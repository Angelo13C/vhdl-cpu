LIBRARY IEEE;
USE IEEE.numeric_std.ALL;
USE IEEE.std_logic_1164.ALL;

ENTITY single_register IS
    GENERIC (
        g_SIZE_IN_BITS : NATURAL := 64
    );
    PORT (
        i_clock : IN STD_LOGIC;
        i_reset : IN STD_LOGIC;

        i_load : IN STD_LOGIC;
        i_store : IN STD_LOGIC;

        i_data : IN STD_LOGIC_VECTOR(g_SIZE_IN_BITS - 1 DOWNTO 0);

        o_data : OUT STD_LOGIC_VECTOR(g_SIZE_IN_BITS - 1 DOWNTO 0)
    );
END ENTITY single_register;

ARCHITECTURE rtl OF single_register IS
    SIGNAL r_data : STD_LOGIC_VECTOR(g_SIZE_IN_BITS - 1 DOWNTO 0);
BEGIN
    PROCESS (i_clock, i_reset)
    BEGIN
        IF i_reset = '1' THEN
            r_data <= STD_LOGIC_VECTOR(to_unsigned(0, g_SIZE_IN_BITS));
            --IF i_store = '1' THEN
            o_data <= (OTHERS => '0');
            --END IF;
            ELSIF rising_edge(i_clock) THEN
            IF i_load = '1' THEN
                r_data <= i_data;
            END IF;

            IF i_store = '1' THEN
                o_data <= r_data;
            END IF;
        END IF;
    END PROCESS;
END ARCHITECTURE rtl;