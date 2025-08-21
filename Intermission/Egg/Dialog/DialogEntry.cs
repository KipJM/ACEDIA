using Godot;

namespace Pins.Intermission.Egg.Dialog;

public enum DialogTransType
{
    Typewriter,
    Fade
}

public enum DialogAnimType
{
    None,
    Local,
    Sky
}

[GlobalClass]
public partial class DialogEntry : Resource
{
    [ExportGroup("Dialog")]
    [Export(PropertyHint.MultilineText)] 
    public string Content { get; set; }

    [ExportGroup("Transition")]
    [ExportSubgroup("In")] 
    [Export] public float InWaitDuration { get; set; }
    [Export] public DialogTransType InType { get; set; }
    [Export] public float InDuration { get; set; }
    [ExportSubgroup("Out")] 
    [Export] public float WaitDuration { get; set; }
    [Export] public float OutDuration { get; set; }
    
    [ExportGroup("Animation")] 
    [Export] public DialogAnimType HaveAnimation { get; set; }
    [Export] public string TargetAnimationKey { get; set; }

    
    public DialogEntry() : this("", 0, DialogTransType.Fade, 0, 0, 0, DialogAnimType.None, "") {}
    public DialogEntry(string content, float inWaitDuration, DialogTransType inType, float inDuration, float waitDuration, float outDuration, DialogAnimType haveAnimation, string targetAnimationKey)
    {
        Content = content;
        InWaitDuration = inWaitDuration;
        InType = inType;
        InDuration = inDuration;
        WaitDuration = waitDuration;
        OutDuration = outDuration;
        HaveAnimation = haveAnimation;
        TargetAnimationKey = targetAnimationKey;
    }
}