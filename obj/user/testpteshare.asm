
obj/user/testpteshare.debug:     file format elf32-i386


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
  80002c:	e8 4f 01 00 00       	call   800180 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <childofspawn>:
	breakpoint();
}

void
childofspawn(void)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	strcpy(VA, msg2);
  800039:	ff 35 00 30 80 00    	pushl  0x803000
  80003f:	68 00 00 00 a0       	push   $0xa0000000
  800044:	e8 5d 08 00 00       	call   8008a6 <strcpy>
	exit();
  800049:	e8 81 01 00 00       	call   8001cf <exit>
}
  80004e:	83 c4 10             	add    $0x10,%esp
  800051:	c9                   	leave  
  800052:	c3                   	ret    

00800053 <umain>:

void childofspawn(void);

void
umain(int argc, char **argv)
{
  800053:	55                   	push   %ebp
  800054:	89 e5                	mov    %esp,%ebp
  800056:	53                   	push   %ebx
  800057:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (argc != 0)
  80005a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  80005e:	74 05                	je     800065 <umain+0x12>
		childofspawn();
  800060:	e8 ce ff ff ff       	call   800033 <childofspawn>

	if ((r = sys_page_alloc(0, VA, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800065:	83 ec 04             	sub    $0x4,%esp
  800068:	68 07 04 00 00       	push   $0x407
  80006d:	68 00 00 00 a0       	push   $0xa0000000
  800072:	6a 00                	push   $0x0
  800074:	e8 9d 0c 00 00       	call   800d16 <sys_page_alloc>
  800079:	83 c4 10             	add    $0x10,%esp
  80007c:	85 c0                	test   %eax,%eax
  80007e:	79 12                	jns    800092 <umain+0x3f>
		panic("sys_page_alloc: %e", r);
  800080:	50                   	push   %eax
  800081:	68 0c 29 80 00       	push   $0x80290c
  800086:	6a 13                	push   $0x13
  800088:	68 1f 29 80 00       	push   $0x80291f
  80008d:	e8 57 01 00 00       	call   8001e9 <_panic>

	// check fork
	if ((r = fork()) < 0)
  800092:	e8 5f 0f 00 00       	call   800ff6 <fork>
  800097:	89 c3                	mov    %eax,%ebx
  800099:	85 c0                	test   %eax,%eax
  80009b:	79 12                	jns    8000af <umain+0x5c>
		panic("fork: %e", r);
  80009d:	50                   	push   %eax
  80009e:	68 33 29 80 00       	push   $0x802933
  8000a3:	6a 17                	push   $0x17
  8000a5:	68 1f 29 80 00       	push   $0x80291f
  8000aa:	e8 3a 01 00 00       	call   8001e9 <_panic>
	if (r == 0) {
  8000af:	85 c0                	test   %eax,%eax
  8000b1:	75 1b                	jne    8000ce <umain+0x7b>
		strcpy(VA, msg);
  8000b3:	83 ec 08             	sub    $0x8,%esp
  8000b6:	ff 35 04 30 80 00    	pushl  0x803004
  8000bc:	68 00 00 00 a0       	push   $0xa0000000
  8000c1:	e8 e0 07 00 00       	call   8008a6 <strcpy>
		exit();
  8000c6:	e8 04 01 00 00       	call   8001cf <exit>
  8000cb:	83 c4 10             	add    $0x10,%esp
	}
	wait(r);
  8000ce:	83 ec 0c             	sub    $0xc,%esp
  8000d1:	53                   	push   %ebx
  8000d2:	e8 a9 21 00 00       	call   802280 <wait>
	cprintf("fork handles PTE_SHARE %s\n", strcmp(VA, msg) == 0 ? "right" : "wrong");
  8000d7:	83 c4 08             	add    $0x8,%esp
  8000da:	ff 35 04 30 80 00    	pushl  0x803004
  8000e0:	68 00 00 00 a0       	push   $0xa0000000
  8000e5:	e8 6c 08 00 00       	call   800956 <strcmp>
  8000ea:	83 c4 10             	add    $0x10,%esp
  8000ed:	85 c0                	test   %eax,%eax
  8000ef:	74 07                	je     8000f8 <umain+0xa5>
  8000f1:	b8 06 29 80 00       	mov    $0x802906,%eax
  8000f6:	eb 05                	jmp    8000fd <umain+0xaa>
  8000f8:	b8 00 29 80 00       	mov    $0x802900,%eax
  8000fd:	83 ec 08             	sub    $0x8,%esp
  800100:	50                   	push   %eax
  800101:	68 3c 29 80 00       	push   $0x80293c
  800106:	e8 b6 01 00 00       	call   8002c1 <cprintf>

	// check spawn
	if ((r = spawnl("/testpteshare", "testpteshare", "arg", 0)) < 0)
  80010b:	6a 00                	push   $0x0
  80010d:	68 57 29 80 00       	push   $0x802957
  800112:	68 5c 29 80 00       	push   $0x80295c
  800117:	68 5b 29 80 00       	push   $0x80295b
  80011c:	e8 67 1d 00 00       	call   801e88 <spawnl>
  800121:	83 c4 20             	add    $0x20,%esp
  800124:	85 c0                	test   %eax,%eax
  800126:	79 12                	jns    80013a <umain+0xe7>
		panic("spawn: %e", r);
  800128:	50                   	push   %eax
  800129:	68 69 29 80 00       	push   $0x802969
  80012e:	6a 21                	push   $0x21
  800130:	68 1f 29 80 00       	push   $0x80291f
  800135:	e8 af 00 00 00       	call   8001e9 <_panic>
	wait(r);
  80013a:	83 ec 0c             	sub    $0xc,%esp
  80013d:	50                   	push   %eax
  80013e:	e8 3d 21 00 00       	call   802280 <wait>
	cprintf("spawn handles PTE_SHARE %s\n", strcmp(VA, msg2) == 0 ? "right" : "wrong");
  800143:	83 c4 08             	add    $0x8,%esp
  800146:	ff 35 00 30 80 00    	pushl  0x803000
  80014c:	68 00 00 00 a0       	push   $0xa0000000
  800151:	e8 00 08 00 00       	call   800956 <strcmp>
  800156:	83 c4 10             	add    $0x10,%esp
  800159:	85 c0                	test   %eax,%eax
  80015b:	74 07                	je     800164 <umain+0x111>
  80015d:	b8 06 29 80 00       	mov    $0x802906,%eax
  800162:	eb 05                	jmp    800169 <umain+0x116>
  800164:	b8 00 29 80 00       	mov    $0x802900,%eax
  800169:	83 ec 08             	sub    $0x8,%esp
  80016c:	50                   	push   %eax
  80016d:	68 73 29 80 00       	push   $0x802973
  800172:	e8 4a 01 00 00       	call   8002c1 <cprintf>
static __inline uint64_t read_tsc(void) __attribute__((always_inline));

static __inline void
breakpoint(void)
{
	__asm __volatile("int3");
  800177:	cc                   	int3   

	breakpoint();
}
  800178:	83 c4 10             	add    $0x10,%esp
  80017b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80017e:	c9                   	leave  
  80017f:	c3                   	ret    

00800180 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800180:	55                   	push   %ebp
  800181:	89 e5                	mov    %esp,%ebp
  800183:	56                   	push   %esi
  800184:	53                   	push   %ebx
  800185:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800188:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80018b:	e8 48 0b 00 00       	call   800cd8 <sys_getenvid>
  800190:	25 ff 03 00 00       	and    $0x3ff,%eax
  800195:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80019c:	c1 e0 07             	shl    $0x7,%eax
  80019f:	29 d0                	sub    %edx,%eax
  8001a1:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001a6:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001ab:	85 db                	test   %ebx,%ebx
  8001ad:	7e 07                	jle    8001b6 <libmain+0x36>
		binaryname = argv[0];
  8001af:	8b 06                	mov    (%esi),%eax
  8001b1:	a3 08 30 80 00       	mov    %eax,0x803008

	// call user main routine
	umain(argc, argv);
  8001b6:	83 ec 08             	sub    $0x8,%esp
  8001b9:	56                   	push   %esi
  8001ba:	53                   	push   %ebx
  8001bb:	e8 93 fe ff ff       	call   800053 <umain>

	// exit gracefully
	exit();
  8001c0:	e8 0a 00 00 00       	call   8001cf <exit>
}
  8001c5:	83 c4 10             	add    $0x10,%esp
  8001c8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001cb:	5b                   	pop    %ebx
  8001cc:	5e                   	pop    %esi
  8001cd:	5d                   	pop    %ebp
  8001ce:	c3                   	ret    

008001cf <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001cf:	55                   	push   %ebp
  8001d0:	89 e5                	mov    %esp,%ebp
  8001d2:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8001d5:	e8 17 12 00 00       	call   8013f1 <close_all>
	sys_env_destroy(0);
  8001da:	83 ec 0c             	sub    $0xc,%esp
  8001dd:	6a 00                	push   $0x0
  8001df:	e8 b3 0a 00 00       	call   800c97 <sys_env_destroy>
}
  8001e4:	83 c4 10             	add    $0x10,%esp
  8001e7:	c9                   	leave  
  8001e8:	c3                   	ret    

008001e9 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8001e9:	55                   	push   %ebp
  8001ea:	89 e5                	mov    %esp,%ebp
  8001ec:	56                   	push   %esi
  8001ed:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8001ee:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001f1:	8b 35 08 30 80 00    	mov    0x803008,%esi
  8001f7:	e8 dc 0a 00 00       	call   800cd8 <sys_getenvid>
  8001fc:	83 ec 0c             	sub    $0xc,%esp
  8001ff:	ff 75 0c             	pushl  0xc(%ebp)
  800202:	ff 75 08             	pushl  0x8(%ebp)
  800205:	56                   	push   %esi
  800206:	50                   	push   %eax
  800207:	68 b8 29 80 00       	push   $0x8029b8
  80020c:	e8 b0 00 00 00       	call   8002c1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800211:	83 c4 18             	add    $0x18,%esp
  800214:	53                   	push   %ebx
  800215:	ff 75 10             	pushl  0x10(%ebp)
  800218:	e8 53 00 00 00       	call   800270 <vcprintf>
	cprintf("\n");
  80021d:	c7 04 24 4b 2d 80 00 	movl   $0x802d4b,(%esp)
  800224:	e8 98 00 00 00       	call   8002c1 <cprintf>
  800229:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80022c:	cc                   	int3   
  80022d:	eb fd                	jmp    80022c <_panic+0x43>

0080022f <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80022f:	55                   	push   %ebp
  800230:	89 e5                	mov    %esp,%ebp
  800232:	53                   	push   %ebx
  800233:	83 ec 04             	sub    $0x4,%esp
  800236:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800239:	8b 13                	mov    (%ebx),%edx
  80023b:	8d 42 01             	lea    0x1(%edx),%eax
  80023e:	89 03                	mov    %eax,(%ebx)
  800240:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800243:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800247:	3d ff 00 00 00       	cmp    $0xff,%eax
  80024c:	75 1a                	jne    800268 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80024e:	83 ec 08             	sub    $0x8,%esp
  800251:	68 ff 00 00 00       	push   $0xff
  800256:	8d 43 08             	lea    0x8(%ebx),%eax
  800259:	50                   	push   %eax
  80025a:	e8 fb 09 00 00       	call   800c5a <sys_cputs>
		b->idx = 0;
  80025f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800265:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800268:	ff 43 04             	incl   0x4(%ebx)
}
  80026b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80026e:	c9                   	leave  
  80026f:	c3                   	ret    

00800270 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800270:	55                   	push   %ebp
  800271:	89 e5                	mov    %esp,%ebp
  800273:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800279:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800280:	00 00 00 
	b.cnt = 0;
  800283:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80028a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80028d:	ff 75 0c             	pushl  0xc(%ebp)
  800290:	ff 75 08             	pushl  0x8(%ebp)
  800293:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800299:	50                   	push   %eax
  80029a:	68 2f 02 80 00       	push   $0x80022f
  80029f:	e8 54 01 00 00       	call   8003f8 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002a4:	83 c4 08             	add    $0x8,%esp
  8002a7:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8002ad:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002b3:	50                   	push   %eax
  8002b4:	e8 a1 09 00 00       	call   800c5a <sys_cputs>

	return b.cnt;
}
  8002b9:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002bf:	c9                   	leave  
  8002c0:	c3                   	ret    

008002c1 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002c1:	55                   	push   %ebp
  8002c2:	89 e5                	mov    %esp,%ebp
  8002c4:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002c7:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002ca:	50                   	push   %eax
  8002cb:	ff 75 08             	pushl  0x8(%ebp)
  8002ce:	e8 9d ff ff ff       	call   800270 <vcprintf>
	va_end(ap);

	return cnt;
}
  8002d3:	c9                   	leave  
  8002d4:	c3                   	ret    

008002d5 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002d5:	55                   	push   %ebp
  8002d6:	89 e5                	mov    %esp,%ebp
  8002d8:	57                   	push   %edi
  8002d9:	56                   	push   %esi
  8002da:	53                   	push   %ebx
  8002db:	83 ec 1c             	sub    $0x1c,%esp
  8002de:	89 c6                	mov    %eax,%esi
  8002e0:	89 d7                	mov    %edx,%edi
  8002e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8002e5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002e8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002eb:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002ee:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8002f1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002f6:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8002f9:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8002fc:	39 d3                	cmp    %edx,%ebx
  8002fe:	72 11                	jb     800311 <printnum+0x3c>
  800300:	39 45 10             	cmp    %eax,0x10(%ebp)
  800303:	76 0c                	jbe    800311 <printnum+0x3c>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800305:	8b 45 14             	mov    0x14(%ebp),%eax
  800308:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80030b:	85 db                	test   %ebx,%ebx
  80030d:	7f 37                	jg     800346 <printnum+0x71>
  80030f:	eb 44                	jmp    800355 <printnum+0x80>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800311:	83 ec 0c             	sub    $0xc,%esp
  800314:	ff 75 18             	pushl  0x18(%ebp)
  800317:	8b 45 14             	mov    0x14(%ebp),%eax
  80031a:	48                   	dec    %eax
  80031b:	50                   	push   %eax
  80031c:	ff 75 10             	pushl  0x10(%ebp)
  80031f:	83 ec 08             	sub    $0x8,%esp
  800322:	ff 75 e4             	pushl  -0x1c(%ebp)
  800325:	ff 75 e0             	pushl  -0x20(%ebp)
  800328:	ff 75 dc             	pushl  -0x24(%ebp)
  80032b:	ff 75 d8             	pushl  -0x28(%ebp)
  80032e:	e8 69 23 00 00       	call   80269c <__udivdi3>
  800333:	83 c4 18             	add    $0x18,%esp
  800336:	52                   	push   %edx
  800337:	50                   	push   %eax
  800338:	89 fa                	mov    %edi,%edx
  80033a:	89 f0                	mov    %esi,%eax
  80033c:	e8 94 ff ff ff       	call   8002d5 <printnum>
  800341:	83 c4 20             	add    $0x20,%esp
  800344:	eb 0f                	jmp    800355 <printnum+0x80>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800346:	83 ec 08             	sub    $0x8,%esp
  800349:	57                   	push   %edi
  80034a:	ff 75 18             	pushl  0x18(%ebp)
  80034d:	ff d6                	call   *%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80034f:	83 c4 10             	add    $0x10,%esp
  800352:	4b                   	dec    %ebx
  800353:	75 f1                	jne    800346 <printnum+0x71>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800355:	83 ec 08             	sub    $0x8,%esp
  800358:	57                   	push   %edi
  800359:	83 ec 04             	sub    $0x4,%esp
  80035c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80035f:	ff 75 e0             	pushl  -0x20(%ebp)
  800362:	ff 75 dc             	pushl  -0x24(%ebp)
  800365:	ff 75 d8             	pushl  -0x28(%ebp)
  800368:	e8 3f 24 00 00       	call   8027ac <__umoddi3>
  80036d:	83 c4 14             	add    $0x14,%esp
  800370:	0f be 80 db 29 80 00 	movsbl 0x8029db(%eax),%eax
  800377:	50                   	push   %eax
  800378:	ff d6                	call   *%esi
}
  80037a:	83 c4 10             	add    $0x10,%esp
  80037d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800380:	5b                   	pop    %ebx
  800381:	5e                   	pop    %esi
  800382:	5f                   	pop    %edi
  800383:	5d                   	pop    %ebp
  800384:	c3                   	ret    

00800385 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800385:	55                   	push   %ebp
  800386:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800388:	83 fa 01             	cmp    $0x1,%edx
  80038b:	7e 0e                	jle    80039b <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80038d:	8b 10                	mov    (%eax),%edx
  80038f:	8d 4a 08             	lea    0x8(%edx),%ecx
  800392:	89 08                	mov    %ecx,(%eax)
  800394:	8b 02                	mov    (%edx),%eax
  800396:	8b 52 04             	mov    0x4(%edx),%edx
  800399:	eb 22                	jmp    8003bd <getuint+0x38>
	else if (lflag)
  80039b:	85 d2                	test   %edx,%edx
  80039d:	74 10                	je     8003af <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80039f:	8b 10                	mov    (%eax),%edx
  8003a1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003a4:	89 08                	mov    %ecx,(%eax)
  8003a6:	8b 02                	mov    (%edx),%eax
  8003a8:	ba 00 00 00 00       	mov    $0x0,%edx
  8003ad:	eb 0e                	jmp    8003bd <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003af:	8b 10                	mov    (%eax),%edx
  8003b1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003b4:	89 08                	mov    %ecx,(%eax)
  8003b6:	8b 02                	mov    (%edx),%eax
  8003b8:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003bd:	5d                   	pop    %ebp
  8003be:	c3                   	ret    

008003bf <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003bf:	55                   	push   %ebp
  8003c0:	89 e5                	mov    %esp,%ebp
  8003c2:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003c5:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8003c8:	8b 10                	mov    (%eax),%edx
  8003ca:	3b 50 04             	cmp    0x4(%eax),%edx
  8003cd:	73 0a                	jae    8003d9 <sprintputch+0x1a>
		*b->buf++ = ch;
  8003cf:	8d 4a 01             	lea    0x1(%edx),%ecx
  8003d2:	89 08                	mov    %ecx,(%eax)
  8003d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8003d7:	88 02                	mov    %al,(%edx)
}
  8003d9:	5d                   	pop    %ebp
  8003da:	c3                   	ret    

008003db <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003db:	55                   	push   %ebp
  8003dc:	89 e5                	mov    %esp,%ebp
  8003de:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8003e1:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003e4:	50                   	push   %eax
  8003e5:	ff 75 10             	pushl  0x10(%ebp)
  8003e8:	ff 75 0c             	pushl  0xc(%ebp)
  8003eb:	ff 75 08             	pushl  0x8(%ebp)
  8003ee:	e8 05 00 00 00       	call   8003f8 <vprintfmt>
	va_end(ap);
}
  8003f3:	83 c4 10             	add    $0x10,%esp
  8003f6:	c9                   	leave  
  8003f7:	c3                   	ret    

