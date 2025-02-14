using Godot;

namespace Pins.Universal.Player.CharController;

public partial class PlayerLook : Node3D
{
    public Player Player;
    [ExportGroup("Sensitivity")]
    [Export(PropertyHint.Range, "0.1,2")] private float _mouseSensitivity = 0.4f;
    [Export(PropertyHint.Range, "50,200")] private float _stickSensitivity = 120f;

    [ExportGroup("LookClamp")] 
    [ExportSubgroup("Vertical")]
    [Export(PropertyHint.Range,"-90,0")] public float LookClampVMin = -90;
    [Export(PropertyHint.Range,"0,90")] public float LookClampVMax = 90;
    [ExportSubgroup("Horizontal")]
    [Export(PropertyHint.Range,"-90,0")] public float LookClampHMin = -90;
    [Export(PropertyHint.Range,"0,90")] public float LookClampHMax = 90;

    [ExportGroup("Tilt")] 
    [Export] public float TiltAmount = 3f;
    
    public override void _Input(InputEvent inputEvent)
    {
        // Mouse Camera Control
        if (inputEvent is InputEventMouseMotion eventMouseMotion)
        {
            View(-eventMouseMotion.Relative.X * _mouseSensitivity, 
                -eventMouseMotion.Relative.Y * _mouseSensitivity);
        }
    }
    
    public override void _Process(double delta)
    {
        // Controller Camera control
        float lookHoriz = Input.GetAxis("look_left", "look_right");
        float lookVert = Input.GetAxis("look_down", "look_up");
		
        View((float)(-lookHoriz * _stickSensitivity * delta),
            (float)(lookVert * _stickSensitivity * delta));

        if (Player.State is PlayerState.Normal)
        {
            // Reset head tilt
            Player.Camera.Rotation = Player.Camera.Rotation with
            {
                Z = (float)Mathf.Lerp(Player.Camera.Rotation.Z, 0, delta * Player.LerpSpeed)
            };
        }
       
    }

    public void View(float horizontal, float vertical)
    {
        if (Player.State == PlayerState.Locked) return;
        
        // Rotate
        Player.Head.RotateX(Mathf.DegToRad(vertical));
        
        // Clamp Y look
        Player.Head.Rotation = Player.Head.Rotation with
        {
            X = float.Clamp(Player.Head.Rotation.X, Mathf.DegToRad(LookClampVMin), Mathf.DegToRad(LookClampVMax))
        };
        

        // Limited view
        if (Player.State is PlayerState.ForwardOnly or PlayerState.LimitedViewOnly)
        {
            Player.Neck.RotateY(Mathf.DegToRad(horizontal));
            // Clamp X look
            Player.Neck.Rotation = Player.Neck.Rotation with
            {
                Y = float.Clamp(Player.Neck.Rotation.Y, Mathf.DegToRad(LookClampHMin), Mathf.DegToRad(LookClampHMax)),
            };
            
            // Tilt Head
            Player.Camera.Rotation = Player.Camera.Rotation with
            {
                Z = Mathf.DegToRad(-Player.Neck.Rotation.Y * TiltAmount)
            };
        }
        else
        {
            Player.Body.Rotation = Player.Body.Rotation with { Y = Player.Neck.GlobalRotation.Y }; // Transfer Neck to Body
            Player.Neck.Rotation = Player.Neck.Rotation with { Y = 0 }; // Reset Neck
            Player.Body.RotateY(Mathf.DegToRad(horizontal));
        }
    }
}