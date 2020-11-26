
obj/user/icode.debug:     file format elf32-i386


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
  80002c:	e8 03 01 00 00       	call   800134 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	81 ec 1c 02 00 00    	sub    $0x21c,%esp
	int fd, n, r;
	char buf[512+1];

	binaryname = "icode";
  80003e:	c7 05 00 30 80 00 c0 	movl   $0x8024c0,0x803000
  800045:	24 80 00 

	cprintf("icode startup\n");
  800048:	68 c6 24 80 00       	push   $0x8024c6
  80004d:	e8 23 02 00 00       	call   800275 <cprintf>

	cprintf("icode: open /motd\n");
  800052:	c7 04 24 d5 24 80 00 	movl   $0x8024d5,(%esp)
  800059:	e8 17 02 00 00       	call   800275 <cprintf>
	if ((fd = open("/motd", O_RDONLY)) < 0)
  80005e:	83 c4 08             	add    $0x8,%esp
  800061:	6a 00                	push   $0x0
  800063:	68 e8 24 80 00       	push   $0x8024e8
  800068:	e8 6b 15 00 00       	call   8015d8 <open>
  80006d:	89 c6                	mov    %eax,%esi
  80006f:	83 c4 10             	add    $0x10,%esp
  800072:	85 c0                	test   %eax,%eax
  800074:	79 12                	jns    800088 <umain+0x55>
		panic("icode: open /motd: %e", fd);
  800076:	50                   	push   %eax
  800077:	68 ee 24 80 00       	push   $0x8024ee
  80007c:	6a 0f                	push   $0xf
  80007e:	68 04 25 80 00       	push   $0x802504
  800083:	e8 15 01 00 00       	call   80019d <_panic>

	cprintf("icode: read /motd\n");
  800088:	83 ec 0c             	sub    $0xc,%esp
  80008b:	68 11 25 80 00       	push   $0x802511
  800090:	e8 e0 01 00 00       	call   800275 <cprintf>
	while ((n = read(fd, buf, sizeof buf-1)) > 0)
  800095:	83 c4 10             	add    $0x10,%esp
  800098:	8d 9d f7 fd ff ff    	lea    -0x209(%ebp),%ebx
  80009e:	eb 0d                	jmp    8000ad <umain+0x7a>
		sys_cputs(buf, n);
  8000a0:	83 ec 08             	sub    $0x8,%esp
  8000a3:	50                   	push   %eax
  8000a4:	53                   	push   %ebx
  8000a5:	e8 64 0b 00 00       	call   800c0e <sys_cputs>
  8000aa:	83 c4 10             	add    $0x10,%esp
	cprintf("icode: open /motd\n");
	if ((fd = open("/motd", O_RDONLY)) < 0)
		panic("icode: open /motd: %e", fd);

	cprintf("icode: read /motd\n");
	while ((n = read(fd, buf, sizeof buf-1)) > 0)
  8000ad:	83 ec 04             	sub    $0x4,%esp
  8000b0:	68 00 02 00 00       	push   $0x200
  8000b5:	53                   	push   %ebx
  8000b6:	56                   	push   %esi
  8000b7:	e8 1b 11 00 00       	call   8011d7 <read>
  8000bc:	83 c4 10             	add    $0x10,%esp
  8000bf:	85 c0                	test   %eax,%eax
  8000c1:	7f dd                	jg     8000a0 <umain+0x6d>
		sys_cputs(buf, n);

	cprintf("icode: close /motd\n");
  8000c3:	83 ec 0c             	sub    $0xc,%esp
  8000c6:	68 24 25 80 00       	push   $0x802524
  8000cb:	e8 a5 01 00 00       	call   800275 <cprintf>
	close(fd);
  8000d0:	89 34 24             	mov    %esi,(%esp)
  8000d3:	e8 c7 0f 00 00       	call   80109f <close>

	cprintf("icode: spawn /init\n");
  8000d8:	c7 04 24 38 25 80 00 	movl   $0x802538,(%esp)
  8000df:	e8 91 01 00 00       	call   800275 <cprintf>
	if ((r = spawnl("/init", "init", "initarg1", "initarg2", (char*)0)) < 0)
  8000e4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000eb:	68 4c 25 80 00       	push   $0x80254c
  8000f0:	68 55 25 80 00       	push   $0x802555
  8000f5:	68 5f 25 80 00       	push   $0x80255f
  8000fa:	68 5e 25 80 00       	push   $0x80255e
  8000ff:	e8 5d 1a 00 00       	call   801b61 <spawnl>
  800104:	83 c4 20             	add    $0x20,%esp
  800107:	85 c0                	test   %eax,%eax
  800109:	79 12                	jns    80011d <umain+0xea>
		panic("icode: spawn /init: %e", r);
  80010b:	50                   	push   %eax
  80010c:	68 64 25 80 00       	push   $0x802564
  800111:	6a 1a                	push   $0x1a
  800113:	68 04 25 80 00       	push   $0x802504
  800118:	e8 80 00 00 00       	call   80019d <_panic>

	cprintf("icode: exiting\n");
  80011d:	83 ec 0c             	sub    $0xc,%esp
  800120:	68 7b 25 80 00       	push   $0x80257b
  800125:	e8 4b 01 00 00       	call   800275 <cprintf>
}
  80012a:	83 c4 10             	add    $0x10,%esp
  80012d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800130:	5b                   	pop    %ebx
  800131:	5e                   	pop    %esi
  800132:	5d                   	pop    %ebp
  800133:	c3                   	ret    

00800134 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800134:	55                   	push   %ebp
  800135:	89 e5                	mov    %esp,%ebp
  800137:	56                   	push   %esi
  800138:	53                   	push   %ebx
  800139:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80013c:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80013f:	e8 48 0b 00 00       	call   800c8c <sys_getenvid>
  800144:	25 ff 03 00 00       	and    $0x3ff,%eax
  800149:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800150:	c1 e0 07             	shl    $0x7,%eax
  800153:	29 d0                	sub    %edx,%eax
  800155:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80015a:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80015f:	85 db                	test   %ebx,%ebx
  800161:	7e 07                	jle    80016a <libmain+0x36>
		binaryname = argv[0];
  800163:	8b 06                	mov    (%esi),%eax
  800165:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80016a:	83 ec 08             	sub    $0x8,%esp
  80016d:	56                   	push   %esi
  80016e:	53                   	push   %ebx
  80016f:	e8 bf fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800174:	e8 0a 00 00 00       	call   800183 <exit>
}
  800179:	83 c4 10             	add    $0x10,%esp
  80017c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80017f:	5b                   	pop    %ebx
  800180:	5e                   	pop    %esi
  800181:	5d                   	pop    %ebp
  800182:	c3                   	ret    

00800183 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800183:	55                   	push   %ebp
  800184:	89 e5                	mov    %esp,%ebp
  800186:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800189:	e8 3c 0f 00 00       	call   8010ca <close_all>
	sys_env_destroy(0);
  80018e:	83 ec 0c             	sub    $0xc,%esp
  800191:	6a 00                	push   $0x0
  800193:	e8 b3 0a 00 00       	call   800c4b <sys_env_destroy>
}
  800198:	83 c4 10             	add    $0x10,%esp
  80019b:	c9                   	leave  
  80019c:	c3                   	ret    

0080019d <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80019d:	55                   	push   %ebp
  80019e:	89 e5                	mov    %esp,%ebp
  8001a0:	56                   	push   %esi
  8001a1:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8001a2:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001a5:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8001ab:	e8 dc 0a 00 00       	call   800c8c <sys_getenvid>
  8001b0:	83 ec 0c             	sub    $0xc,%esp
  8001b3:	ff 75 0c             	pushl  0xc(%ebp)
  8001b6:	ff 75 08             	pushl  0x8(%ebp)
  8001b9:	56                   	push   %esi
  8001ba:	50                   	push   %eax
  8001bb:	68 98 25 80 00       	push   $0x802598
  8001c0:	e8 b0 00 00 00       	call   800275 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001c5:	83 c4 18             	add    $0x18,%esp
  8001c8:	53                   	push   %ebx
  8001c9:	ff 75 10             	pushl  0x10(%ebp)
  8001cc:	e8 53 00 00 00       	call   800224 <vcprintf>
	cprintf("\n");
  8001d1:	c7 04 24 50 2a 80 00 	movl   $0x802a50,(%esp)
  8001d8:	e8 98 00 00 00       	call   800275 <cprintf>
  8001dd:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001e0:	cc                   	int3   
  8001e1:	eb fd                	jmp    8001e0 <_panic+0x43>

008001e3 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001e3:	55                   	push   %ebp
  8001e4:	89 e5                	mov    %esp,%ebp
  8001e6:	53                   	push   %ebx
  8001e7:	83 ec 04             	sub    $0x4,%esp
  8001ea:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001ed:	8b 13                	mov    (%ebx),%edx
  8001ef:	8d 42 01             	lea    0x1(%edx),%eax
  8001f2:	89 03                	mov    %eax,(%ebx)
  8001f4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001f7:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001fb:	3d ff 00 00 00       	cmp    $0xff,%eax
  800200:	75 1a                	jne    80021c <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800202:	83 ec 08             	sub    $0x8,%esp
  800205:	68 ff 00 00 00       	push   $0xff
  80020a:	8d 43 08             	lea    0x8(%ebx),%eax
  80020d:	50                   	push   %eax
  80020e:	e8 fb 09 00 00       	call   800c0e <sys_cputs>
		b->idx = 0;
  800213:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800219:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80021c:	ff 43 04             	incl   0x4(%ebx)
}
  80021f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800222:	c9                   	leave  
  800223:	c3                   	ret    

00800224 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800224:	55                   	push   %ebp
  800225:	89 e5                	mov    %esp,%ebp
  800227:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80022d:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800234:	00 00 00 
	b.cnt = 0;
  800237:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80023e:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800241:	ff 75 0c             	pushl  0xc(%ebp)
  800244:	ff 75 08             	pushl  0x8(%ebp)
  800247:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80024d:	50                   	push   %eax
  80024e:	68 e3 01 80 00       	push   $0x8001e3
  800253:	e8 54 01 00 00       	call   8003ac <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800258:	83 c4 08             	add    $0x8,%esp
  80025b:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800261:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800267:	50                   	push   %eax
  800268:	e8 a1 09 00 00       	call   800c0e <sys_cputs>

	return b.cnt;
}
  80026d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800273:	c9                   	leave  
  800274:	c3                   	ret    

00800275 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800275:	55                   	push   %ebp
  800276:	89 e5                	mov    %esp,%ebp
  800278:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80027b:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80027e:	50                   	push   %eax
  80027f:	ff 75 08             	pushl  0x8(%ebp)
  800282:	e8 9d ff ff ff       	call   800224 <vcprintf>
	va_end(ap);

	return cnt;
}
  800287:	c9                   	leave  
  800288:	c3                   	ret    

00800289 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800289:	55                   	push   %ebp
  80028a:	89 e5                	mov    %esp,%ebp
  80028c:	57                   	push   %edi
  80028d:	56                   	push   %esi
  80028e:	53                   	push   %ebx
  80028f:	83 ec 1c             	sub    $0x1c,%esp
  800292:	89 c6                	mov    %eax,%esi
  800294:	89 d7                	mov    %edx,%edi
  800296:	8b 45 08             	mov    0x8(%ebp),%eax
  800299:	8b 55 0c             	mov    0xc(%ebp),%edx
  80029c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80029f:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002a2:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8002a5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002aa:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8002ad:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8002b0:	39 d3                	cmp    %edx,%ebx
  8002b2:	72 11                	jb     8002c5 <printnum+0x3c>
  8002b4:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002b7:	76 0c                	jbe    8002c5 <printnum+0x3c>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8002bc:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8002bf:	85 db                	test   %ebx,%ebx
  8002c1:	7f 37                	jg     8002fa <printnum+0x71>
  8002c3:	eb 44                	jmp    800309 <printnum+0x80>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002c5:	83 ec 0c             	sub    $0xc,%esp
  8002c8:	ff 75 18             	pushl  0x18(%ebp)
  8002cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8002ce:	48                   	dec    %eax
  8002cf:	50                   	push   %eax
  8002d0:	ff 75 10             	pushl  0x10(%ebp)
  8002d3:	83 ec 08             	sub    $0x8,%esp
  8002d6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002d9:	ff 75 e0             	pushl  -0x20(%ebp)
  8002dc:	ff 75 dc             	pushl  -0x24(%ebp)
  8002df:	ff 75 d8             	pushl  -0x28(%ebp)
  8002e2:	e8 75 1f 00 00       	call   80225c <__udivdi3>
  8002e7:	83 c4 18             	add    $0x18,%esp
  8002ea:	52                   	push   %edx
  8002eb:	50                   	push   %eax
  8002ec:	89 fa                	mov    %edi,%edx
  8002ee:	89 f0                	mov    %esi,%eax
  8002f0:	e8 94 ff ff ff       	call   800289 <printnum>
  8002f5:	83 c4 20             	add    $0x20,%esp
  8002f8:	eb 0f                	jmp    800309 <printnum+0x80>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002fa:	83 ec 08             	sub    $0x8,%esp
  8002fd:	57                   	push   %edi
  8002fe:	ff 75 18             	pushl  0x18(%ebp)
  800301:	ff d6                	call   *%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800303:	83 c4 10             	add    $0x10,%esp
  800306:	4b                   	dec    %ebx
  800307:	75 f1                	jne    8002fa <printnum+0x71>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800309:	83 ec 08             	sub    $0x8,%esp
  80030c:	57                   	push   %edi
  80030d:	83 ec 04             	sub    $0x4,%esp
  800310:	ff 75 e4             	pushl  -0x1c(%ebp)
  800313:	ff 75 e0             	pushl  -0x20(%ebp)
  800316:	ff 75 dc             	pushl  -0x24(%ebp)
  800319:	ff 75 d8             	pushl  -0x28(%ebp)
  80031c:	e8 4b 20 00 00       	call   80236c <__umoddi3>
  800321:	83 c4 14             	add    $0x14,%esp
  800324:	0f be 80 bb 25 80 00 	movsbl 0x8025bb(%eax),%eax
  80032b:	50                   	push   %eax
  80032c:	ff d6                	call   *%esi
}
  80032e:	83 c4 10             	add    $0x10,%esp
  800331:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800334:	5b                   	pop    %ebx
  800335:	5e                   	pop    %esi
  800336:	5f                   	pop    %edi
  800337:	5d                   	pop    %ebp
  800338:	c3                   	ret    

00800339 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800339:	55                   	push   %ebp
  80033a:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80033c:	83 fa 01             	cmp    $0x1,%edx
  80033f:	7e 0e                	jle    80034f <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800341:	8b 10                	mov    (%eax),%edx
  800343:	8d 4a 08             	lea    0x8(%edx),%ecx
  800346:	89 08                	mov    %ecx,(%eax)
  800348:	8b 02                	mov    (%edx),%eax
  80034a:	8b 52 04             	mov    0x4(%edx),%edx
  80034d:	eb 22                	jmp    800371 <getuint+0x38>
	else if (lflag)
  80034f:	85 d2                	test   %edx,%edx
  800351:	74 10                	je     800363 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800353:	8b 10                	mov    (%eax),%edx
  800355:	8d 4a 04             	lea    0x4(%edx),%ecx
  800358:	89 08                	mov    %ecx,(%eax)
  80035a:	8b 02                	mov    (%edx),%eax
  80035c:	ba 00 00 00 00       	mov    $0x0,%edx
  800361:	eb 0e                	jmp    800371 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800363:	8b 10                	mov    (%eax),%edx
  800365:	8d 4a 04             	lea    0x4(%edx),%ecx
  800368:	89 08                	mov    %ecx,(%eax)
  80036a:	8b 02                	mov    (%edx),%eax
  80036c:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800371:	5d                   	pop    %ebp
  800372:	c3                   	ret    

00800373 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800373:	55                   	push   %ebp
  800374:	89 e5                	mov    %esp,%ebp
  800376:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800379:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  80037c:	8b 10                	mov    (%eax),%edx
  80037e:	3b 50 04             	cmp    0x4(%eax),%edx
  800381:	73 0a                	jae    80038d <sprintputch+0x1a>
		*b->buf++ = ch;
  800383:	8d 4a 01             	lea    0x1(%edx),%ecx
  800386:	89 08                	mov    %ecx,(%eax)
  800388:	8b 45 08             	mov    0x8(%ebp),%eax
  80038b:	88 02                	mov    %al,(%edx)
}
  80038d:	5d                   	pop    %ebp
  80038e:	c3                   	ret    

0080038f <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80038f:	55                   	push   %ebp
  800390:	89 e5                	mov    %esp,%ebp
  800392:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800395:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800398:	50                   	push   %eax
  800399:	ff 75 10             	pushl  0x10(%ebp)
  80039c:	ff 75 0c             	pushl  0xc(%ebp)
  80039f:	ff 75 08             	pushl  0x8(%ebp)
  8003a2:	e8 05 00 00 00       	call   8003ac <vprintfmt>
	va_end(ap);
}
  8003a7:	83 c4 10             	add    $0x10,%esp
  8003aa:	c9                   	leave  
  8003ab:	c3                   	ret    

