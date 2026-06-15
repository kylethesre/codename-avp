extends Node
func _ready():
	var p = get_parent()
	if p:
		for c in p.get_children():
			if c.name == 'Scratch' or "causes_bleed" in c:
				c.causes_bleed = true
