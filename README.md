# Xendit iOS SDK

Xendit iOS SDK is compatible with CocoaPods and Swift Package Manager, and provides target for consumption: `Xendit`.

## Ownership

Team: [Credit Cards Team](https://www.draw.io/?state=%7B%22ids%22:%5B%221Vk1zqYgX2YqjJYieQ6qDPh0PhB2yAd0j%22%5D,%22action%22:%22open%22,%22userId%22:%22104938211257040552218%22%7D)

Slack Channel: [#p-cards-product](https://xendit.slack.com/messages/p-cards-product)

Slack Mentions: `@troops-cards`

## Usage

Note that starting version 3.10.0, it requires minimum version of iOS 11. If you still want to support iOS 9, you may use [version 3.9.2](https://github.com/xendit/xendit-sdk-ios-src/releases/tag/3.9.2) instead.

### Install Xendit iOS SDK with CocoaPods

Add this to your Podfile.

```ruby
pod 'Xendit', '~> 3.10.0'
```

**Important:** Import SDK in Objective-C project with CocoaPods integration, you can do as following

```objective-c
#import "Xendit-Swift.h"
```

### Install Xendit iOS SDK with SPM

1. Select your project in the Project Navigator on the right. Select the project in the Project section and click the Package Dependencies tab at the top.

2. Click the + button at the bottom of the table to add Xendit iOS SDK using the Swift Package Manager.

<img width="870" alt="Screenshot 2022-03-15 at 2 10 14 PM" src="https://user-images.githubusercontent.com/36880960/158318641-9d2fa77f-f6b2-4a9e-9d0a-b5f6348f1e39.png">

3. Enter the package URL in the search field in the top right, that simply means the [GitHub URL](https://github.com/xendit/xendit-sdk-ios-src.git).

4. Choose Dependency Rule as `Up to Next Major Version` from `3.7.0`.

<img width="1080" alt="Screenshot 2022-03-15 at 10 11 26 PM" src="https://user-images.githubusercontent.com/36880960/158397849-5fd4f311-4ed4-4df5-a257-cd332462ce41.png">

<img width="870" alt="Screenshot 2022-03-15 at 10 13 34 PM" src="https://user-images.githubusercontent.com/36880960/158397994-9253f9ab-124c-443e-b31c-5e09bcf0d4da.png">

**Important:** Import SDK in Objective-C project with SPM integration, you can do as following

```objective-c
@import Xendit;
```

### Creating token

This function accepts parameters below:

| Parameter          | Type                  | Description                                                                                                                                                                                                                                                                                                                                                    |
| ------------------ | --------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Card               | Card Object           | Card data that will be used to create a token                                                                                                                                                                                                                                                                                                                  |
| amount             | String                | Amount that will be used to create a token bundled with 3DS authentication                                                                                                                                                                                                                                                                                     |
| shouldAuthenticate | Boolean               | A flag indicating if 3DS authentication is required for this token. Will be set to `true` if you omit the parameter                                                                                                                                                                                                                                            |
| isMultipleUse      | Boolean               | A flag to identify whether a token will be reusable or just for one-time use. Will be set to `false` if you omit the parameter                                                                                                                                                                                                                                 |
| billingDetails     | billingDetails Object | Card holder's billing details                                                                                                                                                                                                                                                                                                                                  |
| customer           | customer object       | Xendit customer object                                                                                                                                                                                                                                                                                                                                         |
| currency           | String                | Currency of the transaction that will be submitted for 3DS authentication                                                                                                                                                                                                                                                                                      |
| midLabel           | String                | _For switcher merchant only_ Specific string value which labels any of your Merchant IDs (MID) set up with Xendit. This can be configured in the list of MIDs on your Dashboard settings. (If this is not included in a request, and you have more than 1 MID in your list, the transaction will proceed using your prioritized MID (first MID on your list)). |

## Running Tests

### Running Tests from Xcode

Open `Xendit.xcworkspace`

To run unit tests: choose `Xendit` scheme and press `cmd+u` (or "Run Product" -> "Test")

To run UI tests: choose `XenditExample` scheme and press `cmd+u`

## Run the app

### Running App with Xcode

1. Open xcode, click on the `Open a project or file`

<img width="809" alt="Screen Shot 2020-12-08 at 11 17 45" src="https://user-images.githubusercontent.com/16671326/101439516-3a639c80-3947-11eb-96de-f5aa518dd45b.png">

2. Browse to the repository folder, and open `Xendit.xcworkspace`

<img width="643" alt="Screen Shot 2020-12-08 at 11 18 18" src="https://user-images.githubusercontent.com/16671326/101439618-6e3ec200-3947-11eb-96c8-2087dcfdcea8.png">

3. Click the project scheme button (its beside stop button)

<img width="319" alt="Screen Shot 2020-12-08 at 11 23 22" src="https://user-images.githubusercontent.com/16671326/101439776-d8effd80-3947-11eb-8218-9f621762a8f5.png">

4. A dropdown list will appear, click `Edit scheme...`

<img width="197" alt="Screen Shot 2020-12-08 at 11 24 26" src="https://user-images.githubusercontent.com/16671326/101439832-fde47080-3947-11eb-97ae-14f619a68d86.png">

5. On the `Run` section, at the `Info` tab, click the `Executable` dropdown

<img width="888" alt="Screen Shot 2020-12-08 at 11 28 21" src="https://user-images.githubusercontent.com/16671326/101440128-a4c90c80-3948-11eb-89d7-570f0dabc638.png">

6. Select `XenditExample.app` and `Close` the window

<img width="901" alt="Screen Shot 2020-12-08 at 11 30 31" src="https://user-images.githubusercontent.com/16671326/101440250-e954a800-3948-11eb-94a3-17d302948fd4.png">

7. Click the `Run` button

<img width="335" alt="Screen Shot 2020-12-08 at 11 32 29" src="https://user-images.githubusercontent.com/16671326/101440380-2d47ad00-3949-11eb-9615-c6aaa5928394.png">

8. Wait for the app build and the simulator will showed up

<img width="434" alt="Screen Shot 2020-12-08 at 11 34 43" src="https://user-images.githubusercontent.com/16671326/101440486-66801d00-3949-11eb-8212-d5307ad0f5cb.png">
