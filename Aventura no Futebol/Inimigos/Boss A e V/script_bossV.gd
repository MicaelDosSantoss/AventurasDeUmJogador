extends CharacterBody2D

signal boss_derrotado

const SPEED = 45
const SPEED_PERSEGUICAO = 68

const ALCANCE_VISAO = 680.0
const DISTANCIA_RECUO = 240.0
const DISTANCIA_ATAQUE_BOLA = 380.0

const FRAME_DISPARO_CARTAS = 2
const FRAME_CHUTE_BOLA = 3

const INTERVALO_ENTRE_ATAQUES = 1.8
const DURACAO_DANO = 0.45

const VIDA_MAXIMA = 50
var vida_atual = VIDA_MAXIMA

enum Estado { PATRULHA, PERSEGUINDO, ATACANDO, DANO, MORTO }
var estado_atual = Estado.PATRULHA
var timer_estado = 0.0
var cooldown_ataque = 0.0

var direction = -1
var ultimo_foi_bola = false
var bola_lancada = false
var cartas_lancadas = false
var golpe_curto_ativo = false
var jogador: Node2D = null

var marker_esquerda: Node2D = null
var marker_direita: Node2D = null
var animated_sprite: AnimatedSprite2D = null
var barra_vida: ProgressBar = null
var marker_carta_direita: Node2D = null
var marker_carta_esquerda: Node2D = null
var marker_bola_direita: Node2D = null
var marker_bola_esquerda: Node2D = null

@export var bola_scene: PackedScene
@export var cartas_v_scene: PackedScene

func _ready():

	randomize()
	add_to_group("Inimigos")
	animated_sprite = find_child("AnimatedSprite2D", true, false)
	barra_vida = find_child("ProgressBar", true, false)
	marker_carta_direita = find_child("MarkerCartaD", true, false)
	marker_carta_esquerda = find_child("MarkerCartaE", true, false)
	marker_bola_direita = find_child("MarkerBolaD", true, false)
	marker_bola_esquerda = find_child("MarkerBolaE", true, false)
	if animated_sprite != null:
		animated_sprite.play("Patrulha_V")
		animated_sprite.flip_h = direction < 0
		if not animated_sprite.frame_changed.is_connected(_on_animated_sprite_frame_changed):
			animated_sprite.frame_changed.connect(_on_animated_sprite_frame_changed)
		if not animated_sprite.animation_finished.is_connected(_on_animated_sprite_animation_finished):
			animated_sprite.animation_finished.connect(_on_animated_sprite_animation_finished)
	if barra_vida != null:
		barra_vida.max_value = 100
		barra_vida.value = vida_atual

func _physics_process(delta):

	if not is_on_floor():
		velocity += get_gravity() * delta

	if estado_atual == Estado.MORTO:
		velocity.x = 0
		if not is_on_floor():
			move_and_slide()
		return

	if cooldown_ataque > 0.0 and estado_atual != Estado.ATACANDO and estado_atual != Estado.DANO:
		cooldown_ataque -= delta

	if estado_atual == Estado.DANO:
		velocity.x = 0
		move_and_slide()
		timer_estado -= delta
		if timer_estado <= 0.0:
			estado_atual = Estado.PERSEGUINDO
			if animated_sprite != null:
				animated_sprite.play("Patrulha_V")
		return

	if estado_atual == Estado.ATACANDO:
		velocity.x = 0
		move_and_slide()
		return

	if jogador == null:
		jogador = get_tree().get_first_node_in_group("Player")
		if jogador == null:
			jogador = get_tree().current_scene.find_child("Personagem", true, false)

	var distancia_x = 9999.0
	if jogador != null and animated_sprite != null:
		distancia_x = abs(jogador.global_position.x - animated_sprite.global_position.x)

	var em_combate = jogador != null and distancia_x <= ALCANCE_VISAO

	if em_combate:
		estado_atual = Estado.PERSEGUINDO

		if jogador.global_position.x > animated_sprite.global_position.x:
			direction = 1
			animated_sprite.flip_h = false
		else:
			direction = -1
			animated_sprite.flip_h = true

		if cooldown_ataque <= 0.0:
			if distancia_x < DISTANCIA_RECUO:
				iniciar_golpe_curto_fogo()
			elif distancia_x <= DISTANCIA_ATAQUE_BOLA and not ultimo_foi_bola:
				ultimo_foi_bola = true
				iniciar_ataque_bola()
			else:
				ultimo_foi_bola = false
				iniciar_ataque_cartas()
		else:
			if animated_sprite.animation != "Patrulha_V":
				animated_sprite.play("Patrulha_V")
			if distancia_x < DISTANCIA_RECUO:
				velocity.x = -(SPEED_PERSEGUICAO * 1.4) * direction
				if marker_direita != null and animated_sprite.global_position.x >= marker_direita.global_position.x and velocity.x > 0:
					velocity.x = 0
				if marker_esquerda != null and animated_sprite.global_position.x <= marker_esquerda.global_position.x and velocity.x < 0:
					velocity.x = 0
			else:
				velocity.x = SPEED_PERSEGUICAO * direction
	else:
		estado_atual = Estado.PATRULHA
		ultimo_foi_bola = false
		if animated_sprite != null and animated_sprite.animation != "Patrulha_V":
			animated_sprite.play("Patrulha_V")
		velocity.x = SPEED * direction
		if marker_direita != null and animated_sprite != null and animated_sprite.global_position.x >= marker_direita.global_position.x:
			direction = -1
		if marker_esquerda != null and animated_sprite != null and animated_sprite.global_position.x <= marker_esquerda.global_position.x:
			direction = 1
		if animated_sprite != null:
			animated_sprite.flip_h = direction < 0

	move_and_slide()
