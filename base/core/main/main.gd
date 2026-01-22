class_name Main
extends Control

@export var level_container: Node
@export var gui: Control

@onready var window_display: Node2D = $WindowCanvesLayer/WindowDisplay
@onready var virtual_viewport: SubViewport = $VirtualViewPort
@onready var real_world: Node2D = $World/RealWorld
@onready var virtual_world: Node2D = $World/VirtualWorld
@onready var real_player: Node2D = $World/VirtualWorld


func _ready():
	virtual_world.get_parent().remove_child(virtual_world)
	virtual_viewport.add_child(virtual_world)
	virtual_world.position = $World.position

	if not SceneManager.main:
		SceneManager.main = self


func _process(_delta):
	var mouse_screen = get_global_mouse_position()
	window_display.global_position = mouse_screen
