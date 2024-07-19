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
			;print("too few of",$ingredient,"need",$diff,"requested",$required,"have",$available);,"ingAm",$ingredientAmount,"recAm",$recipeamount)
			if @getCategory($ingredient) == ""
				;print("skipping mineral, not added to queue")
			else
				;print("adding ingredient to queue:",$ingredient,"x" & $diff:text)
				$result.$ingredient = $diff
				return $result
	return ""

function @addToQueueNewItem($name:text,$amount:number)
	print("added to queue",$name,$amount)
	var $new = ""
	$new.name = $name
	$new.amountordered = $amount ; - @getResource($container,$name)
	;$new.amountgoal = $amount + @getResource($container,$name)
	$new.amountgoal = $amount + @getResource($name,$inventories)
	$queue.append($new)

function @addToQueueExistingItem($name:text,$amount:number):number
	foreach $queue ($i,$n)
		if $n.name == $name
			var $new = $n
			$new.amountordered += $amount
			$new.amountgoal += $amount ;$new.amountordered + @getResource($name,$inventories)
			;print(text("erase queue item at: {} size: {}",$i,$queue.size))
			$queue.erase($i)
			;print(text("insert queue item at: {} size: {}",$i,$queue.size))
			$queue.append($new)
			;print(text("queue size now: {}",$queue.size))
			;print("Add to existing queue item", $n,$i,$new.amountordered,$new.amountgoal)
			;print("queue item now", $queue.$i)
			return 1
	return 0

function @addToQueue($name:text,$amount:number)
	if @addToQueueExistingItem($name,$amount) == 0
		@addToQueueNewItem($name,$amount)

function @updateAutoQueue()
	if $queue.size > 0
		print("skipping auto queue, already crafting")
		return
	foreach $autoQueue ($autoitem,$autoamount)
		if $autoamount < 1
			;print("auto with 0 set")
			continue
		;print("auto ",$autoitem,$autoamount)
		var $current = @getResource($autoitem,$inventories)

		if $current < $autoamount && $queue.size < 1
			var $missing = $autoamount - $current
			@addToQueue($autoitem,$missing)
			print("added to queue:", $autoitem, $missing)
		
function @lastItem():text
	var $qi = $queue.size-1
	var $queueItem = $queue.$qi
	return $queueItem