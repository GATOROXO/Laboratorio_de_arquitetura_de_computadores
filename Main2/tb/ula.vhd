LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY ula IS
    PORT (
        a, b       : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        alucontrol : IN std_logic_vector(2 DOWNTO 0);
        result     : BUFFER std_logic_vector(31 DOWNTO 0);
        zero       : OUT std_logic
    );

END ula;

ARCHITECTURE synth OF ula IS
    SIGNAL aluextended, condinvb, sum: STD_LOGIC_VECTOR(31 DOWNTO 0);
BEGIN
    condinvb <= NOT b WHEN alucontrol(2) = '1' ELSE b;
    aluextended <= x"00000001" WHEN alucontrol(2) = '1' ELSE x"00000000";
    sum <= std_logic_vector(unsigned(a) + unsigned(condinvb) + unsigned(aluextended));

    PROCESS(ALL) BEGIN
        CASE alucontrol(1 DOWNTO 0) IS
            WHEN "00"   => result <= a AND b; 
            WHEN "01"   => result <= a OR b; 
            WHEN "10"   => result <= sum; 
            WHEN "11"   => result <= (0 => sum(31), OTHERS => '0');  -- set less than
            WHEN OTHERS => result <= (OTHERS => 'X'); 
        END CASE;
    END PROCESS;

    zero <= '1' WHEN result = X"00000000" ELSE '0';
    
END synth;