#version 330 core
out vec4 color;

uniform vec2 mouse_cords;
uniform ivec2 window_size;

void main() {

    vec2 uv = gl_FragCoord.xy / window_size;
    vec2 mouse = mouse_cords / gl_FragCoord.xy;

    // if(abs(uv - mouse_cords) < vec2(5,5) ) {

    // }

    color = vec4(mouse.xy, 0.2, 1.0);
}