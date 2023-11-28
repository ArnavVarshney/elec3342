LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.numeric_std.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
-- library UNISIM;
-- use UNISIM.VComponents.all;

ENTITY symb_det IS
	PORT (
		clk : IN std_logic; -- input clock 96khz
		clr : IN std_logic; -- input synchronized reset
		adc_data : IN std_logic_vector(11 DOWNTO 0); -- input 12-bit adc data
		symbol_valid : OUT std_logic;
		symbol_out : OUT std_logic_vector(2 DOWNTO 0) -- output 3-bit detection symbol
	);
END symb_det;

ARCHITECTURE rtl OF symb_det IS
	SIGNAL signed_adc : signed(11 DOWNTO 0);
	SIGNAL last_signed_adc : signed(11 DOWNTO 0);
	SIGNAL bitty : std_logic := '0';
	SIGNAL clkcnt : unsigned(11 DOWNTO 0) := x"000";
	SIGNAL zcd : std_logic := '0';
	TYPE state_type IS (IDLE, ZCDWAIT, COUNT, SEND);
	SIGNAL state, next_state : state_type := IDLE;
	SIGNAL stopzcdcheck : STD_LOGIC := '0';
	SIGNAL freq_counter : unsigned(7 DOWNTO 0);
BEGIN
	sync : PROCESS (clr, clk)
	BEGIN
		signed_adc <= signed(adc_data);
		IF clr = '1' THEN
			state <= IDLE;
		ELSIF rising_edge(clk) THEN
			IF clkcnt = x"5DB" THEN
				bitty <= NOT bitty;
				stopzcdcheck <= '0';
				clkcnt <= x"000";
			ELSE
				clkcnt <= clkcnt + 1;
			END IF;
			state <= next_state;
			CASE (state) IS
				WHEN ZCDWAIT => 
					IF (last_signed_adc <- 123 AND signed_adc > 123 AND stopzcdcheck = '0') THEN
						zcd <= '1';
						stopzcdcheck <= '1';
					ELSE
						zcd <= '0';
					END IF;
				WHEN COUNT => 
					zcd <= '0';
					freq_counter <= freq_counter + 1;
					IF (last_signed_adc <- 123 AND signed_adc > 123) THEN
						zcd <= '1';
					END IF;
				WHEN IDLE => 
					freq_counter <= x"00";
				WHEN OTHERS => 
					NULL;
			END CASE;
			last_signed_adc <= signed_adc;
		END IF;
	END PROCESS;
 
	statel : PROCESS (state, signed_adc)
	BEGIN
		next_state <= state;
		CASE(state) IS
			WHEN IDLE => 
				IF bitty = '1' THEN
					next_state <= ZCDWAIT;
				END IF;
			WHEN ZCDWAIT => 
				IF zcd = '1' THEN
					next_state <= COUNT;
				END IF;
			WHEN COUNT => 
				IF zcd = '1' THEN
					next_state <= SEND;
				END IF;
			WHEN SEND => 
				next_state <= IDLE;
			WHEN OTHERS => 
				NULL;
		END CASE;
	END PROCESS;
 
	SENDING : PROCESS (state)
		VARIABLE count_int : INTEGER;
	BEGIN
		symbol_valid <= '0';
		IF state = SEND THEN
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
 
END rtl;