LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY data_mem IS
    PORT (
        CLK, WE : IN STD_LOGIC;
        A, WD   : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        RD      : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
END data_mem;

ARCHITECTURE behavior OF data_mem IS
    -- Memória de 64 palavras de 32 bits (total 256 bytes)
    TYPE ram_type IS ARRAY (63 DOWNTO 0) OF STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL mem : ram_type := (OTHERS => (OTHERS => '0')); -- inicializa com zero

BEGIN

    -- Escrita síncrona (em borda de subida do clock)
    PROCESS(CLK)
    BEGIN
        IF rising_edge(CLK) THEN
            IF (WE = '1') THEN
                -- ENDereçamento por palavra (A(7 DOWNTO 2) -> ignora os 2 LSBs)
                mem(to_integer(unsigned(A(7 DOWNTO 2)))) <= WD;
            END IF;
        END IF;
    END PROCESS;

    -- Leitura combinacional
    RD <= mem(to_integer(unsigned(A(7 DOWNTO 2))));

END behavior;
