
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
USE IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

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
						state <= start;
					END IF;
				WHEN start => 
					IF cnt = 9 THEN
						state <= d0;
					END IF;
				WHEN d0 => 
					IF cnt = 9 THEN
						state <= d1;
					END IF;
				WHEN d1 => 
					IF cnt = 9 THEN
						state <= d2;
					END IF;
				WHEN d2 => 
					IF cnt = 9 THEN
						state <= d3;
					END IF;
				WHEN d3 => 
					IF cnt = 9 THEN
						state <= d4;
					END IF;
				WHEN d4 => 
					IF cnt = 9 THEN
						state <= d5;
					END IF;
				WHEN d5 => 
					IF cnt = 9 THEN
						state <= d6;
					END IF;
				WHEN d6 => 
					IF cnt = 9 THEN
						state <= d7;
					END IF;
				WHEN d7 => 
					IF cnt = 9 THEN
						state <= stop;
					END IF;
				WHEN stop => 
					IF cnt = 9 THEN
						state <= idle;
					END IF;
 
			END CASE;
		END IF;
	END PROCESS;
	update : PROCESS (state)
	BEGIN
		CASE(state) IS
			WHEN idle => 
				sout <= '1';
				busy <= '0';
			WHEN start => 
				sout <= '0';
				busy <= '1';
			WHEN d0 => 
				sout <= din(0);
				busy <= '1';
			WHEN d1 => 
				sout <= din(1);
				busy <= '1';
			WHEN d2 => 
				sout <= din(2);
				busy <= '1';
			WHEN d3 => 
				sout <= din(3);
				busy <= '1';
			WHEN d4 => 
				sout <= din(4);
				busy <= '1';
			WHEN d5 => 
				sout <= din(5);
				busy <= '1';
			WHEN d6 => 
				sout <= din(6);
				busy <= '1';
			WHEN d7 => 
				sout <= din(7);
				busy <= '1';
			WHEN stop => 
				sout <= '1';
				busy <= '1';
		END CASE;
	END PROCESS;
END rtl;
