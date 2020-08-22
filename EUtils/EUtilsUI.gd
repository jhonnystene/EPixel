extends Node

# Inputs: node - Control based node
# Outputs: true - if cursor is within node, false otherwise
func isCursorTouchingUINode(node):
	var mousePos = get_viewport().get_mouse_position()
	if(mousePos.x > node.rect_position.x && mousePos.x < node.rect_position.x + node.rect_size.x):
		if(mousePos.y > node.rect_position.y && mousePos.y < node.rect_position.y + node.rect_size.y):
			return true
	return false

# Inputs: node - Control based node, tileDimensions - Vector2D of the size of each tile	
# Outputs: Vector2 of tile numbers, -1, -1 if mouse outside
func cursorTile(node, tileDimensions):
	if(isCursorTouchingUINode(node)):
		var relativePos = get_viewport().get_mouse_position() - node.rect_position
		var tile = Vector2(0, 0)
		tile.x = floor(relativePos.x / tileDimensions.x)
		tile.y = floor(relativePos.y / tileDimensions.y)
		return tile
	else:
		return Vector2(-1, -1)
