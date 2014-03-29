/**
* OpenBYOND Standard Library: atom defaults
*
* This file defines the default state of datums.
*/

/**
* objtree can't parse global constants, so we use defines here.
*/
#ifdef __OBJTREE
#define NORTH     1
#define SOUTH     2
#define EAST      4
#define WEST      8
#define NORTHEAST 5
#define NORTHWEST 9
#define SOUTHEAST 6
#define SOUTHWEST 10
#define UP        16
#define DOWN      32
#endif

/
	var/list/vars = list()
	var/type = null
	var/parent_type = null
	var/layer = OBJ_LAYER
	
/atom
	var/list/contents = list() 
	var/density = 0 
	var/desc = "" 
	var/dir = 2 
	var/gender = "neutral" 
	var/icon/icon=null
	var/icon_state=""
	var/invisibility = 0 
	var/list/underlays = list() 
	var/list/overlays = list() 
	//var/loc = null 
	var/layer = 3 
	var/mouse_over_pointer 
	var/mouse_drag_pointer 
	var/mouse_drop_pointer 
	var/mouse_drop_zone 
	var/mouse_opacity 
	var/name = "" 
	var/opacity = 1 
	var/pixel_x = 0 
	var/pixel_y = 0 
	var/pixel_z = 0 
	var/text = "" 
	var/list/verbs 
	var/x = 0 
	var/y = 0 
	var/z = 0 
	
/atom/movable
	var/turf/loc = null 
	
/turf
	#__OB_FORCE_PARENT /atom
	layer = TURF_LAYER
	
/area
	#__OB_FORCE_PARENT /atom
	layer = AREA_LAYER
	
/obj
	#__OB_FORCE_PARENT /atom/movable
	layer = OBJ_LAYER
	
/mob
	#__OB_FORCE_PARENT /atom/movable
	layer = MOB_LAYER