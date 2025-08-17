using Godot;

namespace Pins.Intermission.Egg.Dialog;

public partial class EggDialogManager : Node
{
    [Export] public Node3D SiblingNode;

    [ExportCategory("UI")]
    [Export] public EggDialogUi DialogUi;
    
    public override void _Ready()
    {
        base._Ready();
        SiblingNode.Hide();
    }

    public void ShowSibling()
    {
        SiblingNode.Show();
    }

    public void StartSequence()
    {
        DialogUi.ShowUi();
    }

}