extends Control

export(int) var default_sel = 0
var pos_sel = default_sel

export(int) var num_column = 5
export(int) var num_row = 2
export(int) var chest_tile = 7
export(Vector2) var mouse_clicker =  Vector2(50, 40)
export(Vector2) var mouse_offset = Vector2(0, 0)

var mObjects=[]

onready var mSelection = $selection
onready var mItemMap = $ItemMap
onready var mItemSprite = $ItemSprite
onready var mTileMap = $TileMap
onready var mGoldLabel = $GoldLabel

var tileStart = Vector2(0, 0)
var dragging = false
var draggingObj = null
var originalPos = 0
var originChest = false

const Item = preload('res://Item.gd')

var hand_open = load("res://gfx_src/hand_open.png")
var hand_close = load("res://gfx_src/hand_close.png")

var chest = null setget setChest

var userWallet = null
func setUserWallet(wallet):
	print("Inventory::setUserWallet")
	userWallet = wallet
	if mGoldLabel != null:
		mGoldLabel.text = str(wallet.money)

signal newInventorySelection(item)

func create_chest_background():
	if mTileMap and chest!=null:
		for row in range(chest.num_row):
			for col in range(chest.num_column):
				mTileMap.set_cell(chest.tileStart.x + col, chest.tileStart.y + row, chest_tile)

func setChest(newchest):
	chest = newchest
	create_chest_background()

func update_drafting_sprite(i:int, object):
	if i < object.mObjects.size():
		if object.mObjects[i] != null:
			mItemSprite.position = get_local_mouse_position() - Vector2(600, 500)
			mItemSprite.visible = true
			mItemSprite.index = object.mObjects[i].id
		else:
			reset_drafting_sprite()
			
func reset_drafting_sprite():
	mItemSprite.index = 0
	mItemSprite.visible = false

func move_sprite_on_sel(i:int):
	mSelection.position.x =250+i%num_column*(100)
	mSelection.position.y = 350+(100)*(i/num_column)
	if i < mObjects.size():
		emit_signal("newInventorySelection", mObjects[i])

func update_items_sprites():
	var count = 0
	if not mItemMap:
		return
	for item in mObjects:
		var sprite_id = -1
		if item != null:
			sprite_id = item.id
		var cell_x = count%num_column + tileStart.x
		var cell_y = count/num_column + tileStart.y
		mItemMap.set_cell(cell_x, cell_y, sprite_id)
		count += 1
	if chest:
		count = 0
		for i in range(chest.num_column*chest.num_row):
			var sprite_id = -1
			var item = null
			if i < chest.mObjects.size():
				item = chest.mObjects[i]
				if item != null:
					sprite_id = item.id
			var cell_x = i%chest.num_column + chest.tileStart.x
			var cell_y = i/chest.num_column + chest.tileStart.y
			mItemMap.set_cell(cell_x, cell_y, sprite_id)
			count += 1

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	Input.set_custom_mouse_cursor(hand_open, Input.CURSOR_ARROW, mouse_clicker)
	pos_sel = default_sel
	move_sprite_on_sel(pos_sel)
	update_items_sprites()
	create_chest_background()
	if userWallet != null:
		mGoldLabel.text = str(userWallet.money)

func is_inside_inventory(ix, iy, object):
	var minx = object.tileStart.x
	var maxx = minx + object.num_column
	var miny = object.tileStart.y
	var maxy = miny + object.num_row
	if ix <= maxx and iy <= maxy and ix >= minx and iy >= miny:
		return true
	return false

func start_drag_sprite(pos):
	if dragging:
		if originChest:
			chest.setItem(originalPos,draggingObj)
		else:
			mObjects[originalPos] = draggingObj
		dragging = false
		originalPos = 0
		draggingObj = null
		reset_drafting_sprite()

	var tmp = mouse_to_mItemMap_relative(pos)
	var ix:int = tmp.x
	var iy:int = tmp.y
	if is_inside_inventory(ix, iy, self):
		pos_sel = (ix-tileStart.x) + (iy-tileStart.y)*num_column
		originChest = false
		if pos_sel < 0:
			dragging = false
			originalPos = 0
			draggingObj = null
			reset_drafting_sprite()
			update_items_sprites()
		elif pos_sel < mObjects.size():
			dragging = true
			Input.set_custom_mouse_cursor(hand_close, Input.CURSOR_ARROW, mouse_clicker)
			originalPos = pos_sel
			update_drafting_sprite(pos_sel, self)
			draggingObj = mObjects[pos_sel]
			mObjects[pos_sel] = null
			update_items_sprites()
	elif chest != null and is_inside_inventory(ix, iy, chest): # valid coordinates ?
		pos_sel = (ix-chest.tileStart.x) + (iy-chest.tileStart.y-1)*chest.num_column
		originChest = true
		if pos_sel < 0:
			dragging = false
			originalPos = 0
			draggingObj = null
			reset_drafting_sprite()
			update_items_sprites()
		elif pos_sel < chest.mObjects.size():
			dragging = true
			Input.set_custom_mouse_cursor(hand_close, Input.CURSOR_ARROW, mouse_clicker)
			originalPos = pos_sel
			update_drafting_sprite(pos_sel, chest)
			draggingObj = chest.mObjects[pos_sel]
			chest.setItem(originalPos,null)
			update_items_sprites()
	else:
		dragging = false
		originalPos = 0
		draggingObj = null
		reset_drafting_sprite()
		update_items_sprites()
		return
		
