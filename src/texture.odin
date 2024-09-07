package funhalla

import gl "vendor:OpenGL"
import "vendor:stb/image"

load_texture :: proc(path: cstring) {
  texture_id : u32

  gl.GenTextures(1, &texture_id)

  width, height, nr_components : u32
}
