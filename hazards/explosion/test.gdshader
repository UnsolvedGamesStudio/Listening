shader_type spatial;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back;

uniform sampler2D tex: hint_albedo;

varying float y_pos;


float depth_to_plane(vec3 dir, vec3 origin, vec3 normal) {
	float denom = dot(normal, dir);
	if (abs(denom) > 1e-5) return dot(origin, normal) / denom;
	else return -1.0;
}


void vertex() {
	// Straight billboard
	mat4 normal_billboard = mat4(
		CAMERA_MATRIX[0],
		CAMERA_MATRIX[1],
		CAMERA_MATRIX[2],
		WORLD_MATRIX[3]
	);

	// Y billboard
	mat4 y_billboard = mat4(
		vec4(normalize(cross(vec3(0.0, 1.0, 0.0), CAMERA_MATRIX[2].xyz)), 0.0),
		vec4(0.0, 1.0, 0.0, 0.0),
		vec4(normalize(cross(CAMERA_MATRIX[0].xyz, vec3(0.0, 1.0, 0.0))), 0.0),
		WORLD_MATRIX[3]
	);

	// Straight billboard with Y billboard shading
	mat4 billboard = mat4(
		CAMERA_MATRIX[0],
		CAMERA_MATRIX[1],
		vec4(normalize(cross(CAMERA_MATRIX[0].xyz, vec3(0.0, 1.0, 0.0))), 0.0),
		WORLD_MATRIX[3]
	);

	MODELVIEW_MATRIX = INV_CAMERA_MATRIX * normal_billboard;

	y_pos = VERTEX.y;
}


void fragment() {
	// plane origins are both vec3(0.0) in this frame of reference
	vec3 point = CAMERA_MATRIX[3].xyz - WORLD_MATRIX[3].xyz;
	vec3 front_normal = normalize(vec3(point.x, 0.0, point.z));
	// transform all from world space to view space
	vec3 point_vs = (INV_CAMERA_MATRIX * vec4(point, 0.0)).xyz;
	front_normal = (INV_CAMERA_MATRIX * vec4(front_normal, 0.0)).xyz;
	vec3 up = (INV_CAMERA_MATRIX * vec4(vec3(0.0, 1.0, 0.0), 0.0)).xyz;

	float vert_depth = depth_to_plane(VIEW, point_vs, front_normal);
	float lat_depth = depth_to_plane(VIEW, point_vs, up);
	// abs() or not?
	vert_depth = abs(vert_depth);
	lat_depth = abs(lat_depth);

	// magic margin on lateral depth
	lat_depth -= 0.1;

	float above = float(point.y > 0.0);
	float upper_depth = min(vert_depth, lat_depth) * above + vert_depth * (1.0 - above);
	float depth = float(y_pos >= 0.0) * upper_depth + float(y_pos < 0.0) * min(vert_depth, lat_depth);

	vec4 clip = PROJECTION_MATRIX * vec4(VERTEX.xy, -depth, 1.0);
	DEPTH = 0.5 * clip.z / clip.w + 0.5;
	ALBEDO = texture(tex, UV).rgb;
}