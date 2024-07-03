include "craftfunctions.xc"
const $crafter = "crafter"
;const $container = "container"
var $inventories = ".a{container}.b{tank_O2}.c{tank_H2}.d{tank_1}"
; it's optional to place separate O2 and H2 tanks.
; If you have one, all or none of the tanks above, the code just counts from the ones it finds

var $scroll = 0
var $scrollMax = 100
var $currentCraft:text
var $categories:text
var $screen = screen
var $marginHorz = 5 ;distance from text to edge of button
var $marginVert = 2 ;distance from text to edge of button
var $spacer = 2 ; distance between buttons
var $selectedCategory = ""
var $selectedRecipe = ""
array $menupages : text
var $menuLevel = 0
var $clicked = 0
var $oldclicked = 0
var $newclick = 0
array $recipeLibrary : text
array $history:text
var $historyStep = 0
var $upX : number
var $upY : number
var $downX : number
var $downY : number
var $linesOnScreen : number
var $itemLines = 0
array $queue : text

var $lineHeight = 12

function @addHistory()
	var $now = ""
	$now.category = $selectedCategory
	$now.recipe = $selectedRecipe
	$now.menulevel = $menulevel
	;$now.scroll = $scroll
	print("add history",$now)
	var $historyLast = $history.size-1
	;print("history step",$historyStep,"< size",$historyLast)
	if $historyStep < $historyLast
		;print("not at end")
		var $cull = $historyLast-$historyStep
		repeat $cull ($i)
			$historyLast = $history.size-1
			;print($i,"cull loop",$historyStep,"size pre",$history.size)
			var $content = $history.$historyStep
			;print("cull",$content.recipe)
			if $historyLast > 0 && $history.size > 0
				$history.erase($historyLast)
		;print("Replace history at ",$historyStep,"last",$historyLast)			

	$history.append($now)
	$historyStep = $history.size-1
	;print("Appending to history, new size:",$history.size)

function @getHistory($number:number)
	if $number < 0
		return
	if $number >= $history.size
		return
	$historyStep = $number
	;print("history",$history.size,$historyStep)
	var $set = $history.$historyStep
	;print("history content",$set.category,$set.recipe,$set.menulevel)
	$selectedCategory = $set.category
	$selectedRecipe = $set.recipe
	$menulevel = $set.menulevel
	$scroll = $set.scroll
	print("jump to history",$historyStep,$set)
	
function @updateHistoryScroll($step:number,$scrollValue:number)
	if  $step >= $history.size
		return
	var $newHistoryEntry = $history.$step
	$newHistoryEntry.scroll = $scroll
	print("updated scroll on entry",$step,$newHistoryEntry)
	$history.$step = $newHistoryEntry


function @getLibraryItem($name:text):text
	foreach $recipeLibrary ($i,$value)
		if $value.name == $name
			;print("found",$name,$value.name,$value.category,$value.recipe)
			return $value
	;print("couldn't find",$name)
	return ""

function @getCategory($name:text):text
	var $cat = @getLibraryItem($name)
	return $cat.category
	
function @getRecipe($name:text):text
	var $rec = @getLibraryItem($name)
	return $rec.recipe

function @checkRecipe($name:text,$recipeamount:number):text
	var $recipe = @getRecipe($name)
	var $result = ""
	foreach $recipe ($ingredient,$ingredientAmount)
		var $required = $ingredientAmount * $recipeamount
		var $available = @getResource($ingredient,$inventories);@getResource($container,$ingredient)
		if $available < $required
			var $diff = $required-$available
			print("too few of",$ingredient,"need",$diff,"requested",$required,"have",$available);,"ingAm",$ingredientAmount,"recAm",$recipeamount)
			if @getCategory($ingredient) == ""
				print("skipping mineral, not added to queue")
			else
				print("adding ingredient to queue:",$ingredient,"x" & $diff:text)
				$result.$ingredient = $diff
				return $result
	return ""

recursive function @addToQueue($name:text,$amount:number)
	print("added to queue",$name,$amount)
	var $new = ""
	$new.name = $name
	$new.amountordered = $amount ; - @getResource($container,$name)
	;$new.amountgoal = $amount + @getResource($container,$name)
	$new.amountgoal = $amount + @getResource($name,$inventories)
	$queue.append($new)

