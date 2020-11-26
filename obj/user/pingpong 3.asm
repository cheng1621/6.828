
obj/user/pingpong.debug:     file format elf32-i386


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
  80002c:	e8 8b 00 00 00       	call   8000bc <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 1c             	sub    $0x1c,%esp
	envid_t who;

	if ((who = fork()) != 0) {
  80003c:	e8 ab 0e 00 00       	call   800eec <fork>
  800041:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800044:	85 c0                	test   %eax,%eax
  800046:	74 27                	je     80006f <umain+0x3c>
  800048:	89 c3                	mov    %eax,%ebx
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  80004a:	e8 7f 0b 00 00       	call   800bce <sys_getenvid>
  80004f:	83 ec 04             	sub    $0x4,%esp
  800052:	53                   	push   %ebx
  800053:	50                   	push   %eax
  800054:	68 40 22 80 00       	push   $0x802240
  800059:	e8 59 01 00 00       	call   8001b7 <cprintf>
		ipc_send(who, 0, 0, 0);
  80005e:	6a 00                	push   $0x0
  800060:	6a 00                	push   $0x0
  800062:	6a 00                	push   $0x0
  800064:	ff 75 e4             	pushl  -0x1c(%ebp)
  800067:	e8 e1 10 00 00       	call   80114d <ipc_send>
  80006c:	83 c4 20             	add    $0x20,%esp
	}

	while (1) {
		uint32_t i = ipc_recv(&who, 0, 0);
  80006f:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  800072:	83 ec 04             	sub    $0x4,%esp
  800075:	6a 00                	push   $0x0
  800077:	6a 00                	push   $0x0
  800079:	56                   	push   %esi
  80007a:	e8 59 10 00 00       	call   8010d8 <ipc_recv>
  80007f:	89 c3                	mov    %eax,%ebx
		cprintf("%x got %d from %x\n", sys_getenvid(), i, who);
  800081:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800084:	e8 45 0b 00 00       	call   800bce <sys_getenvid>
  800089:	57                   	push   %edi
  80008a:	53                   	push   %ebx
  80008b:	50                   	push   %eax
  80008c:	68 56 22 80 00       	push   $0x802256
  800091:	e8 21 01 00 00       	call   8001b7 <cprintf>
		if (i == 10)
  800096:	83 c4 20             	add    $0x20,%esp
  800099:	83 fb 0a             	cmp    $0xa,%ebx
  80009c:	74 16                	je     8000b4 <umain+0x81>
			return;
		i++;
  80009e:	43                   	inc    %ebx
		ipc_send(who, i, 0, 0);
  80009f:	6a 00                	push   $0x0
  8000a1:	6a 00                	push   $0x0
  8000a3:	53                   	push   %ebx
  8000a4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8000a7:	e8 a1 10 00 00       	call   80114d <ipc_send>
		if (i == 10)
  8000ac:	83 c4 10             	add    $0x10,%esp
  8000af:	83 fb 0a             	cmp    $0xa,%ebx
  8000b2:	75 be                	jne    800072 <umain+0x3f>
			return;
	}

}
  8000b4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000b7:	5b                   	pop    %ebx
  8000b8:	5e                   	pop    %esi
  8000b9:	5f                   	pop    %edi
  8000ba:	5d                   	pop    %ebp
  8000bb:	c3                   	ret    

008000bc <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000bc:	55                   	push   %ebp
  8000bd:	89 e5                	mov    %esp,%ebp
  8000bf:	56                   	push   %esi
  8000c0:	53                   	push   %ebx
  8000c1:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000c4:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8000c7:	e8 02 0b 00 00       	call   800bce <sys_getenvid>
  8000cc:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000d1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8000d8:	c1 e0 07             	shl    $0x7,%eax
  8000db:	29 d0                	sub    %edx,%eax
  8000dd:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000e2:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000e7:	85 db                	test   %ebx,%ebx
  8000e9:	7e 07                	jle    8000f2 <libmain+0x36>
		binaryname = argv[0];
  8000eb:	8b 06                	mov    (%esi),%eax
  8000ed:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000f2:	83 ec 08             	sub    $0x8,%esp
  8000f5:	56                   	push   %esi
  8000f6:	53                   	push   %ebx
  8000f7:	e8 37 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000fc:	e8 0a 00 00 00       	call   80010b <exit>
}
  800101:	83 c4 10             	add    $0x10,%esp
  800104:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800107:	5b                   	pop    %ebx
  800108:	5e                   	pop    %esi
  800109:	5d                   	pop    %ebp
  80010a:	c3                   	ret    

0080010b <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80010b:	55                   	push   %ebp
  80010c:	89 e5                	mov    %esp,%ebp
  80010e:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800111:	e8 00 13 00 00       	call   801416 <close_all>
	sys_env_destroy(0);
  800116:	83 ec 0c             	sub    $0xc,%esp
  800119:	6a 00                	push   $0x0
  80011b:	e8 6d 0a 00 00       	call   800b8d <sys_env_destroy>
}
  800120:	83 c4 10             	add    $0x10,%esp
  800123:	c9                   	leave  
  800124:	c3                   	ret    

00800125 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800125:	55                   	push   %ebp
  800126:	89 e5                	mov    %esp,%ebp
  800128:	53                   	push   %ebx
  800129:	83 ec 04             	sub    $0x4,%esp
  80012c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80012f:	8b 13                	mov    (%ebx),%edx
  800131:	8d 42 01             	lea    0x1(%edx),%eax
  800134:	89 03                	mov    %eax,(%ebx)
  800136:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800139:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80013d:	3d ff 00 00 00       	cmp    $0xff,%eax
  800142:	75 1a                	jne    80015e <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800144:	83 ec 08             	sub    $0x8,%esp
  800147:	68 ff 00 00 00       	push   $0xff
  80014c:	8d 43 08             	lea    0x8(%ebx),%eax
  80014f:	50                   	push   %eax
  800150:	e8 fb 09 00 00       	call   800b50 <sys_cputs>
		b->idx = 0;
  800155:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80015b:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80015e:	ff 43 04             	incl   0x4(%ebx)
}
  800161:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800164:	c9                   	leave  
  800165:	c3                   	ret    

00800166 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800166:	55                   	push   %ebp
  800167:	89 e5                	mov    %esp,%ebp
  800169:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80016f:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800176:	00 00 00 
	b.cnt = 0;
  800179:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800180:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800183:	ff 75 0c             	pushl  0xc(%ebp)
  800186:	ff 75 08             	pushl  0x8(%ebp)
  800189:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80018f:	50                   	push   %eax
  800190:	68 25 01 80 00       	push   $0x800125
  800195:	e8 54 01 00 00       	call   8002ee <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80019a:	83 c4 08             	add    $0x8,%esp
  80019d:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001a3:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001a9:	50                   	push   %eax
  8001aa:	e8 a1 09 00 00       	call   800b50 <sys_cputs>

	return b.cnt;
}
  8001af:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001b5:	c9                   	leave  
  8001b6:	c3                   	ret    

008001b7 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001b7:	55                   	push   %ebp
  8001b8:	89 e5                	mov    %esp,%ebp
  8001ba:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001bd:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001c0:	50                   	push   %eax
  8001c1:	ff 75 08             	pushl  0x8(%ebp)
  8001c4:	e8 9d ff ff ff       	call   800166 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001c9:	c9                   	leave  
  8001ca:	c3                   	ret    

008001cb <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001cb:	55                   	push   %ebp
  8001cc:	89 e5                	mov    %esp,%ebp
  8001ce:	57                   	push   %edi
  8001cf:	56                   	push   %esi
  8001d0:	53                   	push   %ebx
  8001d1:	83 ec 1c             	sub    $0x1c,%esp
  8001d4:	89 c6                	mov    %eax,%esi
  8001d6:	89 d7                	mov    %edx,%edi
  8001d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8001db:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001de:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001e1:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001e4:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001e7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001ec:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001ef:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001f2:	39 d3                	cmp    %edx,%ebx
  8001f4:	72 11                	jb     800207 <printnum+0x3c>
  8001f6:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001f9:	76 0c                	jbe    800207 <printnum+0x3c>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8001fe:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800201:	85 db                	test   %ebx,%ebx
  800203:	7f 37                	jg     80023c <printnum+0x71>
  800205:	eb 44                	jmp    80024b <printnum+0x80>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800207:	83 ec 0c             	sub    $0xc,%esp
  80020a:	ff 75 18             	pushl  0x18(%ebp)
  80020d:	8b 45 14             	mov    0x14(%ebp),%eax
  800210:	48                   	dec    %eax
  800211:	50                   	push   %eax
  800212:	ff 75 10             	pushl  0x10(%ebp)
  800215:	83 ec 08             	sub    $0x8,%esp
  800218:	ff 75 e4             	pushl  -0x1c(%ebp)
  80021b:	ff 75 e0             	pushl  -0x20(%ebp)
  80021e:	ff 75 dc             	pushl  -0x24(%ebp)
  800221:	ff 75 d8             	pushl  -0x28(%ebp)
  800224:	e8 9f 1d 00 00       	call   801fc8 <__udivdi3>
  800229:	83 c4 18             	add    $0x18,%esp
  80022c:	52                   	push   %edx
  80022d:	50                   	push   %eax
  80022e:	89 fa                	mov    %edi,%edx
  800230:	89 f0                	mov    %esi,%eax
  800232:	e8 94 ff ff ff       	call   8001cb <printnum>
  800237:	83 c4 20             	add    $0x20,%esp
  80023a:	eb 0f                	jmp    80024b <printnum+0x80>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80023c:	83 ec 08             	sub    $0x8,%esp
  80023f:	57                   	push   %edi
  800240:	ff 75 18             	pushl  0x18(%ebp)
  800243:	ff d6                	call   *%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800245:	83 c4 10             	add    $0x10,%esp
  800248:	4b                   	dec    %ebx
  800249:	75 f1                	jne    80023c <printnum+0x71>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80024b:	83 ec 08             	sub    $0x8,%esp
  80024e:	57                   	push   %edi
  80024f:	83 ec 04             	sub    $0x4,%esp
  800252:	ff 75 e4             	pushl  -0x1c(%ebp)
  800255:	ff 75 e0             	pushl  -0x20(%ebp)
  800258:	ff 75 dc             	pushl  -0x24(%ebp)
  80025b:	ff 75 d8             	pushl  -0x28(%ebp)
  80025e:	e8 75 1e 00 00       	call   8020d8 <__umoddi3>
  800263:	83 c4 14             	add    $0x14,%esp
  800266:	0f be 80 73 22 80 00 	movsbl 0x802273(%eax),%eax
  80026d:	50                   	push   %eax
  80026e:	ff d6                	call   *%esi
}
  800270:	83 c4 10             	add    $0x10,%esp
  800273:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800276:	5b                   	pop    %ebx
  800277:	5e                   	pop    %esi
  800278:	5f                   	pop    %edi
  800279:	5d                   	pop    %ebp
  80027a:	c3                   	ret    

0080027b <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80027b:	55                   	push   %ebp
  80027c:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80027e:	83 fa 01             	cmp    $0x1,%edx
  800281:	7e 0e                	jle    800291 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800283:	8b 10                	mov    (%eax),%edx
  800285:	8d 4a 08             	lea    0x8(%edx),%ecx
  800288:	89 08                	mov    %ecx,(%eax)
  80028a:	8b 02                	mov    (%edx),%eax
  80028c:	8b 52 04             	mov    0x4(%edx),%edx
  80028f:	eb 22                	jmp    8002b3 <getuint+0x38>
	else if (lflag)
  800291:	85 d2                	test   %edx,%edx
  800293:	74 10                	je     8002a5 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800295:	8b 10                	mov    (%eax),%edx
  800297:	8d 4a 04             	lea    0x4(%edx),%ecx
  80029a:	89 08                	mov    %ecx,(%eax)
  80029c:	8b 02                	mov    (%edx),%eax
  80029e:	ba 00 00 00 00       	mov    $0x0,%edx
  8002a3:	eb 0e                	jmp    8002b3 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002a5:	8b 10                	mov    (%eax),%edx
  8002a7:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002aa:	89 08                	mov    %ecx,(%eax)
  8002ac:	8b 02                	mov    (%edx),%eax
  8002ae:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002b3:	5d                   	pop    %ebp
  8002b4:	c3                   	ret    

008002b5 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002b5:	55                   	push   %ebp
  8002b6:	89 e5                	mov    %esp,%ebp
  8002b8:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002bb:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8002be:	8b 10                	mov    (%eax),%edx
  8002c0:	3b 50 04             	cmp    0x4(%eax),%edx
  8002c3:	73 0a                	jae    8002cf <sprintputch+0x1a>
		*b->buf++ = ch;
  8002c5:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002c8:	89 08                	mov    %ecx,(%eax)
  8002ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8002cd:	88 02                	mov    %al,(%edx)
}
  8002cf:	5d                   	pop    %ebp
  8002d0:	c3                   	ret    

008002d1 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002d1:	55                   	push   %ebp
  8002d2:	89 e5                	mov    %esp,%ebp
  8002d4:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002d7:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002da:	50                   	push   %eax
  8002db:	ff 75 10             	pushl  0x10(%ebp)
  8002de:	ff 75 0c             	pushl  0xc(%ebp)
  8002e1:	ff 75 08             	pushl  0x8(%ebp)
  8002e4:	e8 05 00 00 00       	call   8002ee <vprintfmt>
	va_end(ap);
}
  8002e9:	83 c4 10             	add    $0x10,%esp
  8002ec:	c9                   	leave  
  8002ed:	c3                   	ret    

