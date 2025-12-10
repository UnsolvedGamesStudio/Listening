shader_type canvas_item;

uniform float progress : hint_range(0.0, 1.0) = 1.0;        // angular wipe progress
uniform float scale : hint_range(0.0, 2.0) = 1.0;           // 1 = original size, <1 shrink, >1 grow
uniform vec2 center = vec2(0.5, 0.5);                       // center of wipe & scaling
uniform float direction : hint_range(-1.0, 1.0) = 1.0;      // 1 = clockwise, -1 = counterclockwise
uniform float start_angle : hint_range(0.0, 6.2831853) = 0.0; // starting angle in radians

void fragment() {
    // Scale the UVs around center
    vec2 uv_centered = UV - center;
    vec2 uv_scaled = uv_centered / scale + center;

    // Default color is transparent
    vec4 final_color = vec4(0.0);

    // Only process if inside UV bounds after scaling
    if (uv_scaled.x >= 0.0 && uv_scaled.x <= 1.0 && uv_scaled.y >= 0.0 && uv_scaled.y <= 1.0) {

        // Clock wipe calculation
        vec2 pos = uv_scaled - center;
        float angle = atan(pos.y, pos.x);          // -pi to pi
        angle = mod(angle - start_angle + 6.2831853, 6.2831853);
        if (direction < 0.0) {
            angle = 6.2831853 - angle;            // invert for counterclockwise
        }
        float angle_pct = angle / (2.0 * 3.14159265);

        // Apply both wipe and scale
        if (angle_pct <= progress) {
            final_color = texture(TEXTURE, uv_scaled);
        }
    }

    COLOR = final_color;
}
