library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library UNISIM;
use UNISIM.vcomponents.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity top is
  Port (
  -- SIMULATION ONLY: expose internals -- 

--   ack_received_debug: out std_logic;
    RsTx : out STD_LOGIC;
    sda  : inout std_logic;
    scl  : out std_logic;
    clk  : in std_logic;
    seg : out std_logic_vector(6 downto 0);
    an    : out std_logic_vector(3 downto 0) ; -- 4 anode signals
    sw : in std_logic_vector (2 downto 1);
    dp : out std_logic;
    rst  : in std_logic
  );
end top;

architecture struct of top is
  signal sda_i, sda_o, sda_t : std_logic;
  signal scl_itermed         : std_logic;
  signal sda_t_n             : std_logic;

  constant bme280_addr_7bit      : std_logic_vector(6 downto 0) := "1110110"; -- 0x76
  constant BME280_REG_CTRL_MEAS : std_logic_vector(7 downto 0) := x"F4";
  constant normal_mod            : std_logic_vector(7 downto 0) := x"27";
  -------------------------------------------------------------------------------------------
  constant dig_T1_1_addr   : std_logic_vector(7 downto 0) := x"88";
  constant dig_T1_2_addr   : std_logic_vector(7 downto 0) := x"89";
  constant dig_T2_1_addr   : std_logic_vector(7 downto 0) := x"8A";
  constant dig_T2_2_addr   : std_logic_vector(7 downto 0) := x"8B";
  constant dig_T3_1_addr   : std_logic_vector(7 downto 0) := x"8C";
  constant dig_T3_2_addr   : std_logic_vector(7 downto 0) := x"8D";
-------------------------------------------------------------------------------------  
constant dig_P1_1_addr : std_logic_vector(7 downto 0) := x"8E";
constant dig_P1_2_addr : std_logic_vector(7 downto 0) := x"8F";
constant dig_P2_1_addr : std_logic_vector(7 downto 0) := x"90";
constant dig_P2_2_addr : std_logic_vector(7 downto 0) := x"91";
constant dig_P3_1_addr : std_logic_vector(7 downto 0) := x"92";
constant dig_P3_2_addr : std_logic_vector(7 downto 0) := x"93";
constant dig_P4_1_addr : std_logic_vector(7 downto 0) := x"94";
constant dig_P4_2_addr : std_logic_vector(7 downto 0) := x"95";
constant dig_P5_1_addr : std_logic_vector(7 downto 0) := x"96";
constant dig_P5_2_addr : std_logic_vector(7 downto 0) := x"97";
constant dig_P6_1_addr : std_logic_vector(7 downto 0) := x"98";
constant dig_P6_2_addr : std_logic_vector(7 downto 0) := x"99";
constant dig_P7_1_addr : std_logic_vector(7 downto 0) := x"9A";
constant dig_P7_2_addr : std_logic_vector(7 downto 0) := x"9B";
constant dig_P8_1_addr : std_logic_vector(7 downto 0) := x"9C";
constant dig_P8_2_addr : std_logic_vector(7 downto 0) := x"9D";
constant dig_P9_1_addr : std_logic_vector(7 downto 0) := x"9E";
constant dig_P9_2_addr : std_logic_vector(7 downto 0) := x"9F";
------------------------------------------------------------------------
constant dig_H1_addr    : std_logic_vector(7 downto 0) := x"A1";
constant dig_H2_1_addr  : std_logic_vector(7 downto 0) := x"E1";
constant dig_H2_2_addr  : std_logic_vector(7 downto 0) := x"E2";
constant dig_H3_addr    : std_logic_vector(7 downto 0) := x"E3";
constant dig_H4_1_addr  : std_logic_vector(7 downto 0) := x"E4"; -- bits [11:4]
constant dig_H4_2_addr  : std_logic_vector(7 downto 0) := x"E5"; -- bits [3:0] shared with H5
constant dig_H5_1_addr  : std_logic_vector(7 downto 0) := x"E5"; -- bits [7:4] shared with H4
constant dig_H5_2_addr  : std_logic_vector(7 downto 0) := x"E6"; -- bits [11:8]
constant dig_H6_addr    : std_logic_vector(7 downto 0) := x"E7";
------------------------------------------------------------------------
constant REG_HUM_MSB_addr     : std_logic_vector(7 downto 0) := x"FD";
constant REG_HUM_LSB_addr     : std_logic_vector(7 downto 0) := x"FE";
------------------------------------------------------------------------
constant REG_TEMP_MSB_addr   : std_logic_vector(7 downto 0) := x"FA";
constant REG_TEMP_LSB_addr   : std_logic_vector(7 downto 0) := x"FB";
constant REG_TEMP_xSB_addr   : std_logic_vector(7 downto 0) := x"FC";
------------------------------------------------------------------------
constant REG_PRESS_MSB_addr   : std_logic_vector(7 downto 0) := x"F7";
constant REG_PRESS_LSB_addr   : std_logic_vector(7 downto 0) := x"F8";
constant REG_PRESS_XSB_addr   : std_logic_vector(7 downto 0) := x"F9";
-----------------------------------------------------------------------
-- Each register is 16-bit (8-bit MSB + 8-bit LSB)
signal dig_P1_1_DATA : std_logic_vector(7 downto 0);
signal dig_P1_2_DATA : std_logic_vector(7 downto 0);
signal dig_P2_1_DATA : std_logic_vector(7 downto 0);
signal dig_P2_2_DATA : std_logic_vector(7 downto 0);
signal dig_P3_1_DATA : std_logic_vector(7 downto 0);
signal dig_P3_2_DATA : std_logic_vector(7 downto 0);
signal dig_P4_1_DATA : std_logic_vector(7 downto 0);
signal dig_P4_2_DATA : std_logic_vector(7 downto 0);
signal dig_P5_1_DATA : std_logic_vector(7 downto 0);
signal dig_P5_2_DATA : std_logic_vector(7 downto 0);
signal dig_P6_1_DATA : std_logic_vector(7 downto 0);
signal dig_P6_2_DATA : std_logic_vector(7 downto 0);
signal dig_P7_1_DATA : std_logic_vector(7 downto 0);
signal dig_P7_2_DATA : std_logic_vector(7 downto 0);
signal dig_P8_1_DATA : std_logic_vector(7 downto 0);
signal dig_P8_2_DATA : std_logic_vector(7 downto 0);
signal dig_P9_1_DATA : std_logic_vector(7 downto 0);
signal dig_P9_2_DATA : std_logic_vector(7 downto 0);
-----------------------------------------------------------------------------------------
  signal dig_T1_1_DATA     : std_logic_vector(7 downto 0);
  signal dig_T1_2_DATA     : std_logic_vector(7 downto 0);
  signal dig_T2_1_DATA     : std_logic_vector(7 downto 0);
  signal dig_T2_2_DATA     : std_logic_vector(7 downto 0);
  signal dig_T3_1_DATA     : std_logic_vector(7 downto 0);
  signal dig_T3_2_DATA     : std_logic_vector(7 downto 0);
