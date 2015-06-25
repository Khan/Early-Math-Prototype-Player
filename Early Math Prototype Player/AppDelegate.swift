//
//  AppDelegate.swift
//  Protomath
//
//  Created by Jason Brennan on 2015-06-22.
//  Copyright (c) 2015 Khan Academy. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?
	var prototypeListTableViewController: PrototypeListTableViewController!
	var navigationController: UINavigationController!


	func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
		
		application.idleTimerDisabled = true
		
		window = UIWindow(frame: UIScreen.mainScreen().bounds)
		
		prototypeListTableViewController = PrototypeListTableViewController(style: .Plain)
		
		navigationController = UINavigationController(rootViewController: prototypeListTableViewController)		

		window?.rootViewController = navigationController
		
		let swipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "handleSwipeBackGesture:")
		swipeGestureRecognizer.numberOfTouchesRequired = 3
		swipeGestureRecognizer.direction = .Right
		window?.addGestureRecognizer(swipeGestureRecognizer)
		window?.makeKeyAndVisible()
		
		return true
	}

	func handleSwipeBackGesture(gesture: UIGestureRecognizer!) {
		self.navigationController.popToRootViewControllerAnimated(true)
	}

}

