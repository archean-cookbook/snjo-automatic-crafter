; Set you external screen here if you use this HDD in a mini computer.
var $ac_screen = screen
;var $ac_screen = screen("external_screen",0)


var $delay = 30
array $quotes : text
var $quote = "..."

function @getQuote($num:number):text
	return $quotes.$num

init
	print("BIOS boot")
	print("Screen:",$ac_screen.width,"x",$ac_screen.height)
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
	return size($text)*$ac_screen.char_w

function @getTextHalfWidth($text:text):number
	return @getTextWidth($text) / 2

update
	$ac_screen.blank(black)
	$delay--
	var $title = "Automatic Crafter"
	var $by = "by Snjo"
	var $centerX = $ac_screen.width/2
	$ac_screen.write($centerX-@getTextHalfWidth($title),60,cyan,$title)
	$ac_screen.write($centerX-@getTextHalfWidth($by),70,cyan,$by)
	$ac_screen.write($centerX-@getTextHalfWidth($quote),90,gray,$quote)
	if $delay < 0
		load_program("crafter")
