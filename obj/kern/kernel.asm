
obj/kern/kernel:     file format elf32-i386


Disassembly of section .text:

f0100000 <_start+0xeffffff4>:
.globl		_start
_start = RELOC(entry)

.globl entry
entry:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fe 4f 52             	decb   0x52(%edi)
f010000b:	e4 66                	in     $0x66,%al

f010000c <entry>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 
	# sufficient until we set up our real page table in mem_init
	# in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 e0 11 00       	mov    $0x11e000,%eax
	movl	%eax, %cr3
f010001a:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl	%cr0, %eax
f010001d:	0f 20 c0             	mov    %cr0,%eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
f0100020:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl	%eax, %cr0
f0100025:	0f 22 c0             	mov    %eax,%cr0

	# Now paging is enabled, but we're still running at a low EIP
	# (why is this okay?).  Jump up above KERNBASE before entering
	# C code.
	mov	$relocated, %eax
f0100028:	b8 2f 00 10 f0       	mov    $0xf010002f,%eax
	jmp	*%eax
f010002d:	ff e0                	jmp    *%eax

f010002f <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(bootstacktop),%esp
f0100034:	bc 00 e0 11 f0       	mov    $0xf011e000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 5c 00 00 00       	call   f010009a <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	56                   	push   %esi
f0100044:	53                   	push   %ebx
f0100045:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f0100048:	83 3d 80 5e 24 f0 00 	cmpl   $0x0,0xf0245e80
f010004f:	75 3a                	jne    f010008b <_panic+0x4b>
		goto dead;
	panicstr = fmt;
f0100051:	89 35 80 5e 24 f0    	mov    %esi,0xf0245e80

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");
f0100057:	fa                   	cli    
f0100058:	fc                   	cld    

	va_start(ap, fmt);
f0100059:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f010005c:	e8 7e 5d 00 00       	call   f0105ddf <cpunum>
f0100061:	ff 75 0c             	pushl  0xc(%ebp)
f0100064:	ff 75 08             	pushl  0x8(%ebp)
f0100067:	50                   	push   %eax
f0100068:	68 a0 64 10 f0       	push   $0xf01064a0
f010006d:	e8 9e 37 00 00       	call   f0103810 <cprintf>
	vcprintf(fmt, ap);
f0100072:	83 c4 08             	add    $0x8,%esp
f0100075:	53                   	push   %ebx
f0100076:	56                   	push   %esi
f0100077:	e8 6e 37 00 00       	call   f01037ea <vcprintf>
	cprintf("\n");
f010007c:	c7 04 24 41 6d 10 f0 	movl   $0xf0106d41,(%esp)
f0100083:	e8 88 37 00 00       	call   f0103810 <cprintf>
	va_end(ap);
f0100088:	83 c4 10             	add    $0x10,%esp

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f010008b:	83 ec 0c             	sub    $0xc,%esp
f010008e:	6a 00                	push   $0x0
f0100090:	e8 ee 08 00 00       	call   f0100983 <monitor>
f0100095:	83 c4 10             	add    $0x10,%esp
f0100098:	eb f1                	jmp    f010008b <_panic+0x4b>

f010009a <i386_init>:
static void boot_aps(void);


void
i386_init(void)
{
f010009a:	55                   	push   %ebp
f010009b:	89 e5                	mov    %esp,%ebp
f010009d:	53                   	push   %ebx
f010009e:	83 ec 08             	sub    $0x8,%esp
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f01000a1:	b8 08 70 28 f0       	mov    $0xf0287008,%eax
f01000a6:	2d 18 4b 24 f0       	sub    $0xf0244b18,%eax
f01000ab:	50                   	push   %eax
f01000ac:	6a 00                	push   $0x0
f01000ae:	68 18 4b 24 f0       	push   $0xf0244b18
f01000b3:	e8 ad 56 00 00       	call   f0105765 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000b8:	e8 bc 05 00 00       	call   f0100679 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000bd:	83 c4 08             	add    $0x8,%esp
f01000c0:	68 ac 1a 00 00       	push   $0x1aac
f01000c5:	68 0c 65 10 f0       	push   $0xf010650c
f01000ca:	e8 41 37 00 00       	call   f0103810 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f01000cf:	e8 61 12 00 00       	call   f0101335 <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f01000d4:	e8 5f 2f 00 00       	call   f0103038 <env_init>
	trap_init();
f01000d9:	e8 62 38 00 00       	call   f0103940 <trap_init>

	// Lab 4 multiprocessor initialization functions
	mp_init();
f01000de:	e8 d9 59 00 00       	call   f0105abc <mp_init>
	lapic_init();
f01000e3:	e8 12 5d 00 00       	call   f0105dfa <lapic_init>

	// Lab 4 multitasking initialization functions
	pic_init();
f01000e8:	e8 73 36 00 00       	call   f0103760 <pic_init>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f01000ed:	c7 04 24 c0 03 12 f0 	movl   $0xf01203c0,(%esp)
f01000f4:	e8 57 5f 00 00       	call   f0106050 <spin_lock>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01000f9:	83 c4 10             	add    $0x10,%esp
f01000fc:	83 3d 88 5e 24 f0 07 	cmpl   $0x7,0xf0245e88
f0100103:	77 16                	ja     f010011b <i386_init+0x81>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100105:	68 00 70 00 00       	push   $0x7000
f010010a:	68 c4 64 10 f0       	push   $0xf01064c4
f010010f:	6a 5f                	push   $0x5f
f0100111:	68 27 65 10 f0       	push   $0xf0106527
f0100116:	e8 25 ff ff ff       	call   f0100040 <_panic>
	void *code;
	struct CpuInfo *c;

	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f010011b:	83 ec 04             	sub    $0x4,%esp
f010011e:	b8 16 5a 10 f0       	mov    $0xf0105a16,%eax
f0100123:	2d 9c 59 10 f0       	sub    $0xf010599c,%eax
f0100128:	50                   	push   %eax
f0100129:	68 9c 59 10 f0       	push   $0xf010599c
f010012e:	68 00 70 00 f0       	push   $0xf0007000
f0100133:	e8 7a 56 00 00       	call   f01057b2 <memmove>

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f0100138:	8b 15 c4 63 24 f0    	mov    0xf02463c4,%edx
f010013e:	8d 04 12             	lea    (%edx,%edx,1),%eax
f0100141:	01 d0                	add    %edx,%eax
f0100143:	01 c0                	add    %eax,%eax
f0100145:	01 d0                	add    %edx,%eax
f0100147:	8d 04 82             	lea    (%edx,%eax,4),%eax
f010014a:	8d 04 85 20 60 24 f0 	lea    -0xfdb9fe0(,%eax,4),%eax
f0100151:	83 c4 10             	add    $0x10,%esp
f0100154:	3d 20 60 24 f0       	cmp    $0xf0246020,%eax
f0100159:	0f 86 95 00 00 00    	jbe    f01001f4 <i386_init+0x15a>
f010015f:	bb 20 60 24 f0       	mov    $0xf0246020,%ebx
		if (c == cpus + cpunum())  // We've started already.
f0100164:	e8 76 5c 00 00       	call   f0105ddf <cpunum>
f0100169:	8d 14 00             	lea    (%eax,%eax,1),%edx
f010016c:	01 c2                	add    %eax,%edx
f010016e:	01 d2                	add    %edx,%edx
f0100170:	01 c2                	add    %eax,%edx
f0100172:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0100175:	8d 04 85 20 60 24 f0 	lea    -0xfdb9fe0(,%eax,4),%eax
f010017c:	39 c3                	cmp    %eax,%ebx
f010017e:	74 50                	je     f01001d0 <i386_init+0x136>
			continue;

		// Tell mpentry.S what stack to use 
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f0100180:	89 d8                	mov    %ebx,%eax
f0100182:	2d 20 60 24 f0       	sub    $0xf0246020,%eax
f0100187:	c1 f8 02             	sar    $0x2,%eax
f010018a:	8d 14 80             	lea    (%eax,%eax,4),%edx
f010018d:	8d 0c d0             	lea    (%eax,%edx,8),%ecx
f0100190:	89 ca                	mov    %ecx,%edx
f0100192:	c1 e2 05             	shl    $0x5,%edx
f0100195:	29 ca                	sub    %ecx,%edx
f0100197:	8d 0c 90             	lea    (%eax,%edx,4),%ecx
f010019a:	89 ca                	mov    %ecx,%edx
f010019c:	c1 e2 0e             	shl    $0xe,%edx
f010019f:	29 ca                	sub    %ecx,%edx
f01001a1:	8d 14 90             	lea    (%eax,%edx,4),%edx
f01001a4:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01001a7:	c1 e0 0f             	shl    $0xf,%eax
f01001aa:	05 00 f0 24 f0       	add    $0xf024f000,%eax
f01001af:	a3 84 5e 24 f0       	mov    %eax,0xf0245e84
		// Start the CPU at mpentry_start
		lapic_startap(c->cpu_id, PADDR(code));
f01001b4:	83 ec 08             	sub    $0x8,%esp
f01001b7:	68 00 70 00 00       	push   $0x7000
f01001bc:	0f b6 03             	movzbl (%ebx),%eax
f01001bf:	50                   	push   %eax
f01001c0:	e8 8c 5d 00 00       	call   f0105f51 <lapic_startap>
f01001c5:	83 c4 10             	add    $0x10,%esp
		// Wait for the CPU to finish some basic setup in mp_main()
		while(c->cpu_status != CPU_STARTED)
f01001c8:	8b 43 04             	mov    0x4(%ebx),%eax
f01001cb:	83 f8 01             	cmp    $0x1,%eax
f01001ce:	75 f8                	jne    f01001c8 <i386_init+0x12e>
	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f01001d0:	83 c3 74             	add    $0x74,%ebx
f01001d3:	8b 15 c4 63 24 f0    	mov    0xf02463c4,%edx
f01001d9:	8d 04 12             	lea    (%edx,%edx,1),%eax
f01001dc:	01 d0                	add    %edx,%eax
f01001de:	01 c0                	add    %eax,%eax
f01001e0:	01 d0                	add    %edx,%eax
f01001e2:	8d 04 82             	lea    (%edx,%eax,4),%eax
f01001e5:	8d 04 85 20 60 24 f0 	lea    -0xfdb9fe0(,%eax,4),%eax
f01001ec:	39 c3                	cmp    %eax,%ebx
f01001ee:	0f 82 70 ff ff ff    	jb     f0100164 <i386_init+0xca>
	lock_kernel();
	// Starting non-boot CPUs
	boot_aps();

	// Start fs.
	ENV_CREATE(fs_fs, ENV_TYPE_FS);
f01001f4:	83 ec 08             	sub    $0x8,%esp
f01001f7:	6a 01                	push   $0x1
f01001f9:	68 9c 9b 1f f0       	push   $0xf01f9b9c
f01001fe:	e8 00 30 00 00       	call   f0103203 <env_create>

#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
f0100203:	83 c4 08             	add    $0x8,%esp
f0100206:	6a 00                	push   $0x0
f0100208:	68 94 d0 23 f0       	push   $0xf023d094
f010020d:	e8 f1 2f 00 00       	call   f0103203 <env_create>
    // ENV_CREATE(user_yield, ENV_TYPE_USER);

#endif // TEST*

	// Should not be necessary - drains keyboard because interrupt has given up.
	kbd_intr();
f0100212:	e8 08 04 00 00       	call   f010061f <kbd_intr>

	// Schedule and run the first user environment!
	sched_yield();
f0100217:	e8 4f 42 00 00       	call   f010446b <sched_yield>

f010021c <mp_main>:
}

// Setup code for APs
void
mp_main(void)
{
f010021c:	55                   	push   %ebp
f010021d:	89 e5                	mov    %esp,%ebp
f010021f:	83 ec 08             	sub    $0x8,%esp
	// We are in high EIP now, safe to switch to kern_pgdir 
	lcr3(PADDR(kern_pgdir));
f0100222:	a1 8c 5e 24 f0       	mov    0xf0245e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100227:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010022c:	77 12                	ja     f0100240 <mp_main+0x24>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010022e:	50                   	push   %eax
f010022f:	68 e8 64 10 f0       	push   $0xf01064e8
f0100234:	6a 76                	push   $0x76
f0100236:	68 27 65 10 f0       	push   $0xf0106527
f010023b:	e8 00 fe ff ff       	call   f0100040 <_panic>
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0100240:	05 00 00 00 10       	add    $0x10000000,%eax
f0100245:	0f 22 d8             	mov    %eax,%cr3
	cprintf("SMP: CPU %d starting\n", cpunum());
f0100248:	e8 92 5b 00 00       	call   f0105ddf <cpunum>
f010024d:	83 ec 08             	sub    $0x8,%esp
f0100250:	50                   	push   %eax
f0100251:	68 33 65 10 f0       	push   $0xf0106533
f0100256:	e8 b5 35 00 00       	call   f0103810 <cprintf>

	lapic_init();
f010025b:	e8 9a 5b 00 00       	call   f0105dfa <lapic_init>
	env_init_percpu();
f0100260:	e8 a3 2d 00 00       	call   f0103008 <env_init_percpu>
	trap_init_percpu();
f0100265:	e8 ba 35 00 00       	call   f0103824 <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f010026a:	e8 70 5b 00 00       	call   f0105ddf <cpunum>
f010026f:	6b d0 74             	imul   $0x74,%eax,%edx
f0100272:	81 c2 20 60 24 f0    	add    $0xf0246020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0100278:	b8 01 00 00 00       	mov    $0x1,%eax
f010027d:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f0100281:	c7 04 24 c0 03 12 f0 	movl   $0xf01203c0,(%esp)
f0100288:	e8 c3 5d 00 00       	call   f0106050 <spin_lock>
	// to start running processes on this CPU.  But make sure that
	// only one CPU can enter the scheduler at a time!
	//
	// Your code here:
	lock_kernel();
	sched_yield();
f010028d:	e8 d9 41 00 00       	call   f010446b <sched_yield>

f0100292 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100292:	55                   	push   %ebp
f0100293:	89 e5                	mov    %esp,%ebp
f0100295:	53                   	push   %ebx
f0100296:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0100299:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f010029c:	ff 75 0c             	pushl  0xc(%ebp)
f010029f:	ff 75 08             	pushl  0x8(%ebp)
f01002a2:	68 49 65 10 f0       	push   $0xf0106549
f01002a7:	e8 64 35 00 00       	call   f0103810 <cprintf>
	vcprintf(fmt, ap);
f01002ac:	83 c4 08             	add    $0x8,%esp
f01002af:	53                   	push   %ebx
f01002b0:	ff 75 10             	pushl  0x10(%ebp)
f01002b3:	e8 32 35 00 00       	call   f01037ea <vcprintf>
	cprintf("\n");
f01002b8:	c7 04 24 41 6d 10 f0 	movl   $0xf0106d41,(%esp)
f01002bf:	e8 4c 35 00 00       	call   f0103810 <cprintf>
	va_end(ap);
}
f01002c4:	83 c4 10             	add    $0x10,%esp
f01002c7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01002ca:	c9                   	leave  
f01002cb:	c3                   	ret    

f01002cc <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f01002cc:	55                   	push   %ebp
f01002cd:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002cf:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01002d4:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f01002d5:	a8 01                	test   $0x1,%al
f01002d7:	74 0b                	je     f01002e4 <serial_proc_data+0x18>
f01002d9:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01002de:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f01002df:	0f b6 c0             	movzbl %al,%eax
f01002e2:	eb 05                	jmp    f01002e9 <serial_proc_data+0x1d>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f01002e4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f01002e9:	5d                   	pop    %ebp
f01002ea:	c3                   	ret    

f01002eb <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f01002eb:	55                   	push   %ebp
f01002ec:	89 e5                	mov    %esp,%ebp
f01002ee:	53                   	push   %ebx
f01002ef:	83 ec 04             	sub    $0x4,%esp
f01002f2:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f01002f4:	eb 2b                	jmp    f0100321 <cons_intr+0x36>
		if (c == 0)
f01002f6:	85 c0                	test   %eax,%eax
f01002f8:	74 27                	je     f0100321 <cons_intr+0x36>
			continue;
		cons.buf[cons.wpos++] = c;
f01002fa:	8b 0d 24 52 24 f0    	mov    0xf0245224,%ecx
f0100300:	8d 51 01             	lea    0x1(%ecx),%edx
f0100303:	89 15 24 52 24 f0    	mov    %edx,0xf0245224
f0100309:	88 81 20 50 24 f0    	mov    %al,-0xfdbafe0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f010030f:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f0100315:	75 0a                	jne    f0100321 <cons_intr+0x36>
			cons.wpos = 0;
f0100317:	c7 05 24 52 24 f0 00 	movl   $0x0,0xf0245224
f010031e:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f0100321:	ff d3                	call   *%ebx
f0100323:	83 f8 ff             	cmp    $0xffffffff,%eax
f0100326:	75 ce                	jne    f01002f6 <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f0100328:	83 c4 04             	add    $0x4,%esp
f010032b:	5b                   	pop    %ebx
f010032c:	5d                   	pop    %ebp
f010032d:	c3                   	ret    

f010032e <kbd_proc_data>:
f010032e:	ba 64 00 00 00       	mov    $0x64,%edx
f0100333:	ec                   	in     (%dx),%al
{
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f0100334:	a8 01                	test   $0x1,%al
f0100336:	0f 84 e6 00 00 00    	je     f0100422 <kbd_proc_data+0xf4>
f010033c:	ba 60 00 00 00       	mov    $0x60,%edx
f0100341:	ec                   	in     (%dx),%al
f0100342:	88 c2                	mov    %al,%dl
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f0100344:	3c e0                	cmp    $0xe0,%al
f0100346:	75 0d                	jne    f0100355 <kbd_proc_data+0x27>
		// E0 escape character
		shift |= E0ESC;
f0100348:	83 0d 00 50 24 f0 40 	orl    $0x40,0xf0245000
		return 0;
f010034f:	b8 00 00 00 00       	mov    $0x0,%eax
f0100354:	c3                   	ret    
	} else if (data & 0x80) {
f0100355:	84 c0                	test   %al,%al
f0100357:	79 2e                	jns    f0100387 <kbd_proc_data+0x59>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f0100359:	8b 0d 00 50 24 f0    	mov    0xf0245000,%ecx
f010035f:	f6 c1 40             	test   $0x40,%cl
f0100362:	75 05                	jne    f0100369 <kbd_proc_data+0x3b>
f0100364:	83 e0 7f             	and    $0x7f,%eax
f0100367:	88 c2                	mov    %al,%dl
		shift &= ~(shiftcode[data] | E0ESC);
f0100369:	0f b6 c2             	movzbl %dl,%eax
f010036c:	8a 80 c0 66 10 f0    	mov    -0xfef9940(%eax),%al
f0100372:	83 c8 40             	or     $0x40,%eax
f0100375:	0f b6 c0             	movzbl %al,%eax
f0100378:	f7 d0                	not    %eax
f010037a:	21 c8                	and    %ecx,%eax
f010037c:	a3 00 50 24 f0       	mov    %eax,0xf0245000
		return 0;
f0100381:	b8 00 00 00 00       	mov    $0x0,%eax
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f0100386:	c3                   	ret    
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f0100387:	55                   	push   %ebp
f0100388:	89 e5                	mov    %esp,%ebp
f010038a:	53                   	push   %ebx
f010038b:	83 ec 04             	sub    $0x4,%esp
	} else if (data & 0x80) {
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
		shift &= ~(shiftcode[data] | E0ESC);
		return 0;
	} else if (shift & E0ESC) {
f010038e:	8b 0d 00 50 24 f0    	mov    0xf0245000,%ecx
f0100394:	f6 c1 40             	test   $0x40,%cl
f0100397:	74 0e                	je     f01003a7 <kbd_proc_data+0x79>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100399:	83 c8 80             	or     $0xffffff80,%eax
f010039c:	88 c2                	mov    %al,%dl
		shift &= ~E0ESC;
f010039e:	83 e1 bf             	and    $0xffffffbf,%ecx
f01003a1:	89 0d 00 50 24 f0    	mov    %ecx,0xf0245000
	}

	shift |= shiftcode[data];
f01003a7:	0f b6 c2             	movzbl %dl,%eax
	shift ^= togglecode[data];
f01003aa:	0f b6 90 c0 66 10 f0 	movzbl -0xfef9940(%eax),%edx
f01003b1:	0b 15 00 50 24 f0    	or     0xf0245000,%edx
f01003b7:	0f b6 88 c0 65 10 f0 	movzbl -0xfef9a40(%eax),%ecx
f01003be:	31 ca                	xor    %ecx,%edx
f01003c0:	89 15 00 50 24 f0    	mov    %edx,0xf0245000

	c = charcode[shift & (CTL | SHIFT)][data];
f01003c6:	89 d1                	mov    %edx,%ecx
f01003c8:	83 e1 03             	and    $0x3,%ecx
f01003cb:	8b 0c 8d a0 65 10 f0 	mov    -0xfef9a60(,%ecx,4),%ecx
f01003d2:	8a 04 01             	mov    (%ecx,%eax,1),%al
f01003d5:	0f b6 d8             	movzbl %al,%ebx
	if (shift & CAPSLOCK) {
f01003d8:	f6 c2 08             	test   $0x8,%dl
f01003db:	74 1a                	je     f01003f7 <kbd_proc_data+0xc9>
		if ('a' <= c && c <= 'z')
f01003dd:	89 d8                	mov    %ebx,%eax
f01003df:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f01003e2:	83 f9 19             	cmp    $0x19,%ecx
f01003e5:	77 05                	ja     f01003ec <kbd_proc_data+0xbe>
			c += 'A' - 'a';
f01003e7:	83 eb 20             	sub    $0x20,%ebx
f01003ea:	eb 0b                	jmp    f01003f7 <kbd_proc_data+0xc9>
		else if ('A' <= c && c <= 'Z')
f01003ec:	83 e8 41             	sub    $0x41,%eax
f01003ef:	83 f8 19             	cmp    $0x19,%eax
f01003f2:	77 03                	ja     f01003f7 <kbd_proc_data+0xc9>
			c += 'a' - 'A';
f01003f4:	83 c3 20             	add    $0x20,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01003f7:	f7 d2                	not    %edx
f01003f9:	f6 c2 06             	test   $0x6,%dl
f01003fc:	75 2a                	jne    f0100428 <kbd_proc_data+0xfa>
f01003fe:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f0100404:	75 26                	jne    f010042c <kbd_proc_data+0xfe>
		cprintf("Rebooting!\n");
f0100406:	83 ec 0c             	sub    $0xc,%esp
f0100409:	68 63 65 10 f0       	push   $0xf0106563
f010040e:	e8 fd 33 00 00       	call   f0103810 <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100413:	ba 92 00 00 00       	mov    $0x92,%edx
f0100418:	b0 03                	mov    $0x3,%al
f010041a:	ee                   	out    %al,(%dx)
f010041b:	83 c4 10             	add    $0x10,%esp
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f010041e:	89 d8                	mov    %ebx,%eax
f0100420:	eb 0c                	jmp    f010042e <kbd_proc_data+0x100>
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
		return -1;
f0100422:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100427:	c3                   	ret    
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f0100428:	89 d8                	mov    %ebx,%eax
f010042a:	eb 02                	jmp    f010042e <kbd_proc_data+0x100>
f010042c:	89 d8                	mov    %ebx,%eax
}
f010042e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100431:	c9                   	leave  
f0100432:	c3                   	ret    

f0100433 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f0100433:	55                   	push   %ebp
f0100434:	89 e5                	mov    %esp,%ebp
f0100436:	57                   	push   %edi
f0100437:	56                   	push   %esi
f0100438:	53                   	push   %ebx
f0100439:	83 ec 0c             	sub    $0xc,%esp
f010043c:	89 c1                	mov    %eax,%ecx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010043e:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100443:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f0100444:	a8 20                	test   $0x20,%al
f0100446:	75 1f                	jne    f0100467 <cons_putc+0x34>
f0100448:	bb 00 32 00 00       	mov    $0x3200,%ebx
f010044d:	bf 84 00 00 00       	mov    $0x84,%edi
f0100452:	be fd 03 00 00       	mov    $0x3fd,%esi
f0100457:	89 fa                	mov    %edi,%edx
f0100459:	ec                   	in     (%dx),%al
f010045a:	ec                   	in     (%dx),%al
f010045b:	ec                   	in     (%dx),%al
f010045c:	ec                   	in     (%dx),%al
f010045d:	89 f2                	mov    %esi,%edx
f010045f:	ec                   	in     (%dx),%al
f0100460:	a8 20                	test   $0x20,%al
f0100462:	75 03                	jne    f0100467 <cons_putc+0x34>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f0100464:	4b                   	dec    %ebx
f0100465:	75 f0                	jne    f0100457 <cons_putc+0x24>
f0100467:	89 cf                	mov    %ecx,%edi
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100469:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010046e:	88 c8                	mov    %cl,%al
f0100470:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100471:	ba 79 03 00 00       	mov    $0x379,%edx
f0100476:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f0100477:	84 c0                	test   %al,%al
f0100479:	78 1d                	js     f0100498 <cons_putc+0x65>
f010047b:	bb 00 32 00 00       	mov    $0x3200,%ebx
f0100480:	be 79 03 00 00       	mov    $0x379,%esi
f0100485:	ba 84 00 00 00       	mov    $0x84,%edx
f010048a:	ec                   	in     (%dx),%al
f010048b:	ec                   	in     (%dx),%al
f010048c:	ec                   	in     (%dx),%al
f010048d:	ec                   	in     (%dx),%al
f010048e:	89 f2                	mov    %esi,%edx
f0100490:	ec                   	in     (%dx),%al
f0100491:	84 c0                	test   %al,%al
f0100493:	78 03                	js     f0100498 <cons_putc+0x65>
f0100495:	4b                   	dec    %ebx
f0100496:	75 ed                	jne    f0100485 <cons_putc+0x52>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100498:	ba 78 03 00 00       	mov    $0x378,%edx
f010049d:	89 f8                	mov    %edi,%eax
f010049f:	ee                   	out    %al,(%dx)
f01004a0:	ba 7a 03 00 00       	mov    $0x37a,%edx
f01004a5:	b0 0d                	mov    $0xd,%al
f01004a7:	ee                   	out    %al,(%dx)
f01004a8:	b0 08                	mov    $0x8,%al
f01004aa:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f01004ab:	f7 c1 00 ff ff ff    	test   $0xffffff00,%ecx
f01004b1:	75 03                	jne    f01004b6 <cons_putc+0x83>
		c |= 0x0700;
f01004b3:	80 cd 07             	or     $0x7,%ch

	switch (c & 0xff) {
f01004b6:	0f b6 c1             	movzbl %cl,%eax
f01004b9:	83 f8 09             	cmp    $0x9,%eax
f01004bc:	74 77                	je     f0100535 <cons_putc+0x102>
f01004be:	83 f8 09             	cmp    $0x9,%eax
f01004c1:	7f 0a                	jg     f01004cd <cons_putc+0x9a>
f01004c3:	83 f8 08             	cmp    $0x8,%eax
f01004c6:	74 14                	je     f01004dc <cons_putc+0xa9>
f01004c8:	e9 9c 00 00 00       	jmp    f0100569 <cons_putc+0x136>
f01004cd:	83 f8 0a             	cmp    $0xa,%eax
f01004d0:	74 3a                	je     f010050c <cons_putc+0xd9>
f01004d2:	83 f8 0d             	cmp    $0xd,%eax
f01004d5:	74 3d                	je     f0100514 <cons_putc+0xe1>
f01004d7:	e9 8d 00 00 00       	jmp    f0100569 <cons_putc+0x136>
	case '\b':
		if (crt_pos > 0) {
f01004dc:	66 a1 28 52 24 f0    	mov    0xf0245228,%ax
f01004e2:	66 85 c0             	test   %ax,%ax
f01004e5:	0f 84 e9 00 00 00    	je     f01005d4 <cons_putc+0x1a1>
			crt_pos--;
f01004eb:	48                   	dec    %eax
f01004ec:	66 a3 28 52 24 f0    	mov    %ax,0xf0245228
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01004f2:	0f b7 c0             	movzwl %ax,%eax
f01004f5:	89 cf                	mov    %ecx,%edi
f01004f7:	81 e7 00 ff ff ff    	and    $0xffffff00,%edi
f01004fd:	83 cf 20             	or     $0x20,%edi
f0100500:	8b 15 2c 52 24 f0    	mov    0xf024522c,%edx
f0100506:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f010050a:	eb 7a                	jmp    f0100586 <cons_putc+0x153>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f010050c:	66 83 05 28 52 24 f0 	addw   $0x50,0xf0245228
f0100513:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f0100514:	66 8b 0d 28 52 24 f0 	mov    0xf0245228,%cx
f010051b:	bb 50 00 00 00       	mov    $0x50,%ebx
f0100520:	89 c8                	mov    %ecx,%eax
f0100522:	ba 00 00 00 00       	mov    $0x0,%edx
f0100527:	66 f7 f3             	div    %bx
f010052a:	29 d1                	sub    %edx,%ecx
f010052c:	66 89 0d 28 52 24 f0 	mov    %cx,0xf0245228
f0100533:	eb 51                	jmp    f0100586 <cons_putc+0x153>
		break;
	case '\t':
		cons_putc(' ');
f0100535:	b8 20 00 00 00       	mov    $0x20,%eax
f010053a:	e8 f4 fe ff ff       	call   f0100433 <cons_putc>
		cons_putc(' ');
f010053f:	b8 20 00 00 00       	mov    $0x20,%eax
f0100544:	e8 ea fe ff ff       	call   f0100433 <cons_putc>
		cons_putc(' ');
f0100549:	b8 20 00 00 00       	mov    $0x20,%eax
f010054e:	e8 e0 fe ff ff       	call   f0100433 <cons_putc>
		cons_putc(' ');
f0100553:	b8 20 00 00 00       	mov    $0x20,%eax
f0100558:	e8 d6 fe ff ff       	call   f0100433 <cons_putc>
		cons_putc(' ');
f010055d:	b8 20 00 00 00       	mov    $0x20,%eax
f0100562:	e8 cc fe ff ff       	call   f0100433 <cons_putc>
f0100567:	eb 1d                	jmp    f0100586 <cons_putc+0x153>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f0100569:	66 a1 28 52 24 f0    	mov    0xf0245228,%ax
f010056f:	8d 50 01             	lea    0x1(%eax),%edx
f0100572:	66 89 15 28 52 24 f0 	mov    %dx,0xf0245228
f0100579:	0f b7 c0             	movzwl %ax,%eax
f010057c:	8b 15 2c 52 24 f0    	mov    0xf024522c,%edx
f0100582:	66 89 0c 42          	mov    %cx,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100586:	66 81 3d 28 52 24 f0 	cmpw   $0x7cf,0xf0245228
f010058d:	cf 07 
f010058f:	76 43                	jbe    f01005d4 <cons_putc+0x1a1>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100591:	a1 2c 52 24 f0       	mov    0xf024522c,%eax
f0100596:	83 ec 04             	sub    $0x4,%esp
f0100599:	68 00 0f 00 00       	push   $0xf00
f010059e:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f01005a4:	52                   	push   %edx
f01005a5:	50                   	push   %eax
f01005a6:	e8 07 52 00 00       	call   f01057b2 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f01005ab:	8b 15 2c 52 24 f0    	mov    0xf024522c,%edx
f01005b1:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f01005b7:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f01005bd:	83 c4 10             	add    $0x10,%esp
f01005c0:	66 c7 00 20 07       	movw   $0x720,(%eax)
f01005c5:	83 c0 02             	add    $0x2,%eax
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01005c8:	39 d0                	cmp    %edx,%eax
f01005ca:	75 f4                	jne    f01005c0 <cons_putc+0x18d>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f01005cc:	66 83 2d 28 52 24 f0 	subw   $0x50,0xf0245228
f01005d3:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f01005d4:	8b 0d 30 52 24 f0    	mov    0xf0245230,%ecx
f01005da:	b0 0e                	mov    $0xe,%al
f01005dc:	89 ca                	mov    %ecx,%edx
f01005de:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01005df:	8d 59 01             	lea    0x1(%ecx),%ebx
f01005e2:	66 a1 28 52 24 f0    	mov    0xf0245228,%ax
f01005e8:	66 c1 e8 08          	shr    $0x8,%ax
f01005ec:	89 da                	mov    %ebx,%edx
f01005ee:	ee                   	out    %al,(%dx)
f01005ef:	b0 0f                	mov    $0xf,%al
f01005f1:	89 ca                	mov    %ecx,%edx
f01005f3:	ee                   	out    %al,(%dx)
f01005f4:	a0 28 52 24 f0       	mov    0xf0245228,%al
f01005f9:	89 da                	mov    %ebx,%edx
f01005fb:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01005fc:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01005ff:	5b                   	pop    %ebx
f0100600:	5e                   	pop    %esi
f0100601:	5f                   	pop    %edi
f0100602:	5d                   	pop    %ebp
f0100603:	c3                   	ret    

f0100604 <serial_intr>:
}

void
serial_intr(void)
{
	if (serial_exists)
f0100604:	80 3d 34 52 24 f0 00 	cmpb   $0x0,0xf0245234
f010060b:	74 11                	je     f010061e <serial_intr+0x1a>
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f010060d:	55                   	push   %ebp
f010060e:	89 e5                	mov    %esp,%ebp
f0100610:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
		cons_intr(serial_proc_data);
f0100613:	b8 cc 02 10 f0       	mov    $0xf01002cc,%eax
f0100618:	e8 ce fc ff ff       	call   f01002eb <cons_intr>
}
f010061d:	c9                   	leave  
f010061e:	c3                   	ret    

f010061f <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f010061f:	55                   	push   %ebp
f0100620:	89 e5                	mov    %esp,%ebp
f0100622:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f0100625:	b8 2e 03 10 f0       	mov    $0xf010032e,%eax
f010062a:	e8 bc fc ff ff       	call   f01002eb <cons_intr>
}
f010062f:	c9                   	leave  
f0100630:	c3                   	ret    

f0100631 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f0100631:	55                   	push   %ebp
f0100632:	89 e5                	mov    %esp,%ebp
f0100634:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f0100637:	e8 c8 ff ff ff       	call   f0100604 <serial_intr>
	kbd_intr();
f010063c:	e8 de ff ff ff       	call   f010061f <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f0100641:	a1 20 52 24 f0       	mov    0xf0245220,%eax
f0100646:	3b 05 24 52 24 f0    	cmp    0xf0245224,%eax
f010064c:	74 24                	je     f0100672 <cons_getc+0x41>
		c = cons.buf[cons.rpos++];
f010064e:	8d 50 01             	lea    0x1(%eax),%edx
f0100651:	89 15 20 52 24 f0    	mov    %edx,0xf0245220
f0100657:	0f b6 80 20 50 24 f0 	movzbl -0xfdbafe0(%eax),%eax
		if (cons.rpos == CONSBUFSIZE)
f010065e:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f0100664:	75 11                	jne    f0100677 <cons_getc+0x46>
			cons.rpos = 0;
f0100666:	c7 05 20 52 24 f0 00 	movl   $0x0,0xf0245220
f010066d:	00 00 00 
f0100670:	eb 05                	jmp    f0100677 <cons_getc+0x46>
		return c;
	}
	return 0;
f0100672:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100677:	c9                   	leave  
f0100678:	c3                   	ret    

f0100679 <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f0100679:	55                   	push   %ebp
f010067a:	89 e5                	mov    %esp,%ebp
f010067c:	56                   	push   %esi
f010067d:	53                   	push   %ebx
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f010067e:	66 8b 15 00 80 0b f0 	mov    0xf00b8000,%dx
	*cp = (uint16_t) 0xA55A;
f0100685:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f010068c:	5a a5 
	if (*cp != 0xA55A) {
f010068e:	66 a1 00 80 0b f0    	mov    0xf00b8000,%ax
f0100694:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100698:	74 11                	je     f01006ab <cons_init+0x32>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f010069a:	c7 05 30 52 24 f0 b4 	movl   $0x3b4,0xf0245230
f01006a1:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f01006a4:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f01006a9:	eb 16                	jmp    f01006c1 <cons_init+0x48>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f01006ab:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f01006b2:	c7 05 30 52 24 f0 d4 	movl   $0x3d4,0xf0245230
f01006b9:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f01006bc:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
f01006c1:	b0 0e                	mov    $0xe,%al
f01006c3:	8b 15 30 52 24 f0    	mov    0xf0245230,%edx
f01006c9:	ee                   	out    %al,(%dx)
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
	pos = inb(addr_6845 + 1) << 8;
f01006ca:	8d 5a 01             	lea    0x1(%edx),%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006cd:	89 da                	mov    %ebx,%edx
f01006cf:	ec                   	in     (%dx),%al
f01006d0:	0f b6 c8             	movzbl %al,%ecx
f01006d3:	c1 e1 08             	shl    $0x8,%ecx
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006d6:	b0 0f                	mov    $0xf,%al
f01006d8:	8b 15 30 52 24 f0    	mov    0xf0245230,%edx
f01006de:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006df:	89 da                	mov    %ebx,%edx
f01006e1:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f01006e2:	89 35 2c 52 24 f0    	mov    %esi,0xf024522c
	crt_pos = pos;
f01006e8:	0f b6 c0             	movzbl %al,%eax
f01006eb:	09 c8                	or     %ecx,%eax
f01006ed:	66 a3 28 52 24 f0    	mov    %ax,0xf0245228

static void
kbd_init(void)
{
	// Drain the kbd buffer so that Bochs generates interrupts.
	kbd_intr();
f01006f3:	e8 27 ff ff ff       	call   f010061f <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<1));
f01006f8:	83 ec 0c             	sub    $0xc,%esp
f01006fb:	66 a1 a8 03 12 f0    	mov    0xf01203a8,%ax
f0100701:	25 fd ff 00 00       	and    $0xfffd,%eax
f0100706:	50                   	push   %eax
f0100707:	e8 d9 2f 00 00       	call   f01036e5 <irq_setmask_8259A>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010070c:	be fa 03 00 00       	mov    $0x3fa,%esi
f0100711:	b0 00                	mov    $0x0,%al
f0100713:	89 f2                	mov    %esi,%edx
f0100715:	ee                   	out    %al,(%dx)
f0100716:	ba fb 03 00 00       	mov    $0x3fb,%edx
f010071b:	b0 80                	mov    $0x80,%al
f010071d:	ee                   	out    %al,(%dx)
f010071e:	bb f8 03 00 00       	mov    $0x3f8,%ebx
f0100723:	b0 0c                	mov    $0xc,%al
f0100725:	89 da                	mov    %ebx,%edx
f0100727:	ee                   	out    %al,(%dx)
f0100728:	ba f9 03 00 00       	mov    $0x3f9,%edx
f010072d:	b0 00                	mov    $0x0,%al
f010072f:	ee                   	out    %al,(%dx)
f0100730:	ba fb 03 00 00       	mov    $0x3fb,%edx
f0100735:	b0 03                	mov    $0x3,%al
f0100737:	ee                   	out    %al,(%dx)
f0100738:	ba fc 03 00 00       	mov    $0x3fc,%edx
f010073d:	b0 00                	mov    $0x0,%al
f010073f:	ee                   	out    %al,(%dx)
f0100740:	ba f9 03 00 00       	mov    $0x3f9,%edx
f0100745:	b0 01                	mov    $0x1,%al
f0100747:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100748:	ba fd 03 00 00       	mov    $0x3fd,%edx
f010074d:	ec                   	in     (%dx),%al
f010074e:	88 c1                	mov    %al,%cl
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f0100750:	83 c4 10             	add    $0x10,%esp
f0100753:	3c ff                	cmp    $0xff,%al
f0100755:	0f 95 05 34 52 24 f0 	setne  0xf0245234
f010075c:	89 f2                	mov    %esi,%edx
f010075e:	ec                   	in     (%dx),%al
f010075f:	89 da                	mov    %ebx,%edx
f0100761:	ec                   	in     (%dx),%al
	(void) inb(COM1+COM_IIR);
	(void) inb(COM1+COM_RX);

	// Enable serial interrupts
	if (serial_exists)
f0100762:	80 f9 ff             	cmp    $0xff,%cl
f0100765:	74 20                	je     f0100787 <cons_init+0x10e>
		irq_setmask_8259A(irq_mask_8259A & ~(1<<4));
f0100767:	83 ec 0c             	sub    $0xc,%esp
f010076a:	66 a1 a8 03 12 f0    	mov    0xf01203a8,%ax
f0100770:	25 ef ff 00 00       	and    $0xffef,%eax
f0100775:	50                   	push   %eax
f0100776:	e8 6a 2f 00 00       	call   f01036e5 <irq_setmask_8259A>
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f010077b:	83 c4 10             	add    $0x10,%esp
f010077e:	80 3d 34 52 24 f0 00 	cmpb   $0x0,0xf0245234
f0100785:	75 10                	jne    f0100797 <cons_init+0x11e>
		cprintf("Serial port does not exist!\n");
f0100787:	83 ec 0c             	sub    $0xc,%esp
f010078a:	68 6f 65 10 f0       	push   $0xf010656f
f010078f:	e8 7c 30 00 00       	call   f0103810 <cprintf>
f0100794:	83 c4 10             	add    $0x10,%esp
}
f0100797:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010079a:	5b                   	pop    %ebx
f010079b:	5e                   	pop    %esi
f010079c:	5d                   	pop    %ebp
f010079d:	c3                   	ret    

f010079e <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f010079e:	55                   	push   %ebp
f010079f:	89 e5                	mov    %esp,%ebp
f01007a1:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f01007a4:	8b 45 08             	mov    0x8(%ebp),%eax
f01007a7:	e8 87 fc ff ff       	call   f0100433 <cons_putc>
}
f01007ac:	c9                   	leave  
f01007ad:	c3                   	ret    

f01007ae <getchar>:

int
getchar(void)
{
f01007ae:	55                   	push   %ebp
f01007af:	89 e5                	mov    %esp,%ebp
f01007b1:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f01007b4:	e8 78 fe ff ff       	call   f0100631 <cons_getc>
f01007b9:	85 c0                	test   %eax,%eax
f01007bb:	74 f7                	je     f01007b4 <getchar+0x6>
		/* do nothing */;
	return c;
}
f01007bd:	c9                   	leave  
f01007be:	c3                   	ret    

f01007bf <iscons>:

int
iscons(int fdnum)
{
f01007bf:	55                   	push   %ebp
f01007c0:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f01007c2:	b8 01 00 00 00       	mov    $0x1,%eax
f01007c7:	5d                   	pop    %ebp
f01007c8:	c3                   	ret    

f01007c9 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f01007c9:	55                   	push   %ebp
f01007ca:	89 e5                	mov    %esp,%ebp
f01007cc:	83 ec 0c             	sub    $0xc,%esp
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f01007cf:	68 c0 67 10 f0       	push   $0xf01067c0
f01007d4:	68 de 67 10 f0       	push   $0xf01067de
f01007d9:	68 e3 67 10 f0       	push   $0xf01067e3
f01007de:	e8 2d 30 00 00       	call   f0103810 <cprintf>
f01007e3:	83 c4 0c             	add    $0xc,%esp
f01007e6:	68 84 68 10 f0       	push   $0xf0106884
f01007eb:	68 ec 67 10 f0       	push   $0xf01067ec
f01007f0:	68 e3 67 10 f0       	push   $0xf01067e3
f01007f5:	e8 16 30 00 00       	call   f0103810 <cprintf>
f01007fa:	83 c4 0c             	add    $0xc,%esp
f01007fd:	68 ac 68 10 f0       	push   $0xf01068ac
f0100802:	68 f5 67 10 f0       	push   $0xf01067f5
f0100807:	68 e3 67 10 f0       	push   $0xf01067e3
f010080c:	e8 ff 2f 00 00       	call   f0103810 <cprintf>
	return 0;
}
f0100811:	b8 00 00 00 00       	mov    $0x0,%eax
f0100816:	c9                   	leave  
f0100817:	c3                   	ret    

f0100818 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f0100818:	55                   	push   %ebp
f0100819:	89 e5                	mov    %esp,%ebp
f010081b:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f010081e:	68 ff 67 10 f0       	push   $0xf01067ff
f0100823:	e8 e8 2f 00 00       	call   f0103810 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100828:	83 c4 08             	add    $0x8,%esp
f010082b:	68 0c 00 10 00       	push   $0x10000c
f0100830:	68 d0 68 10 f0       	push   $0xf01068d0
f0100835:	e8 d6 2f 00 00       	call   f0103810 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f010083a:	83 c4 0c             	add    $0xc,%esp
f010083d:	68 0c 00 10 00       	push   $0x10000c
f0100842:	68 0c 00 10 f0       	push   $0xf010000c
f0100847:	68 f8 68 10 f0       	push   $0xf01068f8
f010084c:	e8 bf 2f 00 00       	call   f0103810 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100851:	83 c4 0c             	add    $0xc,%esp
f0100854:	68 85 64 10 00       	push   $0x106485
f0100859:	68 85 64 10 f0       	push   $0xf0106485
f010085e:	68 1c 69 10 f0       	push   $0xf010691c
f0100863:	e8 a8 2f 00 00       	call   f0103810 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100868:	83 c4 0c             	add    $0xc,%esp
f010086b:	68 18 4b 24 00       	push   $0x244b18
f0100870:	68 18 4b 24 f0       	push   $0xf0244b18
f0100875:	68 40 69 10 f0       	push   $0xf0106940
f010087a:	e8 91 2f 00 00       	call   f0103810 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010087f:	83 c4 0c             	add    $0xc,%esp
f0100882:	68 08 70 28 00       	push   $0x287008
f0100887:	68 08 70 28 f0       	push   $0xf0287008
f010088c:	68 64 69 10 f0       	push   $0xf0106964
f0100891:	e8 7a 2f 00 00       	call   f0103810 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f0100896:	b8 07 74 28 f0       	mov    $0xf0287407,%eax
f010089b:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f01008a0:	83 c4 08             	add    $0x8,%esp
f01008a3:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f01008a8:	89 c2                	mov    %eax,%edx
f01008aa:	85 c0                	test   %eax,%eax
f01008ac:	79 06                	jns    f01008b4 <mon_kerninfo+0x9c>
f01008ae:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f01008b4:	c1 fa 0a             	sar    $0xa,%edx
f01008b7:	52                   	push   %edx
f01008b8:	68 88 69 10 f0       	push   $0xf0106988
f01008bd:	e8 4e 2f 00 00       	call   f0103810 <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f01008c2:	b8 00 00 00 00       	mov    $0x0,%eax
f01008c7:	c9                   	leave  
f01008c8:	c3                   	ret    

f01008c9 <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f01008c9:	55                   	push   %ebp
f01008ca:	89 e5                	mov    %esp,%ebp
f01008cc:	56                   	push   %esi
f01008cd:	53                   	push   %ebx

static __inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	__asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f01008ce:	89 e8                	mov    %ebp,%eax
	//The ebp value of the program, which calls the mon_backtrace
	int regebp = read_ebp();
	regebp = *((int *)regebp);
f01008d0:	8b 30                	mov    (%eax),%esi
	int *ebp = (int *)regebp;
	
	cprintf("Stack backtrace:\n");
f01008d2:	83 ec 0c             	sub    $0xc,%esp
f01008d5:	68 18 68 10 f0       	push   $0xf0106818
f01008da:	e8 31 2f 00 00       	call   f0103810 <cprintf>
	//If only we haven't pass the stack frame of i386_init
	while((int)ebp != 0x0) {
f01008df:	83 c4 10             	add    $0x10,%esp
f01008e2:	85 f6                	test   %esi,%esi
f01008e4:	0f 84 8d 00 00 00    	je     f0100977 <mon_backtrace+0xae>
f01008ea:	89 f3                	mov    %esi,%ebx
f01008ec:	89 f0                	mov    %esi,%eax
		cprintf("  ebp %08x", (int)ebp);
f01008ee:	83 ec 08             	sub    $0x8,%esp
f01008f1:	50                   	push   %eax
f01008f2:	68 2a 68 10 f0       	push   $0xf010682a
f01008f7:	e8 14 2f 00 00       	call   f0103810 <cprintf>
		cprintf("  eip %08x", *(ebp+1));
f01008fc:	83 c4 08             	add    $0x8,%esp
f01008ff:	ff 73 04             	pushl  0x4(%ebx)
f0100902:	68 35 68 10 f0       	push   $0xf0106835
f0100907:	e8 04 2f 00 00       	call   f0103810 <cprintf>
		cprintf("  args");
f010090c:	c7 04 24 40 68 10 f0 	movl   $0xf0106840,(%esp)
f0100913:	e8 f8 2e 00 00       	call   f0103810 <cprintf>
		cprintf(" %08x", *(ebp+2));
f0100918:	83 c4 08             	add    $0x8,%esp
f010091b:	ff 73 08             	pushl  0x8(%ebx)
f010091e:	68 2f 68 10 f0       	push   $0xf010682f
f0100923:	e8 e8 2e 00 00       	call   f0103810 <cprintf>
		cprintf(" %08x", *(ebp+3));
f0100928:	83 c4 08             	add    $0x8,%esp
f010092b:	ff 73 0c             	pushl  0xc(%ebx)
f010092e:	68 2f 68 10 f0       	push   $0xf010682f
f0100933:	e8 d8 2e 00 00       	call   f0103810 <cprintf>
		cprintf(" %08x", *(ebp+4));
f0100938:	83 c4 08             	add    $0x8,%esp
f010093b:	ff 73 10             	pushl  0x10(%ebx)
f010093e:	68 2f 68 10 f0       	push   $0xf010682f
f0100943:	e8 c8 2e 00 00       	call   f0103810 <cprintf>
		cprintf(" %08x", *(ebp+5));
f0100948:	83 c4 08             	add    $0x8,%esp
f010094b:	ff 73 14             	pushl  0x14(%ebx)
f010094e:	68 2f 68 10 f0       	push   $0xf010682f
f0100953:	e8 b8 2e 00 00       	call   f0103810 <cprintf>
		cprintf(" %08x\n", *(ebp+6));
f0100958:	83 c4 08             	add    $0x8,%esp
f010095b:	ff 73 18             	pushl  0x18(%ebx)
f010095e:	68 10 81 10 f0       	push   $0xf0108110
f0100963:	e8 a8 2e 00 00       	call   f0103810 <cprintf>
		ebp = (int *)(*ebp);
f0100968:	8b 03                	mov    (%ebx),%eax
f010096a:	89 c3                	mov    %eax,%ebx
	regebp = *((int *)regebp);
	int *ebp = (int *)regebp;
	
	cprintf("Stack backtrace:\n");
	//If only we haven't pass the stack frame of i386_init
	while((int)ebp != 0x0) {
f010096c:	83 c4 10             	add    $0x10,%esp
f010096f:	85 c0                	test   %eax,%eax
f0100971:	0f 85 77 ff ff ff    	jne    f01008ee <mon_backtrace+0x25>
		cprintf(" %08x", *(ebp+5));
		cprintf(" %08x\n", *(ebp+6));
		ebp = (int *)(*ebp);
	}
	return 0;
}
f0100977:	b8 00 00 00 00       	mov    $0x0,%eax
f010097c:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010097f:	5b                   	pop    %ebx
f0100980:	5e                   	pop    %esi
f0100981:	5d                   	pop    %ebp
f0100982:	c3                   	ret    

f0100983 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100983:	55                   	push   %ebp
f0100984:	89 e5                	mov    %esp,%ebp
f0100986:	57                   	push   %edi
f0100987:	56                   	push   %esi
f0100988:	53                   	push   %ebx
f0100989:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f010098c:	68 b4 69 10 f0       	push   $0xf01069b4
f0100991:	e8 7a 2e 00 00       	call   f0103810 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100996:	c7 04 24 d8 69 10 f0 	movl   $0xf01069d8,(%esp)
f010099d:	e8 6e 2e 00 00       	call   f0103810 <cprintf>

	if (tf != NULL)
f01009a2:	83 c4 10             	add    $0x10,%esp
f01009a5:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f01009a9:	74 0e                	je     f01009b9 <monitor+0x36>
		print_trapframe(tf);
f01009ab:	83 ec 0c             	sub    $0xc,%esp
f01009ae:	ff 75 08             	pushl  0x8(%ebp)
f01009b1:	e8 58 34 00 00       	call   f0103e0e <print_trapframe>
f01009b6:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f01009b9:	83 ec 0c             	sub    $0xc,%esp
f01009bc:	68 47 68 10 f0       	push   $0xf0106847
f01009c1:	e8 c4 4a 00 00       	call   f010548a <readline>
f01009c6:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f01009c8:	83 c4 10             	add    $0x10,%esp
f01009cb:	85 c0                	test   %eax,%eax
f01009cd:	74 ea                	je     f01009b9 <monitor+0x36>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f01009cf:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f01009d6:	be 00 00 00 00       	mov    $0x0,%esi
f01009db:	eb 0a                	jmp    f01009e7 <monitor+0x64>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f01009dd:	c6 03 00             	movb   $0x0,(%ebx)
f01009e0:	89 f7                	mov    %esi,%edi
f01009e2:	8d 5b 01             	lea    0x1(%ebx),%ebx
f01009e5:	89 fe                	mov    %edi,%esi
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f01009e7:	8a 03                	mov    (%ebx),%al
f01009e9:	84 c0                	test   %al,%al
f01009eb:	74 66                	je     f0100a53 <monitor+0xd0>
f01009ed:	83 ec 08             	sub    $0x8,%esp
f01009f0:	0f be c0             	movsbl %al,%eax
f01009f3:	50                   	push   %eax
f01009f4:	68 4b 68 10 f0       	push   $0xf010684b
f01009f9:	e8 0f 4d 00 00       	call   f010570d <strchr>
f01009fe:	83 c4 10             	add    $0x10,%esp
f0100a01:	85 c0                	test   %eax,%eax
f0100a03:	75 d8                	jne    f01009dd <monitor+0x5a>
			*buf++ = 0;
		if (*buf == 0)
f0100a05:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100a08:	74 49                	je     f0100a53 <monitor+0xd0>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f0100a0a:	83 fe 0f             	cmp    $0xf,%esi
f0100a0d:	75 14                	jne    f0100a23 <monitor+0xa0>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100a0f:	83 ec 08             	sub    $0x8,%esp
f0100a12:	6a 10                	push   $0x10
f0100a14:	68 50 68 10 f0       	push   $0xf0106850
f0100a19:	e8 f2 2d 00 00       	call   f0103810 <cprintf>
f0100a1e:	83 c4 10             	add    $0x10,%esp
f0100a21:	eb 96                	jmp    f01009b9 <monitor+0x36>
			return 0;
		}
		argv[argc++] = buf;
f0100a23:	8d 7e 01             	lea    0x1(%esi),%edi
f0100a26:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
		while (*buf && !strchr(WHITESPACE, *buf))
f0100a2a:	8a 03                	mov    (%ebx),%al
f0100a2c:	84 c0                	test   %al,%al
f0100a2e:	75 09                	jne    f0100a39 <monitor+0xb6>
f0100a30:	eb b3                	jmp    f01009e5 <monitor+0x62>
			buf++;
f0100a32:	43                   	inc    %ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f0100a33:	8a 03                	mov    (%ebx),%al
f0100a35:	84 c0                	test   %al,%al
f0100a37:	74 ac                	je     f01009e5 <monitor+0x62>
f0100a39:	83 ec 08             	sub    $0x8,%esp
f0100a3c:	0f be c0             	movsbl %al,%eax
f0100a3f:	50                   	push   %eax
f0100a40:	68 4b 68 10 f0       	push   $0xf010684b
f0100a45:	e8 c3 4c 00 00       	call   f010570d <strchr>
f0100a4a:	83 c4 10             	add    $0x10,%esp
f0100a4d:	85 c0                	test   %eax,%eax
f0100a4f:	74 e1                	je     f0100a32 <monitor+0xaf>
f0100a51:	eb 92                	jmp    f01009e5 <monitor+0x62>
			buf++;
	}
	argv[argc] = 0;
f0100a53:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100a5a:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100a5b:	85 f6                	test   %esi,%esi
f0100a5d:	0f 84 56 ff ff ff    	je     f01009b9 <monitor+0x36>
f0100a63:	bf 00 6a 10 f0       	mov    $0xf0106a00,%edi
f0100a68:	bb 00 00 00 00       	mov    $0x0,%ebx
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100a6d:	83 ec 08             	sub    $0x8,%esp
f0100a70:	ff 37                	pushl  (%edi)
f0100a72:	ff 75 a8             	pushl  -0x58(%ebp)
f0100a75:	e8 1b 4c 00 00       	call   f0105695 <strcmp>
f0100a7a:	83 c4 10             	add    $0x10,%esp
f0100a7d:	85 c0                	test   %eax,%eax
f0100a7f:	75 23                	jne    f0100aa4 <monitor+0x121>
			return commands[i].func(argc, argv, tf);
f0100a81:	83 ec 04             	sub    $0x4,%esp
f0100a84:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
f0100a87:	01 c3                	add    %eax,%ebx
f0100a89:	ff 75 08             	pushl  0x8(%ebp)
f0100a8c:	8d 45 a8             	lea    -0x58(%ebp),%eax
f0100a8f:	50                   	push   %eax
f0100a90:	56                   	push   %esi
f0100a91:	ff 14 9d 08 6a 10 f0 	call   *-0xfef95f8(,%ebx,4)
		print_trapframe(tf);

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100a98:	83 c4 10             	add    $0x10,%esp
f0100a9b:	85 c0                	test   %eax,%eax
f0100a9d:	78 26                	js     f0100ac5 <monitor+0x142>
f0100a9f:	e9 15 ff ff ff       	jmp    f01009b9 <monitor+0x36>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f0100aa4:	43                   	inc    %ebx
f0100aa5:	83 c7 0c             	add    $0xc,%edi
f0100aa8:	83 fb 03             	cmp    $0x3,%ebx
f0100aab:	75 c0                	jne    f0100a6d <monitor+0xea>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100aad:	83 ec 08             	sub    $0x8,%esp
f0100ab0:	ff 75 a8             	pushl  -0x58(%ebp)
f0100ab3:	68 6d 68 10 f0       	push   $0xf010686d
f0100ab8:	e8 53 2d 00 00       	call   f0103810 <cprintf>
f0100abd:	83 c4 10             	add    $0x10,%esp
f0100ac0:	e9 f4 fe ff ff       	jmp    f01009b9 <monitor+0x36>
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}

}
f0100ac5:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100ac8:	5b                   	pop    %ebx
f0100ac9:	5e                   	pop    %esi
f0100aca:	5f                   	pop    %edi
f0100acb:	5d                   	pop    %ebp
f0100acc:	c3                   	ret    

f0100acd <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100acd:	55                   	push   %ebp
f0100ace:	89 e5                	mov    %esp,%ebp
f0100ad0:	53                   	push   %ebx
f0100ad1:	83 ec 04             	sub    $0x4,%esp
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100ad4:	83 3d 38 52 24 f0 00 	cmpl   $0x0,0xf0245238
f0100adb:	75 11                	jne    f0100aee <boot_alloc+0x21>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100add:	ba 07 80 28 f0       	mov    $0xf0288007,%edx
f0100ae2:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100ae8:	89 15 38 52 24 f0    	mov    %edx,0xf0245238
	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	result = nextfree;
f0100aee:	8b 1d 38 52 24 f0    	mov    0xf0245238,%ebx
	nextfree = ROUNDUP(nextfree+n, PGSIZE);
f0100af4:	8d 94 03 ff 0f 00 00 	lea    0xfff(%ebx,%eax,1),%edx
f0100afb:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100b01:	89 15 38 52 24 f0    	mov    %edx,0xf0245238
	if((uint32_t)nextfree-KERNBASE > (npages * PGSIZE)) {
f0100b07:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f0100b0d:	8b 0d 88 5e 24 f0    	mov    0xf0245e88,%ecx
f0100b13:	c1 e1 0c             	shl    $0xc,%ecx
f0100b16:	39 ca                	cmp    %ecx,%edx
f0100b18:	76 14                	jbe    f0100b2e <boot_alloc+0x61>
		panic("Out of memory!\n");
f0100b1a:	83 ec 04             	sub    $0x4,%esp
f0100b1d:	68 24 6a 10 f0       	push   $0xf0106a24
f0100b22:	6a 6b                	push   $0x6b
f0100b24:	68 34 6a 10 f0       	push   $0xf0106a34
f0100b29:	e8 12 f5 ff ff       	call   f0100040 <_panic>
	}
	return result;
}
f0100b2e:	89 d8                	mov    %ebx,%eax
f0100b30:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100b33:	c9                   	leave  
f0100b34:	c3                   	ret    

f0100b35 <check_va2pa>:
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
f0100b35:	89 d1                	mov    %edx,%ecx
f0100b37:	c1 e9 16             	shr    $0x16,%ecx
f0100b3a:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100b3d:	a8 01                	test   $0x1,%al
f0100b3f:	74 47                	je     f0100b88 <check_va2pa+0x53>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100b41:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100b46:	89 c1                	mov    %eax,%ecx
f0100b48:	c1 e9 0c             	shr    $0xc,%ecx
f0100b4b:	3b 0d 88 5e 24 f0    	cmp    0xf0245e88,%ecx
f0100b51:	72 1b                	jb     f0100b6e <check_va2pa+0x39>
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100b53:	55                   	push   %ebp
f0100b54:	89 e5                	mov    %esp,%ebp
f0100b56:	83 ec 08             	sub    $0x8,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100b59:	50                   	push   %eax
f0100b5a:	68 c4 64 10 f0       	push   $0xf01064c4
f0100b5f:	68 95 03 00 00       	push   $0x395
f0100b64:	68 34 6a 10 f0       	push   $0xf0106a34
f0100b69:	e8 d2 f4 ff ff       	call   f0100040 <_panic>

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
f0100b6e:	c1 ea 0c             	shr    $0xc,%edx
f0100b71:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100b77:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100b7e:	a8 01                	test   $0x1,%al
f0100b80:	74 0c                	je     f0100b8e <check_va2pa+0x59>
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100b82:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100b87:	c3                   	ret    
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
f0100b88:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100b8d:	c3                   	ret    
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
		return ~0;
f0100b8e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return PTE_ADDR(p[PTX(va)]);
}
f0100b93:	c3                   	ret    

f0100b94 <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0100b94:	55                   	push   %ebp
f0100b95:	89 e5                	mov    %esp,%ebp
f0100b97:	57                   	push   %edi
f0100b98:	56                   	push   %esi
f0100b99:	53                   	push   %ebx
f0100b9a:	83 ec 2c             	sub    $0x2c,%esp
//	cprintf("\nEntering check_page_free_list\n");

	struct PageInfo *pp = NULL;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100b9d:	84 c0                	test   %al,%al
f0100b9f:	0f 85 c4 02 00 00    	jne    f0100e69 <check_page_free_list+0x2d5>
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100ba5:	8b 1d 40 52 24 f0    	mov    0xf0245240,%ebx
f0100bab:	85 db                	test   %ebx,%ebx
f0100bad:	75 6c                	jne    f0100c1b <check_page_free_list+0x87>
		panic("'page_free_list' is a null pointer!");
f0100baf:	83 ec 04             	sub    $0x4,%esp
f0100bb2:	68 74 6d 10 f0       	push   $0xf0106d74
f0100bb7:	68 c7 02 00 00       	push   $0x2c7
f0100bbc:	68 34 6a 10 f0       	push   $0xf0106a34
f0100bc1:	e8 7a f4 ff ff       	call   f0100040 <_panic>

	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100bc6:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100bc9:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100bcc:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100bcf:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100bd2:	89 c2                	mov    %eax,%edx
f0100bd4:	2b 15 90 5e 24 f0    	sub    0xf0245e90,%edx
f0100bda:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100be0:	0f 95 c2             	setne  %dl
f0100be3:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100be6:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100bea:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100bec:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100bf0:	8b 00                	mov    (%eax),%eax
f0100bf2:	85 c0                	test   %eax,%eax
f0100bf4:	75 dc                	jne    f0100bd2 <check_page_free_list+0x3e>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0100bf6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100bf9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100bff:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100c02:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100c05:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100c07:	8b 5d d8             	mov    -0x28(%ebp),%ebx
f0100c0a:	89 1d 40 52 24 f0    	mov    %ebx,0xf0245240
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100c10:	85 db                	test   %ebx,%ebx
f0100c12:	74 63                	je     f0100c77 <check_page_free_list+0xe3>
f0100c14:	be 01 00 00 00       	mov    $0x1,%esi
f0100c19:	eb 05                	jmp    f0100c20 <check_page_free_list+0x8c>
check_page_free_list(bool only_low_memory)
{
//	cprintf("\nEntering check_page_free_list\n");

	struct PageInfo *pp = NULL;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100c1b:	be 00 04 00 00       	mov    $0x400,%esi
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100c20:	89 d8                	mov    %ebx,%eax
f0100c22:	2b 05 90 5e 24 f0    	sub    0xf0245e90,%eax
f0100c28:	c1 f8 03             	sar    $0x3,%eax
f0100c2b:	c1 e0 0c             	shl    $0xc,%eax
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
f0100c2e:	89 c2                	mov    %eax,%edx
f0100c30:	c1 ea 16             	shr    $0x16,%edx
f0100c33:	39 d6                	cmp    %edx,%esi
f0100c35:	76 3a                	jbe    f0100c71 <check_page_free_list+0xdd>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100c37:	89 c2                	mov    %eax,%edx
f0100c39:	c1 ea 0c             	shr    $0xc,%edx
f0100c3c:	3b 15 88 5e 24 f0    	cmp    0xf0245e88,%edx
f0100c42:	72 12                	jb     f0100c56 <check_page_free_list+0xc2>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100c44:	50                   	push   %eax
f0100c45:	68 c4 64 10 f0       	push   $0xf01064c4
f0100c4a:	6a 58                	push   $0x58
f0100c4c:	68 40 6a 10 f0       	push   $0xf0106a40
f0100c51:	e8 ea f3 ff ff       	call   f0100040 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100c56:	83 ec 04             	sub    $0x4,%esp
f0100c59:	68 80 00 00 00       	push   $0x80
f0100c5e:	68 97 00 00 00       	push   $0x97
f0100c63:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100c68:	50                   	push   %eax
f0100c69:	e8 f7 4a 00 00       	call   f0105765 <memset>
f0100c6e:	83 c4 10             	add    $0x10,%esp
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100c71:	8b 1b                	mov    (%ebx),%ebx
f0100c73:	85 db                	test   %ebx,%ebx
f0100c75:	75 a9                	jne    f0100c20 <check_page_free_list+0x8c>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f0100c77:	b8 00 00 00 00       	mov    $0x0,%eax
f0100c7c:	e8 4c fe ff ff       	call   f0100acd <boot_alloc>
f0100c81:	89 45 cc             	mov    %eax,-0x34(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c84:	8b 15 40 52 24 f0    	mov    0xf0245240,%edx
f0100c8a:	85 d2                	test   %edx,%edx
f0100c8c:	0f 84 a1 01 00 00    	je     f0100e33 <check_page_free_list+0x29f>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100c92:	8b 0d 90 5e 24 f0    	mov    0xf0245e90,%ecx
f0100c98:	39 ca                	cmp    %ecx,%edx
f0100c9a:	72 43                	jb     f0100cdf <check_page_free_list+0x14b>
		assert(pp < pages + npages);
f0100c9c:	a1 88 5e 24 f0       	mov    0xf0245e88,%eax
f0100ca1:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0100ca4:	8d 04 c1             	lea    (%ecx,%eax,8),%eax
f0100ca7:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0100caa:	39 c2                	cmp    %eax,%edx
f0100cac:	73 4f                	jae    f0100cfd <check_page_free_list+0x169>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100cae:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f0100cb1:	89 d0                	mov    %edx,%eax
f0100cb3:	29 c8                	sub    %ecx,%eax
f0100cb5:	a8 07                	test   $0x7,%al
f0100cb7:	75 66                	jne    f0100d1f <check_page_free_list+0x18b>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100cb9:	c1 f8 03             	sar    $0x3,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0100cbc:	c1 e0 0c             	shl    $0xc,%eax
f0100cbf:	74 7f                	je     f0100d40 <check_page_free_list+0x1ac>
		assert(page2pa(pp) != IOPHYSMEM);
f0100cc1:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100cc6:	0f 84 94 00 00 00    	je     f0100d60 <check_page_free_list+0x1cc>
f0100ccc:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100cd1:	be 00 00 00 00       	mov    $0x0,%esi
f0100cd6:	e9 9e 00 00 00       	jmp    f0100d79 <check_page_free_list+0x1e5>
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100cdb:	39 ca                	cmp    %ecx,%edx
f0100cdd:	73 19                	jae    f0100cf8 <check_page_free_list+0x164>
f0100cdf:	68 4e 6a 10 f0       	push   $0xf0106a4e
f0100ce4:	68 5a 6a 10 f0       	push   $0xf0106a5a
f0100ce9:	68 e4 02 00 00       	push   $0x2e4
f0100cee:	68 34 6a 10 f0       	push   $0xf0106a34
f0100cf3:	e8 48 f3 ff ff       	call   f0100040 <_panic>
		assert(pp < pages + npages);
f0100cf8:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0100cfb:	72 19                	jb     f0100d16 <check_page_free_list+0x182>
f0100cfd:	68 6f 6a 10 f0       	push   $0xf0106a6f
f0100d02:	68 5a 6a 10 f0       	push   $0xf0106a5a
f0100d07:	68 e5 02 00 00       	push   $0x2e5
f0100d0c:	68 34 6a 10 f0       	push   $0xf0106a34
f0100d11:	e8 2a f3 ff ff       	call   f0100040 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100d16:	89 d0                	mov    %edx,%eax
f0100d18:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0100d1b:	a8 07                	test   $0x7,%al
f0100d1d:	74 19                	je     f0100d38 <check_page_free_list+0x1a4>
f0100d1f:	68 98 6d 10 f0       	push   $0xf0106d98
f0100d24:	68 5a 6a 10 f0       	push   $0xf0106a5a
f0100d29:	68 e6 02 00 00       	push   $0x2e6
f0100d2e:	68 34 6a 10 f0       	push   $0xf0106a34
f0100d33:	e8 08 f3 ff ff       	call   f0100040 <_panic>
f0100d38:	c1 f8 03             	sar    $0x3,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0100d3b:	c1 e0 0c             	shl    $0xc,%eax
f0100d3e:	75 19                	jne    f0100d59 <check_page_free_list+0x1c5>
f0100d40:	68 83 6a 10 f0       	push   $0xf0106a83
f0100d45:	68 5a 6a 10 f0       	push   $0xf0106a5a
f0100d4a:	68 e9 02 00 00       	push   $0x2e9
f0100d4f:	68 34 6a 10 f0       	push   $0xf0106a34
f0100d54:	e8 e7 f2 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100d59:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100d5e:	75 19                	jne    f0100d79 <check_page_free_list+0x1e5>
f0100d60:	68 94 6a 10 f0       	push   $0xf0106a94
f0100d65:	68 5a 6a 10 f0       	push   $0xf0106a5a
f0100d6a:	68 ea 02 00 00       	push   $0x2ea
f0100d6f:	68 34 6a 10 f0       	push   $0xf0106a34
f0100d74:	e8 c7 f2 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100d79:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100d7e:	75 19                	jne    f0100d99 <check_page_free_list+0x205>
f0100d80:	68 cc 6d 10 f0       	push   $0xf0106dcc
f0100d85:	68 5a 6a 10 f0       	push   $0xf0106a5a
f0100d8a:	68 eb 02 00 00       	push   $0x2eb
f0100d8f:	68 34 6a 10 f0       	push   $0xf0106a34
f0100d94:	e8 a7 f2 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100d99:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100d9e:	75 19                	jne    f0100db9 <check_page_free_list+0x225>
f0100da0:	68 ad 6a 10 f0       	push   $0xf0106aad
f0100da5:	68 5a 6a 10 f0       	push   $0xf0106a5a
f0100daa:	68 ec 02 00 00       	push   $0x2ec
f0100daf:	68 34 6a 10 f0       	push   $0xf0106a34
f0100db4:	e8 87 f2 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100db9:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100dbe:	0f 86 b7 00 00 00    	jbe    f0100e7b <check_page_free_list+0x2e7>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100dc4:	89 c7                	mov    %eax,%edi
f0100dc6:	c1 ef 0c             	shr    $0xc,%edi
f0100dc9:	39 7d c8             	cmp    %edi,-0x38(%ebp)
f0100dcc:	77 12                	ja     f0100de0 <check_page_free_list+0x24c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100dce:	50                   	push   %eax
f0100dcf:	68 c4 64 10 f0       	push   $0xf01064c4
f0100dd4:	6a 58                	push   $0x58
f0100dd6:	68 40 6a 10 f0       	push   $0xf0106a40
f0100ddb:	e8 60 f2 ff ff       	call   f0100040 <_panic>
f0100de0:	8d b8 00 00 00 f0    	lea    -0x10000000(%eax),%edi
f0100de6:	39 7d cc             	cmp    %edi,-0x34(%ebp)
f0100de9:	0f 86 95 00 00 00    	jbe    f0100e84 <check_page_free_list+0x2f0>
f0100def:	68 f0 6d 10 f0       	push   $0xf0106df0
f0100df4:	68 5a 6a 10 f0       	push   $0xf0106a5a
f0100df9:	68 ed 02 00 00       	push   $0x2ed
f0100dfe:	68 34 6a 10 f0       	push   $0xf0106a34
f0100e03:	e8 38 f2 ff ff       	call   f0100040 <_panic>
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100e08:	68 c7 6a 10 f0       	push   $0xf0106ac7
f0100e0d:	68 5a 6a 10 f0       	push   $0xf0106a5a
f0100e12:	68 ef 02 00 00       	push   $0x2ef
f0100e17:	68 34 6a 10 f0       	push   $0xf0106a34
f0100e1c:	e8 1f f2 ff ff       	call   f0100040 <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
f0100e21:	46                   	inc    %esi
f0100e22:	eb 01                	jmp    f0100e25 <check_page_free_list+0x291>
		else
			++nfree_extmem;
f0100e24:	43                   	inc    %ebx
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100e25:	8b 12                	mov    (%edx),%edx
f0100e27:	85 d2                	test   %edx,%edx
f0100e29:	0f 85 ac fe ff ff    	jne    f0100cdb <check_page_free_list+0x147>
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f0100e2f:	85 f6                	test   %esi,%esi
f0100e31:	7f 19                	jg     f0100e4c <check_page_free_list+0x2b8>
f0100e33:	68 e4 6a 10 f0       	push   $0xf0106ae4
f0100e38:	68 5a 6a 10 f0       	push   $0xf0106a5a
f0100e3d:	68 f7 02 00 00       	push   $0x2f7
f0100e42:	68 34 6a 10 f0       	push   $0xf0106a34
f0100e47:	e8 f4 f1 ff ff       	call   f0100040 <_panic>
	assert(nfree_extmem > 0);
f0100e4c:	85 db                	test   %ebx,%ebx
f0100e4e:	7f 40                	jg     f0100e90 <check_page_free_list+0x2fc>
f0100e50:	68 f6 6a 10 f0       	push   $0xf0106af6
f0100e55:	68 5a 6a 10 f0       	push   $0xf0106a5a
f0100e5a:	68 f8 02 00 00       	push   $0x2f8
f0100e5f:	68 34 6a 10 f0       	push   $0xf0106a34
f0100e64:	e8 d7 f1 ff ff       	call   f0100040 <_panic>
	struct PageInfo *pp = NULL;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100e69:	a1 40 52 24 f0       	mov    0xf0245240,%eax
f0100e6e:	85 c0                	test   %eax,%eax
f0100e70:	0f 85 50 fd ff ff    	jne    f0100bc6 <check_page_free_list+0x32>
f0100e76:	e9 34 fd ff ff       	jmp    f0100baf <check_page_free_list+0x1b>
		assert(page2pa(pp) != IOPHYSMEM);
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
		assert(page2pa(pp) != EXTPHYSMEM);
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100e7b:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0100e80:	75 9f                	jne    f0100e21 <check_page_free_list+0x28d>
f0100e82:	eb 84                	jmp    f0100e08 <check_page_free_list+0x274>
f0100e84:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0100e89:	75 99                	jne    f0100e24 <check_page_free_list+0x290>
f0100e8b:	e9 78 ff ff ff       	jmp    f0100e08 <check_page_free_list+0x274>
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
	assert(nfree_extmem > 0);
}
f0100e90:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100e93:	5b                   	pop    %ebx
f0100e94:	5e                   	pop    %esi
f0100e95:	5f                   	pop    %edi
f0100e96:	5d                   	pop    %ebp
f0100e97:	c3                   	ret    

f0100e98 <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0100e98:	55                   	push   %ebp
f0100e99:	89 e5                	mov    %esp,%ebp
f0100e9b:	57                   	push   %edi
f0100e9c:	56                   	push   %esi
f0100e9d:	53                   	push   %ebx
f0100e9e:	83 ec 1c             	sub    $0x1c,%esp
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100ea1:	83 3d 88 5e 24 f0 07 	cmpl   $0x7,0xf0245e88
f0100ea8:	77 14                	ja     f0100ebe <page_init+0x26>
		panic("pa2page called with invalid pa");
f0100eaa:	83 ec 04             	sub    $0x4,%esp
f0100ead:	68 38 6e 10 f0       	push   $0xf0106e38
f0100eb2:	6a 51                	push   $0x51
f0100eb4:	68 40 6a 10 f0       	push   $0xf0106a40
f0100eb9:	e8 82 f1 ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f0100ebe:	a1 90 5e 24 f0       	mov    0xf0245e90,%eax
f0100ec3:	8d 78 38             	lea    0x38(%eax),%edi
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	page_free_list = NULL;
f0100ec6:	c7 05 40 52 24 f0 00 	movl   $0x0,0xf0245240
f0100ecd:	00 00 00 
//	cprintf("kern_pgdir locates at %p\n", kern_pgdir);
//	cprintf("pages locates at %p\n", pages);
//	cprintf("nextfree locates at %p\n", boot_alloc);
//	int alloc = (int)((char *)kern_pgdir-KERNBASE)/PGSIZE + (int)((char *)boot_alloc(0)-(char *)pages)/PGSIZE;
	int num_alloc =((uint32_t)boot_alloc(0) - KERNBASE) / PGSIZE;    //The allocated pages in extended memory.
f0100ed0:	b8 00 00 00 00       	mov    $0x0,%eax
f0100ed5:	e8 f3 fb ff ff       	call   f0100acd <boot_alloc>
f0100eda:	05 00 00 00 10       	add    $0x10000000,%eax
f0100edf:	c1 e8 0c             	shr    $0xc,%eax
	int num_iohole = 96;
//	cprintf("there are %d allocated pages.\n", alloc);
	for (i = 0; i < npages; i++) {
f0100ee2:	83 3d 88 5e 24 f0 00 	cmpl   $0x0,0xf0245e88
f0100ee9:	0f 84 81 00 00 00    	je     f0100f70 <page_init+0xd8>
		if(i == 0){       //Physical page 0 is in use.
			pages[i].pp_ref = 1;
		}
		else if(i >= npages_basemem && i < npages_basemem + num_iohole + num_alloc) {
f0100eef:	8b 35 44 52 24 f0    	mov    0xf0245244,%esi
f0100ef5:	8d 44 30 60          	lea    0x60(%eax,%esi,1),%eax
f0100ef9:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100efc:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
f0100f00:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100f05:	b8 00 00 00 00       	mov    $0x0,%eax
//	int alloc = (int)((char *)kern_pgdir-KERNBASE)/PGSIZE + (int)((char *)boot_alloc(0)-(char *)pages)/PGSIZE;
	int num_alloc =((uint32_t)boot_alloc(0) - KERNBASE) / PGSIZE;    //The allocated pages in extended memory.
	int num_iohole = 96;
//	cprintf("there are %d allocated pages.\n", alloc);
	for (i = 0; i < npages; i++) {
		if(i == 0){       //Physical page 0 is in use.
f0100f0a:	85 c0                	test   %eax,%eax
f0100f0c:	75 0e                	jne    f0100f1c <page_init+0x84>
			pages[i].pp_ref = 1;
f0100f0e:	8b 15 90 5e 24 f0    	mov    0xf0245e90,%edx
f0100f14:	66 c7 42 04 01 00    	movw   $0x1,0x4(%edx)
f0100f1a:	eb 3f                	jmp    f0100f5b <page_init+0xc3>
		}
		else if(i >= npages_basemem && i < npages_basemem + num_iohole + num_alloc) {
f0100f1c:	39 c6                	cmp    %eax,%esi
f0100f1e:	77 14                	ja     f0100f34 <page_init+0x9c>
f0100f20:	39 45 e0             	cmp    %eax,-0x20(%ebp)
f0100f23:	76 0f                	jbe    f0100f34 <page_init+0x9c>
			pages[i].pp_ref = 1;
f0100f25:	8b 15 90 5e 24 f0    	mov    0xf0245e90,%edx
f0100f2b:	66 c7 44 c2 04 01 00 	movw   $0x1,0x4(%edx,%eax,8)
f0100f32:	eb 27                	jmp    f0100f5b <page_init+0xc3>
f0100f34:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
		}
		else {
			if (pages + i == ret) continue;
f0100f3b:	89 ca                	mov    %ecx,%edx
f0100f3d:	03 15 90 5e 24 f0    	add    0xf0245e90,%edx
f0100f43:	39 fa                	cmp    %edi,%edx
f0100f45:	74 14                	je     f0100f5b <page_init+0xc3>
			pages[i].pp_ref = 0;
f0100f47:	66 c7 42 04 00 00    	movw   $0x0,0x4(%edx)
			pages[i].pp_link = page_free_list;
f0100f4d:	89 1a                	mov    %ebx,(%edx)
			page_free_list = &pages[i];
f0100f4f:	03 0d 90 5e 24 f0    	add    0xf0245e90,%ecx
f0100f55:	89 cb                	mov    %ecx,%ebx
f0100f57:	c6 45 e7 01          	movb   $0x1,-0x19(%ebp)
//	cprintf("nextfree locates at %p\n", boot_alloc);
//	int alloc = (int)((char *)kern_pgdir-KERNBASE)/PGSIZE + (int)((char *)boot_alloc(0)-(char *)pages)/PGSIZE;
	int num_alloc =((uint32_t)boot_alloc(0) - KERNBASE) / PGSIZE;    //The allocated pages in extended memory.
	int num_iohole = 96;
//	cprintf("there are %d allocated pages.\n", alloc);
	for (i = 0; i < npages; i++) {
f0100f5b:	40                   	inc    %eax
f0100f5c:	39 05 88 5e 24 f0    	cmp    %eax,0xf0245e88
f0100f62:	77 a6                	ja     f0100f0a <page_init+0x72>
f0100f64:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
f0100f68:	74 06                	je     f0100f70 <page_init+0xd8>
f0100f6a:	89 1d 40 52 24 f0    	mov    %ebx,0xf0245240
			pages[i].pp_ref = 0;
			pages[i].pp_link = page_free_list;
			page_free_list = &pages[i];
		}
	}
}
f0100f70:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100f73:	5b                   	pop    %ebx
f0100f74:	5e                   	pop    %esi
f0100f75:	5f                   	pop    %edi
f0100f76:	5d                   	pop    %ebp
f0100f77:	c3                   	ret    

f0100f78 <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f0100f78:	55                   	push   %ebp
f0100f79:	89 e5                	mov    %esp,%ebp
f0100f7b:	53                   	push   %ebx
f0100f7c:	83 ec 04             	sub    $0x4,%esp
	// Fill this function in
	struct PageInfo * result = page_free_list;
f0100f7f:	8b 1d 40 52 24 f0    	mov    0xf0245240,%ebx
	if(page_free_list == NULL)
f0100f85:	85 db                	test   %ebx,%ebx
f0100f87:	74 5c                	je     f0100fe5 <page_alloc+0x6d>
		return NULL;
	page_free_list = page_free_list->pp_link;
f0100f89:	8b 03                	mov    (%ebx),%eax
f0100f8b:	a3 40 52 24 f0       	mov    %eax,0xf0245240

	result->pp_link = NULL;
f0100f90:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if(alloc_flags & ALLOC_ZERO)
f0100f96:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0100f9a:	74 50                	je     f0100fec <page_alloc+0x74>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100f9c:	89 d8                	mov    %ebx,%eax
f0100f9e:	2b 05 90 5e 24 f0    	sub    0xf0245e90,%eax
f0100fa4:	c1 f8 03             	sar    $0x3,%eax
f0100fa7:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100faa:	89 c2                	mov    %eax,%edx
f0100fac:	c1 ea 0c             	shr    $0xc,%edx
f0100faf:	3b 15 88 5e 24 f0    	cmp    0xf0245e88,%edx
f0100fb5:	72 12                	jb     f0100fc9 <page_alloc+0x51>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100fb7:	50                   	push   %eax
f0100fb8:	68 c4 64 10 f0       	push   $0xf01064c4
f0100fbd:	6a 58                	push   $0x58
f0100fbf:	68 40 6a 10 f0       	push   $0xf0106a40
f0100fc4:	e8 77 f0 ff ff       	call   f0100040 <_panic>
		memset(page2kva(result), 0, PGSIZE);
f0100fc9:	83 ec 04             	sub    $0x4,%esp
f0100fcc:	68 00 10 00 00       	push   $0x1000
f0100fd1:	6a 00                	push   $0x0
f0100fd3:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100fd8:	50                   	push   %eax
f0100fd9:	e8 87 47 00 00       	call   f0105765 <memset>
f0100fde:	83 c4 10             	add    $0x10,%esp
	return result;
f0100fe1:	89 d8                	mov    %ebx,%eax
f0100fe3:	eb 09                	jmp    f0100fee <page_alloc+0x76>
page_alloc(int alloc_flags)
{
	// Fill this function in
	struct PageInfo * result = page_free_list;
	if(page_free_list == NULL)
		return NULL;
f0100fe5:	b8 00 00 00 00       	mov    $0x0,%eax
f0100fea:	eb 02                	jmp    f0100fee <page_alloc+0x76>
	page_free_list = page_free_list->pp_link;

	result->pp_link = NULL;
	if(alloc_flags & ALLOC_ZERO)
		memset(page2kva(result), 0, PGSIZE);
	return result;
f0100fec:	89 d8                	mov    %ebx,%eax
}
f0100fee:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100ff1:	c9                   	leave  
f0100ff2:	c3                   	ret    

f0100ff3 <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f0100ff3:	55                   	push   %ebp
f0100ff4:	89 e5                	mov    %esp,%ebp
f0100ff6:	83 ec 08             	sub    $0x8,%esp
f0100ff9:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
	// Hint: You may want to panic if pp->pp_ref is nonzero or
	// pp->pp_link is not NULL.
	assert(pp->pp_ref == 0);
f0100ffc:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0101001:	74 19                	je     f010101c <page_free+0x29>
f0101003:	68 07 6b 10 f0       	push   $0xf0106b07
f0101008:	68 5a 6a 10 f0       	push   $0xf0106a5a
f010100d:	68 7a 01 00 00       	push   $0x17a
f0101012:	68 34 6a 10 f0       	push   $0xf0106a34
f0101017:	e8 24 f0 ff ff       	call   f0100040 <_panic>
	assert(pp->pp_link == NULL);
f010101c:	83 38 00             	cmpl   $0x0,(%eax)
f010101f:	74 19                	je     f010103a <page_free+0x47>
f0101021:	68 17 6b 10 f0       	push   $0xf0106b17
f0101026:	68 5a 6a 10 f0       	push   $0xf0106a5a
f010102b:	68 7b 01 00 00       	push   $0x17b
f0101030:	68 34 6a 10 f0       	push   $0xf0106a34
f0101035:	e8 06 f0 ff ff       	call   f0100040 <_panic>

	pp->pp_link = page_free_list;
f010103a:	8b 15 40 52 24 f0    	mov    0xf0245240,%edx
f0101040:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f0101042:	a3 40 52 24 f0       	mov    %eax,0xf0245240
}
f0101047:	c9                   	leave  
f0101048:	c3                   	ret    

f0101049 <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f0101049:	55                   	push   %ebp
f010104a:	89 e5                	mov    %esp,%ebp
f010104c:	83 ec 08             	sub    $0x8,%esp
f010104f:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f0101052:	8b 42 04             	mov    0x4(%edx),%eax
f0101055:	48                   	dec    %eax
f0101056:	66 89 42 04          	mov    %ax,0x4(%edx)
f010105a:	66 85 c0             	test   %ax,%ax
f010105d:	75 0c                	jne    f010106b <page_decref+0x22>
		page_free(pp);
f010105f:	83 ec 0c             	sub    $0xc,%esp
f0101062:	52                   	push   %edx
f0101063:	e8 8b ff ff ff       	call   f0100ff3 <page_free>
f0101068:	83 c4 10             	add    $0x10,%esp
}
f010106b:	c9                   	leave  
f010106c:	c3                   	ret    

f010106d <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f010106d:	55                   	push   %ebp
f010106e:	89 e5                	mov    %esp,%ebp
f0101070:	53                   	push   %ebx
f0101071:	83 ec 04             	sub    $0x4,%esp
	// Fill this function in
	unsigned int page_off;
	pte_t *page_base = NULL;
	struct PageInfo* new_page = NULL;
	unsigned int dic_off = PDX(va); 						 //The page directory index of this page table page.
	pde_t *dic_entry_ptr = pgdir + dic_off;        //The page directory entry of this page table page.
f0101074:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101077:	c1 eb 16             	shr    $0x16,%ebx
f010107a:	c1 e3 02             	shl    $0x2,%ebx
f010107d:	03 5d 08             	add    0x8(%ebp),%ebx
	if( !(*dic_entry_ptr) & PTE_P )                        //If this page table page exists.
f0101080:	83 3b 00             	cmpl   $0x0,(%ebx)
f0101083:	75 2c                	jne    f01010b1 <pgdir_walk+0x44>
	{
		if(create)								 //If create is true, then create a new page table page.
f0101085:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0101089:	74 64                	je     f01010ef <pgdir_walk+0x82>
		{
			new_page = page_alloc(1);
f010108b:	83 ec 0c             	sub    $0xc,%esp
f010108e:	6a 01                	push   $0x1
f0101090:	e8 e3 fe ff ff       	call   f0100f78 <page_alloc>
			if(new_page == NULL) return NULL;    //Allocation failed.
f0101095:	83 c4 10             	add    $0x10,%esp
f0101098:	85 c0                	test   %eax,%eax
f010109a:	74 5a                	je     f01010f6 <pgdir_walk+0x89>
			new_page->pp_ref++;
f010109c:	66 ff 40 04          	incw   0x4(%eax)
			*dic_entry_ptr = (page2pa(new_page) | PTE_P | PTE_W | PTE_U);
f01010a0:	2b 05 90 5e 24 f0    	sub    0xf0245e90,%eax
f01010a6:	c1 f8 03             	sar    $0x3,%eax
f01010a9:	c1 e0 0c             	shl    $0xc,%eax
f01010ac:	83 c8 07             	or     $0x7,%eax
f01010af:	89 03                	mov    %eax,(%ebx)
		}
		else
			return NULL; 
	}	
	page_off = PTX(va);						 //The page table index of this page.
f01010b1:	8b 45 0c             	mov    0xc(%ebp),%eax
f01010b4:	c1 e8 0c             	shr    $0xc,%eax
f01010b7:	25 ff 03 00 00       	and    $0x3ff,%eax
	page_base = KADDR(PTE_ADDR(*dic_entry_ptr));
f01010bc:	8b 13                	mov    (%ebx),%edx
f01010be:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01010c4:	89 d1                	mov    %edx,%ecx
f01010c6:	c1 e9 0c             	shr    $0xc,%ecx
f01010c9:	3b 0d 88 5e 24 f0    	cmp    0xf0245e88,%ecx
f01010cf:	72 15                	jb     f01010e6 <pgdir_walk+0x79>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01010d1:	52                   	push   %edx
f01010d2:	68 c4 64 10 f0       	push   $0xf01064c4
f01010d7:	68 b8 01 00 00       	push   $0x1b8
f01010dc:	68 34 6a 10 f0       	push   $0xf0106a34
f01010e1:	e8 5a ef ff ff       	call   f0100040 <_panic>
	return &page_base[page_off];
f01010e6:	8d 84 82 00 00 00 f0 	lea    -0x10000000(%edx,%eax,4),%eax
f01010ed:	eb 0c                	jmp    f01010fb <pgdir_walk+0x8e>
			if(new_page == NULL) return NULL;    //Allocation failed.
			new_page->pp_ref++;
			*dic_entry_ptr = (page2pa(new_page) | PTE_P | PTE_W | PTE_U);
		}
		else
			return NULL; 
f01010ef:	b8 00 00 00 00       	mov    $0x0,%eax
f01010f4:	eb 05                	jmp    f01010fb <pgdir_walk+0x8e>
	if( !(*dic_entry_ptr) & PTE_P )                        //If this page table page exists.
	{
		if(create)								 //If create is true, then create a new page table page.
		{
			new_page = page_alloc(1);
			if(new_page == NULL) return NULL;    //Allocation failed.
f01010f6:	b8 00 00 00 00       	mov    $0x0,%eax
			return NULL; 
	}	
	page_off = PTX(va);						 //The page table index of this page.
	page_base = KADDR(PTE_ADDR(*dic_entry_ptr));
	return &page_base[page_off];
}
f01010fb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01010fe:	c9                   	leave  
f01010ff:	c3                   	ret    

f0101100 <boot_map_region>:
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	int nadd;
	pte_t *entry = NULL;
	for(nadd = 0; nadd < size; nadd += PGSIZE)
f0101100:	85 c9                	test   %ecx,%ecx
f0101102:	74 55                	je     f0101159 <boot_map_region+0x59>
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f0101104:	55                   	push   %ebp
f0101105:	89 e5                	mov    %esp,%ebp
f0101107:	57                   	push   %edi
f0101108:	56                   	push   %esi
f0101109:	53                   	push   %ebx
f010110a:	83 ec 1c             	sub    $0x1c,%esp
f010110d:	89 4d d8             	mov    %ecx,-0x28(%ebp)
f0101110:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0101113:	89 c7                	mov    %eax,%edi
	int nadd;
	pte_t *entry = NULL;
	for(nadd = 0; nadd < size; nadd += PGSIZE)
f0101115:	89 d3                	mov    %edx,%ebx
f0101117:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010111a:	29 d1                	sub    %edx,%ecx
f010111c:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	{
		entry = pgdir_walk(pgdir,(void *)va, 1);    //Get the table entry of this page.
		*entry = (pa | perm | PTE_P);
f010111f:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101122:	83 c8 01             	or     $0x1,%eax
f0101125:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0101128:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010112b:	8d 34 18             	lea    (%eax,%ebx,1),%esi
{
	int nadd;
	pte_t *entry = NULL;
	for(nadd = 0; nadd < size; nadd += PGSIZE)
	{
		entry = pgdir_walk(pgdir,(void *)va, 1);    //Get the table entry of this page.
f010112e:	83 ec 04             	sub    $0x4,%esp
f0101131:	6a 01                	push   $0x1
f0101133:	53                   	push   %ebx
f0101134:	57                   	push   %edi
f0101135:	e8 33 ff ff ff       	call   f010106d <pgdir_walk>
		*entry = (pa | perm | PTE_P);
f010113a:	0b 75 e0             	or     -0x20(%ebp),%esi
f010113d:	89 30                	mov    %esi,(%eax)
		
		
		pa += PGSIZE;
		va += PGSIZE;
f010113f:	81 c3 00 10 00 00    	add    $0x1000,%ebx
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	int nadd;
	pte_t *entry = NULL;
	for(nadd = 0; nadd < size; nadd += PGSIZE)
f0101145:	89 d8                	mov    %ebx,%eax
f0101147:	2b 45 dc             	sub    -0x24(%ebp),%eax
f010114a:	83 c4 10             	add    $0x10,%esp
f010114d:	3b 45 d8             	cmp    -0x28(%ebp),%eax
f0101150:	72 d6                	jb     f0101128 <boot_map_region+0x28>
		
		pa += PGSIZE;
		va += PGSIZE;
		
	}
}
f0101152:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101155:	5b                   	pop    %ebx
f0101156:	5e                   	pop    %esi
f0101157:	5f                   	pop    %edi
f0101158:	5d                   	pop    %ebp
f0101159:	c3                   	ret    

f010115a <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f010115a:	55                   	push   %ebp
f010115b:	89 e5                	mov    %esp,%ebp
f010115d:	53                   	push   %ebx
f010115e:	83 ec 08             	sub    $0x8,%esp
f0101161:	8b 5d 10             	mov    0x10(%ebp),%ebx
	pte_t *entry = NULL;
	struct PageInfo *ret = NULL;

	entry = pgdir_walk(pgdir, va, 0);
f0101164:	6a 00                	push   $0x0
f0101166:	ff 75 0c             	pushl  0xc(%ebp)
f0101169:	ff 75 08             	pushl  0x8(%ebp)
f010116c:	e8 fc fe ff ff       	call   f010106d <pgdir_walk>
	if(entry == NULL)
f0101171:	83 c4 10             	add    $0x10,%esp
f0101174:	85 c0                	test   %eax,%eax
f0101176:	74 38                	je     f01011b0 <page_lookup+0x56>
f0101178:	89 c1                	mov    %eax,%ecx
		return NULL;
	if(!(*entry & PTE_P))
f010117a:	8b 10                	mov    (%eax),%edx
f010117c:	f6 c2 01             	test   $0x1,%dl
f010117f:	74 36                	je     f01011b7 <page_lookup+0x5d>
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101181:	c1 ea 0c             	shr    $0xc,%edx
f0101184:	3b 15 88 5e 24 f0    	cmp    0xf0245e88,%edx
f010118a:	72 14                	jb     f01011a0 <page_lookup+0x46>
		panic("pa2page called with invalid pa");
f010118c:	83 ec 04             	sub    $0x4,%esp
f010118f:	68 38 6e 10 f0       	push   $0xf0106e38
f0101194:	6a 51                	push   $0x51
f0101196:	68 40 6a 10 f0       	push   $0xf0106a40
f010119b:	e8 a0 ee ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f01011a0:	a1 90 5e 24 f0       	mov    0xf0245e90,%eax
f01011a5:	8d 04 d0             	lea    (%eax,%edx,8),%eax
		return NULL;
	
	ret = pa2page(PTE_ADDR(*entry));
	if(pte_store != NULL)
f01011a8:	85 db                	test   %ebx,%ebx
f01011aa:	74 10                	je     f01011bc <page_lookup+0x62>
	{
		*pte_store = entry;
f01011ac:	89 0b                	mov    %ecx,(%ebx)
f01011ae:	eb 0c                	jmp    f01011bc <page_lookup+0x62>
	pte_t *entry = NULL;
	struct PageInfo *ret = NULL;

	entry = pgdir_walk(pgdir, va, 0);
	if(entry == NULL)
		return NULL;
f01011b0:	b8 00 00 00 00       	mov    $0x0,%eax
f01011b5:	eb 05                	jmp    f01011bc <page_lookup+0x62>
	if(!(*entry & PTE_P))
		return NULL;
f01011b7:	b8 00 00 00 00       	mov    $0x0,%eax
	if(pte_store != NULL)
	{
		*pte_store = entry;
	}
	return ret;
}
f01011bc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01011bf:	c9                   	leave  
f01011c0:	c3                   	ret    

f01011c1 <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f01011c1:	55                   	push   %ebp
f01011c2:	89 e5                	mov    %esp,%ebp
f01011c4:	83 ec 08             	sub    $0x8,%esp
	// Flush the entry only if we're modifying the current address space.
	if (!curenv || curenv->env_pgdir == pgdir)
f01011c7:	e8 13 4c 00 00       	call   f0105ddf <cpunum>
f01011cc:	8d 14 00             	lea    (%eax,%eax,1),%edx
f01011cf:	01 c2                	add    %eax,%edx
f01011d1:	01 d2                	add    %edx,%edx
f01011d3:	01 c2                	add    %eax,%edx
f01011d5:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01011d8:	83 3c 85 28 60 24 f0 	cmpl   $0x0,-0xfdb9fd8(,%eax,4)
f01011df:	00 
f01011e0:	74 20                	je     f0101202 <tlb_invalidate+0x41>
f01011e2:	e8 f8 4b 00 00       	call   f0105ddf <cpunum>
f01011e7:	8d 14 00             	lea    (%eax,%eax,1),%edx
f01011ea:	01 c2                	add    %eax,%edx
f01011ec:	01 d2                	add    %edx,%edx
f01011ee:	01 c2                	add    %eax,%edx
f01011f0:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01011f3:	8b 04 85 28 60 24 f0 	mov    -0xfdb9fd8(,%eax,4),%eax
f01011fa:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01011fd:	39 48 60             	cmp    %ecx,0x60(%eax)
f0101200:	75 06                	jne    f0101208 <tlb_invalidate+0x47>
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0101202:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101205:	0f 01 38             	invlpg (%eax)
		invlpg(va);
}
f0101208:	c9                   	leave  
f0101209:	c3                   	ret    

f010120a <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f010120a:	55                   	push   %ebp
f010120b:	89 e5                	mov    %esp,%ebp
f010120d:	56                   	push   %esi
f010120e:	53                   	push   %ebx
f010120f:	83 ec 14             	sub    $0x14,%esp
f0101212:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0101215:	8b 75 0c             	mov    0xc(%ebp),%esi
	pte_t *pte = NULL;
f0101218:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	struct PageInfo *page = page_lookup(pgdir, va, &pte);
f010121f:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0101222:	50                   	push   %eax
f0101223:	56                   	push   %esi
f0101224:	53                   	push   %ebx
f0101225:	e8 30 ff ff ff       	call   f010115a <page_lookup>
	if(page == NULL) return ;	
f010122a:	83 c4 10             	add    $0x10,%esp
f010122d:	85 c0                	test   %eax,%eax
f010122f:	74 1f                	je     f0101250 <page_remove+0x46>
	
	page_decref(page);
f0101231:	83 ec 0c             	sub    $0xc,%esp
f0101234:	50                   	push   %eax
f0101235:	e8 0f fe ff ff       	call   f0101049 <page_decref>
	tlb_invalidate(pgdir, va);
f010123a:	83 c4 08             	add    $0x8,%esp
f010123d:	56                   	push   %esi
f010123e:	53                   	push   %ebx
f010123f:	e8 7d ff ff ff       	call   f01011c1 <tlb_invalidate>
	*pte = 0;
f0101244:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101247:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
f010124d:	83 c4 10             	add    $0x10,%esp
}
f0101250:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0101253:	5b                   	pop    %ebx
f0101254:	5e                   	pop    %esi
f0101255:	5d                   	pop    %ebp
f0101256:	c3                   	ret    

f0101257 <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f0101257:	55                   	push   %ebp
f0101258:	89 e5                	mov    %esp,%ebp
f010125a:	57                   	push   %edi
f010125b:	56                   	push   %esi
f010125c:	53                   	push   %ebx
f010125d:	83 ec 10             	sub    $0x10,%esp
f0101260:	8b 75 08             	mov    0x8(%ebp),%esi
f0101263:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	pte_t *entry = NULL;
	entry =  pgdir_walk(pgdir, va, 1);    //Get the mapping page of this address va.
f0101266:	6a 01                	push   $0x1
f0101268:	ff 75 10             	pushl  0x10(%ebp)
f010126b:	56                   	push   %esi
f010126c:	e8 fc fd ff ff       	call   f010106d <pgdir_walk>
	if(entry == NULL) return -E_NO_MEM;
f0101271:	83 c4 10             	add    $0x10,%esp
f0101274:	85 c0                	test   %eax,%eax
f0101276:	74 4f                	je     f01012c7 <page_insert+0x70>
f0101278:	89 c7                	mov    %eax,%edi

	pp->pp_ref++;
f010127a:	66 ff 43 04          	incw   0x4(%ebx)
	if((*entry) & PTE_P) 	        //If this virtual address is already mapped.
f010127e:	f6 00 01             	testb  $0x1,(%eax)
f0101281:	74 1b                	je     f010129e <page_insert+0x47>
	{
		tlb_invalidate(pgdir, va);
f0101283:	83 ec 08             	sub    $0x8,%esp
f0101286:	ff 75 10             	pushl  0x10(%ebp)
f0101289:	56                   	push   %esi
f010128a:	e8 32 ff ff ff       	call   f01011c1 <tlb_invalidate>
		page_remove(pgdir, va);
f010128f:	83 c4 08             	add    $0x8,%esp
f0101292:	ff 75 10             	pushl  0x10(%ebp)
f0101295:	56                   	push   %esi
f0101296:	e8 6f ff ff ff       	call   f010120a <page_remove>
f010129b:	83 c4 10             	add    $0x10,%esp
	}
	*entry = (page2pa(pp) | perm | PTE_P);
f010129e:	2b 1d 90 5e 24 f0    	sub    0xf0245e90,%ebx
f01012a4:	c1 fb 03             	sar    $0x3,%ebx
f01012a7:	c1 e3 0c             	shl    $0xc,%ebx
f01012aa:	8b 45 14             	mov    0x14(%ebp),%eax
f01012ad:	83 c8 01             	or     $0x1,%eax
f01012b0:	09 c3                	or     %eax,%ebx
f01012b2:	89 1f                	mov    %ebx,(%edi)
	pgdir[PDX(va)] |= perm;			      //Remember this step!
f01012b4:	8b 45 10             	mov    0x10(%ebp),%eax
f01012b7:	c1 e8 16             	shr    $0x16,%eax
f01012ba:	8b 55 14             	mov    0x14(%ebp),%edx
f01012bd:	09 14 86             	or     %edx,(%esi,%eax,4)
		
	return 0;
f01012c0:	b8 00 00 00 00       	mov    $0x0,%eax
f01012c5:	eb 05                	jmp    f01012cc <page_insert+0x75>
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
	pte_t *entry = NULL;
	entry =  pgdir_walk(pgdir, va, 1);    //Get the mapping page of this address va.
	if(entry == NULL) return -E_NO_MEM;
f01012c7:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	}
	*entry = (page2pa(pp) | perm | PTE_P);
	pgdir[PDX(va)] |= perm;			      //Remember this step!
		
	return 0;
}
f01012cc:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01012cf:	5b                   	pop    %ebx
f01012d0:	5e                   	pop    %esi
f01012d1:	5f                   	pop    %edi
f01012d2:	5d                   	pop    %ebp
f01012d3:	c3                   	ret    

f01012d4 <mmio_map_region>:
// location.  Return the base of the reserved region.  size does *not*
// have to be multiple of PGSIZE.
//
void *
mmio_map_region(physaddr_t pa, size_t size)
{
f01012d4:	55                   	push   %ebp
f01012d5:	89 e5                	mov    %esp,%ebp
f01012d7:	53                   	push   %ebx
f01012d8:	83 ec 04             	sub    $0x4,%esp
f01012db:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// Hint: The staff solution uses boot_map_region.
	//
	// Your code here:

	size_t new_size = ROUNDUP(size,PGSIZE);
f01012de:	8d 99 ff 0f 00 00    	lea    0xfff(%ecx),%ebx
f01012e4:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	if (base + new_size > MMIOLIM )
f01012ea:	8b 15 00 03 12 f0    	mov    0xf0120300,%edx
f01012f0:	8d 04 13             	lea    (%ebx,%edx,1),%eax
f01012f3:	3d 00 00 c0 ef       	cmp    $0xefc00000,%eax
f01012f8:	76 17                	jbe    f0101311 <mmio_map_region+0x3d>
		panic("overflow");
f01012fa:	83 ec 04             	sub    $0x4,%esp
f01012fd:	68 2b 6b 10 f0       	push   $0xf0106b2b
f0101302:	68 6d 02 00 00       	push   $0x26d
f0101307:	68 34 6a 10 f0       	push   $0xf0106a34
f010130c:	e8 2f ed ff ff       	call   f0100040 <_panic>
	boot_map_region(kern_pgdir,base,size,pa,PTE_PCD | PTE_PWT | PTE_W);
f0101311:	83 ec 08             	sub    $0x8,%esp
f0101314:	6a 1a                	push   $0x1a
f0101316:	ff 75 08             	pushl  0x8(%ebp)
f0101319:	a1 8c 5e 24 f0       	mov    0xf0245e8c,%eax
f010131e:	e8 dd fd ff ff       	call   f0101100 <boot_map_region>
	base += new_size;
f0101323:	a1 00 03 12 f0       	mov    0xf0120300,%eax
f0101328:	01 c3                	add    %eax,%ebx
f010132a:	89 1d 00 03 12 f0    	mov    %ebx,0xf0120300
	return (void*)(base - new_size);
	// panic("mmio_map_region not implemented");
}
f0101330:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101333:	c9                   	leave  
f0101334:	c3                   	ret    

f0101335 <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f0101335:	55                   	push   %ebp
f0101336:	89 e5                	mov    %esp,%ebp
f0101338:	57                   	push   %edi
f0101339:	56                   	push   %esi
f010133a:	53                   	push   %ebx
f010133b:	83 ec 38             	sub    $0x38,%esp
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f010133e:	6a 15                	push   $0x15
f0101340:	e8 72 23 00 00       	call   f01036b7 <mc146818_read>
f0101345:	89 c3                	mov    %eax,%ebx
f0101347:	c7 04 24 16 00 00 00 	movl   $0x16,(%esp)
f010134e:	e8 64 23 00 00       	call   f01036b7 <mc146818_read>
{
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f0101353:	c1 e0 08             	shl    $0x8,%eax
f0101356:	09 d8                	or     %ebx,%eax
f0101358:	c1 e0 0a             	shl    $0xa,%eax
f010135b:	89 c2                	mov    %eax,%edx
f010135d:	83 c4 10             	add    $0x10,%esp
f0101360:	85 c0                	test   %eax,%eax
f0101362:	79 06                	jns    f010136a <mem_init+0x35>
f0101364:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f010136a:	c1 fa 0c             	sar    $0xc,%edx
f010136d:	89 15 44 52 24 f0    	mov    %edx,0xf0245244
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0101373:	83 ec 0c             	sub    $0xc,%esp
f0101376:	6a 17                	push   $0x17
f0101378:	e8 3a 23 00 00       	call   f01036b7 <mc146818_read>
f010137d:	89 c3                	mov    %eax,%ebx
f010137f:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
f0101386:	e8 2c 23 00 00       	call   f01036b7 <mc146818_read>
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f010138b:	c1 e0 08             	shl    $0x8,%eax
f010138e:	89 c2                	mov    %eax,%edx
f0101390:	09 da                	or     %ebx,%edx
f0101392:	c1 e2 0a             	shl    $0xa,%edx
f0101395:	89 d0                	mov    %edx,%eax
f0101397:	83 c4 10             	add    $0x10,%esp
f010139a:	85 d2                	test   %edx,%edx
f010139c:	79 06                	jns    f01013a4 <mem_init+0x6f>
f010139e:	8d 82 ff 0f 00 00    	lea    0xfff(%edx),%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f01013a4:	c1 f8 0c             	sar    $0xc,%eax
f01013a7:	74 0e                	je     f01013b7 <mem_init+0x82>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f01013a9:	8d 90 00 01 00 00    	lea    0x100(%eax),%edx
f01013af:	89 15 88 5e 24 f0    	mov    %edx,0xf0245e88
f01013b5:	eb 0c                	jmp    f01013c3 <mem_init+0x8e>
	else
		npages = npages_basemem;
f01013b7:	8b 15 44 52 24 f0    	mov    0xf0245244,%edx
f01013bd:	89 15 88 5e 24 f0    	mov    %edx,0xf0245e88

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01013c3:	c1 e0 0c             	shl    $0xc,%eax
f01013c6:	c1 e8 0a             	shr    $0xa,%eax
f01013c9:	50                   	push   %eax
f01013ca:	a1 44 52 24 f0       	mov    0xf0245244,%eax
f01013cf:	c1 e0 0c             	shl    $0xc,%eax
f01013d2:	c1 e8 0a             	shr    $0xa,%eax
f01013d5:	50                   	push   %eax
f01013d6:	a1 88 5e 24 f0       	mov    0xf0245e88,%eax
f01013db:	c1 e0 0c             	shl    $0xc,%eax
f01013de:	c1 e8 0a             	shr    $0xa,%eax
f01013e1:	50                   	push   %eax
f01013e2:	68 58 6e 10 f0       	push   $0xf0106e58
f01013e7:	e8 24 24 00 00       	call   f0103810 <cprintf>
	// Remove this line when you're ready to test this function.
//	panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f01013ec:	b8 00 10 00 00       	mov    $0x1000,%eax
f01013f1:	e8 d7 f6 ff ff       	call   f0100acd <boot_alloc>
f01013f6:	a3 8c 5e 24 f0       	mov    %eax,0xf0245e8c
	memset(kern_pgdir, 0, PGSIZE);
f01013fb:	83 c4 0c             	add    $0xc,%esp
f01013fe:	68 00 10 00 00       	push   $0x1000
f0101403:	6a 00                	push   $0x0
f0101405:	50                   	push   %eax
f0101406:	e8 5a 43 00 00       	call   f0105765 <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f010140b:	a1 8c 5e 24 f0       	mov    0xf0245e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0101410:	83 c4 10             	add    $0x10,%esp
f0101413:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101418:	77 15                	ja     f010142f <mem_init+0xfa>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010141a:	50                   	push   %eax
f010141b:	68 e8 64 10 f0       	push   $0xf01064e8
f0101420:	68 92 00 00 00       	push   $0x92
f0101425:	68 34 6a 10 f0       	push   $0xf0106a34
f010142a:	e8 11 ec ff ff       	call   f0100040 <_panic>
f010142f:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0101435:	83 ca 05             	or     $0x5,%edx
f0101438:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// The kernel uses this array to keep track of physical pages: for
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.  Use memset
	// to initialize all fields of each struct PageInfo to 0.
	// Your code goes here:
	pages = (struct PageInfo *)boot_alloc(npages * sizeof(struct PageInfo));
f010143e:	a1 88 5e 24 f0       	mov    0xf0245e88,%eax
f0101443:	c1 e0 03             	shl    $0x3,%eax
f0101446:	e8 82 f6 ff ff       	call   f0100acd <boot_alloc>
f010144b:	a3 90 5e 24 f0       	mov    %eax,0xf0245e90
	memset(pages, 0, npages * sizeof(struct PageInfo));
f0101450:	83 ec 04             	sub    $0x4,%esp
f0101453:	8b 0d 88 5e 24 f0    	mov    0xf0245e88,%ecx
f0101459:	8d 14 cd 00 00 00 00 	lea    0x0(,%ecx,8),%edx
f0101460:	52                   	push   %edx
f0101461:	6a 00                	push   $0x0
f0101463:	50                   	push   %eax
f0101464:	e8 fc 42 00 00       	call   f0105765 <memset>

	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.
	envs = (struct Env *)boot_alloc(NENV * sizeof(struct Env));
f0101469:	b8 00 f0 01 00       	mov    $0x1f000,%eax
f010146e:	e8 5a f6 ff ff       	call   f0100acd <boot_alloc>
f0101473:	a3 48 52 24 f0       	mov    %eax,0xf0245248
	memset(envs, 0, NENV * sizeof(struct Env));
f0101478:	83 c4 0c             	add    $0xc,%esp
f010147b:	68 00 f0 01 00       	push   $0x1f000
f0101480:	6a 00                	push   $0x0
f0101482:	50                   	push   %eax
f0101483:	e8 dd 42 00 00       	call   f0105765 <memset>
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f0101488:	e8 0b fa ff ff       	call   f0100e98 <page_init>

	check_page_free_list(1);
f010148d:	b8 01 00 00 00       	mov    $0x1,%eax
f0101492:	e8 fd f6 ff ff       	call   f0100b94 <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f0101497:	83 c4 10             	add    $0x10,%esp
f010149a:	83 3d 90 5e 24 f0 00 	cmpl   $0x0,0xf0245e90
f01014a1:	75 17                	jne    f01014ba <mem_init+0x185>
		panic("'pages' is a null pointer!");
f01014a3:	83 ec 04             	sub    $0x4,%esp
f01014a6:	68 34 6b 10 f0       	push   $0xf0106b34
f01014ab:	68 09 03 00 00       	push   $0x309
f01014b0:	68 34 6a 10 f0       	push   $0xf0106a34
f01014b5:	e8 86 eb ff ff       	call   f0100040 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01014ba:	a1 40 52 24 f0       	mov    0xf0245240,%eax
f01014bf:	85 c0                	test   %eax,%eax
f01014c1:	74 0e                	je     f01014d1 <mem_init+0x19c>
f01014c3:	bb 00 00 00 00       	mov    $0x0,%ebx
		++nfree;
f01014c8:	43                   	inc    %ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01014c9:	8b 00                	mov    (%eax),%eax
f01014cb:	85 c0                	test   %eax,%eax
f01014cd:	75 f9                	jne    f01014c8 <mem_init+0x193>
f01014cf:	eb 05                	jmp    f01014d6 <mem_init+0x1a1>
f01014d1:	bb 00 00 00 00       	mov    $0x0,%ebx
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01014d6:	83 ec 0c             	sub    $0xc,%esp
f01014d9:	6a 00                	push   $0x0
f01014db:	e8 98 fa ff ff       	call   f0100f78 <page_alloc>
f01014e0:	89 c7                	mov    %eax,%edi
f01014e2:	83 c4 10             	add    $0x10,%esp
f01014e5:	85 c0                	test   %eax,%eax
f01014e7:	75 19                	jne    f0101502 <mem_init+0x1cd>
f01014e9:	68 4f 6b 10 f0       	push   $0xf0106b4f
f01014ee:	68 5a 6a 10 f0       	push   $0xf0106a5a
f01014f3:	68 11 03 00 00       	push   $0x311
f01014f8:	68 34 6a 10 f0       	push   $0xf0106a34
f01014fd:	e8 3e eb ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101502:	83 ec 0c             	sub    $0xc,%esp
f0101505:	6a 00                	push   $0x0
f0101507:	e8 6c fa ff ff       	call   f0100f78 <page_alloc>
f010150c:	89 c6                	mov    %eax,%esi
f010150e:	83 c4 10             	add    $0x10,%esp
f0101511:	85 c0                	test   %eax,%eax
f0101513:	75 19                	jne    f010152e <mem_init+0x1f9>
f0101515:	68 65 6b 10 f0       	push   $0xf0106b65
f010151a:	68 5a 6a 10 f0       	push   $0xf0106a5a
f010151f:	68 12 03 00 00       	push   $0x312
f0101524:	68 34 6a 10 f0       	push   $0xf0106a34
f0101529:	e8 12 eb ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f010152e:	83 ec 0c             	sub    $0xc,%esp
f0101531:	6a 00                	push   $0x0
f0101533:	e8 40 fa ff ff       	call   f0100f78 <page_alloc>
f0101538:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010153b:	83 c4 10             	add    $0x10,%esp
f010153e:	85 c0                	test   %eax,%eax
f0101540:	75 19                	jne    f010155b <mem_init+0x226>
f0101542:	68 7b 6b 10 f0       	push   $0xf0106b7b
f0101547:	68 5a 6a 10 f0       	push   $0xf0106a5a
f010154c:	68 13 03 00 00       	push   $0x313
f0101551:	68 34 6a 10 f0       	push   $0xf0106a34
f0101556:	e8 e5 ea ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f010155b:	39 f7                	cmp    %esi,%edi
f010155d:	75 19                	jne    f0101578 <mem_init+0x243>
f010155f:	68 91 6b 10 f0       	push   $0xf0106b91
f0101564:	68 5a 6a 10 f0       	push   $0xf0106a5a
f0101569:	68 16 03 00 00       	push   $0x316
f010156e:	68 34 6a 10 f0       	push   $0xf0106a34
f0101573:	e8 c8 ea ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101578:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010157b:	39 c6                	cmp    %eax,%esi
f010157d:	74 04                	je     f0101583 <mem_init+0x24e>
f010157f:	39 c7                	cmp    %eax,%edi
f0101581:	75 19                	jne    f010159c <mem_init+0x267>
f0101583:	68 94 6e 10 f0       	push   $0xf0106e94
f0101588:	68 5a 6a 10 f0       	push   $0xf0106a5a
f010158d:	68 17 03 00 00       	push   $0x317
f0101592:	68 34 6a 10 f0       	push   $0xf0106a34
f0101597:	e8 a4 ea ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010159c:	8b 0d 90 5e 24 f0    	mov    0xf0245e90,%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f01015a2:	8b 15 88 5e 24 f0    	mov    0xf0245e88,%edx
f01015a8:	c1 e2 0c             	shl    $0xc,%edx
f01015ab:	89 f8                	mov    %edi,%eax
f01015ad:	29 c8                	sub    %ecx,%eax
f01015af:	c1 f8 03             	sar    $0x3,%eax
f01015b2:	c1 e0 0c             	shl    $0xc,%eax
f01015b5:	39 d0                	cmp    %edx,%eax
f01015b7:	72 19                	jb     f01015d2 <mem_init+0x29d>
f01015b9:	68 a3 6b 10 f0       	push   $0xf0106ba3
f01015be:	68 5a 6a 10 f0       	push   $0xf0106a5a
f01015c3:	68 18 03 00 00       	push   $0x318
f01015c8:	68 34 6a 10 f0       	push   $0xf0106a34
f01015cd:	e8 6e ea ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f01015d2:	89 f0                	mov    %esi,%eax
f01015d4:	29 c8                	sub    %ecx,%eax
f01015d6:	c1 f8 03             	sar    $0x3,%eax
f01015d9:	c1 e0 0c             	shl    $0xc,%eax
f01015dc:	39 c2                	cmp    %eax,%edx
f01015de:	77 19                	ja     f01015f9 <mem_init+0x2c4>
f01015e0:	68 c0 6b 10 f0       	push   $0xf0106bc0
f01015e5:	68 5a 6a 10 f0       	push   $0xf0106a5a
f01015ea:	68 19 03 00 00       	push   $0x319
f01015ef:	68 34 6a 10 f0       	push   $0xf0106a34
f01015f4:	e8 47 ea ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f01015f9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01015fc:	29 c8                	sub    %ecx,%eax
f01015fe:	c1 f8 03             	sar    $0x3,%eax
f0101601:	c1 e0 0c             	shl    $0xc,%eax
f0101604:	39 c2                	cmp    %eax,%edx
f0101606:	77 19                	ja     f0101621 <mem_init+0x2ec>
f0101608:	68 dd 6b 10 f0       	push   $0xf0106bdd
f010160d:	68 5a 6a 10 f0       	push   $0xf0106a5a
f0101612:	68 1a 03 00 00       	push   $0x31a
f0101617:	68 34 6a 10 f0       	push   $0xf0106a34
f010161c:	e8 1f ea ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101621:	a1 40 52 24 f0       	mov    0xf0245240,%eax
f0101626:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101629:	c7 05 40 52 24 f0 00 	movl   $0x0,0xf0245240
f0101630:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101633:	83 ec 0c             	sub    $0xc,%esp
f0101636:	6a 00                	push   $0x0
f0101638:	e8 3b f9 ff ff       	call   f0100f78 <page_alloc>
f010163d:	83 c4 10             	add    $0x10,%esp
f0101640:	85 c0                	test   %eax,%eax
f0101642:	74 19                	je     f010165d <mem_init+0x328>
f0101644:	68 fa 6b 10 f0       	push   $0xf0106bfa
f0101649:	68 5a 6a 10 f0       	push   $0xf0106a5a
f010164e:	68 21 03 00 00       	push   $0x321
f0101653:	68 34 6a 10 f0       	push   $0xf0106a34
f0101658:	e8 e3 e9 ff ff       	call   f0100040 <_panic>

	// free and re-allocate?
	page_free(pp0);
f010165d:	83 ec 0c             	sub    $0xc,%esp
f0101660:	57                   	push   %edi
f0101661:	e8 8d f9 ff ff       	call   f0100ff3 <page_free>
	page_free(pp1);
f0101666:	89 34 24             	mov    %esi,(%esp)
f0101669:	e8 85 f9 ff ff       	call   f0100ff3 <page_free>
	page_free(pp2);
f010166e:	83 c4 04             	add    $0x4,%esp
f0101671:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101674:	e8 7a f9 ff ff       	call   f0100ff3 <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101679:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101680:	e8 f3 f8 ff ff       	call   f0100f78 <page_alloc>
f0101685:	89 c6                	mov    %eax,%esi
f0101687:	83 c4 10             	add    $0x10,%esp
f010168a:	85 c0                	test   %eax,%eax
f010168c:	75 19                	jne    f01016a7 <mem_init+0x372>
f010168e:	68 4f 6b 10 f0       	push   $0xf0106b4f
f0101693:	68 5a 6a 10 f0       	push   $0xf0106a5a
f0101698:	68 28 03 00 00       	push   $0x328
f010169d:	68 34 6a 10 f0       	push   $0xf0106a34
f01016a2:	e8 99 e9 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f01016a7:	83 ec 0c             	sub    $0xc,%esp
f01016aa:	6a 00                	push   $0x0
f01016ac:	e8 c7 f8 ff ff       	call   f0100f78 <page_alloc>
f01016b1:	89 c7                	mov    %eax,%edi
f01016b3:	83 c4 10             	add    $0x10,%esp
f01016b6:	85 c0                	test   %eax,%eax
f01016b8:	75 19                	jne    f01016d3 <mem_init+0x39e>
f01016ba:	68 65 6b 10 f0       	push   $0xf0106b65
f01016bf:	68 5a 6a 10 f0       	push   $0xf0106a5a
f01016c4:	68 29 03 00 00       	push   $0x329
f01016c9:	68 34 6a 10 f0       	push   $0xf0106a34
f01016ce:	e8 6d e9 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f01016d3:	83 ec 0c             	sub    $0xc,%esp
f01016d6:	6a 00                	push   $0x0
f01016d8:	e8 9b f8 ff ff       	call   f0100f78 <page_alloc>
f01016dd:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01016e0:	83 c4 10             	add    $0x10,%esp
f01016e3:	85 c0                	test   %eax,%eax
f01016e5:	75 19                	jne    f0101700 <mem_init+0x3cb>
f01016e7:	68 7b 6b 10 f0       	push   $0xf0106b7b
f01016ec:	68 5a 6a 10 f0       	push   $0xf0106a5a
f01016f1:	68 2a 03 00 00       	push   $0x32a
f01016f6:	68 34 6a 10 f0       	push   $0xf0106a34
f01016fb:	e8 40 e9 ff ff       	call   f0100040 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101700:	39 fe                	cmp    %edi,%esi
f0101702:	75 19                	jne    f010171d <mem_init+0x3e8>
f0101704:	68 91 6b 10 f0       	push   $0xf0106b91
f0101709:	68 5a 6a 10 f0       	push   $0xf0106a5a
f010170e:	68 2c 03 00 00       	push   $0x32c
f0101713:	68 34 6a 10 f0       	push   $0xf0106a34
f0101718:	e8 23 e9 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010171d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101720:	39 c7                	cmp    %eax,%edi
f0101722:	74 04                	je     f0101728 <mem_init+0x3f3>
f0101724:	39 c6                	cmp    %eax,%esi
f0101726:	75 19                	jne    f0101741 <mem_init+0x40c>
f0101728:	68 94 6e 10 f0       	push   $0xf0106e94
f010172d:	68 5a 6a 10 f0       	push   $0xf0106a5a
f0101732:	68 2d 03 00 00       	push   $0x32d
f0101737:	68 34 6a 10 f0       	push   $0xf0106a34
f010173c:	e8 ff e8 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f0101741:	83 ec 0c             	sub    $0xc,%esp
f0101744:	6a 00                	push   $0x0
f0101746:	e8 2d f8 ff ff       	call   f0100f78 <page_alloc>
f010174b:	83 c4 10             	add    $0x10,%esp
f010174e:	85 c0                	test   %eax,%eax
f0101750:	74 19                	je     f010176b <mem_init+0x436>
f0101752:	68 fa 6b 10 f0       	push   $0xf0106bfa
f0101757:	68 5a 6a 10 f0       	push   $0xf0106a5a
f010175c:	68 2e 03 00 00       	push   $0x32e
f0101761:	68 34 6a 10 f0       	push   $0xf0106a34
f0101766:	e8 d5 e8 ff ff       	call   f0100040 <_panic>
f010176b:	89 f0                	mov    %esi,%eax
f010176d:	2b 05 90 5e 24 f0    	sub    0xf0245e90,%eax
f0101773:	c1 f8 03             	sar    $0x3,%eax
f0101776:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101779:	89 c2                	mov    %eax,%edx
f010177b:	c1 ea 0c             	shr    $0xc,%edx
f010177e:	3b 15 88 5e 24 f0    	cmp    0xf0245e88,%edx
f0101784:	72 12                	jb     f0101798 <mem_init+0x463>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101786:	50                   	push   %eax
f0101787:	68 c4 64 10 f0       	push   $0xf01064c4
f010178c:	6a 58                	push   $0x58
f010178e:	68 40 6a 10 f0       	push   $0xf0106a40
f0101793:	e8 a8 e8 ff ff       	call   f0100040 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f0101798:	83 ec 04             	sub    $0x4,%esp
f010179b:	68 00 10 00 00       	push   $0x1000
f01017a0:	6a 01                	push   $0x1
f01017a2:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01017a7:	50                   	push   %eax
f01017a8:	e8 b8 3f 00 00       	call   f0105765 <memset>
	page_free(pp0);
f01017ad:	89 34 24             	mov    %esi,(%esp)
f01017b0:	e8 3e f8 ff ff       	call   f0100ff3 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f01017b5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01017bc:	e8 b7 f7 ff ff       	call   f0100f78 <page_alloc>
f01017c1:	83 c4 10             	add    $0x10,%esp
f01017c4:	85 c0                	test   %eax,%eax
f01017c6:	75 19                	jne    f01017e1 <mem_init+0x4ac>
f01017c8:	68 09 6c 10 f0       	push   $0xf0106c09
f01017cd:	68 5a 6a 10 f0       	push   $0xf0106a5a
f01017d2:	68 33 03 00 00       	push   $0x333
f01017d7:	68 34 6a 10 f0       	push   $0xf0106a34
f01017dc:	e8 5f e8 ff ff       	call   f0100040 <_panic>
	assert(pp && pp0 == pp);
f01017e1:	39 c6                	cmp    %eax,%esi
f01017e3:	74 19                	je     f01017fe <mem_init+0x4c9>
f01017e5:	68 27 6c 10 f0       	push   $0xf0106c27
f01017ea:	68 5a 6a 10 f0       	push   $0xf0106a5a
f01017ef:	68 34 03 00 00       	push   $0x334
f01017f4:	68 34 6a 10 f0       	push   $0xf0106a34
f01017f9:	e8 42 e8 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01017fe:	89 f2                	mov    %esi,%edx
f0101800:	2b 15 90 5e 24 f0    	sub    0xf0245e90,%edx
f0101806:	c1 fa 03             	sar    $0x3,%edx
f0101809:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010180c:	89 d0                	mov    %edx,%eax
f010180e:	c1 e8 0c             	shr    $0xc,%eax
f0101811:	3b 05 88 5e 24 f0    	cmp    0xf0245e88,%eax
f0101817:	72 12                	jb     f010182b <mem_init+0x4f6>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101819:	52                   	push   %edx
f010181a:	68 c4 64 10 f0       	push   $0xf01064c4
f010181f:	6a 58                	push   $0x58
f0101821:	68 40 6a 10 f0       	push   $0xf0106a40
f0101826:	e8 15 e8 ff ff       	call   f0100040 <_panic>
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f010182b:	80 ba 00 00 00 f0 00 	cmpb   $0x0,-0x10000000(%edx)
f0101832:	75 11                	jne    f0101845 <mem_init+0x510>
f0101834:	8d 82 01 00 00 f0    	lea    -0xfffffff(%edx),%eax
f010183a:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
f0101840:	80 38 00             	cmpb   $0x0,(%eax)
f0101843:	74 19                	je     f010185e <mem_init+0x529>
f0101845:	68 37 6c 10 f0       	push   $0xf0106c37
f010184a:	68 5a 6a 10 f0       	push   $0xf0106a5a
f010184f:	68 37 03 00 00       	push   $0x337
f0101854:	68 34 6a 10 f0       	push   $0xf0106a34
f0101859:	e8 e2 e7 ff ff       	call   f0100040 <_panic>
f010185e:	40                   	inc    %eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f010185f:	39 d0                	cmp    %edx,%eax
f0101861:	75 dd                	jne    f0101840 <mem_init+0x50b>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f0101863:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101866:	a3 40 52 24 f0       	mov    %eax,0xf0245240

	// free the pages we took
	page_free(pp0);
f010186b:	83 ec 0c             	sub    $0xc,%esp
f010186e:	56                   	push   %esi
f010186f:	e8 7f f7 ff ff       	call   f0100ff3 <page_free>
	page_free(pp1);
f0101874:	89 3c 24             	mov    %edi,(%esp)
f0101877:	e8 77 f7 ff ff       	call   f0100ff3 <page_free>
	page_free(pp2);
f010187c:	83 c4 04             	add    $0x4,%esp
f010187f:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101882:	e8 6c f7 ff ff       	call   f0100ff3 <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101887:	a1 40 52 24 f0       	mov    0xf0245240,%eax
f010188c:	83 c4 10             	add    $0x10,%esp
f010188f:	85 c0                	test   %eax,%eax
f0101891:	74 07                	je     f010189a <mem_init+0x565>
		--nfree;
f0101893:	4b                   	dec    %ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101894:	8b 00                	mov    (%eax),%eax
f0101896:	85 c0                	test   %eax,%eax
f0101898:	75 f9                	jne    f0101893 <mem_init+0x55e>
		--nfree;
	assert(nfree == 0);
f010189a:	85 db                	test   %ebx,%ebx
f010189c:	74 19                	je     f01018b7 <mem_init+0x582>
f010189e:	68 41 6c 10 f0       	push   $0xf0106c41
f01018a3:	68 5a 6a 10 f0       	push   $0xf0106a5a
f01018a8:	68 44 03 00 00       	push   $0x344
f01018ad:	68 34 6a 10 f0       	push   $0xf0106a34
f01018b2:	e8 89 e7 ff ff       	call   f0100040 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f01018b7:	83 ec 0c             	sub    $0xc,%esp
f01018ba:	68 b4 6e 10 f0       	push   $0xf0106eb4
f01018bf:	e8 4c 1f 00 00       	call   f0103810 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01018c4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01018cb:	e8 a8 f6 ff ff       	call   f0100f78 <page_alloc>
f01018d0:	89 c7                	mov    %eax,%edi
f01018d2:	83 c4 10             	add    $0x10,%esp
f01018d5:	85 c0                	test   %eax,%eax
f01018d7:	75 19                	jne    f01018f2 <mem_init+0x5bd>
f01018d9:	68 4f 6b 10 f0       	push   $0xf0106b4f
f01018de:	68 5a 6a 10 f0       	push   $0xf0106a5a
f01018e3:	68 aa 03 00 00       	push   $0x3aa
f01018e8:	68 34 6a 10 f0       	push   $0xf0106a34
f01018ed:	e8 4e e7 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f01018f2:	83 ec 0c             	sub    $0xc,%esp
f01018f5:	6a 00                	push   $0x0
f01018f7:	e8 7c f6 ff ff       	call   f0100f78 <page_alloc>
f01018fc:	89 c3                	mov    %eax,%ebx
f01018fe:	83 c4 10             	add    $0x10,%esp
f0101901:	85 c0                	test   %eax,%eax
f0101903:	75 19                	jne    f010191e <mem_init+0x5e9>
f0101905:	68 65 6b 10 f0       	push   $0xf0106b65
f010190a:	68 5a 6a 10 f0       	push   $0xf0106a5a
f010190f:	68 ab 03 00 00       	push   $0x3ab
f0101914:	68 34 6a 10 f0       	push   $0xf0106a34
f0101919:	e8 22 e7 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f010191e:	83 ec 0c             	sub    $0xc,%esp
f0101921:	6a 00                	push   $0x0
f0101923:	e8 50 f6 ff ff       	call   f0100f78 <page_alloc>
f0101928:	89 c6                	mov    %eax,%esi
f010192a:	83 c4 10             	add    $0x10,%esp
f010192d:	85 c0                	test   %eax,%eax
f010192f:	75 19                	jne    f010194a <mem_init+0x615>
f0101931:	68 7b 6b 10 f0       	push   $0xf0106b7b
f0101936:	68 5a 6a 10 f0       	push   $0xf0106a5a
f010193b:	68 ac 03 00 00       	push   $0x3ac
f0101940:	68 34 6a 10 f0       	push   $0xf0106a34
f0101945:	e8 f6 e6 ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f010194a:	39 df                	cmp    %ebx,%edi
f010194c:	75 19                	jne    f0101967 <mem_init+0x632>
f010194e:	68 91 6b 10 f0       	push   $0xf0106b91
f0101953:	68 5a 6a 10 f0       	push   $0xf0106a5a
f0101958:	68 af 03 00 00       	push   $0x3af
f010195d:	68 34 6a 10 f0       	push   $0xf0106a34
f0101962:	e8 d9 e6 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101967:	39 c3                	cmp    %eax,%ebx
f0101969:	74 04                	je     f010196f <mem_init+0x63a>
f010196b:	39 c7                	cmp    %eax,%edi
f010196d:	75 19                	jne    f0101988 <mem_init+0x653>
f010196f:	68 94 6e 10 f0       	push   $0xf0106e94
f0101974:	68 5a 6a 10 f0       	push   $0xf0106a5a
f0101979:	68 b0 03 00 00       	push   $0x3b0
f010197e:	68 34 6a 10 f0       	push   $0xf0106a34
f0101983:	e8 b8 e6 ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101988:	a1 40 52 24 f0       	mov    0xf0245240,%eax
f010198d:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101990:	c7 05 40 52 24 f0 00 	movl   $0x0,0xf0245240
f0101997:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f010199a:	83 ec 0c             	sub    $0xc,%esp
f010199d:	6a 00                	push   $0x0
f010199f:	e8 d4 f5 ff ff       	call   f0100f78 <page_alloc>
f01019a4:	83 c4 10             	add    $0x10,%esp
f01019a7:	85 c0                	test   %eax,%eax
f01019a9:	74 19                	je     f01019c4 <mem_init+0x68f>
f01019ab:	68 fa 6b 10 f0       	push   $0xf0106bfa
f01019b0:	68 5a 6a 10 f0       	push   $0xf0106a5a
f01019b5:	68 b7 03 00 00       	push   $0x3b7
f01019ba:	68 34 6a 10 f0       	push   $0xf0106a34
f01019bf:	e8 7c e6 ff ff       	call   f0100040 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f01019c4:	83 ec 04             	sub    $0x4,%esp
f01019c7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01019ca:	50                   	push   %eax
f01019cb:	6a 00                	push   $0x0
f01019cd:	ff 35 8c 5e 24 f0    	pushl  0xf0245e8c
f01019d3:	e8 82 f7 ff ff       	call   f010115a <page_lookup>
f01019d8:	83 c4 10             	add    $0x10,%esp
f01019db:	85 c0                	test   %eax,%eax
f01019dd:	74 19                	je     f01019f8 <mem_init+0x6c3>
f01019df:	68 d4 6e 10 f0       	push   $0xf0106ed4
f01019e4:	68 5a 6a 10 f0       	push   $0xf0106a5a
f01019e9:	68 ba 03 00 00       	push   $0x3ba
f01019ee:	68 34 6a 10 f0       	push   $0xf0106a34
f01019f3:	e8 48 e6 ff ff       	call   f0100040 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f01019f8:	6a 02                	push   $0x2
f01019fa:	6a 00                	push   $0x0
f01019fc:	53                   	push   %ebx
f01019fd:	ff 35 8c 5e 24 f0    	pushl  0xf0245e8c
f0101a03:	e8 4f f8 ff ff       	call   f0101257 <page_insert>
f0101a08:	83 c4 10             	add    $0x10,%esp
f0101a0b:	85 c0                	test   %eax,%eax
f0101a0d:	78 19                	js     f0101a28 <mem_init+0x6f3>
f0101a0f:	68 0c 6f 10 f0       	push   $0xf0106f0c
f0101a14:	68 5a 6a 10 f0       	push   $0xf0106a5a
f0101a19:	68 bd 03 00 00       	push   $0x3bd
f0101a1e:	68 34 6a 10 f0       	push   $0xf0106a34
f0101a23:	e8 18 e6 ff ff       	call   f0100040 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101a28:	83 ec 0c             	sub    $0xc,%esp
f0101a2b:	57                   	push   %edi
f0101a2c:	e8 c2 f5 ff ff       	call   f0100ff3 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101a31:	6a 02                	push   $0x2
f0101a33:	6a 00                	push   $0x0
f0101a35:	53                   	push   %ebx
f0101a36:	ff 35 8c 5e 24 f0    	pushl  0xf0245e8c
f0101a3c:	e8 16 f8 ff ff       	call   f0101257 <page_insert>
f0101a41:	83 c4 20             	add    $0x20,%esp
f0101a44:	85 c0                	test   %eax,%eax
f0101a46:	74 19                	je     f0101a61 <mem_init+0x72c>
f0101a48:	68 3c 6f 10 f0       	push   $0xf0106f3c
f0101a4d:	68 5a 6a 10 f0       	push   $0xf0106a5a
f0101a52:	68 c1 03 00 00       	push   $0x3c1
f0101a57:	68 34 6a 10 f0       	push   $0xf0106a34
f0101a5c:	e8 df e5 ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101a61:	a1 8c 5e 24 f0       	mov    0xf0245e8c,%eax
f0101a66:	89 45 d4             	mov    %eax,-0x2c(%ebp)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101a69:	8b 0d 90 5e 24 f0    	mov    0xf0245e90,%ecx
f0101a6f:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f0101a72:	8b 00                	mov    (%eax),%eax
f0101a74:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0101a77:	89 c2                	mov    %eax,%edx
f0101a79:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101a7f:	89 f8                	mov    %edi,%eax
f0101a81:	29 c8                	sub    %ecx,%eax
f0101a83:	c1 f8 03             	sar    $0x3,%eax
f0101a86:	c1 e0 0c             	shl    $0xc,%eax
f0101a89:	39 c2                	cmp    %eax,%edx
f0101a8b:	74 19                	je     f0101aa6 <mem_init+0x771>
f0101a8d:	68 6c 6f 10 f0       	push   $0xf0106f6c
f0101a92:	68 5a 6a 10 f0       	push   $0xf0106a5a
f0101a97:	68 c2 03 00 00       	push   $0x3c2
f0101a9c:	68 34 6a 10 f0       	push   $0xf0106a34
f0101aa1:	e8 9a e5 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101aa6:	ba 00 00 00 00       	mov    $0x0,%edx
f0101aab:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101aae:	e8 82 f0 ff ff       	call   f0100b35 <check_va2pa>
f0101ab3:	89 da                	mov    %ebx,%edx
f0101ab5:	2b 55 cc             	sub    -0x34(%ebp),%edx
f0101ab8:	c1 fa 03             	sar    $0x3,%edx
f0101abb:	c1 e2 0c             	shl    $0xc,%edx
f0101abe:	39 d0                	cmp    %edx,%eax
f0101ac0:	74 19                	je     f0101adb <mem_init+0x7a6>
f0101ac2:	68 94 6f 10 f0       	push   $0xf0106f94
f0101ac7:	68 5a 6a 10 f0       	push   $0xf0106a5a
f0101acc:	68 c3 03 00 00       	push   $0x3c3
f0101ad1:	68 34 6a 10 f0       	push   $0xf0106a34
f0101ad6:	e8 65 e5 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0101adb:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101ae0:	74 19                	je     f0101afb <mem_init+0x7c6>
f0101ae2:	68 4c 6c 10 f0       	push   $0xf0106c4c
f0101ae7:	68 5a 6a 10 f0       	push   $0xf0106a5a
f0101aec:	68 c4 03 00 00       	push   $0x3c4
f0101af1:	68 34 6a 10 f0       	push   $0xf0106a34
f0101af6:	e8 45 e5 ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f0101afb:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101b00:	74 19                	je     f0101b1b <mem_init+0x7e6>
f0101b02:	68 5d 6c 10 f0       	push   $0xf0106c5d
f0101b07:	68 5a 6a 10 f0       	push   $0xf0106a5a
f0101b0c:	68 c5 03 00 00       	push   $0x3c5
f0101b11:	68 34 6a 10 f0       	push   $0xf0106a34
f0101b16:	e8 25 e5 ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101b1b:	6a 02                	push   $0x2
f0101b1d:	68 00 10 00 00       	push   $0x1000
f0101b22:	56                   	push   %esi
f0101b23:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101b26:	e8 2c f7 ff ff       	call   f0101257 <page_insert>
f0101b2b:	83 c4 10             	add    $0x10,%esp
f0101b2e:	85 c0                	test   %eax,%eax
f0101b30:	74 19                	je     f0101b4b <mem_init+0x816>
f0101b32:	68 c4 6f 10 f0       	push   $0xf0106fc4
f0101b37:	68 5a 6a 10 f0       	push   $0xf0106a5a
f0101b3c:	68 c8 03 00 00       	push   $0x3c8
f0101b41:	68 34 6a 10 f0       	push   $0xf0106a34
f0101b46:	e8 f5 e4 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101b4b:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101b50:	a1 8c 5e 24 f0       	mov    0xf0245e8c,%eax
f0101b55:	e8 db ef ff ff       	call   f0100b35 <check_va2pa>
f0101b5a:	89 f2                	mov    %esi,%edx
f0101b5c:	2b 15 90 5e 24 f0    	sub    0xf0245e90,%edx
f0101b62:	c1 fa 03             	sar    $0x3,%edx
f0101b65:	c1 e2 0c             	shl    $0xc,%edx
f0101b68:	39 d0                	cmp    %edx,%eax
f0101b6a:	74 19                	je     f0101b85 <mem_init+0x850>
f0101b6c:	68 00 70 10 f0       	push   $0xf0107000
f0101b71:	68 5a 6a 10 f0       	push   $0xf0106a5a
f0101b76:	68 c9 03 00 00       	push   $0x3c9
f0101b7b:	68 34 6a 10 f0       	push   $0xf0106a34
f0101b80:	e8 bb e4 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101b85:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101b8a:	74 19                	je     f0101ba5 <mem_init+0x870>
f0101b8c:	68 6e 6c 10 f0       	push   $0xf0106c6e
f0101b91:	68 5a 6a 10 f0       	push   $0xf0106a5a
f0101b96:	68 ca 03 00 00       	push   $0x3ca
f0101b9b:	68 34 6a 10 f0       	push   $0xf0106a34
f0101ba0:	e8 9b e4 ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101ba5:	83 ec 0c             	sub    $0xc,%esp
f0101ba8:	6a 00                	push   $0x0
f0101baa:	e8 c9 f3 ff ff       	call   f0100f78 <page_alloc>
f0101baf:	83 c4 10             	add    $0x10,%esp
f0101bb2:	85 c0                	test   %eax,%eax
f0101bb4:	74 19                	je     f0101bcf <mem_init+0x89a>
f0101bb6:	68 fa 6b 10 f0       	push   $0xf0106bfa
f0101bbb:	68 5a 6a 10 f0       	push   $0xf0106a5a
f0101bc0:	68 cd 03 00 00       	push   $0x3cd
f0101bc5:	68 34 6a 10 f0       	push   $0xf0106a34
f0101bca:	e8 71 e4 ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101bcf:	6a 02                	push   $0x2
f0101bd1:	68 00 10 00 00       	push   $0x1000
f0101bd6:	56                   	push   %esi
f0101bd7:	ff 35 8c 5e 24 f0    	pushl  0xf0245e8c
f0101bdd:	e8 75 f6 ff ff       	call   f0101257 <page_insert>
f0101be2:	83 c4 10             	add    $0x10,%esp
f0101be5:	85 c0                	test   %eax,%eax
f0101be7:	74 19                	je     f0101c02 <mem_init+0x8cd>
f0101be9:	68 c4 6f 10 f0       	push   $0xf0106fc4
f0101bee:	68 5a 6a 10 f0       	push   $0xf0106a5a
f0101bf3:	68 d0 03 00 00       	push   $0x3d0
f0101bf8:	68 34 6a 10 f0       	push   $0xf0106a34
f0101bfd:	e8 3e e4 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101c02:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101c07:	a1 8c 5e 24 f0       	mov    0xf0245e8c,%eax
f0101c0c:	e8 24 ef ff ff       	call   f0100b35 <check_va2pa>
f0101c11:	89 f2                	mov    %esi,%edx
f0101c13:	2b 15 90 5e 24 f0    	sub    0xf0245e90,%edx
f0101c19:	c1 fa 03             	sar    $0x3,%edx
f0101c1c:	c1 e2 0c             	shl    $0xc,%edx
f0101c1f:	39 d0                	cmp    %edx,%eax
f0101c21:	74 19                	je     f0101c3c <mem_init+0x907>
f0101c23:	68 00 70 10 f0       	push   $0xf0107000
f0101c28:	68 5a 6a 10 f0       	push   $0xf0106a5a
f0101c2d:	68 d1 03 00 00       	push   $0x3d1
f0101c32:	68 34 6a 10 f0       	push   $0xf0106a34
f0101c37:	e8 04 e4 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101c3c:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101c41:	74 19                	je     f0101c5c <mem_init+0x927>
f0101c43:	68 6e 6c 10 f0       	push   $0xf0106c6e
f0101c48:	68 5a 6a 10 f0       	push   $0xf0106a5a
f0101c4d:	68 d2 03 00 00       	push   $0x3d2
f0101c52:	68 34 6a 10 f0       	push   $0xf0106a34
f0101c57:	e8 e4 e3 ff ff       	call   f0100040 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101c5c:	83 ec 0c             	sub    $0xc,%esp
f0101c5f:	6a 00                	push   $0x0
f0101c61:	e8 12 f3 ff ff       	call   f0100f78 <page_alloc>
f0101c66:	83 c4 10             	add    $0x10,%esp
f0101c69:	85 c0                	test   %eax,%eax
f0101c6b:	74 19                	je     f0101c86 <mem_init+0x951>
f0101c6d:	68 fa 6b 10 f0       	push   $0xf0106bfa
f0101c72:	68 5a 6a 10 f0       	push   $0xf0106a5a
f0101c77:	68 d6 03 00 00       	push   $0x3d6
f0101c7c:	68 34 6a 10 f0       	push   $0xf0106a34
f0101c81:	e8 ba e3 ff ff       	call   f0100040 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101c86:	8b 15 8c 5e 24 f0    	mov    0xf0245e8c,%edx
f0101c8c:	8b 02                	mov    (%edx),%eax
f0101c8e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101c93:	89 c1                	mov    %eax,%ecx
f0101c95:	c1 e9 0c             	shr    $0xc,%ecx
f0101c98:	3b 0d 88 5e 24 f0    	cmp    0xf0245e88,%ecx
f0101c9e:	72 15                	jb     f0101cb5 <mem_init+0x980>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101ca0:	50                   	push   %eax
f0101ca1:	68 c4 64 10 f0       	push   $0xf01064c4
f0101ca6:	68 d9 03 00 00       	push   $0x3d9
f0101cab:	68 34 6a 10 f0       	push   $0xf0106a34
f0101cb0:	e8 8b e3 ff ff       	call   f0100040 <_panic>
f0101cb5:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101cba:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101cbd:	83 ec 04             	sub    $0x4,%esp
f0101cc0:	6a 00                	push   $0x0
f0101cc2:	68 00 10 00 00       	push   $0x1000
f0101cc7:	52                   	push   %edx
f0101cc8:	e8 a0 f3 ff ff       	call   f010106d <pgdir_walk>
f0101ccd:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0101cd0:	8d 51 04             	lea    0x4(%ecx),%edx
f0101cd3:	83 c4 10             	add    $0x10,%esp
f0101cd6:	39 d0                	cmp    %edx,%eax
f0101cd8:	74 19                	je     f0101cf3 <mem_init+0x9be>
f0101cda:	68 30 70 10 f0       	push   $0xf0107030
f0101cdf:	68 5a 6a 10 f0       	push   $0xf0106a5a
f0101ce4:	68 da 03 00 00       	push   $0x3da
f0101ce9:	68 34 6a 10 f0       	push   $0xf0106a34
f0101cee:	e8 4d e3 ff ff       	call   f0100040 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101cf3:	6a 06                	push   $0x6
f0101cf5:	68 00 10 00 00       	push   $0x1000
f0101cfa:	56                   	push   %esi
f0101cfb:	ff 35 8c 5e 24 f0    	pushl  0xf0245e8c
f0101d01:	e8 51 f5 ff ff       	call   f0101257 <page_insert>
f0101d06:	83 c4 10             	add    $0x10,%esp
f0101d09:	85 c0                	test   %eax,%eax
f0101d0b:	74 19                	je     f0101d26 <mem_init+0x9f1>
f0101d0d:	68 70 70 10 f0       	push   $0xf0107070
f0101d12:	68 5a 6a 10 f0       	push   $0xf0106a5a
f0101d17:	68 dd 03 00 00       	push   $0x3dd
f0101d1c:	68 34 6a 10 f0       	push   $0xf0106a34
f0101d21:	e8 1a e3 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101d26:	a1 8c 5e 24 f0       	mov    0xf0245e8c,%eax
f0101d2b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101d2e:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101d33:	e8 fd ed ff ff       	call   f0100b35 <check_va2pa>
f0101d38:	89 f2                	mov    %esi,%edx
f0101d3a:	2b 15 90 5e 24 f0    	sub    0xf0245e90,%edx
f0101d40:	c1 fa 03             	sar    $0x3,%edx
f0101d43:	c1 e2 0c             	shl    $0xc,%edx
f0101d46:	39 d0                	cmp    %edx,%eax
f0101d48:	74 19                	je     f0101d63 <mem_init+0xa2e>
f0101d4a:	68 00 70 10 f0       	push   $0xf0107000
f0101d4f:	68 5a 6a 10 f0       	push   $0xf0106a5a
f0101d54:	68 de 03 00 00       	push   $0x3de
f0101d59:	68 34 6a 10 f0       	push   $0xf0106a34
f0101d5e:	e8 dd e2 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101d63:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101d68:	74 19                	je     f0101d83 <mem_init+0xa4e>
f0101d6a:	68 6e 6c 10 f0       	push   $0xf0106c6e
f0101d6f:	68 5a 6a 10 f0       	push   $0xf0106a5a
f0101d74:	68 df 03 00 00       	push   $0x3df
f0101d79:	68 34 6a 10 f0       	push   $0xf0106a34
f0101d7e:	e8 bd e2 ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101d83:	83 ec 04             	sub    $0x4,%esp
f0101d86:	6a 00                	push   $0x0
f0101d88:	68 00 10 00 00       	push   $0x1000
f0101d8d:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101d90:	e8 d8 f2 ff ff       	call   f010106d <pgdir_walk>
f0101d95:	83 c4 10             	add    $0x10,%esp
f0101d98:	f6 00 04             	testb  $0x4,(%eax)
f0101d9b:	75 19                	jne    f0101db6 <mem_init+0xa81>
f0101d9d:	68 b0 70 10 f0       	push   $0xf01070b0
f0101da2:	68 5a 6a 10 f0       	push   $0xf0106a5a
f0101da7:	68 e0 03 00 00       	push   $0x3e0
f0101dac:	68 34 6a 10 f0       	push   $0xf0106a34
f0101db1:	e8 8a e2 ff ff       	call   f0100040 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0101db6:	a1 8c 5e 24 f0       	mov    0xf0245e8c,%eax
f0101dbb:	f6 00 04             	testb  $0x4,(%eax)
f0101dbe:	75 19                	jne    f0101dd9 <mem_init+0xaa4>
f0101dc0:	68 7f 6c 10 f0       	push   $0xf0106c7f
f0101dc5:	68 5a 6a 10 f0       	push   $0xf0106a5a
f0101dca:	68 e1 03 00 00       	push   $0x3e1
f0101dcf:	68 34 6a 10 f0       	push   $0xf0106a34
f0101dd4:	e8 67 e2 ff ff       	call   f0100040 <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101dd9:	6a 02                	push   $0x2
f0101ddb:	68 00 10 00 00       	push   $0x1000
f0101de0:	56                   	push   %esi
f0101de1:	50                   	push   %eax
f0101de2:	e8 70 f4 ff ff       	call   f0101257 <page_insert>
f0101de7:	83 c4 10             	add    $0x10,%esp
f0101dea:	85 c0                	test   %eax,%eax
f0101dec:	74 19                	je     f0101e07 <mem_init+0xad2>
f0101dee:	68 c4 6f 10 f0       	push   $0xf0106fc4
f0101df3:	68 5a 6a 10 f0       	push   $0xf0106a5a
f0101df8:	68 e4 03 00 00       	push   $0x3e4
f0101dfd:	68 34 6a 10 f0       	push   $0xf0106a34
f0101e02:	e8 39 e2 ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101e07:	83 ec 04             	sub    $0x4,%esp
f0101e0a:	6a 00                	push   $0x0
f0101e0c:	68 00 10 00 00       	push   $0x1000
f0101e11:	ff 35 8c 5e 24 f0    	pushl  0xf0245e8c
f0101e17:	e8 51 f2 ff ff       	call   f010106d <pgdir_walk>
f0101e1c:	83 c4 10             	add    $0x10,%esp
f0101e1f:	f6 00 02             	testb  $0x2,(%eax)
f0101e22:	75 19                	jne    f0101e3d <mem_init+0xb08>
f0101e24:	68 e4 70 10 f0       	push   $0xf01070e4
f0101e29:	68 5a 6a 10 f0       	push   $0xf0106a5a
f0101e2e:	68 e5 03 00 00       	push   $0x3e5
f0101e33:	68 34 6a 10 f0       	push   $0xf0106a34
f0101e38:	e8 03 e2 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101e3d:	83 ec 04             	sub    $0x4,%esp
f0101e40:	6a 00                	push   $0x0
f0101e42:	68 00 10 00 00       	push   $0x1000
f0101e47:	ff 35 8c 5e 24 f0    	pushl  0xf0245e8c
f0101e4d:	e8 1b f2 ff ff       	call   f010106d <pgdir_walk>
f0101e52:	83 c4 10             	add    $0x10,%esp
f0101e55:	f6 00 04             	testb  $0x4,(%eax)
f0101e58:	74 19                	je     f0101e73 <mem_init+0xb3e>
f0101e5a:	68 18 71 10 f0       	push   $0xf0107118
f0101e5f:	68 5a 6a 10 f0       	push   $0xf0106a5a
f0101e64:	68 e6 03 00 00       	push   $0x3e6
f0101e69:	68 34 6a 10 f0       	push   $0xf0106a34
f0101e6e:	e8 cd e1 ff ff       	call   f0100040 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101e73:	6a 02                	push   $0x2
f0101e75:	68 00 00 40 00       	push   $0x400000
f0101e7a:	57                   	push   %edi
f0101e7b:	ff 35 8c 5e 24 f0    	pushl  0xf0245e8c
f0101e81:	e8 d1 f3 ff ff       	call   f0101257 <page_insert>
f0101e86:	83 c4 10             	add    $0x10,%esp
f0101e89:	85 c0                	test   %eax,%eax
f0101e8b:	78 19                	js     f0101ea6 <mem_init+0xb71>
f0101e8d:	68 50 71 10 f0       	push   $0xf0107150
f0101e92:	68 5a 6a 10 f0       	push   $0xf0106a5a
f0101e97:	68 e9 03 00 00       	push   $0x3e9
f0101e9c:	68 34 6a 10 f0       	push   $0xf0106a34
f0101ea1:	e8 9a e1 ff ff       	call   f0100040 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101ea6:	6a 02                	push   $0x2
f0101ea8:	68 00 10 00 00       	push   $0x1000
f0101ead:	53                   	push   %ebx
f0101eae:	ff 35 8c 5e 24 f0    	pushl  0xf0245e8c
f0101eb4:	e8 9e f3 ff ff       	call   f0101257 <page_insert>
f0101eb9:	83 c4 10             	add    $0x10,%esp
f0101ebc:	85 c0                	test   %eax,%eax
f0101ebe:	74 19                	je     f0101ed9 <mem_init+0xba4>
f0101ec0:	68 88 71 10 f0       	push   $0xf0107188
f0101ec5:	68 5a 6a 10 f0       	push   $0xf0106a5a
f0101eca:	68 ec 03 00 00       	push   $0x3ec
f0101ecf:	68 34 6a 10 f0       	push   $0xf0106a34
f0101ed4:	e8 67 e1 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101ed9:	83 ec 04             	sub    $0x4,%esp
f0101edc:	6a 00                	push   $0x0
f0101ede:	68 00 10 00 00       	push   $0x1000
f0101ee3:	ff 35 8c 5e 24 f0    	pushl  0xf0245e8c
f0101ee9:	e8 7f f1 ff ff       	call   f010106d <pgdir_walk>
f0101eee:	83 c4 10             	add    $0x10,%esp
f0101ef1:	f6 00 04             	testb  $0x4,(%eax)
f0101ef4:	74 19                	je     f0101f0f <mem_init+0xbda>
f0101ef6:	68 18 71 10 f0       	push   $0xf0107118
f0101efb:	68 5a 6a 10 f0       	push   $0xf0106a5a
f0101f00:	68 ed 03 00 00       	push   $0x3ed
f0101f05:	68 34 6a 10 f0       	push   $0xf0106a34
f0101f0a:	e8 31 e1 ff ff       	call   f0100040 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101f0f:	a1 8c 5e 24 f0       	mov    0xf0245e8c,%eax
f0101f14:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101f17:	ba 00 00 00 00       	mov    $0x0,%edx
f0101f1c:	e8 14 ec ff ff       	call   f0100b35 <check_va2pa>
f0101f21:	89 c1                	mov    %eax,%ecx
f0101f23:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101f26:	89 d8                	mov    %ebx,%eax
f0101f28:	2b 05 90 5e 24 f0    	sub    0xf0245e90,%eax
f0101f2e:	c1 f8 03             	sar    $0x3,%eax
f0101f31:	c1 e0 0c             	shl    $0xc,%eax
f0101f34:	39 c1                	cmp    %eax,%ecx
f0101f36:	74 19                	je     f0101f51 <mem_init+0xc1c>
f0101f38:	68 c4 71 10 f0       	push   $0xf01071c4
f0101f3d:	68 5a 6a 10 f0       	push   $0xf0106a5a
f0101f42:	68 f0 03 00 00       	push   $0x3f0
f0101f47:	68 34 6a 10 f0       	push   $0xf0106a34
f0101f4c:	e8 ef e0 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101f51:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101f56:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101f59:	e8 d7 eb ff ff       	call   f0100b35 <check_va2pa>
f0101f5e:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0101f61:	74 19                	je     f0101f7c <mem_init+0xc47>
f0101f63:	68 f0 71 10 f0       	push   $0xf01071f0
f0101f68:	68 5a 6a 10 f0       	push   $0xf0106a5a
f0101f6d:	68 f1 03 00 00       	push   $0x3f1
f0101f72:	68 34 6a 10 f0       	push   $0xf0106a34
f0101f77:	e8 c4 e0 ff ff       	call   f0100040 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0101f7c:	66 83 7b 04 02       	cmpw   $0x2,0x4(%ebx)
f0101f81:	74 19                	je     f0101f9c <mem_init+0xc67>
f0101f83:	68 95 6c 10 f0       	push   $0xf0106c95
f0101f88:	68 5a 6a 10 f0       	push   $0xf0106a5a
f0101f8d:	68 f3 03 00 00       	push   $0x3f3
f0101f92:	68 34 6a 10 f0       	push   $0xf0106a34
f0101f97:	e8 a4 e0 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0101f9c:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101fa1:	74 19                	je     f0101fbc <mem_init+0xc87>
f0101fa3:	68 a6 6c 10 f0       	push   $0xf0106ca6
f0101fa8:	68 5a 6a 10 f0       	push   $0xf0106a5a
f0101fad:	68 f4 03 00 00       	push   $0x3f4
f0101fb2:	68 34 6a 10 f0       	push   $0xf0106a34
f0101fb7:	e8 84 e0 ff ff       	call   f0100040 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0101fbc:	83 ec 0c             	sub    $0xc,%esp
f0101fbf:	6a 00                	push   $0x0
f0101fc1:	e8 b2 ef ff ff       	call   f0100f78 <page_alloc>
f0101fc6:	83 c4 10             	add    $0x10,%esp
f0101fc9:	85 c0                	test   %eax,%eax
f0101fcb:	74 04                	je     f0101fd1 <mem_init+0xc9c>
f0101fcd:	39 c6                	cmp    %eax,%esi
f0101fcf:	74 19                	je     f0101fea <mem_init+0xcb5>
f0101fd1:	68 20 72 10 f0       	push   $0xf0107220
f0101fd6:	68 5a 6a 10 f0       	push   $0xf0106a5a
f0101fdb:	68 f7 03 00 00       	push   $0x3f7
f0101fe0:	68 34 6a 10 f0       	push   $0xf0106a34
f0101fe5:	e8 56 e0 ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0101fea:	83 ec 08             	sub    $0x8,%esp
f0101fed:	6a 00                	push   $0x0
f0101fef:	ff 35 8c 5e 24 f0    	pushl  0xf0245e8c
f0101ff5:	e8 10 f2 ff ff       	call   f010120a <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101ffa:	a1 8c 5e 24 f0       	mov    0xf0245e8c,%eax
f0101fff:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102002:	ba 00 00 00 00       	mov    $0x0,%edx
f0102007:	e8 29 eb ff ff       	call   f0100b35 <check_va2pa>
f010200c:	83 c4 10             	add    $0x10,%esp
f010200f:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102012:	74 19                	je     f010202d <mem_init+0xcf8>
f0102014:	68 44 72 10 f0       	push   $0xf0107244
f0102019:	68 5a 6a 10 f0       	push   $0xf0106a5a
f010201e:	68 fb 03 00 00       	push   $0x3fb
f0102023:	68 34 6a 10 f0       	push   $0xf0106a34
f0102028:	e8 13 e0 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f010202d:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102032:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102035:	e8 fb ea ff ff       	call   f0100b35 <check_va2pa>
f010203a:	89 da                	mov    %ebx,%edx
f010203c:	2b 15 90 5e 24 f0    	sub    0xf0245e90,%edx
f0102042:	c1 fa 03             	sar    $0x3,%edx
f0102045:	c1 e2 0c             	shl    $0xc,%edx
f0102048:	39 d0                	cmp    %edx,%eax
f010204a:	74 19                	je     f0102065 <mem_init+0xd30>
f010204c:	68 f0 71 10 f0       	push   $0xf01071f0
f0102051:	68 5a 6a 10 f0       	push   $0xf0106a5a
f0102056:	68 fc 03 00 00       	push   $0x3fc
f010205b:	68 34 6a 10 f0       	push   $0xf0106a34
f0102060:	e8 db df ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0102065:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f010206a:	74 19                	je     f0102085 <mem_init+0xd50>
f010206c:	68 4c 6c 10 f0       	push   $0xf0106c4c
f0102071:	68 5a 6a 10 f0       	push   $0xf0106a5a
f0102076:	68 fd 03 00 00       	push   $0x3fd
f010207b:	68 34 6a 10 f0       	push   $0xf0106a34
f0102080:	e8 bb df ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102085:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f010208a:	74 19                	je     f01020a5 <mem_init+0xd70>
f010208c:	68 a6 6c 10 f0       	push   $0xf0106ca6
f0102091:	68 5a 6a 10 f0       	push   $0xf0106a5a
f0102096:	68 fe 03 00 00       	push   $0x3fe
f010209b:	68 34 6a 10 f0       	push   $0xf0106a34
f01020a0:	e8 9b df ff ff       	call   f0100040 <_panic>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f01020a5:	6a 00                	push   $0x0
f01020a7:	68 00 10 00 00       	push   $0x1000
f01020ac:	53                   	push   %ebx
f01020ad:	ff 75 d4             	pushl  -0x2c(%ebp)
f01020b0:	e8 a2 f1 ff ff       	call   f0101257 <page_insert>
f01020b5:	83 c4 10             	add    $0x10,%esp
f01020b8:	85 c0                	test   %eax,%eax
f01020ba:	74 19                	je     f01020d5 <mem_init+0xda0>
f01020bc:	68 68 72 10 f0       	push   $0xf0107268
f01020c1:	68 5a 6a 10 f0       	push   $0xf0106a5a
f01020c6:	68 01 04 00 00       	push   $0x401
f01020cb:	68 34 6a 10 f0       	push   $0xf0106a34
f01020d0:	e8 6b df ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref);
f01020d5:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01020da:	75 19                	jne    f01020f5 <mem_init+0xdc0>
f01020dc:	68 b7 6c 10 f0       	push   $0xf0106cb7
f01020e1:	68 5a 6a 10 f0       	push   $0xf0106a5a
f01020e6:	68 02 04 00 00       	push   $0x402
f01020eb:	68 34 6a 10 f0       	push   $0xf0106a34
f01020f0:	e8 4b df ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_link == NULL);
f01020f5:	83 3b 00             	cmpl   $0x0,(%ebx)
f01020f8:	74 19                	je     f0102113 <mem_init+0xdde>
f01020fa:	68 c3 6c 10 f0       	push   $0xf0106cc3
f01020ff:	68 5a 6a 10 f0       	push   $0xf0106a5a
f0102104:	68 03 04 00 00       	push   $0x403
f0102109:	68 34 6a 10 f0       	push   $0xf0106a34
f010210e:	e8 2d df ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102113:	83 ec 08             	sub    $0x8,%esp
f0102116:	68 00 10 00 00       	push   $0x1000
f010211b:	ff 35 8c 5e 24 f0    	pushl  0xf0245e8c
f0102121:	e8 e4 f0 ff ff       	call   f010120a <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102126:	a1 8c 5e 24 f0       	mov    0xf0245e8c,%eax
f010212b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010212e:	ba 00 00 00 00       	mov    $0x0,%edx
f0102133:	e8 fd e9 ff ff       	call   f0100b35 <check_va2pa>
f0102138:	83 c4 10             	add    $0x10,%esp
f010213b:	83 f8 ff             	cmp    $0xffffffff,%eax
f010213e:	74 19                	je     f0102159 <mem_init+0xe24>
f0102140:	68 44 72 10 f0       	push   $0xf0107244
f0102145:	68 5a 6a 10 f0       	push   $0xf0106a5a
f010214a:	68 07 04 00 00       	push   $0x407
f010214f:	68 34 6a 10 f0       	push   $0xf0106a34
f0102154:	e8 e7 de ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102159:	ba 00 10 00 00       	mov    $0x1000,%edx
f010215e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102161:	e8 cf e9 ff ff       	call   f0100b35 <check_va2pa>
f0102166:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102169:	74 19                	je     f0102184 <mem_init+0xe4f>
f010216b:	68 a0 72 10 f0       	push   $0xf01072a0
f0102170:	68 5a 6a 10 f0       	push   $0xf0106a5a
f0102175:	68 08 04 00 00       	push   $0x408
f010217a:	68 34 6a 10 f0       	push   $0xf0106a34
f010217f:	e8 bc de ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f0102184:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102189:	74 19                	je     f01021a4 <mem_init+0xe6f>
f010218b:	68 d8 6c 10 f0       	push   $0xf0106cd8
f0102190:	68 5a 6a 10 f0       	push   $0xf0106a5a
f0102195:	68 09 04 00 00       	push   $0x409
f010219a:	68 34 6a 10 f0       	push   $0xf0106a34
f010219f:	e8 9c de ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f01021a4:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f01021a9:	74 19                	je     f01021c4 <mem_init+0xe8f>
f01021ab:	68 a6 6c 10 f0       	push   $0xf0106ca6
f01021b0:	68 5a 6a 10 f0       	push   $0xf0106a5a
f01021b5:	68 0a 04 00 00       	push   $0x40a
f01021ba:	68 34 6a 10 f0       	push   $0xf0106a34
f01021bf:	e8 7c de ff ff       	call   f0100040 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f01021c4:	83 ec 0c             	sub    $0xc,%esp
f01021c7:	6a 00                	push   $0x0
f01021c9:	e8 aa ed ff ff       	call   f0100f78 <page_alloc>
f01021ce:	83 c4 10             	add    $0x10,%esp
f01021d1:	85 c0                	test   %eax,%eax
f01021d3:	74 04                	je     f01021d9 <mem_init+0xea4>
f01021d5:	39 c3                	cmp    %eax,%ebx
f01021d7:	74 19                	je     f01021f2 <mem_init+0xebd>
f01021d9:	68 c8 72 10 f0       	push   $0xf01072c8
f01021de:	68 5a 6a 10 f0       	push   $0xf0106a5a
f01021e3:	68 0d 04 00 00       	push   $0x40d
f01021e8:	68 34 6a 10 f0       	push   $0xf0106a34
f01021ed:	e8 4e de ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f01021f2:	83 ec 0c             	sub    $0xc,%esp
f01021f5:	6a 00                	push   $0x0
f01021f7:	e8 7c ed ff ff       	call   f0100f78 <page_alloc>
f01021fc:	83 c4 10             	add    $0x10,%esp
f01021ff:	85 c0                	test   %eax,%eax
f0102201:	74 19                	je     f010221c <mem_init+0xee7>
f0102203:	68 fa 6b 10 f0       	push   $0xf0106bfa
f0102208:	68 5a 6a 10 f0       	push   $0xf0106a5a
f010220d:	68 10 04 00 00       	push   $0x410
f0102212:	68 34 6a 10 f0       	push   $0xf0106a34
f0102217:	e8 24 de ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010221c:	8b 0d 8c 5e 24 f0    	mov    0xf0245e8c,%ecx
f0102222:	8b 11                	mov    (%ecx),%edx
f0102224:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f010222a:	89 f8                	mov    %edi,%eax
f010222c:	2b 05 90 5e 24 f0    	sub    0xf0245e90,%eax
f0102232:	c1 f8 03             	sar    $0x3,%eax
f0102235:	c1 e0 0c             	shl    $0xc,%eax
f0102238:	39 c2                	cmp    %eax,%edx
f010223a:	74 19                	je     f0102255 <mem_init+0xf20>
f010223c:	68 6c 6f 10 f0       	push   $0xf0106f6c
f0102241:	68 5a 6a 10 f0       	push   $0xf0106a5a
f0102246:	68 13 04 00 00       	push   $0x413
f010224b:	68 34 6a 10 f0       	push   $0xf0106a34
f0102250:	e8 eb dd ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f0102255:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f010225b:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102260:	74 19                	je     f010227b <mem_init+0xf46>
f0102262:	68 5d 6c 10 f0       	push   $0xf0106c5d
f0102267:	68 5a 6a 10 f0       	push   $0xf0106a5a
f010226c:	68 15 04 00 00       	push   $0x415
f0102271:	68 34 6a 10 f0       	push   $0xf0106a34
f0102276:	e8 c5 dd ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f010227b:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0102281:	83 ec 0c             	sub    $0xc,%esp
f0102284:	57                   	push   %edi
f0102285:	e8 69 ed ff ff       	call   f0100ff3 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f010228a:	83 c4 0c             	add    $0xc,%esp
f010228d:	6a 01                	push   $0x1
f010228f:	68 00 10 40 00       	push   $0x401000
f0102294:	ff 35 8c 5e 24 f0    	pushl  0xf0245e8c
f010229a:	e8 ce ed ff ff       	call   f010106d <pgdir_walk>
f010229f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01022a2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f01022a5:	a1 8c 5e 24 f0       	mov    0xf0245e8c,%eax
f01022aa:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01022ad:	8b 50 04             	mov    0x4(%eax),%edx
f01022b0:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01022b6:	a1 88 5e 24 f0       	mov    0xf0245e88,%eax
f01022bb:	89 45 c8             	mov    %eax,-0x38(%ebp)
f01022be:	89 d1                	mov    %edx,%ecx
f01022c0:	c1 e9 0c             	shr    $0xc,%ecx
f01022c3:	83 c4 10             	add    $0x10,%esp
f01022c6:	39 c1                	cmp    %eax,%ecx
f01022c8:	72 15                	jb     f01022df <mem_init+0xfaa>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01022ca:	52                   	push   %edx
f01022cb:	68 c4 64 10 f0       	push   $0xf01064c4
f01022d0:	68 1c 04 00 00       	push   $0x41c
f01022d5:	68 34 6a 10 f0       	push   $0xf0106a34
f01022da:	e8 61 dd ff ff       	call   f0100040 <_panic>
	assert(ptep == ptep1 + PTX(va));
f01022df:	81 ea fc ff ff 0f    	sub    $0xffffffc,%edx
f01022e5:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
f01022e8:	74 19                	je     f0102303 <mem_init+0xfce>
f01022ea:	68 e9 6c 10 f0       	push   $0xf0106ce9
f01022ef:	68 5a 6a 10 f0       	push   $0xf0106a5a
f01022f4:	68 1d 04 00 00       	push   $0x41d
f01022f9:	68 34 6a 10 f0       	push   $0xf0106a34
f01022fe:	e8 3d dd ff ff       	call   f0100040 <_panic>
	kern_pgdir[PDX(va)] = 0;
f0102303:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0102306:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	pp0->pp_ref = 0;
f010230d:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102313:	89 f8                	mov    %edi,%eax
f0102315:	2b 05 90 5e 24 f0    	sub    0xf0245e90,%eax
f010231b:	c1 f8 03             	sar    $0x3,%eax
f010231e:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102321:	89 c2                	mov    %eax,%edx
f0102323:	c1 ea 0c             	shr    $0xc,%edx
f0102326:	39 55 c8             	cmp    %edx,-0x38(%ebp)
f0102329:	77 12                	ja     f010233d <mem_init+0x1008>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010232b:	50                   	push   %eax
f010232c:	68 c4 64 10 f0       	push   $0xf01064c4
f0102331:	6a 58                	push   $0x58
f0102333:	68 40 6a 10 f0       	push   $0xf0106a40
f0102338:	e8 03 dd ff ff       	call   f0100040 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f010233d:	83 ec 04             	sub    $0x4,%esp
f0102340:	68 00 10 00 00       	push   $0x1000
f0102345:	68 ff 00 00 00       	push   $0xff
f010234a:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010234f:	50                   	push   %eax
f0102350:	e8 10 34 00 00       	call   f0105765 <memset>
	page_free(pp0);
f0102355:	89 3c 24             	mov    %edi,(%esp)
f0102358:	e8 96 ec ff ff       	call   f0100ff3 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f010235d:	83 c4 0c             	add    $0xc,%esp
f0102360:	6a 01                	push   $0x1
f0102362:	6a 00                	push   $0x0
f0102364:	ff 35 8c 5e 24 f0    	pushl  0xf0245e8c
f010236a:	e8 fe ec ff ff       	call   f010106d <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010236f:	89 fa                	mov    %edi,%edx
f0102371:	2b 15 90 5e 24 f0    	sub    0xf0245e90,%edx
f0102377:	c1 fa 03             	sar    $0x3,%edx
f010237a:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010237d:	89 d0                	mov    %edx,%eax
f010237f:	c1 e8 0c             	shr    $0xc,%eax
f0102382:	83 c4 10             	add    $0x10,%esp
f0102385:	3b 05 88 5e 24 f0    	cmp    0xf0245e88,%eax
f010238b:	72 12                	jb     f010239f <mem_init+0x106a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010238d:	52                   	push   %edx
f010238e:	68 c4 64 10 f0       	push   $0xf01064c4
f0102393:	6a 58                	push   $0x58
f0102395:	68 40 6a 10 f0       	push   $0xf0106a40
f010239a:	e8 a1 dc ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f010239f:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f01023a5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f01023a8:	f6 82 00 00 00 f0 01 	testb  $0x1,-0x10000000(%edx)
f01023af:	75 11                	jne    f01023c2 <mem_init+0x108d>
f01023b1:	8d 82 04 00 00 f0    	lea    -0xffffffc(%edx),%eax
f01023b7:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
f01023bd:	f6 00 01             	testb  $0x1,(%eax)
f01023c0:	74 19                	je     f01023db <mem_init+0x10a6>
f01023c2:	68 01 6d 10 f0       	push   $0xf0106d01
f01023c7:	68 5a 6a 10 f0       	push   $0xf0106a5a
f01023cc:	68 27 04 00 00       	push   $0x427
f01023d1:	68 34 6a 10 f0       	push   $0xf0106a34
f01023d6:	e8 65 dc ff ff       	call   f0100040 <_panic>
f01023db:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f01023de:	39 d0                	cmp    %edx,%eax
f01023e0:	75 db                	jne    f01023bd <mem_init+0x1088>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f01023e2:	a1 8c 5e 24 f0       	mov    0xf0245e8c,%eax
f01023e7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f01023ed:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)

	// give free list back
	page_free_list = fl;
f01023f3:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01023f6:	a3 40 52 24 f0       	mov    %eax,0xf0245240

	// free the pages we took
	page_free(pp0);
f01023fb:	83 ec 0c             	sub    $0xc,%esp
f01023fe:	57                   	push   %edi
f01023ff:	e8 ef eb ff ff       	call   f0100ff3 <page_free>
	page_free(pp1);
f0102404:	89 1c 24             	mov    %ebx,(%esp)
f0102407:	e8 e7 eb ff ff       	call   f0100ff3 <page_free>
	page_free(pp2);
f010240c:	89 34 24             	mov    %esi,(%esp)
f010240f:	e8 df eb ff ff       	call   f0100ff3 <page_free>

	// test mmio_map_region
	mm1 = (uintptr_t) mmio_map_region(0, 4097);
f0102414:	83 c4 08             	add    $0x8,%esp
f0102417:	68 01 10 00 00       	push   $0x1001
f010241c:	6a 00                	push   $0x0
f010241e:	e8 b1 ee ff ff       	call   f01012d4 <mmio_map_region>
f0102423:	89 c3                	mov    %eax,%ebx
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
f0102425:	83 c4 08             	add    $0x8,%esp
f0102428:	68 00 10 00 00       	push   $0x1000
f010242d:	6a 00                	push   $0x0
f010242f:	e8 a0 ee ff ff       	call   f01012d4 <mmio_map_region>
f0102434:	89 c6                	mov    %eax,%esi
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8096 < MMIOLIM);
f0102436:	83 c4 10             	add    $0x10,%esp
f0102439:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f010243f:	76 0d                	jbe    f010244e <mem_init+0x1119>
f0102441:	8d 83 a0 1f 00 00    	lea    0x1fa0(%ebx),%eax
f0102447:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f010244c:	76 19                	jbe    f0102467 <mem_init+0x1132>
f010244e:	68 ec 72 10 f0       	push   $0xf01072ec
f0102453:	68 5a 6a 10 f0       	push   $0xf0106a5a
f0102458:	68 37 04 00 00       	push   $0x437
f010245d:	68 34 6a 10 f0       	push   $0xf0106a34
f0102462:	e8 d9 db ff ff       	call   f0100040 <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8096 < MMIOLIM);
f0102467:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f010246d:	76 0e                	jbe    f010247d <mem_init+0x1148>
f010246f:	8d 96 a0 1f 00 00    	lea    0x1fa0(%esi),%edx
f0102475:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f010247b:	76 19                	jbe    f0102496 <mem_init+0x1161>
f010247d:	68 14 73 10 f0       	push   $0xf0107314
f0102482:	68 5a 6a 10 f0       	push   $0xf0106a5a
f0102487:	68 38 04 00 00       	push   $0x438
f010248c:	68 34 6a 10 f0       	push   $0xf0106a34
f0102491:	e8 aa db ff ff       	call   f0100040 <_panic>
	// check that they're page-aligned
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f0102496:	89 da                	mov    %ebx,%edx
f0102498:	09 f2                	or     %esi,%edx
f010249a:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f01024a0:	74 19                	je     f01024bb <mem_init+0x1186>
f01024a2:	68 3c 73 10 f0       	push   $0xf010733c
f01024a7:	68 5a 6a 10 f0       	push   $0xf0106a5a
f01024ac:	68 3a 04 00 00       	push   $0x43a
f01024b1:	68 34 6a 10 f0       	push   $0xf0106a34
f01024b6:	e8 85 db ff ff       	call   f0100040 <_panic>
	// check that they don't overlap
	assert(mm1 + 8096 <= mm2);
f01024bb:	39 c6                	cmp    %eax,%esi
f01024bd:	73 19                	jae    f01024d8 <mem_init+0x11a3>
f01024bf:	68 18 6d 10 f0       	push   $0xf0106d18
f01024c4:	68 5a 6a 10 f0       	push   $0xf0106a5a
f01024c9:	68 3c 04 00 00       	push   $0x43c
f01024ce:	68 34 6a 10 f0       	push   $0xf0106a34
f01024d3:	e8 68 db ff ff       	call   f0100040 <_panic>
	// check page mappings
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f01024d8:	8b 3d 8c 5e 24 f0    	mov    0xf0245e8c,%edi
f01024de:	89 da                	mov    %ebx,%edx
f01024e0:	89 f8                	mov    %edi,%eax
f01024e2:	e8 4e e6 ff ff       	call   f0100b35 <check_va2pa>
f01024e7:	85 c0                	test   %eax,%eax
f01024e9:	74 19                	je     f0102504 <mem_init+0x11cf>
f01024eb:	68 64 73 10 f0       	push   $0xf0107364
f01024f0:	68 5a 6a 10 f0       	push   $0xf0106a5a
f01024f5:	68 3e 04 00 00       	push   $0x43e
f01024fa:	68 34 6a 10 f0       	push   $0xf0106a34
f01024ff:	e8 3c db ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f0102504:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
f010250a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010250d:	89 c2                	mov    %eax,%edx
f010250f:	89 f8                	mov    %edi,%eax
f0102511:	e8 1f e6 ff ff       	call   f0100b35 <check_va2pa>
f0102516:	3d 00 10 00 00       	cmp    $0x1000,%eax
f010251b:	74 19                	je     f0102536 <mem_init+0x1201>
f010251d:	68 88 73 10 f0       	push   $0xf0107388
f0102522:	68 5a 6a 10 f0       	push   $0xf0106a5a
f0102527:	68 3f 04 00 00       	push   $0x43f
f010252c:	68 34 6a 10 f0       	push   $0xf0106a34
f0102531:	e8 0a db ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f0102536:	89 f2                	mov    %esi,%edx
f0102538:	89 f8                	mov    %edi,%eax
f010253a:	e8 f6 e5 ff ff       	call   f0100b35 <check_va2pa>
f010253f:	85 c0                	test   %eax,%eax
f0102541:	74 19                	je     f010255c <mem_init+0x1227>
f0102543:	68 b8 73 10 f0       	push   $0xf01073b8
f0102548:	68 5a 6a 10 f0       	push   $0xf0106a5a
f010254d:	68 40 04 00 00       	push   $0x440
f0102552:	68 34 6a 10 f0       	push   $0xf0106a34
f0102557:	e8 e4 da ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f010255c:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
f0102562:	89 f8                	mov    %edi,%eax
f0102564:	e8 cc e5 ff ff       	call   f0100b35 <check_va2pa>
f0102569:	83 f8 ff             	cmp    $0xffffffff,%eax
f010256c:	74 19                	je     f0102587 <mem_init+0x1252>
f010256e:	68 dc 73 10 f0       	push   $0xf01073dc
f0102573:	68 5a 6a 10 f0       	push   $0xf0106a5a
f0102578:	68 41 04 00 00       	push   $0x441
f010257d:	68 34 6a 10 f0       	push   $0xf0106a34
f0102582:	e8 b9 da ff ff       	call   f0100040 <_panic>
	// check permissions
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f0102587:	83 ec 04             	sub    $0x4,%esp
f010258a:	6a 00                	push   $0x0
f010258c:	53                   	push   %ebx
f010258d:	57                   	push   %edi
f010258e:	e8 da ea ff ff       	call   f010106d <pgdir_walk>
f0102593:	83 c4 10             	add    $0x10,%esp
f0102596:	f6 00 1a             	testb  $0x1a,(%eax)
f0102599:	75 19                	jne    f01025b4 <mem_init+0x127f>
f010259b:	68 08 74 10 f0       	push   $0xf0107408
f01025a0:	68 5a 6a 10 f0       	push   $0xf0106a5a
f01025a5:	68 43 04 00 00       	push   $0x443
f01025aa:	68 34 6a 10 f0       	push   $0xf0106a34
f01025af:	e8 8c da ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f01025b4:	83 ec 04             	sub    $0x4,%esp
f01025b7:	6a 00                	push   $0x0
f01025b9:	53                   	push   %ebx
f01025ba:	ff 35 8c 5e 24 f0    	pushl  0xf0245e8c
f01025c0:	e8 a8 ea ff ff       	call   f010106d <pgdir_walk>
f01025c5:	8b 00                	mov    (%eax),%eax
f01025c7:	83 c4 10             	add    $0x10,%esp
f01025ca:	83 e0 04             	and    $0x4,%eax
f01025cd:	89 45 c8             	mov    %eax,-0x38(%ebp)
f01025d0:	74 19                	je     f01025eb <mem_init+0x12b6>
f01025d2:	68 4c 74 10 f0       	push   $0xf010744c
f01025d7:	68 5a 6a 10 f0       	push   $0xf0106a5a
f01025dc:	68 44 04 00 00       	push   $0x444
f01025e1:	68 34 6a 10 f0       	push   $0xf0106a34
f01025e6:	e8 55 da ff ff       	call   f0100040 <_panic>
	// clear the mappings
	*pgdir_walk(kern_pgdir, (void*) mm1, 0) = 0;
f01025eb:	83 ec 04             	sub    $0x4,%esp
f01025ee:	6a 00                	push   $0x0
f01025f0:	53                   	push   %ebx
f01025f1:	ff 35 8c 5e 24 f0    	pushl  0xf0245e8c
f01025f7:	e8 71 ea ff ff       	call   f010106d <pgdir_walk>
f01025fc:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm1 + PGSIZE, 0) = 0;
f0102602:	83 c4 0c             	add    $0xc,%esp
f0102605:	6a 00                	push   $0x0
f0102607:	ff 75 d4             	pushl  -0x2c(%ebp)
f010260a:	ff 35 8c 5e 24 f0    	pushl  0xf0245e8c
f0102610:	e8 58 ea ff ff       	call   f010106d <pgdir_walk>
f0102615:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm2, 0) = 0;
f010261b:	83 c4 0c             	add    $0xc,%esp
f010261e:	6a 00                	push   $0x0
f0102620:	56                   	push   %esi
f0102621:	ff 35 8c 5e 24 f0    	pushl  0xf0245e8c
f0102627:	e8 41 ea ff ff       	call   f010106d <pgdir_walk>
f010262c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	cprintf("check_page() succeeded!\n");
f0102632:	c7 04 24 2a 6d 10 f0 	movl   $0xf0106d2a,(%esp)
f0102639:	e8 d2 11 00 00       	call   f0103810 <cprintf>
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir, UPAGES, PTSIZE, PADDR(pages), PTE_U);
f010263e:	a1 90 5e 24 f0       	mov    0xf0245e90,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102643:	83 c4 10             	add    $0x10,%esp
f0102646:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010264b:	77 15                	ja     f0102662 <mem_init+0x132d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010264d:	50                   	push   %eax
f010264e:	68 e8 64 10 f0       	push   $0xf01064e8
f0102653:	68 ba 00 00 00       	push   $0xba
f0102658:	68 34 6a 10 f0       	push   $0xf0106a34
f010265d:	e8 de d9 ff ff       	call   f0100040 <_panic>
f0102662:	83 ec 08             	sub    $0x8,%esp
f0102665:	6a 04                	push   $0x4
f0102667:	05 00 00 00 10       	add    $0x10000000,%eax
f010266c:	50                   	push   %eax
f010266d:	b9 00 00 40 00       	mov    $0x400000,%ecx
f0102672:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0102677:	a1 8c 5e 24 f0       	mov    0xf0245e8c,%eax
f010267c:	e8 7f ea ff ff       	call   f0101100 <boot_map_region>
	// (ie. perm = PTE_U | PTE_P).
	// Permissions:
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.
	boot_map_region(kern_pgdir, UENVS, PTSIZE, PADDR(envs), PTE_U);	
f0102681:	a1 48 52 24 f0       	mov    0xf0245248,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102686:	83 c4 10             	add    $0x10,%esp
f0102689:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010268e:	77 15                	ja     f01026a5 <mem_init+0x1370>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102690:	50                   	push   %eax
f0102691:	68 e8 64 10 f0       	push   $0xf01064e8
f0102696:	68 c3 00 00 00       	push   $0xc3
f010269b:	68 34 6a 10 f0       	push   $0xf0106a34
f01026a0:	e8 9b d9 ff ff       	call   f0100040 <_panic>
f01026a5:	83 ec 08             	sub    $0x8,%esp
f01026a8:	6a 04                	push   $0x4
f01026aa:	05 00 00 00 10       	add    $0x10000000,%eax
f01026af:	50                   	push   %eax
f01026b0:	b9 00 00 40 00       	mov    $0x400000,%ecx
f01026b5:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f01026ba:	a1 8c 5e 24 f0       	mov    0xf0245e8c,%eax
f01026bf:	e8 3c ea ff ff       	call   f0101100 <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01026c4:	83 c4 10             	add    $0x10,%esp
f01026c7:	b8 00 60 11 f0       	mov    $0xf0116000,%eax
f01026cc:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01026d1:	77 15                	ja     f01026e8 <mem_init+0x13b3>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01026d3:	50                   	push   %eax
f01026d4:	68 e8 64 10 f0       	push   $0xf01064e8
f01026d9:	68 d0 00 00 00       	push   $0xd0
f01026de:	68 34 6a 10 f0       	push   $0xf0106a34
f01026e3:	e8 58 d9 ff ff       	call   f0100040 <_panic>
	//     * [KSTACKTOP-PTSIZE, KSTACKTOP-KSTKSIZE) -- not backed; so if
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir, KSTACKTOP-KSTKSIZE, KSTKSIZE, PADDR(bootstack), PTE_W);
f01026e8:	83 ec 08             	sub    $0x8,%esp
f01026eb:	6a 02                	push   $0x2
f01026ed:	68 00 60 11 00       	push   $0x116000
f01026f2:	b9 00 80 00 00       	mov    $0x8000,%ecx
f01026f7:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f01026fc:	a1 8c 5e 24 f0       	mov    0xf0245e8c,%eax
f0102701:	e8 fa e9 ff ff       	call   f0101100 <boot_map_region>
	//      the PA range [0, 2^32 - KERNBASE)
	// We might not have 2^32 - KERNBASE bytes of physical memory, but
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir, KERNBASE, 0xffffffff-KERNBASE, 0, PTE_W);
f0102706:	83 c4 08             	add    $0x8,%esp
f0102709:	6a 02                	push   $0x2
f010270b:	6a 00                	push   $0x0
f010270d:	b9 ff ff ff 0f       	mov    $0xfffffff,%ecx
f0102712:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0102717:	a1 8c 5e 24 f0       	mov    0xf0245e8c,%eax
f010271c:	e8 df e9 ff ff       	call   f0101100 <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102721:	83 c4 10             	add    $0x10,%esp
f0102724:	b8 00 70 24 f0       	mov    $0xf0247000,%eax
f0102729:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010272e:	0f 87 63 06 00 00    	ja     f0102d97 <mem_init+0x1a62>
f0102734:	eb 0c                	jmp    f0102742 <mem_init+0x140d>
	// LAB 4: Your code here:
	uintptr_t kstacktop_i;
	for (int i = 0;i < NCPU;i++)
	{
		kstacktop_i = KSTACKTOP - i * (KSTKSIZE + KSTKGAP);
		boot_map_region(kern_pgdir,kstacktop_i - KSTKSIZE,KSTKSIZE,PADDR(percpu_kstacks[i]),PTE_P | PTE_W);
f0102736:	89 d8                	mov    %ebx,%eax
f0102738:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f010273e:	77 1c                	ja     f010275c <mem_init+0x1427>
f0102740:	eb 05                	jmp    f0102747 <mem_init+0x1412>
f0102742:	b8 00 70 24 f0       	mov    $0xf0247000,%eax
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102747:	50                   	push   %eax
f0102748:	68 e8 64 10 f0       	push   $0xf01064e8
f010274d:	68 13 01 00 00       	push   $0x113
f0102752:	68 34 6a 10 f0       	push   $0xf0106a34
f0102757:	e8 e4 d8 ff ff       	call   f0100040 <_panic>
f010275c:	83 ec 08             	sub    $0x8,%esp
f010275f:	6a 03                	push   $0x3
f0102761:	8d 83 00 00 00 10    	lea    0x10000000(%ebx),%eax
f0102767:	50                   	push   %eax
f0102768:	b9 00 80 00 00       	mov    $0x8000,%ecx
f010276d:	89 f2                	mov    %esi,%edx
f010276f:	a1 8c 5e 24 f0       	mov    0xf0245e8c,%eax
f0102774:	e8 87 e9 ff ff       	call   f0101100 <boot_map_region>
f0102779:	81 c3 00 80 00 00    	add    $0x8000,%ebx
f010277f:	81 ee 00 00 01 00    	sub    $0x10000,%esi
	//             Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	//
	// LAB 4: Your code here:
	uintptr_t kstacktop_i;
	for (int i = 0;i < NCPU;i++)
f0102785:	83 c4 10             	add    $0x10,%esp
f0102788:	81 fb 00 70 28 f0    	cmp    $0xf0287000,%ebx
f010278e:	75 a6                	jne    f0102736 <mem_init+0x1401>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f0102790:	8b 3d 8c 5e 24 f0    	mov    0xf0245e8c,%edi

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0102796:	a1 88 5e 24 f0       	mov    0xf0245e88,%eax
f010279b:	89 45 cc             	mov    %eax,-0x34(%ebp)
f010279e:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
	for (i = 0; i < n; i += PGSIZE)
f01027a5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01027aa:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01027ad:	75 10                	jne    f01027bf <mem_init+0x148a>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f01027af:	8b 35 48 52 24 f0    	mov    0xf0245248,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01027b5:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f01027b8:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
f01027bd:	eb 6a                	jmp    f0102829 <mem_init+0x14f4>
	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01027bf:	8b 35 90 5e 24 f0    	mov    0xf0245e90,%esi
f01027c5:	89 75 d0             	mov    %esi,-0x30(%ebp)
f01027c8:	bb 00 00 00 00       	mov    $0x0,%ebx
f01027cd:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
f01027d3:	89 f8                	mov    %edi,%eax
f01027d5:	e8 5b e3 ff ff       	call   f0100b35 <check_va2pa>
f01027da:	81 7d d0 ff ff ff ef 	cmpl   $0xefffffff,-0x30(%ebp)
f01027e1:	77 15                	ja     f01027f8 <mem_init+0x14c3>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01027e3:	56                   	push   %esi
f01027e4:	68 e8 64 10 f0       	push   $0xf01064e8
f01027e9:	68 5c 03 00 00       	push   $0x35c
f01027ee:	68 34 6a 10 f0       	push   $0xf0106a34
f01027f3:	e8 48 d8 ff ff       	call   f0100040 <_panic>
f01027f8:	8d 94 1e 00 00 00 10 	lea    0x10000000(%esi,%ebx,1),%edx
f01027ff:	39 c2                	cmp    %eax,%edx
f0102801:	74 19                	je     f010281c <mem_init+0x14e7>
f0102803:	68 80 74 10 f0       	push   $0xf0107480
f0102808:	68 5a 6a 10 f0       	push   $0xf0106a5a
f010280d:	68 5c 03 00 00       	push   $0x35c
f0102812:	68 34 6a 10 f0       	push   $0xf0106a34
f0102817:	e8 24 d8 ff ff       	call   f0100040 <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f010281c:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102822:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0102825:	77 a6                	ja     f01027cd <mem_init+0x1498>
f0102827:	eb 86                	jmp    f01027af <mem_init+0x147a>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102829:	89 da                	mov    %ebx,%edx
f010282b:	89 f8                	mov    %edi,%eax
f010282d:	e8 03 e3 ff ff       	call   f0100b35 <check_va2pa>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102832:	81 7d d4 ff ff ff ef 	cmpl   $0xefffffff,-0x2c(%ebp)
f0102839:	77 15                	ja     f0102850 <mem_init+0x151b>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010283b:	56                   	push   %esi
f010283c:	68 e8 64 10 f0       	push   $0xf01064e8
f0102841:	68 61 03 00 00       	push   $0x361
f0102846:	68 34 6a 10 f0       	push   $0xf0106a34
f010284b:	e8 f0 d7 ff ff       	call   f0100040 <_panic>
f0102850:	8d 94 1e 00 00 40 21 	lea    0x21400000(%esi,%ebx,1),%edx
f0102857:	39 d0                	cmp    %edx,%eax
f0102859:	74 19                	je     f0102874 <mem_init+0x153f>
f010285b:	68 b4 74 10 f0       	push   $0xf01074b4
f0102860:	68 5a 6a 10 f0       	push   $0xf0106a5a
f0102865:	68 61 03 00 00       	push   $0x361
f010286a:	68 34 6a 10 f0       	push   $0xf0106a34
f010286f:	e8 cc d7 ff ff       	call   f0100040 <_panic>
f0102874:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f010287a:	81 fb 00 f0 c1 ee    	cmp    $0xeec1f000,%ebx
f0102880:	75 a7                	jne    f0102829 <mem_init+0x14f4>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102882:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102887:	8b 75 cc             	mov    -0x34(%ebp),%esi
f010288a:	c1 e6 0c             	shl    $0xc,%esi
f010288d:	75 11                	jne    f01028a0 <mem_init+0x156b>
f010288f:	be 00 70 24 f0       	mov    $0xf0247000,%esi
f0102894:	c7 45 cc 00 80 ff ef 	movl   $0xefff8000,-0x34(%ebp)
f010289b:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f010289e:	eb 36                	jmp    f01028d6 <mem_init+0x15a1>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f01028a0:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
f01028a6:	89 f8                	mov    %edi,%eax
f01028a8:	e8 88 e2 ff ff       	call   f0100b35 <check_va2pa>
f01028ad:	39 d8                	cmp    %ebx,%eax
f01028af:	74 19                	je     f01028ca <mem_init+0x1595>
f01028b1:	68 e8 74 10 f0       	push   $0xf01074e8
f01028b6:	68 5a 6a 10 f0       	push   $0xf0106a5a
f01028bb:	68 65 03 00 00       	push   $0x365
f01028c0:	68 34 6a 10 f0       	push   $0xf0106a34
f01028c5:	e8 76 d7 ff ff       	call   f0100040 <_panic>
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01028ca:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01028d0:	39 f3                	cmp    %esi,%ebx
f01028d2:	72 cc                	jb     f01028a0 <mem_init+0x156b>
f01028d4:	eb b9                	jmp    f010288f <mem_init+0x155a>
f01028d6:	8b 45 cc             	mov    -0x34(%ebp),%eax
f01028d9:	8d 88 00 80 00 00    	lea    0x8000(%eax),%ecx
f01028df:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f01028e2:	89 c3                	mov    %eax,%ebx
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f01028e4:	8b 45 c8             	mov    -0x38(%ebp),%eax
f01028e7:	8d b8 00 80 00 20    	lea    0x20008000(%eax),%edi
f01028ed:	89 da                	mov    %ebx,%edx
f01028ef:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01028f2:	e8 3e e2 ff ff       	call   f0100b35 <check_va2pa>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01028f7:	81 fe ff ff ff ef    	cmp    $0xefffffff,%esi
f01028fd:	77 15                	ja     f0102914 <mem_init+0x15df>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01028ff:	56                   	push   %esi
f0102900:	68 e8 64 10 f0       	push   $0xf01064e8
f0102905:	68 6d 03 00 00       	push   $0x36d
f010290a:	68 34 6a 10 f0       	push   $0xf0106a34
f010290f:	e8 2c d7 ff ff       	call   f0100040 <_panic>
f0102914:	8d 94 3b 00 70 24 f0 	lea    -0xfdb9000(%ebx,%edi,1),%edx
f010291b:	39 c2                	cmp    %eax,%edx
f010291d:	74 19                	je     f0102938 <mem_init+0x1603>
f010291f:	68 10 75 10 f0       	push   $0xf0107510
f0102924:	68 5a 6a 10 f0       	push   $0xf0106a5a
f0102929:	68 6d 03 00 00       	push   $0x36d
f010292e:	68 34 6a 10 f0       	push   $0xf0106a34
f0102933:	e8 08 d7 ff ff       	call   f0100040 <_panic>
f0102938:	81 c3 00 10 00 00    	add    $0x1000,%ebx

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f010293e:	3b 5d d0             	cmp    -0x30(%ebp),%ebx
f0102941:	75 aa                	jne    f01028ed <mem_init+0x15b8>
f0102943:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0102946:	8d 98 00 80 ff ff    	lea    -0x8000(%eax),%ebx
f010294c:	89 75 d0             	mov    %esi,-0x30(%ebp)
f010294f:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0102952:	89 c7                	mov    %eax,%edi
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
f0102954:	89 da                	mov    %ebx,%edx
f0102956:	89 f0                	mov    %esi,%eax
f0102958:	e8 d8 e1 ff ff       	call   f0100b35 <check_va2pa>
f010295d:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102960:	74 19                	je     f010297b <mem_init+0x1646>
f0102962:	68 58 75 10 f0       	push   $0xf0107558
f0102967:	68 5a 6a 10 f0       	push   $0xf0106a5a
f010296c:	68 6f 03 00 00       	push   $0x36f
f0102971:	68 34 6a 10 f0       	push   $0xf0106a34
f0102976:	e8 c5 d6 ff ff       	call   f0100040 <_panic>
f010297b:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
f0102981:	39 fb                	cmp    %edi,%ebx
f0102983:	75 cf                	jne    f0102954 <mem_init+0x161f>
f0102985:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0102988:	81 6d cc 00 00 01 00 	subl   $0x10000,-0x34(%ebp)
f010298f:	81 45 c8 00 80 01 00 	addl   $0x18000,-0x38(%ebp)
f0102996:	81 c6 00 80 00 00    	add    $0x8000,%esi
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
f010299c:	81 fe 00 70 28 f0    	cmp    $0xf0287000,%esi
f01029a2:	0f 85 2e ff ff ff    	jne    f01028d6 <mem_init+0x15a1>
f01029a8:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f01029ab:	b8 00 00 00 00       	mov    $0x0,%eax
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f01029b0:	8d 90 45 fc ff ff    	lea    -0x3bb(%eax),%edx
f01029b6:	83 fa 04             	cmp    $0x4,%edx
f01029b9:	77 1f                	ja     f01029da <mem_init+0x16a5>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
		case PDX(MMIOBASE):
			assert(pgdir[i] & PTE_P);
f01029bb:	f6 04 87 01          	testb  $0x1,(%edi,%eax,4)
f01029bf:	75 7e                	jne    f0102a3f <mem_init+0x170a>
f01029c1:	68 43 6d 10 f0       	push   $0xf0106d43
f01029c6:	68 5a 6a 10 f0       	push   $0xf0106a5a
f01029cb:	68 7a 03 00 00       	push   $0x37a
f01029d0:	68 34 6a 10 f0       	push   $0xf0106a34
f01029d5:	e8 66 d6 ff ff       	call   f0100040 <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f01029da:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f01029df:	76 3f                	jbe    f0102a20 <mem_init+0x16eb>
				assert(pgdir[i] & PTE_P);
f01029e1:	8b 14 87             	mov    (%edi,%eax,4),%edx
f01029e4:	f6 c2 01             	test   $0x1,%dl
f01029e7:	75 19                	jne    f0102a02 <mem_init+0x16cd>
f01029e9:	68 43 6d 10 f0       	push   $0xf0106d43
f01029ee:	68 5a 6a 10 f0       	push   $0xf0106a5a
f01029f3:	68 7e 03 00 00       	push   $0x37e
f01029f8:	68 34 6a 10 f0       	push   $0xf0106a34
f01029fd:	e8 3e d6 ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] & PTE_W);
f0102a02:	f6 c2 02             	test   $0x2,%dl
f0102a05:	75 38                	jne    f0102a3f <mem_init+0x170a>
f0102a07:	68 54 6d 10 f0       	push   $0xf0106d54
f0102a0c:	68 5a 6a 10 f0       	push   $0xf0106a5a
f0102a11:	68 7f 03 00 00       	push   $0x37f
f0102a16:	68 34 6a 10 f0       	push   $0xf0106a34
f0102a1b:	e8 20 d6 ff ff       	call   f0100040 <_panic>
			} else
				assert(pgdir[i] == 0);
f0102a20:	83 3c 87 00          	cmpl   $0x0,(%edi,%eax,4)
f0102a24:	74 19                	je     f0102a3f <mem_init+0x170a>
f0102a26:	68 65 6d 10 f0       	push   $0xf0106d65
f0102a2b:	68 5a 6a 10 f0       	push   $0xf0106a5a
f0102a30:	68 81 03 00 00       	push   $0x381
f0102a35:	68 34 6a 10 f0       	push   $0xf0106a34
f0102a3a:	e8 01 d6 ff ff       	call   f0100040 <_panic>
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f0102a3f:	40                   	inc    %eax
f0102a40:	3d 00 04 00 00       	cmp    $0x400,%eax
f0102a45:	0f 85 65 ff ff ff    	jne    f01029b0 <mem_init+0x167b>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f0102a4b:	83 ec 0c             	sub    $0xc,%esp
f0102a4e:	68 7c 75 10 f0       	push   $0xf010757c
f0102a53:	e8 b8 0d 00 00       	call   f0103810 <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f0102a58:	a1 8c 5e 24 f0       	mov    0xf0245e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102a5d:	83 c4 10             	add    $0x10,%esp
f0102a60:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102a65:	77 15                	ja     f0102a7c <mem_init+0x1747>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102a67:	50                   	push   %eax
f0102a68:	68 e8 64 10 f0       	push   $0xf01064e8
f0102a6d:	68 ea 00 00 00       	push   $0xea
f0102a72:	68 34 6a 10 f0       	push   $0xf0106a34
f0102a77:	e8 c4 d5 ff ff       	call   f0100040 <_panic>
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0102a7c:	05 00 00 00 10       	add    $0x10000000,%eax
f0102a81:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f0102a84:	b8 00 00 00 00       	mov    $0x0,%eax
f0102a89:	e8 06 e1 ff ff       	call   f0100b94 <check_page_free_list>

static __inline uint32_t
rcr0(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f0102a8e:	0f 20 c0             	mov    %cr0,%eax
f0102a91:	83 e0 f3             	and    $0xfffffff3,%eax
}

static __inline void
lcr0(uint32_t val)
{
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f0102a94:	0d 23 00 05 80       	or     $0x80050023,%eax
f0102a99:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102a9c:	83 ec 0c             	sub    $0xc,%esp
f0102a9f:	6a 00                	push   $0x0
f0102aa1:	e8 d2 e4 ff ff       	call   f0100f78 <page_alloc>
f0102aa6:	89 c3                	mov    %eax,%ebx
f0102aa8:	83 c4 10             	add    $0x10,%esp
f0102aab:	85 c0                	test   %eax,%eax
f0102aad:	75 19                	jne    f0102ac8 <mem_init+0x1793>
f0102aaf:	68 4f 6b 10 f0       	push   $0xf0106b4f
f0102ab4:	68 5a 6a 10 f0       	push   $0xf0106a5a
f0102ab9:	68 59 04 00 00       	push   $0x459
f0102abe:	68 34 6a 10 f0       	push   $0xf0106a34
f0102ac3:	e8 78 d5 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0102ac8:	83 ec 0c             	sub    $0xc,%esp
f0102acb:	6a 00                	push   $0x0
f0102acd:	e8 a6 e4 ff ff       	call   f0100f78 <page_alloc>
f0102ad2:	89 c7                	mov    %eax,%edi
f0102ad4:	83 c4 10             	add    $0x10,%esp
f0102ad7:	85 c0                	test   %eax,%eax
f0102ad9:	75 19                	jne    f0102af4 <mem_init+0x17bf>
f0102adb:	68 65 6b 10 f0       	push   $0xf0106b65
f0102ae0:	68 5a 6a 10 f0       	push   $0xf0106a5a
f0102ae5:	68 5a 04 00 00       	push   $0x45a
f0102aea:	68 34 6a 10 f0       	push   $0xf0106a34
f0102aef:	e8 4c d5 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0102af4:	83 ec 0c             	sub    $0xc,%esp
f0102af7:	6a 00                	push   $0x0
f0102af9:	e8 7a e4 ff ff       	call   f0100f78 <page_alloc>
f0102afe:	89 c6                	mov    %eax,%esi
f0102b00:	83 c4 10             	add    $0x10,%esp
f0102b03:	85 c0                	test   %eax,%eax
f0102b05:	75 19                	jne    f0102b20 <mem_init+0x17eb>
f0102b07:	68 7b 6b 10 f0       	push   $0xf0106b7b
f0102b0c:	68 5a 6a 10 f0       	push   $0xf0106a5a
f0102b11:	68 5b 04 00 00       	push   $0x45b
f0102b16:	68 34 6a 10 f0       	push   $0xf0106a34
f0102b1b:	e8 20 d5 ff ff       	call   f0100040 <_panic>
	page_free(pp0);
f0102b20:	83 ec 0c             	sub    $0xc,%esp
f0102b23:	53                   	push   %ebx
f0102b24:	e8 ca e4 ff ff       	call   f0100ff3 <page_free>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102b29:	89 f8                	mov    %edi,%eax
f0102b2b:	2b 05 90 5e 24 f0    	sub    0xf0245e90,%eax
f0102b31:	c1 f8 03             	sar    $0x3,%eax
f0102b34:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102b37:	89 c2                	mov    %eax,%edx
f0102b39:	c1 ea 0c             	shr    $0xc,%edx
f0102b3c:	83 c4 10             	add    $0x10,%esp
f0102b3f:	3b 15 88 5e 24 f0    	cmp    0xf0245e88,%edx
f0102b45:	72 12                	jb     f0102b59 <mem_init+0x1824>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102b47:	50                   	push   %eax
f0102b48:	68 c4 64 10 f0       	push   $0xf01064c4
f0102b4d:	6a 58                	push   $0x58
f0102b4f:	68 40 6a 10 f0       	push   $0xf0106a40
f0102b54:	e8 e7 d4 ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f0102b59:	83 ec 04             	sub    $0x4,%esp
f0102b5c:	68 00 10 00 00       	push   $0x1000
f0102b61:	6a 01                	push   $0x1
f0102b63:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102b68:	50                   	push   %eax
f0102b69:	e8 f7 2b 00 00       	call   f0105765 <memset>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102b6e:	89 f0                	mov    %esi,%eax
f0102b70:	2b 05 90 5e 24 f0    	sub    0xf0245e90,%eax
f0102b76:	c1 f8 03             	sar    $0x3,%eax
f0102b79:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102b7c:	89 c2                	mov    %eax,%edx
f0102b7e:	c1 ea 0c             	shr    $0xc,%edx
f0102b81:	83 c4 10             	add    $0x10,%esp
f0102b84:	3b 15 88 5e 24 f0    	cmp    0xf0245e88,%edx
f0102b8a:	72 12                	jb     f0102b9e <mem_init+0x1869>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102b8c:	50                   	push   %eax
f0102b8d:	68 c4 64 10 f0       	push   $0xf01064c4
f0102b92:	6a 58                	push   $0x58
f0102b94:	68 40 6a 10 f0       	push   $0xf0106a40
f0102b99:	e8 a2 d4 ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f0102b9e:	83 ec 04             	sub    $0x4,%esp
f0102ba1:	68 00 10 00 00       	push   $0x1000
f0102ba6:	6a 02                	push   $0x2
f0102ba8:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102bad:	50                   	push   %eax
f0102bae:	e8 b2 2b 00 00       	call   f0105765 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102bb3:	6a 02                	push   $0x2
f0102bb5:	68 00 10 00 00       	push   $0x1000
f0102bba:	57                   	push   %edi
f0102bbb:	ff 35 8c 5e 24 f0    	pushl  0xf0245e8c
f0102bc1:	e8 91 e6 ff ff       	call   f0101257 <page_insert>
	assert(pp1->pp_ref == 1);
f0102bc6:	83 c4 20             	add    $0x20,%esp
f0102bc9:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102bce:	74 19                	je     f0102be9 <mem_init+0x18b4>
f0102bd0:	68 4c 6c 10 f0       	push   $0xf0106c4c
f0102bd5:	68 5a 6a 10 f0       	push   $0xf0106a5a
f0102bda:	68 60 04 00 00       	push   $0x460
f0102bdf:	68 34 6a 10 f0       	push   $0xf0106a34
f0102be4:	e8 57 d4 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102be9:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102bf0:	01 01 01 
f0102bf3:	74 19                	je     f0102c0e <mem_init+0x18d9>
f0102bf5:	68 9c 75 10 f0       	push   $0xf010759c
f0102bfa:	68 5a 6a 10 f0       	push   $0xf0106a5a
f0102bff:	68 61 04 00 00       	push   $0x461
f0102c04:	68 34 6a 10 f0       	push   $0xf0106a34
f0102c09:	e8 32 d4 ff ff       	call   f0100040 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102c0e:	6a 02                	push   $0x2
f0102c10:	68 00 10 00 00       	push   $0x1000
f0102c15:	56                   	push   %esi
f0102c16:	ff 35 8c 5e 24 f0    	pushl  0xf0245e8c
f0102c1c:	e8 36 e6 ff ff       	call   f0101257 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102c21:	83 c4 10             	add    $0x10,%esp
f0102c24:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102c2b:	02 02 02 
f0102c2e:	74 19                	je     f0102c49 <mem_init+0x1914>
f0102c30:	68 c0 75 10 f0       	push   $0xf01075c0
f0102c35:	68 5a 6a 10 f0       	push   $0xf0106a5a
f0102c3a:	68 63 04 00 00       	push   $0x463
f0102c3f:	68 34 6a 10 f0       	push   $0xf0106a34
f0102c44:	e8 f7 d3 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0102c49:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102c4e:	74 19                	je     f0102c69 <mem_init+0x1934>
f0102c50:	68 6e 6c 10 f0       	push   $0xf0106c6e
f0102c55:	68 5a 6a 10 f0       	push   $0xf0106a5a
f0102c5a:	68 64 04 00 00       	push   $0x464
f0102c5f:	68 34 6a 10 f0       	push   $0xf0106a34
f0102c64:	e8 d7 d3 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f0102c69:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102c6e:	74 19                	je     f0102c89 <mem_init+0x1954>
f0102c70:	68 d8 6c 10 f0       	push   $0xf0106cd8
f0102c75:	68 5a 6a 10 f0       	push   $0xf0106a5a
f0102c7a:	68 65 04 00 00       	push   $0x465
f0102c7f:	68 34 6a 10 f0       	push   $0xf0106a34
f0102c84:	e8 b7 d3 ff ff       	call   f0100040 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102c89:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102c90:	03 03 03 
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102c93:	89 f0                	mov    %esi,%eax
f0102c95:	2b 05 90 5e 24 f0    	sub    0xf0245e90,%eax
f0102c9b:	c1 f8 03             	sar    $0x3,%eax
f0102c9e:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102ca1:	89 c2                	mov    %eax,%edx
f0102ca3:	c1 ea 0c             	shr    $0xc,%edx
f0102ca6:	3b 15 88 5e 24 f0    	cmp    0xf0245e88,%edx
f0102cac:	72 12                	jb     f0102cc0 <mem_init+0x198b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102cae:	50                   	push   %eax
f0102caf:	68 c4 64 10 f0       	push   $0xf01064c4
f0102cb4:	6a 58                	push   $0x58
f0102cb6:	68 40 6a 10 f0       	push   $0xf0106a40
f0102cbb:	e8 80 d3 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102cc0:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0102cc7:	03 03 03 
f0102cca:	74 19                	je     f0102ce5 <mem_init+0x19b0>
f0102ccc:	68 e4 75 10 f0       	push   $0xf01075e4
f0102cd1:	68 5a 6a 10 f0       	push   $0xf0106a5a
f0102cd6:	68 67 04 00 00       	push   $0x467
f0102cdb:	68 34 6a 10 f0       	push   $0xf0106a34
f0102ce0:	e8 5b d3 ff ff       	call   f0100040 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102ce5:	83 ec 08             	sub    $0x8,%esp
f0102ce8:	68 00 10 00 00       	push   $0x1000
f0102ced:	ff 35 8c 5e 24 f0    	pushl  0xf0245e8c
f0102cf3:	e8 12 e5 ff ff       	call   f010120a <page_remove>
	assert(pp2->pp_ref == 0);
f0102cf8:	83 c4 10             	add    $0x10,%esp
f0102cfb:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102d00:	74 19                	je     f0102d1b <mem_init+0x19e6>
f0102d02:	68 a6 6c 10 f0       	push   $0xf0106ca6
f0102d07:	68 5a 6a 10 f0       	push   $0xf0106a5a
f0102d0c:	68 69 04 00 00       	push   $0x469
f0102d11:	68 34 6a 10 f0       	push   $0xf0106a34
f0102d16:	e8 25 d3 ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102d1b:	8b 0d 8c 5e 24 f0    	mov    0xf0245e8c,%ecx
f0102d21:	8b 11                	mov    (%ecx),%edx
f0102d23:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102d29:	89 d8                	mov    %ebx,%eax
f0102d2b:	2b 05 90 5e 24 f0    	sub    0xf0245e90,%eax
f0102d31:	c1 f8 03             	sar    $0x3,%eax
f0102d34:	c1 e0 0c             	shl    $0xc,%eax
f0102d37:	39 c2                	cmp    %eax,%edx
f0102d39:	74 19                	je     f0102d54 <mem_init+0x1a1f>
f0102d3b:	68 6c 6f 10 f0       	push   $0xf0106f6c
f0102d40:	68 5a 6a 10 f0       	push   $0xf0106a5a
f0102d45:	68 6c 04 00 00       	push   $0x46c
f0102d4a:	68 34 6a 10 f0       	push   $0xf0106a34
f0102d4f:	e8 ec d2 ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f0102d54:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102d5a:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102d5f:	74 19                	je     f0102d7a <mem_init+0x1a45>
f0102d61:	68 5d 6c 10 f0       	push   $0xf0106c5d
f0102d66:	68 5a 6a 10 f0       	push   $0xf0106a5a
f0102d6b:	68 6e 04 00 00       	push   $0x46e
f0102d70:	68 34 6a 10 f0       	push   $0xf0106a34
f0102d75:	e8 c6 d2 ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f0102d7a:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f0102d80:	83 ec 0c             	sub    $0xc,%esp
f0102d83:	53                   	push   %ebx
f0102d84:	e8 6a e2 ff ff       	call   f0100ff3 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102d89:	c7 04 24 10 76 10 f0 	movl   $0xf0107610,(%esp)
f0102d90:	e8 7b 0a 00 00       	call   f0103810 <cprintf>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f0102d95:	eb 30                	jmp    f0102dc7 <mem_init+0x1a92>
	// LAB 4: Your code here:
	uintptr_t kstacktop_i;
	for (int i = 0;i < NCPU;i++)
	{
		kstacktop_i = KSTACKTOP - i * (KSTKSIZE + KSTKGAP);
		boot_map_region(kern_pgdir,kstacktop_i - KSTKSIZE,KSTKSIZE,PADDR(percpu_kstacks[i]),PTE_P | PTE_W);
f0102d97:	83 ec 08             	sub    $0x8,%esp
f0102d9a:	6a 03                	push   $0x3
f0102d9c:	68 00 70 24 00       	push   $0x247000
f0102da1:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102da6:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0102dab:	a1 8c 5e 24 f0       	mov    0xf0245e8c,%eax
f0102db0:	e8 4b e3 ff ff       	call   f0101100 <boot_map_region>
f0102db5:	bb 00 f0 24 f0       	mov    $0xf024f000,%ebx
f0102dba:	83 c4 10             	add    $0x10,%esp
f0102dbd:	be 00 80 fe ef       	mov    $0xeffe8000,%esi
f0102dc2:	e9 6f f9 ff ff       	jmp    f0102736 <mem_init+0x1401>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f0102dc7:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102dca:	5b                   	pop    %ebx
f0102dcb:	5e                   	pop    %esi
f0102dcc:	5f                   	pop    %edi
f0102dcd:	5d                   	pop    %ebp
f0102dce:	c3                   	ret    

f0102dcf <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f0102dcf:	55                   	push   %ebp
f0102dd0:	89 e5                	mov    %esp,%ebp
f0102dd2:	57                   	push   %edi
f0102dd3:	56                   	push   %esi
f0102dd4:	53                   	push   %ebx
f0102dd5:	83 ec 1c             	sub    $0x1c,%esp
f0102dd8:	8b 7d 08             	mov    0x8(%ebp),%edi
f0102ddb:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 3: Your code here.
	char * end = NULL;
	char * start = NULL;
	start = ROUNDDOWN((char *)va, PGSIZE); 
f0102dde:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102de1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102de6:	89 c2                	mov    %eax,%edx
f0102de8:	89 45 e0             	mov    %eax,-0x20(%ebp)
	end = ROUNDUP((char *)(va + len), PGSIZE);
f0102deb:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102dee:	03 45 10             	add    0x10(%ebp),%eax
f0102df1:	05 ff 0f 00 00       	add    $0xfff,%eax
f0102df6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102dfb:	89 c1                	mov    %eax,%ecx
f0102dfd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	pte_t *cur = NULL;

	for(; start < end; start += PGSIZE) {
f0102e00:	89 d0                	mov    %edx,%eax
f0102e02:	39 c8                	cmp    %ecx,%eax
f0102e04:	73 5c                	jae    f0102e62 <user_mem_check+0x93>
f0102e06:	89 c3                	mov    %eax,%ebx
		cur = pgdir_walk(env->env_pgdir, (void *)start, 0);
f0102e08:	83 ec 04             	sub    $0x4,%esp
f0102e0b:	6a 00                	push   $0x0
f0102e0d:	53                   	push   %ebx
f0102e0e:	ff 77 60             	pushl  0x60(%edi)
f0102e11:	e8 57 e2 ff ff       	call   f010106d <pgdir_walk>
		if((int)start > ULIM || cur == NULL || ((uint32_t)(*cur) & perm) != perm) {
f0102e16:	89 da                	mov    %ebx,%edx
f0102e18:	83 c4 10             	add    $0x10,%esp
f0102e1b:	81 fb 00 00 80 ef    	cmp    $0xef800000,%ebx
f0102e21:	77 0c                	ja     f0102e2f <user_mem_check+0x60>
f0102e23:	85 c0                	test   %eax,%eax
f0102e25:	74 08                	je     f0102e2f <user_mem_check+0x60>
f0102e27:	89 f1                	mov    %esi,%ecx
f0102e29:	23 08                	and    (%eax),%ecx
f0102e2b:	39 ce                	cmp    %ecx,%esi
f0102e2d:	74 21                	je     f0102e50 <user_mem_check+0x81>
			  if(start == ROUNDDOWN((char *)va, PGSIZE)) {
f0102e2f:	39 5d e0             	cmp    %ebx,-0x20(%ebp)
f0102e32:	75 0f                	jne    f0102e43 <user_mem_check+0x74>
					user_mem_check_addr = (uintptr_t)va;
f0102e34:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102e37:	a3 3c 52 24 f0       	mov    %eax,0xf024523c
			  }
			  else {
			  		user_mem_check_addr = (uintptr_t)start;
			  }
			  return -E_FAULT;
f0102e3c:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0102e41:	eb 24                	jmp    f0102e67 <user_mem_check+0x98>
		if((int)start > ULIM || cur == NULL || ((uint32_t)(*cur) & perm) != perm) {
			  if(start == ROUNDDOWN((char *)va, PGSIZE)) {
					user_mem_check_addr = (uintptr_t)va;
			  }
			  else {
			  		user_mem_check_addr = (uintptr_t)start;
f0102e43:	89 15 3c 52 24 f0    	mov    %edx,0xf024523c
			  }
			  return -E_FAULT;
f0102e49:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0102e4e:	eb 17                	jmp    f0102e67 <user_mem_check+0x98>
	char * start = NULL;
	start = ROUNDDOWN((char *)va, PGSIZE); 
	end = ROUNDUP((char *)(va + len), PGSIZE);
	pte_t *cur = NULL;

	for(; start < end; start += PGSIZE) {
f0102e50:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102e56:	39 5d e4             	cmp    %ebx,-0x1c(%ebp)
f0102e59:	77 ad                	ja     f0102e08 <user_mem_check+0x39>
			  return -E_FAULT;
		}
		
	}
		
	return 0;
f0102e5b:	b8 00 00 00 00       	mov    $0x0,%eax
f0102e60:	eb 05                	jmp    f0102e67 <user_mem_check+0x98>
f0102e62:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102e67:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102e6a:	5b                   	pop    %ebx
f0102e6b:	5e                   	pop    %esi
f0102e6c:	5f                   	pop    %edi
f0102e6d:	5d                   	pop    %ebp
f0102e6e:	c3                   	ret    

f0102e6f <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f0102e6f:	55                   	push   %ebp
f0102e70:	89 e5                	mov    %esp,%ebp
f0102e72:	53                   	push   %ebx
f0102e73:	83 ec 04             	sub    $0x4,%esp
f0102e76:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f0102e79:	8b 45 14             	mov    0x14(%ebp),%eax
f0102e7c:	83 c8 04             	or     $0x4,%eax
f0102e7f:	50                   	push   %eax
f0102e80:	ff 75 10             	pushl  0x10(%ebp)
f0102e83:	ff 75 0c             	pushl  0xc(%ebp)
f0102e86:	53                   	push   %ebx
f0102e87:	e8 43 ff ff ff       	call   f0102dcf <user_mem_check>
f0102e8c:	83 c4 10             	add    $0x10,%esp
f0102e8f:	85 c0                	test   %eax,%eax
f0102e91:	79 21                	jns    f0102eb4 <user_mem_assert+0x45>
		cprintf("[%08x] user_mem_check assertion failure for "
f0102e93:	83 ec 04             	sub    $0x4,%esp
f0102e96:	ff 35 3c 52 24 f0    	pushl  0xf024523c
f0102e9c:	ff 73 48             	pushl  0x48(%ebx)
f0102e9f:	68 3c 76 10 f0       	push   $0xf010763c
f0102ea4:	e8 67 09 00 00       	call   f0103810 <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f0102ea9:	89 1c 24             	mov    %ebx,(%esp)
f0102eac:	e8 3c 06 00 00       	call   f01034ed <env_destroy>
f0102eb1:	83 c4 10             	add    $0x10,%esp
	}
}
f0102eb4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0102eb7:	c9                   	leave  
f0102eb8:	c3                   	ret    

f0102eb9 <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f0102eb9:	55                   	push   %ebp
f0102eba:	89 e5                	mov    %esp,%ebp
f0102ebc:	57                   	push   %edi
f0102ebd:	56                   	push   %esi
f0102ebe:	53                   	push   %ebx
f0102ebf:	83 ec 0c             	sub    $0xc,%esp
f0102ec2:	89 c7                	mov    %eax,%edi
	// LAB 3: Your code here.
	// (But only if you need it for load_icode.)
	void* start = (void *)ROUNDDOWN((uint32_t)va, PGSIZE);
f0102ec4:	89 d3                	mov    %edx,%ebx
f0102ec6:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	void* end = (void *)ROUNDUP((uint32_t)va+len, PGSIZE);
f0102ecc:	8d b4 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%esi
f0102ed3:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	struct PageInfo *p = NULL;
	void* i;
	int r;
	for(i=start; i<end; i+=PGSIZE){
f0102ed9:	39 f3                	cmp    %esi,%ebx
f0102edb:	73 5c                	jae    f0102f39 <region_alloc+0x80>
		p = page_alloc(0);
f0102edd:	83 ec 0c             	sub    $0xc,%esp
f0102ee0:	6a 00                	push   $0x0
f0102ee2:	e8 91 e0 ff ff       	call   f0100f78 <page_alloc>
		if(p == NULL)
f0102ee7:	83 c4 10             	add    $0x10,%esp
f0102eea:	85 c0                	test   %eax,%eax
f0102eec:	75 17                	jne    f0102f05 <region_alloc+0x4c>
			panic(" region alloc, allocation failed.");
f0102eee:	83 ec 04             	sub    $0x4,%esp
f0102ef1:	68 74 76 10 f0       	push   $0xf0107674
f0102ef6:	68 31 01 00 00       	push   $0x131
f0102efb:	68 28 77 10 f0       	push   $0xf0107728
f0102f00:	e8 3b d1 ff ff       	call   f0100040 <_panic>

		r = page_insert(e->env_pgdir, p, i, PTE_W | PTE_U);
f0102f05:	6a 06                	push   $0x6
f0102f07:	53                   	push   %ebx
f0102f08:	50                   	push   %eax
f0102f09:	ff 77 60             	pushl  0x60(%edi)
f0102f0c:	e8 46 e3 ff ff       	call   f0101257 <page_insert>
		if(r != 0) {
f0102f11:	83 c4 10             	add    $0x10,%esp
f0102f14:	85 c0                	test   %eax,%eax
f0102f16:	74 17                	je     f0102f2f <region_alloc+0x76>
			panic("region alloc error");
f0102f18:	83 ec 04             	sub    $0x4,%esp
f0102f1b:	68 33 77 10 f0       	push   $0xf0107733
f0102f20:	68 35 01 00 00       	push   $0x135
f0102f25:	68 28 77 10 f0       	push   $0xf0107728
f0102f2a:	e8 11 d1 ff ff       	call   f0100040 <_panic>
	void* start = (void *)ROUNDDOWN((uint32_t)va, PGSIZE);
	void* end = (void *)ROUNDUP((uint32_t)va+len, PGSIZE);
	struct PageInfo *p = NULL;
	void* i;
	int r;
	for(i=start; i<end; i+=PGSIZE){
f0102f2f:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102f35:	39 de                	cmp    %ebx,%esi
f0102f37:	77 a4                	ja     f0102edd <region_alloc+0x24>
	}
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
}
f0102f39:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102f3c:	5b                   	pop    %ebx
f0102f3d:	5e                   	pop    %esi
f0102f3e:	5f                   	pop    %edi
f0102f3f:	5d                   	pop    %ebp
f0102f40:	c3                   	ret    

f0102f41 <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f0102f41:	55                   	push   %ebp
f0102f42:	89 e5                	mov    %esp,%ebp
f0102f44:	56                   	push   %esi
f0102f45:	53                   	push   %ebx
f0102f46:	8b 45 08             	mov    0x8(%ebp),%eax
f0102f49:	8b 55 10             	mov    0x10(%ebp),%edx
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f0102f4c:	85 c0                	test   %eax,%eax
f0102f4e:	75 27                	jne    f0102f77 <envid2env+0x36>
		*env_store = curenv;
f0102f50:	e8 8a 2e 00 00       	call   f0105ddf <cpunum>
f0102f55:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0102f58:	01 c2                	add    %eax,%edx
f0102f5a:	01 d2                	add    %edx,%edx
f0102f5c:	01 c2                	add    %eax,%edx
f0102f5e:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0102f61:	8b 04 85 28 60 24 f0 	mov    -0xfdb9fd8(,%eax,4),%eax
f0102f68:	8b 75 0c             	mov    0xc(%ebp),%esi
f0102f6b:	89 06                	mov    %eax,(%esi)
		return 0;
f0102f6d:	b8 00 00 00 00       	mov    $0x0,%eax
f0102f72:	e9 8d 00 00 00       	jmp    f0103004 <envid2env+0xc3>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f0102f77:	89 c3                	mov    %eax,%ebx
f0102f79:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f0102f7f:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
f0102f86:	c1 e3 07             	shl    $0x7,%ebx
f0102f89:	29 cb                	sub    %ecx,%ebx
f0102f8b:	03 1d 48 52 24 f0    	add    0xf0245248,%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0102f91:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f0102f95:	74 05                	je     f0102f9c <envid2env+0x5b>
f0102f97:	3b 43 48             	cmp    0x48(%ebx),%eax
f0102f9a:	74 10                	je     f0102fac <envid2env+0x6b>
		*env_store = 0;
f0102f9c:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102f9f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0102fa5:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0102faa:	eb 58                	jmp    f0103004 <envid2env+0xc3>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0102fac:	84 d2                	test   %dl,%dl
f0102fae:	74 4a                	je     f0102ffa <envid2env+0xb9>
f0102fb0:	e8 2a 2e 00 00       	call   f0105ddf <cpunum>
f0102fb5:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0102fb8:	01 c2                	add    %eax,%edx
f0102fba:	01 d2                	add    %edx,%edx
f0102fbc:	01 c2                	add    %eax,%edx
f0102fbe:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0102fc1:	3b 1c 85 28 60 24 f0 	cmp    -0xfdb9fd8(,%eax,4),%ebx
f0102fc8:	74 30                	je     f0102ffa <envid2env+0xb9>
f0102fca:	8b 73 4c             	mov    0x4c(%ebx),%esi
f0102fcd:	e8 0d 2e 00 00       	call   f0105ddf <cpunum>
f0102fd2:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0102fd5:	01 c2                	add    %eax,%edx
f0102fd7:	01 d2                	add    %edx,%edx
f0102fd9:	01 c2                	add    %eax,%edx
f0102fdb:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0102fde:	8b 04 85 28 60 24 f0 	mov    -0xfdb9fd8(,%eax,4),%eax
f0102fe5:	3b 70 48             	cmp    0x48(%eax),%esi
f0102fe8:	74 10                	je     f0102ffa <envid2env+0xb9>
		*env_store = 0;
f0102fea:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102fed:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0102ff3:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0102ff8:	eb 0a                	jmp    f0103004 <envid2env+0xc3>
	}

	*env_store = e;
f0102ffa:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102ffd:	89 18                	mov    %ebx,(%eax)
	return 0;
f0102fff:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103004:	5b                   	pop    %ebx
f0103005:	5e                   	pop    %esi
f0103006:	5d                   	pop    %ebp
f0103007:	c3                   	ret    

f0103008 <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f0103008:	55                   	push   %ebp
f0103009:	89 e5                	mov    %esp,%ebp
}

static __inline void
lgdt(void *p)
{
	__asm __volatile("lgdt (%0)" : : "r" (p));
f010300b:	b8 20 03 12 f0       	mov    $0xf0120320,%eax
f0103010:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" :: "a" (GD_UD|3));
f0103013:	b8 23 00 00 00       	mov    $0x23,%eax
f0103018:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" :: "a" (GD_UD|3));
f010301a:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" :: "a" (GD_KD));
f010301c:	b8 10 00 00 00       	mov    $0x10,%eax
f0103021:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" :: "a" (GD_KD));
f0103023:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" :: "a" (GD_KD));
f0103025:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" :: "i" (GD_KT));
f0103027:	ea 2e 30 10 f0 08 00 	ljmp   $0x8,$0xf010302e
}

static __inline void
lldt(uint16_t sel)
{
	__asm __volatile("lldt %0" : : "r" (sel));
f010302e:	b8 00 00 00 00       	mov    $0x0,%eax
f0103033:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f0103036:	5d                   	pop    %ebp
f0103037:	c3                   	ret    

f0103038 <env_init>:
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f0103038:	55                   	push   %ebp
f0103039:	89 e5                	mov    %esp,%ebp
f010303b:	56                   	push   %esi
f010303c:	53                   	push   %ebx
	// Set up envs array
	// LAB 3: Your code here.
	int i;
	env_free_list = NULL;
	for(i=NENV-1; i>=0; i--){
		envs[i].env_id = 0;
f010303d:	8b 35 48 52 24 f0    	mov    0xf0245248,%esi
f0103043:	8d 86 84 ef 01 00    	lea    0x1ef84(%esi),%eax
f0103049:	8d 5e 84             	lea    -0x7c(%esi),%ebx
f010304c:	ba 00 00 00 00       	mov    $0x0,%edx
f0103051:	89 c1                	mov    %eax,%ecx
f0103053:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
		envs[i].env_status = ENV_FREE;
f010305a:	c7 40 54 00 00 00 00 	movl   $0x0,0x54(%eax)
		envs[i].env_link = env_free_list;
f0103061:	89 50 44             	mov    %edx,0x44(%eax)
f0103064:	83 e8 7c             	sub    $0x7c,%eax
		env_free_list = &envs[i];
f0103067:	89 ca                	mov    %ecx,%edx
{
	// Set up envs array
	// LAB 3: Your code here.
	int i;
	env_free_list = NULL;
	for(i=NENV-1; i>=0; i--){
f0103069:	39 d8                	cmp    %ebx,%eax
f010306b:	75 e4                	jne    f0103051 <env_init+0x19>
f010306d:	89 35 4c 52 24 f0    	mov    %esi,0xf024524c
		envs[i].env_status = ENV_FREE;
		envs[i].env_link = env_free_list;
		env_free_list = &envs[i];
	}
	// Per-CPU part of the initialization
	env_init_percpu();
f0103073:	e8 90 ff ff ff       	call   f0103008 <env_init_percpu>
}
f0103078:	5b                   	pop    %ebx
f0103079:	5e                   	pop    %esi
f010307a:	5d                   	pop    %ebp
f010307b:	c3                   	ret    

f010307c <env_alloc>:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f010307c:	55                   	push   %ebp
f010307d:	89 e5                	mov    %esp,%ebp
f010307f:	56                   	push   %esi
f0103080:	53                   	push   %ebx
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f0103081:	8b 1d 4c 52 24 f0    	mov    0xf024524c,%ebx
f0103087:	85 db                	test   %ebx,%ebx
f0103089:	0f 84 61 01 00 00    	je     f01031f0 <env_alloc+0x174>
{
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f010308f:	83 ec 0c             	sub    $0xc,%esp
f0103092:	6a 01                	push   $0x1
f0103094:	e8 df de ff ff       	call   f0100f78 <page_alloc>
f0103099:	83 c4 10             	add    $0x10,%esp
f010309c:	85 c0                	test   %eax,%eax
f010309e:	0f 84 53 01 00 00    	je     f01031f7 <env_alloc+0x17b>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01030a4:	89 c2                	mov    %eax,%edx
f01030a6:	2b 15 90 5e 24 f0    	sub    0xf0245e90,%edx
f01030ac:	c1 fa 03             	sar    $0x3,%edx
f01030af:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01030b2:	89 d1                	mov    %edx,%ecx
f01030b4:	c1 e9 0c             	shr    $0xc,%ecx
f01030b7:	3b 0d 88 5e 24 f0    	cmp    0xf0245e88,%ecx
f01030bd:	72 12                	jb     f01030d1 <env_alloc+0x55>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01030bf:	52                   	push   %edx
f01030c0:	68 c4 64 10 f0       	push   $0xf01064c4
f01030c5:	6a 58                	push   $0x58
f01030c7:	68 40 6a 10 f0       	push   $0xf0106a40
f01030cc:	e8 6f cf ff ff       	call   f0100040 <_panic>
	//	is an exception -- you need to increment env_pgdir's
	//	pp_ref for env_free to work correctly.
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.
	e->env_pgdir = (pde_t *)page2kva(p);
f01030d1:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f01030d7:	89 53 60             	mov    %edx,0x60(%ebx)
	p->pp_ref++;
f01030da:	66 ff 40 04          	incw   0x4(%eax)
f01030de:	b8 00 00 00 00       	mov    $0x0,%eax

	//Map the directory below UTOP.
	for(i = 0; i < PDX(UTOP); i++) {
		e->env_pgdir[i] = 0;		
f01030e3:	8b 53 60             	mov    0x60(%ebx),%edx
f01030e6:	c7 04 02 00 00 00 00 	movl   $0x0,(%edx,%eax,1)
f01030ed:	83 c0 04             	add    $0x4,%eax
	// LAB 3: Your code here.
	e->env_pgdir = (pde_t *)page2kva(p);
	p->pp_ref++;

	//Map the directory below UTOP.
	for(i = 0; i < PDX(UTOP); i++) {
f01030f0:	3d ec 0e 00 00       	cmp    $0xeec,%eax
f01030f5:	75 ec                	jne    f01030e3 <env_alloc+0x67>
		e->env_pgdir[i] = 0;		
	}

	//Map the directory above UTOP
	for(i = PDX(UTOP); i < NPDENTRIES; i++) {
		e->env_pgdir[i] = kern_pgdir[i];
f01030f7:	8b 15 8c 5e 24 f0    	mov    0xf0245e8c,%edx
f01030fd:	8b 0c 02             	mov    (%edx,%eax,1),%ecx
f0103100:	8b 53 60             	mov    0x60(%ebx),%edx
f0103103:	89 0c 02             	mov    %ecx,(%edx,%eax,1)
f0103106:	83 c0 04             	add    $0x4,%eax
	for(i = 0; i < PDX(UTOP); i++) {
		e->env_pgdir[i] = 0;		
	}

	//Map the directory above UTOP
	for(i = PDX(UTOP); i < NPDENTRIES; i++) {
f0103109:	3d 00 10 00 00       	cmp    $0x1000,%eax
f010310e:	75 e7                	jne    f01030f7 <env_alloc+0x7b>
		e->env_pgdir[i] = kern_pgdir[i];
	}
		
	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f0103110:	8b 43 60             	mov    0x60(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103113:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103118:	77 15                	ja     f010312f <env_alloc+0xb3>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010311a:	50                   	push   %eax
f010311b:	68 e8 64 10 f0       	push   $0xf01064e8
f0103120:	68 cf 00 00 00       	push   $0xcf
f0103125:	68 28 77 10 f0       	push   $0xf0107728
f010312a:	e8 11 cf ff ff       	call   f0100040 <_panic>
f010312f:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0103135:	83 ca 05             	or     $0x5,%edx
f0103138:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f010313e:	8b 43 48             	mov    0x48(%ebx),%eax
f0103141:	8d 90 00 10 00 00    	lea    0x1000(%eax),%edx
	if (generation <= 0)	// Don't create a negative env_id.
f0103147:	81 e2 00 fc ff ff    	and    $0xfffffc00,%edx
f010314d:	7f 05                	jg     f0103154 <env_alloc+0xd8>
		generation = 1 << ENVGENSHIFT;
f010314f:	ba 00 10 00 00       	mov    $0x1000,%edx
	e->env_id = generation | (e - envs);
f0103154:	89 d8                	mov    %ebx,%eax
f0103156:	2b 05 48 52 24 f0    	sub    0xf0245248,%eax
f010315c:	c1 f8 02             	sar    $0x2,%eax
f010315f:	89 c6                	mov    %eax,%esi
f0103161:	c1 e6 05             	shl    $0x5,%esi
f0103164:	89 c1                	mov    %eax,%ecx
f0103166:	c1 e1 0a             	shl    $0xa,%ecx
f0103169:	01 f1                	add    %esi,%ecx
f010316b:	01 c1                	add    %eax,%ecx
f010316d:	89 ce                	mov    %ecx,%esi
f010316f:	c1 e6 0f             	shl    $0xf,%esi
f0103172:	01 f1                	add    %esi,%ecx
f0103174:	c1 e1 05             	shl    $0x5,%ecx
f0103177:	01 c8                	add    %ecx,%eax
f0103179:	f7 d8                	neg    %eax
f010317b:	09 d0                	or     %edx,%eax
f010317d:	89 43 48             	mov    %eax,0x48(%ebx)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f0103180:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103183:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f0103186:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f010318d:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f0103194:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f010319b:	83 ec 04             	sub    $0x4,%esp
f010319e:	6a 44                	push   $0x44
f01031a0:	6a 00                	push   $0x0
f01031a2:	53                   	push   %ebx
f01031a3:	e8 bd 25 00 00       	call   f0105765 <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f01031a8:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f01031ae:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f01031b4:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f01031ba:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f01031c1:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	// You will set e->env_tf.tf_eip later.

	// Enable interrupts while in user mode.
	// LAB 4: Your code here.

	e->env_tf.tf_eflags |= FL_IF;
f01031c7:	81 4b 38 00 02 00 00 	orl    $0x200,0x38(%ebx)
	// Clear the page fault handler until user installs one.
	e->env_pgfault_upcall = 0;
f01031ce:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)

	// Also clear the IPC receiving flag.
	e->env_ipc_recving = 0;
f01031d5:	c6 43 68 00          	movb   $0x0,0x68(%ebx)

	// commit the allocation
	env_free_list = e->env_link;
f01031d9:	8b 43 44             	mov    0x44(%ebx),%eax
f01031dc:	a3 4c 52 24 f0       	mov    %eax,0xf024524c
	*newenv_store = e;
f01031e1:	8b 45 08             	mov    0x8(%ebp),%eax
f01031e4:	89 18                	mov    %ebx,(%eax)

	// cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
f01031e6:	83 c4 10             	add    $0x10,%esp
f01031e9:	b8 00 00 00 00       	mov    $0x0,%eax
f01031ee:	eb 0c                	jmp    f01031fc <env_alloc+0x180>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
		return -E_NO_FREE_ENV;
f01031f0:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f01031f5:	eb 05                	jmp    f01031fc <env_alloc+0x180>
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;
f01031f7:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	env_free_list = e->env_link;
	*newenv_store = e;

	// cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f01031fc:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01031ff:	5b                   	pop    %ebx
f0103200:	5e                   	pop    %esi
f0103201:	5d                   	pop    %ebp
f0103202:	c3                   	ret    

f0103203 <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f0103203:	55                   	push   %ebp
f0103204:	89 e5                	mov    %esp,%ebp
f0103206:	57                   	push   %edi
f0103207:	56                   	push   %esi
f0103208:	53                   	push   %ebx
f0103209:	83 ec 24             	sub    $0x24,%esp
	// LAB 5: Your code here.

	
	struct Env *e;
	int rc;
	if((rc = env_alloc(&e, 0)) != 0) {
f010320c:	6a 00                	push   $0x0
f010320e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0103211:	50                   	push   %eax
f0103212:	e8 65 fe ff ff       	call   f010307c <env_alloc>
f0103217:	83 c4 10             	add    $0x10,%esp
f010321a:	85 c0                	test   %eax,%eax
f010321c:	74 17                	je     f0103235 <env_create+0x32>
		panic("env_create failed: env_alloc failed.\n");
f010321e:	83 ec 04             	sub    $0x4,%esp
f0103221:	68 98 76 10 f0       	push   $0xf0107698
f0103226:	68 aa 01 00 00       	push   $0x1aa
f010322b:	68 28 77 10 f0       	push   $0xf0107728
f0103230:	e8 0b ce ff ff       	call   f0100040 <_panic>
	}
	if (type == ENV_TYPE_FS)
f0103235:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
f0103239:	75 0a                	jne    f0103245 <env_create+0x42>
		e->env_tf.tf_eflags |= FL_IOPL_MASK;
f010323b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010323e:	81 48 38 00 30 00 00 	orl    $0x3000,0x38(%eax)
	load_icode(e, binary);
f0103245:	8b 7d e4             	mov    -0x1c(%ebp),%edi
	//  What?  (See env_run() and env_pop_tf() below.)

	// LAB 3: Your code here.
	struct Elf* header = (struct Elf*)binary;
	
	if(header->e_magic != ELF_MAGIC) {
f0103248:	8b 45 08             	mov    0x8(%ebp),%eax
f010324b:	81 38 7f 45 4c 46    	cmpl   $0x464c457f,(%eax)
f0103251:	74 17                	je     f010326a <env_create+0x67>
		panic("load_icode failed: The binary we load is not elf.\n");
f0103253:	83 ec 04             	sub    $0x4,%esp
f0103256:	68 c0 76 10 f0       	push   $0xf01076c0
f010325b:	68 77 01 00 00       	push   $0x177
f0103260:	68 28 77 10 f0       	push   $0xf0107728
f0103265:	e8 d6 cd ff ff       	call   f0100040 <_panic>
	}

	if(header->e_entry == 0){
f010326a:	8b 45 08             	mov    0x8(%ebp),%eax
f010326d:	8b 40 18             	mov    0x18(%eax),%eax
f0103270:	85 c0                	test   %eax,%eax
f0103272:	75 17                	jne    f010328b <env_create+0x88>
		panic("load_icode failed: The elf file can't be excuterd.\n");
f0103274:	83 ec 04             	sub    $0x4,%esp
f0103277:	68 f4 76 10 f0       	push   $0xf01076f4
f010327c:	68 7b 01 00 00       	push   $0x17b
f0103281:	68 28 77 10 f0       	push   $0xf0107728
f0103286:	e8 b5 cd ff ff       	call   f0100040 <_panic>
	}

	e->env_tf.tf_eip = header->e_entry;
f010328b:	89 47 30             	mov    %eax,0x30(%edi)

	lcr3(PADDR(e->env_pgdir));   //?????
f010328e:	8b 47 60             	mov    0x60(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103291:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103296:	77 15                	ja     f01032ad <env_create+0xaa>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103298:	50                   	push   %eax
f0103299:	68 e8 64 10 f0       	push   $0xf01064e8
f010329e:	68 80 01 00 00       	push   $0x180
f01032a3:	68 28 77 10 f0       	push   $0xf0107728
f01032a8:	e8 93 cd ff ff       	call   f0100040 <_panic>
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f01032ad:	05 00 00 00 10       	add    $0x10000000,%eax
f01032b2:	0f 22 d8             	mov    %eax,%cr3

	struct Proghdr *ph, *eph;
	ph = (struct Proghdr* )((uint8_t *)header + header->e_phoff);
f01032b5:	8b 45 08             	mov    0x8(%ebp),%eax
f01032b8:	89 c3                	mov    %eax,%ebx
f01032ba:	03 58 1c             	add    0x1c(%eax),%ebx
	eph = ph + header->e_phnum;
f01032bd:	0f b7 70 2c          	movzwl 0x2c(%eax),%esi
f01032c1:	c1 e6 05             	shl    $0x5,%esi
f01032c4:	01 de                	add    %ebx,%esi
	for(; ph < eph; ph++) {
f01032c6:	39 f3                	cmp    %esi,%ebx
f01032c8:	73 48                	jae    f0103312 <env_create+0x10f>
		if(ph->p_type == ELF_PROG_LOAD) {
f01032ca:	83 3b 01             	cmpl   $0x1,(%ebx)
f01032cd:	75 3c                	jne    f010330b <env_create+0x108>
			if(ph->p_memsz - ph->p_filesz < 0) {
				panic("load icode failed : p_memsz < p_filesz.\n");
			}

			region_alloc(e, (void *)ph->p_va, ph->p_memsz);
f01032cf:	8b 4b 14             	mov    0x14(%ebx),%ecx
f01032d2:	8b 53 08             	mov    0x8(%ebx),%edx
f01032d5:	89 f8                	mov    %edi,%eax
f01032d7:	e8 dd fb ff ff       	call   f0102eb9 <region_alloc>
			memmove((void *)ph->p_va, binary + ph->p_offset, ph->p_filesz);
f01032dc:	83 ec 04             	sub    $0x4,%esp
f01032df:	ff 73 10             	pushl  0x10(%ebx)
f01032e2:	8b 45 08             	mov    0x8(%ebp),%eax
f01032e5:	03 43 04             	add    0x4(%ebx),%eax
f01032e8:	50                   	push   %eax
f01032e9:	ff 73 08             	pushl  0x8(%ebx)
f01032ec:	e8 c1 24 00 00       	call   f01057b2 <memmove>
			memset((void *)(ph->p_va + ph->p_filesz), 0, ph->p_memsz - ph->p_filesz);
f01032f1:	8b 43 10             	mov    0x10(%ebx),%eax
f01032f4:	83 c4 0c             	add    $0xc,%esp
f01032f7:	8b 53 14             	mov    0x14(%ebx),%edx
f01032fa:	29 c2                	sub    %eax,%edx
f01032fc:	52                   	push   %edx
f01032fd:	6a 00                	push   $0x0
f01032ff:	03 43 08             	add    0x8(%ebx),%eax
f0103302:	50                   	push   %eax
f0103303:	e8 5d 24 00 00       	call   f0105765 <memset>
f0103308:	83 c4 10             	add    $0x10,%esp
	lcr3(PADDR(e->env_pgdir));   //?????

	struct Proghdr *ph, *eph;
	ph = (struct Proghdr* )((uint8_t *)header + header->e_phoff);
	eph = ph + header->e_phnum;
	for(; ph < eph; ph++) {
f010330b:	83 c3 20             	add    $0x20,%ebx
f010330e:	39 de                	cmp    %ebx,%esi
f0103310:	77 b8                	ja     f01032ca <env_create+0xc7>
		}
	} 
	 
	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.
	region_alloc(e,(void *)(USTACKTOP-PGSIZE), PGSIZE);
f0103312:	b9 00 10 00 00       	mov    $0x1000,%ecx
f0103317:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f010331c:	89 f8                	mov    %edi,%eax
f010331e:	e8 96 fb ff ff       	call   f0102eb9 <region_alloc>
		panic("env_create failed: env_alloc failed.\n");
	}
	if (type == ENV_TYPE_FS)
		e->env_tf.tf_eflags |= FL_IOPL_MASK;
	load_icode(e, binary);
	e->env_type = type;
f0103323:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103326:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0103329:	89 48 50             	mov    %ecx,0x50(%eax)
}
f010332c:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010332f:	5b                   	pop    %ebx
f0103330:	5e                   	pop    %esi
f0103331:	5f                   	pop    %edi
f0103332:	5d                   	pop    %ebp
f0103333:	c3                   	ret    

f0103334 <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f0103334:	55                   	push   %ebp
f0103335:	89 e5                	mov    %esp,%ebp
f0103337:	57                   	push   %edi
f0103338:	56                   	push   %esi
f0103339:	53                   	push   %ebx
f010333a:	83 ec 1c             	sub    $0x1c,%esp
f010333d:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0103340:	e8 9a 2a 00 00       	call   f0105ddf <cpunum>
f0103345:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0103348:	01 c2                	add    %eax,%edx
f010334a:	01 d2                	add    %edx,%edx
f010334c:	01 c2                	add    %eax,%edx
f010334e:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103351:	39 3c 85 28 60 24 f0 	cmp    %edi,-0xfdb9fd8(,%eax,4)
f0103358:	75 39                	jne    f0103393 <env_free+0x5f>
		lcr3(PADDR(kern_pgdir));
f010335a:	a1 8c 5e 24 f0       	mov    0xf0245e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010335f:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103364:	77 15                	ja     f010337b <env_free+0x47>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103366:	50                   	push   %eax
f0103367:	68 e8 64 10 f0       	push   $0xf01064e8
f010336c:	68 c0 01 00 00       	push   $0x1c0
f0103371:	68 28 77 10 f0       	push   $0xf0107728
f0103376:	e8 c5 cc ff ff       	call   f0100040 <_panic>
f010337b:	05 00 00 00 10       	add    $0x10000000,%eax
f0103380:	0f 22 d8             	mov    %eax,%cr3
f0103383:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f010338a:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
f0103391:	eb 0e                	jmp    f01033a1 <env_free+0x6d>
f0103393:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f010339a:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f01033a1:	8b 47 60             	mov    0x60(%edi),%eax
f01033a4:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01033a7:	8b 34 10             	mov    (%eax,%edx,1),%esi
f01033aa:	f7 c6 01 00 00 00    	test   $0x1,%esi
f01033b0:	0f 84 a6 00 00 00    	je     f010345c <env_free+0x128>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f01033b6:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01033bc:	89 f0                	mov    %esi,%eax
f01033be:	c1 e8 0c             	shr    $0xc,%eax
f01033c1:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01033c4:	39 05 88 5e 24 f0    	cmp    %eax,0xf0245e88
f01033ca:	77 15                	ja     f01033e1 <env_free+0xad>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01033cc:	56                   	push   %esi
f01033cd:	68 c4 64 10 f0       	push   $0xf01064c4
f01033d2:	68 cf 01 00 00       	push   $0x1cf
f01033d7:	68 28 77 10 f0       	push   $0xf0107728
f01033dc:	e8 5f cc ff ff       	call   f0100040 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f01033e1:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01033e4:	c1 e0 16             	shl    $0x16,%eax
f01033e7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f01033ea:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f01033ef:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f01033f6:	01 
f01033f7:	74 17                	je     f0103410 <env_free+0xdc>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f01033f9:	83 ec 08             	sub    $0x8,%esp
f01033fc:	89 d8                	mov    %ebx,%eax
f01033fe:	c1 e0 0c             	shl    $0xc,%eax
f0103401:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0103404:	50                   	push   %eax
f0103405:	ff 77 60             	pushl  0x60(%edi)
f0103408:	e8 fd dd ff ff       	call   f010120a <page_remove>
f010340d:	83 c4 10             	add    $0x10,%esp
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103410:	43                   	inc    %ebx
f0103411:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f0103417:	75 d6                	jne    f01033ef <env_free+0xbb>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0103419:	8b 47 60             	mov    0x60(%edi),%eax
f010341c:	8b 55 e0             	mov    -0x20(%ebp),%edx
f010341f:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103426:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103429:	3b 05 88 5e 24 f0    	cmp    0xf0245e88,%eax
f010342f:	72 14                	jb     f0103445 <env_free+0x111>
		panic("pa2page called with invalid pa");
f0103431:	83 ec 04             	sub    $0x4,%esp
f0103434:	68 38 6e 10 f0       	push   $0xf0106e38
f0103439:	6a 51                	push   $0x51
f010343b:	68 40 6a 10 f0       	push   $0xf0106a40
f0103440:	e8 fb cb ff ff       	call   f0100040 <_panic>
		page_decref(pa2page(pa));
f0103445:	83 ec 0c             	sub    $0xc,%esp
f0103448:	a1 90 5e 24 f0       	mov    0xf0245e90,%eax
f010344d:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0103450:	8d 04 d0             	lea    (%eax,%edx,8),%eax
f0103453:	50                   	push   %eax
f0103454:	e8 f0 db ff ff       	call   f0101049 <page_decref>
f0103459:	83 c4 10             	add    $0x10,%esp
	// Note the environment's demise.
	// cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f010345c:	ff 45 dc             	incl   -0x24(%ebp)
f010345f:	83 45 e0 04          	addl   $0x4,-0x20(%ebp)
f0103463:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103466:	3d ec 0e 00 00       	cmp    $0xeec,%eax
f010346b:	0f 85 30 ff ff ff    	jne    f01033a1 <env_free+0x6d>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f0103471:	8b 47 60             	mov    0x60(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103474:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103479:	77 15                	ja     f0103490 <env_free+0x15c>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010347b:	50                   	push   %eax
f010347c:	68 e8 64 10 f0       	push   $0xf01064e8
f0103481:	68 dd 01 00 00       	push   $0x1dd
f0103486:	68 28 77 10 f0       	push   $0xf0107728
f010348b:	e8 b0 cb ff ff       	call   f0100040 <_panic>
	e->env_pgdir = 0;
f0103490:	c7 47 60 00 00 00 00 	movl   $0x0,0x60(%edi)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103497:	05 00 00 00 10       	add    $0x10000000,%eax
f010349c:	c1 e8 0c             	shr    $0xc,%eax
f010349f:	3b 05 88 5e 24 f0    	cmp    0xf0245e88,%eax
f01034a5:	72 14                	jb     f01034bb <env_free+0x187>
		panic("pa2page called with invalid pa");
f01034a7:	83 ec 04             	sub    $0x4,%esp
f01034aa:	68 38 6e 10 f0       	push   $0xf0106e38
f01034af:	6a 51                	push   $0x51
f01034b1:	68 40 6a 10 f0       	push   $0xf0106a40
f01034b6:	e8 85 cb ff ff       	call   f0100040 <_panic>
	page_decref(pa2page(pa));
f01034bb:	83 ec 0c             	sub    $0xc,%esp
f01034be:	8b 15 90 5e 24 f0    	mov    0xf0245e90,%edx
f01034c4:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f01034c7:	50                   	push   %eax
f01034c8:	e8 7c db ff ff       	call   f0101049 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f01034cd:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f01034d4:	a1 4c 52 24 f0       	mov    0xf024524c,%eax
f01034d9:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f01034dc:	89 3d 4c 52 24 f0    	mov    %edi,0xf024524c
}
f01034e2:	83 c4 10             	add    $0x10,%esp
f01034e5:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01034e8:	5b                   	pop    %ebx
f01034e9:	5e                   	pop    %esi
f01034ea:	5f                   	pop    %edi
f01034eb:	5d                   	pop    %ebp
f01034ec:	c3                   	ret    

f01034ed <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f01034ed:	55                   	push   %ebp
f01034ee:	89 e5                	mov    %esp,%ebp
f01034f0:	53                   	push   %ebx
f01034f1:	83 ec 04             	sub    $0x4,%esp
f01034f4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f01034f7:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f01034fb:	75 23                	jne    f0103520 <env_destroy+0x33>
f01034fd:	e8 dd 28 00 00       	call   f0105ddf <cpunum>
f0103502:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0103505:	01 c2                	add    %eax,%edx
f0103507:	01 d2                	add    %edx,%edx
f0103509:	01 c2                	add    %eax,%edx
f010350b:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010350e:	3b 1c 85 28 60 24 f0 	cmp    -0xfdb9fd8(,%eax,4),%ebx
f0103515:	74 09                	je     f0103520 <env_destroy+0x33>
		e->env_status = ENV_DYING;
f0103517:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f010351e:	eb 3d                	jmp    f010355d <env_destroy+0x70>
	}

	env_free(e);
f0103520:	83 ec 0c             	sub    $0xc,%esp
f0103523:	53                   	push   %ebx
f0103524:	e8 0b fe ff ff       	call   f0103334 <env_free>

	if (curenv == e) {
f0103529:	e8 b1 28 00 00       	call   f0105ddf <cpunum>
f010352e:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0103531:	01 c2                	add    %eax,%edx
f0103533:	01 d2                	add    %edx,%edx
f0103535:	01 c2                	add    %eax,%edx
f0103537:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010353a:	83 c4 10             	add    $0x10,%esp
f010353d:	3b 1c 85 28 60 24 f0 	cmp    -0xfdb9fd8(,%eax,4),%ebx
f0103544:	75 17                	jne    f010355d <env_destroy+0x70>
		curenv = NULL;
f0103546:	e8 94 28 00 00       	call   f0105ddf <cpunum>
f010354b:	6b c0 74             	imul   $0x74,%eax,%eax
f010354e:	c7 80 28 60 24 f0 00 	movl   $0x0,-0xfdb9fd8(%eax)
f0103555:	00 00 00 
		sched_yield();
f0103558:	e8 0e 0f 00 00       	call   f010446b <sched_yield>
	}
}
f010355d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103560:	c9                   	leave  
f0103561:	c3                   	ret    

f0103562 <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0103562:	55                   	push   %ebp
f0103563:	89 e5                	mov    %esp,%ebp
f0103565:	53                   	push   %ebx
f0103566:	83 ec 04             	sub    $0x4,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f0103569:	e8 71 28 00 00       	call   f0105ddf <cpunum>
f010356e:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0103571:	01 c2                	add    %eax,%edx
f0103573:	01 d2                	add    %edx,%edx
f0103575:	01 c2                	add    %eax,%edx
f0103577:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010357a:	8b 1c 85 28 60 24 f0 	mov    -0xfdb9fd8(,%eax,4),%ebx
f0103581:	e8 59 28 00 00       	call   f0105ddf <cpunum>
f0103586:	89 43 5c             	mov    %eax,0x5c(%ebx)

	__asm __volatile("movl %0,%%esp\n"
f0103589:	8b 65 08             	mov    0x8(%ebp),%esp
f010358c:	61                   	popa   
f010358d:	07                   	pop    %es
f010358e:	1f                   	pop    %ds
f010358f:	83 c4 08             	add    $0x8,%esp
f0103592:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0103593:	83 ec 04             	sub    $0x4,%esp
f0103596:	68 46 77 10 f0       	push   $0xf0107746
f010359b:	68 13 02 00 00       	push   $0x213
f01035a0:	68 28 77 10 f0       	push   $0xf0107728
f01035a5:	e8 96 ca ff ff       	call   f0100040 <_panic>

f01035aa <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f01035aa:	55                   	push   %ebp
f01035ab:	89 e5                	mov    %esp,%ebp
f01035ad:	83 ec 08             	sub    $0x8,%esp
	//	   4. Update its 'env_runs' counter,
	//	   5. Use lcr3() to switch to its address space.
	// Step 2: Use env_pop_tf() to restore the environment's
	//	   registers and drop into user mode in the
	//	   environment.
	if(curenv != NULL && curenv->env_status == ENV_RUNNING) {
f01035b0:	e8 2a 28 00 00       	call   f0105ddf <cpunum>
f01035b5:	8d 14 00             	lea    (%eax,%eax,1),%edx
f01035b8:	01 c2                	add    %eax,%edx
f01035ba:	01 d2                	add    %edx,%edx
f01035bc:	01 c2                	add    %eax,%edx
f01035be:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01035c1:	83 3c 85 28 60 24 f0 	cmpl   $0x0,-0xfdb9fd8(,%eax,4)
f01035c8:	00 
f01035c9:	74 33                	je     f01035fe <env_run+0x54>
f01035cb:	e8 0f 28 00 00       	call   f0105ddf <cpunum>
f01035d0:	8d 14 00             	lea    (%eax,%eax,1),%edx
f01035d3:	01 c2                	add    %eax,%edx
f01035d5:	01 d2                	add    %edx,%edx
f01035d7:	01 c2                	add    %eax,%edx
f01035d9:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01035dc:	8b 04 85 28 60 24 f0 	mov    -0xfdb9fd8(,%eax,4),%eax
f01035e3:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f01035e7:	75 15                	jne    f01035fe <env_run+0x54>
		curenv->env_status = ENV_RUNNABLE;
f01035e9:	e8 f1 27 00 00       	call   f0105ddf <cpunum>
f01035ee:	6b c0 74             	imul   $0x74,%eax,%eax
f01035f1:	8b 80 28 60 24 f0    	mov    -0xfdb9fd8(%eax),%eax
f01035f7:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
	}

	curenv = e;
f01035fe:	e8 dc 27 00 00       	call   f0105ddf <cpunum>
f0103603:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0103606:	01 c2                	add    %eax,%edx
f0103608:	01 d2                	add    %edx,%edx
f010360a:	01 c2                	add    %eax,%edx
f010360c:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010360f:	8b 55 08             	mov    0x8(%ebp),%edx
f0103612:	89 14 85 28 60 24 f0 	mov    %edx,-0xfdb9fd8(,%eax,4)
	curenv->env_status = ENV_RUNNING;
f0103619:	e8 c1 27 00 00       	call   f0105ddf <cpunum>
f010361e:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0103621:	01 c2                	add    %eax,%edx
f0103623:	01 d2                	add    %edx,%edx
f0103625:	01 c2                	add    %eax,%edx
f0103627:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010362a:	8b 04 85 28 60 24 f0 	mov    -0xfdb9fd8(,%eax,4),%eax
f0103631:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
	curenv->env_runs++;
f0103638:	e8 a2 27 00 00       	call   f0105ddf <cpunum>
f010363d:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0103640:	01 c2                	add    %eax,%edx
f0103642:	01 d2                	add    %edx,%edx
f0103644:	01 c2                	add    %eax,%edx
f0103646:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103649:	8b 04 85 28 60 24 f0 	mov    -0xfdb9fd8(,%eax,4),%eax
f0103650:	ff 40 58             	incl   0x58(%eax)
	lcr3(PADDR(curenv->env_pgdir));
f0103653:	e8 87 27 00 00       	call   f0105ddf <cpunum>
f0103658:	8d 14 00             	lea    (%eax,%eax,1),%edx
f010365b:	01 c2                	add    %eax,%edx
f010365d:	01 d2                	add    %edx,%edx
f010365f:	01 c2                	add    %eax,%edx
f0103661:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103664:	8b 04 85 28 60 24 f0 	mov    -0xfdb9fd8(,%eax,4),%eax
f010366b:	8b 40 60             	mov    0x60(%eax),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010366e:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103673:	77 15                	ja     f010368a <env_run+0xe0>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103675:	50                   	push   %eax
f0103676:	68 e8 64 10 f0       	push   $0xf01064e8
f010367b:	68 31 02 00 00       	push   $0x231
f0103680:	68 28 77 10 f0       	push   $0xf0107728
f0103685:	e8 b6 c9 ff ff       	call   f0100040 <_panic>
f010368a:	05 00 00 00 10       	add    $0x10000000,%eax
f010368f:	0f 22 d8             	mov    %eax,%cr3
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0103692:	83 ec 0c             	sub    $0xc,%esp
f0103695:	68 c0 03 12 f0       	push   $0xf01203c0
f010369a:	e8 88 2a 00 00       	call   f0106127 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f010369f:	f3 90                	pause  
	// Hint: This function loads the new environment's state from
	//	e->env_tf.  Go back through the code you wrote above
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.
	unlock_kernel();
	env_pop_tf(&curenv->env_tf);
f01036a1:	e8 39 27 00 00       	call   f0105ddf <cpunum>
f01036a6:	83 c4 04             	add    $0x4,%esp
f01036a9:	6b c0 74             	imul   $0x74,%eax,%eax
f01036ac:	ff b0 28 60 24 f0    	pushl  -0xfdb9fd8(%eax)
f01036b2:	e8 ab fe ff ff       	call   f0103562 <env_pop_tf>

f01036b7 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f01036b7:	55                   	push   %ebp
f01036b8:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01036ba:	ba 70 00 00 00       	mov    $0x70,%edx
f01036bf:	8b 45 08             	mov    0x8(%ebp),%eax
f01036c2:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01036c3:	ba 71 00 00 00       	mov    $0x71,%edx
f01036c8:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f01036c9:	0f b6 c0             	movzbl %al,%eax
}
f01036cc:	5d                   	pop    %ebp
f01036cd:	c3                   	ret    

f01036ce <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f01036ce:	55                   	push   %ebp
f01036cf:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01036d1:	ba 70 00 00 00       	mov    $0x70,%edx
f01036d6:	8b 45 08             	mov    0x8(%ebp),%eax
f01036d9:	ee                   	out    %al,(%dx)
f01036da:	ba 71 00 00 00       	mov    $0x71,%edx
f01036df:	8b 45 0c             	mov    0xc(%ebp),%eax
f01036e2:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f01036e3:	5d                   	pop    %ebp
f01036e4:	c3                   	ret    

f01036e5 <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f01036e5:	55                   	push   %ebp
f01036e6:	89 e5                	mov    %esp,%ebp
f01036e8:	56                   	push   %esi
f01036e9:	53                   	push   %ebx
f01036ea:	8b 45 08             	mov    0x8(%ebp),%eax
	int i;
	irq_mask_8259A = mask;
f01036ed:	66 a3 a8 03 12 f0    	mov    %ax,0xf01203a8
	if (!didinit)
f01036f3:	80 3d 50 52 24 f0 00 	cmpb   $0x0,0xf0245250
f01036fa:	74 5d                	je     f0103759 <irq_setmask_8259A+0x74>
f01036fc:	89 c6                	mov    %eax,%esi
f01036fe:	ba 21 00 00 00       	mov    $0x21,%edx
f0103703:	ee                   	out    %al,(%dx)
f0103704:	66 c1 e8 08          	shr    $0x8,%ax
f0103708:	ba a1 00 00 00       	mov    $0xa1,%edx
f010370d:	ee                   	out    %al,(%dx)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
f010370e:	83 ec 0c             	sub    $0xc,%esp
f0103711:	68 52 77 10 f0       	push   $0xf0107752
f0103716:	e8 f5 00 00 00       	call   f0103810 <cprintf>
f010371b:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 16; i++)
f010371e:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f0103723:	0f b7 f6             	movzwl %si,%esi
f0103726:	f7 d6                	not    %esi
f0103728:	89 f0                	mov    %esi,%eax
f010372a:	88 d9                	mov    %bl,%cl
f010372c:	d3 f8                	sar    %cl,%eax
f010372e:	a8 01                	test   $0x1,%al
f0103730:	74 11                	je     f0103743 <irq_setmask_8259A+0x5e>
			cprintf(" %d", i);
f0103732:	83 ec 08             	sub    $0x8,%esp
f0103735:	53                   	push   %ebx
f0103736:	68 ab 7b 10 f0       	push   $0xf0107bab
f010373b:	e8 d0 00 00 00       	call   f0103810 <cprintf>
f0103740:	83 c4 10             	add    $0x10,%esp
	if (!didinit)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
f0103743:	43                   	inc    %ebx
f0103744:	83 fb 10             	cmp    $0x10,%ebx
f0103747:	75 df                	jne    f0103728 <irq_setmask_8259A+0x43>
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
f0103749:	83 ec 0c             	sub    $0xc,%esp
f010374c:	68 41 6d 10 f0       	push   $0xf0106d41
f0103751:	e8 ba 00 00 00       	call   f0103810 <cprintf>
f0103756:	83 c4 10             	add    $0x10,%esp
}
f0103759:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010375c:	5b                   	pop    %ebx
f010375d:	5e                   	pop    %esi
f010375e:	5d                   	pop    %ebp
f010375f:	c3                   	ret    

f0103760 <pic_init>:

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
	didinit = 1;
f0103760:	c6 05 50 52 24 f0 01 	movb   $0x1,0xf0245250
f0103767:	ba 21 00 00 00       	mov    $0x21,%edx
f010376c:	b0 ff                	mov    $0xff,%al
f010376e:	ee                   	out    %al,(%dx)
f010376f:	ba a1 00 00 00       	mov    $0xa1,%edx
f0103774:	ee                   	out    %al,(%dx)
f0103775:	ba 20 00 00 00       	mov    $0x20,%edx
f010377a:	b0 11                	mov    $0x11,%al
f010377c:	ee                   	out    %al,(%dx)
f010377d:	ba 21 00 00 00       	mov    $0x21,%edx
f0103782:	b0 20                	mov    $0x20,%al
f0103784:	ee                   	out    %al,(%dx)
f0103785:	b0 04                	mov    $0x4,%al
f0103787:	ee                   	out    %al,(%dx)
f0103788:	b0 03                	mov    $0x3,%al
f010378a:	ee                   	out    %al,(%dx)
f010378b:	ba a0 00 00 00       	mov    $0xa0,%edx
f0103790:	b0 11                	mov    $0x11,%al
f0103792:	ee                   	out    %al,(%dx)
f0103793:	ba a1 00 00 00       	mov    $0xa1,%edx
f0103798:	b0 28                	mov    $0x28,%al
f010379a:	ee                   	out    %al,(%dx)
f010379b:	b0 02                	mov    $0x2,%al
f010379d:	ee                   	out    %al,(%dx)
f010379e:	b0 01                	mov    $0x1,%al
f01037a0:	ee                   	out    %al,(%dx)
f01037a1:	ba 20 00 00 00       	mov    $0x20,%edx
f01037a6:	b0 68                	mov    $0x68,%al
f01037a8:	ee                   	out    %al,(%dx)
f01037a9:	b0 0a                	mov    $0xa,%al
f01037ab:	ee                   	out    %al,(%dx)
f01037ac:	ba a0 00 00 00       	mov    $0xa0,%edx
f01037b1:	b0 68                	mov    $0x68,%al
f01037b3:	ee                   	out    %al,(%dx)
f01037b4:	b0 0a                	mov    $0xa,%al
f01037b6:	ee                   	out    %al,(%dx)
	outb(IO_PIC1, 0x0a);             /* read IRR by default */

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
f01037b7:	66 a1 a8 03 12 f0    	mov    0xf01203a8,%ax
f01037bd:	66 83 f8 ff          	cmp    $0xffff,%ax
f01037c1:	74 13                	je     f01037d6 <pic_init+0x76>
static bool didinit;

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
f01037c3:	55                   	push   %ebp
f01037c4:	89 e5                	mov    %esp,%ebp
f01037c6:	83 ec 14             	sub    $0x14,%esp

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
		irq_setmask_8259A(irq_mask_8259A);
f01037c9:	0f b7 c0             	movzwl %ax,%eax
f01037cc:	50                   	push   %eax
f01037cd:	e8 13 ff ff ff       	call   f01036e5 <irq_setmask_8259A>
f01037d2:	83 c4 10             	add    $0x10,%esp
}
f01037d5:	c9                   	leave  
f01037d6:	c3                   	ret    

f01037d7 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f01037d7:	55                   	push   %ebp
f01037d8:	89 e5                	mov    %esp,%ebp
f01037da:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f01037dd:	ff 75 08             	pushl  0x8(%ebp)
f01037e0:	e8 b9 cf ff ff       	call   f010079e <cputchar>
	*cnt++;
}
f01037e5:	83 c4 10             	add    $0x10,%esp
f01037e8:	c9                   	leave  
f01037e9:	c3                   	ret    

f01037ea <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f01037ea:	55                   	push   %ebp
f01037eb:	89 e5                	mov    %esp,%ebp
f01037ed:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f01037f0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f01037f7:	ff 75 0c             	pushl  0xc(%ebp)
f01037fa:	ff 75 08             	pushl  0x8(%ebp)
f01037fd:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103800:	50                   	push   %eax
f0103801:	68 d7 37 10 f0       	push   $0xf01037d7
f0103806:	e8 28 18 00 00       	call   f0105033 <vprintfmt>
	return cnt;
}
f010380b:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010380e:	c9                   	leave  
f010380f:	c3                   	ret    

f0103810 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0103810:	55                   	push   %ebp
f0103811:	89 e5                	mov    %esp,%ebp
f0103813:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0103816:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0103819:	50                   	push   %eax
f010381a:	ff 75 08             	pushl  0x8(%ebp)
f010381d:	e8 c8 ff ff ff       	call   f01037ea <vcprintf>
	va_end(ap);

	return cnt;
}
f0103822:	c9                   	leave  
f0103823:	c3                   	ret    

f0103824 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0103824:	55                   	push   %ebp
f0103825:	89 e5                	mov    %esp,%ebp
f0103827:	57                   	push   %edi
f0103828:	56                   	push   %esi
f0103829:	53                   	push   %ebx
f010382a:	83 ec 0c             	sub    $0xc,%esp
	// wrong, you may not get a fault until you try to return from
	// user space on that CPU.
	//
	// LAB 4: Your code here:
	
	thiscpu->cpu_ts.ts_esp0 = (uintptr_t)(percpu_kstacks[cpunum()] + KSTKSIZE);
f010382d:	e8 ad 25 00 00       	call   f0105ddf <cpunum>
f0103832:	89 c3                	mov    %eax,%ebx
f0103834:	e8 a6 25 00 00       	call   f0105ddf <cpunum>
f0103839:	8d 14 1b             	lea    (%ebx,%ebx,1),%edx
f010383c:	01 da                	add    %ebx,%edx
f010383e:	01 d2                	add    %edx,%edx
f0103840:	01 da                	add    %ebx,%edx
f0103842:	8d 14 93             	lea    (%ebx,%edx,4),%edx
f0103845:	c1 e0 0f             	shl    $0xf,%eax
f0103848:	05 00 f0 24 f0       	add    $0xf024f000,%eax
f010384d:	89 04 95 30 60 24 f0 	mov    %eax,-0xfdb9fd0(,%edx,4)
	thiscpu->cpu_ts.ts_ss0 = GD_KD;
f0103854:	e8 86 25 00 00       	call   f0105ddf <cpunum>
f0103859:	8d 14 00             	lea    (%eax,%eax,1),%edx
f010385c:	01 c2                	add    %eax,%edx
f010385e:	01 d2                	add    %edx,%edx
f0103860:	01 c2                	add    %eax,%edx
f0103862:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103865:	66 c7 04 85 34 60 24 	movw   $0x10,-0xfdb9fcc(,%eax,4)
f010386c:	f0 10 00 
	thiscpu->cpu_ts.ts_iomb = sizeof(struct Taskstate);
f010386f:	e8 6b 25 00 00       	call   f0105ddf <cpunum>
f0103874:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0103877:	01 c2                	add    %eax,%edx
f0103879:	01 d2                	add    %edx,%edx
f010387b:	01 c2                	add    %eax,%edx
f010387d:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103880:	66 c7 04 85 92 60 24 	movw   $0x68,-0xfdb9f6e(,%eax,4)
f0103887:	f0 68 00 
	gdt[(GD_TSS0 >> 3) + cpunum()] = SEG16(STS_T32A, (uint32_t) (&(thiscpu->cpu_ts)),
f010388a:	e8 50 25 00 00       	call   f0105ddf <cpunum>
f010388f:	8d 58 05             	lea    0x5(%eax),%ebx
f0103892:	e8 48 25 00 00       	call   f0105ddf <cpunum>
f0103897:	89 c7                	mov    %eax,%edi
f0103899:	e8 41 25 00 00       	call   f0105ddf <cpunum>
f010389e:	89 c6                	mov    %eax,%esi
f01038a0:	e8 3a 25 00 00       	call   f0105ddf <cpunum>
f01038a5:	66 c7 04 dd 40 03 12 	movw   $0x67,-0xfedfcc0(,%ebx,8)
f01038ac:	f0 67 00 
f01038af:	8d 14 3f             	lea    (%edi,%edi,1),%edx
f01038b2:	01 fa                	add    %edi,%edx
f01038b4:	01 d2                	add    %edx,%edx
f01038b6:	01 fa                	add    %edi,%edx
f01038b8:	8d 14 97             	lea    (%edi,%edx,4),%edx
f01038bb:	8d 14 95 2c 60 24 f0 	lea    -0xfdb9fd4(,%edx,4),%edx
f01038c2:	66 89 14 dd 42 03 12 	mov    %dx,-0xfedfcbe(,%ebx,8)
f01038c9:	f0 
f01038ca:	8d 14 36             	lea    (%esi,%esi,1),%edx
f01038cd:	01 f2                	add    %esi,%edx
f01038cf:	01 d2                	add    %edx,%edx
f01038d1:	01 f2                	add    %esi,%edx
f01038d3:	8d 14 96             	lea    (%esi,%edx,4),%edx
f01038d6:	8d 14 95 2c 60 24 f0 	lea    -0xfdb9fd4(,%edx,4),%edx
f01038dd:	c1 ea 10             	shr    $0x10,%edx
f01038e0:	88 14 dd 44 03 12 f0 	mov    %dl,-0xfedfcbc(,%ebx,8)
f01038e7:	c6 04 dd 45 03 12 f0 	movb   $0x99,-0xfedfcbb(,%ebx,8)
f01038ee:	99 
f01038ef:	c6 04 dd 46 03 12 f0 	movb   $0x40,-0xfedfcba(,%ebx,8)
f01038f6:	40 
f01038f7:	8d 14 00             	lea    (%eax,%eax,1),%edx
f01038fa:	01 c2                	add    %eax,%edx
f01038fc:	01 d2                	add    %edx,%edx
f01038fe:	01 c2                	add    %eax,%edx
f0103900:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103903:	8d 04 85 2c 60 24 f0 	lea    -0xfdb9fd4(,%eax,4),%eax
f010390a:	c1 e8 18             	shr    $0x18,%eax
f010390d:	88 04 dd 47 03 12 f0 	mov    %al,-0xfedfcb9(,%ebx,8)
					sizeof(struct Taskstate) - 1, 0);
	gdt[(GD_TSS0 >> 3) + cpunum()].sd_s = 0;
f0103914:	e8 c6 24 00 00       	call   f0105ddf <cpunum>
f0103919:	80 24 c5 6d 03 12 f0 	andb   $0xef,-0xfedfc93(,%eax,8)
f0103920:	ef 
	ltr(GD_TSS0 + (cpunum() << 3));
f0103921:	e8 b9 24 00 00       	call   f0105ddf <cpunum>
}

static __inline void
ltr(uint16_t sel)
{
	__asm __volatile("ltr %0" : : "r" (sel));
f0103926:	8d 04 c5 28 00 00 00 	lea    0x28(,%eax,8),%eax
f010392d:	0f 00 d8             	ltr    %ax
}

static __inline void
lidt(void *p)
{
	__asm __volatile("lidt (%0)" : : "r" (p));
f0103930:	b8 ac 03 12 f0       	mov    $0xf01203ac,%eax
f0103935:	0f 01 18             	lidtl  (%eax)
	// // bottom three bits are special; we leave them 0)
	// ltr(GD_TSS0);

	// // Load the IDT
	// lidt(&idt_pd);
}
f0103938:	83 c4 0c             	add    $0xc,%esp
f010393b:	5b                   	pop    %ebx
f010393c:	5e                   	pop    %esi
f010393d:	5f                   	pop    %edi
f010393e:	5d                   	pop    %ebp
f010393f:	c3                   	ret    

f0103940 <trap_init>:
}


void
trap_init(void)
{
f0103940:	55                   	push   %ebp
f0103941:	89 e5                	mov    %esp,%ebp
f0103943:	83 ec 08             	sub    $0x8,%esp
	extern struct Segdesc gdt[];
	
	// LAB 3: Your code here.
	SETGATE(idt[T_DIVIDE], 0, GD_KT, t_divide, 0);
f0103946:	b8 d4 42 10 f0       	mov    $0xf01042d4,%eax
f010394b:	66 a3 60 52 24 f0    	mov    %ax,0xf0245260
f0103951:	66 c7 05 62 52 24 f0 	movw   $0x8,0xf0245262
f0103958:	08 00 
f010395a:	c6 05 64 52 24 f0 00 	movb   $0x0,0xf0245264
f0103961:	c6 05 65 52 24 f0 8e 	movb   $0x8e,0xf0245265
f0103968:	c1 e8 10             	shr    $0x10,%eax
f010396b:	66 a3 66 52 24 f0    	mov    %ax,0xf0245266
	SETGATE(idt[T_DEBUG], 0, GD_KT, t_debug, 0);
f0103971:	b8 de 42 10 f0       	mov    $0xf01042de,%eax
f0103976:	66 a3 68 52 24 f0    	mov    %ax,0xf0245268
f010397c:	66 c7 05 6a 52 24 f0 	movw   $0x8,0xf024526a
f0103983:	08 00 
f0103985:	c6 05 6c 52 24 f0 00 	movb   $0x0,0xf024526c
f010398c:	c6 05 6d 52 24 f0 8e 	movb   $0x8e,0xf024526d
f0103993:	c1 e8 10             	shr    $0x10,%eax
f0103996:	66 a3 6e 52 24 f0    	mov    %ax,0xf024526e
	SETGATE(idt[T_NMI], 0, GD_KT, t_nmi, 0);
f010399c:	b8 e4 42 10 f0       	mov    $0xf01042e4,%eax
f01039a1:	66 a3 70 52 24 f0    	mov    %ax,0xf0245270
f01039a7:	66 c7 05 72 52 24 f0 	movw   $0x8,0xf0245272
f01039ae:	08 00 
f01039b0:	c6 05 74 52 24 f0 00 	movb   $0x0,0xf0245274
f01039b7:	c6 05 75 52 24 f0 8e 	movb   $0x8e,0xf0245275
f01039be:	c1 e8 10             	shr    $0x10,%eax
f01039c1:	66 a3 76 52 24 f0    	mov    %ax,0xf0245276
	SETGATE(idt[T_BRKPT], 0, GD_KT, t_brkpt, 3);
f01039c7:	b8 ea 42 10 f0       	mov    $0xf01042ea,%eax
f01039cc:	66 a3 78 52 24 f0    	mov    %ax,0xf0245278
f01039d2:	66 c7 05 7a 52 24 f0 	movw   $0x8,0xf024527a
f01039d9:	08 00 
f01039db:	c6 05 7c 52 24 f0 00 	movb   $0x0,0xf024527c
f01039e2:	c6 05 7d 52 24 f0 ee 	movb   $0xee,0xf024527d
f01039e9:	c1 e8 10             	shr    $0x10,%eax
f01039ec:	66 a3 7e 52 24 f0    	mov    %ax,0xf024527e
	SETGATE(idt[T_OFLOW], 0, GD_KT, t_oflow, 0);
f01039f2:	b8 f0 42 10 f0       	mov    $0xf01042f0,%eax
f01039f7:	66 a3 80 52 24 f0    	mov    %ax,0xf0245280
f01039fd:	66 c7 05 82 52 24 f0 	movw   $0x8,0xf0245282
f0103a04:	08 00 
f0103a06:	c6 05 84 52 24 f0 00 	movb   $0x0,0xf0245284
f0103a0d:	c6 05 85 52 24 f0 8e 	movb   $0x8e,0xf0245285
f0103a14:	c1 e8 10             	shr    $0x10,%eax
f0103a17:	66 a3 86 52 24 f0    	mov    %ax,0xf0245286
	SETGATE(idt[T_BOUND], 0, GD_KT, t_bound, 0);
f0103a1d:	b8 f6 42 10 f0       	mov    $0xf01042f6,%eax
f0103a22:	66 a3 88 52 24 f0    	mov    %ax,0xf0245288
f0103a28:	66 c7 05 8a 52 24 f0 	movw   $0x8,0xf024528a
f0103a2f:	08 00 
f0103a31:	c6 05 8c 52 24 f0 00 	movb   $0x0,0xf024528c
f0103a38:	c6 05 8d 52 24 f0 8e 	movb   $0x8e,0xf024528d
f0103a3f:	c1 e8 10             	shr    $0x10,%eax
f0103a42:	66 a3 8e 52 24 f0    	mov    %ax,0xf024528e
	SETGATE(idt[T_ILLOP], 0, GD_KT, t_illop, 0);
f0103a48:	b8 fc 42 10 f0       	mov    $0xf01042fc,%eax
f0103a4d:	66 a3 90 52 24 f0    	mov    %ax,0xf0245290
f0103a53:	66 c7 05 92 52 24 f0 	movw   $0x8,0xf0245292
f0103a5a:	08 00 
f0103a5c:	c6 05 94 52 24 f0 00 	movb   $0x0,0xf0245294
f0103a63:	c6 05 95 52 24 f0 8e 	movb   $0x8e,0xf0245295
f0103a6a:	c1 e8 10             	shr    $0x10,%eax
f0103a6d:	66 a3 96 52 24 f0    	mov    %ax,0xf0245296
	SETGATE(idt[T_DEVICE], 0, GD_KT, t_device, 0);
f0103a73:	b8 02 43 10 f0       	mov    $0xf0104302,%eax
f0103a78:	66 a3 98 52 24 f0    	mov    %ax,0xf0245298
f0103a7e:	66 c7 05 9a 52 24 f0 	movw   $0x8,0xf024529a
f0103a85:	08 00 
f0103a87:	c6 05 9c 52 24 f0 00 	movb   $0x0,0xf024529c
f0103a8e:	c6 05 9d 52 24 f0 8e 	movb   $0x8e,0xf024529d
f0103a95:	c1 e8 10             	shr    $0x10,%eax
f0103a98:	66 a3 9e 52 24 f0    	mov    %ax,0xf024529e
	SETGATE(idt[T_DBLFLT], 0, GD_KT, t_dblflt, 0);
f0103a9e:	b8 08 43 10 f0       	mov    $0xf0104308,%eax
f0103aa3:	66 a3 a0 52 24 f0    	mov    %ax,0xf02452a0
f0103aa9:	66 c7 05 a2 52 24 f0 	movw   $0x8,0xf02452a2
f0103ab0:	08 00 
f0103ab2:	c6 05 a4 52 24 f0 00 	movb   $0x0,0xf02452a4
f0103ab9:	c6 05 a5 52 24 f0 8e 	movb   $0x8e,0xf02452a5
f0103ac0:	c1 e8 10             	shr    $0x10,%eax
f0103ac3:	66 a3 a6 52 24 f0    	mov    %ax,0xf02452a6
	SETGATE(idt[T_TSS], 0, GD_KT, t_tss, 0);
f0103ac9:	b8 0c 43 10 f0       	mov    $0xf010430c,%eax
f0103ace:	66 a3 b0 52 24 f0    	mov    %ax,0xf02452b0
f0103ad4:	66 c7 05 b2 52 24 f0 	movw   $0x8,0xf02452b2
f0103adb:	08 00 
f0103add:	c6 05 b4 52 24 f0 00 	movb   $0x0,0xf02452b4
f0103ae4:	c6 05 b5 52 24 f0 8e 	movb   $0x8e,0xf02452b5
f0103aeb:	c1 e8 10             	shr    $0x10,%eax
f0103aee:	66 a3 b6 52 24 f0    	mov    %ax,0xf02452b6
	SETGATE(idt[T_SEGNP], 0, GD_KT, t_segnp, 0);
f0103af4:	b8 10 43 10 f0       	mov    $0xf0104310,%eax
f0103af9:	66 a3 b8 52 24 f0    	mov    %ax,0xf02452b8
f0103aff:	66 c7 05 ba 52 24 f0 	movw   $0x8,0xf02452ba
f0103b06:	08 00 
f0103b08:	c6 05 bc 52 24 f0 00 	movb   $0x0,0xf02452bc
f0103b0f:	c6 05 bd 52 24 f0 8e 	movb   $0x8e,0xf02452bd
f0103b16:	c1 e8 10             	shr    $0x10,%eax
f0103b19:	66 a3 be 52 24 f0    	mov    %ax,0xf02452be
	SETGATE(idt[T_STACK], 0, GD_KT, t_stack, 0);
f0103b1f:	b8 14 43 10 f0       	mov    $0xf0104314,%eax
f0103b24:	66 a3 c0 52 24 f0    	mov    %ax,0xf02452c0
f0103b2a:	66 c7 05 c2 52 24 f0 	movw   $0x8,0xf02452c2
f0103b31:	08 00 
f0103b33:	c6 05 c4 52 24 f0 00 	movb   $0x0,0xf02452c4
f0103b3a:	c6 05 c5 52 24 f0 8e 	movb   $0x8e,0xf02452c5
f0103b41:	c1 e8 10             	shr    $0x10,%eax
f0103b44:	66 a3 c6 52 24 f0    	mov    %ax,0xf02452c6
	SETGATE(idt[T_GPFLT], 0, GD_KT, t_gpflt, 0);
f0103b4a:	b8 18 43 10 f0       	mov    $0xf0104318,%eax
f0103b4f:	66 a3 c8 52 24 f0    	mov    %ax,0xf02452c8
f0103b55:	66 c7 05 ca 52 24 f0 	movw   $0x8,0xf02452ca
f0103b5c:	08 00 
f0103b5e:	c6 05 cc 52 24 f0 00 	movb   $0x0,0xf02452cc
f0103b65:	c6 05 cd 52 24 f0 8e 	movb   $0x8e,0xf02452cd
f0103b6c:	c1 e8 10             	shr    $0x10,%eax
f0103b6f:	66 a3 ce 52 24 f0    	mov    %ax,0xf02452ce
	SETGATE(idt[T_PGFLT], 0, GD_KT, t_pgflt, 0);
f0103b75:	b8 1c 43 10 f0       	mov    $0xf010431c,%eax
f0103b7a:	66 a3 d0 52 24 f0    	mov    %ax,0xf02452d0
f0103b80:	66 c7 05 d2 52 24 f0 	movw   $0x8,0xf02452d2
f0103b87:	08 00 
f0103b89:	c6 05 d4 52 24 f0 00 	movb   $0x0,0xf02452d4
f0103b90:	c6 05 d5 52 24 f0 8e 	movb   $0x8e,0xf02452d5
f0103b97:	c1 e8 10             	shr    $0x10,%eax
f0103b9a:	66 a3 d6 52 24 f0    	mov    %ax,0xf02452d6
	SETGATE(idt[T_FPERR], 0, GD_KT, t_fperr, 0);
f0103ba0:	b8 20 43 10 f0       	mov    $0xf0104320,%eax
f0103ba5:	66 a3 e0 52 24 f0    	mov    %ax,0xf02452e0
f0103bab:	66 c7 05 e2 52 24 f0 	movw   $0x8,0xf02452e2
f0103bb2:	08 00 
f0103bb4:	c6 05 e4 52 24 f0 00 	movb   $0x0,0xf02452e4
f0103bbb:	c6 05 e5 52 24 f0 8e 	movb   $0x8e,0xf02452e5
f0103bc2:	c1 e8 10             	shr    $0x10,%eax
f0103bc5:	66 a3 e6 52 24 f0    	mov    %ax,0xf02452e6
	SETGATE(idt[T_ALIGN], 0, GD_KT, t_align, 0);
f0103bcb:	b8 26 43 10 f0       	mov    $0xf0104326,%eax
f0103bd0:	66 a3 e8 52 24 f0    	mov    %ax,0xf02452e8
f0103bd6:	66 c7 05 ea 52 24 f0 	movw   $0x8,0xf02452ea
f0103bdd:	08 00 
f0103bdf:	c6 05 ec 52 24 f0 00 	movb   $0x0,0xf02452ec
f0103be6:	c6 05 ed 52 24 f0 8e 	movb   $0x8e,0xf02452ed
f0103bed:	c1 e8 10             	shr    $0x10,%eax
f0103bf0:	66 a3 ee 52 24 f0    	mov    %ax,0xf02452ee
	SETGATE(idt[T_MCHK], 0, GD_KT, t_mchk, 0);
f0103bf6:	b8 2a 43 10 f0       	mov    $0xf010432a,%eax
f0103bfb:	66 a3 f0 52 24 f0    	mov    %ax,0xf02452f0
f0103c01:	66 c7 05 f2 52 24 f0 	movw   $0x8,0xf02452f2
f0103c08:	08 00 
f0103c0a:	c6 05 f4 52 24 f0 00 	movb   $0x0,0xf02452f4
f0103c11:	c6 05 f5 52 24 f0 8e 	movb   $0x8e,0xf02452f5
f0103c18:	c1 e8 10             	shr    $0x10,%eax
f0103c1b:	66 a3 f6 52 24 f0    	mov    %ax,0xf02452f6
	SETGATE(idt[T_SIMDERR], 0, GD_KT, t_simderr, 0);
f0103c21:	b8 30 43 10 f0       	mov    $0xf0104330,%eax
f0103c26:	66 a3 f8 52 24 f0    	mov    %ax,0xf02452f8
f0103c2c:	66 c7 05 fa 52 24 f0 	movw   $0x8,0xf02452fa
f0103c33:	08 00 
f0103c35:	c6 05 fc 52 24 f0 00 	movb   $0x0,0xf02452fc
f0103c3c:	c6 05 fd 52 24 f0 8e 	movb   $0x8e,0xf02452fd
f0103c43:	c1 e8 10             	shr    $0x10,%eax
f0103c46:	66 a3 fe 52 24 f0    	mov    %ax,0xf02452fe
	SETGATE(idt[T_SYSCALL], 0, GD_KT, t_syscall, 3);
f0103c4c:	b8 36 43 10 f0       	mov    $0xf0104336,%eax
f0103c51:	66 a3 e0 53 24 f0    	mov    %ax,0xf02453e0
f0103c57:	66 c7 05 e2 53 24 f0 	movw   $0x8,0xf02453e2
f0103c5e:	08 00 
f0103c60:	c6 05 e4 53 24 f0 00 	movb   $0x0,0xf02453e4
f0103c67:	c6 05 e5 53 24 f0 ee 	movb   $0xee,0xf02453e5
f0103c6e:	c1 e8 10             	shr    $0x10,%eax
f0103c71:	66 a3 e6 53 24 f0    	mov    %ax,0xf02453e6

	SETGATE(idt[IRQ_OFFSET + IRQ_TIMER], 0, GD_KT, irqtimer_handler, 0);
f0103c77:	b8 3c 43 10 f0       	mov    $0xf010433c,%eax
f0103c7c:	66 a3 60 53 24 f0    	mov    %ax,0xf0245360
f0103c82:	66 c7 05 62 53 24 f0 	movw   $0x8,0xf0245362
f0103c89:	08 00 
f0103c8b:	c6 05 64 53 24 f0 00 	movb   $0x0,0xf0245364
f0103c92:	c6 05 65 53 24 f0 8e 	movb   $0x8e,0xf0245365
f0103c99:	c1 e8 10             	shr    $0x10,%eax
f0103c9c:	66 a3 66 53 24 f0    	mov    %ax,0xf0245366
    SETGATE(idt[IRQ_OFFSET + IRQ_KBD], 0, GD_KT, irqkbd_handler, 0);
f0103ca2:	b8 42 43 10 f0       	mov    $0xf0104342,%eax
f0103ca7:	66 a3 68 53 24 f0    	mov    %ax,0xf0245368
f0103cad:	66 c7 05 6a 53 24 f0 	movw   $0x8,0xf024536a
f0103cb4:	08 00 
f0103cb6:	c6 05 6c 53 24 f0 00 	movb   $0x0,0xf024536c
f0103cbd:	c6 05 6d 53 24 f0 8e 	movb   $0x8e,0xf024536d
f0103cc4:	c1 e8 10             	shr    $0x10,%eax
f0103cc7:	66 a3 6e 53 24 f0    	mov    %ax,0xf024536e
    SETGATE(idt[IRQ_OFFSET + IRQ_SERIAL], 0, GD_KT, irqserial_handler, 0);
f0103ccd:	b8 48 43 10 f0       	mov    $0xf0104348,%eax
f0103cd2:	66 a3 80 53 24 f0    	mov    %ax,0xf0245380
f0103cd8:	66 c7 05 82 53 24 f0 	movw   $0x8,0xf0245382
f0103cdf:	08 00 
f0103ce1:	c6 05 84 53 24 f0 00 	movb   $0x0,0xf0245384
f0103ce8:	c6 05 85 53 24 f0 8e 	movb   $0x8e,0xf0245385
f0103cef:	c1 e8 10             	shr    $0x10,%eax
f0103cf2:	66 a3 86 53 24 f0    	mov    %ax,0xf0245386
    SETGATE(idt[IRQ_OFFSET + IRQ_SPURIOUS], 0, GD_KT, irqspurious_handler, 0);
f0103cf8:	b8 4e 43 10 f0       	mov    $0xf010434e,%eax
f0103cfd:	66 a3 98 53 24 f0    	mov    %ax,0xf0245398
f0103d03:	66 c7 05 9a 53 24 f0 	movw   $0x8,0xf024539a
f0103d0a:	08 00 
f0103d0c:	c6 05 9c 53 24 f0 00 	movb   $0x0,0xf024539c
f0103d13:	c6 05 9d 53 24 f0 8e 	movb   $0x8e,0xf024539d
f0103d1a:	c1 e8 10             	shr    $0x10,%eax
f0103d1d:	66 a3 9e 53 24 f0    	mov    %ax,0xf024539e
    SETGATE(idt[IRQ_OFFSET + IRQ_IDE], 0, GD_KT, irqide_handler, 0);
f0103d23:	b8 54 43 10 f0       	mov    $0xf0104354,%eax
f0103d28:	66 a3 d0 53 24 f0    	mov    %ax,0xf02453d0
f0103d2e:	66 c7 05 d2 53 24 f0 	movw   $0x8,0xf02453d2
f0103d35:	08 00 
f0103d37:	c6 05 d4 53 24 f0 00 	movb   $0x0,0xf02453d4
f0103d3e:	c6 05 d5 53 24 f0 8e 	movb   $0x8e,0xf02453d5
f0103d45:	c1 e8 10             	shr    $0x10,%eax
f0103d48:	66 a3 d6 53 24 f0    	mov    %ax,0xf02453d6
    SETGATE(idt[IRQ_OFFSET + IRQ_ERROR], 0, GD_KT, irqerror_handler, 0);
f0103d4e:	b8 5a 43 10 f0       	mov    $0xf010435a,%eax
f0103d53:	66 a3 f8 53 24 f0    	mov    %ax,0xf02453f8
f0103d59:	66 c7 05 fa 53 24 f0 	movw   $0x8,0xf02453fa
f0103d60:	08 00 
f0103d62:	c6 05 fc 53 24 f0 00 	movb   $0x0,0xf02453fc
f0103d69:	c6 05 fd 53 24 f0 8e 	movb   $0x8e,0xf02453fd
f0103d70:	c1 e8 10             	shr    $0x10,%eax
f0103d73:	66 a3 fe 53 24 f0    	mov    %ax,0xf02453fe
	// Per-CPU setup 
	trap_init_percpu();
f0103d79:	e8 a6 fa ff ff       	call   f0103824 <trap_init_percpu>
}
f0103d7e:	c9                   	leave  
f0103d7f:	c3                   	ret    

f0103d80 <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f0103d80:	55                   	push   %ebp
f0103d81:	89 e5                	mov    %esp,%ebp
f0103d83:	53                   	push   %ebx
f0103d84:	83 ec 0c             	sub    $0xc,%esp
f0103d87:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0103d8a:	ff 33                	pushl  (%ebx)
f0103d8c:	68 66 77 10 f0       	push   $0xf0107766
f0103d91:	e8 7a fa ff ff       	call   f0103810 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0103d96:	83 c4 08             	add    $0x8,%esp
f0103d99:	ff 73 04             	pushl  0x4(%ebx)
f0103d9c:	68 75 77 10 f0       	push   $0xf0107775
f0103da1:	e8 6a fa ff ff       	call   f0103810 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0103da6:	83 c4 08             	add    $0x8,%esp
f0103da9:	ff 73 08             	pushl  0x8(%ebx)
f0103dac:	68 84 77 10 f0       	push   $0xf0107784
f0103db1:	e8 5a fa ff ff       	call   f0103810 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0103db6:	83 c4 08             	add    $0x8,%esp
f0103db9:	ff 73 0c             	pushl  0xc(%ebx)
f0103dbc:	68 93 77 10 f0       	push   $0xf0107793
f0103dc1:	e8 4a fa ff ff       	call   f0103810 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0103dc6:	83 c4 08             	add    $0x8,%esp
f0103dc9:	ff 73 10             	pushl  0x10(%ebx)
f0103dcc:	68 a2 77 10 f0       	push   $0xf01077a2
f0103dd1:	e8 3a fa ff ff       	call   f0103810 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0103dd6:	83 c4 08             	add    $0x8,%esp
f0103dd9:	ff 73 14             	pushl  0x14(%ebx)
f0103ddc:	68 b1 77 10 f0       	push   $0xf01077b1
f0103de1:	e8 2a fa ff ff       	call   f0103810 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0103de6:	83 c4 08             	add    $0x8,%esp
f0103de9:	ff 73 18             	pushl  0x18(%ebx)
f0103dec:	68 c0 77 10 f0       	push   $0xf01077c0
f0103df1:	e8 1a fa ff ff       	call   f0103810 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0103df6:	83 c4 08             	add    $0x8,%esp
f0103df9:	ff 73 1c             	pushl  0x1c(%ebx)
f0103dfc:	68 cf 77 10 f0       	push   $0xf01077cf
f0103e01:	e8 0a fa ff ff       	call   f0103810 <cprintf>
}
f0103e06:	83 c4 10             	add    $0x10,%esp
f0103e09:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103e0c:	c9                   	leave  
f0103e0d:	c3                   	ret    

f0103e0e <print_trapframe>:
	// lidt(&idt_pd);
}

void
print_trapframe(struct Trapframe *tf)
{
f0103e0e:	55                   	push   %ebp
f0103e0f:	89 e5                	mov    %esp,%ebp
f0103e11:	53                   	push   %ebx
f0103e12:	83 ec 04             	sub    $0x4,%esp
f0103e15:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f0103e18:	e8 c2 1f 00 00       	call   f0105ddf <cpunum>
f0103e1d:	83 ec 04             	sub    $0x4,%esp
f0103e20:	50                   	push   %eax
f0103e21:	53                   	push   %ebx
f0103e22:	68 33 78 10 f0       	push   $0xf0107833
f0103e27:	e8 e4 f9 ff ff       	call   f0103810 <cprintf>
	print_regs(&tf->tf_regs);
f0103e2c:	89 1c 24             	mov    %ebx,(%esp)
f0103e2f:	e8 4c ff ff ff       	call   f0103d80 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0103e34:	83 c4 08             	add    $0x8,%esp
f0103e37:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f0103e3b:	50                   	push   %eax
f0103e3c:	68 51 78 10 f0       	push   $0xf0107851
f0103e41:	e8 ca f9 ff ff       	call   f0103810 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0103e46:	83 c4 08             	add    $0x8,%esp
f0103e49:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f0103e4d:	50                   	push   %eax
f0103e4e:	68 64 78 10 f0       	push   $0xf0107864
f0103e53:	e8 b8 f9 ff ff       	call   f0103810 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103e58:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
f0103e5b:	83 c4 10             	add    $0x10,%esp
f0103e5e:	83 f8 13             	cmp    $0x13,%eax
f0103e61:	77 09                	ja     f0103e6c <print_trapframe+0x5e>
		return excnames[trapno];
f0103e63:	8b 14 85 c0 7a 10 f0 	mov    -0xfef8540(,%eax,4),%edx
f0103e6a:	eb 20                	jmp    f0103e8c <print_trapframe+0x7e>
	if (trapno == T_SYSCALL)
f0103e6c:	83 f8 30             	cmp    $0x30,%eax
f0103e6f:	74 0f                	je     f0103e80 <print_trapframe+0x72>
		return "System call";
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f0103e71:	8d 50 e0             	lea    -0x20(%eax),%edx
f0103e74:	83 fa 0f             	cmp    $0xf,%edx
f0103e77:	76 0e                	jbe    f0103e87 <print_trapframe+0x79>
		return "Hardware Interrupt";
	return "(unknown trap)";
f0103e79:	ba fd 77 10 f0       	mov    $0xf01077fd,%edx
f0103e7e:	eb 0c                	jmp    f0103e8c <print_trapframe+0x7e>
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
		return excnames[trapno];
	if (trapno == T_SYSCALL)
		return "System call";
f0103e80:	ba de 77 10 f0       	mov    $0xf01077de,%edx
f0103e85:	eb 05                	jmp    f0103e8c <print_trapframe+0x7e>
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
		return "Hardware Interrupt";
f0103e87:	ba ea 77 10 f0       	mov    $0xf01077ea,%edx
{
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103e8c:	83 ec 04             	sub    $0x4,%esp
f0103e8f:	52                   	push   %edx
f0103e90:	50                   	push   %eax
f0103e91:	68 77 78 10 f0       	push   $0xf0107877
f0103e96:	e8 75 f9 ff ff       	call   f0103810 <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0103e9b:	83 c4 10             	add    $0x10,%esp
f0103e9e:	3b 1d 60 5a 24 f0    	cmp    0xf0245a60,%ebx
f0103ea4:	75 1a                	jne    f0103ec0 <print_trapframe+0xb2>
f0103ea6:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103eaa:	75 14                	jne    f0103ec0 <print_trapframe+0xb2>

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f0103eac:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f0103eaf:	83 ec 08             	sub    $0x8,%esp
f0103eb2:	50                   	push   %eax
f0103eb3:	68 89 78 10 f0       	push   $0xf0107889
f0103eb8:	e8 53 f9 ff ff       	call   f0103810 <cprintf>
f0103ebd:	83 c4 10             	add    $0x10,%esp
	cprintf("  err  0x%08x", tf->tf_err);
f0103ec0:	83 ec 08             	sub    $0x8,%esp
f0103ec3:	ff 73 2c             	pushl  0x2c(%ebx)
f0103ec6:	68 98 78 10 f0       	push   $0xf0107898
f0103ecb:	e8 40 f9 ff ff       	call   f0103810 <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f0103ed0:	83 c4 10             	add    $0x10,%esp
f0103ed3:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103ed7:	75 45                	jne    f0103f1e <print_trapframe+0x110>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f0103ed9:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f0103edc:	a8 01                	test   $0x1,%al
f0103ede:	75 07                	jne    f0103ee7 <print_trapframe+0xd9>
f0103ee0:	b9 17 78 10 f0       	mov    $0xf0107817,%ecx
f0103ee5:	eb 05                	jmp    f0103eec <print_trapframe+0xde>
f0103ee7:	b9 0c 78 10 f0       	mov    $0xf010780c,%ecx
f0103eec:	a8 02                	test   $0x2,%al
f0103eee:	75 07                	jne    f0103ef7 <print_trapframe+0xe9>
f0103ef0:	ba 29 78 10 f0       	mov    $0xf0107829,%edx
f0103ef5:	eb 05                	jmp    f0103efc <print_trapframe+0xee>
f0103ef7:	ba 23 78 10 f0       	mov    $0xf0107823,%edx
f0103efc:	a8 04                	test   $0x4,%al
f0103efe:	75 07                	jne    f0103f07 <print_trapframe+0xf9>
f0103f00:	b8 46 79 10 f0       	mov    $0xf0107946,%eax
f0103f05:	eb 05                	jmp    f0103f0c <print_trapframe+0xfe>
f0103f07:	b8 2e 78 10 f0       	mov    $0xf010782e,%eax
f0103f0c:	51                   	push   %ecx
f0103f0d:	52                   	push   %edx
f0103f0e:	50                   	push   %eax
f0103f0f:	68 a6 78 10 f0       	push   $0xf01078a6
f0103f14:	e8 f7 f8 ff ff       	call   f0103810 <cprintf>
f0103f19:	83 c4 10             	add    $0x10,%esp
f0103f1c:	eb 10                	jmp    f0103f2e <print_trapframe+0x120>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f0103f1e:	83 ec 0c             	sub    $0xc,%esp
f0103f21:	68 41 6d 10 f0       	push   $0xf0106d41
f0103f26:	e8 e5 f8 ff ff       	call   f0103810 <cprintf>
f0103f2b:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0103f2e:	83 ec 08             	sub    $0x8,%esp
f0103f31:	ff 73 30             	pushl  0x30(%ebx)
f0103f34:	68 b5 78 10 f0       	push   $0xf01078b5
f0103f39:	e8 d2 f8 ff ff       	call   f0103810 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0103f3e:	83 c4 08             	add    $0x8,%esp
f0103f41:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f0103f45:	50                   	push   %eax
f0103f46:	68 c4 78 10 f0       	push   $0xf01078c4
f0103f4b:	e8 c0 f8 ff ff       	call   f0103810 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0103f50:	83 c4 08             	add    $0x8,%esp
f0103f53:	ff 73 38             	pushl  0x38(%ebx)
f0103f56:	68 d7 78 10 f0       	push   $0xf01078d7
f0103f5b:	e8 b0 f8 ff ff       	call   f0103810 <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f0103f60:	83 c4 10             	add    $0x10,%esp
f0103f63:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0103f67:	74 25                	je     f0103f8e <print_trapframe+0x180>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f0103f69:	83 ec 08             	sub    $0x8,%esp
f0103f6c:	ff 73 3c             	pushl  0x3c(%ebx)
f0103f6f:	68 e6 78 10 f0       	push   $0xf01078e6
f0103f74:	e8 97 f8 ff ff       	call   f0103810 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0103f79:	83 c4 08             	add    $0x8,%esp
f0103f7c:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f0103f80:	50                   	push   %eax
f0103f81:	68 f5 78 10 f0       	push   $0xf01078f5
f0103f86:	e8 85 f8 ff ff       	call   f0103810 <cprintf>
f0103f8b:	83 c4 10             	add    $0x10,%esp
	}
}
f0103f8e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103f91:	c9                   	leave  
f0103f92:	c3                   	ret    

f0103f93 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f0103f93:	55                   	push   %ebp
f0103f94:	89 e5                	mov    %esp,%ebp
f0103f96:	57                   	push   %edi
f0103f97:	56                   	push   %esi
f0103f98:	53                   	push   %ebx
f0103f99:	83 ec 0c             	sub    $0xc,%esp
f0103f9c:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0103f9f:	0f 20 d6             	mov    %cr2,%esi

	// Call the environment's page fault upcall, if one exists.  Set up a
	// page fault stack frame on the user exception stack (below
	// UXSTACKTOP), then branch to curenv->env_pgfault_upcall.
	//
	if(curenv->env_pgfault_upcall){		//检查是够有 page fault upcall
f0103fa2:	e8 38 1e 00 00       	call   f0105ddf <cpunum>
f0103fa7:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0103faa:	01 c2                	add    %eax,%edx
f0103fac:	01 d2                	add    %edx,%edx
f0103fae:	01 c2                	add    %eax,%edx
f0103fb0:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103fb3:	8b 04 85 28 60 24 f0 	mov    -0xfdb9fd8(,%eax,4),%eax
f0103fba:	83 78 64 00          	cmpl   $0x0,0x64(%eax)
f0103fbe:	0f 84 8a 00 00 00    	je     f010404e <page_fault_handler+0xbb>
		struct UTrapframe *utf;
		if(tf->tf_esp >= UXSTACKTOP-PGSIZE && tf->tf_esp < UXSTACKTOP){
f0103fc4:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0103fc7:	8d 90 00 10 40 11    	lea    0x11401000(%eax),%edx
			// 出现嵌套错误直接下移32bit 然后处理
			utf = (struct UTrapframe*)(tf->tf_esp - 4 - sizeof(struct UTrapframe)); 	
		}else{
			utf = (struct UTrapframe*)(UXSTACKTOP - sizeof(struct UTrapframe));
f0103fcd:	bf cc ff bf ee       	mov    $0xeebfffcc,%edi
	// page fault stack frame on the user exception stack (below
	// UXSTACKTOP), then branch to curenv->env_pgfault_upcall.
	//
	if(curenv->env_pgfault_upcall){		//检查是够有 page fault upcall
		struct UTrapframe *utf;
		if(tf->tf_esp >= UXSTACKTOP-PGSIZE && tf->tf_esp < UXSTACKTOP){
f0103fd2:	81 fa ff 0f 00 00    	cmp    $0xfff,%edx
f0103fd8:	77 05                	ja     f0103fdf <page_fault_handler+0x4c>
			// 出现嵌套错误直接下移32bit 然后处理
			utf = (struct UTrapframe*)(tf->tf_esp - 4 - sizeof(struct UTrapframe)); 	
f0103fda:	83 e8 38             	sub    $0x38,%eax
f0103fdd:	89 c7                	mov    %eax,%edi
		}else{
			utf = (struct UTrapframe*)(UXSTACKTOP - sizeof(struct UTrapframe));
		}
		// 先检查是否有权访问
		user_mem_assert(curenv,(void*)utf,sizeof(struct UTrapframe),PTE_U|PTE_W|PTE_P);
f0103fdf:	e8 fb 1d 00 00       	call   f0105ddf <cpunum>
f0103fe4:	6a 07                	push   $0x7
f0103fe6:	6a 34                	push   $0x34
f0103fe8:	57                   	push   %edi
f0103fe9:	6b c0 74             	imul   $0x74,%eax,%eax
f0103fec:	ff b0 28 60 24 f0    	pushl  -0xfdb9fd8(%eax)
f0103ff2:	e8 78 ee ff ff       	call   f0102e6f <user_mem_assert>
		// 设置错误信息
		utf->utf_fault_va = fault_va;
f0103ff7:	89 37                	mov    %esi,(%edi)
		utf->utf_err = tf->tf_trapno;
f0103ff9:	8b 43 28             	mov    0x28(%ebx),%eax
f0103ffc:	89 fa                	mov    %edi,%edx
f0103ffe:	89 47 04             	mov    %eax,0x4(%edi)
		utf->utf_regs = tf->tf_regs;
f0104001:	8d 7f 08             	lea    0x8(%edi),%edi
f0104004:	b9 08 00 00 00       	mov    $0x8,%ecx
f0104009:	89 de                	mov    %ebx,%esi
f010400b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		utf->utf_eip = tf->tf_eip;
f010400d:	8b 43 30             	mov    0x30(%ebx),%eax
f0104010:	89 42 28             	mov    %eax,0x28(%edx)
		utf->utf_eflags = tf->tf_eflags;
f0104013:	8b 43 38             	mov    0x38(%ebx),%eax
f0104016:	89 d7                	mov    %edx,%edi
f0104018:	89 42 2c             	mov    %eax,0x2c(%edx)
		utf->utf_esp = tf->tf_esp;
f010401b:	8b 43 3c             	mov    0x3c(%ebx),%eax
f010401e:	89 42 30             	mov    %eax,0x30(%edx)
		// 修改eip跳转到页错误处理，切换栈
		tf->tf_eip = (uintptr_t)curenv->env_pgfault_upcall;
f0104021:	e8 b9 1d 00 00       	call   f0105ddf <cpunum>
f0104026:	6b c0 74             	imul   $0x74,%eax,%eax
f0104029:	8b 80 28 60 24 f0    	mov    -0xfdb9fd8(%eax),%eax
f010402f:	8b 40 64             	mov    0x64(%eax),%eax
f0104032:	89 43 30             	mov    %eax,0x30(%ebx)
		tf->tf_esp = (uintptr_t) utf;
f0104035:	89 7b 3c             	mov    %edi,0x3c(%ebx)
		env_run(curenv);
f0104038:	e8 a2 1d 00 00       	call   f0105ddf <cpunum>
f010403d:	83 c4 04             	add    $0x4,%esp
f0104040:	6b c0 74             	imul   $0x74,%eax,%eax
f0104043:	ff b0 28 60 24 f0    	pushl  -0xfdb9fd8(%eax)
f0104049:	e8 5c f5 ff ff       	call   f01035aa <env_run>
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f010404e:	8b 7b 30             	mov    0x30(%ebx),%edi
		curenv->env_id, fault_va, tf->tf_eip);
f0104051:	e8 89 1d 00 00       	call   f0105ddf <cpunum>
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0104056:	57                   	push   %edi
f0104057:	56                   	push   %esi
		curenv->env_id, fault_va, tf->tf_eip);
f0104058:	8d 14 00             	lea    (%eax,%eax,1),%edx
f010405b:	01 c2                	add    %eax,%edx
f010405d:	01 d2                	add    %edx,%edx
f010405f:	01 c2                	add    %eax,%edx
f0104061:	8d 04 90             	lea    (%eax,%edx,4),%eax
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0104064:	8b 04 85 28 60 24 f0 	mov    -0xfdb9fd8(,%eax,4),%eax
f010406b:	ff 70 48             	pushl  0x48(%eax)
f010406e:	68 90 7a 10 f0       	push   $0xf0107a90
f0104073:	e8 98 f7 ff ff       	call   f0103810 <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f0104078:	89 1c 24             	mov    %ebx,(%esp)
f010407b:	e8 8e fd ff ff       	call   f0103e0e <print_trapframe>
	env_destroy(curenv);
f0104080:	e8 5a 1d 00 00       	call   f0105ddf <cpunum>
f0104085:	83 c4 04             	add    $0x4,%esp
f0104088:	8d 14 00             	lea    (%eax,%eax,1),%edx
f010408b:	01 c2                	add    %eax,%edx
f010408d:	01 d2                	add    %edx,%edx
f010408f:	01 c2                	add    %eax,%edx
f0104091:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104094:	ff 34 85 28 60 24 f0 	pushl  -0xfdb9fd8(,%eax,4)
f010409b:	e8 4d f4 ff ff       	call   f01034ed <env_destroy>
}
f01040a0:	83 c4 10             	add    $0x10,%esp
f01040a3:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01040a6:	5b                   	pop    %ebx
f01040a7:	5e                   	pop    %esi
f01040a8:	5f                   	pop    %edi
f01040a9:	5d                   	pop    %ebp
f01040aa:	c3                   	ret    

f01040ab <trap>:
	}
}
}
void
trap(struct Trapframe *tf)
{
f01040ab:	55                   	push   %ebp
f01040ac:	89 e5                	mov    %esp,%ebp
f01040ae:	57                   	push   %edi
f01040af:	56                   	push   %esi
f01040b0:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f01040b3:	fc                   	cld    

	// Halt the CPU if some other CPU has called panic()
	extern char *panicstr;
	if (panicstr)
f01040b4:	83 3d 80 5e 24 f0 00 	cmpl   $0x0,0xf0245e80
f01040bb:	74 01                	je     f01040be <trap+0x13>
		asm volatile("hlt");
f01040bd:	f4                   	hlt    

	// Re-acqurie the big kernel lock if we were halted in
	// sched_yield()
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f01040be:	e8 1c 1d 00 00       	call   f0105ddf <cpunum>
f01040c3:	8d 14 00             	lea    (%eax,%eax,1),%edx
f01040c6:	01 c2                	add    %eax,%edx
f01040c8:	01 d2                	add    %edx,%edx
f01040ca:	01 c2                	add    %eax,%edx
f01040cc:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01040cf:	8d 14 85 20 60 24 f0 	lea    -0xfdb9fe0(,%eax,4),%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f01040d6:	b8 01 00 00 00       	mov    $0x1,%eax
f01040db:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f01040df:	83 f8 02             	cmp    $0x2,%eax
f01040e2:	75 10                	jne    f01040f4 <trap+0x49>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f01040e4:	83 ec 0c             	sub    $0xc,%esp
f01040e7:	68 c0 03 12 f0       	push   $0xf01203c0
f01040ec:	e8 5f 1f 00 00       	call   f0106050 <spin_lock>
f01040f1:	83 c4 10             	add    $0x10,%esp

static __inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	__asm __volatile("pushfl; popl %0" : "=r" (eflags));
f01040f4:	9c                   	pushf  
f01040f5:	58                   	pop    %eax
		lock_kernel();
	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f01040f6:	f6 c4 02             	test   $0x2,%ah
f01040f9:	74 19                	je     f0104114 <trap+0x69>
f01040fb:	68 08 79 10 f0       	push   $0xf0107908
f0104100:	68 5a 6a 10 f0       	push   $0xf0106a5a
f0104105:	68 40 01 00 00       	push   $0x140
f010410a:	68 21 79 10 f0       	push   $0xf0107921
f010410f:	e8 2c bf ff ff       	call   f0100040 <_panic>

	if ((tf->tf_cs & 3) == 3) {
f0104114:	66 8b 46 34          	mov    0x34(%esi),%ax
f0104118:	83 e0 03             	and    $0x3,%eax
f010411b:	66 83 f8 03          	cmp    $0x3,%ax
f010411f:	0f 85 a0 00 00 00    	jne    f01041c5 <trap+0x11a>
f0104125:	83 ec 0c             	sub    $0xc,%esp
f0104128:	68 c0 03 12 f0       	push   $0xf01203c0
f010412d:	e8 1e 1f 00 00       	call   f0106050 <spin_lock>
		// Trapped from user mode.
		// Acquire the big kernel lock before doing any
		// serious kernel work.
		// LAB 4: Your code here.
		lock_kernel();
		assert(curenv);
f0104132:	e8 a8 1c 00 00       	call   f0105ddf <cpunum>
f0104137:	6b c0 74             	imul   $0x74,%eax,%eax
f010413a:	83 c4 10             	add    $0x10,%esp
f010413d:	83 b8 28 60 24 f0 00 	cmpl   $0x0,-0xfdb9fd8(%eax)
f0104144:	75 19                	jne    f010415f <trap+0xb4>
f0104146:	68 2d 79 10 f0       	push   $0xf010792d
f010414b:	68 5a 6a 10 f0       	push   $0xf0106a5a
f0104150:	68 48 01 00 00       	push   $0x148
f0104155:	68 21 79 10 f0       	push   $0xf0107921
f010415a:	e8 e1 be ff ff       	call   f0100040 <_panic>

		// Garbage collect if current enviroment is a zombie
		if (curenv->env_status == ENV_DYING) {
f010415f:	e8 7b 1c 00 00       	call   f0105ddf <cpunum>
f0104164:	6b c0 74             	imul   $0x74,%eax,%eax
f0104167:	8b 80 28 60 24 f0    	mov    -0xfdb9fd8(%eax),%eax
f010416d:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f0104171:	75 2d                	jne    f01041a0 <trap+0xf5>
			env_free(curenv);
f0104173:	e8 67 1c 00 00       	call   f0105ddf <cpunum>
f0104178:	83 ec 0c             	sub    $0xc,%esp
f010417b:	6b c0 74             	imul   $0x74,%eax,%eax
f010417e:	ff b0 28 60 24 f0    	pushl  -0xfdb9fd8(%eax)
f0104184:	e8 ab f1 ff ff       	call   f0103334 <env_free>
			curenv = NULL;
f0104189:	e8 51 1c 00 00       	call   f0105ddf <cpunum>
f010418e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104191:	c7 80 28 60 24 f0 00 	movl   $0x0,-0xfdb9fd8(%eax)
f0104198:	00 00 00 
			sched_yield();
f010419b:	e8 cb 02 00 00       	call   f010446b <sched_yield>
		}

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f01041a0:	e8 3a 1c 00 00       	call   f0105ddf <cpunum>
f01041a5:	6b c0 74             	imul   $0x74,%eax,%eax
f01041a8:	8b 80 28 60 24 f0    	mov    -0xfdb9fd8(%eax),%eax
f01041ae:	b9 11 00 00 00       	mov    $0x11,%ecx
f01041b3:	89 c7                	mov    %eax,%edi
f01041b5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f01041b7:	e8 23 1c 00 00       	call   f0105ddf <cpunum>
f01041bc:	6b c0 74             	imul   $0x74,%eax,%eax
f01041bf:	8b b0 28 60 24 f0    	mov    -0xfdb9fd8(%eax),%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f01041c5:	89 35 60 5a 24 f0    	mov    %esi,0xf0245a60
trap_dispatch(struct Trapframe *tf)
{
	int32_t ret_code;
	// Handle processor exceptions.
	// LAB 3: Your code here.
	switch(tf->tf_trapno) {
f01041cb:	8b 46 28             	mov    0x28(%esi),%eax
f01041ce:	83 f8 0e             	cmp    $0xe,%eax
f01041d1:	74 1d                	je     f01041f0 <trap+0x145>
f01041d3:	83 f8 0e             	cmp    $0xe,%eax
f01041d6:	77 0c                	ja     f01041e4 <trap+0x139>
f01041d8:	83 f8 01             	cmp    $0x1,%eax
f01041db:	74 3a                	je     f0104217 <trap+0x16c>
f01041dd:	83 f8 03             	cmp    $0x3,%eax
f01041e0:	74 1f                	je     f0104201 <trap+0x156>
f01041e2:	eb 6c                	jmp    f0104250 <trap+0x1a5>
f01041e4:	83 f8 20             	cmp    $0x20,%eax
f01041e7:	74 5d                	je     f0104246 <trap+0x19b>
f01041e9:	83 f8 30             	cmp    $0x30,%eax
f01041ec:	74 37                	je     f0104225 <trap+0x17a>
f01041ee:	eb 60                	jmp    f0104250 <trap+0x1a5>
		case (T_PGFLT):
			page_fault_handler(tf);
f01041f0:	83 ec 0c             	sub    $0xc,%esp
f01041f3:	56                   	push   %esi
f01041f4:	e8 9a fd ff ff       	call   f0103f93 <page_fault_handler>
f01041f9:	83 c4 10             	add    $0x10,%esp
f01041fc:	e9 92 00 00 00       	jmp    f0104293 <trap+0x1e8>
			break; 
		case (T_BRKPT):
			print_trapframe(tf);
f0104201:	83 ec 0c             	sub    $0xc,%esp
f0104204:	56                   	push   %esi
f0104205:	e8 04 fc ff ff       	call   f0103e0e <print_trapframe>
			monitor(tf);		
f010420a:	89 34 24             	mov    %esi,(%esp)
f010420d:	e8 71 c7 ff ff       	call   f0100983 <monitor>
f0104212:	83 c4 10             	add    $0x10,%esp
f0104215:	eb 7c                	jmp    f0104293 <trap+0x1e8>
			break;
		case (T_DEBUG):
			monitor(tf);
f0104217:	83 ec 0c             	sub    $0xc,%esp
f010421a:	56                   	push   %esi
f010421b:	e8 63 c7 ff ff       	call   f0100983 <monitor>
f0104220:	83 c4 10             	add    $0x10,%esp
f0104223:	eb 6e                	jmp    f0104293 <trap+0x1e8>
			break;
		case (T_SYSCALL):
	//		print_trapframe(tf);
			ret_code = syscall(
f0104225:	83 ec 08             	sub    $0x8,%esp
f0104228:	ff 76 04             	pushl  0x4(%esi)
f010422b:	ff 36                	pushl  (%esi)
f010422d:	ff 76 10             	pushl  0x10(%esi)
f0104230:	ff 76 18             	pushl  0x18(%esi)
f0104233:	ff 76 14             	pushl  0x14(%esi)
f0104236:	ff 76 1c             	pushl  0x1c(%esi)
f0104239:	e8 36 03 00 00       	call   f0104574 <syscall>
					tf->tf_regs.reg_edx,
					tf->tf_regs.reg_ecx,
					tf->tf_regs.reg_ebx,
					tf->tf_regs.reg_edi,
					tf->tf_regs.reg_esi);
			tf->tf_regs.reg_eax = ret_code;
f010423e:	89 46 1c             	mov    %eax,0x1c(%esi)
f0104241:	83 c4 20             	add    $0x20,%esp
f0104244:	eb 4d                	jmp    f0104293 <trap+0x1e8>
			break;
		case IRQ_OFFSET + IRQ_TIMER:
			lapic_eoi();
f0104246:	e8 e9 1c 00 00       	call   f0105f34 <lapic_eoi>
			sched_yield();
f010424b:	e8 1b 02 00 00       	call   f010446b <sched_yield>
 		default:
			// Unexpected trap: The user process or the kernel has a bug.
			print_trapframe(tf);
f0104250:	83 ec 0c             	sub    $0xc,%esp
f0104253:	56                   	push   %esi
f0104254:	e8 b5 fb ff ff       	call   f0103e0e <print_trapframe>
			if (tf->tf_cs == GD_KT)
f0104259:	83 c4 10             	add    $0x10,%esp
f010425c:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f0104261:	75 17                	jne    f010427a <trap+0x1cf>
				panic("unhandled trap in kernel");
f0104263:	83 ec 04             	sub    $0x4,%esp
f0104266:	68 34 79 10 f0       	push   $0xf0107934
f010426b:	68 0a 01 00 00       	push   $0x10a
f0104270:	68 21 79 10 f0       	push   $0xf0107921
f0104275:	e8 c6 bd ff ff       	call   f0100040 <_panic>
			else {
				env_destroy(curenv);
f010427a:	e8 60 1b 00 00       	call   f0105ddf <cpunum>
f010427f:	83 ec 0c             	sub    $0xc,%esp
f0104282:	6b c0 74             	imul   $0x74,%eax,%eax
f0104285:	ff b0 28 60 24 f0    	pushl  -0xfdb9fd8(%eax)
f010428b:	e8 5d f2 ff ff       	call   f01034ed <env_destroy>
f0104290:	83 c4 10             	add    $0x10,%esp
	trap_dispatch(tf);

	// If we made it to this point, then no other environment was
	// scheduled, so we should return to the current environment
	// if doing so makes sense.
	if (curenv && curenv->env_status == ENV_RUNNING)
f0104293:	e8 47 1b 00 00       	call   f0105ddf <cpunum>
f0104298:	6b c0 74             	imul   $0x74,%eax,%eax
f010429b:	83 b8 28 60 24 f0 00 	cmpl   $0x0,-0xfdb9fd8(%eax)
f01042a2:	74 2a                	je     f01042ce <trap+0x223>
f01042a4:	e8 36 1b 00 00       	call   f0105ddf <cpunum>
f01042a9:	6b c0 74             	imul   $0x74,%eax,%eax
f01042ac:	8b 80 28 60 24 f0    	mov    -0xfdb9fd8(%eax),%eax
f01042b2:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f01042b6:	75 16                	jne    f01042ce <trap+0x223>
		env_run(curenv);
f01042b8:	e8 22 1b 00 00       	call   f0105ddf <cpunum>
f01042bd:	83 ec 0c             	sub    $0xc,%esp
f01042c0:	6b c0 74             	imul   $0x74,%eax,%eax
f01042c3:	ff b0 28 60 24 f0    	pushl  -0xfdb9fd8(%eax)
f01042c9:	e8 dc f2 ff ff       	call   f01035aa <env_run>
	else
		sched_yield();
f01042ce:	e8 98 01 00 00       	call   f010446b <sched_yield>
f01042d3:	90                   	nop

f01042d4 <t_divide>:
.text

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */
TRAPHANDLER_NOEC(t_divide, T_DIVIDE)
f01042d4:	6a 00                	push   $0x0
f01042d6:	6a 00                	push   $0x0
f01042d8:	e9 83 00 00 00       	jmp    f0104360 <_alltraps>
f01042dd:	90                   	nop

f01042de <t_debug>:
TRAPHANDLER_NOEC(t_debug, T_DEBUG)
f01042de:	6a 00                	push   $0x0
f01042e0:	6a 01                	push   $0x1
f01042e2:	eb 7c                	jmp    f0104360 <_alltraps>

f01042e4 <t_nmi>:
TRAPHANDLER_NOEC(t_nmi, T_NMI)
f01042e4:	6a 00                	push   $0x0
f01042e6:	6a 02                	push   $0x2
f01042e8:	eb 76                	jmp    f0104360 <_alltraps>

f01042ea <t_brkpt>:
TRAPHANDLER_NOEC(t_brkpt, T_BRKPT)
f01042ea:	6a 00                	push   $0x0
f01042ec:	6a 03                	push   $0x3
f01042ee:	eb 70                	jmp    f0104360 <_alltraps>

f01042f0 <t_oflow>:
TRAPHANDLER_NOEC(t_oflow, T_OFLOW)
f01042f0:	6a 00                	push   $0x0
f01042f2:	6a 04                	push   $0x4
f01042f4:	eb 6a                	jmp    f0104360 <_alltraps>

f01042f6 <t_bound>:
TRAPHANDLER_NOEC(t_bound, T_BOUND)
f01042f6:	6a 00                	push   $0x0
f01042f8:	6a 05                	push   $0x5
f01042fa:	eb 64                	jmp    f0104360 <_alltraps>

f01042fc <t_illop>:
TRAPHANDLER_NOEC(t_illop, T_ILLOP)
f01042fc:	6a 00                	push   $0x0
f01042fe:	6a 06                	push   $0x6
f0104300:	eb 5e                	jmp    f0104360 <_alltraps>

f0104302 <t_device>:
TRAPHANDLER_NOEC(t_device, T_DEVICE)
f0104302:	6a 00                	push   $0x0
f0104304:	6a 07                	push   $0x7
f0104306:	eb 58                	jmp    f0104360 <_alltraps>

f0104308 <t_dblflt>:
TRAPHANDLER(t_dblflt, T_DBLFLT)
f0104308:	6a 08                	push   $0x8
f010430a:	eb 54                	jmp    f0104360 <_alltraps>

f010430c <t_tss>:
TRAPHANDLER(t_tss, T_TSS)
f010430c:	6a 0a                	push   $0xa
f010430e:	eb 50                	jmp    f0104360 <_alltraps>

f0104310 <t_segnp>:
TRAPHANDLER(t_segnp, T_SEGNP)
f0104310:	6a 0b                	push   $0xb
f0104312:	eb 4c                	jmp    f0104360 <_alltraps>

f0104314 <t_stack>:
TRAPHANDLER(t_stack, T_STACK)
f0104314:	6a 0c                	push   $0xc
f0104316:	eb 48                	jmp    f0104360 <_alltraps>

f0104318 <t_gpflt>:
TRAPHANDLER(t_gpflt, T_GPFLT)
f0104318:	6a 0d                	push   $0xd
f010431a:	eb 44                	jmp    f0104360 <_alltraps>

f010431c <t_pgflt>:
TRAPHANDLER(t_pgflt, T_PGFLT)
f010431c:	6a 0e                	push   $0xe
f010431e:	eb 40                	jmp    f0104360 <_alltraps>

f0104320 <t_fperr>:
TRAPHANDLER_NOEC(t_fperr, T_FPERR)
f0104320:	6a 00                	push   $0x0
f0104322:	6a 10                	push   $0x10
f0104324:	eb 3a                	jmp    f0104360 <_alltraps>

f0104326 <t_align>:
TRAPHANDLER(t_align, T_ALIGN)
f0104326:	6a 11                	push   $0x11
f0104328:	eb 36                	jmp    f0104360 <_alltraps>

f010432a <t_mchk>:
TRAPHANDLER_NOEC(t_mchk, T_MCHK)
f010432a:	6a 00                	push   $0x0
f010432c:	6a 12                	push   $0x12
f010432e:	eb 30                	jmp    f0104360 <_alltraps>

f0104330 <t_simderr>:
TRAPHANDLER_NOEC(t_simderr, T_SIMDERR)
f0104330:	6a 00                	push   $0x0
f0104332:	6a 13                	push   $0x13
f0104334:	eb 2a                	jmp    f0104360 <_alltraps>

f0104336 <t_syscall>:

TRAPHANDLER_NOEC(t_syscall, T_SYSCALL)
f0104336:	6a 00                	push   $0x0
f0104338:	6a 30                	push   $0x30
f010433a:	eb 24                	jmp    f0104360 <_alltraps>

f010433c <irqtimer_handler>:
TRAPHANDLER_NOEC(irqtimer_handler, IRQ_OFFSET + IRQ_TIMER)
f010433c:	6a 00                	push   $0x0
f010433e:	6a 20                	push   $0x20
f0104340:	eb 1e                	jmp    f0104360 <_alltraps>

f0104342 <irqkbd_handler>:
TRAPHANDLER_NOEC(irqkbd_handler, IRQ_OFFSET + IRQ_KBD)
f0104342:	6a 00                	push   $0x0
f0104344:	6a 21                	push   $0x21
f0104346:	eb 18                	jmp    f0104360 <_alltraps>

f0104348 <irqserial_handler>:
TRAPHANDLER_NOEC(irqserial_handler, IRQ_OFFSET + IRQ_SERIAL)
f0104348:	6a 00                	push   $0x0
f010434a:	6a 24                	push   $0x24
f010434c:	eb 12                	jmp    f0104360 <_alltraps>

f010434e <irqspurious_handler>:
TRAPHANDLER_NOEC(irqspurious_handler, IRQ_OFFSET + IRQ_SPURIOUS)
f010434e:	6a 00                	push   $0x0
f0104350:	6a 27                	push   $0x27
f0104352:	eb 0c                	jmp    f0104360 <_alltraps>

f0104354 <irqide_handler>:
TRAPHANDLER_NOEC(irqide_handler, IRQ_OFFSET + IRQ_IDE)
f0104354:	6a 00                	push   $0x0
f0104356:	6a 2e                	push   $0x2e
f0104358:	eb 06                	jmp    f0104360 <_alltraps>

f010435a <irqerror_handler>:
TRAPHANDLER_NOEC(irqerror_handler, IRQ_OFFSET + IRQ_ERROR)
f010435a:	6a 00                	push   $0x0
f010435c:	6a 33                	push   $0x33
f010435e:	eb 00                	jmp    f0104360 <_alltraps>

f0104360 <_alltraps>:
/*
 * Lab 3: Your code here for _alltraps
 */
_alltraps:
	pushl %ds
f0104360:	1e                   	push   %ds
	pushl %es
f0104361:	06                   	push   %es
	pushal 
f0104362:	60                   	pusha  

	movl $GD_KD, %eax
f0104363:	b8 10 00 00 00       	mov    $0x10,%eax
	movw %ax, %ds
f0104368:	8e d8                	mov    %eax,%ds
	movw %ax, %es
f010436a:	8e c0                	mov    %eax,%es

	push %esp
f010436c:	54                   	push   %esp
	call trap	
f010436d:	e8 39 fd ff ff       	call   f01040ab <trap>

f0104372 <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f0104372:	55                   	push   %ebp
f0104373:	89 e5                	mov    %esp,%ebp
f0104375:	83 ec 08             	sub    $0x8,%esp
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
		if ((envs[i].env_status == ENV_RUNNABLE ||
f0104378:	8b 15 48 52 24 f0    	mov    0xf0245248,%edx
f010437e:	8b 42 54             	mov    0x54(%edx),%eax
f0104381:	48                   	dec    %eax
f0104382:	83 f8 02             	cmp    $0x2,%eax
f0104385:	76 48                	jbe    f01043cf <sched_halt+0x5d>
f0104387:	81 c2 d0 00 00 00    	add    $0xd0,%edx
{
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f010438d:	b9 01 00 00 00       	mov    $0x1,%ecx
		if ((envs[i].env_status == ENV_RUNNABLE ||
f0104392:	8b 02                	mov    (%edx),%eax
f0104394:	48                   	dec    %eax
f0104395:	83 f8 02             	cmp    $0x2,%eax
f0104398:	76 0e                	jbe    f01043a8 <sched_halt+0x36>
{
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f010439a:	41                   	inc    %ecx
f010439b:	83 c2 7c             	add    $0x7c,%edx
f010439e:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f01043a4:	75 ec                	jne    f0104392 <sched_halt+0x20>
f01043a6:	eb 08                	jmp    f01043b0 <sched_halt+0x3e>
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
		     envs[i].env_status == ENV_DYING))
			break;
	}
	if (i == NENV) {
f01043a8:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f01043ae:	75 1f                	jne    f01043cf <sched_halt+0x5d>
		cprintf("No runnable environments in the system!\n");
f01043b0:	83 ec 0c             	sub    $0xc,%esp
f01043b3:	68 10 7b 10 f0       	push   $0xf0107b10
f01043b8:	e8 53 f4 ff ff       	call   f0103810 <cprintf>
f01043bd:	83 c4 10             	add    $0x10,%esp
		while (1)
			monitor(NULL);
f01043c0:	83 ec 0c             	sub    $0xc,%esp
f01043c3:	6a 00                	push   $0x0
f01043c5:	e8 b9 c5 ff ff       	call   f0100983 <monitor>
f01043ca:	83 c4 10             	add    $0x10,%esp
f01043cd:	eb f1                	jmp    f01043c0 <sched_halt+0x4e>
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f01043cf:	e8 0b 1a 00 00       	call   f0105ddf <cpunum>
f01043d4:	8d 14 00             	lea    (%eax,%eax,1),%edx
f01043d7:	01 c2                	add    %eax,%edx
f01043d9:	01 d2                	add    %edx,%edx
f01043db:	01 c2                	add    %eax,%edx
f01043dd:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01043e0:	c7 04 85 28 60 24 f0 	movl   $0x0,-0xfdb9fd8(,%eax,4)
f01043e7:	00 00 00 00 
	lcr3(PADDR(kern_pgdir));
f01043eb:	a1 8c 5e 24 f0       	mov    0xf0245e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01043f0:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01043f5:	77 12                	ja     f0104409 <sched_halt+0x97>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01043f7:	50                   	push   %eax
f01043f8:	68 e8 64 10 f0       	push   $0xf01064e8
f01043fd:	6a 5a                	push   $0x5a
f01043ff:	68 39 7b 10 f0       	push   $0xf0107b39
f0104404:	e8 37 bc ff ff       	call   f0100040 <_panic>
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0104409:	05 00 00 00 10       	add    $0x10000000,%eax
f010440e:	0f 22 d8             	mov    %eax,%cr3

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f0104411:	e8 c9 19 00 00       	call   f0105ddf <cpunum>
f0104416:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0104419:	01 c2                	add    %eax,%edx
f010441b:	01 d2                	add    %edx,%edx
f010441d:	01 c2                	add    %eax,%edx
f010441f:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104422:	8d 14 85 20 60 24 f0 	lea    -0xfdb9fe0(,%eax,4),%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0104429:	b8 02 00 00 00       	mov    $0x2,%eax
f010442e:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0104432:	83 ec 0c             	sub    $0xc,%esp
f0104435:	68 c0 03 12 f0       	push   $0xf01203c0
f010443a:	e8 e8 1c 00 00       	call   f0106127 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f010443f:	f3 90                	pause  
		"movl %0, %%esp\n"
		"pushl $0\n"
		"pushl $0\n"
		"sti\n"
		"hlt\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
f0104441:	e8 99 19 00 00       	call   f0105ddf <cpunum>
f0104446:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0104449:	01 c2                	add    %eax,%edx
f010444b:	01 d2                	add    %edx,%edx
f010444d:	01 c2                	add    %eax,%edx
f010444f:	8d 04 90             	lea    (%eax,%edx,4),%eax

	// Release the big kernel lock as if we were "leaving" the kernel
	unlock_kernel();

	// Reset stack pointer, enable interrupts and then halt.
	asm volatile (
f0104452:	8b 04 85 30 60 24 f0 	mov    -0xfdb9fd0(,%eax,4),%eax
f0104459:	bd 00 00 00 00       	mov    $0x0,%ebp
f010445e:	89 c4                	mov    %eax,%esp
f0104460:	6a 00                	push   $0x0
f0104462:	6a 00                	push   $0x0
f0104464:	fb                   	sti    
f0104465:	f4                   	hlt    
		"pushl $0\n"
		"pushl $0\n"
		"sti\n"
		"hlt\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
}
f0104466:	83 c4 10             	add    $0x10,%esp
f0104469:	c9                   	leave  
f010446a:	c3                   	ret    

f010446b <sched_yield>:
void sched_halt(void);

// Choose a user environment to run and run it.
void
sched_yield(void)
{
f010446b:	55                   	push   %ebp
f010446c:	89 e5                	mov    %esp,%ebp
f010446e:	53                   	push   %ebx
f010446f:	83 ec 04             	sub    $0x4,%esp
	// another CPU (env_status == ENV_RUNNING). If there are
	// no runnable environments, simply drop through to the code
	// below to halt the cpu.

	// LAB 4: Your code here.
	idle = (curenv == NULL) ? envs : (curenv + 1);
f0104472:	e8 68 19 00 00       	call   f0105ddf <cpunum>
f0104477:	8d 14 00             	lea    (%eax,%eax,1),%edx
f010447a:	01 c2                	add    %eax,%edx
f010447c:	01 d2                	add    %edx,%edx
f010447e:	01 c2                	add    %eax,%edx
f0104480:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104483:	83 3c 85 28 60 24 f0 	cmpl   $0x0,-0xfdb9fd8(,%eax,4)
f010448a:	00 
f010448b:	74 30                	je     f01044bd <sched_yield+0x52>
f010448d:	e8 4d 19 00 00       	call   f0105ddf <cpunum>
f0104492:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0104495:	01 c2                	add    %eax,%edx
f0104497:	01 d2                	add    %edx,%edx
f0104499:	01 c2                	add    %eax,%edx
f010449b:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010449e:	8b 0c 85 28 60 24 f0 	mov    -0xfdb9fd8(,%eax,4),%ecx
f01044a5:	83 c1 7c             	add    $0x7c,%ecx
	// A flag, indicating whether find an runnable env
	bool flag = false;
	for(struct Env* e = idle; e != envs + NENV; e++)
f01044a8:	a1 48 52 24 f0       	mov    0xf0245248,%eax
f01044ad:	8d 90 00 f0 01 00    	lea    0x1f000(%eax),%edx
f01044b3:	89 d3                	mov    %edx,%ebx
f01044b5:	39 d1                	cmp    %edx,%ecx
f01044b7:	75 12                	jne    f01044cb <sched_yield+0x60>
	// another CPU (env_status == ENV_RUNNING). If there are
	// no runnable environments, simply drop through to the code
	// below to halt the cpu.

	// LAB 4: Your code here.
	idle = (curenv == NULL) ? envs : (curenv + 1);
f01044b9:	89 d1                	mov    %edx,%ecx
f01044bb:	eb 32                	jmp    f01044ef <sched_yield+0x84>
f01044bd:	8b 0d 48 52 24 f0    	mov    0xf0245248,%ecx
	// A flag, indicating whether find an runnable env
	bool flag = false;
	for(struct Env* e = idle; e != envs + NENV; e++)
f01044c3:	8d 99 00 f0 01 00    	lea    0x1f000(%ecx),%ebx
f01044c9:	89 c8                	mov    %ecx,%eax
	{
		if(e->env_status == ENV_RUNNABLE)
f01044cb:	83 79 54 02          	cmpl   $0x2,0x54(%ecx)
f01044cf:	74 0c                	je     f01044dd <sched_yield+0x72>
f01044d1:	89 ca                	mov    %ecx,%edx
f01044d3:	eb 13                	jmp    f01044e8 <sched_yield+0x7d>
f01044d5:	83 7a 54 02          	cmpl   $0x2,0x54(%edx)
f01044d9:	75 0d                	jne    f01044e8 <sched_yield+0x7d>
f01044db:	eb 02                	jmp    f01044df <sched_yield+0x74>
f01044dd:	89 ca                	mov    %ecx,%edx
		{
			flag = true;
			env_run(e);
f01044df:	83 ec 0c             	sub    $0xc,%esp
f01044e2:	52                   	push   %edx
f01044e3:	e8 c2 f0 ff ff       	call   f01035aa <env_run>

	// LAB 4: Your code here.
	idle = (curenv == NULL) ? envs : (curenv + 1);
	// A flag, indicating whether find an runnable env
	bool flag = false;
	for(struct Env* e = idle; e != envs + NENV; e++)
f01044e8:	83 c2 7c             	add    $0x7c,%edx
f01044eb:	39 da                	cmp    %ebx,%edx
f01044ed:	75 e6                	jne    f01044d5 <sched_yield+0x6a>
			break;
		}
	}
	// do the circular searching
	if(!flag)
		for(struct Env* e = envs; e != idle; e++)
f01044ef:	39 c1                	cmp    %eax,%ecx
f01044f1:	74 1e                	je     f0104511 <sched_yield+0xa6>
		{
			if(e->env_status == ENV_RUNNABLE)
f01044f3:	83 78 54 02          	cmpl   $0x2,0x54(%eax)
f01044f7:	75 11                	jne    f010450a <sched_yield+0x9f>
f01044f9:	eb 06                	jmp    f0104501 <sched_yield+0x96>
f01044fb:	83 78 54 02          	cmpl   $0x2,0x54(%eax)
f01044ff:	75 09                	jne    f010450a <sched_yield+0x9f>
			{
				flag = true;
				env_run(e);
f0104501:	83 ec 0c             	sub    $0xc,%esp
f0104504:	50                   	push   %eax
f0104505:	e8 a0 f0 ff ff       	call   f01035aa <env_run>
			break;
		}
	}
	// do the circular searching
	if(!flag)
		for(struct Env* e = envs; e != idle; e++)
f010450a:	83 c0 7c             	add    $0x7c,%eax
f010450d:	39 c8                	cmp    %ecx,%eax
f010450f:	75 ea                	jne    f01044fb <sched_yield+0x90>
				env_run(e);
				break;
			}		
		}
	// check idle for the last time, for the time it is running
	if(!flag && curenv != NULL && curenv->env_status == ENV_RUNNING)
f0104511:	e8 c9 18 00 00       	call   f0105ddf <cpunum>
f0104516:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0104519:	01 c2                	add    %eax,%edx
f010451b:	01 d2                	add    %edx,%edx
f010451d:	01 c2                	add    %eax,%edx
f010451f:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104522:	83 3c 85 28 60 24 f0 	cmpl   $0x0,-0xfdb9fd8(,%eax,4)
f0104529:	00 
f010452a:	74 3e                	je     f010456a <sched_yield+0xff>
f010452c:	e8 ae 18 00 00       	call   f0105ddf <cpunum>
f0104531:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0104534:	01 c2                	add    %eax,%edx
f0104536:	01 d2                	add    %edx,%edx
f0104538:	01 c2                	add    %eax,%edx
f010453a:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010453d:	8b 04 85 28 60 24 f0 	mov    -0xfdb9fd8(,%eax,4),%eax
f0104544:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0104548:	75 20                	jne    f010456a <sched_yield+0xff>
		env_run(curenv);
f010454a:	e8 90 18 00 00       	call   f0105ddf <cpunum>
f010454f:	83 ec 0c             	sub    $0xc,%esp
f0104552:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0104555:	01 c2                	add    %eax,%edx
f0104557:	01 d2                	add    %edx,%edx
f0104559:	01 c2                	add    %eax,%edx
f010455b:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010455e:	ff 34 85 28 60 24 f0 	pushl  -0xfdb9fd8(,%eax,4)
f0104565:	e8 40 f0 ff ff       	call   f01035aa <env_run>
	// sched_halt never returns
	if(!flag)
		sched_halt();
f010456a:	e8 03 fe ff ff       	call   f0104372 <sched_halt>

	// sched_halt never returns
		
}
f010456f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0104572:	c9                   	leave  
f0104573:	c3                   	ret    

f0104574 <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0104574:	55                   	push   %ebp
f0104575:	89 e5                	mov    %esp,%ebp
f0104577:	57                   	push   %edi
f0104578:	56                   	push   %esi
f0104579:	53                   	push   %ebx
f010457a:	83 ec 1c             	sub    $0x1c,%esp
f010457d:	8b 45 08             	mov    0x8(%ebp),%eax
	// Return any appropriate return value.
	// LAB 3: Your code here.

	//	panic("syscall not implemented");
	int32_t ret = 0;
	switch (syscallno) {
f0104580:	83 f8 0d             	cmp    $0xd,%eax
f0104583:	0f 87 1b 06 00 00    	ja     f0104ba4 <syscall+0x630>
f0104589:	ff 24 85 4c 7b 10 f0 	jmp    *-0xfef84b4(,%eax,4)
{
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not:.

	// LAB 3: Your code here.
	user_mem_assert(curenv, s, len, 0);
f0104590:	e8 4a 18 00 00       	call   f0105ddf <cpunum>
f0104595:	6a 00                	push   $0x0
f0104597:	ff 75 10             	pushl  0x10(%ebp)
f010459a:	ff 75 0c             	pushl  0xc(%ebp)
f010459d:	8d 14 00             	lea    (%eax,%eax,1),%edx
f01045a0:	01 c2                	add    %eax,%edx
f01045a2:	01 d2                	add    %edx,%edx
f01045a4:	01 c2                	add    %eax,%edx
f01045a6:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01045a9:	ff 34 85 28 60 24 f0 	pushl  -0xfdb9fd8(,%eax,4)
f01045b0:	e8 ba e8 ff ff       	call   f0102e6f <user_mem_assert>
	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f01045b5:	83 c4 0c             	add    $0xc,%esp
f01045b8:	ff 75 0c             	pushl  0xc(%ebp)
f01045bb:	ff 75 10             	pushl  0x10(%ebp)
f01045be:	68 46 7b 10 f0       	push   $0xf0107b46
f01045c3:	e8 48 f2 ff ff       	call   f0103810 <cprintf>
f01045c8:	83 c4 10             	add    $0x10,%esp
	//	panic("syscall not implemented");
	int32_t ret = 0;
	switch (syscallno) {
		case (SYS_cputs):
			sys_cputs((const char *)a1, a2);
			return 0;
f01045cb:	bb 00 00 00 00       	mov    $0x0,%ebx
f01045d0:	e9 db 05 00 00       	jmp    f0104bb0 <syscall+0x63c>
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f01045d5:	e8 57 c0 ff ff       	call   f0100631 <cons_getc>
f01045da:	89 c3                	mov    %eax,%ebx
	switch (syscallno) {
		case (SYS_cputs):
			sys_cputs((const char *)a1, a2);
			return 0;
		case (SYS_cgetc):
			return sys_cgetc();
f01045dc:	e9 cf 05 00 00       	jmp    f0104bb0 <syscall+0x63c>

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f01045e1:	e8 f9 17 00 00       	call   f0105ddf <cpunum>
f01045e6:	8d 14 00             	lea    (%eax,%eax,1),%edx
f01045e9:	01 c2                	add    %eax,%edx
f01045eb:	01 d2                	add    %edx,%edx
f01045ed:	01 c2                	add    %eax,%edx
f01045ef:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01045f2:	8b 04 85 28 60 24 f0 	mov    -0xfdb9fd8(,%eax,4),%eax
f01045f9:	8b 58 48             	mov    0x48(%eax),%ebx
			sys_cputs((const char *)a1, a2);
			return 0;
		case (SYS_cgetc):
			return sys_cgetc();
		case (SYS_getenvid):
			return sys_getenvid();
f01045fc:	e9 af 05 00 00       	jmp    f0104bb0 <syscall+0x63c>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f0104601:	83 ec 04             	sub    $0x4,%esp
f0104604:	6a 01                	push   $0x1
f0104606:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104609:	50                   	push   %eax
f010460a:	ff 75 0c             	pushl  0xc(%ebp)
f010460d:	e8 2f e9 ff ff       	call   f0102f41 <envid2env>
f0104612:	83 c4 10             	add    $0x10,%esp
f0104615:	85 c0                	test   %eax,%eax
f0104617:	78 18                	js     f0104631 <syscall+0xbd>
		return r;
	env_destroy(e);
f0104619:	83 ec 0c             	sub    $0xc,%esp
f010461c:	ff 75 e4             	pushl  -0x1c(%ebp)
f010461f:	e8 c9 ee ff ff       	call   f01034ed <env_destroy>
f0104624:	83 c4 10             	add    $0x10,%esp
	return 0;
f0104627:	bb 00 00 00 00       	mov    $0x0,%ebx
f010462c:	e9 7f 05 00 00       	jmp    f0104bb0 <syscall+0x63c>
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
		return r;
f0104631:	89 c3                	mov    %eax,%ebx
		case (SYS_cgetc):
			return sys_cgetc();
		case (SYS_getenvid):
			return sys_getenvid();
		case (SYS_env_destroy):
			return sys_env_destroy(a1);
f0104633:	e9 78 05 00 00       	jmp    f0104bb0 <syscall+0x63c>

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
	sched_yield();
f0104638:	e8 2e fe ff ff       	call   f010446b <sched_yield>
	// status is set to ENV_NOT_RUNNABLE, and the register set is copied
	// from the current environment -- but tweaked so sys_exofork
	// will appear to return 0.

	// LAB 4: Your code here.
	struct Env* store = NULL;
f010463d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	// val used to store the return value
	// Two kinds of error return value is passed directly from env_alloc
	int val;
	if((val = env_alloc(&store, curenv->env_id)) < 0)
f0104644:	e8 96 17 00 00       	call   f0105ddf <cpunum>
f0104649:	83 ec 08             	sub    $0x8,%esp
f010464c:	8d 14 00             	lea    (%eax,%eax,1),%edx
f010464f:	01 c2                	add    %eax,%edx
f0104651:	01 d2                	add    %edx,%edx
f0104653:	01 c2                	add    %eax,%edx
f0104655:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104658:	8b 04 85 28 60 24 f0 	mov    -0xfdb9fd8(,%eax,4),%eax
f010465f:	ff 70 48             	pushl  0x48(%eax)
f0104662:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104665:	50                   	push   %eax
f0104666:	e8 11 ea ff ff       	call   f010307c <env_alloc>
f010466b:	83 c4 10             	add    $0x10,%esp
f010466e:	85 c0                	test   %eax,%eax
f0104670:	78 3d                	js     f01046af <syscall+0x13b>
		return val;
	store->env_status = ENV_NOT_RUNNABLE;
f0104672:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0104675:	c7 43 54 04 00 00 00 	movl   $0x4,0x54(%ebx)
	store->env_tf = curenv->env_tf;
f010467c:	e8 5e 17 00 00       	call   f0105ddf <cpunum>
f0104681:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0104684:	01 c2                	add    %eax,%edx
f0104686:	01 d2                	add    %edx,%edx
f0104688:	01 c2                	add    %eax,%edx
f010468a:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010468d:	8b 34 85 28 60 24 f0 	mov    -0xfdb9fd8(,%eax,4),%esi
f0104694:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104699:	89 df                	mov    %ebx,%edi
f010469b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	// Child environment will return zero instead; change the eax register
	store->env_tf.tf_regs.reg_eax = 0;
f010469d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01046a0:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
	// curenv will return the envid of child environment
	return store->env_id;
f01046a7:	8b 58 48             	mov    0x48(%eax),%ebx
f01046aa:	e9 01 05 00 00       	jmp    f0104bb0 <syscall+0x63c>
	struct Env* store = NULL;
	// val used to store the return value
	// Two kinds of error return value is passed directly from env_alloc
	int val;
	if((val = env_alloc(&store, curenv->env_id)) < 0)
		return val;
f01046af:	89 c3                	mov    %eax,%ebx
			return sys_env_destroy(a1);
		case (SYS_yield):
			sys_yield();
			return 0;
		case SYS_exofork:
    		return sys_exofork();
f01046b1:	e9 fa 04 00 00       	jmp    f0104bb0 <syscall+0x63c>
//		or the caller doesn't have permission to change envid.
static int
sys_env_set_pgfault_upcall(envid_t envid, void *func)
{
	// LAB 4: Your code here.
	struct Env* store = NULL;
f01046b6:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	if (envid2env(envid,&store,1) < 0)
f01046bd:	83 ec 04             	sub    $0x4,%esp
f01046c0:	6a 01                	push   $0x1
f01046c2:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01046c5:	50                   	push   %eax
f01046c6:	ff 75 0c             	pushl  0xc(%ebp)
f01046c9:	e8 73 e8 ff ff       	call   f0102f41 <envid2env>
f01046ce:	83 c4 10             	add    $0x10,%esp
f01046d1:	85 c0                	test   %eax,%eax
f01046d3:	78 13                	js     f01046e8 <syscall+0x174>
		return -E_BAD_ENV;
	store->env_pgfault_upcall = func;
f01046d5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01046d8:	8b 7d 10             	mov    0x10(%ebp),%edi
f01046db:	89 78 64             	mov    %edi,0x64(%eax)
	return 0;
f01046de:	bb 00 00 00 00       	mov    $0x0,%ebx
f01046e3:	e9 c8 04 00 00       	jmp    f0104bb0 <syscall+0x63c>
sys_env_set_pgfault_upcall(envid_t envid, void *func)
{
	// LAB 4: Your code here.
	struct Env* store = NULL;
	if (envid2env(envid,&store,1) < 0)
		return -E_BAD_ENV;
f01046e8:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
		case SYS_exofork:
    		return sys_exofork();
			break;
		case SYS_env_set_pgfault_upcall:
			ret = sys_env_set_pgfault_upcall(a1, (void *)a2);
			return ret;
f01046ed:	e9 be 04 00 00       	jmp    f0104bb0 <syscall+0x63c>
	// Hint: Use the 'envid2env' function from kern/env.c to translate an
	// envid to a struct Env.
	// You should set envid2env's third argument to 1, which will
	// check whether the current environment has permission to set
	// envid's status.
	if(status != ENV_RUNNABLE && status != ENV_NOT_RUNNABLE)
f01046f2:	83 7d 10 02          	cmpl   $0x2,0x10(%ebp)
f01046f6:	74 06                	je     f01046fe <syscall+0x18a>
f01046f8:	83 7d 10 04          	cmpl   $0x4,0x10(%ebp)
f01046fc:	75 32                	jne    f0104730 <syscall+0x1bc>
		return -E_INVAL;
	struct Env* store = NULL;
f01046fe:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	if(envid2env(envid, &store, 1) < 0)
f0104705:	83 ec 04             	sub    $0x4,%esp
f0104708:	6a 01                	push   $0x1
f010470a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010470d:	50                   	push   %eax
f010470e:	ff 75 0c             	pushl  0xc(%ebp)
f0104711:	e8 2b e8 ff ff       	call   f0102f41 <envid2env>
f0104716:	83 c4 10             	add    $0x10,%esp
f0104719:	85 c0                	test   %eax,%eax
f010471b:	78 1d                	js     f010473a <syscall+0x1c6>
		return -E_BAD_ENV;
	// All Preconditions met, now do the assignment part
	store->env_status = status;
f010471d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104720:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0104723:	89 48 54             	mov    %ecx,0x54(%eax)
	return 0;
f0104726:	bb 00 00 00 00       	mov    $0x0,%ebx
f010472b:	e9 80 04 00 00       	jmp    f0104bb0 <syscall+0x63c>
	// envid to a struct Env.
	// You should set envid2env's third argument to 1, which will
	// check whether the current environment has permission to set
	// envid's status.
	if(status != ENV_RUNNABLE && status != ENV_NOT_RUNNABLE)
		return -E_INVAL;
f0104730:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104735:	e9 76 04 00 00       	jmp    f0104bb0 <syscall+0x63c>
	struct Env* store = NULL;
	if(envid2env(envid, &store, 1) < 0)
		return -E_BAD_ENV;
f010473a:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
		case SYS_env_set_pgfault_upcall:
			ret = sys_env_set_pgfault_upcall(a1, (void *)a2);
			return ret;
		case SYS_env_set_status:
			// call sys_env_set_status
			return sys_env_set_status((envid_t)a1, (int)a2);
f010473f:	e9 6c 04 00 00       	jmp    f0104bb0 <syscall+0x63c>
	//   parameters for correctness.
	//   If page_insert() fails, remember to free the page you
	//   allocated!
	
	// LAB 4: Your code here.
	struct Env* store = NULL;
f0104744:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	struct PageInfo* page = NULL;
	// First, do the parameter check
	// check envid
	if(envid2env(envid, &store, 1) < 0)
f010474b:	83 ec 04             	sub    $0x4,%esp
f010474e:	6a 01                	push   $0x1
f0104750:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104753:	50                   	push   %eax
f0104754:	ff 75 0c             	pushl  0xc(%ebp)
f0104757:	e8 e5 e7 ff ff       	call   f0102f41 <envid2env>
f010475c:	83 c4 10             	add    $0x10,%esp
f010475f:	85 c0                	test   %eax,%eax
f0104761:	78 53                	js     f01047b6 <syscall+0x242>
		return -E_BAD_ENV;
	// check va
	if(((uintptr_t)va >= (uintptr_t)UTOP) || (ROUNDDOWN((uintptr_t)va, PGSIZE) != (uintptr_t)va))
f0104763:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f010476a:	77 54                	ja     f01047c0 <syscall+0x24c>
f010476c:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f0104773:	75 55                	jne    f01047ca <syscall+0x256>
		return -E_INVAL;
	// check perm, is PTE_U and PTE_P already set?
	if(((perm & PTE_U) == 0) || ((perm & PTE_P) == 0) )
f0104775:	8b 45 14             	mov    0x14(%ebp),%eax
f0104778:	83 e0 05             	and    $0x5,%eax
f010477b:	83 f8 05             	cmp    $0x5,%eax
f010477e:	75 54                	jne    f01047d4 <syscall+0x260>
		return -E_INVAL;
	// is perm set with other perms that should never be set?
	// bit-and ~PTE_SYSCALL clear the four bits
	if((perm & ~PTE_SYSCALL) != 0)
f0104780:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0104783:	81 e3 f8 f1 ff ff    	and    $0xfffff1f8,%ebx
f0104789:	75 53                	jne    f01047de <syscall+0x26a>
		return -E_INVAL;
	// Now start to do the real things, first alloc a physical page
	if((page = page_alloc(ALLOC_ZERO)) == NULL)
f010478b:	83 ec 0c             	sub    $0xc,%esp
f010478e:	6a 01                	push   $0x1
f0104790:	e8 e3 c7 ff ff       	call   f0100f78 <page_alloc>
f0104795:	83 c4 10             	add    $0x10,%esp
f0104798:	85 c0                	test   %eax,%eax
f010479a:	74 4c                	je     f01047e8 <syscall+0x274>
		return -E_NO_MEM;
	// map it at given va, with given perm
	page_insert(store->env_pgdir, page, va, perm);
f010479c:	ff 75 14             	pushl  0x14(%ebp)
f010479f:	ff 75 10             	pushl  0x10(%ebp)
f01047a2:	50                   	push   %eax
f01047a3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01047a6:	ff 70 60             	pushl  0x60(%eax)
f01047a9:	e8 a9 ca ff ff       	call   f0101257 <page_insert>
f01047ae:	83 c4 10             	add    $0x10,%esp
f01047b1:	e9 fa 03 00 00       	jmp    f0104bb0 <syscall+0x63c>
	struct Env* store = NULL;
	struct PageInfo* page = NULL;
	// First, do the parameter check
	// check envid
	if(envid2env(envid, &store, 1) < 0)
		return -E_BAD_ENV;
f01047b6:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
f01047bb:	e9 f0 03 00 00       	jmp    f0104bb0 <syscall+0x63c>
	// check va
	if(((uintptr_t)va >= (uintptr_t)UTOP) || (ROUNDDOWN((uintptr_t)va, PGSIZE) != (uintptr_t)va))
		return -E_INVAL;
f01047c0:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01047c5:	e9 e6 03 00 00       	jmp    f0104bb0 <syscall+0x63c>
f01047ca:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01047cf:	e9 dc 03 00 00       	jmp    f0104bb0 <syscall+0x63c>
	// check perm, is PTE_U and PTE_P already set?
	if(((perm & PTE_U) == 0) || ((perm & PTE_P) == 0) )
		return -E_INVAL;
f01047d4:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01047d9:	e9 d2 03 00 00       	jmp    f0104bb0 <syscall+0x63c>
	// is perm set with other perms that should never be set?
	// bit-and ~PTE_SYSCALL clear the four bits
	if((perm & ~PTE_SYSCALL) != 0)
		return -E_INVAL;
f01047de:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01047e3:	e9 c8 03 00 00       	jmp    f0104bb0 <syscall+0x63c>
	// Now start to do the real things, first alloc a physical page
	if((page = page_alloc(ALLOC_ZERO)) == NULL)
		return -E_NO_MEM;
f01047e8:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
			// call sys_env_set_status
			return sys_env_set_status((envid_t)a1, (int)a2);
			break;
		case SYS_page_alloc:
			// call sys_page_alloc
			return sys_page_alloc((envid_t)a1, (void *)a2, (int)a3);
f01047ed:	e9 be 03 00 00       	jmp    f0104bb0 <syscall+0x63c>
	//   parameters for correctness.
	//   Use the third argument to page_lookup() to
	//   check the current permissions on the page.

	// LAB 4: Your code here.
	struct Env* src = NULL;
f01047f2:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	struct Env* dst = NULL;
f01047f9:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
	// First do the parameter check
	// check two envids
	if(envid2env(srcenvid, &src, 1) < 0 || envid2env(dstenvid, &dst, 1) < 0)
f0104800:	83 ec 04             	sub    $0x4,%esp
f0104803:	6a 01                	push   $0x1
f0104805:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0104808:	50                   	push   %eax
f0104809:	ff 75 0c             	pushl  0xc(%ebp)
f010480c:	e8 30 e7 ff ff       	call   f0102f41 <envid2env>
f0104811:	83 c4 10             	add    $0x10,%esp
f0104814:	85 c0                	test   %eax,%eax
f0104816:	0f 88 b1 00 00 00    	js     f01048cd <syscall+0x359>
f010481c:	83 ec 04             	sub    $0x4,%esp
f010481f:	6a 01                	push   $0x1
f0104821:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0104824:	50                   	push   %eax
f0104825:	ff 75 14             	pushl  0x14(%ebp)
f0104828:	e8 14 e7 ff ff       	call   f0102f41 <envid2env>
f010482d:	83 c4 10             	add    $0x10,%esp
f0104830:	85 c0                	test   %eax,%eax
f0104832:	0f 88 9f 00 00 00    	js     f01048d7 <syscall+0x363>
		return -E_BAD_ENV;
	// check two vas
	if((uintptr_t)srcva >= UTOP || ROUNDDOWN((uintptr_t)srcva, PGSIZE) != (uintptr_t)srcva)
f0104838:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f010483f:	0f 87 9c 00 00 00    	ja     f01048e1 <syscall+0x36d>
f0104845:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f010484c:	0f 85 99 00 00 00    	jne    f01048eb <syscall+0x377>
		return -E_INVAL;
	if((uintptr_t)dstva >= UTOP || ROUNDDOWN((uintptr_t)dstva, PGSIZE) != (uintptr_t)dstva)
f0104852:	81 7d 18 ff ff bf ee 	cmpl   $0xeebfffff,0x18(%ebp)
f0104859:	0f 87 96 00 00 00    	ja     f01048f5 <syscall+0x381>
f010485f:	f7 45 18 ff 0f 00 00 	testl  $0xfff,0x18(%ebp)
f0104866:	0f 85 93 00 00 00    	jne    f01048ff <syscall+0x38b>
		return -E_INVAL;
	// check whether srcva is mapped in src
	pte_t* pte_addr = NULL;
f010486c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	struct PageInfo* page = NULL;
	if((page = page_lookup(src->env_pgdir, srcva, &pte_addr)) == NULL)
f0104873:	83 ec 04             	sub    $0x4,%esp
f0104876:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104879:	50                   	push   %eax
f010487a:	ff 75 10             	pushl  0x10(%ebp)
f010487d:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104880:	ff 70 60             	pushl  0x60(%eax)
f0104883:	e8 d2 c8 ff ff       	call   f010115a <page_lookup>
f0104888:	83 c4 10             	add    $0x10,%esp
f010488b:	85 c0                	test   %eax,%eax
f010488d:	74 7a                	je     f0104909 <syscall+0x395>
		return -E_INVAL;
	// check whether perm is inappropriate
	if(((perm & PTE_U) == 0) || ((perm & PTE_P) == 0) || ((perm & ~PTE_SYSCALL) != 0))
f010488f:	8b 55 1c             	mov    0x1c(%ebp),%edx
f0104892:	81 e2 fd f1 ff ff    	and    $0xfffff1fd,%edx
f0104898:	83 fa 05             	cmp    $0x5,%edx
f010489b:	75 76                	jne    f0104913 <syscall+0x39f>
		return -E_INVAL;
	// check whether srcva is read-only but perm cotains PTE_W
	if(!(*pte_addr & PTE_W) && (perm & PTE_W))
f010489d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01048a0:	f6 02 02             	testb  $0x2,(%edx)
f01048a3:	75 06                	jne    f01048ab <syscall+0x337>
f01048a5:	f6 45 1c 02          	testb  $0x2,0x1c(%ebp)
f01048a9:	75 72                	jne    f010491d <syscall+0x3a9>
		return -E_INVAL;
	// Now, do the real things, since we have got the physical page
	// just use page_insert() to map it at given addr
	if(page_insert(dst->env_pgdir, page, dstva, perm) < 0)
f01048ab:	ff 75 1c             	pushl  0x1c(%ebp)
f01048ae:	ff 75 18             	pushl  0x18(%ebp)
f01048b1:	50                   	push   %eax
f01048b2:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01048b5:	ff 70 60             	pushl  0x60(%eax)
f01048b8:	e8 9a c9 ff ff       	call   f0101257 <page_insert>
f01048bd:	83 c4 10             	add    $0x10,%esp
		return -E_NO_MEM;
	return 0;
f01048c0:	c1 f8 1f             	sar    $0x1f,%eax
f01048c3:	89 c3                	mov    %eax,%ebx
f01048c5:	83 e3 fc             	and    $0xfffffffc,%ebx
f01048c8:	e9 e3 02 00 00       	jmp    f0104bb0 <syscall+0x63c>
	struct Env* src = NULL;
	struct Env* dst = NULL;
	// First do the parameter check
	// check two envids
	if(envid2env(srcenvid, &src, 1) < 0 || envid2env(dstenvid, &dst, 1) < 0)
		return -E_BAD_ENV;
f01048cd:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
f01048d2:	e9 d9 02 00 00       	jmp    f0104bb0 <syscall+0x63c>
f01048d7:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
f01048dc:	e9 cf 02 00 00       	jmp    f0104bb0 <syscall+0x63c>
	// check two vas
	if((uintptr_t)srcva >= UTOP || ROUNDDOWN((uintptr_t)srcva, PGSIZE) != (uintptr_t)srcva)
		return -E_INVAL;
f01048e1:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01048e6:	e9 c5 02 00 00       	jmp    f0104bb0 <syscall+0x63c>
f01048eb:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01048f0:	e9 bb 02 00 00       	jmp    f0104bb0 <syscall+0x63c>
	if((uintptr_t)dstva >= UTOP || ROUNDDOWN((uintptr_t)dstva, PGSIZE) != (uintptr_t)dstva)
		return -E_INVAL;
f01048f5:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01048fa:	e9 b1 02 00 00       	jmp    f0104bb0 <syscall+0x63c>
f01048ff:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104904:	e9 a7 02 00 00       	jmp    f0104bb0 <syscall+0x63c>
	// check whether srcva is mapped in src
	pte_t* pte_addr = NULL;
	struct PageInfo* page = NULL;
	if((page = page_lookup(src->env_pgdir, srcva, &pte_addr)) == NULL)
		return -E_INVAL;
f0104909:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f010490e:	e9 9d 02 00 00       	jmp    f0104bb0 <syscall+0x63c>
	// check whether perm is inappropriate
	if(((perm & PTE_U) == 0) || ((perm & PTE_P) == 0) || ((perm & ~PTE_SYSCALL) != 0))
		return -E_INVAL;
f0104913:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104918:	e9 93 02 00 00       	jmp    f0104bb0 <syscall+0x63c>
	// check whether srcva is read-only but perm cotains PTE_W
	if(!(*pte_addr & PTE_W) && (perm & PTE_W))
		return -E_INVAL;
f010491d:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104922:	e9 89 02 00 00       	jmp    f0104bb0 <syscall+0x63c>
sys_page_unmap(envid_t envid, void *va)
{
	// Hint: This function is a wrapper around page_remove().

	// LAB 4: Your code here.
	struct Env* store = NULL;
f0104927:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	if(envid2env(envid, &store, 1) < 0)
f010492e:	83 ec 04             	sub    $0x4,%esp
f0104931:	6a 01                	push   $0x1
f0104933:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104936:	50                   	push   %eax
f0104937:	ff 75 0c             	pushl  0xc(%ebp)
f010493a:	e8 02 e6 ff ff       	call   f0102f41 <envid2env>
f010493f:	83 c4 10             	add    $0x10,%esp
f0104942:	85 c0                	test   %eax,%eax
f0104944:	78 30                	js     f0104976 <syscall+0x402>
		return -E_BAD_ENV;
	// Then check va
	if((uintptr_t)va >= UTOP || ROUNDDOWN((uintptr_t)va, PGSIZE) != (uintptr_t)va)
f0104946:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f010494d:	77 31                	ja     f0104980 <syscall+0x40c>
f010494f:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f0104956:	75 32                	jne    f010498a <syscall+0x416>
		return -E_INVAL;
	// Then do the real stuff
	page_remove(store->env_pgdir, va);
f0104958:	83 ec 08             	sub    $0x8,%esp
f010495b:	ff 75 10             	pushl  0x10(%ebp)
f010495e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104961:	ff 70 60             	pushl  0x60(%eax)
f0104964:	e8 a1 c8 ff ff       	call   f010120a <page_remove>
f0104969:	83 c4 10             	add    $0x10,%esp
	// If we could execute through here, then everything is done
	return 0;
f010496c:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104971:	e9 3a 02 00 00       	jmp    f0104bb0 <syscall+0x63c>
	// Hint: This function is a wrapper around page_remove().

	// LAB 4: Your code here.
	struct Env* store = NULL;
	if(envid2env(envid, &store, 1) < 0)
		return -E_BAD_ENV;
f0104976:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
f010497b:	e9 30 02 00 00       	jmp    f0104bb0 <syscall+0x63c>
	// Then check va
	if((uintptr_t)va >= UTOP || ROUNDDOWN((uintptr_t)va, PGSIZE) != (uintptr_t)va)
		return -E_INVAL;
f0104980:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104985:	e9 26 02 00 00       	jmp    f0104bb0 <syscall+0x63c>
f010498a:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
			// call sys_page_map
			return sys_page_map((envid_t)a1, (void *)a2, (envid_t)a3, (void *)a4,(int)a5);
			break;
		case SYS_page_unmap:
			// call sys_page_unmap
			return sys_page_unmap((envid_t)a1, (void *)a2);
f010498f:	e9 1c 02 00 00       	jmp    f0104bb0 <syscall+0x63c>
{
	// LAB 4: Your code here.
	int r;
	struct Env *e;
	struct PageInfo *pp = NULL;
	pte_t *pte = NULL;
f0104994:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	if ((r = envid2env(envid, &e, 0)) < 0)
f010499b:	83 ec 04             	sub    $0x4,%esp
f010499e:	6a 00                	push   $0x0
f01049a0:	8d 45 e0             	lea    -0x20(%ebp),%eax
f01049a3:	50                   	push   %eax
f01049a4:	ff 75 0c             	pushl  0xc(%ebp)
f01049a7:	e8 95 e5 ff ff       	call   f0102f41 <envid2env>
f01049ac:	83 c4 10             	add    $0x10,%esp
f01049af:	85 c0                	test   %eax,%eax
f01049b1:	0f 88 08 01 00 00    	js     f0104abf <syscall+0x54b>
		return r;
	if(!e->env_ipc_recving)
f01049b7:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01049ba:	80 78 68 00          	cmpb   $0x0,0x68(%eax)
f01049be:	0f 84 02 01 00 00    	je     f0104ac6 <syscall+0x552>
		return -E_IPC_NOT_RECV;
	if ((uint32_t)srcva < UTOP && (uint32_t)e->env_ipc_dstva < UTOP) {
f01049c4:	81 7d 14 ff ff bf ee 	cmpl   $0xeebfffff,0x14(%ebp)
f01049cb:	0f 87 a8 00 00 00    	ja     f0104a79 <syscall+0x505>
f01049d1:	81 78 6c ff ff bf ee 	cmpl   $0xeebfffff,0x6c(%eax)
f01049d8:	0f 87 9b 00 00 00    	ja     f0104a79 <syscall+0x505>
		if(ROUNDDOWN((uint32_t)srcva, PGSIZE) != (uint32_t)srcva)
f01049de:	f7 45 14 ff 0f 00 00 	testl  $0xfff,0x14(%ebp)
f01049e5:	0f 85 e5 00 00 00    	jne    f0104ad0 <syscall+0x55c>
			return -E_INVAL;
		if((perm & (PTE_U | PTE_P)) != (PTE_U | PTE_P) || (perm & ~PTE_SYSCALL) != 0)
f01049eb:	8b 45 18             	mov    0x18(%ebp),%eax
f01049ee:	25 fd f1 ff ff       	and    $0xfffff1fd,%eax
f01049f3:	83 f8 05             	cmp    $0x5,%eax
f01049f6:	0f 85 de 00 00 00    	jne    f0104ada <syscall+0x566>
			return -E_INVAL;
		if((pp = page_lookup(curenv->env_pgdir, srcva, &pte)) == NULL)
f01049fc:	e8 de 13 00 00       	call   f0105ddf <cpunum>
f0104a01:	83 ec 04             	sub    $0x4,%esp
f0104a04:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0104a07:	52                   	push   %edx
f0104a08:	ff 75 14             	pushl  0x14(%ebp)
f0104a0b:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0104a0e:	01 c2                	add    %eax,%edx
f0104a10:	01 d2                	add    %edx,%edx
f0104a12:	01 c2                	add    %eax,%edx
f0104a14:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104a17:	8b 04 85 28 60 24 f0 	mov    -0xfdb9fd8(,%eax,4),%eax
f0104a1e:	ff 70 60             	pushl  0x60(%eax)
f0104a21:	e8 34 c7 ff ff       	call   f010115a <page_lookup>
f0104a26:	83 c4 10             	add    $0x10,%esp
f0104a29:	85 c0                	test   %eax,%eax
f0104a2b:	0f 84 b3 00 00 00    	je     f0104ae4 <syscall+0x570>
			return -E_INVAL;
		if((*pte & perm) != perm)
f0104a31:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104a34:	8b 12                	mov    (%edx),%edx
f0104a36:	89 d1                	mov    %edx,%ecx
f0104a38:	23 4d 18             	and    0x18(%ebp),%ecx
f0104a3b:	39 4d 18             	cmp    %ecx,0x18(%ebp)
f0104a3e:	0f 85 aa 00 00 00    	jne    f0104aee <syscall+0x57a>
			return -E_INVAL;
		if((perm & PTE_W) && !(*pte & PTE_W))
f0104a44:	f6 45 18 02          	testb  $0x2,0x18(%ebp)
f0104a48:	74 09                	je     f0104a53 <syscall+0x4df>
f0104a4a:	f6 c2 02             	test   $0x2,%dl
f0104a4d:	0f 84 a5 00 00 00    	je     f0104af8 <syscall+0x584>
			return -E_INVAL;
		if((r = page_insert(e->env_pgdir, pp, e->env_ipc_dstva, perm)) < 0)
f0104a53:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0104a56:	ff 75 18             	pushl  0x18(%ebp)
f0104a59:	ff 72 6c             	pushl  0x6c(%edx)
f0104a5c:	50                   	push   %eax
f0104a5d:	ff 72 60             	pushl  0x60(%edx)
f0104a60:	e8 f2 c7 ff ff       	call   f0101257 <page_insert>
f0104a65:	83 c4 10             	add    $0x10,%esp
f0104a68:	85 c0                	test   %eax,%eax
f0104a6a:	0f 88 92 00 00 00    	js     f0104b02 <syscall+0x58e>
			return r;
		e->env_ipc_perm = perm;
f0104a70:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104a73:	8b 7d 18             	mov    0x18(%ebp),%edi
f0104a76:	89 78 78             	mov    %edi,0x78(%eax)
	}
	e->env_ipc_recving = 0;
f0104a79:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0104a7c:	c6 43 68 00          	movb   $0x0,0x68(%ebx)
	e->env_ipc_from = curenv->env_id;
f0104a80:	e8 5a 13 00 00       	call   f0105ddf <cpunum>
f0104a85:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0104a88:	01 c2                	add    %eax,%edx
f0104a8a:	01 d2                	add    %edx,%edx
f0104a8c:	01 c2                	add    %eax,%edx
f0104a8e:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104a91:	8b 04 85 28 60 24 f0 	mov    -0xfdb9fd8(,%eax,4),%eax
f0104a98:	8b 40 48             	mov    0x48(%eax),%eax
f0104a9b:	89 43 74             	mov    %eax,0x74(%ebx)
	e->env_ipc_value = value;
f0104a9e:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104aa1:	8b 75 10             	mov    0x10(%ebp),%esi
f0104aa4:	89 70 70             	mov    %esi,0x70(%eax)
	e->env_status = ENV_RUNNABLE;
f0104aa7:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
	e->env_tf.tf_regs.reg_eax = 0;
f0104aae:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
	return 0;
f0104ab5:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104aba:	e9 f1 00 00 00       	jmp    f0104bb0 <syscall+0x63c>
	int r;
	struct Env *e;
	struct PageInfo *pp = NULL;
	pte_t *pte = NULL;
	if ((r = envid2env(envid, &e, 0)) < 0)
		return r;
f0104abf:	89 c3                	mov    %eax,%ebx
f0104ac1:	e9 ea 00 00 00       	jmp    f0104bb0 <syscall+0x63c>
	if(!e->env_ipc_recving)
		return -E_IPC_NOT_RECV;
f0104ac6:	bb f9 ff ff ff       	mov    $0xfffffff9,%ebx
f0104acb:	e9 e0 00 00 00       	jmp    f0104bb0 <syscall+0x63c>
	if ((uint32_t)srcva < UTOP && (uint32_t)e->env_ipc_dstva < UTOP) {
		if(ROUNDDOWN((uint32_t)srcva, PGSIZE) != (uint32_t)srcva)
			return -E_INVAL;
f0104ad0:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104ad5:	e9 d6 00 00 00       	jmp    f0104bb0 <syscall+0x63c>
		if((perm & (PTE_U | PTE_P)) != (PTE_U | PTE_P) || (perm & ~PTE_SYSCALL) != 0)
			return -E_INVAL;
f0104ada:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104adf:	e9 cc 00 00 00       	jmp    f0104bb0 <syscall+0x63c>
		if((pp = page_lookup(curenv->env_pgdir, srcva, &pte)) == NULL)
			return -E_INVAL;
f0104ae4:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104ae9:	e9 c2 00 00 00       	jmp    f0104bb0 <syscall+0x63c>
		if((*pte & perm) != perm)
			return -E_INVAL;
f0104aee:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104af3:	e9 b8 00 00 00       	jmp    f0104bb0 <syscall+0x63c>
		if((perm & PTE_W) && !(*pte & PTE_W))
			return -E_INVAL;
f0104af8:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104afd:	e9 ae 00 00 00       	jmp    f0104bb0 <syscall+0x63c>
		if((r = page_insert(e->env_pgdir, pp, e->env_ipc_dstva, perm)) < 0)
			return r;
f0104b02:	89 c3                	mov    %eax,%ebx
			// call sys_page_unmap
			return sys_page_unmap((envid_t)a1, (void *)a2);
			break;
		case SYS_ipc_try_send:
        	ret = sys_ipc_try_send((envid_t)a1, a2, (void *)a3,(int)a4);
        	return ret;
f0104b04:	e9 a7 00 00 00       	jmp    f0104bb0 <syscall+0x63c>

static int
sys_ipc_recv(void *dstva)
{
	// LAB 4: Your code here.
	if((uint32_t)dstva < UTOP)
f0104b09:	81 7d 0c ff ff bf ee 	cmpl   $0xeebfffff,0xc(%ebp)
f0104b10:	77 0d                	ja     f0104b1f <syscall+0x5ab>
		if(ROUNDDOWN((uint32_t)dstva, PGSIZE) != (uint32_t)dstva)
f0104b12:	f7 45 0c ff 0f 00 00 	testl  $0xfff,0xc(%ebp)
f0104b19:	0f 85 8c 00 00 00    	jne    f0104bab <syscall+0x637>
			return -E_INVAL;
	curenv->env_ipc_recving = 1;
f0104b1f:	e8 bb 12 00 00       	call   f0105ddf <cpunum>
f0104b24:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b27:	8b 80 28 60 24 f0    	mov    -0xfdb9fd8(%eax),%eax
f0104b2d:	c6 40 68 01          	movb   $0x1,0x68(%eax)
	curenv->env_ipc_dstva = dstva;
f0104b31:	e8 a9 12 00 00       	call   f0105ddf <cpunum>
f0104b36:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b39:	8b 80 28 60 24 f0    	mov    -0xfdb9fd8(%eax),%eax
f0104b3f:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0104b42:	89 78 6c             	mov    %edi,0x6c(%eax)
	curenv->env_status = ENV_NOT_RUNNABLE;
f0104b45:	e8 95 12 00 00       	call   f0105ddf <cpunum>
f0104b4a:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b4d:	8b 80 28 60 24 f0    	mov    -0xfdb9fd8(%eax),%eax
f0104b53:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	sched_yield();
f0104b5a:	e8 0c f9 ff ff       	call   f010446b <sched_yield>
        	return ret;
    	case SYS_ipc_recv:
        	ret = sys_ipc_recv((void *)a1);
        	return ret;
		case SYS_env_set_trapframe:
			ret = sys_env_set_trapframe((envid_t)a1, (void *)a2);
f0104b5f:	8b 75 10             	mov    0x10(%ebp),%esi
{
	// LAB 5: Your code here.
	// Remember to check whether the user has supplied us with a good
	// address!
	struct Env *theEnv;
	if(envid2env(envid, &theEnv, 1) < 0)return -E_BAD_ENV;
f0104b62:	83 ec 04             	sub    $0x4,%esp
f0104b65:	6a 01                	push   $0x1
f0104b67:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104b6a:	50                   	push   %eax
f0104b6b:	ff 75 0c             	pushl  0xc(%ebp)
f0104b6e:	e8 ce e3 ff ff       	call   f0102f41 <envid2env>
f0104b73:	83 c4 10             	add    $0x10,%esp
f0104b76:	85 c0                	test   %eax,%eax
f0104b78:	78 23                	js     f0104b9d <syscall+0x629>
	// cprintf("this tf va@0x%p\n", tf);
	user_mem_assert(theEnv, tf, sizeof(struct Trapframe), PTE_U);
f0104b7a:	6a 04                	push   $0x4
f0104b7c:	6a 44                	push   $0x44
f0104b7e:	ff 75 10             	pushl  0x10(%ebp)
f0104b81:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104b84:	e8 e6 e2 ff ff       	call   f0102e6f <user_mem_assert>
	theEnv->env_tf = *tf;
f0104b89:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104b8e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104b91:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0104b93:	83 c4 10             	add    $0x10,%esp
	return 0;
f0104b96:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104b9b:	eb 13                	jmp    f0104bb0 <syscall+0x63c>
{
	// LAB 5: Your code here.
	// Remember to check whether the user has supplied us with a good
	// address!
	struct Env *theEnv;
	if(envid2env(envid, &theEnv, 1) < 0)return -E_BAD_ENV;
f0104b9d:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
    	case SYS_ipc_recv:
        	ret = sys_ipc_recv((void *)a1);
        	return ret;
		case SYS_env_set_trapframe:
			ret = sys_env_set_trapframe((envid_t)a1, (void *)a2);
			return ret;
f0104ba2:	eb 0c                	jmp    f0104bb0 <syscall+0x63c>
		default:
			return -E_INVAL;
f0104ba4:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104ba9:	eb 05                	jmp    f0104bb0 <syscall+0x63c>
		case SYS_ipc_try_send:
        	ret = sys_ipc_try_send((envid_t)a1, a2, (void *)a3,(int)a4);
        	return ret;
    	case SYS_ipc_recv:
        	ret = sys_ipc_recv((void *)a1);
        	return ret;
f0104bab:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
			ret = sys_env_set_trapframe((envid_t)a1, (void *)a2);
			return ret;
		default:
			return -E_INVAL;
	}
}
f0104bb0:	89 d8                	mov    %ebx,%eax
f0104bb2:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104bb5:	5b                   	pop    %ebx
f0104bb6:	5e                   	pop    %esi
f0104bb7:	5f                   	pop    %edi
f0104bb8:	5d                   	pop    %ebp
f0104bb9:	c3                   	ret    

f0104bba <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0104bba:	55                   	push   %ebp
f0104bbb:	89 e5                	mov    %esp,%ebp
f0104bbd:	57                   	push   %edi
f0104bbe:	56                   	push   %esi
f0104bbf:	53                   	push   %ebx
f0104bc0:	83 ec 14             	sub    $0x14,%esp
f0104bc3:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104bc6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0104bc9:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0104bcc:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f0104bcf:	8b 1a                	mov    (%edx),%ebx
f0104bd1:	8b 01                	mov    (%ecx),%eax
f0104bd3:	89 45 f0             	mov    %eax,-0x10(%ebp)

	while (l <= r) {
f0104bd6:	39 c3                	cmp    %eax,%ebx
f0104bd8:	0f 8f 9b 00 00 00    	jg     f0104c79 <stab_binsearch+0xbf>
f0104bde:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
		int true_m = (l + r) / 2, m = true_m;
f0104be5:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104be8:	01 d8                	add    %ebx,%eax
f0104bea:	89 c6                	mov    %eax,%esi
f0104bec:	c1 ee 1f             	shr    $0x1f,%esi
f0104bef:	01 c6                	add    %eax,%esi
f0104bf1:	d1 fe                	sar    %esi

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0104bf3:	39 de                	cmp    %ebx,%esi
f0104bf5:	0f 8c c7 00 00 00    	jl     f0104cc2 <stab_binsearch+0x108>
f0104bfb:	8d 04 36             	lea    (%esi,%esi,1),%eax
f0104bfe:	01 f0                	add    %esi,%eax
f0104c00:	c1 e0 02             	shl    $0x2,%eax
f0104c03:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104c06:	0f b6 54 01 04       	movzbl 0x4(%ecx,%eax,1),%edx
f0104c0b:	39 d7                	cmp    %edx,%edi
f0104c0d:	0f 84 b4 00 00 00    	je     f0104cc7 <stab_binsearch+0x10d>
f0104c13:	8d 54 01 f8          	lea    -0x8(%ecx,%eax,1),%edx
f0104c17:	89 f0                	mov    %esi,%eax
			m--;
f0104c19:	48                   	dec    %eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0104c1a:	39 d8                	cmp    %ebx,%eax
f0104c1c:	0f 8c a0 00 00 00    	jl     f0104cc2 <stab_binsearch+0x108>
f0104c22:	0f b6 0a             	movzbl (%edx),%ecx
f0104c25:	83 ea 0c             	sub    $0xc,%edx
f0104c28:	39 f9                	cmp    %edi,%ecx
f0104c2a:	75 ed                	jne    f0104c19 <stab_binsearch+0x5f>
f0104c2c:	e9 98 00 00 00       	jmp    f0104cc9 <stab_binsearch+0x10f>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f0104c31:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0104c34:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0104c36:	8d 5e 01             	lea    0x1(%esi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104c39:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104c40:	eb 28                	jmp    f0104c6a <stab_binsearch+0xb0>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0104c42:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0104c45:	76 12                	jbe    f0104c59 <stab_binsearch+0x9f>
			*region_right = m - 1;
f0104c47:	48                   	dec    %eax
f0104c48:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104c4b:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0104c4e:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104c50:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104c57:	eb 11                	jmp    f0104c6a <stab_binsearch+0xb0>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0104c59:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104c5c:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f0104c5e:	ff 45 0c             	incl   0xc(%ebp)
f0104c61:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104c63:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0104c6a:	39 5d f0             	cmp    %ebx,-0x10(%ebp)
f0104c6d:	0f 8d 72 ff ff ff    	jge    f0104be5 <stab_binsearch+0x2b>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0104c73:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0104c77:	75 0d                	jne    f0104c86 <stab_binsearch+0xcc>
		*region_right = *region_left - 1;
f0104c79:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104c7c:	8b 00                	mov    (%eax),%eax
f0104c7e:	48                   	dec    %eax
f0104c7f:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0104c82:	89 07                	mov    %eax,(%edi)
f0104c84:	eb 5d                	jmp    f0104ce3 <stab_binsearch+0x129>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104c86:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104c89:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0104c8b:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104c8e:	8b 16                	mov    (%esi),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104c90:	39 d0                	cmp    %edx,%eax
f0104c92:	7e 27                	jle    f0104cbb <stab_binsearch+0x101>
		     l > *region_left && stabs[l].n_type != type;
f0104c94:	8d 0c 00             	lea    (%eax,%eax,1),%ecx
f0104c97:	01 c1                	add    %eax,%ecx
f0104c99:	c1 e1 02             	shl    $0x2,%ecx
f0104c9c:	8b 75 ec             	mov    -0x14(%ebp),%esi
f0104c9f:	0f b6 5c 0e 04       	movzbl 0x4(%esi,%ecx,1),%ebx
f0104ca4:	39 df                	cmp    %ebx,%edi
f0104ca6:	74 13                	je     f0104cbb <stab_binsearch+0x101>
f0104ca8:	8d 4c 0e f8          	lea    -0x8(%esi,%ecx,1),%ecx
		     l--)
f0104cac:	48                   	dec    %eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104cad:	39 d0                	cmp    %edx,%eax
f0104caf:	7e 0a                	jle    f0104cbb <stab_binsearch+0x101>
		     l > *region_left && stabs[l].n_type != type;
f0104cb1:	0f b6 19             	movzbl (%ecx),%ebx
f0104cb4:	83 e9 0c             	sub    $0xc,%ecx
f0104cb7:	39 df                	cmp    %ebx,%edi
f0104cb9:	75 f1                	jne    f0104cac <stab_binsearch+0xf2>
		     l--)
			/* do nothing */;
		*region_left = l;
f0104cbb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104cbe:	89 07                	mov    %eax,(%edi)
	}
}
f0104cc0:	eb 21                	jmp    f0104ce3 <stab_binsearch+0x129>

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0104cc2:	8d 5e 01             	lea    0x1(%esi),%ebx
			continue;
f0104cc5:	eb a3                	jmp    f0104c6a <stab_binsearch+0xb0>
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f0104cc7:	89 f0                	mov    %esi,%eax
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0104cc9:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0104ccc:	01 c2                	add    %eax,%edx
f0104cce:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104cd1:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0104cd5:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0104cd8:	0f 82 53 ff ff ff    	jb     f0104c31 <stab_binsearch+0x77>
f0104cde:	e9 5f ff ff ff       	jmp    f0104c42 <stab_binsearch+0x88>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f0104ce3:	83 c4 14             	add    $0x14,%esp
f0104ce6:	5b                   	pop    %ebx
f0104ce7:	5e                   	pop    %esi
f0104ce8:	5f                   	pop    %edi
f0104ce9:	5d                   	pop    %ebp
f0104cea:	c3                   	ret    

f0104ceb <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0104ceb:	55                   	push   %ebp
f0104cec:	89 e5                	mov    %esp,%ebp
f0104cee:	57                   	push   %edi
f0104cef:	56                   	push   %esi
f0104cf0:	53                   	push   %ebx
f0104cf1:	83 ec 3c             	sub    $0x3c,%esp
f0104cf4:	8b 7d 08             	mov    0x8(%ebp),%edi
f0104cf7:	8b 75 0c             	mov    0xc(%ebp),%esi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0104cfa:	c7 06 84 7b 10 f0    	movl   $0xf0107b84,(%esi)
	info->eip_line = 0;
f0104d00:	c7 46 04 00 00 00 00 	movl   $0x0,0x4(%esi)
	info->eip_fn_name = "<unknown>";
f0104d07:	c7 46 08 84 7b 10 f0 	movl   $0xf0107b84,0x8(%esi)
	info->eip_fn_namelen = 9;
f0104d0e:	c7 46 0c 09 00 00 00 	movl   $0x9,0xc(%esi)
	info->eip_fn_addr = addr;
f0104d15:	89 7e 10             	mov    %edi,0x10(%esi)
	info->eip_fn_narg = 0;
f0104d18:	c7 46 14 00 00 00 00 	movl   $0x0,0x14(%esi)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0104d1f:	81 ff ff ff 7f ef    	cmp    $0xef7fffff,%edi
f0104d25:	77 21                	ja     f0104d48 <debuginfo_eip+0x5d>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.

		stabs = usd->stabs;
f0104d27:	a1 00 00 20 00       	mov    0x200000,%eax
f0104d2c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		stab_end = usd->stab_end;
f0104d2f:	a1 04 00 20 00       	mov    0x200004,%eax
		stabstr = usd->stabstr;
f0104d34:	8b 1d 08 00 20 00    	mov    0x200008,%ebx
f0104d3a:	89 5d cc             	mov    %ebx,-0x34(%ebp)
		stabstr_end = usd->stabstr_end;
f0104d3d:	8b 1d 0c 00 20 00    	mov    0x20000c,%ebx
f0104d43:	89 5d d0             	mov    %ebx,-0x30(%ebp)
f0104d46:	eb 1a                	jmp    f0104d62 <debuginfo_eip+0x77>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f0104d48:	c7 45 d0 07 55 11 f0 	movl   $0xf0115507,-0x30(%ebp)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f0104d4f:	c7 45 cc 99 1e 11 f0 	movl   $0xf0111e99,-0x34(%ebp)
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f0104d56:	b8 98 1e 11 f0       	mov    $0xf0111e98,%eax
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f0104d5b:	c7 45 d4 30 81 10 f0 	movl   $0xf0108130,-0x2c(%ebp)
		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0104d62:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0104d65:	39 4d cc             	cmp    %ecx,-0x34(%ebp)
f0104d68:	0f 83 6b 01 00 00    	jae    f0104ed9 <debuginfo_eip+0x1ee>
f0104d6e:	80 79 ff 00          	cmpb   $0x0,-0x1(%ecx)
f0104d72:	0f 85 68 01 00 00    	jne    f0104ee0 <debuginfo_eip+0x1f5>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0104d78:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0104d7f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0104d82:	29 d8                	sub    %ebx,%eax
f0104d84:	c1 f8 02             	sar    $0x2,%eax
f0104d87:	8d 14 80             	lea    (%eax,%eax,4),%edx
f0104d8a:	8d 14 90             	lea    (%eax,%edx,4),%edx
f0104d8d:	8d 0c 90             	lea    (%eax,%edx,4),%ecx
f0104d90:	89 ca                	mov    %ecx,%edx
f0104d92:	c1 e2 08             	shl    $0x8,%edx
f0104d95:	01 d1                	add    %edx,%ecx
f0104d97:	89 ca                	mov    %ecx,%edx
f0104d99:	c1 e2 10             	shl    $0x10,%edx
f0104d9c:	01 ca                	add    %ecx,%edx
f0104d9e:	01 d2                	add    %edx,%edx
f0104da0:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
f0104da4:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0104da7:	57                   	push   %edi
f0104da8:	6a 64                	push   $0x64
f0104daa:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0104dad:	89 c1                	mov    %eax,%ecx
f0104daf:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0104db2:	89 d8                	mov    %ebx,%eax
f0104db4:	e8 01 fe ff ff       	call   f0104bba <stab_binsearch>
	if (lfile == 0)
f0104db9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104dbc:	83 c4 08             	add    $0x8,%esp
f0104dbf:	85 c0                	test   %eax,%eax
f0104dc1:	0f 84 20 01 00 00    	je     f0104ee7 <debuginfo_eip+0x1fc>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0104dc7:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0104dca:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104dcd:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0104dd0:	57                   	push   %edi
f0104dd1:	6a 24                	push   $0x24
f0104dd3:	8d 45 d8             	lea    -0x28(%ebp),%eax
f0104dd6:	89 c1                	mov    %eax,%ecx
f0104dd8:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0104ddb:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
f0104dde:	89 d8                	mov    %ebx,%eax
f0104de0:	e8 d5 fd ff ff       	call   f0104bba <stab_binsearch>

	if (lfun <= rfun) {
f0104de5:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0104de8:	83 c4 08             	add    $0x8,%esp
f0104deb:	3b 5d d8             	cmp    -0x28(%ebp),%ebx
f0104dee:	7f 26                	jg     f0104e16 <debuginfo_eip+0x12b>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0104df0:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
f0104df3:	01 d8                	add    %ebx,%eax
f0104df5:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0104df8:	8d 14 87             	lea    (%edi,%eax,4),%edx
f0104dfb:	8b 02                	mov    (%edx),%eax
f0104dfd:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0104e00:	8b 7d cc             	mov    -0x34(%ebp),%edi
f0104e03:	29 f9                	sub    %edi,%ecx
f0104e05:	39 c8                	cmp    %ecx,%eax
f0104e07:	73 05                	jae    f0104e0e <debuginfo_eip+0x123>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0104e09:	01 f8                	add    %edi,%eax
f0104e0b:	89 46 08             	mov    %eax,0x8(%esi)
		info->eip_fn_addr = stabs[lfun].n_value;
f0104e0e:	8b 42 08             	mov    0x8(%edx),%eax
f0104e11:	89 46 10             	mov    %eax,0x10(%esi)
f0104e14:	eb 06                	jmp    f0104e1c <debuginfo_eip+0x131>
		lline = lfun;
		rline = rfun;
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0104e16:	89 7e 10             	mov    %edi,0x10(%esi)
		lline = lfile;
f0104e19:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0104e1c:	83 ec 08             	sub    $0x8,%esp
f0104e1f:	6a 3a                	push   $0x3a
f0104e21:	ff 76 08             	pushl  0x8(%esi)
f0104e24:	e8 16 09 00 00       	call   f010573f <strfind>
f0104e29:	2b 46 08             	sub    0x8(%esi),%eax
f0104e2c:	89 46 0c             	mov    %eax,0xc(%esi)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0104e2f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104e32:	83 c4 10             	add    $0x10,%esp
f0104e35:	39 fb                	cmp    %edi,%ebx
f0104e37:	7c 63                	jl     f0104e9c <debuginfo_eip+0x1b1>
	       && stabs[lline].n_type != N_SOL
f0104e39:	8d 14 1b             	lea    (%ebx,%ebx,1),%edx
f0104e3c:	01 da                	add    %ebx,%edx
f0104e3e:	c1 e2 02             	shl    $0x2,%edx
f0104e41:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0104e44:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0104e47:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
f0104e4a:	8a 41 04             	mov    0x4(%ecx),%al
f0104e4d:	88 45 c7             	mov    %al,-0x39(%ebp)
f0104e50:	3c 84                	cmp    $0x84,%al
f0104e52:	74 2d                	je     f0104e81 <debuginfo_eip+0x196>
f0104e54:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0104e57:	8d 54 10 f8          	lea    -0x8(%eax,%edx,1),%edx
f0104e5b:	83 c1 08             	add    $0x8,%ecx
f0104e5e:	8a 45 c7             	mov    -0x39(%ebp),%al
f0104e61:	eb 11                	jmp    f0104e74 <debuginfo_eip+0x189>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f0104e63:	4b                   	dec    %ebx
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0104e64:	39 fb                	cmp    %edi,%ebx
f0104e66:	7c 34                	jl     f0104e9c <debuginfo_eip+0x1b1>
	       && stabs[lline].n_type != N_SOL
f0104e68:	8a 02                	mov    (%edx),%al
f0104e6a:	83 ea 0c             	sub    $0xc,%edx
f0104e6d:	83 e9 0c             	sub    $0xc,%ecx
f0104e70:	3c 84                	cmp    $0x84,%al
f0104e72:	74 0d                	je     f0104e81 <debuginfo_eip+0x196>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0104e74:	3c 64                	cmp    $0x64,%al
f0104e76:	75 eb                	jne    f0104e63 <debuginfo_eip+0x178>
f0104e78:	83 39 00             	cmpl   $0x0,(%ecx)
f0104e7b:	74 e6                	je     f0104e63 <debuginfo_eip+0x178>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0104e7d:	39 df                	cmp    %ebx,%edi
f0104e7f:	7f 1b                	jg     f0104e9c <debuginfo_eip+0x1b1>
f0104e81:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
f0104e84:	01 c3                	add    %eax,%ebx
f0104e86:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0104e89:	8b 14 98             	mov    (%eax,%ebx,4),%edx
f0104e8c:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0104e8f:	8b 7d cc             	mov    -0x34(%ebp),%edi
f0104e92:	29 f8                	sub    %edi,%eax
f0104e94:	39 c2                	cmp    %eax,%edx
f0104e96:	73 04                	jae    f0104e9c <debuginfo_eip+0x1b1>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0104e98:	01 fa                	add    %edi,%edx
f0104e9a:	89 16                	mov    %edx,(%esi)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0104e9c:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104e9f:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f0104ea2:	39 c8                	cmp    %ecx,%eax
f0104ea4:	7d 48                	jge    f0104eee <debuginfo_eip+0x203>
		for (lline = lfun + 1;
f0104ea6:	40                   	inc    %eax
f0104ea7:	39 c1                	cmp    %eax,%ecx
f0104ea9:	7e 4a                	jle    f0104ef5 <debuginfo_eip+0x20a>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0104eab:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0104eae:	01 c2                	add    %eax,%edx
f0104eb0:	c1 e2 02             	shl    $0x2,%edx
f0104eb3:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0104eb6:	80 7c 17 04 a0       	cmpb   $0xa0,0x4(%edi,%edx,1)
f0104ebb:	75 3f                	jne    f0104efc <debuginfo_eip+0x211>
f0104ebd:	8d 54 17 10          	lea    0x10(%edi,%edx,1),%edx
		     lline++)
			info->eip_fn_narg++;
f0104ec1:	ff 46 14             	incl   0x14(%esi)
	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
f0104ec4:	40                   	inc    %eax


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0104ec5:	39 c1                	cmp    %eax,%ecx
f0104ec7:	7e 3a                	jle    f0104f03 <debuginfo_eip+0x218>
f0104ec9:	83 c2 0c             	add    $0xc,%edx
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0104ecc:	80 7a f4 a0          	cmpb   $0xa0,-0xc(%edx)
f0104ed0:	74 ef                	je     f0104ec1 <debuginfo_eip+0x1d6>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104ed2:	b8 00 00 00 00       	mov    $0x0,%eax
f0104ed7:	eb 2f                	jmp    f0104f08 <debuginfo_eip+0x21d>
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0104ed9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104ede:	eb 28                	jmp    f0104f08 <debuginfo_eip+0x21d>
f0104ee0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104ee5:	eb 21                	jmp    f0104f08 <debuginfo_eip+0x21d>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f0104ee7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104eec:	eb 1a                	jmp    f0104f08 <debuginfo_eip+0x21d>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104eee:	b8 00 00 00 00       	mov    $0x0,%eax
f0104ef3:	eb 13                	jmp    f0104f08 <debuginfo_eip+0x21d>
f0104ef5:	b8 00 00 00 00       	mov    $0x0,%eax
f0104efa:	eb 0c                	jmp    f0104f08 <debuginfo_eip+0x21d>
f0104efc:	b8 00 00 00 00       	mov    $0x0,%eax
f0104f01:	eb 05                	jmp    f0104f08 <debuginfo_eip+0x21d>
f0104f03:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104f08:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104f0b:	5b                   	pop    %ebx
f0104f0c:	5e                   	pop    %esi
f0104f0d:	5f                   	pop    %edi
f0104f0e:	5d                   	pop    %ebp
f0104f0f:	c3                   	ret    

f0104f10 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0104f10:	55                   	push   %ebp
f0104f11:	89 e5                	mov    %esp,%ebp
f0104f13:	57                   	push   %edi
f0104f14:	56                   	push   %esi
f0104f15:	53                   	push   %ebx
f0104f16:	83 ec 1c             	sub    $0x1c,%esp
f0104f19:	89 c6                	mov    %eax,%esi
f0104f1b:	89 d7                	mov    %edx,%edi
f0104f1d:	8b 45 08             	mov    0x8(%ebp),%eax
f0104f20:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104f23:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104f26:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0104f29:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0104f2c:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104f31:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0104f34:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0104f37:	39 d3                	cmp    %edx,%ebx
f0104f39:	72 11                	jb     f0104f4c <printnum+0x3c>
f0104f3b:	39 45 10             	cmp    %eax,0x10(%ebp)
f0104f3e:	76 0c                	jbe    f0104f4c <printnum+0x3c>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0104f40:	8b 45 14             	mov    0x14(%ebp),%eax
f0104f43:	8d 58 ff             	lea    -0x1(%eax),%ebx
f0104f46:	85 db                	test   %ebx,%ebx
f0104f48:	7f 37                	jg     f0104f81 <printnum+0x71>
f0104f4a:	eb 44                	jmp    f0104f90 <printnum+0x80>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0104f4c:	83 ec 0c             	sub    $0xc,%esp
f0104f4f:	ff 75 18             	pushl  0x18(%ebp)
f0104f52:	8b 45 14             	mov    0x14(%ebp),%eax
f0104f55:	48                   	dec    %eax
f0104f56:	50                   	push   %eax
f0104f57:	ff 75 10             	pushl  0x10(%ebp)
f0104f5a:	83 ec 08             	sub    $0x8,%esp
f0104f5d:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104f60:	ff 75 e0             	pushl  -0x20(%ebp)
f0104f63:	ff 75 dc             	pushl  -0x24(%ebp)
f0104f66:	ff 75 d8             	pushl  -0x28(%ebp)
f0104f69:	e8 b6 12 00 00       	call   f0106224 <__udivdi3>
f0104f6e:	83 c4 18             	add    $0x18,%esp
f0104f71:	52                   	push   %edx
f0104f72:	50                   	push   %eax
f0104f73:	89 fa                	mov    %edi,%edx
f0104f75:	89 f0                	mov    %esi,%eax
f0104f77:	e8 94 ff ff ff       	call   f0104f10 <printnum>
f0104f7c:	83 c4 20             	add    $0x20,%esp
f0104f7f:	eb 0f                	jmp    f0104f90 <printnum+0x80>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0104f81:	83 ec 08             	sub    $0x8,%esp
f0104f84:	57                   	push   %edi
f0104f85:	ff 75 18             	pushl  0x18(%ebp)
f0104f88:	ff d6                	call   *%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0104f8a:	83 c4 10             	add    $0x10,%esp
f0104f8d:	4b                   	dec    %ebx
f0104f8e:	75 f1                	jne    f0104f81 <printnum+0x71>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0104f90:	83 ec 08             	sub    $0x8,%esp
f0104f93:	57                   	push   %edi
f0104f94:	83 ec 04             	sub    $0x4,%esp
f0104f97:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104f9a:	ff 75 e0             	pushl  -0x20(%ebp)
f0104f9d:	ff 75 dc             	pushl  -0x24(%ebp)
f0104fa0:	ff 75 d8             	pushl  -0x28(%ebp)
f0104fa3:	e8 8c 13 00 00       	call   f0106334 <__umoddi3>
f0104fa8:	83 c4 14             	add    $0x14,%esp
f0104fab:	0f be 80 8e 7b 10 f0 	movsbl -0xfef8472(%eax),%eax
f0104fb2:	50                   	push   %eax
f0104fb3:	ff d6                	call   *%esi
}
f0104fb5:	83 c4 10             	add    $0x10,%esp
f0104fb8:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104fbb:	5b                   	pop    %ebx
f0104fbc:	5e                   	pop    %esi
f0104fbd:	5f                   	pop    %edi
f0104fbe:	5d                   	pop    %ebp
f0104fbf:	c3                   	ret    

f0104fc0 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0104fc0:	55                   	push   %ebp
f0104fc1:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0104fc3:	83 fa 01             	cmp    $0x1,%edx
f0104fc6:	7e 0e                	jle    f0104fd6 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0104fc8:	8b 10                	mov    (%eax),%edx
f0104fca:	8d 4a 08             	lea    0x8(%edx),%ecx
f0104fcd:	89 08                	mov    %ecx,(%eax)
f0104fcf:	8b 02                	mov    (%edx),%eax
f0104fd1:	8b 52 04             	mov    0x4(%edx),%edx
f0104fd4:	eb 22                	jmp    f0104ff8 <getuint+0x38>
	else if (lflag)
f0104fd6:	85 d2                	test   %edx,%edx
f0104fd8:	74 10                	je     f0104fea <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0104fda:	8b 10                	mov    (%eax),%edx
f0104fdc:	8d 4a 04             	lea    0x4(%edx),%ecx
f0104fdf:	89 08                	mov    %ecx,(%eax)
f0104fe1:	8b 02                	mov    (%edx),%eax
f0104fe3:	ba 00 00 00 00       	mov    $0x0,%edx
f0104fe8:	eb 0e                	jmp    f0104ff8 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0104fea:	8b 10                	mov    (%eax),%edx
f0104fec:	8d 4a 04             	lea    0x4(%edx),%ecx
f0104fef:	89 08                	mov    %ecx,(%eax)
f0104ff1:	8b 02                	mov    (%edx),%eax
f0104ff3:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0104ff8:	5d                   	pop    %ebp
f0104ff9:	c3                   	ret    

f0104ffa <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0104ffa:	55                   	push   %ebp
f0104ffb:	89 e5                	mov    %esp,%ebp
f0104ffd:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0105000:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
f0105003:	8b 10                	mov    (%eax),%edx
f0105005:	3b 50 04             	cmp    0x4(%eax),%edx
f0105008:	73 0a                	jae    f0105014 <sprintputch+0x1a>
		*b->buf++ = ch;
f010500a:	8d 4a 01             	lea    0x1(%edx),%ecx
f010500d:	89 08                	mov    %ecx,(%eax)
f010500f:	8b 45 08             	mov    0x8(%ebp),%eax
f0105012:	88 02                	mov    %al,(%edx)
}
f0105014:	5d                   	pop    %ebp
f0105015:	c3                   	ret    

f0105016 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0105016:	55                   	push   %ebp
f0105017:	89 e5                	mov    %esp,%ebp
f0105019:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f010501c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f010501f:	50                   	push   %eax
f0105020:	ff 75 10             	pushl  0x10(%ebp)
f0105023:	ff 75 0c             	pushl  0xc(%ebp)
f0105026:	ff 75 08             	pushl  0x8(%ebp)
f0105029:	e8 05 00 00 00       	call   f0105033 <vprintfmt>
	va_end(ap);
}
f010502e:	83 c4 10             	add    $0x10,%esp
f0105031:	c9                   	leave  
f0105032:	c3                   	ret    

f0105033 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0105033:	55                   	push   %ebp
f0105034:	89 e5                	mov    %esp,%ebp
f0105036:	57                   	push   %edi
f0105037:	56                   	push   %esi
f0105038:	53                   	push   %ebx
f0105039:	83 ec 2c             	sub    $0x2c,%esp
f010503c:	8b 7d 08             	mov    0x8(%ebp),%edi
f010503f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105042:	eb 03                	jmp    f0105047 <vprintfmt+0x14>
			break;

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
			for (fmt--; fmt[-1] != '%'; fmt--)
f0105044:	89 75 10             	mov    %esi,0x10(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {    //遍历输入的第一个参数，即输出信息的格式，先把格式字符串中'%'之前的字符一个个输出，因为它们前面没有'%'，所以它们就是要直接显示在屏幕上的
f0105047:	8b 45 10             	mov    0x10(%ebp),%eax
f010504a:	8d 70 01             	lea    0x1(%eax),%esi
f010504d:	0f b6 00             	movzbl (%eax),%eax
f0105050:	83 f8 25             	cmp    $0x25,%eax
f0105053:	74 25                	je     f010507a <vprintfmt+0x47>
			if (ch == '\0')									//当然中间如果遇到'\0'，代表这个字符串的访问结束
f0105055:	85 c0                	test   %eax,%eax
f0105057:	75 0d                	jne    f0105066 <vprintfmt+0x33>
f0105059:	e9 b5 03 00 00       	jmp    f0105413 <vprintfmt+0x3e0>
f010505e:	85 c0                	test   %eax,%eax
f0105060:	0f 84 ad 03 00 00    	je     f0105413 <vprintfmt+0x3e0>
				return;
			putch(ch, putdat);								//调用putch函数，把一个字符ch输出到putdat指针所指向的地址中所存放的值对应的地址处
f0105066:	83 ec 08             	sub    $0x8,%esp
f0105069:	53                   	push   %ebx
f010506a:	50                   	push   %eax
f010506b:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {    //遍历输入的第一个参数，即输出信息的格式，先把格式字符串中'%'之前的字符一个个输出，因为它们前面没有'%'，所以它们就是要直接显示在屏幕上的
f010506d:	46                   	inc    %esi
f010506e:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
f0105072:	83 c4 10             	add    $0x10,%esp
f0105075:	83 f8 25             	cmp    $0x25,%eax
f0105078:	75 e4                	jne    f010505e <vprintfmt+0x2b>
			if (width < 0)									//代表有小数点，但是小数点前面并没有数字，比如'%.6f'这种情况，此时代表整数部分全部显示
				width = 0;			
			goto reswitch;

		case '#':
			altflag = 1;
f010507a:	c6 45 e3 20          	movb   $0x20,-0x1d(%ebp)
f010507e:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0105085:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f010508c:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
f0105093:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
f010509a:	eb 07                	jmp    f01050a3 <vprintfmt+0x70>
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
f010509c:	8b 75 10             	mov    0x10(%ebp),%esi

		// flag to pad on the right
		case '-':											//%后面的'-'代表要进行左对齐输出，右边填空格，如果省略代表右对齐
			padc = '-';										//如果有这个字符代表左对齐，则把对齐方式标志位变为'-'
f010509f:	c6 45 e3 2d          	movb   $0x2d,-0x1d(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
f01050a3:	8d 46 01             	lea    0x1(%esi),%eax
f01050a6:	89 45 10             	mov    %eax,0x10(%ebp)
f01050a9:	0f b6 16             	movzbl (%esi),%edx
f01050ac:	8a 06                	mov    (%esi),%al
f01050ae:	83 e8 23             	sub    $0x23,%eax
f01050b1:	3c 55                	cmp    $0x55,%al
f01050b3:	0f 87 03 03 00 00    	ja     f01053bc <vprintfmt+0x389>
f01050b9:	0f b6 c0             	movzbl %al,%eax
f01050bc:	ff 24 85 e0 7c 10 f0 	jmp    *-0xfef8320(,%eax,4)
f01050c3:	8b 75 10             	mov    0x10(%ebp),%esi
			padc = '-';										//如果有这个字符代表左对齐，则把对齐方式标志位变为'-'
			goto reswitch;									//处理下一个字符

		// flag to pad with 0's instead of spaces
		case '0':											//0--有0表示进行对齐输出时填0,如省略表示填入空格，并且如果为0，则一定是右对齐
			padc = '0';										//对其方式标志位变为0
f01050c6:	c6 45 e3 30          	movb   $0x30,-0x1d(%ebp)
f01050ca:	eb d7                	jmp    f01050a3 <vprintfmt+0x70>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {					//把遇到的位数字符串转换为真实的位数，比如输入的'%40'，代表有效位数为40位，下面的循环就是把precesion的值设置为40
				precision = precision * 10 + ch - '0';
f01050cc:	8d 42 d0             	lea    -0x30(%edx),%eax
f01050cf:	89 c1                	mov    %eax,%ecx
f01050d1:	89 45 d0             	mov    %eax,-0x30(%ebp)
				ch = *fmt;
f01050d4:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
f01050d8:	8d 50 d0             	lea    -0x30(%eax),%edx
f01050db:	83 fa 09             	cmp    $0x9,%edx
f01050de:	77 51                	ja     f0105131 <vprintfmt+0xfe>
f01050e0:	8b 75 10             	mov    0x10(%ebp),%esi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {					//把遇到的位数字符串转换为真实的位数，比如输入的'%40'，代表有效位数为40位，下面的循环就是把precesion的值设置为40
f01050e3:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
f01050e4:	8d 14 89             	lea    (%ecx,%ecx,4),%edx
f01050e7:	01 d2                	add    %edx,%edx
f01050e9:	8d 4c 10 d0          	lea    -0x30(%eax,%edx,1),%ecx
				ch = *fmt;
f01050ed:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
f01050f0:	8d 50 d0             	lea    -0x30(%eax),%edx
f01050f3:	83 fa 09             	cmp    $0x9,%edx
f01050f6:	76 eb                	jbe    f01050e3 <vprintfmt+0xb0>
f01050f8:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f01050fb:	eb 37                	jmp    f0105134 <vprintfmt+0x101>
					break;
			}
			goto process_precision;							//跳转到process_precistion子过程

		case '*':											//*--代表有效数字的位数也是由输入参数指定的，比如printf("%*.*f", 10, 2, n)，其中10,2就是用来指定显示的有效数字位数的
			precision = va_arg(ap, int);
f01050fd:	8b 45 14             	mov    0x14(%ebp),%eax
f0105100:	8d 50 04             	lea    0x4(%eax),%edx
f0105103:	89 55 14             	mov    %edx,0x14(%ebp)
f0105106:	8b 00                	mov    (%eax),%eax
f0105108:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
f010510b:	8b 75 10             	mov    0x10(%ebp),%esi
			}
			goto process_precision;							//跳转到process_precistion子过程

		case '*':											//*--代表有效数字的位数也是由输入参数指定的，比如printf("%*.*f", 10, 2, n)，其中10,2就是用来指定显示的有效数字位数的
			precision = va_arg(ap, int);
			goto process_precision;
f010510e:	eb 24                	jmp    f0105134 <vprintfmt+0x101>
f0105110:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0105114:	79 07                	jns    f010511d <vprintfmt+0xea>
f0105116:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
f010511d:	8b 75 10             	mov    0x10(%ebp),%esi
f0105120:	eb 81                	jmp    f01050a3 <vprintfmt+0x70>
f0105122:	8b 75 10             	mov    0x10(%ebp),%esi
			if (width < 0)									//代表有小数点，但是小数点前面并没有数字，比如'%.6f'这种情况，此时代表整数部分全部显示
				width = 0;			
			goto reswitch;

		case '#':
			altflag = 1;
f0105125:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f010512c:	e9 72 ff ff ff       	jmp    f01050a3 <vprintfmt+0x70>
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
f0105131:	8b 75 10             	mov    0x10(%ebp),%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:									//处理输出精度，把width字段赋值为刚刚计算出来的precision值，所以width应该是整数部分的有效数字位数
			if (width < 0)
f0105134:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0105138:	0f 89 65 ff ff ff    	jns    f01050a3 <vprintfmt+0x70>
				width = precision, precision = -1;
f010513e:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0105141:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105144:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f010514b:	e9 53 ff ff ff       	jmp    f01050a3 <vprintfmt+0x70>
			goto reswitch;

		// long flag (doubled for long long)				
		case 'l':											//如果遇到'l'，代表应该是输入long类型，如果有两个'l'代表long long
			lflag++;										//此时把lflag++
f0105150:	ff 45 d4             	incl   -0x2c(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
f0105153:	8b 75 10             	mov    0x10(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)				
		case 'l':											//如果遇到'l'，代表应该是输入long类型，如果有两个'l'代表long long
			lflag++;										//此时把lflag++
			goto reswitch;
f0105156:	e9 48 ff ff ff       	jmp    f01050a3 <vprintfmt+0x70>

		// character
		case 'c':											//如果是'c'代表显示一个字符
			putch(va_arg(ap, int), putdat);					//调用输出一个字符到内存的函数putch
f010515b:	8b 45 14             	mov    0x14(%ebp),%eax
f010515e:	8d 50 04             	lea    0x4(%eax),%edx
f0105161:	89 55 14             	mov    %edx,0x14(%ebp)
f0105164:	83 ec 08             	sub    $0x8,%esp
f0105167:	53                   	push   %ebx
f0105168:	ff 30                	pushl  (%eax)
f010516a:	ff d7                	call   *%edi
			break;
f010516c:	83 c4 10             	add    $0x10,%esp
f010516f:	e9 d3 fe ff ff       	jmp    f0105047 <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0105174:	8b 45 14             	mov    0x14(%ebp),%eax
f0105177:	8d 50 04             	lea    0x4(%eax),%edx
f010517a:	89 55 14             	mov    %edx,0x14(%ebp)
f010517d:	8b 00                	mov    (%eax),%eax
f010517f:	85 c0                	test   %eax,%eax
f0105181:	79 02                	jns    f0105185 <vprintfmt+0x152>
f0105183:	f7 d8                	neg    %eax
f0105185:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0105187:	83 f8 0f             	cmp    $0xf,%eax
f010518a:	7f 0b                	jg     f0105197 <vprintfmt+0x164>
f010518c:	8b 04 85 40 7e 10 f0 	mov    -0xfef81c0(,%eax,4),%eax
f0105193:	85 c0                	test   %eax,%eax
f0105195:	75 15                	jne    f01051ac <vprintfmt+0x179>
				printfmt(putch, putdat, "error %d", err);
f0105197:	52                   	push   %edx
f0105198:	68 a6 7b 10 f0       	push   $0xf0107ba6
f010519d:	53                   	push   %ebx
f010519e:	57                   	push   %edi
f010519f:	e8 72 fe ff ff       	call   f0105016 <printfmt>
f01051a4:	83 c4 10             	add    $0x10,%esp
f01051a7:	e9 9b fe ff ff       	jmp    f0105047 <vprintfmt+0x14>
			else
				printfmt(putch, putdat, "%s", p);
f01051ac:	50                   	push   %eax
f01051ad:	68 6c 6a 10 f0       	push   $0xf0106a6c
f01051b2:	53                   	push   %ebx
f01051b3:	57                   	push   %edi
f01051b4:	e8 5d fe ff ff       	call   f0105016 <printfmt>
f01051b9:	83 c4 10             	add    $0x10,%esp
f01051bc:	e9 86 fe ff ff       	jmp    f0105047 <vprintfmt+0x14>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f01051c1:	8b 45 14             	mov    0x14(%ebp),%eax
f01051c4:	8d 50 04             	lea    0x4(%eax),%edx
f01051c7:	89 55 14             	mov    %edx,0x14(%ebp)
f01051ca:	8b 00                	mov    (%eax),%eax
f01051cc:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01051cf:	85 c0                	test   %eax,%eax
f01051d1:	75 07                	jne    f01051da <vprintfmt+0x1a7>
				p = "(null)";
f01051d3:	c7 45 d4 9f 7b 10 f0 	movl   $0xf0107b9f,-0x2c(%ebp)
			if (width > 0 && padc != '-')
f01051da:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01051dd:	85 f6                	test   %esi,%esi
f01051df:	0f 8e fb 01 00 00    	jle    f01053e0 <vprintfmt+0x3ad>
f01051e5:	80 7d e3 2d          	cmpb   $0x2d,-0x1d(%ebp)
f01051e9:	0f 84 09 02 00 00    	je     f01053f8 <vprintfmt+0x3c5>
				for (width -= strnlen(p, precision); width > 0; width--)
f01051ef:	83 ec 08             	sub    $0x8,%esp
f01051f2:	ff 75 d0             	pushl  -0x30(%ebp)
f01051f5:	ff 75 d4             	pushl  -0x2c(%ebp)
f01051f8:	e8 b1 03 00 00       	call   f01055ae <strnlen>
f01051fd:	89 f1                	mov    %esi,%ecx
f01051ff:	29 c1                	sub    %eax,%ecx
f0105201:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f0105204:	83 c4 10             	add    $0x10,%esp
f0105207:	85 c9                	test   %ecx,%ecx
f0105209:	0f 8e d1 01 00 00    	jle    f01053e0 <vprintfmt+0x3ad>
					putch(padc, putdat);
f010520f:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
f0105213:	83 ec 08             	sub    $0x8,%esp
f0105216:	53                   	push   %ebx
f0105217:	56                   	push   %esi
f0105218:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f010521a:	83 c4 10             	add    $0x10,%esp
f010521d:	ff 4d e4             	decl   -0x1c(%ebp)
f0105220:	75 f1                	jne    f0105213 <vprintfmt+0x1e0>
f0105222:	e9 b9 01 00 00       	jmp    f01053e0 <vprintfmt+0x3ad>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0105227:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f010522b:	74 19                	je     f0105246 <vprintfmt+0x213>
f010522d:	0f be c0             	movsbl %al,%eax
f0105230:	83 e8 20             	sub    $0x20,%eax
f0105233:	83 f8 5e             	cmp    $0x5e,%eax
f0105236:	76 0e                	jbe    f0105246 <vprintfmt+0x213>
					putch('?', putdat);
f0105238:	83 ec 08             	sub    $0x8,%esp
f010523b:	53                   	push   %ebx
f010523c:	6a 3f                	push   $0x3f
f010523e:	ff 55 08             	call   *0x8(%ebp)
f0105241:	83 c4 10             	add    $0x10,%esp
f0105244:	eb 0b                	jmp    f0105251 <vprintfmt+0x21e>
				else
					putch(ch, putdat);
f0105246:	83 ec 08             	sub    $0x8,%esp
f0105249:	53                   	push   %ebx
f010524a:	52                   	push   %edx
f010524b:	ff 55 08             	call   *0x8(%ebp)
f010524e:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0105251:	ff 4d e4             	decl   -0x1c(%ebp)
f0105254:	46                   	inc    %esi
f0105255:	8a 46 ff             	mov    -0x1(%esi),%al
f0105258:	0f be d0             	movsbl %al,%edx
f010525b:	85 d2                	test   %edx,%edx
f010525d:	75 1c                	jne    f010527b <vprintfmt+0x248>
f010525f:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0105262:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0105266:	7f 1f                	jg     f0105287 <vprintfmt+0x254>
f0105268:	e9 da fd ff ff       	jmp    f0105047 <vprintfmt+0x14>
f010526d:	89 7d 08             	mov    %edi,0x8(%ebp)
f0105270:	8b 7d d0             	mov    -0x30(%ebp),%edi
f0105273:	eb 06                	jmp    f010527b <vprintfmt+0x248>
f0105275:	89 7d 08             	mov    %edi,0x8(%ebp)
f0105278:	8b 7d d0             	mov    -0x30(%ebp),%edi
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f010527b:	85 ff                	test   %edi,%edi
f010527d:	78 a8                	js     f0105227 <vprintfmt+0x1f4>
f010527f:	4f                   	dec    %edi
f0105280:	79 a5                	jns    f0105227 <vprintfmt+0x1f4>
f0105282:	8b 7d 08             	mov    0x8(%ebp),%edi
f0105285:	eb db                	jmp    f0105262 <vprintfmt+0x22f>
f0105287:	8b 75 e4             	mov    -0x1c(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f010528a:	83 ec 08             	sub    $0x8,%esp
f010528d:	53                   	push   %ebx
f010528e:	6a 20                	push   $0x20
f0105290:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0105292:	4e                   	dec    %esi
f0105293:	83 c4 10             	add    $0x10,%esp
f0105296:	85 f6                	test   %esi,%esi
f0105298:	7f f0                	jg     f010528a <vprintfmt+0x257>
f010529a:	e9 a8 fd ff ff       	jmp    f0105047 <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f010529f:	83 7d d4 01          	cmpl   $0x1,-0x2c(%ebp)
f01052a3:	7e 16                	jle    f01052bb <vprintfmt+0x288>
		return va_arg(*ap, long long);
f01052a5:	8b 45 14             	mov    0x14(%ebp),%eax
f01052a8:	8d 50 08             	lea    0x8(%eax),%edx
f01052ab:	89 55 14             	mov    %edx,0x14(%ebp)
f01052ae:	8b 50 04             	mov    0x4(%eax),%edx
f01052b1:	8b 00                	mov    (%eax),%eax
f01052b3:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01052b6:	89 55 dc             	mov    %edx,-0x24(%ebp)
f01052b9:	eb 34                	jmp    f01052ef <vprintfmt+0x2bc>
	else if (lflag)
f01052bb:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f01052bf:	74 18                	je     f01052d9 <vprintfmt+0x2a6>
		return va_arg(*ap, long);
f01052c1:	8b 45 14             	mov    0x14(%ebp),%eax
f01052c4:	8d 50 04             	lea    0x4(%eax),%edx
f01052c7:	89 55 14             	mov    %edx,0x14(%ebp)
f01052ca:	8b 30                	mov    (%eax),%esi
f01052cc:	89 75 d8             	mov    %esi,-0x28(%ebp)
f01052cf:	89 f0                	mov    %esi,%eax
f01052d1:	c1 f8 1f             	sar    $0x1f,%eax
f01052d4:	89 45 dc             	mov    %eax,-0x24(%ebp)
f01052d7:	eb 16                	jmp    f01052ef <vprintfmt+0x2bc>
	else
		return va_arg(*ap, int);
f01052d9:	8b 45 14             	mov    0x14(%ebp),%eax
f01052dc:	8d 50 04             	lea    0x4(%eax),%edx
f01052df:	89 55 14             	mov    %edx,0x14(%ebp)
f01052e2:	8b 30                	mov    (%eax),%esi
f01052e4:	89 75 d8             	mov    %esi,-0x28(%ebp)
f01052e7:	89 f0                	mov    %esi,%eax
f01052e9:	c1 f8 1f             	sar    $0x1f,%eax
f01052ec:	89 45 dc             	mov    %eax,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f01052ef:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01052f2:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
f01052f5:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f01052f9:	0f 89 8a 00 00 00    	jns    f0105389 <vprintfmt+0x356>
				putch('-', putdat);
f01052ff:	83 ec 08             	sub    $0x8,%esp
f0105302:	53                   	push   %ebx
f0105303:	6a 2d                	push   $0x2d
f0105305:	ff d7                	call   *%edi
				num = -(long long) num;
f0105307:	8b 45 d8             	mov    -0x28(%ebp),%eax
f010530a:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010530d:	f7 d8                	neg    %eax
f010530f:	83 d2 00             	adc    $0x0,%edx
f0105312:	f7 da                	neg    %edx
f0105314:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f0105317:	b9 0a 00 00 00       	mov    $0xa,%ecx
f010531c:	eb 70                	jmp    f010538e <vprintfmt+0x35b>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f010531e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0105321:	8d 45 14             	lea    0x14(%ebp),%eax
f0105324:	e8 97 fc ff ff       	call   f0104fc0 <getuint>
			base = 10;
f0105329:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
f010532e:	eb 5e                	jmp    f010538e <vprintfmt+0x35b>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
f0105330:	83 ec 08             	sub    $0x8,%esp
f0105333:	53                   	push   %ebx
f0105334:	6a 30                	push   $0x30
f0105336:	ff d7                	call   *%edi
			num = getuint(&ap, lflag);
f0105338:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f010533b:	8d 45 14             	lea    0x14(%ebp),%eax
f010533e:	e8 7d fc ff ff       	call   f0104fc0 <getuint>
			base = 8;
			goto number;
f0105343:	83 c4 10             	add    $0x10,%esp
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
f0105346:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
f010534b:	eb 41                	jmp    f010538e <vprintfmt+0x35b>
		// pointer
		case 'p':
			putch('0', putdat);
f010534d:	83 ec 08             	sub    $0x8,%esp
f0105350:	53                   	push   %ebx
f0105351:	6a 30                	push   $0x30
f0105353:	ff d7                	call   *%edi
			putch('x', putdat);
f0105355:	83 c4 08             	add    $0x8,%esp
f0105358:	53                   	push   %ebx
f0105359:	6a 78                	push   $0x78
f010535b:	ff d7                	call   *%edi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f010535d:	8b 45 14             	mov    0x14(%ebp),%eax
f0105360:	8d 50 04             	lea    0x4(%eax),%edx
f0105363:	89 55 14             	mov    %edx,0x14(%ebp)
			goto number;
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f0105366:	8b 00                	mov    (%eax),%eax
f0105368:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f010536d:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f0105370:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
f0105375:	eb 17                	jmp    f010538e <vprintfmt+0x35b>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0105377:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f010537a:	8d 45 14             	lea    0x14(%ebp),%eax
f010537d:	e8 3e fc ff ff       	call   f0104fc0 <getuint>
			base = 16;
f0105382:	b9 10 00 00 00       	mov    $0x10,%ecx
f0105387:	eb 05                	jmp    f010538e <vprintfmt+0x35b>
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0105389:	b9 0a 00 00 00       	mov    $0xa,%ecx
		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
f010538e:	83 ec 0c             	sub    $0xc,%esp
f0105391:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
f0105395:	56                   	push   %esi
f0105396:	ff 75 e4             	pushl  -0x1c(%ebp)
f0105399:	51                   	push   %ecx
f010539a:	52                   	push   %edx
f010539b:	50                   	push   %eax
f010539c:	89 da                	mov    %ebx,%edx
f010539e:	89 f8                	mov    %edi,%eax
f01053a0:	e8 6b fb ff ff       	call   f0104f10 <printnum>
			break;
f01053a5:	83 c4 20             	add    $0x20,%esp
f01053a8:	e9 9a fc ff ff       	jmp    f0105047 <vprintfmt+0x14>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f01053ad:	83 ec 08             	sub    $0x8,%esp
f01053b0:	53                   	push   %ebx
f01053b1:	52                   	push   %edx
f01053b2:	ff d7                	call   *%edi
			break;
f01053b4:	83 c4 10             	add    $0x10,%esp
f01053b7:	e9 8b fc ff ff       	jmp    f0105047 <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f01053bc:	83 ec 08             	sub    $0x8,%esp
f01053bf:	53                   	push   %ebx
f01053c0:	6a 25                	push   $0x25
f01053c2:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
f01053c4:	83 c4 10             	add    $0x10,%esp
f01053c7:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
f01053cb:	0f 84 73 fc ff ff    	je     f0105044 <vprintfmt+0x11>
f01053d1:	4e                   	dec    %esi
f01053d2:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
f01053d6:	75 f9                	jne    f01053d1 <vprintfmt+0x39e>
f01053d8:	89 75 10             	mov    %esi,0x10(%ebp)
f01053db:	e9 67 fc ff ff       	jmp    f0105047 <vprintfmt+0x14>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01053e0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01053e3:	8d 70 01             	lea    0x1(%eax),%esi
f01053e6:	8a 00                	mov    (%eax),%al
f01053e8:	0f be d0             	movsbl %al,%edx
f01053eb:	85 d2                	test   %edx,%edx
f01053ed:	0f 85 7a fe ff ff    	jne    f010526d <vprintfmt+0x23a>
f01053f3:	e9 4f fc ff ff       	jmp    f0105047 <vprintfmt+0x14>
f01053f8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01053fb:	8d 70 01             	lea    0x1(%eax),%esi
f01053fe:	8a 00                	mov    (%eax),%al
f0105400:	0f be d0             	movsbl %al,%edx
f0105403:	85 d2                	test   %edx,%edx
f0105405:	0f 85 6a fe ff ff    	jne    f0105275 <vprintfmt+0x242>
f010540b:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f010540e:	e9 77 fe ff ff       	jmp    f010528a <vprintfmt+0x257>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
f0105413:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105416:	5b                   	pop    %ebx
f0105417:	5e                   	pop    %esi
f0105418:	5f                   	pop    %edi
f0105419:	5d                   	pop    %ebp
f010541a:	c3                   	ret    

f010541b <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f010541b:	55                   	push   %ebp
f010541c:	89 e5                	mov    %esp,%ebp
f010541e:	83 ec 18             	sub    $0x18,%esp
f0105421:	8b 45 08             	mov    0x8(%ebp),%eax
f0105424:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0105427:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010542a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f010542e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0105431:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0105438:	85 c0                	test   %eax,%eax
f010543a:	74 26                	je     f0105462 <vsnprintf+0x47>
f010543c:	85 d2                	test   %edx,%edx
f010543e:	7e 29                	jle    f0105469 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0105440:	ff 75 14             	pushl  0x14(%ebp)
f0105443:	ff 75 10             	pushl  0x10(%ebp)
f0105446:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0105449:	50                   	push   %eax
f010544a:	68 fa 4f 10 f0       	push   $0xf0104ffa
f010544f:	e8 df fb ff ff       	call   f0105033 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0105454:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0105457:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f010545a:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010545d:	83 c4 10             	add    $0x10,%esp
f0105460:	eb 0c                	jmp    f010546e <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0105462:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0105467:	eb 05                	jmp    f010546e <vsnprintf+0x53>
f0105469:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f010546e:	c9                   	leave  
f010546f:	c3                   	ret    

f0105470 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0105470:	55                   	push   %ebp
f0105471:	89 e5                	mov    %esp,%ebp
f0105473:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0105476:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0105479:	50                   	push   %eax
f010547a:	ff 75 10             	pushl  0x10(%ebp)
f010547d:	ff 75 0c             	pushl  0xc(%ebp)
f0105480:	ff 75 08             	pushl  0x8(%ebp)
f0105483:	e8 93 ff ff ff       	call   f010541b <vsnprintf>
	va_end(ap);

	return rc;
}
f0105488:	c9                   	leave  
f0105489:	c3                   	ret    

f010548a <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f010548a:	55                   	push   %ebp
f010548b:	89 e5                	mov    %esp,%ebp
f010548d:	57                   	push   %edi
f010548e:	56                   	push   %esi
f010548f:	53                   	push   %ebx
f0105490:	83 ec 0c             	sub    $0xc,%esp
f0105493:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

#if JOS_KERNEL
	if (prompt != NULL)
f0105496:	85 c0                	test   %eax,%eax
f0105498:	74 11                	je     f01054ab <readline+0x21>
		cprintf("%s", prompt);
f010549a:	83 ec 08             	sub    $0x8,%esp
f010549d:	50                   	push   %eax
f010549e:	68 6c 6a 10 f0       	push   $0xf0106a6c
f01054a3:	e8 68 e3 ff ff       	call   f0103810 <cprintf>
f01054a8:	83 c4 10             	add    $0x10,%esp
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
	echoing = iscons(0);
f01054ab:	83 ec 0c             	sub    $0xc,%esp
f01054ae:	6a 00                	push   $0x0
f01054b0:	e8 0a b3 ff ff       	call   f01007bf <iscons>
f01054b5:	89 c7                	mov    %eax,%edi
f01054b7:	83 c4 10             	add    $0x10,%esp
#else
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
f01054ba:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f01054bf:	e8 ea b2 ff ff       	call   f01007ae <getchar>
f01054c4:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f01054c6:	85 c0                	test   %eax,%eax
f01054c8:	79 24                	jns    f01054ee <readline+0x64>
			if (c != -E_EOF)
f01054ca:	83 f8 f8             	cmp    $0xfffffff8,%eax
f01054cd:	0f 84 90 00 00 00    	je     f0105563 <readline+0xd9>
				cprintf("read error: %e\n", c);
f01054d3:	83 ec 08             	sub    $0x8,%esp
f01054d6:	50                   	push   %eax
f01054d7:	68 9f 7e 10 f0       	push   $0xf0107e9f
f01054dc:	e8 2f e3 ff ff       	call   f0103810 <cprintf>
f01054e1:	83 c4 10             	add    $0x10,%esp
			return NULL;
f01054e4:	b8 00 00 00 00       	mov    $0x0,%eax
f01054e9:	e9 98 00 00 00       	jmp    f0105586 <readline+0xfc>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f01054ee:	83 f8 08             	cmp    $0x8,%eax
f01054f1:	74 7d                	je     f0105570 <readline+0xe6>
f01054f3:	83 f8 7f             	cmp    $0x7f,%eax
f01054f6:	75 16                	jne    f010550e <readline+0x84>
f01054f8:	eb 70                	jmp    f010556a <readline+0xe0>
			if (echoing)
f01054fa:	85 ff                	test   %edi,%edi
f01054fc:	74 0d                	je     f010550b <readline+0x81>
				cputchar('\b');
f01054fe:	83 ec 0c             	sub    $0xc,%esp
f0105501:	6a 08                	push   $0x8
f0105503:	e8 96 b2 ff ff       	call   f010079e <cputchar>
f0105508:	83 c4 10             	add    $0x10,%esp
			i--;
f010550b:	4e                   	dec    %esi
f010550c:	eb b1                	jmp    f01054bf <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f010550e:	83 f8 1f             	cmp    $0x1f,%eax
f0105511:	7e 23                	jle    f0105536 <readline+0xac>
f0105513:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0105519:	7f 1b                	jg     f0105536 <readline+0xac>
			if (echoing)
f010551b:	85 ff                	test   %edi,%edi
f010551d:	74 0c                	je     f010552b <readline+0xa1>
				cputchar(c);
f010551f:	83 ec 0c             	sub    $0xc,%esp
f0105522:	53                   	push   %ebx
f0105523:	e8 76 b2 ff ff       	call   f010079e <cputchar>
f0105528:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f010552b:	88 9e 80 5a 24 f0    	mov    %bl,-0xfdba580(%esi)
f0105531:	8d 76 01             	lea    0x1(%esi),%esi
f0105534:	eb 89                	jmp    f01054bf <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f0105536:	83 fb 0a             	cmp    $0xa,%ebx
f0105539:	74 09                	je     f0105544 <readline+0xba>
f010553b:	83 fb 0d             	cmp    $0xd,%ebx
f010553e:	0f 85 7b ff ff ff    	jne    f01054bf <readline+0x35>
			if (echoing)
f0105544:	85 ff                	test   %edi,%edi
f0105546:	74 0d                	je     f0105555 <readline+0xcb>
				cputchar('\n');
f0105548:	83 ec 0c             	sub    $0xc,%esp
f010554b:	6a 0a                	push   $0xa
f010554d:	e8 4c b2 ff ff       	call   f010079e <cputchar>
f0105552:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f0105555:	c6 86 80 5a 24 f0 00 	movb   $0x0,-0xfdba580(%esi)
			return buf;
f010555c:	b8 80 5a 24 f0       	mov    $0xf0245a80,%eax
f0105561:	eb 23                	jmp    f0105586 <readline+0xfc>
	while (1) {
		c = getchar();
		if (c < 0) {
			if (c != -E_EOF)
				cprintf("read error: %e\n", c);
			return NULL;
f0105563:	b8 00 00 00 00       	mov    $0x0,%eax
f0105568:	eb 1c                	jmp    f0105586 <readline+0xfc>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f010556a:	85 f6                	test   %esi,%esi
f010556c:	7f 8c                	jg     f01054fa <readline+0x70>
f010556e:	eb 09                	jmp    f0105579 <readline+0xef>
f0105570:	85 f6                	test   %esi,%esi
f0105572:	7f 86                	jg     f01054fa <readline+0x70>
f0105574:	e9 46 ff ff ff       	jmp    f01054bf <readline+0x35>
			if (echoing)
				cputchar('\b');
			i--;
		} else if (c >= ' ' && i < BUFLEN-1) {
f0105579:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f010557f:	7e 9a                	jle    f010551b <readline+0x91>
f0105581:	e9 39 ff ff ff       	jmp    f01054bf <readline+0x35>
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f0105586:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105589:	5b                   	pop    %ebx
f010558a:	5e                   	pop    %esi
f010558b:	5f                   	pop    %edi
f010558c:	5d                   	pop    %ebp
f010558d:	c3                   	ret    

f010558e <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f010558e:	55                   	push   %ebp
f010558f:	89 e5                	mov    %esp,%ebp
f0105591:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0105594:	80 3a 00             	cmpb   $0x0,(%edx)
f0105597:	74 0e                	je     f01055a7 <strlen+0x19>
f0105599:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
f010559e:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f010559f:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f01055a3:	75 f9                	jne    f010559e <strlen+0x10>
f01055a5:	eb 05                	jmp    f01055ac <strlen+0x1e>
f01055a7:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
f01055ac:	5d                   	pop    %ebp
f01055ad:	c3                   	ret    

f01055ae <strnlen>:

int
strnlen(const char *s, size_t size)
{
f01055ae:	55                   	push   %ebp
f01055af:	89 e5                	mov    %esp,%ebp
f01055b1:	53                   	push   %ebx
f01055b2:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01055b5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01055b8:	85 c9                	test   %ecx,%ecx
f01055ba:	74 1a                	je     f01055d6 <strnlen+0x28>
f01055bc:	80 3b 00             	cmpb   $0x0,(%ebx)
f01055bf:	74 1c                	je     f01055dd <strnlen+0x2f>
f01055c1:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
f01055c6:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01055c8:	39 ca                	cmp    %ecx,%edx
f01055ca:	74 16                	je     f01055e2 <strnlen+0x34>
f01055cc:	42                   	inc    %edx
f01055cd:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
f01055d2:	75 f2                	jne    f01055c6 <strnlen+0x18>
f01055d4:	eb 0c                	jmp    f01055e2 <strnlen+0x34>
f01055d6:	b8 00 00 00 00       	mov    $0x0,%eax
f01055db:	eb 05                	jmp    f01055e2 <strnlen+0x34>
f01055dd:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
f01055e2:	5b                   	pop    %ebx
f01055e3:	5d                   	pop    %ebp
f01055e4:	c3                   	ret    

f01055e5 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f01055e5:	55                   	push   %ebp
f01055e6:	89 e5                	mov    %esp,%ebp
f01055e8:	53                   	push   %ebx
f01055e9:	8b 45 08             	mov    0x8(%ebp),%eax
f01055ec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f01055ef:	89 c2                	mov    %eax,%edx
f01055f1:	42                   	inc    %edx
f01055f2:	41                   	inc    %ecx
f01055f3:	8a 59 ff             	mov    -0x1(%ecx),%bl
f01055f6:	88 5a ff             	mov    %bl,-0x1(%edx)
f01055f9:	84 db                	test   %bl,%bl
f01055fb:	75 f4                	jne    f01055f1 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f01055fd:	5b                   	pop    %ebx
f01055fe:	5d                   	pop    %ebp
f01055ff:	c3                   	ret    

f0105600 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0105600:	55                   	push   %ebp
f0105601:	89 e5                	mov    %esp,%ebp
f0105603:	53                   	push   %ebx
f0105604:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0105607:	53                   	push   %ebx
f0105608:	e8 81 ff ff ff       	call   f010558e <strlen>
f010560d:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f0105610:	ff 75 0c             	pushl  0xc(%ebp)
f0105613:	01 d8                	add    %ebx,%eax
f0105615:	50                   	push   %eax
f0105616:	e8 ca ff ff ff       	call   f01055e5 <strcpy>
	return dst;
}
f010561b:	89 d8                	mov    %ebx,%eax
f010561d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0105620:	c9                   	leave  
f0105621:	c3                   	ret    

f0105622 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0105622:	55                   	push   %ebp
f0105623:	89 e5                	mov    %esp,%ebp
f0105625:	56                   	push   %esi
f0105626:	53                   	push   %ebx
f0105627:	8b 75 08             	mov    0x8(%ebp),%esi
f010562a:	8b 55 0c             	mov    0xc(%ebp),%edx
f010562d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0105630:	85 db                	test   %ebx,%ebx
f0105632:	74 14                	je     f0105648 <strncpy+0x26>
f0105634:	01 f3                	add    %esi,%ebx
f0105636:	89 f1                	mov    %esi,%ecx
		*dst++ = *src;
f0105638:	41                   	inc    %ecx
f0105639:	8a 02                	mov    (%edx),%al
f010563b:	88 41 ff             	mov    %al,-0x1(%ecx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f010563e:	80 3a 01             	cmpb   $0x1,(%edx)
f0105641:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0105644:	39 cb                	cmp    %ecx,%ebx
f0105646:	75 f0                	jne    f0105638 <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0105648:	89 f0                	mov    %esi,%eax
f010564a:	5b                   	pop    %ebx
f010564b:	5e                   	pop    %esi
f010564c:	5d                   	pop    %ebp
f010564d:	c3                   	ret    

f010564e <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f010564e:	55                   	push   %ebp
f010564f:	89 e5                	mov    %esp,%ebp
f0105651:	53                   	push   %ebx
f0105652:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105655:	8b 45 10             	mov    0x10(%ebp),%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0105658:	85 c0                	test   %eax,%eax
f010565a:	74 30                	je     f010568c <strlcpy+0x3e>
		while (--size > 0 && *src != '\0')
f010565c:	48                   	dec    %eax
f010565d:	74 20                	je     f010567f <strlcpy+0x31>
f010565f:	8a 0b                	mov    (%ebx),%cl
f0105661:	84 c9                	test   %cl,%cl
f0105663:	74 1f                	je     f0105684 <strlcpy+0x36>
f0105665:	8d 53 01             	lea    0x1(%ebx),%edx
f0105668:	01 c3                	add    %eax,%ebx
f010566a:	8b 45 08             	mov    0x8(%ebp),%eax
			*dst++ = *src++;
f010566d:	40                   	inc    %eax
f010566e:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0105671:	39 da                	cmp    %ebx,%edx
f0105673:	74 12                	je     f0105687 <strlcpy+0x39>
f0105675:	42                   	inc    %edx
f0105676:	8a 4a ff             	mov    -0x1(%edx),%cl
f0105679:	84 c9                	test   %cl,%cl
f010567b:	75 f0                	jne    f010566d <strlcpy+0x1f>
f010567d:	eb 08                	jmp    f0105687 <strlcpy+0x39>
f010567f:	8b 45 08             	mov    0x8(%ebp),%eax
f0105682:	eb 03                	jmp    f0105687 <strlcpy+0x39>
f0105684:	8b 45 08             	mov    0x8(%ebp),%eax
			*dst++ = *src++;
		*dst = '\0';
f0105687:	c6 00 00             	movb   $0x0,(%eax)
f010568a:	eb 03                	jmp    f010568f <strlcpy+0x41>
f010568c:	8b 45 08             	mov    0x8(%ebp),%eax
	}
	return dst - dst_in;
f010568f:	2b 45 08             	sub    0x8(%ebp),%eax
}
f0105692:	5b                   	pop    %ebx
f0105693:	5d                   	pop    %ebp
f0105694:	c3                   	ret    

f0105695 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0105695:	55                   	push   %ebp
f0105696:	89 e5                	mov    %esp,%ebp
f0105698:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010569b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f010569e:	8a 01                	mov    (%ecx),%al
f01056a0:	84 c0                	test   %al,%al
f01056a2:	74 10                	je     f01056b4 <strcmp+0x1f>
f01056a4:	3a 02                	cmp    (%edx),%al
f01056a6:	75 0c                	jne    f01056b4 <strcmp+0x1f>
		p++, q++;
f01056a8:	41                   	inc    %ecx
f01056a9:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f01056aa:	8a 01                	mov    (%ecx),%al
f01056ac:	84 c0                	test   %al,%al
f01056ae:	74 04                	je     f01056b4 <strcmp+0x1f>
f01056b0:	3a 02                	cmp    (%edx),%al
f01056b2:	74 f4                	je     f01056a8 <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f01056b4:	0f b6 c0             	movzbl %al,%eax
f01056b7:	0f b6 12             	movzbl (%edx),%edx
f01056ba:	29 d0                	sub    %edx,%eax
}
f01056bc:	5d                   	pop    %ebp
f01056bd:	c3                   	ret    

f01056be <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f01056be:	55                   	push   %ebp
f01056bf:	89 e5                	mov    %esp,%ebp
f01056c1:	56                   	push   %esi
f01056c2:	53                   	push   %ebx
f01056c3:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01056c6:	8b 55 0c             	mov    0xc(%ebp),%edx
f01056c9:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
f01056cc:	85 f6                	test   %esi,%esi
f01056ce:	74 23                	je     f01056f3 <strncmp+0x35>
f01056d0:	8a 03                	mov    (%ebx),%al
f01056d2:	84 c0                	test   %al,%al
f01056d4:	74 2b                	je     f0105701 <strncmp+0x43>
f01056d6:	3a 02                	cmp    (%edx),%al
f01056d8:	75 27                	jne    f0105701 <strncmp+0x43>
f01056da:	8d 43 01             	lea    0x1(%ebx),%eax
f01056dd:	01 de                	add    %ebx,%esi
		n--, p++, q++;
f01056df:	89 c3                	mov    %eax,%ebx
f01056e1:	42                   	inc    %edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f01056e2:	39 c6                	cmp    %eax,%esi
f01056e4:	74 14                	je     f01056fa <strncmp+0x3c>
f01056e6:	8a 08                	mov    (%eax),%cl
f01056e8:	84 c9                	test   %cl,%cl
f01056ea:	74 15                	je     f0105701 <strncmp+0x43>
f01056ec:	40                   	inc    %eax
f01056ed:	3a 0a                	cmp    (%edx),%cl
f01056ef:	74 ee                	je     f01056df <strncmp+0x21>
f01056f1:	eb 0e                	jmp    f0105701 <strncmp+0x43>
		n--, p++, q++;
	if (n == 0)
		return 0;
f01056f3:	b8 00 00 00 00       	mov    $0x0,%eax
f01056f8:	eb 0f                	jmp    f0105709 <strncmp+0x4b>
f01056fa:	b8 00 00 00 00       	mov    $0x0,%eax
f01056ff:	eb 08                	jmp    f0105709 <strncmp+0x4b>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0105701:	0f b6 03             	movzbl (%ebx),%eax
f0105704:	0f b6 12             	movzbl (%edx),%edx
f0105707:	29 d0                	sub    %edx,%eax
}
f0105709:	5b                   	pop    %ebx
f010570a:	5e                   	pop    %esi
f010570b:	5d                   	pop    %ebp
f010570c:	c3                   	ret    

f010570d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f010570d:	55                   	push   %ebp
f010570e:	89 e5                	mov    %esp,%ebp
f0105710:	53                   	push   %ebx
f0105711:	8b 45 08             	mov    0x8(%ebp),%eax
f0105714:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
f0105717:	8a 10                	mov    (%eax),%dl
f0105719:	84 d2                	test   %dl,%dl
f010571b:	74 1a                	je     f0105737 <strchr+0x2a>
f010571d:	88 d9                	mov    %bl,%cl
		if (*s == c)
f010571f:	38 d3                	cmp    %dl,%bl
f0105721:	75 06                	jne    f0105729 <strchr+0x1c>
f0105723:	eb 17                	jmp    f010573c <strchr+0x2f>
f0105725:	38 ca                	cmp    %cl,%dl
f0105727:	74 13                	je     f010573c <strchr+0x2f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0105729:	40                   	inc    %eax
f010572a:	8a 10                	mov    (%eax),%dl
f010572c:	84 d2                	test   %dl,%dl
f010572e:	75 f5                	jne    f0105725 <strchr+0x18>
		if (*s == c)
			return (char *) s;
	return 0;
f0105730:	b8 00 00 00 00       	mov    $0x0,%eax
f0105735:	eb 05                	jmp    f010573c <strchr+0x2f>
f0105737:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010573c:	5b                   	pop    %ebx
f010573d:	5d                   	pop    %ebp
f010573e:	c3                   	ret    

f010573f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f010573f:	55                   	push   %ebp
f0105740:	89 e5                	mov    %esp,%ebp
f0105742:	53                   	push   %ebx
f0105743:	8b 45 08             	mov    0x8(%ebp),%eax
f0105746:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
f0105749:	8a 10                	mov    (%eax),%dl
f010574b:	84 d2                	test   %dl,%dl
f010574d:	74 13                	je     f0105762 <strfind+0x23>
f010574f:	88 d9                	mov    %bl,%cl
		if (*s == c)
f0105751:	38 d3                	cmp    %dl,%bl
f0105753:	75 06                	jne    f010575b <strfind+0x1c>
f0105755:	eb 0b                	jmp    f0105762 <strfind+0x23>
f0105757:	38 ca                	cmp    %cl,%dl
f0105759:	74 07                	je     f0105762 <strfind+0x23>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f010575b:	40                   	inc    %eax
f010575c:	8a 10                	mov    (%eax),%dl
f010575e:	84 d2                	test   %dl,%dl
f0105760:	75 f5                	jne    f0105757 <strfind+0x18>
		if (*s == c)
			break;
	return (char *) s;
}
f0105762:	5b                   	pop    %ebx
f0105763:	5d                   	pop    %ebp
f0105764:	c3                   	ret    

f0105765 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0105765:	55                   	push   %ebp
f0105766:	89 e5                	mov    %esp,%ebp
f0105768:	57                   	push   %edi
f0105769:	56                   	push   %esi
f010576a:	53                   	push   %ebx
f010576b:	8b 7d 08             	mov    0x8(%ebp),%edi
f010576e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0105771:	85 c9                	test   %ecx,%ecx
f0105773:	74 36                	je     f01057ab <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0105775:	f7 c7 03 00 00 00    	test   $0x3,%edi
f010577b:	75 28                	jne    f01057a5 <memset+0x40>
f010577d:	f6 c1 03             	test   $0x3,%cl
f0105780:	75 23                	jne    f01057a5 <memset+0x40>
		c &= 0xFF;
f0105782:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0105786:	89 d3                	mov    %edx,%ebx
f0105788:	c1 e3 08             	shl    $0x8,%ebx
f010578b:	89 d6                	mov    %edx,%esi
f010578d:	c1 e6 18             	shl    $0x18,%esi
f0105790:	89 d0                	mov    %edx,%eax
f0105792:	c1 e0 10             	shl    $0x10,%eax
f0105795:	09 f0                	or     %esi,%eax
f0105797:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
f0105799:	89 d8                	mov    %ebx,%eax
f010579b:	09 d0                	or     %edx,%eax
f010579d:	c1 e9 02             	shr    $0x2,%ecx
f01057a0:	fc                   	cld    
f01057a1:	f3 ab                	rep stos %eax,%es:(%edi)
f01057a3:	eb 06                	jmp    f01057ab <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f01057a5:	8b 45 0c             	mov    0xc(%ebp),%eax
f01057a8:	fc                   	cld    
f01057a9:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f01057ab:	89 f8                	mov    %edi,%eax
f01057ad:	5b                   	pop    %ebx
f01057ae:	5e                   	pop    %esi
f01057af:	5f                   	pop    %edi
f01057b0:	5d                   	pop    %ebp
f01057b1:	c3                   	ret    

f01057b2 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f01057b2:	55                   	push   %ebp
f01057b3:	89 e5                	mov    %esp,%ebp
f01057b5:	57                   	push   %edi
f01057b6:	56                   	push   %esi
f01057b7:	8b 45 08             	mov    0x8(%ebp),%eax
f01057ba:	8b 75 0c             	mov    0xc(%ebp),%esi
f01057bd:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f01057c0:	39 c6                	cmp    %eax,%esi
f01057c2:	73 33                	jae    f01057f7 <memmove+0x45>
f01057c4:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f01057c7:	39 d0                	cmp    %edx,%eax
f01057c9:	73 2c                	jae    f01057f7 <memmove+0x45>
		s += n;
		d += n;
f01057cb:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01057ce:	89 d6                	mov    %edx,%esi
f01057d0:	09 fe                	or     %edi,%esi
f01057d2:	f7 c6 03 00 00 00    	test   $0x3,%esi
f01057d8:	75 13                	jne    f01057ed <memmove+0x3b>
f01057da:	f6 c1 03             	test   $0x3,%cl
f01057dd:	75 0e                	jne    f01057ed <memmove+0x3b>
			asm volatile("std; rep movsl\n"
f01057df:	83 ef 04             	sub    $0x4,%edi
f01057e2:	8d 72 fc             	lea    -0x4(%edx),%esi
f01057e5:	c1 e9 02             	shr    $0x2,%ecx
f01057e8:	fd                   	std    
f01057e9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01057eb:	eb 07                	jmp    f01057f4 <memmove+0x42>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f01057ed:	4f                   	dec    %edi
f01057ee:	8d 72 ff             	lea    -0x1(%edx),%esi
f01057f1:	fd                   	std    
f01057f2:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f01057f4:	fc                   	cld    
f01057f5:	eb 1d                	jmp    f0105814 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01057f7:	89 f2                	mov    %esi,%edx
f01057f9:	09 c2                	or     %eax,%edx
f01057fb:	f6 c2 03             	test   $0x3,%dl
f01057fe:	75 0f                	jne    f010580f <memmove+0x5d>
f0105800:	f6 c1 03             	test   $0x3,%cl
f0105803:	75 0a                	jne    f010580f <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
f0105805:	c1 e9 02             	shr    $0x2,%ecx
f0105808:	89 c7                	mov    %eax,%edi
f010580a:	fc                   	cld    
f010580b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010580d:	eb 05                	jmp    f0105814 <memmove+0x62>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f010580f:	89 c7                	mov    %eax,%edi
f0105811:	fc                   	cld    
f0105812:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0105814:	5e                   	pop    %esi
f0105815:	5f                   	pop    %edi
f0105816:	5d                   	pop    %ebp
f0105817:	c3                   	ret    

f0105818 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0105818:	55                   	push   %ebp
f0105819:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f010581b:	ff 75 10             	pushl  0x10(%ebp)
f010581e:	ff 75 0c             	pushl  0xc(%ebp)
f0105821:	ff 75 08             	pushl  0x8(%ebp)
f0105824:	e8 89 ff ff ff       	call   f01057b2 <memmove>
}
f0105829:	c9                   	leave  
f010582a:	c3                   	ret    

f010582b <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f010582b:	55                   	push   %ebp
f010582c:	89 e5                	mov    %esp,%ebp
f010582e:	57                   	push   %edi
f010582f:	56                   	push   %esi
f0105830:	53                   	push   %ebx
f0105831:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0105834:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105837:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010583a:	85 c0                	test   %eax,%eax
f010583c:	74 33                	je     f0105871 <memcmp+0x46>
f010583e:	8d 78 ff             	lea    -0x1(%eax),%edi
		if (*s1 != *s2)
f0105841:	8a 13                	mov    (%ebx),%dl
f0105843:	8a 0e                	mov    (%esi),%cl
f0105845:	38 ca                	cmp    %cl,%dl
f0105847:	75 13                	jne    f010585c <memcmp+0x31>
f0105849:	b8 00 00 00 00       	mov    $0x0,%eax
f010584e:	eb 16                	jmp    f0105866 <memcmp+0x3b>
f0105850:	8a 54 03 01          	mov    0x1(%ebx,%eax,1),%dl
f0105854:	40                   	inc    %eax
f0105855:	8a 0c 06             	mov    (%esi,%eax,1),%cl
f0105858:	38 ca                	cmp    %cl,%dl
f010585a:	74 0a                	je     f0105866 <memcmp+0x3b>
			return (int) *s1 - (int) *s2;
f010585c:	0f b6 c2             	movzbl %dl,%eax
f010585f:	0f b6 c9             	movzbl %cl,%ecx
f0105862:	29 c8                	sub    %ecx,%eax
f0105864:	eb 10                	jmp    f0105876 <memcmp+0x4b>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0105866:	39 f8                	cmp    %edi,%eax
f0105868:	75 e6                	jne    f0105850 <memcmp+0x25>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f010586a:	b8 00 00 00 00       	mov    $0x0,%eax
f010586f:	eb 05                	jmp    f0105876 <memcmp+0x4b>
f0105871:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105876:	5b                   	pop    %ebx
f0105877:	5e                   	pop    %esi
f0105878:	5f                   	pop    %edi
f0105879:	5d                   	pop    %ebp
f010587a:	c3                   	ret    

f010587b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f010587b:	55                   	push   %ebp
f010587c:	89 e5                	mov    %esp,%ebp
f010587e:	53                   	push   %ebx
f010587f:	8b 55 08             	mov    0x8(%ebp),%edx
	const void *ends = (const char *) s + n;
f0105882:	89 d0                	mov    %edx,%eax
f0105884:	03 45 10             	add    0x10(%ebp),%eax
	for (; s < ends; s++)
f0105887:	39 c2                	cmp    %eax,%edx
f0105889:	73 1b                	jae    f01058a6 <memfind+0x2b>
		if (*(const unsigned char *) s == (unsigned char) c)
f010588b:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
f010588f:	0f b6 0a             	movzbl (%edx),%ecx
f0105892:	39 d9                	cmp    %ebx,%ecx
f0105894:	75 09                	jne    f010589f <memfind+0x24>
f0105896:	eb 12                	jmp    f01058aa <memfind+0x2f>
f0105898:	0f b6 0a             	movzbl (%edx),%ecx
f010589b:	39 d9                	cmp    %ebx,%ecx
f010589d:	74 0f                	je     f01058ae <memfind+0x33>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f010589f:	42                   	inc    %edx
f01058a0:	39 d0                	cmp    %edx,%eax
f01058a2:	75 f4                	jne    f0105898 <memfind+0x1d>
f01058a4:	eb 0a                	jmp    f01058b0 <memfind+0x35>
f01058a6:	89 d0                	mov    %edx,%eax
f01058a8:	eb 06                	jmp    f01058b0 <memfind+0x35>
		if (*(const unsigned char *) s == (unsigned char) c)
f01058aa:	89 d0                	mov    %edx,%eax
f01058ac:	eb 02                	jmp    f01058b0 <memfind+0x35>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f01058ae:	89 d0                	mov    %edx,%eax
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f01058b0:	5b                   	pop    %ebx
f01058b1:	5d                   	pop    %ebp
f01058b2:	c3                   	ret    

f01058b3 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f01058b3:	55                   	push   %ebp
f01058b4:	89 e5                	mov    %esp,%ebp
f01058b6:	57                   	push   %edi
f01058b7:	56                   	push   %esi
f01058b8:	53                   	push   %ebx
f01058b9:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01058bc:	eb 01                	jmp    f01058bf <strtol+0xc>
		s++;
f01058be:	41                   	inc    %ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01058bf:	8a 01                	mov    (%ecx),%al
f01058c1:	3c 20                	cmp    $0x20,%al
f01058c3:	74 f9                	je     f01058be <strtol+0xb>
f01058c5:	3c 09                	cmp    $0x9,%al
f01058c7:	74 f5                	je     f01058be <strtol+0xb>
		s++;

	// plus/minus sign
	if (*s == '+')
f01058c9:	3c 2b                	cmp    $0x2b,%al
f01058cb:	75 08                	jne    f01058d5 <strtol+0x22>
		s++;
f01058cd:	41                   	inc    %ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f01058ce:	bf 00 00 00 00       	mov    $0x0,%edi
f01058d3:	eb 11                	jmp    f01058e6 <strtol+0x33>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f01058d5:	3c 2d                	cmp    $0x2d,%al
f01058d7:	75 08                	jne    f01058e1 <strtol+0x2e>
		s++, neg = 1;
f01058d9:	41                   	inc    %ecx
f01058da:	bf 01 00 00 00       	mov    $0x1,%edi
f01058df:	eb 05                	jmp    f01058e6 <strtol+0x33>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f01058e1:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01058e6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f01058ea:	0f 84 87 00 00 00    	je     f0105977 <strtol+0xc4>
f01058f0:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
f01058f4:	75 27                	jne    f010591d <strtol+0x6a>
f01058f6:	80 39 30             	cmpb   $0x30,(%ecx)
f01058f9:	75 22                	jne    f010591d <strtol+0x6a>
f01058fb:	e9 88 00 00 00       	jmp    f0105988 <strtol+0xd5>
		s += 2, base = 16;
f0105900:	83 c1 02             	add    $0x2,%ecx
f0105903:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
f010590a:	eb 11                	jmp    f010591d <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
f010590c:	41                   	inc    %ecx
f010590d:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
f0105914:	eb 07                	jmp    f010591d <strtol+0x6a>
	else if (base == 0)
		base = 10;
f0105916:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)
f010591d:	b8 00 00 00 00       	mov    $0x0,%eax

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0105922:	8a 11                	mov    (%ecx),%dl
f0105924:	8d 5a d0             	lea    -0x30(%edx),%ebx
f0105927:	80 fb 09             	cmp    $0x9,%bl
f010592a:	77 08                	ja     f0105934 <strtol+0x81>
			dig = *s - '0';
f010592c:	0f be d2             	movsbl %dl,%edx
f010592f:	83 ea 30             	sub    $0x30,%edx
f0105932:	eb 22                	jmp    f0105956 <strtol+0xa3>
		else if (*s >= 'a' && *s <= 'z')
f0105934:	8d 72 9f             	lea    -0x61(%edx),%esi
f0105937:	89 f3                	mov    %esi,%ebx
f0105939:	80 fb 19             	cmp    $0x19,%bl
f010593c:	77 08                	ja     f0105946 <strtol+0x93>
			dig = *s - 'a' + 10;
f010593e:	0f be d2             	movsbl %dl,%edx
f0105941:	83 ea 57             	sub    $0x57,%edx
f0105944:	eb 10                	jmp    f0105956 <strtol+0xa3>
		else if (*s >= 'A' && *s <= 'Z')
f0105946:	8d 72 bf             	lea    -0x41(%edx),%esi
f0105949:	89 f3                	mov    %esi,%ebx
f010594b:	80 fb 19             	cmp    $0x19,%bl
f010594e:	77 14                	ja     f0105964 <strtol+0xb1>
			dig = *s - 'A' + 10;
f0105950:	0f be d2             	movsbl %dl,%edx
f0105953:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
f0105956:	3b 55 10             	cmp    0x10(%ebp),%edx
f0105959:	7d 09                	jge    f0105964 <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
f010595b:	41                   	inc    %ecx
f010595c:	0f af 45 10          	imul   0x10(%ebp),%eax
f0105960:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
f0105962:	eb be                	jmp    f0105922 <strtol+0x6f>

	if (endptr)
f0105964:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0105968:	74 05                	je     f010596f <strtol+0xbc>
		*endptr = (char *) s;
f010596a:	8b 75 0c             	mov    0xc(%ebp),%esi
f010596d:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
f010596f:	85 ff                	test   %edi,%edi
f0105971:	74 21                	je     f0105994 <strtol+0xe1>
f0105973:	f7 d8                	neg    %eax
f0105975:	eb 1d                	jmp    f0105994 <strtol+0xe1>
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0105977:	80 39 30             	cmpb   $0x30,(%ecx)
f010597a:	75 9a                	jne    f0105916 <strtol+0x63>
f010597c:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f0105980:	0f 84 7a ff ff ff    	je     f0105900 <strtol+0x4d>
f0105986:	eb 84                	jmp    f010590c <strtol+0x59>
f0105988:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f010598c:	0f 84 6e ff ff ff    	je     f0105900 <strtol+0x4d>
f0105992:	eb 89                	jmp    f010591d <strtol+0x6a>
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
}
f0105994:	5b                   	pop    %ebx
f0105995:	5e                   	pop    %esi
f0105996:	5f                   	pop    %edi
f0105997:	5d                   	pop    %ebp
f0105998:	c3                   	ret    
f0105999:	66 90                	xchg   %ax,%ax
f010599b:	90                   	nop

f010599c <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f010599c:	fa                   	cli    

	xorw    %ax, %ax
f010599d:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f010599f:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f01059a1:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f01059a3:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f01059a5:	0f 01 16             	lgdtl  (%esi)
f01059a8:	74 70                	je     f0105a1a <mpsearch1+0x3>
	movl    %cr0, %eax
f01059aa:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f01059ad:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f01059b1:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f01059b4:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f01059ba:	08 00                	or     %al,(%eax)

f01059bc <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f01059bc:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f01059c0:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f01059c2:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f01059c4:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f01059c6:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f01059ca:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f01059cc:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f01059ce:	b8 00 e0 11 00       	mov    $0x11e000,%eax
	movl    %eax, %cr3
f01059d3:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f01059d6:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f01059d9:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f01059de:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f01059e1:	8b 25 84 5e 24 f0    	mov    0xf0245e84,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f01059e7:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f01059ec:	b8 1c 02 10 f0       	mov    $0xf010021c,%eax
	call    *%eax
f01059f1:	ff d0                	call   *%eax

f01059f3 <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f01059f3:	eb fe                	jmp    f01059f3 <spin>
f01059f5:	8d 76 00             	lea    0x0(%esi),%esi

f01059f8 <gdt>:
	...
f0105a00:	ff                   	(bad)  
f0105a01:	ff 00                	incl   (%eax)
f0105a03:	00 00                	add    %al,(%eax)
f0105a05:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f0105a0c:	00 92 cf 00 17 00    	add    %dl,0x1700cf(%edx)

f0105a10 <gdtdesc>:
f0105a10:	17                   	pop    %ss
f0105a11:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f0105a16 <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f0105a16:	90                   	nop

f0105a17 <mpsearch1>:
}

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f0105a17:	55                   	push   %ebp
f0105a18:	89 e5                	mov    %esp,%ebp
f0105a1a:	57                   	push   %edi
f0105a1b:	56                   	push   %esi
f0105a1c:	53                   	push   %ebx
f0105a1d:	83 ec 0c             	sub    $0xc,%esp
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105a20:	8b 0d 88 5e 24 f0    	mov    0xf0245e88,%ecx
f0105a26:	89 c3                	mov    %eax,%ebx
f0105a28:	c1 eb 0c             	shr    $0xc,%ebx
f0105a2b:	39 cb                	cmp    %ecx,%ebx
f0105a2d:	72 12                	jb     f0105a41 <mpsearch1+0x2a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105a2f:	50                   	push   %eax
f0105a30:	68 c4 64 10 f0       	push   $0xf01064c4
f0105a35:	6a 57                	push   $0x57
f0105a37:	68 3d 80 10 f0       	push   $0xf010803d
f0105a3c:	e8 ff a5 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0105a41:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f0105a47:	01 d0                	add    %edx,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105a49:	89 c2                	mov    %eax,%edx
f0105a4b:	c1 ea 0c             	shr    $0xc,%edx
f0105a4e:	39 ca                	cmp    %ecx,%edx
f0105a50:	72 12                	jb     f0105a64 <mpsearch1+0x4d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105a52:	50                   	push   %eax
f0105a53:	68 c4 64 10 f0       	push   $0xf01064c4
f0105a58:	6a 57                	push   $0x57
f0105a5a:	68 3d 80 10 f0       	push   $0xf010803d
f0105a5f:	e8 dc a5 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0105a64:	8d b0 00 00 00 f0    	lea    -0x10000000(%eax),%esi

	for (; mp < end; mp++)
f0105a6a:	39 de                	cmp    %ebx,%esi
f0105a6c:	76 3d                	jbe    f0105aab <mpsearch1+0x94>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0105a6e:	83 ec 04             	sub    $0x4,%esp
f0105a71:	6a 04                	push   $0x4
f0105a73:	68 4d 80 10 f0       	push   $0xf010804d
f0105a78:	53                   	push   %ebx
f0105a79:	e8 ad fd ff ff       	call   f010582b <memcmp>
f0105a7e:	83 c4 10             	add    $0x10,%esp
f0105a81:	85 c0                	test   %eax,%eax
f0105a83:	75 18                	jne    f0105a9d <mpsearch1+0x86>
f0105a85:	89 d8                	mov    %ebx,%eax
f0105a87:	8d 7b 10             	lea    0x10(%ebx),%edi
f0105a8a:	ba 00 00 00 00       	mov    $0x0,%edx
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
		sum += ((uint8_t *)addr)[i];
f0105a8f:	0f b6 08             	movzbl (%eax),%ecx
f0105a92:	01 ca                	add    %ecx,%edx
f0105a94:	40                   	inc    %eax
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0105a95:	39 c7                	cmp    %eax,%edi
f0105a97:	75 f6                	jne    f0105a8f <mpsearch1+0x78>
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0105a99:	84 d2                	test   %dl,%dl
f0105a9b:	74 15                	je     f0105ab2 <mpsearch1+0x9b>
static struct mp *
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
f0105a9d:	83 c3 10             	add    $0x10,%ebx
f0105aa0:	39 f3                	cmp    %esi,%ebx
f0105aa2:	72 ca                	jb     f0105a6e <mpsearch1+0x57>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f0105aa4:	b8 00 00 00 00       	mov    $0x0,%eax
f0105aa9:	eb 09                	jmp    f0105ab4 <mpsearch1+0x9d>
f0105aab:	b8 00 00 00 00       	mov    $0x0,%eax
f0105ab0:	eb 02                	jmp    f0105ab4 <mpsearch1+0x9d>
f0105ab2:	89 d8                	mov    %ebx,%eax
}
f0105ab4:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105ab7:	5b                   	pop    %ebx
f0105ab8:	5e                   	pop    %esi
f0105ab9:	5f                   	pop    %edi
f0105aba:	5d                   	pop    %ebp
f0105abb:	c3                   	ret    

f0105abc <mp_init>:
	return conf;
}

void
mp_init(void)
{
f0105abc:	55                   	push   %ebp
f0105abd:	89 e5                	mov    %esp,%ebp
f0105abf:	57                   	push   %edi
f0105ac0:	56                   	push   %esi
f0105ac1:	53                   	push   %ebx
f0105ac2:	83 ec 1c             	sub    $0x1c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f0105ac5:	c7 05 c0 63 24 f0 20 	movl   $0xf0246020,0xf02463c0
f0105acc:	60 24 f0 
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105acf:	83 3d 88 5e 24 f0 00 	cmpl   $0x0,0xf0245e88
f0105ad6:	75 16                	jne    f0105aee <mp_init+0x32>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105ad8:	68 00 04 00 00       	push   $0x400
f0105add:	68 c4 64 10 f0       	push   $0xf01064c4
f0105ae2:	6a 6f                	push   $0x6f
f0105ae4:	68 3d 80 10 f0       	push   $0xf010803d
f0105ae9:	e8 52 a5 ff ff       	call   f0100040 <_panic>
	// The BIOS data area lives in 16-bit segment 0x40.
	bda = (uint8_t *) KADDR(0x40 << 4);

	// [MP 4] The 16-bit segment of the EBDA is in the two bytes
	// starting at byte 0x0E of the BDA.  0 if not present.
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f0105aee:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f0105af5:	85 c0                	test   %eax,%eax
f0105af7:	74 16                	je     f0105b0f <mp_init+0x53>
		p <<= 4;	// Translate from segment to PA
		if ((mp = mpsearch1(p, 1024)))
f0105af9:	c1 e0 04             	shl    $0x4,%eax
f0105afc:	ba 00 04 00 00       	mov    $0x400,%edx
f0105b01:	e8 11 ff ff ff       	call   f0105a17 <mpsearch1>
f0105b06:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105b09:	85 c0                	test   %eax,%eax
f0105b0b:	75 3c                	jne    f0105b49 <mp_init+0x8d>
f0105b0d:	eb 20                	jmp    f0105b2f <mp_init+0x73>
			return mp;
	} else {
		// The size of base memory, in KB is in the two bytes
		// starting at 0x13 of the BDA.
		p = *(uint16_t *) (bda + 0x13) * 1024;
		if ((mp = mpsearch1(p - 1024, 1024)))
f0105b0f:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f0105b16:	c1 e0 0a             	shl    $0xa,%eax
f0105b19:	2d 00 04 00 00       	sub    $0x400,%eax
f0105b1e:	ba 00 04 00 00       	mov    $0x400,%edx
f0105b23:	e8 ef fe ff ff       	call   f0105a17 <mpsearch1>
f0105b28:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105b2b:	85 c0                	test   %eax,%eax
f0105b2d:	75 1a                	jne    f0105b49 <mp_init+0x8d>
			return mp;
	}
	return mpsearch1(0xF0000, 0x10000);
f0105b2f:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105b34:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f0105b39:	e8 d9 fe ff ff       	call   f0105a17 <mpsearch1>
f0105b3e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
mpconfig(struct mp **pmp)
{
	struct mpconf *conf;
	struct mp *mp;

	if ((mp = mpsearch()) == 0)
f0105b41:	85 c0                	test   %eax,%eax
f0105b43:	0f 84 76 02 00 00    	je     f0105dbf <mp_init+0x303>
		return NULL;
	if (mp->physaddr == 0 || mp->type != 0) {
f0105b49:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105b4c:	8b 70 04             	mov    0x4(%eax),%esi
f0105b4f:	85 f6                	test   %esi,%esi
f0105b51:	74 06                	je     f0105b59 <mp_init+0x9d>
f0105b53:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f0105b57:	74 15                	je     f0105b6e <mp_init+0xb2>
		cprintf("SMP: Default configurations not implemented\n");
f0105b59:	83 ec 0c             	sub    $0xc,%esp
f0105b5c:	68 b0 7e 10 f0       	push   $0xf0107eb0
f0105b61:	e8 aa dc ff ff       	call   f0103810 <cprintf>
f0105b66:	83 c4 10             	add    $0x10,%esp
f0105b69:	e9 51 02 00 00       	jmp    f0105dbf <mp_init+0x303>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105b6e:	89 f0                	mov    %esi,%eax
f0105b70:	c1 e8 0c             	shr    $0xc,%eax
f0105b73:	3b 05 88 5e 24 f0    	cmp    0xf0245e88,%eax
f0105b79:	72 15                	jb     f0105b90 <mp_init+0xd4>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105b7b:	56                   	push   %esi
f0105b7c:	68 c4 64 10 f0       	push   $0xf01064c4
f0105b81:	68 90 00 00 00       	push   $0x90
f0105b86:	68 3d 80 10 f0       	push   $0xf010803d
f0105b8b:	e8 b0 a4 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0105b90:	8d 9e 00 00 00 f0    	lea    -0x10000000(%esi),%ebx
		return NULL;
	}
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
f0105b96:	83 ec 04             	sub    $0x4,%esp
f0105b99:	6a 04                	push   $0x4
f0105b9b:	68 52 80 10 f0       	push   $0xf0108052
f0105ba0:	53                   	push   %ebx
f0105ba1:	e8 85 fc ff ff       	call   f010582b <memcmp>
f0105ba6:	83 c4 10             	add    $0x10,%esp
f0105ba9:	85 c0                	test   %eax,%eax
f0105bab:	74 15                	je     f0105bc2 <mp_init+0x106>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f0105bad:	83 ec 0c             	sub    $0xc,%esp
f0105bb0:	68 e0 7e 10 f0       	push   $0xf0107ee0
f0105bb5:	e8 56 dc ff ff       	call   f0103810 <cprintf>
f0105bba:	83 c4 10             	add    $0x10,%esp
f0105bbd:	e9 fd 01 00 00       	jmp    f0105dbf <mp_init+0x303>
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f0105bc2:	66 8b 43 04          	mov    0x4(%ebx),%ax
f0105bc6:	66 89 45 e2          	mov    %ax,-0x1e(%ebp)
f0105bca:	0f b7 f8             	movzwl %ax,%edi
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0105bcd:	85 ff                	test   %edi,%edi
f0105bcf:	7e 32                	jle    f0105c03 <mp_init+0x147>
f0105bd1:	ba 00 00 00 00       	mov    $0x0,%edx
f0105bd6:	b8 00 00 00 00       	mov    $0x0,%eax
		sum += ((uint8_t *)addr)[i];
f0105bdb:	0f b6 8c 30 00 00 00 	movzbl -0x10000000(%eax,%esi,1),%ecx
f0105be2:	f0 
f0105be3:	01 ca                	add    %ecx,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0105be5:	40                   	inc    %eax
f0105be6:	39 c7                	cmp    %eax,%edi
f0105be8:	7f f1                	jg     f0105bdb <mp_init+0x11f>
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
		cprintf("SMP: Incorrect MP configuration table signature\n");
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f0105bea:	84 d2                	test   %dl,%dl
f0105bec:	74 15                	je     f0105c03 <mp_init+0x147>
		cprintf("SMP: Bad MP configuration checksum\n");
f0105bee:	83 ec 0c             	sub    $0xc,%esp
f0105bf1:	68 14 7f 10 f0       	push   $0xf0107f14
f0105bf6:	e8 15 dc ff ff       	call   f0103810 <cprintf>
f0105bfb:	83 c4 10             	add    $0x10,%esp
f0105bfe:	e9 bc 01 00 00       	jmp    f0105dbf <mp_init+0x303>
		return NULL;
	}
	if (conf->version != 1 && conf->version != 4) {
f0105c03:	8a 43 06             	mov    0x6(%ebx),%al
f0105c06:	3c 01                	cmp    $0x1,%al
f0105c08:	74 1d                	je     f0105c27 <mp_init+0x16b>
f0105c0a:	3c 04                	cmp    $0x4,%al
f0105c0c:	74 19                	je     f0105c27 <mp_init+0x16b>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f0105c0e:	83 ec 08             	sub    $0x8,%esp
f0105c11:	0f b6 c0             	movzbl %al,%eax
f0105c14:	50                   	push   %eax
f0105c15:	68 38 7f 10 f0       	push   $0xf0107f38
f0105c1a:	e8 f1 db ff ff       	call   f0103810 <cprintf>
f0105c1f:	83 c4 10             	add    $0x10,%esp
f0105c22:	e9 98 01 00 00       	jmp    f0105dbf <mp_init+0x303>
		return NULL;
	}
	if (sum((uint8_t *)conf + conf->length, conf->xlength) != conf->xchecksum) {
f0105c27:	0f b7 4b 28          	movzwl 0x28(%ebx),%ecx
f0105c2b:	0f b7 7d e2          	movzwl -0x1e(%ebp),%edi
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0105c2f:	85 c9                	test   %ecx,%ecx
f0105c31:	7e 1d                	jle    f0105c50 <mp_init+0x194>
f0105c33:	ba 00 00 00 00       	mov    $0x0,%edx
f0105c38:	b8 00 00 00 00       	mov    $0x0,%eax
		sum += ((uint8_t *)addr)[i];
f0105c3d:	01 fe                	add    %edi,%esi
f0105c3f:	0f b6 bc 06 00 00 00 	movzbl -0x10000000(%esi,%eax,1),%edi
f0105c46:	f0 
f0105c47:	01 fa                	add    %edi,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0105c49:	40                   	inc    %eax
f0105c4a:	39 c1                	cmp    %eax,%ecx
f0105c4c:	7f f1                	jg     f0105c3f <mp_init+0x183>
f0105c4e:	eb 05                	jmp    f0105c55 <mp_init+0x199>
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f0105c50:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	if (conf->version != 1 && conf->version != 4) {
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
		return NULL;
	}
	if (sum((uint8_t *)conf + conf->length, conf->xlength) != conf->xchecksum) {
f0105c55:	38 53 2a             	cmp    %dl,0x2a(%ebx)
f0105c58:	74 15                	je     f0105c6f <mp_init+0x1b3>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f0105c5a:	83 ec 0c             	sub    $0xc,%esp
f0105c5d:	68 58 7f 10 f0       	push   $0xf0107f58
f0105c62:	e8 a9 db ff ff       	call   f0103810 <cprintf>
f0105c67:	83 c4 10             	add    $0x10,%esp
f0105c6a:	e9 50 01 00 00       	jmp    f0105dbf <mp_init+0x303>
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
	if ((conf = mpconfig(&mp)) == 0)
f0105c6f:	85 db                	test   %ebx,%ebx
f0105c71:	0f 84 48 01 00 00    	je     f0105dbf <mp_init+0x303>
		return;
	ismp = 1;
f0105c77:	c7 05 00 60 24 f0 01 	movl   $0x1,0xf0246000
f0105c7e:	00 00 00 
	lapicaddr = conf->lapicaddr;
f0105c81:	8b 43 24             	mov    0x24(%ebx),%eax
f0105c84:	a3 00 70 28 f0       	mov    %eax,0xf0287000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0105c89:	8d 7b 2c             	lea    0x2c(%ebx),%edi
f0105c8c:	66 83 7b 22 00       	cmpw   $0x0,0x22(%ebx)
f0105c91:	0f 84 a8 00 00 00    	je     f0105d3f <mp_init+0x283>
f0105c97:	be 00 00 00 00       	mov    $0x0,%esi
		switch (*p) {
f0105c9c:	8a 07                	mov    (%edi),%al
f0105c9e:	84 c0                	test   %al,%al
f0105ca0:	74 06                	je     f0105ca8 <mp_init+0x1ec>
f0105ca2:	3c 04                	cmp    $0x4,%al
f0105ca4:	77 6a                	ja     f0105d10 <mp_init+0x254>
f0105ca6:	eb 63                	jmp    f0105d0b <mp_init+0x24f>
		case MPPROC:
			proc = (struct mpproc *)p;
			if (proc->flags & MPPROC_BOOT)
f0105ca8:	f6 47 03 02          	testb  $0x2,0x3(%edi)
f0105cac:	74 1e                	je     f0105ccc <mp_init+0x210>
				bootcpu = &cpus[ncpu];
f0105cae:	8b 15 c4 63 24 f0    	mov    0xf02463c4,%edx
f0105cb4:	8d 04 12             	lea    (%edx,%edx,1),%eax
f0105cb7:	01 d0                	add    %edx,%eax
f0105cb9:	01 c0                	add    %eax,%eax
f0105cbb:	01 d0                	add    %edx,%eax
f0105cbd:	8d 04 82             	lea    (%edx,%eax,4),%eax
f0105cc0:	8d 04 85 20 60 24 f0 	lea    -0xfdb9fe0(,%eax,4),%eax
f0105cc7:	a3 c0 63 24 f0       	mov    %eax,0xf02463c0
			if (ncpu < NCPU) {
f0105ccc:	a1 c4 63 24 f0       	mov    0xf02463c4,%eax
f0105cd1:	83 f8 07             	cmp    $0x7,%eax
f0105cd4:	7f 1b                	jg     f0105cf1 <mp_init+0x235>
				cpus[ncpu].cpu_id = ncpu;
f0105cd6:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0105cd9:	01 c2                	add    %eax,%edx
f0105cdb:	01 d2                	add    %edx,%edx
f0105cdd:	01 c2                	add    %eax,%edx
f0105cdf:	8d 14 90             	lea    (%eax,%edx,4),%edx
f0105ce2:	88 04 95 20 60 24 f0 	mov    %al,-0xfdb9fe0(,%edx,4)
				ncpu++;
f0105ce9:	40                   	inc    %eax
f0105cea:	a3 c4 63 24 f0       	mov    %eax,0xf02463c4
f0105cef:	eb 15                	jmp    f0105d06 <mp_init+0x24a>
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f0105cf1:	83 ec 08             	sub    $0x8,%esp
f0105cf4:	0f b6 47 01          	movzbl 0x1(%edi),%eax
f0105cf8:	50                   	push   %eax
f0105cf9:	68 88 7f 10 f0       	push   $0xf0107f88
f0105cfe:	e8 0d db ff ff       	call   f0103810 <cprintf>
f0105d03:	83 c4 10             	add    $0x10,%esp
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f0105d06:	83 c7 14             	add    $0x14,%edi
			continue;
f0105d09:	eb 27                	jmp    f0105d32 <mp_init+0x276>
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f0105d0b:	83 c7 08             	add    $0x8,%edi
			continue;
f0105d0e:	eb 22                	jmp    f0105d32 <mp_init+0x276>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f0105d10:	83 ec 08             	sub    $0x8,%esp
f0105d13:	0f b6 c0             	movzbl %al,%eax
f0105d16:	50                   	push   %eax
f0105d17:	68 b0 7f 10 f0       	push   $0xf0107fb0
f0105d1c:	e8 ef da ff ff       	call   f0103810 <cprintf>
			ismp = 0;
f0105d21:	c7 05 00 60 24 f0 00 	movl   $0x0,0xf0246000
f0105d28:	00 00 00 
			i = conf->entry;
f0105d2b:	0f b7 73 22          	movzwl 0x22(%ebx),%esi
f0105d2f:	83 c4 10             	add    $0x10,%esp
	if ((conf = mpconfig(&mp)) == 0)
		return;
	ismp = 1;
	lapicaddr = conf->lapicaddr;

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0105d32:	46                   	inc    %esi
f0105d33:	0f b7 43 22          	movzwl 0x22(%ebx),%eax
f0105d37:	39 f0                	cmp    %esi,%eax
f0105d39:	0f 87 5d ff ff ff    	ja     f0105c9c <mp_init+0x1e0>
			ismp = 0;
			i = conf->entry;
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f0105d3f:	a1 c0 63 24 f0       	mov    0xf02463c0,%eax
f0105d44:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f0105d4b:	83 3d 00 60 24 f0 00 	cmpl   $0x0,0xf0246000
f0105d52:	75 26                	jne    f0105d7a <mp_init+0x2be>
		// Didn't like what we found; fall back to no MP.
		ncpu = 1;
f0105d54:	c7 05 c4 63 24 f0 01 	movl   $0x1,0xf02463c4
f0105d5b:	00 00 00 
		lapicaddr = 0;
f0105d5e:	c7 05 00 70 28 f0 00 	movl   $0x0,0xf0287000
f0105d65:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f0105d68:	83 ec 0c             	sub    $0xc,%esp
f0105d6b:	68 d0 7f 10 f0       	push   $0xf0107fd0
f0105d70:	e8 9b da ff ff       	call   f0103810 <cprintf>
		return;
f0105d75:	83 c4 10             	add    $0x10,%esp
f0105d78:	eb 45                	jmp    f0105dbf <mp_init+0x303>
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f0105d7a:	83 ec 04             	sub    $0x4,%esp
f0105d7d:	ff 35 c4 63 24 f0    	pushl  0xf02463c4
f0105d83:	0f b6 00             	movzbl (%eax),%eax
f0105d86:	50                   	push   %eax
f0105d87:	68 57 80 10 f0       	push   $0xf0108057
f0105d8c:	e8 7f da ff ff       	call   f0103810 <cprintf>

	if (mp->imcrp) {
f0105d91:	83 c4 10             	add    $0x10,%esp
f0105d94:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105d97:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f0105d9b:	74 22                	je     f0105dbf <mp_init+0x303>
		// [MP 3.2.6.1] If the hardware implements PIC mode,
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f0105d9d:	83 ec 0c             	sub    $0xc,%esp
f0105da0:	68 fc 7f 10 f0       	push   $0xf0107ffc
f0105da5:	e8 66 da ff ff       	call   f0103810 <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0105daa:	ba 22 00 00 00       	mov    $0x22,%edx
f0105daf:	b0 70                	mov    $0x70,%al
f0105db1:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0105db2:	ba 23 00 00 00       	mov    $0x23,%edx
f0105db7:	ec                   	in     (%dx),%al
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0105db8:	83 c8 01             	or     $0x1,%eax
f0105dbb:	ee                   	out    %al,(%dx)
f0105dbc:	83 c4 10             	add    $0x10,%esp
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
	}
}
f0105dbf:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105dc2:	5b                   	pop    %ebx
f0105dc3:	5e                   	pop    %esi
f0105dc4:	5f                   	pop    %edi
f0105dc5:	5d                   	pop    %ebp
f0105dc6:	c3                   	ret    

f0105dc7 <lapicw>:
physaddr_t lapicaddr;        // Initialized in mpconfig.c
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
f0105dc7:	55                   	push   %ebp
f0105dc8:	89 e5                	mov    %esp,%ebp
	lapic[index] = value;
f0105dca:	8b 0d 04 70 28 f0    	mov    0xf0287004,%ecx
f0105dd0:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f0105dd3:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f0105dd5:	a1 04 70 28 f0       	mov    0xf0287004,%eax
f0105dda:	8b 40 20             	mov    0x20(%eax),%eax
}
f0105ddd:	5d                   	pop    %ebp
f0105dde:	c3                   	ret    

f0105ddf <cpunum>:
	lapicw(TPR, 0);
}

int
cpunum(void)
{
f0105ddf:	55                   	push   %ebp
f0105de0:	89 e5                	mov    %esp,%ebp
	if (lapic)
f0105de2:	a1 04 70 28 f0       	mov    0xf0287004,%eax
f0105de7:	85 c0                	test   %eax,%eax
f0105de9:	74 08                	je     f0105df3 <cpunum+0x14>
		return lapic[ID] >> 24;
f0105deb:	8b 40 20             	mov    0x20(%eax),%eax
f0105dee:	c1 e8 18             	shr    $0x18,%eax
f0105df1:	eb 05                	jmp    f0105df8 <cpunum+0x19>
	return 0;
f0105df3:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105df8:	5d                   	pop    %ebp
f0105df9:	c3                   	ret    

f0105dfa <lapic_init>:
}

void
lapic_init(void)
{
	if (!lapicaddr)
f0105dfa:	a1 00 70 28 f0       	mov    0xf0287000,%eax
f0105dff:	85 c0                	test   %eax,%eax
f0105e01:	0f 84 2c 01 00 00    	je     f0105f33 <lapic_init+0x139>
	lapic[ID];  // wait for write to finish, by reading
}

void
lapic_init(void)
{
f0105e07:	55                   	push   %ebp
f0105e08:	89 e5                	mov    %esp,%ebp
f0105e0a:	83 ec 10             	sub    $0x10,%esp
	if (!lapicaddr)
		return;

	// lapicaddr is the physical address of the LAPIC's 4K MMIO
	// region.  Map it in to virtual memory so we can access it.
	lapic = mmio_map_region(lapicaddr, 4096);
f0105e0d:	68 00 10 00 00       	push   $0x1000
f0105e12:	50                   	push   %eax
f0105e13:	e8 bc b4 ff ff       	call   f01012d4 <mmio_map_region>
f0105e18:	a3 04 70 28 f0       	mov    %eax,0xf0287004

	// Enable local APIC; set spurious interrupt vector.
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f0105e1d:	ba 27 01 00 00       	mov    $0x127,%edx
f0105e22:	b8 3c 00 00 00       	mov    $0x3c,%eax
f0105e27:	e8 9b ff ff ff       	call   f0105dc7 <lapicw>

	// The timer repeatedly counts down at bus frequency
	// from lapic[TICR] and then issues an interrupt.  
	// If we cared more about precise timekeeping,
	// TICR would be calibrated using an external time source.
	lapicw(TDCR, X1);
f0105e2c:	ba 0b 00 00 00       	mov    $0xb,%edx
f0105e31:	b8 f8 00 00 00       	mov    $0xf8,%eax
f0105e36:	e8 8c ff ff ff       	call   f0105dc7 <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f0105e3b:	ba 20 00 02 00       	mov    $0x20020,%edx
f0105e40:	b8 c8 00 00 00       	mov    $0xc8,%eax
f0105e45:	e8 7d ff ff ff       	call   f0105dc7 <lapicw>
	lapicw(TICR, 10000000); 
f0105e4a:	ba 80 96 98 00       	mov    $0x989680,%edx
f0105e4f:	b8 e0 00 00 00       	mov    $0xe0,%eax
f0105e54:	e8 6e ff ff ff       	call   f0105dc7 <lapicw>
	//
	// According to Intel MP Specification, the BIOS should initialize
	// BSP's local APIC in Virtual Wire Mode, in which 8259A's
	// INTR is virtually connected to BSP's LINTIN0. In this mode,
	// we do not need to program the IOAPIC.
	if (thiscpu != bootcpu)
f0105e59:	e8 81 ff ff ff       	call   f0105ddf <cpunum>
f0105e5e:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0105e61:	01 c2                	add    %eax,%edx
f0105e63:	01 d2                	add    %edx,%edx
f0105e65:	01 c2                	add    %eax,%edx
f0105e67:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0105e6a:	8d 04 85 20 60 24 f0 	lea    -0xfdb9fe0(,%eax,4),%eax
f0105e71:	83 c4 10             	add    $0x10,%esp
f0105e74:	39 05 c0 63 24 f0    	cmp    %eax,0xf02463c0
f0105e7a:	74 0f                	je     f0105e8b <lapic_init+0x91>
		lapicw(LINT0, MASKED);
f0105e7c:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105e81:	b8 d4 00 00 00       	mov    $0xd4,%eax
f0105e86:	e8 3c ff ff ff       	call   f0105dc7 <lapicw>

	// Disable NMI (LINT1) on all CPUs
	lapicw(LINT1, MASKED);
f0105e8b:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105e90:	b8 d8 00 00 00       	mov    $0xd8,%eax
f0105e95:	e8 2d ff ff ff       	call   f0105dc7 <lapicw>

	// Disable performance counter overflow interrupts
	// on machines that provide that interrupt entry.
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f0105e9a:	a1 04 70 28 f0       	mov    0xf0287004,%eax
f0105e9f:	8b 40 30             	mov    0x30(%eax),%eax
f0105ea2:	c1 e8 10             	shr    $0x10,%eax
f0105ea5:	3c 03                	cmp    $0x3,%al
f0105ea7:	76 0f                	jbe    f0105eb8 <lapic_init+0xbe>
		lapicw(PCINT, MASKED);
f0105ea9:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105eae:	b8 d0 00 00 00       	mov    $0xd0,%eax
f0105eb3:	e8 0f ff ff ff       	call   f0105dc7 <lapicw>

	// Map error interrupt to IRQ_ERROR.
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f0105eb8:	ba 33 00 00 00       	mov    $0x33,%edx
f0105ebd:	b8 dc 00 00 00       	mov    $0xdc,%eax
f0105ec2:	e8 00 ff ff ff       	call   f0105dc7 <lapicw>

	// Clear error status register (requires back-to-back writes).
	lapicw(ESR, 0);
f0105ec7:	ba 00 00 00 00       	mov    $0x0,%edx
f0105ecc:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0105ed1:	e8 f1 fe ff ff       	call   f0105dc7 <lapicw>
	lapicw(ESR, 0);
f0105ed6:	ba 00 00 00 00       	mov    $0x0,%edx
f0105edb:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0105ee0:	e8 e2 fe ff ff       	call   f0105dc7 <lapicw>

	// Ack any outstanding interrupts.
	lapicw(EOI, 0);
f0105ee5:	ba 00 00 00 00       	mov    $0x0,%edx
f0105eea:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0105eef:	e8 d3 fe ff ff       	call   f0105dc7 <lapicw>

	// Send an Init Level De-Assert to synchronize arbitration ID's.
	lapicw(ICRHI, 0);
f0105ef4:	ba 00 00 00 00       	mov    $0x0,%edx
f0105ef9:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105efe:	e8 c4 fe ff ff       	call   f0105dc7 <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f0105f03:	ba 00 85 08 00       	mov    $0x88500,%edx
f0105f08:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105f0d:	e8 b5 fe ff ff       	call   f0105dc7 <lapicw>
	while(lapic[ICRLO] & DELIVS)
f0105f12:	8b 15 04 70 28 f0    	mov    0xf0287004,%edx
f0105f18:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0105f1e:	f6 c4 10             	test   $0x10,%ah
f0105f21:	75 f5                	jne    f0105f18 <lapic_init+0x11e>
		;

	// Enable interrupts on the APIC (but not on the processor).
	lapicw(TPR, 0);
f0105f23:	ba 00 00 00 00       	mov    $0x0,%edx
f0105f28:	b8 20 00 00 00       	mov    $0x20,%eax
f0105f2d:	e8 95 fe ff ff       	call   f0105dc7 <lapicw>
}
f0105f32:	c9                   	leave  
f0105f33:	c3                   	ret    

f0105f34 <lapic_eoi>:

// Acknowledge interrupt.
void
lapic_eoi(void)
{
	if (lapic)
f0105f34:	83 3d 04 70 28 f0 00 	cmpl   $0x0,0xf0287004
f0105f3b:	74 13                	je     f0105f50 <lapic_eoi+0x1c>
}

// Acknowledge interrupt.
void
lapic_eoi(void)
{
f0105f3d:	55                   	push   %ebp
f0105f3e:	89 e5                	mov    %esp,%ebp
	if (lapic)
		lapicw(EOI, 0);
f0105f40:	ba 00 00 00 00       	mov    $0x0,%edx
f0105f45:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0105f4a:	e8 78 fe ff ff       	call   f0105dc7 <lapicw>
}
f0105f4f:	5d                   	pop    %ebp
f0105f50:	c3                   	ret    

f0105f51 <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f0105f51:	55                   	push   %ebp
f0105f52:	89 e5                	mov    %esp,%ebp
f0105f54:	56                   	push   %esi
f0105f55:	53                   	push   %ebx
f0105f56:	8b 75 08             	mov    0x8(%ebp),%esi
f0105f59:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105f5c:	ba 70 00 00 00       	mov    $0x70,%edx
f0105f61:	b0 0f                	mov    $0xf,%al
f0105f63:	ee                   	out    %al,(%dx)
f0105f64:	ba 71 00 00 00       	mov    $0x71,%edx
f0105f69:	b0 0a                	mov    $0xa,%al
f0105f6b:	ee                   	out    %al,(%dx)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105f6c:	83 3d 88 5e 24 f0 00 	cmpl   $0x0,0xf0245e88
f0105f73:	75 19                	jne    f0105f8e <lapic_startap+0x3d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105f75:	68 67 04 00 00       	push   $0x467
f0105f7a:	68 c4 64 10 f0       	push   $0xf01064c4
f0105f7f:	68 98 00 00 00       	push   $0x98
f0105f84:	68 74 80 10 f0       	push   $0xf0108074
f0105f89:	e8 b2 a0 ff ff       	call   f0100040 <_panic>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f0105f8e:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f0105f95:	00 00 
	wrv[1] = addr >> 4;
f0105f97:	89 d8                	mov    %ebx,%eax
f0105f99:	c1 e8 04             	shr    $0x4,%eax
f0105f9c:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f0105fa2:	c1 e6 18             	shl    $0x18,%esi
f0105fa5:	89 f2                	mov    %esi,%edx
f0105fa7:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105fac:	e8 16 fe ff ff       	call   f0105dc7 <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f0105fb1:	ba 00 c5 00 00       	mov    $0xc500,%edx
f0105fb6:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105fbb:	e8 07 fe ff ff       	call   f0105dc7 <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f0105fc0:	ba 00 85 00 00       	mov    $0x8500,%edx
f0105fc5:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105fca:	e8 f8 fd ff ff       	call   f0105dc7 <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105fcf:	c1 eb 0c             	shr    $0xc,%ebx
f0105fd2:	80 cf 06             	or     $0x6,%bh
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0105fd5:	89 f2                	mov    %esi,%edx
f0105fd7:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105fdc:	e8 e6 fd ff ff       	call   f0105dc7 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105fe1:	89 da                	mov    %ebx,%edx
f0105fe3:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105fe8:	e8 da fd ff ff       	call   f0105dc7 <lapicw>
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0105fed:	89 f2                	mov    %esi,%edx
f0105fef:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105ff4:	e8 ce fd ff ff       	call   f0105dc7 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105ff9:	89 da                	mov    %ebx,%edx
f0105ffb:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106000:	e8 c2 fd ff ff       	call   f0105dc7 <lapicw>
		microdelay(200);
	}
}
f0106005:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0106008:	5b                   	pop    %ebx
f0106009:	5e                   	pop    %esi
f010600a:	5d                   	pop    %ebp
f010600b:	c3                   	ret    

f010600c <lapic_ipi>:

void
lapic_ipi(int vector)
{
f010600c:	55                   	push   %ebp
f010600d:	89 e5                	mov    %esp,%ebp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f010600f:	8b 55 08             	mov    0x8(%ebp),%edx
f0106012:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f0106018:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010601d:	e8 a5 fd ff ff       	call   f0105dc7 <lapicw>
	while (lapic[ICRLO] & DELIVS)
f0106022:	8b 15 04 70 28 f0    	mov    0xf0287004,%edx
f0106028:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f010602e:	f6 c4 10             	test   $0x10,%ah
f0106031:	75 f5                	jne    f0106028 <lapic_ipi+0x1c>
		;
}
f0106033:	5d                   	pop    %ebp
f0106034:	c3                   	ret    

f0106035 <__spin_initlock>:
}
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f0106035:	55                   	push   %ebp
f0106036:	89 e5                	mov    %esp,%ebp
f0106038:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f010603b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f0106041:	8b 55 0c             	mov    0xc(%ebp),%edx
f0106044:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f0106047:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f010604e:	5d                   	pop    %ebp
f010604f:	c3                   	ret    

f0106050 <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f0106050:	55                   	push   %ebp
f0106051:	89 e5                	mov    %esp,%ebp
f0106053:	56                   	push   %esi
f0106054:	53                   	push   %ebx
f0106055:	8b 5d 08             	mov    0x8(%ebp),%ebx

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
	return lock->locked && lock->cpu == thiscpu;
f0106058:	83 3b 00             	cmpl   $0x0,(%ebx)
f010605b:	74 1f                	je     f010607c <spin_lock+0x2c>
f010605d:	8b 73 08             	mov    0x8(%ebx),%esi
f0106060:	e8 7a fd ff ff       	call   f0105ddf <cpunum>
f0106065:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0106068:	01 c2                	add    %eax,%edx
f010606a:	01 d2                	add    %edx,%edx
f010606c:	01 c2                	add    %eax,%edx
f010606e:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0106071:	8d 04 85 20 60 24 f0 	lea    -0xfdb9fe0(,%eax,4),%eax
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f0106078:	39 c6                	cmp    %eax,%esi
f010607a:	74 15                	je     f0106091 <spin_lock+0x41>
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f010607c:	89 da                	mov    %ebx,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f010607e:	b8 01 00 00 00       	mov    $0x1,%eax
f0106083:	f0 87 03             	lock xchg %eax,(%ebx)
f0106086:	b9 01 00 00 00       	mov    $0x1,%ecx
f010608b:	85 c0                	test   %eax,%eax
f010608d:	75 20                	jne    f01060af <spin_lock+0x5f>
f010608f:	eb 29                	jmp    f01060ba <spin_lock+0x6a>
void
spin_lock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f0106091:	8b 5b 04             	mov    0x4(%ebx),%ebx
f0106094:	e8 46 fd ff ff       	call   f0105ddf <cpunum>
f0106099:	83 ec 0c             	sub    $0xc,%esp
f010609c:	53                   	push   %ebx
f010609d:	50                   	push   %eax
f010609e:	68 84 80 10 f0       	push   $0xf0108084
f01060a3:	6a 41                	push   $0x41
f01060a5:	68 e8 80 10 f0       	push   $0xf01080e8
f01060aa:	e8 91 9f ff ff       	call   f0100040 <_panic>

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f01060af:	f3 90                	pause  
f01060b1:	89 c8                	mov    %ecx,%eax
f01060b3:	f0 87 02             	lock xchg %eax,(%edx)
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f01060b6:	85 c0                	test   %eax,%eax
f01060b8:	75 f5                	jne    f01060af <spin_lock+0x5f>
		asm volatile ("pause");

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f01060ba:	e8 20 fd ff ff       	call   f0105ddf <cpunum>
f01060bf:	8d 14 00             	lea    (%eax,%eax,1),%edx
f01060c2:	01 c2                	add    %eax,%edx
f01060c4:	01 d2                	add    %edx,%edx
f01060c6:	01 c2                	add    %eax,%edx
f01060c8:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01060cb:	8d 04 85 20 60 24 f0 	lea    -0xfdb9fe0(,%eax,4),%eax
f01060d2:	89 43 08             	mov    %eax,0x8(%ebx)
	get_caller_pcs(lk->pcs);
f01060d5:	8d 4b 0c             	lea    0xc(%ebx),%ecx

static __inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	__asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f01060d8:	89 e8                	mov    %ebp,%eax
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f01060da:	3d ff ff 7f ef       	cmp    $0xef7fffff,%eax
f01060df:	77 30                	ja     f0106111 <spin_lock+0xc1>
f01060e1:	eb 27                	jmp    f010610a <spin_lock+0xba>
f01060e3:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f01060e9:	76 10                	jbe    f01060fb <spin_lock+0xab>
			break;
		pcs[i] = ebp[1];          // saved %eip
f01060eb:	8b 5a 04             	mov    0x4(%edx),%ebx
f01060ee:	89 1c 81             	mov    %ebx,(%ecx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f01060f1:	8b 12                	mov    (%edx),%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f01060f3:	40                   	inc    %eax
f01060f4:	83 f8 0a             	cmp    $0xa,%eax
f01060f7:	75 ea                	jne    f01060e3 <spin_lock+0x93>
f01060f9:	eb 25                	jmp    f0106120 <spin_lock+0xd0>
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
		pcs[i] = 0;
f01060fb:	c7 04 81 00 00 00 00 	movl   $0x0,(%ecx,%eax,4)
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
f0106102:	40                   	inc    %eax
f0106103:	83 f8 09             	cmp    $0x9,%eax
f0106106:	7e f3                	jle    f01060fb <spin_lock+0xab>
f0106108:	eb 16                	jmp    f0106120 <spin_lock+0xd0>
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f010610a:	b8 00 00 00 00       	mov    $0x0,%eax
f010610f:	eb ea                	jmp    f01060fb <spin_lock+0xab>
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
f0106111:	8b 50 04             	mov    0x4(%eax),%edx
f0106114:	89 53 0c             	mov    %edx,0xc(%ebx)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f0106117:	8b 10                	mov    (%eax),%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f0106119:	b8 01 00 00 00       	mov    $0x1,%eax
f010611e:	eb c3                	jmp    f01060e3 <spin_lock+0x93>
	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
	get_caller_pcs(lk->pcs);
#endif
}
f0106120:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0106123:	5b                   	pop    %ebx
f0106124:	5e                   	pop    %esi
f0106125:	5d                   	pop    %ebp
f0106126:	c3                   	ret    

f0106127 <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f0106127:	55                   	push   %ebp
f0106128:	89 e5                	mov    %esp,%ebp
f010612a:	57                   	push   %edi
f010612b:	56                   	push   %esi
f010612c:	53                   	push   %ebx
f010612d:	83 ec 4c             	sub    $0x4c,%esp
f0106130:	8b 5d 08             	mov    0x8(%ebp),%ebx

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
	return lock->locked && lock->cpu == thiscpu;
f0106133:	83 3b 00             	cmpl   $0x0,(%ebx)
f0106136:	74 23                	je     f010615b <spin_unlock+0x34>
f0106138:	8b 73 08             	mov    0x8(%ebx),%esi
f010613b:	e8 9f fc ff ff       	call   f0105ddf <cpunum>
f0106140:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0106143:	01 c2                	add    %eax,%edx
f0106145:	01 d2                	add    %edx,%edx
f0106147:	01 c2                	add    %eax,%edx
f0106149:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010614c:	8d 04 85 20 60 24 f0 	lea    -0xfdb9fe0(,%eax,4),%eax
// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
f0106153:	39 c6                	cmp    %eax,%esi
f0106155:	0f 84 ab 00 00 00    	je     f0106206 <spin_unlock+0xdf>
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f010615b:	83 ec 04             	sub    $0x4,%esp
f010615e:	6a 28                	push   $0x28
f0106160:	8d 43 0c             	lea    0xc(%ebx),%eax
f0106163:	50                   	push   %eax
f0106164:	8d 45 c0             	lea    -0x40(%ebp),%eax
f0106167:	50                   	push   %eax
f0106168:	e8 45 f6 ff ff       	call   f01057b2 <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f010616d:	8b 43 08             	mov    0x8(%ebx),%eax
	if (!holding(lk)) {
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f0106170:	0f b6 30             	movzbl (%eax),%esi
f0106173:	8b 5b 04             	mov    0x4(%ebx),%ebx
f0106176:	e8 64 fc ff ff       	call   f0105ddf <cpunum>
f010617b:	56                   	push   %esi
f010617c:	53                   	push   %ebx
f010617d:	50                   	push   %eax
f010617e:	68 b0 80 10 f0       	push   $0xf01080b0
f0106183:	e8 88 d6 ff ff       	call   f0103810 <cprintf>
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f0106188:	8b 45 c0             	mov    -0x40(%ebp),%eax
f010618b:	83 c4 20             	add    $0x20,%esp
f010618e:	85 c0                	test   %eax,%eax
f0106190:	74 60                	je     f01061f2 <spin_unlock+0xcb>
f0106192:	8d 5d c0             	lea    -0x40(%ebp),%ebx
f0106195:	8d 7d e4             	lea    -0x1c(%ebp),%edi
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f0106198:	8d 75 a8             	lea    -0x58(%ebp),%esi
f010619b:	83 ec 08             	sub    $0x8,%esp
f010619e:	56                   	push   %esi
f010619f:	50                   	push   %eax
f01061a0:	e8 46 eb ff ff       	call   f0104ceb <debuginfo_eip>
f01061a5:	83 c4 10             	add    $0x10,%esp
f01061a8:	85 c0                	test   %eax,%eax
f01061aa:	78 27                	js     f01061d3 <spin_unlock+0xac>
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
f01061ac:	8b 03                	mov    (%ebx),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f01061ae:	83 ec 04             	sub    $0x4,%esp
f01061b1:	89 c2                	mov    %eax,%edx
f01061b3:	2b 55 b8             	sub    -0x48(%ebp),%edx
f01061b6:	52                   	push   %edx
f01061b7:	ff 75 b0             	pushl  -0x50(%ebp)
f01061ba:	ff 75 b4             	pushl  -0x4c(%ebp)
f01061bd:	ff 75 ac             	pushl  -0x54(%ebp)
f01061c0:	ff 75 a8             	pushl  -0x58(%ebp)
f01061c3:	50                   	push   %eax
f01061c4:	68 f8 80 10 f0       	push   $0xf01080f8
f01061c9:	e8 42 d6 ff ff       	call   f0103810 <cprintf>
f01061ce:	83 c4 20             	add    $0x20,%esp
f01061d1:	eb 12                	jmp    f01061e5 <spin_unlock+0xbe>
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
f01061d3:	83 ec 08             	sub    $0x8,%esp
f01061d6:	ff 33                	pushl  (%ebx)
f01061d8:	68 0f 81 10 f0       	push   $0xf010810f
f01061dd:	e8 2e d6 ff ff       	call   f0103810 <cprintf>
f01061e2:	83 c4 10             	add    $0x10,%esp
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f01061e5:	39 fb                	cmp    %edi,%ebx
f01061e7:	74 09                	je     f01061f2 <spin_unlock+0xcb>
f01061e9:	83 c3 04             	add    $0x4,%ebx
f01061ec:	8b 03                	mov    (%ebx),%eax
f01061ee:	85 c0                	test   %eax,%eax
f01061f0:	75 a9                	jne    f010619b <spin_unlock+0x74>
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
f01061f2:	83 ec 04             	sub    $0x4,%esp
f01061f5:	68 17 81 10 f0       	push   $0xf0108117
f01061fa:	6a 67                	push   $0x67
f01061fc:	68 e8 80 10 f0       	push   $0xf01080e8
f0106201:	e8 3a 9e ff ff       	call   f0100040 <_panic>
	}

	lk->pcs[0] = 0;
f0106206:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
	lk->cpu = 0;
f010620d:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0106214:	b8 00 00 00 00       	mov    $0x0,%eax
f0106219:	f0 87 03             	lock xchg %eax,(%ebx)
	// Paper says that Intel 64 and IA-32 will not move a load
	// after a store. So lock->locked = 0 would work here.
	// The xchg being asm volatile ensures gcc emits it after
	// the above assignments (and after the critical section).
	xchg(&lk->locked, 0);
}
f010621c:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010621f:	5b                   	pop    %ebx
f0106220:	5e                   	pop    %esi
f0106221:	5f                   	pop    %edi
f0106222:	5d                   	pop    %ebp
f0106223:	c3                   	ret    

f0106224 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
f0106224:	55                   	push   %ebp
f0106225:	57                   	push   %edi
f0106226:	56                   	push   %esi
f0106227:	53                   	push   %ebx
f0106228:	83 ec 1c             	sub    $0x1c,%esp
f010622b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
f010622f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
f0106233:	8b 7c 24 38          	mov    0x38(%esp),%edi
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
f0106237:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f010623b:	89 ca                	mov    %ecx,%edx
  const DWunion dd = {.ll = d};
f010623d:	89 f8                	mov    %edi,%eax
f010623f:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
f0106243:	85 f6                	test   %esi,%esi
f0106245:	75 2d                	jne    f0106274 <__udivdi3+0x50>
    {
      if (d0 > n1)
f0106247:	39 cf                	cmp    %ecx,%edi
f0106249:	77 65                	ja     f01062b0 <__udivdi3+0x8c>
f010624b:	89 fd                	mov    %edi,%ebp
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
f010624d:	85 ff                	test   %edi,%edi
f010624f:	75 0b                	jne    f010625c <__udivdi3+0x38>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
f0106251:	b8 01 00 00 00       	mov    $0x1,%eax
f0106256:	31 d2                	xor    %edx,%edx
f0106258:	f7 f7                	div    %edi
f010625a:	89 c5                	mov    %eax,%ebp

	  udiv_qrnnd (q1, n1, 0, n1, d0);
f010625c:	31 d2                	xor    %edx,%edx
f010625e:	89 c8                	mov    %ecx,%eax
f0106260:	f7 f5                	div    %ebp
f0106262:	89 c1                	mov    %eax,%ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
f0106264:	89 d8                	mov    %ebx,%eax
f0106266:	f7 f5                	div    %ebp
f0106268:	89 cf                	mov    %ecx,%edi
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f010626a:	89 fa                	mov    %edi,%edx
f010626c:	83 c4 1c             	add    $0x1c,%esp
f010626f:	5b                   	pop    %ebx
f0106270:	5e                   	pop    %esi
f0106271:	5f                   	pop    %edi
f0106272:	5d                   	pop    %ebp
f0106273:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
f0106274:	39 ce                	cmp    %ecx,%esi
f0106276:	77 28                	ja     f01062a0 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
f0106278:	0f bd fe             	bsr    %esi,%edi
	  if (bm == 0)
f010627b:	83 f7 1f             	xor    $0x1f,%edi
f010627e:	75 40                	jne    f01062c0 <__udivdi3+0x9c>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
f0106280:	39 ce                	cmp    %ecx,%esi
f0106282:	72 0a                	jb     f010628e <__udivdi3+0x6a>
f0106284:	3b 44 24 08          	cmp    0x8(%esp),%eax
f0106288:	0f 87 9e 00 00 00    	ja     f010632c <__udivdi3+0x108>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
f010628e:	b8 01 00 00 00       	mov    $0x1,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f0106293:	89 fa                	mov    %edi,%edx
f0106295:	83 c4 1c             	add    $0x1c,%esp
f0106298:	5b                   	pop    %ebx
f0106299:	5e                   	pop    %esi
f010629a:	5f                   	pop    %edi
f010629b:	5d                   	pop    %ebp
f010629c:	c3                   	ret    
f010629d:	8d 76 00             	lea    0x0(%esi),%esi
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
f01062a0:	31 ff                	xor    %edi,%edi
f01062a2:	31 c0                	xor    %eax,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f01062a4:	89 fa                	mov    %edi,%edx
f01062a6:	83 c4 1c             	add    $0x1c,%esp
f01062a9:	5b                   	pop    %ebx
f01062aa:	5e                   	pop    %esi
f01062ab:	5f                   	pop    %edi
f01062ac:	5d                   	pop    %ebp
f01062ad:	c3                   	ret    
f01062ae:	66 90                	xchg   %ax,%ax
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
f01062b0:	89 d8                	mov    %ebx,%eax
f01062b2:	f7 f7                	div    %edi
f01062b4:	31 ff                	xor    %edi,%edi
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f01062b6:	89 fa                	mov    %edi,%edx
f01062b8:	83 c4 1c             	add    $0x1c,%esp
f01062bb:	5b                   	pop    %ebx
f01062bc:	5e                   	pop    %esi
f01062bd:	5f                   	pop    %edi
f01062be:	5d                   	pop    %ebp
f01062bf:	c3                   	ret    
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
f01062c0:	bd 20 00 00 00       	mov    $0x20,%ebp
f01062c5:	89 eb                	mov    %ebp,%ebx
f01062c7:	29 fb                	sub    %edi,%ebx

	      d1 = (d1 << bm) | (d0 >> b);
f01062c9:	89 f9                	mov    %edi,%ecx
f01062cb:	d3 e6                	shl    %cl,%esi
f01062cd:	89 c5                	mov    %eax,%ebp
f01062cf:	88 d9                	mov    %bl,%cl
f01062d1:	d3 ed                	shr    %cl,%ebp
f01062d3:	89 e9                	mov    %ebp,%ecx
f01062d5:	09 f1                	or     %esi,%ecx
f01062d7:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
	      d0 = d0 << bm;
f01062db:	89 f9                	mov    %edi,%ecx
f01062dd:	d3 e0                	shl    %cl,%eax
f01062df:	89 c5                	mov    %eax,%ebp
	      n2 = n1 >> b;
f01062e1:	89 d6                	mov    %edx,%esi
f01062e3:	88 d9                	mov    %bl,%cl
f01062e5:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
f01062e7:	89 f9                	mov    %edi,%ecx
f01062e9:	d3 e2                	shl    %cl,%edx
f01062eb:	8b 44 24 08          	mov    0x8(%esp),%eax
f01062ef:	88 d9                	mov    %bl,%cl
f01062f1:	d3 e8                	shr    %cl,%eax
f01062f3:	09 c2                	or     %eax,%edx
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
f01062f5:	89 d0                	mov    %edx,%eax
f01062f7:	89 f2                	mov    %esi,%edx
f01062f9:	f7 74 24 0c          	divl   0xc(%esp)
f01062fd:	89 d6                	mov    %edx,%esi
f01062ff:	89 c3                	mov    %eax,%ebx
	      umul_ppmm (m1, m0, q0, d0);
f0106301:	f7 e5                	mul    %ebp

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f0106303:	39 d6                	cmp    %edx,%esi
f0106305:	72 19                	jb     f0106320 <__udivdi3+0xfc>
f0106307:	74 0b                	je     f0106314 <__udivdi3+0xf0>
f0106309:	89 d8                	mov    %ebx,%eax
f010630b:	31 ff                	xor    %edi,%edi
f010630d:	e9 58 ff ff ff       	jmp    f010626a <__udivdi3+0x46>
f0106312:	66 90                	xchg   %ax,%ax
f0106314:	8b 54 24 08          	mov    0x8(%esp),%edx
f0106318:	89 f9                	mov    %edi,%ecx
f010631a:	d3 e2                	shl    %cl,%edx
f010631c:	39 c2                	cmp    %eax,%edx
f010631e:	73 e9                	jae    f0106309 <__udivdi3+0xe5>
f0106320:	8d 43 ff             	lea    -0x1(%ebx),%eax
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
f0106323:	31 ff                	xor    %edi,%edi
f0106325:	e9 40 ff ff ff       	jmp    f010626a <__udivdi3+0x46>
f010632a:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
f010632c:	31 c0                	xor    %eax,%eax
f010632e:	e9 37 ff ff ff       	jmp    f010626a <__udivdi3+0x46>
f0106333:	90                   	nop

f0106334 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
f0106334:	55                   	push   %ebp
f0106335:	57                   	push   %edi
f0106336:	56                   	push   %esi
f0106337:	53                   	push   %ebx
f0106338:	83 ec 1c             	sub    $0x1c,%esp
f010633b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
f010633f:	8b 74 24 34          	mov    0x34(%esp),%esi
f0106343:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0106347:	8b 44 24 3c          	mov    0x3c(%esp),%eax
f010634b:	89 44 24 0c          	mov    %eax,0xc(%esp)
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
f010634f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0106353:	89 f3                	mov    %esi,%ebx
  const DWunion dd = {.ll = d};
f0106355:	89 fa                	mov    %edi,%edx
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
f0106357:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  n1 = nn.s.high;
f010635b:	89 34 24             	mov    %esi,(%esp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
f010635e:	85 c0                	test   %eax,%eax
f0106360:	75 1a                	jne    f010637c <__umoddi3+0x48>
    {
      if (d0 > n1)
f0106362:	39 f7                	cmp    %esi,%edi
f0106364:	0f 86 a2 00 00 00    	jbe    f010640c <__umoddi3+0xd8>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
f010636a:	89 c8                	mov    %ecx,%eax
f010636c:	89 f2                	mov    %esi,%edx
f010636e:	f7 f7                	div    %edi
f0106370:	89 d0                	mov    %edx,%eax

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
f0106372:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f0106374:	83 c4 1c             	add    $0x1c,%esp
f0106377:	5b                   	pop    %ebx
f0106378:	5e                   	pop    %esi
f0106379:	5f                   	pop    %edi
f010637a:	5d                   	pop    %ebp
f010637b:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
f010637c:	39 f0                	cmp    %esi,%eax
f010637e:	0f 87 ac 00 00 00    	ja     f0106430 <__umoddi3+0xfc>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
f0106384:	0f bd e8             	bsr    %eax,%ebp
	  if (bm == 0)
f0106387:	83 f5 1f             	xor    $0x1f,%ebp
f010638a:	0f 84 ac 00 00 00    	je     f010643c <__umoddi3+0x108>
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
f0106390:	bf 20 00 00 00       	mov    $0x20,%edi
f0106395:	29 ef                	sub    %ebp,%edi
f0106397:	89 fe                	mov    %edi,%esi
f0106399:	89 7c 24 0c          	mov    %edi,0xc(%esp)

	      d1 = (d1 << bm) | (d0 >> b);
f010639d:	89 e9                	mov    %ebp,%ecx
f010639f:	d3 e0                	shl    %cl,%eax
f01063a1:	89 d7                	mov    %edx,%edi
f01063a3:	89 f1                	mov    %esi,%ecx
f01063a5:	d3 ef                	shr    %cl,%edi
f01063a7:	09 c7                	or     %eax,%edi
	      d0 = d0 << bm;
f01063a9:	89 e9                	mov    %ebp,%ecx
f01063ab:	d3 e2                	shl    %cl,%edx
f01063ad:	89 14 24             	mov    %edx,(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
f01063b0:	89 d8                	mov    %ebx,%eax
f01063b2:	d3 e0                	shl    %cl,%eax
f01063b4:	89 c2                	mov    %eax,%edx
	      n0 = n0 << bm;
f01063b6:	8b 44 24 08          	mov    0x8(%esp),%eax
f01063ba:	d3 e0                	shl    %cl,%eax
f01063bc:	89 44 24 04          	mov    %eax,0x4(%esp)

	      udiv_qrnnd (q0, n1, n2, n1, d1);
f01063c0:	8b 44 24 08          	mov    0x8(%esp),%eax
f01063c4:	89 f1                	mov    %esi,%ecx
f01063c6:	d3 e8                	shr    %cl,%eax
f01063c8:	09 d0                	or     %edx,%eax
f01063ca:	d3 eb                	shr    %cl,%ebx
f01063cc:	89 da                	mov    %ebx,%edx
f01063ce:	f7 f7                	div    %edi
f01063d0:	89 d3                	mov    %edx,%ebx
	      umul_ppmm (m1, m0, q0, d0);
f01063d2:	f7 24 24             	mull   (%esp)
f01063d5:	89 c6                	mov    %eax,%esi
f01063d7:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f01063d9:	39 d3                	cmp    %edx,%ebx
f01063db:	0f 82 87 00 00 00    	jb     f0106468 <__umoddi3+0x134>
f01063e1:	0f 84 91 00 00 00    	je     f0106478 <__umoddi3+0x144>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
f01063e7:	8b 54 24 04          	mov    0x4(%esp),%edx
f01063eb:	29 f2                	sub    %esi,%edx
f01063ed:	19 cb                	sbb    %ecx,%ebx
		  rr.s.low = (n1 << b) | (n0 >> bm);
f01063ef:	89 d8                	mov    %ebx,%eax
f01063f1:	8a 4c 24 0c          	mov    0xc(%esp),%cl
f01063f5:	d3 e0                	shl    %cl,%eax
f01063f7:	89 e9                	mov    %ebp,%ecx
f01063f9:	d3 ea                	shr    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
f01063fb:	09 d0                	or     %edx,%eax
f01063fd:	89 e9                	mov    %ebp,%ecx
f01063ff:	d3 eb                	shr    %cl,%ebx
f0106401:	89 da                	mov    %ebx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f0106403:	83 c4 1c             	add    $0x1c,%esp
f0106406:	5b                   	pop    %ebx
f0106407:	5e                   	pop    %esi
f0106408:	5f                   	pop    %edi
f0106409:	5d                   	pop    %ebp
f010640a:	c3                   	ret    
f010640b:	90                   	nop
f010640c:	89 fd                	mov    %edi,%ebp
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
f010640e:	85 ff                	test   %edi,%edi
f0106410:	75 0b                	jne    f010641d <__umoddi3+0xe9>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
f0106412:	b8 01 00 00 00       	mov    $0x1,%eax
f0106417:	31 d2                	xor    %edx,%edx
f0106419:	f7 f7                	div    %edi
f010641b:	89 c5                	mov    %eax,%ebp

	  udiv_qrnnd (q1, n1, 0, n1, d0);
f010641d:	89 f0                	mov    %esi,%eax
f010641f:	31 d2                	xor    %edx,%edx
f0106421:	f7 f5                	div    %ebp
	  udiv_qrnnd (q0, n0, n1, n0, d0);
f0106423:	89 c8                	mov    %ecx,%eax
f0106425:	f7 f5                	div    %ebp
f0106427:	89 d0                	mov    %edx,%eax
f0106429:	e9 44 ff ff ff       	jmp    f0106372 <__umoddi3+0x3e>
f010642e:	66 90                	xchg   %ax,%ax
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
f0106430:	89 c8                	mov    %ecx,%eax
f0106432:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f0106434:	83 c4 1c             	add    $0x1c,%esp
f0106437:	5b                   	pop    %ebx
f0106438:	5e                   	pop    %esi
f0106439:	5f                   	pop    %edi
f010643a:	5d                   	pop    %ebp
f010643b:	c3                   	ret    

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
f010643c:	3b 04 24             	cmp    (%esp),%eax
f010643f:	72 06                	jb     f0106447 <__umoddi3+0x113>
f0106441:	3b 7c 24 04          	cmp    0x4(%esp),%edi
f0106445:	77 0f                	ja     f0106456 <__umoddi3+0x122>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
f0106447:	89 f2                	mov    %esi,%edx
f0106449:	29 f9                	sub    %edi,%ecx
f010644b:	1b 54 24 0c          	sbb    0xc(%esp),%edx
f010644f:	89 14 24             	mov    %edx,(%esp)
f0106452:	89 4c 24 04          	mov    %ecx,0x4(%esp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
f0106456:	8b 44 24 04          	mov    0x4(%esp),%eax
f010645a:	8b 14 24             	mov    (%esp),%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f010645d:	83 c4 1c             	add    $0x1c,%esp
f0106460:	5b                   	pop    %ebx
f0106461:	5e                   	pop    %esi
f0106462:	5f                   	pop    %edi
f0106463:	5d                   	pop    %ebp
f0106464:	c3                   	ret    
f0106465:	8d 76 00             	lea    0x0(%esi),%esi
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
f0106468:	2b 04 24             	sub    (%esp),%eax
f010646b:	19 fa                	sbb    %edi,%edx
f010646d:	89 d1                	mov    %edx,%ecx
f010646f:	89 c6                	mov    %eax,%esi
f0106471:	e9 71 ff ff ff       	jmp    f01063e7 <__umoddi3+0xb3>
f0106476:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f0106478:	39 44 24 04          	cmp    %eax,0x4(%esp)
f010647c:	72 ea                	jb     f0106468 <__umoddi3+0x134>
f010647e:	89 d9                	mov    %ebx,%ecx
f0106480:	e9 62 ff ff ff       	jmp    f01063e7 <__umoddi3+0xb3>
