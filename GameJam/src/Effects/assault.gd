extends Area2D

const speed = 400
var velocity = Vector2()

onready var assault = $aAssault


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _physics_process(delta: float) -> void:
	velocity.x = speed * delta
	assault.play("shoot")
	translate(velocity)
	


func _on_vn_screen_exited() -> void:
	queue_free()
