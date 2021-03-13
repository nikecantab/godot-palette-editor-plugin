tool
extends VBoxContainer

var palette_name := "Test Palette" setget set_palette_name, get_palette_name
var palette : Palette setget set_palette, get_palette#resource
var picker_list = []
var new_color : Color
#export(PoolColorArray) var palette

const picker_button = preload("res://addons/global_palette_manager/ColorButton.tscn")
#const index_label = preload("res://addons/global_palette_manager/ColorIndexLabel.tscn")

onready var line_edit = $LineEdit
onready var add_button = $AddButton

signal color_to_history(color)

func _ready() -> void:
	line_edit.connect("text_entered", self, "_on_LineEdit_text_entered")
	add_button.connect("pressed", self, "_on_AddButton_pressed")
	
	set_palette_name(palette_name)
	init_pickers()

func init_pickers() -> void:
	#palette has to be updated already
	if !palette:
		return
	
	#clear list
	picker_list = []
	
	#delete all pickers
	
	var kill_them_kids = []
	var count = 0
	for c in get_children():
		if c.is_in_group("ColorPicker"):
			kill_them_kids.append(c)
			count += 1
#	
	for c in count:
		kill_them_kids[c].queue_free()
		
	var pal = palette.palette
	for c in pal.size():
		add_picker(c)
		
	add_button.raise()

func add_picker(index : int):
	var button = picker_button.instance()
	var picker = button.get_node("ColorPickerButton")
	var label = button.get_node("ColorIndexLabel")
	var col = palette.palette
	picker.color = col[index]
	picker.edit_alpha = false
	
	picker.connect("popup_closed", self, "_on_picker_done")
	button.connect("remove_pressed", self, "_on_RemoveButton_pressed")
	
#	print(picker_list.size())
	var new_list = []
	for p in picker_list:
		new_list.append(p)
	new_list.append(picker)
	picker_list = new_list
#	print("new picker size: ", picker_list.size())
	label.text = String(index)
	add_child(button)
	
	add_button.raise()

func set_palette(_palette: Palette):
	palette = _palette
	get_palette_name()
	set_palette_name(palette_name)
	pass
	
func get_palette() -> Palette:
	return palette

func set_palette_name(value) -> void:
	palette_name = value
	line_edit.text = value
	if palette:
		palette.name = value

func get_palette_name() -> String:
	if palette:
		palette_name = palette.name
	return palette_name

func update_color_in_file(index : int, color : Color) -> void:
	if !palette:
		return
	if index<palette.palette.size():
		if palette.palette[index] != color:
			palette.palette[index] = color

func add_color():
	var new_palette = []
	for c in palette.palette:
		new_palette.append(c)
	new_palette.append(Color.black)
	palette.palette = new_palette
	add_picker(new_palette.size() - 1)
	
func remove_color(index):
	var new_palette = []
	var i = 0
	for c in palette.palette:
		if i != index:
			new_palette.append(c)
		i += 1
	palette.palette = new_palette
	#re-init pickers
	init_pickers()
	
func _on_picker_done():
	var i := 0
	for p in picker_list:
		var old_color
		if palette:
			old_color = palette.palette[i]
		update_color_in_file(i, p.color)
		if palette:
			if old_color != palette.palette[i]:
				emit_signal("color_to_history", old_color)
		i += 1
		
func _on_AddButton_pressed():
	add_color()
#	print("pressed")

func _on_RemoveButton_pressed(index):
	remove_color(index)

func _on_LineEdit_text_entered(new_text):
	print("text entered: ", new_text)
	set_palette_name(new_text)
