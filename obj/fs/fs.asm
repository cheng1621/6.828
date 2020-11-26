
obj/fs/fs:     file format elf32-i386


Disassembly of section .text:

00800020 <_start>:
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	cmpl $USTACKTOP, %esp
  800020:	81 fc 00 e0 bf ee    	cmp    $0xeebfe000,%esp
	jne args_exist
  800026:	75 04                	jne    80002c <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
  800028:	6a 00                	push   $0x0
	pushl $0
  80002a:	6a 00                	push   $0x0

0080002c <args_exist>:

args_exist:
	call libmain
  80002c:	e8 b7 0a 00 00       	call   800ae8 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <ide_wait_ready>:

static int diskno = 1;

static int
ide_wait_ready(bool check_error)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	89 c1                	mov    %eax,%ecx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  800039:	ba f7 01 00 00       	mov    $0x1f7,%edx
  80003e:	ec                   	in     (%dx),%al
  80003f:	88 c3                	mov    %al,%bl
	int r;

	while (((r = inb(0x1F7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
  800041:	83 e0 c0             	and    $0xffffffc0,%eax
  800044:	3c 40                	cmp    $0x40,%al
  800046:	75 f6                	jne    80003e <ide_wait_ready+0xb>
		/* do nothing */;

	if (check_error && (r & (IDE_DF|IDE_ERR)) != 0)
  800048:	84 c9                	test   %cl,%cl
  80004a:	74 0d                	je     800059 <ide_wait_ready+0x26>
  80004c:	f6 c3 21             	test   $0x21,%bl
  80004f:	0f 95 c0             	setne  %al
  800052:	0f b6 c0             	movzbl %al,%eax
  800055:	f7 d8                	neg    %eax
  800057:	eb 05                	jmp    80005e <ide_wait_ready+0x2b>
		return -1;
	return 0;
  800059:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80005e:	5b                   	pop    %ebx
  80005f:	5d                   	pop    %ebp
  800060:	c3                   	ret    

00800061 <ide_probe_disk1>:

bool
ide_probe_disk1(void)
{
  800061:	55                   	push   %ebp
  800062:	89 e5                	mov    %esp,%ebp
  800064:	53                   	push   %ebx
  800065:	83 ec 04             	sub    $0x4,%esp
	int r, x;

	// wait for Device 0 to be ready
	ide_wait_ready(0);
  800068:	b8 00 00 00 00       	mov    $0x0,%eax
  80006d:	e8 c1 ff ff ff       	call   800033 <ide_wait_ready>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  800072:	ba f6 01 00 00       	mov    $0x1f6,%edx
  800077:	b0 f0                	mov    $0xf0,%al
  800079:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  80007a:	ba f7 01 00 00       	mov    $0x1f7,%edx
  80007f:	ec                   	in     (%dx),%al
	// switch to Device 1
	outb(0x1F6, 0xE0 | (1<<4));

	// check for Device 1 to be ready for a while
	for (x = 0;
	     x < 1000 && ((r = inb(0x1F7)) & (IDE_BSY|IDE_DF|IDE_ERR)) != 0;
  800080:	b9 01 00 00 00       	mov    $0x1,%ecx
  800085:	a8 a1                	test   $0xa1,%al
  800087:	75 10                	jne    800099 <ide_probe_disk1+0x38>

	// switch to Device 1
	outb(0x1F6, 0xE0 | (1<<4));

	// check for Device 1 to be ready for a while
	for (x = 0;
  800089:	b9 00 00 00 00       	mov    $0x0,%ecx
  80008e:	eb 0e                	jmp    80009e <ide_probe_disk1+0x3d>
	     x < 1000 && ((r = inb(0x1F7)) & (IDE_BSY|IDE_DF|IDE_ERR)) != 0;
	     x++)
  800090:	41                   	inc    %ecx

	// switch to Device 1
	outb(0x1F6, 0xE0 | (1<<4));

	// check for Device 1 to be ready for a while
	for (x = 0;
  800091:	81 f9 e8 03 00 00    	cmp    $0x3e8,%ecx
  800097:	74 05                	je     80009e <ide_probe_disk1+0x3d>
  800099:	ec                   	in     (%dx),%al
	     x < 1000 && ((r = inb(0x1F7)) & (IDE_BSY|IDE_DF|IDE_ERR)) != 0;
  80009a:	a8 a1                	test   $0xa1,%al
  80009c:	75 f2                	jne    800090 <ide_probe_disk1+0x2f>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  80009e:	ba f6 01 00 00       	mov    $0x1f6,%edx
  8000a3:	b0 e0                	mov    $0xe0,%al
  8000a5:	ee                   	out    %al,(%dx)
		/* do nothing */;

	// switch back to Device 0
	outb(0x1F6, 0xE0 | (0<<4));

	cprintf("Device 1 presence: %d\n", (x < 1000));
  8000a6:	81 f9 e7 03 00 00    	cmp    $0x3e7,%ecx
  8000ac:	0f 9e c3             	setle  %bl
  8000af:	83 ec 08             	sub    $0x8,%esp
  8000b2:	0f b6 c3             	movzbl %bl,%eax
  8000b5:	50                   	push   %eax
  8000b6:	68 80 29 80 00       	push   $0x802980
  8000bb:	e8 69 0b 00 00       	call   800c29 <cprintf>
	return (x < 1000);
}
  8000c0:	88 d8                	mov    %bl,%al
  8000c2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000c5:	c9                   	leave  
  8000c6:	c3                   	ret    

008000c7 <ide_set_disk>:

void
ide_set_disk(int d)
{
  8000c7:	55                   	push   %ebp
  8000c8:	89 e5                	mov    %esp,%ebp
  8000ca:	83 ec 08             	sub    $0x8,%esp
  8000cd:	8b 45 08             	mov    0x8(%ebp),%eax
	if (d != 0 && d != 1)
  8000d0:	83 f8 01             	cmp    $0x1,%eax
  8000d3:	76 14                	jbe    8000e9 <ide_set_disk+0x22>
		panic("bad disk number");
  8000d5:	83 ec 04             	sub    $0x4,%esp
  8000d8:	68 97 29 80 00       	push   $0x802997
  8000dd:	6a 3a                	push   $0x3a
  8000df:	68 a7 29 80 00       	push   $0x8029a7
  8000e4:	e8 68 0a 00 00       	call   800b51 <_panic>
	diskno = d;
  8000e9:	a3 00 30 80 00       	mov    %eax,0x803000
}
  8000ee:	c9                   	leave  
  8000ef:	c3                   	ret    

008000f0 <ide_read>:

int
ide_read(uint32_t secno, void *dst, size_t nsecs)
{
  8000f0:	55                   	push   %ebp
  8000f1:	89 e5                	mov    %esp,%ebp
  8000f3:	57                   	push   %edi
  8000f4:	56                   	push   %esi
  8000f5:	53                   	push   %ebx
  8000f6:	83 ec 0c             	sub    $0xc,%esp
  8000f9:	8b 7d 08             	mov    0x8(%ebp),%edi
  8000fc:	8b 75 0c             	mov    0xc(%ebp),%esi
  8000ff:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int r;

	assert(nsecs <= 256);
  800102:	81 fb 00 01 00 00    	cmp    $0x100,%ebx
  800108:	76 16                	jbe    800120 <ide_read+0x30>
  80010a:	68 b0 29 80 00       	push   $0x8029b0
  80010f:	68 bd 29 80 00       	push   $0x8029bd
  800114:	6a 43                	push   $0x43
  800116:	68 a7 29 80 00       	push   $0x8029a7
  80011b:	e8 31 0a 00 00       	call   800b51 <_panic>

	ide_wait_ready(0);
  800120:	b8 00 00 00 00       	mov    $0x0,%eax
  800125:	e8 09 ff ff ff       	call   800033 <ide_wait_ready>
  80012a:	ba f2 01 00 00       	mov    $0x1f2,%edx
  80012f:	88 d8                	mov    %bl,%al
  800131:	ee                   	out    %al,(%dx)
  800132:	ba f3 01 00 00       	mov    $0x1f3,%edx
  800137:	89 f8                	mov    %edi,%eax
  800139:	ee                   	out    %al,(%dx)
  80013a:	89 f8                	mov    %edi,%eax
  80013c:	c1 e8 08             	shr    $0x8,%eax
  80013f:	ba f4 01 00 00       	mov    $0x1f4,%edx
  800144:	ee                   	out    %al,(%dx)
  800145:	89 f8                	mov    %edi,%eax
  800147:	c1 e8 10             	shr    $0x10,%eax
  80014a:	ba f5 01 00 00       	mov    $0x1f5,%edx
  80014f:	ee                   	out    %al,(%dx)
  800150:	a0 00 30 80 00       	mov    0x803000,%al
  800155:	83 e0 01             	and    $0x1,%eax
  800158:	c1 e0 04             	shl    $0x4,%eax
  80015b:	83 c8 e0             	or     $0xffffffe0,%eax
  80015e:	c1 ef 18             	shr    $0x18,%edi
  800161:	83 e7 0f             	and    $0xf,%edi
  800164:	09 f8                	or     %edi,%eax
  800166:	ba f6 01 00 00       	mov    $0x1f6,%edx
  80016b:	ee                   	out    %al,(%dx)
  80016c:	ba f7 01 00 00       	mov    $0x1f7,%edx
  800171:	b0 20                	mov    $0x20,%al
  800173:	ee                   	out    %al,(%dx)
	outb(0x1F4, (secno >> 8) & 0xFF);
	outb(0x1F5, (secno >> 16) & 0xFF);
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
	outb(0x1F7, 0x20);	// CMD 0x20 means read sector

	for (; nsecs > 0; nsecs--, dst += SECTSIZE) {
  800174:	85 db                	test   %ebx,%ebx
  800176:	74 2d                	je     8001a5 <ide_read+0xb5>
		if ((r = ide_wait_ready(1)) < 0)
  800178:	b8 01 00 00 00       	mov    $0x1,%eax
  80017d:	e8 b1 fe ff ff       	call   800033 <ide_wait_ready>
  800182:	85 c0                	test   %eax,%eax
  800184:	78 24                	js     8001aa <ide_read+0xba>
}

static __inline void
insl(int port, void *addr, int cnt)
{
	__asm __volatile("cld\n\trepne\n\tinsl"			:
  800186:	89 f7                	mov    %esi,%edi
  800188:	b9 80 00 00 00       	mov    $0x80,%ecx
  80018d:	ba f0 01 00 00       	mov    $0x1f0,%edx
  800192:	fc                   	cld    
  800193:	f2 6d                	repnz insl (%dx),%es:(%edi)
	outb(0x1F4, (secno >> 8) & 0xFF);
	outb(0x1F5, (secno >> 16) & 0xFF);
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
	outb(0x1F7, 0x20);	// CMD 0x20 means read sector

	for (; nsecs > 0; nsecs--, dst += SECTSIZE) {
  800195:	81 c6 00 02 00 00    	add    $0x200,%esi
  80019b:	4b                   	dec    %ebx
  80019c:	75 da                	jne    800178 <ide_read+0x88>
		if ((r = ide_wait_ready(1)) < 0)
			return r;
		insl(0x1F0, dst, SECTSIZE/4);
	}

	return 0;
  80019e:	b8 00 00 00 00       	mov    $0x0,%eax
  8001a3:	eb 05                	jmp    8001aa <ide_read+0xba>
  8001a5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8001aa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001ad:	5b                   	pop    %ebx
  8001ae:	5e                   	pop    %esi
  8001af:	5f                   	pop    %edi
  8001b0:	5d                   	pop    %ebp
  8001b1:	c3                   	ret    

008001b2 <ide_write>:

int
ide_write(uint32_t secno, const void *src, size_t nsecs)
{
  8001b2:	55                   	push   %ebp
  8001b3:	89 e5                	mov    %esp,%ebp
  8001b5:	57                   	push   %edi
  8001b6:	56                   	push   %esi
  8001b7:	53                   	push   %ebx
  8001b8:	83 ec 0c             	sub    $0xc,%esp
  8001bb:	8b 75 08             	mov    0x8(%ebp),%esi
  8001be:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8001c1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int r;

	assert(nsecs <= 256);
  8001c4:	81 fb 00 01 00 00    	cmp    $0x100,%ebx
  8001ca:	76 16                	jbe    8001e2 <ide_write+0x30>
  8001cc:	68 b0 29 80 00       	push   $0x8029b0
  8001d1:	68 bd 29 80 00       	push   $0x8029bd
  8001d6:	6a 5c                	push   $0x5c
  8001d8:	68 a7 29 80 00       	push   $0x8029a7
  8001dd:	e8 6f 09 00 00       	call   800b51 <_panic>

	ide_wait_ready(0);
  8001e2:	b8 00 00 00 00       	mov    $0x0,%eax
  8001e7:	e8 47 fe ff ff       	call   800033 <ide_wait_ready>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  8001ec:	ba f2 01 00 00       	mov    $0x1f2,%edx
  8001f1:	88 d8                	mov    %bl,%al
  8001f3:	ee                   	out    %al,(%dx)
  8001f4:	ba f3 01 00 00       	mov    $0x1f3,%edx
  8001f9:	89 f0                	mov    %esi,%eax
  8001fb:	ee                   	out    %al,(%dx)
  8001fc:	89 f0                	mov    %esi,%eax
  8001fe:	c1 e8 08             	shr    $0x8,%eax
  800201:	ba f4 01 00 00       	mov    $0x1f4,%edx
  800206:	ee                   	out    %al,(%dx)
  800207:	89 f0                	mov    %esi,%eax
  800209:	c1 e8 10             	shr    $0x10,%eax
  80020c:	ba f5 01 00 00       	mov    $0x1f5,%edx
  800211:	ee                   	out    %al,(%dx)
  800212:	a0 00 30 80 00       	mov    0x803000,%al
  800217:	83 e0 01             	and    $0x1,%eax
  80021a:	c1 e0 04             	shl    $0x4,%eax
  80021d:	83 c8 e0             	or     $0xffffffe0,%eax
  800220:	c1 ee 18             	shr    $0x18,%esi
  800223:	83 e6 0f             	and    $0xf,%esi
  800226:	09 f0                	or     %esi,%eax
  800228:	ba f6 01 00 00       	mov    $0x1f6,%edx
  80022d:	ee                   	out    %al,(%dx)
  80022e:	ba f7 01 00 00       	mov    $0x1f7,%edx
  800233:	b0 30                	mov    $0x30,%al
  800235:	ee                   	out    %al,(%dx)
	outb(0x1F4, (secno >> 8) & 0xFF);
	outb(0x1F5, (secno >> 16) & 0xFF);
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
	outb(0x1F7, 0x30);	// CMD 0x30 means write sector

	for (; nsecs > 0; nsecs--, src += SECTSIZE) {
  800236:	85 db                	test   %ebx,%ebx
  800238:	74 2d                	je     800267 <ide_write+0xb5>
		if ((r = ide_wait_ready(1)) < 0)
  80023a:	b8 01 00 00 00       	mov    $0x1,%eax
  80023f:	e8 ef fd ff ff       	call   800033 <ide_wait_ready>
  800244:	85 c0                	test   %eax,%eax
  800246:	78 24                	js     80026c <ide_write+0xba>
}

static __inline void
outsl(int port, const void *addr, int cnt)
{
	__asm __volatile("cld\n\trepne\n\toutsl"		:
  800248:	89 fe                	mov    %edi,%esi
  80024a:	b9 80 00 00 00       	mov    $0x80,%ecx
  80024f:	ba f0 01 00 00       	mov    $0x1f0,%edx
  800254:	fc                   	cld    
  800255:	f2 6f                	repnz outsl %ds:(%esi),(%dx)
	outb(0x1F4, (secno >> 8) & 0xFF);
	outb(0x1F5, (secno >> 16) & 0xFF);
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
	outb(0x1F7, 0x30);	// CMD 0x30 means write sector

	for (; nsecs > 0; nsecs--, src += SECTSIZE) {
  800257:	81 c7 00 02 00 00    	add    $0x200,%edi
  80025d:	4b                   	dec    %ebx
  80025e:	75 da                	jne    80023a <ide_write+0x88>
		if ((r = ide_wait_ready(1)) < 0)
			return r;
		outsl(0x1F0, src, SECTSIZE/4);
	}

	return 0;
  800260:	b8 00 00 00 00       	mov    $0x0,%eax
  800265:	eb 05                	jmp    80026c <ide_write+0xba>
  800267:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80026c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80026f:	5b                   	pop    %ebx
  800270:	5e                   	pop    %esi
  800271:	5f                   	pop    %edi
  800272:	5d                   	pop    %ebp
  800273:	c3                   	ret    

00800274 <bc_pgfault>:

// Fault any disk block that is read in to memory by
// loading it from disk.
static void
bc_pgfault(struct UTrapframe *utf)
{
  800274:	55                   	push   %ebp
  800275:	89 e5                	mov    %esp,%ebp
  800277:	56                   	push   %esi
  800278:	53                   	push   %ebx
  800279:	8b 4d 08             	mov    0x8(%ebp),%ecx
	void *addr = (void *) utf->utf_fault_va;
  80027c:	8b 01                	mov    (%ecx),%eax
	uint32_t blockno = ((uint32_t)addr - DISKMAP) / BLKSIZE;
  80027e:	8d 90 00 00 00 f0    	lea    -0x10000000(%eax),%edx
  800284:	89 d6                	mov    %edx,%esi
  800286:	c1 ee 0c             	shr    $0xc,%esi
	int r;

	// Check that the fault was within the block cache region
	if (addr < (void*)DISKMAP || addr >= (void*)(DISKMAP + DISKSIZE))
  800289:	81 fa ff ff ff bf    	cmp    $0xbfffffff,%edx
  80028f:	76 1b                	jbe    8002ac <bc_pgfault+0x38>
		panic("page fault in FS: eip %08x, va %08x, err %04x",
  800291:	83 ec 08             	sub    $0x8,%esp
  800294:	ff 71 04             	pushl  0x4(%ecx)
  800297:	50                   	push   %eax
  800298:	ff 71 28             	pushl  0x28(%ecx)
  80029b:	68 d4 29 80 00       	push   $0x8029d4
  8002a0:	6a 19                	push   $0x19
  8002a2:	68 6e 2a 80 00       	push   $0x802a6e
  8002a7:	e8 a5 08 00 00       	call   800b51 <_panic>
		      utf->utf_eip, addr, utf->utf_err);

	// Sanity check the block number.
	if (super && blockno >= super->s_nblocks)
  8002ac:	8b 15 08 80 80 00    	mov    0x808008,%edx
  8002b2:	85 d2                	test   %edx,%edx
  8002b4:	74 17                	je     8002cd <bc_pgfault+0x59>
  8002b6:	3b 72 04             	cmp    0x4(%edx),%esi
  8002b9:	72 12                	jb     8002cd <bc_pgfault+0x59>
		panic("reading non-existent block %08x\n", blockno);
  8002bb:	56                   	push   %esi
  8002bc:	68 04 2a 80 00       	push   $0x802a04
  8002c1:	6a 1d                	push   $0x1d
  8002c3:	68 6e 2a 80 00       	push   $0x802a6e
  8002c8:	e8 84 08 00 00       	call   800b51 <_panic>
	// Allocate a page in the disk map region, read the contents
	// of the block from the disk into that page.
	// Hint: first round addr to page boundary.
	//
	// LAB 5: you code here:
	addr = (void*) ROUNDDOWN(addr,BLKSIZE);
  8002cd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8002d2:	89 c3                	mov    %eax,%ebx
	if((r = sys_page_alloc(0, addr, PTE_U | PTE_W | PTE_P)) < 0)
  8002d4:	83 ec 04             	sub    $0x4,%esp
  8002d7:	6a 07                	push   $0x7
  8002d9:	50                   	push   %eax
  8002da:	6a 00                	push   $0x0
  8002dc:	e8 9d 13 00 00       	call   80167e <sys_page_alloc>
  8002e1:	83 c4 10             	add    $0x10,%esp
  8002e4:	85 c0                	test   %eax,%eax
  8002e6:	79 12                	jns    8002fa <bc_pgfault+0x86>
		panic("in bc_pgfault, sys_page_alloc: %e", r);
  8002e8:	50                   	push   %eax
  8002e9:	68 28 2a 80 00       	push   $0x802a28
  8002ee:	6a 26                	push   $0x26
  8002f0:	68 6e 2a 80 00       	push   $0x802a6e
  8002f5:	e8 57 08 00 00       	call   800b51 <_panic>
	if((r = ide_read(blockno << 3, addr, 8)) < 0)
  8002fa:	83 ec 04             	sub    $0x4,%esp
  8002fd:	6a 08                	push   $0x8
  8002ff:	53                   	push   %ebx
  800300:	c1 e6 03             	shl    $0x3,%esi
  800303:	56                   	push   %esi
  800304:	e8 e7 fd ff ff       	call   8000f0 <ide_read>
  800309:	83 c4 10             	add    $0x10,%esp
  80030c:	85 c0                	test   %eax,%eax
  80030e:	79 12                	jns    800322 <bc_pgfault+0xae>
		panic("in bc_pgfault, ide_read: %e", r);
  800310:	50                   	push   %eax
  800311:	68 76 2a 80 00       	push   $0x802a76
  800316:	6a 28                	push   $0x28
  800318:	68 6e 2a 80 00       	push   $0x802a6e
  80031d:	e8 2f 08 00 00       	call   800b51 <_panic>
}
  800322:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800325:	5b                   	pop    %ebx
  800326:	5e                   	pop    %esi
  800327:	5d                   	pop    %ebp
  800328:	c3                   	ret    

00800329 <diskaddr>:
#include "fs.h"

// Return the virtual address of this disk block.
void*
diskaddr(uint32_t blockno)
{
  800329:	55                   	push   %ebp
  80032a:	89 e5                	mov    %esp,%ebp
  80032c:	83 ec 08             	sub    $0x8,%esp
  80032f:	8b 45 08             	mov    0x8(%ebp),%eax
	if (blockno == 0 || (super && blockno >= super->s_nblocks))
  800332:	85 c0                	test   %eax,%eax
  800334:	74 0f                	je     800345 <diskaddr+0x1c>
  800336:	8b 15 08 80 80 00    	mov    0x808008,%edx
  80033c:	85 d2                	test   %edx,%edx
  80033e:	74 17                	je     800357 <diskaddr+0x2e>
  800340:	3b 42 04             	cmp    0x4(%edx),%eax
  800343:	72 12                	jb     800357 <diskaddr+0x2e>
		panic("bad block number %08x in diskaddr", blockno);
  800345:	50                   	push   %eax
  800346:	68 4c 2a 80 00       	push   $0x802a4c
  80034b:	6a 09                	push   $0x9
  80034d:	68 6e 2a 80 00       	push   $0x802a6e
  800352:	e8 fa 07 00 00       	call   800b51 <_panic>
	return (char*) (DISKMAP + blockno * BLKSIZE);
  800357:	05 00 00 01 00       	add    $0x10000,%eax
  80035c:	c1 e0 0c             	shl    $0xc,%eax
}
  80035f:	c9                   	leave  
  800360:	c3                   	ret    

00800361 <bc_init>:
}


void
bc_init(void)
{
  800361:	55                   	push   %ebp
  800362:	89 e5                	mov    %esp,%ebp
  800364:	81 ec 24 01 00 00    	sub    $0x124,%esp
	struct Super super;
	set_pgfault_handler(bc_pgfault);
  80036a:	68 74 02 80 00       	push   $0x800274
  80036f:	e8 fb 14 00 00       	call   80186f <set_pgfault_handler>

	// cache the super block by reading it once
	memmove(&super, diskaddr(1), sizeof super);
  800374:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80037b:	e8 a9 ff ff ff       	call   800329 <diskaddr>
  800380:	83 c4 0c             	add    $0xc,%esp
  800383:	68 08 01 00 00       	push   $0x108
  800388:	50                   	push   %eax
  800389:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80038f:	50                   	push   %eax
  800390:	e8 46 10 00 00       	call   8013db <memmove>
}
  800395:	83 c4 10             	add    $0x10,%esp
  800398:	c9                   	leave  
  800399:	c3                   	ret    

0080039a <check_super>:
// --------------------------------------------------------------

// Validate the file system super-block.
void
check_super(void)
{
  80039a:	55                   	push   %ebp
  80039b:	89 e5                	mov    %esp,%ebp
  80039d:	83 ec 08             	sub    $0x8,%esp
	if (super->s_magic != FS_MAGIC)
  8003a0:	a1 08 80 80 00       	mov    0x808008,%eax
  8003a5:	81 38 ae 30 05 4a    	cmpl   $0x4a0530ae,(%eax)
  8003ab:	74 14                	je     8003c1 <check_super+0x27>
		panic("bad file system magic number");
  8003ad:	83 ec 04             	sub    $0x4,%esp
  8003b0:	68 92 2a 80 00       	push   $0x802a92
  8003b5:	6a 0e                	push   $0xe
  8003b7:	68 af 2a 80 00       	push   $0x802aaf
  8003bc:	e8 90 07 00 00       	call   800b51 <_panic>

	if (super->s_nblocks > DISKSIZE/BLKSIZE)
  8003c1:	81 78 04 00 00 0c 00 	cmpl   $0xc0000,0x4(%eax)
  8003c8:	76 14                	jbe    8003de <check_super+0x44>
		panic("file system is too large");
  8003ca:	83 ec 04             	sub    $0x4,%esp
  8003cd:	68 b7 2a 80 00       	push   $0x802ab7
  8003d2:	6a 11                	push   $0x11
  8003d4:	68 af 2a 80 00       	push   $0x802aaf
  8003d9:	e8 73 07 00 00       	call   800b51 <_panic>

	cprintf("superblock is good\n");
  8003de:	83 ec 0c             	sub    $0xc,%esp
  8003e1:	68 d0 2a 80 00       	push   $0x802ad0
  8003e6:	e8 3e 08 00 00       	call   800c29 <cprintf>
}
  8003eb:	83 c4 10             	add    $0x10,%esp
  8003ee:	c9                   	leave  
  8003ef:	c3                   	ret    

008003f0 <fs_init>:
// --------------------------------------------------------------

// Initialize the file system
void
fs_init(void)
{
  8003f0:	55                   	push   %ebp
  8003f1:	89 e5                	mov    %esp,%ebp
  8003f3:	83 ec 08             	sub    $0x8,%esp
	static_assert(sizeof(struct File) == 256);

	// Find a JOS disk.  Use the second IDE disk (number 1) if available.
	if (ide_probe_disk1())
  8003f6:	e8 66 fc ff ff       	call   800061 <ide_probe_disk1>
  8003fb:	84 c0                	test   %al,%al
  8003fd:	74 0f                	je     80040e <fs_init+0x1e>
		ide_set_disk(1);
  8003ff:	83 ec 0c             	sub    $0xc,%esp
  800402:	6a 01                	push   $0x1
  800404:	e8 be fc ff ff       	call   8000c7 <ide_set_disk>
  800409:	83 c4 10             	add    $0x10,%esp
  80040c:	eb 0d                	jmp    80041b <fs_init+0x2b>
	else
		ide_set_disk(0);
  80040e:	83 ec 0c             	sub    $0xc,%esp
  800411:	6a 00                	push   $0x0
  800413:	e8 af fc ff ff       	call   8000c7 <ide_set_disk>
  800418:	83 c4 10             	add    $0x10,%esp

	bc_init();
  80041b:	e8 41 ff ff ff       	call   800361 <bc_init>

	// Set "super" to point to the super block.
	super = diskaddr(1);
  800420:	83 ec 0c             	sub    $0xc,%esp
  800423:	6a 01                	push   $0x1
  800425:	e8 ff fe ff ff       	call   800329 <diskaddr>
  80042a:	a3 08 80 80 00       	mov    %eax,0x808008
	check_super();
  80042f:	e8 66 ff ff ff       	call   80039a <check_super>
}
  800434:	83 c4 10             	add    $0x10,%esp
  800437:	c9                   	leave  
  800438:	c3                   	ret    

00800439 <file_get_block>:
//	-E_NO_DISK if a block needed to be allocated but the disk is full.
//	-E_INVAL if filebno is out of range.
//
int
file_get_block(struct File *f, uint32_t filebno, char **blk)
{
  800439:	55                   	push   %ebp
  80043a:	89 e5                	mov    %esp,%ebp
  80043c:	53                   	push   %ebx
  80043d:	83 ec 04             	sub    $0x4,%esp
  800440:	8b 5d 0c             	mov    0xc(%ebp),%ebx
{
	int r;
	uint32_t *ptr;
	char *blk;

	if (filebno < NDIRECT)
  800443:	83 fb 09             	cmp    $0x9,%ebx
  800446:	77 0c                	ja     800454 <file_get_block+0x1b>
		ptr = &f->f_direct[filebno];
  800448:	8b 45 08             	mov    0x8(%ebp),%eax
  80044b:	8d 84 98 88 00 00 00 	lea    0x88(%eax,%ebx,4),%eax
  800452:	eb 46                	jmp    80049a <file_get_block+0x61>
	else if (filebno < NDIRECT + NINDIRECT) {
  800454:	81 fb 09 04 00 00    	cmp    $0x409,%ebx
  80045a:	77 46                	ja     8004a2 <file_get_block+0x69>
		if (f->f_indirect == 0) {
  80045c:	8b 45 08             	mov    0x8(%ebp),%eax
  80045f:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
  800465:	85 c0                	test   %eax,%eax
  800467:	74 40                	je     8004a9 <file_get_block+0x70>
			return -E_NOT_FOUND;
		}
		ptr = (uint32_t*)diskaddr(f->f_indirect) + filebno - NDIRECT;
  800469:	83 ec 0c             	sub    $0xc,%esp
  80046c:	50                   	push   %eax
  80046d:	e8 b7 fe ff ff       	call   800329 <diskaddr>
  800472:	8d 44 98 d8          	lea    -0x28(%eax,%ebx,4),%eax
  800476:	83 c4 10             	add    $0x10,%esp
  800479:	eb 1f                	jmp    80049a <file_get_block+0x61>
	if ((r = file_block_walk(f, filebno, &ptr, 1)) < 0)
		return r;
	if (*ptr == 0) {
		return -E_NOT_FOUND;
	}
	*blk = diskaddr(*ptr);
  80047b:	83 ec 0c             	sub    $0xc,%esp
  80047e:	50                   	push   %eax
  80047f:	e8 a5 fe ff ff       	call   800329 <diskaddr>
  800484:	8b 55 10             	mov    0x10(%ebp),%edx
  800487:	89 02                	mov    %eax,(%edx)
	return 0;
  800489:	83 c4 10             	add    $0x10,%esp
  80048c:	b8 00 00 00 00       	mov    $0x0,%eax
  800491:	eb 1b                	jmp    8004ae <file_get_block+0x75>
	uint32_t *ptr;

	if ((r = file_block_walk(f, filebno, &ptr, 1)) < 0)
		return r;
	if (*ptr == 0) {
		return -E_NOT_FOUND;
  800493:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  800498:	eb 14                	jmp    8004ae <file_get_block+0x75>
	int r;
	uint32_t *ptr;

	if ((r = file_block_walk(f, filebno, &ptr, 1)) < 0)
		return r;
	if (*ptr == 0) {
  80049a:	8b 00                	mov    (%eax),%eax
  80049c:	85 c0                	test   %eax,%eax
  80049e:	75 db                	jne    80047b <file_get_block+0x42>
  8004a0:	eb f1                	jmp    800493 <file_get_block+0x5a>
		if (f->f_indirect == 0) {
			return -E_NOT_FOUND;
		}
		ptr = (uint32_t*)diskaddr(f->f_indirect) + filebno - NDIRECT;
	} else
		return -E_INVAL;
  8004a2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8004a7:	eb 05                	jmp    8004ae <file_get_block+0x75>

	if (filebno < NDIRECT)
		ptr = &f->f_direct[filebno];
	else if (filebno < NDIRECT + NINDIRECT) {
		if (f->f_indirect == 0) {
			return -E_NOT_FOUND;
  8004a9:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
	if (*ptr == 0) {
		return -E_NOT_FOUND;
	}
	*blk = diskaddr(*ptr);
	return 0;
}
  8004ae:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8004b1:	c9                   	leave  
  8004b2:	c3                   	ret    

008004b3 <file_open>:

// Open "path".  On success set *pf to point at the file and return 0.
// On error return < 0.
int
file_open(const char *path, struct File **pf)
{
  8004b3:	55                   	push   %ebp
  8004b4:	89 e5                	mov    %esp,%ebp
  8004b6:	57                   	push   %edi
  8004b7:	56                   	push   %esi
  8004b8:	53                   	push   %ebx
  8004b9:	81 ec bc 00 00 00    	sub    $0xbc,%esp
  8004bf:	8b 55 08             	mov    0x8(%ebp),%edx

// Skip over slashes.
static const char*
skip_slash(const char *p)
{
	while (*p == '/')
  8004c2:	80 3a 2f             	cmpb   $0x2f,(%edx)
  8004c5:	75 06                	jne    8004cd <file_open+0x1a>
		p++;
  8004c7:	42                   	inc    %edx

// Skip over slashes.
static const char*
skip_slash(const char *p)
{
	while (*p == '/')
  8004c8:	80 3a 2f             	cmpb   $0x2f,(%edx)
  8004cb:	74 fa                	je     8004c7 <file_open+0x14>
	int r;

	// if (*path != '/')
	//	return -E_BAD_PATH;
	path = skip_slash(path);
	f = &super->s_root;
  8004cd:	a1 08 80 80 00       	mov    0x808008,%eax
  8004d2:	83 c0 08             	add    $0x8,%eax
  8004d5:	89 85 4c ff ff ff    	mov    %eax,-0xb4(%ebp)
	dir = 0;
	name[0] = 0;
  8004db:	c6 85 68 ff ff ff 00 	movb   $0x0,-0x98(%ebp)

	if (pdir)
		*pdir = 0;
	*pf = 0;
  8004e2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004e5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		p = path;
		while (*path != '/' && *path != '\0')
			path++;
		if (path - p >= MAXNAMELEN)
			return -E_BAD_PATH;
		memmove(name, p, path - p);
  8004eb:	8d b5 68 ff ff ff    	lea    -0x98(%ebp),%esi
  8004f1:	e9 1b 01 00 00       	jmp    800611 <file_open+0x15e>
	*pf = 0;
	while (*path != '\0') {
		dir = f;
		p = path;
		while (*path != '/' && *path != '\0')
			path++;
  8004f6:	47                   	inc    %edi
		*pdir = 0;
	*pf = 0;
	while (*path != '\0') {
		dir = f;
		p = path;
		while (*path != '/' && *path != '\0')
  8004f7:	8a 07                	mov    (%edi),%al
  8004f9:	3c 2f                	cmp    $0x2f,%al
  8004fb:	74 04                	je     800501 <file_open+0x4e>
  8004fd:	84 c0                	test   %al,%al
  8004ff:	75 f5                	jne    8004f6 <file_open+0x43>
			path++;
		if (path - p >= MAXNAMELEN)
  800501:	89 fb                	mov    %edi,%ebx
  800503:	29 d3                	sub    %edx,%ebx
  800505:	83 fb 7f             	cmp    $0x7f,%ebx
  800508:	0f 8f 2a 01 00 00    	jg     800638 <file_open+0x185>
			return -E_BAD_PATH;
		memmove(name, p, path - p);
  80050e:	83 ec 04             	sub    $0x4,%esp
  800511:	53                   	push   %ebx
  800512:	52                   	push   %edx
  800513:	56                   	push   %esi
  800514:	e8 c2 0e 00 00       	call   8013db <memmove>
		name[path - p] = '\0';
  800519:	c6 84 1d 68 ff ff ff 	movb   $0x0,-0x98(%ebp,%ebx,1)
  800520:	00 

// Skip over slashes.
static const char*
skip_slash(const char *p)
{
	while (*p == '/')
  800521:	83 c4 10             	add    $0x10,%esp
  800524:	80 3f 2f             	cmpb   $0x2f,(%edi)
  800527:	75 06                	jne    80052f <file_open+0x7c>
		p++;
  800529:	47                   	inc    %edi

// Skip over slashes.
static const char*
skip_slash(const char *p)
{
	while (*p == '/')
  80052a:	80 3f 2f             	cmpb   $0x2f,(%edi)
  80052d:	74 fa                	je     800529 <file_open+0x76>
			return -E_BAD_PATH;
		memmove(name, p, path - p);
		name[path - p] = '\0';
		path = skip_slash(path);

		if (dir->f_type != FTYPE_DIR)
  80052f:	8b 85 4c ff ff ff    	mov    -0xb4(%ebp),%eax
  800535:	83 b8 84 00 00 00 01 	cmpl   $0x1,0x84(%eax)
  80053c:	0f 85 fd 00 00 00    	jne    80063f <file_open+0x18c>
	struct File *f;

	// Search dir for name.
	// We maintain the invariant that the size of a directory-file
	// is always a multiple of the file system's block size.
	assert((dir->f_size % BLKSIZE) == 0);
  800542:	8b 90 80 00 00 00    	mov    0x80(%eax),%edx
  800548:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
  80054e:	74 16                	je     800566 <file_open+0xb3>
  800550:	68 e4 2a 80 00       	push   $0x802ae4
  800555:	68 bd 29 80 00       	push   $0x8029bd
  80055a:	6a 78                	push   $0x78
  80055c:	68 af 2a 80 00       	push   $0x802aaf
  800561:	e8 eb 05 00 00       	call   800b51 <_panic>
	nblock = dir->f_size / BLKSIZE;
  800566:	89 d0                	mov    %edx,%eax
  800568:	85 d2                	test   %edx,%edx
  80056a:	79 06                	jns    800572 <file_open+0xbf>
  80056c:	8d 82 ff 0f 00 00    	lea    0xfff(%edx),%eax
  800572:	c1 f8 0c             	sar    $0xc,%eax
  800575:	89 85 48 ff ff ff    	mov    %eax,-0xb8(%ebp)
	for (i = 0; i < nblock; i++) {
  80057b:	85 c0                	test   %eax,%eax
  80057d:	74 7d                	je     8005fc <file_open+0x149>
  80057f:	c7 85 50 ff ff ff 00 	movl   $0x0,-0xb0(%ebp)
  800586:	00 00 00 
  800589:	89 bd 44 ff ff ff    	mov    %edi,-0xbc(%ebp)
		if ((r = file_get_block(dir, i, &blk)) < 0)
  80058f:	83 ec 04             	sub    $0x4,%esp
  800592:	8d 85 64 ff ff ff    	lea    -0x9c(%ebp),%eax
  800598:	50                   	push   %eax
  800599:	ff b5 50 ff ff ff    	pushl  -0xb0(%ebp)
  80059f:	ff b5 4c ff ff ff    	pushl  -0xb4(%ebp)
  8005a5:	e8 8f fe ff ff       	call   800439 <file_get_block>
  8005aa:	83 c4 10             	add    $0x10,%esp
  8005ad:	85 c0                	test   %eax,%eax
  8005af:	0f 88 ae 00 00 00    	js     800663 <file_open+0x1b0>
			return r;
		f = (struct File*) blk;
  8005b5:	8b 9d 64 ff ff ff    	mov    -0x9c(%ebp),%ebx
  8005bb:	8d bb 00 10 00 00    	lea    0x1000(%ebx),%edi
		for (j = 0; j < BLKFILES; j++)
			if (strcmp(f[j].f_name, name) == 0) {
  8005c1:	89 9d 54 ff ff ff    	mov    %ebx,-0xac(%ebp)
  8005c7:	83 ec 08             	sub    $0x8,%esp
  8005ca:	56                   	push   %esi
  8005cb:	53                   	push   %ebx
  8005cc:	e8 ed 0c 00 00       	call   8012be <strcmp>
  8005d1:	83 c4 10             	add    $0x10,%esp
  8005d4:	85 c0                	test   %eax,%eax
  8005d6:	74 75                	je     80064d <file_open+0x19a>
  8005d8:	81 c3 00 01 00 00    	add    $0x100,%ebx
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
		if ((r = file_get_block(dir, i, &blk)) < 0)
			return r;
		f = (struct File*) blk;
		for (j = 0; j < BLKFILES; j++)
  8005de:	39 fb                	cmp    %edi,%ebx
  8005e0:	75 df                	jne    8005c1 <file_open+0x10e>
	// Search dir for name.
	// We maintain the invariant that the size of a directory-file
	// is always a multiple of the file system's block size.
	assert((dir->f_size % BLKSIZE) == 0);
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
  8005e2:	ff 85 50 ff ff ff    	incl   -0xb0(%ebp)
  8005e8:	8b 85 50 ff ff ff    	mov    -0xb0(%ebp),%eax
  8005ee:	39 85 48 ff ff ff    	cmp    %eax,-0xb8(%ebp)
  8005f4:	75 99                	jne    80058f <file_open+0xdc>
  8005f6:	8b bd 44 ff ff ff    	mov    -0xbc(%ebp),%edi

		if (dir->f_type != FTYPE_DIR)
			return -E_NOT_FOUND;

		if ((r = dir_lookup(dir, name, &f)) < 0) {
			if (r == -E_NOT_FOUND && *path == '\0') {
  8005fc:	80 3f 00             	cmpb   $0x0,(%edi)
  8005ff:	75 45                	jne    800646 <file_open+0x193>
				if (pdir)
					*pdir = dir;
				if (lastelem)
					strcpy(lastelem, name);
				*pf = 0;
  800601:	8b 45 0c             	mov    0xc(%ebp),%eax
  800604:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
			}
			return r;
  80060a:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  80060f:	eb 5d                	jmp    80066e <file_open+0x1bb>
	name[0] = 0;

	if (pdir)
		*pdir = 0;
	*pf = 0;
	while (*path != '\0') {
  800611:	8a 02                	mov    (%edx),%al
  800613:	84 c0                	test   %al,%al
  800615:	74 0f                	je     800626 <file_open+0x173>
		dir = f;
		p = path;
		while (*path != '/' && *path != '\0')
  800617:	89 d7                	mov    %edx,%edi
  800619:	3c 2f                	cmp    $0x2f,%al
  80061b:	0f 85 d5 fe ff ff    	jne    8004f6 <file_open+0x43>
  800621:	e9 db fe ff ff       	jmp    800501 <file_open+0x4e>
		}
	}

	if (pdir)
		*pdir = dir;
	*pf = f;
  800626:	8b 45 0c             	mov    0xc(%ebp),%eax
  800629:	8b 8d 4c ff ff ff    	mov    -0xb4(%ebp),%ecx
  80062f:	89 08                	mov    %ecx,(%eax)
	return 0;
  800631:	b8 00 00 00 00       	mov    $0x0,%eax
  800636:	eb 36                	jmp    80066e <file_open+0x1bb>
		dir = f;
		p = path;
		while (*path != '/' && *path != '\0')
			path++;
		if (path - p >= MAXNAMELEN)
			return -E_BAD_PATH;
  800638:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  80063d:	eb 2f                	jmp    80066e <file_open+0x1bb>
		memmove(name, p, path - p);
		name[path - p] = '\0';
		path = skip_slash(path);

		if (dir->f_type != FTYPE_DIR)
			return -E_NOT_FOUND;
  80063f:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  800644:	eb 28                	jmp    80066e <file_open+0x1bb>
					*pdir = dir;
				if (lastelem)
					strcpy(lastelem, name);
				*pf = 0;
			}
			return r;
  800646:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  80064b:	eb 21                	jmp    80066e <file_open+0x1bb>
  80064d:	8b bd 44 ff ff ff    	mov    -0xbc(%ebp),%edi
	for (i = 0; i < nblock; i++) {
		if ((r = file_get_block(dir, i, &blk)) < 0)
			return r;
		f = (struct File*) blk;
		for (j = 0; j < BLKFILES; j++)
			if (strcmp(f[j].f_name, name) == 0) {
  800653:	8b 85 54 ff ff ff    	mov    -0xac(%ebp),%eax
  800659:	89 85 4c ff ff ff    	mov    %eax,-0xb4(%ebp)
  80065f:	89 fa                	mov    %edi,%edx
  800661:	eb ae                	jmp    800611 <file_open+0x15e>
  800663:	8b bd 44 ff ff ff    	mov    -0xbc(%ebp),%edi

		if (dir->f_type != FTYPE_DIR)
			return -E_NOT_FOUND;

		if ((r = dir_lookup(dir, name, &f)) < 0) {
			if (r == -E_NOT_FOUND && *path == '\0') {
  800669:	83 f8 f5             	cmp    $0xfffffff5,%eax
  80066c:	74 8e                	je     8005fc <file_open+0x149>
// On error return < 0.
int
file_open(const char *path, struct File **pf)
{
	return walk_path(path, 0, pf, 0);
}
  80066e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800671:	5b                   	pop    %ebx
  800672:	5e                   	pop    %esi
  800673:	5f                   	pop    %edi
  800674:	5d                   	pop    %ebp
  800675:	c3                   	ret    

00800676 <file_read>:
// Read count bytes from f into buf, starting from seek position
// offset.  This meant to mimic the standard pread function.
// Returns the number of bytes read, < 0 on error.
ssize_t
file_read(struct File *f, void *buf, size_t count, off_t offset)
{
  800676:	55                   	push   %ebp
  800677:	89 e5                	mov    %esp,%ebp
  800679:	57                   	push   %edi
  80067a:	56                   	push   %esi
  80067b:	53                   	push   %ebx
  80067c:	83 ec 2c             	sub    $0x2c,%esp
  80067f:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800682:	8b 5d 14             	mov    0x14(%ebp),%ebx
	int r, bn;
	off_t pos;
	char *blk;

	if (offset >= f->f_size)
  800685:	8b 45 08             	mov    0x8(%ebp),%eax
  800688:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  80068e:	39 d8                	cmp    %ebx,%eax
  800690:	0f 8e 8f 00 00 00    	jle    800725 <file_read+0xaf>
		return 0;

	count = MIN(count, f->f_size - offset);
  800696:	29 d8                	sub    %ebx,%eax
  800698:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80069b:	3b 45 10             	cmp    0x10(%ebp),%eax
  80069e:	76 06                	jbe    8006a6 <file_read+0x30>
  8006a0:	8b 45 10             	mov    0x10(%ebp),%eax
  8006a3:	89 45 d0             	mov    %eax,-0x30(%ebp)

	for (pos = offset; pos < offset + count; ) {
  8006a6:	89 de                	mov    %ebx,%esi
  8006a8:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8006ab:	01 d8                	add    %ebx,%eax
  8006ad:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8006b0:	39 c3                	cmp    %eax,%ebx
  8006b2:	73 6c                	jae    800720 <file_read+0xaa>
		if ((r = file_get_block(f, pos / BLKSIZE, &blk)) < 0)
  8006b4:	83 ec 04             	sub    $0x4,%esp
  8006b7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8006ba:	50                   	push   %eax
  8006bb:	89 d8                	mov    %ebx,%eax
  8006bd:	85 db                	test   %ebx,%ebx
  8006bf:	79 06                	jns    8006c7 <file_read+0x51>
  8006c1:	8d 83 ff 0f 00 00    	lea    0xfff(%ebx),%eax
  8006c7:	c1 f8 0c             	sar    $0xc,%eax
  8006ca:	50                   	push   %eax
  8006cb:	ff 75 08             	pushl  0x8(%ebp)
  8006ce:	e8 66 fd ff ff       	call   800439 <file_get_block>
  8006d3:	83 c4 10             	add    $0x10,%esp
  8006d6:	85 c0                	test   %eax,%eax
  8006d8:	78 50                	js     80072a <file_read+0xb4>
			return r;
		bn = MIN(BLKSIZE - pos % BLKSIZE, offset + count - pos);
  8006da:	89 d8                	mov    %ebx,%eax
  8006dc:	25 ff 0f 00 80       	and    $0x80000fff,%eax
  8006e1:	79 07                	jns    8006ea <file_read+0x74>
  8006e3:	48                   	dec    %eax
  8006e4:	0d 00 f0 ff ff       	or     $0xfffff000,%eax
  8006e9:	40                   	inc    %eax
  8006ea:	89 c2                	mov    %eax,%edx
  8006ec:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8006ef:	29 f1                	sub    %esi,%ecx
  8006f1:	be 00 10 00 00       	mov    $0x1000,%esi
  8006f6:	29 c6                	sub    %eax,%esi
  8006f8:	89 f0                	mov    %esi,%eax
  8006fa:	89 ce                	mov    %ecx,%esi
  8006fc:	39 c1                	cmp    %eax,%ecx
  8006fe:	76 02                	jbe    800702 <file_read+0x8c>
  800700:	89 c6                	mov    %eax,%esi
		memmove(buf, blk + pos % BLKSIZE, bn);
  800702:	83 ec 04             	sub    $0x4,%esp
  800705:	56                   	push   %esi
  800706:	89 d0                	mov    %edx,%eax
  800708:	03 45 e4             	add    -0x1c(%ebp),%eax
  80070b:	50                   	push   %eax
  80070c:	57                   	push   %edi
  80070d:	e8 c9 0c 00 00       	call   8013db <memmove>
		pos += bn;
  800712:	01 f3                	add    %esi,%ebx
		buf += bn;
  800714:	01 f7                	add    %esi,%edi
	if (offset >= f->f_size)
		return 0;

	count = MIN(count, f->f_size - offset);

	for (pos = offset; pos < offset + count; ) {
  800716:	89 de                	mov    %ebx,%esi
  800718:	83 c4 10             	add    $0x10,%esp
  80071b:	3b 5d d4             	cmp    -0x2c(%ebp),%ebx
  80071e:	72 94                	jb     8006b4 <file_read+0x3e>
		memmove(buf, blk + pos % BLKSIZE, bn);
		pos += bn;
		buf += bn;
	}

	return count;
  800720:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800723:	eb 05                	jmp    80072a <file_read+0xb4>
	int r, bn;
	off_t pos;
	char *blk;

	if (offset >= f->f_size)
		return 0;
  800725:	b8 00 00 00 00       	mov    $0x0,%eax
		pos += bn;
		buf += bn;
	}

	return count;
}
  80072a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80072d:	5b                   	pop    %ebx
  80072e:	5e                   	pop    %esi
  80072f:	5f                   	pop    %edi
  800730:	5d                   	pop    %ebp
  800731:	c3                   	ret    

00800732 <serve_flush>:


// Our read-only file system do nothing for flush
int
serve_flush(envid_t envid, struct Fsreq_flush *req)
{
  800732:	55                   	push   %ebp
  800733:	89 e5                	mov    %esp,%ebp
	return 0;
}
  800735:	b8 00 00 00 00       	mov    $0x0,%eax
  80073a:	5d                   	pop    %ebp
  80073b:	c3                   	ret    

0080073c <serve_init>:
// Virtual address at which to receive page mappings containing client requests.
union Fsipc *fsreq = (union Fsipc *)0x0ffff000;

void
serve_init(void)
{
  80073c:	55                   	push   %ebp
  80073d:	89 e5                	mov    %esp,%ebp
  80073f:	ba 40 30 80 00       	mov    $0x803040,%edx
	int i;
	uintptr_t va = FILEVA;
  800744:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
	for (i = 0; i < MAXOPEN; i++) {
  800749:	b8 00 00 00 00       	mov    $0x0,%eax
		opentab[i].o_fileid = i;
  80074e:	89 02                	mov    %eax,(%edx)
		opentab[i].o_fd = (struct Fd*) va;
  800750:	89 4a 0c             	mov    %ecx,0xc(%edx)
		va += PGSIZE;
  800753:	81 c1 00 10 00 00    	add    $0x1000,%ecx
void
serve_init(void)
{
	int i;
	uintptr_t va = FILEVA;
	for (i = 0; i < MAXOPEN; i++) {
  800759:	40                   	inc    %eax
  80075a:	83 c2 10             	add    $0x10,%edx
  80075d:	3d 00 04 00 00       	cmp    $0x400,%eax
  800762:	75 ea                	jne    80074e <serve_init+0x12>
		opentab[i].o_fileid = i;
		opentab[i].o_fd = (struct Fd*) va;
		va += PGSIZE;
	}
}
  800764:	5d                   	pop    %ebp
  800765:	c3                   	ret    

00800766 <openfile_alloc>:

// Allocate an open file.
int
openfile_alloc(struct OpenFile **o)
{
  800766:	55                   	push   %ebp
  800767:	89 e5                	mov    %esp,%ebp
  800769:	57                   	push   %edi
  80076a:	56                   	push   %esi
  80076b:	53                   	push   %ebx
  80076c:	83 ec 0c             	sub    $0xc,%esp
  80076f:	8b 75 08             	mov    0x8(%ebp),%esi
  800772:	bf 4c 30 80 00       	mov    $0x80304c,%edi
	int i, r;

	// Find an available open-file table entry
	for (i = 0; i < MAXOPEN; i++) {
  800777:	bb 00 00 00 00       	mov    $0x0,%ebx
		switch (pageref(opentab[i].o_fd)) {
  80077c:	83 ec 0c             	sub    $0xc,%esp
  80077f:	ff 37                	pushl  (%edi)
  800781:	e8 5a 1a 00 00       	call   8021e0 <pageref>
  800786:	83 c4 10             	add    $0x10,%esp
  800789:	85 c0                	test   %eax,%eax
  80078b:	74 07                	je     800794 <openfile_alloc+0x2e>
  80078d:	83 f8 01             	cmp    $0x1,%eax
  800790:	74 20                	je     8007b2 <openfile_alloc+0x4c>
  800792:	eb 51                	jmp    8007e5 <openfile_alloc+0x7f>
		case 0:
			if ((r = sys_page_alloc(0, opentab[i].o_fd, PTE_P|PTE_U|PTE_W)) < 0)
  800794:	83 ec 04             	sub    $0x4,%esp
  800797:	6a 07                	push   $0x7
  800799:	89 d8                	mov    %ebx,%eax
  80079b:	c1 e0 04             	shl    $0x4,%eax
  80079e:	ff b0 4c 30 80 00    	pushl  0x80304c(%eax)
  8007a4:	6a 00                	push   $0x0
  8007a6:	e8 d3 0e 00 00       	call   80167e <sys_page_alloc>
  8007ab:	83 c4 10             	add    $0x10,%esp
  8007ae:	85 c0                	test   %eax,%eax
  8007b0:	78 44                	js     8007f6 <openfile_alloc+0x90>
				return r;
			/* fall through */
		case 1:
			opentab[i].o_fileid += MAXOPEN;
  8007b2:	c1 e3 04             	shl    $0x4,%ebx
  8007b5:	8d 83 40 30 80 00    	lea    0x803040(%ebx),%eax
  8007bb:	81 83 40 30 80 00 00 	addl   $0x400,0x803040(%ebx)
  8007c2:	04 00 00 
			*o = &opentab[i];
  8007c5:	89 06                	mov    %eax,(%esi)
			memset(opentab[i].o_fd, 0, PGSIZE);
  8007c7:	83 ec 04             	sub    $0x4,%esp
  8007ca:	68 00 10 00 00       	push   $0x1000
  8007cf:	6a 00                	push   $0x0
  8007d1:	ff b3 4c 30 80 00    	pushl  0x80304c(%ebx)
  8007d7:	e8 b2 0b 00 00       	call   80138e <memset>
			return (*o)->o_fileid;
  8007dc:	8b 06                	mov    (%esi),%eax
  8007de:	8b 00                	mov    (%eax),%eax
  8007e0:	83 c4 10             	add    $0x10,%esp
  8007e3:	eb 11                	jmp    8007f6 <openfile_alloc+0x90>
openfile_alloc(struct OpenFile **o)
{
	int i, r;

	// Find an available open-file table entry
	for (i = 0; i < MAXOPEN; i++) {
  8007e5:	43                   	inc    %ebx
  8007e6:	83 c7 10             	add    $0x10,%edi
  8007e9:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
  8007ef:	75 8b                	jne    80077c <openfile_alloc+0x16>
			*o = &opentab[i];
			memset(opentab[i].o_fd, 0, PGSIZE);
			return (*o)->o_fileid;
		}
	}
	return -E_MAX_OPEN;
  8007f1:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8007f6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007f9:	5b                   	pop    %ebx
  8007fa:	5e                   	pop    %esi
  8007fb:	5f                   	pop    %edi
  8007fc:	5d                   	pop    %ebp
  8007fd:	c3                   	ret    

008007fe <openfile_lookup>:

// Look up an open file for envid.
int
openfile_lookup(envid_t envid, uint32_t fileid, struct OpenFile **po)
{
  8007fe:	55                   	push   %ebp
  8007ff:	89 e5                	mov    %esp,%ebp
  800801:	57                   	push   %edi
  800802:	56                   	push   %esi
  800803:	53                   	push   %ebx
  800804:	83 ec 18             	sub    $0x18,%esp
  800807:	8b 7d 0c             	mov    0xc(%ebp),%edi
	struct OpenFile *o;

	o = &opentab[fileid % MAXOPEN];
  80080a:	89 fb                	mov    %edi,%ebx
  80080c:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
  800812:	89 de                	mov    %ebx,%esi
  800814:	c1 e6 04             	shl    $0x4,%esi
	if (pageref(o->o_fd) == 1 || o->o_fileid != fileid)
  800817:	ff b6 4c 30 80 00    	pushl  0x80304c(%esi)
int
openfile_lookup(envid_t envid, uint32_t fileid, struct OpenFile **po)
{
	struct OpenFile *o;

	o = &opentab[fileid % MAXOPEN];
  80081d:	81 c6 40 30 80 00    	add    $0x803040,%esi
	if (pageref(o->o_fd) == 1 || o->o_fileid != fileid)
  800823:	e8 b8 19 00 00       	call   8021e0 <pageref>
  800828:	83 c4 10             	add    $0x10,%esp
  80082b:	83 f8 01             	cmp    $0x1,%eax
  80082e:	74 17                	je     800847 <openfile_lookup+0x49>
  800830:	c1 e3 04             	shl    $0x4,%ebx
  800833:	3b bb 40 30 80 00    	cmp    0x803040(%ebx),%edi
  800839:	75 13                	jne    80084e <openfile_lookup+0x50>
		return -E_INVAL;
	*po = o;
  80083b:	8b 45 10             	mov    0x10(%ebp),%eax
  80083e:	89 30                	mov    %esi,(%eax)
	return 0;
  800840:	b8 00 00 00 00       	mov    $0x0,%eax
  800845:	eb 0c                	jmp    800853 <openfile_lookup+0x55>
{
	struct OpenFile *o;

	o = &opentab[fileid % MAXOPEN];
	if (pageref(o->o_fd) == 1 || o->o_fileid != fileid)
		return -E_INVAL;
  800847:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80084c:	eb 05                	jmp    800853 <openfile_lookup+0x55>
  80084e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	*po = o;
	return 0;
}
  800853:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800856:	5b                   	pop    %ebx
  800857:	5e                   	pop    %esi
  800858:	5f                   	pop    %edi
  800859:	5d                   	pop    %ebp
  80085a:	c3                   	ret    

0080085b <serve_read>:
// in ipc->read.req_fileid.  Return the bytes read from the file to
// the caller in ipc->readRet, then update the seek position.  Returns
// the number of bytes successfully read, or < 0 on error.
int
serve_read(envid_t envid, union Fsipc *ipc)
{
  80085b:	55                   	push   %ebp
  80085c:	89 e5                	mov    %esp,%ebp
  80085e:	53                   	push   %ebx
  80085f:	83 ec 18             	sub    $0x18,%esp
  800862:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// so filling in ret will overwrite req.
	//
	struct OpenFile *o;
	int r;

	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  800865:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800868:	50                   	push   %eax
  800869:	ff 33                	pushl  (%ebx)
  80086b:	ff 75 08             	pushl  0x8(%ebp)
  80086e:	e8 8b ff ff ff       	call   8007fe <openfile_lookup>
  800873:	83 c4 10             	add    $0x10,%esp
  800876:	85 c0                	test   %eax,%eax
  800878:	78 32                	js     8008ac <serve_read+0x51>
		return r;

	if ((r = file_read(o->o_file, ret->ret_buf,
			   MIN(req->req_n, sizeof ret->ret_buf),
			   o->o_fd->fd_offset)) < 0)
  80087a:	8b 55 f4             	mov    -0xc(%ebp),%edx
	int r;

	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
		return r;

	if ((r = file_read(o->o_file, ret->ret_buf,
  80087d:	8b 42 0c             	mov    0xc(%edx),%eax
  800880:	ff 70 04             	pushl  0x4(%eax)
  800883:	8b 43 04             	mov    0x4(%ebx),%eax
  800886:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80088b:	76 05                	jbe    800892 <serve_read+0x37>
  80088d:	b8 00 10 00 00       	mov    $0x1000,%eax
  800892:	50                   	push   %eax
  800893:	53                   	push   %ebx
  800894:	ff 72 04             	pushl  0x4(%edx)
  800897:	e8 da fd ff ff       	call   800676 <file_read>
  80089c:	83 c4 10             	add    $0x10,%esp
  80089f:	85 c0                	test   %eax,%eax
  8008a1:	78 09                	js     8008ac <serve_read+0x51>
			   MIN(req->req_n, sizeof ret->ret_buf),
			   o->o_fd->fd_offset)) < 0)
		return r;

	o->o_fd->fd_offset += r;
  8008a3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8008a6:	8b 52 0c             	mov    0xc(%edx),%edx
  8008a9:	01 42 04             	add    %eax,0x4(%edx)
	return r;
}
  8008ac:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008af:	c9                   	leave  
  8008b0:	c3                   	ret    

008008b1 <serve_stat>:

// Stat ipc->stat.req_fileid.  Return the file's struct Stat to the
// caller in ipc->statRet.
int
serve_stat(envid_t envid, union Fsipc *ipc)
{
  8008b1:	55                   	push   %ebp
  8008b2:	89 e5                	mov    %esp,%ebp
  8008b4:	53                   	push   %ebx
  8008b5:	83 ec 18             	sub    $0x18,%esp
  8008b8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	if (debug)
		cprintf("serve_stat %08x %08x\n", envid, req->req_fileid);

	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  8008bb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008be:	50                   	push   %eax
  8008bf:	ff 33                	pushl  (%ebx)
  8008c1:	ff 75 08             	pushl  0x8(%ebp)
  8008c4:	e8 35 ff ff ff       	call   8007fe <openfile_lookup>
  8008c9:	83 c4 10             	add    $0x10,%esp
  8008cc:	85 c0                	test   %eax,%eax
  8008ce:	78 3f                	js     80090f <serve_stat+0x5e>
		return r;

	strcpy(ret->ret_name, o->o_file->f_name);
  8008d0:	83 ec 08             	sub    $0x8,%esp
  8008d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008d6:	ff 70 04             	pushl  0x4(%eax)
  8008d9:	53                   	push   %ebx
  8008da:	e8 2f 09 00 00       	call   80120e <strcpy>
	ret->ret_size = o->o_file->f_size;
  8008df:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008e2:	8b 50 04             	mov    0x4(%eax),%edx
  8008e5:	8b 92 80 00 00 00    	mov    0x80(%edx),%edx
  8008eb:	89 93 80 00 00 00    	mov    %edx,0x80(%ebx)
	ret->ret_isdir = (o->o_file->f_type == FTYPE_DIR);
  8008f1:	8b 40 04             	mov    0x4(%eax),%eax
  8008f4:	83 c4 10             	add    $0x10,%esp
  8008f7:	83 b8 84 00 00 00 01 	cmpl   $0x1,0x84(%eax)
  8008fe:	0f 94 c0             	sete   %al
  800901:	0f b6 c0             	movzbl %al,%eax
  800904:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80090a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80090f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800912:	c9                   	leave  
  800913:	c3                   	ret    

00800914 <serve_open>:
// permissions to return to the calling environment in *pg_store and
// *perm_store respectively.
int
serve_open(envid_t envid, struct Fsreq_open *req,
	   void **pg_store, int *perm_store)
{
  800914:	55                   	push   %ebp
  800915:	89 e5                	mov    %esp,%ebp
  800917:	56                   	push   %esi
  800918:	53                   	push   %ebx
  800919:	81 ec 14 04 00 00    	sub    $0x414,%esp
  80091f:	8b 75 0c             	mov    0xc(%ebp),%esi

	if (debug)
		cprintf("serve_open %08x %s 0x%x\n", envid, req->req_path, req->req_omode);

	// Copy in the path, making sure it's null-terminated
	memmove(path, req->req_path, MAXPATHLEN);
  800922:	68 00 04 00 00       	push   $0x400
  800927:	56                   	push   %esi
  800928:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  80092e:	50                   	push   %eax
  80092f:	e8 a7 0a 00 00       	call   8013db <memmove>
	path[MAXPATHLEN-1] = 0;
  800934:	c6 45 f7 00          	movb   $0x0,-0x9(%ebp)

	// Find an open file ID
	if ((r = openfile_alloc(&o)) < 0) {
  800938:	8d 85 f0 fb ff ff    	lea    -0x410(%ebp),%eax
  80093e:	89 04 24             	mov    %eax,(%esp)
  800941:	e8 20 fe ff ff       	call   800766 <openfile_alloc>
  800946:	83 c4 10             	add    $0x10,%esp
  800949:	85 c0                	test   %eax,%eax
  80094b:	78 7a                	js     8009c7 <serve_open+0xb3>
			cprintf("openfile_alloc failed: %e", r);
		return r;
	}
	fileid = r;

	if (req->req_omode != 0) {
  80094d:	8b 9e 00 04 00 00    	mov    0x400(%esi),%ebx
  800953:	85 db                	test   %ebx,%ebx
  800955:	75 74                	jne    8009cb <serve_open+0xb7>
		if (debug)
			cprintf("file_open omode 0x%x unsupported", req->req_omode);
		return -E_INVAL;
	}

	if ((r = file_open(path, &f)) < 0) {
  800957:	83 ec 08             	sub    $0x8,%esp
  80095a:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  800960:	50                   	push   %eax
  800961:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  800967:	50                   	push   %eax
  800968:	e8 46 fb ff ff       	call   8004b3 <file_open>
  80096d:	83 c4 10             	add    $0x10,%esp
  800970:	85 c0                	test   %eax,%eax
  800972:	78 5e                	js     8009d2 <serve_open+0xbe>
			cprintf("file_open failed: %e", r);
		return r;
	}

	// Save the file pointer
	o->o_file = f;
  800974:	8b 85 f0 fb ff ff    	mov    -0x410(%ebp),%eax
  80097a:	8b 95 f4 fb ff ff    	mov    -0x40c(%ebp),%edx
  800980:	89 50 04             	mov    %edx,0x4(%eax)

	// Fill out the Fd structure
	o->o_fd->fd_file.id = o->o_fileid;
  800983:	8b 50 0c             	mov    0xc(%eax),%edx
  800986:	8b 08                	mov    (%eax),%ecx
  800988:	89 4a 0c             	mov    %ecx,0xc(%edx)
	o->o_fd->fd_omode = req->req_omode & O_ACCMODE;
  80098b:	8b 48 0c             	mov    0xc(%eax),%ecx
  80098e:	8b 96 00 04 00 00    	mov    0x400(%esi),%edx
  800994:	83 e2 03             	and    $0x3,%edx
  800997:	89 51 08             	mov    %edx,0x8(%ecx)
	o->o_fd->fd_dev_id = devfile.dev_id;
  80099a:	8b 40 0c             	mov    0xc(%eax),%eax
  80099d:	8b 15 44 70 80 00    	mov    0x807044,%edx
  8009a3:	89 10                	mov    %edx,(%eax)
	o->o_mode = req->req_omode;
  8009a5:	8b 85 f0 fb ff ff    	mov    -0x410(%ebp),%eax
  8009ab:	8b 96 00 04 00 00    	mov    0x400(%esi),%edx
  8009b1:	89 50 08             	mov    %edx,0x8(%eax)
	if (debug)
		cprintf("sending success, page %08x\n", (uintptr_t) o->o_fd);

	// Share the FD page with the caller by setting *pg_store,
	// store its permission in *perm_store
	*pg_store = o->o_fd;
  8009b4:	8b 50 0c             	mov    0xc(%eax),%edx
  8009b7:	8b 45 10             	mov    0x10(%ebp),%eax
  8009ba:	89 10                	mov    %edx,(%eax)
	*perm_store = PTE_P|PTE_U|PTE_W|PTE_SHARE;
  8009bc:	8b 45 14             	mov    0x14(%ebp),%eax
  8009bf:	c7 00 07 04 00 00    	movl   $0x407,(%eax)

	return 0;
  8009c5:	eb 0d                	jmp    8009d4 <serve_open+0xc0>

	// Find an open file ID
	if ((r = openfile_alloc(&o)) < 0) {
		if (debug)
			cprintf("openfile_alloc failed: %e", r);
		return r;
  8009c7:	89 c3                	mov    %eax,%ebx
  8009c9:	eb 09                	jmp    8009d4 <serve_open+0xc0>
	fileid = r;

	if (req->req_omode != 0) {
		if (debug)
			cprintf("file_open omode 0x%x unsupported", req->req_omode);
		return -E_INVAL;
  8009cb:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
  8009d0:	eb 02                	jmp    8009d4 <serve_open+0xc0>
	}

	if ((r = file_open(path, &f)) < 0) {
		if (debug)
			cprintf("file_open failed: %e", r);
		return r;
  8009d2:	89 c3                	mov    %eax,%ebx
	// store its permission in *perm_store
	*pg_store = o->o_fd;
	*perm_store = PTE_P|PTE_U|PTE_W|PTE_SHARE;

	return 0;
}
  8009d4:	89 d8                	mov    %ebx,%eax
  8009d6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8009d9:	5b                   	pop    %ebx
  8009da:	5e                   	pop    %esi
  8009db:	5d                   	pop    %ebp
  8009dc:	c3                   	ret    

008009dd <serve>:
};
#define NHANDLERS (sizeof(handlers)/sizeof(handlers[0]))

void
serve(void)
{
  8009dd:	55                   	push   %ebp
  8009de:	89 e5                	mov    %esp,%ebp
  8009e0:	56                   	push   %esi
  8009e1:	53                   	push   %ebx
  8009e2:	83 ec 10             	sub    $0x10,%esp
	int perm, r;
	void *pg;

	while (1) {
		perm = 0;
		req = ipc_recv((int32_t *) &whom, fsreq, &perm);
  8009e5:	8d 5d f0             	lea    -0x10(%ebp),%ebx
  8009e8:	8d 75 f4             	lea    -0xc(%ebp),%esi
	uint32_t req, whom;
	int perm, r;
	void *pg;

	while (1) {
		perm = 0;
  8009eb:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
		req = ipc_recv((int32_t *) &whom, fsreq, &perm);
  8009f2:	83 ec 04             	sub    $0x4,%esp
  8009f5:	53                   	push   %ebx
  8009f6:	ff 35 3c 30 80 00    	pushl  0x80303c
  8009fc:	56                   	push   %esi
  8009fd:	e8 0b 0f 00 00       	call   80190d <ipc_recv>
		if (debug)
			cprintf("fs req %d from %08x [page %08x: %s]\n",
				req, whom, uvpt[PGNUM(fsreq)], fsreq);

		// All requests must contain an argument page
		if (!(perm & PTE_P)) {
  800a02:	83 c4 10             	add    $0x10,%esp
  800a05:	f6 45 f0 01          	testb  $0x1,-0x10(%ebp)
  800a09:	75 15                	jne    800a20 <serve+0x43>
			cprintf("Invalid request from %08x: no argument page\n",
  800a0b:	83 ec 08             	sub    $0x8,%esp
  800a0e:	ff 75 f4             	pushl  -0xc(%ebp)
  800a11:	68 04 2b 80 00       	push   $0x802b04
  800a16:	e8 0e 02 00 00       	call   800c29 <cprintf>
				whom);
			continue; // just leave it hanging...
  800a1b:	83 c4 10             	add    $0x10,%esp
  800a1e:	eb cb                	jmp    8009eb <serve+0xe>
		}

		pg = NULL;
  800a20:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
		if (req == FSREQ_OPEN) {
  800a27:	83 f8 01             	cmp    $0x1,%eax
  800a2a:	75 18                	jne    800a44 <serve+0x67>
			r = serve_open(whom, (struct Fsreq_open*)fsreq, &pg, &perm);
  800a2c:	53                   	push   %ebx
  800a2d:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800a30:	50                   	push   %eax
  800a31:	ff 35 3c 30 80 00    	pushl  0x80303c
  800a37:	ff 75 f4             	pushl  -0xc(%ebp)
  800a3a:	e8 d5 fe ff ff       	call   800914 <serve_open>
  800a3f:	83 c4 10             	add    $0x10,%esp
  800a42:	eb 3c                	jmp    800a80 <serve+0xa3>
		} else if (req < NHANDLERS && handlers[req]) {
  800a44:	83 f8 06             	cmp    $0x6,%eax
  800a47:	77 1e                	ja     800a67 <serve+0x8a>
  800a49:	8b 14 85 20 30 80 00 	mov    0x803020(,%eax,4),%edx
  800a50:	85 d2                	test   %edx,%edx
  800a52:	74 13                	je     800a67 <serve+0x8a>
			r = handlers[req](whom, fsreq);
  800a54:	83 ec 08             	sub    $0x8,%esp
  800a57:	ff 35 3c 30 80 00    	pushl  0x80303c
  800a5d:	ff 75 f4             	pushl  -0xc(%ebp)
  800a60:	ff d2                	call   *%edx
  800a62:	83 c4 10             	add    $0x10,%esp
  800a65:	eb 19                	jmp    800a80 <serve+0xa3>
		} else {
			cprintf("Invalid request code %d from %08x\n", req, whom);
  800a67:	83 ec 04             	sub    $0x4,%esp
  800a6a:	ff 75 f4             	pushl  -0xc(%ebp)
  800a6d:	50                   	push   %eax
  800a6e:	68 34 2b 80 00       	push   $0x802b34
  800a73:	e8 b1 01 00 00       	call   800c29 <cprintf>
  800a78:	83 c4 10             	add    $0x10,%esp
			r = -E_INVAL;
  800a7b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		}
		ipc_send(whom, r, pg, perm);
  800a80:	ff 75 f0             	pushl  -0x10(%ebp)
  800a83:	ff 75 ec             	pushl  -0x14(%ebp)
  800a86:	50                   	push   %eax
  800a87:	ff 75 f4             	pushl  -0xc(%ebp)
  800a8a:	e8 f3 0e 00 00       	call   801982 <ipc_send>
		sys_page_unmap(0, fsreq);
  800a8f:	83 c4 08             	add    $0x8,%esp
  800a92:	ff 35 3c 30 80 00    	pushl  0x80303c
  800a98:	6a 00                	push   $0x0
  800a9a:	e8 64 0c 00 00       	call   801703 <sys_page_unmap>
  800a9f:	83 c4 10             	add    $0x10,%esp
  800aa2:	e9 44 ff ff ff       	jmp    8009eb <serve+0xe>

00800aa7 <umain>:
	}
}

void
umain(int argc, char **argv)
{
  800aa7:	55                   	push   %ebp
  800aa8:	89 e5                	mov    %esp,%ebp
  800aaa:	83 ec 14             	sub    $0x14,%esp
	static_assert(sizeof(struct File) == 256);
	binaryname = "fs";
  800aad:	c7 05 40 70 80 00 57 	movl   $0x802b57,0x807040
  800ab4:	2b 80 00 
	cprintf("FS is running\n");
  800ab7:	68 5a 2b 80 00       	push   $0x802b5a
  800abc:	e8 68 01 00 00       	call   800c29 <cprintf>
}

static __inline void
outw(int port, uint16_t data)
{
	__asm __volatile("outw %0,%w1" : : "a" (data), "d" (port));
  800ac1:	ba 00 8a 00 00       	mov    $0x8a00,%edx
  800ac6:	b8 00 8a ff ff       	mov    $0xffff8a00,%eax
  800acb:	66 ef                	out    %ax,(%dx)

	// Check that we are able to do I/O
	outw(0x8A00, 0x8A00);
	cprintf("FS can do I/O\n");
  800acd:	c7 04 24 69 2b 80 00 	movl   $0x802b69,(%esp)
  800ad4:	e8 50 01 00 00       	call   800c29 <cprintf>

	serve_init();
  800ad9:	e8 5e fc ff ff       	call   80073c <serve_init>
	fs_init();
  800ade:	e8 0d f9 ff ff       	call   8003f0 <fs_init>
	serve();
  800ae3:	e8 f5 fe ff ff       	call   8009dd <serve>

00800ae8 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800ae8:	55                   	push   %ebp
  800ae9:	89 e5                	mov    %esp,%ebp
  800aeb:	56                   	push   %esi
  800aec:	53                   	push   %ebx
  800aed:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800af0:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800af3:	e8 48 0b 00 00       	call   801640 <sys_getenvid>
  800af8:	25 ff 03 00 00       	and    $0x3ff,%eax
  800afd:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800b04:	c1 e0 07             	shl    $0x7,%eax
  800b07:	29 d0                	sub    %edx,%eax
  800b09:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800b0e:	a3 0c 80 80 00       	mov    %eax,0x80800c

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800b13:	85 db                	test   %ebx,%ebx
  800b15:	7e 07                	jle    800b1e <libmain+0x36>
		binaryname = argv[0];
  800b17:	8b 06                	mov    (%esi),%eax
  800b19:	a3 40 70 80 00       	mov    %eax,0x807040

	// call user main routine
	umain(argc, argv);
  800b1e:	83 ec 08             	sub    $0x8,%esp
  800b21:	56                   	push   %esi
  800b22:	53                   	push   %ebx
  800b23:	e8 7f ff ff ff       	call   800aa7 <umain>

	// exit gracefully
	exit();
  800b28:	e8 0a 00 00 00       	call   800b37 <exit>
}
  800b2d:	83 c4 10             	add    $0x10,%esp
  800b30:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b33:	5b                   	pop    %ebx
  800b34:	5e                   	pop    %esi
  800b35:	5d                   	pop    %ebp
  800b36:	c3                   	ret    

00800b37 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800b37:	55                   	push   %ebp
  800b38:	89 e5                	mov    %esp,%ebp
  800b3a:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800b3d:	e8 09 11 00 00       	call   801c4b <close_all>
	sys_env_destroy(0);
  800b42:	83 ec 0c             	sub    $0xc,%esp
  800b45:	6a 00                	push   $0x0
  800b47:	e8 b3 0a 00 00       	call   8015ff <sys_env_destroy>
}
  800b4c:	83 c4 10             	add    $0x10,%esp
  800b4f:	c9                   	leave  
  800b50:	c3                   	ret    

00800b51 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800b51:	55                   	push   %ebp
  800b52:	89 e5                	mov    %esp,%ebp
  800b54:	56                   	push   %esi
  800b55:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800b56:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800b59:	8b 35 40 70 80 00    	mov    0x807040,%esi
  800b5f:	e8 dc 0a 00 00       	call   801640 <sys_getenvid>
  800b64:	83 ec 0c             	sub    $0xc,%esp
  800b67:	ff 75 0c             	pushl  0xc(%ebp)
  800b6a:	ff 75 08             	pushl  0x8(%ebp)
  800b6d:	56                   	push   %esi
  800b6e:	50                   	push   %eax
  800b6f:	68 84 2b 80 00       	push   $0x802b84
  800b74:	e8 b0 00 00 00       	call   800c29 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800b79:	83 c4 18             	add    $0x18,%esp
  800b7c:	53                   	push   %ebx
  800b7d:	ff 75 10             	pushl  0x10(%ebp)
  800b80:	e8 53 00 00 00       	call   800bd8 <vcprintf>
	cprintf("\n");
  800b85:	c7 04 24 76 2b 80 00 	movl   $0x802b76,(%esp)
  800b8c:	e8 98 00 00 00       	call   800c29 <cprintf>
  800b91:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800b94:	cc                   	int3   
  800b95:	eb fd                	jmp    800b94 <_panic+0x43>

00800b97 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800b97:	55                   	push   %ebp
  800b98:	89 e5                	mov    %esp,%ebp
  800b9a:	53                   	push   %ebx
  800b9b:	83 ec 04             	sub    $0x4,%esp
  800b9e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800ba1:	8b 13                	mov    (%ebx),%edx
  800ba3:	8d 42 01             	lea    0x1(%edx),%eax
  800ba6:	89 03                	mov    %eax,(%ebx)
  800ba8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bab:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800baf:	3d ff 00 00 00       	cmp    $0xff,%eax
  800bb4:	75 1a                	jne    800bd0 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800bb6:	83 ec 08             	sub    $0x8,%esp
  800bb9:	68 ff 00 00 00       	push   $0xff
  800bbe:	8d 43 08             	lea    0x8(%ebx),%eax
  800bc1:	50                   	push   %eax
  800bc2:	e8 fb 09 00 00       	call   8015c2 <sys_cputs>
		b->idx = 0;
  800bc7:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800bcd:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800bd0:	ff 43 04             	incl   0x4(%ebx)
}
  800bd3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bd6:	c9                   	leave  
  800bd7:	c3                   	ret    

00800bd8 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800bd8:	55                   	push   %ebp
  800bd9:	89 e5                	mov    %esp,%ebp
  800bdb:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800be1:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800be8:	00 00 00 
	b.cnt = 0;
  800beb:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800bf2:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800bf5:	ff 75 0c             	pushl  0xc(%ebp)
  800bf8:	ff 75 08             	pushl  0x8(%ebp)
  800bfb:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800c01:	50                   	push   %eax
  800c02:	68 97 0b 80 00       	push   $0x800b97
  800c07:	e8 54 01 00 00       	call   800d60 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800c0c:	83 c4 08             	add    $0x8,%esp
  800c0f:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800c15:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800c1b:	50                   	push   %eax
  800c1c:	e8 a1 09 00 00       	call   8015c2 <sys_cputs>

	return b.cnt;
}
  800c21:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800c27:	c9                   	leave  
  800c28:	c3                   	ret    

00800c29 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800c29:	55                   	push   %ebp
  800c2a:	89 e5                	mov    %esp,%ebp
  800c2c:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800c2f:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800c32:	50                   	push   %eax
  800c33:	ff 75 08             	pushl  0x8(%ebp)
  800c36:	e8 9d ff ff ff       	call   800bd8 <vcprintf>
	va_end(ap);

	return cnt;
}
  800c3b:	c9                   	leave  
  800c3c:	c3                   	ret    

00800c3d <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800c3d:	55                   	push   %ebp
  800c3e:	89 e5                	mov    %esp,%ebp
  800c40:	57                   	push   %edi
  800c41:	56                   	push   %esi
  800c42:	53                   	push   %ebx
  800c43:	83 ec 1c             	sub    $0x1c,%esp
  800c46:	89 c6                	mov    %eax,%esi
  800c48:	89 d7                	mov    %edx,%edi
  800c4a:	8b 45 08             	mov    0x8(%ebp),%eax
  800c4d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c50:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800c53:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800c56:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800c59:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c5e:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800c61:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800c64:	39 d3                	cmp    %edx,%ebx
  800c66:	72 11                	jb     800c79 <printnum+0x3c>
  800c68:	39 45 10             	cmp    %eax,0x10(%ebp)
  800c6b:	76 0c                	jbe    800c79 <printnum+0x3c>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800c6d:	8b 45 14             	mov    0x14(%ebp),%eax
  800c70:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800c73:	85 db                	test   %ebx,%ebx
  800c75:	7f 37                	jg     800cae <printnum+0x71>
  800c77:	eb 44                	jmp    800cbd <printnum+0x80>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800c79:	83 ec 0c             	sub    $0xc,%esp
  800c7c:	ff 75 18             	pushl  0x18(%ebp)
  800c7f:	8b 45 14             	mov    0x14(%ebp),%eax
  800c82:	48                   	dec    %eax
  800c83:	50                   	push   %eax
  800c84:	ff 75 10             	pushl  0x10(%ebp)
  800c87:	83 ec 08             	sub    $0x8,%esp
  800c8a:	ff 75 e4             	pushl  -0x1c(%ebp)
  800c8d:	ff 75 e0             	pushl  -0x20(%ebp)
  800c90:	ff 75 dc             	pushl  -0x24(%ebp)
  800c93:	ff 75 d8             	pushl  -0x28(%ebp)
  800c96:	e8 7d 1a 00 00       	call   802718 <__udivdi3>
  800c9b:	83 c4 18             	add    $0x18,%esp
  800c9e:	52                   	push   %edx
  800c9f:	50                   	push   %eax
  800ca0:	89 fa                	mov    %edi,%edx
  800ca2:	89 f0                	mov    %esi,%eax
  800ca4:	e8 94 ff ff ff       	call   800c3d <printnum>
  800ca9:	83 c4 20             	add    $0x20,%esp
  800cac:	eb 0f                	jmp    800cbd <printnum+0x80>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800cae:	83 ec 08             	sub    $0x8,%esp
  800cb1:	57                   	push   %edi
  800cb2:	ff 75 18             	pushl  0x18(%ebp)
  800cb5:	ff d6                	call   *%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800cb7:	83 c4 10             	add    $0x10,%esp
  800cba:	4b                   	dec    %ebx
  800cbb:	75 f1                	jne    800cae <printnum+0x71>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800cbd:	83 ec 08             	sub    $0x8,%esp
  800cc0:	57                   	push   %edi
  800cc1:	83 ec 04             	sub    $0x4,%esp
  800cc4:	ff 75 e4             	pushl  -0x1c(%ebp)
  800cc7:	ff 75 e0             	pushl  -0x20(%ebp)
  800cca:	ff 75 dc             	pushl  -0x24(%ebp)
  800ccd:	ff 75 d8             	pushl  -0x28(%ebp)
  800cd0:	e8 53 1b 00 00       	call   802828 <__umoddi3>
  800cd5:	83 c4 14             	add    $0x14,%esp
  800cd8:	0f be 80 a7 2b 80 00 	movsbl 0x802ba7(%eax),%eax
  800cdf:	50                   	push   %eax
  800ce0:	ff d6                	call   *%esi
}
  800ce2:	83 c4 10             	add    $0x10,%esp
  800ce5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ce8:	5b                   	pop    %ebx
  800ce9:	5e                   	pop    %esi
  800cea:	5f                   	pop    %edi
  800ceb:	5d                   	pop    %ebp
  800cec:	c3                   	ret    

00800ced <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800ced:	55                   	push   %ebp
  800cee:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800cf0:	83 fa 01             	cmp    $0x1,%edx
  800cf3:	7e 0e                	jle    800d03 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800cf5:	8b 10                	mov    (%eax),%edx
  800cf7:	8d 4a 08             	lea    0x8(%edx),%ecx
  800cfa:	89 08                	mov    %ecx,(%eax)
  800cfc:	8b 02                	mov    (%edx),%eax
  800cfe:	8b 52 04             	mov    0x4(%edx),%edx
  800d01:	eb 22                	jmp    800d25 <getuint+0x38>
	else if (lflag)
  800d03:	85 d2                	test   %edx,%edx
  800d05:	74 10                	je     800d17 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800d07:	8b 10                	mov    (%eax),%edx
  800d09:	8d 4a 04             	lea    0x4(%edx),%ecx
  800d0c:	89 08                	mov    %ecx,(%eax)
  800d0e:	8b 02                	mov    (%edx),%eax
  800d10:	ba 00 00 00 00       	mov    $0x0,%edx
  800d15:	eb 0e                	jmp    800d25 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800d17:	8b 10                	mov    (%eax),%edx
  800d19:	8d 4a 04             	lea    0x4(%edx),%ecx
  800d1c:	89 08                	mov    %ecx,(%eax)
  800d1e:	8b 02                	mov    (%edx),%eax
  800d20:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800d25:	5d                   	pop    %ebp
  800d26:	c3                   	ret    

00800d27 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800d27:	55                   	push   %ebp
  800d28:	89 e5                	mov    %esp,%ebp
  800d2a:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800d2d:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800d30:	8b 10                	mov    (%eax),%edx
  800d32:	3b 50 04             	cmp    0x4(%eax),%edx
  800d35:	73 0a                	jae    800d41 <sprintputch+0x1a>
		*b->buf++ = ch;
  800d37:	8d 4a 01             	lea    0x1(%edx),%ecx
  800d3a:	89 08                	mov    %ecx,(%eax)
  800d3c:	8b 45 08             	mov    0x8(%ebp),%eax
  800d3f:	88 02                	mov    %al,(%edx)
}
  800d41:	5d                   	pop    %ebp
  800d42:	c3                   	ret    

00800d43 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800d43:	55                   	push   %ebp
  800d44:	89 e5                	mov    %esp,%ebp
  800d46:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800d49:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800d4c:	50                   	push   %eax
  800d4d:	ff 75 10             	pushl  0x10(%ebp)
  800d50:	ff 75 0c             	pushl  0xc(%ebp)
  800d53:	ff 75 08             	pushl  0x8(%ebp)
  800d56:	e8 05 00 00 00       	call   800d60 <vprintfmt>
	va_end(ap);
}
  800d5b:	83 c4 10             	add    $0x10,%esp
  800d5e:	c9                   	leave  
  800d5f:	c3                   	ret    

00800d60 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800d60:	55                   	push   %ebp
  800d61:	89 e5                	mov    %esp,%ebp
  800d63:	57                   	push   %edi
  800d64:	56                   	push   %esi
  800d65:	53                   	push   %ebx
  800d66:	83 ec 2c             	sub    $0x2c,%esp
  800d69:	8b 7d 08             	mov    0x8(%ebp),%edi
  800d6c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800d6f:	eb 03                	jmp    800d74 <vprintfmt+0x14>
			break;

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
			for (fmt--; fmt[-1] != '%'; fmt--)
  800d71:	89 75 10             	mov    %esi,0x10(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {    //遍历输入的第一个参数，即输出信息的格式，先把格式字符串中'%'之前的字符一个个输出，因为它们前面没有'%'，所以它们就是要直接显示在屏幕上的
  800d74:	8b 45 10             	mov    0x10(%ebp),%eax
  800d77:	8d 70 01             	lea    0x1(%eax),%esi
  800d7a:	0f b6 00             	movzbl (%eax),%eax
  800d7d:	83 f8 25             	cmp    $0x25,%eax
  800d80:	74 25                	je     800da7 <vprintfmt+0x47>
			if (ch == '\0')									//当然中间如果遇到'\0'，代表这个字符串的访问结束
  800d82:	85 c0                	test   %eax,%eax
  800d84:	75 0d                	jne    800d93 <vprintfmt+0x33>
  800d86:	e9 b5 03 00 00       	jmp    801140 <vprintfmt+0x3e0>
  800d8b:	85 c0                	test   %eax,%eax
  800d8d:	0f 84 ad 03 00 00    	je     801140 <vprintfmt+0x3e0>
				return;
			putch(ch, putdat);								//调用putch函数，把一个字符ch输出到putdat指针所指向的地址中所存放的值对应的地址处
  800d93:	83 ec 08             	sub    $0x8,%esp
  800d96:	53                   	push   %ebx
  800d97:	50                   	push   %eax
  800d98:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {    //遍历输入的第一个参数，即输出信息的格式，先把格式字符串中'%'之前的字符一个个输出，因为它们前面没有'%'，所以它们就是要直接显示在屏幕上的
  800d9a:	46                   	inc    %esi
  800d9b:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  800d9f:	83 c4 10             	add    $0x10,%esp
  800da2:	83 f8 25             	cmp    $0x25,%eax
  800da5:	75 e4                	jne    800d8b <vprintfmt+0x2b>
			if (width < 0)									//代表有小数点，但是小数点前面并没有数字，比如'%.6f'这种情况，此时代表整数部分全部显示
				width = 0;			
			goto reswitch;

		case '#':
			altflag = 1;
  800da7:	c6 45 e3 20          	movb   $0x20,-0x1d(%ebp)
  800dab:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800db2:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800db9:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800dc0:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800dc7:	eb 07                	jmp    800dd0 <vprintfmt+0x70>
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  800dc9:	8b 75 10             	mov    0x10(%ebp),%esi

		// flag to pad on the right
		case '-':											//%后面的'-'代表要进行左对齐输出，右边填空格，如果省略代表右对齐
			padc = '-';										//如果有这个字符代表左对齐，则把对齐方式标志位变为'-'
  800dcc:	c6 45 e3 2d          	movb   $0x2d,-0x1d(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  800dd0:	8d 46 01             	lea    0x1(%esi),%eax
  800dd3:	89 45 10             	mov    %eax,0x10(%ebp)
  800dd6:	0f b6 16             	movzbl (%esi),%edx
  800dd9:	8a 06                	mov    (%esi),%al
  800ddb:	83 e8 23             	sub    $0x23,%eax
  800dde:	3c 55                	cmp    $0x55,%al
  800de0:	0f 87 03 03 00 00    	ja     8010e9 <vprintfmt+0x389>
  800de6:	0f b6 c0             	movzbl %al,%eax
  800de9:	ff 24 85 e0 2c 80 00 	jmp    *0x802ce0(,%eax,4)
  800df0:	8b 75 10             	mov    0x10(%ebp),%esi
			padc = '-';										//如果有这个字符代表左对齐，则把对齐方式标志位变为'-'
			goto reswitch;									//处理下一个字符

		// flag to pad with 0's instead of spaces
		case '0':											//0--有0表示进行对齐输出时填0,如省略表示填入空格，并且如果为0，则一定是右对齐
			padc = '0';										//对其方式标志位变为0
  800df3:	c6 45 e3 30          	movb   $0x30,-0x1d(%ebp)
  800df7:	eb d7                	jmp    800dd0 <vprintfmt+0x70>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {					//把遇到的位数字符串转换为真实的位数，比如输入的'%40'，代表有效位数为40位，下面的循环就是把precesion的值设置为40
				precision = precision * 10 + ch - '0';
  800df9:	8d 42 d0             	lea    -0x30(%edx),%eax
  800dfc:	89 c1                	mov    %eax,%ecx
  800dfe:	89 45 d0             	mov    %eax,-0x30(%ebp)
				ch = *fmt;
  800e01:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  800e05:	8d 50 d0             	lea    -0x30(%eax),%edx
  800e08:	83 fa 09             	cmp    $0x9,%edx
  800e0b:	77 51                	ja     800e5e <vprintfmt+0xfe>
  800e0d:	8b 75 10             	mov    0x10(%ebp),%esi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {					//把遇到的位数字符串转换为真实的位数，比如输入的'%40'，代表有效位数为40位，下面的循环就是把precesion的值设置为40
  800e10:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  800e11:	8d 14 89             	lea    (%ecx,%ecx,4),%edx
  800e14:	01 d2                	add    %edx,%edx
  800e16:	8d 4c 10 d0          	lea    -0x30(%eax,%edx,1),%ecx
				ch = *fmt;
  800e1a:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800e1d:	8d 50 d0             	lea    -0x30(%eax),%edx
  800e20:	83 fa 09             	cmp    $0x9,%edx
  800e23:	76 eb                	jbe    800e10 <vprintfmt+0xb0>
  800e25:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800e28:	eb 37                	jmp    800e61 <vprintfmt+0x101>
					break;
			}
			goto process_precision;							//跳转到process_precistion子过程

		case '*':											//*--代表有效数字的位数也是由输入参数指定的，比如printf("%*.*f", 10, 2, n)，其中10,2就是用来指定显示的有效数字位数的
			precision = va_arg(ap, int);
  800e2a:	8b 45 14             	mov    0x14(%ebp),%eax
  800e2d:	8d 50 04             	lea    0x4(%eax),%edx
  800e30:	89 55 14             	mov    %edx,0x14(%ebp)
  800e33:	8b 00                	mov    (%eax),%eax
  800e35:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  800e38:	8b 75 10             	mov    0x10(%ebp),%esi
			}
			goto process_precision;							//跳转到process_precistion子过程

		case '*':											//*--代表有效数字的位数也是由输入参数指定的，比如printf("%*.*f", 10, 2, n)，其中10,2就是用来指定显示的有效数字位数的
			precision = va_arg(ap, int);
			goto process_precision;
  800e3b:	eb 24                	jmp    800e61 <vprintfmt+0x101>
  800e3d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800e41:	79 07                	jns    800e4a <vprintfmt+0xea>
  800e43:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  800e4a:	8b 75 10             	mov    0x10(%ebp),%esi
  800e4d:	eb 81                	jmp    800dd0 <vprintfmt+0x70>
  800e4f:	8b 75 10             	mov    0x10(%ebp),%esi
			if (width < 0)									//代表有小数点，但是小数点前面并没有数字，比如'%.6f'这种情况，此时代表整数部分全部显示
				width = 0;			
			goto reswitch;

		case '#':
			altflag = 1;
  800e52:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800e59:	e9 72 ff ff ff       	jmp    800dd0 <vprintfmt+0x70>
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  800e5e:	8b 75 10             	mov    0x10(%ebp),%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:									//处理输出精度，把width字段赋值为刚刚计算出来的precision值，所以width应该是整数部分的有效数字位数
			if (width < 0)
  800e61:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800e65:	0f 89 65 ff ff ff    	jns    800dd0 <vprintfmt+0x70>
				width = precision, precision = -1;
  800e6b:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800e6e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800e71:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800e78:	e9 53 ff ff ff       	jmp    800dd0 <vprintfmt+0x70>
			goto reswitch;

		// long flag (doubled for long long)				
		case 'l':											//如果遇到'l'，代表应该是输入long类型，如果有两个'l'代表long long
			lflag++;										//此时把lflag++
  800e7d:	ff 45 d4             	incl   -0x2c(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  800e80:	8b 75 10             	mov    0x10(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)				
		case 'l':											//如果遇到'l'，代表应该是输入long类型，如果有两个'l'代表long long
			lflag++;										//此时把lflag++
			goto reswitch;
  800e83:	e9 48 ff ff ff       	jmp    800dd0 <vprintfmt+0x70>

		// character
		case 'c':											//如果是'c'代表显示一个字符
			putch(va_arg(ap, int), putdat);					//调用输出一个字符到内存的函数putch
  800e88:	8b 45 14             	mov    0x14(%ebp),%eax
  800e8b:	8d 50 04             	lea    0x4(%eax),%edx
  800e8e:	89 55 14             	mov    %edx,0x14(%ebp)
  800e91:	83 ec 08             	sub    $0x8,%esp
  800e94:	53                   	push   %ebx
  800e95:	ff 30                	pushl  (%eax)
  800e97:	ff d7                	call   *%edi
			break;
  800e99:	83 c4 10             	add    $0x10,%esp
  800e9c:	e9 d3 fe ff ff       	jmp    800d74 <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800ea1:	8b 45 14             	mov    0x14(%ebp),%eax
  800ea4:	8d 50 04             	lea    0x4(%eax),%edx
  800ea7:	89 55 14             	mov    %edx,0x14(%ebp)
  800eaa:	8b 00                	mov    (%eax),%eax
  800eac:	85 c0                	test   %eax,%eax
  800eae:	79 02                	jns    800eb2 <vprintfmt+0x152>
  800eb0:	f7 d8                	neg    %eax
  800eb2:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800eb4:	83 f8 0f             	cmp    $0xf,%eax
  800eb7:	7f 0b                	jg     800ec4 <vprintfmt+0x164>
  800eb9:	8b 04 85 40 2e 80 00 	mov    0x802e40(,%eax,4),%eax
  800ec0:	85 c0                	test   %eax,%eax
  800ec2:	75 15                	jne    800ed9 <vprintfmt+0x179>
				printfmt(putch, putdat, "error %d", err);
  800ec4:	52                   	push   %edx
  800ec5:	68 bf 2b 80 00       	push   $0x802bbf
  800eca:	53                   	push   %ebx
  800ecb:	57                   	push   %edi
  800ecc:	e8 72 fe ff ff       	call   800d43 <printfmt>
  800ed1:	83 c4 10             	add    $0x10,%esp
  800ed4:	e9 9b fe ff ff       	jmp    800d74 <vprintfmt+0x14>
			else
				printfmt(putch, putdat, "%s", p);
  800ed9:	50                   	push   %eax
  800eda:	68 cf 29 80 00       	push   $0x8029cf
  800edf:	53                   	push   %ebx
  800ee0:	57                   	push   %edi
  800ee1:	e8 5d fe ff ff       	call   800d43 <printfmt>
  800ee6:	83 c4 10             	add    $0x10,%esp
  800ee9:	e9 86 fe ff ff       	jmp    800d74 <vprintfmt+0x14>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800eee:	8b 45 14             	mov    0x14(%ebp),%eax
  800ef1:	8d 50 04             	lea    0x4(%eax),%edx
  800ef4:	89 55 14             	mov    %edx,0x14(%ebp)
  800ef7:	8b 00                	mov    (%eax),%eax
  800ef9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800efc:	85 c0                	test   %eax,%eax
  800efe:	75 07                	jne    800f07 <vprintfmt+0x1a7>
				p = "(null)";
  800f00:	c7 45 d4 b8 2b 80 00 	movl   $0x802bb8,-0x2c(%ebp)
			if (width > 0 && padc != '-')
  800f07:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800f0a:	85 f6                	test   %esi,%esi
  800f0c:	0f 8e fb 01 00 00    	jle    80110d <vprintfmt+0x3ad>
  800f12:	80 7d e3 2d          	cmpb   $0x2d,-0x1d(%ebp)
  800f16:	0f 84 09 02 00 00    	je     801125 <vprintfmt+0x3c5>
				for (width -= strnlen(p, precision); width > 0; width--)
  800f1c:	83 ec 08             	sub    $0x8,%esp
  800f1f:	ff 75 d0             	pushl  -0x30(%ebp)
  800f22:	ff 75 d4             	pushl  -0x2c(%ebp)
  800f25:	e8 ad 02 00 00       	call   8011d7 <strnlen>
  800f2a:	89 f1                	mov    %esi,%ecx
  800f2c:	29 c1                	sub    %eax,%ecx
  800f2e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  800f31:	83 c4 10             	add    $0x10,%esp
  800f34:	85 c9                	test   %ecx,%ecx
  800f36:	0f 8e d1 01 00 00    	jle    80110d <vprintfmt+0x3ad>
					putch(padc, putdat);
  800f3c:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  800f40:	83 ec 08             	sub    $0x8,%esp
  800f43:	53                   	push   %ebx
  800f44:	56                   	push   %esi
  800f45:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800f47:	83 c4 10             	add    $0x10,%esp
  800f4a:	ff 4d e4             	decl   -0x1c(%ebp)
  800f4d:	75 f1                	jne    800f40 <vprintfmt+0x1e0>
  800f4f:	e9 b9 01 00 00       	jmp    80110d <vprintfmt+0x3ad>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800f54:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800f58:	74 19                	je     800f73 <vprintfmt+0x213>
  800f5a:	0f be c0             	movsbl %al,%eax
  800f5d:	83 e8 20             	sub    $0x20,%eax
  800f60:	83 f8 5e             	cmp    $0x5e,%eax
  800f63:	76 0e                	jbe    800f73 <vprintfmt+0x213>
					putch('?', putdat);
  800f65:	83 ec 08             	sub    $0x8,%esp
  800f68:	53                   	push   %ebx
  800f69:	6a 3f                	push   $0x3f
  800f6b:	ff 55 08             	call   *0x8(%ebp)
  800f6e:	83 c4 10             	add    $0x10,%esp
  800f71:	eb 0b                	jmp    800f7e <vprintfmt+0x21e>
				else
					putch(ch, putdat);
  800f73:	83 ec 08             	sub    $0x8,%esp
  800f76:	53                   	push   %ebx
  800f77:	52                   	push   %edx
  800f78:	ff 55 08             	call   *0x8(%ebp)
  800f7b:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800f7e:	ff 4d e4             	decl   -0x1c(%ebp)
  800f81:	46                   	inc    %esi
  800f82:	8a 46 ff             	mov    -0x1(%esi),%al
  800f85:	0f be d0             	movsbl %al,%edx
  800f88:	85 d2                	test   %edx,%edx
  800f8a:	75 1c                	jne    800fa8 <vprintfmt+0x248>
  800f8c:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800f8f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800f93:	7f 1f                	jg     800fb4 <vprintfmt+0x254>
  800f95:	e9 da fd ff ff       	jmp    800d74 <vprintfmt+0x14>
  800f9a:	89 7d 08             	mov    %edi,0x8(%ebp)
  800f9d:	8b 7d d0             	mov    -0x30(%ebp),%edi
  800fa0:	eb 06                	jmp    800fa8 <vprintfmt+0x248>
  800fa2:	89 7d 08             	mov    %edi,0x8(%ebp)
  800fa5:	8b 7d d0             	mov    -0x30(%ebp),%edi
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800fa8:	85 ff                	test   %edi,%edi
  800faa:	78 a8                	js     800f54 <vprintfmt+0x1f4>
  800fac:	4f                   	dec    %edi
  800fad:	79 a5                	jns    800f54 <vprintfmt+0x1f4>
  800faf:	8b 7d 08             	mov    0x8(%ebp),%edi
  800fb2:	eb db                	jmp    800f8f <vprintfmt+0x22f>
  800fb4:	8b 75 e4             	mov    -0x1c(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800fb7:	83 ec 08             	sub    $0x8,%esp
  800fba:	53                   	push   %ebx
  800fbb:	6a 20                	push   $0x20
  800fbd:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800fbf:	4e                   	dec    %esi
  800fc0:	83 c4 10             	add    $0x10,%esp
  800fc3:	85 f6                	test   %esi,%esi
  800fc5:	7f f0                	jg     800fb7 <vprintfmt+0x257>
  800fc7:	e9 a8 fd ff ff       	jmp    800d74 <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800fcc:	83 7d d4 01          	cmpl   $0x1,-0x2c(%ebp)
  800fd0:	7e 16                	jle    800fe8 <vprintfmt+0x288>
		return va_arg(*ap, long long);
  800fd2:	8b 45 14             	mov    0x14(%ebp),%eax
  800fd5:	8d 50 08             	lea    0x8(%eax),%edx
  800fd8:	89 55 14             	mov    %edx,0x14(%ebp)
  800fdb:	8b 50 04             	mov    0x4(%eax),%edx
  800fde:	8b 00                	mov    (%eax),%eax
  800fe0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800fe3:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800fe6:	eb 34                	jmp    80101c <vprintfmt+0x2bc>
	else if (lflag)
  800fe8:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800fec:	74 18                	je     801006 <vprintfmt+0x2a6>
		return va_arg(*ap, long);
  800fee:	8b 45 14             	mov    0x14(%ebp),%eax
  800ff1:	8d 50 04             	lea    0x4(%eax),%edx
  800ff4:	89 55 14             	mov    %edx,0x14(%ebp)
  800ff7:	8b 30                	mov    (%eax),%esi
  800ff9:	89 75 d8             	mov    %esi,-0x28(%ebp)
  800ffc:	89 f0                	mov    %esi,%eax
  800ffe:	c1 f8 1f             	sar    $0x1f,%eax
  801001:	89 45 dc             	mov    %eax,-0x24(%ebp)
  801004:	eb 16                	jmp    80101c <vprintfmt+0x2bc>
	else
		return va_arg(*ap, int);
  801006:	8b 45 14             	mov    0x14(%ebp),%eax
  801009:	8d 50 04             	lea    0x4(%eax),%edx
  80100c:	89 55 14             	mov    %edx,0x14(%ebp)
  80100f:	8b 30                	mov    (%eax),%esi
  801011:	89 75 d8             	mov    %esi,-0x28(%ebp)
  801014:	89 f0                	mov    %esi,%eax
  801016:	c1 f8 1f             	sar    $0x1f,%eax
  801019:	89 45 dc             	mov    %eax,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80101c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80101f:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
  801022:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801026:	0f 89 8a 00 00 00    	jns    8010b6 <vprintfmt+0x356>
				putch('-', putdat);
  80102c:	83 ec 08             	sub    $0x8,%esp
  80102f:	53                   	push   %ebx
  801030:	6a 2d                	push   $0x2d
  801032:	ff d7                	call   *%edi
				num = -(long long) num;
  801034:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801037:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80103a:	f7 d8                	neg    %eax
  80103c:	83 d2 00             	adc    $0x0,%edx
  80103f:	f7 da                	neg    %edx
  801041:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801044:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801049:	eb 70                	jmp    8010bb <vprintfmt+0x35b>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80104b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80104e:	8d 45 14             	lea    0x14(%ebp),%eax
  801051:	e8 97 fc ff ff       	call   800ced <getuint>
			base = 10;
  801056:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80105b:	eb 5e                	jmp    8010bb <vprintfmt+0x35b>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
  80105d:	83 ec 08             	sub    $0x8,%esp
  801060:	53                   	push   %ebx
  801061:	6a 30                	push   $0x30
  801063:	ff d7                	call   *%edi
			num = getuint(&ap, lflag);
  801065:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  801068:	8d 45 14             	lea    0x14(%ebp),%eax
  80106b:	e8 7d fc ff ff       	call   800ced <getuint>
			base = 8;
			goto number;
  801070:	83 c4 10             	add    $0x10,%esp
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  801073:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  801078:	eb 41                	jmp    8010bb <vprintfmt+0x35b>
		// pointer
		case 'p':
			putch('0', putdat);
  80107a:	83 ec 08             	sub    $0x8,%esp
  80107d:	53                   	push   %ebx
  80107e:	6a 30                	push   $0x30
  801080:	ff d7                	call   *%edi
			putch('x', putdat);
  801082:	83 c4 08             	add    $0x8,%esp
  801085:	53                   	push   %ebx
  801086:	6a 78                	push   $0x78
  801088:	ff d7                	call   *%edi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80108a:	8b 45 14             	mov    0x14(%ebp),%eax
  80108d:	8d 50 04             	lea    0x4(%eax),%edx
  801090:	89 55 14             	mov    %edx,0x14(%ebp)
			goto number;
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801093:	8b 00                	mov    (%eax),%eax
  801095:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80109a:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80109d:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8010a2:	eb 17                	jmp    8010bb <vprintfmt+0x35b>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8010a4:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8010a7:	8d 45 14             	lea    0x14(%ebp),%eax
  8010aa:	e8 3e fc ff ff       	call   800ced <getuint>
			base = 16;
  8010af:	b9 10 00 00 00       	mov    $0x10,%ecx
  8010b4:	eb 05                	jmp    8010bb <vprintfmt+0x35b>
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8010b6:	b9 0a 00 00 00       	mov    $0xa,%ecx
		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  8010bb:	83 ec 0c             	sub    $0xc,%esp
  8010be:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  8010c2:	56                   	push   %esi
  8010c3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010c6:	51                   	push   %ecx
  8010c7:	52                   	push   %edx
  8010c8:	50                   	push   %eax
  8010c9:	89 da                	mov    %ebx,%edx
  8010cb:	89 f8                	mov    %edi,%eax
  8010cd:	e8 6b fb ff ff       	call   800c3d <printnum>
			break;
  8010d2:	83 c4 20             	add    $0x20,%esp
  8010d5:	e9 9a fc ff ff       	jmp    800d74 <vprintfmt+0x14>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8010da:	83 ec 08             	sub    $0x8,%esp
  8010dd:	53                   	push   %ebx
  8010de:	52                   	push   %edx
  8010df:	ff d7                	call   *%edi
			break;
  8010e1:	83 c4 10             	add    $0x10,%esp
  8010e4:	e9 8b fc ff ff       	jmp    800d74 <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8010e9:	83 ec 08             	sub    $0x8,%esp
  8010ec:	53                   	push   %ebx
  8010ed:	6a 25                	push   $0x25
  8010ef:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8010f1:	83 c4 10             	add    $0x10,%esp
  8010f4:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8010f8:	0f 84 73 fc ff ff    	je     800d71 <vprintfmt+0x11>
  8010fe:	4e                   	dec    %esi
  8010ff:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  801103:	75 f9                	jne    8010fe <vprintfmt+0x39e>
  801105:	89 75 10             	mov    %esi,0x10(%ebp)
  801108:	e9 67 fc ff ff       	jmp    800d74 <vprintfmt+0x14>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80110d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801110:	8d 70 01             	lea    0x1(%eax),%esi
  801113:	8a 00                	mov    (%eax),%al
  801115:	0f be d0             	movsbl %al,%edx
  801118:	85 d2                	test   %edx,%edx
  80111a:	0f 85 7a fe ff ff    	jne    800f9a <vprintfmt+0x23a>
  801120:	e9 4f fc ff ff       	jmp    800d74 <vprintfmt+0x14>
  801125:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801128:	8d 70 01             	lea    0x1(%eax),%esi
  80112b:	8a 00                	mov    (%eax),%al
  80112d:	0f be d0             	movsbl %al,%edx
  801130:	85 d2                	test   %edx,%edx
  801132:	0f 85 6a fe ff ff    	jne    800fa2 <vprintfmt+0x242>
  801138:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80113b:	e9 77 fe ff ff       	jmp    800fb7 <vprintfmt+0x257>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  801140:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801143:	5b                   	pop    %ebx
  801144:	5e                   	pop    %esi
  801145:	5f                   	pop    %edi
  801146:	5d                   	pop    %ebp
  801147:	c3                   	ret    

00801148 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801148:	55                   	push   %ebp
  801149:	89 e5                	mov    %esp,%ebp
  80114b:	83 ec 18             	sub    $0x18,%esp
  80114e:	8b 45 08             	mov    0x8(%ebp),%eax
  801151:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801154:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801157:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80115b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80115e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801165:	85 c0                	test   %eax,%eax
  801167:	74 26                	je     80118f <vsnprintf+0x47>
  801169:	85 d2                	test   %edx,%edx
  80116b:	7e 29                	jle    801196 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80116d:	ff 75 14             	pushl  0x14(%ebp)
  801170:	ff 75 10             	pushl  0x10(%ebp)
  801173:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801176:	50                   	push   %eax
  801177:	68 27 0d 80 00       	push   $0x800d27
  80117c:	e8 df fb ff ff       	call   800d60 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801181:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801184:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801187:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80118a:	83 c4 10             	add    $0x10,%esp
  80118d:	eb 0c                	jmp    80119b <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80118f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801194:	eb 05                	jmp    80119b <vsnprintf+0x53>
  801196:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80119b:	c9                   	leave  
  80119c:	c3                   	ret    

0080119d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80119d:	55                   	push   %ebp
  80119e:	89 e5                	mov    %esp,%ebp
  8011a0:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8011a3:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8011a6:	50                   	push   %eax
  8011a7:	ff 75 10             	pushl  0x10(%ebp)
  8011aa:	ff 75 0c             	pushl  0xc(%ebp)
  8011ad:	ff 75 08             	pushl  0x8(%ebp)
  8011b0:	e8 93 ff ff ff       	call   801148 <vsnprintf>
	va_end(ap);

	return rc;
}
  8011b5:	c9                   	leave  
  8011b6:	c3                   	ret    

008011b7 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8011b7:	55                   	push   %ebp
  8011b8:	89 e5                	mov    %esp,%ebp
  8011ba:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8011bd:	80 3a 00             	cmpb   $0x0,(%edx)
  8011c0:	74 0e                	je     8011d0 <strlen+0x19>
  8011c2:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8011c7:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8011c8:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8011cc:	75 f9                	jne    8011c7 <strlen+0x10>
  8011ce:	eb 05                	jmp    8011d5 <strlen+0x1e>
  8011d0:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8011d5:	5d                   	pop    %ebp
  8011d6:	c3                   	ret    

008011d7 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8011d7:	55                   	push   %ebp
  8011d8:	89 e5                	mov    %esp,%ebp
  8011da:	53                   	push   %ebx
  8011db:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8011de:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8011e1:	85 c9                	test   %ecx,%ecx
  8011e3:	74 1a                	je     8011ff <strnlen+0x28>
  8011e5:	80 3b 00             	cmpb   $0x0,(%ebx)
  8011e8:	74 1c                	je     801206 <strnlen+0x2f>
  8011ea:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  8011ef:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8011f1:	39 ca                	cmp    %ecx,%edx
  8011f3:	74 16                	je     80120b <strnlen+0x34>
  8011f5:	42                   	inc    %edx
  8011f6:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  8011fb:	75 f2                	jne    8011ef <strnlen+0x18>
  8011fd:	eb 0c                	jmp    80120b <strnlen+0x34>
  8011ff:	b8 00 00 00 00       	mov    $0x0,%eax
  801204:	eb 05                	jmp    80120b <strnlen+0x34>
  801206:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  80120b:	5b                   	pop    %ebx
  80120c:	5d                   	pop    %ebp
  80120d:	c3                   	ret    

0080120e <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80120e:	55                   	push   %ebp
  80120f:	89 e5                	mov    %esp,%ebp
  801211:	53                   	push   %ebx
  801212:	8b 45 08             	mov    0x8(%ebp),%eax
  801215:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801218:	89 c2                	mov    %eax,%edx
  80121a:	42                   	inc    %edx
  80121b:	41                   	inc    %ecx
  80121c:	8a 59 ff             	mov    -0x1(%ecx),%bl
  80121f:	88 5a ff             	mov    %bl,-0x1(%edx)
  801222:	84 db                	test   %bl,%bl
  801224:	75 f4                	jne    80121a <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801226:	5b                   	pop    %ebx
  801227:	5d                   	pop    %ebp
  801228:	c3                   	ret    

00801229 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801229:	55                   	push   %ebp
  80122a:	89 e5                	mov    %esp,%ebp
  80122c:	53                   	push   %ebx
  80122d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801230:	53                   	push   %ebx
  801231:	e8 81 ff ff ff       	call   8011b7 <strlen>
  801236:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801239:	ff 75 0c             	pushl  0xc(%ebp)
  80123c:	01 d8                	add    %ebx,%eax
  80123e:	50                   	push   %eax
  80123f:	e8 ca ff ff ff       	call   80120e <strcpy>
	return dst;
}
  801244:	89 d8                	mov    %ebx,%eax
  801246:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801249:	c9                   	leave  
  80124a:	c3                   	ret    

0080124b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80124b:	55                   	push   %ebp
  80124c:	89 e5                	mov    %esp,%ebp
  80124e:	56                   	push   %esi
  80124f:	53                   	push   %ebx
  801250:	8b 75 08             	mov    0x8(%ebp),%esi
  801253:	8b 55 0c             	mov    0xc(%ebp),%edx
  801256:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801259:	85 db                	test   %ebx,%ebx
  80125b:	74 14                	je     801271 <strncpy+0x26>
  80125d:	01 f3                	add    %esi,%ebx
  80125f:	89 f1                	mov    %esi,%ecx
		*dst++ = *src;
  801261:	41                   	inc    %ecx
  801262:	8a 02                	mov    (%edx),%al
  801264:	88 41 ff             	mov    %al,-0x1(%ecx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801267:	80 3a 01             	cmpb   $0x1,(%edx)
  80126a:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80126d:	39 cb                	cmp    %ecx,%ebx
  80126f:	75 f0                	jne    801261 <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801271:	89 f0                	mov    %esi,%eax
  801273:	5b                   	pop    %ebx
  801274:	5e                   	pop    %esi
  801275:	5d                   	pop    %ebp
  801276:	c3                   	ret    

00801277 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801277:	55                   	push   %ebp
  801278:	89 e5                	mov    %esp,%ebp
  80127a:	53                   	push   %ebx
  80127b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80127e:	8b 45 10             	mov    0x10(%ebp),%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801281:	85 c0                	test   %eax,%eax
  801283:	74 30                	je     8012b5 <strlcpy+0x3e>
		while (--size > 0 && *src != '\0')
  801285:	48                   	dec    %eax
  801286:	74 20                	je     8012a8 <strlcpy+0x31>
  801288:	8a 0b                	mov    (%ebx),%cl
  80128a:	84 c9                	test   %cl,%cl
  80128c:	74 1f                	je     8012ad <strlcpy+0x36>
  80128e:	8d 53 01             	lea    0x1(%ebx),%edx
  801291:	01 c3                	add    %eax,%ebx
  801293:	8b 45 08             	mov    0x8(%ebp),%eax
			*dst++ = *src++;
  801296:	40                   	inc    %eax
  801297:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80129a:	39 da                	cmp    %ebx,%edx
  80129c:	74 12                	je     8012b0 <strlcpy+0x39>
  80129e:	42                   	inc    %edx
  80129f:	8a 4a ff             	mov    -0x1(%edx),%cl
  8012a2:	84 c9                	test   %cl,%cl
  8012a4:	75 f0                	jne    801296 <strlcpy+0x1f>
  8012a6:	eb 08                	jmp    8012b0 <strlcpy+0x39>
  8012a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8012ab:	eb 03                	jmp    8012b0 <strlcpy+0x39>
  8012ad:	8b 45 08             	mov    0x8(%ebp),%eax
			*dst++ = *src++;
		*dst = '\0';
  8012b0:	c6 00 00             	movb   $0x0,(%eax)
  8012b3:	eb 03                	jmp    8012b8 <strlcpy+0x41>
  8012b5:	8b 45 08             	mov    0x8(%ebp),%eax
	}
	return dst - dst_in;
  8012b8:	2b 45 08             	sub    0x8(%ebp),%eax
}
  8012bb:	5b                   	pop    %ebx
  8012bc:	5d                   	pop    %ebp
  8012bd:	c3                   	ret    

008012be <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8012be:	55                   	push   %ebp
  8012bf:	89 e5                	mov    %esp,%ebp
  8012c1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012c4:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8012c7:	8a 01                	mov    (%ecx),%al
  8012c9:	84 c0                	test   %al,%al
  8012cb:	74 10                	je     8012dd <strcmp+0x1f>
  8012cd:	3a 02                	cmp    (%edx),%al
  8012cf:	75 0c                	jne    8012dd <strcmp+0x1f>
		p++, q++;
  8012d1:	41                   	inc    %ecx
  8012d2:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8012d3:	8a 01                	mov    (%ecx),%al
  8012d5:	84 c0                	test   %al,%al
  8012d7:	74 04                	je     8012dd <strcmp+0x1f>
  8012d9:	3a 02                	cmp    (%edx),%al
  8012db:	74 f4                	je     8012d1 <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8012dd:	0f b6 c0             	movzbl %al,%eax
  8012e0:	0f b6 12             	movzbl (%edx),%edx
  8012e3:	29 d0                	sub    %edx,%eax
}
  8012e5:	5d                   	pop    %ebp
  8012e6:	c3                   	ret    

008012e7 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8012e7:	55                   	push   %ebp
  8012e8:	89 e5                	mov    %esp,%ebp
  8012ea:	56                   	push   %esi
  8012eb:	53                   	push   %ebx
  8012ec:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8012ef:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012f2:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  8012f5:	85 f6                	test   %esi,%esi
  8012f7:	74 23                	je     80131c <strncmp+0x35>
  8012f9:	8a 03                	mov    (%ebx),%al
  8012fb:	84 c0                	test   %al,%al
  8012fd:	74 2b                	je     80132a <strncmp+0x43>
  8012ff:	3a 02                	cmp    (%edx),%al
  801301:	75 27                	jne    80132a <strncmp+0x43>
  801303:	8d 43 01             	lea    0x1(%ebx),%eax
  801306:	01 de                	add    %ebx,%esi
		n--, p++, q++;
  801308:	89 c3                	mov    %eax,%ebx
  80130a:	42                   	inc    %edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80130b:	39 c6                	cmp    %eax,%esi
  80130d:	74 14                	je     801323 <strncmp+0x3c>
  80130f:	8a 08                	mov    (%eax),%cl
  801311:	84 c9                	test   %cl,%cl
  801313:	74 15                	je     80132a <strncmp+0x43>
  801315:	40                   	inc    %eax
  801316:	3a 0a                	cmp    (%edx),%cl
  801318:	74 ee                	je     801308 <strncmp+0x21>
  80131a:	eb 0e                	jmp    80132a <strncmp+0x43>
		n--, p++, q++;
	if (n == 0)
		return 0;
  80131c:	b8 00 00 00 00       	mov    $0x0,%eax
  801321:	eb 0f                	jmp    801332 <strncmp+0x4b>
  801323:	b8 00 00 00 00       	mov    $0x0,%eax
  801328:	eb 08                	jmp    801332 <strncmp+0x4b>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80132a:	0f b6 03             	movzbl (%ebx),%eax
  80132d:	0f b6 12             	movzbl (%edx),%edx
  801330:	29 d0                	sub    %edx,%eax
}
  801332:	5b                   	pop    %ebx
  801333:	5e                   	pop    %esi
  801334:	5d                   	pop    %ebp
  801335:	c3                   	ret    

00801336 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801336:	55                   	push   %ebp
  801337:	89 e5                	mov    %esp,%ebp
  801339:	53                   	push   %ebx
  80133a:	8b 45 08             	mov    0x8(%ebp),%eax
  80133d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  801340:	8a 10                	mov    (%eax),%dl
  801342:	84 d2                	test   %dl,%dl
  801344:	74 1a                	je     801360 <strchr+0x2a>
  801346:	88 d9                	mov    %bl,%cl
		if (*s == c)
  801348:	38 d3                	cmp    %dl,%bl
  80134a:	75 06                	jne    801352 <strchr+0x1c>
  80134c:	eb 17                	jmp    801365 <strchr+0x2f>
  80134e:	38 ca                	cmp    %cl,%dl
  801350:	74 13                	je     801365 <strchr+0x2f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801352:	40                   	inc    %eax
  801353:	8a 10                	mov    (%eax),%dl
  801355:	84 d2                	test   %dl,%dl
  801357:	75 f5                	jne    80134e <strchr+0x18>
		if (*s == c)
			return (char *) s;
	return 0;
  801359:	b8 00 00 00 00       	mov    $0x0,%eax
  80135e:	eb 05                	jmp    801365 <strchr+0x2f>
  801360:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801365:	5b                   	pop    %ebx
  801366:	5d                   	pop    %ebp
  801367:	c3                   	ret    

00801368 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801368:	55                   	push   %ebp
  801369:	89 e5                	mov    %esp,%ebp
  80136b:	53                   	push   %ebx
  80136c:	8b 45 08             	mov    0x8(%ebp),%eax
  80136f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  801372:	8a 10                	mov    (%eax),%dl
  801374:	84 d2                	test   %dl,%dl
  801376:	74 13                	je     80138b <strfind+0x23>
  801378:	88 d9                	mov    %bl,%cl
		if (*s == c)
  80137a:	38 d3                	cmp    %dl,%bl
  80137c:	75 06                	jne    801384 <strfind+0x1c>
  80137e:	eb 0b                	jmp    80138b <strfind+0x23>
  801380:	38 ca                	cmp    %cl,%dl
  801382:	74 07                	je     80138b <strfind+0x23>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  801384:	40                   	inc    %eax
  801385:	8a 10                	mov    (%eax),%dl
  801387:	84 d2                	test   %dl,%dl
  801389:	75 f5                	jne    801380 <strfind+0x18>
		if (*s == c)
			break;
	return (char *) s;
}
  80138b:	5b                   	pop    %ebx
  80138c:	5d                   	pop    %ebp
  80138d:	c3                   	ret    

0080138e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80138e:	55                   	push   %ebp
  80138f:	89 e5                	mov    %esp,%ebp
  801391:	57                   	push   %edi
  801392:	56                   	push   %esi
  801393:	53                   	push   %ebx
  801394:	8b 7d 08             	mov    0x8(%ebp),%edi
  801397:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80139a:	85 c9                	test   %ecx,%ecx
  80139c:	74 36                	je     8013d4 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80139e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8013a4:	75 28                	jne    8013ce <memset+0x40>
  8013a6:	f6 c1 03             	test   $0x3,%cl
  8013a9:	75 23                	jne    8013ce <memset+0x40>
		c &= 0xFF;
  8013ab:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8013af:	89 d3                	mov    %edx,%ebx
  8013b1:	c1 e3 08             	shl    $0x8,%ebx
  8013b4:	89 d6                	mov    %edx,%esi
  8013b6:	c1 e6 18             	shl    $0x18,%esi
  8013b9:	89 d0                	mov    %edx,%eax
  8013bb:	c1 e0 10             	shl    $0x10,%eax
  8013be:	09 f0                	or     %esi,%eax
  8013c0:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8013c2:	89 d8                	mov    %ebx,%eax
  8013c4:	09 d0                	or     %edx,%eax
  8013c6:	c1 e9 02             	shr    $0x2,%ecx
  8013c9:	fc                   	cld    
  8013ca:	f3 ab                	rep stos %eax,%es:(%edi)
  8013cc:	eb 06                	jmp    8013d4 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8013ce:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013d1:	fc                   	cld    
  8013d2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8013d4:	89 f8                	mov    %edi,%eax
  8013d6:	5b                   	pop    %ebx
  8013d7:	5e                   	pop    %esi
  8013d8:	5f                   	pop    %edi
  8013d9:	5d                   	pop    %ebp
  8013da:	c3                   	ret    

008013db <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8013db:	55                   	push   %ebp
  8013dc:	89 e5                	mov    %esp,%ebp
  8013de:	57                   	push   %edi
  8013df:	56                   	push   %esi
  8013e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8013e3:	8b 75 0c             	mov    0xc(%ebp),%esi
  8013e6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8013e9:	39 c6                	cmp    %eax,%esi
  8013eb:	73 33                	jae    801420 <memmove+0x45>
  8013ed:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8013f0:	39 d0                	cmp    %edx,%eax
  8013f2:	73 2c                	jae    801420 <memmove+0x45>
		s += n;
		d += n;
  8013f4:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8013f7:	89 d6                	mov    %edx,%esi
  8013f9:	09 fe                	or     %edi,%esi
  8013fb:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801401:	75 13                	jne    801416 <memmove+0x3b>
  801403:	f6 c1 03             	test   $0x3,%cl
  801406:	75 0e                	jne    801416 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801408:	83 ef 04             	sub    $0x4,%edi
  80140b:	8d 72 fc             	lea    -0x4(%edx),%esi
  80140e:	c1 e9 02             	shr    $0x2,%ecx
  801411:	fd                   	std    
  801412:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801414:	eb 07                	jmp    80141d <memmove+0x42>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801416:	4f                   	dec    %edi
  801417:	8d 72 ff             	lea    -0x1(%edx),%esi
  80141a:	fd                   	std    
  80141b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80141d:	fc                   	cld    
  80141e:	eb 1d                	jmp    80143d <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801420:	89 f2                	mov    %esi,%edx
  801422:	09 c2                	or     %eax,%edx
  801424:	f6 c2 03             	test   $0x3,%dl
  801427:	75 0f                	jne    801438 <memmove+0x5d>
  801429:	f6 c1 03             	test   $0x3,%cl
  80142c:	75 0a                	jne    801438 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
  80142e:	c1 e9 02             	shr    $0x2,%ecx
  801431:	89 c7                	mov    %eax,%edi
  801433:	fc                   	cld    
  801434:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801436:	eb 05                	jmp    80143d <memmove+0x62>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801438:	89 c7                	mov    %eax,%edi
  80143a:	fc                   	cld    
  80143b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80143d:	5e                   	pop    %esi
  80143e:	5f                   	pop    %edi
  80143f:	5d                   	pop    %ebp
  801440:	c3                   	ret    

00801441 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801441:	55                   	push   %ebp
  801442:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801444:	ff 75 10             	pushl  0x10(%ebp)
  801447:	ff 75 0c             	pushl  0xc(%ebp)
  80144a:	ff 75 08             	pushl  0x8(%ebp)
  80144d:	e8 89 ff ff ff       	call   8013db <memmove>
}
  801452:	c9                   	leave  
  801453:	c3                   	ret    

00801454 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801454:	55                   	push   %ebp
  801455:	89 e5                	mov    %esp,%ebp
  801457:	57                   	push   %edi
  801458:	56                   	push   %esi
  801459:	53                   	push   %ebx
  80145a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80145d:	8b 75 0c             	mov    0xc(%ebp),%esi
  801460:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801463:	85 c0                	test   %eax,%eax
  801465:	74 33                	je     80149a <memcmp+0x46>
  801467:	8d 78 ff             	lea    -0x1(%eax),%edi
		if (*s1 != *s2)
  80146a:	8a 13                	mov    (%ebx),%dl
  80146c:	8a 0e                	mov    (%esi),%cl
  80146e:	38 ca                	cmp    %cl,%dl
  801470:	75 13                	jne    801485 <memcmp+0x31>
  801472:	b8 00 00 00 00       	mov    $0x0,%eax
  801477:	eb 16                	jmp    80148f <memcmp+0x3b>
  801479:	8a 54 03 01          	mov    0x1(%ebx,%eax,1),%dl
  80147d:	40                   	inc    %eax
  80147e:	8a 0c 06             	mov    (%esi,%eax,1),%cl
  801481:	38 ca                	cmp    %cl,%dl
  801483:	74 0a                	je     80148f <memcmp+0x3b>
			return (int) *s1 - (int) *s2;
  801485:	0f b6 c2             	movzbl %dl,%eax
  801488:	0f b6 c9             	movzbl %cl,%ecx
  80148b:	29 c8                	sub    %ecx,%eax
  80148d:	eb 10                	jmp    80149f <memcmp+0x4b>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80148f:	39 f8                	cmp    %edi,%eax
  801491:	75 e6                	jne    801479 <memcmp+0x25>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801493:	b8 00 00 00 00       	mov    $0x0,%eax
  801498:	eb 05                	jmp    80149f <memcmp+0x4b>
  80149a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80149f:	5b                   	pop    %ebx
  8014a0:	5e                   	pop    %esi
  8014a1:	5f                   	pop    %edi
  8014a2:	5d                   	pop    %ebp
  8014a3:	c3                   	ret    

008014a4 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8014a4:	55                   	push   %ebp
  8014a5:	89 e5                	mov    %esp,%ebp
  8014a7:	53                   	push   %ebx
  8014a8:	8b 55 08             	mov    0x8(%ebp),%edx
	const void *ends = (const char *) s + n;
  8014ab:	89 d0                	mov    %edx,%eax
  8014ad:	03 45 10             	add    0x10(%ebp),%eax
	for (; s < ends; s++)
  8014b0:	39 c2                	cmp    %eax,%edx
  8014b2:	73 1b                	jae    8014cf <memfind+0x2b>
		if (*(const unsigned char *) s == (unsigned char) c)
  8014b4:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
  8014b8:	0f b6 0a             	movzbl (%edx),%ecx
  8014bb:	39 d9                	cmp    %ebx,%ecx
  8014bd:	75 09                	jne    8014c8 <memfind+0x24>
  8014bf:	eb 12                	jmp    8014d3 <memfind+0x2f>
  8014c1:	0f b6 0a             	movzbl (%edx),%ecx
  8014c4:	39 d9                	cmp    %ebx,%ecx
  8014c6:	74 0f                	je     8014d7 <memfind+0x33>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8014c8:	42                   	inc    %edx
  8014c9:	39 d0                	cmp    %edx,%eax
  8014cb:	75 f4                	jne    8014c1 <memfind+0x1d>
  8014cd:	eb 0a                	jmp    8014d9 <memfind+0x35>
  8014cf:	89 d0                	mov    %edx,%eax
  8014d1:	eb 06                	jmp    8014d9 <memfind+0x35>
		if (*(const unsigned char *) s == (unsigned char) c)
  8014d3:	89 d0                	mov    %edx,%eax
  8014d5:	eb 02                	jmp    8014d9 <memfind+0x35>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8014d7:	89 d0                	mov    %edx,%eax
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8014d9:	5b                   	pop    %ebx
  8014da:	5d                   	pop    %ebp
  8014db:	c3                   	ret    

008014dc <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8014dc:	55                   	push   %ebp
  8014dd:	89 e5                	mov    %esp,%ebp
  8014df:	57                   	push   %edi
  8014e0:	56                   	push   %esi
  8014e1:	53                   	push   %ebx
  8014e2:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8014e5:	eb 01                	jmp    8014e8 <strtol+0xc>
		s++;
  8014e7:	41                   	inc    %ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8014e8:	8a 01                	mov    (%ecx),%al
  8014ea:	3c 20                	cmp    $0x20,%al
  8014ec:	74 f9                	je     8014e7 <strtol+0xb>
  8014ee:	3c 09                	cmp    $0x9,%al
  8014f0:	74 f5                	je     8014e7 <strtol+0xb>
		s++;

	// plus/minus sign
	if (*s == '+')
  8014f2:	3c 2b                	cmp    $0x2b,%al
  8014f4:	75 08                	jne    8014fe <strtol+0x22>
		s++;
  8014f6:	41                   	inc    %ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8014f7:	bf 00 00 00 00       	mov    $0x0,%edi
  8014fc:	eb 11                	jmp    80150f <strtol+0x33>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8014fe:	3c 2d                	cmp    $0x2d,%al
  801500:	75 08                	jne    80150a <strtol+0x2e>
		s++, neg = 1;
  801502:	41                   	inc    %ecx
  801503:	bf 01 00 00 00       	mov    $0x1,%edi
  801508:	eb 05                	jmp    80150f <strtol+0x33>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80150a:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80150f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801513:	0f 84 87 00 00 00    	je     8015a0 <strtol+0xc4>
  801519:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  80151d:	75 27                	jne    801546 <strtol+0x6a>
  80151f:	80 39 30             	cmpb   $0x30,(%ecx)
  801522:	75 22                	jne    801546 <strtol+0x6a>
  801524:	e9 88 00 00 00       	jmp    8015b1 <strtol+0xd5>
		s += 2, base = 16;
  801529:	83 c1 02             	add    $0x2,%ecx
  80152c:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  801533:	eb 11                	jmp    801546 <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
  801535:	41                   	inc    %ecx
  801536:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  80153d:	eb 07                	jmp    801546 <strtol+0x6a>
	else if (base == 0)
		base = 10;
  80153f:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)
  801546:	b8 00 00 00 00       	mov    $0x0,%eax

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  80154b:	8a 11                	mov    (%ecx),%dl
  80154d:	8d 5a d0             	lea    -0x30(%edx),%ebx
  801550:	80 fb 09             	cmp    $0x9,%bl
  801553:	77 08                	ja     80155d <strtol+0x81>
			dig = *s - '0';
  801555:	0f be d2             	movsbl %dl,%edx
  801558:	83 ea 30             	sub    $0x30,%edx
  80155b:	eb 22                	jmp    80157f <strtol+0xa3>
		else if (*s >= 'a' && *s <= 'z')
  80155d:	8d 72 9f             	lea    -0x61(%edx),%esi
  801560:	89 f3                	mov    %esi,%ebx
  801562:	80 fb 19             	cmp    $0x19,%bl
  801565:	77 08                	ja     80156f <strtol+0x93>
			dig = *s - 'a' + 10;
  801567:	0f be d2             	movsbl %dl,%edx
  80156a:	83 ea 57             	sub    $0x57,%edx
  80156d:	eb 10                	jmp    80157f <strtol+0xa3>
		else if (*s >= 'A' && *s <= 'Z')
  80156f:	8d 72 bf             	lea    -0x41(%edx),%esi
  801572:	89 f3                	mov    %esi,%ebx
  801574:	80 fb 19             	cmp    $0x19,%bl
  801577:	77 14                	ja     80158d <strtol+0xb1>
			dig = *s - 'A' + 10;
  801579:	0f be d2             	movsbl %dl,%edx
  80157c:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  80157f:	3b 55 10             	cmp    0x10(%ebp),%edx
  801582:	7d 09                	jge    80158d <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  801584:	41                   	inc    %ecx
  801585:	0f af 45 10          	imul   0x10(%ebp),%eax
  801589:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  80158b:	eb be                	jmp    80154b <strtol+0x6f>

	if (endptr)
  80158d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801591:	74 05                	je     801598 <strtol+0xbc>
		*endptr = (char *) s;
  801593:	8b 75 0c             	mov    0xc(%ebp),%esi
  801596:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  801598:	85 ff                	test   %edi,%edi
  80159a:	74 21                	je     8015bd <strtol+0xe1>
  80159c:	f7 d8                	neg    %eax
  80159e:	eb 1d                	jmp    8015bd <strtol+0xe1>
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8015a0:	80 39 30             	cmpb   $0x30,(%ecx)
  8015a3:	75 9a                	jne    80153f <strtol+0x63>
  8015a5:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8015a9:	0f 84 7a ff ff ff    	je     801529 <strtol+0x4d>
  8015af:	eb 84                	jmp    801535 <strtol+0x59>
  8015b1:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8015b5:	0f 84 6e ff ff ff    	je     801529 <strtol+0x4d>
  8015bb:	eb 89                	jmp    801546 <strtol+0x6a>
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
}
  8015bd:	5b                   	pop    %ebx
  8015be:	5e                   	pop    %esi
  8015bf:	5f                   	pop    %edi
  8015c0:	5d                   	pop    %ebp
  8015c1:	c3                   	ret    

008015c2 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8015c2:	55                   	push   %ebp
  8015c3:	89 e5                	mov    %esp,%ebp
  8015c5:	57                   	push   %edi
  8015c6:	56                   	push   %esi
  8015c7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8015c8:	b8 00 00 00 00       	mov    $0x0,%eax
  8015cd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8015d0:	8b 55 08             	mov    0x8(%ebp),%edx
  8015d3:	89 c3                	mov    %eax,%ebx
  8015d5:	89 c7                	mov    %eax,%edi
  8015d7:	89 c6                	mov    %eax,%esi
  8015d9:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8015db:	5b                   	pop    %ebx
  8015dc:	5e                   	pop    %esi
  8015dd:	5f                   	pop    %edi
  8015de:	5d                   	pop    %ebp
  8015df:	c3                   	ret    

008015e0 <sys_cgetc>:

int
sys_cgetc(void)
{
  8015e0:	55                   	push   %ebp
  8015e1:	89 e5                	mov    %esp,%ebp
  8015e3:	57                   	push   %edi
  8015e4:	56                   	push   %esi
  8015e5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8015e6:	ba 00 00 00 00       	mov    $0x0,%edx
  8015eb:	b8 01 00 00 00       	mov    $0x1,%eax
  8015f0:	89 d1                	mov    %edx,%ecx
  8015f2:	89 d3                	mov    %edx,%ebx
  8015f4:	89 d7                	mov    %edx,%edi
  8015f6:	89 d6                	mov    %edx,%esi
  8015f8:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8015fa:	5b                   	pop    %ebx
  8015fb:	5e                   	pop    %esi
  8015fc:	5f                   	pop    %edi
  8015fd:	5d                   	pop    %ebp
  8015fe:	c3                   	ret    

008015ff <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8015ff:	55                   	push   %ebp
  801600:	89 e5                	mov    %esp,%ebp
  801602:	57                   	push   %edi
  801603:	56                   	push   %esi
  801604:	53                   	push   %ebx
  801605:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801608:	b9 00 00 00 00       	mov    $0x0,%ecx
  80160d:	b8 03 00 00 00       	mov    $0x3,%eax
  801612:	8b 55 08             	mov    0x8(%ebp),%edx
  801615:	89 cb                	mov    %ecx,%ebx
  801617:	89 cf                	mov    %ecx,%edi
  801619:	89 ce                	mov    %ecx,%esi
  80161b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80161d:	85 c0                	test   %eax,%eax
  80161f:	7e 17                	jle    801638 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  801621:	83 ec 0c             	sub    $0xc,%esp
  801624:	50                   	push   %eax
  801625:	6a 03                	push   $0x3
  801627:	68 9f 2e 80 00       	push   $0x802e9f
  80162c:	6a 23                	push   $0x23
  80162e:	68 bc 2e 80 00       	push   $0x802ebc
  801633:	e8 19 f5 ff ff       	call   800b51 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801638:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80163b:	5b                   	pop    %ebx
  80163c:	5e                   	pop    %esi
  80163d:	5f                   	pop    %edi
  80163e:	5d                   	pop    %ebp
  80163f:	c3                   	ret    

00801640 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  801640:	55                   	push   %ebp
  801641:	89 e5                	mov    %esp,%ebp
  801643:	57                   	push   %edi
  801644:	56                   	push   %esi
  801645:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801646:	ba 00 00 00 00       	mov    $0x0,%edx
  80164b:	b8 02 00 00 00       	mov    $0x2,%eax
  801650:	89 d1                	mov    %edx,%ecx
  801652:	89 d3                	mov    %edx,%ebx
  801654:	89 d7                	mov    %edx,%edi
  801656:	89 d6                	mov    %edx,%esi
  801658:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80165a:	5b                   	pop    %ebx
  80165b:	5e                   	pop    %esi
  80165c:	5f                   	pop    %edi
  80165d:	5d                   	pop    %ebp
  80165e:	c3                   	ret    

0080165f <sys_yield>:

void
sys_yield(void)
{
  80165f:	55                   	push   %ebp
  801660:	89 e5                	mov    %esp,%ebp
  801662:	57                   	push   %edi
  801663:	56                   	push   %esi
  801664:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801665:	ba 00 00 00 00       	mov    $0x0,%edx
  80166a:	b8 0b 00 00 00       	mov    $0xb,%eax
  80166f:	89 d1                	mov    %edx,%ecx
  801671:	89 d3                	mov    %edx,%ebx
  801673:	89 d7                	mov    %edx,%edi
  801675:	89 d6                	mov    %edx,%esi
  801677:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  801679:	5b                   	pop    %ebx
  80167a:	5e                   	pop    %esi
  80167b:	5f                   	pop    %edi
  80167c:	5d                   	pop    %ebp
  80167d:	c3                   	ret    

0080167e <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80167e:	55                   	push   %ebp
  80167f:	89 e5                	mov    %esp,%ebp
  801681:	57                   	push   %edi
  801682:	56                   	push   %esi
  801683:	53                   	push   %ebx
  801684:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801687:	be 00 00 00 00       	mov    $0x0,%esi
  80168c:	b8 04 00 00 00       	mov    $0x4,%eax
  801691:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801694:	8b 55 08             	mov    0x8(%ebp),%edx
  801697:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80169a:	89 f7                	mov    %esi,%edi
  80169c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80169e:	85 c0                	test   %eax,%eax
  8016a0:	7e 17                	jle    8016b9 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8016a2:	83 ec 0c             	sub    $0xc,%esp
  8016a5:	50                   	push   %eax
  8016a6:	6a 04                	push   $0x4
  8016a8:	68 9f 2e 80 00       	push   $0x802e9f
  8016ad:	6a 23                	push   $0x23
  8016af:	68 bc 2e 80 00       	push   $0x802ebc
  8016b4:	e8 98 f4 ff ff       	call   800b51 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8016b9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016bc:	5b                   	pop    %ebx
  8016bd:	5e                   	pop    %esi
  8016be:	5f                   	pop    %edi
  8016bf:	5d                   	pop    %ebp
  8016c0:	c3                   	ret    

008016c1 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8016c1:	55                   	push   %ebp
  8016c2:	89 e5                	mov    %esp,%ebp
  8016c4:	57                   	push   %edi
  8016c5:	56                   	push   %esi
  8016c6:	53                   	push   %ebx
  8016c7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8016ca:	b8 05 00 00 00       	mov    $0x5,%eax
  8016cf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016d2:	8b 55 08             	mov    0x8(%ebp),%edx
  8016d5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8016d8:	8b 7d 14             	mov    0x14(%ebp),%edi
  8016db:	8b 75 18             	mov    0x18(%ebp),%esi
  8016de:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8016e0:	85 c0                	test   %eax,%eax
  8016e2:	7e 17                	jle    8016fb <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8016e4:	83 ec 0c             	sub    $0xc,%esp
  8016e7:	50                   	push   %eax
  8016e8:	6a 05                	push   $0x5
  8016ea:	68 9f 2e 80 00       	push   $0x802e9f
  8016ef:	6a 23                	push   $0x23
  8016f1:	68 bc 2e 80 00       	push   $0x802ebc
  8016f6:	e8 56 f4 ff ff       	call   800b51 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8016fb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016fe:	5b                   	pop    %ebx
  8016ff:	5e                   	pop    %esi
  801700:	5f                   	pop    %edi
  801701:	5d                   	pop    %ebp
  801702:	c3                   	ret    

00801703 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  801703:	55                   	push   %ebp
  801704:	89 e5                	mov    %esp,%ebp
  801706:	57                   	push   %edi
  801707:	56                   	push   %esi
  801708:	53                   	push   %ebx
  801709:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80170c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801711:	b8 06 00 00 00       	mov    $0x6,%eax
  801716:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801719:	8b 55 08             	mov    0x8(%ebp),%edx
  80171c:	89 df                	mov    %ebx,%edi
  80171e:	89 de                	mov    %ebx,%esi
  801720:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801722:	85 c0                	test   %eax,%eax
  801724:	7e 17                	jle    80173d <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801726:	83 ec 0c             	sub    $0xc,%esp
  801729:	50                   	push   %eax
  80172a:	6a 06                	push   $0x6
  80172c:	68 9f 2e 80 00       	push   $0x802e9f
  801731:	6a 23                	push   $0x23
  801733:	68 bc 2e 80 00       	push   $0x802ebc
  801738:	e8 14 f4 ff ff       	call   800b51 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80173d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801740:	5b                   	pop    %ebx
  801741:	5e                   	pop    %esi
  801742:	5f                   	pop    %edi
  801743:	5d                   	pop    %ebp
  801744:	c3                   	ret    

00801745 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801745:	55                   	push   %ebp
  801746:	89 e5                	mov    %esp,%ebp
  801748:	57                   	push   %edi
  801749:	56                   	push   %esi
  80174a:	53                   	push   %ebx
  80174b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80174e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801753:	b8 08 00 00 00       	mov    $0x8,%eax
  801758:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80175b:	8b 55 08             	mov    0x8(%ebp),%edx
  80175e:	89 df                	mov    %ebx,%edi
  801760:	89 de                	mov    %ebx,%esi
  801762:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801764:	85 c0                	test   %eax,%eax
  801766:	7e 17                	jle    80177f <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801768:	83 ec 0c             	sub    $0xc,%esp
  80176b:	50                   	push   %eax
  80176c:	6a 08                	push   $0x8
  80176e:	68 9f 2e 80 00       	push   $0x802e9f
  801773:	6a 23                	push   $0x23
  801775:	68 bc 2e 80 00       	push   $0x802ebc
  80177a:	e8 d2 f3 ff ff       	call   800b51 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80177f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801782:	5b                   	pop    %ebx
  801783:	5e                   	pop    %esi
  801784:	5f                   	pop    %edi
  801785:	5d                   	pop    %ebp
  801786:	c3                   	ret    

00801787 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801787:	55                   	push   %ebp
  801788:	89 e5                	mov    %esp,%ebp
  80178a:	57                   	push   %edi
  80178b:	56                   	push   %esi
  80178c:	53                   	push   %ebx
  80178d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801790:	bb 00 00 00 00       	mov    $0x0,%ebx
  801795:	b8 09 00 00 00       	mov    $0x9,%eax
  80179a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80179d:	8b 55 08             	mov    0x8(%ebp),%edx
  8017a0:	89 df                	mov    %ebx,%edi
  8017a2:	89 de                	mov    %ebx,%esi
  8017a4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8017a6:	85 c0                	test   %eax,%eax
  8017a8:	7e 17                	jle    8017c1 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8017aa:	83 ec 0c             	sub    $0xc,%esp
  8017ad:	50                   	push   %eax
  8017ae:	6a 09                	push   $0x9
  8017b0:	68 9f 2e 80 00       	push   $0x802e9f
  8017b5:	6a 23                	push   $0x23
  8017b7:	68 bc 2e 80 00       	push   $0x802ebc
  8017bc:	e8 90 f3 ff ff       	call   800b51 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8017c1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017c4:	5b                   	pop    %ebx
  8017c5:	5e                   	pop    %esi
  8017c6:	5f                   	pop    %edi
  8017c7:	5d                   	pop    %ebp
  8017c8:	c3                   	ret    

008017c9 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8017c9:	55                   	push   %ebp
  8017ca:	89 e5                	mov    %esp,%ebp
  8017cc:	57                   	push   %edi
  8017cd:	56                   	push   %esi
  8017ce:	53                   	push   %ebx
  8017cf:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8017d2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8017d7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8017dc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017df:	8b 55 08             	mov    0x8(%ebp),%edx
  8017e2:	89 df                	mov    %ebx,%edi
  8017e4:	89 de                	mov    %ebx,%esi
  8017e6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8017e8:	85 c0                	test   %eax,%eax
  8017ea:	7e 17                	jle    801803 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8017ec:	83 ec 0c             	sub    $0xc,%esp
  8017ef:	50                   	push   %eax
  8017f0:	6a 0a                	push   $0xa
  8017f2:	68 9f 2e 80 00       	push   $0x802e9f
  8017f7:	6a 23                	push   $0x23
  8017f9:	68 bc 2e 80 00       	push   $0x802ebc
  8017fe:	e8 4e f3 ff ff       	call   800b51 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801803:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801806:	5b                   	pop    %ebx
  801807:	5e                   	pop    %esi
  801808:	5f                   	pop    %edi
  801809:	5d                   	pop    %ebp
  80180a:	c3                   	ret    

0080180b <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80180b:	55                   	push   %ebp
  80180c:	89 e5                	mov    %esp,%ebp
  80180e:	57                   	push   %edi
  80180f:	56                   	push   %esi
  801810:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801811:	be 00 00 00 00       	mov    $0x0,%esi
  801816:	b8 0c 00 00 00       	mov    $0xc,%eax
  80181b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80181e:	8b 55 08             	mov    0x8(%ebp),%edx
  801821:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801824:	8b 7d 14             	mov    0x14(%ebp),%edi
  801827:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801829:	5b                   	pop    %ebx
  80182a:	5e                   	pop    %esi
  80182b:	5f                   	pop    %edi
  80182c:	5d                   	pop    %ebp
  80182d:	c3                   	ret    

0080182e <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80182e:	55                   	push   %ebp
  80182f:	89 e5                	mov    %esp,%ebp
  801831:	57                   	push   %edi
  801832:	56                   	push   %esi
  801833:	53                   	push   %ebx
  801834:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801837:	b9 00 00 00 00       	mov    $0x0,%ecx
  80183c:	b8 0d 00 00 00       	mov    $0xd,%eax
  801841:	8b 55 08             	mov    0x8(%ebp),%edx
  801844:	89 cb                	mov    %ecx,%ebx
  801846:	89 cf                	mov    %ecx,%edi
  801848:	89 ce                	mov    %ecx,%esi
  80184a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80184c:	85 c0                	test   %eax,%eax
  80184e:	7e 17                	jle    801867 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  801850:	83 ec 0c             	sub    $0xc,%esp
  801853:	50                   	push   %eax
  801854:	6a 0d                	push   $0xd
  801856:	68 9f 2e 80 00       	push   $0x802e9f
  80185b:	6a 23                	push   $0x23
  80185d:	68 bc 2e 80 00       	push   $0x802ebc
  801862:	e8 ea f2 ff ff       	call   800b51 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801867:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80186a:	5b                   	pop    %ebx
  80186b:	5e                   	pop    %esi
  80186c:	5f                   	pop    %edi
  80186d:	5d                   	pop    %ebp
  80186e:	c3                   	ret    

0080186f <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80186f:	55                   	push   %ebp
  801870:	89 e5                	mov    %esp,%ebp
  801872:	53                   	push   %ebx
  801873:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (_pgfault_handler == 0) {
  801876:	83 3d 10 80 80 00 00 	cmpl   $0x0,0x808010
  80187d:	75 5b                	jne    8018da <set_pgfault_handler+0x6b>
		// First time through!
		// LAB 4: Your code here.
		void *va = (void *)(UXSTACKTOP - PGSIZE);
		envid_t eid = sys_getenvid();
  80187f:	e8 bc fd ff ff       	call   801640 <sys_getenvid>
  801884:	89 c3                	mov    %eax,%ebx
		r = sys_page_alloc(eid,va,PTE_P | PTE_U | PTE_W);
  801886:	83 ec 04             	sub    $0x4,%esp
  801889:	6a 07                	push   $0x7
  80188b:	68 00 f0 bf ee       	push   $0xeebff000
  801890:	50                   	push   %eax
  801891:	e8 e8 fd ff ff       	call   80167e <sys_page_alloc>
		if(r<0) panic("set_pgfault_handler\n");
  801896:	83 c4 10             	add    $0x10,%esp
  801899:	85 c0                	test   %eax,%eax
  80189b:	79 14                	jns    8018b1 <set_pgfault_handler+0x42>
  80189d:	83 ec 04             	sub    $0x4,%esp
  8018a0:	68 ca 2e 80 00       	push   $0x802eca
  8018a5:	6a 23                	push   $0x23
  8018a7:	68 df 2e 80 00       	push   $0x802edf
  8018ac:	e8 a0 f2 ff ff       	call   800b51 <_panic>
		r = sys_env_set_pgfault_upcall(eid,_pgfault_upcall);
  8018b1:	83 ec 08             	sub    $0x8,%esp
  8018b4:	68 e7 18 80 00       	push   $0x8018e7
  8018b9:	53                   	push   %ebx
  8018ba:	e8 0a ff ff ff       	call   8017c9 <sys_env_set_pgfault_upcall>
		if(r<0) panic("set_pgfault_handler\n");
  8018bf:	83 c4 10             	add    $0x10,%esp
  8018c2:	85 c0                	test   %eax,%eax
  8018c4:	79 14                	jns    8018da <set_pgfault_handler+0x6b>
  8018c6:	83 ec 04             	sub    $0x4,%esp
  8018c9:	68 ca 2e 80 00       	push   $0x802eca
  8018ce:	6a 25                	push   $0x25
  8018d0:	68 df 2e 80 00       	push   $0x802edf
  8018d5:	e8 77 f2 ff ff       	call   800b51 <_panic>
		// panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8018da:	8b 45 08             	mov    0x8(%ebp),%eax
  8018dd:	a3 10 80 80 00       	mov    %eax,0x808010
}
  8018e2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018e5:	c9                   	leave  
  8018e6:	c3                   	ret    

008018e7 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8018e7:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8018e8:	a1 10 80 80 00       	mov    0x808010,%eax
	call *%eax
  8018ed:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8018ef:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl %esp,%ebx
  8018f2:	89 e3                	mov    %esp,%ebx
	movl 40(%esp),%eax 	// esp from utf_fault_va to utf_regs(end)
  8018f4:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl 48(%esp),%esp 	// 
  8018f8:	8b 64 24 30          	mov    0x30(%esp),%esp
	pushl %eax
  8018fc:	50                   	push   %eax
 
 
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	movl %ebx,%esp
  8018fd:	89 dc                	mov    %ebx,%esp
	subl $4,48(%esp)
  8018ff:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	popl %eax
  801904:	58                   	pop    %eax
	popl %eax
  801905:	58                   	pop    %eax
	popal
  801906:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	add $4,%esp
  801907:	83 c4 04             	add    $0x4,%esp
	popfl
  80190a:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  80190b:	5c                   	pop    %esp
 
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  80190c:	c3                   	ret    

0080190d <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80190d:	55                   	push   %ebp
  80190e:	89 e5                	mov    %esp,%ebp
  801910:	56                   	push   %esi
  801911:	53                   	push   %ebx
  801912:	8b 75 08             	mov    0x8(%ebp),%esi
  801915:	8b 45 0c             	mov    0xc(%ebp),%eax
  801918:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");
	int r;
    if (pg != NULL) {
  80191b:	85 c0                	test   %eax,%eax
  80191d:	74 0e                	je     80192d <ipc_recv+0x20>
        r = sys_ipc_recv(pg);
  80191f:	83 ec 0c             	sub    $0xc,%esp
  801922:	50                   	push   %eax
  801923:	e8 06 ff ff ff       	call   80182e <sys_ipc_recv>
  801928:	83 c4 10             	add    $0x10,%esp
  80192b:	eb 10                	jmp    80193d <ipc_recv+0x30>
    } else {
        r = sys_ipc_recv((void *) UTOP);
  80192d:	83 ec 0c             	sub    $0xc,%esp
  801930:	68 00 00 c0 ee       	push   $0xeec00000
  801935:	e8 f4 fe ff ff       	call   80182e <sys_ipc_recv>
  80193a:	83 c4 10             	add    $0x10,%esp
    }
    if (r < 0) {
  80193d:	85 c0                	test   %eax,%eax
  80193f:	79 16                	jns    801957 <ipc_recv+0x4a>
        // failed
        if (from_env_store != NULL) *from_env_store = 0;
  801941:	85 f6                	test   %esi,%esi
  801943:	74 06                	je     80194b <ipc_recv+0x3e>
  801945:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        if (perm_store != NULL) *perm_store = 0;
  80194b:	85 db                	test   %ebx,%ebx
  80194d:	74 2c                	je     80197b <ipc_recv+0x6e>
  80194f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801955:	eb 24                	jmp    80197b <ipc_recv+0x6e>
        return r;
    } else {
        if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801957:	85 f6                	test   %esi,%esi
  801959:	74 0a                	je     801965 <ipc_recv+0x58>
  80195b:	a1 0c 80 80 00       	mov    0x80800c,%eax
  801960:	8b 40 74             	mov    0x74(%eax),%eax
  801963:	89 06                	mov    %eax,(%esi)
        if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801965:	85 db                	test   %ebx,%ebx
  801967:	74 0a                	je     801973 <ipc_recv+0x66>
  801969:	a1 0c 80 80 00       	mov    0x80800c,%eax
  80196e:	8b 40 78             	mov    0x78(%eax),%eax
  801971:	89 03                	mov    %eax,(%ebx)
        return thisenv->env_ipc_value;
  801973:	a1 0c 80 80 00       	mov    0x80800c,%eax
  801978:	8b 40 70             	mov    0x70(%eax),%eax
    }
 
	return 0;
}
  80197b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80197e:	5b                   	pop    %ebx
  80197f:	5e                   	pop    %esi
  801980:	5d                   	pop    %ebp
  801981:	c3                   	ret    

00801982 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801982:	55                   	push   %ebp
  801983:	89 e5                	mov    %esp,%ebp
  801985:	57                   	push   %edi
  801986:	56                   	push   %esi
  801987:	53                   	push   %ebx
  801988:	83 ec 0c             	sub    $0xc,%esp
  80198b:	8b 75 10             	mov    0x10(%ebp),%esi
  80198e:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");
	int r;
    if (pg == NULL) pg = (void *)UTOP;
  801991:	85 f6                	test   %esi,%esi
  801993:	75 05                	jne    80199a <ipc_send+0x18>
  801995:	be 00 00 c0 ee       	mov    $0xeec00000,%esi
    do {
        r = sys_ipc_try_send(to_env, val, pg, perm);
  80199a:	57                   	push   %edi
  80199b:	56                   	push   %esi
  80199c:	ff 75 0c             	pushl  0xc(%ebp)
  80199f:	ff 75 08             	pushl  0x8(%ebp)
  8019a2:	e8 64 fe ff ff       	call   80180b <sys_ipc_try_send>
  8019a7:	89 c3                	mov    %eax,%ebx
        if (r < 0 && r != -E_IPC_NOT_RECV) panic("ipc send failed: %e", r);
  8019a9:	83 c4 10             	add    $0x10,%esp
  8019ac:	85 c0                	test   %eax,%eax
  8019ae:	79 17                	jns    8019c7 <ipc_send+0x45>
  8019b0:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8019b3:	74 1d                	je     8019d2 <ipc_send+0x50>
  8019b5:	50                   	push   %eax
  8019b6:	68 ed 2e 80 00       	push   $0x802eed
  8019bb:	6a 40                	push   $0x40
  8019bd:	68 01 2f 80 00       	push   $0x802f01
  8019c2:	e8 8a f1 ff ff       	call   800b51 <_panic>
        sys_yield();
  8019c7:	e8 93 fc ff ff       	call   80165f <sys_yield>
    } while (r != 0);
  8019cc:	85 db                	test   %ebx,%ebx
  8019ce:	75 ca                	jne    80199a <ipc_send+0x18>
  8019d0:	eb 07                	jmp    8019d9 <ipc_send+0x57>
	int r;
    if (pg == NULL) pg = (void *)UTOP;
    do {
        r = sys_ipc_try_send(to_env, val, pg, perm);
        if (r < 0 && r != -E_IPC_NOT_RECV) panic("ipc send failed: %e", r);
        sys_yield();
  8019d2:	e8 88 fc ff ff       	call   80165f <sys_yield>
  8019d7:	eb c1                	jmp    80199a <ipc_send+0x18>
    } while (r != 0);
}
  8019d9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019dc:	5b                   	pop    %ebx
  8019dd:	5e                   	pop    %esi
  8019de:	5f                   	pop    %edi
  8019df:	5d                   	pop    %ebp
  8019e0:	c3                   	ret    

008019e1 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8019e1:	55                   	push   %ebp
  8019e2:	89 e5                	mov    %esp,%ebp
  8019e4:	53                   	push   %ebx
  8019e5:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  8019e8:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  8019ed:	39 c1                	cmp    %eax,%ecx
  8019ef:	74 21                	je     801a12 <ipc_find_env+0x31>
  8019f1:	ba 01 00 00 00       	mov    $0x1,%edx
  8019f6:	8d 1c 95 00 00 00 00 	lea    0x0(,%edx,4),%ebx
  8019fd:	89 d0                	mov    %edx,%eax
  8019ff:	c1 e0 07             	shl    $0x7,%eax
  801a02:	29 d8                	sub    %ebx,%eax
  801a04:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801a09:	8b 40 50             	mov    0x50(%eax),%eax
  801a0c:	39 c8                	cmp    %ecx,%eax
  801a0e:	75 1b                	jne    801a2b <ipc_find_env+0x4a>
  801a10:	eb 05                	jmp    801a17 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801a12:	ba 00 00 00 00       	mov    $0x0,%edx
		if (envs[i].env_type == type)
			return envs[i].env_id;
  801a17:	8d 04 95 00 00 00 00 	lea    0x0(,%edx,4),%eax
  801a1e:	c1 e2 07             	shl    $0x7,%edx
  801a21:	29 c2                	sub    %eax,%edx
  801a23:	8b 82 48 00 c0 ee    	mov    -0x113fffb8(%edx),%eax
  801a29:	eb 0e                	jmp    801a39 <ipc_find_env+0x58>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801a2b:	42                   	inc    %edx
  801a2c:	81 fa 00 04 00 00    	cmp    $0x400,%edx
  801a32:	75 c2                	jne    8019f6 <ipc_find_env+0x15>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801a34:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a39:	5b                   	pop    %ebx
  801a3a:	5d                   	pop    %ebp
  801a3b:	c3                   	ret    

00801a3c <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801a3c:	55                   	push   %ebp
  801a3d:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801a3f:	8b 45 08             	mov    0x8(%ebp),%eax
  801a42:	05 00 00 00 30       	add    $0x30000000,%eax
  801a47:	c1 e8 0c             	shr    $0xc,%eax
}
  801a4a:	5d                   	pop    %ebp
  801a4b:	c3                   	ret    

00801a4c <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801a4c:	55                   	push   %ebp
  801a4d:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801a4f:	8b 45 08             	mov    0x8(%ebp),%eax
  801a52:	05 00 00 00 30       	add    $0x30000000,%eax
  801a57:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801a5c:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801a61:	5d                   	pop    %ebp
  801a62:	c3                   	ret    

00801a63 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801a63:	55                   	push   %ebp
  801a64:	89 e5                	mov    %esp,%ebp
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801a66:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  801a6b:	a8 01                	test   $0x1,%al
  801a6d:	74 34                	je     801aa3 <fd_alloc+0x40>
  801a6f:	a1 00 00 74 ef       	mov    0xef740000,%eax
  801a74:	a8 01                	test   $0x1,%al
  801a76:	74 32                	je     801aaa <fd_alloc+0x47>
  801a78:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  801a7d:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801a7f:	89 c2                	mov    %eax,%edx
  801a81:	c1 ea 16             	shr    $0x16,%edx
  801a84:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801a8b:	f6 c2 01             	test   $0x1,%dl
  801a8e:	74 1f                	je     801aaf <fd_alloc+0x4c>
  801a90:	89 c2                	mov    %eax,%edx
  801a92:	c1 ea 0c             	shr    $0xc,%edx
  801a95:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801a9c:	f6 c2 01             	test   $0x1,%dl
  801a9f:	75 1a                	jne    801abb <fd_alloc+0x58>
  801aa1:	eb 0c                	jmp    801aaf <fd_alloc+0x4c>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  801aa3:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  801aa8:	eb 05                	jmp    801aaf <fd_alloc+0x4c>
  801aaa:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  801aaf:	8b 45 08             	mov    0x8(%ebp),%eax
  801ab2:	89 08                	mov    %ecx,(%eax)
			return 0;
  801ab4:	b8 00 00 00 00       	mov    $0x0,%eax
  801ab9:	eb 1a                	jmp    801ad5 <fd_alloc+0x72>
  801abb:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801ac0:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801ac5:	75 b6                	jne    801a7d <fd_alloc+0x1a>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801ac7:	8b 45 08             	mov    0x8(%ebp),%eax
  801aca:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  801ad0:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801ad5:	5d                   	pop    %ebp
  801ad6:	c3                   	ret    

00801ad7 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801ad7:	55                   	push   %ebp
  801ad8:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801ada:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
  801ade:	77 39                	ja     801b19 <fd_lookup+0x42>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801ae0:	8b 45 08             	mov    0x8(%ebp),%eax
  801ae3:	c1 e0 0c             	shl    $0xc,%eax
  801ae6:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801aeb:	89 c2                	mov    %eax,%edx
  801aed:	c1 ea 16             	shr    $0x16,%edx
  801af0:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801af7:	f6 c2 01             	test   $0x1,%dl
  801afa:	74 24                	je     801b20 <fd_lookup+0x49>
  801afc:	89 c2                	mov    %eax,%edx
  801afe:	c1 ea 0c             	shr    $0xc,%edx
  801b01:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801b08:	f6 c2 01             	test   $0x1,%dl
  801b0b:	74 1a                	je     801b27 <fd_lookup+0x50>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801b0d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b10:	89 02                	mov    %eax,(%edx)
	return 0;
  801b12:	b8 00 00 00 00       	mov    $0x0,%eax
  801b17:	eb 13                	jmp    801b2c <fd_lookup+0x55>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801b19:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801b1e:	eb 0c                	jmp    801b2c <fd_lookup+0x55>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801b20:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801b25:	eb 05                	jmp    801b2c <fd_lookup+0x55>
  801b27:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801b2c:	5d                   	pop    %ebp
  801b2d:	c3                   	ret    

00801b2e <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801b2e:	55                   	push   %ebp
  801b2f:	89 e5                	mov    %esp,%ebp
  801b31:	53                   	push   %ebx
  801b32:	83 ec 04             	sub    $0x4,%esp
  801b35:	8b 45 08             	mov    0x8(%ebp),%eax
  801b38:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  801b3b:	3b 05 44 70 80 00    	cmp    0x807044,%eax
  801b41:	75 1e                	jne    801b61 <dev_lookup+0x33>
  801b43:	eb 0e                	jmp    801b53 <dev_lookup+0x25>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801b45:	b8 60 70 80 00       	mov    $0x807060,%eax
  801b4a:	eb 0c                	jmp    801b58 <dev_lookup+0x2a>
  801b4c:	b8 7c 70 80 00       	mov    $0x80707c,%eax
  801b51:	eb 05                	jmp    801b58 <dev_lookup+0x2a>
  801b53:	b8 44 70 80 00       	mov    $0x807044,%eax
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  801b58:	89 03                	mov    %eax,(%ebx)
			return 0;
  801b5a:	b8 00 00 00 00       	mov    $0x0,%eax
  801b5f:	eb 36                	jmp    801b97 <dev_lookup+0x69>
int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  801b61:	3b 05 60 70 80 00    	cmp    0x807060,%eax
  801b67:	74 dc                	je     801b45 <dev_lookup+0x17>
  801b69:	3b 05 7c 70 80 00    	cmp    0x80707c,%eax
  801b6f:	74 db                	je     801b4c <dev_lookup+0x1e>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801b71:	8b 15 0c 80 80 00    	mov    0x80800c,%edx
  801b77:	8b 52 48             	mov    0x48(%edx),%edx
  801b7a:	83 ec 04             	sub    $0x4,%esp
  801b7d:	50                   	push   %eax
  801b7e:	52                   	push   %edx
  801b7f:	68 0c 2f 80 00       	push   $0x802f0c
  801b84:	e8 a0 f0 ff ff       	call   800c29 <cprintf>
	*dev = 0;
  801b89:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  801b8f:	83 c4 10             	add    $0x10,%esp
  801b92:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801b97:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b9a:	c9                   	leave  
  801b9b:	c3                   	ret    

00801b9c <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801b9c:	55                   	push   %ebp
  801b9d:	89 e5                	mov    %esp,%ebp
  801b9f:	56                   	push   %esi
  801ba0:	53                   	push   %ebx
  801ba1:	83 ec 10             	sub    $0x10,%esp
  801ba4:	8b 75 08             	mov    0x8(%ebp),%esi
  801ba7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801baa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bad:	50                   	push   %eax
  801bae:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801bb4:	c1 e8 0c             	shr    $0xc,%eax
  801bb7:	50                   	push   %eax
  801bb8:	e8 1a ff ff ff       	call   801ad7 <fd_lookup>
  801bbd:	83 c4 08             	add    $0x8,%esp
  801bc0:	85 c0                	test   %eax,%eax
  801bc2:	78 05                	js     801bc9 <fd_close+0x2d>
	    || fd != fd2)
  801bc4:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801bc7:	74 06                	je     801bcf <fd_close+0x33>
		return (must_exist ? r : 0);
  801bc9:	84 db                	test   %bl,%bl
  801bcb:	74 47                	je     801c14 <fd_close+0x78>
  801bcd:	eb 4a                	jmp    801c19 <fd_close+0x7d>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801bcf:	83 ec 08             	sub    $0x8,%esp
  801bd2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801bd5:	50                   	push   %eax
  801bd6:	ff 36                	pushl  (%esi)
  801bd8:	e8 51 ff ff ff       	call   801b2e <dev_lookup>
  801bdd:	89 c3                	mov    %eax,%ebx
  801bdf:	83 c4 10             	add    $0x10,%esp
  801be2:	85 c0                	test   %eax,%eax
  801be4:	78 1c                	js     801c02 <fd_close+0x66>
		if (dev->dev_close)
  801be6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801be9:	8b 40 10             	mov    0x10(%eax),%eax
  801bec:	85 c0                	test   %eax,%eax
  801bee:	74 0d                	je     801bfd <fd_close+0x61>
			r = (*dev->dev_close)(fd);
  801bf0:	83 ec 0c             	sub    $0xc,%esp
  801bf3:	56                   	push   %esi
  801bf4:	ff d0                	call   *%eax
  801bf6:	89 c3                	mov    %eax,%ebx
  801bf8:	83 c4 10             	add    $0x10,%esp
  801bfb:	eb 05                	jmp    801c02 <fd_close+0x66>
		else
			r = 0;
  801bfd:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801c02:	83 ec 08             	sub    $0x8,%esp
  801c05:	56                   	push   %esi
  801c06:	6a 00                	push   $0x0
  801c08:	e8 f6 fa ff ff       	call   801703 <sys_page_unmap>
	return r;
  801c0d:	83 c4 10             	add    $0x10,%esp
  801c10:	89 d8                	mov    %ebx,%eax
  801c12:	eb 05                	jmp    801c19 <fd_close+0x7d>
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
  801c14:	b8 00 00 00 00       	mov    $0x0,%eax
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
	return r;
}
  801c19:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c1c:	5b                   	pop    %ebx
  801c1d:	5e                   	pop    %esi
  801c1e:	5d                   	pop    %ebp
  801c1f:	c3                   	ret    

00801c20 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801c20:	55                   	push   %ebp
  801c21:	89 e5                	mov    %esp,%ebp
  801c23:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c26:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c29:	50                   	push   %eax
  801c2a:	ff 75 08             	pushl  0x8(%ebp)
  801c2d:	e8 a5 fe ff ff       	call   801ad7 <fd_lookup>
  801c32:	83 c4 08             	add    $0x8,%esp
  801c35:	85 c0                	test   %eax,%eax
  801c37:	78 10                	js     801c49 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801c39:	83 ec 08             	sub    $0x8,%esp
  801c3c:	6a 01                	push   $0x1
  801c3e:	ff 75 f4             	pushl  -0xc(%ebp)
  801c41:	e8 56 ff ff ff       	call   801b9c <fd_close>
  801c46:	83 c4 10             	add    $0x10,%esp
}
  801c49:	c9                   	leave  
  801c4a:	c3                   	ret    

00801c4b <close_all>:

void
close_all(void)
{
  801c4b:	55                   	push   %ebp
  801c4c:	89 e5                	mov    %esp,%ebp
  801c4e:	53                   	push   %ebx
  801c4f:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801c52:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801c57:	83 ec 0c             	sub    $0xc,%esp
  801c5a:	53                   	push   %ebx
  801c5b:	e8 c0 ff ff ff       	call   801c20 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801c60:	43                   	inc    %ebx
  801c61:	83 c4 10             	add    $0x10,%esp
  801c64:	83 fb 20             	cmp    $0x20,%ebx
  801c67:	75 ee                	jne    801c57 <close_all+0xc>
		close(i);
}
  801c69:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c6c:	c9                   	leave  
  801c6d:	c3                   	ret    

00801c6e <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801c6e:	55                   	push   %ebp
  801c6f:	89 e5                	mov    %esp,%ebp
  801c71:	57                   	push   %edi
  801c72:	56                   	push   %esi
  801c73:	53                   	push   %ebx
  801c74:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801c77:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801c7a:	50                   	push   %eax
  801c7b:	ff 75 08             	pushl  0x8(%ebp)
  801c7e:	e8 54 fe ff ff       	call   801ad7 <fd_lookup>
  801c83:	83 c4 08             	add    $0x8,%esp
  801c86:	85 c0                	test   %eax,%eax
  801c88:	0f 88 c2 00 00 00    	js     801d50 <dup+0xe2>
		return r;
	close(newfdnum);
  801c8e:	83 ec 0c             	sub    $0xc,%esp
  801c91:	ff 75 0c             	pushl  0xc(%ebp)
  801c94:	e8 87 ff ff ff       	call   801c20 <close>

	newfd = INDEX2FD(newfdnum);
  801c99:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801c9c:	c1 e3 0c             	shl    $0xc,%ebx
  801c9f:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801ca5:	83 c4 04             	add    $0x4,%esp
  801ca8:	ff 75 e4             	pushl  -0x1c(%ebp)
  801cab:	e8 9c fd ff ff       	call   801a4c <fd2data>
  801cb0:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  801cb2:	89 1c 24             	mov    %ebx,(%esp)
  801cb5:	e8 92 fd ff ff       	call   801a4c <fd2data>
  801cba:	83 c4 10             	add    $0x10,%esp
  801cbd:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801cbf:	89 f0                	mov    %esi,%eax
  801cc1:	c1 e8 16             	shr    $0x16,%eax
  801cc4:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801ccb:	a8 01                	test   $0x1,%al
  801ccd:	74 35                	je     801d04 <dup+0x96>
  801ccf:	89 f0                	mov    %esi,%eax
  801cd1:	c1 e8 0c             	shr    $0xc,%eax
  801cd4:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801cdb:	f6 c2 01             	test   $0x1,%dl
  801cde:	74 24                	je     801d04 <dup+0x96>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801ce0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801ce7:	83 ec 0c             	sub    $0xc,%esp
  801cea:	25 07 0e 00 00       	and    $0xe07,%eax
  801cef:	50                   	push   %eax
  801cf0:	57                   	push   %edi
  801cf1:	6a 00                	push   $0x0
  801cf3:	56                   	push   %esi
  801cf4:	6a 00                	push   $0x0
  801cf6:	e8 c6 f9 ff ff       	call   8016c1 <sys_page_map>
  801cfb:	89 c6                	mov    %eax,%esi
  801cfd:	83 c4 20             	add    $0x20,%esp
  801d00:	85 c0                	test   %eax,%eax
  801d02:	78 2c                	js     801d30 <dup+0xc2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801d04:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801d07:	89 d0                	mov    %edx,%eax
  801d09:	c1 e8 0c             	shr    $0xc,%eax
  801d0c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801d13:	83 ec 0c             	sub    $0xc,%esp
  801d16:	25 07 0e 00 00       	and    $0xe07,%eax
  801d1b:	50                   	push   %eax
  801d1c:	53                   	push   %ebx
  801d1d:	6a 00                	push   $0x0
  801d1f:	52                   	push   %edx
  801d20:	6a 00                	push   $0x0
  801d22:	e8 9a f9 ff ff       	call   8016c1 <sys_page_map>
  801d27:	89 c6                	mov    %eax,%esi
  801d29:	83 c4 20             	add    $0x20,%esp
  801d2c:	85 c0                	test   %eax,%eax
  801d2e:	79 1d                	jns    801d4d <dup+0xdf>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801d30:	83 ec 08             	sub    $0x8,%esp
  801d33:	53                   	push   %ebx
  801d34:	6a 00                	push   $0x0
  801d36:	e8 c8 f9 ff ff       	call   801703 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801d3b:	83 c4 08             	add    $0x8,%esp
  801d3e:	57                   	push   %edi
  801d3f:	6a 00                	push   $0x0
  801d41:	e8 bd f9 ff ff       	call   801703 <sys_page_unmap>
	return r;
  801d46:	83 c4 10             	add    $0x10,%esp
  801d49:	89 f0                	mov    %esi,%eax
  801d4b:	eb 03                	jmp    801d50 <dup+0xe2>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801d4d:	8b 45 0c             	mov    0xc(%ebp),%eax

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801d50:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d53:	5b                   	pop    %ebx
  801d54:	5e                   	pop    %esi
  801d55:	5f                   	pop    %edi
  801d56:	5d                   	pop    %ebp
  801d57:	c3                   	ret    

00801d58 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801d58:	55                   	push   %ebp
  801d59:	89 e5                	mov    %esp,%ebp
  801d5b:	53                   	push   %ebx
  801d5c:	83 ec 14             	sub    $0x14,%esp
  801d5f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801d62:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d65:	50                   	push   %eax
  801d66:	53                   	push   %ebx
  801d67:	e8 6b fd ff ff       	call   801ad7 <fd_lookup>
  801d6c:	83 c4 08             	add    $0x8,%esp
  801d6f:	85 c0                	test   %eax,%eax
  801d71:	78 67                	js     801dda <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801d73:	83 ec 08             	sub    $0x8,%esp
  801d76:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d79:	50                   	push   %eax
  801d7a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d7d:	ff 30                	pushl  (%eax)
  801d7f:	e8 aa fd ff ff       	call   801b2e <dev_lookup>
  801d84:	83 c4 10             	add    $0x10,%esp
  801d87:	85 c0                	test   %eax,%eax
  801d89:	78 4f                	js     801dda <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801d8b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801d8e:	8b 42 08             	mov    0x8(%edx),%eax
  801d91:	83 e0 03             	and    $0x3,%eax
  801d94:	83 f8 01             	cmp    $0x1,%eax
  801d97:	75 21                	jne    801dba <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801d99:	a1 0c 80 80 00       	mov    0x80800c,%eax
  801d9e:	8b 40 48             	mov    0x48(%eax),%eax
  801da1:	83 ec 04             	sub    $0x4,%esp
  801da4:	53                   	push   %ebx
  801da5:	50                   	push   %eax
  801da6:	68 50 2f 80 00       	push   $0x802f50
  801dab:	e8 79 ee ff ff       	call   800c29 <cprintf>
		return -E_INVAL;
  801db0:	83 c4 10             	add    $0x10,%esp
  801db3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801db8:	eb 20                	jmp    801dda <read+0x82>
	}
	if (!dev->dev_read)
  801dba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dbd:	8b 40 08             	mov    0x8(%eax),%eax
  801dc0:	85 c0                	test   %eax,%eax
  801dc2:	74 11                	je     801dd5 <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801dc4:	83 ec 04             	sub    $0x4,%esp
  801dc7:	ff 75 10             	pushl  0x10(%ebp)
  801dca:	ff 75 0c             	pushl  0xc(%ebp)
  801dcd:	52                   	push   %edx
  801dce:	ff d0                	call   *%eax
  801dd0:	83 c4 10             	add    $0x10,%esp
  801dd3:	eb 05                	jmp    801dda <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801dd5:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801dda:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ddd:	c9                   	leave  
  801dde:	c3                   	ret    

00801ddf <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801ddf:	55                   	push   %ebp
  801de0:	89 e5                	mov    %esp,%ebp
  801de2:	57                   	push   %edi
  801de3:	56                   	push   %esi
  801de4:	53                   	push   %ebx
  801de5:	83 ec 0c             	sub    $0xc,%esp
  801de8:	8b 7d 08             	mov    0x8(%ebp),%edi
  801deb:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801dee:	85 f6                	test   %esi,%esi
  801df0:	74 31                	je     801e23 <readn+0x44>
  801df2:	b8 00 00 00 00       	mov    $0x0,%eax
  801df7:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  801dfc:	83 ec 04             	sub    $0x4,%esp
  801dff:	89 f2                	mov    %esi,%edx
  801e01:	29 c2                	sub    %eax,%edx
  801e03:	52                   	push   %edx
  801e04:	03 45 0c             	add    0xc(%ebp),%eax
  801e07:	50                   	push   %eax
  801e08:	57                   	push   %edi
  801e09:	e8 4a ff ff ff       	call   801d58 <read>
		if (m < 0)
  801e0e:	83 c4 10             	add    $0x10,%esp
  801e11:	85 c0                	test   %eax,%eax
  801e13:	78 17                	js     801e2c <readn+0x4d>
			return m;
		if (m == 0)
  801e15:	85 c0                	test   %eax,%eax
  801e17:	74 11                	je     801e2a <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801e19:	01 c3                	add    %eax,%ebx
  801e1b:	89 d8                	mov    %ebx,%eax
  801e1d:	39 f3                	cmp    %esi,%ebx
  801e1f:	72 db                	jb     801dfc <readn+0x1d>
  801e21:	eb 09                	jmp    801e2c <readn+0x4d>
  801e23:	b8 00 00 00 00       	mov    $0x0,%eax
  801e28:	eb 02                	jmp    801e2c <readn+0x4d>
  801e2a:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801e2c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e2f:	5b                   	pop    %ebx
  801e30:	5e                   	pop    %esi
  801e31:	5f                   	pop    %edi
  801e32:	5d                   	pop    %ebp
  801e33:	c3                   	ret    

00801e34 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801e34:	55                   	push   %ebp
  801e35:	89 e5                	mov    %esp,%ebp
  801e37:	53                   	push   %ebx
  801e38:	83 ec 14             	sub    $0x14,%esp
  801e3b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801e3e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801e41:	50                   	push   %eax
  801e42:	53                   	push   %ebx
  801e43:	e8 8f fc ff ff       	call   801ad7 <fd_lookup>
  801e48:	83 c4 08             	add    $0x8,%esp
  801e4b:	85 c0                	test   %eax,%eax
  801e4d:	78 62                	js     801eb1 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801e4f:	83 ec 08             	sub    $0x8,%esp
  801e52:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e55:	50                   	push   %eax
  801e56:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e59:	ff 30                	pushl  (%eax)
  801e5b:	e8 ce fc ff ff       	call   801b2e <dev_lookup>
  801e60:	83 c4 10             	add    $0x10,%esp
  801e63:	85 c0                	test   %eax,%eax
  801e65:	78 4a                	js     801eb1 <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801e67:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e6a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801e6e:	75 21                	jne    801e91 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801e70:	a1 0c 80 80 00       	mov    0x80800c,%eax
  801e75:	8b 40 48             	mov    0x48(%eax),%eax
  801e78:	83 ec 04             	sub    $0x4,%esp
  801e7b:	53                   	push   %ebx
  801e7c:	50                   	push   %eax
  801e7d:	68 6c 2f 80 00       	push   $0x802f6c
  801e82:	e8 a2 ed ff ff       	call   800c29 <cprintf>
		return -E_INVAL;
  801e87:	83 c4 10             	add    $0x10,%esp
  801e8a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801e8f:	eb 20                	jmp    801eb1 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801e91:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801e94:	8b 52 0c             	mov    0xc(%edx),%edx
  801e97:	85 d2                	test   %edx,%edx
  801e99:	74 11                	je     801eac <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801e9b:	83 ec 04             	sub    $0x4,%esp
  801e9e:	ff 75 10             	pushl  0x10(%ebp)
  801ea1:	ff 75 0c             	pushl  0xc(%ebp)
  801ea4:	50                   	push   %eax
  801ea5:	ff d2                	call   *%edx
  801ea7:	83 c4 10             	add    $0x10,%esp
  801eaa:	eb 05                	jmp    801eb1 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801eac:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801eb1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801eb4:	c9                   	leave  
  801eb5:	c3                   	ret    

00801eb6 <seek>:

int
seek(int fdnum, off_t offset)
{
  801eb6:	55                   	push   %ebp
  801eb7:	89 e5                	mov    %esp,%ebp
  801eb9:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ebc:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801ebf:	50                   	push   %eax
  801ec0:	ff 75 08             	pushl  0x8(%ebp)
  801ec3:	e8 0f fc ff ff       	call   801ad7 <fd_lookup>
  801ec8:	83 c4 08             	add    $0x8,%esp
  801ecb:	85 c0                	test   %eax,%eax
  801ecd:	78 0e                	js     801edd <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801ecf:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801ed2:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ed5:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801ed8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801edd:	c9                   	leave  
  801ede:	c3                   	ret    

00801edf <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801edf:	55                   	push   %ebp
  801ee0:	89 e5                	mov    %esp,%ebp
  801ee2:	53                   	push   %ebx
  801ee3:	83 ec 14             	sub    $0x14,%esp
  801ee6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801ee9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801eec:	50                   	push   %eax
  801eed:	53                   	push   %ebx
  801eee:	e8 e4 fb ff ff       	call   801ad7 <fd_lookup>
  801ef3:	83 c4 08             	add    $0x8,%esp
  801ef6:	85 c0                	test   %eax,%eax
  801ef8:	78 5f                	js     801f59 <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801efa:	83 ec 08             	sub    $0x8,%esp
  801efd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f00:	50                   	push   %eax
  801f01:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f04:	ff 30                	pushl  (%eax)
  801f06:	e8 23 fc ff ff       	call   801b2e <dev_lookup>
  801f0b:	83 c4 10             	add    $0x10,%esp
  801f0e:	85 c0                	test   %eax,%eax
  801f10:	78 47                	js     801f59 <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801f12:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f15:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801f19:	75 21                	jne    801f3c <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801f1b:	a1 0c 80 80 00       	mov    0x80800c,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801f20:	8b 40 48             	mov    0x48(%eax),%eax
  801f23:	83 ec 04             	sub    $0x4,%esp
  801f26:	53                   	push   %ebx
  801f27:	50                   	push   %eax
  801f28:	68 2c 2f 80 00       	push   $0x802f2c
  801f2d:	e8 f7 ec ff ff       	call   800c29 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801f32:	83 c4 10             	add    $0x10,%esp
  801f35:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801f3a:	eb 1d                	jmp    801f59 <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  801f3c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801f3f:	8b 52 18             	mov    0x18(%edx),%edx
  801f42:	85 d2                	test   %edx,%edx
  801f44:	74 0e                	je     801f54 <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801f46:	83 ec 08             	sub    $0x8,%esp
  801f49:	ff 75 0c             	pushl  0xc(%ebp)
  801f4c:	50                   	push   %eax
  801f4d:	ff d2                	call   *%edx
  801f4f:	83 c4 10             	add    $0x10,%esp
  801f52:	eb 05                	jmp    801f59 <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801f54:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801f59:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f5c:	c9                   	leave  
  801f5d:	c3                   	ret    

00801f5e <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801f5e:	55                   	push   %ebp
  801f5f:	89 e5                	mov    %esp,%ebp
  801f61:	53                   	push   %ebx
  801f62:	83 ec 14             	sub    $0x14,%esp
  801f65:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801f68:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801f6b:	50                   	push   %eax
  801f6c:	ff 75 08             	pushl  0x8(%ebp)
  801f6f:	e8 63 fb ff ff       	call   801ad7 <fd_lookup>
  801f74:	83 c4 08             	add    $0x8,%esp
  801f77:	85 c0                	test   %eax,%eax
  801f79:	78 52                	js     801fcd <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801f7b:	83 ec 08             	sub    $0x8,%esp
  801f7e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f81:	50                   	push   %eax
  801f82:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f85:	ff 30                	pushl  (%eax)
  801f87:	e8 a2 fb ff ff       	call   801b2e <dev_lookup>
  801f8c:	83 c4 10             	add    $0x10,%esp
  801f8f:	85 c0                	test   %eax,%eax
  801f91:	78 3a                	js     801fcd <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  801f93:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f96:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801f9a:	74 2c                	je     801fc8 <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801f9c:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801f9f:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801fa6:	00 00 00 
	stat->st_isdir = 0;
  801fa9:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801fb0:	00 00 00 
	stat->st_dev = dev;
  801fb3:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801fb9:	83 ec 08             	sub    $0x8,%esp
  801fbc:	53                   	push   %ebx
  801fbd:	ff 75 f0             	pushl  -0x10(%ebp)
  801fc0:	ff 50 14             	call   *0x14(%eax)
  801fc3:	83 c4 10             	add    $0x10,%esp
  801fc6:	eb 05                	jmp    801fcd <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801fc8:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801fcd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801fd0:	c9                   	leave  
  801fd1:	c3                   	ret    

00801fd2 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801fd2:	55                   	push   %ebp
  801fd3:	89 e5                	mov    %esp,%ebp
  801fd5:	56                   	push   %esi
  801fd6:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801fd7:	83 ec 08             	sub    $0x8,%esp
  801fda:	6a 00                	push   $0x0
  801fdc:	ff 75 08             	pushl  0x8(%ebp)
  801fdf:	e8 75 01 00 00       	call   802159 <open>
  801fe4:	89 c3                	mov    %eax,%ebx
  801fe6:	83 c4 10             	add    $0x10,%esp
  801fe9:	85 c0                	test   %eax,%eax
  801feb:	78 1d                	js     80200a <stat+0x38>
		return fd;
	r = fstat(fd, stat);
  801fed:	83 ec 08             	sub    $0x8,%esp
  801ff0:	ff 75 0c             	pushl  0xc(%ebp)
  801ff3:	50                   	push   %eax
  801ff4:	e8 65 ff ff ff       	call   801f5e <fstat>
  801ff9:	89 c6                	mov    %eax,%esi
	close(fd);
  801ffb:	89 1c 24             	mov    %ebx,(%esp)
  801ffe:	e8 1d fc ff ff       	call   801c20 <close>
	return r;
  802003:	83 c4 10             	add    $0x10,%esp
  802006:	89 f0                	mov    %esi,%eax
  802008:	eb 00                	jmp    80200a <stat+0x38>
}
  80200a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80200d:	5b                   	pop    %ebx
  80200e:	5e                   	pop    %esi
  80200f:	5d                   	pop    %ebp
  802010:	c3                   	ret    

00802011 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  802011:	55                   	push   %ebp
  802012:	89 e5                	mov    %esp,%ebp
  802014:	56                   	push   %esi
  802015:	53                   	push   %ebx
  802016:	89 c6                	mov    %eax,%esi
  802018:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80201a:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  802021:	75 12                	jne    802035 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  802023:	83 ec 0c             	sub    $0xc,%esp
  802026:	6a 01                	push   $0x1
  802028:	e8 b4 f9 ff ff       	call   8019e1 <ipc_find_env>
  80202d:	a3 00 80 80 00       	mov    %eax,0x808000
  802032:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  802035:	6a 07                	push   $0x7
  802037:	68 00 90 80 00       	push   $0x809000
  80203c:	56                   	push   %esi
  80203d:	ff 35 00 80 80 00    	pushl  0x808000
  802043:	e8 3a f9 ff ff       	call   801982 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  802048:	83 c4 0c             	add    $0xc,%esp
  80204b:	6a 00                	push   $0x0
  80204d:	53                   	push   %ebx
  80204e:	6a 00                	push   $0x0
  802050:	e8 b8 f8 ff ff       	call   80190d <ipc_recv>
}
  802055:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802058:	5b                   	pop    %ebx
  802059:	5e                   	pop    %esi
  80205a:	5d                   	pop    %ebp
  80205b:	c3                   	ret    

0080205c <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80205c:	55                   	push   %ebp
  80205d:	89 e5                	mov    %esp,%ebp
  80205f:	53                   	push   %ebx
  802060:	83 ec 04             	sub    $0x4,%esp
  802063:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  802066:	8b 45 08             	mov    0x8(%ebp),%eax
  802069:	8b 40 0c             	mov    0xc(%eax),%eax
  80206c:	a3 00 90 80 00       	mov    %eax,0x809000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  802071:	ba 00 00 00 00       	mov    $0x0,%edx
  802076:	b8 05 00 00 00       	mov    $0x5,%eax
  80207b:	e8 91 ff ff ff       	call   802011 <fsipc>
  802080:	85 c0                	test   %eax,%eax
  802082:	78 2c                	js     8020b0 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  802084:	83 ec 08             	sub    $0x8,%esp
  802087:	68 00 90 80 00       	push   $0x809000
  80208c:	53                   	push   %ebx
  80208d:	e8 7c f1 ff ff       	call   80120e <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  802092:	a1 80 90 80 00       	mov    0x809080,%eax
  802097:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80209d:	a1 84 90 80 00       	mov    0x809084,%eax
  8020a2:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8020a8:	83 c4 10             	add    $0x10,%esp
  8020ab:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8020b0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8020b3:	c9                   	leave  
  8020b4:	c3                   	ret    

008020b5 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8020b5:	55                   	push   %ebp
  8020b6:	89 e5                	mov    %esp,%ebp
  8020b8:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8020bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8020be:	8b 40 0c             	mov    0xc(%eax),%eax
  8020c1:	a3 00 90 80 00       	mov    %eax,0x809000
	return fsipc(FSREQ_FLUSH, NULL);
  8020c6:	ba 00 00 00 00       	mov    $0x0,%edx
  8020cb:	b8 06 00 00 00       	mov    $0x6,%eax
  8020d0:	e8 3c ff ff ff       	call   802011 <fsipc>
}
  8020d5:	c9                   	leave  
  8020d6:	c3                   	ret    

008020d7 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8020d7:	55                   	push   %ebp
  8020d8:	89 e5                	mov    %esp,%ebp
  8020da:	56                   	push   %esi
  8020db:	53                   	push   %ebx
  8020dc:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8020df:	8b 45 08             	mov    0x8(%ebp),%eax
  8020e2:	8b 40 0c             	mov    0xc(%eax),%eax
  8020e5:	a3 00 90 80 00       	mov    %eax,0x809000
	fsipcbuf.read.req_n = n;
  8020ea:	89 35 04 90 80 00    	mov    %esi,0x809004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8020f0:	ba 00 00 00 00       	mov    $0x0,%edx
  8020f5:	b8 03 00 00 00       	mov    $0x3,%eax
  8020fa:	e8 12 ff ff ff       	call   802011 <fsipc>
  8020ff:	89 c3                	mov    %eax,%ebx
  802101:	85 c0                	test   %eax,%eax
  802103:	78 4b                	js     802150 <devfile_read+0x79>
		return r;
	assert(r <= n);
  802105:	39 c6                	cmp    %eax,%esi
  802107:	73 16                	jae    80211f <devfile_read+0x48>
  802109:	68 89 2f 80 00       	push   $0x802f89
  80210e:	68 bd 29 80 00       	push   $0x8029bd
  802113:	6a 7a                	push   $0x7a
  802115:	68 90 2f 80 00       	push   $0x802f90
  80211a:	e8 32 ea ff ff       	call   800b51 <_panic>
	assert(r <= PGSIZE);
  80211f:	3d 00 10 00 00       	cmp    $0x1000,%eax
  802124:	7e 16                	jle    80213c <devfile_read+0x65>
  802126:	68 9b 2f 80 00       	push   $0x802f9b
  80212b:	68 bd 29 80 00       	push   $0x8029bd
  802130:	6a 7b                	push   $0x7b
  802132:	68 90 2f 80 00       	push   $0x802f90
  802137:	e8 15 ea ff ff       	call   800b51 <_panic>
	memmove(buf, &fsipcbuf, r);
  80213c:	83 ec 04             	sub    $0x4,%esp
  80213f:	50                   	push   %eax
  802140:	68 00 90 80 00       	push   $0x809000
  802145:	ff 75 0c             	pushl  0xc(%ebp)
  802148:	e8 8e f2 ff ff       	call   8013db <memmove>
	return r;
  80214d:	83 c4 10             	add    $0x10,%esp
}
  802150:	89 d8                	mov    %ebx,%eax
  802152:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802155:	5b                   	pop    %ebx
  802156:	5e                   	pop    %esi
  802157:	5d                   	pop    %ebp
  802158:	c3                   	ret    

00802159 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  802159:	55                   	push   %ebp
  80215a:	89 e5                	mov    %esp,%ebp
  80215c:	53                   	push   %ebx
  80215d:	83 ec 20             	sub    $0x20,%esp
  802160:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  802163:	53                   	push   %ebx
  802164:	e8 4e f0 ff ff       	call   8011b7 <strlen>
  802169:	83 c4 10             	add    $0x10,%esp
  80216c:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  802171:	7f 63                	jg     8021d6 <open+0x7d>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  802173:	83 ec 0c             	sub    $0xc,%esp
  802176:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802179:	50                   	push   %eax
  80217a:	e8 e4 f8 ff ff       	call   801a63 <fd_alloc>
  80217f:	83 c4 10             	add    $0x10,%esp
  802182:	85 c0                	test   %eax,%eax
  802184:	78 55                	js     8021db <open+0x82>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  802186:	83 ec 08             	sub    $0x8,%esp
  802189:	53                   	push   %ebx
  80218a:	68 00 90 80 00       	push   $0x809000
  80218f:	e8 7a f0 ff ff       	call   80120e <strcpy>
	fsipcbuf.open.req_omode = mode;
  802194:	8b 45 0c             	mov    0xc(%ebp),%eax
  802197:	a3 00 94 80 00       	mov    %eax,0x809400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80219c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80219f:	b8 01 00 00 00       	mov    $0x1,%eax
  8021a4:	e8 68 fe ff ff       	call   802011 <fsipc>
  8021a9:	89 c3                	mov    %eax,%ebx
  8021ab:	83 c4 10             	add    $0x10,%esp
  8021ae:	85 c0                	test   %eax,%eax
  8021b0:	79 14                	jns    8021c6 <open+0x6d>
		fd_close(fd, 0);
  8021b2:	83 ec 08             	sub    $0x8,%esp
  8021b5:	6a 00                	push   $0x0
  8021b7:	ff 75 f4             	pushl  -0xc(%ebp)
  8021ba:	e8 dd f9 ff ff       	call   801b9c <fd_close>
		return r;
  8021bf:	83 c4 10             	add    $0x10,%esp
  8021c2:	89 d8                	mov    %ebx,%eax
  8021c4:	eb 15                	jmp    8021db <open+0x82>
	}

	return fd2num(fd);
  8021c6:	83 ec 0c             	sub    $0xc,%esp
  8021c9:	ff 75 f4             	pushl  -0xc(%ebp)
  8021cc:	e8 6b f8 ff ff       	call   801a3c <fd2num>
  8021d1:	83 c4 10             	add    $0x10,%esp
  8021d4:	eb 05                	jmp    8021db <open+0x82>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8021d6:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8021db:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8021de:	c9                   	leave  
  8021df:	c3                   	ret    

008021e0 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8021e0:	55                   	push   %ebp
  8021e1:	89 e5                	mov    %esp,%ebp
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8021e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8021e6:	c1 e8 16             	shr    $0x16,%eax
  8021e9:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8021f0:	a8 01                	test   $0x1,%al
  8021f2:	74 21                	je     802215 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  8021f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8021f7:	c1 e8 0c             	shr    $0xc,%eax
  8021fa:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802201:	a8 01                	test   $0x1,%al
  802203:	74 17                	je     80221c <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802205:	c1 e8 0c             	shr    $0xc,%eax
  802208:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  80220f:	ef 
  802210:	0f b7 c0             	movzwl %ax,%eax
  802213:	eb 0c                	jmp    802221 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  802215:	b8 00 00 00 00       	mov    $0x0,%eax
  80221a:	eb 05                	jmp    802221 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  80221c:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  802221:	5d                   	pop    %ebp
  802222:	c3                   	ret    

00802223 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802223:	55                   	push   %ebp
  802224:	89 e5                	mov    %esp,%ebp
  802226:	56                   	push   %esi
  802227:	53                   	push   %ebx
  802228:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80222b:	83 ec 0c             	sub    $0xc,%esp
  80222e:	ff 75 08             	pushl  0x8(%ebp)
  802231:	e8 16 f8 ff ff       	call   801a4c <fd2data>
  802236:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  802238:	83 c4 08             	add    $0x8,%esp
  80223b:	68 a7 2f 80 00       	push   $0x802fa7
  802240:	53                   	push   %ebx
  802241:	e8 c8 ef ff ff       	call   80120e <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802246:	8b 46 04             	mov    0x4(%esi),%eax
  802249:	2b 06                	sub    (%esi),%eax
  80224b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  802251:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802258:	00 00 00 
	stat->st_dev = &devpipe;
  80225b:	c7 83 88 00 00 00 60 	movl   $0x807060,0x88(%ebx)
  802262:	70 80 00 
	return 0;
}
  802265:	b8 00 00 00 00       	mov    $0x0,%eax
  80226a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80226d:	5b                   	pop    %ebx
  80226e:	5e                   	pop    %esi
  80226f:	5d                   	pop    %ebp
  802270:	c3                   	ret    

00802271 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  802271:	55                   	push   %ebp
  802272:	89 e5                	mov    %esp,%ebp
  802274:	53                   	push   %ebx
  802275:	83 ec 0c             	sub    $0xc,%esp
  802278:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80227b:	53                   	push   %ebx
  80227c:	6a 00                	push   $0x0
  80227e:	e8 80 f4 ff ff       	call   801703 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802283:	89 1c 24             	mov    %ebx,(%esp)
  802286:	e8 c1 f7 ff ff       	call   801a4c <fd2data>
  80228b:	83 c4 08             	add    $0x8,%esp
  80228e:	50                   	push   %eax
  80228f:	6a 00                	push   $0x0
  802291:	e8 6d f4 ff ff       	call   801703 <sys_page_unmap>
}
  802296:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802299:	c9                   	leave  
  80229a:	c3                   	ret    

0080229b <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80229b:	55                   	push   %ebp
  80229c:	89 e5                	mov    %esp,%ebp
  80229e:	57                   	push   %edi
  80229f:	56                   	push   %esi
  8022a0:	53                   	push   %ebx
  8022a1:	83 ec 1c             	sub    $0x1c,%esp
  8022a4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8022a7:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8022a9:	a1 0c 80 80 00       	mov    0x80800c,%eax
  8022ae:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8022b1:	83 ec 0c             	sub    $0xc,%esp
  8022b4:	ff 75 e0             	pushl  -0x20(%ebp)
  8022b7:	e8 24 ff ff ff       	call   8021e0 <pageref>
  8022bc:	89 c3                	mov    %eax,%ebx
  8022be:	89 3c 24             	mov    %edi,(%esp)
  8022c1:	e8 1a ff ff ff       	call   8021e0 <pageref>
  8022c6:	83 c4 10             	add    $0x10,%esp
  8022c9:	39 c3                	cmp    %eax,%ebx
  8022cb:	0f 94 c1             	sete   %cl
  8022ce:	0f b6 c9             	movzbl %cl,%ecx
  8022d1:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8022d4:	8b 15 0c 80 80 00    	mov    0x80800c,%edx
  8022da:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8022dd:	39 ce                	cmp    %ecx,%esi
  8022df:	74 1b                	je     8022fc <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8022e1:	39 c3                	cmp    %eax,%ebx
  8022e3:	75 c4                	jne    8022a9 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8022e5:	8b 42 58             	mov    0x58(%edx),%eax
  8022e8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8022eb:	50                   	push   %eax
  8022ec:	56                   	push   %esi
  8022ed:	68 ae 2f 80 00       	push   $0x802fae
  8022f2:	e8 32 e9 ff ff       	call   800c29 <cprintf>
  8022f7:	83 c4 10             	add    $0x10,%esp
  8022fa:	eb ad                	jmp    8022a9 <_pipeisclosed+0xe>
	}
}
  8022fc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8022ff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802302:	5b                   	pop    %ebx
  802303:	5e                   	pop    %esi
  802304:	5f                   	pop    %edi
  802305:	5d                   	pop    %ebp
  802306:	c3                   	ret    

00802307 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802307:	55                   	push   %ebp
  802308:	89 e5                	mov    %esp,%ebp
  80230a:	57                   	push   %edi
  80230b:	56                   	push   %esi
  80230c:	53                   	push   %ebx
  80230d:	83 ec 18             	sub    $0x18,%esp
  802310:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802313:	56                   	push   %esi
  802314:	e8 33 f7 ff ff       	call   801a4c <fd2data>
  802319:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80231b:	83 c4 10             	add    $0x10,%esp
  80231e:	bf 00 00 00 00       	mov    $0x0,%edi
  802323:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802327:	75 42                	jne    80236b <devpipe_write+0x64>
  802329:	eb 4e                	jmp    802379 <devpipe_write+0x72>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80232b:	89 da                	mov    %ebx,%edx
  80232d:	89 f0                	mov    %esi,%eax
  80232f:	e8 67 ff ff ff       	call   80229b <_pipeisclosed>
  802334:	85 c0                	test   %eax,%eax
  802336:	75 46                	jne    80237e <devpipe_write+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802338:	e8 22 f3 ff ff       	call   80165f <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80233d:	8b 53 04             	mov    0x4(%ebx),%edx
  802340:	8b 03                	mov    (%ebx),%eax
  802342:	83 c0 20             	add    $0x20,%eax
  802345:	39 c2                	cmp    %eax,%edx
  802347:	73 e2                	jae    80232b <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802349:	8b 45 0c             	mov    0xc(%ebp),%eax
  80234c:	8a 0c 38             	mov    (%eax,%edi,1),%cl
  80234f:	89 d0                	mov    %edx,%eax
  802351:	25 1f 00 00 80       	and    $0x8000001f,%eax
  802356:	79 05                	jns    80235d <devpipe_write+0x56>
  802358:	48                   	dec    %eax
  802359:	83 c8 e0             	or     $0xffffffe0,%eax
  80235c:	40                   	inc    %eax
  80235d:	88 4c 03 08          	mov    %cl,0x8(%ebx,%eax,1)
		p->p_wpos++;
  802361:	42                   	inc    %edx
  802362:	89 53 04             	mov    %edx,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802365:	47                   	inc    %edi
  802366:	39 7d 10             	cmp    %edi,0x10(%ebp)
  802369:	74 0e                	je     802379 <devpipe_write+0x72>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80236b:	8b 53 04             	mov    0x4(%ebx),%edx
  80236e:	8b 03                	mov    (%ebx),%eax
  802370:	83 c0 20             	add    $0x20,%eax
  802373:	39 c2                	cmp    %eax,%edx
  802375:	73 b4                	jae    80232b <devpipe_write+0x24>
  802377:	eb d0                	jmp    802349 <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802379:	8b 45 10             	mov    0x10(%ebp),%eax
  80237c:	eb 05                	jmp    802383 <devpipe_write+0x7c>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80237e:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802383:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802386:	5b                   	pop    %ebx
  802387:	5e                   	pop    %esi
  802388:	5f                   	pop    %edi
  802389:	5d                   	pop    %ebp
  80238a:	c3                   	ret    

0080238b <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80238b:	55                   	push   %ebp
  80238c:	89 e5                	mov    %esp,%ebp
  80238e:	57                   	push   %edi
  80238f:	56                   	push   %esi
  802390:	53                   	push   %ebx
  802391:	83 ec 18             	sub    $0x18,%esp
  802394:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802397:	57                   	push   %edi
  802398:	e8 af f6 ff ff       	call   801a4c <fd2data>
  80239d:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80239f:	83 c4 10             	add    $0x10,%esp
  8023a2:	be 00 00 00 00       	mov    $0x0,%esi
  8023a7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8023ab:	75 3d                	jne    8023ea <devpipe_read+0x5f>
  8023ad:	eb 48                	jmp    8023f7 <devpipe_read+0x6c>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  8023af:	89 f0                	mov    %esi,%eax
  8023b1:	eb 4e                	jmp    802401 <devpipe_read+0x76>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8023b3:	89 da                	mov    %ebx,%edx
  8023b5:	89 f8                	mov    %edi,%eax
  8023b7:	e8 df fe ff ff       	call   80229b <_pipeisclosed>
  8023bc:	85 c0                	test   %eax,%eax
  8023be:	75 3c                	jne    8023fc <devpipe_read+0x71>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8023c0:	e8 9a f2 ff ff       	call   80165f <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8023c5:	8b 03                	mov    (%ebx),%eax
  8023c7:	3b 43 04             	cmp    0x4(%ebx),%eax
  8023ca:	74 e7                	je     8023b3 <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8023cc:	25 1f 00 00 80       	and    $0x8000001f,%eax
  8023d1:	79 05                	jns    8023d8 <devpipe_read+0x4d>
  8023d3:	48                   	dec    %eax
  8023d4:	83 c8 e0             	or     $0xffffffe0,%eax
  8023d7:	40                   	inc    %eax
  8023d8:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  8023dc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8023df:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  8023e2:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8023e4:	46                   	inc    %esi
  8023e5:	39 75 10             	cmp    %esi,0x10(%ebp)
  8023e8:	74 0d                	je     8023f7 <devpipe_read+0x6c>
		while (p->p_rpos == p->p_wpos) {
  8023ea:	8b 03                	mov    (%ebx),%eax
  8023ec:	3b 43 04             	cmp    0x4(%ebx),%eax
  8023ef:	75 db                	jne    8023cc <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8023f1:	85 f6                	test   %esi,%esi
  8023f3:	75 ba                	jne    8023af <devpipe_read+0x24>
  8023f5:	eb bc                	jmp    8023b3 <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8023f7:	8b 45 10             	mov    0x10(%ebp),%eax
  8023fa:	eb 05                	jmp    802401 <devpipe_read+0x76>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8023fc:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802401:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802404:	5b                   	pop    %ebx
  802405:	5e                   	pop    %esi
  802406:	5f                   	pop    %edi
  802407:	5d                   	pop    %ebp
  802408:	c3                   	ret    

00802409 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802409:	55                   	push   %ebp
  80240a:	89 e5                	mov    %esp,%ebp
  80240c:	56                   	push   %esi
  80240d:	53                   	push   %ebx
  80240e:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802411:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802414:	50                   	push   %eax
  802415:	e8 49 f6 ff ff       	call   801a63 <fd_alloc>
  80241a:	83 c4 10             	add    $0x10,%esp
  80241d:	85 c0                	test   %eax,%eax
  80241f:	0f 88 2a 01 00 00    	js     80254f <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802425:	83 ec 04             	sub    $0x4,%esp
  802428:	68 07 04 00 00       	push   $0x407
  80242d:	ff 75 f4             	pushl  -0xc(%ebp)
  802430:	6a 00                	push   $0x0
  802432:	e8 47 f2 ff ff       	call   80167e <sys_page_alloc>
  802437:	83 c4 10             	add    $0x10,%esp
  80243a:	85 c0                	test   %eax,%eax
  80243c:	0f 88 0d 01 00 00    	js     80254f <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802442:	83 ec 0c             	sub    $0xc,%esp
  802445:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802448:	50                   	push   %eax
  802449:	e8 15 f6 ff ff       	call   801a63 <fd_alloc>
  80244e:	89 c3                	mov    %eax,%ebx
  802450:	83 c4 10             	add    $0x10,%esp
  802453:	85 c0                	test   %eax,%eax
  802455:	0f 88 e2 00 00 00    	js     80253d <pipe+0x134>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80245b:	83 ec 04             	sub    $0x4,%esp
  80245e:	68 07 04 00 00       	push   $0x407
  802463:	ff 75 f0             	pushl  -0x10(%ebp)
  802466:	6a 00                	push   $0x0
  802468:	e8 11 f2 ff ff       	call   80167e <sys_page_alloc>
  80246d:	89 c3                	mov    %eax,%ebx
  80246f:	83 c4 10             	add    $0x10,%esp
  802472:	85 c0                	test   %eax,%eax
  802474:	0f 88 c3 00 00 00    	js     80253d <pipe+0x134>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80247a:	83 ec 0c             	sub    $0xc,%esp
  80247d:	ff 75 f4             	pushl  -0xc(%ebp)
  802480:	e8 c7 f5 ff ff       	call   801a4c <fd2data>
  802485:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802487:	83 c4 0c             	add    $0xc,%esp
  80248a:	68 07 04 00 00       	push   $0x407
  80248f:	50                   	push   %eax
  802490:	6a 00                	push   $0x0
  802492:	e8 e7 f1 ff ff       	call   80167e <sys_page_alloc>
  802497:	89 c3                	mov    %eax,%ebx
  802499:	83 c4 10             	add    $0x10,%esp
  80249c:	85 c0                	test   %eax,%eax
  80249e:	0f 88 89 00 00 00    	js     80252d <pipe+0x124>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8024a4:	83 ec 0c             	sub    $0xc,%esp
  8024a7:	ff 75 f0             	pushl  -0x10(%ebp)
  8024aa:	e8 9d f5 ff ff       	call   801a4c <fd2data>
  8024af:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8024b6:	50                   	push   %eax
  8024b7:	6a 00                	push   $0x0
  8024b9:	56                   	push   %esi
  8024ba:	6a 00                	push   $0x0
  8024bc:	e8 00 f2 ff ff       	call   8016c1 <sys_page_map>
  8024c1:	89 c3                	mov    %eax,%ebx
  8024c3:	83 c4 20             	add    $0x20,%esp
  8024c6:	85 c0                	test   %eax,%eax
  8024c8:	78 55                	js     80251f <pipe+0x116>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8024ca:	8b 15 60 70 80 00    	mov    0x807060,%edx
  8024d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024d3:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8024d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024d8:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8024df:	8b 15 60 70 80 00    	mov    0x807060,%edx
  8024e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8024e8:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8024ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8024ed:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8024f4:	83 ec 0c             	sub    $0xc,%esp
  8024f7:	ff 75 f4             	pushl  -0xc(%ebp)
  8024fa:	e8 3d f5 ff ff       	call   801a3c <fd2num>
  8024ff:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802502:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802504:	83 c4 04             	add    $0x4,%esp
  802507:	ff 75 f0             	pushl  -0x10(%ebp)
  80250a:	e8 2d f5 ff ff       	call   801a3c <fd2num>
  80250f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802512:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802515:	83 c4 10             	add    $0x10,%esp
  802518:	b8 00 00 00 00       	mov    $0x0,%eax
  80251d:	eb 30                	jmp    80254f <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  80251f:	83 ec 08             	sub    $0x8,%esp
  802522:	56                   	push   %esi
  802523:	6a 00                	push   $0x0
  802525:	e8 d9 f1 ff ff       	call   801703 <sys_page_unmap>
  80252a:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80252d:	83 ec 08             	sub    $0x8,%esp
  802530:	ff 75 f0             	pushl  -0x10(%ebp)
  802533:	6a 00                	push   $0x0
  802535:	e8 c9 f1 ff ff       	call   801703 <sys_page_unmap>
  80253a:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80253d:	83 ec 08             	sub    $0x8,%esp
  802540:	ff 75 f4             	pushl  -0xc(%ebp)
  802543:	6a 00                	push   $0x0
  802545:	e8 b9 f1 ff ff       	call   801703 <sys_page_unmap>
  80254a:	83 c4 10             	add    $0x10,%esp
  80254d:	89 d8                	mov    %ebx,%eax
    err:
	return r;
}
  80254f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802552:	5b                   	pop    %ebx
  802553:	5e                   	pop    %esi
  802554:	5d                   	pop    %ebp
  802555:	c3                   	ret    

00802556 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802556:	55                   	push   %ebp
  802557:	89 e5                	mov    %esp,%ebp
  802559:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80255c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80255f:	50                   	push   %eax
  802560:	ff 75 08             	pushl  0x8(%ebp)
  802563:	e8 6f f5 ff ff       	call   801ad7 <fd_lookup>
  802568:	83 c4 10             	add    $0x10,%esp
  80256b:	85 c0                	test   %eax,%eax
  80256d:	78 18                	js     802587 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80256f:	83 ec 0c             	sub    $0xc,%esp
  802572:	ff 75 f4             	pushl  -0xc(%ebp)
  802575:	e8 d2 f4 ff ff       	call   801a4c <fd2data>
	return _pipeisclosed(fd, p);
  80257a:	89 c2                	mov    %eax,%edx
  80257c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80257f:	e8 17 fd ff ff       	call   80229b <_pipeisclosed>
  802584:	83 c4 10             	add    $0x10,%esp
}
  802587:	c9                   	leave  
  802588:	c3                   	ret    

00802589 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802589:	55                   	push   %ebp
  80258a:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80258c:	b8 00 00 00 00       	mov    $0x0,%eax
  802591:	5d                   	pop    %ebp
  802592:	c3                   	ret    

00802593 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802593:	55                   	push   %ebp
  802594:	89 e5                	mov    %esp,%ebp
  802596:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802599:	68 c6 2f 80 00       	push   $0x802fc6
  80259e:	ff 75 0c             	pushl  0xc(%ebp)
  8025a1:	e8 68 ec ff ff       	call   80120e <strcpy>
	return 0;
}
  8025a6:	b8 00 00 00 00       	mov    $0x0,%eax
  8025ab:	c9                   	leave  
  8025ac:	c3                   	ret    

008025ad <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8025ad:	55                   	push   %ebp
  8025ae:	89 e5                	mov    %esp,%ebp
  8025b0:	57                   	push   %edi
  8025b1:	56                   	push   %esi
  8025b2:	53                   	push   %ebx
  8025b3:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8025b9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8025bd:	74 45                	je     802604 <devcons_write+0x57>
  8025bf:	b8 00 00 00 00       	mov    $0x0,%eax
  8025c4:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8025c9:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8025cf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8025d2:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  8025d4:	83 fb 7f             	cmp    $0x7f,%ebx
  8025d7:	76 05                	jbe    8025de <devcons_write+0x31>
			m = sizeof(buf) - 1;
  8025d9:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  8025de:	83 ec 04             	sub    $0x4,%esp
  8025e1:	53                   	push   %ebx
  8025e2:	03 45 0c             	add    0xc(%ebp),%eax
  8025e5:	50                   	push   %eax
  8025e6:	57                   	push   %edi
  8025e7:	e8 ef ed ff ff       	call   8013db <memmove>
		sys_cputs(buf, m);
  8025ec:	83 c4 08             	add    $0x8,%esp
  8025ef:	53                   	push   %ebx
  8025f0:	57                   	push   %edi
  8025f1:	e8 cc ef ff ff       	call   8015c2 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8025f6:	01 de                	add    %ebx,%esi
  8025f8:	89 f0                	mov    %esi,%eax
  8025fa:	83 c4 10             	add    $0x10,%esp
  8025fd:	3b 75 10             	cmp    0x10(%ebp),%esi
  802600:	72 cd                	jb     8025cf <devcons_write+0x22>
  802602:	eb 05                	jmp    802609 <devcons_write+0x5c>
  802604:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802609:	89 f0                	mov    %esi,%eax
  80260b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80260e:	5b                   	pop    %ebx
  80260f:	5e                   	pop    %esi
  802610:	5f                   	pop    %edi
  802611:	5d                   	pop    %ebp
  802612:	c3                   	ret    

00802613 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802613:	55                   	push   %ebp
  802614:	89 e5                	mov    %esp,%ebp
  802616:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  802619:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80261d:	75 07                	jne    802626 <devcons_read+0x13>
  80261f:	eb 23                	jmp    802644 <devcons_read+0x31>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802621:	e8 39 f0 ff ff       	call   80165f <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802626:	e8 b5 ef ff ff       	call   8015e0 <sys_cgetc>
  80262b:	85 c0                	test   %eax,%eax
  80262d:	74 f2                	je     802621 <devcons_read+0xe>
		sys_yield();
	if (c < 0)
  80262f:	85 c0                	test   %eax,%eax
  802631:	78 1d                	js     802650 <devcons_read+0x3d>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802633:	83 f8 04             	cmp    $0x4,%eax
  802636:	74 13                	je     80264b <devcons_read+0x38>
		return 0;
	*(char*)vbuf = c;
  802638:	8b 55 0c             	mov    0xc(%ebp),%edx
  80263b:	88 02                	mov    %al,(%edx)
	return 1;
  80263d:	b8 01 00 00 00       	mov    $0x1,%eax
  802642:	eb 0c                	jmp    802650 <devcons_read+0x3d>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  802644:	b8 00 00 00 00       	mov    $0x0,%eax
  802649:	eb 05                	jmp    802650 <devcons_read+0x3d>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80264b:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802650:	c9                   	leave  
  802651:	c3                   	ret    

00802652 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802652:	55                   	push   %ebp
  802653:	89 e5                	mov    %esp,%ebp
  802655:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802658:	8b 45 08             	mov    0x8(%ebp),%eax
  80265b:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80265e:	6a 01                	push   $0x1
  802660:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802663:	50                   	push   %eax
  802664:	e8 59 ef ff ff       	call   8015c2 <sys_cputs>
}
  802669:	83 c4 10             	add    $0x10,%esp
  80266c:	c9                   	leave  
  80266d:	c3                   	ret    

0080266e <getchar>:

int
getchar(void)
{
  80266e:	55                   	push   %ebp
  80266f:	89 e5                	mov    %esp,%ebp
  802671:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802674:	6a 01                	push   $0x1
  802676:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802679:	50                   	push   %eax
  80267a:	6a 00                	push   $0x0
  80267c:	e8 d7 f6 ff ff       	call   801d58 <read>
	if (r < 0)
  802681:	83 c4 10             	add    $0x10,%esp
  802684:	85 c0                	test   %eax,%eax
  802686:	78 0f                	js     802697 <getchar+0x29>
		return r;
	if (r < 1)
  802688:	85 c0                	test   %eax,%eax
  80268a:	7e 06                	jle    802692 <getchar+0x24>
		return -E_EOF;
	return c;
  80268c:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802690:	eb 05                	jmp    802697 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802692:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802697:	c9                   	leave  
  802698:	c3                   	ret    

00802699 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802699:	55                   	push   %ebp
  80269a:	89 e5                	mov    %esp,%ebp
  80269c:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80269f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8026a2:	50                   	push   %eax
  8026a3:	ff 75 08             	pushl  0x8(%ebp)
  8026a6:	e8 2c f4 ff ff       	call   801ad7 <fd_lookup>
  8026ab:	83 c4 10             	add    $0x10,%esp
  8026ae:	85 c0                	test   %eax,%eax
  8026b0:	78 11                	js     8026c3 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8026b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8026b5:	8b 15 7c 70 80 00    	mov    0x80707c,%edx
  8026bb:	39 10                	cmp    %edx,(%eax)
  8026bd:	0f 94 c0             	sete   %al
  8026c0:	0f b6 c0             	movzbl %al,%eax
}
  8026c3:	c9                   	leave  
  8026c4:	c3                   	ret    

008026c5 <opencons>:

int
opencons(void)
{
  8026c5:	55                   	push   %ebp
  8026c6:	89 e5                	mov    %esp,%ebp
  8026c8:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8026cb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8026ce:	50                   	push   %eax
  8026cf:	e8 8f f3 ff ff       	call   801a63 <fd_alloc>
  8026d4:	83 c4 10             	add    $0x10,%esp
  8026d7:	85 c0                	test   %eax,%eax
  8026d9:	78 3a                	js     802715 <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8026db:	83 ec 04             	sub    $0x4,%esp
  8026de:	68 07 04 00 00       	push   $0x407
  8026e3:	ff 75 f4             	pushl  -0xc(%ebp)
  8026e6:	6a 00                	push   $0x0
  8026e8:	e8 91 ef ff ff       	call   80167e <sys_page_alloc>
  8026ed:	83 c4 10             	add    $0x10,%esp
  8026f0:	85 c0                	test   %eax,%eax
  8026f2:	78 21                	js     802715 <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8026f4:	8b 15 7c 70 80 00    	mov    0x80707c,%edx
  8026fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8026fd:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8026ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802702:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802709:	83 ec 0c             	sub    $0xc,%esp
  80270c:	50                   	push   %eax
  80270d:	e8 2a f3 ff ff       	call   801a3c <fd2num>
  802712:	83 c4 10             	add    $0x10,%esp
}
  802715:	c9                   	leave  
  802716:	c3                   	ret    
  802717:	90                   	nop

00802718 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  802718:	55                   	push   %ebp
  802719:	57                   	push   %edi
  80271a:	56                   	push   %esi
  80271b:	53                   	push   %ebx
  80271c:	83 ec 1c             	sub    $0x1c,%esp
  80271f:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  802723:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802727:	8b 7c 24 38          	mov    0x38(%esp),%edi
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  80272b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80272f:	89 ca                	mov    %ecx,%edx
  const DWunion dd = {.ll = d};
  802731:	89 f8                	mov    %edi,%eax
  802733:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802737:	85 f6                	test   %esi,%esi
  802739:	75 2d                	jne    802768 <__udivdi3+0x50>
    {
      if (d0 > n1)
  80273b:	39 cf                	cmp    %ecx,%edi
  80273d:	77 65                	ja     8027a4 <__udivdi3+0x8c>
  80273f:	89 fd                	mov    %edi,%ebp
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802741:	85 ff                	test   %edi,%edi
  802743:	75 0b                	jne    802750 <__udivdi3+0x38>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802745:	b8 01 00 00 00       	mov    $0x1,%eax
  80274a:	31 d2                	xor    %edx,%edx
  80274c:	f7 f7                	div    %edi
  80274e:	89 c5                	mov    %eax,%ebp

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802750:	31 d2                	xor    %edx,%edx
  802752:	89 c8                	mov    %ecx,%eax
  802754:	f7 f5                	div    %ebp
  802756:	89 c1                	mov    %eax,%ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802758:	89 d8                	mov    %ebx,%eax
  80275a:	f7 f5                	div    %ebp
  80275c:	89 cf                	mov    %ecx,%edi
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80275e:	89 fa                	mov    %edi,%edx
  802760:	83 c4 1c             	add    $0x1c,%esp
  802763:	5b                   	pop    %ebx
  802764:	5e                   	pop    %esi
  802765:	5f                   	pop    %edi
  802766:	5d                   	pop    %ebp
  802767:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802768:	39 ce                	cmp    %ecx,%esi
  80276a:	77 28                	ja     802794 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  80276c:	0f bd fe             	bsr    %esi,%edi
	  if (bm == 0)
  80276f:	83 f7 1f             	xor    $0x1f,%edi
  802772:	75 40                	jne    8027b4 <__udivdi3+0x9c>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802774:	39 ce                	cmp    %ecx,%esi
  802776:	72 0a                	jb     802782 <__udivdi3+0x6a>
  802778:	3b 44 24 08          	cmp    0x8(%esp),%eax
  80277c:	0f 87 9e 00 00 00    	ja     802820 <__udivdi3+0x108>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802782:	b8 01 00 00 00       	mov    $0x1,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802787:	89 fa                	mov    %edi,%edx
  802789:	83 c4 1c             	add    $0x1c,%esp
  80278c:	5b                   	pop    %ebx
  80278d:	5e                   	pop    %esi
  80278e:	5f                   	pop    %edi
  80278f:	5d                   	pop    %ebp
  802790:	c3                   	ret    
  802791:	8d 76 00             	lea    0x0(%esi),%esi
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802794:	31 ff                	xor    %edi,%edi
  802796:	31 c0                	xor    %eax,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802798:	89 fa                	mov    %edi,%edx
  80279a:	83 c4 1c             	add    $0x1c,%esp
  80279d:	5b                   	pop    %ebx
  80279e:	5e                   	pop    %esi
  80279f:	5f                   	pop    %edi
  8027a0:	5d                   	pop    %ebp
  8027a1:	c3                   	ret    
  8027a2:	66 90                	xchg   %ax,%ax
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8027a4:	89 d8                	mov    %ebx,%eax
  8027a6:	f7 f7                	div    %edi
  8027a8:	31 ff                	xor    %edi,%edi
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8027aa:	89 fa                	mov    %edi,%edx
  8027ac:	83 c4 1c             	add    $0x1c,%esp
  8027af:	5b                   	pop    %ebx
  8027b0:	5e                   	pop    %esi
  8027b1:	5f                   	pop    %edi
  8027b2:	5d                   	pop    %ebp
  8027b3:	c3                   	ret    
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8027b4:	bd 20 00 00 00       	mov    $0x20,%ebp
  8027b9:	89 eb                	mov    %ebp,%ebx
  8027bb:	29 fb                	sub    %edi,%ebx

	      d1 = (d1 << bm) | (d0 >> b);
  8027bd:	89 f9                	mov    %edi,%ecx
  8027bf:	d3 e6                	shl    %cl,%esi
  8027c1:	89 c5                	mov    %eax,%ebp
  8027c3:	88 d9                	mov    %bl,%cl
  8027c5:	d3 ed                	shr    %cl,%ebp
  8027c7:	89 e9                	mov    %ebp,%ecx
  8027c9:	09 f1                	or     %esi,%ecx
  8027cb:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
	      d0 = d0 << bm;
  8027cf:	89 f9                	mov    %edi,%ecx
  8027d1:	d3 e0                	shl    %cl,%eax
  8027d3:	89 c5                	mov    %eax,%ebp
	      n2 = n1 >> b;
  8027d5:	89 d6                	mov    %edx,%esi
  8027d7:	88 d9                	mov    %bl,%cl
  8027d9:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
  8027db:	89 f9                	mov    %edi,%ecx
  8027dd:	d3 e2                	shl    %cl,%edx
  8027df:	8b 44 24 08          	mov    0x8(%esp),%eax
  8027e3:	88 d9                	mov    %bl,%cl
  8027e5:	d3 e8                	shr    %cl,%eax
  8027e7:	09 c2                	or     %eax,%edx
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8027e9:	89 d0                	mov    %edx,%eax
  8027eb:	89 f2                	mov    %esi,%edx
  8027ed:	f7 74 24 0c          	divl   0xc(%esp)
  8027f1:	89 d6                	mov    %edx,%esi
  8027f3:	89 c3                	mov    %eax,%ebx
	      umul_ppmm (m1, m0, q0, d0);
  8027f5:	f7 e5                	mul    %ebp

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8027f7:	39 d6                	cmp    %edx,%esi
  8027f9:	72 19                	jb     802814 <__udivdi3+0xfc>
  8027fb:	74 0b                	je     802808 <__udivdi3+0xf0>
  8027fd:	89 d8                	mov    %ebx,%eax
  8027ff:	31 ff                	xor    %edi,%edi
  802801:	e9 58 ff ff ff       	jmp    80275e <__udivdi3+0x46>
  802806:	66 90                	xchg   %ax,%ax
  802808:	8b 54 24 08          	mov    0x8(%esp),%edx
  80280c:	89 f9                	mov    %edi,%ecx
  80280e:	d3 e2                	shl    %cl,%edx
  802810:	39 c2                	cmp    %eax,%edx
  802812:	73 e9                	jae    8027fd <__udivdi3+0xe5>
  802814:	8d 43 ff             	lea    -0x1(%ebx),%eax
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802817:	31 ff                	xor    %edi,%edi
  802819:	e9 40 ff ff ff       	jmp    80275e <__udivdi3+0x46>
  80281e:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802820:	31 c0                	xor    %eax,%eax
  802822:	e9 37 ff ff ff       	jmp    80275e <__udivdi3+0x46>
  802827:	90                   	nop

00802828 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  802828:	55                   	push   %ebp
  802829:	57                   	push   %edi
  80282a:	56                   	push   %esi
  80282b:	53                   	push   %ebx
  80282c:	83 ec 1c             	sub    $0x1c,%esp
  80282f:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  802833:	8b 74 24 34          	mov    0x34(%esp),%esi
  802837:	8b 7c 24 38          	mov    0x38(%esp),%edi
  80283b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80283f:	89 44 24 0c          	mov    %eax,0xc(%esp)
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  802843:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802847:	89 f3                	mov    %esi,%ebx
  const DWunion dd = {.ll = d};
  802849:	89 fa                	mov    %edi,%edx
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  80284b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  n1 = nn.s.high;
  80284f:	89 34 24             	mov    %esi,(%esp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802852:	85 c0                	test   %eax,%eax
  802854:	75 1a                	jne    802870 <__umoddi3+0x48>
    {
      if (d0 > n1)
  802856:	39 f7                	cmp    %esi,%edi
  802858:	0f 86 a2 00 00 00    	jbe    802900 <__umoddi3+0xd8>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80285e:	89 c8                	mov    %ecx,%eax
  802860:	89 f2                	mov    %esi,%edx
  802862:	f7 f7                	div    %edi
  802864:	89 d0                	mov    %edx,%eax

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  802866:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802868:	83 c4 1c             	add    $0x1c,%esp
  80286b:	5b                   	pop    %ebx
  80286c:	5e                   	pop    %esi
  80286d:	5f                   	pop    %edi
  80286e:	5d                   	pop    %ebp
  80286f:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802870:	39 f0                	cmp    %esi,%eax
  802872:	0f 87 ac 00 00 00    	ja     802924 <__umoddi3+0xfc>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802878:	0f bd e8             	bsr    %eax,%ebp
	  if (bm == 0)
  80287b:	83 f5 1f             	xor    $0x1f,%ebp
  80287e:	0f 84 ac 00 00 00    	je     802930 <__umoddi3+0x108>
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802884:	bf 20 00 00 00       	mov    $0x20,%edi
  802889:	29 ef                	sub    %ebp,%edi
  80288b:	89 fe                	mov    %edi,%esi
  80288d:	89 7c 24 0c          	mov    %edi,0xc(%esp)

	      d1 = (d1 << bm) | (d0 >> b);
  802891:	89 e9                	mov    %ebp,%ecx
  802893:	d3 e0                	shl    %cl,%eax
  802895:	89 d7                	mov    %edx,%edi
  802897:	89 f1                	mov    %esi,%ecx
  802899:	d3 ef                	shr    %cl,%edi
  80289b:	09 c7                	or     %eax,%edi
	      d0 = d0 << bm;
  80289d:	89 e9                	mov    %ebp,%ecx
  80289f:	d3 e2                	shl    %cl,%edx
  8028a1:	89 14 24             	mov    %edx,(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8028a4:	89 d8                	mov    %ebx,%eax
  8028a6:	d3 e0                	shl    %cl,%eax
  8028a8:	89 c2                	mov    %eax,%edx
	      n0 = n0 << bm;
  8028aa:	8b 44 24 08          	mov    0x8(%esp),%eax
  8028ae:	d3 e0                	shl    %cl,%eax
  8028b0:	89 44 24 04          	mov    %eax,0x4(%esp)

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8028b4:	8b 44 24 08          	mov    0x8(%esp),%eax
  8028b8:	89 f1                	mov    %esi,%ecx
  8028ba:	d3 e8                	shr    %cl,%eax
  8028bc:	09 d0                	or     %edx,%eax
  8028be:	d3 eb                	shr    %cl,%ebx
  8028c0:	89 da                	mov    %ebx,%edx
  8028c2:	f7 f7                	div    %edi
  8028c4:	89 d3                	mov    %edx,%ebx
	      umul_ppmm (m1, m0, q0, d0);
  8028c6:	f7 24 24             	mull   (%esp)
  8028c9:	89 c6                	mov    %eax,%esi
  8028cb:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8028cd:	39 d3                	cmp    %edx,%ebx
  8028cf:	0f 82 87 00 00 00    	jb     80295c <__umoddi3+0x134>
  8028d5:	0f 84 91 00 00 00    	je     80296c <__umoddi3+0x144>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  8028db:	8b 54 24 04          	mov    0x4(%esp),%edx
  8028df:	29 f2                	sub    %esi,%edx
  8028e1:	19 cb                	sbb    %ecx,%ebx
		  rr.s.low = (n1 << b) | (n0 >> bm);
  8028e3:	89 d8                	mov    %ebx,%eax
  8028e5:	8a 4c 24 0c          	mov    0xc(%esp),%cl
  8028e9:	d3 e0                	shl    %cl,%eax
  8028eb:	89 e9                	mov    %ebp,%ecx
  8028ed:	d3 ea                	shr    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  8028ef:	09 d0                	or     %edx,%eax
  8028f1:	89 e9                	mov    %ebp,%ecx
  8028f3:	d3 eb                	shr    %cl,%ebx
  8028f5:	89 da                	mov    %ebx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8028f7:	83 c4 1c             	add    $0x1c,%esp
  8028fa:	5b                   	pop    %ebx
  8028fb:	5e                   	pop    %esi
  8028fc:	5f                   	pop    %edi
  8028fd:	5d                   	pop    %ebp
  8028fe:	c3                   	ret    
  8028ff:	90                   	nop
  802900:	89 fd                	mov    %edi,%ebp
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802902:	85 ff                	test   %edi,%edi
  802904:	75 0b                	jne    802911 <__umoddi3+0xe9>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802906:	b8 01 00 00 00       	mov    $0x1,%eax
  80290b:	31 d2                	xor    %edx,%edx
  80290d:	f7 f7                	div    %edi
  80290f:	89 c5                	mov    %eax,%ebp

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802911:	89 f0                	mov    %esi,%eax
  802913:	31 d2                	xor    %edx,%edx
  802915:	f7 f5                	div    %ebp
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802917:	89 c8                	mov    %ecx,%eax
  802919:	f7 f5                	div    %ebp
  80291b:	89 d0                	mov    %edx,%eax
  80291d:	e9 44 ff ff ff       	jmp    802866 <__umoddi3+0x3e>
  802922:	66 90                	xchg   %ax,%ax
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  802924:	89 c8                	mov    %ecx,%eax
  802926:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802928:	83 c4 1c             	add    $0x1c,%esp
  80292b:	5b                   	pop    %ebx
  80292c:	5e                   	pop    %esi
  80292d:	5f                   	pop    %edi
  80292e:	5d                   	pop    %ebp
  80292f:	c3                   	ret    

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802930:	3b 04 24             	cmp    (%esp),%eax
  802933:	72 06                	jb     80293b <__umoddi3+0x113>
  802935:	3b 7c 24 04          	cmp    0x4(%esp),%edi
  802939:	77 0f                	ja     80294a <__umoddi3+0x122>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  80293b:	89 f2                	mov    %esi,%edx
  80293d:	29 f9                	sub    %edi,%ecx
  80293f:	1b 54 24 0c          	sbb    0xc(%esp),%edx
  802943:	89 14 24             	mov    %edx,(%esp)
  802946:	89 4c 24 04          	mov    %ecx,0x4(%esp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  80294a:	8b 44 24 04          	mov    0x4(%esp),%eax
  80294e:	8b 14 24             	mov    (%esp),%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802951:	83 c4 1c             	add    $0x1c,%esp
  802954:	5b                   	pop    %ebx
  802955:	5e                   	pop    %esi
  802956:	5f                   	pop    %edi
  802957:	5d                   	pop    %ebp
  802958:	c3                   	ret    
  802959:	8d 76 00             	lea    0x0(%esi),%esi
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  80295c:	2b 04 24             	sub    (%esp),%eax
  80295f:	19 fa                	sbb    %edi,%edx
  802961:	89 d1                	mov    %edx,%ecx
  802963:	89 c6                	mov    %eax,%esi
  802965:	e9 71 ff ff ff       	jmp    8028db <__umoddi3+0xb3>
  80296a:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80296c:	39 44 24 04          	cmp    %eax,0x4(%esp)
  802970:	72 ea                	jb     80295c <__umoddi3+0x134>
  802972:	89 d9                	mov    %ebx,%ecx
  802974:	e9 62 ff ff ff       	jmp    8028db <__umoddi3+0xb3>
