; Detect beacons with default settings


; User Settings


array $nsn_scanning_beacons : text 	; Fill this array with your beacon alias'
array $nsn_beacon_detections : text 	; Found beacon data is stored here, use this in your code, index 0 is most recent
const $nsn_max_found_beacons = 50	; How many detections to store, anything over this gets deleted

; How fast to scan
const $nsn_scan_speed = 0.04 ; 0.04 is every tick

; Should we print info to console?
const $debug = 1



; Put this in main

; include "find_beacons.xc"
;
; init
;	$nsn_scanning_beacons.append("ant_0")
;	$nsn_scanning_beacons.append("ant_1")
;	$nsn_scanning_beacons.append("ant_2")
;	$nsn_scanning_beacons.append("ant_3")
;	$nsn_scanning_beacons.append("ant_4")












; Program settins

const $nsn_max_chan = 10000 	; Max channel on beacon
array $nsn_cur_chan : number 	; Keep track of which beacon is on which channel
var $nsn_next_chan = 0	; Increment through each channel
var $nsn_first_run = 1	; Is this the first run?

timer interval $nsn_scan_speed
	
	
	; Do initial setup
	if $nsn_first_run
		
		; Initialize our beacon channel array
		$nsn_cur_chan.fill($nsn_scanning_beacons.size, 0)
		
		;Initialize beacon detections array
		var $dummy_detection = ".time{0}" ; Make the detection really old, so they can be filtered out
		$nsn_beacon_detections.fill($nsn_max_found_beacons, $dummy_detection)
		
		; Initialize each beacon
		foreach $nsn_scanning_beacons ($index, $beacon)
			output_number($beacon, 2, $nsn_next_chan)	; Set the beacons channel
			$nsn_cur_chan.$index = $nsn_next_chan			; Save channel selection for later use
			output_text($beacon, 1, "")					; Turn off default transmit channel, dont want to detect ourselves
			$nsn_next_chan += 1							; Increment channel selector for next beacon
		
		$nsn_first_run = 0 ; We only want to run this initial setup once
		if $debug
			print("Completed setup")
		return	; Finish this tick, we only want to run initialization code first time round
		
	
	
	
	
	; Scan with each beacon
	foreach $nsn_scanning_beacons ($index, $beacon)
		
		
		; Check "Is Receiving" on beacon
		if input_number($beacon, 5)
			
			; Gather detection data
			var $detection = ""
			$detection.data = input_text($beacon, 0)
			$detection.distance = input_number ($beacon, 1)
			$detection.channel = $nsn_cur_chan.$index
			$detection.x = input_number ($beacon, 2)
			$detection.y = input_number ($beacon, 3)
			$detection.z = input_number ($beacon, 4)
			$detection.time = time
			
			; Store detection data
			$nsn_beacon_detections.insert(0, $detection)
			
			; Delete old data if we are storing too much
			if  $nsn_beacon_detections.size > $nsn_max_found_beacons
				$nsn_beacon_detections.pop()
		
		
		output_number($beacon, 2, $nsn_next_chan)	; Set channel for next scan
		$nsn_cur_chan.$index = $nsn_next_chan			; Save channel for later use
		$nsn_next_chan += 1							; Increment channel for next beacon
		

	if $debug
		print("Last detection: " & $nsn_beacon_detections.0)