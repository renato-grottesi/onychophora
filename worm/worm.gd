extends Node2D

signal win
signal lose

var sections = [Vector2(1,1), Vector2(2,1), Vector2(3,1)]
var tail
var body
var join
var head
var soil
var rock
var door
var food
var mold
var stable = 128

var dead = false

func _ready():
	tail = $Map.tile_set.find_tile_by_name("tail")
	body = $Map.tile_set.find_tile_by_name("body")
	join = $Map.tile_set.find_tile_by_name("join")
	head = $Map.tile_set.find_tile_by_name("head")
	soil = $Map.tile_set.find_tile_by_name("soil")
	rock = $Map.tile_set.find_tile_by_name("rock")
	door = $Map.tile_set.find_tile_by_name("door")
	food = $Map.tile_set.find_tile_by_name("food")
	mold = $Map.tile_set.find_tile_by_name("mold")
	
	for i in range(1, 16): fall()

func set_sections(new_sections):
	sections.clear()
	for s in new_sections:
		sections.append(s)
	draw()

func set_sections_from_head(h):
	sections.clear()
	for s in range(0, 3):
		sections.append(h+Vector2(s, 0))
	fall()

func _unhandled_input(event):
	if dead:
		return
	if event is InputEventKey:
		if event.pressed:
			var arrow = Vector2(0, 0)
			if event.scancode == KEY_LEFT or event.scancode == KEY_A:
				arrow = Vector2(-1, 0)
			if event.scancode == KEY_RIGHT or event.scancode == KEY_D:
				arrow = Vector2(1, 0)
			if event.scancode == KEY_UP or event.scancode == KEY_W:
				arrow = Vector2(0, -1)
			if event.scancode == KEY_DOWN or event.scancode == KEY_S:
				arrow = Vector2(0, 1)
			if arrow.length() > 0.0:
				var new_head = sections.back() + arrow
				if can_move_to(new_head):
					$"body".set_cellv(sections.front(), -1)
					if $Resources.get_cellv(new_head) == food:
						$Resources.set_cellv(new_head, -1)
					else:
						sections.pop_front();
					if $Resources.get_cellv(new_head) == mold:
						$Resources.set_cellv(new_head, -1)
						if sections.size() >= 3:
							sections.pop_front();
					sections.push_back(new_head)
					eat_soil(new_head)
				for i in range(1, 16): fall()
				if not check_win():
					check_buried()
					check_stuck()

func check_stuck():
	var h = sections.back()
	if not(can_move_to(h+Vector2(1, 0))) and not(can_move_to(h+Vector2(-1, 0))):
		if not(can_move_to(h+Vector2(0, 1))) and not(can_move_to(h+Vector2(0, -1))):
			dead = true
			emit_signal("lose")
			return

func check_buried():
	for c in $Map.get_used_cells_by_id(soil):
		for s in sections:
			if c == s:
				dead = true
				emit_signal("lose")
				return

func check_win():
	for c in $Resources.get_used_cells_by_id(door):
		for s in sections:
			if c == s:
				emit_signal("win")
				return true
	return false

