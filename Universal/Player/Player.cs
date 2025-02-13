using Godot;
using Pins.Universal.Player.CharController;

namespace Pins.Universal.Player;

public partial class Player : CharacterBody3D
{
	[ExportGroup("Subsystems")] 
	[Export] private PlayerLook _look;
	[Export] private PlayerMove _move;

	[ExportGroup("References")] 
	[Export] private Node3D _head;

	public override void _Ready()
	{
		// PlayerLook init
		_look.Head = _head;
		_look.Body = this;
		
		//PlayerMove init
		_move.Body = this;
	}
	
	
	public void InSqueeze()
	{
		_move.IsSqueezing = true;
	}
}