008003f8 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003f8:	55                   	push   %ebp
  8003f9:	89 e5                	mov    %esp,%ebp
  8003fb:	57                   	push   %edi
  8003fc:	56                   	push   %esi
  8003fd:	53                   	push   %ebx
  8003fe:	83 ec 2c             	sub    $0x2c,%esp
  800401:	8b 7d 08             	mov    0x8(%ebp),%edi
  800404:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800407:	eb 03                	jmp    80040c <vprintfmt+0x14>
			break;

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
			for (fmt--; fmt[-1] != '%'; fmt--)
  800409:	89 75 10             	mov    %esi,0x10(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {    //遍历输入的第一个参数，即输出信息的格式，先把格式字符串中'%'之前的字符一个个输出，因为它们前面没有'%'，所以它们就是要直接显示在屏幕上的
  80040c:	8b 45 10             	mov    0x10(%ebp),%eax
  80040f:	8d 70 01             	lea    0x1(%eax),%esi
  800412:	0f b6 00             	movzbl (%eax),%eax
  800415:	83 f8 25             	cmp    $0x25,%eax
  800418:	74 25                	je     80043f <vprintfmt+0x47>
			if (ch == '\0')									//当然中间如果遇到'\0'，代表这个字符串的访问结束
  80041a:	85 c0                	test   %eax,%eax
  80041c:	75 0d                	jne    80042b <vprintfmt+0x33>
  80041e:	e9 b5 03 00 00       	jmp    8007d8 <vprintfmt+0x3e0>
  800423:	85 c0                	test   %eax,%eax
  800425:	0f 84 ad 03 00 00    	je     8007d8 <vprintfmt+0x3e0>
				return;
			putch(ch, putdat);								//调用putch函数，把一个字符ch输出到putdat指针所指向的地址中所存放的值对应的地址处
  80042b:	83 ec 08             	sub    $0x8,%esp
  80042e:	53                   	push   %ebx
  80042f:	50                   	push   %eax
  800430:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {    //遍历输入的第一个参数，即输出信息的格式，先把格式字符串中'%'之前的字符一个个输出，因为它们前面没有'%'，所以它们就是要直接显示在屏幕上的
  800432:	46                   	inc    %esi
  800433:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  800437:	83 c4 10             	add    $0x10,%esp
  80043a:	83 f8 25             	cmp    $0x25,%eax
  80043d:	75 e4                	jne    800423 <vprintfmt+0x2b>
			if (width < 0)									//代表有小数点，但是小数点前面并没有数字，比如'%.6f'这种情况，此时代表整数部分全部显示
				width = 0;			
			goto reswitch;

		case '#':
			altflag = 1;
  80043f:	c6 45 e3 20          	movb   $0x20,-0x1d(%ebp)
  800443:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80044a:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800451:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800458:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  80045f:	eb 07                	jmp    800468 <vprintfmt+0x70>
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  800461:	8b 75 10             	mov    0x10(%ebp),%esi

		// flag to pad on the right
		case '-':											//%后面的'-'代表要进行左对齐输出，右边填空格，如果省略代表右对齐
			padc = '-';										//如果有这个字符代表左对齐，则把对齐方式标志位变为'-'
  800464:	c6 45 e3 2d          	movb   $0x2d,-0x1d(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  800468:	8d 46 01             	lea    0x1(%esi),%eax
  80046b:	89 45 10             	mov    %eax,0x10(%ebp)
  80046e:	0f b6 16             	movzbl (%esi),%edx
  800471:	8a 06                	mov    (%esi),%al
  800473:	83 e8 23             	sub    $0x23,%eax
  800476:	3c 55                	cmp    $0x55,%al
  800478:	0f 87 03 03 00 00    	ja     800781 <vprintfmt+0x389>
  80047e:	0f b6 c0             	movzbl %al,%eax
  800481:	ff 24 85 20 2b 80 00 	jmp    *0x802b20(,%eax,4)
  800488:	8b 75 10             	mov    0x10(%ebp),%esi
			padc = '-';										//如果有这个字符代表左对齐，则把对齐方式标志位变为'-'
			goto reswitch;									//处理下一个字符

		// flag to pad with 0's instead of spaces
		case '0':											//0--有0表示进行对齐输出时填0,如省略表示填入空格，并且如果为0，则一定是右对齐
			padc = '0';										//对其方式标志位变为0
  80048b:	c6 45 e3 30          	movb   $0x30,-0x1d(%ebp)
  80048f:	eb d7                	jmp    800468 <vprintfmt+0x70>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {					//把遇到的位数字符串转换为真实的位数，比如输入的'%40'，代表有效位数为40位，下面的循环就是把precesion的值设置为40
				precision = precision * 10 + ch - '0';
  800491:	8d 42 d0             	lea    -0x30(%edx),%eax
  800494:	89 c1                	mov    %eax,%ecx
  800496:	89 45 d0             	mov    %eax,-0x30(%ebp)
				ch = *fmt;
  800499:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  80049d:	8d 50 d0             	lea    -0x30(%eax),%edx
  8004a0:	83 fa 09             	cmp    $0x9,%edx
  8004a3:	77 51                	ja     8004f6 <vprintfmt+0xfe>
  8004a5:	8b 75 10             	mov    0x10(%ebp),%esi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {					//把遇到的位数字符串转换为真实的位数，比如输入的'%40'，代表有效位数为40位，下面的循环就是把precesion的值设置为40
  8004a8:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  8004a9:	8d 14 89             	lea    (%ecx,%ecx,4),%edx
  8004ac:	01 d2                	add    %edx,%edx
  8004ae:	8d 4c 10 d0          	lea    -0x30(%eax,%edx,1),%ecx
				ch = *fmt;
  8004b2:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8004b5:	8d 50 d0             	lea    -0x30(%eax),%edx
  8004b8:	83 fa 09             	cmp    $0x9,%edx
  8004bb:	76 eb                	jbe    8004a8 <vprintfmt+0xb0>
  8004bd:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8004c0:	eb 37                	jmp    8004f9 <vprintfmt+0x101>
					break;
			}
			goto process_precision;							//跳转到process_precistion子过程

		case '*':											//*--代表有效数字的位数也是由输入参数指定的，比如printf("%*.*f", 10, 2, n)，其中10,2就是用来指定显示的有效数字位数的
			precision = va_arg(ap, int);
  8004c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c5:	8d 50 04             	lea    0x4(%eax),%edx
  8004c8:	89 55 14             	mov    %edx,0x14(%ebp)
  8004cb:	8b 00                	mov    (%eax),%eax
  8004cd:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  8004d0:	8b 75 10             	mov    0x10(%ebp),%esi
			}
			goto process_precision;							//跳转到process_precistion子过程

		case '*':											//*--代表有效数字的位数也是由输入参数指定的，比如printf("%*.*f", 10, 2, n)，其中10,2就是用来指定显示的有效数字位数的
			precision = va_arg(ap, int);
			goto process_precision;
  8004d3:	eb 24                	jmp    8004f9 <vprintfmt+0x101>
  8004d5:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004d9:	79 07                	jns    8004e2 <vprintfmt+0xea>
  8004db:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  8004e2:	8b 75 10             	mov    0x10(%ebp),%esi
  8004e5:	eb 81                	jmp    800468 <vprintfmt+0x70>
  8004e7:	8b 75 10             	mov    0x10(%ebp),%esi
			if (width < 0)									//代表有小数点，但是小数点前面并没有数字，比如'%.6f'这种情况，此时代表整数部分全部显示
				width = 0;			
			goto reswitch;

		case '#':
			altflag = 1;
  8004ea:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8004f1:	e9 72 ff ff ff       	jmp    800468 <vprintfmt+0x70>
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  8004f6:	8b 75 10             	mov    0x10(%ebp),%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:									//处理输出精度，把width字段赋值为刚刚计算出来的precision值，所以width应该是整数部分的有效数字位数
			if (width < 0)
  8004f9:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004fd:	0f 89 65 ff ff ff    	jns    800468 <vprintfmt+0x70>
				width = precision, precision = -1;
  800503:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800506:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800509:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800510:	e9 53 ff ff ff       	jmp    800468 <vprintfmt+0x70>
			goto reswitch;

		// long flag (doubled for long long)				
		case 'l':											//如果遇到'l'，代表应该是输入long类型，如果有两个'l'代表long long
			lflag++;										//此时把lflag++
  800515:	ff 45 d4             	incl   -0x2c(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  800518:	8b 75 10             	mov    0x10(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)				
		case 'l':											//如果遇到'l'，代表应该是输入long类型，如果有两个'l'代表long long
			lflag++;										//此时把lflag++
			goto reswitch;
  80051b:	e9 48 ff ff ff       	jmp    800468 <vprintfmt+0x70>

		// character
		case 'c':											//如果是'c'代表显示一个字符
			putch(va_arg(ap, int), putdat);					//调用输出一个字符到内存的函数putch
  800520:	8b 45 14             	mov    0x14(%ebp),%eax
  800523:	8d 50 04             	lea    0x4(%eax),%edx
  800526:	89 55 14             	mov    %edx,0x14(%ebp)
  800529:	83 ec 08             	sub    $0x8,%esp
  80052c:	53                   	push   %ebx
  80052d:	ff 30                	pushl  (%eax)
  80052f:	ff d7                	call   *%edi
			break;
  800531:	83 c4 10             	add    $0x10,%esp
  800534:	e9 d3 fe ff ff       	jmp    80040c <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800539:	8b 45 14             	mov    0x14(%ebp),%eax
  80053c:	8d 50 04             	lea    0x4(%eax),%edx
  80053f:	89 55 14             	mov    %edx,0x14(%ebp)
  800542:	8b 00                	mov    (%eax),%eax
  800544:	85 c0                	test   %eax,%eax
  800546:	79 02                	jns    80054a <vprintfmt+0x152>
  800548:	f7 d8                	neg    %eax
  80054a:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80054c:	83 f8 0f             	cmp    $0xf,%eax
  80054f:	7f 0b                	jg     80055c <vprintfmt+0x164>
  800551:	8b 04 85 80 2c 80 00 	mov    0x802c80(,%eax,4),%eax
  800558:	85 c0                	test   %eax,%eax
  80055a:	75 15                	jne    800571 <vprintfmt+0x179>
				printfmt(putch, putdat, "error %d", err);
  80055c:	52                   	push   %edx
  80055d:	68 f3 29 80 00       	push   $0x8029f3
  800562:	53                   	push   %ebx
  800563:	57                   	push   %edi
  800564:	e8 72 fe ff ff       	call   8003db <printfmt>
  800569:	83 c4 10             	add    $0x10,%esp
  80056c:	e9 9b fe ff ff       	jmp    80040c <vprintfmt+0x14>
			else
				printfmt(putch, putdat, "%s", p);
  800571:	50                   	push   %eax
  800572:	68 87 2e 80 00       	push   $0x802e87
  800577:	53                   	push   %ebx
  800578:	57                   	push   %edi
  800579:	e8 5d fe ff ff       	call   8003db <printfmt>
  80057e:	83 c4 10             	add    $0x10,%esp
  800581:	e9 86 fe ff ff       	jmp    80040c <vprintfmt+0x14>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800586:	8b 45 14             	mov    0x14(%ebp),%eax
  800589:	8d 50 04             	lea    0x4(%eax),%edx
  80058c:	89 55 14             	mov    %edx,0x14(%ebp)
  80058f:	8b 00                	mov    (%eax),%eax
  800591:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800594:	85 c0                	test   %eax,%eax
  800596:	75 07                	jne    80059f <vprintfmt+0x1a7>
				p = "(null)";
  800598:	c7 45 d4 ec 29 80 00 	movl   $0x8029ec,-0x2c(%ebp)
			if (width > 0 && padc != '-')
  80059f:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8005a2:	85 f6                	test   %esi,%esi
  8005a4:	0f 8e fb 01 00 00    	jle    8007a5 <vprintfmt+0x3ad>
  8005aa:	80 7d e3 2d          	cmpb   $0x2d,-0x1d(%ebp)
  8005ae:	0f 84 09 02 00 00    	je     8007bd <vprintfmt+0x3c5>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005b4:	83 ec 08             	sub    $0x8,%esp
  8005b7:	ff 75 d0             	pushl  -0x30(%ebp)
  8005ba:	ff 75 d4             	pushl  -0x2c(%ebp)
  8005bd:	e8 ad 02 00 00       	call   80086f <strnlen>
  8005c2:	89 f1                	mov    %esi,%ecx
  8005c4:	29 c1                	sub    %eax,%ecx
  8005c6:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  8005c9:	83 c4 10             	add    $0x10,%esp
  8005cc:	85 c9                	test   %ecx,%ecx
  8005ce:	0f 8e d1 01 00 00    	jle    8007a5 <vprintfmt+0x3ad>
					putch(padc, putdat);
  8005d4:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  8005d8:	83 ec 08             	sub    $0x8,%esp
  8005db:	53                   	push   %ebx
  8005dc:	56                   	push   %esi
  8005dd:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005df:	83 c4 10             	add    $0x10,%esp
  8005e2:	ff 4d e4             	decl   -0x1c(%ebp)
  8005e5:	75 f1                	jne    8005d8 <vprintfmt+0x1e0>
  8005e7:	e9 b9 01 00 00       	jmp    8007a5 <vprintfmt+0x3ad>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005ec:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005f0:	74 19                	je     80060b <vprintfmt+0x213>
  8005f2:	0f be c0             	movsbl %al,%eax
  8005f5:	83 e8 20             	sub    $0x20,%eax
  8005f8:	83 f8 5e             	cmp    $0x5e,%eax
  8005fb:	76 0e                	jbe    80060b <vprintfmt+0x213>
					putch('?', putdat);
  8005fd:	83 ec 08             	sub    $0x8,%esp
  800600:	53                   	push   %ebx
  800601:	6a 3f                	push   $0x3f
  800603:	ff 55 08             	call   *0x8(%ebp)
  800606:	83 c4 10             	add    $0x10,%esp
  800609:	eb 0b                	jmp    800616 <vprintfmt+0x21e>
				else
					putch(ch, putdat);
  80060b:	83 ec 08             	sub    $0x8,%esp
  80060e:	53                   	push   %ebx
  80060f:	52                   	push   %edx
  800610:	ff 55 08             	call   *0x8(%ebp)
  800613:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800616:	ff 4d e4             	decl   -0x1c(%ebp)
  800619:	46                   	inc    %esi
  80061a:	8a 46 ff             	mov    -0x1(%esi),%al
  80061d:	0f be d0             	movsbl %al,%edx
  800620:	85 d2                	test   %edx,%edx
  800622:	75 1c                	jne    800640 <vprintfmt+0x248>
  800624:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800627:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80062b:	7f 1f                	jg     80064c <vprintfmt+0x254>
  80062d:	e9 da fd ff ff       	jmp    80040c <vprintfmt+0x14>
  800632:	89 7d 08             	mov    %edi,0x8(%ebp)
  800635:	8b 7d d0             	mov    -0x30(%ebp),%edi
  800638:	eb 06                	jmp    800640 <vprintfmt+0x248>
  80063a:	89 7d 08             	mov    %edi,0x8(%ebp)
  80063d:	8b 7d d0             	mov    -0x30(%ebp),%edi
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800640:	85 ff                	test   %edi,%edi
  800642:	78 a8                	js     8005ec <vprintfmt+0x1f4>
  800644:	4f                   	dec    %edi
  800645:	79 a5                	jns    8005ec <vprintfmt+0x1f4>
  800647:	8b 7d 08             	mov    0x8(%ebp),%edi
  80064a:	eb db                	jmp    800627 <vprintfmt+0x22f>
  80064c:	8b 75 e4             	mov    -0x1c(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80064f:	83 ec 08             	sub    $0x8,%esp
  800652:	53                   	push   %ebx
  800653:	6a 20                	push   $0x20
  800655:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800657:	4e                   	dec    %esi
  800658:	83 c4 10             	add    $0x10,%esp
  80065b:	85 f6                	test   %esi,%esi
  80065d:	7f f0                	jg     80064f <vprintfmt+0x257>
  80065f:	e9 a8 fd ff ff       	jmp    80040c <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800664:	83 7d d4 01          	cmpl   $0x1,-0x2c(%ebp)
  800668:	7e 16                	jle    800680 <vprintfmt+0x288>
		return va_arg(*ap, long long);
  80066a:	8b 45 14             	mov    0x14(%ebp),%eax
  80066d:	8d 50 08             	lea    0x8(%eax),%edx
  800670:	89 55 14             	mov    %edx,0x14(%ebp)
  800673:	8b 50 04             	mov    0x4(%eax),%edx
  800676:	8b 00                	mov    (%eax),%eax
  800678:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80067b:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80067e:	eb 34                	jmp    8006b4 <vprintfmt+0x2bc>
	else if (lflag)
  800680:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800684:	74 18                	je     80069e <vprintfmt+0x2a6>
		return va_arg(*ap, long);
  800686:	8b 45 14             	mov    0x14(%ebp),%eax
  800689:	8d 50 04             	lea    0x4(%eax),%edx
  80068c:	89 55 14             	mov    %edx,0x14(%ebp)
  80068f:	8b 30                	mov    (%eax),%esi
  800691:	89 75 d8             	mov    %esi,-0x28(%ebp)
  800694:	89 f0                	mov    %esi,%eax
  800696:	c1 f8 1f             	sar    $0x1f,%eax
  800699:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80069c:	eb 16                	jmp    8006b4 <vprintfmt+0x2bc>
	else
		return va_arg(*ap, int);
  80069e:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a1:	8d 50 04             	lea    0x4(%eax),%edx
  8006a4:	89 55 14             	mov    %edx,0x14(%ebp)
  8006a7:	8b 30                	mov    (%eax),%esi
  8006a9:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8006ac:	89 f0                	mov    %esi,%eax
  8006ae:	c1 f8 1f             	sar    $0x1f,%eax
  8006b1:	89 45 dc             	mov    %eax,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006b4:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8006b7:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
  8006ba:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8006be:	0f 89 8a 00 00 00    	jns    80074e <vprintfmt+0x356>
				putch('-', putdat);
  8006c4:	83 ec 08             	sub    $0x8,%esp
  8006c7:	53                   	push   %ebx
  8006c8:	6a 2d                	push   $0x2d
  8006ca:	ff d7                	call   *%edi
				num = -(long long) num;
  8006cc:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8006cf:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8006d2:	f7 d8                	neg    %eax
  8006d4:	83 d2 00             	adc    $0x0,%edx
  8006d7:	f7 da                	neg    %edx
  8006d9:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8006dc:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8006e1:	eb 70                	jmp    800753 <vprintfmt+0x35b>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006e3:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8006e6:	8d 45 14             	lea    0x14(%ebp),%eax
  8006e9:	e8 97 fc ff ff       	call   800385 <getuint>
			base = 10;
  8006ee:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8006f3:	eb 5e                	jmp    800753 <vprintfmt+0x35b>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
  8006f5:	83 ec 08             	sub    $0x8,%esp
  8006f8:	53                   	push   %ebx
  8006f9:	6a 30                	push   $0x30
  8006fb:	ff d7                	call   *%edi
			num = getuint(&ap, lflag);
  8006fd:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800700:	8d 45 14             	lea    0x14(%ebp),%eax
  800703:	e8 7d fc ff ff       	call   800385 <getuint>
			base = 8;
			goto number;
  800708:	83 c4 10             	add    $0x10,%esp
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  80070b:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800710:	eb 41                	jmp    800753 <vprintfmt+0x35b>
		// pointer
		case 'p':
			putch('0', putdat);
  800712:	83 ec 08             	sub    $0x8,%esp
  800715:	53                   	push   %ebx
  800716:	6a 30                	push   $0x30
  800718:	ff d7                	call   *%edi
			putch('x', putdat);
  80071a:	83 c4 08             	add    $0x8,%esp
  80071d:	53                   	push   %ebx
  80071e:	6a 78                	push   $0x78
  800720:	ff d7                	call   *%edi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800722:	8b 45 14             	mov    0x14(%ebp),%eax
  800725:	8d 50 04             	lea    0x4(%eax),%edx
  800728:	89 55 14             	mov    %edx,0x14(%ebp)
			goto number;
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80072b:	8b 00                	mov    (%eax),%eax
  80072d:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800732:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800735:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80073a:	eb 17                	jmp    800753 <vprintfmt+0x35b>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80073c:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80073f:	8d 45 14             	lea    0x14(%ebp),%eax
  800742:	e8 3e fc ff ff       	call   800385 <getuint>
			base = 16;
  800747:	b9 10 00 00 00       	mov    $0x10,%ecx
  80074c:	eb 05                	jmp    800753 <vprintfmt+0x35b>
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80074e:	b9 0a 00 00 00       	mov    $0xa,%ecx
		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  800753:	83 ec 0c             	sub    $0xc,%esp
  800756:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  80075a:	56                   	push   %esi
  80075b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80075e:	51                   	push   %ecx
  80075f:	52                   	push   %edx
  800760:	50                   	push   %eax
  800761:	89 da                	mov    %ebx,%edx
  800763:	89 f8                	mov    %edi,%eax
  800765:	e8 6b fb ff ff       	call   8002d5 <printnum>
			break;
  80076a:	83 c4 20             	add    $0x20,%esp
  80076d:	e9 9a fc ff ff       	jmp    80040c <vprintfmt+0x14>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800772:	83 ec 08             	sub    $0x8,%esp
  800775:	53                   	push   %ebx
  800776:	52                   	push   %edx
  800777:	ff d7                	call   *%edi
			break;
  800779:	83 c4 10             	add    $0x10,%esp
  80077c:	e9 8b fc ff ff       	jmp    80040c <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800781:	83 ec 08             	sub    $0x8,%esp
  800784:	53                   	push   %ebx
  800785:	6a 25                	push   $0x25
  800787:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800789:	83 c4 10             	add    $0x10,%esp
  80078c:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800790:	0f 84 73 fc ff ff    	je     800409 <vprintfmt+0x11>
  800796:	4e                   	dec    %esi
  800797:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80079b:	75 f9                	jne    800796 <vprintfmt+0x39e>
  80079d:	89 75 10             	mov    %esi,0x10(%ebp)
  8007a0:	e9 67 fc ff ff       	jmp    80040c <vprintfmt+0x14>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8007a5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8007a8:	8d 70 01             	lea    0x1(%eax),%esi
  8007ab:	8a 00                	mov    (%eax),%al
  8007ad:	0f be d0             	movsbl %al,%edx
  8007b0:	85 d2                	test   %edx,%edx
  8007b2:	0f 85 7a fe ff ff    	jne    800632 <vprintfmt+0x23a>
  8007b8:	e9 4f fc ff ff       	jmp    80040c <vprintfmt+0x14>
  8007bd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8007c0:	8d 70 01             	lea    0x1(%eax),%esi
  8007c3:	8a 00                	mov    (%eax),%al
  8007c5:	0f be d0             	movsbl %al,%edx
  8007c8:	85 d2                	test   %edx,%edx
  8007ca:	0f 85 6a fe ff ff    	jne    80063a <vprintfmt+0x242>
  8007d0:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8007d3:	e9 77 fe ff ff       	jmp    80064f <vprintfmt+0x257>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  8007d8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007db:	5b                   	pop    %ebx
  8007dc:	5e                   	pop    %esi
  8007dd:	5f                   	pop    %edi
  8007de:	5d                   	pop    %ebp
  8007df:	c3                   	ret    

008007e0 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007e0:	55                   	push   %ebp
  8007e1:	89 e5                	mov    %esp,%ebp
  8007e3:	83 ec 18             	sub    $0x18,%esp
  8007e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e9:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007ec:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007ef:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007f3:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007f6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007fd:	85 c0                	test   %eax,%eax
  8007ff:	74 26                	je     800827 <vsnprintf+0x47>
  800801:	85 d2                	test   %edx,%edx
  800803:	7e 29                	jle    80082e <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800805:	ff 75 14             	pushl  0x14(%ebp)
  800808:	ff 75 10             	pushl  0x10(%ebp)
  80080b:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80080e:	50                   	push   %eax
  80080f:	68 bf 03 80 00       	push   $0x8003bf
  800814:	e8 df fb ff ff       	call   8003f8 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800819:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80081c:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80081f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800822:	83 c4 10             	add    $0x10,%esp
  800825:	eb 0c                	jmp    800833 <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800827:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80082c:	eb 05                	jmp    800833 <vsnprintf+0x53>
  80082e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800833:	c9                   	leave  
  800834:	c3                   	ret    

00800835 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800835:	55                   	push   %ebp
  800836:	89 e5                	mov    %esp,%ebp
  800838:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80083b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80083e:	50                   	push   %eax
  80083f:	ff 75 10             	pushl  0x10(%ebp)
  800842:	ff 75 0c             	pushl  0xc(%ebp)
  800845:	ff 75 08             	pushl  0x8(%ebp)
  800848:	e8 93 ff ff ff       	call   8007e0 <vsnprintf>
	va_end(ap);

	return rc;
}
  80084d:	c9                   	leave  
  80084e:	c3                   	ret    

0080084f <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80084f:	55                   	push   %ebp
  800850:	89 e5                	mov    %esp,%ebp
  800852:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800855:	80 3a 00             	cmpb   $0x0,(%edx)
  800858:	74 0e                	je     800868 <strlen+0x19>
  80085a:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  80085f:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800860:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800864:	75 f9                	jne    80085f <strlen+0x10>
  800866:	eb 05                	jmp    80086d <strlen+0x1e>
  800868:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  80086d:	5d                   	pop    %ebp
  80086e:	c3                   	ret    

0080086f <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80086f:	55                   	push   %ebp
  800870:	89 e5                	mov    %esp,%ebp
  800872:	53                   	push   %ebx
  800873:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800876:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800879:	85 c9                	test   %ecx,%ecx
  80087b:	74 1a                	je     800897 <strnlen+0x28>
  80087d:	80 3b 00             	cmpb   $0x0,(%ebx)
  800880:	74 1c                	je     80089e <strnlen+0x2f>
  800882:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  800887:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800889:	39 ca                	cmp    %ecx,%edx
  80088b:	74 16                	je     8008a3 <strnlen+0x34>
  80088d:	42                   	inc    %edx
  80088e:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800893:	75 f2                	jne    800887 <strnlen+0x18>
  800895:	eb 0c                	jmp    8008a3 <strnlen+0x34>
  800897:	b8 00 00 00 00       	mov    $0x0,%eax
  80089c:	eb 05                	jmp    8008a3 <strnlen+0x34>
  80089e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8008a3:	5b                   	pop    %ebx
  8008a4:	5d                   	pop    %ebp
  8008a5:	c3                   	ret    

008008a6 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008a6:	55                   	push   %ebp
  8008a7:	89 e5                	mov    %esp,%ebp
  8008a9:	53                   	push   %ebx
  8008aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008b0:	89 c2                	mov    %eax,%edx
  8008b2:	42                   	inc    %edx
  8008b3:	41                   	inc    %ecx
  8008b4:	8a 59 ff             	mov    -0x1(%ecx),%bl
  8008b7:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008ba:	84 db                	test   %bl,%bl
  8008bc:	75 f4                	jne    8008b2 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8008be:	5b                   	pop    %ebx
  8008bf:	5d                   	pop    %ebp
  8008c0:	c3                   	ret    

008008c1 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008c1:	55                   	push   %ebp
  8008c2:	89 e5                	mov    %esp,%ebp
  8008c4:	53                   	push   %ebx
  8008c5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008c8:	53                   	push   %ebx
  8008c9:	e8 81 ff ff ff       	call   80084f <strlen>
  8008ce:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8008d1:	ff 75 0c             	pushl  0xc(%ebp)
  8008d4:	01 d8                	add    %ebx,%eax
  8008d6:	50                   	push   %eax
  8008d7:	e8 ca ff ff ff       	call   8008a6 <strcpy>
	return dst;
}
  8008dc:	89 d8                	mov    %ebx,%eax
  8008de:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008e1:	c9                   	leave  
  8008e2:	c3                   	ret    

008008e3 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008e3:	55                   	push   %ebp
  8008e4:	89 e5                	mov    %esp,%ebp
  8008e6:	56                   	push   %esi
  8008e7:	53                   	push   %ebx
  8008e8:	8b 75 08             	mov    0x8(%ebp),%esi
  8008eb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ee:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008f1:	85 db                	test   %ebx,%ebx
  8008f3:	74 14                	je     800909 <strncpy+0x26>
  8008f5:	01 f3                	add    %esi,%ebx
  8008f7:	89 f1                	mov    %esi,%ecx
		*dst++ = *src;
  8008f9:	41                   	inc    %ecx
  8008fa:	8a 02                	mov    (%edx),%al
  8008fc:	88 41 ff             	mov    %al,-0x1(%ecx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008ff:	80 3a 01             	cmpb   $0x1,(%edx)
  800902:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800905:	39 cb                	cmp    %ecx,%ebx
  800907:	75 f0                	jne    8008f9 <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800909:	89 f0                	mov    %esi,%eax
  80090b:	5b                   	pop    %ebx
  80090c:	5e                   	pop    %esi
  80090d:	5d                   	pop    %ebp
  80090e:	c3                   	ret    

0080090f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80090f:	55                   	push   %ebp
  800910:	89 e5                	mov    %esp,%ebp
  800912:	53                   	push   %ebx
  800913:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800916:	8b 45 10             	mov    0x10(%ebp),%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800919:	85 c0                	test   %eax,%eax
  80091b:	74 30                	je     80094d <strlcpy+0x3e>
		while (--size > 0 && *src != '\0')
  80091d:	48                   	dec    %eax
  80091e:	74 20                	je     800940 <strlcpy+0x31>
  800920:	8a 0b                	mov    (%ebx),%cl
  800922:	84 c9                	test   %cl,%cl
  800924:	74 1f                	je     800945 <strlcpy+0x36>
  800926:	8d 53 01             	lea    0x1(%ebx),%edx
  800929:	01 c3                	add    %eax,%ebx
  80092b:	8b 45 08             	mov    0x8(%ebp),%eax
			*dst++ = *src++;
  80092e:	40                   	inc    %eax
  80092f:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800932:	39 da                	cmp    %ebx,%edx
  800934:	74 12                	je     800948 <strlcpy+0x39>
  800936:	42                   	inc    %edx
  800937:	8a 4a ff             	mov    -0x1(%edx),%cl
  80093a:	84 c9                	test   %cl,%cl
  80093c:	75 f0                	jne    80092e <strlcpy+0x1f>
  80093e:	eb 08                	jmp    800948 <strlcpy+0x39>
  800940:	8b 45 08             	mov    0x8(%ebp),%eax
  800943:	eb 03                	jmp    800948 <strlcpy+0x39>
  800945:	8b 45 08             	mov    0x8(%ebp),%eax
			*dst++ = *src++;
		*dst = '\0';
  800948:	c6 00 00             	movb   $0x0,(%eax)
  80094b:	eb 03                	jmp    800950 <strlcpy+0x41>
  80094d:	8b 45 08             	mov    0x8(%ebp),%eax
	}
	return dst - dst_in;
  800950:	2b 45 08             	sub    0x8(%ebp),%eax
}
  800953:	5b                   	pop    %ebx
  800954:	5d                   	pop    %ebp
  800955:	c3                   	ret    

00800956 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800956:	55                   	push   %ebp
  800957:	89 e5                	mov    %esp,%ebp
  800959:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80095c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80095f:	8a 01                	mov    (%ecx),%al
  800961:	84 c0                	test   %al,%al
  800963:	74 10                	je     800975 <strcmp+0x1f>
  800965:	3a 02                	cmp    (%edx),%al
  800967:	75 0c                	jne    800975 <strcmp+0x1f>
		p++, q++;
  800969:	41                   	inc    %ecx
  80096a:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80096b:	8a 01                	mov    (%ecx),%al
  80096d:	84 c0                	test   %al,%al
  80096f:	74 04                	je     800975 <strcmp+0x1f>
  800971:	3a 02                	cmp    (%edx),%al
  800973:	74 f4                	je     800969 <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800975:	0f b6 c0             	movzbl %al,%eax
  800978:	0f b6 12             	movzbl (%edx),%edx
  80097b:	29 d0                	sub    %edx,%eax
}
  80097d:	5d                   	pop    %ebp
  80097e:	c3                   	ret    

0080097f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80097f:	55                   	push   %ebp
  800980:	89 e5                	mov    %esp,%ebp
  800982:	56                   	push   %esi
  800983:	53                   	push   %ebx
  800984:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800987:	8b 55 0c             	mov    0xc(%ebp),%edx
  80098a:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  80098d:	85 f6                	test   %esi,%esi
  80098f:	74 23                	je     8009b4 <strncmp+0x35>
  800991:	8a 03                	mov    (%ebx),%al
  800993:	84 c0                	test   %al,%al
  800995:	74 2b                	je     8009c2 <strncmp+0x43>
  800997:	3a 02                	cmp    (%edx),%al
  800999:	75 27                	jne    8009c2 <strncmp+0x43>
  80099b:	8d 43 01             	lea    0x1(%ebx),%eax
  80099e:	01 de                	add    %ebx,%esi
		n--, p++, q++;
  8009a0:	89 c3                	mov    %eax,%ebx
  8009a2:	42                   	inc    %edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009a3:	39 c6                	cmp    %eax,%esi
  8009a5:	74 14                	je     8009bb <strncmp+0x3c>
  8009a7:	8a 08                	mov    (%eax),%cl
  8009a9:	84 c9                	test   %cl,%cl
  8009ab:	74 15                	je     8009c2 <strncmp+0x43>
  8009ad:	40                   	inc    %eax
  8009ae:	3a 0a                	cmp    (%edx),%cl
  8009b0:	74 ee                	je     8009a0 <strncmp+0x21>
  8009b2:	eb 0e                	jmp    8009c2 <strncmp+0x43>
		n--, p++, q++;
	if (n == 0)
		return 0;
  8009b4:	b8 00 00 00 00       	mov    $0x0,%eax
  8009b9:	eb 0f                	jmp    8009ca <strncmp+0x4b>
  8009bb:	b8 00 00 00 00       	mov    $0x0,%eax
  8009c0:	eb 08                	jmp    8009ca <strncmp+0x4b>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009c2:	0f b6 03             	movzbl (%ebx),%eax
  8009c5:	0f b6 12             	movzbl (%edx),%edx
  8009c8:	29 d0                	sub    %edx,%eax
}
  8009ca:	5b                   	pop    %ebx
  8009cb:	5e                   	pop    %esi
  8009cc:	5d                   	pop    %ebp
  8009cd:	c3                   	ret    

008009ce <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009ce:	55                   	push   %ebp
  8009cf:	89 e5                	mov    %esp,%ebp
  8009d1:	53                   	push   %ebx
  8009d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  8009d8:	8a 10                	mov    (%eax),%dl
  8009da:	84 d2                	test   %dl,%dl
  8009dc:	74 1a                	je     8009f8 <strchr+0x2a>
  8009de:	88 d9                	mov    %bl,%cl
		if (*s == c)
  8009e0:	38 d3                	cmp    %dl,%bl
  8009e2:	75 06                	jne    8009ea <strchr+0x1c>
  8009e4:	eb 17                	jmp    8009fd <strchr+0x2f>
  8009e6:	38 ca                	cmp    %cl,%dl
  8009e8:	74 13                	je     8009fd <strchr+0x2f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009ea:	40                   	inc    %eax
  8009eb:	8a 10                	mov    (%eax),%dl
  8009ed:	84 d2                	test   %dl,%dl
  8009ef:	75 f5                	jne    8009e6 <strchr+0x18>
		if (*s == c)
			return (char *) s;
	return 0;
  8009f1:	b8 00 00 00 00       	mov    $0x0,%eax
  8009f6:	eb 05                	jmp    8009fd <strchr+0x2f>
  8009f8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009fd:	5b                   	pop    %ebx
  8009fe:	5d                   	pop    %ebp
  8009ff:	c3                   	ret    

00800a00 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a00:	55                   	push   %ebp
  800a01:	89 e5                	mov    %esp,%ebp
  800a03:	53                   	push   %ebx
  800a04:	8b 45 08             	mov    0x8(%ebp),%eax
  800a07:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  800a0a:	8a 10                	mov    (%eax),%dl
  800a0c:	84 d2                	test   %dl,%dl
  800a0e:	74 13                	je     800a23 <strfind+0x23>
  800a10:	88 d9                	mov    %bl,%cl
		if (*s == c)
  800a12:	38 d3                	cmp    %dl,%bl
  800a14:	75 06                	jne    800a1c <strfind+0x1c>
  800a16:	eb 0b                	jmp    800a23 <strfind+0x23>
  800a18:	38 ca                	cmp    %cl,%dl
  800a1a:	74 07                	je     800a23 <strfind+0x23>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a1c:	40                   	inc    %eax
  800a1d:	8a 10                	mov    (%eax),%dl
  800a1f:	84 d2                	test   %dl,%dl
  800a21:	75 f5                	jne    800a18 <strfind+0x18>
		if (*s == c)
			break;
	return (char *) s;
}
  800a23:	5b                   	pop    %ebx
  800a24:	5d                   	pop    %ebp
  800a25:	c3                   	ret    

