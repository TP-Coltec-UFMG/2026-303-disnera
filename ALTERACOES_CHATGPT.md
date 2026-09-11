# Alterações realizadas

## Estrutura anterior preservada

- Menu inicial mantido.
- Cutscene de entrada nos esgotos mantida.
- Cinco fases totais mantidas, com objetivo de partida completa em até ~10 minutos.

## Controles

- WASD / setas: movimentação.
- Clique esquerdo **ou** clique direito: ataque.
- Espaço / Shift / Q: dash, com recarga curta e invulnerabilidade durante o impulso.
- E: interação com alavancas.
- Espaço durante a cutscene: pular a cutscene.

## Novas mecânicas de inimigos

- Ratos: perseguição corpo a corpo simples, 40 HP e 8 de dano.
- Morcegos: 30 HP; circulam/voam próximos do jogador, fazem uma curta preparação visual e então executam mergulhos rápidos em linha reta. Dano do mergulho: 10.
- Escorpiões: 55 HP; tentam manter distância, movimentam-se lateralmente e disparam bolas roxas de veneno a distância. Cada projétil causa 12 de dano.
- Ratão: aumentado para 450 HP e com resistência maior a stun. Alterna entre:
  - **Chuva de meteoros:** marca círculos no chão e, após o aviso, atinge as áreas marcadas. Na segunda metade da vida aparecem mais zonas.
  - **Baforada de veneno:** marca um grande cone roxo à frente do Ratão e ataca o cone após um curto aviso.
  - Além disso, continua podendo perseguir e causar dano corpo a corpo.

## Cura e drops

- Cada inimigo comum tem 12% de chance de derrubar um coração ao morrer.
- O coração reutiliza `Imagens/UI/Heart_cheio.png`, o mesmo sprite do HUD.
- Coletar o coração recupera 20 pontos de vida, sem ultrapassar a vida máxima.
- O coração desaparece após alguns segundos se não for coletado.

## Puzzle das alavancas

- Na fase imediatamente anterior ao puzzle foi adicionada a dica: **"DICA PARA A PRÓXIMA SALA: a resposta é 5 em binário."**
- A combinação existente permanece `101` (ON - OFF - ON), equivalente a 5 em binário.
- Ao se aproximar de cada alavanca aparece um pequeno indicador com a tecla **E**.

## Balanceamento

- A quantidade de inimigos e as cinco salas foram preservadas da versão anterior.
- Os novos padrões substituem aumento artificial de quantidade: morcegos exigem esquiva, escorpiões exigem movimentação contra projéteis e o Ratão exige leitura das marcações no chão.
- O boss ficou mais resistente, mas os ataques especiais possuem aviso visual para permitir reação com movimento/dash.