recursive function @addToQueueOld($name:text,$amount:number)
	var $new = ""
	$new.name = $name
	$new.amount = $amount
	$queue.append($new)
	;$queue.insert(-1,$new)
	var $recipe = @getRecipe($name)
	foreach $recipe ($ingredient,$n)
		var $required = $n * $amount
		var $available = @getResource($ingredient,$inventories);@getResource($container,$ingredient)
		if $available < $required
			var $diff = $required-$available
			;print("too few of",$ingredient,"need",$diff)
			if @getCategory($ingredient) == ""
				print("skipping mineral, not added to queue")
			else
				;print("adding ingredient to queue:",$ingredient,"x" & $diff:text)
				recurse($ingredient,$required);$diff) ; calls @addToQueue, but the recurse needs to NOT have its own name in the line

function @orderItemOld($name:text,$amount:number):text
	var $instock = @getResource($name,$inventories);@getResource($container,$name)
	if $instock < $amount
		@start_craft($crafter,$name)
		return "crafting"
	else
		print("done, in stock:", $instock:text, "requested:" ,$amount:text)
		@cancel_craft($crafter)
		return "done"
	
init
	$linesOnScreen = floor($screen.height / ($screen.char_h + $spacer + $marginvert*2))-1
	print("lines on screen",$linesOnScreen)
	$upX = $screen.width-14
	$upY = $screen.height/4
	$downX = $screen.width-14
	$downY = $screen.height*3/4-2
	$menupages.append("Categories","Items","Craft","Subcraft")
	array $recipesCategories : text
	$recipesCategories.from(get_recipes_categories($crafter), ",") ; get categories
	
	;create recipe library
	foreach $recipesCategories ($catnum, $category)
		$categories.$category = 0 ;collapse category
		array $items:text
		$items.from(get_recipes($crafter, $category), ",")
		foreach $items ($i, $craftname)
			;print($catnum,$i,$craftname,$category)
			var $recipeInfo = ""
			$recipeInfo.name = $craftname
			$recipeInfo.category = $category
			var $rec = get_recipe($crafter, $category, $craftname)
			$recipeInfo.recipe = $rec
			;print(":::",$recipeInfo.category,$recipeInfo.recipe,size($recipeInfo),size($rec))
			$recipeLibrary.append($recipeInfo)
	;test library
	;print("test Iron",@getCategory("Iron"),@getRecipe("Iron"))
	
	@addHistory()


function @drawCategories($width:number)
	var $line = 1
	var $index = 0
	$scrollMax = 0;size($categories)
	;print("cat max",$scrollMax ,$categories)
	foreach $categories ($category, $open)
		$scrollMax++
		if $index < $scroll || $index > $scroll+$linesOnScreen-2
			$index++
			continue
		var $rect_top = $line*($screen.char_h+$marginVert+$spacer*2)+$spacer
		var $rect_bottom = $rect_top + $screen.char_h + $marginVert*2
		var $rect_left = $spacer
		if @button($rect_left,$rect_top,$width,0,0,gray,$category,white,2) && $newclick
			$selectedCategory = $category
			print("select",$selectedCategory)
			$menulevel++
			@addHistory()
			$scroll = 0
		$line++
		$index++
	$itemLines = $index
		
