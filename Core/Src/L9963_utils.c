#include "L9963_utils.h"

#include "L9963E.h"
#include "stm32_if.h"

/* Using L9963TH to send and receive data
    L9963TL will be used to check the correctness of communication
*/
volatile uint16_t vcells[N_CELLS_PER_SLAVE];
volatile uint16_t vgpio[N_GPIOS_PER_SLAVE];
volatile uint16_t vtot;
volatile uint32_t vsumbatt;
volatile uint16_t vmodules[N_SLAVES];

L9963E_HandleTypeDef hl9963e;

const L9963E_IfTypeDef interface_H = {.L9963E_IF_DelayMs       = DelayMs,
                                      .L9963E_IF_GetTickMs     = GetTickMs,
                                      .L9963E_IF_GPIO_ReadPin  = L9963TH_GPIO_ReadPin,
                                      .L9963E_IF_GPIO_WritePin = L9963TH_GPIO_WritePin,
                                      .L9963E_IF_SPI_Receive   = L9963TH_SPI_Receive,
                                      .L9963E_IF_SPI_Transmit  = L9963TH_SPI_Transmit};

const L9963E_IfTypeDef interface_L = {.L9963E_IF_DelayMs       = DelayMs,
                                      .L9963E_IF_GetTickMs     = GetTickMs,
                                      .L9963E_IF_GPIO_ReadPin  = L9963TL_GPIO_ReadPin,
                                      .L9963E_IF_GPIO_WritePin = L9963TL_GPIO_WritePin,
                                      .L9963E_IF_SPI_Receive   = L9963TL_SPI_Receive,
                                      .L9963E_IF_SPI_Transmit  = L9963TL_SPI_Transmit};

// TRYING TO FIGURE OUT HOW TO INITIALIZE THE DRIVER HANDLE
void L9963E_utils_init(void) {
    L9963E_init(&hl9963e, interface_H, N_SLAVES);
    L9963E_addressing_procedure(&hl9963e, 0b11, 1, 0b00, 1);

    /** Configuring the chips by writing to the registers, since each chip 
        has the same configuration, we are using Broadcast access 
        to write to all chips at once **/

    // Configuring GPIOs
    L9963E_RegisterUnionTypeDef gpio9_3_conf_reg = {.generic = L9963E_GPIO9_3_CONF_DEFAULT};
    gpio9_3_conf_reg.GPIO9_3_CONF.GPIO7_CONFIG   = 0;
    gpio9_3_conf_reg.GPIO9_3_CONF.GPIO8_CONFIG   = 0;
    L9963E_DRV_reg_write(
        &(hl9963e.drv_handle), L9963E_DEVICE_BROADCAST, L9963E_GPIO9_3_CONF_ADDR, &gpio9_3_conf_reg, 10);

    // Configuring cells overvoltage/undervoltage thresholds
    L9963E_RegisterUnionTypeDef vcell_thresh_uv_ov_reg      = {.generic = L9963E_VCELL_THRESH_UV_OV_DEFAULT};
    vcell_thresh_uv_ov_reg.VCELL_THRESH_UV_OV.threshVcellOV = 0xff;
    L9963E_DRV_reg_write(
        &(hl9963e.drv_handle), L9963E_DEVICE_BROADCAST, L9963E_VCELL_THRESH_UV_OV_ADDR, &vcell_thresh_uv_ov_reg, 10);

    // Configuring total voltage tresholds
    L9963E_RegisterUnionTypeDef vbat_sum_th_reg  = {.generic = L9963E_VBATT_SUM_TH_DEFAULT};
    vbat_sum_th_reg.VBATT_SUM_TH.VBATT_SUM_OV_TH = 0xff;
    L9963E_DRV_reg_write(
        &(hl9963e.drv_handle), L9963E_DEVICE_BROADCAST, L9963E_VBATT_SUM_TH_ADDR, &vbat_sum_th_reg, 10);

    // Enabling the Reference Voltage for ADC
    L9963E_enable_vref(&hl9963e, L9963E_DEVICE_BROADCAST, 1);

    // Set communication timeout and enable cells
    L9963E_setCommTimeout(&hl9963e, _256MS, L9963E_DEVICE_BROADCAST, 0);
    L9963E_set_enabled_cells(&hl9963e, L9963E_DEVICE_BROADCAST, ENABLED_CELLS);
}

void L9963E_utils_read_cells(uint8_t module_id, uint8_t read_gpio) {
    L9963E_StatusTypeDef e;
    uint8_t c_done;
    do {
      L9963E_poll_conversion(&hl9963e, module_id , &c_done);
    } while (!c_done);
    L9963E_start_conversion(&hl9963e, module_id ,0b000, read_gpio ? L9963E_GPIO_CONV : 0);
    uint16_t enabled_cells = ENABLED_CELLS;
    uint8_t enabled_gpios = ENABLED_GPIOS;
    uint16_t voltage = 0;
    uint8_t d_rdy = 0;

    // Reading the voltage of each individual cell
    uint8_t cell_id = 0;
    while(enabled_cells){
        uint16_t current_cell = enabled_cells & -enabled_cells;

        do {
            e = L9963E_read_cell_voltage(&hl9963e, module_id, current_cell, &voltage, &d_rdy);
          } while(e != L9963E_OK || !d_rdy);
          vcells[cell_id] = voltage;

        cell_id++;
        enabled_cells &= enabled_cells - 1;
    }

    // Reading total battery voltage
    do {
      e = L9963E_read_batt_voltage(&hl9963e, module_id, (uint16_t*)&vtot, (uint32_t*)&vsumbatt);
    } while(e != L9963E_OK);
  
    if(!read_gpio)
      return;
    
    // Reading GPIOs
    uint8_t gpio_id = 0;
    while(enabled_gpios){
        uint16_t current_gpio = enabled_gpios & -enabled_gpios;

        do {
            e = L9963E_read_gpio_voltage(&hl9963e, module_id, current_gpio, &voltage, &d_rdy);
          } while(e != L9963E_OK || !d_rdy);
          vcells[gpio_id] = voltage;

        gpio_id++;
        enabled_gpios &= enabled_gpios - 1;
    }
  
    ntc_set_ext_data((uint16_t*)vgpio, N_GPIOS_PER_SLAVE, 0);
  }