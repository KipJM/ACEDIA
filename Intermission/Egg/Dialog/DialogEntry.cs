using Godot;

namespace Pins.Intermission.Egg.Dialog;

public enum DialogTransType
{
    Typewriter,
    Fade
}

[GlobalClass]
public partial class DialogEntry : Resource
{
    [ExportGroup("Dialog")]
    [Export(PropertyHint.MultilineText)] 
    public string Content { get; set; }

    [ExportGroup("Transition")]
    [ExportSubgroup("In")] 
    [Export] public DialogTransType InType { get; set; }
    [Export] public float InDuration { get; set; }
    [ExportSubgroup("Out")] 
    [Export] public float WaitDuration { get; set; }
    [Export] public float OutDuration { get; set; }
    
    [ExportGroup("Animation")] 
    [Export] public bool HaveAnimation { get; set; }
    [Export] public string TargetAnimationKey { get; set; }

    
    public DialogEntry() : this("", DialogTransType.Fade, 0, 0, 0, false, "") {}
    public DialogEntry(string content, DialogTransType inType, float inDuration, float waitDuration, float outDuration, bool haveAnimation, string targetAnimationKey)
    {
        Content = content;
        InType = inType;
        InDuration = inDuration;
        WaitDuration = waitDuration;
        OutDuration = outDuration;
        HaveAnimation = haveAnimation;
        TargetAnimationKey = targetAnimationKey;
    }
}