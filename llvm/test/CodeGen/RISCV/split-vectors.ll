; RUN: llc -mcpu=nextsilicon-ns-core-v2 -mtriple=riscv64-unknown-elf -verify-machineinstrs < %s | FileCheck %s

target datalayout = "e-m:e-p:64:64-i64:64-i128:128-n32:64-S128"
target triple = "riscv64-unknown-unknown-elf"

; All functions have the same type of body:
;   for (int i = 0; i < N; i++) {
;      C[i] = A[i] `op` B[i];
;   }
; The first two numbers in the function name are sizes of vector A, B and C
; respectively.

; CHECK: vsetvli {{.*}}, m1, {{.*}}
; CHECK-NOT: vsetvli {{.*}}, {{mf8|mf4|mf2|m2|m4|m8}}, {{.*}}
define dso_local void @funcMul_32_32_64(i32 noundef signext %N, ptr nocapture noundef writeonly %C, ptr nocapture noundef readonly %A, ptr nocapture noundef readonly %B) local_unnamed_addr #0 {
entry:
  %cmp9 = icmp sgt i32 %N, 0
  br i1 %cmp9, label %for.body.preheader, label %for.cond.cleanup

for.body.preheader:                               ; preds = %entry
  %wide.trip.count = sext i32 %N to i64
  %0 = tail call i64 @llvm.vscale.i64()
  %1 = shl nuw nsw i64 %0, 1
  %min.iters.check = icmp ugt i64 %1, %wide.trip.count
  br i1 %min.iters.check, label %for.body.preheader12, label %vector.ph

vector.ph:                                        ; preds = %for.body.preheader
  %2 = tail call i64 @llvm.vscale.i64()
  %.neg = mul nuw nsw i64 %2, 4294967294
  %n.vec = and i64 %.neg, %wide.trip.count
  %3 = tail call i64 @llvm.vscale.i64()
  %4 = shl nuw nsw i64 %3, 1
  %5 = shl nuw nsw i64 %3, 3
  %6 = shl nuw nsw i64 %3, 4
  br label %vector.body

vector.body:                                      ; preds = %vector.body, %vector.ph
  %lsr.iv27 = phi i64 [ %lsr.iv.next28, %vector.body ], [ %n.vec, %vector.ph ]
  %lsr.iv25 = phi ptr [ %scevgep26, %vector.body ], [ %C, %vector.ph ]
  %lsr.iv23 = phi ptr [ %scevgep24, %vector.body ], [ %B, %vector.ph ]
  %lsr.iv21 = phi ptr [ %scevgep22, %vector.body ], [ %A, %vector.ph ]
  %wide.load = load <vscale x 2 x i32>, ptr %lsr.iv21, align 4
  %wide.load11 = load <vscale x 2 x i32>, ptr %lsr.iv23, align 4
  %7 = mul nsw <vscale x 2 x i32> %wide.load11, %wide.load
  %8 = sext <vscale x 2 x i32> %7 to <vscale x 2 x i64>
  store <vscale x 2 x i64> %8, ptr %lsr.iv25, align 8
  %scevgep22 = getelementptr i8, ptr %lsr.iv21, i64 %5
  %scevgep24 = getelementptr i8, ptr %lsr.iv23, i64 %5
  %scevgep26 = getelementptr i8, ptr %lsr.iv25, i64 %6
  %lsr.iv.next28 = sub i64 %lsr.iv27, %4
  %9 = icmp eq i64 %lsr.iv.next28, 0
  br i1 %9, label %middle.block, label %vector.body

middle.block:                                     ; preds = %vector.body
  %cmp.n = icmp eq i64 %n.vec, %wide.trip.count
  br i1 %cmp.n, label %for.cond.cleanup, label %for.body.preheader12

for.body.preheader12:                             ; preds = %middle.block, %for.body.preheader
  %indvars.iv.ph = phi i64 [ 0, %for.body.preheader ], [ %n.vec, %middle.block ]
  %10 = shl nuw nsw i64 %indvars.iv.ph, 3
  %scevgep = getelementptr i8, ptr %C, i64 %10
  %11 = shl nuw nsw i64 %indvars.iv.ph, 2
  %scevgep14 = getelementptr i8, ptr %B, i64 %11
  %scevgep17 = getelementptr i8, ptr %A, i64 %11
  %12 = sub i64 %wide.trip.count, %indvars.iv.ph
  br label %for.body

for.cond.cleanup:                                 ; preds = %for.body, %middle.block, %entry
  ret void

for.body:                                         ; preds = %for.body.preheader12, %for.body
  %lsr.iv20 = phi i64 [ %12, %for.body.preheader12 ], [ %lsr.iv.next, %for.body ]
  %lsr.iv18 = phi ptr [ %scevgep17, %for.body.preheader12 ], [ %scevgep19, %for.body ]
  %lsr.iv15 = phi ptr [ %scevgep14, %for.body.preheader12 ], [ %scevgep16, %for.body ]
  %lsr.iv = phi ptr [ %scevgep, %for.body.preheader12 ], [ %scevgep13, %for.body ]
  %13 = load i32, ptr %lsr.iv18, align 4
  %14 = load i32, ptr %lsr.iv15, align 4
  %mul = mul nsw i32 %14, %13
  %conv = sext i32 %mul to i64
  store i64 %conv, ptr %lsr.iv, align 8
  %scevgep13 = getelementptr i8, ptr %lsr.iv, i64 8
  %scevgep16 = getelementptr i8, ptr %lsr.iv15, i64 4
  %scevgep19 = getelementptr i8, ptr %lsr.iv18, i64 4
  %lsr.iv.next = add i64 %lsr.iv20, -1
  %exitcond.not = icmp eq i64 %lsr.iv.next, 0
  br i1 %exitcond.not, label %for.cond.cleanup, label %for.body
}

; CHECK: vsetvli {{.*}}, m1, {{.*}}
; CHECK-NOT: vsetvli {{.*}}, {{mf8|mf4|mf2|m2|m4|m8}}, {{.*}}
define dso_local void @funcMul_16_16_32(i32 noundef signext %N, ptr nocapture noundef writeonly %C, ptr nocapture noundef readonly %A, ptr nocapture noundef readonly %B) local_unnamed_addr #0 {
entry:
  %cmp10 = icmp sgt i32 %N, 0
  br i1 %cmp10, label %for.body.preheader, label %for.cond.cleanup

for.body.preheader:                               ; preds = %entry
  %wide.trip.count = sext i32 %N to i64
  %0 = tail call i64 @llvm.vscale.i64()
  %1 = shl nuw nsw i64 %0, 2
  %min.iters.check = icmp ugt i64 %1, %wide.trip.count
  br i1 %min.iters.check, label %for.body.preheader13, label %vector.ph

vector.ph:                                        ; preds = %for.body.preheader
  %2 = tail call i64 @llvm.vscale.i64()
  %.neg = mul nuw nsw i64 %2, 4294967292
  %n.vec = and i64 %.neg, %wide.trip.count
  %3 = tail call i64 @llvm.vscale.i64()
  %4 = shl nuw nsw i64 %3, 2
  %5 = shl nuw nsw i64 %3, 3
  %6 = shl nuw nsw i64 %3, 4
  br label %vector.body

