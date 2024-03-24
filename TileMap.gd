extends TileMap
var moisture = FastNoiseLite.new()
var temperature = FastNoiseLite.new()
var altitude = FastNoiseLite.new()
var width = 96
var height = 96
var processed_cells = {}

func _ready():
	moisture.seed = randi()
	temperature.seed = randi()
	altitude.seed = randi()
	moisture.set_noise_type(FastNoiseLite.TYPE_PERLIN)
	temperature.set_noise_type(FastNoiseLite.TYPE_PERLIN)
	altitude.set_noise_type(FastNoiseLite.TYPE_PERLIN)


func _process(_delta):
	var pos = get_parent().getPlayerPos()
	var tile_pos = local_to_map(pos)
	for x in range(width):
		for y in range(height):
			var lx = tile_pos.x - width / 2 + x
			var ly = tile_pos.y - height / 2 + y
			var cell_key = Vector2(lx, ly)
			var moist = moisture.get_noise_2d(lx,ly)
			if cell_key in processed_cells:
				continue
			var temp = temperature.get_noise_2d(lx,ly)
			var alt = altitude.get_noise_2d(lx,ly)
			var atlasx = abs(int(round(moist * 10 + 5))) % 6
			var atlasy = 7- (abs(int(round(temp * 10 + 5))) % 8)
			if (int(round(alt * 10 + 5))% 8 < 4):
				set_cell(0,Vector2i(lx, ly),0,Vector2i(7,atlasy))
			else :
				set_cell(0,Vector2i(lx, ly),0,Vector2i(atlasx,atlasy))
			processed_cells[cell_key] = true
