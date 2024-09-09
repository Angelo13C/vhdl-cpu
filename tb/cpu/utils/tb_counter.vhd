LIBRARY IEEE;
USE IEEE.numeric_std.ALL;
USE IEEE.std_logic_1164.ALL;

LIBRARY work;
USE work.utils.ALL;

ENTITY tb_counter IS
END tb_counter;

ARCHITECTURE rtl OF tb_counter IS
    CONSTANT c_MAX_VALUE : NATURAL := 30;
    CONSTANT c_CLOCK_PERIOD : TIME := 10 ns;

    SIGNAL tb_reset : STD_LOGIC := '0';
    SIGNAL tb_clock : STD_LOGIC := '0';
    SIGNAL tb_has_been_resetted : BOOLEAN := false;
    SIGNAL tb_counter_previous_output : INTEGER := 0;
    SIGNAL tb_counter_output : STD_LOGIC_VECTOR(bits_required_for_vector(c_MAX_VALUE) - 1 DOWNTO 0);
BEGIN
    tb_clock <= NOT tb_clock AFTER c_CLOCK_PERIOD;
    tb_reset <= '1', '0' AFTER 5 ns;
    tb_has_been_resetted <= true AFTER 5 ns;

    uut : ENTITY work.counter
        GENERIC MAP(
            g_MAX_VALUE => c_MAX_VALUE
        )
        PORT MAP(
            i_reset => tb_reset,
            i_clock => tb_clock,
            o_counter => tb_counter_output
        );

    assertion_process : PROCESS (tb_clock)
    BEGIN
        IF tb_reset = '1' THEN
            ASSERT are_all_zeroes(tb_counter_output)
            REPORT "Counter reset failed with value " & INTEGER'image(to_integer(unsigned(tb_counter_output))) SEVERITY FAILURE;

        ELSIF tb_has_been_resetted AND rising_edge(tb_clock) THEN
            ASSERT to_integer(unsigned(tb_counter_output)) = tb_counter_previous_output
            REPORT "Counting failed, " & INTEGER'image(to_integer(unsigned(tb_counter_output))) & " != " & INTEGER'image(tb_counter_previous_output)
                SEVERITY FAILURE;
            tb_counter_previous_output <= tb_counter_previous_output + 1;
            IF tb_counter_previous_output = c_MAX_VALUE THEN
                tb_counter_previous_output <= 0;
            END IF;
        END IF;
    END PROCESS;

    stop_simulation_process : PROCESS
    BEGIN
        WAIT FOR 1 ms;
        REPORT "Simulation completed successfully." SEVERITY failure;
    END PROCESS;

END ARCHITECTURE rtl;