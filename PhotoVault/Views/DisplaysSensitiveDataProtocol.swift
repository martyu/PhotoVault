//
//  DisplaysSensitiveDataProtocol.swift
//  KeepSafe
//
//  Created by Marty Ulrich on 8/13/18.
//  Copyright © 2018 marty. All rights reserved.
//

import Foundation
import UIKit
import PureLayout

protocol DisplaysSensitiveData {
	func hideSensitiveData()
	func showSensitiveData()
}

extension UIViewController: DisplaysSensitiveData {
	var blackoutViewTag: Int { return -1000 }
	func hideSensitiveData() {
		let blackoutView = UIView()
		blackoutView.backgroundColor = .black
		blackoutView.isUserInteractionEnabled = false
		view.addSubview(blackoutView)
		blackoutView.autoPinEdgesToSuperviewEdges()
		blackoutView.tag = blackoutViewTag
	}
	
	func showSensitiveData() {
		view.viewWithTag(blackoutViewTag)?.removeFromSuperview()
	}
	
	
}
