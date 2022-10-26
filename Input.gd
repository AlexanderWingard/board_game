extends Node

var clicked = null
var touch_events = {}
var first_touch = false
var selected = null
var rotating = false
var old_mouse_offset = Vector2.ZERO
var fake_mouse_pos = Vector2.ZERO
var inital_position = Vector3.ZERO
var last_drag_distance = 0
var zoom_sensitivity = 5
onready var cursor = $"../Cursor"
onready var cursor_2d = $"../ColorRect"
onready var camera = $"../CameraRig/Camera"
onready var camera_rig = $"../CameraRig"
var sensitivity = 0.005

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.pressed:
				pass
			else:
				pass
		elif event.button_index == BUTTON_WHEEL_UP:
			camera.translation -= Vector3(0,0,0.2)
		elif event.button_index == BUTTON_WHEEL_DOWN:
			camera.translation += Vector3(0,0,0.2)
	elif event is InputEventMouseMotion:
		return
#		relative = event.relative
	elif event is InputEventScreenDrag:
		update_event(event.index, event.position)
	elif event is InputEventScreenTouch:
			if event.pressed:
				update_event(event.index, event.position)
			else:
				touch_events.erase(event.index)

func update_event(index, position):
	if touch_events.has(index):
		touch_events[index].position = position
	else:
		touch_events[index] = {"position": position, "last_position": position}

func _physics_process(delta):
	var events = touch_events.values()
	var event_count = touch_events.size()
	if event_count > 0 and not first_touch:
		first_touch = true
		var hit = ray_cast_hit(events[0].position, 0b10)
		if hit: # Empty dict
			$"../Highlighter".monitoring = true
			selected = hit.collider.owner
			inital_position = selected.global_translation
			fake_mouse_pos = camera.unproject_position(selected.global_translation)
			old_mouse_offset = get_viewport().get_mouse_position() - fake_mouse_pos
			cursor.global_translation = hit.position
#				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	elif event_count > 0 and selected:
		var event = events[0]
		fake_mouse_pos += event.position - event.last_position
		event.last_position = event.position
		var ground_plane = Plane(Vector3.UP, 0)
		var from = camera.project_ray_origin(fake_mouse_pos)
		var to = from + camera.project_ray_normal(fake_mouse_pos) * 1000
		var cursor_pos = ground_plane.intersects_ray(from, to)
		if cursor_pos:
			cursor_pos.y = clamp(inital_position.distance_to(cursor_pos) / 4.0, 0, 0.4)
			selected.global_translation = cursor_pos
			$"../Highlighter".global_translation = cursor_pos
	elif event_count == 0:
		if selected != null:
			$"../Highlighter".monitoring = false
			if active_square:
				var tween = create_tween()
				tween.tween_property(selected, "global_translation", active_square.get_parent().global_translation, 0.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			Input.warp_mouse_position(fake_mouse_pos + old_mouse_offset)
		selected = null
		first_touch = null

	if event_count > 2 and selected:
		touch_zoom(events[1], events[2])
	elif event_count > 1 and not selected:
		touch_zoom(events[0], events[1])
	elif event_count > 1 and selected:
		rotate_camera(events[1])
	elif event_count > 0 and not selected:
		rotate_camera(events[0])

	cursor_2d.rect_global_position = fake_mouse_pos

func ray_cast_hit(position, mask):
	var ray_length = 1000
	var ray_start = camera.project_ray_origin(position)
	var ray_end = ray_start + camera.project_ray_normal(position) * ray_length
	var space_state = camera.get_world().direct_space_state
	return space_state.intersect_ray(ray_start, ray_end, [], mask, false, true)

func touch_zoom(event_1, event_2):
	var drag_distance = event_1.position.distance_to(event_2.position)
	if abs(drag_distance - last_drag_distance) > zoom_sensitivity:
		if drag_distance < last_drag_distance:
			camera.translation += Vector3(0,0,0.5)
		else:
			camera.translation -= Vector3(0,0,0.5)
	last_drag_distance = drag_distance
	event_1.last_position = event_1.position
	event_2.last_position = event_2.position

func rotate_camera(event):
	var relative = event.position - event.last_position
	event.last_position = event.position
	camera_rig.rotation.y -= relative.x * sensitivity
	camera_rig.rotation.x -= relative.y * sensitivity
	camera_rig.rotation.x = clamp(camera_rig.rotation.x, -PI/2.0, PI/2.0)

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
