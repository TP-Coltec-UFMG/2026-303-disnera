extends Node

var vida: int = 100
var max_vida: int = 100
var fase_atual: int = 1
var moedas := 20
var pocoes := 1
var arma := "Caco"
var armas: Array[String] = ["Caco"]
var feitos: Dictionary = {}
var diario: Array[String] = []
var nome := "Estudante"
var protecao := false
var epilogo := false

const ARMAS = {
	"Caco": {"dano": 28, "recarga": 0.28},
	"Cano": {"dano": 55, "recarga": 0.7},
	"Estilingue": {"dano": 22, "recarga": 0.42}
}

func registrar(id: String, texto: String, recompensa: int = 0) -> bool:
	if feitos.has(id):
		return false
	feitos[id] = true
	diario.append(texto)
	moedas += recompensa
	return true

func comprar(item: String, preco: int) -> bool:
	if moedas < preco or (item in armas) or (item == "Tampa" and protecao):
		return false
	moedas -= preco
	if item == "Poção":
		pocoes += 1
	elif item == "Tampa":
		protecao = true
	else:
		armas.append(item)
		arma = item
	return true

func reset() -> void:
	epilogo = false
	max_vida = 100
	vida = max_vida
	fase_atual = 1
	moedas = 20
	pocoes = 1
	arma = "Caco"
	armas = ["Caco"]
	feitos.clear()
	diario.clear()
	protecao = false
	nome = "Estudante"

func iniciar_epilogo() -> void:
	epilogo = true
	vida = max_vida
	registrar("retorno_coltec", "Depois do Ratão, voltei ao COLTEC. O ano acabou. A turma se formou e foi embora.")
