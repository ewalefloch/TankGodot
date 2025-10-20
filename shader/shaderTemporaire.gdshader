shader_type spatial;
render_mode unshaded; // retire "unshaded" si tu veux l'éclairer normalement

uniform vec4 color1 : source_color = vec4(0.8, 0.8, 0.8, 1.0);
uniform vec4 color2 : source_color = vec4(0.15, 0.15, 0.15, 1.0);
uniform float grid_size : hint_range(0.1, 50.0) = 2.0;
uniform float blend_smooth : hint_range(0.0, 1.0) = 0.15; // lissage entre projections
uniform bool use_smooth  = true; // si true -> smooth, sinon damier net

varying vec3 world_pos;
varying vec3 world_normal;

void vertex() {
	// position et normale en espace monde
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	world_normal = normalize((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz);
}

float checker2(vec2 uv) {
	vec2 f = floor(uv);
	return mod(f.x + f.y, 2.0);
}

void fragment() {
	// poids de blending basé sur la normale (abs)
	vec3 w = abs(world_normal);
	// éviter division par zéro
	float s = max(w.x + w.y + w.z, 1e-6);
	w /= s;

	// calculer les UV 2D pour chaque projection (PAS de vec3 contenant vec2)
	vec2 uv_x = world_pos.yz / grid_size; // projection pour l'axe X (utilise YZ)
	vec2 uv_y = world_pos.xz / grid_size; // projection pour l'axe Y (utilise XZ)
	vec2 uv_z = world_pos.xy / grid_size; // projection pour l'axe Z (utilise XY)

	// valeur damier par projection
	float m_x = checker2(uv_x);
	float m_y = checker2(uv_y);
	float m_z = checker2(uv_z);

	// moyenne pondérée par la normale
	float m_weighted = m_x * w.x + m_y * w.y + m_z * w.z;

	float final_mask;
	if (use_smooth) {
		// lissage autour de 0.5
		float half = 0.5;
		float smooth_t = clamp((m_weighted - (half - blend_smooth)) / (2.0 * blend_smooth), 0.0, 1.0);
		final_mask = smoothstep(0.0, 1.0, smooth_t);
	} else {
		// damier net
		final_mask = step(0.5, m_weighted);
	}

	vec3 col = mix(color1.rgb, color2.rgb, final_mask);

	ALBEDO = col;
	ALPHA = 1.0;
}
