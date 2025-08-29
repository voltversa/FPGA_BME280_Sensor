library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity I2C_Master_tb is
end I2C_Master_tb;

architecture sim of I2C_Master_tb is
  -- Clocks & reset
  signal clk_tb   : std_logic := '0';   -- 100 MHz
  signal rst_tb   : std_logic := '0';   -- ACTIVE-LOW reset
  signal scl_tb   : std_logic := '0';   -- 100 kHz SCL

  -- Open-drain SDA modeling
  signal sda_tb          : std_logic := 'Z';
  signal sda_in_tb       : std_logic;
  signal sda_out_tb      : std_logic;
  signal sda_en_tb       : std_logic;
  signal sda_slave_drive : std_logic := 'Z';  -- TB pulls low to ACK

  -- DUT control/observe
  signal i2c_start_tb    : std_logic := '0';
  signal i2c_done_tb     : std_logic;

  -- Unused but required ports
  signal rx_dbg          : std_logic_vector(47 downto 0);

  -- BME280 constants for Phase-1 write F4:=27 to 0x76
  constant BME280_ADDR7         : std_logic_vector(6 downto 0) := "1110110"; -- 0x76
  constant BME280_REG_CTRL_MEAS : std_logic_vector(7 downto 0) := x"F4";
  constant NORMAL_MODE          : std_logic_vector(7 downto 0) := x"27";

  -- Fillers for unused address ports (DUT requires them)
  constant dig_T1_1_addr : std_logic_vector(7 downto 0) := x"88";
  constant dig_T1_2_addr : std_logic_vector(7 downto 0) := x"89";
  constant dig_T2_1_addr : std_logic_vector(7 downto 0) := x"8A";
  constant dig_T2_2_addr : std_logic_vector(7 downto 0) := x"8B";
  constant dig_T3_1_addr : std_logic_vector(7 downto 0) := x"8C";
  constant dig_T3_2_addr : std_logic_vector(7 downto 0) := x"8D";
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
  constant dig_H1_addr   : std_logic_vector(7 downto 0) := x"A1";
  constant dig_H2_1_addr : std_logic_vector(7 downto 0) := x"E1";
  constant dig_H2_2_addr : std_logic_vector(7 downto 0) := x"E2";
  constant dig_H3_addr   : std_logic_vector(7 downto 0) := x"E3";
  constant dig_H4_1_addr : std_logic_vector(7 downto 0) := x"E4";
  constant dig_H4_2_addr : std_logic_vector(7 downto 0) := x"E5";
  constant dig_H5_1_addr : std_logic_vector(7 downto 0) := x"E5";
  constant dig_H5_2_addr : std_logic_vector(7 downto 0) := x"E6";
  constant dig_H6_addr   : std_logic_vector(7 downto 0) := x"E7";
  constant REG_PRESS_MSB_addr : std_logic_vector(7 downto 0) := x"F7";
  constant REG_PRESS_LSB_addr : std_logic_vector(7 downto 0) := x"F8";
  constant REG_PRESS_XSB_addr : std_logic_vector(7 downto 0) := x"F9";
  constant REG_TEMP_MSB_addr  : std_logic_vector(7 downto 0) := x"FA";
  constant REG_TEMP_LSB_addr  : std_logic_vector(7 downto 0) := x"FB";
  constant REG_TEMP_XSB_addr  : std_logic_vector(7 downto 0) := x"FC";
  constant REG_HUM_MSB_addr   : std_logic_vector(7 downto 0) := x"FD";
  constant REG_HUM_LSB_addr   : std_logic_vector(7 downto 0) := x"FE";

