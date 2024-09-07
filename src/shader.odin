package funhalla

import "core:math/linalg"
import "core:strings"
import gl "vendor:OpenGL"

Shader :: struct {
	id: u32,
}

SHADER_LOAD_ERROR :: -1
SHADER_OK :: 0

shader_init :: proc(vsp, fsp: string) -> (^Shader, int) {
	program_id, ok := gl.load_shaders_file(vsp, fsp)

	if !ok {
		return nil, SHADER_LOAD_ERROR
	}

	shader := new(Shader)
	shader.id = program_id

	return shader, SHADER_OK
}

shader_use :: proc(using shader: ^Shader) {
	gl.UseProgram(id)
}

shader_set_bool :: proc(using shader: ^Shader, name: cstring, value: bool) {
	gl.Uniform1i(gl.GetUniformLocation(id, name), i32(value))
}

shader_set_i32 :: proc(using shader: ^Shader, name: cstring, value: i32) {
	gl.Uniform1i(gl.GetUniformLocation(id, name), value)
}

shader_set_f32 :: proc(using shader: ^Shader, name: cstring, value: f32) {
	gl.Uniform1f(gl.GetUniformLocation(id, name), value)
}

shader_set_vec3 :: proc(using shader: ^Shader, name: cstring, value: ^Vec3) {
	gl.Uniform3fv(gl.GetUniformLocation(id, name), 1, &value[0])
}

shader_set_mat4 :: proc(using shader: ^Shader, name: cstring, value: ^Mat4) {
	gl.UniformMatrix4fv(gl.GetUniformLocation(id, name), 1, gl.FALSE, &value[0][0])
}

shader_set_value :: proc {
	shader_set_i32,
	shader_set_f32,
	shader_set_vec3,
	shader_set_mat4,
	shader_set_bool,
}
