extends Node2D


func _ready() -> void:
	if ScriptGlobal.portao == false:
		$AudioStreamPlayer_Boss.play()
	else:
		$AudioStreamPlayer_Boss.stop()
