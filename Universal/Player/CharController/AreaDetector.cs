using Godot;

namespace Pins.Universal.Player.CharController;

public partial class AreaDetector : Area3D
{
    private int _previousAreasCount = 0;
    
    [Signal]
    public delegate void SqueezeAreaEnteredEventHandler();
    
    [Signal]
    public delegate void SqueezeAreaExitedEventHandler();
    
    public override void _PhysicsProcess(double delta)
    {
        if (GetOverlappingAreas().Count > 0 && _previousAreasCount == 0)
        {
            EmitSignal(SignalName.SqueezeAreaEntered);
        }

        if (GetOverlappingAreas().Count == 0 && _previousAreasCount > 0)
        {
            EmitSignal(SignalName.SqueezeAreaExited);
        }
        
        _previousAreasCount = GetOverlappingAreas().Count;
    }
}