//
//  PINEntryManager.swift
//  KeepSafe
//
//  Created by Marty Ulrich on 8/12/18.
//  Copyright © 2018 marty. All rights reserved.
//

import KeychainAccess

enum PINEntryResult {
	case correct
	case incorrect
	case continueEntering
	case newPINNeedsVerify // For creating a new PIN
	case newPINVerifyFailure // Verification failed for new PIN
	case newPINVerifySuccess // Verification succeeded for new PIN
}

struct PINEntryManager {
	private let PINLength = 4
	private let pinKeychain = Keychain(service: "com.keepsafe.pin")
	private var userID: String
	private var pinBuilder = ""
	private var verifyPinBuilder = "" // Used to verify PIN on creation
	private var verifyMode = false
	
	private var correctPIN: String? {
		if let correctPIN = pinKeychain[userID] {
			return correctPIN
		}
		return nil
	}
	
	init(userID: String) {
		self.userID = userID
	}
	
	mutating func digitEntered(_ digit: String) -> PINEntryResult {
		if verifyMode {
			verifyPinBuilder += digit
			if verifyPinBuilder.count == PINLength {
				if verifyPinBuilder == pinBuilder {
					// Save new PIN in keychain.
					pinKeychain[userID] = verifyPinBuilder
					clear()
					return .newPINVerifySuccess
				} else {
					clear()
					return .newPINVerifyFailure
				}
			}
		} else {
			pinBuilder += digit
			if pinBuilder.count == PINLength {
				// User entered a PIN *not* in verify mode
				if let correctPIN = correctPIN {
					// User has already saved a PIN
					if correctPIN == pinBuilder {
						clear()
						return .correct
					} else {
						clear()
						return .incorrect
					}
				} else {
					// User has not already saved a PIN.  New PIN.
					verifyMode = true
					return .newPINNeedsVerify
				}
			}
		}
		
		return .continueEntering
	}
	
	private mutating func clear() {
		verifyPinBuilder = ""
		pinBuilder = ""
		verifyMode = false
	}
}

