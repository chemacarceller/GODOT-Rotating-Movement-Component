class_name RotatingMovementComponent extends Node


# Property to activate or deactivate the movement
@export var _isEnabled : bool = true

func set_IsEnabled(value : bool) -> void :
	_isEnabled = value

func get_IsEnebled() -> bool :
	return _isEnabled

# Exported variables of the MovementComponent
## Rotating vector
@export var rotatingVector : Vector3 = Vector3.ZERO :
	set(value):
		rotatingVector = value
		if value != Vector3.ZERO:
			_rotatingVectorNormalized = value.normalized()
var _rotatingVectorNormalized : Vector3 = Vector3.ZERO

## Speed in rpm (revolutions per minute)
@export var speed : float = 0.0 :
	set(value):
		speed = value
		_speed = value * PI /30
var _speed : float = 0.0

# Internal variables
# Getting the ParentActor
@onready var _parentActor : Node3D = get_parent()

# the movement code
func _physics_process(delta: float) -> void:
	# Only if it is enabled
	if _isEnabled :
		var angle = _speed * delta
		if (angle > 2*PI):
			angle -= 2*PI
		_parentActor.rotate(_rotatingVectorNormalized, _speed*delta)
