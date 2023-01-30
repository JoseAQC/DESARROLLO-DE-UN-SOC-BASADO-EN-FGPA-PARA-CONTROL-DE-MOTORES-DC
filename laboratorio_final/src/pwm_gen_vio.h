#ifndef PWM_GEN_H 
#define PWM_GEN_H 
 


#include <stdint.h>

typedef struct { 
  uint32_t  base_addr; 
  uint32_t  period_reg; 
  uint32_t  dc_code;
  uint32_t  dt_code;
  float     dc_i;
} pwm_gen_t; 

 
int pwm_initialize(pwm_gen_t *drv, uint32_t base_addr); 
int pwm_set_reset(pwm_gen_t *drv, int x); 
int pwm_enable_pwm(pwm_gen_t *drv, int x); 
int pwm_enable_dtime(pwm_gen_t *drv, int x);
int pwm_set_frequency(pwm_gen_t *drv, float f_pwm);
int pwm_set_duty_cycle(pwm_gen_t *drv);
int pwm_set_dead_time(pwm_gen_t *drv, float dt);
int pwm_set_dc_from_sw(pwm_gen_t *drv, uint32_t val);






#endif // PWM_GEN_H 
