#version 330 core

out vec4 FragColor;

in vec3 Normal;
in vec3 FragPos;

uniform vec3 object_color;
uniform vec3 light_color;
uniform vec3 light_position;

void main() {
  float ambient_stength = 0.1;
  vec3 ambient = ambient_stength * light_color;

  vec3 norm = normalize(Normal);
  vec3 light_dir = normalize(light_position - FragPos);
  float diff = max(dot(norm, light_dir), 0.0);
  vec3 diffuse = diff * light_color;
  
  vec3 result = (ambient + diffuse) * object_color;
  FragColor = vec4(result, 1.0);
}

