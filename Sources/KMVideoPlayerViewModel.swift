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
  let showHideControlsTrigger: AnyObserver<Void>

  let controlHideModeTrigger: AnyObserver<ControlHideMode>

  let playerActionTrigger: AnyObserver<PlayerAction>

  let fullscreenTrigger: AnyObserver<Void>

  // MARK: - Outputs
  let animateLoadingIndicator: Driver<Bool>

  let hideControls: Driver<Bool>

  let controlHideMode: Driver<ControlHideMode>

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

    let showHideControls = PublishSubject<Void>()
    self.showHideControlsTrigger = showHideControls.asObserver()

    let controlHideMode = BehaviorSubject(value: ControlHideMode.auto)
    self.controlHideModeTrigger = controlHideMode.asObserver()

    let fullscreen = PublishSubject<Void>()
    self.fullscreenTrigger = fullscreen.asObserver()

    self.hideControls = controlHideMode.flatMapLatest { mode -> Observable<Bool> in
        switch mode {
        case .auto:
          // hide controls if playing for more than 2 secs and there is no UI interaction
          let triggers: [Observable<Bool>] = [
            showHideControls.map { true },
            state.map { _ in false },
            fullscreen.map { false }
          ]
          var isHidden = false
          return Observable.merge(triggers)
            .startWith(false)
            .throttle(1.0, scheduler: MainScheduler.instance)
            .flatMapLatest { toggle -> Observable<Bool> in
              if !toggle || (toggle && isHidden) {
                return Observable<Bool>.create {
                    $0.onNext(false)
                    return Disposables.create()
                  }
                  .timeout(2.0, scheduler: MainScheduler.instance)
                  .catchError { _ in .just(player.rate > 0.0) }
              } else {
                return Observable.just(true)
              }
            }
            .do(onNext: { isHidden = $0 })
        case .manual:
          return showHideControls.scan(false) { hide, _ in
              return !hide
            }
        case .never:
          return .just(false)
        }
      }
      .distinctUntilChanged()
      .asDriver(onErrorJustReturn: false)

    self.controlHideMode = controlHideMode.asDriver(onErrorJustReturn: .auto)

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
