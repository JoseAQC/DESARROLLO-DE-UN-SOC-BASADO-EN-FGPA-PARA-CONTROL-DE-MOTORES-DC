#include <stdio.h>
#include <stdint.h>
#include "pwm_gen_vio.h"
#include "motor_enc.h"
#include <xparameters.h>
#include "xscugic.h"
#include "xil_exception.h"
#include <sleep.h>
#include <xil_printf.h>
#include <xgpio_l.h>


void test_pwm();
void test_encoder();
int cfg_sys_interrupts();

#define AXI_CLK_FREQ_HZ    100000000

#define GPIO_SWITCHES_BASEADDR XPAR_AXI_GPIO_0_BASEADDR

XScuGic   scu_GIC_drv;
motor_enc_t sys_enc;
pwm_gen_t sys_pwm;


void encoder_IRQ_Handler(){

	motor_get_obs_period(&sys_enc);
	motor_get_speed(&sys_enc);

	printf("Velocidad = %f rpm\n", sys_enc.speed_factor);

	motor_clr_int_flag(&sys_enc);
}

void test_pwm() {
  pwm_initialize(&sys_pwm,XPAR_AXI_PWM_GENERATOR_0_S_AXI_BASEADDR ); //0x43C00000

  // Set the PWM period
  pwm_set_frequency(&sys_pwm, 2000);

  // Set dead time period
  pwm_set_dead_time(&sys_pwm, 40e-6);

  pwm_set_reset(&sys_pwm, 0);    // Release the reset
  pwm_enable_pwm(&sys_pwm, 1);   // enable pwm the generation
  pwm_enable_dtime(&sys_pwm, 1); // enable the dead time generation
}

void test_encoder() {
	float t_obs = 20;  // Interruption period in ms

	motor_enc_initialize(&sys_enc, XPAR_AXI_MOTOR_ENCODER_0_S_AXI_BASEADDR);

	motor_set_mode(&sys_enc, 1);
	motor_set_obs_period(&sys_enc, t_obs);
	motor_set_int_enable(&sys_enc, 1);

	motor_set_reset(&sys_enc, 0);

}

int cfg_sys_interrupts(XScuGic *intc_drv){
	XStatus ret;
	XScuGic_Config *scu_GIC_cfg;

	Xil_ExceptionDisable();

	scu_GIC_cfg = XScuGic_LookupConfig(XPAR_PS7_SCUGIC_0_DEVICE_ID);
	if(scu_GIC_cfg == NULL) {
		return -1;
	}

	ret = XScuGic_CfgInitialize(intc_drv, scu_GIC_cfg, scu_GIC_cfg->CpuBaseAddress);
	if(ret != XST_SUCCESS){
		return -1;
	}

	Xil_ExceptionRegisterHandler(
	      XIL_EXCEPTION_ID_IRQ_INT,
	      (Xil_ExceptionHandler) XScuGic_InterruptHandler,
	      intc_drv);

	ret = XScuGic_Connect(
	          intc_drv,
			  XPAR_FABRIC_AXI_MOTOR_ENCODER_0_INTERRUPTION_INTR,
	          (Xil_ExceptionHandler) encoder_IRQ_Handler,
	          (void *) NULL);
	if (ret != XST_SUCCESS) {
	    return -1;
	  }

	XScuGic_Enable(intc_drv, XPAR_FABRIC_AXI_MOTOR_ENCODER_0_INTERRUPTION_INTR);

	Xil_ExceptionEnable();
	return 0;
}

int main() {
  uint32_t value=0;
  test_pwm();
  XGpio_WriteReg(GPIO_SWITCHES_BASEADDR, XGPIO_TRI_OFFSET, 0);
  test_encoder();
  cfg_sys_interrupts(&scu_GIC_drv);
  while(1) {
	  value = XGpio_ReadReg(GPIO_SWITCHES_BASEADDR, XGPIO_DATA_OFFSET);
	  pwm_set_dc_from_sw(&sys_pwm, value);
	  pwm_set_duty_cycle(&sys_pwm);
  }
  return 0;
}
