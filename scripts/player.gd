class_name Player
extends CharacterBody2D

enum State {
	IDLE,
	RUNNING,
	JUMPING,
	DOUBLE_JUMPING,
	WALL_JUMP,
	FALLING,
	HIT,
	DEAD,
}

@export var  WALK_FORCE := 1200
@export var  WALK_MAX_SPEED := 400
@export var STOP_FORCE := 1300
@export var JUMP_SPEED := 600

var _jump_count := 0
var _state : State = State.IDLE

@onready var gravity := ProjectSettings.get_setting("physics/2d/default_gravity") as float
@onready var animation_player := $AnimationPlayer as AnimationPlayer
@onready var sprite_2d := $Sprite2D as Sprite2D
@onready var collision_shape_2d := $CollisionShape2D as CollisionShape2D

func _ready() -> void:
	animation_player.play(Globals.ANIM_CONST_IDLE)


func _physics_process(delta: float) -> void:
	var move_direction : int = 0
	if Input.is_action_pressed(Globals.ACTION_CONST_MOVE_LEFT):
		move_direction = -1
	elif Input.is_action_pressed(Globals.ACTION_CONST_MOVE_RIGHT):
		move_direction = 1
	
	# Horizontal movement code. First, get the player's input.
	var walk := WALK_FORCE * (Input.get_axis(Globals.ACTION_CONST_MOVE_LEFT,
			Globals.ACTION_CONST_MOVE_RIGHT))
	
	# Slow down the player if they're not trying to move.
	if abs(walk) < WALK_FORCE * 0.2:
		# The velocity, slowed down a bit, and then reassigned.
		velocity.x = move_toward(velocity.x, 0, STOP_FORCE * delta)
	else:
		velocity.x += walk * delta
		if is_on_floor():
			if move_direction == -1:
				sprite_2d.flip_h = true
			elif move_direction == 1:
				sprite_2d.flip_h = false
		
	
	# Clamp to the maximum horizontal movement speed.
	velocity.x = clamp(velocity.x, -WALK_MAX_SPEED, WALK_MAX_SPEED)
	
	# Vertical movement code. Apply gravity
	velocity.y += gravity * delta
	
	move_and_slide()
	
	# Jump
	if is_on_floor():
		_jump_count = 0
		if abs(walk) < WALK_FORCE * 0.2:
			_state = State.IDLE
		else:
			_state = State.RUNNING		
	
		# Check for jumping. is_on_floor() must be called after movement code.
		if Input.is_action_just_pressed(Globals.ACTION_CONST_JUMP):
			velocity.y = -JUMP_SPEED
			_jump_count += 1
			_state = State.JUMPING
	# We're falling
	elif velocity.y > 0:
		_state = State.FALLING
	
	_debug_double_jump()
	
	# Check for Double jump
	if (!is_on_floor() and !is_on_wall() and
			_jump_count <= 1 and 
			Input.is_action_just_pressed(Globals.ACTION_CONST_JUMP)):
		#animation_player.play(Globals.ANIM_CONST_DOUBLE_JUMP)
		_state = State.DOUBLE_JUMPING
		velocity.y = -JUMP_SPEED
		_jump_count += 1
	
	_wall_jump()
	
	var animation := _get_new_animation()
	if animation != animation_player.current_animation:
		print("Getting new anim {a}".format({"a":animation}))
		animation_player.play(animation)
	
	# I don't know if I want this match to be here since I am already
	# checking the state in _get_new_animation()...
	match _state:
		State.HIT:
			pass
		State.IDLE:
			pass
		State.DEAD:
			pass
		State.RUNNING:
			pass
		_:
			pass
	


func receive_damage() -> void:
	velocity = Vector2.ZERO
	_state = State.HIT
	print("Receive damage")


func _wall_jump() -> void:
		# Check for Wall jump
	if is_on_wall():
		_state = State.WALL_JUMP
		velocity.y = 30
		
		var temp := position + JUMP_SPEED * get_wall_normal()
		temp.y = -JUMP_SPEED
		DebugDraw2d.arrow(position, temp)
		
		# Use wall normal to figure out which way to flip our sprite horizontal
		if is_equal_approx(get_wall_normal().angle(), 0.0):
			sprite_2d.flip_h = true
		elif is_equal_approx(get_wall_normal().angle(), PI):
			sprite_2d.flip_h = false
		
		if Input.is_action_just_pressed(Globals.ACTION_CONST_JUMP):
			# Need a vector away from wall and up
			# TODO: Probaly want to refactor the jump code into a func
			velocity = JUMP_SPEED * get_wall_normal()
			velocity.y = -JUMP_SPEED
			_state = State.JUMPING
			sprite_2d.flip_h = !sprite_2d.flip_h


func _get_new_animation() -> StringName:
	var animation_new: StringName
	match _state:
		State.HIT:
			animation_new = Globals.ANIM_CONST_HIT
		State.IDLE:
			animation_new = Globals.ANIM_CONST_IDLE
		State.RUNNING:
			animation_new = Globals.ANIM_CONST_RUN
		State.JUMPING:
			animation_new = Globals.ANIM_CONST_JUMP
		State.FALLING:
			animation_new = Globals.ANIM_CONST_FALL
		State.DOUBLE_JUMPING:
			animation_new = Globals.ANIM_CONST_DOUBLE_JUMP
		State.WALL_JUMP:
			animation_new = Globals.ANIM_CONST_WALL_JUMP
		_:
			animation_new = ""
			push_error("YO WTF")
	return animation_new


func _debug_double_jump() -> void:
	
	var did_double_jump := (!is_on_floor() and !is_on_wall() and
			_jump_count == 1 and 
			Input.is_action_just_pressed(Globals.ACTION_CONST_JUMP))
	if Input.is_action_just_pressed(Globals.ACTION_CONST_JUMP) and !is_on_floor():
		var format_string := "Did double jump? %s"
		print("--------------")
		print(format_string % did_double_jump)
		print("Jump count = {jc}".format({"jc": _jump_count}))
		print("")


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	#print("Finished "+anim_name)
	if anim_name == Globals.ANIM_CONST_DOUBLE_JUMP:
		#animation_player.play(Globals.ANIM_CONST_FALL)
		print()
	elif anim_name == Globals.ANIM_CONST_HIT:
		_state = State.IDLE


func _on_animation_player_animation_changed(old_name: StringName, new_name: StringName) -> void:
	#print("Animation changed from " + old_name + " to " + new_name)
	pass


func _on_animation_player_animation_started(anim_name: StringName) -> void:
	#print("Animation started " + anim_name)
	pass
	
	
	# TODO: AI and Navigation for the platforms would be cool
