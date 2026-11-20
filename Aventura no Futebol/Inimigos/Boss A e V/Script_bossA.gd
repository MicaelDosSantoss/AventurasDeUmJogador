extends CharacterBody2D

const SPEED = 40
const SPEED_PERSEGUICAO = 60

const ALCANCE_VISAO = 650.0
const DISTANCIA_RECUO = 240.0
const DISTANCIA_MINIMA_ONDA = 320.0
const DISTANCIA_MAXIMA_ONDA = 460.0
const FRAME_IMPACTO_CHAO = 3 

const DURACAO_ANIMACAO_GOLPE = 0.85 
const INTERVALO_ENTRE_ATAQUES = 1.6 

const VIDA_MAXIMA = 100
var vida_atual = VIDA_MAXIMA

var direction = -1
var atacando = false
var levando_dano = false
var morto = false
var pode_atacar = true
var ataque_duplo = false
var ultimo_foi_chao = false
var onda_lancada = false
var jogador: Node2D = null

var marker_esquerda: Node2D = null
var marker_direita: Node2D = null
var animated_sprite: AnimatedSprite2D = null
var barra_vida: ProgressBar = null
var marker_carta_direita: Node2D = null
var marker_carta_esquerda: Node2D = null

@export var carta_scene: PackedScene
@export var onda_scene: PackedScene
@export var boss_vermelho_scene: PackedScene

func _ready():
	randomize()
	add_to_group("Inimigos")
	animated_sprite = find_child("AnimatedSprite2D", true, false)
	barra_vida = find_child("ProgressBar", true, false)
	marker_carta_direita = find_child("MarkerCartaD", true, false)
	marker_carta_esquerda = find_child("MarkerCartaE", true, false)
	if get_parent() != null:
		marker_esquerda = get_parent().find_child("MarkerEsquerda", true, false)
		marker_direita = get_parent().find_child("MarkerDireita", true, false)
	if animated_sprite != null:
		animated_sprite.play("Patrulha")
		if not animated_sprite.frame_changed.is_connected(_on_animated_sprite_frame_changed):
			animated_sprite.frame_changed.connect(_on_animated_sprite_frame_changed)
	if barra_vida != null:
		barra_vida.max_value = VIDA_MAXIMA
		barra_vida.value = vida_atual

func _physics_process(delta):

	if morto:
		if not is_on_floor():
			velocity += get_gravity() * delta
			velocity.x = 0
			move_and_slide()
		return

	if not is_on_floor():
		velocity += get_gravity() * delta

	if levando_dano:
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
		if atacando:
			velocity.x = 0
			move_and_slide()
			return

		if jogador.global_position.x > animated_sprite.global_position.x:
			direction = 1
			animated_sprite.flip_h = false
		else:
			direction = -1
			animated_sprite.flip_h = true

		if pode_atacar:
			if distancia_x < DISTANCIA_RECUO:
				ultimo_foi_chao = true
				iniciar_ataque_chao()
			elif distancia_x >= DISTANCIA_MINIMA_ONDA and distancia_x <= DISTANCIA_MAXIMA_ONDA:
				var sorteio = randf()
				if sorteio <= 0.65 and not ultimo_foi_chao:
					ultimo_foi_chao = true
					iniciar_ataque_chao()
				else:
					ultimo_foi_chao = false
					iniciar_ataque_carta()
			else:
				ultimo_foi_chao = false
				iniciar_ataque_carta()
		else:
			if animated_sprite.animation != "Patrulha":
				animated_sprite.play("Patrulha")
			if distancia_x < DISTANCIA_RECUO:
				velocity.x = -(SPEED_PERSEGUICAO * 1.4) * direction
				if marker_direita != null and animated_sprite.global_position.x >= marker_direita.global_position.x and velocity.x > 0:
					velocity.x = 0
				if marker_esquerda != null and animated_sprite.global_position.x <= marker_esquerda.global_position.x and velocity.x < 0:
					velocity.x = 0
			else:
				velocity.x = SPEED_PERSEGUICAO * direction
	else:
		atacando = false
		ataque_duplo = false
		ultimo_foi_chao = false
		if animated_sprite != null and animated_sprite.animation != "Patrulha":
			animated_sprite.play("Patrulha")
		velocity.x = SPEED * direction
		if marker_direita != null and animated_sprite != null and animated_sprite.global_position.x >= marker_direita.global_position.x:
			direction = -1
		if marker_esquerda != null and animated_sprite != null and animated_sprite.global_position.x <= marker_esquerda.global_position.x:
			direction = 1
		if animated_sprite != null:
			animated_sprite.flip_h = direction < 0

	move_and_slide()
	
func receber_dano(quantidade: int):
	if morto:
		return
	vida_atual -= quantidade
	var som_dano = find_child("Audio_Dano", true, false)
	if som_dano != null:
		som_dano.play()
	if barra_vida != null:
		var tween_hp = create_tween()
		tween_hp.tween_property(barra_vida, "value", max(50, vida_atual), 0.2)
	if vida_atual <= (VIDA_MAXIMA / 2):
		transformar_em_boss_vermelho()
		return
	levando_dano = true
	atacando = false
	if animated_sprite != null:
		animated_sprite.play("Dano")
	await get_tree().create_timer(0.35).timeout
	if not morto:
		levando_dano = false
		pode_atacar = true
		if animated_sprite != null:
			animated_sprite.play("Patrulha")

