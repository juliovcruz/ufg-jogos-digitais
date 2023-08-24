extends Label

var record: int
var score = Singleton.get_score() - 2



func _process(delta):
	if score > record:
		record = score
		var file = FileAccess.open("user://record.txt", FileAccess.WRITE)
		file.store_var(record)
		file.close()
	else:
		var file = FileAccess.open("user://record.txt", FileAccess.READ)
		if file.file_exists("user://record.txt"):
			record = file.get_var()
			file.close()
		text = str(int(record), "Pts")
