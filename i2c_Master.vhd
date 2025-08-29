library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library UNISIM;
use UNISIM.vcomponents.all;

entity I2C_Master is
  generic (
    clock_frequency    : integer := 100_000_000;
    required_delay_us  : real    := 2.5;
    required_hold_us   : real    := 5.0;
    required_hold_us2  : real    := 10.0
  );
Port ( 
    clk           : in  std_logic;
    rst           : in  std_logic;
    i2c_start     : in  std_logic := '0';
    i2c_done      : out std_logic := '0';
    scl_in        : in  std_logic;
    address       : in  std_logic_vector(6 downto 0);
ack_received : out std_logic ; -- for debug 
rx_data_debug : out std_logic_vector(7 downto 0);
    reg_addr      : in  std_logic_vector(7 downto 0);
    reg_data      : in  std_logic_vector(7 downto 0);
    address2       : in  std_logic_vector(6 downto 0);
    address3       : in  std_logic_vector(6 downto 0);
    -- Temperature calibration register addresses
    dig_T1_1_addr : in  std_logic_vector(7 downto 0);
    dig_T1_2_addr : in  std_logic_vector(7 downto 0);
    dig_T2_1_addr : in  std_logic_vector(7 downto 0);
    dig_T2_2_addr : in  std_logic_vector(7 downto 0);
    dig_T3_1_addr : in  std_logic_vector(7 downto 0);
    dig_T3_2_addr : in  std_logic_vector(7 downto 0);

    -- Pressure calibration register addresses
    dig_P1_1_addr : in  std_logic_vector(7 downto 0);
    dig_P1_2_addr : in  std_logic_vector(7 downto 0);
    dig_P2_1_addr : in  std_logic_vector(7 downto 0);
    dig_P2_2_addr : in  std_logic_vector(7 downto 0);
    dig_P3_1_addr : in  std_logic_vector(7 downto 0);
    dig_P3_2_addr : in  std_logic_vector(7 downto 0);
    dig_P4_1_addr : in  std_logic_vector(7 downto 0);
    dig_P4_2_addr : in  std_logic_vector(7 downto 0);
    dig_P5_1_addr : in  std_logic_vector(7 downto 0);
    dig_P5_2_addr : in  std_logic_vector(7 downto 0);
    dig_P6_1_addr : in  std_logic_vector(7 downto 0);
    dig_P6_2_addr : in  std_logic_vector(7 downto 0);
    dig_P7_1_addr : in  std_logic_vector(7 downto 0);
    dig_P7_2_addr : in  std_logic_vector(7 downto 0);
    dig_P8_1_addr : in  std_logic_vector(7 downto 0);
    dig_P8_2_addr : in  std_logic_vector(7 downto 0);
    dig_P9_1_addr : in  std_logic_vector(7 downto 0);
    dig_P9_2_addr : in  std_logic_vector(7 downto 0);

    -- Humidity calibration register addresses
    dig_H1_addr   : in  std_logic_vector(7 downto 0);
    dig_H2_1_addr : in  std_logic_vector(7 downto 0);
    dig_H2_2_addr : in  std_logic_vector(7 downto 0);
    dig_H3_addr   : in  std_logic_vector(7 downto 0);
    dig_H4_1_addr : in std_logic_vector(7 downto 0);  -- from 0xE4
 dig_H4_2_addr :in  std_logic_vector(7 downto 0);  -- from 0xE5 (shared)
 dig_H5_1_addr : in std_logic_vector(7 downto 0);  -- from 0xE5 (shared)
 dig_H5_2_addr :in  std_logic_vector(7 downto 0);  -- from 0xE6

    dig_H6_addr   : in  std_logic_vector(7 downto 0);

    -- Outputs for calibration values
    dig_T1_1_out  : out std_logic_vector(7 downto 0);
    dig_T1_2_out  : out std_logic_vector(7 downto 0);
    dig_T2_1_out  : out std_logic_vector(7 downto 0);
    dig_T2_2_out  : out std_logic_vector(7 downto 0);
    dig_T3_1_out  : out std_logic_vector(7 downto 0);
    dig_T3_2_out  : out std_logic_vector(7 downto 0);

    dig_P1_1_out  : out std_logic_vector(7 downto 0);
    dig_P1_2_out  : out std_logic_vector(7 downto 0);
    dig_P2_1_out  : out std_logic_vector(7 downto 0);
    dig_P2_2_out  : out std_logic_vector(7 downto 0);
    dig_P3_1_out  : out std_logic_vector(7 downto 0);
    dig_P3_2_out  : out std_logic_vector(7 downto 0);
    dig_P4_1_out  : out std_logic_vector(7 downto 0);
    dig_P4_2_out  : out std_logic_vector(7 downto 0);
    dig_P5_1_out  : out std_logic_vector(7 downto 0);
    dig_P5_2_out  : out std_logic_vector(7 downto 0);
    dig_P6_1_out  : out std_logic_vector(7 downto 0);
    dig_P6_2_out  : out std_logic_vector(7 downto 0);
    dig_P7_1_out  : out std_logic_vector(7 downto 0);
    dig_P7_2_out  : out std_logic_vector(7 downto 0);
    dig_P8_1_out  : out std_logic_vector(7 downto 0);
    dig_P8_2_out  : out std_logic_vector(7 downto 0);
    dig_P9_1_out  : out std_logic_vector(7 downto 0);
    dig_P9_2_out  : out std_logic_vector(7 downto 0);

    dig_H1_out    : out std_logic_vector(7 downto 0);
    dig_H2_1_out  : out std_logic_vector(7 downto 0);
    dig_H2_2_out  : out std_logic_vector(7 downto 0);
    dig_H3_out    : out std_logic_vector(7 downto 0);
    dig_H4_1_out    : out std_logic_vector(7 downto 0);
    dig_H4_2_out    : out std_logic_vector(7 downto 0);
    dig_H5_1_out    : out std_logic_vector(7 downto 0);
    dig_H5_2_out    : out std_logic_vector(7 downto 0);
    dig_H6_out    : out std_logic_vector(7 downto 0);

    -- Raw sensor register address inputs
    REG_TEMP_MSB_addr  : in std_logic_vector(7 downto 0);
    REG_TEMP_LSB_addr  : in std_logic_vector(7 downto 0);
    REG_TEMP_XSB_addr  : in std_logic_vector(7 downto 0);
    REG_PRESS_MSB_addr : in std_logic_vector(7 downto 0);
    REG_PRESS_LSB_addr : in std_logic_vector(7 downto 0);
    REG_PRESS_XSB_addr : in std_logic_vector(7 downto 0);
    REG_HUM_MSB_addr   : in std_logic_vector(7 downto 0);
    REG_HUM_LSB_addr   : in std_logic_vector(7 downto 0);

    -- Raw sensor data outputs
    RAW_Temp_MSB       : out std_logic_vector(7 downto 0);
    RAW_Temp_LSB       : out std_logic_vector(7 downto 0);
    RAW_Temp_XSB       : out std_logic_vector(7 downto 0);
    RAW_Press_MSB      : out std_logic_vector(7 downto 0);
    RAW_Press_LSB      : out std_logic_vector(7 downto 0);
    RAW_Press_XSB      : out std_logic_vector(7 downto 0);
    RAW_Hum_MSB        : out std_logic_vector(7 downto 0);
    RAW_Hum_LSB        : out std_logic_vector(7 downto 0);

    -- I2C communication
    read_byte_count    : in  integer;
    rx_data_output     : out std_logic_vector(47 downto 0);
    sda_out            : out std_logic;
    sda_in             : in  std_logic;
    sda_en             : out std_logic
);

