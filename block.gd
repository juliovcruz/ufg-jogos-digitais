extends RigidBody2D
class_name MovableBlock

var speed = 200

func _ready():
	lock_rotation = true
	angular_damp = 100.0
	mass = 1.0 # Ajuste a massa do bloco para torná-lo mais leve
	linear_damp = 0.0 # Ajuste o amortecimento linear para controlar o quão rápido o bloco para de se mover
	

func _process(delta):
	pass
	
