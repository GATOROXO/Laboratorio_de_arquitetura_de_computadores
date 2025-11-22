LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY datapath IS
    PORT (
        -- clock / reset
        CLK        : IN  STD_LOGIC;
        RESET      : IN  STD_LOGIC;

        -- instrução (entrada ao datapath - 26 bits conforme seu projeto)
        Instruct   : IN  STD_LOGIC_VECTOR(25 DOWNTO 0);

        -- sinais de controle (vindos da UC)
        ALUControl : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        PCSrc      : IN STD_LOGIC;                          -- seleciona PCBranch ou PCPlus4
        MemtoReg   : IN STD_LOGIC;                          -- seleciona ALUResult ou ReadData para gravar em reg
        ALUSrc     : IN STD_LOGIC;                          -- seleciona sRD2 ou Signimm para B da ALU
        RegDst     : IN STD_LOGIC;                          -- seleciona rt (20:16) ou rd (15:11) para A3
        RegWrite   : IN STD_LOGIC;                          -- habilita a escrita no registerfile
        Jump       : IN STD_LOGIC;                          -- seleciona entre PCJump e saída do mux PCSrc

        -- entradas/saídas relacionadas às memórias (memórias são externas ao datapath)
        ReadData   : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);     -- dado vindo da Data Memory (load)

        -- saídas do datapath (para Data Memory e Instruction Memory externa)
        PC         : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);     -- endereço de instrução (para instr_mem)
        ALUOut     : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);     -- endereço / resultado (para data_mem)
        WD         : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);     -- write data (para data_mem)
        Zero_0     : OUT STD_LOGIC
    );

END datapath;

