extends Spatial

func _ready():
	var white_material = preload("res://White.material")
	var black_material = preload("res://Black.material")
	for x in 8:
		for y in 8:
			var square = preload("res://Square.tscn").instance()
			add_child(square)
			square.transform.origin = Vector3(-3.5 + x, 0, -3.5 + y)
			if x == 1 or x == 6:
				create_pawn(square.transform.origin, white_material if x == 1 else black_material)
			square.name = str("square_", x, "_", y)
			if (x + y) % 2 == 0:
				square.color = white_material
			else:
				square.color = black_material
			square.init()

func create_pawn(pos, material):
	var pawn = preload("res://Models/Pawn.tscn").instance()
	add_child(pawn)
	pawn.get_node("Area").connect("input_event", $"Input", "_on_Area_input_event", [pawn])
	pawn.get_node("Sphere").set_surface_material(0, material)
	pawn.global_translation = pos
