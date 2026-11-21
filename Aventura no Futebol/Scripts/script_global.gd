extends Node

var qtd_vidas = 0
var valor_dano = 0
var fase_atual = 0
var qtd_garrafas = 0
var qtd_municao = 0
var musica_ligada = true
var keyboard_visible = true
var portao = false
var checkpoint = "res://Telas/Game Over/Game_Over.tscn"
var mensagem = false

func resetar_variaveis():
	qtd_vidas = 3
	valor_dano = 1
	fase_atual = 0
	qtd_garrafas = 0
	qtd_municao = 3
	musica_ligada = true
	portao = false
	checkpoint = "res://Telas/Game Over/Game_Over.tscn"
	mensagem = false
	
func _ready() -> void:
	resetar_variaveis()
