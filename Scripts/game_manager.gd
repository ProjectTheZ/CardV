extends Node3D
class_name GameManager

# Preload card scenes
const V_CARD_SCENE = preload("res://Scenes/v_card.tscn")
const A_CARD_SCENE = preload("res://Scenes/a_card.tscn")
const D_CARD_SCENE = preload("res://Scenes/d_card.tscn")

# Card references
var all_cards = []
var selected_card = null
var player_cards = []
var enemy_cards = []

# Game state
var current_turn = 0  # 0 for player, 1 for enemy
var game_started = false
var waiting_for_turn_end = false


# UI reference
@onready var ui_controller: UIController = $"../CanvasLayer/UiController"

# Board references
@onready var player_v_area = $"../Board/PlayerSide/VCardsArea"
@onready var player_frontline = $"../Board/PlayerSide/Frontline"
@onready var player_backline = $"../Board/PlayerSide/Backline"
@onready var enemy_v_area = $"../Board/EnemySide/VCardsArea"
@onready var enemy_frontline = $"../Board/EnemySide/Frontline"
@onready var enemy_backline = $"../Board/EnemySide/Backline"

# Card spacing
var card_spacing = 1.5

func _ready():
	# Initial game setup
	initialize_game()

func initialize_game():
	# Create initial cards for both players
	create_initial_cards(true)  # Player cards
	create_initial_cards(false) # Enemy cards
	
	# Start the first turn
	game_started = true
	start_next_turn()

func create_initial_cards(is_player):
	# Create initial V cards for both players
	for i in range(3):
		var x_pos = -2 + i * 2
		var z_pos = 3 if is_player else -3
		create_v_card(Vector3(x_pos, 0.5, z_pos), is_player)

func create_v_card(position, is_player):
	var new_card = V_CARD_SCENE.instantiate()
	add_child(new_card)
	new_card.global_position = position
	new_card.is_player_card = is_player
	
	# Add to appropriate lists
	all_cards.append(new_card)
	if is_player:
		player_cards.append(new_card)
		new_card.get_parent().remove_child(new_card)
		player_v_area.add_child(new_card)
	else:
		enemy_cards.append(new_card)
		new_card.get_parent().remove_child(new_card)
		enemy_v_area.add_child(new_card)
	
	# Position the card properly
	rearrange_cards(is_player, Card.CardType.V)
	
	return new_card

func convert_card_to_a(card):
	if not card is VCard:
		return null
		
	var position = card.global_position
	var is_player = card.is_player_card
	remove_card(card)
	
	var new_card = A_CARD_SCENE.instantiate()
	add_child(new_card)
	new_card.global_position = position
	new_card.is_player_card = is_player
	
	# Add to appropriate lists
	all_cards.append(new_card)
	if is_player:
		player_cards.append(new_card)
		new_card.get_parent().remove_child(new_card)
		player_frontline.add_child(new_card)
	else:
		enemy_cards.append(new_card)
		new_card.get_parent().remove_child(new_card)
		enemy_frontline.add_child(new_card)
	
	# Position the card properly
	rearrange_cards(is_player, Card.CardType.A)
	
	return new_card

func convert_card_to_d(card):
	if not card is VCard:
		return null
		
	var position = card.global_position
	var is_player = card.is_player_card
	remove_card(card)
	
	var new_card = D_CARD_SCENE.instantiate()
	add_child(new_card)
	new_card.global_position = position
	new_card.is_player_card = is_player
	
	# Add to appropriate lists
	all_cards.append(new_card)
	if is_player:
		player_cards.append(new_card)
		new_card.get_parent().remove_child(new_card)
		player_backline.add_child(new_card)
	else:
		enemy_cards.append(new_card)
		new_card.get_parent().remove_child(new_card)
		enemy_backline.add_child(new_card)
	
	# Position the card properly
	rearrange_cards(is_player, Card.CardType.D)
	
	return new_card

func remove_card(card):
	if all_cards.has(card):
		all_cards.erase(card)
	
	if player_cards.has(card):
		player_cards.erase(card)
		rearrange_cards(true, card.card_type)
	elif enemy_cards.has(card):
		enemy_cards.erase(card)
		rearrange_cards(false, card.card_type)
	
	card.queue_free()

func rearrange_cards(is_player, card_type):
	var cards_to_arrange = []
	var parent_node = null
	
	if is_player:
		match card_type:
			Card.CardType.V:
				cards_to_arrange = get_cards_of_type(player_cards, Card.CardType.V)
				parent_node = player_v_area
			Card.CardType.A:
				cards_to_arrange = get_cards_of_type(player_cards, Card.CardType.A)
				parent_node = player_frontline
			Card.CardType.D:
				cards_to_arrange = get_cards_of_type(player_cards, Card.CardType.D)
				parent_node = player_backline
	else:
		match card_type:
			Card.CardType.V:
				cards_to_arrange = get_cards_of_type(enemy_cards, Card.CardType.V)
				parent_node = enemy_v_area
			Card.CardType.A:
				cards_to_arrange = get_cards_of_type(enemy_cards, Card.CardType.A)
				parent_node = enemy_frontline
			Card.CardType.D:
				cards_to_arrange = get_cards_of_type(enemy_cards, Card.CardType.D)
				parent_node = enemy_backline
	
	if cards_to_arrange.size() > 0 and parent_node != null:
		# Calculate positions for each card
		var total_width = (cards_to_arrange.size() - 1) * card_spacing
		var start_x = -total_width / 2
		
		for i in range(cards_to_arrange.size()):
			var x_pos = start_x + i * card_spacing
			cards_to_arrange[i].position = Vector3(x_pos, 0.5, 0)

