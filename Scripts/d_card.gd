extends Card
class_name DCard

func _ready():
	card_type = CardType.D
	rotation_degrees = Vector3(0, 0, 0)  # Make it horizontal
	super._ready()

# D cards cannot split
func split():
	print("Defense cards cannot be split")

func update_visuals():
	mesh_instance.material_override.albedo_color = Color.BLUE