00800a26 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a26:	55                   	push   %ebp
  800a27:	89 e5                	mov    %esp,%ebp
  800a29:	57                   	push   %edi
  800a2a:	56                   	push   %esi
  800a2b:	53                   	push   %ebx
  800a2c:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a2f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a32:	85 c9                	test   %ecx,%ecx
  800a34:	74 36                	je     800a6c <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a36:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a3c:	75 28                	jne    800a66 <memset+0x40>
  800a3e:	f6 c1 03             	test   $0x3,%cl
  800a41:	75 23                	jne    800a66 <memset+0x40>
		c &= 0xFF;
  800a43:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a47:	89 d3                	mov    %edx,%ebx
  800a49:	c1 e3 08             	shl    $0x8,%ebx
  800a4c:	89 d6                	mov    %edx,%esi
  800a4e:	c1 e6 18             	shl    $0x18,%esi
  800a51:	89 d0                	mov    %edx,%eax
  800a53:	c1 e0 10             	shl    $0x10,%eax
  800a56:	09 f0                	or     %esi,%eax
  800a58:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800a5a:	89 d8                	mov    %ebx,%eax
  800a5c:	09 d0                	or     %edx,%eax
  800a5e:	c1 e9 02             	shr    $0x2,%ecx
  800a61:	fc                   	cld    
  800a62:	f3 ab                	rep stos %eax,%es:(%edi)
  800a64:	eb 06                	jmp    800a6c <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a66:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a69:	fc                   	cld    
  800a6a:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a6c:	89 f8                	mov    %edi,%eax
  800a6e:	5b                   	pop    %ebx
  800a6f:	5e                   	pop    %esi
  800a70:	5f                   	pop    %edi
  800a71:	5d                   	pop    %ebp
  800a72:	c3                   	ret    

00800a73 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a73:	55                   	push   %ebp
  800a74:	89 e5                	mov    %esp,%ebp
  800a76:	57                   	push   %edi
  800a77:	56                   	push   %esi
  800a78:	8b 45 08             	mov    0x8(%ebp),%eax
  800a7b:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a7e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a81:	39 c6                	cmp    %eax,%esi
  800a83:	73 33                	jae    800ab8 <memmove+0x45>
  800a85:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a88:	39 d0                	cmp    %edx,%eax
  800a8a:	73 2c                	jae    800ab8 <memmove+0x45>
		s += n;
		d += n;
  800a8c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a8f:	89 d6                	mov    %edx,%esi
  800a91:	09 fe                	or     %edi,%esi
  800a93:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a99:	75 13                	jne    800aae <memmove+0x3b>
  800a9b:	f6 c1 03             	test   $0x3,%cl
  800a9e:	75 0e                	jne    800aae <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800aa0:	83 ef 04             	sub    $0x4,%edi
  800aa3:	8d 72 fc             	lea    -0x4(%edx),%esi
  800aa6:	c1 e9 02             	shr    $0x2,%ecx
  800aa9:	fd                   	std    
  800aaa:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800aac:	eb 07                	jmp    800ab5 <memmove+0x42>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800aae:	4f                   	dec    %edi
  800aaf:	8d 72 ff             	lea    -0x1(%edx),%esi
  800ab2:	fd                   	std    
  800ab3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ab5:	fc                   	cld    
  800ab6:	eb 1d                	jmp    800ad5 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ab8:	89 f2                	mov    %esi,%edx
  800aba:	09 c2                	or     %eax,%edx
  800abc:	f6 c2 03             	test   $0x3,%dl
  800abf:	75 0f                	jne    800ad0 <memmove+0x5d>
  800ac1:	f6 c1 03             	test   $0x3,%cl
  800ac4:	75 0a                	jne    800ad0 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
  800ac6:	c1 e9 02             	shr    $0x2,%ecx
  800ac9:	89 c7                	mov    %eax,%edi
  800acb:	fc                   	cld    
  800acc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ace:	eb 05                	jmp    800ad5 <memmove+0x62>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800ad0:	89 c7                	mov    %eax,%edi
  800ad2:	fc                   	cld    
  800ad3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ad5:	5e                   	pop    %esi
  800ad6:	5f                   	pop    %edi
  800ad7:	5d                   	pop    %ebp
  800ad8:	c3                   	ret    

00800ad9 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ad9:	55                   	push   %ebp
  800ada:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800adc:	ff 75 10             	pushl  0x10(%ebp)
  800adf:	ff 75 0c             	pushl  0xc(%ebp)
  800ae2:	ff 75 08             	pushl  0x8(%ebp)
  800ae5:	e8 89 ff ff ff       	call   800a73 <memmove>
}
  800aea:	c9                   	leave  
  800aeb:	c3                   	ret    

00800aec <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800aec:	55                   	push   %ebp
  800aed:	89 e5                	mov    %esp,%ebp
  800aef:	57                   	push   %edi
  800af0:	56                   	push   %esi
  800af1:	53                   	push   %ebx
  800af2:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800af5:	8b 75 0c             	mov    0xc(%ebp),%esi
  800af8:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800afb:	85 c0                	test   %eax,%eax
  800afd:	74 33                	je     800b32 <memcmp+0x46>
  800aff:	8d 78 ff             	lea    -0x1(%eax),%edi
		if (*s1 != *s2)
  800b02:	8a 13                	mov    (%ebx),%dl
  800b04:	8a 0e                	mov    (%esi),%cl
  800b06:	38 ca                	cmp    %cl,%dl
  800b08:	75 13                	jne    800b1d <memcmp+0x31>
  800b0a:	b8 00 00 00 00       	mov    $0x0,%eax
  800b0f:	eb 16                	jmp    800b27 <memcmp+0x3b>
  800b11:	8a 54 03 01          	mov    0x1(%ebx,%eax,1),%dl
  800b15:	40                   	inc    %eax
  800b16:	8a 0c 06             	mov    (%esi,%eax,1),%cl
  800b19:	38 ca                	cmp    %cl,%dl
  800b1b:	74 0a                	je     800b27 <memcmp+0x3b>
			return (int) *s1 - (int) *s2;
  800b1d:	0f b6 c2             	movzbl %dl,%eax
  800b20:	0f b6 c9             	movzbl %cl,%ecx
  800b23:	29 c8                	sub    %ecx,%eax
  800b25:	eb 10                	jmp    800b37 <memcmp+0x4b>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b27:	39 f8                	cmp    %edi,%eax
  800b29:	75 e6                	jne    800b11 <memcmp+0x25>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b2b:	b8 00 00 00 00       	mov    $0x0,%eax
  800b30:	eb 05                	jmp    800b37 <memcmp+0x4b>
  800b32:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b37:	5b                   	pop    %ebx
  800b38:	5e                   	pop    %esi
  800b39:	5f                   	pop    %edi
  800b3a:	5d                   	pop    %ebp
  800b3b:	c3                   	ret    

00800b3c <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b3c:	55                   	push   %ebp
  800b3d:	89 e5                	mov    %esp,%ebp
  800b3f:	53                   	push   %ebx
  800b40:	8b 55 08             	mov    0x8(%ebp),%edx
	const void *ends = (const char *) s + n;
  800b43:	89 d0                	mov    %edx,%eax
  800b45:	03 45 10             	add    0x10(%ebp),%eax
	for (; s < ends; s++)
  800b48:	39 c2                	cmp    %eax,%edx
  800b4a:	73 1b                	jae    800b67 <memfind+0x2b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b4c:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
  800b50:	0f b6 0a             	movzbl (%edx),%ecx
  800b53:	39 d9                	cmp    %ebx,%ecx
  800b55:	75 09                	jne    800b60 <memfind+0x24>
  800b57:	eb 12                	jmp    800b6b <memfind+0x2f>
  800b59:	0f b6 0a             	movzbl (%edx),%ecx
  800b5c:	39 d9                	cmp    %ebx,%ecx
  800b5e:	74 0f                	je     800b6f <memfind+0x33>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b60:	42                   	inc    %edx
  800b61:	39 d0                	cmp    %edx,%eax
  800b63:	75 f4                	jne    800b59 <memfind+0x1d>
  800b65:	eb 0a                	jmp    800b71 <memfind+0x35>
  800b67:	89 d0                	mov    %edx,%eax
  800b69:	eb 06                	jmp    800b71 <memfind+0x35>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b6b:	89 d0                	mov    %edx,%eax
  800b6d:	eb 02                	jmp    800b71 <memfind+0x35>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b6f:	89 d0                	mov    %edx,%eax
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b71:	5b                   	pop    %ebx
  800b72:	5d                   	pop    %ebp
  800b73:	c3                   	ret    

00800b74 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b74:	55                   	push   %ebp
  800b75:	89 e5                	mov    %esp,%ebp
  800b77:	57                   	push   %edi
  800b78:	56                   	push   %esi
  800b79:	53                   	push   %ebx
  800b7a:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b7d:	eb 01                	jmp    800b80 <strtol+0xc>
		s++;
  800b7f:	41                   	inc    %ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b80:	8a 01                	mov    (%ecx),%al
  800b82:	3c 20                	cmp    $0x20,%al
  800b84:	74 f9                	je     800b7f <strtol+0xb>
  800b86:	3c 09                	cmp    $0x9,%al
  800b88:	74 f5                	je     800b7f <strtol+0xb>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b8a:	3c 2b                	cmp    $0x2b,%al
  800b8c:	75 08                	jne    800b96 <strtol+0x22>
		s++;
  800b8e:	41                   	inc    %ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b8f:	bf 00 00 00 00       	mov    $0x0,%edi
  800b94:	eb 11                	jmp    800ba7 <strtol+0x33>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b96:	3c 2d                	cmp    $0x2d,%al
  800b98:	75 08                	jne    800ba2 <strtol+0x2e>
		s++, neg = 1;
  800b9a:	41                   	inc    %ecx
  800b9b:	bf 01 00 00 00       	mov    $0x1,%edi
  800ba0:	eb 05                	jmp    800ba7 <strtol+0x33>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ba2:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ba7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800bab:	0f 84 87 00 00 00    	je     800c38 <strtol+0xc4>
  800bb1:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  800bb5:	75 27                	jne    800bde <strtol+0x6a>
  800bb7:	80 39 30             	cmpb   $0x30,(%ecx)
  800bba:	75 22                	jne    800bde <strtol+0x6a>
  800bbc:	e9 88 00 00 00       	jmp    800c49 <strtol+0xd5>
		s += 2, base = 16;
  800bc1:	83 c1 02             	add    $0x2,%ecx
  800bc4:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  800bcb:	eb 11                	jmp    800bde <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
  800bcd:	41                   	inc    %ecx
  800bce:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  800bd5:	eb 07                	jmp    800bde <strtol+0x6a>
	else if (base == 0)
		base = 10;
  800bd7:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)
  800bde:	b8 00 00 00 00       	mov    $0x0,%eax

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800be3:	8a 11                	mov    (%ecx),%dl
  800be5:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800be8:	80 fb 09             	cmp    $0x9,%bl
  800beb:	77 08                	ja     800bf5 <strtol+0x81>
			dig = *s - '0';
  800bed:	0f be d2             	movsbl %dl,%edx
  800bf0:	83 ea 30             	sub    $0x30,%edx
  800bf3:	eb 22                	jmp    800c17 <strtol+0xa3>
		else if (*s >= 'a' && *s <= 'z')
  800bf5:	8d 72 9f             	lea    -0x61(%edx),%esi
  800bf8:	89 f3                	mov    %esi,%ebx
  800bfa:	80 fb 19             	cmp    $0x19,%bl
  800bfd:	77 08                	ja     800c07 <strtol+0x93>
			dig = *s - 'a' + 10;
  800bff:	0f be d2             	movsbl %dl,%edx
  800c02:	83 ea 57             	sub    $0x57,%edx
  800c05:	eb 10                	jmp    800c17 <strtol+0xa3>
		else if (*s >= 'A' && *s <= 'Z')
  800c07:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c0a:	89 f3                	mov    %esi,%ebx
  800c0c:	80 fb 19             	cmp    $0x19,%bl
  800c0f:	77 14                	ja     800c25 <strtol+0xb1>
			dig = *s - 'A' + 10;
  800c11:	0f be d2             	movsbl %dl,%edx
  800c14:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800c17:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c1a:	7d 09                	jge    800c25 <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800c1c:	41                   	inc    %ecx
  800c1d:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c21:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800c23:	eb be                	jmp    800be3 <strtol+0x6f>

	if (endptr)
  800c25:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c29:	74 05                	je     800c30 <strtol+0xbc>
		*endptr = (char *) s;
  800c2b:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c2e:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800c30:	85 ff                	test   %edi,%edi
  800c32:	74 21                	je     800c55 <strtol+0xe1>
  800c34:	f7 d8                	neg    %eax
  800c36:	eb 1d                	jmp    800c55 <strtol+0xe1>
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c38:	80 39 30             	cmpb   $0x30,(%ecx)
  800c3b:	75 9a                	jne    800bd7 <strtol+0x63>
  800c3d:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c41:	0f 84 7a ff ff ff    	je     800bc1 <strtol+0x4d>
  800c47:	eb 84                	jmp    800bcd <strtol+0x59>
  800c49:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c4d:	0f 84 6e ff ff ff    	je     800bc1 <strtol+0x4d>
  800c53:	eb 89                	jmp    800bde <strtol+0x6a>
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
}
  800c55:	5b                   	pop    %ebx
  800c56:	5e                   	pop    %esi
  800c57:	5f                   	pop    %edi
  800c58:	5d                   	pop    %ebp
  800c59:	c3                   	ret    

00800c5a <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c5a:	55                   	push   %ebp
  800c5b:	89 e5                	mov    %esp,%ebp
  800c5d:	57                   	push   %edi
  800c5e:	56                   	push   %esi
  800c5f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c60:	b8 00 00 00 00       	mov    $0x0,%eax
  800c65:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c68:	8b 55 08             	mov    0x8(%ebp),%edx
  800c6b:	89 c3                	mov    %eax,%ebx
  800c6d:	89 c7                	mov    %eax,%edi
  800c6f:	89 c6                	mov    %eax,%esi
  800c71:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c73:	5b                   	pop    %ebx
  800c74:	5e                   	pop    %esi
  800c75:	5f                   	pop    %edi
  800c76:	5d                   	pop    %ebp
  800c77:	c3                   	ret    

00800c78 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c78:	55                   	push   %ebp
  800c79:	89 e5                	mov    %esp,%ebp
  800c7b:	57                   	push   %edi
  800c7c:	56                   	push   %esi
  800c7d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c7e:	ba 00 00 00 00       	mov    $0x0,%edx
  800c83:	b8 01 00 00 00       	mov    $0x1,%eax
  800c88:	89 d1                	mov    %edx,%ecx
  800c8a:	89 d3                	mov    %edx,%ebx
  800c8c:	89 d7                	mov    %edx,%edi
  800c8e:	89 d6                	mov    %edx,%esi
  800c90:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c92:	5b                   	pop    %ebx
  800c93:	5e                   	pop    %esi
  800c94:	5f                   	pop    %edi
  800c95:	5d                   	pop    %ebp
  800c96:	c3                   	ret    

00800c97 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c97:	55                   	push   %ebp
  800c98:	89 e5                	mov    %esp,%ebp
  800c9a:	57                   	push   %edi
  800c9b:	56                   	push   %esi
  800c9c:	53                   	push   %ebx
  800c9d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca0:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ca5:	b8 03 00 00 00       	mov    $0x3,%eax
  800caa:	8b 55 08             	mov    0x8(%ebp),%edx
  800cad:	89 cb                	mov    %ecx,%ebx
  800caf:	89 cf                	mov    %ecx,%edi
  800cb1:	89 ce                	mov    %ecx,%esi
  800cb3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cb5:	85 c0                	test   %eax,%eax
  800cb7:	7e 17                	jle    800cd0 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb9:	83 ec 0c             	sub    $0xc,%esp
  800cbc:	50                   	push   %eax
  800cbd:	6a 03                	push   $0x3
  800cbf:	68 df 2c 80 00       	push   $0x802cdf
  800cc4:	6a 23                	push   $0x23
  800cc6:	68 fc 2c 80 00       	push   $0x802cfc
  800ccb:	e8 19 f5 ff ff       	call   8001e9 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800cd0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cd3:	5b                   	pop    %ebx
  800cd4:	5e                   	pop    %esi
  800cd5:	5f                   	pop    %edi
  800cd6:	5d                   	pop    %ebp
  800cd7:	c3                   	ret    

00800cd8 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800cd8:	55                   	push   %ebp
  800cd9:	89 e5                	mov    %esp,%ebp
  800cdb:	57                   	push   %edi
  800cdc:	56                   	push   %esi
  800cdd:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cde:	ba 00 00 00 00       	mov    $0x0,%edx
  800ce3:	b8 02 00 00 00       	mov    $0x2,%eax
  800ce8:	89 d1                	mov    %edx,%ecx
  800cea:	89 d3                	mov    %edx,%ebx
  800cec:	89 d7                	mov    %edx,%edi
  800cee:	89 d6                	mov    %edx,%esi
  800cf0:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800cf2:	5b                   	pop    %ebx
  800cf3:	5e                   	pop    %esi
  800cf4:	5f                   	pop    %edi
  800cf5:	5d                   	pop    %ebp
  800cf6:	c3                   	ret    

00800cf7 <sys_yield>:

