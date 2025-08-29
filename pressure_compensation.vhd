library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity pressure_compensation is
    Port (
        clk          : in  std_logic;
        rst          : in  std_logic;
        pressure_out : out std_logic_vector(31 downto 0);  -- Output pressure in Pa

        t_fine       : in  integer;
        press_raw    : in  std_logic_vector(19 downto 0);  -- 20-bit raw ADC_P

        dig_P1       : in  unsigned(15 downto 0);
        dig_P2       : in  signed(15 downto 0);
        dig_P3       : in  signed(15 downto 0);
        dig_P4       : in  signed(15 downto 0);
        dig_P5       : in  signed(15 downto 0);
        dig_P6       : in  signed(15 downto 0);
        dig_P7       : in  signed(15 downto 0);
        dig_P8       : in  signed(15 downto 0);
        dig_P9       : in  signed(15 downto 0)
    );
end pressure_compensation;

architecture Behavioral of pressure_compensation is
    signal pressure : integer := 0;

begin

    process(clk, rst)
        variable adc_P : integer;
        variable var1  : integer;
        variable var2  : integer;
        variable p     : integer;

        variable dp1, dp2, dp3, dp4, dp5, dp6, dp7, dp8, dp9 : integer;
    begin
        if rst = '0' then
            pressure    <= 0;
            pressure_out <= (others => '0');

        elsif rising_edge(clk) then
            -- Convert raw pressure and calibration values
            adc_P := to_integer(unsigned(press_raw));

            dp1 := to_integer(dig_P1);
            dp2 := to_integer(dig_P2);
            dp3 := to_integer(dig_P3);
            dp4 := to_integer(dig_P4);
            dp5 := to_integer(dig_P5);
            dp6 := to_integer(dig_P6);
            dp7 := to_integer(dig_P7);
            dp8 := to_integer(dig_P8);
            dp9 := to_integer(dig_P9);

            -- var1 and var2 calculations
            var1 := ((t_fine / 2) - 64000);
         -- Assuming var1 is already assigned
var2 := (((var1 / 4) * (var1 / 4)) / 2048) * dP6;
var2 := var2 + ((var1 * dP5) * 2);
var2 := (var2 / 4) + (dP4 * 65536);

-- Assume var1 is already calculated from earlier steps
var1 := ((dP3 * ((var1 / 4) * (var1 / 4) / 8192)) / 8 + (dP2 * var1) / 2) / 262144;
var1 := ((32768 + var1) * dP1) / 32768;

            if var1 = 0 then
                pressure <= 0;
                pressure_out <= (others => '0');
            else
                -- Calculate p
              p := ( (1048576 - adc_P - (var2 / 4096)) * 3125 );  -- >>12 = /4096
if unsigned(to_unsigned(p, 32)) < x"80000000" then
        p := (p * 2) / var1;
    else
        p := (p / var1) * 2;
    end if;
var1 := (dp9 * (((p / 8) * (p / 8)) / 8192)) / 4096;
    var2 := ((p / 4) * dP8) / 8192;                      -- >>2, >>13
    p := p + ((var1 + var2 + dP7) / 16);                 -- >>4

                -- Store final pressure in Pascal
                pressure <= p;
                pressure_out <= std_logic_vector(to_unsigned(pressure, 32));
            end if;
        end if;
    end process;

end Behavioral;
