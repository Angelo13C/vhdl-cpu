LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE work.utils.ALL;

ENTITY tb_single_register IS
END ENTITY tb_single_register;

ARCHITECTURE behavior OF tb_single_register IS
    CONSTANT c_CLOCK_PERIOD : TIME := 10 ns;

    SIGNAL tb_clock : STD_LOGIC := '0';
    SIGNAL tb_load : STD_LOGIC := '0';
    SIGNAL tb_reset : STD_LOGIC := '0';

    SIGNAL tb_data_in : STD_LOGIC_VECTOR(63 DOWNTO 0) := (OTHERS => '0');
    SIGNAL tb_data_out : STD_LOGIC_VECTOR(63 DOWNTO 0);
BEGIN
    tb_clock <= NOT tb_clock AFTER c_CLOCK_PERIOD / 2;

    uut : ENTITY work.single_register
        GENERIC MAP(
            g_SIZE_IN_BITS => 64
        )
        PORT MAP(
            i_clock => tb_clock,
            i_load => tb_load,
            i_store => '1',
            i_reset => tb_reset,
            i_data => tb_data_in,
            o_data => tb_data_out
        );

    test_process : PROCESS
    BEGIN
        tb_reset <= '1';
        WAIT FOR c_CLOCK_PERIOD;
        tb_reset <= '0';
        WAIT FOR c_CLOCK_PERIOD;

        -- Assert the output should be zero after reset
        ASSERT are_all_zeroes(tb_data_out)
        REPORT "Test failed: Output should be zero after reset."
        SEVERITY FAILURE;

        -- Load first value
        tb_data_in <= x"FFFFFFFFFFFFFFFF"; -- Example value
        tb_load <= '1';
        WAIT FOR c_CLOCK_PERIOD;
        tb_load <= '0';
        WAIT FOR c_CLOCK_PERIOD;

        -- Assert the output should match the input after loading
        ASSERT (tb_data_out = tb_data_in)
        REPORT "Test failed: Output did not match input after load."
        SEVERITY FAILURE;

        -- Load second value
        tb_data_in <= x"1234567890ABCDEF"; -- Example value
        tb_load <= '1';
        WAIT FOR c_CLOCK_PERIOD;
        tb_load <= '0';
        WAIT FOR c_CLOCK_PERIOD;

        -- Assert the output should match the new input after loading
        ASSERT (tb_data_out = tb_data_in)
        REPORT "Test failed: Output did not match input after second load."
        SEVERITY FAILURE;

        -- Apply reset again
        tb_reset <= '1';
        WAIT FOR c_CLOCK_PERIOD;
        tb_reset <= '0';
        WAIT FOR c_CLOCK_PERIOD;

        -- Assert the output should be zero after reset again
        ASSERT are_all_zeroes(tb_data_out)
        REPORT "Test failed: Output should be zero after reset."
        SEVERITY FAILURE;

        -- Final test with a new value
        tb_data_in <= x"A5A5A5A5A5A5A5A5"; -- Example value
        tb_load <= '1';
        WAIT FOR c_CLOCK_PERIOD;
        tb_load <= '0';
        WAIT FOR c_CLOCK_PERIOD;

        -- Assert the output should match the new input
        ASSERT (tb_data_out = tb_data_in)
        REPORT "Test failed: Output did not match input after final load."
        SEVERITY FAILURE;

        REPORT "Simulation completed successfully." SEVERITY FAILURE;
    END PROCESS;

END ARCHITECTURE behavior;