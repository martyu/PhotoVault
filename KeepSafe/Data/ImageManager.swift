//
//  ImageManager.swift
//  KeepSafe
//
//  Created by Marty Ulrich on 8/12/18.
//  Copyright © 2018 marty. All rights reserved.
//

import Foundation
import UIKit

class Image: UIImage {
	var url: URL?
}

let sharedImageManager = ImageManager()

class ImageManager: NSObject {
	let imageCache = ImageCache()
	let operationQueue: OperationQueue = {
		let operationQueue = OperationQueue()
		operationQueue.qualityOfService = .userInitiated
		return operationQueue
	}()
	
	func fetchImage(for url: URL, completion: @escaping (Image?, NSError?) -> ()) {
		if let image = imageCache.image(for: url) {
			print("loaded from cache \(url)")
			completion(image, nil)
		} else {
			print("adding op \(operationQueue.operations.count) for \(url)")
			operationQueue.addOperation(imageLoadOperation(url: url, completion: completion))
		}
	}
	
	private func imageLoadOperation(url: URL, completion: @escaping (Image?, NSError?) -> ()) -> Operation {
		let imageLoadOp = BlockOperation { [weak self] in
			do {
				let data = try Data(contentsOf: url)
				if let image = Image(data: data) {
					image.url = url
					self?.imageCache.set(image: image, for: url)
					DispatchQueue.main.async {
						completion(image, nil)
					}
				}
			} catch {
				print(error)
				completion(nil, error as NSError)
			}
		}
		return imageLoadOp
	}
}

extension URL {
	var absoluteNSString: NSString { return NSString(string: absoluteString) }
}
