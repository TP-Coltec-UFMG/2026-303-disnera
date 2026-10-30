# COLTEC: escola, Senta e Toca e esgotos

Inicie pelo menu normal do projeto Godot. O botão de começar abre o hall da escola. O protagonista, os inimigos e as cinco fases de esgoto conservam suas artes anteriores; a escola agora tem novos fundos e novos sprites de NPCs.

## Escola e exploração

Cinco ambientes com fundos próprios, revisados a partir do vídeo enviado em 20/10/2026:

- **Hall:** paredes bege/amarelo-claro, esquadrias retangulares avermelhadas, fluorescentes, armários cinza/verdes e piso cinza. Porta esquerda: sala de música. Porta direita: laboratório/oficina. Saída inferior: pátio externo.
- **Laboratório da turma:** substitui a sala de música; 38 estudantes em computadores individuais, aula de Java e mural dos desaparecidos. Sala de 1600 × 1100, com câmera acompanhando o jogador e saída inferior para o hall.
- **Sala de metal:** tornos, bancadas, colunas, janelas retangulares e vigas aparentes, inspirados na oficina do vídeo. Professor Geovane, de cabelo branco, ensina a sequência medir/marcar/cortar; o minigame de drenagem é preservado.
- **Exterior:** fachada retangular em tons claros, esquadrias avermelhadas, passeio pavimentado e canteiros com árvores. O túnel continua no lado direito como elemento fictício do jogo. O portão inferior esquerdo leva à quadra.
- **Quadra:** piso verde/vermelho, linhas claras, tabelas, rede, alambrado e árvores, inspirados no trecho externo do vídeo. A passagem inferior volta à área externa.

O vídeo tem 19,10 segundos e mostra os ambientes em cortes rápidos, parcialmente cobertos por uma montagem. A adaptação usa os detalhes arquitetônicos visíveis, não uma planta exata. A montagem, marcas da rede social e pessoas não foram incorporadas. Nenhum aluno real foi identificado ou recriado nesta etapa.

Os nomes das seis imagens estão representados por 38 novos estudantes no laboratório e três colegas já existentes (Duda, Tigas e Pedro Silva, agora identificado como Pedro Silva Freitas). PH e Saci completam os cinco amigos no hall, todos andando. Nomes parecidos foram mantidos separados. A lista está em `data/turma.json`; não foram incorporados telefones, descrições de perfil ou fotos. Os sprites são fictícios e compartilham as animações do protagonista. Conversas de estudo são falas fictícias do jogo, não declarações reais dessas pessoas. Duda conversa, Pedro Silva vende itens, PH oferece memória musical e Tigas orienta a drenagem.

## Senta e Toca

Evento ativo no hall com a banda Toquempé: os três músicos são anônimos e identificados apenas pelo nome da banda. A apresentação tem uma composição instrumental original sintetizada, com guitarra, baixo, teclado e percussão. Ela toca em loop pelo canal Music, continua durante a conversa e para ao sair do hall.

Aproxime-se da frente do palco e aperte E para ouvir ou participar do minigame de memória musical. Ouvir concede uma lembrança e cinco sucatas apenas uma vez. O minigame também continua acessível conversando com PH.

## Refúgio

O refúgio fica invisível e indisponível enquanto houver inimigos vivos na sala. O ponto e a função de abertura verificam a mesma condição. Após eliminar todos, ele aparece na entrada do setor e libera oficina, descanso e conversa.

A condição é separada da saída: na fase das alavancas, limpar os inimigos libera o refúgio; resolver a combinação continua necessário para avançar. Morrer repovoa a sala atual, bloqueando o refúgio novamente, e preserva compras e memórias da sessão. Descanso cura uma vez por setor.

## Recursos mantidos

- Memória musical: memorize quatro notas por três segundos e repita. Drenagem: cada válvula inverte a seguinte; abra todas. Recompensas únicas, com tentativas livres.
- Loja: cano (25 sucatas), estilingue (30), curativo (10), tampa protetora (35). Ratos e subclasses derrotados rendem sucata.
- Caco: 28 de dano / recarga de 0,28 s. Cano: 55 / 0,7 s. Estilingue: 22 / 0,42 s. A animação também limita a frequência do corpo a corpo. A tampa reduz três pontos de dano, com mínimo de um.
- Chefão sem dano de contato, com meteoros e baforada telegrafados; fica mais agressivo abaixo de metade da vida.
- Lore dos desaparecimentos ligada a memórias do patinete, do farol, da música e do desejo de refazer escolhas.

