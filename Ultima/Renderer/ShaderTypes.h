//
//  ShaderTypes.h
//  Ultima
//
//  Created by Taylor Sullivan on 12/4/20.
//

#ifndef ShaderTypes_h
#define ShaderTypes_h

#include <simd/simd.h>

typedef struct {
    vector_float2 position;
    vector_float2 textureCoordinate;
} Vertex;

#endif /* ShaderTypes_h */