008002ee <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002ee:	55                   	push   %ebp
  8002ef:	89 e5                	mov    %esp,%ebp
  8002f1:	57                   	push   %edi
  8002f2:	56                   	push   %esi
  8002f3:	53                   	push   %ebx
  8002f4:	83 ec 2c             	sub    $0x2c,%esp
  8002f7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8002fa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002fd:	eb 03                	jmp    800302 <vprintfmt+0x14>
			break;

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
			for (fmt--; fmt[-1] != '%'; fmt--)
  8002ff:	89 75 10             	mov    %esi,0x10(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {    //遍历输入的第一个参数，即输出信息的格式，先把格式字符串中'%'之前的字符一个个输出，因为它们前面没有'%'，所以它们就是要直接显示在屏幕上的
  800302:	8b 45 10             	mov    0x10(%ebp),%eax
  800305:	8d 70 01             	lea    0x1(%eax),%esi
  800308:	0f b6 00             	movzbl (%eax),%eax
  80030b:	83 f8 25             	cmp    $0x25,%eax
  80030e:	74 25                	je     800335 <vprintfmt+0x47>
			if (ch == '\0')									//当然中间如果遇到'\0'，代表这个字符串的访问结束
  800310:	85 c0                	test   %eax,%eax
  800312:	75 0d                	jne    800321 <vprintfmt+0x33>
  800314:	e9 b5 03 00 00       	jmp    8006ce <vprintfmt+0x3e0>
  800319:	85 c0                	test   %eax,%eax
  80031b:	0f 84 ad 03 00 00    	je     8006ce <vprintfmt+0x3e0>
				return;
			putch(ch, putdat);								//调用putch函数，把一个字符ch输出到putdat指针所指向的地址中所存放的值对应的地址处
  800321:	83 ec 08             	sub    $0x8,%esp
  800324:	53                   	push   %ebx
  800325:	50                   	push   %eax
  800326:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {    //遍历输入的第一个参数，即输出信息的格式，先把格式字符串中'%'之前的字符一个个输出，因为它们前面没有'%'，所以它们就是要直接显示在屏幕上的
  800328:	46                   	inc    %esi
  800329:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  80032d:	83 c4 10             	add    $0x10,%esp
  800330:	83 f8 25             	cmp    $0x25,%eax
  800333:	75 e4                	jne    800319 <vprintfmt+0x2b>
			if (width < 0)									//代表有小数点，但是小数点前面并没有数字，比如'%.6f'这种情况，此时代表整数部分全部显示
				width = 0;			
			goto reswitch;

		case '#':
			altflag = 1;
  800335:	c6 45 e3 20          	movb   $0x20,-0x1d(%ebp)
  800339:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800340:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800347:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80034e:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800355:	eb 07                	jmp    80035e <vprintfmt+0x70>
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  800357:	8b 75 10             	mov    0x10(%ebp),%esi

		// flag to pad on the right
		case '-':											//%后面的'-'代表要进行左对齐输出，右边填空格，如果省略代表右对齐
			padc = '-';										//如果有这个字符代表左对齐，则把对齐方式标志位变为'-'
  80035a:	c6 45 e3 2d          	movb   $0x2d,-0x1d(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  80035e:	8d 46 01             	lea    0x1(%esi),%eax
  800361:	89 45 10             	mov    %eax,0x10(%ebp)
  800364:	0f b6 16             	movzbl (%esi),%edx
  800367:	8a 06                	mov    (%esi),%al
  800369:	83 e8 23             	sub    $0x23,%eax
  80036c:	3c 55                	cmp    $0x55,%al
  80036e:	0f 87 03 03 00 00    	ja     800677 <vprintfmt+0x389>
  800374:	0f b6 c0             	movzbl %al,%eax
  800377:	ff 24 85 c0 23 80 00 	jmp    *0x8023c0(,%eax,4)
  80037e:	8b 75 10             	mov    0x10(%ebp),%esi
			padc = '-';										//如果有这个字符代表左对齐，则把对齐方式标志位变为'-'
			goto reswitch;									//处理下一个字符

		// flag to pad with 0's instead of spaces
		case '0':											//0--有0表示进行对齐输出时填0,如省略表示填入空格，并且如果为0，则一定是右对齐
			padc = '0';										//对其方式标志位变为0
  800381:	c6 45 e3 30          	movb   $0x30,-0x1d(%ebp)
  800385:	eb d7                	jmp    80035e <vprintfmt+0x70>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {					//把遇到的位数字符串转换为真实的位数，比如输入的'%40'，代表有效位数为40位，下面的循环就是把precesion的值设置为40
				precision = precision * 10 + ch - '0';
  800387:	8d 42 d0             	lea    -0x30(%edx),%eax
  80038a:	89 c1                	mov    %eax,%ecx
  80038c:	89 45 d0             	mov    %eax,-0x30(%ebp)
				ch = *fmt;
  80038f:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  800393:	8d 50 d0             	lea    -0x30(%eax),%edx
  800396:	83 fa 09             	cmp    $0x9,%edx
  800399:	77 51                	ja     8003ec <vprintfmt+0xfe>
  80039b:	8b 75 10             	mov    0x10(%ebp),%esi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {					//把遇到的位数字符串转换为真实的位数，比如输入的'%40'，代表有效位数为40位，下面的循环就是把precesion的值设置为40
  80039e:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  80039f:	8d 14 89             	lea    (%ecx,%ecx,4),%edx
  8003a2:	01 d2                	add    %edx,%edx
  8003a4:	8d 4c 10 d0          	lea    -0x30(%eax,%edx,1),%ecx
				ch = *fmt;
  8003a8:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8003ab:	8d 50 d0             	lea    -0x30(%eax),%edx
  8003ae:	83 fa 09             	cmp    $0x9,%edx
  8003b1:	76 eb                	jbe    80039e <vprintfmt+0xb0>
  8003b3:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8003b6:	eb 37                	jmp    8003ef <vprintfmt+0x101>
					break;
			}
			goto process_precision;							//跳转到process_precistion子过程

		case '*':											//*--代表有效数字的位数也是由输入参数指定的，比如printf("%*.*f", 10, 2, n)，其中10,2就是用来指定显示的有效数字位数的
			precision = va_arg(ap, int);
  8003b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8003bb:	8d 50 04             	lea    0x4(%eax),%edx
  8003be:	89 55 14             	mov    %edx,0x14(%ebp)
  8003c1:	8b 00                	mov    (%eax),%eax
  8003c3:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  8003c6:	8b 75 10             	mov    0x10(%ebp),%esi
			}
			goto process_precision;							//跳转到process_precistion子过程

		case '*':											//*--代表有效数字的位数也是由输入参数指定的，比如printf("%*.*f", 10, 2, n)，其中10,2就是用来指定显示的有效数字位数的
			precision = va_arg(ap, int);
			goto process_precision;
  8003c9:	eb 24                	jmp    8003ef <vprintfmt+0x101>
  8003cb:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003cf:	79 07                	jns    8003d8 <vprintfmt+0xea>
  8003d1:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  8003d8:	8b 75 10             	mov    0x10(%ebp),%esi
  8003db:	eb 81                	jmp    80035e <vprintfmt+0x70>
  8003dd:	8b 75 10             	mov    0x10(%ebp),%esi
			if (width < 0)									//代表有小数点，但是小数点前面并没有数字，比如'%.6f'这种情况，此时代表整数部分全部显示
				width = 0;			
			goto reswitch;

		case '#':
			altflag = 1;
  8003e0:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003e7:	e9 72 ff ff ff       	jmp    80035e <vprintfmt+0x70>
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  8003ec:	8b 75 10             	mov    0x10(%ebp),%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:									//处理输出精度，把width字段赋值为刚刚计算出来的precision值，所以width应该是整数部分的有效数字位数
			if (width < 0)
  8003ef:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003f3:	0f 89 65 ff ff ff    	jns    80035e <vprintfmt+0x70>
				width = precision, precision = -1;
  8003f9:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003fc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003ff:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800406:	e9 53 ff ff ff       	jmp    80035e <vprintfmt+0x70>
			goto reswitch;

		// long flag (doubled for long long)				
		case 'l':											//如果遇到'l'，代表应该是输入long类型，如果有两个'l'代表long long
			lflag++;										//此时把lflag++
  80040b:	ff 45 d4             	incl   -0x2c(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  80040e:	8b 75 10             	mov    0x10(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)				
		case 'l':											//如果遇到'l'，代表应该是输入long类型，如果有两个'l'代表long long
			lflag++;										//此时把lflag++
			goto reswitch;
  800411:	e9 48 ff ff ff       	jmp    80035e <vprintfmt+0x70>

		// character
		case 'c':											//如果是'c'代表显示一个字符
			putch(va_arg(ap, int), putdat);					//调用输出一个字符到内存的函数putch
  800416:	8b 45 14             	mov    0x14(%ebp),%eax
  800419:	8d 50 04             	lea    0x4(%eax),%edx
  80041c:	89 55 14             	mov    %edx,0x14(%ebp)
  80041f:	83 ec 08             	sub    $0x8,%esp
  800422:	53                   	push   %ebx
  800423:	ff 30                	pushl  (%eax)
  800425:	ff d7                	call   *%edi
			break;
  800427:	83 c4 10             	add    $0x10,%esp
  80042a:	e9 d3 fe ff ff       	jmp    800302 <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80042f:	8b 45 14             	mov    0x14(%ebp),%eax
  800432:	8d 50 04             	lea    0x4(%eax),%edx
  800435:	89 55 14             	mov    %edx,0x14(%ebp)
  800438:	8b 00                	mov    (%eax),%eax
  80043a:	85 c0                	test   %eax,%eax
  80043c:	79 02                	jns    800440 <vprintfmt+0x152>
  80043e:	f7 d8                	neg    %eax
  800440:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800442:	83 f8 0f             	cmp    $0xf,%eax
  800445:	7f 0b                	jg     800452 <vprintfmt+0x164>
  800447:	8b 04 85 20 25 80 00 	mov    0x802520(,%eax,4),%eax
  80044e:	85 c0                	test   %eax,%eax
  800450:	75 15                	jne    800467 <vprintfmt+0x179>
				printfmt(putch, putdat, "error %d", err);
  800452:	52                   	push   %edx
  800453:	68 8b 22 80 00       	push   $0x80228b
  800458:	53                   	push   %ebx
  800459:	57                   	push   %edi
  80045a:	e8 72 fe ff ff       	call   8002d1 <printfmt>
  80045f:	83 c4 10             	add    $0x10,%esp
  800462:	e9 9b fe ff ff       	jmp    800302 <vprintfmt+0x14>
			else
				printfmt(putch, putdat, "%s", p);
  800467:	50                   	push   %eax
  800468:	68 47 27 80 00       	push   $0x802747
  80046d:	53                   	push   %ebx
  80046e:	57                   	push   %edi
  80046f:	e8 5d fe ff ff       	call   8002d1 <printfmt>
  800474:	83 c4 10             	add    $0x10,%esp
  800477:	e9 86 fe ff ff       	jmp    800302 <vprintfmt+0x14>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80047c:	8b 45 14             	mov    0x14(%ebp),%eax
  80047f:	8d 50 04             	lea    0x4(%eax),%edx
  800482:	89 55 14             	mov    %edx,0x14(%ebp)
  800485:	8b 00                	mov    (%eax),%eax
  800487:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80048a:	85 c0                	test   %eax,%eax
  80048c:	75 07                	jne    800495 <vprintfmt+0x1a7>
				p = "(null)";
  80048e:	c7 45 d4 84 22 80 00 	movl   $0x802284,-0x2c(%ebp)
			if (width > 0 && padc != '-')
  800495:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800498:	85 f6                	test   %esi,%esi
  80049a:	0f 8e fb 01 00 00    	jle    80069b <vprintfmt+0x3ad>
  8004a0:	80 7d e3 2d          	cmpb   $0x2d,-0x1d(%ebp)
  8004a4:	0f 84 09 02 00 00    	je     8006b3 <vprintfmt+0x3c5>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004aa:	83 ec 08             	sub    $0x8,%esp
  8004ad:	ff 75 d0             	pushl  -0x30(%ebp)
  8004b0:	ff 75 d4             	pushl  -0x2c(%ebp)
  8004b3:	e8 ad 02 00 00       	call   800765 <strnlen>
  8004b8:	89 f1                	mov    %esi,%ecx
  8004ba:	29 c1                	sub    %eax,%ecx
  8004bc:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  8004bf:	83 c4 10             	add    $0x10,%esp
  8004c2:	85 c9                	test   %ecx,%ecx
  8004c4:	0f 8e d1 01 00 00    	jle    80069b <vprintfmt+0x3ad>
					putch(padc, putdat);
  8004ca:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  8004ce:	83 ec 08             	sub    $0x8,%esp
  8004d1:	53                   	push   %ebx
  8004d2:	56                   	push   %esi
  8004d3:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004d5:	83 c4 10             	add    $0x10,%esp
  8004d8:	ff 4d e4             	decl   -0x1c(%ebp)
  8004db:	75 f1                	jne    8004ce <vprintfmt+0x1e0>
  8004dd:	e9 b9 01 00 00       	jmp    80069b <vprintfmt+0x3ad>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004e2:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004e6:	74 19                	je     800501 <vprintfmt+0x213>
  8004e8:	0f be c0             	movsbl %al,%eax
  8004eb:	83 e8 20             	sub    $0x20,%eax
  8004ee:	83 f8 5e             	cmp    $0x5e,%eax
  8004f1:	76 0e                	jbe    800501 <vprintfmt+0x213>
					putch('?', putdat);
  8004f3:	83 ec 08             	sub    $0x8,%esp
  8004f6:	53                   	push   %ebx
  8004f7:	6a 3f                	push   $0x3f
  8004f9:	ff 55 08             	call   *0x8(%ebp)
  8004fc:	83 c4 10             	add    $0x10,%esp
  8004ff:	eb 0b                	jmp    80050c <vprintfmt+0x21e>
				else
					putch(ch, putdat);
  800501:	83 ec 08             	sub    $0x8,%esp
  800504:	53                   	push   %ebx
  800505:	52                   	push   %edx
  800506:	ff 55 08             	call   *0x8(%ebp)
  800509:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80050c:	ff 4d e4             	decl   -0x1c(%ebp)
  80050f:	46                   	inc    %esi
  800510:	8a 46 ff             	mov    -0x1(%esi),%al
  800513:	0f be d0             	movsbl %al,%edx
  800516:	85 d2                	test   %edx,%edx
  800518:	75 1c                	jne    800536 <vprintfmt+0x248>
  80051a:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80051d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800521:	7f 1f                	jg     800542 <vprintfmt+0x254>
  800523:	e9 da fd ff ff       	jmp    800302 <vprintfmt+0x14>
  800528:	89 7d 08             	mov    %edi,0x8(%ebp)
  80052b:	8b 7d d0             	mov    -0x30(%ebp),%edi
  80052e:	eb 06                	jmp    800536 <vprintfmt+0x248>
  800530:	89 7d 08             	mov    %edi,0x8(%ebp)
  800533:	8b 7d d0             	mov    -0x30(%ebp),%edi
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800536:	85 ff                	test   %edi,%edi
  800538:	78 a8                	js     8004e2 <vprintfmt+0x1f4>
  80053a:	4f                   	dec    %edi
  80053b:	79 a5                	jns    8004e2 <vprintfmt+0x1f4>
  80053d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800540:	eb db                	jmp    80051d <vprintfmt+0x22f>
  800542:	8b 75 e4             	mov    -0x1c(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800545:	83 ec 08             	sub    $0x8,%esp
  800548:	53                   	push   %ebx
  800549:	6a 20                	push   $0x20
  80054b:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80054d:	4e                   	dec    %esi
  80054e:	83 c4 10             	add    $0x10,%esp
  800551:	85 f6                	test   %esi,%esi
  800553:	7f f0                	jg     800545 <vprintfmt+0x257>
  800555:	e9 a8 fd ff ff       	jmp    800302 <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80055a:	83 7d d4 01          	cmpl   $0x1,-0x2c(%ebp)
  80055e:	7e 16                	jle    800576 <vprintfmt+0x288>
		return va_arg(*ap, long long);
  800560:	8b 45 14             	mov    0x14(%ebp),%eax
  800563:	8d 50 08             	lea    0x8(%eax),%edx
  800566:	89 55 14             	mov    %edx,0x14(%ebp)
  800569:	8b 50 04             	mov    0x4(%eax),%edx
  80056c:	8b 00                	mov    (%eax),%eax
  80056e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800571:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800574:	eb 34                	jmp    8005aa <vprintfmt+0x2bc>
	else if (lflag)
  800576:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80057a:	74 18                	je     800594 <vprintfmt+0x2a6>
		return va_arg(*ap, long);
  80057c:	8b 45 14             	mov    0x14(%ebp),%eax
  80057f:	8d 50 04             	lea    0x4(%eax),%edx
  800582:	89 55 14             	mov    %edx,0x14(%ebp)
  800585:	8b 30                	mov    (%eax),%esi
  800587:	89 75 d8             	mov    %esi,-0x28(%ebp)
  80058a:	89 f0                	mov    %esi,%eax
  80058c:	c1 f8 1f             	sar    $0x1f,%eax
  80058f:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800592:	eb 16                	jmp    8005aa <vprintfmt+0x2bc>
	else
		return va_arg(*ap, int);
  800594:	8b 45 14             	mov    0x14(%ebp),%eax
  800597:	8d 50 04             	lea    0x4(%eax),%edx
  80059a:	89 55 14             	mov    %edx,0x14(%ebp)
  80059d:	8b 30                	mov    (%eax),%esi
  80059f:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8005a2:	89 f0                	mov    %esi,%eax
  8005a4:	c1 f8 1f             	sar    $0x1f,%eax
  8005a7:	89 45 dc             	mov    %eax,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005aa:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005ad:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
  8005b0:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005b4:	0f 89 8a 00 00 00    	jns    800644 <vprintfmt+0x356>
				putch('-', putdat);
  8005ba:	83 ec 08             	sub    $0x8,%esp
  8005bd:	53                   	push   %ebx
  8005be:	6a 2d                	push   $0x2d
  8005c0:	ff d7                	call   *%edi
				num = -(long long) num;
  8005c2:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005c5:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005c8:	f7 d8                	neg    %eax
  8005ca:	83 d2 00             	adc    $0x0,%edx
  8005cd:	f7 da                	neg    %edx
  8005cf:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005d2:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8005d7:	eb 70                	jmp    800649 <vprintfmt+0x35b>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005d9:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8005dc:	8d 45 14             	lea    0x14(%ebp),%eax
  8005df:	e8 97 fc ff ff       	call   80027b <getuint>
			base = 10;
  8005e4:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8005e9:	eb 5e                	jmp    800649 <vprintfmt+0x35b>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
  8005eb:	83 ec 08             	sub    $0x8,%esp
  8005ee:	53                   	push   %ebx
  8005ef:	6a 30                	push   $0x30
  8005f1:	ff d7                	call   *%edi
			num = getuint(&ap, lflag);
  8005f3:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8005f6:	8d 45 14             	lea    0x14(%ebp),%eax
  8005f9:	e8 7d fc ff ff       	call   80027b <getuint>
			base = 8;
			goto number;
  8005fe:	83 c4 10             	add    $0x10,%esp
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  800601:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800606:	eb 41                	jmp    800649 <vprintfmt+0x35b>
		// pointer
		case 'p':
			putch('0', putdat);
  800608:	83 ec 08             	sub    $0x8,%esp
  80060b:	53                   	push   %ebx
  80060c:	6a 30                	push   $0x30
  80060e:	ff d7                	call   *%edi
			putch('x', putdat);
  800610:	83 c4 08             	add    $0x8,%esp
  800613:	53                   	push   %ebx
  800614:	6a 78                	push   $0x78
  800616:	ff d7                	call   *%edi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800618:	8b 45 14             	mov    0x14(%ebp),%eax
  80061b:	8d 50 04             	lea    0x4(%eax),%edx
  80061e:	89 55 14             	mov    %edx,0x14(%ebp)
			goto number;
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800621:	8b 00                	mov    (%eax),%eax
  800623:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800628:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80062b:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800630:	eb 17                	jmp    800649 <vprintfmt+0x35b>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800632:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800635:	8d 45 14             	lea    0x14(%ebp),%eax
  800638:	e8 3e fc ff ff       	call   80027b <getuint>
			base = 16;
  80063d:	b9 10 00 00 00       	mov    $0x10,%ecx
  800642:	eb 05                	jmp    800649 <vprintfmt+0x35b>
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800644:	b9 0a 00 00 00       	mov    $0xa,%ecx
		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  800649:	83 ec 0c             	sub    $0xc,%esp
  80064c:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  800650:	56                   	push   %esi
  800651:	ff 75 e4             	pushl  -0x1c(%ebp)
  800654:	51                   	push   %ecx
  800655:	52                   	push   %edx
  800656:	50                   	push   %eax
  800657:	89 da                	mov    %ebx,%edx
  800659:	89 f8                	mov    %edi,%eax
  80065b:	e8 6b fb ff ff       	call   8001cb <printnum>
			break;
  800660:	83 c4 20             	add    $0x20,%esp
  800663:	e9 9a fc ff ff       	jmp    800302 <vprintfmt+0x14>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800668:	83 ec 08             	sub    $0x8,%esp
  80066b:	53                   	push   %ebx
  80066c:	52                   	push   %edx
  80066d:	ff d7                	call   *%edi
			break;
  80066f:	83 c4 10             	add    $0x10,%esp
  800672:	e9 8b fc ff ff       	jmp    800302 <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800677:	83 ec 08             	sub    $0x8,%esp
  80067a:	53                   	push   %ebx
  80067b:	6a 25                	push   $0x25
  80067d:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80067f:	83 c4 10             	add    $0x10,%esp
  800682:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800686:	0f 84 73 fc ff ff    	je     8002ff <vprintfmt+0x11>
  80068c:	4e                   	dec    %esi
  80068d:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800691:	75 f9                	jne    80068c <vprintfmt+0x39e>
  800693:	89 75 10             	mov    %esi,0x10(%ebp)
  800696:	e9 67 fc ff ff       	jmp    800302 <vprintfmt+0x14>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80069b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80069e:	8d 70 01             	lea    0x1(%eax),%esi
  8006a1:	8a 00                	mov    (%eax),%al
  8006a3:	0f be d0             	movsbl %al,%edx
  8006a6:	85 d2                	test   %edx,%edx
  8006a8:	0f 85 7a fe ff ff    	jne    800528 <vprintfmt+0x23a>
  8006ae:	e9 4f fc ff ff       	jmp    800302 <vprintfmt+0x14>
  8006b3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8006b6:	8d 70 01             	lea    0x1(%eax),%esi
  8006b9:	8a 00                	mov    (%eax),%al
  8006bb:	0f be d0             	movsbl %al,%edx
  8006be:	85 d2                	test   %edx,%edx
  8006c0:	0f 85 6a fe ff ff    	jne    800530 <vprintfmt+0x242>
  8006c6:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8006c9:	e9 77 fe ff ff       	jmp    800545 <vprintfmt+0x257>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  8006ce:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006d1:	5b                   	pop    %ebx
  8006d2:	5e                   	pop    %esi
  8006d3:	5f                   	pop    %edi
  8006d4:	5d                   	pop    %ebp
  8006d5:	c3                   	ret    

008006d6 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006d6:	55                   	push   %ebp
  8006d7:	89 e5                	mov    %esp,%ebp
  8006d9:	83 ec 18             	sub    $0x18,%esp
  8006dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8006df:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006e2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006e5:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006e9:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006ec:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006f3:	85 c0                	test   %eax,%eax
  8006f5:	74 26                	je     80071d <vsnprintf+0x47>
  8006f7:	85 d2                	test   %edx,%edx
  8006f9:	7e 29                	jle    800724 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006fb:	ff 75 14             	pushl  0x14(%ebp)
  8006fe:	ff 75 10             	pushl  0x10(%ebp)
  800701:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800704:	50                   	push   %eax
  800705:	68 b5 02 80 00       	push   $0x8002b5
  80070a:	e8 df fb ff ff       	call   8002ee <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80070f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800712:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800715:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800718:	83 c4 10             	add    $0x10,%esp
  80071b:	eb 0c                	jmp    800729 <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80071d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800722:	eb 05                	jmp    800729 <vsnprintf+0x53>
  800724:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800729:	c9                   	leave  
  80072a:	c3                   	ret    

0080072b <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80072b:	55                   	push   %ebp
  80072c:	89 e5                	mov    %esp,%ebp
  80072e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800731:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800734:	50                   	push   %eax
  800735:	ff 75 10             	pushl  0x10(%ebp)
  800738:	ff 75 0c             	pushl  0xc(%ebp)
  80073b:	ff 75 08             	pushl  0x8(%ebp)
  80073e:	e8 93 ff ff ff       	call   8006d6 <vsnprintf>
	va_end(ap);

	return rc;
}
  800743:	c9                   	leave  
  800744:	c3                   	ret    

00800745 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800745:	55                   	push   %ebp
  800746:	89 e5                	mov    %esp,%ebp
  800748:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80074b:	80 3a 00             	cmpb   $0x0,(%edx)
  80074e:	74 0e                	je     80075e <strlen+0x19>
  800750:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800755:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800756:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80075a:	75 f9                	jne    800755 <strlen+0x10>
  80075c:	eb 05                	jmp    800763 <strlen+0x1e>
  80075e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800763:	5d                   	pop    %ebp
  800764:	c3                   	ret    

00800765 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800765:	55                   	push   %ebp
  800766:	89 e5                	mov    %esp,%ebp
  800768:	53                   	push   %ebx
  800769:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80076c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80076f:	85 c9                	test   %ecx,%ecx
  800771:	74 1a                	je     80078d <strnlen+0x28>
  800773:	80 3b 00             	cmpb   $0x0,(%ebx)
  800776:	74 1c                	je     800794 <strnlen+0x2f>
  800778:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  80077d:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80077f:	39 ca                	cmp    %ecx,%edx
  800781:	74 16                	je     800799 <strnlen+0x34>
  800783:	42                   	inc    %edx
  800784:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800789:	75 f2                	jne    80077d <strnlen+0x18>
  80078b:	eb 0c                	jmp    800799 <strnlen+0x34>
  80078d:	b8 00 00 00 00       	mov    $0x0,%eax
  800792:	eb 05                	jmp    800799 <strnlen+0x34>
  800794:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800799:	5b                   	pop    %ebx
  80079a:	5d                   	pop    %ebp
  80079b:	c3                   	ret    

0080079c <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80079c:	55                   	push   %ebp
  80079d:	89 e5                	mov    %esp,%ebp
  80079f:	53                   	push   %ebx
  8007a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8007a3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007a6:	89 c2                	mov    %eax,%edx
  8007a8:	42                   	inc    %edx
  8007a9:	41                   	inc    %ecx
  8007aa:	8a 59 ff             	mov    -0x1(%ecx),%bl
  8007ad:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007b0:	84 db                	test   %bl,%bl
  8007b2:	75 f4                	jne    8007a8 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007b4:	5b                   	pop    %ebx
  8007b5:	5d                   	pop    %ebp
  8007b6:	c3                   	ret    

008007b7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007b7:	55                   	push   %ebp
  8007b8:	89 e5                	mov    %esp,%ebp
  8007ba:	53                   	push   %ebx
  8007bb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007be:	53                   	push   %ebx
  8007bf:	e8 81 ff ff ff       	call   800745 <strlen>
  8007c4:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007c7:	ff 75 0c             	pushl  0xc(%ebp)
  8007ca:	01 d8                	add    %ebx,%eax
  8007cc:	50                   	push   %eax
  8007cd:	e8 ca ff ff ff       	call   80079c <strcpy>
	return dst;
}
  8007d2:	89 d8                	mov    %ebx,%eax
  8007d4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007d7:	c9                   	leave  
  8007d8:	c3                   	ret    

008007d9 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007d9:	55                   	push   %ebp
  8007da:	89 e5                	mov    %esp,%ebp
  8007dc:	56                   	push   %esi
  8007dd:	53                   	push   %ebx
  8007de:	8b 75 08             	mov    0x8(%ebp),%esi
  8007e1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007e4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007e7:	85 db                	test   %ebx,%ebx
  8007e9:	74 14                	je     8007ff <strncpy+0x26>
  8007eb:	01 f3                	add    %esi,%ebx
  8007ed:	89 f1                	mov    %esi,%ecx
		*dst++ = *src;
  8007ef:	41                   	inc    %ecx
  8007f0:	8a 02                	mov    (%edx),%al
  8007f2:	88 41 ff             	mov    %al,-0x1(%ecx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007f5:	80 3a 01             	cmpb   $0x1,(%edx)
  8007f8:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007fb:	39 cb                	cmp    %ecx,%ebx
  8007fd:	75 f0                	jne    8007ef <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007ff:	89 f0                	mov    %esi,%eax
  800801:	5b                   	pop    %ebx
  800802:	5e                   	pop    %esi
  800803:	5d                   	pop    %ebp
  800804:	c3                   	ret    

00800805 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800805:	55                   	push   %ebp
  800806:	89 e5                	mov    %esp,%ebp
  800808:	53                   	push   %ebx
  800809:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80080c:	8b 45 10             	mov    0x10(%ebp),%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80080f:	85 c0                	test   %eax,%eax
  800811:	74 30                	je     800843 <strlcpy+0x3e>
		while (--size > 0 && *src != '\0')
  800813:	48                   	dec    %eax
  800814:	74 20                	je     800836 <strlcpy+0x31>
  800816:	8a 0b                	mov    (%ebx),%cl
  800818:	84 c9                	test   %cl,%cl
  80081a:	74 1f                	je     80083b <strlcpy+0x36>
  80081c:	8d 53 01             	lea    0x1(%ebx),%edx
  80081f:	01 c3                	add    %eax,%ebx
  800821:	8b 45 08             	mov    0x8(%ebp),%eax
			*dst++ = *src++;
  800824:	40                   	inc    %eax
  800825:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800828:	39 da                	cmp    %ebx,%edx
  80082a:	74 12                	je     80083e <strlcpy+0x39>
  80082c:	42                   	inc    %edx
  80082d:	8a 4a ff             	mov    -0x1(%edx),%cl
  800830:	84 c9                	test   %cl,%cl
  800832:	75 f0                	jne    800824 <strlcpy+0x1f>
  800834:	eb 08                	jmp    80083e <strlcpy+0x39>
  800836:	8b 45 08             	mov    0x8(%ebp),%eax
  800839:	eb 03                	jmp    80083e <strlcpy+0x39>
  80083b:	8b 45 08             	mov    0x8(%ebp),%eax
			*dst++ = *src++;
		*dst = '\0';
  80083e:	c6 00 00             	movb   $0x0,(%eax)
  800841:	eb 03                	jmp    800846 <strlcpy+0x41>
  800843:	8b 45 08             	mov    0x8(%ebp),%eax
	}
	return dst - dst_in;
  800846:	2b 45 08             	sub    0x8(%ebp),%eax
}
  800849:	5b                   	pop    %ebx
  80084a:	5d                   	pop    %ebp
  80084b:	c3                   	ret    

0080084c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80084c:	55                   	push   %ebp
  80084d:	89 e5                	mov    %esp,%ebp
  80084f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800852:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800855:	8a 01                	mov    (%ecx),%al
  800857:	84 c0                	test   %al,%al
  800859:	74 10                	je     80086b <strcmp+0x1f>
  80085b:	3a 02                	cmp    (%edx),%al
  80085d:	75 0c                	jne    80086b <strcmp+0x1f>
		p++, q++;
  80085f:	41                   	inc    %ecx
  800860:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800861:	8a 01                	mov    (%ecx),%al
  800863:	84 c0                	test   %al,%al
  800865:	74 04                	je     80086b <strcmp+0x1f>
  800867:	3a 02                	cmp    (%edx),%al
  800869:	74 f4                	je     80085f <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80086b:	0f b6 c0             	movzbl %al,%eax
  80086e:	0f b6 12             	movzbl (%edx),%edx
  800871:	29 d0                	sub    %edx,%eax
}
  800873:	5d                   	pop    %ebp
  800874:	c3                   	ret    

00800875 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800875:	55                   	push   %ebp
  800876:	89 e5                	mov    %esp,%ebp
  800878:	56                   	push   %esi
  800879:	53                   	push   %ebx
  80087a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80087d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800880:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  800883:	85 f6                	test   %esi,%esi
  800885:	74 23                	je     8008aa <strncmp+0x35>
  800887:	8a 03                	mov    (%ebx),%al
  800889:	84 c0                	test   %al,%al
  80088b:	74 2b                	je     8008b8 <strncmp+0x43>
  80088d:	3a 02                	cmp    (%edx),%al
  80088f:	75 27                	jne    8008b8 <strncmp+0x43>
  800891:	8d 43 01             	lea    0x1(%ebx),%eax
  800894:	01 de                	add    %ebx,%esi
		n--, p++, q++;
  800896:	89 c3                	mov    %eax,%ebx
  800898:	42                   	inc    %edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800899:	39 c6                	cmp    %eax,%esi
  80089b:	74 14                	je     8008b1 <strncmp+0x3c>
  80089d:	8a 08                	mov    (%eax),%cl
  80089f:	84 c9                	test   %cl,%cl
  8008a1:	74 15                	je     8008b8 <strncmp+0x43>
  8008a3:	40                   	inc    %eax
  8008a4:	3a 0a                	cmp    (%edx),%cl
  8008a6:	74 ee                	je     800896 <strncmp+0x21>
  8008a8:	eb 0e                	jmp    8008b8 <strncmp+0x43>
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008aa:	b8 00 00 00 00       	mov    $0x0,%eax
  8008af:	eb 0f                	jmp    8008c0 <strncmp+0x4b>
  8008b1:	b8 00 00 00 00       	mov    $0x0,%eax
  8008b6:	eb 08                	jmp    8008c0 <strncmp+0x4b>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008b8:	0f b6 03             	movzbl (%ebx),%eax
  8008bb:	0f b6 12             	movzbl (%edx),%edx
  8008be:	29 d0                	sub    %edx,%eax
}
  8008c0:	5b                   	pop    %ebx
  8008c1:	5e                   	pop    %esi
  8008c2:	5d                   	pop    %ebp
  8008c3:	c3                   	ret    

008008c4 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008c4:	55                   	push   %ebp
  8008c5:	89 e5                	mov    %esp,%ebp
  8008c7:	53                   	push   %ebx
  8008c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008cb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  8008ce:	8a 10                	mov    (%eax),%dl
  8008d0:	84 d2                	test   %dl,%dl
  8008d2:	74 1a                	je     8008ee <strchr+0x2a>
  8008d4:	88 d9                	mov    %bl,%cl
		if (*s == c)
  8008d6:	38 d3                	cmp    %dl,%bl
  8008d8:	75 06                	jne    8008e0 <strchr+0x1c>
  8008da:	eb 17                	jmp    8008f3 <strchr+0x2f>
  8008dc:	38 ca                	cmp    %cl,%dl
  8008de:	74 13                	je     8008f3 <strchr+0x2f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008e0:	40                   	inc    %eax
  8008e1:	8a 10                	mov    (%eax),%dl
  8008e3:	84 d2                	test   %dl,%dl
  8008e5:	75 f5                	jne    8008dc <strchr+0x18>
		if (*s == c)
			return (char *) s;
	return 0;
  8008e7:	b8 00 00 00 00       	mov    $0x0,%eax
  8008ec:	eb 05                	jmp    8008f3 <strchr+0x2f>
  8008ee:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008f3:	5b                   	pop    %ebx
  8008f4:	5d                   	pop    %ebp
  8008f5:	c3                   	ret    

008008f6 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008f6:	55                   	push   %ebp
  8008f7:	89 e5                	mov    %esp,%ebp
  8008f9:	53                   	push   %ebx
  8008fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8008fd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  800900:	8a 10                	mov    (%eax),%dl
  800902:	84 d2                	test   %dl,%dl
  800904:	74 13                	je     800919 <strfind+0x23>
  800906:	88 d9                	mov    %bl,%cl
		if (*s == c)
  800908:	38 d3                	cmp    %dl,%bl
  80090a:	75 06                	jne    800912 <strfind+0x1c>
  80090c:	eb 0b                	jmp    800919 <strfind+0x23>
  80090e:	38 ca                	cmp    %cl,%dl
  800910:	74 07                	je     800919 <strfind+0x23>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800912:	40                   	inc    %eax
  800913:	8a 10                	mov    (%eax),%dl
  800915:	84 d2                	test   %dl,%dl
  800917:	75 f5                	jne    80090e <strfind+0x18>
		if (*s == c)
			break;
	return (char *) s;
}
  800919:	5b                   	pop    %ebx
  80091a:	5d                   	pop    %ebp
  80091b:	c3                   	ret    

