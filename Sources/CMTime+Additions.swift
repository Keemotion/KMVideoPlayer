//
//  CMTime-Additions.swift
//  KMVideoPlayer
//
//  Created by Valérian Buyck on 27/02/2018.
//  Copyright © 2018 Keemotion SPRL. All rights reserved.
//

import Foundation
import CoreMedia

extension CMTime {
  var timeString: String {
    if self.isNumeric {
      let seconds = Int(self.seconds.truncatingRemainder(dividingBy: 60).rounded(.down))
      let minutes = Int((self.seconds / 60.0).rounded(.down))
      return String(format: "%i:%02i", minutes, seconds)
    } else {
      return "0:00"
    }
  }
}
