extends Node2D


export(int) var sprite_w = 90
export(int) var sprite_h = 90
export(int) var columns = 11
export(int) var index = 0 setget setIndex

onready var mSprite = $Sprite

func setIndex(i):
	index = i
	update()

func update():
	mSprite.region_rect = Rect2(Vector2(sprite_w*(index%columns),sprite_w*(index/columns)), Vector2(sprite_w, sprite_h))

func _ready():
	update()
