extends Actor

#mechanics
var idle = true
var jumping = false
var attacking = false
var shooting = false
var dashing = false
var walking =  false
var charging = false
var morph = false
var morphA= false
var morphD = false

var jumpcount = 0
#override
var dash_on = false

const RAPID = preload("res://src/Effects/assault.tscn")
const ROCKET = preload("res://src/Effects/rocket.tscn")


var dash = 0
var getLastDir = Vector2(0, 0)

onready var animWoodCutter = $animWoodCutter
onready var cyberDude = $cyberDude
onready var biker = $biker

onready var attack = $animWoodCutter/Area2D/areaAttack
onready var dashInit = $dashInit
onready var dashRelay = $dashRelay

onready var curSprite: AnimatedSprite = animWoodCutter

func _physics_process(delta: float) -> void:
	# start custom
	var right = Input.is_action_pressed("move_right")
	var rightR = Input.is_action_just_released("move_right")
	var left = Input.is_action_pressed("move_left")
	var leftR = Input.is_action_just_released("move_left")
	var shift = Input.is_action_just_pressed("shift")
	var shiftA = Input.is_action_just_pressed("shiftA")
	var shiftD = Input.is_action_just_pressed("shiftD")
	var shoot = Input.is_action_just_pressed("shoot")
	
	if right and charging == false:
		charging = true
		dashTimer()
		dashRelayOn()
	elif rightR  and charging == true:
		charging = false
		dashCount(dashInit.time_left)
		dashTimerOff()
		getLastDir.x = 1
	else:
		pass
	
	if left and charging == false:
		charging = true
		dashTimer()
		dashRelayOn()
	elif leftR  and charging == true:
		charging = false
		dashCount(dashInit.time_left)
		dashTimerOff()
		getLastDir.x = -1
	else:
		pass
	#end custom
	
	if Input.is_action_just_pressed("attack") and is_on_floor():
		attacking = true
	if shoot:
		shoot = true
		var rBullet = ROCKET.instance()
		get_parent().add_child(rBullet)
		rBullet.position = $animWoodCutter/Position2D.global_position
	
	if attacking == true and animWoodCutter.frame >= 3:
		attack.disabled = false
		
	else:
		attack.disabled = true
	
	var is_jump_interrupted = Input.is_action_just_released("jump") and _velocity.y < 0.0
	var direction: = get_direction()
	var animation = get_new_animation(attacking)
	
	if shift and $cyberDude.is_playing() == false:
		morph = true
	elif shiftA and $animWoodCutter.is_playing() == false:
		morphA = true
	elif shiftD and $biker.is_playing() == false:
		morphD = true
	else:
		pass
	
	if Input.is_action_just_pressed("jump") and jumping == true and jumpcount < 2:
		direction.y = -1
		jumpcount += 1
	if is_on_floor():
		jumping = false
		jumpcount = 0
	
	if dash == 2 and dash_on == true:
		dashing = true
		#print("dashing")
		#dash = 0
	if dashing == true:
		_velocity.x = 600 * getLastDir.x
		direction.x = getLastDir.x
		speed = Vector2(600.0, 500.0)
	else:
		speed = Vector2(300.0, 500.0)
	
	if direction.x != 0 and not attacking:
		if direction.x > 0:
			curSprite.scale.x = 2
		else:
			curSprite.scale.x = -2
		
	
	#end custom
	curSprite.play(animation)
	if (attacking == false):
		_velocity = calculate_move_velocity(_velocity, direction, speed, is_jump_interrupted)
		_velocity = move_and_slide(_velocity, FLOOR_NORMAL)

func get_current_sprite(sprite: String) -> AnimatedSprite:
	var newSprite: AnimatedSprite = null
	if sprite == "cyber":
		newSprite = cyberDude
	elif sprite == "wood":
		newSprite = animWoodCutter
	elif sprite == "biker":
		newSprite = biker
	else:
		pass
	return newSprite

func get_direction() -> Vector2:
	 return Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"), 
		-1.0 if Input.is_action_just_pressed("jump") and is_on_floor()  else 1.0
	)
	
func dashCount(time_left: float) -> void:
	if time_left > 0.1:
		dash +=1
		
func calculate_move_velocity(
		linear_velocity: Vector2,
		direction: Vector2,
		speed: Vector2,
		is_jump_interrupted: bool
		) -> Vector2:
	var out = linear_velocity
	out.x = speed.x * direction.x
	out.y += gravity * get_physics_process_delta_time()
	if direction.y == -1.0:
		jumpcount += 1
		jumping  = true
		out.y = speed.y * direction.y
	if is_jump_interrupted:
		out.y = 0.0
	return out

func get_new_animation(is_shooting = false):
	var animation_new = ""
	if is_on_floor() and not dashing:
		if abs(_velocity.x) > 0.1:
			animation_new = "run"
			walking =  true
		else:
			animation_new = "idle"
			walking = false
	elif is_on_floor() and dashing:
		animation_new = "dash"
	else:
		if _velocity.y > 0:
			animation_new = "falling"
		else:
			animation_new = "jumping"
	if jumping == true and jumpcount > 2:
		animation_new = "djump"

	if morph == true and not attacking:
		animation_new = "morph"
	if morphA == true:
		animation_new = "morph"
	elif morphD == true:
		animation_new = "morph"
	if attacking == true:
		animation_new = "attack"
	return animation_new
#timers
func dashTimer() -> void:
	dashInit.start()

func dashTimerOff() -> void:
	dashInit.stop()

func dashRelayOn() -> void:
	dashRelay.start()

func _on_animWoodCutter_animation_finished() -> void:
	attacking = false
	if morph:
		morph("cyber", cyberDude)
		morph = false
	elif morphD:
		morph("biker", biker)
		morphD= false
	else:
		pass

func _on_cyberDude_animation_finished() -> void:
	attacking = false
	if morphA:
		morph("wood", animWoodCutter)
		morphA = false
	elif morphD:
		morph("biker", biker)
		morphD = false
	else:
		pass

func _on_biker_animation_finished() -> void:
	attacking = false
	if morph:
		morph("cyber", cyberDude)
		morph = false
	elif morphA:
		morph("wood", animWoodCutter)
		morphA = false
	else:
		pass
	
func morph(sprite: String, spriteNode: AnimatedSprite) -> void:
	spriteNode.scale.x = curSprite.scale.x
	curSprite.visible = false
	curSprite.stop()
	print(curSprite)
	curSprite = get_current_sprite(sprite)
	curSprite.visible = true
	curSprite.play("idle")
	print(curSprite)

func _on_dashInit_timeout() -> void:
	pass # Replace with function body.

func _on_dashRelay_timeout() -> void:
	dashing = false
	dash = 0




