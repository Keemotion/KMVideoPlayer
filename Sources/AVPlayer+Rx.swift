//
//  AVPlayer+Rx.swift
//  KMVideoPlayer
//
//  Inspired by RxAVFoundation
//  Created by Valérian Buyck on 27/02/2018.
//  Copyright © 2018 Keemotion SPRL. All rights reserved.
//

import Foundation
import AVFoundation
import RxSwift
import RxCocoa

extension Reactive where Base: AVPlayer {
  var currentItem: Observable<AVPlayerItem> {
    return self.observe(AVPlayerItem.self, #keyPath(AVPlayer.currentItem))
      .flatMap { item -> Observable<AVPlayerItem> in
        guard let item = item else {
          return .empty()
        }
        return .just(item)
      }
  }

  var currentTime: Observable<CMTime> {
    return Observable.create { observer in
      let time = self.base.currentTime()
      observer.onNext(time.isValid ? time : CMTime(value: 0, timescale: 1))

      let interval = CMTime(seconds: 0.02, preferredTimescale: 100)
      let timeObserver = self.base.addPeriodicTimeObserver(forInterval: interval, queue: nil) {
        observer.onNext($0)
      }

      return Disposables.create {
        self.base.removeTimeObserver(timeObserver)
      }
    }
  }

  var rate: Observable<Float> {
    return self.observe(Float.self, #keyPath(AVPlayer.rate))
      .map { $0 ?? 0 }
  }

  var isExternalPlaybackActive: Observable<Bool> {
    return self.observe(Bool.self, #keyPath(AVPlayer.isExternalPlaybackActive))
      .map { $0 ?? false }
  }
}