0080091c <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80091c:	55                   	push   %ebp
  80091d:	89 e5                	mov    %esp,%ebp
  80091f:	57                   	push   %edi
  800920:	56                   	push   %esi
  800921:	53                   	push   %ebx
  800922:	8b 7d 08             	mov    0x8(%ebp),%edi
  800925:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800928:	85 c9                	test   %ecx,%ecx
  80092a:	74 36                	je     800962 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80092c:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800932:	75 28                	jne    80095c <memset+0x40>
  800934:	f6 c1 03             	test   $0x3,%cl
  800937:	75 23                	jne    80095c <memset+0x40>
		c &= 0xFF;
  800939:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80093d:	89 d3                	mov    %edx,%ebx
  80093f:	c1 e3 08             	shl    $0x8,%ebx
  800942:	89 d6                	mov    %edx,%esi
  800944:	c1 e6 18             	shl    $0x18,%esi
  800947:	89 d0                	mov    %edx,%eax
  800949:	c1 e0 10             	shl    $0x10,%eax
  80094c:	09 f0                	or     %esi,%eax
  80094e:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800950:	89 d8                	mov    %ebx,%eax
  800952:	09 d0                	or     %edx,%eax
  800954:	c1 e9 02             	shr    $0x2,%ecx
  800957:	fc                   	cld    
  800958:	f3 ab                	rep stos %eax,%es:(%edi)
  80095a:	eb 06                	jmp    800962 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80095c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80095f:	fc                   	cld    
  800960:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800962:	89 f8                	mov    %edi,%eax
  800964:	5b                   	pop    %ebx
  800965:	5e                   	pop    %esi
  800966:	5f                   	pop    %edi
  800967:	5d                   	pop    %ebp
  800968:	c3                   	ret    

00800969 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800969:	55                   	push   %ebp
  80096a:	89 e5                	mov    %esp,%ebp
  80096c:	57                   	push   %edi
  80096d:	56                   	push   %esi
  80096e:	8b 45 08             	mov    0x8(%ebp),%eax
  800971:	8b 75 0c             	mov    0xc(%ebp),%esi
  800974:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800977:	39 c6                	cmp    %eax,%esi
  800979:	73 33                	jae    8009ae <memmove+0x45>
  80097b:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80097e:	39 d0                	cmp    %edx,%eax
  800980:	73 2c                	jae    8009ae <memmove+0x45>
		s += n;
		d += n;
  800982:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800985:	89 d6                	mov    %edx,%esi
  800987:	09 fe                	or     %edi,%esi
  800989:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80098f:	75 13                	jne    8009a4 <memmove+0x3b>
  800991:	f6 c1 03             	test   $0x3,%cl
  800994:	75 0e                	jne    8009a4 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800996:	83 ef 04             	sub    $0x4,%edi
  800999:	8d 72 fc             	lea    -0x4(%edx),%esi
  80099c:	c1 e9 02             	shr    $0x2,%ecx
  80099f:	fd                   	std    
  8009a0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009a2:	eb 07                	jmp    8009ab <memmove+0x42>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009a4:	4f                   	dec    %edi
  8009a5:	8d 72 ff             	lea    -0x1(%edx),%esi
  8009a8:	fd                   	std    
  8009a9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009ab:	fc                   	cld    
  8009ac:	eb 1d                	jmp    8009cb <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009ae:	89 f2                	mov    %esi,%edx
  8009b0:	09 c2                	or     %eax,%edx
  8009b2:	f6 c2 03             	test   $0x3,%dl
  8009b5:	75 0f                	jne    8009c6 <memmove+0x5d>
  8009b7:	f6 c1 03             	test   $0x3,%cl
  8009ba:	75 0a                	jne    8009c6 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
  8009bc:	c1 e9 02             	shr    $0x2,%ecx
  8009bf:	89 c7                	mov    %eax,%edi
  8009c1:	fc                   	cld    
  8009c2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009c4:	eb 05                	jmp    8009cb <memmove+0x62>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009c6:	89 c7                	mov    %eax,%edi
  8009c8:	fc                   	cld    
  8009c9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009cb:	5e                   	pop    %esi
  8009cc:	5f                   	pop    %edi
  8009cd:	5d                   	pop    %ebp
  8009ce:	c3                   	ret    

008009cf <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009cf:	55                   	push   %ebp
  8009d0:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009d2:	ff 75 10             	pushl  0x10(%ebp)
  8009d5:	ff 75 0c             	pushl  0xc(%ebp)
  8009d8:	ff 75 08             	pushl  0x8(%ebp)
  8009db:	e8 89 ff ff ff       	call   800969 <memmove>
}
  8009e0:	c9                   	leave  
  8009e1:	c3                   	ret    

008009e2 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009e2:	55                   	push   %ebp
  8009e3:	89 e5                	mov    %esp,%ebp
  8009e5:	57                   	push   %edi
  8009e6:	56                   	push   %esi
  8009e7:	53                   	push   %ebx
  8009e8:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8009eb:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009ee:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009f1:	85 c0                	test   %eax,%eax
  8009f3:	74 33                	je     800a28 <memcmp+0x46>
  8009f5:	8d 78 ff             	lea    -0x1(%eax),%edi
		if (*s1 != *s2)
  8009f8:	8a 13                	mov    (%ebx),%dl
  8009fa:	8a 0e                	mov    (%esi),%cl
  8009fc:	38 ca                	cmp    %cl,%dl
  8009fe:	75 13                	jne    800a13 <memcmp+0x31>
  800a00:	b8 00 00 00 00       	mov    $0x0,%eax
  800a05:	eb 16                	jmp    800a1d <memcmp+0x3b>
  800a07:	8a 54 03 01          	mov    0x1(%ebx,%eax,1),%dl
  800a0b:	40                   	inc    %eax
  800a0c:	8a 0c 06             	mov    (%esi,%eax,1),%cl
  800a0f:	38 ca                	cmp    %cl,%dl
  800a11:	74 0a                	je     800a1d <memcmp+0x3b>
			return (int) *s1 - (int) *s2;
  800a13:	0f b6 c2             	movzbl %dl,%eax
  800a16:	0f b6 c9             	movzbl %cl,%ecx
  800a19:	29 c8                	sub    %ecx,%eax
  800a1b:	eb 10                	jmp    800a2d <memcmp+0x4b>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a1d:	39 f8                	cmp    %edi,%eax
  800a1f:	75 e6                	jne    800a07 <memcmp+0x25>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a21:	b8 00 00 00 00       	mov    $0x0,%eax
  800a26:	eb 05                	jmp    800a2d <memcmp+0x4b>
  800a28:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a2d:	5b                   	pop    %ebx
  800a2e:	5e                   	pop    %esi
  800a2f:	5f                   	pop    %edi
  800a30:	5d                   	pop    %ebp
  800a31:	c3                   	ret    

00800a32 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a32:	55                   	push   %ebp
  800a33:	89 e5                	mov    %esp,%ebp
  800a35:	53                   	push   %ebx
  800a36:	8b 55 08             	mov    0x8(%ebp),%edx
	const void *ends = (const char *) s + n;
  800a39:	89 d0                	mov    %edx,%eax
  800a3b:	03 45 10             	add    0x10(%ebp),%eax
	for (; s < ends; s++)
  800a3e:	39 c2                	cmp    %eax,%edx
  800a40:	73 1b                	jae    800a5d <memfind+0x2b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a42:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
  800a46:	0f b6 0a             	movzbl (%edx),%ecx
  800a49:	39 d9                	cmp    %ebx,%ecx
  800a4b:	75 09                	jne    800a56 <memfind+0x24>
  800a4d:	eb 12                	jmp    800a61 <memfind+0x2f>
  800a4f:	0f b6 0a             	movzbl (%edx),%ecx
  800a52:	39 d9                	cmp    %ebx,%ecx
  800a54:	74 0f                	je     800a65 <memfind+0x33>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a56:	42                   	inc    %edx
  800a57:	39 d0                	cmp    %edx,%eax
  800a59:	75 f4                	jne    800a4f <memfind+0x1d>
  800a5b:	eb 0a                	jmp    800a67 <memfind+0x35>
  800a5d:	89 d0                	mov    %edx,%eax
  800a5f:	eb 06                	jmp    800a67 <memfind+0x35>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a61:	89 d0                	mov    %edx,%eax
  800a63:	eb 02                	jmp    800a67 <memfind+0x35>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a65:	89 d0                	mov    %edx,%eax
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a67:	5b                   	pop    %ebx
  800a68:	5d                   	pop    %ebp
  800a69:	c3                   	ret    

00800a6a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a6a:	55                   	push   %ebp
  800a6b:	89 e5                	mov    %esp,%ebp
  800a6d:	57                   	push   %edi
  800a6e:	56                   	push   %esi
  800a6f:	53                   	push   %ebx
  800a70:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a73:	eb 01                	jmp    800a76 <strtol+0xc>
		s++;
  800a75:	41                   	inc    %ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a76:	8a 01                	mov    (%ecx),%al
  800a78:	3c 20                	cmp    $0x20,%al
  800a7a:	74 f9                	je     800a75 <strtol+0xb>
  800a7c:	3c 09                	cmp    $0x9,%al
  800a7e:	74 f5                	je     800a75 <strtol+0xb>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a80:	3c 2b                	cmp    $0x2b,%al
  800a82:	75 08                	jne    800a8c <strtol+0x22>
		s++;
  800a84:	41                   	inc    %ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a85:	bf 00 00 00 00       	mov    $0x0,%edi
  800a8a:	eb 11                	jmp    800a9d <strtol+0x33>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a8c:	3c 2d                	cmp    $0x2d,%al
  800a8e:	75 08                	jne    800a98 <strtol+0x2e>
		s++, neg = 1;
  800a90:	41                   	inc    %ecx
  800a91:	bf 01 00 00 00       	mov    $0x1,%edi
  800a96:	eb 05                	jmp    800a9d <strtol+0x33>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a98:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a9d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800aa1:	0f 84 87 00 00 00    	je     800b2e <strtol+0xc4>
  800aa7:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  800aab:	75 27                	jne    800ad4 <strtol+0x6a>
  800aad:	80 39 30             	cmpb   $0x30,(%ecx)
  800ab0:	75 22                	jne    800ad4 <strtol+0x6a>
  800ab2:	e9 88 00 00 00       	jmp    800b3f <strtol+0xd5>
		s += 2, base = 16;
  800ab7:	83 c1 02             	add    $0x2,%ecx
  800aba:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  800ac1:	eb 11                	jmp    800ad4 <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
  800ac3:	41                   	inc    %ecx
  800ac4:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  800acb:	eb 07                	jmp    800ad4 <strtol+0x6a>
	else if (base == 0)
		base = 10;
  800acd:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)
  800ad4:	b8 00 00 00 00       	mov    $0x0,%eax

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ad9:	8a 11                	mov    (%ecx),%dl
  800adb:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800ade:	80 fb 09             	cmp    $0x9,%bl
  800ae1:	77 08                	ja     800aeb <strtol+0x81>
			dig = *s - '0';
  800ae3:	0f be d2             	movsbl %dl,%edx
  800ae6:	83 ea 30             	sub    $0x30,%edx
  800ae9:	eb 22                	jmp    800b0d <strtol+0xa3>
		else if (*s >= 'a' && *s <= 'z')
  800aeb:	8d 72 9f             	lea    -0x61(%edx),%esi
  800aee:	89 f3                	mov    %esi,%ebx
  800af0:	80 fb 19             	cmp    $0x19,%bl
  800af3:	77 08                	ja     800afd <strtol+0x93>
			dig = *s - 'a' + 10;
  800af5:	0f be d2             	movsbl %dl,%edx
  800af8:	83 ea 57             	sub    $0x57,%edx
  800afb:	eb 10                	jmp    800b0d <strtol+0xa3>
		else if (*s >= 'A' && *s <= 'Z')
  800afd:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b00:	89 f3                	mov    %esi,%ebx
  800b02:	80 fb 19             	cmp    $0x19,%bl
  800b05:	77 14                	ja     800b1b <strtol+0xb1>
			dig = *s - 'A' + 10;
  800b07:	0f be d2             	movsbl %dl,%edx
  800b0a:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b0d:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b10:	7d 09                	jge    800b1b <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800b12:	41                   	inc    %ecx
  800b13:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b17:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b19:	eb be                	jmp    800ad9 <strtol+0x6f>

	if (endptr)
  800b1b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b1f:	74 05                	je     800b26 <strtol+0xbc>
		*endptr = (char *) s;
  800b21:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b24:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800b26:	85 ff                	test   %edi,%edi
  800b28:	74 21                	je     800b4b <strtol+0xe1>
  800b2a:	f7 d8                	neg    %eax
  800b2c:	eb 1d                	jmp    800b4b <strtol+0xe1>
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b2e:	80 39 30             	cmpb   $0x30,(%ecx)
  800b31:	75 9a                	jne    800acd <strtol+0x63>
  800b33:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b37:	0f 84 7a ff ff ff    	je     800ab7 <strtol+0x4d>
  800b3d:	eb 84                	jmp    800ac3 <strtol+0x59>
  800b3f:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b43:	0f 84 6e ff ff ff    	je     800ab7 <strtol+0x4d>
  800b49:	eb 89                	jmp    800ad4 <strtol+0x6a>
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
}
  800b4b:	5b                   	pop    %ebx
  800b4c:	5e                   	pop    %esi
  800b4d:	5f                   	pop    %edi
  800b4e:	5d                   	pop    %ebp
  800b4f:	c3                   	ret    

00800b50 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b50:	55                   	push   %ebp
  800b51:	89 e5                	mov    %esp,%ebp
  800b53:	57                   	push   %edi
  800b54:	56                   	push   %esi
  800b55:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b56:	b8 00 00 00 00       	mov    $0x0,%eax
  800b5b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b5e:	8b 55 08             	mov    0x8(%ebp),%edx
  800b61:	89 c3                	mov    %eax,%ebx
  800b63:	89 c7                	mov    %eax,%edi
  800b65:	89 c6                	mov    %eax,%esi
  800b67:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b69:	5b                   	pop    %ebx
  800b6a:	5e                   	pop    %esi
  800b6b:	5f                   	pop    %edi
  800b6c:	5d                   	pop    %ebp
  800b6d:	c3                   	ret    

00800b6e <sys_cgetc>:

