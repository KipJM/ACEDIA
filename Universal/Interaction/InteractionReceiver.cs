using Godot;

namespace Pins.Universal.Interaction;

public partial class InteractionReceiver : Node
{
    public bool Listening;
    
    [Signal]
    public delegate void InteractionEventHandler();
    
    [Export]
    private bool _oneShot = false;


    public override void _Ready()
    {
        base._Ready();
        Listening = true;
    }

    public void Interact()
    {
        if (Listening == false)
            return;
        
        if (_oneShot)
            Listening = false;
        EmitSignalInteraction();
    }

    public void InteractProxy(Node3D _)
    {
        Interact();
    }
    
}