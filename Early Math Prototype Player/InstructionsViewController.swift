//
//  InstructionsViewController.swift
//  Early Math Prototype Player
//
//  Created by Andy Matuschak on 7/5/15.
//  Copyright (c) 2015 Khan Academy. All rights reserved.
//

import Foundation
import AVFoundation

class InstructionsViewController: UIViewController {
	// This state shouldn't be entangled here, but this is throwaway...
	static var userHasSeenInstructions: Bool {
		return NSUserDefaults.standardUserDefaults().boolForKey(InstructionsViewController.userHasSeenInstructionsKey)
	}

	init() {
		super.init(nibName: "Instructions", bundle: nil)
	}

	required init(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}

	private static let userHasSeenInstructionsKey = "UserHasSeenInstructions"
	@IBOutlet weak var videoPlayerView: AVPlayerView!
	@IBOutlet weak var simulatorNoteLabel: UILabel!

	override func viewWillAppear(animated: Bool) {
		NSUserDefaults.standardUserDefaults().setBool(true, forKey: InstructionsViewController.userHasSeenInstructionsKey)

		simulatorNoteLabel.hidden = TARGET_IPHONE_SIMULATOR == 0

		videoPlayerView.playerLayer.player = AVPlayer(URL: NSBundle.mainBundle().URLForResource("finger_demo", withExtension: "m4v"))
		videoPlayerView.playerLayer.player.play()
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "loopPlayer", name: AVPlayerItemDidPlayToEndTimeNotification, object: videoPlayerView.playerLayer.player.currentItem)
	}

	override func viewDidDisappear(animated: Bool) {
		NSNotificationCenter.defaultCenter().removeObserver(self, name: AVPlayerItemDidPlayToEndTimeNotification, object: videoPlayerView.playerLayer.player.currentItem)
	}

	@objc private func loopPlayer() {
		videoPlayerView.playerLayer.player.seekToTime(kCMTimeZero)
		videoPlayerView.playerLayer.player.play()
	}

	@IBAction func handleContinue(sender: AnyObject) {
		self.dismissViewControllerAnimated(true, completion: nil)
	}
}

@objc(AVPlayerView) class AVPlayerView: UIView {
	override class func layerClass() -> AnyClass { return AVPlayerLayer.self }
	var playerLayer: AVPlayerLayer { return layer as! AVPlayerLayer }
}
