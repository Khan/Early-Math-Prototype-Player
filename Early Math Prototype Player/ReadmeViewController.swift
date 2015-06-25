//
//  ReadmeViewController.swift
//  Early Math Prototype Player
//
//  Created by Andy Matuschak on 6/24/15.
//  Copyright (c) 2015 Khan Academy. All rights reserved.
//

import UIKit

/** This view controller shows readmes for prototypes. */
class ReadmeViewController: UIViewController {
	let prototype: Prototype
	lazy var startButton: UIButton = {
		let button = UIButton.buttonWithType(.System) as! UIButton
		button.setTitle("Start", forState: .Normal)
		button.titleLabel!.font = UIFont.systemFontOfSize(24)
		return button
	}()

	init(prototype: Prototype) {
		precondition(prototype.readmeURL != nil)
		self.prototype = prototype

		var error: NSError?
		let markdownSource = NSString(contentsOfURL: prototype.readmeURL!, encoding: NSUTF8StringEncoding, error: &error)
		precondition(markdownSource != nil, "Couldn't read markdown for \(prototype.name): \(error)")

		let html = MMMarkdown.HTMLStringWithMarkdown(markdownSource! as String, error: &error)
		println(html)

		super.init(nibName: nil, bundle: nil)
		
		navigationItem.title = prototype.name
	}

	required init(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func loadView() {
		super.loadView()
		view.backgroundColor = UIColor.whiteColor()

		startButton.addTarget(self, action: "startPrototype", forControlEvents: .TouchUpInside)
		view.addSubview(startButton)

		view.setNeedsLayout()
	}

	override func viewWillLayoutSubviews() {
		// what is the difference between a view controller and a view anyways?!?
		startButton.sizeToFit()
		startButton.center.x = view.bounds.size.width / 2.0
		startButton.center.y = view.bounds.size.height - startButton.bounds.size.height / 2.0 - 50
	}

	func startPrototype() {
		let player = PlayerViewController(path: prototype.mainFileURL)
		navigationController!.pushViewController(player, animated: true) // what is a "control flow" anyway so lazy so prototype
	}
}