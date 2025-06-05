using Godot;

namespace Pins.Universal.UI;

public partial class UiBase : Control
{
    public Player.Player Player;

    public override void _Ready()
    {
        Player = GetNode<Player.Player>("%Player");
        base._Ready();
    }
}