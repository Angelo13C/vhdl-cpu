LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE work.utils.ALL;
USE work.cu_pkg.ALL;

ENTITY executer IS
    GENERIC (
        g_DATA_BUS_WIDTH : NATURAL
    );
    PORT (
        i_instruction_bits : IN STD_LOGIC_VECTOR(c_INSTRUCTION_MAX_BITS - 1 DOWNTO 0);
        i_instruction : IN t_CU_INSTRUCTION;
        i_current_step : IN INTEGER;

        i_alu_result_is_ready : IN STD_LOGIC;

        i_reset : IN STD_LOGIC;
        i_clock : IN STD_LOGIC;

        o_has_finished_instruction : OUT STD_LOGIC;

        o_register_index_connected_to_alu : OUT STD_LOGIC_VECTOR(c_CU_REGISTER_INDEX_BITS - 1 DOWNTO 0);
        o_register_index_connected_to_data_bus : OUT STD_LOGIC_VECTOR(c_CU_REGISTER_INDEX_BITS - 1 DOWNTO 0);
        o_register_index_to_write : OUT STD_LOGIC_VECTOR(c_CU_REGISTER_INDEX_BITS - 1 DOWNTO 0);
        o_immediate_value_to_data_bus : OUT STD_LOGIC_VECTOR(g_DATA_BUS_WIDTH - 1 DOWNTO 0);

        o_control_bus : OUT STD_LOGIC_VECTOR(c_MICRO_INSTRUCTION_COUNT - 1 DOWNTO 0)
    );
END ENTITY executer;

