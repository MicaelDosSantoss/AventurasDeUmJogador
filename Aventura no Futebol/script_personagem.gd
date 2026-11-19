extends CharacterBody2D

var velocidade  = 500
var gravidade   = 30
var forca_pulo  = 1000
var direcao     = 1 # 1 para direita, -1 para esquerda
var animando    = false

@onready var area_ataque: Area2D = $Area2D

func _process(delta: float) -> void:
	velocity.x = 0
	velocity.y += gravidade
	
	if (ScriptGlobal.qtd_vidas <= 0):
		get_tree().change_scene_to_file("res://Telas/Game Over/Game_Over.tscn")	
		
	if (Input.is_action_pressed("ir_para_esquerda")):
		velocity.x = -velocidade
		direcao = -1
		$Sprite2D.flip_h = true
	
	if (Input.is_action_pressed("ir_para_direita")):
		velocity.x = velocidade
		direcao = 1
		$Sprite2D.flip_h = false
	
	if (Input.is_action_just_pressed("pular") and is_on_floor()):
		
		if(not animando):
			velocity.y = -forca_pulo
	
	if (is_on_floor()):
		if ($AnimationPlayer.current_animation==""):
			animando = false
			
		if (not animando):
			if (velocity.x == 0):
				$AnimationPlayer.play("parado")
			else:
				$AnimationPlayer.play("correndo")
		if (ScriptGlobal.qtd_municao > 0):
			if (Input.is_action_pressed("chutar")):
				$AnimationPlayer.play("chutando")
				animando = true
			
		if (Input.is_action_pressed("carrinho")):
			$AnimationPlayer.play("carrinho")
			animando = true
			
		if (Input.is_action_pressed("curar_vida")):
			if (ScriptGlobal.qtd_vidas < 3 && ScriptGlobal.qtd_garrafas > 0): 
				$AnimationPlayer.play("Curar_Vida")
				animando = true
			
	else:
		$AnimationPlayer.play("pulando")
		
	move_and_slide()
	
func spawnar_bolar():
	var cena_bola = preload("res://cena_bola.tscn")
	var obj_bola  = cena_bola.instantiate()
	obj_bola.get_node("CharacterBody2D").direcao = direcao
	get_parent().add_child(obj_bola)
		
	var pos_x = abs($Marker2D.position.x)
	$Marker2D.position.x = pos_x * direcao
		
	obj_bola.global_position = $Marker2D.global_position
		
	ScriptGlobal.qtd_municao -= 1
	
func curar_vida():
	if  ScriptGlobal.qtd_vidas < 3 && ScriptGlobal.qtd_garrafas > 0:
		ScriptGlobal.qtd_garrafas -= 1
		ScriptGlobal.qtd_vidas += 1

func eliminar_inimigo(body: Node2D) -> void:
	if( body.name == 'Coletavel (Municao)'):
		print("Pegou o Coletavel...")
		ScriptGlobal.qtd_municao += 3
		
	if( body.name == 'Coletavel (Garrafas)'):
		
		if (ScriptGlobal.qtd_garrafas > 0 || ScriptGlobal.qtd_garrafas < 4):
			print("Pegou o Coletavel...")
			ScriptGlobal.qtd_garrafas += 1
	
	if ( body.name != "Personagem" && body.name != "Cenario" ):
		body.queue_free()
		
func receber_dano() -> void:
	ScriptGlobal.qtd_vidas -= 1
