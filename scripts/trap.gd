extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous Sframe.
func _process(delta: float) -> void:
	pass


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		var player := body as Player
		DebugDraw2d.arrow(position, player.position, Color(1, 0, 1), 1, 0.5)
		player.receive_damage(player.position-position)
	pass # Replace with function body.
