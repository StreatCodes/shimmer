#version 330 core
layout(origin_upper_left) in vec4 gl_FragCoord;

out vec4 color;

uniform vec2 mouse_cords;
uniform ivec2 window_size;

void main() {
    vec2 uv = gl_FragCoord.xy / window_size;
    vec2 mouse = mouse_cords / gl_FragCoord.xy;

    color = vec4(mouse.xy, 0.2, 1.0);
}