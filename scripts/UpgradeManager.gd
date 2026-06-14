extends Node

signal upgrade_chosen(upgrade: Upgrade)

@export var upgrades_path: String = "res://upgrades"
@export var ui_scene_path: String = "res://scenes/UpgradeSelectionUI.tscn"

var all_upgrades: Array[Upgrade] = []
var obtained_upgrades: Array[String] = []
var ui: UpgradeSelectionUI
var player: Player

func _ready() -> void:
	randomize()
	load_all_upgrades()
	_instantiate_ui()

	# Find player node for applying upgrades
	player = get_parent().get_node("CharacterBody2D") as Player
	if not player:
		player = get_tree().get_first_node_in_group("Player")
	if not player:
		push_error("UpgradeManager: No Player node found to apply upgrades")


func _instantiate_ui() -> void:
	print("UpgradeManager: _instantiate_ui() called")
	var ui_scene: PackedScene = ResourceLoader.load(ui_scene_path)
	if not ui_scene:
		push_error("Failed to load UpgradeSelection scene at '%s'." % ui_scene_path)
		return
	print("UpgradeManager: UI scene loaded, instantiating...")
	var root: Node = ui_scene.instantiate()
	# If root is CanvasLayer, get the UpgradeSelectionUI child
	if root is CanvasLayer:
		ui = root.get_child(0) as UpgradeSelectionUI
		add_child(root)  # Add the CanvasLayer to keep the hierarchy
	else:
		ui = root as UpgradeSelectionUI
		add_child(ui)
	if not ui:
		push_error("Failed to find UpgradeSelectionUI in scene")
		return
	print("UpgradeManager: UI instantiated, type=", ui.get_class(), " visible=", ui.visible)
	ui.connect("upgrade_selected", Callable(self, "_on_upgrade_selected"))

func load_all_upgrades() -> void:
	var dir: DirAccess = DirAccess.open(upgrades_path)
	if dir:
		dir.list_dir_begin()
		var file_name: String = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir() and file_name.ends_with(".tres"):
				var res = ResourceLoader.load(upgrades_path + "/" + file_name)
				if res is Upgrade:
					all_upgrades.append(res)
			file_name = dir.get_next()
		dir.list_dir_end()

func show_upgrade_selection(count: int = 3) -> void:
	if not ui:
		_instantiate_ui()
	var choices: Array[Upgrade] = _pick_random_upgrades(count)
	print("UpgradeManager: ", choices.size(), " choices available")
	print("UpgradeManager: all_upgrades count = ", all_upgrades.size())
	print("UpgradeManager: obtained = ", obtained_upgrades)
	print("UpgradeManager: ui=", ui, " in_tree=", ui.is_inside_tree() if ui else "null")
	if ui:
		ui.show_choices(choices)
	else:
		print("UpgradeManager: WARNING - ui is null!")

func _pick_random_upgrades(count: int) -> Array[Upgrade]:
	var filtered: Array[Upgrade] = []
	for u in all_upgrades:
		# Check prerequisites
		var meets_prereq: bool = true
		for prereq in u.prerequisites:
			if not obtained_upgrades.has(prereq):
				meets_prereq = false
				break
		if not meets_prereq:
			continue
		# Check mutual exclusivity
		var mut_ex: bool = false
		for excl in u.mutually_exclusive:
			if obtained_upgrades.has(excl):
				mut_ex = true
				break
		if mut_ex:
			continue
		# Check max instances
		if obtained_upgrades.count(u.id) >= u.max_instances:
			continue
		filtered.append(u)

	var picks: Array[Upgrade] = []
	var candidates: Array[Upgrade] = filtered.duplicate()
	for i in range(min(count, candidates.size())):
		if candidates.is_empty():
			break
		var total_weight: int = 0
		for u in candidates:
			total_weight += u.weight
		if total_weight <= 0:
			break
		var r: int = randi() % total_weight
		for u in candidates:
			r -= u.weight
			if r < 0:
				picks.append(u)
				candidates.erase(u)
				break
	return picks

func _on_upgrade_selected(upgrade: Upgrade) -> void:
	obtained_upgrades.append(upgrade.id)
	
	if not is_instance_valid(player):
		var found_player = get_tree().get_first_node_in_group("Player")
		if found_player is Player:
			player = found_player as Player
		else:
			push_error("UpgradeManager: Found node in 'Player' group but it is not of type 'Player'!")
			
	print("UpgradeManager Debug: upgrade=", upgrade.id, " ability=", upgrade.ability)
	
	# Instantiate ability under player if applicable
	if upgrade.ability:
		var ability_instance: Node = upgrade.ability.instantiate()
		if player:
			player.add_child(ability_instance)
			ability_instance.owner = player
			print("UpgradeManager: Successfully instantiated and attached ability: ", upgrade.name)
		else:
			push_error("UpgradeManager: No player found when applying upgrade!")
	else:
		print("UpgradeManager: Upgrade selected is not an ability or has no scene attached.")
		
	emit_signal("upgrade_chosen", upgrade)
