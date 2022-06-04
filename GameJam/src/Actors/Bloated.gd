extends Actor

var hit = false
var attacking = false
var dashAtk = false
var attackCount = 0

onready var player = $"../Player"
onready var posEnemy = $Position2D
onready var animBloater = $aMain
onready var rayCaster = $aMain/RayCast2D

var collider_name = null
var get_last_collider = null
var current_direction : int = 2

var suppress = 0

func _physics_process(delta: float) -> void:
	
	var dash = Input.is_action_just_pressed("dash")
	
	var direction = player.position.x - position.x
	
	if collider_name == "player":
		suppress += 1
		stop(suppress)
		
		
	
	if attacking == false: 
		if direction < 0:
			current_direction = 2
			animBloater.scale.x = current_direction
		else:
			current_direction = -2
			animBloater.scale.x = current_direction
	
	if rayCaster.is_colliding():
		collider_name = rayCaster.get_collider().name
	else:
		pass	
		
	if collider_name != null && collider_name == "Player":
		animBloater.play("Attack")
		attacking = true
		$attack.start()
		if animBloater.frame == 5:
			attacking = false
			collider_name = null
	else:
		if dashAtk == false:
			animBloater.play("Idle")
	
	if(animBloater.get_animation() == "Idle"):
		suppress += 1
		search_and_destroy(suppress)
	
	if attackCount == 3 and attacking == false:
			$attack.stop()
			dashAtk = true
			attackCount = 0
	if dashAtk == true and is_on_floor():
		dashAtk = false
		attacking = true
		animBloater.play("Dash")
		$charge.start()
	
	if attacking and collider_name == "TileMap"  :
		 attacking = false
	_velocity.y += delta * gravity
	move_and_slide(_velocity, Vector2(0, -1))
	
	
	
func _on_attack_timeout():
	attackCount +=1

func _on_charge_timeout():
	_velocity.x = 300 * (current_direction * -1)

func _on_search_timeout():
	dashAtk = true
	suppress = 0
	
func search_and_destroy(count: int):
	if count == 1:
		$search.start()
func stop(count: int):
	if count >= 1:
		_velocity.x = 0
	


