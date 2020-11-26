
obj/user/pingpongs.debug:     file format elf32-i386


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
  80002c:	e8 cb 00 00 00       	call   8000fc <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

uint32_t val;

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 2c             	sub    $0x2c,%esp
	envid_t who;
	uint32_t i;

	i = 0;
	if ((who = sfork()) != 0) {
  80003c:	e8 bd 10 00 00       	call   8010fe <sfork>
  800041:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800044:	85 c0                	test   %eax,%eax
  800046:	74 42                	je     80008a <umain+0x57>
		cprintf("i am %08x; thisenv is %p\n", sys_getenvid(), thisenv);
  800048:	8b 1d 08 40 80 00    	mov    0x804008,%ebx
  80004e:	e8 bb 0b 00 00       	call   800c0e <sys_getenvid>
  800053:	83 ec 04             	sub    $0x4,%esp
  800056:	53                   	push   %ebx
  800057:	50                   	push   %eax
  800058:	68 80 22 80 00       	push   $0x802280
  80005d:	e8 95 01 00 00       	call   8001f7 <cprintf>
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  800062:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800065:	e8 a4 0b 00 00       	call   800c0e <sys_getenvid>
  80006a:	83 c4 0c             	add    $0xc,%esp
  80006d:	53                   	push   %ebx
  80006e:	50                   	push   %eax
  80006f:	68 9a 22 80 00       	push   $0x80229a
  800074:	e8 7e 01 00 00       	call   8001f7 <cprintf>
		ipc_send(who, 0, 0, 0);
  800079:	6a 00                	push   $0x0
  80007b:	6a 00                	push   $0x0
  80007d:	6a 00                	push   $0x0
  80007f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800082:	e8 06 11 00 00       	call   80118d <ipc_send>
  800087:	83 c4 20             	add    $0x20,%esp
	}

	while (1) {
		ipc_recv(&who, 0, 0);
  80008a:	83 ec 04             	sub    $0x4,%esp
  80008d:	6a 00                	push   $0x0
  80008f:	6a 00                	push   $0x0
  800091:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800094:	50                   	push   %eax
  800095:	e8 7e 10 00 00       	call   801118 <ipc_recv>
		cprintf("%x got %d from %x (thisenv is %p %x)\n", sys_getenvid(), val, who, thisenv, thisenv->env_id);
  80009a:	8b 1d 08 40 80 00    	mov    0x804008,%ebx
  8000a0:	8b 7b 48             	mov    0x48(%ebx),%edi
  8000a3:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8000a6:	a1 04 40 80 00       	mov    0x804004,%eax
  8000ab:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8000ae:	e8 5b 0b 00 00       	call   800c0e <sys_getenvid>
  8000b3:	83 c4 08             	add    $0x8,%esp
  8000b6:	57                   	push   %edi
  8000b7:	53                   	push   %ebx
  8000b8:	56                   	push   %esi
  8000b9:	ff 75 d4             	pushl  -0x2c(%ebp)
  8000bc:	50                   	push   %eax
  8000bd:	68 b0 22 80 00       	push   $0x8022b0
  8000c2:	e8 30 01 00 00       	call   8001f7 <cprintf>
		if (val == 10)
  8000c7:	a1 04 40 80 00       	mov    0x804004,%eax
  8000cc:	83 c4 20             	add    $0x20,%esp
  8000cf:	83 f8 0a             	cmp    $0xa,%eax
  8000d2:	74 20                	je     8000f4 <umain+0xc1>
			return;
		++val;
  8000d4:	40                   	inc    %eax
  8000d5:	a3 04 40 80 00       	mov    %eax,0x804004
		ipc_send(who, 0, 0, 0);
  8000da:	6a 00                	push   $0x0
  8000dc:	6a 00                	push   $0x0
  8000de:	6a 00                	push   $0x0
  8000e0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8000e3:	e8 a5 10 00 00       	call   80118d <ipc_send>
		if (val == 10)
  8000e8:	83 c4 10             	add    $0x10,%esp
  8000eb:	83 3d 04 40 80 00 0a 	cmpl   $0xa,0x804004
  8000f2:	75 96                	jne    80008a <umain+0x57>
			return;
	}

}
  8000f4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000f7:	5b                   	pop    %ebx
  8000f8:	5e                   	pop    %esi
  8000f9:	5f                   	pop    %edi
  8000fa:	5d                   	pop    %ebp
  8000fb:	c3                   	ret    

008000fc <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000fc:	55                   	push   %ebp
  8000fd:	89 e5                	mov    %esp,%ebp
  8000ff:	56                   	push   %esi
  800100:	53                   	push   %ebx
  800101:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800104:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800107:	e8 02 0b 00 00       	call   800c0e <sys_getenvid>
  80010c:	25 ff 03 00 00       	and    $0x3ff,%eax
  800111:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800118:	c1 e0 07             	shl    $0x7,%eax
  80011b:	29 d0                	sub    %edx,%eax
  80011d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800122:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800127:	85 db                	test   %ebx,%ebx
  800129:	7e 07                	jle    800132 <libmain+0x36>
		binaryname = argv[0];
  80012b:	8b 06                	mov    (%esi),%eax
  80012d:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800132:	83 ec 08             	sub    $0x8,%esp
  800135:	56                   	push   %esi
  800136:	53                   	push   %ebx
  800137:	e8 f7 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80013c:	e8 0a 00 00 00       	call   80014b <exit>
}
  800141:	83 c4 10             	add    $0x10,%esp
  800144:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800147:	5b                   	pop    %ebx
  800148:	5e                   	pop    %esi
  800149:	5d                   	pop    %ebp
  80014a:	c3                   	ret    

0080014b <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80014b:	55                   	push   %ebp
  80014c:	89 e5                	mov    %esp,%ebp
  80014e:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800151:	e8 00 13 00 00       	call   801456 <close_all>
	sys_env_destroy(0);
  800156:	83 ec 0c             	sub    $0xc,%esp
  800159:	6a 00                	push   $0x0
  80015b:	e8 6d 0a 00 00       	call   800bcd <sys_env_destroy>
}
  800160:	83 c4 10             	add    $0x10,%esp
  800163:	c9                   	leave  
  800164:	c3                   	ret    

00800165 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800165:	55                   	push   %ebp
  800166:	89 e5                	mov    %esp,%ebp
  800168:	53                   	push   %ebx
  800169:	83 ec 04             	sub    $0x4,%esp
  80016c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80016f:	8b 13                	mov    (%ebx),%edx
  800171:	8d 42 01             	lea    0x1(%edx),%eax
  800174:	89 03                	mov    %eax,(%ebx)
  800176:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800179:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80017d:	3d ff 00 00 00       	cmp    $0xff,%eax
  800182:	75 1a                	jne    80019e <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800184:	83 ec 08             	sub    $0x8,%esp
  800187:	68 ff 00 00 00       	push   $0xff
  80018c:	8d 43 08             	lea    0x8(%ebx),%eax
  80018f:	50                   	push   %eax
  800190:	e8 fb 09 00 00       	call   800b90 <sys_cputs>
		b->idx = 0;
  800195:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80019b:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80019e:	ff 43 04             	incl   0x4(%ebx)
}
  8001a1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001a4:	c9                   	leave  
  8001a5:	c3                   	ret    

008001a6 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001a6:	55                   	push   %ebp
  8001a7:	89 e5                	mov    %esp,%ebp
  8001a9:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001af:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001b6:	00 00 00 
	b.cnt = 0;
  8001b9:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001c0:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001c3:	ff 75 0c             	pushl  0xc(%ebp)
  8001c6:	ff 75 08             	pushl  0x8(%ebp)
  8001c9:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001cf:	50                   	push   %eax
  8001d0:	68 65 01 80 00       	push   $0x800165
  8001d5:	e8 54 01 00 00       	call   80032e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001da:	83 c4 08             	add    $0x8,%esp
  8001dd:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001e3:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001e9:	50                   	push   %eax
  8001ea:	e8 a1 09 00 00       	call   800b90 <sys_cputs>

	return b.cnt;
}
  8001ef:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001f5:	c9                   	leave  
  8001f6:	c3                   	ret    

008001f7 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001f7:	55                   	push   %ebp
  8001f8:	89 e5                	mov    %esp,%ebp
  8001fa:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001fd:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800200:	50                   	push   %eax
  800201:	ff 75 08             	pushl  0x8(%ebp)
  800204:	e8 9d ff ff ff       	call   8001a6 <vcprintf>
	va_end(ap);

	return cnt;
}
  800209:	c9                   	leave  
  80020a:	c3                   	ret    

0080020b <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80020b:	55                   	push   %ebp
  80020c:	89 e5                	mov    %esp,%ebp
  80020e:	57                   	push   %edi
  80020f:	56                   	push   %esi
  800210:	53                   	push   %ebx
  800211:	83 ec 1c             	sub    $0x1c,%esp
  800214:	89 c6                	mov    %eax,%esi
  800216:	89 d7                	mov    %edx,%edi
  800218:	8b 45 08             	mov    0x8(%ebp),%eax
  80021b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80021e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800221:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800224:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800227:	bb 00 00 00 00       	mov    $0x0,%ebx
  80022c:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80022f:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800232:	39 d3                	cmp    %edx,%ebx
  800234:	72 11                	jb     800247 <printnum+0x3c>
  800236:	39 45 10             	cmp    %eax,0x10(%ebp)
  800239:	76 0c                	jbe    800247 <printnum+0x3c>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80023b:	8b 45 14             	mov    0x14(%ebp),%eax
  80023e:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800241:	85 db                	test   %ebx,%ebx
  800243:	7f 37                	jg     80027c <printnum+0x71>
  800245:	eb 44                	jmp    80028b <printnum+0x80>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800247:	83 ec 0c             	sub    $0xc,%esp
  80024a:	ff 75 18             	pushl  0x18(%ebp)
  80024d:	8b 45 14             	mov    0x14(%ebp),%eax
  800250:	48                   	dec    %eax
  800251:	50                   	push   %eax
  800252:	ff 75 10             	pushl  0x10(%ebp)
  800255:	83 ec 08             	sub    $0x8,%esp
  800258:	ff 75 e4             	pushl  -0x1c(%ebp)
  80025b:	ff 75 e0             	pushl  -0x20(%ebp)
  80025e:	ff 75 dc             	pushl  -0x24(%ebp)
  800261:	ff 75 d8             	pushl  -0x28(%ebp)
  800264:	e8 9f 1d 00 00       	call   802008 <__udivdi3>
  800269:	83 c4 18             	add    $0x18,%esp
  80026c:	52                   	push   %edx
  80026d:	50                   	push   %eax
  80026e:	89 fa                	mov    %edi,%edx
  800270:	89 f0                	mov    %esi,%eax
  800272:	e8 94 ff ff ff       	call   80020b <printnum>
  800277:	83 c4 20             	add    $0x20,%esp
  80027a:	eb 0f                	jmp    80028b <printnum+0x80>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80027c:	83 ec 08             	sub    $0x8,%esp
  80027f:	57                   	push   %edi
  800280:	ff 75 18             	pushl  0x18(%ebp)
  800283:	ff d6                	call   *%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800285:	83 c4 10             	add    $0x10,%esp
  800288:	4b                   	dec    %ebx
  800289:	75 f1                	jne    80027c <printnum+0x71>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80028b:	83 ec 08             	sub    $0x8,%esp
  80028e:	57                   	push   %edi
  80028f:	83 ec 04             	sub    $0x4,%esp
  800292:	ff 75 e4             	pushl  -0x1c(%ebp)
  800295:	ff 75 e0             	pushl  -0x20(%ebp)
  800298:	ff 75 dc             	pushl  -0x24(%ebp)
  80029b:	ff 75 d8             	pushl  -0x28(%ebp)
  80029e:	e8 75 1e 00 00       	call   802118 <__umoddi3>
  8002a3:	83 c4 14             	add    $0x14,%esp
  8002a6:	0f be 80 e0 22 80 00 	movsbl 0x8022e0(%eax),%eax
  8002ad:	50                   	push   %eax
  8002ae:	ff d6                	call   *%esi
}
  8002b0:	83 c4 10             	add    $0x10,%esp
  8002b3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002b6:	5b                   	pop    %ebx
  8002b7:	5e                   	pop    %esi
  8002b8:	5f                   	pop    %edi
  8002b9:	5d                   	pop    %ebp
  8002ba:	c3                   	ret    

008002bb <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002bb:	55                   	push   %ebp
  8002bc:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002be:	83 fa 01             	cmp    $0x1,%edx
  8002c1:	7e 0e                	jle    8002d1 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002c3:	8b 10                	mov    (%eax),%edx
  8002c5:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002c8:	89 08                	mov    %ecx,(%eax)
  8002ca:	8b 02                	mov    (%edx),%eax
  8002cc:	8b 52 04             	mov    0x4(%edx),%edx
  8002cf:	eb 22                	jmp    8002f3 <getuint+0x38>
	else if (lflag)
  8002d1:	85 d2                	test   %edx,%edx
  8002d3:	74 10                	je     8002e5 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002d5:	8b 10                	mov    (%eax),%edx
  8002d7:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002da:	89 08                	mov    %ecx,(%eax)
  8002dc:	8b 02                	mov    (%edx),%eax
  8002de:	ba 00 00 00 00       	mov    $0x0,%edx
  8002e3:	eb 0e                	jmp    8002f3 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002e5:	8b 10                	mov    (%eax),%edx
  8002e7:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002ea:	89 08                	mov    %ecx,(%eax)
  8002ec:	8b 02                	mov    (%edx),%eax
  8002ee:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002f3:	5d                   	pop    %ebp
  8002f4:	c3                   	ret    

008002f5 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002f5:	55                   	push   %ebp
  8002f6:	89 e5                	mov    %esp,%ebp
  8002f8:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002fb:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8002fe:	8b 10                	mov    (%eax),%edx
  800300:	3b 50 04             	cmp    0x4(%eax),%edx
  800303:	73 0a                	jae    80030f <sprintputch+0x1a>
		*b->buf++ = ch;
  800305:	8d 4a 01             	lea    0x1(%edx),%ecx
  800308:	89 08                	mov    %ecx,(%eax)
  80030a:	8b 45 08             	mov    0x8(%ebp),%eax
  80030d:	88 02                	mov    %al,(%edx)
}
  80030f:	5d                   	pop    %ebp
  800310:	c3                   	ret    

00800311 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800311:	55                   	push   %ebp
  800312:	89 e5                	mov    %esp,%ebp
  800314:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800317:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80031a:	50                   	push   %eax
  80031b:	ff 75 10             	pushl  0x10(%ebp)
  80031e:	ff 75 0c             	pushl  0xc(%ebp)
  800321:	ff 75 08             	pushl  0x8(%ebp)
  800324:	e8 05 00 00 00       	call   80032e <vprintfmt>
	va_end(ap);
}
  800329:	83 c4 10             	add    $0x10,%esp
  80032c:	c9                   	leave  
  80032d:	c3                   	ret    

