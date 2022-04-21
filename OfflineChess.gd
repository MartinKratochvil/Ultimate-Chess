extends Node2D

#bool
var select
var drop
export var white = true

#variable
var line
var area
var num

#array
var options
var moved
var check
var king
var direction
var pos = [0, 0]

func _ready():
	_restart()

func _process(delta):
	if select:
		if drop:
			$Piece.global_position = lerp($Piece.global_position, get_node("Line" + str(options[num][0]) + "/Area" + str(options[num][1])).global_position, 15 * delta)
			if ($Piece.global_position.distance_squared_to(get_node("Line" + str(options[num][0]) + "/Area" + str(options[num][1])).global_position)) < 1:
				var piece = "Line" + str(line) + "/Area" + str(area) + "/Piece"
				var position = "Line" + str(options[num][0]) + "/Area" + str(options[num][1]) + "/Piece"
				if get_node(position).animation != get_node(piece).animation or get_node(position).frame != get_node(piece).frame:
					if get_node(piece).animation == "King":
						king[int(!white)] = options[num]
					get_node(position).animation = get_node(piece).animation
					get_node(position).frame = get_node(piece).frame
					get_node(piece).animation = "Empty"
					check[int(!white)] = false
					get_node("Line" + str(king[int(!white)][0]) + "/Area" + str(king[int(!white)][1]) + "/Overlay").frame = 0
					white = !white
					if _check(king[int(!white)][0], king[int(!white)][1], false):
						check[int(!white)] = true
						get_node("Line" + str(king[int(!white)][0]) + "/Area" + str(king[int(!white)][1]) + "/Overlay").frame = 1
				_drop()
		else:
			$Piece.global_position = lerp($Piece.global_position, get_global_mouse_position(), 25 * delta)

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and not event.pressed:
			if select:
				for i in options.size():
					if get_node("Line" + str(options[i][0]) + "/Area" + str(options[i][1])).global_position.distance_to(get_global_mouse_position()) < get_global_transform().get_scale().x * 32:
						num = i
						drop = true
						break
				if !drop:
					_drop()
				print(options)

func _on_Area_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			for i in 8:
				for j in 8:
					var piece = "Line" + str(i + 1) + "/Area" + str(j + 1) + "/Piece"
					if get_node(piece).global_position.distance_to(get_global_mouse_position()) < get_global_transform().get_scale().x * 32 and get_node(piece).animation != "Empty":
						line = i + 1
						area = j + 1
						_drag()

func _restart():
	for i in 2:
		get_node("Line" + str(i * 7 + 1) + "/Area1/Piece").animation = "Rook"
		get_node("Line" + str(i * 7 + 1) + "/Area2/Piece").animation = "Knight"
		get_node("Line" + str(i * 7 + 1) + "/Area3/Piece").animation = "Bishop"
		get_node("Line" + str(i * 7 + 1) + "/Area4/Piece").animation = "Queen"
		get_node("Line" + str(i * 7 + 1) + "/Area5/Piece").animation = "King"
		get_node("Line" + str(i * 7 + 1) + "/Area6/Piece").animation = "Bishop"
		get_node("Line" + str(i * 7 + 1) + "/Area7/Piece").animation = "Knight"
		get_node("Line" + str(i * 7 + 1) + "/Area8/Piece").animation = "Rook"
	for i in 2:
		for j in 8:
			get_node("Line" + str(7 - 5 * i) + "/Area" + str(j + 1) + "/Piece").animation = "Pawn"
			get_node("Line" + str(i + 7) +"/Area" + str(j + 1) + "/Piece").frame = 1
	moved = [[], []]
	check = [false, false]
	king = [[1, 5], [8, 5]]
	select = false
	drop = false
	#white = true

