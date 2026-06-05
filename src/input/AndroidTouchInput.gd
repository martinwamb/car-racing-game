```gdscript
# 
extends Node

func _ready():
    input_map["ui_left"] = InputEventScreenEdgeSwiped.LEFT
    input_map["ui_right"] = InputEventScreenEdgeSwiped.RIGHT
    input_map["ui_up"] = InputEventScreenEdgeSwiped.TOP
    input_map["ui_down"] = InputEventScreenEdgeSwiped.BOTTOM

func _input(event):
    if event is InputEventScreenEdgeSwiped:
        match event.get_edge():
            SCREEN_EDGE_LEFT: # Left swipe to go left
                if get_node("Car"): # Assuming the car movement node exists
                    get_node("Car").go_left()
            SCREEN_EDGE_RIGHT: # Right swipe to go right
                if get_node("Car"): 
                    get_node("Car").go_right()

# File: src/input/BackButtonInput.gd

extends Node

func _ready():
    Input.map_action("back", "ui_back")

func _unhandled_input(event):
    if event is InputEventAction and event.action == "ui_back":
        if Application.is_running():
            quit()
```

FILE: src/input/AndroidTouchInput.gd