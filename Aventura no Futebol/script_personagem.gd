extends CharacterBody2D

var velocidade  = 500
var gravidade   = 30
var forca_pulo  = 1000
var direcao     = 1 # 1 para direita, -1 para esquerda
var animando    = false

@onready var area_ataque: Area2D = $Area2D

func _ready() -> void:
	if get_tree().current_scene.name == "Fase2":
		$Camera2D.limit_top = -250
		$Camera2D.limit_left = 30
		$Camera2D.limit_right = 1680
		ScriptGlobal.qtd_municao += 10
		
		ScriptGlobal.qtd_vidas = 0
		ScriptGlobal.qtd_vidas += 3
		
		ScriptGlobal.qtd_garrafas = 0
		ScriptGlobal.qtd_garrafas += 3
		
		ScriptGlobal.checkpoint = "res://Telas/Game Over2/Game_Over2.tscn"


func _process(delta: float) -> void:
	velocity.x = 0
	velocity.y += gravidade
	
	if (ScriptGlobal.qtd_vidas <= 0):	
		get_tree().change_scene_to_file(ScriptGlobal.checkpoint)	
		
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
			$AudioStreamPlayer_Pulando.play()
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
			$AudioStreamPlayer_Rasteira.play()
			animando = true
			
		if (Input.is_action_pressed("curar_vida")):
			if (ScriptGlobal.qtd_vidas < 3 && ScriptGlobal.qtd_garrafas > 0):
				$AudioStreamPlayer_Tomando_Agua.play()
				$AnimationPlayer.play("Curar_Vida")
				animando = true
			
	else:
		$AnimationPlayer.play("pulando")
		
	move_and_slide()
	
func spawnar_bolar():
	$AudioStreamPlayer_Bola_de_futebol.play()
	var cena_bola = preload("res://cena_bola.tscn")
	var obj_bola  = cena_bola.instantiate()
	obj_bola.get_node("Bola_Futebol").direcao = direcao
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
	print(body.name)
	
	if( body.name == 'Coletavel (Municao)'):
		$AudioStreamPlayer_destruir_coletavel.play()
		print("Pegou o Coletavel...")
		ScriptGlobal.qtd_municao += 3
		
	if( body.name == 'Coletavel (Garrafas)'):
		$AudioStreamPlayer_destruir_coletavel.play()
		if (ScriptGlobal.qtd_garrafas > 0 || ScriptGlobal.qtd_garrafas < 4):
			print("Pegou o Coletavel...")
			ScriptGlobal.qtd_garrafas += 1
			
	if (body.name == "CharacterBody2D"):
		var boss = get_tree().current_scene.find_child("CharacterBody2D", true, false)
		
		if boss != null:
			boss.receber_dano(25)
	
	if ( body.name != "Personagem" && body.name != "Cenario" && body.name != "CharacterBody2D" ):
		body.queue_free()
			
func receber_dano() -> void:
	$AudioStreamPlayer_Recebendo_Dano.play()
	ScriptGlobal.qtd_vidas -= 1
