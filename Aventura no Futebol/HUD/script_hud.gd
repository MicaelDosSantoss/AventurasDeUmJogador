extends Node2D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var vida = ScriptGlobal.qtd_vidas;
	var keyboard_visible = ScriptGlobal.keyboard_visible
	$ParallaxBackground/Sprite2D.visible = keyboard_visible
