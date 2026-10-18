@tool
extends Sprite3D
class_name RichText3D


@onready var sub_viewport: SubViewport = $SubViewport
@onready var rich_text_label: RichTextLabel = $SubViewport/RichTextLabel

const RICH_TEXT_3D = preload("uid://dbhtveg1jfnli")

const PX_DENSITY: float = 2 / 512.0


@export var size: Vector2i = Vector2i(512, 512):
	set(val):
		size = val
		if not is_node_ready():
			await ready
		sub_viewport.size = size


@export var text: String = "":
	set(val):
		text = val
		if not is_node_ready():
			await ready
		rich_text_label.text = text


# Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#mesh = mesh.duplicate()
	#var material: ShaderMaterial = ShaderMaterial.new()
	#material.shader = RICH_TEXT_3D
	#var viewport_tex: ViewportTexture = ViewportTexture.new()
	#viewport_tex.viewport_path = sub_viewport.get_path()
	#material.set_shader_parameter("viewport_texture", viewport_tex)
	#material.resource_local_to_scene = true
	#viewport_tex.resource_local_to_scene = true
	#
	#mesh.material = material
