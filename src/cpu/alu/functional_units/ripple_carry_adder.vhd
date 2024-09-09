LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY ripple_carry_adder IS
    GENERIC (
        g_OPERANDS_BITS : POSITIVE RANGE 1 TO 128 := 64
    );
    PORT (
        i_number1 : IN STD_LOGIC_VECTOR(g_OPERANDS_BITS - 1 DOWNTO 0);
        i_number2 : IN STD_LOGIC_VECTOR(g_OPERANDS_BITS - 1 DOWNTO 0);
        i_carry : IN STD_LOGIC;

        o_sum : OUT STD_LOGIC_VECTOR(g_OPERANDS_BITS - 1 DOWNTO 0);
        o_carry : OUT STD_LOGIC
    );
END ENTITY ripple_carry_adder;

ARCHITECTURE rtl OF ripple_carry_adder IS
    SIGNAL w_carry : STD_LOGIC_VECTOR(g_OPERANDS_BITS DOWNTO 0);
BEGIN
    w_carry(0) <= i_carry;

    full_adder_generate : FOR i IN 0 TO g_OPERANDS_BITS - 1 GENERATE
        full_adder_instance : ENTITY work.full_adder
            PORT MAP(
                i_bit1 => i_number1(i),
                i_bit2 => i_number2(i),
                i_carry => w_carry(i),

                o_sum => o_sum(i),
                o_carry => w_carry(i + 1)
            );
    END GENERATE full_adder_generate;

    o_carry <= w_carry(g_OPERANDS_BITS);
END rtl;