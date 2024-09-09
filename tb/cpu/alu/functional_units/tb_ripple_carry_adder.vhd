LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY tb_ripple_carry_adder IS
END ENTITY tb_ripple_carry_adder;

ARCHITECTURE behavior OF tb_ripple_carry_adder IS
    CONSTANT c_OPERANDS_BITS : POSITIVE := 4;

    SIGNAL tb_i_number1 : STD_LOGIC_VECTOR(c_OPERANDS_BITS - 1 DOWNTO 0);
    SIGNAL tb_i_number2 : STD_LOGIC_VECTOR(c_OPERANDS_BITS - 1 DOWNTO 0);
    SIGNAL tb_i_carry : STD_LOGIC := '0';
    SIGNAL tb_o_sum : STD_LOGIC_VECTOR(c_OPERANDS_BITS - 1 DOWNTO 0);
    SIGNAL tb_o_carry : STD_LOGIC;
BEGIN
    uut : ENTITY work.ripple_carry_adder
        GENERIC MAP(
            g_OPERANDS_BITS => c_OPERANDS_BITS
        )
        PORT MAP(
            i_number1 => tb_i_number1,
            i_number2 => tb_i_number2,
            i_carry => tb_i_carry,
            o_sum => tb_o_sum,
            o_carry => tb_o_carry
        );

    PROCESS
        VARIABLE expected_sum : STD_LOGIC_VECTOR(c_OPERANDS_BITS - 1 DOWNTO 0);
        VARIABLE expected_carry : STD_LOGIC;
    BEGIN
        -- Test case 1: Simple addition without carry-in
        tb_i_number1 <= STD_LOGIC_VECTOR(to_unsigned(1, c_OPERANDS_BITS));
        tb_i_number2 <= STD_LOGIC_VECTOR(to_unsigned(2, c_OPERANDS_BITS));
        tb_i_carry <= '0';
        WAIT FOR 10 ns;

        -- Calculate expected results
        expected_sum := STD_LOGIC_VECTOR(to_unsigned(1 + 2, c_OPERANDS_BITS));
        expected_carry := '0';

        -- Check results
        ASSERT tb_o_sum = expected_sum
        REPORT "Test failed: 1 + 2" SEVERITY FAILURE;
        ASSERT tb_o_carry = expected_carry
        REPORT "Test failed: carry (1 + 2)" SEVERITY FAILURE;

        -- Test case 2: Addition with carry-in
        tb_i_number1 <= STD_LOGIC_VECTOR(to_unsigned(10, c_OPERANDS_BITS));
        tb_i_number2 <= STD_LOGIC_VECTOR(to_unsigned(3, c_OPERANDS_BITS));
        tb_i_carry <= '1';
        WAIT FOR 10 ns;

        -- Calculate expected results
        expected_sum := STD_LOGIC_VECTOR(to_unsigned(10 + 3 + 1, c_OPERANDS_BITS));
        expected_carry := '0';

        -- Check results
        ASSERT tb_o_sum = expected_sum
        REPORT "Test failed: 10 + 3 + carry-in" SEVERITY FAILURE;
        ASSERT tb_o_carry = expected_carry
        REPORT "Test failed: carry (10 + 3 + carry-in)" SEVERITY FAILURE;

        -- Test case 3: Overflow scenario
        tb_i_number1 <= STD_LOGIC_VECTOR(to_unsigned(15, c_OPERANDS_BITS));
        tb_i_number2 <= STD_LOGIC_VECTOR(to_unsigned(1, c_OPERANDS_BITS));
        tb_i_carry <= '1';
        WAIT FOR 10 ns;

        -- Calculate expected results
        expected_sum := STD_LOGIC_VECTOR(to_unsigned(15 + 1 + 1, c_OPERANDS_BITS)(c_OPERANDS_BITS - 1 DOWNTO 0));
        expected_carry := '1';

        -- Check results
        ASSERT tb_o_sum = expected_sum
        REPORT "Test failed: 15 + 1 + carry-in" SEVERITY FAILURE;
        ASSERT tb_o_carry = expected_carry
        REPORT "Test failed: carry (overflow)" SEVERITY FAILURE;

        WAIT;
    END PROCESS;
END ARCHITECTURE behavior;