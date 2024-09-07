package funhalla

import gl "vendor:OpenGL"
import "vendor:stb/image"
import "core:log"

load_texture :: proc(path: cstring) -> u32 {
  texture_id : u32

  gl.GenTextures(1, &texture_id)

  x, y, nr_channels: i32

  data := image.load(path, &x, &y, &nr_channels, 0)
  defer image.image_free(data)

  if data != nil {
    format : i32
    if nr_channels == 1 {
      format = gl.RED
    } else if nr_channels == 3 {
      format = gl.RGB
    } else if nr_channels == 4 {
      format = gl.RGBA
    }
    gl.BindTexture(gl.TEXTURE_2D, texture_id)
    gl.TexImage2D(gl.TEXTURE_2D, 0, format, x, y, 0, auto_cast format, gl.UNSIGNED_BYTE, data)
    gl.GenerateMipmap(gl.TEXTURE_2D)

    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.REPEAT)
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.REPEAT)
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR_MIPMAP_LINEAR)
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR)
  } else {
    log.errorf("Failed to load texture at path: %s", path)
    return 0
  }

  return texture_id
}
