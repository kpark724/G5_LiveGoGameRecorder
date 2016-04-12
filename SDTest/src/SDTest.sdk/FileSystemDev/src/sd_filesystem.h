/*
 * sd_filesystem.h
 *
 * Created: 16/02/29
 * Author: Jesse Barcelos
 *
 * microSD hardware driver using AXI SPI interface
 */

#ifndef SD_FILESYSTEM_H
#define SD_FILESYSTEM_H

#include "xparameters.h"
#include "xil_io.h"
#include "xil_types.h"

//file system init parameters
#define SD_INIT_ATTEMPTS 40
#define SD_INIT_CMD_READS 16
#define SD_INIT_PRE_CLKS 20
#define SD_INIT_SEC_SIZE 512

//sd power pin macros
#define CLR_SD_POWER_STATE(ptr) *ptr = *ptr | 0x2
#define SET_SD_POWER_STATE(ptr) *ptr = *ptr & 0x1
#define SET_IND(ptr) *ptr |= 0x1;
#define CLR_IND(ptr) *ptr &= &= 0x2

//file system status bit masks
#define SD_FS_CARD_DETECT	0x1
#define SD_FS_CARD_CONFIG	0x2
#define SD_FS_FAT_MOUNTED	0x4
#define SD_FS_CARD_POWERED	0x8

//file system CD set function macros
#define SET_CD(status) status |= SD_FS_CARD_DETECT
#define CLR_CD(status) status &= ~SD_FS_CARD_DETECT

//SPI control register bit masks
#define SD_CTRL_LOOP 		0x1
#define SD_CTRL_SYS_EN 		0x2
#define SD_CTRL_MASTER_MODE 0x4
#define SD_CTRL_CLK_POL		0x8
#define SD_CTRL_CLK_PHA		0x10
#define SD_CTRL_TX_FIFO_RES	0x20
#define SD_CTRL_RX_FIFO_RES 0x40
#define SD_CTRL_MAN_SLV_SEL	0x80
#define SD_CTRL_TRANS_INHIB	0x100
#define SD_CTRL_LSB_FIRST	0x200

//SPI status register bit masks
#define SD_SR_RX_EMPTY		0x1
#define SD_SR_RX_FULL		0x2
#define SD_SR_TX_EMPTY		0x4
#define SD_SR_TX_FULL		0x8
#define SD_SR_MODE_FAULT	0x10
#define SD_SR_SLV_MODE_SEL	0x20

//SPI slave register bit mask
#define SD_SSR_SEL_0		0x1

//SD error codes
#define SD_ERR_ALREADY_CONFIGURED	-1
#define SD_ERR_UNDETECTED_CARD 		-2
#define SD_ERR_CANT_INIT			-3
#define SD_ERR_EXITING_IDLE			-4
#define SD_ERR_FAT_INIT				-5
#define SD_READ_ERROR				-6

//SD R1 response codes
#define SD_RES_IDLE				0x1
#define SD_RES_ERASE_RESET		0x2
#define SD_RES_ILLEGAL_COMM		0x4
#define SD_RES_CRC_ERROR		0x8
#define SD_RES_ERASE_SEQ_ERROR	0x10
#define SD_RES_ADDR_ERROR		0x20
#define SD_RES_PARAM_ERROR		0x40

typedef struct SD_SPI_CONTROLLER {
	//Interrupt Controller Group
	u32 unused_0[7];
	u32 global_intr_en;	//DGIER
	u32 intr_status_reg;//IPISR
	u32 unused_1;
	u32 intr_en_reg;	//IPIER
	u32 unused_2[5];

	//Core Group
	u32 software_reset_reg;	//SRR
	u32 unused_3[7];
	u32 spi_ctrl_reg;	//SPICR
	u32 spi_status_reg;	//SPISR
	u32 spi_tx_reg;		//SPIDTR
	u32 spi_rx_reg;		//SPIDRR
	u32 spi_slv_sel;	//SPISSR
	u32 tx_fifo_size;
	u32 rx_fifo_size;
} SD_SPI_CONTROLLER;

