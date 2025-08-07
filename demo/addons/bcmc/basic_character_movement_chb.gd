@tool class_name BasicCharacterMovementComponent extends Node

# Basic Character Movement Component
#
# That is a Movement Component to be attached as a child to a Pawn, Character built as a CharacterBody3D
#
# The parent object (Character, Pawn) must have mandatory an Node3D Armature (MeshInstance3D, Skeleton3D) to be rotated
# and a Node3D (mostly a CameraController but not mandatory) that indicates the Character Forward Vector
# and should have a mass needed for the pushing action
#
# The Movement Component receives the left, right, front, rear, jump InputAction as String
# In an advanced version this could change
#
# This Basic component is based in three states idle, walk, and run with fixed exported speed constant
# The transitions between this states are blended with help of accelerationSpeed and decelerationSpeed (is in reality a time indicator)
# The transitions between walk and run are made by activating the flag _isRuning using the set_isRuning() method
#
# The armature rotates blended with help of trasitionSpeed ( is also a time indicator)
#
# It can also jump with a fixed constant exported value speed
#
# Gravity is also taken into account
#

# Movement state's options
enum MOVEMENT_STATE {
	IDLE,
	WALKING,
	RUNING,
	JUMPING,
	FALLING
}

# Different movement modes
# ONESPEED -> the character moves only with a speed it is the MAX_SPEER that correspon with RUN_SPEED
# The increase and decrease in speed is managed via the acceleration and deceleration, the acceleration should not be high, the deceleration can be high
# The animation should be done bia a blending Locomotion
# TWOSPEEDS -> there is a walk and run speed and can changed from one to another
# There is also the acceleration and deceleration parameter to be configured
enum MOVEMENT_MODE {
	ONESPEED,
	TWOSPEEDS
}



################################################################################################
#                               E X P O R T E D   V A R I A B L E S
################################################################################################


# Property to activate or deactivate the movement
## Property to activate or deactivate the movement
@export var isEnabled : bool = true :
	set (value):
		isEnabled=value
	get():
		return isEnabled

# Movement mode
## Movement mode
@export var movementMode : MOVEMENT_MODE = MOVEMENT_MODE.TWOSPEEDS :
	set (value) :
		movementMode = value
		notify_property_list_changed()
	get() :
		return movementMode



@export_group("Character settings")

# Specifies the character mass for calculating the impulse force
## Specifies the character mass for calculating the impulse force
@export_range(25,150) var characterMass : float = 75.0 :
	set (value):
		characterMass=value
	get():
		return characterMass

# Specifies the characterForceFactor for calculating the impulse force, how strong is the character
## Specifies the characterForceFactor for calculating the impulse force, how strong is the character
@export_range(0.1,10) var characterForceFactor : float = 1 :
	set (value):
		characterForceFactor=value
	get():
		return characterForceFactor



# Exported variables Inputs as public accessed with properties set/get methods
@export_group("Components and properties")

# Armature is used to rotate the character but not the camera
## A Node3D that represents ths mesh to be rotated by this movement component
@export var armature : Node3D = null:
	set (value):
		armature=value
	get():
		return armature


# DirectionalObject is to set the Forward Direction
## A Node3D that indicates que forward vector for the movement component
@export var directionalObject : Node3D = null:
	set (value):
		directionalObject=value
	get():
		return directionalObject


# The list of collisionHulls of the character so that they are also rotated when the armature is totated.
## The list of collisionHulls of the character so that they are also rotated when the armature is totated.
@export var collisionHullsArray : Array[CollisionShape3D] = []

# Internal variable storing the offsets of each collision shape relative to the armature, calculated in _ready()
var _collisionHullsArrayOffset : Array[float] = []



@export_group("Input actions setting")

# Left movement input action
## Left movement input action
@export var leftInput : String = "":
	set (value):
		leftInput=value
	get():
		return leftInput

