LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY rcadder IS
    PORT (
        a : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        b : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        y : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );

END rcadder;

ARCHITECTURE synth OF rcadder IS
BEGIN
    Y <= std_logic_vector(unsigned(a) + unsigned(b));
END synth;