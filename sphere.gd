extends Node3D

@onready var sphere_node = $MeshInstance3D

func _input(event):
	if event is InputEventMouseMotion:
		if event.button_mask & MOUSE_BUTTON_MASK_LEFT:
			sphere_node.rotate(Vector3.UP, event.relative.x * 0.005)
			sphere_node.rotate(Vector3.LEFT, -event.relative.y * 0.005)
