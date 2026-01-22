// RUN: %clang --target=riscv64-unknown-elf -mcpu=nextsilicon-ns-core-v2 -march=rv64gcv -O3 -S -o - %s | FileCheck %s -check-prefix=NSCORE-V2
// RUN: %clang --target=riscv64-unknown-elf -mcpu=nextsilicon-ns-core-v3 -march=rv64gcv -O3 -S -o - %s | FileCheck %s -check-prefix=NSCORE-V3

#include <stdint.h>


// For NSCoreV3 check only that vsetvli instructions have LMUL <= 1.
// For NSCoreV2 check only that vsetvli instructions have LMUL == 1 and no other

// Vector integer types with explicit casts

// NSCORE-V3-NOT: vsetvli {{.*}}, {{m2|m4|m8}}, {{.*}}
// NSCORE-V3: vsetvli {{.*}}, {{m1|mf2|mf4|mf8}}, {{.*}}

// NSCORE-V2-NOT: vsetvli {{.*}}, {{mf2|mf4|mf8|m2|m4|m8}}, {{.*}}
// NSCORE-V2: vsetvli {{.*}}, m1, {{.*}}
void funcMul_32_32_64(int32_t *A, int32_t *B, int64_t *C, unsigned N) {
    for (int i = 0; i < N; ++i)
        C[i] = (int64_t)A[i] * (int64_t)B[i];
}

// NSCORE-V3-NOT: vsetvli {{.*}}, {{m2|m4|m8}}, {{.*}}
// NSCORE-V3: vsetvli {{.*}}, {{m1|mf2|mf4|mf8}}, {{.*}}

// NSCORE-V2-NOT: vsetvli {{.*}}, {{mf2|mf4|mf8|m2|m4|m8}}, {{.*}}
// NSCORE-V2: vsetvli {{.*}}, m1, {{.*}}
void funcAdd_16_16_32(int16_t *A, int16_t *B, int32_t *C, unsigned N) {
    for (int i = 0; i < N; ++i)
        C[i] = (int32_t)A[i] + (int32_t)B[i];
}

// NSCORE-V3-NOT: vsetvli {{.*}}, {{m2|m4|m8}}, {{.*}}
// NSCORE-V3: vsetvli {{.*}}, {{m1|mf2|mf4|mf8}}, {{.*}}

// NSCORE-V2-NOT: vsetvli {{.*}}, {{mf2|mf4|mf8|m2|m4|m8}}, {{.*}}
// NSCORE-V2: vsetvli {{.*}}, m1, {{.*}}
void funcMul_8_8_16(int8_t *A, int8_t *B, int16_t *C, unsigned N) {
    for (int i = 0; i < N; ++i)
        C[i] = (int16_t)A[i] * (int16_t)B[i];
}

// NSCORE-V3-NOT: vsetvli {{.*}}, {{m2|m4|m8}}, {{.*}}
// NSCORE-V3: vsetvli {{.*}}, {{m1|mf2|mf4|mf8}}, {{.*}}

// NSCORE-V2-NOT: vsetvli {{.*}}, {{mf2|mf4|mf8|m2|m4|m8}}, {{.*}}
// NSCORE-V2: vsetvli {{.*}}, m1, {{.*}}
void funcAdd_16_16_64(int16_t *A, int16_t *B, int64_t *C, unsigned N) {
    for (int i = 0; i < N; ++i)
        C[i] = (int64_t)A[i] + (int64_t)B[i];
}

// NSCORE-V3-NOT: vsetvli {{.*}}, {{m2|m4|m8}}, {{.*}}
// NSCORE-V3: vsetvli {{.*}}, {{m1|mf2|mf4|mf8}}, {{.*}}

// NSCORE-V2-NOT: vsetvli {{.*}}, {{mf2|mf4|mf8|m2|m4|m8}}, {{.*}}
// NSCORE-V2: vsetvli {{.*}}, m1, {{.*}}
void funcMul_16_32_64(int16_t *A, int32_t *B, int64_t *C, unsigned N) {
    for (int i = 0; i < N; ++i)
        C[i] = (int64_t)A[i] * (int64_t)B[i];
}

