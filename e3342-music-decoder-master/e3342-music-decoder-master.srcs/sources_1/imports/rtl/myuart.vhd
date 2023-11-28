LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;


ENTITY myuart IS
	PORT (
		din : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		busy : OUT STD_LOGIC;
		wen : IN STD_LOGIC;
		sout : OUT STD_LOGIC;
		clr : IN STD_LOGIC;
		clk : IN STD_LOGIC
	);
END myuart;

ARCHITECTURE rtl OF myuart IS
	TYPE state_type IS (idle, start, d0, d1, d2, d3, d4, d5, d6, d7, stop);
	SIGNAL state : state_type := idle;
	SIGNAL cnt : INTEGER RANGE 0 TO 9 := 0;
BEGIN
	statechg : PROCESS (clr, clk, cnt)
	BEGIN
		IF clr = '1' THEN
			state <= idle;
		ELSIF rising_edge(clk) THEN
			IF cnt < 9 THEN
				cnt <= cnt + 1;
			ELSE
				cnt <= 0;
			END IF;
			CASE(state) IS
				WHEN idle => 
					IF wen = '1' THEN
		                  		sout <= '1';
				          	busy <= '0';
				          	state <= start;
				          			         
					END IF;
				WHEN start => 
					IF cnt = 9 THEN
						sout <= '0';
				          	busy <= '1';
				          	state <= d0;
					END IF;
				WHEN d0 => 
					IF cnt = 9 THEN
					      	sout <= din(0);
				          	busy <= '1';
				          	state <= d1;
					END IF;
				WHEN d1 => 
					IF cnt = 9 THEN
						sout <= din(1);
				          	busy <= '1';
				          	state <= d2;
					END IF;
				WHEN d2 => 
					IF cnt = 9 THEN
						sout <= din(2);
				          	busy <= '1';
				          	state <= d3;
					END IF;
				WHEN d3 => 
					IF cnt = 9 THEN
						sout <= din(3);
				          	busy <= '1';
				          	state <= d4;
					END IF;
				WHEN d4 => 
					IF cnt = 9 THEN
					   	sout <= din(4);
				          	busy <= '1';
						state <= d5;
					END IF;
				WHEN d5 => 
					IF cnt = 9 THEN
					   	sout <= din(5);
				          	busy <= '1';
						state <= d6;
					END IF;
				WHEN d6 => 
					IF cnt = 9 THEN
						sout <= din(6);
				          	busy <= '1';
						state <= d7;
					END IF;
				WHEN d7 => 
					IF cnt = 9 THEN
					   	sout <= din(7);
				          	busy <= '1';
						state <= stop;
					END IF;
				WHEN stop => 
					IF cnt = 9 THEN
					   	 sout <= '1';
				          	 busy <= '1';
						 state <= idle;
					END IF;
 
			END CASE;
		END IF;
	END PROCESS;

END rtl;
