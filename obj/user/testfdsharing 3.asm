
obj/user/testfdsharing.debug:     file format elf32-i386


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
  80002c:	e8 87 01 00 00       	call   8001b8 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

char buf[512], buf2[512];

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 14             	sub    $0x14,%esp
	int fd, r, n, n2;

	if ((fd = open("motd", O_RDONLY)) < 0)
  80003c:	6a 00                	push   $0x0
  80003e:	68 c0 23 80 00       	push   $0x8023c0
  800043:	e8 ef 18 00 00       	call   801937 <open>
  800048:	89 c3                	mov    %eax,%ebx
  80004a:	83 c4 10             	add    $0x10,%esp
  80004d:	85 c0                	test   %eax,%eax
  80004f:	79 12                	jns    800063 <umain+0x30>
		panic("open motd: %e", fd);
  800051:	50                   	push   %eax
  800052:	68 c5 23 80 00       	push   $0x8023c5
  800057:	6a 0c                	push   $0xc
  800059:	68 d3 23 80 00       	push   $0x8023d3
  80005e:	e8 be 01 00 00       	call   800221 <_panic>
	seek(fd, 0);
  800063:	83 ec 08             	sub    $0x8,%esp
  800066:	6a 00                	push   $0x0
  800068:	50                   	push   %eax
  800069:	e8 26 16 00 00       	call   801694 <seek>
	if ((n = readn(fd, buf, sizeof buf)) <= 0)
  80006e:	83 c4 0c             	add    $0xc,%esp
  800071:	68 00 02 00 00       	push   $0x200
  800076:	68 20 42 80 00       	push   $0x804220
  80007b:	53                   	push   %ebx
  80007c:	e8 3c 15 00 00       	call   8015bd <readn>
  800081:	89 c6                	mov    %eax,%esi
  800083:	83 c4 10             	add    $0x10,%esp
  800086:	85 c0                	test   %eax,%eax
  800088:	7f 12                	jg     80009c <umain+0x69>
		panic("readn: %e", n);
  80008a:	50                   	push   %eax
  80008b:	68 e8 23 80 00       	push   $0x8023e8
  800090:	6a 0f                	push   $0xf
  800092:	68 d3 23 80 00       	push   $0x8023d3
  800097:	e8 85 01 00 00       	call   800221 <_panic>

	if ((r = fork()) < 0)
  80009c:	e8 8d 0f 00 00       	call   80102e <fork>
  8000a1:	89 c7                	mov    %eax,%edi
  8000a3:	85 c0                	test   %eax,%eax
  8000a5:	79 12                	jns    8000b9 <umain+0x86>
		panic("fork: %e", r);
  8000a7:	50                   	push   %eax
  8000a8:	68 f2 23 80 00       	push   $0x8023f2
  8000ad:	6a 12                	push   $0x12
  8000af:	68 d3 23 80 00       	push   $0x8023d3
  8000b4:	e8 68 01 00 00       	call   800221 <_panic>
	if (r == 0) {
  8000b9:	85 c0                	test   %eax,%eax
  8000bb:	0f 85 9d 00 00 00    	jne    80015e <umain+0x12b>
		seek(fd, 0);
  8000c1:	83 ec 08             	sub    $0x8,%esp
  8000c4:	6a 00                	push   $0x0
  8000c6:	53                   	push   %ebx
  8000c7:	e8 c8 15 00 00       	call   801694 <seek>
		cprintf("going to read in child (might page fault if your sharing is buggy)\n");
  8000cc:	c7 04 24 30 24 80 00 	movl   $0x802430,(%esp)
  8000d3:	e8 21 02 00 00       	call   8002f9 <cprintf>
		if ((n2 = readn(fd, buf2, sizeof buf2)) != n)
  8000d8:	83 c4 0c             	add    $0xc,%esp
  8000db:	68 00 02 00 00       	push   $0x200
  8000e0:	68 20 40 80 00       	push   $0x804020
  8000e5:	53                   	push   %ebx
  8000e6:	e8 d2 14 00 00       	call   8015bd <readn>
  8000eb:	83 c4 10             	add    $0x10,%esp
  8000ee:	39 c6                	cmp    %eax,%esi
  8000f0:	74 16                	je     800108 <umain+0xd5>
			panic("read in parent got %d, read in child got %d", n, n2);
  8000f2:	83 ec 0c             	sub    $0xc,%esp
  8000f5:	50                   	push   %eax
  8000f6:	56                   	push   %esi
  8000f7:	68 74 24 80 00       	push   $0x802474
  8000fc:	6a 17                	push   $0x17
  8000fe:	68 d3 23 80 00       	push   $0x8023d3
  800103:	e8 19 01 00 00       	call   800221 <_panic>
		if (memcmp(buf, buf2, n) != 0)
  800108:	83 ec 04             	sub    $0x4,%esp
  80010b:	56                   	push   %esi
  80010c:	68 20 40 80 00       	push   $0x804020
  800111:	68 20 42 80 00       	push   $0x804220
  800116:	e8 09 0a 00 00       	call   800b24 <memcmp>
  80011b:	83 c4 10             	add    $0x10,%esp
  80011e:	85 c0                	test   %eax,%eax
  800120:	74 14                	je     800136 <umain+0x103>
			panic("read in parent got different bytes from read in child");
  800122:	83 ec 04             	sub    $0x4,%esp
  800125:	68 a0 24 80 00       	push   $0x8024a0
  80012a:	6a 19                	push   $0x19
  80012c:	68 d3 23 80 00       	push   $0x8023d3
  800131:	e8 eb 00 00 00       	call   800221 <_panic>
		cprintf("read in child succeeded\n");
  800136:	83 ec 0c             	sub    $0xc,%esp
  800139:	68 fb 23 80 00       	push   $0x8023fb
  80013e:	e8 b6 01 00 00       	call   8002f9 <cprintf>
		seek(fd, 0);
  800143:	83 c4 08             	add    $0x8,%esp
  800146:	6a 00                	push   $0x0
  800148:	53                   	push   %ebx
  800149:	e8 46 15 00 00       	call   801694 <seek>
		close(fd);
  80014e:	89 1c 24             	mov    %ebx,(%esp)
  800151:	e8 a8 12 00 00       	call   8013fe <close>
		exit();
  800156:	e8 ac 00 00 00       	call   800207 <exit>
  80015b:	83 c4 10             	add    $0x10,%esp
	}
	wait(r);
  80015e:	83 ec 0c             	sub    $0xc,%esp
  800161:	57                   	push   %edi
  800162:	e8 bd 1b 00 00       	call   801d24 <wait>
	if ((n2 = readn(fd, buf2, sizeof buf2)) != n)
  800167:	83 c4 0c             	add    $0xc,%esp
  80016a:	68 00 02 00 00       	push   $0x200
  80016f:	68 20 40 80 00       	push   $0x804020
  800174:	53                   	push   %ebx
  800175:	e8 43 14 00 00       	call   8015bd <readn>
  80017a:	83 c4 10             	add    $0x10,%esp
  80017d:	39 c6                	cmp    %eax,%esi
  80017f:	74 16                	je     800197 <umain+0x164>
		panic("read in parent got %d, then got %d", n, n2);
  800181:	83 ec 0c             	sub    $0xc,%esp
  800184:	50                   	push   %eax
  800185:	56                   	push   %esi
  800186:	68 d8 24 80 00       	push   $0x8024d8
  80018b:	6a 21                	push   $0x21
  80018d:	68 d3 23 80 00       	push   $0x8023d3
  800192:	e8 8a 00 00 00       	call   800221 <_panic>
	cprintf("read in parent succeeded\n");
  800197:	83 ec 0c             	sub    $0xc,%esp
  80019a:	68 14 24 80 00       	push   $0x802414
  80019f:	e8 55 01 00 00       	call   8002f9 <cprintf>
	close(fd);
  8001a4:	89 1c 24             	mov    %ebx,(%esp)
  8001a7:	e8 52 12 00 00       	call   8013fe <close>
static __inline uint64_t read_tsc(void) __attribute__((always_inline));

static __inline void
breakpoint(void)
{
	__asm __volatile("int3");
  8001ac:	cc                   	int3   

	breakpoint();
}
  8001ad:	83 c4 10             	add    $0x10,%esp
  8001b0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001b3:	5b                   	pop    %ebx
  8001b4:	5e                   	pop    %esi
  8001b5:	5f                   	pop    %edi
  8001b6:	5d                   	pop    %ebp
  8001b7:	c3                   	ret    

008001b8 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001b8:	55                   	push   %ebp
  8001b9:	89 e5                	mov    %esp,%ebp
  8001bb:	56                   	push   %esi
  8001bc:	53                   	push   %ebx
  8001bd:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001c0:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8001c3:	e8 48 0b 00 00       	call   800d10 <sys_getenvid>
  8001c8:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001cd:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8001d4:	c1 e0 07             	shl    $0x7,%eax
  8001d7:	29 d0                	sub    %edx,%eax
  8001d9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001de:	a3 20 44 80 00       	mov    %eax,0x804420

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001e3:	85 db                	test   %ebx,%ebx
  8001e5:	7e 07                	jle    8001ee <libmain+0x36>
		binaryname = argv[0];
  8001e7:	8b 06                	mov    (%esi),%eax
  8001e9:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8001ee:	83 ec 08             	sub    $0x8,%esp
  8001f1:	56                   	push   %esi
  8001f2:	53                   	push   %ebx
  8001f3:	e8 3b fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8001f8:	e8 0a 00 00 00       	call   800207 <exit>
}
  8001fd:	83 c4 10             	add    $0x10,%esp
  800200:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800203:	5b                   	pop    %ebx
  800204:	5e                   	pop    %esi
  800205:	5d                   	pop    %ebp
  800206:	c3                   	ret    

00800207 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800207:	55                   	push   %ebp
  800208:	89 e5                	mov    %esp,%ebp
  80020a:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80020d:	e8 17 12 00 00       	call   801429 <close_all>
	sys_env_destroy(0);
  800212:	83 ec 0c             	sub    $0xc,%esp
  800215:	6a 00                	push   $0x0
  800217:	e8 b3 0a 00 00       	call   800ccf <sys_env_destroy>
}
  80021c:	83 c4 10             	add    $0x10,%esp
  80021f:	c9                   	leave  
  800220:	c3                   	ret    

00800221 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800221:	55                   	push   %ebp
  800222:	89 e5                	mov    %esp,%ebp
  800224:	56                   	push   %esi
  800225:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800226:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800229:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80022f:	e8 dc 0a 00 00       	call   800d10 <sys_getenvid>
  800234:	83 ec 0c             	sub    $0xc,%esp
  800237:	ff 75 0c             	pushl  0xc(%ebp)
  80023a:	ff 75 08             	pushl  0x8(%ebp)
  80023d:	56                   	push   %esi
  80023e:	50                   	push   %eax
  80023f:	68 08 25 80 00       	push   $0x802508
  800244:	e8 b0 00 00 00       	call   8002f9 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800249:	83 c4 18             	add    $0x18,%esp
  80024c:	53                   	push   %ebx
  80024d:	ff 75 10             	pushl  0x10(%ebp)
  800250:	e8 53 00 00 00       	call   8002a8 <vcprintf>
	cprintf("\n");
  800255:	c7 04 24 8b 28 80 00 	movl   $0x80288b,(%esp)
  80025c:	e8 98 00 00 00       	call   8002f9 <cprintf>
  800261:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800264:	cc                   	int3   
  800265:	eb fd                	jmp    800264 <_panic+0x43>

00800267 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800267:	55                   	push   %ebp
  800268:	89 e5                	mov    %esp,%ebp
  80026a:	53                   	push   %ebx
  80026b:	83 ec 04             	sub    $0x4,%esp
  80026e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800271:	8b 13                	mov    (%ebx),%edx
  800273:	8d 42 01             	lea    0x1(%edx),%eax
  800276:	89 03                	mov    %eax,(%ebx)
  800278:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80027b:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80027f:	3d ff 00 00 00       	cmp    $0xff,%eax
  800284:	75 1a                	jne    8002a0 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800286:	83 ec 08             	sub    $0x8,%esp
  800289:	68 ff 00 00 00       	push   $0xff
  80028e:	8d 43 08             	lea    0x8(%ebx),%eax
  800291:	50                   	push   %eax
  800292:	e8 fb 09 00 00       	call   800c92 <sys_cputs>
		b->idx = 0;
  800297:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80029d:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8002a0:	ff 43 04             	incl   0x4(%ebx)
}
  8002a3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8002a6:	c9                   	leave  
  8002a7:	c3                   	ret    

008002a8 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002a8:	55                   	push   %ebp
  8002a9:	89 e5                	mov    %esp,%ebp
  8002ab:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8002b1:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002b8:	00 00 00 
	b.cnt = 0;
  8002bb:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002c2:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002c5:	ff 75 0c             	pushl  0xc(%ebp)
  8002c8:	ff 75 08             	pushl  0x8(%ebp)
  8002cb:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002d1:	50                   	push   %eax
  8002d2:	68 67 02 80 00       	push   $0x800267
  8002d7:	e8 54 01 00 00       	call   800430 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002dc:	83 c4 08             	add    $0x8,%esp
  8002df:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8002e5:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002eb:	50                   	push   %eax
  8002ec:	e8 a1 09 00 00       	call   800c92 <sys_cputs>

	return b.cnt;
}
  8002f1:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002f7:	c9                   	leave  
  8002f8:	c3                   	ret    

008002f9 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002f9:	55                   	push   %ebp
  8002fa:	89 e5                	mov    %esp,%ebp
  8002fc:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002ff:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800302:	50                   	push   %eax
  800303:	ff 75 08             	pushl  0x8(%ebp)
  800306:	e8 9d ff ff ff       	call   8002a8 <vcprintf>
	va_end(ap);

	return cnt;
}
  80030b:	c9                   	leave  
  80030c:	c3                   	ret    

0080030d <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80030d:	55                   	push   %ebp
  80030e:	89 e5                	mov    %esp,%ebp
  800310:	57                   	push   %edi
  800311:	56                   	push   %esi
  800312:	53                   	push   %ebx
  800313:	83 ec 1c             	sub    $0x1c,%esp
  800316:	89 c6                	mov    %eax,%esi
  800318:	89 d7                	mov    %edx,%edi
  80031a:	8b 45 08             	mov    0x8(%ebp),%eax
  80031d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800320:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800323:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800326:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800329:	bb 00 00 00 00       	mov    $0x0,%ebx
  80032e:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800331:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800334:	39 d3                	cmp    %edx,%ebx
  800336:	72 11                	jb     800349 <printnum+0x3c>
  800338:	39 45 10             	cmp    %eax,0x10(%ebp)
  80033b:	76 0c                	jbe    800349 <printnum+0x3c>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80033d:	8b 45 14             	mov    0x14(%ebp),%eax
  800340:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800343:	85 db                	test   %ebx,%ebx
  800345:	7f 37                	jg     80037e <printnum+0x71>
  800347:	eb 44                	jmp    80038d <printnum+0x80>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800349:	83 ec 0c             	sub    $0xc,%esp
  80034c:	ff 75 18             	pushl  0x18(%ebp)
  80034f:	8b 45 14             	mov    0x14(%ebp),%eax
  800352:	48                   	dec    %eax
  800353:	50                   	push   %eax
  800354:	ff 75 10             	pushl  0x10(%ebp)
  800357:	83 ec 08             	sub    $0x8,%esp
  80035a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80035d:	ff 75 e0             	pushl  -0x20(%ebp)
  800360:	ff 75 dc             	pushl  -0x24(%ebp)
  800363:	ff 75 d8             	pushl  -0x28(%ebp)
  800366:	e8 d5 1d 00 00       	call   802140 <__udivdi3>
  80036b:	83 c4 18             	add    $0x18,%esp
  80036e:	52                   	push   %edx
  80036f:	50                   	push   %eax
  800370:	89 fa                	mov    %edi,%edx
  800372:	89 f0                	mov    %esi,%eax
  800374:	e8 94 ff ff ff       	call   80030d <printnum>
  800379:	83 c4 20             	add    $0x20,%esp
  80037c:	eb 0f                	jmp    80038d <printnum+0x80>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80037e:	83 ec 08             	sub    $0x8,%esp
  800381:	57                   	push   %edi
  800382:	ff 75 18             	pushl  0x18(%ebp)
  800385:	ff d6                	call   *%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800387:	83 c4 10             	add    $0x10,%esp
  80038a:	4b                   	dec    %ebx
  80038b:	75 f1                	jne    80037e <printnum+0x71>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80038d:	83 ec 08             	sub    $0x8,%esp
  800390:	57                   	push   %edi
  800391:	83 ec 04             	sub    $0x4,%esp
  800394:	ff 75 e4             	pushl  -0x1c(%ebp)
  800397:	ff 75 e0             	pushl  -0x20(%ebp)
  80039a:	ff 75 dc             	pushl  -0x24(%ebp)
  80039d:	ff 75 d8             	pushl  -0x28(%ebp)
  8003a0:	e8 ab 1e 00 00       	call   802250 <__umoddi3>
  8003a5:	83 c4 14             	add    $0x14,%esp
  8003a8:	0f be 80 2b 25 80 00 	movsbl 0x80252b(%eax),%eax
  8003af:	50                   	push   %eax
  8003b0:	ff d6                	call   *%esi
}
  8003b2:	83 c4 10             	add    $0x10,%esp
  8003b5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003b8:	5b                   	pop    %ebx
  8003b9:	5e                   	pop    %esi
  8003ba:	5f                   	pop    %edi
  8003bb:	5d                   	pop    %ebp
  8003bc:	c3                   	ret    

008003bd <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003bd:	55                   	push   %ebp
  8003be:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003c0:	83 fa 01             	cmp    $0x1,%edx
  8003c3:	7e 0e                	jle    8003d3 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003c5:	8b 10                	mov    (%eax),%edx
  8003c7:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003ca:	89 08                	mov    %ecx,(%eax)
  8003cc:	8b 02                	mov    (%edx),%eax
  8003ce:	8b 52 04             	mov    0x4(%edx),%edx
  8003d1:	eb 22                	jmp    8003f5 <getuint+0x38>
	else if (lflag)
  8003d3:	85 d2                	test   %edx,%edx
  8003d5:	74 10                	je     8003e7 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003d7:	8b 10                	mov    (%eax),%edx
  8003d9:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003dc:	89 08                	mov    %ecx,(%eax)
  8003de:	8b 02                	mov    (%edx),%eax
  8003e0:	ba 00 00 00 00       	mov    $0x0,%edx
  8003e5:	eb 0e                	jmp    8003f5 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003e7:	8b 10                	mov    (%eax),%edx
  8003e9:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003ec:	89 08                	mov    %ecx,(%eax)
  8003ee:	8b 02                	mov    (%edx),%eax
  8003f0:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003f5:	5d                   	pop    %ebp
  8003f6:	c3                   	ret    

008003f7 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003f7:	55                   	push   %ebp
  8003f8:	89 e5                	mov    %esp,%ebp
  8003fa:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003fd:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800400:	8b 10                	mov    (%eax),%edx
  800402:	3b 50 04             	cmp    0x4(%eax),%edx
  800405:	73 0a                	jae    800411 <sprintputch+0x1a>
		*b->buf++ = ch;
  800407:	8d 4a 01             	lea    0x1(%edx),%ecx
  80040a:	89 08                	mov    %ecx,(%eax)
  80040c:	8b 45 08             	mov    0x8(%ebp),%eax
  80040f:	88 02                	mov    %al,(%edx)
}
  800411:	5d                   	pop    %ebp
  800412:	c3                   	ret    

00800413 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800413:	55                   	push   %ebp
  800414:	89 e5                	mov    %esp,%ebp
  800416:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800419:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80041c:	50                   	push   %eax
  80041d:	ff 75 10             	pushl  0x10(%ebp)
  800420:	ff 75 0c             	pushl  0xc(%ebp)
  800423:	ff 75 08             	pushl  0x8(%ebp)
  800426:	e8 05 00 00 00       	call   800430 <vprintfmt>
	va_end(ap);
}
  80042b:	83 c4 10             	add    $0x10,%esp
  80042e:	c9                   	leave  
  80042f:	c3                   	ret    

