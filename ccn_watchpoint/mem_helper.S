/* ------------------------------------------------
 * void mem_load(void* start, unsigned length);
 * x0 -> start, x2 -> end
 * ------------------------------------------------
 */

.global mem_load

.func
mem_load:
	add x2, x0, x1
1:	ldr w3, [x0], #64
	cmp x0, x2
    b.lo 1b
	ret
.endfunc
