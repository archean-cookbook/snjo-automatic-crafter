; ADD THIS TO THE MAIN UPDATE LOOP
; 	var $sleep = @checkGoToSleep()
;	if $sleep 						; check if last click happened some time ago
;									; or if there's an additional condition: if $sleep && !$_isCrafting
;		if !$oldSleep 				; ensures that the sleep screen is only drawn once, saving even more compute power
;			@drawSleepScreen() 		; sleep mode screen
;		$oldSleep = $sleep			; used next tick to see if sleep mode was a new state or ongoing
;		return 						; don't run the rest of the update loop
;	elseif $wakeDelay > 0 			; delay allowing clicks after waking with the screen, prevents accidental menu clicks
;		$wakeDelay-- 				; allow the normal update loop when this reaches 0 (1 tick)
;		return
;   $oldSleep = $sleep


var $allowSleepMode = 1 ; set this to 0 to never allow sleep mode screen
var $sleepLastClick = 0 ; set whenever a user clicks the screen
storage var $sleepTime : number	; seconds, 300 is 5 minutes, set in init
						; After this time has elapsed, the crafting computer and optionally the crafter box turns off if no craft is active (not counting failed crafts due to resources lacking)
						; When waking up, the failed craft resumes trying.
var $oldSleep = 0
var $sleep = 0			; used in the main update loop example above
var $forceSleep = 0     ; used by the "sleep now" option

function @checkGoToSleep():number
	;print("sleep check",$sleep,$sleepLastClick,$sleepTime)
	if time > $sleepLastClick + $sleepTime && $allowSleepMode
		output_number($crafterRelay,0,0) ; turn off crafter
		;print("go to sleep")
		return 1
	return 0

function @resetSleepActivity()
	if @checkGoToSleep() ; am I returning from sleep, if so disallow clicks to UI for the next tick
		$wakeDelay = 1
	$sleepLastClick = time
	output_number($crafterRelay,0,1) ; turn on crafter
	
function @drawSleepScreen()
	$screen.blank()
	$screen.text_size(1)
	$screen.write(45,60,cyan,"Automatic Crafter")
	$screen.write(45,70,orange,"Sleeping to save power")
	$screen.write(45,90,orange,"Click to wake")
		
;click ; changed from click to update to work on external screens.
update
	if $screen.clicked
		; print("awaken?, force sleep:",$forcesleep)
		if $forceSleep == 1 ; prevents waking right up when clicking "sleep now". Only worked when "click" was in use.
			; print("disable force sleep")
			$forceSleep = 0
		else
			@resetSleepActivity()
