using Godot;

namespace Pins.Universal;

public partial class Pause : Control
{
    private bool _paused;

    [Export] 
    private Control _exitGamePanel;

    [Export]
    private Control _settingsPanel;
    
    
    public override void _Ready()
    {
        // TODO: Modularize
        Input.SetMouseMode(Input.MouseModeEnum.Captured);
        Visible = false;
        _paused = false;
        
        HideExitPanel();
        HideSettingsPanel();
    }
    
    public override void _Input(InputEvent @event)
    {
        if (Input.IsActionJustPressed("pause"))
        {
            TogglePause();
        }
    }

    public void TogglePause()
    {
        if (_paused)
        {
            ResumeGame();
        }
        else
        {
            PauseGame();
        }
    }

    public void PauseGame()
    {
        Input.SetMouseMode(Input.MouseModeEnum.Visible);

        Visible = true;
        GetTree().Paused = true;
        _paused = true;
        
    }

    public void ResumeGame()
    {
        Input.SetMouseMode(Input.MouseModeEnum.Captured);
        
        Visible = false;
        GetTree().Paused = false;
        _paused = false;
        
        HideExitPanel();
    }

    public void HideExitPanel()
    {
        _exitGamePanel.Visible = false;
    }

    public void ToggleExitPanel()
    {
        _exitGamePanel.Visible = !_exitGamePanel.Visible;
    }

    public void HideSettingsPanel()
    {
        _settingsPanel.Visible = false;
    }
    
    public void ToggleSettingsPanel()
    {
        _settingsPanel.Visible = !_settingsPanel.Visible;
    }
}