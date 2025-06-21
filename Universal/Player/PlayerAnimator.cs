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
    [Export] public Node3D EyeBone;
    [Export] public Curve LerpCurve;
    [ExportGroup("Locomotion")]
    [Export] private CharacterBody3D _playerBody;
    [Export] private StringName _locomotionPropertyPath;
    
    // System-controlled animation
    private Node3D _bodyTransform;
    private Node3D _headTransform;
    private bool _isSiblingIntro;
    private Node3D _lookAtTransform;
    private float _lookVMax;
    private float _lookVMin;
    private float _lookH;
    private float _fov;
    
    private float _fovMemory;
    
    public bool IsAnimationControlActive = false;
    public bool IsAnimationTransitioning = false;
    
    public override void _Process(double delta)
    {
        base._Process(delta);
        
        if (IsAnimationControlActive)
        {
            // GD.Print("UHHHH FUCK");
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
        Player.AnimatedHead.GlobalTransform = _headTransform.GlobalTransform;

        if (_lookAtTransform != null)
        {
            Player.AnimatedHead.GlobalTransform = Player.AnimatedHead.GlobalTransform.LookingAt(_lookAtTransform.GlobalPosition, Vector3.Up);
        }

        if (_isSiblingIntro)
        {
            Player.Camera.SetFov(_fov);
        }
    }

    public void GotoAnimation(StringName key)
    {
        AnimationNodeStateMachinePlayback playback = (AnimationNodeStateMachinePlayback)_playerAnimationTree.Get("parameters/playback");
        playback.Travel(key);
        GD.Print($"Traveled to {key}"); //DEBUG
    }
    
    // Prep

    public void PrepareForAnimation(
        Node3D bodyTransform, Node3D headTransform, PlayerState targetState,
        double duration, Action onPreparationFinished = null,
        float lookVMax = 90f, float lookVMin = -90f, float lookH = 90f, bool resetFov = false, bool isSibling = false, Node3D lookAtTransform = null, float fov = 0f)
    {
        _bodyTransform = bodyTransform;
        _headTransform = headTransform;
        
        _isSiblingIntro = isSibling;
        
        Player.PlayerState = targetState;
        
        _lookVMax = lookVMax;
        _lookVMin = lookVMin;
        _lookH = lookH;

        if (resetFov)
        {
            _fov = _fovMemory;
        }

        if (isSibling)
        {
            _lookAtTransform = lookAtTransform;
            _fov = fov;
        }
        
        
        //             Body (P, R) -> target
        //     AnimatedHead (P, R) -> target
        // [IF STATIC] Neck (   R) -> 0 
        // [IF STATIC] Head (   R) -> 0
        
        // Start transition
        IsAnimationControlActive = false;
        Timing.RunCoroutine(LerpToAnchor(duration, onPreparationFinished, isSibling, resetFov).CancelWith(this));
    }

    IEnumerator<double> LerpToAnchor(double duration, Action onPreparationFinished, bool isSibling, bool resetFov)
    {
        IsAnimationTransitioning = true;
        
        double currentTime = 0;
        
        Transform3D bodySt = Player.Body.GlobalTransform;
        Transform3D headGSt = Player.AnimatedHead.GlobalTransform;
        Vector3 camRot = Player.Camera.Rotation;
        // Vector3 hdRot = Player.Head.Rotation;
        // Vector3 nekRot = Player.Neck.Rotation;
        float lkVMax = Player.Look.LookClampVMax;
        float lkVMin = Player.Look.LookClampVMin;
        float lkH = Player.Look.LookClampH;

        _fovMemory = Player.Camera.GetFov();
        
        while (true) // scaryyyyyy
        {
            float weight = (duration < 0) ? 1f : LerpCurve.Sample((float)(currentTime / duration));
            
            // GD.Print(weight);

            Player.Body.GlobalTransform =
                bodySt.InterpolateWith(_bodyTransform.GlobalTransform, weight);

            if (!isSibling)
            {
                Player.AnimatedHead.GlobalTransform =
                    headGSt.InterpolateWith(_headTransform.GlobalTransform, weight);
                if (resetFov)
                {
                    Player.Camera.SetFov(float.Lerp(_fovMemory, _fov, weight));
                }
            }
            else
            {
                Player.AnimatedHead.GlobalTransform = 
                    headGSt.InterpolateWith(_headTransform.GlobalTransform.LookingAt(_lookAtTransform.GlobalPosition, Vector3.Up), weight);
                Player.Camera.SetFov(float.Lerp(_fovMemory, _fov, weight));
            }
            

            Player.Camera.Rotation = camRot.Lerp(Vector3.Zero, weight);

            // Guide player view to object of interest
            Player.Neck.Rotation = Player.Neck.Rotation.Lerp(Vector3.Zero, weight);
            Player.Head.Rotation = Player.Head.Rotation.Lerp(Vector3.Zero, weight);


            Player.Look.LookClampVMax = float.Lerp(lkVMax, _lookVMax, weight);
            Player.Look.LookClampVMin = float.Lerp(lkVMin, _lookVMin, weight);

            Player.Look.LookClampH = float.Lerp(lkH, _lookH, weight);

            
            if (currentTime >= duration) // Make sure lerp ran at least once
            {
                break;
            }
            
            yield return Timing.WaitForOneFrame;
            currentTime += GetProcessDeltaTime();
            // GD.Print(weight);
        }
        
        IsAnimationTransitioning = false;

        if (resetFov)
        {
            Player.Camera.SetFov(_fov);
        }
        
        AnimationPrepared(onPreparationFinished);
    }

    private void AnimationPrepared(Action onPreparationFinished)
    {
        IsAnimationControlActive = true; // if inverse, let animationAnchor unlock
        GD.Print("send prep finished sig");
        onPreparationFinished?.Invoke(); // nullable
    }

    public void UnlockPlayer()
    {
        IsAnimationControlActive = false;
        _bodyTransform = null;
        _headTransform = null;
        _lookAtTransform = null;
    }
    
    [Signal]
    public delegate void AnimationEndEventHandler(StringName animationName);
    
    // External
    public void AnimationEndEventReceiver(StringName animationName)
    {
        GD.Print("Mixer -> PlayerAnimator");
        EmitSignalAnimationEnd(animationName);
    }
}