ARCHITECTURE rtl OF executer IS
BEGIN
    PROCESS (i_clock)
        PROCEDURE p_END_INSTRUCTION IS
        BEGIN
            o_has_finished_instruction <= '1';
        END PROCEDURE;

        IMPURE FUNCTION f_FIRST_REGISTER_IN_16BIT_INSTRUCTION RETURN STD_LOGIC_VECTOR IS
            CONSTANT START : INTEGER := c_CU_16BIT_INSTRUCTION_OPCODE_BITS + c_CU_INSTRUCTION_SIZE_BITS;
        BEGIN
            RETURN i_instruction_bits(c_CU_REGISTER_INDEX_BITS + START - 1 DOWNTO START);
        END FUNCTION;
        IMPURE FUNCTION f_SECOND_REGISTER_IN_16BIT_INSTRUCTION RETURN STD_LOGIC_VECTOR IS
            CONSTANT START : INTEGER := c_CU_REGISTER_INDEX_BITS + c_CU_16BIT_INSTRUCTION_OPCODE_BITS + c_CU_INSTRUCTION_SIZE_BITS;
        BEGIN
            RETURN i_instruction_bits(c_CU_REGISTER_INDEX_BITS + START - 1 DOWNTO START);
        END FUNCTION;
        IMPURE FUNCTION f_FIRST_REGISTER_IN_64BIT_INSTRUCTION RETURN STD_LOGIC_VECTOR IS
            CONSTANT START : INTEGER := c_CU_64BIT_INSTRUCTION_OPCODE_BITS + c_CU_INSTRUCTION_SIZE_BITS;
        BEGIN
            RETURN i_instruction_bits(c_CU_REGISTER_INDEX_BITS + START - 1 DOWNTO START);
        END FUNCTION;

        PROCEDURE p_ASSIGN_VALUE_AND_END_INSTRUCTION IS
        BEGIN
            o_register_index_to_write <= f_FIRST_REGISTER_IN_16BIT_INSTRUCTION;
            o_control_bus <= convert(ALU_OUT) OR convert(GP_REGISTER_TO_WRITE_IN);
            p_END_INSTRUCTION;
        END PROCEDURE;

        PROCEDURE p_ADD_OR_SUB_INSTRUCTION(CONSTANT sub : IN BOOLEAN) IS
            VARIABLE v_sub_control_signal : STD_LOGIC_VECTOR(o_control_bus'RANGE);
        BEGIN
            IF sub THEN
                v_sub_control_signal := convert(ALU_SUBTRACT);
                ELSE
                v_sub_control_signal := (OTHERS => '0');
            END IF;

            CASE i_current_step IS
                WHEN 0 =>
                    o_register_index_connected_to_alu <= f_FIRST_REGISTER_IN_16BIT_INSTRUCTION;
                    o_register_index_connected_to_data_bus <= f_SECOND_REGISTER_IN_16BIT_INSTRUCTION;
                    o_control_bus <= v_sub_control_signal;
                WHEN 1 => p_ASSIGN_VALUE_AND_END_INSTRUCTION;
                WHEN OTHERS => NULL;
            END CASE;
        END PROCEDURE;
    BEGIN
        IF rising_edge(i_clock) THEN
            IF i_reset = '1' THEN
                o_control_bus <= (OTHERS => '0');
                o_has_finished_instruction <= '0';
                o_register_index_connected_to_alu <= (OTHERS => '0');
                o_register_index_connected_to_data_bus <= (OTHERS => '0');
                o_register_index_to_write <= (OTHERS => '0');
                ELSE
                CASE i_instruction IS
                    WHEN NO_OP =>
                        o_control_bus <= (OTHERS => '0');
                        p_END_INSTRUCTION;
                    WHEN ADD => p_ADD_OR_SUB_INSTRUCTION(sub => false);
                    WHEN SUB => p_ADD_OR_SUB_INSTRUCTION(sub => true);
                    WHEN MUL =>
                        o_register_index_connected_to_alu <= f_FIRST_REGISTER_IN_16BIT_INSTRUCTION;
                        o_register_index_connected_to_data_bus <= f_SECOND_REGISTER_IN_16BIT_INSTRUCTION;
                        o_control_bus <= convert(ALU_MULTIPLY);
                        IF i_alu_result_is_ready = '1' THEN
                            p_ASSIGN_VALUE_AND_END_INSTRUCTION;
                        END IF;
                    WHEN MOVE =>
                        o_register_index_to_write <= f_FIRST_REGISTER_IN_16BIT_INSTRUCTION;
                        o_register_index_connected_to_data_bus <= f_SECOND_REGISTER_IN_16BIT_INSTRUCTION;
                        o_control_bus <= convert(GP_REGISTER_CONNECTED_TO_DATA_BUS_OUT) OR convert(GP_REGISTER_TO_WRITE_IN);
                        p_END_INSTRUCTION;
                    WHEN MOVE_I =>
                        o_register_index_to_write <= f_FIRST_REGISTER_IN_64BIT_INSTRUCTION;
                        o_immediate_value_to_data_bus <= (c_CU_INSTRUCTION_SIZE_BITS + c_CU_64BIT_INSTRUCTION_OPCODE_BITS + c_CU_REGISTER_INDEX_BITS - 1 DOWNTO 0 => '0') & i_instruction_bits(64 - 1 DOWNTO c_CU_INSTRUCTION_SIZE_BITS + c_CU_64BIT_INSTRUCTION_OPCODE_BITS + c_CU_REGISTER_INDEX_BITS);
                        o_control_bus <= convert(GP_REGISTER_TO_WRITE_IN) OR convert(IMMEDIATE_VALUE_CONNECTED_TO_DATA_BUS_OUT);
                        p_END_INSTRUCTION;
                    WHEN LOAD =>
                        CASE i_current_step IS
                                --WHEN 0 => o_control_bus <= convert(REGISTER_INSTRUCTION_OUT) OR convert(RAM_ADDRESS_IN);
                                --WHEN 1 => o_control_bus <= convert(RAM_DATA_OUT) OR convert(REGISTER_B_IN);
                                --WHEN 2 => o_control_bus <= convert(ALU_OUT) OR convert(REGISTER_A_IN);
                                --    o_has_finished_instruction <= '1';
                            WHEN OTHERS => NULL;
                        END CASE;
                    WHEN LOAD_I =>
                        -- LOAD_I is different from load immediate in some other architectures I've seen online.
                        CASE i_current_step IS
                            WHEN 0 =>
                                o_immediate_value_to_data_bus <= (c_CU_INSTRUCTION_SIZE_BITS + c_CU_64BIT_INSTRUCTION_OPCODE_BITS + c_CU_REGISTER_INDEX_BITS - 1 DOWNTO 0 => '0') & i_instruction_bits(64 - 1 DOWNTO c_CU_INSTRUCTION_SIZE_BITS + c_CU_64BIT_INSTRUCTION_OPCODE_BITS + c_CU_REGISTER_INDEX_BITS);
                                o_control_bus <= convert(RAM_ADDRESS_IN) OR convert(RAM_ADDRESS_OUT) OR convert(IMMEDIATE_VALUE_CONNECTED_TO_DATA_BUS_OUT);
                            WHEN 1 =>
                                o_register_index_to_write <= f_FIRST_REGISTER_IN_64BIT_INSTRUCTION;
                                o_control_bus <= convert(RAM_ADDRESS_OUT) OR convert(RAM_DATA_OUT) OR convert(GP_REGISTER_TO_WRITE_IN);
                                p_END_INSTRUCTION;
                            WHEN OTHERS => NULL;
                        END CASE;
                    WHEN JUMP =>
                        o_immediate_value_to_data_bus <= (c_CU_INSTRUCTION_SIZE_BITS + c_CU_64BIT_INSTRUCTION_OPCODE_BITS - 1 DOWNTO 0 => '0') & i_instruction_bits(64 - 1 DOWNTO c_CU_INSTRUCTION_SIZE_BITS + c_CU_64BIT_INSTRUCTION_OPCODE_BITS);
                        o_control_bus <= convert(PROGRAM_COUNTER_IN) OR convert(IMMEDIATE_VALUE_CONNECTED_TO_DATA_BUS_OUT);
                        p_END_INSTRUCTION;
                    WHEN OTHERS => NULL;--p_END_INSTRUCTION;
                END CASE;
            END IF;
        END IF;
    END PROCESS;
END rtl;