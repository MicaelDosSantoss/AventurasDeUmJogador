extends CharacterBody2D

var direcao_inimigo = 1

func atirar_cartao():
	var cena_cartao = preload("res://cena_cartao.tscn")
	var obj_cartao  = cena_cartao.instantiate()
	get_parent().add_child(obj_cartao)
	obj_cartao.get_node("CharacterBody2D").direcao = direcao_inimigo
	obj_cartao.global_position = $Marker2D.global_position
	
	
	
	
