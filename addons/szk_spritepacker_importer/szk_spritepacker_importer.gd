@tool
extends EditorPlugin


func _enable_plugin():
	# Add autoloads here.
	pass


func _disable_plugin():
	# Remove autoloads here.
	pass


func _enter_tree():
	# Initialization of the plugin goes here.
	add_custom_type("SZKSpritePackerImporter", "Node2D", preload("szk_spritepacker_importer_class.gd"), preload("icon.png"))


func _exit_tree():
	# Clean-up of the plugin goes here.
	remove_custom_type("SZKSpritePackerImporter")
