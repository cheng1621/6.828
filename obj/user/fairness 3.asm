
obj/user/fairness.debug:     file format elf32-i386


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
  80002c:	e8 70 00 00 00       	call   8000a1 <libmain>
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
  800038:	83 ec 10             	sub    $0x10,%esp
	envid_t who, id;

	id = sys_getenvid();
  80003b:	e8 73 0b 00 00       	call   800bb3 <sys_getenvid>
  800040:	89 c3                	mov    %eax,%ebx

	if (thisenv == &envs[1]) {
  800042:	81 3d 04 40 80 00 7c 	cmpl   $0xeec0007c,0x804004
  800049:	00 c0 ee 
  80004c:	75 26                	jne    800074 <umain+0x41>
		while (1) {
			ipc_recv(&who, 0, 0);
  80004e:	8d 75 f4             	lea    -0xc(%ebp),%esi
  800051:	83 ec 04             	sub    $0x4,%esp
  800054:	6a 00                	push   $0x0
  800056:	6a 00                	push   $0x0
  800058:	56                   	push   %esi
  800059:	e8 84 0d 00 00       	call   800de2 <ipc_recv>
			cprintf("%x recv from %x\n", id, who);
  80005e:	83 c4 0c             	add    $0xc,%esp
  800061:	ff 75 f4             	pushl  -0xc(%ebp)
  800064:	53                   	push   %ebx
  800065:	68 a0 1e 80 00       	push   $0x801ea0
  80006a:	e8 2d 01 00 00       	call   80019c <cprintf>
  80006f:	83 c4 10             	add    $0x10,%esp
  800072:	eb dd                	jmp    800051 <umain+0x1e>
		}
	} else {
		cprintf("%x loop sending to %x\n", id, envs[1].env_id);
  800074:	a1 c4 00 c0 ee       	mov    0xeec000c4,%eax
  800079:	83 ec 04             	sub    $0x4,%esp
  80007c:	50                   	push   %eax
  80007d:	53                   	push   %ebx
  80007e:	68 b1 1e 80 00       	push   $0x801eb1
  800083:	e8 14 01 00 00       	call   80019c <cprintf>
  800088:	83 c4 10             	add    $0x10,%esp
		while (1)
			ipc_send(envs[1].env_id, 0, 0, 0);
  80008b:	a1 c4 00 c0 ee       	mov    0xeec000c4,%eax
  800090:	6a 00                	push   $0x0
  800092:	6a 00                	push   $0x0
  800094:	6a 00                	push   $0x0
  800096:	50                   	push   %eax
  800097:	e8 bb 0d 00 00       	call   800e57 <ipc_send>
  80009c:	83 c4 10             	add    $0x10,%esp
  80009f:	eb ea                	jmp    80008b <umain+0x58>

008000a1 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000a1:	55                   	push   %ebp
  8000a2:	89 e5                	mov    %esp,%ebp
  8000a4:	56                   	push   %esi
  8000a5:	53                   	push   %ebx
  8000a6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000a9:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8000ac:	e8 02 0b 00 00       	call   800bb3 <sys_getenvid>
  8000b1:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000b6:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8000bd:	c1 e0 07             	shl    $0x7,%eax
  8000c0:	29 d0                	sub    %edx,%eax
  8000c2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000c7:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000cc:	85 db                	test   %ebx,%ebx
  8000ce:	7e 07                	jle    8000d7 <libmain+0x36>
		binaryname = argv[0];
  8000d0:	8b 06                	mov    (%esi),%eax
  8000d2:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000d7:	83 ec 08             	sub    $0x8,%esp
  8000da:	56                   	push   %esi
  8000db:	53                   	push   %ebx
  8000dc:	e8 52 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000e1:	e8 0a 00 00 00       	call   8000f0 <exit>
}
  8000e6:	83 c4 10             	add    $0x10,%esp
  8000e9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000ec:	5b                   	pop    %ebx
  8000ed:	5e                   	pop    %esi
  8000ee:	5d                   	pop    %ebp
  8000ef:	c3                   	ret    

008000f0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000f0:	55                   	push   %ebp
  8000f1:	89 e5                	mov    %esp,%ebp
  8000f3:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000f6:	e8 25 10 00 00       	call   801120 <close_all>
	sys_env_destroy(0);
  8000fb:	83 ec 0c             	sub    $0xc,%esp
  8000fe:	6a 00                	push   $0x0
  800100:	e8 6d 0a 00 00       	call   800b72 <sys_env_destroy>
}
  800105:	83 c4 10             	add    $0x10,%esp
  800108:	c9                   	leave  
  800109:	c3                   	ret    

0080010a <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80010a:	55                   	push   %ebp
  80010b:	89 e5                	mov    %esp,%ebp
  80010d:	53                   	push   %ebx
  80010e:	83 ec 04             	sub    $0x4,%esp
  800111:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800114:	8b 13                	mov    (%ebx),%edx
  800116:	8d 42 01             	lea    0x1(%edx),%eax
  800119:	89 03                	mov    %eax,(%ebx)
  80011b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80011e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800122:	3d ff 00 00 00       	cmp    $0xff,%eax
  800127:	75 1a                	jne    800143 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800129:	83 ec 08             	sub    $0x8,%esp
  80012c:	68 ff 00 00 00       	push   $0xff
  800131:	8d 43 08             	lea    0x8(%ebx),%eax
  800134:	50                   	push   %eax
  800135:	e8 fb 09 00 00       	call   800b35 <sys_cputs>
		b->idx = 0;
  80013a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800140:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800143:	ff 43 04             	incl   0x4(%ebx)
}
  800146:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800149:	c9                   	leave  
  80014a:	c3                   	ret    

0080014b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80014b:	55                   	push   %ebp
  80014c:	89 e5                	mov    %esp,%ebp
  80014e:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800154:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80015b:	00 00 00 
	b.cnt = 0;
  80015e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800165:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800168:	ff 75 0c             	pushl  0xc(%ebp)
  80016b:	ff 75 08             	pushl  0x8(%ebp)
  80016e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800174:	50                   	push   %eax
  800175:	68 0a 01 80 00       	push   $0x80010a
  80017a:	e8 54 01 00 00       	call   8002d3 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80017f:	83 c4 08             	add    $0x8,%esp
  800182:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800188:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80018e:	50                   	push   %eax
  80018f:	e8 a1 09 00 00       	call   800b35 <sys_cputs>

	return b.cnt;
}
  800194:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80019a:	c9                   	leave  
  80019b:	c3                   	ret    

0080019c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80019c:	55                   	push   %ebp
  80019d:	89 e5                	mov    %esp,%ebp
  80019f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001a2:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001a5:	50                   	push   %eax
  8001a6:	ff 75 08             	pushl  0x8(%ebp)
  8001a9:	e8 9d ff ff ff       	call   80014b <vcprintf>
	va_end(ap);

	return cnt;
}
  8001ae:	c9                   	leave  
  8001af:	c3                   	ret    

008001b0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001b0:	55                   	push   %ebp
  8001b1:	89 e5                	mov    %esp,%ebp
  8001b3:	57                   	push   %edi
  8001b4:	56                   	push   %esi
  8001b5:	53                   	push   %ebx
  8001b6:	83 ec 1c             	sub    $0x1c,%esp
  8001b9:	89 c6                	mov    %eax,%esi
  8001bb:	89 d7                	mov    %edx,%edi
  8001bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8001c0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001c3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001c6:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001c9:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001cc:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001d1:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001d4:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001d7:	39 d3                	cmp    %edx,%ebx
  8001d9:	72 11                	jb     8001ec <printnum+0x3c>
  8001db:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001de:	76 0c                	jbe    8001ec <printnum+0x3c>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8001e3:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001e6:	85 db                	test   %ebx,%ebx
  8001e8:	7f 37                	jg     800221 <printnum+0x71>
  8001ea:	eb 44                	jmp    800230 <printnum+0x80>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001ec:	83 ec 0c             	sub    $0xc,%esp
  8001ef:	ff 75 18             	pushl  0x18(%ebp)
  8001f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8001f5:	48                   	dec    %eax
  8001f6:	50                   	push   %eax
  8001f7:	ff 75 10             	pushl  0x10(%ebp)
  8001fa:	83 ec 08             	sub    $0x8,%esp
  8001fd:	ff 75 e4             	pushl  -0x1c(%ebp)
  800200:	ff 75 e0             	pushl  -0x20(%ebp)
  800203:	ff 75 dc             	pushl  -0x24(%ebp)
  800206:	ff 75 d8             	pushl  -0x28(%ebp)
  800209:	e8 26 1a 00 00       	call   801c34 <__udivdi3>
  80020e:	83 c4 18             	add    $0x18,%esp
  800211:	52                   	push   %edx
  800212:	50                   	push   %eax
  800213:	89 fa                	mov    %edi,%edx
  800215:	89 f0                	mov    %esi,%eax
  800217:	e8 94 ff ff ff       	call   8001b0 <printnum>
  80021c:	83 c4 20             	add    $0x20,%esp
  80021f:	eb 0f                	jmp    800230 <printnum+0x80>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800221:	83 ec 08             	sub    $0x8,%esp
  800224:	57                   	push   %edi
  800225:	ff 75 18             	pushl  0x18(%ebp)
  800228:	ff d6                	call   *%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80022a:	83 c4 10             	add    $0x10,%esp
  80022d:	4b                   	dec    %ebx
  80022e:	75 f1                	jne    800221 <printnum+0x71>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800230:	83 ec 08             	sub    $0x8,%esp
  800233:	57                   	push   %edi
  800234:	83 ec 04             	sub    $0x4,%esp
  800237:	ff 75 e4             	pushl  -0x1c(%ebp)
  80023a:	ff 75 e0             	pushl  -0x20(%ebp)
  80023d:	ff 75 dc             	pushl  -0x24(%ebp)
  800240:	ff 75 d8             	pushl  -0x28(%ebp)
  800243:	e8 fc 1a 00 00       	call   801d44 <__umoddi3>
  800248:	83 c4 14             	add    $0x14,%esp
  80024b:	0f be 80 d2 1e 80 00 	movsbl 0x801ed2(%eax),%eax
  800252:	50                   	push   %eax
  800253:	ff d6                	call   *%esi
}
  800255:	83 c4 10             	add    $0x10,%esp
  800258:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80025b:	5b                   	pop    %ebx
  80025c:	5e                   	pop    %esi
  80025d:	5f                   	pop    %edi
  80025e:	5d                   	pop    %ebp
  80025f:	c3                   	ret    

00800260 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800260:	55                   	push   %ebp
  800261:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800263:	83 fa 01             	cmp    $0x1,%edx
  800266:	7e 0e                	jle    800276 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800268:	8b 10                	mov    (%eax),%edx
  80026a:	8d 4a 08             	lea    0x8(%edx),%ecx
  80026d:	89 08                	mov    %ecx,(%eax)
  80026f:	8b 02                	mov    (%edx),%eax
  800271:	8b 52 04             	mov    0x4(%edx),%edx
  800274:	eb 22                	jmp    800298 <getuint+0x38>
	else if (lflag)
  800276:	85 d2                	test   %edx,%edx
  800278:	74 10                	je     80028a <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80027a:	8b 10                	mov    (%eax),%edx
  80027c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80027f:	89 08                	mov    %ecx,(%eax)
  800281:	8b 02                	mov    (%edx),%eax
  800283:	ba 00 00 00 00       	mov    $0x0,%edx
  800288:	eb 0e                	jmp    800298 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80028a:	8b 10                	mov    (%eax),%edx
  80028c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80028f:	89 08                	mov    %ecx,(%eax)
  800291:	8b 02                	mov    (%edx),%eax
  800293:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800298:	5d                   	pop    %ebp
  800299:	c3                   	ret    

0080029a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80029a:	55                   	push   %ebp
  80029b:	89 e5                	mov    %esp,%ebp
  80029d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002a0:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8002a3:	8b 10                	mov    (%eax),%edx
  8002a5:	3b 50 04             	cmp    0x4(%eax),%edx
  8002a8:	73 0a                	jae    8002b4 <sprintputch+0x1a>
		*b->buf++ = ch;
  8002aa:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002ad:	89 08                	mov    %ecx,(%eax)
  8002af:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b2:	88 02                	mov    %al,(%edx)
}
  8002b4:	5d                   	pop    %ebp
  8002b5:	c3                   	ret    

008002b6 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002b6:	55                   	push   %ebp
  8002b7:	89 e5                	mov    %esp,%ebp
  8002b9:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002bc:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002bf:	50                   	push   %eax
  8002c0:	ff 75 10             	pushl  0x10(%ebp)
  8002c3:	ff 75 0c             	pushl  0xc(%ebp)
  8002c6:	ff 75 08             	pushl  0x8(%ebp)
  8002c9:	e8 05 00 00 00       	call   8002d3 <vprintfmt>
	va_end(ap);
}
  8002ce:	83 c4 10             	add    $0x10,%esp
  8002d1:	c9                   	leave  
  8002d2:	c3                   	ret    

