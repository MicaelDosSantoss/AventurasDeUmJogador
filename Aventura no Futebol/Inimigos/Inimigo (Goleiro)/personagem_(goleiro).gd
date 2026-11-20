extends CharacterBody2D

var velocidade       = 300
var direcao_inimigo3 = 1
var gravidade        = 10
var forcao_pulo      = 250

func _process(delta: float) -> void:
	velocity.y += gravidade

	var personagem = get_tree().root.get_node("Fase/Jogador/Personagem")	
	var personagem_pos_x = personagem.global_position.x
	
	if (is_on_floor() and velocidade>0):
		if (global_position.x < personagem_pos_x):
			direcao_inimigo3 = 1
			$Sprite2D.flip_h = false
		else:
			direcao_inimigo3 = -1
			$Sprite2D.flip_h = true
		
		if ($RayCast2D.get_collider()!=null):
			if ($RayCast2D.get_collider().name=="Personagem"):
				$AudioStreamPlayer_Goleiro_Atacando.play()
				$AnimationPlayer.play("Goleiro (Atacando)")
				velocity.y = -forcao_pulo
		else:
			$AnimationPlayer.play("Goleiro (Correndo)")
	
	var visibleOnScreenPosX = $VisibleOnScreenNotifier2D.position.x
	$VisibleOnScreenNotifier2D.position.x = abs(visibleOnScreenPosX) * direcao_inimigo3
		
	velocity.x  = velocidade * direcao_inimigo3

	move_and_slide()


func Dano_do_Personagem(body: Node2D) -> void:
	if(body.name == "Personagem"):
		body.receber_dano()


func perseguir() -> void:
	velocidade = 300


func parar_perseguir() -> void:
	velocidade = 0
	$AnimationPlayer.play("Goleiro (Parado)")
