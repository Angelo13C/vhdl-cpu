LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY partial_multiplier IS
    GENERIC (
        g_OPERAND_BITS : POSITIVE RANGE 1 TO 128 := 64
    );
    PORT (
        i_number1 : IN STD_LOGIC_VECTOR(g_OPERAND_BITS - 1 DOWNTO 0);
        i_number2 : IN STD_LOGIC_VECTOR(g_OPERAND_BITS - 1 DOWNTO 0);
        i_shift_count : IN INTEGER;

        o_result : OUT STD_LOGIC_VECTOR((2 * g_OPERAND_BITS) - 1 DOWNTO 0)
    );
END ENTITY partial_multiplier;
ARCHITECTURE rtl OF partial_multiplier IS
BEGIN
    WITH i_shift_count >= 0 AND i_shift_count < g_OPERAND_BITS AND i_number2(i_shift_count) = '1' SELECT
    o_result <=
    STD_LOGIC_VECTOR(shift_left(unsigned(STD_LOGIC_VECTOR(to_unsigned(0, g_OPERAND_BITS)) & i_number1), i_shift_count)) WHEN true,
    (OTHERS => '0') WHEN false;
END ARCHITECTURE;

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE work.utils.ALL;

ENTITY multiplier IS
    GENERIC (
        g_OPERAND_BITS : POSITIVE RANGE 1 TO 128 := 64
    );
    PORT (
        i_clock : IN STD_LOGIC;
        i_reset : IN STD_LOGIC;

        i_number1 : IN STD_LOGIC_VECTOR(g_OPERAND_BITS - 1 DOWNTO 0);
        i_number2 : IN STD_LOGIC_VECTOR(g_OPERAND_BITS - 1 DOWNTO 0);
        i_start_operation : IN STD_LOGIC;

        o_result : OUT STD_LOGIC_VECTOR((2 * g_OPERAND_BITS) - 1 DOWNTO 0);
        o_result_is_valid : OUT STD_LOGIC
    );
END ENTITY multiplier;

ARCHITECTURE rtl OF multiplier IS
    SIGNAL r_multiplicand : STD_LOGIC_VECTOR(g_OPERAND_BITS - 1 DOWNTO 0);
    SIGNAL r_multiplier : STD_LOGIC_VECTOR(g_OPERAND_BITS - 1 DOWNTO 0);
    SIGNAL r_current_bit_count_logic_bits : STD_LOGIC_VECTOR(bits_required_for_vector(g_OPERAND_BITS) DOWNTO 0);
    SIGNAL w_shift_count : INTEGER;
    SIGNAL w_reset_counter : STD_LOGIC;

    SIGNAL r_is_executing_operation : BOOLEAN;
    SIGNAL r_should_output_result : BOOLEAN;
    SIGNAL r_accumulator : STD_LOGIC_VECTOR((2 * g_OPERAND_BITS) - 1 DOWNTO 0);
    SIGNAL r_partial_product : STD_LOGIC_VECTOR((2 * g_OPERAND_BITS) - 1 DOWNTO 0);
    SIGNAL r_result : STD_LOGIC_VECTOR((2 * g_OPERAND_BITS) - 1 DOWNTO 0);
BEGIN
    w_reset_counter <= i_reset OR i_start_operation;
    counter_instance : ENTITY work.counter
        GENERIC MAP(
            g_MAX_VALUE => g_OPERAND_BITS + 1
        )
        PORT MAP(
            i_reset => w_reset_counter,
            i_clock => i_clock,
            o_counter => r_current_bit_count_logic_bits
        );
    w_shift_count <= to_integer(unsigned(r_current_bit_count_logic_bits)) - 1;
    partial_multiplier_instance : ENTITY work.partial_multiplier
        GENERIC MAP(
            g_OPERAND_BITS => g_OPERAND_BITS
        )
        PORT MAP(
            i_number1 => r_multiplicand,
            i_number2 => r_multiplier,
            i_shift_count => w_shift_count,

            o_result => r_partial_product
        );
    ripple_carry_adder_instance : ENTITY work.ripple_carry_adder
        GENERIC MAP(
            g_OPERANDS_BITS => 2 * g_OPERAND_BITS
        )
        PORT MAP(
            i_number1 => r_partial_product,
            i_number2 => r_accumulator,
            i_carry => '0',

            o_sum => r_result
        );

    PROCESS (i_clock)
    BEGIN
        IF rising_edge(i_clock) THEN
            IF i_reset = '1' THEN
                o_result_is_valid <= '0';
                r_accumulator <= (OTHERS => '0');
                r_is_executing_operation <= false;
                r_should_output_result <= false;
                ELSE
                IF i_start_operation = '1' THEN
                    r_multiplicand <= i_number1;
                    r_multiplier <= i_number2;

                    r_should_output_result <= false;
                    o_result_is_valid <= '0';
                    r_accumulator <= (OTHERS => '0');
                    r_is_executing_operation <= true;
                END IF;

                IF r_is_executing_operation THEN
                    r_accumulator <= r_result;

                    IF to_integer(unsigned(r_current_bit_count_logic_bits)) + 1 = g_OPERAND_BITS THEN
                        r_is_executing_operation <= false;
                        r_should_output_result <= true;
                    END IF;
                    ELSIF r_should_output_result THEN
                    r_should_output_result <= false;
                    o_result <= r_result;
                    o_result_is_valid <= '1';
                END IF;
            END IF;
        END IF;
    END PROCESS;
END rtl;