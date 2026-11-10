extends StaticBody2D

@onready var area_ataque = get_node_or_null("Area2D")

func _ready() -> void:
	$AnimationPlayer.play("Coletavel Munição (Animação Padrão)")



func pegar_munição(body: Node2D) -> void:
	if(body.name == "Personagem"):
		print("Entrou" + body.name)
		$AnimationPlayer.play("Coletavel Munição (Se Apagando)")
