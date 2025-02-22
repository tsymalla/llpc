#version 450

layout(binding = 0) uniform Uniforms
{
    float f1;
};

layout(location = 0) out vec4 f;

void main()
{
    f = (isinf(f1)) ? vec4(0.0) : vec4(1.0);
}
// BEGIN_SHADERTEST
/*
; RUN: amdllpc -v %gfxip %s | FileCheck -check-prefix=SHADERTEST %s
; REQUIRES: do-not-run-me
; SHADERTEST-LABEL: {{^// LLPC}} SPIRV-to-LLVM translation results
; SHADERTEST: = call i1 (...) @lgc.create.isinf.i1(float

; SHADERTEST-LABEL: {{^// LLPC}} pipeline patching results
; SHADERTEST: %[[FABS:[0-9]+]] = call float @llvm.fabs.f32(float %{{[0-9]*}})
; SHADERTEST: = fcmp oeq float %[[FABS]], 0x7FF0000000000000

; SHADERTEST: AMDLLPC SUCCESS
*/
// END_SHADERTEST