void
sys_yield(void)
{
  800cf7:	55                   	push   %ebp
  800cf8:	89 e5                	mov    %esp,%ebp
  800cfa:	57                   	push   %edi
  800cfb:	56                   	push   %esi
  800cfc:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cfd:	ba 00 00 00 00       	mov    $0x0,%edx
  800d02:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d07:	89 d1                	mov    %edx,%ecx
  800d09:	89 d3                	mov    %edx,%ebx
  800d0b:	89 d7                	mov    %edx,%edi
  800d0d:	89 d6                	mov    %edx,%esi
  800d0f:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d11:	5b                   	pop    %ebx
  800d12:	5e                   	pop    %esi
  800d13:	5f                   	pop    %edi
  800d14:	5d                   	pop    %ebp
  800d15:	c3                   	ret    

00800d16 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d16:	55                   	push   %ebp
  800d17:	89 e5                	mov    %esp,%ebp
  800d19:	57                   	push   %edi
  800d1a:	56                   	push   %esi
  800d1b:	53                   	push   %ebx
  800d1c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d1f:	be 00 00 00 00       	mov    $0x0,%esi
  800d24:	b8 04 00 00 00       	mov    $0x4,%eax
  800d29:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d2c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d2f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d32:	89 f7                	mov    %esi,%edi
  800d34:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d36:	85 c0                	test   %eax,%eax
  800d38:	7e 17                	jle    800d51 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d3a:	83 ec 0c             	sub    $0xc,%esp
  800d3d:	50                   	push   %eax
  800d3e:	6a 04                	push   $0x4
  800d40:	68 df 2c 80 00       	push   $0x802cdf
  800d45:	6a 23                	push   $0x23
  800d47:	68 fc 2c 80 00       	push   $0x802cfc
  800d4c:	e8 98 f4 ff ff       	call   8001e9 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d51:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d54:	5b                   	pop    %ebx
  800d55:	5e                   	pop    %esi
  800d56:	5f                   	pop    %edi
  800d57:	5d                   	pop    %ebp
  800d58:	c3                   	ret    

00800d59 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d59:	55                   	push   %ebp
  800d5a:	89 e5                	mov    %esp,%ebp
  800d5c:	57                   	push   %edi
  800d5d:	56                   	push   %esi
  800d5e:	53                   	push   %ebx
  800d5f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d62:	b8 05 00 00 00       	mov    $0x5,%eax
  800d67:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d6a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d6d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d70:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d73:	8b 75 18             	mov    0x18(%ebp),%esi
  800d76:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d78:	85 c0                	test   %eax,%eax
  800d7a:	7e 17                	jle    800d93 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d7c:	83 ec 0c             	sub    $0xc,%esp
  800d7f:	50                   	push   %eax
  800d80:	6a 05                	push   $0x5
  800d82:	68 df 2c 80 00       	push   $0x802cdf
  800d87:	6a 23                	push   $0x23
  800d89:	68 fc 2c 80 00       	push   $0x802cfc
  800d8e:	e8 56 f4 ff ff       	call   8001e9 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d93:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d96:	5b                   	pop    %ebx
  800d97:	5e                   	pop    %esi
  800d98:	5f                   	pop    %edi
  800d99:	5d                   	pop    %ebp
  800d9a:	c3                   	ret    

00800d9b <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d9b:	55                   	push   %ebp
  800d9c:	89 e5                	mov    %esp,%ebp
  800d9e:	57                   	push   %edi
  800d9f:	56                   	push   %esi
  800da0:	53                   	push   %ebx
  800da1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800da4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800da9:	b8 06 00 00 00       	mov    $0x6,%eax
  800dae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db1:	8b 55 08             	mov    0x8(%ebp),%edx
  800db4:	89 df                	mov    %ebx,%edi
  800db6:	89 de                	mov    %ebx,%esi
  800db8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dba:	85 c0                	test   %eax,%eax
  800dbc:	7e 17                	jle    800dd5 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dbe:	83 ec 0c             	sub    $0xc,%esp
  800dc1:	50                   	push   %eax
  800dc2:	6a 06                	push   $0x6
  800dc4:	68 df 2c 80 00       	push   $0x802cdf
  800dc9:	6a 23                	push   $0x23
  800dcb:	68 fc 2c 80 00       	push   $0x802cfc
  800dd0:	e8 14 f4 ff ff       	call   8001e9 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800dd5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dd8:	5b                   	pop    %ebx
  800dd9:	5e                   	pop    %esi
  800dda:	5f                   	pop    %edi
  800ddb:	5d                   	pop    %ebp
  800ddc:	c3                   	ret    

00800ddd <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ddd:	55                   	push   %ebp
  800dde:	89 e5                	mov    %esp,%ebp
  800de0:	57                   	push   %edi
  800de1:	56                   	push   %esi
  800de2:	53                   	push   %ebx
  800de3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800de6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800deb:	b8 08 00 00 00       	mov    $0x8,%eax
  800df0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800df3:	8b 55 08             	mov    0x8(%ebp),%edx
  800df6:	89 df                	mov    %ebx,%edi
  800df8:	89 de                	mov    %ebx,%esi
  800dfa:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dfc:	85 c0                	test   %eax,%eax
  800dfe:	7e 17                	jle    800e17 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e00:	83 ec 0c             	sub    $0xc,%esp
  800e03:	50                   	push   %eax
  800e04:	6a 08                	push   $0x8
  800e06:	68 df 2c 80 00       	push   $0x802cdf
  800e0b:	6a 23                	push   $0x23
  800e0d:	68 fc 2c 80 00       	push   $0x802cfc
  800e12:	e8 d2 f3 ff ff       	call   8001e9 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e17:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e1a:	5b                   	pop    %ebx
  800e1b:	5e                   	pop    %esi
  800e1c:	5f                   	pop    %edi
  800e1d:	5d                   	pop    %ebp
  800e1e:	c3                   	ret    

00800e1f <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e1f:	55                   	push   %ebp
  800e20:	89 e5                	mov    %esp,%ebp
  800e22:	57                   	push   %edi
  800e23:	56                   	push   %esi
  800e24:	53                   	push   %ebx
  800e25:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e28:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e2d:	b8 09 00 00 00       	mov    $0x9,%eax
  800e32:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e35:	8b 55 08             	mov    0x8(%ebp),%edx
  800e38:	89 df                	mov    %ebx,%edi
  800e3a:	89 de                	mov    %ebx,%esi
  800e3c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e3e:	85 c0                	test   %eax,%eax
  800e40:	7e 17                	jle    800e59 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e42:	83 ec 0c             	sub    $0xc,%esp
  800e45:	50                   	push   %eax
  800e46:	6a 09                	push   $0x9
  800e48:	68 df 2c 80 00       	push   $0x802cdf
  800e4d:	6a 23                	push   $0x23
  800e4f:	68 fc 2c 80 00       	push   $0x802cfc
  800e54:	e8 90 f3 ff ff       	call   8001e9 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e59:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e5c:	5b                   	pop    %ebx
  800e5d:	5e                   	pop    %esi
  800e5e:	5f                   	pop    %edi
  800e5f:	5d                   	pop    %ebp
  800e60:	c3                   	ret    

00800e61 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e61:	55                   	push   %ebp
  800e62:	89 e5                	mov    %esp,%ebp
  800e64:	57                   	push   %edi
  800e65:	56                   	push   %esi
  800e66:	53                   	push   %ebx
  800e67:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e6a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e6f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e74:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e77:	8b 55 08             	mov    0x8(%ebp),%edx
  800e7a:	89 df                	mov    %ebx,%edi
  800e7c:	89 de                	mov    %ebx,%esi
  800e7e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e80:	85 c0                	test   %eax,%eax
  800e82:	7e 17                	jle    800e9b <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e84:	83 ec 0c             	sub    $0xc,%esp
  800e87:	50                   	push   %eax
  800e88:	6a 0a                	push   $0xa
  800e8a:	68 df 2c 80 00       	push   $0x802cdf
  800e8f:	6a 23                	push   $0x23
  800e91:	68 fc 2c 80 00       	push   $0x802cfc
  800e96:	e8 4e f3 ff ff       	call   8001e9 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e9b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e9e:	5b                   	pop    %ebx
  800e9f:	5e                   	pop    %esi
  800ea0:	5f                   	pop    %edi
  800ea1:	5d                   	pop    %ebp
  800ea2:	c3                   	ret    

00800ea3 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ea3:	55                   	push   %ebp
  800ea4:	89 e5                	mov    %esp,%ebp
  800ea6:	57                   	push   %edi
  800ea7:	56                   	push   %esi
  800ea8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ea9:	be 00 00 00 00       	mov    $0x0,%esi
  800eae:	b8 0c 00 00 00       	mov    $0xc,%eax
  800eb3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eb6:	8b 55 08             	mov    0x8(%ebp),%edx
  800eb9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ebc:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ebf:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ec1:	5b                   	pop    %ebx
  800ec2:	5e                   	pop    %esi
  800ec3:	5f                   	pop    %edi
  800ec4:	5d                   	pop    %ebp
  800ec5:	c3                   	ret    

00800ec6 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ec6:	55                   	push   %ebp
  800ec7:	89 e5                	mov    %esp,%ebp
  800ec9:	57                   	push   %edi
  800eca:	56                   	push   %esi
  800ecb:	53                   	push   %ebx
  800ecc:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ecf:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ed4:	b8 0d 00 00 00       	mov    $0xd,%eax
  800ed9:	8b 55 08             	mov    0x8(%ebp),%edx
  800edc:	89 cb                	mov    %ecx,%ebx
  800ede:	89 cf                	mov    %ecx,%edi
  800ee0:	89 ce                	mov    %ecx,%esi
  800ee2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ee4:	85 c0                	test   %eax,%eax
  800ee6:	7e 17                	jle    800eff <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ee8:	83 ec 0c             	sub    $0xc,%esp
  800eeb:	50                   	push   %eax
  800eec:	6a 0d                	push   $0xd
  800eee:	68 df 2c 80 00       	push   $0x802cdf
  800ef3:	6a 23                	push   $0x23
  800ef5:	68 fc 2c 80 00       	push   $0x802cfc
  800efa:	e8 ea f2 ff ff       	call   8001e9 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800eff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f02:	5b                   	pop    %ebx
  800f03:	5e                   	pop    %esi
  800f04:	5f                   	pop    %edi
  800f05:	5d                   	pop    %ebp
  800f06:	c3                   	ret    

00800f07 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800f07:	55                   	push   %ebp
  800f08:	89 e5                	mov    %esp,%ebp
  800f0a:	56                   	push   %esi
  800f0b:	53                   	push   %ebx
  800f0c:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800f0f:	8b 18                	mov    (%eax),%ebx
	// copy-on-write page.  If not, panic.
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).
	
	if((err & FEC_WR) == 0){
  800f11:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800f15:	75 14                	jne    800f2b <pgfault+0x24>
		panic("pgfault not cause by write \n");
  800f17:	83 ec 04             	sub    $0x4,%esp
  800f1a:	68 0a 2d 80 00       	push   $0x802d0a
  800f1f:	6a 1c                	push   $0x1c
  800f21:	68 27 2d 80 00       	push   $0x802d27
  800f26:	e8 be f2 ff ff       	call   8001e9 <_panic>
	}
 
	if ((uvpt[PGNUM(addr)] & PTE_COW) == 0) 
  800f2b:	89 d8                	mov    %ebx,%eax
  800f2d:	c1 e8 0c             	shr    $0xc,%eax
  800f30:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f37:	f6 c4 08             	test   $0x8,%ah
  800f3a:	75 14                	jne    800f50 <pgfault+0x49>
    {
        panic("pgfault not cause by COW \n");
  800f3c:	83 ec 04             	sub    $0x4,%esp
  800f3f:	68 32 2d 80 00       	push   $0x802d32
  800f44:	6a 21                	push   $0x21
  800f46:	68 27 2d 80 00       	push   $0x802d27
  800f4b:	e8 99 f2 ff ff       	call   8001e9 <_panic>
	// copy the data from the old page to the new page, then move the new
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.
	envid_t eid = sys_getenvid();
  800f50:	e8 83 fd ff ff       	call   800cd8 <sys_getenvid>
  800f55:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(eid,(void*)PFTEMP,PTE_P|PTE_W|PTE_U)) < 0)
  800f57:	83 ec 04             	sub    $0x4,%esp
  800f5a:	6a 07                	push   $0x7
  800f5c:	68 00 f0 7f 00       	push   $0x7ff000
  800f61:	50                   	push   %eax
  800f62:	e8 af fd ff ff       	call   800d16 <sys_page_alloc>
  800f67:	83 c4 10             	add    $0x10,%esp
  800f6a:	85 c0                	test   %eax,%eax
  800f6c:	79 14                	jns    800f82 <pgfault+0x7b>
		panic("page alloction failed.\n");
  800f6e:	83 ec 04             	sub    $0x4,%esp
  800f71:	68 4d 2d 80 00       	push   $0x802d4d
  800f76:	6a 2d                	push   $0x2d
  800f78:	68 27 2d 80 00       	push   $0x802d27
  800f7d:	e8 67 f2 ff ff       	call   8001e9 <_panic>
	addr = ROUNDDOWN(addr,PGSIZE);
  800f82:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memmove(PFTEMP,addr,PGSIZE);
  800f88:	83 ec 04             	sub    $0x4,%esp
  800f8b:	68 00 10 00 00       	push   $0x1000
  800f90:	53                   	push   %ebx
  800f91:	68 00 f0 7f 00       	push   $0x7ff000
  800f96:	e8 d8 fa ff ff       	call   800a73 <memmove>
	if ((r = sys_page_map(eid, PFTEMP, eid, addr, PTE_P | PTE_W |PTE_U)) < 0)
  800f9b:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800fa2:	53                   	push   %ebx
  800fa3:	56                   	push   %esi
  800fa4:	68 00 f0 7f 00       	push   $0x7ff000
  800fa9:	56                   	push   %esi
  800faa:	e8 aa fd ff ff       	call   800d59 <sys_page_map>
  800faf:	83 c4 20             	add    $0x20,%esp
  800fb2:	85 c0                	test   %eax,%eax
  800fb4:	79 12                	jns    800fc8 <pgfault+0xc1>
        panic("pgfault: page map failed %e\n", r);
  800fb6:	50                   	push   %eax
  800fb7:	68 65 2d 80 00       	push   $0x802d65
  800fbc:	6a 31                	push   $0x31
  800fbe:	68 27 2d 80 00       	push   $0x802d27
  800fc3:	e8 21 f2 ff ff       	call   8001e9 <_panic>
	if ((r = sys_page_unmap(eid, PFTEMP)) < 0)
  800fc8:	83 ec 08             	sub    $0x8,%esp
  800fcb:	68 00 f0 7f 00       	push   $0x7ff000
  800fd0:	56                   	push   %esi
  800fd1:	e8 c5 fd ff ff       	call   800d9b <sys_page_unmap>
  800fd6:	83 c4 10             	add    $0x10,%esp
  800fd9:	85 c0                	test   %eax,%eax
  800fdb:	79 12                	jns    800fef <pgfault+0xe8>
        panic("pgfault: page unmap failed %e\n", r);
  800fdd:	50                   	push   %eax
  800fde:	68 d4 2d 80 00       	push   $0x802dd4
  800fe3:	6a 33                	push   $0x33
  800fe5:	68 27 2d 80 00       	push   $0x802d27
  800fea:	e8 fa f1 ff ff       	call   8001e9 <_panic>
	// LAB 4: Your code here.

	// panic("pgfault not implemented");
}
  800fef:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ff2:	5b                   	pop    %ebx
  800ff3:	5e                   	pop    %esi
  800ff4:	5d                   	pop    %ebp
  800ff5:	c3                   	ret    

