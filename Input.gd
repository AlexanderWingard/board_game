extends Node

onready var rc = $"../RayCast"
var fake_mouse_pos = Vector2.ZERO

func _physics_process(delta):
	var ground_plane = Plane(Vector3.UP, 0)
	var from = $"../Camera".project_ray_origin(fake_mouse_pos)
	var to = from + $"../Camera".project_ray_normal(fake_mouse_pos) * 1000
	var cursor_pos = ground_plane.intersects_ray(from, to)
	if pressed:
		$"../Pawn".global_translation = cursor_pos
		$"../ColorRect".rect_position = fake_mouse_pos

var pressed = false
var old_mouse_offset = Vector2.ZERO
func _input(event):
	if event is InputEventMouseMotion:
		if pressed:
			fake_mouse_pos += event.relative
	elif event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		if not event.pressed:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			if pressed:
				Input.warp_mouse_position(fake_mouse_pos + old_mouse_offset)
			pressed = false

func _on_Area_input_event(camera, event, position, normal, shape_idx):
	if event is InputEventMouseButton:
		pressed = event.pressed
		if not event.pressed:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			fake_mouse_pos = get_viewport().get_camera().unproject_position($"../Pawn".global_transform.origin)
			old_mouse_offset = get_viewport().get_mouse_position() - fake_mouse_pos