0080032e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80032e:	55                   	push   %ebp
  80032f:	89 e5                	mov    %esp,%ebp
  800331:	57                   	push   %edi
  800332:	56                   	push   %esi
  800333:	53                   	push   %ebx
  800334:	83 ec 2c             	sub    $0x2c,%esp
  800337:	8b 7d 08             	mov    0x8(%ebp),%edi
  80033a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80033d:	eb 03                	jmp    800342 <vprintfmt+0x14>
			break;

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
			for (fmt--; fmt[-1] != '%'; fmt--)
  80033f:	89 75 10             	mov    %esi,0x10(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {    //遍历输入的第一个参数，即输出信息的格式，先把格式字符串中'%'之前的字符一个个输出，因为它们前面没有'%'，所以它们就是要直接显示在屏幕上的
  800342:	8b 45 10             	mov    0x10(%ebp),%eax
  800345:	8d 70 01             	lea    0x1(%eax),%esi
  800348:	0f b6 00             	movzbl (%eax),%eax
  80034b:	83 f8 25             	cmp    $0x25,%eax
  80034e:	74 25                	je     800375 <vprintfmt+0x47>
			if (ch == '\0')									//当然中间如果遇到'\0'，代表这个字符串的访问结束
  800350:	85 c0                	test   %eax,%eax
  800352:	75 0d                	jne    800361 <vprintfmt+0x33>
  800354:	e9 b5 03 00 00       	jmp    80070e <vprintfmt+0x3e0>
  800359:	85 c0                	test   %eax,%eax
  80035b:	0f 84 ad 03 00 00    	je     80070e <vprintfmt+0x3e0>
				return;
			putch(ch, putdat);								//调用putch函数，把一个字符ch输出到putdat指针所指向的地址中所存放的值对应的地址处
  800361:	83 ec 08             	sub    $0x8,%esp
  800364:	53                   	push   %ebx
  800365:	50                   	push   %eax
  800366:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {    //遍历输入的第一个参数，即输出信息的格式，先把格式字符串中'%'之前的字符一个个输出，因为它们前面没有'%'，所以它们就是要直接显示在屏幕上的
  800368:	46                   	inc    %esi
  800369:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  80036d:	83 c4 10             	add    $0x10,%esp
  800370:	83 f8 25             	cmp    $0x25,%eax
  800373:	75 e4                	jne    800359 <vprintfmt+0x2b>
			if (width < 0)									//代表有小数点，但是小数点前面并没有数字，比如'%.6f'这种情况，此时代表整数部分全部显示
				width = 0;			
			goto reswitch;

		case '#':
			altflag = 1;
  800375:	c6 45 e3 20          	movb   $0x20,-0x1d(%ebp)
  800379:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800380:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800387:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80038e:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800395:	eb 07                	jmp    80039e <vprintfmt+0x70>
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  800397:	8b 75 10             	mov    0x10(%ebp),%esi

		// flag to pad on the right
		case '-':											//%后面的'-'代表要进行左对齐输出，右边填空格，如果省略代表右对齐
			padc = '-';										//如果有这个字符代表左对齐，则把对齐方式标志位变为'-'
  80039a:	c6 45 e3 2d          	movb   $0x2d,-0x1d(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  80039e:	8d 46 01             	lea    0x1(%esi),%eax
  8003a1:	89 45 10             	mov    %eax,0x10(%ebp)
  8003a4:	0f b6 16             	movzbl (%esi),%edx
  8003a7:	8a 06                	mov    (%esi),%al
  8003a9:	83 e8 23             	sub    $0x23,%eax
  8003ac:	3c 55                	cmp    $0x55,%al
  8003ae:	0f 87 03 03 00 00    	ja     8006b7 <vprintfmt+0x389>
  8003b4:	0f b6 c0             	movzbl %al,%eax
  8003b7:	ff 24 85 20 24 80 00 	jmp    *0x802420(,%eax,4)
  8003be:	8b 75 10             	mov    0x10(%ebp),%esi
			padc = '-';										//如果有这个字符代表左对齐，则把对齐方式标志位变为'-'
			goto reswitch;									//处理下一个字符

		// flag to pad with 0's instead of spaces
		case '0':											//0--有0表示进行对齐输出时填0,如省略表示填入空格，并且如果为0，则一定是右对齐
			padc = '0';										//对其方式标志位变为0
  8003c1:	c6 45 e3 30          	movb   $0x30,-0x1d(%ebp)
  8003c5:	eb d7                	jmp    80039e <vprintfmt+0x70>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {					//把遇到的位数字符串转换为真实的位数，比如输入的'%40'，代表有效位数为40位，下面的循环就是把precesion的值设置为40
				precision = precision * 10 + ch - '0';
  8003c7:	8d 42 d0             	lea    -0x30(%edx),%eax
  8003ca:	89 c1                	mov    %eax,%ecx
  8003cc:	89 45 d0             	mov    %eax,-0x30(%ebp)
				ch = *fmt;
  8003cf:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  8003d3:	8d 50 d0             	lea    -0x30(%eax),%edx
  8003d6:	83 fa 09             	cmp    $0x9,%edx
  8003d9:	77 51                	ja     80042c <vprintfmt+0xfe>
  8003db:	8b 75 10             	mov    0x10(%ebp),%esi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {					//把遇到的位数字符串转换为真实的位数，比如输入的'%40'，代表有效位数为40位，下面的循环就是把precesion的值设置为40
  8003de:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  8003df:	8d 14 89             	lea    (%ecx,%ecx,4),%edx
  8003e2:	01 d2                	add    %edx,%edx
  8003e4:	8d 4c 10 d0          	lea    -0x30(%eax,%edx,1),%ecx
				ch = *fmt;
  8003e8:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8003eb:	8d 50 d0             	lea    -0x30(%eax),%edx
  8003ee:	83 fa 09             	cmp    $0x9,%edx
  8003f1:	76 eb                	jbe    8003de <vprintfmt+0xb0>
  8003f3:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8003f6:	eb 37                	jmp    80042f <vprintfmt+0x101>
					break;
			}
			goto process_precision;							//跳转到process_precistion子过程

		case '*':											//*--代表有效数字的位数也是由输入参数指定的，比如printf("%*.*f", 10, 2, n)，其中10,2就是用来指定显示的有效数字位数的
			precision = va_arg(ap, int);
  8003f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8003fb:	8d 50 04             	lea    0x4(%eax),%edx
  8003fe:	89 55 14             	mov    %edx,0x14(%ebp)
  800401:	8b 00                	mov    (%eax),%eax
  800403:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  800406:	8b 75 10             	mov    0x10(%ebp),%esi
			}
			goto process_precision;							//跳转到process_precistion子过程

		case '*':											//*--代表有效数字的位数也是由输入参数指定的，比如printf("%*.*f", 10, 2, n)，其中10,2就是用来指定显示的有效数字位数的
			precision = va_arg(ap, int);
			goto process_precision;
  800409:	eb 24                	jmp    80042f <vprintfmt+0x101>
  80040b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80040f:	79 07                	jns    800418 <vprintfmt+0xea>
  800411:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  800418:	8b 75 10             	mov    0x10(%ebp),%esi
  80041b:	eb 81                	jmp    80039e <vprintfmt+0x70>
  80041d:	8b 75 10             	mov    0x10(%ebp),%esi
			if (width < 0)									//代表有小数点，但是小数点前面并没有数字，比如'%.6f'这种情况，此时代表整数部分全部显示
				width = 0;			
			goto reswitch;

		case '#':
			altflag = 1;
  800420:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800427:	e9 72 ff ff ff       	jmp    80039e <vprintfmt+0x70>
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  80042c:	8b 75 10             	mov    0x10(%ebp),%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:									//处理输出精度，把width字段赋值为刚刚计算出来的precision值，所以width应该是整数部分的有效数字位数
			if (width < 0)
  80042f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800433:	0f 89 65 ff ff ff    	jns    80039e <vprintfmt+0x70>
				width = precision, precision = -1;
  800439:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80043c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80043f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800446:	e9 53 ff ff ff       	jmp    80039e <vprintfmt+0x70>
			goto reswitch;

		// long flag (doubled for long long)				
		case 'l':											//如果遇到'l'，代表应该是输入long类型，如果有两个'l'代表long long
			lflag++;										//此时把lflag++
  80044b:	ff 45 d4             	incl   -0x2c(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  80044e:	8b 75 10             	mov    0x10(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)				
		case 'l':											//如果遇到'l'，代表应该是输入long类型，如果有两个'l'代表long long
			lflag++;										//此时把lflag++
			goto reswitch;
  800451:	e9 48 ff ff ff       	jmp    80039e <vprintfmt+0x70>

		// character
		case 'c':											//如果是'c'代表显示一个字符
			putch(va_arg(ap, int), putdat);					//调用输出一个字符到内存的函数putch
  800456:	8b 45 14             	mov    0x14(%ebp),%eax
  800459:	8d 50 04             	lea    0x4(%eax),%edx
  80045c:	89 55 14             	mov    %edx,0x14(%ebp)
  80045f:	83 ec 08             	sub    $0x8,%esp
  800462:	53                   	push   %ebx
  800463:	ff 30                	pushl  (%eax)
  800465:	ff d7                	call   *%edi
			break;
  800467:	83 c4 10             	add    $0x10,%esp
  80046a:	e9 d3 fe ff ff       	jmp    800342 <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80046f:	8b 45 14             	mov    0x14(%ebp),%eax
  800472:	8d 50 04             	lea    0x4(%eax),%edx
  800475:	89 55 14             	mov    %edx,0x14(%ebp)
  800478:	8b 00                	mov    (%eax),%eax
  80047a:	85 c0                	test   %eax,%eax
  80047c:	79 02                	jns    800480 <vprintfmt+0x152>
  80047e:	f7 d8                	neg    %eax
  800480:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800482:	83 f8 0f             	cmp    $0xf,%eax
  800485:	7f 0b                	jg     800492 <vprintfmt+0x164>
  800487:	8b 04 85 80 25 80 00 	mov    0x802580(,%eax,4),%eax
  80048e:	85 c0                	test   %eax,%eax
  800490:	75 15                	jne    8004a7 <vprintfmt+0x179>
				printfmt(putch, putdat, "error %d", err);
  800492:	52                   	push   %edx
  800493:	68 f8 22 80 00       	push   $0x8022f8
  800498:	53                   	push   %ebx
  800499:	57                   	push   %edi
  80049a:	e8 72 fe ff ff       	call   800311 <printfmt>
  80049f:	83 c4 10             	add    $0x10,%esp
  8004a2:	e9 9b fe ff ff       	jmp    800342 <vprintfmt+0x14>
			else
				printfmt(putch, putdat, "%s", p);
  8004a7:	50                   	push   %eax
  8004a8:	68 a7 27 80 00       	push   $0x8027a7
  8004ad:	53                   	push   %ebx
  8004ae:	57                   	push   %edi
  8004af:	e8 5d fe ff ff       	call   800311 <printfmt>
  8004b4:	83 c4 10             	add    $0x10,%esp
  8004b7:	e9 86 fe ff ff       	jmp    800342 <vprintfmt+0x14>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004bc:	8b 45 14             	mov    0x14(%ebp),%eax
  8004bf:	8d 50 04             	lea    0x4(%eax),%edx
  8004c2:	89 55 14             	mov    %edx,0x14(%ebp)
  8004c5:	8b 00                	mov    (%eax),%eax
  8004c7:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8004ca:	85 c0                	test   %eax,%eax
  8004cc:	75 07                	jne    8004d5 <vprintfmt+0x1a7>
				p = "(null)";
  8004ce:	c7 45 d4 f1 22 80 00 	movl   $0x8022f1,-0x2c(%ebp)
			if (width > 0 && padc != '-')
  8004d5:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8004d8:	85 f6                	test   %esi,%esi
  8004da:	0f 8e fb 01 00 00    	jle    8006db <vprintfmt+0x3ad>
  8004e0:	80 7d e3 2d          	cmpb   $0x2d,-0x1d(%ebp)
  8004e4:	0f 84 09 02 00 00    	je     8006f3 <vprintfmt+0x3c5>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ea:	83 ec 08             	sub    $0x8,%esp
  8004ed:	ff 75 d0             	pushl  -0x30(%ebp)
  8004f0:	ff 75 d4             	pushl  -0x2c(%ebp)
  8004f3:	e8 ad 02 00 00       	call   8007a5 <strnlen>
  8004f8:	89 f1                	mov    %esi,%ecx
  8004fa:	29 c1                	sub    %eax,%ecx
  8004fc:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  8004ff:	83 c4 10             	add    $0x10,%esp
  800502:	85 c9                	test   %ecx,%ecx
  800504:	0f 8e d1 01 00 00    	jle    8006db <vprintfmt+0x3ad>
					putch(padc, putdat);
  80050a:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  80050e:	83 ec 08             	sub    $0x8,%esp
  800511:	53                   	push   %ebx
  800512:	56                   	push   %esi
  800513:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800515:	83 c4 10             	add    $0x10,%esp
  800518:	ff 4d e4             	decl   -0x1c(%ebp)
  80051b:	75 f1                	jne    80050e <vprintfmt+0x1e0>
  80051d:	e9 b9 01 00 00       	jmp    8006db <vprintfmt+0x3ad>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800522:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800526:	74 19                	je     800541 <vprintfmt+0x213>
  800528:	0f be c0             	movsbl %al,%eax
  80052b:	83 e8 20             	sub    $0x20,%eax
  80052e:	83 f8 5e             	cmp    $0x5e,%eax
  800531:	76 0e                	jbe    800541 <vprintfmt+0x213>
					putch('?', putdat);
  800533:	83 ec 08             	sub    $0x8,%esp
  800536:	53                   	push   %ebx
  800537:	6a 3f                	push   $0x3f
  800539:	ff 55 08             	call   *0x8(%ebp)
  80053c:	83 c4 10             	add    $0x10,%esp
  80053f:	eb 0b                	jmp    80054c <vprintfmt+0x21e>
				else
					putch(ch, putdat);
  800541:	83 ec 08             	sub    $0x8,%esp
  800544:	53                   	push   %ebx
  800545:	52                   	push   %edx
  800546:	ff 55 08             	call   *0x8(%ebp)
  800549:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80054c:	ff 4d e4             	decl   -0x1c(%ebp)
  80054f:	46                   	inc    %esi
  800550:	8a 46 ff             	mov    -0x1(%esi),%al
  800553:	0f be d0             	movsbl %al,%edx
  800556:	85 d2                	test   %edx,%edx
  800558:	75 1c                	jne    800576 <vprintfmt+0x248>
  80055a:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80055d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800561:	7f 1f                	jg     800582 <vprintfmt+0x254>
  800563:	e9 da fd ff ff       	jmp    800342 <vprintfmt+0x14>
  800568:	89 7d 08             	mov    %edi,0x8(%ebp)
  80056b:	8b 7d d0             	mov    -0x30(%ebp),%edi
  80056e:	eb 06                	jmp    800576 <vprintfmt+0x248>
  800570:	89 7d 08             	mov    %edi,0x8(%ebp)
  800573:	8b 7d d0             	mov    -0x30(%ebp),%edi
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800576:	85 ff                	test   %edi,%edi
  800578:	78 a8                	js     800522 <vprintfmt+0x1f4>
  80057a:	4f                   	dec    %edi
  80057b:	79 a5                	jns    800522 <vprintfmt+0x1f4>
  80057d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800580:	eb db                	jmp    80055d <vprintfmt+0x22f>
  800582:	8b 75 e4             	mov    -0x1c(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800585:	83 ec 08             	sub    $0x8,%esp
  800588:	53                   	push   %ebx
  800589:	6a 20                	push   $0x20
  80058b:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80058d:	4e                   	dec    %esi
  80058e:	83 c4 10             	add    $0x10,%esp
  800591:	85 f6                	test   %esi,%esi
  800593:	7f f0                	jg     800585 <vprintfmt+0x257>
  800595:	e9 a8 fd ff ff       	jmp    800342 <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80059a:	83 7d d4 01          	cmpl   $0x1,-0x2c(%ebp)
  80059e:	7e 16                	jle    8005b6 <vprintfmt+0x288>
		return va_arg(*ap, long long);
  8005a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a3:	8d 50 08             	lea    0x8(%eax),%edx
  8005a6:	89 55 14             	mov    %edx,0x14(%ebp)
  8005a9:	8b 50 04             	mov    0x4(%eax),%edx
  8005ac:	8b 00                	mov    (%eax),%eax
  8005ae:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005b1:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005b4:	eb 34                	jmp    8005ea <vprintfmt+0x2bc>
	else if (lflag)
  8005b6:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8005ba:	74 18                	je     8005d4 <vprintfmt+0x2a6>
		return va_arg(*ap, long);
  8005bc:	8b 45 14             	mov    0x14(%ebp),%eax
  8005bf:	8d 50 04             	lea    0x4(%eax),%edx
  8005c2:	89 55 14             	mov    %edx,0x14(%ebp)
  8005c5:	8b 30                	mov    (%eax),%esi
  8005c7:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8005ca:	89 f0                	mov    %esi,%eax
  8005cc:	c1 f8 1f             	sar    $0x1f,%eax
  8005cf:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8005d2:	eb 16                	jmp    8005ea <vprintfmt+0x2bc>
	else
		return va_arg(*ap, int);
  8005d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d7:	8d 50 04             	lea    0x4(%eax),%edx
  8005da:	89 55 14             	mov    %edx,0x14(%ebp)
  8005dd:	8b 30                	mov    (%eax),%esi
  8005df:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8005e2:	89 f0                	mov    %esi,%eax
  8005e4:	c1 f8 1f             	sar    $0x1f,%eax
  8005e7:	89 45 dc             	mov    %eax,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005ea:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005ed:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
  8005f0:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005f4:	0f 89 8a 00 00 00    	jns    800684 <vprintfmt+0x356>
				putch('-', putdat);
  8005fa:	83 ec 08             	sub    $0x8,%esp
  8005fd:	53                   	push   %ebx
  8005fe:	6a 2d                	push   $0x2d
  800600:	ff d7                	call   *%edi
				num = -(long long) num;
  800602:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800605:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800608:	f7 d8                	neg    %eax
  80060a:	83 d2 00             	adc    $0x0,%edx
  80060d:	f7 da                	neg    %edx
  80060f:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800612:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800617:	eb 70                	jmp    800689 <vprintfmt+0x35b>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800619:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80061c:	8d 45 14             	lea    0x14(%ebp),%eax
  80061f:	e8 97 fc ff ff       	call   8002bb <getuint>
			base = 10;
  800624:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800629:	eb 5e                	jmp    800689 <vprintfmt+0x35b>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
  80062b:	83 ec 08             	sub    $0x8,%esp
  80062e:	53                   	push   %ebx
  80062f:	6a 30                	push   $0x30
  800631:	ff d7                	call   *%edi
			num = getuint(&ap, lflag);
  800633:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800636:	8d 45 14             	lea    0x14(%ebp),%eax
  800639:	e8 7d fc ff ff       	call   8002bb <getuint>
			base = 8;
			goto number;
  80063e:	83 c4 10             	add    $0x10,%esp
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  800641:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800646:	eb 41                	jmp    800689 <vprintfmt+0x35b>
		// pointer
		case 'p':
			putch('0', putdat);
  800648:	83 ec 08             	sub    $0x8,%esp
  80064b:	53                   	push   %ebx
  80064c:	6a 30                	push   $0x30
  80064e:	ff d7                	call   *%edi
			putch('x', putdat);
  800650:	83 c4 08             	add    $0x8,%esp
  800653:	53                   	push   %ebx
  800654:	6a 78                	push   $0x78
  800656:	ff d7                	call   *%edi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800658:	8b 45 14             	mov    0x14(%ebp),%eax
  80065b:	8d 50 04             	lea    0x4(%eax),%edx
  80065e:	89 55 14             	mov    %edx,0x14(%ebp)
			goto number;
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800661:	8b 00                	mov    (%eax),%eax
  800663:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800668:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80066b:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800670:	eb 17                	jmp    800689 <vprintfmt+0x35b>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800672:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800675:	8d 45 14             	lea    0x14(%ebp),%eax
  800678:	e8 3e fc ff ff       	call   8002bb <getuint>
			base = 16;
  80067d:	b9 10 00 00 00       	mov    $0x10,%ecx
  800682:	eb 05                	jmp    800689 <vprintfmt+0x35b>
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800684:	b9 0a 00 00 00       	mov    $0xa,%ecx
		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  800689:	83 ec 0c             	sub    $0xc,%esp
  80068c:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  800690:	56                   	push   %esi
  800691:	ff 75 e4             	pushl  -0x1c(%ebp)
  800694:	51                   	push   %ecx
  800695:	52                   	push   %edx
  800696:	50                   	push   %eax
  800697:	89 da                	mov    %ebx,%edx
  800699:	89 f8                	mov    %edi,%eax
  80069b:	e8 6b fb ff ff       	call   80020b <printnum>
			break;
  8006a0:	83 c4 20             	add    $0x20,%esp
  8006a3:	e9 9a fc ff ff       	jmp    800342 <vprintfmt+0x14>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006a8:	83 ec 08             	sub    $0x8,%esp
  8006ab:	53                   	push   %ebx
  8006ac:	52                   	push   %edx
  8006ad:	ff d7                	call   *%edi
			break;
  8006af:	83 c4 10             	add    $0x10,%esp
  8006b2:	e9 8b fc ff ff       	jmp    800342 <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006b7:	83 ec 08             	sub    $0x8,%esp
  8006ba:	53                   	push   %ebx
  8006bb:	6a 25                	push   $0x25
  8006bd:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006bf:	83 c4 10             	add    $0x10,%esp
  8006c2:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8006c6:	0f 84 73 fc ff ff    	je     80033f <vprintfmt+0x11>
  8006cc:	4e                   	dec    %esi
  8006cd:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8006d1:	75 f9                	jne    8006cc <vprintfmt+0x39e>
  8006d3:	89 75 10             	mov    %esi,0x10(%ebp)
  8006d6:	e9 67 fc ff ff       	jmp    800342 <vprintfmt+0x14>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006db:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8006de:	8d 70 01             	lea    0x1(%eax),%esi
  8006e1:	8a 00                	mov    (%eax),%al
  8006e3:	0f be d0             	movsbl %al,%edx
  8006e6:	85 d2                	test   %edx,%edx
  8006e8:	0f 85 7a fe ff ff    	jne    800568 <vprintfmt+0x23a>
  8006ee:	e9 4f fc ff ff       	jmp    800342 <vprintfmt+0x14>
  8006f3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8006f6:	8d 70 01             	lea    0x1(%eax),%esi
  8006f9:	8a 00                	mov    (%eax),%al
  8006fb:	0f be d0             	movsbl %al,%edx
  8006fe:	85 d2                	test   %edx,%edx
  800700:	0f 85 6a fe ff ff    	jne    800570 <vprintfmt+0x242>
  800706:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800709:	e9 77 fe ff ff       	jmp    800585 <vprintfmt+0x257>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  80070e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800711:	5b                   	pop    %ebx
  800712:	5e                   	pop    %esi
  800713:	5f                   	pop    %edi
  800714:	5d                   	pop    %ebp
  800715:	c3                   	ret    

00800716 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800716:	55                   	push   %ebp
  800717:	89 e5                	mov    %esp,%ebp
  800719:	83 ec 18             	sub    $0x18,%esp
  80071c:	8b 45 08             	mov    0x8(%ebp),%eax
  80071f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800722:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800725:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800729:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80072c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800733:	85 c0                	test   %eax,%eax
  800735:	74 26                	je     80075d <vsnprintf+0x47>
  800737:	85 d2                	test   %edx,%edx
  800739:	7e 29                	jle    800764 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80073b:	ff 75 14             	pushl  0x14(%ebp)
  80073e:	ff 75 10             	pushl  0x10(%ebp)
  800741:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800744:	50                   	push   %eax
  800745:	68 f5 02 80 00       	push   $0x8002f5
  80074a:	e8 df fb ff ff       	call   80032e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80074f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800752:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800755:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800758:	83 c4 10             	add    $0x10,%esp
  80075b:	eb 0c                	jmp    800769 <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80075d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800762:	eb 05                	jmp    800769 <vsnprintf+0x53>
  800764:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800769:	c9                   	leave  
  80076a:	c3                   	ret    

0080076b <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80076b:	55                   	push   %ebp
  80076c:	89 e5                	mov    %esp,%ebp
  80076e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800771:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800774:	50                   	push   %eax
  800775:	ff 75 10             	pushl  0x10(%ebp)
  800778:	ff 75 0c             	pushl  0xc(%ebp)
  80077b:	ff 75 08             	pushl  0x8(%ebp)
  80077e:	e8 93 ff ff ff       	call   800716 <vsnprintf>
	va_end(ap);

	return rc;
}
  800783:	c9                   	leave  
  800784:	c3                   	ret    

00800785 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800785:	55                   	push   %ebp
  800786:	89 e5                	mov    %esp,%ebp
  800788:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80078b:	80 3a 00             	cmpb   $0x0,(%edx)
  80078e:	74 0e                	je     80079e <strlen+0x19>
  800790:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800795:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800796:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80079a:	75 f9                	jne    800795 <strlen+0x10>
  80079c:	eb 05                	jmp    8007a3 <strlen+0x1e>
  80079e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8007a3:	5d                   	pop    %ebp
  8007a4:	c3                   	ret    

008007a5 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007a5:	55                   	push   %ebp
  8007a6:	89 e5                	mov    %esp,%ebp
  8007a8:	53                   	push   %ebx
  8007a9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8007ac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007af:	85 c9                	test   %ecx,%ecx
  8007b1:	74 1a                	je     8007cd <strnlen+0x28>
  8007b3:	80 3b 00             	cmpb   $0x0,(%ebx)
  8007b6:	74 1c                	je     8007d4 <strnlen+0x2f>
  8007b8:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  8007bd:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007bf:	39 ca                	cmp    %ecx,%edx
  8007c1:	74 16                	je     8007d9 <strnlen+0x34>
  8007c3:	42                   	inc    %edx
  8007c4:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  8007c9:	75 f2                	jne    8007bd <strnlen+0x18>
  8007cb:	eb 0c                	jmp    8007d9 <strnlen+0x34>
  8007cd:	b8 00 00 00 00       	mov    $0x0,%eax
  8007d2:	eb 05                	jmp    8007d9 <strnlen+0x34>
  8007d4:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8007d9:	5b                   	pop    %ebx
  8007da:	5d                   	pop    %ebp
  8007db:	c3                   	ret    

008007dc <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007dc:	55                   	push   %ebp
  8007dd:	89 e5                	mov    %esp,%ebp
  8007df:	53                   	push   %ebx
  8007e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007e6:	89 c2                	mov    %eax,%edx
  8007e8:	42                   	inc    %edx
  8007e9:	41                   	inc    %ecx
  8007ea:	8a 59 ff             	mov    -0x1(%ecx),%bl
  8007ed:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007f0:	84 db                	test   %bl,%bl
  8007f2:	75 f4                	jne    8007e8 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007f4:	5b                   	pop    %ebx
  8007f5:	5d                   	pop    %ebp
  8007f6:	c3                   	ret    

008007f7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007f7:	55                   	push   %ebp
  8007f8:	89 e5                	mov    %esp,%ebp
  8007fa:	53                   	push   %ebx
  8007fb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007fe:	53                   	push   %ebx
  8007ff:	e8 81 ff ff ff       	call   800785 <strlen>
  800804:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800807:	ff 75 0c             	pushl  0xc(%ebp)
  80080a:	01 d8                	add    %ebx,%eax
  80080c:	50                   	push   %eax
  80080d:	e8 ca ff ff ff       	call   8007dc <strcpy>
	return dst;
}
  800812:	89 d8                	mov    %ebx,%eax
  800814:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800817:	c9                   	leave  
  800818:	c3                   	ret    

00800819 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800819:	55                   	push   %ebp
  80081a:	89 e5                	mov    %esp,%ebp
  80081c:	56                   	push   %esi
  80081d:	53                   	push   %ebx
  80081e:	8b 75 08             	mov    0x8(%ebp),%esi
  800821:	8b 55 0c             	mov    0xc(%ebp),%edx
  800824:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800827:	85 db                	test   %ebx,%ebx
  800829:	74 14                	je     80083f <strncpy+0x26>
  80082b:	01 f3                	add    %esi,%ebx
  80082d:	89 f1                	mov    %esi,%ecx
		*dst++ = *src;
  80082f:	41                   	inc    %ecx
  800830:	8a 02                	mov    (%edx),%al
  800832:	88 41 ff             	mov    %al,-0x1(%ecx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800835:	80 3a 01             	cmpb   $0x1,(%edx)
  800838:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80083b:	39 cb                	cmp    %ecx,%ebx
  80083d:	75 f0                	jne    80082f <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80083f:	89 f0                	mov    %esi,%eax
  800841:	5b                   	pop    %ebx
  800842:	5e                   	pop    %esi
  800843:	5d                   	pop    %ebp
  800844:	c3                   	ret    

00800845 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800845:	55                   	push   %ebp
  800846:	89 e5                	mov    %esp,%ebp
  800848:	53                   	push   %ebx
  800849:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80084c:	8b 45 10             	mov    0x10(%ebp),%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80084f:	85 c0                	test   %eax,%eax
  800851:	74 30                	je     800883 <strlcpy+0x3e>
		while (--size > 0 && *src != '\0')
  800853:	48                   	dec    %eax
  800854:	74 20                	je     800876 <strlcpy+0x31>
  800856:	8a 0b                	mov    (%ebx),%cl
  800858:	84 c9                	test   %cl,%cl
  80085a:	74 1f                	je     80087b <strlcpy+0x36>
  80085c:	8d 53 01             	lea    0x1(%ebx),%edx
  80085f:	01 c3                	add    %eax,%ebx
  800861:	8b 45 08             	mov    0x8(%ebp),%eax
			*dst++ = *src++;
  800864:	40                   	inc    %eax
  800865:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800868:	39 da                	cmp    %ebx,%edx
  80086a:	74 12                	je     80087e <strlcpy+0x39>
  80086c:	42                   	inc    %edx
  80086d:	8a 4a ff             	mov    -0x1(%edx),%cl
  800870:	84 c9                	test   %cl,%cl
  800872:	75 f0                	jne    800864 <strlcpy+0x1f>
  800874:	eb 08                	jmp    80087e <strlcpy+0x39>
  800876:	8b 45 08             	mov    0x8(%ebp),%eax
  800879:	eb 03                	jmp    80087e <strlcpy+0x39>
  80087b:	8b 45 08             	mov    0x8(%ebp),%eax
			*dst++ = *src++;
		*dst = '\0';
  80087e:	c6 00 00             	movb   $0x0,(%eax)
  800881:	eb 03                	jmp    800886 <strlcpy+0x41>
  800883:	8b 45 08             	mov    0x8(%ebp),%eax
	}
	return dst - dst_in;
  800886:	2b 45 08             	sub    0x8(%ebp),%eax
}
  800889:	5b                   	pop    %ebx
  80088a:	5d                   	pop    %ebp
  80088b:	c3                   	ret    

0080088c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80088c:	55                   	push   %ebp
  80088d:	89 e5                	mov    %esp,%ebp
  80088f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800892:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800895:	8a 01                	mov    (%ecx),%al
  800897:	84 c0                	test   %al,%al
  800899:	74 10                	je     8008ab <strcmp+0x1f>
  80089b:	3a 02                	cmp    (%edx),%al
  80089d:	75 0c                	jne    8008ab <strcmp+0x1f>
		p++, q++;
  80089f:	41                   	inc    %ecx
  8008a0:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008a1:	8a 01                	mov    (%ecx),%al
  8008a3:	84 c0                	test   %al,%al
  8008a5:	74 04                	je     8008ab <strcmp+0x1f>
  8008a7:	3a 02                	cmp    (%edx),%al
  8008a9:	74 f4                	je     80089f <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008ab:	0f b6 c0             	movzbl %al,%eax
  8008ae:	0f b6 12             	movzbl (%edx),%edx
  8008b1:	29 d0                	sub    %edx,%eax
}
  8008b3:	5d                   	pop    %ebp
  8008b4:	c3                   	ret    

008008b5 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008b5:	55                   	push   %ebp
  8008b6:	89 e5                	mov    %esp,%ebp
  8008b8:	56                   	push   %esi
  8008b9:	53                   	push   %ebx
  8008ba:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8008bd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008c0:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  8008c3:	85 f6                	test   %esi,%esi
  8008c5:	74 23                	je     8008ea <strncmp+0x35>
  8008c7:	8a 03                	mov    (%ebx),%al
  8008c9:	84 c0                	test   %al,%al
  8008cb:	74 2b                	je     8008f8 <strncmp+0x43>
  8008cd:	3a 02                	cmp    (%edx),%al
  8008cf:	75 27                	jne    8008f8 <strncmp+0x43>
  8008d1:	8d 43 01             	lea    0x1(%ebx),%eax
  8008d4:	01 de                	add    %ebx,%esi
		n--, p++, q++;
  8008d6:	89 c3                	mov    %eax,%ebx
  8008d8:	42                   	inc    %edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008d9:	39 c6                	cmp    %eax,%esi
  8008db:	74 14                	je     8008f1 <strncmp+0x3c>
  8008dd:	8a 08                	mov    (%eax),%cl
  8008df:	84 c9                	test   %cl,%cl
  8008e1:	74 15                	je     8008f8 <strncmp+0x43>
  8008e3:	40                   	inc    %eax
  8008e4:	3a 0a                	cmp    (%edx),%cl
  8008e6:	74 ee                	je     8008d6 <strncmp+0x21>
  8008e8:	eb 0e                	jmp    8008f8 <strncmp+0x43>
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008ea:	b8 00 00 00 00       	mov    $0x0,%eax
  8008ef:	eb 0f                	jmp    800900 <strncmp+0x4b>
  8008f1:	b8 00 00 00 00       	mov    $0x0,%eax
  8008f6:	eb 08                	jmp    800900 <strncmp+0x4b>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008f8:	0f b6 03             	movzbl (%ebx),%eax
  8008fb:	0f b6 12             	movzbl (%edx),%edx
  8008fe:	29 d0                	sub    %edx,%eax
}
  800900:	5b                   	pop    %ebx
  800901:	5e                   	pop    %esi
  800902:	5d                   	pop    %ebp
  800903:	c3                   	ret    

00800904 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800904:	55                   	push   %ebp
  800905:	89 e5                	mov    %esp,%ebp
  800907:	53                   	push   %ebx
  800908:	8b 45 08             	mov    0x8(%ebp),%eax
  80090b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  80090e:	8a 10                	mov    (%eax),%dl
  800910:	84 d2                	test   %dl,%dl
  800912:	74 1a                	je     80092e <strchr+0x2a>
  800914:	88 d9                	mov    %bl,%cl
		if (*s == c)
  800916:	38 d3                	cmp    %dl,%bl
  800918:	75 06                	jne    800920 <strchr+0x1c>
  80091a:	eb 17                	jmp    800933 <strchr+0x2f>
  80091c:	38 ca                	cmp    %cl,%dl
  80091e:	74 13                	je     800933 <strchr+0x2f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800920:	40                   	inc    %eax
  800921:	8a 10                	mov    (%eax),%dl
  800923:	84 d2                	test   %dl,%dl
  800925:	75 f5                	jne    80091c <strchr+0x18>
		if (*s == c)
			return (char *) s;
	return 0;
  800927:	b8 00 00 00 00       	mov    $0x0,%eax
  80092c:	eb 05                	jmp    800933 <strchr+0x2f>
  80092e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800933:	5b                   	pop    %ebx
  800934:	5d                   	pop    %ebp
  800935:	c3                   	ret    

00800936 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800936:	55                   	push   %ebp
  800937:	89 e5                	mov    %esp,%ebp
  800939:	53                   	push   %ebx
  80093a:	8b 45 08             	mov    0x8(%ebp),%eax
  80093d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  800940:	8a 10                	mov    (%eax),%dl
  800942:	84 d2                	test   %dl,%dl
  800944:	74 13                	je     800959 <strfind+0x23>
  800946:	88 d9                	mov    %bl,%cl
		if (*s == c)
  800948:	38 d3                	cmp    %dl,%bl
  80094a:	75 06                	jne    800952 <strfind+0x1c>
  80094c:	eb 0b                	jmp    800959 <strfind+0x23>
  80094e:	38 ca                	cmp    %cl,%dl
  800950:	74 07                	je     800959 <strfind+0x23>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800952:	40                   	inc    %eax
  800953:	8a 10                	mov    (%eax),%dl
  800955:	84 d2                	test   %dl,%dl
  800957:	75 f5                	jne    80094e <strfind+0x18>
		if (*s == c)
			break;
	return (char *) s;
}
  800959:	5b                   	pop    %ebx
  80095a:	5d                   	pop    %ebp
  80095b:	c3                   	ret    

