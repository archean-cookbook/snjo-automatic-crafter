var $buttonColor = color(35,35,40)

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
		var $rect_top = $line*($ac_screen.char_h+$marginVert+$spacer*2)+$spacer
		var $rect_bottom = $rect_top + $ac_screen.char_h + $marginVert*2
		var $rect_left = $spacer
		if @button($ac_screen,$rect_left,$rect_top,$width,0,0,$buttonColor,$category,white,2) && $newclick
			$selectedCategory = $category
			print("select",$selectedCategory)
			$menulevel++
			@addHistory()
			$scroll = 0
		$line++
		$index++
		
	; FAVORITES	
	var $rect_top = $line*($ac_screen.char_h+$marginVert+$spacer*2)+$spacer
	var $rect_bottom = $rect_top + $ac_screen.char_h + $marginVert*2
	var $rect_left = $spacer
	if @button($ac_screen,$rect_left,$rect_top,$width,0,0,$buttonColor,"  Favorites & Auto Queue",white,2) && $newclick
		$showFavoriteScreen = 1
		@addHistory()
	$ac_screen.@drawHeart($rect_left+2,$rect_top+1,0)
	$rect_top += $ac_screen.char_h+$marginVert+$spacer*2
	if @button($ac_screen,$rect_left,$rect_top,$width,0,0,$buttonColor,"Settings & sleep",white,2) && $newclick
		$showSettings = 1
		@addHistory()

	$itemLines = $index
	;$ac_screen.@drawHeart(170,20,1)

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

		var $rect_top = $line*($ac_screen.char_h+$marginVert+$spacer*2)+$spacer
		var $rect_bottom = $rect_top + $ac_screen.char_h + $marginVert*2
		var $rect_left = $spacer
		var $rect_right = $ac_screen.width-2
		;print($category, $open)
		;if $ac_screen.button_rect($rect_left,$rect_top,$rect_right,$rect_bottom,0,gray)
		if @button($ac_screen,$rect_left,$rect_top,$width,0,0,$buttonColor,$craft,white,2) && $newclick
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
	;var $lineHeight = $ac_screen.char_h+$marginVert+$spacer*2
	$scrollMax = 0
	foreach $recipeInputs ($item, $amount)
		$scrollMax++
		var $category = @getCategory($item)
		if $index < $scroll || $index > $scroll+$linesOnScreen-3
			$index++
			continue
		var $rect_top = ($line+1)*$lineHeight+$spacer
		var $rect_bottom = $rect_top + $ac_screen.char_h + $marginVert*2
		var $rect_left = $spacer
		var $rect_right = $ac_screen.width-2
		;print($category, $open)
		;if $ac_screen.button_rect($rect_left,$rect_top,$rect_right,$rect_bottom,0,gray)
		var $resourceAmount = @getResource($item,$inventories);@getResource($container,$item)
		var $resourceText = ""
		if $item == "O2" || $item == "H2" || $item == "H2O"
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
		if @button($ac_screen,$rect_left,$rect_top,$width,0,0,$bgColor,$resourceText,$textColor,2) && $newclick
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

function @drawQueueBar()
	var $Y = $ac_screen.height - $lineHeight - $spacer
	$ac_screen.draw_line(2,$Y-2,$ac_screen.width-17,$Y-2,gray)
	$ac_screen.write($spacer,$Y+$spacer,gray,"Queue:")
	var $statusNum = input_number($crafter,0)
	if $statusNum < 0 &&  $queue.size > 0
		$ac_screen.write($spacer+40,$Y+$spacer,red,"Error")
	else
		$ac_screen.write($spacer+40,$Y+$spacer,white,$queue.size:text)
	
	if $showQueue == 0
		if @button($ac_screen,$spacer+70,$Y, 0, 0,0,color(50,50,100),"  VIEW  ",white,2)
			$showQueue = 1
	else
		if @button($ac_screen,$spacer+70,$Y, 0, 0,0,color(50,50,100),"  BACK  ",white,2)
			$showQueue = 0
		
	if @button($ac_screen,$spacer+125,$Y, 0, 0,0,color(200,0,0),"  STOP  ",white,2)
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
	$ac_screen.write($spacer,$spacer,white,$status)
	var $line = 1
	foreach $queue ($i,$n)
		$ac_screen.write($spacer,$spacer+$lineHeight*$line,white,$n.name)
		; var $remaining = $n.amountordered-@getResource($n.name,$inventories);@getResource($container,$n.name)
		var $remaining = $n.amountgoal-@getResource($n.name,$inventories)
		$ac_screen.write($ac_screen.width-50,$spacer+$lineHeight*$line,white,$remaining:text)
		$line++
	
