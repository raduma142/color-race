extends Spatial

#INIT
#nodes
var bg_light
var main_light
var lamppost_left
var lamppost_right
var lamppost_left_light
var lamppost_right_light
var lamppost_left_light2
var lamppost_right_light2
var color_line
var car
var car_body
var car_wheels1
var car_wheels2
var car_light1
var car_light2
var blocks = []
var road1
var road2
var road3
var line1_1
var line1_2
var line2_1
var line2_2
var line3_1
var line3_2
var health1
var health2
var health3
var menu_play
var menu_pause1
var menu_pause2

#colors
var textures = [
	load("res://textures/white.tres"),
	load("res://textures/red.tres"),
	load("res://textures/green.tres"),
	load("res://textures/blue.tres"),
	load("res://textures/yellow.tres"),
	load("res://textures/multicolor.tres"),
]
var colors = [
	Color.white,
	Color.red,
	Color.green,
	Color.blue,
	Color.yellow,
	Color.goldenrod
]
var car_color = -1
var next_color = 0
var blocks_color = [0, 0, 0, 0]

#roads
var car_road = 2
var from = 0
var to = 0
var able_roads = [0, 2, 2, 2]

#motion
var SPEED = 0
var NEXT_SPEED = 0
var SCORE = 0
var GAME_OVER = false
var WHITE_LIGHT = false
var MENU = true
var PAUSE = false
var PLAY = false
var pause_speeds = [0, 0]

#mouse data
var start_pos = Vector2()
var end_pos = Vector2()

#on create
func _ready():
	randomize()
	get_tree().connect("screen_resized", self, "_on_resize")
	_on_resize()
	
	bg_light = get_node("light/bg_light")
	main_light = get_node("light/main_light")
	lamppost_left = get_node("lampposts/lp_left")
	lamppost_right = get_node("lampposts/lp_right")
	lamppost_left_light = get_node("lampposts/lp_left/lp_light")
	lamppost_right_light = get_node("lampposts/lp_right/lp_light")
	lamppost_left_light2 = get_node("lampposts/lp_left/lp_light2")
	lamppost_right_light2 = get_node("lampposts/lp_right/lp_light2")
	color_line = get_node("color_parts/color_line")
	car = get_node("car")
	car_body = get_node("car/body")
	car_wheels1 = get_node("car/wheels1")
	car_wheels2 = get_node("car/wheels2")
	car_light1 = get_node("car/light1")
	car_light2 = get_node("car/light2")
	blocks = [NAN,
		get_node("color_parts/block1"),
		get_node("color_parts/block2"),
		get_node("color_parts/block3")]
	road1 = get_node("roads/road1")
	road2 = get_node("roads/road2")
	road3 = get_node("roads/road3")
	line1_1 = get_node("lines/line1_1")
	line1_2 = get_node("lines/line1_2")
	line2_1 = get_node("lines/line2_1")
	line2_2 = get_node("lines/line2_2")
	line3_1 = get_node("lines/line3_1")
	line3_2 = get_node("lines/line3_2")
	health1 = get_node("health/health1")
	health2 = get_node("health/health2")
	health3 = get_node("health/health3")
	menu_play = get_node("menu/play")
	menu_pause1 = get_node("menu/pause1")
	menu_pause2 = get_node("menu/pause2")

func removing_roads():
	if able_roads[1] == 1:
		health1.light_color = Color.yellow
	elif able_roads[1] == 0:
		health1.light_color = Color.red
		
	if able_roads[2] == 1:
		health2.light_color = Color.yellow
	elif able_roads[2] == 0:
		health2.light_color = Color.red
		
	if able_roads[3] == 1:
		health3.light_color = Color.yellow
	elif able_roads[3] == 0:
		health3.light_color = Color.red

