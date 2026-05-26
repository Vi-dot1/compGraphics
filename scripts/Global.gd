extends Node

@onready var placement_particles_scn = preload("uid://dg1p2cew6y1qy")

var piece_color:Color = Color(0.056, 0.07, 0.304, 0.8)

func _create_placement_particles(pos: Vector3) -> Node3D:
	var particles:CPUParticles3D = placement_particles_scn.instantiate()
	particles.position = pos
	particles.finished.connect(particles.queue_free)
	return particles

var planet_center:Vector3 = Vector3.ZERO
var planet_radius:float = 0
