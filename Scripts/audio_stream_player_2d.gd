##Classe gerente que trabalha com música dinâmica [br]
##Ela mantém o loop de música, dividindo a faixa em seções
##de loops diferentes que trocam dinamicamente [br] [br]
##[center][i]USE APENAS ARQUIVOS OGG VORBIS (.ogg) PARA AS FAIXAS.[/i] Por algum motivo que desconheço, 
##o Godot não aceita looping em faixas que não seja do formato Ogg Vorbis[/center] [br] [br]
class_name MusicManager extends AudioStreamPlayer


enum MusicState {INTRO, LOW, HIGH, EXTERNAL};

@export_category("Faixas")
##Primeira faixa a ser tocada quando a cena é carregada. [br]
##Não pode ser trocada enquanto estiver tocando, nem pode tocar de novo ao terminar. [br] 
##O [MusicManager] irá trocar imediamente para a faixa [member baixa] ao terminar de tocar a intro
@export var intro: AudioStreamOggVorbis;
##Versão menos intensa da música. [br]
##Pode ser alternada usando [method MusicManager.setBaixa]
@export var baixa: AudioStreamOggVorbis;
##Versão mais intensa da música. [br]
##Pode ser alternada usando [method MusicManager.setAlta]
@export var alta:  AudioStreamOggVorbis;

@export_category("Opções adicionais")
##Pula a intro ao tocar a música [br]
##(a faixa [member intro] pode ser [color=red]vazia[/color] nesse caso)
@export var pular_intro: bool;
##Ignora as funções [method MusicManager.setAlta], [method MusicManager.setBaixa]
##e [method MusicManager.trocarFaixa], e toca apenas a faixa [member baixa] [br]
##(A faixa [member alta] pode ser [color=red]vazia[/color] nesse caso)
@export var tocar_apenas_baixa: bool;

var musicstate: MusicState = MusicState.INTRO;
var elapsed: float = 0;

func _ready() -> void:
	print("MusicManager: Conectando ao canal \"Music\"...");
	self.set_bus(&"Music");
	print("Conectou com sucesso!" if (self.get_bus() != &"Master") 
		else "ERRO: O canal \"Music\" não existe. O tocador usará o canal Master"
	);
	
	baixa.set_loop(true);
	if !tocar_apenas_baixa:
		alta.set_loop(true);
	
	if pular_intro:
		musicstate = MusicState.LOW;
		self.stream = baixa;
	else:
		self.stream = intro;
		self.finished.connect(_end_intro);
	
	self.play();

func _process(delta: float) -> void:
	if musicstate != MusicState.EXTERNAL:
		elapsed += delta;
	
		if(elapsed > self.stream.get_length()): elapsed = 0;


##Troca para a faixa [member baixa]
func setBaixa() -> void:
	if(musicstate == MusicState.INTRO or tocar_apenas_baixa): return;
	
	musicstate = MusicState.LOW;
	self.stream = baixa;
	self.play(fmod(elapsed, baixa.get_length()));

##Troca para a faixa [member alta]
func setAlta() -> void:
	if(musicstate == MusicState.INTRO or tocar_apenas_baixa): return;
	
	musicstate = MusicState.HIGH;
	self.stream = alta;
	self.play(fmod(elapsed, alta.get_length()));

##Troca a faixa atual (se for [member alta], troca para a [member baixa], e vice-versa)
func trocarFaixa() -> void:
	if(musicstate == MusicState.INTRO or tocar_apenas_baixa): return;
	
	if musicstate == MusicState.LOW:
		setAlta();
	else: setBaixa();

##Toca uma faixa externa. Essa faixa não tocará em loop. [br]
##O parâmetro [param delay] determina uma pausa antes da faixa ser tocada [br]
##O parâmetro [param autoresume] determina se a faixa normal tocará logo após esta terminar. Caso seja falso,
##para retomar a faixa original, chame a função [method MusicManager.end_externa] ou qualquer função de troca de faixa dinâminca
func tocarFaixaExterna(faixa: AudioStream, delay: float = 0, autoresume: bool = false) -> void:
	if(musicstate == MusicState.INTRO): return;
	
	musicstate = MusicState.EXTERNAL;
	faixa.set_loop(false);
	self.stop();
	self.stream = faixa;
	if(autoresume):
		self.finished.connect(_end_external);
	
	await get_tree().create_timer(delay).timeout
	self.play();

##Para a introdução da música e troca para a faixa baixa
func _end_intro() -> void:
	if(musicstate != MusicState.INTRO or pular_intro): return;
	
	musicstate = MusicState.LOW;
	self.stream = baixa;
	self.play();
	#não é mais necessário verificar se a música acabou
	self.finished.disconnect(_end_intro);

##Para a faixa externa e troca para a faixa baixa
func _end_external():
	if(musicstate != MusicState.EXTERNAL): return;
	await get_tree().create_timer(1).timeout
	setBaixa();
	self.finished.disconnect(_end_external);
