library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library std;
use std.textio.all;

entity pwm_generator_tb is
end entity;

architecture rtl of pwm_generator_tb is
  constant T_CLK : time := 10 ns;

  signal rst        : std_logic;
  signal clk        : std_logic := '0';
  signal period     : std_logic_vector(23 downto 0);
  signal duty_cycle : std_logic_vector(23 downto 0);
  signal en_pwm     : std_logic;
  signal deadtime   : std_logic_vector(15 downto 0);
  signal dir_in     : std_logic;
  signal en_dt      : std_logic;
  signal pwm_out    : std_logic;
  signal dir        : std_logic;
begin

  DUT : entity work.pwm_generator_simple
    port map (
      rst => rst,
      clk => clk,
      period => period,
      duty_cycle => duty_cycle,
      en_pwm => en_pwm,
      deadtime => deadtime,
      dir_in => dir_in,
      en_dt => en_dt,
      pwm_out => pwm_out,
      dir => dir);

  clk <= not(clk) after T_CLK/2;

  main: process
    procedure gap(N_cycles : in integer := 0) is
    begin
      for i in 1 to N_cycles loop
        wait until (clk'event and clk = '1');
      end loop;
    end gap;
    -- T_pwm = Tclk*2*N
    -- N = T_pwm/(2*TCLK)

    procedure set_period (T_pwm_us : in integer) is
      variable N : integer;
    begin
      N := ((T_pwm_us*1000)/10)-1;
      period <= std_logic_vector(to_unsigned(N, 24));
    end set_period;

    -- t_on = 2*D*Tclk
    -- dc = t_on / T_pwm = (2*D*Tclk)/(Tclk*2*N)=D/N
    -- D = dc*N
    -- D = (dc_pc*N)/100

    procedure set_duty_cycle (
      T_pwm_us : in integer;
      duty_cycle_pc : in integer range 0 to 100)
    is
      variable N : integer;
      variable D : integer;
    begin
      N := ((T_pwm_us*1000)/10)-1;
      D := (duty_cycle_pc*(N+1))/100;
      duty_cycle <= std_logic_vector(to_unsigned(D, 24));
    end set_duty_cycle;
    
    procedure set_deadtime (
      T_deadtime_us : in integer)
    is
      variable dt : integer;
    begin
      dt := ((T_deadtime_us*1000)/10)-1;
      deadtime <= std_logic_vector(to_unsigned(dt, 16));
    end set_deadtime;

  begin
    rst <= '1';
    dir_in <= '1';
    en_pwm <= '1';
    en_dt <= '1';
    set_period(100);
    set_duty_cycle(100, 50);
    set_deadtime(50);
    gap(4);
    rst <= '0';
    gap(1);

    gap(500300);
    set_duty_cycle(100,75);
    gap(200000);
    set_period(200);
    set_duty_cycle(200,75);
    gap(200000);
    set_period(100);
    set_duty_cycle(100,75);
    gap(250000);
    dir_in <= '0'; 
    report "End of simulation";
    wait;

  end process;

end rtl;
