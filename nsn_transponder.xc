


; ========== Config ==========


; Set vehicle name
; These get sent to any radars that are listening
; Can be overriden in main prog
const $nsn_vehicle_name = ""


; Add your beacon alias here
; The first 4 are used for detecting position, place them next to each other
; The last one is used for transmitting to radars, placve it anywhere
const $nsn_beacon_alias_0 = "ant_0"
const $nsn_beacon_alias_1 = "ant_1"
const $nsn_beacon_alias_2 = "ant_2"
const $nsn_beacon_alias_3 = "ant_3"
const $nsn_beacon_alias_4 = "ant_4"


; Speed sensor alias
; If you want to track speed at your radar, add this
const $nsn_speed_sensor_alias_0 = "speed_0"


; Update speed
; This is in seconds
; Faster will also make position more accurate but more resource intensive
; Once every 5 seconds is great if you are only using this for radar positioning, or moving slow
; If you need precision or are travelling at fast speeds, you should reduce this.
const $nsn_update_speed = 1.5

; Guesses per update
; If you are getting lag spikes you should reduce this
; Balance it with $nsn_update_speed
; Very resource intensive at large numbers
const $nsn_iterations = 200


; Default is fine
; Your Radar and transponders should have the same prefix set
; Change it if you dont want other people to track your vehicles
; Stealh mode is better if you want to be invisible to other players
const $nsn_transmit_prefix = "transponder_"


; Set to 1 to get verbose output in console
const $nsn_debug = 0








; ========== Public Vars ==========
; you can use these in your main program
; Don't try changing read only valuess

; Contains your vehicles current position
; Read only
; contains x, y, z, error and iterations
; iterations is how many times the code ran (should go to 0 when no moving)
; error is how accurate the position is (lower is better)
var $nsn_current_position : text 

; The channel the transponder is transmitting on
; The is selected automatically during boot
; Read only
var $nsn_transmit_channel = ""

; Stop transmitting craft data to radars
; Useful if your building a stealth fighter :D
; Read/Write
var $nsn_stealth_mode = 0

; Send extra data to the listening radar system
; This should be a key-value object
; eg ".fuel{0.5}.power{0.89}"
; Read/Write
var $nsn_custom_data = ""










; ========== Private vars ==========
; No touchy!
const $nsn_guess_zero = ".x{0}.y{0}.z{0}.error{99999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999}" ; Tons of error, anything is better than this
array $nsn_results_history : text ; an array of previous results

; An array of beacons for positioning
array $nsn_beacons : text

; contains vehicle data that is transmitted
var $nsn_vehicle_data : text



; Gets set to 0 when an open channel is found
; the transponder will find an empty channel and select it for use automatically
var $nsn_init_transmit_beacon = 1
var $nsn_init_count = 0
var $nsn_initial_run = 1





; ========== Functions ==========

; Gets distance between 2 positions
function @distance_vec3($pos_0:text, $pos_1:text):number
	; takes object ".x{}.y{}.z{}"
	var $distance = sqrt(pow($pos_1.x - $pos_0.x, 2) + pow($pos_1.y - $pos_0.y, 2) + pow($pos_1.z - $pos_0.z, 2))
	return $distance


; Gets results from a beacon
function @get_beacon($alias:text): text
	var $results = ""
	$results.position = input_text($alias, 0)
	$results.distance = input_text($alias, 1)
	return $results


; Calculates the amount of error a guess has, lower is better
function @trilat_calc_error($guess:text):number
	; calcs error of current position from beacon input
	; $guess is a vec3 ".x{}.y{}.z{}"
	; https://yogayu.github.io/DeepLearningCourse/04/GradientDescent.html

	var $error = 0
	foreach $nsn_beacons ($index, $beacon)
		$error += pow($beacon.distance - @distance_vec3($guess, $beacon.position), 2)
		
	return $error / $nsn_beacons.size