008003ac <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003ac:	55                   	push   %ebp
  8003ad:	89 e5                	mov    %esp,%ebp
  8003af:	57                   	push   %edi
  8003b0:	56                   	push   %esi
  8003b1:	53                   	push   %ebx
  8003b2:	83 ec 2c             	sub    $0x2c,%esp
  8003b5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8003b8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003bb:	eb 03                	jmp    8003c0 <vprintfmt+0x14>
			break;

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
			for (fmt--; fmt[-1] != '%'; fmt--)
  8003bd:	89 75 10             	mov    %esi,0x10(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {    //遍历输入的第一个参数，即输出信息的格式，先把格式字符串中'%'之前的字符一个个输出，因为它们前面没有'%'，所以它们就是要直接显示在屏幕上的
  8003c0:	8b 45 10             	mov    0x10(%ebp),%eax
  8003c3:	8d 70 01             	lea    0x1(%eax),%esi
  8003c6:	0f b6 00             	movzbl (%eax),%eax
  8003c9:	83 f8 25             	cmp    $0x25,%eax
  8003cc:	74 25                	je     8003f3 <vprintfmt+0x47>
			if (ch == '\0')									//当然中间如果遇到'\0'，代表这个字符串的访问结束
  8003ce:	85 c0                	test   %eax,%eax
  8003d0:	75 0d                	jne    8003df <vprintfmt+0x33>
  8003d2:	e9 b5 03 00 00       	jmp    80078c <vprintfmt+0x3e0>
  8003d7:	85 c0                	test   %eax,%eax
  8003d9:	0f 84 ad 03 00 00    	je     80078c <vprintfmt+0x3e0>
				return;
			putch(ch, putdat);								//调用putch函数，把一个字符ch输出到putdat指针所指向的地址中所存放的值对应的地址处
  8003df:	83 ec 08             	sub    $0x8,%esp
  8003e2:	53                   	push   %ebx
  8003e3:	50                   	push   %eax
  8003e4:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {    //遍历输入的第一个参数，即输出信息的格式，先把格式字符串中'%'之前的字符一个个输出，因为它们前面没有'%'，所以它们就是要直接显示在屏幕上的
  8003e6:	46                   	inc    %esi
  8003e7:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  8003eb:	83 c4 10             	add    $0x10,%esp
  8003ee:	83 f8 25             	cmp    $0x25,%eax
  8003f1:	75 e4                	jne    8003d7 <vprintfmt+0x2b>
			if (width < 0)									//代表有小数点，但是小数点前面并没有数字，比如'%.6f'这种情况，此时代表整数部分全部显示
				width = 0;			
			goto reswitch;

		case '#':
			altflag = 1;
  8003f3:	c6 45 e3 20          	movb   $0x20,-0x1d(%ebp)
  8003f7:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8003fe:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800405:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80040c:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800413:	eb 07                	jmp    80041c <vprintfmt+0x70>
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  800415:	8b 75 10             	mov    0x10(%ebp),%esi

		// flag to pad on the right
		case '-':											//%后面的'-'代表要进行左对齐输出，右边填空格，如果省略代表右对齐
			padc = '-';										//如果有这个字符代表左对齐，则把对齐方式标志位变为'-'
  800418:	c6 45 e3 2d          	movb   $0x2d,-0x1d(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  80041c:	8d 46 01             	lea    0x1(%esi),%eax
  80041f:	89 45 10             	mov    %eax,0x10(%ebp)
  800422:	0f b6 16             	movzbl (%esi),%edx
  800425:	8a 06                	mov    (%esi),%al
  800427:	83 e8 23             	sub    $0x23,%eax
  80042a:	3c 55                	cmp    $0x55,%al
  80042c:	0f 87 03 03 00 00    	ja     800735 <vprintfmt+0x389>
  800432:	0f b6 c0             	movzbl %al,%eax
  800435:	ff 24 85 00 27 80 00 	jmp    *0x802700(,%eax,4)
  80043c:	8b 75 10             	mov    0x10(%ebp),%esi
			padc = '-';										//如果有这个字符代表左对齐，则把对齐方式标志位变为'-'
			goto reswitch;									//处理下一个字符

		// flag to pad with 0's instead of spaces
		case '0':											//0--有0表示进行对齐输出时填0,如省略表示填入空格，并且如果为0，则一定是右对齐
			padc = '0';										//对其方式标志位变为0
  80043f:	c6 45 e3 30          	movb   $0x30,-0x1d(%ebp)
  800443:	eb d7                	jmp    80041c <vprintfmt+0x70>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {					//把遇到的位数字符串转换为真实的位数，比如输入的'%40'，代表有效位数为40位，下面的循环就是把precesion的值设置为40
				precision = precision * 10 + ch - '0';
  800445:	8d 42 d0             	lea    -0x30(%edx),%eax
  800448:	89 c1                	mov    %eax,%ecx
  80044a:	89 45 d0             	mov    %eax,-0x30(%ebp)
				ch = *fmt;
  80044d:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  800451:	8d 50 d0             	lea    -0x30(%eax),%edx
  800454:	83 fa 09             	cmp    $0x9,%edx
  800457:	77 51                	ja     8004aa <vprintfmt+0xfe>
  800459:	8b 75 10             	mov    0x10(%ebp),%esi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {					//把遇到的位数字符串转换为真实的位数，比如输入的'%40'，代表有效位数为40位，下面的循环就是把precesion的值设置为40
  80045c:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  80045d:	8d 14 89             	lea    (%ecx,%ecx,4),%edx
  800460:	01 d2                	add    %edx,%edx
  800462:	8d 4c 10 d0          	lea    -0x30(%eax,%edx,1),%ecx
				ch = *fmt;
  800466:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800469:	8d 50 d0             	lea    -0x30(%eax),%edx
  80046c:	83 fa 09             	cmp    $0x9,%edx
  80046f:	76 eb                	jbe    80045c <vprintfmt+0xb0>
  800471:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800474:	eb 37                	jmp    8004ad <vprintfmt+0x101>
					break;
			}
			goto process_precision;							//跳转到process_precistion子过程

		case '*':											//*--代表有效数字的位数也是由输入参数指定的，比如printf("%*.*f", 10, 2, n)，其中10,2就是用来指定显示的有效数字位数的
			precision = va_arg(ap, int);
  800476:	8b 45 14             	mov    0x14(%ebp),%eax
  800479:	8d 50 04             	lea    0x4(%eax),%edx
  80047c:	89 55 14             	mov    %edx,0x14(%ebp)
  80047f:	8b 00                	mov    (%eax),%eax
  800481:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  800484:	8b 75 10             	mov    0x10(%ebp),%esi
			}
			goto process_precision;							//跳转到process_precistion子过程

		case '*':											//*--代表有效数字的位数也是由输入参数指定的，比如printf("%*.*f", 10, 2, n)，其中10,2就是用来指定显示的有效数字位数的
			precision = va_arg(ap, int);
			goto process_precision;
  800487:	eb 24                	jmp    8004ad <vprintfmt+0x101>
  800489:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80048d:	79 07                	jns    800496 <vprintfmt+0xea>
  80048f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  800496:	8b 75 10             	mov    0x10(%ebp),%esi
  800499:	eb 81                	jmp    80041c <vprintfmt+0x70>
  80049b:	8b 75 10             	mov    0x10(%ebp),%esi
			if (width < 0)									//代表有小数点，但是小数点前面并没有数字，比如'%.6f'这种情况，此时代表整数部分全部显示
				width = 0;			
			goto reswitch;

		case '#':
			altflag = 1;
  80049e:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8004a5:	e9 72 ff ff ff       	jmp    80041c <vprintfmt+0x70>
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  8004aa:	8b 75 10             	mov    0x10(%ebp),%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:									//处理输出精度，把width字段赋值为刚刚计算出来的precision值，所以width应该是整数部分的有效数字位数
			if (width < 0)
  8004ad:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004b1:	0f 89 65 ff ff ff    	jns    80041c <vprintfmt+0x70>
				width = precision, precision = -1;
  8004b7:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8004ba:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004bd:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8004c4:	e9 53 ff ff ff       	jmp    80041c <vprintfmt+0x70>
			goto reswitch;

		// long flag (doubled for long long)				
		case 'l':											//如果遇到'l'，代表应该是输入long类型，如果有两个'l'代表long long
			lflag++;										//此时把lflag++
  8004c9:	ff 45 d4             	incl   -0x2c(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  8004cc:	8b 75 10             	mov    0x10(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)				
		case 'l':											//如果遇到'l'，代表应该是输入long类型，如果有两个'l'代表long long
			lflag++;										//此时把lflag++
			goto reswitch;
  8004cf:	e9 48 ff ff ff       	jmp    80041c <vprintfmt+0x70>

		// character
		case 'c':											//如果是'c'代表显示一个字符
			putch(va_arg(ap, int), putdat);					//调用输出一个字符到内存的函数putch
  8004d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d7:	8d 50 04             	lea    0x4(%eax),%edx
  8004da:	89 55 14             	mov    %edx,0x14(%ebp)
  8004dd:	83 ec 08             	sub    $0x8,%esp
  8004e0:	53                   	push   %ebx
  8004e1:	ff 30                	pushl  (%eax)
  8004e3:	ff d7                	call   *%edi
			break;
  8004e5:	83 c4 10             	add    $0x10,%esp
  8004e8:	e9 d3 fe ff ff       	jmp    8003c0 <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f0:	8d 50 04             	lea    0x4(%eax),%edx
  8004f3:	89 55 14             	mov    %edx,0x14(%ebp)
  8004f6:	8b 00                	mov    (%eax),%eax
  8004f8:	85 c0                	test   %eax,%eax
  8004fa:	79 02                	jns    8004fe <vprintfmt+0x152>
  8004fc:	f7 d8                	neg    %eax
  8004fe:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800500:	83 f8 0f             	cmp    $0xf,%eax
  800503:	7f 0b                	jg     800510 <vprintfmt+0x164>
  800505:	8b 04 85 60 28 80 00 	mov    0x802860(,%eax,4),%eax
  80050c:	85 c0                	test   %eax,%eax
  80050e:	75 15                	jne    800525 <vprintfmt+0x179>
				printfmt(putch, putdat, "error %d", err);
  800510:	52                   	push   %edx
  800511:	68 d3 25 80 00       	push   $0x8025d3
  800516:	53                   	push   %ebx
  800517:	57                   	push   %edi
  800518:	e8 72 fe ff ff       	call   80038f <printfmt>
  80051d:	83 c4 10             	add    $0x10,%esp
  800520:	e9 9b fe ff ff       	jmp    8003c0 <vprintfmt+0x14>
			else
				printfmt(putch, putdat, "%s", p);
  800525:	50                   	push   %eax
  800526:	68 7f 29 80 00       	push   $0x80297f
  80052b:	53                   	push   %ebx
  80052c:	57                   	push   %edi
  80052d:	e8 5d fe ff ff       	call   80038f <printfmt>
  800532:	83 c4 10             	add    $0x10,%esp
  800535:	e9 86 fe ff ff       	jmp    8003c0 <vprintfmt+0x14>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80053a:	8b 45 14             	mov    0x14(%ebp),%eax
  80053d:	8d 50 04             	lea    0x4(%eax),%edx
  800540:	89 55 14             	mov    %edx,0x14(%ebp)
  800543:	8b 00                	mov    (%eax),%eax
  800545:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800548:	85 c0                	test   %eax,%eax
  80054a:	75 07                	jne    800553 <vprintfmt+0x1a7>
				p = "(null)";
  80054c:	c7 45 d4 cc 25 80 00 	movl   $0x8025cc,-0x2c(%ebp)
			if (width > 0 && padc != '-')
  800553:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800556:	85 f6                	test   %esi,%esi
  800558:	0f 8e fb 01 00 00    	jle    800759 <vprintfmt+0x3ad>
  80055e:	80 7d e3 2d          	cmpb   $0x2d,-0x1d(%ebp)
  800562:	0f 84 09 02 00 00    	je     800771 <vprintfmt+0x3c5>
				for (width -= strnlen(p, precision); width > 0; width--)
  800568:	83 ec 08             	sub    $0x8,%esp
  80056b:	ff 75 d0             	pushl  -0x30(%ebp)
  80056e:	ff 75 d4             	pushl  -0x2c(%ebp)
  800571:	e8 ad 02 00 00       	call   800823 <strnlen>
  800576:	89 f1                	mov    %esi,%ecx
  800578:	29 c1                	sub    %eax,%ecx
  80057a:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  80057d:	83 c4 10             	add    $0x10,%esp
  800580:	85 c9                	test   %ecx,%ecx
  800582:	0f 8e d1 01 00 00    	jle    800759 <vprintfmt+0x3ad>
					putch(padc, putdat);
  800588:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  80058c:	83 ec 08             	sub    $0x8,%esp
  80058f:	53                   	push   %ebx
  800590:	56                   	push   %esi
  800591:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800593:	83 c4 10             	add    $0x10,%esp
  800596:	ff 4d e4             	decl   -0x1c(%ebp)
  800599:	75 f1                	jne    80058c <vprintfmt+0x1e0>
  80059b:	e9 b9 01 00 00       	jmp    800759 <vprintfmt+0x3ad>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005a0:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005a4:	74 19                	je     8005bf <vprintfmt+0x213>
  8005a6:	0f be c0             	movsbl %al,%eax
  8005a9:	83 e8 20             	sub    $0x20,%eax
  8005ac:	83 f8 5e             	cmp    $0x5e,%eax
  8005af:	76 0e                	jbe    8005bf <vprintfmt+0x213>
					putch('?', putdat);
  8005b1:	83 ec 08             	sub    $0x8,%esp
  8005b4:	53                   	push   %ebx
  8005b5:	6a 3f                	push   $0x3f
  8005b7:	ff 55 08             	call   *0x8(%ebp)
  8005ba:	83 c4 10             	add    $0x10,%esp
  8005bd:	eb 0b                	jmp    8005ca <vprintfmt+0x21e>
				else
					putch(ch, putdat);
  8005bf:	83 ec 08             	sub    $0x8,%esp
  8005c2:	53                   	push   %ebx
  8005c3:	52                   	push   %edx
  8005c4:	ff 55 08             	call   *0x8(%ebp)
  8005c7:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005ca:	ff 4d e4             	decl   -0x1c(%ebp)
  8005cd:	46                   	inc    %esi
  8005ce:	8a 46 ff             	mov    -0x1(%esi),%al
  8005d1:	0f be d0             	movsbl %al,%edx
  8005d4:	85 d2                	test   %edx,%edx
  8005d6:	75 1c                	jne    8005f4 <vprintfmt+0x248>
  8005d8:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005db:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005df:	7f 1f                	jg     800600 <vprintfmt+0x254>
  8005e1:	e9 da fd ff ff       	jmp    8003c0 <vprintfmt+0x14>
  8005e6:	89 7d 08             	mov    %edi,0x8(%ebp)
  8005e9:	8b 7d d0             	mov    -0x30(%ebp),%edi
  8005ec:	eb 06                	jmp    8005f4 <vprintfmt+0x248>
  8005ee:	89 7d 08             	mov    %edi,0x8(%ebp)
  8005f1:	8b 7d d0             	mov    -0x30(%ebp),%edi
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005f4:	85 ff                	test   %edi,%edi
  8005f6:	78 a8                	js     8005a0 <vprintfmt+0x1f4>
  8005f8:	4f                   	dec    %edi
  8005f9:	79 a5                	jns    8005a0 <vprintfmt+0x1f4>
  8005fb:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005fe:	eb db                	jmp    8005db <vprintfmt+0x22f>
  800600:	8b 75 e4             	mov    -0x1c(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800603:	83 ec 08             	sub    $0x8,%esp
  800606:	53                   	push   %ebx
  800607:	6a 20                	push   $0x20
  800609:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80060b:	4e                   	dec    %esi
  80060c:	83 c4 10             	add    $0x10,%esp
  80060f:	85 f6                	test   %esi,%esi
  800611:	7f f0                	jg     800603 <vprintfmt+0x257>
  800613:	e9 a8 fd ff ff       	jmp    8003c0 <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800618:	83 7d d4 01          	cmpl   $0x1,-0x2c(%ebp)
  80061c:	7e 16                	jle    800634 <vprintfmt+0x288>
		return va_arg(*ap, long long);
  80061e:	8b 45 14             	mov    0x14(%ebp),%eax
  800621:	8d 50 08             	lea    0x8(%eax),%edx
  800624:	89 55 14             	mov    %edx,0x14(%ebp)
  800627:	8b 50 04             	mov    0x4(%eax),%edx
  80062a:	8b 00                	mov    (%eax),%eax
  80062c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80062f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800632:	eb 34                	jmp    800668 <vprintfmt+0x2bc>
	else if (lflag)
  800634:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800638:	74 18                	je     800652 <vprintfmt+0x2a6>
		return va_arg(*ap, long);
  80063a:	8b 45 14             	mov    0x14(%ebp),%eax
  80063d:	8d 50 04             	lea    0x4(%eax),%edx
  800640:	89 55 14             	mov    %edx,0x14(%ebp)
  800643:	8b 30                	mov    (%eax),%esi
  800645:	89 75 d8             	mov    %esi,-0x28(%ebp)
  800648:	89 f0                	mov    %esi,%eax
  80064a:	c1 f8 1f             	sar    $0x1f,%eax
  80064d:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800650:	eb 16                	jmp    800668 <vprintfmt+0x2bc>
	else
		return va_arg(*ap, int);
  800652:	8b 45 14             	mov    0x14(%ebp),%eax
  800655:	8d 50 04             	lea    0x4(%eax),%edx
  800658:	89 55 14             	mov    %edx,0x14(%ebp)
  80065b:	8b 30                	mov    (%eax),%esi
  80065d:	89 75 d8             	mov    %esi,-0x28(%ebp)
  800660:	89 f0                	mov    %esi,%eax
  800662:	c1 f8 1f             	sar    $0x1f,%eax
  800665:	89 45 dc             	mov    %eax,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800668:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80066b:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
  80066e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800672:	0f 89 8a 00 00 00    	jns    800702 <vprintfmt+0x356>
				putch('-', putdat);
  800678:	83 ec 08             	sub    $0x8,%esp
  80067b:	53                   	push   %ebx
  80067c:	6a 2d                	push   $0x2d
  80067e:	ff d7                	call   *%edi
				num = -(long long) num;
  800680:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800683:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800686:	f7 d8                	neg    %eax
  800688:	83 d2 00             	adc    $0x0,%edx
  80068b:	f7 da                	neg    %edx
  80068d:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800690:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800695:	eb 70                	jmp    800707 <vprintfmt+0x35b>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800697:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80069a:	8d 45 14             	lea    0x14(%ebp),%eax
  80069d:	e8 97 fc ff ff       	call   800339 <getuint>
			base = 10;
  8006a2:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8006a7:	eb 5e                	jmp    800707 <vprintfmt+0x35b>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
  8006a9:	83 ec 08             	sub    $0x8,%esp
  8006ac:	53                   	push   %ebx
  8006ad:	6a 30                	push   $0x30
  8006af:	ff d7                	call   *%edi
			num = getuint(&ap, lflag);
  8006b1:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8006b4:	8d 45 14             	lea    0x14(%ebp),%eax
  8006b7:	e8 7d fc ff ff       	call   800339 <getuint>
			base = 8;
			goto number;
  8006bc:	83 c4 10             	add    $0x10,%esp
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  8006bf:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8006c4:	eb 41                	jmp    800707 <vprintfmt+0x35b>
		// pointer
		case 'p':
			putch('0', putdat);
  8006c6:	83 ec 08             	sub    $0x8,%esp
  8006c9:	53                   	push   %ebx
  8006ca:	6a 30                	push   $0x30
  8006cc:	ff d7                	call   *%edi
			putch('x', putdat);
  8006ce:	83 c4 08             	add    $0x8,%esp
  8006d1:	53                   	push   %ebx
  8006d2:	6a 78                	push   $0x78
  8006d4:	ff d7                	call   *%edi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d9:	8d 50 04             	lea    0x4(%eax),%edx
  8006dc:	89 55 14             	mov    %edx,0x14(%ebp)
			goto number;
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006df:	8b 00                	mov    (%eax),%eax
  8006e1:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006e6:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006e9:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8006ee:	eb 17                	jmp    800707 <vprintfmt+0x35b>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006f0:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8006f3:	8d 45 14             	lea    0x14(%ebp),%eax
  8006f6:	e8 3e fc ff ff       	call   800339 <getuint>
			base = 16;
  8006fb:	b9 10 00 00 00       	mov    $0x10,%ecx
  800700:	eb 05                	jmp    800707 <vprintfmt+0x35b>
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800702:	b9 0a 00 00 00       	mov    $0xa,%ecx
		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  800707:	83 ec 0c             	sub    $0xc,%esp
  80070a:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  80070e:	56                   	push   %esi
  80070f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800712:	51                   	push   %ecx
  800713:	52                   	push   %edx
  800714:	50                   	push   %eax
  800715:	89 da                	mov    %ebx,%edx
  800717:	89 f8                	mov    %edi,%eax
  800719:	e8 6b fb ff ff       	call   800289 <printnum>
			break;
  80071e:	83 c4 20             	add    $0x20,%esp
  800721:	e9 9a fc ff ff       	jmp    8003c0 <vprintfmt+0x14>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800726:	83 ec 08             	sub    $0x8,%esp
  800729:	53                   	push   %ebx
  80072a:	52                   	push   %edx
  80072b:	ff d7                	call   *%edi
			break;
  80072d:	83 c4 10             	add    $0x10,%esp
  800730:	e9 8b fc ff ff       	jmp    8003c0 <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800735:	83 ec 08             	sub    $0x8,%esp
  800738:	53                   	push   %ebx
  800739:	6a 25                	push   $0x25
  80073b:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80073d:	83 c4 10             	add    $0x10,%esp
  800740:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800744:	0f 84 73 fc ff ff    	je     8003bd <vprintfmt+0x11>
  80074a:	4e                   	dec    %esi
  80074b:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80074f:	75 f9                	jne    80074a <vprintfmt+0x39e>
  800751:	89 75 10             	mov    %esi,0x10(%ebp)
  800754:	e9 67 fc ff ff       	jmp    8003c0 <vprintfmt+0x14>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800759:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80075c:	8d 70 01             	lea    0x1(%eax),%esi
  80075f:	8a 00                	mov    (%eax),%al
  800761:	0f be d0             	movsbl %al,%edx
  800764:	85 d2                	test   %edx,%edx
  800766:	0f 85 7a fe ff ff    	jne    8005e6 <vprintfmt+0x23a>
  80076c:	e9 4f fc ff ff       	jmp    8003c0 <vprintfmt+0x14>
  800771:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800774:	8d 70 01             	lea    0x1(%eax),%esi
  800777:	8a 00                	mov    (%eax),%al
  800779:	0f be d0             	movsbl %al,%edx
  80077c:	85 d2                	test   %edx,%edx
  80077e:	0f 85 6a fe ff ff    	jne    8005ee <vprintfmt+0x242>
  800784:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800787:	e9 77 fe ff ff       	jmp    800603 <vprintfmt+0x257>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  80078c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80078f:	5b                   	pop    %ebx
  800790:	5e                   	pop    %esi
  800791:	5f                   	pop    %edi
  800792:	5d                   	pop    %ebp
  800793:	c3                   	ret    

00800794 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800794:	55                   	push   %ebp
  800795:	89 e5                	mov    %esp,%ebp
  800797:	83 ec 18             	sub    $0x18,%esp
  80079a:	8b 45 08             	mov    0x8(%ebp),%eax
  80079d:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007a0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007a3:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007a7:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007aa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007b1:	85 c0                	test   %eax,%eax
  8007b3:	74 26                	je     8007db <vsnprintf+0x47>
  8007b5:	85 d2                	test   %edx,%edx
  8007b7:	7e 29                	jle    8007e2 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007b9:	ff 75 14             	pushl  0x14(%ebp)
  8007bc:	ff 75 10             	pushl  0x10(%ebp)
  8007bf:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007c2:	50                   	push   %eax
  8007c3:	68 73 03 80 00       	push   $0x800373
  8007c8:	e8 df fb ff ff       	call   8003ac <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007cd:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007d0:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007d6:	83 c4 10             	add    $0x10,%esp
  8007d9:	eb 0c                	jmp    8007e7 <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007db:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007e0:	eb 05                	jmp    8007e7 <vsnprintf+0x53>
  8007e2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007e7:	c9                   	leave  
  8007e8:	c3                   	ret    

008007e9 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007e9:	55                   	push   %ebp
  8007ea:	89 e5                	mov    %esp,%ebp
  8007ec:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007ef:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007f2:	50                   	push   %eax
  8007f3:	ff 75 10             	pushl  0x10(%ebp)
  8007f6:	ff 75 0c             	pushl  0xc(%ebp)
  8007f9:	ff 75 08             	pushl  0x8(%ebp)
  8007fc:	e8 93 ff ff ff       	call   800794 <vsnprintf>
	va_end(ap);

	return rc;
}
  800801:	c9                   	leave  
  800802:	c3                   	ret    

00800803 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800803:	55                   	push   %ebp
  800804:	89 e5                	mov    %esp,%ebp
  800806:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800809:	80 3a 00             	cmpb   $0x0,(%edx)
  80080c:	74 0e                	je     80081c <strlen+0x19>
  80080e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800813:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800814:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800818:	75 f9                	jne    800813 <strlen+0x10>
  80081a:	eb 05                	jmp    800821 <strlen+0x1e>
  80081c:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800821:	5d                   	pop    %ebp
  800822:	c3                   	ret    

00800823 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800823:	55                   	push   %ebp
  800824:	89 e5                	mov    %esp,%ebp
  800826:	53                   	push   %ebx
  800827:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80082a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80082d:	85 c9                	test   %ecx,%ecx
  80082f:	74 1a                	je     80084b <strnlen+0x28>
  800831:	80 3b 00             	cmpb   $0x0,(%ebx)
  800834:	74 1c                	je     800852 <strnlen+0x2f>
  800836:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  80083b:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80083d:	39 ca                	cmp    %ecx,%edx
  80083f:	74 16                	je     800857 <strnlen+0x34>
  800841:	42                   	inc    %edx
  800842:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800847:	75 f2                	jne    80083b <strnlen+0x18>
  800849:	eb 0c                	jmp    800857 <strnlen+0x34>
  80084b:	b8 00 00 00 00       	mov    $0x0,%eax
  800850:	eb 05                	jmp    800857 <strnlen+0x34>
  800852:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800857:	5b                   	pop    %ebx
  800858:	5d                   	pop    %ebp
  800859:	c3                   	ret    

0080085a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80085a:	55                   	push   %ebp
  80085b:	89 e5                	mov    %esp,%ebp
  80085d:	53                   	push   %ebx
  80085e:	8b 45 08             	mov    0x8(%ebp),%eax
  800861:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800864:	89 c2                	mov    %eax,%edx
  800866:	42                   	inc    %edx
  800867:	41                   	inc    %ecx
  800868:	8a 59 ff             	mov    -0x1(%ecx),%bl
  80086b:	88 5a ff             	mov    %bl,-0x1(%edx)
  80086e:	84 db                	test   %bl,%bl
  800870:	75 f4                	jne    800866 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800872:	5b                   	pop    %ebx
  800873:	5d                   	pop    %ebp
  800874:	c3                   	ret    

00800875 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800875:	55                   	push   %ebp
  800876:	89 e5                	mov    %esp,%ebp
  800878:	53                   	push   %ebx
  800879:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80087c:	53                   	push   %ebx
  80087d:	e8 81 ff ff ff       	call   800803 <strlen>
  800882:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800885:	ff 75 0c             	pushl  0xc(%ebp)
  800888:	01 d8                	add    %ebx,%eax
  80088a:	50                   	push   %eax
  80088b:	e8 ca ff ff ff       	call   80085a <strcpy>
	return dst;
}
  800890:	89 d8                	mov    %ebx,%eax
  800892:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800895:	c9                   	leave  
  800896:	c3                   	ret    

00800897 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800897:	55                   	push   %ebp
  800898:	89 e5                	mov    %esp,%ebp
  80089a:	56                   	push   %esi
  80089b:	53                   	push   %ebx
  80089c:	8b 75 08             	mov    0x8(%ebp),%esi
  80089f:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008a2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008a5:	85 db                	test   %ebx,%ebx
  8008a7:	74 14                	je     8008bd <strncpy+0x26>
  8008a9:	01 f3                	add    %esi,%ebx
  8008ab:	89 f1                	mov    %esi,%ecx
		*dst++ = *src;
  8008ad:	41                   	inc    %ecx
  8008ae:	8a 02                	mov    (%edx),%al
  8008b0:	88 41 ff             	mov    %al,-0x1(%ecx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008b3:	80 3a 01             	cmpb   $0x1,(%edx)
  8008b6:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008b9:	39 cb                	cmp    %ecx,%ebx
  8008bb:	75 f0                	jne    8008ad <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008bd:	89 f0                	mov    %esi,%eax
  8008bf:	5b                   	pop    %ebx
  8008c0:	5e                   	pop    %esi
  8008c1:	5d                   	pop    %ebp
  8008c2:	c3                   	ret    

008008c3 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008c3:	55                   	push   %ebp
  8008c4:	89 e5                	mov    %esp,%ebp
  8008c6:	53                   	push   %ebx
  8008c7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8008ca:	8b 45 10             	mov    0x10(%ebp),%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008cd:	85 c0                	test   %eax,%eax
  8008cf:	74 30                	je     800901 <strlcpy+0x3e>
		while (--size > 0 && *src != '\0')
  8008d1:	48                   	dec    %eax
  8008d2:	74 20                	je     8008f4 <strlcpy+0x31>
  8008d4:	8a 0b                	mov    (%ebx),%cl
  8008d6:	84 c9                	test   %cl,%cl
  8008d8:	74 1f                	je     8008f9 <strlcpy+0x36>
  8008da:	8d 53 01             	lea    0x1(%ebx),%edx
  8008dd:	01 c3                	add    %eax,%ebx
  8008df:	8b 45 08             	mov    0x8(%ebp),%eax
			*dst++ = *src++;
  8008e2:	40                   	inc    %eax
  8008e3:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008e6:	39 da                	cmp    %ebx,%edx
  8008e8:	74 12                	je     8008fc <strlcpy+0x39>
  8008ea:	42                   	inc    %edx
  8008eb:	8a 4a ff             	mov    -0x1(%edx),%cl
  8008ee:	84 c9                	test   %cl,%cl
  8008f0:	75 f0                	jne    8008e2 <strlcpy+0x1f>
  8008f2:	eb 08                	jmp    8008fc <strlcpy+0x39>
  8008f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f7:	eb 03                	jmp    8008fc <strlcpy+0x39>
  8008f9:	8b 45 08             	mov    0x8(%ebp),%eax
			*dst++ = *src++;
		*dst = '\0';
  8008fc:	c6 00 00             	movb   $0x0,(%eax)
  8008ff:	eb 03                	jmp    800904 <strlcpy+0x41>
  800901:	8b 45 08             	mov    0x8(%ebp),%eax
	}
	return dst - dst_in;
  800904:	2b 45 08             	sub    0x8(%ebp),%eax
}
  800907:	5b                   	pop    %ebx
  800908:	5d                   	pop    %ebp
  800909:	c3                   	ret    

0080090a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80090a:	55                   	push   %ebp
  80090b:	89 e5                	mov    %esp,%ebp
  80090d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800910:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800913:	8a 01                	mov    (%ecx),%al
  800915:	84 c0                	test   %al,%al
  800917:	74 10                	je     800929 <strcmp+0x1f>
  800919:	3a 02                	cmp    (%edx),%al
  80091b:	75 0c                	jne    800929 <strcmp+0x1f>
		p++, q++;
  80091d:	41                   	inc    %ecx
  80091e:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80091f:	8a 01                	mov    (%ecx),%al
  800921:	84 c0                	test   %al,%al
  800923:	74 04                	je     800929 <strcmp+0x1f>
  800925:	3a 02                	cmp    (%edx),%al
  800927:	74 f4                	je     80091d <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800929:	0f b6 c0             	movzbl %al,%eax
  80092c:	0f b6 12             	movzbl (%edx),%edx
  80092f:	29 d0                	sub    %edx,%eax
}
  800931:	5d                   	pop    %ebp
  800932:	c3                   	ret    

00800933 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800933:	55                   	push   %ebp
  800934:	89 e5                	mov    %esp,%ebp
  800936:	56                   	push   %esi
  800937:	53                   	push   %ebx
  800938:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80093b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80093e:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  800941:	85 f6                	test   %esi,%esi
  800943:	74 23                	je     800968 <strncmp+0x35>
  800945:	8a 03                	mov    (%ebx),%al
  800947:	84 c0                	test   %al,%al
  800949:	74 2b                	je     800976 <strncmp+0x43>
  80094b:	3a 02                	cmp    (%edx),%al
  80094d:	75 27                	jne    800976 <strncmp+0x43>
  80094f:	8d 43 01             	lea    0x1(%ebx),%eax
  800952:	01 de                	add    %ebx,%esi
		n--, p++, q++;
  800954:	89 c3                	mov    %eax,%ebx
  800956:	42                   	inc    %edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800957:	39 c6                	cmp    %eax,%esi
  800959:	74 14                	je     80096f <strncmp+0x3c>
  80095b:	8a 08                	mov    (%eax),%cl
  80095d:	84 c9                	test   %cl,%cl
  80095f:	74 15                	je     800976 <strncmp+0x43>
  800961:	40                   	inc    %eax
  800962:	3a 0a                	cmp    (%edx),%cl
  800964:	74 ee                	je     800954 <strncmp+0x21>
  800966:	eb 0e                	jmp    800976 <strncmp+0x43>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800968:	b8 00 00 00 00       	mov    $0x0,%eax
  80096d:	eb 0f                	jmp    80097e <strncmp+0x4b>
  80096f:	b8 00 00 00 00       	mov    $0x0,%eax
  800974:	eb 08                	jmp    80097e <strncmp+0x4b>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800976:	0f b6 03             	movzbl (%ebx),%eax
  800979:	0f b6 12             	movzbl (%edx),%edx
  80097c:	29 d0                	sub    %edx,%eax
}
  80097e:	5b                   	pop    %ebx
  80097f:	5e                   	pop    %esi
  800980:	5d                   	pop    %ebp
  800981:	c3                   	ret    

00800982 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800982:	55                   	push   %ebp
  800983:	89 e5                	mov    %esp,%ebp
  800985:	53                   	push   %ebx
  800986:	8b 45 08             	mov    0x8(%ebp),%eax
  800989:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  80098c:	8a 10                	mov    (%eax),%dl
  80098e:	84 d2                	test   %dl,%dl
  800990:	74 1a                	je     8009ac <strchr+0x2a>
  800992:	88 d9                	mov    %bl,%cl
		if (*s == c)
  800994:	38 d3                	cmp    %dl,%bl
  800996:	75 06                	jne    80099e <strchr+0x1c>
  800998:	eb 17                	jmp    8009b1 <strchr+0x2f>
  80099a:	38 ca                	cmp    %cl,%dl
  80099c:	74 13                	je     8009b1 <strchr+0x2f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80099e:	40                   	inc    %eax
  80099f:	8a 10                	mov    (%eax),%dl
  8009a1:	84 d2                	test   %dl,%dl
  8009a3:	75 f5                	jne    80099a <strchr+0x18>
		if (*s == c)
			return (char *) s;
	return 0;
  8009a5:	b8 00 00 00 00       	mov    $0x0,%eax
  8009aa:	eb 05                	jmp    8009b1 <strchr+0x2f>
  8009ac:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009b1:	5b                   	pop    %ebx
  8009b2:	5d                   	pop    %ebp
  8009b3:	c3                   	ret    

008009b4 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009b4:	55                   	push   %ebp
  8009b5:	89 e5                	mov    %esp,%ebp
  8009b7:	53                   	push   %ebx
  8009b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009bb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  8009be:	8a 10                	mov    (%eax),%dl
  8009c0:	84 d2                	test   %dl,%dl
  8009c2:	74 13                	je     8009d7 <strfind+0x23>
  8009c4:	88 d9                	mov    %bl,%cl
		if (*s == c)
  8009c6:	38 d3                	cmp    %dl,%bl
  8009c8:	75 06                	jne    8009d0 <strfind+0x1c>
  8009ca:	eb 0b                	jmp    8009d7 <strfind+0x23>
  8009cc:	38 ca                	cmp    %cl,%dl
  8009ce:	74 07                	je     8009d7 <strfind+0x23>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8009d0:	40                   	inc    %eax
  8009d1:	8a 10                	mov    (%eax),%dl
  8009d3:	84 d2                	test   %dl,%dl
  8009d5:	75 f5                	jne    8009cc <strfind+0x18>
		if (*s == c)
			break;
	return (char *) s;
}
  8009d7:	5b                   	pop    %ebx
  8009d8:	5d                   	pop    %ebp
  8009d9:	c3                   	ret    