vector.body:                                      ; preds = %vector.body, %vector.ph
  %lsr.iv28 = phi i64 [ %lsr.iv.next29, %vector.body ], [ %n.vec, %vector.ph ]
  %lsr.iv26 = phi ptr [ %scevgep27, %vector.body ], [ %C, %vector.ph ]
  %lsr.iv24 = phi ptr [ %scevgep25, %vector.body ], [ %B, %vector.ph ]
  %lsr.iv22 = phi ptr [ %scevgep23, %vector.body ], [ %A, %vector.ph ]
  %wide.load = load <vscale x 4 x i16>, ptr %lsr.iv22, align 2
  %7 = sext <vscale x 4 x i16> %wide.load to <vscale x 4 x i32>
  %wide.load12 = load <vscale x 4 x i16>, ptr %lsr.iv24, align 2
  %8 = sext <vscale x 4 x i16> %wide.load12 to <vscale x 4 x i32>
  %9 = mul nsw <vscale x 4 x i32> %8, %7
  store <vscale x 4 x i32> %9, ptr %lsr.iv26, align 4
  %scevgep23 = getelementptr i8, ptr %lsr.iv22, i64 %5
  %scevgep25 = getelementptr i8, ptr %lsr.iv24, i64 %5
  %scevgep27 = getelementptr i8, ptr %lsr.iv26, i64 %6
  %lsr.iv.next29 = sub i64 %lsr.iv28, %4
  %10 = icmp eq i64 %lsr.iv.next29, 0
  br i1 %10, label %middle.block, label %vector.body

middle.block:                                     ; preds = %vector.body
  %cmp.n = icmp eq i64 %n.vec, %wide.trip.count
  br i1 %cmp.n, label %for.cond.cleanup, label %for.body.preheader13

for.body.preheader13:                             ; preds = %middle.block, %for.body.preheader
  %indvars.iv.ph = phi i64 [ 0, %for.body.preheader ], [ %n.vec, %middle.block ]
  %11 = shl nuw nsw i64 %indvars.iv.ph, 2
  %scevgep = getelementptr i8, ptr %C, i64 %11
  %12 = shl nuw nsw i64 %indvars.iv.ph, 1
  %scevgep15 = getelementptr i8, ptr %B, i64 %12
  %scevgep18 = getelementptr i8, ptr %A, i64 %12
  %13 = sub i64 %wide.trip.count, %indvars.iv.ph
  br label %for.body

for.cond.cleanup:                                 ; preds = %for.body, %middle.block, %entry
  ret void

for.body:                                         ; preds = %for.body.preheader13, %for.body
  %lsr.iv21 = phi i64 [ %13, %for.body.preheader13 ], [ %lsr.iv.next, %for.body ]
  %lsr.iv19 = phi ptr [ %scevgep18, %for.body.preheader13 ], [ %scevgep20, %for.body ]
  %lsr.iv16 = phi ptr [ %scevgep15, %for.body.preheader13 ], [ %scevgep17, %for.body ]
  %lsr.iv = phi ptr [ %scevgep, %for.body.preheader13 ], [ %scevgep14, %for.body ]
  %14 = load i16, ptr %lsr.iv19, align 2
  %conv = sext i16 %14 to i32
  %15 = load i16, ptr %lsr.iv16, align 2
  %conv3 = sext i16 %15 to i32
  %mul = mul nsw i32 %conv3, %conv
  store i32 %mul, ptr %lsr.iv, align 4
  %scevgep14 = getelementptr i8, ptr %lsr.iv, i64 4
  %scevgep17 = getelementptr i8, ptr %lsr.iv16, i64 2
  %scevgep20 = getelementptr i8, ptr %lsr.iv19, i64 2
  %lsr.iv.next = add i64 %lsr.iv21, -1
  %exitcond.not = icmp eq i64 %lsr.iv.next, 0
  br i1 %exitcond.not, label %for.cond.cleanup, label %for.body
}

; CHECK: vsetvli {{.*}}, m1, {{.*}}
; CHECK-NOT: vsetvli {{.*}}, {{mf8|mf4|mf2|m2|m4|m8}}, {{.*}}
define dso_local void @funcMul_8_8_16(i32 noundef signext %N, ptr nocapture noundef writeonly %C, ptr nocapture noundef readonly %A, ptr nocapture noundef readonly %B) local_unnamed_addr #0 {
entry:
  %cmp11 = icmp sgt i32 %N, 0
  br i1 %cmp11, label %for.body.preheader, label %for.cond.cleanup

for.body.preheader:                               ; preds = %entry
  %wide.trip.count = sext i32 %N to i64
  %0 = tail call i64 @llvm.vscale.i64()
  %1 = shl nuw nsw i64 %0, 3
  %2 = tail call i64 @llvm.umax.i64(i64 %1, i64 16)
  %min.iters.check = icmp ugt i64 %2, %wide.trip.count
  br i1 %min.iters.check, label %for.body.preheader19, label %vector.memcheck

vector.memcheck:                                  ; preds = %for.body.preheader
  %3 = shl nuw nsw i64 %wide.trip.count, 1
  %scevgep = getelementptr i8, ptr %C, i64 %3
  %scevgep13 = getelementptr i8, ptr %A, i64 %wide.trip.count
  %scevgep14 = getelementptr i8, ptr %B, i64 %wide.trip.count
  %bound0 = icmp ugt ptr %scevgep13, %C
  %bound1 = icmp ugt ptr %scevgep, %A
  %found.conflict = and i1 %bound0, %bound1
  %bound015 = icmp ugt ptr %scevgep14, %C
  %bound116 = icmp ugt ptr %scevgep, %B
  %found.conflict17 = and i1 %bound015, %bound116
  %conflict.rdx = or i1 %found.conflict, %found.conflict17
  br i1 %conflict.rdx, label %for.body.preheader19, label %vector.ph

vector.ph:                                        ; preds = %vector.memcheck
  %4 = tail call i64 @llvm.vscale.i64()
  %.neg = mul nuw nsw i64 %4, 4294967288
  %n.vec = and i64 %.neg, %wide.trip.count
  %5 = tail call i64 @llvm.vscale.i64()
  %6 = shl nuw nsw i64 %5, 3
  %7 = shl nuw nsw i64 %5, 4
  br label %vector.body

vector.body:                                      ; preds = %vector.body, %vector.ph
  %lsr.iv35 = phi i64 [ %lsr.iv.next36, %vector.body ], [ %n.vec, %vector.ph ]
  %lsr.iv33 = phi ptr [ %scevgep34, %vector.body ], [ %C, %vector.ph ]
  %lsr.iv31 = phi ptr [ %scevgep32, %vector.body ], [ %B, %vector.ph ]
  %lsr.iv29 = phi ptr [ %scevgep30, %vector.body ], [ %A, %vector.ph ]
  %wide.load = load <vscale x 8 x i8>, ptr %lsr.iv29, align 1
  %8 = sext <vscale x 8 x i8> %wide.load to <vscale x 8 x i16>
  %wide.load18 = load <vscale x 8 x i8>, ptr %lsr.iv31, align 1
  %9 = sext <vscale x 8 x i8> %wide.load18 to <vscale x 8 x i16>
  %10 = mul nsw <vscale x 8 x i16> %9, %8
  store <vscale x 8 x i16> %10, ptr %lsr.iv33, align 2
  %scevgep30 = getelementptr i8, ptr %lsr.iv29, i64 %6
  %scevgep32 = getelementptr i8, ptr %lsr.iv31, i64 %6
  %scevgep34 = getelementptr i8, ptr %lsr.iv33, i64 %7
  %lsr.iv.next36 = sub i64 %lsr.iv35, %6
  %11 = icmp eq i64 %lsr.iv.next36, 0
  br i1 %11, label %middle.block, label %vector.body

