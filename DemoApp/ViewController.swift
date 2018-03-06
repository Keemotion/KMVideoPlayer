//
//  ViewController.swift
//  DemoApp
//
//  Created by Valérian Buyck on 26/02/2018.
//  Copyright © 2018 Keemotion SPRL. All rights reserved.
//

import UIKit
import KMVideoPlayer
import AVKit

class ViewController: UIViewController {

  @IBOutlet weak var topView: UIView!
  @IBOutlet weak var bottomView: UIView!

  let player = KMVideoPlayerViewController()

  let otherPlayer = AVPlayerViewController()

  override func viewDidLoad() {
    super.viewDidLoad()

    player.view.frame = topView.bounds
    topView.addSubview(player.view)

    let url = URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_ts/master.m3u8")!
    _ = player.play(fileAtURL: url)

    otherPlayer.view.frame = bottomView.bounds
    bottomView.addSubview(otherPlayer.view)

    otherPlayer.player = AVPlayer(url: url)
  }

}