func _drag():
	var piece = "Line" + str(line) + "/Area" + str(area) + "/Piece"
	if (white and get_node(piece).frame == 0) or (not white and get_node(piece).frame == 1):
		options = [[line, area]]
		$Piece.global_position = get_node("Line" + str(line) + "/Area" + str(area)).global_position
		$Piece.animation = get_node(piece).animation
		$Piece.frame = get_node(piece).frame
		get_node(piece).modulate.a = 0.5
		get_node("Line" + str(line) + "/Area" + str(area) + "/Overlay").animation = "Select"
		if check[int(!white)]:
			get_node("Line" + str(king[int(!white)][0]) + "/Area" + str(king[int(!white)][1]) + "/Overlay").frame = 1
		match get_node(piece).animation:
			"Bishop":
				_move_Bishop()
			"King":
				_move_King()
			"Knight":
				_move_Knight()
			"Pawn":
				_move_Pawn()
			"Queen":
				_move_Queen()
			"Rook":
				_move_Rook()
		select = true

func _drop():
	$Piece.animation = "Empty"
	get_node("Line" + str(line) + "/Area" + str(area) + "/Piece").modulate.a = 1
	for i in options.size():
		get_node("Line" + str(options[i][0]) + "/Area" + str(options[i][1]) + "/Overlay").animation = "Empty"
	if check[int(!white)]:
		get_node("Line" + str(king[int(!white)][0]) + "/Area" + str(king[int(!white)][1]) + "/Overlay").frame = 1
	select = false
	drop = false
	print(check)

func _move_Bishop():
	for i in 7:
		var turn = i + 1
		if line - i > 1 and area - i > 1 and (get_node("Line" + str(line - i) + "/Area" + str(area - i) + "/Overlay").animation == "OptionEmpty" or get_node("Line" + str(line - i) + "/Area" + str(area - i) + "/Overlay").animation == "Select"):
			_select_options(line - turn, area - turn)
		if line - i > 1 and area + i < 8 and (get_node("Line" + str(line - i) + "/Area" + str(area + i) + "/Overlay").animation == "OptionEmpty" or get_node("Line" + str(line - i) + "/Area" + str(area + i) + "/Overlay").animation == "Select"):
			_select_options(line - turn, area + turn)
		if line + i < 8 and area - i > 1 and (get_node("Line" + str(line + i) + "/Area" + str(area - i) + "/Overlay").animation == "OptionEmpty" or get_node("Line" + str(line + i) + "/Area" + str(area - i) + "/Overlay").animation == "Select"):
			_select_options(line + turn, area - turn)
		if line + i < 8 and area + i < 8 and (get_node("Line" + str(line + i) + "/Area" + str(area + i) + "/Overlay").animation == "OptionEmpty" or get_node("Line" + str(line + i) + "/Area" + str(area + i) + "/Overlay").animation == "Select"):
			_select_options(line + turn, area + turn)

func _move_King():
	for i in 3:
		for j in 3:
			var x = line + i - 1
			var y = area + j - 1
			if x > 0 and x <= 8 and y > 0 and y <= 8:
				if get_node("Line" + str(x) + "/Area" + str(y) + "/Piece").animation == "Empty":
					if _check(x, y, false):
						print(str(x) + "-" + str(y) + " jes")
					else:
						get_node("Line" + str(x) + "/Area" + str(y) + "/Overlay").animation = "OptionEmpty"
						options.append([x, y])
				elif get_node("Line" + str(x) + "/Area" + str(y) + "/Piece").frame == int(white):
					if _check(x, y, false):
						print(str(x) + "-" + str(y) + " jes")
					else:
						get_node("Line" + str(x) + "/Area" + str(y) + "/Overlay").animation = "OptionFull"
						options.append([x, y])

func _move_Knight():
	if area - 2 > 0:
		if line - 1 > 0:
			_select_options(line - 1, area - 2)
		if line + 1 <= 8:
			_select_options(line + 1, area - 2)
	if area + 2 <= 8:
		if line - 1 > 0:
			_select_options(line - 1, area + 2)
		if line + 1 <= 8:
			_select_options(line + 1, area + 2)
	if line - 2 > 0:
		if area - 1 > 0:
			_select_options(line - 2, area - 1)
		if area + 1 <= 8:
			_select_options(line - 2, area + 1)
	if line + 2 <= 8:
		if area - 1 > 0:
			_select_options(line + 2, area - 1)
		if area + 1 <= 8:
			_select_options(line + 2, area + 1)

