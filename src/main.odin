package funhalla
import gl "vendor:OpenGL"
import "vendor:glfw"

import "base:intrinsics"
import "base:runtime"
import "core:c/libc"
import "core:fmt"
import "core:math"
import "core:math/linalg"
import "core:os"

Vec3 :: linalg.Vector3f32
Mat4 :: linalg.Matrix4x4f32

GL_MAJOR_VERSION :: 3
GL_MINOR_VERSION :: 3


delta_time: f32 = 0.0
last_frame: f32 = 0.0

SCREEN_WIDTH: f32 : 800.0
SCREEN_HEIGTH: f32 : 600.0


camera := camera_init(Vec3{0.0, 0.0, 3.0})

first_mouse := true
last_x: f32 = 800.0 / 2.0
last_y: f32 = 800.0 / 2.0

light_pos := Vec3{1.2, 1.0, 2.0}

framebuffer_size_callback :: proc "cdecl" (window: glfw.WindowHandle, width, height: i32) {
	gl.Viewport(0, 0, width, height)
}

mouse_callback :: proc "cdecl" (window: glfw.WindowHandle, xpos_in, ypos_in: f64) {
	context = runtime.default_context()
	xpos: f32 = f32(xpos_in)
	ypos: f32 = f32(ypos_in)

	if first_mouse {
		last_x = xpos
		last_y = ypos
		first_mouse = false
	}

	xoffset: f32 = xpos - last_x
	yoffset: f32 = last_y - ypos
	last_x = xpos
	last_y = ypos

	process_mouse_move(camera, xoffset, yoffset)
}

mouse_scroll_callback :: proc "cdecl" (window: glfw.WindowHandle, xoffset, yoffset: f64) {
	context = runtime.default_context()
	process_mouse_scroll(camera, f32(yoffset))
}

process_input :: proc(window: ^glfw.WindowHandle) {
	if glfw.GetKey(window^, glfw.KEY_ESCAPE) == glfw.PRESS {
		glfw.SetWindowShouldClose(window^, true)
	}

	if glfw.GetKey(window^, glfw.KEY_W) == glfw.PRESS {
		process_keyboard(camera, CameraMovement.FORWARD, delta_time)
	}

	if glfw.GetKey(window^, glfw.KEY_S) == glfw.PRESS {
		process_keyboard(camera, CameraMovement.BACKWARD, delta_time)
	}

	if glfw.GetKey(window^, glfw.KEY_A) == glfw.PRESS {
		process_keyboard(camera, CameraMovement.LEFT, delta_time)
	}

	if glfw.GetKey(window^, glfw.KEY_D) == glfw.PRESS {
		process_keyboard(camera, CameraMovement.RIGHT, delta_time)
	}
}


