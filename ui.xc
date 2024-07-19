function @button($_screen:screen, $x:number, $y:number, $width:number, $height:number, $linecolor:number, $backcolor:number, $text:text, $textcolor:number, $margin:number):number
	; if $debug
	;	print($x,$y,$width,$height,$text)
	if $width == 0
		$width = size($text)*$_screen.char_w + $margin*2
	if $height == 0
		$height = $_screen.char_h + $margin*2
	;print($screen.char_h,$margin,$height)
	var $result = $_screen.button_rect($x,$y,$x+$width,$y+$height,$linecolor,$backcolor)
	$_screen.write($X+$margin,$Y+$margin,$textcolor,$text)
	return $result

function @drawTriangleUp($_screen:screen, $X:number,$Y:number,$size:number,$lineColor:number,$fillColor:number)
	$_screen.draw_triangle($X+$size/2,$Y, $X,$Y+$size, $X+$size,$Y+$size,$lineColor,$fillColor)
	
function @drawTriangleDown($_screen:screen, $X:number,$Y:number,$size:number,$lineColor:number,$fillColor:number)
	$_screen.draw_triangle($X+$size/2,$Y+$size, $X,$Y, $X+$size,$Y,$lineColor,$fillColor)
	
function @drawScrollBar($_screen:screen, $X:number,$Y:number,$width:number,$height:number,$position:number,$max:number)
	; SCROLL VIEW
	if $max < 1
		$max = 1
		
	var $buttonHeight = $height/4
	var $arrowSize = $width-6
	var $margin = ($width - $arrowSize)/2
	
	;UP
	if @button($_screen,$X,$Y,$width,$buttonHeight,0,gray,"")
		$scroll -= $linesOnScreen-2
		if $scroll < 0
			$scroll = 0
	@drawTriangleUp($_screen,$X+$margin,$Y+$buttonHeight/2-$margin,$width-$margin*2,0,white)
	
	; DOWN
	if @button($_screen,$X,$height-$buttonHeight,$width,$buttonHeight,0,gray,"")
		$scroll += $linesOnScreen-3
		if $scroll >= $itemLines
			$scroll = $itemLines-1
		if $scroll < 0
			$scroll = 0
	@drawTriangleDown($_screen,$X+$margin,($_screen.height-$buttonHeight)+$buttonHeight/2-$margin,$width-$margin*2,0,white)
	
	var $scrollBoxTop = $buttonHeight + 2
	var $scrollBoxBottom = $height - $buttonHeight - 7
	var $scrollBoxHeight = $scrollBoxBottom - $scrollBoxTop
	var $indicatorY = $scrollBoxTop + $scrollBoxHeight * ($position/$max)
	if @button($_screen,$X,$scrollBoxTop,$width,$scrollBoxHeight+5,0,color(20,20,20),"")
		var $clickY = $_screen.click_y - $scrollBoxTop
		var $clickNormalized = $clickY / $scrollBoxHeight
		var $newScroll = min(floor($max * $clickNormalized),$max)
		print("scroll click",$clickNormalized,"new",$newScroll,"max",$max)
		$scroll = $newScroll
		;var $newScroll = 
	$_screen.draw_rect($X,$indicatorY,$X+$width,$indicatorY+5,0,white)
	
function @onColor($value:number,$on:number,$off:number):number
	if $value
		return $on
	return $off