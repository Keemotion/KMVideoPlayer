//
//  KMVideoPlayerViewModel+ControlBar.swift
//  KMVideoPlayer
//
//  Created by Valérian Buyck on 30/03/2018.
//  Copyright © 2018 Keemotion SPRL. All rights reserved.
//

import Foundation
import AVFoundation
import RxSwift
import RxCocoa

extension KMVideoPlayerViewModel {

  struct ControlBarOutputs {
    let isPlaying: Driver<Bool>
    let currentTime: Driver<String>
    let currentProgress: Driver<Float>
    let maximumValue: Driver<Float>
    let duration: Driver<String>

    init(player: AVPlayer, state: Observable<PlayerState>) {
      self.isPlaying = player.rx.rate.map { $0 > 0 }
        .asDriver(onErrorJustReturn: false)

      let scrubTime = state.flatMap { state -> Observable<CMTime> in
        if case .scrubbing(_, let time) = state {
          return .just(time)
        } else {
          return .empty()
        }
      }
      self.currentTime = Observable.merge(player.rx.currentTime, scrubTime)
        .map { $0.timeString }
        .asDriver(onErrorJustReturn: "0:00")

      self.currentProgress = player.rx.currentTime
        .withLatestFrom(state.map { $0.isScrubbing }) { ($0, $1) }
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
    }
  }

}
