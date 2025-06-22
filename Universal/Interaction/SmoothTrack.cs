using System;
using Godot;

namespace Pins.Universal.Interaction;

[Tool]
public partial class SmoothTrack : Node3D
{
    [Export] public Node3D Target;
    [Export] public float TrackSpeed;

    public override void _Process(double delta)
    {
        base._Process(delta);
        var weight = (float)(1 - Math.Exp(-TrackSpeed * delta));
        GlobalTransform = GlobalTransform.InterpolateWith(Target.GlobalTransform, weight);
    }
}