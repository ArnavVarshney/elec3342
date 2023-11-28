library ieee;
use ieee.std_logic_1164.all;

entity mcdecoder is
    port (
        din    : in std_logic_vector(2 downto 0);
        valid  : in std_logic;
        clr    : in std_logic;
        clk    : in std_logic;
      --  led    : out std_logic;
        dout   : out std_logic_vector(7 downto 0);
        dvalid : out std_logic;
        error  : out std_logic);
end mcdecoder;

ARCHITECTURE Behavioral OF mcdecoder IS
    type state_type is (St_RESET, St_ERROR, St_STARTING , St_LISTENING, St_WRITING, St_STOP);
    signal state, next_state : state_type := St_RESET;
    signal valid_buffer : std_logic;
    signal note_byte : std_logic_vector(5 downto 0);
    signal note_order, note_order_buffer : std_logic := '1';
begin


    sync_process: process (clk, clr)
    begin
        if clr = '1' then
            state <= St_RESET;
        elsif rising_edge(clk) then
            note_order_buffer <= note_order;
            state <= next_state;

            if (valid = '1') then
                note_byte <= note_byte(2 downto 0) & din;
                if state = St_RESET then
                    note_order <= '1';
                else
                    note_order <= not note_order;
                end if;
            end if;

        end if;
    end process;

    state_logic: process (note_byte, state)
    begin
        next_state <= state;
        case(state) is
            when St_RESET =>
                if note_byte = "000111" then
                    next_state <= St_STARTING;
                end if;

            when St_STARTING =>
                if (note_order = '1' and note_order_buffer = '0') then
                    if note_byte = "000111" then
                        next_state <= St_LISTENING;
                    else
                        next_state <= St_RESET;
                    end if;
                end if;

            when St_LISTENING =>
                if (note_order = '1' and note_order_buffer = '0') then
                    if note_byte = "111000" then
                        next_state <= St_STOP;
                    else
                        next_state <= St_WRITING;
                    end if;
                end if;

            when St_WRITING =>
                next_state <= St_LISTENING;

            when St_STOP =>
                if (note_order = '1' and note_order_buffer = '0') then
                    if note_byte = "111000" then
                        next_state <= St_RESET;
                    else
                        next_state <= St_ERROR;
                    end if;
                end if;

            when St_ERROR =>
                next_state <= St_RESET;

            when others =>
                null;
        end case;
    end process;

    output_logic: process (state)
    begin
        error <= '0';
        dvalid <= '0';
        case(state) is
            when St_ERROR => error <= '1';
            when St_WRITING =>
                dvalid <= '1';
                case(note_byte) is
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
						dout <= "01010001";
					WHEN "100011" =>
						dout <= "01001010";
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
                    when others => null;
                end case;
            when others => null;
        end case;
    end process;
end Behavioral;