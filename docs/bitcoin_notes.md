* run a bitcoin full node
* in bitcoin.conf set prune=550.
 - this way we only keep track of the recent 550mb of blocks.
* maybe set dbcache=1000 if we have 4 gb ram, or 4000 if we have 8 gb of ram.