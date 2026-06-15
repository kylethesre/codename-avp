class_name UpgradeSelectionUI
extends Control

signal upgrade_selected(upgrade: Upgrade)

@onready var option_buttons: Array[TextureButton] = [
	$Panel/VBoxContainer/Option1Button,
	$Panel/VBoxContainer/Option2Button,
	$Panel/VBoxContainer/Option3Button
]

var last_choices: Array[Upgrade] = []
var rarity_textures: Array[Texture2D] = []

func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Mapping based on user's editor layout: Option1=Bronze, Option2=Stone, Option3=Gold
	rarity_textures.resize(3)
	rarity_textures[Upgrade.Rarity.BRONZE] = option_buttons[0].texture_normal # Bronze texture
	rarity_textures[Upgrade.Rarity.STONE] = option_buttons[1].texture_normal # Stone texture
	rarity_textures[Upgrade.Rarity.GOLD] = option_buttons[2].texture_normal  # Gold texture
	
	for i in range(option_buttons.size()):
		option_buttons[i].pressed.connect(Callable(self, "_on_option_pressed").bind(i))

func show_choices(choices: Array[Upgrade]) -> void:
	get_tree().paused = true
	last_choices = choices
	for i in range(option_buttons.size()):
		var btn: TextureButton = option_buttons[i]
		if i < choices.size():
			var vbox = btn.get_node("VBoxContainer")
			var name_label = vbox.find_child("NameLabel", true, false) as Label
			var desc_label = vbox.find_child("DescLabel", true, false) as Label
			
			name_label.text = choices[i].name
			desc_label.text = choices[i].desc
			
			var r = choices[i].rarity
			if r >= 0 and r < rarity_textures.size():
				btn.texture_normal = rarity_textures[r]
				
			btn.modulate = Color.WHITE
			btn.visible = true
		else:
			btn.visible = false
	visible = true

func _on_option_pressed(idx: int) -> void:
	if idx < 0 or idx >= last_choices.size():
		return
	emit_signal("upgrade_selected", last_choices[idx])
	get_tree().paused = false
	visible = false
