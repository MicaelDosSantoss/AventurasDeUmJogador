extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AudioStreamPlayer_Vitoria.play()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func voltar() -> void:
	$AudioStreamPlayer_Clique.play()
	get_tree().change_scene_to_file("res://Telas/Tela Principal/Tela_Principal.tscn")
