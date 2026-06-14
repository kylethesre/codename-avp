class_name UpgradeSelectionUI
extends Control

signal upgrade_selected(upgrade: Upgrade)

@onready var option_buttons: Array[Button] = [
	$Panel/VBoxContainer/Option1Button,
	$Panel/VBoxContainer/Option2Button,
	$Panel/VBoxContainer/Option3Button
]

@onready var control_root: Control = self

var last_choices: Array[Upgrade] = []

func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	for i in range(option_buttons.size()):
		option_buttons[i].pressed.connect(Callable(self, "_on_option_pressed").bind(i))

func show_choices(choices: Array[Upgrade]) -> void:
	get_tree().paused = true
	print("UpgradeSelectionUI: show_choices called with ", choices.size(), " choices")
	print("UpgradeSelectionUI: parent=", get_parent(), " in_tree=", is_node_ready())
	print("UpgradeSelectionUI: self.visible before=", visible)
	last_choices = choices
	for i in range(option_buttons.size()):
		var btn: Button = option_buttons[i]
		print("UpgradeSelectionUI: button ", i, " exists=", btn != null)
		if i < choices.size():
			btn.text = choices[i].name
			btn.visible = true
			print("UpgradeSelectionUI: button ", i, " set to '", choices[i].name, "'")
		else:
			btn.visible = false
	visible = true
	print("UpgradeSelectionUI: self.visible after=", visible)

func _on_option_pressed(idx: int) -> void:
	if idx < 0 or idx >= last_choices.size():
		return
	emit_signal("upgrade_selected", last_choices[idx])
	get_tree().paused = false
	visible = false
