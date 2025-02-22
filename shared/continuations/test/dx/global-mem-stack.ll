; NOTE: Assertions have been autogenerated by utils/update_test_checks.py UTC_ARGS: --include-generated-funcs --version 3
; RUN: opt --verify-each -passes='dxil-cont-lgc-rt-op-converter,lint,lower-raytracing-pipeline,lint,inline,lint,dxil-cont-pre-coroutine,lint,sroa,lint,lower-await,lint,coro-early,dxil-coro-split,coro-cleanup,lint,legacy-cleanup-continuations,lint,register-buffer,lint,save-continuation-state,lint,dxil-cont-post-process,lint,remove-types-metadata' -S %s 2>%t.stderr | FileCheck %s
; RUN: count 0 < %t.stderr

target datalayout = "e-m:e-p:64:32-p20:32:32-p21:32:32-i1:32-i8:8-i16:32-i32:32-i64:32-f16:32-f32:32-f64:32-v16:32-v32:32-v48:32-v64:32-v80:32-v96:32-v112:32-v128:32-v144:32-v160:32-v176:32-v192:32-v208:32-v224:32-v240:32-v256:32-n8:16:32"

%struct.DispatchSystemData = type { <3 x i32> }
%struct.TraversalData = type { %struct.SystemData, %struct.HitData, <3 x float>, <3 x float>, float, i64 }
%struct.SystemData = type { %struct.DispatchSystemData, %struct.BuiltInTriangleIntersectionAttributes }
%struct.BuiltInTriangleIntersectionAttributes = type { <2 x float> }
%struct.HitData = type { float, i32 }
%struct.RayPayload = type { <4 x float> }

declare i32 @_cont_GetContinuationStackAddr()

declare i64 @_cont_GetContinuationStackGlobalMemBase()

declare %struct.DispatchSystemData @_cont_SetupRayGen()

declare %struct.DispatchSystemData @_AmdAwaitTraversal(i64, %struct.TraversalData)

declare %struct.DispatchSystemData @_AmdAwaitShader(i64, %struct.DispatchSystemData)

declare %struct.TraversalData @_AmdAwaitAnyHit(i64, %struct.TraversalData, float, i32)

declare !types !9 i32 @_cont_HitKind(%struct.SystemData*)

declare i64 @_AmdGetResumePointAddr()

declare !types !11 %struct.HitData @_cont_GetCommittedState(%struct.SystemData*)

declare !types !12 void @_AmdRestoreSystemData(%struct.DispatchSystemData*)

declare !types !14 void @_AmdRestoreSystemDataAnyHit(%struct.TraversalData*)

declare !types !14 void @_cont_AcceptHit(%struct.TraversalData* nocapture readnone)

declare !types !14 void @_AmdAcceptHitAttributes(%struct.TraversalData*)

declare i1 @opaqueIsEnd()

define i1 @_cont_IsEndSearch(%struct.TraversalData* %data) !types !16 {
  %isEnd = call i1 @opaqueIsEnd()
  ret i1 %isEnd
}

define %struct.BuiltInTriangleIntersectionAttributes @_cont_GetTriangleHitAttributes(%struct.SystemData* %data) !types !17 {
  %addr = getelementptr %struct.SystemData, %struct.SystemData* %data, i32 0, i32 1
  %val = load %struct.BuiltInTriangleIntersectionAttributes, %struct.BuiltInTriangleIntersectionAttributes* %addr, align 4
  ret %struct.BuiltInTriangleIntersectionAttributes %val
}

define void @_cont_SetTriangleHitAttributes(%struct.SystemData* %data, %struct.BuiltInTriangleIntersectionAttributes %val) !types !18 {
  %addr = getelementptr %struct.SystemData, %struct.SystemData* %data, i32 0, i32 1
  store %struct.BuiltInTriangleIntersectionAttributes %val, %struct.BuiltInTriangleIntersectionAttributes* %addr, align 4
  ret void
}

define i32 @_cont_GetLocalRootIndex(%struct.DispatchSystemData* %data) !types !19 {
  ret i32 5
}

declare !types !20 i32 @_cont_DispatchRaysIndex(%struct.DispatchSystemData* nocapture readnone, i32)

declare !types !21 float @_cont_ObjectRayOrigin(%struct.DispatchSystemData* nocapture readnone, %struct.HitData*, i32)

declare !types !21 float @_cont_ObjectRayDirection(%struct.DispatchSystemData* nocapture readnone, %struct.HitData*, i32)

