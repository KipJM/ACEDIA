using Godot;

namespace Pins.Universal.Audio;

public partial class AutoTrack : Area3D
{
    [Export] public Node3D TrackedObject;

    public override void _PhysicsProcess(double delta)
    {
        base._PhysicsProcess(delta);
        if (HasOverlappingBodies())
        {
            var pos = GetOverlappingBodies()[0].GlobalPosition;
            TrackedObject.GlobalPosition = TrackedObject.GlobalPosition with
            {
                X = pos.X,
                Z = pos.Z
            };
        }
    }
}