func _input(event):
	if MENU:
		if event is InputEventMouseButton:
			if event.pressed == false:
				MENU = false
				PLAY = true
				SCORE = 0
				SPEED = 0
				NEXT_SPEED = 5
	elif GAME_OVER:
		if event is InputEventMouseButton:
			if event.pressed == false:
				WHITE_LIGHT = true
	elif event is InputEventMouseButton:
		if event.pressed:
			start_pos = event.position
		else:
			end_pos = event.position
			if not PAUSE and abs(end_pos.x - start_pos.x) > 25:
				if (end_pos.x < start_pos.x):
					init_move_car(true, false)
				else:
					init_move_car(false, true)
			else:
				if PAUSE:
					SPEED = pause_speeds[0]
					NEXT_SPEED = pause_speeds[1]
					PAUSE = false
				else:
					PAUSE = true
					PLAY = false
					pause_speeds = [SPEED, NEXT_SPEED]
					SPEED = 0
					NEXT_SPEED = 0

func init_move_car(left, right):
	if left and car_road != 0:
		if 2 < car_road and able_roads[2] > 0:
			from = car_road
			to = 2
			car_road = 0
		elif 1 < car_road and able_roads[1] > 0:
			from = car_road
			to = 1
			car_road = 0
	
	if right and car_road != 0:
		if 2 > car_road and able_roads[2] > 0:
			from = car_road
			to = 2
			car_road = 0
		elif 3 > car_road and able_roads[3] > 0:
			from = car_road
			to = 3
			car_road = 0

func crash_road(i):
	able_roads[i] -= 1
	
	if able_roads[i] == 0:
		var rm_road = get_node("roads/road" + str(i))
		rm_road.set_material_override(textures[1])
		if i != 1 and able_roads[1] > 0:
			from = i
			to = 1
			car_road = 0
		elif i != 2 and able_roads[2] > 0:
			from = i
			to = 2
			car_road = 0
		elif i != 3 and able_roads[3] > 0:
			from = i
			to = 3
			car_road = 0
		else:
			GAME_OVER = true
			NEXT_SPEED = 0
			$"menu/game_over".visible = true
	
	removing_roads()

func set_main_color():
	car_body.set_material_override(textures[car_color])
	car_wheels1.set_material_override(textures[car_color])
	car_wheels2.set_material_override(textures[car_color])
	line1_1.set_material_override(textures[car_color])
	line1_2.set_material_override(textures[car_color])
	line2_1.set_material_override(textures[car_color])
	line2_2.set_material_override(textures[car_color])
	line3_1.set_material_override(textures[car_color])
	line3_2.set_material_override(textures[car_color])
	lamppost_left_light.light_color = colors[car_color]
	lamppost_right_light.light_color = colors[car_color]
	lamppost_left_light2.light_color = colors[car_color]
	lamppost_right_light2.light_color = colors[car_color]
	car_light1.light_color = colors[car_color]
	car_light2.light_color = colors[car_color]

func new_color_line():
	var new_z = -(randf() * 100 + 40)
	var z1 = blocks[1].translation.z
	var z2 = blocks[2].translation.z
	var z3 = blocks[3].translation.z
	var min_dZ = 0
	while min_dZ < 2:
		new_z = -(randf() * 100 + 40)
		min_dZ = min(abs(new_z - z1), min(abs(new_z - z2), abs(new_z - z3)))
	color_line.translation.z = new_z
	next_color = car_color
	while (next_color == car_color):
		next_color = round(rand_range(0, len(textures) - 1))
		if next_color == 5:
			var r = randf()
			if r < 0.6:
				next_color = car_color
	color_line.set_material_override(textures[next_color])
	main_light.light_color = colors[next_color]


func _on_resize():
	var pos = OS.get_window_size()
	var font_size = pos.y / 100 * 6
	pos.x = pos.x / 2 - 100
	pos.y = 0
	$"menu/score".get("custom_fonts/font").set_size(font_size)
	$"menu/score".rect_position = pos

#PROCESS var
var temp_z