008002d3 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002d3:	55                   	push   %ebp
  8002d4:	89 e5                	mov    %esp,%ebp
  8002d6:	57                   	push   %edi
  8002d7:	56                   	push   %esi
  8002d8:	53                   	push   %ebx
  8002d9:	83 ec 2c             	sub    $0x2c,%esp
  8002dc:	8b 7d 08             	mov    0x8(%ebp),%edi
  8002df:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002e2:	eb 03                	jmp    8002e7 <vprintfmt+0x14>
			break;

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
			for (fmt--; fmt[-1] != '%'; fmt--)
  8002e4:	89 75 10             	mov    %esi,0x10(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {    //遍历输入的第一个参数，即输出信息的格式，先把格式字符串中'%'之前的字符一个个输出，因为它们前面没有'%'，所以它们就是要直接显示在屏幕上的
  8002e7:	8b 45 10             	mov    0x10(%ebp),%eax
  8002ea:	8d 70 01             	lea    0x1(%eax),%esi
  8002ed:	0f b6 00             	movzbl (%eax),%eax
  8002f0:	83 f8 25             	cmp    $0x25,%eax
  8002f3:	74 25                	je     80031a <vprintfmt+0x47>
			if (ch == '\0')									//当然中间如果遇到'\0'，代表这个字符串的访问结束
  8002f5:	85 c0                	test   %eax,%eax
  8002f7:	75 0d                	jne    800306 <vprintfmt+0x33>
  8002f9:	e9 b5 03 00 00       	jmp    8006b3 <vprintfmt+0x3e0>
  8002fe:	85 c0                	test   %eax,%eax
  800300:	0f 84 ad 03 00 00    	je     8006b3 <vprintfmt+0x3e0>
				return;
			putch(ch, putdat);								//调用putch函数，把一个字符ch输出到putdat指针所指向的地址中所存放的值对应的地址处
  800306:	83 ec 08             	sub    $0x8,%esp
  800309:	53                   	push   %ebx
  80030a:	50                   	push   %eax
  80030b:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {    //遍历输入的第一个参数，即输出信息的格式，先把格式字符串中'%'之前的字符一个个输出，因为它们前面没有'%'，所以它们就是要直接显示在屏幕上的
  80030d:	46                   	inc    %esi
  80030e:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  800312:	83 c4 10             	add    $0x10,%esp
  800315:	83 f8 25             	cmp    $0x25,%eax
  800318:	75 e4                	jne    8002fe <vprintfmt+0x2b>
			if (width < 0)									//代表有小数点，但是小数点前面并没有数字，比如'%.6f'这种情况，此时代表整数部分全部显示
				width = 0;			
			goto reswitch;

		case '#':
			altflag = 1;
  80031a:	c6 45 e3 20          	movb   $0x20,-0x1d(%ebp)
  80031e:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800325:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80032c:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800333:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  80033a:	eb 07                	jmp    800343 <vprintfmt+0x70>
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  80033c:	8b 75 10             	mov    0x10(%ebp),%esi

		// flag to pad on the right
		case '-':											//%后面的'-'代表要进行左对齐输出，右边填空格，如果省略代表右对齐
			padc = '-';										//如果有这个字符代表左对齐，则把对齐方式标志位变为'-'
  80033f:	c6 45 e3 2d          	movb   $0x2d,-0x1d(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  800343:	8d 46 01             	lea    0x1(%esi),%eax
  800346:	89 45 10             	mov    %eax,0x10(%ebp)
  800349:	0f b6 16             	movzbl (%esi),%edx
  80034c:	8a 06                	mov    (%esi),%al
  80034e:	83 e8 23             	sub    $0x23,%eax
  800351:	3c 55                	cmp    $0x55,%al
  800353:	0f 87 03 03 00 00    	ja     80065c <vprintfmt+0x389>
  800359:	0f b6 c0             	movzbl %al,%eax
  80035c:	ff 24 85 20 20 80 00 	jmp    *0x802020(,%eax,4)
  800363:	8b 75 10             	mov    0x10(%ebp),%esi
			padc = '-';										//如果有这个字符代表左对齐，则把对齐方式标志位变为'-'
			goto reswitch;									//处理下一个字符

		// flag to pad with 0's instead of spaces
		case '0':											//0--有0表示进行对齐输出时填0,如省略表示填入空格，并且如果为0，则一定是右对齐
			padc = '0';										//对其方式标志位变为0
  800366:	c6 45 e3 30          	movb   $0x30,-0x1d(%ebp)
  80036a:	eb d7                	jmp    800343 <vprintfmt+0x70>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {					//把遇到的位数字符串转换为真实的位数，比如输入的'%40'，代表有效位数为40位，下面的循环就是把precesion的值设置为40
				precision = precision * 10 + ch - '0';
  80036c:	8d 42 d0             	lea    -0x30(%edx),%eax
  80036f:	89 c1                	mov    %eax,%ecx
  800371:	89 45 d0             	mov    %eax,-0x30(%ebp)
				ch = *fmt;
  800374:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  800378:	8d 50 d0             	lea    -0x30(%eax),%edx
  80037b:	83 fa 09             	cmp    $0x9,%edx
  80037e:	77 51                	ja     8003d1 <vprintfmt+0xfe>
  800380:	8b 75 10             	mov    0x10(%ebp),%esi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {					//把遇到的位数字符串转换为真实的位数，比如输入的'%40'，代表有效位数为40位，下面的循环就是把precesion的值设置为40
  800383:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  800384:	8d 14 89             	lea    (%ecx,%ecx,4),%edx
  800387:	01 d2                	add    %edx,%edx
  800389:	8d 4c 10 d0          	lea    -0x30(%eax,%edx,1),%ecx
				ch = *fmt;
  80038d:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800390:	8d 50 d0             	lea    -0x30(%eax),%edx
  800393:	83 fa 09             	cmp    $0x9,%edx
  800396:	76 eb                	jbe    800383 <vprintfmt+0xb0>
  800398:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  80039b:	eb 37                	jmp    8003d4 <vprintfmt+0x101>
					break;
			}
			goto process_precision;							//跳转到process_precistion子过程

		case '*':											//*--代表有效数字的位数也是由输入参数指定的，比如printf("%*.*f", 10, 2, n)，其中10,2就是用来指定显示的有效数字位数的
			precision = va_arg(ap, int);
  80039d:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a0:	8d 50 04             	lea    0x4(%eax),%edx
  8003a3:	89 55 14             	mov    %edx,0x14(%ebp)
  8003a6:	8b 00                	mov    (%eax),%eax
  8003a8:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  8003ab:	8b 75 10             	mov    0x10(%ebp),%esi
			}
			goto process_precision;							//跳转到process_precistion子过程

		case '*':											//*--代表有效数字的位数也是由输入参数指定的，比如printf("%*.*f", 10, 2, n)，其中10,2就是用来指定显示的有效数字位数的
			precision = va_arg(ap, int);
			goto process_precision;
  8003ae:	eb 24                	jmp    8003d4 <vprintfmt+0x101>
  8003b0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003b4:	79 07                	jns    8003bd <vprintfmt+0xea>
  8003b6:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  8003bd:	8b 75 10             	mov    0x10(%ebp),%esi
  8003c0:	eb 81                	jmp    800343 <vprintfmt+0x70>
  8003c2:	8b 75 10             	mov    0x10(%ebp),%esi
			if (width < 0)									//代表有小数点，但是小数点前面并没有数字，比如'%.6f'这种情况，此时代表整数部分全部显示
				width = 0;			
			goto reswitch;

		case '#':
			altflag = 1;
  8003c5:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003cc:	e9 72 ff ff ff       	jmp    800343 <vprintfmt+0x70>
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  8003d1:	8b 75 10             	mov    0x10(%ebp),%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:									//处理输出精度，把width字段赋值为刚刚计算出来的precision值，所以width应该是整数部分的有效数字位数
			if (width < 0)
  8003d4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003d8:	0f 89 65 ff ff ff    	jns    800343 <vprintfmt+0x70>
				width = precision, precision = -1;
  8003de:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003e1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003e4:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003eb:	e9 53 ff ff ff       	jmp    800343 <vprintfmt+0x70>
			goto reswitch;

		// long flag (doubled for long long)				
		case 'l':											//如果遇到'l'，代表应该是输入long类型，如果有两个'l'代表long long
			lflag++;										//此时把lflag++
  8003f0:	ff 45 d4             	incl   -0x2c(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  8003f3:	8b 75 10             	mov    0x10(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)				
		case 'l':											//如果遇到'l'，代表应该是输入long类型，如果有两个'l'代表long long
			lflag++;										//此时把lflag++
			goto reswitch;
  8003f6:	e9 48 ff ff ff       	jmp    800343 <vprintfmt+0x70>

		// character
		case 'c':											//如果是'c'代表显示一个字符
			putch(va_arg(ap, int), putdat);					//调用输出一个字符到内存的函数putch
  8003fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8003fe:	8d 50 04             	lea    0x4(%eax),%edx
  800401:	89 55 14             	mov    %edx,0x14(%ebp)
  800404:	83 ec 08             	sub    $0x8,%esp
  800407:	53                   	push   %ebx
  800408:	ff 30                	pushl  (%eax)
  80040a:	ff d7                	call   *%edi
			break;
  80040c:	83 c4 10             	add    $0x10,%esp
  80040f:	e9 d3 fe ff ff       	jmp    8002e7 <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800414:	8b 45 14             	mov    0x14(%ebp),%eax
  800417:	8d 50 04             	lea    0x4(%eax),%edx
  80041a:	89 55 14             	mov    %edx,0x14(%ebp)
  80041d:	8b 00                	mov    (%eax),%eax
  80041f:	85 c0                	test   %eax,%eax
  800421:	79 02                	jns    800425 <vprintfmt+0x152>
  800423:	f7 d8                	neg    %eax
  800425:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800427:	83 f8 0f             	cmp    $0xf,%eax
  80042a:	7f 0b                	jg     800437 <vprintfmt+0x164>
  80042c:	8b 04 85 80 21 80 00 	mov    0x802180(,%eax,4),%eax
  800433:	85 c0                	test   %eax,%eax
  800435:	75 15                	jne    80044c <vprintfmt+0x179>
				printfmt(putch, putdat, "error %d", err);
  800437:	52                   	push   %edx
  800438:	68 ea 1e 80 00       	push   $0x801eea
  80043d:	53                   	push   %ebx
  80043e:	57                   	push   %edi
  80043f:	e8 72 fe ff ff       	call   8002b6 <printfmt>
  800444:	83 c4 10             	add    $0x10,%esp
  800447:	e9 9b fe ff ff       	jmp    8002e7 <vprintfmt+0x14>
			else
				printfmt(putch, putdat, "%s", p);
  80044c:	50                   	push   %eax
  80044d:	68 bb 22 80 00       	push   $0x8022bb
  800452:	53                   	push   %ebx
  800453:	57                   	push   %edi
  800454:	e8 5d fe ff ff       	call   8002b6 <printfmt>
  800459:	83 c4 10             	add    $0x10,%esp
  80045c:	e9 86 fe ff ff       	jmp    8002e7 <vprintfmt+0x14>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800461:	8b 45 14             	mov    0x14(%ebp),%eax
  800464:	8d 50 04             	lea    0x4(%eax),%edx
  800467:	89 55 14             	mov    %edx,0x14(%ebp)
  80046a:	8b 00                	mov    (%eax),%eax
  80046c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80046f:	85 c0                	test   %eax,%eax
  800471:	75 07                	jne    80047a <vprintfmt+0x1a7>
				p = "(null)";
  800473:	c7 45 d4 e3 1e 80 00 	movl   $0x801ee3,-0x2c(%ebp)
			if (width > 0 && padc != '-')
  80047a:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80047d:	85 f6                	test   %esi,%esi
  80047f:	0f 8e fb 01 00 00    	jle    800680 <vprintfmt+0x3ad>
  800485:	80 7d e3 2d          	cmpb   $0x2d,-0x1d(%ebp)
  800489:	0f 84 09 02 00 00    	je     800698 <vprintfmt+0x3c5>
				for (width -= strnlen(p, precision); width > 0; width--)
  80048f:	83 ec 08             	sub    $0x8,%esp
  800492:	ff 75 d0             	pushl  -0x30(%ebp)
  800495:	ff 75 d4             	pushl  -0x2c(%ebp)
  800498:	e8 ad 02 00 00       	call   80074a <strnlen>
  80049d:	89 f1                	mov    %esi,%ecx
  80049f:	29 c1                	sub    %eax,%ecx
  8004a1:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  8004a4:	83 c4 10             	add    $0x10,%esp
  8004a7:	85 c9                	test   %ecx,%ecx
  8004a9:	0f 8e d1 01 00 00    	jle    800680 <vprintfmt+0x3ad>
					putch(padc, putdat);
  8004af:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  8004b3:	83 ec 08             	sub    $0x8,%esp
  8004b6:	53                   	push   %ebx
  8004b7:	56                   	push   %esi
  8004b8:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ba:	83 c4 10             	add    $0x10,%esp
  8004bd:	ff 4d e4             	decl   -0x1c(%ebp)
  8004c0:	75 f1                	jne    8004b3 <vprintfmt+0x1e0>
  8004c2:	e9 b9 01 00 00       	jmp    800680 <vprintfmt+0x3ad>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004c7:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004cb:	74 19                	je     8004e6 <vprintfmt+0x213>
  8004cd:	0f be c0             	movsbl %al,%eax
  8004d0:	83 e8 20             	sub    $0x20,%eax
  8004d3:	83 f8 5e             	cmp    $0x5e,%eax
  8004d6:	76 0e                	jbe    8004e6 <vprintfmt+0x213>
					putch('?', putdat);
  8004d8:	83 ec 08             	sub    $0x8,%esp
  8004db:	53                   	push   %ebx
  8004dc:	6a 3f                	push   $0x3f
  8004de:	ff 55 08             	call   *0x8(%ebp)
  8004e1:	83 c4 10             	add    $0x10,%esp
  8004e4:	eb 0b                	jmp    8004f1 <vprintfmt+0x21e>
				else
					putch(ch, putdat);
  8004e6:	83 ec 08             	sub    $0x8,%esp
  8004e9:	53                   	push   %ebx
  8004ea:	52                   	push   %edx
  8004eb:	ff 55 08             	call   *0x8(%ebp)
  8004ee:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004f1:	ff 4d e4             	decl   -0x1c(%ebp)
  8004f4:	46                   	inc    %esi
  8004f5:	8a 46 ff             	mov    -0x1(%esi),%al
  8004f8:	0f be d0             	movsbl %al,%edx
  8004fb:	85 d2                	test   %edx,%edx
  8004fd:	75 1c                	jne    80051b <vprintfmt+0x248>
  8004ff:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800502:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800506:	7f 1f                	jg     800527 <vprintfmt+0x254>
  800508:	e9 da fd ff ff       	jmp    8002e7 <vprintfmt+0x14>
  80050d:	89 7d 08             	mov    %edi,0x8(%ebp)
  800510:	8b 7d d0             	mov    -0x30(%ebp),%edi
  800513:	eb 06                	jmp    80051b <vprintfmt+0x248>
  800515:	89 7d 08             	mov    %edi,0x8(%ebp)
  800518:	8b 7d d0             	mov    -0x30(%ebp),%edi
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80051b:	85 ff                	test   %edi,%edi
  80051d:	78 a8                	js     8004c7 <vprintfmt+0x1f4>
  80051f:	4f                   	dec    %edi
  800520:	79 a5                	jns    8004c7 <vprintfmt+0x1f4>
  800522:	8b 7d 08             	mov    0x8(%ebp),%edi
  800525:	eb db                	jmp    800502 <vprintfmt+0x22f>
  800527:	8b 75 e4             	mov    -0x1c(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80052a:	83 ec 08             	sub    $0x8,%esp
  80052d:	53                   	push   %ebx
  80052e:	6a 20                	push   $0x20
  800530:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800532:	4e                   	dec    %esi
  800533:	83 c4 10             	add    $0x10,%esp
  800536:	85 f6                	test   %esi,%esi
  800538:	7f f0                	jg     80052a <vprintfmt+0x257>
  80053a:	e9 a8 fd ff ff       	jmp    8002e7 <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80053f:	83 7d d4 01          	cmpl   $0x1,-0x2c(%ebp)
  800543:	7e 16                	jle    80055b <vprintfmt+0x288>
		return va_arg(*ap, long long);
  800545:	8b 45 14             	mov    0x14(%ebp),%eax
  800548:	8d 50 08             	lea    0x8(%eax),%edx
  80054b:	89 55 14             	mov    %edx,0x14(%ebp)
  80054e:	8b 50 04             	mov    0x4(%eax),%edx
  800551:	8b 00                	mov    (%eax),%eax
  800553:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800556:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800559:	eb 34                	jmp    80058f <vprintfmt+0x2bc>
	else if (lflag)
  80055b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80055f:	74 18                	je     800579 <vprintfmt+0x2a6>
		return va_arg(*ap, long);
  800561:	8b 45 14             	mov    0x14(%ebp),%eax
  800564:	8d 50 04             	lea    0x4(%eax),%edx
  800567:	89 55 14             	mov    %edx,0x14(%ebp)
  80056a:	8b 30                	mov    (%eax),%esi
  80056c:	89 75 d8             	mov    %esi,-0x28(%ebp)
  80056f:	89 f0                	mov    %esi,%eax
  800571:	c1 f8 1f             	sar    $0x1f,%eax
  800574:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800577:	eb 16                	jmp    80058f <vprintfmt+0x2bc>
	else
		return va_arg(*ap, int);
  800579:	8b 45 14             	mov    0x14(%ebp),%eax
  80057c:	8d 50 04             	lea    0x4(%eax),%edx
  80057f:	89 55 14             	mov    %edx,0x14(%ebp)
  800582:	8b 30                	mov    (%eax),%esi
  800584:	89 75 d8             	mov    %esi,-0x28(%ebp)
  800587:	89 f0                	mov    %esi,%eax
  800589:	c1 f8 1f             	sar    $0x1f,%eax
  80058c:	89 45 dc             	mov    %eax,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80058f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800592:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
  800595:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800599:	0f 89 8a 00 00 00    	jns    800629 <vprintfmt+0x356>
				putch('-', putdat);
  80059f:	83 ec 08             	sub    $0x8,%esp
  8005a2:	53                   	push   %ebx
  8005a3:	6a 2d                	push   $0x2d
  8005a5:	ff d7                	call   *%edi
				num = -(long long) num;
  8005a7:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005aa:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005ad:	f7 d8                	neg    %eax
  8005af:	83 d2 00             	adc    $0x0,%edx
  8005b2:	f7 da                	neg    %edx
  8005b4:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005b7:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8005bc:	eb 70                	jmp    80062e <vprintfmt+0x35b>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005be:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8005c1:	8d 45 14             	lea    0x14(%ebp),%eax
  8005c4:	e8 97 fc ff ff       	call   800260 <getuint>
			base = 10;
  8005c9:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8005ce:	eb 5e                	jmp    80062e <vprintfmt+0x35b>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
  8005d0:	83 ec 08             	sub    $0x8,%esp
  8005d3:	53                   	push   %ebx
  8005d4:	6a 30                	push   $0x30
  8005d6:	ff d7                	call   *%edi
			num = getuint(&ap, lflag);
  8005d8:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8005db:	8d 45 14             	lea    0x14(%ebp),%eax
  8005de:	e8 7d fc ff ff       	call   800260 <getuint>
			base = 8;
			goto number;
  8005e3:	83 c4 10             	add    $0x10,%esp
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  8005e6:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8005eb:	eb 41                	jmp    80062e <vprintfmt+0x35b>
		// pointer
		case 'p':
			putch('0', putdat);
  8005ed:	83 ec 08             	sub    $0x8,%esp
  8005f0:	53                   	push   %ebx
  8005f1:	6a 30                	push   $0x30
  8005f3:	ff d7                	call   *%edi
			putch('x', putdat);
  8005f5:	83 c4 08             	add    $0x8,%esp
  8005f8:	53                   	push   %ebx
  8005f9:	6a 78                	push   $0x78
  8005fb:	ff d7                	call   *%edi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005fd:	8b 45 14             	mov    0x14(%ebp),%eax
  800600:	8d 50 04             	lea    0x4(%eax),%edx
  800603:	89 55 14             	mov    %edx,0x14(%ebp)
			goto number;
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800606:	8b 00                	mov    (%eax),%eax
  800608:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80060d:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800610:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800615:	eb 17                	jmp    80062e <vprintfmt+0x35b>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800617:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80061a:	8d 45 14             	lea    0x14(%ebp),%eax
  80061d:	e8 3e fc ff ff       	call   800260 <getuint>
			base = 16;
  800622:	b9 10 00 00 00       	mov    $0x10,%ecx
  800627:	eb 05                	jmp    80062e <vprintfmt+0x35b>
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800629:	b9 0a 00 00 00       	mov    $0xa,%ecx
		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  80062e:	83 ec 0c             	sub    $0xc,%esp
  800631:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  800635:	56                   	push   %esi
  800636:	ff 75 e4             	pushl  -0x1c(%ebp)
  800639:	51                   	push   %ecx
  80063a:	52                   	push   %edx
  80063b:	50                   	push   %eax
  80063c:	89 da                	mov    %ebx,%edx
  80063e:	89 f8                	mov    %edi,%eax
  800640:	e8 6b fb ff ff       	call   8001b0 <printnum>
			break;
  800645:	83 c4 20             	add    $0x20,%esp
  800648:	e9 9a fc ff ff       	jmp    8002e7 <vprintfmt+0x14>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80064d:	83 ec 08             	sub    $0x8,%esp
  800650:	53                   	push   %ebx
  800651:	52                   	push   %edx
  800652:	ff d7                	call   *%edi
			break;
  800654:	83 c4 10             	add    $0x10,%esp
  800657:	e9 8b fc ff ff       	jmp    8002e7 <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80065c:	83 ec 08             	sub    $0x8,%esp
  80065f:	53                   	push   %ebx
  800660:	6a 25                	push   $0x25
  800662:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800664:	83 c4 10             	add    $0x10,%esp
  800667:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80066b:	0f 84 73 fc ff ff    	je     8002e4 <vprintfmt+0x11>
  800671:	4e                   	dec    %esi
  800672:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800676:	75 f9                	jne    800671 <vprintfmt+0x39e>
  800678:	89 75 10             	mov    %esi,0x10(%ebp)
  80067b:	e9 67 fc ff ff       	jmp    8002e7 <vprintfmt+0x14>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800680:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800683:	8d 70 01             	lea    0x1(%eax),%esi
  800686:	8a 00                	mov    (%eax),%al
  800688:	0f be d0             	movsbl %al,%edx
  80068b:	85 d2                	test   %edx,%edx
  80068d:	0f 85 7a fe ff ff    	jne    80050d <vprintfmt+0x23a>
  800693:	e9 4f fc ff ff       	jmp    8002e7 <vprintfmt+0x14>
  800698:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80069b:	8d 70 01             	lea    0x1(%eax),%esi
  80069e:	8a 00                	mov    (%eax),%al
  8006a0:	0f be d0             	movsbl %al,%edx
  8006a3:	85 d2                	test   %edx,%edx
  8006a5:	0f 85 6a fe ff ff    	jne    800515 <vprintfmt+0x242>
  8006ab:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8006ae:	e9 77 fe ff ff       	jmp    80052a <vprintfmt+0x257>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  8006b3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006b6:	5b                   	pop    %ebx
  8006b7:	5e                   	pop    %esi
  8006b8:	5f                   	pop    %edi
  8006b9:	5d                   	pop    %ebp
  8006ba:	c3                   	ret    

008006bb <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006bb:	55                   	push   %ebp
  8006bc:	89 e5                	mov    %esp,%ebp
  8006be:	83 ec 18             	sub    $0x18,%esp
  8006c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8006c4:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006c7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006ca:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006ce:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006d1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006d8:	85 c0                	test   %eax,%eax
  8006da:	74 26                	je     800702 <vsnprintf+0x47>
  8006dc:	85 d2                	test   %edx,%edx
  8006de:	7e 29                	jle    800709 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006e0:	ff 75 14             	pushl  0x14(%ebp)
  8006e3:	ff 75 10             	pushl  0x10(%ebp)
  8006e6:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006e9:	50                   	push   %eax
  8006ea:	68 9a 02 80 00       	push   $0x80029a
  8006ef:	e8 df fb ff ff       	call   8002d3 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006f4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006f7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006fd:	83 c4 10             	add    $0x10,%esp
  800700:	eb 0c                	jmp    80070e <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800702:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800707:	eb 05                	jmp    80070e <vsnprintf+0x53>
  800709:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80070e:	c9                   	leave  
  80070f:	c3                   	ret    

00800710 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800710:	55                   	push   %ebp
  800711:	89 e5                	mov    %esp,%ebp
  800713:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800716:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800719:	50                   	push   %eax
  80071a:	ff 75 10             	pushl  0x10(%ebp)
  80071d:	ff 75 0c             	pushl  0xc(%ebp)
  800720:	ff 75 08             	pushl  0x8(%ebp)
  800723:	e8 93 ff ff ff       	call   8006bb <vsnprintf>
	va_end(ap);

	return rc;
}
  800728:	c9                   	leave  
  800729:	c3                   	ret    

0080072a <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80072a:	55                   	push   %ebp
  80072b:	89 e5                	mov    %esp,%ebp
  80072d:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800730:	80 3a 00             	cmpb   $0x0,(%edx)
  800733:	74 0e                	je     800743 <strlen+0x19>
  800735:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  80073a:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80073b:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80073f:	75 f9                	jne    80073a <strlen+0x10>
  800741:	eb 05                	jmp    800748 <strlen+0x1e>
  800743:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800748:	5d                   	pop    %ebp
  800749:	c3                   	ret    

0080074a <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80074a:	55                   	push   %ebp
  80074b:	89 e5                	mov    %esp,%ebp
  80074d:	53                   	push   %ebx
  80074e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800751:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800754:	85 c9                	test   %ecx,%ecx
  800756:	74 1a                	je     800772 <strnlen+0x28>
  800758:	80 3b 00             	cmpb   $0x0,(%ebx)
  80075b:	74 1c                	je     800779 <strnlen+0x2f>
  80075d:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  800762:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800764:	39 ca                	cmp    %ecx,%edx
  800766:	74 16                	je     80077e <strnlen+0x34>
  800768:	42                   	inc    %edx
  800769:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  80076e:	75 f2                	jne    800762 <strnlen+0x18>
  800770:	eb 0c                	jmp    80077e <strnlen+0x34>
  800772:	b8 00 00 00 00       	mov    $0x0,%eax
  800777:	eb 05                	jmp    80077e <strnlen+0x34>
  800779:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  80077e:	5b                   	pop    %ebx
  80077f:	5d                   	pop    %ebp
  800780:	c3                   	ret    

00800781 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800781:	55                   	push   %ebp
  800782:	89 e5                	mov    %esp,%ebp
  800784:	53                   	push   %ebx
  800785:	8b 45 08             	mov    0x8(%ebp),%eax
  800788:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80078b:	89 c2                	mov    %eax,%edx
  80078d:	42                   	inc    %edx
  80078e:	41                   	inc    %ecx
  80078f:	8a 59 ff             	mov    -0x1(%ecx),%bl
  800792:	88 5a ff             	mov    %bl,-0x1(%edx)
  800795:	84 db                	test   %bl,%bl
  800797:	75 f4                	jne    80078d <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800799:	5b                   	pop    %ebx
  80079a:	5d                   	pop    %ebp
  80079b:	c3                   	ret    

0080079c <strcat>:

char *
strcat(char *dst, const char *src)
{
  80079c:	55                   	push   %ebp
  80079d:	89 e5                	mov    %esp,%ebp
  80079f:	53                   	push   %ebx
  8007a0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007a3:	53                   	push   %ebx
  8007a4:	e8 81 ff ff ff       	call   80072a <strlen>
  8007a9:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007ac:	ff 75 0c             	pushl  0xc(%ebp)
  8007af:	01 d8                	add    %ebx,%eax
  8007b1:	50                   	push   %eax
  8007b2:	e8 ca ff ff ff       	call   800781 <strcpy>
	return dst;
}
  8007b7:	89 d8                	mov    %ebx,%eax
  8007b9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007bc:	c9                   	leave  
  8007bd:	c3                   	ret    

008007be <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007be:	55                   	push   %ebp
  8007bf:	89 e5                	mov    %esp,%ebp
  8007c1:	56                   	push   %esi
  8007c2:	53                   	push   %ebx
  8007c3:	8b 75 08             	mov    0x8(%ebp),%esi
  8007c6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007c9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007cc:	85 db                	test   %ebx,%ebx
  8007ce:	74 14                	je     8007e4 <strncpy+0x26>
  8007d0:	01 f3                	add    %esi,%ebx
  8007d2:	89 f1                	mov    %esi,%ecx
		*dst++ = *src;
  8007d4:	41                   	inc    %ecx
  8007d5:	8a 02                	mov    (%edx),%al
  8007d7:	88 41 ff             	mov    %al,-0x1(%ecx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007da:	80 3a 01             	cmpb   $0x1,(%edx)
  8007dd:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007e0:	39 cb                	cmp    %ecx,%ebx
  8007e2:	75 f0                	jne    8007d4 <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007e4:	89 f0                	mov    %esi,%eax
  8007e6:	5b                   	pop    %ebx
  8007e7:	5e                   	pop    %esi
  8007e8:	5d                   	pop    %ebp
  8007e9:	c3                   	ret    

008007ea <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007ea:	55                   	push   %ebp
  8007eb:	89 e5                	mov    %esp,%ebp
  8007ed:	53                   	push   %ebx
  8007ee:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007f1:	8b 45 10             	mov    0x10(%ebp),%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007f4:	85 c0                	test   %eax,%eax
  8007f6:	74 30                	je     800828 <strlcpy+0x3e>
		while (--size > 0 && *src != '\0')
  8007f8:	48                   	dec    %eax
  8007f9:	74 20                	je     80081b <strlcpy+0x31>
  8007fb:	8a 0b                	mov    (%ebx),%cl
  8007fd:	84 c9                	test   %cl,%cl
  8007ff:	74 1f                	je     800820 <strlcpy+0x36>
  800801:	8d 53 01             	lea    0x1(%ebx),%edx
  800804:	01 c3                	add    %eax,%ebx
  800806:	8b 45 08             	mov    0x8(%ebp),%eax
			*dst++ = *src++;
  800809:	40                   	inc    %eax
  80080a:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80080d:	39 da                	cmp    %ebx,%edx
  80080f:	74 12                	je     800823 <strlcpy+0x39>
  800811:	42                   	inc    %edx
  800812:	8a 4a ff             	mov    -0x1(%edx),%cl
  800815:	84 c9                	test   %cl,%cl
  800817:	75 f0                	jne    800809 <strlcpy+0x1f>
  800819:	eb 08                	jmp    800823 <strlcpy+0x39>
  80081b:	8b 45 08             	mov    0x8(%ebp),%eax
  80081e:	eb 03                	jmp    800823 <strlcpy+0x39>
  800820:	8b 45 08             	mov    0x8(%ebp),%eax
			*dst++ = *src++;
		*dst = '\0';
  800823:	c6 00 00             	movb   $0x0,(%eax)
  800826:	eb 03                	jmp    80082b <strlcpy+0x41>
  800828:	8b 45 08             	mov    0x8(%ebp),%eax
	}
	return dst - dst_in;
  80082b:	2b 45 08             	sub    0x8(%ebp),%eax
}
  80082e:	5b                   	pop    %ebx
  80082f:	5d                   	pop    %ebp
  800830:	c3                   	ret    

00800831 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800831:	55                   	push   %ebp
  800832:	89 e5                	mov    %esp,%ebp
  800834:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800837:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80083a:	8a 01                	mov    (%ecx),%al
  80083c:	84 c0                	test   %al,%al
  80083e:	74 10                	je     800850 <strcmp+0x1f>
  800840:	3a 02                	cmp    (%edx),%al
  800842:	75 0c                	jne    800850 <strcmp+0x1f>
		p++, q++;
  800844:	41                   	inc    %ecx
  800845:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800846:	8a 01                	mov    (%ecx),%al
  800848:	84 c0                	test   %al,%al
  80084a:	74 04                	je     800850 <strcmp+0x1f>
  80084c:	3a 02                	cmp    (%edx),%al
  80084e:	74 f4                	je     800844 <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800850:	0f b6 c0             	movzbl %al,%eax
  800853:	0f b6 12             	movzbl (%edx),%edx
  800856:	29 d0                	sub    %edx,%eax
}
  800858:	5d                   	pop    %ebp
  800859:	c3                   	ret    

0080085a <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80085a:	55                   	push   %ebp
  80085b:	89 e5                	mov    %esp,%ebp
  80085d:	56                   	push   %esi
  80085e:	53                   	push   %ebx
  80085f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800862:	8b 55 0c             	mov    0xc(%ebp),%edx
  800865:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  800868:	85 f6                	test   %esi,%esi
  80086a:	74 23                	je     80088f <strncmp+0x35>
  80086c:	8a 03                	mov    (%ebx),%al
  80086e:	84 c0                	test   %al,%al
  800870:	74 2b                	je     80089d <strncmp+0x43>
  800872:	3a 02                	cmp    (%edx),%al
  800874:	75 27                	jne    80089d <strncmp+0x43>
  800876:	8d 43 01             	lea    0x1(%ebx),%eax
  800879:	01 de                	add    %ebx,%esi
		n--, p++, q++;
  80087b:	89 c3                	mov    %eax,%ebx
  80087d:	42                   	inc    %edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80087e:	39 c6                	cmp    %eax,%esi
  800880:	74 14                	je     800896 <strncmp+0x3c>
  800882:	8a 08                	mov    (%eax),%cl
  800884:	84 c9                	test   %cl,%cl
  800886:	74 15                	je     80089d <strncmp+0x43>
  800888:	40                   	inc    %eax
  800889:	3a 0a                	cmp    (%edx),%cl
  80088b:	74 ee                	je     80087b <strncmp+0x21>
  80088d:	eb 0e                	jmp    80089d <strncmp+0x43>
		n--, p++, q++;
	if (n == 0)
		return 0;
  80088f:	b8 00 00 00 00       	mov    $0x0,%eax
  800894:	eb 0f                	jmp    8008a5 <strncmp+0x4b>
  800896:	b8 00 00 00 00       	mov    $0x0,%eax
  80089b:	eb 08                	jmp    8008a5 <strncmp+0x4b>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80089d:	0f b6 03             	movzbl (%ebx),%eax
  8008a0:	0f b6 12             	movzbl (%edx),%edx
  8008a3:	29 d0                	sub    %edx,%eax
}
  8008a5:	5b                   	pop    %ebx
  8008a6:	5e                   	pop    %esi
  8008a7:	5d                   	pop    %ebp
  8008a8:	c3                   	ret    

008008a9 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008a9:	55                   	push   %ebp
  8008aa:	89 e5                	mov    %esp,%ebp
  8008ac:	53                   	push   %ebx
  8008ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  8008b3:	8a 10                	mov    (%eax),%dl
  8008b5:	84 d2                	test   %dl,%dl
  8008b7:	74 1a                	je     8008d3 <strchr+0x2a>
  8008b9:	88 d9                	mov    %bl,%cl
		if (*s == c)
  8008bb:	38 d3                	cmp    %dl,%bl
  8008bd:	75 06                	jne    8008c5 <strchr+0x1c>
  8008bf:	eb 17                	jmp    8008d8 <strchr+0x2f>
  8008c1:	38 ca                	cmp    %cl,%dl
  8008c3:	74 13                	je     8008d8 <strchr+0x2f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008c5:	40                   	inc    %eax
  8008c6:	8a 10                	mov    (%eax),%dl
  8008c8:	84 d2                	test   %dl,%dl
  8008ca:	75 f5                	jne    8008c1 <strchr+0x18>
		if (*s == c)
			return (char *) s;
	return 0;
  8008cc:	b8 00 00 00 00       	mov    $0x0,%eax
  8008d1:	eb 05                	jmp    8008d8 <strchr+0x2f>
  8008d3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008d8:	5b                   	pop    %ebx
  8008d9:	5d                   	pop    %ebp
  8008da:	c3                   	ret    

008008db <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008db:	55                   	push   %ebp
  8008dc:	89 e5                	mov    %esp,%ebp
  8008de:	53                   	push   %ebx
  8008df:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  8008e5:	8a 10                	mov    (%eax),%dl
  8008e7:	84 d2                	test   %dl,%dl
  8008e9:	74 13                	je     8008fe <strfind+0x23>
  8008eb:	88 d9                	mov    %bl,%cl
		if (*s == c)
  8008ed:	38 d3                	cmp    %dl,%bl
  8008ef:	75 06                	jne    8008f7 <strfind+0x1c>
  8008f1:	eb 0b                	jmp    8008fe <strfind+0x23>
  8008f3:	38 ca                	cmp    %cl,%dl
  8008f5:	74 07                	je     8008fe <strfind+0x23>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8008f7:	40                   	inc    %eax
  8008f8:	8a 10                	mov    (%eax),%dl
  8008fa:	84 d2                	test   %dl,%dl
  8008fc:	75 f5                	jne    8008f3 <strfind+0x18>
		if (*s == c)
			break;
	return (char *) s;
}
  8008fe:	5b                   	pop    %ebx
  8008ff:	5d                   	pop    %ebp
  800900:	c3                   	ret    

00800901 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800901:	55                   	push   %ebp
  800902:	89 e5                	mov    %esp,%ebp
  800904:	57                   	push   %edi
  800905:	56                   	push   %esi
  800906:	53                   	push   %ebx
  800907:	8b 7d 08             	mov    0x8(%ebp),%edi
  80090a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80090d:	85 c9                	test   %ecx,%ecx
  80090f:	74 36                	je     800947 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800911:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800917:	75 28                	jne    800941 <memset+0x40>
  800919:	f6 c1 03             	test   $0x3,%cl
  80091c:	75 23                	jne    800941 <memset+0x40>
		c &= 0xFF;
  80091e:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800922:	89 d3                	mov    %edx,%ebx
  800924:	c1 e3 08             	shl    $0x8,%ebx
  800927:	89 d6                	mov    %edx,%esi
  800929:	c1 e6 18             	shl    $0x18,%esi
  80092c:	89 d0                	mov    %edx,%eax
  80092e:	c1 e0 10             	shl    $0x10,%eax
  800931:	09 f0                	or     %esi,%eax
  800933:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800935:	89 d8                	mov    %ebx,%eax
  800937:	09 d0                	or     %edx,%eax
  800939:	c1 e9 02             	shr    $0x2,%ecx
  80093c:	fc                   	cld    
  80093d:	f3 ab                	rep stos %eax,%es:(%edi)
  80093f:	eb 06                	jmp    800947 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800941:	8b 45 0c             	mov    0xc(%ebp),%eax
  800944:	fc                   	cld    
  800945:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800947:	89 f8                	mov    %edi,%eax
  800949:	5b                   	pop    %ebx
  80094a:	5e                   	pop    %esi
  80094b:	5f                   	pop    %edi
  80094c:	5d                   	pop    %ebp
  80094d:	c3                   	ret    

0080094e <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80094e:	55                   	push   %ebp
  80094f:	89 e5                	mov    %esp,%ebp
  800951:	57                   	push   %edi
  800952:	56                   	push   %esi
  800953:	8b 45 08             	mov    0x8(%ebp),%eax
  800956:	8b 75 0c             	mov    0xc(%ebp),%esi
  800959:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80095c:	39 c6                	cmp    %eax,%esi
  80095e:	73 33                	jae    800993 <memmove+0x45>
  800960:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800963:	39 d0                	cmp    %edx,%eax
  800965:	73 2c                	jae    800993 <memmove+0x45>
		s += n;
		d += n;
  800967:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80096a:	89 d6                	mov    %edx,%esi
  80096c:	09 fe                	or     %edi,%esi
  80096e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800974:	75 13                	jne    800989 <memmove+0x3b>
  800976:	f6 c1 03             	test   $0x3,%cl
  800979:	75 0e                	jne    800989 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  80097b:	83 ef 04             	sub    $0x4,%edi
  80097e:	8d 72 fc             	lea    -0x4(%edx),%esi
  800981:	c1 e9 02             	shr    $0x2,%ecx
  800984:	fd                   	std    
  800985:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800987:	eb 07                	jmp    800990 <memmove+0x42>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800989:	4f                   	dec    %edi
  80098a:	8d 72 ff             	lea    -0x1(%edx),%esi
  80098d:	fd                   	std    
  80098e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800990:	fc                   	cld    
  800991:	eb 1d                	jmp    8009b0 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800993:	89 f2                	mov    %esi,%edx
  800995:	09 c2                	or     %eax,%edx
  800997:	f6 c2 03             	test   $0x3,%dl
  80099a:	75 0f                	jne    8009ab <memmove+0x5d>
  80099c:	f6 c1 03             	test   $0x3,%cl
  80099f:	75 0a                	jne    8009ab <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
  8009a1:	c1 e9 02             	shr    $0x2,%ecx
  8009a4:	89 c7                	mov    %eax,%edi
  8009a6:	fc                   	cld    
  8009a7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009a9:	eb 05                	jmp    8009b0 <memmove+0x62>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009ab:	89 c7                	mov    %eax,%edi
  8009ad:	fc                   	cld    
  8009ae:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009b0:	5e                   	pop    %esi
  8009b1:	5f                   	pop    %edi
  8009b2:	5d                   	pop    %ebp
  8009b3:	c3                   	ret    

008009b4 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009b4:	55                   	push   %ebp
  8009b5:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009b7:	ff 75 10             	pushl  0x10(%ebp)
  8009ba:	ff 75 0c             	pushl  0xc(%ebp)
  8009bd:	ff 75 08             	pushl  0x8(%ebp)
  8009c0:	e8 89 ff ff ff       	call   80094e <memmove>
}
  8009c5:	c9                   	leave  
  8009c6:	c3                   	ret    

