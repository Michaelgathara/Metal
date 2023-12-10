

#include <metal_stdlib>
using namespace metal;


kernel void add(constant float *arr1 [[ buffer(0) ]],
                constant float *arr2 [[ buffer(1) ]],
                device   float *res [[ buffer(2) ]],
                uint idx [[ thread_position_in_grid ]]) {
    res[idx] = arr1[idx] + arr2[idx];
}
