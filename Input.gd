extends Node

onready var camera = $"../CameraRig/Camera"
onready var camera_rig = $"../CameraRig"
var fake_mouse_pos = Vector2.ZERO
var initial_position = Vector3.ZERO
var sensitivity = 0.005
var picked = null

func _physics_process(delta):
	if picked:
		var ground_plane = Plane(Vector3.UP, 0)
		var from = camera.project_ray_origin(fake_mouse_pos)
		var to = from + camera.project_ray_normal(fake_mouse_pos) * 1000
		var cursor_pos = ground_plane.intersects_ray(from, to)
		if cursor_pos:
			cursor_pos.y = clamp(initial_position.distance_to(cursor_pos) / 4.0, 0, 0.4)
			picked.global_translation = cursor_pos
			$"../ColorRect".rect_position = fake_mouse_pos
			$"../Highlighter".global_translation = cursor_pos

var rotating = false
var old_mouse_offset = Vector2.ZERO

func _input(event):
	if event is InputEventMouseMotion:
		if picked:
			fake_mouse_pos += event.relative
		elif rotating:
			camera_rig.rotation.y -= event.relative.x*sensitivity
			camera_rig.rotation.x -= event.relative.y*sensitivity
			camera_rig.rotation.x = clamp(camera_rig.rotation.x,-PI/2.0,PI/2.0)
	elif event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		rotating = event.pressed
		if not event.pressed:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			if picked:
				Input.warp_mouse_position(fake_mouse_pos + old_mouse_offset)
				if active_square:
					var tween = create_tween()
					tween.tween_property(picked, "global_translation", active_square.get_parent().global_translation, 0.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
			picked = null
			$"../Highlighter".monitoring = false


func _on_Area_input_event(camera, event, position, normal, shape_idx, node):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		$"../Highlighter".monitoring = event.pressed
		if event.pressed:
			picked = node
			rotating = false
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			initial_position = node.global_transform.origin
			fake_mouse_pos = camera.unproject_position(initial_position)
			old_mouse_offset = get_viewport().get_mouse_position() - fake_mouse_pos
		else:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


var active_square
func _on_Highlighter_area_entered(area):
	active_square = area
	toggle_highlight(area, true)

func _on_Highlighter_area_exited(area):
	toggle_highlight(area, false)

func toggle_highlight(area, active):
	var n = area.get_node_or_null("..")
	if n != null:
		n.highlight(active)
