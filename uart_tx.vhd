----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 21.07.2025 22:04:27
-- Design Name: 
-- Module Name: uart_tx - rtl
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;


-- one Process Mealy machine 
entity uart_tx is
generic(
 clk_freq :integer  := 100_000_000;
 req_frq : real :=10_000_000.0

);
  Port (
  CLK : in STD_LOGIC; 	--Core clock 100MHz
nRst: in STD_LOGIC; 	-- reset active low (no need to put this in your state diagram)
BD_CLK : in STD_LOGIC; 	-- BD_CLK this is the chip enable at the speed of the Baudrate (only 1 CLK cycle high) 
STOPBIT2 : in boolean;	-- if this signal is true then send 2 stop bits otherwise send 1
TX_DATA : in STD_LOGIC_VECTOR (7 downto 0); --this is the data that has to be transmitted.
TX_START : in STD_LOGIC; -- Puls that indicates when the transmission should start. (high during 1 CLK cycle)
TX_END : out STD_LOGIC;	-- High if the UART_TX is not transmitting 
TX_PIN : out STD_LOGIC ;-- This is the output of the UART_TX and can be connected to a physical pin of the fpga
DEBUG_STATE : out std_logic_vector(2 downto 0)  -- 3 bits = 8 states max
   );
end uart_tx;

architecture rtl of uart_tx is
type TxStateType is (
Wait4Start,
Wait4Sync,
SendStartBit,
SendDataBits,
SendStop1,
SendStop2,
Complete
);
    signal state       : TxStateType := Wait4Start;
signal  buff : std_logic_vector( 7 downto 0);
    signal bit_counter : integer range 0 to 7 := 0;
    signal tx_reg      : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal tx_pin_int  : STD_LOGIC := '1';  -- Idle state
    signal tx_end_int  : STD_LOGIC := '1';  -- Not transmitting

begin

process (clk)
begin
if rising_edge (clk)then
if nRST ='0' then
   state <= Wait4Start;
   tx_pin_int  <= '1';
   tx_end_int  <= '1';
   bit_counter <= 0;

   else 
    case state is
    
     when Wait4Start =>
            tx_pin_int <= '1';
            tx_end_int <= '1';
            if TX_START = '1' then
               tx_reg <= TX_DATA;
                state <= Wait4Sync;
                tx_end_int <= '0';
            end if;
            
      when Wait4Sync =>
               if BD_CLK = '1' then
                state <= SendStartBit;
                 end if;
                        
      when SendStartBit =>
            tx_pin_int <= '0';  -- Start bit
            if BD_CLK = '1' then
                bit_counter <= 0;
                state <= SendDataBits;
            end if;
       when SendDataBits =>
            tx_pin_int <= tx_reg(bit_counter);
            if BD_CLK = '1' then
                if bit_counter = 7 then
                    state <= SendStop1;
                else
                    bit_counter <= bit_counter + 1;
                end if;
            end if;
        when SendStop1 =>
            tx_pin_int <= '1';
            if BD_CLK = '1' then
                if STOPBIT2 then
                    state <= SendStop2;
                else
                    state <= Complete;
                end if;
            end if;  
         when SendStop2 =>
                tx_pin_int <= '1';
                if BD_CLK = '1' then
                    state <= Complete;
                end if;
           when Complete =>
                        tx_pin_int <= '1';
                        tx_end_int <= '1';
                        if BD_CLK = '1' then
                            state <= Wait4Start;
                        end if;
               when others =>
                        state <= Wait4Start;
         end case;
        end if;
        end if;          
END process;

  TX_PIN <= tx_pin_int;
    TX_END <= tx_end_int;
DEBUG_STATE <= std_logic_vector(to_unsigned(TxStateType'pos(state), 3));

end rtl;
