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
  public var currentItem: Observable<AVPlayerItem> {
    return self.observe(AVPlayerItem.self, #keyPath(AVPlayer.currentItem))
      .flatMap { item -> Observable<AVPlayerItem> in
        guard let item = item else {
          return .empty()
        }
        return .just(item)
      }
  }

  public var currentTime: Observable<CMTime> {
    return Observable.create { observer in
      let interval = CMTime(seconds: 0.02, preferredTimescale: 100)
      let timeObserver = self.base.addPeriodicTimeObserver(forInterval: interval, queue: nil) {
        observer.onNext($0)
      }

      return Disposables.create {
        self.base.removeTimeObserver(timeObserver)
      }
    }
  }

  public var rate: Observable<Float> {
    return self.observe(Float.self, #keyPath(AVPlayer.rate))
      .map { $0 ?? 0 }
  }
}