// NSCORE-V3-NOT: vsetvli {{.*}}, {{m2|m4|m8}}, {{.*}}
// NSCORE-V3: vsetvli {{.*}}, {{m1|mf2|mf4|mf8}}, {{.*}}

// NSCORE-V2-NOT: vsetvli {{.*}}, {{mf2|mf4|mf8|m2|m4|m8}}, {{.*}}
// NSCORE-V2: vsetvli {{.*}}, m1, {{.*}}
void funcAdd_16_64_64(int16_t *A, int64_t *B, int64_t *C, unsigned N) {
    for (int i = 0; i < N; ++i)
        C[i] = (int64_t)A[i] + B[i];
}

// NSCORE-V3-NOT: vsetvli {{.*}}, {{m2|m4|m8}}, {{.*}}
// NSCORE-V3: vsetvli {{.*}}, {{m1|mf2|mf4|mf8}}, {{.*}}

// NSCORE-V2-NOT: vsetvli {{.*}}, {{mf2|mf4|mf8|m2|m4|m8}}, {{.*}}
// NSCORE-V2: vsetvli {{.*}}, m1, {{.*}}
void funcMul_32_64_64(int32_t *A, int64_t *B, int64_t *C, unsigned N) {
    for (int i = 0; i < N; ++i)
        C[i] = (int64_t)A[i] * B[i];
}

 // NSCORE-V3-NOT: vsetvli {{.*}}, {{m2|m4|m8}}, {{.*}}
 // NSCORE-V3: vsetvli {{.*}}, {{m1|mf2|mf4|mf8}}, {{.*}}
 
// NSCORE-V2-NOT: vsetvli {{.*}}, {{mf2|mf4|mf8|m2|m4|m8}}, {{.*}}
// NSCORE-V2: vsetvli {{.*}}, m1, {{.*}}
void funcAdd_16_32_32(int16_t *A, int32_t *B, int32_t *C, unsigned N) {
     for (int i = 0; i < N; ++i)
        C[i] = (int32_t)A[i] + B[i];
 }
 
 // NSCORE-V3-NOT: vsetvli {{.*}}, {{m2|m4|m8}}, {{.*}}
 // NSCORE-V3: vsetvli {{.*}}, {{m1|mf2|mf4|mf8}}, {{.*}}
 
// NSCORE-V2-NOT: vsetvli {{.*}}, {{mf2|mf4|mf8|m2|m4|m8}}, {{.*}}
// NSCORE-V2: vsetvli {{.*}}, m1, {{.*}}
void funcMulAdd_32_32_32_64(int32_t *A, int32_t *B, int32_t *C, int64_t *D, unsigned N) {
    for (int i = 0; i < N; ++i)
        D[i] = (int64_t)A[i] * (int64_t)B[i] + (int64_t)C[i];
}

// NSCORE-V3-NOT: vsetvli {{.*}}, {{m2|m4|m8}}, {{.*}}
// NSCORE-V3: vsetvli {{.*}}, {{m1|mf2|mf4|mf8}}, {{.*}}

// NSCORE-V2-NOT: vsetvli {{.*}}, {{mf2|mf4|mf8|m2|m4|m8}}, {{.*}}
// NSCORE-V2: vsetvli {{.*}}, m1, {{.*}}
void funcMulAdd_16_16_16_32(int16_t *A, int16_t *B, int16_t *C, int32_t *D, unsigned N) {
    for (int i = 0; i < N; ++i)
        D[i] = (int32_t)A[i] * (int32_t)B[i] + (int32_t)C[i];
}

// NSCORE-V3-NOT: vsetvli {{.*}}, {{m2|m4|m8}}, {{.*}}
// NSCORE-V3: vsetvli {{.*}}, {{m1|mf2|mf4|mf8}}, {{.*}}

