extends AnimationTree

func _process(_delta: float) -> void:
	var isWalking : bool = true if $"../BasicCharacterMovement".get_state() == $"../BasicCharacterMovement".MOVEMENT_STATE.WALKING else false
	var isRuning : bool = true if $"../BasicCharacterMovement".get_state() == $"../BasicCharacterMovement".MOVEMENT_STATE.RUNING else false
	var isIdle : bool = true if $"../BasicCharacterMovement".get_state() == $"../BasicCharacterMovement".MOVEMENT_STATE.IDLE else false
	var isJumping : bool = true if $"../BasicCharacterMovement".get_state() == $"../BasicCharacterMovement".MOVEMENT_STATE.JUMPING else false
	var isFalling : bool = true if $"../BasicCharacterMovement".get_state() == $"../BasicCharacterMovement".MOVEMENT_STATE.FALLING else false


	if get("parameters/conditions/idle") != isIdle :
		set("parameters/conditions/idle",  isIdle)
	if get("parameters/conditions/walk") != isWalking :
		set("parameters/conditions/walk",  isWalking)
	if get("parameters/conditions/run") != isRuning :
		set("parameters/conditions/run",  isRuning)
	if get("parameters/conditions/jump") != isJumping :
		set("parameters/conditions/jump",  isJumping)
	if get("parameters/conditions/fall") != isFalling :
		set("parameters/conditions/fall",  isFalling)
