extends CharacterBody2D

func _physics_process(delta: float) -> void:
	
	#handle gravity
	if !is_on_floor():
		velocity.y += get_gravity().y * delta
