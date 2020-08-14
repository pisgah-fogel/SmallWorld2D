extends Area2D

export(Vector2) var pos_nothing = Vector2(0, 720)
export(Vector2) var pos_green = Vector2(90*3, 720)
export(Vector2) var pos_yellow = Vector2(90*3, 720+1*90)
export(Vector2) var pos_red = Vector2(90*3, 720+2*90)

var farmKind = 0

onready var sprite = $sprite
onready var timer = $Timer

const Item = preload('res://Item.gd')
var mItem = null

func update_sprite():
	match farmKind:
		Item._id.ID_GRASS:
			sprite.region_rect = Rect2(pos_nothing, sprite.region_rect.size)
		Item._id.ID_GRASS2:
			sprite.region_rect = Rect2(pos_green, sprite.region_rect.size)
		Item._id.ID_GRASS3:
			sprite.region_rect = Rect2(pos_yellow, sprite.region_rect.size)
		Item._id.ID_GRASS4:
			sprite.region_rect = Rect2(pos_red, sprite.region_rect.size)

func _ready():
	farmKind = Item._id.ID_GRASS
	timer.start(10)
	update_sprite()

func _on_FarmingArea_body_entered(body):
	if farmKind != Item._id.ID_GRASS:
		mItem = Item.new()
		mItem.id = farmKind
		mItem.name = Item._name[farmKind]
		mItem.data["quality"] = randi()%3;
		body.get_parent().receiveObject(mItem, self)

func _on_Timer_timeout():
	if farmKind == Item._id.ID_GRASS:
		farmKind = randi()%3+2 # 2, 3 or 4
		update_sprite()

func canRemoveObject(object_id):
	farmKind = Item._id.ID_GRASS
	update_sprite()
	timer.start(10)
