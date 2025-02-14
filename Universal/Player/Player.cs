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

public partial class Player : CharacterBody3D
{
	[Export] public PlayerState State
	{
		get => _state;
		set => SetState(value);
	}
	private PlayerState _state = PlayerState.Normal;
	
	[ExportGroup("Subsystems")] 
	[Export] private PlayerLook _look;
	[Export] private PlayerMove _move;

	[ExportGroup("Universal References")] 
	[Export] public Node3D Neck;
	[Export] public Node3D Head;
	[Export] public Camera3D Camera;
	
	[ExportSubgroup("Easing")]
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


	public void InSqueeze()
	{
		_move.IsSqueezing = true;
	}
	
	// Change player state
	private void SetState(PlayerState value)
	{
		_state = value;
		
	}
	
}