function @drawCraftMenu()
	$clicked = $ac_screen.clicked
	$newclick = $clicked && !$oldclicked
	$oldclicked = $clicked
	;print("start",$selectedCategory,$selectedRecipe,$menulevel)
	var $topX = $spacer
	var $topY = $spacer
	var $topSpacing = 30
	if @button($ac_screen,$topX, $spacer, 20, 0,0,blue,"UP",white,2)
		;print("up")
		$scroll = 0
		$menuLevel--
		if $menuLevel < 0
			$menuLevel = 0

	$topX += 20+$spacer
	if @button($ac_screen,$topX, $spacer, $topSpacing, 0,0,blue,"BACK",white,2) && $newclick
		@getHistory($historyStep-1)
		;print("back")
	$topX += $topSpacing+$spacer
	if @button($ac_screen,$topX, $spacer, $topSpacing, 0,0,blue,"FORW",white,2) && $newclick
		;@updateHistoryScroll($historyStep,$scroll)
		@getHistory($historyStep+1)
		;print("forw")
	;$topX += $topSpacing+$spacer

	$topY += $lineHeight
	if $menulevel == 2
		if @button($ac_screen,$spacer, $topY, 70, 0,0,color(0,100,0),"   CRAFT   ",white,2) && $newclick
			print("----new craft---",$selectedRecipe)
			@addToQueue($selectedRecipe,1)
		if @button($ac_screen,$spacer*2+70, $topY, 30, 0,0,color(0,80,0)," x10",white,2) && $newclick
			print("----new craft---",$selectedRecipe,"x10")
			@addToQueue($selectedRecipe,10)
		if @button($ac_screen,$spacer*3+100, $topY, 0, 0,0,color(0,80,0),"x100",white,2) && $newclick
			print("----new craft---",$selectedRecipe,"x100")
			@addToQueue($selectedRecipe,100)
			;$showQueue = 1 ; optional
		if @button($ac_screen,$spacer*3+130, $topY, 0, 0,0,color(0,80,0),"x500",white,2) && $newclick
			print("----new craft---",$selectedRecipe,"x500")
			@addToQueue($selectedRecipe,500)
			;$showQueue = 1 ; optional
			;FAVORITES
		$ac_screen.@drawHeart(168,$topY+1,$favorites.$selectedRecipe)
		if $ac_screen.button_rect(167,$topY,178,$topY+11,0,0)
			$favorites.$selectedRecipe = !$favorites.$selectedRecipe
			print(text("added {} to favorites",$selectedRecipe))
	$topX += $topSpacing+$spacer*2

	$topY += $lineHeight
	if $menulevel == 0
		$ac_screen.write($topX,$spacer+$marginVert,white,$menupages.$menulevel)
		@drawCategories($ac_screen.width-15-$marginHorz)
	elseif $menulevel == 1
		$ac_screen.write($topX,$spacer+$marginVert,white,$selectedCategory)
		;print("sc",$selectedCategory)
		@drawItems($ac_screen.width-$marginHorz-15,$selectedCategory)
	elseif $menulevel == 2
		$ac_screen.write($topX,$spacer+$marginVert,white,$selectedRecipe)
		@drawRecipe($ac_screen.width-$marginHorz-15,$selectedRecipe)