0080095c <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80095c:	55                   	push   %ebp
  80095d:	89 e5                	mov    %esp,%ebp
  80095f:	57                   	push   %edi
  800960:	56                   	push   %esi
  800961:	53                   	push   %ebx
  800962:	8b 7d 08             	mov    0x8(%ebp),%edi
  800965:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800968:	85 c9                	test   %ecx,%ecx
  80096a:	74 36                	je     8009a2 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80096c:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800972:	75 28                	jne    80099c <memset+0x40>
  800974:	f6 c1 03             	test   $0x3,%cl
  800977:	75 23                	jne    80099c <memset+0x40>
		c &= 0xFF;
  800979:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80097d:	89 d3                	mov    %edx,%ebx
  80097f:	c1 e3 08             	shl    $0x8,%ebx
  800982:	89 d6                	mov    %edx,%esi
  800984:	c1 e6 18             	shl    $0x18,%esi
  800987:	89 d0                	mov    %edx,%eax
  800989:	c1 e0 10             	shl    $0x10,%eax
  80098c:	09 f0                	or     %esi,%eax
  80098e:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800990:	89 d8                	mov    %ebx,%eax
  800992:	09 d0                	or     %edx,%eax
  800994:	c1 e9 02             	shr    $0x2,%ecx
  800997:	fc                   	cld    
  800998:	f3 ab                	rep stos %eax,%es:(%edi)
  80099a:	eb 06                	jmp    8009a2 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80099c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80099f:	fc                   	cld    
  8009a0:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009a2:	89 f8                	mov    %edi,%eax
  8009a4:	5b                   	pop    %ebx
  8009a5:	5e                   	pop    %esi
  8009a6:	5f                   	pop    %edi
  8009a7:	5d                   	pop    %ebp
  8009a8:	c3                   	ret    

008009a9 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009a9:	55                   	push   %ebp
  8009aa:	89 e5                	mov    %esp,%ebp
  8009ac:	57                   	push   %edi
  8009ad:	56                   	push   %esi
  8009ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b1:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009b4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009b7:	39 c6                	cmp    %eax,%esi
  8009b9:	73 33                	jae    8009ee <memmove+0x45>
  8009bb:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009be:	39 d0                	cmp    %edx,%eax
  8009c0:	73 2c                	jae    8009ee <memmove+0x45>
		s += n;
		d += n;
  8009c2:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009c5:	89 d6                	mov    %edx,%esi
  8009c7:	09 fe                	or     %edi,%esi
  8009c9:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009cf:	75 13                	jne    8009e4 <memmove+0x3b>
  8009d1:	f6 c1 03             	test   $0x3,%cl
  8009d4:	75 0e                	jne    8009e4 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8009d6:	83 ef 04             	sub    $0x4,%edi
  8009d9:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009dc:	c1 e9 02             	shr    $0x2,%ecx
  8009df:	fd                   	std    
  8009e0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009e2:	eb 07                	jmp    8009eb <memmove+0x42>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009e4:	4f                   	dec    %edi
  8009e5:	8d 72 ff             	lea    -0x1(%edx),%esi
  8009e8:	fd                   	std    
  8009e9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009eb:	fc                   	cld    
  8009ec:	eb 1d                	jmp    800a0b <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009ee:	89 f2                	mov    %esi,%edx
  8009f0:	09 c2                	or     %eax,%edx
  8009f2:	f6 c2 03             	test   $0x3,%dl
  8009f5:	75 0f                	jne    800a06 <memmove+0x5d>
  8009f7:	f6 c1 03             	test   $0x3,%cl
  8009fa:	75 0a                	jne    800a06 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
  8009fc:	c1 e9 02             	shr    $0x2,%ecx
  8009ff:	89 c7                	mov    %eax,%edi
  800a01:	fc                   	cld    
  800a02:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a04:	eb 05                	jmp    800a0b <memmove+0x62>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a06:	89 c7                	mov    %eax,%edi
  800a08:	fc                   	cld    
  800a09:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a0b:	5e                   	pop    %esi
  800a0c:	5f                   	pop    %edi
  800a0d:	5d                   	pop    %ebp
  800a0e:	c3                   	ret    

00800a0f <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a0f:	55                   	push   %ebp
  800a10:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a12:	ff 75 10             	pushl  0x10(%ebp)
  800a15:	ff 75 0c             	pushl  0xc(%ebp)
  800a18:	ff 75 08             	pushl  0x8(%ebp)
  800a1b:	e8 89 ff ff ff       	call   8009a9 <memmove>
}
  800a20:	c9                   	leave  
  800a21:	c3                   	ret    

00800a22 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a22:	55                   	push   %ebp
  800a23:	89 e5                	mov    %esp,%ebp
  800a25:	57                   	push   %edi
  800a26:	56                   	push   %esi
  800a27:	53                   	push   %ebx
  800a28:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800a2b:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a2e:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a31:	85 c0                	test   %eax,%eax
  800a33:	74 33                	je     800a68 <memcmp+0x46>
  800a35:	8d 78 ff             	lea    -0x1(%eax),%edi
		if (*s1 != *s2)
  800a38:	8a 13                	mov    (%ebx),%dl
  800a3a:	8a 0e                	mov    (%esi),%cl
  800a3c:	38 ca                	cmp    %cl,%dl
  800a3e:	75 13                	jne    800a53 <memcmp+0x31>
  800a40:	b8 00 00 00 00       	mov    $0x0,%eax
  800a45:	eb 16                	jmp    800a5d <memcmp+0x3b>
  800a47:	8a 54 03 01          	mov    0x1(%ebx,%eax,1),%dl
  800a4b:	40                   	inc    %eax
  800a4c:	8a 0c 06             	mov    (%esi,%eax,1),%cl
  800a4f:	38 ca                	cmp    %cl,%dl
  800a51:	74 0a                	je     800a5d <memcmp+0x3b>
			return (int) *s1 - (int) *s2;
  800a53:	0f b6 c2             	movzbl %dl,%eax
  800a56:	0f b6 c9             	movzbl %cl,%ecx
  800a59:	29 c8                	sub    %ecx,%eax
  800a5b:	eb 10                	jmp    800a6d <memcmp+0x4b>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a5d:	39 f8                	cmp    %edi,%eax
  800a5f:	75 e6                	jne    800a47 <memcmp+0x25>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a61:	b8 00 00 00 00       	mov    $0x0,%eax
  800a66:	eb 05                	jmp    800a6d <memcmp+0x4b>
  800a68:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a6d:	5b                   	pop    %ebx
  800a6e:	5e                   	pop    %esi
  800a6f:	5f                   	pop    %edi
  800a70:	5d                   	pop    %ebp
  800a71:	c3                   	ret    

00800a72 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a72:	55                   	push   %ebp
  800a73:	89 e5                	mov    %esp,%ebp
  800a75:	53                   	push   %ebx
  800a76:	8b 55 08             	mov    0x8(%ebp),%edx
	const void *ends = (const char *) s + n;
  800a79:	89 d0                	mov    %edx,%eax
  800a7b:	03 45 10             	add    0x10(%ebp),%eax
	for (; s < ends; s++)
  800a7e:	39 c2                	cmp    %eax,%edx
  800a80:	73 1b                	jae    800a9d <memfind+0x2b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a82:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
  800a86:	0f b6 0a             	movzbl (%edx),%ecx
  800a89:	39 d9                	cmp    %ebx,%ecx
  800a8b:	75 09                	jne    800a96 <memfind+0x24>
  800a8d:	eb 12                	jmp    800aa1 <memfind+0x2f>
  800a8f:	0f b6 0a             	movzbl (%edx),%ecx
  800a92:	39 d9                	cmp    %ebx,%ecx
  800a94:	74 0f                	je     800aa5 <memfind+0x33>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a96:	42                   	inc    %edx
  800a97:	39 d0                	cmp    %edx,%eax
  800a99:	75 f4                	jne    800a8f <memfind+0x1d>
  800a9b:	eb 0a                	jmp    800aa7 <memfind+0x35>
  800a9d:	89 d0                	mov    %edx,%eax
  800a9f:	eb 06                	jmp    800aa7 <memfind+0x35>
		if (*(const unsigned char *) s == (unsigned char) c)
  800aa1:	89 d0                	mov    %edx,%eax
  800aa3:	eb 02                	jmp    800aa7 <memfind+0x35>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800aa5:	89 d0                	mov    %edx,%eax
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800aa7:	5b                   	pop    %ebx
  800aa8:	5d                   	pop    %ebp
  800aa9:	c3                   	ret    

00800aaa <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800aaa:	55                   	push   %ebp
  800aab:	89 e5                	mov    %esp,%ebp
  800aad:	57                   	push   %edi
  800aae:	56                   	push   %esi
  800aaf:	53                   	push   %ebx
  800ab0:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ab3:	eb 01                	jmp    800ab6 <strtol+0xc>
		s++;
  800ab5:	41                   	inc    %ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ab6:	8a 01                	mov    (%ecx),%al
  800ab8:	3c 20                	cmp    $0x20,%al
  800aba:	74 f9                	je     800ab5 <strtol+0xb>
  800abc:	3c 09                	cmp    $0x9,%al
  800abe:	74 f5                	je     800ab5 <strtol+0xb>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ac0:	3c 2b                	cmp    $0x2b,%al
  800ac2:	75 08                	jne    800acc <strtol+0x22>
		s++;
  800ac4:	41                   	inc    %ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ac5:	bf 00 00 00 00       	mov    $0x0,%edi
  800aca:	eb 11                	jmp    800add <strtol+0x33>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800acc:	3c 2d                	cmp    $0x2d,%al
  800ace:	75 08                	jne    800ad8 <strtol+0x2e>
		s++, neg = 1;
  800ad0:	41                   	inc    %ecx
  800ad1:	bf 01 00 00 00       	mov    $0x1,%edi
  800ad6:	eb 05                	jmp    800add <strtol+0x33>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ad8:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800add:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800ae1:	0f 84 87 00 00 00    	je     800b6e <strtol+0xc4>
  800ae7:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  800aeb:	75 27                	jne    800b14 <strtol+0x6a>
  800aed:	80 39 30             	cmpb   $0x30,(%ecx)
  800af0:	75 22                	jne    800b14 <strtol+0x6a>
  800af2:	e9 88 00 00 00       	jmp    800b7f <strtol+0xd5>
		s += 2, base = 16;
  800af7:	83 c1 02             	add    $0x2,%ecx
  800afa:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  800b01:	eb 11                	jmp    800b14 <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
  800b03:	41                   	inc    %ecx
  800b04:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  800b0b:	eb 07                	jmp    800b14 <strtol+0x6a>
	else if (base == 0)
		base = 10;
  800b0d:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)
  800b14:	b8 00 00 00 00       	mov    $0x0,%eax

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b19:	8a 11                	mov    (%ecx),%dl
  800b1b:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800b1e:	80 fb 09             	cmp    $0x9,%bl
  800b21:	77 08                	ja     800b2b <strtol+0x81>
			dig = *s - '0';
  800b23:	0f be d2             	movsbl %dl,%edx
  800b26:	83 ea 30             	sub    $0x30,%edx
  800b29:	eb 22                	jmp    800b4d <strtol+0xa3>
		else if (*s >= 'a' && *s <= 'z')
  800b2b:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b2e:	89 f3                	mov    %esi,%ebx
  800b30:	80 fb 19             	cmp    $0x19,%bl
  800b33:	77 08                	ja     800b3d <strtol+0x93>
			dig = *s - 'a' + 10;
  800b35:	0f be d2             	movsbl %dl,%edx
  800b38:	83 ea 57             	sub    $0x57,%edx
  800b3b:	eb 10                	jmp    800b4d <strtol+0xa3>
		else if (*s >= 'A' && *s <= 'Z')
  800b3d:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b40:	89 f3                	mov    %esi,%ebx
  800b42:	80 fb 19             	cmp    $0x19,%bl
  800b45:	77 14                	ja     800b5b <strtol+0xb1>
			dig = *s - 'A' + 10;
  800b47:	0f be d2             	movsbl %dl,%edx
  800b4a:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b4d:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b50:	7d 09                	jge    800b5b <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800b52:	41                   	inc    %ecx
  800b53:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b57:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b59:	eb be                	jmp    800b19 <strtol+0x6f>

	if (endptr)
  800b5b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b5f:	74 05                	je     800b66 <strtol+0xbc>
		*endptr = (char *) s;
  800b61:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b64:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800b66:	85 ff                	test   %edi,%edi
  800b68:	74 21                	je     800b8b <strtol+0xe1>
  800b6a:	f7 d8                	neg    %eax
  800b6c:	eb 1d                	jmp    800b8b <strtol+0xe1>
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b6e:	80 39 30             	cmpb   $0x30,(%ecx)
  800b71:	75 9a                	jne    800b0d <strtol+0x63>
  800b73:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b77:	0f 84 7a ff ff ff    	je     800af7 <strtol+0x4d>
  800b7d:	eb 84                	jmp    800b03 <strtol+0x59>
  800b7f:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b83:	0f 84 6e ff ff ff    	je     800af7 <strtol+0x4d>
  800b89:	eb 89                	jmp    800b14 <strtol+0x6a>
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
}
  800b8b:	5b                   	pop    %ebx
  800b8c:	5e                   	pop    %esi
  800b8d:	5f                   	pop    %edi
  800b8e:	5d                   	pop    %ebp
  800b8f:	c3                   	ret    

00800b90 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b90:	55                   	push   %ebp
  800b91:	89 e5                	mov    %esp,%ebp
  800b93:	57                   	push   %edi
  800b94:	56                   	push   %esi
  800b95:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b96:	b8 00 00 00 00       	mov    $0x0,%eax
  800b9b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b9e:	8b 55 08             	mov    0x8(%ebp),%edx
  800ba1:	89 c3                	mov    %eax,%ebx
  800ba3:	89 c7                	mov    %eax,%edi
  800ba5:	89 c6                	mov    %eax,%esi
  800ba7:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ba9:	5b                   	pop    %ebx
  800baa:	5e                   	pop    %esi
  800bab:	5f                   	pop    %edi
  800bac:	5d                   	pop    %ebp
  800bad:	c3                   	ret    

00800bae <sys_cgetc>:

