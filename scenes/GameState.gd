extends Node

var is_whites_turn: bool = true
var selected_piece: ChessPiece = null


func pieces_group(for_whites: bool):
	var group
	if for_whites:
		group = "white_pieces"
	else:
		group = "black_pieces"
	
	return group

func is_king(piece):
	return piece.is_king

func get_king(for_whites: bool):
	
	return get_tree().get_nodes_in_group(pieces_group(for_whites)).filter(is_king).front()
