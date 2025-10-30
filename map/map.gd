extends Node2D
class_name Map
## Todo: "orienter" tiles that serve to rotate directional objects when they spawn
@onready var floor_layout: TileMapLayer = %FloorLayout
@onready var enemies: TileMapLayer = %Enemies
@onready var hazards: TileMapLayer = %Hazards
@onready var player_spawn: TileMapLayer = %PlayerSpawn
@onready var pickups: TileMapLayer = %Pickups
@onready var puzzles: TileMapLayer = %Puzzles