int
sys_cgetc(void)
{
  800bae:	55                   	push   %ebp
  800baf:	89 e5                	mov    %esp,%ebp
  800bb1:	57                   	push   %edi
  800bb2:	56                   	push   %esi
  800bb3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bb4:	ba 00 00 00 00       	mov    $0x0,%edx
  800bb9:	b8 01 00 00 00       	mov    $0x1,%eax
  800bbe:	89 d1                	mov    %edx,%ecx
  800bc0:	89 d3                	mov    %edx,%ebx
  800bc2:	89 d7                	mov    %edx,%edi
  800bc4:	89 d6                	mov    %edx,%esi
  800bc6:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bc8:	5b                   	pop    %ebx
  800bc9:	5e                   	pop    %esi
  800bca:	5f                   	pop    %edi
  800bcb:	5d                   	pop    %ebp
  800bcc:	c3                   	ret    

00800bcd <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bcd:	55                   	push   %ebp
  800bce:	89 e5                	mov    %esp,%ebp
  800bd0:	57                   	push   %edi
  800bd1:	56                   	push   %esi
  800bd2:	53                   	push   %ebx
  800bd3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bd6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bdb:	b8 03 00 00 00       	mov    $0x3,%eax
  800be0:	8b 55 08             	mov    0x8(%ebp),%edx
  800be3:	89 cb                	mov    %ecx,%ebx
  800be5:	89 cf                	mov    %ecx,%edi
  800be7:	89 ce                	mov    %ecx,%esi
  800be9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800beb:	85 c0                	test   %eax,%eax
  800bed:	7e 17                	jle    800c06 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bef:	83 ec 0c             	sub    $0xc,%esp
  800bf2:	50                   	push   %eax
  800bf3:	6a 03                	push   $0x3
  800bf5:	68 df 25 80 00       	push   $0x8025df
  800bfa:	6a 23                	push   $0x23
  800bfc:	68 fc 25 80 00       	push   $0x8025fc
  800c01:	e8 d9 12 00 00       	call   801edf <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c06:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c09:	5b                   	pop    %ebx
  800c0a:	5e                   	pop    %esi
  800c0b:	5f                   	pop    %edi
  800c0c:	5d                   	pop    %ebp
  800c0d:	c3                   	ret    

00800c0e <sys_getenvid>:

envid_t
sys_getenvid(void)
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
  800c14:	ba 00 00 00 00       	mov    $0x0,%edx
  800c19:	b8 02 00 00 00       	mov    $0x2,%eax
  800c1e:	89 d1                	mov    %edx,%ecx
  800c20:	89 d3                	mov    %edx,%ebx
  800c22:	89 d7                	mov    %edx,%edi
  800c24:	89 d6                	mov    %edx,%esi
  800c26:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c28:	5b                   	pop    %ebx
  800c29:	5e                   	pop    %esi
  800c2a:	5f                   	pop    %edi
  800c2b:	5d                   	pop    %ebp
  800c2c:	c3                   	ret    

00800c2d <sys_yield>:

void
sys_yield(void)
{
  800c2d:	55                   	push   %ebp
  800c2e:	89 e5                	mov    %esp,%ebp
  800c30:	57                   	push   %edi
  800c31:	56                   	push   %esi
  800c32:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c33:	ba 00 00 00 00       	mov    $0x0,%edx
  800c38:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c3d:	89 d1                	mov    %edx,%ecx
  800c3f:	89 d3                	mov    %edx,%ebx
  800c41:	89 d7                	mov    %edx,%edi
  800c43:	89 d6                	mov    %edx,%esi
  800c45:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c47:	5b                   	pop    %ebx
  800c48:	5e                   	pop    %esi
  800c49:	5f                   	pop    %edi
  800c4a:	5d                   	pop    %ebp
  800c4b:	c3                   	ret    

00800c4c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c4c:	55                   	push   %ebp
  800c4d:	89 e5                	mov    %esp,%ebp
  800c4f:	57                   	push   %edi
  800c50:	56                   	push   %esi
  800c51:	53                   	push   %ebx
  800c52:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c55:	be 00 00 00 00       	mov    $0x0,%esi
  800c5a:	b8 04 00 00 00       	mov    $0x4,%eax
  800c5f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c62:	8b 55 08             	mov    0x8(%ebp),%edx
  800c65:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c68:	89 f7                	mov    %esi,%edi
  800c6a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c6c:	85 c0                	test   %eax,%eax
  800c6e:	7e 17                	jle    800c87 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c70:	83 ec 0c             	sub    $0xc,%esp
  800c73:	50                   	push   %eax
  800c74:	6a 04                	push   $0x4
  800c76:	68 df 25 80 00       	push   $0x8025df
  800c7b:	6a 23                	push   $0x23
  800c7d:	68 fc 25 80 00       	push   $0x8025fc
  800c82:	e8 58 12 00 00       	call   801edf <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c87:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c8a:	5b                   	pop    %ebx
  800c8b:	5e                   	pop    %esi
  800c8c:	5f                   	pop    %edi
  800c8d:	5d                   	pop    %ebp
  800c8e:	c3                   	ret    

00800c8f <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c8f:	55                   	push   %ebp
  800c90:	89 e5                	mov    %esp,%ebp
  800c92:	57                   	push   %edi
  800c93:	56                   	push   %esi
  800c94:	53                   	push   %ebx
  800c95:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c98:	b8 05 00 00 00       	mov    $0x5,%eax
  800c9d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ca6:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ca9:	8b 75 18             	mov    0x18(%ebp),%esi
  800cac:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cae:	85 c0                	test   %eax,%eax
  800cb0:	7e 17                	jle    800cc9 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb2:	83 ec 0c             	sub    $0xc,%esp
  800cb5:	50                   	push   %eax
  800cb6:	6a 05                	push   $0x5
  800cb8:	68 df 25 80 00       	push   $0x8025df
  800cbd:	6a 23                	push   $0x23
  800cbf:	68 fc 25 80 00       	push   $0x8025fc
  800cc4:	e8 16 12 00 00       	call   801edf <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800cc9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ccc:	5b                   	pop    %ebx
  800ccd:	5e                   	pop    %esi
  800cce:	5f                   	pop    %edi
  800ccf:	5d                   	pop    %ebp
  800cd0:	c3                   	ret    

00800cd1 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cd1:	55                   	push   %ebp
  800cd2:	89 e5                	mov    %esp,%ebp
  800cd4:	57                   	push   %edi
  800cd5:	56                   	push   %esi
  800cd6:	53                   	push   %ebx
  800cd7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cda:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cdf:	b8 06 00 00 00       	mov    $0x6,%eax
  800ce4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce7:	8b 55 08             	mov    0x8(%ebp),%edx
  800cea:	89 df                	mov    %ebx,%edi
  800cec:	89 de                	mov    %ebx,%esi
  800cee:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cf0:	85 c0                	test   %eax,%eax
  800cf2:	7e 17                	jle    800d0b <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cf4:	83 ec 0c             	sub    $0xc,%esp
  800cf7:	50                   	push   %eax
  800cf8:	6a 06                	push   $0x6
  800cfa:	68 df 25 80 00       	push   $0x8025df
  800cff:	6a 23                	push   $0x23
  800d01:	68 fc 25 80 00       	push   $0x8025fc
  800d06:	e8 d4 11 00 00       	call   801edf <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d0b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d0e:	5b                   	pop    %ebx
  800d0f:	5e                   	pop    %esi
  800d10:	5f                   	pop    %edi
  800d11:	5d                   	pop    %ebp
  800d12:	c3                   	ret    

00800d13 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d13:	55                   	push   %ebp
  800d14:	89 e5                	mov    %esp,%ebp
  800d16:	57                   	push   %edi
  800d17:	56                   	push   %esi
  800d18:	53                   	push   %ebx
  800d19:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d1c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d21:	b8 08 00 00 00       	mov    $0x8,%eax
  800d26:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d29:	8b 55 08             	mov    0x8(%ebp),%edx
  800d2c:	89 df                	mov    %ebx,%edi
  800d2e:	89 de                	mov    %ebx,%esi
  800d30:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d32:	85 c0                	test   %eax,%eax
  800d34:	7e 17                	jle    800d4d <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d36:	83 ec 0c             	sub    $0xc,%esp
  800d39:	50                   	push   %eax
  800d3a:	6a 08                	push   $0x8
  800d3c:	68 df 25 80 00       	push   $0x8025df
  800d41:	6a 23                	push   $0x23
  800d43:	68 fc 25 80 00       	push   $0x8025fc
  800d48:	e8 92 11 00 00       	call   801edf <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d4d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d50:	5b                   	pop    %ebx
  800d51:	5e                   	pop    %esi
  800d52:	5f                   	pop    %edi
  800d53:	5d                   	pop    %ebp
  800d54:	c3                   	ret    

00800d55 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d55:	55                   	push   %ebp
  800d56:	89 e5                	mov    %esp,%ebp
  800d58:	57                   	push   %edi
  800d59:	56                   	push   %esi
  800d5a:	53                   	push   %ebx
  800d5b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d5e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d63:	b8 09 00 00 00       	mov    $0x9,%eax
  800d68:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d6b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d6e:	89 df                	mov    %ebx,%edi
  800d70:	89 de                	mov    %ebx,%esi
  800d72:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d74:	85 c0                	test   %eax,%eax
  800d76:	7e 17                	jle    800d8f <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d78:	83 ec 0c             	sub    $0xc,%esp
  800d7b:	50                   	push   %eax
  800d7c:	6a 09                	push   $0x9
  800d7e:	68 df 25 80 00       	push   $0x8025df
  800d83:	6a 23                	push   $0x23
  800d85:	68 fc 25 80 00       	push   $0x8025fc
  800d8a:	e8 50 11 00 00       	call   801edf <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d8f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d92:	5b                   	pop    %ebx
  800d93:	5e                   	pop    %esi
  800d94:	5f                   	pop    %edi
  800d95:	5d                   	pop    %ebp
  800d96:	c3                   	ret    

00800d97 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d97:	55                   	push   %ebp
  800d98:	89 e5                	mov    %esp,%ebp
  800d9a:	57                   	push   %edi
  800d9b:	56                   	push   %esi
  800d9c:	53                   	push   %ebx
  800d9d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800da0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800da5:	b8 0a 00 00 00       	mov    $0xa,%eax
  800daa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dad:	8b 55 08             	mov    0x8(%ebp),%edx
  800db0:	89 df                	mov    %ebx,%edi
  800db2:	89 de                	mov    %ebx,%esi
  800db4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800db6:	85 c0                	test   %eax,%eax
  800db8:	7e 17                	jle    800dd1 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dba:	83 ec 0c             	sub    $0xc,%esp
  800dbd:	50                   	push   %eax
  800dbe:	6a 0a                	push   $0xa
  800dc0:	68 df 25 80 00       	push   $0x8025df
  800dc5:	6a 23                	push   $0x23
  800dc7:	68 fc 25 80 00       	push   $0x8025fc
  800dcc:	e8 0e 11 00 00       	call   801edf <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800dd1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dd4:	5b                   	pop    %ebx
  800dd5:	5e                   	pop    %esi
  800dd6:	5f                   	pop    %edi
  800dd7:	5d                   	pop    %ebp
  800dd8:	c3                   	ret    

00800dd9 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800dd9:	55                   	push   %ebp
  800dda:	89 e5                	mov    %esp,%ebp
  800ddc:	57                   	push   %edi
  800ddd:	56                   	push   %esi
  800dde:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ddf:	be 00 00 00 00       	mov    $0x0,%esi
  800de4:	b8 0c 00 00 00       	mov    $0xc,%eax
  800de9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dec:	8b 55 08             	mov    0x8(%ebp),%edx
  800def:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800df2:	8b 7d 14             	mov    0x14(%ebp),%edi
  800df5:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800df7:	5b                   	pop    %ebx
  800df8:	5e                   	pop    %esi
  800df9:	5f                   	pop    %edi
  800dfa:	5d                   	pop    %ebp
  800dfb:	c3                   	ret    

00800dfc <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800dfc:	55                   	push   %ebp
  800dfd:	89 e5                	mov    %esp,%ebp
  800dff:	57                   	push   %edi
  800e00:	56                   	push   %esi
  800e01:	53                   	push   %ebx
  800e02:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e05:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e0a:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e0f:	8b 55 08             	mov    0x8(%ebp),%edx
  800e12:	89 cb                	mov    %ecx,%ebx
  800e14:	89 cf                	mov    %ecx,%edi
  800e16:	89 ce                	mov    %ecx,%esi
  800e18:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e1a:	85 c0                	test   %eax,%eax
  800e1c:	7e 17                	jle    800e35 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e1e:	83 ec 0c             	sub    $0xc,%esp
  800e21:	50                   	push   %eax
  800e22:	6a 0d                	push   $0xd
  800e24:	68 df 25 80 00       	push   $0x8025df
  800e29:	6a 23                	push   $0x23
  800e2b:	68 fc 25 80 00       	push   $0x8025fc
  800e30:	e8 aa 10 00 00       	call   801edf <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e35:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e38:	5b                   	pop    %ebx
  800e39:	5e                   	pop    %esi
  800e3a:	5f                   	pop    %edi
  800e3b:	5d                   	pop    %ebp
  800e3c:	c3                   	ret    

00800e3d <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e3d:	55                   	push   %ebp
  800e3e:	89 e5                	mov    %esp,%ebp
  800e40:	56                   	push   %esi
  800e41:	53                   	push   %ebx
  800e42:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e45:	8b 18                	mov    (%eax),%ebx
	// copy-on-write page.  If not, panic.
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).
	
	if((err & FEC_WR) == 0){
  800e47:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e4b:	75 14                	jne    800e61 <pgfault+0x24>
		panic("pgfault not cause by write \n");
  800e4d:	83 ec 04             	sub    $0x4,%esp
  800e50:	68 0a 26 80 00       	push   $0x80260a
  800e55:	6a 1c                	push   $0x1c
  800e57:	68 27 26 80 00       	push   $0x802627
  800e5c:	e8 7e 10 00 00       	call   801edf <_panic>
	}
 
	if ((uvpt[PGNUM(addr)] & PTE_COW) == 0) 
  800e61:	89 d8                	mov    %ebx,%eax
  800e63:	c1 e8 0c             	shr    $0xc,%eax
  800e66:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e6d:	f6 c4 08             	test   $0x8,%ah
  800e70:	75 14                	jne    800e86 <pgfault+0x49>
    {
        panic("pgfault not cause by COW \n");
  800e72:	83 ec 04             	sub    $0x4,%esp
  800e75:	68 32 26 80 00       	push   $0x802632
  800e7a:	6a 21                	push   $0x21
  800e7c:	68 27 26 80 00       	push   $0x802627
  800e81:	e8 59 10 00 00       	call   801edf <_panic>
	// copy the data from the old page to the new page, then move the new
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.
	envid_t eid = sys_getenvid();
  800e86:	e8 83 fd ff ff       	call   800c0e <sys_getenvid>
  800e8b:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(eid,(void*)PFTEMP,PTE_P|PTE_W|PTE_U)) < 0)
  800e8d:	83 ec 04             	sub    $0x4,%esp
  800e90:	6a 07                	push   $0x7
  800e92:	68 00 f0 7f 00       	push   $0x7ff000
  800e97:	50                   	push   %eax
  800e98:	e8 af fd ff ff       	call   800c4c <sys_page_alloc>
  800e9d:	83 c4 10             	add    $0x10,%esp
  800ea0:	85 c0                	test   %eax,%eax
  800ea2:	79 14                	jns    800eb8 <pgfault+0x7b>
		panic("page alloction failed.\n");
  800ea4:	83 ec 04             	sub    $0x4,%esp
  800ea7:	68 4d 26 80 00       	push   $0x80264d
  800eac:	6a 2d                	push   $0x2d
  800eae:	68 27 26 80 00       	push   $0x802627
  800eb3:	e8 27 10 00 00       	call   801edf <_panic>
	addr = ROUNDDOWN(addr,PGSIZE);
  800eb8:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memmove(PFTEMP,addr,PGSIZE);
  800ebe:	83 ec 04             	sub    $0x4,%esp
  800ec1:	68 00 10 00 00       	push   $0x1000
  800ec6:	53                   	push   %ebx
  800ec7:	68 00 f0 7f 00       	push   $0x7ff000
  800ecc:	e8 d8 fa ff ff       	call   8009a9 <memmove>
	if ((r = sys_page_map(eid, PFTEMP, eid, addr, PTE_P | PTE_W |PTE_U)) < 0)
  800ed1:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800ed8:	53                   	push   %ebx
  800ed9:	56                   	push   %esi
  800eda:	68 00 f0 7f 00       	push   $0x7ff000
  800edf:	56                   	push   %esi
  800ee0:	e8 aa fd ff ff       	call   800c8f <sys_page_map>
  800ee5:	83 c4 20             	add    $0x20,%esp
  800ee8:	85 c0                	test   %eax,%eax
  800eea:	79 12                	jns    800efe <pgfault+0xc1>
        panic("pgfault: page map failed %e\n", r);
  800eec:	50                   	push   %eax
  800eed:	68 65 26 80 00       	push   $0x802665
  800ef2:	6a 31                	push   $0x31
  800ef4:	68 27 26 80 00       	push   $0x802627
  800ef9:	e8 e1 0f 00 00       	call   801edf <_panic>
	if ((r = sys_page_unmap(eid, PFTEMP)) < 0)
  800efe:	83 ec 08             	sub    $0x8,%esp
  800f01:	68 00 f0 7f 00       	push   $0x7ff000
  800f06:	56                   	push   %esi
  800f07:	e8 c5 fd ff ff       	call   800cd1 <sys_page_unmap>
  800f0c:	83 c4 10             	add    $0x10,%esp
  800f0f:	85 c0                	test   %eax,%eax
  800f11:	79 12                	jns    800f25 <pgfault+0xe8>
        panic("pgfault: page unmap failed %e\n", r);
  800f13:	50                   	push   %eax
  800f14:	68 d4 26 80 00       	push   $0x8026d4
  800f19:	6a 33                	push   $0x33
  800f1b:	68 27 26 80 00       	push   $0x802627
  800f20:	e8 ba 0f 00 00       	call   801edf <_panic>
	// LAB 4: Your code here.

	// panic("pgfault not implemented");
}
  800f25:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f28:	5b                   	pop    %ebx
  800f29:	5e                   	pop    %esi
  800f2a:	5d                   	pop    %ebp
  800f2b:	c3                   	ret    

