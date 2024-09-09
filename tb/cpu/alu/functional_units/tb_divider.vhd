LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE work.utils.ALL;

ENTITY tb_divider IS
END ENTITY tb_divider;

ARCHITECTURE behavior OF tb_divider IS
    CONSTANT c_OPERAND_BITS : POSITIVE := 8; -- Change this as per the operand size you want to test
    SIGNAL tb_i_dividend : STD_LOGIC_VECTOR(c_OPERAND_BITS - 1 DOWNTO 0);
    SIGNAL tb_i_divisor : STD_LOGIC_VECTOR(c_OPERAND_BITS - 1 DOWNTO 0);
    SIGNAL tb_i_start_operation : STD_LOGIC := '0';
    SIGNAL tb_i_clock : STD_LOGIC := '0';
    SIGNAL tb_i_reset : STD_LOGIC := '1';
    SIGNAL tb_o_quotient : STD_LOGIC_VECTOR(c_OPERAND_BITS - 1 DOWNTO 0);
    SIGNAL tb_o_remainder : STD_LOGIC_VECTOR(c_OPERAND_BITS - 1 DOWNTO 0);
    SIGNAL tb_o_divide_by_zero_error : STD_LOGIC;
    SIGNAL tb_o_result_is_valid : STD_LOGIC;

    CONSTANT c_CLOCK_PERIOD : TIME := 10 ns;
BEGIN
    tb_i_clock <= NOT tb_i_clock AFTER c_CLOCK_PERIOD / 2;

    uut : ENTITY work.divider
        GENERIC MAP(
            g_OPERAND_BITS => c_OPERAND_BITS
        )
        PORT MAP(
            i_dividend => tb_i_dividend,
            i_divisor => tb_i_divisor,
            i_start_operation => tb_i_start_operation,
            i_clock => tb_i_clock,
            i_reset => tb_i_reset,
            o_quotient => tb_o_quotient,
            o_remainder => tb_o_remainder,
            o_divide_by_zero_error => tb_o_divide_by_zero_error,
            o_done => tb_o_result_is_valid
        );

    PROCESS
        VARIABLE expected_quotient : STD_LOGIC_VECTOR(c_OPERAND_BITS - 1 DOWNTO 0);
        VARIABLE expected_remainder : STD_LOGIC_VECTOR(c_OPERAND_BITS - 1 DOWNTO 0);
    BEGIN
        tb_i_reset <= '1';
        WAIT FOR 2 * c_CLOCK_PERIOD;
        tb_i_reset <= '0';

        -- Test case 1: 15 / 3
        tb_i_dividend <= "00001111"; -- 15
        tb_i_divisor <= "00000011"; -- 3
        tb_i_start_operation <= '1';
        WAIT FOR c_CLOCK_PERIOD;
        tb_i_start_operation <= '0';

        WAIT UNTIL tb_o_result_is_valid = '1';

        expected_quotient := STD_LOGIC_VECTOR(to_unsigned(15 / 3, c_OPERAND_BITS));
        expected_remainder := STD_LOGIC_VECTOR(to_unsigned(15 MOD 3, c_OPERAND_BITS));

        ASSERT tb_o_quotient = expected_quotient
        REPORT "Test failed: 15 / 3 quotient != " & INTEGER'image(to_integer(unsigned(tb_o_quotient))) SEVERITY FAILURE;
        ASSERT tb_o_remainder = expected_remainder
        REPORT "Test failed: 15 / 3 remainder != " & INTEGER'image(to_integer(unsigned(tb_o_remainder))) SEVERITY FAILURE;
        ASSERT tb_o_divide_by_zero_error = '0'
        REPORT "Test failed: 15 / 3 has set the divide by zero flag" SEVERITY FAILURE;

        -- Test case 2: 10 / 5
        tb_i_dividend <= "00001010"; -- 10
        tb_i_divisor <= "00000101"; -- 5
        tb_i_start_operation <= '1';
        WAIT FOR c_CLOCK_PERIOD;
        tb_i_start_operation <= '0';

        WAIT UNTIL tb_o_result_is_valid = '1';

        expected_quotient := STD_LOGIC_VECTOR(to_unsigned(10 / 5, c_OPERAND_BITS));
        expected_remainder := STD_LOGIC_VECTOR(to_unsigned(10 MOD 5, c_OPERAND_BITS));

        ASSERT tb_o_quotient = expected_quotient
        REPORT "Test failed: 10 / 5 quotient != " & INTEGER'image(to_integer(unsigned(tb_o_quotient))) SEVERITY FAILURE;
        ASSERT tb_o_remainder = expected_remainder
        REPORT "Test failed: 10 / 5 remainder != " & INTEGER'image(to_integer(unsigned(tb_o_remainder))) SEVERITY FAILURE;
        ASSERT tb_o_divide_by_zero_error = '0'
        REPORT "Test failed: 15 / 3 has set the divide by zero flag" SEVERITY FAILURE;

        -- Test case 3: 7 / 2
        tb_i_dividend <= "00000111"; -- 7
        tb_i_divisor <= "00000010"; -- 2
        tb_i_start_operation <= '1';
        WAIT FOR c_CLOCK_PERIOD;
        tb_i_start_operation <= '0';

        WAIT UNTIL tb_o_result_is_valid = '1';

        expected_quotient := STD_LOGIC_VECTOR(to_unsigned(7 / 2, c_OPERAND_BITS));
        expected_remainder := STD_LOGIC_VECTOR(to_unsigned(7 MOD 2, c_OPERAND_BITS));

        ASSERT tb_o_quotient = expected_quotient
        REPORT "Test failed: 7 / 2 quotient != " & INTEGER'image(to_integer(unsigned(tb_o_quotient))) SEVERITY FAILURE;
        ASSERT tb_o_remainder = expected_remainder
        REPORT "Test failed: 7 / 2 remainder != " & INTEGER'image(to_integer(unsigned(tb_o_remainder))) SEVERITY FAILURE;
        ASSERT tb_o_divide_by_zero_error = '0'
        REPORT "Test failed: 15 / 3 has set the divide by zero flag" SEVERITY FAILURE;

        -- Test case 4: Division by zero (edge case)
        tb_i_dividend <= "00001000"; -- 8
        tb_i_divisor <= "00000000"; -- 0
        tb_i_start_operation <= '1';
        WAIT FOR c_CLOCK_PERIOD;
        tb_i_start_operation <= '0';

        WAIT UNTIL tb_o_result_is_valid = '1';

        ASSERT tb_o_divide_by_zero_error = '1'
        REPORT "Test failed: division by zero has not set the flag" SEVERITY FAILURE;

        REPORT "Simulation completed successfully." SEVERITY FAILURE;
    END PROCESS;
END ARCHITECTURE behavior;