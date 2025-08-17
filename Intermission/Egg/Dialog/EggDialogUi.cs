using Godot;

namespace Pins.Intermission.Egg.Dialog;

public partial class EggDialogUi : Control
{
    public override void _Ready()
    {
        base._Ready();
        Hide();
    }

    public void ShowUi()
    {
        Show();
    }
}