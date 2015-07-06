//
//  AppDelegate.swift
//  Protomath
//
//  Created by Jason Brennan on 2015-06-22.
//  Copyright (c) 2015 Khan Academy. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UINavigationControllerDelegate {

	var window: UIWindow?
	var prototypeListCollectionViewController: PrototypeListCollectionViewController!
	var navigationController: UINavigationController!


	func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
		
		application.idleTimerDisabled = true
		
		window = UIWindow(frame: UIScreen.mainScreen().bounds)
		
		prototypeListCollectionViewController = PrototypeListCollectionViewController()
		
		navigationController = UINavigationController(rootViewController: prototypeListCollectionViewController)
		navigationController.delegate = self

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

	// Hacks to show/hide navigation bar in prototypes so hack wow
	func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
		if viewController is PlayerViewController {
			navigationController.setNavigationBarHidden(true, animated: true)
			UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: .None) // view controller based status bar APIs interacts poorly with hiding/showing the navigation bar
		} else {
			navigationController.setNavigationBarHidden(false, animated: true)
			UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: .None)
		}
	}
}

