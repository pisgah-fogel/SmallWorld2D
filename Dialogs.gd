extends CanvasLayer

onready var mControl = $Control
onready var mText = $Control/Text

var is_reading = false
var current = null
var current_index = 0

var mScript = [
	{
		"startup": true,
		"msg": [
			{
				"text":"Hello and welcome,\npress 'A' to play with us !"
			},
			{
				"text":"Good job !\nHave Fun now !"
			}
		]
	}
]

func update_placing():
	offset.y = mControl.get_viewport_rect().size.y-600
	offset.x = mControl.get_viewport_rect().size.x/2-500

func stop_reading():
	is_reading = false
	current = null
	current_index = 0
	mControl.visible = false

func update_text():
	if current and is_reading:
		mText.text = current[current_index]["text"]
		

func next_text():
	if current and is_reading:
		current_index += 1
		if current_index < current.size():
			update_text()
		else:
			stop_reading()

func _ready():
	get_tree().get_root().connect("size_changed", self, "_size_changed")
	update_placing()
	for item in mScript:
		if item["startup"]:
			print("Found a startup message")
			is_reading = true
			current = item["msg"]
			current_index = 0
	update_text()

func _size_changed():
	update_placing()

func _input(event):
	if not is_reading:
		return
	elif event.is_action_pressed("ui_action"):
		next_text()
	get_tree().set_input_as_handled()