008009c7 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009c7:	55                   	push   %ebp
  8009c8:	89 e5                	mov    %esp,%ebp
  8009ca:	57                   	push   %edi
  8009cb:	56                   	push   %esi
  8009cc:	53                   	push   %ebx
  8009cd:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8009d0:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009d3:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009d6:	85 c0                	test   %eax,%eax
  8009d8:	74 33                	je     800a0d <memcmp+0x46>
  8009da:	8d 78 ff             	lea    -0x1(%eax),%edi
		if (*s1 != *s2)
  8009dd:	8a 13                	mov    (%ebx),%dl
  8009df:	8a 0e                	mov    (%esi),%cl
  8009e1:	38 ca                	cmp    %cl,%dl
  8009e3:	75 13                	jne    8009f8 <memcmp+0x31>
  8009e5:	b8 00 00 00 00       	mov    $0x0,%eax
  8009ea:	eb 16                	jmp    800a02 <memcmp+0x3b>
  8009ec:	8a 54 03 01          	mov    0x1(%ebx,%eax,1),%dl
  8009f0:	40                   	inc    %eax
  8009f1:	8a 0c 06             	mov    (%esi,%eax,1),%cl
  8009f4:	38 ca                	cmp    %cl,%dl
  8009f6:	74 0a                	je     800a02 <memcmp+0x3b>
			return (int) *s1 - (int) *s2;
  8009f8:	0f b6 c2             	movzbl %dl,%eax
  8009fb:	0f b6 c9             	movzbl %cl,%ecx
  8009fe:	29 c8                	sub    %ecx,%eax
  800a00:	eb 10                	jmp    800a12 <memcmp+0x4b>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a02:	39 f8                	cmp    %edi,%eax
  800a04:	75 e6                	jne    8009ec <memcmp+0x25>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a06:	b8 00 00 00 00       	mov    $0x0,%eax
  800a0b:	eb 05                	jmp    800a12 <memcmp+0x4b>
  800a0d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a12:	5b                   	pop    %ebx
  800a13:	5e                   	pop    %esi
  800a14:	5f                   	pop    %edi
  800a15:	5d                   	pop    %ebp
  800a16:	c3                   	ret    

00800a17 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a17:	55                   	push   %ebp
  800a18:	89 e5                	mov    %esp,%ebp
  800a1a:	53                   	push   %ebx
  800a1b:	8b 55 08             	mov    0x8(%ebp),%edx
	const void *ends = (const char *) s + n;
  800a1e:	89 d0                	mov    %edx,%eax
  800a20:	03 45 10             	add    0x10(%ebp),%eax
	for (; s < ends; s++)
  800a23:	39 c2                	cmp    %eax,%edx
  800a25:	73 1b                	jae    800a42 <memfind+0x2b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a27:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
  800a2b:	0f b6 0a             	movzbl (%edx),%ecx
  800a2e:	39 d9                	cmp    %ebx,%ecx
  800a30:	75 09                	jne    800a3b <memfind+0x24>
  800a32:	eb 12                	jmp    800a46 <memfind+0x2f>
  800a34:	0f b6 0a             	movzbl (%edx),%ecx
  800a37:	39 d9                	cmp    %ebx,%ecx
  800a39:	74 0f                	je     800a4a <memfind+0x33>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a3b:	42                   	inc    %edx
  800a3c:	39 d0                	cmp    %edx,%eax
  800a3e:	75 f4                	jne    800a34 <memfind+0x1d>
  800a40:	eb 0a                	jmp    800a4c <memfind+0x35>
  800a42:	89 d0                	mov    %edx,%eax
  800a44:	eb 06                	jmp    800a4c <memfind+0x35>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a46:	89 d0                	mov    %edx,%eax
  800a48:	eb 02                	jmp    800a4c <memfind+0x35>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a4a:	89 d0                	mov    %edx,%eax
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a4c:	5b                   	pop    %ebx
  800a4d:	5d                   	pop    %ebp
  800a4e:	c3                   	ret    

00800a4f <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a4f:	55                   	push   %ebp
  800a50:	89 e5                	mov    %esp,%ebp
  800a52:	57                   	push   %edi
  800a53:	56                   	push   %esi
  800a54:	53                   	push   %ebx
  800a55:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a58:	eb 01                	jmp    800a5b <strtol+0xc>
		s++;
  800a5a:	41                   	inc    %ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a5b:	8a 01                	mov    (%ecx),%al
  800a5d:	3c 20                	cmp    $0x20,%al
  800a5f:	74 f9                	je     800a5a <strtol+0xb>
  800a61:	3c 09                	cmp    $0x9,%al
  800a63:	74 f5                	je     800a5a <strtol+0xb>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a65:	3c 2b                	cmp    $0x2b,%al
  800a67:	75 08                	jne    800a71 <strtol+0x22>
		s++;
  800a69:	41                   	inc    %ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a6a:	bf 00 00 00 00       	mov    $0x0,%edi
  800a6f:	eb 11                	jmp    800a82 <strtol+0x33>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a71:	3c 2d                	cmp    $0x2d,%al
  800a73:	75 08                	jne    800a7d <strtol+0x2e>
		s++, neg = 1;
  800a75:	41                   	inc    %ecx
  800a76:	bf 01 00 00 00       	mov    $0x1,%edi
  800a7b:	eb 05                	jmp    800a82 <strtol+0x33>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a7d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a82:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800a86:	0f 84 87 00 00 00    	je     800b13 <strtol+0xc4>
  800a8c:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  800a90:	75 27                	jne    800ab9 <strtol+0x6a>
  800a92:	80 39 30             	cmpb   $0x30,(%ecx)
  800a95:	75 22                	jne    800ab9 <strtol+0x6a>
  800a97:	e9 88 00 00 00       	jmp    800b24 <strtol+0xd5>
		s += 2, base = 16;
  800a9c:	83 c1 02             	add    $0x2,%ecx
  800a9f:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  800aa6:	eb 11                	jmp    800ab9 <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
  800aa8:	41                   	inc    %ecx
  800aa9:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  800ab0:	eb 07                	jmp    800ab9 <strtol+0x6a>
	else if (base == 0)
		base = 10;
  800ab2:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)
  800ab9:	b8 00 00 00 00       	mov    $0x0,%eax

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800abe:	8a 11                	mov    (%ecx),%dl
  800ac0:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800ac3:	80 fb 09             	cmp    $0x9,%bl
  800ac6:	77 08                	ja     800ad0 <strtol+0x81>
			dig = *s - '0';
  800ac8:	0f be d2             	movsbl %dl,%edx
  800acb:	83 ea 30             	sub    $0x30,%edx
  800ace:	eb 22                	jmp    800af2 <strtol+0xa3>
		else if (*s >= 'a' && *s <= 'z')
  800ad0:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ad3:	89 f3                	mov    %esi,%ebx
  800ad5:	80 fb 19             	cmp    $0x19,%bl
  800ad8:	77 08                	ja     800ae2 <strtol+0x93>
			dig = *s - 'a' + 10;
  800ada:	0f be d2             	movsbl %dl,%edx
  800add:	83 ea 57             	sub    $0x57,%edx
  800ae0:	eb 10                	jmp    800af2 <strtol+0xa3>
		else if (*s >= 'A' && *s <= 'Z')
  800ae2:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ae5:	89 f3                	mov    %esi,%ebx
  800ae7:	80 fb 19             	cmp    $0x19,%bl
  800aea:	77 14                	ja     800b00 <strtol+0xb1>
			dig = *s - 'A' + 10;
  800aec:	0f be d2             	movsbl %dl,%edx
  800aef:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800af2:	3b 55 10             	cmp    0x10(%ebp),%edx
  800af5:	7d 09                	jge    800b00 <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800af7:	41                   	inc    %ecx
  800af8:	0f af 45 10          	imul   0x10(%ebp),%eax
  800afc:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800afe:	eb be                	jmp    800abe <strtol+0x6f>

	if (endptr)
  800b00:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b04:	74 05                	je     800b0b <strtol+0xbc>
		*endptr = (char *) s;
  800b06:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b09:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800b0b:	85 ff                	test   %edi,%edi
  800b0d:	74 21                	je     800b30 <strtol+0xe1>
  800b0f:	f7 d8                	neg    %eax
  800b11:	eb 1d                	jmp    800b30 <strtol+0xe1>
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b13:	80 39 30             	cmpb   $0x30,(%ecx)
  800b16:	75 9a                	jne    800ab2 <strtol+0x63>
  800b18:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b1c:	0f 84 7a ff ff ff    	je     800a9c <strtol+0x4d>
  800b22:	eb 84                	jmp    800aa8 <strtol+0x59>
  800b24:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b28:	0f 84 6e ff ff ff    	je     800a9c <strtol+0x4d>
  800b2e:	eb 89                	jmp    800ab9 <strtol+0x6a>
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
}
  800b30:	5b                   	pop    %ebx
  800b31:	5e                   	pop    %esi
  800b32:	5f                   	pop    %edi
  800b33:	5d                   	pop    %ebp
  800b34:	c3                   	ret    

