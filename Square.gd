extends Spatial

var color

# Called when the node enters the scene tree for the first time.
func init():
	$"MeshInstance".set_surface_material(0, color)

func highlight(active):
	$"MeshInstance".set_surface_material(0, (preload("res://Highlight.material") if active else color))

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