00800ff6 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800ff6:	55                   	push   %ebp
  800ff7:	89 e5                	mov    %esp,%ebp
  800ff9:	57                   	push   %edi
  800ffa:	56                   	push   %esi
  800ffb:	53                   	push   %ebx
  800ffc:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	struct PageInfo* pg = NULL;
	set_pgfault_handler(pgfault);
  800fff:	68 07 0f 80 00       	push   $0x800f07
  801004:	e8 81 14 00 00       	call   80248a <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801009:	b8 07 00 00 00       	mov    $0x7,%eax
  80100e:	cd 30                	int    $0x30
  801010:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801013:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t eid = sys_exofork();
	if (eid < 0) panic("fork fault.\n");
  801016:	83 c4 10             	add    $0x10,%esp
  801019:	85 c0                	test   %eax,%eax
  80101b:	79 14                	jns    801031 <fork+0x3b>
  80101d:	83 ec 04             	sub    $0x4,%esp
  801020:	68 82 2d 80 00       	push   $0x802d82
  801025:	6a 71                	push   $0x71
  801027:	68 27 2d 80 00       	push   $0x802d27
  80102c:	e8 b8 f1 ff ff       	call   8001e9 <_panic>
	if (eid == 0){
  801031:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801035:	75 25                	jne    80105c <fork+0x66>
		thisenv = &envs[ENVX(sys_getenvid())];
  801037:	e8 9c fc ff ff       	call   800cd8 <sys_getenvid>
  80103c:	25 ff 03 00 00       	and    $0x3ff,%eax
  801041:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801048:	c1 e0 07             	shl    $0x7,%eax
  80104b:	29 d0                	sub    %edx,%eax
  80104d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801052:	a3 04 40 80 00       	mov    %eax,0x804004
		return eid;
  801057:	e9 61 01 00 00       	jmp    8011bd <fork+0x1c7>
  80105c:	bb 00 00 80 00       	mov    $0x800000,%ebx
	}
	// copy something to the child page.
	for (uintptr_t i = UTEXT;i <= USTACKTOP;i += PGSIZE){
		if (uvpd[PDX(i)] & PTE_P && (uvpt[PGNUM(i)] & PTE_P)){
  801061:	89 d8                	mov    %ebx,%eax
  801063:	c1 e8 16             	shr    $0x16,%eax
  801066:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80106d:	a8 01                	test   $0x1,%al
  80106f:	74 52                	je     8010c3 <fork+0xcd>
  801071:	89 de                	mov    %ebx,%esi
  801073:	c1 ee 0c             	shr    $0xc,%esi
  801076:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80107d:	a8 01                	test   $0x1,%al
  80107f:	74 42                	je     8010c3 <fork+0xcd>
duppage(envid_t envid, unsigned pn)
{
	int r;

	// LAB 4: Your code here.
	envid_t myenvid = sys_getenvid();
  801081:	e8 52 fc ff ff       	call   800cd8 <sys_getenvid>
  801086:	89 c7                	mov    %eax,%edi
	pte_t pte = uvpt[pn];
  801088:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
	int perm = PTE_U | PTE_P;
	if(pte & PTE_W || pte & PTE_COW)
  80108f:	a9 02 08 00 00       	test   $0x802,%eax
  801094:	0f 85 de 00 00 00    	jne    801178 <fork+0x182>
  80109a:	e9 fb 00 00 00       	jmp    80119a <fork+0x1a4>
		perm |= PTE_COW;
	if((r = sys_page_map(myenvid,(void*)(pn*PGSIZE),envid,(void*)(pn*PGSIZE),perm))<0){
		panic("duppage fault :%e\n",r);
  80109f:	50                   	push   %eax
  8010a0:	68 8f 2d 80 00       	push   $0x802d8f
  8010a5:	6a 50                	push   $0x50
  8010a7:	68 27 2d 80 00       	push   $0x802d27
  8010ac:	e8 38 f1 ff ff       	call   8001e9 <_panic>
	}
	if(perm & PTE_COW){
		if((r = sys_page_map(myenvid,(void*)(pn*PGSIZE),myenvid,(void*)(pn*PGSIZE),perm))<0)
			panic("duppage fault :%e\n",r);
  8010b1:	50                   	push   %eax
  8010b2:	68 8f 2d 80 00       	push   $0x802d8f
  8010b7:	6a 54                	push   $0x54
  8010b9:	68 27 2d 80 00       	push   $0x802d27
  8010be:	e8 26 f1 ff ff       	call   8001e9 <_panic>
	if (eid == 0){
		thisenv = &envs[ENVX(sys_getenvid())];
		return eid;
	}
	// copy something to the child page.
	for (uintptr_t i = UTEXT;i <= USTACKTOP;i += PGSIZE){
  8010c3:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8010c9:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  8010cf:	75 90                	jne    801061 <fork+0x6b>
		if (uvpd[PDX(i)] & PTE_P && (uvpt[PGNUM(i)] & PTE_P)){
			duppage(eid,PGNUM(i));
		}
	}
	int r = sys_page_alloc(eid,(void*)(UXSTACKTOP-PGSIZE),PTE_U|PTE_P|PTE_W);
  8010d1:	83 ec 04             	sub    $0x4,%esp
  8010d4:	6a 07                	push   $0x7
  8010d6:	68 00 f0 bf ee       	push   $0xeebff000
  8010db:	ff 75 e0             	pushl  -0x20(%ebp)
  8010de:	e8 33 fc ff ff       	call   800d16 <sys_page_alloc>
	if (r < 0) panic("fork fault.\n");
  8010e3:	83 c4 10             	add    $0x10,%esp
  8010e6:	85 c0                	test   %eax,%eax
  8010e8:	79 14                	jns    8010fe <fork+0x108>
  8010ea:	83 ec 04             	sub    $0x4,%esp
  8010ed:	68 82 2d 80 00       	push   $0x802d82
  8010f2:	6a 7d                	push   $0x7d
  8010f4:	68 27 2d 80 00       	push   $0x802d27
  8010f9:	e8 eb f0 ff ff       	call   8001e9 <_panic>

	extern void _pgfault_upcall();
    r = sys_env_set_pgfault_upcall(eid, _pgfault_upcall);
  8010fe:	83 ec 08             	sub    $0x8,%esp
  801101:	68 02 25 80 00       	push   $0x802502
  801106:	ff 75 e0             	pushl  -0x20(%ebp)
  801109:	e8 53 fd ff ff       	call   800e61 <sys_env_set_pgfault_upcall>
    if (r < 0) panic("fork fault 3\n");
  80110e:	83 c4 10             	add    $0x10,%esp
  801111:	85 c0                	test   %eax,%eax
  801113:	79 17                	jns    80112c <fork+0x136>
  801115:	83 ec 04             	sub    $0x4,%esp
  801118:	68 a2 2d 80 00       	push   $0x802da2
  80111d:	68 81 00 00 00       	push   $0x81
  801122:	68 27 2d 80 00       	push   $0x802d27
  801127:	e8 bd f0 ff ff       	call   8001e9 <_panic>

	if ((r = sys_env_set_status(eid, ENV_RUNNABLE)) < 0)
  80112c:	83 ec 08             	sub    $0x8,%esp
  80112f:	6a 02                	push   $0x2
  801131:	ff 75 e0             	pushl  -0x20(%ebp)
  801134:	e8 a4 fc ff ff       	call   800ddd <sys_env_set_status>
  801139:	83 c4 10             	add    $0x10,%esp
  80113c:	85 c0                	test   %eax,%eax
  80113e:	79 7d                	jns    8011bd <fork+0x1c7>
        panic("fork fault 4\n");
  801140:	83 ec 04             	sub    $0x4,%esp
  801143:	68 b0 2d 80 00       	push   $0x802db0
  801148:	68 84 00 00 00       	push   $0x84
  80114d:	68 27 2d 80 00       	push   $0x802d27
  801152:	e8 92 f0 ff ff       	call   8001e9 <_panic>
		perm |= PTE_COW;
	if((r = sys_page_map(myenvid,(void*)(pn*PGSIZE),envid,(void*)(pn*PGSIZE),perm))<0){
		panic("duppage fault :%e\n",r);
	}
	if(perm & PTE_COW){
		if((r = sys_page_map(myenvid,(void*)(pn*PGSIZE),myenvid,(void*)(pn*PGSIZE),perm))<0)
  801157:	83 ec 0c             	sub    $0xc,%esp
  80115a:	68 05 08 00 00       	push   $0x805
  80115f:	56                   	push   %esi
  801160:	57                   	push   %edi
  801161:	56                   	push   %esi
  801162:	57                   	push   %edi
  801163:	e8 f1 fb ff ff       	call   800d59 <sys_page_map>
  801168:	83 c4 20             	add    $0x20,%esp
  80116b:	85 c0                	test   %eax,%eax
  80116d:	0f 89 50 ff ff ff    	jns    8010c3 <fork+0xcd>
  801173:	e9 39 ff ff ff       	jmp    8010b1 <fork+0xbb>
	envid_t myenvid = sys_getenvid();
	pte_t pte = uvpt[pn];
	int perm = PTE_U | PTE_P;
	if(pte & PTE_W || pte & PTE_COW)
		perm |= PTE_COW;
	if((r = sys_page_map(myenvid,(void*)(pn*PGSIZE),envid,(void*)(pn*PGSIZE),perm))<0){
  801178:	c1 e6 0c             	shl    $0xc,%esi
  80117b:	83 ec 0c             	sub    $0xc,%esp
  80117e:	68 05 08 00 00       	push   $0x805
  801183:	56                   	push   %esi
  801184:	ff 75 e4             	pushl  -0x1c(%ebp)
  801187:	56                   	push   %esi
  801188:	57                   	push   %edi
  801189:	e8 cb fb ff ff       	call   800d59 <sys_page_map>
  80118e:	83 c4 20             	add    $0x20,%esp
  801191:	85 c0                	test   %eax,%eax
  801193:	79 c2                	jns    801157 <fork+0x161>
  801195:	e9 05 ff ff ff       	jmp    80109f <fork+0xa9>
  80119a:	c1 e6 0c             	shl    $0xc,%esi
  80119d:	83 ec 0c             	sub    $0xc,%esp
  8011a0:	6a 05                	push   $0x5
  8011a2:	56                   	push   %esi
  8011a3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011a6:	56                   	push   %esi
  8011a7:	57                   	push   %edi
  8011a8:	e8 ac fb ff ff       	call   800d59 <sys_page_map>
  8011ad:	83 c4 20             	add    $0x20,%esp
  8011b0:	85 c0                	test   %eax,%eax
  8011b2:	0f 89 0b ff ff ff    	jns    8010c3 <fork+0xcd>
  8011b8:	e9 e2 fe ff ff       	jmp    80109f <fork+0xa9>
    if (r < 0) panic("fork fault 3\n");

	if ((r = sys_env_set_status(eid, ENV_RUNNABLE)) < 0)
        panic("fork fault 4\n");
    return eid;
}
  8011bd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8011c0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011c3:	5b                   	pop    %ebx
  8011c4:	5e                   	pop    %esi
  8011c5:	5f                   	pop    %edi
  8011c6:	5d                   	pop    %ebp
  8011c7:	c3                   	ret    

008011c8 <sfork>:

// Challenge!
int
sfork(void)
{
  8011c8:	55                   	push   %ebp
  8011c9:	89 e5                	mov    %esp,%ebp
  8011cb:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8011ce:	68 be 2d 80 00       	push   $0x802dbe
  8011d3:	68 8c 00 00 00       	push   $0x8c
  8011d8:	68 27 2d 80 00       	push   $0x802d27
  8011dd:	e8 07 f0 ff ff       	call   8001e9 <_panic>

008011e2 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8011e2:	55                   	push   %ebp
  8011e3:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8011e8:	05 00 00 00 30       	add    $0x30000000,%eax
  8011ed:	c1 e8 0c             	shr    $0xc,%eax
}
  8011f0:	5d                   	pop    %ebp
  8011f1:	c3                   	ret    

008011f2 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8011f2:	55                   	push   %ebp
  8011f3:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8011f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8011f8:	05 00 00 00 30       	add    $0x30000000,%eax
  8011fd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801202:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801207:	5d                   	pop    %ebp
  801208:	c3                   	ret    

00801209 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801209:	55                   	push   %ebp
  80120a:	89 e5                	mov    %esp,%ebp
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80120c:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  801211:	a8 01                	test   $0x1,%al
  801213:	74 34                	je     801249 <fd_alloc+0x40>
  801215:	a1 00 00 74 ef       	mov    0xef740000,%eax
  80121a:	a8 01                	test   $0x1,%al
  80121c:	74 32                	je     801250 <fd_alloc+0x47>
  80121e:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  801223:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801225:	89 c2                	mov    %eax,%edx
  801227:	c1 ea 16             	shr    $0x16,%edx
  80122a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801231:	f6 c2 01             	test   $0x1,%dl
  801234:	74 1f                	je     801255 <fd_alloc+0x4c>
  801236:	89 c2                	mov    %eax,%edx
  801238:	c1 ea 0c             	shr    $0xc,%edx
  80123b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801242:	f6 c2 01             	test   $0x1,%dl
  801245:	75 1a                	jne    801261 <fd_alloc+0x58>
  801247:	eb 0c                	jmp    801255 <fd_alloc+0x4c>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  801249:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  80124e:	eb 05                	jmp    801255 <fd_alloc+0x4c>
  801250:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  801255:	8b 45 08             	mov    0x8(%ebp),%eax
  801258:	89 08                	mov    %ecx,(%eax)
			return 0;
  80125a:	b8 00 00 00 00       	mov    $0x0,%eax
  80125f:	eb 1a                	jmp    80127b <fd_alloc+0x72>
  801261:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801266:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80126b:	75 b6                	jne    801223 <fd_alloc+0x1a>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80126d:	8b 45 08             	mov    0x8(%ebp),%eax
  801270:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  801276:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80127b:	5d                   	pop    %ebp
  80127c:	c3                   	ret    

0080127d <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80127d:	55                   	push   %ebp
  80127e:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801280:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
  801284:	77 39                	ja     8012bf <fd_lookup+0x42>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801286:	8b 45 08             	mov    0x8(%ebp),%eax
  801289:	c1 e0 0c             	shl    $0xc,%eax
  80128c:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801291:	89 c2                	mov    %eax,%edx
  801293:	c1 ea 16             	shr    $0x16,%edx
  801296:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80129d:	f6 c2 01             	test   $0x1,%dl
  8012a0:	74 24                	je     8012c6 <fd_lookup+0x49>
  8012a2:	89 c2                	mov    %eax,%edx
  8012a4:	c1 ea 0c             	shr    $0xc,%edx
  8012a7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012ae:	f6 c2 01             	test   $0x1,%dl
  8012b1:	74 1a                	je     8012cd <fd_lookup+0x50>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8012b3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012b6:	89 02                	mov    %eax,(%edx)
	return 0;
  8012b8:	b8 00 00 00 00       	mov    $0x0,%eax
  8012bd:	eb 13                	jmp    8012d2 <fd_lookup+0x55>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012bf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012c4:	eb 0c                	jmp    8012d2 <fd_lookup+0x55>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012c6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012cb:	eb 05                	jmp    8012d2 <fd_lookup+0x55>
  8012cd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8012d2:	5d                   	pop    %ebp
  8012d3:	c3                   	ret    

008012d4 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8012d4:	55                   	push   %ebp
  8012d5:	89 e5                	mov    %esp,%ebp
  8012d7:	53                   	push   %ebx
  8012d8:	83 ec 04             	sub    $0x4,%esp
  8012db:	8b 45 08             	mov    0x8(%ebp),%eax
  8012de:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  8012e1:	3b 05 0c 30 80 00    	cmp    0x80300c,%eax
  8012e7:	75 1e                	jne    801307 <dev_lookup+0x33>
  8012e9:	eb 0e                	jmp    8012f9 <dev_lookup+0x25>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8012eb:	b8 28 30 80 00       	mov    $0x803028,%eax
  8012f0:	eb 0c                	jmp    8012fe <dev_lookup+0x2a>
  8012f2:	b8 44 30 80 00       	mov    $0x803044,%eax
  8012f7:	eb 05                	jmp    8012fe <dev_lookup+0x2a>
  8012f9:	b8 0c 30 80 00       	mov    $0x80300c,%eax
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  8012fe:	89 03                	mov    %eax,(%ebx)
			return 0;
  801300:	b8 00 00 00 00       	mov    $0x0,%eax
  801305:	eb 36                	jmp    80133d <dev_lookup+0x69>
int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  801307:	3b 05 28 30 80 00    	cmp    0x803028,%eax
  80130d:	74 dc                	je     8012eb <dev_lookup+0x17>
  80130f:	3b 05 44 30 80 00    	cmp    0x803044,%eax
  801315:	74 db                	je     8012f2 <dev_lookup+0x1e>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801317:	8b 15 04 40 80 00    	mov    0x804004,%edx
  80131d:	8b 52 48             	mov    0x48(%edx),%edx
  801320:	83 ec 04             	sub    $0x4,%esp
  801323:	50                   	push   %eax
  801324:	52                   	push   %edx
  801325:	68 f4 2d 80 00       	push   $0x802df4
  80132a:	e8 92 ef ff ff       	call   8002c1 <cprintf>
	*dev = 0;
  80132f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  801335:	83 c4 10             	add    $0x10,%esp
  801338:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80133d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801340:	c9                   	leave  
  801341:	c3                   	ret    

00801342 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801342:	55                   	push   %ebp
  801343:	89 e5                	mov    %esp,%ebp
  801345:	56                   	push   %esi
  801346:	53                   	push   %ebx
  801347:	83 ec 10             	sub    $0x10,%esp
  80134a:	8b 75 08             	mov    0x8(%ebp),%esi
  80134d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801350:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801353:	50                   	push   %eax
  801354:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80135a:	c1 e8 0c             	shr    $0xc,%eax
  80135d:	50                   	push   %eax
  80135e:	e8 1a ff ff ff       	call   80127d <fd_lookup>
  801363:	83 c4 08             	add    $0x8,%esp
  801366:	85 c0                	test   %eax,%eax
  801368:	78 05                	js     80136f <fd_close+0x2d>
	    || fd != fd2)
  80136a:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80136d:	74 06                	je     801375 <fd_close+0x33>
		return (must_exist ? r : 0);
  80136f:	84 db                	test   %bl,%bl
  801371:	74 47                	je     8013ba <fd_close+0x78>
  801373:	eb 4a                	jmp    8013bf <fd_close+0x7d>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801375:	83 ec 08             	sub    $0x8,%esp
  801378:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80137b:	50                   	push   %eax
  80137c:	ff 36                	pushl  (%esi)
  80137e:	e8 51 ff ff ff       	call   8012d4 <dev_lookup>
  801383:	89 c3                	mov    %eax,%ebx
  801385:	83 c4 10             	add    $0x10,%esp
  801388:	85 c0                	test   %eax,%eax
  80138a:	78 1c                	js     8013a8 <fd_close+0x66>
		if (dev->dev_close)
  80138c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80138f:	8b 40 10             	mov    0x10(%eax),%eax
  801392:	85 c0                	test   %eax,%eax
  801394:	74 0d                	je     8013a3 <fd_close+0x61>
			r = (*dev->dev_close)(fd);
  801396:	83 ec 0c             	sub    $0xc,%esp
  801399:	56                   	push   %esi
  80139a:	ff d0                	call   *%eax
  80139c:	89 c3                	mov    %eax,%ebx
  80139e:	83 c4 10             	add    $0x10,%esp
  8013a1:	eb 05                	jmp    8013a8 <fd_close+0x66>
		else
			r = 0;
  8013a3:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8013a8:	83 ec 08             	sub    $0x8,%esp
  8013ab:	56                   	push   %esi
  8013ac:	6a 00                	push   $0x0
  8013ae:	e8 e8 f9 ff ff       	call   800d9b <sys_page_unmap>
	return r;
  8013b3:	83 c4 10             	add    $0x10,%esp
  8013b6:	89 d8                	mov    %ebx,%eax
  8013b8:	eb 05                	jmp    8013bf <fd_close+0x7d>
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
  8013ba:	b8 00 00 00 00       	mov    $0x0,%eax
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
	return r;
}
  8013bf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013c2:	5b                   	pop    %ebx
  8013c3:	5e                   	pop    %esi
  8013c4:	5d                   	pop    %ebp
  8013c5:	c3                   	ret    

008013c6 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8013c6:	55                   	push   %ebp
  8013c7:	89 e5                	mov    %esp,%ebp
  8013c9:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013cc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013cf:	50                   	push   %eax
  8013d0:	ff 75 08             	pushl  0x8(%ebp)
  8013d3:	e8 a5 fe ff ff       	call   80127d <fd_lookup>
  8013d8:	83 c4 08             	add    $0x8,%esp
  8013db:	85 c0                	test   %eax,%eax
  8013dd:	78 10                	js     8013ef <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8013df:	83 ec 08             	sub    $0x8,%esp
  8013e2:	6a 01                	push   $0x1
  8013e4:	ff 75 f4             	pushl  -0xc(%ebp)
  8013e7:	e8 56 ff ff ff       	call   801342 <fd_close>
  8013ec:	83 c4 10             	add    $0x10,%esp
}
  8013ef:	c9                   	leave  
  8013f0:	c3                   	ret    

008013f1 <close_all>:

void
close_all(void)
{
  8013f1:	55                   	push   %ebp
  8013f2:	89 e5                	mov    %esp,%ebp
  8013f4:	53                   	push   %ebx
  8013f5:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8013f8:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8013fd:	83 ec 0c             	sub    $0xc,%esp
  801400:	53                   	push   %ebx
  801401:	e8 c0 ff ff ff       	call   8013c6 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801406:	43                   	inc    %ebx
  801407:	83 c4 10             	add    $0x10,%esp
  80140a:	83 fb 20             	cmp    $0x20,%ebx
  80140d:	75 ee                	jne    8013fd <close_all+0xc>
		close(i);
}
  80140f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801412:	c9                   	leave  
  801413:	c3                   	ret    

00801414 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801414:	55                   	push   %ebp
  801415:	89 e5                	mov    %esp,%ebp
  801417:	57                   	push   %edi
  801418:	56                   	push   %esi
  801419:	53                   	push   %ebx
  80141a:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80141d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801420:	50                   	push   %eax
  801421:	ff 75 08             	pushl  0x8(%ebp)
  801424:	e8 54 fe ff ff       	call   80127d <fd_lookup>
  801429:	83 c4 08             	add    $0x8,%esp
  80142c:	85 c0                	test   %eax,%eax
  80142e:	0f 88 c2 00 00 00    	js     8014f6 <dup+0xe2>
		return r;
	close(newfdnum);
  801434:	83 ec 0c             	sub    $0xc,%esp
  801437:	ff 75 0c             	pushl  0xc(%ebp)
  80143a:	e8 87 ff ff ff       	call   8013c6 <close>

	newfd = INDEX2FD(newfdnum);
  80143f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801442:	c1 e3 0c             	shl    $0xc,%ebx
  801445:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80144b:	83 c4 04             	add    $0x4,%esp
  80144e:	ff 75 e4             	pushl  -0x1c(%ebp)
  801451:	e8 9c fd ff ff       	call   8011f2 <fd2data>
  801456:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  801458:	89 1c 24             	mov    %ebx,(%esp)
  80145b:	e8 92 fd ff ff       	call   8011f2 <fd2data>
  801460:	83 c4 10             	add    $0x10,%esp
  801463:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801465:	89 f0                	mov    %esi,%eax
  801467:	c1 e8 16             	shr    $0x16,%eax
  80146a:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801471:	a8 01                	test   $0x1,%al
  801473:	74 35                	je     8014aa <dup+0x96>
  801475:	89 f0                	mov    %esi,%eax
  801477:	c1 e8 0c             	shr    $0xc,%eax
  80147a:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801481:	f6 c2 01             	test   $0x1,%dl
  801484:	74 24                	je     8014aa <dup+0x96>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801486:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80148d:	83 ec 0c             	sub    $0xc,%esp
  801490:	25 07 0e 00 00       	and    $0xe07,%eax
  801495:	50                   	push   %eax
  801496:	57                   	push   %edi
  801497:	6a 00                	push   $0x0
  801499:	56                   	push   %esi
  80149a:	6a 00                	push   $0x0
  80149c:	e8 b8 f8 ff ff       	call   800d59 <sys_page_map>
  8014a1:	89 c6                	mov    %eax,%esi
  8014a3:	83 c4 20             	add    $0x20,%esp
  8014a6:	85 c0                	test   %eax,%eax
  8014a8:	78 2c                	js     8014d6 <dup+0xc2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014aa:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8014ad:	89 d0                	mov    %edx,%eax
  8014af:	c1 e8 0c             	shr    $0xc,%eax
  8014b2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014b9:	83 ec 0c             	sub    $0xc,%esp
  8014bc:	25 07 0e 00 00       	and    $0xe07,%eax
  8014c1:	50                   	push   %eax
  8014c2:	53                   	push   %ebx
  8014c3:	6a 00                	push   $0x0
  8014c5:	52                   	push   %edx
  8014c6:	6a 00                	push   $0x0
  8014c8:	e8 8c f8 ff ff       	call   800d59 <sys_page_map>
  8014cd:	89 c6                	mov    %eax,%esi
  8014cf:	83 c4 20             	add    $0x20,%esp
  8014d2:	85 c0                	test   %eax,%eax
  8014d4:	79 1d                	jns    8014f3 <dup+0xdf>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8014d6:	83 ec 08             	sub    $0x8,%esp
  8014d9:	53                   	push   %ebx
  8014da:	6a 00                	push   $0x0
  8014dc:	e8 ba f8 ff ff       	call   800d9b <sys_page_unmap>
	sys_page_unmap(0, nva);
  8014e1:	83 c4 08             	add    $0x8,%esp
  8014e4:	57                   	push   %edi
  8014e5:	6a 00                	push   $0x0
  8014e7:	e8 af f8 ff ff       	call   800d9b <sys_page_unmap>
	return r;
  8014ec:	83 c4 10             	add    $0x10,%esp
  8014ef:	89 f0                	mov    %esi,%eax
  8014f1:	eb 03                	jmp    8014f6 <dup+0xe2>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  8014f3:	8b 45 0c             	mov    0xc(%ebp),%eax

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8014f6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014f9:	5b                   	pop    %ebx
  8014fa:	5e                   	pop    %esi
  8014fb:	5f                   	pop    %edi
  8014fc:	5d                   	pop    %ebp
  8014fd:	c3                   	ret    

008014fe <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8014fe:	55                   	push   %ebp
  8014ff:	89 e5                	mov    %esp,%ebp
  801501:	53                   	push   %ebx
  801502:	83 ec 14             	sub    $0x14,%esp
  801505:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801508:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80150b:	50                   	push   %eax
  80150c:	53                   	push   %ebx
  80150d:	e8 6b fd ff ff       	call   80127d <fd_lookup>
  801512:	83 c4 08             	add    $0x8,%esp
  801515:	85 c0                	test   %eax,%eax
  801517:	78 67                	js     801580 <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801519:	83 ec 08             	sub    $0x8,%esp
  80151c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80151f:	50                   	push   %eax
  801520:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801523:	ff 30                	pushl  (%eax)
  801525:	e8 aa fd ff ff       	call   8012d4 <dev_lookup>
  80152a:	83 c4 10             	add    $0x10,%esp
  80152d:	85 c0                	test   %eax,%eax
  80152f:	78 4f                	js     801580 <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801531:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801534:	8b 42 08             	mov    0x8(%edx),%eax
  801537:	83 e0 03             	and    $0x3,%eax
  80153a:	83 f8 01             	cmp    $0x1,%eax
  80153d:	75 21                	jne    801560 <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80153f:	a1 04 40 80 00       	mov    0x804004,%eax
  801544:	8b 40 48             	mov    0x48(%eax),%eax
  801547:	83 ec 04             	sub    $0x4,%esp
  80154a:	53                   	push   %ebx
  80154b:	50                   	push   %eax
  80154c:	68 35 2e 80 00       	push   $0x802e35
  801551:	e8 6b ed ff ff       	call   8002c1 <cprintf>
		return -E_INVAL;
  801556:	83 c4 10             	add    $0x10,%esp
  801559:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80155e:	eb 20                	jmp    801580 <read+0x82>
	}
	if (!dev->dev_read)
  801560:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801563:	8b 40 08             	mov    0x8(%eax),%eax
  801566:	85 c0                	test   %eax,%eax
  801568:	74 11                	je     80157b <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80156a:	83 ec 04             	sub    $0x4,%esp
  80156d:	ff 75 10             	pushl  0x10(%ebp)
  801570:	ff 75 0c             	pushl  0xc(%ebp)
  801573:	52                   	push   %edx
  801574:	ff d0                	call   *%eax
  801576:	83 c4 10             	add    $0x10,%esp
  801579:	eb 05                	jmp    801580 <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80157b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801580:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801583:	c9                   	leave  
  801584:	c3                   	ret    

00801585 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801585:	55                   	push   %ebp
  801586:	89 e5                	mov    %esp,%ebp
  801588:	57                   	push   %edi
  801589:	56                   	push   %esi
  80158a:	53                   	push   %ebx
  80158b:	83 ec 0c             	sub    $0xc,%esp
  80158e:	8b 7d 08             	mov    0x8(%ebp),%edi
  801591:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801594:	85 f6                	test   %esi,%esi
  801596:	74 31                	je     8015c9 <readn+0x44>
  801598:	b8 00 00 00 00       	mov    $0x0,%eax
  80159d:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  8015a2:	83 ec 04             	sub    $0x4,%esp
  8015a5:	89 f2                	mov    %esi,%edx
  8015a7:	29 c2                	sub    %eax,%edx
  8015a9:	52                   	push   %edx
  8015aa:	03 45 0c             	add    0xc(%ebp),%eax
  8015ad:	50                   	push   %eax
  8015ae:	57                   	push   %edi
  8015af:	e8 4a ff ff ff       	call   8014fe <read>
		if (m < 0)
  8015b4:	83 c4 10             	add    $0x10,%esp
  8015b7:	85 c0                	test   %eax,%eax
  8015b9:	78 17                	js     8015d2 <readn+0x4d>
			return m;
		if (m == 0)
  8015bb:	85 c0                	test   %eax,%eax
  8015bd:	74 11                	je     8015d0 <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015bf:	01 c3                	add    %eax,%ebx
  8015c1:	89 d8                	mov    %ebx,%eax
  8015c3:	39 f3                	cmp    %esi,%ebx
  8015c5:	72 db                	jb     8015a2 <readn+0x1d>
  8015c7:	eb 09                	jmp    8015d2 <readn+0x4d>
  8015c9:	b8 00 00 00 00       	mov    $0x0,%eax
  8015ce:	eb 02                	jmp    8015d2 <readn+0x4d>
  8015d0:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8015d2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015d5:	5b                   	pop    %ebx
  8015d6:	5e                   	pop    %esi
  8015d7:	5f                   	pop    %edi
  8015d8:	5d                   	pop    %ebp
  8015d9:	c3                   	ret    

008015da <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8015da:	55                   	push   %ebp
  8015db:	89 e5                	mov    %esp,%ebp
  8015dd:	53                   	push   %ebx
  8015de:	83 ec 14             	sub    $0x14,%esp
  8015e1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015e4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015e7:	50                   	push   %eax
  8015e8:	53                   	push   %ebx
  8015e9:	e8 8f fc ff ff       	call   80127d <fd_lookup>
  8015ee:	83 c4 08             	add    $0x8,%esp
  8015f1:	85 c0                	test   %eax,%eax
  8015f3:	78 62                	js     801657 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015f5:	83 ec 08             	sub    $0x8,%esp
  8015f8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015fb:	50                   	push   %eax
  8015fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015ff:	ff 30                	pushl  (%eax)
  801601:	e8 ce fc ff ff       	call   8012d4 <dev_lookup>
  801606:	83 c4 10             	add    $0x10,%esp
  801609:	85 c0                	test   %eax,%eax
  80160b:	78 4a                	js     801657 <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80160d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801610:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801614:	75 21                	jne    801637 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801616:	a1 04 40 80 00       	mov    0x804004,%eax
  80161b:	8b 40 48             	mov    0x48(%eax),%eax
  80161e:	83 ec 04             	sub    $0x4,%esp
  801621:	53                   	push   %ebx
  801622:	50                   	push   %eax
  801623:	68 51 2e 80 00       	push   $0x802e51
  801628:	e8 94 ec ff ff       	call   8002c1 <cprintf>
		return -E_INVAL;
  80162d:	83 c4 10             	add    $0x10,%esp
  801630:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801635:	eb 20                	jmp    801657 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801637:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80163a:	8b 52 0c             	mov    0xc(%edx),%edx
  80163d:	85 d2                	test   %edx,%edx
  80163f:	74 11                	je     801652 <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801641:	83 ec 04             	sub    $0x4,%esp
  801644:	ff 75 10             	pushl  0x10(%ebp)
  801647:	ff 75 0c             	pushl  0xc(%ebp)
  80164a:	50                   	push   %eax
  80164b:	ff d2                	call   *%edx
  80164d:	83 c4 10             	add    $0x10,%esp
  801650:	eb 05                	jmp    801657 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801652:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801657:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80165a:	c9                   	leave  
  80165b:	c3                   	ret    

0080165c <seek>:

int
seek(int fdnum, off_t offset)
{
  80165c:	55                   	push   %ebp
  80165d:	89 e5                	mov    %esp,%ebp
  80165f:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801662:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801665:	50                   	push   %eax
  801666:	ff 75 08             	pushl  0x8(%ebp)
  801669:	e8 0f fc ff ff       	call   80127d <fd_lookup>
  80166e:	83 c4 08             	add    $0x8,%esp
  801671:	85 c0                	test   %eax,%eax
  801673:	78 0e                	js     801683 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801675:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801678:	8b 55 0c             	mov    0xc(%ebp),%edx
  80167b:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80167e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801683:	c9                   	leave  
  801684:	c3                   	ret    

00801685 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801685:	55                   	push   %ebp
  801686:	89 e5                	mov    %esp,%ebp
  801688:	53                   	push   %ebx
  801689:	83 ec 14             	sub    $0x14,%esp
  80168c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80168f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801692:	50                   	push   %eax
  801693:	53                   	push   %ebx
  801694:	e8 e4 fb ff ff       	call   80127d <fd_lookup>
  801699:	83 c4 08             	add    $0x8,%esp
  80169c:	85 c0                	test   %eax,%eax
  80169e:	78 5f                	js     8016ff <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016a0:	83 ec 08             	sub    $0x8,%esp
  8016a3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016a6:	50                   	push   %eax
  8016a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016aa:	ff 30                	pushl  (%eax)
  8016ac:	e8 23 fc ff ff       	call   8012d4 <dev_lookup>
  8016b1:	83 c4 10             	add    $0x10,%esp
  8016b4:	85 c0                	test   %eax,%eax
  8016b6:	78 47                	js     8016ff <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016bb:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016bf:	75 21                	jne    8016e2 <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8016c1:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8016c6:	8b 40 48             	mov    0x48(%eax),%eax
  8016c9:	83 ec 04             	sub    $0x4,%esp
  8016cc:	53                   	push   %ebx
  8016cd:	50                   	push   %eax
  8016ce:	68 14 2e 80 00       	push   $0x802e14
  8016d3:	e8 e9 eb ff ff       	call   8002c1 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8016d8:	83 c4 10             	add    $0x10,%esp
  8016db:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016e0:	eb 1d                	jmp    8016ff <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  8016e2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016e5:	8b 52 18             	mov    0x18(%edx),%edx
  8016e8:	85 d2                	test   %edx,%edx
  8016ea:	74 0e                	je     8016fa <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8016ec:	83 ec 08             	sub    $0x8,%esp
  8016ef:	ff 75 0c             	pushl  0xc(%ebp)
  8016f2:	50                   	push   %eax
  8016f3:	ff d2                	call   *%edx
  8016f5:	83 c4 10             	add    $0x10,%esp
  8016f8:	eb 05                	jmp    8016ff <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8016fa:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8016ff:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801702:	c9                   	leave  
  801703:	c3                   	ret    

00801704 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801704:	55                   	push   %ebp
  801705:	89 e5                	mov    %esp,%ebp
  801707:	53                   	push   %ebx
  801708:	83 ec 14             	sub    $0x14,%esp
  80170b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80170e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801711:	50                   	push   %eax
  801712:	ff 75 08             	pushl  0x8(%ebp)
  801715:	e8 63 fb ff ff       	call   80127d <fd_lookup>
  80171a:	83 c4 08             	add    $0x8,%esp
  80171d:	85 c0                	test   %eax,%eax
  80171f:	78 52                	js     801773 <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801721:	83 ec 08             	sub    $0x8,%esp
  801724:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801727:	50                   	push   %eax
  801728:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80172b:	ff 30                	pushl  (%eax)
  80172d:	e8 a2 fb ff ff       	call   8012d4 <dev_lookup>
  801732:	83 c4 10             	add    $0x10,%esp
  801735:	85 c0                	test   %eax,%eax
  801737:	78 3a                	js     801773 <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  801739:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80173c:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801740:	74 2c                	je     80176e <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801742:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801745:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80174c:	00 00 00 
	stat->st_isdir = 0;
  80174f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801756:	00 00 00 
	stat->st_dev = dev;
  801759:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80175f:	83 ec 08             	sub    $0x8,%esp
  801762:	53                   	push   %ebx
  801763:	ff 75 f0             	pushl  -0x10(%ebp)
  801766:	ff 50 14             	call   *0x14(%eax)
  801769:	83 c4 10             	add    $0x10,%esp
  80176c:	eb 05                	jmp    801773 <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80176e:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801773:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801776:	c9                   	leave  
  801777:	c3                   	ret    

00801778 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801778:	55                   	push   %ebp
  801779:	89 e5                	mov    %esp,%ebp
  80177b:	56                   	push   %esi
  80177c:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80177d:	83 ec 08             	sub    $0x8,%esp
  801780:	6a 00                	push   $0x0
  801782:	ff 75 08             	pushl  0x8(%ebp)
  801785:	e8 75 01 00 00       	call   8018ff <open>
  80178a:	89 c3                	mov    %eax,%ebx
  80178c:	83 c4 10             	add    $0x10,%esp
  80178f:	85 c0                	test   %eax,%eax
  801791:	78 1d                	js     8017b0 <stat+0x38>
		return fd;
	r = fstat(fd, stat);
  801793:	83 ec 08             	sub    $0x8,%esp
  801796:	ff 75 0c             	pushl  0xc(%ebp)
  801799:	50                   	push   %eax
  80179a:	e8 65 ff ff ff       	call   801704 <fstat>
  80179f:	89 c6                	mov    %eax,%esi
	close(fd);
  8017a1:	89 1c 24             	mov    %ebx,(%esp)
  8017a4:	e8 1d fc ff ff       	call   8013c6 <close>
	return r;
  8017a9:	83 c4 10             	add    $0x10,%esp
  8017ac:	89 f0                	mov    %esi,%eax
  8017ae:	eb 00                	jmp    8017b0 <stat+0x38>
}
  8017b0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017b3:	5b                   	pop    %ebx
  8017b4:	5e                   	pop    %esi
  8017b5:	5d                   	pop    %ebp
  8017b6:	c3                   	ret    

008017b7 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8017b7:	55                   	push   %ebp
  8017b8:	89 e5                	mov    %esp,%ebp
  8017ba:	56                   	push   %esi
  8017bb:	53                   	push   %ebx
  8017bc:	89 c6                	mov    %eax,%esi
  8017be:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8017c0:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8017c7:	75 12                	jne    8017db <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8017c9:	83 ec 0c             	sub    $0xc,%esp
  8017cc:	6a 01                	push   $0x1
  8017ce:	e8 29 0e 00 00       	call   8025fc <ipc_find_env>
  8017d3:	a3 00 40 80 00       	mov    %eax,0x804000
  8017d8:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8017db:	6a 07                	push   $0x7
  8017dd:	68 00 50 80 00       	push   $0x805000
  8017e2:	56                   	push   %esi
  8017e3:	ff 35 00 40 80 00    	pushl  0x804000
  8017e9:	e8 af 0d 00 00       	call   80259d <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8017ee:	83 c4 0c             	add    $0xc,%esp
  8017f1:	6a 00                	push   $0x0
  8017f3:	53                   	push   %ebx
  8017f4:	6a 00                	push   $0x0
  8017f6:	e8 2d 0d 00 00       	call   802528 <ipc_recv>
}
  8017fb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017fe:	5b                   	pop    %ebx
  8017ff:	5e                   	pop    %esi
  801800:	5d                   	pop    %ebp
  801801:	c3                   	ret    

00801802 <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801802:	55                   	push   %ebp
  801803:	89 e5                	mov    %esp,%ebp
  801805:	53                   	push   %ebx
  801806:	83 ec 04             	sub    $0x4,%esp
  801809:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80180c:	8b 45 08             	mov    0x8(%ebp),%eax
  80180f:	8b 40 0c             	mov    0xc(%eax),%eax
  801812:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801817:	ba 00 00 00 00       	mov    $0x0,%edx
  80181c:	b8 05 00 00 00       	mov    $0x5,%eax
  801821:	e8 91 ff ff ff       	call   8017b7 <fsipc>
  801826:	85 c0                	test   %eax,%eax
  801828:	78 2c                	js     801856 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80182a:	83 ec 08             	sub    $0x8,%esp
  80182d:	68 00 50 80 00       	push   $0x805000
  801832:	53                   	push   %ebx
  801833:	e8 6e f0 ff ff       	call   8008a6 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801838:	a1 80 50 80 00       	mov    0x805080,%eax
  80183d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801843:	a1 84 50 80 00       	mov    0x805084,%eax
  801848:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80184e:	83 c4 10             	add    $0x10,%esp
  801851:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801856:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801859:	c9                   	leave  
  80185a:	c3                   	ret    

0080185b <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80185b:	55                   	push   %ebp
  80185c:	89 e5                	mov    %esp,%ebp
  80185e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801861:	8b 45 08             	mov    0x8(%ebp),%eax
  801864:	8b 40 0c             	mov    0xc(%eax),%eax
  801867:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80186c:	ba 00 00 00 00       	mov    $0x0,%edx
  801871:	b8 06 00 00 00       	mov    $0x6,%eax
  801876:	e8 3c ff ff ff       	call   8017b7 <fsipc>
}
  80187b:	c9                   	leave  
  80187c:	c3                   	ret    

0080187d <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80187d:	55                   	push   %ebp
  80187e:	89 e5                	mov    %esp,%ebp
  801880:	56                   	push   %esi
  801881:	53                   	push   %ebx
  801882:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801885:	8b 45 08             	mov    0x8(%ebp),%eax
  801888:	8b 40 0c             	mov    0xc(%eax),%eax
  80188b:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801890:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801896:	ba 00 00 00 00       	mov    $0x0,%edx
  80189b:	b8 03 00 00 00       	mov    $0x3,%eax
  8018a0:	e8 12 ff ff ff       	call   8017b7 <fsipc>
  8018a5:	89 c3                	mov    %eax,%ebx
  8018a7:	85 c0                	test   %eax,%eax
  8018a9:	78 4b                	js     8018f6 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8018ab:	39 c6                	cmp    %eax,%esi
  8018ad:	73 16                	jae    8018c5 <devfile_read+0x48>
  8018af:	68 6e 2e 80 00       	push   $0x802e6e
  8018b4:	68 75 2e 80 00       	push   $0x802e75
  8018b9:	6a 7a                	push   $0x7a
  8018bb:	68 8a 2e 80 00       	push   $0x802e8a
  8018c0:	e8 24 e9 ff ff       	call   8001e9 <_panic>
	assert(r <= PGSIZE);
  8018c5:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8018ca:	7e 16                	jle    8018e2 <devfile_read+0x65>
  8018cc:	68 95 2e 80 00       	push   $0x802e95
  8018d1:	68 75 2e 80 00       	push   $0x802e75
  8018d6:	6a 7b                	push   $0x7b
  8018d8:	68 8a 2e 80 00       	push   $0x802e8a
  8018dd:	e8 07 e9 ff ff       	call   8001e9 <_panic>
	memmove(buf, &fsipcbuf, r);
  8018e2:	83 ec 04             	sub    $0x4,%esp
  8018e5:	50                   	push   %eax
  8018e6:	68 00 50 80 00       	push   $0x805000
  8018eb:	ff 75 0c             	pushl  0xc(%ebp)
  8018ee:	e8 80 f1 ff ff       	call   800a73 <memmove>
	return r;
  8018f3:	83 c4 10             	add    $0x10,%esp
}
  8018f6:	89 d8                	mov    %ebx,%eax
  8018f8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018fb:	5b                   	pop    %ebx
  8018fc:	5e                   	pop    %esi
  8018fd:	5d                   	pop    %ebp
  8018fe:	c3                   	ret    

