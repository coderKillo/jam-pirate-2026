class_name WindowDisplay
extends Node2D

const STATIC_NOISE_FACTOR = 1.0 / 20.0

@export var disable_position := Vector2(5000, 5000)
@export var bounding_box: Rect2
@export var virtual_camera: Camera2D
@export var enable := false

@onready var virtual_rect: ColorRect = $VirtualRect
@onready var window_area: WindowArea = $WindowArea

var drag := false


func _unhandled_input(event):
	if enable:
		if (
			event is InputEventMouseMotion
			and Input.is_action_pressed("click")
			and virtual_rect.get_global_rect().has_point(get_global_mouse_position())
		):
			var new_position = global_position + (event.relative * AppSettings.mouse_sensitifity())
			global_position = new_position.clamp(bounding_box.position, bounding_box.end)

			var static_noise = (event.relative.length()) * STATIC_NOISE_FACTOR
			var shader_material := virtual_rect.material as ShaderMaterial
			shader_material.set_shader_parameter("static_noise_intensity", static_noise)


func _process(_delta):
	virtual_camera.global_position = global_position
