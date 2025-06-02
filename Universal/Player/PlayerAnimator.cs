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
    private float _lookVMax;
    private float _lookVMin;
    private float _lookH;

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

    public void PrepareForAnimation(
        Node3D bodyTransform, Node3D headTransform, PlayerState targetState,
        double duration, Action onPreparationFinished = null,
        float lookVMax = 90f, float lookVMin = -90f, float lookH = 90f)
    {
        _bodyTransform = bodyTransform;
        _headTransform = headTransform;

        Player.PlayerState = targetState;
        
        _lookVMax = lookVMax;
        _lookVMin = lookVMin;
        _lookH = lookH;
        
        //             Body (P, R) -> target
        //     AnimatedHead (P, R) -> target
        // [IF STATIC] Neck (   R) -> 0 
        // [IF STATIC] Head (   R) -> 0
        
        // Start transition
        Timing.RunCoroutine(LerpToAnchor(duration, onPreparationFinished).CancelWith(this));
    }

    IEnumerator<double> LerpToAnchor(double duration, Action onPreparationFinished)
    {
        double currentTime = 0;
        
        Transform3D bodySt = _bodyTransform.GlobalTransform;
        Transform3D headGSt = _headTransform.GlobalTransform;
        Transform3D headSt = _headTransform.Transform;
        Vector3 camRot = Player.Camera.Rotation;
        Vector3 hdRot = Player.Head.Rotation;
        Vector3 nekRot = Player.Neck.Rotation;
        float lkVMax = Player.Look.LookClampVMax;
        float lkVMin = Player.Look.LookClampVMin;
        float lkH = Player.Look.LookClampH;
        
        while (currentTime < duration)
        {
            float weight = LerpCurve.Sample((float)(currentTime / duration));

            Player.Body.GlobalTransform =
                bodySt.InterpolateWith(_bodyTransform.GlobalTransform, weight);

            if (_headTransform == HeadBone)
            {
                Player.AnimatedHead.GlobalTransform =
                    headGSt.InterpolateWith(_headTransform.GlobalTransform, weight);
            }
            else
            {
                Player.AnimatedHead.Transform =
                    headSt.InterpolateWith(_headTransform.Transform, weight); // WARN: Local transform
            }

            Player.Camera.Rotation = camRot.Lerp(Vector3.Zero, weight);

            if (Player.PlayerState != PlayerState.Normal)
            {
                Player.Neck.Rotation = nekRot.Lerp(Vector3.Zero, weight);
                Player.Head.Rotation = hdRot.Lerp(Vector3.Zero, weight);

                if (Player.PlayerState is PlayerState.LimitedViewOnly or PlayerState.ForwardOnly)
                {
                    Player.Look.LookClampVMax = float.Lerp(lkVMax, _lookVMax, weight);
                    Player.Look.LookClampVMin = float.Lerp(lkVMin, _lookVMin, weight);

                    Player.Look.LookClampH = float.Lerp(lkH, _lookH, weight);
                    
                }
            }

            yield return Timing.WaitForOneFrame;
            currentTime += GetProcessDeltaTime();
            GD.Print(weight);
        }
        AnimationPrepared(onPreparationFinished);
    }

    private void AnimationPrepared(Action onPreparationFinished)
    {
        _isAnimationControlActive = true;
        if (onPreparationFinished != null)
            onPreparationFinished.Invoke();
    }
}