// NSCORE-V2-NOT: vsetvli {{.*}}, {{mf2|mf4|mf8|m2|m4|m8}}, {{.*}}
// NSCORE-V2: vsetvli {{.*}}, m1, {{.*}}
void funcMulAdd_16_16_16_64(int16_t *A, int16_t *B, int16_t *C, int64_t *D, unsigned N) {
    for (int i = 0; i < N; ++i)
        D[i] = (int64_t)A[i] * (int64_t)B[i] + (int64_t)C[i];
}

// NSCORE-V3-NOT: vsetvli {{.*}}, {{m2|m4|m8}}, {{.*}}
// NSCORE-V3: vsetvli {{.*}}, {{m1|mf2|mf4|mf8}}, {{.*}}

// NSCORE-V2-NOT: vsetvli {{.*}}, {{mf2|mf4|mf8|m2|m4|m8}}, {{.*}}
// NSCORE-V2: vsetvli {{.*}}, m1, {{.*}}
void funcMulAdd_16_32_32_64(int16_t *A, int32_t *B, int32_t *C, int64_t *D, unsigned N) {
    for (int i = 0; i < N; ++i)
        D[i] = (int64_t)A[i] * (int64_t)B[i] + (int64_t)C[i];
}

// NSCORE-V3-NOT: vsetvli {{.*}}, {{m2|m4|m8}}, {{.*}}
// NSCORE-V3: vsetvli {{.*}}, {{m1|mf2|mf4|mf8}}, {{.*}}

// NSCORE-V2-NOT: vsetvli {{.*}}, {{mf2|mf4|mf8|m2|m4|m8}}, {{.*}}
// NSCORE-V2: vsetvli {{.*}}, m1, {{.*}}
void funcMulAdd_16_16_32_64(int16_t *A, int16_t *B, int32_t *C, int64_t *D, unsigned N) {
    for (int i = 0; i < N; ++i)
        D[i] = (int64_t)A[i] * (int64_t)B[i] + (int64_t)C[i];
}

// NSCORE-V3-NOT: vsetvli {{.*}}, {{m2|m4|m8}}, {{.*}}
// NSCORE-V3: vsetvli {{.*}}, {{m1|mf2|mf4|mf8}}, {{.*}}

// NSCORE-V2-NOT: vsetvli {{.*}}, {{mf2|mf4|mf8|m2|m4|m8}}, {{.*}}
// NSCORE-V2: vsetvli {{.*}}, m1, {{.*}}
void funcMulAdd_16_32_16_64(int16_t *A, int32_t *B, int16_t *C, int64_t *D, unsigned N) {
    for (int i = 0; i < N; ++i)
        D[i] = (int64_t)A[i] * (int64_t)B[i] + (int64_t)C[i];
}

// Vector integer types without explicit casts

// NSCORE-V3-NOT: vsetvli {{.*}}, {{m2|m4|m8}}, {{.*}}
// NSCORE-V3: vsetvli {{.*}}, {{m1|mf2|mf4|mf8}}, {{.*}}

// NSCORE-V2-NOT: vsetvli {{.*}}, {{mf2|mf4|mf8|m2|m4|m8}}, {{.*}}
// NSCORE-V2: vsetvli {{.*}}, m1, {{.*}}
void funcMul_32_32_64_no_cast(int32_t *A, int32_t *B, int64_t *C, unsigned N) {
    for (int i = 0; i < N; ++i)
        C[i] = A[i] * B[i];
}

// NSCORE-V3-NOT: vsetvli {{.*}}, {{m2|m4|m8}}, {{.*}}
// NSCORE-V3: vsetvli {{.*}}, {{m1|mf2|mf4|mf8}}, {{.*}}

// NSCORE-V2-NOT: vsetvli {{.*}}, {{mf2|mf4|mf8|m2|m4|m8}}, {{.*}}
// NSCORE-V2: vsetvli {{.*}}, m1, {{.*}}
void funcAdd_16_16_32_no_cast(int16_t *A, int16_t *B, int32_t *C, unsigned N) {
    for (int i = 0; i < N; ++i)
        C[i] = A[i] + B[i];
}

// NSCORE-V3-NOT: vsetvli {{.*}}, {{m2|m4|m8}}, {{.*}}
// NSCORE-V3: vsetvli {{.*}}, {{m1|mf2|mf4|mf8}}, {{.*}}

