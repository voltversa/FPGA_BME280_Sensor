library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

entity top_tb is
end entity;

architecture tb of top_tb is
  ---------------------------------------------------------------------------
  -- DUT I/O
  ---------------------------------------------------------------------------
  signal clk_tb  : std_logic := '0';            -- 100 MHz
  signal rst_tb  : std_logic := '0';            -- active-low
  signal scl_tb  : std_logic := '0';            -- from DUT
  signal sda_tb  : std_logic := 'Z';            -- open-drain bus
  signal RsTx_tb : std_logic;                   -- UART TX from DUT
  signal seg_tb  : std_logic_vector(6 downto 0);
  signal an_tb   : std_logic_vector(3 downto 0);
  signal dp_tb   : std_logic;
  signal sw_tb   : std_logic_vector(2 downto 1) := (others => '0');

  ---------------------------------------------------------------------------
  -- I2C slave open-drain drive: '0' pulls SDA low, '1' releases (Hi-Z)
  ---------------------------------------------------------------------------
  signal sda_slave_drive : std_logic := '1';

  ---------------------------------------------------------------------------
  -- BME280-like register space (constrained array to avoid Vivado error)
  ---------------------------------------------------------------------------
  type mem_t is array (0 to 255) of std_logic_vector(7 downto 0);
  signal mem : mem_t := (others => x"00");

  -- 7-bit I2C address used by DUT (0x76 common for BME280). We ACK any addr.
  constant SLAVE_ADDR7 : std_logic_vector(6 downto 0) := "1110110";

  ---------------------------------------------------------------------------
  -- UART monitor setup (9600 8N1)
  ---------------------------------------------------------------------------
  constant BIT_PERIOD : time := 104166 ns;  -- ~1/9600 s