func mouse_to_mItemMap_relative(pos):
	var tmp = (pos - mItemMap.position)/mItemMap.scale + Vector2(100,100)*mItemMap.cell_size
	tmp = tmp/mItemMap.cell_size
	return tmp - Vector2(100, 100)

func end_drag_sprite(pos):
	reset_drafting_sprite()
	if not dragging:
		return
	dragging = false
	Input.set_custom_mouse_cursor(hand_open, Input.CURSOR_ARROW, mouse_clicker)
	var tmp = mouse_to_mItemMap_relative(pos)
	var ix:int = tmp.x
	var iy:int = tmp.y
	
	if is_inside_inventory(ix, iy, self): # valid coordinates ?
		var pos_sel_bis = (ix-tileStart.x) + (iy-tileStart.y)*num_column
		# Switch with an other item
		if pos_sel_bis < 0:
			if originChest:
				chest.setItem(originalPos, draggingObj)
			else:
				mObjects[originalPos] = draggingObj
		# Switch item with an other one
		elif pos_sel_bis < mObjects.size() and mObjects[pos_sel_bis] != null:
			var buff = mObjects[pos_sel_bis]
			if originChest:
				chest.setItem(originalPos, buff)
			else:
				mObjects[originalPos] = buff
			mObjects[pos_sel_bis] = draggingObj
		# remplace null item with this one
		elif pos_sel_bis < mObjects.size() and mObjects[pos_sel_bis] == null:
			mObjects[pos_sel_bis] = draggingObj
		# Add at the end of the list
		elif pos_sel_bis >= mObjects.size() && pos_sel_bis < num_column*num_row: 
			mObjects.append(draggingObj)
		else:
			if originChest:
				chest.setItem(originalPos, draggingObj)
			else:
				mObjects[originalPos] = draggingObj
	elif chest != null and is_inside_inventory(ix, iy, chest):
		var pos_sel_bis = (ix-chest.tileStart.x) + (iy-chest.tileStart.y-1)*chest.num_column
		# Switch with an other item
		if chest.isBin:
			originalPos = 0
			draggingObj = null
		elif pos_sel_bis < 0:
			if originChest:
				chest.setItem(originalPos, draggingObj)
			else:
				mObjects[originalPos] = draggingObj
		elif pos_sel_bis < chest.mObjects.size() and chest.mObjects[pos_sel_bis] != null:
			var buff = chest.mObjects[pos_sel_bis]
			if originChest:
				chest.setItem(originalPos, buff)
			else:
				mObjects[originalPos] = buff
			chest.setItem(pos_sel_bis, draggingObj)
		# remplace null item with this one
		elif pos_sel_bis < chest.mObjects.size() and chest.mObjects[pos_sel_bis] == null:
			chest.setItem(pos_sel_bis, draggingObj)
		# Add at the end of the list
		elif pos_sel_bis >= chest.mObjects.size() and pos_sel_bis < chest.num_column*chest.num_row: 
			chest.setItem(pos_sel_bis, draggingObj)
		else:
			if originChest:
				chest.setItem(originalPos, draggingObj)
			else:
				mObjects[originalPos] = draggingObj
	else:
		if originChest:
			chest.setItem(originalPos, draggingObj)
		else:
			mObjects[originalPos] = draggingObj
	originalPos = 0
	draggingObj = null
	update_items_sprites()

func follow_mouse(event):
	if dragging and draggingObj != null:
		mItemSprite.visible = true
		mItemSprite.position = event.position - Vector2(600, 500)

func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			start_drag_sprite(event.position-mouse_offset)
		elif event.button_index == BUTTON_LEFT and not event.pressed:
			end_drag_sprite(event.position-mouse_offset)
	if event is InputEventMouseMotion:
		follow_mouse(event)

func _input(event):
	if event.is_action_pressed("ui_left"):
		accept_event()
		if pos_sel > 0:
			pos_sel -= 1
			move_sprite_on_sel(pos_sel)
	elif event.is_action_pressed("ui_right"):
		accept_event()
		if pos_sel < num_column*num_row-1:
			pos_sel += 1
			move_sprite_on_sel(pos_sel)
	elif event.is_action_pressed("ui_up"):
		accept_event()
		if pos_sel >= num_column:
			pos_sel -= num_column
			move_sprite_on_sel(pos_sel)
	elif event.is_action_pressed("ui_down"):
		accept_event()
		if pos_sel < num_column*(num_row-1):
			pos_sel += num_column
			move_sprite_on_sel(pos_sel)

func setInventoryList(list):
	mObjects = list
	update_items_sprites()
