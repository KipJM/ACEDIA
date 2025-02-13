using Godot;

namespace Pins.Universal.Player.CharController;

public partial class PlayerMove : Node3D
{
    [Export] private float _walkingSpeed = 5.0f;
    [Export] private float _sprintingSpeed = 8.0f;
    [Export] private float _squeezeSpeed = 3.0f;
    [Export] public bool IsSqueezing = false;
    [ExportSubgroup("Easing")]
    [Export] private float _lerpSpeed = 10.0f;
	
    public float CurrentSpeed = 5.0f;
    private Vector3 _direction = Vector3.Zero;

    public CharacterBody3D Body;
    
    public override void _PhysicsProcess(double delta)
    {
        // Switch between walking and sprinting
        var targetSpeed = Input.IsActionPressed("sprint") ? _sprintingSpeed : _walkingSpeed;
        // Squeeze override sprinting and walking
        if (IsSqueezing) targetSpeed = _squeezeSpeed;
		
        CurrentSpeed = (float)Mathf.Lerp(CurrentSpeed, targetSpeed, delta * _lerpSpeed);
		

        // Add the gravity.
        if (!Body.IsOnFloor())
        {
            Body.Velocity += Body.GetGravity() * (float)delta;
        }

        // Get the input direction and handle the movement/deceleration.
        Vector2 inputDir = Input.GetVector(
            "move_left", "move_right", "move_forward", "move_backward");
        _direction = _direction.Lerp(
            Body.Transform.Basis * new Vector3(inputDir.X, 0, inputDir.Y), (float)(delta * _lerpSpeed));
		
        if (_direction != Vector3.Zero)
        {
            Body.Velocity = Body.Velocity with {
                X = _direction.X * CurrentSpeed,  
                Z = _direction.Z * CurrentSpeed  
            };
        }
        else
        {
            Body.Velocity = Body.Velocity with
            {
                X = Mathf.MoveToward(Body.Velocity.X, 0, CurrentSpeed),  
                Z = Mathf.MoveToward(Body.Velocity.Z, 0, CurrentSpeed)
            };
        } 
		
        Body.MoveAndSlide();
		
        // Reset squeeze
        IsSqueezing = false;
    }
}