//
//  ImageExtensions.swift
//  KeepSafe
//
//  Created by Marty Ulrich on 8/13/18.
//  Copyright © 2018 marty. All rights reserved.
//

import Foundation
import UIKit

extension Image {
	func decodedImage(_ image: Image) -> Image? {
		guard let newImage = image.cgImage else { return nil }
		
		let colorSpace = CGColorSpaceCreateDeviceRGB()
		let context = CGContext(data: nil, width: newImage.width, height: newImage.height, bitsPerComponent: 8, bytesPerRow: newImage.width * 4, space: colorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
		
		context?.draw(newImage, in: CGRect(x: 0, y: 0, width: newImage.width, height: newImage.height))
		let drawnImage = context?.makeImage()
		
		if let drawnImage = drawnImage {
			return Image(cgImage: drawnImage)
		}
		return nil
	}
}
