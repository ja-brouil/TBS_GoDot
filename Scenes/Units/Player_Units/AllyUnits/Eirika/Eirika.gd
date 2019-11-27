extends Battlefield_Unit

func _ready():
	# Initial Animation
	$Animation.current_animation = "Idle"
	
	# Set this when the level loads but for now, this is just a test to simply things
	UnitStats.name = "Eirika"
	
	# Unit Portrait
	unit_portrait_path = preload("res://assets/units/eirika/eirikaPortrait.png")
	
	# Unit Mugshot
	unit_mugshot = preload("res://assets/units/eirika/eirika mugshot.png")
	
	# Add 2nd Steel sword
	UnitInventory.add_item(preload("res://Scenes/Items/Swords/Iron Sword.tscn").instance())
	
	# Add Steel sword
	UnitInventory.add_item(preload("res://Scenes/Items/Swords/Steel Sword.tscn").instance())

	# Add 3rd Steel sword
	UnitInventory.add_item(preload("res://Scenes/Items/Swords/Rapier.tscn").instance())
	
	# Set combat node
	combat_node = preload("res://Scenes/Units/Player_Units/AllyUnits/Eirika/Eirika Combat.tscn")