using System;
using System.Collections.Generic;
using System.Numerics;
using Godot;
using MEC;
using Vector2 = Godot.Vector2;
using Vector3 = Godot.Vector3;

namespace Pins.Universal.Player;

public partial class PlayerAnimator : Node3D
{
    public Player Player;
    
    [ExportGroup("Animation")]
    [Export] private AnimationTree _playerAnimationTree;
    [Export] public Node3D HeadBone;
    [Export] public Curve LerpCurve;
    [ExportGroup("Locomotion")]
    [Export] private CharacterBody3D _playerBody;
    [Export] private StringName _locomotionPropertyPath;
    
    // System-controlled animation
    private Node3D _bodyTransform;
    private Node3D _headTransform;

    private bool _isAnimationControlActive = false;
    
    public override void _Process(double delta)
    {
        base._Process(delta);

        if (_isAnimationControlActive)
        {
            UpdateAnchors();
        }
        else
        {
            UpdateLocomotion();
        }
    }

    // Locomotion

    void UpdateLocomotion()
    {
        Vector3 localVelocity = _playerBody.Transform.Inverse().Basis * _playerBody.Velocity;
        // DebugDraw3D.DrawArrowRay(_playerBody.Position, localVelocity, 1, Colors.Aqua);
        Vector2 velocity = new Vector2(localVelocity.X, -localVelocity.Z);

        _playerAnimationTree.Set(_locomotionPropertyPath, velocity);
    }
    
    // Controlled Animation
    private void UpdateAnchors()
    {
        Player.Body.GlobalTransform = _bodyTransform.GlobalTransform;
        if (_headTransform == HeadBone)
        {
            Player.AnimatedHead.GlobalTransform = _headTransform.GlobalTransform;
            // Player.AnimatedHead.Rotation = -Player.AnimatedHead.Rotation;
        }
        else
        {
            Player.AnimatedHead.Transform = _headTransform.Transform;
        }
    }

    public void EnableAnimation(StringName key, bool value = true)
    {
        _playerAnimationTree.Set(key, true);
    }
    
    // Prep

    public void PrepareForAnimation(Node3D bodyTransform, Node3D headTransform, PlayerState targetState,
        double duration, Action onPreparationFinished)
    {
        _bodyTransform = bodyTransform;
        _headTransform = headTransform;

        Player.PlayerState = targetState;
        
        //             Body (P, R) -> target
        //     AnimatedHead (P, R) -> target
        // [IF STATIC] Neck (   R) -> 0 
        // [IF STATIC] Head (   R) -> 0
        
        // Start transition
        Timing.RunCoroutine(LerpToAnchor(duration, targetState == PlayerState.Locked, onPreparationFinished).CancelWith(this));
    }

    IEnumerator<double> LerpToAnchor(double duration, bool toLocked, Action onPreparationFinished)
    {
        double currentTime = 0;
        while (currentTime < duration)
        {
            float weight = LerpCurve.SampleBaked((float)(currentTime / duration));

            Player.Body.GlobalTransform =
                Player.Body.GlobalTransform.InterpolateWith(_bodyTransform.GlobalTransform, weight);

            if (_headTransform == HeadBone)
            {
                Player.AnimatedHead.GlobalTransform =
                    Player.AnimatedHead.GlobalTransform.InterpolateWith(_headTransform.GlobalTransform, weight);
            }
            else
            {
                Player.AnimatedHead.Transform =
                    Player.AnimatedHead.Transform.InterpolateWith(_headTransform.Transform, weight); // WARN: Local transform
            }

            Player.Camera.Rotation = Player.Camera.Rotation.Lerp(Vector3.Zero, weight);
            
            if (toLocked)
            {
                Player.Neck.Rotation = Player.Neck.Rotation.Lerp(Vector3.Zero, weight);
                Player.Head.Rotation = Player.Head.Rotation.Lerp(Vector3.Zero, weight);
            }

            yield return Timing.WaitForOneFrame;
            currentTime += GetProcessDeltaTime();
        }
        AnimationPrepared(onPreparationFinished);
    }

    private void AnimationPrepared(Action onPreparationFinished)
    {
        _isAnimationControlActive = true;
        onPreparationFinished.Invoke();
    }
}