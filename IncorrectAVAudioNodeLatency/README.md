# Incorrect latency reported when using AVAudioNode's latency

This sample demonstrates incorrect latency reported by `AVAudioNode`'s latency property.

Steps to reproduce:

1. Create a simple `AVAudioEngine` graph that contains `AVAudioUnitTimePitch`
2. Start the engine
3. Update `AVAudioUnitTimePitch`'s rate to e.g. 4
4. Query the latency using `AVAudioNode`'s `latency` property
5. Query the latency using `AUAudioUnit`'s `latency` property
6. Result: `AVAudioNode`s latency is incorrectly reported
