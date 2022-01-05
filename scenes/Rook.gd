extends "res://scenes/ChessPiece.gd"


func regular_movements(board):
	var available_movements = []
	for dir in [Vector2(1, 0), Vector2(-1, 0), Vector2(0, 1), Vector2(0, -1)]:
		for length in range(1, 8):
			var dest = board_pos + dir*length
			if not board.can_move_here(self, dest):
				break
			available_movements.append(dest)
			if board.pieces_positions.get(dest, null) != null:
				break
	
	return available_movements