declare !types !12 void @_cont_AcceptHitAndEndSearch(%struct.DispatchSystemData* nocapture readnone)

define void @MyClosestHitShader(%struct.RayPayload* noalias nocapture %payload, %struct.BuiltInTriangleIntersectionAttributes* nocapture readonly %attr) !types !23 {
  %1 = getelementptr inbounds %struct.BuiltInTriangleIntersectionAttributes, %struct.BuiltInTriangleIntersectionAttributes* %attr, i32 0, i32 0
  %2 = load <2 x float>, <2 x float>* %1, align 4
  %3 = extractelement <2 x float> %2, i32 0
  %4 = fsub fast float 1.000000e+00, %3
  %5 = extractelement <2 x float> %2, i32 1
  %6 = fsub fast float %4, %5
  %7 = insertelement <4 x float> undef, float %6, i64 0
  %8 = insertelement <4 x float> %7, float %3, i64 1
  %9 = insertelement <4 x float> %8, float %5, i64 2
  %10 = insertelement <4 x float> %9, float 1.000000e+00, i64 3
  %11 = getelementptr inbounds %struct.RayPayload, %struct.RayPayload* %payload, i32 0, i32 0
  store <4 x float> %10, <4 x float>* %11, align 4
  ret void
}

!dx.shaderModel = !{!0}
!dx.resources = !{!1}
!dx.entryPoints = !{!2, !4}
!continuation.stackAddrspace = !{!7}
!continuation.maxPayloadRegisterCount = !{!8}

