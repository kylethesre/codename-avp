extends Node
func _ready():
	var p = get_parent()
	if p:
		for c in p.get_children():
			if c.name == 'SwarmDrones':
				c.drone_count += 1
