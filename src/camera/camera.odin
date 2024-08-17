package camera

import "core:math"
import la "core:math/linalg"

Vec3 :: la.Vector3f32
Mat4 :: la.Matrix4x4f32

CameraMovement :: enum {
	FORWARD,
	BACKWARD,
	LEFT,
	RIGHT,
}

YAW: f32 : -90
PITCH: f32 : 0.0
SPEED: f32 : 2.5
SENSITIVITY: f32 : 0.1
ZOOM: f32 : 45.0


Camera :: struct {
	position:          Vec3,
	front:             Vec3,
	up:                Vec3,
	right:             Vec3,
	world_up:          Vec3,
	yaw:               f32,
	pitch:             f32,
	move_speed:        f32,
	mouse_sensitivity: f32,
	zoom:              f32,
}


DEFAULT_POSITION :: Vec3{0.0, 0.0, 0.0}
DEFAULT_UP :: Vec3{0.0, 1.0, 0.0}
DEFAULT_FRONT :: Vec3{0.0, 0.0, -1.0}

camera_init :: proc(
	position: Vec3 = Vec3{0.0, 0.0, 0.0},
	up: Vec3 = DEFAULT_UP,
	yaw: f32 = YAW,
	pitch: f32 = PITCH,
	front: Vec3 = DEFAULT_FRONT,
) -> ^Camera {
	c := new(Camera)
	c.position = position
	c.world_up = up
	c.yaw = yaw
	c.pitch = pitch
	_update_camera_vectors(c)
	return c
}

get_view_matrix :: proc(using camera: ^Camera) -> Mat4 {
	return la.matrix4_look_at(position, position + front, up)
}

process_keyboard :: proc(using camera: ^Camera, direction: CameraMovement, dt: f32) {
	velocity: f32 = move_speed * dt

	if direction == .FORWARD {
		position += front * velocity
	}
	if direction == .BACKWARD {
		position -= front * velocity
	}

	if direction == .LEFT {
		position -= right * velocity
	}

	if direction == .RIGHT {
		position += right * velocity
	}
}

process_mouse_move :: proc(
	using camera: ^Camera,
	xoffset, yoffset: f32,
	constraint_pitch: bool = true,
) {
	xoffset *= mouse_sensitivity
	yoffset *= mouse_sensitivity

	yaw += xoffset
	pitch += yoffset

	if constraint_pitch {
		if pitch > 89.0 {
			pitch = 89.0
		}

		if pitch < -89.0 {
			pitch = -89.0
		}
	}
}

process_mouse_scroll :: proc(
  using camera: ^Camera,
  yoffset : f32
) -> {
  zoom -= yoffset

  if zoom < 1.0 {
    zoom = 1.0
  }

  if zoom > 45.0 {
    zooom = 45.0
  }
}


@(private)
_update_camera_vectors :: proc(camera: ^Camera) {
	using math
	using la

	front_x: f32 = cos(to_radians(yaw)) * cos(to_radians(pitch))
	front_y: f32 = cos(to_radians(pitch))
	front_z: f32 = sin(to_radians(yaw)) * cos(to_radians(pitch))

	camera.front = vector_normalize(Vec3{front_x, front_y, front_z})
	camera.right = vector_normalize(vector_cross3(camera.front, camera.world_up))
	camera.up = vector_normalize(vector_cross3(camera.right, camera.front))
}