!0 = !{!"lib", i32 6, i32 6}
!1 = !{null, null, null, null}
!2 = !{null, !"", null, !1, !3}
!3 = !{i32 0, i64 65536}
!4 = !{void (%struct.RayPayload*, %struct.BuiltInTriangleIntersectionAttributes*)* @MyClosestHitShader, !"MyClosestHitShader", null, null, !5}
!5 = !{i32 8, i32 10, i32 6, i32 16, i32 7, i32 8, i32 5, !6}
!6 = !{i32 0}
!7 = !{i32 22}
!8 = !{i32 2}
!9 = !{!"function", i32 poison, !10}
!10 = !{i32 0, %struct.SystemData poison}
!11 = !{!"function", %struct.HitData poison, !10}
!12 = !{!"function", !"void", !13}
!13 = !{i32 0, %struct.DispatchSystemData poison}
!14 = !{!"function", !"void", !15}
!15 = !{i32 0, %struct.TraversalData poison}
!16 = !{!"function", i1 poison, !15}
!17 = !{!"function", %struct.BuiltInTriangleIntersectionAttributes poison, !10}
!18 = !{!"function", !"void", !10, %struct.BuiltInTriangleIntersectionAttributes poison}
!19 = !{!"function", i32 poison, !13}
!20 = !{!"function", i32 poison, !13, i32 poison}
!21 = !{!"function", float poison, !13, !22, i32 poison}
!22 = !{i32 0, %struct.HitData poison}
!23 = !{!"function", !"void", !24, !25}
!24 = !{i32 0, %struct.RayPayload poison}
!25 = !{i32 0, %struct.BuiltInTriangleIntersectionAttributes poison}
; CHECK-LABEL: define i1 @_cont_IsEndSearch(
; CHECK-SAME: ptr [[DATA:%.*]]) {
; CHECK-NEXT:    [[ISEND:%.*]] = call i1 @opaqueIsEnd()
; CHECK-NEXT:    ret i1 [[ISEND]]
;
;
; CHECK-LABEL: define %struct.BuiltInTriangleIntersectionAttributes @_cont_GetTriangleHitAttributes(
; CHECK-SAME: ptr [[DATA:%.*]]) {
; CHECK-NEXT:    [[ADDR:%.*]] = getelementptr [[STRUCT_SYSTEMDATA:%.*]], ptr [[DATA]], i32 0, i32 1
; CHECK-NEXT:    [[VAL:%.*]] = load [[STRUCT_BUILTINTRIANGLEINTERSECTIONATTRIBUTES:%.*]], ptr [[ADDR]], align 4
; CHECK-NEXT:    ret [[STRUCT_BUILTINTRIANGLEINTERSECTIONATTRIBUTES]] [[VAL]]
;
;
; CHECK-LABEL: define void @_cont_SetTriangleHitAttributes(
; CHECK-SAME: ptr [[DATA:%.*]], [[STRUCT_BUILTINTRIANGLEINTERSECTIONATTRIBUTES:%.*]] [[VAL:%.*]]) {
; CHECK-NEXT:    [[ADDR:%.*]] = getelementptr [[STRUCT_SYSTEMDATA:%.*]], ptr [[DATA]], i32 0, i32 1
; CHECK-NEXT:    store [[STRUCT_BUILTINTRIANGLEINTERSECTIONATTRIBUTES]] [[VAL]], ptr [[ADDR]], align 4
; CHECK-NEXT:    ret void
;
;
; CHECK-LABEL: define i32 @_cont_GetLocalRootIndex(
; CHECK-SAME: ptr [[DATA:%.*]]) {
; CHECK-NEXT:    ret i32 5
;
;
; CHECK-LABEL: define void @MyClosestHitShader(
; CHECK-SAME: i32 [[CSPINIT:%.*]], i64 [[RETURNADDR:%.*]], [[STRUCT_SYSTEMDATA:%.*]] [[TMP0:%.*]]) !continuation.registercount !8 !continuation !9 !continuation.state !6 {
; CHECK-NEXT:  AllocaSpillBB:
; CHECK-NEXT:    [[SYSTEM_DATA:%.*]] = alloca [[STRUCT_SYSTEMDATA]], align 8
; CHECK-NEXT:    [[CONT_STATE:%.*]] = alloca [0 x i32], align 4
; CHECK-NEXT:    [[CSP:%.*]] = alloca i32, align 4
; CHECK-NEXT:    store [[STRUCT_SYSTEMDATA]] [[TMP0]], ptr [[SYSTEM_DATA]], align 4
; CHECK-NEXT:    store i32 [[CSPINIT]], ptr [[CSP]], align 4
; CHECK-NEXT:    [[TMP1:%.*]] = load [[STRUCT_SYSTEMDATA]], ptr [[SYSTEM_DATA]], align 4
; CHECK-NEXT:    [[DOTFCA_0_0_EXTRACT:%.*]] = extractvalue [[STRUCT_SYSTEMDATA]] [[TMP1]], 0, 0
; CHECK-NEXT:    [[DOTFCA_1_0_EXTRACT:%.*]] = extractvalue [[STRUCT_SYSTEMDATA]] [[TMP1]], 1, 0
; CHECK-NEXT:    call void @amd.dx.setLocalRootIndex(i32 5)
; CHECK-NEXT:    [[TMP2:%.*]] = load i32, ptr addrspace(20) @REGISTERS, align 4
; CHECK-NEXT:    [[TMP3:%.*]] = call i64 @_cont_GetContinuationStackGlobalMemBase()
; CHECK-NEXT:    [[TMP4:%.*]] = inttoptr i64 [[TMP3]] to ptr addrspace(22)
; CHECK-NEXT:    [[TMP5:%.*]] = getelementptr i8, ptr addrspace(22) [[TMP4]], i32 [[TMP2]]
; CHECK-NEXT:    [[TMP6:%.*]] = getelementptr i32, ptr addrspace(22) [[TMP5]], i32 -2
; CHECK-NEXT:    [[TMP7:%.*]] = getelementptr [[STRUCT_RAYPAYLOAD_ATTR_MAX_8_I32S_LAYOUT_3_CLOSESTHIT_IN_PAYLOAD_ATTR_0_I32S:%.*]], ptr addrspace(22) [[TMP6]], i32 0, i32 0, i32 7
; CHECK-NEXT:    [[TMP8:%.*]] = load i32, ptr addrspace(22) [[TMP7]], align 4
; CHECK-NEXT:    [[TMP9:%.*]] = bitcast i32 [[TMP8]] to float
; CHECK-NEXT:    [[DOTSROA_0_0_VEC_INSERT:%.*]] = insertelement <4 x float> undef, float [[TMP9]], i32 0
; CHECK-NEXT:    [[TMP10:%.*]] = load i32, ptr addrspace(20) @REGISTERS, align 4
; CHECK-NEXT:    [[TMP11:%.*]] = call i64 @_cont_GetContinuationStackGlobalMemBase()
; CHECK-NEXT:    [[TMP12:%.*]] = inttoptr i64 [[TMP11]] to ptr addrspace(22)
; CHECK-NEXT:    [[TMP13:%.*]] = getelementptr i8, ptr addrspace(22) [[TMP12]], i32 [[TMP10]]
; CHECK-NEXT:    [[TMP14:%.*]] = getelementptr i32, ptr addrspace(22) [[TMP13]], i32 -2
; CHECK-NEXT:    [[TMP15:%.*]] = getelementptr [[STRUCT_RAYPAYLOAD_ATTR_MAX_8_I32S_LAYOUT_3_CLOSESTHIT_IN_PAYLOAD_ATTR_0_I32S]], ptr addrspace(22) [[TMP14]], i32 0, i32 0, i64 8
; CHECK-NEXT:    [[TMP16:%.*]] = load i32, ptr addrspace(22) [[TMP15]], align 4
; CHECK-NEXT:    [[TMP17:%.*]] = bitcast i32 [[TMP16]] to float
; CHECK-NEXT:    [[DOTSROA_0_4_VEC_INSERT:%.*]] = insertelement <4 x float> [[DOTSROA_0_0_VEC_INSERT]], float [[TMP17]], i32 1
; CHECK-NEXT:    [[TMP18:%.*]] = load i32, ptr addrspace(20) @REGISTERS, align 4
; CHECK-NEXT:    [[TMP19:%.*]] = call i64 @_cont_GetContinuationStackGlobalMemBase()
; CHECK-NEXT:    [[TMP20:%.*]] = inttoptr i64 [[TMP19]] to ptr addrspace(22)
; CHECK-NEXT:    [[TMP21:%.*]] = getelementptr i8, ptr addrspace(22) [[TMP20]], i32 [[TMP18]]
; CHECK-NEXT:    [[TMP22:%.*]] = getelementptr i32, ptr addrspace(22) [[TMP21]], i32 -2
; CHECK-NEXT:    [[TMP23:%.*]] = getelementptr [[STRUCT_RAYPAYLOAD_ATTR_MAX_8_I32S_LAYOUT_3_CLOSESTHIT_IN_PAYLOAD_ATTR_0_I32S]], ptr addrspace(22) [[TMP22]], i32 0, i32 0, i64 9
; CHECK-NEXT:    [[TMP24:%.*]] = load i32, ptr addrspace(22) [[TMP23]], align 4
; CHECK-NEXT:    [[TMP25:%.*]] = bitcast i32 [[TMP24]] to float
; CHECK-NEXT:    [[DOTSROA_0_8_VEC_INSERT:%.*]] = insertelement <4 x float> [[DOTSROA_0_4_VEC_INSERT]], float [[TMP25]], i32 2
; CHECK-NEXT:    [[TMP26:%.*]] = load i32, ptr addrspace(20) @REGISTERS, align 4
; CHECK-NEXT:    [[TMP27:%.*]] = call i64 @_cont_GetContinuationStackGlobalMemBase()
; CHECK-NEXT:    [[TMP28:%.*]] = inttoptr i64 [[TMP27]] to ptr addrspace(22)
; CHECK-NEXT:    [[TMP29:%.*]] = getelementptr i8, ptr addrspace(22) [[TMP28]], i32 [[TMP26]]
; CHECK-NEXT:    [[TMP30:%.*]] = getelementptr i32, ptr addrspace(22) [[TMP29]], i32 -2
; CHECK-NEXT:    [[TMP31:%.*]] = getelementptr [[STRUCT_RAYPAYLOAD_ATTR_MAX_8_I32S_LAYOUT_3_CLOSESTHIT_IN_PAYLOAD_ATTR_0_I32S]], ptr addrspace(22) [[TMP30]], i32 0, i32 0, i64 10
; CHECK-NEXT:    [[TMP32:%.*]] = load i32, ptr addrspace(22) [[TMP31]], align 4
; CHECK-NEXT:    [[TMP33:%.*]] = bitcast i32 [[TMP32]] to float
; CHECK-NEXT:    [[DOTSROA_0_12_VEC_INSERT:%.*]] = insertelement <4 x float> [[DOTSROA_0_8_VEC_INSERT]], float [[TMP33]], i32 3
; CHECK-NEXT:    [[VAL_I_FCA_0_INSERT:%.*]] = insertvalue [[STRUCT_BUILTINTRIANGLEINTERSECTIONATTRIBUTES:%.*]] poison, <2 x float> [[DOTFCA_1_0_EXTRACT]], 0
; CHECK-NEXT:    [[VAL_I_FCA_0_INSERT_FCA_0_EXTRACT:%.*]] = extractvalue [[STRUCT_BUILTINTRIANGLEINTERSECTIONATTRIBUTES]] [[VAL_I_FCA_0_INSERT]], 0
; CHECK-NEXT:    [[DOTSROA_06_0_VEC_EXTRACT:%.*]] = extractelement <2 x float> [[VAL_I_FCA_0_INSERT_FCA_0_EXTRACT]], i32 0
; CHECK-NEXT:    [[TMP34:%.*]] = bitcast float [[DOTSROA_06_0_VEC_EXTRACT]] to i32
; CHECK-NEXT:    [[TMP35:%.*]] = bitcast i32 [[TMP34]] to float
; CHECK-NEXT:    [[HITATTRS_SROA_0_0_VEC_INSERT:%.*]] = insertelement <2 x float> undef, float [[TMP35]], i32 0
; CHECK-NEXT:    [[DOTSROA_06_4_VEC_EXTRACT:%.*]] = extractelement <2 x float> [[VAL_I_FCA_0_INSERT_FCA_0_EXTRACT]], i32 1
; CHECK-NEXT:    [[TMP36:%.*]] = bitcast float [[DOTSROA_06_4_VEC_EXTRACT]] to i32
; CHECK-NEXT:    [[TMP37:%.*]] = bitcast i32 [[TMP36]] to float
; CHECK-NEXT:    [[HITATTRS_SROA_0_4_VEC_INSERT:%.*]] = insertelement <2 x float> [[HITATTRS_SROA_0_0_VEC_INSERT]], float [[TMP37]], i32 1
; CHECK-NEXT:    [[TMP38:%.*]] = extractelement <2 x float> [[HITATTRS_SROA_0_4_VEC_INSERT]], i32 0
; CHECK-NEXT:    [[TMP39:%.*]] = fsub fast float 1.000000e+00, [[TMP38]]
; CHECK-NEXT:    [[TMP40:%.*]] = extractelement <2 x float> [[HITATTRS_SROA_0_4_VEC_INSERT]], i32 1
; CHECK-NEXT:    [[TMP41:%.*]] = fsub fast float [[TMP39]], [[TMP40]]
; CHECK-NEXT:    [[TMP42:%.*]] = insertelement <4 x float> undef, float [[TMP41]], i64 0
; CHECK-NEXT:    [[TMP43:%.*]] = insertelement <4 x float> [[TMP42]], float [[TMP38]], i64 1
; CHECK-NEXT:    [[TMP44:%.*]] = insertelement <4 x float> [[TMP43]], float [[TMP40]], i64 2
; CHECK-NEXT:    [[TMP45:%.*]] = insertelement <4 x float> [[TMP44]], float 1.000000e+00, i64 3
; CHECK-NEXT:    [[DOTSROA_0_0_VEC_EXTRACT:%.*]] = extractelement <4 x float> [[TMP45]], i32 0
; CHECK-NEXT:    [[TMP46:%.*]] = bitcast float [[DOTSROA_0_0_VEC_EXTRACT]] to i32
; CHECK-NEXT:    [[TMP47:%.*]] = load i32, ptr addrspace(20) @REGISTERS, align 4
; CHECK-NEXT:    [[TMP48:%.*]] = call i64 @_cont_GetContinuationStackGlobalMemBase()
; CHECK-NEXT:    [[TMP49:%.*]] = inttoptr i64 [[TMP48]] to ptr addrspace(22)
; CHECK-NEXT:    [[TMP50:%.*]] = getelementptr i8, ptr addrspace(22) [[TMP49]], i32 [[TMP47]]
; CHECK-NEXT:    [[TMP51:%.*]] = getelementptr i32, ptr addrspace(22) [[TMP50]], i32 -2
; CHECK-NEXT:    [[TMP52:%.*]] = getelementptr [[STRUCT_RAYPAYLOAD_ATTR_MAX_8_I32S_LAYOUT_5_CLOSESTHIT_OUT:%.*]], ptr addrspace(22) [[TMP51]], i32 0, i32 0, i32 7
; CHECK-NEXT:    store i32 [[TMP46]], ptr addrspace(22) [[TMP52]], align 4
; CHECK-NEXT:    [[DOTSROA_0_4_VEC_EXTRACT:%.*]] = extractelement <4 x float> [[TMP45]], i32 1
; CHECK-NEXT:    [[TMP53:%.*]] = bitcast float [[DOTSROA_0_4_VEC_EXTRACT]] to i32
; CHECK-NEXT:    [[TMP54:%.*]] = load i32, ptr addrspace(20) @REGISTERS, align 4
; CHECK-NEXT:    [[TMP55:%.*]] = call i64 @_cont_GetContinuationStackGlobalMemBase()
; CHECK-NEXT:    [[TMP56:%.*]] = inttoptr i64 [[TMP55]] to ptr addrspace(22)
; CHECK-NEXT:    [[TMP57:%.*]] = getelementptr i8, ptr addrspace(22) [[TMP56]], i32 [[TMP54]]
; CHECK-NEXT:    [[TMP58:%.*]] = getelementptr i32, ptr addrspace(22) [[TMP57]], i32 -2
; CHECK-NEXT:    [[TMP59:%.*]] = getelementptr [[STRUCT_RAYPAYLOAD_ATTR_MAX_8_I32S_LAYOUT_5_CLOSESTHIT_OUT]], ptr addrspace(22) [[TMP58]], i32 0, i32 0, i64 8
; CHECK-NEXT:    store i32 [[TMP53]], ptr addrspace(22) [[TMP59]], align 4
; CHECK-NEXT:    [[DOTSROA_0_8_VEC_EXTRACT:%.*]] = extractelement <4 x float> [[TMP45]], i32 2
; CHECK-NEXT:    [[TMP60:%.*]] = bitcast float [[DOTSROA_0_8_VEC_EXTRACT]] to i32
; CHECK-NEXT:    [[TMP61:%.*]] = load i32, ptr addrspace(20) @REGISTERS, align 4
; CHECK-NEXT:    [[TMP62:%.*]] = call i64 @_cont_GetContinuationStackGlobalMemBase()
; CHECK-NEXT:    [[TMP63:%.*]] = inttoptr i64 [[TMP62]] to ptr addrspace(22)
; CHECK-NEXT:    [[TMP64:%.*]] = getelementptr i8, ptr addrspace(22) [[TMP63]], i32 [[TMP61]]
; CHECK-NEXT:    [[TMP65:%.*]] = getelementptr i32, ptr addrspace(22) [[TMP64]], i32 -2
; CHECK-NEXT:    [[TMP66:%.*]] = getelementptr [[STRUCT_RAYPAYLOAD_ATTR_MAX_8_I32S_LAYOUT_5_CLOSESTHIT_OUT]], ptr addrspace(22) [[TMP65]], i32 0, i32 0, i64 9
; CHECK-NEXT:    store i32 [[TMP60]], ptr addrspace(22) [[TMP66]], align 4
; CHECK-NEXT:    [[DOTSROA_0_12_VEC_EXTRACT:%.*]] = extractelement <4 x float> [[TMP45]], i32 3
; CHECK-NEXT:    [[TMP67:%.*]] = bitcast float [[DOTSROA_0_12_VEC_EXTRACT]] to i32
; CHECK-NEXT:    [[TMP68:%.*]] = load i32, ptr addrspace(20) @REGISTERS, align 4
; CHECK-NEXT:    [[TMP69:%.*]] = call i64 @_cont_GetContinuationStackGlobalMemBase()
; CHECK-NEXT:    [[TMP70:%.*]] = inttoptr i64 [[TMP69]] to ptr addrspace(22)
; CHECK-NEXT:    [[TMP71:%.*]] = getelementptr i8, ptr addrspace(22) [[TMP70]], i32 [[TMP68]]
; CHECK-NEXT:    [[TMP72:%.*]] = getelementptr i32, ptr addrspace(22) [[TMP71]], i32 -2
; CHECK-NEXT:    [[TMP73:%.*]] = getelementptr [[STRUCT_RAYPAYLOAD_ATTR_MAX_8_I32S_LAYOUT_5_CLOSESTHIT_OUT]], ptr addrspace(22) [[TMP72]], i32 0, i32 0, i64 10
; CHECK-NEXT:    store i32 [[TMP67]], ptr addrspace(22) [[TMP73]], align 4
; CHECK-NEXT:    [[DOTFCA_0_INSERT:%.*]] = insertvalue [[STRUCT_DISPATCHSYSTEMDATA:%.*]] poison, <3 x i32> [[DOTFCA_0_0_EXTRACT]], 0
; CHECK-NEXT:    [[TMP74:%.*]] = load i32, ptr [[CSP]], align 4
; CHECK-NEXT:    call void (i64, ...) @continuation.continue(i64 [[RETURNADDR]], i32 [[TMP74]], [[STRUCT_DISPATCHSYSTEMDATA]] [[DOTFCA_0_INSERT]]), !continuation.registercount !8
; CHECK-NEXT:    unreachable
;