middle.block:                                     ; preds = %vector.body
  %cmp.n = icmp eq i64 %n.vec, %wide.trip.count
  br i1 %cmp.n, label %for.cond.cleanup, label %for.body.preheader19

for.body.preheader19:                             ; preds = %middle.block, %vector.memcheck, %for.body.preheader
  %indvars.iv.ph = phi i64 [ 0, %vector.memcheck ], [ 0, %for.body.preheader ], [ %n.vec, %middle.block ]
  %12 = shl nuw nsw i64 %indvars.iv.ph, 1
  %scevgep20 = getelementptr i8, ptr %C, i64 %12
  %scevgep22 = getelementptr i8, ptr %B, i64 %indvars.iv.ph
  %scevgep25 = getelementptr i8, ptr %A, i64 %indvars.iv.ph
  %13 = sub i64 %wide.trip.count, %indvars.iv.ph
  br label %for.body

for.cond.cleanup:                                 ; preds = %for.body, %middle.block, %entry
  ret void

for.body:                                         ; preds = %for.body.preheader19, %for.body
  %lsr.iv28 = phi i64 [ %13, %for.body.preheader19 ], [ %lsr.iv.next, %for.body ]
  %lsr.iv26 = phi ptr [ %scevgep25, %for.body.preheader19 ], [ %scevgep27, %for.body ]
  %lsr.iv23 = phi ptr [ %scevgep22, %for.body.preheader19 ], [ %scevgep24, %for.body ]
  %lsr.iv = phi ptr [ %scevgep20, %for.body.preheader19 ], [ %scevgep21, %for.body ]
  %14 = load i8, ptr %lsr.iv26, align 1
  %conv = sext i8 %14 to i16
  %15 = load i8, ptr %lsr.iv23, align 1
  %conv3 = sext i8 %15 to i16
  %mul = mul nsw i16 %conv3, %conv
  store i16 %mul, ptr %lsr.iv, align 2
  %scevgep21 = getelementptr i8, ptr %lsr.iv, i64 2
  %scevgep24 = getelementptr i8, ptr %lsr.iv23, i64 1
  %scevgep27 = getelementptr i8, ptr %lsr.iv26, i64 1
  %lsr.iv.next = add i64 %lsr.iv28, -1
  %exitcond.not = icmp eq i64 %lsr.iv.next, 0
  br i1 %exitcond.not, label %for.cond.cleanup, label %for.body
}

; CHECK: vsetvli {{.*}}, m1, {{.*}}
; CHECK-NOT: vsetvli {{.*}}, {{mf8|mf4|mf2|m2|m4|m8}}, {{.*}}
define dso_local void @funcMul_16_16_64(i32 noundef signext %N, ptr nocapture noundef writeonly %C, ptr nocapture noundef readonly %A, ptr nocapture noundef readonly %B) local_unnamed_addr #0 {
entry:
  %cmp11 = icmp sgt i32 %N, 0
  br i1 %cmp11, label %for.body.preheader, label %for.cond.cleanup

for.body.preheader:                               ; preds = %entry
  %wide.trip.count = sext i32 %N to i64
  %0 = tail call i64 @llvm.vscale.i64()
  %1 = shl nuw nsw i64 %0, 2
  %min.iters.check = icmp ugt i64 %1, %wide.trip.count
  br i1 %min.iters.check, label %for.body.preheader14, label %vector.ph

vector.ph:                                        ; preds = %for.body.preheader
  %2 = tail call i64 @llvm.vscale.i64()
  %.neg = mul nuw nsw i64 %2, 4294967292
  %n.vec = and i64 %.neg, %wide.trip.count
  %3 = tail call i64 @llvm.vscale.i64()
  %4 = shl nuw nsw i64 %3, 2
  %5 = shl nuw nsw i64 %3, 3
  %6 = shl nuw nsw i64 %3, 5
  br label %vector.body

vector.body:                                      ; preds = %vector.body, %vector.ph
  %lsr.iv29 = phi i64 [ %lsr.iv.next30, %vector.body ], [ %n.vec, %vector.ph ]
  %lsr.iv27 = phi ptr [ %scevgep28, %vector.body ], [ %C, %vector.ph ]
  %lsr.iv25 = phi ptr [ %scevgep26, %vector.body ], [ %B, %vector.ph ]
  %lsr.iv23 = phi ptr [ %scevgep24, %vector.body ], [ %A, %vector.ph ]
  %wide.load = load <vscale x 4 x i16>, ptr %lsr.iv23, align 2
  %7 = sext <vscale x 4 x i16> %wide.load to <vscale x 4 x i64>
  %wide.load13 = load <vscale x 4 x i16>, ptr %lsr.iv25, align 2
  %8 = sext <vscale x 4 x i16> %wide.load13 to <vscale x 4 x i64>
  %9 = mul nsw <vscale x 4 x i64> %8, %7
  store <vscale x 4 x i64> %9, ptr %lsr.iv27, align 8
  %scevgep24 = getelementptr i8, ptr %lsr.iv23, i64 %5
  %scevgep26 = getelementptr i8, ptr %lsr.iv25, i64 %5
  %scevgep28 = getelementptr i8, ptr %lsr.iv27, i64 %6
  %lsr.iv.next30 = sub i64 %lsr.iv29, %4
  %10 = icmp eq i64 %lsr.iv.next30, 0
  br i1 %10, label %middle.block, label %vector.body

middle.block:                                     ; preds = %vector.body
  %cmp.n = icmp eq i64 %n.vec, %wide.trip.count
  br i1 %cmp.n, label %for.cond.cleanup, label %for.body.preheader14

for.body.preheader14:                             ; preds = %middle.block, %for.body.preheader
  %indvars.iv.ph = phi i64 [ 0, %for.body.preheader ], [ %n.vec, %middle.block ]
  %11 = shl nuw nsw i64 %indvars.iv.ph, 3
  %scevgep = getelementptr i8, ptr %C, i64 %11
  %12 = shl nuw nsw i64 %indvars.iv.ph, 1
  %scevgep16 = getelementptr i8, ptr %B, i64 %12
  %scevgep19 = getelementptr i8, ptr %A, i64 %12
  %13 = sub i64 %wide.trip.count, %indvars.iv.ph
  br label %for.body

for.cond.cleanup:                                 ; preds = %for.body, %middle.block, %entry
  ret void

