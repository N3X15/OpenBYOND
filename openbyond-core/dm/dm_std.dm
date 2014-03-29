// From byondcore.dll
// Hopefully this won't get me sued, since it's been posted on the Byond forums before.
// (Used for compatibility)

// animation easing
#define LINEAR_EASING 0
#define SINE_EASING 1
#define CIRCULAR_EASING 2
#define CUBIC_EASING 3
#define BOUNCE_EASING 4
#define ELASTIC_EASING 5
#define BACK_EASING 6
#define EASE_IN 64
#define EASE_OUT 128
// blend_mode
var/const
	BLEND_DEFAULT = 0
	BLEND_OVERLAY = 1
	BLEND_ADD = 2
	BLEND_SUBTRACT = 3
	BLEND_MULTIPLY = 4
// matrix
#define MATRIX_COPY 0
#define MATRIX_MULTIPLY 1
#define MATRIX_ADD 2
#define MATRIX_SUBTRACT 3
#define MATRIX_INVERT 4
#define MATRIX_ROTATE 5
#define MATRIX_SCALE 6
#define MATRIX_TRANSLATE 7
#define MATRIX_INTERPOLATE 8
#define MATRIX_MODIFY 128
matrix
	var/a=1
	var/b=0
	var/c=0
	var/d=0
	var/e=1
	var/f=0
	_dm_interface = _DM_datum|_DM_Matrix
	New(m)
		if(args.len == 6)
			a = m; b = args[2]; c = args[3]; src.d = args[4]; src.e = args[5]; src.f = args[6]
		else if(m) matrix(src,m,MATRIX_COPY|MATRIX_MODIFY)
	proc
		Multiply(m) return matrix(src,m,MATRIX_MULTIPLY|MATRIX_MODIFY)
		Add(m) return matrix(src,m,MATRIX_ADD|MATRIX_MODIFY)
		Subtract(m) return matrix(src,m,MATRIX_SUBTRACT|MATRIX_MODIFY)
		Invert() return matrix(src,MATRIX_INVERT|MATRIX_MODIFY)
		Turn(a) return matrix(src,a,MATRIX_ROTATE|MATRIX_MODIFY)
		Scale(x,y)
			if(isnull(y)) y = x
			return matrix(src,x,y,MATRIX_SCALE|MATRIX_MODIFY)
		Translate(x,y)
			if(isnull(y)) y = x
			return matrix(src,x,y,MATRIX_TRANSLATE|MATRIX_MODIFY)
		Interpolate(m2,t)
			return matrix(src,m2,t,MATRIX_INTERPOLATE)
// icons
#define ICON_ADD 0
#define ICON_SUBTRACT 1
#define ICON_MULTIPLY 2
#define ICON_OVERLAY 3
#define ICON_AND 4
#define ICON_OR 5
#define ICON_UNDERLAY 6
icon
	_dm_interface = _DM_datum|_DM_Icon|_DM_RscFile
	var/icon
	New(icon,icon_state,dir,frame,moving)
		src.icon = _dm_new_icon(icon,icon_state,dir,frame,moving)
	proc
		Icon()
			return icon
		RscFile()
			return fcopy_rsc(icon)
		IconStates(mode=0)
			return icon_states(icon,mode)
		Turn(angle,antialias)
			if(antialias) _dm_turn_icon(icon,angle,1)
			else _dm_turn_icon(icon,angle)
		Flip(dir)
			_dm_flip_icon(icon,dir)
		Shift(dir,offset,wrap)
			_dm_shift_icon(icon,dir,offset,wrap)
		SetIntensity(r,g=-1,b=-1)
			_dm_icon_intensity(icon,r,g,b)
		Blend(icon,f,x=1,y=1)
			_dm_icon_blend(src.icon,icon,f,x,y)
		SwapColor(o,n)
			_dm_icon_swap_color(icon,o,n)
		DrawBox(c,x1,y1,x2,y2)
			_dm_icon_draw_box(icon,c,x1,y1,x2,y2)
		Insert(new_icon,icon_state,dir,frame,moving,delay)
			_dm_icon_insert(icon,new_icon,icon_state,dir,frame,moving,delay)
		MapColors(a,b,c,d,e,f,g,h,i,j=0,k=0,l=0)
			if(istext(a))
				if(!e) _dm_icon_map_colors(icon,a,b,c,d)
				else _dm_icon_map_colors(icon,a,b,c,d,e)
			else if(args.len <= 12) _dm_icon_map_colors(icon,a,b,c,d,e,f,g,h,i,j,k,l)
			else _dm_icon_map_colors(icon,a,b,c,d,e,f,g,h,i,j,k,l,args[13],args[14],args[15],args[16],args[17],args[18],args[19],args[20])
		Scale(x,y)
			_dm_icon_scale(icon,x,y)
		Crop(x1,y1,x2,y2)
			_dm_icon_crop(icon,x1,y1,x2,y2)
		GetPixel(x,y,icon_state,dir,frame,moving)
			return _dm_icon_getpixel(icon,x,y,icon_state,dir,frame,moving)
		Width()
			return _dm_icon_size(icon,1)
		Height()
			return _dm_icon_size(icon,2)
