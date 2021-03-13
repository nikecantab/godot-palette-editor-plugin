tool
extends EditorPlugin


const INTERFACE_SCN = preload("menu.tscn")

var editor_interface := get_editor_interface()
var editor_base_control := editor_interface.get_base_control()
var editor_viewport := editor_interface.get_editor_viewport()

var interface : Control

#Plugin req
func _enter_tree():
	interface = INTERFACE_SCN.instance()
	
#	interface.connect("ready", self, "_on_ready")
	#Plugin req 
	editor_viewport.add_child(interface)
	make_visible(false)
	
#	var testing = test.instance()
#	interface.add_child(test)
#	test.set_owner()

#Plugin req
func _exit_tree():
	if interface:
		interface.queue_free()

#Main screen req
func has_main_screen():
	return true

#Main screen req
func make_visible(visible):
	if interface:
		interface.visible = visible
	
#Main screen req
func get_plugin_name():
	return "Palette Manager"
	
#Main screen req
func get_plugin_icon():
	return editor_base_control.get_icon("ColorPick", "EditorIcons")

#func _on_ready():
#	pass

#NOTES
#CustomControlContainer values:
#	CONTAINER_TOOLBAR - right of where the Play, etc. buttons are
#	CONTAINER_CANVAS_EDITOR_MENU - the bar on top of the 2d editor
#	CONTAINER_PROPERTY_EDITOR_BOTTOM - below the inspector
#	CONTAINER_PROJECT_SETTING_TAB_LEFT - a tab in project>project setting
