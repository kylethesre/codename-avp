extends Node
func _ready():
	var p = get_parent()
	if p:
		for c in p.get_children():
			if c.name == 'LightningStrike' or "is_overloaded" in c:
				c.is_overloaded = true