for.body:                                         ; preds = %for.body.preheader14, %for.body
  %lsr.iv22 = phi i64 [ %13, %for.body.preheader14 ], [ %lsr.iv.next, %for.body ]
  %lsr.iv20 = phi ptr [ %scevgep19, %for.body.preheader14 ], [ %scevgep21, %for.body ]
  %lsr.iv17 = phi ptr [ %scevgep16, %for.body.preheader14 ], [ %scevgep18, %for.body ]
  %lsr.iv = phi ptr [ %scevgep, %for.body.preheader14 ], [ %scevgep15, %for.body ]
  %14 = load i16, ptr %lsr.iv20, align 2
  %conv = sext i16 %14 to i64
  %15 = load i16, ptr %lsr.iv17, align 2
  %conv3 = sext i16 %15 to i64
  %mul = mul nsw i64 %conv3, %conv
  store i64 %mul, ptr %lsr.iv, align 8
  %scevgep15 = getelementptr i8, ptr %lsr.iv, i64 8
  %scevgep18 = getelementptr i8, ptr %lsr.iv17, i64 2
  %scevgep21 = getelementptr i8, ptr %lsr.iv20, i64 2
  %lsr.iv.next = add i64 %lsr.iv22, -1
  %exitcond.not = icmp eq i64 %lsr.iv.next, 0
  br i1 %exitcond.not, label %for.cond.cleanup, label %for.body
}

; CHECK: vsetvli {{.*}}, m1, {{.*}}
; CHECK-NOT: vsetvli {{.*}}, {{mf8|mf4|mf2|m2|m4|m8}}, {{.*}}
define dso_local void @funcAdd_16_16_32(i32 noundef signext %N, ptr nocapture noundef writeonly %C, ptr nocapture noundef readonly %A, ptr nocapture noundef readonly %B) local_unnamed_addr #0 {
entry:
  %cmp10 = icmp sgt i32 %N, 0
  br i1 %cmp10, label %for.body.preheader, label %for.cond.cleanup

for.body.preheader:                               ; preds = %entry
  %wide.trip.count = sext i32 %N to i64
  %0 = tail call i64 @llvm.vscale.i64()
  %1 = shl nuw nsw i64 %0, 2
  %min.iters.check = icmp ugt i64 %1, %wide.trip.count
  br i1 %min.iters.check, label %for.body.preheader13, label %vector.ph

vector.ph:                                        ; preds = %for.body.preheader
  %2 = tail call i64 @llvm.vscale.i64()
  %.neg = mul nuw nsw i64 %2, 4294967292
  %n.vec = and i64 %.neg, %wide.trip.count
  %3 = tail call i64 @llvm.vscale.i64()
  %4 = shl nuw nsw i64 %3, 2
  %5 = shl nuw nsw i64 %3, 3
  %6 = shl nuw nsw i64 %3, 4
  br label %vector.body

vector.body:                                      ; preds = %vector.body, %vector.ph
  %lsr.iv28 = phi i64 [ %lsr.iv.next29, %vector.body ], [ %n.vec, %vector.ph ]
  %lsr.iv26 = phi ptr [ %scevgep27, %vector.body ], [ %C, %vector.ph ]
  %lsr.iv24 = phi ptr [ %scevgep25, %vector.body ], [ %B, %vector.ph ]
  %lsr.iv22 = phi ptr [ %scevgep23, %vector.body ], [ %A, %vector.ph ]
  %wide.load = load <vscale x 4 x i16>, ptr %lsr.iv22, align 2
  %7 = sext <vscale x 4 x i16> %wide.load to <vscale x 4 x i32>
  %wide.load12 = load <vscale x 4 x i16>, ptr %lsr.iv24, align 2
  %8 = sext <vscale x 4 x i16> %wide.load12 to <vscale x 4 x i32>
  %9 = add nsw <vscale x 4 x i32> %8, %7
  store <vscale x 4 x i32> %9, ptr %lsr.iv26, align 4
  %scevgep23 = getelementptr i8, ptr %lsr.iv22, i64 %5
  %scevgep25 = getelementptr i8, ptr %lsr.iv24, i64 %5
  %scevgep27 = getelementptr i8, ptr %lsr.iv26, i64 %6
  %lsr.iv.next29 = sub i64 %lsr.iv28, %4
  %10 = icmp eq i64 %lsr.iv.next29, 0
  br i1 %10, label %middle.block, label %vector.body

middle.block:                                     ; preds = %vector.body
  %cmp.n = icmp eq i64 %n.vec, %wide.trip.count
  br i1 %cmp.n, label %for.cond.cleanup, label %for.body.preheader13

for.body.preheader13:                             ; preds = %middle.block, %for.body.preheader
  %indvars.iv.ph = phi i64 [ 0, %for.body.preheader ], [ %n.vec, %middle.block ]
  %11 = shl nuw nsw i64 %indvars.iv.ph, 2
  %scevgep = getelementptr i8, ptr %C, i64 %11
  %12 = shl nuw nsw i64 %indvars.iv.ph, 1
  %scevgep15 = getelementptr i8, ptr %B, i64 %12
  %scevgep18 = getelementptr i8, ptr %A, i64 %12
  %13 = sub i64 %wide.trip.count, %indvars.iv.ph
  br label %for.body

for.cond.cleanup:                                 ; preds = %for.body, %middle.block, %entry
  ret void

for.body:                                         ; preds = %for.body.preheader13, %for.body
  %lsr.iv21 = phi i64 [ %13, %for.body.preheader13 ], [ %lsr.iv.next, %for.body ]
  %lsr.iv19 = phi ptr [ %scevgep18, %for.body.preheader13 ], [ %scevgep20, %for.body ]
  %lsr.iv16 = phi ptr [ %scevgep15, %for.body.preheader13 ], [ %scevgep17, %for.body ]
  %lsr.iv = phi ptr [ %scevgep, %for.body.preheader13 ], [ %scevgep14, %for.body ]
  %14 = load i16, ptr %lsr.iv19, align 2
  %conv = sext i16 %14 to i32
  %15 = load i16, ptr %lsr.iv16, align 2
  %conv3 = sext i16 %15 to i32
  %add = add nsw i32 %conv3, %conv
  store i32 %add, ptr %lsr.iv, align 4
  %scevgep14 = getelementptr i8, ptr %lsr.iv, i64 4
  %scevgep17 = getelementptr i8, ptr %lsr.iv16, i64 2
  %scevgep20 = getelementptr i8, ptr %lsr.iv19, i64 2
  %lsr.iv.next = add i64 %lsr.iv21, -1
  %exitcond.not = icmp eq i64 %lsr.iv.next, 0
  br i1 %exitcond.not, label %for.cond.cleanup, label %for.body
}

; CHECK: vsetvli {{.*}}, m1, {{.*}}
; CHECK-NOT: vsetvli {{.*}}, {{mf8|mf4|mf2|m2|m4|m8}}, {{.*}}
define dso_local void @funcAdd_16_32_64(i32 noundef signext %N, ptr nocapture noundef writeonly %C, ptr nocapture noundef readonly %A, ptr nocapture noundef readonly %B) local_unnamed_addr #0 {
entry:
  %cmp10 = icmp sgt i32 %N, 0
  br i1 %cmp10, label %for.body.preheader, label %for.cond.cleanup