008009da <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009da:	55                   	push   %ebp
  8009db:	89 e5                	mov    %esp,%ebp
  8009dd:	57                   	push   %edi
  8009de:	56                   	push   %esi
  8009df:	53                   	push   %ebx
  8009e0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009e3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009e6:	85 c9                	test   %ecx,%ecx
  8009e8:	74 36                	je     800a20 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009ea:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009f0:	75 28                	jne    800a1a <memset+0x40>
  8009f2:	f6 c1 03             	test   $0x3,%cl
  8009f5:	75 23                	jne    800a1a <memset+0x40>
		c &= 0xFF;
  8009f7:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009fb:	89 d3                	mov    %edx,%ebx
  8009fd:	c1 e3 08             	shl    $0x8,%ebx
  800a00:	89 d6                	mov    %edx,%esi
  800a02:	c1 e6 18             	shl    $0x18,%esi
  800a05:	89 d0                	mov    %edx,%eax
  800a07:	c1 e0 10             	shl    $0x10,%eax
  800a0a:	09 f0                	or     %esi,%eax
  800a0c:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800a0e:	89 d8                	mov    %ebx,%eax
  800a10:	09 d0                	or     %edx,%eax
  800a12:	c1 e9 02             	shr    $0x2,%ecx
  800a15:	fc                   	cld    
  800a16:	f3 ab                	rep stos %eax,%es:(%edi)
  800a18:	eb 06                	jmp    800a20 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a1a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a1d:	fc                   	cld    
  800a1e:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a20:	89 f8                	mov    %edi,%eax
  800a22:	5b                   	pop    %ebx
  800a23:	5e                   	pop    %esi
  800a24:	5f                   	pop    %edi
  800a25:	5d                   	pop    %ebp
  800a26:	c3                   	ret    

00800a27 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a27:	55                   	push   %ebp
  800a28:	89 e5                	mov    %esp,%ebp
  800a2a:	57                   	push   %edi
  800a2b:	56                   	push   %esi
  800a2c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a32:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a35:	39 c6                	cmp    %eax,%esi
  800a37:	73 33                	jae    800a6c <memmove+0x45>
  800a39:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a3c:	39 d0                	cmp    %edx,%eax
  800a3e:	73 2c                	jae    800a6c <memmove+0x45>
		s += n;
		d += n;
  800a40:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a43:	89 d6                	mov    %edx,%esi
  800a45:	09 fe                	or     %edi,%esi
  800a47:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a4d:	75 13                	jne    800a62 <memmove+0x3b>
  800a4f:	f6 c1 03             	test   $0x3,%cl
  800a52:	75 0e                	jne    800a62 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800a54:	83 ef 04             	sub    $0x4,%edi
  800a57:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a5a:	c1 e9 02             	shr    $0x2,%ecx
  800a5d:	fd                   	std    
  800a5e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a60:	eb 07                	jmp    800a69 <memmove+0x42>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a62:	4f                   	dec    %edi
  800a63:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a66:	fd                   	std    
  800a67:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a69:	fc                   	cld    
  800a6a:	eb 1d                	jmp    800a89 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a6c:	89 f2                	mov    %esi,%edx
  800a6e:	09 c2                	or     %eax,%edx
  800a70:	f6 c2 03             	test   $0x3,%dl
  800a73:	75 0f                	jne    800a84 <memmove+0x5d>
  800a75:	f6 c1 03             	test   $0x3,%cl
  800a78:	75 0a                	jne    800a84 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
  800a7a:	c1 e9 02             	shr    $0x2,%ecx
  800a7d:	89 c7                	mov    %eax,%edi
  800a7f:	fc                   	cld    
  800a80:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a82:	eb 05                	jmp    800a89 <memmove+0x62>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a84:	89 c7                	mov    %eax,%edi
  800a86:	fc                   	cld    
  800a87:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a89:	5e                   	pop    %esi
  800a8a:	5f                   	pop    %edi
  800a8b:	5d                   	pop    %ebp
  800a8c:	c3                   	ret    

00800a8d <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a8d:	55                   	push   %ebp
  800a8e:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a90:	ff 75 10             	pushl  0x10(%ebp)
  800a93:	ff 75 0c             	pushl  0xc(%ebp)
  800a96:	ff 75 08             	pushl  0x8(%ebp)
  800a99:	e8 89 ff ff ff       	call   800a27 <memmove>
}
  800a9e:	c9                   	leave  
  800a9f:	c3                   	ret    

00800aa0 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800aa0:	55                   	push   %ebp
  800aa1:	89 e5                	mov    %esp,%ebp
  800aa3:	57                   	push   %edi
  800aa4:	56                   	push   %esi
  800aa5:	53                   	push   %ebx
  800aa6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800aa9:	8b 75 0c             	mov    0xc(%ebp),%esi
  800aac:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800aaf:	85 c0                	test   %eax,%eax
  800ab1:	74 33                	je     800ae6 <memcmp+0x46>
  800ab3:	8d 78 ff             	lea    -0x1(%eax),%edi
		if (*s1 != *s2)
  800ab6:	8a 13                	mov    (%ebx),%dl
  800ab8:	8a 0e                	mov    (%esi),%cl
  800aba:	38 ca                	cmp    %cl,%dl
  800abc:	75 13                	jne    800ad1 <memcmp+0x31>
  800abe:	b8 00 00 00 00       	mov    $0x0,%eax
  800ac3:	eb 16                	jmp    800adb <memcmp+0x3b>
  800ac5:	8a 54 03 01          	mov    0x1(%ebx,%eax,1),%dl
  800ac9:	40                   	inc    %eax
  800aca:	8a 0c 06             	mov    (%esi,%eax,1),%cl
  800acd:	38 ca                	cmp    %cl,%dl
  800acf:	74 0a                	je     800adb <memcmp+0x3b>
			return (int) *s1 - (int) *s2;
  800ad1:	0f b6 c2             	movzbl %dl,%eax
  800ad4:	0f b6 c9             	movzbl %cl,%ecx
  800ad7:	29 c8                	sub    %ecx,%eax
  800ad9:	eb 10                	jmp    800aeb <memcmp+0x4b>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800adb:	39 f8                	cmp    %edi,%eax
  800add:	75 e6                	jne    800ac5 <memcmp+0x25>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800adf:	b8 00 00 00 00       	mov    $0x0,%eax
  800ae4:	eb 05                	jmp    800aeb <memcmp+0x4b>
  800ae6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800aeb:	5b                   	pop    %ebx
  800aec:	5e                   	pop    %esi
  800aed:	5f                   	pop    %edi
  800aee:	5d                   	pop    %ebp
  800aef:	c3                   	ret    

00800af0 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800af0:	55                   	push   %ebp
  800af1:	89 e5                	mov    %esp,%ebp
  800af3:	53                   	push   %ebx
  800af4:	8b 55 08             	mov    0x8(%ebp),%edx
	const void *ends = (const char *) s + n;
  800af7:	89 d0                	mov    %edx,%eax
  800af9:	03 45 10             	add    0x10(%ebp),%eax
	for (; s < ends; s++)
  800afc:	39 c2                	cmp    %eax,%edx
  800afe:	73 1b                	jae    800b1b <memfind+0x2b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b00:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
  800b04:	0f b6 0a             	movzbl (%edx),%ecx
  800b07:	39 d9                	cmp    %ebx,%ecx
  800b09:	75 09                	jne    800b14 <memfind+0x24>
  800b0b:	eb 12                	jmp    800b1f <memfind+0x2f>
  800b0d:	0f b6 0a             	movzbl (%edx),%ecx
  800b10:	39 d9                	cmp    %ebx,%ecx
  800b12:	74 0f                	je     800b23 <memfind+0x33>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b14:	42                   	inc    %edx
  800b15:	39 d0                	cmp    %edx,%eax
  800b17:	75 f4                	jne    800b0d <memfind+0x1d>
  800b19:	eb 0a                	jmp    800b25 <memfind+0x35>
  800b1b:	89 d0                	mov    %edx,%eax
  800b1d:	eb 06                	jmp    800b25 <memfind+0x35>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b1f:	89 d0                	mov    %edx,%eax
  800b21:	eb 02                	jmp    800b25 <memfind+0x35>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b23:	89 d0                	mov    %edx,%eax
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b25:	5b                   	pop    %ebx
  800b26:	5d                   	pop    %ebp
  800b27:	c3                   	ret    

00800b28 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b28:	55                   	push   %ebp
  800b29:	89 e5                	mov    %esp,%ebp
  800b2b:	57                   	push   %edi
  800b2c:	56                   	push   %esi
  800b2d:	53                   	push   %ebx
  800b2e:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b31:	eb 01                	jmp    800b34 <strtol+0xc>
		s++;
  800b33:	41                   	inc    %ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b34:	8a 01                	mov    (%ecx),%al
  800b36:	3c 20                	cmp    $0x20,%al
  800b38:	74 f9                	je     800b33 <strtol+0xb>
  800b3a:	3c 09                	cmp    $0x9,%al
  800b3c:	74 f5                	je     800b33 <strtol+0xb>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b3e:	3c 2b                	cmp    $0x2b,%al
  800b40:	75 08                	jne    800b4a <strtol+0x22>
		s++;
  800b42:	41                   	inc    %ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b43:	bf 00 00 00 00       	mov    $0x0,%edi
  800b48:	eb 11                	jmp    800b5b <strtol+0x33>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b4a:	3c 2d                	cmp    $0x2d,%al
  800b4c:	75 08                	jne    800b56 <strtol+0x2e>
		s++, neg = 1;
  800b4e:	41                   	inc    %ecx
  800b4f:	bf 01 00 00 00       	mov    $0x1,%edi
  800b54:	eb 05                	jmp    800b5b <strtol+0x33>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b56:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b5b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800b5f:	0f 84 87 00 00 00    	je     800bec <strtol+0xc4>
  800b65:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  800b69:	75 27                	jne    800b92 <strtol+0x6a>
  800b6b:	80 39 30             	cmpb   $0x30,(%ecx)
  800b6e:	75 22                	jne    800b92 <strtol+0x6a>
  800b70:	e9 88 00 00 00       	jmp    800bfd <strtol+0xd5>
		s += 2, base = 16;
  800b75:	83 c1 02             	add    $0x2,%ecx
  800b78:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  800b7f:	eb 11                	jmp    800b92 <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
  800b81:	41                   	inc    %ecx
  800b82:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  800b89:	eb 07                	jmp    800b92 <strtol+0x6a>
	else if (base == 0)
		base = 10;
  800b8b:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)
  800b92:	b8 00 00 00 00       	mov    $0x0,%eax

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b97:	8a 11                	mov    (%ecx),%dl
  800b99:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800b9c:	80 fb 09             	cmp    $0x9,%bl
  800b9f:	77 08                	ja     800ba9 <strtol+0x81>
			dig = *s - '0';
  800ba1:	0f be d2             	movsbl %dl,%edx
  800ba4:	83 ea 30             	sub    $0x30,%edx
  800ba7:	eb 22                	jmp    800bcb <strtol+0xa3>
		else if (*s >= 'a' && *s <= 'z')
  800ba9:	8d 72 9f             	lea    -0x61(%edx),%esi
  800bac:	89 f3                	mov    %esi,%ebx
  800bae:	80 fb 19             	cmp    $0x19,%bl
  800bb1:	77 08                	ja     800bbb <strtol+0x93>
			dig = *s - 'a' + 10;
  800bb3:	0f be d2             	movsbl %dl,%edx
  800bb6:	83 ea 57             	sub    $0x57,%edx
  800bb9:	eb 10                	jmp    800bcb <strtol+0xa3>
		else if (*s >= 'A' && *s <= 'Z')
  800bbb:	8d 72 bf             	lea    -0x41(%edx),%esi
  800bbe:	89 f3                	mov    %esi,%ebx
  800bc0:	80 fb 19             	cmp    $0x19,%bl
  800bc3:	77 14                	ja     800bd9 <strtol+0xb1>
			dig = *s - 'A' + 10;
  800bc5:	0f be d2             	movsbl %dl,%edx
  800bc8:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800bcb:	3b 55 10             	cmp    0x10(%ebp),%edx
  800bce:	7d 09                	jge    800bd9 <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800bd0:	41                   	inc    %ecx
  800bd1:	0f af 45 10          	imul   0x10(%ebp),%eax
  800bd5:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800bd7:	eb be                	jmp    800b97 <strtol+0x6f>

	if (endptr)
  800bd9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bdd:	74 05                	je     800be4 <strtol+0xbc>
		*endptr = (char *) s;
  800bdf:	8b 75 0c             	mov    0xc(%ebp),%esi
  800be2:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800be4:	85 ff                	test   %edi,%edi
  800be6:	74 21                	je     800c09 <strtol+0xe1>
  800be8:	f7 d8                	neg    %eax
  800bea:	eb 1d                	jmp    800c09 <strtol+0xe1>
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bec:	80 39 30             	cmpb   $0x30,(%ecx)
  800bef:	75 9a                	jne    800b8b <strtol+0x63>
  800bf1:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800bf5:	0f 84 7a ff ff ff    	je     800b75 <strtol+0x4d>
  800bfb:	eb 84                	jmp    800b81 <strtol+0x59>
  800bfd:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c01:	0f 84 6e ff ff ff    	je     800b75 <strtol+0x4d>
  800c07:	eb 89                	jmp    800b92 <strtol+0x6a>
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
}
  800c09:	5b                   	pop    %ebx
  800c0a:	5e                   	pop    %esi
  800c0b:	5f                   	pop    %edi
  800c0c:	5d                   	pop    %ebp
  800c0d:	c3                   	ret    

00800c0e <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c0e:	55                   	push   %ebp
  800c0f:	89 e5                	mov    %esp,%ebp
  800c11:	57                   	push   %edi
  800c12:	56                   	push   %esi
  800c13:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c14:	b8 00 00 00 00       	mov    $0x0,%eax
  800c19:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c1c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c1f:	89 c3                	mov    %eax,%ebx
  800c21:	89 c7                	mov    %eax,%edi
  800c23:	89 c6                	mov    %eax,%esi
  800c25:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c27:	5b                   	pop    %ebx
  800c28:	5e                   	pop    %esi
  800c29:	5f                   	pop    %edi
  800c2a:	5d                   	pop    %ebp
  800c2b:	c3                   	ret    

00800c2c <sys_cgetc>:

