@tool
class_name Actor extends Node3D

@export var skeloton: Skeleton3D
@export var face_mesh: BlendShapeMesh

enum FacialExpression {happy, sad, angry, smile, surprise, fear, shy, default = -1}
@export_category("Expression")
## Facial expression property
@export var facial_exp: FacialExpression = FacialExpression.default:
	set(value):
		facial_exp = value
		if is_instance_valid(face_mesh):
			var dict: Dictionary = facial_sk_dict[FacialExpression.find_key(value)]
			for key in dict:
				face_mesh.set_sk(key, dict[key], 0.2)
			for ele in face_mesh.blend_shape_names:
				if not dict.keys().has(ele):
					face_mesh.set_sk(ele, 0.0, 0.2)
		return value
@export var facial_bs_sets: FacialBSSets:
	set(value):
		facial_bs_sets = value
		if is_instance_valid(face_mesh):
			#print("facial_bs_changed")
			for facial_bs_set in facial_bs_sets.sets:
				for bs_set in (facial_bs_set as FacialBSSet).blend_shape_sets:
					(bs_set as BlendShapeSet)._hint_string = face_mesh.get_concatenated_shape_names()
					(bs_set as BlendShapeSet).notify_property_list_changed()
					if not is_instance_valid(bs_set.mesh):
						bs_set.mesh = face_mesh
		return value
	get():
		if is_instance_valid(face_mesh):
			#print("facial_bs_changed")
			if not facial_bs_sets:
				return facial_bs_sets
			for facial_bs_set in facial_bs_sets.sets:
				if not facial_bs_set:
					return facial_bs_sets
				for bs_set in (facial_bs_set as FacialBSSet).blend_shape_sets:
					if not bs_set:
						return facial_bs_sets
					if (bs_set as BlendShapeSet)._hint_string == "":
						(bs_set as BlendShapeSet)._hint_string = face_mesh.get_concatenated_shape_names()
						print("set _hint_string")
					if not is_instance_valid(bs_set.mesh):
						bs_set.mesh = face_mesh
		return facial_bs_sets
var facial_sk_dict: Dictionary = {}
#var facial_sk_dict_default: Dictionary = {
	#"happy": {"B_sk2": 1.0, "E_sk3": 1.0, "M_ee": 0.41, "M_oh": 0.52, "M_ou": 0.34},
	#"sad": {"B_sk3": 1.0, "E_sk1": 0.54, "M_sad": 1.0},
	#"angry": {"B_sk1": 1.0, "E_sk1": 1.0, "M_angry": 1.0},
	#"smile": {"B_sk2": 1.0, "E_sk2": 1.0, "M_smile": 0.71},
	#"surprise": {"B_sk2": 1.0, "E_sk4": 1.0, "M_oh": 1.0},
	#"fear": {"B_sk3": 1.0, "E_sk5": 1.0, "E_sk6": 0.29, "M_sad": 0.81, "M_smile": -0.34},
	#"shy": {"B_sk3": 0.9, "E_sk2": 0.15, "M_sad": 0.82, "M_smile": 0.72, "lookDown": 0.51},
	#"default": {"M_close": 1.0}
#}

@export_category("Blink")
@export var blink_sk_names: PackedStringArray = ["blinkL","blinkR"]
@export var blink_sk_exclusions_names: PackedStringArray = ["E_sk1","E_sk2","E_sk4"]
var blink_timer: Timer
@export var use_blink: bool = true:
	set(value):
		use_blink = value
		if is_instance_valid(blink_timer):
			if value:
				blink_timer.start()
			else:
				blink_timer.stop()
		return value

@export_category("Look")
## up, down, left, right
@export var eye_direction_array: PackedStringArray = ["lookUp","lookDown","lookLeft","lookRight"]
@export var use_look_direction: bool = true:
	set(value):
		use_look_direction = value
		if is_instance_valid(head_bone_modifier):
			head_bone_modifier.active = value
		if not value:
			if is_instance_valid(face_mesh):
				face_mesh.set_sk(eye_direction_array[0], 0.0)
				face_mesh.set_sk(eye_direction_array[1], 0.0)
				face_mesh.set_sk(eye_direction_array[2], 0.0)
				face_mesh.set_sk(eye_direction_array[3], 0.0)
		else:
			set("eye_direction", eye_direction)
		return value
