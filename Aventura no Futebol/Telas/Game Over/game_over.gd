extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func reiniciar() -> void:
	$AudioStreamPlayer_Clique.play()
	ScriptGlobal.resetar_variaveis()
	get_tree().change_scene_to_file("res://cena_fase.tscn")

func desistir() -> void:
	$AudioStreamPlayer_Clique.play()
	ScriptGlobal.resetar_variaveis()
	get_tree().change_scene_to_file("res://Telas/Tela Principal/Tela_Principal.tscn")
