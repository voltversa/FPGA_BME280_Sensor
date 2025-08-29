library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity temp_compensation is
Port (

         clk: in std_logic;
         rst      : in  std_logic;
         binary_out : out std_logic_vector(15 downto 0);
      t_fine_out     :  out integer := 0;

          temp_raw : in std_logic_vector(19 downto 0);
           dig_T1          :  in unsigned(15 downto 0);
           dig_T2          :in  signed(15 downto 0);
           dig_T3          : in signed(15 downto 0)

 );
end temp_compensation;
architecture Behavioral of temp_compensation is

  ------------------------------------------------------------------
  -- Internal signals for the compensation math
  ------------------------------------------------------------------
  signal var1       : integer := 0;
  signal var2       : integer := 0;
  signal t_fine     : integer := 0;
  signal temperature: integer := 0;

begin

  ------------------------------------------------------------------
  -- Clocked process: performs compensation math on each rising edge.
  ------------------------------------------------------------------
  process(clk, rst)
    variable adc_T_int  : integer;
    variable dig_T1_int : integer;
    variable dig_T2_int : integer;
    variable dig_T3_int : integer;
    variable tmp        : integer;  -- used locally for partial calculations
  begin
    if rst = '0' then
      -- Synchronous reset of internal signals
      var1        <= 0;
      var2        <= 0;
      t_fine      <= 0;
      temperature <= 0;
      binary_out  <= (others => '0');

    elsif rising_edge(clk) then
      ----------------------------------------------------------------
      -- 1) Convert raw temperature from std_logic_vector to integer
      ----------------------------------------------------------------
      adc_T_int  := to_integer(unsigned(temp_raw));

      ----------------------------------------------------------------
      -- 2) Convert calibration parameters from their types to integer
      ----------------------------------------------------------------
      dig_T1_int := to_integer(dig_T1);
      dig_T2_int := to_integer(dig_T2);
      dig_T3_int := to_integer(dig_T3);

      ----------------------------------------------------------------
      -- 3) Calculate var1
      --    var1 = (((adc_T / 8) - (dig_T1 * 2)) * dig_T2) / 2048
      ----------------------------------------------------------------
      var1 <= (((adc_T_int / 8) - (dig_T1_int * 2)) * dig_T2_int) / 2048;

      ----------------------------------------------------------------
      -- 4) Calculate var2
      --    var2 = ((((adc_T / 16) - dig_T1) * ((adc_T / 16) - dig_T1)) / 4096 ) 
      --           * dig_T3) / 16384
      ----------------------------------------------------------------
      tmp := (adc_T_int / 16) - dig_T1_int;
      var2 <= (((tmp * tmp) / 4096) * dig_T3_int) / 16384;

      ----------------------------------------------------------------
      -- 5) Calculate t_fine
      --    t_fine = var1 + var2
      ----------------------------------------------------------------
      t_fine <= var1 + var2;

      ----------------------------------------------------------------
      -- 6) Calculate temperature in 0.01°C:
      --    temperature = (t_fine * 5 + 128) / 256
      --  i keep to_unsigned() for the final output.
      ----------------------------------------------------------------
      temperature <= (t_fine * 5 + 128) / 256;

      -- Drive the output as an unsigned representation (16 bits).
      binary_out <= std_logic_vector(to_unsigned(temperature, 16));
      t_fine_out<= t_fine;
    end if;
  end process;

end Behavioral;