00800b35 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b35:	55                   	push   %ebp
  800b36:	89 e5                	mov    %esp,%ebp
  800b38:	57                   	push   %edi
  800b39:	56                   	push   %esi
  800b3a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b3b:	b8 00 00 00 00       	mov    $0x0,%eax
  800b40:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b43:	8b 55 08             	mov    0x8(%ebp),%edx
  800b46:	89 c3                	mov    %eax,%ebx
  800b48:	89 c7                	mov    %eax,%edi
  800b4a:	89 c6                	mov    %eax,%esi
  800b4c:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b4e:	5b                   	pop    %ebx
  800b4f:	5e                   	pop    %esi
  800b50:	5f                   	pop    %edi
  800b51:	5d                   	pop    %ebp
  800b52:	c3                   	ret    

00800b53 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b53:	55                   	push   %ebp
  800b54:	89 e5                	mov    %esp,%ebp
  800b56:	57                   	push   %edi
  800b57:	56                   	push   %esi
  800b58:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b59:	ba 00 00 00 00       	mov    $0x0,%edx
  800b5e:	b8 01 00 00 00       	mov    $0x1,%eax
  800b63:	89 d1                	mov    %edx,%ecx
  800b65:	89 d3                	mov    %edx,%ebx
  800b67:	89 d7                	mov    %edx,%edi
  800b69:	89 d6                	mov    %edx,%esi
  800b6b:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b6d:	5b                   	pop    %ebx
  800b6e:	5e                   	pop    %esi
  800b6f:	5f                   	pop    %edi
  800b70:	5d                   	pop    %ebp
  800b71:	c3                   	ret    

00800b72 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b72:	55                   	push   %ebp
  800b73:	89 e5                	mov    %esp,%ebp
  800b75:	57                   	push   %edi
  800b76:	56                   	push   %esi
  800b77:	53                   	push   %ebx
  800b78:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b7b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b80:	b8 03 00 00 00       	mov    $0x3,%eax
  800b85:	8b 55 08             	mov    0x8(%ebp),%edx
  800b88:	89 cb                	mov    %ecx,%ebx
  800b8a:	89 cf                	mov    %ecx,%edi
  800b8c:	89 ce                	mov    %ecx,%esi
  800b8e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b90:	85 c0                	test   %eax,%eax
  800b92:	7e 17                	jle    800bab <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b94:	83 ec 0c             	sub    $0xc,%esp
  800b97:	50                   	push   %eax
  800b98:	6a 03                	push   $0x3
  800b9a:	68 df 21 80 00       	push   $0x8021df
  800b9f:	6a 23                	push   $0x23
  800ba1:	68 fc 21 80 00       	push   $0x8021fc
  800ba6:	e8 fe 0f 00 00       	call   801ba9 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bab:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bae:	5b                   	pop    %ebx
  800baf:	5e                   	pop    %esi
  800bb0:	5f                   	pop    %edi
  800bb1:	5d                   	pop    %ebp
  800bb2:	c3                   	ret    

00800bb3 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bb3:	55                   	push   %ebp
  800bb4:	89 e5                	mov    %esp,%ebp
  800bb6:	57                   	push   %edi
  800bb7:	56                   	push   %esi
  800bb8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bb9:	ba 00 00 00 00       	mov    $0x0,%edx
  800bbe:	b8 02 00 00 00       	mov    $0x2,%eax
  800bc3:	89 d1                	mov    %edx,%ecx
  800bc5:	89 d3                	mov    %edx,%ebx
  800bc7:	89 d7                	mov    %edx,%edi
  800bc9:	89 d6                	mov    %edx,%esi
  800bcb:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bcd:	5b                   	pop    %ebx
  800bce:	5e                   	pop    %esi
  800bcf:	5f                   	pop    %edi
  800bd0:	5d                   	pop    %ebp
  800bd1:	c3                   	ret    

00800bd2 <sys_yield>:

void
sys_yield(void)
{
  800bd2:	55                   	push   %ebp
  800bd3:	89 e5                	mov    %esp,%ebp
  800bd5:	57                   	push   %edi
  800bd6:	56                   	push   %esi
  800bd7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bd8:	ba 00 00 00 00       	mov    $0x0,%edx
  800bdd:	b8 0b 00 00 00       	mov    $0xb,%eax
  800be2:	89 d1                	mov    %edx,%ecx
  800be4:	89 d3                	mov    %edx,%ebx
  800be6:	89 d7                	mov    %edx,%edi
  800be8:	89 d6                	mov    %edx,%esi
  800bea:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bec:	5b                   	pop    %ebx
  800bed:	5e                   	pop    %esi
  800bee:	5f                   	pop    %edi
  800bef:	5d                   	pop    %ebp
  800bf0:	c3                   	ret    

00800bf1 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bf1:	55                   	push   %ebp
  800bf2:	89 e5                	mov    %esp,%ebp
  800bf4:	57                   	push   %edi
  800bf5:	56                   	push   %esi
  800bf6:	53                   	push   %ebx
  800bf7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bfa:	be 00 00 00 00       	mov    $0x0,%esi
  800bff:	b8 04 00 00 00       	mov    $0x4,%eax
  800c04:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c07:	8b 55 08             	mov    0x8(%ebp),%edx
  800c0a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c0d:	89 f7                	mov    %esi,%edi
  800c0f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c11:	85 c0                	test   %eax,%eax
  800c13:	7e 17                	jle    800c2c <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c15:	83 ec 0c             	sub    $0xc,%esp
  800c18:	50                   	push   %eax
  800c19:	6a 04                	push   $0x4
  800c1b:	68 df 21 80 00       	push   $0x8021df
  800c20:	6a 23                	push   $0x23
  800c22:	68 fc 21 80 00       	push   $0x8021fc
  800c27:	e8 7d 0f 00 00       	call   801ba9 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c2c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c2f:	5b                   	pop    %ebx
  800c30:	5e                   	pop    %esi
  800c31:	5f                   	pop    %edi
  800c32:	5d                   	pop    %ebp
  800c33:	c3                   	ret    

00800c34 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c34:	55                   	push   %ebp
  800c35:	89 e5                	mov    %esp,%ebp
  800c37:	57                   	push   %edi
  800c38:	56                   	push   %esi
  800c39:	53                   	push   %ebx
  800c3a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c3d:	b8 05 00 00 00       	mov    $0x5,%eax
  800c42:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c45:	8b 55 08             	mov    0x8(%ebp),%edx
  800c48:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c4b:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c4e:	8b 75 18             	mov    0x18(%ebp),%esi
  800c51:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c53:	85 c0                	test   %eax,%eax
  800c55:	7e 17                	jle    800c6e <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c57:	83 ec 0c             	sub    $0xc,%esp
  800c5a:	50                   	push   %eax
  800c5b:	6a 05                	push   $0x5
  800c5d:	68 df 21 80 00       	push   $0x8021df
  800c62:	6a 23                	push   $0x23
  800c64:	68 fc 21 80 00       	push   $0x8021fc
  800c69:	e8 3b 0f 00 00       	call   801ba9 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c6e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c71:	5b                   	pop    %ebx
  800c72:	5e                   	pop    %esi
  800c73:	5f                   	pop    %edi
  800c74:	5d                   	pop    %ebp
  800c75:	c3                   	ret    

00800c76 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c76:	55                   	push   %ebp
  800c77:	89 e5                	mov    %esp,%ebp
  800c79:	57                   	push   %edi
  800c7a:	56                   	push   %esi
  800c7b:	53                   	push   %ebx
  800c7c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c7f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c84:	b8 06 00 00 00       	mov    $0x6,%eax
  800c89:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c8c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c8f:	89 df                	mov    %ebx,%edi
  800c91:	89 de                	mov    %ebx,%esi
  800c93:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c95:	85 c0                	test   %eax,%eax
  800c97:	7e 17                	jle    800cb0 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c99:	83 ec 0c             	sub    $0xc,%esp
  800c9c:	50                   	push   %eax
  800c9d:	6a 06                	push   $0x6
  800c9f:	68 df 21 80 00       	push   $0x8021df
  800ca4:	6a 23                	push   $0x23
  800ca6:	68 fc 21 80 00       	push   $0x8021fc
  800cab:	e8 f9 0e 00 00       	call   801ba9 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cb0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb3:	5b                   	pop    %ebx
  800cb4:	5e                   	pop    %esi
  800cb5:	5f                   	pop    %edi
  800cb6:	5d                   	pop    %ebp
  800cb7:	c3                   	ret    

00800cb8 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cb8:	55                   	push   %ebp
  800cb9:	89 e5                	mov    %esp,%ebp
  800cbb:	57                   	push   %edi
  800cbc:	56                   	push   %esi
  800cbd:	53                   	push   %ebx
  800cbe:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cc6:	b8 08 00 00 00       	mov    $0x8,%eax
  800ccb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cce:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd1:	89 df                	mov    %ebx,%edi
  800cd3:	89 de                	mov    %ebx,%esi
  800cd5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cd7:	85 c0                	test   %eax,%eax
  800cd9:	7e 17                	jle    800cf2 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cdb:	83 ec 0c             	sub    $0xc,%esp
  800cde:	50                   	push   %eax
  800cdf:	6a 08                	push   $0x8
  800ce1:	68 df 21 80 00       	push   $0x8021df
  800ce6:	6a 23                	push   $0x23
  800ce8:	68 fc 21 80 00       	push   $0x8021fc
  800ced:	e8 b7 0e 00 00       	call   801ba9 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cf2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf5:	5b                   	pop    %ebx
  800cf6:	5e                   	pop    %esi
  800cf7:	5f                   	pop    %edi
  800cf8:	5d                   	pop    %ebp
  800cf9:	c3                   	ret    

00800cfa <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800cfa:	55                   	push   %ebp
  800cfb:	89 e5                	mov    %esp,%ebp
  800cfd:	57                   	push   %edi
  800cfe:	56                   	push   %esi
  800cff:	53                   	push   %ebx
  800d00:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d03:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d08:	b8 09 00 00 00       	mov    $0x9,%eax
  800d0d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d10:	8b 55 08             	mov    0x8(%ebp),%edx
  800d13:	89 df                	mov    %ebx,%edi
  800d15:	89 de                	mov    %ebx,%esi
  800d17:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d19:	85 c0                	test   %eax,%eax
  800d1b:	7e 17                	jle    800d34 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d1d:	83 ec 0c             	sub    $0xc,%esp
  800d20:	50                   	push   %eax
  800d21:	6a 09                	push   $0x9
  800d23:	68 df 21 80 00       	push   $0x8021df
  800d28:	6a 23                	push   $0x23
  800d2a:	68 fc 21 80 00       	push   $0x8021fc
  800d2f:	e8 75 0e 00 00       	call   801ba9 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d34:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d37:	5b                   	pop    %ebx
  800d38:	5e                   	pop    %esi
  800d39:	5f                   	pop    %edi
  800d3a:	5d                   	pop    %ebp
  800d3b:	c3                   	ret    

00800d3c <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d3c:	55                   	push   %ebp
  800d3d:	89 e5                	mov    %esp,%ebp
  800d3f:	57                   	push   %edi
  800d40:	56                   	push   %esi
  800d41:	53                   	push   %ebx
  800d42:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d45:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d4a:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d4f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d52:	8b 55 08             	mov    0x8(%ebp),%edx
  800d55:	89 df                	mov    %ebx,%edi
  800d57:	89 de                	mov    %ebx,%esi
  800d59:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d5b:	85 c0                	test   %eax,%eax
  800d5d:	7e 17                	jle    800d76 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d5f:	83 ec 0c             	sub    $0xc,%esp
  800d62:	50                   	push   %eax
  800d63:	6a 0a                	push   $0xa
  800d65:	68 df 21 80 00       	push   $0x8021df
  800d6a:	6a 23                	push   $0x23
  800d6c:	68 fc 21 80 00       	push   $0x8021fc
  800d71:	e8 33 0e 00 00       	call   801ba9 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d76:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d79:	5b                   	pop    %ebx
  800d7a:	5e                   	pop    %esi
  800d7b:	5f                   	pop    %edi
  800d7c:	5d                   	pop    %ebp
  800d7d:	c3                   	ret    

00800d7e <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d7e:	55                   	push   %ebp
  800d7f:	89 e5                	mov    %esp,%ebp
  800d81:	57                   	push   %edi
  800d82:	56                   	push   %esi
  800d83:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d84:	be 00 00 00 00       	mov    $0x0,%esi
  800d89:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d8e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d91:	8b 55 08             	mov    0x8(%ebp),%edx
  800d94:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d97:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d9a:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d9c:	5b                   	pop    %ebx
  800d9d:	5e                   	pop    %esi
  800d9e:	5f                   	pop    %edi
  800d9f:	5d                   	pop    %ebp
  800da0:	c3                   	ret    

00800da1 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800da1:	55                   	push   %ebp
  800da2:	89 e5                	mov    %esp,%ebp
  800da4:	57                   	push   %edi
  800da5:	56                   	push   %esi
  800da6:	53                   	push   %ebx
  800da7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800daa:	b9 00 00 00 00       	mov    $0x0,%ecx
  800daf:	b8 0d 00 00 00       	mov    $0xd,%eax
  800db4:	8b 55 08             	mov    0x8(%ebp),%edx
  800db7:	89 cb                	mov    %ecx,%ebx
  800db9:	89 cf                	mov    %ecx,%edi
  800dbb:	89 ce                	mov    %ecx,%esi
  800dbd:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dbf:	85 c0                	test   %eax,%eax
  800dc1:	7e 17                	jle    800dda <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dc3:	83 ec 0c             	sub    $0xc,%esp
  800dc6:	50                   	push   %eax
  800dc7:	6a 0d                	push   $0xd
  800dc9:	68 df 21 80 00       	push   $0x8021df
  800dce:	6a 23                	push   $0x23
  800dd0:	68 fc 21 80 00       	push   $0x8021fc
  800dd5:	e8 cf 0d 00 00       	call   801ba9 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800dda:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ddd:	5b                   	pop    %ebx
  800dde:	5e                   	pop    %esi
  800ddf:	5f                   	pop    %edi
  800de0:	5d                   	pop    %ebp
  800de1:	c3                   	ret    

00800de2 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  800de2:	55                   	push   %ebp
  800de3:	89 e5                	mov    %esp,%ebp
  800de5:	56                   	push   %esi
  800de6:	53                   	push   %ebx
  800de7:	8b 75 08             	mov    0x8(%ebp),%esi
  800dea:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ded:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");
	int r;
    if (pg != NULL) {
  800df0:	85 c0                	test   %eax,%eax
  800df2:	74 0e                	je     800e02 <ipc_recv+0x20>
        r = sys_ipc_recv(pg);
  800df4:	83 ec 0c             	sub    $0xc,%esp
  800df7:	50                   	push   %eax
  800df8:	e8 a4 ff ff ff       	call   800da1 <sys_ipc_recv>
  800dfd:	83 c4 10             	add    $0x10,%esp
  800e00:	eb 10                	jmp    800e12 <ipc_recv+0x30>
    } else {
        r = sys_ipc_recv((void *) UTOP);
  800e02:	83 ec 0c             	sub    $0xc,%esp
  800e05:	68 00 00 c0 ee       	push   $0xeec00000
  800e0a:	e8 92 ff ff ff       	call   800da1 <sys_ipc_recv>
  800e0f:	83 c4 10             	add    $0x10,%esp
    }
    if (r < 0) {
  800e12:	85 c0                	test   %eax,%eax
  800e14:	79 16                	jns    800e2c <ipc_recv+0x4a>
        // failed
        if (from_env_store != NULL) *from_env_store = 0;
  800e16:	85 f6                	test   %esi,%esi
  800e18:	74 06                	je     800e20 <ipc_recv+0x3e>
  800e1a:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        if (perm_store != NULL) *perm_store = 0;
  800e20:	85 db                	test   %ebx,%ebx
  800e22:	74 2c                	je     800e50 <ipc_recv+0x6e>
  800e24:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800e2a:	eb 24                	jmp    800e50 <ipc_recv+0x6e>
        return r;
    } else {
        if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  800e2c:	85 f6                	test   %esi,%esi
  800e2e:	74 0a                	je     800e3a <ipc_recv+0x58>
  800e30:	a1 04 40 80 00       	mov    0x804004,%eax
  800e35:	8b 40 74             	mov    0x74(%eax),%eax
  800e38:	89 06                	mov    %eax,(%esi)
        if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  800e3a:	85 db                	test   %ebx,%ebx
  800e3c:	74 0a                	je     800e48 <ipc_recv+0x66>
  800e3e:	a1 04 40 80 00       	mov    0x804004,%eax
  800e43:	8b 40 78             	mov    0x78(%eax),%eax
  800e46:	89 03                	mov    %eax,(%ebx)
        return thisenv->env_ipc_value;
  800e48:	a1 04 40 80 00       	mov    0x804004,%eax
  800e4d:	8b 40 70             	mov    0x70(%eax),%eax
    }
 
	return 0;
}
  800e50:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e53:	5b                   	pop    %ebx
  800e54:	5e                   	pop    %esi
  800e55:	5d                   	pop    %ebp
  800e56:	c3                   	ret    

