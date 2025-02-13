using Godot;

namespace Pins.Universal.Player.CharController;

public partial class PlayerLook : Node3D
{
    public CharacterBody3D Body;
    public Node3D Head;
    [ExportGroup("Sensitivity")]
    [Export(PropertyHint.Range, "0.1,2")] private float _mouseSensitivity = 0.4f;
    [Export(PropertyHint.Range, "50,200")] private float _stickSensitivity = 120f;

    [ExportGroup("LookClamp")] 
    [Export(PropertyHint.Range,"-90,0")] public float LookClampMin = -90;
    [Export(PropertyHint.Range,"0,90")] public float LookClampMax = 90;
    
    
    public override void _Ready()
    {
        Input.SetMouseMode(Input.MouseModeEnum.Captured);
    }
    
    public override void _Input(InputEvent inputEvent)
    {
        // Mouse Camera Control
        if (inputEvent is InputEventMouseMotion eventMouseMotion)
        {
            Body.RotateY(Mathf.DegToRad(-eventMouseMotion.Relative.X * _mouseSensitivity));
            Head.RotateX(Mathf.DegToRad(-eventMouseMotion.Relative.Y * _mouseSensitivity));
        }
    }
    
    public override void _Process(double delta)
    {
        // Controller Camera control
        float lookHoriz = Input.GetAxis("look_left", "look_right");
        float lookVert = Input.GetAxis("look_down", "look_up");
		
        Body.RotateY((float)Mathf.DegToRad(-lookHoriz * _stickSensitivity * delta));
        Head.RotateX((float)Mathf.DegToRad(lookVert * _stickSensitivity * delta));
		
		
        // Clamp Y look
        Head.Rotation = Head.Rotation with
        {
            X = float.Clamp(Head.Rotation.X, Mathf.DegToRad(LookClampMin), Mathf.DegToRad(LookClampMax))
        };
    }
}