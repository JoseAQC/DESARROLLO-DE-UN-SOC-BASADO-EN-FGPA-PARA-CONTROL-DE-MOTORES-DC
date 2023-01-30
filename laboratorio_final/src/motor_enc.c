#include <stdint.h>
#include <string.h>
#include <xparameters.h>
#include "motor_enc.h"
#include "xil_exception.h"
#include <stdint.h>

// Register indexes:
#define MOTOR_CONTROL_REG_INDEX   0
#define MOTOR_PERIOD_REG_INDEX    1
#define MOTOR_POSITION_REG_INDEX  2
#define MOTOR_SPEED_REG_INDEX     3

// Register bit mask:
#define MOTOR_CTRL_RESET          0x01
#define MOTOR_CTRL_POS_CLR        0x02
#define MOTOR_CTRL_MODE           0X04
#define MOTOR_CTRL_INT_EN         0x08
#define MOTOR_CTRL_INT_FLAG       0x10

#define AXI_PWM_GENERATOR_CLK_FREQ_HZ 100000000  //supnemos que es fija


int motor_enc_initialize(motor_enc_t *drv, uint32_t base_addr){

  memset(drv, 0, sizeof(motor_enc_t));
  drv->base_addr = base_addr;
 
  // Inicialización del HW:
  motor_set_reset(drv, 1);
  motor_clr_pos(drv);
  motor_set_mode(drv, 0);
  motor_set_int_enable(drv,0);

  //xil_printf("\n el periodo es : %f", &obs);

  return 0;
}


int motor_set_reset(motor_enc_t *drv, int x){

  volatile uint32_t *reg = (volatile uint32_t *) drv->base_addr;
    if(x) {
      reg[MOTOR_CONTROL_REG_INDEX] |= MOTOR_CTRL_RESET;
    }
    else {
      reg[MOTOR_CONTROL_REG_INDEX] &= ~MOTOR_CTRL_RESET;
    }

  return 0;
}


int motor_clr_pos(motor_enc_t *drv){

  volatile uint32_t *reg = (volatile uint32_t *) drv->base_addr;

    reg[MOTOR_CONTROL_REG_INDEX] |= MOTOR_CTRL_POS_CLR;

  return 0;
}


int motor_set_mode(motor_enc_t *drv, int x){

  volatile uint32_t *reg = (volatile uint32_t *) drv->base_addr;
    if(x) {
      reg[MOTOR_CONTROL_REG_INDEX] |= MOTOR_CTRL_MODE;
    }
    else {
      reg[MOTOR_CONTROL_REG_INDEX] &= ~MOTOR_CTRL_MODE;
    }

  return 0;
}


int motor_get_int_enable(motor_enc_t *drv){

  volatile uint32_t *reg = (volatile uint32_t *) drv->base_addr;

  drv->int_enable = (reg[MOTOR_CONTROL_REG_INDEX] & 0x08)>>3;

  return 0;
}


int motor_set_int_enable(motor_enc_t *drv, int x){

  volatile uint32_t *reg = (volatile uint32_t *) drv->base_addr;
	if(x) {
	  reg[MOTOR_CONTROL_REG_INDEX] |= MOTOR_CTRL_INT_EN;
	  }
	else {
	  reg[MOTOR_CONTROL_REG_INDEX] &= ~MOTOR_CTRL_INT_EN;
	}

  return 0;
}


int motor_get_int_flag(motor_enc_t *drv){

  volatile uint32_t *reg = (volatile uint32_t *) drv->base_addr;

  drv->int_flag = (reg[MOTOR_CONTROL_REG_INDEX] & 0x10)>>4;

  return 0;
}


int motor_clr_int_flag(motor_enc_t *drv){

  volatile uint32_t *reg = (volatile uint32_t *) drv->base_addr;

  reg[MOTOR_CONTROL_REG_INDEX] |= MOTOR_CTRL_INT_FLAG;

  return 0;
}


float motor_get_obs_period(motor_enc_t *drv){

  volatile uint32_t *reg = (volatile uint32_t *) drv->base_addr;
  uint32_t temporal;

  temporal = reg[MOTOR_PERIOD_REG_INDEX];
  drv->period_reg = (temporal+1)/(float)AXI_PWM_GENERATOR_CLK_FREQ_HZ;

  return drv->period_reg;
}


int motor_set_obs_period(motor_enc_t *drv, float T_obs){

  volatile uint32_t *reg = (volatile uint32_t *) drv->base_addr;
  float obs_period = 0;
  uint32_t temporal;

  obs_period = 1/(float)(T_obs*1e-3);
  temporal = (AXI_PWM_GENERATOR_CLK_FREQ_HZ/obs_period)-1;
  reg[MOTOR_PERIOD_REG_INDEX] = temporal;

  return 0;
}


int motor_get_position_code(motor_enc_t *drv){
	volatile uint32_t *reg = (volatile uint32_t *) drv->base_addr;

	drv->postion_code = reg[MOTOR_POSITION_REG_INDEX];

	return 0;
}


int motor_get_speed_code(motor_enc_t *drv){
	volatile uint32_t *reg = (volatile uint32_t *) drv->base_addr;

	drv->speed_code = reg[MOTOR_SPEED_REG_INDEX];

	return 0;
}


float motor_get_speed(motor_enc_t *drv){

	volatile uint32_t *reg = (volatile uint32_t *) drv->base_addr;
	int32_t temporal=0;

	temporal = reg[MOTOR_SPEED_REG_INDEX];
    drv->speed_factor = (temporal*60)/(12*19.225*drv->period_reg);

	return 0;
}
