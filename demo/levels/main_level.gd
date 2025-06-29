extends Node

@export var character : PackedScene

var _character : CharacterBody3D = null

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	_character = character.instantiate()
	_character.position = Vector3(11,3,3)
	add_child(_character)
	

func _unhandled_input(event) :
	if event is InputEventKey and event.pressed :
		match event.keycode :
			KEY_ESCAPE :
				get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
				get_tree().quit()
