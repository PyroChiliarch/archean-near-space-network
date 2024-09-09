; 
;	Library for 4x4 matrixes
;	Useful for 3d graphics
;
;	A matrix 4x4 array	
;	[ 0, 4, 8,  12 ]
;	[ 1, 5, 9,  13 ]
;	[ 2, 6, 10, 14 ]
;	[ 3, 7, 11, 15 ]
;
;	Examples of what it can do
; 	These are 2d, but you get the idea (i hope)
;	https://en.wikipedia.org/wiki/File:2D_affine_transformation_matrix.svg
;
;	Reference
;	https://en.wikipedia.org/wiki/Transformation_matrix
;
;	Why is this library/module built this?
;	You cant pass arrays to functions in XenonCode, so the library reuses a couple global arrays
;
;	In most cases $matrix_arr_0 is input and output
;	If a second input matrix is needed, then $matrix_arr_1 is used as the second output
;	
;	Some functions take a vec3, a vec4 can be used here but the w value will be ignored





; ===== Public Vars

; Inputs for functions
array $matrix_arr_0 : number ; Used most of the time
array $matrix_arr_1 : number ; Used when 2 matrixes are needed



; Set to 1 when initialized
var $matrix_loaded = 0






; ===== Functions =====



; Init both global arrays
function @matrix_reset ()
	$matrix_arr_0.fill(16, 0)
	$matrix_arr_1.fill(16, 0)




; ===== Constructors

; Gets a matrix full of 0
; Outputs to $matrix_arr_0
function @matrix_get_zero ()
	
	; Make an empty matrix
	$matrix_arr_0.fill(16, 0)







; Gets the identity matrix
; Outputs to $matrix_arr_0
function @matrix_get_identity ()
	
	; Start with empty matrix
	@matrix_get_zero()
	
	; Change diagonal to 1
	$matrix_arr_0.0 = 1
	$matrix_arr_0.5 = 1
	$matrix_arr_0.10 = 1
	$matrix_arr_0.15= 1
	
	









; ===== Helper Functions =====
	

; Prints a matrix to the console for troubleshooting
; Uses $matrix_arr_0
function @matrix_print ()
	print(text("[	{},	{},	{},	{}	]", $matrix_arr_0.0, $matrix_arr_0.4, $matrix_arr_0.8, $matrix_arr_0.12))
	print(text("[	{},	{},	{},	{}	]", $matrix_arr_0.1, $matrix_arr_0.5, $matrix_arr_0.9, $matrix_arr_0.13))
	print(text("[	{},	{},	{},	{}	]", $matrix_arr_0.2, $matrix_arr_0.6, $matrix_arr_0.10, $matrix_arr_0.14))
	print(text("[	{},	{},	{},	{}	]", $matrix_arr_0.3, $matrix_arr_0.7, $matrix_arr_0.11, $matrix_arr_0.15))


; Swap the global matrices
; $matrix_arr_0 <=> $matrix_arr_1
function @matrix_swap ()
	
	; Create middle man matrix
	array $matrix_temp : number
	
	$matrix_temp.from($matrix_arr_0)
	$matrix_arr_0.from($matrix_arr_1)
	$matrix_arr_1.from($matrix_temp)
	
	









; ===== Modify Matrix =====


; Have a look at this link to see what these do https://tinylittlemaggie.github.io/transformation-matrix-playground/


; Translate a matrix by a vector
; use $matrix_arr_0
; Use vec 3
function @matrix_translate ($vec:text)
	$matrix_arr_0.12 += $vec.x
	$matrix_arr_0.13 += $vec.y
	$matrix_arr_0.14 += $vec.z





; Scale a matrix by a vector
; use $matrix_arr_0
; Use vec 3
function @matrix_scale ($vec:text)
	$matrix_arr_0.0 *= $vec.x
	$matrix_arr_0.5 *= $vec.y
	$matrix_arr_0.10 *= $vec.z





; Shear a matrix by a vector
; use $matrix_arr_0
; Use vec 3
function @matrix_shear ($vec:text)
	$matrix_arr_0.8 *= $vec.x
	$matrix_arr_0.5 *= $vec.y
	$matrix_arr_0.2 *= $vec.z



; Rotate a matrix around an axis by a number of degrees

; https://en.wikipedia.org/wiki/Rotation_matrix
; Section "In three dimensions > Basic 3D rotations"
function @matrix_rotate_x ($angle:number)
	$matrix_arr_0.5 += cos($angle)
	$matrix_arr_0.9 += -sin($angle)
	$matrix_arr_0.6 += sin($angle)
	$matrix_arr_0.10 += cos($angle)

function @matrix_rotate_y ($angle:number)
	$matrix_arr_0.0 += cos($angle)
	$matrix_arr_0.8 += sin($angle)
	$matrix_arr_0.2 += -sin($angle)
	$matrix_arr_0.10 += cos($angle)
	
function @matrix_rotate_z ($angle:number)
	$matrix_arr_0.0 += cos($angle)
	$matrix_arr_0.4 += -sin($angle)
	$matrix_arr_0.1 += sin($angle)
	$matrix_arr_0.5 += cos($angle)

	
	
	
	

; ===== Matrix Multiplication =====


; Multiple a Matrix and a Vector
; https://mathinsight.org/matrix_vector_multiplication
function @matrix_multiply_vector($vec:text):text
	var $result = ""
	$result.x = ($vec.x * $matrix_arr_0.0) + ($vec.y * $matrix_arr_0.4) + ($vec.z * $matrix_arr_0.8) + ($vec.w * $matrix_arr_0.12)
	$result.y = ($vec.x * $matrix_arr_0.1) + ($vec.y * $matrix_arr_0.5) + ($vec.z * $matrix_arr_0.9) + ($vec.w * $matrix_arr_0.13)
	$result.z = ($vec.x * $matrix_arr_0.2) + ($vec.y * $matrix_arr_0.6) + ($vec.z * $matrix_arr_0.10) + ($vec.w * $matrix_arr_0.14)
	$result.w = ($vec.x * $matrix_arr_0.3) + ($vec.y * $matrix_arr_0.7) + ($vec.z * $matrix_arr_0.11) + ($vec.w * $matrix_arr_0.15)
	return $result
	

;function @matrix_multiply_matrix()



;	[ 0, 4, 8,  12 ]
;	[ 1, 5, 9,  13 ]
;	[ 2, 6, 10, 14 ]
;	[ 3, 7, 11, 15 ]





; Initialize the module
; Make sure global arrays are setup
update
	if !$matrix_loaded
		$matrix_loaded = 1
		@matrix_reset()
