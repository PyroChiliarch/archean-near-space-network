; This is your first beacons position
; leaving it 0, 0, 0 is fine, but some people might want to change it
; eg, offset by altitude to have earths center at 0, 0, 0
var $start_pos = ".x{0}.y{0}.z{0}"
	
; These are the distances between the beacons, put your measurements in here
; you dont need to, but it is recommended you place you first 3 beacons at sea level on even ground, at the same height
; The last fourth beacon, place it as high as you can

; distance from beacon_0 to beacon_1 etc...
var $beacon_0_to_1 = 0
	
var $beacon_0_to_2 = 0
var $beacon_1_to_2 = 0
	
var $beacon_0_to_3 = 0
var $beacon_1_to_3 = 0
var $beacon_2_to_3 = 0


init
	
	var $beacon_1 = ""
	var $beacon_2 = ""
	var $beacon_3 = ""



	; Beacon 0
	print("Beacon 0: ", $start_pos)
	
	; Beacon 1
	if $beacon_0_to_1 != 0
		$beacon_1 = $start_pos
		$beacon_1.x += $beacon_0_to_1
		print("Beacon 1: ", $beacon_1)
		
	; Beacon 2
	if $beacon_0_to_2 != 0
		if $beacon_1_to_2 != 0
			var $a = $beacon_1_to_2
			var $b = $beacon_0_to_1
			var $c = $beacon_0_to_2
			
			; https://www.symbolab.com/solver/algebra-calculator
			; A=cos^{-1}\left(\frac{b^2+c^2-a^2}{2bc}\right)
			; ^ this then convert from radians to degrees
			var $degrees = acos((pow($b, 2) + pow($c, 2) - pow($a, 2)) / (2 * $b * $c))
			
			;x = start_x + len * cos(angle
			var $x = $start_pos.x + $beacon_0_to_2 * cos($degrees)
			var $y = $start_pos.y + $beacon_0_to_2 * sin($degrees)
			
			$beacon_2 = ""
			$beacon_2.x = $x
			$beacon_2.y = $y
			$beacon_2.z = 0
			print("Beacon 2: ", $beacon_2)
			
			

	; Beacon 3
	
	; I dont know the maths for this, for now just paste your data into this site
	; https://planetcalc.com/10159/
	; You have the positions in the output of this script, you just need to measure the distance from each beacon to your fourth beacon (beacon_3)
	
	if $beacon_2 != "" and $beacon_0_to_3 != 0 and $beacon_1_to_3 != 0 and $beacon_2_to_3 != 0
		print("Beacon 4: ", "Paste below values into this website: https://planetcalc.com/10159/")
		print($start_pos.x & " " & $start_pos.y & " " & $start_pos.z, "", $beacon_0_to_3)
		print($beacon_1.x & " " & $beacon_1.y & " " & $beacon_1.z, "", $beacon_1_to_3)
		print($beacon_2.x & " " & $beacon_2.y & " " & $beacon_2.z, "", $beacon_2_to_3)
