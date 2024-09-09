LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE work.alu_pkg.ALL;

ENTITY tb_alu IS
END ENTITY tb_alu;

ARCHITECTURE behavior OF tb_alu IS
    CONSTANT c_OPERANDS_BITS : POSITIVE := 64;

    SIGNAL tb_number1 : STD_LOGIC_VECTOR(c_OPERANDS_BITS - 1 DOWNTO 0);
    SIGNAL tb_number2 : STD_LOGIC_VECTOR(c_OPERANDS_BITS - 1 DOWNTO 0);
    SIGNAL tb_operation : t_ALU_OPERATION;
    SIGNAL tb_clock : STD_LOGIC := '0';
    SIGNAL tb_reset : STD_LOGIC := '1';
    SIGNAL tb_result : STD_LOGIC_VECTOR(c_OPERANDS_BITS - 1 DOWNTO 0);
    SIGNAL tb_result_is_ready : STD_LOGIC;

    CONSTANT c_CLOCK_PERIOD : TIME := 10 ns;
BEGIN
    tb_clock <= NOT tb_clock AFTER c_CLOCK_PERIOD / 2;

    uut : ENTITY work.alu
        GENERIC MAP(
            g_OPERANDS_BITS => c_OPERANDS_BITS
        )
        PORT MAP(
            i_clock => tb_clock,
            i_reset => tb_reset,

            i_number1 => tb_number1,
            i_number2 => tb_number2,
            i_operation => tb_operation,

            o_result => tb_result,
            o_result_is_ready => tb_result_is_ready
        );

    test_process : PROCESS
    BEGIN
        WAIT FOR c_CLOCK_PERIOD;
        tb_reset <= '0';

        -- Test ADD operation
        tb_number1 <= X"0000000000000001"; -- 1
        tb_number2 <= X"0000000000000002"; -- 2
        tb_operation <= ADD;
        WAIT UNTIL tb_result_is_ready = '1';
        ASSERT tb_result = X"0000000000000003" REPORT "ADD operation failed" SEVERITY FAILURE;

        -- Test SUB operation
        tb_number1 <= X"0000000000000005"; -- 5
        tb_number2 <= X"0000000000000003"; -- 3
        tb_operation <= SUB;

        tb_reset <= '1';
        WAIT FOR c_CLOCK_PERIOD;
        tb_reset <= '0';

        WAIT UNTIL tb_result_is_ready = '1';
        ASSERT tb_result = X"0000000000000002" REPORT "SUB operation failed" SEVERITY FAILURE;

        -- Test MUL operation
        tb_number1 <= X"0000000000000002"; -- 2
        tb_number2 <= X"0000000000000003"; -- 3
        tb_operation <= MUL;

        tb_reset <= '1';
        WAIT FOR c_CLOCK_PERIOD;
        tb_reset <= '0';

        WAIT UNTIL tb_result_is_ready = '1';

        ASSERT tb_result = X"0000000000000006" REPORT "MUL operation failed" SEVERITY FAILURE;

        -- Test DIV operation
        tb_number1 <= X"0000000000000009"; -- 9
        tb_number2 <= X"0000000000000004"; -- 4
        tb_operation <= DIV;

        tb_reset <= '1';
        WAIT FOR c_CLOCK_PERIOD;
        tb_reset <= '0';

        WAIT UNTIL tb_result_is_ready = '1';

        ASSERT tb_result = X"0000000000000002" REPORT "DIV operation failed" SEVERITY FAILURE;

        REPORT "Simulation completed successfully." SEVERITY FAILURE;
    END PROCESS;

END ARCHITECTURE behavior;