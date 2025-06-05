using Godot;
using Pins.Universal.Player;

namespace Pins.Universal.Interaction;

public partial class IntroAnchor : Node3D
{
    [ExportCategory("Anchors")] 
    [Export] private AnimationAnchor _startAnchor;
    [Export] private AnimationAnchor _endAnchor;

    [ExportCategory("Transition")]
    [Export] private StringName _transitionAnimName;
    
    private PlayerAnimator _animator;
    
    public override void _Ready()
    {
        base._Ready();
        _animator = ((Player.Player)GetNode(new NodePath("%Player"))).Animator;

        _animator.AnimationEnd += PotentialExitAnim;
        
        _startAnchor.StartAnimationSequence();
    }

    public void PotentialExitAnim(StringName animName)
    {
        GD.Print($"-> IntroAnchor ({animName})");
        if (animName == _transitionAnimName)
        {
            // Exit Anim!
            _endAnchor.StartAnimationSequence(true);
        }
    }
}