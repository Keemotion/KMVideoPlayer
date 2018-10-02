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
    case play(rate: Float)
    case pause
    case startScrubbing
    case scrub(time: Double)
    case stopScrubbing
    case stop

    // Equatable implementation tailored for distinctUntilChanged
    static func == (lhs: PlayerAction, rhs: PlayerAction) -> Bool {
      switch (lhs, rhs) {
      case (.pause, .pause),
           (.startScrubbing, .startScrubbing),
           (.stopScrubbing, .stopScrubbing),
           (.stop, .stop):
        return true
      case (.play(let lrate), .play(let rrate)):
        return lrate == rrate
      case (.scrub(let ltime), .scrub(let rtime)):
        return fabs(ltime - rtime) < Double.ulpOfOne
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
    case scrubbing(resumeWithRate: Float)

    var isPlaying: Bool {
      if case .playing = self {
        return true
      } else {
        return false
      }
    }

    var isScrubbing: Bool {
      if case .scrubbing = self {
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
      case (.paused, .play(let rate)):
        if let currentItem = player.currentItem,
          currentItem.duration.value > 0,
          CMTimeCompare(player.currentTime(), currentItem.duration) >= 0 {
            player.seek(to: kCMTimeZero)
        }
        player.rate = rate
        return .playing
      case (.playing, .play(let rate)):
        player.rate = rate
        return .playing
      case (.playing, .pause):
        player.pause()
        return .paused
      case (.playing, .startScrubbing):
        let rate = player.rate
        player.pause()
        return .scrubbing(resumeWithRate: rate)
      case (.paused, .startScrubbing):
        return .scrubbing(resumeWithRate: 0.0)
      case (.scrubbing, .scrub(let time)):
        player.seek(to: CMTimeMakeWithSeconds(time, player.currentTime().timescale))
        return state
      case (.scrubbing(let rate), .stopScrubbing):
        if rate > 0.0 {
          player.rate = rate
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
