using System;
using Godot;

namespace Pins.Universal.Player.CharController;

public partial class PlayerMove : Node3D
{
    public Player Player;
    
    [Export] private float _walkingSpeed = 5.0f;
    [Export] private float _sprintingSpeed = 8.0f;
    [Export] private float _squeezeSpeed = 3.0f;

	
    public float CurrentSpeed = 5.0f;
    private Vector3 _direction = Vector3.Zero;
    
    public override void _PhysicsProcess(double delta)
    {
        var actualVelocity = Player.Body.Velocity;
        
        if (Player.MovementState != MovementState.Squeezing)
        {
            if (Input.IsActionPressed("sprint"))
            {
                Player.MovementState = MovementState.Sprinting;
            }
            else
            {
                Player.MovementState = MovementState.Walking;
            }
        }


        float targetSpeed = 0;
        switch (Player.MovementState)
        {
            case MovementState.Walking:
                targetSpeed = _walkingSpeed;
                break;
            case MovementState.Sprinting:
                targetSpeed = _sprintingSpeed;
                break;
            case MovementState.Squeezing:
                targetSpeed = _squeezeSpeed;
                break;
        }
        
        // Stop moving if movement is locked
        if (Player.PlayerState is PlayerState.LimitedViewOnly or PlayerState.Locked) targetSpeed = 0;
		
        CurrentSpeed = (float)Mathf.Lerp(CurrentSpeed, targetSpeed, delta * Player.LerpSpeed);
        
        // Add gravity
        if (!Player.Body.IsOnFloor())
        {
            Player.Body.Velocity += Player.Body.GetGravity() * (float)delta;
        }

        // Get the input direction and handle the movement/deceleration.
        Vector2 inputDir = Input.GetVector(
            "move_left", "move_right", "move_forward", "move_backward");

        // if (Player.PlayerState is PlayerState.ForwardOnly)
        // {
        //     inputDir.Y = Mathf.Clamp(inputDir.Y, -1.0f, 0f); // Only allows moving forward
        // }
        
        _direction = _direction.Lerp(
            Player.Neck.GetGlobalTransform().Basis * new Vector3(inputDir.X, 0, inputDir.Y), (float)(delta * Player.LerpSpeed));
        
        if (_direction != Vector3.Zero)
        {
            if (Player.PlayerState != PlayerState.ForwardOnly || (-Player.Body.GlobalBasis.Z).Dot(_direction)>=0)
            {
                Player.Body.Velocity = Player.Body.Velocity with
                {
                    X = _direction.X * CurrentSpeed,
                    Z = _direction.Z * CurrentSpeed
                };
            }
            else
            {
                // Only allow moving forward
                var localDirection = Player.Body.GetGlobalBasis().Inverse() * (_direction * CurrentSpeed);
                localDirection.Z = 0;
                var finalDirection = Player.Body.GlobalBasis * localDirection;
                
                Player.Body.Velocity = Player.Body.Velocity with
                {
                    X = finalDirection.X,
                    Z = finalDirection.Z
                };
            }
        }
        else
        {
            Player.Body.Velocity = Player.Body.Velocity with
            {
                X = Mathf.MoveToward(Player.Body.Velocity.X, 0, CurrentSpeed),  
                Z = Mathf.MoveToward(Player.Body.Velocity.Z, 0, CurrentSpeed)
            };
        }
        
        // IsFeetMoving
        Player.IsFeetMoving = (Player.PlayerState is not (PlayerState.LimitedViewOnly or PlayerState.Locked)) &&
                              (Player.Body.IsOnFloor()) && 
                              (actualVelocity.LengthSquared() > 0.5) &&
                              (!_direction.IsZeroApprox());
        
        // GD.PrintRich($@"[b]A:{Player.PlayerState is not (PlayerState.LimitedViewOnly or PlayerState.Locked)}[b]B:{(Player.Body.IsOnFloor())}[b]C:{(Player.Body.Velocity.LengthSquared() > 0.5)}[b]D:{(!_direction.IsZeroApprox())}");
        Player.Body.MoveAndSlide();
    }
}