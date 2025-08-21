using System;
using Godot;
using Godot.Collections;
using Pins.Universal.Player;

namespace Pins.Intermission.Egg;

public partial class SkyCamera : Node3D
{
    [Export] public Camera3D Camera;
    [Export] public SubViewport Viewport;

    [ExportGroup("Track")] 
    [Export] public float TrackSpeed;
    
    [ExportGroup("Display")]
    [Export] public Array<ShaderMaterial> Materials;
    [Export] public Node3D SkyboxRoot;

    // [ExportGroup("DEBUG")]
    // [Export] public TextureRect Rect;
    
    private Player _player;
    
    public override void _Ready()
    {
        base._Ready();
        _player = GetNode<Player>("%Player");

        var tex= Viewport.GetTexture();

        // Rect.Texture = tex;

        foreach (var mat in Materials)
        {
            mat.SetShaderParameter("sky_texture", tex);
        }
        Camera.ClearCurrent(false);
        SkyboxRoot.Hide();
    }

    public void StartCamera()
    {
        SkyboxRoot.Show();
        Camera.MakeCurrent();
    }

    public override void _Process(double delta)
    {
        base._Process(delta);
        // var weight = (float)(1 - Math.Exp(-TrackSpeed * delta));
        Camera.Rotation = _player.Camera.GlobalRotation;
    }
}