int
sys_cgetc(void)
{
  800b6e:	55                   	push   %ebp
  800b6f:	89 e5                	mov    %esp,%ebp
  800b71:	57                   	push   %edi
  800b72:	56                   	push   %esi
  800b73:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b74:	ba 00 00 00 00       	mov    $0x0,%edx
  800b79:	b8 01 00 00 00       	mov    $0x1,%eax
  800b7e:	89 d1                	mov    %edx,%ecx
  800b80:	89 d3                	mov    %edx,%ebx
  800b82:	89 d7                	mov    %edx,%edi
  800b84:	89 d6                	mov    %edx,%esi
  800b86:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b88:	5b                   	pop    %ebx
  800b89:	5e                   	pop    %esi
  800b8a:	5f                   	pop    %edi
  800b8b:	5d                   	pop    %ebp
  800b8c:	c3                   	ret    

00800b8d <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b8d:	55                   	push   %ebp
  800b8e:	89 e5                	mov    %esp,%ebp
  800b90:	57                   	push   %edi
  800b91:	56                   	push   %esi
  800b92:	53                   	push   %ebx
  800b93:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b96:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b9b:	b8 03 00 00 00       	mov    $0x3,%eax
  800ba0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ba3:	89 cb                	mov    %ecx,%ebx
  800ba5:	89 cf                	mov    %ecx,%edi
  800ba7:	89 ce                	mov    %ecx,%esi
  800ba9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bab:	85 c0                	test   %eax,%eax
  800bad:	7e 17                	jle    800bc6 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800baf:	83 ec 0c             	sub    $0xc,%esp
  800bb2:	50                   	push   %eax
  800bb3:	6a 03                	push   $0x3
  800bb5:	68 7f 25 80 00       	push   $0x80257f
  800bba:	6a 23                	push   $0x23
  800bbc:	68 9c 25 80 00       	push   $0x80259c
  800bc1:	e8 d9 12 00 00       	call   801e9f <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bc6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bc9:	5b                   	pop    %ebx
  800bca:	5e                   	pop    %esi
  800bcb:	5f                   	pop    %edi
  800bcc:	5d                   	pop    %ebp
  800bcd:	c3                   	ret    

00800bce <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bce:	55                   	push   %ebp
  800bcf:	89 e5                	mov    %esp,%ebp
  800bd1:	57                   	push   %edi
  800bd2:	56                   	push   %esi
  800bd3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bd4:	ba 00 00 00 00       	mov    $0x0,%edx
  800bd9:	b8 02 00 00 00       	mov    $0x2,%eax
  800bde:	89 d1                	mov    %edx,%ecx
  800be0:	89 d3                	mov    %edx,%ebx
  800be2:	89 d7                	mov    %edx,%edi
  800be4:	89 d6                	mov    %edx,%esi
  800be6:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800be8:	5b                   	pop    %ebx
  800be9:	5e                   	pop    %esi
  800bea:	5f                   	pop    %edi
  800beb:	5d                   	pop    %ebp
  800bec:	c3                   	ret    

00800bed <sys_yield>:

void
sys_yield(void)
{
  800bed:	55                   	push   %ebp
  800bee:	89 e5                	mov    %esp,%ebp
  800bf0:	57                   	push   %edi
  800bf1:	56                   	push   %esi
  800bf2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bf3:	ba 00 00 00 00       	mov    $0x0,%edx
  800bf8:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bfd:	89 d1                	mov    %edx,%ecx
  800bff:	89 d3                	mov    %edx,%ebx
  800c01:	89 d7                	mov    %edx,%edi
  800c03:	89 d6                	mov    %edx,%esi
  800c05:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c07:	5b                   	pop    %ebx
  800c08:	5e                   	pop    %esi
  800c09:	5f                   	pop    %edi
  800c0a:	5d                   	pop    %ebp
  800c0b:	c3                   	ret    

00800c0c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c0c:	55                   	push   %ebp
  800c0d:	89 e5                	mov    %esp,%ebp
  800c0f:	57                   	push   %edi
  800c10:	56                   	push   %esi
  800c11:	53                   	push   %ebx
  800c12:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c15:	be 00 00 00 00       	mov    $0x0,%esi
  800c1a:	b8 04 00 00 00       	mov    $0x4,%eax
  800c1f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c22:	8b 55 08             	mov    0x8(%ebp),%edx
  800c25:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c28:	89 f7                	mov    %esi,%edi
  800c2a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c2c:	85 c0                	test   %eax,%eax
  800c2e:	7e 17                	jle    800c47 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c30:	83 ec 0c             	sub    $0xc,%esp
  800c33:	50                   	push   %eax
  800c34:	6a 04                	push   $0x4
  800c36:	68 7f 25 80 00       	push   $0x80257f
  800c3b:	6a 23                	push   $0x23
  800c3d:	68 9c 25 80 00       	push   $0x80259c
  800c42:	e8 58 12 00 00       	call   801e9f <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c47:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c4a:	5b                   	pop    %ebx
  800c4b:	5e                   	pop    %esi
  800c4c:	5f                   	pop    %edi
  800c4d:	5d                   	pop    %ebp
  800c4e:	c3                   	ret    

00800c4f <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c4f:	55                   	push   %ebp
  800c50:	89 e5                	mov    %esp,%ebp
  800c52:	57                   	push   %edi
  800c53:	56                   	push   %esi
  800c54:	53                   	push   %ebx
  800c55:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c58:	b8 05 00 00 00       	mov    $0x5,%eax
  800c5d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c60:	8b 55 08             	mov    0x8(%ebp),%edx
  800c63:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c66:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c69:	8b 75 18             	mov    0x18(%ebp),%esi
  800c6c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c6e:	85 c0                	test   %eax,%eax
  800c70:	7e 17                	jle    800c89 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c72:	83 ec 0c             	sub    $0xc,%esp
  800c75:	50                   	push   %eax
  800c76:	6a 05                	push   $0x5
  800c78:	68 7f 25 80 00       	push   $0x80257f
  800c7d:	6a 23                	push   $0x23
  800c7f:	68 9c 25 80 00       	push   $0x80259c
  800c84:	e8 16 12 00 00       	call   801e9f <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c89:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c8c:	5b                   	pop    %ebx
  800c8d:	5e                   	pop    %esi
  800c8e:	5f                   	pop    %edi
  800c8f:	5d                   	pop    %ebp
  800c90:	c3                   	ret    

00800c91 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c91:	55                   	push   %ebp
  800c92:	89 e5                	mov    %esp,%ebp
  800c94:	57                   	push   %edi
  800c95:	56                   	push   %esi
  800c96:	53                   	push   %ebx
  800c97:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c9a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c9f:	b8 06 00 00 00       	mov    $0x6,%eax
  800ca4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca7:	8b 55 08             	mov    0x8(%ebp),%edx
  800caa:	89 df                	mov    %ebx,%edi
  800cac:	89 de                	mov    %ebx,%esi
  800cae:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cb0:	85 c0                	test   %eax,%eax
  800cb2:	7e 17                	jle    800ccb <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb4:	83 ec 0c             	sub    $0xc,%esp
  800cb7:	50                   	push   %eax
  800cb8:	6a 06                	push   $0x6
  800cba:	68 7f 25 80 00       	push   $0x80257f
  800cbf:	6a 23                	push   $0x23
  800cc1:	68 9c 25 80 00       	push   $0x80259c
  800cc6:	e8 d4 11 00 00       	call   801e9f <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800ccb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cce:	5b                   	pop    %ebx
  800ccf:	5e                   	pop    %esi
  800cd0:	5f                   	pop    %edi
  800cd1:	5d                   	pop    %ebp
  800cd2:	c3                   	ret    

00800cd3 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cd3:	55                   	push   %ebp
  800cd4:	89 e5                	mov    %esp,%ebp
  800cd6:	57                   	push   %edi
  800cd7:	56                   	push   %esi
  800cd8:	53                   	push   %ebx
  800cd9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cdc:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ce1:	b8 08 00 00 00       	mov    $0x8,%eax
  800ce6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce9:	8b 55 08             	mov    0x8(%ebp),%edx
  800cec:	89 df                	mov    %ebx,%edi
  800cee:	89 de                	mov    %ebx,%esi
  800cf0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cf2:	85 c0                	test   %eax,%eax
  800cf4:	7e 17                	jle    800d0d <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cf6:	83 ec 0c             	sub    $0xc,%esp
  800cf9:	50                   	push   %eax
  800cfa:	6a 08                	push   $0x8
  800cfc:	68 7f 25 80 00       	push   $0x80257f
  800d01:	6a 23                	push   $0x23
  800d03:	68 9c 25 80 00       	push   $0x80259c
  800d08:	e8 92 11 00 00       	call   801e9f <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d0d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d10:	5b                   	pop    %ebx
  800d11:	5e                   	pop    %esi
  800d12:	5f                   	pop    %edi
  800d13:	5d                   	pop    %ebp
  800d14:	c3                   	ret    

00800d15 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d15:	55                   	push   %ebp
  800d16:	89 e5                	mov    %esp,%ebp
  800d18:	57                   	push   %edi
  800d19:	56                   	push   %esi
  800d1a:	53                   	push   %ebx
  800d1b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d1e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d23:	b8 09 00 00 00       	mov    $0x9,%eax
  800d28:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d2b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d2e:	89 df                	mov    %ebx,%edi
  800d30:	89 de                	mov    %ebx,%esi
  800d32:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d34:	85 c0                	test   %eax,%eax
  800d36:	7e 17                	jle    800d4f <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d38:	83 ec 0c             	sub    $0xc,%esp
  800d3b:	50                   	push   %eax
  800d3c:	6a 09                	push   $0x9
  800d3e:	68 7f 25 80 00       	push   $0x80257f
  800d43:	6a 23                	push   $0x23
  800d45:	68 9c 25 80 00       	push   $0x80259c
  800d4a:	e8 50 11 00 00       	call   801e9f <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d4f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d52:	5b                   	pop    %ebx
  800d53:	5e                   	pop    %esi
  800d54:	5f                   	pop    %edi
  800d55:	5d                   	pop    %ebp
  800d56:	c3                   	ret    

00800d57 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d57:	55                   	push   %ebp
  800d58:	89 e5                	mov    %esp,%ebp
  800d5a:	57                   	push   %edi
  800d5b:	56                   	push   %esi
  800d5c:	53                   	push   %ebx
  800d5d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d60:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d65:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d6a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d6d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d70:	89 df                	mov    %ebx,%edi
  800d72:	89 de                	mov    %ebx,%esi
  800d74:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d76:	85 c0                	test   %eax,%eax
  800d78:	7e 17                	jle    800d91 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d7a:	83 ec 0c             	sub    $0xc,%esp
  800d7d:	50                   	push   %eax
  800d7e:	6a 0a                	push   $0xa
  800d80:	68 7f 25 80 00       	push   $0x80257f
  800d85:	6a 23                	push   $0x23
  800d87:	68 9c 25 80 00       	push   $0x80259c
  800d8c:	e8 0e 11 00 00       	call   801e9f <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d91:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d94:	5b                   	pop    %ebx
  800d95:	5e                   	pop    %esi
  800d96:	5f                   	pop    %edi
  800d97:	5d                   	pop    %ebp
  800d98:	c3                   	ret    

00800d99 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d99:	55                   	push   %ebp
  800d9a:	89 e5                	mov    %esp,%ebp
  800d9c:	57                   	push   %edi
  800d9d:	56                   	push   %esi
  800d9e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d9f:	be 00 00 00 00       	mov    $0x0,%esi
  800da4:	b8 0c 00 00 00       	mov    $0xc,%eax
  800da9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dac:	8b 55 08             	mov    0x8(%ebp),%edx
  800daf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800db2:	8b 7d 14             	mov    0x14(%ebp),%edi
  800db5:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800db7:	5b                   	pop    %ebx
  800db8:	5e                   	pop    %esi
  800db9:	5f                   	pop    %edi
  800dba:	5d                   	pop    %ebp
  800dbb:	c3                   	ret    

00800dbc <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800dbc:	55                   	push   %ebp
  800dbd:	89 e5                	mov    %esp,%ebp
  800dbf:	57                   	push   %edi
  800dc0:	56                   	push   %esi
  800dc1:	53                   	push   %ebx
  800dc2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dc5:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dca:	b8 0d 00 00 00       	mov    $0xd,%eax
  800dcf:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd2:	89 cb                	mov    %ecx,%ebx
  800dd4:	89 cf                	mov    %ecx,%edi
  800dd6:	89 ce                	mov    %ecx,%esi
  800dd8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dda:	85 c0                	test   %eax,%eax
  800ddc:	7e 17                	jle    800df5 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dde:	83 ec 0c             	sub    $0xc,%esp
  800de1:	50                   	push   %eax
  800de2:	6a 0d                	push   $0xd
  800de4:	68 7f 25 80 00       	push   $0x80257f
  800de9:	6a 23                	push   $0x23
  800deb:	68 9c 25 80 00       	push   $0x80259c
  800df0:	e8 aa 10 00 00       	call   801e9f <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800df5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800df8:	5b                   	pop    %ebx
  800df9:	5e                   	pop    %esi
  800dfa:	5f                   	pop    %edi
  800dfb:	5d                   	pop    %ebp
  800dfc:	c3                   	ret    

00800dfd <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800dfd:	55                   	push   %ebp
  800dfe:	89 e5                	mov    %esp,%ebp
  800e00:	56                   	push   %esi
  800e01:	53                   	push   %ebx
  800e02:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e05:	8b 18                	mov    (%eax),%ebx
	// copy-on-write page.  If not, panic.
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).
	
	if((err & FEC_WR) == 0){
  800e07:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e0b:	75 14                	jne    800e21 <pgfault+0x24>
		panic("pgfault not cause by write \n");
  800e0d:	83 ec 04             	sub    $0x4,%esp
  800e10:	68 aa 25 80 00       	push   $0x8025aa
  800e15:	6a 1c                	push   $0x1c
  800e17:	68 c7 25 80 00       	push   $0x8025c7
  800e1c:	e8 7e 10 00 00       	call   801e9f <_panic>
	}
 
	if ((uvpt[PGNUM(addr)] & PTE_COW) == 0) 
  800e21:	89 d8                	mov    %ebx,%eax
  800e23:	c1 e8 0c             	shr    $0xc,%eax
  800e26:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e2d:	f6 c4 08             	test   $0x8,%ah
  800e30:	75 14                	jne    800e46 <pgfault+0x49>
    {
        panic("pgfault not cause by COW \n");
  800e32:	83 ec 04             	sub    $0x4,%esp
  800e35:	68 d2 25 80 00       	push   $0x8025d2
  800e3a:	6a 21                	push   $0x21
  800e3c:	68 c7 25 80 00       	push   $0x8025c7
  800e41:	e8 59 10 00 00       	call   801e9f <_panic>
	// copy the data from the old page to the new page, then move the new
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.
	envid_t eid = sys_getenvid();
  800e46:	e8 83 fd ff ff       	call   800bce <sys_getenvid>
  800e4b:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(eid,(void*)PFTEMP,PTE_P|PTE_W|PTE_U)) < 0)
  800e4d:	83 ec 04             	sub    $0x4,%esp
  800e50:	6a 07                	push   $0x7
  800e52:	68 00 f0 7f 00       	push   $0x7ff000
  800e57:	50                   	push   %eax
  800e58:	e8 af fd ff ff       	call   800c0c <sys_page_alloc>
  800e5d:	83 c4 10             	add    $0x10,%esp
  800e60:	85 c0                	test   %eax,%eax
  800e62:	79 14                	jns    800e78 <pgfault+0x7b>
		panic("page alloction failed.\n");
  800e64:	83 ec 04             	sub    $0x4,%esp
  800e67:	68 ed 25 80 00       	push   $0x8025ed
  800e6c:	6a 2d                	push   $0x2d
  800e6e:	68 c7 25 80 00       	push   $0x8025c7
  800e73:	e8 27 10 00 00       	call   801e9f <_panic>
	addr = ROUNDDOWN(addr,PGSIZE);
  800e78:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memmove(PFTEMP,addr,PGSIZE);
  800e7e:	83 ec 04             	sub    $0x4,%esp
  800e81:	68 00 10 00 00       	push   $0x1000
  800e86:	53                   	push   %ebx
  800e87:	68 00 f0 7f 00       	push   $0x7ff000
  800e8c:	e8 d8 fa ff ff       	call   800969 <memmove>
	if ((r = sys_page_map(eid, PFTEMP, eid, addr, PTE_P | PTE_W |PTE_U)) < 0)
  800e91:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e98:	53                   	push   %ebx
  800e99:	56                   	push   %esi
  800e9a:	68 00 f0 7f 00       	push   $0x7ff000
  800e9f:	56                   	push   %esi
  800ea0:	e8 aa fd ff ff       	call   800c4f <sys_page_map>
  800ea5:	83 c4 20             	add    $0x20,%esp
  800ea8:	85 c0                	test   %eax,%eax
  800eaa:	79 12                	jns    800ebe <pgfault+0xc1>
        panic("pgfault: page map failed %e\n", r);
  800eac:	50                   	push   %eax
  800ead:	68 05 26 80 00       	push   $0x802605
  800eb2:	6a 31                	push   $0x31
  800eb4:	68 c7 25 80 00       	push   $0x8025c7
  800eb9:	e8 e1 0f 00 00       	call   801e9f <_panic>
	if ((r = sys_page_unmap(eid, PFTEMP)) < 0)
  800ebe:	83 ec 08             	sub    $0x8,%esp
  800ec1:	68 00 f0 7f 00       	push   $0x7ff000
  800ec6:	56                   	push   %esi
  800ec7:	e8 c5 fd ff ff       	call   800c91 <sys_page_unmap>
  800ecc:	83 c4 10             	add    $0x10,%esp
  800ecf:	85 c0                	test   %eax,%eax
  800ed1:	79 12                	jns    800ee5 <pgfault+0xe8>
        panic("pgfault: page unmap failed %e\n", r);
  800ed3:	50                   	push   %eax
  800ed4:	68 74 26 80 00       	push   $0x802674
  800ed9:	6a 33                	push   $0x33
  800edb:	68 c7 25 80 00       	push   $0x8025c7
  800ee0:	e8 ba 0f 00 00       	call   801e9f <_panic>
	// LAB 4: Your code here.

	// panic("pgfault not implemented");
}
  800ee5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ee8:	5b                   	pop    %ebx
  800ee9:	5e                   	pop    %esi
  800eea:	5d                   	pop    %ebp
  800eeb:	c3                   	ret    

