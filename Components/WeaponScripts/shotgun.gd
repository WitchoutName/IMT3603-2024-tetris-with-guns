extends "res://Components/WeaponScripts/gun.gd"

@export var bulletAmount = 5

func _init() -> void:
	bulletSpeed = 1000
	bps = 5
	bulletDamage = 30
	bulletSpread = 1
	timeUntilFire = 0
	maxMag = 6
	currentMag = maxMag
	reloadTime = 1
	maxRecoil = 20.0
	recoilIncrement = maxRecoil * 0.2
	

func shoot(delta):
	
	if Input.is_action_just_pressed(fire_mode) and timeUntilFire > fireRate and currentMag > 0 and !isReloading:
		var bullet = bulletScene.instantiate()
		var casing = casingScene.instantiate()
		if $AnimatedSprite2D.is_playing():
			$AnimatedSprite2D.stop()
			
		
			print("bullet spawned")
			
		
		
		$AnimatedSprite2D.play("Fire")
		get_tree().root.add_child(casing)
		casing.rotation = $Eject.global_rotation + randf_range(-0.25, 0)
		casing.position = $Eject.global_position
		casing.linear_velocity = casing.transform.y * -150
		timeUntilFire = 0
		currentMag -= 1
		currentRecoil = clamp(currentRecoil + recoilIncrement, 0.0, maxRecoil)
	else:
		timeUntilFire += delta
