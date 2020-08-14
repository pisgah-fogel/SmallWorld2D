extends StaticBody2D

onready var mSprite = $Sprite

export var mObjects = []
export var num_column = 1
export var num_row = 1
export(bool) var isBin = true
var tileStart = Vector2(0, -2)

const Item = preload('res://Item.gd')

func _on_Area2D_body_entered(body):
	body.get_parent()._on_chestOpenned(self)

func closeChest():
	pass

func setItem(index:int, object):
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
	