## Controles

WASD/setas: andar. E: interação mais próxima ou porta. Tab: mochila, troca de arma, curativos e diário. Escape: fechar painel. Mouse: atacar na última direção; três golpes em sequência dão 50% a mais no terceiro. F: ataque forte com preparação de 0,4 s, custa 35 de energia (golpe amplo ou três projéteis com estilingue). R: aparar por 0,28 s, custa 20 de energia, recarga de 0,9 s. Energia regenera a 19/s. Um aparo bem-sucedido devolve 12 de energia. Dash: espaço/Q/Shift. Conversas pausam o mundo. O progresso dura durante a sessão; não há salvamento em disco.

## Artes e áudio

Cinco fundos simplificados com image_gen em modo edição: cores chapadas, menos textura e contornos mais rústicos. Referências arquitetônicas do vídeo e posições das portas foram mantidas. Prompts completos em `Imagens/Coltec/PROMPTS_SIMPLES.md`; histórico em `PROMPTS_VIDEO.md`:

- `Imagens/Coltec/hall_simples.png`
- `Imagens/Coltec/oficina_simples.png`
- `Imagens/Coltec/sala_simples.png`
- `Imagens/Coltec/exterior_simples.png`
- `Imagens/Coltec/quadra_simples.png`

As versões anteriores foram preservadas como arquivos. A folha `estudantes.png` deixou de ser usada; os NPCs usam `Cute_Fantasy_Free/Player/Player.png`, as animações da cena original e `Shaders/npc_palette.gdshader`. O protagonista não foi alterado.

Os fundos são escalados para 960 × 640. Colisões e pontos de interação foram ajustados em `Scripts/coltec.gd`; os NPCs percorrem rotas predefinidas. O pátio é atravessado pelos passeios, com bloqueio dos canteiros principais.

A composição está em `Musica/Coltec/senta_e_toca.wav`; o gerador determinístico, sem amostras externas, está em `tools/create_school_music.py`.

## Validação

`godot --headless --path . res://tests/adventure_test.tscn`

Cobre compartilhamento das animações do protagonista, direções dos NPCs, ida/volta da quadra, colisões do palco e limites, portas, deslocamento de NPC, reprodução/parada da banda, bloqueio e desbloqueio do túnel, minigames, recompensas únicas, compra, disparo, chefão sem contato, cinco fases, bloqueio/liberação do refúgio, independência do puzzle e retorno após morte. Executado com Godot 4.6 (a configuração original indica 4.7). Há um aviso de instância pendente no encerramento do teste herdado do fluxo de combate; as asserções passam.

`res://tests/preview.tscn` gera capturas reais do jogo em `output/coltec/`. Foram inspecionados os cinco ambientes e o diálogo do evento. Isso não substitui um playtest completo de balanceamento.


## Depois do Ratão

A morte do chefão inicia o fade e retorna automaticamente à escola. Nome, compras e diário da sessão são preservados. Não é preciso eliminar os outros inimigos para disparar esse retorno. O estado de epílogo bloqueia dano no jogador e é limpo ao iniciar um novo jogo.

A escola está vazia: sem NPCs, loja, evento ou acesso ao combate. As portas continuam permitindo explorar os cinco ambientes. Cores frias, papéis esquecidos e uma faixa da turma formada marcam dezembro. Exterior e quadra têm chuva animada; o som de chuva é mais baixo dentro da escola e respeita o canal de efeitos. A quadra oferece voltar ao menu.

Três atividades sem recompensa monetária:
- Hall: ordenar os papéis da despedida.
- Laboratório da turma: repetir quatro notas de uma lembrança.
- Sala de metal: encontrar três pares no arquivo molhado da Disnara.

