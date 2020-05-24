import UIKit
import Vision
import Foundation
import Accelerate

extension CGImagePropertyOrientation {
    init(_ uiOrientation: UIImage.Orientation) {
        switch uiOrientation {
        case .up: self = .up
        case .upMirrored: self = .upMirrored
        case .down: self = .down
        case .downMirrored: self = .downMirrored
        case .left: self = .left
        case .leftMirrored: self = .leftMirrored
        case .right: self = .right
        case .rightMirrored: self = .rightMirrored
        }
    }
}

extension UIImage {
    public var ciImage: CIImage? {
        guard let data = self.pngData() else { return nil }
        return CIImage(data: data)
    }
    
    public func imageRotated(by radians: CGFloat) -> UIImage {
        let orientation = CGImagePropertyOrientation(self.imageOrientation)
        
        // Create CIImage respecting image's orientation 
        guard let inputImage = CIImage(image: self)?.oriented(orientation) 
            else { return self }
        
        // Rotate the image itself
        let rotation = CGAffineTransform(rotationAngle: radians)
        let outputImage = inputImage.transformed(by: rotation)
        
        // Create CGImage first
        guard let cgImage = CIContext().createCGImage(outputImage, from: outputImage.extent) 
            else { return self }
        
        // Create output UIImage from CGImage
        return UIImage(cgImage: cgImage)
    }
    
    func rotate(radians: CGFloat) -> UIImage {
        let rotatedSize = CGRect(origin: .zero, size: size)
            .applying(CGAffineTransform(rotationAngle: CGFloat(radians)))
            .integral.size
        UIGraphicsBeginImageContext(rotatedSize)
        if let context = UIGraphicsGetCurrentContext() {
            let origin = CGPoint(x: rotatedSize.width / 2.0,
                                 y: rotatedSize.height / 2.0)
            context.translateBy(x: origin.x, y: origin.y)
            context.rotate(by: radians)
            draw(in: CGRect(x: -origin.y, y: -origin.x,
                            width: size.width, height: size.height))
            let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return rotatedImage ?? self
        }
        
        return self
    }
    
    public var faces_Vision: [UIImage] {
        guard let ciImage = ciImage else { return [] }
//          let mirroredCIImage = ciImage.oriented(.upMirrored)
        let faceDetectionRequest = VNDetectFaceRectanglesRequest()
        try! VNImageRequestHandler(ciImage: ciImage).perform([faceDetectionRequest])
        
        guard let results = faceDetectionRequest.results as? [VNFaceObservation] else { return [] }
        
        let uiImage = UIImage(ciImage: ciImage)
        let hotdog = #imageLiteral(resourceName: "snapchat_hotdog-removebg-preview.png")
        let widthRatio = CGFloat(0.195895522)
        let heightRatio = CGFloat(0.225806452)
        let xRatio = CGFloat(0.4056)
        let yRatio = CGFloat(0.22)
        
        return results.map {
//              let rotatedHotdog = hotdog.rotate(radians: 0 - CGFloat($0.roll!))
            let rotatedHotdog = hotdog.imageRotated(by: CGFloat($0.roll!))
            
            let finalImageWidth  = max(size.width,  size.width )
            let finalImageHeight = max(size.height, size.height)
            let finalImageSize = CGSize(width : finalImageWidth, height: finalImageHeight)
            
            let rect = $0.boundingBox
            let w_diff_ratio = ((rect.width * size.width) - (hotdog.size.width * widthRatio)) / 100
            let h_diff_ratio = ((rect.height * size.height) - (hotdog.size.height * heightRatio)) / 100
            let w = hotdog.size.width + (w_diff_ratio * hotdog.size.width)
            let h = hotdog.size.height + (h_diff_ratio * hotdog.size.height)
            
            let x = (rect.origin.x * size.width) - (w * xRatio)
            let y = size.height * (1-rect.origin.y) - (rect.height * size.height) - (h * yRatio)
            
            let conv_rect = CGRect(x: x, y: y, width: w, height: h)
            
            // Start combining iimages
            UIGraphicsBeginImageContextWithOptions(finalImageSize, false, UIScreen.main.scale)
            
            uiImage.draw(at: CGPoint(x: 0,  y: 0))
            rotatedHotdog.draw(in: conv_rect)
            
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return image!
        }
    }
}
