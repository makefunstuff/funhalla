package main
import gl "vendor:OpenGL"
import "vendor:glfw"
import "vendor:stb/image"

import "base:intrinsics"
import "base:runtime"
import "core:c/libc"
import "core:fmt"
import "core:math"
import "core:math/linalg"
import "core:os"

import cam "camera"
import "shader"

GL_MAJOR_VERSION :: 3
GL_MINOR_VERSION :: 3

Vec3 :: linalg.Vector3f32


delta_time: f32 = 0.0
last_frame: f32 = 0.0

SCREEN_WIDTH: f32 : 800.0
SCREEN_HEIGTH: f32 : 600.0


camera := cam.camera_init(Vec3{0.0, 0.0, 3.0})

first_mouse := true
last_x: f32 = 800.0 / 2.0
last_y: f32 = 800.0 / 2.0

light_pos := Vec3{1.2, 1.0, 2.0}

framebuffer_size_callback :: proc "cdecl" (window: glfw.WindowHandle, width, height: i32) {
	gl.Viewport(0, 0, width, height)
}

mouse_callback :: proc "cdecl" (window: glfw.WindowHandle, xpos_in, ypos_in: f64) {
	context = runtime.default_context()
	using cam
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
	using cam
	context = runtime.default_context()
	process_mouse_scroll(camera, f32(yoffset))
}