int
sys_cgetc(void)
{
  800c2c:	55                   	push   %ebp
  800c2d:	89 e5                	mov    %esp,%ebp
  800c2f:	57                   	push   %edi
  800c30:	56                   	push   %esi
  800c31:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c32:	ba 00 00 00 00       	mov    $0x0,%edx
  800c37:	b8 01 00 00 00       	mov    $0x1,%eax
  800c3c:	89 d1                	mov    %edx,%ecx
  800c3e:	89 d3                	mov    %edx,%ebx
  800c40:	89 d7                	mov    %edx,%edi
  800c42:	89 d6                	mov    %edx,%esi
  800c44:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c46:	5b                   	pop    %ebx
  800c47:	5e                   	pop    %esi
  800c48:	5f                   	pop    %edi
  800c49:	5d                   	pop    %ebp
  800c4a:	c3                   	ret    

00800c4b <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c4b:	55                   	push   %ebp
  800c4c:	89 e5                	mov    %esp,%ebp
  800c4e:	57                   	push   %edi
  800c4f:	56                   	push   %esi
  800c50:	53                   	push   %ebx
  800c51:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c54:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c59:	b8 03 00 00 00       	mov    $0x3,%eax
  800c5e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c61:	89 cb                	mov    %ecx,%ebx
  800c63:	89 cf                	mov    %ecx,%edi
  800c65:	89 ce                	mov    %ecx,%esi
  800c67:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c69:	85 c0                	test   %eax,%eax
  800c6b:	7e 17                	jle    800c84 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c6d:	83 ec 0c             	sub    $0xc,%esp
  800c70:	50                   	push   %eax
  800c71:	6a 03                	push   $0x3
  800c73:	68 bf 28 80 00       	push   $0x8028bf
  800c78:	6a 23                	push   $0x23
  800c7a:	68 dc 28 80 00       	push   $0x8028dc
  800c7f:	e8 19 f5 ff ff       	call   80019d <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c84:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c87:	5b                   	pop    %ebx
  800c88:	5e                   	pop    %esi
  800c89:	5f                   	pop    %edi
  800c8a:	5d                   	pop    %ebp
  800c8b:	c3                   	ret    

00800c8c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c8c:	55                   	push   %ebp
  800c8d:	89 e5                	mov    %esp,%ebp
  800c8f:	57                   	push   %edi
  800c90:	56                   	push   %esi
  800c91:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c92:	ba 00 00 00 00       	mov    $0x0,%edx
  800c97:	b8 02 00 00 00       	mov    $0x2,%eax
  800c9c:	89 d1                	mov    %edx,%ecx
  800c9e:	89 d3                	mov    %edx,%ebx
  800ca0:	89 d7                	mov    %edx,%edi
  800ca2:	89 d6                	mov    %edx,%esi
  800ca4:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800ca6:	5b                   	pop    %ebx
  800ca7:	5e                   	pop    %esi
  800ca8:	5f                   	pop    %edi
  800ca9:	5d                   	pop    %ebp
  800caa:	c3                   	ret    

00800cab <sys_yield>:

void
sys_yield(void)
{
  800cab:	55                   	push   %ebp
  800cac:	89 e5                	mov    %esp,%ebp
  800cae:	57                   	push   %edi
  800caf:	56                   	push   %esi
  800cb0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cb1:	ba 00 00 00 00       	mov    $0x0,%edx
  800cb6:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cbb:	89 d1                	mov    %edx,%ecx
  800cbd:	89 d3                	mov    %edx,%ebx
  800cbf:	89 d7                	mov    %edx,%edi
  800cc1:	89 d6                	mov    %edx,%esi
  800cc3:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800cc5:	5b                   	pop    %ebx
  800cc6:	5e                   	pop    %esi
  800cc7:	5f                   	pop    %edi
  800cc8:	5d                   	pop    %ebp
  800cc9:	c3                   	ret    

00800cca <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800cca:	55                   	push   %ebp
  800ccb:	89 e5                	mov    %esp,%ebp
  800ccd:	57                   	push   %edi
  800cce:	56                   	push   %esi
  800ccf:	53                   	push   %ebx
  800cd0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cd3:	be 00 00 00 00       	mov    $0x0,%esi
  800cd8:	b8 04 00 00 00       	mov    $0x4,%eax
  800cdd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ce6:	89 f7                	mov    %esi,%edi
  800ce8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cea:	85 c0                	test   %eax,%eax
  800cec:	7e 17                	jle    800d05 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cee:	83 ec 0c             	sub    $0xc,%esp
  800cf1:	50                   	push   %eax
  800cf2:	6a 04                	push   $0x4
  800cf4:	68 bf 28 80 00       	push   $0x8028bf
  800cf9:	6a 23                	push   $0x23
  800cfb:	68 dc 28 80 00       	push   $0x8028dc
  800d00:	e8 98 f4 ff ff       	call   80019d <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d05:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d08:	5b                   	pop    %ebx
  800d09:	5e                   	pop    %esi
  800d0a:	5f                   	pop    %edi
  800d0b:	5d                   	pop    %ebp
  800d0c:	c3                   	ret    

00800d0d <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d0d:	55                   	push   %ebp
  800d0e:	89 e5                	mov    %esp,%ebp
  800d10:	57                   	push   %edi
  800d11:	56                   	push   %esi
  800d12:	53                   	push   %ebx
  800d13:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d16:	b8 05 00 00 00       	mov    $0x5,%eax
  800d1b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d1e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d21:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d24:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d27:	8b 75 18             	mov    0x18(%ebp),%esi
  800d2a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d2c:	85 c0                	test   %eax,%eax
  800d2e:	7e 17                	jle    800d47 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d30:	83 ec 0c             	sub    $0xc,%esp
  800d33:	50                   	push   %eax
  800d34:	6a 05                	push   $0x5
  800d36:	68 bf 28 80 00       	push   $0x8028bf
  800d3b:	6a 23                	push   $0x23
  800d3d:	68 dc 28 80 00       	push   $0x8028dc
  800d42:	e8 56 f4 ff ff       	call   80019d <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d47:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d4a:	5b                   	pop    %ebx
  800d4b:	5e                   	pop    %esi
  800d4c:	5f                   	pop    %edi
  800d4d:	5d                   	pop    %ebp
  800d4e:	c3                   	ret    

00800d4f <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d4f:	55                   	push   %ebp
  800d50:	89 e5                	mov    %esp,%ebp
  800d52:	57                   	push   %edi
  800d53:	56                   	push   %esi
  800d54:	53                   	push   %ebx
  800d55:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d58:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d5d:	b8 06 00 00 00       	mov    $0x6,%eax
  800d62:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d65:	8b 55 08             	mov    0x8(%ebp),%edx
  800d68:	89 df                	mov    %ebx,%edi
  800d6a:	89 de                	mov    %ebx,%esi
  800d6c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d6e:	85 c0                	test   %eax,%eax
  800d70:	7e 17                	jle    800d89 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d72:	83 ec 0c             	sub    $0xc,%esp
  800d75:	50                   	push   %eax
  800d76:	6a 06                	push   $0x6
  800d78:	68 bf 28 80 00       	push   $0x8028bf
  800d7d:	6a 23                	push   $0x23
  800d7f:	68 dc 28 80 00       	push   $0x8028dc
  800d84:	e8 14 f4 ff ff       	call   80019d <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d89:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d8c:	5b                   	pop    %ebx
  800d8d:	5e                   	pop    %esi
  800d8e:	5f                   	pop    %edi
  800d8f:	5d                   	pop    %ebp
  800d90:	c3                   	ret    

00800d91 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
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
  800d9a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d9f:	b8 08 00 00 00       	mov    $0x8,%eax
  800da4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800da7:	8b 55 08             	mov    0x8(%ebp),%edx
  800daa:	89 df                	mov    %ebx,%edi
  800dac:	89 de                	mov    %ebx,%esi
  800dae:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800db0:	85 c0                	test   %eax,%eax
  800db2:	7e 17                	jle    800dcb <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800db4:	83 ec 0c             	sub    $0xc,%esp
  800db7:	50                   	push   %eax
  800db8:	6a 08                	push   $0x8
  800dba:	68 bf 28 80 00       	push   $0x8028bf
  800dbf:	6a 23                	push   $0x23
  800dc1:	68 dc 28 80 00       	push   $0x8028dc
  800dc6:	e8 d2 f3 ff ff       	call   80019d <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800dcb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dce:	5b                   	pop    %ebx
  800dcf:	5e                   	pop    %esi
  800dd0:	5f                   	pop    %edi
  800dd1:	5d                   	pop    %ebp
  800dd2:	c3                   	ret    

00800dd3 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
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
  800de1:	b8 09 00 00 00       	mov    $0x9,%eax
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
  800df4:	7e 17                	jle    800e0d <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800df6:	83 ec 0c             	sub    $0xc,%esp
  800df9:	50                   	push   %eax
  800dfa:	6a 09                	push   $0x9
  800dfc:	68 bf 28 80 00       	push   $0x8028bf
  800e01:	6a 23                	push   $0x23
  800e03:	68 dc 28 80 00       	push   $0x8028dc
  800e08:	e8 90 f3 ff ff       	call   80019d <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e0d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e10:	5b                   	pop    %ebx
  800e11:	5e                   	pop    %esi
  800e12:	5f                   	pop    %edi
  800e13:	5d                   	pop    %ebp
  800e14:	c3                   	ret    

00800e15 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
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
  800e23:	b8 0a 00 00 00       	mov    $0xa,%eax
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
  800e36:	7e 17                	jle    800e4f <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e38:	83 ec 0c             	sub    $0xc,%esp
  800e3b:	50                   	push   %eax
  800e3c:	6a 0a                	push   $0xa
  800e3e:	68 bf 28 80 00       	push   $0x8028bf
  800e43:	6a 23                	push   $0x23
  800e45:	68 dc 28 80 00       	push   $0x8028dc
  800e4a:	e8 4e f3 ff ff       	call   80019d <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e4f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e52:	5b                   	pop    %ebx
  800e53:	5e                   	pop    %esi
  800e54:	5f                   	pop    %edi
  800e55:	5d                   	pop    %ebp
  800e56:	c3                   	ret    

00800e57 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e57:	55                   	push   %ebp
  800e58:	89 e5                	mov    %esp,%ebp
  800e5a:	57                   	push   %edi
  800e5b:	56                   	push   %esi
  800e5c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e5d:	be 00 00 00 00       	mov    $0x0,%esi
  800e62:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e67:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e6a:	8b 55 08             	mov    0x8(%ebp),%edx
  800e6d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e70:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e73:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e75:	5b                   	pop    %ebx
  800e76:	5e                   	pop    %esi
  800e77:	5f                   	pop    %edi
  800e78:	5d                   	pop    %ebp
  800e79:	c3                   	ret    

00800e7a <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e7a:	55                   	push   %ebp
  800e7b:	89 e5                	mov    %esp,%ebp
  800e7d:	57                   	push   %edi
  800e7e:	56                   	push   %esi
  800e7f:	53                   	push   %ebx
  800e80:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e83:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e88:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e8d:	8b 55 08             	mov    0x8(%ebp),%edx
  800e90:	89 cb                	mov    %ecx,%ebx
  800e92:	89 cf                	mov    %ecx,%edi
  800e94:	89 ce                	mov    %ecx,%esi
  800e96:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e98:	85 c0                	test   %eax,%eax
  800e9a:	7e 17                	jle    800eb3 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e9c:	83 ec 0c             	sub    $0xc,%esp
  800e9f:	50                   	push   %eax
  800ea0:	6a 0d                	push   $0xd
  800ea2:	68 bf 28 80 00       	push   $0x8028bf
  800ea7:	6a 23                	push   $0x23
  800ea9:	68 dc 28 80 00       	push   $0x8028dc
  800eae:	e8 ea f2 ff ff       	call   80019d <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800eb3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800eb6:	5b                   	pop    %ebx
  800eb7:	5e                   	pop    %esi
  800eb8:	5f                   	pop    %edi
  800eb9:	5d                   	pop    %ebp
  800eba:	c3                   	ret    

00800ebb <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800ebb:	55                   	push   %ebp
  800ebc:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800ebe:	8b 45 08             	mov    0x8(%ebp),%eax
  800ec1:	05 00 00 00 30       	add    $0x30000000,%eax
  800ec6:	c1 e8 0c             	shr    $0xc,%eax
}
  800ec9:	5d                   	pop    %ebp
  800eca:	c3                   	ret    

00800ecb <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800ecb:	55                   	push   %ebp
  800ecc:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800ece:	8b 45 08             	mov    0x8(%ebp),%eax
  800ed1:	05 00 00 00 30       	add    $0x30000000,%eax
  800ed6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800edb:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800ee0:	5d                   	pop    %ebp
  800ee1:	c3                   	ret    

00800ee2 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800ee2:	55                   	push   %ebp
  800ee3:	89 e5                	mov    %esp,%ebp
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800ee5:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  800eea:	a8 01                	test   $0x1,%al
  800eec:	74 34                	je     800f22 <fd_alloc+0x40>
  800eee:	a1 00 00 74 ef       	mov    0xef740000,%eax
  800ef3:	a8 01                	test   $0x1,%al
  800ef5:	74 32                	je     800f29 <fd_alloc+0x47>
  800ef7:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800efc:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800efe:	89 c2                	mov    %eax,%edx
  800f00:	c1 ea 16             	shr    $0x16,%edx
  800f03:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f0a:	f6 c2 01             	test   $0x1,%dl
  800f0d:	74 1f                	je     800f2e <fd_alloc+0x4c>
  800f0f:	89 c2                	mov    %eax,%edx
  800f11:	c1 ea 0c             	shr    $0xc,%edx
  800f14:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f1b:	f6 c2 01             	test   $0x1,%dl
  800f1e:	75 1a                	jne    800f3a <fd_alloc+0x58>
  800f20:	eb 0c                	jmp    800f2e <fd_alloc+0x4c>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800f22:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  800f27:	eb 05                	jmp    800f2e <fd_alloc+0x4c>
  800f29:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  800f2e:	8b 45 08             	mov    0x8(%ebp),%eax
  800f31:	89 08                	mov    %ecx,(%eax)
			return 0;
  800f33:	b8 00 00 00 00       	mov    $0x0,%eax
  800f38:	eb 1a                	jmp    800f54 <fd_alloc+0x72>
  800f3a:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800f3f:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800f44:	75 b6                	jne    800efc <fd_alloc+0x1a>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800f46:	8b 45 08             	mov    0x8(%ebp),%eax
  800f49:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  800f4f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800f54:	5d                   	pop    %ebp
  800f55:	c3                   	ret    

00800f56 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800f56:	55                   	push   %ebp
  800f57:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800f59:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
  800f5d:	77 39                	ja     800f98 <fd_lookup+0x42>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800f5f:	8b 45 08             	mov    0x8(%ebp),%eax
  800f62:	c1 e0 0c             	shl    $0xc,%eax
  800f65:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800f6a:	89 c2                	mov    %eax,%edx
  800f6c:	c1 ea 16             	shr    $0x16,%edx
  800f6f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f76:	f6 c2 01             	test   $0x1,%dl
  800f79:	74 24                	je     800f9f <fd_lookup+0x49>
  800f7b:	89 c2                	mov    %eax,%edx
  800f7d:	c1 ea 0c             	shr    $0xc,%edx
  800f80:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f87:	f6 c2 01             	test   $0x1,%dl
  800f8a:	74 1a                	je     800fa6 <fd_lookup+0x50>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800f8c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f8f:	89 02                	mov    %eax,(%edx)
	return 0;
  800f91:	b8 00 00 00 00       	mov    $0x0,%eax
  800f96:	eb 13                	jmp    800fab <fd_lookup+0x55>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f98:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f9d:	eb 0c                	jmp    800fab <fd_lookup+0x55>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f9f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800fa4:	eb 05                	jmp    800fab <fd_lookup+0x55>
  800fa6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800fab:	5d                   	pop    %ebp
  800fac:	c3                   	ret    

00800fad <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800fad:	55                   	push   %ebp
  800fae:	89 e5                	mov    %esp,%ebp
  800fb0:	53                   	push   %ebx
  800fb1:	83 ec 04             	sub    $0x4,%esp
  800fb4:	8b 45 08             	mov    0x8(%ebp),%eax
  800fb7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  800fba:	3b 05 04 30 80 00    	cmp    0x803004,%eax
  800fc0:	75 1e                	jne    800fe0 <dev_lookup+0x33>
  800fc2:	eb 0e                	jmp    800fd2 <dev_lookup+0x25>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800fc4:	b8 20 30 80 00       	mov    $0x803020,%eax
  800fc9:	eb 0c                	jmp    800fd7 <dev_lookup+0x2a>
  800fcb:	b8 3c 30 80 00       	mov    $0x80303c,%eax
  800fd0:	eb 05                	jmp    800fd7 <dev_lookup+0x2a>
  800fd2:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  800fd7:	89 03                	mov    %eax,(%ebx)
			return 0;
  800fd9:	b8 00 00 00 00       	mov    $0x0,%eax
  800fde:	eb 36                	jmp    801016 <dev_lookup+0x69>
int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  800fe0:	3b 05 20 30 80 00    	cmp    0x803020,%eax
  800fe6:	74 dc                	je     800fc4 <dev_lookup+0x17>
  800fe8:	3b 05 3c 30 80 00    	cmp    0x80303c,%eax
  800fee:	74 db                	je     800fcb <dev_lookup+0x1e>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800ff0:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800ff6:	8b 52 48             	mov    0x48(%edx),%edx
  800ff9:	83 ec 04             	sub    $0x4,%esp
  800ffc:	50                   	push   %eax
  800ffd:	52                   	push   %edx
  800ffe:	68 ec 28 80 00       	push   $0x8028ec
  801003:	e8 6d f2 ff ff       	call   800275 <cprintf>
	*dev = 0;
  801008:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  80100e:	83 c4 10             	add    $0x10,%esp
  801011:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801016:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801019:	c9                   	leave  
  80101a:	c3                   	ret    

0080101b <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80101b:	55                   	push   %ebp
  80101c:	89 e5                	mov    %esp,%ebp
  80101e:	56                   	push   %esi
  80101f:	53                   	push   %ebx
  801020:	83 ec 10             	sub    $0x10,%esp
  801023:	8b 75 08             	mov    0x8(%ebp),%esi
  801026:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801029:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80102c:	50                   	push   %eax
  80102d:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801033:	c1 e8 0c             	shr    $0xc,%eax
  801036:	50                   	push   %eax
  801037:	e8 1a ff ff ff       	call   800f56 <fd_lookup>
  80103c:	83 c4 08             	add    $0x8,%esp
  80103f:	85 c0                	test   %eax,%eax
  801041:	78 05                	js     801048 <fd_close+0x2d>
	    || fd != fd2)
  801043:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801046:	74 06                	je     80104e <fd_close+0x33>
		return (must_exist ? r : 0);
  801048:	84 db                	test   %bl,%bl
  80104a:	74 47                	je     801093 <fd_close+0x78>
  80104c:	eb 4a                	jmp    801098 <fd_close+0x7d>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80104e:	83 ec 08             	sub    $0x8,%esp
  801051:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801054:	50                   	push   %eax
  801055:	ff 36                	pushl  (%esi)
  801057:	e8 51 ff ff ff       	call   800fad <dev_lookup>
  80105c:	89 c3                	mov    %eax,%ebx
  80105e:	83 c4 10             	add    $0x10,%esp
  801061:	85 c0                	test   %eax,%eax
  801063:	78 1c                	js     801081 <fd_close+0x66>
		if (dev->dev_close)
  801065:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801068:	8b 40 10             	mov    0x10(%eax),%eax
  80106b:	85 c0                	test   %eax,%eax
  80106d:	74 0d                	je     80107c <fd_close+0x61>
			r = (*dev->dev_close)(fd);
  80106f:	83 ec 0c             	sub    $0xc,%esp
  801072:	56                   	push   %esi
  801073:	ff d0                	call   *%eax
  801075:	89 c3                	mov    %eax,%ebx
  801077:	83 c4 10             	add    $0x10,%esp
  80107a:	eb 05                	jmp    801081 <fd_close+0x66>
		else
			r = 0;
  80107c:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801081:	83 ec 08             	sub    $0x8,%esp
  801084:	56                   	push   %esi
  801085:	6a 00                	push   $0x0
  801087:	e8 c3 fc ff ff       	call   800d4f <sys_page_unmap>
	return r;
  80108c:	83 c4 10             	add    $0x10,%esp
  80108f:	89 d8                	mov    %ebx,%eax
  801091:	eb 05                	jmp    801098 <fd_close+0x7d>
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
  801093:	b8 00 00 00 00       	mov    $0x0,%eax
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
	return r;
}
  801098:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80109b:	5b                   	pop    %ebx
  80109c:	5e                   	pop    %esi
  80109d:	5d                   	pop    %ebp
  80109e:	c3                   	ret    

0080109f <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80109f:	55                   	push   %ebp
  8010a0:	89 e5                	mov    %esp,%ebp
  8010a2:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8010a5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010a8:	50                   	push   %eax
  8010a9:	ff 75 08             	pushl  0x8(%ebp)
  8010ac:	e8 a5 fe ff ff       	call   800f56 <fd_lookup>
  8010b1:	83 c4 08             	add    $0x8,%esp
  8010b4:	85 c0                	test   %eax,%eax
  8010b6:	78 10                	js     8010c8 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8010b8:	83 ec 08             	sub    $0x8,%esp
  8010bb:	6a 01                	push   $0x1
  8010bd:	ff 75 f4             	pushl  -0xc(%ebp)
  8010c0:	e8 56 ff ff ff       	call   80101b <fd_close>
  8010c5:	83 c4 10             	add    $0x10,%esp
}
  8010c8:	c9                   	leave  
  8010c9:	c3                   	ret    

008010ca <close_all>:

void
close_all(void)
{
  8010ca:	55                   	push   %ebp
  8010cb:	89 e5                	mov    %esp,%ebp
  8010cd:	53                   	push   %ebx
  8010ce:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8010d1:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8010d6:	83 ec 0c             	sub    $0xc,%esp
  8010d9:	53                   	push   %ebx
  8010da:	e8 c0 ff ff ff       	call   80109f <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8010df:	43                   	inc    %ebx
  8010e0:	83 c4 10             	add    $0x10,%esp
  8010e3:	83 fb 20             	cmp    $0x20,%ebx
  8010e6:	75 ee                	jne    8010d6 <close_all+0xc>
		close(i);
}
  8010e8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010eb:	c9                   	leave  
  8010ec:	c3                   	ret    

008010ed <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8010ed:	55                   	push   %ebp
  8010ee:	89 e5                	mov    %esp,%ebp
  8010f0:	57                   	push   %edi
  8010f1:	56                   	push   %esi
  8010f2:	53                   	push   %ebx
  8010f3:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8010f6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8010f9:	50                   	push   %eax
  8010fa:	ff 75 08             	pushl  0x8(%ebp)
  8010fd:	e8 54 fe ff ff       	call   800f56 <fd_lookup>
  801102:	83 c4 08             	add    $0x8,%esp
  801105:	85 c0                	test   %eax,%eax
  801107:	0f 88 c2 00 00 00    	js     8011cf <dup+0xe2>
		return r;
	close(newfdnum);
  80110d:	83 ec 0c             	sub    $0xc,%esp
  801110:	ff 75 0c             	pushl  0xc(%ebp)
  801113:	e8 87 ff ff ff       	call   80109f <close>

	newfd = INDEX2FD(newfdnum);
  801118:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80111b:	c1 e3 0c             	shl    $0xc,%ebx
  80111e:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801124:	83 c4 04             	add    $0x4,%esp
  801127:	ff 75 e4             	pushl  -0x1c(%ebp)
  80112a:	e8 9c fd ff ff       	call   800ecb <fd2data>
  80112f:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  801131:	89 1c 24             	mov    %ebx,(%esp)
  801134:	e8 92 fd ff ff       	call   800ecb <fd2data>
  801139:	83 c4 10             	add    $0x10,%esp
  80113c:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80113e:	89 f0                	mov    %esi,%eax
  801140:	c1 e8 16             	shr    $0x16,%eax
  801143:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80114a:	a8 01                	test   $0x1,%al
  80114c:	74 35                	je     801183 <dup+0x96>
  80114e:	89 f0                	mov    %esi,%eax
  801150:	c1 e8 0c             	shr    $0xc,%eax
  801153:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80115a:	f6 c2 01             	test   $0x1,%dl
  80115d:	74 24                	je     801183 <dup+0x96>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80115f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801166:	83 ec 0c             	sub    $0xc,%esp
  801169:	25 07 0e 00 00       	and    $0xe07,%eax
  80116e:	50                   	push   %eax
  80116f:	57                   	push   %edi
  801170:	6a 00                	push   $0x0
  801172:	56                   	push   %esi
  801173:	6a 00                	push   $0x0
  801175:	e8 93 fb ff ff       	call   800d0d <sys_page_map>
  80117a:	89 c6                	mov    %eax,%esi
  80117c:	83 c4 20             	add    $0x20,%esp
  80117f:	85 c0                	test   %eax,%eax
  801181:	78 2c                	js     8011af <dup+0xc2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801183:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801186:	89 d0                	mov    %edx,%eax
  801188:	c1 e8 0c             	shr    $0xc,%eax
  80118b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801192:	83 ec 0c             	sub    $0xc,%esp
  801195:	25 07 0e 00 00       	and    $0xe07,%eax
  80119a:	50                   	push   %eax
  80119b:	53                   	push   %ebx
  80119c:	6a 00                	push   $0x0
  80119e:	52                   	push   %edx
  80119f:	6a 00                	push   $0x0
  8011a1:	e8 67 fb ff ff       	call   800d0d <sys_page_map>
  8011a6:	89 c6                	mov    %eax,%esi
  8011a8:	83 c4 20             	add    $0x20,%esp
  8011ab:	85 c0                	test   %eax,%eax
  8011ad:	79 1d                	jns    8011cc <dup+0xdf>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8011af:	83 ec 08             	sub    $0x8,%esp
  8011b2:	53                   	push   %ebx
  8011b3:	6a 00                	push   $0x0
  8011b5:	e8 95 fb ff ff       	call   800d4f <sys_page_unmap>
	sys_page_unmap(0, nva);
  8011ba:	83 c4 08             	add    $0x8,%esp
  8011bd:	57                   	push   %edi
  8011be:	6a 00                	push   $0x0
  8011c0:	e8 8a fb ff ff       	call   800d4f <sys_page_unmap>
	return r;
  8011c5:	83 c4 10             	add    $0x10,%esp
  8011c8:	89 f0                	mov    %esi,%eax
  8011ca:	eb 03                	jmp    8011cf <dup+0xe2>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  8011cc:	8b 45 0c             	mov    0xc(%ebp),%eax

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8011cf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011d2:	5b                   	pop    %ebx
  8011d3:	5e                   	pop    %esi
  8011d4:	5f                   	pop    %edi
  8011d5:	5d                   	pop    %ebp
  8011d6:	c3                   	ret    

