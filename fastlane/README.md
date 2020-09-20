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
or alternatively using `brew install fastlane`

# Available Actions
## iOS
### ios tldrscreenshots
```
fastlane ios tldrscreenshots
```
Generate new localized screenshots
### ios tldruploadmetadata
```
fastlane ios tldruploadmetadata
```
Upload screenshots and metadata
### ios tldrsubmitbinary
```
fastlane ios tldrsubmitbinary
```
Upload binary and submit for review
### ios tldrtestflight
```
fastlane ios tldrtestflight
```
Upload binary to testflight
### ios tldrreject
```
fastlane ios tldrreject
```
Reject binary

----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
