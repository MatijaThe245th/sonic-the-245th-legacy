extends Control

@onready var options = $"../Options"
@onready var checkbox = $"../Options/MarginContainer/HBoxContainer/VBoxContainer/CheckBox"
@onready var d_pad = $"../../../HUD SubViewportContainer/HUD SubViewport/D-Pad"
@onready var a_button = $"../../../HUD SubViewportContainer/HUD SubViewport/A Button"
@onready var pause_button = $"../../../HUD SubViewportContainer/HUD SubViewport/Pause Button"
@onready var fps = $"../../../HUD SubViewportContainer/HUD SubViewport/HUD/CanvasLayer/FPS"
@onready var variables_left = $"../../../HUD SubViewportContainer/HUD SubViewport/HUD/CanvasLayer/Variables (Left)"
@onready var variables_right = $"../../../HUD SubViewportContainer/HUD SubViewport/HUD/CanvasLayer/Variables (Right)"
@onready var resume = $MarginContainer/VBoxContainer/Resume
@onready var options_button = $MarginContainer/VBoxContainer/Options
@onready var quit = $MarginContainer/VBoxContainer/Quit
@onready var hud_subviewport_container = $"../../../HUD SubViewportContainer"

var paused: int = 0


func _process(_delta):
	pause()


func pause():
	if Input.is_action_just_pressed("pause"):
		if paused == 0:
			paused = 1
			resume.grab_focus()
			hud_subviewport_container.scale.x = 0
			hud_subviewport_container.scale.y = 0
		elif visible == true:
			paused = 0
			hud_subviewport_container.scale.x = 5
			hud_subviewport_container.scale.y = 5
	if paused == 1:
		get_tree().paused = true
		if options.visible == false:
			visible = true
			if !resume.has_focus() and !options_button.has_focus() and !quit.has_focus():
				resume.grab_focus()
	else:
		get_tree().paused = false
		visible = false
	if paused == 1:
		d_pad.visible = false
		a_button.visible = false
		fps.visible = false
		pause_button.visible = false
		variables_left.visible = false
		variables_right.visible = false
	else:
		d_pad.visible = true
		a_button.visible = true
		fps.visible = true
		pause_button.visible = true
		variables_left.visible = true
		variables_right.visible = true


func _on_resume_pressed():
	paused = 0
	hud_subviewport_container.scale.x = 5
	hud_subviewport_container.scale.y = 5


func _on_options_pressed():
	visible = false
	options.visible = true
	checkbox.grab_focus()


func _on_quit_pressed():
	get_tree().quit()
