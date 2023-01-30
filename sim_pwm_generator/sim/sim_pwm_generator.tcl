# source sim_pwm_generator.tcl

set pwm_generator_simple          /DUT

quit -sim


vsim -voptargs=+acc -t 1ps work.pwm_generator_tb

set NumericStdNoWarnings 1
configure wave -signalnamewidth 1
configure wave -namecolwidth  160
#configure wave -valuecolwidth 100
configure wave -valuecolwidth 150

add wave -noupdate -divider {PWM_GENERATOR}
add wave            $pwm_generator_simple/rst
add wave            $pwm_generator_simple/clk
add wave            $pwm_generator_simple/en_pwm
add wave            $pwm_generator_simple/en_dt

add wave -unsigned  $pwm_generator_simple/period
add wave -unsigned  $pwm_generator_simple/duty_cycle
add wave -unsigned  $pwm_generator_simple/duty_cycle_reg
add wave -unsigned  $pwm_generator_simple/deadtime
add wave            $pwm_generator_simple/carrier
add wave            $pwm_generator_simple/period_end

add wave            $pwm_generator_simple/dir_in
add wave            $pwm_generator_simple/prev_dir
add wave            $pwm_generator_simple/dir

#add wave            $pwm_generator_simple/match
add wave            $pwm_generator_simple/pwm_in
add wave            $pwm_generator_simple/pwm_out
add wave            $pwm_generator_simple/start_dt
add wave            $pwm_generator_simple/dt_enable
add wave            $pwm_generator_simple/dt_carrier


set sim_time {40 ms}

run $sim_time
