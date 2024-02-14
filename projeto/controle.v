module controle(
  // entradas
  // entradas de fora do processador
  input wire clk, reset,
  
  // instruções
  input wire [5:0] OP, 
    
  input wire [5:0] func,
  
  // exceções
  input wire overflow, divzero,
  
  // vindas da ALU
  input wire GT, ET,

  // REVER CICLOS DO BRANCH E DO SHIFTER
    
  //saídas
  // multiplexadores
  output reg [2:0] MemReadCtrl, 
  output reg [1:0] EntEnd, 
  output reg [2:0] EntWrite, 
  output reg [1:0] ALUSrcA, 
  output reg [1:0] ALUSrcB,
  output reg [1:0] PCCtrl, 
  output reg [1:0] PCSource, 
  output reg [1:0] ShiftEntCtrl, 
  output reg [1:0] ShiftShiftCtrl,
  output reg LoCtrl, HiCtrl, DivSrcA, DivSrcB,
  
  // registradores
  output reg A_W, B_W, MDR_W, RegDiv_W, ALUOut_W,
  output reg PCWrite, EPC_W, Hi_W, Lo_W,
  
  //outros componentes
  output reg [2:0] ShifterCtrl,
  output reg [2:0] ALUCtrl,
  output reg [1:0] StoreCtrl, 
  output reg [1:0] LoadCtrl,
  output reg MemWrite, RegWrite, IRWrite, DivCtrl, MultCtrl,
  output reg reset_out
  );
  
    // variáveis 
    reg [5:0] state;
    reg [5:0] COUNTER;

    //Estados
    parameter RESET = 6'b000000; //0
    parameter FETCH = 6'b000001; //1
    parameter DECODE = 6'b000010; //2
    parameter OP_ERROR = 6'b000011; //3
    parameter OVERFLOW = 6'b000100; //4
    parameter DIV_ZERO = 6'b000101; //5
  
    parameter ADD = 6'b000110; //6
    parameter AND = 6'b000111; //7
    parameter DIV = 6'b001000; //8
    parameter MULT = 6'b001001; //9
    parameter JR = 6'b001010; //10
    parameter MFHI = 6'b001011;
    parameter MFLO = 6'b001100;
    parameter SLL = 6'b001101;
    parameter SLLV = 6'b001111;
    parameter SLT = 6'b010000;
    parameter SRA = 6'b010001;
    parameter SRAV = 6'b010010;
    parameter SRL = 6'b010011;
    parameter SUB = 6'b010100;
    parameter BREAK = 6'b010101;
    parameter RTE = 6'b010110;
    parameter DIVM = 6'b010111;
    parameter ADDI = 6'b011000;
    parameter ADDIU = 6'b011001;
    parameter BEQ = 6'b011010;
    parameter BNE = 6'b011011;
    parameter BLE = 6'b011100;
    parameter BGT = 6'b011101;
    parameter SLLM = 6'b011110;
    parameter LB = 6'b011111;
    parameter LH = 6'b100000;
    parameter LUI = 6'b100001;
    parameter LW = 6'b100010; // 34
    parameter SB = 6'b100011;
    parameter SH = 6'b100100;
    parameter SLTI = 6'b100101;
    parameter SW = 6'b100111; // 39
    parameter J = 6'b101000;
    parameter JAL = 6'b101001;
    parameter ADDM = 6'b101010;

    // Códigos das instruções
    // Instruções do tipo R
    parameter TypeR_OP = 6'b000000;
    parameter ADD_func = 6'b100000; 
    parameter AND_func = 6'b100100;
    parameter DIV_func = 6'b011010;
    parameter MULT_func = 6'b011000;
    parameter JR_func = 6'b001000;
    parameter MFHI_func = 6'b010000;
    parameter MFLO_func = 6'b010010;
    parameter SLL_func = 6'b000000;
    parameter SLLV_func = 6'b000100;
    parameter SLT_func = 6'b101010;
    parameter SRA_func = 6'b000011;
    parameter SRAV_func = 6'b000111;
    parameter SRL_func = 6'b000010;
    parameter SUB_func = 6'b100010;
    parameter BREAK_func = 6'b001101;
    parameter RTE_func = 6'b010011;
    parameter DIVM_func = 6'b000101;

    // Instruções do tipo I
    parameter ADDI_op = 6'b001000;
    parameter ADDIU_op = 6'b001001;
    parameter BEQ_op = 6'b000100;
    parameter BNE_op = 6'b000101;
    parameter BLE_op = 6'b000110;
    parameter BGT_op = 6'b000111;
    parameter ADDM_op = 6'b000001;
    parameter SLLM_op = 6'b000001;
    parameter LB_op = 6'b100000;
    parameter LH_op = 6'b100001;
    parameter LW_op = 6'b100011;
    parameter SB_op = 6'b101000;
    parameter SH_op = 6'b101001;
    parameter SW_op = 6'b101011;
    parameter SLTI_op = 6'b001010;
    parameter LUI_op = 6'b001111;

    //Instruções do tipo J
    parameter J_op = 6'b000010;
    parameter JAL_op = 6'b000011;

    //reset inicial
    initial begin
      reset_out = 1'b1;
      state = RESET;
    end
  

    // início da lógica do controle
    always @(posedge clk) begin

      if(reset == 1'b1 || state == RESET) begin
          
          // todas as saídas são setadas para 0
          MemReadCtrl = 3'b000; 
          EntEnd = 2'b00; 
          EntWrite = 3'b000; 
          DivSrcA = 1'b0;
          DivSrcB = 1'b0;
          ALUSrcA = 2'b00; 
          ALUSrcB = 2'b00; 
          PCCtrl = 2'b00; 
          PCSource = 2'b00; 
          LoCtrl = 1'b0; 
          HiCtrl = 1'b0; 
          ShiftEntCtrl = 2'b00; 
          ShiftShiftCtrl = 2'b00; 
          A_W = 1'b0; 
          B_W = 1'b0;
          MDR_W = 1'b0;
          RegDiv_W = 1'b0;
          ALUOut_W = 1'b0;
          PCWrite = 1'b0;
          EPC_W = 1'b0;
          Hi_W = 1'b0;
          Lo_W = 1'b0;
          ShifterCtrl = 3'b000;
          ALUCtrl = 3'b000;
          StoreCtrl = 2'b00; 
          LoadCtrl = 2'b00;
          MemWrite = 1'b0;
          RegWrite = 1'b0;
          IRWrite = 1'b0;
          DivCtrl = 1'b0;
          MultCtrl = 1'b0;
          
          // reseta a pilha
          EntEnd = 2'b11;
          EntWrite = 3'b100;
          RegWrite = 1'b1;
  
          // próximo estado
          reset_out = 1'b0;
          COUNTER = 6'b000000;
          state = FETCH;
          
      end 
      else begin
          case(state)
              // sempre acontece o fetch (3x) e depois o decode 
               FETCH: begin
                 if (COUNTER < 6'b000011) begin
                   // zerar todos os sinais que permitem escrita
                   A_W = 1'b0;
                   B_W = 1'b0;
                   MDR_W = 1'b0;
                   RegDiv_W = 1'b0; 
                   ALUOut_W = 1'b0;
                   PCWrite = 1'b0;
                   EPC_W = 1'b0;
                   Hi_W = 1'b0; 
                   Lo_W = 1'b0;
                   MemWrite = 1'b0;
                   RegWrite = 1'b0;
                   IRWrite = 1'b0;

                   // 3 primeiros ciclos
                   MemReadCtrl = 3'b000;
                   ALUSrcA = 2'b00;
                   ALUSrcB = 2'b01;
                   ALUCtrl = 3'b001;
                   PCSource = 2'b01;
                   PCCtrl = 2'b01;

                   COUNTER = COUNTER + 6'b000001; // counter é incrementado para indicar que um ciclo se passou
                 end 
                 else begin
                   // último ciclo do fetch;
                  IRWrite = 1'b1;
                  PCWrite = 1'b1;

                  COUNTER = 6'b000000;
                  state = DECODE;
                 end
              end
              
              DECODE: begin
                if (COUNTER == 6'b000000) begin

                   A_W = 1'b0;
                   B_W = 1'b0;
                   MDR_W = 1'b0;
                   RegDiv_W = 1'b0; 
                   ALUOut_W = 1'b0;
                   PCWrite = 1'b0;
                   EPC_W = 1'b0;
                   Hi_W = 1'b0; 
                   Lo_W = 1'b0;
                   MemWrite = 1'b0;
                   RegWrite = 1'b0;
                   IRWrite = 1'b0;
                  
                   A_W = 1'b1;
                   B_W = 1'b1;
                   ALUSrcA = 2'b00;
                   ALUSrcB = 2'b10;
                   ALUCtrl = 3'b001;
                   ALUOut_W = 1'b1;
                  
                   	COUNTER = COUNTER + 6'b000001; 
                 	end
                  else if (COUNTER == 6'b000001) begin

                    A_W = 1'b1;
                    B_W = 1'b1;
                    ALUSrcA = 2'b00;
                    ALUSrcB = 2'b10;
                    ALUCtrl = 3'b001;
                    ALUOut_W = 1'b1;
                    // Reinicia o counter
                    COUNTER = 6'b000000;
                  
                    case(OP)
                      TypeR_OP: begin
                        case (func)
                          // checa todas as possibilidades de func para atribuir o state certo
                          ADD_func: state = ADD;
                          AND_func: state = AND;
                          SUB_func: state = SUB;
                          DIV_func: state = DIV;
                          MULT_func: state = MULT;
                          JR_func: state = JR;
                          MFHI_func: state = MFHI;
                          MFLO_func: state = MFLO;
                          SLL_func: state = SLL;
                          SLLV_func: state = SLLV;
                          SLT_func: state = SLT;
                          SRA_func: state = SRA;
                          SRAV_func: state = SRAV;
                          SRL_func: state = SRL;
                          BREAK_func: state = BREAK;
                          RTE_func: state = RTE;
                          DIVM_func: state = DIVM;
                          default: state = OP_ERROR;
                        endcase
                      end
                      ADDI_op: state = ADDI;
                      ADDIU_op: state = ADDIU;
                      BEQ_op: state = BEQ;
                      BNE_op: state = BNE;
                      BLE_op: state = BLE;
                      BGT_op: state = BGT;
                      ADDM_op: state = ADDM;
                      LB_op: state = LB;
                      LW_op: state = LW;
                      LH_op: state = LH;
                      LUI_op: state = LUI;
                      SB_op: state = SB;
                      SH_op: state = SH;
                      SW_op: state = SW;
                      SLTI_op: state = SLTI;
                      J_op: state = J;
                      JAL_op: state = JAL;
                      default: state = OP_ERROR;
                    endcase
                  end
                 // checa o OP para atribuir o state certo
              end
              
              // checa o state e ativa os sinais necessários em cada ciclo para realizar a instrução
              //exceções
              OVERFLOW: begin  
                if(COUNTER < 6'b000011) begin
                  // zerar todos os sinais que permitem escrita
                  A_W = 1'b0;
                  B_W = 1'b0;
                  MDR_W = 1'b0;
                  RegDiv_W = 1'b0; 
                  ALUOut_W = 1'b0;
                  PCWrite = 1'b0;
                  EPC_W = 1'b0;
                  Hi_W = 1'b0; 
                  Lo_W = 1'b0;
                  MemWrite = 1'b0;
                  RegWrite = 1'b0;
                  IRWrite = 1'b0;
                  
                  MemReadCtrl = 3'b010;
                  MemWrite = 1'b0;
                  ALUSrcA = 2'b00;
                  ALUSrcB = 3'b001;
                  ALUCtrl = 3'b010;
                  PCSource = 2'b01;
                  EPC_W = 1'b1;

                  COUNTER = COUNTER + 6'b000001;
                end
                else
                  if(COUNTER == 6'b000011) begin
                    PCCtrl = 2'b10;
                    PCWrite = 1'b1;
                    EPC_W = 1'b0;

                    COUNTER = COUNTER + 6'b000001;
                  end
                else
                if(COUNTER == 6'b000100) begin

                    COUNTER = 6'b000000;
                    state = FETCH;
                  end
              end

              OP_ERROR: begin  
                if(COUNTER < 6'b000011) begin
                  // zerar todos os sinais que permitem escrita
                  A_W = 1'b0;
                  B_W = 1'b0;
                  MDR_W = 1'b0;
                  RegDiv_W = 1'b0; 
                  ALUOut_W = 1'b0;
                  PCWrite = 1'b0;
                  EPC_W = 1'b0;
                  Hi_W = 1'b0; 
                  Lo_W = 1'b0;
                  MemWrite = 1'b0;
                  RegWrite = 1'b0;
                  IRWrite = 1'b0;
                  
                  MemReadCtrl = 3'b001;
                  MemWrite = 1'b0;
                  ALUSrcA = 2'b00;
                  ALUSrcB = 3'b001;
                  ALUCtrl = 3'b010;
                  PCSource = 2'b01;
                  EPC_W = 1'b1;

                  COUNTER = COUNTER + 6'b000001;
                end
                else
                  if(COUNTER == 6'b000011) begin
                    PCCtrl = 2'b10;
                    PCWrite = 1'b1;
                    EPC_W = 1'b0;

                    COUNTER = COUNTER + 6'b000001;
                  end
                else
                if(COUNTER == 6'b000100) begin

                    COUNTER = 6'b000000;
                    state = FETCH;
                  end
              end
              DIV_ZERO: begin  
                if(COUNTER < 6'b000011) begin
                  // zerar todos os sinais que permitem escrita
                  A_W = 1'b0;
                  B_W = 1'b0;
                  MDR_W = 1'b0;
                  RegDiv_W = 1'b0; 
                  ALUOut_W = 1'b0;
                  PCWrite = 1'b0;
                  EPC_W = 1'b0;
                  Hi_W = 1'b0; 
                  Lo_W = 1'b0;
                  MemWrite = 1'b0;
                  RegWrite = 1'b0;
                  IRWrite = 1'b0;
                  
                  MemReadCtrl = 3'b011;
                  MemWrite = 1'b0;
                  ALUSrcA = 2'b00;
                  ALUSrcB = 3'b001;
                  ALUCtrl = 3'b010;
                  PCSource = 2'b01;
                  EPC_W = 1'b1;

                  COUNTER = COUNTER + 6'b000001;
                end
                else
                  if(COUNTER == 6'b000011) begin
                    PCCtrl = 2'b10;
                    PCWrite = 1'b1;
                    EPC_W = 1'b0;

                    COUNTER = COUNTER + 6'b000001;
                  end
                else
                if(COUNTER == 6'b000100) begin

                    COUNTER = 6'b000000;
                    state = FETCH;
                  end
              end
              
              //instruções R
              ADD: begin
                if(COUNTER == 6'b000000) begin
                  // zerar todos os sinais que permitem escrita
                  A_W = 1'b0;
                  B_W = 1'b0;
                  MDR_W = 1'b0;
                  RegDiv_W = 1'b0; 
                  ALUOut_W = 1'b0;
                  PCWrite = 1'b0;
                  EPC_W = 1'b0;
                  Hi_W = 1'b0; 
                  Lo_W = 1'b0;
                  MemWrite = 1'b0;
                  RegWrite = 1'b0;
                  IRWrite = 1'b0;
                  
                  ALUSrcA = 2'b10;
                  ALUSrcB = 2'b00;
                  ALUCtrl = 3'b001;
				          ALUOut_W = 1'b1;

                  COUNTER = COUNTER + 6'b000001;
                end
                else
                  if(overflow == 1'b1) begin
                    state = OVERFLOW;
  
                    COUNTER = 6'b000000;
                  end
                else 
                  if(COUNTER == 6'b000001) begin
                    EntEnd = 2'b01;
                    EntWrite = 3'b000;
                    RegWrite = 1'b1;
                    
                    COUNTER = 6'b000000;
                    state = FETCH;
                  end
              end
                
              AND: begin
                if(COUNTER == 6'b000000) begin
                  // zerar todos os sinais que permitem escrita
                  A_W = 1'b0;
                  B_W = 1'b0;
                  MDR_W = 1'b0;
                  RegDiv_W = 1'b0; 
                  ALUOut_W = 1'b0;
                  PCWrite = 1'b0;
                  EPC_W = 1'b0;
                  Hi_W = 1'b0; 
                  Lo_W = 1'b0;
                  MemWrite = 1'b0;
                  RegWrite = 1'b0;
                  IRWrite = 1'b0;
                  
                  ALUSrcA = 2'b10;
                  ALUSrcB = 2'b00;
                  ALUCtrl = 3'b011;
                  ALUOut_W = 1'b1;

                  COUNTER = COUNTER + 6'b000001;
                end 
                else
                  if(COUNTER == 6'b000001) begin
                    EntEnd = 2'b01;
                    EntWrite = 3'b000;
                    RegWrite = 1'b1;
                    
                    COUNTER = 6'b000000;
                    state = FETCH;
                  end
              end  

              SUB: begin
                if(COUNTER == 6'b000000) begin
                  // zerar todos os sinais que permitem escrita
                  A_W = 1'b0;
                  B_W = 1'b0;
                  MDR_W = 1'b0;
                  RegDiv_W = 1'b0; 
                  ALUOut_W = 1'b0;
                  PCWrite = 1'b0;
                  EPC_W = 1'b0;
                  Hi_W = 1'b0; 
                  Lo_W = 1'b0;
                  MemWrite = 1'b0;
                  RegWrite = 1'b0;
                  IRWrite = 1'b0;
                  
                  ALUSrcA = 2'b10;
                  ALUSrcB = 2'b00;
                  ALUCtrl = 3'b010;
                  ALUOut_W = 1'b1;

                   COUNTER = COUNTER + 6'b000001;
                end
                else
                  if(overflow == 1'b1) begin
                    state = OVERFLOW;
  
                    COUNTER = 6'b000000;
                  end
                else 
                  if(COUNTER == 6'b000001) begin
                    EntEnd = 2'b01;
                    EntWrite = 3'b000;
                    RegWrite = 1'b1;
                    
                    COUNTER = 6'b000000;
                    state = FETCH;
                  end 
              end
            
              ADDI: begin
                  if(COUNTER == 6'b000000) begin
                    // zerar todos os sinais que permitem escrita
                    A_W = 1'b0;
                    B_W = 1'b0;
                    MDR_W = 1'b0;
                    RegDiv_W = 1'b0; 
                    ALUOut_W = 1'b0;
                    PCWrite = 1'b0;
                    EPC_W = 1'b0;
                    Hi_W = 1'b0; 
                    Lo_W = 1'b0;
                    MemWrite = 1'b0;
                    RegWrite = 1'b0;
                    IRWrite = 1'b0;
                    
                    ALUSrcA = 2'b10;
                    ALUSrcB = 2'b11;
                    ALUCtrl = 3'b001;
                    ALUOut_W = 1'b1;

                   COUNTER = COUNTER + 6'b000001;
                end
                else
                  if(overflow == 1'b1) begin
                    state = OVERFLOW;
  
                    COUNTER = 6'b000000;
                  end
                else
                  if(COUNTER == 6'b000001) begin
                    EntEnd = 2'b00;
                    EntWrite = 3'b000;
                    RegWrite = 1'b1;
                    
                    COUNTER = 6'b000000;
                    state = FETCH;
                  end 
              end

              ADDIU: begin
                    if(COUNTER == 6'b000000) begin
                      // zerar todos os sinais que permitem escrita
                      A_W = 1'b0;
                      B_W = 1'b0;
                      MDR_W = 1'b0;
                      RegDiv_W = 1'b0; 
                      ALUOut_W = 1'b0;
                      PCWrite = 1'b0;
                      EPC_W = 1'b0;
                      Hi_W = 1'b0; 
                      Lo_W = 1'b0;
                      MemWrite = 1'b0;
                      RegWrite = 1'b0;
                      IRWrite = 1'b0;
                      
                      ALUSrcA = 2'b10;
                      ALUSrcB = 2'b11;
                      ALUCtrl = 3'b001;
                      ALUOut_W = 1'b1;
  
                     COUNTER = COUNTER + 6'b000001;
                  end
                  else 
                    if(COUNTER == 6'b000001) begin
                      EntEnd = 2'b00;
                      EntWrite = 3'b000;
                      RegWrite = 1'b1;
                      
                      COUNTER = 6'b000000;
                      state = FETCH;
                    end 
                end
              JR: begin
                      if(COUNTER == 6'b000000) begin
                        // zerar todos os sinais que permitem escrita
                        A_W = 1'b0;
                        B_W = 1'b0;
                        MDR_W = 1'b0;
                        RegDiv_W = 1'b0; 
                        ALUOut_W = 1'b0;
                        PCWrite = 1'b0;
                        EPC_W = 1'b0;
                        Hi_W = 1'b0; 
                        Lo_W = 1'b0;
                        MemWrite = 1'b0;
                        RegWrite = 1'b0;
                        IRWrite = 1'b0;
                        
                        ALUSrcA = 2'b10;
                        ALUCtrl = 3'b000;
                        PCSource = 2'b01;
                        PCCtrl = 2'b01;
                        PCWrite = 1'b1;
    
                        COUNTER = 6'b000000;
                        state = FETCH;
        
                  end
		end
              MFHI: begin
                      if(COUNTER == 6'b000000) begin
                        // zerar todos os sinais que permitem escrita
                        A_W = 1'b0;
                        B_W = 1'b0;
                        MDR_W = 1'b0;
                        RegDiv_W = 1'b0; 
                        ALUOut_W = 1'b0;
                        PCWrite = 1'b0;
                        EPC_W = 1'b0;
                        Hi_W = 1'b0; 
                        Lo_W = 1'b0;
                        MemWrite = 1'b0;
                        RegWrite = 1'b0;
                        IRWrite = 1'b0;
                        
                        EntWrite = 3'b010;
                        EntEnd = 2'b01;
                        RegWrite = 1'b1;
    
                        COUNTER = 6'b000000;
                        state = FETCH;
              
                  end
		        end

              MFLO: begin
                      if(COUNTER == 6'b000000) begin
                        // zerar todos os sinais que permitem escrita
                        A_W = 1'b0;
                        B_W = 1'b0;
                        MDR_W = 1'b0;
                        RegDiv_W = 1'b0; 
                        ALUOut_W = 1'b0;
                        PCWrite = 1'b0;
                        EPC_W = 1'b0;
                        Hi_W = 1'b0; 
                        Lo_W = 1'b0;
                        MemWrite = 1'b0;
                        RegWrite = 1'b0;
                        IRWrite = 1'b0;
                        
                        EntWrite = 3'b011;
                        EntEnd = 2'b01;
                        RegWrite = 1'b1;
    
                        COUNTER = 6'b000000;
                        state = FETCH;
                    end
                  end
              SLL: begin
                if(COUNTER == 6'b000000) begin
                      // zerar todos os sinais que permitem escrita
                      A_W = 1'b0;
                      B_W = 1'b0;
                      MDR_W = 1'b0;
                      RegDiv_W = 1'b0; 
                      ALUOut_W = 1'b0;
                      PCWrite = 1'b0;
                      EPC_W = 1'b0;
                      Hi_W = 1'b0; 
                      Lo_W = 1'b0;
                      MemWrite = 1'b0;
                      RegWrite = 1'b0;
                      IRWrite = 1'b0;
                      
                      ShiftEntCtrl = 2'b01;
                      ShiftShiftCtrl = 2'b01;
                      ShifterCtrl = 3'b001;
  
                     COUNTER = COUNTER + 6'b000001;
                  end
                  else 
                    if(COUNTER == 6'b000001) begin
                      ShifterCtrl = 3'b010;
                      
                      COUNTER = COUNTER + 6'b000001;
                      
                    end else if (COUNTER < 6'b000100) begin
                      ShifterCtrl = 3'b000;

                      COUNTER = COUNTER + 6'b000001;
                      
                    end else if (COUNTER == 6'b000100) begin
                      EntWrite = 3'b001;
                      EntEnd = 2'b01;
                      RegWrite = 1'b1;

                      COUNTER = 6'b000000;
                      state = FETCH;
                    end
                
                end
              SRA: begin
                if(COUNTER == 6'b000000) begin
                      // zerar todos os sinais que permitem escrita
                      A_W = 1'b0;
                      B_W = 1'b0;
                      MDR_W = 1'b0;
                      RegDiv_W = 1'b0; 
                      ALUOut_W = 1'b0;
                      PCWrite = 1'b0;
                      EPC_W = 1'b0;
                      Hi_W = 1'b0; 
                      Lo_W = 1'b0;
                      MemWrite = 1'b0;
                      RegWrite = 1'b0;
                      IRWrite = 1'b0;
                      
                      ShiftEntCtrl = 2'b01;
                      ShiftShiftCtrl = 2'b01;
                      ShifterCtrl = 3'b001;
  
                     COUNTER = COUNTER + 6'b000001;
                  end
                  else 
                    if(COUNTER == 6'b000001) begin
                      ShifterCtrl = 3'b100;
                      
                      COUNTER = COUNTER + 6'b000001;
                      
                    end else if (COUNTER < 6'b000100) begin
                      ShifterCtrl = 3'b000;

                      COUNTER = COUNTER + 6'b000001;
                      
                    end else if (COUNTER == 6'b000100) begin
                      EntWrite = 3'b001;
                      EntEnd = 2'b01;
                      RegWrite = 1'b1;

                      COUNTER = 6'b000000;
                      state = FETCH;
                    end
                
                end
              SRL: begin
                if(COUNTER == 6'b000000) begin
                      // zerar todos os sinais que permitem escrita
                      A_W = 1'b0;
                      B_W = 1'b0;
                      MDR_W = 1'b0;
                      RegDiv_W = 1'b0; 
                      ALUOut_W = 1'b0;
                      PCWrite = 1'b0;
                      EPC_W = 1'b0;
                      Hi_W = 1'b0; 
                      Lo_W = 1'b0;
                      MemWrite = 1'b0;
                      RegWrite = 1'b0;
                      IRWrite = 1'b0;
                      
                      ShiftEntCtrl = 2'b01;
                      ShiftShiftCtrl = 2'b01;
                      ShifterCtrl = 3'b001;
  
                     COUNTER = COUNTER + 6'b000001;
                  end
                  else 
                    if(COUNTER == 6'b000001) begin
                      ShifterCtrl = 3'b011;
                      
                      COUNTER = COUNTER + 6'b000001;
                      
                    end else if (COUNTER < 6'b000100) begin
                      ShifterCtrl = 3'b000;

                      COUNTER = COUNTER + 6'b000001;
                      
                    end else if (COUNTER == 6'b000100) begin
                      EntWrite = 3'b001;
                      EntEnd = 2'b01;
                      RegWrite = 1'b1;

                      COUNTER = 6'b000000;
                      state = FETCH;
                    end
                
                end
              SLLV: begin
                if(COUNTER == 6'b000000) begin
                      // zerar todos os sinais que permitem escrita
                      A_W = 1'b0;
                      B_W = 1'b0;
                      MDR_W = 1'b0;
                      RegDiv_W = 1'b0; 
                      ALUOut_W = 1'b0;
                      PCWrite = 1'b0;
                      EPC_W = 1'b0;
                      Hi_W = 1'b0; 
                      Lo_W = 1'b0;
                      MemWrite = 1'b0;
                      RegWrite = 1'b0;
                      IRWrite = 1'b0;
                      
                      ShiftEntCtrl = 2'b10;
                      ShiftShiftCtrl = 2'b00;
                      ShifterCtrl = 3'b001;
  
                     COUNTER = COUNTER + 6'b000001;
                  end
                  else 
                    if(COUNTER == 6'b000001) begin
                      ShifterCtrl = 3'b010;
                      
                      COUNTER = COUNTER + 6'b000001;
                      
                    end else if (COUNTER < 6'b000100) begin
                      ShifterCtrl = 3'b000;

                      COUNTER = COUNTER + 6'b000001;
                      
                    end else if (COUNTER == 6'b000100) begin
                      EntWrite = 3'b001;
                      EntEnd = 2'b01;
                      RegWrite = 1'b1;

                      COUNTER = 6'b000000;
                      state = FETCH;
                    end
                
                end
              SRAV: begin
                if(COUNTER == 6'b000000) begin
                      // zerar todos os sinais que permitem escrita
                      A_W = 1'b0;
                      B_W = 1'b0;
                      MDR_W = 1'b0;
                      RegDiv_W = 1'b0; 
                      ALUOut_W = 1'b0;
                      PCWrite = 1'b0;
                      EPC_W = 1'b0;
                      Hi_W = 1'b0; 
                      Lo_W = 1'b0;
                      MemWrite = 1'b0;
                      RegWrite = 1'b0;
                      IRWrite = 1'b0;
                      
                      ShiftEntCtrl = 2'b10;
                      ShiftShiftCtrl = 2'b00;
                      ShifterCtrl = 3'b001;
  
                     COUNTER = COUNTER + 6'b000001;
                  end
                  else 
                    if(COUNTER == 6'b000001) begin
                      ShifterCtrl = 3'b100;
                      
                      COUNTER = COUNTER + 6'b000001;
                      
                    end else if (COUNTER < 6'b000100) begin
                      ShifterCtrl = 3'b000;

                      COUNTER = COUNTER + 6'b000001;
                      
                    end else if (COUNTER == 6'b000100) begin
                      EntWrite = 3'b001;
                      EntEnd = 2'b01;
                      RegWrite = 1'b1;

                      COUNTER = 6'b000000;
                      state = FETCH;
                    end
                
                end

              BEQ: begin
              	if(COUNTER == 6'b000000) begin
                      // zerar todos os sinais que permitem escrita
                      A_W = 1'b0;
                      B_W = 1'b0;
                      MDR_W = 1'b0;
                      RegDiv_W = 1'b0; 
                      ALUOut_W = 1'b0;
                      PCWrite = 1'b0;
                      EPC_W = 1'b0;
                      Hi_W = 1'b0; 
                      Lo_W = 1'b0;
                      MemWrite = 1'b0;
                      RegWrite = 1'b0;
                      IRWrite = 1'b0;
                      
                      ALUSrcA = 2'b10;
                      ALUSrcB = 2'b00;
                      ALUCtrl = 3'b111;
  
                     COUNTER = COUNTER + 6'b000001;
                  end
                else if (COUNTER == 6'b000001) begin

                  if (ET == 1'b1) begin 
                    PCSource = 2'b10;
                    PCCtrl = 2'b01;
                    PCWrite = 1'b1;
                  end
                  
                  COUNTER = COUNTER + 6'b000001;
                end
                else if (COUNTER == 6'b000010) begin
                  
                  COUNTER = 6'b000000;
                  state = FETCH;
                end
	      end

              BNE: begin
              	if(COUNTER == 6'b000000) begin
                      // zerar todos os sinais que permitem escrita
                      A_W = 1'b0;
                      B_W = 1'b0;
                      MDR_W = 1'b0;
                      RegDiv_W = 1'b0; 
                      ALUOut_W = 1'b0;
                      PCWrite = 1'b0;
                      EPC_W = 1'b0;
                      Hi_W = 1'b0; 
                      Lo_W = 1'b0;
                      MemWrite = 1'b0;
                      RegWrite = 1'b0;
                      IRWrite = 1'b0;
                      
                      ALUSrcA = 2'b10;
                      ALUSrcB = 2'b00;
                      ALUCtrl = 3'b111;
  
                     COUNTER = COUNTER + 6'b000001;
                  end
                else if (COUNTER == 6'b000001) begin

                  if (ET == 1'b0) begin 
                    PCSource = 2'b10;
                    PCCtrl = 2'b01;
                    PCWrite = 1'b1;
                  end
                  
                  COUNTER = COUNTER + 6'b000001;
                end
                else if (COUNTER == 6'b000010) begin
                  
                  COUNTER = 6'b000000;
                  state = FETCH;
                end
	      end

              BLE: begin
                if(COUNTER == 6'b000000) begin
                    // zerar todos os sinais que permitem escrita
                    A_W = 1'b0;
                    B_W = 1'b0;
                    MDR_W = 1'b0;
                    RegDiv_W = 1'b0; 
                    ALUOut_W = 1'b0;
                    PCWrite = 1'b0;
                    EPC_W = 1'b0;
                    Hi_W = 1'b0; 
                    Lo_W = 1'b0;
                    MemWrite = 1'b0;
                    RegWrite = 1'b0;
                    IRWrite = 1'b0;
                    
                    ALUSrcA = 2'b10;
                    ALUSrcB = 2'b00;
                    ALUCtrl = 3'b111;

                   COUNTER = COUNTER + 6'b000001;
                  end
                else if (COUNTER == 6'b000001) begin

                  if (GT == 1'b0) begin 
                    PCSource = 2'b10;
                    PCCtrl = 2'b01;
                    PCWrite = 1'b1;
                  end
                  
                  COUNTER = COUNTER + 6'b000001;
                end
                else if (COUNTER == 6'b000010) begin
                  
                  COUNTER = 6'b000000;
                  state = FETCH;
                end
	       end

              BGT: begin
              if(COUNTER == 6'b000000) begin
                      // zerar todos os sinais que permitem escrita
                      A_W = 1'b0;
                      B_W = 1'b0;
                      MDR_W = 1'b0;
                      RegDiv_W = 1'b0; 
                      ALUOut_W = 1'b0;
                      PCWrite = 1'b0;
                      EPC_W = 1'b0;
                      Hi_W = 1'b0; 
                      Lo_W = 1'b0;
                      MemWrite = 1'b0;
                      RegWrite = 1'b0;
                      IRWrite = 1'b0;
                      
                      ALUSrcA = 2'b10;
                      ALUSrcB = 2'b00;
                      ALUCtrl = 3'b111;
  
                     COUNTER = COUNTER + 6'b000001;
                  end
                else if (COUNTER == 6'b000001) begin

                  if (GT == 1'b1) begin 
                    PCSource = 2'b10;
                    PCCtrl = 2'b01;
                    PCWrite = 1'b1;
                  end
                  
                  COUNTER = COUNTER + 6'b000001;
                end
                else if (COUNTER == 6'b000010) begin
                  
                  COUNTER = 6'b000000;
                  state = FETCH;
                end
	      end 
              BREAK: begin
                if(COUNTER < 6'b000010) begin
                    // zerar todos os sinais que permitem escrita
                    A_W = 1'b0;
                    B_W = 1'b0;
                    MDR_W = 1'b0;
                    RegDiv_W = 1'b0; 
                    ALUOut_W = 1'b0;
                    PCWrite = 1'b0;
                    EPC_W = 1'b0;
                    Hi_W = 1'b0; 
                    Lo_W = 1'b0;
                    MemWrite = 1'b0;
                    RegWrite = 1'b0;
                    IRWrite = 1'b0;
                    
                    ALUSrcA = 2'b00;
                    ALUSrcB = 2'b01;
                    ALUCtrl = 3'b010;
                    ALUOut_W = 1'b1;


                    COUNTER = COUNTER + 6'b000001;
                    end
                else if (COUNTER == 6'b000010) begin
                    PCSource = 2'b10;
                    PCCtrl = 2'b01;
                    PCWrite = 1'b1;
                    
                    COUNTER = 6'b000000;
                    state = FETCH;
                  end
		end
              J: begin
                if(COUNTER == 6'b000000) begin
                    // zerar todos os sinais que permitem escrita
                    A_W = 1'b0;
                    B_W = 1'b0;
                    MDR_W = 1'b0;
                    RegDiv_W = 1'b0; 
                    ALUOut_W = 1'b0;
                    PCWrite = 1'b0;
                    EPC_W = 1'b0;
                    Hi_W = 1'b0; 
                    Lo_W = 1'b0;
                    MemWrite = 1'b0;
                    RegWrite = 1'b0;
                    IRWrite = 1'b0;
                    
                    PCSource = 2'b00;
                    PCCtrl = 2'b01;
                    PCWrite = 1'b1;
  
                    COUNTER = 6'b000000;
                    state = FETCH;
                    end
		end
              JAL: begin
                if(COUNTER == 6'b000000) begin
                    // zerar todos os sinais que permitem escrita
                    A_W = 1'b0;
                    B_W = 1'b0;
                    MDR_W = 1'b0;
                    RegDiv_W = 1'b0; 
                    ALUOut_W = 1'b0;
                    PCWrite = 1'b0;
                    EPC_W = 1'b0;
                    Hi_W = 1'b0; 
                    Lo_W = 1'b0;
                    MemWrite = 1'b0;
                    RegWrite = 1'b0;
                    IRWrite = 1'b0;
                    
                    EntEnd = 2'b10;
                    EntWrite = 3'b110;
                    RegWrite = 1'b1;
  
                    COUNTER = COUNTER + 6'b000001;
		end
                  else if (COUNTER == 6'b000001) begin
                    PCSource = 2'b00;
                    PCCtrl = 2'b01;
                    PCWrite = 1'b1;
                  
                    COUNTER = 6'b000000;
                    state = FETCH;
                  end
                end
                
                LW: begin
                  if(COUNTER < 6'b000010) begin
                    // zerar todos os sinais que permitem escrita
                    A_W = 1'b0;
                    B_W = 1'b0;
                    MDR_W = 1'b0;
                    RegDiv_W = 1'b0; 
                    ALUOut_W = 1'b0;
                    PCWrite = 1'b0;
                    EPC_W = 1'b0;
                    Hi_W = 1'b0; 
                    Lo_W = 1'b0;
                    MemWrite = 1'b0;
                    RegWrite = 1'b0;
                    IRWrite = 1'b0;

                    ALUSrcA = 2'b10;
                    ALUSrcB = 2'b11;
                    ALUCtrl = 3'b001;
                    ALUOut_W = 1'b1;

                    COUNTER = COUNTER + 6'b000001;
                    
                  end else if(COUNTER < 6'b000101) begin
                    MemReadCtrl = 3'b100;
                    MemWrite = 1'b0;

                    COUNTER = COUNTER + 6'b000001;
                    
                  end else if(COUNTER < 6'b000111) begin
                    MDR_W = 1'b1;

                    COUNTER = COUNTER + 6'b000001;
                    
                  end else if(COUNTER == 6'b000111) begin
                    LoadCtrl = 2'b01;
                    EntEnd = 2'b00;
                    EntWrite = 3'b101;
                    RegWrite = 1'b1;

                    COUNTER = 6'b000000;
                    state = FETCH;
                    
                  end
                end
            
                LH: begin
                  if(COUNTER < 6'b000010) begin
                    // zerar todos os sinais que permitem escrita
                    A_W = 1'b0;
                    B_W = 1'b0;
                    MDR_W = 1'b0;
                    RegDiv_W = 1'b0; 
                    ALUOut_W = 1'b0;
                    PCWrite = 1'b0;
                    EPC_W = 1'b0;
                    Hi_W = 1'b0; 
                    Lo_W = 1'b0;
                    MemWrite = 1'b0;
                    RegWrite = 1'b0;
                    IRWrite = 1'b0;

                    ALUSrcA = 2'b10;
                    ALUSrcB = 2'b11;
                    ALUCtrl = 3'b001;
                    ALUOut_W = 1'b1;

                    COUNTER = COUNTER + 6'b000001;
                    
                  end else if(COUNTER < 6'b000101) begin
                    MemReadCtrl = 3'b100;
                    MemWrite = 1'b0;

                    COUNTER = COUNTER + 6'b000001;
                    
                  end else if(COUNTER < 6'b000111) begin
                    MDR_W = 1'b1;

                    COUNTER = COUNTER + 6'b000001;
                    
                  end else if(COUNTER == 6'b000111) begin
                    LoadCtrl = 2'b10;
                    EntEnd = 2'b00;
                    EntWrite = 3'b101;
                    RegWrite = 1'b1;

                    COUNTER = 6'b000000;
                    state = FETCH;
                    
                  end
		end

                LB: begin
                  if(COUNTER < 6'b000010) begin
                    // zerar todos os sinais que permitem escrita
                    A_W = 1'b0;
                    B_W = 1'b0;
                    MDR_W = 1'b0;
                    RegDiv_W = 1'b0; 
                    ALUOut_W = 1'b0;
                    PCWrite = 1'b0;
                    EPC_W = 1'b0;
                    Hi_W = 1'b0; 
                    Lo_W = 1'b0;
                    MemWrite = 1'b0;
                    RegWrite = 1'b0;
                    IRWrite = 1'b0;

                    ALUSrcA = 2'b10;
                    ALUSrcB = 2'b11;
                    ALUCtrl = 3'b001;
                    ALUOut_W = 1'b1;

                    COUNTER = COUNTER + 6'b000001;
                    
                  end else if(COUNTER < 6'b000101) begin
                    MemReadCtrl = 3'b100;
                    MemWrite = 1'b0;

                    COUNTER = COUNTER + 6'b000001;
                    
                  end else if(COUNTER < 6'b000111) begin
                    MDR_W = 1'b1;

                    COUNTER = COUNTER + 6'b000001;
                    
                  end else if(COUNTER == 6'b000111) begin
                    LoadCtrl = 2'b11;
                    EntEnd = 2'b00;
                    EntWrite = 3'b101;
                    RegWrite = 1'b1;

                    COUNTER = 6'b000000;
                    state = FETCH;

                  end
		end
              SW: begin
                if(COUNTER < 6'b000010) begin
                    // zerar todos os sinais que permitem escrita
                    A_W = 1'b0;
                    B_W = 1'b0;
                    MDR_W = 1'b0;
                    RegDiv_W = 1'b0; 
                    ALUOut_W = 1'b0;
                    PCWrite = 1'b0;
                    EPC_W = 1'b0;
                    Hi_W = 1'b0; 
                    Lo_W = 1'b0;
                    MemWrite = 1'b0;
                    RegWrite = 1'b0;
                    IRWrite = 1'b0;

                    ALUSrcA = 2'b10;
                    ALUSrcB = 2'b11;
                    ALUCtrl = 3'b001;
                    ALUOut_W = 1'b1;

                    COUNTER = COUNTER + 6'b000001;
                    
                end else if(COUNTER < 6'b000101) begin
                    MemReadCtrl = 3'b100;
                    MemWrite = 1'b0;

                    COUNTER = COUNTER + 6'b000001;
                    
                end else if(COUNTER < 6'b000111) begin
                    MDR_W = 1'b1;

                    COUNTER = COUNTER + 6'b000001;
                    
                end else if(COUNTER == 6'b000111) begin
                    StoreCtrl = 2'b01;
                    MemWrite = 1'b1;

                    COUNTER = 6'b000000;
                    state = FETCH;

                  end
              end      
              SH: begin
                if(COUNTER < 6'b000010) begin
                    // zerar todos os sinais que permitem escrita
                    A_W = 1'b0;
                    B_W = 1'b0;
                    MDR_W = 1'b0;
                    RegDiv_W = 1'b0; 
                    ALUOut_W = 1'b0;
                    PCWrite = 1'b0;
                    EPC_W = 1'b0;
                    Hi_W = 1'b0; 
                    Lo_W = 1'b0;
                    MemWrite = 1'b0;
                    RegWrite = 1'b0;
                    IRWrite = 1'b0;

                    ALUSrcA = 2'b10;
                    ALUSrcB = 2'b11;
                    ALUCtrl = 3'b001;
                    ALUOut_W = 1'b1;

                    COUNTER = COUNTER + 6'b000001;
                    
                end else if(COUNTER < 6'b000101) begin
                    MemReadCtrl = 3'b100;
                    MemWrite = 1'b0;

                    COUNTER = COUNTER + 6'b000001;
                    
                end else if(COUNTER < 6'b000111) begin
                    MDR_W = 1'b1;

                    COUNTER = COUNTER + 6'b000001;
                    
                end else if(COUNTER == 6'b000111) begin
                    StoreCtrl = 2'b10;
                    MemWrite = 1'b1;

                    COUNTER = 6'b000000;
                    state = FETCH;

                  end
              end      
              SB: begin
                if(COUNTER < 6'b000010) begin
                    // zerar todos os sinais que permitem escrita
                    A_W = 1'b0;
                    B_W = 1'b0;
                    MDR_W = 1'b0;
                    RegDiv_W = 1'b0; 
                    ALUOut_W = 1'b0;
                    PCWrite = 1'b0;
                    EPC_W = 1'b0;
                    Hi_W = 1'b0; 
                    Lo_W = 1'b0;
                    MemWrite = 1'b0;
                    RegWrite = 1'b0;
                    IRWrite = 1'b0;

                    ALUSrcA = 2'b10;
                    ALUSrcB = 2'b11;
                    ALUCtrl = 3'b001;
                    ALUOut_W = 1'b1;

                    COUNTER = COUNTER + 6'b000001;
                    
                end else if(COUNTER < 6'b000101) begin
                    MemReadCtrl = 3'b100;
                    MemWrite = 1'b0;

                    COUNTER = COUNTER + 6'b000001;
                    
                end else if(COUNTER < 6'b000111) begin
                    MDR_W = 1'b1;

                    COUNTER = COUNTER + 6'b000001;
                    
                end else if(COUNTER == 6'b000111) begin
                    StoreCtrl = 2'b11;
                    MemWrite = 1'b1;

                    COUNTER = 6'b000000;
                    state = FETCH;

                  end
		end

              LUI: begin
                if(COUNTER == 6'b000000) begin
                      // zerar todos os sinais que permitem escrita
                      A_W = 1'b0;
                      B_W = 1'b0;
                      MDR_W = 1'b0;
                      RegDiv_W = 1'b0; 
                      ALUOut_W = 1'b0;
                      PCWrite = 1'b0;
                      EPC_W = 1'b0;
                      Hi_W = 1'b0; 
                      Lo_W = 1'b0;
                      MemWrite = 1'b0;
                      RegWrite = 1'b0;
                      IRWrite = 1'b0;
                      
                      ShiftEntCtrl = 2'b00;
                      ShiftShiftCtrl = 2'b10;
                      ShifterCtrl = 3'b001;
  
                     COUNTER = COUNTER + 6'b000001;
                  end
                  else 
                    if(COUNTER == 6'b000001) begin
                      ShifterCtrl = 3'b010;
                      
                      COUNTER = COUNTER + 6'b000001;
                      
                    end else if (COUNTER < 6'b000100) begin
                      ShifterCtrl = 3'b000;

                      COUNTER = COUNTER + 6'b000001;
                      
                    end else if (COUNTER == 6'b000100) begin
                      EntWrite = 3'b001;
                      EntEnd = 2'b00;
                      RegWrite = 1'b1;

                      COUNTER = 6'b000000;
                      state = FETCH;
                    end
                
                end
              RTE: begin
                if(COUNTER == 6'b000000) begin
                    // zerar todos os sinais que permitem escrita
                    A_W = 1'b0;
                    B_W = 1'b0;
                    MDR_W = 1'b0;
                    RegDiv_W = 1'b0; 
                    ALUOut_W = 1'b0;
                    PCWrite = 1'b0;
                    EPC_W = 1'b0;
                    Hi_W = 1'b0; 
                    Lo_W = 1'b0;
                    MemWrite = 1'b0;
                    RegWrite = 1'b0;
                    IRWrite = 1'b0;
                    
                    PCCtrl = 2'b00;
                    PCWrite = 1'b1;
  
                    COUNTER = 6'b000000;
                    state = FETCH;
                  end
		end

              SLT: begin
                if(COUNTER == 6'b000000) begin
                    // zerar todos os sinais que permitem escrita
                    A_W = 1'b0;
                    B_W = 1'b0;
                    MDR_W = 1'b0;
                    RegDiv_W = 1'b0; 
                    ALUOut_W = 1'b0;
                    PCWrite = 1'b0;
                    EPC_W = 1'b0;
                    Hi_W = 1'b0; 
                    Lo_W = 1'b0;
                    MemWrite = 1'b0;
                    RegWrite = 1'b0;
                    IRWrite = 1'b0;
                    
                    ALUSrcA = 2'b10;
                    ALUSrcB = 2'b00;
                    ALUCtrl = 3'b111;
  
                    COUNTER = COUNTER + 6'b000001;
                 end else if (COUNTER == 6'b000001) begin
                    EntEnd = 2'b01;
                    EntWrite = 3'b111;
                    RegWrite = 1'b1;
                  
                    COUNTER = 6'b000000;
                    state = FETCH;
                  end
                end
              SLTI: begin
                if(COUNTER == 6'b000000) begin
                    // zerar todos os sinais que permitem escrita
                    A_W = 1'b0;
                    B_W = 1'b0;
                    MDR_W = 1'b0;
                    RegDiv_W = 1'b0; 
                    ALUOut_W = 1'b0;
                    PCWrite = 1'b0;
                    EPC_W = 1'b0;
                    Hi_W = 1'b0; 
                    Lo_W = 1'b0;
                    MemWrite = 1'b0;
                    RegWrite = 1'b0;
                    IRWrite = 1'b0;
                    
                    ALUSrcA = 2'b10;
                    ALUSrcB = 2'b11;
                    ALUCtrl = 3'b111;
  
                    COUNTER = COUNTER + 6'b000001;
                  end else if (COUNTER == 6'b000001) begin
                    EntEnd = 2'b00;
                    EntWrite = 3'b111;
                    RegWrite = 1'b1;
                  
                    COUNTER = 6'b000000;
                    state = FETCH;
                  end
                end
              MULT: begin
                if(COUNTER == 6'b000000) begin
                    // zerar todos os sinais que permitem escrita
                    A_W = 1'b0;
                    B_W = 1'b0;
                    MDR_W = 1'b0;
                    RegDiv_W = 1'b0; 
                    ALUOut_W = 1'b0;
                    PCWrite = 1'b0;
                    EPC_W = 1'b0;
                    Hi_W = 1'b0; 
                    Lo_W = 1'b0;
                    MemWrite = 1'b0;
                    RegWrite = 1'b0;
                    IRWrite = 1'b0;
                  
                    MultCtrl = 1'b1;
                     
                    COUNTER = COUNTER + 6'b000001;
                    
                end else if(COUNTER <= 6'b100001) begin
                    MultCtrl = 1'b0;
                  
                    COUNTER = COUNTER + 6'b000001;
                    
                  end
                else if (COUNTER == 6'b100010) begin
                  HiCtrl = 1'b1;
                  LoCtrl = 1'b1;
                  Hi_W = 1'b1;
                  Lo_W = 1'b1;
                  
                  COUNTER = 6'b000000;
                  state = FETCH;
                end
              end
            DIV: begin
                if(COUNTER == 6'b000000) begin
                    // zerar todos os sinais que permitem escrita
                    A_W = 1'b0;
                    B_W = 1'b0;
                    MDR_W = 1'b0;
                    RegDiv_W = 1'b0; 
                    ALUOut_W = 1'b0;
                    PCWrite = 1'b0;
                    EPC_W = 1'b0;
                    Hi_W = 1'b0; 
                    Lo_W = 1'b0;
                    MemWrite = 1'b0;
                    RegWrite = 1'b0;
                    IRWrite = 1'b0;

                    DivSrcA = 1'b1;
                    DivSrcB = 1'b0;
                    DivCtrl = 1'b1;
                     
                    COUNTER = COUNTER + 6'b000001;
                    
                end else 
                  if(COUNTER < 6'b000011) begin
                    DivCtrl = 1'b0;

                    if (divzero == 1'b1) begin
                        COUNTER = 6'b000000;
                        state = DIV_ZERO;
                      end
                      
                    COUNTER = COUNTER + 6'b000001;
                    
                  end else
                  if(COUNTER <= 6'b100010) begin
                      
                    COUNTER = COUNTER + 6'b000001;
                    
                  end else 
                    if (COUNTER == 6'b100011) begin
                      if (divzero == 1'b0) begin
                        HiCtrl = 1'b0;
                        LoCtrl = 1'b0;
                        Hi_W = 1'b1;
                        Lo_W = 1'b1;
  
                        COUNTER = 6'b000000;
                        state = FETCH;
                      end
                end
              end
            ADDM: begin
              if(COUNTER <= 6'b000001) begin
                    // zerar todos os sinais que permitem escrita
                    A_W = 1'b0;
                    B_W = 1'b0;
                    MDR_W = 1'b0;
                    RegDiv_W = 1'b0; 
                    ALUOut_W = 1'b0;
                    PCWrite = 1'b0;
                    EPC_W = 1'b0;
                    Hi_W = 1'b0; 
                    Lo_W = 1'b0;
                    MemWrite = 1'b0;
                    RegWrite = 1'b0;
                    IRWrite = 1'b0;

                    ALUSrcA = 2'b10;
                    ALUSrcB = 2'b11;
                    ALUCtrl = 3'b001;
                    ALUOut_W = 1'b1;
                     
                    COUNTER = COUNTER + 6'b000001;
                    
                end else
                  if(COUNTER < 6'b000101) begin
                    MemReadCtrl = 3'b100;
                    MemWrite = 1'b0;

                    COUNTER = COUNTER + 6'b000001;
                end else
                  if(COUNTER <= 6'b000110) begin
                    MDR_W = 1'b1;

                    COUNTER = COUNTER + 6'b000001;
                end else
                  if(COUNTER == 6'b000111) begin
                    ALUSrcA = 2'b01;
                    ALUSrcB = 2'b00;
                    ALUCtrl = 3'b001;
                    ALUOut_W = 1'b1;

                    COUNTER = COUNTER + 6'b000001;
                end else
                  if(COUNTER == 6'b001000) begin
                    EntEnd = 2'b00;
                    EntWrite = 3'b000;
                    RegWrite = 1'b1;

                    COUNTER = 6'b000000;
                    state = FETCH;
                  end
            end
            DIVM: begin
              if(COUNTER <= 6'b000001) begin // ciclos 0 a 1
                    // zerar todos os sinais que permitem escrita
                    A_W = 1'b0;
                    B_W = 1'b0;
                    MDR_W = 1'b0;
                    RegDiv_W = 1'b0; 
                    ALUOut_W = 1'b0;
                    PCWrite = 1'b0;
                    EPC_W = 1'b0;
                    Hi_W = 1'b0; 
                    Lo_W = 1'b0;
                    MemWrite = 1'b0;
                    RegWrite = 1'b0;
                    IRWrite = 1'b0;

                    ALUSrcA = 2'b10;
                    ALUCtrl = 3'b000;
                    ALUOut_W = 1'b1;
                     
                    COUNTER = COUNTER + 6'b000001;
                    
                end else
                  if(COUNTER < 6'b000100) begin // ciclos 2 a 3
                    ALUOut_W = 1'b0;
                    MemReadCtrl = 3'b100;
                    MemWrite = 1'b0;

                    COUNTER = COUNTER + 6'b000001;
                end else
                  if(COUNTER < 6'b000110) begin // ciclo 4 a 5
                    MDR_W = 1'b1;

                    COUNTER = COUNTER + 6'b000001;
                end else
                  if(COUNTER < 6'b001000) begin // ciclos 6 a 7
                    MDR_W = 1'b0;
                    
                    RegDiv_W = 1'b1;
                    MemReadCtrl = 3'b101;
                    MemWrite = 1'b0;

                    COUNTER = COUNTER + 6'b000001;
                end else
                  if(COUNTER < 6'b001010) begin // ciclos 8 e 9
                    RegDiv_W = 1'b0;
                    MDR_W = 1'b1;

                  COUNTER = COUNTER + 6'b000001;
                end else
                  if(COUNTER == 6'b001010) begin
                    DivSrcA = 1'b0;
                    DivSrcB = 1'b1;
                    DivCtrl = 1'b1;

                    COUNTER = COUNTER + 6'b000001;
                end else
                  if(COUNTER < 6'b101101) begin
                    DivCtrl = 1'b0;

                    if (divzero == 1'b1) begin
                        COUNTER = 6'b000000;
                        state = DIV_ZERO;
                      end

                    COUNTER = COUNTER + 6'b000001;
                end else
                  if(COUNTER == 6'b101101) begin
                    if (divzero == 1'b1) begin
                        COUNTER = 6'b000000;
                        state = DIV_ZERO;
                      end
                    else 
                    if (divzero == 1'b0) begin
                        HiCtrl = 1'b0;
                        LoCtrl = 1'b0;
                        Hi_W = 1'b1;
                        Lo_W = 1'b1;
  
                        COUNTER = 6'b000000;
                        state = FETCH;
                      end
                  end
            end
            endcase
        end
    end
endmodule