//
//  ViewController.swift
//  KeepSafe
//
//  Created by Marty Ulrich on 8/12/18.
//  Copyright © 2018 marty. All rights reserved.
//

import UIKit
import PureLayout

protocol PINViewControllerDelegate {
	func PINAccepted()
}

class PINViewController: UIViewController {
	private let pinLabel = UILabel()
	var delegate: PINViewControllerDelegate?
	private var userID: String = "user"
	private var pinEntryManager: PINEntryManager?
	private var clearPINLabelOnTap = false
	private let stackRowContainer = UIStackView()
	
	private func makePINButton(for int: Int) -> UIButton {
		let button = UIButton()
		button.tag = int
		button.setTitle(String(int), for: .normal)
		button.addTarget(self, action: #selector(digitPressed), for: .touchUpInside)
		button.setTitleColor(.blue, for: .normal)
		button.autoSetDimension(.height, toSize: 120)
		button.reversesTitleShadowWhenHighlighted = false

		return button
	}
	
	private func makeRowOfPINButtons(for ints: [Int]) -> UIStackView {
		let stackView = UIStackView(arrangedSubviews: ints.map { makePINButton(for: $0) })
		stackView.axis = .horizontal
		stackView.distribution = .fillEqually
		return stackView
	}
	
	private func makePINView(rows: [[Int]]) -> UIStackView {
		let stackRows = rows.map { makeRowOfPINButtons(for: $0) }
		let verticalStackView = UIStackView(arrangedSubviews: stackRows)
		verticalStackView.distribution = .fillEqually
		verticalStackView.axis = .vertical
		return verticalStackView
	}
	
	@objc
	private func digitPressed(_ sender: UIButton) {
		if clearPINLabelOnTap {
			setPINLabelText("")
			clearPINLabelOnTap = false
		}
		if let pinEntryResult = pinEntryManager?.digitEntered(String(sender.tag)) {
			switch pinEntryResult {
			case .correct:
				pinAccepted()
			case .incorrect:
				wrongPINEntered()
			case .newPINNeedsVerify:
				verifyNewPIN()
			case .newPINVerifyFailure:
				unmatchingPINsEntered()
			case .newPINVerifySuccess:
				pinSuccessfullyCreated()
			case .continueEntering:
				addPrivacyDotToPINLabel()
			}
		}
	}
	
	private func verifyNewPIN() {
		setStatusLabel("Please re-enter your PIN.")
	}
	
	private func pinSuccessfullyCreated() {
		delegate?.PINAccepted()
		setStatusLabel("PIN created")
	}
	
	private func pinAccepted() {
		delegate?.PINAccepted()
		setStatusLabel("PIN accepted")
	}
	
	private func wrongPINEntered() {
		setStatusLabel("Wrong PIN entered. Try again.")
	}
	
	private func unmatchingPINsEntered() {
		// User was creating a PIN, but entered a different one the second time.
		setStatusLabel("The second PIN you entered didn't match the first.")
	}
	
	private func setStatusLabel(_ status: String) {
		setPINLabelText(status)
		clearPINLabelOnTap = true
	}
	
	private func setPINLabelText(_ text: String) {
		pinLabel.text = text
	}
	
	private func addPrivacyDotToPINLabel() {
		let privacyDot = "•"
		if let pinLabelText = pinLabel.text {
			setPINLabelText(pinLabelText + privacyDot)
		} else {
			setPINLabelText(privacyDot)
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		let PINView = makePINView(rows: [
			[ 1, 2, 3 ],
			[ 4, 5, 6 ],
			[ 7, 8, 9 ],
			[ 0 ] ])
		
		view.addSubview(PINView)
		PINView.autoPinEdges(toSuperviewMarginsExcludingEdge: .top)
		
		view.addSubview(pinLabel)
		pinLabel.autoPinEdges(toSuperviewMarginsExcludingEdge: .bottom)
		pinLabel.autoPinEdge(.bottom, to: .top, of: PINView)
		pinLabel.textAlignment = .center
		
		pinEntryManager = PINEntryManager(userID: userID)
		
		view.backgroundColor = .white
		
		setStatusLabel("Please enter PIN")
	}
}
