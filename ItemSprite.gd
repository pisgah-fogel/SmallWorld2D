extends Node2D

export(int) var index = 0 setget setIndex

onready var mSprite = $Sprite

func setIndex(i):
	index = i
	update()

func update():
	mSprite.frame = index

func _ready():
	update()
