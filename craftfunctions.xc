function @start_craft($crafter:text,$currentCraft:text)
	;print("starting",$currentCraft)
	output_text($crafter,1,$currentCraft)
	output_number($crafter,0,1)
	output_number($crafter,0,0) ; not sure if this matters
	
function @cancel_craft($crafter:text)
	;print("cancel")
	output_text($crafter,1,"x")
	output_number($crafter,0,0)

function @progress():number
	return input_number("crafter",0)
	
function @button($x:number, $y:number, $width:number, $height:number, $linecolor:number, $backcolor:number, $text:text, $textcolor:number, $margin:number):number
	;if $debug
	;	print($x,$y,$width,$height,$text)
	var $screen = screen
	if $width == 0
		$width = size($text)*$screen.char_w + $margin*2
	if $height == 0
		$height = $screen.char_h + $margin*2
	;print($screen.char_h,$margin,$height)
	var $result = $screen.button_rect($x,$y,$x+$width,$y+$height,$linecolor,$backcolor)
	$screen.write($X+$margin,$Y+$margin,$textcolor,$text)
	return $result
	
function @getResource($container:text,$name:text):number
	var $stockText = input_text($container,0)
	;print("container",$name,$stockText.$name:number)
	return $stockText.$name:number	