; Performs trilateration via optimization
function @trilat_3d_basic($options:text):text
	; Trilateration as an optimization problem, calculates pos with error
	; $trilat_2d_opti_array is an array with objects like this ".distance{}.position{.x{}.y{}.z{}}"
	; https://www.alanzucconi.com/2017/03/13/positioning-and-trilateration/
	
	; $options needs these, guess is optional ".max_iterations{50}.learning_rate{0.8}.guess{}"
	; guess is of format ".x{0}.y{0}.z{0}"

	; Tips
	; Learning rate should be around 0.5 - 1.4, extreme values break it
	
	; Max iterations, can be very cpu intensive, over 500 give my pc stutters
	; The higher this is, the quicker error reaches zero
	
	; Example error values (calc is squared so gets big quick)
	; X += 1 ; Error = 0.62
	; X += 10 ; Error = 60
	; X += 100 ; Error = 5879
	; X += 1000 ; Error = 481221
	
	
	var $error = 0
	var $guess = ""
	var $last_guess = ""
	var $total_iterations = 0
	var $results_kept = 2
	
	; Initialize results
	if $nsn_results_history.size == 0
		$nsn_results_history.fill($results_kept, $nsn_guess_zero)
	
	
	var $test = $nsn_results_history.0
	$test.x += 1000
	
	
	; Skip optimization algo if last result error is low enough
	; Stops processing if vehicle is stopped
	if @trilat_calc_error($nsn_results_history.0) < 0.05
		$guess = $nsn_results_history.0
		$guess.iterations = $total_iterations
		return $guess
	
	
	
	; Set an initial guess value
	$guess = $nsn_guess_zero
	$guess.error = @trilat_calc_error($guess)

	
	; Try the guess provided, see if its better
	if $options.guess != ""
		$error = @trilat_calc_error($options.guess)
		if $guess.error > $error
			; replace the guess
			$guess = $options.guess
	
	
	
	; Try the last result
	; Stay still to get accurate fast
	$error = @trilat_calc_error($nsn_results_history.0)
	if $guess.error > $error
		; replace the guess
		$guess = $nsn_results_history.0
	
	
	
	; Try extrapolated future position based on results history
	; for accuracy of moving vehicles
	var $cur_pos = $nsn_results_history.0
	var $last_pos = $nsn_results_history.1
	
	var $future_pos = ""
	$future_pos.x = $cur_pos.x - $last_pos.x
	$future_pos.y = $cur_pos.y - $last_pos.y
	$future_pos.z = $cur_pos.z - $last_pos.z
	$future_pos.error = @trilat_calc_error($future_pos)
	if $future_pos.error < $guess.error
		$guess = $future_pos
	
	
	
	; Try each beacon to see if they are better as an initial guess
	foreach $nsn_beacons ($index, $beacon)
		$error = @trilat_calc_error($beacon.position)
	
		if $error < $guess.error
			$guess = $beacon.position
			$guess.error = $error
			
	
	
	; Make a second initial guess near the first guess
	; needed because the new weight calc is done from $last_guess vs this guess
	$last_guess = $guess
	
	$guess.x = $last_guess.x + 100000
	$guess.y = $last_guess.y + 100000
	$guess.z = $last_guess.z + 100000
	$guess.error = @trilat_calc_error($guess)
	
	
	

	
	; Set an initial best guess
	; gets set to the best initial position
	; Should fix random large error spikes when moving
	var $best_guess = $guess
	
	

	
	; Do the iterations
	var $weight = 0.1 ; changin this doesnt do much, gets updated every iteration
	var $i = 0
	while $i < $options.max_iterations
		$total_iterations += 1
		var $e = $guess.error
		$e.round()
		
		
		$guess = $last_guess
		$guess.x += $weight
		$guess.error = @trilat_calc_error($guess)
		
		$weight = $weight - ($options.learning_rate * ($guess.error / ($guess.x - $last_guess.x)))
		
		if ($guess.error < $best_guess.error)
			$best_guess = $guess

		$i++
	
	
	
	$guess = $best_guess
	$last_guess = $best_guess
	$last_guess.y += $weight
	$weight = 0.1
	$i = 0
	while $i < $options.max_iterations
		$total_iterations += 1
		var $e = $guess.error
		$e.round()
		
		$guess = $last_guess
		$guess.y += $weight
		$guess.error = @trilat_calc_error($guess)
		
		$weight = $weight - ($options.learning_rate * ($guess.error / ($guess.y - $last_guess.y)))
		
		if ($guess.error < $best_guess.error)
			$best_guess = $guess

		$i++
		

	
	$guess = $best_guess
	$last_guess = $best_guess
	$last_guess.z += $weight
	$weight = 0.1
	$i = 0
	while $i < $options.max_iterations
		$total_iterations += 1
		var $e = $guess.error
		$e.round()
		
		$guess = $last_guess
		$guess.z += $weight
		$guess.error = @trilat_calc_error($guess)
		
		$weight = $weight - ($options.learning_rate * ($guess.error / ($guess.z - $last_guess.z)))
		
		
		if ($guess.error < $best_guess.error)
			$best_guess = $guess
		$i++

	$best_guess.iterations = $total_iterations ; how many times we tried to optimize
	$nsn_results_history.insert(0, $best_guess) ; Insert new result into history
	$nsn_results_history.pop() ; Pop last value to avoid a massive history
	
	return $best_guess

















