extends Card
class_name ACard

func _ready():
	card_type = CardType.A
	rotation_degrees = Vector3(0, 0, 90)  # Make it vertical
	super._ready()

func attack(target):
	if can_act_this_turn:
		if target is DCard:
			# Remove defense
			var game_manager = get_node("/root/GameManager")
			game_manager.remove_card(target)
		elif target.current_state == CardState.ACTIVE:
			# Deal damage directly to HP
			target.hp -= 1
			if target.hp <= 0:
				var game_manager = get_node("/root/GameManager")
				game_manager.remove_card(target)
		
		can_act_this_turn = false

# A cards cannot split
func split():
	print("Attack cards cannot be split")

func update_visuals():
	mesh_instance.material_override.albedo_color = Color.RED
