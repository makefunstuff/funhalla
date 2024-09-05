#version 330 core
struct Material {
  vec3 ambient;
  vec3 diffuse;
  vec3 specular;
  float shininess;
};

out vec4 FragColor;

in vec3 Normal;
in vec3 FragPos;

uniform vec3 light_color;
uniform vec3 light_position;
uniform vec3 view_position;

uniform Material material;

void main() {
  // ambient
  vec3 ambient = light_color * material.ambient;

  // diffuse
  vec3 norm = normalize(Normal);
  vec3 light_dir = normalize(light_position - FragPos);
  float diff = max(dot(norm, light_dir), 0.0);
  vec3 diffuse = light_color * (diff * material.diffuse);

  // specular
  vec3 view_dir = normalize(view_position - FragPos);
  vec3 reflect_dir = reflect(-light_dir, norm);
  float spec = pow(max(dot(view_dir, reflect_dir), 0.0), material.shininess);
  vec3 specular = light_color * (spec * material.specular);

  vec3 result = ambient + diffuse + specular;
  FragColor = vec4(result, 1.0);
}