00800eec <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800eec:	55                   	push   %ebp
  800eed:	89 e5                	mov    %esp,%ebp
  800eef:	57                   	push   %edi
  800ef0:	56                   	push   %esi
  800ef1:	53                   	push   %ebx
  800ef2:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	struct PageInfo* pg = NULL;
	set_pgfault_handler(pgfault);
  800ef5:	68 fd 0d 80 00       	push   $0x800dfd
  800efa:	e8 e6 0f 00 00       	call   801ee5 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800eff:	b8 07 00 00 00       	mov    $0x7,%eax
  800f04:	cd 30                	int    $0x30
  800f06:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800f09:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t eid = sys_exofork();
	if (eid < 0) panic("fork fault.\n");
  800f0c:	83 c4 10             	add    $0x10,%esp
  800f0f:	85 c0                	test   %eax,%eax
  800f11:	79 14                	jns    800f27 <fork+0x3b>
  800f13:	83 ec 04             	sub    $0x4,%esp
  800f16:	68 22 26 80 00       	push   $0x802622
  800f1b:	6a 71                	push   $0x71
  800f1d:	68 c7 25 80 00       	push   $0x8025c7
  800f22:	e8 78 0f 00 00       	call   801e9f <_panic>
	if (eid == 0){
  800f27:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800f2b:	75 25                	jne    800f52 <fork+0x66>
		thisenv = &envs[ENVX(sys_getenvid())];
  800f2d:	e8 9c fc ff ff       	call   800bce <sys_getenvid>
  800f32:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f37:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800f3e:	c1 e0 07             	shl    $0x7,%eax
  800f41:	29 d0                	sub    %edx,%eax
  800f43:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f48:	a3 04 40 80 00       	mov    %eax,0x804004
		return eid;
  800f4d:	e9 61 01 00 00       	jmp    8010b3 <fork+0x1c7>
  800f52:	bb 00 00 80 00       	mov    $0x800000,%ebx
	}
	// copy something to the child page.
	for (uintptr_t i = UTEXT;i <= USTACKTOP;i += PGSIZE){
		if (uvpd[PDX(i)] & PTE_P && (uvpt[PGNUM(i)] & PTE_P)){
  800f57:	89 d8                	mov    %ebx,%eax
  800f59:	c1 e8 16             	shr    $0x16,%eax
  800f5c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f63:	a8 01                	test   $0x1,%al
  800f65:	74 52                	je     800fb9 <fork+0xcd>
  800f67:	89 de                	mov    %ebx,%esi
  800f69:	c1 ee 0c             	shr    $0xc,%esi
  800f6c:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800f73:	a8 01                	test   $0x1,%al
  800f75:	74 42                	je     800fb9 <fork+0xcd>
duppage(envid_t envid, unsigned pn)
{
	int r;

	// LAB 4: Your code here.
	envid_t myenvid = sys_getenvid();
  800f77:	e8 52 fc ff ff       	call   800bce <sys_getenvid>
  800f7c:	89 c7                	mov    %eax,%edi
	pte_t pte = uvpt[pn];
  800f7e:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
	int perm = PTE_U | PTE_P;
	if(pte & PTE_W || pte & PTE_COW)
  800f85:	a9 02 08 00 00       	test   $0x802,%eax
  800f8a:	0f 85 de 00 00 00    	jne    80106e <fork+0x182>
  800f90:	e9 fb 00 00 00       	jmp    801090 <fork+0x1a4>
		perm |= PTE_COW;
	if((r = sys_page_map(myenvid,(void*)(pn*PGSIZE),envid,(void*)(pn*PGSIZE),perm))<0){
		panic("duppage fault :%e\n",r);
  800f95:	50                   	push   %eax
  800f96:	68 2f 26 80 00       	push   $0x80262f
  800f9b:	6a 50                	push   $0x50
  800f9d:	68 c7 25 80 00       	push   $0x8025c7
  800fa2:	e8 f8 0e 00 00       	call   801e9f <_panic>
	}
	if(perm & PTE_COW){
		if((r = sys_page_map(myenvid,(void*)(pn*PGSIZE),myenvid,(void*)(pn*PGSIZE),perm))<0)
			panic("duppage fault :%e\n",r);
  800fa7:	50                   	push   %eax
  800fa8:	68 2f 26 80 00       	push   $0x80262f
  800fad:	6a 54                	push   $0x54
  800faf:	68 c7 25 80 00       	push   $0x8025c7
  800fb4:	e8 e6 0e 00 00       	call   801e9f <_panic>
	if (eid == 0){
		thisenv = &envs[ENVX(sys_getenvid())];
		return eid;
	}
	// copy something to the child page.
	for (uintptr_t i = UTEXT;i <= USTACKTOP;i += PGSIZE){
  800fb9:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800fbf:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  800fc5:	75 90                	jne    800f57 <fork+0x6b>
		if (uvpd[PDX(i)] & PTE_P && (uvpt[PGNUM(i)] & PTE_P)){
			duppage(eid,PGNUM(i));
		}
	}
	int r = sys_page_alloc(eid,(void*)(UXSTACKTOP-PGSIZE),PTE_U|PTE_P|PTE_W);
  800fc7:	83 ec 04             	sub    $0x4,%esp
  800fca:	6a 07                	push   $0x7
  800fcc:	68 00 f0 bf ee       	push   $0xeebff000
  800fd1:	ff 75 e0             	pushl  -0x20(%ebp)
  800fd4:	e8 33 fc ff ff       	call   800c0c <sys_page_alloc>
	if (r < 0) panic("fork fault.\n");
  800fd9:	83 c4 10             	add    $0x10,%esp
  800fdc:	85 c0                	test   %eax,%eax
  800fde:	79 14                	jns    800ff4 <fork+0x108>
  800fe0:	83 ec 04             	sub    $0x4,%esp
  800fe3:	68 22 26 80 00       	push   $0x802622
  800fe8:	6a 7d                	push   $0x7d
  800fea:	68 c7 25 80 00       	push   $0x8025c7
  800fef:	e8 ab 0e 00 00       	call   801e9f <_panic>

	extern void _pgfault_upcall();
    r = sys_env_set_pgfault_upcall(eid, _pgfault_upcall);
  800ff4:	83 ec 08             	sub    $0x8,%esp
  800ff7:	68 5d 1f 80 00       	push   $0x801f5d
  800ffc:	ff 75 e0             	pushl  -0x20(%ebp)
  800fff:	e8 53 fd ff ff       	call   800d57 <sys_env_set_pgfault_upcall>
    if (r < 0) panic("fork fault 3\n");
  801004:	83 c4 10             	add    $0x10,%esp
  801007:	85 c0                	test   %eax,%eax
  801009:	79 17                	jns    801022 <fork+0x136>
  80100b:	83 ec 04             	sub    $0x4,%esp
  80100e:	68 42 26 80 00       	push   $0x802642
  801013:	68 81 00 00 00       	push   $0x81
  801018:	68 c7 25 80 00       	push   $0x8025c7
  80101d:	e8 7d 0e 00 00       	call   801e9f <_panic>

	if ((r = sys_env_set_status(eid, ENV_RUNNABLE)) < 0)
  801022:	83 ec 08             	sub    $0x8,%esp
  801025:	6a 02                	push   $0x2
  801027:	ff 75 e0             	pushl  -0x20(%ebp)
  80102a:	e8 a4 fc ff ff       	call   800cd3 <sys_env_set_status>
  80102f:	83 c4 10             	add    $0x10,%esp
  801032:	85 c0                	test   %eax,%eax
  801034:	79 7d                	jns    8010b3 <fork+0x1c7>
        panic("fork fault 4\n");
  801036:	83 ec 04             	sub    $0x4,%esp
  801039:	68 50 26 80 00       	push   $0x802650
  80103e:	68 84 00 00 00       	push   $0x84
  801043:	68 c7 25 80 00       	push   $0x8025c7
  801048:	e8 52 0e 00 00       	call   801e9f <_panic>
		perm |= PTE_COW;
	if((r = sys_page_map(myenvid,(void*)(pn*PGSIZE),envid,(void*)(pn*PGSIZE),perm))<0){
		panic("duppage fault :%e\n",r);
	}
	if(perm & PTE_COW){
		if((r = sys_page_map(myenvid,(void*)(pn*PGSIZE),myenvid,(void*)(pn*PGSIZE),perm))<0)
  80104d:	83 ec 0c             	sub    $0xc,%esp
  801050:	68 05 08 00 00       	push   $0x805
  801055:	56                   	push   %esi
  801056:	57                   	push   %edi
  801057:	56                   	push   %esi
  801058:	57                   	push   %edi
  801059:	e8 f1 fb ff ff       	call   800c4f <sys_page_map>
  80105e:	83 c4 20             	add    $0x20,%esp
  801061:	85 c0                	test   %eax,%eax
  801063:	0f 89 50 ff ff ff    	jns    800fb9 <fork+0xcd>
  801069:	e9 39 ff ff ff       	jmp    800fa7 <fork+0xbb>
	envid_t myenvid = sys_getenvid();
	pte_t pte = uvpt[pn];
	int perm = PTE_U | PTE_P;
	if(pte & PTE_W || pte & PTE_COW)
		perm |= PTE_COW;
	if((r = sys_page_map(myenvid,(void*)(pn*PGSIZE),envid,(void*)(pn*PGSIZE),perm))<0){
  80106e:	c1 e6 0c             	shl    $0xc,%esi
  801071:	83 ec 0c             	sub    $0xc,%esp
  801074:	68 05 08 00 00       	push   $0x805
  801079:	56                   	push   %esi
  80107a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80107d:	56                   	push   %esi
  80107e:	57                   	push   %edi
  80107f:	e8 cb fb ff ff       	call   800c4f <sys_page_map>
  801084:	83 c4 20             	add    $0x20,%esp
  801087:	85 c0                	test   %eax,%eax
  801089:	79 c2                	jns    80104d <fork+0x161>
  80108b:	e9 05 ff ff ff       	jmp    800f95 <fork+0xa9>
  801090:	c1 e6 0c             	shl    $0xc,%esi
  801093:	83 ec 0c             	sub    $0xc,%esp
  801096:	6a 05                	push   $0x5
  801098:	56                   	push   %esi
  801099:	ff 75 e4             	pushl  -0x1c(%ebp)
  80109c:	56                   	push   %esi
  80109d:	57                   	push   %edi
  80109e:	e8 ac fb ff ff       	call   800c4f <sys_page_map>
  8010a3:	83 c4 20             	add    $0x20,%esp
  8010a6:	85 c0                	test   %eax,%eax
  8010a8:	0f 89 0b ff ff ff    	jns    800fb9 <fork+0xcd>
  8010ae:	e9 e2 fe ff ff       	jmp    800f95 <fork+0xa9>
    if (r < 0) panic("fork fault 3\n");

	if ((r = sys_env_set_status(eid, ENV_RUNNABLE)) < 0)
        panic("fork fault 4\n");
    return eid;
}
  8010b3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8010b6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010b9:	5b                   	pop    %ebx
  8010ba:	5e                   	pop    %esi
  8010bb:	5f                   	pop    %edi
  8010bc:	5d                   	pop    %ebp
  8010bd:	c3                   	ret    

008010be <sfork>:

// Challenge!
int
sfork(void)
{
  8010be:	55                   	push   %ebp
  8010bf:	89 e5                	mov    %esp,%ebp
  8010c1:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8010c4:	68 5e 26 80 00       	push   $0x80265e
  8010c9:	68 8c 00 00 00       	push   $0x8c
  8010ce:	68 c7 25 80 00       	push   $0x8025c7
  8010d3:	e8 c7 0d 00 00       	call   801e9f <_panic>

008010d8 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8010d8:	55                   	push   %ebp
  8010d9:	89 e5                	mov    %esp,%ebp
  8010db:	56                   	push   %esi
  8010dc:	53                   	push   %ebx
  8010dd:	8b 75 08             	mov    0x8(%ebp),%esi
  8010e0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010e3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");
	int r;
    if (pg != NULL) {
  8010e6:	85 c0                	test   %eax,%eax
  8010e8:	74 0e                	je     8010f8 <ipc_recv+0x20>
        r = sys_ipc_recv(pg);
  8010ea:	83 ec 0c             	sub    $0xc,%esp
  8010ed:	50                   	push   %eax
  8010ee:	e8 c9 fc ff ff       	call   800dbc <sys_ipc_recv>
  8010f3:	83 c4 10             	add    $0x10,%esp
  8010f6:	eb 10                	jmp    801108 <ipc_recv+0x30>
    } else {
        r = sys_ipc_recv((void *) UTOP);
  8010f8:	83 ec 0c             	sub    $0xc,%esp
  8010fb:	68 00 00 c0 ee       	push   $0xeec00000
  801100:	e8 b7 fc ff ff       	call   800dbc <sys_ipc_recv>
  801105:	83 c4 10             	add    $0x10,%esp
    }
    if (r < 0) {
  801108:	85 c0                	test   %eax,%eax
  80110a:	79 16                	jns    801122 <ipc_recv+0x4a>
        // failed
        if (from_env_store != NULL) *from_env_store = 0;
  80110c:	85 f6                	test   %esi,%esi
  80110e:	74 06                	je     801116 <ipc_recv+0x3e>
  801110:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        if (perm_store != NULL) *perm_store = 0;
  801116:	85 db                	test   %ebx,%ebx
  801118:	74 2c                	je     801146 <ipc_recv+0x6e>
  80111a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801120:	eb 24                	jmp    801146 <ipc_recv+0x6e>
        return r;
    } else {
        if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801122:	85 f6                	test   %esi,%esi
  801124:	74 0a                	je     801130 <ipc_recv+0x58>
  801126:	a1 04 40 80 00       	mov    0x804004,%eax
  80112b:	8b 40 74             	mov    0x74(%eax),%eax
  80112e:	89 06                	mov    %eax,(%esi)
        if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801130:	85 db                	test   %ebx,%ebx
  801132:	74 0a                	je     80113e <ipc_recv+0x66>
  801134:	a1 04 40 80 00       	mov    0x804004,%eax
  801139:	8b 40 78             	mov    0x78(%eax),%eax
  80113c:	89 03                	mov    %eax,(%ebx)
        return thisenv->env_ipc_value;
  80113e:	a1 04 40 80 00       	mov    0x804004,%eax
  801143:	8b 40 70             	mov    0x70(%eax),%eax
    }
 
	return 0;
}
  801146:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801149:	5b                   	pop    %ebx
  80114a:	5e                   	pop    %esi
  80114b:	5d                   	pop    %ebp
  80114c:	c3                   	ret    

0080114d <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80114d:	55                   	push   %ebp
  80114e:	89 e5                	mov    %esp,%ebp
  801150:	57                   	push   %edi
  801151:	56                   	push   %esi
  801152:	53                   	push   %ebx
  801153:	83 ec 0c             	sub    $0xc,%esp
  801156:	8b 75 10             	mov    0x10(%ebp),%esi
  801159:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");
	int r;
    if (pg == NULL) pg = (void *)UTOP;
  80115c:	85 f6                	test   %esi,%esi
  80115e:	75 05                	jne    801165 <ipc_send+0x18>
  801160:	be 00 00 c0 ee       	mov    $0xeec00000,%esi
    do {
        r = sys_ipc_try_send(to_env, val, pg, perm);
  801165:	57                   	push   %edi
  801166:	56                   	push   %esi
  801167:	ff 75 0c             	pushl  0xc(%ebp)
  80116a:	ff 75 08             	pushl  0x8(%ebp)
  80116d:	e8 27 fc ff ff       	call   800d99 <sys_ipc_try_send>
  801172:	89 c3                	mov    %eax,%ebx
        if (r < 0 && r != -E_IPC_NOT_RECV) panic("ipc send failed: %e", r);
  801174:	83 c4 10             	add    $0x10,%esp
  801177:	85 c0                	test   %eax,%eax
  801179:	79 17                	jns    801192 <ipc_send+0x45>
  80117b:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80117e:	74 1d                	je     80119d <ipc_send+0x50>
  801180:	50                   	push   %eax
  801181:	68 93 26 80 00       	push   $0x802693
  801186:	6a 40                	push   $0x40
  801188:	68 a7 26 80 00       	push   $0x8026a7
  80118d:	e8 0d 0d 00 00       	call   801e9f <_panic>
        sys_yield();
  801192:	e8 56 fa ff ff       	call   800bed <sys_yield>
    } while (r != 0);
  801197:	85 db                	test   %ebx,%ebx
  801199:	75 ca                	jne    801165 <ipc_send+0x18>
  80119b:	eb 07                	jmp    8011a4 <ipc_send+0x57>
	int r;
    if (pg == NULL) pg = (void *)UTOP;
    do {
        r = sys_ipc_try_send(to_env, val, pg, perm);
        if (r < 0 && r != -E_IPC_NOT_RECV) panic("ipc send failed: %e", r);
        sys_yield();
  80119d:	e8 4b fa ff ff       	call   800bed <sys_yield>
  8011a2:	eb c1                	jmp    801165 <ipc_send+0x18>
    } while (r != 0);
}
  8011a4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011a7:	5b                   	pop    %ebx
  8011a8:	5e                   	pop    %esi
  8011a9:	5f                   	pop    %edi
  8011aa:	5d                   	pop    %ebp
  8011ab:	c3                   	ret    

008011ac <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8011ac:	55                   	push   %ebp
  8011ad:	89 e5                	mov    %esp,%ebp
  8011af:	53                   	push   %ebx
  8011b0:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  8011b3:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  8011b8:	39 c1                	cmp    %eax,%ecx
  8011ba:	74 21                	je     8011dd <ipc_find_env+0x31>
  8011bc:	ba 01 00 00 00       	mov    $0x1,%edx
  8011c1:	8d 1c 95 00 00 00 00 	lea    0x0(,%edx,4),%ebx
  8011c8:	89 d0                	mov    %edx,%eax
  8011ca:	c1 e0 07             	shl    $0x7,%eax
  8011cd:	29 d8                	sub    %ebx,%eax
  8011cf:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8011d4:	8b 40 50             	mov    0x50(%eax),%eax
  8011d7:	39 c8                	cmp    %ecx,%eax
  8011d9:	75 1b                	jne    8011f6 <ipc_find_env+0x4a>
  8011db:	eb 05                	jmp    8011e2 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8011dd:	ba 00 00 00 00       	mov    $0x0,%edx
		if (envs[i].env_type == type)
			return envs[i].env_id;
  8011e2:	8d 04 95 00 00 00 00 	lea    0x0(,%edx,4),%eax
  8011e9:	c1 e2 07             	shl    $0x7,%edx
  8011ec:	29 c2                	sub    %eax,%edx
  8011ee:	8b 82 48 00 c0 ee    	mov    -0x113fffb8(%edx),%eax
  8011f4:	eb 0e                	jmp    801204 <ipc_find_env+0x58>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8011f6:	42                   	inc    %edx
  8011f7:	81 fa 00 04 00 00    	cmp    $0x400,%edx
  8011fd:	75 c2                	jne    8011c1 <ipc_find_env+0x15>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8011ff:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801204:	5b                   	pop    %ebx
  801205:	5d                   	pop    %ebp
  801206:	c3                   	ret    

00801207 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801207:	55                   	push   %ebp
  801208:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80120a:	8b 45 08             	mov    0x8(%ebp),%eax
  80120d:	05 00 00 00 30       	add    $0x30000000,%eax
  801212:	c1 e8 0c             	shr    $0xc,%eax
}
  801215:	5d                   	pop    %ebp
  801216:	c3                   	ret    

00801217 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801217:	55                   	push   %ebp
  801218:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80121a:	8b 45 08             	mov    0x8(%ebp),%eax
  80121d:	05 00 00 00 30       	add    $0x30000000,%eax
  801222:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801227:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80122c:	5d                   	pop    %ebp
  80122d:	c3                   	ret    

0080122e <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80122e:	55                   	push   %ebp
  80122f:	89 e5                	mov    %esp,%ebp
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801231:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  801236:	a8 01                	test   $0x1,%al
  801238:	74 34                	je     80126e <fd_alloc+0x40>
  80123a:	a1 00 00 74 ef       	mov    0xef740000,%eax
  80123f:	a8 01                	test   $0x1,%al
  801241:	74 32                	je     801275 <fd_alloc+0x47>
  801243:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  801248:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80124a:	89 c2                	mov    %eax,%edx
  80124c:	c1 ea 16             	shr    $0x16,%edx
  80124f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801256:	f6 c2 01             	test   $0x1,%dl
  801259:	74 1f                	je     80127a <fd_alloc+0x4c>
  80125b:	89 c2                	mov    %eax,%edx
  80125d:	c1 ea 0c             	shr    $0xc,%edx
  801260:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801267:	f6 c2 01             	test   $0x1,%dl
  80126a:	75 1a                	jne    801286 <fd_alloc+0x58>
  80126c:	eb 0c                	jmp    80127a <fd_alloc+0x4c>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  80126e:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  801273:	eb 05                	jmp    80127a <fd_alloc+0x4c>
  801275:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  80127a:	8b 45 08             	mov    0x8(%ebp),%eax
  80127d:	89 08                	mov    %ecx,(%eax)
			return 0;
  80127f:	b8 00 00 00 00       	mov    $0x0,%eax
  801284:	eb 1a                	jmp    8012a0 <fd_alloc+0x72>
  801286:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80128b:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801290:	75 b6                	jne    801248 <fd_alloc+0x1a>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801292:	8b 45 08             	mov    0x8(%ebp),%eax
  801295:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  80129b:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8012a0:	5d                   	pop    %ebp
  8012a1:	c3                   	ret    

008012a2 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8012a2:	55                   	push   %ebp
  8012a3:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8012a5:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
  8012a9:	77 39                	ja     8012e4 <fd_lookup+0x42>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8012ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8012ae:	c1 e0 0c             	shl    $0xc,%eax
  8012b1:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8012b6:	89 c2                	mov    %eax,%edx
  8012b8:	c1 ea 16             	shr    $0x16,%edx
  8012bb:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012c2:	f6 c2 01             	test   $0x1,%dl
  8012c5:	74 24                	je     8012eb <fd_lookup+0x49>
  8012c7:	89 c2                	mov    %eax,%edx
  8012c9:	c1 ea 0c             	shr    $0xc,%edx
  8012cc:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012d3:	f6 c2 01             	test   $0x1,%dl
  8012d6:	74 1a                	je     8012f2 <fd_lookup+0x50>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8012d8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012db:	89 02                	mov    %eax,(%edx)
	return 0;
  8012dd:	b8 00 00 00 00       	mov    $0x0,%eax
  8012e2:	eb 13                	jmp    8012f7 <fd_lookup+0x55>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012e4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012e9:	eb 0c                	jmp    8012f7 <fd_lookup+0x55>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012eb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012f0:	eb 05                	jmp    8012f7 <fd_lookup+0x55>
  8012f2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8012f7:	5d                   	pop    %ebp
  8012f8:	c3                   	ret    

008012f9 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8012f9:	55                   	push   %ebp
  8012fa:	89 e5                	mov    %esp,%ebp
  8012fc:	53                   	push   %ebx
  8012fd:	83 ec 04             	sub    $0x4,%esp
  801300:	8b 45 08             	mov    0x8(%ebp),%eax
  801303:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  801306:	3b 05 04 30 80 00    	cmp    0x803004,%eax
  80130c:	75 1e                	jne    80132c <dev_lookup+0x33>
  80130e:	eb 0e                	jmp    80131e <dev_lookup+0x25>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801310:	b8 20 30 80 00       	mov    $0x803020,%eax
  801315:	eb 0c                	jmp    801323 <dev_lookup+0x2a>
  801317:	b8 3c 30 80 00       	mov    $0x80303c,%eax
  80131c:	eb 05                	jmp    801323 <dev_lookup+0x2a>
  80131e:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  801323:	89 03                	mov    %eax,(%ebx)
			return 0;
  801325:	b8 00 00 00 00       	mov    $0x0,%eax
  80132a:	eb 36                	jmp    801362 <dev_lookup+0x69>
int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  80132c:	3b 05 20 30 80 00    	cmp    0x803020,%eax
  801332:	74 dc                	je     801310 <dev_lookup+0x17>
  801334:	3b 05 3c 30 80 00    	cmp    0x80303c,%eax
  80133a:	74 db                	je     801317 <dev_lookup+0x1e>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80133c:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801342:	8b 52 48             	mov    0x48(%edx),%edx
  801345:	83 ec 04             	sub    $0x4,%esp
  801348:	50                   	push   %eax
  801349:	52                   	push   %edx
  80134a:	68 b4 26 80 00       	push   $0x8026b4
  80134f:	e8 63 ee ff ff       	call   8001b7 <cprintf>
	*dev = 0;
  801354:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  80135a:	83 c4 10             	add    $0x10,%esp
  80135d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801362:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801365:	c9                   	leave  
  801366:	c3                   	ret    

00801367 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801367:	55                   	push   %ebp
  801368:	89 e5                	mov    %esp,%ebp
  80136a:	56                   	push   %esi
  80136b:	53                   	push   %ebx
  80136c:	83 ec 10             	sub    $0x10,%esp
  80136f:	8b 75 08             	mov    0x8(%ebp),%esi
  801372:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801375:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801378:	50                   	push   %eax
  801379:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80137f:	c1 e8 0c             	shr    $0xc,%eax
  801382:	50                   	push   %eax
  801383:	e8 1a ff ff ff       	call   8012a2 <fd_lookup>
  801388:	83 c4 08             	add    $0x8,%esp
  80138b:	85 c0                	test   %eax,%eax
  80138d:	78 05                	js     801394 <fd_close+0x2d>
	    || fd != fd2)
  80138f:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801392:	74 06                	je     80139a <fd_close+0x33>
		return (must_exist ? r : 0);
  801394:	84 db                	test   %bl,%bl
  801396:	74 47                	je     8013df <fd_close+0x78>
  801398:	eb 4a                	jmp    8013e4 <fd_close+0x7d>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80139a:	83 ec 08             	sub    $0x8,%esp
  80139d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013a0:	50                   	push   %eax
  8013a1:	ff 36                	pushl  (%esi)
  8013a3:	e8 51 ff ff ff       	call   8012f9 <dev_lookup>
  8013a8:	89 c3                	mov    %eax,%ebx
  8013aa:	83 c4 10             	add    $0x10,%esp
  8013ad:	85 c0                	test   %eax,%eax
  8013af:	78 1c                	js     8013cd <fd_close+0x66>
		if (dev->dev_close)
  8013b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013b4:	8b 40 10             	mov    0x10(%eax),%eax
  8013b7:	85 c0                	test   %eax,%eax
  8013b9:	74 0d                	je     8013c8 <fd_close+0x61>
			r = (*dev->dev_close)(fd);
  8013bb:	83 ec 0c             	sub    $0xc,%esp
  8013be:	56                   	push   %esi
  8013bf:	ff d0                	call   *%eax
  8013c1:	89 c3                	mov    %eax,%ebx
  8013c3:	83 c4 10             	add    $0x10,%esp
  8013c6:	eb 05                	jmp    8013cd <fd_close+0x66>
		else
			r = 0;
  8013c8:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8013cd:	83 ec 08             	sub    $0x8,%esp
  8013d0:	56                   	push   %esi
  8013d1:	6a 00                	push   $0x0
  8013d3:	e8 b9 f8 ff ff       	call   800c91 <sys_page_unmap>
	return r;
  8013d8:	83 c4 10             	add    $0x10,%esp
  8013db:	89 d8                	mov    %ebx,%eax
  8013dd:	eb 05                	jmp    8013e4 <fd_close+0x7d>
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
  8013df:	b8 00 00 00 00       	mov    $0x0,%eax
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
	return r;
}
  8013e4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013e7:	5b                   	pop    %ebx
  8013e8:	5e                   	pop    %esi
  8013e9:	5d                   	pop    %ebp
  8013ea:	c3                   	ret    

008013eb <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8013eb:	55                   	push   %ebp
  8013ec:	89 e5                	mov    %esp,%ebp
  8013ee:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013f1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013f4:	50                   	push   %eax
  8013f5:	ff 75 08             	pushl  0x8(%ebp)
  8013f8:	e8 a5 fe ff ff       	call   8012a2 <fd_lookup>
  8013fd:	83 c4 08             	add    $0x8,%esp
  801400:	85 c0                	test   %eax,%eax
  801402:	78 10                	js     801414 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801404:	83 ec 08             	sub    $0x8,%esp
  801407:	6a 01                	push   $0x1
  801409:	ff 75 f4             	pushl  -0xc(%ebp)
  80140c:	e8 56 ff ff ff       	call   801367 <fd_close>
  801411:	83 c4 10             	add    $0x10,%esp
}
  801414:	c9                   	leave  
  801415:	c3                   	ret    

00801416 <close_all>:

void
close_all(void)
{
  801416:	55                   	push   %ebp
  801417:	89 e5                	mov    %esp,%ebp
  801419:	53                   	push   %ebx
  80141a:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80141d:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801422:	83 ec 0c             	sub    $0xc,%esp
  801425:	53                   	push   %ebx
  801426:	e8 c0 ff ff ff       	call   8013eb <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80142b:	43                   	inc    %ebx
  80142c:	83 c4 10             	add    $0x10,%esp
  80142f:	83 fb 20             	cmp    $0x20,%ebx
  801432:	75 ee                	jne    801422 <close_all+0xc>
		close(i);
}
  801434:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801437:	c9                   	leave  
  801438:	c3                   	ret    

00801439 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801439:	55                   	push   %ebp
  80143a:	89 e5                	mov    %esp,%ebp
  80143c:	57                   	push   %edi
  80143d:	56                   	push   %esi
  80143e:	53                   	push   %ebx
  80143f:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801442:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801445:	50                   	push   %eax
  801446:	ff 75 08             	pushl  0x8(%ebp)
  801449:	e8 54 fe ff ff       	call   8012a2 <fd_lookup>
  80144e:	83 c4 08             	add    $0x8,%esp
  801451:	85 c0                	test   %eax,%eax
  801453:	0f 88 c2 00 00 00    	js     80151b <dup+0xe2>
		return r;
	close(newfdnum);
  801459:	83 ec 0c             	sub    $0xc,%esp
  80145c:	ff 75 0c             	pushl  0xc(%ebp)
  80145f:	e8 87 ff ff ff       	call   8013eb <close>

	newfd = INDEX2FD(newfdnum);
  801464:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801467:	c1 e3 0c             	shl    $0xc,%ebx
  80146a:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801470:	83 c4 04             	add    $0x4,%esp
  801473:	ff 75 e4             	pushl  -0x1c(%ebp)
  801476:	e8 9c fd ff ff       	call   801217 <fd2data>
  80147b:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  80147d:	89 1c 24             	mov    %ebx,(%esp)
  801480:	e8 92 fd ff ff       	call   801217 <fd2data>
  801485:	83 c4 10             	add    $0x10,%esp
  801488:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80148a:	89 f0                	mov    %esi,%eax
  80148c:	c1 e8 16             	shr    $0x16,%eax
  80148f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801496:	a8 01                	test   $0x1,%al
  801498:	74 35                	je     8014cf <dup+0x96>
  80149a:	89 f0                	mov    %esi,%eax
  80149c:	c1 e8 0c             	shr    $0xc,%eax
  80149f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8014a6:	f6 c2 01             	test   $0x1,%dl
  8014a9:	74 24                	je     8014cf <dup+0x96>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8014ab:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014b2:	83 ec 0c             	sub    $0xc,%esp
  8014b5:	25 07 0e 00 00       	and    $0xe07,%eax
  8014ba:	50                   	push   %eax
  8014bb:	57                   	push   %edi
  8014bc:	6a 00                	push   $0x0
  8014be:	56                   	push   %esi
  8014bf:	6a 00                	push   $0x0
  8014c1:	e8 89 f7 ff ff       	call   800c4f <sys_page_map>
  8014c6:	89 c6                	mov    %eax,%esi
  8014c8:	83 c4 20             	add    $0x20,%esp
  8014cb:	85 c0                	test   %eax,%eax
  8014cd:	78 2c                	js     8014fb <dup+0xc2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014cf:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8014d2:	89 d0                	mov    %edx,%eax
  8014d4:	c1 e8 0c             	shr    $0xc,%eax
  8014d7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014de:	83 ec 0c             	sub    $0xc,%esp
  8014e1:	25 07 0e 00 00       	and    $0xe07,%eax
  8014e6:	50                   	push   %eax
  8014e7:	53                   	push   %ebx
  8014e8:	6a 00                	push   $0x0
  8014ea:	52                   	push   %edx
  8014eb:	6a 00                	push   $0x0
  8014ed:	e8 5d f7 ff ff       	call   800c4f <sys_page_map>
  8014f2:	89 c6                	mov    %eax,%esi
  8014f4:	83 c4 20             	add    $0x20,%esp
  8014f7:	85 c0                	test   %eax,%eax
  8014f9:	79 1d                	jns    801518 <dup+0xdf>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8014fb:	83 ec 08             	sub    $0x8,%esp
  8014fe:	53                   	push   %ebx
  8014ff:	6a 00                	push   $0x0
  801501:	e8 8b f7 ff ff       	call   800c91 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801506:	83 c4 08             	add    $0x8,%esp
  801509:	57                   	push   %edi
  80150a:	6a 00                	push   $0x0
  80150c:	e8 80 f7 ff ff       	call   800c91 <sys_page_unmap>
	return r;
  801511:	83 c4 10             	add    $0x10,%esp
  801514:	89 f0                	mov    %esi,%eax
  801516:	eb 03                	jmp    80151b <dup+0xe2>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801518:	8b 45 0c             	mov    0xc(%ebp),%eax

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80151b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80151e:	5b                   	pop    %ebx
  80151f:	5e                   	pop    %esi
  801520:	5f                   	pop    %edi
  801521:	5d                   	pop    %ebp
  801522:	c3                   	ret    

