# 🔑 EFKeychain

**EFKeychain** provides a wrapper around the iOS Keychain and makes its use familiar to UserDefaults.

## Usage

import EFKeychain in your view controller class

**Example**

Set Keychain value
`Keychain.standard.set(5, forKey: "tokens_remaining")`

Get Keychain value
`Keychain.standard.integer(forKey: "tokens_remaining")`

## Installation

With Xcode open:

- File
- Swift Packages
- Add Package Dependency
- Click the checkbox of your target, e.g *CorporatePhone*
- Paste URL `https://github.com/Everyman-Finance/EFKeychain`
- (Optional, but recommended) update your packages using the GUI or command `$ swift package update`.


## Help or Suggestions?

- [Open a PR](https://github.com/Everyman-Finance/EFKeychain/compare) if you want to make a change.
