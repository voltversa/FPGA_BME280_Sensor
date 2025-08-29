library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity humidity_compensation is
    Port (
        clk        : in  std_logic;
        rst        : in  std_logic;
        humidity_out : out std_logic_vector(15 downto 0);  -- compensated humidity in % * 1024

        t_fine     : in  integer;  -- from temp compensation
        hum_raw    : in  std_logic_vector(15 downto 0);  -- raw ADC_H value

        dig_H1     : in  unsigned(7 downto 0);
        dig_H2     : in  signed(15 downto 0);
        dig_H3     : in  unsigned(7 downto 0);
        dig_H4     : in  signed(11 downto 0);  -- combine bits manually in top level
        dig_H5     : in  signed(11 downto 0);  -- combine bits manually in top level
        dig_H6     : in  signed(7 downto 0)
    );
end humidity_compensation;

architecture Behavioral of humidity_compensation is
    signal humidity : integer := 0;
begin
process(clk, rst)
    variable adc_H       : integer;
    variable var_H       : integer;
    variable dig_H1_int  : integer;
    variable dig_H2_int  : integer;
    variable dig_H3_int  : integer;
    variable dig_H4_int  : integer;
    variable dig_H5_int  : integer;
    variable dig_H6_int  : integer;
    variable t_f         : integer;
begin
    if rst = '0' then
        humidity     <= 0;
        humidity_out <= (others => '0');
        
    elsif rising_edge(clk) then
        adc_H      := to_integer(unsigned(hum_raw));      -- Raw humidity
        dig_H1_int := to_integer(dig_H1);                 -- 8-bit unsigned
        dig_H2_int := to_integer(dig_H2);                 -- 16-bit signed
        dig_H3_int := to_integer(dig_H3);                 -- 8-bit unsigned
        dig_H4_int := to_integer(dig_H4);                 -- 12-bit signed
        dig_H5_int := to_integer(dig_H5);                 -- 12-bit signed
        dig_H6_int := to_integer(dig_H6);                 -- 8-bit signed
        t_f        := t_fine;                             -- input t_fine from temp_comp

        ---------------------------------------------
        -- Compensation formula (fixed-point integer)
        -- Based on BME280 datasheet
        ---------------------------------------------
        var_H := t_f - 76800;

        var_H := (((((adc_H * 16384) - ((dig_H4_int * 1048576) + ((dig_H5_int * var_H)))) + 16384) / 32768) *
         (((((((var_H * dig_H6_int) / 1024) * (((var_H * dig_H3_int) / 2048) + 32768)) / 1024) + 2097152) * dig_H2_int + 8192) / 16384));

-- Step 3
var_H := var_H - ((((var_H / 32768) * (var_H / 32768)) / 128) * dig_H1_int / 16);

        -- Clamp and scale result
     if var_H < 0 then
    var_H := 0;
elsif var_H > 419430400 then
    var_H := 419430400;
end if;


        humidity <= var_H / 4096;  -- %RH as integer
        humidity_out <= std_logic_vector(to_unsigned(humidity, 16));
    end if;
end process;


end Behavioral;
