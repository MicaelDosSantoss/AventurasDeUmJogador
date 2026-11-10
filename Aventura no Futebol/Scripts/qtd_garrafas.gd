extends Node2D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var qtd_garrafas = ScriptGlobal.qtd_garrafas
	
	if (qtd_garrafas == 0):
		$AnimationPlayer.play("Garrafas (Sem nada)")
		
	if (qtd_garrafas == 1):
		$AnimationPlayer.play("Garrafas (1)")
		
	if (qtd_garrafas == 2):
		$AnimationPlayer.play("Garrafas (2)")
		
	if (qtd_garrafas == 3):
		$AnimationPlayer.play("Garrafas (3)")
