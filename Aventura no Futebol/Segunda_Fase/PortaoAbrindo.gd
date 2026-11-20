extends StaticBody2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$AnimationPlayer.play("Portão meio aberto")


func vitoria_do_jogador(body: Node2D) -> void:
	if(body.name == "Personagem"):
		get_tree().change_scene_to_file("res://Telas/Vitoria/Vitoria.tscn")