00800430 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800430:	55                   	push   %ebp
  800431:	89 e5                	mov    %esp,%ebp
  800433:	57                   	push   %edi
  800434:	56                   	push   %esi
  800435:	53                   	push   %ebx
  800436:	83 ec 2c             	sub    $0x2c,%esp
  800439:	8b 7d 08             	mov    0x8(%ebp),%edi
  80043c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80043f:	eb 03                	jmp    800444 <vprintfmt+0x14>
			break;

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
			for (fmt--; fmt[-1] != '%'; fmt--)
  800441:	89 75 10             	mov    %esi,0x10(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {    //遍历输入的第一个参数，即输出信息的格式，先把格式字符串中'%'之前的字符一个个输出，因为它们前面没有'%'，所以它们就是要直接显示在屏幕上的
  800444:	8b 45 10             	mov    0x10(%ebp),%eax
  800447:	8d 70 01             	lea    0x1(%eax),%esi
  80044a:	0f b6 00             	movzbl (%eax),%eax
  80044d:	83 f8 25             	cmp    $0x25,%eax
  800450:	74 25                	je     800477 <vprintfmt+0x47>
			if (ch == '\0')									//当然中间如果遇到'\0'，代表这个字符串的访问结束
  800452:	85 c0                	test   %eax,%eax
  800454:	75 0d                	jne    800463 <vprintfmt+0x33>
  800456:	e9 b5 03 00 00       	jmp    800810 <vprintfmt+0x3e0>
  80045b:	85 c0                	test   %eax,%eax
  80045d:	0f 84 ad 03 00 00    	je     800810 <vprintfmt+0x3e0>
				return;
			putch(ch, putdat);								//调用putch函数，把一个字符ch输出到putdat指针所指向的地址中所存放的值对应的地址处
  800463:	83 ec 08             	sub    $0x8,%esp
  800466:	53                   	push   %ebx
  800467:	50                   	push   %eax
  800468:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {    //遍历输入的第一个参数，即输出信息的格式，先把格式字符串中'%'之前的字符一个个输出，因为它们前面没有'%'，所以它们就是要直接显示在屏幕上的
  80046a:	46                   	inc    %esi
  80046b:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  80046f:	83 c4 10             	add    $0x10,%esp
  800472:	83 f8 25             	cmp    $0x25,%eax
  800475:	75 e4                	jne    80045b <vprintfmt+0x2b>
			if (width < 0)									//代表有小数点，但是小数点前面并没有数字，比如'%.6f'这种情况，此时代表整数部分全部显示
				width = 0;			
			goto reswitch;

		case '#':
			altflag = 1;
  800477:	c6 45 e3 20          	movb   $0x20,-0x1d(%ebp)
  80047b:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800482:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800489:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800490:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800497:	eb 07                	jmp    8004a0 <vprintfmt+0x70>
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  800499:	8b 75 10             	mov    0x10(%ebp),%esi

		// flag to pad on the right
		case '-':											//%后面的'-'代表要进行左对齐输出，右边填空格，如果省略代表右对齐
			padc = '-';										//如果有这个字符代表左对齐，则把对齐方式标志位变为'-'
  80049c:	c6 45 e3 2d          	movb   $0x2d,-0x1d(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  8004a0:	8d 46 01             	lea    0x1(%esi),%eax
  8004a3:	89 45 10             	mov    %eax,0x10(%ebp)
  8004a6:	0f b6 16             	movzbl (%esi),%edx
  8004a9:	8a 06                	mov    (%esi),%al
  8004ab:	83 e8 23             	sub    $0x23,%eax
  8004ae:	3c 55                	cmp    $0x55,%al
  8004b0:	0f 87 03 03 00 00    	ja     8007b9 <vprintfmt+0x389>
  8004b6:	0f b6 c0             	movzbl %al,%eax
  8004b9:	ff 24 85 60 26 80 00 	jmp    *0x802660(,%eax,4)
  8004c0:	8b 75 10             	mov    0x10(%ebp),%esi
			padc = '-';										//如果有这个字符代表左对齐，则把对齐方式标志位变为'-'
			goto reswitch;									//处理下一个字符

		// flag to pad with 0's instead of spaces
		case '0':											//0--有0表示进行对齐输出时填0,如省略表示填入空格，并且如果为0，则一定是右对齐
			padc = '0';										//对其方式标志位变为0
  8004c3:	c6 45 e3 30          	movb   $0x30,-0x1d(%ebp)
  8004c7:	eb d7                	jmp    8004a0 <vprintfmt+0x70>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {					//把遇到的位数字符串转换为真实的位数，比如输入的'%40'，代表有效位数为40位，下面的循环就是把precesion的值设置为40
				precision = precision * 10 + ch - '0';
  8004c9:	8d 42 d0             	lea    -0x30(%edx),%eax
  8004cc:	89 c1                	mov    %eax,%ecx
  8004ce:	89 45 d0             	mov    %eax,-0x30(%ebp)
				ch = *fmt;
  8004d1:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  8004d5:	8d 50 d0             	lea    -0x30(%eax),%edx
  8004d8:	83 fa 09             	cmp    $0x9,%edx
  8004db:	77 51                	ja     80052e <vprintfmt+0xfe>
  8004dd:	8b 75 10             	mov    0x10(%ebp),%esi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {					//把遇到的位数字符串转换为真实的位数，比如输入的'%40'，代表有效位数为40位，下面的循环就是把precesion的值设置为40
  8004e0:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  8004e1:	8d 14 89             	lea    (%ecx,%ecx,4),%edx
  8004e4:	01 d2                	add    %edx,%edx
  8004e6:	8d 4c 10 d0          	lea    -0x30(%eax,%edx,1),%ecx
				ch = *fmt;
  8004ea:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8004ed:	8d 50 d0             	lea    -0x30(%eax),%edx
  8004f0:	83 fa 09             	cmp    $0x9,%edx
  8004f3:	76 eb                	jbe    8004e0 <vprintfmt+0xb0>
  8004f5:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8004f8:	eb 37                	jmp    800531 <vprintfmt+0x101>
					break;
			}
			goto process_precision;							//跳转到process_precistion子过程

		case '*':											//*--代表有效数字的位数也是由输入参数指定的，比如printf("%*.*f", 10, 2, n)，其中10,2就是用来指定显示的有效数字位数的
			precision = va_arg(ap, int);
  8004fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8004fd:	8d 50 04             	lea    0x4(%eax),%edx
  800500:	89 55 14             	mov    %edx,0x14(%ebp)
  800503:	8b 00                	mov    (%eax),%eax
  800505:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  800508:	8b 75 10             	mov    0x10(%ebp),%esi
			}
			goto process_precision;							//跳转到process_precistion子过程

		case '*':											//*--代表有效数字的位数也是由输入参数指定的，比如printf("%*.*f", 10, 2, n)，其中10,2就是用来指定显示的有效数字位数的
			precision = va_arg(ap, int);
			goto process_precision;
  80050b:	eb 24                	jmp    800531 <vprintfmt+0x101>
  80050d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800511:	79 07                	jns    80051a <vprintfmt+0xea>
  800513:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  80051a:	8b 75 10             	mov    0x10(%ebp),%esi
  80051d:	eb 81                	jmp    8004a0 <vprintfmt+0x70>
  80051f:	8b 75 10             	mov    0x10(%ebp),%esi
			if (width < 0)									//代表有小数点，但是小数点前面并没有数字，比如'%.6f'这种情况，此时代表整数部分全部显示
				width = 0;			
			goto reswitch;

		case '#':
			altflag = 1;
  800522:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800529:	e9 72 ff ff ff       	jmp    8004a0 <vprintfmt+0x70>
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  80052e:	8b 75 10             	mov    0x10(%ebp),%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:									//处理输出精度，把width字段赋值为刚刚计算出来的precision值，所以width应该是整数部分的有效数字位数
			if (width < 0)
  800531:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800535:	0f 89 65 ff ff ff    	jns    8004a0 <vprintfmt+0x70>
				width = precision, precision = -1;
  80053b:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80053e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800541:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800548:	e9 53 ff ff ff       	jmp    8004a0 <vprintfmt+0x70>
			goto reswitch;

		// long flag (doubled for long long)				
		case 'l':											//如果遇到'l'，代表应该是输入long类型，如果有两个'l'代表long long
			lflag++;										//此时把lflag++
  80054d:	ff 45 d4             	incl   -0x2c(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  800550:	8b 75 10             	mov    0x10(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)				
		case 'l':											//如果遇到'l'，代表应该是输入long类型，如果有两个'l'代表long long
			lflag++;										//此时把lflag++
			goto reswitch;
  800553:	e9 48 ff ff ff       	jmp    8004a0 <vprintfmt+0x70>

		// character
		case 'c':											//如果是'c'代表显示一个字符
			putch(va_arg(ap, int), putdat);					//调用输出一个字符到内存的函数putch
  800558:	8b 45 14             	mov    0x14(%ebp),%eax
  80055b:	8d 50 04             	lea    0x4(%eax),%edx
  80055e:	89 55 14             	mov    %edx,0x14(%ebp)
  800561:	83 ec 08             	sub    $0x8,%esp
  800564:	53                   	push   %ebx
  800565:	ff 30                	pushl  (%eax)
  800567:	ff d7                	call   *%edi
			break;
  800569:	83 c4 10             	add    $0x10,%esp
  80056c:	e9 d3 fe ff ff       	jmp    800444 <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800571:	8b 45 14             	mov    0x14(%ebp),%eax
  800574:	8d 50 04             	lea    0x4(%eax),%edx
  800577:	89 55 14             	mov    %edx,0x14(%ebp)
  80057a:	8b 00                	mov    (%eax),%eax
  80057c:	85 c0                	test   %eax,%eax
  80057e:	79 02                	jns    800582 <vprintfmt+0x152>
  800580:	f7 d8                	neg    %eax
  800582:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800584:	83 f8 0f             	cmp    $0xf,%eax
  800587:	7f 0b                	jg     800594 <vprintfmt+0x164>
  800589:	8b 04 85 c0 27 80 00 	mov    0x8027c0(,%eax,4),%eax
  800590:	85 c0                	test   %eax,%eax
  800592:	75 15                	jne    8005a9 <vprintfmt+0x179>
				printfmt(putch, putdat, "error %d", err);
  800594:	52                   	push   %edx
  800595:	68 43 25 80 00       	push   $0x802543
  80059a:	53                   	push   %ebx
  80059b:	57                   	push   %edi
  80059c:	e8 72 fe ff ff       	call   800413 <printfmt>
  8005a1:	83 c4 10             	add    $0x10,%esp
  8005a4:	e9 9b fe ff ff       	jmp    800444 <vprintfmt+0x14>
			else
				printfmt(putch, putdat, "%s", p);
  8005a9:	50                   	push   %eax
  8005aa:	68 ca 29 80 00       	push   $0x8029ca
  8005af:	53                   	push   %ebx
  8005b0:	57                   	push   %edi
  8005b1:	e8 5d fe ff ff       	call   800413 <printfmt>
  8005b6:	83 c4 10             	add    $0x10,%esp
  8005b9:	e9 86 fe ff ff       	jmp    800444 <vprintfmt+0x14>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005be:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c1:	8d 50 04             	lea    0x4(%eax),%edx
  8005c4:	89 55 14             	mov    %edx,0x14(%ebp)
  8005c7:	8b 00                	mov    (%eax),%eax
  8005c9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8005cc:	85 c0                	test   %eax,%eax
  8005ce:	75 07                	jne    8005d7 <vprintfmt+0x1a7>
				p = "(null)";
  8005d0:	c7 45 d4 3c 25 80 00 	movl   $0x80253c,-0x2c(%ebp)
			if (width > 0 && padc != '-')
  8005d7:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8005da:	85 f6                	test   %esi,%esi
  8005dc:	0f 8e fb 01 00 00    	jle    8007dd <vprintfmt+0x3ad>
  8005e2:	80 7d e3 2d          	cmpb   $0x2d,-0x1d(%ebp)
  8005e6:	0f 84 09 02 00 00    	je     8007f5 <vprintfmt+0x3c5>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005ec:	83 ec 08             	sub    $0x8,%esp
  8005ef:	ff 75 d0             	pushl  -0x30(%ebp)
  8005f2:	ff 75 d4             	pushl  -0x2c(%ebp)
  8005f5:	e8 ad 02 00 00       	call   8008a7 <strnlen>
  8005fa:	89 f1                	mov    %esi,%ecx
  8005fc:	29 c1                	sub    %eax,%ecx
  8005fe:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  800601:	83 c4 10             	add    $0x10,%esp
  800604:	85 c9                	test   %ecx,%ecx
  800606:	0f 8e d1 01 00 00    	jle    8007dd <vprintfmt+0x3ad>
					putch(padc, putdat);
  80060c:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  800610:	83 ec 08             	sub    $0x8,%esp
  800613:	53                   	push   %ebx
  800614:	56                   	push   %esi
  800615:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800617:	83 c4 10             	add    $0x10,%esp
  80061a:	ff 4d e4             	decl   -0x1c(%ebp)
  80061d:	75 f1                	jne    800610 <vprintfmt+0x1e0>
  80061f:	e9 b9 01 00 00       	jmp    8007dd <vprintfmt+0x3ad>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800624:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800628:	74 19                	je     800643 <vprintfmt+0x213>
  80062a:	0f be c0             	movsbl %al,%eax
  80062d:	83 e8 20             	sub    $0x20,%eax
  800630:	83 f8 5e             	cmp    $0x5e,%eax
  800633:	76 0e                	jbe    800643 <vprintfmt+0x213>
					putch('?', putdat);
  800635:	83 ec 08             	sub    $0x8,%esp
  800638:	53                   	push   %ebx
  800639:	6a 3f                	push   $0x3f
  80063b:	ff 55 08             	call   *0x8(%ebp)
  80063e:	83 c4 10             	add    $0x10,%esp
  800641:	eb 0b                	jmp    80064e <vprintfmt+0x21e>
				else
					putch(ch, putdat);
  800643:	83 ec 08             	sub    $0x8,%esp
  800646:	53                   	push   %ebx
  800647:	52                   	push   %edx
  800648:	ff 55 08             	call   *0x8(%ebp)
  80064b:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80064e:	ff 4d e4             	decl   -0x1c(%ebp)
  800651:	46                   	inc    %esi
  800652:	8a 46 ff             	mov    -0x1(%esi),%al
  800655:	0f be d0             	movsbl %al,%edx
  800658:	85 d2                	test   %edx,%edx
  80065a:	75 1c                	jne    800678 <vprintfmt+0x248>
  80065c:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80065f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800663:	7f 1f                	jg     800684 <vprintfmt+0x254>
  800665:	e9 da fd ff ff       	jmp    800444 <vprintfmt+0x14>
  80066a:	89 7d 08             	mov    %edi,0x8(%ebp)
  80066d:	8b 7d d0             	mov    -0x30(%ebp),%edi
  800670:	eb 06                	jmp    800678 <vprintfmt+0x248>
  800672:	89 7d 08             	mov    %edi,0x8(%ebp)
  800675:	8b 7d d0             	mov    -0x30(%ebp),%edi
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800678:	85 ff                	test   %edi,%edi
  80067a:	78 a8                	js     800624 <vprintfmt+0x1f4>
  80067c:	4f                   	dec    %edi
  80067d:	79 a5                	jns    800624 <vprintfmt+0x1f4>
  80067f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800682:	eb db                	jmp    80065f <vprintfmt+0x22f>
  800684:	8b 75 e4             	mov    -0x1c(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800687:	83 ec 08             	sub    $0x8,%esp
  80068a:	53                   	push   %ebx
  80068b:	6a 20                	push   $0x20
  80068d:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80068f:	4e                   	dec    %esi
  800690:	83 c4 10             	add    $0x10,%esp
  800693:	85 f6                	test   %esi,%esi
  800695:	7f f0                	jg     800687 <vprintfmt+0x257>
  800697:	e9 a8 fd ff ff       	jmp    800444 <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80069c:	83 7d d4 01          	cmpl   $0x1,-0x2c(%ebp)
  8006a0:	7e 16                	jle    8006b8 <vprintfmt+0x288>
		return va_arg(*ap, long long);
  8006a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a5:	8d 50 08             	lea    0x8(%eax),%edx
  8006a8:	89 55 14             	mov    %edx,0x14(%ebp)
  8006ab:	8b 50 04             	mov    0x4(%eax),%edx
  8006ae:	8b 00                	mov    (%eax),%eax
  8006b0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006b3:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006b6:	eb 34                	jmp    8006ec <vprintfmt+0x2bc>
	else if (lflag)
  8006b8:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8006bc:	74 18                	je     8006d6 <vprintfmt+0x2a6>
		return va_arg(*ap, long);
  8006be:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c1:	8d 50 04             	lea    0x4(%eax),%edx
  8006c4:	89 55 14             	mov    %edx,0x14(%ebp)
  8006c7:	8b 30                	mov    (%eax),%esi
  8006c9:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8006cc:	89 f0                	mov    %esi,%eax
  8006ce:	c1 f8 1f             	sar    $0x1f,%eax
  8006d1:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8006d4:	eb 16                	jmp    8006ec <vprintfmt+0x2bc>
	else
		return va_arg(*ap, int);
  8006d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d9:	8d 50 04             	lea    0x4(%eax),%edx
  8006dc:	89 55 14             	mov    %edx,0x14(%ebp)
  8006df:	8b 30                	mov    (%eax),%esi
  8006e1:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8006e4:	89 f0                	mov    %esi,%eax
  8006e6:	c1 f8 1f             	sar    $0x1f,%eax
  8006e9:	89 45 dc             	mov    %eax,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006ec:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8006ef:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
  8006f2:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8006f6:	0f 89 8a 00 00 00    	jns    800786 <vprintfmt+0x356>
				putch('-', putdat);
  8006fc:	83 ec 08             	sub    $0x8,%esp
  8006ff:	53                   	push   %ebx
  800700:	6a 2d                	push   $0x2d
  800702:	ff d7                	call   *%edi
				num = -(long long) num;
  800704:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800707:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80070a:	f7 d8                	neg    %eax
  80070c:	83 d2 00             	adc    $0x0,%edx
  80070f:	f7 da                	neg    %edx
  800711:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800714:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800719:	eb 70                	jmp    80078b <vprintfmt+0x35b>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80071b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80071e:	8d 45 14             	lea    0x14(%ebp),%eax
  800721:	e8 97 fc ff ff       	call   8003bd <getuint>
			base = 10;
  800726:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80072b:	eb 5e                	jmp    80078b <vprintfmt+0x35b>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
  80072d:	83 ec 08             	sub    $0x8,%esp
  800730:	53                   	push   %ebx
  800731:	6a 30                	push   $0x30
  800733:	ff d7                	call   *%edi
			num = getuint(&ap, lflag);
  800735:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800738:	8d 45 14             	lea    0x14(%ebp),%eax
  80073b:	e8 7d fc ff ff       	call   8003bd <getuint>
			base = 8;
			goto number;
  800740:	83 c4 10             	add    $0x10,%esp
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  800743:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800748:	eb 41                	jmp    80078b <vprintfmt+0x35b>
		// pointer
		case 'p':
			putch('0', putdat);
  80074a:	83 ec 08             	sub    $0x8,%esp
  80074d:	53                   	push   %ebx
  80074e:	6a 30                	push   $0x30
  800750:	ff d7                	call   *%edi
			putch('x', putdat);
  800752:	83 c4 08             	add    $0x8,%esp
  800755:	53                   	push   %ebx
  800756:	6a 78                	push   $0x78
  800758:	ff d7                	call   *%edi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80075a:	8b 45 14             	mov    0x14(%ebp),%eax
  80075d:	8d 50 04             	lea    0x4(%eax),%edx
  800760:	89 55 14             	mov    %edx,0x14(%ebp)
			goto number;
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800763:	8b 00                	mov    (%eax),%eax
  800765:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80076a:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80076d:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800772:	eb 17                	jmp    80078b <vprintfmt+0x35b>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800774:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800777:	8d 45 14             	lea    0x14(%ebp),%eax
  80077a:	e8 3e fc ff ff       	call   8003bd <getuint>
			base = 16;
  80077f:	b9 10 00 00 00       	mov    $0x10,%ecx
  800784:	eb 05                	jmp    80078b <vprintfmt+0x35b>
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800786:	b9 0a 00 00 00       	mov    $0xa,%ecx
		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  80078b:	83 ec 0c             	sub    $0xc,%esp
  80078e:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  800792:	56                   	push   %esi
  800793:	ff 75 e4             	pushl  -0x1c(%ebp)
  800796:	51                   	push   %ecx
  800797:	52                   	push   %edx
  800798:	50                   	push   %eax
  800799:	89 da                	mov    %ebx,%edx
  80079b:	89 f8                	mov    %edi,%eax
  80079d:	e8 6b fb ff ff       	call   80030d <printnum>
			break;
  8007a2:	83 c4 20             	add    $0x20,%esp
  8007a5:	e9 9a fc ff ff       	jmp    800444 <vprintfmt+0x14>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007aa:	83 ec 08             	sub    $0x8,%esp
  8007ad:	53                   	push   %ebx
  8007ae:	52                   	push   %edx
  8007af:	ff d7                	call   *%edi
			break;
  8007b1:	83 c4 10             	add    $0x10,%esp
  8007b4:	e9 8b fc ff ff       	jmp    800444 <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007b9:	83 ec 08             	sub    $0x8,%esp
  8007bc:	53                   	push   %ebx
  8007bd:	6a 25                	push   $0x25
  8007bf:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007c1:	83 c4 10             	add    $0x10,%esp
  8007c4:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8007c8:	0f 84 73 fc ff ff    	je     800441 <vprintfmt+0x11>
  8007ce:	4e                   	dec    %esi
  8007cf:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8007d3:	75 f9                	jne    8007ce <vprintfmt+0x39e>
  8007d5:	89 75 10             	mov    %esi,0x10(%ebp)
  8007d8:	e9 67 fc ff ff       	jmp    800444 <vprintfmt+0x14>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8007dd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8007e0:	8d 70 01             	lea    0x1(%eax),%esi
  8007e3:	8a 00                	mov    (%eax),%al
  8007e5:	0f be d0             	movsbl %al,%edx
  8007e8:	85 d2                	test   %edx,%edx
  8007ea:	0f 85 7a fe ff ff    	jne    80066a <vprintfmt+0x23a>
  8007f0:	e9 4f fc ff ff       	jmp    800444 <vprintfmt+0x14>
  8007f5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8007f8:	8d 70 01             	lea    0x1(%eax),%esi
  8007fb:	8a 00                	mov    (%eax),%al
  8007fd:	0f be d0             	movsbl %al,%edx
  800800:	85 d2                	test   %edx,%edx
  800802:	0f 85 6a fe ff ff    	jne    800672 <vprintfmt+0x242>
  800808:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80080b:	e9 77 fe ff ff       	jmp    800687 <vprintfmt+0x257>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800810:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800813:	5b                   	pop    %ebx
  800814:	5e                   	pop    %esi
  800815:	5f                   	pop    %edi
  800816:	5d                   	pop    %ebp
  800817:	c3                   	ret    

00800818 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800818:	55                   	push   %ebp
  800819:	89 e5                	mov    %esp,%ebp
  80081b:	83 ec 18             	sub    $0x18,%esp
  80081e:	8b 45 08             	mov    0x8(%ebp),%eax
  800821:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800824:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800827:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80082b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80082e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800835:	85 c0                	test   %eax,%eax
  800837:	74 26                	je     80085f <vsnprintf+0x47>
  800839:	85 d2                	test   %edx,%edx
  80083b:	7e 29                	jle    800866 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80083d:	ff 75 14             	pushl  0x14(%ebp)
  800840:	ff 75 10             	pushl  0x10(%ebp)
  800843:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800846:	50                   	push   %eax
  800847:	68 f7 03 80 00       	push   $0x8003f7
  80084c:	e8 df fb ff ff       	call   800430 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800851:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800854:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800857:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80085a:	83 c4 10             	add    $0x10,%esp
  80085d:	eb 0c                	jmp    80086b <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80085f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800864:	eb 05                	jmp    80086b <vsnprintf+0x53>
  800866:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80086b:	c9                   	leave  
  80086c:	c3                   	ret    

0080086d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80086d:	55                   	push   %ebp
  80086e:	89 e5                	mov    %esp,%ebp
  800870:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800873:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800876:	50                   	push   %eax
  800877:	ff 75 10             	pushl  0x10(%ebp)
  80087a:	ff 75 0c             	pushl  0xc(%ebp)
  80087d:	ff 75 08             	pushl  0x8(%ebp)
  800880:	e8 93 ff ff ff       	call   800818 <vsnprintf>
	va_end(ap);

	return rc;
}
  800885:	c9                   	leave  
  800886:	c3                   	ret    

00800887 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800887:	55                   	push   %ebp
  800888:	89 e5                	mov    %esp,%ebp
  80088a:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80088d:	80 3a 00             	cmpb   $0x0,(%edx)
  800890:	74 0e                	je     8008a0 <strlen+0x19>
  800892:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800897:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800898:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80089c:	75 f9                	jne    800897 <strlen+0x10>
  80089e:	eb 05                	jmp    8008a5 <strlen+0x1e>
  8008a0:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8008a5:	5d                   	pop    %ebp
  8008a6:	c3                   	ret    

008008a7 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008a7:	55                   	push   %ebp
  8008a8:	89 e5                	mov    %esp,%ebp
  8008aa:	53                   	push   %ebx
  8008ab:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8008ae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008b1:	85 c9                	test   %ecx,%ecx
  8008b3:	74 1a                	je     8008cf <strnlen+0x28>
  8008b5:	80 3b 00             	cmpb   $0x0,(%ebx)
  8008b8:	74 1c                	je     8008d6 <strnlen+0x2f>
  8008ba:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  8008bf:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008c1:	39 ca                	cmp    %ecx,%edx
  8008c3:	74 16                	je     8008db <strnlen+0x34>
  8008c5:	42                   	inc    %edx
  8008c6:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  8008cb:	75 f2                	jne    8008bf <strnlen+0x18>
  8008cd:	eb 0c                	jmp    8008db <strnlen+0x34>
  8008cf:	b8 00 00 00 00       	mov    $0x0,%eax
  8008d4:	eb 05                	jmp    8008db <strnlen+0x34>
  8008d6:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8008db:	5b                   	pop    %ebx
  8008dc:	5d                   	pop    %ebp
  8008dd:	c3                   	ret    

008008de <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008de:	55                   	push   %ebp
  8008df:	89 e5                	mov    %esp,%ebp
  8008e1:	53                   	push   %ebx
  8008e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008e8:	89 c2                	mov    %eax,%edx
  8008ea:	42                   	inc    %edx
  8008eb:	41                   	inc    %ecx
  8008ec:	8a 59 ff             	mov    -0x1(%ecx),%bl
  8008ef:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008f2:	84 db                	test   %bl,%bl
  8008f4:	75 f4                	jne    8008ea <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8008f6:	5b                   	pop    %ebx
  8008f7:	5d                   	pop    %ebp
  8008f8:	c3                   	ret    

008008f9 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008f9:	55                   	push   %ebp
  8008fa:	89 e5                	mov    %esp,%ebp
  8008fc:	53                   	push   %ebx
  8008fd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800900:	53                   	push   %ebx
  800901:	e8 81 ff ff ff       	call   800887 <strlen>
  800906:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800909:	ff 75 0c             	pushl  0xc(%ebp)
  80090c:	01 d8                	add    %ebx,%eax
  80090e:	50                   	push   %eax
  80090f:	e8 ca ff ff ff       	call   8008de <strcpy>
	return dst;
}
  800914:	89 d8                	mov    %ebx,%eax
  800916:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800919:	c9                   	leave  
  80091a:	c3                   	ret    

0080091b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80091b:	55                   	push   %ebp
  80091c:	89 e5                	mov    %esp,%ebp
  80091e:	56                   	push   %esi
  80091f:	53                   	push   %ebx
  800920:	8b 75 08             	mov    0x8(%ebp),%esi
  800923:	8b 55 0c             	mov    0xc(%ebp),%edx
  800926:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800929:	85 db                	test   %ebx,%ebx
  80092b:	74 14                	je     800941 <strncpy+0x26>
  80092d:	01 f3                	add    %esi,%ebx
  80092f:	89 f1                	mov    %esi,%ecx
		*dst++ = *src;
  800931:	41                   	inc    %ecx
  800932:	8a 02                	mov    (%edx),%al
  800934:	88 41 ff             	mov    %al,-0x1(%ecx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800937:	80 3a 01             	cmpb   $0x1,(%edx)
  80093a:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80093d:	39 cb                	cmp    %ecx,%ebx
  80093f:	75 f0                	jne    800931 <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800941:	89 f0                	mov    %esi,%eax
  800943:	5b                   	pop    %ebx
  800944:	5e                   	pop    %esi
  800945:	5d                   	pop    %ebp
  800946:	c3                   	ret    

00800947 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800947:	55                   	push   %ebp
  800948:	89 e5                	mov    %esp,%ebp
  80094a:	53                   	push   %ebx
  80094b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80094e:	8b 45 10             	mov    0x10(%ebp),%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800951:	85 c0                	test   %eax,%eax
  800953:	74 30                	je     800985 <strlcpy+0x3e>
		while (--size > 0 && *src != '\0')
  800955:	48                   	dec    %eax
  800956:	74 20                	je     800978 <strlcpy+0x31>
  800958:	8a 0b                	mov    (%ebx),%cl
  80095a:	84 c9                	test   %cl,%cl
  80095c:	74 1f                	je     80097d <strlcpy+0x36>
  80095e:	8d 53 01             	lea    0x1(%ebx),%edx
  800961:	01 c3                	add    %eax,%ebx
  800963:	8b 45 08             	mov    0x8(%ebp),%eax
			*dst++ = *src++;
  800966:	40                   	inc    %eax
  800967:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80096a:	39 da                	cmp    %ebx,%edx
  80096c:	74 12                	je     800980 <strlcpy+0x39>
  80096e:	42                   	inc    %edx
  80096f:	8a 4a ff             	mov    -0x1(%edx),%cl
  800972:	84 c9                	test   %cl,%cl
  800974:	75 f0                	jne    800966 <strlcpy+0x1f>
  800976:	eb 08                	jmp    800980 <strlcpy+0x39>
  800978:	8b 45 08             	mov    0x8(%ebp),%eax
  80097b:	eb 03                	jmp    800980 <strlcpy+0x39>
  80097d:	8b 45 08             	mov    0x8(%ebp),%eax
			*dst++ = *src++;
		*dst = '\0';
  800980:	c6 00 00             	movb   $0x0,(%eax)
  800983:	eb 03                	jmp    800988 <strlcpy+0x41>
  800985:	8b 45 08             	mov    0x8(%ebp),%eax
	}
	return dst - dst_in;
  800988:	2b 45 08             	sub    0x8(%ebp),%eax
}
  80098b:	5b                   	pop    %ebx
  80098c:	5d                   	pop    %ebp
  80098d:	c3                   	ret    

0080098e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80098e:	55                   	push   %ebp
  80098f:	89 e5                	mov    %esp,%ebp
  800991:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800994:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800997:	8a 01                	mov    (%ecx),%al
  800999:	84 c0                	test   %al,%al
  80099b:	74 10                	je     8009ad <strcmp+0x1f>
  80099d:	3a 02                	cmp    (%edx),%al
  80099f:	75 0c                	jne    8009ad <strcmp+0x1f>
		p++, q++;
  8009a1:	41                   	inc    %ecx
  8009a2:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8009a3:	8a 01                	mov    (%ecx),%al
  8009a5:	84 c0                	test   %al,%al
  8009a7:	74 04                	je     8009ad <strcmp+0x1f>
  8009a9:	3a 02                	cmp    (%edx),%al
  8009ab:	74 f4                	je     8009a1 <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009ad:	0f b6 c0             	movzbl %al,%eax
  8009b0:	0f b6 12             	movzbl (%edx),%edx
  8009b3:	29 d0                	sub    %edx,%eax
}
  8009b5:	5d                   	pop    %ebp
  8009b6:	c3                   	ret    

008009b7 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009b7:	55                   	push   %ebp
  8009b8:	89 e5                	mov    %esp,%ebp
  8009ba:	56                   	push   %esi
  8009bb:	53                   	push   %ebx
  8009bc:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8009bf:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009c2:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  8009c5:	85 f6                	test   %esi,%esi
  8009c7:	74 23                	je     8009ec <strncmp+0x35>
  8009c9:	8a 03                	mov    (%ebx),%al
  8009cb:	84 c0                	test   %al,%al
  8009cd:	74 2b                	je     8009fa <strncmp+0x43>
  8009cf:	3a 02                	cmp    (%edx),%al
  8009d1:	75 27                	jne    8009fa <strncmp+0x43>
  8009d3:	8d 43 01             	lea    0x1(%ebx),%eax
  8009d6:	01 de                	add    %ebx,%esi
		n--, p++, q++;
  8009d8:	89 c3                	mov    %eax,%ebx
  8009da:	42                   	inc    %edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009db:	39 c6                	cmp    %eax,%esi
  8009dd:	74 14                	je     8009f3 <strncmp+0x3c>
  8009df:	8a 08                	mov    (%eax),%cl
  8009e1:	84 c9                	test   %cl,%cl
  8009e3:	74 15                	je     8009fa <strncmp+0x43>
  8009e5:	40                   	inc    %eax
  8009e6:	3a 0a                	cmp    (%edx),%cl
  8009e8:	74 ee                	je     8009d8 <strncmp+0x21>
  8009ea:	eb 0e                	jmp    8009fa <strncmp+0x43>
		n--, p++, q++;
	if (n == 0)
		return 0;
  8009ec:	b8 00 00 00 00       	mov    $0x0,%eax
  8009f1:	eb 0f                	jmp    800a02 <strncmp+0x4b>
  8009f3:	b8 00 00 00 00       	mov    $0x0,%eax
  8009f8:	eb 08                	jmp    800a02 <strncmp+0x4b>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009fa:	0f b6 03             	movzbl (%ebx),%eax
  8009fd:	0f b6 12             	movzbl (%edx),%edx
  800a00:	29 d0                	sub    %edx,%eax
}
  800a02:	5b                   	pop    %ebx
  800a03:	5e                   	pop    %esi
  800a04:	5d                   	pop    %ebp
  800a05:	c3                   	ret    

00800a06 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a06:	55                   	push   %ebp
  800a07:	89 e5                	mov    %esp,%ebp
  800a09:	53                   	push   %ebx
  800a0a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  800a10:	8a 10                	mov    (%eax),%dl
  800a12:	84 d2                	test   %dl,%dl
  800a14:	74 1a                	je     800a30 <strchr+0x2a>
  800a16:	88 d9                	mov    %bl,%cl
		if (*s == c)
  800a18:	38 d3                	cmp    %dl,%bl
  800a1a:	75 06                	jne    800a22 <strchr+0x1c>
  800a1c:	eb 17                	jmp    800a35 <strchr+0x2f>
  800a1e:	38 ca                	cmp    %cl,%dl
  800a20:	74 13                	je     800a35 <strchr+0x2f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a22:	40                   	inc    %eax
  800a23:	8a 10                	mov    (%eax),%dl
  800a25:	84 d2                	test   %dl,%dl
  800a27:	75 f5                	jne    800a1e <strchr+0x18>
		if (*s == c)
			return (char *) s;
	return 0;
  800a29:	b8 00 00 00 00       	mov    $0x0,%eax
  800a2e:	eb 05                	jmp    800a35 <strchr+0x2f>
  800a30:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a35:	5b                   	pop    %ebx
  800a36:	5d                   	pop    %ebp
  800a37:	c3                   	ret    

00800a38 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a38:	55                   	push   %ebp
  800a39:	89 e5                	mov    %esp,%ebp
  800a3b:	53                   	push   %ebx
  800a3c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a3f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  800a42:	8a 10                	mov    (%eax),%dl
  800a44:	84 d2                	test   %dl,%dl
  800a46:	74 13                	je     800a5b <strfind+0x23>
  800a48:	88 d9                	mov    %bl,%cl
		if (*s == c)
  800a4a:	38 d3                	cmp    %dl,%bl
  800a4c:	75 06                	jne    800a54 <strfind+0x1c>
  800a4e:	eb 0b                	jmp    800a5b <strfind+0x23>
  800a50:	38 ca                	cmp    %cl,%dl
  800a52:	74 07                	je     800a5b <strfind+0x23>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a54:	40                   	inc    %eax
  800a55:	8a 10                	mov    (%eax),%dl
  800a57:	84 d2                	test   %dl,%dl
  800a59:	75 f5                	jne    800a50 <strfind+0x18>
		if (*s == c)
			break;
	return (char *) s;
}
  800a5b:	5b                   	pop    %ebx
  800a5c:	5d                   	pop    %ebp
  800a5d:	c3                   	ret    