end I2C_Master;
-- =====================================================================
-- Architecture: rtl of I2C_Master
-- Purpose: Tidy layout + explanatory comments ONLY (no logic changes)
-- =====================================================================
architecture rtl of I2C_Master is

  -- -------------------------------------------------------------------
  -- Timing constants derived from generics (clock_frequency, delays)
  -- -------------------------------------------------------------------
  constant delay_cycles : integer := integer((real(clock_frequency) / 1_000_000.0) * required_delay_us);
  constant hold_cycles  : integer := integer((real(clock_frequency) / 1_000_000.0) * required_hold_us);
  constant hold_cycles2 : integer := integer((real(clock_frequency) / 1_000_000.0) * required_hold_us2);

  -- -------------------------------------------------------------------
  -- FSM state encoding for three I2C phases: write ctrl, write addr, read
  -- (Names retained; only grouped and commented.)
  -- -------------------------------------------------------------------
  type state_type is (
    -- Phase 1: Write <address, reg_addr, data>
    idle1, wait_before_start, start, wait_after_start,
    send_address, hold_address, wait_ack_address, ack_address,
    send_regaddr, hold_regaddr, wait_ack_regaddr, ack_regaddr,
    send_data, hold_data, wait_ack_data, ack_data,
    idle_stop, wait_before_stop, stop, wait_after_stop, done1

    -- Phase 2: Burst write of register addresses only (setup for read)
     ,idle2, wait_before_start2, start2, wait_after_start2,
    send_address2, hold_address2, wait_ack_address2, ack_address2,
    send_regaddr2, hold_regaddr2, wait_ack_regaddr2, ack_regaddr2,
        idle_stop2, wait_before_stop2, stop2, wait_after_stop2, done2 ,

    -- Phase 3: Read bytes (looped over reg_addr table)
  idle3, wait_before_start3, start3, wait_after_start3,
    send_address3, hold_address3, wait_ack_address3, ack_address3,
         read_bit, read_hold, wait_ack_mstr, read_done,
        idle_stop3, wait_before_stop3, stop3, wait_after_stop3, done3 
  );

