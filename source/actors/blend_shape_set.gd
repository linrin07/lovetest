@tool
extends Resource
class_name BlendShapeSet

@export var blend_shape_name: String
@export_range(0.0, 1.0, 0.01, "or_less") var value: float:
	set(bs_value):
		value = bs_value
		if is_instance_valid(mesh):
			if mesh.find_blend_shape_by_name(blend_shape_name) != -1:
				mesh.set_blend_shape_value(mesh.find_blend_shape_by_name(blend_shape_name), bs_value)
		return bs_value
var _hint_string: String = ""
var mesh: MeshInstance3D

func _validate_property(property: Dictionary) -> void:
	if property.name == "blend_shape_name":
		property.hint = PROPERTY_HINT_ENUM
		property.hint_string = _hint_string
