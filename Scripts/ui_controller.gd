extends Control
class_name UIController

@onready var game_manager = get_node("/root/Main/GameManager")

# Preload the card script to use with 'is' comparison
var VCardClass = preload("res://Scripts/v_card.gd")

# Button handlers
func _on_split_button_pressed():
	if game_manager and game_manager.selected_card != null:
		if game_manager.selected_card is VCard:
			game_manager.selected_card.split()

func _on_convert_to_a_button_pressed():
	if game_manager and game_manager.selected_card != null:
		if game_manager.selected_card is VCard:
			game_manager.convert_card_to_a(game_manager.selected_card)

func _on_convert_to_d_button_pressed():
	if game_manager and game_manager.selected_card != null:
		if game_manager.selected_card is VCard:
			game_manager.convert_card_to_d(game_manager.selected_card)

func _on_end_turn_button_pressed():
	if game_manager:
		game_manager.end_turn()

# Update UI based on selected card
func update_ui_for_selected_card(card):
	if card != null and card is VCard:
		# Show buttons for V cards
		$SplitButton.visible = true
		$ConvertToAButton.visible = true
		$ConvertToDButton.visible = true
	else:
		# Hide buttons for non-V cards
		$SplitButton.visible = false
		$ConvertToAButton.visible = false
		$ConvertToDButton.visible = false

# Update turn indicator
func update_turn_indicator(is_player_turn):
	if is_player_turn:
		$TurnLabel.text = "Your Turn"
		$TurnLabel.modulate = Color.GREEN
	else:
		$TurnLabel.text = "Enemy Turn"
		$TurnLabel.modulate = Color.RED

# Show game over screen
func show_game_over(player_won):
	$GameOverPanel.visible = true
	if player_won:
		$GameOverPanel/WinLabel.text = "You Win!"
	else:
		$GameOverPanel/WinLabel.text = "You Lose!"
		
	# Hide action buttons
	$SplitButton.visible = false
	$ConvertToAButton.visible = false
	$ConvertToDButton.visible = false
	$EndTurnButton.visible = false

func _on_restart_button_pressed():
	if game_manager:
		game_manager.restart_game()
	$GameOverPanel.visible = false
	$EndTurnButton.visible = true