function @drawAutoView($autoItem:text)
	var $addColor = color (20,60,20)
	var $subColor = color (60,10,20)
	
	var $topX = $spacer
	var $topSpacing = 30
	if @button($ac_screen,$topX,2,20,0,0,blue,"UP",white,2)
		$showAutoView = 0
	$topX += 22
	if @button($ac_screen,$topX, $spacer, $topSpacing, 0,0,blue,"BACK",white,2) && $newclick
		@getHistory($historyStep-1)
	$topX += $topSpacing+$spacer
	if @button($ac_screen,$topX, $spacer, $topSpacing, 0,0,blue,"FORW",white,2) && $newclick
		@getHistory($historyStep+1)

	$topX += $topSpacing+$spacer
	$ac_screen.write($topX,4,white," Auto craft ")
	;$ac_screen.write($ac_screen.width/2 - 10 - (size($autoItem) * $ac_screen.char_w * 0.5),20,cyan,$autoItem) ; item name
	$ac_screen.write(90 - (size($autoItem) * $ac_screen.char_w * 0.5),20,cyan,$autoItem) ; item name
	
	$ac_screen.write(60,40,white,"Maintain:")
	var $amount = $autoQueue.$autoItem:number
	$ac_screen.write(60,52,white,$amount:text)

	$ac_screen.write(60,64,white,"Current:")
	var $curAmount = @getResource($autoItem,$inventories)
	$ac_screen.write(60,76,white,$curAmount:text)
	
	var $xadd = 10
	if @button($ac_screen,$xadd,35,40,0,0,$addColor,"+1",white,2)
		$amount += 1
	if @button($ac_screen,$xadd,50,40,0,0,$addColor,"+10",white,2)
		$amount += 10
	if @button($ac_screen,$xadd,65,40,0,0,$addColor,"+100",white,2)
		$amount += 100
	if @button($ac_screen,$xadd,80,40,0,0,$addColor,"+1000",white,2)
		$amount += 1000
	
	var $xsub = 130
	if @button($ac_screen,$xsub,35,40,0,0,$subColor,"-1",white,2)
		$amount -= 1
	if @button($ac_screen,$xsub,50,40,0,0,$subColor,"-10",white,2)
		$amount -= 10
	if @button($ac_screen,$xsub,65,40,0,0,$subColor,"-100",white,2)
		$amount -= 100
	if @button($ac_screen,$xsub,80,40,0,0,$subColor,"-1000",white,2)
		$amount -= 1000
	
	if @button($ac_screen,55,110,0,0,0,orange,"   Clear  ",black,5)
		$amount = 0
		
	$amount.clamp(0,100000)
	$autoQueue.$autoItem = $amount

