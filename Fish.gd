extends Node2D

enum {
	ENTER,
	WANDER,
	CHASING,
	SCARED,
	SLEEP,
	EATING,
	SHOW
}

var state = ENTER

var type = 0

export(int) var default_speed = 50
var speed

onready var mAnimation = $AnimationPlayer
onready var mSprite = $FishSprite

export(int) var default_y = 0
export(int) var tortle_y = 90*6

export(Rect2) var spawner_zone = Rect2(-100,-100,100,100)

var destination = Vector2.ZERO

onready var mTimer = $Timer

var food = null
enum ChasingState {ATTACK, BACK, WAIT}
var mChasingState = ChasingState.ATTACK
var distance_chasing_back = 50

export(int) var want_food = 50
export(int) var badLuck = 10

export(float) var timeToCatch = 0.75

const Item = preload('res://Item.gd')
var mItem = null

func random_vec_in_zone():
	return Vector2(spawner_zone.position.x+spawner_zone.size.x*randf(), spawner_zone.position.y+spawner_zone.size.y*randf())
	
func _on_Timer_timeout():
	mTimer.start(randi()%7+2)
	if state == WANDER:
		if randi()%100 < 50:
			start_sleeping()
	elif state == SLEEP:
		start_wandering()
	elif state == CHASING:
		mChasingState = ChasingState.ATTACK
	elif state == EATING:
		_timeout_eating()
	
func random_type():
	var i = randi()%100
	if i<80:
		return Item._id.ID_TURTLE
	else:
		return Item._id.ID_FISH

func _ready():
	type = Item._id.ID_FISH
	type = random_type()
	mItem = Item.new()
	mItem.id = type
	mItem.name = Item._name[type]
	match type:
		Item._id.ID_FISH:
			mItem.data["size"] = randi()%5+6
			mSprite.region_rect.position.y = default_y
		Item._id.ID_TURTLE:
			mItem.data["size"] = randi()%10+11
			mSprite.region_rect.position.y = tortle_y
	start_enter()

func setZone(zone):
	spawner_zone = zone
	destination = random_vec_in_zone()
	look_at(to_global(destination))

func _process(delta):
	match state:
		ENTER:
			pass
		WANDER:
			state_wander(delta)
		CHASING:
			state_chasing(delta)
		SCARED:
			state_scared(delta)
		SLEEP:
			pass
		EATING:
			pass
		SHOW:
			pass

func _unhandled_key_input(event):
	match state:
		ENTER:
			pass
		WANDER:
			pass
		CHASING:
			if event.is_action_pressed("ui_fishing"):
				start_scared()
		SCARED:
			pass
		SLEEP:
			pass
		EATING:
			if event.is_action_pressed("ui_fishing"):
				mTimer.stop()
				if food != null:
					food.get_parent().catchAFish(self)
				else:
					start_scared()
		SHOW:
			pass

########################### SHOW ##########################

func _show_yourself():
	state = SHOW
	mAnimation.playback_speed = 0.5
	mAnimation.play("move")

##################### SPAWNING / ENTER ####################

func _end_of_enter_anim():
	start_wandering()
	mTimer.start(randi()%5+2)

func start_enter():
	rotation = randf()*2*3.14
	speed = default_speed/2
	mAnimation.playback_speed = 0.5
	state = ENTER
	mAnimation.play("enter")


######################### SLEEPING ########################

func start_sleeping():
	mAnimation.play("hide")
	mAnimation.playback_speed = 0.5
	state = SLEEP

####################### WANDERING #########################

func start_wandering():
	mAnimation.play("hide")
	speed = default_speed
	mAnimation.playback_speed = 0.5
	state = WANDER

func state_wander(delta):
	if global_position.distance_to(destination) <= 10:
		destination = random_vec_in_zone()
		look_at(destination)
	else:
		look_at(destination)
		move_local_x(delta*speed)

######################## CHASING ##########################

func _on_FishView_body_entered(body):
	if state == SCARED or state == ENTER or state == EATING or state == SHOW:
		return
	state = CHASING
	mAnimation.playback_speed = 0.5
	speed = default_speed
	food = body

func state_chasing(delta):
	if food != null:
		if global_position.distance_to(food.global_position) < 10:
			if randi()%100 < want_food:
				start_eating()
				return
			elif randi()%100 < badLuck:
				food.get_parent().tasting()
				start_scared()
			else:
				food.get_parent().tasting()
				mChasingState = ChasingState.BACK
		match mChasingState:
			ChasingState.WAIT:
				mAnimation.playback_speed = 0.5
			ChasingState.ATTACK:
				mAnimation.playback_speed = 0.5
				look_at(food.global_position)
				translate(delta*speed*(food.global_position - global_position).normalized())
			ChasingState.BACK:
				look_at(food.global_position)
				translate(-delta*speed*(food.global_position - global_position).normalized())
				if global_position.distance_to(food.global_position) > distance_chasing_back:
					mChasingState = ChasingState.WAIT
	else:
		start_wandering()
		
######################### EATING ###########################

func start_eating():
	mTimer.start(timeToCatch)
	if food != null:
		food.get_parent().beating()
	else:
		start_scared()
	state = EATING
	mAnimation.playback_speed = 2

func _timeout_eating():
	if state != SHOW:
		if food != null:
			food.get_parent().baitEatenByFish(self)
		mTimer.stop()
		start_scared()

######################### SCARED ###########################

func state_scared(delta):
	move_local_x(delta*speed)
	
func start_scared():
	speed = default_speed/2
	mAnimation.playback_speed = 0.25
	state = SCARED
	mAnimation.play("scared")
	
func scared_animation_finished():
	queue_free()
	
func _on_PredatorView_body_entered(body):
	if state != SHOW:
		var character_angle = get_angle_to(body.global_position)
		rotation = character_angle + 3.14
		start_scared()
