; Vector Library
; Supprts 2, 3 or 4 value vectors
;
;
;
;
;






; ===== Constants

const $vec2_zero = ".x{0}.y{0}.type{2}"
const $vec2_right = ".x{1}.y{0}.type{2}"
const $vec2_up = ".x{0}.y{1}.type{2}"

const $vec3_zero = ".x{0}.y{0}.z{0}.type{3}"
const $vec3_right = ".x{1}.y{0}.z{0}.type{3}"
const $vec3_up = ".x{0}.y{1}.z{0}.type{3}"
const $vec3_forward = ".x{0}.y{0}.z{1}.type{3}"

const $vec4_zero = ".x{0}.y{0}.z{0}.w{0}.type{4}"
const $vec4_right = ".x{1}.y{0}.z{0}.w{1}.type{4}"
const $vec4_up = ".x{0}.y{1}.z{0}.w{1}.type{4}"
const $vec4_forward = ".x{0}.y{0}.z{1}.w{1}.type{4}"







; ===== Vector Properties



; Get the magnitude of the vector
function @vec2_magnitude ($vec:text):number
	return abs(sqrt(($vec.x * $vec.x) + ($vec.y * $vec.y)))
	
function @vec3_magnitude ($vec:text):number
	return abs(sqrt(($vec.x * $vec.x) + ($vec.y * $vec.y) + ($vec.z * $vec.z)))
	
function @vec4_magnitude ($vec:text):number
	return abs(sqrt(($vec.x * $vec.x) + ($vec.y * $vec.y) + ($vec.z * $vec.z) + ($vec.w * $vec.w)))



; Get the squared magnitude of the vector
; Is faster than @vec_magnitude because it skips the sqrt
function @vec2_sqr_magnitude ($vec:text):number
	return abs(($vec.x * $vec.x) + ($vec.y * $vec.y)))
	
function @vec3_sqr_magnitude ($vec:text):number
	return abs(($vec.x * $vec.x) + ($vec.y * $vec.y) + ($vec.z * $vec.z)))	
	
function @vec4_sqr_magnitude ($vec:text):number
	return abs(($vec.x * $vec.x) + ($vec.y * $vec.y) + ($vec.z * $vec.z) + ($vec.w * $vec.w)))


; Get the normal of the vector
; Normal is the same vector but with a magnitude of 1
function @vec2_normal ($vec:text):text
	var $result = $vec
	var $magnitude = @vec2_magnitude($result)
	
	; IFs are to make sure we dont divide by zero
	; if value is already zero its fine we can leave it
	if $result.x
		$result.x /= $magnitude
	if $result.y
		$result.y /= $magnitude

	return $result
	
	
	
function @vec3_normal ($vec:text):text
	var $result = $vec
	var $magnitude =  @vec3_magnitude($result)
	
	; IFs are to make sure we dont divide by zero
	; if value is already zero its fine we can leave it
	if $result.x
		$result.x /= $magnitude
	if $result.y
		$result.y /= $magnitude
	if $result.z
		$result.z /= $magnitude

	return $result
	
	
	
function @vec4_normal ($vec:text):text
	var $result = $vec
	var $magnitude =  @vec4_magnitude($result)
	
	; IFs are to make sure we dont divide by zero
	; if value is already zero its fine we can leave it
	if $result.x
		$result.x /= $magnitude
	if $result.y
		$result.y /= $magnitude
	if $result.z
		$result.z /= $magnitude
	if $result.w
		$result.w /= $magnitude

	return $result








; ===== Vector Maths



; Add vectors together
function @vec2_add($vec_0:text, $vec_1:text):text
	var $result = $vec_0
	$result.x += $vec_1.x
	$result.y += $vec_1.y
	return $result
	
function @vec3_add($vec_0:text, $vec_1:text):text
	var $result = $vec_0
	$result.x += $vec_1.x
	$result.y += $vec_1.y
	$result.z += $vec_1.z
	return $result
	
function @vec4_add($vec_0:text, $vec_1:text):text
	var $result = $vec_0
	$result.x += $vec_1.x
	$result.y += $vec_1.y
	$result.z += $vec_1.z
	$result.w += $vec_1.w
	return $result




; Subtract second vector from first vector
function @vec2_subtract($vec_0:text, $vec_1:text):text
	var $result = $vec_0
	$result.x -= $vec_1.x
	$result.y -= $vec_1.y
	return $result
	
function @vec3_subtract($vec_0:text, $vec_1:text):text
	var $result = $vec_0
	$result.x -= $vec_1.x
	$result.y -= $vec_1.y
	$result.z -= $vec_1.z
	return $result
	
function @vec4_subtract($vec_0:text, $vec_1:text):text
	var $result = $vec_0
	$result.x -= $vec_1.x
	$result.y -= $vec_1.y
	$result.z -= $vec_1.z
	$result.w -= $vec_1.w
	return $result



; Calculate distance between 2 vectors
function @vec2_distance($vec_0:text, $vec_1:text):number
	var $dist_vec = @vec2_subtract($vec_0, $vec_1)
	return @vec2_magnitude($dist_vec)

function @vec3_distance($vec_0:text, $vec_1:text):number
	var $dist_vec = @vec3_subtract($vec_0, $vec_1)
	return @vec3_magnitude($dist_vec)

function @vec4_distance($vec_0:text, $vec_1:text):number
	var $dist_vec = @vec4_subtract($vec_0, $vec_1)
	return @vec4_magnitude($dist_vec)






; ===== Vector conditionals

; Check if Vectors are equal
; Equal if magnitudes are within 1 millimeter (1 = 1 Meter)
function @vec2_equal($vec_0:text, $vec_1:text):number
	var $result = $vec_0
	$result.x -= $vec_1.x
	$result.y -= $vec_1.y
	
	if @vec2_sqr_magnitude($result) < 0.001
		return 1 ; true, they are equal
	else
		return 0 ; false, vec are not equal
	return $result
	
function @vec3_equal($vec_0:text, $vec_1:text):number
	var $result = $vec_0
	$result.x -= $vec_1.x
	$result.y -= $vec_1.y
	$result.z -= $vec_1.z
	
	if @vec3_sqr_magnitude($result) < 0.001
		return 1 ; true, they are equal
	else
		return 0 ; false, vec are not equal
	return $result
	
function @vec4_equal($vec_0:text, $vec_1:text):number
	var $result = $vec_0
	$result.x -= $vec_1.x
	$result.y -= $vec_1.y
	$result.z -= $vec_1.z
	$result.w -= $vec_1.w
	
	if @vec4_sqr_magnitude($result) < 0.001
		return 1 ; true, they are equal
	else
		return 0 ; false, vec are not equal
	return $result