00800f2c <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f2c:	55                   	push   %ebp
  800f2d:	89 e5                	mov    %esp,%ebp
  800f2f:	57                   	push   %edi
  800f30:	56                   	push   %esi
  800f31:	53                   	push   %ebx
  800f32:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	struct PageInfo* pg = NULL;
	set_pgfault_handler(pgfault);
  800f35:	68 3d 0e 80 00       	push   $0x800e3d
  800f3a:	e8 e6 0f 00 00       	call   801f25 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800f3f:	b8 07 00 00 00       	mov    $0x7,%eax
  800f44:	cd 30                	int    $0x30
  800f46:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800f49:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t eid = sys_exofork();
	if (eid < 0) panic("fork fault.\n");
  800f4c:	83 c4 10             	add    $0x10,%esp
  800f4f:	85 c0                	test   %eax,%eax
  800f51:	79 14                	jns    800f67 <fork+0x3b>
  800f53:	83 ec 04             	sub    $0x4,%esp
  800f56:	68 82 26 80 00       	push   $0x802682
  800f5b:	6a 71                	push   $0x71
  800f5d:	68 27 26 80 00       	push   $0x802627
  800f62:	e8 78 0f 00 00       	call   801edf <_panic>
	if (eid == 0){
  800f67:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800f6b:	75 25                	jne    800f92 <fork+0x66>
		thisenv = &envs[ENVX(sys_getenvid())];
  800f6d:	e8 9c fc ff ff       	call   800c0e <sys_getenvid>
  800f72:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f77:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800f7e:	c1 e0 07             	shl    $0x7,%eax
  800f81:	29 d0                	sub    %edx,%eax
  800f83:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f88:	a3 08 40 80 00       	mov    %eax,0x804008
		return eid;
  800f8d:	e9 61 01 00 00       	jmp    8010f3 <fork+0x1c7>
  800f92:	bb 00 00 80 00       	mov    $0x800000,%ebx
	}
	// copy something to the child page.
	for (uintptr_t i = UTEXT;i <= USTACKTOP;i += PGSIZE){
		if (uvpd[PDX(i)] & PTE_P && (uvpt[PGNUM(i)] & PTE_P)){
  800f97:	89 d8                	mov    %ebx,%eax
  800f99:	c1 e8 16             	shr    $0x16,%eax
  800f9c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fa3:	a8 01                	test   $0x1,%al
  800fa5:	74 52                	je     800ff9 <fork+0xcd>
  800fa7:	89 de                	mov    %ebx,%esi
  800fa9:	c1 ee 0c             	shr    $0xc,%esi
  800fac:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800fb3:	a8 01                	test   $0x1,%al
  800fb5:	74 42                	je     800ff9 <fork+0xcd>
duppage(envid_t envid, unsigned pn)
{
	int r;

	// LAB 4: Your code here.
	envid_t myenvid = sys_getenvid();
  800fb7:	e8 52 fc ff ff       	call   800c0e <sys_getenvid>
  800fbc:	89 c7                	mov    %eax,%edi
	pte_t pte = uvpt[pn];
  800fbe:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
	int perm = PTE_U | PTE_P;
	if(pte & PTE_W || pte & PTE_COW)
  800fc5:	a9 02 08 00 00       	test   $0x802,%eax
  800fca:	0f 85 de 00 00 00    	jne    8010ae <fork+0x182>
  800fd0:	e9 fb 00 00 00       	jmp    8010d0 <fork+0x1a4>
		perm |= PTE_COW;
	if((r = sys_page_map(myenvid,(void*)(pn*PGSIZE),envid,(void*)(pn*PGSIZE),perm))<0){
		panic("duppage fault :%e\n",r);
  800fd5:	50                   	push   %eax
  800fd6:	68 8f 26 80 00       	push   $0x80268f
  800fdb:	6a 50                	push   $0x50
  800fdd:	68 27 26 80 00       	push   $0x802627
  800fe2:	e8 f8 0e 00 00       	call   801edf <_panic>
	}
	if(perm & PTE_COW){
		if((r = sys_page_map(myenvid,(void*)(pn*PGSIZE),myenvid,(void*)(pn*PGSIZE),perm))<0)
			panic("duppage fault :%e\n",r);
  800fe7:	50                   	push   %eax
  800fe8:	68 8f 26 80 00       	push   $0x80268f
  800fed:	6a 54                	push   $0x54
  800fef:	68 27 26 80 00       	push   $0x802627
  800ff4:	e8 e6 0e 00 00       	call   801edf <_panic>
	if (eid == 0){
		thisenv = &envs[ENVX(sys_getenvid())];
		return eid;
	}
	// copy something to the child page.
	for (uintptr_t i = UTEXT;i <= USTACKTOP;i += PGSIZE){
  800ff9:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800fff:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  801005:	75 90                	jne    800f97 <fork+0x6b>
		if (uvpd[PDX(i)] & PTE_P && (uvpt[PGNUM(i)] & PTE_P)){
			duppage(eid,PGNUM(i));
		}
	}
	int r = sys_page_alloc(eid,(void*)(UXSTACKTOP-PGSIZE),PTE_U|PTE_P|PTE_W);
  801007:	83 ec 04             	sub    $0x4,%esp
  80100a:	6a 07                	push   $0x7
  80100c:	68 00 f0 bf ee       	push   $0xeebff000
  801011:	ff 75 e0             	pushl  -0x20(%ebp)
  801014:	e8 33 fc ff ff       	call   800c4c <sys_page_alloc>
	if (r < 0) panic("fork fault.\n");
  801019:	83 c4 10             	add    $0x10,%esp
  80101c:	85 c0                	test   %eax,%eax
  80101e:	79 14                	jns    801034 <fork+0x108>
  801020:	83 ec 04             	sub    $0x4,%esp
  801023:	68 82 26 80 00       	push   $0x802682
  801028:	6a 7d                	push   $0x7d
  80102a:	68 27 26 80 00       	push   $0x802627
  80102f:	e8 ab 0e 00 00       	call   801edf <_panic>

	extern void _pgfault_upcall();
    r = sys_env_set_pgfault_upcall(eid, _pgfault_upcall);
  801034:	83 ec 08             	sub    $0x8,%esp
  801037:	68 9d 1f 80 00       	push   $0x801f9d
  80103c:	ff 75 e0             	pushl  -0x20(%ebp)
  80103f:	e8 53 fd ff ff       	call   800d97 <sys_env_set_pgfault_upcall>
    if (r < 0) panic("fork fault 3\n");
  801044:	83 c4 10             	add    $0x10,%esp
  801047:	85 c0                	test   %eax,%eax
  801049:	79 17                	jns    801062 <fork+0x136>
  80104b:	83 ec 04             	sub    $0x4,%esp
  80104e:	68 a2 26 80 00       	push   $0x8026a2
  801053:	68 81 00 00 00       	push   $0x81
  801058:	68 27 26 80 00       	push   $0x802627
  80105d:	e8 7d 0e 00 00       	call   801edf <_panic>

	if ((r = sys_env_set_status(eid, ENV_RUNNABLE)) < 0)
  801062:	83 ec 08             	sub    $0x8,%esp
  801065:	6a 02                	push   $0x2
  801067:	ff 75 e0             	pushl  -0x20(%ebp)
  80106a:	e8 a4 fc ff ff       	call   800d13 <sys_env_set_status>
  80106f:	83 c4 10             	add    $0x10,%esp
  801072:	85 c0                	test   %eax,%eax
  801074:	79 7d                	jns    8010f3 <fork+0x1c7>
        panic("fork fault 4\n");
  801076:	83 ec 04             	sub    $0x4,%esp
  801079:	68 b0 26 80 00       	push   $0x8026b0
  80107e:	68 84 00 00 00       	push   $0x84
  801083:	68 27 26 80 00       	push   $0x802627
  801088:	e8 52 0e 00 00       	call   801edf <_panic>
		perm |= PTE_COW;
	if((r = sys_page_map(myenvid,(void*)(pn*PGSIZE),envid,(void*)(pn*PGSIZE),perm))<0){
		panic("duppage fault :%e\n",r);
	}
	if(perm & PTE_COW){
		if((r = sys_page_map(myenvid,(void*)(pn*PGSIZE),myenvid,(void*)(pn*PGSIZE),perm))<0)
  80108d:	83 ec 0c             	sub    $0xc,%esp
  801090:	68 05 08 00 00       	push   $0x805
  801095:	56                   	push   %esi
  801096:	57                   	push   %edi
  801097:	56                   	push   %esi
  801098:	57                   	push   %edi
  801099:	e8 f1 fb ff ff       	call   800c8f <sys_page_map>
  80109e:	83 c4 20             	add    $0x20,%esp
  8010a1:	85 c0                	test   %eax,%eax
  8010a3:	0f 89 50 ff ff ff    	jns    800ff9 <fork+0xcd>
  8010a9:	e9 39 ff ff ff       	jmp    800fe7 <fork+0xbb>
	envid_t myenvid = sys_getenvid();
	pte_t pte = uvpt[pn];
	int perm = PTE_U | PTE_P;
	if(pte & PTE_W || pte & PTE_COW)
		perm |= PTE_COW;
	if((r = sys_page_map(myenvid,(void*)(pn*PGSIZE),envid,(void*)(pn*PGSIZE),perm))<0){
  8010ae:	c1 e6 0c             	shl    $0xc,%esi
  8010b1:	83 ec 0c             	sub    $0xc,%esp
  8010b4:	68 05 08 00 00       	push   $0x805
  8010b9:	56                   	push   %esi
  8010ba:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010bd:	56                   	push   %esi
  8010be:	57                   	push   %edi
  8010bf:	e8 cb fb ff ff       	call   800c8f <sys_page_map>
  8010c4:	83 c4 20             	add    $0x20,%esp
  8010c7:	85 c0                	test   %eax,%eax
  8010c9:	79 c2                	jns    80108d <fork+0x161>
  8010cb:	e9 05 ff ff ff       	jmp    800fd5 <fork+0xa9>
  8010d0:	c1 e6 0c             	shl    $0xc,%esi
  8010d3:	83 ec 0c             	sub    $0xc,%esp
  8010d6:	6a 05                	push   $0x5
  8010d8:	56                   	push   %esi
  8010d9:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010dc:	56                   	push   %esi
  8010dd:	57                   	push   %edi
  8010de:	e8 ac fb ff ff       	call   800c8f <sys_page_map>
  8010e3:	83 c4 20             	add    $0x20,%esp
  8010e6:	85 c0                	test   %eax,%eax
  8010e8:	0f 89 0b ff ff ff    	jns    800ff9 <fork+0xcd>
  8010ee:	e9 e2 fe ff ff       	jmp    800fd5 <fork+0xa9>
    if (r < 0) panic("fork fault 3\n");

	if ((r = sys_env_set_status(eid, ENV_RUNNABLE)) < 0)
        panic("fork fault 4\n");
    return eid;
}
  8010f3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8010f6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010f9:	5b                   	pop    %ebx
  8010fa:	5e                   	pop    %esi
  8010fb:	5f                   	pop    %edi
  8010fc:	5d                   	pop    %ebp
  8010fd:	c3                   	ret    

008010fe <sfork>:

// Challenge!
int
sfork(void)
{
  8010fe:	55                   	push   %ebp
  8010ff:	89 e5                	mov    %esp,%ebp
  801101:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801104:	68 be 26 80 00       	push   $0x8026be
  801109:	68 8c 00 00 00       	push   $0x8c
  80110e:	68 27 26 80 00       	push   $0x802627
  801113:	e8 c7 0d 00 00       	call   801edf <_panic>

00801118 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801118:	55                   	push   %ebp
  801119:	89 e5                	mov    %esp,%ebp
  80111b:	56                   	push   %esi
  80111c:	53                   	push   %ebx
  80111d:	8b 75 08             	mov    0x8(%ebp),%esi
  801120:	8b 45 0c             	mov    0xc(%ebp),%eax
  801123:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");
	int r;
    if (pg != NULL) {
  801126:	85 c0                	test   %eax,%eax
  801128:	74 0e                	je     801138 <ipc_recv+0x20>
        r = sys_ipc_recv(pg);
  80112a:	83 ec 0c             	sub    $0xc,%esp
  80112d:	50                   	push   %eax
  80112e:	e8 c9 fc ff ff       	call   800dfc <sys_ipc_recv>
  801133:	83 c4 10             	add    $0x10,%esp
  801136:	eb 10                	jmp    801148 <ipc_recv+0x30>
    } else {
        r = sys_ipc_recv((void *) UTOP);
  801138:	83 ec 0c             	sub    $0xc,%esp
  80113b:	68 00 00 c0 ee       	push   $0xeec00000
  801140:	e8 b7 fc ff ff       	call   800dfc <sys_ipc_recv>
  801145:	83 c4 10             	add    $0x10,%esp
    }
    if (r < 0) {
  801148:	85 c0                	test   %eax,%eax
  80114a:	79 16                	jns    801162 <ipc_recv+0x4a>
        // failed
        if (from_env_store != NULL) *from_env_store = 0;
  80114c:	85 f6                	test   %esi,%esi
  80114e:	74 06                	je     801156 <ipc_recv+0x3e>
  801150:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        if (perm_store != NULL) *perm_store = 0;
  801156:	85 db                	test   %ebx,%ebx
  801158:	74 2c                	je     801186 <ipc_recv+0x6e>
  80115a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801160:	eb 24                	jmp    801186 <ipc_recv+0x6e>
        return r;
    } else {
        if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801162:	85 f6                	test   %esi,%esi
  801164:	74 0a                	je     801170 <ipc_recv+0x58>
  801166:	a1 08 40 80 00       	mov    0x804008,%eax
  80116b:	8b 40 74             	mov    0x74(%eax),%eax
  80116e:	89 06                	mov    %eax,(%esi)
        if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801170:	85 db                	test   %ebx,%ebx
  801172:	74 0a                	je     80117e <ipc_recv+0x66>
  801174:	a1 08 40 80 00       	mov    0x804008,%eax
  801179:	8b 40 78             	mov    0x78(%eax),%eax
  80117c:	89 03                	mov    %eax,(%ebx)
        return thisenv->env_ipc_value;
  80117e:	a1 08 40 80 00       	mov    0x804008,%eax
  801183:	8b 40 70             	mov    0x70(%eax),%eax
    }
 
	return 0;
}
  801186:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801189:	5b                   	pop    %ebx
  80118a:	5e                   	pop    %esi
  80118b:	5d                   	pop    %ebp
  80118c:	c3                   	ret    

0080118d <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80118d:	55                   	push   %ebp
  80118e:	89 e5                	mov    %esp,%ebp
  801190:	57                   	push   %edi
  801191:	56                   	push   %esi
  801192:	53                   	push   %ebx
  801193:	83 ec 0c             	sub    $0xc,%esp
  801196:	8b 75 10             	mov    0x10(%ebp),%esi
  801199:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");
	int r;
    if (pg == NULL) pg = (void *)UTOP;
  80119c:	85 f6                	test   %esi,%esi
  80119e:	75 05                	jne    8011a5 <ipc_send+0x18>
  8011a0:	be 00 00 c0 ee       	mov    $0xeec00000,%esi
    do {
        r = sys_ipc_try_send(to_env, val, pg, perm);
  8011a5:	57                   	push   %edi
  8011a6:	56                   	push   %esi
  8011a7:	ff 75 0c             	pushl  0xc(%ebp)
  8011aa:	ff 75 08             	pushl  0x8(%ebp)
  8011ad:	e8 27 fc ff ff       	call   800dd9 <sys_ipc_try_send>
  8011b2:	89 c3                	mov    %eax,%ebx
        if (r < 0 && r != -E_IPC_NOT_RECV) panic("ipc send failed: %e", r);
  8011b4:	83 c4 10             	add    $0x10,%esp
  8011b7:	85 c0                	test   %eax,%eax
  8011b9:	79 17                	jns    8011d2 <ipc_send+0x45>
  8011bb:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8011be:	74 1d                	je     8011dd <ipc_send+0x50>
  8011c0:	50                   	push   %eax
  8011c1:	68 f3 26 80 00       	push   $0x8026f3
  8011c6:	6a 40                	push   $0x40
  8011c8:	68 07 27 80 00       	push   $0x802707
  8011cd:	e8 0d 0d 00 00       	call   801edf <_panic>
        sys_yield();
  8011d2:	e8 56 fa ff ff       	call   800c2d <sys_yield>
    } while (r != 0);
  8011d7:	85 db                	test   %ebx,%ebx
  8011d9:	75 ca                	jne    8011a5 <ipc_send+0x18>
  8011db:	eb 07                	jmp    8011e4 <ipc_send+0x57>
	int r;
    if (pg == NULL) pg = (void *)UTOP;
    do {
        r = sys_ipc_try_send(to_env, val, pg, perm);
        if (r < 0 && r != -E_IPC_NOT_RECV) panic("ipc send failed: %e", r);
        sys_yield();
  8011dd:	e8 4b fa ff ff       	call   800c2d <sys_yield>
  8011e2:	eb c1                	jmp    8011a5 <ipc_send+0x18>
    } while (r != 0);
}
  8011e4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011e7:	5b                   	pop    %ebx
  8011e8:	5e                   	pop    %esi
  8011e9:	5f                   	pop    %edi
  8011ea:	5d                   	pop    %ebp
  8011eb:	c3                   	ret    

008011ec <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8011ec:	55                   	push   %ebp
  8011ed:	89 e5                	mov    %esp,%ebp
  8011ef:	53                   	push   %ebx
  8011f0:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  8011f3:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  8011f8:	39 c1                	cmp    %eax,%ecx
  8011fa:	74 21                	je     80121d <ipc_find_env+0x31>
  8011fc:	ba 01 00 00 00       	mov    $0x1,%edx
  801201:	8d 1c 95 00 00 00 00 	lea    0x0(,%edx,4),%ebx
  801208:	89 d0                	mov    %edx,%eax
  80120a:	c1 e0 07             	shl    $0x7,%eax
  80120d:	29 d8                	sub    %ebx,%eax
  80120f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801214:	8b 40 50             	mov    0x50(%eax),%eax
  801217:	39 c8                	cmp    %ecx,%eax
  801219:	75 1b                	jne    801236 <ipc_find_env+0x4a>
  80121b:	eb 05                	jmp    801222 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80121d:	ba 00 00 00 00       	mov    $0x0,%edx
		if (envs[i].env_type == type)
			return envs[i].env_id;
  801222:	8d 04 95 00 00 00 00 	lea    0x0(,%edx,4),%eax
  801229:	c1 e2 07             	shl    $0x7,%edx
  80122c:	29 c2                	sub    %eax,%edx
  80122e:	8b 82 48 00 c0 ee    	mov    -0x113fffb8(%edx),%eax
  801234:	eb 0e                	jmp    801244 <ipc_find_env+0x58>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801236:	42                   	inc    %edx
  801237:	81 fa 00 04 00 00    	cmp    $0x400,%edx
  80123d:	75 c2                	jne    801201 <ipc_find_env+0x15>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80123f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801244:	5b                   	pop    %ebx
  801245:	5d                   	pop    %ebp
  801246:	c3                   	ret    

00801247 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801247:	55                   	push   %ebp
  801248:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80124a:	8b 45 08             	mov    0x8(%ebp),%eax
  80124d:	05 00 00 00 30       	add    $0x30000000,%eax
  801252:	c1 e8 0c             	shr    $0xc,%eax
}
  801255:	5d                   	pop    %ebp
  801256:	c3                   	ret    

00801257 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801257:	55                   	push   %ebp
  801258:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80125a:	8b 45 08             	mov    0x8(%ebp),%eax
  80125d:	05 00 00 00 30       	add    $0x30000000,%eax
  801262:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801267:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80126c:	5d                   	pop    %ebp
  80126d:	c3                   	ret    

0080126e <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80126e:	55                   	push   %ebp
  80126f:	89 e5                	mov    %esp,%ebp
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801271:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  801276:	a8 01                	test   $0x1,%al
  801278:	74 34                	je     8012ae <fd_alloc+0x40>
  80127a:	a1 00 00 74 ef       	mov    0xef740000,%eax
  80127f:	a8 01                	test   $0x1,%al
  801281:	74 32                	je     8012b5 <fd_alloc+0x47>
  801283:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  801288:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80128a:	89 c2                	mov    %eax,%edx
  80128c:	c1 ea 16             	shr    $0x16,%edx
  80128f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801296:	f6 c2 01             	test   $0x1,%dl
  801299:	74 1f                	je     8012ba <fd_alloc+0x4c>
  80129b:	89 c2                	mov    %eax,%edx
  80129d:	c1 ea 0c             	shr    $0xc,%edx
  8012a0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012a7:	f6 c2 01             	test   $0x1,%dl
  8012aa:	75 1a                	jne    8012c6 <fd_alloc+0x58>
  8012ac:	eb 0c                	jmp    8012ba <fd_alloc+0x4c>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8012ae:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  8012b3:	eb 05                	jmp    8012ba <fd_alloc+0x4c>
  8012b5:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  8012ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8012bd:	89 08                	mov    %ecx,(%eax)
			return 0;
  8012bf:	b8 00 00 00 00       	mov    $0x0,%eax
  8012c4:	eb 1a                	jmp    8012e0 <fd_alloc+0x72>
  8012c6:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8012cb:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8012d0:	75 b6                	jne    801288 <fd_alloc+0x1a>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8012d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8012d5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  8012db:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8012e0:	5d                   	pop    %ebp
  8012e1:	c3                   	ret    

008012e2 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8012e2:	55                   	push   %ebp
  8012e3:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8012e5:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
  8012e9:	77 39                	ja     801324 <fd_lookup+0x42>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8012eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8012ee:	c1 e0 0c             	shl    $0xc,%eax
  8012f1:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8012f6:	89 c2                	mov    %eax,%edx
  8012f8:	c1 ea 16             	shr    $0x16,%edx
  8012fb:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801302:	f6 c2 01             	test   $0x1,%dl
  801305:	74 24                	je     80132b <fd_lookup+0x49>
  801307:	89 c2                	mov    %eax,%edx
  801309:	c1 ea 0c             	shr    $0xc,%edx
  80130c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801313:	f6 c2 01             	test   $0x1,%dl
  801316:	74 1a                	je     801332 <fd_lookup+0x50>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801318:	8b 55 0c             	mov    0xc(%ebp),%edx
  80131b:	89 02                	mov    %eax,(%edx)
	return 0;
  80131d:	b8 00 00 00 00       	mov    $0x0,%eax
  801322:	eb 13                	jmp    801337 <fd_lookup+0x55>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801324:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801329:	eb 0c                	jmp    801337 <fd_lookup+0x55>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80132b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801330:	eb 05                	jmp    801337 <fd_lookup+0x55>
  801332:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801337:	5d                   	pop    %ebp
  801338:	c3                   	ret    

00801339 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801339:	55                   	push   %ebp
  80133a:	89 e5                	mov    %esp,%ebp
  80133c:	53                   	push   %ebx
  80133d:	83 ec 04             	sub    $0x4,%esp
  801340:	8b 45 08             	mov    0x8(%ebp),%eax
  801343:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  801346:	3b 05 04 30 80 00    	cmp    0x803004,%eax
  80134c:	75 1e                	jne    80136c <dev_lookup+0x33>
  80134e:	eb 0e                	jmp    80135e <dev_lookup+0x25>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801350:	b8 20 30 80 00       	mov    $0x803020,%eax
  801355:	eb 0c                	jmp    801363 <dev_lookup+0x2a>
  801357:	b8 3c 30 80 00       	mov    $0x80303c,%eax
  80135c:	eb 05                	jmp    801363 <dev_lookup+0x2a>
  80135e:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  801363:	89 03                	mov    %eax,(%ebx)
			return 0;
  801365:	b8 00 00 00 00       	mov    $0x0,%eax
  80136a:	eb 36                	jmp    8013a2 <dev_lookup+0x69>
int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  80136c:	3b 05 20 30 80 00    	cmp    0x803020,%eax
  801372:	74 dc                	je     801350 <dev_lookup+0x17>
  801374:	3b 05 3c 30 80 00    	cmp    0x80303c,%eax
  80137a:	74 db                	je     801357 <dev_lookup+0x1e>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80137c:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801382:	8b 52 48             	mov    0x48(%edx),%edx
  801385:	83 ec 04             	sub    $0x4,%esp
  801388:	50                   	push   %eax
  801389:	52                   	push   %edx
  80138a:	68 14 27 80 00       	push   $0x802714
  80138f:	e8 63 ee ff ff       	call   8001f7 <cprintf>
	*dev = 0;
  801394:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  80139a:	83 c4 10             	add    $0x10,%esp
  80139d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8013a2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013a5:	c9                   	leave  
  8013a6:	c3                   	ret    

008013a7 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8013a7:	55                   	push   %ebp
  8013a8:	89 e5                	mov    %esp,%ebp
  8013aa:	56                   	push   %esi
  8013ab:	53                   	push   %ebx
  8013ac:	83 ec 10             	sub    $0x10,%esp
  8013af:	8b 75 08             	mov    0x8(%ebp),%esi
  8013b2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8013b5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013b8:	50                   	push   %eax
  8013b9:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8013bf:	c1 e8 0c             	shr    $0xc,%eax
  8013c2:	50                   	push   %eax
  8013c3:	e8 1a ff ff ff       	call   8012e2 <fd_lookup>
  8013c8:	83 c4 08             	add    $0x8,%esp
  8013cb:	85 c0                	test   %eax,%eax
  8013cd:	78 05                	js     8013d4 <fd_close+0x2d>
	    || fd != fd2)
  8013cf:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8013d2:	74 06                	je     8013da <fd_close+0x33>
		return (must_exist ? r : 0);
  8013d4:	84 db                	test   %bl,%bl
  8013d6:	74 47                	je     80141f <fd_close+0x78>
  8013d8:	eb 4a                	jmp    801424 <fd_close+0x7d>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8013da:	83 ec 08             	sub    $0x8,%esp
  8013dd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013e0:	50                   	push   %eax
  8013e1:	ff 36                	pushl  (%esi)
  8013e3:	e8 51 ff ff ff       	call   801339 <dev_lookup>
  8013e8:	89 c3                	mov    %eax,%ebx
  8013ea:	83 c4 10             	add    $0x10,%esp
  8013ed:	85 c0                	test   %eax,%eax
  8013ef:	78 1c                	js     80140d <fd_close+0x66>
		if (dev->dev_close)
  8013f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013f4:	8b 40 10             	mov    0x10(%eax),%eax
  8013f7:	85 c0                	test   %eax,%eax
  8013f9:	74 0d                	je     801408 <fd_close+0x61>
			r = (*dev->dev_close)(fd);
  8013fb:	83 ec 0c             	sub    $0xc,%esp
  8013fe:	56                   	push   %esi
  8013ff:	ff d0                	call   *%eax
  801401:	89 c3                	mov    %eax,%ebx
  801403:	83 c4 10             	add    $0x10,%esp
  801406:	eb 05                	jmp    80140d <fd_close+0x66>
		else
			r = 0;
  801408:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80140d:	83 ec 08             	sub    $0x8,%esp
  801410:	56                   	push   %esi
  801411:	6a 00                	push   $0x0
  801413:	e8 b9 f8 ff ff       	call   800cd1 <sys_page_unmap>
	return r;
  801418:	83 c4 10             	add    $0x10,%esp
  80141b:	89 d8                	mov    %ebx,%eax
  80141d:	eb 05                	jmp    801424 <fd_close+0x7d>
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
  80141f:	b8 00 00 00 00       	mov    $0x0,%eax
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
	return r;
}
  801424:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801427:	5b                   	pop    %ebx
  801428:	5e                   	pop    %esi
  801429:	5d                   	pop    %ebp
  80142a:	c3                   	ret    

0080142b <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80142b:	55                   	push   %ebp
  80142c:	89 e5                	mov    %esp,%ebp
  80142e:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801431:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801434:	50                   	push   %eax
  801435:	ff 75 08             	pushl  0x8(%ebp)
  801438:	e8 a5 fe ff ff       	call   8012e2 <fd_lookup>
  80143d:	83 c4 08             	add    $0x8,%esp
  801440:	85 c0                	test   %eax,%eax
  801442:	78 10                	js     801454 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801444:	83 ec 08             	sub    $0x8,%esp
  801447:	6a 01                	push   $0x1
  801449:	ff 75 f4             	pushl  -0xc(%ebp)
  80144c:	e8 56 ff ff ff       	call   8013a7 <fd_close>
  801451:	83 c4 10             	add    $0x10,%esp
}
  801454:	c9                   	leave  
  801455:	c3                   	ret    

00801456 <close_all>:

void
close_all(void)
{
  801456:	55                   	push   %ebp
  801457:	89 e5                	mov    %esp,%ebp
  801459:	53                   	push   %ebx
  80145a:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80145d:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801462:	83 ec 0c             	sub    $0xc,%esp
  801465:	53                   	push   %ebx
  801466:	e8 c0 ff ff ff       	call   80142b <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80146b:	43                   	inc    %ebx
  80146c:	83 c4 10             	add    $0x10,%esp
  80146f:	83 fb 20             	cmp    $0x20,%ebx
  801472:	75 ee                	jne    801462 <close_all+0xc>
		close(i);
}
  801474:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801477:	c9                   	leave  
  801478:	c3                   	ret    

