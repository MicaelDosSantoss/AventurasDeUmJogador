extends Node2D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var vida = ScriptGlobal.qtd_vidas;
	
	if (vida == 3):
		$AnimationPlayer.play("Vida 3")
		
	if (vida == 2):
		$AnimationPlayer.play("Vida 2")
		
	if (vida == 1):
		$AnimationPlayer.play("Vida 1")
		
