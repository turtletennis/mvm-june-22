extends Actor

var hit = false
onready var posEnemy = $Position2D
onready var animBrawler = $Position2D/animBrawler
func _ready() -> void:
	set_physics_process(false)
	posEnemy.scale.x = -1
	#_velocity.x = -speed.x
func _physics_process(delta: float) -> void:
	if is_on_wall():
		_velocity.y += gravity * delta 
		_velocity.x *= -1
	
	if hit == true:
		animBrawler.play("hit")
	else:
		animBrawler.play("idle")
	
	if _velocity.x==0 and not hit:
		animBrawler.play("idle")
	else:
		#animBrawler.play("move")
		pass
	if _velocity.x < 0:
		#animBrawler.scale.x = -3
		pass
	else:
		#animBrawler.scale.x = 3
		pass
	_velocity.y = move_and_slide(_velocity, FLOOR_NORMAL).y


func _on_areaBody_area_entered(area: Area2D) -> void:
	hit = true
	print(hit)


func _on_areaBody_area_exited(area: Area2D) -> void:
	hit = false
	print(hit)
