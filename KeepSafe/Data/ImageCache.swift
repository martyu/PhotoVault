//
//  ImageCache.swift
//  KeepSafe
//
//  Created by Marty Ulrich on 8/13/18.
//  Copyright © 2018 marty. All rights reserved.
//

import Foundation
import KeychainAccess

class ImageCache: NSObject, NSCacheDelegate {
	private let imageCache = NSCache<NSString, Image>()
	private let imageKeychain = Keychain(service: "imageCache")
	
	override init() {
		super.init()
		imageCache.delegate = self
	}
	
	func image(for url: URL) -> Image? {
		// First check local cache
		if let image = imageCache.object(forKey: url.absoluteNSString) {
			return image
		// Then check disk
		} else if let imageData = imageKeychain[data: url.absoluteString] {
			if let image = Image(data: imageData) {
				imageCache.setObject(image, forKey: url.absoluteNSString)
				return image
			}
		}
		
		return nil
	}
	
	func set(image: Image, for url: URL) {
		imageCache.setObject(image, forKey: url.absoluteNSString)
	}
	
	func cache(_ cache: NSCache<AnyObject, AnyObject>, willEvictObject obj: Any) {
		guard
			let evictedImage = obj as? Image
		else { return }
		
		if let urlString = evictedImage.url?.absoluteString, imageKeychain[data: urlString] == nil {
			imageKeychain[data: urlString] = evictedImage.cgImage?.dataProvider?.data as Data?
			print("evicted \(urlString)")
		}
	}
}