-------------------------------------------------------------------------  
  -- Tables for register addresses to read and receive buffers
-------------------------------------------------------------------------  
  type reg_addrs_type is array (0 to 40) of std_logic_vector(7 downto 0);
  type reg_data_type  is array (0 to 40) of std_logic_vector(7 downto 0);

  signal reg_addr_tbl : reg_addrs_type := (
    x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00",
    x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00",
    x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00",
    x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00",
    x"00"
  );

  signal rx_reg_data : reg_data_type := (
    x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00",
    x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00",
    x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00",
    x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00",
    x"00"
  );

-------------------------------------------------------------------------
  -- Misc. internal control and data path registers
-------------------------------------------------------------------------
  signal scl_prev          : std_logic := '0';                 -- Edge detect for SCL
  signal state, next_state : state_type := idle1;              -- FSM state regs
  signal sda_out_reg       : std_logic := '1';                 -- SDA output bit
  signal sda_en_reg        : std_logic := '0';                 -- SDA output enable
  signal counter           : integer := 0;                     -- Generic wait counter
  signal bit_counter       : integer range 0 to 7 := 0;        -- Bit index (MSB first)
  signal BME280_addr      : std_logic_vector(7 downto 0) := (others => '0');  -- Address+W
  signal BME280_REG_CTRL_MEAS      : std_logic_vector(7 downto 0) := (others => '0');  -- Reg addr
  signal normal_mod      : std_logic_vector(7 downto 0) := (others => '0');  -- Data byte
  
  signal tx_address        : std_logic_vector(7 downto 0) := (others => '0');  -- Phase 2 addr
  signal tx_address_read   : std_logic_vector(7 downto 0) := (others => '0');  -- Phase 3 addr (R)
  signal i2c_done_sig      : std_logic := '0';                                   -- Done flag
  
  signal ack_received_reg  : std_logic := '0';                 -- Latched ACK/NACK
  signal rx_bit_counter    : integer := 0;                     -- Bit index for RX
  signal read_ack          : std_logic := '1';                 -- Master ACK bit to slave
  signal rx_buffer         : std_logic_vector(47 downto 0) := (others => '0');  -- Spare
  signal loop_counter      : integer range 0 to 40 := 0;       -- Index over reg_addr22