# Indicates when the pawn turns left if it should rotate
## Indicates when the pawn turns left if it should rotate
@export var leftRotationEnabled : bool = true


# Right movement input action
## Right movement input action
@export var rightInput : String = "":
	set (value):
		rightInput=value
	get():
		return rightInput

# Indicates when the pawn turns right if it should rotate
## Indicates when the pawn turns right if it should rotate
@export var rightRotationEnabled : bool = true


# Front movement input action
## Front movement input action
@export var frontInput : String = "":
	set (value):
		frontInput=value
	get():
		return frontInput

# Indicates when the pawn turns front if it should rotate
## Indicates when the pawn turns front if it should rotate
@export var frontRotationEnabled : bool = true


# Rear movement input action
## Rear movement input action
@export var rearInput : String = "":
	set (value):
		rearInput=value
	get():
		return rearInput

# Indicates when the pawn turns rear if it should rotate
## Indicates when the pawn turns rear if it should rotate
@export var rearRotationEnabled : bool = true


# Jump input action
## Jump input action
@export var jumpInput : String = "":
	set (value):
		jumpInput=value
	get():
		return jumpInput



@export_group("Transition speed settings")

var _accelerationTime : float
# How fast the character increases speed in m/seg
## How fast the character increases speed in m/seg
@export_range (0.1,30) var accelerationSpeed : float = 15.0:
	set (value):
		accelerationSpeed=value
		if get_isRuning() :
			_accelerationTime = RUN_SPEED / accelerationSpeed
		else :
			_accelerationTime = WALK_SPEED / accelerationSpeed
	get():
		return accelerationSpeed


var _decelerationTime : float
# How fast the character reduces speed in m/seg
## How fast the character reduces speed in m/seg
@export_range (0.1,30) var decelerationSpeed : float = 15.0:
	set (value):
		decelerationSpeed=value
		if get_isRuning() :
			_decelerationTime = RUN_SPEED / decelerationSpeed
		else :
			_decelerationTime = WALK_SPEED / decelerationSpeed

	get():
		return decelerationSpeed


# How fast the character changes direction in seg
## How fast the character changes direction in seg
@export_range (0.01,1) var transitionTime : float = 0.25:
	set (value):
		transitionTime=value
	get():
		return transitionTime



# Exported variables Speeds
@export_group("Speed settings")

# WALK SPEED
## WALK SPEED
@export_range(1,4) var WALK_SPEED : float = 3.0:
	set (value):
		WALK_SPEED=value
	get():
		return WALK_SPEED


# RUN SPEED
## RUN SPEED
@export_range(1,15) var RUN_SPEED : float = 6.0:
	set (value):
		RUN_SPEED=value
	get():
		return RUN_SPEED


# MAX SPEED used in mode ONESPEED
## MAX SPEED used in mode ONESPEED
@export_range(1,15) var MAX_SPEED : float = 10.0:
	set (value):
		MAX_SPEED=value
		RUN_SPEED=MAX_SPEED
		set_isRuning(true)
	get():
		return MAX_SPEED

# JUMP SPEED
## JUMP SPEED
@export_range(1,6) var JUMP_VELOCITY : float = 4.2:
	set (value):
		JUMP_VELOCITY=value
	get():
		return JUMP_VELOCITY


# Speed is reducing by jumping, the speed during jumping is multiply by this factor
## Speed is reducing by jumping, the speed during jumping is multiply by this factor
@export_range(0,1) var SPEED_KEPT_BY_JUMPING : float = 0.4:
	set (value):
		SPEED_KEPT_BY_JUMPING=value
	get():
		return SPEED_KEPT_BY_JUMPING


# Speed is reducing by falling, the speed during falling is multiply by this factor
## Speed is reducing by falling, the speed during falling is multiply by this factor
@export_range(0,1) var SPEED_KEPT_BY_FALLING : float = 0.4:
	set (value):
		SPEED_KEPT_BY_FALLING=value
	get():
		return SPEED_KEPT_BY_FALLING



