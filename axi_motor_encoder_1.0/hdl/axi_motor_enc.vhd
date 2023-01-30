
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity axi_motor_enc is
  port(
    clk        : in  std_logic;
    rst        : in  std_logic;
    ch_a       : in  std_logic;
    ch_b       : in  std_logic;
    pos_clr    : in  std_logic;
    mode       : in  std_logic;
    obs_period : in  std_logic_vector(31 downto 0);
    interrupt  : out std_logic;
    speed      : out std_logic_vector(31 downto 0); --speed_reg
    position   : out std_logic_vector(31 downto 0));
end axi_motor_enc;


architecture rtl of axi_motor_enc is
  -- Clean channel signals
  signal prescaler_cnt  : unsigned(15 downto 0);
  signal prescaler_end  : std_logic;
  signal ch_a_reg       : std_logic_vector (3 downto 0);
  signal ch_b_reg       : std_logic_vector (3 downto 0);
  signal all_zeros_a    : std_logic;
  signal all_ones_a     : std_logic;
  signal all_zeros_b    : std_logic;
  signal all_ones_b     : std_logic;
  signal f_ch_a         : std_logic;
  signal f_ch_b         : std_logic;

  -- FSM signals
  signal channel     : std_logic_vector(1 downto 0);
  signal channel_reg : std_logic_vector(1 downto 0);
  signal update      : std_logic;

  signal pos_cnt_clr : std_logic;
  signal pos_cnt_en  : std_logic;
  signal pos_cnt_dir : std_logic;

  -- counter signals
  signal pos_cnt : signed(31 downto 0); --registros para control

  -- period_counter signals
  signal period_cnt   : unsigned(31 downto 0);
  signal period_end   : std_logic;

  --speed_code---
  signal pos_integer : integer;
  signal obs_integer : integer;
  signal speed_integer_aux : integer range 0 to 10000000;
  
begin

  --------------------------------------
  --  PROCESOS PARA LIMPIAR LA SEÑAL  --
  --------------------------------------

  process(clk) -- Prescaler
  begin
    if (clk'event and clk = '1') then
      if (rst = '1' or prescaler_end = '1') then
        prescaler_cnt <= (others => '0');
      else
        prescaler_cnt <= prescaler_cnt + 1;
      end if;
    end if;
  end process;

  prescaler_end <= '1' when (prescaler_cnt = 9) else '0';


  process(clk, rst) -- Channel A
  begin
    if(clk'event and clk='1') then
      if(rst = '1') then
        ch_a_reg <= (others => '0');
      else
        if(prescaler_end = '1') then
          ch_a_reg <= ch_a_reg(2 downto 0) & ch_a;
        end if;
      end if;
    end if;
  end process;

  all_ones_a  <= '1' when (ch_a_reg = "1111") else '0';
  all_zeros_a <= '1' when (ch_a_reg = "0000") else '0';

  process(clk, rst)
  begin
    if(clk'event and clk = '1') then
      if(rst = '1') then
        f_ch_a <= '0';
      else
        if(all_ones_a = '1') then
          f_ch_a <= '1';
        elsif(all_zeros_a = '1') then
          f_ch_a <= '0';
        end if;
      end if;
    end if;
  end process;


process(clk, rst) -- Channel B
  begin
    if(clk'event and clk='1') then
      if(rst = '1') then
        ch_b_reg <= (others => '0');
      else
        if(prescaler_end = '1') then
          ch_b_reg <= ch_b_reg(2 downto 0) & ch_b;
        end if;
      end if;
    end if;
  end process;

  all_ones_b  <= '1' when (ch_b_reg = "1111") else '0';
  all_zeros_b <= '1' when (ch_b_reg = "0000") else '0';

  process(clk, rst)
  begin
    if(clk'event and clk = '1') then
      if(rst = '1') then
        f_ch_b <= '0';
      else
        if(all_ones_b = '1') then
          f_ch_b <= '1';
        elsif(all_zeros_b = '1') then
          f_ch_b <= '0';
        end if;
      end if;
    end if;
  end process;

  channel <= f_ch_a & f_ch_b;

  --------------------------------------
  -- PROCESOS DE LA MAQUINA DE ESTADO --
  --------------------------------------

  process(clk) -- Clean signals register
  begin
    if(clk'event and clk = '1') then
      if(rst = '1') then
        channel_reg <= channel;
      else
        channel_reg <= channel;
      end if;
    end if;
  end process;

  process(channel_reg, channel)  -- FMS
  begin
    pos_cnt_en  <= '0';
    pos_cnt_dir <= '0';

    case channel_reg is
      when "00" =>
        if (channel = "10") then
          pos_cnt_en  <= '1';
          pos_cnt_dir <= '1';
        elsif(channel = "01") then
          pos_cnt_en  <= '1';
          pos_cnt_dir <= '0';
        end if;
      when "10" =>
        if (channel = "11") then
          pos_cnt_en  <= '1';
          pos_cnt_dir <= '1';
        elsif(channel = "00") then
          pos_cnt_en  <= '1';
          pos_cnt_dir <= '0';
        end if;
      when "11" =>
        if (channel = "01") then
          pos_cnt_en  <= '1';
          pos_cnt_dir <= '1';
        elsif(channel = "10") then
          pos_cnt_en  <= '1';
          pos_cnt_dir <= '0';
        end if;
      when "01" =>
        if (channel = "00") then
          pos_cnt_en  <= '1';
          pos_cnt_dir <= '1';
        elsif(channel = "11") then
          pos_cnt_en  <= '1';
          pos_cnt_dir <= '0';
        end if;
      when others => null;
    end case;
  end process;

  process(clk)  -- Period Counter
  begin
    if(clk'event and clk = '1') then
      if(rst = '1' or period_end = '1') then
        period_cnt <= unsigned(obs_period)-1;
      else
        period_cnt <= period_cnt - 1;
      end if;
    end if;
  end process;

  period_end <= '1' when (period_cnt = 0) else '0';

  process(clk)  -- Clear Counter Process
  begin
    if(clk'event and clk = '1') then
      if(rst = '1' or pos_clr = '1') then
        pos_cnt_clr <= '1';
      else
        pos_cnt_clr <= '0';
        update      <= '0';
        if(mode = '1' and period_end = '1') then
          pos_cnt_clr <= '1';
          update      <= '1';
        end if;
      end if;
    end if;
  end process;

  interrupt <= update;  -- Salida interrupt

  --------------------------------------
  -- CONTADOR DE POSICION Y VELOCIDAD --
  --------------------------------------

  process(clk)  -- Counter
  begin
    if(clk'event and clk = '1') then
      if(rst = '1' or pos_cnt_clr = '1') then
        pos_cnt <= (others => '0');
      elsif(pos_cnt_en= '1') then
        if(pos_cnt_dir = '1') then
          pos_cnt <= pos_cnt + 1;
        else
          pos_cnt <= pos_cnt - 1;
        end if;
      end if;
    end if;
  end process;

  position <= std_logic_vector(pos_cnt) ;

  process(clk) -- Speed Registrer
  begin
    if(clk'event and clk = '1') then
      if(rst = '1') then
        speed <= (others => '0'); --
      elsif(update = '1') then
        speed <= std_logic_vector(pos_cnt);
      end if;
    end if;
  end process;

end rtl;
