# File decoder error

This sample demonstrates an error when loading many audio files at the same time. Audio files need to be alac encoded.

This error was originally discovered when using `AVAudioUnitSampler` which loads these files under the hood.

This crash is only happening on iOS 18 and not on previous iOS versions.