----------------------------------------------------------------------------------------------
-- H1 is 8-bit, H2 is 16-bit, H3 is 8-bit, H4 & H5 are split across registers, H6 is 8-bit signed
signal dig_H1_DATA    : std_logic_vector(7 downto 0);
signal dig_H2_1_DATA  : std_logic_vector(7 downto 0);
signal dig_H2_2_DATA  : std_logic_vector(7 downto 0);
signal dig_H3_DATA    : std_logic_vector(7 downto 0);
signal dig_H4_2_DATA    : std_logic_vector(7 downto 0);
signal dig_H4_1_DATA    : std_logic_vector(7 downto 0);
signal dig_H5_1_DATA    : std_logic_vector(7 downto 0);
signal dig_H5_2_DATA    : std_logic_vector(7 downto 0);
signal dig_H6_DATA    : std_logic_vector(7 downto 0);
-------------------------------------------------------------------------------
  signal ack_received     : std_logic;
  signal rx_data          : std_logic_vector(47 downto 0);
  signal BD_CLK           : std_logic;
  signal uart_TX_END      : std_logic;
  signal uart_TX_PIN      : std_logic;
  signal uart_TX_START    : std_logic := '0';
  signal uart_TX_DATA     : std_logic_vector(7 downto 0);
 --------------------------------------------------------------------------------------------- 
  signal RAW_Temp_MSB     : std_logic_vector(7 downto 0);
  signal RAW_Temp_LSB     : std_logic_vector(7 downto 0);
  signal RAW_Temp_XSB     : std_logic_vector(7 downto 0);
  
signal RAW_Temp_init : std_logic_vector(19 downto 0);
signal RAW_Press_init : std_logic_vector(19 downto 0);
signal RAW_Hum_init : std_logic_vector(15 downto 0);

