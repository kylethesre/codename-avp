import os

upgrades = [
    {
        "id": "orbital_blade_count",
        "name": "More Blades",
        "desc": "+1 Orbital Blade",
        "prereq": "orbital_blades",
        "script_body": "extends Node\nfunc _ready():\n\tvar p = get_parent()\n\tif p:\n\t\tfor c in p.get_children():\n\t\t\tif c.name == 'OrbitalBlades' or c.has_method('set_blade_count'):\n\t\t\t\tc.set_blade_count(c.blade_count + 1)"
    },
    {
        "id": "orbital_blade_speed",
        "name": "Faster Orbit",
        "desc": "Orbital blades spin faster",
        "prereq": "orbital_blades",
        "script_body": "extends Node\nfunc _ready():\n\tvar p = get_parent()\n\tif p:\n\t\tfor c in p.get_children():\n\t\t\tif c.name == 'OrbitalBlades':\n\t\t\t\tc.speed += 1.5"
    },
    {
        "id": "orbital_blade_radius",
        "name": "Wider Orbit",
        "desc": "Orbital blades reach further",
        "prereq": "orbital_blades",
        "script_body": "extends Node\nfunc _ready():\n\tvar p = get_parent()\n\tif p:\n\t\tfor c in p.get_children():\n\t\t\tif c.name == 'OrbitalBlades':\n\t\t\t\tc.radius += 20.0"
    },
    {
        "id": "lightning_chain",
        "name": "Chain Lightning",
        "desc": "Lightning strikes chain to +1 enemy",
        "prereq": "lightning_strike",
        "script_body": "extends Node\nfunc _ready():\n\tvar p = get_parent()\n\tif p:\n\t\tfor c in p.get_children():\n\t\t\tif c.name == 'LightningStrike':\n\t\t\t\tc.chain_count += 1"
    },
    {
        "id": "lightning_overcharge",
        "name": "Overcharge",
        "desc": "Lightning strikes faster (-0.5s cooldown)",
        "prereq": "lightning_strike",
        "script_body": "extends Node\nfunc _ready():\n\tvar p = get_parent()\n\tif p:\n\t\tfor c in p.get_children():\n\t\t\tif c.name == 'LightningStrike':\n\t\t\t\tc.cooldown = max(0.5, c.cooldown - 0.5)\n\t\t\t\tc.timer.wait_time = c.cooldown"
    },
    {
        "id": "lightning_thunderclap",
        "name": "Thunderclap",
        "desc": "Lightning AoE radius increased",
        "prereq": "lightning_strike",
        "script_body": "extends Node\nfunc _ready():\n\tvar p = get_parent()\n\tif p:\n\t\tfor c in p.get_children():\n\t\t\tif c.name == 'LightningStrike':\n\t\t\t\tc.radius += 15.0"
    },
    {
        "id": "swarm_hive_mind",
        "name": "Hive Mind",
        "desc": "+1 Drone spawned per volley",
        "prereq": "swarm_drones",
        "script_body": "extends Node\nfunc _ready():\n\tvar p = get_parent()\n\tif p:\n\t\tfor c in p.get_children():\n\t\t\tif c.name == 'SwarmDrones':\n\t\t\t\tc.drone_count += 1"
    },
    {
        "id": "swarm_sensors",
        "name": "Targeting Sensors",
        "desc": "Drones fly significantly faster",
        "prereq": "swarm_drones",
        "script_body": "extends Node\nfunc _ready():\n\tvar p = get_parent()\n\tif p:\n\t\tfor c in p.get_children():\n\t\t\tif c.name == 'SwarmDrones':\n\t\t\t\tc.drone_speed += 100.0"
    },
    {
        "id": "scratch_size",
        "name": "Wide Swipe",
        "desc": "Scratch hits further away",
        "prereq": "scratch",
        "script_body": "extends Node\nfunc _ready():\n\tvar p = get_parent()\n\tif p:\n\t\tfor c in p.get_children():\n\t\t\tif c.name == 'Scratch':\n\t\t\t\tc.range_dist += 25.0"
    },
    {
        "id": "scratch_cooldown",
        "name": "Feral Instinct",
        "desc": "Scratch cooldown reduced",
        "prereq": "scratch",
        "script_body": "extends Node\nfunc _ready():\n\tvar p = get_parent()\n\tif p:\n\t\tfor c in p.get_children():\n\t\t\tif c.name == 'Scratch':\n\t\t\t\tc.cooldown = max(0.5, c.cooldown - 0.3)\n\t\t\t\tc.timer.wait_time = c.cooldown"
    }
]

base_dir = r"c:\Users\Kyle\Documents\codename-avp"

for u in upgrades:
    # 1. Write .gd
    with open(os.path.join(base_dir, f"scripts/{u['id']}.gd"), "w") as f:
        f.write(u['script_body'])
    
    # 2. Write .tscn
    tscn = f"""[gd_scene format=3 uid="uid://{u['id']}_scene"]
[ext_resource type="Script" path="res://scripts/{u['id']}.gd" id="1"]
[node name="{u['id'].capitalize()}" type="Node"]
script = ExtResource("1")
"""
    with open(os.path.join(base_dir, f"scenes/abilities/{u['id']}.tscn"), "w") as f:
        f.write(tscn)
        
    # 3. Write .tres
    tres = f"""[gd_resource type="Resource" script_class="Upgrade" load_steps=3 format=3]
[ext_resource type="Script" path="res://scripts/Upgrade.gd" id="1"]
[ext_resource type="PackedScene" path="res://scenes/abilities/{u['id']}.tscn" id="2"]
[resource]
script = ExtResource("1")
id = "{u['id']}"
ability = ExtResource("2")
weight = 100
max_instances = 3
prerequisites = ["{u['prereq']}"]
mutually_exclusive = []
rarity = 1
name = "{u['name']}"
desc = "{u['desc']}"
is_ability = false
"""
    with open(os.path.join(base_dir, f"upgrades/{u['id']}.tres"), "w") as f:
        f.write(tres)

print("Generated 30 files successfully!")
