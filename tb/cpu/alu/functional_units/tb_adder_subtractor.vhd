LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY tb_adder_subtractor IS
END ENTITY tb_adder_subtractor;

ARCHITECTURE behavior OF tb_adder_subtractor IS
    CONSTANT c_OPERANDS_BITS : POSITIVE := 4;

    SIGNAL tb_i_number1 : STD_LOGIC_VECTOR(c_OPERANDS_BITS - 1 DOWNTO 0);
    SIGNAL tb_i_number2 : STD_LOGIC_VECTOR(c_OPERANDS_BITS - 1 DOWNTO 0);
    SIGNAL tb_i_subtract : STD_LOGIC := '0';
    SIGNAL tb_o_result : STD_LOGIC_VECTOR(c_OPERANDS_BITS - 1 DOWNTO 0);
    SIGNAL tb_o_carry : STD_LOGIC;
BEGIN
    uut : ENTITY work.adder_subtractor
        GENERIC MAP(
            g_OPERANDS_BITS => c_OPERANDS_BITS
        )
        PORT MAP(
            i_number1 => tb_i_number1,
            i_number2 => tb_i_number2,
            i_subtract => tb_i_subtract,
            o_result => tb_o_result,
            o_carry => tb_o_carry
        );

    PROCESS
        VARIABLE expected_result : STD_LOGIC_VECTOR(c_OPERANDS_BITS - 1 DOWNTO 0);
        VARIABLE expected_carry : STD_LOGIC;
    BEGIN
        -- Test case 1: Simple addition
        tb_i_number1 <= "0010"; -- 2
        tb_i_number2 <= "0011"; -- 3
        tb_i_subtract <= '0'; -- Addition
        WAIT FOR 10 ns;

        -- Calculate expected results
        expected_result := STD_LOGIC_VECTOR(to_unsigned(2 + 3, c_OPERANDS_BITS));
        expected_carry := '0';

        -- Check results
        ASSERT tb_o_result = expected_result
        REPORT "Test failed: 0010 + 0011" SEVERITY FAILURE;
        ASSERT tb_o_carry = expected_carry
        REPORT "Test failed: carry in addition" SEVERITY FAILURE;

        -- Test case 2: Simple subtraction without borrow
        tb_i_number1 <= "0100"; -- 4
        tb_i_number2 <= "0011"; -- 3
        tb_i_subtract <= '1'; -- Subtraction
        WAIT FOR 10 ns;

        -- Calculate expected results
        expected_result := STD_LOGIC_VECTOR(to_unsigned(4 - 3, c_OPERANDS_BITS));
        expected_carry := '1'; -- No borrow, so carry should be 1

        -- Check results
        ASSERT tb_o_result = expected_result
        REPORT "Test failed: 0100 - 0011" SEVERITY FAILURE;
        ASSERT tb_o_carry = expected_carry
        REPORT "Test failed: carry in subtraction without borrow" SEVERITY FAILURE;

        -- Test case 3: Subtraction with borrow
        tb_i_number1 <= "0010"; -- 2
        tb_i_number2 <= "0111"; -- 7
        tb_i_subtract <= '1'; -- Subtraction
        WAIT FOR 10 ns;

        -- Calculate expected results
        expected_result := STD_LOGIC_VECTOR(to_unsigned(2 - 7, c_OPERANDS_BITS));
        expected_carry := '0'; -- Borrow occurred, so carry should be 0

        -- Check results
        ASSERT tb_o_result = expected_result
        REPORT "Test failed: 0010 - 0111" SEVERITY FAILURE;
        ASSERT tb_o_carry = expected_carry
        REPORT "Test failed: carry in subtraction with borrow" SEVERITY FAILURE;

        -- Test case 4: Addition with overflow
        tb_i_number1 <= "1111"; -- 15
        tb_i_number2 <= "0001"; -- 1
        tb_i_subtract <= '0'; -- Addition
        WAIT FOR 10 ns;

        -- Calculate expected results
        expected_result := STD_LOGIC_VECTOR(to_unsigned(15 + 1, c_OPERANDS_BITS));
        expected_carry := '1'; -- Overflow results in carry

        -- Check results
        ASSERT tb_o_result = "0000" -- Result should overflow to 0000
        REPORT "Test failed: 1111 + 0001 (overflow)" SEVERITY FAILURE;
        ASSERT tb_o_carry = expected_carry
        REPORT "Test failed: carry in addition with overflow" SEVERITY FAILURE;

        WAIT;
    END PROCESS;
END ARCHITECTURE behavior;