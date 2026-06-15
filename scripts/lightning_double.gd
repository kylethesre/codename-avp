extends Node
func _ready():
	var p = get_parent()
	if p:
		for c in p.get_children():
			if c.name == 'LightningStrike' or "double_strike" in c:
				c.double_strike = true
