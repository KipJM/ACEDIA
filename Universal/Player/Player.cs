using Godot;
using Pins.Universal.Player.CharController;

namespace Pins.Universal.Player;


public enum PlayerState
{
	Normal, // Full control
	ForwardOnly, // Only allows moving forward
	LimitedViewOnly, // Only allows rotating view (limited)
	Locked // Fully locked
}

public enum MovementState
{
	Walking,
	Sprinting,
	Squeezing
}

public partial class Player : CharacterBody3D
{
	[Export] public PlayerState PlayerState;
	[Export] public MovementState MovementState;
	[Export] public bool IsFeetMoving;
	
	[ExportGroup("Subsystems")] 
	[Export] private PlayerLook _look;
	[Export] private PlayerMove _move;

	[ExportGroup("References")] 
	[Export] public Node3D Neck;
	[Export] public Node3D Head;
	[Export] public Node3D Eyes;
	[Export] public Camera3D Camera;
	
	[ExportGroup("Easing")]
	[Export] public float LerpSpeed = 10.0f;

	public CharacterBody3D Body;

	public override void _Ready()
	{
		Body = this;
		
		// PlayerLook init
		_look.Player = this;
		
		//PlayerMove init
		_move.Player = this;
		
		Input.SetMouseMode(Input.MouseModeEnum.Captured);
	}

	public override void _Input(InputEvent @event)
	{
		if (Input.IsActionJustPressed("pause"))
		{
			Input.SetMouseMode(Input.MouseMode == Input.MouseModeEnum.Captured ? Input.MouseModeEnum.Visible : Input.MouseModeEnum.Captured);
		}
	}
	
	public void OnStartSqueeze()
	{
		MovementState = MovementState.Squeezing;
	}

	public void OnEndSqueeze()
	{
		MovementState = MovementState.Walking;
	}
	
}
