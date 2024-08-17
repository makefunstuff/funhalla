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


camera := cam.camera_init(Vec3{0.0, 0.0, 0.3})

first_mouse := true
last_x: f32 = 800.0 / 2.0
last_y: f32 = 800.0 / 2.0

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

	shdr, err := shader.shader_init("res/shaders/triangle.vs", "res/shaders/triangle.fs")
	if err == shader.SHADER_LOAD_ERROR {
		fmt.eprintln("Could not initialize shader")
		return
	}

	vertices: []f32 = {
		-0.5,
		-0.5,
		-0.5,
		0.0,
		0.0,
		0.5,
		-0.5,
		-0.5,
		1.0,
		0.0,
		0.5,
		0.5,
		-0.5,
		1.0,
		1.0,
		0.5,
		0.5,
		-0.5,
		1.0,
		1.0,
		-0.5,
		0.5,
		-0.5,
		0.0,
		1.0,
		-0.5,
		-0.5,
		-0.5,
		0.0,
		0.0,
		-0.5,
		-0.5,
		0.5,
		0.0,
		0.0,
		0.5,
		-0.5,
		0.5,
		1.0,
		0.0,
		0.5,
		0.5,
		0.5,
		1.0,
		1.0,
		0.5,
		0.5,
		0.5,
		1.0,
		1.0,
		-0.5,
		0.5,
		0.5,
		0.0,
		1.0,
		-0.5,
		-0.5,
		0.5,
		0.0,
		0.0,
		-0.5,
		0.5,
		0.5,
		1.0,
		0.0,
		-0.5,
		0.5,
		-0.5,
		1.0,
		1.0,
		-0.5,
		-0.5,
		-0.5,
		0.0,
		1.0,
		-0.5,
		-0.5,
		-0.5,
		0.0,
		1.0,
		-0.5,
		-0.5,
		0.5,
		0.0,
		0.0,
		-0.5,
		0.5,
		0.5,
		1.0,
		0.0,
		0.5,
		0.5,
		0.5,
		1.0,
		0.0,
		0.5,
		0.5,
		-0.5,
		1.0,
		1.0,
		0.5,
		-0.5,
		-0.5,
		0.0,
		1.0,
		0.5,
		-0.5,
		-0.5,
		0.0,
		1.0,
		0.5,
		-0.5,
		0.5,
		0.0,
		0.0,
		0.5,
		0.5,
		0.5,
		1.0,
		0.0,
		-0.5,
		-0.5,
		-0.5,
		0.0,
		1.0,
		0.5,
		-0.5,
		-0.5,
		1.0,
		1.0,
		0.5,
		-0.5,
		0.5,
		1.0,
		0.0,
		0.5,
		-0.5,
		0.5,
		1.0,
		0.0,
		-0.5,
		-0.5,
		0.5,
		0.0,
		0.0,
		-0.5,
		-0.5,
		-0.5,
		0.0,
		1.0,
		-0.5,
		0.5,
		-0.5,
		0.0,
		1.0,
		0.5,
		0.5,
		-0.5,
		1.0,
		1.0,
		0.5,
		0.5,
		0.5,
		1.0,
		0.0,
		0.5,
		0.5,
		0.5,
		1.0,
		0.0,
		-0.5,
		0.5,
		0.5,
		0.0,
		0.0,
		-0.5,
		0.5,
		-0.5,
		0.0,
		1.0,
	}


	vbo, vao, texture1, texture2: u32
	gl.GenVertexArrays(1, &vao)
	gl.GenBuffers(1, &vbo)

	gl.BindVertexArray(vao)
	gl.BindBuffer(gl.ARRAY_BUFFER, vbo)

	gl.BufferData(
		gl.ARRAY_BUFFER,
		size_of(f32) * len(vertices),
		raw_data(vertices),
		gl.STATIC_DRAW,
	)

	gl.VertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, 5 * size_of(f32), 0)
	gl.EnableVertexAttribArray(0)

	gl.VertexAttribPointer(1, 2, gl.FLOAT, gl.FALSE, 5 * size_of(f32), 3 * size_of(f32))
	gl.EnableVertexAttribArray(1)

	gl.GenTextures(1, &texture1)
	gl.BindTexture(gl.TEXTURE_2D, texture1)
	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.REPEAT)
	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.REPEAT)

	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR_MIPMAP_LINEAR)
	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR)

	width, height, nr_channels: libc.int
	assert(os.is_file_path("res/images/container.jpg"))
	data := image.load("res/images/container.jpg", &width, &height, &nr_channels, 0)

	if data != nil {
		gl.TexImage2D(
			gl.TEXTURE_2D,
			0,
			gl.RGB,
			i32(width),
			i32(height),
			0,
			gl.RGB,
			gl.UNSIGNED_BYTE,
			data,
		)
		gl.GenerateMipmap(gl.TEXTURE_2D)
	} else {
		fmt.eprintln("Failed to load texture")
		return
	}
	image.image_free(data)

	gl.GenTextures(1, &texture2)
	gl.BindTexture(gl.TEXTURE_2D, texture2)
	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.REPEAT)
	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.REPEAT)

	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR_MIPMAP_LINEAR)
	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR)

	image.set_flip_vertically_on_load(1)

	assert(os.is_file_path("res/images/awesomeface.png"))
	data = image.load("res/images/awesomeface.png", &width, &height, &nr_channels, 0)

	if data != nil {
		gl.TexImage2D(
			gl.TEXTURE_2D,
			0,
			gl.RGBA,
			i32(width),
			i32(height),
			0,
			gl.RGBA,
			gl.UNSIGNED_BYTE,
			data,
		)
		gl.GenerateMipmap(gl.TEXTURE_2D)
	} else {
		fmt.eprintln("Failed to load texture")
		return
	}
	image.image_free(data)

	shader.use(shdr)
	shader.set_value(shdr, cstring("texture1"), 0)
	shader.set_value(shdr, cstring("texture2"), 1)

	//gl.PolygonMode(gl.FRONT_AND_BACK, gl.LINE)

	gl.Enable(gl.DEPTH_TEST)

	cube_positions: []linalg.Vector3f32 = {
		linalg.Vector3f32{0.0, 0.0, 0.0},
		linalg.Vector3f32{2.0, 5.0, -15.0},
		linalg.Vector3f32{-1.5, -2.2, -2.5},
		linalg.Vector3f32{-3.8, -2.0, -12.3},
		linalg.Vector3f32{2.4, -0.4, -3.5},
		linalg.Vector3f32{-1.7, 3.0, -7.5},
		linalg.Vector3f32{1.3, -2.0, -2.5},
		linalg.Vector3f32{1.5, 2.0, -2.5},
		linalg.Vector3f32{1.5, 0.2, -1.5},
		linalg.Vector3f32{-1.3, 1.0, -1.5},
	}

	for !glfw.WindowShouldClose(window) {
		current_frame: f32 = f32(glfw.GetTime())
		delta_time = current_frame - last_frame
		last_frame = current_frame

		process_input(&window)

		gl.ClearColor(0.2, 0.3, 0.3, 1.0)
		gl.Clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT)

		gl.ActiveTexture(gl.TEXTURE0)
		gl.BindTexture(gl.TEXTURE_2D, texture1)
		gl.ActiveTexture(gl.TEXTURE1)
		gl.BindTexture(gl.TEXTURE_2D, texture2)


		aspect: f32 = 800.0 / 600.0

		view := cam.get_view_matrix(camera)

		projection := linalg.matrix4_perspective_f32(
			linalg.to_radians(camera.zoom),
			aspect,
			0.1,
			100.0,
		)

		view_location := gl.GetUniformLocation(shdr.id, "view")
		gl.UniformMatrix4fv(view_location, 1, gl.FALSE, &view[0][0])

		projection_location := gl.GetUniformLocation(shdr.id, "projection")
		gl.UniformMatrix4fv(projection_location, 1, gl.FALSE, &projection[0][0])

		shader.use(shdr)


		gl.BindVertexArray(vao)

		for cube_position, i in cube_positions {
			model := linalg.matrix4_translate(cube_position)
			angle: f32 = linalg.to_radians(20.0 * cast(f32)i)
			model *= linalg.matrix4_rotate(angle, linalg.Vector3f32{1.0, 0.3, 0.5})


			model_location := gl.GetUniformLocation(shdr.id, "model")
			gl.UniformMatrix4fv(model_location, 1, gl.FALSE, &model[0][0])


			gl.DrawArrays(gl.TRIANGLES, 0, 36)
		}


		glfw.SwapBuffers(window)
		glfw.PollEvents()
	}

	gl.DeleteVertexArrays(1, &vao)
	gl.DeleteBuffers(1, &vbo)
}
