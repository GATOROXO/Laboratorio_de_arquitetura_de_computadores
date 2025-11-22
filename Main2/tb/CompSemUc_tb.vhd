LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY CompSemUC_tb IS
END ENTITY;

ARCHITECTURE tb OF CompSemUC_tb IS

    -- DUT
    COMPONENT CompSemUC IS
        PORT (
            clk        : IN STD_LOGIC;
            reset      : IN STD_LOGIC;
            ALUControl : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            Branch     : IN STD_LOGIC;
            MemtoReg   : IN STD_LOGIC;
            ALUSrc     : IN STD_LOGIC;
            RegDst     : IN STD_LOGIC;
            RegWrite   : IN STD_LOGIC;
            Jump       : IN STD_LOGIC;
            MemWrite   : IN STD_LOGIC
        );
    END COMPONENT;

    -- Sinais do testbench
    SIGNAL clk       : STD_LOGIC := '0';         -- começa em baixa
    SIGNAL reset     : STD_LOGIC := '1';

    SIGNAL ALUControl : STD_LOGIC_VECTOR(2 DOWNTO 0) := "000";
    SIGNAL Branch     : STD_LOGIC := '0';
    SIGNAL MemtoReg   : STD_LOGIC := '0';
    SIGNAL ALUSrc     : STD_LOGIC := '0';
    SIGNAL RegDst     : STD_LOGIC := '0';
    SIGNAL RegWrite   : STD_LOGIC := '0';
    SIGNAL Jump       : STD_LOGIC := '0';
    SIGNAL MemWrite   : STD_LOGIC := '0';

    -- clock: 10 ns period
    CONSTANT clk_period : time := 10 ns;         -- tempo do clock