@export var eye_direction: Vector2 = Vector2(0.0, 0.0):
	set(value):
		value = value.limit_length(1.0)
		eye_direction = value
		if is_instance_valid(face_mesh):
			if use_look_direction:
				face_mesh.set_sk(eye_direction_array[0], clampf(eye_direction.y, 0.0, 1.0))
				face_mesh.set_sk(eye_direction_array[1], -clampf(eye_direction.y, -1.0, 0.0))
				face_mesh.set_sk(eye_direction_array[2], -clampf(eye_direction.x, -1.0, 0.0))
				face_mesh.set_sk(eye_direction_array[3], clampf(eye_direction.x, 0.0, 1.0))
		return value

@export var head_bone_modifier: HeadBoneLookAt

enum FacialMouth {default, aa, ih, ou, ee, oh}
@export_category("Speak")
@export var facial_mouth: FacialMouth = FacialMouth.default:
	set(value):
		facial_mouth = value
		if is_instance_valid(face_mesh):
			face_mesh.set_sk(mouth_sk_names[value], mouth_apply_weight, 0.2)
			for ele in mouth_sk_names:
				if ele != mouth_sk_names[value]:
					face_mesh.set_sk(ele, 0.0, 0.2)
		return value
## aa, ih, ou, ee, oh, default
@export var mouth_sk_names: PackedStringArray = ["M_close", "M_aa", "M_ih", "M_ou", "M_ee", "M_oh"]
@export_range(0.0, 1.0, 0.01) var mouth_apply_weight: float = 1.0

func _validate_property(property: Dictionary) -> void:
	match property.name:
		"blink_sk_names","blink_sk_exclusions_names","eye_direction_array","mouth_sk_names":
			if face_mesh:
				property.hint = PROPERTY_HINT_ARRAY_TYPE
				property.hint_string = "%d/%d:%s" % [TYPE_STRING, PROPERTY_HINT_ENUM, face_mesh.get_concatenated_shape_names()]
		"eye_direction_dict":
			if face_mesh:
				property.hint = PROPERTY_HINT_ARRAY_TYPE
		
func ready() -> void:
	pass

func _ready() -> void:
	if face_mesh:
		if facial_bs_sets:
			facial_sk_dict = generate_facial_sk_dict(facial_bs_sets)
		#print(get_property_list())
		set_blink_timer()
	ready()

func set_blink_timer() -> void:
	blink_timer = Timer.new()
	blink_timer.wait_time = 5.0
	blink_timer.one_shot = true
	if not blink_timer.is_connected("timeout", _on_blink_timer_timerout):
		blink_timer.connect("timeout", _on_blink_timer_timerout)
	add_child(blink_timer)
	blink_timer.start()

func _on_blink_timer_timerout() -> void:
	var value_array: PackedFloat32Array = []
	for sk_name in blink_sk_exclusions_names:
		value_array.append(face_mesh.get_blend_shape_value(face_mesh.find_blend_shape_by_name(sk_name)))
	var tween: Tween = create_tween()
	for blink_sk_name in blink_sk_names:
		tween.parallel().tween_property(face_mesh, "blend_shapes/" +blink_sk_name, 1.0, 0.05).set_ease(Tween.EASE_OUT)
	for sk_name in blink_sk_exclusions_names:
		tween.parallel().tween_property(face_mesh, "blend_shapes/" +sk_name, 0.0, 0.05).set_ease(Tween.EASE_OUT)
	tween.tween_interval(0.075)
	for blink_sk_name in blink_sk_names:
		tween.parallel().tween_property(face_mesh, "blend_shapes/" +blink_sk_name, 0.0, 0.05).set_ease(Tween.EASE_OUT)
	var i: int = 0
	for sk_name in blink_sk_exclusions_names:
		tween.parallel().tween_property(face_mesh, "blend_shapes/" +sk_name, value_array[i], 0.05).set_ease(Tween.EASE_OUT)
		i += 1
	blink_timer.wait_time = randf_range(1.0, 8.0)
	blink_timer.start()

## generate Dictionary facial_sk_dict from FacialBSSets resource
func generate_facial_sk_dict(facial_sets: FacialBSSets) -> Dictionary:
	var dic: Dictionary = {}
	for facial_set in facial_sets.sets:
		var dic_key: String = (facial_set as FacialBSSet).facial_name
		var dic_value: Dictionary = {}
		for bs_set in (facial_set as FacialBSSet).blend_shape_sets:
			var dic_value_key: String = (bs_set as BlendShapeSet).blend_shape_name
			var dic_value_value: float = (bs_set as BlendShapeSet).value
			dic_value.merge({dic_value_key: dic_value_value})
		dic.merge({dic_key: dic_value})
	return dic
	