00800a5e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a5e:	55                   	push   %ebp
  800a5f:	89 e5                	mov    %esp,%ebp
  800a61:	57                   	push   %edi
  800a62:	56                   	push   %esi
  800a63:	53                   	push   %ebx
  800a64:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a67:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a6a:	85 c9                	test   %ecx,%ecx
  800a6c:	74 36                	je     800aa4 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a6e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a74:	75 28                	jne    800a9e <memset+0x40>
  800a76:	f6 c1 03             	test   $0x3,%cl
  800a79:	75 23                	jne    800a9e <memset+0x40>
		c &= 0xFF;
  800a7b:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a7f:	89 d3                	mov    %edx,%ebx
  800a81:	c1 e3 08             	shl    $0x8,%ebx
  800a84:	89 d6                	mov    %edx,%esi
  800a86:	c1 e6 18             	shl    $0x18,%esi
  800a89:	89 d0                	mov    %edx,%eax
  800a8b:	c1 e0 10             	shl    $0x10,%eax
  800a8e:	09 f0                	or     %esi,%eax
  800a90:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800a92:	89 d8                	mov    %ebx,%eax
  800a94:	09 d0                	or     %edx,%eax
  800a96:	c1 e9 02             	shr    $0x2,%ecx
  800a99:	fc                   	cld    
  800a9a:	f3 ab                	rep stos %eax,%es:(%edi)
  800a9c:	eb 06                	jmp    800aa4 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a9e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aa1:	fc                   	cld    
  800aa2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800aa4:	89 f8                	mov    %edi,%eax
  800aa6:	5b                   	pop    %ebx
  800aa7:	5e                   	pop    %esi
  800aa8:	5f                   	pop    %edi
  800aa9:	5d                   	pop    %ebp
  800aaa:	c3                   	ret    

00800aab <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800aab:	55                   	push   %ebp
  800aac:	89 e5                	mov    %esp,%ebp
  800aae:	57                   	push   %edi
  800aaf:	56                   	push   %esi
  800ab0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab3:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ab6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ab9:	39 c6                	cmp    %eax,%esi
  800abb:	73 33                	jae    800af0 <memmove+0x45>
  800abd:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ac0:	39 d0                	cmp    %edx,%eax
  800ac2:	73 2c                	jae    800af0 <memmove+0x45>
		s += n;
		d += n;
  800ac4:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ac7:	89 d6                	mov    %edx,%esi
  800ac9:	09 fe                	or     %edi,%esi
  800acb:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800ad1:	75 13                	jne    800ae6 <memmove+0x3b>
  800ad3:	f6 c1 03             	test   $0x3,%cl
  800ad6:	75 0e                	jne    800ae6 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800ad8:	83 ef 04             	sub    $0x4,%edi
  800adb:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ade:	c1 e9 02             	shr    $0x2,%ecx
  800ae1:	fd                   	std    
  800ae2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ae4:	eb 07                	jmp    800aed <memmove+0x42>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800ae6:	4f                   	dec    %edi
  800ae7:	8d 72 ff             	lea    -0x1(%edx),%esi
  800aea:	fd                   	std    
  800aeb:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800aed:	fc                   	cld    
  800aee:	eb 1d                	jmp    800b0d <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800af0:	89 f2                	mov    %esi,%edx
  800af2:	09 c2                	or     %eax,%edx
  800af4:	f6 c2 03             	test   $0x3,%dl
  800af7:	75 0f                	jne    800b08 <memmove+0x5d>
  800af9:	f6 c1 03             	test   $0x3,%cl
  800afc:	75 0a                	jne    800b08 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
  800afe:	c1 e9 02             	shr    $0x2,%ecx
  800b01:	89 c7                	mov    %eax,%edi
  800b03:	fc                   	cld    
  800b04:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b06:	eb 05                	jmp    800b0d <memmove+0x62>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b08:	89 c7                	mov    %eax,%edi
  800b0a:	fc                   	cld    
  800b0b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b0d:	5e                   	pop    %esi
  800b0e:	5f                   	pop    %edi
  800b0f:	5d                   	pop    %ebp
  800b10:	c3                   	ret    

00800b11 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b11:	55                   	push   %ebp
  800b12:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b14:	ff 75 10             	pushl  0x10(%ebp)
  800b17:	ff 75 0c             	pushl  0xc(%ebp)
  800b1a:	ff 75 08             	pushl  0x8(%ebp)
  800b1d:	e8 89 ff ff ff       	call   800aab <memmove>
}
  800b22:	c9                   	leave  
  800b23:	c3                   	ret    

00800b24 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b24:	55                   	push   %ebp
  800b25:	89 e5                	mov    %esp,%ebp
  800b27:	57                   	push   %edi
  800b28:	56                   	push   %esi
  800b29:	53                   	push   %ebx
  800b2a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800b2d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b30:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b33:	85 c0                	test   %eax,%eax
  800b35:	74 33                	je     800b6a <memcmp+0x46>
  800b37:	8d 78 ff             	lea    -0x1(%eax),%edi
		if (*s1 != *s2)
  800b3a:	8a 13                	mov    (%ebx),%dl
  800b3c:	8a 0e                	mov    (%esi),%cl
  800b3e:	38 ca                	cmp    %cl,%dl
  800b40:	75 13                	jne    800b55 <memcmp+0x31>
  800b42:	b8 00 00 00 00       	mov    $0x0,%eax
  800b47:	eb 16                	jmp    800b5f <memcmp+0x3b>
  800b49:	8a 54 03 01          	mov    0x1(%ebx,%eax,1),%dl
  800b4d:	40                   	inc    %eax
  800b4e:	8a 0c 06             	mov    (%esi,%eax,1),%cl
  800b51:	38 ca                	cmp    %cl,%dl
  800b53:	74 0a                	je     800b5f <memcmp+0x3b>
			return (int) *s1 - (int) *s2;
  800b55:	0f b6 c2             	movzbl %dl,%eax
  800b58:	0f b6 c9             	movzbl %cl,%ecx
  800b5b:	29 c8                	sub    %ecx,%eax
  800b5d:	eb 10                	jmp    800b6f <memcmp+0x4b>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b5f:	39 f8                	cmp    %edi,%eax
  800b61:	75 e6                	jne    800b49 <memcmp+0x25>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b63:	b8 00 00 00 00       	mov    $0x0,%eax
  800b68:	eb 05                	jmp    800b6f <memcmp+0x4b>
  800b6a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b6f:	5b                   	pop    %ebx
  800b70:	5e                   	pop    %esi
  800b71:	5f                   	pop    %edi
  800b72:	5d                   	pop    %ebp
  800b73:	c3                   	ret    

00800b74 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b74:	55                   	push   %ebp
  800b75:	89 e5                	mov    %esp,%ebp
  800b77:	53                   	push   %ebx
  800b78:	8b 55 08             	mov    0x8(%ebp),%edx
	const void *ends = (const char *) s + n;
  800b7b:	89 d0                	mov    %edx,%eax
  800b7d:	03 45 10             	add    0x10(%ebp),%eax
	for (; s < ends; s++)
  800b80:	39 c2                	cmp    %eax,%edx
  800b82:	73 1b                	jae    800b9f <memfind+0x2b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b84:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
  800b88:	0f b6 0a             	movzbl (%edx),%ecx
  800b8b:	39 d9                	cmp    %ebx,%ecx
  800b8d:	75 09                	jne    800b98 <memfind+0x24>
  800b8f:	eb 12                	jmp    800ba3 <memfind+0x2f>
  800b91:	0f b6 0a             	movzbl (%edx),%ecx
  800b94:	39 d9                	cmp    %ebx,%ecx
  800b96:	74 0f                	je     800ba7 <memfind+0x33>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b98:	42                   	inc    %edx
  800b99:	39 d0                	cmp    %edx,%eax
  800b9b:	75 f4                	jne    800b91 <memfind+0x1d>
  800b9d:	eb 0a                	jmp    800ba9 <memfind+0x35>
  800b9f:	89 d0                	mov    %edx,%eax
  800ba1:	eb 06                	jmp    800ba9 <memfind+0x35>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ba3:	89 d0                	mov    %edx,%eax
  800ba5:	eb 02                	jmp    800ba9 <memfind+0x35>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ba7:	89 d0                	mov    %edx,%eax
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ba9:	5b                   	pop    %ebx
  800baa:	5d                   	pop    %ebp
  800bab:	c3                   	ret    

00800bac <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800bac:	55                   	push   %ebp
  800bad:	89 e5                	mov    %esp,%ebp
  800baf:	57                   	push   %edi
  800bb0:	56                   	push   %esi
  800bb1:	53                   	push   %ebx
  800bb2:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bb5:	eb 01                	jmp    800bb8 <strtol+0xc>
		s++;
  800bb7:	41                   	inc    %ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bb8:	8a 01                	mov    (%ecx),%al
  800bba:	3c 20                	cmp    $0x20,%al
  800bbc:	74 f9                	je     800bb7 <strtol+0xb>
  800bbe:	3c 09                	cmp    $0x9,%al
  800bc0:	74 f5                	je     800bb7 <strtol+0xb>
		s++;

	// plus/minus sign
	if (*s == '+')
  800bc2:	3c 2b                	cmp    $0x2b,%al
  800bc4:	75 08                	jne    800bce <strtol+0x22>
		s++;
  800bc6:	41                   	inc    %ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800bc7:	bf 00 00 00 00       	mov    $0x0,%edi
  800bcc:	eb 11                	jmp    800bdf <strtol+0x33>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800bce:	3c 2d                	cmp    $0x2d,%al
  800bd0:	75 08                	jne    800bda <strtol+0x2e>
		s++, neg = 1;
  800bd2:	41                   	inc    %ecx
  800bd3:	bf 01 00 00 00       	mov    $0x1,%edi
  800bd8:	eb 05                	jmp    800bdf <strtol+0x33>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800bda:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bdf:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800be3:	0f 84 87 00 00 00    	je     800c70 <strtol+0xc4>
  800be9:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  800bed:	75 27                	jne    800c16 <strtol+0x6a>
  800bef:	80 39 30             	cmpb   $0x30,(%ecx)
  800bf2:	75 22                	jne    800c16 <strtol+0x6a>
  800bf4:	e9 88 00 00 00       	jmp    800c81 <strtol+0xd5>
		s += 2, base = 16;
  800bf9:	83 c1 02             	add    $0x2,%ecx
  800bfc:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  800c03:	eb 11                	jmp    800c16 <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
  800c05:	41                   	inc    %ecx
  800c06:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  800c0d:	eb 07                	jmp    800c16 <strtol+0x6a>
	else if (base == 0)
		base = 10;
  800c0f:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)
  800c16:	b8 00 00 00 00       	mov    $0x0,%eax

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c1b:	8a 11                	mov    (%ecx),%dl
  800c1d:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800c20:	80 fb 09             	cmp    $0x9,%bl
  800c23:	77 08                	ja     800c2d <strtol+0x81>
			dig = *s - '0';
  800c25:	0f be d2             	movsbl %dl,%edx
  800c28:	83 ea 30             	sub    $0x30,%edx
  800c2b:	eb 22                	jmp    800c4f <strtol+0xa3>
		else if (*s >= 'a' && *s <= 'z')
  800c2d:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c30:	89 f3                	mov    %esi,%ebx
  800c32:	80 fb 19             	cmp    $0x19,%bl
  800c35:	77 08                	ja     800c3f <strtol+0x93>
			dig = *s - 'a' + 10;
  800c37:	0f be d2             	movsbl %dl,%edx
  800c3a:	83 ea 57             	sub    $0x57,%edx
  800c3d:	eb 10                	jmp    800c4f <strtol+0xa3>
		else if (*s >= 'A' && *s <= 'Z')
  800c3f:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c42:	89 f3                	mov    %esi,%ebx
  800c44:	80 fb 19             	cmp    $0x19,%bl
  800c47:	77 14                	ja     800c5d <strtol+0xb1>
			dig = *s - 'A' + 10;
  800c49:	0f be d2             	movsbl %dl,%edx
  800c4c:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800c4f:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c52:	7d 09                	jge    800c5d <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800c54:	41                   	inc    %ecx
  800c55:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c59:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800c5b:	eb be                	jmp    800c1b <strtol+0x6f>

	if (endptr)
  800c5d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c61:	74 05                	je     800c68 <strtol+0xbc>
		*endptr = (char *) s;
  800c63:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c66:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800c68:	85 ff                	test   %edi,%edi
  800c6a:	74 21                	je     800c8d <strtol+0xe1>
  800c6c:	f7 d8                	neg    %eax
  800c6e:	eb 1d                	jmp    800c8d <strtol+0xe1>
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c70:	80 39 30             	cmpb   $0x30,(%ecx)
  800c73:	75 9a                	jne    800c0f <strtol+0x63>
  800c75:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c79:	0f 84 7a ff ff ff    	je     800bf9 <strtol+0x4d>
  800c7f:	eb 84                	jmp    800c05 <strtol+0x59>
  800c81:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c85:	0f 84 6e ff ff ff    	je     800bf9 <strtol+0x4d>
  800c8b:	eb 89                	jmp    800c16 <strtol+0x6a>
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
}
  800c8d:	5b                   	pop    %ebx
  800c8e:	5e                   	pop    %esi
  800c8f:	5f                   	pop    %edi
  800c90:	5d                   	pop    %ebp
  800c91:	c3                   	ret    

00800c92 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c92:	55                   	push   %ebp
  800c93:	89 e5                	mov    %esp,%ebp
  800c95:	57                   	push   %edi
  800c96:	56                   	push   %esi
  800c97:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c98:	b8 00 00 00 00       	mov    $0x0,%eax
  800c9d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca3:	89 c3                	mov    %eax,%ebx
  800ca5:	89 c7                	mov    %eax,%edi
  800ca7:	89 c6                	mov    %eax,%esi
  800ca9:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800cab:	5b                   	pop    %ebx
  800cac:	5e                   	pop    %esi
  800cad:	5f                   	pop    %edi
  800cae:	5d                   	pop    %ebp
  800caf:	c3                   	ret    

00800cb0 <sys_cgetc>:

