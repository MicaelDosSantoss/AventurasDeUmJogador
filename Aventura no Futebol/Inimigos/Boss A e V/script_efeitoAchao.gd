extends Node2D

var direction = 1
var ja_acertou = false

func _ready():
	$Area2D.set_collision_mask_value(2, true)
	$AnimatedSprite2D.flip_h = direction < 0
	$AnimatedSprite2D.play("EfeitoChao")
	$Area2D.body_entered.connect(_on_area_2d_body_entered)
	
	scale = Vector2(0.75, 0.75)
	
	modulate.a = 0.0
	var tween_entrada = create_tween()
	tween_entrada.tween_property(self, "modulate:a", 1.0, 0.08)
	
	await get_tree().create_timer(0.45).timeout
	
	var tween_saida = create_tween()
	tween_saida.tween_property(self, "modulate:a", 0.0, 0.25)
	await tween_saida.finished
	queue_free()

func _on_area_2d_body_entered(body):

	if not ja_acertou and (body.name == "Personagem" or body.is_in_group("Player")):
		ja_acertou = true
		print("Jogador atingido e empurrado pela onda de choque!")
		
		var destino_x = body.global_position.x + (260.0 * direction)
		var tween_empurrao = create_tween()
		tween_empurrao.tween_property(body, "global_position:x", destino_x, 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
			
		if body.has_method("receber_dano"):
			body.receber_dano()
