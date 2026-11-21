extends StaticBody2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AnimationPlayer.play("Animacao_padrao")
	$Mensagem_Primeira.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func mensagem(body: Node2D) -> void:
	print(ScriptGlobal.mensagem)
	if(ScriptGlobal.mensagem == false):
		$Mensagem_Primeira.visible = true
		$Mensagem_Segunda.visible = false
		
	else:
		$Mensagem_Primeira.visible = false
		$Mensagem_Segunda.visible = true

func sair_mensagem(body: Node2D) -> void:
	$Mensagem_Primeira.visible = false
	$Mensagem_Segunda.visible = false