@export_group("Pushing settings")

# The lowest value calculated for the massRatio between character and pushing object
## The lowest value calculated for the massRatio between character and pushing object
@export_range(0.1,1) var minMassRatioAllowed : float = 0.5:
	set (value):
		minMassRatioAllowed=value
	get():
		return minMassRatioAllowed


# The highest value calculated for the massRatio between character and pushing object
## The highest value calculated for the massRatio between character and pushing object
@export_range(1,100) var maxMassRatioAllowed : float = 30 :
	set (value):
		maxMassRatioAllowed=value
	get():
		return maxMassRatioAllowed




# ======================================================================================
# Private variables (underscored)
# ======================================================================================


# _myCharacter without access outside because is the ParentActor
@onready var _myCharacter : CharacterBody3D = get_parent()


# State of the Character's movement used typically in animation tree
var _state : MOVEMENT_STATE = MOVEMENT_STATE.IDLE


# _speed accesible from outside get and set method
# The _oldSpeed is the speed before a speed change, it is used to know the difference in a speed change for the right transition time
var _oldSpeed : float = 0.0
@onready var _speed : float = RUN_SPEED if _isRuning else WALK_SPEED

# This variable indicates if we are in front of a direction change and the speed should be mantained
# Detected comparing previos direction with actual direction
# The changeDirection is disable when the character stops, in this case the speed should be increased or reduced by the accelerationSpeed decelerationSpeed
var _changedDirection : bool = false

# Flags indicating different states of the movementcomponent
# _isRuning indicates if the character is running or not
# Two possibilities Runing or Walking
var _isRuning : bool = false


# Indicates if the character is moving or idle
var _isMoving : bool = true


# self-explanatory propertie
# _isPushing indicates it is pushing something not used as a movement state jet
var _isPushing : bool = false


# _isJumping indicates it is in the jumping process
var _isJumping : bool = false


# _Jumpkeypressed indicates that the jump key is pressed while on floor
var _JumpKeyPressed : bool = false


# _isFalling indicates it is in the falling process
var _isFalling : bool = false


# _idDoingRotation indicates it is doing the rotation
var _isDoingRotation : bool = false


# _inputDir : Vector generated from the inputs needed to character change
var _inputDir : Vector2 = Vector2.ZERO


# Flags indicating if the input actions exist
var _existFrontInput : bool = false
var _existRearInput : bool = false
var _existLeftInput : bool = false
var _existRightInput : bool = false
var _existJumpInput : bool = false

# Stores the actual and the previous direction, used to detect a direction change
var _direction : Vector3 = Vector3.ZERO
var _prevDirection : Vector3 = Vector3.ZERO



# ==========================================================================================
#
#  BUILT-IN FUNCTIONS
#
# ==========================================================================================

# When a close notification is received
func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		armature = null
		directionalObject = null
		_myCharacter = null


# BeginPlay funciton
func _ready() -> void:

	# Warning message if the armature is null, continues without rotation
	if (armature == null):
		print("BasicCharacterMovement : The Parent class " + _myCharacter.name + " doesn't have specified the armature component")

	# Warning message if the directionalObject is not specified, in this case the Character itself is taken
	if (directionalObject == null):
		print("BasicCharacterMovement : The Parent class " + _myCharacter.name + " doesn't have specified the directionalObject component")

	# The has_action doesnt work loop to detect if the actions exist or not
	for action in InputMap.get_actions():
		if frontInput == action.get_basename():
			_existFrontInput = true
		if rearInput == action.get_basename():
			_existRearInput = true
		if leftInput == action.get_basename():
			_existLeftInput = true
		if rightInput == action.get_basename():
			_existRightInput = true
		if jumpInput == action.get_basename():
			_existJumpInput = true

	# Calculated the offsets of each collision shape relative to the armature used for the rotation of collision shapes
	for collisionHull in collisionHullsArray :
		_collisionHullsArrayOffset.append(abs(Vector3(collisionHull.position.x - armature.position.x,0,collisionHull.position.z - armature.position.z).length()))

	# Setting the initial value of the parameters that have code so that the code to be executed
	set_accelerationSpeed(get_accelerationSpeed())
	set_decelerationSpeed(get_decelerationSpeed())
	if movementMode == MOVEMENT_MODE.ONESPEED :
		MAX_SPEED = MAX_SPEED