; ========== Logic ==========
	
	
	

; This is just used to find a free channel to transmit on
; If statement at start stop the rest of the code from running once a channel is found
timer frequency 10

	; Find an empty channel to transmit on
	; Once this is set, it stays the same until reboot
	if $nsn_init_transmit_beacon
	
		
		; Beacons can't read on on tick they are set
		; Need to delay first read
		if $nsn_initial_run
			$nsn_initial_run = 0
			output_text($nsn_beacon_alias_4 , 2, $nsn_transmit_prefix & "0")
			
			
			; ========================= Other initialization code =====================
			; There can only be 1 init
			; Placing this here so users can do their own init
			
			; Set transponder name
			if $nsn_vehicle_name == ""
				$nsn_vehicle_data.name = "unnamed transponder"
			else
				$nsn_vehicle_data.name = $nsn_vehicle_name

			; Select channel on our positioning beacons
			output_text("ant_0", 2, "nsn_0") ; NSN Receivers
			output_text("ant_1", 2, "nsn_1")
			output_text("ant_2", 2, "nsn_2")
			output_text("ant_3", 2, "nsn_3")
			
			
		
		else
			; Iterate over transponder channels until a free one is found
			
			var $is_receiving = input_number($nsn_beacon_alias_4, 5)
			
			; Output channel 5 is whether the beacon is receiving or not
			if $is_receiving 
				
				; There is someone already transmitting here
				if $nsn_debug
					var $my_channel = $nsn_transmit_prefix & $nsn_init_count:text
					print(text("{} is in use", $my_channel))
				
				; Increment the channel checked for next run
				
				$nsn_init_count ++
				output_text($nsn_beacon_alias_4 , 2, $nsn_transmit_prefix & $nsn_init_count:text)
			
			else
				; Beacon is not receiving anything, so this channel is safe to use
			
				; Reset the listen channel
				output_text($nsn_beacon_alias_4 , 2, "")
				
				; Set the transmit channel
				$nsn_transmit_channel = $nsn_transmit_prefix & $nsn_init_count:text
				output_text($nsn_beacon_alias_4 , 1, $nsn_transmit_channel)
				
				
				; Disable Initialization
				$nsn_init_transmit_beacon = 0
				
				if $nsn_debug
					print("Initialization complete")
					print(text("Transmit name set to: {}", $nsn_vehicle_data.name))
					print(text("Transmit channel set to: {}", $nsn_transmit_channel))


timer interval $nsn_update_speed


	if $nsn_init_transmit_beacon
		return

	; Perform Trilateration to get Position
	; Get data from each beacon
	var $beacon_data_0 = @get_beacon($nsn_beacon_alias_0)
	var $beacon_data_1 = @get_beacon($nsn_beacon_alias_1)
	var $beacon_data_2 = @get_beacon($nsn_beacon_alias_2)
	var $beacon_data_3 = @get_beacon($nsn_beacon_alias_3)
	
	; Add data to an array (array can be as long as you need)
	$nsn_beacons.clear()
	$nsn_beacons.append($beacon_data_0, $beacon_data_1, $beacon_data_2, $beacon_data_3)
	
	; Use trilateration to find currect pos
	var $pos_result = @trilat_3d_basic(".max_iterations{200}.learning_rate{0.8}")
	
	if $nsn_debug
		print($pos_result)
	
	; Set the public variable so people know what the position is
	$nsn_current_position = $pos_result

	
	; Format vehicle data to send to listening radars
	$nsn_vehicle_data.x = $pos_result.x
	$nsn_vehicle_data.y = $pos_result.y
	$nsn_vehicle_data.z = $pos_result.z
	$nsn_vehicle_data.time = time
	$nsn_vehicle_data.speed = input_number($nsn_speed_sensor_alias_0, 0)
	$nsn_vehicle_data.custom_data = $nsn_custom_data
	
	; Send vehicle data
	if $nsn_stealth_mode
	
		if $nsn_debug
			print("Stealth mode active")
		
		; Clear transmit data
		output_text($nsn_beacon_alias_4, 0, "")
		
		; Clear transmit channel
		output_text($nsn_beacon_alias_4 , 1, "")
		
	
	else
		; Stealth mode not enable
		; Set channel and transmit
		output_text($nsn_beacon_alias_4 , 1, $nsn_transmit_channel)
		output_text($nsn_beacon_alias_4, 0, $nsn_vehicle_data)