signal RAW_Press_MSB, RAW_Press_LSB, RAW_Press_XSB : std_logic_vector(7 downto 0);
signal RAW_Hum_MSB, RAW_Hum_LSB : std_logic_vector(7 downto 0);
signal RAW_Press_all : std_logic_vector(19 downto 0);  -- Combined pressure raw data
signal RAW_Hum_all : std_logic_vector(15 downto 0);  -- Combined humidity raw data
signal RAW_Temp_all : std_logic_vector(19 downto 0); 
signal dig_P1_init  : std_logic_vector(15 downto 0);  
signal dig_P2_init  : std_logic_vector(15 downto 0);  
signal dig_P3_init  : std_logic_vector(15 downto 0);  
signal dig_P4_init  : std_logic_vector(15 downto 0);  
signal dig_P5_init  : std_logic_vector(15 downto 0);  
signal dig_P6_init  : std_logic_vector(15 downto 0);  
signal dig_P7_init  : std_logic_vector(15 downto 0);  
signal dig_P8_init  : std_logic_vector(15 downto 0);  
signal dig_P9_init  : std_logic_vector(15 downto 0); 
signal dig_H4_init, dig_H5_init: std_logic_vector(11 downto 0);
signal dig_H2_init : std_logic_vector(15 downto 0); 
-------------------------------------------------------------------------------
signal dig_T1_all : unsigned(15 downto 0);
signal dig_T2_all : signed(15 downto 0);
signal dig_T3_all : signed(15 downto 0);
---------------------------------------------------------------
-- Pressure calibration: P1 is unsigned, rest are signed
signal dig_P1_all : unsigned(15 downto 0);
signal dig_P2_all : signed(15 downto 0);
signal dig_P3_all : signed(15 downto 0);
signal dig_P4_all : signed(15 downto 0);
signal dig_P5_all : signed(15 downto 0);
signal dig_P6_all : signed(15 downto 0);
signal dig_P7_all : signed(15 downto 0);
signal dig_P8_all : signed(15 downto 0);
signal dig_P9_all : signed(15 downto 0);
---------------------------------------------------------------------------------------------
-- Humidity calibration (H1-H6)
signal dig_H1_all : unsigned(7 downto 0);       -- 8-bit
signal dig_H2_all : signed(15 downto 0);        -- 16-bit
signal dig_H3_all : unsigned(7 downto 0);       -- 8-bit
signal dig_H4_all : signed(11 downto 0); -- Match 12-bit
signal dig_H5_all : signed(11 downto 0); -- Match 12-bit
signal dig_H6_all : signed(7 downto 0);         -- 8-bit signed
---------------------------------------------------------------------------------------------
  signal start_i2c        : std_logic := '0';
  signal i2c_done         : std_logic;
  signal read_byte_count  : integer := 8;
--------------------------------------------------------------------------------------------
  signal char_index       : integer range 0 to 200 := 0;
  signal tx_busy          : std_logic := '0';
  signal t_fine          : integer  ;
  signal delay_counter    : integer range 0 to 100_000_000 := 0;
-------------------------------------------------------------
type phase_type is (config, read_calib);
signal phase : phase_type := config;
signal start_pulse_sent : std_logic := '0';
signal dig_T1_init : std_logic_vector(15 downto 0);
signal dig_T2_init : std_logic_vector(15 downto 0);
signal dig_T3_init : std_logic_vector(15 downto 0);
signal binary_out : std_logic_vector(15 downto 0);
signal humidity_out  : std_logic_vector(15 downto 0);
signal pressure_out  : std_logic_vector(31 downto 0);
signal bcd_in : std_logic_vector(15 downto 0) := (others => '0');
-----------------------------------------------------------------------------
 -- =============================================================
-- Step 1: Types and message buffer declaration
-- =============================================================
  type message_array is array(0 to 200) of std_logic_vector(7 downto 0);
  signal message : message_array := (
    x"54", x"65", x"6D", x"70", x"3A", x"20",
    others => x"00"
  );

-- =============================================================
-- Step 2: FSM state type and reset state
-- =============================================================
  type state_type is (
    idle, start_i2c_cmd, wait_i2c_done, wait_comp_done,
    prepare_uart, send_uart, wait_delay
  );
  signal state : state_type := idle;

