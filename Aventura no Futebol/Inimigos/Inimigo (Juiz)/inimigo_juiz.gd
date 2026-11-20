extends CharacterBody2D

var direcao_inimigo = 1

func _process(delta: float) -> void:
	velocity.y += 20
	move_and_slide()
	
	if $RayCast2D.get_collider() !=null && $RayCast2D.get_collider().name == "Personagem":
		$AnimationPlayer.play("Inimigo Juiz (Jogando Cartão)")
	else:
		$AnimationPlayer.play("Inimigo Juiz (Parado)")
		
	var personagem = get_tree().root.get_node("Fase/Jogador/Personagem")
	var personagem_pos_x = personagem.global_position.x
	
	if global_position.x < personagem_pos_x:
		$Sprite2D.flip_h = false
		$Marker2D.position.x = abs($Marker2D.position.x)
		direcao_inimigo = 1
	else:
		$Sprite2D.flip_h = true
		$Marker2D.position.x = -abs($Marker2D.position.x)
		direcao_inimigo = -1
		
func atirar_cartao():
	$AudioStreamPlayer_Som_Cartao.play()
	var cena_cartao = preload("res://Inimigos/Inimigo (Juiz)/cena_cartao.tscn")
	var obj_cartao = cena_cartao.instantiate()
	get_parent().add_child(obj_cartao)
	obj_cartao.get_node("CharacterBody2D").direcao = direcao_inimigo
	obj_cartao.global_position = $Marker2D.global_position
