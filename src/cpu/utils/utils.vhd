LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

PACKAGE utils IS
    FUNCTION log2_unsigned (value : NATURAL) RETURN NATURAL;
    FUNCTION log2_ceil (value : POSITIVE) RETURN NATURAL;

    FUNCTION bits_required_for_vector (vector_length : POSITIVE) RETURN NATURAL;

    FUNCTION are_all_zeroes (value : STD_LOGIC_VECTOR) RETURN BOOLEAN;

    FUNCTION max(a : INTEGER; b : INTEGER) RETURN INTEGER;

    FUNCTION bool_to_std_logic(value : BOOLEAN) RETURN STD_LOGIC;

    FUNCTION reverse_vector (a : STD_LOGIC_VECTOR) RETURN STD_LOGIC_VECTOR;
END PACKAGE utils;

PACKAGE BODY utils IS
    -- Thanks to this: https://www.edaboard.com/threads/moved-vhdl-log-base-2-function.242745/ 
    FUNCTION log2_unsigned (value : NATURAL) RETURN NATURAL IS
        VARIABLE temp : NATURAL := value;
        VARIABLE n : NATURAL := 0;
    BEGIN
        WHILE temp > 1 LOOP
            temp := temp / 2;
            n := n + 1;
        END LOOP;
        RETURN n;
    END FUNCTION log2_unsigned;

    -- Thanks to this: https://www.edaboard.com/threads/moved-vhdl-log-base-2-function.242745/ 
    FUNCTION log2_ceil (value : POSITIVE) RETURN NATURAL IS
        VARIABLE return_value : NATURAL;
    BEGIN
        return_value := log2_unsigned(value);
        IF (value > (2 ** return_value)) THEN
            RETURN(return_value + 1);
            ELSE
            RETURN(return_value);
        END IF;
    END FUNCTION log2_ceil;

    FUNCTION bits_required_for_vector (vector_length : POSITIVE) RETURN NATURAL IS
    BEGIN
        RETURN(log2_ceil(vector_length));
    END FUNCTION bits_required_for_vector;

    FUNCTION are_all_zeroes (value : STD_LOGIC_VECTOR) RETURN BOOLEAN IS
    BEGIN
        RETURN value = (value'RANGE => '0');
    END FUNCTION are_all_zeroes;

    FUNCTION max(a : INTEGER; b : INTEGER) RETURN INTEGER IS
    BEGIN
        IF a > b THEN
            RETURN a;
            ELSE
            RETURN b;
        END IF;
    END FUNCTION max;

    FUNCTION bool_to_std_logic(value : BOOLEAN) RETURN STD_LOGIC IS
    BEGIN
        IF value THEN
            RETURN '1';
            ELSE
            RETURN '0';
        END IF;
    END FUNCTION bool_to_std_logic;

    FUNCTION reverse_vector (a : STD_LOGIC_VECTOR) RETURN STD_LOGIC_VECTOR IS
        VARIABLE result : STD_LOGIC_VECTOR(a'RANGE);
        ALIAS aa : STD_LOGIC_VECTOR(a'REVERSE_RANGE) IS a;
    BEGIN
        FOR i IN aa'RANGE LOOP
            result(i) := aa(i);
        END LOOP;
        RETURN result;
    END FUNCTION reverse_vector;
END PACKAGE BODY utils;