// sound
var/const
	SOUND_MUTE = 1
	SOUND_PAUSED = 2
	SOUND_STREAM = 4
	SOUND_UPDATE = 16
sound
	var
		file
		repeat
		wait
		channel
		frequency = 0
		pan = 0
		volume = 100
		priority = 0
		status = 0
		environment = -1
		echo
		x = 0
		y = 0
		z = 0
		falloff = 1
	_dm_interface = _DM_datum|_DM_sound|_DM_RscFile
	New(file,repeat,wait,channel,volume=100)
		src.file = fcopy_rsc(file)
		src.repeat = repeat
		src.wait = wait
		src.channel = channel
		src.volume = volume
		return ..()
	proc
		RscFile()
			return file
var/const
	NORTH = 1
	SOUTH = 2
	EAST = 4
	WEST = 8
	NORTHEAST = 5
	NORTHWEST = 9
	SOUTHEAST = 6
	SOUTHWEST = 10
	UP = 16
	DOWN = 32
var/const
	BLIND = 1
	SEE_MOBS = 4
	SEE_OBJS = 8
	SEE_TURFS = 16
	SEE_SELF = 32
	SEE_INFRA = 64
	SEE_PIXELS = 256
#define SEEINVIS 2
#define SEEMOBS 4
#define SEEOBJS 8
#define SEETURFS 16
var/const
	MOB_PERSPECTIVE = 0
	EYE_PERSPECTIVE = 1
	EDGE_PERSPECTIVE = 2
	
#define FLOAT_LAYER = -1
#define AREA_LAYER 1
#define TURF_LAYER 2
#define OBJ_LAYER 3
#define MOB_LAYER 4
#define FLY_LAYER 5
#define EFFECTS_LAYER 5000
#define TOPDOWN_LAYER 10000
#define BACKGROUND_LAYER 20000
var/const
	TOPDOWN_MAP = 0
	ISOMETRIC_MAP = 1
	SIDE_MAP = 2
	TILED_ICON_MAP = 32768
#define NO_STEPS 0
#define FORWARD_STEPS 1
#define SLIDE_STEPS 2
#define SYNC_STEPS 3
var/const
	TRUE = 1
	FALSE = 0
var/const
	MALE = "male"
	FEMALE = "female"
	NEUTER = "neuter"
	PLURAL = "plural"
var/const
	MOUSE_INACTIVE_POINTER = 0
	MOUSE_ACTIVE_POINTER = 1
	MOUSE_DRAG_POINTER = 3
	MOUSE_DROP_POINTER = 4
	MOUSE_ARROW_POINTER = 5
	MOUSE_CROSSHAIRS_POINTER = 6
	MOUSE_HAND_POINTER = 7
var/const
	MOUSE_LEFT_BUTTON = 1
	MOUSE_RIGHT_BUTTON = 2
	MOUSE_MIDDLE_BUTTON = 4
	MOUSE_CTRL_KEY = 8
	MOUSE_SHIFT_KEY = 16
	MOUSE_ALT_KEY = 32
#define CONTROL_FREAK_ALL 1
#define CONTROL_FREAK_SKIN 2
#define CONTROL_FREAK_MACROS 4
var/const
	MS_WINDOWS = "MS Windows"
	UNIX = "UNIX"
#define ASSERT(c) if(!(c)) {CRASH("[__FILE__]:[__LINE__]:Assertion Failed: [#c]"); }
#define _DM_datum 0x001
#define _DM_atom 0x002
#define _DM_movable 0x004
#define _DM_sound 0x020
#define _DM_Icon 0x100
#define _DM_RscFile 0x200
#define _DM_Matrix 0x400