extends Actor

var hit = false
var attacking = false
onready var posEnemy = $Position2D
onready var animBloater = $aMain
onready var rayCaster = $aMain/RayCast2D

var collider_name = null
var get_last_collider = null

func _physics_process(delta: float) -> void:
	var dash = Input.is_action_just_pressed("dash")
	
	if rayCaster.is_colliding():
		collider_name = rayCaster.get_collider().name
#		if collider_name == "Player":
#			#attacking = true
#			animBloater.play("Attack")
	else:
		pass	
	
	if collider_name != null && collider_name == "Player":
		animBloater.play("Attack")
		print(animBloater.frame)
		if animBloater.frame == 5:
			collider_name = null
	else:
		animBloater.play("Idle")
		
	if dash and is_on_floor():
		_velocity.x = 600 * -1
		#direction.x = getLastDir.x
		#speed = Vector2(600.0, 5

	
	_velocity.y += delta * gravity
	move_and_slide(_velocity, Vector2(0, -1))
	




