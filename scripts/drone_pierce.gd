extends Node
func _ready():
	var p = get_parent()
	if p:
		for c in p.get_children():
			if c.name == 'SwarmDrones' or "pierce_count" in c:
				c.pierce_count += 1
