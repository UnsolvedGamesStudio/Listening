extends Node
## Todo: Put things like amount in the data
const DEFAULT_COST:= 15.0

enum {JOY, SAD, ANG}

var combos: Dictionary[StringName, Dictionary] = {
	## 2 elements
	"spell_1" : {
		"combo" : [JOY, JOY],
		"name" : "Spell 1",
		"data" : null,
		"mana_cost" : 0.0,
		"unlocked" : true,
		"icon_path" : "res://player/combo_textures/default_combo_icon.png",
		"sfx_path" : "",
	},
	
	"spell_2" : {
		"combo" : [JOY, SAD],
		"name" : "Wish",
		"data" : null,
		"mana_cost" : 33.0,
		"unlocked" : true,
		"supress_attack" : null,
		"icon_path" : "res://player/combo_textures/default_combo_icon.png",
		"sfx_path" : "",
	},
	
	"spell_3" : {
		"combo" : [JOY, ANG],
		"mana_cost" : 0.0,
		"data" : null,
		"name" : "Spell",
		"unlocked" : true,
		"icon_path" : "res://player/combo_textures/default_combo_icon.png",
		"sfx_path" : "",
	},
	
	"spell_4" : {
		"combo" : [SAD, SAD],
		"name" : "Spell",
		"data" : null,
		"mana_cost" : 0.0,
		"unlocked" : true,
		"icon_path" : "res://player/combo_textures/default_combo_icon.png",
		"sfx_path" : "",
	},
	
	"spell_5" : {
		"combo" : [SAD, ANG],
		"name" : "Spell",
		"data" : null,
		"mana_cost" : 0.0,
		"unlocked" : true,
		"icon_path" : "res://player/combo_textures/default_combo_icon.png",
		"sfx_path" : "",
	},
	
	"spell_6" : {
		"combo" : [ANG, ANG],
		"name" : "Spell",
		"data" : null,
		"mana_cost" : 0.0,
		"unlocked" : true,
		"icon_path" : "res://player/combo_textures/default_combo_icon.png",
		"sfx_path" : "",
	},
	
	## 3 elements
	## Joy
	"spell_7" : {
		"combo" : [JOY, JOY, JOY],
		"name" : "Bubble",
		"data" : preload("res://projectile/projectile_data/bubble.tres"),
		"mana_cost" : DEFAULT_COST,
		"extra_amount" : 5,
		"delay" : 0.1,
		"unlocked" : true,
		"icon_path" : "res://player/combo_textures/default_combo_icon.png",
		"sfx_path" : "",
	},
	
	"spell_8" : {
		"combo" : [JOY, JOY, SAD],
		"name" : "Shell",
		"data" : null,
		"mana_cost" : DEFAULT_COST,
		"unlocked" : true,
		"supress_attack" : null,
		"icon_path" : "res://player/combo_textures/default_combo_icon.png",
		"sfx_path" : "",
	},
	
	"spell_9" : {
		"combo" : [JOY, JOY, ANG],
		"name" : "Spell",
		"data" : null,
		"mana_cost" : 0.0,
		"unlocked" : true,
		"icon_path" : "res://player/combo_textures/default_combo_icon.png",
		"sfx_path" : "",
	},
	
	## Sadness
	"spell_10" : {
		"combo" : [SAD, SAD, SAD],
		"name" : "Frostbite",
		"data" : preload("res://projectile/projectile_data/frostbite.tres"),
		"mana_cost" : DEFAULT_COST,
		"unlocked" : true,
		"projectile_effect_path" : "res://projectile/projectile_effects/damaging_aura_pe.tscn",
		"icon_path" : "res://player/combo_textures/default_combo_icon.png",
		"sfx_path" : "",
	},
	
	"spell_11" : {
		"combo" : [SAD, SAD, JOY],
		"name" : "Spell",
		"data" : null,
		"mana_cost" : 0.0,
		"unlocked" : true,
		"icon_path" : "res://player/combo_textures/default_combo_icon.png",
		"sfx_path" : "",
	},
	
	"spell_12" : {
		"combo" : [SAD, SAD, ANG],
		"name" : "Weight",
		"data" : preload("res://projectile/projectile_data/weight.tres"),
		"mana_cost" : DEFAULT_COST,
		"projectile_override": preload("res://projectile/cube_spell_projectile.tscn"),
		"unlocked" : true,
		"icon_path" : "res://player/combo_textures/default_combo_icon.png",
		"sfx_path" : "",
	},
	
	## Anger
	"spell_13" : {
		"combo" : [ANG, ANG, ANG],
		"name" : "Violence",
		"data" : preload("res://projectile/projectile_data/violence.tres"),
		"mana_cost" : DEFAULT_COST,
		"unlocked" : true,
		"projectile_effect_path" : "res://projectile/projectile_effects/blast_pe.tscn",
		"icon_path" : "res://player/combo_textures/default_combo_icon.png",
		"sfx_path" : "",
	},
	
	"spell_14" : {
		"combo" : [ANG, ANG, JOY],
		"name" : "Spell",
		"data" : null,
		"mana_cost" : 0.0,
		"unlocked" : true,
		"icon_path" : "res://player/combo_textures/default_combo_icon.png",
		"sfx_path" : "",
	},
	
	"spell_15" : {
		"combo" : [ANG, ANG, SAD],
		"name" : "Spell",
		"data" : null,
		"mana_cost" : 0.0,
		"unlocked" : true,
		"icon_path" : "res://player/combo_textures/default_combo_icon.png",
		"sfx_path" : "",
	},
	
	## All 3
	"spell_16" : {
		"combo" : [JOY, SAD, ANG],
		"name" : "Spell",
		"data" : null,
		"mana_cost" : 0.0,
		"unlocked" : true,
		"icon_path" : "res://player/combo_textures/default_combo_icon.png",
		"sfx_path" : "",
	},
	
}
