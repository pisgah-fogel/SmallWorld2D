extends Node2D

onready var mGameSaver = $GameSaver
onready var mGround = $Ground

func _ready():
	mGameSaver.load(0)
	randomize()

func _notification(what):
	if (what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST):
		mGameSaver.save(0)

func is_water(position):
	var relative = position - mGround.global_position
	var tilep = relative / mGround.cell_size
	# TODO: find more robust way to do it
	return mGround.get_cellv(tilep) == 39 # 39 = Water
