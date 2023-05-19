# SwiftUI List memory leak

A demonstration of SwiftUI memory leak when using lists

## Steps to reproduce

1. Delete an item from the list
2. Observe that dealloc is never called
