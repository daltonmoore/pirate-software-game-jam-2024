class_name Enemy
extends CharacterBody2D

enum State {
	WALKING,
	DEAD
}

const WALK_SPEED = 40.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
@onready var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var floor_detector_left := $FloorDetectorLeft as RayCast2D
@onready var floor_detector_right := $FloorDetectorRight as RayCast2D
@onready var sprite := $Sprite2D as Sprite2D
@onready var animation_player := $AnimationPlayer as AnimationPlayer

var lastVelocity := 0
func _physics_process(delta: float) -> void:
	# Add the gravity.
	velocity.y += gravity * delta
	
	if not floor_detector_left.is_colliding():
		velocity.x = WALK_SPEED
	elif not floor_detector_right.is_colliding():
		velocity.x = -WALK_SPEED
	
	if lastVelocity != velocity.x:
		print("Last Velocity = {lv}. New Velocity = {nv}".format({"lv": lastVelocity, "nv": velocity.x}))
		lastVelocity = velocity.x
	move_and_slide()