00800e57 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  800e57:	55                   	push   %ebp
  800e58:	89 e5                	mov    %esp,%ebp
  800e5a:	57                   	push   %edi
  800e5b:	56                   	push   %esi
  800e5c:	53                   	push   %ebx
  800e5d:	83 ec 0c             	sub    $0xc,%esp
  800e60:	8b 75 10             	mov    0x10(%ebp),%esi
  800e63:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");
	int r;
    if (pg == NULL) pg = (void *)UTOP;
  800e66:	85 f6                	test   %esi,%esi
  800e68:	75 05                	jne    800e6f <ipc_send+0x18>
  800e6a:	be 00 00 c0 ee       	mov    $0xeec00000,%esi
    do {
        r = sys_ipc_try_send(to_env, val, pg, perm);
  800e6f:	57                   	push   %edi
  800e70:	56                   	push   %esi
  800e71:	ff 75 0c             	pushl  0xc(%ebp)
  800e74:	ff 75 08             	pushl  0x8(%ebp)
  800e77:	e8 02 ff ff ff       	call   800d7e <sys_ipc_try_send>
  800e7c:	89 c3                	mov    %eax,%ebx
        if (r < 0 && r != -E_IPC_NOT_RECV) panic("ipc send failed: %e", r);
  800e7e:	83 c4 10             	add    $0x10,%esp
  800e81:	85 c0                	test   %eax,%eax
  800e83:	79 17                	jns    800e9c <ipc_send+0x45>
  800e85:	83 f8 f9             	cmp    $0xfffffff9,%eax
  800e88:	74 1d                	je     800ea7 <ipc_send+0x50>
  800e8a:	50                   	push   %eax
  800e8b:	68 0a 22 80 00       	push   $0x80220a
  800e90:	6a 40                	push   $0x40
  800e92:	68 1e 22 80 00       	push   $0x80221e
  800e97:	e8 0d 0d 00 00       	call   801ba9 <_panic>
        sys_yield();
  800e9c:	e8 31 fd ff ff       	call   800bd2 <sys_yield>
    } while (r != 0);
  800ea1:	85 db                	test   %ebx,%ebx
  800ea3:	75 ca                	jne    800e6f <ipc_send+0x18>
  800ea5:	eb 07                	jmp    800eae <ipc_send+0x57>
	int r;
    if (pg == NULL) pg = (void *)UTOP;
    do {
        r = sys_ipc_try_send(to_env, val, pg, perm);
        if (r < 0 && r != -E_IPC_NOT_RECV) panic("ipc send failed: %e", r);
        sys_yield();
  800ea7:	e8 26 fd ff ff       	call   800bd2 <sys_yield>
  800eac:	eb c1                	jmp    800e6f <ipc_send+0x18>
    } while (r != 0);
}
  800eae:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800eb1:	5b                   	pop    %ebx
  800eb2:	5e                   	pop    %esi
  800eb3:	5f                   	pop    %edi
  800eb4:	5d                   	pop    %ebp
  800eb5:	c3                   	ret    

00800eb6 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  800eb6:	55                   	push   %ebp
  800eb7:	89 e5                	mov    %esp,%ebp
  800eb9:	53                   	push   %ebx
  800eba:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  800ebd:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  800ec2:	39 c1                	cmp    %eax,%ecx
  800ec4:	74 21                	je     800ee7 <ipc_find_env+0x31>
  800ec6:	ba 01 00 00 00       	mov    $0x1,%edx
  800ecb:	8d 1c 95 00 00 00 00 	lea    0x0(,%edx,4),%ebx
  800ed2:	89 d0                	mov    %edx,%eax
  800ed4:	c1 e0 07             	shl    $0x7,%eax
  800ed7:	29 d8                	sub    %ebx,%eax
  800ed9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800ede:	8b 40 50             	mov    0x50(%eax),%eax
  800ee1:	39 c8                	cmp    %ecx,%eax
  800ee3:	75 1b                	jne    800f00 <ipc_find_env+0x4a>
  800ee5:	eb 05                	jmp    800eec <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  800ee7:	ba 00 00 00 00       	mov    $0x0,%edx
		if (envs[i].env_type == type)
			return envs[i].env_id;
  800eec:	8d 04 95 00 00 00 00 	lea    0x0(,%edx,4),%eax
  800ef3:	c1 e2 07             	shl    $0x7,%edx
  800ef6:	29 c2                	sub    %eax,%edx
  800ef8:	8b 82 48 00 c0 ee    	mov    -0x113fffb8(%edx),%eax
  800efe:	eb 0e                	jmp    800f0e <ipc_find_env+0x58>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  800f00:	42                   	inc    %edx
  800f01:	81 fa 00 04 00 00    	cmp    $0x400,%edx
  800f07:	75 c2                	jne    800ecb <ipc_find_env+0x15>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  800f09:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f0e:	5b                   	pop    %ebx
  800f0f:	5d                   	pop    %ebp
  800f10:	c3                   	ret    

00800f11 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800f11:	55                   	push   %ebp
  800f12:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800f14:	8b 45 08             	mov    0x8(%ebp),%eax
  800f17:	05 00 00 00 30       	add    $0x30000000,%eax
  800f1c:	c1 e8 0c             	shr    $0xc,%eax
}
  800f1f:	5d                   	pop    %ebp
  800f20:	c3                   	ret    

00800f21 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800f21:	55                   	push   %ebp
  800f22:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800f24:	8b 45 08             	mov    0x8(%ebp),%eax
  800f27:	05 00 00 00 30       	add    $0x30000000,%eax
  800f2c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800f31:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800f36:	5d                   	pop    %ebp
  800f37:	c3                   	ret    

00800f38 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800f38:	55                   	push   %ebp
  800f39:	89 e5                	mov    %esp,%ebp
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800f3b:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  800f40:	a8 01                	test   $0x1,%al
  800f42:	74 34                	je     800f78 <fd_alloc+0x40>
  800f44:	a1 00 00 74 ef       	mov    0xef740000,%eax
  800f49:	a8 01                	test   $0x1,%al
  800f4b:	74 32                	je     800f7f <fd_alloc+0x47>
  800f4d:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800f52:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800f54:	89 c2                	mov    %eax,%edx
  800f56:	c1 ea 16             	shr    $0x16,%edx
  800f59:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f60:	f6 c2 01             	test   $0x1,%dl
  800f63:	74 1f                	je     800f84 <fd_alloc+0x4c>
  800f65:	89 c2                	mov    %eax,%edx
  800f67:	c1 ea 0c             	shr    $0xc,%edx
  800f6a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f71:	f6 c2 01             	test   $0x1,%dl
  800f74:	75 1a                	jne    800f90 <fd_alloc+0x58>
  800f76:	eb 0c                	jmp    800f84 <fd_alloc+0x4c>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800f78:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  800f7d:	eb 05                	jmp    800f84 <fd_alloc+0x4c>
  800f7f:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  800f84:	8b 45 08             	mov    0x8(%ebp),%eax
  800f87:	89 08                	mov    %ecx,(%eax)
			return 0;
  800f89:	b8 00 00 00 00       	mov    $0x0,%eax
  800f8e:	eb 1a                	jmp    800faa <fd_alloc+0x72>
  800f90:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800f95:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800f9a:	75 b6                	jne    800f52 <fd_alloc+0x1a>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800f9c:	8b 45 08             	mov    0x8(%ebp),%eax
  800f9f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  800fa5:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800faa:	5d                   	pop    %ebp
  800fab:	c3                   	ret    

00800fac <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800fac:	55                   	push   %ebp
  800fad:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800faf:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
  800fb3:	77 39                	ja     800fee <fd_lookup+0x42>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800fb5:	8b 45 08             	mov    0x8(%ebp),%eax
  800fb8:	c1 e0 0c             	shl    $0xc,%eax
  800fbb:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800fc0:	89 c2                	mov    %eax,%edx
  800fc2:	c1 ea 16             	shr    $0x16,%edx
  800fc5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800fcc:	f6 c2 01             	test   $0x1,%dl
  800fcf:	74 24                	je     800ff5 <fd_lookup+0x49>
  800fd1:	89 c2                	mov    %eax,%edx
  800fd3:	c1 ea 0c             	shr    $0xc,%edx
  800fd6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800fdd:	f6 c2 01             	test   $0x1,%dl
  800fe0:	74 1a                	je     800ffc <fd_lookup+0x50>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800fe2:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fe5:	89 02                	mov    %eax,(%edx)
	return 0;
  800fe7:	b8 00 00 00 00       	mov    $0x0,%eax
  800fec:	eb 13                	jmp    801001 <fd_lookup+0x55>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800fee:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ff3:	eb 0c                	jmp    801001 <fd_lookup+0x55>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800ff5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ffa:	eb 05                	jmp    801001 <fd_lookup+0x55>
  800ffc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801001:	5d                   	pop    %ebp
  801002:	c3                   	ret    

00801003 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801003:	55                   	push   %ebp
  801004:	89 e5                	mov    %esp,%ebp
  801006:	53                   	push   %ebx
  801007:	83 ec 04             	sub    $0x4,%esp
  80100a:	8b 45 08             	mov    0x8(%ebp),%eax
  80100d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  801010:	3b 05 04 30 80 00    	cmp    0x803004,%eax
  801016:	75 1e                	jne    801036 <dev_lookup+0x33>
  801018:	eb 0e                	jmp    801028 <dev_lookup+0x25>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80101a:	b8 20 30 80 00       	mov    $0x803020,%eax
  80101f:	eb 0c                	jmp    80102d <dev_lookup+0x2a>
  801021:	b8 3c 30 80 00       	mov    $0x80303c,%eax
  801026:	eb 05                	jmp    80102d <dev_lookup+0x2a>
  801028:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  80102d:	89 03                	mov    %eax,(%ebx)
			return 0;
  80102f:	b8 00 00 00 00       	mov    $0x0,%eax
  801034:	eb 36                	jmp    80106c <dev_lookup+0x69>
int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  801036:	3b 05 20 30 80 00    	cmp    0x803020,%eax
  80103c:	74 dc                	je     80101a <dev_lookup+0x17>
  80103e:	3b 05 3c 30 80 00    	cmp    0x80303c,%eax
  801044:	74 db                	je     801021 <dev_lookup+0x1e>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801046:	8b 15 04 40 80 00    	mov    0x804004,%edx
  80104c:	8b 52 48             	mov    0x48(%edx),%edx
  80104f:	83 ec 04             	sub    $0x4,%esp
  801052:	50                   	push   %eax
  801053:	52                   	push   %edx
  801054:	68 28 22 80 00       	push   $0x802228
  801059:	e8 3e f1 ff ff       	call   80019c <cprintf>
	*dev = 0;
  80105e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  801064:	83 c4 10             	add    $0x10,%esp
  801067:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80106c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80106f:	c9                   	leave  
  801070:	c3                   	ret    

00801071 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801071:	55                   	push   %ebp
  801072:	89 e5                	mov    %esp,%ebp
  801074:	56                   	push   %esi
  801075:	53                   	push   %ebx
  801076:	83 ec 10             	sub    $0x10,%esp
  801079:	8b 75 08             	mov    0x8(%ebp),%esi
  80107c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80107f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801082:	50                   	push   %eax
  801083:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801089:	c1 e8 0c             	shr    $0xc,%eax
  80108c:	50                   	push   %eax
  80108d:	e8 1a ff ff ff       	call   800fac <fd_lookup>
  801092:	83 c4 08             	add    $0x8,%esp
  801095:	85 c0                	test   %eax,%eax
  801097:	78 05                	js     80109e <fd_close+0x2d>
	    || fd != fd2)
  801099:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80109c:	74 06                	je     8010a4 <fd_close+0x33>
		return (must_exist ? r : 0);
  80109e:	84 db                	test   %bl,%bl
  8010a0:	74 47                	je     8010e9 <fd_close+0x78>
  8010a2:	eb 4a                	jmp    8010ee <fd_close+0x7d>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8010a4:	83 ec 08             	sub    $0x8,%esp
  8010a7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010aa:	50                   	push   %eax
  8010ab:	ff 36                	pushl  (%esi)
  8010ad:	e8 51 ff ff ff       	call   801003 <dev_lookup>
  8010b2:	89 c3                	mov    %eax,%ebx
  8010b4:	83 c4 10             	add    $0x10,%esp
  8010b7:	85 c0                	test   %eax,%eax
  8010b9:	78 1c                	js     8010d7 <fd_close+0x66>
		if (dev->dev_close)
  8010bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010be:	8b 40 10             	mov    0x10(%eax),%eax
  8010c1:	85 c0                	test   %eax,%eax
  8010c3:	74 0d                	je     8010d2 <fd_close+0x61>
			r = (*dev->dev_close)(fd);
  8010c5:	83 ec 0c             	sub    $0xc,%esp
  8010c8:	56                   	push   %esi
  8010c9:	ff d0                	call   *%eax
  8010cb:	89 c3                	mov    %eax,%ebx
  8010cd:	83 c4 10             	add    $0x10,%esp
  8010d0:	eb 05                	jmp    8010d7 <fd_close+0x66>
		else
			r = 0;
  8010d2:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8010d7:	83 ec 08             	sub    $0x8,%esp
  8010da:	56                   	push   %esi
  8010db:	6a 00                	push   $0x0
  8010dd:	e8 94 fb ff ff       	call   800c76 <sys_page_unmap>
	return r;
  8010e2:	83 c4 10             	add    $0x10,%esp
  8010e5:	89 d8                	mov    %ebx,%eax
  8010e7:	eb 05                	jmp    8010ee <fd_close+0x7d>
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
  8010e9:	b8 00 00 00 00       	mov    $0x0,%eax
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
	return r;
}
  8010ee:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010f1:	5b                   	pop    %ebx
  8010f2:	5e                   	pop    %esi
  8010f3:	5d                   	pop    %ebp
  8010f4:	c3                   	ret    

008010f5 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8010f5:	55                   	push   %ebp
  8010f6:	89 e5                	mov    %esp,%ebp
  8010f8:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8010fb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010fe:	50                   	push   %eax
  8010ff:	ff 75 08             	pushl  0x8(%ebp)
  801102:	e8 a5 fe ff ff       	call   800fac <fd_lookup>
  801107:	83 c4 08             	add    $0x8,%esp
  80110a:	85 c0                	test   %eax,%eax
  80110c:	78 10                	js     80111e <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80110e:	83 ec 08             	sub    $0x8,%esp
  801111:	6a 01                	push   $0x1
  801113:	ff 75 f4             	pushl  -0xc(%ebp)
  801116:	e8 56 ff ff ff       	call   801071 <fd_close>
  80111b:	83 c4 10             	add    $0x10,%esp
}
  80111e:	c9                   	leave  
  80111f:	c3                   	ret    

00801120 <close_all>:

void
close_all(void)
{
  801120:	55                   	push   %ebp
  801121:	89 e5                	mov    %esp,%ebp
  801123:	53                   	push   %ebx
  801124:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801127:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80112c:	83 ec 0c             	sub    $0xc,%esp
  80112f:	53                   	push   %ebx
  801130:	e8 c0 ff ff ff       	call   8010f5 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801135:	43                   	inc    %ebx
  801136:	83 c4 10             	add    $0x10,%esp
  801139:	83 fb 20             	cmp    $0x20,%ebx
  80113c:	75 ee                	jne    80112c <close_all+0xc>
		close(i);
}
  80113e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801141:	c9                   	leave  
  801142:	c3                   	ret    

00801143 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801143:	55                   	push   %ebp
  801144:	89 e5                	mov    %esp,%ebp
  801146:	57                   	push   %edi
  801147:	56                   	push   %esi
  801148:	53                   	push   %ebx
  801149:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80114c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80114f:	50                   	push   %eax
  801150:	ff 75 08             	pushl  0x8(%ebp)
  801153:	e8 54 fe ff ff       	call   800fac <fd_lookup>
  801158:	83 c4 08             	add    $0x8,%esp
  80115b:	85 c0                	test   %eax,%eax
  80115d:	0f 88 c2 00 00 00    	js     801225 <dup+0xe2>
		return r;
	close(newfdnum);
  801163:	83 ec 0c             	sub    $0xc,%esp
  801166:	ff 75 0c             	pushl  0xc(%ebp)
  801169:	e8 87 ff ff ff       	call   8010f5 <close>

	newfd = INDEX2FD(newfdnum);
  80116e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801171:	c1 e3 0c             	shl    $0xc,%ebx
  801174:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80117a:	83 c4 04             	add    $0x4,%esp
  80117d:	ff 75 e4             	pushl  -0x1c(%ebp)
  801180:	e8 9c fd ff ff       	call   800f21 <fd2data>
  801185:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  801187:	89 1c 24             	mov    %ebx,(%esp)
  80118a:	e8 92 fd ff ff       	call   800f21 <fd2data>
  80118f:	83 c4 10             	add    $0x10,%esp
  801192:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801194:	89 f0                	mov    %esi,%eax
  801196:	c1 e8 16             	shr    $0x16,%eax
  801199:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8011a0:	a8 01                	test   $0x1,%al
  8011a2:	74 35                	je     8011d9 <dup+0x96>
  8011a4:	89 f0                	mov    %esi,%eax
  8011a6:	c1 e8 0c             	shr    $0xc,%eax
  8011a9:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8011b0:	f6 c2 01             	test   $0x1,%dl
  8011b3:	74 24                	je     8011d9 <dup+0x96>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8011b5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8011bc:	83 ec 0c             	sub    $0xc,%esp
  8011bf:	25 07 0e 00 00       	and    $0xe07,%eax
  8011c4:	50                   	push   %eax
  8011c5:	57                   	push   %edi
  8011c6:	6a 00                	push   $0x0
  8011c8:	56                   	push   %esi
  8011c9:	6a 00                	push   $0x0
  8011cb:	e8 64 fa ff ff       	call   800c34 <sys_page_map>
  8011d0:	89 c6                	mov    %eax,%esi
  8011d2:	83 c4 20             	add    $0x20,%esp
  8011d5:	85 c0                	test   %eax,%eax
  8011d7:	78 2c                	js     801205 <dup+0xc2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8011d9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8011dc:	89 d0                	mov    %edx,%eax
  8011de:	c1 e8 0c             	shr    $0xc,%eax
  8011e1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8011e8:	83 ec 0c             	sub    $0xc,%esp
  8011eb:	25 07 0e 00 00       	and    $0xe07,%eax
  8011f0:	50                   	push   %eax
  8011f1:	53                   	push   %ebx
  8011f2:	6a 00                	push   $0x0
  8011f4:	52                   	push   %edx
  8011f5:	6a 00                	push   $0x0
  8011f7:	e8 38 fa ff ff       	call   800c34 <sys_page_map>
  8011fc:	89 c6                	mov    %eax,%esi
  8011fe:	83 c4 20             	add    $0x20,%esp
  801201:	85 c0                	test   %eax,%eax
  801203:	79 1d                	jns    801222 <dup+0xdf>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801205:	83 ec 08             	sub    $0x8,%esp
  801208:	53                   	push   %ebx
  801209:	6a 00                	push   $0x0
  80120b:	e8 66 fa ff ff       	call   800c76 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801210:	83 c4 08             	add    $0x8,%esp
  801213:	57                   	push   %edi
  801214:	6a 00                	push   $0x0
  801216:	e8 5b fa ff ff       	call   800c76 <sys_page_unmap>
	return r;
  80121b:	83 c4 10             	add    $0x10,%esp
  80121e:	89 f0                	mov    %esi,%eax
  801220:	eb 03                	jmp    801225 <dup+0xe2>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801222:	8b 45 0c             	mov    0xc(%ebp),%eax

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801225:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801228:	5b                   	pop    %ebx
  801229:	5e                   	pop    %esi
  80122a:	5f                   	pop    %edi
  80122b:	5d                   	pop    %ebp
  80122c:	c3                   	ret    

0080122d <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80122d:	55                   	push   %ebp
  80122e:	89 e5                	mov    %esp,%ebp
  801230:	53                   	push   %ebx
  801231:	83 ec 14             	sub    $0x14,%esp
  801234:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801237:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80123a:	50                   	push   %eax
  80123b:	53                   	push   %ebx
  80123c:	e8 6b fd ff ff       	call   800fac <fd_lookup>
  801241:	83 c4 08             	add    $0x8,%esp
  801244:	85 c0                	test   %eax,%eax
  801246:	78 67                	js     8012af <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801248:	83 ec 08             	sub    $0x8,%esp
  80124b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80124e:	50                   	push   %eax
  80124f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801252:	ff 30                	pushl  (%eax)
  801254:	e8 aa fd ff ff       	call   801003 <dev_lookup>
  801259:	83 c4 10             	add    $0x10,%esp
  80125c:	85 c0                	test   %eax,%eax
  80125e:	78 4f                	js     8012af <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801260:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801263:	8b 42 08             	mov    0x8(%edx),%eax
  801266:	83 e0 03             	and    $0x3,%eax
  801269:	83 f8 01             	cmp    $0x1,%eax
  80126c:	75 21                	jne    80128f <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80126e:	a1 04 40 80 00       	mov    0x804004,%eax
  801273:	8b 40 48             	mov    0x48(%eax),%eax
  801276:	83 ec 04             	sub    $0x4,%esp
  801279:	53                   	push   %ebx
  80127a:	50                   	push   %eax
  80127b:	68 69 22 80 00       	push   $0x802269
  801280:	e8 17 ef ff ff       	call   80019c <cprintf>
		return -E_INVAL;
  801285:	83 c4 10             	add    $0x10,%esp
  801288:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80128d:	eb 20                	jmp    8012af <read+0x82>
	}
	if (!dev->dev_read)
  80128f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801292:	8b 40 08             	mov    0x8(%eax),%eax
  801295:	85 c0                	test   %eax,%eax
  801297:	74 11                	je     8012aa <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801299:	83 ec 04             	sub    $0x4,%esp
  80129c:	ff 75 10             	pushl  0x10(%ebp)
  80129f:	ff 75 0c             	pushl  0xc(%ebp)
  8012a2:	52                   	push   %edx
  8012a3:	ff d0                	call   *%eax
  8012a5:	83 c4 10             	add    $0x10,%esp
  8012a8:	eb 05                	jmp    8012af <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8012aa:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8012af:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012b2:	c9                   	leave  
  8012b3:	c3                   	ret    

