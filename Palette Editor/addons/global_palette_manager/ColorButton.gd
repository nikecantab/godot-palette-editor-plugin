tool
extends HBoxContainer

onready var label = $ColorIndexLabel
onready var button = $TextureButton

func _ready():
	button.connect("pressed", self, "_on_TextureButton_pressed")

signal remove_pressed(index)

func _on_TextureButton_pressed():
	emit_signal("remove_pressed", int(label.text))
#	print("picker says: pressed")
