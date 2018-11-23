xendit-sdk-ios-src

### Running Tests

1. Install [Carthage](https://github.com/Carthage/Carthage) (if you have homebrew installed, `brew install carthage`)
2. In console open repository root folder and install test dependencies by running `carthage bootstrap --platform ios --no-use-binaries`
3. Open `Xendit.xcworkspace`

To run UI tests: choose `Xendit` scheme and press `cmd+u` (or "Run Product" -> "Test")
To run unit tests: choose `XenditExample` scheme and press `cmd+u`
