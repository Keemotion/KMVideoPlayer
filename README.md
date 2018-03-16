# KMVideoPlayer

KMVideoPlayer provides a basic player UI on top of `AVPlayerLayer` matching what you can find in `AVPlayerViewController` but with the ability to customize the UI further to fit your needs.

The implementation relies heavily on `RxSwift` internally and the goal is eventually for the API to be functional as well.

## Features
- [x] Support basic playback (play/pause and seeking)
- [x] Controls automatically hide while playing
- [x] Support fullscreen
- [ ] Support additionnal custom UI controls
- [ ] Queue items to play
- [ ] Functional Rx API

## Requirements
- iOS 9 +
- Xcode 9
- Swift 4
- RxSwift 4.1.2

### [Carthage](https://github.com/Carthage/Carthage)
Add `KMVideoPlayer` to your Cartfile.
```
github "Keemotion/KMVideoPlayer"
```
Run `$ carthage update` and integrate `KMVideoPlayer`, `RxSwift` and `RxCocoa` frameworks into your project.
