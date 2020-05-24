import SwiftUI
import PlaygroundSupport

struct ContentView: View {
    @State private var showImagePicker: Bool = false
    @State private var image: Image? = nil
    @State private var result: String?
    private var isHotDog: Bool {
        result?.contains("hot dog") ?? false
    }
    
    
    func dismiss() {
        showImagePicker = false
    }
    
    var body: some View {
        VStack(alignment: .center, spacing:0) {
            if image != nil && isHotDog {
                Rectangle()
                    .frame(height: 100)
                    .foregroundColor(.green)
                    .overlay(Text("Hot Dog")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.yellow))
            }
            ZStack {
                Rectangle()
                    .foregroundColor(.white)
                if image != nil {
                    image?
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    VStack {
                        Image(systemName: "camera")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(.gray)
                            .opacity(0.5)
                            .frame(width: 100, height: 100)
                        Text("Tap to take a photo")
                            .font(.subheadline)
                            .foregroundColor(.black)
                    }
                    
                }
                
            }
            .onTapGesture {
                self.showImagePicker = true
            }
            
            if image != nil && !isHotDog {
                Rectangle()
                    .frame(height: 100)
                    .foregroundColor(.red)
                    .overlay(Text("Not Hot Dog")
                        .foregroundColor(.yellow)
                        .fontWeight(.bold)
                        .font(.largeTitle))
            }
            
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(sourceType: .camera) { userPickedImage in
                let faces = userPickedImage.faces_Vision
                if faces.count > 0 {
                    self.result = "hot dog"
                    self.image = Image(uiImage: faces[0])
                    return
                } 
                
                self.image = Image(uiImage: userPickedImage)
                
                let detector = HotDogDetector()
                detector.detect(from: userPickedImage) { predictedResult in
                    self.result = predictedResult
                }
                
                
            }
        }
    }
}

//  struct ContentView_Previews: PreviewProvider {
//      static var previews: some View {
//          ContentView(showImagePicker: false, image: Image("HotDog"))
//      }
//  }
//  

PlaygroundPage.current.setLiveView(ContentView())
