LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE work.utils.ALL;

ENTITY divider IS
    GENERIC (
        g_OPERAND_BITS : NATURAL := 64
    );
    PORT (
        i_clock : IN STD_LOGIC;
        i_reset : IN STD_LOGIC;

        i_dividend : IN STD_LOGIC_VECTOR(g_OPERAND_BITS - 1 DOWNTO 0);
        i_divisor : IN STD_LOGIC_VECTOR(g_OPERAND_BITS - 1 DOWNTO 0);
        i_start_operation : IN STD_LOGIC;

        o_quotient : OUT STD_LOGIC_VECTOR(g_OPERAND_BITS - 1 DOWNTO 0);
        o_remainder : OUT STD_LOGIC_VECTOR(g_OPERAND_BITS - 1 DOWNTO 0);
        o_divide_by_zero_error : OUT STD_LOGIC;
        o_done : OUT STD_LOGIC
    );
END ENTITY divider;

ARCHITECTURE rtl OF divider IS
    SIGNAL r_dividend : UNSIGNED(g_OPERAND_BITS - 1 DOWNTO 0);
    SIGNAL r_divisor : UNSIGNED(g_OPERAND_BITS - 1 DOWNTO 0);
    SIGNAL r_quotient : UNSIGNED(g_OPERAND_BITS - 1 DOWNTO 0);
    SIGNAL r_remainder : UNSIGNED(g_OPERAND_BITS - 1 DOWNTO 0);
    SIGNAL r_done : STD_LOGIC;
    SIGNAL r_is_doing_operation : BOOLEAN;
    SIGNAL r_counter : INTEGER RANGE 0 TO g_OPERAND_BITS;
BEGIN
    PROCESS (i_clock, i_reset)
        VARIABLE v_remainder : UNSIGNED(g_OPERAND_BITS - 1 DOWNTO 0);
    BEGIN
        IF rising_edge(i_clock) THEN
            IF i_reset = '1' THEN
                o_divide_by_zero_error <= '0';
                r_quotient <= (OTHERS => '0');
                v_remainder := (OTHERS => '0');
                r_done <= '0';
                r_counter <= 0;
                r_is_doing_operation <= false;
                ELSE
                IF i_start_operation = '1' THEN
                    r_is_doing_operation <= true;
                    o_divide_by_zero_error <= '0';
                    r_dividend <= UNSIGNED(i_dividend);
                    r_divisor <= UNSIGNED(i_divisor);
                    r_quotient <= (OTHERS => '0');
                    v_remainder := (OTHERS => '0');
                    r_counter <= g_OPERAND_BITS;
                    r_done <= '0';
                    ELSIF r_is_doing_operation THEN
                    IF are_all_zeroes(i_divisor) THEN
                        r_is_doing_operation <= false;
                        o_divide_by_zero_error <= '1';
                        r_done <= '1';
                        ELSIF r_counter > 0 THEN
                        v_remainder := v_remainder(g_OPERAND_BITS - 2 DOWNTO 0) & r_dividend(r_counter - 1);

                        IF v_remainder >= r_divisor THEN
                            v_remainder := v_remainder - r_divisor;
                            r_quotient(r_counter - 1) <= '1';
                        END IF;

                        r_counter <= r_counter - 1;
                        ELSE
                        r_is_doing_operation <= false;
                        r_done <= '1';
                        r_remainder <= v_remainder;
                    END IF;
                END IF;
            END IF;
        END IF;
    END PROCESS;

    o_quotient <= STD_LOGIC_VECTOR(r_quotient);
    o_remainder <= STD_LOGIC_VECTOR(r_remainder);
    o_done <= r_done;
END ARCHITECTURE rtl;