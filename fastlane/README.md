fastlane documentation
================
# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```
xcode-select --install
```

Install _fastlane_ using
```
[sudo] gem install fastlane -NV
```
or alternatively using `brew cask install fastlane`

# Available Actions
## iOS
### ios bootstrap
```
fastlane ios bootstrap
```
Bootstrap the sdk
### ios alpha
```
fastlane ios alpha
```
Build to app distribution
### ios beta
```
fastlane ios beta
```
Build to apple tf
### ios release
```
fastlane ios release
```
Build to apple ga

----

## Android
### android bootstrap
```
fastlane android bootstrap
```
Bootstrap the sdk
### android alpha
```
fastlane android alpha
```
Build to app distribution
### android beta
```
fastlane android beta
```
Build to play beta
### android release
```
fastlane android release
```
Build to play ga

----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
