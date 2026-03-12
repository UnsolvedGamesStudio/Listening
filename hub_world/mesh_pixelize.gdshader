shader_type spatial;
// Keeping it unshaded to match your previous look, remove this line if you want shadows/light to affect it
render_mode unshaded; 

// This creates a slot in the inspector to drop your mesh's texture
uniform sampler2D albedo_texture : source_color, filter_nearest; 

// This controls how blocky the texture gets. Lower number = chunkier pixels.
uniform float pixel_resolution = 64.0; 

void fragment() {
    // 1. Take the smooth UV map, multiply it by the resolution, round it off, then divide it back.
    // This creates a "stepped" grid instead of a smooth gradient.
    vec2 stepped_uv = round(UV * pixel_resolution) / pixel_resolution;

    // 2. Read the color of your texture using those new blocky coordinates
    vec4 tex_color = texture(albedo_texture, stepped_uv);
    
    // 3. Apply it to the mesh
    ALBEDO = tex_color.rgb;
    
    // 4. Preserve transparency if your texture has an alpha channel
    ALPHA = tex_color.a; 
}