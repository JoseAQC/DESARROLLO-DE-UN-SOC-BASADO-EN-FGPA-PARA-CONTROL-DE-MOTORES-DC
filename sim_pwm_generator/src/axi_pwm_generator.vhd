library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pwm_generator_simple is
  port (
    rst             : in  std_logic;
    clk             : in  std_logic;
    period          : in  std_logic_vector(23 downto 0);
    duty_cycle      : in  std_logic_vector(23 downto 0);
    en_pwm          : in  std_logic;
    deadtime        : in  std_logic_vector(15 downto 0);
    dir_in          : in  std_logic;
    en_dt           : in  std_logic;
    pwm_out         : out std_logic;
    dir             : out std_logic);
end entity;

architecture rtl of pwm_generator_simple is
  -- Se?les de modulo de Pwm Generator
  signal carrier         : unsigned(23 downto 0);
  signal duty_cycle_reg  : std_logic_vector(23 downto 0);
  signal period_end      : std_logic;
  signal match           : std_logic;
  
  -- Se?les de modulo de Tiempo Muerto
  signal dt_carrier      : unsigned(15 downto 0);
  signal prev_dir        : std_logic;
  signal start_dt        : std_logic;
  signal dt_enable       : std_logic;
  
  -- Se?l de salida sin tiempos muertos
  signal pwm_in           : std_logic;

begin

  -- PROCESOS DE LA GENERACION DE LA PWM

  process(clk) -- Shadow registrer duty cycle process
  begin
    if(clk'event and clk = '1') then
      if(rst = '1') then
        duty_cycle_reg <= (others => '0');
      elsif(en_pwm = '1') then
        if(period_end = '1') then
          duty_cycle_reg <= duty_cycle;
        end if;
      end if;
    end if;
  end process;

  process(clk)  -- Counter process
  begin
    if (clk'event and clk = '1') then
      if(rst = '1') then
        carrier <= unsigned(period);
      elsif(en_pwm = '1') then
        if(period_end = '1') then
          carrier <= unsigned(period);
        else
          carrier <= carrier - 1;
        end if;
      end if;
    end if;
  end process;

  period_end <= '1' when(carrier = 0) else '0';

  process(clk)  -- Comparator process
  begin
    if(clk'event and clk= '1') then
      if(rst= '1') then
        pwm_in <= '0';
      elsif(en_pwm = '1') then
        if(carrier < unsigned(duty_cycle_reg)) then
          pwm_in <= '1';
        else
          pwm_in <= '0';
        end if;
      end if;
    end if;
  end process;

  match <= '1' when(carrier = unsigned(duty_cycle_reg)) else '0';

  -- PROCESOS DE LA GENERACION DE TIEMPOS MUERTOS

  process(clk)  -- Shadow registrer turn direction process
  begin
    if(clk'event and clk = '1') then
      if(rst = '1') then
        prev_dir <= dir_in;
      elsif (en_dt = '1') then
        if(period_end = '1') then
          prev_dir <= dir_in;
        end if;
      end if;
    end if;
  end process;

  start_dt <= '1' when(not(dir_in = prev_dir) and period_end = '1') else '0';

  process(clk)  -- Mono stable process
  begin
    if(clk'event and clk = '1') then
      if(rst = '1') then
        dt_carrier <= (others => '0');
      elsif(en_dt = '1') then
        if(start_dt = '1') then
          dt_carrier <= unsigned(deadtime);
        elsif(dt_carrier > 0) then
          dt_carrier <= dt_carrier - 1;
        end if;
      end if;
    end if;
  end process;

  dt_enable <= '1' when(dt_carrier > 0) else '0';

  process(clk)  -- Out direction process
  begin
    if(clk'event and clk = '1') then
      if(rst = '1') then
        dir <= prev_dir;
      elsif(en_dt = '1') then
        if (dt_carrier = unsigned(deadtime)/2) then
          dir <= prev_dir;
        end if;
      end if;
    end if;
  end process;
  
  pwm_out <= pwm_in and not(dt_enable);  -- Salida pwm con Tiempos Muertos
   
end rtl;