function @drawFavoriteList()
	var $topX = $spacer
	var $topSpacing = 30
	if @button($ac_screen,$topX,2,20,0,0,blue,"UP",white,2)
		$showFavoriteScreen = 0
	$topX += 22
	if @button($ac_screen,$topX, $spacer, $topSpacing, 0,0,blue,"BACK",white,2) && $newclick
		@getHistory($historyStep-1)
	$topX += $topSpacing+$spacer
	if @button($ac_screen,$topX, $spacer, $topSpacing, 0,0,blue,"FORW",white,2) && $newclick
		@getHistory($historyStep+1)
	$topX += $topSpacing+$spacer
	$ac_screen.write($topX,$spacer+2,white,"Favorites")
	var $favCount = 0
	foreach $favorites ($favName,$faved)
		if $faved	
			$favCount++
	$scrollMax = 0
	
	var $line = 1
	var $index = 0
	$itemLines = $favCount
	$scrollMax = 0
	
	foreach $favorites ($favName,$faved)
		if $faved
			$scrollMax++
			if $index < $scroll || $index > $scroll+$linesOnScreen-2
				$index++
				continue
		
			var $rect_top = $line*($ac_screen.char_h+$marginVert+$spacer*2)+$spacer
			var $rect_bottom = $rect_top + $ac_screen.char_h + $marginVert*2
			var $rect_left = $spacer
			var $rect_right = $ac_screen.width-2
			$ac_screen.@drawHeart($spacer,$rect_top+1,$favorites.$favName)
			if @button($ac_screen,1,$rect_top,11,11,0,0,"",white,2) ; heart button
				print("unfave ",$favName)
				$favorites.$favName = 0
				$favorites.@flushzero()
				$autoQueue.$favName = 0
			if @button($ac_screen,12,$rect_top,130,11,0,color(60,60,60),$favName,white,2) ; jump to item button
				$selectedRecipe = $favName
				$selectedCategory = @getCategory($favName)
				$showFavoriteScreen = 0
				$menuLevel = 2
				$scroll = 0
				@addHistory()
			if @button($ac_screen,145,$rect_top,35,11,0,@onColor($autoQueue.$favName > 0, green, gray),"Auto",black,2) ; auto button
				print("auto menu")
				$showAutoView = 1
				$favItemSelected = $favName
				@addHistory()
			$favCount++
			$line++
			$index++
	if $favCount == 0
		$ac_screen.write(5,40,white,"No favorites added\n\nPress   on a craft to add\na favorite")
		$ac_screen.@drawHeart(40,55,0)
	;foreach $favorite

function @drawFavoriteScreen()
	if $showAutoView
		@drawAutoView($favItemSelected)
	else
		@drawFavoriteList()
		
function @drawSettings()
	var $topX = $spacer
	var $topSpacing = 30
	if @button($ac_screen,$topX,2,20,0,0,blue,"UP",white,2)
		$showSettings = 0
	$topX += 22
	if @button($ac_screen,$topX, $spacer, $topSpacing, 0,0,blue,"BACK",white,2) && $newclick
		@getHistory($historyStep-1)
	$topX += $topSpacing+$spacer
	if @button($ac_screen,$topX, $spacer, $topSpacing, 0,0,blue,"FORW",white,2) && $newclick
		@getHistory($historyStep+1)
	$topX += $topSpacing+$spacer
	$ac_screen.write($topX,$spacer+2,white,"Settings")
	var $bw = 100
	$ac_screen.write($spacer,20,white,"Go to sleep after:")
	if @button($ac_screen,$spacer,35,$bw,0,0,@onColor($sleepTime==300 && $allowSleepMode,blue,$buttonColor),"5 minutes",white,2)
		$sleepTime = 300
		$allowSleepMode = 1
	if @button($ac_screen,$spacer,50,$bw,0,0,@onColor($sleepTime==900 && $allowSleepMode,blue,$buttonColor),"15 minutes",white,2)
		$sleepTime = 900
		$allowSleepMode = 1
	if @button($ac_screen,$spacer,65,$bw,0,0,@onColor($sleepTime==1800 && $allowSleepMode,blue,$buttonColor),"30 minutes",white,2)
		$sleepTime = 1800
		$allowSleepMode = 1
	if @button($ac_screen,$spacer,80,$bw,0,0,@onColor($allowSleepMode==0,blue,$buttonColor),"Never",white,2)
		$allowSleepMode = 0
	;if @button($spacer,95,$bw,0,0,@onColor($sleepTime==5 && $allowSleepMode,blue,$buttonColor),"test: 5s",white,2)
	;	$sleepTime = 5
	;	$allowSleepMode = 1
	if @button($ac_screen,$spacer,110,$bw,0,0,@onColor($allowSleepMode==0,blue,$buttonColor),"Sleep now",white,2)
		$allowSleepMode = 1
		$sleepLastClick = 0 ; 1970
		$forceSleep = 1
	
	