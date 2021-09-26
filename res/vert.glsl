#version 330 core
layout (location = 0) in vec2 pos;

uniform ivec2 window_size;

void main() {
    float x = ((pos.x / window_size.x * 2.0) - 1.0);
    float y = ((pos.y / window_size.y * 2.0) - 1.0);

    gl_Position = vec4(x, -y, 0.0, 1.0);
}