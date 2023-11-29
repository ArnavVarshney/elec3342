LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.numeric_std.ALL;
ENTITY symb_det IS
    PORT
    (
        clk          : IN std_logic;
        clr          : IN std_logic;
        adc_data     : IN std_logic_vector(11 DOWNTO 0);
        symbol_valid : OUT std_logic;
        symbol_out   : OUT std_logic_vector(2 DOWNTO 0)
    );
END symb_det;
ARCHITECTURE Behavioral OF symb_det IS
    SIGNAL signed_adc_last  : signed(11 DOWNTO 0);
    SIGNAL signed_adc       : signed(11 DOWNTO 0);
    SIGNAL note_clk         : std_logic := '0';
    SIGNAL last_note_clk    : std_logic := '0';
    SIGNAL note_clk_counter : unsigned(11 DOWNTO 0) := x"000";
    TYPE state_type IS (St_WAITING, St_LISTENING, St_COUNTING, St_SENDING);
    SIGNAL state, next_state : state_type := St_WAITING;
    SIGNAL freq_counter      : unsigned(7 DOWNTO 0);
BEGIN
    signed_adc <= signed(adc_data - x"800");
    sync_process : PROCESS (clk, clr)
    BEGIN
        IF clr = '1' THEN
            state <= St_WAITING;
        ELSIF rising_edge(clk) THEN
            signed_adc_last <= signed_adc;
            last_note_clk   <= note_clk;
            IF note_clk_counter = x"7D0" THEN
                note_clk         <= NOT note_clk;
                note_clk_counter <= x"000";
            ELSE
                note_clk_counter <= note_clk_counter + 1;
            END IF;
            state <= next_state;
            CASE(state) IS
                WHEN St_WAITING =>
                    freq_counter <= x"00";
                WHEN St_COUNTING =>
                    freq_counter <= freq_counter + 1;
                WHEN OTHERS =>
                    NULL;
            END CASE;
        END IF;
    END PROCESS;
    state_logic : PROCESS (state, signed_adc, note_clk)
    BEGIN
        next_state <= state;
        CASE(state) IS
            WHEN St_WAITING =>
                IF last_note_clk = '0' AND note_clk = '1' THEN
                    next_state <= St_LISTENING;
                END IF;
            WHEN St_LISTENING =>
                IF signed_adc_last < 0 AND signed_adc > 0 THEN
                    next_state <= St_COUNTING;
                END IF;
            WHEN St_COUNTING =>
                IF signed_adc_last < 0 AND signed_adc > 0 THEN
                    next_state <= St_SENDING;
                END IF;
            WHEN St_SENDING =>
                next_state <= St_WAITING;
            WHEN OTHERS =>
                NULL;
        END CASE;
    END PROCESS;
    output_logic       : PROCESS (state)
        VARIABLE count_int : INTEGER;
    BEGIN
        symbol_valid <= '0';
        IF state = St_SENDING THEN
            symbol_valid <= '1';
            count_int := to_integer(freq_counter);
            CASE(count_int) IS
                WHEN 0 TO 49 =>
                    symbol_out <= "000";
                WHEN 50 TO 60 =>
                    symbol_out <= "001";
                WHEN 61 TO 74 =>     
                    symbol_out <= "010";
                WHEN 75 TO 88 =>     
                    symbol_out <= "011";        
                WHEN 89 TO 108 =>
                    symbol_out <= "100";
                WHEN 109 TO 133 =>
                    symbol_out <= "101";
                WHEN 134 TO 163 =>
                    symbol_out <= "110";
                WHEN 164 TO 255 =>
                    symbol_out <= "111";
                WHEN OTHERS =>
                    NULL;
            END CASE;
        END IF;
    END PROCESS;
END Behavioral;