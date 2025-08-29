----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 14.07.2025 19:15:32
-- Design Name: 
-- Module Name: i2c_clk_gen - rtl
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
Library UNISIM;
use UNISIM.vcomponents.all;

--  <-----Cut code below this line and paste into the architecture body---->

   -- IOBUF: Single-ended Bi-directional Buffer
   --        Artix-7
   -- Xilinx HDL Language Template, version 2024.1

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity i2c_clk_gen is
 Port (
        clk     : in  std_logic;
        rst     : in  std_logic;

        scl     : out std_logic
 
  );
end i2c_clk_gen;

architecture rtl of i2c_clk_gen is
    constant  DIVISOR : integer := 500;  -- for 100 MHz sys clk -> 100 kHz SCL
    signal counter   : integer range 0 to DIVISOR := 0;
    signal scl_reg   : std_logic := '1';
begin
process(clk, rst)
    begin
        if rst = '0' then
            counter  <= 0;
            scl_reg  <= '1';
        elsif rising_edge(clk) then
            if counter = DIVISOR - 1 then
                counter <= 0;
                scl_reg <= not scl_reg;
            else
                counter <= counter + 1;
            end if;
        end if;
    end process;

    scl <= scl_reg;


end rtl;