int
sys_cgetc(void)
{
  800cb0:	55                   	push   %ebp
  800cb1:	89 e5                	mov    %esp,%ebp
  800cb3:	57                   	push   %edi
  800cb4:	56                   	push   %esi
  800cb5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cb6:	ba 00 00 00 00       	mov    $0x0,%edx
  800cbb:	b8 01 00 00 00       	mov    $0x1,%eax
  800cc0:	89 d1                	mov    %edx,%ecx
  800cc2:	89 d3                	mov    %edx,%ebx
  800cc4:	89 d7                	mov    %edx,%edi
  800cc6:	89 d6                	mov    %edx,%esi
  800cc8:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800cca:	5b                   	pop    %ebx
  800ccb:	5e                   	pop    %esi
  800ccc:	5f                   	pop    %edi
  800ccd:	5d                   	pop    %ebp
  800cce:	c3                   	ret    

00800ccf <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ccf:	55                   	push   %ebp
  800cd0:	89 e5                	mov    %esp,%ebp
  800cd2:	57                   	push   %edi
  800cd3:	56                   	push   %esi
  800cd4:	53                   	push   %ebx
  800cd5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cd8:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cdd:	b8 03 00 00 00       	mov    $0x3,%eax
  800ce2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce5:	89 cb                	mov    %ecx,%ebx
  800ce7:	89 cf                	mov    %ecx,%edi
  800ce9:	89 ce                	mov    %ecx,%esi
  800ceb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ced:	85 c0                	test   %eax,%eax
  800cef:	7e 17                	jle    800d08 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cf1:	83 ec 0c             	sub    $0xc,%esp
  800cf4:	50                   	push   %eax
  800cf5:	6a 03                	push   $0x3
  800cf7:	68 1f 28 80 00       	push   $0x80281f
  800cfc:	6a 23                	push   $0x23
  800cfe:	68 3c 28 80 00       	push   $0x80283c
  800d03:	e8 19 f5 ff ff       	call   800221 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d08:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d0b:	5b                   	pop    %ebx
  800d0c:	5e                   	pop    %esi
  800d0d:	5f                   	pop    %edi
  800d0e:	5d                   	pop    %ebp
  800d0f:	c3                   	ret    

00800d10 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d10:	55                   	push   %ebp
  800d11:	89 e5                	mov    %esp,%ebp
  800d13:	57                   	push   %edi
  800d14:	56                   	push   %esi
  800d15:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d16:	ba 00 00 00 00       	mov    $0x0,%edx
  800d1b:	b8 02 00 00 00       	mov    $0x2,%eax
  800d20:	89 d1                	mov    %edx,%ecx
  800d22:	89 d3                	mov    %edx,%ebx
  800d24:	89 d7                	mov    %edx,%edi
  800d26:	89 d6                	mov    %edx,%esi
  800d28:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d2a:	5b                   	pop    %ebx
  800d2b:	5e                   	pop    %esi
  800d2c:	5f                   	pop    %edi
  800d2d:	5d                   	pop    %ebp
  800d2e:	c3                   	ret    

00800d2f <sys_yield>:

void
sys_yield(void)
{
  800d2f:	55                   	push   %ebp
  800d30:	89 e5                	mov    %esp,%ebp
  800d32:	57                   	push   %edi
  800d33:	56                   	push   %esi
  800d34:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d35:	ba 00 00 00 00       	mov    $0x0,%edx
  800d3a:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d3f:	89 d1                	mov    %edx,%ecx
  800d41:	89 d3                	mov    %edx,%ebx
  800d43:	89 d7                	mov    %edx,%edi
  800d45:	89 d6                	mov    %edx,%esi
  800d47:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d49:	5b                   	pop    %ebx
  800d4a:	5e                   	pop    %esi
  800d4b:	5f                   	pop    %edi
  800d4c:	5d                   	pop    %ebp
  800d4d:	c3                   	ret    

00800d4e <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d4e:	55                   	push   %ebp
  800d4f:	89 e5                	mov    %esp,%ebp
  800d51:	57                   	push   %edi
  800d52:	56                   	push   %esi
  800d53:	53                   	push   %ebx
  800d54:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d57:	be 00 00 00 00       	mov    $0x0,%esi
  800d5c:	b8 04 00 00 00       	mov    $0x4,%eax
  800d61:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d64:	8b 55 08             	mov    0x8(%ebp),%edx
  800d67:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d6a:	89 f7                	mov    %esi,%edi
  800d6c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d6e:	85 c0                	test   %eax,%eax
  800d70:	7e 17                	jle    800d89 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d72:	83 ec 0c             	sub    $0xc,%esp
  800d75:	50                   	push   %eax
  800d76:	6a 04                	push   $0x4
  800d78:	68 1f 28 80 00       	push   $0x80281f
  800d7d:	6a 23                	push   $0x23
  800d7f:	68 3c 28 80 00       	push   $0x80283c
  800d84:	e8 98 f4 ff ff       	call   800221 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d89:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d8c:	5b                   	pop    %ebx
  800d8d:	5e                   	pop    %esi
  800d8e:	5f                   	pop    %edi
  800d8f:	5d                   	pop    %ebp
  800d90:	c3                   	ret    

00800d91 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d91:	55                   	push   %ebp
  800d92:	89 e5                	mov    %esp,%ebp
  800d94:	57                   	push   %edi
  800d95:	56                   	push   %esi
  800d96:	53                   	push   %ebx
  800d97:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d9a:	b8 05 00 00 00       	mov    $0x5,%eax
  800d9f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800da2:	8b 55 08             	mov    0x8(%ebp),%edx
  800da5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800da8:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dab:	8b 75 18             	mov    0x18(%ebp),%esi
  800dae:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800db0:	85 c0                	test   %eax,%eax
  800db2:	7e 17                	jle    800dcb <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800db4:	83 ec 0c             	sub    $0xc,%esp
  800db7:	50                   	push   %eax
  800db8:	6a 05                	push   $0x5
  800dba:	68 1f 28 80 00       	push   $0x80281f
  800dbf:	6a 23                	push   $0x23
  800dc1:	68 3c 28 80 00       	push   $0x80283c
  800dc6:	e8 56 f4 ff ff       	call   800221 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800dcb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dce:	5b                   	pop    %ebx
  800dcf:	5e                   	pop    %esi
  800dd0:	5f                   	pop    %edi
  800dd1:	5d                   	pop    %ebp
  800dd2:	c3                   	ret    

00800dd3 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800dd3:	55                   	push   %ebp
  800dd4:	89 e5                	mov    %esp,%ebp
  800dd6:	57                   	push   %edi
  800dd7:	56                   	push   %esi
  800dd8:	53                   	push   %ebx
  800dd9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ddc:	bb 00 00 00 00       	mov    $0x0,%ebx
  800de1:	b8 06 00 00 00       	mov    $0x6,%eax
  800de6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800de9:	8b 55 08             	mov    0x8(%ebp),%edx
  800dec:	89 df                	mov    %ebx,%edi
  800dee:	89 de                	mov    %ebx,%esi
  800df0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800df2:	85 c0                	test   %eax,%eax
  800df4:	7e 17                	jle    800e0d <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800df6:	83 ec 0c             	sub    $0xc,%esp
  800df9:	50                   	push   %eax
  800dfa:	6a 06                	push   $0x6
  800dfc:	68 1f 28 80 00       	push   $0x80281f
  800e01:	6a 23                	push   $0x23
  800e03:	68 3c 28 80 00       	push   $0x80283c
  800e08:	e8 14 f4 ff ff       	call   800221 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e0d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e10:	5b                   	pop    %ebx
  800e11:	5e                   	pop    %esi
  800e12:	5f                   	pop    %edi
  800e13:	5d                   	pop    %ebp
  800e14:	c3                   	ret    

00800e15 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e15:	55                   	push   %ebp
  800e16:	89 e5                	mov    %esp,%ebp
  800e18:	57                   	push   %edi
  800e19:	56                   	push   %esi
  800e1a:	53                   	push   %ebx
  800e1b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e1e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e23:	b8 08 00 00 00       	mov    $0x8,%eax
  800e28:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e2b:	8b 55 08             	mov    0x8(%ebp),%edx
  800e2e:	89 df                	mov    %ebx,%edi
  800e30:	89 de                	mov    %ebx,%esi
  800e32:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e34:	85 c0                	test   %eax,%eax
  800e36:	7e 17                	jle    800e4f <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e38:	83 ec 0c             	sub    $0xc,%esp
  800e3b:	50                   	push   %eax
  800e3c:	6a 08                	push   $0x8
  800e3e:	68 1f 28 80 00       	push   $0x80281f
  800e43:	6a 23                	push   $0x23
  800e45:	68 3c 28 80 00       	push   $0x80283c
  800e4a:	e8 d2 f3 ff ff       	call   800221 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e4f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e52:	5b                   	pop    %ebx
  800e53:	5e                   	pop    %esi
  800e54:	5f                   	pop    %edi
  800e55:	5d                   	pop    %ebp
  800e56:	c3                   	ret    

00800e57 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e57:	55                   	push   %ebp
  800e58:	89 e5                	mov    %esp,%ebp
  800e5a:	57                   	push   %edi
  800e5b:	56                   	push   %esi
  800e5c:	53                   	push   %ebx
  800e5d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e60:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e65:	b8 09 00 00 00       	mov    $0x9,%eax
  800e6a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e6d:	8b 55 08             	mov    0x8(%ebp),%edx
  800e70:	89 df                	mov    %ebx,%edi
  800e72:	89 de                	mov    %ebx,%esi
  800e74:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e76:	85 c0                	test   %eax,%eax
  800e78:	7e 17                	jle    800e91 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e7a:	83 ec 0c             	sub    $0xc,%esp
  800e7d:	50                   	push   %eax
  800e7e:	6a 09                	push   $0x9
  800e80:	68 1f 28 80 00       	push   $0x80281f
  800e85:	6a 23                	push   $0x23
  800e87:	68 3c 28 80 00       	push   $0x80283c
  800e8c:	e8 90 f3 ff ff       	call   800221 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e91:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e94:	5b                   	pop    %ebx
  800e95:	5e                   	pop    %esi
  800e96:	5f                   	pop    %edi
  800e97:	5d                   	pop    %ebp
  800e98:	c3                   	ret    

00800e99 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e99:	55                   	push   %ebp
  800e9a:	89 e5                	mov    %esp,%ebp
  800e9c:	57                   	push   %edi
  800e9d:	56                   	push   %esi
  800e9e:	53                   	push   %ebx
  800e9f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ea2:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ea7:	b8 0a 00 00 00       	mov    $0xa,%eax
  800eac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eaf:	8b 55 08             	mov    0x8(%ebp),%edx
  800eb2:	89 df                	mov    %ebx,%edi
  800eb4:	89 de                	mov    %ebx,%esi
  800eb6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800eb8:	85 c0                	test   %eax,%eax
  800eba:	7e 17                	jle    800ed3 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ebc:	83 ec 0c             	sub    $0xc,%esp
  800ebf:	50                   	push   %eax
  800ec0:	6a 0a                	push   $0xa
  800ec2:	68 1f 28 80 00       	push   $0x80281f
  800ec7:	6a 23                	push   $0x23
  800ec9:	68 3c 28 80 00       	push   $0x80283c
  800ece:	e8 4e f3 ff ff       	call   800221 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ed3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ed6:	5b                   	pop    %ebx
  800ed7:	5e                   	pop    %esi
  800ed8:	5f                   	pop    %edi
  800ed9:	5d                   	pop    %ebp
  800eda:	c3                   	ret    

00800edb <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800edb:	55                   	push   %ebp
  800edc:	89 e5                	mov    %esp,%ebp
  800ede:	57                   	push   %edi
  800edf:	56                   	push   %esi
  800ee0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ee1:	be 00 00 00 00       	mov    $0x0,%esi
  800ee6:	b8 0c 00 00 00       	mov    $0xc,%eax
  800eeb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eee:	8b 55 08             	mov    0x8(%ebp),%edx
  800ef1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ef4:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ef7:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ef9:	5b                   	pop    %ebx
  800efa:	5e                   	pop    %esi
  800efb:	5f                   	pop    %edi
  800efc:	5d                   	pop    %ebp
  800efd:	c3                   	ret    

00800efe <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800efe:	55                   	push   %ebp
  800eff:	89 e5                	mov    %esp,%ebp
  800f01:	57                   	push   %edi
  800f02:	56                   	push   %esi
  800f03:	53                   	push   %ebx
  800f04:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f07:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f0c:	b8 0d 00 00 00       	mov    $0xd,%eax
  800f11:	8b 55 08             	mov    0x8(%ebp),%edx
  800f14:	89 cb                	mov    %ecx,%ebx
  800f16:	89 cf                	mov    %ecx,%edi
  800f18:	89 ce                	mov    %ecx,%esi
  800f1a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f1c:	85 c0                	test   %eax,%eax
  800f1e:	7e 17                	jle    800f37 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f20:	83 ec 0c             	sub    $0xc,%esp
  800f23:	50                   	push   %eax
  800f24:	6a 0d                	push   $0xd
  800f26:	68 1f 28 80 00       	push   $0x80281f
  800f2b:	6a 23                	push   $0x23
  800f2d:	68 3c 28 80 00       	push   $0x80283c
  800f32:	e8 ea f2 ff ff       	call   800221 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f37:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f3a:	5b                   	pop    %ebx
  800f3b:	5e                   	pop    %esi
  800f3c:	5f                   	pop    %edi
  800f3d:	5d                   	pop    %ebp
  800f3e:	c3                   	ret    

00800f3f <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800f3f:	55                   	push   %ebp
  800f40:	89 e5                	mov    %esp,%ebp
  800f42:	56                   	push   %esi
  800f43:	53                   	push   %ebx
  800f44:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800f47:	8b 18                	mov    (%eax),%ebx
	// copy-on-write page.  If not, panic.
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).
	
	if((err & FEC_WR) == 0){
  800f49:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800f4d:	75 14                	jne    800f63 <pgfault+0x24>
		panic("pgfault not cause by write \n");
  800f4f:	83 ec 04             	sub    $0x4,%esp
  800f52:	68 4a 28 80 00       	push   $0x80284a
  800f57:	6a 1c                	push   $0x1c
  800f59:	68 67 28 80 00       	push   $0x802867
  800f5e:	e8 be f2 ff ff       	call   800221 <_panic>
	}
 
	if ((uvpt[PGNUM(addr)] & PTE_COW) == 0) 
  800f63:	89 d8                	mov    %ebx,%eax
  800f65:	c1 e8 0c             	shr    $0xc,%eax
  800f68:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f6f:	f6 c4 08             	test   $0x8,%ah
  800f72:	75 14                	jne    800f88 <pgfault+0x49>
    {
        panic("pgfault not cause by COW \n");
  800f74:	83 ec 04             	sub    $0x4,%esp
  800f77:	68 72 28 80 00       	push   $0x802872
  800f7c:	6a 21                	push   $0x21
  800f7e:	68 67 28 80 00       	push   $0x802867
  800f83:	e8 99 f2 ff ff       	call   800221 <_panic>
	// copy the data from the old page to the new page, then move the new
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.
	envid_t eid = sys_getenvid();
  800f88:	e8 83 fd ff ff       	call   800d10 <sys_getenvid>
  800f8d:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(eid,(void*)PFTEMP,PTE_P|PTE_W|PTE_U)) < 0)
  800f8f:	83 ec 04             	sub    $0x4,%esp
  800f92:	6a 07                	push   $0x7
  800f94:	68 00 f0 7f 00       	push   $0x7ff000
  800f99:	50                   	push   %eax
  800f9a:	e8 af fd ff ff       	call   800d4e <sys_page_alloc>
  800f9f:	83 c4 10             	add    $0x10,%esp
  800fa2:	85 c0                	test   %eax,%eax
  800fa4:	79 14                	jns    800fba <pgfault+0x7b>
		panic("page alloction failed.\n");
  800fa6:	83 ec 04             	sub    $0x4,%esp
  800fa9:	68 8d 28 80 00       	push   $0x80288d
  800fae:	6a 2d                	push   $0x2d
  800fb0:	68 67 28 80 00       	push   $0x802867
  800fb5:	e8 67 f2 ff ff       	call   800221 <_panic>
	addr = ROUNDDOWN(addr,PGSIZE);
  800fba:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memmove(PFTEMP,addr,PGSIZE);
  800fc0:	83 ec 04             	sub    $0x4,%esp
  800fc3:	68 00 10 00 00       	push   $0x1000
  800fc8:	53                   	push   %ebx
  800fc9:	68 00 f0 7f 00       	push   $0x7ff000
  800fce:	e8 d8 fa ff ff       	call   800aab <memmove>
	if ((r = sys_page_map(eid, PFTEMP, eid, addr, PTE_P | PTE_W |PTE_U)) < 0)
  800fd3:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800fda:	53                   	push   %ebx
  800fdb:	56                   	push   %esi
  800fdc:	68 00 f0 7f 00       	push   $0x7ff000
  800fe1:	56                   	push   %esi
  800fe2:	e8 aa fd ff ff       	call   800d91 <sys_page_map>
  800fe7:	83 c4 20             	add    $0x20,%esp
  800fea:	85 c0                	test   %eax,%eax
  800fec:	79 12                	jns    801000 <pgfault+0xc1>
        panic("pgfault: page map failed %e\n", r);
  800fee:	50                   	push   %eax
  800fef:	68 a5 28 80 00       	push   $0x8028a5
  800ff4:	6a 31                	push   $0x31
  800ff6:	68 67 28 80 00       	push   $0x802867
  800ffb:	e8 21 f2 ff ff       	call   800221 <_panic>
	if ((r = sys_page_unmap(eid, PFTEMP)) < 0)
  801000:	83 ec 08             	sub    $0x8,%esp
  801003:	68 00 f0 7f 00       	push   $0x7ff000
  801008:	56                   	push   %esi
  801009:	e8 c5 fd ff ff       	call   800dd3 <sys_page_unmap>
  80100e:	83 c4 10             	add    $0x10,%esp
  801011:	85 c0                	test   %eax,%eax
  801013:	79 12                	jns    801027 <pgfault+0xe8>
        panic("pgfault: page unmap failed %e\n", r);
  801015:	50                   	push   %eax
  801016:	68 14 29 80 00       	push   $0x802914
  80101b:	6a 33                	push   $0x33
  80101d:	68 67 28 80 00       	push   $0x802867
  801022:	e8 fa f1 ff ff       	call   800221 <_panic>
	// LAB 4: Your code here.

	// panic("pgfault not implemented");
}
  801027:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80102a:	5b                   	pop    %ebx
  80102b:	5e                   	pop    %esi
  80102c:	5d                   	pop    %ebp
  80102d:	c3                   	ret    