begin
  ----------------------------------------------------------------------------
  -- Instantiate DUT
  ----------------------------------------------------------------------------
  dut: entity work.top
    port map (
      RsTx => RsTx_tb,
      sda  => sda_tb,
      scl  => scl_tb,
      clk  => clk_tb,
      seg  => seg_tb,
      an   => an_tb,
      sw   => sw_tb,
      dp   => dp_tb,
      rst  => rst_tb
    );

  ----------------------------------------------------------------------------
  -- Open-drain bus with weak pull-up on SDA
  --  - Master drives via its IOBUF in 'top'
  --  - Slave pulls low when needed
  --  - Weak pull-up keeps line high when released
  ----------------------------------------------------------------------------
  sda_tb <= 'H';                                  -- weak pull-up
  sda_tb <= '0' when sda_slave_drive = '0' else 'Z';

  ----------------------------------------------------------------------------
  -- 100 MHz clock
  ----------------------------------------------------------------------------
  clk_gen : process
  begin
    clk_tb <= '0'; wait for 5 ns;
    clk_tb <= '1'; wait for 5 ns;
  end process;

  ----------------------------------------------------------------------------
  -- Reset (active-low)
  ----------------------------------------------------------------------------
  reset_proc : process
  begin
    rst_tb <= '0';
    wait for 200 ns;
    rst_tb <= '1';
    wait;
  end process;

  ----------------------------------------------------------------------------
  -- Optional: drive switches to cycle 7-seg view
  ----------------------------------------------------------------------------
  sw_driver : process
  begin
    wait for 5 ms;  sw_tb <= "10";   -- pressure
    wait for 5 ms;  sw_tb <= "01";   -- humidity
    wait for 5 ms;  sw_tb <= "00";   -- temperature
    wait; -- keep running
  end process;

  ----------------------------------------------------------------------------
  -- Initialize BME280-like memory (calibration + raw data)
  -- Adjust if you want specific compensated outputs.
  ----------------------------------------------------------------------------
  init_mem : process
  begin
    -- Temperature calib
    mem(16#88#) <= x"50"; mem(16#89#) <= x"6B";  -- dig_T1 (u16)
    mem(16#8A#) <= x"E5"; mem(16#8B#) <= x"FF";  -- dig_T2 (s16)
    mem(16#8C#) <= x"0C"; mem(16#8D#) <= x"00";  -- dig_T3 (s16)

    -- Pressure calib
    mem(16#8E#) <= x"34"; mem(16#8F#) <= x"C5";  -- dig_P1 (u16)
    mem(16#90#) <= x"F0"; mem(16#91#) <= x"FF";  -- dig_P2 (s16)
    mem(16#92#) <= x"0C"; mem(16#93#) <= x"00";  -- dig_P3 (s16)
    mem(16#94#) <= x"C3"; mem(16#95#) <= x"FE";  -- dig_P4 (s16)
    mem(16#96#) <= x"50"; mem(16#97#) <= x"01";  -- dig_P5 (s16)
    mem(16#98#) <= x"02"; mem(16#99#) <= x"00";  -- dig_P6 (s16)
    mem(16#9A#) <= x"07"; mem(16#9B#) <= x"00";  -- dig_P7 (s16)
    mem(16#9C#) <= x"0F"; mem(16#9D#) <= x"00";  -- dig_P8 (s16)
    mem(16#9E#) <= x"2C"; mem(16#9F#) <= x"FF";  -- dig_P9 (s16)

    -- Humidity calib
    mem(16#A1#) <= x"4B";                         -- dig_H1 (u8)
    mem(16#E1#) <= x"66"; mem(16#E2#) <= x"00";   -- dig_H2 (s16)
    mem(16#E3#) <= x"01";                         -- dig_H3 (u8)
    mem(16#E4#) <= x"33"; mem(16#E5#) <= x"A5";   -- H4/H5 packed nibbles
    mem(16#E6#) <= x"7C";
    mem(16#E7#) <= x"FE";                         -- dig_H6 (s8)

    -- Raw data
    mem(16#F7#) <= x"64"; mem(16#F8#) <= x"23"; mem(16#F9#) <= x"10"; -- press_raw (MSB,LSB,XLSB[7:0])
    mem(16#FA#) <= x"6A"; mem(16#FB#) <= x"BC"; mem(16#FC#) <= x"50"; -- temp_raw  (MSB,LSB,XLSB[7:0])
    mem(16#FD#) <= x"3C"; mem(16#FE#) <= x"80";                        -- hum_raw   (MSB,LSB)

    wait;
  end process;

  ----------------------------------------------------------------------------
  -- Minimal I2C Slave (BME280-like)
  ----------------------------------------------------------------------------
  slave_model : process
    variable addr_byte  : std_logic_vector(7 downto 0);
    variable data_byte  : std_logic_vector(7 downto 0);
    variable rw         : std_logic; -- '0' write, '1' read
    variable reg_ptr    : integer range 0 to 255 := 0;
    variable i          : integer;
    variable master_ack : std_logic;
  begin
    sda_slave_drive <= '1';  -- release

    -- Wait for START: SDA 1->0 while SCL=1
    wait until (scl_tb = '1' and sda_tb'event and sda_tb = '0');

    -- Address + R/W (MSB first on SCL rising edges)
    for i in 7 downto 0 loop
      wait until scl_tb = '1';
      addr_byte(i) := sda_tb;
      wait until scl_tb = '0';
    end loop;
    rw := addr_byte(0); -- LSB = R/W; [7..1] are address (we ACK any)

    -- ACK address
    sda_slave_drive <= '0';
    wait until scl_tb = '1';
    wait until scl_tb = '0';
    sda_slave_drive <= '1';

    if rw = '0' then
      ----------------------------------------------------------------
      -- WRITE: first data byte is register pointer
      ----------------------------------------------------------------
      for i in 7 downto 0 loop
        wait until scl_tb = '1';
        data_byte(i) := sda_tb;
        wait until scl_tb = '0';
      end loop;
      reg_ptr := to_integer(unsigned(data_byte));

      -- ACK reg pointer
      sda_slave_drive <= '0';
      wait until scl_tb = '1';
      wait until scl_tb = '0';
      sda_slave_drive <= '1';

      -- Optionally accept one more data byte (e.g., CTRL_MEAS)
      -- Only if master continues clocking before STOP
      if not (scl_tb = '1' and sda_tb = '1') then
        for i in 7 downto 0 loop
          wait until scl_tb = '1';
          data_byte(i) := sda_tb;
          wait until scl_tb = '0';
        end loop;
        mem(reg_ptr) <= data_byte;

        sda_slave_drive <= '0';
        wait until scl_tb = '1';
        wait until scl_tb = '0';
        sda_slave_drive <= '1';
      end if;

      -- Wait for STOP: SDA 0->1 while SCL=1
      wait until (scl_tb = '1' and sda_tb'event and sda_tb = '1');

    else
      ----------------------------------------------------------------
      -- READ: drive byte(s) from mem(reg_ptr), auto-increment on ACK
      ----------------------------------------------------------------
      data_byte := mem(reg_ptr);

      for i in 7 downto 0 loop
        wait until scl_tb = '0';
        if data_byte(i) = '0' then
          sda_slave_drive <= '0';        -- drive '0'
        else
          sda_slave_drive <= '1';        -- release for '1'
        end if;
        wait until scl_tb = '1';
      end loop;

      -- Release SDA for master's ACK/NACK and sample it
      wait until scl_tb = '0';
      sda_slave_drive <= '1';
      wait until scl_tb = '1';
      master_ack := sda_tb;               -- 0=ACK (more bytes), 1=NACK (last)
      wait until scl_tb = '0';

      if master_ack = '0' then
        reg_ptr := (reg_ptr + 1) mod 256; -- multi-byte read
      end if;

      -- Wait for STOP
      wait until (scl_tb = '1' and sda_tb'event and sda_tb = '1');
    end if;

    -- Loop for next transaction
  end process;

  ----------------------------------------------------------------------------
  -- UART 9600 8N1 monitor: prints ASCII to transcript
  ----------------------------------------------------------------------------
  uart_mon : process
    variable ch     : character;
    variable v_byte : std_logic_vector(7 downto 0);
    variable L      : line;
    variable i      : integer;
  begin
    -- wait for start bit
    wait until (RsTx_tb'event and RsTx_tb = '0');
    wait for BIT_PERIOD/2;  -- mid-start

    -- 8 data bits (LSB first)
    for i in 0 to 7 loop
      wait for BIT_PERIOD;
      v_byte(i) := RsTx_tb;
    end loop;

    -- stop bit
    wait for BIT_PERIOD;

    -- print printable ASCII; newline on LF (0x0A) or CR (0x0D)
    ch := character'val(to_integer(unsigned(v_byte)));
    if (ch >= ' ') and (ch <= '~') then
      write(L, ch);
    elsif (ch = character'val(10)) or (ch = character'val(13)) then
      writeline(output, L);  -- flush line
    end if;

    -- keep monitoring forever
  end process;

  ----------------------------------------------------------------------------
  -- End simulation
  ----------------------------------------------------------------------------
  stop_sim : process
  begin
    wait for 30 ms;
    assert false report "Simulation finished." severity failure;
  end process;

end architecture;
