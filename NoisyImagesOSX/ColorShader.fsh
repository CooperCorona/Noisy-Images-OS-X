#version 150

in vec3 v_Color;

out vec4 c_gl_FragColor;

void main(void) {
    c_gl_FragColor = vec4(v_Color, 1.0);
}