// NSCORE-V2-NOT: vsetvli {{.*}}, {{mf2|mf4|mf8|m2|m4|m8}}, {{.*}}
// NSCORE-V2: vsetvli {{.*}}, m1, {{.*}}
void funcMul_8_8_16_no_cast(int8_t *A, int8_t *B, int16_t *C, unsigned N) {
    for (int i = 0; i < N; ++i)
        C[i] = A[i] * B[i];
}

// NSCORE-V3-NOT: vsetvli {{.*}}, {{m2|m4|m8}}, {{.*}}
// NSCORE-V3: vsetvli {{.*}}, {{m1|mf2|mf4|mf8}}, {{.*}}

// NSCORE-V2-NOT: vsetvli {{.*}}, {{mf2|mf4|mf8|m2|m4|m8}}, {{.*}}
// NSCORE-V2: vsetvli {{.*}}, m1, {{.*}}
void funcAdd_16_16_64_no_cast(int16_t *A, int16_t *B, int64_t *C, unsigned N) {
    for (int i = 0; i < N; ++i)
        C[i] = A[i] + B[i];
}

// NSCORE-V3-NOT: vsetvli {{.*}}, {{m2|m4|m8}}, {{.*}}
// NSCORE-V3: vsetvli {{.*}}, {{m1|mf2|mf4|mf8}}, {{.*}}

// NSCORE-V2-NOT: vsetvli {{.*}}, {{mf2|mf4|mf8|m2|m4|m8}}, {{.*}}
// NSCORE-V2: vsetvli {{.*}}, m1, {{.*}}
void funcMul_16_32_64_no_cast(int16_t *A, int32_t *B, int64_t *C, unsigned N) {
    for (int i = 0; i < N; ++i)
        C[i] = A[i] * B[i];
}

// NSCORE-V3-NOT: vsetvli {{.*}}, {{m2|m4|m8}}, {{.*}}
// NSCORE-V3: vsetvli {{.*}}, {{m1|mf2|mf4|mf8}}, {{.*}}

// NSCORE-V2-NOT: vsetvli {{.*}}, {{mf2|mf4|mf8|m2|m4|m8}}, {{.*}}
// NSCORE-V2: vsetvli {{.*}}, m1, {{.*}}
void funcAdd_16_64_64_no_cast(int16_t *A, int64_t *B, int64_t *C, unsigned N) {
    for (int i = 0; i < N; ++i)
        C[i] = A[i] + B[i];
}

// NSCORE-V3-NOT: vsetvli {{.*}}, {{m2|m4|m8}}, {{.*}}
// NSCORE-V3: vsetvli {{.*}}, {{m1|mf2|mf4|mf8}}, {{.*}}

// NSCORE-V2-NOT: vsetvli {{.*}}, {{mf2|mf4|mf8|m2|m4|m8}}, {{.*}}
// NSCORE-V2: vsetvli {{.*}}, m1, {{.*}}
void funcMul_32_64_64_no_cast(int32_t *A, int64_t *B, int64_t *C, unsigned N) {
    for (int i = 0; i < N; ++i)
        C[i] = A[i] * B[i];
}

// NSCORE-V3-NOT: vsetvli {{.*}}, {{m2|m4|m8}}, {{.*}}
// NSCORE-V3: vsetvli {{.*}}, {{m1|mf2|mf4|mf8}}, {{.*}}

// NSCORE-V2-NOT: vsetvli {{.*}}, {{mf2|mf4|mf8|m2|m4|m8}}, {{.*}}
// NSCORE-V2: vsetvli {{.*}}, m1, {{.*}}
void funcAdd_16_32_32_no_cast(int16_t *A, int32_t *B, int32_t *C, unsigned N) {
    for (int i = 0; i < N; ++i)
        C[i] = A[i] + B[i];
}

// NSCORE-V3-NOT: vsetvli {{.*}}, {{m2|m4|m8}}, {{.*}}
// NSCORE-V3: vsetvli {{.*}}, {{m1|mf2|mf4|mf8}}, {{.*}}