func _physics_process(delta):
	
	if not PLAY and not MENU:
		print(menu_pause1.rotation.z)
		if PAUSE:
			if menu_pause1.rotation_degrees.z > 0:
				menu_pause1.rotation_degrees.z -= 6
				menu_pause2.rotation_degrees.z -= 6
			else:
				menu_pause1.rotation_degrees.z = 0
				menu_pause2.rotation_degrees.z = 0
			menu_pause1.visible = true
			menu_pause2.visible = true
		else:
			if menu_pause1.rotation_degrees.z > -90:
				menu_pause1.rotation_degrees.z -= 6
				menu_pause2.rotation_degrees.z -= 6
			else:
				menu_pause1.rotation_degrees.z = 90
				menu_pause2.rotation_degrees.z = 90
				menu_pause1.visible = false
				menu_pause2.visible = false
				PLAY = true
	
	drive(delta * SPEED)
	
	if car_road == 0:
		move_car(delta)
	car.rotation /= 2
	
	if WHITE_LIGHT:
		if bg_light.light_energy <= 15:
			bg_light.light_energy += 0.5
		else:
			get_tree().reload_current_scene()
	else:
		if bg_light.light_energy > 0.5:
			bg_light.light_energy -= 0.5
		else:
			bg_light.light_energy = 0.5
	
	#Main Light
	temp_z = color_line.translation.z
	if temp_z >= 1 and temp_z <= 4:
		main_light.light_energy = sin((temp_z - 1) / 3 * 3.14) * 5
	else:
		main_light.light_energy = 0

func _process(delta):
	#multicolor texture
	if next_color == 5:
		var mat = color_line.get_material_override()
		mat.uv1_offset.y += 0.01
		color_line.set_material_override(mat)
	if car_color == 5:
		var mat = car_body.get_material_override()
		mat.uv1_offset.y += 0.01
		car_body.set_material_override(mat)
	
	SPEED += (0.1 + SPEED * 0.02) * sign(NEXT_SPEED - SPEED)
	
	get_input()
	
	#lampposts
	if lamppost_left.translation.z > 10:
		lamppost_left.translation.z = -10
	if lamppost_right.translation.z > 10:
		lamppost_right.translation.z = -10
	
	#colorline
	if color_line.translation.z > 10:
		new_color_line()
		NEXT_SPEED += 1
	elif color_line.translation.z > 3.5:
		if car_color != next_color:
			car_color = next_color
			set_main_color()
	
	#block_N
	for N in range(1, 4):
		temp_z = blocks[N].translation.z
		if temp_z > 3.5:
			if car_road == N and blocks_color[N] != -1:
				if blocks_color[N] == car_color or car_color == 5:
					SCORE += 1
					$"menu/score".text = str(SCORE)
				else:
					SPEED /= 2
					crash_road(N)
			blocks_color[N] = -1
			if temp_z > 10:
				var new_z = -(randf() * 30 + 10)
				var z1 = color_line.translation.z
				while abs(new_z - z1) < 2:
					new_z = -(randf() * 30 + 10)
				blocks[N].translation.z = new_z
				blocks_color[N] = round(rand_range(0, len(textures) - 2))
				blocks[N].set_material_override(textures[blocks_color[N]])

func get_input():
	var left = Input.is_action_just_pressed("ui_left")
	var right = Input.is_action_just_pressed("ui_right")
	if left or right:
		init_move_car(left, right)
	
	if Input.is_action_just_pressed("ui_accept"):
		if MENU:
			MENU = false
			SCORE = 0
			SPEED = 0
			NEXT_SPEED = 5
			$"menu/play".visible = false
		if GAME_OVER:
			get_tree().reload_current_scene()

func drive(delta_SPEED):
	blocks[1].translation.z += delta_SPEED
	blocks[2].translation.z += delta_SPEED
	blocks[3].translation.z += delta_SPEED
	color_line.translation.z += delta_SPEED
	lamppost_left.translation.z += delta_SPEED
	lamppost_right.translation.z += delta_SPEED
	if menu_play.translation.z < 10:
		menu_play.translation.z += delta_SPEED

func move_car(delta):
	var roads_x = [NAN, -2.8, 0, 2.8]
	var k = sign(to - from)
	var delta_SPEED = SPEED * 8 * delta
	
	car.rotation.y -= k * 0.5
	if k > 0: #right
		if car.translation.x + delta_SPEED < roads_x[to]:
			car.translation.x += delta_SPEED
		else:
			car.translation.x = roads_x[to]
			car_road = to
	else: #left
		if car.translation.x - delta_SPEED > roads_x[to]:
			car.translation.x -= delta_SPEED
		else:
			car.translation.x = roads_x[to]
			car_road = to
