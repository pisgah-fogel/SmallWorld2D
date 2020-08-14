extends KinematicBody2D

enum {
	MOVE,
	INVENTORY,
	GET_OBJECT,
	FISHING,
	GOTFISH
}

enum Direction {UP, DOWN, LEFT, RIGHT}

const FishingBait = preload("res://FishingBait.tscn")
const Inventory = preload("res://Inventory.tscn")
export(int) var speed = 240.0
export(int) var max_inventory = 10
var state = MOVE
var userControl = Vector2.ZERO
var velocity = Vector2.ZERO
var animationPlayer = null
var inventoryInstance = null
var objectList = []
var bait = null
var bait_movement = false
var bait_notInWater = false
var newFish = null
var mDirection = Direction.DOWN


class Wallet:
	var money:int = 0
var mWallet = Wallet.new()

func _ready():
	animationPlayer = $AnimationPlayer
	animationPlayer.play("idle_down")
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func _physics_process(delta):
	match state:
		MOVE:
			state_move(delta)
		GET_OBJECT:
			pass # Do nothing, just the animation
		INVENTORY:
			pass # Do nothing, just stop when something is pressed
		FISHING:
			state_fishing(delta)
		GOTFISH:
			state_gotFish(delta)

func _unhandled_key_input(event):
	match state:
		MOVE:
			if event.is_action_pressed("ui_action"):
				start_getObject()
				return
			elif event.is_action_pressed("ui_inventory"):
				start_inventory()
				return
			elif event.is_action_pressed("ui_fishing"):
				start_fishing()
				return
			else:
				userControl.x = event.get_action_strength("ui_right") - event.get_action_strength("ui_left")
				userControl.y = event.get_action_strength("ui_down") - event.get_action_strength("ui_up")
		GET_OBJECT:
			pass
		INVENTORY:
			if event.is_action_pressed("ui_action") or event.is_action_pressed("ui_cancel") or event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_inventory"):
				stop_inventory()
		FISHING:
			if event.is_action_pressed("ui_up") or event.is_action_pressed("ui_down") or event.is_action_pressed("ui_left") or event.is_action_pressed("ui_right"):
				stop_fishing()

			if event.is_action_pressed("ui_fishing"):
				bait_movement = true
			elif event.is_action_released("ui_fishing"):
				bait_movement = false
		GOTFISH:
			pass

func _on_AnimationPlayer_animation_finished(anim_name):
	match state:
		MOVE:
			pass
		GET_OBJECT:
			if anim_name == "get_down":
				start_move()
		INVENTORY:
			if anim_name == "inventory":
				open_inventory(null)
		FISHING:
			if bait_notInWater:
				stop_fishing()
			else:
				if bait != null:
					add_child(bait)
		GOTFISH:
			pass
##################### FISHING #######################

func state_gotFish(delta):
	if newFish != null:
		newFish.translate((global_position - newFish.global_position).normalized()*delta*50)
		if newFish.global_position.distance_to(global_position) < 100:
			stop_gotFish()
	else:
		stop_gotFish()

func stop_gotFish():
	if newFish != null:
		print("Player catched ", newFish.name)
		if haveSpareSpace():
			addObjectToInventory(newFish.mItem)
		else:
			print("Inventory is full")
		# TODO handle full inventory
		newFish.queue_free()
	newFish = null
	stop_fishing() #Free bait & start_move()

func stop_fishing():
	bait_notInWater = false
	bait_movement = false
	if bait != null:
		bait.queue_free()
		bait = null
	start_move()

func _fishCatched(fish):
	state = GOTFISH
	newFish = fish
	if bait != null:
		bait.queue_free()
	bait = null
	newFish._show_yourself()
	newFish.global_rotation = 0

func _baitEaten(fish):
	stop_fishing()

func start_fishing():
	velocity = Vector2.ZERO
	var tmp = Vector2.ZERO
	state = FISHING
	match mDirection:
			Direction.DOWN:
				animationPlayer.play("fishing_down")
				tmp = get_parent().global_position + Vector2(0.0, 200)
			Direction.UP:
				animationPlayer.play("fishing_up")
				tmp = get_parent().global_position + Vector2(0.0, -200)
			Direction.LEFT:
				animationPlayer.play("fishing_left")
				tmp = get_parent().global_position + Vector2(-200, 0.0)
			Direction.RIGHT:
				animationPlayer.play("fishing_right")
				tmp = get_parent().global_position + Vector2(200, 0.0)
	if not get_parent().get_parent().is_water(tmp + global_position):
		bait_notInWater = true
	elif bait == null:
		bait_notInWater = false
		bait = FishingBait.instance()
		bait.global_position = tmp
		bait.connect("fishCatched", self, "_fishCatched")
		bait.connect("baitEaten", self, "_baitEaten")

