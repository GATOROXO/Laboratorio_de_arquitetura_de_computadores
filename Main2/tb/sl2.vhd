LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

-- Deslocador lógico à esquerda de 2 bits
ENTITY sl2 IS
    GENERIC (n : INTEGER);
    PORT (
        a : IN  STD_LOGIC_VECTOR(n-1 DOWNTO 0);
        y : OUT STD_LOGIC_VECTOR(n-1 DOWNTO 0)
    );
END sl2;

ARCHITECTURE synth OF sl2 IS
BEGIN
    y <= a(n-3 DOWNTO 0) & "00"; -- desloca para a esquerda em 2 bits
END synth;
