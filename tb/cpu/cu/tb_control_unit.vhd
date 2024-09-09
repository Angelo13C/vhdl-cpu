LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE work.utils.ALL;
USE work.cu_pkg.ALL;

ENTITY tb_control_unit IS
END ENTITY tb_control_unit;

ARCHITECTURE behavior OF tb_control_unit IS
    CONSTANT c_CLOCK_PERIOD : TIME := 10 ns;
    CONSTANT c_DATA_BUS_WIDTH : NATURAL := 64;

    SIGNAL tb_instruction_bits : STD_LOGIC_VECTOR(c_INSTRUCTION_MAX_BITS - 1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL tb_reset : STD_LOGIC := '1';
    SIGNAL tb_clock : STD_LOGIC := '0';

    SIGNAL tb_alu_result_is_ready : STD_LOGIC := '0';
    SIGNAL tb_has_finished_instruction : STD_LOGIC;

    SIGNAL tb_register_index_connected_to_alu : STD_LOGIC_VECTOR(c_CU_REGISTER_INDEX_BITS - 1 DOWNTO 0);
    SIGNAL tb_register_index_connected_to_data_bus : STD_LOGIC_VECTOR(c_CU_REGISTER_INDEX_BITS - 1 DOWNTO 0);
    SIGNAL tb_register_index_to_write : STD_LOGIC_VECTOR(c_CU_REGISTER_INDEX_BITS - 1 DOWNTO 0);

    SIGNAL tb_immediate_value_to_data_bus : STD_LOGIC_VECTOR(c_DATA_BUS_WIDTH - 1 DOWNTO 0);

    SIGNAL tb_control_bus : STD_LOGIC_VECTOR(c_MICRO_INSTRUCTION_COUNT - 1 DOWNTO 0);

    SIGNAL tb_first_register : STD_LOGIC_VECTOR(c_CU_REGISTER_INDEX_BITS - 1 DOWNTO 0) := "00001";
    SIGNAL tb_second_register : STD_LOGIC_VECTOR(c_CU_REGISTER_INDEX_BITS - 1 DOWNTO 0) := "00010";
    SIGNAL tb_immediate_value : STD_LOGIC_VECTOR(c_DATA_BUS_WIDTH - 1 DOWNTO 0) := "0000000000000000000000000000000000000000000000000000000000001010"; -- Example immediate value (10)

BEGIN
    tb_clock <= NOT tb_clock AFTER c_CLOCK_PERIOD / 2;

    uut : ENTITY work.control_unit
        GENERIC MAP
        (
            g_DATA_BUS_WIDTH => c_DATA_BUS_WIDTH
        )
        PORT MAP
        (
            i_reset => tb_reset,
            i_clock => tb_clock,
            i_temporary_instruction_bits => tb_instruction_bits,
            i_alu_result_is_ready => tb_alu_result_is_ready,

            o_has_finished_instruction => tb_has_finished_instruction,
            o_register_index_connected_to_alu => tb_register_index_connected_to_alu,
            o_register_index_connected_to_data_bus => tb_register_index_connected_to_data_bus,
            o_register_index_to_write => tb_register_index_to_write,

            o_immediate_value_to_data_bus => tb_immediate_value_to_data_bus,
            o_control_bus => tb_control_bus
        );

    test_process : PROCESS
    BEGIN
        WAIT FOR c_CLOCK_PERIOD;
        tb_reset <= '0';
        WAIT FOR c_CLOCK_PERIOD;

        -- Test 1: NOP Instruction (No operation)
        tb_instruction_bits <= (OTHERS => '0');
        tb_instruction_bits(from_CU_INSTRUCTION(NO_OP)'reverse_range) <= from_CU_INSTRUCTION(NO_OP);
        WAIT FOR 3 * c_CLOCK_PERIOD;
        ASSERT are_all_zeroes(tb_control_bus)
        REPORT "Test 1 failed: NO_OP did not result in expected control signals."
        SEVERITY FAILURE;
        ASSERT tb_has_finished_instruction = '1'
        REPORT "Test 1 failed: NO_OP instruction has not finished properly."
        SEVERITY FAILURE;

        -- Test 2: ADD Instruction (Add two registers)
        tb_instruction_bits <= (64 - 1 DOWNTO 16 => '0') & tb_second_register & tb_first_register & from_CU_INSTRUCTION(ADD);
        WAIT FOR 5 * c_CLOCK_PERIOD;
        ASSERT tb_register_index_connected_to_alu = tb_first_register
        REPORT "Test 2 failed: ADD instruction did not connect the first register to ALU."
        SEVERITY FAILURE;
        ASSERT tb_register_index_connected_to_data_bus = tb_second_register
        REPORT "Test 2 failed: ADD instruction did not connect the second register to the data bus."
        SEVERITY FAILURE;

        WAIT FOR c_CLOCK_PERIOD;

        ASSERT tb_register_index_to_write = tb_first_register
        REPORT "Test 2 failed: ADD instruction did not select the correct register for writing."
        SEVERITY FAILURE;
        ASSERT tb_control_bus = (convert(ALU_OUT) OR convert(GP_REGISTER_TO_WRITE_IN))
        REPORT "Test 2 failed: ADD instruction did not result in expected control signals."
        SEVERITY FAILURE;
        ASSERT tb_has_finished_instruction = '1'
        REPORT "Test 2 failed: ADD instruction has not finished properly."
        SEVERITY FAILURE;

        -- Test 3: MOVE_I Instruction (Move immediate value into register)
        tb_instruction_bits <= tb_immediate_value(54 DOWNTO 0) & tb_first_register & from_CU_INSTRUCTION(MOVE_I);
        WAIT FOR 5 * c_CLOCK_PERIOD;
        ASSERT tb_register_index_to_write = tb_first_register
        REPORT "Test 3 failed: MOVE_I instruction did not select the correct register for writing."
        SEVERITY FAILURE;
        ASSERT tb_immediate_value_to_data_bus = tb_immediate_value
        REPORT "Test 3 failed: MOVE_I instruction did not transfer the immediate value to the data bus."
        SEVERITY FAILURE;
        ASSERT tb_control_bus = convert(GP_REGISTER_TO_WRITE_IN)
        REPORT "Test 3 failed: MOVE_I instruction did not result in expected control signals."
        SEVERITY FAILURE;
        ASSERT tb_has_finished_instruction = '1'
        REPORT "Test 3 failed: MOVE_I instruction has not finished properly."
        SEVERITY FAILURE;

        -- Test 4: SUB Instruction (Subtract two registers)
        tb_instruction_bits <= (64 - 1 DOWNTO 16 => '0') & tb_second_register & tb_first_register & from_CU_INSTRUCTION(SUB);
        WAIT FOR 5 * c_CLOCK_PERIOD;
        ASSERT tb_register_index_connected_to_alu = tb_first_register
        REPORT "Test 4 failed: SUB instruction did not connect the first register to ALU."
        SEVERITY FAILURE;
        ASSERT tb_register_index_connected_to_data_bus = tb_second_register
        REPORT "Test 4 failed: SUB instruction did not connect the second register to the data bus."
        SEVERITY FAILURE;

        WAIT FOR c_CLOCK_PERIOD;

        ASSERT tb_register_index_to_write = tb_first_register
        REPORT "Test 4 failed: SUB instruction did not select the correct register for writing."
        SEVERITY FAILURE;
        ASSERT tb_control_bus = (convert(ALU_OUT) OR convert(GP_REGISTER_TO_WRITE_IN))
        REPORT "Test 4 failed: SUB instruction did not result in expected control signals."
        SEVERITY FAILURE;
        ASSERT tb_has_finished_instruction = '1'
        REPORT "Test 4 failed: SUB instruction has not finished properly."
        SEVERITY FAILURE;

        REPORT "Simulation completed successfully." SEVERITY FAILURE;
        WAIT;
    END PROCESS;

END ARCHITECTURE behavior;