00801523 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801523:	55                   	push   %ebp
  801524:	89 e5                	mov    %esp,%ebp
  801526:	53                   	push   %ebx
  801527:	83 ec 14             	sub    $0x14,%esp
  80152a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80152d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801530:	50                   	push   %eax
  801531:	53                   	push   %ebx
  801532:	e8 6b fd ff ff       	call   8012a2 <fd_lookup>
  801537:	83 c4 08             	add    $0x8,%esp
  80153a:	85 c0                	test   %eax,%eax
  80153c:	78 67                	js     8015a5 <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80153e:	83 ec 08             	sub    $0x8,%esp
  801541:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801544:	50                   	push   %eax
  801545:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801548:	ff 30                	pushl  (%eax)
  80154a:	e8 aa fd ff ff       	call   8012f9 <dev_lookup>
  80154f:	83 c4 10             	add    $0x10,%esp
  801552:	85 c0                	test   %eax,%eax
  801554:	78 4f                	js     8015a5 <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801556:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801559:	8b 42 08             	mov    0x8(%edx),%eax
  80155c:	83 e0 03             	and    $0x3,%eax
  80155f:	83 f8 01             	cmp    $0x1,%eax
  801562:	75 21                	jne    801585 <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801564:	a1 04 40 80 00       	mov    0x804004,%eax
  801569:	8b 40 48             	mov    0x48(%eax),%eax
  80156c:	83 ec 04             	sub    $0x4,%esp
  80156f:	53                   	push   %ebx
  801570:	50                   	push   %eax
  801571:	68 f5 26 80 00       	push   $0x8026f5
  801576:	e8 3c ec ff ff       	call   8001b7 <cprintf>
		return -E_INVAL;
  80157b:	83 c4 10             	add    $0x10,%esp
  80157e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801583:	eb 20                	jmp    8015a5 <read+0x82>
	}
	if (!dev->dev_read)
  801585:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801588:	8b 40 08             	mov    0x8(%eax),%eax
  80158b:	85 c0                	test   %eax,%eax
  80158d:	74 11                	je     8015a0 <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80158f:	83 ec 04             	sub    $0x4,%esp
  801592:	ff 75 10             	pushl  0x10(%ebp)
  801595:	ff 75 0c             	pushl  0xc(%ebp)
  801598:	52                   	push   %edx
  801599:	ff d0                	call   *%eax
  80159b:	83 c4 10             	add    $0x10,%esp
  80159e:	eb 05                	jmp    8015a5 <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8015a0:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8015a5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015a8:	c9                   	leave  
  8015a9:	c3                   	ret    

008015aa <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8015aa:	55                   	push   %ebp
  8015ab:	89 e5                	mov    %esp,%ebp
  8015ad:	57                   	push   %edi
  8015ae:	56                   	push   %esi
  8015af:	53                   	push   %ebx
  8015b0:	83 ec 0c             	sub    $0xc,%esp
  8015b3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8015b6:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015b9:	85 f6                	test   %esi,%esi
  8015bb:	74 31                	je     8015ee <readn+0x44>
  8015bd:	b8 00 00 00 00       	mov    $0x0,%eax
  8015c2:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  8015c7:	83 ec 04             	sub    $0x4,%esp
  8015ca:	89 f2                	mov    %esi,%edx
  8015cc:	29 c2                	sub    %eax,%edx
  8015ce:	52                   	push   %edx
  8015cf:	03 45 0c             	add    0xc(%ebp),%eax
  8015d2:	50                   	push   %eax
  8015d3:	57                   	push   %edi
  8015d4:	e8 4a ff ff ff       	call   801523 <read>
		if (m < 0)
  8015d9:	83 c4 10             	add    $0x10,%esp
  8015dc:	85 c0                	test   %eax,%eax
  8015de:	78 17                	js     8015f7 <readn+0x4d>
			return m;
		if (m == 0)
  8015e0:	85 c0                	test   %eax,%eax
  8015e2:	74 11                	je     8015f5 <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015e4:	01 c3                	add    %eax,%ebx
  8015e6:	89 d8                	mov    %ebx,%eax
  8015e8:	39 f3                	cmp    %esi,%ebx
  8015ea:	72 db                	jb     8015c7 <readn+0x1d>
  8015ec:	eb 09                	jmp    8015f7 <readn+0x4d>
  8015ee:	b8 00 00 00 00       	mov    $0x0,%eax
  8015f3:	eb 02                	jmp    8015f7 <readn+0x4d>
  8015f5:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8015f7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015fa:	5b                   	pop    %ebx
  8015fb:	5e                   	pop    %esi
  8015fc:	5f                   	pop    %edi
  8015fd:	5d                   	pop    %ebp
  8015fe:	c3                   	ret    

008015ff <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8015ff:	55                   	push   %ebp
  801600:	89 e5                	mov    %esp,%ebp
  801602:	53                   	push   %ebx
  801603:	83 ec 14             	sub    $0x14,%esp
  801606:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801609:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80160c:	50                   	push   %eax
  80160d:	53                   	push   %ebx
  80160e:	e8 8f fc ff ff       	call   8012a2 <fd_lookup>
  801613:	83 c4 08             	add    $0x8,%esp
  801616:	85 c0                	test   %eax,%eax
  801618:	78 62                	js     80167c <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80161a:	83 ec 08             	sub    $0x8,%esp
  80161d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801620:	50                   	push   %eax
  801621:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801624:	ff 30                	pushl  (%eax)
  801626:	e8 ce fc ff ff       	call   8012f9 <dev_lookup>
  80162b:	83 c4 10             	add    $0x10,%esp
  80162e:	85 c0                	test   %eax,%eax
  801630:	78 4a                	js     80167c <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801632:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801635:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801639:	75 21                	jne    80165c <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80163b:	a1 04 40 80 00       	mov    0x804004,%eax
  801640:	8b 40 48             	mov    0x48(%eax),%eax
  801643:	83 ec 04             	sub    $0x4,%esp
  801646:	53                   	push   %ebx
  801647:	50                   	push   %eax
  801648:	68 11 27 80 00       	push   $0x802711
  80164d:	e8 65 eb ff ff       	call   8001b7 <cprintf>
		return -E_INVAL;
  801652:	83 c4 10             	add    $0x10,%esp
  801655:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80165a:	eb 20                	jmp    80167c <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80165c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80165f:	8b 52 0c             	mov    0xc(%edx),%edx
  801662:	85 d2                	test   %edx,%edx
  801664:	74 11                	je     801677 <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801666:	83 ec 04             	sub    $0x4,%esp
  801669:	ff 75 10             	pushl  0x10(%ebp)
  80166c:	ff 75 0c             	pushl  0xc(%ebp)
  80166f:	50                   	push   %eax
  801670:	ff d2                	call   *%edx
  801672:	83 c4 10             	add    $0x10,%esp
  801675:	eb 05                	jmp    80167c <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801677:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  80167c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80167f:	c9                   	leave  
  801680:	c3                   	ret    

00801681 <seek>:

int
seek(int fdnum, off_t offset)
{
  801681:	55                   	push   %ebp
  801682:	89 e5                	mov    %esp,%ebp
  801684:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801687:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80168a:	50                   	push   %eax
  80168b:	ff 75 08             	pushl  0x8(%ebp)
  80168e:	e8 0f fc ff ff       	call   8012a2 <fd_lookup>
  801693:	83 c4 08             	add    $0x8,%esp
  801696:	85 c0                	test   %eax,%eax
  801698:	78 0e                	js     8016a8 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80169a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80169d:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016a0:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8016a3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016a8:	c9                   	leave  
  8016a9:	c3                   	ret    

008016aa <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8016aa:	55                   	push   %ebp
  8016ab:	89 e5                	mov    %esp,%ebp
  8016ad:	53                   	push   %ebx
  8016ae:	83 ec 14             	sub    $0x14,%esp
  8016b1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016b4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016b7:	50                   	push   %eax
  8016b8:	53                   	push   %ebx
  8016b9:	e8 e4 fb ff ff       	call   8012a2 <fd_lookup>
  8016be:	83 c4 08             	add    $0x8,%esp
  8016c1:	85 c0                	test   %eax,%eax
  8016c3:	78 5f                	js     801724 <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016c5:	83 ec 08             	sub    $0x8,%esp
  8016c8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016cb:	50                   	push   %eax
  8016cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016cf:	ff 30                	pushl  (%eax)
  8016d1:	e8 23 fc ff ff       	call   8012f9 <dev_lookup>
  8016d6:	83 c4 10             	add    $0x10,%esp
  8016d9:	85 c0                	test   %eax,%eax
  8016db:	78 47                	js     801724 <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016e0:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016e4:	75 21                	jne    801707 <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8016e6:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8016eb:	8b 40 48             	mov    0x48(%eax),%eax
  8016ee:	83 ec 04             	sub    $0x4,%esp
  8016f1:	53                   	push   %ebx
  8016f2:	50                   	push   %eax
  8016f3:	68 d4 26 80 00       	push   $0x8026d4
  8016f8:	e8 ba ea ff ff       	call   8001b7 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8016fd:	83 c4 10             	add    $0x10,%esp
  801700:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801705:	eb 1d                	jmp    801724 <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  801707:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80170a:	8b 52 18             	mov    0x18(%edx),%edx
  80170d:	85 d2                	test   %edx,%edx
  80170f:	74 0e                	je     80171f <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801711:	83 ec 08             	sub    $0x8,%esp
  801714:	ff 75 0c             	pushl  0xc(%ebp)
  801717:	50                   	push   %eax
  801718:	ff d2                	call   *%edx
  80171a:	83 c4 10             	add    $0x10,%esp
  80171d:	eb 05                	jmp    801724 <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80171f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801724:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801727:	c9                   	leave  
  801728:	c3                   	ret    

00801729 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801729:	55                   	push   %ebp
  80172a:	89 e5                	mov    %esp,%ebp
  80172c:	53                   	push   %ebx
  80172d:	83 ec 14             	sub    $0x14,%esp
  801730:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801733:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801736:	50                   	push   %eax
  801737:	ff 75 08             	pushl  0x8(%ebp)
  80173a:	e8 63 fb ff ff       	call   8012a2 <fd_lookup>
  80173f:	83 c4 08             	add    $0x8,%esp
  801742:	85 c0                	test   %eax,%eax
  801744:	78 52                	js     801798 <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801746:	83 ec 08             	sub    $0x8,%esp
  801749:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80174c:	50                   	push   %eax
  80174d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801750:	ff 30                	pushl  (%eax)
  801752:	e8 a2 fb ff ff       	call   8012f9 <dev_lookup>
  801757:	83 c4 10             	add    $0x10,%esp
  80175a:	85 c0                	test   %eax,%eax
  80175c:	78 3a                	js     801798 <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  80175e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801761:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801765:	74 2c                	je     801793 <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801767:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80176a:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801771:	00 00 00 
	stat->st_isdir = 0;
  801774:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80177b:	00 00 00 
	stat->st_dev = dev;
  80177e:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801784:	83 ec 08             	sub    $0x8,%esp
  801787:	53                   	push   %ebx
  801788:	ff 75 f0             	pushl  -0x10(%ebp)
  80178b:	ff 50 14             	call   *0x14(%eax)
  80178e:	83 c4 10             	add    $0x10,%esp
  801791:	eb 05                	jmp    801798 <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801793:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801798:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80179b:	c9                   	leave  
  80179c:	c3                   	ret    

0080179d <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80179d:	55                   	push   %ebp
  80179e:	89 e5                	mov    %esp,%ebp
  8017a0:	56                   	push   %esi
  8017a1:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8017a2:	83 ec 08             	sub    $0x8,%esp
  8017a5:	6a 00                	push   $0x0
  8017a7:	ff 75 08             	pushl  0x8(%ebp)
  8017aa:	e8 75 01 00 00       	call   801924 <open>
  8017af:	89 c3                	mov    %eax,%ebx
  8017b1:	83 c4 10             	add    $0x10,%esp
  8017b4:	85 c0                	test   %eax,%eax
  8017b6:	78 1d                	js     8017d5 <stat+0x38>
		return fd;
	r = fstat(fd, stat);
  8017b8:	83 ec 08             	sub    $0x8,%esp
  8017bb:	ff 75 0c             	pushl  0xc(%ebp)
  8017be:	50                   	push   %eax
  8017bf:	e8 65 ff ff ff       	call   801729 <fstat>
  8017c4:	89 c6                	mov    %eax,%esi
	close(fd);
  8017c6:	89 1c 24             	mov    %ebx,(%esp)
  8017c9:	e8 1d fc ff ff       	call   8013eb <close>
	return r;
  8017ce:	83 c4 10             	add    $0x10,%esp
  8017d1:	89 f0                	mov    %esi,%eax
  8017d3:	eb 00                	jmp    8017d5 <stat+0x38>
}
  8017d5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017d8:	5b                   	pop    %ebx
  8017d9:	5e                   	pop    %esi
  8017da:	5d                   	pop    %ebp
  8017db:	c3                   	ret    

008017dc <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8017dc:	55                   	push   %ebp
  8017dd:	89 e5                	mov    %esp,%ebp
  8017df:	56                   	push   %esi
  8017e0:	53                   	push   %ebx
  8017e1:	89 c6                	mov    %eax,%esi
  8017e3:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8017e5:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8017ec:	75 12                	jne    801800 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8017ee:	83 ec 0c             	sub    $0xc,%esp
  8017f1:	6a 01                	push   $0x1
  8017f3:	e8 b4 f9 ff ff       	call   8011ac <ipc_find_env>
  8017f8:	a3 00 40 80 00       	mov    %eax,0x804000
  8017fd:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801800:	6a 07                	push   $0x7
  801802:	68 00 50 80 00       	push   $0x805000
  801807:	56                   	push   %esi
  801808:	ff 35 00 40 80 00    	pushl  0x804000
  80180e:	e8 3a f9 ff ff       	call   80114d <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801813:	83 c4 0c             	add    $0xc,%esp
  801816:	6a 00                	push   $0x0
  801818:	53                   	push   %ebx
  801819:	6a 00                	push   $0x0
  80181b:	e8 b8 f8 ff ff       	call   8010d8 <ipc_recv>
}
  801820:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801823:	5b                   	pop    %ebx
  801824:	5e                   	pop    %esi
  801825:	5d                   	pop    %ebp
  801826:	c3                   	ret    

00801827 <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801827:	55                   	push   %ebp
  801828:	89 e5                	mov    %esp,%ebp
  80182a:	53                   	push   %ebx
  80182b:	83 ec 04             	sub    $0x4,%esp
  80182e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801831:	8b 45 08             	mov    0x8(%ebp),%eax
  801834:	8b 40 0c             	mov    0xc(%eax),%eax
  801837:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80183c:	ba 00 00 00 00       	mov    $0x0,%edx
  801841:	b8 05 00 00 00       	mov    $0x5,%eax
  801846:	e8 91 ff ff ff       	call   8017dc <fsipc>
  80184b:	85 c0                	test   %eax,%eax
  80184d:	78 2c                	js     80187b <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80184f:	83 ec 08             	sub    $0x8,%esp
  801852:	68 00 50 80 00       	push   $0x805000
  801857:	53                   	push   %ebx
  801858:	e8 3f ef ff ff       	call   80079c <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80185d:	a1 80 50 80 00       	mov    0x805080,%eax
  801862:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801868:	a1 84 50 80 00       	mov    0x805084,%eax
  80186d:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801873:	83 c4 10             	add    $0x10,%esp
  801876:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80187b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80187e:	c9                   	leave  
  80187f:	c3                   	ret    

00801880 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801880:	55                   	push   %ebp
  801881:	89 e5                	mov    %esp,%ebp
  801883:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801886:	8b 45 08             	mov    0x8(%ebp),%eax
  801889:	8b 40 0c             	mov    0xc(%eax),%eax
  80188c:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801891:	ba 00 00 00 00       	mov    $0x0,%edx
  801896:	b8 06 00 00 00       	mov    $0x6,%eax
  80189b:	e8 3c ff ff ff       	call   8017dc <fsipc>
}
  8018a0:	c9                   	leave  
  8018a1:	c3                   	ret    

008018a2 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8018a2:	55                   	push   %ebp
  8018a3:	89 e5                	mov    %esp,%ebp
  8018a5:	56                   	push   %esi
  8018a6:	53                   	push   %ebx
  8018a7:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8018aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8018ad:	8b 40 0c             	mov    0xc(%eax),%eax
  8018b0:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8018b5:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8018bb:	ba 00 00 00 00       	mov    $0x0,%edx
  8018c0:	b8 03 00 00 00       	mov    $0x3,%eax
  8018c5:	e8 12 ff ff ff       	call   8017dc <fsipc>
  8018ca:	89 c3                	mov    %eax,%ebx
  8018cc:	85 c0                	test   %eax,%eax
  8018ce:	78 4b                	js     80191b <devfile_read+0x79>
		return r;
	assert(r <= n);
  8018d0:	39 c6                	cmp    %eax,%esi
  8018d2:	73 16                	jae    8018ea <devfile_read+0x48>
  8018d4:	68 2e 27 80 00       	push   $0x80272e
  8018d9:	68 35 27 80 00       	push   $0x802735
  8018de:	6a 7a                	push   $0x7a
  8018e0:	68 4a 27 80 00       	push   $0x80274a
  8018e5:	e8 b5 05 00 00       	call   801e9f <_panic>
	assert(r <= PGSIZE);
  8018ea:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8018ef:	7e 16                	jle    801907 <devfile_read+0x65>
  8018f1:	68 55 27 80 00       	push   $0x802755
  8018f6:	68 35 27 80 00       	push   $0x802735
  8018fb:	6a 7b                	push   $0x7b
  8018fd:	68 4a 27 80 00       	push   $0x80274a
  801902:	e8 98 05 00 00       	call   801e9f <_panic>
	memmove(buf, &fsipcbuf, r);
  801907:	83 ec 04             	sub    $0x4,%esp
  80190a:	50                   	push   %eax
  80190b:	68 00 50 80 00       	push   $0x805000
  801910:	ff 75 0c             	pushl  0xc(%ebp)
  801913:	e8 51 f0 ff ff       	call   800969 <memmove>
	return r;
  801918:	83 c4 10             	add    $0x10,%esp
}
  80191b:	89 d8                	mov    %ebx,%eax
  80191d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801920:	5b                   	pop    %ebx
  801921:	5e                   	pop    %esi
  801922:	5d                   	pop    %ebp
  801923:	c3                   	ret    

00801924 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801924:	55                   	push   %ebp
  801925:	89 e5                	mov    %esp,%ebp
  801927:	53                   	push   %ebx
  801928:	83 ec 20             	sub    $0x20,%esp
  80192b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80192e:	53                   	push   %ebx
  80192f:	e8 11 ee ff ff       	call   800745 <strlen>
  801934:	83 c4 10             	add    $0x10,%esp
  801937:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80193c:	7f 63                	jg     8019a1 <open+0x7d>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80193e:	83 ec 0c             	sub    $0xc,%esp
  801941:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801944:	50                   	push   %eax
  801945:	e8 e4 f8 ff ff       	call   80122e <fd_alloc>
  80194a:	83 c4 10             	add    $0x10,%esp
  80194d:	85 c0                	test   %eax,%eax
  80194f:	78 55                	js     8019a6 <open+0x82>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801951:	83 ec 08             	sub    $0x8,%esp
  801954:	53                   	push   %ebx
  801955:	68 00 50 80 00       	push   $0x805000
  80195a:	e8 3d ee ff ff       	call   80079c <strcpy>
	fsipcbuf.open.req_omode = mode;
  80195f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801962:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801967:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80196a:	b8 01 00 00 00       	mov    $0x1,%eax
  80196f:	e8 68 fe ff ff       	call   8017dc <fsipc>
  801974:	89 c3                	mov    %eax,%ebx
  801976:	83 c4 10             	add    $0x10,%esp
  801979:	85 c0                	test   %eax,%eax
  80197b:	79 14                	jns    801991 <open+0x6d>
		fd_close(fd, 0);
  80197d:	83 ec 08             	sub    $0x8,%esp
  801980:	6a 00                	push   $0x0
  801982:	ff 75 f4             	pushl  -0xc(%ebp)
  801985:	e8 dd f9 ff ff       	call   801367 <fd_close>
		return r;
  80198a:	83 c4 10             	add    $0x10,%esp
  80198d:	89 d8                	mov    %ebx,%eax
  80198f:	eb 15                	jmp    8019a6 <open+0x82>
	}

	return fd2num(fd);
  801991:	83 ec 0c             	sub    $0xc,%esp
  801994:	ff 75 f4             	pushl  -0xc(%ebp)
  801997:	e8 6b f8 ff ff       	call   801207 <fd2num>
  80199c:	83 c4 10             	add    $0x10,%esp
  80199f:	eb 05                	jmp    8019a6 <open+0x82>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8019a1:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8019a6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019a9:	c9                   	leave  
  8019aa:	c3                   	ret    

