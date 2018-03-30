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

  // MARK: - Inputs
  let showControlsTrigger: AnyObserver<Void>

  let playerActionTrigger: AnyObserver<PlayerAction>

  let fullscreenTrigger: AnyObserver<Void>

  // MARK: - Outputs
  let animateLoadingIndicator: Driver<Bool>

  let hideControls: Driver<Bool>

  let fullscreen: Driver<Bool>

  let playerState: Driver<PlayerState>

  let controlBarOutputs: ControlBarOutputs

  init(player: AVQueuePlayer, layer: AVPlayerLayer) {
    let playerAction = PublishSubject<PlayerAction>()
    self.playerActionTrigger = playerAction.asObserver()

    let state = playerAction.distinctUntilChanged()
      .startWith(.stop)
      .scan(PlayerState.stopped, accumulator: KMVideoPlayerViewModel.actionProcessor(for: player))
      .share()

    let showControls = PublishSubject<Void>()
    self.showControlsTrigger = showControls.asObserver()

    let fullscreen = PublishSubject<Void>()
    self.fullscreenTrigger = fullscreen.asObserver()

    // hide controls if playing for more than 2 secs and there is no UI interaction
    let uiTriggers: [Observable<Void>] = [
      state.map { _ in () },
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

    self.playerState = state.asDriver(onErrorJustReturn: .stopped)

    self.controlBarOutputs = ControlBarOutputs(player: player, isScrubbing: state.map { $0.isScrubbing })
  }

}