008012b4 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8012b4:	55                   	push   %ebp
  8012b5:	89 e5                	mov    %esp,%ebp
  8012b7:	57                   	push   %edi
  8012b8:	56                   	push   %esi
  8012b9:	53                   	push   %ebx
  8012ba:	83 ec 0c             	sub    $0xc,%esp
  8012bd:	8b 7d 08             	mov    0x8(%ebp),%edi
  8012c0:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8012c3:	85 f6                	test   %esi,%esi
  8012c5:	74 31                	je     8012f8 <readn+0x44>
  8012c7:	b8 00 00 00 00       	mov    $0x0,%eax
  8012cc:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  8012d1:	83 ec 04             	sub    $0x4,%esp
  8012d4:	89 f2                	mov    %esi,%edx
  8012d6:	29 c2                	sub    %eax,%edx
  8012d8:	52                   	push   %edx
  8012d9:	03 45 0c             	add    0xc(%ebp),%eax
  8012dc:	50                   	push   %eax
  8012dd:	57                   	push   %edi
  8012de:	e8 4a ff ff ff       	call   80122d <read>
		if (m < 0)
  8012e3:	83 c4 10             	add    $0x10,%esp
  8012e6:	85 c0                	test   %eax,%eax
  8012e8:	78 17                	js     801301 <readn+0x4d>
			return m;
		if (m == 0)
  8012ea:	85 c0                	test   %eax,%eax
  8012ec:	74 11                	je     8012ff <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8012ee:	01 c3                	add    %eax,%ebx
  8012f0:	89 d8                	mov    %ebx,%eax
  8012f2:	39 f3                	cmp    %esi,%ebx
  8012f4:	72 db                	jb     8012d1 <readn+0x1d>
  8012f6:	eb 09                	jmp    801301 <readn+0x4d>
  8012f8:	b8 00 00 00 00       	mov    $0x0,%eax
  8012fd:	eb 02                	jmp    801301 <readn+0x4d>
  8012ff:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801301:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801304:	5b                   	pop    %ebx
  801305:	5e                   	pop    %esi
  801306:	5f                   	pop    %edi
  801307:	5d                   	pop    %ebp
  801308:	c3                   	ret    

00801309 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801309:	55                   	push   %ebp
  80130a:	89 e5                	mov    %esp,%ebp
  80130c:	53                   	push   %ebx
  80130d:	83 ec 14             	sub    $0x14,%esp
  801310:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801313:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801316:	50                   	push   %eax
  801317:	53                   	push   %ebx
  801318:	e8 8f fc ff ff       	call   800fac <fd_lookup>
  80131d:	83 c4 08             	add    $0x8,%esp
  801320:	85 c0                	test   %eax,%eax
  801322:	78 62                	js     801386 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801324:	83 ec 08             	sub    $0x8,%esp
  801327:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80132a:	50                   	push   %eax
  80132b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80132e:	ff 30                	pushl  (%eax)
  801330:	e8 ce fc ff ff       	call   801003 <dev_lookup>
  801335:	83 c4 10             	add    $0x10,%esp
  801338:	85 c0                	test   %eax,%eax
  80133a:	78 4a                	js     801386 <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80133c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80133f:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801343:	75 21                	jne    801366 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801345:	a1 04 40 80 00       	mov    0x804004,%eax
  80134a:	8b 40 48             	mov    0x48(%eax),%eax
  80134d:	83 ec 04             	sub    $0x4,%esp
  801350:	53                   	push   %ebx
  801351:	50                   	push   %eax
  801352:	68 85 22 80 00       	push   $0x802285
  801357:	e8 40 ee ff ff       	call   80019c <cprintf>
		return -E_INVAL;
  80135c:	83 c4 10             	add    $0x10,%esp
  80135f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801364:	eb 20                	jmp    801386 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801366:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801369:	8b 52 0c             	mov    0xc(%edx),%edx
  80136c:	85 d2                	test   %edx,%edx
  80136e:	74 11                	je     801381 <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801370:	83 ec 04             	sub    $0x4,%esp
  801373:	ff 75 10             	pushl  0x10(%ebp)
  801376:	ff 75 0c             	pushl  0xc(%ebp)
  801379:	50                   	push   %eax
  80137a:	ff d2                	call   *%edx
  80137c:	83 c4 10             	add    $0x10,%esp
  80137f:	eb 05                	jmp    801386 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801381:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801386:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801389:	c9                   	leave  
  80138a:	c3                   	ret    

0080138b <seek>:

int
seek(int fdnum, off_t offset)
{
  80138b:	55                   	push   %ebp
  80138c:	89 e5                	mov    %esp,%ebp
  80138e:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801391:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801394:	50                   	push   %eax
  801395:	ff 75 08             	pushl  0x8(%ebp)
  801398:	e8 0f fc ff ff       	call   800fac <fd_lookup>
  80139d:	83 c4 08             	add    $0x8,%esp
  8013a0:	85 c0                	test   %eax,%eax
  8013a2:	78 0e                	js     8013b2 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8013a4:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8013a7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013aa:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8013ad:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013b2:	c9                   	leave  
  8013b3:	c3                   	ret    

008013b4 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8013b4:	55                   	push   %ebp
  8013b5:	89 e5                	mov    %esp,%ebp
  8013b7:	53                   	push   %ebx
  8013b8:	83 ec 14             	sub    $0x14,%esp
  8013bb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013be:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013c1:	50                   	push   %eax
  8013c2:	53                   	push   %ebx
  8013c3:	e8 e4 fb ff ff       	call   800fac <fd_lookup>
  8013c8:	83 c4 08             	add    $0x8,%esp
  8013cb:	85 c0                	test   %eax,%eax
  8013cd:	78 5f                	js     80142e <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013cf:	83 ec 08             	sub    $0x8,%esp
  8013d2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013d5:	50                   	push   %eax
  8013d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013d9:	ff 30                	pushl  (%eax)
  8013db:	e8 23 fc ff ff       	call   801003 <dev_lookup>
  8013e0:	83 c4 10             	add    $0x10,%esp
  8013e3:	85 c0                	test   %eax,%eax
  8013e5:	78 47                	js     80142e <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8013e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013ea:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8013ee:	75 21                	jne    801411 <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8013f0:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8013f5:	8b 40 48             	mov    0x48(%eax),%eax
  8013f8:	83 ec 04             	sub    $0x4,%esp
  8013fb:	53                   	push   %ebx
  8013fc:	50                   	push   %eax
  8013fd:	68 48 22 80 00       	push   $0x802248
  801402:	e8 95 ed ff ff       	call   80019c <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801407:	83 c4 10             	add    $0x10,%esp
  80140a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80140f:	eb 1d                	jmp    80142e <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  801411:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801414:	8b 52 18             	mov    0x18(%edx),%edx
  801417:	85 d2                	test   %edx,%edx
  801419:	74 0e                	je     801429 <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80141b:	83 ec 08             	sub    $0x8,%esp
  80141e:	ff 75 0c             	pushl  0xc(%ebp)
  801421:	50                   	push   %eax
  801422:	ff d2                	call   *%edx
  801424:	83 c4 10             	add    $0x10,%esp
  801427:	eb 05                	jmp    80142e <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801429:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  80142e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801431:	c9                   	leave  
  801432:	c3                   	ret    

00801433 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801433:	55                   	push   %ebp
  801434:	89 e5                	mov    %esp,%ebp
  801436:	53                   	push   %ebx
  801437:	83 ec 14             	sub    $0x14,%esp
  80143a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80143d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801440:	50                   	push   %eax
  801441:	ff 75 08             	pushl  0x8(%ebp)
  801444:	e8 63 fb ff ff       	call   800fac <fd_lookup>
  801449:	83 c4 08             	add    $0x8,%esp
  80144c:	85 c0                	test   %eax,%eax
  80144e:	78 52                	js     8014a2 <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801450:	83 ec 08             	sub    $0x8,%esp
  801453:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801456:	50                   	push   %eax
  801457:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80145a:	ff 30                	pushl  (%eax)
  80145c:	e8 a2 fb ff ff       	call   801003 <dev_lookup>
  801461:	83 c4 10             	add    $0x10,%esp
  801464:	85 c0                	test   %eax,%eax
  801466:	78 3a                	js     8014a2 <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  801468:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80146b:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80146f:	74 2c                	je     80149d <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801471:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801474:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80147b:	00 00 00 
	stat->st_isdir = 0;
  80147e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801485:	00 00 00 
	stat->st_dev = dev;
  801488:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80148e:	83 ec 08             	sub    $0x8,%esp
  801491:	53                   	push   %ebx
  801492:	ff 75 f0             	pushl  -0x10(%ebp)
  801495:	ff 50 14             	call   *0x14(%eax)
  801498:	83 c4 10             	add    $0x10,%esp
  80149b:	eb 05                	jmp    8014a2 <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80149d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8014a2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014a5:	c9                   	leave  
  8014a6:	c3                   	ret    

008014a7 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8014a7:	55                   	push   %ebp
  8014a8:	89 e5                	mov    %esp,%ebp
  8014aa:	56                   	push   %esi
  8014ab:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8014ac:	83 ec 08             	sub    $0x8,%esp
  8014af:	6a 00                	push   $0x0
  8014b1:	ff 75 08             	pushl  0x8(%ebp)
  8014b4:	e8 75 01 00 00       	call   80162e <open>
  8014b9:	89 c3                	mov    %eax,%ebx
  8014bb:	83 c4 10             	add    $0x10,%esp
  8014be:	85 c0                	test   %eax,%eax
  8014c0:	78 1d                	js     8014df <stat+0x38>
		return fd;
	r = fstat(fd, stat);
  8014c2:	83 ec 08             	sub    $0x8,%esp
  8014c5:	ff 75 0c             	pushl  0xc(%ebp)
  8014c8:	50                   	push   %eax
  8014c9:	e8 65 ff ff ff       	call   801433 <fstat>
  8014ce:	89 c6                	mov    %eax,%esi
	close(fd);
  8014d0:	89 1c 24             	mov    %ebx,(%esp)
  8014d3:	e8 1d fc ff ff       	call   8010f5 <close>
	return r;
  8014d8:	83 c4 10             	add    $0x10,%esp
  8014db:	89 f0                	mov    %esi,%eax
  8014dd:	eb 00                	jmp    8014df <stat+0x38>
}
  8014df:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014e2:	5b                   	pop    %ebx
  8014e3:	5e                   	pop    %esi
  8014e4:	5d                   	pop    %ebp
  8014e5:	c3                   	ret    

008014e6 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8014e6:	55                   	push   %ebp
  8014e7:	89 e5                	mov    %esp,%ebp
  8014e9:	56                   	push   %esi
  8014ea:	53                   	push   %ebx
  8014eb:	89 c6                	mov    %eax,%esi
  8014ed:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8014ef:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8014f6:	75 12                	jne    80150a <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8014f8:	83 ec 0c             	sub    $0xc,%esp
  8014fb:	6a 01                	push   $0x1
  8014fd:	e8 b4 f9 ff ff       	call   800eb6 <ipc_find_env>
  801502:	a3 00 40 80 00       	mov    %eax,0x804000
  801507:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80150a:	6a 07                	push   $0x7
  80150c:	68 00 50 80 00       	push   $0x805000
  801511:	56                   	push   %esi
  801512:	ff 35 00 40 80 00    	pushl  0x804000
  801518:	e8 3a f9 ff ff       	call   800e57 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80151d:	83 c4 0c             	add    $0xc,%esp
  801520:	6a 00                	push   $0x0
  801522:	53                   	push   %ebx
  801523:	6a 00                	push   $0x0
  801525:	e8 b8 f8 ff ff       	call   800de2 <ipc_recv>
}
  80152a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80152d:	5b                   	pop    %ebx
  80152e:	5e                   	pop    %esi
  80152f:	5d                   	pop    %ebp
  801530:	c3                   	ret    

00801531 <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801531:	55                   	push   %ebp
  801532:	89 e5                	mov    %esp,%ebp
  801534:	53                   	push   %ebx
  801535:	83 ec 04             	sub    $0x4,%esp
  801538:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80153b:	8b 45 08             	mov    0x8(%ebp),%eax
  80153e:	8b 40 0c             	mov    0xc(%eax),%eax
  801541:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801546:	ba 00 00 00 00       	mov    $0x0,%edx
  80154b:	b8 05 00 00 00       	mov    $0x5,%eax
  801550:	e8 91 ff ff ff       	call   8014e6 <fsipc>
  801555:	85 c0                	test   %eax,%eax
  801557:	78 2c                	js     801585 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801559:	83 ec 08             	sub    $0x8,%esp
  80155c:	68 00 50 80 00       	push   $0x805000
  801561:	53                   	push   %ebx
  801562:	e8 1a f2 ff ff       	call   800781 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801567:	a1 80 50 80 00       	mov    0x805080,%eax
  80156c:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801572:	a1 84 50 80 00       	mov    0x805084,%eax
  801577:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80157d:	83 c4 10             	add    $0x10,%esp
  801580:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801585:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801588:	c9                   	leave  
  801589:	c3                   	ret    

0080158a <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80158a:	55                   	push   %ebp
  80158b:	89 e5                	mov    %esp,%ebp
  80158d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801590:	8b 45 08             	mov    0x8(%ebp),%eax
  801593:	8b 40 0c             	mov    0xc(%eax),%eax
  801596:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80159b:	ba 00 00 00 00       	mov    $0x0,%edx
  8015a0:	b8 06 00 00 00       	mov    $0x6,%eax
  8015a5:	e8 3c ff ff ff       	call   8014e6 <fsipc>
}
  8015aa:	c9                   	leave  
  8015ab:	c3                   	ret    

008015ac <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8015ac:	55                   	push   %ebp
  8015ad:	89 e5                	mov    %esp,%ebp
  8015af:	56                   	push   %esi
  8015b0:	53                   	push   %ebx
  8015b1:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8015b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8015b7:	8b 40 0c             	mov    0xc(%eax),%eax
  8015ba:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8015bf:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8015c5:	ba 00 00 00 00       	mov    $0x0,%edx
  8015ca:	b8 03 00 00 00       	mov    $0x3,%eax
  8015cf:	e8 12 ff ff ff       	call   8014e6 <fsipc>
  8015d4:	89 c3                	mov    %eax,%ebx
  8015d6:	85 c0                	test   %eax,%eax
  8015d8:	78 4b                	js     801625 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8015da:	39 c6                	cmp    %eax,%esi
  8015dc:	73 16                	jae    8015f4 <devfile_read+0x48>
  8015de:	68 a2 22 80 00       	push   $0x8022a2
  8015e3:	68 a9 22 80 00       	push   $0x8022a9
  8015e8:	6a 7a                	push   $0x7a
  8015ea:	68 be 22 80 00       	push   $0x8022be
  8015ef:	e8 b5 05 00 00       	call   801ba9 <_panic>
	assert(r <= PGSIZE);
  8015f4:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8015f9:	7e 16                	jle    801611 <devfile_read+0x65>
  8015fb:	68 c9 22 80 00       	push   $0x8022c9
  801600:	68 a9 22 80 00       	push   $0x8022a9
  801605:	6a 7b                	push   $0x7b
  801607:	68 be 22 80 00       	push   $0x8022be
  80160c:	e8 98 05 00 00       	call   801ba9 <_panic>
	memmove(buf, &fsipcbuf, r);
  801611:	83 ec 04             	sub    $0x4,%esp
  801614:	50                   	push   %eax
  801615:	68 00 50 80 00       	push   $0x805000
  80161a:	ff 75 0c             	pushl  0xc(%ebp)
  80161d:	e8 2c f3 ff ff       	call   80094e <memmove>
	return r;
  801622:	83 c4 10             	add    $0x10,%esp
}
  801625:	89 d8                	mov    %ebx,%eax
  801627:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80162a:	5b                   	pop    %ebx
  80162b:	5e                   	pop    %esi
  80162c:	5d                   	pop    %ebp
  80162d:	c3                   	ret    

0080162e <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80162e:	55                   	push   %ebp
  80162f:	89 e5                	mov    %esp,%ebp
  801631:	53                   	push   %ebx
  801632:	83 ec 20             	sub    $0x20,%esp
  801635:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801638:	53                   	push   %ebx
  801639:	e8 ec f0 ff ff       	call   80072a <strlen>
  80163e:	83 c4 10             	add    $0x10,%esp
  801641:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801646:	7f 63                	jg     8016ab <open+0x7d>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801648:	83 ec 0c             	sub    $0xc,%esp
  80164b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80164e:	50                   	push   %eax
  80164f:	e8 e4 f8 ff ff       	call   800f38 <fd_alloc>
  801654:	83 c4 10             	add    $0x10,%esp
  801657:	85 c0                	test   %eax,%eax
  801659:	78 55                	js     8016b0 <open+0x82>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80165b:	83 ec 08             	sub    $0x8,%esp
  80165e:	53                   	push   %ebx
  80165f:	68 00 50 80 00       	push   $0x805000
  801664:	e8 18 f1 ff ff       	call   800781 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801669:	8b 45 0c             	mov    0xc(%ebp),%eax
  80166c:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801671:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801674:	b8 01 00 00 00       	mov    $0x1,%eax
  801679:	e8 68 fe ff ff       	call   8014e6 <fsipc>
  80167e:	89 c3                	mov    %eax,%ebx
  801680:	83 c4 10             	add    $0x10,%esp
  801683:	85 c0                	test   %eax,%eax
  801685:	79 14                	jns    80169b <open+0x6d>
		fd_close(fd, 0);
  801687:	83 ec 08             	sub    $0x8,%esp
  80168a:	6a 00                	push   $0x0
  80168c:	ff 75 f4             	pushl  -0xc(%ebp)
  80168f:	e8 dd f9 ff ff       	call   801071 <fd_close>
		return r;
  801694:	83 c4 10             	add    $0x10,%esp
  801697:	89 d8                	mov    %ebx,%eax
  801699:	eb 15                	jmp    8016b0 <open+0x82>
	}

	return fd2num(fd);
  80169b:	83 ec 0c             	sub    $0xc,%esp
  80169e:	ff 75 f4             	pushl  -0xc(%ebp)
  8016a1:	e8 6b f8 ff ff       	call   800f11 <fd2num>
  8016a6:	83 c4 10             	add    $0x10,%esp
  8016a9:	eb 05                	jmp    8016b0 <open+0x82>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8016ab:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8016b0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016b3:	c9                   	leave  
  8016b4:	c3                   	ret    

008016b5 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8016b5:	55                   	push   %ebp
  8016b6:	89 e5                	mov    %esp,%ebp
  8016b8:	56                   	push   %esi
  8016b9:	53                   	push   %ebx
  8016ba:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8016bd:	83 ec 0c             	sub    $0xc,%esp
  8016c0:	ff 75 08             	pushl  0x8(%ebp)
  8016c3:	e8 59 f8 ff ff       	call   800f21 <fd2data>
  8016c8:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8016ca:	83 c4 08             	add    $0x8,%esp
  8016cd:	68 d5 22 80 00       	push   $0x8022d5
  8016d2:	53                   	push   %ebx
  8016d3:	e8 a9 f0 ff ff       	call   800781 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8016d8:	8b 46 04             	mov    0x4(%esi),%eax
  8016db:	2b 06                	sub    (%esi),%eax
  8016dd:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8016e3:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016ea:	00 00 00 
	stat->st_dev = &devpipe;
  8016ed:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8016f4:	30 80 00 
	return 0;
}
  8016f7:	b8 00 00 00 00       	mov    $0x0,%eax
  8016fc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016ff:	5b                   	pop    %ebx
  801700:	5e                   	pop    %esi
  801701:	5d                   	pop    %ebp
  801702:	c3                   	ret    

