extends "res://scenes/ChessPiece.gd"


func regular_movements(board):
	var available_movements = []
	var dir = board.forward_dir(is_white_piece)
	for move in [Vector2(-1, 1*dir), Vector2(1, 1*dir)]:
		var dest = board_pos + move
		if board.can_move_here(self, dest) and board.is_there_piece_here(dest):
			available_movements.append(dest)
	var forward_dest = board_pos + Vector2(0, 1*dir)
	if not board.is_there_piece_here(forward_dest):
		available_movements.append(forward_dest)
	
	if board_pos.y == 1 or board_pos.y == 6:
		var superforward_dest = board_pos + Vector2(0, 2*dir)
		if not board.is_there_piece_here(superforward_dest):
			available_movements.append(superforward_dest)
	
	return available_movements
