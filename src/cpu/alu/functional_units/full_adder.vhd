LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY full_adder IS
    PORT (
        i_bit1 : IN STD_LOGIC;
        i_bit2 : IN STD_LOGIC;
        i_carry : IN STD_LOGIC;

        o_sum : OUT STD_LOGIC;
        o_carry : OUT STD_LOGIC
    );
END ENTITY full_adder;

ARCHITECTURE rtl OF full_adder IS
    SIGNAL w_wire1 : STD_LOGIC;
    SIGNAL w_wire2 : STD_LOGIC;
    SIGNAL w_wire3 : STD_LOGIC;
BEGIN

    w_wire1 <= i_bit1 XOR i_bit2;
    w_wire2 <= w_wire1 AND i_carry;
    w_wire3 <= i_bit1 AND i_bit2;

    o_sum <= w_wire1 XOR i_carry;
    o_carry <= w_wire2 OR w_wire3;

END rtl;