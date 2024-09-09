LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY adder_subtractor IS
    GENERIC (
        g_OPERANDS_BITS : POSITIVE RANGE 1 TO 128 := 64
    );
    PORT (
        i_number1 : IN STD_LOGIC_VECTOR(g_OPERANDS_BITS - 1 DOWNTO 0);
        i_number2 : IN STD_LOGIC_VECTOR(g_OPERANDS_BITS - 1 DOWNTO 0);
        i_subtract : IN STD_LOGIC;

        o_result : OUT STD_LOGIC_VECTOR(g_OPERANDS_BITS - 1 DOWNTO 0);
        o_carry : OUT STD_LOGIC
    );
END ENTITY adder_subtractor;

ARCHITECTURE rtl OF adder_subtractor IS
    SIGNAL w_number2 : STD_LOGIC_VECTOR(g_OPERANDS_BITS - 1 DOWNTO 0);
BEGIN
    gen_xor : FOR i IN i_number2'RANGE GENERATE
        w_number2(i) <= i_number2(i) XOR i_subtract;
    END GENERATE gen_xor;

    ripple_carry_adder_instance : ENTITY work.ripple_carry_adder
        GENERIC MAP(
            g_OPERANDS_BITS => g_OPERANDS_BITS
        )
        PORT MAP(

            i_number1 => i_number1,
            i_number2 => w_number2,
            i_carry => i_subtract,

            o_sum => o_result,
            o_carry => o_carry
        );

END rtl;