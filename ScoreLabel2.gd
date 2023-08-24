extends Label

var score = Singleton.get_score() - 2

func _process(delta):
	text = str(int(score), "Pts")