func _move_Pawn():
	var turn = -1 + 2 * int(white)
	if get_node("Line" + str(line + turn) + "/Area" + str(area) + "/Piece").animation == "Empty":
		get_node("Line" + str(line + turn) + "/Area" + str(area) + "/Overlay").animation = "OptionEmpty"
		options.append([line + turn, area])
		if line == 7 - 5 * int(white) and get_node("Line" + str(line + turn * 2) + "/Area" + str(area) + "/Piece").animation == "Empty":
			get_node("Line" + str(line + turn * 2) + "/Area" + str(area) + "/Overlay").animation = "OptionEmpty"
			options.append([line + turn * 2, area])
	if area > 1 and get_node("Line" + str(line + turn) + "/Area" + str(area - 1) + "/Piece").animation != "Empty" and get_node("Line" + str(line + turn) + "/Area" + str(area - 1) + "/Piece").frame == int(white):
		get_node("Line" + str(line + turn) + "/Area" + str(area - 1) + "/Overlay").animation = "OptionFull"
		options.append([line + turn, area - 1])
	if area < 8 and get_node("Line" + str(line + turn) + "/Area" + str(area + 1) + "/Piece").animation != "Empty" and get_node("Line" + str(line + turn) + "/Area" + str(area + 1) + "/Piece").frame == int(white):
		get_node("Line" + str(line + turn) + "/Area" + str(area + 1) + "/Overlay").animation = "OptionFull"
		options.append([line + turn, area + 1])

func _move_Queen():
	_move_Rook()
	_move_Bishop()

func _move_Rook():
	for i in 7:
		var turn = i + 1
		if area - i > 1 and (get_node("Line" + str(line) + "/Area" + str(area - i) + "/Overlay").animation == "OptionEmpty" or get_node("Line" + str(line) + "/Area" + str(area - i) + "/Overlay").animation == "Select"):
			_select_options(line, area - turn)
		if area + i < 8 and (get_node("Line" + str(line) + "/Area" + str(area + i) + "/Overlay").animation == "OptionEmpty" or get_node("Line" + str(line) + "/Area" + str(area + i) + "/Overlay").animation == "Select"):
			_select_options(line, area + turn)
		if line - i > 1 and (get_node("Line" + str(line - i) + "/Area" + str(area) + "/Overlay").animation == "OptionEmpty" or get_node("Line" + str(line - i) + "/Area" + str(area) + "/Overlay").animation == "Select"):
			_select_options(line - turn, area)
		if line + i < 8 and (get_node("Line" + str(line + i) + "/Area" + str(area) + "/Overlay").animation == "OptionEmpty" or get_node("Line" + str(line + i) + "/Area" + str(area) + "/Overlay").animation == "Select"):
			_select_options(line + turn, area)

func _select_options(var x, var y):
	pos = [x, y]
	if not _check(king[int(!white)][0], king[int(!white)][1], true):
		if get_node("Line" + str(x) + "/Area" + str(y) + "/Piece").animation == "Empty":
			get_node("Line" + str(x) + "/Area" + str(y) + "/Overlay").animation = "OptionEmpty"
			options.append([x, y])
		elif get_node("Line" + str(x) + "/Area" + str(y) + "/Piece").frame == int(white):
			get_node("Line" + str(x) + "/Area" + str(y) + "/Overlay").animation = "OptionFull"
			options.append([x, y])