func animar_entrada_furia():
	estado_atual = Estado.DANO
	timer_estado = 0.9
	if jogador == null:
		jogador = get_tree().get_first_node_in_group("Player")
		if jogador == null:
			jogador = get_tree().current_scene.find_child("Personagem", true, false)
	if jogador != null and animated_sprite != null:
		direction = 1 if jogador.global_position.x > animated_sprite.global_position.x else -1
	if animated_sprite != null:
		animated_sprite.flip_h = direction < 0
		animated_sprite.play("Dano_V")
	var som_explosao = find_child("Audio_Explosão", true, false)
	if som_explosao != null:
		som_explosao.volume_db = 0.0
		som_explosao.play()
	if animated_sprite != null:
		animated_sprite.modulate = Color(3.0, 0.9, 0.9)
		var tween = create_tween()
		tween.tween_property(animated_sprite, "modulate", Color(1, 1, 1), 0.75)
	var camera = get_viewport().get_camera_2d()
	if camera != null:
		var tempo = 0.0
		while tempo < 0.6:
			camera.offset = Vector2(randf_range(-12.0, 12.0), randf_range(-12.0, 12.0))
			await get_tree().process_frame
			tempo += get_process_delta_time()
		camera.offset = Vector2.ZERO
	await get_tree().create_timer(0.3).timeout
	if som_explosao != null and som_explosao.playing:
		var tween_som = create_tween()
		tween_som.tween_property(som_explosao, "volume_db", -40.0, 0.25)
		await tween_som.finished
		som_explosao.stop()

func iniciar_golpe_curto_fogo():
	estado_atual = Estado.ATACANDO
	cartas_lancadas = false
	golpe_curto_ativo = true
	velocity.x = 0
	animated_sprite.play("AtaqueCartas_V")
	tocar_som_golpe_com_corte("Audio_Repulsor", 0.35, 0.0)

func iniciar_ataque_cartas():
	estado_atual = Estado.ATACANDO
	cartas_lancadas = false
	golpe_curto_ativo = false
	velocity.x = 0
	animated_sprite.play("AtaqueCartas_V")
	tocar_som_golpe_com_corte("Audio_Repulsor", 0.35, 0.0)

func iniciar_ataque_bola():
	estado_atual = Estado.ATACANDO
	bola_lancada = false
	velocity.x = 0
	animated_sprite.play("AtaqueBola_V")
	tocar_som_golpe_com_corte("Audio_Repulsor", 0.55, 0.0)

func tocar_som_golpe_com_corte(nome_no: String, duracao: float, inicio_seg: float = 0.0):
	var som = find_child(nome_no, true, false)
	if som == null:
		return
	som.volume_db = 0.0
	som.play(inicio_seg)
	await get_tree().create_timer(duracao).timeout
	if is_instance_valid(som) and som.playing:
		var tween = create_tween()
		tween.tween_property(som, "volume_db", -40.0, 0.12)
		await tween.finished
		som.stop()

