extends "res://scenes/ChessPiece.gd"


func regular_movements(board):
	var available_movements = []
	for dir in [Vector2(1, 2), Vector2(-1, 2), Vector2(2, 1), Vector2(2, -1), 
				Vector2(1, -2), Vector2(-1, -2), Vector2(-2, 1), Vector2(-2, -1)]:
		var dest = board_pos + dir
		if board.can_move_here(self, dest):
			available_movements.append(dest)
	
	return available_movements