008018ff <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8018ff:	55                   	push   %ebp
  801900:	89 e5                	mov    %esp,%ebp
  801902:	53                   	push   %ebx
  801903:	83 ec 20             	sub    $0x20,%esp
  801906:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801909:	53                   	push   %ebx
  80190a:	e8 40 ef ff ff       	call   80084f <strlen>
  80190f:	83 c4 10             	add    $0x10,%esp
  801912:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801917:	7f 63                	jg     80197c <open+0x7d>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801919:	83 ec 0c             	sub    $0xc,%esp
  80191c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80191f:	50                   	push   %eax
  801920:	e8 e4 f8 ff ff       	call   801209 <fd_alloc>
  801925:	83 c4 10             	add    $0x10,%esp
  801928:	85 c0                	test   %eax,%eax
  80192a:	78 55                	js     801981 <open+0x82>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80192c:	83 ec 08             	sub    $0x8,%esp
  80192f:	53                   	push   %ebx
  801930:	68 00 50 80 00       	push   $0x805000
  801935:	e8 6c ef ff ff       	call   8008a6 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80193a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80193d:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801942:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801945:	b8 01 00 00 00       	mov    $0x1,%eax
  80194a:	e8 68 fe ff ff       	call   8017b7 <fsipc>
  80194f:	89 c3                	mov    %eax,%ebx
  801951:	83 c4 10             	add    $0x10,%esp
  801954:	85 c0                	test   %eax,%eax
  801956:	79 14                	jns    80196c <open+0x6d>
		fd_close(fd, 0);
  801958:	83 ec 08             	sub    $0x8,%esp
  80195b:	6a 00                	push   $0x0
  80195d:	ff 75 f4             	pushl  -0xc(%ebp)
  801960:	e8 dd f9 ff ff       	call   801342 <fd_close>
		return r;
  801965:	83 c4 10             	add    $0x10,%esp
  801968:	89 d8                	mov    %ebx,%eax
  80196a:	eb 15                	jmp    801981 <open+0x82>
	}

	return fd2num(fd);
  80196c:	83 ec 0c             	sub    $0xc,%esp
  80196f:	ff 75 f4             	pushl  -0xc(%ebp)
  801972:	e8 6b f8 ff ff       	call   8011e2 <fd2num>
  801977:	83 c4 10             	add    $0x10,%esp
  80197a:	eb 05                	jmp    801981 <open+0x82>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80197c:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801981:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801984:	c9                   	leave  
  801985:	c3                   	ret    

00801986 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  801986:	55                   	push   %ebp
  801987:	89 e5                	mov    %esp,%ebp
  801989:	57                   	push   %edi
  80198a:	56                   	push   %esi
  80198b:	53                   	push   %ebx
  80198c:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  801992:	6a 00                	push   $0x0
  801994:	ff 75 08             	pushl  0x8(%ebp)
  801997:	e8 63 ff ff ff       	call   8018ff <open>
  80199c:	89 c1                	mov    %eax,%ecx
  80199e:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  8019a4:	83 c4 10             	add    $0x10,%esp
  8019a7:	85 c0                	test   %eax,%eax
  8019a9:	0f 88 6f 04 00 00    	js     801e1e <spawn+0x498>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  8019af:	83 ec 04             	sub    $0x4,%esp
  8019b2:	68 00 02 00 00       	push   $0x200
  8019b7:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  8019bd:	50                   	push   %eax
  8019be:	51                   	push   %ecx
  8019bf:	e8 c1 fb ff ff       	call   801585 <readn>
  8019c4:	83 c4 10             	add    $0x10,%esp
  8019c7:	3d 00 02 00 00       	cmp    $0x200,%eax
  8019cc:	75 0c                	jne    8019da <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  8019ce:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  8019d5:	45 4c 46 
  8019d8:	74 33                	je     801a0d <spawn+0x87>
		close(fd);
  8019da:	83 ec 0c             	sub    $0xc,%esp
  8019dd:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8019e3:	e8 de f9 ff ff       	call   8013c6 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  8019e8:	83 c4 0c             	add    $0xc,%esp
  8019eb:	68 7f 45 4c 46       	push   $0x464c457f
  8019f0:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  8019f6:	68 a1 2e 80 00       	push   $0x802ea1
  8019fb:	e8 c1 e8 ff ff       	call   8002c1 <cprintf>
		return -E_NOT_EXEC;
  801a00:	83 c4 10             	add    $0x10,%esp
  801a03:	bb f2 ff ff ff       	mov    $0xfffffff2,%ebx
  801a08:	e9 71 04 00 00       	jmp    801e7e <spawn+0x4f8>
  801a0d:	b8 07 00 00 00       	mov    $0x7,%eax
  801a12:	cd 30                	int    $0x30
  801a14:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  801a1a:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801a20:	85 c0                	test   %eax,%eax
  801a22:	0f 88 fe 03 00 00    	js     801e26 <spawn+0x4a0>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801a28:	89 c6                	mov    %eax,%esi
  801a2a:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  801a30:	8d 04 b5 00 00 00 00 	lea    0x0(,%esi,4),%eax
  801a37:	c1 e6 07             	shl    $0x7,%esi
  801a3a:	29 c6                	sub    %eax,%esi
  801a3c:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  801a42:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801a48:	b9 11 00 00 00       	mov    $0x11,%ecx
  801a4d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801a4f:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801a55:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801a5b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a5e:	8b 00                	mov    (%eax),%eax
  801a60:	85 c0                	test   %eax,%eax
  801a62:	74 3a                	je     801a9e <spawn+0x118>
  801a64:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a69:	be 00 00 00 00       	mov    $0x0,%esi
  801a6e:	8b 7d 0c             	mov    0xc(%ebp),%edi
		string_size += strlen(argv[argc]) + 1;
  801a71:	83 ec 0c             	sub    $0xc,%esp
  801a74:	50                   	push   %eax
  801a75:	e8 d5 ed ff ff       	call   80084f <strlen>
  801a7a:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801a7e:	43                   	inc    %ebx
  801a7f:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  801a86:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  801a89:	83 c4 10             	add    $0x10,%esp
  801a8c:	85 c0                	test   %eax,%eax
  801a8e:	75 e1                	jne    801a71 <spawn+0xeb>
  801a90:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  801a96:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
  801a9c:	eb 1e                	jmp    801abc <spawn+0x136>
  801a9e:	c7 85 80 fd ff ff 00 	movl   $0x0,-0x280(%ebp)
  801aa5:	00 00 00 
  801aa8:	c7 85 88 fd ff ff 00 	movl   $0x0,-0x278(%ebp)
  801aaf:	00 00 00 
  801ab2:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  801ab7:	be 00 00 00 00       	mov    $0x0,%esi
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801abc:	bf 00 10 40 00       	mov    $0x401000,%edi
  801ac1:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801ac3:	89 fa                	mov    %edi,%edx
  801ac5:	83 e2 fc             	and    $0xfffffffc,%edx
  801ac8:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  801acf:	29 c2                	sub    %eax,%edx
  801ad1:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801ad7:	8d 42 f8             	lea    -0x8(%edx),%eax
  801ada:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801adf:	0f 86 51 03 00 00    	jbe    801e36 <spawn+0x4b0>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801ae5:	83 ec 04             	sub    $0x4,%esp
  801ae8:	6a 07                	push   $0x7
  801aea:	68 00 00 40 00       	push   $0x400000
  801aef:	6a 00                	push   $0x0
  801af1:	e8 20 f2 ff ff       	call   800d16 <sys_page_alloc>
  801af6:	83 c4 10             	add    $0x10,%esp
  801af9:	85 c0                	test   %eax,%eax
  801afb:	0f 88 3c 03 00 00    	js     801e3d <spawn+0x4b7>
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801b01:	85 db                	test   %ebx,%ebx
  801b03:	7e 44                	jle    801b49 <spawn+0x1c3>
  801b05:	be 00 00 00 00       	mov    $0x0,%esi
  801b0a:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  801b10:	8b 5d 0c             	mov    0xc(%ebp),%ebx
		argv_store[i] = UTEMP2USTACK(string_store);
  801b13:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801b19:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  801b1f:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  801b22:	83 ec 08             	sub    $0x8,%esp
  801b25:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801b28:	57                   	push   %edi
  801b29:	e8 78 ed ff ff       	call   8008a6 <strcpy>
		string_store += strlen(argv[i]) + 1;
  801b2e:	83 c4 04             	add    $0x4,%esp
  801b31:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801b34:	e8 16 ed ff ff       	call   80084f <strlen>
  801b39:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801b3d:	46                   	inc    %esi
  801b3e:	83 c4 10             	add    $0x10,%esp
  801b41:	3b b5 90 fd ff ff    	cmp    -0x270(%ebp),%esi
  801b47:	75 ca                	jne    801b13 <spawn+0x18d>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  801b49:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801b4f:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  801b55:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801b5c:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801b62:	74 19                	je     801b7d <spawn+0x1f7>
  801b64:	68 18 2f 80 00       	push   $0x802f18
  801b69:	68 75 2e 80 00       	push   $0x802e75
  801b6e:	68 f1 00 00 00       	push   $0xf1
  801b73:	68 bb 2e 80 00       	push   $0x802ebb
  801b78:	e8 6c e6 ff ff       	call   8001e9 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801b7d:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  801b83:	89 c8                	mov    %ecx,%eax
  801b85:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801b8a:	89 41 fc             	mov    %eax,-0x4(%ecx)
	argv_store[-2] = argc;
  801b8d:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801b93:	89 41 f8             	mov    %eax,-0x8(%ecx)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801b96:	8d 81 f8 cf 7f ee    	lea    -0x11803008(%ecx),%eax
  801b9c:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801ba2:	83 ec 0c             	sub    $0xc,%esp
  801ba5:	6a 07                	push   $0x7
  801ba7:	68 00 d0 bf ee       	push   $0xeebfd000
  801bac:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801bb2:	68 00 00 40 00       	push   $0x400000
  801bb7:	6a 00                	push   $0x0
  801bb9:	e8 9b f1 ff ff       	call   800d59 <sys_page_map>
  801bbe:	89 c3                	mov    %eax,%ebx
  801bc0:	83 c4 20             	add    $0x20,%esp
  801bc3:	85 c0                	test   %eax,%eax
  801bc5:	0f 88 a1 02 00 00    	js     801e6c <spawn+0x4e6>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801bcb:	83 ec 08             	sub    $0x8,%esp
  801bce:	68 00 00 40 00       	push   $0x400000
  801bd3:	6a 00                	push   $0x0
  801bd5:	e8 c1 f1 ff ff       	call   800d9b <sys_page_unmap>
  801bda:	89 c3                	mov    %eax,%ebx
  801bdc:	83 c4 10             	add    $0x10,%esp
  801bdf:	85 c0                	test   %eax,%eax
  801be1:	0f 88 85 02 00 00    	js     801e6c <spawn+0x4e6>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801be7:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  801bed:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  801bf4:	89 85 78 fd ff ff    	mov    %eax,-0x288(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801bfa:	66 83 bd 14 fe ff ff 	cmpw   $0x0,-0x1ec(%ebp)
  801c01:	00 
  801c02:	0f 84 ab 01 00 00    	je     801db3 <spawn+0x42d>
  801c08:	c7 85 80 fd ff ff 00 	movl   $0x0,-0x280(%ebp)
  801c0f:	00 00 00 
		if (ph->p_type != ELF_PROG_LOAD)
  801c12:	8b 85 78 fd ff ff    	mov    -0x288(%ebp),%eax
  801c18:	83 38 01             	cmpl   $0x1,(%eax)
  801c1b:	0f 85 70 01 00 00    	jne    801d91 <spawn+0x40b>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801c21:	89 c1                	mov    %eax,%ecx
  801c23:	8b 40 18             	mov    0x18(%eax),%eax
  801c26:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  801c29:	83 f8 01             	cmp    $0x1,%eax
  801c2c:	19 c0                	sbb    %eax,%eax
  801c2e:	83 e0 fe             	and    $0xfffffffe,%eax
  801c31:	83 c0 07             	add    $0x7,%eax
  801c34:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801c3a:	89 c8                	mov    %ecx,%eax
  801c3c:	8b 49 04             	mov    0x4(%ecx),%ecx
  801c3f:	89 8d 7c fd ff ff    	mov    %ecx,-0x284(%ebp)
  801c45:	8b 50 10             	mov    0x10(%eax),%edx
  801c48:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)
  801c4e:	8b 78 14             	mov    0x14(%eax),%edi
  801c51:	89 bd 90 fd ff ff    	mov    %edi,-0x270(%ebp)
  801c57:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801c5a:	89 f0                	mov    %esi,%eax
  801c5c:	25 ff 0f 00 00       	and    $0xfff,%eax
  801c61:	74 1a                	je     801c7d <spawn+0x2f7>
		va -= i;
  801c63:	29 c6                	sub    %eax,%esi
		memsz += i;
  801c65:	01 c7                	add    %eax,%edi
  801c67:	89 bd 90 fd ff ff    	mov    %edi,-0x270(%ebp)
		filesz += i;
  801c6d:	01 c2                	add    %eax,%edx
  801c6f:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)
		fileoffset -= i;
  801c75:	29 c1                	sub    %eax,%ecx
  801c77:	89 8d 7c fd ff ff    	mov    %ecx,-0x284(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801c7d:	83 bd 90 fd ff ff 00 	cmpl   $0x0,-0x270(%ebp)
  801c84:	0f 84 07 01 00 00    	je     801d91 <spawn+0x40b>
  801c8a:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (i >= filesz) {
  801c8f:	39 9d 94 fd ff ff    	cmp    %ebx,-0x26c(%ebp)
  801c95:	77 27                	ja     801cbe <spawn+0x338>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801c97:	83 ec 04             	sub    $0x4,%esp
  801c9a:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801ca0:	56                   	push   %esi
  801ca1:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801ca7:	e8 6a f0 ff ff       	call   800d16 <sys_page_alloc>
  801cac:	83 c4 10             	add    $0x10,%esp
  801caf:	85 c0                	test   %eax,%eax
  801cb1:	0f 89 c2 00 00 00    	jns    801d79 <spawn+0x3f3>
  801cb7:	89 c3                	mov    %eax,%ebx
  801cb9:	e9 8d 01 00 00       	jmp    801e4b <spawn+0x4c5>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801cbe:	83 ec 04             	sub    $0x4,%esp
  801cc1:	6a 07                	push   $0x7
  801cc3:	68 00 00 40 00       	push   $0x400000
  801cc8:	6a 00                	push   $0x0
  801cca:	e8 47 f0 ff ff       	call   800d16 <sys_page_alloc>
  801ccf:	83 c4 10             	add    $0x10,%esp
  801cd2:	85 c0                	test   %eax,%eax
  801cd4:	0f 88 67 01 00 00    	js     801e41 <spawn+0x4bb>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801cda:	83 ec 08             	sub    $0x8,%esp
  801cdd:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  801ce3:	01 d8                	add    %ebx,%eax
  801ce5:	50                   	push   %eax
  801ce6:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801cec:	e8 6b f9 ff ff       	call   80165c <seek>
  801cf1:	83 c4 10             	add    $0x10,%esp
  801cf4:	85 c0                	test   %eax,%eax
  801cf6:	0f 88 49 01 00 00    	js     801e45 <spawn+0x4bf>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801cfc:	83 ec 04             	sub    $0x4,%esp
  801cff:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801d05:	29 d8                	sub    %ebx,%eax
  801d07:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801d0c:	76 05                	jbe    801d13 <spawn+0x38d>
  801d0e:	b8 00 10 00 00       	mov    $0x1000,%eax
  801d13:	50                   	push   %eax
  801d14:	68 00 00 40 00       	push   $0x400000
  801d19:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801d1f:	e8 61 f8 ff ff       	call   801585 <readn>
  801d24:	83 c4 10             	add    $0x10,%esp
  801d27:	85 c0                	test   %eax,%eax
  801d29:	0f 88 1a 01 00 00    	js     801e49 <spawn+0x4c3>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801d2f:	83 ec 0c             	sub    $0xc,%esp
  801d32:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801d38:	56                   	push   %esi
  801d39:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801d3f:	68 00 00 40 00       	push   $0x400000
  801d44:	6a 00                	push   $0x0
  801d46:	e8 0e f0 ff ff       	call   800d59 <sys_page_map>
  801d4b:	83 c4 20             	add    $0x20,%esp
  801d4e:	85 c0                	test   %eax,%eax
  801d50:	79 15                	jns    801d67 <spawn+0x3e1>
				panic("spawn: sys_page_map data: %e", r);
  801d52:	50                   	push   %eax
  801d53:	68 c7 2e 80 00       	push   $0x802ec7
  801d58:	68 24 01 00 00       	push   $0x124
  801d5d:	68 bb 2e 80 00       	push   $0x802ebb
  801d62:	e8 82 e4 ff ff       	call   8001e9 <_panic>
			sys_page_unmap(0, UTEMP);
  801d67:	83 ec 08             	sub    $0x8,%esp
  801d6a:	68 00 00 40 00       	push   $0x400000
  801d6f:	6a 00                	push   $0x0
  801d71:	e8 25 f0 ff ff       	call   800d9b <sys_page_unmap>
  801d76:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801d79:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801d7f:	81 c6 00 10 00 00    	add    $0x1000,%esi
  801d85:	3b 9d 90 fd ff ff    	cmp    -0x270(%ebp),%ebx
  801d8b:	0f 82 fe fe ff ff    	jb     801c8f <spawn+0x309>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801d91:	ff 85 80 fd ff ff    	incl   -0x280(%ebp)
  801d97:	8b 95 80 fd ff ff    	mov    -0x280(%ebp),%edx
  801d9d:	83 85 78 fd ff ff 20 	addl   $0x20,-0x288(%ebp)
  801da4:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801dab:	39 d0                	cmp    %edx,%eax
  801dad:	0f 8f 5f fe ff ff    	jg     801c12 <spawn+0x28c>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  801db3:	83 ec 0c             	sub    $0xc,%esp
  801db6:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801dbc:	e8 05 f6 ff ff       	call   8013c6 <close>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801dc1:	83 c4 08             	add    $0x8,%esp
  801dc4:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801dca:	50                   	push   %eax
  801dcb:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801dd1:	e8 49 f0 ff ff       	call   800e1f <sys_env_set_trapframe>
  801dd6:	83 c4 10             	add    $0x10,%esp
  801dd9:	85 c0                	test   %eax,%eax
  801ddb:	79 15                	jns    801df2 <spawn+0x46c>
		panic("sys_env_set_trapframe: %e", r);
  801ddd:	50                   	push   %eax
  801dde:	68 e4 2e 80 00       	push   $0x802ee4
  801de3:	68 85 00 00 00       	push   $0x85
  801de8:	68 bb 2e 80 00       	push   $0x802ebb
  801ded:	e8 f7 e3 ff ff       	call   8001e9 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801df2:	83 ec 08             	sub    $0x8,%esp
  801df5:	6a 02                	push   $0x2
  801df7:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801dfd:	e8 db ef ff ff       	call   800ddd <sys_env_set_status>
  801e02:	83 c4 10             	add    $0x10,%esp
  801e05:	85 c0                	test   %eax,%eax
  801e07:	79 25                	jns    801e2e <spawn+0x4a8>
		panic("sys_env_set_status: %e", r);
  801e09:	50                   	push   %eax
  801e0a:	68 fe 2e 80 00       	push   $0x802efe
  801e0f:	68 88 00 00 00       	push   $0x88
  801e14:	68 bb 2e 80 00       	push   $0x802ebb
  801e19:	e8 cb e3 ff ff       	call   8001e9 <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  801e1e:	8b 9d 8c fd ff ff    	mov    -0x274(%ebp),%ebx
  801e24:	eb 58                	jmp    801e7e <spawn+0x4f8>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  801e26:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801e2c:	eb 50                	jmp    801e7e <spawn+0x4f8>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  801e2e:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801e34:	eb 48                	jmp    801e7e <spawn+0x4f8>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  801e36:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
  801e3b:	eb 41                	jmp    801e7e <spawn+0x4f8>

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		return r;
  801e3d:	89 c3                	mov    %eax,%ebx
  801e3f:	eb 3d                	jmp    801e7e <spawn+0x4f8>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801e41:	89 c3                	mov    %eax,%ebx
  801e43:	eb 06                	jmp    801e4b <spawn+0x4c5>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801e45:	89 c3                	mov    %eax,%ebx
  801e47:	eb 02                	jmp    801e4b <spawn+0x4c5>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801e49:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  801e4b:	83 ec 0c             	sub    $0xc,%esp
  801e4e:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801e54:	e8 3e ee ff ff       	call   800c97 <sys_env_destroy>
	close(fd);
  801e59:	83 c4 04             	add    $0x4,%esp
  801e5c:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801e62:	e8 5f f5 ff ff       	call   8013c6 <close>
	return r;
  801e67:	83 c4 10             	add    $0x10,%esp
  801e6a:	eb 12                	jmp    801e7e <spawn+0x4f8>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  801e6c:	83 ec 08             	sub    $0x8,%esp
  801e6f:	68 00 00 40 00       	push   $0x400000
  801e74:	6a 00                	push   $0x0
  801e76:	e8 20 ef ff ff       	call   800d9b <sys_page_unmap>
  801e7b:	83 c4 10             	add    $0x10,%esp

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  801e7e:	89 d8                	mov    %ebx,%eax
  801e80:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e83:	5b                   	pop    %ebx
  801e84:	5e                   	pop    %esi
  801e85:	5f                   	pop    %edi
  801e86:	5d                   	pop    %ebp
  801e87:	c3                   	ret    

00801e88 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  801e88:	55                   	push   %ebp
  801e89:	89 e5                	mov    %esp,%ebp
  801e8b:	57                   	push   %edi
  801e8c:	56                   	push   %esi
  801e8d:	53                   	push   %ebx
  801e8e:	83 ec 1c             	sub    $0x1c,%esp
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801e91:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801e95:	74 5f                	je     801ef6 <spawnl+0x6e>
  801e97:	8d 45 14             	lea    0x14(%ebp),%eax
  801e9a:	ba 00 00 00 00       	mov    $0x0,%edx
  801e9f:	eb 02                	jmp    801ea3 <spawnl+0x1b>
		argc++;
  801ea1:	89 ca                	mov    %ecx,%edx
  801ea3:	8d 4a 01             	lea    0x1(%edx),%ecx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801ea6:	83 c0 04             	add    $0x4,%eax
  801ea9:	83 78 fc 00          	cmpl   $0x0,-0x4(%eax)
  801ead:	75 f2                	jne    801ea1 <spawnl+0x19>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801eaf:	8d 04 95 1e 00 00 00 	lea    0x1e(,%edx,4),%eax
  801eb6:	83 e0 f0             	and    $0xfffffff0,%eax
  801eb9:	29 c4                	sub    %eax,%esp
  801ebb:	8d 44 24 03          	lea    0x3(%esp),%eax
  801ebf:	c1 e8 02             	shr    $0x2,%eax
  801ec2:	8d 34 85 00 00 00 00 	lea    0x0(,%eax,4),%esi
  801ec9:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  801ecb:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801ece:	89 3c 85 00 00 00 00 	mov    %edi,0x0(,%eax,4)
	argv[argc+1] = NULL;
  801ed5:	c7 44 96 08 00 00 00 	movl   $0x0,0x8(%esi,%edx,4)
  801edc:	00 

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801edd:	89 ce                	mov    %ecx,%esi
  801edf:	85 c9                	test   %ecx,%ecx
  801ee1:	74 23                	je     801f06 <spawnl+0x7e>
  801ee3:	b8 00 00 00 00       	mov    $0x0,%eax
		argv[i+1] = va_arg(vl, const char *);
  801ee8:	40                   	inc    %eax
  801ee9:	8b 54 85 0c          	mov    0xc(%ebp,%eax,4),%edx
  801eed:	89 14 83             	mov    %edx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801ef0:	39 f0                	cmp    %esi,%eax
  801ef2:	75 f4                	jne    801ee8 <spawnl+0x60>
  801ef4:	eb 10                	jmp    801f06 <spawnl+0x7e>
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
	argv[0] = arg0;
  801ef6:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ef9:	89 45 e0             	mov    %eax,-0x20(%ebp)
	argv[argc+1] = NULL;
  801efc:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801f03:	8d 5d e0             	lea    -0x20(%ebp),%ebx
	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  801f06:	83 ec 08             	sub    $0x8,%esp
  801f09:	53                   	push   %ebx
  801f0a:	ff 75 08             	pushl  0x8(%ebp)
  801f0d:	e8 74 fa ff ff       	call   801986 <spawn>
}
  801f12:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f15:	5b                   	pop    %ebx
  801f16:	5e                   	pop    %esi
  801f17:	5f                   	pop    %edi
  801f18:	5d                   	pop    %ebp
  801f19:	c3                   	ret    

00801f1a <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801f1a:	55                   	push   %ebp
  801f1b:	89 e5                	mov    %esp,%ebp
  801f1d:	56                   	push   %esi
  801f1e:	53                   	push   %ebx
  801f1f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801f22:	83 ec 0c             	sub    $0xc,%esp
  801f25:	ff 75 08             	pushl  0x8(%ebp)
  801f28:	e8 c5 f2 ff ff       	call   8011f2 <fd2data>
  801f2d:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801f2f:	83 c4 08             	add    $0x8,%esp
  801f32:	68 40 2f 80 00       	push   $0x802f40
  801f37:	53                   	push   %ebx
  801f38:	e8 69 e9 ff ff       	call   8008a6 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801f3d:	8b 46 04             	mov    0x4(%esi),%eax
  801f40:	2b 06                	sub    (%esi),%eax
  801f42:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801f48:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801f4f:	00 00 00 
	stat->st_dev = &devpipe;
  801f52:	c7 83 88 00 00 00 28 	movl   $0x803028,0x88(%ebx)
  801f59:	30 80 00 
	return 0;
}
  801f5c:	b8 00 00 00 00       	mov    $0x0,%eax
  801f61:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f64:	5b                   	pop    %ebx
  801f65:	5e                   	pop    %esi
  801f66:	5d                   	pop    %ebp
  801f67:	c3                   	ret    

