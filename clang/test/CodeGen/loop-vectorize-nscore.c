// RUN: %clang --target=riscv64-unknown-elf -mcpu=nextsilicon-ns-core-v2 -march=rv64gcv -O3 -S -o - %s | FileCheck %s -check-prefix=NSCORE-V2
// RUN: %clang --target=riscv64-unknown-elf -mcpu=nextsilicon-ns-core-v3 -march=rv64gcv -O3 -S -o - %s | FileCheck %s -check-prefix=NSCORE-V3

#include <stdint.h>

// Check only that vsetvli instructions have LMUL <= 1, because NSCORE-V3
// automatically sets LMUL limit to 1.
// NSCORE-V3-NOT: vsetvli {{.*}}, {{m2|m4|m8}}, {{.*}}
// NSCORE-V3: vsetvli {{.*}}, {{m1|mf2|mf4|mf8}}, {{.*}}

// To be changed when LMUL fix is merged.
// NSCORE-V2: vsetvli {{.*}}
void foo_add(int64_t *A, int32_t *B, int32_t *C, int N) {
    for (int i = 0; i < N; ++i)
        A[i] = B[i] + C[i];
}

// NSCORE-V3-NOT: vsetvli {{.*}}, {{m2|m4|m8}}, {{.*}}
// NSCORE-V3: vsetvli {{.*}}, {{m1|mf2|mf4|mf8}}, {{.*}}

// NSCORE-V2: vsetvli {{.*}}
// To be changed when LMUL fix is merged.
void foo_mul(int32_t *A, int16_t *B, int16_t *C, int N) {
    for (int i = 0; i < N; ++i)
        A[i] = B[i] * C[i];
}