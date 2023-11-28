LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
ENTITY myuart IS
	PORT
	(
		din  : IN std_logic_vector (7 DOWNTO 0);
		busy : OUT std_logic;
		wen  : IN std_logic;
		sout : OUT std_logic;
		clr  : IN std_logic;
		clk  : IN std_logic
	);
END myuart;
ARCHITECTURE Behavioral OF myuart IS
	TYPE state_type IS (St_IDLE, St_BUSY);
	SIGNAL state, next_state   : state_type := St_IDLE;
	SIGNAL wen_buffer          : std_logic;
	SIGNAL din_buffer          : std_logic_vector (8 DOWNTO 0);
	SIGNAL bit_seq, baud_timer : unsigned (3 DOWNTO 0) := x"0";
BEGIN
	sync_process : PROCESS (clk, clr)
	BEGIN
		IF clr = '1' THEN
			state <= St_IDLE;
		ELSIF rising_edge(clk) THEN
			wen_buffer <= wen;
			state      <= next_state;
			IF state = St_IDLE THEN
				bit_seq    <= x"0";
				baud_timer <= x"0";
			ELSE
				IF baud_timer = x"9" THEN
					baud_timer <= x"0";
					IF bit_seq = x"9" THEN
						bit_seq <= x"0";
					ELSE
						bit_seq <= bit_seq + 1;
					END IF;
				ELSE
					baud_timer <= baud_timer + 1;
				END IF;
			END IF;
		END IF;
	END PROCESS;
	state_logic : PROCESS (wen, baud_timer)
	BEGIN
		next_state <= state;
		CASE(state) IS
			WHEN St_IDLE =>
				IF (wen = '1' AND wen_buffer = '0') THEN
					din_buffer <= din & "0";
					next_state <= St_BUSY;
				END IF;
			WHEN St_BUSY =>
				IF bit_seq = x"9" AND baud_timer = x"9" THEN
					next_state <= St_IDLE;
				END IF;
			WHEN OTHERS =>
				next_state <= St_IDLE;
		END CASE;
	END PROCESS;
	output_logic : PROCESS (state, bit_seq)
	BEGIN
		CASE(state) IS
			WHEN St_IDLE =>
				sout <= '1';
				busy <= '0';
			WHEN St_BUSY =>
				busy <= '1';
				CASE(bit_seq) IS
					WHEN x"0" =>
						sout <= '0';
					WHEN x"9" =>
						sout <= '1';
					WHEN OTHERS =>
						sout <= din_buffer(to_integer(bit_seq));
			END CASE;
			WHEN OTHERS =>
				NULL;
		END CASE;
	END PROCESS;
END Behavioral;