extends Node2D

export(Rect2) var spawner_zone
export(int) var spawn_every_x_second = 1
export(int) var max_spawn = 2

onready var mTimer = $Timer
const Fish = preload("res://Fish.tscn")
var numberFish = 0

func _fish_vanished():
	numberFish -= 1
	mTimer.start(spawn_every_x_second)

func random_vec_in_box(x, y, w, h):
	return Vector2(x+w*randf(), y+h*randf())

func create_fish():
	var fish = Fish.instance()
	fish.global_position = random_vec_in_box(spawner_zone.position.x, spawner_zone.position.y, spawner_zone.size.x, spawner_zone.size.y)
	fish.connect("tree_exiting", self, "_fish_vanished")
	#print("Fish spawn x:", fish.global_position.x, " y:", fish.global_position.y)
	add_child(fish)
	fish.setZone(Rect2(spawner_zone.position + global_position, spawner_zone.size))
	numberFish += 1
	if max_spawn > numberFish:
		mTimer.start(spawn_every_x_second)

func _ready():
	mTimer.start(spawn_every_x_second)

func _on_Timer_timeout():
	if max_spawn > numberFish:
		create_fish()
