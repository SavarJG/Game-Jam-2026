extends Node2D


func _ready():
	if GameState.respawn_position != Vector2.ZERO:
		$Player.global_position = GameState.respawn_position
	else:
		$Player.global_position = $SpawnPoint.global_position
		GameState.respawn_position = $SpawnPoint.global_position
	$Music.play()