// NSCORE-V2-NOT: vsetvli {{.*}}, {{mf2|mf4|mf8|m2|m4|m8}}, {{.*}}
// NSCORE-V2: vsetvli {{.*}}, m1, {{.*}}
void funcMulAdd_32_32_32_64_no_cast(int32_t *A, int32_t *B, int32_t *C, int64_t *D, unsigned N) {
    for (int i = 0; i < N; ++i)
        D[i] = A[i] * B[i] + C[i];
}

// NSCORE-V3-NOT: vsetvli {{.*}}, {{m2|m4|m8}}, {{.*}}
// NSCORE-V3: vsetvli {{.*}}, {{m1|mf2|mf4|mf8}}, {{.*}}

// NSCORE-V2-NOT: vsetvli {{.*}}, {{mf2|mf4|mf8|m2|m4|m8}}, {{.*}}
// NSCORE-V2: vsetvli {{.*}}, m1, {{.*}}
void funcMulAdd_16_16_16_32_no_cast(int16_t *A, int16_t *B, int16_t *C, int32_t *D, unsigned N) {
    for (int i = 0; i < N; ++i)
        D[i] = A[i] * B[i] + C[i];
}

// NSCORE-V3-NOT: vsetvli {{.*}}, {{m2|m4|m8}}, {{.*}}
// NSCORE-V3: vsetvli {{.*}}, {{m1|mf2|mf4|mf8}}, {{.*}}

// NSCORE-V2-NOT: vsetvli {{.*}}, {{mf2|mf4|mf8|m2|m4|m8}}, {{.*}}
// NSCORE-V2: vsetvli {{.*}}, m1, {{.*}}
void funcMulAdd_16_16_16_64_no_cast(int16_t *A, int16_t *B, int16_t *C, int64_t *D, unsigned N) {
    for (int i = 0; i < N; ++i)
        D[i] = A[i] * B[i] + C[i];
}

// NSCORE-V3-NOT: vsetvli {{.*}}, {{m2|m4|m8}}, {{.*}}
// NSCORE-V3: vsetvli {{.*}}, {{m1|mf2|mf4|mf8}}, {{.*}}

// NSCORE-V2-NOT: vsetvli {{.*}}, {{mf2|mf4|mf8|m2|m4|m8}}, {{.*}}
// NSCORE-V2: vsetvli {{.*}}, m1, {{.*}}
void funcMulAdd_16_32_32_64_no_cast(int16_t *A, int32_t *B, int32_t *C, int64_t *D, unsigned N) {
    for (int i = 0; i < N; ++i)
        D[i] = A[i] * B[i] + C[i];
}

// NSCORE-V3-NOT: vsetvli {{.*}}, {{m2|m4|m8}}, {{.*}}
// NSCORE-V3: vsetvli {{.*}}, {{m1|mf2|mf4|mf8}}, {{.*}}

// NSCORE-V2-NOT: vsetvli {{.*}}, {{mf2|mf4|mf8|m2|m4|m8}}, {{.*}}
// NSCORE-V2: vsetvli {{.*}}, m1, {{.*}}
void funcMulAdd_16_16_32_64_no_cast(int16_t *A, int16_t *B, int32_t *C, int64_t *D, unsigned N) {
    for (int i = 0; i < N; ++i)
        D[i] = A[i] * B[i] + C[i];
}

// NSCORE-V3-NOT: vsetvli {{.*}}, {{m2|m4|m8}}, {{.*}}
// NSCORE-V3: vsetvli {{.*}}, {{m1|mf2|mf4|mf8}}, {{.*}}

// NSCORE-V2-NOT: vsetvli {{.*}}, {{mf2|mf4|mf8|m2|m4|m8}}, {{.*}}
// NSCORE-V2: vsetvli {{.*}}, m1, {{.*}}
void funcMulAdd_16_32_16_64_no_cast(int16_t *A, int32_t *B, int16_t *C, int64_t *D, unsigned N) {
    for (int i = 0; i < N; ++i)
        D[i] = A[i] * B[i] + C[i];
}

// Vector fp types with explicit casts

