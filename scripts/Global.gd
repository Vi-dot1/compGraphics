extends Node

@onready var placement_particles_scn = preload("uid://dg1p2cew6y1qy")

func _create_placement_particles(pos: Vector3, rot: Vector3) -> Node3D:
	var particles = placement_particles_scn.instantiate()
	particles.position = pos
	particles.rotation = rot
	
	return particles

var planet_center:Vector3 = Vector3.ZERO
