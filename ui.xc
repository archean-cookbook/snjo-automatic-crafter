function @button($x:number, $y:number, $width:number, $height:number, $linecolor:number, $backcolor:number, $text:text, $textcolor:number, $margin:number):number
	; if $debug
	;	print($x,$y,$width,$height,$text)
	; var $screen = screen
	if $width == 0
		$width = size($text)*$screen.char_w + $margin*2
	if $height == 0
		$height = $screen.char_h + $margin*2
	;print($screen.char_h,$margin,$height)
	var $result = $screen.button_rect($x,$y,$x+$width,$y+$height,$linecolor,$backcolor)
	$screen.write($X+$margin,$Y+$margin,$textcolor,$text)
	return $result

function @drawTriangleUp($X:number,$Y:number,$size:number,$lineColor:number,$fillColor:number)
	$screen.draw_triangle($X+$size/2,$Y, $X,$Y+$size, $X+$size,$Y+$size,$lineColor,$fillColor)
	
function @drawTriangleDown($X:number,$Y:number,$size:number,$lineColor:number,$fillColor:number)
	$screen.draw_triangle($X+$size/2,$Y+$size, $X,$Y, $X+$size,$Y,$lineColor,$fillColor)
	
function @drawScrollBar($X:number,$Y:number,$width:number,$height:number,$position:number,$max:number)
	; SCROLL VIEW
	if $max < 1
		$max = 1
		
	var $buttonHeight = $height/4
	var $arrowSize = $width-6
	var $margin = ($width - $arrowSize)/2
	
	;UP
	if @button($X,$Y,$width,$buttonHeight,0,gray,"")
		$scroll -= $linesOnScreen-2
		if $scroll < 0
			$scroll = 0
	@drawTriangleUp($X+$margin,$Y+$buttonHeight/2-$margin,$width-$margin*2,0,white)
	
	; DOWN
	if @button($X,$height-$buttonHeight,$width,$buttonHeight,0,gray,"")
		$scroll += $linesOnScreen-3
		if $scroll >= $itemLines
			$scroll = $itemLines-1
		if $scroll < 0
			$scroll = 0
	@drawTriangleDown($X+$margin,($screen.height-$buttonHeight)+$buttonHeight/2-$margin,$width-$margin*2,0,white)
	
	var $scrollBoxTop = $buttonHeight + 2
	var $scrollBoxBottom = $height - $buttonHeight - 7
	var $scrollBoxHeight = $scrollBoxBottom - $scrollBoxTop
	var $indicatorY = $scrollBoxTop + $scrollBoxHeight * ($position/$max)
	if @button($X,$scrollBoxTop,$width,$scrollBoxHeight+5,0,color(20,20,20),"")
		var $clickY = click_y - $scrollBoxTop
		var $clickNormalized = $clickY / $scrollBoxHeight
		var $newScroll = min(floor($max * $clickNormalized),$max)
		print("scroll click",$clickNormalized,"new",$newScroll,"max",$max)
		$scroll = $newScroll
		;var $newScroll = 
	$screen.draw_rect($X,$indicatorY,$X+$width,$indicatorY+5,0,white)
	
function @onColor($value:number,$on:number,$off:number):number
	if $value
		return $on
	return $off