library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

ENTITY registerfile IS
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
END registerfile;

ARCHITECTURE synth OF registerfile IS

    TYPE ram_type IS ARRAY (31 DOWNTO 0) OF STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL mem: ram_type;
    
BEGIN
    -- escrita sincronizada na borda de subida do sinal de clock
    PROCESS(clk) BEGIN
        IF rising_edge(clk) THEN
            IF we = '1' THEN 
                mem(to_integer(unsigned(a3))) <= wd3;
            END IF;
        END IF;
    END PROCESS;

    -- leitura combinacional 
    PROCESS(all) BEGIN
        IF (to_integer(unsigned(a1)) = 0) THEN 
            rd1 <= X"00000000"; -- registrador $0 = 0
        ELSE 
            rd1 <= mem(to_integer(unsigned(a1)));
        END IF;
    
        IF (to_integer(unsigned(a2)) = 0) THEN 
            rd2 <= X"00000000";  -- registrador 0 sempre em 0
        ELSE 
            rd2 <= mem(to_integer(unsigned(a2)));
        END IF;
    END PROCESS;
END synth;