Tentativas são livres; cada lembrança entra uma única vez no caderno. Os textos atuais são provisórios e neutros. A lore futura pode ser adicionada nos campos `lore` de `data/epilogue_memories.json`, exibidos ao concluir cada atividade. Nenhuma história nova enviada futuramente foi presumida.

Teste adicional: `godot --headless --path . res://tests/epilogue_test.tscn`. Verifica morte real do chefão, troca de cena, nomes, ausência dos NPCs no retorno, chuva, conclusão dos três minigames, registros únicos, cancelamento de temporizador e novo jogo. As asserções passaram no Godot 4.6; o encerramento ainda registra instâncias/um recurso pendente, sem erro de execução durante as verificações. Capturas do retorno em `output/coltec/epilogo_*.png`.


## Turma, torneio e combate — revisão de 26/10

A quadra tem dez atletas animados e uma bola em movimento. E no ponto do torneio abre uma disputa jogável de cinco pênaltis por equipe: escolher canto, acertar a força entre 55 e 85, e escolher um lado para defender. Empate oferece revanche; a primeira vitória da Dinsara rende 15 sucatas e um registro. O torneio desaparece no epílogo.

Morcego e escorpião usam pixel art desenhada em código (`Scripts/enemy_pixel_art.gd`), com asas/patas animadas. O morcego trava a direção durante o aviso do mergulho; acertá-lo interrompe a investida. O escorpião avisa por 0,65 s, alterna tiro único com leque de três tiros, e perde o ataque preparado quando recebe dano. Linhas no chão mostram a direção. O chefão permanece sem dano de contato.

O laboratório anterior em `Imagens/Coltec/laboratorio_turma.png` foi preservado como histórico. A sala ampliada atual é desenhada em código por `Scripts/computer_lab.gd` e `Scripts/study_desk.gd`, com computadores em todas as mesas. Mesas não bloqueiam a passagem entre colegas. A arte do protagonista permanece intacta.

Validação adicional: `res://tests/turma_combat_test.tscn` passou, cobrindo acesso a cada estudante, exterior, banda, pênaltis, recompensa única, combo, energia, aparo, ataque forte, aviso e interrupção dos inimigos. Os testes anteriores de progressão e epílogo também passaram. As capturas reais estão em `output/coltec/laboratorio_turma.png`, `quadra.png`, `penaltis.png` e `inimigos.png`. Os testes anteriores ainda emitem avisos de recursos pendentes ao encerrar.


## Informática, professores e interfaces

Duda, Pedro Silva Freitas, PH, Saci e Tigas voltaram ao hall com trajetos de caminhada. A Toquempé permanece no palco. Bandeirolas e notas animadas reforçam o evento; desaparecem no epílogo.

Leando Maia dá aula de Java no quadro do laboratório de informática. Os 38 estudantes estão separados por 160 pixels na horizontal e 115 na vertical (antes: 85 × 57). Três computadores na frente oferecem prever a saída (laços, strings e arrays), depurar (ponto e vírgula e limites de array) e montar classe/main/instrução/fechamento. Cada exercício permite tentar novamente e rende 8 sucatas uma única vez. O professor também abre a seleção de exercícios. São exercícios de lógica, sem execução arbitrária de código.

A oficina agora se chama Sala de metal e contém o professor Geovane com cabelo branco e uma atividade introdutória sobre a ordem do trabalho.

O torneio se chama **Dinsara × Estelionatários** em toda a interface. A grafia Disnara da lore permanece intacta.

As interações usam fundos próprios desenhados em código: diário com papel pautado e espiral; conversa em balão; Java em terminal; música com teclado; circuito/metal com painel e parafusos; futebol com gramado; memórias com papel. Os botões seguem as cores de cada contexto. Escape continua fechando e devolvendo o controle.

Validação: `tests/java_ui_test.tscn` cobre câmera, hall, professores, os três exercícios (erro e acerto), recompensas únicas e seleção dos temas. Também passaram novamente os testes de aventura, combate/turma e epílogo. Capturas: `output/coltec/ui_diario.png`, `ui_conversa.png`, `ui_java.png`, `ui_metal.png`, `ui_circuito.png`, `laboratorio_turma.png` e `computadores.png`. Persistem avisos de instâncias/recursos pendentes ao encerrar os testes, sem falha nas asserções.
