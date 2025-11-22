LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY CompSemUC IS
    PORT (
        clk        : IN STD_LOGIC;
        reset      : IN STD_LOGIC;
        ALUControl : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        Branch     : IN STD_LOGIC;
        MemtoReg   : IN STD_LOGIC;                          -- seleciona ALUResult ou ReadData para gravar em reg
        ALUSrc     : IN STD_LOGIC;                          -- seleciona sRD2 ou Signimm para B da ALU
        RegDst     : IN STD_LOGIC;                          -- seleciona rt (20:16) ou rd (15:11) para A3
        RegWrite   : IN STD_LOGIC;                          -- habilita escrita no Register File
        Jump       : IN STD_LOGIC;                          -- seleciona entre PCJump e saída do mux PCSrc
        MemWrite   : IN STD_LOGIC                           -- habilita a escrita no memory data
    ); 

END CompSemUC;

ARCHITECTURE behavior OF CompSemUC IS
    
    -- COMPONENTES
    COMPONENT datapath IS
        PORT (
        -- clock / reset
        CLK      : IN  STD_LOGIC;
        RESET    : IN  STD_LOGIC;

        -- instrução (entrada ao datapath - 26 bits conforme seu projeto)
        Instruct : IN  STD_LOGIC_VECTOR(25 DOWNTO 0);

        -- sinais de controle (vindos da UC)
        ALUControl : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        PCSrc      : IN STD_LOGIC;                          -- seleciona PCBranch ou PCPlus4
        MemtoReg   : IN STD_LOGIC;                          -- seleciona ALUResult ou ReadData para gravar em reg
        ALUSrc     : IN STD_LOGIC;                          -- seleciona sRD2 ou Signimm para B da ALU
        RegDst     : IN STD_LOGIC;                          -- seleciona rt (20:16) ou rd (15:11) para A3
        RegWrite   : IN STD_LOGIC;

        Jump       : IN STD_LOGIC;                          -- seleciona entre PCJump e saída do mux PCSrc

        -- entradas/saídas relacionadas às memórias (memórias são externas ao datapath)
        ReadData   : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);     -- dado vindo da Data Memory (load)

        -- saídas do datapath (para Data Memory e Instruction Memory externa)
        PC         : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);     -- endereço de instrução (para instr_mem)
        ALUOut     : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);     -- endereço / resultado (para data_mem)
        WD         : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);     -- write data (para data_mem)
        Zero_0     : OUT STD_LOGIC
        );
    END COMPONENT;

    COMPONENT instruction_mem IS
        port (
            A  : IN  STD_LOGIC_vector(31 DOWNTO 0);  -- entrada do PC
            RD : BUFFER STD_LOGIC_vector(31 DOWNTO 0)   -- saída da instrução (32 bits)
        );
    END COMPONENT;

    COMPONENT data_mem IS
        PORT (
            CLK, WE : IN STD_LOGIC;
            A, WD   : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            RD      : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
        );
    END COMPONENT;

--sinais que serão utilizados Comp_sem_uc

	SIGNAL sPC_out       : STD_LOGIC_VECTOR(31 DOWNTO 0); -- Fio: Datapath -> Mem. Instrução
    SIGNAL sInstruct 	 : STD_LOGIC_VECTOR(31 DOWNTO 0); -- Fio: Mem. Instrução -> Datapath (32 bits)
    SIGNAL sALUOut       : STD_LOGIC_VECTOR(31 DOWNTO 0); -- Fio: Datapath -> Mem. Dados (Endereço)
    SIGNAL sWD_out       : STD_LOGIC_VECTOR(31 DOWNTO 0); -- Fio: Datapath -> Mem. Dados (Dado Escrita)
    SIGNAL sReadData_in  : STD_LOGIC_VECTOR(31 DOWNTO 0); -- Fio: Mem. Dados -> Datapath (Dado Leitura)
    SIGNAL sZero         : STD_LOGIC;
    SIGNAL sPCSrc        : STD_LOGIC;

BEGIN
    sPCSrc <= Branch AND sZero;

    instruction : instruction_mem
    PORT MAP (
        A => sPC_out,
        RD => sInstruct
    );
    
    memory_dados : data_mem
    PORT MAP (
        CLK => clk, 
        WE => MemWrite, 
        A => sALUOut, 
        WD => sWD_out,
        RD => sReadData_in
    );
	 
	 -- Ele recebe os sinais de controle e se conecta aos SINAIS das memórias
    meu_datapath : datapath
    PORT MAP (
        -- Clock e Reset (direto das portas)
        CLK   => clk,
        RESET => reset,

        -- Sinais de Controle (direto das portas)
        ALUControl => ALUControl,
        PCSrc      => sPCSrc,
        MemtoReg   => MemtoReg,
        ALUSrc     => ALUSrc,
        RegDst     => RegDst,
        RegWrite   => RegWrite,
        Jump       => Jump,

        -- Conexões com as Memórias (usando os SINAIS)
        Instruct   => sInstruct(25 DOWNTO 0),
        ReadData   => sReadData_in,               -- Dado lido da memória de dados
    
        -- Saídas do Datapath (para os SINAIS)
        PC         => sPC_out,       -- Endereço para a memória de instrução
        ALUOut     => sALUOut,       -- Endereço para a memória de dados
        WD         => sWD_out,       -- Dado a ser escrito na memória de dados
        Zero_0     => sZero
    );

    
END behavior;