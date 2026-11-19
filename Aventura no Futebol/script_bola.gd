extends CharacterBody2D

var direcao    = 1 #  1 => Direita, -1 => Esquerda
var velocidade = 350

func _process(delta: float) -> void:
	velocity.x = velocidade * direcao
	velocity.y = 0
	move_and_slide()
	
func Dano_inimigo(body: Node2D) -> void:
	
	if( body.name == 'Coletavel (Municao)'):
		print("Pegou o Coletavel...")
		ScriptGlobal.qtd_municao += 3
		
	if( body.name == 'Coletavel (Garrafas)'):
		
		if (ScriptGlobal.qtd_garrafas > 0 || ScriptGlobal.qtd_garrafas < 4):
			print("Pegou o Coletavel...")
			ScriptGlobal.qtd_garrafas += 1
			
	if ( body.name != "Personagem" && body.name != "Cenario" && body.name != "Cenario"):
			body.queue_free()
			get_parent().queue_free()
