extends Camera2D

@export var cam_speed: float = 1000

func _ready() -> void:
	make_current()
	
func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("cam_left"):
		position.x -= cam_speed * delta
	if Input.is_action_pressed("cam_right"):
		position.x += cam_speed * delta
	if Input.is_action_pressed("cam_up"):
		position.y -= cam_speed * delta
	if Input.is_action_pressed("cam_down"):
		position.y += cam_speed * delta
