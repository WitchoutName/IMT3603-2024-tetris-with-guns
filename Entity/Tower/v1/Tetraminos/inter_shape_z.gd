extends StaticBody2D

@onready var interaction_area: InteractionArea = $InteractionArea

# Called when the node enters the scene tree for the first time.
func _ready():
	interaction_area.interact = Callable(self, "_on_interact") #Assigning interact function


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

func _on_interact():
	print("It works!")
