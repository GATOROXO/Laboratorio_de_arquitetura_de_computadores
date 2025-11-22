LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY mux2 IS
    GENERIC(t : INTEGER);
    PORT (
        d0 : IN std_logic_vector(t-1 DOWNTO 0);
        d1 : IN std_logic_vector(t-1 DOWNTO 0);
        s  : IN std_logic;
        y  : OUT std_logic_vector(t-1 DOWNTO 0)
    );

END mux2;

ARCHITECTURE synth OF mux2 IS
BEGIN
    y <= d1 WHEN s = '1' ELSE d0;
END synth;