for.body.preheader:                               ; preds = %entry
  %wide.trip.count = sext i32 %N to i64
  %0 = tail call i64 @llvm.vscale.i64()
  %1 = shl nuw nsw i64 %0, 2
  %min.iters.check = icmp ugt i64 %1, %wide.trip.count
  br i1 %min.iters.check, label %for.body.preheader13, label %vector.ph

vector.ph:                                        ; preds = %for.body.preheader
  %2 = tail call i64 @llvm.vscale.i64()
  %.neg = mul nuw nsw i64 %2, 4294967292
  %n.vec = and i64 %.neg, %wide.trip.count
  %3 = tail call i64 @llvm.vscale.i64()
  %4 = shl nuw nsw i64 %3, 2
  %5 = shl nuw nsw i64 %3, 3
  %6 = shl nuw nsw i64 %3, 4
  %7 = shl nuw nsw i64 %3, 5
  br label %vector.body

vector.body:                                      ; preds = %vector.body, %vector.ph
  %lsr.iv28 = phi i64 [ %lsr.iv.next29, %vector.body ], [ %n.vec, %vector.ph ]
  %lsr.iv26 = phi ptr [ %scevgep27, %vector.body ], [ %C, %vector.ph ]
  %lsr.iv24 = phi ptr [ %scevgep25, %vector.body ], [ %B, %vector.ph ]
  %lsr.iv22 = phi ptr [ %scevgep23, %vector.body ], [ %A, %vector.ph ]
  %wide.load = load <vscale x 4 x i16>, ptr %lsr.iv22, align 2
  %8 = sext <vscale x 4 x i16> %wide.load to <vscale x 4 x i32>
  %wide.load12 = load <vscale x 4 x i32>, ptr %lsr.iv24, align 4
  %9 = add nsw <vscale x 4 x i32> %wide.load12, %8
  %10 = sext <vscale x 4 x i32> %9 to <vscale x 4 x i64>
  store <vscale x 4 x i64> %10, ptr %lsr.iv26, align 8
  %scevgep23 = getelementptr i8, ptr %lsr.iv22, i64 %5
  %scevgep25 = getelementptr i8, ptr %lsr.iv24, i64 %6
  %scevgep27 = getelementptr i8, ptr %lsr.iv26, i64 %7
  %lsr.iv.next29 = sub i64 %lsr.iv28, %4
  %11 = icmp eq i64 %lsr.iv.next29, 0
  br i1 %11, label %middle.block, label %vector.body

middle.block:                                     ; preds = %vector.body
  %cmp.n = icmp eq i64 %n.vec, %wide.trip.count
  br i1 %cmp.n, label %for.cond.cleanup, label %for.body.preheader13

for.body.preheader13:                             ; preds = %middle.block, %for.body.preheader
  %indvars.iv.ph = phi i64 [ 0, %for.body.preheader ], [ %n.vec, %middle.block ]
  %12 = shl nuw nsw i64 %indvars.iv.ph, 3
  %scevgep = getelementptr i8, ptr %C, i64 %12
  %13 = shl nuw nsw i64 %indvars.iv.ph, 2
  %scevgep15 = getelementptr i8, ptr %B, i64 %13
  %14 = shl nuw nsw i64 %indvars.iv.ph, 1
  %scevgep18 = getelementptr i8, ptr %A, i64 %14
  %15 = sub i64 %wide.trip.count, %indvars.iv.ph
  br label %for.body

for.cond.cleanup:                                 ; preds = %for.body, %middle.block, %entry
  ret void

for.body:                                         ; preds = %for.body.preheader13, %for.body
  %lsr.iv21 = phi i64 [ %15, %for.body.preheader13 ], [ %lsr.iv.next, %for.body ]
  %lsr.iv19 = phi ptr [ %scevgep18, %for.body.preheader13 ], [ %scevgep20, %for.body ]
  %lsr.iv16 = phi ptr [ %scevgep15, %for.body.preheader13 ], [ %scevgep17, %for.body ]
  %lsr.iv = phi ptr [ %scevgep, %for.body.preheader13 ], [ %scevgep14, %for.body ]
  %16 = load i16, ptr %lsr.iv19, align 2
  %conv = sext i16 %16 to i32
  %17 = load i32, ptr %lsr.iv16, align 4
  %add = add nsw i32 %17, %conv
  %conv3 = sext i32 %add to i64
  store i64 %conv3, ptr %lsr.iv, align 8
  %scevgep14 = getelementptr i8, ptr %lsr.iv, i64 8
  %scevgep17 = getelementptr i8, ptr %lsr.iv16, i64 4
  %scevgep20 = getelementptr i8, ptr %lsr.iv19, i64 2
  %lsr.iv.next = add i64 %lsr.iv21, -1
  %exitcond.not = icmp eq i64 %lsr.iv.next, 0
  br i1 %exitcond.not, label %for.cond.cleanup, label %for.body
}

; CHECK: vsetvli {{.*}}, m1, {{.*}}
; CHECK-NOT: vsetvli {{.*}}, {{mf8|mf4|mf2|m2|m4|m8}}, {{.*}}
define dso_local void @funcAdd_32_32_64(i32 noundef signext %N, ptr nocapture noundef writeonly %C, ptr nocapture noundef readonly %A, ptr nocapture noundef readonly %B) local_unnamed_addr #0 {
entry:
  %cmp9 = icmp sgt i32 %N, 0
  br i1 %cmp9, label %for.body.preheader, label %for.cond.cleanup

for.body.preheader:                               ; preds = %entry
  %wide.trip.count = sext i32 %N to i64
  %0 = tail call i64 @llvm.vscale.i64()
  %1 = shl nuw nsw i64 %0, 1
  %min.iters.check = icmp ugt i64 %1, %wide.trip.count
  br i1 %min.iters.check, label %for.body.preheader12, label %vector.ph

vector.ph:                                        ; preds = %for.body.preheader
  %2 = tail call i64 @llvm.vscale.i64()
  %.neg = mul nuw nsw i64 %2, 4294967294
  %n.vec = and i64 %.neg, %wide.trip.count
  %3 = tail call i64 @llvm.vscale.i64()
  %4 = shl nuw nsw i64 %3, 1
  %5 = shl nuw nsw i64 %3, 3
  %6 = shl nuw nsw i64 %3, 4
  br label %vector.body

vector.body:                                      ; preds = %vector.body, %vector.ph
  %lsr.iv27 = phi i64 [ %lsr.iv.next28, %vector.body ], [ %n.vec, %vector.ph ]
  %lsr.iv25 = phi ptr [ %scevgep26, %vector.body ], [ %C, %vector.ph ]
  %lsr.iv23 = phi ptr [ %scevgep24, %vector.body ], [ %B, %vector.ph ]
  %lsr.iv21 = phi ptr [ %scevgep22, %vector.body ], [ %A, %vector.ph ]
  %wide.load = load <vscale x 2 x i32>, ptr %lsr.iv21, align 4
  %wide.load11 = load <vscale x 2 x i32>, ptr %lsr.iv23, align 4
  %7 = add nsw <vscale x 2 x i32> %wide.load11, %wide.load
  %8 = sext <vscale x 2 x i32> %7 to <vscale x 2 x i64>
  store <vscale x 2 x i64> %8, ptr %lsr.iv25, align 8
  %scevgep22 = getelementptr i8, ptr %lsr.iv21, i64 %5
  %scevgep24 = getelementptr i8, ptr %lsr.iv23, i64 %5
  %scevgep26 = getelementptr i8, ptr %lsr.iv25, i64 %6
  %lsr.iv.next28 = sub i64 %lsr.iv27, %4
  %9 = icmp eq i64 %lsr.iv.next28, 0
  br i1 %9, label %middle.block, label %vector.body

