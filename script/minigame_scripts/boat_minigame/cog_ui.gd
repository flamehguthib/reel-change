class_name CogUI
extends TextureRect

enum Type { NORMAL, START, TARGET, BLOCKED }

# Change these to match your spritesheet's column and row count
const HFRAMES: int = 4
const VFRAMES: int = 1

var piece_type: Type = Type.NORMAL
var is_locked: bool = false
var spin_dir: int = 0       # 1 = Clockwise, -1 = Counter-Clockwise, 0 = Stopped
var required_dir: int = 1   # Target spin direction (1 = CW, -1 = CCW)
var spin_speed: float = 2.0 # Radians per second

func setup(cell: Vector2i, cell_size: Vector2, tex: Texture2D, type: Type, locked: bool, req_dir: int = 1) -> void:
	piece_type = type
	is_locked = locked
	required_dir = req_dir

	# Pick which frame index (0-based) to slice from the spritesheet
	var frame_index: int = 0
	match piece_type:
		Type.NORMAL:
			frame_index = 0
		Type.START:
			frame_index = 1
		Type.TARGET:
			frame_index = 2
		Type.BLOCKED:
			frame_index = 3

	texture = slice_frame(tex, frame_index)

	# Keep sprite crisp and centered inside the slot
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED

	# Scale down to 75% of the cell and center it so adjacent cogs do not touch
	var cog_size: Vector2 = cell_size * 0.75
	size = cog_size
	position = (cell_size - cog_size) * 0.5
	pivot_offset = cog_size * 0.5

	mouse_filter = Control.MOUSE_FILTER_IGNORE

func slice_frame(tex: Texture2D, frame_index: int) -> AtlasTexture:
	var safe_index: int = clampi(frame_index, 0, (HFRAMES * VFRAMES) - 1)
	var frame_w: float = tex.get_width() / float(HFRAMES)
	var frame_h: float = tex.get_height() / float(VFRAMES)
	var col: int = safe_index % HFRAMES
	var row: int = safe_index / HFRAMES

	var atlas := AtlasTexture.new()
	atlas.atlas = tex
	atlas.region = Rect2(col * frame_w, row * frame_h, frame_w, frame_h)
	return atlas

func _process(delta: float) -> void:
	if spin_dir != 0 and piece_type != Type.BLOCKED:
		rotation += spin_speed * spin_dir * delta
