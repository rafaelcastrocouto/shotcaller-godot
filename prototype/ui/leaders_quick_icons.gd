extends VBoxContainer
var game:Node

# self = game.ui.leaders_icons

var built = false
var buttons_name = {}


var button_template:PackedScene = load("res://ui/buttons/order_button.tscn")

func _ready():
	game = get_tree().get_current_scene()
	hide()
	for placeholder in get_children():
		placeholder.hide()


func build():
	var index = 0
	var buttons_array = self.get_children()
	for leader in WorldState.get_state("player_leaders"):
		var button = buttons_array[index]
		buttons_name[leader.name] = button
		button.hpbar.show()
		button.name = leader.name
		index += 1
		button.hint.text = str(index)
		var player_team = WorldState.get_state("player_team")
		if player_team == "blue": button.sprite.material = null
		button.prepare(leader.display_name, player_team)
		button.show()
	self.built = true
	self.show()


func buttons_focus(leader):
	buttons_unfocus()
	if leader.name in buttons_name:
		buttons_name[leader.name].button_pressed = true


func buttons_unfocus():
	for all_leader_name in buttons_name: 
		buttons_name[all_leader_name].button_pressed = false


func button_down(index):
	var leader = WorldState.get_state("player_leaders")[index]
	if leader and leader.global_position.x > 0 and leader.global_position.y > 0:
		Crafty_camera.global_position = leader.global_position - Crafty_camera.offset
		game.selection.select_unit(leader)
		game.ui.leaders_icons.buttons_focus(leader)
