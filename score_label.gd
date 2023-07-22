extends Label
class_name ScoreLabel

var score = 0
var trauma = 0
var shake = 8
var counter_offset = Vector2(0, 0)

func _process(delta):
	position -= counter_offset
	trauma = min(max(trauma - delta*1.5, 0), 1)
	counter_offset = Vector2((2*randf() - 1)*shake*trauma*trauma, (2*randf() - 1)*shake*trauma*trauma)
	position += counter_offset
	
	text = str(int(score), "Pts")

func scorePlusInLabel(point):
	score += point
	trauma += 0.9
