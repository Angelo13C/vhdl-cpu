LIBRARY IEEE;
USE IEEE.numeric_std.ALL;
USE IEEE.std_logic_1164.ALL;
USE work.utils.ALL;

ENTITY counter IS
    GENERIC (
        g_MAX_VALUE : NATURAL
    );
    PORT (
        i_reset : IN STD_LOGIC;
        i_clock : IN STD_LOGIC;
        o_counter : OUT STD_LOGIC_VECTOR(bits_required_for_vector(g_MAX_VALUE) - 1 DOWNTO 0)
    );
END counter;

ARCHITECTURE rtl OF counter IS
    CONSTANT c_COUNTER_WIDTH : NATURAL := bits_required_for_vector(g_MAX_VALUE);
    SIGNAL r_counter : STD_LOGIC_VECTOR(c_COUNTER_WIDTH - 1 DOWNTO 0);
BEGIN
    PROCESS (i_reset, i_clock)
    BEGIN
        IF (i_reset = '1') THEN
            r_counter <= (OTHERS => '0');
            ELSE
            IF (rising_edge(i_clock)) THEN
                IF (unsigned(r_counter) = g_MAX_VALUE) THEN
                    r_counter <= (OTHERS => '0');
                    ELSE
                    r_counter <= STD_LOGIC_VECTOR(unsigned(r_counter) + 1);
                END IF;
            END IF;
        END IF;
    END PROCESS;
    o_counter <= r_counter;
END ARCHITECTURE rtl;