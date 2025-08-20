using Godot;
using Godot.Collections;

namespace Pins.Intermission.Egg.Dialog;

public partial class EggDialogManager : Node
{
    [Export] public Node3D SiblingNode;

    [ExportGroup("UI")]
    [Export] public EggDialogUi DialogUi;

    [ExportGroup("Audio")] 
    [Export] public AudioStreamPlayer MusicPlayer;
    
    [ExportGroup("Misc")]
    [Export] public Material SiblingMaterial;
    
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
        SiblingMaterial.Set("flags/depth_test_disabled", false);
        SiblingNode.Show();
    }

    public void StartSequence()
    {
        SiblingMaterial.Set("flags/depth_test_disabled", true);
        MusicPlayer.Play();
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