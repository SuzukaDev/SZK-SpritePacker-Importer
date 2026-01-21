@tool
class_name  SZKSpritePackerImporter
extends Node2D

#export()
#@export var json_file:Resource
@export var json_file:JSON:
	set(value):
		json_file = value
		if sprite_sheet == null:
			var sprite_sheet_path = json_file.resource_path.get_basename()+".png"
			sprite_sheet = load(sprite_sheet_path)
			
@export var sprite_sheet:Resource:
	set(value):
		sprite_sheet = value
		if json_file == null:
			var json_path = sprite_sheet.resource_path.get_basename()+".json"
			json_file = load(json_path)

## Press to build the sceene from the a SpriteSheet + .JSON file
@export var generate : bool:
	set(value):
		#if not value:
			#return
		
		#generate = value
		
		if not value:
			return
		generate = false
		
		if json_file == null:
			#var sprite_sheet_dir = sprite_sheet.resource_path.get_base_dir()
			var json_dir = sprite_sheet.resource_path.get_basename()+".json"
			json_file = load(json_dir)
		delete_all_children()
		#create_group_nodes() # ESTO NO!!!
		create_sprites_from_spritesheet()
		center_groups()


func center_groups():
	var container_nodes = get_container_nodes("Node2D")
	container_nodes.reverse()
	for c in container_nodes:
		var childs = c.get_children()
		var median_pos = get_median_position(childs)
		c.position = median_pos
		substract_position(childs, median_pos)


func substract_position(nodes:Array[Node], pos:Vector2)->void:
	for n in nodes:
		n.position -= pos


func get_median_position(nodes:Array[Node])->Vector2:
	var pos = Vector2(0,0)
	for c in nodes:
		pos += c.position
	return pos/nodes.size()


func get_container_nodes(type:String)->Array[Node]:
	var children = find_children("", type)
	var node2D_nodes:Array[Node] = []
	for c in children:
		#print(c.name)
		#if c is Node2D:
		#if is_instance_of(c, Node2D):
		if c.get_class() == type:
			node2D_nodes.append(c)
	#for c in node2D_nodes:
		#print("------", c.name)
	return node2D_nodes
	

# REFACTOR deprecated (executing it separatedly before adding the sprites alters the order!)
func create_group_nodes()->void:
	var jdict = get_json_dict()
	for k in jdict.keys():
		var parents_array = jdict[k].parents
		var previous_parent = self
		#print(previous_parent.name)
		var parents_path = "/".join(parents_array)
		#print(parents_path)
		
		#for parent_name in parents_array:
			#print("===========")
			#print(parent_name)
			#print(previous_parent.name)
			#print(previous_parent.has_node(parent_name))
			#if not previous_parent.has_node(parent_name):
##				Create the parent
				#var node2d = Node2D.new()
				#previous_parent.add_child(node2d)
				#node2d.name = parent_name
				#if Engine.is_editor_hint():
					#node2d.owner = previous_parent
			#previous_parent = previous_parent.get_node(parent_name)
		for parent_name in parents_array:
			if previous_parent.has_node(parent_name):
				previous_parent = previous_parent.get_node(parent_name)
				continue
			print("===========")
			print("current: ", parent_name)
			print("previous parent: ", previous_parent.name)
			print("Tiene el nodo? ", previous_parent.has_node(parent_name))
			#if not previous_parent.has_node(parent_name):
#			Create the parent
			var node2d = Node2D.new()
			previous_parent.add_child(node2d)
			node2d.name = parent_name
			if Engine.is_editor_hint():
				print("previous parent (Ownder): ", previous_parent.name)
				#node2d.owner = previous_parent
				node2d.owner = get_tree().edited_scene_root
			previous_parent = previous_parent.get_node(parent_name)


func delete_all_children():
	for n in get_children():
		remove_child(n)
		n.owner = null
		n.queue_free() 



func create_sprites_from_spritesheet():
	var json_dict = get_json_dict()
	for key in json_dict.keys():
	#var keys = json_dict.keys()
	#keys.reverse()
	#for key in keys:
		#print(key)
		create_sprite(json_dict[key])


func create_parent(parents_array:Array)->Node:
	var previous_parent = self
	for parent_name in parents_array:
		if previous_parent.has_node(parent_name):
			previous_parent = previous_parent.get_node(parent_name)
			continue
		#if not previous_parent.has_node(parent_name):
		#Create the parent
		var node2d = Node2D.new()
		previous_parent.add_child(node2d)
		node2d.name = parent_name
		if Engine.is_editor_hint():
			#print("previous parent (Ownder): ", previous_parent.name)
			#node2d.owner = previous_parent
			node2d.owner = get_tree().edited_scene_root
		previous_parent = previous_parent.get_node(parent_name)
	
	return previous_parent

func create_sprite(info:Dictionary):
	var sprite = Sprite2D.new()
	sprite.texture = sprite_sheet
	sprite.name = info.name
	#sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var mid_size = Vector2(info.w, info.h)/2.0
	sprite.position = Vector2(info.layer_x+.1, info.layer_y+.1) + mid_size
	sprite.region_enabled = true
	sprite.region_rect = Rect2(info.x, info.y, info.w, info.h)
	#sprite.region = Rect2(0,0,20,20)
	#add_child(sprite)
	var parent_path = "/".join(info.parents)
	
	var parent = null
	if not has_node(parent_path):
		parent = create_parent(info.parents)
	else:
		parent = get_node(parent_path)
	
	parent.add_child(sprite)
	if Engine.is_editor_hint():
#		INFO https://docs.godotengine.org/en/stable/tutorials/plugins/running_code_in_the_editor.html#instancing-scenes
		# The line below is required to make the node visible in the Scene tree dock
		# and persist changes made by the tool script to the saved scene file.
		sprite.owner = get_tree().edited_scene_root


# REFACTOR DELETE THIS
func create_spritePREVIOUS(info:Dictionary):
	var sprite = Sprite2D.new()
	sprite.texture = sprite_sheet
	sprite.name = info.name
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	#sprite.position = Vector2(info.layer_x+.1, info.layer_y+.1)
	var mid_size = Vector2(info.w, info.h)/2.0
	sprite.position = Vector2(info.layer_x+.1, info.layer_y+.1) + mid_size
	sprite.region_enabled = true
	sprite.region_rect = Rect2(info.x, info.y, info.w, info.h)
	#sprite.region = Rect2(0,0,20,20)
	#add_child(sprite)
	var parent_path = "/".join(info.parents)
	var parent = get_node(parent_path)
	parent.add_child(sprite)
	if Engine.is_editor_hint():
#		INFO https://docs.godotengine.org/en/stable/tutorials/plugins/running_code_in_the_editor.html#instancing-scenes
		# The line below is required to make the node visible in the Scene tree dock
		# and persist changes made by the tool script to the saved scene file.
		sprite.owner = get_tree().edited_scene_root
	


func get_json_dict()->Dictionary:
	var file_path = json_file.resource_path
	var json_as_text = FileAccess.get_file_as_string(file_path)
	#print(json_as_text)
	var json_as_dict:Dictionary = JSON.parse_string(json_as_text)
	#for key in json_as_dict.keys():
		#print(key)
	return json_as_dict
	
	
