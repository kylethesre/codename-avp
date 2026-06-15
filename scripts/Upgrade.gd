class_name Upgrade
extends Resource

enum Rarity { STONE, BRONZE, GOLD }

@export var id: String
@export var ability: PackedScene
@export var weight: int = 100
@export var max_instances: int = 1
@export var prerequisites: Array[String]
@export var mutually_exclusive: Array[String]
@export var rarity: Rarity
@export var name: String
@export var desc: String
@export var icon: Texture2D
@export var is_ability: bool
