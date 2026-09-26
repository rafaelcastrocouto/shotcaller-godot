extends CanvasLayer

@onready var circle_transition_scene : PackedScene = preload("res://ui/transitions/circle_transition.tscn")
@onready var square_transition_scene : PackedScene = preload("res://ui/transitions/square_transition.tscn")
@onready var campaign_intro_scene : PackedScene = preload("res://ui/transitions/campaign_intro.tscn")

@onready var game = get_tree().get_current_scene()

signal transition_completed

var intro_ended = false
var intro_text:Control

func start():
	#var transition = random()
	if game.map_manager.current_map == "campaign_map" and intro_ended:
		intro()
	else:
		transition()


func transition():
	var transition = circle_transition_scene.instantiate()
	add_child(transition)
	transition.transition_completed.connect(on_transition_end.bind(transition))


func intro():
	var intro = campaign_intro_scene.instantiate()
	add_child(intro)
	intro_text = intro
	intro.intro_completed.connect(intro_end)

func intro_end():
	intro_ended = true
	transition()
	

func on_transition_end(transition = null):
	# clears transition
	if transition: transition.queue_free()
	
	if game.map_manager.current_map == "campaign_map" and !intro_ended:
		intro()
	else:
		if intro_text: intro_text.queue_free()
		emit_signal("transition_completed")


func random():
	return [square_transition_scene, circle_transition_scene][randi() % 2].instantiate()
