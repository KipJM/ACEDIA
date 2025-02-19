using Godot;
using Pins.Universal.Player;

namespace Pins.Testing.CharControllerTest;

public partial class VariableDebugText : RichTextLabel
{
	[Export]public Player Player;

	// Called every frame. 'delta' is the elapsed time since the previous frame.
	public override void _Process(double delta)
	{
		Text = $"is feet moving: {Player.IsFeetMoving}\nvelocity: {Player.Velocity.LengthSquared()}\n{Player.PlayerState is not (PlayerState.LimitedViewOnly or PlayerState.Locked)}\n{
		Player.Body.IsOnFloor()}\n{Player.Body.Velocity.LengthSquared() > 0.5}";
	}
}