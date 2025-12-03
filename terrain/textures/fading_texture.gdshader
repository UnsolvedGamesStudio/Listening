shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_disabled, diffuse_burley, specular_schlick_ggx;

// --- Base material ---
uniform vec4 albedo : source_color;
uniform sampler2D texture_albedo : source_color, filter_nearest_mipmap, repeat_enable;

uniform float metallic : hint_range(0.0, 1.0, 0.01);
uniform float roughness : hint_range(0.0, 1.0);
uniform float specular : hint_range(0.0, 1.0, 0.01);

uniform vec3 uv1_scale;
uniform vec3 uv1_offset;

// --- Fade texture ---
uniform sampler2D fade_texture : source_color, filter_nearest_mipmap, repeat_enable;

// --- Fade curve (Curve Texture) ---
uniform sampler2D fade_curve; // width ≥ 2, height = 1

// --- Animation parameters ---
uniform float fade_duration = 10.0; // seconds
uniform float fade_speed = 1.0;      // multiplier

void vertex() {
    UV = UV * uv1_scale.xy + uv1_offset.xy;
}

void fragment() {
    vec2 base_uv = UV;

    // --- Sample albedo ---
    vec3 base_rgb = albedo.rgb * texture(texture_albedo, base_uv).rgb;
    vec3 fade_rgb = texture(fade_texture, base_uv).rgb;

    // --- Compute normalized time along curve with duration ---
    float t = fract((TIME / fade_duration) * fade_speed); // loops automatically 0->1

    // --- Sample curve for easing ---
    float eased_t = t;
    if (textureSize(fade_curve,0).x > 1) {
        eased_t = texture(fade_curve, vec2(clamp(t,0.0,1.0), 0.0)).r;
        eased_t = clamp(eased_t, 0.0, 1.0);
    }

    // --- Blend albedo ---
    ALBEDO = mix(base_rgb, fade_rgb, eased_t);

    // --- Use scalar metallic / roughness values only ---
    METALLIC = metallic;
    SPECULAR = specular;
    ROUGHNESS = roughness;
}