-- =============================================================
-- Step 3:  function to convert a 4-bit nibble to ASCII
-- =============================================================
function nibble_to_ascii(nibble: std_logic_vector(3 downto 0)) return std_logic_vector is
begin
  case nibble is
    when "0000" => return x"30"; -- '0'
    when "0001" => return x"31"; -- '1'
    when "0010" => return x"32";
    when "0011" => return x"33";
    when "0100" => return x"34";
    when "0101" => return x"35";
    when "0110" => return x"36";
    when "0111" => return x"37";
    when "1000" => return x"38";
    when "1001" => return x"39";
    when "1010" => return x"41"; -- 'A'
    when "1011" => return x"42";
    when "1100" => return x"43";
    when "1101" => return x"44";
    when "1110" => return x"45";
    when "1111" => return x"46";
    when others => return x"3F"; -- '?'
  end case;
end function;

-- =============================================================
-- Step 4: I2C SDA tri-state and buffer instantiation
-- =============================================================
begin
  sda_t_n <= not sda_t;  -- Active-low tri-state control for IOBUF

  iobuf_inst : IOBUF
    port map (
      IO => sda,
      I  => sda_o,
      O  => sda_i,
      T  => sda_t_n
    );

-- =============================================================
-- Step 5: I2C SCL generator instance and wiring
-- =============================================================
  scl_inst : entity work.i2c_clk_gen
    port map (
      clk => clk,
      rst => rst,
      scl => scl_itermed
    );
  scl <= scl_itermed;

-- =============================================================
-- Step 6: I2C master instantiation with all BME280 signals
-- =============================================================
  i2c_master_inst : entity work.I2C_Master
    port map (
      clk      => clk,
      rst      => rst,
      scl_in   => scl_itermed,
      address  => bme280_addr_7bit,
      address2 => bme280_addr_7bit,
      address3 => bme280_addr_7bit,
--rx_data_debug =>rx_data_debug,
      reg_addr => BME280_REG_CTRL_MEAS,
      reg_data => normal_mod,

      -- Temperature calibration
      dig_T1_1_addr => dig_T1_1_addr,
      dig_T1_2_addr => dig_T1_2_addr,
      dig_T2_1_addr => dig_T2_1_addr,
      dig_T2_2_addr => dig_T2_2_addr,
      dig_T3_1_addr => dig_T3_1_addr,
      dig_T3_2_addr => dig_T3_2_addr,

      dig_T1_1_out  => dig_T1_1_DATA,
      dig_T1_2_out  => dig_T1_2_DATA,
      dig_T2_1_out  => dig_T2_1_DATA,
      dig_T2_2_out  => dig_T2_2_DATA,
      dig_T3_1_out  => dig_T3_1_DATA,
      dig_T3_2_out  => dig_T3_2_DATA,

      -- Pressure calibration (dig_P1-dig_P9)
      dig_P1_1_addr => dig_P1_1_addr,
      dig_P1_2_addr => dig_P1_2_addr,
      dig_P2_1_addr => dig_P2_1_addr,
      dig_P2_2_addr => dig_P2_2_addr,
      dig_P3_1_addr => dig_P3_1_addr,
      dig_P3_2_addr => dig_P3_2_addr,
      dig_P4_1_addr => dig_P4_1_addr,
      dig_P4_2_addr => dig_P4_2_addr,
      dig_P5_1_addr => dig_P5_1_addr,
      dig_P5_2_addr => dig_P5_2_addr,
      dig_P6_1_addr => dig_P6_1_addr,
      dig_P6_2_addr => dig_P6_2_addr,
      dig_P7_1_addr => dig_P7_1_addr,
      dig_P7_2_addr => dig_P7_2_addr,
      dig_P8_1_addr => dig_P8_1_addr,
      dig_P8_2_addr => dig_P8_2_addr,
      dig_P9_1_addr => dig_P9_1_addr,
      dig_P9_2_addr => dig_P9_2_addr,

      dig_P1_1_out  => dig_P1_1_DATA,
      dig_P1_2_out  => dig_P1_2_DATA,
      dig_P2_1_out  => dig_P2_1_DATA,
      dig_P2_2_out  => dig_P2_2_DATA,
      dig_P3_1_out  => dig_P3_1_DATA,
      dig_P3_2_out  => dig_P3_2_DATA,
      dig_P4_1_out  => dig_P4_1_DATA,
      dig_P4_2_out  => dig_P4_2_DATA,
      dig_P5_1_out  => dig_P5_1_DATA,
      dig_P5_2_out  => dig_P5_2_DATA,
      dig_P6_1_out  => dig_P6_1_DATA,
      dig_P6_2_out  => dig_P6_2_DATA,
      dig_P7_1_out  => dig_P7_1_DATA,
      dig_P7_2_out  => dig_P7_2_DATA,
      dig_P8_1_out  => dig_P8_1_DATA,
      dig_P8_2_out  => dig_P8_2_DATA,
      dig_P9_1_out  => dig_P9_1_DATA,
      dig_P9_2_out  => dig_P9_2_DATA,

      -- Humidity calibration (dig_H1-dig_H6)
      dig_H1_addr   => dig_H1_addr,
      dig_H2_1_addr => dig_H2_1_addr,
      dig_H2_2_addr => dig_H2_2_addr,
      dig_H3_addr   => dig_H3_addr,
      dig_H4_1_addr => dig_H4_1_addr,
      dig_H4_2_addr => dig_H4_2_addr,
      dig_H5_1_addr => dig_H5_1_addr,
      dig_H5_2_addr => dig_H5_2_addr,
      dig_H6_addr   => dig_H6_addr,

      dig_H1_out    => dig_H1_DATA,
      dig_H2_1_out  => dig_H2_1_DATA,
      dig_H2_2_out  => dig_H2_2_DATA,
      dig_H3_out    => dig_H3_DATA,
      dig_H4_1_out  => dig_H4_1_DATA,
      dig_H4_2_out  => dig_H4_2_DATA,
      dig_H5_1_out  => dig_H5_1_DATA,
      dig_H5_2_out  => dig_H5_2_DATA,
      dig_H6_out    => dig_H6_DATA,

      -- Raw temperature
      REG_TEMP_MSB_addr => REG_TEMP_MSB_addr,
      REG_TEMP_LSB_addr => REG_TEMP_LSB_addr,
      REG_TEMP_xSB_addr => REG_TEMP_xSB_addr,
      RAW_Temp_MSB      => RAW_Temp_MSB,
      RAW_Temp_LSB      => RAW_Temp_LSB,
      RAW_Temp_xSB      => RAW_Temp_XSB,

      -- Raw pressure
      REG_PRESS_MSB_addr => REG_PRESS_MSB_addr,
      REG_PRESS_LSB_addr => REG_PRESS_LSB_addr,
      REG_PRESS_xSB_addr => REG_PRESS_XSB_addr,
      RAW_Press_MSB      => RAW_Press_MSB,
      RAW_Press_LSB      => RAW_Press_LSB,
      RAW_Press_xSB      => RAW_Press_XSB,

      -- Raw humidity
      REG_HUM_MSB_addr => REG_HUM_MSB_addr,
      REG_HUM_LSB_addr => REG_HUM_LSB_addr,
      RAW_Hum_MSB      => RAW_Hum_MSB,
      RAW_Hum_LSB      => RAW_Hum_LSB,

      -- I2C interface
      read_byte_count => 1,
      rx_data_output  => rx_data,
      sda_out         => sda_o,
      sda_in          => sda_i,
      sda_en          => sda_t,
--      ack_received    => ack_received,
      i2c_start       => start_i2c,
      i2c_done        => i2c_done
    );

