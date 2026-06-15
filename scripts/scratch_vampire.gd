extends Node
func _ready():
	var p = get_parent()
	if p:
		for c in p.get_children():
			if c.name == 'Scratch' or "is_vampiric" in c:
				c.is_vampiric = true
