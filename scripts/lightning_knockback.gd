extends Node
func _ready():
	var p = get_parent()
	if p:
		for c in p.get_children():
			if c.name == 'LightningStrike' or "has_knockback" in c:
				c.has_knockback = true
