extends StaticBody2D

onready var mSprite = $Sprite

export var mObjects = []
export var num_column = 3
export var num_row = 1

var total = 0

var tileStart = Vector2(0, -2)
var isShop = true

var prices = [
	0,
	1, # grass
	10, # green fruit
	15, # yellow fruit
	10, # red fruit
	75, # turtle
	50, # blue fish
	5, # seed
	5 # seed 
	]
	
var userWallet = null
func setUserWallet(wallet):
	print("Shop::setUserWallet")
	userWallet = wallet

func getPrice(item_id:int):
	if item_id >= 0 and item_id < prices.size():
		return prices[item_id]
	else:
		return 0
		
const Item = preload('res://Item.gd')

func _on_Area2D_body_entered(body):
	body.get_parent()._on_chestOpenned(self)
	# TODO: if userWAllter == null display something to tell the user...

func closeChest():
	userWallet.money += total
	mObjects.clear()
	total = 0

func setItem(index:int, object):
	if index >= 0 and index < mObjects.size() and mObjects[index]!= null:
		print("Removed from shop: ", mObjects[index].name, " (", getPrice(mObjects[index].id), ")")
		total -= getPrice(mObjects[index].id)
		# ToDO update display
		# ToDo: add need items when we buy some
	if index >= 0 and index < num_column*num_row and object != null:
		print("Added to shop: ", object.name, " (", getPrice(object.id), ")")
		total += getPrice(object.id)
		# ToDo update display
	print("Total: ", total)
	
	if index < 0:
		return false
	elif index < mObjects.size():
		mObjects[index] = object
		return true
	elif index < num_column*num_row:
		mObjects.append(object)
		return true
	else:
		return false
