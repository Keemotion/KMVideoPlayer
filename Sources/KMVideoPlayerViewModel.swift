//
//  KMVideoPlayerViewModel.swift
//  KMVideoPlayer
//
//  Created by Valérian Buyck on 05/03/2018.
//  Copyright © 2018 Keemotion SPRL. All rights reserved.
//

import Foundation
import AVFoundation
import RxSwift
import RxCocoa

internal final class KMVideoPlayerViewModel {

  enum ScrubbingState: Equatable {
    case start
    case scrub(time: Float)
    case stop

    static func == (lhs: ScrubbingState, rhs: ScrubbingState) -> Bool {
      switch (lhs, rhs) {
      case (.start, .start),
           (.stop, .stop):
        return true
      case (.scrub(let ltime), .scrub(let rtime)):
        return fabs(ltime - rtime) < Float.ulpOfOne
      default:
        return false
      }
    }
  }

  // MARK: - Inputs
  let playPauseTrigger: AnyObserver<Void>

  let scrubbingTrigger: AnyObserver<ScrubbingState>

  let showControlsTrigger: AnyObserver<Void>

  let fullscreenTrigger: AnyObserver<Void>

  // MARK: - Outputs
  let animateLoadingIndicator: Driver<Bool>

  let hideControls: Driver<Bool>

  let fullscreen: Driver<Bool>

  let controlBarOutputs: ControlBarOutputs

  init(player: AVPlayer, layer: AVPlayerLayer) {
    let _playPause = PublishSubject<Void>()
    self.playPauseTrigger = _playPause.asObserver()
    let playPause = _playPause.do(onNext: { _ in
      player.rate > 0.0 ? player.pause() : player.play()
    })

    let scrubbing = PublishSubject<ScrubbingState>()
    self.scrubbingTrigger = scrubbing.asObserver()

    let firstState = (shouldResume: false, scrubbing: false)
    let isScrubbing = scrubbing.distinctUntilChanged()
      .startWith(.stop)
      .scan(firstState) { state, scrubbingState in
        switch scrubbingState {
        case .start:
          let shouldResume = player.rate > 0
          if shouldResume {
            player.pause()
          }
          return (shouldResume: shouldResume, scrubbing: true)
        case .scrub(let time):
          player.seek(to: CMTimeMakeWithSeconds(Float64(time), player.currentTime().timescale))
          return state
        case .stop:
          if state.shouldResume {
            player.play()
          }
          return (shouldResume: false, scrubbing: false)
        }
      }

    let showControls = PublishSubject<Void>()
    self.showControlsTrigger = showControls.asObserver()

    let fullscreen = PublishSubject<Void>()
    self.fullscreenTrigger = fullscreen.asObserver()

    // hide controls if playing for more than 2 secs and there is no UI interaction
    let uiTriggers: [Observable<Void>] = [
      playPause,
      scrubbing.map { _ in () },
      showControls,
      fullscreen
    ]
    self.hideControls = Observable.merge(uiTriggers)
      .startWith(())
      .throttle(1.0, scheduler: MainScheduler.instance)
      .flatMapLatest {
        return Observable<Bool>.create {
            $0.onNext(false)
            return Disposables.create()
          }
          .timeout(2.0, scheduler: MainScheduler.instance)
          .catchError { _ in .just(player.rate > 0.0) }
      }
      .distinctUntilChanged()
      .asDriver(onErrorJustReturn: false)

    self.animateLoadingIndicator = layer.rx.readyForDisplay.map { !$0 }
      .asDriver(onErrorJustReturn: false)

    self.fullscreen = fullscreen.scan(false) { previous, _ in
        return !previous
      }
      .asDriver(onErrorDriveWith: .empty())

    self.controlBarOutputs = ControlBarOutputs(player: player, isScrubbing: isScrubbing.map { $0.scrubbing })
  }

}
