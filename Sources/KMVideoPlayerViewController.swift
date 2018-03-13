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
  private let showControlsButton = UIButton()
  private let loadingIndicatorView: UIActivityIndicatorView = {
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    activityIndicator.hidesWhenStopped = true
    return activityIndicator
  }()
  private let controlBar = KMVideoPlayerControlBar()

  private let disposeBag = DisposeBag()

  open override func viewDidLoad() {
    super.viewDidLoad()

    view.layer.backgroundColor = UIColor.black.cgColor
    view.layer.insertSublayer(playerLayer, at: 0)

    setupSubviews()

    bindViewModelInputs()
    bindViewModelOutputs()
  }

  open override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()

    playerLayer.frame = view.bounds
  }

  private func setupSubviews() {
    view.addSubview(showControlsButton)

    showControlsButton.fit()

    view.addSubview(controlBar)

    controlBar.pin(to: [.left, .right], margin: KMVideoPlayerControlView.spacing)
    controlBar.pin(to: .bottom, margin: KMVideoPlayerControlView.spacing)

    view.addSubview(loadingIndicatorView)

    loadingIndicatorView.center()
  }

  private func bindViewModelInputs() {
    showControlsButton.rx.tap
      .subscribe(viewModel.showControlsTrigger)
      .disposed(by: disposeBag)

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

    viewModel.currentValue
      .drive(controlBar.timeSlider.rx.value)
      .disposed(by: disposeBag)

    viewModel.maximumValue
      .drive(controlBar.timeSlider.rx.maximumValue)
      .disposed(by: disposeBag)

    viewModel.duration
      .drive(controlBar.durationLabel.rx.text)
      .disposed(by: disposeBag)

    viewModel.hideControls.drive(onNext: { [unowned self] shouldHide in
      guard self.controlBar.isHidden != shouldHide else { return }
      UIView.transition(with: self.controlBar,
                        duration: 0.1,
                        options: .transitionCrossDissolve,
                        animations: {
                          self.controlBar.isHidden = shouldHide
                        },
                        completion: nil)
    }).disposed(by: disposeBag)
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

}
