@tool
class_name BlendShapeMesh extends MeshInstance3D

@export var blend_shape_names: PackedStringArray

func _ready() -> void:
	if Engine.is_editor_hint():
		blend_shape_names = get_blend_shape_names()

func get_blend_shape_names() -> PackedStringArray:
	var names_array: PackedStringArray = []
	for dict in get_property_list():
		if "blend_shapes/" in dict["name"]:
			names_array.append(dict["name"].replace("blend_shapes/", ""))
	return names_array

func set_sk(sk_name: String, value: float, delay: float = 0.0) -> float:
	if find_blend_shape_by_name(sk_name) == -1:
		return value
	if delay == 0.0:
		set_blend_shape_value(find_blend_shape_by_name(sk_name), value)
	else:
		var tween: Tween = create_tween()
		tween.tween_property(self, "blend_shapes/"+sk_name, value, delay).set_ease(Tween.EASE_IN)
	return value

func get_concatenated_shape_names() -> StringName:
	return StringName(",".join(blend_shape_names))
