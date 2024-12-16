shader_type spatial;
render_mode cull_front, unshaded, specular_disabled, shadows_disabled;
uniform vec4 albedo_color: source_color = vec4(0.03, 0.03, 0.03, 1.0);
uniform sampler2D texture_albedo : source_color;
uniform float outline_width: hint_range(0, 10.0, 0.1) = 2.0;
uniform float alpha_threshold: hint_range(0.0, 1.0, 0.01) = 0.5;

uniform vec3 light_direction = vec3(0.0, -1.0, 0.0);

void vertex() {
	vec4 clip_position = PROJECTION_MATRIX * (MODELVIEW_MATRIX * vec4(VERTEX, 1.0));
	vec3 clip_normal = mat3(PROJECTION_MATRIX) * (mat3(MODELVIEW_MATRIX) * NORMAL);
	
	vec2 offset = normalize(clip_normal.xy) / VIEWPORT_SIZE * clip_position.w * outline_width * 1.5;
	
	vec3 ld_local = normalize(light_direction);
	float NdotL = dot(MODEL_NORMAL_MATRIX * NORMAL, normalize(ld_local));
	float light_affect = clamp(NdotL, 0.25, 1.0);
	VERTEX += NORMAL * length(offset) * light_affect;
}


void fragment() {
//	discard;
	vec2 base_uv = UV;
	vec4 albedo_tex = texture(texture_albedo,base_uv);
	albedo_tex *= COLOR;
	ALBEDO = albedo_color.rgb * albedo_tex.rgb;
	float a = albedo_tex.a;
	if (a < 1.0) {
		if (a < alpha_threshold){
			discard;
		}
		else {
			ALPHA = a;
		}
	}
}