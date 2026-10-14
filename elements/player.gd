extends CharacterBody2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

const SPEED = 150.0
func _ready() -> void:
	sprite.play("default")


func _physics_process(delta: float) -> void:
	var direction :=Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = direction * SPEED
	move_and_slide()
	
	if direction.x > 0:
		sprite.flip_h = false
	elif direction.x < 0:
		sprite.flip_h = true
		