// NSCORE-V3-NOT: vsetvli {{.*}}, {{m2|m4|m8}}, {{.*}}
// NSCORE-V3: vsetvli {{.*}}, {{m1|mf2|mf4|mf8}}, {{.*}}

// NSCORE-V2-NOT: vsetvli {{.*}}, {{mf2|mf4|mf8|m2|m4|m8}}, {{.*}}
// NSCORE-V2: vsetvli {{.*}}, m1, {{.*}}
void funcFPMul_32_32_64(float *A, float *B, double *C, unsigned N) {
    for (int i = 0; i < N; ++i)
        C[i] = (double)A[i] * (double)B[i];
}

// NSCORE-V3-NOT: vsetvli {{.*}}, {{m2|m4|m8}}, {{.*}}
// NSCORE-V3: vsetvli {{.*}}, {{m1|mf2|mf4|mf8}}, {{.*}}

// NSCORE-V2-NOT: vsetvli {{.*}}, {{mf2|mf4|mf8|m2|m4|m8}}, {{.*}}
// NSCORE-V2: vsetvli {{.*}}, m1, {{.*}}
void funcFPAdd_32_64_64(float *A, double *B, double *C, unsigned N) {
    for (int i = 0; i < N; ++i)
        C[i] = (double)A[i] + B[i];
}

// NSCORE-V3-NOT: vsetvli {{.*}}, {{m2|m4|m8}}, {{.*}}
// NSCORE-V3: vsetvli {{.*}}, {{m1|mf2|mf4|mf8}}, {{.*}}

// NSCORE-V2-NOT: vsetvli {{.*}}, {{mf2|mf4|mf8|m2|m4|m8}}, {{.*}}
// NSCORE-V2: vsetvli {{.*}}, m1, {{.*}}
void funcFPMulAdd_32_32_32_64(float *A, float *B, float *C, double *D, unsigned N) {
    for (int i = 0; i < N; ++i)
        D[i] = (double)A[i] * (double)B[i] + (double)C[i];
}

// Vector fp types with explicit casts

// NSCORE-V3-NOT: vsetvli {{.*}}, {{m2|m4|m8}}, {{.*}}
// NSCORE-V3: vsetvli {{.*}}, {{m1|mf2|mf4|mf8}}, {{.*}}

// NSCORE-V2-NOT: vsetvli {{.*}}, {{mf2|mf4|mf8|m2|m4|m8}}, {{.*}}
// NSCORE-V2: vsetvli {{.*}}, m1, {{.*}}
void funcFPMul_32_32_64_no_cast(float *A, float *B, double *C, unsigned N) {
    for (int i = 0; i < N; ++i)
        C[i] = A[i] * B[i];
}

 // NSCORE-V3-NOT: vsetvli {{.*}}, {{m2|m4|m8}}, {{.*}}
 // NSCORE-V3: vsetvli {{.*}}, {{m1|mf2|mf4|mf8}}, {{.*}}
 
// NSCORE-V2-NOT: vsetvli {{.*}}, {{mf2|mf4|mf8|m2|m4|m8}}, {{.*}}
// NSCORE-V2: vsetvli {{.*}}, m1, {{.*}}
void funcFPAdd_32_64_64_no_cast(float *A, double *B, double *C, unsigned N) {
    for (int i = 0; i < N; ++i)
        C[i] = A[i] + B[i];
 }
 
 // NSCORE-V3-NOT: vsetvli {{.*}}, {{m2|m4|m8}}, {{.*}}
 // NSCORE-V3: vsetvli {{.*}}, {{m1|mf2|mf4|mf8}}, {{.*}}
 
// NSCORE-V2-NOT: vsetvli {{.*}}, {{mf2|mf4|mf8|m2|m4|m8}}, {{.*}}
// NSCORE-V2: vsetvli {{.*}}, m1, {{.*}}
void funcFPMulAdd_32_32_32_64_no_cast(float *A, float *B, float *C, double *D, unsigned N) {
    for (int i = 0; i < N; ++i)
      D[i] = A[i] * B[i] + C[i];
}