extends Node2D


func _ready() -> void:
	$AudioStreamPlayer_Boss.play()
	
func _process(delta: float) -> void:
	if ScriptGlobal.mensagem != false:
		$AudioStreamPlayer_Boss.stop()
