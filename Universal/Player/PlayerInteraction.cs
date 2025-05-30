using Godot;

namespace Pins.Universal.Player;

public partial class PlayerInteraction : Node3D
{
    public Player Player;

    [ExportGroup("References")] [Export] public RayCast3D InteractorRay;

    [Export] public StringName InteractAction;


    public override void _Process(double delta)
    {
        base._Process(delta);
        Player.IsInteractionHovering = InteractorRay.IsColliding();

        if (Player.IsInteractionHovering)
        {
            if (Input.IsActionJustPressed(InteractAction))
            {
                GD.Print("INTERACT");
                // InteractorRay.GetCollider().Call("Interact"); //TODO
                Player.EmitSignal(Player.SignalName.InteractionStart);
            }
        }
    }
}