00801703 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801703:	55                   	push   %ebp
  801704:	89 e5                	mov    %esp,%ebp
  801706:	53                   	push   %ebx
  801707:	83 ec 0c             	sub    $0xc,%esp
  80170a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80170d:	53                   	push   %ebx
  80170e:	6a 00                	push   $0x0
  801710:	e8 61 f5 ff ff       	call   800c76 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801715:	89 1c 24             	mov    %ebx,(%esp)
  801718:	e8 04 f8 ff ff       	call   800f21 <fd2data>
  80171d:	83 c4 08             	add    $0x8,%esp
  801720:	50                   	push   %eax
  801721:	6a 00                	push   $0x0
  801723:	e8 4e f5 ff ff       	call   800c76 <sys_page_unmap>
}
  801728:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80172b:	c9                   	leave  
  80172c:	c3                   	ret    

0080172d <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80172d:	55                   	push   %ebp
  80172e:	89 e5                	mov    %esp,%ebp
  801730:	57                   	push   %edi
  801731:	56                   	push   %esi
  801732:	53                   	push   %ebx
  801733:	83 ec 1c             	sub    $0x1c,%esp
  801736:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801739:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80173b:	a1 04 40 80 00       	mov    0x804004,%eax
  801740:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801743:	83 ec 0c             	sub    $0xc,%esp
  801746:	ff 75 e0             	pushl  -0x20(%ebp)
  801749:	e8 a1 04 00 00       	call   801bef <pageref>
  80174e:	89 c3                	mov    %eax,%ebx
  801750:	89 3c 24             	mov    %edi,(%esp)
  801753:	e8 97 04 00 00       	call   801bef <pageref>
  801758:	83 c4 10             	add    $0x10,%esp
  80175b:	39 c3                	cmp    %eax,%ebx
  80175d:	0f 94 c1             	sete   %cl
  801760:	0f b6 c9             	movzbl %cl,%ecx
  801763:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801766:	8b 15 04 40 80 00    	mov    0x804004,%edx
  80176c:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  80176f:	39 ce                	cmp    %ecx,%esi
  801771:	74 1b                	je     80178e <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801773:	39 c3                	cmp    %eax,%ebx
  801775:	75 c4                	jne    80173b <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801777:	8b 42 58             	mov    0x58(%edx),%eax
  80177a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80177d:	50                   	push   %eax
  80177e:	56                   	push   %esi
  80177f:	68 dc 22 80 00       	push   $0x8022dc
  801784:	e8 13 ea ff ff       	call   80019c <cprintf>
  801789:	83 c4 10             	add    $0x10,%esp
  80178c:	eb ad                	jmp    80173b <_pipeisclosed+0xe>
	}
}
  80178e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801791:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801794:	5b                   	pop    %ebx
  801795:	5e                   	pop    %esi
  801796:	5f                   	pop    %edi
  801797:	5d                   	pop    %ebp
  801798:	c3                   	ret    

00801799 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801799:	55                   	push   %ebp
  80179a:	89 e5                	mov    %esp,%ebp
  80179c:	57                   	push   %edi
  80179d:	56                   	push   %esi
  80179e:	53                   	push   %ebx
  80179f:	83 ec 18             	sub    $0x18,%esp
  8017a2:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8017a5:	56                   	push   %esi
  8017a6:	e8 76 f7 ff ff       	call   800f21 <fd2data>
  8017ab:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8017ad:	83 c4 10             	add    $0x10,%esp
  8017b0:	bf 00 00 00 00       	mov    $0x0,%edi
  8017b5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8017b9:	75 42                	jne    8017fd <devpipe_write+0x64>
  8017bb:	eb 4e                	jmp    80180b <devpipe_write+0x72>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8017bd:	89 da                	mov    %ebx,%edx
  8017bf:	89 f0                	mov    %esi,%eax
  8017c1:	e8 67 ff ff ff       	call   80172d <_pipeisclosed>
  8017c6:	85 c0                	test   %eax,%eax
  8017c8:	75 46                	jne    801810 <devpipe_write+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8017ca:	e8 03 f4 ff ff       	call   800bd2 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8017cf:	8b 53 04             	mov    0x4(%ebx),%edx
  8017d2:	8b 03                	mov    (%ebx),%eax
  8017d4:	83 c0 20             	add    $0x20,%eax
  8017d7:	39 c2                	cmp    %eax,%edx
  8017d9:	73 e2                	jae    8017bd <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8017db:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017de:	8a 0c 38             	mov    (%eax,%edi,1),%cl
  8017e1:	89 d0                	mov    %edx,%eax
  8017e3:	25 1f 00 00 80       	and    $0x8000001f,%eax
  8017e8:	79 05                	jns    8017ef <devpipe_write+0x56>
  8017ea:	48                   	dec    %eax
  8017eb:	83 c8 e0             	or     $0xffffffe0,%eax
  8017ee:	40                   	inc    %eax
  8017ef:	88 4c 03 08          	mov    %cl,0x8(%ebx,%eax,1)
		p->p_wpos++;
  8017f3:	42                   	inc    %edx
  8017f4:	89 53 04             	mov    %edx,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8017f7:	47                   	inc    %edi
  8017f8:	39 7d 10             	cmp    %edi,0x10(%ebp)
  8017fb:	74 0e                	je     80180b <devpipe_write+0x72>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8017fd:	8b 53 04             	mov    0x4(%ebx),%edx
  801800:	8b 03                	mov    (%ebx),%eax
  801802:	83 c0 20             	add    $0x20,%eax
  801805:	39 c2                	cmp    %eax,%edx
  801807:	73 b4                	jae    8017bd <devpipe_write+0x24>
  801809:	eb d0                	jmp    8017db <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80180b:	8b 45 10             	mov    0x10(%ebp),%eax
  80180e:	eb 05                	jmp    801815 <devpipe_write+0x7c>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801810:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801815:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801818:	5b                   	pop    %ebx
  801819:	5e                   	pop    %esi
  80181a:	5f                   	pop    %edi
  80181b:	5d                   	pop    %ebp
  80181c:	c3                   	ret    

0080181d <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80181d:	55                   	push   %ebp
  80181e:	89 e5                	mov    %esp,%ebp
  801820:	57                   	push   %edi
  801821:	56                   	push   %esi
  801822:	53                   	push   %ebx
  801823:	83 ec 18             	sub    $0x18,%esp
  801826:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801829:	57                   	push   %edi
  80182a:	e8 f2 f6 ff ff       	call   800f21 <fd2data>
  80182f:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801831:	83 c4 10             	add    $0x10,%esp
  801834:	be 00 00 00 00       	mov    $0x0,%esi
  801839:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80183d:	75 3d                	jne    80187c <devpipe_read+0x5f>
  80183f:	eb 48                	jmp    801889 <devpipe_read+0x6c>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  801841:	89 f0                	mov    %esi,%eax
  801843:	eb 4e                	jmp    801893 <devpipe_read+0x76>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801845:	89 da                	mov    %ebx,%edx
  801847:	89 f8                	mov    %edi,%eax
  801849:	e8 df fe ff ff       	call   80172d <_pipeisclosed>
  80184e:	85 c0                	test   %eax,%eax
  801850:	75 3c                	jne    80188e <devpipe_read+0x71>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801852:	e8 7b f3 ff ff       	call   800bd2 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801857:	8b 03                	mov    (%ebx),%eax
  801859:	3b 43 04             	cmp    0x4(%ebx),%eax
  80185c:	74 e7                	je     801845 <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80185e:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801863:	79 05                	jns    80186a <devpipe_read+0x4d>
  801865:	48                   	dec    %eax
  801866:	83 c8 e0             	or     $0xffffffe0,%eax
  801869:	40                   	inc    %eax
  80186a:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  80186e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801871:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801874:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801876:	46                   	inc    %esi
  801877:	39 75 10             	cmp    %esi,0x10(%ebp)
  80187a:	74 0d                	je     801889 <devpipe_read+0x6c>
		while (p->p_rpos == p->p_wpos) {
  80187c:	8b 03                	mov    (%ebx),%eax
  80187e:	3b 43 04             	cmp    0x4(%ebx),%eax
  801881:	75 db                	jne    80185e <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801883:	85 f6                	test   %esi,%esi
  801885:	75 ba                	jne    801841 <devpipe_read+0x24>
  801887:	eb bc                	jmp    801845 <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801889:	8b 45 10             	mov    0x10(%ebp),%eax
  80188c:	eb 05                	jmp    801893 <devpipe_read+0x76>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80188e:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801893:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801896:	5b                   	pop    %ebx
  801897:	5e                   	pop    %esi
  801898:	5f                   	pop    %edi
  801899:	5d                   	pop    %ebp
  80189a:	c3                   	ret    

0080189b <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80189b:	55                   	push   %ebp
  80189c:	89 e5                	mov    %esp,%ebp
  80189e:	56                   	push   %esi
  80189f:	53                   	push   %ebx
  8018a0:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8018a3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018a6:	50                   	push   %eax
  8018a7:	e8 8c f6 ff ff       	call   800f38 <fd_alloc>
  8018ac:	83 c4 10             	add    $0x10,%esp
  8018af:	85 c0                	test   %eax,%eax
  8018b1:	0f 88 2a 01 00 00    	js     8019e1 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018b7:	83 ec 04             	sub    $0x4,%esp
  8018ba:	68 07 04 00 00       	push   $0x407
  8018bf:	ff 75 f4             	pushl  -0xc(%ebp)
  8018c2:	6a 00                	push   $0x0
  8018c4:	e8 28 f3 ff ff       	call   800bf1 <sys_page_alloc>
  8018c9:	83 c4 10             	add    $0x10,%esp
  8018cc:	85 c0                	test   %eax,%eax
  8018ce:	0f 88 0d 01 00 00    	js     8019e1 <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8018d4:	83 ec 0c             	sub    $0xc,%esp
  8018d7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018da:	50                   	push   %eax
  8018db:	e8 58 f6 ff ff       	call   800f38 <fd_alloc>
  8018e0:	89 c3                	mov    %eax,%ebx
  8018e2:	83 c4 10             	add    $0x10,%esp
  8018e5:	85 c0                	test   %eax,%eax
  8018e7:	0f 88 e2 00 00 00    	js     8019cf <pipe+0x134>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018ed:	83 ec 04             	sub    $0x4,%esp
  8018f0:	68 07 04 00 00       	push   $0x407
  8018f5:	ff 75 f0             	pushl  -0x10(%ebp)
  8018f8:	6a 00                	push   $0x0
  8018fa:	e8 f2 f2 ff ff       	call   800bf1 <sys_page_alloc>
  8018ff:	89 c3                	mov    %eax,%ebx
  801901:	83 c4 10             	add    $0x10,%esp
  801904:	85 c0                	test   %eax,%eax
  801906:	0f 88 c3 00 00 00    	js     8019cf <pipe+0x134>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80190c:	83 ec 0c             	sub    $0xc,%esp
  80190f:	ff 75 f4             	pushl  -0xc(%ebp)
  801912:	e8 0a f6 ff ff       	call   800f21 <fd2data>
  801917:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801919:	83 c4 0c             	add    $0xc,%esp
  80191c:	68 07 04 00 00       	push   $0x407
  801921:	50                   	push   %eax
  801922:	6a 00                	push   $0x0
  801924:	e8 c8 f2 ff ff       	call   800bf1 <sys_page_alloc>
  801929:	89 c3                	mov    %eax,%ebx
  80192b:	83 c4 10             	add    $0x10,%esp
  80192e:	85 c0                	test   %eax,%eax
  801930:	0f 88 89 00 00 00    	js     8019bf <pipe+0x124>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801936:	83 ec 0c             	sub    $0xc,%esp
  801939:	ff 75 f0             	pushl  -0x10(%ebp)
  80193c:	e8 e0 f5 ff ff       	call   800f21 <fd2data>
  801941:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801948:	50                   	push   %eax
  801949:	6a 00                	push   $0x0
  80194b:	56                   	push   %esi
  80194c:	6a 00                	push   $0x0
  80194e:	e8 e1 f2 ff ff       	call   800c34 <sys_page_map>
  801953:	89 c3                	mov    %eax,%ebx
  801955:	83 c4 20             	add    $0x20,%esp
  801958:	85 c0                	test   %eax,%eax
  80195a:	78 55                	js     8019b1 <pipe+0x116>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80195c:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801962:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801965:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801967:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80196a:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801971:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801977:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80197a:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80197c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80197f:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801986:	83 ec 0c             	sub    $0xc,%esp
  801989:	ff 75 f4             	pushl  -0xc(%ebp)
  80198c:	e8 80 f5 ff ff       	call   800f11 <fd2num>
  801991:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801994:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801996:	83 c4 04             	add    $0x4,%esp
  801999:	ff 75 f0             	pushl  -0x10(%ebp)
  80199c:	e8 70 f5 ff ff       	call   800f11 <fd2num>
  8019a1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8019a4:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8019a7:	83 c4 10             	add    $0x10,%esp
  8019aa:	b8 00 00 00 00       	mov    $0x0,%eax
  8019af:	eb 30                	jmp    8019e1 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  8019b1:	83 ec 08             	sub    $0x8,%esp
  8019b4:	56                   	push   %esi
  8019b5:	6a 00                	push   $0x0
  8019b7:	e8 ba f2 ff ff       	call   800c76 <sys_page_unmap>
  8019bc:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8019bf:	83 ec 08             	sub    $0x8,%esp
  8019c2:	ff 75 f0             	pushl  -0x10(%ebp)
  8019c5:	6a 00                	push   $0x0
  8019c7:	e8 aa f2 ff ff       	call   800c76 <sys_page_unmap>
  8019cc:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8019cf:	83 ec 08             	sub    $0x8,%esp
  8019d2:	ff 75 f4             	pushl  -0xc(%ebp)
  8019d5:	6a 00                	push   $0x0
  8019d7:	e8 9a f2 ff ff       	call   800c76 <sys_page_unmap>
  8019dc:	83 c4 10             	add    $0x10,%esp
  8019df:	89 d8                	mov    %ebx,%eax
    err:
	return r;
}
  8019e1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019e4:	5b                   	pop    %ebx
  8019e5:	5e                   	pop    %esi
  8019e6:	5d                   	pop    %ebp
  8019e7:	c3                   	ret    

008019e8 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8019e8:	55                   	push   %ebp
  8019e9:	89 e5                	mov    %esp,%ebp
  8019eb:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8019ee:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019f1:	50                   	push   %eax
  8019f2:	ff 75 08             	pushl  0x8(%ebp)
  8019f5:	e8 b2 f5 ff ff       	call   800fac <fd_lookup>
  8019fa:	83 c4 10             	add    $0x10,%esp
  8019fd:	85 c0                	test   %eax,%eax
  8019ff:	78 18                	js     801a19 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801a01:	83 ec 0c             	sub    $0xc,%esp
  801a04:	ff 75 f4             	pushl  -0xc(%ebp)
  801a07:	e8 15 f5 ff ff       	call   800f21 <fd2data>
	return _pipeisclosed(fd, p);
  801a0c:	89 c2                	mov    %eax,%edx
  801a0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a11:	e8 17 fd ff ff       	call   80172d <_pipeisclosed>
  801a16:	83 c4 10             	add    $0x10,%esp
}
  801a19:	c9                   	leave  
  801a1a:	c3                   	ret    

00801a1b <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801a1b:	55                   	push   %ebp
  801a1c:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801a1e:	b8 00 00 00 00       	mov    $0x0,%eax
  801a23:	5d                   	pop    %ebp
  801a24:	c3                   	ret    

00801a25 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801a25:	55                   	push   %ebp
  801a26:	89 e5                	mov    %esp,%ebp
  801a28:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801a2b:	68 f4 22 80 00       	push   $0x8022f4
  801a30:	ff 75 0c             	pushl  0xc(%ebp)
  801a33:	e8 49 ed ff ff       	call   800781 <strcpy>
	return 0;
}
  801a38:	b8 00 00 00 00       	mov    $0x0,%eax
  801a3d:	c9                   	leave  
  801a3e:	c3                   	ret    

00801a3f <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a3f:	55                   	push   %ebp
  801a40:	89 e5                	mov    %esp,%ebp
  801a42:	57                   	push   %edi
  801a43:	56                   	push   %esi
  801a44:	53                   	push   %ebx
  801a45:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801a4b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801a4f:	74 45                	je     801a96 <devcons_write+0x57>
  801a51:	b8 00 00 00 00       	mov    $0x0,%eax
  801a56:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801a5b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801a61:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801a64:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  801a66:	83 fb 7f             	cmp    $0x7f,%ebx
  801a69:	76 05                	jbe    801a70 <devcons_write+0x31>
			m = sizeof(buf) - 1;
  801a6b:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801a70:	83 ec 04             	sub    $0x4,%esp
  801a73:	53                   	push   %ebx
  801a74:	03 45 0c             	add    0xc(%ebp),%eax
  801a77:	50                   	push   %eax
  801a78:	57                   	push   %edi
  801a79:	e8 d0 ee ff ff       	call   80094e <memmove>
		sys_cputs(buf, m);
  801a7e:	83 c4 08             	add    $0x8,%esp
  801a81:	53                   	push   %ebx
  801a82:	57                   	push   %edi
  801a83:	e8 ad f0 ff ff       	call   800b35 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801a88:	01 de                	add    %ebx,%esi
  801a8a:	89 f0                	mov    %esi,%eax
  801a8c:	83 c4 10             	add    $0x10,%esp
  801a8f:	3b 75 10             	cmp    0x10(%ebp),%esi
  801a92:	72 cd                	jb     801a61 <devcons_write+0x22>
  801a94:	eb 05                	jmp    801a9b <devcons_write+0x5c>
  801a96:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801a9b:	89 f0                	mov    %esi,%eax
  801a9d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801aa0:	5b                   	pop    %ebx
  801aa1:	5e                   	pop    %esi
  801aa2:	5f                   	pop    %edi
  801aa3:	5d                   	pop    %ebp
  801aa4:	c3                   	ret    

00801aa5 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801aa5:	55                   	push   %ebp
  801aa6:	89 e5                	mov    %esp,%ebp
  801aa8:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801aab:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801aaf:	75 07                	jne    801ab8 <devcons_read+0x13>
  801ab1:	eb 23                	jmp    801ad6 <devcons_read+0x31>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801ab3:	e8 1a f1 ff ff       	call   800bd2 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801ab8:	e8 96 f0 ff ff       	call   800b53 <sys_cgetc>
  801abd:	85 c0                	test   %eax,%eax
  801abf:	74 f2                	je     801ab3 <devcons_read+0xe>
		sys_yield();
	if (c < 0)
  801ac1:	85 c0                	test   %eax,%eax
  801ac3:	78 1d                	js     801ae2 <devcons_read+0x3d>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801ac5:	83 f8 04             	cmp    $0x4,%eax
  801ac8:	74 13                	je     801add <devcons_read+0x38>
		return 0;
	*(char*)vbuf = c;
  801aca:	8b 55 0c             	mov    0xc(%ebp),%edx
  801acd:	88 02                	mov    %al,(%edx)
	return 1;
  801acf:	b8 01 00 00 00       	mov    $0x1,%eax
  801ad4:	eb 0c                	jmp    801ae2 <devcons_read+0x3d>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801ad6:	b8 00 00 00 00       	mov    $0x0,%eax
  801adb:	eb 05                	jmp    801ae2 <devcons_read+0x3d>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801add:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801ae2:	c9                   	leave  
  801ae3:	c3                   	ret    

00801ae4 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801ae4:	55                   	push   %ebp
  801ae5:	89 e5                	mov    %esp,%ebp
  801ae7:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801aea:	8b 45 08             	mov    0x8(%ebp),%eax
  801aed:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801af0:	6a 01                	push   $0x1
  801af2:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801af5:	50                   	push   %eax
  801af6:	e8 3a f0 ff ff       	call   800b35 <sys_cputs>
}
  801afb:	83 c4 10             	add    $0x10,%esp
  801afe:	c9                   	leave  
  801aff:	c3                   	ret    

00801b00 <getchar>:

