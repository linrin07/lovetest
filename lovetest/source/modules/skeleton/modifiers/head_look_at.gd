@tool
extends SkeletonModifier3D
class_name HeadBoneLookAt

@export var target_object: Node3D
@export_enum(" ") var head_bone_name: String
@export_range(0.0, 1.0, 0.01) var eye_offset: float = 0.15
@export var reverse_z: bool = false
@export var rotation_limitation: float = 45.0
var target_coordinate: Vector3 = Vector3(0, 0, -1)
@export var actor: Actor

func _validate_property(property: Dictionary) -> void:
	match property.name:
		"head_bone_name", "neck_bone_name":
			var skeleton: Skeleton3D = get_skeleton()
			if skeleton:
				property.hint = PROPERTY_HINT_ENUM
				property.hint_string = skeleton.get_concatenated_bone_names()

func _process_modification() -> void:
	if not head_bone_name:
		return
	var skeleton: Skeleton3D = get_skeleton()
	if !skeleton:
		return # Never happen, but for the safety.
	
	var delta: float
	if skeleton.modifier_callback_mode_process == Skeleton3D.MODIFIER_CALLBACK_MODE_PROCESS_IDLE:
		delta = get_process_delta_time()
	else:
		delta = get_physics_process_delta_time()
		
	var bone_idx: int = skeleton.find_bone(head_bone_name)
	var parent_idx: int = skeleton.get_bone_parent(bone_idx)
	var parent_pose: Transform3D = skeleton.get_bone_global_rest(parent_idx)
	parent_pose.origin = skeleton.get_bone_global_pose(parent_idx).origin
	var pose: Transform3D = parent_pose * skeleton.get_bone_rest(bone_idx)
	pose = pose.translated_local(Vector3.UP * eye_offset)
	#var parent_pose: Transform3D = skeleton.get_bone_global_pose(parent_idx)
	#var pose: Transform3D = skeleton.get_bone_global_pose(bone_idx).translated_local(Vector3.UP * eye_offset)
	
	var axis_sign: float = -1.0 if reverse_z else 1.0
	if not target_object:
		return
		#target_coordinate = target_coordinate.lerp((pose.basis.z+pose.origin) * axis_sign, delta * 8.0)
	else:
		target_coordinate = target_coordinate.lerp(skeleton.to_local(target_object.global_position), delta * 8.0)
	
	var direction: Vector3 = (target_coordinate - pose.origin).normalized()
	
	if abs(rad_to_deg(axis_sign * pose.basis.z.angle_to(direction))) > rotation_limitation:
		influence = lerpf(influence, 0.0, delta * 8.0)
	elif abs(rad_to_deg(axis_sign * pose.basis.z.angle_to(direction))) > rotation_limitation * 0.5:
		var lerp_to : float = lerp(1.0, 0.5, 2.0 * abs(rad_to_deg(axis_sign * pose.basis.z.angle_to(direction))) / rotation_limitation - 1.0)
		influence = lerpf(influence, lerp_to, delta * 8.0)
	else:
		influence = lerpf(influence, 1.0, delta * 8.0)
	if actor:
		#var local_d: Vector3 = pose.affine_inverse() * direction
		actor.eye_direction = Vector2(-direction.x, direction.y) * (1.0 - influence) * 1.1
		#print(direction, local_d)
	
	var looked_at: Transform3D = _z_look_at(pose, target_coordinate, reverse_z, 0.5)
	var parent_looked_at: Transform3D = _z_look_at(parent_pose, target_coordinate, reverse_z, 0.5)
	skeleton.set_bone_global_pose(parent_idx, Transform3D(parent_looked_at.basis.orthonormalized(), skeleton.get_bone_global_pose(parent_idx).origin))
	skeleton.set_bone_global_pose(bone_idx, Transform3D(looked_at.basis.orthonormalized(), skeleton.get_bone_global_pose(bone_idx).origin))
	#skeleton.set_bone_global_pose(parent_idx, Transform3D(skeleton.get_bone_global_rest(parent_idx).basis, skeleton.get_bone_global_pose(parent_idx).origin))
	#skeleton.set_bone_global_pose(bone_idx, Transform3D(skeleton.get_bone_global_rest(bone_idx).basis, skeleton.get_bone_global_pose(bone_idx).origin))
	

func _y_look_at(from: Transform3D, target: Vector3) -> Transform3D:
	var t_v: Vector3 = target - from.origin
	var v_y: Vector3 = t_v.normalized()
	var v_z: Vector3 = from.basis.x.cross(v_y)
	v_z = v_z.normalized()
	var v_x: Vector3 = v_y.cross(v_z)
	from.basis = Basis(v_x, v_y, v_z)
	return from

func _z_look_at(from: Transform3D, target: Vector3, reverse: bool = false, weight: float= 1.0) -> Transform3D:
	var axis_sign: float = -1.0 if reverse else 1.0
	var t_v: Vector3 = target - from.origin
	var v_z: Vector3 = t_v.normalized() * axis_sign
	var v_x: Vector3 = from.basis.y.cross(v_z)
	v_x = v_x.normalized()
	var v_y: Vector3 = v_z.cross(v_x)
	if weight == 1.0:
		from.basis = Basis(v_x, v_y, v_z)
	else:
		from.basis = Basis(from.basis.get_rotation_quaternion().slerp(Basis(v_x, v_y, v_z).get_rotation_quaternion(), weight))
	return from