-- =============================================================
-- Step 7: Temperature compensation block
-- =============================================================
  tmpcomp : entity work.temp_compensation
    port map (
      clk         => clk,
      rst         => rst,
      dig_T1      => dig_T1_all,
      dig_T2      => dig_T2_all,
      dig_T3      => dig_T3_all,
      temp_raw    => raw_temp_all,
      t_fine_out  => t_fine,
      binary_out  => binary_out
    );

-- =============================================================
-- Step 8: Humidity compensation block
-- =============================================================
  humcomp : entity work.humidity_compensation
    port map (
      clk          => clk,
      rst          => rst,
      hum_raw      => RAW_Hum_all,
      t_fine       => t_fine,
      dig_H1       => dig_H1_all,
      dig_H2       => dig_H2_all,
      dig_H3       => dig_H3_all,
      dig_H4       => dig_H4_all,
      dig_H5       => dig_H5_all,
      dig_H6       => dig_H6_all,
      humidity_out => humidity_out  
    );

-- =============================================================
-- Step 9: Pressure compensation block
-- =============================================================
  presscomp : entity work.pressure_compensation
    port map (
      clk          => clk,
      rst          => rst,
      t_fine       => t_fine,
      press_raw    => RAW_Press_all,
      dig_P1       => dig_P1_all,
      dig_P2       => dig_P2_all,
      dig_P3       => dig_P3_all,
      dig_P4       => dig_P4_all,
      dig_P5       => dig_P5_all,
      dig_P6       => dig_P6_all,
      dig_P7       => dig_P7_all,
      dig_P8       => dig_P8_all,
      dig_P9       => dig_P9_all,
      pressure_out => pressure_out  
    );

