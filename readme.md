# Automatic Crafter

Automatically crafts an item, and any items required to build it.

You can queue multiple items by pressing again, or using the x10 or x100 buttons.

## Setup

Press V on the crafter and container you've already built.
Set the name of the Crafter to "Crafter"
Set the name of the Container to "Container"
(These can be changed in the code)

Connect data lines from this computer to the crafter and container.

## UI

- You can click on any ingredient item to go to that item's crafting page.
- If an ingredient in a craft is green, you have all you need to make a single item.
- Blue indicates that the ingredient will be added to the queue. It's still possible that you won't have all the mined resources you need to complete it.
- Red indicates a mined resource that's too low to complete the craft. Add some more to the container.
- The Stop button cancels the current craft, and any queued items.
- The Queue View button shows the current items in the queue. This will be updated with more needed items as the craft progresses.

## Errors
It's normal for a brief flashing "Error" message during a craft, as the missing ingredients get back filled.
If the error remains, it's likely that some mined resource is missing.

## Workshop Blueprint
https://steamcommunity.com/sharedfiles/filedetails/?id=3278744757

## Source code
If you want the code, but don't want to spawn the blueprint, the repo is here:

https://github.com/archean-cookbook/snjo-automatic-crafter