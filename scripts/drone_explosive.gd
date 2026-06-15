extends Node
func _ready():
	var p = get_parent()
	if p:
		for c in p.get_children():
			if c.name == 'SwarmDrones' or "is_explosive" in c:
				c.is_explosive = true
