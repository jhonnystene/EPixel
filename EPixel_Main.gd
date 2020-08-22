extends Control

var image

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

const COLORS = [Color.blue, Color.red, Color.black, Color.magenta, Color.green, Color.orange, Color.brown, Color.navyblue, Color.lightblue, Color.yellow, Color.white, Color.lightgray, Color.gray, Color.darkgray]
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
		node.color = image[node.rect_position.y / 16][node.rect_position.x / 16]

func _process(delta):
	if(Input.is_action_pressed("LeftClick")):
		var mousePos = get_viewport().get_mouse_position()
		
		# Are we in the color picker range?
		if(mousePos.x > $ColorPicker.rect_position.x && mousePos.x < $ColorPicker.rect_position.x + $ColorPicker.rect_size.x):
			if(mousePos.y > $ColorPicker.rect_position.y && mousePos.y < $ColorPicker.rect_position.y + $ColorPicker.rect_size.y):
				# Get mouse position relative to color picker
				var mousePosRelative = mousePos - $ColorPicker.rect_position
				
				# Figure out which square the user clicked on
				var mousePosSquare = Vector2(0, 0)
				mousePosSquare.x = floor(mousePosRelative.x / 16)
				mousePosSquare.y = floor(mousePosRelative.y / 16)
				
				# Figure out which color that is
				var colorId = mousePosSquare.x
				if(mousePosSquare.y == 1): # We're on the second layer.
					colorId += 8
				
				if(colorId > len(COLORS) - 1):
					print("Error: Color out of bounds!")
				else:
					currentColor = COLORS[colorId]
					
		# Are we in the image range?
		if(mousePos.x > $ImageEditor.rect_position.x && mousePos.x < $ImageEditor.rect_position.x + $ImageEditor.rect_size.x):
			if(mousePos.y > $ImageEditor.rect_position.y && mousePos.y < $ImageEditor.rect_position.y + $ImageEditor.rect_size.y):
				# Get mouse position relative to image
				var mousePosRelative = mousePos - $ImageEditor.rect_position
				
				# Figure out which square the user clicked on
				var mousePosSquare = Vector2(0, 0)
				mousePosSquare.x = floor(mousePosRelative.x / 16)
				mousePosSquare.y = floor(mousePosRelative.y / 16)
				
				# Figure out which color that is
				image[mousePosSquare.y][mousePosSquare.x] = currentColor
				
				#print("Clicked tile at " + str(mousePosSquare))
				updateImage()

func createImageExport():
	print("Preparing image for export...")
	var imageExport = ""
	for y in range(0,len(image)):
		for x in range(0,len(image[y])):
			imageExport += str(image[y][x])
			imageExport += "+"
		imageExport += "-"
	print("Image prepared.")
	return imageExport

func importImage(imgText):
	print("Parsing image file...")
	var yLines = imgText.split("-")
	print(str(len(yLines)) + " lines")
	print(str(len(yLines[0].split("+"))) + " colors per line")
	for lineNumber in range(0,len(yLines)):
		var colors = yLines[lineNumber].split("+")
		for x in range(0,len(colors) - 1):
			var color = colors[x].split(",")
			image[lineNumber][x] = Color(color[0], color[1], color[2], color[3])
	print("Done. Updating image...")
	updateImage()

func _ready():
	# Create a new image
	newImage()
	
	# Set file dialog permissions
	$SaveLoadMenu/FileDialog.access = FileDialog.ACCESS_FILESYSTEM
	$SaveLoadMenu/FileDialog.set_filters(PoolStringArray(["*.epx ; EPixel Image Files"]))
	
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
	print("Showing save box...")
	$SaveLoadMenu/FileDialog.mode = FileDialog.MODE_SAVE_FILE
	$SaveLoadMenu/FileDialog.popup()

func _on_FileDialog_file_selected(path):
	print("File selected.")
	if($SaveLoadMenu/FileDialog.mode == FileDialog.MODE_SAVE_FILE):
		print("Saving...")
		var save_file = File.new()
		save_file.open(path, File.WRITE)
		save_file.store_line(createImageExport())
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
		importImage(fileContents)