begin
  ----------------------------------------------------------------------------
  -- DUT
  ----------------------------------------------------------------------------
  DUT: entity work.I2C_Master
    generic map (
      clock_frequency   => 100_000_000,
      required_delay_us => 2.5,
      required_hold_us  => 5.0,
      required_hold_us2 => 10.0
    )
    port map (
      clk           => clk_tb,
      rst           => rst_tb,         -- ACTIVE-LOW in RTL
      i2c_start     => i2c_start_tb,
      i2c_done      => i2c_done_tb,
      scl_in        => scl_tb,

      address       => BME280_ADDR7,
      reg_addr      => BME280_REG_CTRL_MEAS,
      reg_data      => NORMAL_MODE,
      address2      => BME280_ADDR7,
      address3      => BME280_ADDR7,

      -- (Not used in phase 1 but required)
      dig_T1_1_addr => dig_T1_1_addr,  dig_T1_2_addr => dig_T1_2_addr,
      dig_T2_1_addr => dig_T2_1_addr,  dig_T2_2_addr => dig_T2_2_addr,
      dig_T3_1_addr => dig_T3_1_addr,  dig_T3_2_addr => dig_T3_2_addr,
      dig_P1_1_addr => dig_P1_1_addr,  dig_P1_2_addr => dig_P1_2_addr,
      dig_P2_1_addr => dig_P2_1_addr,  dig_P2_2_addr => dig_P2_2_addr,
      dig_P3_1_addr => dig_P3_1_addr,  dig_P3_2_addr => dig_P3_2_addr,
      dig_P4_1_addr => dig_P4_1_addr,  dig_P4_2_addr => dig_P4_2_addr,
      dig_P5_1_addr => dig_P5_1_addr,  dig_P5_2_addr => dig_P5_2_addr,
      dig_P6_1_addr => dig_P6_1_addr,  dig_P6_2_addr => dig_P6_2_addr,
      dig_P7_1_addr => dig_P7_1_addr,  dig_P7_2_addr => dig_P7_2_addr,
      dig_P8_1_addr => dig_P8_1_addr,  dig_P8_2_addr => dig_P8_2_addr,
      dig_P9_1_addr => dig_P9_1_addr,  dig_P9_2_addr => dig_P9_2_addr,
      dig_H1_addr   => dig_H1_addr,
      dig_H2_1_addr => dig_H2_1_addr,  dig_H2_2_addr => dig_H2_2_addr,
      dig_H3_addr   => dig_H3_addr,
      dig_H4_1_addr => dig_H4_1_addr,  dig_H4_2_addr => dig_H4_2_addr,
      dig_H5_1_addr => dig_H5_1_addr,  dig_H5_2_addr => dig_H5_2_addr,
      dig_H6_addr   => dig_H6_addr,
      REG_TEMP_MSB_addr  => REG_TEMP_MSB_addr,
      REG_TEMP_LSB_addr  => REG_TEMP_LSB_addr,
      REG_TEMP_XSB_addr  => REG_TEMP_XSB_addr,
      REG_PRESS_MSB_addr => REG_PRESS_MSB_addr,
      REG_PRESS_LSB_addr => REG_PRESS_LSB_addr,
      REG_PRESS_XSB_addr => REG_PRESS_XSB_addr,
      REG_HUM_MSB_addr   => REG_HUM_MSB_addr,
      REG_HUM_LSB_addr   => REG_HUM_LSB_addr,

      RAW_Temp_MSB  => open, RAW_Temp_LSB  => open, RAW_Temp_XSB  => open,
      RAW_Press_MSB => open, RAW_Press_LSB => open, RAW_Press_XSB => open,
      RAW_Hum_MSB   => open, RAW_Hum_LSB   => open,

      read_byte_count => 1,
      rx_data_output  => rx_dbg,

      sda_out        => sda_out_tb,
      sda_in         => sda_in_tb,
      sda_en         => sda_en_tb
    );

  ----------------------------------------------------------------------------
  -- Open-drain wired-AND on SDA
  ----------------------------------------------------------------------------
  sda_tb    <= '0' when (sda_en_tb = '0' and sda_out_tb = '0') or sda_slave_drive = '0' else 'Z';
  sda_in_tb <= sda_tb;

  ----------------------------------------------------------------------------
  -- 100 MHz system clock
  ----------------------------------------------------------------------------
  clk_gen : process
  begin
    while true loop
      clk_tb <= '0'; wait for 5 ns;
      clk_tb <= '1'; wait for 5 ns;
    end loop;
  end process;

  ----------------------------------------------------------------------------
  -- 100 kHz I2C SCL (10 µs period)
  ----------------------------------------------------------------------------
  scl_gen : process
  begin
    wait for 5 us; scl_tb <= '1';
    wait for 5 us; scl_tb <= '0';
  end process;

  ----------------------------------------------------------------------------
  -- Stimulus: reset, start while SCL high, 3 ACKs (addr/reg/data), detect STOP
  ----------------------------------------------------------------------------
  stim : process
    variable sda_prev : std_logic := '1';
  begin
    -- Active-low reset: hold low then release
    rst_tb <= '0';
    wait for 200 ns;
    rst_tb <= '1';

    -- Wait SCL high, then pulse i2c_start for one CLK
    wait until scl_tb = '1';
    wait until rising_edge(clk_tb);
    i2c_start_tb <= '1';
    wait until rising_edge(clk_tb);
    i2c_start_tb <= '0';

    -- ======== ACK #1: for address byte ========
    -- Wait 8 SCL bit clocks (MSB..LSB)
    for i in 0 to 7 loop
      wait until scl_tb = '1';
      wait until scl_tb = '0';
    end loop;
    -- ACK bit: pull SDA low across SCL high
    sda_slave_drive <= '0';
    wait until scl_tb = '1';
    wait until scl_tb = '0';
    sda_slave_drive <= 'Z';

    -- ======== ACK #2: for register byte (0xF4) ========
    for i in 0 to 7 loop
      wait until scl_tb = '1';
      wait until scl_tb = '0';
    end loop;
    sda_slave_drive <= '0';
    wait until scl_tb = '1';
    wait until scl_tb = '0';
    sda_slave_drive <= 'Z';

    -- ======== ACK #3: for data byte (0x27) ========
    for i in 0 to 7 loop
      wait until scl_tb = '1';
      wait until scl_tb = '0';
    end loop;
    sda_slave_drive <= '0';
    wait until scl_tb = '1';
    wait until scl_tb = '0';
    sda_slave_drive <= 'Z';

    -- ======== Detect STOP (SDA low->high while SCL high) ========
    loop
      sda_prev := sda_tb;
      wait until scl_tb = '1';
      wait for 100 ns;
      exit when (sda_prev = '0' and sda_tb = '1');
      wait until scl_tb = '0';
    end loop;
    report "Phase-1 STOP detected. Ending sim before Phase-2." severity note;

    wait for 20 us;
    assert false report "Simulation finished (Phase 1 only)" severity failure;
  end process;

end sim;
