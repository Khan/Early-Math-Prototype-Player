//
//  AppDelegate.swift
//  Protomath
//
//  Created by Jason Brennan on 2015-06-22.
//  Copyright (c) 2015 Khan Academy. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate {

	var window: UIWindow?
	var prototypeListTableViewController: PrototypeListTableViewController!
	var navigationController: UINavigationController!


	func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
		
		application.idleTimerDisabled = true
		
		window = UIWindow(frame: UIScreen.mainScreen().bounds)
		
		prototypeListTableViewController = PrototypeListTableViewController(style: .Plain)
		
		navigationController = UINavigationController(rootViewController: prototypeListTableViewController)
		navigationController.delegate = self

		window?.rootViewController = navigationController
		
		let swipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "handleSwipeBackGesture:")
		swipeGestureRecognizer.numberOfTouchesRequired = 3
		swipeGestureRecognizer.direction = .Right
		swipeGestureRecognizer.delegate = self
		window?.addGestureRecognizer(swipeGestureRecognizer)
		window?.makeKeyAndVisible()
		
		return true
	}

	func handleSwipeBackGesture(gesture: UIGestureRecognizer!) {
		self.navigationController.popToRootViewControllerAnimated(true)
	}

	func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailByGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
		return false
	}

	func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
		return true
	}

	// Hacks to show/hide navigation bar in prototypes so hack wow
	func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
		if viewController is PlayerViewController {
			navigationController.setNavigationBarHidden(true, animated: true)
		} else {
			navigationController.setNavigationBarHidden(false, animated: true)
		}
	}
}

