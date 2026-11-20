extends Node2D

const SPEED = 250.0
var direction = 1
var ja_acertou = false

func _ready():
	$Area2D.set_collision_mask_value(2, true)
	$AnimatedSprite2D.flip_h = direction < 0
	$AnimatedSprite2D.play()
	$Area2D.body_entered.connect(_on_area_2d_body_entered)
	
	await get_tree().create_timer(4.0).timeout
	queue_free()

func _process(delta):
	global_position.x += SPEED * direction * delta

func _on_area_2d_body_entered(body):
	if not ja_acertou and (body.name == "Personagem" or body.is_in_group("Player")):
		ja_acertou = true
		print("Jogador atingido pela Bola de Fogo!")
		
		var destino_x = body.global_position.x + (240.0 * direction)
		var tween_empurrao = create_tween()
		tween_empurrao.tween_property(body, "global_position:x", destino_x, 0.22).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
			
		if body.has_method("receber_dano"):
			body.receber_dano()
			body.receber_dano()
			
		await get_tree().create_timer(0.08).timeout
		queue_free()