begin

  -- ===================================================================
  -- Sequential process: state register, counters, data movers, samplers
  -- ===================================================================
  process(clk)
  begin
    if rising_edge(clk) then
      scl_prev <= scl_in;  -- SCL edge memory for RX sampling

      if rst = '0' then
        -- --------------------------
        -- Synchronous reset of regs
        -- --------------------------
        state           <= idle1;
        counter         <= 0;
        bit_counter     <= 0;
        rx_bit_counter  <= 0;
        BME280_addr    <= (others => '0');
        BME280_REG_CTRL_MEAS    <= (others => '0');
        normal_mod    <= (others => '0');
        
        tx_address      <= (others => '0');
        tx_address_read <= (others => '0');
        reg_addr_tbl      <= (others => (others => '0'));
        rx_reg_data     <= (others => (others => '0'));
        loop_counter    <= 0;
        read_ack        <= '1';

      else
        -- ----------------------------------------
        -- Advance the FSM state on each clock
        -- ----------------------------------------
        state <= next_state;

        -- ----------------------------------------
        -- One-time init when entering idle1 (phase 1 setup)
        -- ----------------------------------------
        if state = idle1 then
          BME280_addr <= address & '0';  -- 7-bit addr + W
          BME280_REG_CTRL_MEAS <= reg_addr;       -- register address
          normal_mod <= reg_data;       -- data to write
        ------------------------------------  
          tx_address <= address2 & '0';   -- phase 2 write address

          -- Assign all register addresses to reg_addr_tbl in correct order 
          reg_addr_tbl(0)  <= dig_T1_1_addr;
          reg_addr_tbl(1)  <= dig_T1_2_addr;
          reg_addr_tbl(2)  <= dig_T2_1_addr;
          reg_addr_tbl(3)  <= dig_T2_2_addr;
          reg_addr_tbl(4)  <= dig_T3_1_addr;
          reg_addr_tbl(5)  <= dig_T3_2_addr;

          reg_addr_tbl(6)  <= dig_P1_1_addr;
          reg_addr_tbl(7)  <= dig_P1_2_addr;
          reg_addr_tbl(8)  <= dig_P2_1_addr;
          reg_addr_tbl(9)  <= dig_P2_2_addr;
          reg_addr_tbl(10) <= dig_P3_1_addr;
          reg_addr_tbl(11) <= dig_P3_2_addr;
          reg_addr_tbl(12) <= dig_P4_1_addr;
          reg_addr_tbl(13) <= dig_P4_2_addr;
          reg_addr_tbl(14) <= dig_P5_1_addr;
          reg_addr_tbl(15) <= dig_P5_2_addr;
          reg_addr_tbl(16) <= dig_P6_1_addr;
          reg_addr_tbl(17) <= dig_P6_2_addr;
          reg_addr_tbl(18) <= dig_P7_1_addr;
          reg_addr_tbl(19) <= dig_P7_2_addr;
          reg_addr_tbl(20) <= dig_P8_1_addr;
          reg_addr_tbl(21) <= dig_P8_2_addr;
          reg_addr_tbl(22) <= dig_P9_1_addr;
          reg_addr_tbl(23) <= dig_P9_2_addr;

          reg_addr_tbl(24) <= dig_H1_addr;
          reg_addr_tbl(25) <= dig_H2_1_addr;
          reg_addr_tbl(26) <= dig_H2_2_addr;
          reg_addr_tbl(27) <= dig_H3_addr;
          reg_addr_tbl(28) <= dig_H4_1_addr;
          reg_addr_tbl(29) <= dig_H4_2_addr;
          reg_addr_tbl(30) <= dig_H5_1_addr;
          reg_addr_tbl(31) <= dig_H5_2_addr;
          reg_addr_tbl(32) <= dig_H6_addr;

          -- Raw temperature register addresses
          reg_addr_tbl(33) <= REG_TEMP_MSB_addr;
          reg_addr_tbl(34) <= REG_TEMP_LSB_addr;
          reg_addr_tbl(35) <= REG_TEMP_XSB_addr;

          -- Raw pressure register addresses
          reg_addr_tbl(36) <= REG_PRESS_MSB_addr;
          reg_addr_tbl(37) <= REG_PRESS_LSB_addr;
          reg_addr_tbl(38) <= REG_PRESS_XSB_addr;

          -- Raw humidity register addresses
          reg_addr_tbl(39) <= REG_HUM_MSB_addr;
          reg_addr_tbl(40) <= REG_HUM_LSB_addr;

          tx_address_read <= address3 & '1';  -- phase 3 read address
        ---------------------------------------------
        end if;

        -- ----------------------------------------
        -- Bit sampling during read (on SCL rising edge)
        -- ----------------------------------------
        if state = read_bit then
          if scl_prev = '0' and scl_in = '1' then
            rx_reg_data(loop_counter)(7 - rx_bit_counter) <= sda_in;

            if rx_bit_counter < 7 then
              rx_bit_counter <= rx_bit_counter + 1;
            else
              rx_bit_counter <= 0;
            end if;
          end if;
        end if;

      end if; -- rst

      -- ----------------------------------------
      -- Shared counter/bit-counter updates by state class
      -- ----------------------------------------
      case state is
        when wait_before_start | wait_before_stop | wait_before_start2 | wait_before_stop2 | wait_before_start3 | wait_before_stop3 =>
          counter <= counter + 1;
          if counter = delay_cycles - 1 then counter <= 0; end if;

        when wait_after_start | wait_after_stop | wait_after_start2 | wait_after_stop2 | wait_after_start3 | wait_after_stop3 =>
          counter <= counter + 1;
          if counter = hold_cycles - 1 then counter <= 0; end if;

        when hold_address | hold_regaddr | hold_data | hold_address2 | hold_regaddr2 | hold_address3 =>
          counter <= counter + 1;
          if counter = hold_cycles2 - 1 then
            counter <= 0;
            if bit_counter < 7 then
              bit_counter <= bit_counter + 1;
            end if;
          end if;

        when wait_ack_address | wait_ack_regaddr | wait_ack_data | wait_ack_mstr | wait_ack_address2 | wait_ack_regaddr2 | wait_ack_address3 =>
          counter <= counter + 1;
          if counter = hold_cycles2 - 1 then counter <= 0; end if;

        when ack_regaddr | ack_data | ack_address | ack_regaddr2 | ack_address2 | ack_address3 =>
          if scl_in = '0' then bit_counter <= 0; end if;

        when read_hold =>
          counter <= counter + 1;
          if counter = hold_cycles2 - 1 then
            counter <= 0;
            if rx_bit_counter < 7 then
              rx_bit_counter <= rx_bit_counter + 1;
            end if;
          end if;

        when done3 =>
          bit_counter     <= 0;
          rx_bit_counter  <= 0;
          counter         <= 0;
          BME280_addr    <= (others => '0');
          BME280_REG_CTRL_MEAS    <= (others => '0');
          normal_mod    <= (others => '0');
          read_ack        <= '1';
          loop_counter    <= loop_counter + 1;
          if loop_counter = 40 then
            loop_counter <= 0;
          end if;
        when others => null;
      end case;

      -- ----------------------------------------
      -- Sample ACK on SCL rising edge during ACK wait windows
      -- ----------------------------------------
      if (state = wait_ack_address or state = wait_ack_regaddr or state = wait_ack_data or state = wait_ack_mstr)
         and scl_prev = '0' and scl_in = '1' then
        ack_received_reg <= not sda_in;
      end if;

    end if; -- rising_edge
  end process;

  -- ===================================================================
  -- Combinational process: next-state and SDA control (no storage)
  -- ===================================================================
  process(state, scl_in, counter, bit_counter, loop_counter, rx_bit_counter)
  begin
    next_state  <= state;     -- default stay
    sda_out_reg <= '1';       -- default SDA high (pulled up)
    sda_en_reg  <= '0';       -- default Hi-Z
        
    case state is

      -- =====================
      -- Phase 1: Write cycle
      -- =====================
      when idle1 =>
        if scl_in = '1' and i2c_start = '1' then
          next_state <= wait_before_start;
        end if;

      when wait_before_start =>
        sda_en_reg  <= '1';
        sda_out_reg <= '1';
        if counter = delay_cycles - 1 then next_state <= start; end if;

      when start =>
        sda_en_reg  <= '1';
        sda_out_reg <= '0';
        if scl_in = '1' then next_state <= wait_after_start; end if;

      when wait_after_start =>
        sda_en_reg  <= '1';
        sda_out_reg <= '0';
        if counter = hold_cycles - 1 then
          next_state <= send_address;
        end if;

      when send_address =>
        if scl_in = '0' then
          sda_en_reg  <= '1';
          sda_out_reg <= BME280_addr(7 - bit_counter);
          next_state  <= hold_address;
        end if;

      when hold_address =>
        sda_en_reg  <= '1';
        sda_out_reg <= BME280_addr(7 - bit_counter);
        if counter = hold_cycles2 - 1 then
          if bit_counter = 7 then
            next_state <= wait_ack_address;
          else
            next_state <= send_address;
          end if;
        end if;

      when wait_ack_address =>
        sda_en_reg <= '0';
        if counter = hold_cycles2 - 1 then
          next_state <= ack_address;
        end if;

      when ack_address =>
        if scl_in = '0' then
            next_state <= send_regaddr;
          else
            next_state <= ack_address;
          end if;

      when send_regaddr =>
        if scl_in = '0' then
          sda_en_reg  <= '1';
          sda_out_reg <= BME280_REG_CTRL_MEAS(7 - bit_counter);
          next_state  <= hold_regaddr;
        end if;

      when hold_regaddr =>
        sda_en_reg  <= '1';
        sda_out_reg <= BME280_REG_CTRL_MEAS(7 - bit_counter);
        if counter = hold_cycles2 - 1 then
          if bit_counter = 7 then
            next_state <= wait_ack_regaddr;
          else
            next_state <= send_regaddr;
          end if;
        end if;

      when wait_ack_regaddr =>
        sda_en_reg <= '0';
        if counter = hold_cycles2 - 1 then
          next_state <= ack_regaddr;
        end if;

      when ack_regaddr =>
        if scl_in = '0' then
            next_state <= send_data;
          else
            next_state <= ack_regaddr;
          end if;

      when send_data =>
        if scl_in = '0' then
          sda_en_reg  <= '1';
          sda_out_reg <= normal_mod(7 - bit_counter);
          next_state  <= hold_data;
        end if;

      when hold_data =>
        sda_en_reg  <= '1';
        sda_out_reg <= normal_mod(7 - bit_counter);
        if counter = hold_cycles2 - 1 then
          if bit_counter = 7 then
            next_state <= wait_ack_data;
          else
            next_state <= send_data;
          end if;
        end if;

      when wait_ack_data =>
        sda_en_reg <= '0';
        if counter = hold_cycles2 - 1 then
          next_state <= ack_data;
        end if;

      when ack_data =>
        if scl_in = '0' then
          next_state <= idle_stop;
        end if;
   
      when idle_stop =>
        sda_en_reg <= '0';
        if scl_in = '1' then
          next_state <= wait_before_stop;
        end if;

      when wait_before_stop =>
        sda_en_reg  <= '1';
        sda_out_reg <= '0';
        if counter = delay_cycles - 1 then next_state <= stop; end if;

      when stop =>
        sda_en_reg  <= '1';
        sda_out_reg <= '1';
        if scl_in = '1' then next_state <= wait_after_stop; end if;

      when wait_after_stop =>
        sda_en_reg  <= '1';
        sda_out_reg <= '1';
        if counter = hold_cycles - 1 then next_state <= done1; end if;

      when done1 =>
        next_state <= idle2;

      -- =====================
      -- Phase 2: Address push
      -- =====================
      when idle2 =>
        if scl_in = '1'  then
          next_state <= wait_before_start2;
        end if;

      when wait_before_start2 =>
        sda_en_reg  <= '1';  -- drive SDA
        sda_out_reg <= '1';
        if counter = delay_cycles - 1 then next_state <= start2; end if;

      when start2 =>
        sda_en_reg  <= '1';
        sda_out_reg <= '0';
        if scl_in = '1' then next_state <= wait_after_start2; end if;

      when wait_after_start2 =>
        sda_en_reg  <= '1';
        sda_out_reg <= '0';
        if counter = hold_cycles - 1 then
          next_state <= send_address2;
        end if;

      when send_address2 =>
        if scl_in = '0' then
          sda_en_reg  <= '1';
          sda_out_reg <= tx_address(7 - bit_counter);
          next_state  <= hold_address2;
        end if;

      when hold_address2 =>
        sda_en_reg  <= '1';
        sda_out_reg <= tx_address(7 - bit_counter);
        if counter = hold_cycles2 - 1 then
          if bit_counter = 7 then
            next_state <= wait_ack_address2;
          else
            next_state <= send_address2;
          end if;
        end if;

      when wait_ack_address2 =>
        sda_en_reg <= '0';
        if counter = hold_cycles2 - 1 then
          next_state <= ack_address2;
        end if;

      when ack_address2 =>
        if scl_in = '0' then
            next_state <= send_regaddr2;
          else
            next_state <= ack_address2;
          end if;

      when send_regaddr2 =>
        if scl_in = '0' then
          sda_en_reg  <= '1';
          sda_out_reg <= reg_addr_tbl(loop_counter)(7 - bit_counter);
          next_state  <= hold_regaddr2;
        end if;

      when hold_regaddr2 =>
        sda_en_reg  <= '1';
        sda_out_reg <= reg_addr_tbl(loop_counter)(7 - bit_counter);
        if counter = hold_cycles2 - 1 then
          if bit_counter = 7 then
            next_state <= wait_ack_regaddr2;
          else
            next_state <= send_regaddr2;
          end if;
        end if;

      when wait_ack_regaddr2 =>
        sda_en_reg <= '0';
        if counter = hold_cycles2 - 1 then
          next_state <= ack_regaddr2;
        end if;

      when ack_regaddr2 =>
        if scl_in = '0' then
          next_state <= idle_stop2;
        else
          next_state <= ack_regaddr2;
        end if;

      when idle_stop2 =>
        sda_en_reg <= '0';
        if scl_in = '1' then
          next_state <= wait_before_stop2;
        end if;

      when wait_before_stop2 =>
        sda_en_reg  <= '1';
        sda_out_reg <= '0';
        if counter = delay_cycles - 1 then next_state <= stop2; end if;

      when stop2 =>
        sda_en_reg  <= '1';
        sda_out_reg <= '1';
        if scl_in = '1' then next_state <= wait_after_stop2; end if;

      when wait_after_stop2 =>
        sda_en_reg  <= '1';
        sda_out_reg <= '1';
        if counter = hold_cycles - 1 then next_state <= done2; end if;

      when done2 =>
        next_state <= idle3;
        
      -- =====================
      -- Phase 3: Read cycle
      -- =====================
      when idle3 =>
        if scl_in = '1' then
          next_state <= wait_before_start3;
        end if;

      when wait_before_start3 =>
        sda_en_reg  <= '1';
        sda_out_reg <= '1';
        if counter = delay_cycles - 1 then next_state <= start3; end if;

      when start3 =>
        sda_en_reg  <= '1';
        sda_out_reg <= '0';
        if scl_in = '1' then next_state <= wait_after_start3; end if;

      when wait_after_start3 =>
        sda_en_reg  <= '1';
        sda_out_reg <= '0';
        if counter = hold_cycles - 1 then
          next_state <= send_address3;
        end if;

      when send_address3 =>
        if scl_in = '0' then
          sda_en_reg  <= '1';
          sda_out_reg <= tx_address_read(7 - bit_counter);
          next_state  <= hold_address3;
        end if;

      when hold_address3 =>
        sda_en_reg  <= '1';
        sda_out_reg <= tx_address_read(7 - bit_counter);
        if counter = hold_cycles2 - 1 then
          if bit_counter = 7 then
            next_state <= wait_ack_address3;
          else
            next_state <= send_address3;
          end if;
        end if;

      when wait_ack_address3 =>
        sda_en_reg <= '0';
        if counter = hold_cycles2 - 1 then
          next_state <= ack_address3;
        end if;

      when ack_address3 =>
        if scl_in = '0' then
          next_state <= read_bit;
        end if;

      when read_bit =>
        if scl_prev = '0' and scl_in = '1' then
          if rx_bit_counter = 7 then
            next_state <= wait_ack_mstr;
          end if;
        end if;

      when wait_ack_mstr =>
        sda_out_reg <= read_ack;  -- Master drives ACK/NACK
        sda_en_reg  <= '1';
        if counter = hold_cycles2 - 1 then
          next_state <= read_done;
        end if;

      when read_done =>
        if scl_in = '0' then
          next_state <= idle_stop3;
        end if;

      when idle_stop3 =>
        sda_en_reg <= '0';
        if scl_in = '1' then
          next_state <= wait_before_stop3;
        end if;

      when wait_before_stop3 =>
        sda_en_reg  <= '1';
        sda_out_reg <= '0';
        if counter = delay_cycles - 1 then next_state <= stop3; end if;

      when stop3 =>
        sda_en_reg  <= '1';
        sda_out_reg <= '1';
        if scl_in = '1' then next_state <= wait_after_stop3; end if;

      when wait_after_stop3 =>
        sda_en_reg  <= '1';
        sda_out_reg <= '1';
        if counter = hold_cycles - 1 then next_state <= done3; end if;

      when done3 =>
        if loop_counter = 40 then
          next_state   <= idle1;     
          i2c_done_sig <= '1';
        else
          next_state   <= idle2;     
        end if;

      when others =>
        next_state <= idle1;        

    end case;
  end process;

  -- ===================================================================
  -- Output mappings
  -- ===================================================================
  sda_out      <= sda_out_reg;
  sda_en       <= sda_en_reg;
  ack_received <= ack_received_reg;
  i2c_done     <= i2c_done_sig;

  -- Temperature calibration
  dig_T1_1_out <= rx_reg_data(0);
  dig_T1_2_out <= rx_reg_data(1);
  dig_T2_1_out <= rx_reg_data(2);
  dig_T2_2_out <= rx_reg_data(3);
  dig_T3_1_out <= rx_reg_data(4);
  dig_T3_2_out <= rx_reg_data(5);

  -- Pressure calibration
  dig_P1_1_out <= rx_reg_data(6);
  dig_P1_2_out <= rx_reg_data(7);
  dig_P2_1_out <= rx_reg_data(8);
  dig_P2_2_out <= rx_reg_data(9);
  dig_P3_1_out <= rx_reg_data(10);
  dig_P3_2_out <= rx_reg_data(11);
  dig_P4_1_out <= rx_reg_data(12);
  dig_P4_2_out <= rx_reg_data(13);
  dig_P5_1_out <= rx_reg_data(14);
  dig_P5_2_out <= rx_reg_data(15);
  dig_P6_1_out <= rx_reg_data(16);
  dig_P6_2_out <= rx_reg_data(17);
  dig_P7_1_out <= rx_reg_data(18);
  dig_P7_2_out <= rx_reg_data(19);
  dig_P8_1_out <= rx_reg_data(20);
  dig_P8_2_out <= rx_reg_data(21);
  dig_P9_1_out <= rx_reg_data(22);
  dig_P9_2_out <= rx_reg_data(23);

  -- Humidity calibration
  dig_H1_out   <= rx_reg_data(24);
  dig_H2_1_out <= rx_reg_data(25);
  dig_H2_2_out <= rx_reg_data(26);
  dig_H3_out   <= rx_reg_data(27);
  dig_H4_1_out <= rx_reg_data(28);
  dig_H4_2_out <= rx_reg_data(29);
  dig_H5_1_out <= rx_reg_data(30);
  dig_H5_2_out <= rx_reg_data(31);
  dig_H6_out   <= rx_reg_data(32);

  -- Raw temperature
  RAW_Temp_MSB <= rx_reg_data(33);
  RAW_Temp_LSB <= rx_reg_data(34);
  RAW_Temp_XSB <= rx_reg_data(35);

  -- Raw pressure
  RAW_Press_MSB <= rx_reg_data(36);
  RAW_Press_LSB <= rx_reg_data(37);
  RAW_Press_XSB <= rx_reg_data(38);

  -- Raw humidity
  RAW_Hum_MSB <= rx_reg_data(39);
  RAW_Hum_LSB <= rx_reg_data(40);
ack_received <= ack_received_reg; 
rx_data_debug <= rx_reg_data(1);
end rtl;

