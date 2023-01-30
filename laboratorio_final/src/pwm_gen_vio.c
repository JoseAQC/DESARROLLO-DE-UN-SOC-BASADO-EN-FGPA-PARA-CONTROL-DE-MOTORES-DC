
#include <stdint.h>
#include <string.h>
#include <xparameters.h>

#include "pwm_gen_vio.h"

// Register indexes:
#define PWM_CTRL_REG_INDEX      0
#define PWM_PERIOD_REG_INDEX    1
#define DUTY_CYCLE_REG_INDEX    2
#define PWM_DEADTIME_REG_INDEX  3


// Register bit mask:
#define PWM_CTRL_RST      0x01
#define PWM_CTRL_PWM_EN   0x02
#define PWM_CTRL_DT_EN    0X04
#define PWM_CTRL_DIR      0x80000000




#define AXI_PWM_GENERATOR_CLK_FREQ_HZ 100000000  //supnemos que es fija


//////// Inicializar IP //////// 

int pwm_initialize(pwm_gen_t *drv, uint32_t base_addr) {
  memset(drv, 0, sizeof(pwm_gen_t));
  drv->base_addr = base_addr;
  volatile uint32_t *reg = (volatile uint32_t *) drv->base_addr;
  // Inicialización del HW:
  pwm_set_reset(drv, 1); 
  pwm_enable_pwm(drv,0);
  pwm_enable_dtime(drv,0);
  reg[DUTY_CYCLE_REG_INDEX] |= PWM_CTRL_DIR;
  return 0;
}

//////// Set o Reset //////// 

int pwm_set_reset(pwm_gen_t *drv, int x) {
  volatile uint32_t *reg = (volatile uint32_t *) drv->base_addr;

  if(x) {
    reg[PWM_CTRL_REG_INDEX] |= PWM_CTRL_RST;
  }
  else {
    reg[PWM_CTRL_REG_INDEX] &= ~PWM_CTRL_RST;
  }

  return 0;
} 

//////// Habilitar la PWM //////// 

int pwm_enable_pwm(pwm_gen_t *drv, int x){

  volatile uint32_t *reg = (volatile uint32_t *) drv->base_addr;

 if(x){
  reg[PWM_CTRL_REG_INDEX] |= PWM_CTRL_PWM_EN;  // 1 -> enable
  }

 else{
  reg[PWM_CTRL_REG_INDEX] &= ~PWM_CTRL_PWM_EN;  
  }
 return 0;
}


//////// Habilitar el el generdor de tiempos muertos //////// 

int pwm_enable_dtime(pwm_gen_t *drv, int x){

  volatile uint32_t *reg = (volatile uint32_t *) drv->base_addr;

  if(x){
  reg[PWM_CTRL_REG_INDEX] |= PWM_CTRL_DT_EN;  // 1 -> enable
  }

 else{
  reg[PWM_CTRL_REG_INDEX] &= ~PWM_CTRL_DT_EN;  
  }
  return 0;

}


//////// Configurar el periodo de la PWM ///////////////

int pwm_set_frequency(pwm_gen_t *drv, float f_pwm){
 
  volatile uint32_t *reg = (volatile uint32_t *) drv->base_addr;
  
  drv->period_reg = (AXI_PWM_GENERATOR_CLK_FREQ_HZ/f_pwm)-1;
  reg[PWM_PERIOD_REG_INDEX] = drv->period_reg;
  reg[DUTY_CYCLE_REG_INDEX] = 0;
  return 0;

} 


//////// Configurar el ciclo de trabajo de la PWM ////////

int pwm_set_duty_cycle(pwm_gen_t *drv){

  volatile uint32_t *reg = (volatile uint32_t *) drv->base_addr;
  if(drv->dc_i < 0){
	  reg[DUTY_CYCLE_REG_INDEX] = PWM_CTRL_DIR;
	  drv->dc_code = (uint32_t) (drv->period_reg*(-drv->dc_i));
	  reg[DUTY_CYCLE_REG_INDEX] |= drv->dc_code;
  }
  else{
	  reg[DUTY_CYCLE_REG_INDEX] = 0x00;
	  drv->dc_code = (uint32_t) (drv->period_reg*drv->dc_i);
	  reg[DUTY_CYCLE_REG_INDEX] |= drv->dc_code;
  }

return 0;
}



//////// Configurar el dead time //////// 

int pwm_set_dead_time(pwm_gen_t *drv, float dt){

  volatile uint32_t *reg = (volatile uint32_t *) drv->base_addr;

  drv->dt_code = (AXI_PWM_GENERATOR_CLK_FREQ_HZ*dt);
  reg[PWM_DEADTIME_REG_INDEX] = drv->dt_code;
  return 0;
}




//////// Configurar el valor proveniente del registro ////////

int pwm_set_dc_from_sw(pwm_gen_t *drv, uint32_t val){

	volatile uint32_t *reg = (volatile uint32_t *) drv->base_addr;

    if(val >= 128){
    	drv->dc_i = -(float)(val-128)/127;
    }
    else{
    	drv->dc_i = (float)val / 127;
    }
    return drv->dc_i;
}
