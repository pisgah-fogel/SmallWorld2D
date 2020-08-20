extends Popup

onready var mCanvasLayer = $CanvasLayer

func update_placing():
	print("Resizing: ", get_viewport_rect().size)
	mCanvasLayer.offset.y = get_viewport_rect().size.y-600
	mCanvasLayer.offset.x = get_viewport_rect().size.x/2-500

func _ready():
	get_tree().get_root().connect("size_changed", self, "_size_changed")
	update_placing()

func _size_changed():
	update_placing()