function @drawItems($width:number,$category:text)
	array $items:text
	$items.from(get_recipes($crafter, $category), ",") ; get recipes in category
	var $line = 1
	var $index = 0
	$itemLines = $items.size
	$scrollMax = 0
	foreach $items ($craftindex, $craft)
		$scrollMax++
		;print("index",$index,"scroll",$scroll
		if $index < $scroll || $index > $scroll+$linesOnScreen-2
			$index++
			continue

		var $rect_top = $line*($screen.char_h+$marginVert+$spacer*2)+$spacer
		var $rect_bottom = $rect_top + $screen.char_h + $marginVert*2
		var $rect_left = $spacer
		var $rect_right = $screen.width-2
		;print($category, $open)
		;if $screen.button_rect($rect_left,$rect_top,$rect_right,$rect_bottom,0,gray)
		if @button($rect_left,$rect_top,$width,0,0,gray,$craft,white,2) && $newclick
			;$categories.$category = !$categories.$category
			@updateHistoryScroll($historyStep,$scroll)
			print("select",$craft)
			$selectedRecipe = $craft
			$menulevel++
			@addHistory()
			$scroll = 0
		$line++
		$index++
		
function @drawRecipe($width:number,$recipe:text)
	var $recipeInputs = get_recipe($crafter, $selectedCategory, $selectedRecipe)
	var $line = 1
	var $index = 0
	;var $lineHeight = $screen.char_h+$marginVert+$spacer*2
	$scrollMax = 0
	foreach $recipeInputs ($item, $amount)
		$scrollMax++
		var $category = @getCategory($item)
		if $index < $scroll || $index > $scroll+$linesOnScreen-3
			$index++
			continue
		var $rect_top = ($line+1)*$lineHeight+$spacer
		var $rect_bottom = $rect_top + $screen.char_h + $marginVert*2
		var $rect_left = $spacer
		var $rect_right = $screen.width-2
		;print($category, $open)
		;if $screen.button_rect($rect_left,$rect_top,$rect_right,$rect_bottom,0,gray)
		var $resourceAmount = @getResource($item,$inventories);@getResource($container,$item)
		var $resourceText = ""
		if $item == "O2" || $item == "H2"
			var $percent = $resourceAmount*100
			$resourceText = text("{} tank at {0.00}% / {}",$item,$percent,$amount)

		else
			$resourceText = text("{} {} / {}",$item,$resourceamount,$amount)
		var $bgColor = color(30,100,30) ; green, is available
		var $textColor = white
		if $resourceAmount < $amount
			if $category == ""
				$bgColor = color(255,0,0) ; red, mineral missing, mine more
			else
				$bgColor = color(50,50,70) ; blue, will be sub-crafted

		if $category == ""
			$textColor = black
		if @button($rect_left,$rect_top,$width,0,0,$bgColor,$resourceText,$textColor,2) && $newclick
			;$categories.$selectedCategory = !$categories.$selectedCategory
			print("select item ",$item)
			if 	$category != ""
				$selectedRecipe = $item
				print("cat from item",$selectedRecipe,$category)
				$selectedCategory = $category
			else
				print("can't craft item",$item)
			@addHistory()
			$scroll = 0
		$line++
		$index++
	$itemLines = $index

var $showQueue = 0
function @drawQueueBar()
	var $Y = $screen.height - $lineHeight - $spacer
	$screen.draw_line(2,$Y-2,$screen.width-17,$Y-2,gray)
	$screen.write($spacer,$Y+$spacer,gray,"Queue:")
	var $statusNum = input_number($crafter,0)
	if $statusNum < 0 &&  $queue.size > 0
		$screen.write($spacer+40,$Y+$spacer,red,"Error")
	else
		$screen.write($spacer+40,$Y+$spacer,white,$queue.size:text)
	
	if $showQueue == 0
		if @button($spacer+70,$Y, 0, 0,0,color(50,50,100),"  VIEW  ",white,2)
			$showQueue = 1
	else
		if @button($spacer+70,$Y, 0, 0,0,color(50,50,100),"  BACK  ",white,2)
			$showQueue = 0
		
	if @button($spacer+125,$Y, 0, 0,0,color(200,0,0),"  STOP  ",white,2)
	;if @button(10,100,100,10,0,red,"STOP",white,2)
		@cancel_craft($crafter)
		$queue.clear()

function @drawQueueView()
	var $statusNum = input_number($crafter,0)
	;print("status",$statusNum)
	var $status = ""
	if $statusNum >= 1
		$status = "Status: Done"
	elseif $statusNum < 0 && $queue.size > 0
		$status = "Status: Missing resources"
	elseif $queue.size > 0
		var $statusPercent = floor($statusNum*100)
		$status = text("Status: {}%", $statusPercent)
	else
		$status = "Queue is empty"
	$screen.write($spacer,$spacer,white,$status)
	var $line = 1
	foreach $queue ($i,$n)
		$screen.write($spacer,$spacer+$lineHeight*$line,white,$n.name)
		var $remaining = $n.amountordered-@getResource($n.name,$inventories);@getResource($container,$n.name)
		$screen.write($screen.width-50,$spacer+$lineHeight*$line,white,$remaining:text)
		$line++
	
function @drawCraftMenu()
	$clicked = $screen.clicked
	$newclick = $clicked && !$oldclicked
	$oldclicked = $clicked
	;print("start",$selectedCategory,$selectedRecipe,$menulevel)
	var $topX = $spacer
	var $topY = $spacer
	var $topSpacing = 30
	if @button($topX, $spacer, 20, 0,0,blue,"UP",white,2)
		;print("up")
		$scroll = 0
		$menuLevel--
		if $menuLevel < 0
			$menuLevel = 0

	$topX += 20+$spacer
	if @button($topX, $spacer, $topSpacing, 0,0,blue,"BACK",white,2) && $newclick
		@getHistory($historyStep-1)
		;print("back")
	$topX += $topSpacing+$spacer
	if @button($topX, $spacer, $topSpacing, 0,0,blue,"FORW",white,2) && $newclick
		;@updateHistoryScroll($historyStep,$scroll)
		@getHistory($historyStep+1)
		;print("forw")
	;$topX += $topSpacing+$spacer

	$topY += $lineHeight
	if $menulevel == 2
		if @button($spacer, $topY, 70, 0,0,color(0,100,0),"   CRAFT   ",white,2) && $newclick
			print("----new craft---",$selectedRecipe)
			@addToQueue($selectedRecipe,1)
		if @button($spacer*2+70, $topY, 30, 0,0,color(0,80,0)," x10",white,2) && $newclick
			print("----new craft---",$selectedRecipe,"x10")
			@addToQueue($selectedRecipe,10)
		if @button($spacer*3+100, $topY, 0, 0,0,color(0,80,0),"x100",white,2) && $newclick
			print("----new craft---",$selectedRecipe,"x100")
			@addToQueue($selectedRecipe,100)
			;$showQueue = 1 ; optional
	$topX += $topSpacing+$spacer*2

	$topY += $lineHeight
	if $menulevel == 0
		$screen.write($topX,$spacer+$marginVert,white,$menupages.$menulevel)
		@drawCategories($screen.width-15-$marginHorz)
	elseif $menulevel == 1
		$screen.write($topX,$spacer+$marginVert,white,$selectedCategory)
		;print("sc",$selectedCategory)
		@drawItems($screen.width-$marginHorz-15,$selectedCategory)
	elseif $menulevel == 2
		$screen.write($topX,$spacer+$marginVert,white,$selectedRecipe)
		@drawRecipe($screen.width-$marginHorz-15,$selectedRecipe)

; CRAFTING ON TICK
var $queueWaitBetween = 5
var $queueCountdown = 5
var $craftingActive = 0
function @resetCountdown()
	$queueCountdown = $queueWaitBetween
	
function @countDown()
	if $queueCountdown > 0
		$queueCountdown--

function @lastItem():text
	var $qi = $queue.size-1
	var $queueItem = $queue.$qi
	return $queueItem

function @updateCrafting()
	if $queueCountdown > 0
		@countDown()
		;print("queue countdown",$queuecountdown)
		return
	if $queue.size < 1
		;print("no items in queue")
		return
	;var $firstItem = $queue.0
	var $lastItem = @lastItem()
	var $progress = input_number($crafter,0)
	var $isCrafting = abs($progress) != 1 && $progress != 0
	;var $neededItems = $lastItem.amountgoal - (@getResource($container,$lastItem.name)+$isCrafting)
	var $neededItems = $lastItem.amountgoal - (@getResource($lastItem.name,$inventories)+$isCrafting)
	
	;print("Crafting queue",$queue.size,$lastItem.name,"ordered",$lastItem.amountordered,"goal",$lastItem.amountgoal,"needed",$neededItems,"progress",$progress)
	if $neededItems > 0
		var $missing = @checkRecipe($lastItem.name,$neededItems);$lastItem.amountordered)
		foreach $missing ($i,$a)
			@addToQueue($i,$a)
		$lastItem = @lastItem()
		@start_craft($crafter,$lastItem.name)
	elseif $isCrafting && @getResource($lastItem.name,$inventories) < $lastItem.amountgoal
		; finish this craft
		print("continue craft")
	else
		@resetCountdown()
		@cancel_craft($crafter)
		var $last = $queue.size-1
		var $removed = $queue.$last
		print("queue item done, removing",$removed)
		$queue.erase($queue.size-1)
	@countDown()


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
	@drawTriangleDown($X+$margin,(screen_h-$buttonHeight)+$buttonHeight/2-$margin,$width-$margin*2,0,white)
	
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
	draw_rect($X,$indicatorY,$X+$width,$indicatorY+5,0,white)
		
tick
	blank()
	text_size(1)
	
	;DRAW UI
	$lineHeight = $screen.char_h + $spacer + $marginVert*2
	if $showQueue == 1
		@drawQueueView()
	else
		@drawCraftMenu()

	@drawQueueBar()
	
	@drawScrollBar(screen_w-16,1,15,screen_h-2,$scroll,$scrollMax)
	
	; CRAFT PRODUCTS
	;@crafting()
	@updateCrafting()

		
		