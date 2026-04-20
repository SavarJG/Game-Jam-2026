extends StaticBody2D


func _on_spike_hit_body_entered(body: Node2D):
	if body.name == "Player":
		$Kill.play()
		body.kill()