00801f68 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801f68:	55                   	push   %ebp
  801f69:	89 e5                	mov    %esp,%ebp
  801f6b:	53                   	push   %ebx
  801f6c:	83 ec 0c             	sub    $0xc,%esp
  801f6f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801f72:	53                   	push   %ebx
  801f73:	6a 00                	push   $0x0
  801f75:	e8 21 ee ff ff       	call   800d9b <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801f7a:	89 1c 24             	mov    %ebx,(%esp)
  801f7d:	e8 70 f2 ff ff       	call   8011f2 <fd2data>
  801f82:	83 c4 08             	add    $0x8,%esp
  801f85:	50                   	push   %eax
  801f86:	6a 00                	push   $0x0
  801f88:	e8 0e ee ff ff       	call   800d9b <sys_page_unmap>
}
  801f8d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f90:	c9                   	leave  
  801f91:	c3                   	ret    

00801f92 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801f92:	55                   	push   %ebp
  801f93:	89 e5                	mov    %esp,%ebp
  801f95:	57                   	push   %edi
  801f96:	56                   	push   %esi
  801f97:	53                   	push   %ebx
  801f98:	83 ec 1c             	sub    $0x1c,%esp
  801f9b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801f9e:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801fa0:	a1 04 40 80 00       	mov    0x804004,%eax
  801fa5:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801fa8:	83 ec 0c             	sub    $0xc,%esp
  801fab:	ff 75 e0             	pushl  -0x20(%ebp)
  801fae:	e8 a4 06 00 00       	call   802657 <pageref>
  801fb3:	89 c3                	mov    %eax,%ebx
  801fb5:	89 3c 24             	mov    %edi,(%esp)
  801fb8:	e8 9a 06 00 00       	call   802657 <pageref>
  801fbd:	83 c4 10             	add    $0x10,%esp
  801fc0:	39 c3                	cmp    %eax,%ebx
  801fc2:	0f 94 c1             	sete   %cl
  801fc5:	0f b6 c9             	movzbl %cl,%ecx
  801fc8:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801fcb:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801fd1:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801fd4:	39 ce                	cmp    %ecx,%esi
  801fd6:	74 1b                	je     801ff3 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801fd8:	39 c3                	cmp    %eax,%ebx
  801fda:	75 c4                	jne    801fa0 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801fdc:	8b 42 58             	mov    0x58(%edx),%eax
  801fdf:	ff 75 e4             	pushl  -0x1c(%ebp)
  801fe2:	50                   	push   %eax
  801fe3:	56                   	push   %esi
  801fe4:	68 47 2f 80 00       	push   $0x802f47
  801fe9:	e8 d3 e2 ff ff       	call   8002c1 <cprintf>
  801fee:	83 c4 10             	add    $0x10,%esp
  801ff1:	eb ad                	jmp    801fa0 <_pipeisclosed+0xe>
	}
}
  801ff3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ff6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ff9:	5b                   	pop    %ebx
  801ffa:	5e                   	pop    %esi
  801ffb:	5f                   	pop    %edi
  801ffc:	5d                   	pop    %ebp
  801ffd:	c3                   	ret    

00801ffe <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ffe:	55                   	push   %ebp
  801fff:	89 e5                	mov    %esp,%ebp
  802001:	57                   	push   %edi
  802002:	56                   	push   %esi
  802003:	53                   	push   %ebx
  802004:	83 ec 18             	sub    $0x18,%esp
  802007:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80200a:	56                   	push   %esi
  80200b:	e8 e2 f1 ff ff       	call   8011f2 <fd2data>
  802010:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802012:	83 c4 10             	add    $0x10,%esp
  802015:	bf 00 00 00 00       	mov    $0x0,%edi
  80201a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80201e:	75 42                	jne    802062 <devpipe_write+0x64>
  802020:	eb 4e                	jmp    802070 <devpipe_write+0x72>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  802022:	89 da                	mov    %ebx,%edx
  802024:	89 f0                	mov    %esi,%eax
  802026:	e8 67 ff ff ff       	call   801f92 <_pipeisclosed>
  80202b:	85 c0                	test   %eax,%eax
  80202d:	75 46                	jne    802075 <devpipe_write+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80202f:	e8 c3 ec ff ff       	call   800cf7 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802034:	8b 53 04             	mov    0x4(%ebx),%edx
  802037:	8b 03                	mov    (%ebx),%eax
  802039:	83 c0 20             	add    $0x20,%eax
  80203c:	39 c2                	cmp    %eax,%edx
  80203e:	73 e2                	jae    802022 <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802040:	8b 45 0c             	mov    0xc(%ebp),%eax
  802043:	8a 0c 38             	mov    (%eax,%edi,1),%cl
  802046:	89 d0                	mov    %edx,%eax
  802048:	25 1f 00 00 80       	and    $0x8000001f,%eax
  80204d:	79 05                	jns    802054 <devpipe_write+0x56>
  80204f:	48                   	dec    %eax
  802050:	83 c8 e0             	or     $0xffffffe0,%eax
  802053:	40                   	inc    %eax
  802054:	88 4c 03 08          	mov    %cl,0x8(%ebx,%eax,1)
		p->p_wpos++;
  802058:	42                   	inc    %edx
  802059:	89 53 04             	mov    %edx,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80205c:	47                   	inc    %edi
  80205d:	39 7d 10             	cmp    %edi,0x10(%ebp)
  802060:	74 0e                	je     802070 <devpipe_write+0x72>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802062:	8b 53 04             	mov    0x4(%ebx),%edx
  802065:	8b 03                	mov    (%ebx),%eax
  802067:	83 c0 20             	add    $0x20,%eax
  80206a:	39 c2                	cmp    %eax,%edx
  80206c:	73 b4                	jae    802022 <devpipe_write+0x24>
  80206e:	eb d0                	jmp    802040 <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802070:	8b 45 10             	mov    0x10(%ebp),%eax
  802073:	eb 05                	jmp    80207a <devpipe_write+0x7c>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802075:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80207a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80207d:	5b                   	pop    %ebx
  80207e:	5e                   	pop    %esi
  80207f:	5f                   	pop    %edi
  802080:	5d                   	pop    %ebp
  802081:	c3                   	ret    

00802082 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802082:	55                   	push   %ebp
  802083:	89 e5                	mov    %esp,%ebp
  802085:	57                   	push   %edi
  802086:	56                   	push   %esi
  802087:	53                   	push   %ebx
  802088:	83 ec 18             	sub    $0x18,%esp
  80208b:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80208e:	57                   	push   %edi
  80208f:	e8 5e f1 ff ff       	call   8011f2 <fd2data>
  802094:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802096:	83 c4 10             	add    $0x10,%esp
  802099:	be 00 00 00 00       	mov    $0x0,%esi
  80209e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8020a2:	75 3d                	jne    8020e1 <devpipe_read+0x5f>
  8020a4:	eb 48                	jmp    8020ee <devpipe_read+0x6c>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  8020a6:	89 f0                	mov    %esi,%eax
  8020a8:	eb 4e                	jmp    8020f8 <devpipe_read+0x76>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8020aa:	89 da                	mov    %ebx,%edx
  8020ac:	89 f8                	mov    %edi,%eax
  8020ae:	e8 df fe ff ff       	call   801f92 <_pipeisclosed>
  8020b3:	85 c0                	test   %eax,%eax
  8020b5:	75 3c                	jne    8020f3 <devpipe_read+0x71>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8020b7:	e8 3b ec ff ff       	call   800cf7 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8020bc:	8b 03                	mov    (%ebx),%eax
  8020be:	3b 43 04             	cmp    0x4(%ebx),%eax
  8020c1:	74 e7                	je     8020aa <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8020c3:	25 1f 00 00 80       	and    $0x8000001f,%eax
  8020c8:	79 05                	jns    8020cf <devpipe_read+0x4d>
  8020ca:	48                   	dec    %eax
  8020cb:	83 c8 e0             	or     $0xffffffe0,%eax
  8020ce:	40                   	inc    %eax
  8020cf:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  8020d3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8020d6:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  8020d9:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8020db:	46                   	inc    %esi
  8020dc:	39 75 10             	cmp    %esi,0x10(%ebp)
  8020df:	74 0d                	je     8020ee <devpipe_read+0x6c>
		while (p->p_rpos == p->p_wpos) {
  8020e1:	8b 03                	mov    (%ebx),%eax
  8020e3:	3b 43 04             	cmp    0x4(%ebx),%eax
  8020e6:	75 db                	jne    8020c3 <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8020e8:	85 f6                	test   %esi,%esi
  8020ea:	75 ba                	jne    8020a6 <devpipe_read+0x24>
  8020ec:	eb bc                	jmp    8020aa <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8020ee:	8b 45 10             	mov    0x10(%ebp),%eax
  8020f1:	eb 05                	jmp    8020f8 <devpipe_read+0x76>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8020f3:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8020f8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020fb:	5b                   	pop    %ebx
  8020fc:	5e                   	pop    %esi
  8020fd:	5f                   	pop    %edi
  8020fe:	5d                   	pop    %ebp
  8020ff:	c3                   	ret    

00802100 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802100:	55                   	push   %ebp
  802101:	89 e5                	mov    %esp,%ebp
  802103:	56                   	push   %esi
  802104:	53                   	push   %ebx
  802105:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802108:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80210b:	50                   	push   %eax
  80210c:	e8 f8 f0 ff ff       	call   801209 <fd_alloc>
  802111:	83 c4 10             	add    $0x10,%esp
  802114:	85 c0                	test   %eax,%eax
  802116:	0f 88 2a 01 00 00    	js     802246 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80211c:	83 ec 04             	sub    $0x4,%esp
  80211f:	68 07 04 00 00       	push   $0x407
  802124:	ff 75 f4             	pushl  -0xc(%ebp)
  802127:	6a 00                	push   $0x0
  802129:	e8 e8 eb ff ff       	call   800d16 <sys_page_alloc>
  80212e:	83 c4 10             	add    $0x10,%esp
  802131:	85 c0                	test   %eax,%eax
  802133:	0f 88 0d 01 00 00    	js     802246 <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802139:	83 ec 0c             	sub    $0xc,%esp
  80213c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80213f:	50                   	push   %eax
  802140:	e8 c4 f0 ff ff       	call   801209 <fd_alloc>
  802145:	89 c3                	mov    %eax,%ebx
  802147:	83 c4 10             	add    $0x10,%esp
  80214a:	85 c0                	test   %eax,%eax
  80214c:	0f 88 e2 00 00 00    	js     802234 <pipe+0x134>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802152:	83 ec 04             	sub    $0x4,%esp
  802155:	68 07 04 00 00       	push   $0x407
  80215a:	ff 75 f0             	pushl  -0x10(%ebp)
  80215d:	6a 00                	push   $0x0
  80215f:	e8 b2 eb ff ff       	call   800d16 <sys_page_alloc>
  802164:	89 c3                	mov    %eax,%ebx
  802166:	83 c4 10             	add    $0x10,%esp
  802169:	85 c0                	test   %eax,%eax
  80216b:	0f 88 c3 00 00 00    	js     802234 <pipe+0x134>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802171:	83 ec 0c             	sub    $0xc,%esp
  802174:	ff 75 f4             	pushl  -0xc(%ebp)
  802177:	e8 76 f0 ff ff       	call   8011f2 <fd2data>
  80217c:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80217e:	83 c4 0c             	add    $0xc,%esp
  802181:	68 07 04 00 00       	push   $0x407
  802186:	50                   	push   %eax
  802187:	6a 00                	push   $0x0
  802189:	e8 88 eb ff ff       	call   800d16 <sys_page_alloc>
  80218e:	89 c3                	mov    %eax,%ebx
  802190:	83 c4 10             	add    $0x10,%esp
  802193:	85 c0                	test   %eax,%eax
  802195:	0f 88 89 00 00 00    	js     802224 <pipe+0x124>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80219b:	83 ec 0c             	sub    $0xc,%esp
  80219e:	ff 75 f0             	pushl  -0x10(%ebp)
  8021a1:	e8 4c f0 ff ff       	call   8011f2 <fd2data>
  8021a6:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8021ad:	50                   	push   %eax
  8021ae:	6a 00                	push   $0x0
  8021b0:	56                   	push   %esi
  8021b1:	6a 00                	push   $0x0
  8021b3:	e8 a1 eb ff ff       	call   800d59 <sys_page_map>
  8021b8:	89 c3                	mov    %eax,%ebx
  8021ba:	83 c4 20             	add    $0x20,%esp
  8021bd:	85 c0                	test   %eax,%eax
  8021bf:	78 55                	js     802216 <pipe+0x116>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8021c1:	8b 15 28 30 80 00    	mov    0x803028,%edx
  8021c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021ca:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8021cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021cf:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8021d6:	8b 15 28 30 80 00    	mov    0x803028,%edx
  8021dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8021df:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8021e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8021e4:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8021eb:	83 ec 0c             	sub    $0xc,%esp
  8021ee:	ff 75 f4             	pushl  -0xc(%ebp)
  8021f1:	e8 ec ef ff ff       	call   8011e2 <fd2num>
  8021f6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8021f9:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8021fb:	83 c4 04             	add    $0x4,%esp
  8021fe:	ff 75 f0             	pushl  -0x10(%ebp)
  802201:	e8 dc ef ff ff       	call   8011e2 <fd2num>
  802206:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802209:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  80220c:	83 c4 10             	add    $0x10,%esp
  80220f:	b8 00 00 00 00       	mov    $0x0,%eax
  802214:	eb 30                	jmp    802246 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  802216:	83 ec 08             	sub    $0x8,%esp
  802219:	56                   	push   %esi
  80221a:	6a 00                	push   $0x0
  80221c:	e8 7a eb ff ff       	call   800d9b <sys_page_unmap>
  802221:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  802224:	83 ec 08             	sub    $0x8,%esp
  802227:	ff 75 f0             	pushl  -0x10(%ebp)
  80222a:	6a 00                	push   $0x0
  80222c:	e8 6a eb ff ff       	call   800d9b <sys_page_unmap>
  802231:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  802234:	83 ec 08             	sub    $0x8,%esp
  802237:	ff 75 f4             	pushl  -0xc(%ebp)
  80223a:	6a 00                	push   $0x0
  80223c:	e8 5a eb ff ff       	call   800d9b <sys_page_unmap>
  802241:	83 c4 10             	add    $0x10,%esp
  802244:	89 d8                	mov    %ebx,%eax
    err:
	return r;
}
  802246:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802249:	5b                   	pop    %ebx
  80224a:	5e                   	pop    %esi
  80224b:	5d                   	pop    %ebp
  80224c:	c3                   	ret    

0080224d <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80224d:	55                   	push   %ebp
  80224e:	89 e5                	mov    %esp,%ebp
  802250:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802253:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802256:	50                   	push   %eax
  802257:	ff 75 08             	pushl  0x8(%ebp)
  80225a:	e8 1e f0 ff ff       	call   80127d <fd_lookup>
  80225f:	83 c4 10             	add    $0x10,%esp
  802262:	85 c0                	test   %eax,%eax
  802264:	78 18                	js     80227e <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802266:	83 ec 0c             	sub    $0xc,%esp
  802269:	ff 75 f4             	pushl  -0xc(%ebp)
  80226c:	e8 81 ef ff ff       	call   8011f2 <fd2data>
	return _pipeisclosed(fd, p);
  802271:	89 c2                	mov    %eax,%edx
  802273:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802276:	e8 17 fd ff ff       	call   801f92 <_pipeisclosed>
  80227b:	83 c4 10             	add    $0x10,%esp
}
  80227e:	c9                   	leave  
  80227f:	c3                   	ret    

00802280 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  802280:	55                   	push   %ebp
  802281:	89 e5                	mov    %esp,%ebp
  802283:	56                   	push   %esi
  802284:	53                   	push   %ebx
  802285:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  802288:	85 f6                	test   %esi,%esi
  80228a:	75 16                	jne    8022a2 <wait+0x22>
  80228c:	68 5f 2f 80 00       	push   $0x802f5f
  802291:	68 75 2e 80 00       	push   $0x802e75
  802296:	6a 09                	push   $0x9
  802298:	68 6a 2f 80 00       	push   $0x802f6a
  80229d:	e8 47 df ff ff       	call   8001e9 <_panic>
	e = &envs[ENVX(envid)];
  8022a2:	89 f3                	mov    %esi,%ebx
  8022a4:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  8022aa:	8d 14 9d 00 00 00 00 	lea    0x0(,%ebx,4),%edx
  8022b1:	89 d8                	mov    %ebx,%eax
  8022b3:	c1 e0 07             	shl    $0x7,%eax
  8022b6:	29 d0                	sub    %edx,%eax
  8022b8:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8022bd:	8b 40 48             	mov    0x48(%eax),%eax
  8022c0:	39 c6                	cmp    %eax,%esi
  8022c2:	75 31                	jne    8022f5 <wait+0x75>
  8022c4:	89 d8                	mov    %ebx,%eax
  8022c6:	c1 e0 07             	shl    $0x7,%eax
  8022c9:	29 d0                	sub    %edx,%eax
  8022cb:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8022d0:	8b 40 54             	mov    0x54(%eax),%eax
  8022d3:	85 c0                	test   %eax,%eax
  8022d5:	74 1e                	je     8022f5 <wait+0x75>
  8022d7:	c1 e3 07             	shl    $0x7,%ebx
  8022da:	29 d3                	sub    %edx,%ebx
  8022dc:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
		sys_yield();
  8022e2:	e8 10 ea ff ff       	call   800cf7 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  8022e7:	8b 43 48             	mov    0x48(%ebx),%eax
  8022ea:	39 c6                	cmp    %eax,%esi
  8022ec:	75 07                	jne    8022f5 <wait+0x75>
  8022ee:	8b 43 54             	mov    0x54(%ebx),%eax
  8022f1:	85 c0                	test   %eax,%eax
  8022f3:	75 ed                	jne    8022e2 <wait+0x62>
		sys_yield();
}
  8022f5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8022f8:	5b                   	pop    %ebx
  8022f9:	5e                   	pop    %esi
  8022fa:	5d                   	pop    %ebp
  8022fb:	c3                   	ret    

008022fc <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8022fc:	55                   	push   %ebp
  8022fd:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8022ff:	b8 00 00 00 00       	mov    $0x0,%eax
  802304:	5d                   	pop    %ebp
  802305:	c3                   	ret    

00802306 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802306:	55                   	push   %ebp
  802307:	89 e5                	mov    %esp,%ebp
  802309:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80230c:	68 75 2f 80 00       	push   $0x802f75
  802311:	ff 75 0c             	pushl  0xc(%ebp)
  802314:	e8 8d e5 ff ff       	call   8008a6 <strcpy>
	return 0;
}
  802319:	b8 00 00 00 00       	mov    $0x0,%eax
  80231e:	c9                   	leave  
  80231f:	c3                   	ret    

00802320 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802320:	55                   	push   %ebp
  802321:	89 e5                	mov    %esp,%ebp
  802323:	57                   	push   %edi
  802324:	56                   	push   %esi
  802325:	53                   	push   %ebx
  802326:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80232c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802330:	74 45                	je     802377 <devcons_write+0x57>
  802332:	b8 00 00 00 00       	mov    $0x0,%eax
  802337:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80233c:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  802342:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802345:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  802347:	83 fb 7f             	cmp    $0x7f,%ebx
  80234a:	76 05                	jbe    802351 <devcons_write+0x31>
			m = sizeof(buf) - 1;
  80234c:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  802351:	83 ec 04             	sub    $0x4,%esp
  802354:	53                   	push   %ebx
  802355:	03 45 0c             	add    0xc(%ebp),%eax
  802358:	50                   	push   %eax
  802359:	57                   	push   %edi
  80235a:	e8 14 e7 ff ff       	call   800a73 <memmove>
		sys_cputs(buf, m);
  80235f:	83 c4 08             	add    $0x8,%esp
  802362:	53                   	push   %ebx
  802363:	57                   	push   %edi
  802364:	e8 f1 e8 ff ff       	call   800c5a <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802369:	01 de                	add    %ebx,%esi
  80236b:	89 f0                	mov    %esi,%eax
  80236d:	83 c4 10             	add    $0x10,%esp
  802370:	3b 75 10             	cmp    0x10(%ebp),%esi
  802373:	72 cd                	jb     802342 <devcons_write+0x22>
  802375:	eb 05                	jmp    80237c <devcons_write+0x5c>
  802377:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80237c:	89 f0                	mov    %esi,%eax
  80237e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802381:	5b                   	pop    %ebx
  802382:	5e                   	pop    %esi
  802383:	5f                   	pop    %edi
  802384:	5d                   	pop    %ebp
  802385:	c3                   	ret    

00802386 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802386:	55                   	push   %ebp
  802387:	89 e5                	mov    %esp,%ebp
  802389:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  80238c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802390:	75 07                	jne    802399 <devcons_read+0x13>
  802392:	eb 23                	jmp    8023b7 <devcons_read+0x31>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802394:	e8 5e e9 ff ff       	call   800cf7 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802399:	e8 da e8 ff ff       	call   800c78 <sys_cgetc>
  80239e:	85 c0                	test   %eax,%eax
  8023a0:	74 f2                	je     802394 <devcons_read+0xe>
		sys_yield();
	if (c < 0)
  8023a2:	85 c0                	test   %eax,%eax
  8023a4:	78 1d                	js     8023c3 <devcons_read+0x3d>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8023a6:	83 f8 04             	cmp    $0x4,%eax
  8023a9:	74 13                	je     8023be <devcons_read+0x38>
		return 0;
	*(char*)vbuf = c;
  8023ab:	8b 55 0c             	mov    0xc(%ebp),%edx
  8023ae:	88 02                	mov    %al,(%edx)
	return 1;
  8023b0:	b8 01 00 00 00       	mov    $0x1,%eax
  8023b5:	eb 0c                	jmp    8023c3 <devcons_read+0x3d>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  8023b7:	b8 00 00 00 00       	mov    $0x0,%eax
  8023bc:	eb 05                	jmp    8023c3 <devcons_read+0x3d>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8023be:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8023c3:	c9                   	leave  
  8023c4:	c3                   	ret    

008023c5 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8023c5:	55                   	push   %ebp
  8023c6:	89 e5                	mov    %esp,%ebp
  8023c8:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8023cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8023ce:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8023d1:	6a 01                	push   $0x1
  8023d3:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8023d6:	50                   	push   %eax
  8023d7:	e8 7e e8 ff ff       	call   800c5a <sys_cputs>
}
  8023dc:	83 c4 10             	add    $0x10,%esp
  8023df:	c9                   	leave  
  8023e0:	c3                   	ret    

008023e1 <getchar>:

int
getchar(void)
{
  8023e1:	55                   	push   %ebp
  8023e2:	89 e5                	mov    %esp,%ebp
  8023e4:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8023e7:	6a 01                	push   $0x1
  8023e9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8023ec:	50                   	push   %eax
  8023ed:	6a 00                	push   $0x0
  8023ef:	e8 0a f1 ff ff       	call   8014fe <read>
	if (r < 0)
  8023f4:	83 c4 10             	add    $0x10,%esp
  8023f7:	85 c0                	test   %eax,%eax
  8023f9:	78 0f                	js     80240a <getchar+0x29>
		return r;
	if (r < 1)
  8023fb:	85 c0                	test   %eax,%eax
  8023fd:	7e 06                	jle    802405 <getchar+0x24>
		return -E_EOF;
	return c;
  8023ff:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802403:	eb 05                	jmp    80240a <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802405:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80240a:	c9                   	leave  
  80240b:	c3                   	ret    

0080240c <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80240c:	55                   	push   %ebp
  80240d:	89 e5                	mov    %esp,%ebp
  80240f:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802412:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802415:	50                   	push   %eax
  802416:	ff 75 08             	pushl  0x8(%ebp)
  802419:	e8 5f ee ff ff       	call   80127d <fd_lookup>
  80241e:	83 c4 10             	add    $0x10,%esp
  802421:	85 c0                	test   %eax,%eax
  802423:	78 11                	js     802436 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802425:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802428:	8b 15 44 30 80 00    	mov    0x803044,%edx
  80242e:	39 10                	cmp    %edx,(%eax)
  802430:	0f 94 c0             	sete   %al
  802433:	0f b6 c0             	movzbl %al,%eax
}
  802436:	c9                   	leave  
  802437:	c3                   	ret    

00802438 <opencons>:

int
opencons(void)
{
  802438:	55                   	push   %ebp
  802439:	89 e5                	mov    %esp,%ebp
  80243b:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80243e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802441:	50                   	push   %eax
  802442:	e8 c2 ed ff ff       	call   801209 <fd_alloc>
  802447:	83 c4 10             	add    $0x10,%esp
  80244a:	85 c0                	test   %eax,%eax
  80244c:	78 3a                	js     802488 <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80244e:	83 ec 04             	sub    $0x4,%esp
  802451:	68 07 04 00 00       	push   $0x407
  802456:	ff 75 f4             	pushl  -0xc(%ebp)
  802459:	6a 00                	push   $0x0
  80245b:	e8 b6 e8 ff ff       	call   800d16 <sys_page_alloc>
  802460:	83 c4 10             	add    $0x10,%esp
  802463:	85 c0                	test   %eax,%eax
  802465:	78 21                	js     802488 <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802467:	8b 15 44 30 80 00    	mov    0x803044,%edx
  80246d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802470:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802472:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802475:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80247c:	83 ec 0c             	sub    $0xc,%esp
  80247f:	50                   	push   %eax
  802480:	e8 5d ed ff ff       	call   8011e2 <fd2num>
  802485:	83 c4 10             	add    $0x10,%esp
}
  802488:	c9                   	leave  
  802489:	c3                   	ret    