func transformar_em_boss_vermelho():
	morto = true
	atacando = false
	levando_dano = true
	velocity = Vector2.ZERO
	if has_node("Area2D"):
		$Area2D.set_deferred("monitoring", false)
	if animated_sprite != null:
		animated_sprite.play("Dano")
	var som_transicao = find_child("Audio_Transição", true, false)
	if som_transicao != null:
		som_transicao.play()
	var pos_original_sprite = animated_sprite.position
	var escala_original = animated_sprite.scale
	var tween_energia = create_tween().set_parallel(true)
	tween_energia.tween_property(animated_sprite, "modulate", Color(3.0, 1.0, 0.4), 2.2).set_trans(Tween.TRANS_SINE)
	tween_energia.tween_property(animated_sprite, "scale", escala_original * 1.15, 2.2).set_trans(Tween.TRANS_BACK)
	var tempo_vibracao = 0.0
	var duracao_vibracao = 2.3
	var camera = get_viewport().get_camera_2d()
	while tempo_vibracao < duracao_vibracao:
		var progresso = tempo_vibracao / duracao_vibracao
		var forca = lerpf(1.5, 9.5, progresso)
		animated_sprite.position = pos_original_sprite + Vector2(randf_range(-forca, forca), randf_range(-forca * 0.5, forca * 0.5))
		if camera != null:
			camera.offset = Vector2(randf_range(-forca, forca), randf_range(-forca, forca))
		await get_tree().process_frame
		tempo_vibracao += get_process_delta_time()
	if camera != null:
		camera.offset = Vector2.ZERO
	animated_sprite.modulate = Color(4.5, 4.5, 4.5)
	await get_tree().create_timer(0.35).timeout
	if boss_vermelho_scene == null:
		push_error("Arraste a cena_bossV.tscn no Inspetor do Boss Amarelo!")
		return
	var novo_boss = boss_vermelho_scene.instantiate()
	get_parent().get_parent().add_child(novo_boss)
	novo_boss.global_position = get_parent().global_position
	var body_vermelho = novo_boss.find_child("CharacterBody2D", true, false)
	if body_vermelho == null and novo_boss is CharacterBody2D:
		body_vermelho = novo_boss
	if body_vermelho != null:
		body_vermelho.global_position = global_position
		body_vermelho.direction = direction
		body_vermelho.marker_esquerda = marker_esquerda
		body_vermelho.marker_direita = marker_direita
		if body_vermelho.has_method("animar_entrada_furia"):
			body_vermelho.animar_entrada_furia()
	get_parent().queue_free()

func iniciar_ataque_carta():
	atacando = true
	pode_atacar = false
	velocity.x = 0
	animated_sprite.play("AtaqueCarta")
	tocar_som_com_corte("Audio_Repulsor", 0.35)
	await get_tree().create_timer(0.22).timeout
	if morto or levando_dano: return
	instanciar_carta()
	if ataque_duplo:
		await get_tree().create_timer(0.25).timeout
		if morto or levando_dano: return
		instanciar_carta()
	ataque_duplo = not ataque_duplo
	finalizar_golpe_e_contar_intervalo()

func tocar_som_com_corte(nome_no: String, duracao: float):
	var som = find_child(nome_no, true, false)
	if som == null:
		return
	som.volume_db = 0.0
	som.play()
	await get_tree().create_timer(duracao).timeout
	if is_instance_valid(som) and som.playing:
		var tween = create_tween()
		tween.tween_property(som, "volume_db", -40.0, 0.1)
		await tween.finished
		som.stop()

func iniciar_ataque_chao():
	atacando = true
	pode_atacar = false
	onda_lancada = false
	velocity.x = 0
	animated_sprite.play("AtaqueChao")
	finalizar_golpe_e_contar_intervalo()

func _on_animated_sprite_frame_changed():
	if animated_sprite.animation == "AtaqueChao":
		if animated_sprite.frame == FRAME_IMPACTO_CHAO and not onda_lancada:
			onda_lancada = true
			soltar_onda_de_choque()
	elif animated_sprite.animation == "Patrulha" and abs(velocity.x) > 0:
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

func soltar_onda_de_choque():
	if onda_scene == null:
		return
	tremer_camera(8.0, 0.25)
	var nova_onda = onda_scene.instantiate()
	nova_onda.direction = direction
	var distancia_jogador = abs(jogador.global_position.x - animated_sprite.global_position.x) if jogador != null else 300.0
	var deslocamento_x = (95.0 if distancia_jogador < DISTANCIA_RECUO else 285.0) * direction
	nova_onda.global_position = Vector2(animated_sprite.global_position.x + deslocamento_x, animated_sprite.global_position.y + 42)
	get_tree().current_scene.add_child(nova_onda)

func finalizar_golpe_e_contar_intervalo():
	await get_tree().create_timer(DURACAO_ANIMACAO_GOLPE).timeout
	if morto or levando_dano: return
	atacando = false
	animated_sprite.play("Patrulha")
	await get_tree().create_timer(INTERVALO_ENTRE_ATAQUES).timeout
	pode_atacar = true

func instanciar_carta():
	if jogador == null or morto or carta_scene == null:
		return
	var nova_carta = carta_scene.instantiate()
	if direction == 1 and marker_carta_direita != null:
		nova_carta.direction = 1
		nova_carta.global_position = marker_carta_direita.global_position
	elif marker_carta_esquerda != null:
		nova_carta.direction = -1
		nova_carta.global_position = marker_carta_esquerda.global_position
	get_tree().current_scene.add_child(nova_carta)

func tremer_camera(intensidade: float, duracao: float):
	var camera = get_viewport().get_camera_2d()
	if camera == null:
		return
	var tempo = 0.0
	while tempo < duracao:
		camera.offset = Vector2(randf_range(-intensidade, intensidade), randf_range(-intensidade, intensidade))
		await get_tree().process_frame
		tempo += get_process_delta_time()
	camera.offset = Vector2.ZERO