main :: proc() {
	glfw.Init()

	glfw.WindowHint(glfw.CONTEXT_VERSION_MAJOR, GL_MAJOR_VERSION)
	glfw.WindowHint(glfw.CONTEXT_VERSION_MINOR, GL_MINOR_VERSION)
	glfw.WindowHint(glfw.OPENGL_PROFILE, glfw.OPENGL_CORE_PROFILE)

	when ODIN_OS == .Darwin {
		glfw.WindowHint(glfw.OPENGL_FORWARD_COMPAT, gl.TRUE)
	}

	window := glfw.CreateWindow(800, 600, "Funhalla Engine", nil, nil)

	defer glfw.Terminate()
	defer glfw.DestroyWindow(window)


	if window == nil {
		fmt.eprintln("Failed to create GLFW window")
		return
	}

	glfw.MakeContextCurrent(window)
	gl.load_up_to(GL_MAJOR_VERSION, GL_MINOR_VERSION, glfw.gl_set_proc_address)

	gl.Viewport(0, 0, 800, 600)
	glfw.SetFramebufferSizeCallback(window, framebuffer_size_callback)

	glfw.SetCursorPosCallback(window, mouse_callback)
	glfw.SetScrollCallback(window, mouse_scroll_callback)
	glfw.SetInputMode(window, glfw.CURSOR, glfw.CURSOR_DISABLED)


	vbo, light_cube_vao, cube_vao: u32
	gl.GenBuffers(1, &vbo)
	gl.BindBuffer(gl.ARRAY_BUFFER, vbo)

	gl.BufferData(
		gl.ARRAY_BUFFER,
		size_of(f32) * len(vertices),
		raw_data(vertices),
		gl.STATIC_DRAW,
	)

	gl.GenVertexArrays(1, &cube_vao)
	gl.BindVertexArray(cube_vao)
	gl.VertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, 8 * size_of(f32), 0)
	gl.EnableVertexAttribArray(0)
	gl.VertexAttribPointer(1, 3, gl.FLOAT, gl.FALSE, 8 * size_of(f32), 3 * size_of(f32))
	gl.EnableVertexAttribArray(1)
	gl.VertexAttribPointer(2, 2, gl.FLOAT, gl.FALSE, 8 * size_of(f32), 6 * size_of(f32))
	gl.EnableVertexAttribArray(2)

	gl.GenVertexArrays(1, &light_cube_vao)
	gl.BindVertexArray(light_cube_vao)
	gl.BindBuffer(gl.ARRAY_BUFFER, vbo)
	gl.VertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, 8 * size_of(f32), 0)
	gl.EnableVertexAttribArray(0)

	defer gl.DeleteVertexArrays(1, &light_cube_vao)
	defer gl.DeleteVertexArrays(1, &cube_vao)
	defer gl.DeleteBuffers(1, &vbo)
	diffuse_map := load_texture("res/images/container.png")
	specular_map := load_texture("res/images/container_specular.png")

	if diffuse_map == 0 {
		fmt.eprintln("could not load texture: exiting...")
		return
	}

	light_cube_shader, err := shader_init("res/shaders/light_cube.vs", "res/shaders/light_cube.fs")
	if err == SHADER_LOAD_ERROR {
		fmt.eprintln("Could not initialize shader")
		return
	}

	lighting_shader: ^Shader
	lighting_shader, err = shader_init("res/shaders/colors.vs", "res/shaders/colors.fs")

	if err == SHADER_LOAD_ERROR {
		fmt.eprintln("Could not initialize shader")
		return
	}

	shader_use(lighting_shader)
	shader_set_i32(lighting_shader, "material.diffuse", 0)
	shader_set_i32(lighting_shader, "material.specular", 1)
	//gl.PolygonMode(gl.FRONT_AND_BACK, gl.LINE)

	gl.Enable(gl.DEPTH_TEST)

	for !glfw.WindowShouldClose(window) {
		current_frame: f32 = f32(glfw.GetTime())
		delta_time = current_frame - last_frame
		last_frame = current_frame

		process_input(&window)

		gl.ClearColor(0.1, 0.1, 0.1, 1.0)
		gl.Clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT)


		shader_use(lighting_shader)

		material_ambient := Vec3{1.0, 0.5, 0.31}
		material_specular := Vec3{0.5, 0.5, 0.5}
		shader_set_vec3(lighting_shader, cstring("material.ambient"), &material_ambient)
		shader_set_vec3(lighting_shader, cstring("material.specular"), &material_specular)
		shader_set_f32(lighting_shader, cstring("material.shininess"), 32.0)

		light_diffuse := Vec3{0.5, 0.5, 0.05}
		light_ambient := Vec3{0.2, 0.2, 0.2}
		light_specular := Vec3{1.0, 1.0, 1.0}
		light_direction := Vec3{-0.2, -1.0, -0.3}

		shader_set_vec3(lighting_shader, "light.direction", &light_direction)
		shader_set_vec3(lighting_shader, cstring("light.ambient"), &light_ambient)
		shader_set_vec3(lighting_shader, cstring("light.diffuse"), &light_diffuse)
		shader_set_vec3(lighting_shader, cstring("light.specular"), &light_specular)

		shader_set_vec3(lighting_shader, cstring("light_position"), &light_pos)
		shader_set_vec3(lighting_shader, cstring("view_position"), &camera.position)

		aspect: f32 = 800.0 / 600.0
		projection := linalg.matrix4_perspective_f32(
			linalg.to_radians(camera.zoom),
			aspect,
			0.1,
			100.0,
		)

		view := get_view_matrix(camera)

		view_location := gl.GetUniformLocation(lighting_shader.id, "view")
		gl.UniformMatrix4fv(view_location, 1, gl.FALSE, &view[0][0])

		projection_location := gl.GetUniformLocation(lighting_shader.id, "projection")
		gl.UniformMatrix4fv(projection_location, 1, gl.FALSE, &projection[0][0])

		model := linalg.MATRIX4F32_IDENTITY
		shader_set_mat4(lighting_shader, cstring("model"), &model)

		gl.ActiveTexture(gl.TEXTURE0)
		gl.BindTexture(gl.TEXTURE_2D, diffuse_map)

		gl.ActiveTexture(gl.TEXTURE1)
		gl.BindTexture(gl.TEXTURE_2D, specular_map)

		gl.BindVertexArray(cube_vao)
		// gl.DrawArrays(gl.TRIANGLES, 0, 36)
		for position, i in cube_positions {
			model = linalg.MATRIX4F32_IDENTITY
			model *= linalg.matrix4_translate_f32(position)
			angle: f32 = linalg.to_radians(20.0 * f32(i))
			model *= linalg.matrix4_rotate_f32(angle, Vec3{1.0, 0.3, 0.5})

			shader_set_mat4(lighting_shader, "model", &model)
			gl.DrawArrays(gl.TRIANGLES, 0, 36)
		}

		//// lamp cube object drawing
		//shader_use(light_cube_shader)
		//shader_set_mat4(light_cube_shader, cstring("projection"), &projection)
		//shader_set_mat4(light_cube_shader, cstring("view"), &view)
		//
		//model = linalg.matrix4_translate_f32(light_pos)
		//model *= linalg.matrix4_scale_f32(Vec3{0.2, 0.2, 0.2})
		//shader_set_mat4(light_cube_shader, cstring("model"), &model)
		//
		//gl.BindVertexArray(light_cube_vao)
		//gl.DrawArrays(gl.TRIANGLES, 0, 36)

		glfw.SwapBuffers(window)
		glfw.PollEvents()
	}

}
