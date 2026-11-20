extends Node2D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$ParallaxBackground.scroll_base_offset.x -= 0.2


func passar_de_fase(body: Node2D) -> void:
	if(body.name == "Personagem"):
		get_tree().change_scene_to_file("res://Segunda_Fase/Fase_2.tscn")
