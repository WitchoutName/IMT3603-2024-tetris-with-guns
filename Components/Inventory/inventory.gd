extends Node
class_name Inventory


enum ItemSlot { RIGHT_HAND, LEFT_HAND, ITEM_SLOT }

signal slot_change(current_slot: ItemSlot)
signal slot_state_change(current_slot: ItemSlot, slot: BaseItem)

@export var current_slot = ItemSlot.LEFT_HAND

@onready var player: Player = get_parent()

#The inventory slots
var right_hand: Node2D = null
var left_hand: Node2D = null
var item_slot: Node2D = null

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
	slot_change.emit(current_slot)


func equip_item(item: Node2D):
	slot_state_change.emit(current_slot, item)
	if item.is_in_group("one-handed"):
		#No matter the slot, if current weapon is two handed, it needs to be dropped
		if right_hand != null && right_hand.is_in_group("two-handed") and not right_hand.is_queued_for_deletion():
			right_hand.call_drop()
			right_hand = null
		match current_slot:
			ItemSlot.RIGHT_HAND:
				if right_hand != null and not right_hand.is_queued_for_deletion():
					right_hand.call_drop()
				right_hand = item.change_parent($RightHand)
			ItemSlot.LEFT_HAND:
				if left_hand != null and not left_hand.is_queued_for_deletion():
					left_hand.call_drop()
				left_hand = item.change_parent($LeftHand)
				print(left_hand.get_path())
			ItemSlot.ITEM_SLOT:
				pass
			_:
				#Unexpected selection, should not be possible, reverting to right
				#and doing nothing
				current_slot = ItemSlot.RIGHT_HAND
				print("ERROR: Unknown item slot selected, reverting to default")
	elif item.is_in_group("two-handed"):
		#Drop both weapons
		if right_hand != null and not right_hand.is_queued_for_deletion():
			right_hand.call_drop()
		if left_hand != null and not left_hand.is_queued_for_deletion():
			left_hand.call_drop()
		left_hand = null
		right_hand = item.change_parent($RightHand)
	elif item.is_in_group("item"):
		if item_slot:
			item_slot.call_drop()
		item_slot = item.change_parent($ItemSlot)

func unequip_item():
	slot_state_change.emit(current_slot, null)
	match current_slot:
		ItemSlot.RIGHT_HAND:
			if right_hand != null and not right_hand.is_queued_for_deletion():
				right_hand.call_drop()
				right_hand = null
		ItemSlot.LEFT_HAND:
			if right_hand && right_hand.is_in_group("two-handed") && not right_hand.is_queued_for_deletion(): #Allowing for weapon switch when two handing
				right_hand.call_drop()
				right_hand = null
			if left_hand != null and not left_hand.is_queued_for_deletion():
				left_hand.call_drop()
				left_hand = null 
		ItemSlot.ITEM_SLOT:
			if item_slot != null and not item_slot.is_queued_for_deletion():
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
	if right_hand != null && right_hand.is_in_group("two-handed"):
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
		if slot != null and not slot.is_queued_for_deletion():
			slot.call_drop()
			slot.set_multiplayer_authority(1)
			
	slot_state_change.emit(ItemSlot.RIGHT_HAND, null)
	slot_state_change.emit(ItemSlot.LEFT_HAND, null)
	slot_state_change.emit(ItemSlot.ITEM_SLOT, null)
	right_hand = null
	left_hand = null
	item_slot = null

func remove(item):
	if right_hand == item:
		right_hand = null
	elif left_hand == item:
		left_hand = null
	elif item_slot == item:
		item_slot = null

func clear_slot_right():
	slot_state_change.emit(ItemSlot.RIGHT_HAND, null)
	right_hand = null

func clear_slot_left():
	slot_state_change.emit(ItemSlot.LEFT_HAND, null)
	left_hand = null 

func clear_slot_item():
	slot_state_change.emit(ItemSlot.ITEM_SLOT, null)
	item_slot = null

func delete_inventory():
	if right_hand:
		slot_state_change.emit(ItemSlot.RIGHT_HAND, null)
		right_hand.destroy.rpc()
		right_hand = null
	if left_hand:
		slot_state_change.emit(ItemSlot.LEFT_HAND, null)
		left_hand.destroy.rpc()
		left_hand = null
	if item_slot:
		slot_state_change.emit(ItemSlot.ITEM_SLOT, null)
		item_slot.destroy.rpc()
		item_slot = null
