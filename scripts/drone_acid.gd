extends Node
func _ready():
	var p = get_parent()
	if p:
		for c in p.get_children():
			if c.name == 'SwarmDrones' or "leaves_acid" in c:
				c.leaves_acid = true
