extends MeshInstance3D

class_name ChessBoard

const TILE_LENGTH = 0.06
const INITIAL_CORNER = Vector3(-3.5, 0, -3.5) * TILE_LENGTH

var tile_scene = preload("res://scenes/Tile.tscn")
var pawn_scene = preload("res://scenes/Pawn.tscn")
var bishop_scene = preload("res://scenes/Bishop.tscn")
var knight_scene = preload("res://scenes/Knight.tscn")
var rook_scene = preload("res://scenes/Rook.tscn")
var queen_scene = preload("res://scenes/Queen.tscn")
var king_scene = preload("res://scenes/King.tscn")

signal new_turn
signal check

var initial_positions=[
	{
		"type": pawn_scene,
		"is_white": true,
		"positions": [Vector2(0, 1), Vector2(1, 1), Vector2(2, 1), Vector2(3, 1), Vector2(4, 1), Vector2(5, 1), Vector2(6, 1), Vector2(7, 1)]
	},
	{
		"type": pawn_scene,
		"is_white": false,
		"positions": [Vector2(0, 6), Vector2(1, 6), Vector2(2, 6), Vector2(3, 6), Vector2(4, 6), Vector2(5, 6), Vector2(6, 6), Vector2(7, 6)]
	},
	{
		"type": bishop_scene,
		"is_white": true,
		"positions": [Vector2(2, 0), Vector2(5, 0)]
	},
	{
		"type": bishop_scene,
		"is_white": false,
		"positions": [Vector2(2, 7), Vector2(5, 7)]
	},
	{
		"type": knight_scene,
		"is_white": true,
		"positions": [Vector2(1, 0), Vector2(6, 0)]
	},
	{
		"type": knight_scene,
		"is_white": false,
		"positions": [Vector2(1, 7), Vector2(6, 7)]
	},
	{
		"type": rook_scene,
		"is_white": true,
		"positions": [Vector2(0, 0), Vector2(7, 0)]
	},
	{
		"type": rook_scene,
		"is_white": false,
		"positions": [Vector2(0, 7), Vector2(7, 7)]
	},
	{
		"type": queen_scene,
		"is_white": true,
		"positions": [Vector2(4, 0)]
	},
	{
		"type": queen_scene,
		"is_white": false,
		"positions": [Vector2(4, 7)]
	},
	{
		"type": king_scene,
		"is_white": true,
		"positions": [Vector2(3, 0)]
	},
	{
		"type": king_scene,
		"is_white": false,
		"positions": [Vector2(3, 7)]
	}
]

var pieces_positions = {}
var tiles_cache = {}

func _ready():
	for i in range(0, 8):
		for j in range(0, 8):
			spawn_tile(Vector2(i,j))
	for piece_data in initial_positions:
		for pos in piece_data["positions"]:
			spawn_piece(piece_data["type"].instantiate(), pos, piece_data["is_white"])
	
	start_turn(true)


func real_board_position(board_pos: Vector2):
	return INITIAL_CORNER + TILE_LENGTH * Vector3(board_pos.x, 0, board_pos.y)

func spawn_piece(piece: ChessPiece, board_pos: Vector2, is_white: bool):
	piece.board_pos = board_pos
	piece.set_as_white_piece(is_white)
	piece.position = real_board_position(piece.board_pos)
	pieces_positions[piece.board_pos] = piece
	piece.input_event.connect(clicked_on_piece.bind(piece))
	$Pieces.add_child(piece)

func spawn_tile(board_pos: Vector2):
	var tile: Tile = tile_scene.instantiate()
	tile.add_to_group("tiles")
	tile.board_pos = board_pos
	tile.position = real_board_position(board_pos)
	tiles_cache[board_pos] = tile
	tile.input_event.connect(clicked_on_tile.bind(tile))
	tile.hide()
	$Tiles.add_child(tile)

func show_available_movements(piece: ChessPiece):
	var possible_movements = piece.regular_movements(self)
	for pos in possible_movements:
		tiles_cache[pos].tile_highlighted()

func hide_tiles(piece: ChessPiece):
	var possible_movements = piece.regular_movements(self)
	for pos in possible_movements:
		tiles_cache[pos].hide()

func start_turn(is_whites_turn: bool):
	GameState.is_whites_turn = is_whites_turn
	emit_signal("new_turn")
	enter_overview_mode()

func enter_selection_mode(piece: ChessPiece):
	GameState.selected_piece = piece
	for p in get_tree().get_nodes_in_group(GameState.pieces_group(GameState.is_whites_turn)):
		p.mouse_entered.disconnect(show_available_movements.bind(piece))
		p.mouse_exited.disconnect(hide_tiles.bind(piece))
	tiles_cache[piece.board_pos].tile_selected()
	show_available_movements(piece)

func enter_overview_mode():
	get_tree().call_group("tiles", "hide")
	GameState.selected_piece = null
	for piece in get_tree().get_nodes_in_group(GameState.pieces_group(GameState.is_whites_turn)):
		piece.mouse_entered.connect(show_available_movements.bind(piece))
		piece.mouse_exited.connect(hide_tiles.bind(piece))

func move_piece(piece: ChessPiece, dest: Vector2):
	pieces_positions.erase(piece.board_pos)
	piece.position = real_board_position(dest)
	piece.board_pos = dest
	if pieces_positions.has(dest):
		var eaten_piece = pieces_positions[dest]
		eaten_piece.queue_free()
	pieces_positions[dest] = piece
	start_turn(not GameState.is_whites_turn)
	is_check()

func is_check():
	var opponent_pieces_movement = []
	for p in get_tree().get_nodes_in_group(GameState.pieces_group(not GameState.is_whites_turn)):
		opponent_pieces_movement += p.regular_movements(self)
	if GameState.get_king(GameState.is_whites_turn).board_pos in opponent_pieces_movement:
		emit_signal("check")

func clicked_on_piece(_camera, event, _click_position, _click_normal, _shape_idx, piece):
	if event is InputEventMouse and event is InputEventMouseButton and event.is_action_pressed("select"):
		if piece.is_white_piece != GameState.is_whites_turn:
			return
		if GameState.selected_piece == null:
			enter_selection_mode(piece)
		elif GameState.selected_piece == piece:
			enter_overview_mode()

func clicked_on_tile(_camera, event, _click_position, _click_normal, _shape_idx, tile: Tile):
	if event is InputEventMouse and event is InputEventMouseButton and event.is_action_pressed("select"):
		var piece = GameState.selected_piece
		if piece == null:
			return
		
		var tile_board_pos = tile.board_pos
		if tile_board_pos in piece.regular_movements(self):
			move_piece(piece, tile_board_pos)

func can_move_here(piece: ChessPiece, dest: Vector2):
	if dest.x >= 8 or dest.x < 0 or dest.y >= 8 or dest.y < 0:
		return false
	var dest_piece: ChessPiece = pieces_positions.get(dest, null)
	return dest_piece == null or dest_piece.is_white_piece != piece.is_white_piece

func is_there_piece_here(dest: Vector2):
	return (pieces_positions.get(dest, null) != null)

func forward_dir(is_white):
	if is_white:
		return 1
	else:
		return -1