# Processes every physics frame
# Calculating the movement
func _physics_process(delta: float) -> void:

	# _rotationAngle : Angle to rotate the armature
	var _rotationAngle : float 
	
	# Only if it is enabled
	if isEnabled and _myCharacter != null:

		# Establishing normalized direction of movement
		if not _existLeftInput or not _existRightInput:
			if _existFrontInput and _existRearInput :
				# Only front and rear direction
				_inputDir = Vector2.DOWN * Input.get_axis(frontInput, rearInput)
			else:
				if _existFrontInput :
					_inputDir = -Vector2.DOWN * Input.get_action_strength(frontInput)
				else :
					# None direction
					_inputDir = Vector2.ZERO
		elif not _existFrontInput or not _existRearInput :
			# Only left and right direction
			_inputDir = Vector2.DOWN * Input.get_axis(leftInput, rightInput)
		else:
			# All directions
			_inputDir = Input.get_vector(leftInput, rightInput, frontInput, rearInput)

		# if there is no directionalObject defined we take the Character itself
		_direction = directionalObject.transform.basis * Vector3(_inputDir.x, 0, _inputDir.y).normalized() if directionalObject != null else _myCharacter.transform.basis * Vector3(_inputDir.x, 0, _inputDir.y).normalized()

		
		# The direction change is detected when direction and previousdirection are different and it doesnt comes from being stopped
		if _direction != _prevDirection and _prevDirection != Vector3.ZERO:
			_changedDirection = true
		else :
			_prevDirection = _direction
			
		
		# Add the gravity for fall movement when detecting is not on floor
		if not _myCharacter.is_on_floor() and not _JumpKeyPressed:
			_myCharacter.velocity += _myCharacter.get_gravity() * delta
			_isFalling = true
		else:
			_isFalling = false
			# By ending the falling state we retrieve the previous movement state
			if _isMoving:
				_state = MOVEMENT_STATE.RUNING if _isRuning else MOVEMENT_STATE.WALKING
			else:
				_state = MOVEMENT_STATE.IDLE
			

		# Handling jump. We can only jump if we are on floor
		if _existJumpInput:
			if Input.is_action_just_pressed(jumpInput) and _myCharacter.is_on_floor():
				_myCharacter.velocity.y = JUMP_VELOCITY
				_JumpKeyPressed = true
				_isJumping = true
			else :
				if _myCharacter.is_on_floor():
					_isJumping = false
				_JumpKeyPressed = false
				# By ending the jumping state we retrieve the previous movement state
				if _isMoving:
					_state = MOVEMENT_STATE.RUNING if _isRuning else MOVEMENT_STATE.WALKING
				else:
					_state = MOVEMENT_STATE.IDLE

		# Changing the movement state when falling. It must be set here bacause if not by falling and walking/runing
		# doesnt return to walking/runing
		if _isFalling :
			_state = MOVEMENT_STATE.FALLING

		if _isJumping :
			_state = MOVEMENT_STATE.JUMPING

		# If inputs are present, that means if a movement direction is set
		if _direction :

			#setting true the isMoving flag to indicate we are moving
			set_isMoving(true)

			# Establishing rotation of the armature
			_rotationAngle = atan2(_direction.z,_direction.x)+PI/2

			# The condition is to avoid crashing when the armature is not defined no movement is made
			# _offset is the amount to rotate in the scope of 0 and 2*PI
			var _offset : float = armature.rotation.y + _rotationAngle  if armature != null  else 0.0
			if _offset >= 2*PI:
				_offset -= 2*PI

			# Calling corroutine to make a blend in rotation inside the _rotateArmature
			# If rotation offset is abova 1%, less than 1% doesnt call _rotateArmature
			if not _isDoingRotation and abs(_offset)>PI/18000 and armature != null:
				if (_inputDir == Vector2(-1,0) and leftRotationEnabled) or (_inputDir == Vector2(1,0) and rightRotationEnabled) or (_inputDir == Vector2(0,-1) and frontRotationEnabled) or (_inputDir == Vector2(0,1) and rearRotationEnabled) :
					_rotateArmature(armature, -armature.rotation.y, _rotationAngle, delta)
			
			# Calculate the _speed it should move, only made once if there is a speed change
			# Kept the previous speed to calculate the diference for speed transitions
			if (_speed != RUN_SPEED) and _isRuning:
				_oldSpeed = _speed
				_speed = RUN_SPEED
			elif (_speed != WALK_SPEED) and not _isRuning:
				_oldSpeed = _speed
				_speed = WALK_SPEED

			# By falling or jumping the _speed must be adjusted, only made once
			# Kept the previous speed to calculate the diference for speed transitions
			if (_isFalling):
				if (_isRuning) and _speed != RUN_SPEED * SPEED_KEPT_BY_FALLING :
					_oldSpeed = _speed
					_speed = RUN_SPEED * SPEED_KEPT_BY_FALLING
				elif (not _isRuning) and _speed != WALK_SPEED * SPEED_KEPT_BY_FALLING :
					_oldSpeed = _speed
					_speed = WALK_SPEED * SPEED_KEPT_BY_FALLING
			elif (_JumpKeyPressed):
				if (_isRuning) and _speed != RUN_SPEED * SPEED_KEPT_BY_JUMPING :
					_oldSpeed = _speed
					_speed = RUN_SPEED * SPEED_KEPT_BY_JUMPING
				elif (not _isRuning) and _speed != WALK_SPEED * SPEED_KEPT_BY_JUMPING :
					_oldSpeed = _speed
					_speed = WALK_SPEED * SPEED_KEPT_BY_JUMPING

			# Speed to arrive when moving taken into account the direction
			var _finalSpeed : Vector3 = _direction * _speed

			# until the finalSpeed is arrived we increment the character's velocity by a step depending on diference between speeds and the accelerationSpeed in seg independently from the pc characteristics (delta)
			if (_myCharacter.velocity !=_finalSpeed) :

				# If a changedDirection is detected and not is falling and not is jumping the velocity is set to the real speed so that it is not reduced or incremented via the accelerationSpeed or decelerationSpeed
				# After that the bool variable changeDirection is set to false
				if _changedDirection and not _isJumping and not _isFalling:
					_myCharacter.velocity = _direction * _speed
					_changedDirection = false

				# Doing the speed increment via the accelerationSpeed
				_myCharacter.velocity.x = move_toward(_myCharacter.velocity.x, _finalSpeed.x, delta * abs(_speed - _oldSpeed) / _accelerationTime)
				_myCharacter.velocity.z = move_toward(_myCharacter.velocity.z, _finalSpeed.z, delta * abs(_speed - _oldSpeed) / _accelerationTime)

		else:

			# When there is no input the speed is set to 0.0, only made once
			# Kept the previous speed to calculate the diference for speed transitions
			if _speed != 0.0 :
				_oldSpeed = _speed
				_speed = 0.0

			# Deceleration when there is no input
			# We arrive the zero velocity by a factor of decelerationSpeed seconds
			
			if (_myCharacter.velocity != Vector3.ZERO) :
				# The speed is decrease via the decelerationSpeed
				_myCharacter.velocity.x = move_toward(_myCharacter.velocity.x, 0, delta * abs(_speed - _oldSpeed)  / _decelerationTime)
				_myCharacter.velocity.z = move_toward(_myCharacter.velocity.z, 0, delta * abs(_speed - _oldSpeed) / _decelerationTime)
			else:
				# Seting the previous direction that is Vector3.ZERO
				_prevDirection = _direction
				
				# If bu decreasing the speed it arrives zero (it stops) the change direction flag is disabled
				_changedDirection = false
				
				# Setting to false the ismoving flag to indicate that there is no movement
				set_isMoving(false)
				if not _isFalling and not _isJumping:
					_state = MOVEMENT_STATE.IDLE

		# To avoid a weird reaction on character when pushes light objects i lock the y position
		# when there is no need to move character up
		# May be there is another way to avoid that, i dont know
		if _isJumping or _isFalling or _myCharacter.get_floor_angle() > 0:
			_myCharacter.axis_lock_linear_y = false
		else :
			_myCharacter.axis_lock_linear_y = true

		# Doing the movement
		# Using the method move_and_slide from CharacterBody3D node
		if _myCharacter.move_and_slide() :
			# If there is a collission we push the rigidbodies involved in the collision
			_pushAwwayRigidbody()



