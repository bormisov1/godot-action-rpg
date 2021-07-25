tool
extends TileMap
var offset = Vector2(0, -192)
func _ready():
	for tile in tile_set.get_tiles_ids().size():
		tile_set.tile_set_texture_offset(tile, offset)
		
