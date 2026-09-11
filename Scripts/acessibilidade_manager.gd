extends Node
const CONFIG_PATH := "user://disnera_acessibilidade.cfg"
var alto_contraste_ativado := false
var filtro: ColorRect

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	carregar_configuracao()
	criar_filtro()
	atualizar_filtro()
	
func esta_em_alto_contraste() -> bool:
	return alto_contraste_ativado
	
func definir_alto_contraste(ativado: bool) -> void:
	if alto_contraste_ativado == ativado:
		return
		
	alto_contraste_ativado = ativado
	salvar_configuracao()
	atualizar_filtro()
	
func criar_filtro() -> void:
	var camada := CanvasLayer.new()
	camada.name = "CamadaAcessibilidade"
	camada.layer = 100
	
	add_child(camada)
	
	filtro = ColorRect.new()
	filtro.name = "FiltroAltoContraste"
	filtro.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	filtro.mouse_filter = Control.MOUSE_FILTER_IGNORE
	filtro.color = Color.WHITE
	
	var shader := Shader.new()
	shader.code = """
shader_type canvas_item;

uniform sampler2D screen_texture :
	hint_screen_texture,
	repeat_disable,
	filter_nearest;

uniform float contraste : hint_range(1.0, 3.0) = 1.5;
uniform float saturacao : hint_range(0.0, 2.0) = 1.2;
uniform float brilho : hint_range(0.0, 0.4) = 0.04;

void fragment() {
	vec4 cor_da_tela = textureLod(screen_texture, SCREEN_UV, 0.0);

	float luminosidade = dot(
		cor_da_tela.rgb,
		vec3(0.2126, 0.7152, 0.0722)
	);

	vec3 cor = mix(
		vec3(luminosidade),
		cor_da_tela.rgb,
		saturacao
	);

	cor = (cor - vec3(0.5)) * contraste + vec3(0.5);
	cor += vec3(brilho);
	cor = pow(max(cor, vec3(0.0)), vec3(0.9));

	COLOR = vec4(clamp(cor, vec3(0.0), vec3(1.0)), 1.0);
}
"""
	var material := ShaderMaterial.new()
	material.shader = shader
	filtro.material = material
	camada.add_child(filtro)
	
func atualizar_filtro() -> void:
	if is_instance_valid(filtro):
		filtro.visible = alto_contraste_ativado
		
func carregar_configuracao() -> void:
	var config := ConfigFile.new()
	if config.load(CONFIG_PATH) == OK:
		alto_contraste_ativado = config.get_value(
			"acessibilidade",
			"alto_contraste",
			false
		)
		
func salvar_configuracao() -> void:
	var config := ConfigFile.new()
	config.set_value(
		"acessibilidade",
		"alto_contraste",
		alto_contraste_ativado
	)
	config.save(CONFIG_PATH)
