extends Node

const default_cost:= 15.0

enum {JOY, SAD, ANG}

var combos: Dictionary[StringName, Dictionary] = {
	## 2 elements
	"spell_1" : {
		"combo" : [JOY, JOY],
		"name" : "Spell 1",
		"mana_cost" : 0.0,
		"unlocked" : true,
		"icon_path" : "res://player/combo_textures/default_combo_icon.png",
		"color" : Color.WHITE,
		"sfx_path" : "",
	},
	
	"spell_2" : {
		"combo" : [JOY, SAD],
		"name" : "Spell",
		"mana_cost" : 0.0,
		"unlocked" : true,
		"icon_path" : "res://player/combo_textures/default_combo_icon.png",
		"color" : Color.WHITE,
		"sfx_path" : "",
	},
	
	"spell_3" : {
		"combo" : [JOY, ANG],
		"mana_cost" : 0.0,
		"name" : "Spell",
		"unlocked" : true,
		"icon_path" : "res://player/combo_textures/default_combo_icon.png",
		"color" : Color.WHITE,
		"sfx_path" : "",
	},
	
	"spell_4" : {
		"combo" : [SAD, SAD],
		"name" : "Spell",
		"mana_cost" : 0.0,
		"unlocked" : true,
		"icon_path" : "res://player/combo_textures/default_combo_icon.png",
		"color" : Color.WHITE,
		"sfx_path" : "",
	},
	
	"spell_5" : {
		"combo" : [SAD, ANG],
		"name" : "Spell",
		"mana_cost" : 0.0,
		"unlocked" : true,
		"icon_path" : "res://player/combo_textures/default_combo_icon.png",
		"color" : Color.WHITE,
		"sfx_path" : "",
	},
	
	"spell_6" : {
		"combo" : [ANG, ANG],
		"name" : "Spell",
		"mana_cost" : 0.0,
		"unlocked" : true,
		"icon_path" : "res://player/combo_textures/default_combo_icon.png",
		"color" : Color.WHITE,
		"sfx_path" : "",
	},
	
	## 3 elements
	## Joy
	"spell_7" : {
		"combo" : [JOY, JOY, JOY],
		"name" : "Bubble",
		"mana_cost" : default_cost,
		"extra_amount" : 5,
		"delay" : 0.1,
		"unlocked" : true,
		"icon_path" : "res://player/combo_textures/default_combo_icon.png",
		"color" : Color.WHITE,
		"sfx_path" : "",
	},
	
	"spell_8" : {
		"combo" : [JOY, JOY, SAD],
		"name" : "Shell",
		"mana_cost" : default_cost,
		"unlocked" : true,
		"supress_attack" : null,
		"icon_path" : "res://player/combo_textures/default_combo_icon.png",
		"color" : Color.WHITE,
		"sfx_path" : "",
	},
	
	"spell_9" : {
		"combo" : [JOY, JOY, ANG],
		"name" : "Spell",
		"mana_cost" : 0.0,
		"unlocked" : true,
		"icon_path" : "res://player/combo_textures/default_combo_icon.png",
		"color" : Color.WHITE,
		"sfx_path" : "",
	},
	
	## Sadness
	"spell_10" : {
		"combo" : [SAD, SAD, SAD],
		"name" : "Spell",
		"mana_cost" : 0.0,
		"unlocked" : true,
		"icon_path" : "res://player/combo_textures/default_combo_icon.png",
		"color" : Color.WHITE,
		"sfx_path" : "",
	},
	
	"spell_11" : {
		"combo" : [SAD, SAD, JOY],
		"name" : "Wish",
		"mana_cost" : 33.0,
		"unlocked" : true,
		"supress_attack" : null,
		"icon_path" : "res://player/combo_textures/default_combo_icon.png",
		"color" : Color.WHITE,
		"sfx_path" : "",
	},
	
	"spell_12" : {
		"combo" : [SAD, SAD, ANG],
		"name" : "Spell",
		"mana_cost" : 0.0,
		"unlocked" : true,
		"icon_path" : "res://player/combo_textures/default_combo_icon.png",
		"color" : Color.WHITE,
		"sfx_path" : "",
	},
	
	## Anger
	"spell_13" : {
		"combo" : [ANG, ANG, ANG],
		"name" : "Violence",
		"mana_cost" : default_cost,
		"unlocked" : true,
		"projectile_effect_path" : "res://projectile/projectile_effects/blast_pe.tscn",
		"icon_path" : "res://player/combo_textures/default_combo_icon.png",
		"color" : Color.WHITE,
		"sfx_path" : "",
	},
	
	"spell_14" : {
		"combo" : [ANG, ANG, JOY],
		"name" : "Spell",
		"mana_cost" : 0.0,
		"unlocked" : true,
		"icon_path" : "res://player/combo_textures/default_combo_icon.png",
		"color" : Color.WHITE,
		"sfx_path" : "",
	},
	
	"spell_15" : {
		"combo" : [ANG, ANG, SAD],
		"name" : "Spell",
		"mana_cost" : 0.0,
		"unlocked" : true,
		"icon_path" : "res://player/combo_textures/default_combo_icon.png",
		"color" : Color.WHITE,
		"sfx_path" : "",
	},
	
	## All 3
	"spell_16" : {
		"combo" : [JOY, SAD, ANG],
		"name" : "Spell",
		"mana_cost" : 0.0,
		"unlocked" : true,
		"icon_path" : "res://player/combo_textures/default_combo_icon.png",
		"color" : Color.WHITE,
		"sfx_path" : "",
	},
	
}
