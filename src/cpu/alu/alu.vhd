PACKAGE alu_pkg IS
    TYPE t_ALU_OPERATION IS (ADD, SUB, MUL, DIV, LSHIFT, RSHIFT);
    TYPE t_STATUS_FLAG IS (ZERO, CARRY, OVERFLOW, DIVISION_BY_ZERO, PARITY);
    CONSTANT c_STATUS_FLAGS_COUNT : NATURAL := 5;
END PACKAGE alu_pkg;

LIBRARY IEEE;
USE IEEE.numeric_std.ALL;
USE IEEE.std_logic_1164.ALL;
USE work.alu_pkg.ALL;
USE work.utils.ALL;

ENTITY alu IS
    GENERIC (
        g_OPERANDS_BITS : POSITIVE RANGE 1 TO 128 := 64
    );
    PORT (
        i_reset : IN STD_LOGIC;
        i_clock : IN STD_LOGIC;

        i_number1 : IN STD_LOGIC_VECTOR(g_OPERANDS_BITS - 1 DOWNTO 0);
        i_number2 : IN STD_LOGIC_VECTOR(g_OPERANDS_BITS - 1 DOWNTO 0);

        i_operation : IN t_ALU_OPERATION;

        o_zero_flag : OUT STD_LOGIC;
        o_carry_flag : OUT STD_LOGIC;
        o_parity_flag : OUT STD_LOGIC;
        o_divide_by_zero_flag : OUT STD_LOGIC;
        o_result : OUT STD_LOGIC_VECTOR(g_OPERANDS_BITS - 1 DOWNTO 0);
        o_result_is_ready : OUT STD_LOGIC
    );
END ENTITY alu;

ARCHITECTURE rtl OF alu IS
    SIGNAL w_subtract_or_add : STD_LOGIC;
    SIGNAL r_adder_subtractor_carry : STD_LOGIC;
    SIGNAL r_adder_subtractor_result : STD_LOGIC_VECTOR(g_OPERANDS_BITS - 1 DOWNTO 0);

    SIGNAL w_multiply : STD_LOGIC;
    SIGNAL w_multiply_start_operation : STD_LOGIC;
    SIGNAL r_multiplier_has_started : STD_LOGIC;
    SIGNAL r_multiplier_has_finished : STD_LOGIC;
    SIGNAL r_multiplier_result : STD_LOGIC_VECTOR((2 * g_OPERANDS_BITS) - 1 DOWNTO 0);

    SIGNAL w_divide : STD_LOGIC;
    SIGNAL w_divider_start_operation : STD_LOGIC;
    SIGNAL r_divider_has_started : STD_LOGIC;
    SIGNAL r_divider_has_finished : STD_LOGIC;
    SIGNAL r_divider_quotient : STD_LOGIC_VECTOR(g_OPERANDS_BITS - 1 DOWNTO 0);
    SIGNAL r_divider_remainder : STD_LOGIC_VECTOR(g_OPERANDS_BITS - 1 DOWNTO 0);
