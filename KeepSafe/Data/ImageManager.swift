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
		operationQueue.maxConcurrentOperationCount = 5
		return operationQueue
	}()
	
	func fetchImage(for url: URL, completion: @escaping (Image?, NSError?) -> ()) {
		if let image = imageCache.image(for: url) {
			completion(image, nil)
		} else {
			if checkIfImageLoadOpIsInQueue(url: url) == false {
				print("adding op \(operationQueue.operations.count) for \(url)")
				operationQueue.addOperation(imageLoadOperation(url: url, completion: completion))
			} else {
				print("op already in queue \(url)")
			}
			if url.absoluteString == "https://farm3.staticflickr.com/2917/14351024987_1d9abf99fa_b.jpg" {
				print("match")
			}

		}
	}
	
	private func checkIfImageLoadOpIsInQueue(url: URL) -> Bool {
		return operationQueue.operations.contains { $0.name == url.absoluteString }
	}
	
	private func imageLoadOperation(url: URL, completion: @escaping (Image?, NSError?) -> ()) -> Operation {
		let imageLoadOp = ImageLoadOperation { [weak self] in
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
		imageLoadOp.name = url.absoluteString
		
		return imageLoadOp
	}
}

class ImageLoadOperation: BlockOperation {
	override var isConcurrent: Bool { return true }
}

extension URL {
	var absoluteNSString: NSString { return NSString(string: absoluteString) }
}
