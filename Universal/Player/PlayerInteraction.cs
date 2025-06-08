using Godot;
using Pins.Universal.Interaction;

namespace Pins.Universal.Player;

public partial class PlayerInteraction : Node3D
{
    public Player Player;

    [ExportGroup("References")] [Export] public RayCast3D InteractorRay;

    [Export] public StringName InteractAction;


    public override void _Process(double delta)
    {
        base._Process(delta);

        Player.IsInteractionHovering = false;
        if (InteractorRay.IsColliding())
        {
            // GD.Print(InteractorRay.GetCollider().ToString());
            if (InteractorRay.GetCollider() is InteractionReceiver receiver)
            {
                // GD.Print("HEHEH");
                if (receiver.Listening)
                {
                    Player.IsInteractionHovering = true;

                    if (Input.IsActionJustPressed(InteractAction))
                    {
                        GD.Print("INTERACT");
                        InteractorRay.GetCollider().Call("Interact");
                        Player.EmitSignal(Player.SignalName.InteractionStart);
                    }
                }
            }
        }
    }
}