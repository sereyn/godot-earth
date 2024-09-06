extends Node2D

var filepath := "res://ne_110m_admin_0_countries.json"
var radius := 100.0
var center := Vector2.ZERO

var min_x := INF
var min_y := INF
var max_x := -INF
var max_y := -INF

func fetch_countries_polygons() -> Array:
	var json_as_text := FileAccess.get_file_as_string(filepath)
	var json_as_dict := JSON.parse_string(json_as_text) as Dictionary
	var features := json_as_dict["features"] as Array
	return features.map(func (f): return f["geometry"]["coordinates"])

func add_polys(countries_polygons: Array):
	for country_polygons in countries_polygons:
		for polys in country_polygons:
			for poly in polys:
				var points := PackedVector2Array()
				for geo_coords in poly:
					if geo_coords is Array: # TODO: Add support for multi-polygons
						var lon = deg_to_rad(geo_coords[0])
						var lat = deg_to_rad(geo_coords[1])
						var x = radius * cos(center.x) * (lon - center.y)
						var y = radius * (lat - center.x)
						update_bounding_box(x, y)
						points.push_back(Vector2(x, -y))
				add_country_poly(points)
	fit_to_viewport()

func update_bounding_box(x: float, y: float):
	min_x = min(min_x, x)
	min_y = min(min_y, y)
	max_x = max(max_x, x)
	max_y = max(max_y, y)

func add_country_poly(points: PackedVector2Array):
	var p := Polygon2D.new()
	p.color = Color(randf(), randf(), randf())
	p.polygon = points
	add_child(p)

func fit_to_viewport():
	var viewport_size = Vector2(get_viewport().size)
	var rect := Rect2(min_x, min_y, max_x - min_x, max_y - min_y)
	var scale_factor = min(viewport_size.x / rect.size.x, viewport_size.y / rect.size.y)
	var scaled_rect_size = rect.size * scale_factor
	var offset = (viewport_size - scaled_rect_size) / 2 - (rect.position * scale_factor)
	scale = Vector2(scale_factor, scale_factor)
	position += offset

func _ready():
	add_polys(fetch_countries_polygons())
