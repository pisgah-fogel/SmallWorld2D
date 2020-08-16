extends Node2D

onready var mGameSaver = $GameSaver
onready var mGround = $Ground

export(int) var water_tile = 4

func _ready():
	mGameSaver.load(0)
	randomize()

func _notification(what):
	if (what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST):
		mGameSaver.save(0)

func is_water(position):
	var relative = (position - mGround.global_position)/mGround.scale
	var tilep = relative / mGround.cell_size
	print("Looking at tile: x:",tilep.x, " y:", tilep.y)
	print("Tile type: ", mGround.get_cellv(tilep))
	# TODO: find more robust way to do it
	return mGround.get_cellv(tilep) == water_tile # 4 = Water