process_input :: proc(window: ^glfw.WindowHandle) {
	using cam
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

	light_cube_shader, err := shader.shader_init(
		"res/shaders/light_cube.vs",
		"res/shaders/light_cube.fs",
	)
	if err == shader.SHADER_LOAD_ERROR {
		fmt.eprintln("Could not initialize shader")
		return
	}

	lighting_shader: ^shader.Shader
	lighting_shader, err = shader.shader_init("res/shaders/colors.vs", "res/shaders/colors.fs")

	if err == shader.SHADER_LOAD_ERROR {
		fmt.eprintln("Could not initialize shader")
		return
	}

	vertices: []f32 = {
   -0.5, -0.5, -0.5,  0.0,  0.0, -1.0,
     0.5, -0.5, -0.5,  0.0,  0.0, -1.0, 
     0.5,  0.5, -0.5,  0.0,  0.0, -1.0, 
     0.5,  0.5, -0.5,  0.0,  0.0, -1.0, 
    -0.5,  0.5, -0.5,  0.0,  0.0, -1.0, 
    -0.5, -0.5, -0.5,  0.0,  0.0, -1.0, 

    -0.5, -0.5,  0.5,  0.0,  0.0, 1.0,
     0.5, -0.5,  0.5,  0.0,  0.0, 1.0,
     0.5,  0.5,  0.5,  0.0,  0.0, 1.0,
     0.5,  0.5,  0.5,  0.0,  0.0, 1.0,
    -0.5,  0.5,  0.5,  0.0,  0.0, 1.0,
    -0.5, -0.5,  0.5,  0.0,  0.0, 1.0,

    -0.5,  0.5,  0.5, -1.0,  0.0,  0.0,
    -0.5,  0.5, -0.5, -1.0,  0.0,  0.0,
    -0.5, -0.5, -0.5, -1.0,  0.0,  0.0,
    -0.5, -0.5, -0.5, -1.0,  0.0,  0.0,
    -0.5, -0.5,  0.5, -1.0,  0.0,  0.0,
    -0.5,  0.5,  0.5, -1.0,  0.0,  0.0,

     0.5,  0.5,  0.5,  1.0,  0.0,  0.0,
     0.5,  0.5, -0.5,  1.0,  0.0,  0.0,
     0.5, -0.5, -0.5,  1.0,  0.0,  0.0,
     0.5, -0.5, -0.5,  1.0,  0.0,  0.0,
     0.5, -0.5,  0.5,  1.0,  0.0,  0.0,
     0.5,  0.5,  0.5,  1.0,  0.0,  0.0,

    -0.5, -0.5, -0.5,  0.0, -1.0,  0.0,
     0.5, -0.5, -0.5,  0.0, -1.0,  0.0,
     0.5, -0.5,  0.5,  0.0, -1.0,  0.0,
     0.5, -0.5,  0.5,  0.0, -1.0,  0.0,
    -0.5, -0.5,  0.5,  0.0, -1.0,  0.0,
    -0.5, -0.5, -0.5,  0.0, -1.0,  0.0,

    -0.5,  0.5, -0.5,  0.0,  1.0,  0.0,
     0.5,  0.5, -0.5,  0.0,  1.0,  0.0,
     0.5,  0.5,  0.5,  0.0,  1.0,  0.0,
     0.5,  0.5,  0.5,  0.0,  1.0,  0.0,
    -0.5,  0.5,  0.5,  0.0,  1.0,  0.0,
    -0.5,  0.5, -0.5,  0.0,  1.0,  0.0
	}


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
	gl.VertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, 6 * size_of(f32), 0)
	gl.EnableVertexAttribArray(0)
	gl.VertexAttribPointer(1, 3, gl.FLOAT, gl.FALSE, 6 * size_of(f32), 3 * size_of(f32))
	gl.EnableVertexAttribArray(1)

	gl.GenVertexArrays(1, &light_cube_vao)
	gl.BindVertexArray(light_cube_vao)
	gl.BindBuffer(gl.ARRAY_BUFFER, vbo)
	gl.VertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, 6 * size_of(f32), 0)
	gl.EnableVertexAttribArray(0)

	//gl.PolygonMode(gl.FRONT_AND_BACK, gl.LINE)

	gl.Enable(gl.DEPTH_TEST)

	for !glfw.WindowShouldClose(window) {
		current_frame: f32 = f32(glfw.GetTime())
		delta_time = current_frame - last_frame
		last_frame = current_frame

		process_input(&window)

		gl.ClearColor(0.1, 0.1, 0.1, 1.0)
		gl.Clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT)


		shader.use(lighting_shader)
		object_color := Vec3{1.0, 0.5, 0.31}
		light_color := Vec3{1.0, 1.0, 1.0}
		shader.set_vec3(lighting_shader, cstring("object_color"), &object_color)
		shader.set_vec3(lighting_shader, cstring("light_color"), &light_color)
    shader.set_vec3(lighting_shader, cstring("light_position"), &light_pos)

		aspect: f32 = 800.0 / 600.0
		projection := linalg.matrix4_perspective_f32(
			linalg.to_radians(camera.zoom),
			aspect,
			0.1,
			100.0,
		)

		view := cam.get_view_matrix(camera)

		view_location := gl.GetUniformLocation(lighting_shader.id, "view")
		gl.UniformMatrix4fv(view_location, 1, gl.FALSE, &view[0][0])

		projection_location := gl.GetUniformLocation(lighting_shader.id, "projection")
		gl.UniformMatrix4fv(projection_location, 1, gl.FALSE, &projection[0][0])

		model := linalg.MATRIX4F32_IDENTITY
		shader.set_mat4(lighting_shader, cstring("model"), &model)

		gl.BindVertexArray(cube_vao)
		gl.DrawArrays(gl.TRIANGLES, 0, 36)

		shader.use(light_cube_shader)
		shader.set_mat4(light_cube_shader, cstring("projection"), &projection)
		shader.set_mat4(light_cube_shader, cstring("view"), &view)

		model = linalg.matrix4_translate_f32(light_pos)
		model *= linalg.matrix4_scale_f32(Vec3{0.2, 0.2, 0.2})
		shader.set_mat4(light_cube_shader, cstring("model"), &model)

		gl.BindVertexArray(light_cube_vao)
		gl.DrawArrays(gl.TRIANGLES, 0, 36)

		glfw.SwapBuffers(window)
		glfw.PollEvents()
	}

	gl.DeleteVertexArrays(1, &light_cube_vao)
	gl.DeleteVertexArrays(1, &cube_vao)
	gl.DeleteBuffers(1, &vbo)
}