middle.block:                                     ; preds = %vector.body
  %cmp.n = icmp eq i64 %n.vec, %wide.trip.count
  br i1 %cmp.n, label %for.cond.cleanup, label %for.body.preheader12

for.body.preheader12:                             ; preds = %middle.block, %for.body.preheader
  %indvars.iv.ph = phi i64 [ 0, %for.body.preheader ], [ %n.vec, %middle.block ]
  %10 = shl nuw nsw i64 %indvars.iv.ph, 3
  %scevgep = getelementptr i8, ptr %C, i64 %10
  %11 = shl nuw nsw i64 %indvars.iv.ph, 2
  %scevgep14 = getelementptr i8, ptr %B, i64 %11
  %scevgep17 = getelementptr i8, ptr %A, i64 %11
  %12 = sub i64 %wide.trip.count, %indvars.iv.ph
  br label %for.body

for.cond.cleanup:                                 ; preds = %for.body, %middle.block, %entry
  ret void

for.body:                                         ; preds = %for.body.preheader12, %for.body
  %lsr.iv20 = phi i64 [ %12, %for.body.preheader12 ], [ %lsr.iv.next, %for.body ]
  %lsr.iv18 = phi ptr [ %scevgep17, %for.body.preheader12 ], [ %scevgep19, %for.body ]
  %lsr.iv15 = phi ptr [ %scevgep14, %for.body.preheader12 ], [ %scevgep16, %for.body ]
  %lsr.iv = phi ptr [ %scevgep, %for.body.preheader12 ], [ %scevgep13, %for.body ]
  %13 = load i32, ptr %lsr.iv18, align 4
  %14 = load i32, ptr %lsr.iv15, align 4
  %add = add nsw i32 %14, %13
  %conv = sext i32 %add to i64
  store i64 %conv, ptr %lsr.iv, align 8
  %scevgep13 = getelementptr i8, ptr %lsr.iv, i64 8
  %scevgep16 = getelementptr i8, ptr %lsr.iv15, i64 4
  %scevgep19 = getelementptr i8, ptr %lsr.iv18, i64 4
  %lsr.iv.next = add i64 %lsr.iv20, -1
  %exitcond.not = icmp eq i64 %lsr.iv.next, 0
  br i1 %exitcond.not, label %for.cond.cleanup, label %for.body
}

; CHECK: vsetvli {{.*}}, m1, {{.*}}
; CHECK-NOT: vsetvli {{.*}}, {{mf8|mf4|mf2|m2|m4|m8}}, {{.*}}
define dso_local void @funcSub_32_32_16(i32 noundef signext %N, ptr nocapture noundef writeonly %C, ptr nocapture noundef readonly %A, ptr nocapture noundef readonly %B) local_unnamed_addr #0 {
entry:
  %cmp9 = icmp sgt i32 %N, 0
  br i1 %cmp9, label %for.body.preheader, label %for.cond.cleanup

for.body.preheader:                               ; preds = %entry
  %wide.trip.count = sext i32 %N to i64
  %0 = tail call i64 @llvm.vscale.i64()
  %1 = shl nuw nsw i64 %0, 2
  %min.iters.check = icmp ugt i64 %1, %wide.trip.count
  br i1 %min.iters.check, label %for.body.preheader12, label %vector.ph

vector.ph:                                        ; preds = %for.body.preheader
  %2 = tail call i64 @llvm.vscale.i64()
  %.neg = mul nuw nsw i64 %2, 4294967292
  %n.vec = and i64 %.neg, %wide.trip.count
  %3 = tail call i64 @llvm.vscale.i64()
  %4 = shl nuw nsw i64 %3, 2
  %5 = shl nuw nsw i64 %3, 4
  %6 = shl nuw nsw i64 %3, 3
  br label %vector.body

vector.body:                                      ; preds = %vector.body, %vector.ph
  %lsr.iv27 = phi i64 [ %lsr.iv.next28, %vector.body ], [ %n.vec, %vector.ph ]
  %lsr.iv25 = phi ptr [ %scevgep26, %vector.body ], [ %C, %vector.ph ]
  %lsr.iv23 = phi ptr [ %scevgep24, %vector.body ], [ %B, %vector.ph ]
  %lsr.iv21 = phi ptr [ %scevgep22, %vector.body ], [ %A, %vector.ph ]
  %wide.load = load <vscale x 4 x i32>, ptr %lsr.iv21, align 4
  %wide.load11 = load <vscale x 4 x i32>, ptr %lsr.iv23, align 4
  %7 = sub nsw <vscale x 4 x i32> %wide.load, %wide.load11
  %8 = trunc <vscale x 4 x i32> %7 to <vscale x 4 x i16>
  store <vscale x 4 x i16> %8, ptr %lsr.iv25, align 2
  %scevgep22 = getelementptr i8, ptr %lsr.iv21, i64 %5
  %scevgep24 = getelementptr i8, ptr %lsr.iv23, i64 %5
  %scevgep26 = getelementptr i8, ptr %lsr.iv25, i64 %6
  %lsr.iv.next28 = sub i64 %lsr.iv27, %4
  %9 = icmp eq i64 %lsr.iv.next28, 0
  br i1 %9, label %middle.block, label %vector.body

middle.block:                                     ; preds = %vector.body
  %cmp.n = icmp eq i64 %n.vec, %wide.trip.count
  br i1 %cmp.n, label %for.cond.cleanup, label %for.body.preheader12

for.body.preheader12:                             ; preds = %middle.block, %for.body.preheader
  %indvars.iv.ph = phi i64 [ 0, %for.body.preheader ], [ %n.vec, %middle.block ]
  %10 = shl nuw nsw i64 %indvars.iv.ph, 1
  %scevgep = getelementptr i8, ptr %C, i64 %10
  %11 = shl nuw nsw i64 %indvars.iv.ph, 2
  %scevgep14 = getelementptr i8, ptr %B, i64 %11
  %scevgep17 = getelementptr i8, ptr %A, i64 %11
  %12 = sub i64 %wide.trip.count, %indvars.iv.ph
  br label %for.body

for.cond.cleanup:                                 ; preds = %for.body, %middle.block, %entry
  ret void

