extends Camera2D

@export var cam_speed: float = 1
@export var cam_lag = 1
var velocity: Vector2

func _ready() -> void:
	make_current()
	
func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("cam_left"):
		velocity.x = -cam_speed * delta * 100000
	if Input.is_action_pressed("cam_right"):
		velocity.x = cam_speed * delta * 100000
	if Input.is_action_pressed("cam_up"):
		velocity.y = -cam_speed * delta * 100000
	if Input.is_action_pressed("cam_down"):
		velocity.y = cam_speed * delta * 100000
	else:
		velocity.x = move_toward(velocity.x, 0, cam_lag * delta * 10000)
		velocity.y = move_toward(velocity.y, 0, cam_lag * delta * 10000)

	position += velocity * delta
