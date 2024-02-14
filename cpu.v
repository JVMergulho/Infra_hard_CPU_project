module cpu (

  input wire clk,
  input wire reset
);

  //SINAIS DE CONTROLE

    //load de registradores
    wire EPC_W;
    wire PCWrite;
    wire MDR_W;
    wire A_W;
    wire B_W;
    wire ALUOut_W;
    wire RegDiv_W;
    wire Hi_W;
    wire Lo_W;

    //controle de estruturas
    wire [2:0] ShifterCtrl;
    wire [2:0] ALUCtrl;
    wire [1:0] StoreCtrl;
    wire [1:0] LoadCtrl;
    wire MemWrite, RegWrite, IRWrite, DivCtrl, MultCtrl;

    // MUXS
    wire [2:0] MemReadCtrl;
    wire [1:0] EntEnd;
    wire [2:0] EntWrite;
    wire [1:0] ALUSrcA;
    wire [1:0] ALUSrcB;
    wire [1:0] PCCtrl;
    wire [1:0] PCSource;
    wire [1:0] ShiftEntCtrl;
    wire [1:0] ShiftShiftCtrl;
    wire LoCtrl, HiCtrl, DivSrcA, DivSrcB;
  
  //FIOS

    //saÃ­das dos MUXs
    wire [31:0] PCCtrl_Out;
    wire [31:0] MemReadCtrl_Out;
    wire [4:0] EntEnd_Out;
    wire [31:0] EntWrite_Out; 
    wire [31:0] ShiftEntCtrl_Out;
    wire [4:0] ShiftShiftCtrl_Out;
    wire [31:0] PCSource_Out;
    wire [31:0] ALUSrcA_Out;
    wire [31:0] ALUSrcB_Out;
    wire [31:0] DivSrcA_Out;
    wire [31:0] DivSrcB_Out;
    wire [31:0] HiCtrl_Out;  
    wire [31:0] LoCtrl_Out;

    //saÃ­das dos REGs
    wire [31:0] EPC_Out;
    wire [31:0] PC_Out;
    wire [31:0] MDR_Out;
    wire [31:0] RegA_Out;
    wire [31:0] RegB_Out;
    wire [31:0] ALUOut_Out;
    wire [31:0] RegDiv_Out;
    wire [31:0] Hi_Out;
    wire [31:0] Lo_Out;

    //saidas dos componentes
    wire [31:0] Mem_Out;
    wire [31:0] ALU_Out;
    wire [31:0] RegA_In;
    wire [31:0] RegB_In;
    wire [31:0] Shift_Out;
    wire [31:0] Div_Out;
    wire [31:0] Mult_Out;
    wire [31:0] StoreSize_Out;
    wire [31:0] LoadSize_Out;

    wire [31:0] Div_Lo;
    wire [31:0] Div_Hi;
    wire [31:0] Mult_Lo;
    wire [31:0] Mult_Hi;

    wire overflow, neg, zero, ET, GT, LT, divzero;

    //saidas dos extend
    wire [31:0] Exception_Extended;
    wire [31:0] Offset_Extended;
    wire [31:0] SLT_Extended;

    //saida dos shifters
    wire [31:0] BranchShift_Out;
    wire [27:0] JumpShift_Out;

    //Instrucao

    wire [5:0] opcode;
    wire [4:0] rs;
    wire [4:0] rt;
    wire [15:0] offset;

  //Parametros

  parameter imediato16 = 5'b10000;
  parameter jal = 5'b11111;
  parameter sp = 5'b11101;
  parameter four = 32'b00000000000000000000000000000100;
  parameter opinex_address  = 32'b00000000000000000000000011111101;
  parameter overf_address   = 32'b00000000000000000000000011111110;
  parameter divzero_address = 32'b00000000000000000000000011111111;
  parameter stacktop       = 32'b00000000000000000000000011100011;


  controle CONTROLE (
    clk,
    reset,
    opcode,
    offset[5:0],
    overflow,
    divzero,
    GT,
    ET,
    MemReadCtrl, 
    EntEnd, 
    EntWrite, 
    ALUSrcA, 
    ALUSrcB,
    PCCtrl, 
    PCSource, 
    ShiftEntCtrl, 
    ShiftShiftCtrl,
    LoCtrl, 
    HiCtrl, 
    DivSrcA, 
    DivSrcB,
    A_W, 
    B_W, 
    MDR_W, 
    RegDiv_W, 
    ALUOut_W,
    PCWrite, 
    EPC_W, 
    Hi_W,
    Lo_W,
    ShifterCtrl,
    ALUCtrl,
    StoreCtrl, 
    LoadCtrl,
    MemWrite,
    RegWrite,
    IRWrite,
    DivCtrl,
    MultCtrl,
    reset
  );

  //REGISTRADORES

  Registrador EPC(
    clk, 
    reset,
    EPC_W,
    PCSource_Out,
    EPC_Out
  );
  
  Registrador PC(
    clk, 
    reset,
    PCWrite,
    PCCtrl_Out,
    PC_Out
  );

  Registrador MDR(
    clk, 
    reset,
    MDR_W,
    Mem_Out,
    MDR_Out
  );

  Registrador REG_A(
    clk, 
    reset,
    A_W,
    RegA_In,
    RegA_Out
  );

  Registrador REG_B(
    clk, 
    reset,
    B_W,
    RegB_In,
    RegB_Out
  );

  Registrador ALU_OUT(
    clk, 
    reset,
    ALUOut_W,
    ALU_Out,
    ALUOut_Out
  );

  Registrador REG_DIV(
    clk, 
    reset,
    RegDiv_W,
    MDR_Out,
    RegDiv_Out
  );

  Registrador HI(
    clk, 
    reset,
    Hi_W,
    HiCtrl_Out,
    Hi_Out
  );

  Registrador LO(
    clk, 
    reset,
    Lo_W,
    LoCtrl_Out,
    Lo_Out
  );

  //MEMORIA
  Memoria MEM(
    MemReadCtrl_Out,
    clk,
    MemWrite,
    StoreSize_Out,
    Mem_Out
  );

  //REGISTRADOR DE INSTRUCOES

  Instr_Reg IR(
    clk,
    reset,
    IRWrite,
    Mem_Out,
    opcode,
    rs,
    rt,
    offset
  );

  // BANCO DE REGISTRADORES

  Banco_reg BANCO_REG (
    clk,
    reset,
    RegWrite,
    rs,
    rt,
    EntEnd_Out,
    EntWrite_Out,
    RegA_In,
    RegB_In
  );

  // ULA

  ula32 ALU (

    ALUSrcA_Out,
    ALUSrcB_Out,
    ALUCtrl,
    ALU_Out,
    overflow,
    neg,
    zero,
    ET,
    GT,
    LT
  );

  // SHIFTER

  RegDesloc SHIFTER (
    clk,
    reset,
    ShifterCtrl,
    ShiftShiftCtrl_Out,
    ShiftEntCtrl_Out,
    Shift_Out
    
  );

  //MULTIPLEXADORES

  mux2to1_32b DIV_SRC_A(
    RegDiv_Out,
    RegA_Out,
    DivSrcA,
    DivSrcA_Out
  );
  
  mux2to1_32b DIV_SRC_B(
    RegB_Out,
    MDR_Out,
    DivSrcB,
    DivSrcB_Out
  );
  
  mux2to1_32b HI_CTRL(
    Div_Hi,
    Mult_Hi,
    HiCtrl,
    HiCtrl_Out
  );
  mux2to1_32b LO_CTRL(
    Div_Lo,
    Mult_Lo,
    LoCtrl,
    LoCtrl_Out
  );

  mux3to1_5b SHIFT_SHIFT_CTRL(
    RegB_Out[4:0],
    offset[10:6],
    imediato16,
    ShiftShiftCtrl,
    ShiftShiftCtrl_Out
  );
  
  mux3to1_32b PC_CTRL(
    EPC_Out,
    PCSource_Out,
    Exception_Extended,
    PCCtrl,
    PCCtrl_Out
    
  );
  mux3to1_32b SHIFT_ENT_CTRL(
    Offset_Extended,
    RegB_Out,
    RegA_Out,
    ShiftEntCtrl,
    ShiftEntCtrl_Out
  );
  
  mux3to1_32b PC_SOURCE(
    {PC_Out[31:28], JumpShift_Out},
    ALU_Out,
    ALUOut_Out,
    PCSource,
    PCSource_Out
  );
  
  mux3to1_32b ALU_SRC_A(
    PC_Out,
    MDR_Out,
    RegA_Out,
    ALUSrcA,
    ALUSrcA_Out
  );


  mux4to1_5b ENT_END(
    rt,
    offset[15:11],
    jal,
    sp,
    EntEnd,
    EntEnd_Out
  );

  mux4to1_32b ALU_SRC_B(
    RegB_Out,
    four,
    BranchShift_Out,
    Offset_Extended,
    ALUSrcB,
    ALUSrcB_Out
  );

  

  mux6to1_32b MEM_READ_CTRL(
    PC_Out,
    opinex_address,
    overf_address,
    divzero_address,
    ALUOut_Out,
    RegB_Out,
    MemReadCtrl,
    MemReadCtrl_Out
  );
  
  mux8to1_32b ENT_WRITE(
    ALUOut_Out,
    Shift_Out,
    Hi_Out,
    Lo_Out,
    stacktop,
    LoadSize_Out,
    PC_Out,
    SLT_Extended,
    EntWrite,
    EntWrite_Out
  );

  // EXTENSORES

  sign_extend16to32 OFFSET_EXTENDER (
    offset,
    Offset_Extended
  );

  logic_extend8to32 EXCEPTION_EXTENDER (
    Mem_Out[7:0],
    Exception_Extended
  );

  logic_extend1to32 SLT_EXTENDER (
    LT,
    SLT_Extended
  );

  //SHIFTERS

  wire [31:0] Branch_Shifted;

  Shifterleft32 BRANCH_SHIFTER (
    Offset_Extended,
    BranchShift_Out
  );

  Shifterleft26to28 JUMP_SHIFTER(
    {rs, rt, offset},
    JumpShift_Out
  );

  // DIVISOR

  divider DIVIDER (
    clk,
    reset,
    DivCtrl,
    DivSrcA_Out,
    DivSrcB_Out,
    divzero,
    Div_Hi,
    Div_Lo
  );

  // MULTIPLICADOR

  multiplier MULTIPLIER (
    clk,
    reset,
    MultCtrl,
    RegB_Out,
    RegA_Out,
    Mult_Hi,
    Mult_Lo
  );

  // LOAD SIZE UNIT

  load_unit LOAD_SIZE_UNIT (
    MDR_Out,
    LoadCtrl,
    LoadSize_Out
  );

  // STORE SIZE UNIT

  store_unit STORE_SIZE_UNIT (
    MDR_Out,
    RegB_Out,
    StoreCtrl,
    StoreSize_Out
  );
  
endmodule