# Crash when showing audio unit view twice

This sample demonstrates an error when showing AUAudioUnit view controller twice.

Steps to reproduce:

1. Show AUSampler
2. Play notes, change properites - this works well
3. Close AUSampler window
4. Show AUSampler again
5. Play notes, change properties - doesn't work and crashes.
