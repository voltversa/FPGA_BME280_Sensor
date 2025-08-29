----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 21.07.2025 22:02:54
-- Design Name: 
-- Module Name: clock_en - rtl
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


entity clock_en is
generic(
clock_frequency : integer := 100000000;
required_frequency : real := 1.0
);
Port ( 
  clk : in std_logic;
  CHIP_EN :  out std_logic
  );
end clock_en;

architecture rtl of clock_en is
constant X : integer :=integer(real (clock_frequency)/required_frequency) ;
signal counter : integer:=0 ;
begin
process (clk)
begin 
if rising_edge(clk) then
if counter = x -1 then
CHIP_EN <='1' ;
counter <= 0;
else
CHIP_EN<='0';
counter<= counter+1;
end if;
end if; 
end process;



end rtl;
