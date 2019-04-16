# xendit-sdk-ios-src

## Ownership

Team: [TPI Team](https://www.draw.io/?state=%7B%22ids%22:%5B%221Vk1zqYgX2YqjJYieQ6qDPh0PhB2yAd0j%22%5D,%22action%22:%22open%22,%22userId%22:%22104938211257040552218%22%7D)

Slack Channel: [#integration-product](https://xendit.slack.com/messages/integration-product)

Slack Mentions: `@troops-tpi`

### Running Tests

1. Install [Carthage](https://github.com/Carthage/Carthage) (if you have homebrew installed, `brew install carthage`)
2. In console open repository root folder and install test dependencies by running `carthage bootstrap --platform ios --no-use-binaries`
3. Open `Xendit.xcworkspace`

To run UI tests: choose `Xendit` scheme and press `cmd+u` (or "Run Product" -> "Test")
To run unit tests: choose `XenditExample` scheme and press `cmd+u`
