extends Node2D

const SIZE = 256
const GRID_SIZE = 16

const RED = Color("ab4642")
const GREEN = Color("a1b56c")

const GRID_COLOR = Color("282828")
const OCEAN_COLOR = Color("181818")
const SHIP_COLOR = Color("383838")
const HIT_COLOR = RED

const PREVIEW_PHASE = 0
const GAME_PHASE = 1

# BLOCK TYPES
const EMPTY = 0
const SHIP = 1
const OCEAN = 2
const HIT = 3
const SHIP_PREVIEW = 4
const SHIP_PREVIEW_CANT_ADD = 5

# TOTAL UNITS
var s2 = 2
var s3 = 4
var s4 = 2

var player_field = []
var enemy_field = []
var field = []

var turn = true

var phase = PREVIEW_PHASE

# Vars used for preview
var sel
var old_sel
var vertical = false

var ship_size

func _ready():
	init_blank_grid()


func _input(event):
	if event is InputEventMouseButton and event.pressed and turn:
		if event.button_index == BUTTON_LEFT:
			var sel = (event.position / GRID_SIZE).floor()
			
			if phase == PREVIEW_PHASE:
				if can_add_ship():
					add_ship()
				
				if s2 == 0 and s3 == 0 and s4 == 0:
					phase = GAME_PHASE
			else:
				if field[sel.x][sel.y] != EMPTY:
					return
				
				turn = !turn
				if enemy_field[sel.x][sel.y] == SHIP:
					field[sel.x][sel.y] = HIT
				else:
					field[sel.x][sel.y] = OCEAN
			
				update()
		if event.button_index == BUTTON_RIGHT:
			vertical = !vertical
			preview_ship(event.position)
	
	if event is InputEventMouseMotion:
		preview_ship(event.position)


func preview_ship(pos):
	ship_size = null
	old_sel = sel
	sel = (pos / GRID_SIZE).floor()
	
	var region = Vector2(GRID_SIZE,GRID_SIZE)
	var offset = 0
	
	if s4 > 0:
		ship_size = 4
		offset = 3
	elif s3 > 0:
		ship_size = 3
		offset = 2
	elif s2 > 0:
		ship_size = 2
		offset = 1
	
	if vertical:
		region.y -= offset
	else:
		region.x -= offset
	
	if ship_size != null:
		if is_sel_inside_region(sel, region):
			if old_sel != null:
				clear_old_preview()
			
			if can_add_ship():
				add_ship(SHIP_PREVIEW)
			else:
				add_ship(SHIP_PREVIEW_CANT_ADD)
		else:
			sel = old_sel

func clear_old_preview():
	for i in ship_size:
		if old_sel.y+i < GRID_SIZE and player_field[old_sel.x][old_sel.y+i] != SHIP:
			player_field[old_sel.x][old_sel.y+i] = EMPTY
		if old_sel.x+i < GRID_SIZE and player_field[old_sel.x+i][old_sel.y] != SHIP:
			player_field[old_sel.x+i][old_sel.y] = EMPTY


func add_ship(type = SHIP):
	for i in ship_size:
		if vertical:
			if player_field[sel.x][sel.y+i] != SHIP:
				player_field[sel.x][sel.y+i] = type
		else:
			if player_field[sel.x+i][sel.y] != SHIP:
				player_field[sel.x+i][sel.y] = type
	
	if type == SHIP:
		match(ship_size):
			2: s2 -= 1
			3: s3 -= 1
			4: s4 -= 1

	update()


func can_add_ship():
	for i in ship_size:
		if vertical:
			if player_field[sel.x][sel.y+i] == SHIP:
				return false
		else:
			if player_field[sel.x+i][sel.y] == SHIP:
				return false
	
	return true


func init_blank_grid():
	for x in SIZE / GRID_SIZE:
		var col = []
		for y in SIZE / GRID_SIZE:
			col.append(EMPTY)
		player_field.append(col)
		enemy_field.append(col.duplicate())
		field.append(col.duplicate())


func is_sel_inside_region(sel, region):
	return sel.x >= 0 and sel.y >= 0 and sel.x < region.x and sel.y < region.y


func _draw():
	draw_blocks()
	draw_grid()
	draw_turn()


func draw_blocks():
	for x in SIZE / GRID_SIZE:
		for y in SIZE / GRID_SIZE:
			var color
			var cell
			if phase == PREVIEW_PHASE:
				cell = player_field
			else:
				cell = field
			match cell[x][y]:
				EMPTY: "do nothing"
				SHIP: color = SHIP_COLOR
				OCEAN: color = OCEAN_COLOR
				HIT: color = HIT_COLOR
				SHIP_PREVIEW: color = SHIP_COLOR
				SHIP_PREVIEW_CANT_ADD: color = RED
				
			if color:
				draw_rect(Rect2(Vector2(x * GRID_SIZE, y * GRID_SIZE), Vector2(GRID_SIZE, GRID_SIZE)), color)


func draw_grid():
	for x in range(1, SIZE / GRID_SIZE):
		draw_line(Vector2(x * GRID_SIZE, 0), Vector2(x * GRID_SIZE, SIZE), GRID_COLOR)
	for y in range(1, SIZE / GRID_SIZE):
		draw_line(Vector2(0, y * GRID_SIZE), Vector2(SIZE, y * GRID_SIZE), GRID_COLOR)


func draw_turn():
	var color
	
	if turn:
		color = GREEN
	else:
		color = RED
	draw_rect(Rect2(Vector2(1,0), Vector2(SIZE-1, SIZE-1)), color, false)
	draw_rect(Rect2(Vector2(2,1), Vector2(SIZE-3, SIZE-3)), color, false)
