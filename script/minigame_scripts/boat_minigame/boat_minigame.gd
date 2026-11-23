extends CanvasLayer

signal puzzle_solved

@export var grid: GridContainer # Drag your GridContainer node here in the Inspector

func _ready() -> void:
	grid.puzzle_solved.connect(func() -> void: puzzle_solved.emit())