for.body:                                         ; preds = %for.body.preheader12, %for.body
  %lsr.iv20 = phi i64 [ %12, %for.body.preheader12 ], [ %lsr.iv.next, %for.body ]
  %lsr.iv18 = phi ptr [ %scevgep17, %for.body.preheader12 ], [ %scevgep19, %for.body ]
  %lsr.iv15 = phi ptr [ %scevgep14, %for.body.preheader12 ], [ %scevgep16, %for.body ]
  %lsr.iv = phi ptr [ %scevgep, %for.body.preheader12 ], [ %scevgep13, %for.body ]
  %13 = load i32, ptr %lsr.iv18, align 4
  %14 = load i32, ptr %lsr.iv15, align 4
  %sub = sub nsw i32 %13, %14
  %conv = trunc i32 %sub to i16
  store i16 %conv, ptr %lsr.iv, align 2
  %scevgep13 = getelementptr i8, ptr %lsr.iv, i64 2
  %scevgep16 = getelementptr i8, ptr %lsr.iv15, i64 4
  %scevgep19 = getelementptr i8, ptr %lsr.iv18, i64 4
  %lsr.iv.next = add i64 %lsr.iv20, -1
  %exitcond.not = icmp eq i64 %lsr.iv.next, 0
  br i1 %exitcond.not, label %for.cond.cleanup, label %for.body
}

; CHECK: vsetvli {{.*}}, m1, {{.*}}
; CHECK-NOT: vsetvli {{.*}}, {{mf8|mf4|mf2|m2|m4|m8}}, {{.*}}
define dso_local void @funcSub_16_16_16(i32 noundef signext %N, ptr nocapture noundef writeonly %C, ptr nocapture noundef readonly %A, ptr nocapture noundef readonly %B) local_unnamed_addr #0 {
entry:
  %cmp11 = icmp sgt i32 %N, 0
  br i1 %cmp11, label %for.body.preheader, label %for.cond.cleanup

for.body.preheader:                               ; preds = %entry
  %wide.trip.count = sext i32 %N to i64
  %0 = tail call i64 @llvm.vscale.i64()
  %1 = shl nuw nsw i64 %0, 3
  %2 = tail call i64 @llvm.umax.i64(i64 %1, i64 16)
  %min.iters.check = icmp ugt i64 %2, %wide.trip.count
  br i1 %min.iters.check, label %for.body.preheader18, label %vector.memcheck

vector.memcheck:                                  ; preds = %for.body.preheader
  %3 = ptrtoint ptr %C to i64
  %4 = ptrtoint ptr %A to i64
  %5 = ptrtoint ptr %B to i64
  %6 = tail call i64 @llvm.vscale.i64()
  %7 = shl nuw nsw i64 %6, 4
  %8 = sub i64 %3, %4
  %diff.check = icmp ult i64 %8, %7
  %9 = shl nuw nsw i64 %6, 4
  %10 = sub i64 %3, %5
  %diff.check16 = icmp ult i64 %10, %9
  %conflict.rdx = or i1 %diff.check, %diff.check16
  br i1 %conflict.rdx, label %for.body.preheader18, label %vector.ph

vector.ph:                                        ; preds = %vector.memcheck
  %11 = tail call i64 @llvm.vscale.i64()
  %.neg = mul nuw nsw i64 %11, 4294967288
  %n.vec = and i64 %.neg, %wide.trip.count
  %12 = tail call i64 @llvm.vscale.i64()
  %13 = shl nuw nsw i64 %12, 3
  %14 = shl nuw nsw i64 %12, 4
  br label %vector.body

vector.body:                                      ; preds = %vector.body, %vector.ph
  %lsr.iv33 = phi i64 [ %lsr.iv.next34, %vector.body ], [ %n.vec, %vector.ph ]
  %lsr.iv31 = phi ptr [ %scevgep32, %vector.body ], [ %C, %vector.ph ]
  %lsr.iv29 = phi ptr [ %scevgep30, %vector.body ], [ %B, %vector.ph ]
  %lsr.iv27 = phi ptr [ %scevgep28, %vector.body ], [ %A, %vector.ph ]
  %wide.load = load <vscale x 8 x i16>, ptr %lsr.iv27, align 2
  %wide.load17 = load <vscale x 8 x i16>, ptr %lsr.iv29, align 2
  %15 = sub <vscale x 8 x i16> %wide.load, %wide.load17
  store <vscale x 8 x i16> %15, ptr %lsr.iv31, align 2
  %scevgep28 = getelementptr i8, ptr %lsr.iv27, i64 %14
  %scevgep30 = getelementptr i8, ptr %lsr.iv29, i64 %14
  %scevgep32 = getelementptr i8, ptr %lsr.iv31, i64 %14
  %lsr.iv.next34 = sub i64 %lsr.iv33, %13
  %16 = icmp eq i64 %lsr.iv.next34, 0
  br i1 %16, label %middle.block, label %vector.body

middle.block:                                     ; preds = %vector.body
  %cmp.n = icmp eq i64 %n.vec, %wide.trip.count
  br i1 %cmp.n, label %for.cond.cleanup, label %for.body.preheader18

for.body.preheader18:                             ; preds = %middle.block, %vector.memcheck, %for.body.preheader
  %indvars.iv.ph = phi i64 [ 0, %vector.memcheck ], [ 0, %for.body.preheader ], [ %n.vec, %middle.block ]
  %17 = shl nuw nsw i64 %indvars.iv.ph, 1
  %scevgep = getelementptr i8, ptr %C, i64 %17
  %scevgep20 = getelementptr i8, ptr %B, i64 %17
  %scevgep23 = getelementptr i8, ptr %A, i64 %17
  %18 = sub i64 %wide.trip.count, %indvars.iv.ph
  br label %for.body

for.cond.cleanup:                                 ; preds = %for.body, %middle.block, %entry
  ret void

for.body:                                         ; preds = %for.body.preheader18, %for.body
  %lsr.iv26 = phi i64 [ %18, %for.body.preheader18 ], [ %lsr.iv.next, %for.body ]
  %lsr.iv24 = phi ptr [ %scevgep23, %for.body.preheader18 ], [ %scevgep25, %for.body ]
  %lsr.iv21 = phi ptr [ %scevgep20, %for.body.preheader18 ], [ %scevgep22, %for.body ]
  %lsr.iv = phi ptr [ %scevgep, %for.body.preheader18 ], [ %scevgep19, %for.body ]
  %19 = load i16, ptr %lsr.iv24, align 2
  %20 = load i16, ptr %lsr.iv21, align 2
  %sub = sub i16 %19, %20
  store i16 %sub, ptr %lsr.iv, align 2
  %scevgep19 = getelementptr i8, ptr %lsr.iv, i64 2
  %scevgep22 = getelementptr i8, ptr %lsr.iv21, i64 2
  %scevgep25 = getelementptr i8, ptr %lsr.iv24, i64 2
  %lsr.iv.next = add i64 %lsr.iv26, -1
  %exitcond.not = icmp eq i64 %lsr.iv.next, 0
  br i1 %exitcond.not, label %for.cond.cleanup, label %for.body
}

; CHECK: vsetvli {{.*}}, m1, {{.*}}
; CHECK-NOT: vsetvli {{.*}}, {{mf8|mf4|mf2|m2|m4|m8}}, {{.*}}
define dso_local void @funcSub_64_64_32(i32 noundef signext %N, ptr nocapture noundef writeonly %C, ptr nocapture noundef readonly %A, ptr nocapture noundef readonly %B) local_unnamed_addr #0 {
entry:
  %cmp9 = icmp sgt i32 %N, 0
  br i1 %cmp9, label %for.body.preheader, label %for.cond.cleanup

