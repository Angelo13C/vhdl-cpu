LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY main_memory IS
    GENERIC (
        g_ADDRESS_WIDTH_IN_BITS : POSITIVE;
        g_DATA_WIDTH_IN_BITS : POSITIVE
    );
    PORT (
        i_clock : IN STD_LOGIC;
        i_reset : IN STD_LOGIC;

        i_address : IN STD_LOGIC_VECTOR(g_ADDRESS_WIDTH_IN_BITS - 1 DOWNTO 0);

        i_data : IN STD_LOGIC_VECTOR(g_DATA_WIDTH_IN_BITS - 1 DOWNTO 0);
        i_data_mask : IN STD_LOGIC_VECTOR(g_DATA_WIDTH_IN_BITS / 8 - 1 DOWNTO 0);
        i_load : IN STD_LOGIC;

        o_data : OUT STD_LOGIC_VECTOR(g_DATA_WIDTH_IN_BITS - 1 DOWNTO 0)
    );
END ENTITY main_memory;

ARCHITECTURE rtl OF main_memory IS
    CONSTANT c_BITS_COUNT_IN_A_BYTE : NATURAL := 8;
    TYPE t_memory_array IS ARRAY (2 ** g_ADDRESS_WIDTH_IN_BITS - 1 DOWNTO 0) OF STD_LOGIC_VECTOR(c_BITS_COUNT_IN_A_BYTE - 1 DOWNTO 0);
    SIGNAL r_memory_buffer : t_memory_array;
BEGIN
    PROCESS (i_clock)
    BEGIN
        IF rising_edge(i_clock) THEN
            IF i_reset = '1' THEN
                r_memory_buffer <= (OTHERS => (OTHERS => '0'));
                o_data <= (OTHERS => '0');
                ELSE
                IF i_load = '1' THEN
                    FOR i IN 0 TO g_DATA_WIDTH_IN_BITS / c_BITS_COUNT_IN_A_BYTE - 1 LOOP
                        IF i_data_mask(i) = '0' THEN
                            r_memory_buffer(to_integer(unsigned(i_address)) + i) <= i_data((i + 1) * c_BITS_COUNT_IN_A_BYTE - 1 DOWNTO i * c_BITS_COUNT_IN_A_BYTE);
                        END IF;
                    END LOOP;
                END IF;

                FOR i IN 0 TO g_DATA_WIDTH_IN_BITS / c_BITS_COUNT_IN_A_BYTE - 1 LOOP
                    o_data((i + 1) * c_BITS_COUNT_IN_A_BYTE - 1 DOWNTO i * c_BITS_COUNT_IN_A_BYTE) <= r_memory_buffer(to_integer(unsigned(i_address)) + i);
                END LOOP;
            END IF;
        END IF;
    END PROCESS;
END ARCHITECTURE rtl;