0080102e <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  80102e:	55                   	push   %ebp
  80102f:	89 e5                	mov    %esp,%ebp
  801031:	57                   	push   %edi
  801032:	56                   	push   %esi
  801033:	53                   	push   %ebx
  801034:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	struct PageInfo* pg = NULL;
	set_pgfault_handler(pgfault);
  801037:	68 3f 0f 80 00       	push   $0x800f3f
  80103c:	e8 ed 0e 00 00       	call   801f2e <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801041:	b8 07 00 00 00       	mov    $0x7,%eax
  801046:	cd 30                	int    $0x30
  801048:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80104b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t eid = sys_exofork();
	if (eid < 0) panic("fork fault.\n");
  80104e:	83 c4 10             	add    $0x10,%esp
  801051:	85 c0                	test   %eax,%eax
  801053:	79 14                	jns    801069 <fork+0x3b>
  801055:	83 ec 04             	sub    $0x4,%esp
  801058:	68 c2 28 80 00       	push   $0x8028c2
  80105d:	6a 71                	push   $0x71
  80105f:	68 67 28 80 00       	push   $0x802867
  801064:	e8 b8 f1 ff ff       	call   800221 <_panic>
	if (eid == 0){
  801069:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80106d:	75 25                	jne    801094 <fork+0x66>
		thisenv = &envs[ENVX(sys_getenvid())];
  80106f:	e8 9c fc ff ff       	call   800d10 <sys_getenvid>
  801074:	25 ff 03 00 00       	and    $0x3ff,%eax
  801079:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801080:	c1 e0 07             	shl    $0x7,%eax
  801083:	29 d0                	sub    %edx,%eax
  801085:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80108a:	a3 20 44 80 00       	mov    %eax,0x804420
		return eid;
  80108f:	e9 61 01 00 00       	jmp    8011f5 <fork+0x1c7>
  801094:	bb 00 00 80 00       	mov    $0x800000,%ebx
	}
	// copy something to the child page.
	for (uintptr_t i = UTEXT;i <= USTACKTOP;i += PGSIZE){
		if (uvpd[PDX(i)] & PTE_P && (uvpt[PGNUM(i)] & PTE_P)){
  801099:	89 d8                	mov    %ebx,%eax
  80109b:	c1 e8 16             	shr    $0x16,%eax
  80109e:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010a5:	a8 01                	test   $0x1,%al
  8010a7:	74 52                	je     8010fb <fork+0xcd>
  8010a9:	89 de                	mov    %ebx,%esi
  8010ab:	c1 ee 0c             	shr    $0xc,%esi
  8010ae:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8010b5:	a8 01                	test   $0x1,%al
  8010b7:	74 42                	je     8010fb <fork+0xcd>
duppage(envid_t envid, unsigned pn)
{
	int r;

	// LAB 4: Your code here.
	envid_t myenvid = sys_getenvid();
  8010b9:	e8 52 fc ff ff       	call   800d10 <sys_getenvid>
  8010be:	89 c7                	mov    %eax,%edi
	pte_t pte = uvpt[pn];
  8010c0:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
	int perm = PTE_U | PTE_P;
	if(pte & PTE_W || pte & PTE_COW)
  8010c7:	a9 02 08 00 00       	test   $0x802,%eax
  8010cc:	0f 85 de 00 00 00    	jne    8011b0 <fork+0x182>
  8010d2:	e9 fb 00 00 00       	jmp    8011d2 <fork+0x1a4>
		perm |= PTE_COW;
	if((r = sys_page_map(myenvid,(void*)(pn*PGSIZE),envid,(void*)(pn*PGSIZE),perm))<0){
		panic("duppage fault :%e\n",r);
  8010d7:	50                   	push   %eax
  8010d8:	68 cf 28 80 00       	push   $0x8028cf
  8010dd:	6a 50                	push   $0x50
  8010df:	68 67 28 80 00       	push   $0x802867
  8010e4:	e8 38 f1 ff ff       	call   800221 <_panic>
	}
	if(perm & PTE_COW){
		if((r = sys_page_map(myenvid,(void*)(pn*PGSIZE),myenvid,(void*)(pn*PGSIZE),perm))<0)
			panic("duppage fault :%e\n",r);
  8010e9:	50                   	push   %eax
  8010ea:	68 cf 28 80 00       	push   $0x8028cf
  8010ef:	6a 54                	push   $0x54
  8010f1:	68 67 28 80 00       	push   $0x802867
  8010f6:	e8 26 f1 ff ff       	call   800221 <_panic>
	if (eid == 0){
		thisenv = &envs[ENVX(sys_getenvid())];
		return eid;
	}
	// copy something to the child page.
	for (uintptr_t i = UTEXT;i <= USTACKTOP;i += PGSIZE){
  8010fb:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801101:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  801107:	75 90                	jne    801099 <fork+0x6b>
		if (uvpd[PDX(i)] & PTE_P && (uvpt[PGNUM(i)] & PTE_P)){
			duppage(eid,PGNUM(i));
		}
	}
	int r = sys_page_alloc(eid,(void*)(UXSTACKTOP-PGSIZE),PTE_U|PTE_P|PTE_W);
  801109:	83 ec 04             	sub    $0x4,%esp
  80110c:	6a 07                	push   $0x7
  80110e:	68 00 f0 bf ee       	push   $0xeebff000
  801113:	ff 75 e0             	pushl  -0x20(%ebp)
  801116:	e8 33 fc ff ff       	call   800d4e <sys_page_alloc>
	if (r < 0) panic("fork fault.\n");
  80111b:	83 c4 10             	add    $0x10,%esp
  80111e:	85 c0                	test   %eax,%eax
  801120:	79 14                	jns    801136 <fork+0x108>
  801122:	83 ec 04             	sub    $0x4,%esp
  801125:	68 c2 28 80 00       	push   $0x8028c2
  80112a:	6a 7d                	push   $0x7d
  80112c:	68 67 28 80 00       	push   $0x802867
  801131:	e8 eb f0 ff ff       	call   800221 <_panic>

	extern void _pgfault_upcall();
    r = sys_env_set_pgfault_upcall(eid, _pgfault_upcall);
  801136:	83 ec 08             	sub    $0x8,%esp
  801139:	68 a6 1f 80 00       	push   $0x801fa6
  80113e:	ff 75 e0             	pushl  -0x20(%ebp)
  801141:	e8 53 fd ff ff       	call   800e99 <sys_env_set_pgfault_upcall>
    if (r < 0) panic("fork fault 3\n");
  801146:	83 c4 10             	add    $0x10,%esp
  801149:	85 c0                	test   %eax,%eax
  80114b:	79 17                	jns    801164 <fork+0x136>
  80114d:	83 ec 04             	sub    $0x4,%esp
  801150:	68 e2 28 80 00       	push   $0x8028e2
  801155:	68 81 00 00 00       	push   $0x81
  80115a:	68 67 28 80 00       	push   $0x802867
  80115f:	e8 bd f0 ff ff       	call   800221 <_panic>

	if ((r = sys_env_set_status(eid, ENV_RUNNABLE)) < 0)
  801164:	83 ec 08             	sub    $0x8,%esp
  801167:	6a 02                	push   $0x2
  801169:	ff 75 e0             	pushl  -0x20(%ebp)
  80116c:	e8 a4 fc ff ff       	call   800e15 <sys_env_set_status>
  801171:	83 c4 10             	add    $0x10,%esp
  801174:	85 c0                	test   %eax,%eax
  801176:	79 7d                	jns    8011f5 <fork+0x1c7>
        panic("fork fault 4\n");
  801178:	83 ec 04             	sub    $0x4,%esp
  80117b:	68 f0 28 80 00       	push   $0x8028f0
  801180:	68 84 00 00 00       	push   $0x84
  801185:	68 67 28 80 00       	push   $0x802867
  80118a:	e8 92 f0 ff ff       	call   800221 <_panic>
		perm |= PTE_COW;
	if((r = sys_page_map(myenvid,(void*)(pn*PGSIZE),envid,(void*)(pn*PGSIZE),perm))<0){
		panic("duppage fault :%e\n",r);
	}
	if(perm & PTE_COW){
		if((r = sys_page_map(myenvid,(void*)(pn*PGSIZE),myenvid,(void*)(pn*PGSIZE),perm))<0)
  80118f:	83 ec 0c             	sub    $0xc,%esp
  801192:	68 05 08 00 00       	push   $0x805
  801197:	56                   	push   %esi
  801198:	57                   	push   %edi
  801199:	56                   	push   %esi
  80119a:	57                   	push   %edi
  80119b:	e8 f1 fb ff ff       	call   800d91 <sys_page_map>
  8011a0:	83 c4 20             	add    $0x20,%esp
  8011a3:	85 c0                	test   %eax,%eax
  8011a5:	0f 89 50 ff ff ff    	jns    8010fb <fork+0xcd>
  8011ab:	e9 39 ff ff ff       	jmp    8010e9 <fork+0xbb>
	envid_t myenvid = sys_getenvid();
	pte_t pte = uvpt[pn];
	int perm = PTE_U | PTE_P;
	if(pte & PTE_W || pte & PTE_COW)
		perm |= PTE_COW;
	if((r = sys_page_map(myenvid,(void*)(pn*PGSIZE),envid,(void*)(pn*PGSIZE),perm))<0){
  8011b0:	c1 e6 0c             	shl    $0xc,%esi
  8011b3:	83 ec 0c             	sub    $0xc,%esp
  8011b6:	68 05 08 00 00       	push   $0x805
  8011bb:	56                   	push   %esi
  8011bc:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011bf:	56                   	push   %esi
  8011c0:	57                   	push   %edi
  8011c1:	e8 cb fb ff ff       	call   800d91 <sys_page_map>
  8011c6:	83 c4 20             	add    $0x20,%esp
  8011c9:	85 c0                	test   %eax,%eax
  8011cb:	79 c2                	jns    80118f <fork+0x161>
  8011cd:	e9 05 ff ff ff       	jmp    8010d7 <fork+0xa9>
  8011d2:	c1 e6 0c             	shl    $0xc,%esi
  8011d5:	83 ec 0c             	sub    $0xc,%esp
  8011d8:	6a 05                	push   $0x5
  8011da:	56                   	push   %esi
  8011db:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011de:	56                   	push   %esi
  8011df:	57                   	push   %edi
  8011e0:	e8 ac fb ff ff       	call   800d91 <sys_page_map>
  8011e5:	83 c4 20             	add    $0x20,%esp
  8011e8:	85 c0                	test   %eax,%eax
  8011ea:	0f 89 0b ff ff ff    	jns    8010fb <fork+0xcd>
  8011f0:	e9 e2 fe ff ff       	jmp    8010d7 <fork+0xa9>
    if (r < 0) panic("fork fault 3\n");

	if ((r = sys_env_set_status(eid, ENV_RUNNABLE)) < 0)
        panic("fork fault 4\n");
    return eid;
}
  8011f5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8011f8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011fb:	5b                   	pop    %ebx
  8011fc:	5e                   	pop    %esi
  8011fd:	5f                   	pop    %edi
  8011fe:	5d                   	pop    %ebp
  8011ff:	c3                   	ret    

00801200 <sfork>:

// Challenge!
int
sfork(void)
{
  801200:	55                   	push   %ebp
  801201:	89 e5                	mov    %esp,%ebp
  801203:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801206:	68 fe 28 80 00       	push   $0x8028fe
  80120b:	68 8c 00 00 00       	push   $0x8c
  801210:	68 67 28 80 00       	push   $0x802867
  801215:	e8 07 f0 ff ff       	call   800221 <_panic>

0080121a <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80121a:	55                   	push   %ebp
  80121b:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80121d:	8b 45 08             	mov    0x8(%ebp),%eax
  801220:	05 00 00 00 30       	add    $0x30000000,%eax
  801225:	c1 e8 0c             	shr    $0xc,%eax
}
  801228:	5d                   	pop    %ebp
  801229:	c3                   	ret    

0080122a <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80122a:	55                   	push   %ebp
  80122b:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80122d:	8b 45 08             	mov    0x8(%ebp),%eax
  801230:	05 00 00 00 30       	add    $0x30000000,%eax
  801235:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80123a:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80123f:	5d                   	pop    %ebp
  801240:	c3                   	ret    

00801241 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801241:	55                   	push   %ebp
  801242:	89 e5                	mov    %esp,%ebp
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801244:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  801249:	a8 01                	test   $0x1,%al
  80124b:	74 34                	je     801281 <fd_alloc+0x40>
  80124d:	a1 00 00 74 ef       	mov    0xef740000,%eax
  801252:	a8 01                	test   $0x1,%al
  801254:	74 32                	je     801288 <fd_alloc+0x47>
  801256:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  80125b:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80125d:	89 c2                	mov    %eax,%edx
  80125f:	c1 ea 16             	shr    $0x16,%edx
  801262:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801269:	f6 c2 01             	test   $0x1,%dl
  80126c:	74 1f                	je     80128d <fd_alloc+0x4c>
  80126e:	89 c2                	mov    %eax,%edx
  801270:	c1 ea 0c             	shr    $0xc,%edx
  801273:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80127a:	f6 c2 01             	test   $0x1,%dl
  80127d:	75 1a                	jne    801299 <fd_alloc+0x58>
  80127f:	eb 0c                	jmp    80128d <fd_alloc+0x4c>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  801281:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  801286:	eb 05                	jmp    80128d <fd_alloc+0x4c>
  801288:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  80128d:	8b 45 08             	mov    0x8(%ebp),%eax
  801290:	89 08                	mov    %ecx,(%eax)
			return 0;
  801292:	b8 00 00 00 00       	mov    $0x0,%eax
  801297:	eb 1a                	jmp    8012b3 <fd_alloc+0x72>
  801299:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80129e:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8012a3:	75 b6                	jne    80125b <fd_alloc+0x1a>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8012a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8012a8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  8012ae:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8012b3:	5d                   	pop    %ebp
  8012b4:	c3                   	ret    

008012b5 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8012b5:	55                   	push   %ebp
  8012b6:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8012b8:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
  8012bc:	77 39                	ja     8012f7 <fd_lookup+0x42>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8012be:	8b 45 08             	mov    0x8(%ebp),%eax
  8012c1:	c1 e0 0c             	shl    $0xc,%eax
  8012c4:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8012c9:	89 c2                	mov    %eax,%edx
  8012cb:	c1 ea 16             	shr    $0x16,%edx
  8012ce:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012d5:	f6 c2 01             	test   $0x1,%dl
  8012d8:	74 24                	je     8012fe <fd_lookup+0x49>
  8012da:	89 c2                	mov    %eax,%edx
  8012dc:	c1 ea 0c             	shr    $0xc,%edx
  8012df:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012e6:	f6 c2 01             	test   $0x1,%dl
  8012e9:	74 1a                	je     801305 <fd_lookup+0x50>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8012eb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012ee:	89 02                	mov    %eax,(%edx)
	return 0;
  8012f0:	b8 00 00 00 00       	mov    $0x0,%eax
  8012f5:	eb 13                	jmp    80130a <fd_lookup+0x55>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012f7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012fc:	eb 0c                	jmp    80130a <fd_lookup+0x55>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012fe:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801303:	eb 05                	jmp    80130a <fd_lookup+0x55>
  801305:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80130a:	5d                   	pop    %ebp
  80130b:	c3                   	ret    

0080130c <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80130c:	55                   	push   %ebp
  80130d:	89 e5                	mov    %esp,%ebp
  80130f:	53                   	push   %ebx
  801310:	83 ec 04             	sub    $0x4,%esp
  801313:	8b 45 08             	mov    0x8(%ebp),%eax
  801316:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  801319:	3b 05 04 30 80 00    	cmp    0x803004,%eax
  80131f:	75 1e                	jne    80133f <dev_lookup+0x33>
  801321:	eb 0e                	jmp    801331 <dev_lookup+0x25>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801323:	b8 20 30 80 00       	mov    $0x803020,%eax
  801328:	eb 0c                	jmp    801336 <dev_lookup+0x2a>
  80132a:	b8 3c 30 80 00       	mov    $0x80303c,%eax
  80132f:	eb 05                	jmp    801336 <dev_lookup+0x2a>
  801331:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  801336:	89 03                	mov    %eax,(%ebx)
			return 0;
  801338:	b8 00 00 00 00       	mov    $0x0,%eax
  80133d:	eb 36                	jmp    801375 <dev_lookup+0x69>
int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  80133f:	3b 05 20 30 80 00    	cmp    0x803020,%eax
  801345:	74 dc                	je     801323 <dev_lookup+0x17>
  801347:	3b 05 3c 30 80 00    	cmp    0x80303c,%eax
  80134d:	74 db                	je     80132a <dev_lookup+0x1e>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80134f:	8b 15 20 44 80 00    	mov    0x804420,%edx
  801355:	8b 52 48             	mov    0x48(%edx),%edx
  801358:	83 ec 04             	sub    $0x4,%esp
  80135b:	50                   	push   %eax
  80135c:	52                   	push   %edx
  80135d:	68 34 29 80 00       	push   $0x802934
  801362:	e8 92 ef ff ff       	call   8002f9 <cprintf>
	*dev = 0;
  801367:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  80136d:	83 c4 10             	add    $0x10,%esp
  801370:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801375:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801378:	c9                   	leave  
  801379:	c3                   	ret    

0080137a <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80137a:	55                   	push   %ebp
  80137b:	89 e5                	mov    %esp,%ebp
  80137d:	56                   	push   %esi
  80137e:	53                   	push   %ebx
  80137f:	83 ec 10             	sub    $0x10,%esp
  801382:	8b 75 08             	mov    0x8(%ebp),%esi
  801385:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801388:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80138b:	50                   	push   %eax
  80138c:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801392:	c1 e8 0c             	shr    $0xc,%eax
  801395:	50                   	push   %eax
  801396:	e8 1a ff ff ff       	call   8012b5 <fd_lookup>
  80139b:	83 c4 08             	add    $0x8,%esp
  80139e:	85 c0                	test   %eax,%eax
  8013a0:	78 05                	js     8013a7 <fd_close+0x2d>
	    || fd != fd2)
  8013a2:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8013a5:	74 06                	je     8013ad <fd_close+0x33>
		return (must_exist ? r : 0);
  8013a7:	84 db                	test   %bl,%bl
  8013a9:	74 47                	je     8013f2 <fd_close+0x78>
  8013ab:	eb 4a                	jmp    8013f7 <fd_close+0x7d>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8013ad:	83 ec 08             	sub    $0x8,%esp
  8013b0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013b3:	50                   	push   %eax
  8013b4:	ff 36                	pushl  (%esi)
  8013b6:	e8 51 ff ff ff       	call   80130c <dev_lookup>
  8013bb:	89 c3                	mov    %eax,%ebx
  8013bd:	83 c4 10             	add    $0x10,%esp
  8013c0:	85 c0                	test   %eax,%eax
  8013c2:	78 1c                	js     8013e0 <fd_close+0x66>
		if (dev->dev_close)
  8013c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013c7:	8b 40 10             	mov    0x10(%eax),%eax
  8013ca:	85 c0                	test   %eax,%eax
  8013cc:	74 0d                	je     8013db <fd_close+0x61>
			r = (*dev->dev_close)(fd);
  8013ce:	83 ec 0c             	sub    $0xc,%esp
  8013d1:	56                   	push   %esi
  8013d2:	ff d0                	call   *%eax
  8013d4:	89 c3                	mov    %eax,%ebx
  8013d6:	83 c4 10             	add    $0x10,%esp
  8013d9:	eb 05                	jmp    8013e0 <fd_close+0x66>
		else
			r = 0;
  8013db:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8013e0:	83 ec 08             	sub    $0x8,%esp
  8013e3:	56                   	push   %esi
  8013e4:	6a 00                	push   $0x0
  8013e6:	e8 e8 f9 ff ff       	call   800dd3 <sys_page_unmap>
	return r;
  8013eb:	83 c4 10             	add    $0x10,%esp
  8013ee:	89 d8                	mov    %ebx,%eax
  8013f0:	eb 05                	jmp    8013f7 <fd_close+0x7d>
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
  8013f2:	b8 00 00 00 00       	mov    $0x0,%eax
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
	return r;
}
  8013f7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013fa:	5b                   	pop    %ebx
  8013fb:	5e                   	pop    %esi
  8013fc:	5d                   	pop    %ebp
  8013fd:	c3                   	ret    

008013fe <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8013fe:	55                   	push   %ebp
  8013ff:	89 e5                	mov    %esp,%ebp
  801401:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801404:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801407:	50                   	push   %eax
  801408:	ff 75 08             	pushl  0x8(%ebp)
  80140b:	e8 a5 fe ff ff       	call   8012b5 <fd_lookup>
  801410:	83 c4 08             	add    $0x8,%esp
  801413:	85 c0                	test   %eax,%eax
  801415:	78 10                	js     801427 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801417:	83 ec 08             	sub    $0x8,%esp
  80141a:	6a 01                	push   $0x1
  80141c:	ff 75 f4             	pushl  -0xc(%ebp)
  80141f:	e8 56 ff ff ff       	call   80137a <fd_close>
  801424:	83 c4 10             	add    $0x10,%esp
}
  801427:	c9                   	leave  
  801428:	c3                   	ret    

00801429 <close_all>:

void
close_all(void)
{
  801429:	55                   	push   %ebp
  80142a:	89 e5                	mov    %esp,%ebp
  80142c:	53                   	push   %ebx
  80142d:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801430:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801435:	83 ec 0c             	sub    $0xc,%esp
  801438:	53                   	push   %ebx
  801439:	e8 c0 ff ff ff       	call   8013fe <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80143e:	43                   	inc    %ebx
  80143f:	83 c4 10             	add    $0x10,%esp
  801442:	83 fb 20             	cmp    $0x20,%ebx
  801445:	75 ee                	jne    801435 <close_all+0xc>
		close(i);
}
  801447:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80144a:	c9                   	leave  
  80144b:	c3                   	ret    

0080144c <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80144c:	55                   	push   %ebp
  80144d:	89 e5                	mov    %esp,%ebp
  80144f:	57                   	push   %edi
  801450:	56                   	push   %esi
  801451:	53                   	push   %ebx
  801452:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801455:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801458:	50                   	push   %eax
  801459:	ff 75 08             	pushl  0x8(%ebp)
  80145c:	e8 54 fe ff ff       	call   8012b5 <fd_lookup>
  801461:	83 c4 08             	add    $0x8,%esp
  801464:	85 c0                	test   %eax,%eax
  801466:	0f 88 c2 00 00 00    	js     80152e <dup+0xe2>
		return r;
	close(newfdnum);
  80146c:	83 ec 0c             	sub    $0xc,%esp
  80146f:	ff 75 0c             	pushl  0xc(%ebp)
  801472:	e8 87 ff ff ff       	call   8013fe <close>

	newfd = INDEX2FD(newfdnum);
  801477:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80147a:	c1 e3 0c             	shl    $0xc,%ebx
  80147d:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801483:	83 c4 04             	add    $0x4,%esp
  801486:	ff 75 e4             	pushl  -0x1c(%ebp)
  801489:	e8 9c fd ff ff       	call   80122a <fd2data>
  80148e:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  801490:	89 1c 24             	mov    %ebx,(%esp)
  801493:	e8 92 fd ff ff       	call   80122a <fd2data>
  801498:	83 c4 10             	add    $0x10,%esp
  80149b:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80149d:	89 f0                	mov    %esi,%eax
  80149f:	c1 e8 16             	shr    $0x16,%eax
  8014a2:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8014a9:	a8 01                	test   $0x1,%al
  8014ab:	74 35                	je     8014e2 <dup+0x96>
  8014ad:	89 f0                	mov    %esi,%eax
  8014af:	c1 e8 0c             	shr    $0xc,%eax
  8014b2:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8014b9:	f6 c2 01             	test   $0x1,%dl
  8014bc:	74 24                	je     8014e2 <dup+0x96>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8014be:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014c5:	83 ec 0c             	sub    $0xc,%esp
  8014c8:	25 07 0e 00 00       	and    $0xe07,%eax
  8014cd:	50                   	push   %eax
  8014ce:	57                   	push   %edi
  8014cf:	6a 00                	push   $0x0
  8014d1:	56                   	push   %esi
  8014d2:	6a 00                	push   $0x0
  8014d4:	e8 b8 f8 ff ff       	call   800d91 <sys_page_map>
  8014d9:	89 c6                	mov    %eax,%esi
  8014db:	83 c4 20             	add    $0x20,%esp
  8014de:	85 c0                	test   %eax,%eax
  8014e0:	78 2c                	js     80150e <dup+0xc2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014e2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8014e5:	89 d0                	mov    %edx,%eax
  8014e7:	c1 e8 0c             	shr    $0xc,%eax
  8014ea:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014f1:	83 ec 0c             	sub    $0xc,%esp
  8014f4:	25 07 0e 00 00       	and    $0xe07,%eax
  8014f9:	50                   	push   %eax
  8014fa:	53                   	push   %ebx
  8014fb:	6a 00                	push   $0x0
  8014fd:	52                   	push   %edx
  8014fe:	6a 00                	push   $0x0
  801500:	e8 8c f8 ff ff       	call   800d91 <sys_page_map>
  801505:	89 c6                	mov    %eax,%esi
  801507:	83 c4 20             	add    $0x20,%esp
  80150a:	85 c0                	test   %eax,%eax
  80150c:	79 1d                	jns    80152b <dup+0xdf>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80150e:	83 ec 08             	sub    $0x8,%esp
  801511:	53                   	push   %ebx
  801512:	6a 00                	push   $0x0
  801514:	e8 ba f8 ff ff       	call   800dd3 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801519:	83 c4 08             	add    $0x8,%esp
  80151c:	57                   	push   %edi
  80151d:	6a 00                	push   $0x0
  80151f:	e8 af f8 ff ff       	call   800dd3 <sys_page_unmap>
	return r;
  801524:	83 c4 10             	add    $0x10,%esp
  801527:	89 f0                	mov    %esi,%eax
  801529:	eb 03                	jmp    80152e <dup+0xe2>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  80152b:	8b 45 0c             	mov    0xc(%ebp),%eax

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80152e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801531:	5b                   	pop    %ebx
  801532:	5e                   	pop    %esi
  801533:	5f                   	pop    %edi
  801534:	5d                   	pop    %ebp
  801535:	c3                   	ret    

00801536 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801536:	55                   	push   %ebp
  801537:	89 e5                	mov    %esp,%ebp
  801539:	53                   	push   %ebx
  80153a:	83 ec 14             	sub    $0x14,%esp
  80153d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801540:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801543:	50                   	push   %eax
  801544:	53                   	push   %ebx
  801545:	e8 6b fd ff ff       	call   8012b5 <fd_lookup>
  80154a:	83 c4 08             	add    $0x8,%esp
  80154d:	85 c0                	test   %eax,%eax
  80154f:	78 67                	js     8015b8 <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801551:	83 ec 08             	sub    $0x8,%esp
  801554:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801557:	50                   	push   %eax
  801558:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80155b:	ff 30                	pushl  (%eax)
  80155d:	e8 aa fd ff ff       	call   80130c <dev_lookup>
  801562:	83 c4 10             	add    $0x10,%esp
  801565:	85 c0                	test   %eax,%eax
  801567:	78 4f                	js     8015b8 <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801569:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80156c:	8b 42 08             	mov    0x8(%edx),%eax
  80156f:	83 e0 03             	and    $0x3,%eax
  801572:	83 f8 01             	cmp    $0x1,%eax
  801575:	75 21                	jne    801598 <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801577:	a1 20 44 80 00       	mov    0x804420,%eax
  80157c:	8b 40 48             	mov    0x48(%eax),%eax
  80157f:	83 ec 04             	sub    $0x4,%esp
  801582:	53                   	push   %ebx
  801583:	50                   	push   %eax
  801584:	68 78 29 80 00       	push   $0x802978
  801589:	e8 6b ed ff ff       	call   8002f9 <cprintf>
		return -E_INVAL;
  80158e:	83 c4 10             	add    $0x10,%esp
  801591:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801596:	eb 20                	jmp    8015b8 <read+0x82>
	}
	if (!dev->dev_read)
  801598:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80159b:	8b 40 08             	mov    0x8(%eax),%eax
  80159e:	85 c0                	test   %eax,%eax
  8015a0:	74 11                	je     8015b3 <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8015a2:	83 ec 04             	sub    $0x4,%esp
  8015a5:	ff 75 10             	pushl  0x10(%ebp)
  8015a8:	ff 75 0c             	pushl  0xc(%ebp)
  8015ab:	52                   	push   %edx
  8015ac:	ff d0                	call   *%eax
  8015ae:	83 c4 10             	add    $0x10,%esp
  8015b1:	eb 05                	jmp    8015b8 <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8015b3:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8015b8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015bb:	c9                   	leave  
  8015bc:	c3                   	ret    

008015bd <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8015bd:	55                   	push   %ebp
  8015be:	89 e5                	mov    %esp,%ebp
  8015c0:	57                   	push   %edi
  8015c1:	56                   	push   %esi
  8015c2:	53                   	push   %ebx
  8015c3:	83 ec 0c             	sub    $0xc,%esp
  8015c6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8015c9:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015cc:	85 f6                	test   %esi,%esi
  8015ce:	74 31                	je     801601 <readn+0x44>
  8015d0:	b8 00 00 00 00       	mov    $0x0,%eax
  8015d5:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  8015da:	83 ec 04             	sub    $0x4,%esp
  8015dd:	89 f2                	mov    %esi,%edx
  8015df:	29 c2                	sub    %eax,%edx
  8015e1:	52                   	push   %edx
  8015e2:	03 45 0c             	add    0xc(%ebp),%eax
  8015e5:	50                   	push   %eax
  8015e6:	57                   	push   %edi
  8015e7:	e8 4a ff ff ff       	call   801536 <read>
		if (m < 0)
  8015ec:	83 c4 10             	add    $0x10,%esp
  8015ef:	85 c0                	test   %eax,%eax
  8015f1:	78 17                	js     80160a <readn+0x4d>
			return m;
		if (m == 0)
  8015f3:	85 c0                	test   %eax,%eax
  8015f5:	74 11                	je     801608 <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015f7:	01 c3                	add    %eax,%ebx
  8015f9:	89 d8                	mov    %ebx,%eax
  8015fb:	39 f3                	cmp    %esi,%ebx
  8015fd:	72 db                	jb     8015da <readn+0x1d>
  8015ff:	eb 09                	jmp    80160a <readn+0x4d>
  801601:	b8 00 00 00 00       	mov    $0x0,%eax
  801606:	eb 02                	jmp    80160a <readn+0x4d>
  801608:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80160a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80160d:	5b                   	pop    %ebx
  80160e:	5e                   	pop    %esi
  80160f:	5f                   	pop    %edi
  801610:	5d                   	pop    %ebp
  801611:	c3                   	ret    

00801612 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801612:	55                   	push   %ebp
  801613:	89 e5                	mov    %esp,%ebp
  801615:	53                   	push   %ebx
  801616:	83 ec 14             	sub    $0x14,%esp
  801619:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80161c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80161f:	50                   	push   %eax
  801620:	53                   	push   %ebx
  801621:	e8 8f fc ff ff       	call   8012b5 <fd_lookup>
  801626:	83 c4 08             	add    $0x8,%esp
  801629:	85 c0                	test   %eax,%eax
  80162b:	78 62                	js     80168f <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80162d:	83 ec 08             	sub    $0x8,%esp
  801630:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801633:	50                   	push   %eax
  801634:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801637:	ff 30                	pushl  (%eax)
  801639:	e8 ce fc ff ff       	call   80130c <dev_lookup>
  80163e:	83 c4 10             	add    $0x10,%esp
  801641:	85 c0                	test   %eax,%eax
  801643:	78 4a                	js     80168f <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801645:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801648:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80164c:	75 21                	jne    80166f <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80164e:	a1 20 44 80 00       	mov    0x804420,%eax
  801653:	8b 40 48             	mov    0x48(%eax),%eax
  801656:	83 ec 04             	sub    $0x4,%esp
  801659:	53                   	push   %ebx
  80165a:	50                   	push   %eax
  80165b:	68 94 29 80 00       	push   $0x802994
  801660:	e8 94 ec ff ff       	call   8002f9 <cprintf>
		return -E_INVAL;
  801665:	83 c4 10             	add    $0x10,%esp
  801668:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80166d:	eb 20                	jmp    80168f <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80166f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801672:	8b 52 0c             	mov    0xc(%edx),%edx
  801675:	85 d2                	test   %edx,%edx
  801677:	74 11                	je     80168a <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801679:	83 ec 04             	sub    $0x4,%esp
  80167c:	ff 75 10             	pushl  0x10(%ebp)
  80167f:	ff 75 0c             	pushl  0xc(%ebp)
  801682:	50                   	push   %eax
  801683:	ff d2                	call   *%edx
  801685:	83 c4 10             	add    $0x10,%esp
  801688:	eb 05                	jmp    80168f <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80168a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  80168f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801692:	c9                   	leave  
  801693:	c3                   	ret    

00801694 <seek>:

int
seek(int fdnum, off_t offset)
{
  801694:	55                   	push   %ebp
  801695:	89 e5                	mov    %esp,%ebp
  801697:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80169a:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80169d:	50                   	push   %eax
  80169e:	ff 75 08             	pushl  0x8(%ebp)
  8016a1:	e8 0f fc ff ff       	call   8012b5 <fd_lookup>
  8016a6:	83 c4 08             	add    $0x8,%esp
  8016a9:	85 c0                	test   %eax,%eax
  8016ab:	78 0e                	js     8016bb <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8016ad:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8016b0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016b3:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8016b6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016bb:	c9                   	leave  
  8016bc:	c3                   	ret    

008016bd <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8016bd:	55                   	push   %ebp
  8016be:	89 e5                	mov    %esp,%ebp
  8016c0:	53                   	push   %ebx
  8016c1:	83 ec 14             	sub    $0x14,%esp
  8016c4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016c7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016ca:	50                   	push   %eax
  8016cb:	53                   	push   %ebx
  8016cc:	e8 e4 fb ff ff       	call   8012b5 <fd_lookup>
  8016d1:	83 c4 08             	add    $0x8,%esp
  8016d4:	85 c0                	test   %eax,%eax
  8016d6:	78 5f                	js     801737 <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016d8:	83 ec 08             	sub    $0x8,%esp
  8016db:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016de:	50                   	push   %eax
  8016df:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016e2:	ff 30                	pushl  (%eax)
  8016e4:	e8 23 fc ff ff       	call   80130c <dev_lookup>
  8016e9:	83 c4 10             	add    $0x10,%esp
  8016ec:	85 c0                	test   %eax,%eax
  8016ee:	78 47                	js     801737 <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016f3:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016f7:	75 21                	jne    80171a <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8016f9:	a1 20 44 80 00       	mov    0x804420,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8016fe:	8b 40 48             	mov    0x48(%eax),%eax
  801701:	83 ec 04             	sub    $0x4,%esp
  801704:	53                   	push   %ebx
  801705:	50                   	push   %eax
  801706:	68 54 29 80 00       	push   $0x802954
  80170b:	e8 e9 eb ff ff       	call   8002f9 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801710:	83 c4 10             	add    $0x10,%esp
  801713:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801718:	eb 1d                	jmp    801737 <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  80171a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80171d:	8b 52 18             	mov    0x18(%edx),%edx
  801720:	85 d2                	test   %edx,%edx
  801722:	74 0e                	je     801732 <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801724:	83 ec 08             	sub    $0x8,%esp
  801727:	ff 75 0c             	pushl  0xc(%ebp)
  80172a:	50                   	push   %eax
  80172b:	ff d2                	call   *%edx
  80172d:	83 c4 10             	add    $0x10,%esp
  801730:	eb 05                	jmp    801737 <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801732:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801737:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80173a:	c9                   	leave  
  80173b:	c3                   	ret    

0080173c <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80173c:	55                   	push   %ebp
  80173d:	89 e5                	mov    %esp,%ebp
  80173f:	53                   	push   %ebx
  801740:	83 ec 14             	sub    $0x14,%esp
  801743:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801746:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801749:	50                   	push   %eax
  80174a:	ff 75 08             	pushl  0x8(%ebp)
  80174d:	e8 63 fb ff ff       	call   8012b5 <fd_lookup>
  801752:	83 c4 08             	add    $0x8,%esp
  801755:	85 c0                	test   %eax,%eax
  801757:	78 52                	js     8017ab <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801759:	83 ec 08             	sub    $0x8,%esp
  80175c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80175f:	50                   	push   %eax
  801760:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801763:	ff 30                	pushl  (%eax)
  801765:	e8 a2 fb ff ff       	call   80130c <dev_lookup>
  80176a:	83 c4 10             	add    $0x10,%esp
  80176d:	85 c0                	test   %eax,%eax
  80176f:	78 3a                	js     8017ab <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  801771:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801774:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801778:	74 2c                	je     8017a6 <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80177a:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80177d:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801784:	00 00 00 
	stat->st_isdir = 0;
  801787:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80178e:	00 00 00 
	stat->st_dev = dev;
  801791:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801797:	83 ec 08             	sub    $0x8,%esp
  80179a:	53                   	push   %ebx
  80179b:	ff 75 f0             	pushl  -0x10(%ebp)
  80179e:	ff 50 14             	call   *0x14(%eax)
  8017a1:	83 c4 10             	add    $0x10,%esp
  8017a4:	eb 05                	jmp    8017ab <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8017a6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8017ab:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017ae:	c9                   	leave  
  8017af:	c3                   	ret    

008017b0 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8017b0:	55                   	push   %ebp
  8017b1:	89 e5                	mov    %esp,%ebp
  8017b3:	56                   	push   %esi
  8017b4:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8017b5:	83 ec 08             	sub    $0x8,%esp
  8017b8:	6a 00                	push   $0x0
  8017ba:	ff 75 08             	pushl  0x8(%ebp)
  8017bd:	e8 75 01 00 00       	call   801937 <open>
  8017c2:	89 c3                	mov    %eax,%ebx
  8017c4:	83 c4 10             	add    $0x10,%esp
  8017c7:	85 c0                	test   %eax,%eax
  8017c9:	78 1d                	js     8017e8 <stat+0x38>
		return fd;
	r = fstat(fd, stat);
  8017cb:	83 ec 08             	sub    $0x8,%esp
  8017ce:	ff 75 0c             	pushl  0xc(%ebp)
  8017d1:	50                   	push   %eax
  8017d2:	e8 65 ff ff ff       	call   80173c <fstat>
  8017d7:	89 c6                	mov    %eax,%esi
	close(fd);
  8017d9:	89 1c 24             	mov    %ebx,(%esp)
  8017dc:	e8 1d fc ff ff       	call   8013fe <close>
	return r;
  8017e1:	83 c4 10             	add    $0x10,%esp
  8017e4:	89 f0                	mov    %esi,%eax
  8017e6:	eb 00                	jmp    8017e8 <stat+0x38>
}
  8017e8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017eb:	5b                   	pop    %ebx
  8017ec:	5e                   	pop    %esi
  8017ed:	5d                   	pop    %ebp
  8017ee:	c3                   	ret    

008017ef <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8017ef:	55                   	push   %ebp
  8017f0:	89 e5                	mov    %esp,%ebp
  8017f2:	56                   	push   %esi
  8017f3:	53                   	push   %ebx
  8017f4:	89 c6                	mov    %eax,%esi
  8017f6:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8017f8:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8017ff:	75 12                	jne    801813 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801801:	83 ec 0c             	sub    $0xc,%esp
  801804:	6a 01                	push   $0x1
  801806:	e8 95 08 00 00       	call   8020a0 <ipc_find_env>
  80180b:	a3 00 40 80 00       	mov    %eax,0x804000
  801810:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801813:	6a 07                	push   $0x7
  801815:	68 00 50 80 00       	push   $0x805000
  80181a:	56                   	push   %esi
  80181b:	ff 35 00 40 80 00    	pushl  0x804000
  801821:	e8 1b 08 00 00       	call   802041 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801826:	83 c4 0c             	add    $0xc,%esp
  801829:	6a 00                	push   $0x0
  80182b:	53                   	push   %ebx
  80182c:	6a 00                	push   $0x0
  80182e:	e8 99 07 00 00       	call   801fcc <ipc_recv>
}
  801833:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801836:	5b                   	pop    %ebx
  801837:	5e                   	pop    %esi
  801838:	5d                   	pop    %ebp
  801839:	c3                   	ret    