func _check(var x, var y, var move):
	direction = [true, true, true, true, true, true, true, true] #U, R, D, L, UR, DR, DL, UL
	for i in 7:
		var turn = i + 1
		var left = false
		var right = false
		if y - i > 1: #left
			if _find_check(x, y - turn, "Rook", 3, i, false, move):
				return true
			left = true
		if y + i < 8: #right
			if _find_check(x, y + turn, "Rook", 1, i, false, move):
				return true
			right = true
		if x - i > 1: #down
			if _find_check(x - turn, y, "Rook", 2, i, false, move) or (left and _find_check(x - turn, y - turn, "Bishop", 6, i, false, move)) or (right and _find_check(x - turn, y + turn, "Bishop", 5, i, false, move)):
				return true
		if x + i < 8: #up
			if _find_check(x + turn, y, "Rook", 0, i, false, move) or (left and _find_check(x + turn, y - turn, "Bishop", 7, i, true, move)) or (right and _find_check(x + turn, y + turn, "Bishop", 4, i, true, move)):
				return true
	if y - 2 > 0:
		if x - 1 > 0 and get_node("Line" + str(x - 1) + "/Area" + str(y - 2) + "/Piece").animation == "Knight" and get_node("Line" + str(x - 1) + "/Area" + str(y - 2) + "/Piece").frame == int(white):
			return true
		if x + 1 <= 8 and get_node("Line" + str(x + 1) + "/Area" + str(y - 2) + "/Piece").animation == "Knight" and get_node("Line" + str(x + 1) + "/Area" + str(y - 2) + "/Piece").frame == int(white):
			return true
	if y + 2 <= 8:
		if x - 1 > 0 and get_node("Line" + str(x - 1) + "/Area" + str(y + 2) + "/Piece").animation == "Knight" and get_node("Line" + str(x - 1) + "/Area" + str(y + 2) + "/Piece").frame == int(white):
			return true
		if x + 1 <= 8 and get_node("Line" + str(x + 1) + "/Area" + str(y + 2) + "/Piece").animation == "Knight" and get_node("Line" + str(x + 1) + "/Area" + str(y + 2) + "/Piece").frame == int(white):
			return true
	if x - 2 > 0:
		if y - 1 > 0 and get_node("Line" + str(x - 2) + "/Area" + str(y - 1) + "/Piece").animation == "Knight" and get_node("Line" + str(x - 2) + "/Area" + str(y - 1) + "/Piece").frame == int(white):
			return true
		if y + 1 <= 8 and get_node("Line" + str(x - 2) + "/Area" + str(y + 1) + "/Piece").animation == "Knight" and get_node("Line" + str(x - 2) + "/Area" + str(y + 1) + "/Piece").frame == int(white):
			return true
	if x + 2 <= 8:
		if y - 1 > 0 and get_node("Line" + str(x + 2) + "/Area" + str(y - 1) + "/Piece").animation == "Knight" and get_node("Line" + str(x + 2) + "/Area" + str(y - 1) + "/Piece").frame == int(white):
			return true
		if y + 1 <= 0 and get_node("Line" + str(x + 2) + "/Area" + str(y + 1) + "/Piece").animation == "Knight" and get_node("Line" + str(x + 2) + "/Area" + str(y + 1) + "/Piece").frame == int(white):
			return true
	return false

func _find_check(var x, var y, var figure, var num, var i, var pawn, var move):
	print (str(x) + " " + str(y) + " : " + str(line) + " " + str(area) + " : " + str(pos))
	var piece = "Line" + str(x) + "/Area" + str(y) + "/Piece"
	if get_node(piece).animation != "Empty" and direction[num] and ((move and x != line and y != area) or !move):
		print("jj")
		if get_node(piece).frame == int(white):
			if get_node(piece).animation == figure or get_node(piece).animation == "Queen":
				return true
			elif i == 0:
				if get_node(piece).animation == "King" or (pawn and get_node(piece).animation == "Pawn"):
					return true
			else:
				direction[num] = false
		elif get_node(piece).animation != "King" and ((move and x != line and y != area) or !move):
			direction[num] = false
	else:
		print("nn")
	return false
