extends Sprite

signal fishCatched(fish)
signal baitEaten(fish)

onready var mAnimationPlayer = $AnimationPlayer

func baitEatenByFish(fish):
	emit_signal("baitEaten", fish)

func catchAFish(fish):
	emit_signal("fishCatched", fish)

func tasting():
	mAnimationPlayer.play("taste")

func beating():
	mAnimationPlayer.play("beat")