func eat_soil(p):
	if $Map.get_cellv(p) == soil:
		$Map.set_cellv(p, -1)
	var unstable_tile_count = 1
	while unstable_tile_count > 0:
		# mark all soil cells as stable
		var soil_count = $Map.get_used_cells_by_id(soil).size()
		for c in $Map.get_used_cells_by_id(rock):
			if $Map.get_cellv(c+Vector2(1, 0))==soil: $Map.set_cellv(c+Vector2(1, 0), stable)
			if $Map.get_cellv(c+Vector2(-1, 0))==soil: $Map.set_cellv(c+Vector2(-1, 0), stable)
			if $Map.get_cellv(c+Vector2(0, 1))==soil: $Map.set_cellv(c+Vector2(0, 1), stable)
			if $Map.get_cellv(c+Vector2(0, -1))==soil: $Map.set_cellv(c+Vector2(0, -1), stable)
		var new_soil_count = $Map.get_used_cells_by_id(soil).size()
		while soil_count != new_soil_count:
			soil_count = new_soil_count
			for c in $Map.get_used_cells_by_id(stable):
				if $Map.get_cellv(c+Vector2(1, 0))==soil: $Map.set_cellv(c+Vector2(1, 0), stable)
				if $Map.get_cellv(c+Vector2(-1, 0))==soil: $Map.set_cellv(c+Vector2(-1, 0), stable)
				if $Map.get_cellv(c+Vector2(0, 1))==soil: $Map.set_cellv(c+Vector2(0, 1), stable)
				if $Map.get_cellv(c+Vector2(0, -1))==soil: $Map.set_cellv(c+Vector2(0, -1), stable)
			new_soil_count = $Map.get_used_cells_by_id(soil).size()
		# now let the unstable fall
		var unstable_tiles = []
		for c in $Map.get_used_cells_by_id(soil): unstable_tiles.append(c)
		unstable_tile_count = unstable_tiles.size()
		for c in $Map.get_used_cells_by_id(soil): $Map.set_cellv(c, -1)
		for c in unstable_tiles: $Map.set_cellv(c+Vector2(0, 1), soil)
		#finally mark all stable back as soil
		for c in $Map.get_used_cells_by_id(stable):
			$Map.set_cellv(c, soil)

enum dir {L=0, R=1, U=2, D=3}

func draw():
	for c in $body.get_used_cells():
		$body.set_cellv(c, -1)
	for s in range(0, sections.size()-1):
		var s_c = sections[s]
		if s_c != sections.back() and s_c != sections.front():
			var s_b = sections[s-1]
			var s_a = sections[s+1]
			if s_b.x == s_c.x and s_c.x == s_a.x:
				# horizontal section
				$body.set_cellv(s_c, body, s_b.x<s_a.x, false, true)
			elif s_b.y == s_c.y and s_c.y == s_a.y:
				# vertical section
				$body.set_cellv(s_c, body, false, s_b.y<s_a.y, false)
			# L sections
			elif s_b.x < s_c.x and s_c.y < s_a.y:
				# previous point on left and next below
				$body.set_cellv(s_c, join, true, false, true)
			elif s_b.x < s_c.x and s_c.y > s_a.y:
				# previous point on left and next above
				$body.set_cellv(s_c, join, true, true, true)
			elif s_b.x > s_c.x and s_c.y < s_a.y:
				# previous point on right and next below
				$body.set_cellv(s_c, join, true, true, false)
			elif s_b.x > s_c.x and s_c.y > s_a.y:
				# previous point on right and next below
				$body.set_cellv(s_c, join, false, true, true)
			elif s_b.y > s_c.y and s_c.x > s_a.x:
				# previous point below and next left
				$body.set_cellv(s_c, join, true, false, true)
			elif s_b.y > s_c.y and s_c.x < s_a.x:
				# previous point below and next right
				$body.set_cellv(s_c, join, false, false, true)
			elif s_b.y < s_c.y and s_c.x > s_a.x:
				# previous point above and next left
				$body.set_cellv(s_c, join, false, false, true)
			elif s_b.y < s_c.y and s_c.x < s_a.x:
				# previous point above and next right
				$body.set_cellv(s_c, join, true, false, false)
	# tail
	var s_tail = sections[0];
	var s_tail_1 = sections[1]
	$body.set_cellv(s_tail, tail, s_tail_1.x<s_tail.x, s_tail_1.y<s_tail.y, s_tail_1.y!=s_tail.y)
	# head
	var s_head = sections[sections.size()-1];
	var s_head_1 = sections[sections.size()-2]
	$body.set_cellv(s_head, head, s_head_1.x>s_head.x, s_head_1.y>s_head.y, s_head_1.y!=s_head.y)

func fall():
	if not on_ground():
		for s in range(0, sections.size()):
			$"body".set_cellv(sections[s], -1)
			sections[s] = sections[s] + Vector2(0, 1)
	draw()

func on_ground():
	for c in $Map.get_used_cells():
		for s in sections:
			var s_1 = s - Vector2(0, -1);
			if s_1 == c:
				return true
	return false

func can_move_to(p):
	for s in sections:
		if p == s:
			return false
	for c in $Map.get_used_cells_by_id(rock):
		if p == c:
			return false
	return true