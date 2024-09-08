package funhalla

import gl "vendor:OpenGL"

Vertex :: struct {
  position: Vec3,
  normal: Vec3,
  tex_coords: Vec2
}

Texture :: struct {
  id: u32,
  type: string
}

Mesh :: struct {
  vertices: [dynamic]Vertex,
  indices: [dynamic]u32,
  textures: [dynamic]Texture,

  vao, vbo, ebo: u32
}


mesh_init :: proc(vertices: [dynamic]Vertex, indices: [dynamic]u32, textures: [dynamic]Texture) -> ^Mesh {
  mesh := new(Mesh)
  mesh.vertices = vertices
  mesh.indices = indices
  mesh.textures = textures

  _setup_mesh(mesh)

  return mesh
}

mesh_draw :: proc() {

}

@(private)
_setup_mesh :: proc(using mesh: ^Mesh) {
  using gl

  GenVertexArrays(1, &vao)
  GenBuffers(1, &vbo)
  GenBuffers(1, &ebo)

  BindVertexArray(vao)
  BindBuffer(ARRAY_BUFFER, vbo)


}
