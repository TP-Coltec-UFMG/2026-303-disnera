shader_type canvas_item;
render_mode unshaded;

// Troca somente a paleta: os pixels e os frames são os mesmos do protagonista.
uniform vec4 cabelo_escuro : source_color = vec4(0.365, 0.173, 0.157, 1.0);
uniform vec4 cabelo_claro : source_color = vec4(0.439, 0.275, 0.263, 1.0);
uniform vec4 pele_clara : source_color = vec4(0.965, 0.792, 0.624, 1.0);
uniform vec4 pele_sombra : source_color = vec4(0.824, 0.624, 0.439, 1.0);
uniform vec4 roupa_clara : source_color = vec4(0.2, 0.596, 0.294, 1.0);
uniform vec4 roupa_media : source_color = vec4(0.118, 0.435, 0.314, 1.0);
uniform vec4 roupa_sombra : source_color = vec4(0.075, 0.298, 0.298, 1.0);
uniform vec4 calca_clara : source_color = vec4(0.0, 0.596, 0.863, 1.0);
uniform vec4 calca_sombra : source_color = vec4(0.0, 0.412, 0.667, 1.0);

bool mesma_cor(vec3 a, vec3 b) { return distance(a, b / 255.0) < 0.009; }

void fragment() {
	vec4 pixel = texture(TEXTURE, UV);
	vec3 cor = pixel.rgb;
	if (mesma_cor(cor, vec3(93, 44, 40))) cor = cabelo_escuro.rgb;
	else if (mesma_cor(cor, vec3(112, 70, 67))) cor = cabelo_claro.rgb;
	else if (mesma_cor(cor, vec3(246, 202, 159))) cor = pele_clara.rgb;
	else if (mesma_cor(cor, vec3(210, 159, 112))) cor = pele_sombra.rgb;
	else if (mesma_cor(cor, vec3(51, 152, 75))) cor = roupa_clara.rgb;
	else if (mesma_cor(cor, vec3(30, 111, 80))) cor = roupa_media.rgb;
	else if (mesma_cor(cor, vec3(19, 76, 76))) cor = roupa_sombra.rgb;
	else if (mesma_cor(cor, vec3(0, 152, 220))) cor = calca_clara.rgb;
	else if (mesma_cor(cor, vec3(0, 105, 170))) cor = calca_sombra.rgb;
	COLOR = vec4(cor, pixel.a);
}
