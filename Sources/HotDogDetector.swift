import SwiftUI
import Vision
import CoreML


public struct HotDogDetector {
    
    public init() {}

    public func detect(from image: UIImage, completion: @escaping (_ result: String) -> Void ){
        guard let ciImage = CIImage(image: image) else {
            fatalError("Failed to convert UIImage to CIImage.")
        }
        
        guard let model = try? VNCoreMLModel(for: SqueezeNet().model) else {
            fatalError("Loading CoreML model failed")
        }
        
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("Model failed to process image")
            }
            
            if let firstResult = results.first {
                completion(firstResult.identifier)
            }
        }
        
        let handler = VNImageRequestHandler(ciImage: ciImage)
        
        do {
            try handler.perform([request])
        } catch {
            print("Could not handle Image request. \(error)")
        }
    }
}
