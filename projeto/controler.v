module controler(
  // entradas
  // entradas de fora do processador
  input wire clk, reset,
  
  // instruções
  input wire opcode, func,
  
  // exceções
  input wire overflow, divZero,
  
  // vindas da ALU
  input wire GT, ET,
  
  
  //saídas
  // multiplexadores
  output wire [2:0] MemReadCtrl, 
  output wire [1:0] EntEnd, 
  output wire [2:0] EntWrite, 
  output wire [1:0] AluSrcA, 
  output wire [1:0] AluSrcB,
  output wire [1:0] PCCtrl, 
  output wire [1:0] PCSource, 
  output wire [1:0] ShiftEntCtrl, 
  output wire [1:0] ShiftShiftCtrl,
  output wire LoCtrl, HiCtrl, DivSrcA, DivSrcB,
  
  // registradores
  output wire A_W, B_W, MDR_W, RegDiv_W, AluOut_W
  output wire PCWrite, EPC_W, Hi_W, Lo_W,
  
  //outros componentes
  output wire [2:0] ShifterCtrl,
  output wire [2:0] AluCtrl,
  output wire [1:0] StoreCtrl, 
  output wire [1:0] LoadCtrl,
  output wire MemWrite, RegWrite, IRWrite, DivCtrl, MultCtrl
  );
  
  
    // variáveis 
    reg [5:0] state;
  	reg [5:0] counter;

    //Estados
    parameter RESET = 6'b000000;
    parameter FETCH = 6'b000001;
    parameter DECODE = 6'b000010;
    parameter OP_ERROR = 6'b000011;
    parameter OVERFLOW = 6'b000100;
    parameter DIV_ZERO = 6'b000101;
  
    parameter ADD = 6'b000110;
    parameter AND = 6'b000111;
    parameter DIV = 6'b001000;
    parameter MULT = 6'b001001;
    parameter JR = 6'b001010;
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
    parameter LW = 6'b100010;
    parameter SB = 6'b100011;
    parameter SH = 6'b100100;
    parameter SLTI = 6'b100101;
    parameter SW = 6'b100111;
    parameter J = 6'b101000;
    parameter JAL = 6'b101001;

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
  

    // início da lógica do controle
    always @(posedge clk) begin

          if(reset == 1'b1)begin
              if(state != RESET) begin

                // todas as saídas são setadas para 0
                MemReadCtrl = 3'b000; 
                EntEnd = 2'b00; 
                EntWrite = 3'b000; 
                DivSrcA = 1'b0;
                DivsrcB = 1'b0;
                AluSrcA = 2'b00; 
                AluSrcB = 2'b00; 
                PCCtrl = 2'b00; 
                PCSource = 2'b00; 
                LoCtrl, 
                HiCtrl, 
                ShiftEntCtrl = 2'b00; 
                ShiftShiftCtrl = 2'b00; 
                A_W = 1'b0; 
                B_W = 1'b0;
                MDR_W = 1'b0;
                RegDiv_W = 1'b0;
                AluOut_W = 1'b0;
                PCWrite = 1'b0;
                EPC_W = 1'b0;
                Hi_W = 1'b0;
                Lo_W = 1'b0;
                ShifterCtrl = 3'b000;
                AluCtrl = 3'b000;
                StoreCtrl = 2'b00; 
                LoadCtrl = 2'b00;
                MemWrite = 1'b0;
                RegWrite = 1'b0;
                IRWrite = 1'b0;
                DivCtrl = 1'b0;
                MultCtrl = 1'b0;
                
                // reseta a pilha
                EntEnd = 11;
				EntWrite = 100;
                RegWrite = 1'b1;

                // próximo estado
                counter = 5'b00000;
                state = Fetch;
                
              end
            
          end else begin
            case(state)
              // sempre acontece o fetch (3x) e depois o decode 
               FETCH: begin
               //
                 COUNTER = COUNTER + 5'b00001; // counter é incrementado para indicar que um ciclo se passou
               end
               DECODE: begin
                 if (COUNTER == 5'b00000) begin
               	   //
                 	COUNTER = COUNTER + 5'b00001; 
               		end
                 else if (COUNTER == 5'b00001)
                 // Reinicia o counter
                 COUNTER = 5'b00000;
                 //
                 case(OP)
                   TypeR_OP: begin
                     case (func)
                       // checa todas as possibilidades de func para atribuir o state certo
                     endcase
                 endcase
                 // checa o OP para atribuir o state certo
               end
              
                // checa o states e ativa os sinais necessários em cada ciclo para realizar a instrução
                   
             endcase
        end
    end