# ===================================================================================================
#
#   HELPING FUNCTIONS
#
# ===================================================================================================

func _rotateArmature(armatureComponent : Node3D, oldRotationAngle : float, newRotationAngle : float, delta : float) -> void:

	# How much it must rotate in each frame is between 0 and 1
	var _step : float = delta / transitionTime

	# We check the doingRotation flag once the rotateArmature movement begins
	_isDoingRotation = true

	# clamping rotations between -PI and PI
	if (oldRotationAngle > PI):
		oldRotationAngle = oldRotationAngle - 2*PI
	if (oldRotationAngle < -PI):
		oldRotationAngle = oldRotationAngle + 2*PI
	if (newRotationAngle > PI):
		newRotationAngle = newRotationAngle - 2*PI
	if (newRotationAngle < -PI):
		newRotationAngle = newRotationAngle + 2*PI

	# Adjusting rotations to take the shortest way
	if abs(newRotationAngle - oldRotationAngle) > PI:
		if oldRotationAngle > 0:
			oldRotationAngle = oldRotationAngle - 2*PI
		else:
			oldRotationAngle = oldRotationAngle + 2*PI

	# Loop until get the last value of the lerp
	while (_step < 1):

		# if the Character changes the coroutine stops
		if not is_inside_tree():
			# Breaking the loop to be able to change the _isDoingRotation flag
			break

		# Rotation to apply in this frame
		var x : float = lerp(oldRotationAngle,newRotationAngle, _step)
		armatureComponent.rotation.y=-x

		# Also the shapes indicated must be rotated
		var index : int = 0
		for collisionHull in collisionHullsArray :
			# The position of the shape calculation
			collisionHull.position = -armatureComponent.basis.z.normalized() * _collisionHullsArrayOffset[index] + Vector3(0,collisionHull.position.y,0)
			# The rotation of the shape calculation
			collisionHull.rotation.y = -x
			index += 1

		# As it is used lerp the _step must be increased for the next frame
		_step += delta / transitionTime

		# Corroutine stoping function when frame's end comes
		await  get_tree().physics_frame

	# Now i can make another rotation move
	_isDoingRotation = false


