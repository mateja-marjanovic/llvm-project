//----------------------------------------------------------------------//

def NSCoreModel : SchedMachineModel {
  let IssueWidth        = 10;   // 10 wide decode 
  let MicroOpBufferSize = 480;  // 480 entries ROB
  let LoadLatency       = 4;    // load to usw latency
  let MispredictPenalty = 14;   // Fetch + Decode/Rename/Dispatch + Branch
   
  let CompleteModel = 0;
}

let SchedModel = NSCoreModel in {

//===----------------------------------------------------------------------===//
// RSU Sections depth.

def NSC_RSALU  : ProcResource<6>{
  let BufferSize = 20;     //6x20 total 120
 } 
def NSC_ALUDIV : ProcResource<3>;
def NSC_ALUMUL : ProcResource<3>;

def NSC_RSBR   : ProcResource<3>{
  let BufferSize = 12;
 }
def NSC_RSVFP  : ProcResource<4>{
  let BufferSize = 24;
}
def NSC_VFPDIV : ProcResource<2>;

def NSC_RSAGLD : ProcResource<3>;
def NSC_RSAGST : ProcResource<2>{
 let BufferSize = 16; //STD
}
def NSC_RSAGU  : ProcResGroup<[NSC_RSAGLD, NSC_RSAGST]>{
 let BufferSize = 72; //flat STA+LD
}

//===----------------------------------------------------------------------===//

// Branching
def : WriteRes<WriteJmp,  [NSC_RSBR]>;
def : WriteRes<WriteJal,  [NSC_RSBR]>;
def : WriteRes<WriteJalr, [NSC_RSBR]>;

// Base - I ext ALU
def : WriteRes<WriteIALU32,     [NSC_RSALU]>;
def : WriteRes<WriteIALU,       [NSC_RSALU]>;
def : WriteRes<WriteShiftImm32, [NSC_RSALU]>;
def : WriteRes<WriteShiftImm,   [NSC_RSALU]>;
def : WriteRes<WriteShiftReg32, [NSC_RSALU]>;
def : WriteRes<WriteShiftReg,   [NSC_RSALU]>;
def : WriteRes<WriteCSR,        [NSC_RSALU]>;
def : WriteRes<WriteNop,        [NSC_RSALU]>;

// Intger Mul
let Latency = 3 in {
  def : WriteRes<WriteIMul,   [NSC_RSALU, NSC_ALUMUL]>;
  def : WriteRes<WriteIMul32, [NSC_RSALU, NSC_ALUMUL]>;
}

// Integer div
def : WriteRes<WriteIDiv, [NSC_RSALU, NSC_ALUDIV]> {
  let Latency = 20;
  let ReleaseAtCycles = [1, 20];
}
def : WriteRes<WriteIDiv32, [NSC_RSALU, NSC_ALUDIV]> {
  let Latency = 20;
  let ReleaseAtCycles = [1, 20];
}
def : WriteRes<WriteIRem, [NSC_RSALU, NSC_ALUDIV]> {
  let Latency = 20;
  let ReleaseAtCycles = [1, 20];
}
def : WriteRes<WriteIRem32, [NSC_RSALU, NSC_ALUDIV]> {
  let Latency = 20;
  let ReleaseAtCycles = [1, 20];
}

// Bitmanip 1 cyc
def : WriteRes<WriteRotateImm,    [NSC_RSALU]>;
def : WriteRes<WriteRotateImm32,  [NSC_RSALU]>;
def : WriteRes<WriteRotateReg,    [NSC_RSALU]>;
def : WriteRes<WriteRotateReg32,  [NSC_RSALU]>;
def : WriteRes<WriteSingleBit,    [NSC_RSALU]>;
def : WriteRes<WriteSingleBitImm, [NSC_RSALU]>;
def : WriteRes<WriteBEXT, [NSC_RSALU]>;
def : WriteRes<WriteBEXTI, [NSC_RSALU]>;
def : WriteRes<WriteORCB, [NSC_RSALU]>;
def : WriteRes<WriteREV8, [NSC_RSALU]>;
def : WriteRes<WriteSHXADD, [NSC_RSALU]>;
def : WriteRes<WriteSHXADD32, [NSC_RSALU]>;
def : WriteRes<WriteCLZ, [NSC_RSALU]>;
def : WriteRes<WriteCLZ32, [NSC_RSALU]>;
def : WriteRes<WriteCTZ, [NSC_RSALU]>;
def : WriteRes<WriteCTZ32, [NSC_RSALU]>;

// Bitmanip 2 cyc
let Latency = 2 in {
  def : WriteRes<WriteCPOP,    [NSC_RSALU]>;
  def : WriteRes<WriteCPOP32,  [NSC_RSALU]>;
  def : WriteRes<WriteIMinMax, [NSC_RSALU]>;
  // def : WriteRes<WriteCLMUL,   [NSC_RSALU]>;
}

// Memory
def : WriteRes<WriteSTB,   [NSC_RSAGST]>;
def : WriteRes<WriteSTH,   [NSC_RSAGST]>;
def : WriteRes<WriteSTW,   [NSC_RSAGST]>;
def : WriteRes<WriteSTD,   [NSC_RSAGST]>;
def : WriteRes<WriteFST32, [NSC_RSAGST]>;
def : WriteRes<WriteFST64, [NSC_RSAGST]>;

let Latency = 4 in {
  def : WriteRes<WriteLDB,   [NSC_RSAGLD]>;
  def : WriteRes<WriteLDH,   [NSC_RSAGLD]>;
  def : WriteRes<WriteLDW,   [NSC_RSAGLD]>;
  def : WriteRes<WriteLDD,   [NSC_RSAGLD]>;
  def : WriteRes<WriteFLD32, [NSC_RSAGLD]>;
  def : WriteRes<WriteFLD64, [NSC_RSAGLD]>;
}

// A - Ext
def : WriteRes<WriteAtomicSTW, [NSC_RSAGU]>;
def : WriteRes<WriteAtomicSTD, [NSC_RSAGU]>;

let Latency = 4 in {
  def : WriteRes<WriteAtomicW,   [NSC_RSAGU]>;
  def : WriteRes<WriteAtomicD,   [NSC_RSAGU]>;
  def : WriteRes<WriteAtomicLDW, [NSC_RSAGU]>;
  def : WriteRes<WriteAtomicLDD, [NSC_RSAGU]>;
}

// FP Scalar 

//FP 1 cycle
def : WriteRes<WriteFSGNJ32, [NSC_RSVFP]>;
def : WriteRes<WriteFSGNJ64, [NSC_RSVFP]>;
//FP 2 cycle
let Latency = 2 in {
  def : WriteRes<WriteFMinMax32,    [NSC_RSVFP]>;
  def : WriteRes<WriteFMinMax64,    [NSC_RSVFP]>;
  def : WriteRes<WriteFCvtF32ToF64, [NSC_RSVFP]>;
  def : WriteRes<WriteFCvtF64ToF32, [NSC_RSVFP]>;
}
//FP 5 cycle
let Latency = 5 in {
  def : WriteRes<WriteFAdd32, [NSC_RSVFP]>;
  def : WriteRes<WriteFMul32, [NSC_RSVFP]>;
  def : WriteRes<WriteFMA32,  [NSC_RSVFP]>;
  def : WriteRes<WriteFAdd64, [NSC_RSVFP]>;
  def : WriteRes<WriteFMul64, [NSC_RSVFP]>;
  def : WriteRes<WriteFMA64,  [NSC_RSVFP]>;
}
// FP Div
def :  WriteRes<WriteFDiv32,  [NSC_RSVFP, NSC_VFPDIV]> {
  let Latency = 16;
  let ReleaseAtCycles = [1, 16]; 
}
def :  WriteRes<WriteFDiv64,  [NSC_RSVFP, NSC_VFPDIV]> {
  let Latency = 16;
  let ReleaseAtCycles = [1, 16]; 
}
def :  WriteRes<WriteFSqrt32,  [NSC_RSVFP, NSC_VFPDIV]> {
  let Latency = 18;
  let ReleaseAtCycles = [1, 18]; 
}
def :  WriteRes<WriteFSqrt64,  [NSC_RSVFP, NSC_VFPDIV]> {
  let Latency = 18;
  let ReleaseAtCycles = [1, 18]; 
}

// Xstack
// I2VFP
let Latency = 2 in {
  def : WriteRes<WriteFCvtI32ToF32, [NSC_RSALU, NSC_RSVFP]>;
  def : WriteRes<WriteFCvtI32ToF64, [NSC_RSALU, NSC_RSVFP]>;
  def : WriteRes<WriteFCvtI64ToF32, [NSC_RSALU, NSC_RSVFP]>;
  def : WriteRes<WriteFCvtI64ToF64, [NSC_RSALU, NSC_RSVFP]>;
  def : WriteRes<WriteFMovI32ToF32, [NSC_RSALU, NSC_RSVFP]>;
  def : WriteRes<WriteFMovI64ToF64, [NSC_RSALU, NSC_RSVFP]>;
//VFP2Int
  def : WriteRes<WriteFCvtF32ToI32, [NSC_RSVFP, NSC_RSALU]>;
  def : WriteRes<WriteFCvtF32ToI64, [NSC_RSVFP, NSC_RSALU]>;
  def : WriteRes<WriteFCvtF64ToI32, [NSC_RSVFP, NSC_RSALU]>;
  def : WriteRes<WriteFCvtF64ToI64, [NSC_RSVFP, NSC_RSALU]>;
  def : WriteRes<WriteFClass32,     [NSC_RSVFP, NSC_RSVFP]>;
  def : WriteRes<WriteFClass64,     [NSC_RSVFP, NSC_RSVFP]>;
  def : WriteRes<WriteFCmp32,       [NSC_RSVFP, NSC_RSVFP]>;
  def : WriteRes<WriteFCmp64,       [NSC_RSVFP, NSC_RSVFP]>;
  def : WriteRes<WriteFMovF32ToI32, [NSC_RSVFP, NSC_RSALU]>;
  def : WriteRes<WriteFMovF64ToI64, [NSC_RSVFP, NSC_RSALU]>;
}

//===----------------------------------------------------------------------===//
// Bypass and advance
def : ReadAdvance<ReadJmp, 0>;
def : ReadAdvance<ReadJalr, 0>;
def : ReadAdvance<ReadCSR, 0>;
def : ReadAdvance<ReadStoreData, 0>;
def : ReadAdvance<ReadMemBase, 0>;
def : ReadAdvance<ReadIALU, 0>;
def : ReadAdvance<ReadIALU32, 0>;
def : ReadAdvance<ReadShiftImm, 0>;
def : ReadAdvance<ReadShiftImm32, 0>;
def : ReadAdvance<ReadShiftReg, 0>;
def : ReadAdvance<ReadShiftReg32, 0>;
def : ReadAdvance<ReadIDiv, 0>;
def : ReadAdvance<ReadIDiv32, 0>;
def : ReadAdvance<ReadIRem, 0>;
def : ReadAdvance<ReadIRem32, 0>;
def : ReadAdvance<ReadIMul, 0>;
def : ReadAdvance<ReadIMul32, 0>;
def : ReadAdvance<ReadAtomicWA, 0>;
def : ReadAdvance<ReadAtomicWD, 0>;
def : ReadAdvance<ReadAtomicDA, 0>;
def : ReadAdvance<ReadAtomicDD, 0>;
def : ReadAdvance<ReadAtomicLDW, 0>;
def : ReadAdvance<ReadAtomicLDD, 0>;
def : ReadAdvance<ReadAtomicSTW, 0>;
def : ReadAdvance<ReadAtomicSTD, 0>;
def : ReadAdvance<ReadFStoreData, 0>;
def : ReadAdvance<ReadFMemBase, 0>;
def : ReadAdvance<ReadFAdd32, 0>;
def : ReadAdvance<ReadFAdd64, 0>;
def : ReadAdvance<ReadFMul32, 0>;
def : ReadAdvance<ReadFMul64, 0>;
def : ReadAdvance<ReadFMA32, 0>;
def : ReadAdvance<ReadFMA32Addend, 0>;
def : ReadAdvance<ReadFMA64, 0>;
def : ReadAdvance<ReadFMA64Addend, 0>;
def : ReadAdvance<ReadFDiv32, 0>;
def : ReadAdvance<ReadFDiv64, 0>;
def : ReadAdvance<ReadFSqrt32, 0>;
def : ReadAdvance<ReadFSqrt64, 0>;
def : ReadAdvance<ReadFCmp32, 0>;
def : ReadAdvance<ReadFCmp64, 0>;
def : ReadAdvance<ReadFSGNJ32, 0>;
def : ReadAdvance<ReadFSGNJ64, 0>;
def : ReadAdvance<ReadFMinMax32, 0>;
def : ReadAdvance<ReadFMinMax64, 0>;
def : ReadAdvance<ReadFCvtF32ToI32, 0>;
def : ReadAdvance<ReadFCvtF32ToI64, 0>;
def : ReadAdvance<ReadFCvtF64ToI32, 0>;
def : ReadAdvance<ReadFCvtF64ToI64, 0>;
def : ReadAdvance<ReadFCvtI32ToF32, 0>;
def : ReadAdvance<ReadFCvtI32ToF64, 0>;
def : ReadAdvance<ReadFCvtI64ToF32, 0>;
def : ReadAdvance<ReadFCvtI64ToF64, 0>;
def : ReadAdvance<ReadFCvtF32ToF64, 0>;
def : ReadAdvance<ReadFCvtF64ToF32, 0>;
def : ReadAdvance<ReadFMovF32ToI32, 0>;
def : ReadAdvance<ReadFMovI32ToF32, 0>;
def : ReadAdvance<ReadFMovF64ToI64, 0>;
def : ReadAdvance<ReadFMovI64ToF64, 0>;
def : ReadAdvance<ReadFClass32, 0>;
def : ReadAdvance<ReadFClass64, 0>;

// Bitmanip
def : ReadAdvance<ReadRotateImm, 0>;
def : ReadAdvance<ReadRotateImm32, 0>;
def : ReadAdvance<ReadRotateReg, 0>;
def : ReadAdvance<ReadRotateReg32, 0>;
def : ReadAdvance<ReadCLZ, 0>;
def : ReadAdvance<ReadCLZ32, 0>;
def : ReadAdvance<ReadCTZ, 0>;
def : ReadAdvance<ReadCTZ32, 0>;
def : ReadAdvance<ReadCPOP, 0>;
def : ReadAdvance<ReadCPOP32, 0>;
def : ReadAdvance<ReadORCB, 0>;
def : ReadAdvance<ReadIMinMax, 0>;
def : ReadAdvance<ReadREV8, 0>;
def : ReadAdvance<ReadSHXADD, 0>;
def : ReadAdvance<ReadSHXADD32, 0>;
// Single-bit instructions
def : ReadAdvance<ReadSingleBit, 0>;
def : ReadAdvance<ReadSingleBitImm, 0>;

//===----------------------------------------------------------------------===//
// Unsupported extensions
defm : UnsupportedSchedV;
defm : UnsupportedSchedZabha;
defm : UnsupportedSchedZbc;
defm : UnsupportedSchedZbkb;
defm : UnsupportedSchedZbkx;
defm : UnsupportedSchedZfa;
defm : UnsupportedSchedZfhmin;
defm : UnsupportedSchedQ;
defm : UnsupportedSchedZvk;
defm : UnsupportedSchedSFB;
defm : UnsupportedSchedXsf;
}
