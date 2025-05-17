using Godot;

namespace Pins.Universal;

public partial class Pause : RichTextLabel
{
    [Export]
    private RichTextLabel _pausedLabel;
    public override void _Ready()
    {
        // TODO: Modularize
        Input.SetMouseMode(Input.MouseModeEnum.Captured);
        _pausedLabel.Visible = false;
    }
    
    public override void _Input(InputEvent @event)
    {
        if (Input.IsActionJustPressed("pause"))
        {
            Input.SetMouseMode(Input.MouseMode == Input.MouseModeEnum.Captured ? Input.MouseModeEnum.Visible : Input.MouseModeEnum.Captured);
            GetTree().Paused = !GetTree().Paused;
            _pausedLabel.Visible = !_pausedLabel.Visible;
        }
    }

}