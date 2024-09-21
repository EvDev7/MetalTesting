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
    var colorBuffer: MTLBuffer?

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
        let vertexData: [SIMD3<Float>] = [
            SIMD3<Float>(0.0, 1.0, 0.0),    // Top
            SIMD3<Float>(-1.0, 0.0, 0.0),   // Bottom left
            SIMD3<Float>(1.0, 0.0, 0.0)     // Bottom right
        ]
        
        let colorData: [SIMD4<Float>] = [
            SIMD4<Float>(1.0, 0.0, 0.0, 1.0),  // Red
            SIMD4<Float>(0.0, 1.0, 0.0, 1.0),  // Green
            SIMD4<Float>(0.0, 0.0, 1.0, 1.0)   // Blue
        ]

        // Create a vertex buffer
        vertexBuffer = device.makeBuffer(bytes: vertexData, length: vertexData.count * MemoryLayout<SIMD3<Float>>.size, options: [])
        
        colorBuffer = device.makeBuffer(bytes: colorData, length: colorData.count * MemoryLayout<SIMD4<Float>>.size, options: [])

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
              let colorBuffer = colorBuffer
        else { return }

        let commandBuffer = commandQueue.makeCommandBuffer()
        let renderEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: passDescriptor)
        renderEncoder?.setRenderPipelineState(pipelineState)
        renderEncoder?.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        renderEncoder?.setVertexBuffer(colorBuffer, offset: 0, index: 1)
        renderEncoder?.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3)
        renderEncoder?.endEncoding()

        commandBuffer?.present(drawable)
        commandBuffer?.commit()
    }
}

#Preview {
    MetalView()
}
