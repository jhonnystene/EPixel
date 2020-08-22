extends Control

var image
var filePath = ""

const IMAGE_DIMENSIONS = 32
const COLOR_BLUE = Color(0, 0, 204, 255)
const COLOR_RED = Color(255, 0, 0, 255)
const COLOR_BLACK = Color(0, 0, 0, 255)
const COLOR_MAGENTA = Color(255, 51, 204, 255)
const COLOR_GREEN = Color(0, 51, 0, 255)
const COLOR_ORANGE = Color(255, 102, 0, 255)
const COLOR_BROWN = Color(102, 51, 0, 255)
const COLOR_NAVY = Color(0, 0, 102, 255)
const COLOR_LTBLUE = Color(51, 153, 255, 255)
const COLOR_YELLOW = Color(255, 255, 0, 255)
const COLOR_WHITE = Color(255, 255, 255, 255)
const COLOR_LTGRAY = Color(190, 190, 190, 255)
const COLOR_MEDGRAY = Color(154, 154, 154, 255)
const COLOR_GRAY = Color(121, 121, 121, 255)
const COLOR_DARKGRAY = Color(78, 78, 78, 255)
const COLOR_VERYDARKGRAY = Color(24, 24, 24, 255)

const COLORS_TI84CE = [Color.blue, Color.red, Color.black, Color.magenta, Color.green, Color.orange, Color.brown, Color.navyblue, Color.lightblue, Color.yellow, Color.white, Color.lightgray, Color.gray, Color.darkgray]
const COLORS_WIN16 = [Color.black, Color.darkred, Color.darkgreen, Color.olive, Color.navyblue, Color.purple, Color.teal, Color.silver, Color.gray, Color.red, Color.lime, Color.yellow, Color.blue, Color.fuchsia, Color.aqua, Color.white]
var COLORS = COLORS_WIN16
var currentColor = Color.blue
var pixel = preload("res://Pixel.tscn")

func initImage():
	image = [] # Empty image variable
	for y in range(0, IMAGE_DIMENSIONS): # Loop through all y positions
		var yArray = [] # Create an empty array
		for x in range(0, IMAGE_DIMENSIONS): # Loop through all x positions
			yArray.append(Color(0, 0, 0)) # Add an empty color
		image.append(yArray) # Add line to image

func clearImage():
	for child in $ImageEditor.get_children():
		child.queue_free()

func newImage():
	initImage()
	createImage()
	filePath = ""

func createImage():
	clearImage()
	var xpos = 0
	var ypos = 0
	for y in range(0, len(image)):
		xpos = 0
		for x in range(0,len(image)):
			var instance = pixel.instance()
			instance.rect_position = Vector2(xpos * 16, ypos * 16)
			instance.color = image[y][x]
			#instance.name = x + (IMAGE_DIMENSIONS * y)
			$ImageEditor.add_child(instance)
			xpos += 1
		ypos += 1
		
func updateImage():
	for node in $ImageEditor.get_children():
		node.color = image[floor(node.rect_position.y / 16)][floor(node.rect_position.x / 16)]

func updatePixel(x, y):
	for node in $ImageEditor.get_children():
		if(floor(node.rect_position.x / 16) == x && floor(node.rect_position.y / 16) == y):
			node.color = image[floor(node.rect_position.y / 16)][floor(node.rect_position.x / 16)]

func _process(delta):
	if(Input.is_action_pressed("LeftClick")):
		if(EUtilsUI.isCursorTouchingUINode($ColorPicker)):
			var colorPickerTile = EUtilsUI.cursorTile($ColorPicker, Vector2(16, 16))
			if(colorPickerTile.y == 1):
				colorPickerTile.x += 8
			if(colorPickerTile.x > len(COLORS) - 1):
				print("Error: Color out of bounds!")
			else:
				currentColor = COLORS[colorPickerTile.x]
		elif(EUtilsUI.isCursorTouchingUINode($ImageEditor)):
			var pixel = EUtilsUI.cursorTile($ImageEditor, Vector2(16, 16))
			image[pixel.y][pixel.x] = currentColor
			updatePixel(pixel.x, pixel.y)

func _ready():
	# Create a new image
	newImage()
	
	# Set file dialog permissions
	$SaveLoadMenu/FileDialog.access = FileDialog.ACCESS_FILESYSTEM
	$SaveLoadMenu/FileDialog.set_filters(PoolStringArray(["*.epx ; EPixel Image Files"]))
	
	refreshColorPicker()
	
func refreshColorPicker():
	for child in $ColorPicker.get_children():
		child.queue_free()
		
	# Populate color picker
	var colorPickerColor = load("res://ColorPickerColor.tscn")
	var x = 0
	var y = 0
	for c in COLORS:
		var colorInstance = colorPickerColor.instance()
		colorInstance.color = c
		colorInstance.rect_position = Vector2(x * 16, y * 16)
		$ColorPicker.add_child(colorInstance)
		x += 1
		if(x == 8):
			x = 0
			y += 1

func _on_OpenButton_pressed():
	print("Showing load box...")
	$SaveLoadMenu/FileDialog.mode = FileDialog.MODE_OPEN_FILE
	$SaveLoadMenu/FileDialog.popup()

func _on_SaveButton_pressed():
	if(filePath == ""):
		print("Showing save box...")
		$SaveLoadMenu/FileDialog.mode = FileDialog.MODE_SAVE_FILE
		$SaveLoadMenu/FileDialog.popup()
	else:
		$SaveLoadMenu/FileDialog.mode = FileDialog.MODE_SAVE_FILE
		_on_FileDialog_file_selected(filePath)
	
func _on_SaveAsButton_pressed():
	print("Showing save box...")
	$SaveLoadMenu/FileDialog.mode = FileDialog.MODE_SAVE_FILE
	$SaveLoadMenu/FileDialog.popup()

func _on_FileDialog_file_selected(path):
	print("File selected.")
	if($SaveLoadMenu/FileDialog.mode == FileDialog.MODE_SAVE_FILE):
		print("Saving...")
		var save_file = File.new()
		save_file.open(path, File.WRITE)
		save_file.store_line(EUtilsImage.imageToEPX(image))
		save_file.close()
	else:
		print("Loading...")
		var open_file = File.new()
		if not open_file.file_exists(path):
			print("Error! File doesn't exist.")
			return
		open_file.open(path, File.READ)
		var fileContents = ""
		while(open_file.get_position() < open_file.get_len()):
			fileContents += open_file.get_line()
		open_file.close()
		image = EUtilsImage.EPXToImage(fileContents)
		updateImage()
	filePath = path


func _on_TIPaletteButton_pressed():
	COLORS = COLORS_TI84CE
	refreshColorPicker()

func _on_Win16PaletteButton_pressed():
	COLORS = COLORS_WIN16
	refreshColorPicker()
