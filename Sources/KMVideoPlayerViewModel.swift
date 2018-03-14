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

  // MARK: - Outputs
  let animateLoadingIndicator: Driver<Bool>

  let isPlaying: Driver<Bool>

  let currentTime: Driver<String>

  let currentProgress: Driver<Float>

  let maximumValue: Driver<Float>

  let duration: Driver<String>

  let hideControls: Driver<Bool>

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

    self.currentTime = player.rx.currentTime
      .map { $0.timeString }
      .asDriver(onErrorJustReturn: "0:00")

    self.currentProgress = player.rx.currentTime
      .withLatestFrom(isScrubbing.map { $0.scrubbing }) { ($0, $1) }
      .flatMap { (time, scrubbing) -> Observable<Float> in
        if scrubbing {
          return .empty()
        } else {
          return .just(Float(time.seconds))
        }
      }
      .asDriver(onErrorJustReturn: 0.0)

    let duration = player.rx.currentItem
      .flatMap { $0.rx.duration }
      .filter { $0.isNumeric }
      .share()

    self.maximumValue = duration.map { Float($0.seconds) }
      .asDriver(onErrorJustReturn: 0)

    self.duration = duration.map { $0.timeString }
      .asDriver(onErrorJustReturn: "0:00")

    // hide controls if playing for more than 2 secs and there is no UI interaction
    let uiTriggers: [Observable<Void>] = [
      playPause,
      scrubbing.map { _ in () },
      showControls
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

    self.isPlaying = player.rx.rate.map { $0 > 0 }
      .asDriver(onErrorJustReturn: false)
  }

}