BEGIN
    WITH i_operation SELECT
    w_subtract_or_add <=
    '0' WHEN ADD,
    '1' WHEN SUB,
    'X' WHEN OTHERS;
    WITH i_operation SELECT
    w_multiply <=
    '1' WHEN MUL,
    '0' WHEN OTHERS;
    w_multiply_start_operation <= NOT r_multiplier_has_started AND w_multiply;
    WITH i_operation SELECT
    w_divide <=
    '1' WHEN DIV,
    '0' WHEN OTHERS;
    w_divider_start_operation <= NOT r_divider_has_started AND w_divide;

    adder_subtractor_instance : ENTITY work.adder_subtractor
        GENERIC MAP(
            g_OPERANDS_BITS => g_OPERANDS_BITS
        )
        PORT MAP(
            i_number1 => i_number1,
            i_number2 => i_number2,
            i_subtract => w_subtract_or_add,

            o_result => r_adder_subtractor_result,
            o_carry => r_adder_subtractor_carry
        );
    multiplier_instance : ENTITY work.multiplier
        GENERIC MAP(
            g_OPERANDS_BITS => g_OPERANDS_BITS
        )
        PORT MAP(
            i_reset => i_reset,
            i_clock => i_clock,

            i_number1 => i_number1,
            i_number2 => i_number2,

            i_start_operation => w_multiply_start_operation,

            o_result => r_multiplier_result,
            o_result_is_valid => r_multiplier_has_finished
        );
    divider_instance : ENTITY work.divider
        GENERIC MAP(
            g_OPERANDS_BITS => g_OPERANDS_BITS
        )
        PORT MAP(
            i_reset => i_reset,
            i_clock => i_clock,

            i_dividend => i_number1,
            i_divisor => i_number2,

            i_start_operation => w_divider_start_operation,

            o_quotient => r_divider_quotient,
            o_remainder => r_divider_remainder,
            o_divide_by_zero_error => o_divide_by_zero_flag,
            o_done => r_divider_has_finished
        );

    PROCESS (i_clock)
        PROCEDURE p_UPDATE_PARITY_FLAG(SIGNAL result : IN STD_LOGIC_VECTOR) IS
            VARIABLE v_parity : STD_LOGIC := '0';
        BEGIN
            FOR i IN result'RANGE LOOP
                v_parity := v_parity XOR result(i);
            END LOOP;
            o_parity_flag <= v_parity;
        END PROCEDURE;

        PROCEDURE p_UPDATE_ZERO_FLAG(SIGNAL result : IN STD_LOGIC_VECTOR) IS
        BEGIN
            o_zero_flag <= bool_to_std_logic(are_all_zeroes(r_adder_subtractor_result));
        END PROCEDURE;

        PROCEDURE p_UPDATE_FLAGS(SIGNAL result : IN STD_LOGIC_VECTOR) IS
        BEGIN
            p_UPDATE_ZERO_FLAG(result);
            p_UPDATE_PARITY_FLAG(result);
        END PROCEDURE;
    BEGIN
        IF rising_edge(i_clock) THEN
            IF i_reset = '1' THEN
                o_result_is_ready <= '0';
                r_multiplier_has_started <= '0';
                r_divider_has_started <= '0';
                o_zero_flag <= '0';
                o_carry_flag <= '0';
                o_parity_flag <= '0';
                ELSE
                IF w_multiply_start_operation = '1' THEN
                    r_multiplier_has_started <= '1';
                END IF;

                IF w_divider_start_operation = '1' THEN
                    r_divider_has_started <= '1';
                END IF;

                IF r_multiplier_has_finished = '1' THEN
                    r_multiplier_has_started <= '0';
                    -- `r_multiplier_result` doesn't fit in `o_result`!
                    o_result <= r_multiplier_result(g_OPERANDS_BITS - 1 DOWNTO 0);
                    o_result_is_ready <= '1';

                    p_UPDATE_FLAGS(r_multiplier_result(g_OPERANDS_BITS - 1 DOWNTO 0));
                    ELSIF r_divider_has_finished = '1' THEN
                    r_divider_has_started <= '0';
                    o_result <= r_divider_quotient;
                    -- For now `r_divider_remainder` is ignored. I should have another output port for the remainder.
                    o_result_is_ready <= '1';

                    p_UPDATE_FLAGS(r_divider_quotient);
                    ELSIF w_subtract_or_add = '0' OR w_subtract_or_add = '1' THEN
                    o_result <= r_adder_subtractor_result;
                    o_result_is_ready <= '1';

                    p_UPDATE_FLAGS(r_adder_subtractor_result);
                    IF w_subtract_or_add = '0' THEN
                        o_carry_flag <= r_adder_subtractor_carry;
                        ELSE
                        o_carry_flag <= bool_to_std_logic(unsigned(i_number1) < unsigned(i_number2));
                    END IF;
                    ELSE
                    o_result_is_ready <= '0';
                END IF;
            END IF;
        END IF;
    END PROCESS;
END ARCHITECTURE rtl;