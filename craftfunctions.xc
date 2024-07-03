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

function @drawTriangleUp($X:number,$Y:number,$size:number,$lineColor:number,$fillColor:number)
	draw_triangle($X+$size/2,$Y, $X,$Y+$size, $X+$size,$Y+$size,$lineColor,$fillColor)
	
function @drawTriangleDown($X:number,$Y:number,$size:number,$lineColor:number,$fillColor:number)
	draw_triangle($X+$size/2,$Y+$size, $X,$Y, $X+$size,$Y,$lineColor,$fillColor)
			
function @getResourceOld($container:text,$name:text):number
	var $stockText = input_text($container,0)
	;print("container",$name,$stockText.$name:number)
	return $stockText.$name:number	

function @getResource($name:text,$inventories:text):number
	var $items = ""
	var $O2 = 0
	var $H2 = 0
	var $gasFallback = 0
	foreach $inventories ($i,$n)
		if contains($n,"tank")
			var $amount = input_text($n,0)
			if contains($n,"O2")
				$O2 += $amount
			elseif contains($n,"H2")
				$H2 += $amount
			else ; very rough split in half, not accurate
				$gasFallback = $amount/2
		else
			$items = input_text($n,0)
	if $gasFallback > 0 && $O2 <= 0 && $H2 <= 0
		$O2 = $gasFallback
		$H2 = $gasFallback
		print("using fallback split gas value since there aren't separate tanks")
	$items.O2 = $O2
	$items.H2 = $H2
	return $items.$name:number	