0080248a <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80248a:	55                   	push   %ebp
  80248b:	89 e5                	mov    %esp,%ebp
  80248d:	53                   	push   %ebx
  80248e:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (_pgfault_handler == 0) {
  802491:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  802498:	75 5b                	jne    8024f5 <set_pgfault_handler+0x6b>
		// First time through!
		// LAB 4: Your code here.
		void *va = (void *)(UXSTACKTOP - PGSIZE);
		envid_t eid = sys_getenvid();
  80249a:	e8 39 e8 ff ff       	call   800cd8 <sys_getenvid>
  80249f:	89 c3                	mov    %eax,%ebx
		r = sys_page_alloc(eid,va,PTE_P | PTE_U | PTE_W);
  8024a1:	83 ec 04             	sub    $0x4,%esp
  8024a4:	6a 07                	push   $0x7
  8024a6:	68 00 f0 bf ee       	push   $0xeebff000
  8024ab:	50                   	push   %eax
  8024ac:	e8 65 e8 ff ff       	call   800d16 <sys_page_alloc>
		if(r<0) panic("set_pgfault_handler\n");
  8024b1:	83 c4 10             	add    $0x10,%esp
  8024b4:	85 c0                	test   %eax,%eax
  8024b6:	79 14                	jns    8024cc <set_pgfault_handler+0x42>
  8024b8:	83 ec 04             	sub    $0x4,%esp
  8024bb:	68 81 2f 80 00       	push   $0x802f81
  8024c0:	6a 23                	push   $0x23
  8024c2:	68 96 2f 80 00       	push   $0x802f96
  8024c7:	e8 1d dd ff ff       	call   8001e9 <_panic>
		r = sys_env_set_pgfault_upcall(eid,_pgfault_upcall);
  8024cc:	83 ec 08             	sub    $0x8,%esp
  8024cf:	68 02 25 80 00       	push   $0x802502
  8024d4:	53                   	push   %ebx
  8024d5:	e8 87 e9 ff ff       	call   800e61 <sys_env_set_pgfault_upcall>
		if(r<0) panic("set_pgfault_handler\n");
  8024da:	83 c4 10             	add    $0x10,%esp
  8024dd:	85 c0                	test   %eax,%eax
  8024df:	79 14                	jns    8024f5 <set_pgfault_handler+0x6b>
  8024e1:	83 ec 04             	sub    $0x4,%esp
  8024e4:	68 81 2f 80 00       	push   $0x802f81
  8024e9:	6a 25                	push   $0x25
  8024eb:	68 96 2f 80 00       	push   $0x802f96
  8024f0:	e8 f4 dc ff ff       	call   8001e9 <_panic>
		// panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8024f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8024f8:	a3 00 60 80 00       	mov    %eax,0x806000
}
  8024fd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802500:	c9                   	leave  
  802501:	c3                   	ret    

00802502 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802502:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802503:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  802508:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80250a:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl %esp,%ebx
  80250d:	89 e3                	mov    %esp,%ebx
	movl 40(%esp),%eax 	// esp from utf_fault_va to utf_regs(end)
  80250f:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl 48(%esp),%esp 	// 
  802513:	8b 64 24 30          	mov    0x30(%esp),%esp
	pushl %eax
  802517:	50                   	push   %eax
 
 
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	movl %ebx,%esp
  802518:	89 dc                	mov    %ebx,%esp
	subl $4,48(%esp)
  80251a:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	popl %eax
  80251f:	58                   	pop    %eax
	popl %eax
  802520:	58                   	pop    %eax
	popal
  802521:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	add $4,%esp
  802522:	83 c4 04             	add    $0x4,%esp
	popfl
  802525:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  802526:	5c                   	pop    %esp
 
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  802527:	c3                   	ret    

00802528 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802528:	55                   	push   %ebp
  802529:	89 e5                	mov    %esp,%ebp
  80252b:	56                   	push   %esi
  80252c:	53                   	push   %ebx
  80252d:	8b 75 08             	mov    0x8(%ebp),%esi
  802530:	8b 45 0c             	mov    0xc(%ebp),%eax
  802533:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");
	int r;
    if (pg != NULL) {
  802536:	85 c0                	test   %eax,%eax
  802538:	74 0e                	je     802548 <ipc_recv+0x20>
        r = sys_ipc_recv(pg);
  80253a:	83 ec 0c             	sub    $0xc,%esp
  80253d:	50                   	push   %eax
  80253e:	e8 83 e9 ff ff       	call   800ec6 <sys_ipc_recv>
  802543:	83 c4 10             	add    $0x10,%esp
  802546:	eb 10                	jmp    802558 <ipc_recv+0x30>
    } else {
        r = sys_ipc_recv((void *) UTOP);
  802548:	83 ec 0c             	sub    $0xc,%esp
  80254b:	68 00 00 c0 ee       	push   $0xeec00000
  802550:	e8 71 e9 ff ff       	call   800ec6 <sys_ipc_recv>
  802555:	83 c4 10             	add    $0x10,%esp
    }
    if (r < 0) {
  802558:	85 c0                	test   %eax,%eax
  80255a:	79 16                	jns    802572 <ipc_recv+0x4a>
        // failed
        if (from_env_store != NULL) *from_env_store = 0;
  80255c:	85 f6                	test   %esi,%esi
  80255e:	74 06                	je     802566 <ipc_recv+0x3e>
  802560:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        if (perm_store != NULL) *perm_store = 0;
  802566:	85 db                	test   %ebx,%ebx
  802568:	74 2c                	je     802596 <ipc_recv+0x6e>
  80256a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  802570:	eb 24                	jmp    802596 <ipc_recv+0x6e>
        return r;
    } else {
        if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  802572:	85 f6                	test   %esi,%esi
  802574:	74 0a                	je     802580 <ipc_recv+0x58>
  802576:	a1 04 40 80 00       	mov    0x804004,%eax
  80257b:	8b 40 74             	mov    0x74(%eax),%eax
  80257e:	89 06                	mov    %eax,(%esi)
        if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  802580:	85 db                	test   %ebx,%ebx
  802582:	74 0a                	je     80258e <ipc_recv+0x66>
  802584:	a1 04 40 80 00       	mov    0x804004,%eax
  802589:	8b 40 78             	mov    0x78(%eax),%eax
  80258c:	89 03                	mov    %eax,(%ebx)
        return thisenv->env_ipc_value;
  80258e:	a1 04 40 80 00       	mov    0x804004,%eax
  802593:	8b 40 70             	mov    0x70(%eax),%eax
    }
 
	return 0;
}
  802596:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802599:	5b                   	pop    %ebx
  80259a:	5e                   	pop    %esi
  80259b:	5d                   	pop    %ebp
  80259c:	c3                   	ret    

0080259d <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80259d:	55                   	push   %ebp
  80259e:	89 e5                	mov    %esp,%ebp
  8025a0:	57                   	push   %edi
  8025a1:	56                   	push   %esi
  8025a2:	53                   	push   %ebx
  8025a3:	83 ec 0c             	sub    $0xc,%esp
  8025a6:	8b 75 10             	mov    0x10(%ebp),%esi
  8025a9:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");
	int r;
    if (pg == NULL) pg = (void *)UTOP;
  8025ac:	85 f6                	test   %esi,%esi
  8025ae:	75 05                	jne    8025b5 <ipc_send+0x18>
  8025b0:	be 00 00 c0 ee       	mov    $0xeec00000,%esi
    do {
        r = sys_ipc_try_send(to_env, val, pg, perm);
  8025b5:	57                   	push   %edi
  8025b6:	56                   	push   %esi
  8025b7:	ff 75 0c             	pushl  0xc(%ebp)
  8025ba:	ff 75 08             	pushl  0x8(%ebp)
  8025bd:	e8 e1 e8 ff ff       	call   800ea3 <sys_ipc_try_send>
  8025c2:	89 c3                	mov    %eax,%ebx
        if (r < 0 && r != -E_IPC_NOT_RECV) panic("ipc send failed: %e", r);
  8025c4:	83 c4 10             	add    $0x10,%esp
  8025c7:	85 c0                	test   %eax,%eax
  8025c9:	79 17                	jns    8025e2 <ipc_send+0x45>
  8025cb:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8025ce:	74 1d                	je     8025ed <ipc_send+0x50>
  8025d0:	50                   	push   %eax
  8025d1:	68 a4 2f 80 00       	push   $0x802fa4
  8025d6:	6a 40                	push   $0x40
  8025d8:	68 b8 2f 80 00       	push   $0x802fb8
  8025dd:	e8 07 dc ff ff       	call   8001e9 <_panic>
        sys_yield();
  8025e2:	e8 10 e7 ff ff       	call   800cf7 <sys_yield>
    } while (r != 0);
  8025e7:	85 db                	test   %ebx,%ebx
  8025e9:	75 ca                	jne    8025b5 <ipc_send+0x18>
  8025eb:	eb 07                	jmp    8025f4 <ipc_send+0x57>
	int r;
    if (pg == NULL) pg = (void *)UTOP;
    do {
        r = sys_ipc_try_send(to_env, val, pg, perm);
        if (r < 0 && r != -E_IPC_NOT_RECV) panic("ipc send failed: %e", r);
        sys_yield();
  8025ed:	e8 05 e7 ff ff       	call   800cf7 <sys_yield>
  8025f2:	eb c1                	jmp    8025b5 <ipc_send+0x18>
    } while (r != 0);
}
  8025f4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8025f7:	5b                   	pop    %ebx
  8025f8:	5e                   	pop    %esi
  8025f9:	5f                   	pop    %edi
  8025fa:	5d                   	pop    %ebp
  8025fb:	c3                   	ret    

008025fc <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8025fc:	55                   	push   %ebp
  8025fd:	89 e5                	mov    %esp,%ebp
  8025ff:	53                   	push   %ebx
  802600:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  802603:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  802608:	39 c1                	cmp    %eax,%ecx
  80260a:	74 21                	je     80262d <ipc_find_env+0x31>
  80260c:	ba 01 00 00 00       	mov    $0x1,%edx
  802611:	8d 1c 95 00 00 00 00 	lea    0x0(,%edx,4),%ebx
  802618:	89 d0                	mov    %edx,%eax
  80261a:	c1 e0 07             	shl    $0x7,%eax
  80261d:	29 d8                	sub    %ebx,%eax
  80261f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802624:	8b 40 50             	mov    0x50(%eax),%eax
  802627:	39 c8                	cmp    %ecx,%eax
  802629:	75 1b                	jne    802646 <ipc_find_env+0x4a>
  80262b:	eb 05                	jmp    802632 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80262d:	ba 00 00 00 00       	mov    $0x0,%edx
		if (envs[i].env_type == type)
			return envs[i].env_id;
  802632:	8d 04 95 00 00 00 00 	lea    0x0(,%edx,4),%eax
  802639:	c1 e2 07             	shl    $0x7,%edx
  80263c:	29 c2                	sub    %eax,%edx
  80263e:	8b 82 48 00 c0 ee    	mov    -0x113fffb8(%edx),%eax
  802644:	eb 0e                	jmp    802654 <ipc_find_env+0x58>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802646:	42                   	inc    %edx
  802647:	81 fa 00 04 00 00    	cmp    $0x400,%edx
  80264d:	75 c2                	jne    802611 <ipc_find_env+0x15>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80264f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802654:	5b                   	pop    %ebx
  802655:	5d                   	pop    %ebp
  802656:	c3                   	ret    

00802657 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802657:	55                   	push   %ebp
  802658:	89 e5                	mov    %esp,%ebp
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80265a:	8b 45 08             	mov    0x8(%ebp),%eax
  80265d:	c1 e8 16             	shr    $0x16,%eax
  802660:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  802667:	a8 01                	test   $0x1,%al
  802669:	74 21                	je     80268c <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  80266b:	8b 45 08             	mov    0x8(%ebp),%eax
  80266e:	c1 e8 0c             	shr    $0xc,%eax
  802671:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802678:	a8 01                	test   $0x1,%al
  80267a:	74 17                	je     802693 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80267c:	c1 e8 0c             	shr    $0xc,%eax
  80267f:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  802686:	ef 
  802687:	0f b7 c0             	movzwl %ax,%eax
  80268a:	eb 0c                	jmp    802698 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  80268c:	b8 00 00 00 00       	mov    $0x0,%eax
  802691:	eb 05                	jmp    802698 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  802693:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  802698:	5d                   	pop    %ebp
  802699:	c3                   	ret    
  80269a:	66 90                	xchg   %ax,%ax

0080269c <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  80269c:	55                   	push   %ebp
  80269d:	57                   	push   %edi
  80269e:	56                   	push   %esi
  80269f:	53                   	push   %ebx
  8026a0:	83 ec 1c             	sub    $0x1c,%esp
  8026a3:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8026a7:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8026ab:	8b 7c 24 38          	mov    0x38(%esp),%edi
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8026af:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8026b3:	89 ca                	mov    %ecx,%edx
  const DWunion dd = {.ll = d};
  8026b5:	89 f8                	mov    %edi,%eax
  8026b7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8026bb:	85 f6                	test   %esi,%esi
  8026bd:	75 2d                	jne    8026ec <__udivdi3+0x50>
    {
      if (d0 > n1)
  8026bf:	39 cf                	cmp    %ecx,%edi
  8026c1:	77 65                	ja     802728 <__udivdi3+0x8c>
  8026c3:	89 fd                	mov    %edi,%ebp
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8026c5:	85 ff                	test   %edi,%edi
  8026c7:	75 0b                	jne    8026d4 <__udivdi3+0x38>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8026c9:	b8 01 00 00 00       	mov    $0x1,%eax
  8026ce:	31 d2                	xor    %edx,%edx
  8026d0:	f7 f7                	div    %edi
  8026d2:	89 c5                	mov    %eax,%ebp

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8026d4:	31 d2                	xor    %edx,%edx
  8026d6:	89 c8                	mov    %ecx,%eax
  8026d8:	f7 f5                	div    %ebp
  8026da:	89 c1                	mov    %eax,%ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8026dc:	89 d8                	mov    %ebx,%eax
  8026de:	f7 f5                	div    %ebp
  8026e0:	89 cf                	mov    %ecx,%edi
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8026e2:	89 fa                	mov    %edi,%edx
  8026e4:	83 c4 1c             	add    $0x1c,%esp
  8026e7:	5b                   	pop    %ebx
  8026e8:	5e                   	pop    %esi
  8026e9:	5f                   	pop    %edi
  8026ea:	5d                   	pop    %ebp
  8026eb:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8026ec:	39 ce                	cmp    %ecx,%esi
  8026ee:	77 28                	ja     802718 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8026f0:	0f bd fe             	bsr    %esi,%edi
	  if (bm == 0)
  8026f3:	83 f7 1f             	xor    $0x1f,%edi
  8026f6:	75 40                	jne    802738 <__udivdi3+0x9c>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8026f8:	39 ce                	cmp    %ecx,%esi
  8026fa:	72 0a                	jb     802706 <__udivdi3+0x6a>
  8026fc:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802700:	0f 87 9e 00 00 00    	ja     8027a4 <__udivdi3+0x108>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802706:	b8 01 00 00 00       	mov    $0x1,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80270b:	89 fa                	mov    %edi,%edx
  80270d:	83 c4 1c             	add    $0x1c,%esp
  802710:	5b                   	pop    %ebx
  802711:	5e                   	pop    %esi
  802712:	5f                   	pop    %edi
  802713:	5d                   	pop    %ebp
  802714:	c3                   	ret    
  802715:	8d 76 00             	lea    0x0(%esi),%esi
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802718:	31 ff                	xor    %edi,%edi
  80271a:	31 c0                	xor    %eax,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80271c:	89 fa                	mov    %edi,%edx
  80271e:	83 c4 1c             	add    $0x1c,%esp
  802721:	5b                   	pop    %ebx
  802722:	5e                   	pop    %esi
  802723:	5f                   	pop    %edi
  802724:	5d                   	pop    %ebp
  802725:	c3                   	ret    
  802726:	66 90                	xchg   %ax,%ax
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802728:	89 d8                	mov    %ebx,%eax
  80272a:	f7 f7                	div    %edi
  80272c:	31 ff                	xor    %edi,%edi
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80272e:	89 fa                	mov    %edi,%edx
  802730:	83 c4 1c             	add    $0x1c,%esp
  802733:	5b                   	pop    %ebx
  802734:	5e                   	pop    %esi
  802735:	5f                   	pop    %edi
  802736:	5d                   	pop    %ebp
  802737:	c3                   	ret    
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802738:	bd 20 00 00 00       	mov    $0x20,%ebp
  80273d:	89 eb                	mov    %ebp,%ebx
  80273f:	29 fb                	sub    %edi,%ebx

	      d1 = (d1 << bm) | (d0 >> b);
  802741:	89 f9                	mov    %edi,%ecx
  802743:	d3 e6                	shl    %cl,%esi
  802745:	89 c5                	mov    %eax,%ebp
  802747:	88 d9                	mov    %bl,%cl
  802749:	d3 ed                	shr    %cl,%ebp
  80274b:	89 e9                	mov    %ebp,%ecx
  80274d:	09 f1                	or     %esi,%ecx
  80274f:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
	      d0 = d0 << bm;
  802753:	89 f9                	mov    %edi,%ecx
  802755:	d3 e0                	shl    %cl,%eax
  802757:	89 c5                	mov    %eax,%ebp
	      n2 = n1 >> b;
  802759:	89 d6                	mov    %edx,%esi
  80275b:	88 d9                	mov    %bl,%cl
  80275d:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
  80275f:	89 f9                	mov    %edi,%ecx
  802761:	d3 e2                	shl    %cl,%edx
  802763:	8b 44 24 08          	mov    0x8(%esp),%eax
  802767:	88 d9                	mov    %bl,%cl
  802769:	d3 e8                	shr    %cl,%eax
  80276b:	09 c2                	or     %eax,%edx
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  80276d:	89 d0                	mov    %edx,%eax
  80276f:	89 f2                	mov    %esi,%edx
  802771:	f7 74 24 0c          	divl   0xc(%esp)
  802775:	89 d6                	mov    %edx,%esi
  802777:	89 c3                	mov    %eax,%ebx
	      umul_ppmm (m1, m0, q0, d0);
  802779:	f7 e5                	mul    %ebp

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80277b:	39 d6                	cmp    %edx,%esi
  80277d:	72 19                	jb     802798 <__udivdi3+0xfc>
  80277f:	74 0b                	je     80278c <__udivdi3+0xf0>
  802781:	89 d8                	mov    %ebx,%eax
  802783:	31 ff                	xor    %edi,%edi
  802785:	e9 58 ff ff ff       	jmp    8026e2 <__udivdi3+0x46>
  80278a:	66 90                	xchg   %ax,%ax
  80278c:	8b 54 24 08          	mov    0x8(%esp),%edx
  802790:	89 f9                	mov    %edi,%ecx
  802792:	d3 e2                	shl    %cl,%edx
  802794:	39 c2                	cmp    %eax,%edx
  802796:	73 e9                	jae    802781 <__udivdi3+0xe5>
  802798:	8d 43 ff             	lea    -0x1(%ebx),%eax
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  80279b:	31 ff                	xor    %edi,%edi
  80279d:	e9 40 ff ff ff       	jmp    8026e2 <__udivdi3+0x46>
  8027a2:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8027a4:	31 c0                	xor    %eax,%eax
  8027a6:	e9 37 ff ff ff       	jmp    8026e2 <__udivdi3+0x46>
  8027ab:	90                   	nop

008027ac <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  8027ac:	55                   	push   %ebp
  8027ad:	57                   	push   %edi
  8027ae:	56                   	push   %esi
  8027af:	53                   	push   %ebx
  8027b0:	83 ec 1c             	sub    $0x1c,%esp
  8027b3:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8027b7:	8b 74 24 34          	mov    0x34(%esp),%esi
  8027bb:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8027bf:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8027c3:	89 44 24 0c          	mov    %eax,0xc(%esp)
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8027c7:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8027cb:	89 f3                	mov    %esi,%ebx
  const DWunion dd = {.ll = d};
  8027cd:	89 fa                	mov    %edi,%edx
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  8027cf:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  n1 = nn.s.high;
  8027d3:	89 34 24             	mov    %esi,(%esp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8027d6:	85 c0                	test   %eax,%eax
  8027d8:	75 1a                	jne    8027f4 <__umoddi3+0x48>
    {
      if (d0 > n1)
  8027da:	39 f7                	cmp    %esi,%edi
  8027dc:	0f 86 a2 00 00 00    	jbe    802884 <__umoddi3+0xd8>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8027e2:	89 c8                	mov    %ecx,%eax
  8027e4:	89 f2                	mov    %esi,%edx
  8027e6:	f7 f7                	div    %edi
  8027e8:	89 d0                	mov    %edx,%eax

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  8027ea:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8027ec:	83 c4 1c             	add    $0x1c,%esp
  8027ef:	5b                   	pop    %ebx
  8027f0:	5e                   	pop    %esi
  8027f1:	5f                   	pop    %edi
  8027f2:	5d                   	pop    %ebp
  8027f3:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8027f4:	39 f0                	cmp    %esi,%eax
  8027f6:	0f 87 ac 00 00 00    	ja     8028a8 <__umoddi3+0xfc>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8027fc:	0f bd e8             	bsr    %eax,%ebp
	  if (bm == 0)
  8027ff:	83 f5 1f             	xor    $0x1f,%ebp
  802802:	0f 84 ac 00 00 00    	je     8028b4 <__umoddi3+0x108>
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802808:	bf 20 00 00 00       	mov    $0x20,%edi
  80280d:	29 ef                	sub    %ebp,%edi
  80280f:	89 fe                	mov    %edi,%esi
  802811:	89 7c 24 0c          	mov    %edi,0xc(%esp)

	      d1 = (d1 << bm) | (d0 >> b);
  802815:	89 e9                	mov    %ebp,%ecx
  802817:	d3 e0                	shl    %cl,%eax
  802819:	89 d7                	mov    %edx,%edi
  80281b:	89 f1                	mov    %esi,%ecx
  80281d:	d3 ef                	shr    %cl,%edi
  80281f:	09 c7                	or     %eax,%edi
	      d0 = d0 << bm;
  802821:	89 e9                	mov    %ebp,%ecx
  802823:	d3 e2                	shl    %cl,%edx
  802825:	89 14 24             	mov    %edx,(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802828:	89 d8                	mov    %ebx,%eax
  80282a:	d3 e0                	shl    %cl,%eax
  80282c:	89 c2                	mov    %eax,%edx
	      n0 = n0 << bm;
  80282e:	8b 44 24 08          	mov    0x8(%esp),%eax
  802832:	d3 e0                	shl    %cl,%eax
  802834:	89 44 24 04          	mov    %eax,0x4(%esp)

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802838:	8b 44 24 08          	mov    0x8(%esp),%eax
  80283c:	89 f1                	mov    %esi,%ecx
  80283e:	d3 e8                	shr    %cl,%eax
  802840:	09 d0                	or     %edx,%eax
  802842:	d3 eb                	shr    %cl,%ebx
  802844:	89 da                	mov    %ebx,%edx
  802846:	f7 f7                	div    %edi
  802848:	89 d3                	mov    %edx,%ebx
	      umul_ppmm (m1, m0, q0, d0);
  80284a:	f7 24 24             	mull   (%esp)
  80284d:	89 c6                	mov    %eax,%esi
  80284f:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802851:	39 d3                	cmp    %edx,%ebx
  802853:	0f 82 87 00 00 00    	jb     8028e0 <__umoddi3+0x134>
  802859:	0f 84 91 00 00 00    	je     8028f0 <__umoddi3+0x144>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  80285f:	8b 54 24 04          	mov    0x4(%esp),%edx
  802863:	29 f2                	sub    %esi,%edx
  802865:	19 cb                	sbb    %ecx,%ebx
		  rr.s.low = (n1 << b) | (n0 >> bm);
  802867:	89 d8                	mov    %ebx,%eax
  802869:	8a 4c 24 0c          	mov    0xc(%esp),%cl
  80286d:	d3 e0                	shl    %cl,%eax
  80286f:	89 e9                	mov    %ebp,%ecx
  802871:	d3 ea                	shr    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  802873:	09 d0                	or     %edx,%eax
  802875:	89 e9                	mov    %ebp,%ecx
  802877:	d3 eb                	shr    %cl,%ebx
  802879:	89 da                	mov    %ebx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80287b:	83 c4 1c             	add    $0x1c,%esp
  80287e:	5b                   	pop    %ebx
  80287f:	5e                   	pop    %esi
  802880:	5f                   	pop    %edi
  802881:	5d                   	pop    %ebp
  802882:	c3                   	ret    
  802883:	90                   	nop
  802884:	89 fd                	mov    %edi,%ebp
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802886:	85 ff                	test   %edi,%edi
  802888:	75 0b                	jne    802895 <__umoddi3+0xe9>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  80288a:	b8 01 00 00 00       	mov    $0x1,%eax
  80288f:	31 d2                	xor    %edx,%edx
  802891:	f7 f7                	div    %edi
  802893:	89 c5                	mov    %eax,%ebp

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802895:	89 f0                	mov    %esi,%eax
  802897:	31 d2                	xor    %edx,%edx
  802899:	f7 f5                	div    %ebp
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80289b:	89 c8                	mov    %ecx,%eax
  80289d:	f7 f5                	div    %ebp
  80289f:	89 d0                	mov    %edx,%eax
  8028a1:	e9 44 ff ff ff       	jmp    8027ea <__umoddi3+0x3e>
  8028a6:	66 90                	xchg   %ax,%ax
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  8028a8:	89 c8                	mov    %ecx,%eax
  8028aa:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8028ac:	83 c4 1c             	add    $0x1c,%esp
  8028af:	5b                   	pop    %ebx
  8028b0:	5e                   	pop    %esi
  8028b1:	5f                   	pop    %edi
  8028b2:	5d                   	pop    %ebp
  8028b3:	c3                   	ret    

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8028b4:	3b 04 24             	cmp    (%esp),%eax
  8028b7:	72 06                	jb     8028bf <__umoddi3+0x113>
  8028b9:	3b 7c 24 04          	cmp    0x4(%esp),%edi
  8028bd:	77 0f                	ja     8028ce <__umoddi3+0x122>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8028bf:	89 f2                	mov    %esi,%edx
  8028c1:	29 f9                	sub    %edi,%ecx
  8028c3:	1b 54 24 0c          	sbb    0xc(%esp),%edx
  8028c7:	89 14 24             	mov    %edx,(%esp)
  8028ca:	89 4c 24 04          	mov    %ecx,0x4(%esp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  8028ce:	8b 44 24 04          	mov    0x4(%esp),%eax
  8028d2:	8b 14 24             	mov    (%esp),%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8028d5:	83 c4 1c             	add    $0x1c,%esp
  8028d8:	5b                   	pop    %ebx
  8028d9:	5e                   	pop    %esi
  8028da:	5f                   	pop    %edi
  8028db:	5d                   	pop    %ebp
  8028dc:	c3                   	ret    
  8028dd:	8d 76 00             	lea    0x0(%esi),%esi
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8028e0:	2b 04 24             	sub    (%esp),%eax
  8028e3:	19 fa                	sbb    %edi,%edx
  8028e5:	89 d1                	mov    %edx,%ecx
  8028e7:	89 c6                	mov    %eax,%esi
  8028e9:	e9 71 ff ff ff       	jmp    80285f <__umoddi3+0xb3>
  8028ee:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8028f0:	39 44 24 04          	cmp    %eax,0x4(%esp)
  8028f4:	72 ea                	jb     8028e0 <__umoddi3+0x134>
  8028f6:	89 d9                	mov    %ebx,%ecx
  8028f8:	e9 62 ff ff ff       	jmp    80285f <__umoddi3+0xb3>
