LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

-- extende o sinal a de 16 bits para 32 bits
ENTITY signext IS
    port (
        a : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
        ex : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );

END signext;

ARCHITECTURE synth OF signext IS
BEGIN
    ex <= (X"ffff" & a) WHEN a(15) = '1' ELSE (X"0000" & a); 
END synth;