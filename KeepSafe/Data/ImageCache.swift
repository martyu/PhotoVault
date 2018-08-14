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
			print("loaded from cache \(url)")
			return image
		// Then check disk
		}
		///TODO: This was causing a performance hit. Find faster way.
		///Maybe keep a list of URLs that have been written to disk so we don't have to do a Keychain read to find out?
//		else if let imageData = imageKeychain[data: url.absoluteString] {
//			if let dataProvider = CGDataProvider(data: imageData as CFData),
//				let cgImage = CGImage(jpegDataProviderSource: dataProvider, decode: nil, shouldInterpolate: false, intent: .defaultIntent) {
//				let image = Image(cgImage: cgImage)
//				imageCache.setObject(image, forKey: url.absoluteNSString)
//				print("loaded from disk \(url)")
//				return image
//			}
//		}
		
		return nil
	}
	
	func set(image: Image, for url: URL) {
		imageCache.setObject(image, forKey: url.absoluteNSString)
	}
	
	///TODO: This was causing a performance hit. Find faster way.
	///Maybe keep a list of URLs that have been written to disk so we don't have to do a Keychain read to find out?
	func cache(_ cache: NSCache<AnyObject, AnyObject>, willEvictObject obj: Any) {
		guard
			let evictedImage = obj as? Image
		else { return }
		if let urlString = evictedImage.url?.absoluteString, imageKeychain[data: urlString] == nil {
//			imageKeychain[data: urlString] = evictedImage.cgImage?.dataProvider?.data as Data?
			print("evicted \(urlString)")
		}
	}
}