func state_fishing(delta):
	if bait_movement and bait != null:
		# TODO check that the bait is not too close to the player
		match mDirection:
			Direction.DOWN:
				bait.translate(Vector2(0, -100)*delta)
			Direction.UP:
				bait.translate(Vector2(0, 100)*delta)
			Direction.LEFT:
				bait.translate(Vector2(100, 0)*delta)
			Direction.RIGHT:
				bait.translate(Vector2(-100, 0)*delta)
		if not get_parent().get_parent().is_water(bait.global_position):
			stop_fishing()

############################  MOVING ######################

func start_move():
	state = MOVE
	animationPlayer.play("idle_down")

func state_move(delta):
	velocity = userControl.normalized() * speed
	velocity = velocity*delta
	# TODO add movement fluidity went switch from one direction to an other
	var col_info = move_and_collide(velocity)
	if col_info or velocity == Vector2.ZERO:
		match mDirection:
			Direction.DOWN:
				animationPlayer.play("idle_down")
			Direction.UP:
				animationPlayer.play("idle_up")
			Direction.LEFT:
				animationPlayer.play("idle_left")
			Direction.RIGHT:
				animationPlayer.play("idle_right")
	else:
		if userControl.x > 0:
			mDirection = Direction.RIGHT
			animationPlayer.play("right")
		elif userControl.x < 0:
			mDirection = Direction.LEFT
			animationPlayer.play("left")
		elif userControl.y > 0:
			mDirection = Direction.DOWN
			animationPlayer.play("down")
		elif userControl.y < 0:
			mDirection = Direction.UP
			animationPlayer.play("up")

####################### GETTING OBJECTS #######################
func start_getObject():
	velocity = Vector2.ZERO
	state = GET_OBJECT
	animationPlayer.play("get_down")
	velocity = Vector2.ZERO

########################## INVENTORY ############################

func start_inventory():
	animationPlayer.play("inventory")
	velocity = Vector2.ZERO
	state = INVENTORY

func open_inventory(chest):
	velocity = Vector2.ZERO
	state = INVENTORY
	clear_null_inventory()
	inventoryInstance = Inventory.instance()
	if inventoryInstance.has_method("setUserWallet"):
		inventoryInstance.setUserWallet(mWallet)
	if chest and chest.has_method("setUserWallet"):
		chest.setUserWallet(mWallet)
	inventoryInstance.setInventoryList(objectList)
	inventoryInstance.connect("newInventorySelection", self, "_inventorySelection")
	inventoryInstance.chest = chest
	add_child(inventoryInstance)

func stop_inventory():
	start_move()
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	if inventoryInstance.chest != null:
		inventoryInstance.chest.closeChest()
	if inventoryInstance != null:
		inventoryInstance.queue_free()

func _on_chestOpenned(chest):
	open_inventory(chest)

func _inventorySelection(itemSelection):
	print("Player: Item selection: ", itemSelection)

##################### SAVING RESOURCES ########################

func save(save_game: Resource):
	save_game.data["character_position"] = global_position
	save_game.data["character_objects"] = objectList
	save_game.data["character_money"] = mWallet.money

func load(save_game: Resource):
	global_position = save_game.data["character_position"]
	objectList = save_game.data["character_objects"]
	mWallet.money = save_game.data["character_money"]

######################## UTILS ########################

func receiveObject(object, giver):
	print("Player receive ", object.name)
	if haveSpareSpace():
		giver.canRemoveObject(object)
		addObjectToInventory(object)
	else:
		# TODO handle inventory full
		giver.canRemoveObject(object)
		print("Inventory is full")

func haveSpareSpace():
	var count = 0
	for item in objectList:
		if item == null:
			count += 1
	return objectList.size()-count < max_inventory

func addObjectToInventory(object):
	for i in range(objectList.size()):
		if objectList[i] == null:
			objectList[i] = object
			return
	objectList.append(object)
	

func clear_null_inventory():
	while objectList.size() > 0 and objectList[objectList.size()-1] == null:
		objectList.pop_back()
