extends Node
var painel: CanvasLayer
var tipo := ""
var etapa := 0
var ordem: Array[int] = []
const QUESTOES = [
	{"codigo":"int total = 0;\nfor (int i = 1; i <= 3; i++) {\n    total += i;\n}\nSystem.out.println(total);", "opcoes":["3","6","7"], "certa":1, "explica":"O laço soma 1 + 2 + 3. O resultado é 6."},
	{"codigo":"String turma = \"COLTEC\";\nSystem.out.println(turma.length());", "opcoes":["5","6","7"], "certa":1, "explica":"COLTEC tem 6 caracteres."},
	{"codigo":"int[] notas = {7, 8, 9};\nSystem.out.println(notas[1]);", "opcoes":["7","8","9"], "certa":1, "explica":"Os índices começam em zero. notas[1] vale 8."}
]
func aula() -> void:
	painel.abrir("Leando Maia · Java no quadro","Hoje vamos acompanhar variáveis, laços e arrays. Leiam o código no quadro: a cada repetição, soma recebe mais um valor.\n\nNos computadores vocês podem prever a saída, corrigir erros e montar um programa.","conversa")
	painel.botao("Executar mentalmente",iniciar.bind("saida"))
	painel.botao("Depurar o programa",iniciar.bind("debug"))
	painel.botao("Montar o código",iniciar.bind("ordem"))
	painel.botao("Voltar à aula",painel.fechar)
func iniciar(id: String) -> void:
	tipo = id
	etapa = 0
	ordem.clear()
	mostrar()
func mostrar() -> void:
	if tipo == "saida":
		var q: Dictionary = QUESTOES[etapa]
		painel.abrir("Terminal Java · saída %d/3" % (etapa+1),q.codigo+"\n\nO que será impresso?","java")
		_codigo()
		for i in range(q.opcoes.size()):
			painel.botao(q.opcoes[i],responder.bind(i))
	elif tipo == "debug":
		var codigos := ["int idade = 18\nSystem.out.println(idade);","int[] valores = {4, 5};\nSystem.out.println(valores[2]);"]
		var opcoes := [["Adicionar ; depois de 18","Trocar int por boolean","Remover println"],["Usar valores[1] para acessar 5","Usar valores[3]","Trocar 2 por -1"]]
		painel.abrir("Terminal Java · depuração %d/2" % (etapa+1),codigos[etapa]+"\n\nQual correção faz o programa funcionar?","java")
		_codigo()
		for i in range(3):
			painel.botao(opcoes[etapa][i],responder.bind(i))
	else:
		painel.abrir("Terminal Java · monte o programa","Coloque os trechos na ordem correta.\n\n"+"\n".join(ordem.map(func(i): return _linhas()[i])),"java")
		_codigo()
		for i in [2,0,3,1]:
			var b = painel.botao(_linhas()[i],escolher.bind(i))
			b.disabled = i in ordem
	painel.botao("Sair do computador",painel.fechar)
func _codigo() -> void:
	var fonte := SystemFont.new()
	fonte.font_names = PackedStringArray(["monospace"])
	painel.conteudo.add_theme_font_override("font",fonte)
	painel.conteudo.add_theme_font_size_override("font_size",17)
func _linhas() -> Array[String]:
	return ["public class Aula {","  public static void main(String[] args) {","    System.out.println(\"Olá, COLTEC!\");","  } }"]
func responder(indice: int) -> void:
	var correto: int = QUESTOES[etapa].certa if tipo == "saida" else 0
	if indice != correto:
		painel.abrir("Terminal Java · vamos revisar","Leando Maia: acompanhe uma linha por vez. Confira o ponto e vírgula e lembre que arrays começam no índice zero.","java")
		painel.botao("Tentar novamente",mostrar)
		painel.botao("Voltar ao laboratório",painel.fechar)
		return
	var explicacao: String = QUESTOES[etapa].explica if tipo == "saida" else ("Cada instrução termina com ;." if etapa == 0 else "O array tem dois elementos: índices 0 e 1.")
	etapa += 1
	painel.abrir("Terminal Java · correto",explicacao,"java")
	painel.botao("Continuar",concluir if etapa == (3 if tipo == "saida" else 2) else mostrar)
func escolher(indice: int) -> void:
	if indice != ordem.size():
		painel.abrir("Terminal Java · erro de compilação","Primeiro a classe, depois o método main, a instrução e as chaves de fechamento.","java")
		painel.botao("Revisar a ordem",mostrar)
		painel.botao("Sair",painel.fechar)
		return
	ordem.append(indice)
	if ordem.size() == 4:
		concluir()
	else:
		mostrar()
func concluir() -> void:
	var novo := EstatisticasJogador.registrar("java_"+tipo,"Pratiquei "+tipo+" na aula de Java do Leando Maia.",8)
	painel.abrir("Terminal Java · programa concluído","BUILD SUCCESSFUL\n\nLeando Maia: ótimo! Agora você consegue explicar o que o programa faz." + ("\n+8 sucatas" if novo else "\nAtividade já registrada no diário."),"java")
	painel.botao("Escolher outro exercício",aula)
	painel.botao("Sair",painel.fechar)
