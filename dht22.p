/* Functions use r20 as argument and r20-r27 for their private
 * operations. r29 is used as stack. r28 as return value
 */

.setcallreg r29.w0
.origin 0 // offset of the start of the code in PRU memory
.entrypoint START // program entry point, used by debugger only

// To signal the host that we're done, we set bit 5 in our R31
// simultaneously with putting the number of the signal we want
// into R31 bits 0-3. See 5.2.2.2 in AM335x PRU-ICSS Reference Guide.
#define PRU0_R31_VEC_VALID (1<<5)
#define SIGNUM 3 // corresponds to PRU_EVTOUT_0

#define CLOCK 200000000 // PRU is always clocked at 200MHz
#define CLOCKS_PER_LOOP 2 // loop contains two instructions, one clock each
#define DELAY_US_MULTIPLIER (CLOCK / CLOCKS_PER_LOOP / 1000000)

#define SHARED_RAM           0x100
#define PRU0_CTRL            0x22000
#define PRU1_CTRL            0x24000
#define CTPPR0               0x28

#define GPIO1               0x4804c000 /* this is gpio1 (zero-based) */
#define GPIO_CLEARDATAOUT   0x190
#define GPIO_SETDATAOUT     0x194
#define GPIO_OE             0x134

START:

	/* Setup shared memory */
	mov     r0, SHARED_RAM                  // Set C28 to point to shared RAM
	mov     r1, PRU1_CTRL + CTPPR0
	sbbo    r0, r1, 0, 4

	/* Enable the OCP */
	lbco r0, C4, 4, 4  // load the PRU control reg
	clr  r0, r0, 4  // set bit 4
	sbco r0, C4, 4, 4  // store the PRU control reg

	/* Set the value to low before we change the dir */
	mov r1, (GPIO1 | GPIO_CLEARDATAOUT)  // get the offset
	mov r0, 1 << 13  // we're changing gpio1[13]
	sbbo r0, r1, 0, 4  // write it

	/* Load the output enable register of gpio1 (0-based) */
	mov r1, GPIO1 | GPIO_OE  // get the offset
	lbbo r0, r1, 0, 4  // load in r0
	clr r0, 13  // clear bit 13 (output is active low)
	sbbo r0, r1, 0, 4  // write it back

	/* Wait for 500us */
	mov	r20, 500 * DELAY_US_MULTIPLIER // wait 1 sec
	call	delay_us

	/* Now we restore the pin in high-Z */

	/* Load the output enable register of gpio1 (0-based) */
	mov r1, GPIO1 | GPIO_OE  // get the offset
	lbbo r0, r1, 0, 4  // load in r0
	set r0, 13  // set bit 13 (output is active low)
	sbbo r0, r1, 0, 4  // write it back

	/* Okay we've sent the request, now eat some output */

	/* Wait for the line to return high after our low assertion */
	wbs r31.t15  // our input is mapped in bit 15 of r31

	/* Wait for the line to come back low as a result of the sensor saying hi */
	wbc r31.t15

	/* Wait for the line to return high after the sensor's hi */
	wbs r31.t15  // our input is mapped in bit 15 of r31

	/* Wait for the line to return low as a preamble to the first data bit */
	wbc r31.t15

	/* Okay now the real data */
	mov r0, 0  // r0,r1 = the data
	mov r2, 32  // r2 = current bit

bit_loop:
	/* Wait for the line to return high for the first data bit */
	wbs r31.t15

	lsl r0, r0, 1  // left shift r0 by one for next bit
	sub r2, r2, 1

	call wait_low_count
	mov r21, 3500
	qbgt noset, r28, r21
	set r0.t0
	noset:

	qbne bit_loop, r2, 0

	/* Continue for a 5th byte for the checksum, this time in r1 */

	mov r1, 0
	mov r2, 8  // r2 = current bit
bit_loop2:
	/* Wait for the line to return high for the first data bit */
	wbs r31.t15

	lsl r1.b0, r1.b0, 1  // left shift r0 by one for next bit
	sub r2, r2, 1

	call wait_low_count
	mov r21, 3500
	qbgt noset2, r28, r21
	set r1.b0.t0
	noset2:

	qbne bit_loop2, r2, 0


	sbco	r0, C28, 0, 8 // Store contents of r0 in shared memory

        // tell host we're done, then halt
	mov	R31.b0, PRU0_R31_VEC_VALID | SIGNUM
	halt

/* Waits for bit to become low, while counting the loops */
wait_low_count:
	mov r28, 0
	wait_low_count_loop:
	add r28, r28, 1
	qbbs wait_low_count_loop, r31.t15
	ret

/* Waits for a given number of us, pass number in r0 */

delay_us:
delay_int:
	sub     r20, r20, 1     // decrement loop counter
	qbne    delay_int, r20, 0  // repeat loop unless zero
	ret
