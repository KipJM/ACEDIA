using Godot;

namespace Pins.Universal.UI;

public partial class UiBase : Control
{
    public Player.Player Player;

    [Export] 
    private Control _sprintHint;
    
    public override void _Ready()
    {
        Player = GetNode<Player.Player>("%Player");
        base._Ready();
    }

    public void ShowSprintHint()
    {
        _sprintHint.Visible = true;
    }

    public void HideSprintHint()
    {
        _sprintHint.Visible = false;
    }
}