00801479 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801479:	55                   	push   %ebp
  80147a:	89 e5                	mov    %esp,%ebp
  80147c:	57                   	push   %edi
  80147d:	56                   	push   %esi
  80147e:	53                   	push   %ebx
  80147f:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801482:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801485:	50                   	push   %eax
  801486:	ff 75 08             	pushl  0x8(%ebp)
  801489:	e8 54 fe ff ff       	call   8012e2 <fd_lookup>
  80148e:	83 c4 08             	add    $0x8,%esp
  801491:	85 c0                	test   %eax,%eax
  801493:	0f 88 c2 00 00 00    	js     80155b <dup+0xe2>
		return r;
	close(newfdnum);
  801499:	83 ec 0c             	sub    $0xc,%esp
  80149c:	ff 75 0c             	pushl  0xc(%ebp)
  80149f:	e8 87 ff ff ff       	call   80142b <close>

	newfd = INDEX2FD(newfdnum);
  8014a4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8014a7:	c1 e3 0c             	shl    $0xc,%ebx
  8014aa:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8014b0:	83 c4 04             	add    $0x4,%esp
  8014b3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8014b6:	e8 9c fd ff ff       	call   801257 <fd2data>
  8014bb:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  8014bd:	89 1c 24             	mov    %ebx,(%esp)
  8014c0:	e8 92 fd ff ff       	call   801257 <fd2data>
  8014c5:	83 c4 10             	add    $0x10,%esp
  8014c8:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8014ca:	89 f0                	mov    %esi,%eax
  8014cc:	c1 e8 16             	shr    $0x16,%eax
  8014cf:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8014d6:	a8 01                	test   $0x1,%al
  8014d8:	74 35                	je     80150f <dup+0x96>
  8014da:	89 f0                	mov    %esi,%eax
  8014dc:	c1 e8 0c             	shr    $0xc,%eax
  8014df:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8014e6:	f6 c2 01             	test   $0x1,%dl
  8014e9:	74 24                	je     80150f <dup+0x96>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8014eb:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014f2:	83 ec 0c             	sub    $0xc,%esp
  8014f5:	25 07 0e 00 00       	and    $0xe07,%eax
  8014fa:	50                   	push   %eax
  8014fb:	57                   	push   %edi
  8014fc:	6a 00                	push   $0x0
  8014fe:	56                   	push   %esi
  8014ff:	6a 00                	push   $0x0
  801501:	e8 89 f7 ff ff       	call   800c8f <sys_page_map>
  801506:	89 c6                	mov    %eax,%esi
  801508:	83 c4 20             	add    $0x20,%esp
  80150b:	85 c0                	test   %eax,%eax
  80150d:	78 2c                	js     80153b <dup+0xc2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80150f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801512:	89 d0                	mov    %edx,%eax
  801514:	c1 e8 0c             	shr    $0xc,%eax
  801517:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80151e:	83 ec 0c             	sub    $0xc,%esp
  801521:	25 07 0e 00 00       	and    $0xe07,%eax
  801526:	50                   	push   %eax
  801527:	53                   	push   %ebx
  801528:	6a 00                	push   $0x0
  80152a:	52                   	push   %edx
  80152b:	6a 00                	push   $0x0
  80152d:	e8 5d f7 ff ff       	call   800c8f <sys_page_map>
  801532:	89 c6                	mov    %eax,%esi
  801534:	83 c4 20             	add    $0x20,%esp
  801537:	85 c0                	test   %eax,%eax
  801539:	79 1d                	jns    801558 <dup+0xdf>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80153b:	83 ec 08             	sub    $0x8,%esp
  80153e:	53                   	push   %ebx
  80153f:	6a 00                	push   $0x0
  801541:	e8 8b f7 ff ff       	call   800cd1 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801546:	83 c4 08             	add    $0x8,%esp
  801549:	57                   	push   %edi
  80154a:	6a 00                	push   $0x0
  80154c:	e8 80 f7 ff ff       	call   800cd1 <sys_page_unmap>
	return r;
  801551:	83 c4 10             	add    $0x10,%esp
  801554:	89 f0                	mov    %esi,%eax
  801556:	eb 03                	jmp    80155b <dup+0xe2>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801558:	8b 45 0c             	mov    0xc(%ebp),%eax

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80155b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80155e:	5b                   	pop    %ebx
  80155f:	5e                   	pop    %esi
  801560:	5f                   	pop    %edi
  801561:	5d                   	pop    %ebp
  801562:	c3                   	ret    

00801563 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801563:	55                   	push   %ebp
  801564:	89 e5                	mov    %esp,%ebp
  801566:	53                   	push   %ebx
  801567:	83 ec 14             	sub    $0x14,%esp
  80156a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80156d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801570:	50                   	push   %eax
  801571:	53                   	push   %ebx
  801572:	e8 6b fd ff ff       	call   8012e2 <fd_lookup>
  801577:	83 c4 08             	add    $0x8,%esp
  80157a:	85 c0                	test   %eax,%eax
  80157c:	78 67                	js     8015e5 <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80157e:	83 ec 08             	sub    $0x8,%esp
  801581:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801584:	50                   	push   %eax
  801585:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801588:	ff 30                	pushl  (%eax)
  80158a:	e8 aa fd ff ff       	call   801339 <dev_lookup>
  80158f:	83 c4 10             	add    $0x10,%esp
  801592:	85 c0                	test   %eax,%eax
  801594:	78 4f                	js     8015e5 <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801596:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801599:	8b 42 08             	mov    0x8(%edx),%eax
  80159c:	83 e0 03             	and    $0x3,%eax
  80159f:	83 f8 01             	cmp    $0x1,%eax
  8015a2:	75 21                	jne    8015c5 <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8015a4:	a1 08 40 80 00       	mov    0x804008,%eax
  8015a9:	8b 40 48             	mov    0x48(%eax),%eax
  8015ac:	83 ec 04             	sub    $0x4,%esp
  8015af:	53                   	push   %ebx
  8015b0:	50                   	push   %eax
  8015b1:	68 55 27 80 00       	push   $0x802755
  8015b6:	e8 3c ec ff ff       	call   8001f7 <cprintf>
		return -E_INVAL;
  8015bb:	83 c4 10             	add    $0x10,%esp
  8015be:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015c3:	eb 20                	jmp    8015e5 <read+0x82>
	}
	if (!dev->dev_read)
  8015c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015c8:	8b 40 08             	mov    0x8(%eax),%eax
  8015cb:	85 c0                	test   %eax,%eax
  8015cd:	74 11                	je     8015e0 <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8015cf:	83 ec 04             	sub    $0x4,%esp
  8015d2:	ff 75 10             	pushl  0x10(%ebp)
  8015d5:	ff 75 0c             	pushl  0xc(%ebp)
  8015d8:	52                   	push   %edx
  8015d9:	ff d0                	call   *%eax
  8015db:	83 c4 10             	add    $0x10,%esp
  8015de:	eb 05                	jmp    8015e5 <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8015e0:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8015e5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015e8:	c9                   	leave  
  8015e9:	c3                   	ret    

008015ea <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8015ea:	55                   	push   %ebp
  8015eb:	89 e5                	mov    %esp,%ebp
  8015ed:	57                   	push   %edi
  8015ee:	56                   	push   %esi
  8015ef:	53                   	push   %ebx
  8015f0:	83 ec 0c             	sub    $0xc,%esp
  8015f3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8015f6:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015f9:	85 f6                	test   %esi,%esi
  8015fb:	74 31                	je     80162e <readn+0x44>
  8015fd:	b8 00 00 00 00       	mov    $0x0,%eax
  801602:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  801607:	83 ec 04             	sub    $0x4,%esp
  80160a:	89 f2                	mov    %esi,%edx
  80160c:	29 c2                	sub    %eax,%edx
  80160e:	52                   	push   %edx
  80160f:	03 45 0c             	add    0xc(%ebp),%eax
  801612:	50                   	push   %eax
  801613:	57                   	push   %edi
  801614:	e8 4a ff ff ff       	call   801563 <read>
		if (m < 0)
  801619:	83 c4 10             	add    $0x10,%esp
  80161c:	85 c0                	test   %eax,%eax
  80161e:	78 17                	js     801637 <readn+0x4d>
			return m;
		if (m == 0)
  801620:	85 c0                	test   %eax,%eax
  801622:	74 11                	je     801635 <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801624:	01 c3                	add    %eax,%ebx
  801626:	89 d8                	mov    %ebx,%eax
  801628:	39 f3                	cmp    %esi,%ebx
  80162a:	72 db                	jb     801607 <readn+0x1d>
  80162c:	eb 09                	jmp    801637 <readn+0x4d>
  80162e:	b8 00 00 00 00       	mov    $0x0,%eax
  801633:	eb 02                	jmp    801637 <readn+0x4d>
  801635:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801637:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80163a:	5b                   	pop    %ebx
  80163b:	5e                   	pop    %esi
  80163c:	5f                   	pop    %edi
  80163d:	5d                   	pop    %ebp
  80163e:	c3                   	ret    

0080163f <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80163f:	55                   	push   %ebp
  801640:	89 e5                	mov    %esp,%ebp
  801642:	53                   	push   %ebx
  801643:	83 ec 14             	sub    $0x14,%esp
  801646:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801649:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80164c:	50                   	push   %eax
  80164d:	53                   	push   %ebx
  80164e:	e8 8f fc ff ff       	call   8012e2 <fd_lookup>
  801653:	83 c4 08             	add    $0x8,%esp
  801656:	85 c0                	test   %eax,%eax
  801658:	78 62                	js     8016bc <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80165a:	83 ec 08             	sub    $0x8,%esp
  80165d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801660:	50                   	push   %eax
  801661:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801664:	ff 30                	pushl  (%eax)
  801666:	e8 ce fc ff ff       	call   801339 <dev_lookup>
  80166b:	83 c4 10             	add    $0x10,%esp
  80166e:	85 c0                	test   %eax,%eax
  801670:	78 4a                	js     8016bc <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801672:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801675:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801679:	75 21                	jne    80169c <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80167b:	a1 08 40 80 00       	mov    0x804008,%eax
  801680:	8b 40 48             	mov    0x48(%eax),%eax
  801683:	83 ec 04             	sub    $0x4,%esp
  801686:	53                   	push   %ebx
  801687:	50                   	push   %eax
  801688:	68 71 27 80 00       	push   $0x802771
  80168d:	e8 65 eb ff ff       	call   8001f7 <cprintf>
		return -E_INVAL;
  801692:	83 c4 10             	add    $0x10,%esp
  801695:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80169a:	eb 20                	jmp    8016bc <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80169c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80169f:	8b 52 0c             	mov    0xc(%edx),%edx
  8016a2:	85 d2                	test   %edx,%edx
  8016a4:	74 11                	je     8016b7 <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8016a6:	83 ec 04             	sub    $0x4,%esp
  8016a9:	ff 75 10             	pushl  0x10(%ebp)
  8016ac:	ff 75 0c             	pushl  0xc(%ebp)
  8016af:	50                   	push   %eax
  8016b0:	ff d2                	call   *%edx
  8016b2:	83 c4 10             	add    $0x10,%esp
  8016b5:	eb 05                	jmp    8016bc <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8016b7:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8016bc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016bf:	c9                   	leave  
  8016c0:	c3                   	ret    

008016c1 <seek>:

int
seek(int fdnum, off_t offset)
{
  8016c1:	55                   	push   %ebp
  8016c2:	89 e5                	mov    %esp,%ebp
  8016c4:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8016c7:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8016ca:	50                   	push   %eax
  8016cb:	ff 75 08             	pushl  0x8(%ebp)
  8016ce:	e8 0f fc ff ff       	call   8012e2 <fd_lookup>
  8016d3:	83 c4 08             	add    $0x8,%esp
  8016d6:	85 c0                	test   %eax,%eax
  8016d8:	78 0e                	js     8016e8 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8016da:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8016dd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016e0:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8016e3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016e8:	c9                   	leave  
  8016e9:	c3                   	ret    

008016ea <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8016ea:	55                   	push   %ebp
  8016eb:	89 e5                	mov    %esp,%ebp
  8016ed:	53                   	push   %ebx
  8016ee:	83 ec 14             	sub    $0x14,%esp
  8016f1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016f4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016f7:	50                   	push   %eax
  8016f8:	53                   	push   %ebx
  8016f9:	e8 e4 fb ff ff       	call   8012e2 <fd_lookup>
  8016fe:	83 c4 08             	add    $0x8,%esp
  801701:	85 c0                	test   %eax,%eax
  801703:	78 5f                	js     801764 <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801705:	83 ec 08             	sub    $0x8,%esp
  801708:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80170b:	50                   	push   %eax
  80170c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80170f:	ff 30                	pushl  (%eax)
  801711:	e8 23 fc ff ff       	call   801339 <dev_lookup>
  801716:	83 c4 10             	add    $0x10,%esp
  801719:	85 c0                	test   %eax,%eax
  80171b:	78 47                	js     801764 <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80171d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801720:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801724:	75 21                	jne    801747 <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801726:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80172b:	8b 40 48             	mov    0x48(%eax),%eax
  80172e:	83 ec 04             	sub    $0x4,%esp
  801731:	53                   	push   %ebx
  801732:	50                   	push   %eax
  801733:	68 34 27 80 00       	push   $0x802734
  801738:	e8 ba ea ff ff       	call   8001f7 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80173d:	83 c4 10             	add    $0x10,%esp
  801740:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801745:	eb 1d                	jmp    801764 <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  801747:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80174a:	8b 52 18             	mov    0x18(%edx),%edx
  80174d:	85 d2                	test   %edx,%edx
  80174f:	74 0e                	je     80175f <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801751:	83 ec 08             	sub    $0x8,%esp
  801754:	ff 75 0c             	pushl  0xc(%ebp)
  801757:	50                   	push   %eax
  801758:	ff d2                	call   *%edx
  80175a:	83 c4 10             	add    $0x10,%esp
  80175d:	eb 05                	jmp    801764 <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80175f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801764:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801767:	c9                   	leave  
  801768:	c3                   	ret    

00801769 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801769:	55                   	push   %ebp
  80176a:	89 e5                	mov    %esp,%ebp
  80176c:	53                   	push   %ebx
  80176d:	83 ec 14             	sub    $0x14,%esp
  801770:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801773:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801776:	50                   	push   %eax
  801777:	ff 75 08             	pushl  0x8(%ebp)
  80177a:	e8 63 fb ff ff       	call   8012e2 <fd_lookup>
  80177f:	83 c4 08             	add    $0x8,%esp
  801782:	85 c0                	test   %eax,%eax
  801784:	78 52                	js     8017d8 <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801786:	83 ec 08             	sub    $0x8,%esp
  801789:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80178c:	50                   	push   %eax
  80178d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801790:	ff 30                	pushl  (%eax)
  801792:	e8 a2 fb ff ff       	call   801339 <dev_lookup>
  801797:	83 c4 10             	add    $0x10,%esp
  80179a:	85 c0                	test   %eax,%eax
  80179c:	78 3a                	js     8017d8 <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  80179e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017a1:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8017a5:	74 2c                	je     8017d3 <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8017a7:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8017aa:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8017b1:	00 00 00 
	stat->st_isdir = 0;
  8017b4:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8017bb:	00 00 00 
	stat->st_dev = dev;
  8017be:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8017c4:	83 ec 08             	sub    $0x8,%esp
  8017c7:	53                   	push   %ebx
  8017c8:	ff 75 f0             	pushl  -0x10(%ebp)
  8017cb:	ff 50 14             	call   *0x14(%eax)
  8017ce:	83 c4 10             	add    $0x10,%esp
  8017d1:	eb 05                	jmp    8017d8 <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8017d3:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8017d8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017db:	c9                   	leave  
  8017dc:	c3                   	ret    

008017dd <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8017dd:	55                   	push   %ebp
  8017de:	89 e5                	mov    %esp,%ebp
  8017e0:	56                   	push   %esi
  8017e1:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8017e2:	83 ec 08             	sub    $0x8,%esp
  8017e5:	6a 00                	push   $0x0
  8017e7:	ff 75 08             	pushl  0x8(%ebp)
  8017ea:	e8 75 01 00 00       	call   801964 <open>
  8017ef:	89 c3                	mov    %eax,%ebx
  8017f1:	83 c4 10             	add    $0x10,%esp
  8017f4:	85 c0                	test   %eax,%eax
  8017f6:	78 1d                	js     801815 <stat+0x38>
		return fd;
	r = fstat(fd, stat);
  8017f8:	83 ec 08             	sub    $0x8,%esp
  8017fb:	ff 75 0c             	pushl  0xc(%ebp)
  8017fe:	50                   	push   %eax
  8017ff:	e8 65 ff ff ff       	call   801769 <fstat>
  801804:	89 c6                	mov    %eax,%esi
	close(fd);
  801806:	89 1c 24             	mov    %ebx,(%esp)
  801809:	e8 1d fc ff ff       	call   80142b <close>
	return r;
  80180e:	83 c4 10             	add    $0x10,%esp
  801811:	89 f0                	mov    %esi,%eax
  801813:	eb 00                	jmp    801815 <stat+0x38>
}
  801815:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801818:	5b                   	pop    %ebx
  801819:	5e                   	pop    %esi
  80181a:	5d                   	pop    %ebp
  80181b:	c3                   	ret    

0080181c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80181c:	55                   	push   %ebp
  80181d:	89 e5                	mov    %esp,%ebp
  80181f:	56                   	push   %esi
  801820:	53                   	push   %ebx
  801821:	89 c6                	mov    %eax,%esi
  801823:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801825:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80182c:	75 12                	jne    801840 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80182e:	83 ec 0c             	sub    $0xc,%esp
  801831:	6a 01                	push   $0x1
  801833:	e8 b4 f9 ff ff       	call   8011ec <ipc_find_env>
  801838:	a3 00 40 80 00       	mov    %eax,0x804000
  80183d:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801840:	6a 07                	push   $0x7
  801842:	68 00 50 80 00       	push   $0x805000
  801847:	56                   	push   %esi
  801848:	ff 35 00 40 80 00    	pushl  0x804000
  80184e:	e8 3a f9 ff ff       	call   80118d <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801853:	83 c4 0c             	add    $0xc,%esp
  801856:	6a 00                	push   $0x0
  801858:	53                   	push   %ebx
  801859:	6a 00                	push   $0x0
  80185b:	e8 b8 f8 ff ff       	call   801118 <ipc_recv>
}
  801860:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801863:	5b                   	pop    %ebx
  801864:	5e                   	pop    %esi
  801865:	5d                   	pop    %ebp
  801866:	c3                   	ret    

00801867 <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801867:	55                   	push   %ebp
  801868:	89 e5                	mov    %esp,%ebp
  80186a:	53                   	push   %ebx
  80186b:	83 ec 04             	sub    $0x4,%esp
  80186e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801871:	8b 45 08             	mov    0x8(%ebp),%eax
  801874:	8b 40 0c             	mov    0xc(%eax),%eax
  801877:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80187c:	ba 00 00 00 00       	mov    $0x0,%edx
  801881:	b8 05 00 00 00       	mov    $0x5,%eax
  801886:	e8 91 ff ff ff       	call   80181c <fsipc>
  80188b:	85 c0                	test   %eax,%eax
  80188d:	78 2c                	js     8018bb <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80188f:	83 ec 08             	sub    $0x8,%esp
  801892:	68 00 50 80 00       	push   $0x805000
  801897:	53                   	push   %ebx
  801898:	e8 3f ef ff ff       	call   8007dc <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80189d:	a1 80 50 80 00       	mov    0x805080,%eax
  8018a2:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8018a8:	a1 84 50 80 00       	mov    0x805084,%eax
  8018ad:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8018b3:	83 c4 10             	add    $0x10,%esp
  8018b6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018bb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018be:	c9                   	leave  
  8018bf:	c3                   	ret    

008018c0 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8018c0:	55                   	push   %ebp
  8018c1:	89 e5                	mov    %esp,%ebp
  8018c3:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8018c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8018c9:	8b 40 0c             	mov    0xc(%eax),%eax
  8018cc:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8018d1:	ba 00 00 00 00       	mov    $0x0,%edx
  8018d6:	b8 06 00 00 00       	mov    $0x6,%eax
  8018db:	e8 3c ff ff ff       	call   80181c <fsipc>
}
  8018e0:	c9                   	leave  
  8018e1:	c3                   	ret    

008018e2 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8018e2:	55                   	push   %ebp
  8018e3:	89 e5                	mov    %esp,%ebp
  8018e5:	56                   	push   %esi
  8018e6:	53                   	push   %ebx
  8018e7:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8018ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8018ed:	8b 40 0c             	mov    0xc(%eax),%eax
  8018f0:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8018f5:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8018fb:	ba 00 00 00 00       	mov    $0x0,%edx
  801900:	b8 03 00 00 00       	mov    $0x3,%eax
  801905:	e8 12 ff ff ff       	call   80181c <fsipc>
  80190a:	89 c3                	mov    %eax,%ebx
  80190c:	85 c0                	test   %eax,%eax
  80190e:	78 4b                	js     80195b <devfile_read+0x79>
		return r;
	assert(r <= n);
  801910:	39 c6                	cmp    %eax,%esi
  801912:	73 16                	jae    80192a <devfile_read+0x48>
  801914:	68 8e 27 80 00       	push   $0x80278e
  801919:	68 95 27 80 00       	push   $0x802795
  80191e:	6a 7a                	push   $0x7a
  801920:	68 aa 27 80 00       	push   $0x8027aa
  801925:	e8 b5 05 00 00       	call   801edf <_panic>
	assert(r <= PGSIZE);
  80192a:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80192f:	7e 16                	jle    801947 <devfile_read+0x65>
  801931:	68 b5 27 80 00       	push   $0x8027b5
  801936:	68 95 27 80 00       	push   $0x802795
  80193b:	6a 7b                	push   $0x7b
  80193d:	68 aa 27 80 00       	push   $0x8027aa
  801942:	e8 98 05 00 00       	call   801edf <_panic>
	memmove(buf, &fsipcbuf, r);
  801947:	83 ec 04             	sub    $0x4,%esp
  80194a:	50                   	push   %eax
  80194b:	68 00 50 80 00       	push   $0x805000
  801950:	ff 75 0c             	pushl  0xc(%ebp)
  801953:	e8 51 f0 ff ff       	call   8009a9 <memmove>
	return r;
  801958:	83 c4 10             	add    $0x10,%esp
}
  80195b:	89 d8                	mov    %ebx,%eax
  80195d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801960:	5b                   	pop    %ebx
  801961:	5e                   	pop    %esi
  801962:	5d                   	pop    %ebp
  801963:	c3                   	ret    

00801964 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801964:	55                   	push   %ebp
  801965:	89 e5                	mov    %esp,%ebp
  801967:	53                   	push   %ebx
  801968:	83 ec 20             	sub    $0x20,%esp
  80196b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80196e:	53                   	push   %ebx
  80196f:	e8 11 ee ff ff       	call   800785 <strlen>
  801974:	83 c4 10             	add    $0x10,%esp
  801977:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80197c:	7f 63                	jg     8019e1 <open+0x7d>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80197e:	83 ec 0c             	sub    $0xc,%esp
  801981:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801984:	50                   	push   %eax
  801985:	e8 e4 f8 ff ff       	call   80126e <fd_alloc>
  80198a:	83 c4 10             	add    $0x10,%esp
  80198d:	85 c0                	test   %eax,%eax
  80198f:	78 55                	js     8019e6 <open+0x82>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801991:	83 ec 08             	sub    $0x8,%esp
  801994:	53                   	push   %ebx
  801995:	68 00 50 80 00       	push   $0x805000
  80199a:	e8 3d ee ff ff       	call   8007dc <strcpy>
	fsipcbuf.open.req_omode = mode;
  80199f:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019a2:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8019a7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019aa:	b8 01 00 00 00       	mov    $0x1,%eax
  8019af:	e8 68 fe ff ff       	call   80181c <fsipc>
  8019b4:	89 c3                	mov    %eax,%ebx
  8019b6:	83 c4 10             	add    $0x10,%esp
  8019b9:	85 c0                	test   %eax,%eax
  8019bb:	79 14                	jns    8019d1 <open+0x6d>
		fd_close(fd, 0);
  8019bd:	83 ec 08             	sub    $0x8,%esp
  8019c0:	6a 00                	push   $0x0
  8019c2:	ff 75 f4             	pushl  -0xc(%ebp)
  8019c5:	e8 dd f9 ff ff       	call   8013a7 <fd_close>
		return r;
  8019ca:	83 c4 10             	add    $0x10,%esp
  8019cd:	89 d8                	mov    %ebx,%eax
  8019cf:	eb 15                	jmp    8019e6 <open+0x82>
	}

	return fd2num(fd);
  8019d1:	83 ec 0c             	sub    $0xc,%esp
  8019d4:	ff 75 f4             	pushl  -0xc(%ebp)
  8019d7:	e8 6b f8 ff ff       	call   801247 <fd2num>
  8019dc:	83 c4 10             	add    $0x10,%esp
  8019df:	eb 05                	jmp    8019e6 <open+0x82>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8019e1:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8019e6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019e9:	c9                   	leave  
  8019ea:	c3                   	ret    

