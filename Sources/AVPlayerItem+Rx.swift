//
//  AVPlayerItem+Rx.swift
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

extension Reactive where Base: AVPlayerItem {
  var status: Observable<AVPlayerItemStatus> {
    return self.observe(AVPlayerItemStatus.self, #keyPath(AVPlayerItem.status))
      .map { $0 ?? .unknown }
  }

  var duration: Observable<CMTime> {
    return self.observe(CMTime.self, #keyPath(AVPlayerItem.duration))
      .map { $0 ?? CMTime(value: 0, timescale: 1) }
  }

  var presentationSize: Observable<CGSize> {
    return self.observe(CGSize.self, #keyPath(AVPlayerItem.presentationSize))
      .map { $0 ?? .zero }
  }

  var didPlayToEndTime: Observable<Notification> {
    return NotificationCenter.default.rx.notification(.AVPlayerItemDidPlayToEndTime,
                                                      object: base)
  }

  var failedToPlayToEndTime: Observable<Notification> {
    return NotificationCenter.default.rx.notification(.AVPlayerItemFailedToPlayToEndTime,
                                                      object: base)
  }
}
