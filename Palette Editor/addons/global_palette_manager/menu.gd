tool
extends Control

###NOTE!!!###
#get_filelist scans the whole directory, it is highly recommended you set a folder to load your palettes from on startup

###SETTINGS###
const MAX_HISTORY_SIZE = 15
const LOAD_PALETTES_ON_STARTUP = true

###CODE###
onready var body : VBoxContainer = $Panel/Margin/Body
onready var toolbar : HBoxContainer = body.get_node("Toolbar")
onready var loadButton : Button = toolbar.get_node("LoadButton")
onready var newButton : Button = toolbar.get_node("NewButton")
onready var paletteContainer : HBoxContainer = body.get_node("ScrollContainer/PalettesContainer")
#onready var testPaletteList := paletteContainer.get_node("PaletteList")

onready var creationDialog : WindowDialog = $CreatePaletteDialog
onready var createButton : Button = creationDialog.get_node("MarginContainer/Body/Button")
onready var spinBox : Range = creationDialog.get_node("MarginContainer/Body/HBoxContainer/ColorAmount")
onready var nameField : LineEdit = creationDialog.get_node("MarginContainer/Body/LineEdit")
onready var loadingDialog : WindowDialog = $LoadPaletteDialog
onready var historyBar : HBoxContainer = body.get_node("HistoryContainer/History")
onready var scanPath = body.get_node("Path")

const paletteList = preload("PaletteList.tscn")

var DIR

func _ready():
	loadButton.connect("pressed", self, "_on_LoadButton_pressed")
	newButton.connect("pressed", self, "_on_NewButton_pressed")
	loadingDialog.connect("file_selected",self,"_on_LoadingPaletteDialog_file_selected")
	createButton.connect("pressed", self, "_on_CreateButton_pressed")
	nameField.connect("text_changed", self, "_on_NameField_text_changed")
#	scanPath.connect("")
	creationDialog.set_as_toplevel(true)
	loadingDialog.set_as_toplevel(true)
	
	DIR = scanPath.text
	
	#load all
	if LOAD_PALETTES_ON_STARTUP:
		scan_for_palettes(scanPath.text)

	
func create_list_from_resource(res : Palette) -> VBoxContainer:
	var new_list = paletteList.instance()
	paletteContainer.add_child(new_list)
	new_list.set_palette(res)
	new_list.init_pickers()
	new_list.connect("color_to_history", self, "_on_color_to_history")
	return new_list
	
func create_new_palette_resource(_name : String, _amount, _path : String) -> Palette:
	var new_resource = Palette.new()
	
	new_resource.name = _name
	
	var new_palette : PoolColorArray = []
	var ii = int(_amount)
	for i in ii:
		new_palette.append(Color.black)
		
	new_resource.palette = new_palette
	
	#save file
	#remove spaces from resource name?
	var _filename = _path + "/" + _name + ".tres"
	print(_filename)
	ResourceSaver.save(_filename, new_resource)
	return new_resource
	
func scan_for_palettes(_path : String):
	var files = []
	files = get_filelist(_path)
	for f in files:
		var ext = f.get_extension()
		if ext == "tres":
			_on_LoadingPaletteDialog_file_selected(f)

func _on_LoadButton_pressed():
	loadingDialog.invalidate()
	loadingDialog.popup_centered()

func _on_NewButton_pressed():
	creationDialog.popup_centered()
	nameField.clear()

func _on_CreateButton_pressed():
	if !nameField.text.is_valid_filename():
		#remove invalid characters
		return
	createButton.disabled = true
#	print("spinbox is: ")
#	print( spinBox.get_value())
	var new_palette = create_new_palette_resource(nameField.text, spinBox.get_value(), DIR)
	create_list_from_resource(new_palette)
	
	pass

func _on_LoadingPaletteDialog_file_selected(path: String) -> void:
	#get file
	var file = load(path)
	#verify file type
	if file is Palette:
		print("valid")
		#load 
		create_list_from_resource(file)
		
	else:
		print("invalid type")

func _on_NameField_text_changed(new_text):
	#validate
	if new_text != "":
		createButton.disabled = false
	else:
		createButton.disabled = true

func _on_color_to_history(color):
	var col_rect = ColorRect.new()
	historyBar.add_child(col_rect)
	col_rect.rect_min_size = Vector2(30,30)
	col_rect.color = color
	if historyBar.get_child_count() > MAX_HISTORY_SIZE:
		historyBar.get_child(0).queue_free()
	
	
	
	###Utils###
func get_filelist(scan_dir : String) -> Array:
	var my_files : Array = []
	var dir := Directory.new()
	if dir.open(scan_dir) != OK:
		printerr("Warning: could not open directory: ", scan_dir)
		return []

	if dir.list_dir_begin(true, true) != OK:
		printerr("Warning: could not list contents of: ", scan_dir)
		return []

	var file_name := dir.get_next()
	while file_name != "":
		if dir.current_is_dir():
			my_files += get_filelist(dir.get_current_dir() + "/" + file_name)
		else:
			my_files.append(dir.get_current_dir() + "/" + file_name)

		file_name = dir.get_next()

	return my_files
