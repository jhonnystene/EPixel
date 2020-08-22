extends Node

# Inputs: width - Image width, height - Image height
func createEmptyImage(width, height):
	var image = []
	for y in range(0, height):
		var yData = []
		for x in range(0, width):
			yData.append(Color(0, 0, 0, 0))
		image.append(yData)
	return image

# Inputs: Image
# Outputs: Image in EPX format
func imageToEPX(image):
	var imageExport = ""
	for y in range(0,len(image)):
		for x in range(0,len(image[y])):
			imageExport += str(image[y][x])
			imageExport += "+"
		imageExport += "-"
	return imageExport

# Inputs: Image in EPX format
# Outputs: Image
func EPXToImage(epx):
	var yLines = epx.split("-")
	var height = len(yLines)
	var width = len(yLines[0].split("+"))
	var image = createEmptyImage(width, height)
	for lineNumber in range(0,len(yLines)):
		var colors = yLines[lineNumber].split("+")
		for x in range(0,len(colors) - 1):
			var color = colors[x].split(",")
			image[lineNumber][x] = Color(color[0], color[1], color[2], color[3])
	return image
