extends Node2D

enum RailType { END=1, CORNER=2, BAR=3 }

@onready var tilemap:TileMap = $TileMap

const SAW_TILE_LAYER:int = 1
const TILE_WIDTH:int = 32
const TILE_HEIGHT:int = 32

func _ready():
	create_saw_paths()


func create_saw_paths():
	var saw_layer = tilemap.get_used_cells(SAW_TILE_LAYER)
	var used_ends = []
	var curve:Line2D = Line2D.new()
	
	for tile in saw_layer:
		var tile_data = tilemap.get_cell_tile_data(SAW_TILE_LAYER, tile)
		var rail_type = tile_data.get_custom_data("rail_type")
		
		if rail_type == RailType.END:
			if used_ends.has(tile) == false:
				# new end so create the starting point in the path
				var rail_position:Vector2
				# we add 1 to tile x/y as the rail is in the middle of our larger 64x64 tile
				rail_position.x = (tile.x + 1) * TILE_WIDTH
				rail_position.y = (tile.y + 1) * TILE_HEIGHT
				print(curve)
				curve.add_point(rail_position)
				
				# get direction of end, if there is more than 1 direction then we have a problem!
				var rail_directions = tile_data.get_custom_data("rail_directions")
				if rail_directions.size() > 1:
					print("Error with tile data.")
					return
				
				
				# save the previous tile as we need to test we aren't going back to it
				var previous_tile = tile
				var current_tile = tile + rail_directions[0]
				
				var rail_complete:bool = false
				
				while rail_complete == false:
					print(current_tile)
					tile_data = tilemap.get_cell_tile_data(SAW_TILE_LAYER, current_tile)
					rail_type = tile_data.get_custom_data("rail_type")
				
					if rail_type != RailType.BAR:
						# this is either an end or a corner so add a new point
						rail_position.x = (current_tile.x + 1) * TILE_WIDTH
						rail_position.y = (current_tile.y + 1) * TILE_HEIGHT
						curve.add_point(rail_position)
					
						if rail_type == RailType.END:
							# end of rail so stop loop
							used_ends.append(current_tile)
							rail_complete = true
							break
					
					rail_directions = tile_data.get_custom_data("rail_directions")
					
					# loop through the directions to find the one that doesn't take us to the previous tile
					for direction in rail_directions:
						if (current_tile + direction) != previous_tile:
							# set the previous and current tiles and break to go back to start of loop
							previous_tile = current_tile
							current_tile = current_tile + direction
							break
	
	print(curve.get_point_count())
	print(curve.points)
	add_child(curve)
