import Foundation
import SwiftUI
import UIKit
import Combine

public struct ImagePicker: UIViewControllerRepresentable {
    
    @Environment(\.presentationMode)
    var presentationMode
    
    var sourceType: UIImagePickerController.SourceType
    var onImagePicked: (UIImage) -> Void
    
    public init(sourceType type: UIImagePickerController.SourceType, completion: @escaping (UIImage) -> Void){
        sourceType = type
        onImagePicked = completion
    }
    
    final public class Coordinator: NSObject,
        UINavigationControllerDelegate,
    UIImagePickerControllerDelegate {
        
        @Binding
        private var presentationMode: PresentationMode
        let sourceType: UIImagePickerController.SourceType
        private let onImagePicked: (UIImage) -> Void
        
        init(presentationMode: Binding<PresentationMode>,
             sourceType: UIImagePickerController.SourceType,
             onImagePicked: @escaping (UIImage) -> Void) {
            _presentationMode = presentationMode
            self.sourceType = sourceType
            self.onImagePicked = onImagePicked
        }
        
        public func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            let uiImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
            onImagePicked(uiImage)
            presentationMode.dismiss()
            
        }
        
        public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            presentationMode.dismiss()
        }
        
    }
    
    public func makeCoordinator() -> Coordinator {
        return Coordinator(presentationMode: presentationMode,
                           sourceType: sourceType,
                           onImagePicked: onImagePicked)
    }
    
    public func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }
    
    public func updateUIViewController(_ uiViewController: UIImagePickerController,
                                context: UIViewControllerRepresentableContext<ImagePicker>) {
        
    }
    
}