-- =============================================================
-- Step 10: Baud generator for UART (clock enable @ 9600 bps)
-- =============================================================
  baud_gen : entity work.clock_en
    generic map (
      clock_frequency    => 100_000_000,
      required_frequency => 9600.0
    )
    port map (
      clk     => clk,
      CHIP_EN => BD_CLK
    );

-- =============================================================
-- Step 11: UART transmitter instance
-- =============================================================
  uart_inst : entity work.uart_tx
    port map (
      CLK      => clk,
      nRst     => rst,
      BD_CLK   => BD_CLK,
      STOPBIT2 => false,
      TX_DATA  => uart_TX_DATA,
      TX_START => uart_TX_START,
      TX_END   => uart_TX_END,
      TX_PIN   => uart_TX_PIN
    );

-- =============================================================
-- Step 12: Seven-segment display driver instance
-- =============================================================
  sevseg_inst : entity work.BCD_to_7Segment
    port map (
      CLK     => clk,
      reset_n => rst,
      bcd_in  => bcd_in,
      seg     => seg,
      an      => an,
      dp      => dp
    );

-- =============================================================
-- Step 13: Main control process (I2C sequencing, data packing, UART feed)
--           
-- =============================================================
  process(clk)
    variable temp       : integer := 0;
    variable press      : integer := 0;
    variable hum        : integer := 0;
    variable press_hpa  : integer := 0;
    variable scaled     : integer := 0;
    variable d1, d2, d3, d4, d5, d6 : integer := 0;
    variable h1, h2, h3, h4, h5, h6 : integer := 0;
    variable p1, p2, p3, p4, p5, p6 : integer := 0;
  begin
    if rising_edge(clk) then
      if rst = '0' then
        -- Step 13.1: Synchronous reset of state and control signals
        state            <= idle;
        char_index       <= 0;
        uart_TX_START    <= '0';
        start_i2c        <= '0';
        phase            <= config;
        delay_counter    <= 0;
        start_pulse_sent <= '0';

      else
        -- Step 13.2: FSM next-state logic
        case state is

          when idle =>
            -- Step 13.2.1: Kick off an I2C transaction
            start_i2c <= '1';
            state     <= start_i2c_cmd;

          when start_i2c_cmd =>
            -- Step 13.2.2: De-assert start after one cycle
            start_i2c <= '0';
            state     <= wait_i2c_done;

          when wait_i2c_done =>
            -- Step 13.2.3: Wait until I2C master reports completion
            if i2c_done = '1' then
              if phase = config then
                -- Step 13.2.3.a: After config, proceed to calibration reads
                phase <= read_calib;
                state <= idle;
              else
                -- Step 13.2.3.b: Capture raw/calibration data and cast types

                -- 1. Temperature: 20-bit raw and 16-bit calibration parameters
                RAW_Temp_init <= RAW_Temp_MSB & RAW_Temp_LSB & RAW_Temp_XSB(7 downto 4);  -- [19:0]
                dig_T1_init   <= dig_T1_2_DATA & dig_T1_1_DATA;  -- unsigned 16-bit
                dig_T2_init   <= dig_T2_2_DATA & dig_T2_1_DATA;  -- signed 16-bit
                dig_T3_init   <= dig_T3_2_DATA & dig_T3_1_DATA;  -- signed 16-bit

                -- Convert temperature calibration to appropriate numeric types
                dig_T1_all   <= unsigned(dig_T1_init);
                dig_T2_all   <= signed(dig_T2_init);
                dig_T3_all   <= signed(dig_T3_init);
                RAW_Temp_all <= RAW_Temp_init;

                -- 2. Pressure: 20-bit raw value
                RAW_Press_init <= RAW_Press_MSB & RAW_Press_LSB & RAW_Press_XSB(7 downto 4);
                RAW_Press_all  <= RAW_Press_init;

                -- 3. Humidity: 16-bit raw value
                RAW_Hum_init <= RAW_Hum_MSB & RAW_Hum_LSB;
                RAW_Hum_all  <= RAW_Hum_init;

                -- 4. Pressure Calibration (combine MSB & LSB)
                dig_P1_init <= dig_P1_2_DATA & dig_P1_1_DATA;  
                dig_P2_init <= dig_P2_2_DATA & dig_P2_1_DATA; 
                dig_P3_init <= dig_P3_2_DATA & dig_P3_1_DATA;
                dig_P4_init <= dig_P4_2_DATA & dig_P4_1_DATA;
                dig_P5_init <= dig_P5_2_DATA & dig_P5_1_DATA;
                dig_P6_init <= dig_P6_2_DATA & dig_P6_1_DATA;
                dig_P7_init <= dig_P7_2_DATA & dig_P7_1_DATA;
                dig_P8_init <= dig_P8_2_DATA & dig_P8_1_DATA;
                dig_P9_init <= dig_P9_2_DATA & dig_P9_1_DATA;

                -- Convert to correct types
                dig_P1_all <= unsigned(dig_P1_init);
                dig_P2_all <= signed(dig_P2_init);
                dig_P3_all <= signed(dig_P3_init);
                dig_P4_all <= signed(dig_P4_init);
                dig_P5_all <= signed(dig_P5_init);
                dig_P6_all <= signed(dig_P6_init);
                dig_P7_all <= signed(dig_P7_init);
                dig_P8_all <= signed(dig_P8_init);
                dig_P9_all <= signed(dig_P9_init);

                -- 5. Humidity Calibration
                dig_H2_init <= dig_H2_2_DATA & dig_H2_1_DATA;
                -- Correct H4 = E4[7:0] << 4 | (E5[3:0])
                dig_H4_init <= dig_H4_1_DATA & dig_H4_2_DATA(3 downto 0);  
                -- Correct H5 = E5[7:4] << 4 | E6[7:0]
                dig_H5_init <= dig_H5_1_DATA(7 downto 4) & dig_H5_2_DATA;  

                -- Type casting for humidity calibration 
                dig_H1_all <= unsigned(dig_h1_DATA);  -- 8-bit unsigned
                dig_H2_all <= signed(dig_H2_init);    -- 16-bit signed
                dig_H4_all <= signed(dig_H4_init);    -- 12-bit signed
                dig_H5_all <= signed(dig_H5_init);    -- 12-bit signed
                dig_H6_all <= signed(dig_h6_DATA);    -- 8-bit signed

                state <= wait_comp_done;
              end if;
            end if;

          when wait_comp_done =>
            -- Step 13.2.4: Build human-readable message buffer (Temp / Press / Hum)

            -- Temperature (binary_out is °C ×100)
            temp := to_integer(unsigned(binary_out));

            -- ================= TEMPERATURE =================
            message(0)  <= x"54"; -- 'T'
            message(1)  <= x"65"; -- 'e'
            message(2)  <= x"6D"; -- 'm'
            message(3)  <= x"70"; -- 'p'
            message(4)  <= x"3A"; -- ':'
            message(5)  <= x"20"; -- ' '

            d1 := (temp / 1000) mod 10;
            d2 := (temp / 100) mod 10;
            d3 := (temp / 10)  mod 10;
            d4 :=  temp        mod 10;

            message(6)  <= nibble_to_ascii(std_logic_vector(to_unsigned(d1, 4)));
            message(7)  <= nibble_to_ascii(std_logic_vector(to_unsigned(d2, 4)));
            message(8)  <= x"2E"; -- '.'
            message(9)  <= nibble_to_ascii(std_logic_vector(to_unsigned(d3, 4)));
            message(10) <= nibble_to_ascii(std_logic_vector(to_unsigned(d4, 4)));
            message(11) <= x"43"; -- 'C'
            message(12) <= x"0D"; -- CR
            message(13) <= x"0A"; -- LF

            -- ================= PRESSURE =================
            -- Pressure in Pa -> hPa with 1 decimal digit
            press     := to_integer(unsigned(pressure_out));
            press_hpa := press / 10;

            p1 := (press_hpa / 1000) mod 10;
            p2 := (press_hpa / 100) mod 10;
            p3 := (press_hpa / 10)  mod 10;
            p4 :=  press_hpa       mod 10;

            message(14) <= x"50"; -- 'P'
            message(15) <= x"72"; -- 'r'
            message(16) <= x"65"; -- 'e'
            message(17) <= x"73"; -- 's'
            message(18) <= x"73"; -- 's'
            message(19) <= x"3A"; -- ':'
            message(20) <= x"20"; -- ' '

            message(21) <= nibble_to_ascii(std_logic_vector(to_unsigned(p1, 4)));
            message(22) <= nibble_to_ascii(std_logic_vector(to_unsigned(p2, 4)));
            message(23) <= nibble_to_ascii(std_logic_vector(to_unsigned(p3, 4)));
            message(24) <= x"2E"; -- '.'
            message(25) <= nibble_to_ascii(std_logic_vector(to_unsigned(p4, 4)));

            message(26) <= x"68"; -- 'h'
            message(27) <= x"50"; -- 'P'
            message(28) <= x"61"; -- 'a'
            message(29) <= x"0D";
            message(30) <= x"0A";

            -- ================= HUMIDITY =================
            hum    := to_integer(unsigned(humidity_out));
            scaled := hum * 1;  -- turn into hundredths of %RH

            h1 := (scaled / 10000) mod 10;  -- tens
            h2 := (scaled / 1000) mod 10;   -- ones
            h3 := (scaled / 100)  mod 10;   -- .1
            h4 := (scaled / 10)   mod 10;   -- .01

            message(31) <= x"48"; -- 'H'
            message(32) <= x"75"; -- 'u'
            message(33) <= x"6D"; -- 'm'
            message(34) <= x"3A"; -- ':'
            message(35) <= x"20"; -- ' '

            message(36) <= nibble_to_ascii(std_logic_vector(to_unsigned(h1, 4)));
            message(37) <= nibble_to_ascii(std_logic_vector(to_unsigned(h2, 4)));
            message(38) <= x"2E";  -- '.'
            message(39) <= nibble_to_ascii(std_logic_vector(to_unsigned(h3, 4)));
            message(40) <= nibble_to_ascii(std_logic_vector(to_unsigned(h4, 4)));
            message(41) <= x"25"; -- '%'
            message(42) <= x"52"; -- 'R'
            message(43) <= x"48"; -- 'H'
            message(44) <= x"0D";
            message(45) <= x"0A";

            -- Start UART output
            char_index <= 0;
            state      <= prepare_uart;

          when prepare_uart =>
            -- Step 13.2.5: Load next byte and start UART transmission
            uart_TX_DATA     <= message(char_index);
            uart_TX_START    <= '1';
            start_pulse_sent <= '1';
            state            <= send_uart;

          when send_uart =>
            -- Step 13.2.6: Manage TX_START pulse width and advance on TX_END
            if start_pulse_sent = '1' then
              if uart_TX_END = '0' then
                uart_TX_START    <= '0';
                start_pulse_sent <= '0';
              end if;
            else
              if uart_TX_END = '1' then
                if char_index < 200 then
                  char_index <= char_index + 1;
                  state      <= prepare_uart;
                else
                  delay_counter <= 0;
                  state         <= wait_delay;
                end if;
              end if;
            end if;

          when wait_delay =>
            -- Step 13.2.7: Optional inter-message delay (currently bypassed)
            -- if delay_counter < 100_000_000 then
            --   delay_counter <= delay_counter + 1;
            -- else
                state <= idle;
            -- end if;

        end case;
      end if;
    end if;
  end process;