008011d7 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8011d7:	55                   	push   %ebp
  8011d8:	89 e5                	mov    %esp,%ebp
  8011da:	53                   	push   %ebx
  8011db:	83 ec 14             	sub    $0x14,%esp
  8011de:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011e1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011e4:	50                   	push   %eax
  8011e5:	53                   	push   %ebx
  8011e6:	e8 6b fd ff ff       	call   800f56 <fd_lookup>
  8011eb:	83 c4 08             	add    $0x8,%esp
  8011ee:	85 c0                	test   %eax,%eax
  8011f0:	78 67                	js     801259 <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011f2:	83 ec 08             	sub    $0x8,%esp
  8011f5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011f8:	50                   	push   %eax
  8011f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011fc:	ff 30                	pushl  (%eax)
  8011fe:	e8 aa fd ff ff       	call   800fad <dev_lookup>
  801203:	83 c4 10             	add    $0x10,%esp
  801206:	85 c0                	test   %eax,%eax
  801208:	78 4f                	js     801259 <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80120a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80120d:	8b 42 08             	mov    0x8(%edx),%eax
  801210:	83 e0 03             	and    $0x3,%eax
  801213:	83 f8 01             	cmp    $0x1,%eax
  801216:	75 21                	jne    801239 <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801218:	a1 04 40 80 00       	mov    0x804004,%eax
  80121d:	8b 40 48             	mov    0x48(%eax),%eax
  801220:	83 ec 04             	sub    $0x4,%esp
  801223:	53                   	push   %ebx
  801224:	50                   	push   %eax
  801225:	68 2d 29 80 00       	push   $0x80292d
  80122a:	e8 46 f0 ff ff       	call   800275 <cprintf>
		return -E_INVAL;
  80122f:	83 c4 10             	add    $0x10,%esp
  801232:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801237:	eb 20                	jmp    801259 <read+0x82>
	}
	if (!dev->dev_read)
  801239:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80123c:	8b 40 08             	mov    0x8(%eax),%eax
  80123f:	85 c0                	test   %eax,%eax
  801241:	74 11                	je     801254 <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801243:	83 ec 04             	sub    $0x4,%esp
  801246:	ff 75 10             	pushl  0x10(%ebp)
  801249:	ff 75 0c             	pushl  0xc(%ebp)
  80124c:	52                   	push   %edx
  80124d:	ff d0                	call   *%eax
  80124f:	83 c4 10             	add    $0x10,%esp
  801252:	eb 05                	jmp    801259 <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801254:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801259:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80125c:	c9                   	leave  
  80125d:	c3                   	ret    

0080125e <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80125e:	55                   	push   %ebp
  80125f:	89 e5                	mov    %esp,%ebp
  801261:	57                   	push   %edi
  801262:	56                   	push   %esi
  801263:	53                   	push   %ebx
  801264:	83 ec 0c             	sub    $0xc,%esp
  801267:	8b 7d 08             	mov    0x8(%ebp),%edi
  80126a:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80126d:	85 f6                	test   %esi,%esi
  80126f:	74 31                	je     8012a2 <readn+0x44>
  801271:	b8 00 00 00 00       	mov    $0x0,%eax
  801276:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  80127b:	83 ec 04             	sub    $0x4,%esp
  80127e:	89 f2                	mov    %esi,%edx
  801280:	29 c2                	sub    %eax,%edx
  801282:	52                   	push   %edx
  801283:	03 45 0c             	add    0xc(%ebp),%eax
  801286:	50                   	push   %eax
  801287:	57                   	push   %edi
  801288:	e8 4a ff ff ff       	call   8011d7 <read>
		if (m < 0)
  80128d:	83 c4 10             	add    $0x10,%esp
  801290:	85 c0                	test   %eax,%eax
  801292:	78 17                	js     8012ab <readn+0x4d>
			return m;
		if (m == 0)
  801294:	85 c0                	test   %eax,%eax
  801296:	74 11                	je     8012a9 <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801298:	01 c3                	add    %eax,%ebx
  80129a:	89 d8                	mov    %ebx,%eax
  80129c:	39 f3                	cmp    %esi,%ebx
  80129e:	72 db                	jb     80127b <readn+0x1d>
  8012a0:	eb 09                	jmp    8012ab <readn+0x4d>
  8012a2:	b8 00 00 00 00       	mov    $0x0,%eax
  8012a7:	eb 02                	jmp    8012ab <readn+0x4d>
  8012a9:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8012ab:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012ae:	5b                   	pop    %ebx
  8012af:	5e                   	pop    %esi
  8012b0:	5f                   	pop    %edi
  8012b1:	5d                   	pop    %ebp
  8012b2:	c3                   	ret    

008012b3 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8012b3:	55                   	push   %ebp
  8012b4:	89 e5                	mov    %esp,%ebp
  8012b6:	53                   	push   %ebx
  8012b7:	83 ec 14             	sub    $0x14,%esp
  8012ba:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012bd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012c0:	50                   	push   %eax
  8012c1:	53                   	push   %ebx
  8012c2:	e8 8f fc ff ff       	call   800f56 <fd_lookup>
  8012c7:	83 c4 08             	add    $0x8,%esp
  8012ca:	85 c0                	test   %eax,%eax
  8012cc:	78 62                	js     801330 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012ce:	83 ec 08             	sub    $0x8,%esp
  8012d1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012d4:	50                   	push   %eax
  8012d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012d8:	ff 30                	pushl  (%eax)
  8012da:	e8 ce fc ff ff       	call   800fad <dev_lookup>
  8012df:	83 c4 10             	add    $0x10,%esp
  8012e2:	85 c0                	test   %eax,%eax
  8012e4:	78 4a                	js     801330 <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012e9:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012ed:	75 21                	jne    801310 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8012ef:	a1 04 40 80 00       	mov    0x804004,%eax
  8012f4:	8b 40 48             	mov    0x48(%eax),%eax
  8012f7:	83 ec 04             	sub    $0x4,%esp
  8012fa:	53                   	push   %ebx
  8012fb:	50                   	push   %eax
  8012fc:	68 49 29 80 00       	push   $0x802949
  801301:	e8 6f ef ff ff       	call   800275 <cprintf>
		return -E_INVAL;
  801306:	83 c4 10             	add    $0x10,%esp
  801309:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80130e:	eb 20                	jmp    801330 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801310:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801313:	8b 52 0c             	mov    0xc(%edx),%edx
  801316:	85 d2                	test   %edx,%edx
  801318:	74 11                	je     80132b <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80131a:	83 ec 04             	sub    $0x4,%esp
  80131d:	ff 75 10             	pushl  0x10(%ebp)
  801320:	ff 75 0c             	pushl  0xc(%ebp)
  801323:	50                   	push   %eax
  801324:	ff d2                	call   *%edx
  801326:	83 c4 10             	add    $0x10,%esp
  801329:	eb 05                	jmp    801330 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80132b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801330:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801333:	c9                   	leave  
  801334:	c3                   	ret    

00801335 <seek>:

int
seek(int fdnum, off_t offset)
{
  801335:	55                   	push   %ebp
  801336:	89 e5                	mov    %esp,%ebp
  801338:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80133b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80133e:	50                   	push   %eax
  80133f:	ff 75 08             	pushl  0x8(%ebp)
  801342:	e8 0f fc ff ff       	call   800f56 <fd_lookup>
  801347:	83 c4 08             	add    $0x8,%esp
  80134a:	85 c0                	test   %eax,%eax
  80134c:	78 0e                	js     80135c <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80134e:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801351:	8b 55 0c             	mov    0xc(%ebp),%edx
  801354:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801357:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80135c:	c9                   	leave  
  80135d:	c3                   	ret    

0080135e <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80135e:	55                   	push   %ebp
  80135f:	89 e5                	mov    %esp,%ebp
  801361:	53                   	push   %ebx
  801362:	83 ec 14             	sub    $0x14,%esp
  801365:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801368:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80136b:	50                   	push   %eax
  80136c:	53                   	push   %ebx
  80136d:	e8 e4 fb ff ff       	call   800f56 <fd_lookup>
  801372:	83 c4 08             	add    $0x8,%esp
  801375:	85 c0                	test   %eax,%eax
  801377:	78 5f                	js     8013d8 <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801379:	83 ec 08             	sub    $0x8,%esp
  80137c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80137f:	50                   	push   %eax
  801380:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801383:	ff 30                	pushl  (%eax)
  801385:	e8 23 fc ff ff       	call   800fad <dev_lookup>
  80138a:	83 c4 10             	add    $0x10,%esp
  80138d:	85 c0                	test   %eax,%eax
  80138f:	78 47                	js     8013d8 <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801391:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801394:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801398:	75 21                	jne    8013bb <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80139a:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80139f:	8b 40 48             	mov    0x48(%eax),%eax
  8013a2:	83 ec 04             	sub    $0x4,%esp
  8013a5:	53                   	push   %ebx
  8013a6:	50                   	push   %eax
  8013a7:	68 0c 29 80 00       	push   $0x80290c
  8013ac:	e8 c4 ee ff ff       	call   800275 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8013b1:	83 c4 10             	add    $0x10,%esp
  8013b4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013b9:	eb 1d                	jmp    8013d8 <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  8013bb:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8013be:	8b 52 18             	mov    0x18(%edx),%edx
  8013c1:	85 d2                	test   %edx,%edx
  8013c3:	74 0e                	je     8013d3 <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8013c5:	83 ec 08             	sub    $0x8,%esp
  8013c8:	ff 75 0c             	pushl  0xc(%ebp)
  8013cb:	50                   	push   %eax
  8013cc:	ff d2                	call   *%edx
  8013ce:	83 c4 10             	add    $0x10,%esp
  8013d1:	eb 05                	jmp    8013d8 <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8013d3:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8013d8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013db:	c9                   	leave  
  8013dc:	c3                   	ret    

008013dd <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8013dd:	55                   	push   %ebp
  8013de:	89 e5                	mov    %esp,%ebp
  8013e0:	53                   	push   %ebx
  8013e1:	83 ec 14             	sub    $0x14,%esp
  8013e4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013e7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013ea:	50                   	push   %eax
  8013eb:	ff 75 08             	pushl  0x8(%ebp)
  8013ee:	e8 63 fb ff ff       	call   800f56 <fd_lookup>
  8013f3:	83 c4 08             	add    $0x8,%esp
  8013f6:	85 c0                	test   %eax,%eax
  8013f8:	78 52                	js     80144c <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013fa:	83 ec 08             	sub    $0x8,%esp
  8013fd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801400:	50                   	push   %eax
  801401:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801404:	ff 30                	pushl  (%eax)
  801406:	e8 a2 fb ff ff       	call   800fad <dev_lookup>
  80140b:	83 c4 10             	add    $0x10,%esp
  80140e:	85 c0                	test   %eax,%eax
  801410:	78 3a                	js     80144c <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  801412:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801415:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801419:	74 2c                	je     801447 <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80141b:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80141e:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801425:	00 00 00 
	stat->st_isdir = 0;
  801428:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80142f:	00 00 00 
	stat->st_dev = dev;
  801432:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801438:	83 ec 08             	sub    $0x8,%esp
  80143b:	53                   	push   %ebx
  80143c:	ff 75 f0             	pushl  -0x10(%ebp)
  80143f:	ff 50 14             	call   *0x14(%eax)
  801442:	83 c4 10             	add    $0x10,%esp
  801445:	eb 05                	jmp    80144c <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801447:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80144c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80144f:	c9                   	leave  
  801450:	c3                   	ret    

00801451 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801451:	55                   	push   %ebp
  801452:	89 e5                	mov    %esp,%ebp
  801454:	56                   	push   %esi
  801455:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801456:	83 ec 08             	sub    $0x8,%esp
  801459:	6a 00                	push   $0x0
  80145b:	ff 75 08             	pushl  0x8(%ebp)
  80145e:	e8 75 01 00 00       	call   8015d8 <open>
  801463:	89 c3                	mov    %eax,%ebx
  801465:	83 c4 10             	add    $0x10,%esp
  801468:	85 c0                	test   %eax,%eax
  80146a:	78 1d                	js     801489 <stat+0x38>
		return fd;
	r = fstat(fd, stat);
  80146c:	83 ec 08             	sub    $0x8,%esp
  80146f:	ff 75 0c             	pushl  0xc(%ebp)
  801472:	50                   	push   %eax
  801473:	e8 65 ff ff ff       	call   8013dd <fstat>
  801478:	89 c6                	mov    %eax,%esi
	close(fd);
  80147a:	89 1c 24             	mov    %ebx,(%esp)
  80147d:	e8 1d fc ff ff       	call   80109f <close>
	return r;
  801482:	83 c4 10             	add    $0x10,%esp
  801485:	89 f0                	mov    %esi,%eax
  801487:	eb 00                	jmp    801489 <stat+0x38>
}
  801489:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80148c:	5b                   	pop    %ebx
  80148d:	5e                   	pop    %esi
  80148e:	5d                   	pop    %ebp
  80148f:	c3                   	ret    

00801490 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801490:	55                   	push   %ebp
  801491:	89 e5                	mov    %esp,%ebp
  801493:	56                   	push   %esi
  801494:	53                   	push   %ebx
  801495:	89 c6                	mov    %eax,%esi
  801497:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801499:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8014a0:	75 12                	jne    8014b4 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8014a2:	83 ec 0c             	sub    $0xc,%esp
  8014a5:	6a 01                	push   $0x1
  8014a7:	e8 0f 0d 00 00       	call   8021bb <ipc_find_env>
  8014ac:	a3 00 40 80 00       	mov    %eax,0x804000
  8014b1:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8014b4:	6a 07                	push   $0x7
  8014b6:	68 00 50 80 00       	push   $0x805000
  8014bb:	56                   	push   %esi
  8014bc:	ff 35 00 40 80 00    	pushl  0x804000
  8014c2:	e8 95 0c 00 00       	call   80215c <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8014c7:	83 c4 0c             	add    $0xc,%esp
  8014ca:	6a 00                	push   $0x0
  8014cc:	53                   	push   %ebx
  8014cd:	6a 00                	push   $0x0
  8014cf:	e8 13 0c 00 00       	call   8020e7 <ipc_recv>
}
  8014d4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014d7:	5b                   	pop    %ebx
  8014d8:	5e                   	pop    %esi
  8014d9:	5d                   	pop    %ebp
  8014da:	c3                   	ret    

008014db <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8014db:	55                   	push   %ebp
  8014dc:	89 e5                	mov    %esp,%ebp
  8014de:	53                   	push   %ebx
  8014df:	83 ec 04             	sub    $0x4,%esp
  8014e2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8014e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8014e8:	8b 40 0c             	mov    0xc(%eax),%eax
  8014eb:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8014f0:	ba 00 00 00 00       	mov    $0x0,%edx
  8014f5:	b8 05 00 00 00       	mov    $0x5,%eax
  8014fa:	e8 91 ff ff ff       	call   801490 <fsipc>
  8014ff:	85 c0                	test   %eax,%eax
  801501:	78 2c                	js     80152f <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801503:	83 ec 08             	sub    $0x8,%esp
  801506:	68 00 50 80 00       	push   $0x805000
  80150b:	53                   	push   %ebx
  80150c:	e8 49 f3 ff ff       	call   80085a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801511:	a1 80 50 80 00       	mov    0x805080,%eax
  801516:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80151c:	a1 84 50 80 00       	mov    0x805084,%eax
  801521:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801527:	83 c4 10             	add    $0x10,%esp
  80152a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80152f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801532:	c9                   	leave  
  801533:	c3                   	ret    

00801534 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801534:	55                   	push   %ebp
  801535:	89 e5                	mov    %esp,%ebp
  801537:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80153a:	8b 45 08             	mov    0x8(%ebp),%eax
  80153d:	8b 40 0c             	mov    0xc(%eax),%eax
  801540:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801545:	ba 00 00 00 00       	mov    $0x0,%edx
  80154a:	b8 06 00 00 00       	mov    $0x6,%eax
  80154f:	e8 3c ff ff ff       	call   801490 <fsipc>
}
  801554:	c9                   	leave  
  801555:	c3                   	ret    

00801556 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801556:	55                   	push   %ebp
  801557:	89 e5                	mov    %esp,%ebp
  801559:	56                   	push   %esi
  80155a:	53                   	push   %ebx
  80155b:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80155e:	8b 45 08             	mov    0x8(%ebp),%eax
  801561:	8b 40 0c             	mov    0xc(%eax),%eax
  801564:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801569:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80156f:	ba 00 00 00 00       	mov    $0x0,%edx
  801574:	b8 03 00 00 00       	mov    $0x3,%eax
  801579:	e8 12 ff ff ff       	call   801490 <fsipc>
  80157e:	89 c3                	mov    %eax,%ebx
  801580:	85 c0                	test   %eax,%eax
  801582:	78 4b                	js     8015cf <devfile_read+0x79>
		return r;
	assert(r <= n);
  801584:	39 c6                	cmp    %eax,%esi
  801586:	73 16                	jae    80159e <devfile_read+0x48>
  801588:	68 66 29 80 00       	push   $0x802966
  80158d:	68 6d 29 80 00       	push   $0x80296d
  801592:	6a 7a                	push   $0x7a
  801594:	68 82 29 80 00       	push   $0x802982
  801599:	e8 ff eb ff ff       	call   80019d <_panic>
	assert(r <= PGSIZE);
  80159e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8015a3:	7e 16                	jle    8015bb <devfile_read+0x65>
  8015a5:	68 8d 29 80 00       	push   $0x80298d
  8015aa:	68 6d 29 80 00       	push   $0x80296d
  8015af:	6a 7b                	push   $0x7b
  8015b1:	68 82 29 80 00       	push   $0x802982
  8015b6:	e8 e2 eb ff ff       	call   80019d <_panic>
	memmove(buf, &fsipcbuf, r);
  8015bb:	83 ec 04             	sub    $0x4,%esp
  8015be:	50                   	push   %eax
  8015bf:	68 00 50 80 00       	push   $0x805000
  8015c4:	ff 75 0c             	pushl  0xc(%ebp)
  8015c7:	e8 5b f4 ff ff       	call   800a27 <memmove>
	return r;
  8015cc:	83 c4 10             	add    $0x10,%esp
}
  8015cf:	89 d8                	mov    %ebx,%eax
  8015d1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015d4:	5b                   	pop    %ebx
  8015d5:	5e                   	pop    %esi
  8015d6:	5d                   	pop    %ebp
  8015d7:	c3                   	ret    

008015d8 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8015d8:	55                   	push   %ebp
  8015d9:	89 e5                	mov    %esp,%ebp
  8015db:	53                   	push   %ebx
  8015dc:	83 ec 20             	sub    $0x20,%esp
  8015df:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8015e2:	53                   	push   %ebx
  8015e3:	e8 1b f2 ff ff       	call   800803 <strlen>
  8015e8:	83 c4 10             	add    $0x10,%esp
  8015eb:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8015f0:	7f 63                	jg     801655 <open+0x7d>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015f2:	83 ec 0c             	sub    $0xc,%esp
  8015f5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015f8:	50                   	push   %eax
  8015f9:	e8 e4 f8 ff ff       	call   800ee2 <fd_alloc>
  8015fe:	83 c4 10             	add    $0x10,%esp
  801601:	85 c0                	test   %eax,%eax
  801603:	78 55                	js     80165a <open+0x82>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801605:	83 ec 08             	sub    $0x8,%esp
  801608:	53                   	push   %ebx
  801609:	68 00 50 80 00       	push   $0x805000
  80160e:	e8 47 f2 ff ff       	call   80085a <strcpy>
	fsipcbuf.open.req_omode = mode;
  801613:	8b 45 0c             	mov    0xc(%ebp),%eax
  801616:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80161b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80161e:	b8 01 00 00 00       	mov    $0x1,%eax
  801623:	e8 68 fe ff ff       	call   801490 <fsipc>
  801628:	89 c3                	mov    %eax,%ebx
  80162a:	83 c4 10             	add    $0x10,%esp
  80162d:	85 c0                	test   %eax,%eax
  80162f:	79 14                	jns    801645 <open+0x6d>
		fd_close(fd, 0);
  801631:	83 ec 08             	sub    $0x8,%esp
  801634:	6a 00                	push   $0x0
  801636:	ff 75 f4             	pushl  -0xc(%ebp)
  801639:	e8 dd f9 ff ff       	call   80101b <fd_close>
		return r;
  80163e:	83 c4 10             	add    $0x10,%esp
  801641:	89 d8                	mov    %ebx,%eax
  801643:	eb 15                	jmp    80165a <open+0x82>
	}

	return fd2num(fd);
  801645:	83 ec 0c             	sub    $0xc,%esp
  801648:	ff 75 f4             	pushl  -0xc(%ebp)
  80164b:	e8 6b f8 ff ff       	call   800ebb <fd2num>
  801650:	83 c4 10             	add    $0x10,%esp
  801653:	eb 05                	jmp    80165a <open+0x82>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801655:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80165a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80165d:	c9                   	leave  
  80165e:	c3                   	ret    

