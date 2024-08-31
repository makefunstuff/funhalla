#version 330 core

layout (location = 0) in vec3 a_pos;
layout (location = 1) in vec3 a_normal;

uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;

out vec3 Normal;
out vec3 FragPos;

void main() {
  FragPos = vec3(model * vec4(a_pos, 1.0));
  Normal = mat3(transpose(inverse(model))) * a_normal;

  gl_Position = projection * view  * vec4(FragPos, 1.0);
}
