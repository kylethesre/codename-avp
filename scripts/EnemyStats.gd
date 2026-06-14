class_name EnemyStats
extends Resource

@export_category("Combat Stats")
@export var max_health: float = 10.0
@export var armor: float = 0.0
@export var attack: float = 1.0
@export var dodge: float = 0.0

@export_category("Movement")
@export var speed: float = 10.0


@export_category("Spawn Chance")
@export var waves: Array[float] = []
