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

typealias ImageFetchCompletionHandler = ((Image?, NSError?) -> ())?

let sharedImageManager = ImageManager()

class ImageManager: NSObject {
	let imageCache = ImageCache()
	let operationQueue: OperationQueue = {
		let operationQueue = OperationQueue()
		operationQueue.qualityOfService = .userInitiated
		return operationQueue
	}()
	
	func prefetchImages(for urls: [URL]) {
		urls.forEach { [weak self] url in
			print("prefetching \(url)")
			self?.fetchImage(for: url)
		}
	}
	
	func cancelPrefetchingImages(for urls: [URL]) {
		urls.forEach { [weak self] url in
			print("canceling prefetch of \(url)")
			self?.cancelOperation(name: url.absoluteString)
		}
	}
	
	private func cancelOperation(name: String) {
		operationQueue.operations.first { operation in
			return operation.name == name
		}?.cancel()
	}
	
	func fetchImage(for url: URL, completion: ImageFetchCompletionHandler = nil) {
		if let image = imageCache.image(for: url) {
			completion?(image, nil)
		} else {
//			if checkIfImageLoadOpIsInQueue(url: url) == false {
				print("adding op \(operationQueue.operations.count) for \(url)")
				operationQueue.addOperation(imageLoadOperation(url: url, completion: completion))
//			} else {
//				print("op already in queue \(url)")
//			}
		}
	}
	
	private func checkIfImageLoadOpIsInQueue(url: URL) -> Bool {
		return operationQueue.operations.contains { $0.name == url.absoluteString }
	}
	
	private func imageLoadOperation(url: URL, completion: ImageFetchCompletionHandler) -> Operation {
		let imageLoadOp = ImageLoadOperation { [weak self] in
			do {
				let data = try Data(contentsOf: url)
				if let image = Image(data: data) {
					image.url = url
					self?.imageCache.set(image: image, for: url)
					DispatchQueue.main.async {
						completion?(image, nil)
					}
				}
			} catch {
				print(error)
				completion?(nil, error as NSError)
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
