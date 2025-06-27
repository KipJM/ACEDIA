using Godot;
using Godot.Collections;

namespace Pins.Universal.SceneManagement;

public partial class SceneLoader : Node
{
    [Export] private string _scenePath;
    // [Export] private Node _rootNode; //Unused

    private string _loadingPath = null;
    
    public void PreloadScene()
    {
        PreloadSceneCustom(_scenePath);
    }
    
    public void PreloadSceneCustom(string scenePath)
    {
        ResourceLoader.LoadThreadedRequest(scenePath);
        _loadingPath = scenePath;
    }


    public void SwitchScene()
    {
        SwitchSceneCustom(_scenePath);
    }
    
    public void SwitchSceneCustom(string scenePath)
    {
        // Retrieve Scene
        var scene = RetrieveScene(scenePath);
        
        // Switch
        // if (SceneReset.MenuBack)
        // {
        //     GetTree().ReloadCurrentScene();
        // }
        GetTree().ChangeSceneToPacked(scene);
        GD.Print("CHANGE SCN");
    }

    
    private PackedScene RetrieveScene(string scenePath)
    {
        // GD.Print($"progress: {ResourceLoader.LoadThreadedGetStatus(scenePath)}");
        return (PackedScene)ResourceLoader.LoadThreadedGet(scenePath);
    }

    
    public void SwitchSceneMenu()
    {
        // if (SceneReset.MenuBack)
        // {
        //     GetTree().ReloadCurrentScene();
        // }
        GetTree().Paused = false;
        GetTree().ChangeSceneToFile(_scenePath);
    }

    // public override void _Ready()
    // {
    //     base._Ready();
    //     if (SceneReset.ResetScene)
    //     {
    //         GD.Print("RESET");
    //         SceneReset.ResetScene = false;
    //         
    //     }
    // }
    //
    public override void _Process(double delta)
    {
        base._Process(delta);
        if (_loadingPath != null)
        {
            Array arr = [];
            ResourceLoader.LoadThreadedGetStatus(_loadingPath, arr);
            // GD.Print("progress: ", arr[0]);
            if ((float)arr[0] < 0.999)
            {
                GD.Print("progress: ", arr[0]);
            }
        }
    }
}