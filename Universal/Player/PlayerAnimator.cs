using Godot;

namespace Pins.Universal.Player;

public partial class PlayerAnimator : Node3D
{
    [ExportGroup("Animation")]
    [Export] private AnimationTree _playerAnimationTree;
    [ExportGroup("Locomotion")]
    [Export] private CharacterBody3D _playerBody;
    [Export] private StringName _locomotionPropertyPath;
    
    public override void _Process(double delta)
    {
        base._Process(delta);
        UpdateLocomotion();
    }

    void UpdateLocomotion()
    {
        Vector3 localVelocity = _playerBody.Transform.Inverse().Basis * _playerBody.Velocity;
        // DebugDraw3D.DrawArrowRay(_playerBody.Position, localVelocity, 1, Colors.Aqua);
        Vector2 velocity = new Vector2(localVelocity.X, -localVelocity.Z);

        _playerAnimationTree.Set(_locomotionPropertyPath, velocity);
    }
}