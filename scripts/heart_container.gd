extends HBoxContainer

const HEART_SCENE = preload("res://scenes/heart.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var player := get_tree().get_first_node_in_group("Player")
	if player:
		for child in get_children():
			child.queue_free()
		await Engine.get_main_loop().process_frame
		player.health_changed.connect(update_display)
		update_display(player.health, player.max_health)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func update_display(health, max_health):
	var children := get_children()
	if children.size() < max_health:
		for i in range(children.size(), max_health):
			var heart := HEART_SCENE.instantiate();
			(heart as TextureRect).texture = (heart as TextureRect).texture.duplicate()
			add_child(heart)
	
	children = get_children()
	var i := 0
	for child in children:
		if child is TextureRect:
			i = i + 1
			if i > health:
				((child as TextureRect).texture as AtlasTexture).region.position.x = 17 * 4
			else:
				((child as TextureRect).texture as AtlasTexture).region.position.x = 0
				
		
