extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var volume = AudioServer.get_bus_index("Master")
	ScriptGlobal.musica_ligada = $CheckButton_Musica.button_pressed
	AudioServer.set_bus_mute(volume, ScriptGlobal.musica_ligada)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$CheckButton_Keyboard.button_pressed = ScriptGlobal.keyboard_visible

func voltar() -> void:
	$AudioStreamPlayer_Clique.play()
	get_tree().change_scene_to_file("res://Telas/Tela Principal/Tela_Principal.tscn")

func silenciar() -> void:
	$AudioStreamPlayer_Clique.play()
	var volume = AudioServer.get_bus_index("Master")
	ScriptGlobal.musica_ligada = $CheckButton_Musica.button_pressed
	AudioServer.set_bus_mute(volume, ScriptGlobal.musica_ligada)

func Keyboard() -> void:
	$AudioStreamPlayer_Clique.play()
	ScriptGlobal.keyboard_visible = $CheckButton_Keyboard.button_pressed
	print(ScriptGlobal.keyboard_visible)