008019ab <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8019ab:	55                   	push   %ebp
  8019ac:	89 e5                	mov    %esp,%ebp
  8019ae:	56                   	push   %esi
  8019af:	53                   	push   %ebx
  8019b0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8019b3:	83 ec 0c             	sub    $0xc,%esp
  8019b6:	ff 75 08             	pushl  0x8(%ebp)
  8019b9:	e8 59 f8 ff ff       	call   801217 <fd2data>
  8019be:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8019c0:	83 c4 08             	add    $0x8,%esp
  8019c3:	68 61 27 80 00       	push   $0x802761
  8019c8:	53                   	push   %ebx
  8019c9:	e8 ce ed ff ff       	call   80079c <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8019ce:	8b 46 04             	mov    0x4(%esi),%eax
  8019d1:	2b 06                	sub    (%esi),%eax
  8019d3:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8019d9:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8019e0:	00 00 00 
	stat->st_dev = &devpipe;
  8019e3:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8019ea:	30 80 00 
	return 0;
}
  8019ed:	b8 00 00 00 00       	mov    $0x0,%eax
  8019f2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019f5:	5b                   	pop    %ebx
  8019f6:	5e                   	pop    %esi
  8019f7:	5d                   	pop    %ebp
  8019f8:	c3                   	ret    

008019f9 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8019f9:	55                   	push   %ebp
  8019fa:	89 e5                	mov    %esp,%ebp
  8019fc:	53                   	push   %ebx
  8019fd:	83 ec 0c             	sub    $0xc,%esp
  801a00:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a03:	53                   	push   %ebx
  801a04:	6a 00                	push   $0x0
  801a06:	e8 86 f2 ff ff       	call   800c91 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a0b:	89 1c 24             	mov    %ebx,(%esp)
  801a0e:	e8 04 f8 ff ff       	call   801217 <fd2data>
  801a13:	83 c4 08             	add    $0x8,%esp
  801a16:	50                   	push   %eax
  801a17:	6a 00                	push   $0x0
  801a19:	e8 73 f2 ff ff       	call   800c91 <sys_page_unmap>
}
  801a1e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a21:	c9                   	leave  
  801a22:	c3                   	ret    

00801a23 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801a23:	55                   	push   %ebp
  801a24:	89 e5                	mov    %esp,%ebp
  801a26:	57                   	push   %edi
  801a27:	56                   	push   %esi
  801a28:	53                   	push   %ebx
  801a29:	83 ec 1c             	sub    $0x1c,%esp
  801a2c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801a2f:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801a31:	a1 04 40 80 00       	mov    0x804004,%eax
  801a36:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801a39:	83 ec 0c             	sub    $0xc,%esp
  801a3c:	ff 75 e0             	pushl  -0x20(%ebp)
  801a3f:	e8 3f 05 00 00       	call   801f83 <pageref>
  801a44:	89 c3                	mov    %eax,%ebx
  801a46:	89 3c 24             	mov    %edi,(%esp)
  801a49:	e8 35 05 00 00       	call   801f83 <pageref>
  801a4e:	83 c4 10             	add    $0x10,%esp
  801a51:	39 c3                	cmp    %eax,%ebx
  801a53:	0f 94 c1             	sete   %cl
  801a56:	0f b6 c9             	movzbl %cl,%ecx
  801a59:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801a5c:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801a62:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801a65:	39 ce                	cmp    %ecx,%esi
  801a67:	74 1b                	je     801a84 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801a69:	39 c3                	cmp    %eax,%ebx
  801a6b:	75 c4                	jne    801a31 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a6d:	8b 42 58             	mov    0x58(%edx),%eax
  801a70:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a73:	50                   	push   %eax
  801a74:	56                   	push   %esi
  801a75:	68 68 27 80 00       	push   $0x802768
  801a7a:	e8 38 e7 ff ff       	call   8001b7 <cprintf>
  801a7f:	83 c4 10             	add    $0x10,%esp
  801a82:	eb ad                	jmp    801a31 <_pipeisclosed+0xe>
	}
}
  801a84:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a87:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a8a:	5b                   	pop    %ebx
  801a8b:	5e                   	pop    %esi
  801a8c:	5f                   	pop    %edi
  801a8d:	5d                   	pop    %ebp
  801a8e:	c3                   	ret    

00801a8f <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a8f:	55                   	push   %ebp
  801a90:	89 e5                	mov    %esp,%ebp
  801a92:	57                   	push   %edi
  801a93:	56                   	push   %esi
  801a94:	53                   	push   %ebx
  801a95:	83 ec 18             	sub    $0x18,%esp
  801a98:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801a9b:	56                   	push   %esi
  801a9c:	e8 76 f7 ff ff       	call   801217 <fd2data>
  801aa1:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801aa3:	83 c4 10             	add    $0x10,%esp
  801aa6:	bf 00 00 00 00       	mov    $0x0,%edi
  801aab:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801aaf:	75 42                	jne    801af3 <devpipe_write+0x64>
  801ab1:	eb 4e                	jmp    801b01 <devpipe_write+0x72>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801ab3:	89 da                	mov    %ebx,%edx
  801ab5:	89 f0                	mov    %esi,%eax
  801ab7:	e8 67 ff ff ff       	call   801a23 <_pipeisclosed>
  801abc:	85 c0                	test   %eax,%eax
  801abe:	75 46                	jne    801b06 <devpipe_write+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801ac0:	e8 28 f1 ff ff       	call   800bed <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801ac5:	8b 53 04             	mov    0x4(%ebx),%edx
  801ac8:	8b 03                	mov    (%ebx),%eax
  801aca:	83 c0 20             	add    $0x20,%eax
  801acd:	39 c2                	cmp    %eax,%edx
  801acf:	73 e2                	jae    801ab3 <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801ad1:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ad4:	8a 0c 38             	mov    (%eax,%edi,1),%cl
  801ad7:	89 d0                	mov    %edx,%eax
  801ad9:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801ade:	79 05                	jns    801ae5 <devpipe_write+0x56>
  801ae0:	48                   	dec    %eax
  801ae1:	83 c8 e0             	or     $0xffffffe0,%eax
  801ae4:	40                   	inc    %eax
  801ae5:	88 4c 03 08          	mov    %cl,0x8(%ebx,%eax,1)
		p->p_wpos++;
  801ae9:	42                   	inc    %edx
  801aea:	89 53 04             	mov    %edx,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801aed:	47                   	inc    %edi
  801aee:	39 7d 10             	cmp    %edi,0x10(%ebp)
  801af1:	74 0e                	je     801b01 <devpipe_write+0x72>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801af3:	8b 53 04             	mov    0x4(%ebx),%edx
  801af6:	8b 03                	mov    (%ebx),%eax
  801af8:	83 c0 20             	add    $0x20,%eax
  801afb:	39 c2                	cmp    %eax,%edx
  801afd:	73 b4                	jae    801ab3 <devpipe_write+0x24>
  801aff:	eb d0                	jmp    801ad1 <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801b01:	8b 45 10             	mov    0x10(%ebp),%eax
  801b04:	eb 05                	jmp    801b0b <devpipe_write+0x7c>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b06:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801b0b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b0e:	5b                   	pop    %ebx
  801b0f:	5e                   	pop    %esi
  801b10:	5f                   	pop    %edi
  801b11:	5d                   	pop    %ebp
  801b12:	c3                   	ret    

00801b13 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b13:	55                   	push   %ebp
  801b14:	89 e5                	mov    %esp,%ebp
  801b16:	57                   	push   %edi
  801b17:	56                   	push   %esi
  801b18:	53                   	push   %ebx
  801b19:	83 ec 18             	sub    $0x18,%esp
  801b1c:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801b1f:	57                   	push   %edi
  801b20:	e8 f2 f6 ff ff       	call   801217 <fd2data>
  801b25:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b27:	83 c4 10             	add    $0x10,%esp
  801b2a:	be 00 00 00 00       	mov    $0x0,%esi
  801b2f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801b33:	75 3d                	jne    801b72 <devpipe_read+0x5f>
  801b35:	eb 48                	jmp    801b7f <devpipe_read+0x6c>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  801b37:	89 f0                	mov    %esi,%eax
  801b39:	eb 4e                	jmp    801b89 <devpipe_read+0x76>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801b3b:	89 da                	mov    %ebx,%edx
  801b3d:	89 f8                	mov    %edi,%eax
  801b3f:	e8 df fe ff ff       	call   801a23 <_pipeisclosed>
  801b44:	85 c0                	test   %eax,%eax
  801b46:	75 3c                	jne    801b84 <devpipe_read+0x71>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801b48:	e8 a0 f0 ff ff       	call   800bed <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801b4d:	8b 03                	mov    (%ebx),%eax
  801b4f:	3b 43 04             	cmp    0x4(%ebx),%eax
  801b52:	74 e7                	je     801b3b <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b54:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801b59:	79 05                	jns    801b60 <devpipe_read+0x4d>
  801b5b:	48                   	dec    %eax
  801b5c:	83 c8 e0             	or     $0xffffffe0,%eax
  801b5f:	40                   	inc    %eax
  801b60:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801b64:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b67:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801b6a:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b6c:	46                   	inc    %esi
  801b6d:	39 75 10             	cmp    %esi,0x10(%ebp)
  801b70:	74 0d                	je     801b7f <devpipe_read+0x6c>
		while (p->p_rpos == p->p_wpos) {
  801b72:	8b 03                	mov    (%ebx),%eax
  801b74:	3b 43 04             	cmp    0x4(%ebx),%eax
  801b77:	75 db                	jne    801b54 <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801b79:	85 f6                	test   %esi,%esi
  801b7b:	75 ba                	jne    801b37 <devpipe_read+0x24>
  801b7d:	eb bc                	jmp    801b3b <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801b7f:	8b 45 10             	mov    0x10(%ebp),%eax
  801b82:	eb 05                	jmp    801b89 <devpipe_read+0x76>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b84:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801b89:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b8c:	5b                   	pop    %ebx
  801b8d:	5e                   	pop    %esi
  801b8e:	5f                   	pop    %edi
  801b8f:	5d                   	pop    %ebp
  801b90:	c3                   	ret    

00801b91 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801b91:	55                   	push   %ebp
  801b92:	89 e5                	mov    %esp,%ebp
  801b94:	56                   	push   %esi
  801b95:	53                   	push   %ebx
  801b96:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801b99:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b9c:	50                   	push   %eax
  801b9d:	e8 8c f6 ff ff       	call   80122e <fd_alloc>
  801ba2:	83 c4 10             	add    $0x10,%esp
  801ba5:	85 c0                	test   %eax,%eax
  801ba7:	0f 88 2a 01 00 00    	js     801cd7 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bad:	83 ec 04             	sub    $0x4,%esp
  801bb0:	68 07 04 00 00       	push   $0x407
  801bb5:	ff 75 f4             	pushl  -0xc(%ebp)
  801bb8:	6a 00                	push   $0x0
  801bba:	e8 4d f0 ff ff       	call   800c0c <sys_page_alloc>
  801bbf:	83 c4 10             	add    $0x10,%esp
  801bc2:	85 c0                	test   %eax,%eax
  801bc4:	0f 88 0d 01 00 00    	js     801cd7 <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801bca:	83 ec 0c             	sub    $0xc,%esp
  801bcd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801bd0:	50                   	push   %eax
  801bd1:	e8 58 f6 ff ff       	call   80122e <fd_alloc>
  801bd6:	89 c3                	mov    %eax,%ebx
  801bd8:	83 c4 10             	add    $0x10,%esp
  801bdb:	85 c0                	test   %eax,%eax
  801bdd:	0f 88 e2 00 00 00    	js     801cc5 <pipe+0x134>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801be3:	83 ec 04             	sub    $0x4,%esp
  801be6:	68 07 04 00 00       	push   $0x407
  801beb:	ff 75 f0             	pushl  -0x10(%ebp)
  801bee:	6a 00                	push   $0x0
  801bf0:	e8 17 f0 ff ff       	call   800c0c <sys_page_alloc>
  801bf5:	89 c3                	mov    %eax,%ebx
  801bf7:	83 c4 10             	add    $0x10,%esp
  801bfa:	85 c0                	test   %eax,%eax
  801bfc:	0f 88 c3 00 00 00    	js     801cc5 <pipe+0x134>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801c02:	83 ec 0c             	sub    $0xc,%esp
  801c05:	ff 75 f4             	pushl  -0xc(%ebp)
  801c08:	e8 0a f6 ff ff       	call   801217 <fd2data>
  801c0d:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c0f:	83 c4 0c             	add    $0xc,%esp
  801c12:	68 07 04 00 00       	push   $0x407
  801c17:	50                   	push   %eax
  801c18:	6a 00                	push   $0x0
  801c1a:	e8 ed ef ff ff       	call   800c0c <sys_page_alloc>
  801c1f:	89 c3                	mov    %eax,%ebx
  801c21:	83 c4 10             	add    $0x10,%esp
  801c24:	85 c0                	test   %eax,%eax
  801c26:	0f 88 89 00 00 00    	js     801cb5 <pipe+0x124>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c2c:	83 ec 0c             	sub    $0xc,%esp
  801c2f:	ff 75 f0             	pushl  -0x10(%ebp)
  801c32:	e8 e0 f5 ff ff       	call   801217 <fd2data>
  801c37:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c3e:	50                   	push   %eax
  801c3f:	6a 00                	push   $0x0
  801c41:	56                   	push   %esi
  801c42:	6a 00                	push   $0x0
  801c44:	e8 06 f0 ff ff       	call   800c4f <sys_page_map>
  801c49:	89 c3                	mov    %eax,%ebx
  801c4b:	83 c4 20             	add    $0x20,%esp
  801c4e:	85 c0                	test   %eax,%eax
  801c50:	78 55                	js     801ca7 <pipe+0x116>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801c52:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c58:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c5b:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801c5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c60:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801c67:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c6d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c70:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801c72:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c75:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801c7c:	83 ec 0c             	sub    $0xc,%esp
  801c7f:	ff 75 f4             	pushl  -0xc(%ebp)
  801c82:	e8 80 f5 ff ff       	call   801207 <fd2num>
  801c87:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c8a:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801c8c:	83 c4 04             	add    $0x4,%esp
  801c8f:	ff 75 f0             	pushl  -0x10(%ebp)
  801c92:	e8 70 f5 ff ff       	call   801207 <fd2num>
  801c97:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c9a:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801c9d:	83 c4 10             	add    $0x10,%esp
  801ca0:	b8 00 00 00 00       	mov    $0x0,%eax
  801ca5:	eb 30                	jmp    801cd7 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  801ca7:	83 ec 08             	sub    $0x8,%esp
  801caa:	56                   	push   %esi
  801cab:	6a 00                	push   $0x0
  801cad:	e8 df ef ff ff       	call   800c91 <sys_page_unmap>
  801cb2:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801cb5:	83 ec 08             	sub    $0x8,%esp
  801cb8:	ff 75 f0             	pushl  -0x10(%ebp)
  801cbb:	6a 00                	push   $0x0
  801cbd:	e8 cf ef ff ff       	call   800c91 <sys_page_unmap>
  801cc2:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801cc5:	83 ec 08             	sub    $0x8,%esp
  801cc8:	ff 75 f4             	pushl  -0xc(%ebp)
  801ccb:	6a 00                	push   $0x0
  801ccd:	e8 bf ef ff ff       	call   800c91 <sys_page_unmap>
  801cd2:	83 c4 10             	add    $0x10,%esp
  801cd5:	89 d8                	mov    %ebx,%eax
    err:
	return r;
}
  801cd7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cda:	5b                   	pop    %ebx
  801cdb:	5e                   	pop    %esi
  801cdc:	5d                   	pop    %ebp
  801cdd:	c3                   	ret    

00801cde <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801cde:	55                   	push   %ebp
  801cdf:	89 e5                	mov    %esp,%ebp
  801ce1:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ce4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ce7:	50                   	push   %eax
  801ce8:	ff 75 08             	pushl  0x8(%ebp)
  801ceb:	e8 b2 f5 ff ff       	call   8012a2 <fd_lookup>
  801cf0:	83 c4 10             	add    $0x10,%esp
  801cf3:	85 c0                	test   %eax,%eax
  801cf5:	78 18                	js     801d0f <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801cf7:	83 ec 0c             	sub    $0xc,%esp
  801cfa:	ff 75 f4             	pushl  -0xc(%ebp)
  801cfd:	e8 15 f5 ff ff       	call   801217 <fd2data>
	return _pipeisclosed(fd, p);
  801d02:	89 c2                	mov    %eax,%edx
  801d04:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d07:	e8 17 fd ff ff       	call   801a23 <_pipeisclosed>
  801d0c:	83 c4 10             	add    $0x10,%esp
}
  801d0f:	c9                   	leave  
  801d10:	c3                   	ret    

00801d11 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801d11:	55                   	push   %ebp
  801d12:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801d14:	b8 00 00 00 00       	mov    $0x0,%eax
  801d19:	5d                   	pop    %ebp
  801d1a:	c3                   	ret    

00801d1b <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801d1b:	55                   	push   %ebp
  801d1c:	89 e5                	mov    %esp,%ebp
  801d1e:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801d21:	68 80 27 80 00       	push   $0x802780
  801d26:	ff 75 0c             	pushl  0xc(%ebp)
  801d29:	e8 6e ea ff ff       	call   80079c <strcpy>
	return 0;
}
  801d2e:	b8 00 00 00 00       	mov    $0x0,%eax
  801d33:	c9                   	leave  
  801d34:	c3                   	ret    

00801d35 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d35:	55                   	push   %ebp
  801d36:	89 e5                	mov    %esp,%ebp
  801d38:	57                   	push   %edi
  801d39:	56                   	push   %esi
  801d3a:	53                   	push   %ebx
  801d3b:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d41:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d45:	74 45                	je     801d8c <devcons_write+0x57>
  801d47:	b8 00 00 00 00       	mov    $0x0,%eax
  801d4c:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d51:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801d57:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801d5a:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  801d5c:	83 fb 7f             	cmp    $0x7f,%ebx
  801d5f:	76 05                	jbe    801d66 <devcons_write+0x31>
			m = sizeof(buf) - 1;
  801d61:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801d66:	83 ec 04             	sub    $0x4,%esp
  801d69:	53                   	push   %ebx
  801d6a:	03 45 0c             	add    0xc(%ebp),%eax
  801d6d:	50                   	push   %eax
  801d6e:	57                   	push   %edi
  801d6f:	e8 f5 eb ff ff       	call   800969 <memmove>
		sys_cputs(buf, m);
  801d74:	83 c4 08             	add    $0x8,%esp
  801d77:	53                   	push   %ebx
  801d78:	57                   	push   %edi
  801d79:	e8 d2 ed ff ff       	call   800b50 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d7e:	01 de                	add    %ebx,%esi
  801d80:	89 f0                	mov    %esi,%eax
  801d82:	83 c4 10             	add    $0x10,%esp
  801d85:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d88:	72 cd                	jb     801d57 <devcons_write+0x22>
  801d8a:	eb 05                	jmp    801d91 <devcons_write+0x5c>
  801d8c:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801d91:	89 f0                	mov    %esi,%eax
  801d93:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d96:	5b                   	pop    %ebx
  801d97:	5e                   	pop    %esi
  801d98:	5f                   	pop    %edi
  801d99:	5d                   	pop    %ebp
  801d9a:	c3                   	ret    

00801d9b <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d9b:	55                   	push   %ebp
  801d9c:	89 e5                	mov    %esp,%ebp
  801d9e:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801da1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801da5:	75 07                	jne    801dae <devcons_read+0x13>
  801da7:	eb 23                	jmp    801dcc <devcons_read+0x31>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801da9:	e8 3f ee ff ff       	call   800bed <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801dae:	e8 bb ed ff ff       	call   800b6e <sys_cgetc>
  801db3:	85 c0                	test   %eax,%eax
  801db5:	74 f2                	je     801da9 <devcons_read+0xe>
		sys_yield();
	if (c < 0)
  801db7:	85 c0                	test   %eax,%eax
  801db9:	78 1d                	js     801dd8 <devcons_read+0x3d>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801dbb:	83 f8 04             	cmp    $0x4,%eax
  801dbe:	74 13                	je     801dd3 <devcons_read+0x38>
		return 0;
	*(char*)vbuf = c;
  801dc0:	8b 55 0c             	mov    0xc(%ebp),%edx
  801dc3:	88 02                	mov    %al,(%edx)
	return 1;
  801dc5:	b8 01 00 00 00       	mov    $0x1,%eax
  801dca:	eb 0c                	jmp    801dd8 <devcons_read+0x3d>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801dcc:	b8 00 00 00 00       	mov    $0x0,%eax
  801dd1:	eb 05                	jmp    801dd8 <devcons_read+0x3d>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801dd3:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801dd8:	c9                   	leave  
  801dd9:	c3                   	ret    

00801dda <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801dda:	55                   	push   %ebp
  801ddb:	89 e5                	mov    %esp,%ebp
  801ddd:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801de0:	8b 45 08             	mov    0x8(%ebp),%eax
  801de3:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801de6:	6a 01                	push   $0x1
  801de8:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801deb:	50                   	push   %eax
  801dec:	e8 5f ed ff ff       	call   800b50 <sys_cputs>
}
  801df1:	83 c4 10             	add    $0x10,%esp
  801df4:	c9                   	leave  
  801df5:	c3                   	ret    

00801df6 <getchar>:

int
getchar(void)
{
  801df6:	55                   	push   %ebp
  801df7:	89 e5                	mov    %esp,%ebp
  801df9:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801dfc:	6a 01                	push   $0x1
  801dfe:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e01:	50                   	push   %eax
  801e02:	6a 00                	push   $0x0
  801e04:	e8 1a f7 ff ff       	call   801523 <read>
	if (r < 0)
  801e09:	83 c4 10             	add    $0x10,%esp
  801e0c:	85 c0                	test   %eax,%eax
  801e0e:	78 0f                	js     801e1f <getchar+0x29>
		return r;
	if (r < 1)
  801e10:	85 c0                	test   %eax,%eax
  801e12:	7e 06                	jle    801e1a <getchar+0x24>
		return -E_EOF;
	return c;
  801e14:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801e18:	eb 05                	jmp    801e1f <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801e1a:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801e1f:	c9                   	leave  
  801e20:	c3                   	ret    

00801e21 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801e21:	55                   	push   %ebp
  801e22:	89 e5                	mov    %esp,%ebp
  801e24:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e27:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e2a:	50                   	push   %eax
  801e2b:	ff 75 08             	pushl  0x8(%ebp)
  801e2e:	e8 6f f4 ff ff       	call   8012a2 <fd_lookup>
  801e33:	83 c4 10             	add    $0x10,%esp
  801e36:	85 c0                	test   %eax,%eax
  801e38:	78 11                	js     801e4b <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801e3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e3d:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e43:	39 10                	cmp    %edx,(%eax)
  801e45:	0f 94 c0             	sete   %al
  801e48:	0f b6 c0             	movzbl %al,%eax
}
  801e4b:	c9                   	leave  
  801e4c:	c3                   	ret    

