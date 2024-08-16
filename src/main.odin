package main
import gl "vendor:OpenGL"
import "vendor:glfw"

import "base:intrinsics"
import "base:runtime"
import "core:fmt"

GL_MAJOR_VERSION :: 3
GL_MINOR_VERSION :: 3

framebuffer_size_callback :: proc "cdecl" (window: glfw.WindowHandle, width, height: i32) {
	gl.Viewport(0, 0, width, height)
}

process_input :: proc(window: ^glfw.WindowHandle) {
	if glfw.GetKey(window^, glfw.KEY_ESCAPE) == glfw.PRESS {
		glfw.SetWindowShouldClose(window^, true)
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

	for !glfw.WindowShouldClose(window) {
		process_input(&window)

		gl.ClearColor(0.2, 0.3, 0.3, 1.0)
		gl.Clear(gl.COLOR_BUFFER_BIT)

		glfw.SwapBuffers(window)
		glfw.PollEvents()
	}
}
