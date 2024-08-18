package shader

import "core:math/linalg"
import "core:os"
import "core:strings"
import gl "vendor:OpenGL"

Shader :: struct {
	id: u32,
}

SHADER_LOAD_ERROR :: -1
SHADER_OK :: 0

Vec3 :: linalg.Vector3f32
Mat4 :: linalg.Matrix4x4f32

shader_init :: proc(vsp, fsp: string) -> (^Shader, int) {
	assert(os.is_file_path(vsp))
	assert(os.is_file_path(fsp))

	program_id, ok := gl.load_shaders_file(vsp, fsp)

	if !ok {
		return nil, SHADER_LOAD_ERROR
	}

	shader := new(Shader)
	shader.id = program_id

	return shader, SHADER_OK
}

use :: proc(using shader: ^Shader) {
	gl.UseProgram(id)
}

set_bool :: proc(using shader: ^Shader, name: cstring, value: bool) {
	gl.Uniform1i(gl.GetUniformLocation(id, name), i32(value))
}

set_i32 :: proc(using shader: ^Shader, name: cstring, value: i32) {
	gl.Uniform1i(gl.GetUniformLocation(id, name), value)
}

set_f32 :: proc(using shader: ^Shader, name: cstring, value: f32) {
	gl.Uniform1f(gl.GetUniformLocation(id, name), value)
}

set_vec3 :: proc(using shader: ^Shader, name: cstring, value: [^]f32) {
	gl.Uniform3fv(gl.GetUniformLocation(id, name), 1, value)
}

set_mat4 :: proc(using shader: ^Shader, name: cstring, value: [^]f32) {
	gl.UniformMatrix4fv(gl.GetUniformLocation(id, name), 1, gl.FALSE, value)
}

set_value :: proc {
	set_i32,
	set_f32,
	set_bool,
}
