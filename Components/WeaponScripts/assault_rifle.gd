extends "res://Components/WeaponScripts/gun.gd"

func _init() -> void:
	bulletSpeed = 1000
	bps = 10
	bulletDamage = 30
	bulletSpread = 0.1
	timeUntilFire = 0
	maxMag = 30
	currentMag = maxMag
	reloadTime = 1
	
	

func shoot(delta: float) -> void:
	
	if Input.is_action_pressed(fire_mode) and timeUntilFire > fireRate and currentMag > 0 and !isReloading:
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
		timeUntilFire = 0
		currentMag -= 1
		
	else:
		timeUntilFire += delta
