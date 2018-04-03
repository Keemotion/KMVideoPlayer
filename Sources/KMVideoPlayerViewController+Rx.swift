//
//  KMVideoPlayerViewController+Rx.swift
//  KMVideoPlayer
//
//  Created by Valérian Buyck on 28/02/2018.
//  Copyright © 2018 Keemotion SPRL. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

extension Reactive where Base: KMVideoPlayerViewController {
  public var presentationSize: Observable<CGSize> {
    return base.player.rx.currentItem
      .flatMapLatest { $0.rx.presentationSize }
  }

  public var itemDidPlayToEndTime: Observable<Notification> {
    return base.player.rx.currentItem
      .flatMapLatest { $0.rx.didPlayToEndTime }
  }

  public var itemFailedToPlayToEndTime: Observable<Notification> {
    return base.player.rx.currentItem
      .flatMapLatest { $0.rx.failedToPlayToEndTime }
  }

  public var fullscreen: Observable<Bool> {
    return base.viewModel.fullscreen.asObservable()
  }

  public var controlHideMode: ControlProperty<ControlHideMode> {
    return ControlProperty(values: base.viewModel.controlHideMode.asObservable(),
                           valueSink: base.viewModel.controlHideModeTrigger)
  }
}
