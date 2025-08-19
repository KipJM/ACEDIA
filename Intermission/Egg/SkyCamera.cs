using Godot;
using Pins.Universal.Player;

namespace Pins.Intermission.Egg;

public partial class SkyCamera : Node3D
{
    [Export] public Camera3D Camera;
    
    private Player _player;

    public override void _Ready()
    {
        base._Ready();
        _player = GetNode<Player>("%Player");
    }

    public override void _Process(double delta)
    {
        base._Process(delta);
        Camera.Rotation = _player.Camera.GlobalRotation;
    }
}