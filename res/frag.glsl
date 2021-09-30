#version 330 core
in vec2 tex_coord;

uniform sampler2D tex;
uniform vec2 mouse_cords;
uniform ivec2 window_size;

out vec4 color;

void main() {
    // vec2 uv = gl_FragCoord.xy / window_size;
    // vec2 mouse = mouse_cords / gl_FragCoord.xy;

    // color = vec4(mouse.xy, 0.2, 1.0);

    vec4 c = texture(tex, tex_coord);
    color = vec4(c.rrr, 1.0);
}