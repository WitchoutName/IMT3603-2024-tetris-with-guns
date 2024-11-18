extends Node
class_name Inventory

enum ItemSlot { RIGHT_HAND, LEFT_HAND, ITEM_SLOT }

var current_slot = ItemSlot.LEFT_HAND

@onready var player: Player = get_parent()

#The inventory slots
var right_hand = null
var left_hand = null
var item_slot = null

func _input(event):
	if not is_multiplayer_authority(): return
	#Handling slot switching
	if event.is_action_pressed("switch_to_slot_1"):
		switch_slot(ItemSlot.LEFT_HAND)
	elif event.is_action_pressed("switch_to_slot_2"):
		switch_slot(ItemSlot.RIGHT_HAND)
	elif event.is_action_pressed("switch_to_slot_3"):
		switch_slot(ItemSlot.ITEM_SLOT)
	elif event.is_action_pressed("drop"):
		unequip_item()

func _process(delta):
	pass

func switch_slot(slot: ItemSlot):
	current_slot = slot


func equip_item(item: Node2D):
	if item.is_in_group("one-handed"):
		#No matter the slot, if current weapon is two handed, it needs to be dropped
		if right_hand && right_hand.is_in_group("two-handed"):
			right_hand.call_drop()
			right_hand = null
		match current_slot:
			ItemSlot.RIGHT_HAND:
				if right_hand:
					right_hand.call_drop()
				right_hand = item
				item.change_parent($RightHand)
			ItemSlot.LEFT_HAND:
				if left_hand:
					left_hand.call_drop()
				left_hand = item
				print(item.get_path())
				item.change_parent($LeftHand)
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
			right_hand.call_drop()
		if left_hand:
			left_hand.call_drop()
		left_hand = null
		right_hand = item
		item.change_parent($RightHand)
	elif item.is_in_group("item"):
		if item_slot:
			item_slot.call_drop()
		item_slot = item
		item.change_parent(player)

func unequip_item():
	match current_slot:
		ItemSlot.RIGHT_HAND:
			if right_hand:
				right_hand.call_drop()
				right_hand = null
		ItemSlot.LEFT_HAND:
			if right_hand && right_hand.is_in_group("two-handed"): #Allowing for weapon switch when two handing
				right_hand.call_drop()
				right_hand = null
			elif left_hand:
				left_hand.call_drop()
				left_hand = null 
		ItemSlot.ITEM_SLOT:
			if item_slot:
				item_slot.call_drop()
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
			return "click2"
		ItemSlot.LEFT_HAND:
			return "click"
		_:
			return null

#Unequips everything
func unequip_everything():
	for slot in [right_hand, left_hand, item_slot]:
		if slot:
			slot.call_drop()
			slot.set_multiplayer_authority(1)
	right_hand = null
	left_hand = null
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
