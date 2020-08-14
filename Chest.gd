extends StaticBody2D

onready var mSprite = $Sprite

signal chestOpenned(chest)

export var mObjects = []
export var num_column = 3
export var num_row = 1
export(bool) var isBin = false

var tileStart = Vector2(0, -2)

const Item = preload('res://Item.gd')

func _on_Area2D_body_entered(body):
	print("Play opened a chest")
	mSprite.frame = 1
	emit_signal("chestOpenned", self)

func closeChest():
	mSprite.frame = 0
	print("Chest closed")

##################### SAVING RESOURCES ########################

func save(save_game: Resource):
	save_game.data["chest_1_objects"] = mObjects

func load(save_game: Resource):
	mObjects = save_game.data["chest_1_objects"]
