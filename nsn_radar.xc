; Radar designed to receive signals from transponders
; use with nsn_transponder.xc on your vehicles
; nsn_radar_draw.xc can be used to draw a 3d map on a screen


; ========== Config ==========
; configure the radar here
const $nsn_radar_antenna_alias = "ant_0" ; Antenna used for find transponders
const $nsn_radar_transponder_prefix = "transponder_" ; Set it to the same as your transponders
const $nsn_radar_maxChannels = 50 ; '10' would scan channel 0-9
const $nsn_radar_scan_speed = 0.04 ; lower is faster
const $nsn_radar_debug = 0 ; 0 or 1, turn off so avoid console spam





; ========== Public Vars ==========
;  use these in your main program
array $nsn_radar_transponders : text ; Array of data from each transponder





; ========== Internal ==========

; dont touch :)
var $nsn_radar_loaded = 0 ; Custom init so it doesn't interfere with main prog
var $nsn_radar_cur_scan = 0 ; Increments every call
var $nsn_radar_cur_channel = "" ; current channel being scanned








; ========== Functions ==========

; Scans another channel each time its called
; Updates $nsn_radar_transponders
; Note! the very first scan does doesn't receive data, wait for your scans to get back around to the start 
function @nsn_radar_scan_for_transponders($ant_alias:text)

	
	if $nsn_radar_debug
		print("Scanning Channel: " & $nsn_radar_cur_channel)
	
	; Check if a transponder is transmitting on current channel
	if input_number($ant_alias, 5) == 1
	
		if $nsn_radar_debug
			print("Found Transponder")
		
		; Get data from found transponder
		var $data = input_text($ant_alias, 0)
		
		; Store in global array
		$nsn_radar_transponders.$nsn_radar_cur_scan = $data
		
		if $nsn_radar_debug
			print($data)
	
	
	; Increment Channel
	$nsn_radar_cur_scan ++
	if $nsn_radar_cur_scan >= $nsn_radar_maxChannels
		$nsn_radar_cur_scan = 0
	
	; Set Channel for next run
	; Must go at end, or it wont scan the correct channel, Takes a run to update antenna channel
	$nsn_radar_cur_channel = $nsn_radar_transponder_prefix & $nsn_radar_cur_scan:text
	output_text($ant_alias, 2, $nsn_radar_cur_channel)
	








; ========== Logic ==========

	
	
timer interval $nsn_radar_scan_speed
	
	; Do init
	if !$nsn_radar_loaded
		$nsn_radar_loaded = 1
		
		; Initialize transponders array
		$nsn_radar_transponders.fill($nsn_radar_maxChannels, "")
		$nsn_radar_cur_channel = $nsn_radar_transponder_prefix & $nsn_radar_cur_scan:text



	; Search for transponders
	@nsn_radar_scan_for_transponders($nsn_radar_antenna_alias)
