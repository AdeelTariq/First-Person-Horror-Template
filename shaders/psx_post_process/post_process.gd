@tool
class_name PSXPostProcess extends CompositorEffect

@export var enable: bool = true
@export var dithering: bool = true
@export var colors: float = 16
@export var dither_size: float = 1.0

var device: RenderingDevice
var shader: RID
var pipeline: RID


func _init() -> void:
	RenderingServer.call_on_render_thread(init_compute_shader)

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE and shader.is_valid():
		RenderingServer.free_rid(shader)
		
		
func init_compute_shader() -> void:
	device = RenderingServer.get_rendering_device()
	if not device: return
	
	var glsl_file: RDShaderFile = load("res://shaders/psx_post_process/post_process.glsl")
	shader = device.shader_create_from_spirv(glsl_file.get_spirv())
	pipeline = device.compute_pipeline_create(shader)


func _render_callback(_effect_callback_type: int, render_data: RenderData) -> void:
	if not device: return
	
	var scene_buffer: RenderSceneBuffersRD = render_data.get_render_scene_buffers()
	if not scene_buffer: return
	
	var size: Vector2i = scene_buffer.get_internal_size()
	if size.x == 0 or size.y == 0: return
	
	@warning_ignore("integer_division")
	var x_groups: int = (size.x - 1) / 16 + 1
	@warning_ignore("integer_division")
	var y_groups: int = (size.y - 1) / 16 + 1
	
	var push_constants: PackedFloat32Array = PackedFloat32Array()
	push_constants.append(size.x)
	push_constants.append(size.y)
	push_constants.append(colors)
	push_constants.append(dither_size)
	push_constants.append(enable)
	push_constants.append(dithering)
	push_constants.append(0.0)
	push_constants.append(0.0)
	
	
	for view: int in scene_buffer.get_view_count():
		var screen_texture: RID = scene_buffer.get_color_layer(view)
		var uniform: RDUniform = RDUniform.new()
		uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
		uniform.binding = 0
		uniform.add_id(screen_texture)
		
		var image_uniform_set: RID = UniformSetCacheRD.get_cache(shader, 0, [uniform])
		var compute_list: int = device.compute_list_begin()
		device.compute_list_bind_compute_pipeline(compute_list, pipeline)
		device.compute_list_bind_uniform_set(compute_list, image_uniform_set, 0)
		device.compute_list_set_push_constant(
			compute_list, 
			push_constants.to_byte_array(), 
			push_constants.size() * 4
		)
		device.compute_list_dispatch(compute_list, x_groups, y_groups, 1)
		device.compute_list_end()
		
		
		
	
