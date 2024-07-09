function @addHistory()
	var $now = ""
	$now.category = $selectedCategory
	$now.recipe = $selectedRecipe
	$now.menulevel = $menulevel
	$now.showFavorites = $showFavoriteScreen
	$now.showAutoView = $showAutoView
	$now.favItemSelected = $favItemSelected
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
	$showFavoriteScreen = $set.showFavorites
	$showAutoView = $set.showAutoView
	$favItemSelected = $set.favItemSelected
	print("jump to history",$historyStep,$set)
	
function @updateHistoryScroll($step:number,$scrollValue:number)
	if  $step >= $history.size
		return
	var $newHistoryEntry = $history.$step
	$newHistoryEntry.scroll = $scroll
	print("updated scroll on entry",$step,$newHistoryEntry)
	$history.$step = $newHistoryEntry
