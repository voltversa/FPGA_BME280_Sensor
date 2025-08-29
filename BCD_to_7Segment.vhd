
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity BCD_to_7Segment is
    Port (
       clk   : in std_logic;                -- System clock
        reset_n   : in std_logic;                -- Reset signal
        bcd_in    : in  std_logic_vector(15 downto 0);
        seg : out std_logic_vector(6 downto 0); -- a to g + dp
        an    : out std_logic_vector(3 downto 0); -- 4 anode signals
        dp: out std_logic 

    );
end BCD_to_7Segment;

architecture Behavioral of BCD_to_7Segment is
   -- Internal signals
    signal clk_div : integer := 0;
    signal digit_select : integer range 0 to 3 := 0;
    signal current_digit : std_logic_vector(3 downto 0);
signal dot_mask : std_logic_vector(3 downto 0):= "0010";  -- Dot on digit 2 (third from left)
 -- One bit per digit


    -- 7-segment encoding for digits 0-9
    type seg_table_type is array (0 to 13) of std_logic_vector(6 downto 0);
    constant seg_table : seg_table_type := (
        "1000000", -- 0
        "1111001", -- 1
        "0100100", -- 2
        "0110000", -- 3
        "0011001", -- 4
        "0010010", -- 5
        "0000010", -- 6
        "1111000", -- 7
        "0000000", -- 8
        "0010000",  -- 9
        "1000110",  -- C
        "1001000", -- 11: h (example)
        "1010010", -- 12: % (example)
        "1111111"  -- 13: blank (default)


    );

begin
  -- Clock divider to control refresh rate
    process (clk, reset_n)
    begin
        if reset_n = '0' then
            clk_div <= 0;
            digit_select <= 0;
        elsif rising_edge(clk) then
            if clk_div = 5000 then --  refresh rate
                clk_div <= 0;
                digit_select <= (digit_select + 1) mod 4;
            else
                clk_div <= clk_div + 1;
            end if;
        end if;
    end process;
  -- Select Active BCD Digit
    process (digit_select, bcd_in)
    begin
        case digit_select is
         when 0 => current_digit <=bcd_in(15 downto 12);
        when 1 => current_digit <= bcd_in(11 downto 8);
        when 2 => current_digit <= bcd_in(7 downto 4);
        when 3 => current_digit <= bcd_in(3 downto 0);
        when others => current_digit <= "0000";
        end case;
    end process;

    process(current_digit,dot_mask)
    begin
        case current_digit is
            when "0000" => seg <= seg_table(0); -- 0
            when "0001" => seg <= seg_table(1); -- 1
            when "0010" => seg <= seg_table(2); -- 2
            when "0011" => seg <= seg_table(3); -- 3
            when "0100" => seg <= seg_table(4); -- 4
            when "0101" => seg <= seg_table(5); -- 5
            when "0110" => seg <= seg_table(6); -- 6
            when "0111" => seg <= seg_table(7); -- 7
            when "1000" => seg <= seg_table(8); -- 8
            when "1001" => seg <= seg_table(9); -- 9
            when "1010" => seg <= seg_table(11);  -- h
            when "1011" => seg <= seg_table(12);  -- %
            when "1100" => seg <= seg_table(10);  -- C
            when others => seg <= seg_table(13);  -- blank

        end case;

    end process;
    
    -- Active Anode Selection
  an <= "0111" when digit_select = 0 else  -- Fourth digit (rightmost)
      "1011" when digit_select = 1 else  -- Third digit
      "1101" when digit_select = 2 else  -- Second digit
      "1110";                            -- First digit (leftmost)
dp <= not dot_mask(digit_select);
end Behavioral;
