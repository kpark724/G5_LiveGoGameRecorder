/*
 * sgf_writer.h
 *
 *  Created on: Apr 3, 2016
 *      Author: Jesse
 */

#ifndef SGF_WRITER_H_
#define SGF_WRITER_H_
/*
*   Everytime vdma_1 reads from the StoneDetect IP, the IP changes one of its register value to the next stone.
*   It is assumed that IP is outputting the result by traversing through column first and then row (row: outer loop, col: inner loop)
*   Therefore, the memory will be stored with 361 2-bit information, which must be translated into sgf file format.
*   361 * 2 bits / 8 bits per byte = 90.25 bytes ~= 91 bytes
*   91 bytes ~= 23 DWORD
*
*/

#include "fat_filesystem.h"

#define BOARD_CONFIG_SIZE 23
#define BLACK_STONE 2
#define NO_STONE 0
#define WHITE_STONE 1
#define BOARD_SIZE 19

#define BLACK_TURN  2
#define WHITE_TURN  1

#define STR_SIZE 20

typedef struct{
    char color;
    char j;
    char i;
}Move;

void init_sgf_file(FATTIE *fp);

void write_sgf_move(FATTIE *fp, char x, char y, char color);

void end_sgf_file(FATTIE *fp);

#endif /* SGF_WRITER_H_ */