BEGIN

    --------------------------------------------------------------------
    -- Instância do processador Sem unidade de controle (UC)
    --------------------------------------------------------------------
    DUT : CompSemUC
    PORT MAP (
        clk        => clk,
        reset      => reset,
        ALUControl => ALUControl,
        Branch     => Branch,
        MemtoReg   => MemtoReg,
        ALUSrc     => ALUSrc,
        RegDst     => RegDst,
        RegWrite   => RegWrite,
        Jump       => Jump,
        MemWrite   => MemWrite
    );

    --------------------------------------------------------------------
    -- Geração do Clock
    --------------------------------------------------------------------
    clk_process : PROCESS
    BEGIN
        clk <= '0';
        WAIT FOR clk_period/2;
        clk <= '1';
        WAIT FOR clk_period/2;
    END PROCESS;

    --------------------------------------------------------------------
    -- Processo de Esti­mulo
    --------------------------------------------------------------------
    stim_process : PROCESS
    BEGIN
        WAIT FOR clk_period;
        reset      <= '0';
        --------------------------------------------------------------------
        -- Instruçao 0: addi $2,$0,5
        -- HEX: 20020005
        -- Binario: 001000 00000 00010 0000000000000101
        -- Tipo I: op=0x08, rs=0, rt=2, imm=5
        -- Operação: $2 = $0 + 5 = 0 + 5 = 5
        --------------------------------------------------------------------
        ALUControl <= "010";  -- ADD (soma para addi)
        Branch     <= '0';    -- Não é branch
        MemtoReg   <= '0';    -- Resultado vem da ALU
        ALUSrc     <= '1';    -- Usa imediato (não registrador)
        RegDst     <= '0';    -- Destino é rt (campo rt = 2)
        RegWrite   <= '1';    -- Escreve no registrador
        Jump       <= '0';    -- Não é jump
        MemWrite   <= '0';    -- Não escreve na memória
        --------------------------------------------------------------------
        -- Instruçao 1: addi $3,$0,12
        -- HEX: 2003000C
        -- Binario: 001000 00000 00011 0000000000001100
        -- Tipo I: op=0x08, rs=0, rt=3, imm=12
        -- Operação: $3 = $0 + 12 = 0 + 12 = 12
        --------------------------------------------------------------------
        WAIT FOR clk_period;

        reset      <= '0';
        ALUControl <= "010";  -- ADD (soma para addi)
        Branch     <= '0';    -- Não é branch
        MemtoReg   <= '0';    -- Resultado vem da ALU
        ALUSrc     <= '1';    -- Usa imediato (não registrador)
        RegDst     <= '0';    -- Destino é rt (campo rt = 3)
        RegWrite   <= '1';    -- Escreve no registrador
        Jump       <= '0';    -- Não é jump
        MemWrite   <= '0';    -- Não escreve na memória

        WAIT FOR clk_period;

        --------------------------------------------------------------------
        -- Instruçao 2: addi $7,$3,-9
        -- HEX: 2067FFF7
        -- Binario: 001000 00011 00111 1111111111110111
        -- Tipo I: op=0x08, rs=3, rt=7, imm=-9
        -- Operação: $7 = $3 + (-9) =  12 + -9 = 3
        --------------------------------------------------------------------
        reset      <= '0';
        ALUControl <= "010";  -- ADD (soma para addi)
        Branch     <= '0';    -- Não é branch
        MemtoReg   <= '0';    -- Resultado vem da ALU
        ALUSrc     <= '1';    -- Usa imediato (não registrador)
        RegDst     <= '0';    -- Destino é rt (campo rt = 7)
        RegWrite   <= '1';    -- Escreve no registrador
        Jump       <= '0';    -- Não é jump
        MemWrite   <= '0';    -- Não escreve na memória

        WAIT FOR clk_period;

        --------------------------------------------------------------------
        -- Instruçao 3: or $4,$7,$2
        -- HEX: 00e22025
        -- Binario: 000000 00111 00010 00100 00000 100101
        -- Tipo R: op=0x00, rs=7, rt=2, rd=4, shamt=0, funct=37
        -- Operação: $4 = $7 or $2 =  3 or 5 = 7    
        --------------------------------------------------------------------
        reset      <= '0';
        ALUControl <= "001";  -- OR (operação Logica para OR)
        Branch     <= '0';    -- Não é branch
        MemtoReg   <= '0';    -- Resultado vem da ALU
        ALUSrc     <= '0';    -- Usa registrador (não imediato)
        RegDst     <= '1';    -- Destino é rd (campo rd = 4, bit's = 15:11) 
        RegWrite   <= '1';    -- Escreve no registrador
        Jump       <= '0';    -- Não é jump
        MemWrite   <= '0';    -- Não escreve na memória

        WAIT FOR clk_period;
        --------------------------------------------------------------------
        -- Instruçao 4: and $5,$3,$4
        -- HEX: 00642824
        -- Binario: 000000 00011 00100 00101 00000 100100
        -- Tipo R: op=0x00, rs=3, rt=4, rd=5, shamt=0, funct=36
        -- Operação: $5 = $3 or $4 =  12 or 7 = 4
        --------------------------------------------------------------------
        reset      <= '0';
        ALUControl <= "000";  -- and (operação Logica para and)
        Branch     <= '0';    -- Não é branch
        MemtoReg   <= '0';    -- Resultado vem da ALU
        ALUSrc     <= '0';    -- Usa registrador (não imediato)
        RegDst     <= '1';    -- Destino é rd (campo rd = 4, bit's = 15:11) 
        RegWrite   <= '1';    -- Escreve no registrador
        Jump       <= '0';    -- Não é jump
        MemWrite   <= '0';    -- Não escreve na memória

        WAIT FOR clk_period;
        
        --------------------------------------------------------------------
        -- Instruçao 5: add $5,$5,$4
        -- HEX: 00a42820
        -- Binario: 000000 00101 00100 00101 00000 100000
        -- Tipo R: op=0x00, rs=5, rt=4, rd=5, shamt=0, funct=32
        -- Operação: $5 = $5 + $4 = 4 + 3 = 4
        --------------------------------------------------------------------
        reset      <= '0';
        ALUControl <= "010";  -- ADD (soma para add)
        Branch     <= '0';    -- Não é branch
        MemtoReg   <= '0';    -- Resultado vem da ALU
        ALUSrc     <= '0';    -- Usa registrador (não imediato)
        RegDst     <= '1';    -- Destino é rd (campo rd = 5, bit's = 15:11)
        RegWrite   <= '1';    -- Escreve no registrador
        Jump       <= '0';    -- Não é jump
        MemWrite   <= '0';    -- Não escreve na memória

        WAIT FOR clk_period;
        --------------------------------------------------------------------
        -- Instruçao 6: beq $5,$7,label
        -- HEX: 10a7000A
        -- Binario: 000100 00101 00111 0000000000001010
        -- Tipo I: op=0x04, rs=5, rt=7, offset=10
        -- Operação: se ($5 == $7) então PC = PC + 4 + (offset * 4)
        --------------------------------------------------------------------
        
        reset      <= '0';
        ALUControl <= "110";  -- SUB (SUB para o branch)
        Branch     <= '1';    -- É branch
        MemtoReg   <= '0';    -- Resultado vem da ALU
        ALUSrc     <= '1';    -- usa imediato (não registrador)
        RegDst     <= '0';    -- Destino é rd (campo rd = 5, bit's = 15:11)
        RegWrite   <= '0';    -- Não escreve no registrador
        Jump       <= '0';    -- Não é jump
        MemWrite   <= '0';    -- Não escreve na memória

        WAIT FOR clk_period;

        --------------------------------------------------------------------
        -- Instruçao 7: slt $4,$3,$4
        -- HEX: 0064202A
        -- Binario: 000000 00011 00100 00100 00000 101010
        -- Tipo R: op=0x00, rs=3, rt=4, rd=4, shamt=0, funct=42
        -- Operação: se ($3 < $4) então $4 = 1 senão $4 = 0 logo o esperado é $4 = 0
        --------------------------------------------------------------------

        reset      <= '0';
        ALUControl <= "111";  -- SLT (operação SLT)
        Branch     <= '0';    -- Não é branch
        MemtoReg   <= '0';    -- Resultado vem da ALU
        ALUSrc     <= '0';    -- usa registrador (não imeediato)
        RegDst     <= '1';    -- Destino é rd (campo rd = 4, bit's = 15:11)
        RegWrite   <= '1';    -- Escreve no registrador
        Jump       <= '0';    -- Não é jump
        MemWrite   <= '0';    -- Não escreve na memória

        WAIT FOR clk_period;

        --------------------------------------------------------------------
        -- instruçao 8: beq $4,$0,skip
        -- HEX: 10800001
        -- Binario: 000100 00100 00000 0000000000000001
        -- Tipo I: op=0x04, rs=4, rt=0, offset=1
        -- Operação: se ($4 == $0) então PC = PC + 4 + (offset * 4)
        --------------------------------------------------------------------

        reset      <= '0';
        ALUControl <= "110";  -- SUB (SUB para o branch)
        Branch     <= '1';    -- É branch
        MemtoReg   <= '0';    -- Resultado vem da ALU
        ALUSrc     <= '1';    -- usa imediato (não registrador)
        RegDst     <= '0';    -- Dont care para instrução beq
        RegWrite   <= '0';    -- Não escreve no registrador
        Jump       <= '0';    -- Não é jump
        MemWrite   <= '0';    -- Não escreve na memória

        WAIT FOR clk_period;

        --------------------------------------------------------------------
        -- Instruçao 9: addi $5,$0,0 (nao executada por branch)
        -- HEX: 20050000
        -- Binario: 001000 00000 00101 0000000000000000
        -- Tipo I: op=0x08, rs=0, rt=5, imm=0
        -- Operação: $5 = $0 + 0 = 0 + 0 = 0
        --------------------------------------------------------------------

        -- reset      <= '0';
        -- ALUControl <= "010";  -- ADD (soma para addi)
        -- Branch     <= '0';    -- Não é branch
        -- MemtoReg   <= '0';    -- Resultado vem da ALU
        -- ALUSrc     <= '1';    -- Usa imediato (não registrador)
        -- RegDst     <= '0';    -- Destino é rt (campo rt = 7)
        -- RegWrite   <= '1';    -- Escreve no registrador
        -- Jump       <= '0';    -- Não é jump
        -- MemWrite   <= '0';    -- Não escreve na memória

        WAIT FOR clk_period;

        --------------------------------------------------------------------
        -- instrução 10: slt $4,$7,$2 
        -- HEX: 00e2202a
        -- Binario: 000000 00111 00010 00100 00000 101010
        -- Tipo R: op=0x00, rs=7, rt=2, rd=4, shamt=0, funct=42
        -- Operação: se ($7 < $2) então $4 = 1 senão $4 = 0 $4 esperado é $4 = 1.
        --------------------------------------------------------------------

        reset      <= '0';
        ALUControl <= "111";  -- SLT (operação SLT)
        Branch     <= '0';    -- Não é branch
        MemtoReg   <= '0';    -- Resultado vem da ALU
        ALUSrc     <= '0';    -- usa registrador (não imeediato)
        RegDst     <= '1';    -- Destino é rd (campo rd = 4, bit's = 15:11)
        RegWrite   <= '1';    -- Escreve no registrador
        Jump       <= '0';    -- Não é jump
        MemWrite   <= '0';    -- Não escreve na memória
        
        WAIT FOR clk_period;
        --------------------------------------------------------------------
        -- instrução 11: add $7,$4,$5 
        -- HEX: 00853820
        -- Binario: 000000 00100 00101 00111 00000 100000
        -- Tipo R: op=0x00, rs=4, rt=5, rd=7, shamt=0, funct=32
        -- Operação: $7 = $4 + $5 = 0 + 0 = 0
        --------------------------------------------------------------------

        reset      <= '0';
        ALUControl <= "010";  -- ADD (soma para add)
        Branch     <= '0';    -- Não é branch
        MemtoReg   <= '0';    -- Resultado vem da ALU
        ALUSrc     <= '0';    -- Usa registrador (não imediato)
        RegDst     <= '1';    -- Destino é rd (campo rd = 7, bit's = 15:11)
        RegWrite   <= '1';    -- Escreve no registrador
        Jump       <= '0';    -- Não é jump
        MemWrite   <= '0';    -- Não escreve na memória

        WAIT FOR clk_period;
        --------------------------------------------------------------------
        -- Instrução 12: sub $7,$7,$2 (subtração da ula = 110)
        -- HEX: 00e23822
        -- Binario: 000000 00111 00010 00111 00000 100010
        -- Tipo R: op=0x00, rs=7, rt=2, rd=7, shamt=0, funct=34
        -- Operação: $7 = $7 - $2 = 12 +  (-5) =  (em complemento de 2: 0xFFFFFFFB)
        --------------------------------------------------------------------

        reset      <= '0';
        ALUControl <= "110";  -- SUB (subtração para sub)
        Branch     <= '0';    -- Não é branch
        MemtoReg   <= '0';    -- Resultado vem da ALU
        ALUSrc     <= '0';    -- Usa registrador (não imediato)
        RegDst     <= '1';    -- Destino é rd (campo rd = 7, bit's = 15:11)
        RegWrite   <= '1';    -- Escreve no registrador
        Jump       <= '0';    -- Não é jump
        MemWrite   <= '0';    -- Não escreve na memória
        
        WAIT FOR clk_period;
        --------------------------------------------------------------------
        -- Instrução 13: sw $7,68($3) (escrita na memoria)
        -- HEX: ac670044
        -- Binario: 101011 00011 00111 0000000001000100
        -- Tipo I: op=0x2B, rs=3, rt=7, imm=68
        -- Operação: Mem[$3 + 68] = $7
        --------------------------------------------------------------------

        reset      <= '0';
        ALUControl <= "010";  -- ADD (SOMA para calcular endereço(OFFSET + BASE))
        Branch     <= '0';    -- Não é branch
        MemtoReg   <= '0';    -- Resultado vem da ALU
        ALUSrc     <= '1';    -- Usa imediato (não registrador)
        RegDst     <= '0';    -- Destino é conteudo de Rt para rs + offset (campo rt = 7, bit's = 20:16)
        RegWrite   <= '0';    -- Não escreve no registrador
        Jump       <= '0';    -- Não é jump
        MemWrite   <= '1';    -- Escreve na memória

        WAIT FOR clk_period;
        
        --------------------------------------------------------------------
        -- Instrução 14: lw $2,80($0) (leitura da memoria)
        -- HEX: 8c020050
        -- Binario: 100011 00000 00010 0000000001010000
        -- Tipo I: op=0x23, rs=0, rt=2, imm=80
        -- Operação: $2 = Mem[$0 + 80] = $2 = 7.
        --------------------------------------------------------------------

        reset      <= '0';
        ALUControl <= "010";  -- ADD (SOMA para calcular endereço(OFFSET + BASE))
        Branch     <= '0';    -- Não é branch
        MemtoReg   <= '1';    -- Resultado vem da memória 
        ALUSrc     <= '1';    -- Usa imediato (não registrador)
        RegDst     <= '0';    -- Destino é conteudo de OFFSET + BASE para rt (campo rt = 2, bit's = 20:16)
        RegWrite   <= '1';    -- Escreve no registrador
        Jump       <= '0';    -- Não é jump
        MemWrite   <= '0';    -- Não escreve na memória

        WAIT FOR clk_period;

        --------------------------------------------------------------------
        -- Instrução 15: j 0x11 (jump para instrução 17)
        -- HEX: 08000011
        -- Binario: 000010 000000000000000000010001
        -- Tipo J: op=0x02, target=0x11
        -- Operação: PC = (PC[31:28] || target << 2)
        --------------------------------------------------------------------
        
        reset      <= '0';
        ALUControl <= "000";  -- Dont care para instrução jump
        Branch     <= '0';    -- Não é branch
        MemtoReg   <= '0';    -- Dont care para instrução jump 
        ALUSrc     <= '0';    -- Usa imediato (não registrador)
        RegDst     <= '0';    -- Dont care para instrução jump
        RegWrite   <= '0';    -- Não escreve no registrador
        Jump       <= '1';    -- É jump
        MemWrite   <= '0';    -- Dont care para instrução jump

        WAIT FOR clk_period;


        --------------------------------------------------------------------
        -- Instrução 17: sw $2,84($0)(para onde o jal pula.)
        -- HEX: ac020054
        -- Binario: 101011 00000 00010 0000000001010100
        -- Tipo I: op=0x2B, rs=0, rt=2, imm=84
        -- Operação: Mem[$0 + 84] = $2
        --------------------------------------------------------------------
        reset      <= '0';
        ALUControl <= "010";  -- ADD (SOMA para calcular endereço(OFFSET + BASE))
        Branch     <= '0';    -- Não é branch
        MemtoReg   <= '0';    -- Resultado vem da ALU
        ALUSrc     <= '1';    -- Usa imediato (não registrador)
        RegDst     <= '0';    -- Destino é conteudo de Rt para rs + offset (campo rt = 2, bit's = 20:16)
        RegWrite   <= '0';    -- Não escreve no registrador
        Jump       <= '0';    -- Não é jump
        MemWrite   <= '1';    -- Escreve na memória

        WAIT FOR clk_period;

        --------------------------------------------------------------------
        -- Instrução 16: addi $2,$0,1 (não executada por jump)
        -- HEX: 20020001
        -- Binario: 001000 00000 00010 0000000000000001
        -- Tipo I: op=0x08, rs=0, rt=2, imm=1
        -- Operação: $2 = $0 + 1 = 0 + 1 = 1
        --------------------------------------------------------------------
        
        reset      <= '0';
        ALUControl <= "010";  -- ADD (soma para addi)
        Branch     <= '0';    -- Não é branch
        MemtoReg   <= '0';    -- Resultado vem da ALU
        ALUSrc     <= '1';    -- Usa imediato (não registrador)
        RegDst     <= '0';    -- Destino é rt (campo rt = 2)
        RegWrite   <= '1';    -- Escreve no registrador
        Jump       <= '0';    -- Não é jump
        MemWrite   <= '0';    -- Não escreve na memória
        

        WAIT;
        --------------------------------------------------------------------
        -- Fim da simulação
        --------------------------------------------------------------------
    END PROCESS;

END ARCHITECTURE tb;



--| End |      Assembly    |     HEX     |            Binário (32 bits)            | Tip |           Campos           |
--| --- | ---------------- | ----------- | --------------------------------------- | --- | -------------------------- |
--| 0   |  addi $2,$0,5    |  20020005   |  001000 00000 00010 0000000000000101    |  I  | op=0x08, rs=0, rt=2, imm=5 |
--| 4   |  addi $3,$0,12   |  2003000c   |  001000 00000 00011 0000000000001100    |  I  | rs=0, rt=3, imm=12         |
--| 8   |  addi $7,$3,-9   |  2067fff7   |  001000 00011 00111 1111111111110111    |  I  | rs=3, rt=7, imm=-9         |
--| C   |  or $4,$7,$2     |  00e22025   |  000000 00111 00010 00100 00000 100101  |  R  | funct=0x25                 |
--| 10  |  and $5,$3,$4    |  00642824   |  000000 00011 00100 00101 00000 100100  |  R  | funct=0x24                 |
--| 14  |  add $5,$5,$4    |  00a42820   |  000000 00101 00100 00101 00000 100000  |  R  | funct=0x20                 |
--| 18  |  beq $5,$7,label |  10a7000a   |  000100 00101 00111 0000000000001010    |  I  | offset=10                  |
--| 1C  |  slt $4,$3,$4    |  0064202a   |  000000 00011 00100 00100 00000 101010  |  R  | funct=0x2A                 |
--| 20  |  beq $4,$0,skip  |  10800001   |  000100 00100 00000 0000000000000001    |  I  | offset=1                   |
--| 24  |  addi $5,$0,0    |  20050000   |  001000 00000 00101 0000000000000000    |  I  | imm=0                      |
--| 28  |  slt $4,$7,$2    |  00e2202a   |  000000 00111 00010 00100 00000 101010  |  R  | funct=0x2A                 |
--| 2C  |  add $7,$4,$5    |  00853820   |  000000 00100 00101 00111 00000 100000  |  R  | funct=0x20                 |
--| 30  |  sub $7,$7,$2    |  00e23822   |  000000 00111 00010 00111 00000 100010  |  R  | funct=0x22                 |
--| 34  |  sw $7,68($3)    |  ac670044   |  101011 00011 00111 0000000001000100    |  I  | imm=68                     |
--| 38  |  lw $2,80($0)    |  8c020050   |  100011 00000 00010 0000000001010000    |  I  | imm=80                     |
--| 3C  |  j 0x11          |  08000011   |  000010 000000000000000000010001        |  J  | target=0x11                |
--| 40  |  addi $2,$0,1    |  20020001   |  001000 00000 00010 0000000000000001    |  I  | imm=1                      |
--| 44  |  sw $2,84($0)    |  ac020054   |  101011 00000 00010 0000000001010100    |  I  | imm=84                     |

    



