 # Pluto-Swift-SDK

[![CI Status](https://img.shields.io/travis/MuShare/PlutoSwiftClientSDK.svg?style=flat)](https://travis-ci.org/MuShare/PlutoSwiftClientSDK)
[![Version](https://img.shields.io/cocoapods/v/PlutoSDK.svg?style=flat)](https://cocoapods.org/pods/PlutoSDK)
[![License](https://img.shields.io/cocoapods/l/PlutoSDK.svg?style=flat)](https://cocoapods.org/pods/PlutoSDK)
[![Platform](https://img.shields.io/cocoapods/p/PlutoSDK.svg?style=flat)](https://cocoapods.org/pods/PlutoSDK)

Swift SDK for Pluto login microservice, which simplify the implementation for signing in with email, Google and Apple.

## Installation

The Swift SDK for Pluto is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'PlutoSDK'
```

## Document

To auth with Pluto, set up it at first in your `AppDelegate` class.

```swift
Pluto.shared.setup(server: "[server url]", appId: "[app id]")
```

Implement signing in and signing up with the following methods

- `Pluto.shared.registerByEmaili()`
- `Pluto.shared.resendValidationEmail()`
- `Pluto.shared.loginWithEmail()`
- `Pluto.shared.loginWithGoogle()`
- `Pluto.shared.loginWithApple()`
- `Pluto.shared.resetPassword()`
- `Pluto.shared.logout()`

After signing in, get token or the header with token with the following methods

- `Pluto.shared.getToken()`
- `Pluto.shared.getHeaders()`

Get user information with 

- `Pluto.shared.myInfo()`

Get scopes from jwt token with

- `Pluto.shared.getScopes()`

## Author

lm2343635, lm2343635@126.com

## License

MuShare-Login-Swift-SDK is available under the MIT license. See the LICENSE file for more info.
