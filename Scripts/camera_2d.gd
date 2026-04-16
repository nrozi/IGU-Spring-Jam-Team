extends Camera2D

@export var cam_speed: float = 1
@export var cam_lag: float = 1
@export var zoom_speed: float = 5
@export var zoom_lag: float = 20
var velocity: Vector2
var cam_velocity: Vector2

func _ready() -> void:
	make_current()
	
func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("cam_left"):
		velocity.x = -cam_speed * delta * 100000 / zoom.x
	if Input.is_action_pressed("cam_right"):
		velocity.x = cam_speed * delta * 100000 / zoom.x
	if Input.is_action_pressed("cam_up"):
		velocity.y = -cam_speed * delta * 100000 / zoom.x
	if Input.is_action_pressed("cam_down"):
		velocity.y = cam_speed * delta * 100000 / zoom.x
	else:
		velocity.x = move_toward(velocity.x, 0, cam_lag * delta * 10000)
		velocity.y = move_toward(velocity.y, 0, cam_lag * delta * 10000)

	if Input.is_action_pressed("cam_zoom_in"):
		cam_velocity = Vector2(zoom_speed, zoom_speed)
	if Input.is_action_pressed("cam_zoom_out"):
		cam_velocity = -Vector2(zoom_speed, zoom_speed)
	else:
		cam_velocity.x = move_toward(cam_velocity.x, 0, zoom_lag * delta)
		cam_velocity.y = move_toward(cam_velocity.y, 0, zoom_lag * delta)
		
	position += velocity * delta
	zoom += cam_velocity * delta
	
