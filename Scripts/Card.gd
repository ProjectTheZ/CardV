extends Area3D
class_name Card

enum CardState { ACTIVE, INACTIVE }
enum CardType { V, A, D }

var current_state = CardState.INACTIVE
var hp = 1
var can_act_this_turn = false
var card_type = CardType.V

# References
@onready var mesh_instance = $MeshInstance3D

func _ready():
	update_visuals()

func on_turn_start():
	can_act_this_turn = true

func on_turn_end():
	can_act_this_turn = false

func split():
	if can_act_this_turn and current_state == CardState.ACTIVE:
		# Create two new V cards
		var game_manager = get_node("/root/GameManager")
		game_manager.create_v_card(global_position + Vector3.LEFT * 0.5)
		game_manager.create_v_card(global_position + Vector3.RIGHT * 0.5)
		
		# Remove this card
		game_manager.remove_card(self)

func update_visuals():
	# Base implementation - override in child classes
	pass

func _on_input_event(_camera, event, _position, _normal, _shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var game_manager = get_node("/root/GameManager")
		game_manager.card_clicked(self)
