LIBRARY IEEE;
USE IEEE.numeric_std.ALL;
USE IEEE.std_logic_1164.ALL;
USE work.utils.ALL;

ENTITY register_file IS
    GENERIC (
        g_REGISTERS_SIZE_IN_BITS : POSITIVE := 64;
        g_REGISTERS_COUNT : POSITIVE := 16;

        g_READ_PORTS_COUNT : POSITIVE := 2;
        g_WRITE_PORTS_COUNT : POSITIVE := 2
    );
    PORT (
        i_clock : IN STD_LOGIC;
        i_reset : IN STD_LOGIC;

        i_write_enables : IN STD_LOGIC_VECTOR(g_WRITE_PORTS_COUNT - 1 DOWNTO 0);
        i_write_register_addresses : IN STD_LOGIC_VECTOR(g_WRITE_PORTS_COUNT * bits_required_for_vector(g_REGISTERS_COUNT) - 1 DOWNTO 0);
        i_write_data : IN STD_LOGIC_VECTOR(g_WRITE_PORTS_COUNT * g_REGISTERS_SIZE_IN_BITS - 1 DOWNTO 0);

        i_read_register_addresses : IN STD_LOGIC_VECTOR(g_READ_PORTS_COUNT * bits_required_for_vector(g_REGISTERS_COUNT) - 1 DOWNTO 0);
        o_read_data : OUT STD_LOGIC_VECTOR(g_READ_PORTS_COUNT * g_REGISTERS_SIZE_IN_BITS - 1 DOWNTO 0)
    );
END ENTITY register_file;

ARCHITECTURE rtl OF register_file IS
    SIGNAL registers_data : STD_LOGIC_VECTOR(g_REGISTERS_COUNT * g_REGISTERS_SIZE_IN_BITS - 1 DOWNTO 0);
BEGIN
    PROCESS (i_clock)
        VARIABLE j : INTEGER;
    BEGIN
        IF rising_edge(i_clock) THEN
            IF i_reset = '1' THEN
                registers_data <= (OTHERS => '0');
                o_read_data <= (OTHERS => '0');
            ELSE
                FOR i IN 0 TO g_WRITE_PORTS_COUNT - 1 LOOP
                    IF i_write_enables(i) = '1' THEN
                        j := to_integer(unsigned(i_write_register_addresses((i + 1) * bits_required_for_vector(g_REGISTERS_COUNT) - 1 DOWNTO i * bits_required_for_vector(g_REGISTERS_COUNT))));
                        registers_data((j + 1) * g_REGISTERS_SIZE_IN_BITS - 1 DOWNTO j * g_REGISTERS_SIZE_IN_BITS) <= i_write_data((i + 1) * g_REGISTERS_SIZE_IN_BITS - 1 DOWNTO i * g_REGISTERS_SIZE_IN_BITS);
                    END IF;
                END LOOP;

                FOR i IN 0 TO g_READ_PORTS_COUNT - 1 LOOP
                    j := to_integer(unsigned(i_read_register_addresses((i + 1) * bits_required_for_vector(g_REGISTERS_COUNT) - 1 DOWNTO i * bits_required_for_vector(g_REGISTERS_COUNT))));
                    o_read_data((i + 1) * g_REGISTERS_SIZE_IN_BITS - 1 DOWNTO i * g_REGISTERS_SIZE_IN_BITS) <= registers_data((j + 1) * g_REGISTERS_SIZE_IN_BITS - 1 DOWNTO j * g_REGISTERS_SIZE_IN_BITS);
                END LOOP;
            END IF;
        END IF;
    END PROCESS;
END ARCHITECTURE rtl;