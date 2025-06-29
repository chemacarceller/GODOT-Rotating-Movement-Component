extends Node

func _ready() -> void:
	$"RigidBodies/Cube 1".apply_impulse(Vector3(3,9,2)) 
	$"RigidBodies/Cube 2".apply_impulse(Vector3(6,12,3)) 
	$"RigidBodies/Cube 3".apply_impulse(Vector3(9,15,4)) 
