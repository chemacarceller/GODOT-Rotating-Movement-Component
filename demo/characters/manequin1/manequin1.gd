extends CharacterBody3D

var rotationSensitivity : float = 1.5

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		$SpringArm3D.rotation.y = $SpringArm3D.rotation.y - event.relative.x /1000 * rotationSensitivity

	# If move_run action changes, the runing variable of the movement modified
	if Input.is_action_pressed("move_run_change"):
		$BasicCharacterMovement.set_isRuning(not $BasicCharacterMovement.get_isRuning())
	elif Input.is_action_pressed("move_run_continuos"):
		$BasicCharacterMovement.set_isRuning(true)
	elif Input.is_action_just_released("move_run_continuos"):
		$BasicCharacterMovement.set_isRuning(false)
