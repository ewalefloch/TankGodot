shader_type spatial;

uniform sampler2D albedo_tex;
uniform float tile = 1.0;    // répétition le long de l'axe
uniform float scroll = 0.0;  // on anime ce paramètre depuis GDScript
uniform int axis = 2;        // 0=x, 1=y, 2=z  -> axe local le long duquel on fait défiler

varying vec3 local_pos;

void vertex() {
	local_pos = VERTEX; // position locale (MagicaVoxel export garde la topologie)
}

void fragment() {
	// mapping simple basé sur la position locale : on génère des uv fictives à partir de local_pos
	float along = local_pos.z;
	if (axis == 0) along = local_pos.x;
	else if (axis == 1) along = local_pos.y;

	// uv.x = coordonnée le long de la chenille (scrollable)
	// uv.y = coord transversale (on peut utiliser local_pos.x pour la largeur)
	vec2 uv = vec2(along * tile + scroll, local_pos.x * tile);

	// Si ton mesh a des UVs valides, tu peux préférer utiliser UV directement :
	// vec4 t = texture(albedo_tex, UV + vec2(scroll, 0.0));
	// ALBEDO = t.rgb;

	vec4 t = texture(albedo_tex, uv);
	ALBEDO = t.rgb;
	ALPHA = t.a;
}
