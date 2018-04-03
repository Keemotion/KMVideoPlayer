//
//  KMVideoPlayerStateMachine.swift
//  KMVideoPlayer
//
//  Created by Valérian Buyck on 30/03/2018.
//  Copyright © 2018 Keemotion SPRL. All rights reserved.
//

import Foundation
import AVFoundation

extension KMVideoPlayerViewModel {

  enum PlayerAction: Equatable {
    case queue(item: AVPlayerItem)
    case play
    case pause
    case startScrubbing
    case scrub(time: Float)
    case stopScrubbing
    case stop

    // Equatable implementation tailored for distinctUntilChanged
    static func == (lhs: PlayerAction, rhs: PlayerAction) -> Bool {
      switch (lhs, rhs) {
      case (.play, .play),
           (.pause, .pause),
           (.startScrubbing, .startScrubbing),
           (.stopScrubbing, .stopScrubbing),
           (.stop, .stop):
        return true
      case (.scrub(let ltime), .scrub(let rtime)):
        return fabs(ltime - rtime) < Float.ulpOfOne
      // Consider queue as never equal
      default:
        return false
      }
    }
  }

  enum PlayerState {
    case playing
    case paused
    case stopped
    case scrubbing(shouldResume: Bool)

    var isPlaying: Bool {
      if case .playing = self {
        return true
      } else {
        return false
      }
    }

    var isScrubbing: Bool {
      if case .scrubbing(_) = self {
        return true
      } else {
        return false
      }
    }
  }

  static func actionProcessor(for player: AVQueuePlayer) -> (PlayerState, PlayerAction) -> PlayerState {
    return { state, action -> PlayerState in
      switch (state, action) {
      case (.stopped, .queue(let item)):
        player.insert(item, after: nil)
        return .paused
      case (.paused, .play):
        player.play()
        return .playing
      case (.playing, .pause):
        player.pause()
        return .paused
      case (.playing, .startScrubbing):
        player.pause()
        return .scrubbing(shouldResume: true)
      case (.paused, .startScrubbing):
        return .scrubbing(shouldResume: false)
      case (.scrubbing, .scrub(let time)):
        player.seek(to: CMTimeMakeWithSeconds(Float64(time), player.currentTime().timescale))
        return state
      case (.scrubbing(let resume), .stopScrubbing):
        if resume {
          player.play()
          return .playing
        } else {
          return .paused
        }
      case (_, .stop):
        player.removeAllItems()
        return .stopped
      default:
        return state
      }
    }
  }

}