-- =============================================================
-- Step 14: Display-selection process for 7-seg (Temp/Press/Hum)
-- =============================================================
  process(clk)
    variable value      : integer;
    variable d1, d2, d3 : integer;
    variable unit_digit : std_logic_vector(3 downto 0);
  begin
    if rising_edge(clk) then

      -- Select what to display
      if sw(2) = '1' then
        value      := to_integer(unsigned(humidity_out));  -- Humidity
        unit_digit := "1111";  -- Custom code for '%'
      elsif sw(1) = '1' then
        value      := to_integer(unsigned(pressure_out));  -- Pressure
        unit_digit := "1010";  -- Custom code for 'h' (e.g., hPa)
      else
        value      := to_integer(unsigned(binary_out));    -- Temperature
        unit_digit := "1100";  -- Code for 'C'
      end if;

      -- Extract digits (only 3 digits + unit symbol)
      if value >= 1000 then
        d1 := (value / 1000) mod 10;
        d2 := (value / 100)  mod 10;
        d3 := (value / 10)   mod 10;
      else
        d1 := 0;
        d2 := (value / 100) mod 10;
        d3 := (value / 10)  mod 10;
      end if;

      -- Build BCD bus: digit1 digit2 digit3 unit_symbol
      bcd_in <= std_logic_vector(to_unsigned(d1, 4)) &
                std_logic_vector(to_unsigned(d2, 4)) &
                std_logic_vector(to_unsigned(d3, 4)) &
                unit_digit;

    end if;
  end process;

-- =============================================================
-- Step 15: UART TX pin routing to top-level output
-- =============================================================
  RsTx <= uart_TX_PIN;

-- =============================================================
-- End of structured architecture 
-- =============================================================
end struct;