008019eb <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8019eb:	55                   	push   %ebp
  8019ec:	89 e5                	mov    %esp,%ebp
  8019ee:	56                   	push   %esi
  8019ef:	53                   	push   %ebx
  8019f0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8019f3:	83 ec 0c             	sub    $0xc,%esp
  8019f6:	ff 75 08             	pushl  0x8(%ebp)
  8019f9:	e8 59 f8 ff ff       	call   801257 <fd2data>
  8019fe:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801a00:	83 c4 08             	add    $0x8,%esp
  801a03:	68 c1 27 80 00       	push   $0x8027c1
  801a08:	53                   	push   %ebx
  801a09:	e8 ce ed ff ff       	call   8007dc <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801a0e:	8b 46 04             	mov    0x4(%esi),%eax
  801a11:	2b 06                	sub    (%esi),%eax
  801a13:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801a19:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a20:	00 00 00 
	stat->st_dev = &devpipe;
  801a23:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801a2a:	30 80 00 
	return 0;
}
  801a2d:	b8 00 00 00 00       	mov    $0x0,%eax
  801a32:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a35:	5b                   	pop    %ebx
  801a36:	5e                   	pop    %esi
  801a37:	5d                   	pop    %ebp
  801a38:	c3                   	ret    

00801a39 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a39:	55                   	push   %ebp
  801a3a:	89 e5                	mov    %esp,%ebp
  801a3c:	53                   	push   %ebx
  801a3d:	83 ec 0c             	sub    $0xc,%esp
  801a40:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a43:	53                   	push   %ebx
  801a44:	6a 00                	push   $0x0
  801a46:	e8 86 f2 ff ff       	call   800cd1 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a4b:	89 1c 24             	mov    %ebx,(%esp)
  801a4e:	e8 04 f8 ff ff       	call   801257 <fd2data>
  801a53:	83 c4 08             	add    $0x8,%esp
  801a56:	50                   	push   %eax
  801a57:	6a 00                	push   $0x0
  801a59:	e8 73 f2 ff ff       	call   800cd1 <sys_page_unmap>
}
  801a5e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a61:	c9                   	leave  
  801a62:	c3                   	ret    

00801a63 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801a63:	55                   	push   %ebp
  801a64:	89 e5                	mov    %esp,%ebp
  801a66:	57                   	push   %edi
  801a67:	56                   	push   %esi
  801a68:	53                   	push   %ebx
  801a69:	83 ec 1c             	sub    $0x1c,%esp
  801a6c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801a6f:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801a71:	a1 08 40 80 00       	mov    0x804008,%eax
  801a76:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801a79:	83 ec 0c             	sub    $0xc,%esp
  801a7c:	ff 75 e0             	pushl  -0x20(%ebp)
  801a7f:	e8 3f 05 00 00       	call   801fc3 <pageref>
  801a84:	89 c3                	mov    %eax,%ebx
  801a86:	89 3c 24             	mov    %edi,(%esp)
  801a89:	e8 35 05 00 00       	call   801fc3 <pageref>
  801a8e:	83 c4 10             	add    $0x10,%esp
  801a91:	39 c3                	cmp    %eax,%ebx
  801a93:	0f 94 c1             	sete   %cl
  801a96:	0f b6 c9             	movzbl %cl,%ecx
  801a99:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801a9c:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801aa2:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801aa5:	39 ce                	cmp    %ecx,%esi
  801aa7:	74 1b                	je     801ac4 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801aa9:	39 c3                	cmp    %eax,%ebx
  801aab:	75 c4                	jne    801a71 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801aad:	8b 42 58             	mov    0x58(%edx),%eax
  801ab0:	ff 75 e4             	pushl  -0x1c(%ebp)
  801ab3:	50                   	push   %eax
  801ab4:	56                   	push   %esi
  801ab5:	68 c8 27 80 00       	push   $0x8027c8
  801aba:	e8 38 e7 ff ff       	call   8001f7 <cprintf>
  801abf:	83 c4 10             	add    $0x10,%esp
  801ac2:	eb ad                	jmp    801a71 <_pipeisclosed+0xe>
	}
}
  801ac4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ac7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801aca:	5b                   	pop    %ebx
  801acb:	5e                   	pop    %esi
  801acc:	5f                   	pop    %edi
  801acd:	5d                   	pop    %ebp
  801ace:	c3                   	ret    

00801acf <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801acf:	55                   	push   %ebp
  801ad0:	89 e5                	mov    %esp,%ebp
  801ad2:	57                   	push   %edi
  801ad3:	56                   	push   %esi
  801ad4:	53                   	push   %ebx
  801ad5:	83 ec 18             	sub    $0x18,%esp
  801ad8:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801adb:	56                   	push   %esi
  801adc:	e8 76 f7 ff ff       	call   801257 <fd2data>
  801ae1:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ae3:	83 c4 10             	add    $0x10,%esp
  801ae6:	bf 00 00 00 00       	mov    $0x0,%edi
  801aeb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801aef:	75 42                	jne    801b33 <devpipe_write+0x64>
  801af1:	eb 4e                	jmp    801b41 <devpipe_write+0x72>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801af3:	89 da                	mov    %ebx,%edx
  801af5:	89 f0                	mov    %esi,%eax
  801af7:	e8 67 ff ff ff       	call   801a63 <_pipeisclosed>
  801afc:	85 c0                	test   %eax,%eax
  801afe:	75 46                	jne    801b46 <devpipe_write+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801b00:	e8 28 f1 ff ff       	call   800c2d <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b05:	8b 53 04             	mov    0x4(%ebx),%edx
  801b08:	8b 03                	mov    (%ebx),%eax
  801b0a:	83 c0 20             	add    $0x20,%eax
  801b0d:	39 c2                	cmp    %eax,%edx
  801b0f:	73 e2                	jae    801af3 <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801b11:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b14:	8a 0c 38             	mov    (%eax,%edi,1),%cl
  801b17:	89 d0                	mov    %edx,%eax
  801b19:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801b1e:	79 05                	jns    801b25 <devpipe_write+0x56>
  801b20:	48                   	dec    %eax
  801b21:	83 c8 e0             	or     $0xffffffe0,%eax
  801b24:	40                   	inc    %eax
  801b25:	88 4c 03 08          	mov    %cl,0x8(%ebx,%eax,1)
		p->p_wpos++;
  801b29:	42                   	inc    %edx
  801b2a:	89 53 04             	mov    %edx,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b2d:	47                   	inc    %edi
  801b2e:	39 7d 10             	cmp    %edi,0x10(%ebp)
  801b31:	74 0e                	je     801b41 <devpipe_write+0x72>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b33:	8b 53 04             	mov    0x4(%ebx),%edx
  801b36:	8b 03                	mov    (%ebx),%eax
  801b38:	83 c0 20             	add    $0x20,%eax
  801b3b:	39 c2                	cmp    %eax,%edx
  801b3d:	73 b4                	jae    801af3 <devpipe_write+0x24>
  801b3f:	eb d0                	jmp    801b11 <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801b41:	8b 45 10             	mov    0x10(%ebp),%eax
  801b44:	eb 05                	jmp    801b4b <devpipe_write+0x7c>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b46:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801b4b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b4e:	5b                   	pop    %ebx
  801b4f:	5e                   	pop    %esi
  801b50:	5f                   	pop    %edi
  801b51:	5d                   	pop    %ebp
  801b52:	c3                   	ret    

00801b53 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b53:	55                   	push   %ebp
  801b54:	89 e5                	mov    %esp,%ebp
  801b56:	57                   	push   %edi
  801b57:	56                   	push   %esi
  801b58:	53                   	push   %ebx
  801b59:	83 ec 18             	sub    $0x18,%esp
  801b5c:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801b5f:	57                   	push   %edi
  801b60:	e8 f2 f6 ff ff       	call   801257 <fd2data>
  801b65:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b67:	83 c4 10             	add    $0x10,%esp
  801b6a:	be 00 00 00 00       	mov    $0x0,%esi
  801b6f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801b73:	75 3d                	jne    801bb2 <devpipe_read+0x5f>
  801b75:	eb 48                	jmp    801bbf <devpipe_read+0x6c>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  801b77:	89 f0                	mov    %esi,%eax
  801b79:	eb 4e                	jmp    801bc9 <devpipe_read+0x76>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801b7b:	89 da                	mov    %ebx,%edx
  801b7d:	89 f8                	mov    %edi,%eax
  801b7f:	e8 df fe ff ff       	call   801a63 <_pipeisclosed>
  801b84:	85 c0                	test   %eax,%eax
  801b86:	75 3c                	jne    801bc4 <devpipe_read+0x71>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801b88:	e8 a0 f0 ff ff       	call   800c2d <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801b8d:	8b 03                	mov    (%ebx),%eax
  801b8f:	3b 43 04             	cmp    0x4(%ebx),%eax
  801b92:	74 e7                	je     801b7b <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b94:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801b99:	79 05                	jns    801ba0 <devpipe_read+0x4d>
  801b9b:	48                   	dec    %eax
  801b9c:	83 c8 e0             	or     $0xffffffe0,%eax
  801b9f:	40                   	inc    %eax
  801ba0:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801ba4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ba7:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801baa:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bac:	46                   	inc    %esi
  801bad:	39 75 10             	cmp    %esi,0x10(%ebp)
  801bb0:	74 0d                	je     801bbf <devpipe_read+0x6c>
		while (p->p_rpos == p->p_wpos) {
  801bb2:	8b 03                	mov    (%ebx),%eax
  801bb4:	3b 43 04             	cmp    0x4(%ebx),%eax
  801bb7:	75 db                	jne    801b94 <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801bb9:	85 f6                	test   %esi,%esi
  801bbb:	75 ba                	jne    801b77 <devpipe_read+0x24>
  801bbd:	eb bc                	jmp    801b7b <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801bbf:	8b 45 10             	mov    0x10(%ebp),%eax
  801bc2:	eb 05                	jmp    801bc9 <devpipe_read+0x76>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801bc4:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801bc9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bcc:	5b                   	pop    %ebx
  801bcd:	5e                   	pop    %esi
  801bce:	5f                   	pop    %edi
  801bcf:	5d                   	pop    %ebp
  801bd0:	c3                   	ret    

00801bd1 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801bd1:	55                   	push   %ebp
  801bd2:	89 e5                	mov    %esp,%ebp
  801bd4:	56                   	push   %esi
  801bd5:	53                   	push   %ebx
  801bd6:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801bd9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bdc:	50                   	push   %eax
  801bdd:	e8 8c f6 ff ff       	call   80126e <fd_alloc>
  801be2:	83 c4 10             	add    $0x10,%esp
  801be5:	85 c0                	test   %eax,%eax
  801be7:	0f 88 2a 01 00 00    	js     801d17 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bed:	83 ec 04             	sub    $0x4,%esp
  801bf0:	68 07 04 00 00       	push   $0x407
  801bf5:	ff 75 f4             	pushl  -0xc(%ebp)
  801bf8:	6a 00                	push   $0x0
  801bfa:	e8 4d f0 ff ff       	call   800c4c <sys_page_alloc>
  801bff:	83 c4 10             	add    $0x10,%esp
  801c02:	85 c0                	test   %eax,%eax
  801c04:	0f 88 0d 01 00 00    	js     801d17 <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801c0a:	83 ec 0c             	sub    $0xc,%esp
  801c0d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c10:	50                   	push   %eax
  801c11:	e8 58 f6 ff ff       	call   80126e <fd_alloc>
  801c16:	89 c3                	mov    %eax,%ebx
  801c18:	83 c4 10             	add    $0x10,%esp
  801c1b:	85 c0                	test   %eax,%eax
  801c1d:	0f 88 e2 00 00 00    	js     801d05 <pipe+0x134>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c23:	83 ec 04             	sub    $0x4,%esp
  801c26:	68 07 04 00 00       	push   $0x407
  801c2b:	ff 75 f0             	pushl  -0x10(%ebp)
  801c2e:	6a 00                	push   $0x0
  801c30:	e8 17 f0 ff ff       	call   800c4c <sys_page_alloc>
  801c35:	89 c3                	mov    %eax,%ebx
  801c37:	83 c4 10             	add    $0x10,%esp
  801c3a:	85 c0                	test   %eax,%eax
  801c3c:	0f 88 c3 00 00 00    	js     801d05 <pipe+0x134>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801c42:	83 ec 0c             	sub    $0xc,%esp
  801c45:	ff 75 f4             	pushl  -0xc(%ebp)
  801c48:	e8 0a f6 ff ff       	call   801257 <fd2data>
  801c4d:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c4f:	83 c4 0c             	add    $0xc,%esp
  801c52:	68 07 04 00 00       	push   $0x407
  801c57:	50                   	push   %eax
  801c58:	6a 00                	push   $0x0
  801c5a:	e8 ed ef ff ff       	call   800c4c <sys_page_alloc>
  801c5f:	89 c3                	mov    %eax,%ebx
  801c61:	83 c4 10             	add    $0x10,%esp
  801c64:	85 c0                	test   %eax,%eax
  801c66:	0f 88 89 00 00 00    	js     801cf5 <pipe+0x124>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c6c:	83 ec 0c             	sub    $0xc,%esp
  801c6f:	ff 75 f0             	pushl  -0x10(%ebp)
  801c72:	e8 e0 f5 ff ff       	call   801257 <fd2data>
  801c77:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c7e:	50                   	push   %eax
  801c7f:	6a 00                	push   $0x0
  801c81:	56                   	push   %esi
  801c82:	6a 00                	push   $0x0
  801c84:	e8 06 f0 ff ff       	call   800c8f <sys_page_map>
  801c89:	89 c3                	mov    %eax,%ebx
  801c8b:	83 c4 20             	add    $0x20,%esp
  801c8e:	85 c0                	test   %eax,%eax
  801c90:	78 55                	js     801ce7 <pipe+0x116>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801c92:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c98:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c9b:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801c9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ca0:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801ca7:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801cad:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cb0:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801cb2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cb5:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801cbc:	83 ec 0c             	sub    $0xc,%esp
  801cbf:	ff 75 f4             	pushl  -0xc(%ebp)
  801cc2:	e8 80 f5 ff ff       	call   801247 <fd2num>
  801cc7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cca:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801ccc:	83 c4 04             	add    $0x4,%esp
  801ccf:	ff 75 f0             	pushl  -0x10(%ebp)
  801cd2:	e8 70 f5 ff ff       	call   801247 <fd2num>
  801cd7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cda:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801cdd:	83 c4 10             	add    $0x10,%esp
  801ce0:	b8 00 00 00 00       	mov    $0x0,%eax
  801ce5:	eb 30                	jmp    801d17 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  801ce7:	83 ec 08             	sub    $0x8,%esp
  801cea:	56                   	push   %esi
  801ceb:	6a 00                	push   $0x0
  801ced:	e8 df ef ff ff       	call   800cd1 <sys_page_unmap>
  801cf2:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801cf5:	83 ec 08             	sub    $0x8,%esp
  801cf8:	ff 75 f0             	pushl  -0x10(%ebp)
  801cfb:	6a 00                	push   $0x0
  801cfd:	e8 cf ef ff ff       	call   800cd1 <sys_page_unmap>
  801d02:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801d05:	83 ec 08             	sub    $0x8,%esp
  801d08:	ff 75 f4             	pushl  -0xc(%ebp)
  801d0b:	6a 00                	push   $0x0
  801d0d:	e8 bf ef ff ff       	call   800cd1 <sys_page_unmap>
  801d12:	83 c4 10             	add    $0x10,%esp
  801d15:	89 d8                	mov    %ebx,%eax
    err:
	return r;
}
  801d17:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d1a:	5b                   	pop    %ebx
  801d1b:	5e                   	pop    %esi
  801d1c:	5d                   	pop    %ebp
  801d1d:	c3                   	ret    

00801d1e <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801d1e:	55                   	push   %ebp
  801d1f:	89 e5                	mov    %esp,%ebp
  801d21:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d24:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d27:	50                   	push   %eax
  801d28:	ff 75 08             	pushl  0x8(%ebp)
  801d2b:	e8 b2 f5 ff ff       	call   8012e2 <fd_lookup>
  801d30:	83 c4 10             	add    $0x10,%esp
  801d33:	85 c0                	test   %eax,%eax
  801d35:	78 18                	js     801d4f <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801d37:	83 ec 0c             	sub    $0xc,%esp
  801d3a:	ff 75 f4             	pushl  -0xc(%ebp)
  801d3d:	e8 15 f5 ff ff       	call   801257 <fd2data>
	return _pipeisclosed(fd, p);
  801d42:	89 c2                	mov    %eax,%edx
  801d44:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d47:	e8 17 fd ff ff       	call   801a63 <_pipeisclosed>
  801d4c:	83 c4 10             	add    $0x10,%esp
}
  801d4f:	c9                   	leave  
  801d50:	c3                   	ret    

00801d51 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801d51:	55                   	push   %ebp
  801d52:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801d54:	b8 00 00 00 00       	mov    $0x0,%eax
  801d59:	5d                   	pop    %ebp
  801d5a:	c3                   	ret    

00801d5b <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801d5b:	55                   	push   %ebp
  801d5c:	89 e5                	mov    %esp,%ebp
  801d5e:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801d61:	68 e0 27 80 00       	push   $0x8027e0
  801d66:	ff 75 0c             	pushl  0xc(%ebp)
  801d69:	e8 6e ea ff ff       	call   8007dc <strcpy>
	return 0;
}
  801d6e:	b8 00 00 00 00       	mov    $0x0,%eax
  801d73:	c9                   	leave  
  801d74:	c3                   	ret    

00801d75 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d75:	55                   	push   %ebp
  801d76:	89 e5                	mov    %esp,%ebp
  801d78:	57                   	push   %edi
  801d79:	56                   	push   %esi
  801d7a:	53                   	push   %ebx
  801d7b:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d81:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d85:	74 45                	je     801dcc <devcons_write+0x57>
  801d87:	b8 00 00 00 00       	mov    $0x0,%eax
  801d8c:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d91:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801d97:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801d9a:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  801d9c:	83 fb 7f             	cmp    $0x7f,%ebx
  801d9f:	76 05                	jbe    801da6 <devcons_write+0x31>
			m = sizeof(buf) - 1;
  801da1:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801da6:	83 ec 04             	sub    $0x4,%esp
  801da9:	53                   	push   %ebx
  801daa:	03 45 0c             	add    0xc(%ebp),%eax
  801dad:	50                   	push   %eax
  801dae:	57                   	push   %edi
  801daf:	e8 f5 eb ff ff       	call   8009a9 <memmove>
		sys_cputs(buf, m);
  801db4:	83 c4 08             	add    $0x8,%esp
  801db7:	53                   	push   %ebx
  801db8:	57                   	push   %edi
  801db9:	e8 d2 ed ff ff       	call   800b90 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801dbe:	01 de                	add    %ebx,%esi
  801dc0:	89 f0                	mov    %esi,%eax
  801dc2:	83 c4 10             	add    $0x10,%esp
  801dc5:	3b 75 10             	cmp    0x10(%ebp),%esi
  801dc8:	72 cd                	jb     801d97 <devcons_write+0x22>
  801dca:	eb 05                	jmp    801dd1 <devcons_write+0x5c>
  801dcc:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801dd1:	89 f0                	mov    %esi,%eax
  801dd3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801dd6:	5b                   	pop    %ebx
  801dd7:	5e                   	pop    %esi
  801dd8:	5f                   	pop    %edi
  801dd9:	5d                   	pop    %ebp
  801dda:	c3                   	ret    

00801ddb <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ddb:	55                   	push   %ebp
  801ddc:	89 e5                	mov    %esp,%ebp
  801dde:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801de1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801de5:	75 07                	jne    801dee <devcons_read+0x13>
  801de7:	eb 23                	jmp    801e0c <devcons_read+0x31>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801de9:	e8 3f ee ff ff       	call   800c2d <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801dee:	e8 bb ed ff ff       	call   800bae <sys_cgetc>
  801df3:	85 c0                	test   %eax,%eax
  801df5:	74 f2                	je     801de9 <devcons_read+0xe>
		sys_yield();
	if (c < 0)
  801df7:	85 c0                	test   %eax,%eax
  801df9:	78 1d                	js     801e18 <devcons_read+0x3d>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801dfb:	83 f8 04             	cmp    $0x4,%eax
  801dfe:	74 13                	je     801e13 <devcons_read+0x38>
		return 0;
	*(char*)vbuf = c;
  801e00:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e03:	88 02                	mov    %al,(%edx)
	return 1;
  801e05:	b8 01 00 00 00       	mov    $0x1,%eax
  801e0a:	eb 0c                	jmp    801e18 <devcons_read+0x3d>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801e0c:	b8 00 00 00 00       	mov    $0x0,%eax
  801e11:	eb 05                	jmp    801e18 <devcons_read+0x3d>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801e13:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801e18:	c9                   	leave  
  801e19:	c3                   	ret    

00801e1a <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801e1a:	55                   	push   %ebp
  801e1b:	89 e5                	mov    %esp,%ebp
  801e1d:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801e20:	8b 45 08             	mov    0x8(%ebp),%eax
  801e23:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801e26:	6a 01                	push   $0x1
  801e28:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e2b:	50                   	push   %eax
  801e2c:	e8 5f ed ff ff       	call   800b90 <sys_cputs>
}
  801e31:	83 c4 10             	add    $0x10,%esp
  801e34:	c9                   	leave  
  801e35:	c3                   	ret    

00801e36 <getchar>:

int
getchar(void)
{
  801e36:	55                   	push   %ebp
  801e37:	89 e5                	mov    %esp,%ebp
  801e39:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801e3c:	6a 01                	push   $0x1
  801e3e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e41:	50                   	push   %eax
  801e42:	6a 00                	push   $0x0
  801e44:	e8 1a f7 ff ff       	call   801563 <read>
	if (r < 0)
  801e49:	83 c4 10             	add    $0x10,%esp
  801e4c:	85 c0                	test   %eax,%eax
  801e4e:	78 0f                	js     801e5f <getchar+0x29>
		return r;
	if (r < 1)
  801e50:	85 c0                	test   %eax,%eax
  801e52:	7e 06                	jle    801e5a <getchar+0x24>
		return -E_EOF;
	return c;
  801e54:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801e58:	eb 05                	jmp    801e5f <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801e5a:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801e5f:	c9                   	leave  
  801e60:	c3                   	ret    

00801e61 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801e61:	55                   	push   %ebp
  801e62:	89 e5                	mov    %esp,%ebp
  801e64:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e67:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e6a:	50                   	push   %eax
  801e6b:	ff 75 08             	pushl  0x8(%ebp)
  801e6e:	e8 6f f4 ff ff       	call   8012e2 <fd_lookup>
  801e73:	83 c4 10             	add    $0x10,%esp
  801e76:	85 c0                	test   %eax,%eax
  801e78:	78 11                	js     801e8b <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801e7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e7d:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e83:	39 10                	cmp    %edx,(%eax)
  801e85:	0f 94 c0             	sete   %al
  801e88:	0f b6 c0             	movzbl %al,%eax
}
  801e8b:	c9                   	leave  
  801e8c:	c3                   	ret    

