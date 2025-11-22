LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY instruction_mem IS
    PORT (
        A  : IN  std_logic_vector(31 DOWNTO 0);  -- entrada do PC
        RD : OUT std_logic_vector(31 DOWNTO 0)   -- saída da instrução (32 bits)
    );
END instruction_mem;

ARCHITECTURE synth OF instruction_mem IS
    -- Memória ROM com 64 posições de 32 bits
    TYPE rom_type IS ARRAY (0 TO 63) OF std_logic_vector(31 DOWNTO 0);
    
    -- Inicialização direta da ROM com as instruções
    SIGNAL mem : rom_type := (
        0  => x"20020005",  -- addi $2,$0,5
        1  => x"2003000C",  -- addi $3,$0,12
        2  => x"2067FFF7",  -- addi $7,$3,-9
        3  => x"00E22025",  -- or $4,$7,$2
        4  => x"00642824",  -- and $5,$3,$4
        5  => x"00A42820",  -- add $5,$5,$4
        6  => x"10A7000A",  -- beq $5,$7,label
        7  => x"0064202A",  -- slt $4,$3,$4
        8  => x"10800001",  -- beq $4,$0,skip
        9  => x"20050000",  -- addi $5,$0,0
        10 => x"00E2202A",  -- slt $4,$7,$2
        11 => x"00853820",  -- add $7,$4,$5
        12 => x"00E23822",  -- sub $7,$7,$2
        13 => x"AC670044",  -- sw $7,68($3)
        14 => x"8C020050",  -- lw $2,80($0)
        15 => x"08000011",  -- j 0x11
        16 => x"20020001",  -- addi $2,$0,1
        17 => x"AC020054",  -- sw $2,84($0)
        OTHERS => x"00000000"  -- Restante preenchido com NOPs
    );

BEGIN
    -- Leitura assíncrona (ROM)
    RD <= mem(to_integer(unsigned(A(7 DOWNTO 2))));
END synth;