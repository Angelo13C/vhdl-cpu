LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY tb_main_memory IS
END ENTITY tb_main_memory;

ARCHITECTURE behavior OF tb_main_memory IS
    -- Constants
    CONSTANT c_CLOCK_PERIOD : TIME := 10 ns;
    CONSTANT c_ADDRESS_WIDTH : POSITIVE := 16;
    CONSTANT c_DATA_WIDTH : POSITIVE := 64;

    -- Testbench signals
    SIGNAL tb_i_clock : STD_LOGIC := '0';
    SIGNAL tb_i_reset : STD_LOGIC := '1';
    SIGNAL tb_i_address : STD_LOGIC_VECTOR(c_ADDRESS_WIDTH - 1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL tb_i_data : STD_LOGIC_VECTOR(c_DATA_WIDTH - 1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL tb_i_data_mask : STD_LOGIC_VECTOR(c_DATA_WIDTH / 8 - 1 DOWNTO 0) := (OTHERS => '1');
    SIGNAL tb_i_load : STD_LOGIC := '0';
    SIGNAL tb_o_data : STD_LOGIC_VECTOR(c_DATA_WIDTH - 1 DOWNTO 0);

BEGIN
    tb_i_clock <= NOT tb_i_clock AFTER c_CLOCK_PERIOD / 2;

    uut : ENTITY work.main_memory
        GENERIC MAP(
            g_ADDRESS_WIDTH_IN_BITS => c_ADDRESS_WIDTH,
            g_DATA_WIDTH_IN_BITS => c_DATA_WIDTH
        )
        PORT MAP(
            i_clock => tb_i_clock,
            i_reset => tb_i_reset,
            i_address => tb_i_address,
            i_data => tb_i_data,
            i_data_mask => tb_i_data_mask,
            i_load => tb_i_load,
            o_data => tb_o_data
        );

    PROCESS
    BEGIN
        tb_i_reset <= '1';
        WAIT FOR 2 * c_CLOCK_PERIOD;
        tb_i_reset <= '0';

        -- Test case 1: Write all bytes to address 0 without masking
        tb_i_address <= (OTHERS => '0');
        tb_i_data <= x"1111111111111111"; -- Data to write
        tb_i_data_mask <= (OTHERS => '0'); -- No mask, all bytes should be written
        tb_i_load <= '1';
        WAIT FOR c_CLOCK_PERIOD;
        tb_i_load <= '0';

        -- Read back and check the data
        WAIT FOR c_CLOCK_PERIOD;
        ASSERT tb_o_data = x"1111111111111111"
        REPORT "Test case 1 failed: Data at address 0 is incorrect." SEVERITY FAILURE;

        -- Test case 2: Write to address 0 with masking (only half the data should be written)
        tb_i_data <= x"2222222222222222"; -- New data
        tb_i_data_mask <= b"00001111"; -- Mask the lower half
        tb_i_load <= '1';
        WAIT FOR c_CLOCK_PERIOD;
        tb_i_load <= '0';

        -- Read back and check the data
        WAIT FOR c_CLOCK_PERIOD;
        ASSERT tb_o_data = x"2222222211111111" -- Expect old lower half and new upper half
        REPORT "Test case 2 failed: Data masking didn't work correctly." SEVERITY FAILURE;

        -- Test case 3: Write and read from a different address
        tb_i_address <= x"0008";
        tb_i_data <= x"3333333333333333";
        tb_i_data_mask <= (OTHERS => '0'); -- No mask, all bytes should be written
        tb_i_load <= '1';
        WAIT FOR c_CLOCK_PERIOD;
        tb_i_load <= '0';

        -- Read back and check the data at address 8
        WAIT FOR c_CLOCK_PERIOD;
        ASSERT tb_o_data = x"3333333333333333"
        REPORT "Test case 3 failed: Data at address 8 is incorrect." SEVERITY FAILURE;

        -- Test case 4: Verify that data at address 0 is unaffected
        tb_i_address <= x"0000";
        WAIT FOR c_CLOCK_PERIOD;
        ASSERT tb_o_data = x"2222222211111111"
        REPORT "Test case 4 failed: Data at address 0 was affected by write to address 8." SEVERITY FAILURE;

        -- Test case 5: Write and read from a different address
        tb_i_address <= x"0004";
        tb_i_data <= x"3333333333333333";
        tb_i_data_mask <= (OTHERS => '0'); -- No mask, all bytes should be written
        tb_i_load <= '1';
        WAIT FOR c_CLOCK_PERIOD;
        tb_i_load <= '0';

        tb_i_address <= x"0000";
        -- Read back and check the data at address 0
        WAIT FOR c_CLOCK_PERIOD;
        ASSERT tb_o_data = x"3333333311111111"
        REPORT "Test case 5 failed: Data at address 0 is incorrect." SEVERITY FAILURE;

        REPORT "Simulation completed successfully." SEVERITY FAILURE;
    END PROCESS;

END ARCHITECTURE behavior;