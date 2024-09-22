//
//  Coordinator.swift
//  MetalTest
//
//  Created by Evan Rinehart on 9/14/24.
//

import MetalKit
import SwiftUI

class Coordinator: NSObject, MTKViewDelegate {
    var parent: MetalView
    var commandQueue: MTLCommandQueue?
    var pipelineState: MTLRenderPipelineState?
    var vertexBuffer: MTLBuffer?
    var texCoordBuffer: MTLBuffer?
    var colorTexture: MTLTexture?
    var vertexData: [SIMD3<Float>] = []
    var texCoordData: [SIMD2<Float>] = []
    var projectionMatrix: matrix_float4x4 = orthographicProjectionMatrix(left: -1, right: 1, bottom: -1, top: 1, near: 0, far: 1)
    var uniformBuffer: MTLBuffer?

    init(_ parent: MetalView) {
        self.parent = parent
        super.init()
    }

    func setupMetal(mtkView: MTKView) {
        guard let device = mtkView.device else {
            return
        }

        // Set up command queue
        commandQueue = device.makeCommandQueue()

        // Define the vertex data for a triangle
        // Define the vertex data as float3
        vertexData = [
            SIMD3<Float>(-1.0, 1.0, 0.0),    // Top left
            SIMD3<Float>(-1.0, 0.0, 0.0),   // Bottom left
            SIMD3<Float>(1.0, 0.0, 0.0),     // Bottom right
            SIMD3<Float>(-1.0, 1.0, 0.0),    // Top left
            SIMD3<Float>(1.0, 0.0, 0.0),     // Bottom right
            SIMD3<Float>(1.0, 1.0, 0.0)     // Top right
        ]
        
        // Samples from the top left
        texCoordData = [
            SIMD2<Float>(0.0, 0.0), // Top left
            SIMD2<Float>(0.0, 1.0), // Bottom left
            SIMD2<Float>(1.0, 1.0),  // Bottom right
            SIMD2<Float>(0.0, 0.0), // Top left
            SIMD2<Float>(1.0, 1.0),  // Bottom right
            SIMD2<Float>(1.0, 0.0),  // Top right
        ]

        // Create a vertex buffer
        vertexBuffer = device.makeBuffer(bytes: vertexData, length: vertexData.count * MemoryLayout<SIMD3<Float>>.size, options: [])
        
        texCoordBuffer = device.makeBuffer(bytes: texCoordData, length: texCoordData.count * MemoryLayout<SIMD2<Float>>.size, options: [])
        
        uniformBuffer = device.makeBuffer(bytes: &projectionMatrix, length: MemoryLayout<matrix_float4x4>.size, options: [])
        
        let loader = MTKTextureLoader(device: device)
        do {
            // Enable mipmaps generation
            let textureLoaderOptions: [MTKTextureLoader.Option: Any] = [
                .generateMipmaps: true
            ]
            
            // Make sure if using PNG that they are 32 bit format, otherwise will fail to load
            if let url = Bundle.main.url(forResource: "squirtle", withExtension: "png") {
                self.colorTexture = try loader.newTexture(URL: url, options: textureLoaderOptions)
            } else {
                print("URL for not found.")
            }
        } catch {
            print("Failed to load image 'image.png'")
        }

        // Set up the Metal pipeline
        let library = device.makeDefaultLibrary()
        let vertexFunction = library?.makeFunction(name: "vertex_main")
        let fragmentFunction = library?.makeFunction(name: "fragment_main")

        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.colorAttachments[0].pixelFormat = mtkView.colorPixelFormat

        do {
            pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch {
            print("Error creating pipeline state: \(error)")
        }
    }

    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
    }

    func draw(in view: MTKView) {
        guard let drawable = view.currentDrawable,
              let passDescriptor = view.currentRenderPassDescriptor,
              let commandQueue = commandQueue,
              let pipelineState = pipelineState,
              let vertexBuffer = vertexBuffer,
              let texCoordBuffer = texCoordBuffer,
              let colorTexture = colorTexture
        else { return }

        let commandBuffer = commandQueue.makeCommandBuffer()
        let renderEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: passDescriptor)
        renderEncoder?.setRenderPipelineState(pipelineState)
        renderEncoder?.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        renderEncoder?.setVertexBuffer(texCoordBuffer, offset: 0, index: 1)
        renderEncoder?.setFragmentTexture(colorTexture, index: 0)
        renderEncoder?.setVertexBuffer(uniformBuffer, offset: 0, index: 2)
        renderEncoder?.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertexData.count)
        renderEncoder?.endEncoding()

        commandBuffer?.present(drawable)
        commandBuffer?.commit()
    }
}

#Preview {
    MetalView()
}
