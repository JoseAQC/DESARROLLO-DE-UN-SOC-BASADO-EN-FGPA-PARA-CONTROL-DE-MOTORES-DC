#ifndef MOTOR_ENC_H
#define MOTOR_ENC_H

#include <stdint.h>

typedef struct {
	uint32_t base_addr;
	uint8_t int_flag;
	uint8_t int_enable;
	float period_reg;
	int32_t postion_code;
	int32_t speed_code;
	float speed_factor;
} motor_enc_t;

int motor_enc_initialize(motor_enc_t *drv, uint32_t base_addr);
int motor_set_reset(motor_enc_t *drv, int x);
int motor_clr_pos(motor_enc_t *drv);
int motor_set_mode(motor_enc_t *drv, int x);
int motor_get_int_enable(motor_enc_t *drv);
int motor_set_int_enable(motor_enc_t *drv, int x);
int motor_get_int_flag(motor_enc_t *drv);
int motor_clr_int_flag(motor_enc_t *drv);
float motor_get_obs_period(motor_enc_t *drv);
int motor_set_obs_period(motor_enc_t *drv, float T_obs); 
int motor_get_position_code(motor_enc_t *drv);
int motor_get_speed_code(motor_enc_t *drv);
float motor_get_speed(motor_enc_t *drv);


#endif // PWM_GEN_H 
