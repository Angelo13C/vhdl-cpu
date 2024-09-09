LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY tb_full_adder IS
END ENTITY tb_full_adder;

ARCHITECTURE behavior OF tb_full_adder IS
    SIGNAL tb_i_bit1 : STD_LOGIC;
    SIGNAL tb_i_bit2 : STD_LOGIC;
    SIGNAL tb_i_carry : STD_LOGIC;
    SIGNAL tb_o_sum : STD_LOGIC;
    SIGNAL tb_o_carry : STD_LOGIC;

BEGIN
    uut : ENTITY work.full_adder
        PORT MAP
        (
            i_bit1 => tb_i_bit1,
            i_bit2 => tb_i_bit2,
            i_carry => tb_i_carry,
            o_sum => tb_o_sum,
            o_carry => tb_o_carry
        );

    PROCESS
    BEGIN

        FOR i IN 0 TO 1 LOOP
            FOR j IN 0 TO 1 LOOP
                FOR k IN 0 TO 1 LOOP
                    tb_i_bit1 <= STD_LOGIC'VAL(i);
                    tb_i_bit2 <= STD_LOGIC'VAL(j);
                    tb_i_carry <= STD_LOGIC'VAL(k);
                    -- Wait for signals to propagate
                    WAIT FOR 100 ns;

                    ASSERT tb_o_sum = (tb_i_bit1 XOR tb_i_bit2 XOR tb_i_carry)
                    REPORT "Test failed for inputs: " &
                        "i_bit1=" & STD_LOGIC'IMAGE(tb_i_bit1) & ", " &
                        "i_bit2=" & STD_LOGIC'IMAGE(tb_i_bit2) & ", " &
                        "i_carry=" & STD_LOGIC'IMAGE(tb_i_carry) &
                        " | Expected o_sum=" &
                        STD_LOGIC'IMAGE(tb_i_bit1 XOR tb_i_bit2 XOR tb_i_carry) &
                        " | Got o_sum=" & STD_LOGIC'IMAGE(tb_o_sum)
                        SEVERITY FAILURE;

                    ASSERT tb_o_carry = ((tb_i_bit1 AND tb_i_bit2) OR
                    ((tb_i_bit1 XOR tb_i_bit2) AND tb_i_carry))
                    REPORT "Test failed for inputs: " &
                        "i_bit1=" & STD_LOGIC'IMAGE(tb_i_bit1) & ", " &
                        "i_bit2=" & STD_LOGIC'IMAGE(tb_i_bit2) & ", " &
                        "i_carry=" & STD_LOGIC'IMAGE(tb_i_carry) &
                        " | Expected o_carry=" &
                        STD_LOGIC'IMAGE((tb_i_bit1 AND tb_i_bit2) OR
                        ((tb_i_bit1 XOR tb_i_bit2) AND tb_i_carry)) &
                        " | Got o_carry=" & STD_LOGIC'IMAGE(tb_o_carry)
                        SEVERITY FAILURE;
                END LOOP;
            END LOOP;
        END LOOP;

        WAIT;
    END PROCESS;

END ARCHITECTURE behavior;