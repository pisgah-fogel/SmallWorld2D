extends CanvasLayer

onready var mControl = $Control

func update_placing():
	offset.y = mControl.get_viewport_rect().size.y-600
	offset.x = mControl.get_viewport_rect().size.x/2-500

func _ready():
	get_tree().get_root().connect("size_changed", self, "_size_changed")
	update_placing()

func _size_changed():
	update_placing()

func _input(event):
	if event.is_action_pressed("ui_action"):
		queue_free()
	get_tree().set_input_as_handled()
