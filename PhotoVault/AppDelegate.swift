//
//  AppDelegate.swift
//  KeepSafe
//
//  Created by Marty Ulrich on 8/12/18.
//  Copyright © 2018 marty. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, PINViewControllerDelegate {

	var window: UIWindow?
	
	var pinViewController: PINViewController?
	func makePinViewController() -> PINViewController {
		let pinViewController = PINViewController()
		pinViewController.delegate = self
		return pinViewController
	}

	func PINAccepted() {
		showPinView(false)
	}
	
	func showPinView(_ show: Bool) {
		if show, pinViewController?.view.superview == nil {
			pinViewController = makePinViewController()
		}
		
		guard
			let rootViewController = window?.rootViewController,
			let pinViewController = pinViewController
		else {
			assert(false, "No view controller")
			return
		}
		
		if show {
			rootViewController.view.addSubview(pinViewController.view)
			rootViewController.addChildViewController(pinViewController)
			pinViewController.view.autoPinEdgesToSuperviewEdges()
		} else {
			pinViewController.view.removeFromSuperview()
			pinViewController.removeFromParentViewController()
			self.pinViewController = nil
		}
	}
	
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		showPinView(true)
		return true
	}

	func applicationWillResignActive(_ application: UIApplication) {
		showPinView(true)
	}

	func applicationDidEnterBackground(_ application: UIApplication) {
		// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
		// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	}

	func applicationWillEnterForeground(_ application: UIApplication) {
		// Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
	}

	func applicationDidBecomeActive(_ application: UIApplication) {
		// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	}

	func applicationWillTerminate(_ application: UIApplication) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
	}


}

