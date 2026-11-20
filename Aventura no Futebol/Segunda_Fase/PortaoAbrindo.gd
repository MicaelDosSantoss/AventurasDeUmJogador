extends StaticBody2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AnimationPlayer.play("Portão meio aberto")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if ScriptGlobal.portao != false:
		ScriptGlobal.portao = false
		$AudioStreamPlayer.play()
		$AnimationPlayer.play("Portão Abrindo")
		$AudioStreamPlayer.stop()

func vitoria_do_jogador(body: Node2D) -> void:
	if(body.name == "Personagem"):
		get_tree().change_scene_to_file("res://Telas/Vitoria/Vitoria.tscn")
