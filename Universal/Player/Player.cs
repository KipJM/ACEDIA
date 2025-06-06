using Godot;
using NathanHoad;
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
	
	[Export] public bool IsInteractionHovering;

	[ExportGroup("Level Settings")] 
	[Export] public Material PlayerMaterial;
	
	[ExportGroup("Subsystems")] 
	[Export] public PlayerLook Look;
	[Export] private PlayerMove _move;
	[Export] public PlayerAnimator Animator;
	[Export] private PlayerInteraction _interaction;

	[ExportGroup("References")] 
	[Export] public MeshInstance3D PlayerMesh;
	[Export] public Node3D AnimatedHead;
	[Export] public Node3D Neck;
	[Export] public Node3D Head;
	[Export] public Node3D Eyes;
	[Export] public Camera3D Camera;
	
	[ExportGroup("Easing")]
	[Export] public float LerpSpeed = 10.0f;
	
	public CharacterBody3D Body;

	[Signal]
	public delegate void InteractionStartEventHandler();
	
	public override void _Ready()
	{
		Camera.MakeCurrent();
		Body = this;
		
		// PlayerLook init
		Look.Player = this;
		
		//PlayerMove init
		_move.Player = this;
		
		_interaction.Player = this;
		Animator.Player = this;
		
		// Set Player Material
		if (PlayerMaterial != null)
		{
			PlayerMesh.SetSurfaceOverrideMaterial(0, PlayerMaterial);
		}
	}

	public void OnStartSqueeze()
	{
		GD.Print($"RUM: {InputHelper.LastKnownJoypadIndex}");
		InputHelper.StartRumbleSmall(int.Parse(InputHelper.LastKnownJoypadIndex));
		MovementState = MovementState.Squeezing;
	}

	public void OnEndSqueeze()
	{
		InputHelper.StopRumble(int.Parse(InputHelper.LastKnownJoypadIndex));
		MovementState = MovementState.Walking;
	}
}