int
getchar(void)
{
  801b00:	55                   	push   %ebp
  801b01:	89 e5                	mov    %esp,%ebp
  801b03:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801b06:	6a 01                	push   $0x1
  801b08:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801b0b:	50                   	push   %eax
  801b0c:	6a 00                	push   $0x0
  801b0e:	e8 1a f7 ff ff       	call   80122d <read>
	if (r < 0)
  801b13:	83 c4 10             	add    $0x10,%esp
  801b16:	85 c0                	test   %eax,%eax
  801b18:	78 0f                	js     801b29 <getchar+0x29>
		return r;
	if (r < 1)
  801b1a:	85 c0                	test   %eax,%eax
  801b1c:	7e 06                	jle    801b24 <getchar+0x24>
		return -E_EOF;
	return c;
  801b1e:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801b22:	eb 05                	jmp    801b29 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801b24:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801b29:	c9                   	leave  
  801b2a:	c3                   	ret    

00801b2b <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801b2b:	55                   	push   %ebp
  801b2c:	89 e5                	mov    %esp,%ebp
  801b2e:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b31:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b34:	50                   	push   %eax
  801b35:	ff 75 08             	pushl  0x8(%ebp)
  801b38:	e8 6f f4 ff ff       	call   800fac <fd_lookup>
  801b3d:	83 c4 10             	add    $0x10,%esp
  801b40:	85 c0                	test   %eax,%eax
  801b42:	78 11                	js     801b55 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801b44:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b47:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801b4d:	39 10                	cmp    %edx,(%eax)
  801b4f:	0f 94 c0             	sete   %al
  801b52:	0f b6 c0             	movzbl %al,%eax
}
  801b55:	c9                   	leave  
  801b56:	c3                   	ret    

00801b57 <opencons>:

int
opencons(void)
{
  801b57:	55                   	push   %ebp
  801b58:	89 e5                	mov    %esp,%ebp
  801b5a:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801b5d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b60:	50                   	push   %eax
  801b61:	e8 d2 f3 ff ff       	call   800f38 <fd_alloc>
  801b66:	83 c4 10             	add    $0x10,%esp
  801b69:	85 c0                	test   %eax,%eax
  801b6b:	78 3a                	js     801ba7 <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801b6d:	83 ec 04             	sub    $0x4,%esp
  801b70:	68 07 04 00 00       	push   $0x407
  801b75:	ff 75 f4             	pushl  -0xc(%ebp)
  801b78:	6a 00                	push   $0x0
  801b7a:	e8 72 f0 ff ff       	call   800bf1 <sys_page_alloc>
  801b7f:	83 c4 10             	add    $0x10,%esp
  801b82:	85 c0                	test   %eax,%eax
  801b84:	78 21                	js     801ba7 <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801b86:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801b8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b8f:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801b91:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b94:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801b9b:	83 ec 0c             	sub    $0xc,%esp
  801b9e:	50                   	push   %eax
  801b9f:	e8 6d f3 ff ff       	call   800f11 <fd2num>
  801ba4:	83 c4 10             	add    $0x10,%esp
}
  801ba7:	c9                   	leave  
  801ba8:	c3                   	ret    

00801ba9 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801ba9:	55                   	push   %ebp
  801baa:	89 e5                	mov    %esp,%ebp
  801bac:	56                   	push   %esi
  801bad:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801bae:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801bb1:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801bb7:	e8 f7 ef ff ff       	call   800bb3 <sys_getenvid>
  801bbc:	83 ec 0c             	sub    $0xc,%esp
  801bbf:	ff 75 0c             	pushl  0xc(%ebp)
  801bc2:	ff 75 08             	pushl  0x8(%ebp)
  801bc5:	56                   	push   %esi
  801bc6:	50                   	push   %eax
  801bc7:	68 00 23 80 00       	push   $0x802300
  801bcc:	e8 cb e5 ff ff       	call   80019c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801bd1:	83 c4 18             	add    $0x18,%esp
  801bd4:	53                   	push   %ebx
  801bd5:	ff 75 10             	pushl  0x10(%ebp)
  801bd8:	e8 6e e5 ff ff       	call   80014b <vcprintf>
	cprintf("\n");
  801bdd:	c7 04 24 ed 22 80 00 	movl   $0x8022ed,(%esp)
  801be4:	e8 b3 e5 ff ff       	call   80019c <cprintf>
  801be9:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801bec:	cc                   	int3   
  801bed:	eb fd                	jmp    801bec <_panic+0x43>

00801bef <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801bef:	55                   	push   %ebp
  801bf0:	89 e5                	mov    %esp,%ebp
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801bf2:	8b 45 08             	mov    0x8(%ebp),%eax
  801bf5:	c1 e8 16             	shr    $0x16,%eax
  801bf8:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801bff:	a8 01                	test   $0x1,%al
  801c01:	74 21                	je     801c24 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801c03:	8b 45 08             	mov    0x8(%ebp),%eax
  801c06:	c1 e8 0c             	shr    $0xc,%eax
  801c09:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801c10:	a8 01                	test   $0x1,%al
  801c12:	74 17                	je     801c2b <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801c14:	c1 e8 0c             	shr    $0xc,%eax
  801c17:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801c1e:	ef 
  801c1f:	0f b7 c0             	movzwl %ax,%eax
  801c22:	eb 0c                	jmp    801c30 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801c24:	b8 00 00 00 00       	mov    $0x0,%eax
  801c29:	eb 05                	jmp    801c30 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801c2b:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801c30:	5d                   	pop    %ebp
  801c31:	c3                   	ret    
  801c32:	66 90                	xchg   %ax,%ax

00801c34 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801c34:	55                   	push   %ebp
  801c35:	57                   	push   %edi
  801c36:	56                   	push   %esi
  801c37:	53                   	push   %ebx
  801c38:	83 ec 1c             	sub    $0x1c,%esp
  801c3b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801c3f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801c43:	8b 7c 24 38          	mov    0x38(%esp),%edi
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801c47:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801c4b:	89 ca                	mov    %ecx,%edx
  const DWunion dd = {.ll = d};
  801c4d:	89 f8                	mov    %edi,%eax
  801c4f:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801c53:	85 f6                	test   %esi,%esi
  801c55:	75 2d                	jne    801c84 <__udivdi3+0x50>
    {
      if (d0 > n1)
  801c57:	39 cf                	cmp    %ecx,%edi
  801c59:	77 65                	ja     801cc0 <__udivdi3+0x8c>
  801c5b:	89 fd                	mov    %edi,%ebp
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801c5d:	85 ff                	test   %edi,%edi
  801c5f:	75 0b                	jne    801c6c <__udivdi3+0x38>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801c61:	b8 01 00 00 00       	mov    $0x1,%eax
  801c66:	31 d2                	xor    %edx,%edx
  801c68:	f7 f7                	div    %edi
  801c6a:	89 c5                	mov    %eax,%ebp

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801c6c:	31 d2                	xor    %edx,%edx
  801c6e:	89 c8                	mov    %ecx,%eax
  801c70:	f7 f5                	div    %ebp
  801c72:	89 c1                	mov    %eax,%ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801c74:	89 d8                	mov    %ebx,%eax
  801c76:	f7 f5                	div    %ebp
  801c78:	89 cf                	mov    %ecx,%edi
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801c7a:	89 fa                	mov    %edi,%edx
  801c7c:	83 c4 1c             	add    $0x1c,%esp
  801c7f:	5b                   	pop    %ebx
  801c80:	5e                   	pop    %esi
  801c81:	5f                   	pop    %edi
  801c82:	5d                   	pop    %ebp
  801c83:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801c84:	39 ce                	cmp    %ecx,%esi
  801c86:	77 28                	ja     801cb0 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801c88:	0f bd fe             	bsr    %esi,%edi
	  if (bm == 0)
  801c8b:	83 f7 1f             	xor    $0x1f,%edi
  801c8e:	75 40                	jne    801cd0 <__udivdi3+0x9c>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801c90:	39 ce                	cmp    %ecx,%esi
  801c92:	72 0a                	jb     801c9e <__udivdi3+0x6a>
  801c94:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801c98:	0f 87 9e 00 00 00    	ja     801d3c <__udivdi3+0x108>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801c9e:	b8 01 00 00 00       	mov    $0x1,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801ca3:	89 fa                	mov    %edi,%edx
  801ca5:	83 c4 1c             	add    $0x1c,%esp
  801ca8:	5b                   	pop    %ebx
  801ca9:	5e                   	pop    %esi
  801caa:	5f                   	pop    %edi
  801cab:	5d                   	pop    %ebp
  801cac:	c3                   	ret    
  801cad:	8d 76 00             	lea    0x0(%esi),%esi
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801cb0:	31 ff                	xor    %edi,%edi
  801cb2:	31 c0                	xor    %eax,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801cb4:	89 fa                	mov    %edi,%edx
  801cb6:	83 c4 1c             	add    $0x1c,%esp
  801cb9:	5b                   	pop    %ebx
  801cba:	5e                   	pop    %esi
  801cbb:	5f                   	pop    %edi
  801cbc:	5d                   	pop    %ebp
  801cbd:	c3                   	ret    
  801cbe:	66 90                	xchg   %ax,%ax
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801cc0:	89 d8                	mov    %ebx,%eax
  801cc2:	f7 f7                	div    %edi
  801cc4:	31 ff                	xor    %edi,%edi
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801cc6:	89 fa                	mov    %edi,%edx
  801cc8:	83 c4 1c             	add    $0x1c,%esp
  801ccb:	5b                   	pop    %ebx
  801ccc:	5e                   	pop    %esi
  801ccd:	5f                   	pop    %edi
  801cce:	5d                   	pop    %ebp
  801ccf:	c3                   	ret    
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801cd0:	bd 20 00 00 00       	mov    $0x20,%ebp
  801cd5:	89 eb                	mov    %ebp,%ebx
  801cd7:	29 fb                	sub    %edi,%ebx

	      d1 = (d1 << bm) | (d0 >> b);
  801cd9:	89 f9                	mov    %edi,%ecx
  801cdb:	d3 e6                	shl    %cl,%esi
  801cdd:	89 c5                	mov    %eax,%ebp
  801cdf:	88 d9                	mov    %bl,%cl
  801ce1:	d3 ed                	shr    %cl,%ebp
  801ce3:	89 e9                	mov    %ebp,%ecx
  801ce5:	09 f1                	or     %esi,%ecx
  801ce7:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
	      d0 = d0 << bm;
  801ceb:	89 f9                	mov    %edi,%ecx
  801ced:	d3 e0                	shl    %cl,%eax
  801cef:	89 c5                	mov    %eax,%ebp
	      n2 = n1 >> b;
  801cf1:	89 d6                	mov    %edx,%esi
  801cf3:	88 d9                	mov    %bl,%cl
  801cf5:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
  801cf7:	89 f9                	mov    %edi,%ecx
  801cf9:	d3 e2                	shl    %cl,%edx
  801cfb:	8b 44 24 08          	mov    0x8(%esp),%eax
  801cff:	88 d9                	mov    %bl,%cl
  801d01:	d3 e8                	shr    %cl,%eax
  801d03:	09 c2                	or     %eax,%edx
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801d05:	89 d0                	mov    %edx,%eax
  801d07:	89 f2                	mov    %esi,%edx
  801d09:	f7 74 24 0c          	divl   0xc(%esp)
  801d0d:	89 d6                	mov    %edx,%esi
  801d0f:	89 c3                	mov    %eax,%ebx
	      umul_ppmm (m1, m0, q0, d0);
  801d11:	f7 e5                	mul    %ebp

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801d13:	39 d6                	cmp    %edx,%esi
  801d15:	72 19                	jb     801d30 <__udivdi3+0xfc>
  801d17:	74 0b                	je     801d24 <__udivdi3+0xf0>
  801d19:	89 d8                	mov    %ebx,%eax
  801d1b:	31 ff                	xor    %edi,%edi
  801d1d:	e9 58 ff ff ff       	jmp    801c7a <__udivdi3+0x46>
  801d22:	66 90                	xchg   %ax,%ax
  801d24:	8b 54 24 08          	mov    0x8(%esp),%edx
  801d28:	89 f9                	mov    %edi,%ecx
  801d2a:	d3 e2                	shl    %cl,%edx
  801d2c:	39 c2                	cmp    %eax,%edx
  801d2e:	73 e9                	jae    801d19 <__udivdi3+0xe5>
  801d30:	8d 43 ff             	lea    -0x1(%ebx),%eax
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801d33:	31 ff                	xor    %edi,%edi
  801d35:	e9 40 ff ff ff       	jmp    801c7a <__udivdi3+0x46>
  801d3a:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801d3c:	31 c0                	xor    %eax,%eax
  801d3e:	e9 37 ff ff ff       	jmp    801c7a <__udivdi3+0x46>
  801d43:	90                   	nop

00801d44 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  801d44:	55                   	push   %ebp
  801d45:	57                   	push   %edi
  801d46:	56                   	push   %esi
  801d47:	53                   	push   %ebx
  801d48:	83 ec 1c             	sub    $0x1c,%esp
  801d4b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801d4f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801d53:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801d57:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801d5b:	89 44 24 0c          	mov    %eax,0xc(%esp)
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801d5f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801d63:	89 f3                	mov    %esi,%ebx
  const DWunion dd = {.ll = d};
  801d65:	89 fa                	mov    %edi,%edx
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  801d67:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  n1 = nn.s.high;
  801d6b:	89 34 24             	mov    %esi,(%esp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801d6e:	85 c0                	test   %eax,%eax
  801d70:	75 1a                	jne    801d8c <__umoddi3+0x48>
    {
      if (d0 > n1)
  801d72:	39 f7                	cmp    %esi,%edi
  801d74:	0f 86 a2 00 00 00    	jbe    801e1c <__umoddi3+0xd8>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801d7a:	89 c8                	mov    %ecx,%eax
  801d7c:	89 f2                	mov    %esi,%edx
  801d7e:	f7 f7                	div    %edi
  801d80:	89 d0                	mov    %edx,%eax

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  801d82:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801d84:	83 c4 1c             	add    $0x1c,%esp
  801d87:	5b                   	pop    %ebx
  801d88:	5e                   	pop    %esi
  801d89:	5f                   	pop    %edi
  801d8a:	5d                   	pop    %ebp
  801d8b:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801d8c:	39 f0                	cmp    %esi,%eax
  801d8e:	0f 87 ac 00 00 00    	ja     801e40 <__umoddi3+0xfc>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801d94:	0f bd e8             	bsr    %eax,%ebp
	  if (bm == 0)
  801d97:	83 f5 1f             	xor    $0x1f,%ebp
  801d9a:	0f 84 ac 00 00 00    	je     801e4c <__umoddi3+0x108>
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801da0:	bf 20 00 00 00       	mov    $0x20,%edi
  801da5:	29 ef                	sub    %ebp,%edi
  801da7:	89 fe                	mov    %edi,%esi
  801da9:	89 7c 24 0c          	mov    %edi,0xc(%esp)

	      d1 = (d1 << bm) | (d0 >> b);
  801dad:	89 e9                	mov    %ebp,%ecx
  801daf:	d3 e0                	shl    %cl,%eax
  801db1:	89 d7                	mov    %edx,%edi
  801db3:	89 f1                	mov    %esi,%ecx
  801db5:	d3 ef                	shr    %cl,%edi
  801db7:	09 c7                	or     %eax,%edi
	      d0 = d0 << bm;
  801db9:	89 e9                	mov    %ebp,%ecx
  801dbb:	d3 e2                	shl    %cl,%edx
  801dbd:	89 14 24             	mov    %edx,(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801dc0:	89 d8                	mov    %ebx,%eax
  801dc2:	d3 e0                	shl    %cl,%eax
  801dc4:	89 c2                	mov    %eax,%edx
	      n0 = n0 << bm;
  801dc6:	8b 44 24 08          	mov    0x8(%esp),%eax
  801dca:	d3 e0                	shl    %cl,%eax
  801dcc:	89 44 24 04          	mov    %eax,0x4(%esp)

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801dd0:	8b 44 24 08          	mov    0x8(%esp),%eax
  801dd4:	89 f1                	mov    %esi,%ecx
  801dd6:	d3 e8                	shr    %cl,%eax
  801dd8:	09 d0                	or     %edx,%eax
  801dda:	d3 eb                	shr    %cl,%ebx
  801ddc:	89 da                	mov    %ebx,%edx
  801dde:	f7 f7                	div    %edi
  801de0:	89 d3                	mov    %edx,%ebx
	      umul_ppmm (m1, m0, q0, d0);
  801de2:	f7 24 24             	mull   (%esp)
  801de5:	89 c6                	mov    %eax,%esi
  801de7:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801de9:	39 d3                	cmp    %edx,%ebx
  801deb:	0f 82 87 00 00 00    	jb     801e78 <__umoddi3+0x134>
  801df1:	0f 84 91 00 00 00    	je     801e88 <__umoddi3+0x144>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  801df7:	8b 54 24 04          	mov    0x4(%esp),%edx
  801dfb:	29 f2                	sub    %esi,%edx
  801dfd:	19 cb                	sbb    %ecx,%ebx
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801dff:	89 d8                	mov    %ebx,%eax
  801e01:	8a 4c 24 0c          	mov    0xc(%esp),%cl
  801e05:	d3 e0                	shl    %cl,%eax
  801e07:	89 e9                	mov    %ebp,%ecx
  801e09:	d3 ea                	shr    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  801e0b:	09 d0                	or     %edx,%eax
  801e0d:	89 e9                	mov    %ebp,%ecx
  801e0f:	d3 eb                	shr    %cl,%ebx
  801e11:	89 da                	mov    %ebx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801e13:	83 c4 1c             	add    $0x1c,%esp
  801e16:	5b                   	pop    %ebx
  801e17:	5e                   	pop    %esi
  801e18:	5f                   	pop    %edi
  801e19:	5d                   	pop    %ebp
  801e1a:	c3                   	ret    
  801e1b:	90                   	nop
  801e1c:	89 fd                	mov    %edi,%ebp
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801e1e:	85 ff                	test   %edi,%edi
  801e20:	75 0b                	jne    801e2d <__umoddi3+0xe9>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801e22:	b8 01 00 00 00       	mov    $0x1,%eax
  801e27:	31 d2                	xor    %edx,%edx
  801e29:	f7 f7                	div    %edi
  801e2b:	89 c5                	mov    %eax,%ebp

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801e2d:	89 f0                	mov    %esi,%eax
  801e2f:	31 d2                	xor    %edx,%edx
  801e31:	f7 f5                	div    %ebp
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801e33:	89 c8                	mov    %ecx,%eax
  801e35:	f7 f5                	div    %ebp
  801e37:	89 d0                	mov    %edx,%eax
  801e39:	e9 44 ff ff ff       	jmp    801d82 <__umoddi3+0x3e>
  801e3e:	66 90                	xchg   %ax,%ax
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  801e40:	89 c8                	mov    %ecx,%eax
  801e42:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801e44:	83 c4 1c             	add    $0x1c,%esp
  801e47:	5b                   	pop    %ebx
  801e48:	5e                   	pop    %esi
  801e49:	5f                   	pop    %edi
  801e4a:	5d                   	pop    %ebp
  801e4b:	c3                   	ret    

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801e4c:	3b 04 24             	cmp    (%esp),%eax
  801e4f:	72 06                	jb     801e57 <__umoddi3+0x113>
  801e51:	3b 7c 24 04          	cmp    0x4(%esp),%edi
  801e55:	77 0f                	ja     801e66 <__umoddi3+0x122>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801e57:	89 f2                	mov    %esi,%edx
  801e59:	29 f9                	sub    %edi,%ecx
  801e5b:	1b 54 24 0c          	sbb    0xc(%esp),%edx
  801e5f:	89 14 24             	mov    %edx,(%esp)
  801e62:	89 4c 24 04          	mov    %ecx,0x4(%esp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  801e66:	8b 44 24 04          	mov    0x4(%esp),%eax
  801e6a:	8b 14 24             	mov    (%esp),%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801e6d:	83 c4 1c             	add    $0x1c,%esp
  801e70:	5b                   	pop    %ebx
  801e71:	5e                   	pop    %esi
  801e72:	5f                   	pop    %edi
  801e73:	5d                   	pop    %ebp
  801e74:	c3                   	ret    
  801e75:	8d 76 00             	lea    0x0(%esi),%esi
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801e78:	2b 04 24             	sub    (%esp),%eax
  801e7b:	19 fa                	sbb    %edi,%edx
  801e7d:	89 d1                	mov    %edx,%ecx
  801e7f:	89 c6                	mov    %eax,%esi
  801e81:	e9 71 ff ff ff       	jmp    801df7 <__umoddi3+0xb3>
  801e86:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801e88:	39 44 24 04          	cmp    %eax,0x4(%esp)
  801e8c:	72 ea                	jb     801e78 <__umoddi3+0x134>
  801e8e:	89 d9                	mov    %ebx,%ecx
  801e90:	e9 62 ff ff ff       	jmp    801df7 <__umoddi3+0xb3>