0080165f <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  80165f:	55                   	push   %ebp
  801660:	89 e5                	mov    %esp,%ebp
  801662:	57                   	push   %edi
  801663:	56                   	push   %esi
  801664:	53                   	push   %ebx
  801665:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  80166b:	6a 00                	push   $0x0
  80166d:	ff 75 08             	pushl  0x8(%ebp)
  801670:	e8 63 ff ff ff       	call   8015d8 <open>
  801675:	89 c1                	mov    %eax,%ecx
  801677:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  80167d:	83 c4 10             	add    $0x10,%esp
  801680:	85 c0                	test   %eax,%eax
  801682:	0f 88 6f 04 00 00    	js     801af7 <spawn+0x498>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801688:	83 ec 04             	sub    $0x4,%esp
  80168b:	68 00 02 00 00       	push   $0x200
  801690:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  801696:	50                   	push   %eax
  801697:	51                   	push   %ecx
  801698:	e8 c1 fb ff ff       	call   80125e <readn>
  80169d:	83 c4 10             	add    $0x10,%esp
  8016a0:	3d 00 02 00 00       	cmp    $0x200,%eax
  8016a5:	75 0c                	jne    8016b3 <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  8016a7:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  8016ae:	45 4c 46 
  8016b1:	74 33                	je     8016e6 <spawn+0x87>
		close(fd);
  8016b3:	83 ec 0c             	sub    $0xc,%esp
  8016b6:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8016bc:	e8 de f9 ff ff       	call   80109f <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  8016c1:	83 c4 0c             	add    $0xc,%esp
  8016c4:	68 7f 45 4c 46       	push   $0x464c457f
  8016c9:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  8016cf:	68 99 29 80 00       	push   $0x802999
  8016d4:	e8 9c eb ff ff       	call   800275 <cprintf>
		return -E_NOT_EXEC;
  8016d9:	83 c4 10             	add    $0x10,%esp
  8016dc:	bb f2 ff ff ff       	mov    $0xfffffff2,%ebx
  8016e1:	e9 71 04 00 00       	jmp    801b57 <spawn+0x4f8>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  8016e6:	b8 07 00 00 00       	mov    $0x7,%eax
  8016eb:	cd 30                	int    $0x30
  8016ed:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  8016f3:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  8016f9:	85 c0                	test   %eax,%eax
  8016fb:	0f 88 fe 03 00 00    	js     801aff <spawn+0x4a0>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801701:	89 c6                	mov    %eax,%esi
  801703:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  801709:	8d 04 b5 00 00 00 00 	lea    0x0(,%esi,4),%eax
  801710:	c1 e6 07             	shl    $0x7,%esi
  801713:	29 c6                	sub    %eax,%esi
  801715:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  80171b:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801721:	b9 11 00 00 00       	mov    $0x11,%ecx
  801726:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801728:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  80172e:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801734:	8b 45 0c             	mov    0xc(%ebp),%eax
  801737:	8b 00                	mov    (%eax),%eax
  801739:	85 c0                	test   %eax,%eax
  80173b:	74 3a                	je     801777 <spawn+0x118>
  80173d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801742:	be 00 00 00 00       	mov    $0x0,%esi
  801747:	8b 7d 0c             	mov    0xc(%ebp),%edi
		string_size += strlen(argv[argc]) + 1;
  80174a:	83 ec 0c             	sub    $0xc,%esp
  80174d:	50                   	push   %eax
  80174e:	e8 b0 f0 ff ff       	call   800803 <strlen>
  801753:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801757:	43                   	inc    %ebx
  801758:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  80175f:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  801762:	83 c4 10             	add    $0x10,%esp
  801765:	85 c0                	test   %eax,%eax
  801767:	75 e1                	jne    80174a <spawn+0xeb>
  801769:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  80176f:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
  801775:	eb 1e                	jmp    801795 <spawn+0x136>
  801777:	c7 85 80 fd ff ff 00 	movl   $0x0,-0x280(%ebp)
  80177e:	00 00 00 
  801781:	c7 85 88 fd ff ff 00 	movl   $0x0,-0x278(%ebp)
  801788:	00 00 00 
  80178b:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  801790:	be 00 00 00 00       	mov    $0x0,%esi
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801795:	bf 00 10 40 00       	mov    $0x401000,%edi
  80179a:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  80179c:	89 fa                	mov    %edi,%edx
  80179e:	83 e2 fc             	and    $0xfffffffc,%edx
  8017a1:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  8017a8:	29 c2                	sub    %eax,%edx
  8017aa:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  8017b0:	8d 42 f8             	lea    -0x8(%edx),%eax
  8017b3:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  8017b8:	0f 86 51 03 00 00    	jbe    801b0f <spawn+0x4b0>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8017be:	83 ec 04             	sub    $0x4,%esp
  8017c1:	6a 07                	push   $0x7
  8017c3:	68 00 00 40 00       	push   $0x400000
  8017c8:	6a 00                	push   $0x0
  8017ca:	e8 fb f4 ff ff       	call   800cca <sys_page_alloc>
  8017cf:	83 c4 10             	add    $0x10,%esp
  8017d2:	85 c0                	test   %eax,%eax
  8017d4:	0f 88 3c 03 00 00    	js     801b16 <spawn+0x4b7>
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  8017da:	85 db                	test   %ebx,%ebx
  8017dc:	7e 44                	jle    801822 <spawn+0x1c3>
  8017de:	be 00 00 00 00       	mov    $0x0,%esi
  8017e3:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  8017e9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
		argv_store[i] = UTEMP2USTACK(string_store);
  8017ec:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  8017f2:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  8017f8:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  8017fb:	83 ec 08             	sub    $0x8,%esp
  8017fe:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801801:	57                   	push   %edi
  801802:	e8 53 f0 ff ff       	call   80085a <strcpy>
		string_store += strlen(argv[i]) + 1;
  801807:	83 c4 04             	add    $0x4,%esp
  80180a:	ff 34 b3             	pushl  (%ebx,%esi,4)
  80180d:	e8 f1 ef ff ff       	call   800803 <strlen>
  801812:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801816:	46                   	inc    %esi
  801817:	83 c4 10             	add    $0x10,%esp
  80181a:	3b b5 90 fd ff ff    	cmp    -0x270(%ebp),%esi
  801820:	75 ca                	jne    8017ec <spawn+0x18d>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  801822:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801828:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  80182e:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801835:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  80183b:	74 19                	je     801856 <spawn+0x1f7>
  80183d:	68 10 2a 80 00       	push   $0x802a10
  801842:	68 6d 29 80 00       	push   $0x80296d
  801847:	68 f1 00 00 00       	push   $0xf1
  80184c:	68 b3 29 80 00       	push   $0x8029b3
  801851:	e8 47 e9 ff ff       	call   80019d <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801856:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  80185c:	89 c8                	mov    %ecx,%eax
  80185e:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801863:	89 41 fc             	mov    %eax,-0x4(%ecx)
	argv_store[-2] = argc;
  801866:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  80186c:	89 41 f8             	mov    %eax,-0x8(%ecx)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  80186f:	8d 81 f8 cf 7f ee    	lea    -0x11803008(%ecx),%eax
  801875:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  80187b:	83 ec 0c             	sub    $0xc,%esp
  80187e:	6a 07                	push   $0x7
  801880:	68 00 d0 bf ee       	push   $0xeebfd000
  801885:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  80188b:	68 00 00 40 00       	push   $0x400000
  801890:	6a 00                	push   $0x0
  801892:	e8 76 f4 ff ff       	call   800d0d <sys_page_map>
  801897:	89 c3                	mov    %eax,%ebx
  801899:	83 c4 20             	add    $0x20,%esp
  80189c:	85 c0                	test   %eax,%eax
  80189e:	0f 88 a1 02 00 00    	js     801b45 <spawn+0x4e6>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  8018a4:	83 ec 08             	sub    $0x8,%esp
  8018a7:	68 00 00 40 00       	push   $0x400000
  8018ac:	6a 00                	push   $0x0
  8018ae:	e8 9c f4 ff ff       	call   800d4f <sys_page_unmap>
  8018b3:	89 c3                	mov    %eax,%ebx
  8018b5:	83 c4 10             	add    $0x10,%esp
  8018b8:	85 c0                	test   %eax,%eax
  8018ba:	0f 88 85 02 00 00    	js     801b45 <spawn+0x4e6>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  8018c0:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  8018c6:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  8018cd:	89 85 78 fd ff ff    	mov    %eax,-0x288(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  8018d3:	66 83 bd 14 fe ff ff 	cmpw   $0x0,-0x1ec(%ebp)
  8018da:	00 
  8018db:	0f 84 ab 01 00 00    	je     801a8c <spawn+0x42d>
  8018e1:	c7 85 80 fd ff ff 00 	movl   $0x0,-0x280(%ebp)
  8018e8:	00 00 00 
		if (ph->p_type != ELF_PROG_LOAD)
  8018eb:	8b 85 78 fd ff ff    	mov    -0x288(%ebp),%eax
  8018f1:	83 38 01             	cmpl   $0x1,(%eax)
  8018f4:	0f 85 70 01 00 00    	jne    801a6a <spawn+0x40b>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  8018fa:	89 c1                	mov    %eax,%ecx
  8018fc:	8b 40 18             	mov    0x18(%eax),%eax
  8018ff:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  801902:	83 f8 01             	cmp    $0x1,%eax
  801905:	19 c0                	sbb    %eax,%eax
  801907:	83 e0 fe             	and    $0xfffffffe,%eax
  80190a:	83 c0 07             	add    $0x7,%eax
  80190d:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801913:	89 c8                	mov    %ecx,%eax
  801915:	8b 49 04             	mov    0x4(%ecx),%ecx
  801918:	89 8d 7c fd ff ff    	mov    %ecx,-0x284(%ebp)
  80191e:	8b 50 10             	mov    0x10(%eax),%edx
  801921:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)
  801927:	8b 78 14             	mov    0x14(%eax),%edi
  80192a:	89 bd 90 fd ff ff    	mov    %edi,-0x270(%ebp)
  801930:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801933:	89 f0                	mov    %esi,%eax
  801935:	25 ff 0f 00 00       	and    $0xfff,%eax
  80193a:	74 1a                	je     801956 <spawn+0x2f7>
		va -= i;
  80193c:	29 c6                	sub    %eax,%esi
		memsz += i;
  80193e:	01 c7                	add    %eax,%edi
  801940:	89 bd 90 fd ff ff    	mov    %edi,-0x270(%ebp)
		filesz += i;
  801946:	01 c2                	add    %eax,%edx
  801948:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)
		fileoffset -= i;
  80194e:	29 c1                	sub    %eax,%ecx
  801950:	89 8d 7c fd ff ff    	mov    %ecx,-0x284(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801956:	83 bd 90 fd ff ff 00 	cmpl   $0x0,-0x270(%ebp)
  80195d:	0f 84 07 01 00 00    	je     801a6a <spawn+0x40b>
  801963:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (i >= filesz) {
  801968:	39 9d 94 fd ff ff    	cmp    %ebx,-0x26c(%ebp)
  80196e:	77 27                	ja     801997 <spawn+0x338>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801970:	83 ec 04             	sub    $0x4,%esp
  801973:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801979:	56                   	push   %esi
  80197a:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801980:	e8 45 f3 ff ff       	call   800cca <sys_page_alloc>
  801985:	83 c4 10             	add    $0x10,%esp
  801988:	85 c0                	test   %eax,%eax
  80198a:	0f 89 c2 00 00 00    	jns    801a52 <spawn+0x3f3>
  801990:	89 c3                	mov    %eax,%ebx
  801992:	e9 8d 01 00 00       	jmp    801b24 <spawn+0x4c5>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801997:	83 ec 04             	sub    $0x4,%esp
  80199a:	6a 07                	push   $0x7
  80199c:	68 00 00 40 00       	push   $0x400000
  8019a1:	6a 00                	push   $0x0
  8019a3:	e8 22 f3 ff ff       	call   800cca <sys_page_alloc>
  8019a8:	83 c4 10             	add    $0x10,%esp
  8019ab:	85 c0                	test   %eax,%eax
  8019ad:	0f 88 67 01 00 00    	js     801b1a <spawn+0x4bb>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  8019b3:	83 ec 08             	sub    $0x8,%esp
  8019b6:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  8019bc:	01 d8                	add    %ebx,%eax
  8019be:	50                   	push   %eax
  8019bf:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8019c5:	e8 6b f9 ff ff       	call   801335 <seek>
  8019ca:	83 c4 10             	add    $0x10,%esp
  8019cd:	85 c0                	test   %eax,%eax
  8019cf:	0f 88 49 01 00 00    	js     801b1e <spawn+0x4bf>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  8019d5:	83 ec 04             	sub    $0x4,%esp
  8019d8:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  8019de:	29 d8                	sub    %ebx,%eax
  8019e0:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8019e5:	76 05                	jbe    8019ec <spawn+0x38d>
  8019e7:	b8 00 10 00 00       	mov    $0x1000,%eax
  8019ec:	50                   	push   %eax
  8019ed:	68 00 00 40 00       	push   $0x400000
  8019f2:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8019f8:	e8 61 f8 ff ff       	call   80125e <readn>
  8019fd:	83 c4 10             	add    $0x10,%esp
  801a00:	85 c0                	test   %eax,%eax
  801a02:	0f 88 1a 01 00 00    	js     801b22 <spawn+0x4c3>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801a08:	83 ec 0c             	sub    $0xc,%esp
  801a0b:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801a11:	56                   	push   %esi
  801a12:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801a18:	68 00 00 40 00       	push   $0x400000
  801a1d:	6a 00                	push   $0x0
  801a1f:	e8 e9 f2 ff ff       	call   800d0d <sys_page_map>
  801a24:	83 c4 20             	add    $0x20,%esp
  801a27:	85 c0                	test   %eax,%eax
  801a29:	79 15                	jns    801a40 <spawn+0x3e1>
				panic("spawn: sys_page_map data: %e", r);
  801a2b:	50                   	push   %eax
  801a2c:	68 bf 29 80 00       	push   $0x8029bf
  801a31:	68 24 01 00 00       	push   $0x124
  801a36:	68 b3 29 80 00       	push   $0x8029b3
  801a3b:	e8 5d e7 ff ff       	call   80019d <_panic>
			sys_page_unmap(0, UTEMP);
  801a40:	83 ec 08             	sub    $0x8,%esp
  801a43:	68 00 00 40 00       	push   $0x400000
  801a48:	6a 00                	push   $0x0
  801a4a:	e8 00 f3 ff ff       	call   800d4f <sys_page_unmap>
  801a4f:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801a52:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801a58:	81 c6 00 10 00 00    	add    $0x1000,%esi
  801a5e:	3b 9d 90 fd ff ff    	cmp    -0x270(%ebp),%ebx
  801a64:	0f 82 fe fe ff ff    	jb     801968 <spawn+0x309>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801a6a:	ff 85 80 fd ff ff    	incl   -0x280(%ebp)
  801a70:	8b 95 80 fd ff ff    	mov    -0x280(%ebp),%edx
  801a76:	83 85 78 fd ff ff 20 	addl   $0x20,-0x288(%ebp)
  801a7d:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801a84:	39 d0                	cmp    %edx,%eax
  801a86:	0f 8f 5f fe ff ff    	jg     8018eb <spawn+0x28c>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  801a8c:	83 ec 0c             	sub    $0xc,%esp
  801a8f:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801a95:	e8 05 f6 ff ff       	call   80109f <close>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801a9a:	83 c4 08             	add    $0x8,%esp
  801a9d:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801aa3:	50                   	push   %eax
  801aa4:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801aaa:	e8 24 f3 ff ff       	call   800dd3 <sys_env_set_trapframe>
  801aaf:	83 c4 10             	add    $0x10,%esp
  801ab2:	85 c0                	test   %eax,%eax
  801ab4:	79 15                	jns    801acb <spawn+0x46c>
		panic("sys_env_set_trapframe: %e", r);
  801ab6:	50                   	push   %eax
  801ab7:	68 dc 29 80 00       	push   $0x8029dc
  801abc:	68 85 00 00 00       	push   $0x85
  801ac1:	68 b3 29 80 00       	push   $0x8029b3
  801ac6:	e8 d2 e6 ff ff       	call   80019d <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801acb:	83 ec 08             	sub    $0x8,%esp
  801ace:	6a 02                	push   $0x2
  801ad0:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801ad6:	e8 b6 f2 ff ff       	call   800d91 <sys_env_set_status>
  801adb:	83 c4 10             	add    $0x10,%esp
  801ade:	85 c0                	test   %eax,%eax
  801ae0:	79 25                	jns    801b07 <spawn+0x4a8>
		panic("sys_env_set_status: %e", r);
  801ae2:	50                   	push   %eax
  801ae3:	68 f6 29 80 00       	push   $0x8029f6
  801ae8:	68 88 00 00 00       	push   $0x88
  801aed:	68 b3 29 80 00       	push   $0x8029b3
  801af2:	e8 a6 e6 ff ff       	call   80019d <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  801af7:	8b 9d 8c fd ff ff    	mov    -0x274(%ebp),%ebx
  801afd:	eb 58                	jmp    801b57 <spawn+0x4f8>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  801aff:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801b05:	eb 50                	jmp    801b57 <spawn+0x4f8>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  801b07:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801b0d:	eb 48                	jmp    801b57 <spawn+0x4f8>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  801b0f:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
  801b14:	eb 41                	jmp    801b57 <spawn+0x4f8>

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		return r;
  801b16:	89 c3                	mov    %eax,%ebx
  801b18:	eb 3d                	jmp    801b57 <spawn+0x4f8>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801b1a:	89 c3                	mov    %eax,%ebx
  801b1c:	eb 06                	jmp    801b24 <spawn+0x4c5>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801b1e:	89 c3                	mov    %eax,%ebx
  801b20:	eb 02                	jmp    801b24 <spawn+0x4c5>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801b22:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  801b24:	83 ec 0c             	sub    $0xc,%esp
  801b27:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801b2d:	e8 19 f1 ff ff       	call   800c4b <sys_env_destroy>
	close(fd);
  801b32:	83 c4 04             	add    $0x4,%esp
  801b35:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801b3b:	e8 5f f5 ff ff       	call   80109f <close>
	return r;
  801b40:	83 c4 10             	add    $0x10,%esp
  801b43:	eb 12                	jmp    801b57 <spawn+0x4f8>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  801b45:	83 ec 08             	sub    $0x8,%esp
  801b48:	68 00 00 40 00       	push   $0x400000
  801b4d:	6a 00                	push   $0x0
  801b4f:	e8 fb f1 ff ff       	call   800d4f <sys_page_unmap>
  801b54:	83 c4 10             	add    $0x10,%esp

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  801b57:	89 d8                	mov    %ebx,%eax
  801b59:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b5c:	5b                   	pop    %ebx
  801b5d:	5e                   	pop    %esi
  801b5e:	5f                   	pop    %edi
  801b5f:	5d                   	pop    %ebp
  801b60:	c3                   	ret    

00801b61 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  801b61:	55                   	push   %ebp
  801b62:	89 e5                	mov    %esp,%ebp
  801b64:	57                   	push   %edi
  801b65:	56                   	push   %esi
  801b66:	53                   	push   %ebx
  801b67:	83 ec 1c             	sub    $0x1c,%esp
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801b6a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801b6e:	74 5f                	je     801bcf <spawnl+0x6e>
  801b70:	8d 45 14             	lea    0x14(%ebp),%eax
  801b73:	ba 00 00 00 00       	mov    $0x0,%edx
  801b78:	eb 02                	jmp    801b7c <spawnl+0x1b>
		argc++;
  801b7a:	89 ca                	mov    %ecx,%edx
  801b7c:	8d 4a 01             	lea    0x1(%edx),%ecx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801b7f:	83 c0 04             	add    $0x4,%eax
  801b82:	83 78 fc 00          	cmpl   $0x0,-0x4(%eax)
  801b86:	75 f2                	jne    801b7a <spawnl+0x19>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801b88:	8d 04 95 1e 00 00 00 	lea    0x1e(,%edx,4),%eax
  801b8f:	83 e0 f0             	and    $0xfffffff0,%eax
  801b92:	29 c4                	sub    %eax,%esp
  801b94:	8d 44 24 03          	lea    0x3(%esp),%eax
  801b98:	c1 e8 02             	shr    $0x2,%eax
  801b9b:	8d 34 85 00 00 00 00 	lea    0x0(,%eax,4),%esi
  801ba2:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  801ba4:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801ba7:	89 3c 85 00 00 00 00 	mov    %edi,0x0(,%eax,4)
	argv[argc+1] = NULL;
  801bae:	c7 44 96 08 00 00 00 	movl   $0x0,0x8(%esi,%edx,4)
  801bb5:	00 

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801bb6:	89 ce                	mov    %ecx,%esi
  801bb8:	85 c9                	test   %ecx,%ecx
  801bba:	74 23                	je     801bdf <spawnl+0x7e>
  801bbc:	b8 00 00 00 00       	mov    $0x0,%eax
		argv[i+1] = va_arg(vl, const char *);
  801bc1:	40                   	inc    %eax
  801bc2:	8b 54 85 0c          	mov    0xc(%ebp,%eax,4),%edx
  801bc6:	89 14 83             	mov    %edx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801bc9:	39 f0                	cmp    %esi,%eax
  801bcb:	75 f4                	jne    801bc1 <spawnl+0x60>
  801bcd:	eb 10                	jmp    801bdf <spawnl+0x7e>
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
	argv[0] = arg0;
  801bcf:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bd2:	89 45 e0             	mov    %eax,-0x20(%ebp)
	argv[argc+1] = NULL;
  801bd5:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801bdc:	8d 5d e0             	lea    -0x20(%ebp),%ebx
	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  801bdf:	83 ec 08             	sub    $0x8,%esp
  801be2:	53                   	push   %ebx
  801be3:	ff 75 08             	pushl  0x8(%ebp)
  801be6:	e8 74 fa ff ff       	call   80165f <spawn>
}
  801beb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bee:	5b                   	pop    %ebx
  801bef:	5e                   	pop    %esi
  801bf0:	5f                   	pop    %edi
  801bf1:	5d                   	pop    %ebp
  801bf2:	c3                   	ret    

00801bf3 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801bf3:	55                   	push   %ebp
  801bf4:	89 e5                	mov    %esp,%ebp
  801bf6:	56                   	push   %esi
  801bf7:	53                   	push   %ebx
  801bf8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801bfb:	83 ec 0c             	sub    $0xc,%esp
  801bfe:	ff 75 08             	pushl  0x8(%ebp)
  801c01:	e8 c5 f2 ff ff       	call   800ecb <fd2data>
  801c06:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801c08:	83 c4 08             	add    $0x8,%esp
  801c0b:	68 38 2a 80 00       	push   $0x802a38
  801c10:	53                   	push   %ebx
  801c11:	e8 44 ec ff ff       	call   80085a <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801c16:	8b 46 04             	mov    0x4(%esi),%eax
  801c19:	2b 06                	sub    (%esi),%eax
  801c1b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801c21:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801c28:	00 00 00 
	stat->st_dev = &devpipe;
  801c2b:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801c32:	30 80 00 
	return 0;
}
  801c35:	b8 00 00 00 00       	mov    $0x0,%eax
  801c3a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c3d:	5b                   	pop    %ebx
  801c3e:	5e                   	pop    %esi
  801c3f:	5d                   	pop    %ebp
  801c40:	c3                   	ret    

00801c41 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801c41:	55                   	push   %ebp
  801c42:	89 e5                	mov    %esp,%ebp
  801c44:	53                   	push   %ebx
  801c45:	83 ec 0c             	sub    $0xc,%esp
  801c48:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801c4b:	53                   	push   %ebx
  801c4c:	6a 00                	push   $0x0
  801c4e:	e8 fc f0 ff ff       	call   800d4f <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801c53:	89 1c 24             	mov    %ebx,(%esp)
  801c56:	e8 70 f2 ff ff       	call   800ecb <fd2data>
  801c5b:	83 c4 08             	add    $0x8,%esp
  801c5e:	50                   	push   %eax
  801c5f:	6a 00                	push   $0x0
  801c61:	e8 e9 f0 ff ff       	call   800d4f <sys_page_unmap>
}
  801c66:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c69:	c9                   	leave  
  801c6a:	c3                   	ret    

