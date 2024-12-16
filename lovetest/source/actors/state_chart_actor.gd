@tool
extends Actor
class_name StateChartActor

@export var state_chart: StateChart

func get_all_children(in_node: Node, array := []):
	array.push_back(in_node)
	for child in in_node.get_children():
		array = get_all_children(child, array)
	return array

func try_connect_state_signal(node: Node, suffix: String) -> void:
	var str: String = node.name.to_snake_case() + "_" + suffix
	var str2: String = "_on_" + str
	if not self.has_method(str):
		return
	if not node.is_connected(str, Callable(self, str2)):
		node.connect(str, Callable(self, str2))

func ready() -> void:
	if Engine.is_editor_hint():
		return
	if state_chart:
		for element in get_all_children(state_chart):
			if element is StateChartState:
				try_connect_state_signal(element, "state_entered")
				try_connect_state_signal(element, "state_exit")
				try_connect_state_signal(element, "state_processing")
			if element is CompoundState:
				try_connect_state_signal(element, "child_state_entered")


func _on_sit_idle_state_entered() -> void:
	pass # Replace with function body.


func _on_pluck_state_entered() -> void:
	pass # Replace with function body.
