//
//  ImageManager.swift
//  KeepSafe
//
//  Created by Marty Ulrich on 8/12/18.
//  Copyright © 2018 marty. All rights reserved.
//

//import Foundation
//import UIKit
//
//class ImageManager {
//	let imageCache = NSCache<NSString, UIImage>()
//	func fetchImage(for url: URL, completion: @escaping (UIImage?, NSError?) -> ()) {
//		if let image = imageCache.object(forKey: url.absoluteNSString) {
//			completion(image, nil)
//		} else {
//			DispatchQueue.global(qos: .utility).async { [weak self] in
//				do {
//					let data = try Data(contentsOf: url)
//					if let image = UIImage(data: data) {
//						self?.imageCache.setObject(image, forKey: url.absoluteNSString)
//						DispatchQueue.main.async {
//							completion(image, nil)
//						}
//					}
//				} catch {
//					print(error)
//				}
//			}
//		}
//	}
//}
//
//extension URL {
//	var absoluteNSString: NSString { return NSString(string: absoluteString) }
//}
