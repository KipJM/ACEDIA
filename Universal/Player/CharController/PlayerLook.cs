using System;
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
    // [Export(PropertyHint.Range,"-90,0")] public float LookClampHMin = -90;
    [Export(PropertyHint.Range,"0,90")] public float LookClampH = 90;

    [ExportGroup("Tilt")] 
    [Export] public Curve TiltCurve;
    [Export] public float TiltAmount = 3f;

    [ExportGroup("Head Bobbing")] 
    [ExportSubgroup("Speed")]
    [Export] private float _bobbingWalkingSpeed = 14.0f;
    [Export] private float _bobbingSprintingSpeed = 22.0f;
    [Export] private float _bobbingSqueezeSpeed = 10.0f;
    [ExportSubgroup("Intensity")]
    [Export] private float _bobbingWalkingIntensity = 0.2f;
    [Export] private float _bobbingSprintingIntensity = 0.1f;
    [Export] private float _bobbingSqueezeIntensity = 0.05f;

    private float _bobbingCurrentIntensity = 0f;
    
    private Vector2 _bobbingVector = Vector2.Zero;
    private float _bobbingIndex = 0f;
    
    public override void _Input(InputEvent inputEvent)
    {
        // Mouse Camera Control
        if (inputEvent is InputEventMouseMotion eventMouseMotion)
        {
            View(-eventMouseMotion.Relative.X * _mouseSensitivity, 
                -eventMouseMotion.Relative.Y * _mouseSensitivity);
        }
    }
    
    private void ProcessGamepadInput(double delta)
    {
        // Controller Camera control
        float lookHoriz = Input.GetAxis("look_left", "look_right");
        float lookVert = Input.GetAxis("look_down", "look_up");
		
        View((float)(-lookHoriz * _stickSensitivity * delta),
            (float)(lookVert * _stickSensitivity * delta));
    }
    
    public override void _Process(double delta)
    {
        ProcessGamepadInput(delta);

        if (Player.PlayerState is PlayerState.Normal)
        {
            // Reset head tilt
            Player.Camera.Rotation = Player.Camera.Rotation with
            {
                Z = (float)Mathf.Lerp(Player.Camera.Rotation.Z, 0, delta * Player.LerpSpeed)
            };
        }
        
        // Head Bob
        switch (Player.MovementState)
        {
            case MovementState.Walking:
                _bobbingCurrentIntensity = _bobbingWalkingIntensity;
                _bobbingIndex += _bobbingWalkingSpeed * (float)delta;
                break;
            case MovementState.Sprinting:
                _bobbingCurrentIntensity = _bobbingSprintingIntensity;
                _bobbingIndex += _bobbingSprintingSpeed * (float)delta;
                break;
            case MovementState.Squeezing:
                _bobbingCurrentIntensity = _bobbingSqueezeIntensity;
                _bobbingIndex += _bobbingSqueezeSpeed * (float)delta;
                break;  
        }

        if (Player.IsFeetMoving)
        {
            // Head bobbing
            
            _bobbingVector.Y = (float)Math.Sin(_bobbingIndex);
            _bobbingVector.X = (float)(Math.Sin(_bobbingIndex / 2) + 0.5);

            Player.Eyes.Position = Player.Eyes.Position with
            {
                X = float.Lerp(Player.Eyes.Position.X, _bobbingVector.X * _bobbingCurrentIntensity,
                    (float)(delta * Player.LerpSpeed)),
                Y = float.Lerp(Player.Eyes.Position.Y, _bobbingVector.Y * (_bobbingCurrentIntensity / 2.0f),
                    (float)(delta * Player.LerpSpeed))
            };
        }
        else
        {
            // Reset Head bobbing
            Player.Eyes.Position = Player.Eyes.Position with
            {
                X = float.Lerp(Player.Eyes.Position.X, 0, (float)(delta * Player.LerpSpeed)),
                Y = float.Lerp(Player.Eyes.Position.Y, 0, (float)(delta * Player.LerpSpeed))
            };
        }
    }
    

    public void View(float horizontal, float vertical)
    {
        if (Player.PlayerState == PlayerState.Locked) return;
        
        // Up-down view
        
        Player.Head.RotateX(Mathf.DegToRad(vertical));
        // Clamp Y
        Player.Head.Rotation = Player.Head.Rotation with
        {
            X = float.Clamp(Player.Head.Rotation.X, Mathf.DegToRad(LookClampVMin), Mathf.DegToRad(LookClampVMax))
        };
        
        // Left-right view
        if (Player.PlayerState is PlayerState.ForwardOnly or PlayerState.LimitedViewOnly)
        {
            // Limited left-right view
            
            Player.Neck.RotateY(Mathf.DegToRad(horizontal));
            // Clamp X look
            Player.Neck.Rotation = Player.Neck.Rotation with
            {
                Y = float.Clamp(Player.Neck.Rotation.Y, Mathf.DegToRad(-LookClampH), Mathf.DegToRad(LookClampH)),
            };
            
            // Tilt Head
            Player.Camera.Rotation = Player.Camera.Rotation with
            {
                Z = Mathf.DegToRad(Math.Sign(-Player.Neck.Rotation.Y) * TiltCurve.Sample(Math.Abs(Player.Neck.RotationDegrees.Y)/LookClampH) * TiltAmount)
            };
        }
        else
        {
            // Normal left-right view
            
            Player.Body.Rotation = Player.Body.Rotation with { Y = Player.Neck.GlobalRotation.Y }; // Transfer Neck to Body
            Player.Neck.Rotation = Player.Neck.Rotation with { Y = 0 }; // Reset Neck
            Player.Body.RotateY(Mathf.DegToRad(horizontal));
        }
    }
}