ARCHITECTURE behavior OF datapath IS

    -- ========== Component declarations (ajuste caso suas entities tenham nomes/ordens diferentes)
    COMPONENT registerfile IS
        PORT (
            clk : IN  STD_LOGIC;
            we  : IN  STD_LOGIC;
            a1  : IN  STD_LOGIC_VECTOR(4 DOWNTO 0);
            a2  : IN  STD_LOGIC_VECTOR(4 DOWNTO 0);
            a3  : IN  STD_LOGIC_VECTOR(4 DOWNTO 0);
            wd3 : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
            rd1 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            rd2 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT mux2 IS
        GENERIC (t : INTEGER);
        PORT (
            d0 : IN  STD_LOGIC_VECTOR(t-1 DOWNTO 0);
            d1 : IN  STD_LOGIC_VECTOR(t-1 DOWNTO 0);
            s  : IN  STD_LOGIC;
            y  : OUT STD_LOGIC_VECTOR(t-1 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT rcadder IS
        PORT (
            a : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
            b : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
            y : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT register1 IS
        GENERIC (n : INTEGER);
        PORT (
            clk, reset   : IN  STD_LOGIC;
            d            : IN  STD_LOGIC_VECTOR(n-1 DOWNTO 0);
            q            : OUT STD_LOGIC_VECTOR(n-1 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT ula IS
        PORT (
            a, b       : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
            alucontrol : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
            result     : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            zero       : OUT STD_LOGIC
        );
    END COMPONENT;

    COMPONENT signext IS
        PORT (
            a  : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
            ex : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT sl2 IS
        GENERIC (n : INTEGER);
        PORT (
            a : IN  STD_LOGIC_VECTOR(n-1 DOWNTO 0);
            y : OUT STD_LOGIC_VECTOR(n-1 DOWNTO 0)
        );
    END COMPONENT;

    -- SINAIS INTERNOS DO DATAPAHT
    
    -- banco de registradores
    SIGNAL sA3         : STD_LOGIC_VECTOR(4 DOWNTO 0);    -- endereço de escrita após mux RegDst
    SIGNAL sWD3        : STD_LOGIC_VECTOR(31 DOWNTO 0);   -- dado de escrita para regfile (RESULTED)
    SIGNAL sRD1        : STD_LOGIC_VECTOR(31 DOWNTO 0);   -- leitura regfile rs -> SrcA
    SIGNAL sRD2        : STD_LOGIC_VECTOR(31 DOWNTO 0);   -- leitura regfile rt -> WD / mux SrcB

    -- ALU / ALU result
    signal sPCSrc      : STD_LOGIC;
    SIGNAL sALUResult  : STD_LOGIC_VECTOR(31 DOWNTO 0);

    -- sinais do immediate extend/shift
    SIGNAL Signimm     : STD_LOGIC_VECTOR(31 DOWNTO 0); -- saída do signext (extende 16->32)
    SIGNAL shiftlY     : STD_LOGIC_VECTOR(31 DOWNTO 0); -- signimm << 2 (para branch) saída do shiftBranch
    signal shiftlA     : STD_LOGIC_vector(27 downto 0);  -- instruct[25:0] << 2 (para jump, 28 LSB úteis) saida do shiftJump

    -- PC, PC+4 e branch
    SIGNAL pc_reg      : STD_LOGIC_VECTOR(31 DOWNTO 0); -- registrador interno do PC
    SIGNAL PCPlus4     : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL PCBranch    : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL PCMuxOut    : STD_LOGIC_VECTOR(31 DOWNTO 0); -- saída do mux entre PCPlus4 e PCBranch

    -- sinais dos muxes
    SIGNAL mux_alu_b_out  : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL mux_result_out : STD_LOGIC_VECTOR(31 DOWNTO 0);

    -- PCJump (concatenação PCs[31:28] & shiftlA(27:0))
    SIGNAL PCJump       : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL PCMuxJumpOut : STD_LOGIC_VECTOR(31 DOWNTO 0);



BEGIN

    -- Saídas externas
    ------------------------------------------------------------------------------
    PC     <= pc_reg;          -- PC (32 bits) para a Instruction Memory externa
    ALUOut <= sALUResult;      -- ALU result para Data Memory externa (endereço)
    WD     <= sRD2;            -- Write Data para Data Memory externa (RD2)
    ------------------------------------------------------------------------------

    ------------------------------------------------------------------------------
    -- PCJump: concatena os 4 MSBs do PCBranch com os 28 LSBs do shiftlA
    -- (PCBranch(31 downto 28) & shiftlA(27 downto 0))
    ------------------------------------------------------------------------------

    PCJump <= PCPlus4(31 DOWNTO 28) & shiftlA(27 DOWNTO 0);

    ------------------------------------------------------------------------------
    -- Banco de Registradores
    -- a1 = Instruct(25:21) = rs
    -- a2 = Instruct(20:16) = rt
    -- a3 = sA3 (após MUX RegDst)
    -- wd3 = resultado selecionado (após MUX MemtoReg)
    ------------------------------------------------------------------------------

    RF_inst : registerfile
    PORT MAP (
        clk => CLK,
        we  => RegWrite,
        a1  => Instruct(25 DOWNTO 21),
        a2  => Instruct(20 DOWNTO 16),
        a3  => sA3,
        wd3 => sWD3,
        rd1 => sRD1,
        rd2 => sRD2
    );

    ------------------------------------------------------------------------------
    -- MUX RegDst (5 bits): escolhe entre rt (20:16) e rd (15:11)
    -- saída -> sA3
    ------------------------------------------------------------------------------

    mux_regdst : mux2
    GENERIC MAP(t => 5)
    PORT MAP (
        d0 => Instruct(20 DOWNTO 16),  -- rt
        d1 => Instruct(15 DOWNTO 11),  -- rd
        s  => RegDst,
        y  => sA3
    );

    ------------------------------------------------------------------------------
    -- Sign extend (16 -> 32)
    -- input: Instruct(15:0)
    ------------------------------------------------------------------------------

    extend_inst : signext
    PORT MAP (
        a  => Instruct(15 DOWNTO 0),
        ex => Signimm
    );

    ------------------------------------------------------------------------------
    -- sl2 para imediato estendido (Signimm << 2) -> shiftlY
    -- (para cálculo do branch target = PCPlus4 + (Signimm << 2))
    ------------------------------------------------------------------------------

    sl2_imm : sl2
    GENERIC MAP(n => 32)
    PORT MAP (
        a => Signimm,
        y => shiftlY
    );

    ------------------------------------------------------------------------------
    -- sl2 para campo jump (instr[25:0] + "00" -> extend|shift -> shiftlA)
    -- a entrada tem n = 26
    ------------------------------------------------------------------------------

    sl2_jump : sl2
    GENERIC MAP(n => 28)
    PORT MAP (
        a => "00" & Instruct,  -- aumenta 2 bits
        y => shiftlA
    );

    ------------------------------------------------------------------------------
    -- ALU: a = sRD1, b = mux_alu_b_out, result -> sALUResult
    ------------------------------------------------------------------------------

    ALU_inst : ula
    PORT MAP (
        a          => sRD1,
        b          => mux_alu_b_out,
        alucontrol => ALUControl,
        result     => sALUResult,
        zero       => Zero_0
    );

    ------------------------------------------------------------------------------
    -- MUX ALUSrc (32 bits): escolhe entre RD2 e Signimm
    -- saída -> mux_alu_b_out (para ALU b)
    ------------------------------------------------------------------------------

    mux_alusrc : mux2
    GENERIC MAP(t => 32)
    PORT MAP (
        d0 => sRD2,
        d1 => Signimm,
        s  => ALUSrc,
        y  => mux_alu_b_out
    );

    ------------------------------------------------------------------------------
    -- RCA PC+4 (pc_reg + 4)
    ------------------------------------------------------------------------------

    pc_plus4_adder : rcadder
    PORT MAP (
        a => pc_reg,
        b => x"00000004",
        y => PCPlus4
    );

    ------------------------------------------------------------------------------
    -- RCA Branch (PCPlus4 + shiftlY) -> PCBranch
    ------------------------------------------------------------------------------

    branch_adder : rcadder
    PORT MAP (
        a => PCPlus4,
        b => shiftlY,
        y => PCBranch
    );

    ------------------------------------------------------------------------------
    -- MUX PCSrc (32 bits): escolhe entre PCPlus4 e PCBranch
    -- saída -> PCMuxOut
    ------------------------------------------------------------------------------

    mux_pc_src : mux2
    GENERIC MAP(t => 32)
    PORT MAP (
        d0 => PCPlus4,
        d1 => PCBranch,
        s  => PCSrc,
        y  => PCMuxOut
    );

    ------------------------------------------------------------------------------
    -- MUX Jump: seleciona entre PCMuxOut e PCJump
    ------------------------------------------------------------------------------

    mux_pc_jump : mux2
    GENERIC MAP(t => 32)
    PORT MAP (
        d0 => PCMuxOut,   -- caminho normal (PC+4 ou branch)
        d1 => PCJump,     -- caminho de jump
        s  => Jump,       -- controle Jump
        y  => PCMuxJumpOut
    );

    ------------------------------------------------------------------------------
    -- Registrador do PC
    ------------------------------------------------------------------------------

    pc_register : register1
    GENERIC MAP(n => 32)
    PORT MAP (
        clk   => CLK,
        reset => RESET,
        d     => PCMuxJumpOut,
        q     => pc_reg
    );

    -- MUX MemtoReg (32 bits): seleciona entre ALUResult e ReadData
    -- saída -> sWD3 (dado que será gravado no banco de registradores)

    mux_memtoreg : mux2
    GENERIC MAP(t => 32)
    PORT MAP (
        d0 => sALUResult,
        d1 => ReadData, --RD
        s  => MemtoReg,
        y  => sWD3
    );


END behavior;