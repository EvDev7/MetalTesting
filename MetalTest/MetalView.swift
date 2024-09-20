import SwiftUI
import MetalKit

struct MetalView: UIViewRepresentable {
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> MTKView {
        // Create the MetalKit view
        let metalView = MTKView()
        metalView.device = MTLCreateSystemDefaultDevice()  // Use the default Metal device
        metalView.delegate = context.coordinator  // Set the delegate to the coordinator
        metalView.preferredFramesPerSecond = 60   // Set the frame rate
        metalView.clearColor = MTLClearColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1.0)  // Black background
        metalView.colorPixelFormat = .bgra8Unorm  // Set the pixel format
        context.coordinator.setupMetal(mtkView: metalView)  // Initialize the Metal pipeline
        return metalView
    }

    func updateUIView(_ uiView: MTKView, context: Context) {
        
    }
}


#Preview {
    MetalView()
}
