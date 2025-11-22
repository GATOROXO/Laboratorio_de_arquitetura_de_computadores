LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

-- Registrador genérico de n bits (baseado em flip-flops tipo D)
ENTITY register1 IS
    GENERIC(n : INTEGER); -- define tamanho qualquer
    PORT (
        clk, reset : IN  STD_LOGIC;
        d          : IN  STD_LOGIC_VECTOR(n-1 DOWNTO 0);
        q          : OUT STD_LOGIC_VECTOR(n-1 DOWNTO 0)
    );
END register1;

ARCHITECTURE behavior OF register1 IS
BEGIN
    PROCESS(clk, reset)
    BEGIN
        IF reset = '1' THEN
            q <= (OTHERS => '0'); -- zera todas as saídas
        ELSIF rising_edge(clk) THEN
            q <= d; -- armazena valor de entrada em borda de subida
        END IF;
    END PROCESS;
END behavior;
