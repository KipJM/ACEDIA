using System;
using System.Collections.Generic;
using Godot;
using MEC;
using Pins.Universal.Player;

namespace Pins.Universal.Interaction;

public partial class AnimationAnchor : Node3D
{
    [ExportGroup("Anchors")] 
    [Export] private Node3D _bodyAnchor;
    [Export] private Node3D _headAnchor;
    [Export] private bool _useHeadBone;
    [Export] private bool _isTrainAnim;
    [ExportGroup("Look")] 
    [Export] private float _vLimitMax;
    [Export] private float _vLimitMin;
    [Export] private float _hLimit;

    [ExportGroup("Animation Settings")] 
    [Export] private PlayerState _playerState;
    [Export] private double _lerpDuration;
    [ExportSubgroup("Animation")]
    [Export] private StringName _animationName;
    [Export] private double _wait;

    [ExportGroup("Additional Animation")] 
    [Export] private AnimationPlayer _externalPlayer;
    [Export] private StringName _externalAnimName;
    
    private PlayerAnimator _animator;

    public override void _Ready()
    {
        base._Ready();
        _animator = ((Player.Player)GetNode(new NodePath("%Player"))).Animator;
    }
    
    public void StartAnimationSequence(bool inverse = false)
    {
        if (_isTrainAnim)
        {
            _animator.Player.Camera.SetCullMaskValue(20, true); // unhide player
            _animator.PrepareForAnimation(_bodyAnchor, _animator.EyeBone,
                _playerState, _lerpDuration, () => OnPreparationFinished(inverse), 
                _vLimitMax, _vLimitMin, _hLimit);
        }
        else
        {
            _animator.PrepareForAnimation(_bodyAnchor, 
                _useHeadBone ? _animator.HeadBone : _headAnchor,
                _playerState, _lerpDuration, () => OnPreparationFinished(inverse), 
                _vLimitMax, _vLimitMin, _hLimit);
        }
    }

    // Auto callback from PlayerAnimator
    public void OnPreparationFinished(bool inverse)
    {
        if (inverse)
        {
            if (_wait < 0.01)
            {
                _animator.UnlockPlayer();
            }
            else
            {
                // Timer
                Timing.RunCoroutine(Timer(_wait, _animator.UnlockPlayer).CancelWith(this));
            }
            
        }
        else
        {
            if (_wait < 0.01)
            {
                RunAnimation();
            }
            else
            {
                // Timer
                Timing.RunCoroutine(Timer(_wait, RunAnimation).CancelWith(this));
            }
        }
        
    }

    [Signal]
    public delegate void AnimationStartEventHandler();
    
    public void RunAnimation()
    {
        if (_animationName != "[SKIP]")
        {
            _animator.GotoAnimation(_animationName);
        }
        
        EmitSignalAnimationStart();
    }
    
    IEnumerator<double> Timer(double time, Action action)
    {
        yield return Timing.WaitForSeconds(time);
        action.Invoke();
    }
    
    // External
    public void PlayExternalAnimation()
    {
        _externalPlayer.Play(_externalAnimName);
    }

    
}