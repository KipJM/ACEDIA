using Godot;
using Godot.Collections;

namespace Pins.Intermission.Egg.Dialog;

public partial class EggDialogManager : Node
{
    [Export] public Node3D SiblingNode;

    [ExportGroup("UI")]
    [Export] public EggDialogUi DialogUi;

    [ExportGroup("Dialogs")] 
    [Export] public Array<DialogEntry> Entries;

    private int _currentEntryId = -1;
    
    public override void _Ready()
    {
        base._Ready();
        SiblingNode.Hide();
        DialogUi.EntryFinished += NextEntry;
    }

    public void ShowSibling()
    {
        SiblingNode.Show();
    }

    public void StartSequence()
    {
        DialogUi.ShowUi();
        NextEntry();
    }

    public void NextEntry()
    {
        GD.Print("NEXT DIALOG");
        _currentEntryId++;
        if (_currentEntryId >= 0 && _currentEntryId < Entries.Count)
        {
            DialogUi.StartEntry(Entries[_currentEntryId]);
        }
    }
    
}