func _on_animated_sprite_frame_changed():
	if animated_sprite.animation == "AtaqueBola_V":
		if animated_sprite.frame == FRAME_CHUTE_BOLA and not bola_lancada:
			bola_lancada = true
			instanciar_bola()
	elif animated_sprite.animation == "AtaqueCartas_V":
		if animated_sprite.frame == FRAME_DISPARO_CARTAS and not cartas_lancadas:
			cartas_lancadas = true
			tocar_som_golpe_com_corte("Audio_chamas", 0.65, 0.15)
			if golpe_curto_ativo:
				aplicar_explosao_curta()
			else:
				instanciar_cartas_v()
	elif animated_sprite.animation == "Patrulha_V" and abs(velocity.x) > 0:
		if animated_sprite.frame == 1 or animated_sprite.frame == 3:
			tocar_passo()

func tocar_passo():
	var som_passo = find_child("Audio_Andando", true, false)
	if som_passo == null:
		return
	som_passo.pitch_scale = randf_range(0.92, 1.08)
	som_passo.volume_db = -4.0
	som_passo.play()
	await get_tree().create_timer(0.3).timeout
	if is_instance_valid(som_passo) and som_passo.playing:
		som_passo.stop()

func _on_animated_sprite_animation_finished():
	if estado_atual == Estado.ATACANDO:
		estado_atual = Estado.PERSEGUINDO
		cooldown_ataque = INTERVALO_ENTRE_ATAQUES
		animated_sprite.play("Patrulha_V")

func aplicar_explosao_curta():
	if jogador == null:
		return
	var distancia_atual = abs(jogador.global_position.x - animated_sprite.global_position.x)
	if distancia_atual <= DISTANCIA_RECUO + 30.0:
		var destino_x = jogador.global_position.x + (220.0 * direction)
		var tween_empurrao = create_tween()
		tween_empurrao.tween_property(jogador, "global_position:x", destino_x, 0.22).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		if jogador.has_method("receber_dano"):
			jogador.receber_dano(1)

func instanciar_bola():
	if bola_scene == null:
		return
	var nova_bola = bola_scene.instantiate()
	nova_bola.direction = direction
	if direction == 1 and marker_bola_direita != null:
		nova_bola.global_position = marker_bola_direita.global_position
	elif marker_bola_esquerda != null:
		nova_bola.global_position = marker_bola_esquerda.global_position
	get_tree().current_scene.add_child(nova_bola)

func instanciar_cartas_v():
	if cartas_v_scene == null:
		return
	var novas_cartas = cartas_v_scene.instantiate()
	novas_cartas.direction = direction
	if direction == 1 and marker_carta_direita != null:
		novas_cartas.global_position = marker_carta_direita.global_position
	elif marker_carta_esquerda != null:
		novas_cartas.global_position = marker_carta_esquerda.global_position
	get_tree().current_scene.add_child(novas_cartas)

func receber_dano(quantidade: int):
	if estado_atual == Estado.MORTO:
		return
	vida_atual -= quantidade
	if barra_vida != null:
		var tween_hp = create_tween()
		tween_hp.tween_property(barra_vida, "value", max(0, vida_atual), 0.2)
	if vida_atual <= 0:
		morrer()
		return
	estado_atual = Estado.DANO
	timer_estado = DURACAO_DANO
	animated_sprite.play("Dano_V")
	var som_dano = find_child("Audio_Dano", true, false)
	if som_dano != null:
		som_dano.play()

func morrer():
	estado_atual = Estado.MORTO
	velocity = Vector2.ZERO
	collision_layer = 0
	if barra_vida != null:
		var tween_sumir = create_tween()
		tween_sumir.tween_property(barra_vida, "modulate:a", 0.0, 0.3)
	if has_node("Area2D"):
		$Area2D.set_deferred("monitoring", false)
	animated_sprite.play("Morte_V")
	var som_morte = find_child("Audio_Morte", true, false)
	if som_morte != null:
		som_morte.play()
	boss_derrotado.emit()
	ScriptGlobal.portao = true
	ScriptGlobal.mensagem = true
