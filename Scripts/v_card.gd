extends Area3D
class_name VCard

enum CardState { ACTIVE, INACTIVE }
var current_state = CardState.INACTIVE
var can_act_this_turn = false

# Use @onready to ensure proper initialization
@onready var mesh_instance = $MeshInstance3D

func _ready():
	update_visuals()

func on_turn_start():
	can_act_this_turn = true
	current_state = CardState.ACTIVE
	update_visuals()

func on_turn_end():
	can_act_this_turn = false
	update_visuals()

func convert_to_a():
	if can_act_this_turn:
		# This should call a function in GameManager to convert this card
		pass

func convert_to_d():
	if can_act_this_turn:
		# This should call a function in GameManager to convert this card
		pass

func update_visuals():
	# Safety check
	if mesh_instance == null:
		push_error("MeshInstance3D not found in VCard!")
		return
	
	if current_state == CardState.ACTIVE:
		mesh_instance.material_override.albedo_color = Color.WHITE
	else:
		mesh_instance.material_override.albedo_color = Color.GRAY  # Fixed typo
