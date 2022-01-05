extends Area3D

class_name ChessPiece

var whites_material: Material = preload("res://resources/models/chess-set/exports/materials/WhitePieces.tres")
var blacks_material: Material = preload("res://resources/models/chess-set/exports/materials/BlackPieces.tres")

var is_white_piece: bool = true
var is_king: bool = false
var board_pos: Vector2 = Vector2(0, 0)

func set_as_white_piece(is_white: bool) -> void:
	add_to_group("pieces")
	is_white_piece = is_white
	if is_white_piece:
		add_to_group("white_pieces")
		$Mesh.set_surface_override_material(0, whites_material)
	else:
		add_to_group("black_pieces")
		$Mesh.set_surface_override_material(0, blacks_material)


func regular_movements(_board):
	return []
