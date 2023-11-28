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
	SIGNAL squared_adc        : std_logic;
	SIGNAL squared_adc_buffer : std_logic;
	SIGNAL signed_adc         : signed(11 DOWNTO 0);
	SIGNAL note_clk           : std_logic := '0';
	SIGNAL note_clk_buffer    : std_logic := '0';
	SIGNAL note_clk_counter   : unsigned(11 DOWNTO 0) := x"000";
	TYPE state_type IS (St_IDLE, St_STARTING, St_WAITING, St_LISTENING, St_COUNTING, St_WRITING);
	SIGNAL state, next_state : state_type := St_IDLE;
	SIGNAL freq_counter      : unsigned(7 DOWNTO 0);
BEGIN
	signed_adc <= signed(adc_data - x"800");
	sync_process : PROCESS (clk, clr)
	BEGIN
		IF clr = '1' THEN
			state <= St_IDLE;
		ELSIF rising_edge(clk) THEN
			squared_adc_buffer <= squared_adc;
			note_clk_buffer    <= note_clk;
			IF note_clk_counter = x"BB7" THEN
				note_clk         <= NOT note_clk;
				note_clk_counter <= x"000";
			ELSE
				note_clk_counter <= note_clk_counter + 1;
			END IF;
			state <= next_state;
			CASE(state) IS
				WHEN St_STARTING =>
					note_clk         <= '0';
					note_clk_counter <= x"000";
				WHEN St_WAITING =>
					freq_counter <= x"00";
				WHEN St_COUNTING =>
					freq_counter <= freq_counter + 1;
				WHEN OTHERS =>
					NULL;
			END CASE;
		END IF;
	END PROCESS;
	state_logic : PROCESS (state, note_clk, squared_adc)
	BEGIN
		next_state <= state;
		CASE(state) IS
			WHEN St_IDLE =>
				IF (squared_adc = '1' AND squared_adc_buffer = '0') THEN
					next_state <= St_STARTING;
				END IF;
			WHEN St_STARTING =>
				IF (squared_adc = '1' AND squared_adc_buffer = '0') THEN
					next_state <= St_WAITING;
				END IF;
			WHEN St_WAITING =>
				IF (note_clk = '1' AND note_clk_buffer = '0') THEN
					next_state <= St_LISTENING;
				END IF;
			WHEN St_LISTENING =>
				IF (squared_adc = '1' AND squared_adc_buffer = '0') THEN
					next_state <= St_COUNTING;
				END IF;
			WHEN St_COUNTING =>
				IF (squared_adc = '1' AND squared_adc_buffer = '0') THEN
					next_state <= St_WRITING;
				END IF;
			WHEN St_WRITING =>
				next_state <= St_WAITING;
			WHEN OTHERS =>
				NULL;
		END CASE;
	END PROCESS;
	output_logic       : PROCESS (state)
		VARIABLE count_int : INTEGER;
	BEGIN
		symbol_valid <= '0';
		IF state = St_WRITING THEN
			symbol_valid <= '1';
			count_int := to_integer(freq_counter);
			CASE(count_int) IS
				WHEN 164 TO 255 =>
					symbol_out <= "111";
				WHEN 134 TO 163 =>
					symbol_out <= "110";
				WHEN 109 TO 133 =>
					symbol_out <= "101";
				WHEN 89 TO 108 =>
					symbol_out <= "100";
				WHEN 75 TO 88 =>
					symbol_out <= "011";
				WHEN 61 TO 74 =>
					symbol_out <= "010";
				WHEN 50 TO 60 =>
					symbol_out <= "001";
				WHEN 0 TO 49 =>
					symbol_out <= "000";
				WHEN OTHERS =>
					NULL;
			END CASE;
		END IF;
	END PROCESS;
	conv_adc : PROCESS (signed_adc)
	BEGIN
		IF signed_adc <- 233 THEN
			squared_adc <= '0';
		ELSIF signed_adc > 233 THEN
			squared_adc <= '1';
		END IF;
	END PROCESS;
END Behavioral;