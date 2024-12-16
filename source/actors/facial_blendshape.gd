@tool
extends Resource
class_name FacialBSSet

@export var facial_name: String
@export var blend_shape_sets: Array[BlendShapeSet]

func _validate_property(property: Dictionary) -> void:
	if property.name == "facial_name":
		property.hint = PROPERTY_HINT_ENUM
		var arr: PackedStringArray = []
		for ele in Actor.FacialExpression:
			arr.append(ele)
		property.hint_string = ",".join(arr)
