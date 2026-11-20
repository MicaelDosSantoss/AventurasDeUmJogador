extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for node in get_tree().root.get_children():
		print(node.name, " -> ", node.get_path())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func voltar() -> void:
	get_tree().change_scene_to_file("res://Telas/Tela Principal/Tela_Principal.tscn")
