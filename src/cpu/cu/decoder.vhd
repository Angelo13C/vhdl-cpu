LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE work.cu_pkg.ALL;

ENTITY decoder IS
    PORT (
        i_clock : IN STD_LOGIC;

        i_enable : IN STD_LOGIC;

        i_instruction : IN STD_LOGIC_VECTOR(c_INSTRUCTION_MAX_BITS - 1 DOWNTO 0);

        o_instruction : OUT t_CU_INSTRUCTION
    );
END ENTITY decoder;

ARCHITECTURE rtl OF decoder IS
BEGIN
    PROCESS (i_clock)
    BEGIN
        IF rising_edge(i_clock) THEN
            IF i_enable = '1' THEN
                o_instruction <= to_CU_INSTRUCTION(i_instruction);
            END IF;
        END IF;
    END PROCESS;
END rtl;