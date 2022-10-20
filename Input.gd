extends Node

func _physics_process(delta):
	var ground_plane = Plane(Vector3.UP, 0)
	var mouse_pos = get_viewport().get_mouse_position()
	var from = $"../Camera".project_ray_origin(mouse_pos)
	var to = from + $"../Camera".project_ray_normal(mouse_pos) * 1000
	var cursor_pos = ground_plane.intersects_ray(from, to)
	if grabbed:
		$"../Pawn".global_translation = $"../Cursor/Grab".global_translation

	if not cursor_pos:
		return
	$"../Cursor".global_transform.origin = cursor_pos

var grabbed = false
func _input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		if not event.pressed:
			grabbed = false
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _on_Area_input_event(camera, event, position, normal, shape_idx):
	if event is InputEventMouseButton:
		grabbed = event.pressed
		if event.pressed:
			var grab_point = $"../Pawn".global_transform.origin
			$"../Cursor/Grab".global_transform.origin = grab_point