func get_cards_of_type(cards_list, card_type):
	var result = []
	for card in cards_list:
		if card.card_type == card_type:
			result.append(card)
	return result

func end_turn():
	if waiting_for_turn_end:
		return
		
	waiting_for_turn_end = true
	
	# End turn for all cards
	for card in all_cards:
		card.on_turn_end()
	
	# Switch turn
	current_turn = 1 if current_turn == 0 else 0
	
	# Start next turn after a delay
	await get_tree().create_timer(1.0).timeout
	start_next_turn()

func start_next_turn():
	waiting_for_turn_end = false
	
	# Start turn for all cards
	for card in all_cards:
		card.on_turn_start()
	
	# Update UI
	if ui_controller:
		ui_controller.update_turn_indicator(current_turn == 0)
	
	# If it's enemy's turn, perform AI actions
	if current_turn == 1:
		perform_enemy_turn()

func perform_enemy_turn():
	# Simple AI - convert V cards to A or D randomly and attack if possible
	for card in enemy_cards:
		if card is VCard and card.current_state == Card.CardState.ACTIVE:
			# Randomly convert to A or D
			if randf() > 0.5:
				convert_card_to_a(card)
			else:
				convert_card_to_d(card)
	
	# Wait a bit before attacking
	await get_tree().create_timer(1.0).timeout
	
	# Try to attack with all attack cards
	for card in enemy_cards:
		if card is ACard and card.can_act_this_turn:
			# Find a target
			var targets = get_attack_targets(false)
			if targets.size() > 0:
				var target = targets[0]  # Simple AI - attack first target
				card.attack(target)
				await get_tree().create_timer(0.5).timeout
	
	# Wait a bit before ending turn
	await get_tree().create_timer(1.0).timeout
	end_turn()

func get_attack_targets(is_player_attacking):
	var targets = []
	
	if is_player_attacking:
		# Player is attacking - target enemy defense cards first, then others
		var defense_cards = get_cards_of_type(enemy_cards, Card.CardType.D)
		if defense_cards.size() > 0:
			targets = defense_cards
		else:
			# No defense cards, target any active enemy cards
			for card in enemy_cards:
				if card.current_state == Card.CardState.ACTIVE:
					targets.append(card)
	else:
		# Enemy is attacking - target player defense cards first, then others
		var defense_cards = get_cards_of_type(player_cards, Card.CardType.D)
		if defense_cards.size() > 0:
			targets = defense_cards
		else:
			# No defense cards, target any active player cards
			for card in player_cards:
				if card.current_state == Card.CardState.ACTIVE:
					targets.append(card)
	
	return targets

func card_clicked(card):
	# Only allow interactions on player's turn
	if current_turn != 0:
		return
		
	if selected_card == null:
		# First card selected
		selected_card = card
		highlight_card(card, true)
		
		# Update UI based on selected card
		if ui_controller:
			ui_controller.update_ui_for_selected_card(card)
	else:
		# Second card selected - perform action
		perform_action(selected_card, card)
		
		# Remove highlight
		highlight_card(selected_card, false)
		selected_card = null
		
		# Reset UI
		if ui_controller:
			ui_controller.update_ui_for_selected_card(null)

func highlight_card(card, highlight):
	if highlight:
		# Create highlight effect - you can modify this based on your visual needs
		card.modulate = Color(1.2, 1.2, 1.2)  # Brighten the card
	else:
		card.modulate = Color(1, 1, 1)  # Reset to normal

func perform_action(card1, card2):
	if card1 is ACard:
		if card2 is DCard or card2.current_state == Card.CardState.ACTIVE:
			card1.attack(card2)
	# Add other interaction logic here as needed

# Check for win condition
func check_win_condition():
	if player_cards.size() == 0:
		# Player loses
		game_over(false)
	elif enemy_cards.size() == 0:
		# Player wins
		game_over(true)

func game_over(player_won):
	game_started = false
	
	# Show game over screen
	if ui_controller:
		ui_controller.show_game_over(player_won)

# Function to restart the game
func restart_game():
	# Clear all cards
	for card in all_cards.duplicate():
		remove_card(card)
	
	# Reset game state
	all_cards.clear()
	player_cards.clear()
	enemy_cards.clear()
	current_turn = 0
	selected_card = null
	
	# Reinitialize the game
	initialize_game()


func _on_end_turn_button_button_down() -> void:
	pass # Replace with function body.


func _on_split_button_button_down() -> void:
	pass # Replace with function body.


func _on_convert_to_a_button_pressed() -> void:
	pass # Replace with function body.


func _on_split_button_pressed() -> void:
	pass # Replace with function body.


func _on_end_turn_button_pressed() -> void:
	pass # Replace with function body.


func _on_convert_to_d_button_pressed() -> void:
	pass # Replace with function body.