0080183a <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80183a:	55                   	push   %ebp
  80183b:	89 e5                	mov    %esp,%ebp
  80183d:	53                   	push   %ebx
  80183e:	83 ec 04             	sub    $0x4,%esp
  801841:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801844:	8b 45 08             	mov    0x8(%ebp),%eax
  801847:	8b 40 0c             	mov    0xc(%eax),%eax
  80184a:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80184f:	ba 00 00 00 00       	mov    $0x0,%edx
  801854:	b8 05 00 00 00       	mov    $0x5,%eax
  801859:	e8 91 ff ff ff       	call   8017ef <fsipc>
  80185e:	85 c0                	test   %eax,%eax
  801860:	78 2c                	js     80188e <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801862:	83 ec 08             	sub    $0x8,%esp
  801865:	68 00 50 80 00       	push   $0x805000
  80186a:	53                   	push   %ebx
  80186b:	e8 6e f0 ff ff       	call   8008de <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801870:	a1 80 50 80 00       	mov    0x805080,%eax
  801875:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80187b:	a1 84 50 80 00       	mov    0x805084,%eax
  801880:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801886:	83 c4 10             	add    $0x10,%esp
  801889:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80188e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801891:	c9                   	leave  
  801892:	c3                   	ret    

00801893 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801893:	55                   	push   %ebp
  801894:	89 e5                	mov    %esp,%ebp
  801896:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801899:	8b 45 08             	mov    0x8(%ebp),%eax
  80189c:	8b 40 0c             	mov    0xc(%eax),%eax
  80189f:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8018a4:	ba 00 00 00 00       	mov    $0x0,%edx
  8018a9:	b8 06 00 00 00       	mov    $0x6,%eax
  8018ae:	e8 3c ff ff ff       	call   8017ef <fsipc>
}
  8018b3:	c9                   	leave  
  8018b4:	c3                   	ret    

008018b5 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8018b5:	55                   	push   %ebp
  8018b6:	89 e5                	mov    %esp,%ebp
  8018b8:	56                   	push   %esi
  8018b9:	53                   	push   %ebx
  8018ba:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8018bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8018c0:	8b 40 0c             	mov    0xc(%eax),%eax
  8018c3:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8018c8:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8018ce:	ba 00 00 00 00       	mov    $0x0,%edx
  8018d3:	b8 03 00 00 00       	mov    $0x3,%eax
  8018d8:	e8 12 ff ff ff       	call   8017ef <fsipc>
  8018dd:	89 c3                	mov    %eax,%ebx
  8018df:	85 c0                	test   %eax,%eax
  8018e1:	78 4b                	js     80192e <devfile_read+0x79>
		return r;
	assert(r <= n);
  8018e3:	39 c6                	cmp    %eax,%esi
  8018e5:	73 16                	jae    8018fd <devfile_read+0x48>
  8018e7:	68 b1 29 80 00       	push   $0x8029b1
  8018ec:	68 b8 29 80 00       	push   $0x8029b8
  8018f1:	6a 7a                	push   $0x7a
  8018f3:	68 cd 29 80 00       	push   $0x8029cd
  8018f8:	e8 24 e9 ff ff       	call   800221 <_panic>
	assert(r <= PGSIZE);
  8018fd:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801902:	7e 16                	jle    80191a <devfile_read+0x65>
  801904:	68 d8 29 80 00       	push   $0x8029d8
  801909:	68 b8 29 80 00       	push   $0x8029b8
  80190e:	6a 7b                	push   $0x7b
  801910:	68 cd 29 80 00       	push   $0x8029cd
  801915:	e8 07 e9 ff ff       	call   800221 <_panic>
	memmove(buf, &fsipcbuf, r);
  80191a:	83 ec 04             	sub    $0x4,%esp
  80191d:	50                   	push   %eax
  80191e:	68 00 50 80 00       	push   $0x805000
  801923:	ff 75 0c             	pushl  0xc(%ebp)
  801926:	e8 80 f1 ff ff       	call   800aab <memmove>
	return r;
  80192b:	83 c4 10             	add    $0x10,%esp
}
  80192e:	89 d8                	mov    %ebx,%eax
  801930:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801933:	5b                   	pop    %ebx
  801934:	5e                   	pop    %esi
  801935:	5d                   	pop    %ebp
  801936:	c3                   	ret    

00801937 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801937:	55                   	push   %ebp
  801938:	89 e5                	mov    %esp,%ebp
  80193a:	53                   	push   %ebx
  80193b:	83 ec 20             	sub    $0x20,%esp
  80193e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801941:	53                   	push   %ebx
  801942:	e8 40 ef ff ff       	call   800887 <strlen>
  801947:	83 c4 10             	add    $0x10,%esp
  80194a:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80194f:	7f 63                	jg     8019b4 <open+0x7d>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801951:	83 ec 0c             	sub    $0xc,%esp
  801954:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801957:	50                   	push   %eax
  801958:	e8 e4 f8 ff ff       	call   801241 <fd_alloc>
  80195d:	83 c4 10             	add    $0x10,%esp
  801960:	85 c0                	test   %eax,%eax
  801962:	78 55                	js     8019b9 <open+0x82>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801964:	83 ec 08             	sub    $0x8,%esp
  801967:	53                   	push   %ebx
  801968:	68 00 50 80 00       	push   $0x805000
  80196d:	e8 6c ef ff ff       	call   8008de <strcpy>
	fsipcbuf.open.req_omode = mode;
  801972:	8b 45 0c             	mov    0xc(%ebp),%eax
  801975:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80197a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80197d:	b8 01 00 00 00       	mov    $0x1,%eax
  801982:	e8 68 fe ff ff       	call   8017ef <fsipc>
  801987:	89 c3                	mov    %eax,%ebx
  801989:	83 c4 10             	add    $0x10,%esp
  80198c:	85 c0                	test   %eax,%eax
  80198e:	79 14                	jns    8019a4 <open+0x6d>
		fd_close(fd, 0);
  801990:	83 ec 08             	sub    $0x8,%esp
  801993:	6a 00                	push   $0x0
  801995:	ff 75 f4             	pushl  -0xc(%ebp)
  801998:	e8 dd f9 ff ff       	call   80137a <fd_close>
		return r;
  80199d:	83 c4 10             	add    $0x10,%esp
  8019a0:	89 d8                	mov    %ebx,%eax
  8019a2:	eb 15                	jmp    8019b9 <open+0x82>
	}

	return fd2num(fd);
  8019a4:	83 ec 0c             	sub    $0xc,%esp
  8019a7:	ff 75 f4             	pushl  -0xc(%ebp)
  8019aa:	e8 6b f8 ff ff       	call   80121a <fd2num>
  8019af:	83 c4 10             	add    $0x10,%esp
  8019b2:	eb 05                	jmp    8019b9 <open+0x82>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8019b4:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8019b9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019bc:	c9                   	leave  
  8019bd:	c3                   	ret    

008019be <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8019be:	55                   	push   %ebp
  8019bf:	89 e5                	mov    %esp,%ebp
  8019c1:	56                   	push   %esi
  8019c2:	53                   	push   %ebx
  8019c3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8019c6:	83 ec 0c             	sub    $0xc,%esp
  8019c9:	ff 75 08             	pushl  0x8(%ebp)
  8019cc:	e8 59 f8 ff ff       	call   80122a <fd2data>
  8019d1:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8019d3:	83 c4 08             	add    $0x8,%esp
  8019d6:	68 e4 29 80 00       	push   $0x8029e4
  8019db:	53                   	push   %ebx
  8019dc:	e8 fd ee ff ff       	call   8008de <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8019e1:	8b 46 04             	mov    0x4(%esi),%eax
  8019e4:	2b 06                	sub    (%esi),%eax
  8019e6:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8019ec:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8019f3:	00 00 00 
	stat->st_dev = &devpipe;
  8019f6:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8019fd:	30 80 00 
	return 0;
}
  801a00:	b8 00 00 00 00       	mov    $0x0,%eax
  801a05:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a08:	5b                   	pop    %ebx
  801a09:	5e                   	pop    %esi
  801a0a:	5d                   	pop    %ebp
  801a0b:	c3                   	ret    

00801a0c <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a0c:	55                   	push   %ebp
  801a0d:	89 e5                	mov    %esp,%ebp
  801a0f:	53                   	push   %ebx
  801a10:	83 ec 0c             	sub    $0xc,%esp
  801a13:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a16:	53                   	push   %ebx
  801a17:	6a 00                	push   $0x0
  801a19:	e8 b5 f3 ff ff       	call   800dd3 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a1e:	89 1c 24             	mov    %ebx,(%esp)
  801a21:	e8 04 f8 ff ff       	call   80122a <fd2data>
  801a26:	83 c4 08             	add    $0x8,%esp
  801a29:	50                   	push   %eax
  801a2a:	6a 00                	push   $0x0
  801a2c:	e8 a2 f3 ff ff       	call   800dd3 <sys_page_unmap>
}
  801a31:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a34:	c9                   	leave  
  801a35:	c3                   	ret    

00801a36 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801a36:	55                   	push   %ebp
  801a37:	89 e5                	mov    %esp,%ebp
  801a39:	57                   	push   %edi
  801a3a:	56                   	push   %esi
  801a3b:	53                   	push   %ebx
  801a3c:	83 ec 1c             	sub    $0x1c,%esp
  801a3f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801a42:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801a44:	a1 20 44 80 00       	mov    0x804420,%eax
  801a49:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801a4c:	83 ec 0c             	sub    $0xc,%esp
  801a4f:	ff 75 e0             	pushl  -0x20(%ebp)
  801a52:	e8 a4 06 00 00       	call   8020fb <pageref>
  801a57:	89 c3                	mov    %eax,%ebx
  801a59:	89 3c 24             	mov    %edi,(%esp)
  801a5c:	e8 9a 06 00 00       	call   8020fb <pageref>
  801a61:	83 c4 10             	add    $0x10,%esp
  801a64:	39 c3                	cmp    %eax,%ebx
  801a66:	0f 94 c1             	sete   %cl
  801a69:	0f b6 c9             	movzbl %cl,%ecx
  801a6c:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801a6f:	8b 15 20 44 80 00    	mov    0x804420,%edx
  801a75:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801a78:	39 ce                	cmp    %ecx,%esi
  801a7a:	74 1b                	je     801a97 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801a7c:	39 c3                	cmp    %eax,%ebx
  801a7e:	75 c4                	jne    801a44 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a80:	8b 42 58             	mov    0x58(%edx),%eax
  801a83:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a86:	50                   	push   %eax
  801a87:	56                   	push   %esi
  801a88:	68 eb 29 80 00       	push   $0x8029eb
  801a8d:	e8 67 e8 ff ff       	call   8002f9 <cprintf>
  801a92:	83 c4 10             	add    $0x10,%esp
  801a95:	eb ad                	jmp    801a44 <_pipeisclosed+0xe>
	}
}
  801a97:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a9a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a9d:	5b                   	pop    %ebx
  801a9e:	5e                   	pop    %esi
  801a9f:	5f                   	pop    %edi
  801aa0:	5d                   	pop    %ebp
  801aa1:	c3                   	ret    

00801aa2 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801aa2:	55                   	push   %ebp
  801aa3:	89 e5                	mov    %esp,%ebp
  801aa5:	57                   	push   %edi
  801aa6:	56                   	push   %esi
  801aa7:	53                   	push   %ebx
  801aa8:	83 ec 18             	sub    $0x18,%esp
  801aab:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801aae:	56                   	push   %esi
  801aaf:	e8 76 f7 ff ff       	call   80122a <fd2data>
  801ab4:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ab6:	83 c4 10             	add    $0x10,%esp
  801ab9:	bf 00 00 00 00       	mov    $0x0,%edi
  801abe:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801ac2:	75 42                	jne    801b06 <devpipe_write+0x64>
  801ac4:	eb 4e                	jmp    801b14 <devpipe_write+0x72>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801ac6:	89 da                	mov    %ebx,%edx
  801ac8:	89 f0                	mov    %esi,%eax
  801aca:	e8 67 ff ff ff       	call   801a36 <_pipeisclosed>
  801acf:	85 c0                	test   %eax,%eax
  801ad1:	75 46                	jne    801b19 <devpipe_write+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801ad3:	e8 57 f2 ff ff       	call   800d2f <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801ad8:	8b 53 04             	mov    0x4(%ebx),%edx
  801adb:	8b 03                	mov    (%ebx),%eax
  801add:	83 c0 20             	add    $0x20,%eax
  801ae0:	39 c2                	cmp    %eax,%edx
  801ae2:	73 e2                	jae    801ac6 <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801ae4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ae7:	8a 0c 38             	mov    (%eax,%edi,1),%cl
  801aea:	89 d0                	mov    %edx,%eax
  801aec:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801af1:	79 05                	jns    801af8 <devpipe_write+0x56>
  801af3:	48                   	dec    %eax
  801af4:	83 c8 e0             	or     $0xffffffe0,%eax
  801af7:	40                   	inc    %eax
  801af8:	88 4c 03 08          	mov    %cl,0x8(%ebx,%eax,1)
		p->p_wpos++;
  801afc:	42                   	inc    %edx
  801afd:	89 53 04             	mov    %edx,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b00:	47                   	inc    %edi
  801b01:	39 7d 10             	cmp    %edi,0x10(%ebp)
  801b04:	74 0e                	je     801b14 <devpipe_write+0x72>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b06:	8b 53 04             	mov    0x4(%ebx),%edx
  801b09:	8b 03                	mov    (%ebx),%eax
  801b0b:	83 c0 20             	add    $0x20,%eax
  801b0e:	39 c2                	cmp    %eax,%edx
  801b10:	73 b4                	jae    801ac6 <devpipe_write+0x24>
  801b12:	eb d0                	jmp    801ae4 <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801b14:	8b 45 10             	mov    0x10(%ebp),%eax
  801b17:	eb 05                	jmp    801b1e <devpipe_write+0x7c>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b19:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801b1e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b21:	5b                   	pop    %ebx
  801b22:	5e                   	pop    %esi
  801b23:	5f                   	pop    %edi
  801b24:	5d                   	pop    %ebp
  801b25:	c3                   	ret    

