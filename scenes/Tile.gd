extends Area3D

class_name Tile

var selected_material = preload("res://resources/materials/TileSelected.tres")
var highlighted_material = preload("res://resources/materials/TileHighlight.tres")

var board_pos: Vector2

func tile_selected():
	$Mesh.material_override = selected_material
	show()

func tile_highlighted():
	$Mesh.material_override = highlighted_material
	show()