# This function detects a collision and push the rigidbodies involved
func _pushAwwayRigidbody() -> void :
	
	# the flag _isPushing is useful for the character's animations
	_isPushing = false

	# When there is a collision
	for i in _myCharacter.get_slide_collision_count():

		# Which actors are involved in the collision
		var c = _myCharacter.get_slide_collision(i)

		# if the actor is a rigidbody
		if c.get_collider() is RigidBody3D:

			# we get the direction for pushing using the normal to the colliding body
			var pushDir = -c.get_normal()

			# Ratio between the Character mass and the colliding body mass with a minimum and a maximum
			var massRatio : float = max(minMassRatioAllowed, characterMass / c.get_collider().mass)
			massRatio = min(massRatio, maxMassRatioAllowed)

			# Calculation the push force multiplying the massRatio by the characterForceFactor and the _speed
			var pushForce = massRatio * characterForceFactor

			# The force depends also from the speed by multiplying it
			pushForce *= _speed
			
			# The pushForce to be applied is calculated with the formula 
			# massRatio clamped * _speed (in m/sec) * characterForceFactor (how strong is the character)

			# Applying the impuls and setting the _isPushing flag
			c.get_collider().apply_impulse(pushDir.normalized() * pushForce, c.get_position() - c.get_collider().global_position)

			#Setting the _isPushing flag to true
			_isPushing = true