00801b26 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b26:	55                   	push   %ebp
  801b27:	89 e5                	mov    %esp,%ebp
  801b29:	57                   	push   %edi
  801b2a:	56                   	push   %esi
  801b2b:	53                   	push   %ebx
  801b2c:	83 ec 18             	sub    $0x18,%esp
  801b2f:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801b32:	57                   	push   %edi
  801b33:	e8 f2 f6 ff ff       	call   80122a <fd2data>
  801b38:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b3a:	83 c4 10             	add    $0x10,%esp
  801b3d:	be 00 00 00 00       	mov    $0x0,%esi
  801b42:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801b46:	75 3d                	jne    801b85 <devpipe_read+0x5f>
  801b48:	eb 48                	jmp    801b92 <devpipe_read+0x6c>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  801b4a:	89 f0                	mov    %esi,%eax
  801b4c:	eb 4e                	jmp    801b9c <devpipe_read+0x76>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801b4e:	89 da                	mov    %ebx,%edx
  801b50:	89 f8                	mov    %edi,%eax
  801b52:	e8 df fe ff ff       	call   801a36 <_pipeisclosed>
  801b57:	85 c0                	test   %eax,%eax
  801b59:	75 3c                	jne    801b97 <devpipe_read+0x71>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801b5b:	e8 cf f1 ff ff       	call   800d2f <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801b60:	8b 03                	mov    (%ebx),%eax
  801b62:	3b 43 04             	cmp    0x4(%ebx),%eax
  801b65:	74 e7                	je     801b4e <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b67:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801b6c:	79 05                	jns    801b73 <devpipe_read+0x4d>
  801b6e:	48                   	dec    %eax
  801b6f:	83 c8 e0             	or     $0xffffffe0,%eax
  801b72:	40                   	inc    %eax
  801b73:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801b77:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b7a:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801b7d:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b7f:	46                   	inc    %esi
  801b80:	39 75 10             	cmp    %esi,0x10(%ebp)
  801b83:	74 0d                	je     801b92 <devpipe_read+0x6c>
		while (p->p_rpos == p->p_wpos) {
  801b85:	8b 03                	mov    (%ebx),%eax
  801b87:	3b 43 04             	cmp    0x4(%ebx),%eax
  801b8a:	75 db                	jne    801b67 <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801b8c:	85 f6                	test   %esi,%esi
  801b8e:	75 ba                	jne    801b4a <devpipe_read+0x24>
  801b90:	eb bc                	jmp    801b4e <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801b92:	8b 45 10             	mov    0x10(%ebp),%eax
  801b95:	eb 05                	jmp    801b9c <devpipe_read+0x76>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b97:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801b9c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b9f:	5b                   	pop    %ebx
  801ba0:	5e                   	pop    %esi
  801ba1:	5f                   	pop    %edi
  801ba2:	5d                   	pop    %ebp
  801ba3:	c3                   	ret    

00801ba4 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801ba4:	55                   	push   %ebp
  801ba5:	89 e5                	mov    %esp,%ebp
  801ba7:	56                   	push   %esi
  801ba8:	53                   	push   %ebx
  801ba9:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801bac:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801baf:	50                   	push   %eax
  801bb0:	e8 8c f6 ff ff       	call   801241 <fd_alloc>
  801bb5:	83 c4 10             	add    $0x10,%esp
  801bb8:	85 c0                	test   %eax,%eax
  801bba:	0f 88 2a 01 00 00    	js     801cea <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bc0:	83 ec 04             	sub    $0x4,%esp
  801bc3:	68 07 04 00 00       	push   $0x407
  801bc8:	ff 75 f4             	pushl  -0xc(%ebp)
  801bcb:	6a 00                	push   $0x0
  801bcd:	e8 7c f1 ff ff       	call   800d4e <sys_page_alloc>
  801bd2:	83 c4 10             	add    $0x10,%esp
  801bd5:	85 c0                	test   %eax,%eax
  801bd7:	0f 88 0d 01 00 00    	js     801cea <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801bdd:	83 ec 0c             	sub    $0xc,%esp
  801be0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801be3:	50                   	push   %eax
  801be4:	e8 58 f6 ff ff       	call   801241 <fd_alloc>
  801be9:	89 c3                	mov    %eax,%ebx
  801beb:	83 c4 10             	add    $0x10,%esp
  801bee:	85 c0                	test   %eax,%eax
  801bf0:	0f 88 e2 00 00 00    	js     801cd8 <pipe+0x134>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bf6:	83 ec 04             	sub    $0x4,%esp
  801bf9:	68 07 04 00 00       	push   $0x407
  801bfe:	ff 75 f0             	pushl  -0x10(%ebp)
  801c01:	6a 00                	push   $0x0
  801c03:	e8 46 f1 ff ff       	call   800d4e <sys_page_alloc>
  801c08:	89 c3                	mov    %eax,%ebx
  801c0a:	83 c4 10             	add    $0x10,%esp
  801c0d:	85 c0                	test   %eax,%eax
  801c0f:	0f 88 c3 00 00 00    	js     801cd8 <pipe+0x134>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801c15:	83 ec 0c             	sub    $0xc,%esp
  801c18:	ff 75 f4             	pushl  -0xc(%ebp)
  801c1b:	e8 0a f6 ff ff       	call   80122a <fd2data>
  801c20:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c22:	83 c4 0c             	add    $0xc,%esp
  801c25:	68 07 04 00 00       	push   $0x407
  801c2a:	50                   	push   %eax
  801c2b:	6a 00                	push   $0x0
  801c2d:	e8 1c f1 ff ff       	call   800d4e <sys_page_alloc>
  801c32:	89 c3                	mov    %eax,%ebx
  801c34:	83 c4 10             	add    $0x10,%esp
  801c37:	85 c0                	test   %eax,%eax
  801c39:	0f 88 89 00 00 00    	js     801cc8 <pipe+0x124>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c3f:	83 ec 0c             	sub    $0xc,%esp
  801c42:	ff 75 f0             	pushl  -0x10(%ebp)
  801c45:	e8 e0 f5 ff ff       	call   80122a <fd2data>
  801c4a:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c51:	50                   	push   %eax
  801c52:	6a 00                	push   $0x0
  801c54:	56                   	push   %esi
  801c55:	6a 00                	push   $0x0
  801c57:	e8 35 f1 ff ff       	call   800d91 <sys_page_map>
  801c5c:	89 c3                	mov    %eax,%ebx
  801c5e:	83 c4 20             	add    $0x20,%esp
  801c61:	85 c0                	test   %eax,%eax
  801c63:	78 55                	js     801cba <pipe+0x116>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801c65:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c6e:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801c70:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c73:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801c7a:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c80:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c83:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801c85:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c88:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801c8f:	83 ec 0c             	sub    $0xc,%esp
  801c92:	ff 75 f4             	pushl  -0xc(%ebp)
  801c95:	e8 80 f5 ff ff       	call   80121a <fd2num>
  801c9a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c9d:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801c9f:	83 c4 04             	add    $0x4,%esp
  801ca2:	ff 75 f0             	pushl  -0x10(%ebp)
  801ca5:	e8 70 f5 ff ff       	call   80121a <fd2num>
  801caa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cad:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801cb0:	83 c4 10             	add    $0x10,%esp
  801cb3:	b8 00 00 00 00       	mov    $0x0,%eax
  801cb8:	eb 30                	jmp    801cea <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  801cba:	83 ec 08             	sub    $0x8,%esp
  801cbd:	56                   	push   %esi
  801cbe:	6a 00                	push   $0x0
  801cc0:	e8 0e f1 ff ff       	call   800dd3 <sys_page_unmap>
  801cc5:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801cc8:	83 ec 08             	sub    $0x8,%esp
  801ccb:	ff 75 f0             	pushl  -0x10(%ebp)
  801cce:	6a 00                	push   $0x0
  801cd0:	e8 fe f0 ff ff       	call   800dd3 <sys_page_unmap>
  801cd5:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801cd8:	83 ec 08             	sub    $0x8,%esp
  801cdb:	ff 75 f4             	pushl  -0xc(%ebp)
  801cde:	6a 00                	push   $0x0
  801ce0:	e8 ee f0 ff ff       	call   800dd3 <sys_page_unmap>
  801ce5:	83 c4 10             	add    $0x10,%esp
  801ce8:	89 d8                	mov    %ebx,%eax
    err:
	return r;
}
  801cea:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ced:	5b                   	pop    %ebx
  801cee:	5e                   	pop    %esi
  801cef:	5d                   	pop    %ebp
  801cf0:	c3                   	ret    

00801cf1 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801cf1:	55                   	push   %ebp
  801cf2:	89 e5                	mov    %esp,%ebp
  801cf4:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801cf7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cfa:	50                   	push   %eax
  801cfb:	ff 75 08             	pushl  0x8(%ebp)
  801cfe:	e8 b2 f5 ff ff       	call   8012b5 <fd_lookup>
  801d03:	83 c4 10             	add    $0x10,%esp
  801d06:	85 c0                	test   %eax,%eax
  801d08:	78 18                	js     801d22 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801d0a:	83 ec 0c             	sub    $0xc,%esp
  801d0d:	ff 75 f4             	pushl  -0xc(%ebp)
  801d10:	e8 15 f5 ff ff       	call   80122a <fd2data>
	return _pipeisclosed(fd, p);
  801d15:	89 c2                	mov    %eax,%edx
  801d17:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d1a:	e8 17 fd ff ff       	call   801a36 <_pipeisclosed>
  801d1f:	83 c4 10             	add    $0x10,%esp
}
  801d22:	c9                   	leave  
  801d23:	c3                   	ret    

00801d24 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  801d24:	55                   	push   %ebp
  801d25:	89 e5                	mov    %esp,%ebp
  801d27:	56                   	push   %esi
  801d28:	53                   	push   %ebx
  801d29:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  801d2c:	85 f6                	test   %esi,%esi
  801d2e:	75 16                	jne    801d46 <wait+0x22>
  801d30:	68 03 2a 80 00       	push   $0x802a03
  801d35:	68 b8 29 80 00       	push   $0x8029b8
  801d3a:	6a 09                	push   $0x9
  801d3c:	68 0e 2a 80 00       	push   $0x802a0e
  801d41:	e8 db e4 ff ff       	call   800221 <_panic>
	e = &envs[ENVX(envid)];
  801d46:	89 f3                	mov    %esi,%ebx
  801d48:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  801d4e:	8d 14 9d 00 00 00 00 	lea    0x0(,%ebx,4),%edx
  801d55:	89 d8                	mov    %ebx,%eax
  801d57:	c1 e0 07             	shl    $0x7,%eax
  801d5a:	29 d0                	sub    %edx,%eax
  801d5c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801d61:	8b 40 48             	mov    0x48(%eax),%eax
  801d64:	39 c6                	cmp    %eax,%esi
  801d66:	75 31                	jne    801d99 <wait+0x75>
  801d68:	89 d8                	mov    %ebx,%eax
  801d6a:	c1 e0 07             	shl    $0x7,%eax
  801d6d:	29 d0                	sub    %edx,%eax
  801d6f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801d74:	8b 40 54             	mov    0x54(%eax),%eax
  801d77:	85 c0                	test   %eax,%eax
  801d79:	74 1e                	je     801d99 <wait+0x75>
  801d7b:	c1 e3 07             	shl    $0x7,%ebx
  801d7e:	29 d3                	sub    %edx,%ebx
  801d80:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
		sys_yield();
  801d86:	e8 a4 ef ff ff       	call   800d2f <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  801d8b:	8b 43 48             	mov    0x48(%ebx),%eax
  801d8e:	39 c6                	cmp    %eax,%esi
  801d90:	75 07                	jne    801d99 <wait+0x75>
  801d92:	8b 43 54             	mov    0x54(%ebx),%eax
  801d95:	85 c0                	test   %eax,%eax
  801d97:	75 ed                	jne    801d86 <wait+0x62>
		sys_yield();
}
  801d99:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d9c:	5b                   	pop    %ebx
  801d9d:	5e                   	pop    %esi
  801d9e:	5d                   	pop    %ebp
  801d9f:	c3                   	ret    

00801da0 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801da0:	55                   	push   %ebp
  801da1:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801da3:	b8 00 00 00 00       	mov    $0x0,%eax
  801da8:	5d                   	pop    %ebp
  801da9:	c3                   	ret    

00801daa <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801daa:	55                   	push   %ebp
  801dab:	89 e5                	mov    %esp,%ebp
  801dad:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801db0:	68 19 2a 80 00       	push   $0x802a19
  801db5:	ff 75 0c             	pushl  0xc(%ebp)
  801db8:	e8 21 eb ff ff       	call   8008de <strcpy>
	return 0;
}
  801dbd:	b8 00 00 00 00       	mov    $0x0,%eax
  801dc2:	c9                   	leave  
  801dc3:	c3                   	ret    

00801dc4 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801dc4:	55                   	push   %ebp
  801dc5:	89 e5                	mov    %esp,%ebp
  801dc7:	57                   	push   %edi
  801dc8:	56                   	push   %esi
  801dc9:	53                   	push   %ebx
  801dca:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801dd0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801dd4:	74 45                	je     801e1b <devcons_write+0x57>
  801dd6:	b8 00 00 00 00       	mov    $0x0,%eax
  801ddb:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801de0:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801de6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801de9:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  801deb:	83 fb 7f             	cmp    $0x7f,%ebx
  801dee:	76 05                	jbe    801df5 <devcons_write+0x31>
			m = sizeof(buf) - 1;
  801df0:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801df5:	83 ec 04             	sub    $0x4,%esp
  801df8:	53                   	push   %ebx
  801df9:	03 45 0c             	add    0xc(%ebp),%eax
  801dfc:	50                   	push   %eax
  801dfd:	57                   	push   %edi
  801dfe:	e8 a8 ec ff ff       	call   800aab <memmove>
		sys_cputs(buf, m);
  801e03:	83 c4 08             	add    $0x8,%esp
  801e06:	53                   	push   %ebx
  801e07:	57                   	push   %edi
  801e08:	e8 85 ee ff ff       	call   800c92 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e0d:	01 de                	add    %ebx,%esi
  801e0f:	89 f0                	mov    %esi,%eax
  801e11:	83 c4 10             	add    $0x10,%esp
  801e14:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e17:	72 cd                	jb     801de6 <devcons_write+0x22>
  801e19:	eb 05                	jmp    801e20 <devcons_write+0x5c>
  801e1b:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801e20:	89 f0                	mov    %esi,%eax
  801e22:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e25:	5b                   	pop    %ebx
  801e26:	5e                   	pop    %esi
  801e27:	5f                   	pop    %edi
  801e28:	5d                   	pop    %ebp
  801e29:	c3                   	ret    

00801e2a <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801e2a:	55                   	push   %ebp
  801e2b:	89 e5                	mov    %esp,%ebp
  801e2d:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801e30:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801e34:	75 07                	jne    801e3d <devcons_read+0x13>
  801e36:	eb 23                	jmp    801e5b <devcons_read+0x31>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801e38:	e8 f2 ee ff ff       	call   800d2f <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801e3d:	e8 6e ee ff ff       	call   800cb0 <sys_cgetc>
  801e42:	85 c0                	test   %eax,%eax
  801e44:	74 f2                	je     801e38 <devcons_read+0xe>
		sys_yield();
	if (c < 0)
  801e46:	85 c0                	test   %eax,%eax
  801e48:	78 1d                	js     801e67 <devcons_read+0x3d>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801e4a:	83 f8 04             	cmp    $0x4,%eax
  801e4d:	74 13                	je     801e62 <devcons_read+0x38>
		return 0;
	*(char*)vbuf = c;
  801e4f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e52:	88 02                	mov    %al,(%edx)
	return 1;
  801e54:	b8 01 00 00 00       	mov    $0x1,%eax
  801e59:	eb 0c                	jmp    801e67 <devcons_read+0x3d>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801e5b:	b8 00 00 00 00       	mov    $0x0,%eax
  801e60:	eb 05                	jmp    801e67 <devcons_read+0x3d>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801e62:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801e67:	c9                   	leave  
  801e68:	c3                   	ret    

00801e69 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801e69:	55                   	push   %ebp
  801e6a:	89 e5                	mov    %esp,%ebp
  801e6c:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801e6f:	8b 45 08             	mov    0x8(%ebp),%eax
  801e72:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801e75:	6a 01                	push   $0x1
  801e77:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e7a:	50                   	push   %eax
  801e7b:	e8 12 ee ff ff       	call   800c92 <sys_cputs>
}
  801e80:	83 c4 10             	add    $0x10,%esp
  801e83:	c9                   	leave  
  801e84:	c3                   	ret    

00801e85 <getchar>:

int
getchar(void)
{
  801e85:	55                   	push   %ebp
  801e86:	89 e5                	mov    %esp,%ebp
  801e88:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801e8b:	6a 01                	push   $0x1
  801e8d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e90:	50                   	push   %eax
  801e91:	6a 00                	push   $0x0
  801e93:	e8 9e f6 ff ff       	call   801536 <read>
	if (r < 0)
  801e98:	83 c4 10             	add    $0x10,%esp
  801e9b:	85 c0                	test   %eax,%eax
  801e9d:	78 0f                	js     801eae <getchar+0x29>
		return r;
	if (r < 1)
  801e9f:	85 c0                	test   %eax,%eax
  801ea1:	7e 06                	jle    801ea9 <getchar+0x24>
		return -E_EOF;
	return c;
  801ea3:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801ea7:	eb 05                	jmp    801eae <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801ea9:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801eae:	c9                   	leave  
  801eaf:	c3                   	ret    

00801eb0 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801eb0:	55                   	push   %ebp
  801eb1:	89 e5                	mov    %esp,%ebp
  801eb3:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801eb6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801eb9:	50                   	push   %eax
  801eba:	ff 75 08             	pushl  0x8(%ebp)
  801ebd:	e8 f3 f3 ff ff       	call   8012b5 <fd_lookup>
  801ec2:	83 c4 10             	add    $0x10,%esp
  801ec5:	85 c0                	test   %eax,%eax
  801ec7:	78 11                	js     801eda <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801ec9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ecc:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ed2:	39 10                	cmp    %edx,(%eax)
  801ed4:	0f 94 c0             	sete   %al
  801ed7:	0f b6 c0             	movzbl %al,%eax
}
  801eda:	c9                   	leave  
  801edb:	c3                   	ret    

00801edc <opencons>:

int
opencons(void)
{
  801edc:	55                   	push   %ebp
  801edd:	89 e5                	mov    %esp,%ebp
  801edf:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ee2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ee5:	50                   	push   %eax
  801ee6:	e8 56 f3 ff ff       	call   801241 <fd_alloc>
  801eeb:	83 c4 10             	add    $0x10,%esp
  801eee:	85 c0                	test   %eax,%eax
  801ef0:	78 3a                	js     801f2c <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ef2:	83 ec 04             	sub    $0x4,%esp
  801ef5:	68 07 04 00 00       	push   $0x407
  801efa:	ff 75 f4             	pushl  -0xc(%ebp)
  801efd:	6a 00                	push   $0x0
  801eff:	e8 4a ee ff ff       	call   800d4e <sys_page_alloc>
  801f04:	83 c4 10             	add    $0x10,%esp
  801f07:	85 c0                	test   %eax,%eax
  801f09:	78 21                	js     801f2c <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801f0b:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f11:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f14:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801f16:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f19:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801f20:	83 ec 0c             	sub    $0xc,%esp
  801f23:	50                   	push   %eax
  801f24:	e8 f1 f2 ff ff       	call   80121a <fd2num>
  801f29:	83 c4 10             	add    $0x10,%esp
}
  801f2c:	c9                   	leave  
  801f2d:	c3                   	ret    

00801f2e <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801f2e:	55                   	push   %ebp
  801f2f:	89 e5                	mov    %esp,%ebp
  801f31:	53                   	push   %ebx
  801f32:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (_pgfault_handler == 0) {
  801f35:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801f3c:	75 5b                	jne    801f99 <set_pgfault_handler+0x6b>
		// First time through!
		// LAB 4: Your code here.
		void *va = (void *)(UXSTACKTOP - PGSIZE);
		envid_t eid = sys_getenvid();
  801f3e:	e8 cd ed ff ff       	call   800d10 <sys_getenvid>
  801f43:	89 c3                	mov    %eax,%ebx
		r = sys_page_alloc(eid,va,PTE_P | PTE_U | PTE_W);
  801f45:	83 ec 04             	sub    $0x4,%esp
  801f48:	6a 07                	push   $0x7
  801f4a:	68 00 f0 bf ee       	push   $0xeebff000
  801f4f:	50                   	push   %eax
  801f50:	e8 f9 ed ff ff       	call   800d4e <sys_page_alloc>
		if(r<0) panic("set_pgfault_handler\n");
  801f55:	83 c4 10             	add    $0x10,%esp
  801f58:	85 c0                	test   %eax,%eax
  801f5a:	79 14                	jns    801f70 <set_pgfault_handler+0x42>
  801f5c:	83 ec 04             	sub    $0x4,%esp
  801f5f:	68 25 2a 80 00       	push   $0x802a25
  801f64:	6a 23                	push   $0x23
  801f66:	68 3a 2a 80 00       	push   $0x802a3a
  801f6b:	e8 b1 e2 ff ff       	call   800221 <_panic>
		r = sys_env_set_pgfault_upcall(eid,_pgfault_upcall);
  801f70:	83 ec 08             	sub    $0x8,%esp
  801f73:	68 a6 1f 80 00       	push   $0x801fa6
  801f78:	53                   	push   %ebx
  801f79:	e8 1b ef ff ff       	call   800e99 <sys_env_set_pgfault_upcall>
		if(r<0) panic("set_pgfault_handler\n");
  801f7e:	83 c4 10             	add    $0x10,%esp
  801f81:	85 c0                	test   %eax,%eax
  801f83:	79 14                	jns    801f99 <set_pgfault_handler+0x6b>
  801f85:	83 ec 04             	sub    $0x4,%esp
  801f88:	68 25 2a 80 00       	push   $0x802a25
  801f8d:	6a 25                	push   $0x25
  801f8f:	68 3a 2a 80 00       	push   $0x802a3a
  801f94:	e8 88 e2 ff ff       	call   800221 <_panic>
		// panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801f99:	8b 45 08             	mov    0x8(%ebp),%eax
  801f9c:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801fa1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801fa4:	c9                   	leave  
  801fa5:	c3                   	ret    

00801fa6 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801fa6:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801fa7:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801fac:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801fae:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl %esp,%ebx
  801fb1:	89 e3                	mov    %esp,%ebx
	movl 40(%esp),%eax 	// esp from utf_fault_va to utf_regs(end)
  801fb3:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl 48(%esp),%esp 	// 
  801fb7:	8b 64 24 30          	mov    0x30(%esp),%esp
	pushl %eax
  801fbb:	50                   	push   %eax
 
 
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	movl %ebx,%esp
  801fbc:	89 dc                	mov    %ebx,%esp
	subl $4,48(%esp)
  801fbe:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	popl %eax
  801fc3:	58                   	pop    %eax
	popl %eax
  801fc4:	58                   	pop    %eax
	popal
  801fc5:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	add $4,%esp
  801fc6:	83 c4 04             	add    $0x4,%esp
	popfl
  801fc9:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  801fca:	5c                   	pop    %esp
 
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801fcb:	c3                   	ret    

00801fcc <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801fcc:	55                   	push   %ebp
  801fcd:	89 e5                	mov    %esp,%ebp
  801fcf:	56                   	push   %esi
  801fd0:	53                   	push   %ebx
  801fd1:	8b 75 08             	mov    0x8(%ebp),%esi
  801fd4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fd7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");
	int r;
    if (pg != NULL) {
  801fda:	85 c0                	test   %eax,%eax
  801fdc:	74 0e                	je     801fec <ipc_recv+0x20>
        r = sys_ipc_recv(pg);
  801fde:	83 ec 0c             	sub    $0xc,%esp
  801fe1:	50                   	push   %eax
  801fe2:	e8 17 ef ff ff       	call   800efe <sys_ipc_recv>
  801fe7:	83 c4 10             	add    $0x10,%esp
  801fea:	eb 10                	jmp    801ffc <ipc_recv+0x30>
    } else {
        r = sys_ipc_recv((void *) UTOP);
  801fec:	83 ec 0c             	sub    $0xc,%esp
  801fef:	68 00 00 c0 ee       	push   $0xeec00000
  801ff4:	e8 05 ef ff ff       	call   800efe <sys_ipc_recv>
  801ff9:	83 c4 10             	add    $0x10,%esp
    }
    if (r < 0) {
  801ffc:	85 c0                	test   %eax,%eax
  801ffe:	79 16                	jns    802016 <ipc_recv+0x4a>
        // failed
        if (from_env_store != NULL) *from_env_store = 0;
  802000:	85 f6                	test   %esi,%esi
  802002:	74 06                	je     80200a <ipc_recv+0x3e>
  802004:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        if (perm_store != NULL) *perm_store = 0;
  80200a:	85 db                	test   %ebx,%ebx
  80200c:	74 2c                	je     80203a <ipc_recv+0x6e>
  80200e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  802014:	eb 24                	jmp    80203a <ipc_recv+0x6e>
        return r;
    } else {
        if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  802016:	85 f6                	test   %esi,%esi
  802018:	74 0a                	je     802024 <ipc_recv+0x58>
  80201a:	a1 20 44 80 00       	mov    0x804420,%eax
  80201f:	8b 40 74             	mov    0x74(%eax),%eax
  802022:	89 06                	mov    %eax,(%esi)
        if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  802024:	85 db                	test   %ebx,%ebx
  802026:	74 0a                	je     802032 <ipc_recv+0x66>
  802028:	a1 20 44 80 00       	mov    0x804420,%eax
  80202d:	8b 40 78             	mov    0x78(%eax),%eax
  802030:	89 03                	mov    %eax,(%ebx)
        return thisenv->env_ipc_value;
  802032:	a1 20 44 80 00       	mov    0x804420,%eax
  802037:	8b 40 70             	mov    0x70(%eax),%eax
    }
 
	return 0;
}
  80203a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80203d:	5b                   	pop    %ebx
  80203e:	5e                   	pop    %esi
  80203f:	5d                   	pop    %ebp
  802040:	c3                   	ret    