00801c6b <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801c6b:	55                   	push   %ebp
  801c6c:	89 e5                	mov    %esp,%ebp
  801c6e:	57                   	push   %edi
  801c6f:	56                   	push   %esi
  801c70:	53                   	push   %ebx
  801c71:	83 ec 1c             	sub    $0x1c,%esp
  801c74:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801c77:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801c79:	a1 04 40 80 00       	mov    0x804004,%eax
  801c7e:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801c81:	83 ec 0c             	sub    $0xc,%esp
  801c84:	ff 75 e0             	pushl  -0x20(%ebp)
  801c87:	e8 8a 05 00 00       	call   802216 <pageref>
  801c8c:	89 c3                	mov    %eax,%ebx
  801c8e:	89 3c 24             	mov    %edi,(%esp)
  801c91:	e8 80 05 00 00       	call   802216 <pageref>
  801c96:	83 c4 10             	add    $0x10,%esp
  801c99:	39 c3                	cmp    %eax,%ebx
  801c9b:	0f 94 c1             	sete   %cl
  801c9e:	0f b6 c9             	movzbl %cl,%ecx
  801ca1:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801ca4:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801caa:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801cad:	39 ce                	cmp    %ecx,%esi
  801caf:	74 1b                	je     801ccc <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801cb1:	39 c3                	cmp    %eax,%ebx
  801cb3:	75 c4                	jne    801c79 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801cb5:	8b 42 58             	mov    0x58(%edx),%eax
  801cb8:	ff 75 e4             	pushl  -0x1c(%ebp)
  801cbb:	50                   	push   %eax
  801cbc:	56                   	push   %esi
  801cbd:	68 3f 2a 80 00       	push   $0x802a3f
  801cc2:	e8 ae e5 ff ff       	call   800275 <cprintf>
  801cc7:	83 c4 10             	add    $0x10,%esp
  801cca:	eb ad                	jmp    801c79 <_pipeisclosed+0xe>
	}
}
  801ccc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ccf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cd2:	5b                   	pop    %ebx
  801cd3:	5e                   	pop    %esi
  801cd4:	5f                   	pop    %edi
  801cd5:	5d                   	pop    %ebp
  801cd6:	c3                   	ret    

00801cd7 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801cd7:	55                   	push   %ebp
  801cd8:	89 e5                	mov    %esp,%ebp
  801cda:	57                   	push   %edi
  801cdb:	56                   	push   %esi
  801cdc:	53                   	push   %ebx
  801cdd:	83 ec 18             	sub    $0x18,%esp
  801ce0:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801ce3:	56                   	push   %esi
  801ce4:	e8 e2 f1 ff ff       	call   800ecb <fd2data>
  801ce9:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ceb:	83 c4 10             	add    $0x10,%esp
  801cee:	bf 00 00 00 00       	mov    $0x0,%edi
  801cf3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801cf7:	75 42                	jne    801d3b <devpipe_write+0x64>
  801cf9:	eb 4e                	jmp    801d49 <devpipe_write+0x72>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801cfb:	89 da                	mov    %ebx,%edx
  801cfd:	89 f0                	mov    %esi,%eax
  801cff:	e8 67 ff ff ff       	call   801c6b <_pipeisclosed>
  801d04:	85 c0                	test   %eax,%eax
  801d06:	75 46                	jne    801d4e <devpipe_write+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801d08:	e8 9e ef ff ff       	call   800cab <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801d0d:	8b 53 04             	mov    0x4(%ebx),%edx
  801d10:	8b 03                	mov    (%ebx),%eax
  801d12:	83 c0 20             	add    $0x20,%eax
  801d15:	39 c2                	cmp    %eax,%edx
  801d17:	73 e2                	jae    801cfb <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801d19:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d1c:	8a 0c 38             	mov    (%eax,%edi,1),%cl
  801d1f:	89 d0                	mov    %edx,%eax
  801d21:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801d26:	79 05                	jns    801d2d <devpipe_write+0x56>
  801d28:	48                   	dec    %eax
  801d29:	83 c8 e0             	or     $0xffffffe0,%eax
  801d2c:	40                   	inc    %eax
  801d2d:	88 4c 03 08          	mov    %cl,0x8(%ebx,%eax,1)
		p->p_wpos++;
  801d31:	42                   	inc    %edx
  801d32:	89 53 04             	mov    %edx,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d35:	47                   	inc    %edi
  801d36:	39 7d 10             	cmp    %edi,0x10(%ebp)
  801d39:	74 0e                	je     801d49 <devpipe_write+0x72>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801d3b:	8b 53 04             	mov    0x4(%ebx),%edx
  801d3e:	8b 03                	mov    (%ebx),%eax
  801d40:	83 c0 20             	add    $0x20,%eax
  801d43:	39 c2                	cmp    %eax,%edx
  801d45:	73 b4                	jae    801cfb <devpipe_write+0x24>
  801d47:	eb d0                	jmp    801d19 <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801d49:	8b 45 10             	mov    0x10(%ebp),%eax
  801d4c:	eb 05                	jmp    801d53 <devpipe_write+0x7c>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801d4e:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801d53:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d56:	5b                   	pop    %ebx
  801d57:	5e                   	pop    %esi
  801d58:	5f                   	pop    %edi
  801d59:	5d                   	pop    %ebp
  801d5a:	c3                   	ret    

00801d5b <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d5b:	55                   	push   %ebp
  801d5c:	89 e5                	mov    %esp,%ebp
  801d5e:	57                   	push   %edi
  801d5f:	56                   	push   %esi
  801d60:	53                   	push   %ebx
  801d61:	83 ec 18             	sub    $0x18,%esp
  801d64:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801d67:	57                   	push   %edi
  801d68:	e8 5e f1 ff ff       	call   800ecb <fd2data>
  801d6d:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d6f:	83 c4 10             	add    $0x10,%esp
  801d72:	be 00 00 00 00       	mov    $0x0,%esi
  801d77:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d7b:	75 3d                	jne    801dba <devpipe_read+0x5f>
  801d7d:	eb 48                	jmp    801dc7 <devpipe_read+0x6c>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  801d7f:	89 f0                	mov    %esi,%eax
  801d81:	eb 4e                	jmp    801dd1 <devpipe_read+0x76>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801d83:	89 da                	mov    %ebx,%edx
  801d85:	89 f8                	mov    %edi,%eax
  801d87:	e8 df fe ff ff       	call   801c6b <_pipeisclosed>
  801d8c:	85 c0                	test   %eax,%eax
  801d8e:	75 3c                	jne    801dcc <devpipe_read+0x71>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801d90:	e8 16 ef ff ff       	call   800cab <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801d95:	8b 03                	mov    (%ebx),%eax
  801d97:	3b 43 04             	cmp    0x4(%ebx),%eax
  801d9a:	74 e7                	je     801d83 <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801d9c:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801da1:	79 05                	jns    801da8 <devpipe_read+0x4d>
  801da3:	48                   	dec    %eax
  801da4:	83 c8 e0             	or     $0xffffffe0,%eax
  801da7:	40                   	inc    %eax
  801da8:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801dac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801daf:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801db2:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801db4:	46                   	inc    %esi
  801db5:	39 75 10             	cmp    %esi,0x10(%ebp)
  801db8:	74 0d                	je     801dc7 <devpipe_read+0x6c>
		while (p->p_rpos == p->p_wpos) {
  801dba:	8b 03                	mov    (%ebx),%eax
  801dbc:	3b 43 04             	cmp    0x4(%ebx),%eax
  801dbf:	75 db                	jne    801d9c <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801dc1:	85 f6                	test   %esi,%esi
  801dc3:	75 ba                	jne    801d7f <devpipe_read+0x24>
  801dc5:	eb bc                	jmp    801d83 <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801dc7:	8b 45 10             	mov    0x10(%ebp),%eax
  801dca:	eb 05                	jmp    801dd1 <devpipe_read+0x76>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801dcc:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801dd1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801dd4:	5b                   	pop    %ebx
  801dd5:	5e                   	pop    %esi
  801dd6:	5f                   	pop    %edi
  801dd7:	5d                   	pop    %ebp
  801dd8:	c3                   	ret    

00801dd9 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801dd9:	55                   	push   %ebp
  801dda:	89 e5                	mov    %esp,%ebp
  801ddc:	56                   	push   %esi
  801ddd:	53                   	push   %ebx
  801dde:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801de1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801de4:	50                   	push   %eax
  801de5:	e8 f8 f0 ff ff       	call   800ee2 <fd_alloc>
  801dea:	83 c4 10             	add    $0x10,%esp
  801ded:	85 c0                	test   %eax,%eax
  801def:	0f 88 2a 01 00 00    	js     801f1f <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801df5:	83 ec 04             	sub    $0x4,%esp
  801df8:	68 07 04 00 00       	push   $0x407
  801dfd:	ff 75 f4             	pushl  -0xc(%ebp)
  801e00:	6a 00                	push   $0x0
  801e02:	e8 c3 ee ff ff       	call   800cca <sys_page_alloc>
  801e07:	83 c4 10             	add    $0x10,%esp
  801e0a:	85 c0                	test   %eax,%eax
  801e0c:	0f 88 0d 01 00 00    	js     801f1f <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801e12:	83 ec 0c             	sub    $0xc,%esp
  801e15:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801e18:	50                   	push   %eax
  801e19:	e8 c4 f0 ff ff       	call   800ee2 <fd_alloc>
  801e1e:	89 c3                	mov    %eax,%ebx
  801e20:	83 c4 10             	add    $0x10,%esp
  801e23:	85 c0                	test   %eax,%eax
  801e25:	0f 88 e2 00 00 00    	js     801f0d <pipe+0x134>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e2b:	83 ec 04             	sub    $0x4,%esp
  801e2e:	68 07 04 00 00       	push   $0x407
  801e33:	ff 75 f0             	pushl  -0x10(%ebp)
  801e36:	6a 00                	push   $0x0
  801e38:	e8 8d ee ff ff       	call   800cca <sys_page_alloc>
  801e3d:	89 c3                	mov    %eax,%ebx
  801e3f:	83 c4 10             	add    $0x10,%esp
  801e42:	85 c0                	test   %eax,%eax
  801e44:	0f 88 c3 00 00 00    	js     801f0d <pipe+0x134>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801e4a:	83 ec 0c             	sub    $0xc,%esp
  801e4d:	ff 75 f4             	pushl  -0xc(%ebp)
  801e50:	e8 76 f0 ff ff       	call   800ecb <fd2data>
  801e55:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e57:	83 c4 0c             	add    $0xc,%esp
  801e5a:	68 07 04 00 00       	push   $0x407
  801e5f:	50                   	push   %eax
  801e60:	6a 00                	push   $0x0
  801e62:	e8 63 ee ff ff       	call   800cca <sys_page_alloc>
  801e67:	89 c3                	mov    %eax,%ebx
  801e69:	83 c4 10             	add    $0x10,%esp
  801e6c:	85 c0                	test   %eax,%eax
  801e6e:	0f 88 89 00 00 00    	js     801efd <pipe+0x124>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e74:	83 ec 0c             	sub    $0xc,%esp
  801e77:	ff 75 f0             	pushl  -0x10(%ebp)
  801e7a:	e8 4c f0 ff ff       	call   800ecb <fd2data>
  801e7f:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801e86:	50                   	push   %eax
  801e87:	6a 00                	push   $0x0
  801e89:	56                   	push   %esi
  801e8a:	6a 00                	push   $0x0
  801e8c:	e8 7c ee ff ff       	call   800d0d <sys_page_map>
  801e91:	89 c3                	mov    %eax,%ebx
  801e93:	83 c4 20             	add    $0x20,%esp
  801e96:	85 c0                	test   %eax,%eax
  801e98:	78 55                	js     801eef <pipe+0x116>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801e9a:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801ea0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ea3:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801ea5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ea8:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801eaf:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801eb5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801eb8:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801eba:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ebd:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801ec4:	83 ec 0c             	sub    $0xc,%esp
  801ec7:	ff 75 f4             	pushl  -0xc(%ebp)
  801eca:	e8 ec ef ff ff       	call   800ebb <fd2num>
  801ecf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ed2:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801ed4:	83 c4 04             	add    $0x4,%esp
  801ed7:	ff 75 f0             	pushl  -0x10(%ebp)
  801eda:	e8 dc ef ff ff       	call   800ebb <fd2num>
  801edf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ee2:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801ee5:	83 c4 10             	add    $0x10,%esp
  801ee8:	b8 00 00 00 00       	mov    $0x0,%eax
  801eed:	eb 30                	jmp    801f1f <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  801eef:	83 ec 08             	sub    $0x8,%esp
  801ef2:	56                   	push   %esi
  801ef3:	6a 00                	push   $0x0
  801ef5:	e8 55 ee ff ff       	call   800d4f <sys_page_unmap>
  801efa:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801efd:	83 ec 08             	sub    $0x8,%esp
  801f00:	ff 75 f0             	pushl  -0x10(%ebp)
  801f03:	6a 00                	push   $0x0
  801f05:	e8 45 ee ff ff       	call   800d4f <sys_page_unmap>
  801f0a:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801f0d:	83 ec 08             	sub    $0x8,%esp
  801f10:	ff 75 f4             	pushl  -0xc(%ebp)
  801f13:	6a 00                	push   $0x0
  801f15:	e8 35 ee ff ff       	call   800d4f <sys_page_unmap>
  801f1a:	83 c4 10             	add    $0x10,%esp
  801f1d:	89 d8                	mov    %ebx,%eax
    err:
	return r;
}
  801f1f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f22:	5b                   	pop    %ebx
  801f23:	5e                   	pop    %esi
  801f24:	5d                   	pop    %ebp
  801f25:	c3                   	ret    

00801f26 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801f26:	55                   	push   %ebp
  801f27:	89 e5                	mov    %esp,%ebp
  801f29:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f2c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f2f:	50                   	push   %eax
  801f30:	ff 75 08             	pushl  0x8(%ebp)
  801f33:	e8 1e f0 ff ff       	call   800f56 <fd_lookup>
  801f38:	83 c4 10             	add    $0x10,%esp
  801f3b:	85 c0                	test   %eax,%eax
  801f3d:	78 18                	js     801f57 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801f3f:	83 ec 0c             	sub    $0xc,%esp
  801f42:	ff 75 f4             	pushl  -0xc(%ebp)
  801f45:	e8 81 ef ff ff       	call   800ecb <fd2data>
	return _pipeisclosed(fd, p);
  801f4a:	89 c2                	mov    %eax,%edx
  801f4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f4f:	e8 17 fd ff ff       	call   801c6b <_pipeisclosed>
  801f54:	83 c4 10             	add    $0x10,%esp
}
  801f57:	c9                   	leave  
  801f58:	c3                   	ret    

00801f59 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801f59:	55                   	push   %ebp
  801f5a:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801f5c:	b8 00 00 00 00       	mov    $0x0,%eax
  801f61:	5d                   	pop    %ebp
  801f62:	c3                   	ret    

00801f63 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801f63:	55                   	push   %ebp
  801f64:	89 e5                	mov    %esp,%ebp
  801f66:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801f69:	68 57 2a 80 00       	push   $0x802a57
  801f6e:	ff 75 0c             	pushl  0xc(%ebp)
  801f71:	e8 e4 e8 ff ff       	call   80085a <strcpy>
	return 0;
}
  801f76:	b8 00 00 00 00       	mov    $0x0,%eax
  801f7b:	c9                   	leave  
  801f7c:	c3                   	ret    

00801f7d <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801f7d:	55                   	push   %ebp
  801f7e:	89 e5                	mov    %esp,%ebp
  801f80:	57                   	push   %edi
  801f81:	56                   	push   %esi
  801f82:	53                   	push   %ebx
  801f83:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f89:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801f8d:	74 45                	je     801fd4 <devcons_write+0x57>
  801f8f:	b8 00 00 00 00       	mov    $0x0,%eax
  801f94:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801f99:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801f9f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801fa2:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  801fa4:	83 fb 7f             	cmp    $0x7f,%ebx
  801fa7:	76 05                	jbe    801fae <devcons_write+0x31>
			m = sizeof(buf) - 1;
  801fa9:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801fae:	83 ec 04             	sub    $0x4,%esp
  801fb1:	53                   	push   %ebx
  801fb2:	03 45 0c             	add    0xc(%ebp),%eax
  801fb5:	50                   	push   %eax
  801fb6:	57                   	push   %edi
  801fb7:	e8 6b ea ff ff       	call   800a27 <memmove>
		sys_cputs(buf, m);
  801fbc:	83 c4 08             	add    $0x8,%esp
  801fbf:	53                   	push   %ebx
  801fc0:	57                   	push   %edi
  801fc1:	e8 48 ec ff ff       	call   800c0e <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801fc6:	01 de                	add    %ebx,%esi
  801fc8:	89 f0                	mov    %esi,%eax
  801fca:	83 c4 10             	add    $0x10,%esp
  801fcd:	3b 75 10             	cmp    0x10(%ebp),%esi
  801fd0:	72 cd                	jb     801f9f <devcons_write+0x22>
  801fd2:	eb 05                	jmp    801fd9 <devcons_write+0x5c>
  801fd4:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801fd9:	89 f0                	mov    %esi,%eax
  801fdb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fde:	5b                   	pop    %ebx
  801fdf:	5e                   	pop    %esi
  801fe0:	5f                   	pop    %edi
  801fe1:	5d                   	pop    %ebp
  801fe2:	c3                   	ret    

00801fe3 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801fe3:	55                   	push   %ebp
  801fe4:	89 e5                	mov    %esp,%ebp
  801fe6:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801fe9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801fed:	75 07                	jne    801ff6 <devcons_read+0x13>
  801fef:	eb 23                	jmp    802014 <devcons_read+0x31>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801ff1:	e8 b5 ec ff ff       	call   800cab <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801ff6:	e8 31 ec ff ff       	call   800c2c <sys_cgetc>
  801ffb:	85 c0                	test   %eax,%eax
  801ffd:	74 f2                	je     801ff1 <devcons_read+0xe>
		sys_yield();
	if (c < 0)
  801fff:	85 c0                	test   %eax,%eax
  802001:	78 1d                	js     802020 <devcons_read+0x3d>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802003:	83 f8 04             	cmp    $0x4,%eax
  802006:	74 13                	je     80201b <devcons_read+0x38>
		return 0;
	*(char*)vbuf = c;
  802008:	8b 55 0c             	mov    0xc(%ebp),%edx
  80200b:	88 02                	mov    %al,(%edx)
	return 1;
  80200d:	b8 01 00 00 00       	mov    $0x1,%eax
  802012:	eb 0c                	jmp    802020 <devcons_read+0x3d>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  802014:	b8 00 00 00 00       	mov    $0x0,%eax
  802019:	eb 05                	jmp    802020 <devcons_read+0x3d>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80201b:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802020:	c9                   	leave  
  802021:	c3                   	ret    

00802022 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802022:	55                   	push   %ebp
  802023:	89 e5                	mov    %esp,%ebp
  802025:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802028:	8b 45 08             	mov    0x8(%ebp),%eax
  80202b:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80202e:	6a 01                	push   $0x1
  802030:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802033:	50                   	push   %eax
  802034:	e8 d5 eb ff ff       	call   800c0e <sys_cputs>
}
  802039:	83 c4 10             	add    $0x10,%esp
  80203c:	c9                   	leave  
  80203d:	c3                   	ret    

0080203e <getchar>:

int
getchar(void)
{
  80203e:	55                   	push   %ebp
  80203f:	89 e5                	mov    %esp,%ebp
  802041:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802044:	6a 01                	push   $0x1
  802046:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802049:	50                   	push   %eax
  80204a:	6a 00                	push   $0x0
  80204c:	e8 86 f1 ff ff       	call   8011d7 <read>
	if (r < 0)
  802051:	83 c4 10             	add    $0x10,%esp
  802054:	85 c0                	test   %eax,%eax
  802056:	78 0f                	js     802067 <getchar+0x29>
		return r;
	if (r < 1)
  802058:	85 c0                	test   %eax,%eax
  80205a:	7e 06                	jle    802062 <getchar+0x24>
		return -E_EOF;
	return c;
  80205c:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802060:	eb 05                	jmp    802067 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802062:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802067:	c9                   	leave  
  802068:	c3                   	ret    

00802069 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802069:	55                   	push   %ebp
  80206a:	89 e5                	mov    %esp,%ebp
  80206c:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80206f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802072:	50                   	push   %eax
  802073:	ff 75 08             	pushl  0x8(%ebp)
  802076:	e8 db ee ff ff       	call   800f56 <fd_lookup>
  80207b:	83 c4 10             	add    $0x10,%esp
  80207e:	85 c0                	test   %eax,%eax
  802080:	78 11                	js     802093 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802082:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802085:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80208b:	39 10                	cmp    %edx,(%eax)
  80208d:	0f 94 c0             	sete   %al
  802090:	0f b6 c0             	movzbl %al,%eax
}
  802093:	c9                   	leave  
  802094:	c3                   	ret    

00802095 <opencons>:

int
opencons(void)
{
  802095:	55                   	push   %ebp
  802096:	89 e5                	mov    %esp,%ebp
  802098:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80209b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80209e:	50                   	push   %eax
  80209f:	e8 3e ee ff ff       	call   800ee2 <fd_alloc>
  8020a4:	83 c4 10             	add    $0x10,%esp
  8020a7:	85 c0                	test   %eax,%eax
  8020a9:	78 3a                	js     8020e5 <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8020ab:	83 ec 04             	sub    $0x4,%esp
  8020ae:	68 07 04 00 00       	push   $0x407
  8020b3:	ff 75 f4             	pushl  -0xc(%ebp)
  8020b6:	6a 00                	push   $0x0
  8020b8:	e8 0d ec ff ff       	call   800cca <sys_page_alloc>
  8020bd:	83 c4 10             	add    $0x10,%esp
  8020c0:	85 c0                	test   %eax,%eax
  8020c2:	78 21                	js     8020e5 <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8020c4:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8020ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020cd:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8020cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020d2:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8020d9:	83 ec 0c             	sub    $0xc,%esp
  8020dc:	50                   	push   %eax
  8020dd:	e8 d9 ed ff ff       	call   800ebb <fd2num>
  8020e2:	83 c4 10             	add    $0x10,%esp
}
  8020e5:	c9                   	leave  
  8020e6:	c3                   	ret    

