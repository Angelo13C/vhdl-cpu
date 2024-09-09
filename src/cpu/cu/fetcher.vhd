LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE work.cu_pkg.ALL;

ENTITY fetcher IS
    PORT (
        i_clock : IN STD_LOGIC;
        i_enabled : IN STD_LOGIC;

        i_current_step : IN INTEGER;

        o_control_bus : OUT STD_LOGIC_VECTOR(c_MICRO_INSTRUCTION_COUNT - 1 DOWNTO 0)
    );
END ENTITY fetcher;

ARCHITECTURE rtl OF fetcher IS
BEGIN
    PROCESS (i_clock)
    BEGIN
        IF rising_edge(i_clock) AND i_enabled = '1' THEN
            CASE i_current_step IS
                WHEN 0 => o_control_bus <= convert(PROGRAM_COUNTER_OUT) OR convert(RAM_ADDRESS_IN) OR convert(RAM_ADDRESS_OUT);
                WHEN 1 => o_control_bus <= convert(RAM_DATA_OUT) OR convert(REGISTER_INSTRUCTION_IN);
                WHEN OTHERS => o_control_bus <= (OTHERS => '0');
            END CASE;
        END IF;
    END PROCESS;
END rtl;