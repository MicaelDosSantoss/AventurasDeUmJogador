
extends CharacterBody2D

var velocidade = 300
var direcao_inimigo2 = 1
var gravidade = 10
var forca_pulo = 10

var atacando = false

func _process(delta: float) -> void:
	velocity.y += gravidade

	var personagem = get_tree().root.get_node("Fase/Jogador/Personagem")
	var personagem_pos_x = personagem.global_position.x

	# Define a direção do inimigo
	if global_position.x < personagem_pos_x:
		direcao_inimigo2 = 1
		$Sprite2D.flip_h = false
		$RayCast_Visao.rotation_degrees = 0
	else:
		direcao_inimigo2 = -1
		$Sprite2D.flip_h = true
		$RayCast_Visao.rotation_degrees = 180
		
	# Prioridade das animações
	if $RayCast2D.get_collider() != null:
		if ($RayCast2D.get_collider().name=="Personagem"):
			$AnimationPlayer.play("Inimigo Atacante (Rasteira)")
	
	elif velocidade == 0:
		if $AnimationPlayer.current_animation != "Inimigo Atacante (Parado)":
			$AnimationPlayer.play("Inimigo Atacante (Parado)")

	elif velocidade > 0:
			if $AnimationPlayer.current_animation != "Inimigo Atacante (Correndo)":
				$AnimationPlayer.play("Inimigo Atacante (Correndo)")

	# Movimentação
	if $RayCast_Visao.get_collider() == null:
		velocity.x = 0
		$AnimationPlayer.play("Inimigo Atacante (Parado)")
		
	elif $RayCast_Visao.get_collider() != null:
		if ($RayCast_Visao.get_collider().name=="Personagem"):
			velocity.x = velocidade * direcao_inimigo2

	move_and_slide()

func Dano_atacante_personagem(body: Node2D) -> void:
	print("De")
	if(body.name == "Personagem"):
		body.receber_dano()
		await get_tree().create_timer(10.0).timeout
