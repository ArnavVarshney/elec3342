lIBRARY ieee;
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
	TYPE state_type IS (St_IDLE, St_START, St_D0, St_D1, St_D2, St_D3, St_D4, St_D5, St_D6, St_D7, St_STOP);
	SIGNAL state, next_state   : state_type := St_IDLE;
	SIGNAL din_buffer          : std_logic_vector (8 DOWNTO 0);
	SIGNAL bitposition, baudcounter : INTEGER RANGE 0 TO 9  := 0;
BEGIN
	sync_process : PROCESS (clk, clr)
	BEGIN
		IF clr = '1' THEN
			state <= St_IDLE;
		ELSIF rising_edge(clk) THEN
			state      <= next_state;
            
			IF state = St_IDLE THEN
				bitposition    <= 0;
				baudcounter <= 0;
			ELSE
				IF baudcounter = 9 THEN
					baudcounter <= 0;
					IF bitposition = 9 THEN
						bitposition <= 0;
					ELSE
						bitposition <= bitposition + 1;
					END IF;
				ELSE
					baudcounter <= baudcounter + 1;
				END IF;
			END IF;
		END IF;
	END PROCESS;

state_logic: PROCESS (wen, baudcounter)
BEGIN
    next_state <= state;
    CASE state IS
        WHEN St_IDLE =>
            IF (wen = '1') THEN
                din_buffer <= din & "0";
                next_state <= St_START;
            END IF;
        WHEN St_START =>
            IF baudcounter = 9 THEN
                next_state <= St_D0;
            END IF;
        WHEN St_D0 =>
            IF baudcounter = 9 THEN
                next_state <= St_D1;
            END IF;
        WHEN St_D1 =>
            IF baudcounter = 9 THEN
                next_state <= St_D2;
            END IF;
        WHEN St_D2 =>
            IF baudcounter = 9 THEN
                next_state <= St_D3;
            END IF;
        WHEN St_D3 =>
            IF baudcounter = 9 THEN
                next_state <= St_D4;
            END IF;
        WHEN St_D4 =>
            IF baudcounter = 9 THEN
                next_state <= St_D5;
            END IF;
        WHEN St_D5 =>
            IF baudcounter = 9 THEN
                next_state <= St_D6;
            END IF;
        WHEN St_D6 =>
            IF baudcounter = 9 THEN
                next_state <= St_D7;
            END IF;
        WHEN St_D7 =>
            IF baudcounter = 9 THEN
                next_state <= St_STOP;
            END IF;
        WHEN St_STOP =>
            IF baudcounter = 9 THEN
                next_state <= St_IDLE;
            END IF;
        WHEN OTHERS =>
            next_state <= St_IDLE;
    END CASE;
END PROCESS;

	output_logic : PROCESS (state, bitposition)
	BEGIN
		CASE(state) IS
			WHEN St_IDLE =>
				sout <= '1';
				busy <= '0';
			WHEN St_START to St_D7 =>
				busy <= '1';
				CASE(bitposition) IS
					WHEN 0 =>
						sout <= '0';
					WHEN 9 =>
						sout <= '1';
					WHEN OTHERS =>
						sout <= din_buffer(bitposition);
				END CASE;
			WHEN St_STOP =>
				sout <= '1';
				busy <= '0';
			WHEN OTHERS =>
				NULL;
		END CASE;
	END PROCESS;
END Behavioral;