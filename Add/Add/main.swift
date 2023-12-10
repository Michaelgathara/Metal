import MetalKit

let count: Int = 30000000
var firstArray = createArray()
var secondArray = createArray()

var CPUarray = CPU(arr1: firstArray, arr2: secondArray)
var GPUarray = GPU(arr1: firstArray, arr2: secondArray)

func CPU(arr1: [Float], arr2: [Float])->[Float] {
//    we kinda wanna time this
    let startTime = CFAbsoluteTimeGetCurrent()
    var res = [Float].init(repeating: 0.0, count: count)
    for i in 0..<count {
        res[i] = arr1[i] + arr2[i]
    }
    let elapsed = CFAbsoluteTimeGetCurrent() - startTime
    print("CPU elapsed time: \(String(format: "%0.05f", elapsed)) seconds")
    print()
    return res
}

func GPU(arr1: [Float], arr2: [Float])->[Float] {
    let startTime = CFAbsoluteTimeGetCurrent()
    
    let device = MTLCreateSystemDefaultDevice() // should only be one GPU, if not, big error
    
    let commandQueue = device?.makeCommandQueue()
    
    let gpuFunc = device?.makeDefaultLibrary()
    
    let GPUadd = gpuFunc?.makeFunction(name: "add")
    
    // GPU on Mac is stateful
    var addPipelineState: MTLComputePipelineState!
    do {
        addPipelineState = try device?.makeComputePipelineState(function: GPUadd!)
    } catch {
        print(error)
    }
    
    // These buffers help us share memory between CPU and GPU
    let arr1Buffer = device?.makeBuffer(bytes: arr1,
                                        length: MemoryLayout<Float>.size * count,
                                        options: .storageModeShared)
    let arr2Buffer = device?.makeBuffer(bytes: arr2,
                                        length: MemoryLayout<Float>.size * count,
                                        options: .storageModeShared)
    let resBuffer = device?.makeBuffer(length: MemoryLayout<Float>.size * count,
                                       options: .storageModeShared)
    
    let commandBuffer = commandQueue?.makeCommandBuffer()
    
    let commandEncoder = commandBuffer?.makeComputeCommandEncoder()
    commandEncoder?.setComputePipelineState(addPipelineState)
    
    commandEncoder?.setBuffer(arr1Buffer, offset: 0, index: 0)
    commandEncoder?.setBuffer(arr2Buffer, offset: 0, index: 1)
    commandEncoder?.setBuffer(resBuffer, offset: 0, index: 2)
    
    let threadsPerGrid = MTLSize(width: count, height: 1, depth: 1)
    let maxThreadsPerThreadGroup = addPipelineState.maxTotalThreadsPerThreadgroup
    let threadsPerThreadGroup = MTLSize(width: maxThreadsPerThreadGroup, height: 1, depth: 1)
    commandEncoder?.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerThreadGroup)
    
//    print("Finished encoding, can now send to GPU")
    commandEncoder?.endEncoding() // Should be done enoding and can be sent to the GPU
    
    commandBuffer?.commit()
    
    commandBuffer?.waitUntilCompleted()
    
    var resBufferPointer = resBuffer?.contents().bindMemory(to: Float.self,
                                                            capacity: MemoryLayout<Float>.size * count)
    var res = [Float](repeating: 0.0, count: count)

    if let resBufferPointer = resBuffer?.contents() {
        memcpy(&res, resBufferPointer, count * MemoryLayout<Float>.size)
    }
    
    let elapsed = CFAbsoluteTimeGetCurrent() - startTime
    print("GPU elapsed time: \(String(format: "%0.05f", elapsed)) seconds")
    print()
    
    return res
}

func createArray()->[Float] {
    var res = [Float].init(repeating: 0.0, count: count)
    for i in 0..<count {
        res[i] = Float(arc4random_uniform(1000000))
    }
    return res
}
