//
//  KMVideoPlayerViewController.swift
//  KMVideoPlayer
//
//  Created by Valérian Buyck on 23/02/2018.
//  Copyright © 2018 Keemotion SPRL. All rights reserved.
//

import UIKit
import AVFoundation
import RxSwift
import RxCocoa

@objc open class KMVideoPlayerViewController: UIViewController {

  typealias PlayerAction = KMVideoPlayerViewModel.PlayerAction

  public enum ControlZone {
    case left
    case topLeft
    case topRight
    case right
  }

  internal let player: AVQueuePlayer = {
    let player = AVQueuePlayer()
    player.actionAtItemEnd = .pause
    return player
  }()
  internal lazy var playerLayer: AVPlayerLayer = {
    let layer = AVPlayerLayer()
    layer.player = player
    layer.videoGravity = .resizeAspect
    return layer
  }()
  internal lazy var viewModel = KMVideoPlayerViewModel(player: self.player,
                                                       layer: self.playerLayer)

  // controls & ui
  private let loadingIndicatorView: UIActivityIndicatorView = {
    let activityIndicator = UIActivityIndicatorView(style: .whiteLarge)
    activityIndicator.hidesWhenStopped = true
    return activityIndicator
  }()
  private let airplayTextLabel: UILabel = {
    let label = UILabel(frame: .zero)
    label.text = "Video is showing on an external screen"
    label.textColor = UIColor.white
    return label
  }()
  private let controlContainerView = UIView()
  private let controlBar = KMVideoPlayerControlBar()
  private let topLeftControlView = KMVideoPlayerControlView(axis: .horizontal)
  private let topRightControlView = KMVideoPlayerControlView(axis: .horizontal)
  private let leftControlView = KMVideoPlayerControlView(axis: .vertical)
  private let rightControlView = KMVideoPlayerControlView(axis: .vertical)
  private let fullscreenButton = KMVideoPlayerFullscreenButton()

  // fullscreen support
  private let fullscreenWindow = UIWindow()
  private weak var previousKeyWindow: UIWindow?
  private var previousSuperview: UIView?

  private let disposeBag = DisposeBag()

  open override var prefersStatusBarHidden: Bool {
    return true
  }

  open override func viewDidLoad() {
    super.viewDidLoad()

    view.layer.backgroundColor = UIColor.black.cgColor
    view.layer.insertSublayer(playerLayer, at: 0)

    setupSubviews()
    setupTapGesture()

    bindViewModelInputs()
    bindViewModelOutputs()
  }

  open override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()

