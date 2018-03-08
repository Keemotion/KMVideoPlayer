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

open class KMVideoPlayerViewController: UIViewController {

  typealias ScrubbingState = KMVideoPlayerViewModel.ScrubbingState

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
  private lazy var viewModel = KMVideoPlayerViewModel(player: self.player,
                                                      layer: self.playerLayer)

  // controls & ui
  private let loadingIndicatorView: UIActivityIndicatorView = {
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    activityIndicator.hidesWhenStopped = true
    return activityIndicator
  }()
  private let controlContainerView = UIView()
  private let controlBar = KMVideoPlayerControlBar()
  private let topLeftControlView = KMVideoPlayerControlView()
  private let fullscreenButton = KMVideoPlayerFullscreenButton()

  // fullscreen support
  private let fullscreenWindow = UIWindow()
  private weak var previousKeyWindow: UIWindow?
  private var previousSuperview: UIView?
  public var isFullscreen = false

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
    topLeftControlView.pin(to: [.top, .left], margin: KMVideoPlayerControlView.spacing)
    topLeftControlView.stackView.addArrangedSubview(fullscreenButton)

    controlContainerView.addSubview(controlBar)

    controlBar.pin(to: [.left, .right], margin: KMVideoPlayerControlView.spacing)
    controlBar.pin(to: .bottom, margin: KMVideoPlayerControlView.spacing)

    view.addSubview(loadingIndicatorView)

    loadingIndicatorView.center()
  }

  private func setupTapGesture() {
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showControlsTap))
    view.isUserInteractionEnabled = true
    view.addGestureRecognizer(tapGesture)
  }

  @objc private func showControlsTap() {
    viewModel.showControlsTrigger.onNext(())
  }

  private func bindViewModelInputs() {
    controlBar.playPauseButton.rx.tap
      .subscribe(viewModel.playPauseTrigger)
      .disposed(by: disposeBag)

    let slider = controlBar.timeSlider
    let startObservable = slider.rx.controlEvent(.touchDown)
      .map { ScrubbingState.start }
    let stopObservable = slider.rx.controlEvent(.touchUpInside)
      .map { ScrubbingState.stop }
    let timeObservable = slider.rx.controlEvent(.valueChanged)
      .map { ScrubbingState.scrub(time: slider.value) }
    Observable.merge(startObservable, stopObservable, timeObservable)
      .subscribe(viewModel.scrubbingTrigger)
      .disposed(by: disposeBag)

    controlBar.timeSlider.rx.controlEvent(.allTouchEvents)
      .subscribe(viewModel.showControlsTrigger)
      .disposed(by: disposeBag)

    fullscreenButton.rx.tap
      .subscribe(viewModel.fullscreenTrigger)
      .disposed(by: disposeBag)
  }

  private func bindViewModelOutputs() {
    viewModel.animateLoadingIndicator.drive(loadingIndicatorView.rx.isAnimating)
      .disposed(by: disposeBag)

    viewModel.isPlaying
      .drive(controlBar.playPauseButton.rx.isPlaying)
      .disposed(by: disposeBag)

    viewModel.currentTime
      .drive(controlBar.currentTimeLabel.rx.text)
      .disposed(by: disposeBag)

    viewModel.currentProgress
      .drive(controlBar.timeSlider.rx.value)
      .disposed(by: disposeBag)

    viewModel.maximumValue
      .drive(controlBar.timeSlider.rx.maximumValue)
      .disposed(by: disposeBag)

    viewModel.duration
      .drive(controlBar.durationLabel.rx.text)
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
          self.willMove(toParentViewController: nil)
          self.view.removeFromSuperview()
          self.removeFromParentViewController()
          if let previousSuperview = self.previousSuperview {
            self.view.frame = previousSuperview.bounds
            previousSuperview.addSubview(self.view)
            self.previousSuperview = nil
          }
          self.fullscreenWindow.isHidden = true
          self.previousKeyWindow?.makeKeyAndVisible()
        }
        self.isFullscreen = shouldBeFullscreen
      })
      .startWith(false)
      .drive(fullscreenButton.rx.isFullscreen)
      .disposed(by: disposeBag)
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

    player.removeAllItems()

    guard player.canInsert(playerItem, after: nil) else {
      return false
    }

    player.insert(playerItem, after: nil)
    if startImmediately {
      player.play()
    }

    return true
  }

  /**
   Pauses the player
   */
  open func pause() {
    player.pause()
  }

  /**
   Stops the player and clears the current item
   */
  open func stop() {
    player.pause()
    player.removeAllItems()
  }

  /**
   Leaves fullscreen mode
   */
  open func leaveFullscreen() {
    if isFullscreen {
      viewModel.fullscreenTrigger.onNext(())
    }
  }

}