00802041 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802041:	55                   	push   %ebp
  802042:	89 e5                	mov    %esp,%ebp
  802044:	57                   	push   %edi
  802045:	56                   	push   %esi
  802046:	53                   	push   %ebx
  802047:	83 ec 0c             	sub    $0xc,%esp
  80204a:	8b 75 10             	mov    0x10(%ebp),%esi
  80204d:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");
	int r;
    if (pg == NULL) pg = (void *)UTOP;
  802050:	85 f6                	test   %esi,%esi
  802052:	75 05                	jne    802059 <ipc_send+0x18>
  802054:	be 00 00 c0 ee       	mov    $0xeec00000,%esi
    do {
        r = sys_ipc_try_send(to_env, val, pg, perm);
  802059:	57                   	push   %edi
  80205a:	56                   	push   %esi
  80205b:	ff 75 0c             	pushl  0xc(%ebp)
  80205e:	ff 75 08             	pushl  0x8(%ebp)
  802061:	e8 75 ee ff ff       	call   800edb <sys_ipc_try_send>
  802066:	89 c3                	mov    %eax,%ebx
        if (r < 0 && r != -E_IPC_NOT_RECV) panic("ipc send failed: %e", r);
  802068:	83 c4 10             	add    $0x10,%esp
  80206b:	85 c0                	test   %eax,%eax
  80206d:	79 17                	jns    802086 <ipc_send+0x45>
  80206f:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802072:	74 1d                	je     802091 <ipc_send+0x50>
  802074:	50                   	push   %eax
  802075:	68 48 2a 80 00       	push   $0x802a48
  80207a:	6a 40                	push   $0x40
  80207c:	68 5c 2a 80 00       	push   $0x802a5c
  802081:	e8 9b e1 ff ff       	call   800221 <_panic>
        sys_yield();
  802086:	e8 a4 ec ff ff       	call   800d2f <sys_yield>
    } while (r != 0);
  80208b:	85 db                	test   %ebx,%ebx
  80208d:	75 ca                	jne    802059 <ipc_send+0x18>
  80208f:	eb 07                	jmp    802098 <ipc_send+0x57>
	int r;
    if (pg == NULL) pg = (void *)UTOP;
    do {
        r = sys_ipc_try_send(to_env, val, pg, perm);
        if (r < 0 && r != -E_IPC_NOT_RECV) panic("ipc send failed: %e", r);
        sys_yield();
  802091:	e8 99 ec ff ff       	call   800d2f <sys_yield>
  802096:	eb c1                	jmp    802059 <ipc_send+0x18>
    } while (r != 0);
}
  802098:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80209b:	5b                   	pop    %ebx
  80209c:	5e                   	pop    %esi
  80209d:	5f                   	pop    %edi
  80209e:	5d                   	pop    %ebp
  80209f:	c3                   	ret    

008020a0 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8020a0:	55                   	push   %ebp
  8020a1:	89 e5                	mov    %esp,%ebp
  8020a3:	53                   	push   %ebx
  8020a4:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  8020a7:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  8020ac:	39 c1                	cmp    %eax,%ecx
  8020ae:	74 21                	je     8020d1 <ipc_find_env+0x31>
  8020b0:	ba 01 00 00 00       	mov    $0x1,%edx
  8020b5:	8d 1c 95 00 00 00 00 	lea    0x0(,%edx,4),%ebx
  8020bc:	89 d0                	mov    %edx,%eax
  8020be:	c1 e0 07             	shl    $0x7,%eax
  8020c1:	29 d8                	sub    %ebx,%eax
  8020c3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8020c8:	8b 40 50             	mov    0x50(%eax),%eax
  8020cb:	39 c8                	cmp    %ecx,%eax
  8020cd:	75 1b                	jne    8020ea <ipc_find_env+0x4a>
  8020cf:	eb 05                	jmp    8020d6 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8020d1:	ba 00 00 00 00       	mov    $0x0,%edx
		if (envs[i].env_type == type)
			return envs[i].env_id;
  8020d6:	8d 04 95 00 00 00 00 	lea    0x0(,%edx,4),%eax
  8020dd:	c1 e2 07             	shl    $0x7,%edx
  8020e0:	29 c2                	sub    %eax,%edx
  8020e2:	8b 82 48 00 c0 ee    	mov    -0x113fffb8(%edx),%eax
  8020e8:	eb 0e                	jmp    8020f8 <ipc_find_env+0x58>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8020ea:	42                   	inc    %edx
  8020eb:	81 fa 00 04 00 00    	cmp    $0x400,%edx
  8020f1:	75 c2                	jne    8020b5 <ipc_find_env+0x15>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8020f3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8020f8:	5b                   	pop    %ebx
  8020f9:	5d                   	pop    %ebp
  8020fa:	c3                   	ret    

008020fb <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8020fb:	55                   	push   %ebp
  8020fc:	89 e5                	mov    %esp,%ebp
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8020fe:	8b 45 08             	mov    0x8(%ebp),%eax
  802101:	c1 e8 16             	shr    $0x16,%eax
  802104:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80210b:	a8 01                	test   $0x1,%al
  80210d:	74 21                	je     802130 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  80210f:	8b 45 08             	mov    0x8(%ebp),%eax
  802112:	c1 e8 0c             	shr    $0xc,%eax
  802115:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  80211c:	a8 01                	test   $0x1,%al
  80211e:	74 17                	je     802137 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802120:	c1 e8 0c             	shr    $0xc,%eax
  802123:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  80212a:	ef 
  80212b:	0f b7 c0             	movzwl %ax,%eax
  80212e:	eb 0c                	jmp    80213c <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  802130:	b8 00 00 00 00       	mov    $0x0,%eax
  802135:	eb 05                	jmp    80213c <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  802137:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  80213c:	5d                   	pop    %ebp
  80213d:	c3                   	ret    
  80213e:	66 90                	xchg   %ax,%ax

00802140 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  802140:	55                   	push   %ebp
  802141:	57                   	push   %edi
  802142:	56                   	push   %esi
  802143:	53                   	push   %ebx
  802144:	83 ec 1c             	sub    $0x1c,%esp
  802147:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80214b:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  80214f:	8b 7c 24 38          	mov    0x38(%esp),%edi
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  802153:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802157:	89 ca                	mov    %ecx,%edx
  const DWunion dd = {.ll = d};
  802159:	89 f8                	mov    %edi,%eax
  80215b:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  80215f:	85 f6                	test   %esi,%esi
  802161:	75 2d                	jne    802190 <__udivdi3+0x50>
    {
      if (d0 > n1)
  802163:	39 cf                	cmp    %ecx,%edi
  802165:	77 65                	ja     8021cc <__udivdi3+0x8c>
  802167:	89 fd                	mov    %edi,%ebp
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802169:	85 ff                	test   %edi,%edi
  80216b:	75 0b                	jne    802178 <__udivdi3+0x38>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  80216d:	b8 01 00 00 00       	mov    $0x1,%eax
  802172:	31 d2                	xor    %edx,%edx
  802174:	f7 f7                	div    %edi
  802176:	89 c5                	mov    %eax,%ebp

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802178:	31 d2                	xor    %edx,%edx
  80217a:	89 c8                	mov    %ecx,%eax
  80217c:	f7 f5                	div    %ebp
  80217e:	89 c1                	mov    %eax,%ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802180:	89 d8                	mov    %ebx,%eax
  802182:	f7 f5                	div    %ebp
  802184:	89 cf                	mov    %ecx,%edi
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802186:	89 fa                	mov    %edi,%edx
  802188:	83 c4 1c             	add    $0x1c,%esp
  80218b:	5b                   	pop    %ebx
  80218c:	5e                   	pop    %esi
  80218d:	5f                   	pop    %edi
  80218e:	5d                   	pop    %ebp
  80218f:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802190:	39 ce                	cmp    %ecx,%esi
  802192:	77 28                	ja     8021bc <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802194:	0f bd fe             	bsr    %esi,%edi
	  if (bm == 0)
  802197:	83 f7 1f             	xor    $0x1f,%edi
  80219a:	75 40                	jne    8021dc <__udivdi3+0x9c>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  80219c:	39 ce                	cmp    %ecx,%esi
  80219e:	72 0a                	jb     8021aa <__udivdi3+0x6a>
  8021a0:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8021a4:	0f 87 9e 00 00 00    	ja     802248 <__udivdi3+0x108>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8021aa:	b8 01 00 00 00       	mov    $0x1,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8021af:	89 fa                	mov    %edi,%edx
  8021b1:	83 c4 1c             	add    $0x1c,%esp
  8021b4:	5b                   	pop    %ebx
  8021b5:	5e                   	pop    %esi
  8021b6:	5f                   	pop    %edi
  8021b7:	5d                   	pop    %ebp
  8021b8:	c3                   	ret    
  8021b9:	8d 76 00             	lea    0x0(%esi),%esi
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8021bc:	31 ff                	xor    %edi,%edi
  8021be:	31 c0                	xor    %eax,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8021c0:	89 fa                	mov    %edi,%edx
  8021c2:	83 c4 1c             	add    $0x1c,%esp
  8021c5:	5b                   	pop    %ebx
  8021c6:	5e                   	pop    %esi
  8021c7:	5f                   	pop    %edi
  8021c8:	5d                   	pop    %ebp
  8021c9:	c3                   	ret    
  8021ca:	66 90                	xchg   %ax,%ax
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8021cc:	89 d8                	mov    %ebx,%eax
  8021ce:	f7 f7                	div    %edi
  8021d0:	31 ff                	xor    %edi,%edi
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8021d2:	89 fa                	mov    %edi,%edx
  8021d4:	83 c4 1c             	add    $0x1c,%esp
  8021d7:	5b                   	pop    %ebx
  8021d8:	5e                   	pop    %esi
  8021d9:	5f                   	pop    %edi
  8021da:	5d                   	pop    %ebp
  8021db:	c3                   	ret    
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8021dc:	bd 20 00 00 00       	mov    $0x20,%ebp
  8021e1:	89 eb                	mov    %ebp,%ebx
  8021e3:	29 fb                	sub    %edi,%ebx

	      d1 = (d1 << bm) | (d0 >> b);
  8021e5:	89 f9                	mov    %edi,%ecx
  8021e7:	d3 e6                	shl    %cl,%esi
  8021e9:	89 c5                	mov    %eax,%ebp
  8021eb:	88 d9                	mov    %bl,%cl
  8021ed:	d3 ed                	shr    %cl,%ebp
  8021ef:	89 e9                	mov    %ebp,%ecx
  8021f1:	09 f1                	or     %esi,%ecx
  8021f3:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
	      d0 = d0 << bm;
  8021f7:	89 f9                	mov    %edi,%ecx
  8021f9:	d3 e0                	shl    %cl,%eax
  8021fb:	89 c5                	mov    %eax,%ebp
	      n2 = n1 >> b;
  8021fd:	89 d6                	mov    %edx,%esi
  8021ff:	88 d9                	mov    %bl,%cl
  802201:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
  802203:	89 f9                	mov    %edi,%ecx
  802205:	d3 e2                	shl    %cl,%edx
  802207:	8b 44 24 08          	mov    0x8(%esp),%eax
  80220b:	88 d9                	mov    %bl,%cl
  80220d:	d3 e8                	shr    %cl,%eax
  80220f:	09 c2                	or     %eax,%edx
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802211:	89 d0                	mov    %edx,%eax
  802213:	89 f2                	mov    %esi,%edx
  802215:	f7 74 24 0c          	divl   0xc(%esp)
  802219:	89 d6                	mov    %edx,%esi
  80221b:	89 c3                	mov    %eax,%ebx
	      umul_ppmm (m1, m0, q0, d0);
  80221d:	f7 e5                	mul    %ebp

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80221f:	39 d6                	cmp    %edx,%esi
  802221:	72 19                	jb     80223c <__udivdi3+0xfc>
  802223:	74 0b                	je     802230 <__udivdi3+0xf0>
  802225:	89 d8                	mov    %ebx,%eax
  802227:	31 ff                	xor    %edi,%edi
  802229:	e9 58 ff ff ff       	jmp    802186 <__udivdi3+0x46>
  80222e:	66 90                	xchg   %ax,%ax
  802230:	8b 54 24 08          	mov    0x8(%esp),%edx
  802234:	89 f9                	mov    %edi,%ecx
  802236:	d3 e2                	shl    %cl,%edx
  802238:	39 c2                	cmp    %eax,%edx
  80223a:	73 e9                	jae    802225 <__udivdi3+0xe5>
  80223c:	8d 43 ff             	lea    -0x1(%ebx),%eax
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  80223f:	31 ff                	xor    %edi,%edi
  802241:	e9 40 ff ff ff       	jmp    802186 <__udivdi3+0x46>
  802246:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802248:	31 c0                	xor    %eax,%eax
  80224a:	e9 37 ff ff ff       	jmp    802186 <__udivdi3+0x46>
  80224f:	90                   	nop

00802250 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  802250:	55                   	push   %ebp
  802251:	57                   	push   %edi
  802252:	56                   	push   %esi
  802253:	53                   	push   %ebx
  802254:	83 ec 1c             	sub    $0x1c,%esp
  802257:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80225b:	8b 74 24 34          	mov    0x34(%esp),%esi
  80225f:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802263:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  802267:	89 44 24 0c          	mov    %eax,0xc(%esp)
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  80226b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80226f:	89 f3                	mov    %esi,%ebx
  const DWunion dd = {.ll = d};
  802271:	89 fa                	mov    %edi,%edx
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  802273:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  n1 = nn.s.high;
  802277:	89 34 24             	mov    %esi,(%esp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  80227a:	85 c0                	test   %eax,%eax
  80227c:	75 1a                	jne    802298 <__umoddi3+0x48>
    {
      if (d0 > n1)
  80227e:	39 f7                	cmp    %esi,%edi
  802280:	0f 86 a2 00 00 00    	jbe    802328 <__umoddi3+0xd8>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802286:	89 c8                	mov    %ecx,%eax
  802288:	89 f2                	mov    %esi,%edx
  80228a:	f7 f7                	div    %edi
  80228c:	89 d0                	mov    %edx,%eax

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  80228e:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802290:	83 c4 1c             	add    $0x1c,%esp
  802293:	5b                   	pop    %ebx
  802294:	5e                   	pop    %esi
  802295:	5f                   	pop    %edi
  802296:	5d                   	pop    %ebp
  802297:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802298:	39 f0                	cmp    %esi,%eax
  80229a:	0f 87 ac 00 00 00    	ja     80234c <__umoddi3+0xfc>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8022a0:	0f bd e8             	bsr    %eax,%ebp
	  if (bm == 0)
  8022a3:	83 f5 1f             	xor    $0x1f,%ebp
  8022a6:	0f 84 ac 00 00 00    	je     802358 <__umoddi3+0x108>
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8022ac:	bf 20 00 00 00       	mov    $0x20,%edi
  8022b1:	29 ef                	sub    %ebp,%edi
  8022b3:	89 fe                	mov    %edi,%esi
  8022b5:	89 7c 24 0c          	mov    %edi,0xc(%esp)

	      d1 = (d1 << bm) | (d0 >> b);
  8022b9:	89 e9                	mov    %ebp,%ecx
  8022bb:	d3 e0                	shl    %cl,%eax
  8022bd:	89 d7                	mov    %edx,%edi
  8022bf:	89 f1                	mov    %esi,%ecx
  8022c1:	d3 ef                	shr    %cl,%edi
  8022c3:	09 c7                	or     %eax,%edi
	      d0 = d0 << bm;
  8022c5:	89 e9                	mov    %ebp,%ecx
  8022c7:	d3 e2                	shl    %cl,%edx
  8022c9:	89 14 24             	mov    %edx,(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8022cc:	89 d8                	mov    %ebx,%eax
  8022ce:	d3 e0                	shl    %cl,%eax
  8022d0:	89 c2                	mov    %eax,%edx
	      n0 = n0 << bm;
  8022d2:	8b 44 24 08          	mov    0x8(%esp),%eax
  8022d6:	d3 e0                	shl    %cl,%eax
  8022d8:	89 44 24 04          	mov    %eax,0x4(%esp)

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8022dc:	8b 44 24 08          	mov    0x8(%esp),%eax
  8022e0:	89 f1                	mov    %esi,%ecx
  8022e2:	d3 e8                	shr    %cl,%eax
  8022e4:	09 d0                	or     %edx,%eax
  8022e6:	d3 eb                	shr    %cl,%ebx
  8022e8:	89 da                	mov    %ebx,%edx
  8022ea:	f7 f7                	div    %edi
  8022ec:	89 d3                	mov    %edx,%ebx
	      umul_ppmm (m1, m0, q0, d0);
  8022ee:	f7 24 24             	mull   (%esp)
  8022f1:	89 c6                	mov    %eax,%esi
  8022f3:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8022f5:	39 d3                	cmp    %edx,%ebx
  8022f7:	0f 82 87 00 00 00    	jb     802384 <__umoddi3+0x134>
  8022fd:	0f 84 91 00 00 00    	je     802394 <__umoddi3+0x144>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  802303:	8b 54 24 04          	mov    0x4(%esp),%edx
  802307:	29 f2                	sub    %esi,%edx
  802309:	19 cb                	sbb    %ecx,%ebx
		  rr.s.low = (n1 << b) | (n0 >> bm);
  80230b:	89 d8                	mov    %ebx,%eax
  80230d:	8a 4c 24 0c          	mov    0xc(%esp),%cl
  802311:	d3 e0                	shl    %cl,%eax
  802313:	89 e9                	mov    %ebp,%ecx
  802315:	d3 ea                	shr    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  802317:	09 d0                	or     %edx,%eax
  802319:	89 e9                	mov    %ebp,%ecx
  80231b:	d3 eb                	shr    %cl,%ebx
  80231d:	89 da                	mov    %ebx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80231f:	83 c4 1c             	add    $0x1c,%esp
  802322:	5b                   	pop    %ebx
  802323:	5e                   	pop    %esi
  802324:	5f                   	pop    %edi
  802325:	5d                   	pop    %ebp
  802326:	c3                   	ret    
  802327:	90                   	nop
  802328:	89 fd                	mov    %edi,%ebp
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  80232a:	85 ff                	test   %edi,%edi
  80232c:	75 0b                	jne    802339 <__umoddi3+0xe9>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  80232e:	b8 01 00 00 00       	mov    $0x1,%eax
  802333:	31 d2                	xor    %edx,%edx
  802335:	f7 f7                	div    %edi
  802337:	89 c5                	mov    %eax,%ebp

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802339:	89 f0                	mov    %esi,%eax
  80233b:	31 d2                	xor    %edx,%edx
  80233d:	f7 f5                	div    %ebp
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80233f:	89 c8                	mov    %ecx,%eax
  802341:	f7 f5                	div    %ebp
  802343:	89 d0                	mov    %edx,%eax
  802345:	e9 44 ff ff ff       	jmp    80228e <__umoddi3+0x3e>
  80234a:	66 90                	xchg   %ax,%ax
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  80234c:	89 c8                	mov    %ecx,%eax
  80234e:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802350:	83 c4 1c             	add    $0x1c,%esp
  802353:	5b                   	pop    %ebx
  802354:	5e                   	pop    %esi
  802355:	5f                   	pop    %edi
  802356:	5d                   	pop    %ebp
  802357:	c3                   	ret    

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802358:	3b 04 24             	cmp    (%esp),%eax
  80235b:	72 06                	jb     802363 <__umoddi3+0x113>
  80235d:	3b 7c 24 04          	cmp    0x4(%esp),%edi
  802361:	77 0f                	ja     802372 <__umoddi3+0x122>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802363:	89 f2                	mov    %esi,%edx
  802365:	29 f9                	sub    %edi,%ecx
  802367:	1b 54 24 0c          	sbb    0xc(%esp),%edx
  80236b:	89 14 24             	mov    %edx,(%esp)
  80236e:	89 4c 24 04          	mov    %ecx,0x4(%esp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  802372:	8b 44 24 04          	mov    0x4(%esp),%eax
  802376:	8b 14 24             	mov    (%esp),%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802379:	83 c4 1c             	add    $0x1c,%esp
  80237c:	5b                   	pop    %ebx
  80237d:	5e                   	pop    %esi
  80237e:	5f                   	pop    %edi
  80237f:	5d                   	pop    %ebp
  802380:	c3                   	ret    
  802381:	8d 76 00             	lea    0x0(%esi),%esi
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802384:	2b 04 24             	sub    (%esp),%eax
  802387:	19 fa                	sbb    %edi,%edx
  802389:	89 d1                	mov    %edx,%ecx
  80238b:	89 c6                	mov    %eax,%esi
  80238d:	e9 71 ff ff ff       	jmp    802303 <__umoddi3+0xb3>
  802392:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802394:	39 44 24 04          	cmp    %eax,0x4(%esp)
  802398:	72 ea                	jb     802384 <__umoddi3+0x134>
  80239a:	89 d9                	mov    %ebx,%ecx
  80239c:	e9 62 ff ff ff       	jmp    802303 <__umoddi3+0xb3>
