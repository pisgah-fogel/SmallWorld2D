extends TextureRect

enum State {IDLE, APPEARS}

var mState = State.IDLE

func _process(delta):
	if mState == State.APPEARS:
		if self_modulate.a < 0.9:
			self_modulate.a += delta*0.5
		else:
			self_modulate.a = 1.0
	
func _appears():
	visible = true
	self_modulate.a = 0.0
	mState = State.APPEARS

func _disappears():
	visible = false
	mState = State.IDLE
