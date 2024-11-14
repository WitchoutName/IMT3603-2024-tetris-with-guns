extends "res://Components/WeaponScripts/gun.gd"

func _init() -> void:
	bulletSpeed = 1000
	bps = 10
	bulletDamage = 30
	bulletSpread = 0.1
	timeSinceFired = 0
	mag_size = 30
	ammo_in_mag = mag_size
	reloadInterval = 1
	
@rpc("any_peer", "call_local")
func shoot():
		var bullet = bulletScene.instantiate()
		var casing = casingScene.instantiate()
		if $AnimatedSprite2D.is_playing():
			$AnimatedSprite2D.stop()
		
		get_tree().root.add_child(bullet)
		bullet.rotation = $Barrel.global_rotation + randf_range(-bulletSpread,bulletSpread)
		bullet.position = $Barrel.global_position
		bullet.linear_velocity = bullet.transform.x * bulletSpeed
		
		
		$AnimatedSprite2D.play("Fire")
		get_tree().root.add_child(casing)
		casing.rotation = $Eject.global_rotation + randf_range(-0.25, 0)
		casing.position = $Eject.global_position
		casing.linear_velocity = casing.transform.y * -150
		timeSinceFired = 0
		ammo_in_mag -= 1

func shooting_logic(delta: float) -> void:
	if not is_multiplayer_authority(): return
	if Input.is_action_pressed(fire_mode) and timeSinceFired > fireRate and ammo_in_mag > 0 and !isReloading:
		shoot.rpc_id(1)
	else:
		timeSinceFired += delta
