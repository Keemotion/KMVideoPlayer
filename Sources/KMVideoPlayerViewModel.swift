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

  let hideAirplayMessage: Driver<Bool>

  let hideControls: Driver<Bool>

  let controlHideMode: Driver<ControlHideMode>

  let fullscreen: Driver<Bool>

  let playerState: Driver<PlayerState>

  let controlBarOutputs: ControlBarOutputs

  init(player: AVQueuePlayer, layer: AVPlayerLayer) {
    let playerAction = PublishSubject<PlayerAction>()
    self.playerActionTrigger = playerAction.asObserver()

    let itemFinished = player.rx.currentItem
      .flatMapLatest { $0.rx.didPlayToEndTime }
      .map { _ in PlayerAction.pause }

    let state = Observable.merge(playerAction, itemFinished)
      .distinctUntilChanged()
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
            .throttle(.seconds(1), scheduler: MainScheduler.instance)
            .flatMapLatest { toggle -> Observable<Bool> in
              if !toggle || (toggle && isHidden) {
                return Observable<Bool>.create {
                    $0.onNext(false)
                    return Disposables.create()
                  }
                  .timeout(.seconds(2), scheduler: MainScheduler.instance)
                  .catchAndReturn(player.rate > 0.0)
              } else {
                return Observable.just(true)
              }
            }
            .do(onNext: { isHidden = $0 })
        case .manual:
          return showHideControls.withLatestFrom(state)
            .scan(false) { hide, state in
              return state.isScrubbing ? false : !hide
            }
        case .never:
          return .just(false)
        }
      }
      .distinctUntilChanged()
      .asDriver(onErrorJustReturn: false)

    self.controlHideMode = controlHideMode.asDriver(onErrorJustReturn: .auto)

    self.animateLoadingIndicator = player.rx.isExternalPlaybackActive
      .flatMapLatest { isExternal -> Observable<Bool> in
        if isExternal {
          return Observable.just(false)
        } else {
          return layer.rx.readyForDisplay.map { !$0 }
        }
      }
      .asDriver(onErrorJustReturn: false)

    self.hideAirplayMessage = player.rx.isExternalPlaybackActive
      .map { !$0 }
      .asDriver(onErrorJustReturn: false)

    self.fullscreen = fullscreen.scan(false) { previous, _ in
        return !previous
      }
      .asDriver(onErrorDriveWith: .empty())

    self.playerState = state.asDriver(onErrorJustReturn: .stopped)

    self.controlBarOutputs = ControlBarOutputs(player: player, state: state)
  }

}