00801e4d <opencons>:

int
opencons(void)
{
  801e4d:	55                   	push   %ebp
  801e4e:	89 e5                	mov    %esp,%ebp
  801e50:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e53:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e56:	50                   	push   %eax
  801e57:	e8 d2 f3 ff ff       	call   80122e <fd_alloc>
  801e5c:	83 c4 10             	add    $0x10,%esp
  801e5f:	85 c0                	test   %eax,%eax
  801e61:	78 3a                	js     801e9d <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e63:	83 ec 04             	sub    $0x4,%esp
  801e66:	68 07 04 00 00       	push   $0x407
  801e6b:	ff 75 f4             	pushl  -0xc(%ebp)
  801e6e:	6a 00                	push   $0x0
  801e70:	e8 97 ed ff ff       	call   800c0c <sys_page_alloc>
  801e75:	83 c4 10             	add    $0x10,%esp
  801e78:	85 c0                	test   %eax,%eax
  801e7a:	78 21                	js     801e9d <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801e7c:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e82:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e85:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801e87:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e8a:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801e91:	83 ec 0c             	sub    $0xc,%esp
  801e94:	50                   	push   %eax
  801e95:	e8 6d f3 ff ff       	call   801207 <fd2num>
  801e9a:	83 c4 10             	add    $0x10,%esp
}
  801e9d:	c9                   	leave  
  801e9e:	c3                   	ret    

00801e9f <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801e9f:	55                   	push   %ebp
  801ea0:	89 e5                	mov    %esp,%ebp
  801ea2:	56                   	push   %esi
  801ea3:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801ea4:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801ea7:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801ead:	e8 1c ed ff ff       	call   800bce <sys_getenvid>
  801eb2:	83 ec 0c             	sub    $0xc,%esp
  801eb5:	ff 75 0c             	pushl  0xc(%ebp)
  801eb8:	ff 75 08             	pushl  0x8(%ebp)
  801ebb:	56                   	push   %esi
  801ebc:	50                   	push   %eax
  801ebd:	68 8c 27 80 00       	push   $0x80278c
  801ec2:	e8 f0 e2 ff ff       	call   8001b7 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801ec7:	83 c4 18             	add    $0x18,%esp
  801eca:	53                   	push   %ebx
  801ecb:	ff 75 10             	pushl  0x10(%ebp)
  801ece:	e8 93 e2 ff ff       	call   800166 <vcprintf>
	cprintf("\n");
  801ed3:	c7 04 24 eb 25 80 00 	movl   $0x8025eb,(%esp)
  801eda:	e8 d8 e2 ff ff       	call   8001b7 <cprintf>
  801edf:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801ee2:	cc                   	int3   
  801ee3:	eb fd                	jmp    801ee2 <_panic+0x43>

00801ee5 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801ee5:	55                   	push   %ebp
  801ee6:	89 e5                	mov    %esp,%ebp
  801ee8:	53                   	push   %ebx
  801ee9:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (_pgfault_handler == 0) {
  801eec:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801ef3:	75 5b                	jne    801f50 <set_pgfault_handler+0x6b>
		// First time through!
		// LAB 4: Your code here.
		void *va = (void *)(UXSTACKTOP - PGSIZE);
		envid_t eid = sys_getenvid();
  801ef5:	e8 d4 ec ff ff       	call   800bce <sys_getenvid>
  801efa:	89 c3                	mov    %eax,%ebx
		r = sys_page_alloc(eid,va,PTE_P | PTE_U | PTE_W);
  801efc:	83 ec 04             	sub    $0x4,%esp
  801eff:	6a 07                	push   $0x7
  801f01:	68 00 f0 bf ee       	push   $0xeebff000
  801f06:	50                   	push   %eax
  801f07:	e8 00 ed ff ff       	call   800c0c <sys_page_alloc>
		if(r<0) panic("set_pgfault_handler\n");
  801f0c:	83 c4 10             	add    $0x10,%esp
  801f0f:	85 c0                	test   %eax,%eax
  801f11:	79 14                	jns    801f27 <set_pgfault_handler+0x42>
  801f13:	83 ec 04             	sub    $0x4,%esp
  801f16:	68 b0 27 80 00       	push   $0x8027b0
  801f1b:	6a 23                	push   $0x23
  801f1d:	68 c5 27 80 00       	push   $0x8027c5
  801f22:	e8 78 ff ff ff       	call   801e9f <_panic>
		r = sys_env_set_pgfault_upcall(eid,_pgfault_upcall);
  801f27:	83 ec 08             	sub    $0x8,%esp
  801f2a:	68 5d 1f 80 00       	push   $0x801f5d
  801f2f:	53                   	push   %ebx
  801f30:	e8 22 ee ff ff       	call   800d57 <sys_env_set_pgfault_upcall>
		if(r<0) panic("set_pgfault_handler\n");
  801f35:	83 c4 10             	add    $0x10,%esp
  801f38:	85 c0                	test   %eax,%eax
  801f3a:	79 14                	jns    801f50 <set_pgfault_handler+0x6b>
  801f3c:	83 ec 04             	sub    $0x4,%esp
  801f3f:	68 b0 27 80 00       	push   $0x8027b0
  801f44:	6a 25                	push   $0x25
  801f46:	68 c5 27 80 00       	push   $0x8027c5
  801f4b:	e8 4f ff ff ff       	call   801e9f <_panic>
		// panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801f50:	8b 45 08             	mov    0x8(%ebp),%eax
  801f53:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801f58:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f5b:	c9                   	leave  
  801f5c:	c3                   	ret    

00801f5d <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801f5d:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801f5e:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801f63:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801f65:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl %esp,%ebx
  801f68:	89 e3                	mov    %esp,%ebx
	movl 40(%esp),%eax 	// esp from utf_fault_va to utf_regs(end)
  801f6a:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl 48(%esp),%esp 	// 
  801f6e:	8b 64 24 30          	mov    0x30(%esp),%esp
	pushl %eax
  801f72:	50                   	push   %eax
 
 
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	movl %ebx,%esp
  801f73:	89 dc                	mov    %ebx,%esp
	subl $4,48(%esp)
  801f75:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	popl %eax
  801f7a:	58                   	pop    %eax
	popl %eax
  801f7b:	58                   	pop    %eax
	popal
  801f7c:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	add $4,%esp
  801f7d:	83 c4 04             	add    $0x4,%esp
	popfl
  801f80:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  801f81:	5c                   	pop    %esp
 
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801f82:	c3                   	ret    

00801f83 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f83:	55                   	push   %ebp
  801f84:	89 e5                	mov    %esp,%ebp
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f86:	8b 45 08             	mov    0x8(%ebp),%eax
  801f89:	c1 e8 16             	shr    $0x16,%eax
  801f8c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801f93:	a8 01                	test   $0x1,%al
  801f95:	74 21                	je     801fb8 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f97:	8b 45 08             	mov    0x8(%ebp),%eax
  801f9a:	c1 e8 0c             	shr    $0xc,%eax
  801f9d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801fa4:	a8 01                	test   $0x1,%al
  801fa6:	74 17                	je     801fbf <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801fa8:	c1 e8 0c             	shr    $0xc,%eax
  801fab:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801fb2:	ef 
  801fb3:	0f b7 c0             	movzwl %ax,%eax
  801fb6:	eb 0c                	jmp    801fc4 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801fb8:	b8 00 00 00 00       	mov    $0x0,%eax
  801fbd:	eb 05                	jmp    801fc4 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801fbf:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801fc4:	5d                   	pop    %ebp
  801fc5:	c3                   	ret    
  801fc6:	66 90                	xchg   %ax,%ax

00801fc8 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801fc8:	55                   	push   %ebp
  801fc9:	57                   	push   %edi
  801fca:	56                   	push   %esi
  801fcb:	53                   	push   %ebx
  801fcc:	83 ec 1c             	sub    $0x1c,%esp
  801fcf:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801fd3:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801fd7:	8b 7c 24 38          	mov    0x38(%esp),%edi
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801fdb:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801fdf:	89 ca                	mov    %ecx,%edx
  const DWunion dd = {.ll = d};
  801fe1:	89 f8                	mov    %edi,%eax
  801fe3:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801fe7:	85 f6                	test   %esi,%esi
  801fe9:	75 2d                	jne    802018 <__udivdi3+0x50>
    {
      if (d0 > n1)
  801feb:	39 cf                	cmp    %ecx,%edi
  801fed:	77 65                	ja     802054 <__udivdi3+0x8c>
  801fef:	89 fd                	mov    %edi,%ebp
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801ff1:	85 ff                	test   %edi,%edi
  801ff3:	75 0b                	jne    802000 <__udivdi3+0x38>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801ff5:	b8 01 00 00 00       	mov    $0x1,%eax
  801ffa:	31 d2                	xor    %edx,%edx
  801ffc:	f7 f7                	div    %edi
  801ffe:	89 c5                	mov    %eax,%ebp

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802000:	31 d2                	xor    %edx,%edx
  802002:	89 c8                	mov    %ecx,%eax
  802004:	f7 f5                	div    %ebp
  802006:	89 c1                	mov    %eax,%ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802008:	89 d8                	mov    %ebx,%eax
  80200a:	f7 f5                	div    %ebp
  80200c:	89 cf                	mov    %ecx,%edi
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80200e:	89 fa                	mov    %edi,%edx
  802010:	83 c4 1c             	add    $0x1c,%esp
  802013:	5b                   	pop    %ebx
  802014:	5e                   	pop    %esi
  802015:	5f                   	pop    %edi
  802016:	5d                   	pop    %ebp
  802017:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802018:	39 ce                	cmp    %ecx,%esi
  80201a:	77 28                	ja     802044 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  80201c:	0f bd fe             	bsr    %esi,%edi
	  if (bm == 0)
  80201f:	83 f7 1f             	xor    $0x1f,%edi
  802022:	75 40                	jne    802064 <__udivdi3+0x9c>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802024:	39 ce                	cmp    %ecx,%esi
  802026:	72 0a                	jb     802032 <__udivdi3+0x6a>
  802028:	3b 44 24 08          	cmp    0x8(%esp),%eax
  80202c:	0f 87 9e 00 00 00    	ja     8020d0 <__udivdi3+0x108>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802032:	b8 01 00 00 00       	mov    $0x1,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802037:	89 fa                	mov    %edi,%edx
  802039:	83 c4 1c             	add    $0x1c,%esp
  80203c:	5b                   	pop    %ebx
  80203d:	5e                   	pop    %esi
  80203e:	5f                   	pop    %edi
  80203f:	5d                   	pop    %ebp
  802040:	c3                   	ret    
  802041:	8d 76 00             	lea    0x0(%esi),%esi
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802044:	31 ff                	xor    %edi,%edi
  802046:	31 c0                	xor    %eax,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802048:	89 fa                	mov    %edi,%edx
  80204a:	83 c4 1c             	add    $0x1c,%esp
  80204d:	5b                   	pop    %ebx
  80204e:	5e                   	pop    %esi
  80204f:	5f                   	pop    %edi
  802050:	5d                   	pop    %ebp
  802051:	c3                   	ret    
  802052:	66 90                	xchg   %ax,%ax
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802054:	89 d8                	mov    %ebx,%eax
  802056:	f7 f7                	div    %edi
  802058:	31 ff                	xor    %edi,%edi
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80205a:	89 fa                	mov    %edi,%edx
  80205c:	83 c4 1c             	add    $0x1c,%esp
  80205f:	5b                   	pop    %ebx
  802060:	5e                   	pop    %esi
  802061:	5f                   	pop    %edi
  802062:	5d                   	pop    %ebp
  802063:	c3                   	ret    
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802064:	bd 20 00 00 00       	mov    $0x20,%ebp
  802069:	89 eb                	mov    %ebp,%ebx
  80206b:	29 fb                	sub    %edi,%ebx

	      d1 = (d1 << bm) | (d0 >> b);
  80206d:	89 f9                	mov    %edi,%ecx
  80206f:	d3 e6                	shl    %cl,%esi
  802071:	89 c5                	mov    %eax,%ebp
  802073:	88 d9                	mov    %bl,%cl
  802075:	d3 ed                	shr    %cl,%ebp
  802077:	89 e9                	mov    %ebp,%ecx
  802079:	09 f1                	or     %esi,%ecx
  80207b:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
	      d0 = d0 << bm;
  80207f:	89 f9                	mov    %edi,%ecx
  802081:	d3 e0                	shl    %cl,%eax
  802083:	89 c5                	mov    %eax,%ebp
	      n2 = n1 >> b;
  802085:	89 d6                	mov    %edx,%esi
  802087:	88 d9                	mov    %bl,%cl
  802089:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
  80208b:	89 f9                	mov    %edi,%ecx
  80208d:	d3 e2                	shl    %cl,%edx
  80208f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802093:	88 d9                	mov    %bl,%cl
  802095:	d3 e8                	shr    %cl,%eax
  802097:	09 c2                	or     %eax,%edx
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802099:	89 d0                	mov    %edx,%eax
  80209b:	89 f2                	mov    %esi,%edx
  80209d:	f7 74 24 0c          	divl   0xc(%esp)
  8020a1:	89 d6                	mov    %edx,%esi
  8020a3:	89 c3                	mov    %eax,%ebx
	      umul_ppmm (m1, m0, q0, d0);
  8020a5:	f7 e5                	mul    %ebp

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8020a7:	39 d6                	cmp    %edx,%esi
  8020a9:	72 19                	jb     8020c4 <__udivdi3+0xfc>
  8020ab:	74 0b                	je     8020b8 <__udivdi3+0xf0>
  8020ad:	89 d8                	mov    %ebx,%eax
  8020af:	31 ff                	xor    %edi,%edi
  8020b1:	e9 58 ff ff ff       	jmp    80200e <__udivdi3+0x46>
  8020b6:	66 90                	xchg   %ax,%ax
  8020b8:	8b 54 24 08          	mov    0x8(%esp),%edx
  8020bc:	89 f9                	mov    %edi,%ecx
  8020be:	d3 e2                	shl    %cl,%edx
  8020c0:	39 c2                	cmp    %eax,%edx
  8020c2:	73 e9                	jae    8020ad <__udivdi3+0xe5>
  8020c4:	8d 43 ff             	lea    -0x1(%ebx),%eax
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8020c7:	31 ff                	xor    %edi,%edi
  8020c9:	e9 40 ff ff ff       	jmp    80200e <__udivdi3+0x46>
  8020ce:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8020d0:	31 c0                	xor    %eax,%eax
  8020d2:	e9 37 ff ff ff       	jmp    80200e <__udivdi3+0x46>
  8020d7:	90                   	nop

008020d8 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  8020d8:	55                   	push   %ebp
  8020d9:	57                   	push   %edi
  8020da:	56                   	push   %esi
  8020db:	53                   	push   %ebx
  8020dc:	83 ec 1c             	sub    $0x1c,%esp
  8020df:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8020e3:	8b 74 24 34          	mov    0x34(%esp),%esi
  8020e7:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8020eb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8020ef:	89 44 24 0c          	mov    %eax,0xc(%esp)
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8020f3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8020f7:	89 f3                	mov    %esi,%ebx
  const DWunion dd = {.ll = d};
  8020f9:	89 fa                	mov    %edi,%edx
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  8020fb:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  n1 = nn.s.high;
  8020ff:	89 34 24             	mov    %esi,(%esp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802102:	85 c0                	test   %eax,%eax
  802104:	75 1a                	jne    802120 <__umoddi3+0x48>
    {
      if (d0 > n1)
  802106:	39 f7                	cmp    %esi,%edi
  802108:	0f 86 a2 00 00 00    	jbe    8021b0 <__umoddi3+0xd8>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80210e:	89 c8                	mov    %ecx,%eax
  802110:	89 f2                	mov    %esi,%edx
  802112:	f7 f7                	div    %edi
  802114:	89 d0                	mov    %edx,%eax

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  802116:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802118:	83 c4 1c             	add    $0x1c,%esp
  80211b:	5b                   	pop    %ebx
  80211c:	5e                   	pop    %esi
  80211d:	5f                   	pop    %edi
  80211e:	5d                   	pop    %ebp
  80211f:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802120:	39 f0                	cmp    %esi,%eax
  802122:	0f 87 ac 00 00 00    	ja     8021d4 <__umoddi3+0xfc>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802128:	0f bd e8             	bsr    %eax,%ebp
	  if (bm == 0)
  80212b:	83 f5 1f             	xor    $0x1f,%ebp
  80212e:	0f 84 ac 00 00 00    	je     8021e0 <__umoddi3+0x108>
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802134:	bf 20 00 00 00       	mov    $0x20,%edi
  802139:	29 ef                	sub    %ebp,%edi
  80213b:	89 fe                	mov    %edi,%esi
  80213d:	89 7c 24 0c          	mov    %edi,0xc(%esp)

	      d1 = (d1 << bm) | (d0 >> b);
  802141:	89 e9                	mov    %ebp,%ecx
  802143:	d3 e0                	shl    %cl,%eax
  802145:	89 d7                	mov    %edx,%edi
  802147:	89 f1                	mov    %esi,%ecx
  802149:	d3 ef                	shr    %cl,%edi
  80214b:	09 c7                	or     %eax,%edi
	      d0 = d0 << bm;
  80214d:	89 e9                	mov    %ebp,%ecx
  80214f:	d3 e2                	shl    %cl,%edx
  802151:	89 14 24             	mov    %edx,(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802154:	89 d8                	mov    %ebx,%eax
  802156:	d3 e0                	shl    %cl,%eax
  802158:	89 c2                	mov    %eax,%edx
	      n0 = n0 << bm;
  80215a:	8b 44 24 08          	mov    0x8(%esp),%eax
  80215e:	d3 e0                	shl    %cl,%eax
  802160:	89 44 24 04          	mov    %eax,0x4(%esp)

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802164:	8b 44 24 08          	mov    0x8(%esp),%eax
  802168:	89 f1                	mov    %esi,%ecx
  80216a:	d3 e8                	shr    %cl,%eax
  80216c:	09 d0                	or     %edx,%eax
  80216e:	d3 eb                	shr    %cl,%ebx
  802170:	89 da                	mov    %ebx,%edx
  802172:	f7 f7                	div    %edi
  802174:	89 d3                	mov    %edx,%ebx
	      umul_ppmm (m1, m0, q0, d0);
  802176:	f7 24 24             	mull   (%esp)
  802179:	89 c6                	mov    %eax,%esi
  80217b:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80217d:	39 d3                	cmp    %edx,%ebx
  80217f:	0f 82 87 00 00 00    	jb     80220c <__umoddi3+0x134>
  802185:	0f 84 91 00 00 00    	je     80221c <__umoddi3+0x144>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  80218b:	8b 54 24 04          	mov    0x4(%esp),%edx
  80218f:	29 f2                	sub    %esi,%edx
  802191:	19 cb                	sbb    %ecx,%ebx
		  rr.s.low = (n1 << b) | (n0 >> bm);
  802193:	89 d8                	mov    %ebx,%eax
  802195:	8a 4c 24 0c          	mov    0xc(%esp),%cl
  802199:	d3 e0                	shl    %cl,%eax
  80219b:	89 e9                	mov    %ebp,%ecx
  80219d:	d3 ea                	shr    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  80219f:	09 d0                	or     %edx,%eax
  8021a1:	89 e9                	mov    %ebp,%ecx
  8021a3:	d3 eb                	shr    %cl,%ebx
  8021a5:	89 da                	mov    %ebx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8021a7:	83 c4 1c             	add    $0x1c,%esp
  8021aa:	5b                   	pop    %ebx
  8021ab:	5e                   	pop    %esi
  8021ac:	5f                   	pop    %edi
  8021ad:	5d                   	pop    %ebp
  8021ae:	c3                   	ret    
  8021af:	90                   	nop
  8021b0:	89 fd                	mov    %edi,%ebp
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8021b2:	85 ff                	test   %edi,%edi
  8021b4:	75 0b                	jne    8021c1 <__umoddi3+0xe9>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8021b6:	b8 01 00 00 00       	mov    $0x1,%eax
  8021bb:	31 d2                	xor    %edx,%edx
  8021bd:	f7 f7                	div    %edi
  8021bf:	89 c5                	mov    %eax,%ebp

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8021c1:	89 f0                	mov    %esi,%eax
  8021c3:	31 d2                	xor    %edx,%edx
  8021c5:	f7 f5                	div    %ebp
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8021c7:	89 c8                	mov    %ecx,%eax
  8021c9:	f7 f5                	div    %ebp
  8021cb:	89 d0                	mov    %edx,%eax
  8021cd:	e9 44 ff ff ff       	jmp    802116 <__umoddi3+0x3e>
  8021d2:	66 90                	xchg   %ax,%ax
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  8021d4:	89 c8                	mov    %ecx,%eax
  8021d6:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8021d8:	83 c4 1c             	add    $0x1c,%esp
  8021db:	5b                   	pop    %ebx
  8021dc:	5e                   	pop    %esi
  8021dd:	5f                   	pop    %edi
  8021de:	5d                   	pop    %ebp
  8021df:	c3                   	ret    

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8021e0:	3b 04 24             	cmp    (%esp),%eax
  8021e3:	72 06                	jb     8021eb <__umoddi3+0x113>
  8021e5:	3b 7c 24 04          	cmp    0x4(%esp),%edi
  8021e9:	77 0f                	ja     8021fa <__umoddi3+0x122>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8021eb:	89 f2                	mov    %esi,%edx
  8021ed:	29 f9                	sub    %edi,%ecx
  8021ef:	1b 54 24 0c          	sbb    0xc(%esp),%edx
  8021f3:	89 14 24             	mov    %edx,(%esp)
  8021f6:	89 4c 24 04          	mov    %ecx,0x4(%esp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  8021fa:	8b 44 24 04          	mov    0x4(%esp),%eax
  8021fe:	8b 14 24             	mov    (%esp),%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802201:	83 c4 1c             	add    $0x1c,%esp
  802204:	5b                   	pop    %ebx
  802205:	5e                   	pop    %esi
  802206:	5f                   	pop    %edi
  802207:	5d                   	pop    %ebp
  802208:	c3                   	ret    
  802209:	8d 76 00             	lea    0x0(%esi),%esi
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  80220c:	2b 04 24             	sub    (%esp),%eax
  80220f:	19 fa                	sbb    %edi,%edx
  802211:	89 d1                	mov    %edx,%ecx
  802213:	89 c6                	mov    %eax,%esi
  802215:	e9 71 ff ff ff       	jmp    80218b <__umoddi3+0xb3>
  80221a:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80221c:	39 44 24 04          	cmp    %eax,0x4(%esp)
  802220:	72 ea                	jb     80220c <__umoddi3+0x134>
  802222:	89 d9                	mov    %ebx,%ecx
  802224:	e9 62 ff ff ff       	jmp    80218b <__umoddi3+0xb3>
