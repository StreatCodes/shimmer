#version 330 core
layout (location = 0) in vec2 pos;

void main() {
    float x = (pos.x / 1280) - 1.0;
    float y = (pos.y / 720) - 1.0;

    gl_Position = vec4(x, -y, 0.0, 1.0);
}