008020e7 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8020e7:	55                   	push   %ebp
  8020e8:	89 e5                	mov    %esp,%ebp
  8020ea:	56                   	push   %esi
  8020eb:	53                   	push   %ebx
  8020ec:	8b 75 08             	mov    0x8(%ebp),%esi
  8020ef:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020f2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");
	int r;
    if (pg != NULL) {
  8020f5:	85 c0                	test   %eax,%eax
  8020f7:	74 0e                	je     802107 <ipc_recv+0x20>
        r = sys_ipc_recv(pg);
  8020f9:	83 ec 0c             	sub    $0xc,%esp
  8020fc:	50                   	push   %eax
  8020fd:	e8 78 ed ff ff       	call   800e7a <sys_ipc_recv>
  802102:	83 c4 10             	add    $0x10,%esp
  802105:	eb 10                	jmp    802117 <ipc_recv+0x30>
    } else {
        r = sys_ipc_recv((void *) UTOP);
  802107:	83 ec 0c             	sub    $0xc,%esp
  80210a:	68 00 00 c0 ee       	push   $0xeec00000
  80210f:	e8 66 ed ff ff       	call   800e7a <sys_ipc_recv>
  802114:	83 c4 10             	add    $0x10,%esp
    }
    if (r < 0) {
  802117:	85 c0                	test   %eax,%eax
  802119:	79 16                	jns    802131 <ipc_recv+0x4a>
        // failed
        if (from_env_store != NULL) *from_env_store = 0;
  80211b:	85 f6                	test   %esi,%esi
  80211d:	74 06                	je     802125 <ipc_recv+0x3e>
  80211f:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        if (perm_store != NULL) *perm_store = 0;
  802125:	85 db                	test   %ebx,%ebx
  802127:	74 2c                	je     802155 <ipc_recv+0x6e>
  802129:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80212f:	eb 24                	jmp    802155 <ipc_recv+0x6e>
        return r;
    } else {
        if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  802131:	85 f6                	test   %esi,%esi
  802133:	74 0a                	je     80213f <ipc_recv+0x58>
  802135:	a1 04 40 80 00       	mov    0x804004,%eax
  80213a:	8b 40 74             	mov    0x74(%eax),%eax
  80213d:	89 06                	mov    %eax,(%esi)
        if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  80213f:	85 db                	test   %ebx,%ebx
  802141:	74 0a                	je     80214d <ipc_recv+0x66>
  802143:	a1 04 40 80 00       	mov    0x804004,%eax
  802148:	8b 40 78             	mov    0x78(%eax),%eax
  80214b:	89 03                	mov    %eax,(%ebx)
        return thisenv->env_ipc_value;
  80214d:	a1 04 40 80 00       	mov    0x804004,%eax
  802152:	8b 40 70             	mov    0x70(%eax),%eax
    }
 
	return 0;
}
  802155:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802158:	5b                   	pop    %ebx
  802159:	5e                   	pop    %esi
  80215a:	5d                   	pop    %ebp
  80215b:	c3                   	ret    

0080215c <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80215c:	55                   	push   %ebp
  80215d:	89 e5                	mov    %esp,%ebp
  80215f:	57                   	push   %edi
  802160:	56                   	push   %esi
  802161:	53                   	push   %ebx
  802162:	83 ec 0c             	sub    $0xc,%esp
  802165:	8b 75 10             	mov    0x10(%ebp),%esi
  802168:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");
	int r;
    if (pg == NULL) pg = (void *)UTOP;
  80216b:	85 f6                	test   %esi,%esi
  80216d:	75 05                	jne    802174 <ipc_send+0x18>
  80216f:	be 00 00 c0 ee       	mov    $0xeec00000,%esi
    do {
        r = sys_ipc_try_send(to_env, val, pg, perm);
  802174:	57                   	push   %edi
  802175:	56                   	push   %esi
  802176:	ff 75 0c             	pushl  0xc(%ebp)
  802179:	ff 75 08             	pushl  0x8(%ebp)
  80217c:	e8 d6 ec ff ff       	call   800e57 <sys_ipc_try_send>
  802181:	89 c3                	mov    %eax,%ebx
        if (r < 0 && r != -E_IPC_NOT_RECV) panic("ipc send failed: %e", r);
  802183:	83 c4 10             	add    $0x10,%esp
  802186:	85 c0                	test   %eax,%eax
  802188:	79 17                	jns    8021a1 <ipc_send+0x45>
  80218a:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80218d:	74 1d                	je     8021ac <ipc_send+0x50>
  80218f:	50                   	push   %eax
  802190:	68 63 2a 80 00       	push   $0x802a63
  802195:	6a 40                	push   $0x40
  802197:	68 77 2a 80 00       	push   $0x802a77
  80219c:	e8 fc df ff ff       	call   80019d <_panic>
        sys_yield();
  8021a1:	e8 05 eb ff ff       	call   800cab <sys_yield>
    } while (r != 0);
  8021a6:	85 db                	test   %ebx,%ebx
  8021a8:	75 ca                	jne    802174 <ipc_send+0x18>
  8021aa:	eb 07                	jmp    8021b3 <ipc_send+0x57>
	int r;
    if (pg == NULL) pg = (void *)UTOP;
    do {
        r = sys_ipc_try_send(to_env, val, pg, perm);
        if (r < 0 && r != -E_IPC_NOT_RECV) panic("ipc send failed: %e", r);
        sys_yield();
  8021ac:	e8 fa ea ff ff       	call   800cab <sys_yield>
  8021b1:	eb c1                	jmp    802174 <ipc_send+0x18>
    } while (r != 0);
}
  8021b3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8021b6:	5b                   	pop    %ebx
  8021b7:	5e                   	pop    %esi
  8021b8:	5f                   	pop    %edi
  8021b9:	5d                   	pop    %ebp
  8021ba:	c3                   	ret    

008021bb <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8021bb:	55                   	push   %ebp
  8021bc:	89 e5                	mov    %esp,%ebp
  8021be:	53                   	push   %ebx
  8021bf:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  8021c2:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  8021c7:	39 c1                	cmp    %eax,%ecx
  8021c9:	74 21                	je     8021ec <ipc_find_env+0x31>
  8021cb:	ba 01 00 00 00       	mov    $0x1,%edx
  8021d0:	8d 1c 95 00 00 00 00 	lea    0x0(,%edx,4),%ebx
  8021d7:	89 d0                	mov    %edx,%eax
  8021d9:	c1 e0 07             	shl    $0x7,%eax
  8021dc:	29 d8                	sub    %ebx,%eax
  8021de:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8021e3:	8b 40 50             	mov    0x50(%eax),%eax
  8021e6:	39 c8                	cmp    %ecx,%eax
  8021e8:	75 1b                	jne    802205 <ipc_find_env+0x4a>
  8021ea:	eb 05                	jmp    8021f1 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8021ec:	ba 00 00 00 00       	mov    $0x0,%edx
		if (envs[i].env_type == type)
			return envs[i].env_id;
  8021f1:	8d 04 95 00 00 00 00 	lea    0x0(,%edx,4),%eax
  8021f8:	c1 e2 07             	shl    $0x7,%edx
  8021fb:	29 c2                	sub    %eax,%edx
  8021fd:	8b 82 48 00 c0 ee    	mov    -0x113fffb8(%edx),%eax
  802203:	eb 0e                	jmp    802213 <ipc_find_env+0x58>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802205:	42                   	inc    %edx
  802206:	81 fa 00 04 00 00    	cmp    $0x400,%edx
  80220c:	75 c2                	jne    8021d0 <ipc_find_env+0x15>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80220e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802213:	5b                   	pop    %ebx
  802214:	5d                   	pop    %ebp
  802215:	c3                   	ret    

00802216 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802216:	55                   	push   %ebp
  802217:	89 e5                	mov    %esp,%ebp
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802219:	8b 45 08             	mov    0x8(%ebp),%eax
  80221c:	c1 e8 16             	shr    $0x16,%eax
  80221f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  802226:	a8 01                	test   $0x1,%al
  802228:	74 21                	je     80224b <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  80222a:	8b 45 08             	mov    0x8(%ebp),%eax
  80222d:	c1 e8 0c             	shr    $0xc,%eax
  802230:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802237:	a8 01                	test   $0x1,%al
  802239:	74 17                	je     802252 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80223b:	c1 e8 0c             	shr    $0xc,%eax
  80223e:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  802245:	ef 
  802246:	0f b7 c0             	movzwl %ax,%eax
  802249:	eb 0c                	jmp    802257 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  80224b:	b8 00 00 00 00       	mov    $0x0,%eax
  802250:	eb 05                	jmp    802257 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  802252:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  802257:	5d                   	pop    %ebp
  802258:	c3                   	ret    
  802259:	66 90                	xchg   %ax,%ax
  80225b:	90                   	nop

0080225c <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  80225c:	55                   	push   %ebp
  80225d:	57                   	push   %edi
  80225e:	56                   	push   %esi
  80225f:	53                   	push   %ebx
  802260:	83 ec 1c             	sub    $0x1c,%esp
  802263:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  802267:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  80226b:	8b 7c 24 38          	mov    0x38(%esp),%edi
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  80226f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802273:	89 ca                	mov    %ecx,%edx
  const DWunion dd = {.ll = d};
  802275:	89 f8                	mov    %edi,%eax
  802277:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  80227b:	85 f6                	test   %esi,%esi
  80227d:	75 2d                	jne    8022ac <__udivdi3+0x50>
    {
      if (d0 > n1)
  80227f:	39 cf                	cmp    %ecx,%edi
  802281:	77 65                	ja     8022e8 <__udivdi3+0x8c>
  802283:	89 fd                	mov    %edi,%ebp
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802285:	85 ff                	test   %edi,%edi
  802287:	75 0b                	jne    802294 <__udivdi3+0x38>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802289:	b8 01 00 00 00       	mov    $0x1,%eax
  80228e:	31 d2                	xor    %edx,%edx
  802290:	f7 f7                	div    %edi
  802292:	89 c5                	mov    %eax,%ebp

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802294:	31 d2                	xor    %edx,%edx
  802296:	89 c8                	mov    %ecx,%eax
  802298:	f7 f5                	div    %ebp
  80229a:	89 c1                	mov    %eax,%ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80229c:	89 d8                	mov    %ebx,%eax
  80229e:	f7 f5                	div    %ebp
  8022a0:	89 cf                	mov    %ecx,%edi
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8022a2:	89 fa                	mov    %edi,%edx
  8022a4:	83 c4 1c             	add    $0x1c,%esp
  8022a7:	5b                   	pop    %ebx
  8022a8:	5e                   	pop    %esi
  8022a9:	5f                   	pop    %edi
  8022aa:	5d                   	pop    %ebp
  8022ab:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8022ac:	39 ce                	cmp    %ecx,%esi
  8022ae:	77 28                	ja     8022d8 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8022b0:	0f bd fe             	bsr    %esi,%edi
	  if (bm == 0)
  8022b3:	83 f7 1f             	xor    $0x1f,%edi
  8022b6:	75 40                	jne    8022f8 <__udivdi3+0x9c>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8022b8:	39 ce                	cmp    %ecx,%esi
  8022ba:	72 0a                	jb     8022c6 <__udivdi3+0x6a>
  8022bc:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8022c0:	0f 87 9e 00 00 00    	ja     802364 <__udivdi3+0x108>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8022c6:	b8 01 00 00 00       	mov    $0x1,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8022cb:	89 fa                	mov    %edi,%edx
  8022cd:	83 c4 1c             	add    $0x1c,%esp
  8022d0:	5b                   	pop    %ebx
  8022d1:	5e                   	pop    %esi
  8022d2:	5f                   	pop    %edi
  8022d3:	5d                   	pop    %ebp
  8022d4:	c3                   	ret    
  8022d5:	8d 76 00             	lea    0x0(%esi),%esi
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8022d8:	31 ff                	xor    %edi,%edi
  8022da:	31 c0                	xor    %eax,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8022dc:	89 fa                	mov    %edi,%edx
  8022de:	83 c4 1c             	add    $0x1c,%esp
  8022e1:	5b                   	pop    %ebx
  8022e2:	5e                   	pop    %esi
  8022e3:	5f                   	pop    %edi
  8022e4:	5d                   	pop    %ebp
  8022e5:	c3                   	ret    
  8022e6:	66 90                	xchg   %ax,%ax
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8022e8:	89 d8                	mov    %ebx,%eax
  8022ea:	f7 f7                	div    %edi
  8022ec:	31 ff                	xor    %edi,%edi
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8022ee:	89 fa                	mov    %edi,%edx
  8022f0:	83 c4 1c             	add    $0x1c,%esp
  8022f3:	5b                   	pop    %ebx
  8022f4:	5e                   	pop    %esi
  8022f5:	5f                   	pop    %edi
  8022f6:	5d                   	pop    %ebp
  8022f7:	c3                   	ret    
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8022f8:	bd 20 00 00 00       	mov    $0x20,%ebp
  8022fd:	89 eb                	mov    %ebp,%ebx
  8022ff:	29 fb                	sub    %edi,%ebx

	      d1 = (d1 << bm) | (d0 >> b);
  802301:	89 f9                	mov    %edi,%ecx
  802303:	d3 e6                	shl    %cl,%esi
  802305:	89 c5                	mov    %eax,%ebp
  802307:	88 d9                	mov    %bl,%cl
  802309:	d3 ed                	shr    %cl,%ebp
  80230b:	89 e9                	mov    %ebp,%ecx
  80230d:	09 f1                	or     %esi,%ecx
  80230f:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
	      d0 = d0 << bm;
  802313:	89 f9                	mov    %edi,%ecx
  802315:	d3 e0                	shl    %cl,%eax
  802317:	89 c5                	mov    %eax,%ebp
	      n2 = n1 >> b;
  802319:	89 d6                	mov    %edx,%esi
  80231b:	88 d9                	mov    %bl,%cl
  80231d:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
  80231f:	89 f9                	mov    %edi,%ecx
  802321:	d3 e2                	shl    %cl,%edx
  802323:	8b 44 24 08          	mov    0x8(%esp),%eax
  802327:	88 d9                	mov    %bl,%cl
  802329:	d3 e8                	shr    %cl,%eax
  80232b:	09 c2                	or     %eax,%edx
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  80232d:	89 d0                	mov    %edx,%eax
  80232f:	89 f2                	mov    %esi,%edx
  802331:	f7 74 24 0c          	divl   0xc(%esp)
  802335:	89 d6                	mov    %edx,%esi
  802337:	89 c3                	mov    %eax,%ebx
	      umul_ppmm (m1, m0, q0, d0);
  802339:	f7 e5                	mul    %ebp

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80233b:	39 d6                	cmp    %edx,%esi
  80233d:	72 19                	jb     802358 <__udivdi3+0xfc>
  80233f:	74 0b                	je     80234c <__udivdi3+0xf0>
  802341:	89 d8                	mov    %ebx,%eax
  802343:	31 ff                	xor    %edi,%edi
  802345:	e9 58 ff ff ff       	jmp    8022a2 <__udivdi3+0x46>
  80234a:	66 90                	xchg   %ax,%ax
  80234c:	8b 54 24 08          	mov    0x8(%esp),%edx
  802350:	89 f9                	mov    %edi,%ecx
  802352:	d3 e2                	shl    %cl,%edx
  802354:	39 c2                	cmp    %eax,%edx
  802356:	73 e9                	jae    802341 <__udivdi3+0xe5>
  802358:	8d 43 ff             	lea    -0x1(%ebx),%eax
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  80235b:	31 ff                	xor    %edi,%edi
  80235d:	e9 40 ff ff ff       	jmp    8022a2 <__udivdi3+0x46>
  802362:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802364:	31 c0                	xor    %eax,%eax
  802366:	e9 37 ff ff ff       	jmp    8022a2 <__udivdi3+0x46>
  80236b:	90                   	nop

0080236c <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  80236c:	55                   	push   %ebp
  80236d:	57                   	push   %edi
  80236e:	56                   	push   %esi
  80236f:	53                   	push   %ebx
  802370:	83 ec 1c             	sub    $0x1c,%esp
  802373:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  802377:	8b 74 24 34          	mov    0x34(%esp),%esi
  80237b:	8b 7c 24 38          	mov    0x38(%esp),%edi
  80237f:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  802383:	89 44 24 0c          	mov    %eax,0xc(%esp)
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  802387:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80238b:	89 f3                	mov    %esi,%ebx
  const DWunion dd = {.ll = d};
  80238d:	89 fa                	mov    %edi,%edx
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  80238f:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  n1 = nn.s.high;
  802393:	89 34 24             	mov    %esi,(%esp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802396:	85 c0                	test   %eax,%eax
  802398:	75 1a                	jne    8023b4 <__umoddi3+0x48>
    {
      if (d0 > n1)
  80239a:	39 f7                	cmp    %esi,%edi
  80239c:	0f 86 a2 00 00 00    	jbe    802444 <__umoddi3+0xd8>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8023a2:	89 c8                	mov    %ecx,%eax
  8023a4:	89 f2                	mov    %esi,%edx
  8023a6:	f7 f7                	div    %edi
  8023a8:	89 d0                	mov    %edx,%eax

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  8023aa:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8023ac:	83 c4 1c             	add    $0x1c,%esp
  8023af:	5b                   	pop    %ebx
  8023b0:	5e                   	pop    %esi
  8023b1:	5f                   	pop    %edi
  8023b2:	5d                   	pop    %ebp
  8023b3:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8023b4:	39 f0                	cmp    %esi,%eax
  8023b6:	0f 87 ac 00 00 00    	ja     802468 <__umoddi3+0xfc>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8023bc:	0f bd e8             	bsr    %eax,%ebp
	  if (bm == 0)
  8023bf:	83 f5 1f             	xor    $0x1f,%ebp
  8023c2:	0f 84 ac 00 00 00    	je     802474 <__umoddi3+0x108>
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8023c8:	bf 20 00 00 00       	mov    $0x20,%edi
  8023cd:	29 ef                	sub    %ebp,%edi
  8023cf:	89 fe                	mov    %edi,%esi
  8023d1:	89 7c 24 0c          	mov    %edi,0xc(%esp)

	      d1 = (d1 << bm) | (d0 >> b);
  8023d5:	89 e9                	mov    %ebp,%ecx
  8023d7:	d3 e0                	shl    %cl,%eax
  8023d9:	89 d7                	mov    %edx,%edi
  8023db:	89 f1                	mov    %esi,%ecx
  8023dd:	d3 ef                	shr    %cl,%edi
  8023df:	09 c7                	or     %eax,%edi
	      d0 = d0 << bm;
  8023e1:	89 e9                	mov    %ebp,%ecx
  8023e3:	d3 e2                	shl    %cl,%edx
  8023e5:	89 14 24             	mov    %edx,(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8023e8:	89 d8                	mov    %ebx,%eax
  8023ea:	d3 e0                	shl    %cl,%eax
  8023ec:	89 c2                	mov    %eax,%edx
	      n0 = n0 << bm;
  8023ee:	8b 44 24 08          	mov    0x8(%esp),%eax
  8023f2:	d3 e0                	shl    %cl,%eax
  8023f4:	89 44 24 04          	mov    %eax,0x4(%esp)

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8023f8:	8b 44 24 08          	mov    0x8(%esp),%eax
  8023fc:	89 f1                	mov    %esi,%ecx
  8023fe:	d3 e8                	shr    %cl,%eax
  802400:	09 d0                	or     %edx,%eax
  802402:	d3 eb                	shr    %cl,%ebx
  802404:	89 da                	mov    %ebx,%edx
  802406:	f7 f7                	div    %edi
  802408:	89 d3                	mov    %edx,%ebx
	      umul_ppmm (m1, m0, q0, d0);
  80240a:	f7 24 24             	mull   (%esp)
  80240d:	89 c6                	mov    %eax,%esi
  80240f:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802411:	39 d3                	cmp    %edx,%ebx
  802413:	0f 82 87 00 00 00    	jb     8024a0 <__umoddi3+0x134>
  802419:	0f 84 91 00 00 00    	je     8024b0 <__umoddi3+0x144>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  80241f:	8b 54 24 04          	mov    0x4(%esp),%edx
  802423:	29 f2                	sub    %esi,%edx
  802425:	19 cb                	sbb    %ecx,%ebx
		  rr.s.low = (n1 << b) | (n0 >> bm);
  802427:	89 d8                	mov    %ebx,%eax
  802429:	8a 4c 24 0c          	mov    0xc(%esp),%cl
  80242d:	d3 e0                	shl    %cl,%eax
  80242f:	89 e9                	mov    %ebp,%ecx
  802431:	d3 ea                	shr    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  802433:	09 d0                	or     %edx,%eax
  802435:	89 e9                	mov    %ebp,%ecx
  802437:	d3 eb                	shr    %cl,%ebx
  802439:	89 da                	mov    %ebx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80243b:	83 c4 1c             	add    $0x1c,%esp
  80243e:	5b                   	pop    %ebx
  80243f:	5e                   	pop    %esi
  802440:	5f                   	pop    %edi
  802441:	5d                   	pop    %ebp
  802442:	c3                   	ret    
  802443:	90                   	nop
  802444:	89 fd                	mov    %edi,%ebp
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802446:	85 ff                	test   %edi,%edi
  802448:	75 0b                	jne    802455 <__umoddi3+0xe9>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  80244a:	b8 01 00 00 00       	mov    $0x1,%eax
  80244f:	31 d2                	xor    %edx,%edx
  802451:	f7 f7                	div    %edi
  802453:	89 c5                	mov    %eax,%ebp

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802455:	89 f0                	mov    %esi,%eax
  802457:	31 d2                	xor    %edx,%edx
  802459:	f7 f5                	div    %ebp
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80245b:	89 c8                	mov    %ecx,%eax
  80245d:	f7 f5                	div    %ebp
  80245f:	89 d0                	mov    %edx,%eax
  802461:	e9 44 ff ff ff       	jmp    8023aa <__umoddi3+0x3e>
  802466:	66 90                	xchg   %ax,%ax
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  802468:	89 c8                	mov    %ecx,%eax
  80246a:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80246c:	83 c4 1c             	add    $0x1c,%esp
  80246f:	5b                   	pop    %ebx
  802470:	5e                   	pop    %esi
  802471:	5f                   	pop    %edi
  802472:	5d                   	pop    %ebp
  802473:	c3                   	ret    

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802474:	3b 04 24             	cmp    (%esp),%eax
  802477:	72 06                	jb     80247f <__umoddi3+0x113>
  802479:	3b 7c 24 04          	cmp    0x4(%esp),%edi
  80247d:	77 0f                	ja     80248e <__umoddi3+0x122>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  80247f:	89 f2                	mov    %esi,%edx
  802481:	29 f9                	sub    %edi,%ecx
  802483:	1b 54 24 0c          	sbb    0xc(%esp),%edx
  802487:	89 14 24             	mov    %edx,(%esp)
  80248a:	89 4c 24 04          	mov    %ecx,0x4(%esp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  80248e:	8b 44 24 04          	mov    0x4(%esp),%eax
  802492:	8b 14 24             	mov    (%esp),%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802495:	83 c4 1c             	add    $0x1c,%esp
  802498:	5b                   	pop    %ebx
  802499:	5e                   	pop    %esi
  80249a:	5f                   	pop    %edi
  80249b:	5d                   	pop    %ebp
  80249c:	c3                   	ret    
  80249d:	8d 76 00             	lea    0x0(%esi),%esi
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8024a0:	2b 04 24             	sub    (%esp),%eax
  8024a3:	19 fa                	sbb    %edi,%edx
  8024a5:	89 d1                	mov    %edx,%ecx
  8024a7:	89 c6                	mov    %eax,%esi
  8024a9:	e9 71 ff ff ff       	jmp    80241f <__umoddi3+0xb3>
  8024ae:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8024b0:	39 44 24 04          	cmp    %eax,0x4(%esp)
  8024b4:	72 ea                	jb     8024a0 <__umoddi3+0x134>
  8024b6:	89 d9                	mov    %ebx,%ecx
  8024b8:	e9 62 ff ff ff       	jmp    80241f <__umoddi3+0xb3>