00801e8d <opencons>:

int
opencons(void)
{
  801e8d:	55                   	push   %ebp
  801e8e:	89 e5                	mov    %esp,%ebp
  801e90:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e93:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e96:	50                   	push   %eax
  801e97:	e8 d2 f3 ff ff       	call   80126e <fd_alloc>
  801e9c:	83 c4 10             	add    $0x10,%esp
  801e9f:	85 c0                	test   %eax,%eax
  801ea1:	78 3a                	js     801edd <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ea3:	83 ec 04             	sub    $0x4,%esp
  801ea6:	68 07 04 00 00       	push   $0x407
  801eab:	ff 75 f4             	pushl  -0xc(%ebp)
  801eae:	6a 00                	push   $0x0
  801eb0:	e8 97 ed ff ff       	call   800c4c <sys_page_alloc>
  801eb5:	83 c4 10             	add    $0x10,%esp
  801eb8:	85 c0                	test   %eax,%eax
  801eba:	78 21                	js     801edd <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801ebc:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ec2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ec5:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801ec7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801eca:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801ed1:	83 ec 0c             	sub    $0xc,%esp
  801ed4:	50                   	push   %eax
  801ed5:	e8 6d f3 ff ff       	call   801247 <fd2num>
  801eda:	83 c4 10             	add    $0x10,%esp
}
  801edd:	c9                   	leave  
  801ede:	c3                   	ret    

00801edf <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801edf:	55                   	push   %ebp
  801ee0:	89 e5                	mov    %esp,%ebp
  801ee2:	56                   	push   %esi
  801ee3:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801ee4:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801ee7:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801eed:	e8 1c ed ff ff       	call   800c0e <sys_getenvid>
  801ef2:	83 ec 0c             	sub    $0xc,%esp
  801ef5:	ff 75 0c             	pushl  0xc(%ebp)
  801ef8:	ff 75 08             	pushl  0x8(%ebp)
  801efb:	56                   	push   %esi
  801efc:	50                   	push   %eax
  801efd:	68 ec 27 80 00       	push   $0x8027ec
  801f02:	e8 f0 e2 ff ff       	call   8001f7 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801f07:	83 c4 18             	add    $0x18,%esp
  801f0a:	53                   	push   %ebx
  801f0b:	ff 75 10             	pushl  0x10(%ebp)
  801f0e:	e8 93 e2 ff ff       	call   8001a6 <vcprintf>
	cprintf("\n");
  801f13:	c7 04 24 4b 26 80 00 	movl   $0x80264b,(%esp)
  801f1a:	e8 d8 e2 ff ff       	call   8001f7 <cprintf>
  801f1f:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801f22:	cc                   	int3   
  801f23:	eb fd                	jmp    801f22 <_panic+0x43>

00801f25 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801f25:	55                   	push   %ebp
  801f26:	89 e5                	mov    %esp,%ebp
  801f28:	53                   	push   %ebx
  801f29:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (_pgfault_handler == 0) {
  801f2c:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801f33:	75 5b                	jne    801f90 <set_pgfault_handler+0x6b>
		// First time through!
		// LAB 4: Your code here.
		void *va = (void *)(UXSTACKTOP - PGSIZE);
		envid_t eid = sys_getenvid();
  801f35:	e8 d4 ec ff ff       	call   800c0e <sys_getenvid>
  801f3a:	89 c3                	mov    %eax,%ebx
		r = sys_page_alloc(eid,va,PTE_P | PTE_U | PTE_W);
  801f3c:	83 ec 04             	sub    $0x4,%esp
  801f3f:	6a 07                	push   $0x7
  801f41:	68 00 f0 bf ee       	push   $0xeebff000
  801f46:	50                   	push   %eax
  801f47:	e8 00 ed ff ff       	call   800c4c <sys_page_alloc>
		if(r<0) panic("set_pgfault_handler\n");
  801f4c:	83 c4 10             	add    $0x10,%esp
  801f4f:	85 c0                	test   %eax,%eax
  801f51:	79 14                	jns    801f67 <set_pgfault_handler+0x42>
  801f53:	83 ec 04             	sub    $0x4,%esp
  801f56:	68 10 28 80 00       	push   $0x802810
  801f5b:	6a 23                	push   $0x23
  801f5d:	68 25 28 80 00       	push   $0x802825
  801f62:	e8 78 ff ff ff       	call   801edf <_panic>
		r = sys_env_set_pgfault_upcall(eid,_pgfault_upcall);
  801f67:	83 ec 08             	sub    $0x8,%esp
  801f6a:	68 9d 1f 80 00       	push   $0x801f9d
  801f6f:	53                   	push   %ebx
  801f70:	e8 22 ee ff ff       	call   800d97 <sys_env_set_pgfault_upcall>
		if(r<0) panic("set_pgfault_handler\n");
  801f75:	83 c4 10             	add    $0x10,%esp
  801f78:	85 c0                	test   %eax,%eax
  801f7a:	79 14                	jns    801f90 <set_pgfault_handler+0x6b>
  801f7c:	83 ec 04             	sub    $0x4,%esp
  801f7f:	68 10 28 80 00       	push   $0x802810
  801f84:	6a 25                	push   $0x25
  801f86:	68 25 28 80 00       	push   $0x802825
  801f8b:	e8 4f ff ff ff       	call   801edf <_panic>
		// panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801f90:	8b 45 08             	mov    0x8(%ebp),%eax
  801f93:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801f98:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f9b:	c9                   	leave  
  801f9c:	c3                   	ret    

00801f9d <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801f9d:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801f9e:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801fa3:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801fa5:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl %esp,%ebx
  801fa8:	89 e3                	mov    %esp,%ebx
	movl 40(%esp),%eax 	// esp from utf_fault_va to utf_regs(end)
  801faa:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl 48(%esp),%esp 	// 
  801fae:	8b 64 24 30          	mov    0x30(%esp),%esp
	pushl %eax
  801fb2:	50                   	push   %eax
 
 
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	movl %ebx,%esp
  801fb3:	89 dc                	mov    %ebx,%esp
	subl $4,48(%esp)
  801fb5:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	popl %eax
  801fba:	58                   	pop    %eax
	popl %eax
  801fbb:	58                   	pop    %eax
	popal
  801fbc:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	add $4,%esp
  801fbd:	83 c4 04             	add    $0x4,%esp
	popfl
  801fc0:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  801fc1:	5c                   	pop    %esp
 
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801fc2:	c3                   	ret    

00801fc3 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801fc3:	55                   	push   %ebp
  801fc4:	89 e5                	mov    %esp,%ebp
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fc6:	8b 45 08             	mov    0x8(%ebp),%eax
  801fc9:	c1 e8 16             	shr    $0x16,%eax
  801fcc:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801fd3:	a8 01                	test   $0x1,%al
  801fd5:	74 21                	je     801ff8 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801fd7:	8b 45 08             	mov    0x8(%ebp),%eax
  801fda:	c1 e8 0c             	shr    $0xc,%eax
  801fdd:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801fe4:	a8 01                	test   $0x1,%al
  801fe6:	74 17                	je     801fff <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801fe8:	c1 e8 0c             	shr    $0xc,%eax
  801feb:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801ff2:	ef 
  801ff3:	0f b7 c0             	movzwl %ax,%eax
  801ff6:	eb 0c                	jmp    802004 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801ff8:	b8 00 00 00 00       	mov    $0x0,%eax
  801ffd:	eb 05                	jmp    802004 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801fff:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  802004:	5d                   	pop    %ebp
  802005:	c3                   	ret    
  802006:	66 90                	xchg   %ax,%ax

00802008 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  802008:	55                   	push   %ebp
  802009:	57                   	push   %edi
  80200a:	56                   	push   %esi
  80200b:	53                   	push   %ebx
  80200c:	83 ec 1c             	sub    $0x1c,%esp
  80200f:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  802013:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802017:	8b 7c 24 38          	mov    0x38(%esp),%edi
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  80201b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80201f:	89 ca                	mov    %ecx,%edx
  const DWunion dd = {.ll = d};
  802021:	89 f8                	mov    %edi,%eax
  802023:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802027:	85 f6                	test   %esi,%esi
  802029:	75 2d                	jne    802058 <__udivdi3+0x50>
    {
      if (d0 > n1)
  80202b:	39 cf                	cmp    %ecx,%edi
  80202d:	77 65                	ja     802094 <__udivdi3+0x8c>
  80202f:	89 fd                	mov    %edi,%ebp
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802031:	85 ff                	test   %edi,%edi
  802033:	75 0b                	jne    802040 <__udivdi3+0x38>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802035:	b8 01 00 00 00       	mov    $0x1,%eax
  80203a:	31 d2                	xor    %edx,%edx
  80203c:	f7 f7                	div    %edi
  80203e:	89 c5                	mov    %eax,%ebp

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802040:	31 d2                	xor    %edx,%edx
  802042:	89 c8                	mov    %ecx,%eax
  802044:	f7 f5                	div    %ebp
  802046:	89 c1                	mov    %eax,%ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802048:	89 d8                	mov    %ebx,%eax
  80204a:	f7 f5                	div    %ebp
  80204c:	89 cf                	mov    %ecx,%edi
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80204e:	89 fa                	mov    %edi,%edx
  802050:	83 c4 1c             	add    $0x1c,%esp
  802053:	5b                   	pop    %ebx
  802054:	5e                   	pop    %esi
  802055:	5f                   	pop    %edi
  802056:	5d                   	pop    %ebp
  802057:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802058:	39 ce                	cmp    %ecx,%esi
  80205a:	77 28                	ja     802084 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  80205c:	0f bd fe             	bsr    %esi,%edi
	  if (bm == 0)
  80205f:	83 f7 1f             	xor    $0x1f,%edi
  802062:	75 40                	jne    8020a4 <__udivdi3+0x9c>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802064:	39 ce                	cmp    %ecx,%esi
  802066:	72 0a                	jb     802072 <__udivdi3+0x6a>
  802068:	3b 44 24 08          	cmp    0x8(%esp),%eax
  80206c:	0f 87 9e 00 00 00    	ja     802110 <__udivdi3+0x108>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802072:	b8 01 00 00 00       	mov    $0x1,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802077:	89 fa                	mov    %edi,%edx
  802079:	83 c4 1c             	add    $0x1c,%esp
  80207c:	5b                   	pop    %ebx
  80207d:	5e                   	pop    %esi
  80207e:	5f                   	pop    %edi
  80207f:	5d                   	pop    %ebp
  802080:	c3                   	ret    
  802081:	8d 76 00             	lea    0x0(%esi),%esi
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802084:	31 ff                	xor    %edi,%edi
  802086:	31 c0                	xor    %eax,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802088:	89 fa                	mov    %edi,%edx
  80208a:	83 c4 1c             	add    $0x1c,%esp
  80208d:	5b                   	pop    %ebx
  80208e:	5e                   	pop    %esi
  80208f:	5f                   	pop    %edi
  802090:	5d                   	pop    %ebp
  802091:	c3                   	ret    
  802092:	66 90                	xchg   %ax,%ax
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802094:	89 d8                	mov    %ebx,%eax
  802096:	f7 f7                	div    %edi
  802098:	31 ff                	xor    %edi,%edi
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80209a:	89 fa                	mov    %edi,%edx
  80209c:	83 c4 1c             	add    $0x1c,%esp
  80209f:	5b                   	pop    %ebx
  8020a0:	5e                   	pop    %esi
  8020a1:	5f                   	pop    %edi
  8020a2:	5d                   	pop    %ebp
  8020a3:	c3                   	ret    
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8020a4:	bd 20 00 00 00       	mov    $0x20,%ebp
  8020a9:	89 eb                	mov    %ebp,%ebx
  8020ab:	29 fb                	sub    %edi,%ebx

	      d1 = (d1 << bm) | (d0 >> b);
  8020ad:	89 f9                	mov    %edi,%ecx
  8020af:	d3 e6                	shl    %cl,%esi
  8020b1:	89 c5                	mov    %eax,%ebp
  8020b3:	88 d9                	mov    %bl,%cl
  8020b5:	d3 ed                	shr    %cl,%ebp
  8020b7:	89 e9                	mov    %ebp,%ecx
  8020b9:	09 f1                	or     %esi,%ecx
  8020bb:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
	      d0 = d0 << bm;
  8020bf:	89 f9                	mov    %edi,%ecx
  8020c1:	d3 e0                	shl    %cl,%eax
  8020c3:	89 c5                	mov    %eax,%ebp
	      n2 = n1 >> b;
  8020c5:	89 d6                	mov    %edx,%esi
  8020c7:	88 d9                	mov    %bl,%cl
  8020c9:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
  8020cb:	89 f9                	mov    %edi,%ecx
  8020cd:	d3 e2                	shl    %cl,%edx
  8020cf:	8b 44 24 08          	mov    0x8(%esp),%eax
  8020d3:	88 d9                	mov    %bl,%cl
  8020d5:	d3 e8                	shr    %cl,%eax
  8020d7:	09 c2                	or     %eax,%edx
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8020d9:	89 d0                	mov    %edx,%eax
  8020db:	89 f2                	mov    %esi,%edx
  8020dd:	f7 74 24 0c          	divl   0xc(%esp)
  8020e1:	89 d6                	mov    %edx,%esi
  8020e3:	89 c3                	mov    %eax,%ebx
	      umul_ppmm (m1, m0, q0, d0);
  8020e5:	f7 e5                	mul    %ebp

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8020e7:	39 d6                	cmp    %edx,%esi
  8020e9:	72 19                	jb     802104 <__udivdi3+0xfc>
  8020eb:	74 0b                	je     8020f8 <__udivdi3+0xf0>
  8020ed:	89 d8                	mov    %ebx,%eax
  8020ef:	31 ff                	xor    %edi,%edi
  8020f1:	e9 58 ff ff ff       	jmp    80204e <__udivdi3+0x46>
  8020f6:	66 90                	xchg   %ax,%ax
  8020f8:	8b 54 24 08          	mov    0x8(%esp),%edx
  8020fc:	89 f9                	mov    %edi,%ecx
  8020fe:	d3 e2                	shl    %cl,%edx
  802100:	39 c2                	cmp    %eax,%edx
  802102:	73 e9                	jae    8020ed <__udivdi3+0xe5>
  802104:	8d 43 ff             	lea    -0x1(%ebx),%eax
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802107:	31 ff                	xor    %edi,%edi
  802109:	e9 40 ff ff ff       	jmp    80204e <__udivdi3+0x46>
  80210e:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802110:	31 c0                	xor    %eax,%eax
  802112:	e9 37 ff ff ff       	jmp    80204e <__udivdi3+0x46>
  802117:	90                   	nop

00802118 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  802118:	55                   	push   %ebp
  802119:	57                   	push   %edi
  80211a:	56                   	push   %esi
  80211b:	53                   	push   %ebx
  80211c:	83 ec 1c             	sub    $0x1c,%esp
  80211f:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  802123:	8b 74 24 34          	mov    0x34(%esp),%esi
  802127:	8b 7c 24 38          	mov    0x38(%esp),%edi
  80212b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80212f:	89 44 24 0c          	mov    %eax,0xc(%esp)
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  802133:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802137:	89 f3                	mov    %esi,%ebx
  const DWunion dd = {.ll = d};
  802139:	89 fa                	mov    %edi,%edx
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  80213b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  n1 = nn.s.high;
  80213f:	89 34 24             	mov    %esi,(%esp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802142:	85 c0                	test   %eax,%eax
  802144:	75 1a                	jne    802160 <__umoddi3+0x48>
    {
      if (d0 > n1)
  802146:	39 f7                	cmp    %esi,%edi
  802148:	0f 86 a2 00 00 00    	jbe    8021f0 <__umoddi3+0xd8>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80214e:	89 c8                	mov    %ecx,%eax
  802150:	89 f2                	mov    %esi,%edx
  802152:	f7 f7                	div    %edi
  802154:	89 d0                	mov    %edx,%eax

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  802156:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802158:	83 c4 1c             	add    $0x1c,%esp
  80215b:	5b                   	pop    %ebx
  80215c:	5e                   	pop    %esi
  80215d:	5f                   	pop    %edi
  80215e:	5d                   	pop    %ebp
  80215f:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802160:	39 f0                	cmp    %esi,%eax
  802162:	0f 87 ac 00 00 00    	ja     802214 <__umoddi3+0xfc>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802168:	0f bd e8             	bsr    %eax,%ebp
	  if (bm == 0)
  80216b:	83 f5 1f             	xor    $0x1f,%ebp
  80216e:	0f 84 ac 00 00 00    	je     802220 <__umoddi3+0x108>
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802174:	bf 20 00 00 00       	mov    $0x20,%edi
  802179:	29 ef                	sub    %ebp,%edi
  80217b:	89 fe                	mov    %edi,%esi
  80217d:	89 7c 24 0c          	mov    %edi,0xc(%esp)

	      d1 = (d1 << bm) | (d0 >> b);
  802181:	89 e9                	mov    %ebp,%ecx
  802183:	d3 e0                	shl    %cl,%eax
  802185:	89 d7                	mov    %edx,%edi
  802187:	89 f1                	mov    %esi,%ecx
  802189:	d3 ef                	shr    %cl,%edi
  80218b:	09 c7                	or     %eax,%edi
	      d0 = d0 << bm;
  80218d:	89 e9                	mov    %ebp,%ecx
  80218f:	d3 e2                	shl    %cl,%edx
  802191:	89 14 24             	mov    %edx,(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802194:	89 d8                	mov    %ebx,%eax
  802196:	d3 e0                	shl    %cl,%eax
  802198:	89 c2                	mov    %eax,%edx
	      n0 = n0 << bm;
  80219a:	8b 44 24 08          	mov    0x8(%esp),%eax
  80219e:	d3 e0                	shl    %cl,%eax
  8021a0:	89 44 24 04          	mov    %eax,0x4(%esp)

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8021a4:	8b 44 24 08          	mov    0x8(%esp),%eax
  8021a8:	89 f1                	mov    %esi,%ecx
  8021aa:	d3 e8                	shr    %cl,%eax
  8021ac:	09 d0                	or     %edx,%eax
  8021ae:	d3 eb                	shr    %cl,%ebx
  8021b0:	89 da                	mov    %ebx,%edx
  8021b2:	f7 f7                	div    %edi
  8021b4:	89 d3                	mov    %edx,%ebx
	      umul_ppmm (m1, m0, q0, d0);
  8021b6:	f7 24 24             	mull   (%esp)
  8021b9:	89 c6                	mov    %eax,%esi
  8021bb:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8021bd:	39 d3                	cmp    %edx,%ebx
  8021bf:	0f 82 87 00 00 00    	jb     80224c <__umoddi3+0x134>
  8021c5:	0f 84 91 00 00 00    	je     80225c <__umoddi3+0x144>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  8021cb:	8b 54 24 04          	mov    0x4(%esp),%edx
  8021cf:	29 f2                	sub    %esi,%edx
  8021d1:	19 cb                	sbb    %ecx,%ebx
		  rr.s.low = (n1 << b) | (n0 >> bm);
  8021d3:	89 d8                	mov    %ebx,%eax
  8021d5:	8a 4c 24 0c          	mov    0xc(%esp),%cl
  8021d9:	d3 e0                	shl    %cl,%eax
  8021db:	89 e9                	mov    %ebp,%ecx
  8021dd:	d3 ea                	shr    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  8021df:	09 d0                	or     %edx,%eax
  8021e1:	89 e9                	mov    %ebp,%ecx
  8021e3:	d3 eb                	shr    %cl,%ebx
  8021e5:	89 da                	mov    %ebx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8021e7:	83 c4 1c             	add    $0x1c,%esp
  8021ea:	5b                   	pop    %ebx
  8021eb:	5e                   	pop    %esi
  8021ec:	5f                   	pop    %edi
  8021ed:	5d                   	pop    %ebp
  8021ee:	c3                   	ret    
  8021ef:	90                   	nop
  8021f0:	89 fd                	mov    %edi,%ebp
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8021f2:	85 ff                	test   %edi,%edi
  8021f4:	75 0b                	jne    802201 <__umoddi3+0xe9>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8021f6:	b8 01 00 00 00       	mov    $0x1,%eax
  8021fb:	31 d2                	xor    %edx,%edx
  8021fd:	f7 f7                	div    %edi
  8021ff:	89 c5                	mov    %eax,%ebp

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802201:	89 f0                	mov    %esi,%eax
  802203:	31 d2                	xor    %edx,%edx
  802205:	f7 f5                	div    %ebp
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802207:	89 c8                	mov    %ecx,%eax
  802209:	f7 f5                	div    %ebp
  80220b:	89 d0                	mov    %edx,%eax
  80220d:	e9 44 ff ff ff       	jmp    802156 <__umoddi3+0x3e>
  802212:	66 90                	xchg   %ax,%ax
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  802214:	89 c8                	mov    %ecx,%eax
  802216:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802218:	83 c4 1c             	add    $0x1c,%esp
  80221b:	5b                   	pop    %ebx
  80221c:	5e                   	pop    %esi
  80221d:	5f                   	pop    %edi
  80221e:	5d                   	pop    %ebp
  80221f:	c3                   	ret    

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802220:	3b 04 24             	cmp    (%esp),%eax
  802223:	72 06                	jb     80222b <__umoddi3+0x113>
  802225:	3b 7c 24 04          	cmp    0x4(%esp),%edi
  802229:	77 0f                	ja     80223a <__umoddi3+0x122>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  80222b:	89 f2                	mov    %esi,%edx
  80222d:	29 f9                	sub    %edi,%ecx
  80222f:	1b 54 24 0c          	sbb    0xc(%esp),%edx
  802233:	89 14 24             	mov    %edx,(%esp)
  802236:	89 4c 24 04          	mov    %ecx,0x4(%esp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  80223a:	8b 44 24 04          	mov    0x4(%esp),%eax
  80223e:	8b 14 24             	mov    (%esp),%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802241:	83 c4 1c             	add    $0x1c,%esp
  802244:	5b                   	pop    %ebx
  802245:	5e                   	pop    %esi
  802246:	5f                   	pop    %edi
  802247:	5d                   	pop    %ebp
  802248:	c3                   	ret    
  802249:	8d 76 00             	lea    0x0(%esi),%esi
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  80224c:	2b 04 24             	sub    (%esp),%eax
  80224f:	19 fa                	sbb    %edi,%edx
  802251:	89 d1                	mov    %edx,%ecx
  802253:	89 c6                	mov    %eax,%esi
  802255:	e9 71 ff ff ff       	jmp    8021cb <__umoddi3+0xb3>
  80225a:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80225c:	39 44 24 04          	cmp    %eax,0x4(%esp)
  802260:	72 ea                	jb     80224c <__umoddi3+0x134>
  802262:	89 d9                	mov    %ebx,%ecx
  802264:	e9 62 ff ff ff       	jmp    8021cb <__umoddi3+0xb3>
