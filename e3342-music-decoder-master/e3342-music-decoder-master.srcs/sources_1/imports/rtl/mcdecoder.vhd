LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
ENTITY mcdecoder IS
	PORT
	(
		din    : IN std_logic_vector(2 DOWNTO 0);
		valid  : IN std_logic;
		clr    : IN std_logic;
		clk    : IN std_logic;
		led    : OUT std_logic;
		dout   : OUT std_logic_vector(7 DOWNTO 0);
		dvalid : OUT std_logic;
		error  : OUT std_logic
	);
END mcdecoder;
ARCHITECTURE Behavioral OF mcdecoder IS
	TYPE state_type IS (St_RESET, St_ERROR, St_STARTING, St_LISTENING, St_WRITING, St_ENDING);
	SIGNAL state, next_state : state_type := St_RESET;
	SIGNAL valid_buffer      : std_logic;
	SIGNAL note_byte         : std_logic_vector(5 DOWNTO 0);
	SIGNAL note_order        : std_logic := '0';
	SIGNAL next_note_order   : std_logic := '1';
BEGIN
	led <= note_order;
	sync_process : PROCESS (clk, clr)
	BEGIN
		IF clr = '1' THEN
			state <= St_RESET;
		ELSIF rising_edge(clk) THEN
			valid_buffer <= valid;
			state        <= next_state;
			IF valid = '1' THEN
				note_byte(5 DOWNTO 3) <= note_byte(2 DOWNTO 0);
				note_byte(2 DOWNTO 0) <= din;
				note_order            <= next_note_order;
			END IF;
		END IF;
	END PROCESS;
	state_logic        : PROCESS (valid)
		VARIABLE next_byte : std_logic_vector(5 DOWNTO 0);
	BEGIN
		IF state = St_RESET THEN
			next_note_order <= '0';
		ELSE
			next_note_order <= note_order;
			IF (valid = '1' AND valid_buffer = '0') THEN
				next_note_order <= NOT note_order;
			END IF;
		END IF;
		next_byte := note_byte(2 DOWNTO 0) & din;
		next_state <= state;
		CASE(state) IS
			WHEN St_RESET =>
				IF next_byte = "000111" THEN
					next_state <= St_STARTING;
				END IF;
			WHEN St_STARTING =>
				IF valid = '1' THEN
					IF note_order = '1' AND next_byte = "000111" THEN
						next_state <= St_LISTENING;
					ELSIF note_order = '0' AND din /= "000" THEN
						next_state <= St_RESET;
					END IF;
				END IF;
			WHEN St_LISTENING =>
				IF valid = '1' THEN
					IF note_order = '1' THEN
						CASE(next_byte) IS
							WHEN "111000" =>
								next_state <= St_ENDING;
							WHEN "010001" | "011001" | "100001" | "101001" | "110001" | "001010" |
								"011010" | "100010" | "101010" | "110010" | "001011" | "010011" |
									"100011" | "101011" | "110011" | "001100" | "010100" | "011100" |
									"101100" | "110100" | "001101" | "010101" | "011101" | "100101" |
									"110101" | "001110" | "010110" | "011110" | "100110" | "101110" =>
									next_state <= St_WRITING;
							WHEN OTHERS =>
								next_state <= St_ERROR;
						END CASE;
					ELSIF din = "000" THEN
						next_state <= St_ERROR;
					END IF;
				END IF;
			WHEN St_ENDING =>
				IF valid = '1' THEN
					IF note_order = '1' AND next_byte = "111000" THEN
						next_state <= St_RESET;
					ELSIF note_order = '0' AND din /= "111" THEN
						next_state <= St_ERROR;
					END IF;
				END IF;
			WHEN St_ERROR =>
				next_state <= St_RESET;
			WHEN St_WRITING =>
				next_state <= St_LISTENING;
			WHEN OTHERS =>
				NULL;
		END CASE;
	END PROCESS;
	output_logic : PROCESS (state)
	BEGIN
		error  <= '0';
		dvalid <= '0';
		CASE(state) IS
			WHEN St_RESET =>
				dout <= "10000000";
			WHEN St_ERROR =>
				dout  <= "10000001";
				error <= '1';
			WHEN St_STARTING =>
				dout <= "10000010";
			WHEN St_LISTENING =>
				NULL;
			WHEN St_WRITING =>
				dvalid <= '1';
				CASE(note_byte) IS
--                    WHEN "001001" =>
--                        dout <= "00101000";
--                    WHEN "010010" =>
--                        dout <= "00101001";
--                    WHEN "011011" =>
--                        dout <= "00111010";
--                    WHEN "100100" =>
--                        dout <= "01011110";
--                    WHEN "101101" =>
--                        dout <= "00111011";
--                    WHEN "110110" =>
--                        dout <= "00100011";

					WHEN "001010" =>
						dout <= "01000010";
					WHEN "001011" =>
						dout <= "01000100";
					WHEN "001100" =>
						dout <= "01001000";
					WHEN "001101" =>
						dout <= "01001100";
					WHEN "001110" =>
						dout <= "01010010";
					WHEN "010001" =>
						dout <= "01000001";
					WHEN "010011" =>
						dout <= "01000111";
					WHEN "010100" =>
						dout <= "01001011";
					WHEN "010101" =>
						dout <= "01010001";
					WHEN "010110" =>
						dout <= "01010110";
					WHEN "011001" =>
						dout <= "01000011";
					WHEN "011010" =>
						dout <= "01000110";
					WHEN "011100" =>
						dout <= "01010000";
					WHEN "011101" =>
						dout <= "01010101";
					WHEN "011110" =>
						dout <= "01011010";
					WHEN "100001" =>
						dout <= "01000101";
					WHEN "100010" =>
						dout <= "01001010";
					WHEN "100011" =>
						dout <= "01001111";
					WHEN "100101" =>
						dout <= "01011001";
					WHEN "100110" =>
						dout <= "00101110";
					WHEN "101001" =>
						dout <= "01001001";
					WHEN "101010" =>
						dout <= "01001110";
					WHEN "101011" =>
						dout <= "01010100";
					WHEN "101100" =>
						dout <= "01011000";
					WHEN "101110" =>
						dout <= "00111111";
					WHEN "110001" =>
						dout <= "01001101";
					WHEN "110010" =>
						dout <= "01010011";
					WHEN "110011" =>
						dout <= "01010111";
					WHEN "110100" =>
						dout <= "00100001";
					WHEN "110101" =>
						dout <= "00100000";
					WHEN OTHERS =>
						dout   <= "11111111";
						dvalid <= '0';
			END CASE;
			WHEN St_ENDING =>
				dout <= "10000100";
			WHEN OTHERS =>
				dout <= "10000101";
		END CASE;
	END PROCESS;
END Behavioral;