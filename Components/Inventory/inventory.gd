extends Node
class_name Inventory

enum ItemSlot { RIGHT_HAND, LEFT_HAND, ITEM_SLOT }

var current_slot = ItemSlot.RIGHT_HAND

@onready var player = get_parent()

#The inventory slots
var right_hand = null
var left_hand = null
var item_slot = null

func _input(event):
	#Handling slot switching
	if event.is_action_pressed("switch_to_slot_1"):
		switch_slot(ItemSlot.RIGHT_HAND)
	elif event.is_action_pressed("switch_to_slot_2"):
		switch_slot(ItemSlot.LEFT_HAND)
	elif event.is_action_pressed("switch_to_slot_3"):
		switch_slot(ItemSlot.ITEM_SLOT)
	elif event.is_action_pressed("drop"):
		unequip_item()

func _process(delta):
	if left_hand:
		left_hand.global_position = player.global_position
		left_hand.global_position.x += 4
	if right_hand:
		right_hand.global_position = player.global_position
		right_hand.global_position.x -= 4

func switch_slot(slot: ItemSlot):
	current_slot = slot

func equip_item(item):
	if item.is_in_group("one-handed"):
		#No matter the slot, if current weapon is two handed, it needs to be dropped
		if right_hand && right_hand.is_in_group("two-handed"):
			right_hand._drop()
			right_hand = null
		match current_slot:
			ItemSlot.RIGHT_HAND:
				if right_hand:
					await right_hand._drop()
				right_hand = item
			ItemSlot.LEFT_HAND:
				if left_hand:
					await left_hand._drop()
				left_hand = item 
			ItemSlot.ITEM_SLOT:
				pass
			_:
				#Unexpected selection, should not be possible, reverting to right
				#and doing nothing
				current_slot = ItemSlot.RIGHT_HAND
				print("ERROR: Unknown item slot selected, reverting to default")
	elif item.is_in_group("two-handed"):
		#Drop both weapons
		if right_hand:
			right_hand._drop()
		if left_hand:
			left_hand._drop()
		left_hand = null
		right_hand = item
	elif item.is_in_group("item"):
		if item_slot:
			item_slot._drop()
		item_slot = item

func unequip_item():
	match current_slot:
		ItemSlot.RIGHT_HAND:
			if right_hand:
				right_hand._drop()
				right_hand = null
		ItemSlot.LEFT_HAND:
			if right_hand && right_hand.is_in_group("two-handed"): #Allowing for weapon switch when two handing
				right_hand._drop()
				right_hand = null
			elif left_hand:
				left_hand._drop()
				left_hand = null 
		ItemSlot.ITEM_SLOT:
			if item_slot:
				item_slot._drop()
				item_slot = null
		_:
			current_slot = ItemSlot.RIGHT_HAND
			print("ERROR: Unknown item slot selected, reverting to default")

#Returns the item in the currently selected slot
func get_current_slot():
	match current_slot:
		ItemSlot.RIGHT_HAND:
			return right_hand
		ItemSlot.LEFT_HAND:
			return left_hand 
		ItemSlot.ITEM_SLOT:
			return item_slot

#Returns firemode for item
func get_fire_mode():
	if right_hand && right_hand.is_in_group("two-handed"):
		return "click3"
	match current_slot:
		ItemSlot.RIGHT_HAND:
			return "click"
		ItemSlot.LEFT_HAND:
			return "click2"
		_:
			return null

#Unequips everything
func unequip_everything():
	if right_hand:
		right_hand._drop()
		right_hand = null
	if left_hand:
		left_hand._drop()
		left_hand = null 
	if item_slot:
		item_slot._drop()
		item_slot = null
		

func clear_slot_right():
	if right_hand:
		right_hand = null

func clear_slot_left():
	if left_hand:
		left_hand = null 

func clear_slot_item():
	if item_slot:
		item_slot = null
