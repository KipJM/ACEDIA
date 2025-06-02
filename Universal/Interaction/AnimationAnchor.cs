using Godot;
using Pins.Universal.Player;

namespace Pins.Universal.Interaction;

public partial class AnimationAnchor : Node3D
{
    [ExportGroup("Anchors")] 
    [Export] private Node3D _bodyAnchor;
    [Export] private Node3D _headAnchor;
    [Export] private bool _useHeadBone;

    [ExportGroup("Animation Settings")] 
    [Export] private PlayerState _playerState;
    [Export] private double _lerpDuration;
    
    private PlayerAnimator _animator;

    public override void _Ready()
    {
        base._Ready();
        _animator = ((Player.Player)GetNode(new NodePath("%Player"))).Animator;
    }
    
    public void StartAnimationSequence()
    {
        _animator.PrepareForAnimation(_bodyAnchor, _useHeadBone ? _animator.HeadBone : _headAnchor, _playerState, _lerpDuration);
    }
}