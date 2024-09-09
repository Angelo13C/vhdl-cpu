LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY tb_multiplier IS
END ENTITY tb_multiplier;

ARCHITECTURE behavior OF tb_multiplier IS
    CONSTANT c_OPERAND_BITS : POSITIVE := 4;
    SIGNAL tb_i_number1 : STD_LOGIC_VECTOR(c_OPERAND_BITS - 1 DOWNTO 0);
    SIGNAL tb_i_number2 : STD_LOGIC_VECTOR(c_OPERAND_BITS - 1 DOWNTO 0);
    SIGNAL tb_i_start_operation : STD_LOGIC := '0';
    SIGNAL tb_i_clock : STD_LOGIC := '0';
    SIGNAL tb_i_reset : STD_LOGIC := '1';
    SIGNAL tb_o_result : STD_LOGIC_VECTOR((2 * c_OPERAND_BITS) - 1 DOWNTO 0);
    SIGNAL tb_o_result_is_valid : STD_LOGIC;

    CONSTANT c_CLOCK_PERIOD : TIME := 10 ns;
BEGIN
    tb_i_clock <= NOT tb_i_clock AFTER c_CLOCK_PERIOD;

    uut : ENTITY work.multiplier
        GENERIC MAP(
            g_OPERAND_BITS => c_OPERAND_BITS
        )
        PORT MAP(
            i_number1 => tb_i_number1,
            i_number2 => tb_i_number2,
            i_start_operation => tb_i_start_operation,
            i_clock => tb_i_clock,
            i_reset => tb_i_reset,
            o_result => tb_o_result,
            o_result_is_valid => tb_o_result_is_valid
        );

    PROCESS
        VARIABLE expected_result : STD_LOGIC_VECTOR((2 * c_OPERAND_BITS) - 1 DOWNTO 0);
    BEGIN
        WAIT FOR 2 * c_CLOCK_PERIOD;

        tb_i_reset <= '0';
        -- Test case 1: Multiply 2 * 3
        tb_i_number1 <= "0010"; -- 2
        tb_i_number2 <= "0011"; -- 3
        tb_i_start_operation <= '1';
        WAIT FOR c_CLOCK_PERIOD;
        tb_i_start_operation <= '0';

        -- Wait until the operation completes
        WAIT UNTIL tb_o_result_is_valid = '1';

        -- Calculate expected result
        expected_result := STD_LOGIC_VECTOR(to_unsigned(2 * 3, (2 * c_OPERAND_BITS)));

        -- Check the result
        ASSERT tb_o_result = expected_result
        REPORT "Test failed: 2 * 3 != " & INTEGER'image(to_integer(unsigned(tb_o_result))) SEVERITY FAILURE;

        -- Test case 2: Multiply 7 * 1
        tb_i_number1 <= "0111"; -- 7
        tb_i_number2 <= "0001"; -- 1
        tb_i_start_operation <= '1';
        WAIT FOR 2 * c_CLOCK_PERIOD;
        tb_i_start_operation <= '0';

        WAIT UNTIL tb_o_result_is_valid = '1';

        expected_result := STD_LOGIC_VECTOR(to_unsigned(7 * 1, (2 * c_OPERAND_BITS)));

        ASSERT tb_o_result = expected_result
        REPORT "Test failed: 7 * 1 != " & INTEGER'image(to_integer(unsigned(tb_o_result))) SEVERITY FAILURE;

        -- Test case 3: Multiply 0 * 15
        tb_i_number1 <= "0000"; -- 0
        tb_i_number2 <= "1111"; -- 15
        tb_i_start_operation <= '1';
        WAIT FOR 2 * c_CLOCK_PERIOD;
        tb_i_start_operation <= '0';

        WAIT UNTIL tb_o_result_is_valid = '1';

        expected_result := (OTHERS => '0');

        ASSERT tb_o_result = expected_result
        REPORT "Test failed: 0 * 15 != " & INTEGER'image(to_integer(unsigned(tb_o_result))) SEVERITY FAILURE;

        -- Test case 4: Multiply 15 * 15 (check for overflow)
        tb_i_number1 <= "1111"; -- 15
        tb_i_number2 <= "1111"; -- 15
        tb_i_start_operation <= '1';
        WAIT FOR 2 * c_CLOCK_PERIOD;
        tb_i_start_operation <= '0';

        WAIT UNTIL tb_o_result_is_valid = '1';

        expected_result := STD_LOGIC_VECTOR(to_unsigned(15 * 15, (2 * c_OPERAND_BITS)));

        ASSERT tb_o_result = expected_result
        REPORT "Test failed: 15 * 15 != " & INTEGER'image(to_integer(unsigned(tb_o_result))) SEVERITY FAILURE;

        -- Test case 5: Large bit-width multiplication (for 4-bit set to 2^3 * 2^2)
        tb_i_number1 <= "1000"; -- 8
        tb_i_number2 <= "0100"; -- 4
        tb_i_start_operation <= '1';
        WAIT FOR 2 * c_CLOCK_PERIOD;
        tb_i_start_operation <= '0';

        WAIT UNTIL tb_o_result_is_valid = '1';

        expected_result := STD_LOGIC_VECTOR(to_unsigned(8 * 4, (2 * c_OPERAND_BITS)));

        ASSERT tb_o_result = expected_result
        REPORT "Test failed: 8 * 4 != " & INTEGER'image(to_integer(unsigned(tb_o_result))) SEVERITY FAILURE;

        REPORT "Simulation completed successfully." SEVERITY failure;
    END PROCESS;

END ARCHITECTURE behavior;