    playerLayer.frame = view.bounds
  }

  private func setupSubviews() {
    view.addSubview(controlContainerView)
    controlContainerView.fit()

    controlContainerView.addSubview(topLeftControlView)
    controlContainerView.addSubview(topRightControlView)
    controlContainerView.addSubview(leftControlView)
    controlContainerView.addSubview(rightControlView)

    topLeftControlView.pin(to: [.top, .left], margin: KMVideoPlayerControlView.spacing)
    if allowFullscreen {
      topLeftControlView.stackView.addArrangedSubview(fullscreenButton)
    } else {
      topLeftControlView.isHidden = true
    }
    topRightControlView.pin(to: [.top, .right], margin: KMVideoPlayerControlView.spacing)
    topRightControlView.isHidden = true
    leftControlView.pin(to: .left, margin: KMVideoPlayerControlView.spacing)
    leftControlView.centerVertically()
    leftControlView.isHidden = true
    rightControlView.pin(to: .right, margin: KMVideoPlayerControlView.spacing)
    rightControlView.centerVertically()
    rightControlView.isHidden = true

    controlContainerView.addSubview(controlBar)

    controlBar.pin(to: [.left, .right], margin: KMVideoPlayerControlView.spacing)
    controlBar.pin(to: .bottom, margin: KMVideoPlayerControlView.spacing)

    view.addSubview(loadingIndicatorView)
    loadingIndicatorView.center()

    view.addSubview(airplayTextLabel)
    airplayTextLabel.sizeToFit()
    airplayTextLabel.center()
  }

  private func setupTapGesture() {
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showHideControls))
    view.isUserInteractionEnabled = true
    view.addGestureRecognizer(tapGesture)
  }

  private func bindViewModelInputs() {
    let playPause = controlBar.playPauseButton.rx.tap
      .withLatestFrom(viewModel.playerState.map { $0.isPlaying }.asObservable())
      .map { $0 ? PlayerAction.pause : PlayerAction.play(rate: 1.0) }

    let slider = controlBar.timeSlider
    let startScrubbing = slider.rx.controlEvent(.touchDown)
      .map { PlayerAction.startScrubbing }
    let stopScrubbing = slider.rx.controlEvent([.touchUpInside, .touchUpOutside, .touchCancel])
      .map { PlayerAction.stopScrubbing }
    let scrub = slider.rx.controlEvent(.valueChanged)
      .map { PlayerAction.scrub(time: Double(slider.value)) }

    Observable.merge(playPause, startScrubbing, stopScrubbing, scrub)
      .subscribe(viewModel.playerActionTrigger)
      .disposed(by: disposeBag)

    fullscreenButton.rx.tap
      .subscribe(viewModel.fullscreenTrigger)
      .disposed(by: disposeBag)
  }

  private func bindViewModelOutputs() {
    viewModel.animateLoadingIndicator.drive(loadingIndicatorView.rx.isAnimating)
      .disposed(by: disposeBag)

    viewModel.hideAirplayMessage.drive(airplayTextLabel.rx.isHidden)
      .disposed(by: disposeBag)

    viewModel.hideControls.drive(onNext: { [unowned self] shouldHide in
      guard self.controlContainerView.isHidden != shouldHide else { return }
      UIView.transition(with: self.controlContainerView,
                        duration: 0.1,
                        options: .transitionCrossDissolve,
                        animations: {
                          self.controlContainerView.isHidden = shouldHide
                        },
                        completion: nil)
    }).disposed(by: disposeBag)

    viewModel.fullscreen
      .do(onNext: { [unowned self] shouldBeFullscreen in
        if shouldBeFullscreen {
          guard let mainWindow = UIApplication.shared.keyWindow else { return }

          self.fullscreenWindow.frame = mainWindow.frame
          self.previousKeyWindow = mainWindow
          self.previousSuperview = self.view.superview
          self.view.removeFromSuperview()
          let navigationController = UINavigationController(rootViewController: self)
          navigationController.isNavigationBarHidden = true
          self.fullscreenWindow.rootViewController = navigationController
          self.fullscreenWindow.backgroundColor = UIColor.black
          self.fullscreenWindow.makeKeyAndVisible()
        } else {
          self.fullscreenWindow.rootViewController = nil
          self.willMove(toParent: nil)
          self.view.removeFromSuperview()
          self.removeFromParent()
          if let previousSuperview = self.previousSuperview {
            self.view.frame = previousSuperview.bounds
            previousSuperview.addSubview(self.view)
            self.previousSuperview = nil
          }
          self.fullscreenWindow.isHidden = true
          self.previousKeyWindow?.makeKeyAndVisible()
        }
      })
      .startWith(false)
      .drive(fullscreenButton.rx.isFullscreen)
      .disposed(by: disposeBag)

    controlBar.bind(viewModel.controlBarOutputs)
      .disposed(by: disposeBag)
  }

  /**
   Play/Pause button from the control bar

   Access this button to move it to another control zone only
   */
  open var playPauseButton: KMVideoPlayerPlayPauseButton {
    return controlBar.playPauseButton
  }

  /**
   Queues the video file present at the specified URL and starts playing

   - parameters:
      - fileAtURL: An URL referencing either a local or remote video file
      - startImmediately: If the file should start playing immediately
   - returns: True if the file could be queued
   - important: Clears any previously playing file
   */
  open func play(fileAtURL url: URL, startImmediately: Bool = true) -> Bool {
    let playerItem = AVPlayerItem(url: url)

    viewModel.playerActionTrigger.onNext(.stop)

    guard player.canInsert(playerItem, after: nil) else {
      return false
    }

    viewModel.playerActionTrigger.onNext(.queue(item: playerItem))
    if startImmediately {
      viewModel.playerActionTrigger.onNext(.play(rate: 1.0))
    }

    return true
  }

  /**
   Pauses the player
   */
  open func pause() {
    viewModel.playerActionTrigger.onNext(.pause)
  }

  /**
   Stops the player and clears the current item
   */
  open func stop() {
    viewModel.playerActionTrigger.onNext(.stop)
  }

  /**
   The playback rate
   */
  open var playbackRate: Float {
    get {
      return player.rate
    }
    set {
      viewModel.playerActionTrigger.onNext(.play(rate: newValue))
    }
  }

  /**
   Seeks by adding the passed seconds to the current time
   */
  open func seek(byAdding time: Double) {
    let currentTime = player.currentTime()

    guard currentTime.isValid else { return }

    viewModel.playerActionTrigger.onNext(.startScrubbing)
    viewModel.playerActionTrigger.onNext(.scrub(time: currentTime.seconds + time))
    viewModel.playerActionTrigger.onNext(.stopScrubbing)
  }

  /**
   Seeks to the time passed in seconds
   */
  open func seek(to time: Double) {
    guard time >= 0 else { return }

    viewModel.playerActionTrigger.onNext(.startScrubbing)
    viewModel.playerActionTrigger.onNext(.scrub(time: time))
    viewModel.playerActionTrigger.onNext(.stopScrubbing)
  }

  /**
   Indicates if the player is in fullscreen mode
   Changing the value causes the player to enter or leave fullscreen mode
   */
  open var fullscreen: Bool {
    get {
      var isFullscreen = false
      // Driver shares with replay so we can synchronously retrieve last value
      viewModel.fullscreen
        .drive(onNext: { isFullscreen = $0 })
        .dispose()
      return isFullscreen
    }
    set {
      if newValue != fullscreen {
        viewModel.fullscreenTrigger.onNext(())
      }
    }
  }

  /**
   Indicates if the user should be able to enter manually fullscreen mode
   */
  open var allowFullscreen = true {
    didSet {
      if allowFullscreen != oldValue {
        if allowFullscreen {
          topLeftControlView.stackView.addArrangedSubview(fullscreenButton)
          topLeftControlView.isHidden = false
        } else {
          topLeftControlView.stackView.removeArrangedSubview(fullscreenButton)
          fullscreenButton.removeFromSuperview()
          if topLeftControlView.stackView.subviews.isEmpty {
            topLeftControlView.isHidden = true
          }
        }
      }
    }
  }

  /**
   See AVPlayer.usesExternalPlaybackWhileExternalScreenIsActive
   */
  open var automaticallyUseExternalPlayback: Bool {
    get {
      return player.usesExternalPlaybackWhileExternalScreenIsActive
    }
    set {
      player.usesExternalPlaybackWhileExternalScreenIsActive = newValue
    }
  }

  private func controlView(forZone zone: ControlZone) -> KMVideoPlayerControlView {
    switch zone {
    case .left: return leftControlView
    case .topLeft: return topLeftControlView
    case .topRight: return topRightControlView
    case .right: return rightControlView
    }
  }

  /**
   Adds a view into one of the control zones

   - parameters:
      - controlView: A view to add
      - inZone: Control zone where the view should be added
      - at: The index where the view should be inserted
   - important: Calling this doesn't make the zone automatically visible
  */
  open func add(controlView view: UIView, inZone zone: ControlZone, at index: Int) {
    controlView(forZone: zone).stackView.insertArrangedSubview(view, at: index)
  }

  /**
   Makes the control zone hidden

   - parameters:
      - zone: One of the control zones
      - hidden: Boolean value that determines whether the zone is hidden or visible
   - important: Even if visible, the control zone will still automatically hide while playing
  */
  open func set(zone: ControlZone, hidden: Bool) {
    controlView(forZone: zone).isHidden = hidden
  }

  /**
   Indicates when controls appear on screen
   */
  open var controlHideMode: ControlHideMode {
    get {
      var controlHideMode = ControlHideMode.auto
      viewModel.controlHideMode
        .drive(onNext: { controlHideMode = $0 })
        .dispose()
      return controlHideMode
    }
    set {
      viewModel.controlHideModeTrigger.onNext(newValue)
    }
  }

  /**
   Show/Hide controls on screen
   */
  @objc open func showHideControls() {
    viewModel.showHideControlsTrigger.onNext(())
  }

}
