//
//  Projections.swift
//  MetalTest
//
//  Created by Evan Rinehart on 9/21/24.
//

import simd

func orthographicProjectionMatrix(left: Float, right: Float, bottom: Float, top: Float, near: Float, far: Float) -> matrix_float4x4 {
    let x = 2.0 / (right - left)
    let y = 2.0 / (top - bottom)
    let z = 1.0 / (far - near)
    
    let tx = (right + left) / (left - right)
    let ty = (top + bottom) / (bottom - top)
    let tz = near / (near - far)
    
    return matrix_float4x4(columns: (
        SIMD4<Float>(x, 0, 0, 0),
        SIMD4<Float>(0, y, 0, 0),
        SIMD4<Float>(0, 0, z, 0),
        SIMD4<Float>(tx, ty, tz, 1)
    ))
}