for.body.preheader:                               ; preds = %entry
  %wide.trip.count = sext i32 %N to i64
  %0 = tail call i64 @llvm.vscale.i64()
  %1 = shl nuw nsw i64 %0, 1
  %min.iters.check = icmp ugt i64 %1, %wide.trip.count
  br i1 %min.iters.check, label %for.body.preheader12, label %vector.ph

vector.ph:                                        ; preds = %for.body.preheader
  %2 = tail call i64 @llvm.vscale.i64()
  %.neg = mul nuw nsw i64 %2, 4294967294
  %n.vec = and i64 %.neg, %wide.trip.count
  %3 = tail call i64 @llvm.vscale.i64()
  %4 = shl nuw nsw i64 %3, 1
  %5 = shl nuw nsw i64 %3, 4
  %6 = shl nuw nsw i64 %3, 3
  br label %vector.body

vector.body:                                      ; preds = %vector.body, %vector.ph
  %lsr.iv27 = phi i64 [ %lsr.iv.next28, %vector.body ], [ %n.vec, %vector.ph ]
  %lsr.iv25 = phi ptr [ %scevgep26, %vector.body ], [ %C, %vector.ph ]
  %lsr.iv23 = phi ptr [ %scevgep24, %vector.body ], [ %B, %vector.ph ]
  %lsr.iv21 = phi ptr [ %scevgep22, %vector.body ], [ %A, %vector.ph ]
  %wide.load = load <vscale x 2 x i64>, ptr %lsr.iv21, align 8
  %wide.load11 = load <vscale x 2 x i64>, ptr %lsr.iv23, align 8
  %7 = sub nsw <vscale x 2 x i64> %wide.load, %wide.load11
  %8 = trunc <vscale x 2 x i64> %7 to <vscale x 2 x i32>
  store <vscale x 2 x i32> %8, ptr %lsr.iv25, align 4
  %scevgep22 = getelementptr i8, ptr %lsr.iv21, i64 %5
  %scevgep24 = getelementptr i8, ptr %lsr.iv23, i64 %5
  %scevgep26 = getelementptr i8, ptr %lsr.iv25, i64 %6
  %lsr.iv.next28 = sub i64 %lsr.iv27, %4
  %9 = icmp eq i64 %lsr.iv.next28, 0
  br i1 %9, label %middle.block, label %vector.body

middle.block:                                     ; preds = %vector.body
  %cmp.n = icmp eq i64 %n.vec, %wide.trip.count
  br i1 %cmp.n, label %for.cond.cleanup, label %for.body.preheader12

for.body.preheader12:                             ; preds = %middle.block, %for.body.preheader
  %indvars.iv.ph = phi i64 [ 0, %for.body.preheader ], [ %n.vec, %middle.block ]
  %10 = shl nuw nsw i64 %indvars.iv.ph, 2
  %scevgep = getelementptr i8, ptr %C, i64 %10
  %11 = shl nuw nsw i64 %indvars.iv.ph, 3
  %scevgep14 = getelementptr i8, ptr %B, i64 %11
  %scevgep17 = getelementptr i8, ptr %A, i64 %11
  %12 = sub i64 %wide.trip.count, %indvars.iv.ph
  br label %for.body

for.cond.cleanup:                                 ; preds = %for.body, %middle.block, %entry
  ret void

for.body:                                         ; preds = %for.body.preheader12, %for.body
  %lsr.iv20 = phi i64 [ %12, %for.body.preheader12 ], [ %lsr.iv.next, %for.body ]
  %lsr.iv18 = phi ptr [ %scevgep17, %for.body.preheader12 ], [ %scevgep19, %for.body ]
  %lsr.iv15 = phi ptr [ %scevgep14, %for.body.preheader12 ], [ %scevgep16, %for.body ]
  %lsr.iv = phi ptr [ %scevgep, %for.body.preheader12 ], [ %scevgep13, %for.body ]
  %13 = load i64, ptr %lsr.iv18, align 8
  %14 = load i64, ptr %lsr.iv15, align 8
  %sub = sub nsw i64 %13, %14
  %conv = trunc i64 %sub to i32
  store i32 %conv, ptr %lsr.iv, align 4
  %scevgep13 = getelementptr i8, ptr %lsr.iv, i64 4
  %scevgep16 = getelementptr i8, ptr %lsr.iv15, i64 8
  %scevgep19 = getelementptr i8, ptr %lsr.iv18, i64 8
  %lsr.iv.next = add i64 %lsr.iv20, -1
  %exitcond.not = icmp eq i64 %lsr.iv.next, 0
  br i1 %exitcond.not, label %for.cond.cleanup, label %for.body
}

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(none)
declare i64 @llvm.vscale.i64() #1

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare i64 @llvm.umax.i64(i64, i64) #2

attributes #0 = { nofree norecurse nosync nounwind memory(argmem: readwrite) vscale_range(2,1024) "no-builtins" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-features"="+64bit,+a,+d,+f,+m,+relax,+v,+zicsr,+zve32f,+zve32x,+zve64d,+zve64f,+zve64x,+zvl128b,+zvl32b,+zvl64b,-c,-e,-experimental-smaia,-experimental-ssaia,-experimental-zacas,-experimental-zfa,-experimental-zfbfmin,-experimental-zicond,-experimental-zihintntl,-experimental-ztso,-experimental-zvbb,-experimental-zvbc,-experimental-zvfbfmin,-experimental-zvfbfwma,-experimental-zvkg,-experimental-zvkn,-experimental-zvknc,-experimental-zvkned,-experimental-zvkng,-experimental-zvknha,-experimental-zvknhb,-experimental-zvks,-experimental-zvksc,-experimental-zvksed,-experimental-zvksg,-experimental-zvksh,-experimental-zvkt,-h,-save-restore,-svinval,-svnapot,-svpbmt,-xcvbitmanip,-xcvmac,-xsfcie,-xsfvcp,-xtheadba,-xtheadbb,-xtheadbs,-xtheadcmo,-xtheadcondmov,-xtheadfmemidx,-xtheadmac,-xtheadmemidx,-xtheadmempair,-xtheadsync,-xtheadvdot,-xventanacondops,-zawrs,-zba,-zbb,-zbc,-zbkb,-zbkc,-zbkx,-zbs,-zca,-zcb,-zcd,-zce,-zcf,-zcmp,-zcmt,-zdinx,-zfh,-zfhmin,-zfinx,-zhinx,-zhinxmin,-zicbom,-zicbop,-zicboz,-zicntr,-zifencei,-zihintpause,-zihpm,-zk,-zkn,-zknd,-zkne,-zknh,-zkr,-zks,-zksed,-zksh,-zkt,-zmmul,-zvfh,-zvl1024b,-zvl16384b,-zvl2048b,-zvl256b,-zvl32768b,-zvl4096b,-zvl512b,-zvl65536b,-zvl8192b" }
attributes #1 = { nocallback nofree nosync nounwind willreturn memory(none) }
attributes #2 = { nocallback nofree nosync nounwind speculatable willreturn memory(none) }

!llvm.module.flags = !{!0, !1, !2, !3}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 1, !"target-abi", !"lp64d"}
!2 = !{i32 1, !"Code Model", i32 3}
!3 = !{i32 8, !"SmallDataLimit", i32 8}