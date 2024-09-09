LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE work.utils.ALL;
USE work.cu_pkg.ALL;

ENTITY control_unit IS
    GENERIC (
        g_DATA_BUS_WIDTH : NATURAL
    );
    PORT (
        i_reset : IN STD_LOGIC;
        i_clock : IN STD_LOGIC;

        i_temporary_instruction_bits : IN STD_LOGIC_VECTOR(c_INSTRUCTION_MAX_BITS - 1 DOWNTO 0);

        i_alu_result_is_ready : IN STD_LOGIC;

        o_has_finished_instruction : OUT STD_LOGIC;

        o_register_index_connected_to_alu : OUT STD_LOGIC_VECTOR(c_CU_REGISTER_INDEX_BITS - 1 DOWNTO 0);
        o_register_index_connected_to_data_bus : OUT STD_LOGIC_VECTOR(c_CU_REGISTER_INDEX_BITS - 1 DOWNTO 0);
        o_register_index_to_write : OUT STD_LOGIC_VECTOR(c_CU_REGISTER_INDEX_BITS - 1 DOWNTO 0);

        o_immediate_value_to_data_bus : OUT STD_LOGIC_VECTOR(g_DATA_BUS_WIDTH - 1 DOWNTO 0);

        o_control_bus : OUT STD_LOGIC_VECTOR(c_MICRO_INSTRUCTION_COUNT - 1 DOWNTO 0)
    );
END ENTITY control_unit;

ARCHITECTURE rtl OF control_unit IS
    SIGNAL r_has_finished_instruction : STD_LOGIC;
    SIGNAL w_can_fetcher_run : STD_LOGIC;

    SIGNAL w_can_executer_run : BOOLEAN;
    SIGNAL w_reset_executer : STD_LOGIC;

    CONSTANT c_DECODER_ENABLE_AT_STEP : NATURAL := 2;
    SIGNAL w_enable_decoder : STD_LOGIC;

    SIGNAL r_instruction_bits : STD_LOGIC_VECTOR(c_INSTRUCTION_MAX_BITS - 1 DOWNTO 0);
    SIGNAL r_instruction : t_CU_INSTRUCTION;
    SIGNAL r_instruction_microstep : INTEGER;

    SIGNAL w_executer_instruction_microstep : INTEGER;
    SIGNAL r_executer_control_bus : STD_LOGIC_VECTOR(c_MICRO_INSTRUCTION_COUNT - 1 DOWNTO 0);
    SIGNAL r_fetcher_control_bus : STD_LOGIC_VECTOR(c_MICRO_INSTRUCTION_COUNT - 1 DOWNTO 0);
    SIGNAL r_executer_immediate_value_to_data_bus : STD_LOGIC_VECTOR(g_DATA_BUS_WIDTH - 1 DOWNTO 0);
BEGIN
    r_instruction_bits <= i_temporary_instruction_bits;

    w_can_fetcher_run <= NOT i_reset;
    fetcher_instance : ENTITY work.fetcher
        PORT MAP(
            i_clock => i_clock,
            i_enabled => w_can_fetcher_run,

            i_current_step => r_instruction_microstep,

            o_control_bus => r_fetcher_control_bus
        );
    w_enable_decoder <= bool_to_std_logic(r_instruction_microstep = c_DECODER_ENABLE_AT_STEP);
    decoder_instance : ENTITY work.decoder
        PORT MAP(
            i_clock => i_clock,

            i_enable => w_enable_decoder,
            i_instruction => r_instruction_bits,

            o_instruction => r_instruction
        );
    w_can_executer_run <= r_instruction_microstep >= (c_DECODER_ENABLE_AT_STEP + 1);
    w_reset_executer <= bool_to_std_logic(i_reset = '1' OR r_has_finished_instruction = '1' OR NOT w_can_executer_run);
    w_executer_instruction_microstep <= (r_instruction_microstep - (c_DECODER_ENABLE_AT_STEP + 1))
    WHEN w_can_executer_run ELSE
    0;

    executer_instance : ENTITY work.executer
        GENERIC MAP
        (
            g_DATA_BUS_WIDTH => g_DATA_BUS_WIDTH
        )
        PORT MAP(
            i_reset => w_reset_executer,
            i_clock => i_clock,

            i_instruction_bits => r_instruction_bits,
            i_instruction => r_instruction,
            i_current_step => w_executer_instruction_microstep,
            i_alu_result_is_ready => i_alu_result_is_ready,

            o_has_finished_instruction => r_has_finished_instruction,

            o_register_index_connected_to_alu => o_register_index_connected_to_alu,
            o_register_index_connected_to_data_bus => o_register_index_connected_to_data_bus,
            o_register_index_to_write => o_register_index_to_write,

            o_immediate_value_to_data_bus => r_executer_immediate_value_to_data_bus,

            o_control_bus => r_executer_control_bus
        );

    o_control_bus <= r_executer_control_bus WHEN (i_reset = '1' OR r_has_finished_instruction = '1' OR w_can_executer_run) ELSE
    convert(PROGRAM_COUNTER_ADDED_IN) OR convert(IMMEDIATE_VALUE_CONNECTED_TO_DATA_BUS_OUT) WHEN w_enable_decoder = '1' ELSE
    r_fetcher_control_bus;

    o_immediate_value_to_data_bus <= r_executer_immediate_value_to_data_bus WHEN (i_reset = '1' OR r_has_finished_instruction = '1' OR w_can_executer_run) ELSE
    STD_LOGIC_VECTOR(to_unsigned((t_CU_INSTRUCTION_SIZE'pos(get_instruction_size(r_instruction_bits)) + 1) * 2, o_immediate_value_to_data_bus'length)) WHEN w_enable_decoder = '1';

    o_has_finished_instruction <= r_has_finished_instruction;

    PROCESS (i_clock)
    BEGIN
        IF rising_edge(i_clock) THEN
            IF i_reset = '1' OR r_has_finished_instruction = '1' THEN
                r_instruction_microstep <= 0;
                ELSE
                r_instruction_microstep <= r_instruction_microstep + 1;
            END IF;
        END IF;
    END PROCESS;
END rtl;