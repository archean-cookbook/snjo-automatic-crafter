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

function @getResourceOld($container:text,$name:text):number
	var $stockText = input_text($container,0)
	;print("container",$name,$stockText.$name:number)
	return $stockText.$name:number	

function @getResource($name:text,$inventories:text):number
	var $items = ""
	var $O2 = 0
	var $H2 = 0
	var $H2O = 0
	var $gasFallback = 0
	foreach $inventories ($i,$n)
		;print("inv",$i,$n)
		if contains($n,"tank")
			var $amount = input_text($n,0)
			if contains($n,"O2")
				$O2 += $amount
				;print("O2",$n,$amount)
			elseif contains($n,"H2O") ; must be before H2, since H2O contains H2
				;print("H2O",$n,$amount)
				$H2O += $amount
			elseif contains($n,"H2")
				$H2 += $amount
				;print("H2",$n,$amount)
			else ; very rough split in half, not accurate
				$gasFallback = $amount/2
		else
			if input_number($n, 0) > 0 ; Check if inventory has items
				var $_items = input_text($n, 0)
				foreach $_items ($_i, $_item)
					if $items.$_i ; If the item already exists, add to it
						$items.$_i += $_item
					else ; Otherwise, create a new entry
						$items = $items & "." & $_i & "{" & $_item & "}"
			;$items = input_text($n,0)
	if $gasFallback > 0 && $O2 <= 0 && $H2 <= 0
		$O2 = $gasFallback
		$H2 = $gasFallback
		print("using fallback split gas value since there aren't separate tanks")
	$items.O2 = $O2
	$items.H2 = $H2
	$items.H2O = $H2O
	return $items.$name:number

function @getResourceBasic($container:text,$resourceName:text):number
	var $items = input_text($container,0)
	return $items.$resourceName:number
	
function @drawHeart($_screen:screen,$X:number,$Y:number,$filled:number)
	var $lineColor = red
	if $filled
		$_screen.draw_rect($X+1,$Y+1,$X+8,$Y+6,0,pink)
		$_screen.draw_rect($X+3,$Y+6,$X+6,$Y+8,0,pink)
	$_screen.draw_line($X+1,$Y,$X+4,$Y,$lineColor)
	$_screen.draw_point($X+4,$Y+1,$lineColor)
	$_screen.draw_line($X+5,$Y,$X+8,$Y,$lineColor)
	
	$_screen.draw_line($X,$Y+1,$X,$Y+5,$lineColor)
	$_screen.draw_line($X+8,$Y+1,$X+8,$Y+5,$lineColor)

	$_screen.draw_line($X+1,$Y+5,$X+5,$Y+9,$lineColor)
	$_screen.draw_line($X+7,$Y+5,$X+3,$Y+9,$lineColor)
	
function @flushzero($kvpsource:text):text
	var $kvpresult = ""
	; remove entries in $kvpsource, return a new kvp with only non-zero values.
	; in use: $favorites.@flushzero()
	foreach $kvpsource ($i,$n)
		if $n != 0
			$kvpresult.$i = $n
	return $kvpresult
		

