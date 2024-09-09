LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE work.utils.ALL;

ENTITY tb_register_file IS
END ENTITY tb_register_file;

ARCHITECTURE behavior OF tb_register_file IS
    CONSTANT c_CLOCK_PERIOD : TIME := 10 ns;

    SIGNAL tb_clock : STD_LOGIC := '0';
    SIGNAL tb_reset : STD_LOGIC := '1';

    SIGNAL tb_write_enables : STD_LOGIC_VECTOR(1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL tb_write_register_addresses : STD_LOGIC_VECTOR(2 * bits_required_for_vector(16) - 1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL tb_write_data : STD_LOGIC_VECTOR(2 * 64 - 1 DOWNTO 0) := (OTHERS => '0');

    SIGNAL tb_read_register_addresses : STD_LOGIC_VECTOR(2 * bits_required_for_vector(16) - 1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL tb_read_data : STD_LOGIC_VECTOR(2 * 64 - 1 DOWNTO 0);

BEGIN
    tb_clock <= NOT tb_clock AFTER c_CLOCK_PERIOD / 2;

    uut : ENTITY work.register_file
        GENERIC MAP(
            g_REGISTERS_SIZE_IN_BITS => 64,
            g_REGISTERS_COUNT => 16,
            g_READ_PORTS_COUNT => 2,
            g_WRITE_PORTS_COUNT => 2
        )
        PORT MAP(
            i_clock => tb_clock,
            i_reset => tb_reset,

            i_write_enables => tb_write_enables,
            i_write_register_addresses => tb_write_register_addresses,
            i_write_data => tb_write_data,

            i_read_register_addresses => tb_read_register_addresses,
            o_read_data => tb_read_data
        );

    test_process : PROCESS
    BEGIN
        tb_reset <= '1';
        WAIT FOR c_CLOCK_PERIOD;
        tb_reset <= '0';
        WAIT FOR c_CLOCK_PERIOD;

        -- Test 1: Write to register 1 and read from it
        tb_write_enables(0) <= '1';
        tb_write_register_addresses(3 DOWNTO 0) <= "0000"; -- Write to register 1
        tb_write_data(63 DOWNTO 0) <= x"AAAAAAAAAAAAAAAA"; -- Example data
        tb_read_register_addresses(3 DOWNTO 0) <= "0000";

        WAIT FOR c_CLOCK_PERIOD;

        tb_write_enables(0) <= '0';

        WAIT FOR c_CLOCK_PERIOD;

        -- Assert read data
        ASSERT tb_read_data(63 DOWNTO 0) = tb_write_data(63 DOWNTO 0)
        REPORT "Test 1 failed: Register 1 did not return the expected value. " & INTEGER'image(to_integer(unsigned(tb_read_data(63 DOWNTO 0)))) & " != " & INTEGER'image(to_integer(unsigned(tb_write_data(63 DOWNTO 0))))
            SEVERITY FAILURE;

        -- Test 2: Write to register 2 and read from it
        tb_write_enables(1) <= '1';
        tb_write_register_addresses(7 DOWNTO 4) <= "0001"; -- Write to register 2
        tb_write_data(127 DOWNTO 64) <= x"5555555555555555"; -- Example data
        WAIT FOR c_CLOCK_PERIOD;
        tb_write_enables(1) <= '0';
        WAIT FOR c_CLOCK_PERIOD;

        -- Read from register 2
        tb_read_register_addresses(7 DOWNTO 4) <= "0001";
        WAIT FOR c_CLOCK_PERIOD;

        -- Assert read data
        ASSERT tb_read_data(127 DOWNTO 64) = x"5555555555555555"
        REPORT "Test 2 failed: Register 2 did not return the expected value." & INTEGER'image(to_integer(unsigned(tb_read_data(127 DOWNTO 64)))) & " != " & INTEGER'image(to_integer(unsigned(tb_write_data(127 DOWNTO 64))))
            SEVERITY FAILURE;

        -- Test 3: Read from both registers simultaneously
        tb_read_register_addresses <= "0001" & "0000"; -- Read from register 2 and register 1
        WAIT FOR c_CLOCK_PERIOD;

        -- Assert read data
        ASSERT tb_read_data(127 DOWNTO 64) = x"5555555555555555" AND tb_read_data(63 DOWNTO 0) = x"AAAAAAAAAAAAAAAA"
        REPORT "Test 3 failed: Simultaneous read did not return the expected values." & INTEGER'image(to_integer(unsigned(tb_read_data))) & " != " & INTEGER'image(to_integer(unsigned(tb_write_data)))
            SEVERITY FAILURE;

        REPORT "Simulation completed successfully." SEVERITY FAILURE;
    END PROCESS;

END ARCHITECTURE behavior;