# PUBLIC API of this BasicCharacterComponent Getter and Setters methods
# Getters and setters method
# For the private variables it is used the traditional getter and setter methods instead
# of properties used for exported variables


# Returns the state of the character movement
func get_state() -> MOVEMENT_STATE:
	return _state


# methods to check, start and stop the movement. For example to make an animation that requires to stop the movement
func get_isMoving() -> bool :
	return _isMoving


func set_isMoving(value : bool) :
	_isMoving = value


func stop_movement() -> void:
	set_isMoving(false)


func start_movement() -> void:
	set_isMoving(true)


func get_speed() -> float:
	return _speed


func set_speed(value : float):
	_speed = value


func get_isRuning() -> bool:
	return _isRuning


func set_isRuning(value : bool):
	_isRuning = value
	set_accelerationSpeed(get_accelerationSpeed())
	set_decelerationSpeed(get_decelerationSpeed())
	if movementMode == MOVEMENT_MODE.ONESPEED :
		_isRuning = true


func get_isPushing() -> bool:
	return _isPushing


func set_isPushing(value : bool):
	_isPushing = value


func get_isFalling() -> bool:
	return _isFalling


func set_isFalling(value : bool):
	_isFalling = value


func get_isJumping() -> bool:
	return _isJumping


func set_isJumping(value : bool):
	_isJumping = value


func get_isDoingRotation() -> bool:
	return _isDoingRotation


func set_isDoingRotation(value : bool):
	_isDoingRotation = value


func get_inputDir() -> Vector2:
	return _inputDir


func set_inputDir(value : Vector2):
	_inputDir = value


func set_accelerationSpeed(value : float) :
	accelerationSpeed = value


func get_accelerationSpeed() -> float :
	return accelerationSpeed


func set_decelerationSpeed(value : float) :
	decelerationSpeed = value


func get_decelerationSpeed() -> float :
	return decelerationSpeed



# ===================================================================================================
#
#  CONTEXT FUNCTIONS
#
# ===================================================================================================

# Gets the basic character movement context to translate it to another same type movement
func get_context() -> BasicCharacterMovementData:
	var context = BasicCharacterMovementData.new()
	context.inputDir = get_inputDir()
	context.runing = get_isRuning()
	context.isPushing = get_isPushing()
	context.isFalling = get_isFalling()
	context.isJumping = get_isJumping()
	return context


# Sets the basic character movement context to translate it to another same type movement
func set_context(context : BasicCharacterMovementData):
	set_inputDir(context.inputDir)
	set_isRuning(context.runing)
	set_isPushing(context.isPushing)
	set_isJumping(context.isJumping)
	set_isFalling(context.isFalling)



# This function is used so that the editor's options
func _validate_property(property: Dictionary):
	if property.name in "WALK_SPEED" and movementMode != MOVEMENT_MODE.TWOSPEEDS :
		property.usage = PROPERTY_USAGE_NO_EDITOR
	if property.name in "RUN_SPEED" and movementMode != MOVEMENT_MODE.TWOSPEEDS :
		property.usage = PROPERTY_USAGE_NO_EDITOR
	if property.name in "MAX_SPEED" and movementMode != MOVEMENT_MODE.ONESPEED :
		property.usage = PROPERTY_USAGE_NO_EDITOR