//slave select bit set and clear macros
#define SET_CS(ctrl_ptr) ctrl_ptr->spi_slv_sel |= SD_SSR_SEL_0
#define CLR_CS(ctrl_ptr) ctrl_ptr->spi_slv_sel &= ~SD_SSR_SEL_0

/*****************************************************************************
 *
 * Transfer a single byte via AXI SPI interface. This function is
 * synchronous and will block until the transfer is complete. This
 * function does not drive the chip select pin.
 *
 * @param	value - Byte value to send over SPI.
 *
 * @return	The byte value received during transfer.
 *
 * @note	This function should not be called if a transmission is
 * 			in progress as it will set the inhibit bit prior to operation
 *
 ****************************************************************************/
u8 spi_write_byte(u8 value);


/****************************************************************************
 *
 * Transfer byte buffer over AXI SPI interface.
 *
 * @param	src_buf - Pointer to a byte array to be transfered to the
 * 						SD card. If value is null, MOSI line will be
 * 						always asserted during transfer.
 *
 * @param	dest_buf - Destination buffer to be filled during transfer.
 * 						If value is null, will discard values returned
 * 						during transfer.
 *
 * @param	bytes - Number of bytes to be written/read during the transfer
 *
 * @return	None.
 *
 * @note	None.
 *
 ***************************************************************************/
void spi_transfer_buffer(u8 * src_buf, u8 * dest_buf, u32 bytes);

u8 sd_calc_crc7(u8 crc, u8 message);
u16 sd_calc_crc16(u16 crc, u16 message);

/***************************************************************************
 *
 * Transfers 48-bit command stream to microSD over AXI SPI interface.
 *
 * @param	cmd - Byte command to be transfered to microSD
 *
 * @param	par0-3 - Parameters to be transfered to microSD
 *
 * @param	crc - Checksum of command stream
 *
 * @return	Response code from microSD
 *
 * @note	None.
 *
 ***************************************************************************/
u8 sd_send_command(u8 cmd, u8 par0, u8 par1, u8 par2, u8 par3, u8 crc, u8 read);


/***************************************************************************
 *
 * Initializes microSD to idle state by sending reset to SPI protocol
 * command CMD0
 *
 * @param	None.
 *
 * @return	Error code. If success returns 0, else returns -1
 *
 * @note	None.
 *
 ***************************************************************************/
s32 sd_init_card();

/***************************************************************************
 *
 * Reads in specified number of bytes from microSD card
 *
 * @param	sector - sector on microSD to read from
 *
 * @param	offset - offset within sector to begin reading
 *
 * @param	buffer - ptr to output buffer
 *
 * @param	bytes - number of bytes to be read out
 *
 * @return	None.
 *
 * @note	Number of bytes should not be larger than the maximum
 * 			buffer size.
 *
 ***************************************************************************/
s32 sd_read(u64 sector, u32 offset, u8 * buffer, u32 bytes);

/***************************************************************************
 *
 * Prints formatted given in the data buffer to standard output stream
 * for debugging purposes
 *
 * @param	buffer - byte buffer of data to be displayed
 *
 * @param	length - number of bytes contained in the buffer
 *
 * @param	bytes - indicates the number of bytes to display per line
 *
 * @returns	None.
 *
 * @note	xil_printf must be included in order for this function
 * 			to work
 *
 ***************************************************************************/
void sd_debug_print_hex(u8 * buffer, u32 length, u8 line);

/***************************************************************************
 *
 * De-initializes the data structures used by the microSD card and
 * shuts down power going to the card
 *
 * @param	None.
 *
 * @returns None.
 *
 * @note	None.
 *
 ***************************************************************************/
void sd_eject_card();

s32 sd_write(u64 sector, u32 offset, u8 * buffer, u32 bytes);


#endif /* SD_FILESYSTEM_H */
