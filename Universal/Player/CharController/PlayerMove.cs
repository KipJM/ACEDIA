using Godot;

namespace Pins.Universal.Player.CharController;

public partial class PlayerMove : Node3D
{
    public Player Player;
    
    [Export] private float _walkingSpeed = 5.0f;
    [Export] private float _sprintingSpeed = 8.0f;
    [Export] private float _squeezeSpeed = 3.0f;
    [Export] public bool IsSqueezing = false;

	
    public float CurrentSpeed = 5.0f;
    private Vector3 _direction = Vector3.Zero;
    
    public override void _PhysicsProcess(double delta)
    {
        // Switch between walking and sprinting
        float targetSpeed = Input.IsActionPressed("sprint") ? _sprintingSpeed : _walkingSpeed;
        // Squeeze override sprinting and walking
        if (IsSqueezing) targetSpeed = _squeezeSpeed;
        // Stop moving if movement is locked
        if (Player.State is PlayerState.LimitedViewOnly or PlayerState.Locked) targetSpeed = 0;
		
        CurrentSpeed = (float)Mathf.Lerp(CurrentSpeed, targetSpeed, delta * Player.LerpSpeed);
        
        // Add the gravity.
        if (!Player.Body.IsOnFloor())
        {
            Player.Body.Velocity += Player.Body.GetGravity() * (float)delta;
        }

        // Get the input direction and handle the movement/deceleration.
        Vector2 inputDir = Input.GetVector(
            "move_left", "move_right", "move_forward", "move_backward");

        if (Player.State is PlayerState.ForwardOnly)
        {
            inputDir.Y = Mathf.Clamp(inputDir.Y, -1.0f, 0f); // Only allows moving forward
        }
        
        _direction = _direction.Lerp(
            Player.Neck.GetGlobalTransform().Basis * new Vector3(inputDir.X, 0, inputDir.Y), (float)(delta * Player.LerpSpeed));
        
        if (_direction != Vector3.Zero)
        {
            Player.Body.Velocity = Player.Body.Velocity with {
                X = _direction.X * CurrentSpeed,  
                Z = _direction.Z * CurrentSpeed  
            };
        }
        else
        {
            Player.Body.Velocity = Player.Body.Velocity with
            {
                X = Mathf.MoveToward(Player.Body.Velocity.X, 0, CurrentSpeed),  
                Z = Mathf.MoveToward(Player.Body.Velocity.Z, 0, CurrentSpeed)
            };
        } 
		
        Player.Body.MoveAndSlide();
		
        // Reset squeeze
        IsSqueezing = false;
    }
}