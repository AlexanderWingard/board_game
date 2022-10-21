extends Spatial

func _ready():
	var white_material = preload("res://White.material")
	var black_material = preload("res://Black.material")
	for x in 8:
		for y in 8:
			var square = preload("res://Square.tscn").instance()
			add_child(square)
			square.transform.origin = Vector3(-3.5 + x, 0, -3.5 + y)
			square.name = str("square_", x, "_", y)
			if (x + y) % 2 == 0:
				square.get_node("MeshInstance").set_surface_material(0, white_material)
			else:
				square.get_node("MeshInstance").set_surface_material(0, black_material)
