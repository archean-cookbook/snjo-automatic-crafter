include "craftfunctions.xc"
const $crafter = "crafter"
;const $container = "container"
var $inventories = ".a{container}.b{tank_O2}.c{tank_H2}.d{tank_H2O}.e{tank_1}"
var $crafterRelay = "crafter_relay" ; if present and connected, turns off crafter power when in sleep mode
storage var $favorites : text
storage var $autoqueue : text
; it's optional to place separate O2 and H2 tanks.
; If you have one, all or none of the tanks above, the code just counts from the ones it finds

var $wakeDelay = 0
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
var $showFavoriteScreen = 0
var $showQueue = 0
var $showAutoView = 0
var $favItemSelected = ""
var $showSettings = 0

var $lineHeight = 12

include "history.xc"
include "ui.xc"
include "queue.xc"
include "sleep.xc"
include "drawmenus.xc"

			
init
	@resetSleepActivity()
	if $sleepTime == 0 ; storage value not set
		$sleepTime = 300
		print("set initial sleep time, saved to storage")
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

; CRAFTING ON TICK
var $queueWaitBetween = 5
var $queueCountdown = 5
var $craftingActive = 0
function @resetCountdown()
	$queueCountdown = $queueWaitBetween
	
function @countDown()
	if $queueCountdown > 0
		$queueCountdown--

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

tick
	var $_progress = input_number($crafter,0)
	var $_isCrafting = abs($_progress) != 1 && $_progress != 0
	$sleep = @checkGoToSleep()

	if $sleep && !$_isCrafting;; check if last click happened some time ago
		if !$oldSleep  ; ensures that the sleep screen is only drawn once, saving even more compute power
			@drawSleepScreen() ; sleep mode screen
		return ; don't run the rest of the update loop
	elseif $wakeDelay > 0 ; delay allowing clicks after waking with the screen, prevents accidental menu clicks
		$wakeDelay-- ; allow the normal update loop when this reaches 0 (1 tick)
		return
	$oldSleep = $sleep
	
	blank()
	text_size(1)
	
	;DRAW UI
	$lineHeight = $screen.char_h + $spacer + $marginVert*2
	if $showQueue == 1
		@drawQueueView()
	elseif $showFavoriteScreen
		@drawFavoriteScreen()
	elseif $showSettings
		@drawSettings()
	else
		@drawCraftMenu()

	@drawQueueBar()
	
	@drawScrollBar(screen_w-16,1,15,screen_h-2,$scroll,$scrollMax)
	
	; CRAFT PRODUCTS
	;@crafting()
	@updateCrafting()

timer interval 5
	;print("auto queue", time, $autoqueue.size > 0)
	@updateAutoQueue()
		