var $delay = 30
var $screen = screen
array $quotes : text
var $quote = "..."

function @getQuote($num:number):text
	return $quotes.$num

init
	print("BIOS boot")
	print("Screen:",$screen.width,"x",$screen.height)
	;quotes
	$quotes.append("Welcome!")
	$quotes.append("Reticulating splines...")
	$quotes.append("Pre-heating crafter...")
	$quotes.append("Touching grass...")
	$quotes.append("Deleting coffee recipes...")
	$quotes.append("Accepting cookies...")
	var $rand = random(0, $quotes.size-1)
	$quote = @getQuote($rand)
	
function @getTextWidth($text:text):number
	return size($text)*$screen.char_w

function @getTextHalfWidth($text:text):number
	return @getTextWidth($text) / 2

update
	$screen.blank(black)
	$delay--
	var $title = "Automatic Crafter"
	var $by = "by Snjo"
	var $centerX = $screen.width/2
	$screen.write($centerX-@getTextHalfWidth($title),60,cyan,$title)
	$screen.write($centerX-@getTextHalfWidth($by),70,cyan,$by)
	$screen.write($centerX-@getTextHalfWidth($quote),90,gray,$quote)
	if $delay < 0
		load_program("crafter")
