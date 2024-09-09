

	
; !!!!!!!!!!!!!!! Dependencies !!!!!!!!!!!!!!!
; nsn_radar.xc < needs to load first, or similar
; reads $nsn_radar_transponders for transponder position




; ========== Config ==========

; ===== Global Config

; Set the screen to draw to
var $nsn_radar_draw_screen = screen("dash_0", 0)

; How many seconds inbetween map updates
; Min is 0.04 (every tick)
const $nsn_radar_map_update_speed = 1

; Print verbose output
; 0 or 1, turn off so avoid console spam
const $nsn_radar_draw_debug = 1 


; ===== Planet Config

; Color of the planet
var $nsn_radar_draw_planet_color = green

; Measure using a altitude sensor
; Default is fine for default earth size earth
; Ground level at earth spawn = 623001.693319
const $nsn_radar_draw_planet_radius = 623001.693319

; How think the planet circle is on the screen
; Turn this up on larger screens
const $nsn_radar_draw_planet_thickness = 3




; ===== Transponder Config

; Color of transponders
var $nsn_radar_draw_transponder_color = red

; Size of transpoders marks
var $nsn_radar_draw_transponder_size = 3





; ========== Public Vars ==========
; Change the maps zoom level
var $nsn_radar_draw_zoom = 0.0005


; When set to true will trigger a redraw
; Do this after changing map (Zoom, Move, Rotate etc)
; done this way to only update screen when its needed
; Read/Write
var $nsn_radar_draw_redraw = 0


; ========== Private Vars ==========

; Gets set to true when this module has finished initilizing
var $nsn_radar_draw_loaded = 0





; ========== Functions ==========

function @nsn_radar_draw_planet()

	var $screen = $nsn_radar_draw_screen
	
	; Calc to scale draw radius
	var $draw_radius = $nsn_radar_draw_zoom * $nsn_radar_draw_planet_radius
	
	
	repeat $nsn_radar_draw_planet_thickness ($i)
		$screen.draw_circle($screen.width/2, $screen.height/2, $draw_radius - $i, $nsn_radar_draw_planet_color)





function @nsn_radar_draw_transponders()

	; get config
	var $screen = $nsn_radar_draw_screen
	var $color = $nsn_radar_draw_transponder_color
	var $size = $nsn_radar_draw_transponder_size
	
	; Make Screen Transform Matrix
	@matrix_reset()
	@matrix_get_identity()
	
	
	; Apply Scale
	var $scale = ""
	$scale.x = $nsn_radar_draw_zoom
	$scale.y = $nsn_radar_draw_zoom
	$scale.z = $nsn_radar_draw_zoom
	@matrix_scale($scale)
	
	
	foreach $nsn_radar_transponders ($index, $device)
		if $device.time > 0
		
			$device.w = 1 ; Turn position into a vec4
			
			; Multiply position by matrix
			var $screen_pos = @matrix_multiply_vector($device) ; $device has x,y,z,w so can be used as a vector
			
			$screen.draw_circle($screen_pos.x:number + $screen.width/2, $screen_pos.y:number + $screen.height/2, $size, $color, $color)
	


; ========== Logic ==========


timer interval $nsn_radar_map_update_speed
	
	; Make sure nsn_radar.xc initializes first
	; We're gonna read from its results array so we want it initialized
	if $nsn_radar_loaded
		
		; Init self if not loaded
		if !$nsn_radar_draw_loaded
			$nsn_radar_draw_loaded = 1
		
			; Do init here
			if $nsn_radar_draw_debug

				
				; Trigger redraw
				$nsn_radar_draw_redraw = 1

			
			
			

update

	; Only redraw if its needed
	
	; Debugging
	;$nsn_radar_draw_redraw = 1
	
	if $nsn_radar_draw_redraw
		$nsn_radar_draw_redraw = 0
		
		if $nsn_radar_draw_debug
			print("Redraw Triggered")
		
		; Reset Screen
		$nsn_radar_draw_screen.blank(black)
	
		; ===== Draw =====
		
		; Draw circle of planet
		@nsn_radar_draw_planet()
		
		; Draw Transponders
		@nsn_radar_draw_transponders()
		


timer interval 1
	
	; Trigger redraw once a second
	$nsn_radar_draw_redraw = 1