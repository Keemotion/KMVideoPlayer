//
//  AVPlayerLayer+Rx.swift
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

extension Reactive where Base: AVPlayerLayer {
  public var readyForDisplay: Observable<Bool> {
    return self.observe(Bool.self, #keyPath(AVPlayerLayer.isReadyForDisplay))
      .map { $0 ?? false }
  }
}
