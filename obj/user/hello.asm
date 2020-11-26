
obj/user/hello.debug:     file format elf32-i386


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
  80002c:	e8 2d 00 00 00       	call   80005e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
// hello, world
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 14             	sub    $0x14,%esp
	cprintf("hello, world\n");
  800039:	68 60 1e 80 00       	push   $0x801e60
  80003e:	e8 16 01 00 00       	call   800159 <cprintf>
	cprintf("i am environment %08x\n", thisenv->env_id);
  800043:	a1 04 40 80 00       	mov    0x804004,%eax
  800048:	8b 40 48             	mov    0x48(%eax),%eax
  80004b:	83 c4 08             	add    $0x8,%esp
  80004e:	50                   	push   %eax
  80004f:	68 6e 1e 80 00       	push   $0x801e6e
  800054:	e8 00 01 00 00       	call   800159 <cprintf>
}
  800059:	83 c4 10             	add    $0x10,%esp
  80005c:	c9                   	leave  
  80005d:	c3                   	ret    

0080005e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80005e:	55                   	push   %ebp
  80005f:	89 e5                	mov    %esp,%ebp
  800061:	56                   	push   %esi
  800062:	53                   	push   %ebx
  800063:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800066:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800069:	e8 02 0b 00 00       	call   800b70 <sys_getenvid>
  80006e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800073:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80007a:	c1 e0 07             	shl    $0x7,%eax
  80007d:	29 d0                	sub    %edx,%eax
  80007f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800084:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800089:	85 db                	test   %ebx,%ebx
  80008b:	7e 07                	jle    800094 <libmain+0x36>
		binaryname = argv[0];
  80008d:	8b 06                	mov    (%esi),%eax
  80008f:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800094:	83 ec 08             	sub    $0x8,%esp
  800097:	56                   	push   %esi
  800098:	53                   	push   %ebx
  800099:	e8 95 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80009e:	e8 0a 00 00 00       	call   8000ad <exit>
}
  8000a3:	83 c4 10             	add    $0x10,%esp
  8000a6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000a9:	5b                   	pop    %ebx
  8000aa:	5e                   	pop    %esi
  8000ab:	5d                   	pop    %ebp
  8000ac:	c3                   	ret    

008000ad <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000ad:	55                   	push   %ebp
  8000ae:	89 e5                	mov    %esp,%ebp
  8000b0:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000b3:	e8 f6 0e 00 00       	call   800fae <close_all>
	sys_env_destroy(0);
  8000b8:	83 ec 0c             	sub    $0xc,%esp
  8000bb:	6a 00                	push   $0x0
  8000bd:	e8 6d 0a 00 00       	call   800b2f <sys_env_destroy>
}
  8000c2:	83 c4 10             	add    $0x10,%esp
  8000c5:	c9                   	leave  
  8000c6:	c3                   	ret    

008000c7 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000c7:	55                   	push   %ebp
  8000c8:	89 e5                	mov    %esp,%ebp
  8000ca:	53                   	push   %ebx
  8000cb:	83 ec 04             	sub    $0x4,%esp
  8000ce:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000d1:	8b 13                	mov    (%ebx),%edx
  8000d3:	8d 42 01             	lea    0x1(%edx),%eax
  8000d6:	89 03                	mov    %eax,(%ebx)
  8000d8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000db:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000df:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000e4:	75 1a                	jne    800100 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8000e6:	83 ec 08             	sub    $0x8,%esp
  8000e9:	68 ff 00 00 00       	push   $0xff
  8000ee:	8d 43 08             	lea    0x8(%ebx),%eax
  8000f1:	50                   	push   %eax
  8000f2:	e8 fb 09 00 00       	call   800af2 <sys_cputs>
		b->idx = 0;
  8000f7:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8000fd:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800100:	ff 43 04             	incl   0x4(%ebx)
}
  800103:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800106:	c9                   	leave  
  800107:	c3                   	ret    

00800108 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800108:	55                   	push   %ebp
  800109:	89 e5                	mov    %esp,%ebp
  80010b:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800111:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800118:	00 00 00 
	b.cnt = 0;
  80011b:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800122:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800125:	ff 75 0c             	pushl  0xc(%ebp)
  800128:	ff 75 08             	pushl  0x8(%ebp)
  80012b:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800131:	50                   	push   %eax
  800132:	68 c7 00 80 00       	push   $0x8000c7
  800137:	e8 54 01 00 00       	call   800290 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80013c:	83 c4 08             	add    $0x8,%esp
  80013f:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800145:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80014b:	50                   	push   %eax
  80014c:	e8 a1 09 00 00       	call   800af2 <sys_cputs>

	return b.cnt;
}
  800151:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800157:	c9                   	leave  
  800158:	c3                   	ret    

00800159 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800159:	55                   	push   %ebp
  80015a:	89 e5                	mov    %esp,%ebp
  80015c:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80015f:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800162:	50                   	push   %eax
  800163:	ff 75 08             	pushl  0x8(%ebp)
  800166:	e8 9d ff ff ff       	call   800108 <vcprintf>
	va_end(ap);

	return cnt;
}
  80016b:	c9                   	leave  
  80016c:	c3                   	ret    

0080016d <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80016d:	55                   	push   %ebp
  80016e:	89 e5                	mov    %esp,%ebp
  800170:	57                   	push   %edi
  800171:	56                   	push   %esi
  800172:	53                   	push   %ebx
  800173:	83 ec 1c             	sub    $0x1c,%esp
  800176:	89 c6                	mov    %eax,%esi
  800178:	89 d7                	mov    %edx,%edi
  80017a:	8b 45 08             	mov    0x8(%ebp),%eax
  80017d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800180:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800183:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800186:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800189:	bb 00 00 00 00       	mov    $0x0,%ebx
  80018e:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800191:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800194:	39 d3                	cmp    %edx,%ebx
  800196:	72 11                	jb     8001a9 <printnum+0x3c>
  800198:	39 45 10             	cmp    %eax,0x10(%ebp)
  80019b:	76 0c                	jbe    8001a9 <printnum+0x3c>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80019d:	8b 45 14             	mov    0x14(%ebp),%eax
  8001a0:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001a3:	85 db                	test   %ebx,%ebx
  8001a5:	7f 37                	jg     8001de <printnum+0x71>
  8001a7:	eb 44                	jmp    8001ed <printnum+0x80>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001a9:	83 ec 0c             	sub    $0xc,%esp
  8001ac:	ff 75 18             	pushl  0x18(%ebp)
  8001af:	8b 45 14             	mov    0x14(%ebp),%eax
  8001b2:	48                   	dec    %eax
  8001b3:	50                   	push   %eax
  8001b4:	ff 75 10             	pushl  0x10(%ebp)
  8001b7:	83 ec 08             	sub    $0x8,%esp
  8001ba:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001bd:	ff 75 e0             	pushl  -0x20(%ebp)
  8001c0:	ff 75 dc             	pushl  -0x24(%ebp)
  8001c3:	ff 75 d8             	pushl  -0x28(%ebp)
  8001c6:	e8 25 1a 00 00       	call   801bf0 <__udivdi3>
  8001cb:	83 c4 18             	add    $0x18,%esp
  8001ce:	52                   	push   %edx
  8001cf:	50                   	push   %eax
  8001d0:	89 fa                	mov    %edi,%edx
  8001d2:	89 f0                	mov    %esi,%eax
  8001d4:	e8 94 ff ff ff       	call   80016d <printnum>
  8001d9:	83 c4 20             	add    $0x20,%esp
  8001dc:	eb 0f                	jmp    8001ed <printnum+0x80>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001de:	83 ec 08             	sub    $0x8,%esp
  8001e1:	57                   	push   %edi
  8001e2:	ff 75 18             	pushl  0x18(%ebp)
  8001e5:	ff d6                	call   *%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001e7:	83 c4 10             	add    $0x10,%esp
  8001ea:	4b                   	dec    %ebx
  8001eb:	75 f1                	jne    8001de <printnum+0x71>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001ed:	83 ec 08             	sub    $0x8,%esp
  8001f0:	57                   	push   %edi
  8001f1:	83 ec 04             	sub    $0x4,%esp
  8001f4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001f7:	ff 75 e0             	pushl  -0x20(%ebp)
  8001fa:	ff 75 dc             	pushl  -0x24(%ebp)
  8001fd:	ff 75 d8             	pushl  -0x28(%ebp)
  800200:	e8 fb 1a 00 00       	call   801d00 <__umoddi3>
  800205:	83 c4 14             	add    $0x14,%esp
  800208:	0f be 80 8f 1e 80 00 	movsbl 0x801e8f(%eax),%eax
  80020f:	50                   	push   %eax
  800210:	ff d6                	call   *%esi
}
  800212:	83 c4 10             	add    $0x10,%esp
  800215:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800218:	5b                   	pop    %ebx
  800219:	5e                   	pop    %esi
  80021a:	5f                   	pop    %edi
  80021b:	5d                   	pop    %ebp
  80021c:	c3                   	ret    

0080021d <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80021d:	55                   	push   %ebp
  80021e:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800220:	83 fa 01             	cmp    $0x1,%edx
  800223:	7e 0e                	jle    800233 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800225:	8b 10                	mov    (%eax),%edx
  800227:	8d 4a 08             	lea    0x8(%edx),%ecx
  80022a:	89 08                	mov    %ecx,(%eax)
  80022c:	8b 02                	mov    (%edx),%eax
  80022e:	8b 52 04             	mov    0x4(%edx),%edx
  800231:	eb 22                	jmp    800255 <getuint+0x38>
	else if (lflag)
  800233:	85 d2                	test   %edx,%edx
  800235:	74 10                	je     800247 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800237:	8b 10                	mov    (%eax),%edx
  800239:	8d 4a 04             	lea    0x4(%edx),%ecx
  80023c:	89 08                	mov    %ecx,(%eax)
  80023e:	8b 02                	mov    (%edx),%eax
  800240:	ba 00 00 00 00       	mov    $0x0,%edx
  800245:	eb 0e                	jmp    800255 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800247:	8b 10                	mov    (%eax),%edx
  800249:	8d 4a 04             	lea    0x4(%edx),%ecx
  80024c:	89 08                	mov    %ecx,(%eax)
  80024e:	8b 02                	mov    (%edx),%eax
  800250:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800255:	5d                   	pop    %ebp
  800256:	c3                   	ret    

00800257 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800257:	55                   	push   %ebp
  800258:	89 e5                	mov    %esp,%ebp
  80025a:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80025d:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800260:	8b 10                	mov    (%eax),%edx
  800262:	3b 50 04             	cmp    0x4(%eax),%edx
  800265:	73 0a                	jae    800271 <sprintputch+0x1a>
		*b->buf++ = ch;
  800267:	8d 4a 01             	lea    0x1(%edx),%ecx
  80026a:	89 08                	mov    %ecx,(%eax)
  80026c:	8b 45 08             	mov    0x8(%ebp),%eax
  80026f:	88 02                	mov    %al,(%edx)
}
  800271:	5d                   	pop    %ebp
  800272:	c3                   	ret    

00800273 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800273:	55                   	push   %ebp
  800274:	89 e5                	mov    %esp,%ebp
  800276:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800279:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80027c:	50                   	push   %eax
  80027d:	ff 75 10             	pushl  0x10(%ebp)
  800280:	ff 75 0c             	pushl  0xc(%ebp)
  800283:	ff 75 08             	pushl  0x8(%ebp)
  800286:	e8 05 00 00 00       	call   800290 <vprintfmt>
	va_end(ap);
}
  80028b:	83 c4 10             	add    $0x10,%esp
  80028e:	c9                   	leave  
  80028f:	c3                   	ret    

00800290 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800290:	55                   	push   %ebp
  800291:	89 e5                	mov    %esp,%ebp
  800293:	57                   	push   %edi
  800294:	56                   	push   %esi
  800295:	53                   	push   %ebx
  800296:	83 ec 2c             	sub    $0x2c,%esp
  800299:	8b 7d 08             	mov    0x8(%ebp),%edi
  80029c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80029f:	eb 03                	jmp    8002a4 <vprintfmt+0x14>
			break;

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
			for (fmt--; fmt[-1] != '%'; fmt--)
  8002a1:	89 75 10             	mov    %esi,0x10(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {    //遍历输入的第一个参数，即输出信息的格式，先把格式字符串中'%'之前的字符一个个输出，因为它们前面没有'%'，所以它们就是要直接显示在屏幕上的
  8002a4:	8b 45 10             	mov    0x10(%ebp),%eax
  8002a7:	8d 70 01             	lea    0x1(%eax),%esi
  8002aa:	0f b6 00             	movzbl (%eax),%eax
  8002ad:	83 f8 25             	cmp    $0x25,%eax
  8002b0:	74 25                	je     8002d7 <vprintfmt+0x47>
			if (ch == '\0')									//当然中间如果遇到'\0'，代表这个字符串的访问结束
  8002b2:	85 c0                	test   %eax,%eax
  8002b4:	75 0d                	jne    8002c3 <vprintfmt+0x33>
  8002b6:	e9 b5 03 00 00       	jmp    800670 <vprintfmt+0x3e0>
  8002bb:	85 c0                	test   %eax,%eax
  8002bd:	0f 84 ad 03 00 00    	je     800670 <vprintfmt+0x3e0>
				return;
			putch(ch, putdat);								//调用putch函数，把一个字符ch输出到putdat指针所指向的地址中所存放的值对应的地址处
  8002c3:	83 ec 08             	sub    $0x8,%esp
  8002c6:	53                   	push   %ebx
  8002c7:	50                   	push   %eax
  8002c8:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {    //遍历输入的第一个参数，即输出信息的格式，先把格式字符串中'%'之前的字符一个个输出，因为它们前面没有'%'，所以它们就是要直接显示在屏幕上的
  8002ca:	46                   	inc    %esi
  8002cb:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  8002cf:	83 c4 10             	add    $0x10,%esp
  8002d2:	83 f8 25             	cmp    $0x25,%eax
  8002d5:	75 e4                	jne    8002bb <vprintfmt+0x2b>
			if (width < 0)									//代表有小数点，但是小数点前面并没有数字，比如'%.6f'这种情况，此时代表整数部分全部显示
				width = 0;			
			goto reswitch;

		case '#':
			altflag = 1;
  8002d7:	c6 45 e3 20          	movb   $0x20,-0x1d(%ebp)
  8002db:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8002e2:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8002e9:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8002f0:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8002f7:	eb 07                	jmp    800300 <vprintfmt+0x70>
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  8002f9:	8b 75 10             	mov    0x10(%ebp),%esi

		// flag to pad on the right
		case '-':											//%后面的'-'代表要进行左对齐输出，右边填空格，如果省略代表右对齐
			padc = '-';										//如果有这个字符代表左对齐，则把对齐方式标志位变为'-'
  8002fc:	c6 45 e3 2d          	movb   $0x2d,-0x1d(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  800300:	8d 46 01             	lea    0x1(%esi),%eax
  800303:	89 45 10             	mov    %eax,0x10(%ebp)
  800306:	0f b6 16             	movzbl (%esi),%edx
  800309:	8a 06                	mov    (%esi),%al
  80030b:	83 e8 23             	sub    $0x23,%eax
  80030e:	3c 55                	cmp    $0x55,%al
  800310:	0f 87 03 03 00 00    	ja     800619 <vprintfmt+0x389>
  800316:	0f b6 c0             	movzbl %al,%eax
  800319:	ff 24 85 e0 1f 80 00 	jmp    *0x801fe0(,%eax,4)
  800320:	8b 75 10             	mov    0x10(%ebp),%esi
			padc = '-';										//如果有这个字符代表左对齐，则把对齐方式标志位变为'-'
			goto reswitch;									//处理下一个字符

		// flag to pad with 0's instead of spaces
		case '0':											//0--有0表示进行对齐输出时填0,如省略表示填入空格，并且如果为0，则一定是右对齐
			padc = '0';										//对其方式标志位变为0
  800323:	c6 45 e3 30          	movb   $0x30,-0x1d(%ebp)
  800327:	eb d7                	jmp    800300 <vprintfmt+0x70>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {					//把遇到的位数字符串转换为真实的位数，比如输入的'%40'，代表有效位数为40位，下面的循环就是把precesion的值设置为40
				precision = precision * 10 + ch - '0';
  800329:	8d 42 d0             	lea    -0x30(%edx),%eax
  80032c:	89 c1                	mov    %eax,%ecx
  80032e:	89 45 d0             	mov    %eax,-0x30(%ebp)
				ch = *fmt;
  800331:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  800335:	8d 50 d0             	lea    -0x30(%eax),%edx
  800338:	83 fa 09             	cmp    $0x9,%edx
  80033b:	77 51                	ja     80038e <vprintfmt+0xfe>
  80033d:	8b 75 10             	mov    0x10(%ebp),%esi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {					//把遇到的位数字符串转换为真实的位数，比如输入的'%40'，代表有效位数为40位，下面的循环就是把precesion的值设置为40
  800340:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  800341:	8d 14 89             	lea    (%ecx,%ecx,4),%edx
  800344:	01 d2                	add    %edx,%edx
  800346:	8d 4c 10 d0          	lea    -0x30(%eax,%edx,1),%ecx
				ch = *fmt;
  80034a:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80034d:	8d 50 d0             	lea    -0x30(%eax),%edx
  800350:	83 fa 09             	cmp    $0x9,%edx
  800353:	76 eb                	jbe    800340 <vprintfmt+0xb0>
  800355:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800358:	eb 37                	jmp    800391 <vprintfmt+0x101>
					break;
			}
			goto process_precision;							//跳转到process_precistion子过程

		case '*':											//*--代表有效数字的位数也是由输入参数指定的，比如printf("%*.*f", 10, 2, n)，其中10,2就是用来指定显示的有效数字位数的
			precision = va_arg(ap, int);
  80035a:	8b 45 14             	mov    0x14(%ebp),%eax
  80035d:	8d 50 04             	lea    0x4(%eax),%edx
  800360:	89 55 14             	mov    %edx,0x14(%ebp)
  800363:	8b 00                	mov    (%eax),%eax
  800365:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  800368:	8b 75 10             	mov    0x10(%ebp),%esi
			}
			goto process_precision;							//跳转到process_precistion子过程

		case '*':											//*--代表有效数字的位数也是由输入参数指定的，比如printf("%*.*f", 10, 2, n)，其中10,2就是用来指定显示的有效数字位数的
			precision = va_arg(ap, int);
			goto process_precision;
  80036b:	eb 24                	jmp    800391 <vprintfmt+0x101>
  80036d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800371:	79 07                	jns    80037a <vprintfmt+0xea>
  800373:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  80037a:	8b 75 10             	mov    0x10(%ebp),%esi
  80037d:	eb 81                	jmp    800300 <vprintfmt+0x70>
  80037f:	8b 75 10             	mov    0x10(%ebp),%esi
			if (width < 0)									//代表有小数点，但是小数点前面并没有数字，比如'%.6f'这种情况，此时代表整数部分全部显示
				width = 0;			
			goto reswitch;

		case '#':
			altflag = 1;
  800382:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800389:	e9 72 ff ff ff       	jmp    800300 <vprintfmt+0x70>
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  80038e:	8b 75 10             	mov    0x10(%ebp),%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:									//处理输出精度，把width字段赋值为刚刚计算出来的precision值，所以width应该是整数部分的有效数字位数
			if (width < 0)
  800391:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800395:	0f 89 65 ff ff ff    	jns    800300 <vprintfmt+0x70>
				width = precision, precision = -1;
  80039b:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80039e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003a1:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003a8:	e9 53 ff ff ff       	jmp    800300 <vprintfmt+0x70>
			goto reswitch;

		// long flag (doubled for long long)				
		case 'l':											//如果遇到'l'，代表应该是输入long类型，如果有两个'l'代表long long
			lflag++;										//此时把lflag++
  8003ad:	ff 45 d4             	incl   -0x2c(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  8003b0:	8b 75 10             	mov    0x10(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)				
		case 'l':											//如果遇到'l'，代表应该是输入long类型，如果有两个'l'代表long long
			lflag++;										//此时把lflag++
			goto reswitch;
  8003b3:	e9 48 ff ff ff       	jmp    800300 <vprintfmt+0x70>

		// character
		case 'c':											//如果是'c'代表显示一个字符
			putch(va_arg(ap, int), putdat);					//调用输出一个字符到内存的函数putch
  8003b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8003bb:	8d 50 04             	lea    0x4(%eax),%edx
  8003be:	89 55 14             	mov    %edx,0x14(%ebp)
  8003c1:	83 ec 08             	sub    $0x8,%esp
  8003c4:	53                   	push   %ebx
  8003c5:	ff 30                	pushl  (%eax)
  8003c7:	ff d7                	call   *%edi
			break;
  8003c9:	83 c4 10             	add    $0x10,%esp
  8003cc:	e9 d3 fe ff ff       	jmp    8002a4 <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d4:	8d 50 04             	lea    0x4(%eax),%edx
  8003d7:	89 55 14             	mov    %edx,0x14(%ebp)
  8003da:	8b 00                	mov    (%eax),%eax
  8003dc:	85 c0                	test   %eax,%eax
  8003de:	79 02                	jns    8003e2 <vprintfmt+0x152>
  8003e0:	f7 d8                	neg    %eax
  8003e2:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003e4:	83 f8 0f             	cmp    $0xf,%eax
  8003e7:	7f 0b                	jg     8003f4 <vprintfmt+0x164>
  8003e9:	8b 04 85 40 21 80 00 	mov    0x802140(,%eax,4),%eax
  8003f0:	85 c0                	test   %eax,%eax
  8003f2:	75 15                	jne    800409 <vprintfmt+0x179>
				printfmt(putch, putdat, "error %d", err);
  8003f4:	52                   	push   %edx
  8003f5:	68 a7 1e 80 00       	push   $0x801ea7
  8003fa:	53                   	push   %ebx
  8003fb:	57                   	push   %edi
  8003fc:	e8 72 fe ff ff       	call   800273 <printfmt>
  800401:	83 c4 10             	add    $0x10,%esp
  800404:	e9 9b fe ff ff       	jmp    8002a4 <vprintfmt+0x14>
			else
				printfmt(putch, putdat, "%s", p);
  800409:	50                   	push   %eax
  80040a:	68 5f 22 80 00       	push   $0x80225f
  80040f:	53                   	push   %ebx
  800410:	57                   	push   %edi
  800411:	e8 5d fe ff ff       	call   800273 <printfmt>
  800416:	83 c4 10             	add    $0x10,%esp
  800419:	e9 86 fe ff ff       	jmp    8002a4 <vprintfmt+0x14>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80041e:	8b 45 14             	mov    0x14(%ebp),%eax
  800421:	8d 50 04             	lea    0x4(%eax),%edx
  800424:	89 55 14             	mov    %edx,0x14(%ebp)
  800427:	8b 00                	mov    (%eax),%eax
  800429:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80042c:	85 c0                	test   %eax,%eax
  80042e:	75 07                	jne    800437 <vprintfmt+0x1a7>
				p = "(null)";
  800430:	c7 45 d4 a0 1e 80 00 	movl   $0x801ea0,-0x2c(%ebp)
			if (width > 0 && padc != '-')
  800437:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80043a:	85 f6                	test   %esi,%esi
  80043c:	0f 8e fb 01 00 00    	jle    80063d <vprintfmt+0x3ad>
  800442:	80 7d e3 2d          	cmpb   $0x2d,-0x1d(%ebp)
  800446:	0f 84 09 02 00 00    	je     800655 <vprintfmt+0x3c5>
				for (width -= strnlen(p, precision); width > 0; width--)
  80044c:	83 ec 08             	sub    $0x8,%esp
  80044f:	ff 75 d0             	pushl  -0x30(%ebp)
  800452:	ff 75 d4             	pushl  -0x2c(%ebp)
  800455:	e8 ad 02 00 00       	call   800707 <strnlen>
  80045a:	89 f1                	mov    %esi,%ecx
  80045c:	29 c1                	sub    %eax,%ecx
  80045e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  800461:	83 c4 10             	add    $0x10,%esp
  800464:	85 c9                	test   %ecx,%ecx
  800466:	0f 8e d1 01 00 00    	jle    80063d <vprintfmt+0x3ad>
					putch(padc, putdat);
  80046c:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  800470:	83 ec 08             	sub    $0x8,%esp
  800473:	53                   	push   %ebx
  800474:	56                   	push   %esi
  800475:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800477:	83 c4 10             	add    $0x10,%esp
  80047a:	ff 4d e4             	decl   -0x1c(%ebp)
  80047d:	75 f1                	jne    800470 <vprintfmt+0x1e0>
  80047f:	e9 b9 01 00 00       	jmp    80063d <vprintfmt+0x3ad>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800484:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800488:	74 19                	je     8004a3 <vprintfmt+0x213>
  80048a:	0f be c0             	movsbl %al,%eax
  80048d:	83 e8 20             	sub    $0x20,%eax
  800490:	83 f8 5e             	cmp    $0x5e,%eax
  800493:	76 0e                	jbe    8004a3 <vprintfmt+0x213>
					putch('?', putdat);
  800495:	83 ec 08             	sub    $0x8,%esp
  800498:	53                   	push   %ebx
  800499:	6a 3f                	push   $0x3f
  80049b:	ff 55 08             	call   *0x8(%ebp)
  80049e:	83 c4 10             	add    $0x10,%esp
  8004a1:	eb 0b                	jmp    8004ae <vprintfmt+0x21e>
				else
					putch(ch, putdat);
  8004a3:	83 ec 08             	sub    $0x8,%esp
  8004a6:	53                   	push   %ebx
  8004a7:	52                   	push   %edx
  8004a8:	ff 55 08             	call   *0x8(%ebp)
  8004ab:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004ae:	ff 4d e4             	decl   -0x1c(%ebp)
  8004b1:	46                   	inc    %esi
  8004b2:	8a 46 ff             	mov    -0x1(%esi),%al
  8004b5:	0f be d0             	movsbl %al,%edx
  8004b8:	85 d2                	test   %edx,%edx
  8004ba:	75 1c                	jne    8004d8 <vprintfmt+0x248>
  8004bc:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004bf:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004c3:	7f 1f                	jg     8004e4 <vprintfmt+0x254>
  8004c5:	e9 da fd ff ff       	jmp    8002a4 <vprintfmt+0x14>
  8004ca:	89 7d 08             	mov    %edi,0x8(%ebp)
  8004cd:	8b 7d d0             	mov    -0x30(%ebp),%edi
  8004d0:	eb 06                	jmp    8004d8 <vprintfmt+0x248>
  8004d2:	89 7d 08             	mov    %edi,0x8(%ebp)
  8004d5:	8b 7d d0             	mov    -0x30(%ebp),%edi
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004d8:	85 ff                	test   %edi,%edi
  8004da:	78 a8                	js     800484 <vprintfmt+0x1f4>
  8004dc:	4f                   	dec    %edi
  8004dd:	79 a5                	jns    800484 <vprintfmt+0x1f4>
  8004df:	8b 7d 08             	mov    0x8(%ebp),%edi
  8004e2:	eb db                	jmp    8004bf <vprintfmt+0x22f>
  8004e4:	8b 75 e4             	mov    -0x1c(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8004e7:	83 ec 08             	sub    $0x8,%esp
  8004ea:	53                   	push   %ebx
  8004eb:	6a 20                	push   $0x20
  8004ed:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004ef:	4e                   	dec    %esi
  8004f0:	83 c4 10             	add    $0x10,%esp
  8004f3:	85 f6                	test   %esi,%esi
  8004f5:	7f f0                	jg     8004e7 <vprintfmt+0x257>
  8004f7:	e9 a8 fd ff ff       	jmp    8002a4 <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8004fc:	83 7d d4 01          	cmpl   $0x1,-0x2c(%ebp)
  800500:	7e 16                	jle    800518 <vprintfmt+0x288>
		return va_arg(*ap, long long);
  800502:	8b 45 14             	mov    0x14(%ebp),%eax
  800505:	8d 50 08             	lea    0x8(%eax),%edx
  800508:	89 55 14             	mov    %edx,0x14(%ebp)
  80050b:	8b 50 04             	mov    0x4(%eax),%edx
  80050e:	8b 00                	mov    (%eax),%eax
  800510:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800513:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800516:	eb 34                	jmp    80054c <vprintfmt+0x2bc>
	else if (lflag)
  800518:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80051c:	74 18                	je     800536 <vprintfmt+0x2a6>
		return va_arg(*ap, long);
  80051e:	8b 45 14             	mov    0x14(%ebp),%eax
  800521:	8d 50 04             	lea    0x4(%eax),%edx
  800524:	89 55 14             	mov    %edx,0x14(%ebp)
  800527:	8b 30                	mov    (%eax),%esi
  800529:	89 75 d8             	mov    %esi,-0x28(%ebp)
  80052c:	89 f0                	mov    %esi,%eax
  80052e:	c1 f8 1f             	sar    $0x1f,%eax
  800531:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800534:	eb 16                	jmp    80054c <vprintfmt+0x2bc>
	else
		return va_arg(*ap, int);
  800536:	8b 45 14             	mov    0x14(%ebp),%eax
  800539:	8d 50 04             	lea    0x4(%eax),%edx
  80053c:	89 55 14             	mov    %edx,0x14(%ebp)
  80053f:	8b 30                	mov    (%eax),%esi
  800541:	89 75 d8             	mov    %esi,-0x28(%ebp)
  800544:	89 f0                	mov    %esi,%eax
  800546:	c1 f8 1f             	sar    $0x1f,%eax
  800549:	89 45 dc             	mov    %eax,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80054c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80054f:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
  800552:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800556:	0f 89 8a 00 00 00    	jns    8005e6 <vprintfmt+0x356>
				putch('-', putdat);
  80055c:	83 ec 08             	sub    $0x8,%esp
  80055f:	53                   	push   %ebx
  800560:	6a 2d                	push   $0x2d
  800562:	ff d7                	call   *%edi
				num = -(long long) num;
  800564:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800567:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80056a:	f7 d8                	neg    %eax
  80056c:	83 d2 00             	adc    $0x0,%edx
  80056f:	f7 da                	neg    %edx
  800571:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800574:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800579:	eb 70                	jmp    8005eb <vprintfmt+0x35b>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80057b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80057e:	8d 45 14             	lea    0x14(%ebp),%eax
  800581:	e8 97 fc ff ff       	call   80021d <getuint>
			base = 10;
  800586:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80058b:	eb 5e                	jmp    8005eb <vprintfmt+0x35b>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
  80058d:	83 ec 08             	sub    $0x8,%esp
  800590:	53                   	push   %ebx
  800591:	6a 30                	push   $0x30
  800593:	ff d7                	call   *%edi
			num = getuint(&ap, lflag);
  800595:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800598:	8d 45 14             	lea    0x14(%ebp),%eax
  80059b:	e8 7d fc ff ff       	call   80021d <getuint>
			base = 8;
			goto number;
  8005a0:	83 c4 10             	add    $0x10,%esp
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  8005a3:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8005a8:	eb 41                	jmp    8005eb <vprintfmt+0x35b>
		// pointer
		case 'p':
			putch('0', putdat);
  8005aa:	83 ec 08             	sub    $0x8,%esp
  8005ad:	53                   	push   %ebx
  8005ae:	6a 30                	push   $0x30
  8005b0:	ff d7                	call   *%edi
			putch('x', putdat);
  8005b2:	83 c4 08             	add    $0x8,%esp
  8005b5:	53                   	push   %ebx
  8005b6:	6a 78                	push   $0x78
  8005b8:	ff d7                	call   *%edi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8005bd:	8d 50 04             	lea    0x4(%eax),%edx
  8005c0:	89 55 14             	mov    %edx,0x14(%ebp)
			goto number;
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005c3:	8b 00                	mov    (%eax),%eax
  8005c5:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8005ca:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8005cd:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8005d2:	eb 17                	jmp    8005eb <vprintfmt+0x35b>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8005d4:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8005d7:	8d 45 14             	lea    0x14(%ebp),%eax
  8005da:	e8 3e fc ff ff       	call   80021d <getuint>
			base = 16;
  8005df:	b9 10 00 00 00       	mov    $0x10,%ecx
  8005e4:	eb 05                	jmp    8005eb <vprintfmt+0x35b>
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005e6:	b9 0a 00 00 00       	mov    $0xa,%ecx
		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  8005eb:	83 ec 0c             	sub    $0xc,%esp
  8005ee:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  8005f2:	56                   	push   %esi
  8005f3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8005f6:	51                   	push   %ecx
  8005f7:	52                   	push   %edx
  8005f8:	50                   	push   %eax
  8005f9:	89 da                	mov    %ebx,%edx
  8005fb:	89 f8                	mov    %edi,%eax
  8005fd:	e8 6b fb ff ff       	call   80016d <printnum>
			break;
  800602:	83 c4 20             	add    $0x20,%esp
  800605:	e9 9a fc ff ff       	jmp    8002a4 <vprintfmt+0x14>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80060a:	83 ec 08             	sub    $0x8,%esp
  80060d:	53                   	push   %ebx
  80060e:	52                   	push   %edx
  80060f:	ff d7                	call   *%edi
			break;
  800611:	83 c4 10             	add    $0x10,%esp
  800614:	e9 8b fc ff ff       	jmp    8002a4 <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800619:	83 ec 08             	sub    $0x8,%esp
  80061c:	53                   	push   %ebx
  80061d:	6a 25                	push   $0x25
  80061f:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800621:	83 c4 10             	add    $0x10,%esp
  800624:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800628:	0f 84 73 fc ff ff    	je     8002a1 <vprintfmt+0x11>
  80062e:	4e                   	dec    %esi
  80062f:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800633:	75 f9                	jne    80062e <vprintfmt+0x39e>
  800635:	89 75 10             	mov    %esi,0x10(%ebp)
  800638:	e9 67 fc ff ff       	jmp    8002a4 <vprintfmt+0x14>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80063d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800640:	8d 70 01             	lea    0x1(%eax),%esi
  800643:	8a 00                	mov    (%eax),%al
  800645:	0f be d0             	movsbl %al,%edx
  800648:	85 d2                	test   %edx,%edx
  80064a:	0f 85 7a fe ff ff    	jne    8004ca <vprintfmt+0x23a>
  800650:	e9 4f fc ff ff       	jmp    8002a4 <vprintfmt+0x14>
  800655:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800658:	8d 70 01             	lea    0x1(%eax),%esi
  80065b:	8a 00                	mov    (%eax),%al
  80065d:	0f be d0             	movsbl %al,%edx
  800660:	85 d2                	test   %edx,%edx
  800662:	0f 85 6a fe ff ff    	jne    8004d2 <vprintfmt+0x242>
  800668:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80066b:	e9 77 fe ff ff       	jmp    8004e7 <vprintfmt+0x257>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800670:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800673:	5b                   	pop    %ebx
  800674:	5e                   	pop    %esi
  800675:	5f                   	pop    %edi
  800676:	5d                   	pop    %ebp
  800677:	c3                   	ret    

00800678 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800678:	55                   	push   %ebp
  800679:	89 e5                	mov    %esp,%ebp
  80067b:	83 ec 18             	sub    $0x18,%esp
  80067e:	8b 45 08             	mov    0x8(%ebp),%eax
  800681:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800684:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800687:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80068b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80068e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800695:	85 c0                	test   %eax,%eax
  800697:	74 26                	je     8006bf <vsnprintf+0x47>
  800699:	85 d2                	test   %edx,%edx
  80069b:	7e 29                	jle    8006c6 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80069d:	ff 75 14             	pushl  0x14(%ebp)
  8006a0:	ff 75 10             	pushl  0x10(%ebp)
  8006a3:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006a6:	50                   	push   %eax
  8006a7:	68 57 02 80 00       	push   $0x800257
  8006ac:	e8 df fb ff ff       	call   800290 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006b1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006b4:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006ba:	83 c4 10             	add    $0x10,%esp
  8006bd:	eb 0c                	jmp    8006cb <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006bf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006c4:	eb 05                	jmp    8006cb <vsnprintf+0x53>
  8006c6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006cb:	c9                   	leave  
  8006cc:	c3                   	ret    

008006cd <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006cd:	55                   	push   %ebp
  8006ce:	89 e5                	mov    %esp,%ebp
  8006d0:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006d3:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006d6:	50                   	push   %eax
  8006d7:	ff 75 10             	pushl  0x10(%ebp)
  8006da:	ff 75 0c             	pushl  0xc(%ebp)
  8006dd:	ff 75 08             	pushl  0x8(%ebp)
  8006e0:	e8 93 ff ff ff       	call   800678 <vsnprintf>
	va_end(ap);

	return rc;
}
  8006e5:	c9                   	leave  
  8006e6:	c3                   	ret    

008006e7 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006e7:	55                   	push   %ebp
  8006e8:	89 e5                	mov    %esp,%ebp
  8006ea:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006ed:	80 3a 00             	cmpb   $0x0,(%edx)
  8006f0:	74 0e                	je     800700 <strlen+0x19>
  8006f2:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8006f7:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006f8:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006fc:	75 f9                	jne    8006f7 <strlen+0x10>
  8006fe:	eb 05                	jmp    800705 <strlen+0x1e>
  800700:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800705:	5d                   	pop    %ebp
  800706:	c3                   	ret    

00800707 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800707:	55                   	push   %ebp
  800708:	89 e5                	mov    %esp,%ebp
  80070a:	53                   	push   %ebx
  80070b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80070e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800711:	85 c9                	test   %ecx,%ecx
  800713:	74 1a                	je     80072f <strnlen+0x28>
  800715:	80 3b 00             	cmpb   $0x0,(%ebx)
  800718:	74 1c                	je     800736 <strnlen+0x2f>
  80071a:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  80071f:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800721:	39 ca                	cmp    %ecx,%edx
  800723:	74 16                	je     80073b <strnlen+0x34>
  800725:	42                   	inc    %edx
  800726:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  80072b:	75 f2                	jne    80071f <strnlen+0x18>
  80072d:	eb 0c                	jmp    80073b <strnlen+0x34>
  80072f:	b8 00 00 00 00       	mov    $0x0,%eax
  800734:	eb 05                	jmp    80073b <strnlen+0x34>
  800736:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  80073b:	5b                   	pop    %ebx
  80073c:	5d                   	pop    %ebp
  80073d:	c3                   	ret    

0080073e <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80073e:	55                   	push   %ebp
  80073f:	89 e5                	mov    %esp,%ebp
  800741:	53                   	push   %ebx
  800742:	8b 45 08             	mov    0x8(%ebp),%eax
  800745:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800748:	89 c2                	mov    %eax,%edx
  80074a:	42                   	inc    %edx
  80074b:	41                   	inc    %ecx
  80074c:	8a 59 ff             	mov    -0x1(%ecx),%bl
  80074f:	88 5a ff             	mov    %bl,-0x1(%edx)
  800752:	84 db                	test   %bl,%bl
  800754:	75 f4                	jne    80074a <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800756:	5b                   	pop    %ebx
  800757:	5d                   	pop    %ebp
  800758:	c3                   	ret    

00800759 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800759:	55                   	push   %ebp
  80075a:	89 e5                	mov    %esp,%ebp
  80075c:	53                   	push   %ebx
  80075d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800760:	53                   	push   %ebx
  800761:	e8 81 ff ff ff       	call   8006e7 <strlen>
  800766:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800769:	ff 75 0c             	pushl  0xc(%ebp)
  80076c:	01 d8                	add    %ebx,%eax
  80076e:	50                   	push   %eax
  80076f:	e8 ca ff ff ff       	call   80073e <strcpy>
	return dst;
}
  800774:	89 d8                	mov    %ebx,%eax
  800776:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800779:	c9                   	leave  
  80077a:	c3                   	ret    

0080077b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80077b:	55                   	push   %ebp
  80077c:	89 e5                	mov    %esp,%ebp
  80077e:	56                   	push   %esi
  80077f:	53                   	push   %ebx
  800780:	8b 75 08             	mov    0x8(%ebp),%esi
  800783:	8b 55 0c             	mov    0xc(%ebp),%edx
  800786:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800789:	85 db                	test   %ebx,%ebx
  80078b:	74 14                	je     8007a1 <strncpy+0x26>
  80078d:	01 f3                	add    %esi,%ebx
  80078f:	89 f1                	mov    %esi,%ecx
		*dst++ = *src;
  800791:	41                   	inc    %ecx
  800792:	8a 02                	mov    (%edx),%al
  800794:	88 41 ff             	mov    %al,-0x1(%ecx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800797:	80 3a 01             	cmpb   $0x1,(%edx)
  80079a:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80079d:	39 cb                	cmp    %ecx,%ebx
  80079f:	75 f0                	jne    800791 <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007a1:	89 f0                	mov    %esi,%eax
  8007a3:	5b                   	pop    %ebx
  8007a4:	5e                   	pop    %esi
  8007a5:	5d                   	pop    %ebp
  8007a6:	c3                   	ret    

008007a7 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007a7:	55                   	push   %ebp
  8007a8:	89 e5                	mov    %esp,%ebp
  8007aa:	53                   	push   %ebx
  8007ab:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007ae:	8b 45 10             	mov    0x10(%ebp),%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007b1:	85 c0                	test   %eax,%eax
  8007b3:	74 30                	je     8007e5 <strlcpy+0x3e>
		while (--size > 0 && *src != '\0')
  8007b5:	48                   	dec    %eax
  8007b6:	74 20                	je     8007d8 <strlcpy+0x31>
  8007b8:	8a 0b                	mov    (%ebx),%cl
  8007ba:	84 c9                	test   %cl,%cl
  8007bc:	74 1f                	je     8007dd <strlcpy+0x36>
  8007be:	8d 53 01             	lea    0x1(%ebx),%edx
  8007c1:	01 c3                	add    %eax,%ebx
  8007c3:	8b 45 08             	mov    0x8(%ebp),%eax
			*dst++ = *src++;
  8007c6:	40                   	inc    %eax
  8007c7:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007ca:	39 da                	cmp    %ebx,%edx
  8007cc:	74 12                	je     8007e0 <strlcpy+0x39>
  8007ce:	42                   	inc    %edx
  8007cf:	8a 4a ff             	mov    -0x1(%edx),%cl
  8007d2:	84 c9                	test   %cl,%cl
  8007d4:	75 f0                	jne    8007c6 <strlcpy+0x1f>
  8007d6:	eb 08                	jmp    8007e0 <strlcpy+0x39>
  8007d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8007db:	eb 03                	jmp    8007e0 <strlcpy+0x39>
  8007dd:	8b 45 08             	mov    0x8(%ebp),%eax
			*dst++ = *src++;
		*dst = '\0';
  8007e0:	c6 00 00             	movb   $0x0,(%eax)
  8007e3:	eb 03                	jmp    8007e8 <strlcpy+0x41>
  8007e5:	8b 45 08             	mov    0x8(%ebp),%eax
	}
	return dst - dst_in;
  8007e8:	2b 45 08             	sub    0x8(%ebp),%eax
}
  8007eb:	5b                   	pop    %ebx
  8007ec:	5d                   	pop    %ebp
  8007ed:	c3                   	ret    

008007ee <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007ee:	55                   	push   %ebp
  8007ef:	89 e5                	mov    %esp,%ebp
  8007f1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007f4:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007f7:	8a 01                	mov    (%ecx),%al
  8007f9:	84 c0                	test   %al,%al
  8007fb:	74 10                	je     80080d <strcmp+0x1f>
  8007fd:	3a 02                	cmp    (%edx),%al
  8007ff:	75 0c                	jne    80080d <strcmp+0x1f>
		p++, q++;
  800801:	41                   	inc    %ecx
  800802:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800803:	8a 01                	mov    (%ecx),%al
  800805:	84 c0                	test   %al,%al
  800807:	74 04                	je     80080d <strcmp+0x1f>
  800809:	3a 02                	cmp    (%edx),%al
  80080b:	74 f4                	je     800801 <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80080d:	0f b6 c0             	movzbl %al,%eax
  800810:	0f b6 12             	movzbl (%edx),%edx
  800813:	29 d0                	sub    %edx,%eax
}
  800815:	5d                   	pop    %ebp
  800816:	c3                   	ret    

00800817 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800817:	55                   	push   %ebp
  800818:	89 e5                	mov    %esp,%ebp
  80081a:	56                   	push   %esi
  80081b:	53                   	push   %ebx
  80081c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80081f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800822:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  800825:	85 f6                	test   %esi,%esi
  800827:	74 23                	je     80084c <strncmp+0x35>
  800829:	8a 03                	mov    (%ebx),%al
  80082b:	84 c0                	test   %al,%al
  80082d:	74 2b                	je     80085a <strncmp+0x43>
  80082f:	3a 02                	cmp    (%edx),%al
  800831:	75 27                	jne    80085a <strncmp+0x43>
  800833:	8d 43 01             	lea    0x1(%ebx),%eax
  800836:	01 de                	add    %ebx,%esi
		n--, p++, q++;
  800838:	89 c3                	mov    %eax,%ebx
  80083a:	42                   	inc    %edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80083b:	39 c6                	cmp    %eax,%esi
  80083d:	74 14                	je     800853 <strncmp+0x3c>
  80083f:	8a 08                	mov    (%eax),%cl
  800841:	84 c9                	test   %cl,%cl
  800843:	74 15                	je     80085a <strncmp+0x43>
  800845:	40                   	inc    %eax
  800846:	3a 0a                	cmp    (%edx),%cl
  800848:	74 ee                	je     800838 <strncmp+0x21>
  80084a:	eb 0e                	jmp    80085a <strncmp+0x43>
		n--, p++, q++;
	if (n == 0)
		return 0;
  80084c:	b8 00 00 00 00       	mov    $0x0,%eax
  800851:	eb 0f                	jmp    800862 <strncmp+0x4b>
  800853:	b8 00 00 00 00       	mov    $0x0,%eax
  800858:	eb 08                	jmp    800862 <strncmp+0x4b>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80085a:	0f b6 03             	movzbl (%ebx),%eax
  80085d:	0f b6 12             	movzbl (%edx),%edx
  800860:	29 d0                	sub    %edx,%eax
}
  800862:	5b                   	pop    %ebx
  800863:	5e                   	pop    %esi
  800864:	5d                   	pop    %ebp
  800865:	c3                   	ret    

00800866 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800866:	55                   	push   %ebp
  800867:	89 e5                	mov    %esp,%ebp
  800869:	53                   	push   %ebx
  80086a:	8b 45 08             	mov    0x8(%ebp),%eax
  80086d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  800870:	8a 10                	mov    (%eax),%dl
  800872:	84 d2                	test   %dl,%dl
  800874:	74 1a                	je     800890 <strchr+0x2a>
  800876:	88 d9                	mov    %bl,%cl
		if (*s == c)
  800878:	38 d3                	cmp    %dl,%bl
  80087a:	75 06                	jne    800882 <strchr+0x1c>
  80087c:	eb 17                	jmp    800895 <strchr+0x2f>
  80087e:	38 ca                	cmp    %cl,%dl
  800880:	74 13                	je     800895 <strchr+0x2f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800882:	40                   	inc    %eax
  800883:	8a 10                	mov    (%eax),%dl
  800885:	84 d2                	test   %dl,%dl
  800887:	75 f5                	jne    80087e <strchr+0x18>
		if (*s == c)
			return (char *) s;
	return 0;
  800889:	b8 00 00 00 00       	mov    $0x0,%eax
  80088e:	eb 05                	jmp    800895 <strchr+0x2f>
  800890:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800895:	5b                   	pop    %ebx
  800896:	5d                   	pop    %ebp
  800897:	c3                   	ret    

00800898 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800898:	55                   	push   %ebp
  800899:	89 e5                	mov    %esp,%ebp
  80089b:	53                   	push   %ebx
  80089c:	8b 45 08             	mov    0x8(%ebp),%eax
  80089f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  8008a2:	8a 10                	mov    (%eax),%dl
  8008a4:	84 d2                	test   %dl,%dl
  8008a6:	74 13                	je     8008bb <strfind+0x23>
  8008a8:	88 d9                	mov    %bl,%cl
		if (*s == c)
  8008aa:	38 d3                	cmp    %dl,%bl
  8008ac:	75 06                	jne    8008b4 <strfind+0x1c>
  8008ae:	eb 0b                	jmp    8008bb <strfind+0x23>
  8008b0:	38 ca                	cmp    %cl,%dl
  8008b2:	74 07                	je     8008bb <strfind+0x23>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8008b4:	40                   	inc    %eax
  8008b5:	8a 10                	mov    (%eax),%dl
  8008b7:	84 d2                	test   %dl,%dl
  8008b9:	75 f5                	jne    8008b0 <strfind+0x18>
		if (*s == c)
			break;
	return (char *) s;
}
  8008bb:	5b                   	pop    %ebx
  8008bc:	5d                   	pop    %ebp
  8008bd:	c3                   	ret    

008008be <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008be:	55                   	push   %ebp
  8008bf:	89 e5                	mov    %esp,%ebp
  8008c1:	57                   	push   %edi
  8008c2:	56                   	push   %esi
  8008c3:	53                   	push   %ebx
  8008c4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008c7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008ca:	85 c9                	test   %ecx,%ecx
  8008cc:	74 36                	je     800904 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008ce:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008d4:	75 28                	jne    8008fe <memset+0x40>
  8008d6:	f6 c1 03             	test   $0x3,%cl
  8008d9:	75 23                	jne    8008fe <memset+0x40>
		c &= 0xFF;
  8008db:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008df:	89 d3                	mov    %edx,%ebx
  8008e1:	c1 e3 08             	shl    $0x8,%ebx
  8008e4:	89 d6                	mov    %edx,%esi
  8008e6:	c1 e6 18             	shl    $0x18,%esi
  8008e9:	89 d0                	mov    %edx,%eax
  8008eb:	c1 e0 10             	shl    $0x10,%eax
  8008ee:	09 f0                	or     %esi,%eax
  8008f0:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8008f2:	89 d8                	mov    %ebx,%eax
  8008f4:	09 d0                	or     %edx,%eax
  8008f6:	c1 e9 02             	shr    $0x2,%ecx
  8008f9:	fc                   	cld    
  8008fa:	f3 ab                	rep stos %eax,%es:(%edi)
  8008fc:	eb 06                	jmp    800904 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008fe:	8b 45 0c             	mov    0xc(%ebp),%eax
  800901:	fc                   	cld    
  800902:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800904:	89 f8                	mov    %edi,%eax
  800906:	5b                   	pop    %ebx
  800907:	5e                   	pop    %esi
  800908:	5f                   	pop    %edi
  800909:	5d                   	pop    %ebp
  80090a:	c3                   	ret    

0080090b <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80090b:	55                   	push   %ebp
  80090c:	89 e5                	mov    %esp,%ebp
  80090e:	57                   	push   %edi
  80090f:	56                   	push   %esi
  800910:	8b 45 08             	mov    0x8(%ebp),%eax
  800913:	8b 75 0c             	mov    0xc(%ebp),%esi
  800916:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800919:	39 c6                	cmp    %eax,%esi
  80091b:	73 33                	jae    800950 <memmove+0x45>
  80091d:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800920:	39 d0                	cmp    %edx,%eax
  800922:	73 2c                	jae    800950 <memmove+0x45>
		s += n;
		d += n;
  800924:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800927:	89 d6                	mov    %edx,%esi
  800929:	09 fe                	or     %edi,%esi
  80092b:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800931:	75 13                	jne    800946 <memmove+0x3b>
  800933:	f6 c1 03             	test   $0x3,%cl
  800936:	75 0e                	jne    800946 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800938:	83 ef 04             	sub    $0x4,%edi
  80093b:	8d 72 fc             	lea    -0x4(%edx),%esi
  80093e:	c1 e9 02             	shr    $0x2,%ecx
  800941:	fd                   	std    
  800942:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800944:	eb 07                	jmp    80094d <memmove+0x42>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800946:	4f                   	dec    %edi
  800947:	8d 72 ff             	lea    -0x1(%edx),%esi
  80094a:	fd                   	std    
  80094b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80094d:	fc                   	cld    
  80094e:	eb 1d                	jmp    80096d <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800950:	89 f2                	mov    %esi,%edx
  800952:	09 c2                	or     %eax,%edx
  800954:	f6 c2 03             	test   $0x3,%dl
  800957:	75 0f                	jne    800968 <memmove+0x5d>
  800959:	f6 c1 03             	test   $0x3,%cl
  80095c:	75 0a                	jne    800968 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
  80095e:	c1 e9 02             	shr    $0x2,%ecx
  800961:	89 c7                	mov    %eax,%edi
  800963:	fc                   	cld    
  800964:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800966:	eb 05                	jmp    80096d <memmove+0x62>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800968:	89 c7                	mov    %eax,%edi
  80096a:	fc                   	cld    
  80096b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80096d:	5e                   	pop    %esi
  80096e:	5f                   	pop    %edi
  80096f:	5d                   	pop    %ebp
  800970:	c3                   	ret    

00800971 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800971:	55                   	push   %ebp
  800972:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800974:	ff 75 10             	pushl  0x10(%ebp)
  800977:	ff 75 0c             	pushl  0xc(%ebp)
  80097a:	ff 75 08             	pushl  0x8(%ebp)
  80097d:	e8 89 ff ff ff       	call   80090b <memmove>
}
  800982:	c9                   	leave  
  800983:	c3                   	ret    

00800984 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800984:	55                   	push   %ebp
  800985:	89 e5                	mov    %esp,%ebp
  800987:	57                   	push   %edi
  800988:	56                   	push   %esi
  800989:	53                   	push   %ebx
  80098a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80098d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800990:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800993:	85 c0                	test   %eax,%eax
  800995:	74 33                	je     8009ca <memcmp+0x46>
  800997:	8d 78 ff             	lea    -0x1(%eax),%edi
		if (*s1 != *s2)
  80099a:	8a 13                	mov    (%ebx),%dl
  80099c:	8a 0e                	mov    (%esi),%cl
  80099e:	38 ca                	cmp    %cl,%dl
  8009a0:	75 13                	jne    8009b5 <memcmp+0x31>
  8009a2:	b8 00 00 00 00       	mov    $0x0,%eax
  8009a7:	eb 16                	jmp    8009bf <memcmp+0x3b>
  8009a9:	8a 54 03 01          	mov    0x1(%ebx,%eax,1),%dl
  8009ad:	40                   	inc    %eax
  8009ae:	8a 0c 06             	mov    (%esi,%eax,1),%cl
  8009b1:	38 ca                	cmp    %cl,%dl
  8009b3:	74 0a                	je     8009bf <memcmp+0x3b>
			return (int) *s1 - (int) *s2;
  8009b5:	0f b6 c2             	movzbl %dl,%eax
  8009b8:	0f b6 c9             	movzbl %cl,%ecx
  8009bb:	29 c8                	sub    %ecx,%eax
  8009bd:	eb 10                	jmp    8009cf <memcmp+0x4b>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009bf:	39 f8                	cmp    %edi,%eax
  8009c1:	75 e6                	jne    8009a9 <memcmp+0x25>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009c3:	b8 00 00 00 00       	mov    $0x0,%eax
  8009c8:	eb 05                	jmp    8009cf <memcmp+0x4b>
  8009ca:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009cf:	5b                   	pop    %ebx
  8009d0:	5e                   	pop    %esi
  8009d1:	5f                   	pop    %edi
  8009d2:	5d                   	pop    %ebp
  8009d3:	c3                   	ret    

008009d4 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009d4:	55                   	push   %ebp
  8009d5:	89 e5                	mov    %esp,%ebp
  8009d7:	53                   	push   %ebx
  8009d8:	8b 55 08             	mov    0x8(%ebp),%edx
	const void *ends = (const char *) s + n;
  8009db:	89 d0                	mov    %edx,%eax
  8009dd:	03 45 10             	add    0x10(%ebp),%eax
	for (; s < ends; s++)
  8009e0:	39 c2                	cmp    %eax,%edx
  8009e2:	73 1b                	jae    8009ff <memfind+0x2b>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009e4:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
  8009e8:	0f b6 0a             	movzbl (%edx),%ecx
  8009eb:	39 d9                	cmp    %ebx,%ecx
  8009ed:	75 09                	jne    8009f8 <memfind+0x24>
  8009ef:	eb 12                	jmp    800a03 <memfind+0x2f>
  8009f1:	0f b6 0a             	movzbl (%edx),%ecx
  8009f4:	39 d9                	cmp    %ebx,%ecx
  8009f6:	74 0f                	je     800a07 <memfind+0x33>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009f8:	42                   	inc    %edx
  8009f9:	39 d0                	cmp    %edx,%eax
  8009fb:	75 f4                	jne    8009f1 <memfind+0x1d>
  8009fd:	eb 0a                	jmp    800a09 <memfind+0x35>
  8009ff:	89 d0                	mov    %edx,%eax
  800a01:	eb 06                	jmp    800a09 <memfind+0x35>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a03:	89 d0                	mov    %edx,%eax
  800a05:	eb 02                	jmp    800a09 <memfind+0x35>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a07:	89 d0                	mov    %edx,%eax
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a09:	5b                   	pop    %ebx
  800a0a:	5d                   	pop    %ebp
  800a0b:	c3                   	ret    

00800a0c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a0c:	55                   	push   %ebp
  800a0d:	89 e5                	mov    %esp,%ebp
  800a0f:	57                   	push   %edi
  800a10:	56                   	push   %esi
  800a11:	53                   	push   %ebx
  800a12:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a15:	eb 01                	jmp    800a18 <strtol+0xc>
		s++;
  800a17:	41                   	inc    %ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a18:	8a 01                	mov    (%ecx),%al
  800a1a:	3c 20                	cmp    $0x20,%al
  800a1c:	74 f9                	je     800a17 <strtol+0xb>
  800a1e:	3c 09                	cmp    $0x9,%al
  800a20:	74 f5                	je     800a17 <strtol+0xb>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a22:	3c 2b                	cmp    $0x2b,%al
  800a24:	75 08                	jne    800a2e <strtol+0x22>
		s++;
  800a26:	41                   	inc    %ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a27:	bf 00 00 00 00       	mov    $0x0,%edi
  800a2c:	eb 11                	jmp    800a3f <strtol+0x33>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a2e:	3c 2d                	cmp    $0x2d,%al
  800a30:	75 08                	jne    800a3a <strtol+0x2e>
		s++, neg = 1;
  800a32:	41                   	inc    %ecx
  800a33:	bf 01 00 00 00       	mov    $0x1,%edi
  800a38:	eb 05                	jmp    800a3f <strtol+0x33>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a3a:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a3f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800a43:	0f 84 87 00 00 00    	je     800ad0 <strtol+0xc4>
  800a49:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  800a4d:	75 27                	jne    800a76 <strtol+0x6a>
  800a4f:	80 39 30             	cmpb   $0x30,(%ecx)
  800a52:	75 22                	jne    800a76 <strtol+0x6a>
  800a54:	e9 88 00 00 00       	jmp    800ae1 <strtol+0xd5>
		s += 2, base = 16;
  800a59:	83 c1 02             	add    $0x2,%ecx
  800a5c:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  800a63:	eb 11                	jmp    800a76 <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
  800a65:	41                   	inc    %ecx
  800a66:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  800a6d:	eb 07                	jmp    800a76 <strtol+0x6a>
	else if (base == 0)
		base = 10;
  800a6f:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)
  800a76:	b8 00 00 00 00       	mov    $0x0,%eax

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a7b:	8a 11                	mov    (%ecx),%dl
  800a7d:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800a80:	80 fb 09             	cmp    $0x9,%bl
  800a83:	77 08                	ja     800a8d <strtol+0x81>
			dig = *s - '0';
  800a85:	0f be d2             	movsbl %dl,%edx
  800a88:	83 ea 30             	sub    $0x30,%edx
  800a8b:	eb 22                	jmp    800aaf <strtol+0xa3>
		else if (*s >= 'a' && *s <= 'z')
  800a8d:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a90:	89 f3                	mov    %esi,%ebx
  800a92:	80 fb 19             	cmp    $0x19,%bl
  800a95:	77 08                	ja     800a9f <strtol+0x93>
			dig = *s - 'a' + 10;
  800a97:	0f be d2             	movsbl %dl,%edx
  800a9a:	83 ea 57             	sub    $0x57,%edx
  800a9d:	eb 10                	jmp    800aaf <strtol+0xa3>
		else if (*s >= 'A' && *s <= 'Z')
  800a9f:	8d 72 bf             	lea    -0x41(%edx),%esi
  800aa2:	89 f3                	mov    %esi,%ebx
  800aa4:	80 fb 19             	cmp    $0x19,%bl
  800aa7:	77 14                	ja     800abd <strtol+0xb1>
			dig = *s - 'A' + 10;
  800aa9:	0f be d2             	movsbl %dl,%edx
  800aac:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800aaf:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ab2:	7d 09                	jge    800abd <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800ab4:	41                   	inc    %ecx
  800ab5:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ab9:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800abb:	eb be                	jmp    800a7b <strtol+0x6f>

	if (endptr)
  800abd:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ac1:	74 05                	je     800ac8 <strtol+0xbc>
		*endptr = (char *) s;
  800ac3:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ac6:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800ac8:	85 ff                	test   %edi,%edi
  800aca:	74 21                	je     800aed <strtol+0xe1>
  800acc:	f7 d8                	neg    %eax
  800ace:	eb 1d                	jmp    800aed <strtol+0xe1>
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ad0:	80 39 30             	cmpb   $0x30,(%ecx)
  800ad3:	75 9a                	jne    800a6f <strtol+0x63>
  800ad5:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800ad9:	0f 84 7a ff ff ff    	je     800a59 <strtol+0x4d>
  800adf:	eb 84                	jmp    800a65 <strtol+0x59>
  800ae1:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800ae5:	0f 84 6e ff ff ff    	je     800a59 <strtol+0x4d>
  800aeb:	eb 89                	jmp    800a76 <strtol+0x6a>
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
}
  800aed:	5b                   	pop    %ebx
  800aee:	5e                   	pop    %esi
  800aef:	5f                   	pop    %edi
  800af0:	5d                   	pop    %ebp
  800af1:	c3                   	ret    

00800af2 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800af2:	55                   	push   %ebp
  800af3:	89 e5                	mov    %esp,%ebp
  800af5:	57                   	push   %edi
  800af6:	56                   	push   %esi
  800af7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800af8:	b8 00 00 00 00       	mov    $0x0,%eax
  800afd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b00:	8b 55 08             	mov    0x8(%ebp),%edx
  800b03:	89 c3                	mov    %eax,%ebx
  800b05:	89 c7                	mov    %eax,%edi
  800b07:	89 c6                	mov    %eax,%esi
  800b09:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b0b:	5b                   	pop    %ebx
  800b0c:	5e                   	pop    %esi
  800b0d:	5f                   	pop    %edi
  800b0e:	5d                   	pop    %ebp
  800b0f:	c3                   	ret    

00800b10 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b10:	55                   	push   %ebp
  800b11:	89 e5                	mov    %esp,%ebp
  800b13:	57                   	push   %edi
  800b14:	56                   	push   %esi
  800b15:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b16:	ba 00 00 00 00       	mov    $0x0,%edx
  800b1b:	b8 01 00 00 00       	mov    $0x1,%eax
  800b20:	89 d1                	mov    %edx,%ecx
  800b22:	89 d3                	mov    %edx,%ebx
  800b24:	89 d7                	mov    %edx,%edi
  800b26:	89 d6                	mov    %edx,%esi
  800b28:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b2a:	5b                   	pop    %ebx
  800b2b:	5e                   	pop    %esi
  800b2c:	5f                   	pop    %edi
  800b2d:	5d                   	pop    %ebp
  800b2e:	c3                   	ret    

00800b2f <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b2f:	55                   	push   %ebp
  800b30:	89 e5                	mov    %esp,%ebp
  800b32:	57                   	push   %edi
  800b33:	56                   	push   %esi
  800b34:	53                   	push   %ebx
  800b35:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b38:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b3d:	b8 03 00 00 00       	mov    $0x3,%eax
  800b42:	8b 55 08             	mov    0x8(%ebp),%edx
  800b45:	89 cb                	mov    %ecx,%ebx
  800b47:	89 cf                	mov    %ecx,%edi
  800b49:	89 ce                	mov    %ecx,%esi
  800b4b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b4d:	85 c0                	test   %eax,%eax
  800b4f:	7e 17                	jle    800b68 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b51:	83 ec 0c             	sub    $0xc,%esp
  800b54:	50                   	push   %eax
  800b55:	6a 03                	push   $0x3
  800b57:	68 9f 21 80 00       	push   $0x80219f
  800b5c:	6a 23                	push   $0x23
  800b5e:	68 bc 21 80 00       	push   $0x8021bc
  800b63:	e8 cf 0e 00 00       	call   801a37 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b68:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b6b:	5b                   	pop    %ebx
  800b6c:	5e                   	pop    %esi
  800b6d:	5f                   	pop    %edi
  800b6e:	5d                   	pop    %ebp
  800b6f:	c3                   	ret    

00800b70 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b70:	55                   	push   %ebp
  800b71:	89 e5                	mov    %esp,%ebp
  800b73:	57                   	push   %edi
  800b74:	56                   	push   %esi
  800b75:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b76:	ba 00 00 00 00       	mov    $0x0,%edx
  800b7b:	b8 02 00 00 00       	mov    $0x2,%eax
  800b80:	89 d1                	mov    %edx,%ecx
  800b82:	89 d3                	mov    %edx,%ebx
  800b84:	89 d7                	mov    %edx,%edi
  800b86:	89 d6                	mov    %edx,%esi
  800b88:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b8a:	5b                   	pop    %ebx
  800b8b:	5e                   	pop    %esi
  800b8c:	5f                   	pop    %edi
  800b8d:	5d                   	pop    %ebp
  800b8e:	c3                   	ret    

00800b8f <sys_yield>:

void
sys_yield(void)
{
  800b8f:	55                   	push   %ebp
  800b90:	89 e5                	mov    %esp,%ebp
  800b92:	57                   	push   %edi
  800b93:	56                   	push   %esi
  800b94:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b95:	ba 00 00 00 00       	mov    $0x0,%edx
  800b9a:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b9f:	89 d1                	mov    %edx,%ecx
  800ba1:	89 d3                	mov    %edx,%ebx
  800ba3:	89 d7                	mov    %edx,%edi
  800ba5:	89 d6                	mov    %edx,%esi
  800ba7:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800ba9:	5b                   	pop    %ebx
  800baa:	5e                   	pop    %esi
  800bab:	5f                   	pop    %edi
  800bac:	5d                   	pop    %ebp
  800bad:	c3                   	ret    

00800bae <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bae:	55                   	push   %ebp
  800baf:	89 e5                	mov    %esp,%ebp
  800bb1:	57                   	push   %edi
  800bb2:	56                   	push   %esi
  800bb3:	53                   	push   %ebx
  800bb4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bb7:	be 00 00 00 00       	mov    $0x0,%esi
  800bbc:	b8 04 00 00 00       	mov    $0x4,%eax
  800bc1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bc4:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bca:	89 f7                	mov    %esi,%edi
  800bcc:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bce:	85 c0                	test   %eax,%eax
  800bd0:	7e 17                	jle    800be9 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bd2:	83 ec 0c             	sub    $0xc,%esp
  800bd5:	50                   	push   %eax
  800bd6:	6a 04                	push   $0x4
  800bd8:	68 9f 21 80 00       	push   $0x80219f
  800bdd:	6a 23                	push   $0x23
  800bdf:	68 bc 21 80 00       	push   $0x8021bc
  800be4:	e8 4e 0e 00 00       	call   801a37 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800be9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bec:	5b                   	pop    %ebx
  800bed:	5e                   	pop    %esi
  800bee:	5f                   	pop    %edi
  800bef:	5d                   	pop    %ebp
  800bf0:	c3                   	ret    

00800bf1 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
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
  800bfa:	b8 05 00 00 00       	mov    $0x5,%eax
  800bff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c02:	8b 55 08             	mov    0x8(%ebp),%edx
  800c05:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c08:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c0b:	8b 75 18             	mov    0x18(%ebp),%esi
  800c0e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c10:	85 c0                	test   %eax,%eax
  800c12:	7e 17                	jle    800c2b <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c14:	83 ec 0c             	sub    $0xc,%esp
  800c17:	50                   	push   %eax
  800c18:	6a 05                	push   $0x5
  800c1a:	68 9f 21 80 00       	push   $0x80219f
  800c1f:	6a 23                	push   $0x23
  800c21:	68 bc 21 80 00       	push   $0x8021bc
  800c26:	e8 0c 0e 00 00       	call   801a37 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c2b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c2e:	5b                   	pop    %ebx
  800c2f:	5e                   	pop    %esi
  800c30:	5f                   	pop    %edi
  800c31:	5d                   	pop    %ebp
  800c32:	c3                   	ret    

00800c33 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c33:	55                   	push   %ebp
  800c34:	89 e5                	mov    %esp,%ebp
  800c36:	57                   	push   %edi
  800c37:	56                   	push   %esi
  800c38:	53                   	push   %ebx
  800c39:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c3c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c41:	b8 06 00 00 00       	mov    $0x6,%eax
  800c46:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c49:	8b 55 08             	mov    0x8(%ebp),%edx
  800c4c:	89 df                	mov    %ebx,%edi
  800c4e:	89 de                	mov    %ebx,%esi
  800c50:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c52:	85 c0                	test   %eax,%eax
  800c54:	7e 17                	jle    800c6d <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c56:	83 ec 0c             	sub    $0xc,%esp
  800c59:	50                   	push   %eax
  800c5a:	6a 06                	push   $0x6
  800c5c:	68 9f 21 80 00       	push   $0x80219f
  800c61:	6a 23                	push   $0x23
  800c63:	68 bc 21 80 00       	push   $0x8021bc
  800c68:	e8 ca 0d 00 00       	call   801a37 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c6d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c70:	5b                   	pop    %ebx
  800c71:	5e                   	pop    %esi
  800c72:	5f                   	pop    %edi
  800c73:	5d                   	pop    %ebp
  800c74:	c3                   	ret    

00800c75 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c75:	55                   	push   %ebp
  800c76:	89 e5                	mov    %esp,%ebp
  800c78:	57                   	push   %edi
  800c79:	56                   	push   %esi
  800c7a:	53                   	push   %ebx
  800c7b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c7e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c83:	b8 08 00 00 00       	mov    $0x8,%eax
  800c88:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c8b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c8e:	89 df                	mov    %ebx,%edi
  800c90:	89 de                	mov    %ebx,%esi
  800c92:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c94:	85 c0                	test   %eax,%eax
  800c96:	7e 17                	jle    800caf <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c98:	83 ec 0c             	sub    $0xc,%esp
  800c9b:	50                   	push   %eax
  800c9c:	6a 08                	push   $0x8
  800c9e:	68 9f 21 80 00       	push   $0x80219f
  800ca3:	6a 23                	push   $0x23
  800ca5:	68 bc 21 80 00       	push   $0x8021bc
  800caa:	e8 88 0d 00 00       	call   801a37 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800caf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb2:	5b                   	pop    %ebx
  800cb3:	5e                   	pop    %esi
  800cb4:	5f                   	pop    %edi
  800cb5:	5d                   	pop    %ebp
  800cb6:	c3                   	ret    

00800cb7 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800cb7:	55                   	push   %ebp
  800cb8:	89 e5                	mov    %esp,%ebp
  800cba:	57                   	push   %edi
  800cbb:	56                   	push   %esi
  800cbc:	53                   	push   %ebx
  800cbd:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cc5:	b8 09 00 00 00       	mov    $0x9,%eax
  800cca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ccd:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd0:	89 df                	mov    %ebx,%edi
  800cd2:	89 de                	mov    %ebx,%esi
  800cd4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cd6:	85 c0                	test   %eax,%eax
  800cd8:	7e 17                	jle    800cf1 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cda:	83 ec 0c             	sub    $0xc,%esp
  800cdd:	50                   	push   %eax
  800cde:	6a 09                	push   $0x9
  800ce0:	68 9f 21 80 00       	push   $0x80219f
  800ce5:	6a 23                	push   $0x23
  800ce7:	68 bc 21 80 00       	push   $0x8021bc
  800cec:	e8 46 0d 00 00       	call   801a37 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cf1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf4:	5b                   	pop    %ebx
  800cf5:	5e                   	pop    %esi
  800cf6:	5f                   	pop    %edi
  800cf7:	5d                   	pop    %ebp
  800cf8:	c3                   	ret    

00800cf9 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cf9:	55                   	push   %ebp
  800cfa:	89 e5                	mov    %esp,%ebp
  800cfc:	57                   	push   %edi
  800cfd:	56                   	push   %esi
  800cfe:	53                   	push   %ebx
  800cff:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d02:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d07:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d0c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d0f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d12:	89 df                	mov    %ebx,%edi
  800d14:	89 de                	mov    %ebx,%esi
  800d16:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d18:	85 c0                	test   %eax,%eax
  800d1a:	7e 17                	jle    800d33 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d1c:	83 ec 0c             	sub    $0xc,%esp
  800d1f:	50                   	push   %eax
  800d20:	6a 0a                	push   $0xa
  800d22:	68 9f 21 80 00       	push   $0x80219f
  800d27:	6a 23                	push   $0x23
  800d29:	68 bc 21 80 00       	push   $0x8021bc
  800d2e:	e8 04 0d 00 00       	call   801a37 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d33:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d36:	5b                   	pop    %ebx
  800d37:	5e                   	pop    %esi
  800d38:	5f                   	pop    %edi
  800d39:	5d                   	pop    %ebp
  800d3a:	c3                   	ret    

00800d3b <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d3b:	55                   	push   %ebp
  800d3c:	89 e5                	mov    %esp,%ebp
  800d3e:	57                   	push   %edi
  800d3f:	56                   	push   %esi
  800d40:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d41:	be 00 00 00 00       	mov    $0x0,%esi
  800d46:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d4b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d4e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d51:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d54:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d57:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d59:	5b                   	pop    %ebx
  800d5a:	5e                   	pop    %esi
  800d5b:	5f                   	pop    %edi
  800d5c:	5d                   	pop    %ebp
  800d5d:	c3                   	ret    

00800d5e <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d5e:	55                   	push   %ebp
  800d5f:	89 e5                	mov    %esp,%ebp
  800d61:	57                   	push   %edi
  800d62:	56                   	push   %esi
  800d63:	53                   	push   %ebx
  800d64:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d67:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d6c:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d71:	8b 55 08             	mov    0x8(%ebp),%edx
  800d74:	89 cb                	mov    %ecx,%ebx
  800d76:	89 cf                	mov    %ecx,%edi
  800d78:	89 ce                	mov    %ecx,%esi
  800d7a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d7c:	85 c0                	test   %eax,%eax
  800d7e:	7e 17                	jle    800d97 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d80:	83 ec 0c             	sub    $0xc,%esp
  800d83:	50                   	push   %eax
  800d84:	6a 0d                	push   $0xd
  800d86:	68 9f 21 80 00       	push   $0x80219f
  800d8b:	6a 23                	push   $0x23
  800d8d:	68 bc 21 80 00       	push   $0x8021bc
  800d92:	e8 a0 0c 00 00       	call   801a37 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d97:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d9a:	5b                   	pop    %ebx
  800d9b:	5e                   	pop    %esi
  800d9c:	5f                   	pop    %edi
  800d9d:	5d                   	pop    %ebp
  800d9e:	c3                   	ret    

00800d9f <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800d9f:	55                   	push   %ebp
  800da0:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800da2:	8b 45 08             	mov    0x8(%ebp),%eax
  800da5:	05 00 00 00 30       	add    $0x30000000,%eax
  800daa:	c1 e8 0c             	shr    $0xc,%eax
}
  800dad:	5d                   	pop    %ebp
  800dae:	c3                   	ret    

00800daf <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800daf:	55                   	push   %ebp
  800db0:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800db2:	8b 45 08             	mov    0x8(%ebp),%eax
  800db5:	05 00 00 00 30       	add    $0x30000000,%eax
  800dba:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800dbf:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800dc4:	5d                   	pop    %ebp
  800dc5:	c3                   	ret    

00800dc6 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800dc6:	55                   	push   %ebp
  800dc7:	89 e5                	mov    %esp,%ebp
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800dc9:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  800dce:	a8 01                	test   $0x1,%al
  800dd0:	74 34                	je     800e06 <fd_alloc+0x40>
  800dd2:	a1 00 00 74 ef       	mov    0xef740000,%eax
  800dd7:	a8 01                	test   $0x1,%al
  800dd9:	74 32                	je     800e0d <fd_alloc+0x47>
  800ddb:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800de0:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800de2:	89 c2                	mov    %eax,%edx
  800de4:	c1 ea 16             	shr    $0x16,%edx
  800de7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800dee:	f6 c2 01             	test   $0x1,%dl
  800df1:	74 1f                	je     800e12 <fd_alloc+0x4c>
  800df3:	89 c2                	mov    %eax,%edx
  800df5:	c1 ea 0c             	shr    $0xc,%edx
  800df8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800dff:	f6 c2 01             	test   $0x1,%dl
  800e02:	75 1a                	jne    800e1e <fd_alloc+0x58>
  800e04:	eb 0c                	jmp    800e12 <fd_alloc+0x4c>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800e06:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  800e0b:	eb 05                	jmp    800e12 <fd_alloc+0x4c>
  800e0d:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  800e12:	8b 45 08             	mov    0x8(%ebp),%eax
  800e15:	89 08                	mov    %ecx,(%eax)
			return 0;
  800e17:	b8 00 00 00 00       	mov    $0x0,%eax
  800e1c:	eb 1a                	jmp    800e38 <fd_alloc+0x72>
  800e1e:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800e23:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e28:	75 b6                	jne    800de0 <fd_alloc+0x1a>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800e2a:	8b 45 08             	mov    0x8(%ebp),%eax
  800e2d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  800e33:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800e38:	5d                   	pop    %ebp
  800e39:	c3                   	ret    

00800e3a <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e3a:	55                   	push   %ebp
  800e3b:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e3d:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
  800e41:	77 39                	ja     800e7c <fd_lookup+0x42>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e43:	8b 45 08             	mov    0x8(%ebp),%eax
  800e46:	c1 e0 0c             	shl    $0xc,%eax
  800e49:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e4e:	89 c2                	mov    %eax,%edx
  800e50:	c1 ea 16             	shr    $0x16,%edx
  800e53:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e5a:	f6 c2 01             	test   $0x1,%dl
  800e5d:	74 24                	je     800e83 <fd_lookup+0x49>
  800e5f:	89 c2                	mov    %eax,%edx
  800e61:	c1 ea 0c             	shr    $0xc,%edx
  800e64:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e6b:	f6 c2 01             	test   $0x1,%dl
  800e6e:	74 1a                	je     800e8a <fd_lookup+0x50>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800e70:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e73:	89 02                	mov    %eax,(%edx)
	return 0;
  800e75:	b8 00 00 00 00       	mov    $0x0,%eax
  800e7a:	eb 13                	jmp    800e8f <fd_lookup+0x55>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e7c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e81:	eb 0c                	jmp    800e8f <fd_lookup+0x55>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e83:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e88:	eb 05                	jmp    800e8f <fd_lookup+0x55>
  800e8a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800e8f:	5d                   	pop    %ebp
  800e90:	c3                   	ret    

00800e91 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800e91:	55                   	push   %ebp
  800e92:	89 e5                	mov    %esp,%ebp
  800e94:	53                   	push   %ebx
  800e95:	83 ec 04             	sub    $0x4,%esp
  800e98:	8b 45 08             	mov    0x8(%ebp),%eax
  800e9b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  800e9e:	3b 05 04 30 80 00    	cmp    0x803004,%eax
  800ea4:	75 1e                	jne    800ec4 <dev_lookup+0x33>
  800ea6:	eb 0e                	jmp    800eb6 <dev_lookup+0x25>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800ea8:	b8 20 30 80 00       	mov    $0x803020,%eax
  800ead:	eb 0c                	jmp    800ebb <dev_lookup+0x2a>
  800eaf:	b8 3c 30 80 00       	mov    $0x80303c,%eax
  800eb4:	eb 05                	jmp    800ebb <dev_lookup+0x2a>
  800eb6:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  800ebb:	89 03                	mov    %eax,(%ebx)
			return 0;
  800ebd:	b8 00 00 00 00       	mov    $0x0,%eax
  800ec2:	eb 36                	jmp    800efa <dev_lookup+0x69>
int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  800ec4:	3b 05 20 30 80 00    	cmp    0x803020,%eax
  800eca:	74 dc                	je     800ea8 <dev_lookup+0x17>
  800ecc:	3b 05 3c 30 80 00    	cmp    0x80303c,%eax
  800ed2:	74 db                	je     800eaf <dev_lookup+0x1e>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800ed4:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800eda:	8b 52 48             	mov    0x48(%edx),%edx
  800edd:	83 ec 04             	sub    $0x4,%esp
  800ee0:	50                   	push   %eax
  800ee1:	52                   	push   %edx
  800ee2:	68 cc 21 80 00       	push   $0x8021cc
  800ee7:	e8 6d f2 ff ff       	call   800159 <cprintf>
	*dev = 0;
  800eec:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  800ef2:	83 c4 10             	add    $0x10,%esp
  800ef5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800efa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800efd:	c9                   	leave  
  800efe:	c3                   	ret    

00800eff <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800eff:	55                   	push   %ebp
  800f00:	89 e5                	mov    %esp,%ebp
  800f02:	56                   	push   %esi
  800f03:	53                   	push   %ebx
  800f04:	83 ec 10             	sub    $0x10,%esp
  800f07:	8b 75 08             	mov    0x8(%ebp),%esi
  800f0a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f0d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f10:	50                   	push   %eax
  800f11:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800f17:	c1 e8 0c             	shr    $0xc,%eax
  800f1a:	50                   	push   %eax
  800f1b:	e8 1a ff ff ff       	call   800e3a <fd_lookup>
  800f20:	83 c4 08             	add    $0x8,%esp
  800f23:	85 c0                	test   %eax,%eax
  800f25:	78 05                	js     800f2c <fd_close+0x2d>
	    || fd != fd2)
  800f27:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800f2a:	74 06                	je     800f32 <fd_close+0x33>
		return (must_exist ? r : 0);
  800f2c:	84 db                	test   %bl,%bl
  800f2e:	74 47                	je     800f77 <fd_close+0x78>
  800f30:	eb 4a                	jmp    800f7c <fd_close+0x7d>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f32:	83 ec 08             	sub    $0x8,%esp
  800f35:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800f38:	50                   	push   %eax
  800f39:	ff 36                	pushl  (%esi)
  800f3b:	e8 51 ff ff ff       	call   800e91 <dev_lookup>
  800f40:	89 c3                	mov    %eax,%ebx
  800f42:	83 c4 10             	add    $0x10,%esp
  800f45:	85 c0                	test   %eax,%eax
  800f47:	78 1c                	js     800f65 <fd_close+0x66>
		if (dev->dev_close)
  800f49:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f4c:	8b 40 10             	mov    0x10(%eax),%eax
  800f4f:	85 c0                	test   %eax,%eax
  800f51:	74 0d                	je     800f60 <fd_close+0x61>
			r = (*dev->dev_close)(fd);
  800f53:	83 ec 0c             	sub    $0xc,%esp
  800f56:	56                   	push   %esi
  800f57:	ff d0                	call   *%eax
  800f59:	89 c3                	mov    %eax,%ebx
  800f5b:	83 c4 10             	add    $0x10,%esp
  800f5e:	eb 05                	jmp    800f65 <fd_close+0x66>
		else
			r = 0;
  800f60:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800f65:	83 ec 08             	sub    $0x8,%esp
  800f68:	56                   	push   %esi
  800f69:	6a 00                	push   $0x0
  800f6b:	e8 c3 fc ff ff       	call   800c33 <sys_page_unmap>
	return r;
  800f70:	83 c4 10             	add    $0x10,%esp
  800f73:	89 d8                	mov    %ebx,%eax
  800f75:	eb 05                	jmp    800f7c <fd_close+0x7d>
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
  800f77:	b8 00 00 00 00       	mov    $0x0,%eax
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
	return r;
}
  800f7c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f7f:	5b                   	pop    %ebx
  800f80:	5e                   	pop    %esi
  800f81:	5d                   	pop    %ebp
  800f82:	c3                   	ret    

00800f83 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800f83:	55                   	push   %ebp
  800f84:	89 e5                	mov    %esp,%ebp
  800f86:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f89:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f8c:	50                   	push   %eax
  800f8d:	ff 75 08             	pushl  0x8(%ebp)
  800f90:	e8 a5 fe ff ff       	call   800e3a <fd_lookup>
  800f95:	83 c4 08             	add    $0x8,%esp
  800f98:	85 c0                	test   %eax,%eax
  800f9a:	78 10                	js     800fac <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800f9c:	83 ec 08             	sub    $0x8,%esp
  800f9f:	6a 01                	push   $0x1
  800fa1:	ff 75 f4             	pushl  -0xc(%ebp)
  800fa4:	e8 56 ff ff ff       	call   800eff <fd_close>
  800fa9:	83 c4 10             	add    $0x10,%esp
}
  800fac:	c9                   	leave  
  800fad:	c3                   	ret    

00800fae <close_all>:

void
close_all(void)
{
  800fae:	55                   	push   %ebp
  800faf:	89 e5                	mov    %esp,%ebp
  800fb1:	53                   	push   %ebx
  800fb2:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800fb5:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800fba:	83 ec 0c             	sub    $0xc,%esp
  800fbd:	53                   	push   %ebx
  800fbe:	e8 c0 ff ff ff       	call   800f83 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800fc3:	43                   	inc    %ebx
  800fc4:	83 c4 10             	add    $0x10,%esp
  800fc7:	83 fb 20             	cmp    $0x20,%ebx
  800fca:	75 ee                	jne    800fba <close_all+0xc>
		close(i);
}
  800fcc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fcf:	c9                   	leave  
  800fd0:	c3                   	ret    

00800fd1 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800fd1:	55                   	push   %ebp
  800fd2:	89 e5                	mov    %esp,%ebp
  800fd4:	57                   	push   %edi
  800fd5:	56                   	push   %esi
  800fd6:	53                   	push   %ebx
  800fd7:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800fda:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800fdd:	50                   	push   %eax
  800fde:	ff 75 08             	pushl  0x8(%ebp)
  800fe1:	e8 54 fe ff ff       	call   800e3a <fd_lookup>
  800fe6:	83 c4 08             	add    $0x8,%esp
  800fe9:	85 c0                	test   %eax,%eax
  800feb:	0f 88 c2 00 00 00    	js     8010b3 <dup+0xe2>
		return r;
	close(newfdnum);
  800ff1:	83 ec 0c             	sub    $0xc,%esp
  800ff4:	ff 75 0c             	pushl  0xc(%ebp)
  800ff7:	e8 87 ff ff ff       	call   800f83 <close>

	newfd = INDEX2FD(newfdnum);
  800ffc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800fff:	c1 e3 0c             	shl    $0xc,%ebx
  801002:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801008:	83 c4 04             	add    $0x4,%esp
  80100b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80100e:	e8 9c fd ff ff       	call   800daf <fd2data>
  801013:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  801015:	89 1c 24             	mov    %ebx,(%esp)
  801018:	e8 92 fd ff ff       	call   800daf <fd2data>
  80101d:	83 c4 10             	add    $0x10,%esp
  801020:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801022:	89 f0                	mov    %esi,%eax
  801024:	c1 e8 16             	shr    $0x16,%eax
  801027:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80102e:	a8 01                	test   $0x1,%al
  801030:	74 35                	je     801067 <dup+0x96>
  801032:	89 f0                	mov    %esi,%eax
  801034:	c1 e8 0c             	shr    $0xc,%eax
  801037:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80103e:	f6 c2 01             	test   $0x1,%dl
  801041:	74 24                	je     801067 <dup+0x96>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801043:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80104a:	83 ec 0c             	sub    $0xc,%esp
  80104d:	25 07 0e 00 00       	and    $0xe07,%eax
  801052:	50                   	push   %eax
  801053:	57                   	push   %edi
  801054:	6a 00                	push   $0x0
  801056:	56                   	push   %esi
  801057:	6a 00                	push   $0x0
  801059:	e8 93 fb ff ff       	call   800bf1 <sys_page_map>
  80105e:	89 c6                	mov    %eax,%esi
  801060:	83 c4 20             	add    $0x20,%esp
  801063:	85 c0                	test   %eax,%eax
  801065:	78 2c                	js     801093 <dup+0xc2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801067:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80106a:	89 d0                	mov    %edx,%eax
  80106c:	c1 e8 0c             	shr    $0xc,%eax
  80106f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801076:	83 ec 0c             	sub    $0xc,%esp
  801079:	25 07 0e 00 00       	and    $0xe07,%eax
  80107e:	50                   	push   %eax
  80107f:	53                   	push   %ebx
  801080:	6a 00                	push   $0x0
  801082:	52                   	push   %edx
  801083:	6a 00                	push   $0x0
  801085:	e8 67 fb ff ff       	call   800bf1 <sys_page_map>
  80108a:	89 c6                	mov    %eax,%esi
  80108c:	83 c4 20             	add    $0x20,%esp
  80108f:	85 c0                	test   %eax,%eax
  801091:	79 1d                	jns    8010b0 <dup+0xdf>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801093:	83 ec 08             	sub    $0x8,%esp
  801096:	53                   	push   %ebx
  801097:	6a 00                	push   $0x0
  801099:	e8 95 fb ff ff       	call   800c33 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80109e:	83 c4 08             	add    $0x8,%esp
  8010a1:	57                   	push   %edi
  8010a2:	6a 00                	push   $0x0
  8010a4:	e8 8a fb ff ff       	call   800c33 <sys_page_unmap>
	return r;
  8010a9:	83 c4 10             	add    $0x10,%esp
  8010ac:	89 f0                	mov    %esi,%eax
  8010ae:	eb 03                	jmp    8010b3 <dup+0xe2>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  8010b0:	8b 45 0c             	mov    0xc(%ebp),%eax

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8010b3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010b6:	5b                   	pop    %ebx
  8010b7:	5e                   	pop    %esi
  8010b8:	5f                   	pop    %edi
  8010b9:	5d                   	pop    %ebp
  8010ba:	c3                   	ret    

008010bb <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8010bb:	55                   	push   %ebp
  8010bc:	89 e5                	mov    %esp,%ebp
  8010be:	53                   	push   %ebx
  8010bf:	83 ec 14             	sub    $0x14,%esp
  8010c2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010c5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010c8:	50                   	push   %eax
  8010c9:	53                   	push   %ebx
  8010ca:	e8 6b fd ff ff       	call   800e3a <fd_lookup>
  8010cf:	83 c4 08             	add    $0x8,%esp
  8010d2:	85 c0                	test   %eax,%eax
  8010d4:	78 67                	js     80113d <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010d6:	83 ec 08             	sub    $0x8,%esp
  8010d9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010dc:	50                   	push   %eax
  8010dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010e0:	ff 30                	pushl  (%eax)
  8010e2:	e8 aa fd ff ff       	call   800e91 <dev_lookup>
  8010e7:	83 c4 10             	add    $0x10,%esp
  8010ea:	85 c0                	test   %eax,%eax
  8010ec:	78 4f                	js     80113d <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8010ee:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8010f1:	8b 42 08             	mov    0x8(%edx),%eax
  8010f4:	83 e0 03             	and    $0x3,%eax
  8010f7:	83 f8 01             	cmp    $0x1,%eax
  8010fa:	75 21                	jne    80111d <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8010fc:	a1 04 40 80 00       	mov    0x804004,%eax
  801101:	8b 40 48             	mov    0x48(%eax),%eax
  801104:	83 ec 04             	sub    $0x4,%esp
  801107:	53                   	push   %ebx
  801108:	50                   	push   %eax
  801109:	68 0d 22 80 00       	push   $0x80220d
  80110e:	e8 46 f0 ff ff       	call   800159 <cprintf>
		return -E_INVAL;
  801113:	83 c4 10             	add    $0x10,%esp
  801116:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80111b:	eb 20                	jmp    80113d <read+0x82>
	}
	if (!dev->dev_read)
  80111d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801120:	8b 40 08             	mov    0x8(%eax),%eax
  801123:	85 c0                	test   %eax,%eax
  801125:	74 11                	je     801138 <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801127:	83 ec 04             	sub    $0x4,%esp
  80112a:	ff 75 10             	pushl  0x10(%ebp)
  80112d:	ff 75 0c             	pushl  0xc(%ebp)
  801130:	52                   	push   %edx
  801131:	ff d0                	call   *%eax
  801133:	83 c4 10             	add    $0x10,%esp
  801136:	eb 05                	jmp    80113d <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801138:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  80113d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801140:	c9                   	leave  
  801141:	c3                   	ret    

00801142 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801142:	55                   	push   %ebp
  801143:	89 e5                	mov    %esp,%ebp
  801145:	57                   	push   %edi
  801146:	56                   	push   %esi
  801147:	53                   	push   %ebx
  801148:	83 ec 0c             	sub    $0xc,%esp
  80114b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80114e:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801151:	85 f6                	test   %esi,%esi
  801153:	74 31                	je     801186 <readn+0x44>
  801155:	b8 00 00 00 00       	mov    $0x0,%eax
  80115a:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  80115f:	83 ec 04             	sub    $0x4,%esp
  801162:	89 f2                	mov    %esi,%edx
  801164:	29 c2                	sub    %eax,%edx
  801166:	52                   	push   %edx
  801167:	03 45 0c             	add    0xc(%ebp),%eax
  80116a:	50                   	push   %eax
  80116b:	57                   	push   %edi
  80116c:	e8 4a ff ff ff       	call   8010bb <read>
		if (m < 0)
  801171:	83 c4 10             	add    $0x10,%esp
  801174:	85 c0                	test   %eax,%eax
  801176:	78 17                	js     80118f <readn+0x4d>
			return m;
		if (m == 0)
  801178:	85 c0                	test   %eax,%eax
  80117a:	74 11                	je     80118d <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80117c:	01 c3                	add    %eax,%ebx
  80117e:	89 d8                	mov    %ebx,%eax
  801180:	39 f3                	cmp    %esi,%ebx
  801182:	72 db                	jb     80115f <readn+0x1d>
  801184:	eb 09                	jmp    80118f <readn+0x4d>
  801186:	b8 00 00 00 00       	mov    $0x0,%eax
  80118b:	eb 02                	jmp    80118f <readn+0x4d>
  80118d:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80118f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801192:	5b                   	pop    %ebx
  801193:	5e                   	pop    %esi
  801194:	5f                   	pop    %edi
  801195:	5d                   	pop    %ebp
  801196:	c3                   	ret    

00801197 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801197:	55                   	push   %ebp
  801198:	89 e5                	mov    %esp,%ebp
  80119a:	53                   	push   %ebx
  80119b:	83 ec 14             	sub    $0x14,%esp
  80119e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011a1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011a4:	50                   	push   %eax
  8011a5:	53                   	push   %ebx
  8011a6:	e8 8f fc ff ff       	call   800e3a <fd_lookup>
  8011ab:	83 c4 08             	add    $0x8,%esp
  8011ae:	85 c0                	test   %eax,%eax
  8011b0:	78 62                	js     801214 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011b2:	83 ec 08             	sub    $0x8,%esp
  8011b5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011b8:	50                   	push   %eax
  8011b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011bc:	ff 30                	pushl  (%eax)
  8011be:	e8 ce fc ff ff       	call   800e91 <dev_lookup>
  8011c3:	83 c4 10             	add    $0x10,%esp
  8011c6:	85 c0                	test   %eax,%eax
  8011c8:	78 4a                	js     801214 <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011cd:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011d1:	75 21                	jne    8011f4 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8011d3:	a1 04 40 80 00       	mov    0x804004,%eax
  8011d8:	8b 40 48             	mov    0x48(%eax),%eax
  8011db:	83 ec 04             	sub    $0x4,%esp
  8011de:	53                   	push   %ebx
  8011df:	50                   	push   %eax
  8011e0:	68 29 22 80 00       	push   $0x802229
  8011e5:	e8 6f ef ff ff       	call   800159 <cprintf>
		return -E_INVAL;
  8011ea:	83 c4 10             	add    $0x10,%esp
  8011ed:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011f2:	eb 20                	jmp    801214 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8011f4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011f7:	8b 52 0c             	mov    0xc(%edx),%edx
  8011fa:	85 d2                	test   %edx,%edx
  8011fc:	74 11                	je     80120f <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8011fe:	83 ec 04             	sub    $0x4,%esp
  801201:	ff 75 10             	pushl  0x10(%ebp)
  801204:	ff 75 0c             	pushl  0xc(%ebp)
  801207:	50                   	push   %eax
  801208:	ff d2                	call   *%edx
  80120a:	83 c4 10             	add    $0x10,%esp
  80120d:	eb 05                	jmp    801214 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80120f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801214:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801217:	c9                   	leave  
  801218:	c3                   	ret    

00801219 <seek>:

int
seek(int fdnum, off_t offset)
{
  801219:	55                   	push   %ebp
  80121a:	89 e5                	mov    %esp,%ebp
  80121c:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80121f:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801222:	50                   	push   %eax
  801223:	ff 75 08             	pushl  0x8(%ebp)
  801226:	e8 0f fc ff ff       	call   800e3a <fd_lookup>
  80122b:	83 c4 08             	add    $0x8,%esp
  80122e:	85 c0                	test   %eax,%eax
  801230:	78 0e                	js     801240 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801232:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801235:	8b 55 0c             	mov    0xc(%ebp),%edx
  801238:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80123b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801240:	c9                   	leave  
  801241:	c3                   	ret    

00801242 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801242:	55                   	push   %ebp
  801243:	89 e5                	mov    %esp,%ebp
  801245:	53                   	push   %ebx
  801246:	83 ec 14             	sub    $0x14,%esp
  801249:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80124c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80124f:	50                   	push   %eax
  801250:	53                   	push   %ebx
  801251:	e8 e4 fb ff ff       	call   800e3a <fd_lookup>
  801256:	83 c4 08             	add    $0x8,%esp
  801259:	85 c0                	test   %eax,%eax
  80125b:	78 5f                	js     8012bc <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80125d:	83 ec 08             	sub    $0x8,%esp
  801260:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801263:	50                   	push   %eax
  801264:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801267:	ff 30                	pushl  (%eax)
  801269:	e8 23 fc ff ff       	call   800e91 <dev_lookup>
  80126e:	83 c4 10             	add    $0x10,%esp
  801271:	85 c0                	test   %eax,%eax
  801273:	78 47                	js     8012bc <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801275:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801278:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80127c:	75 21                	jne    80129f <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80127e:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801283:	8b 40 48             	mov    0x48(%eax),%eax
  801286:	83 ec 04             	sub    $0x4,%esp
  801289:	53                   	push   %ebx
  80128a:	50                   	push   %eax
  80128b:	68 ec 21 80 00       	push   $0x8021ec
  801290:	e8 c4 ee ff ff       	call   800159 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801295:	83 c4 10             	add    $0x10,%esp
  801298:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80129d:	eb 1d                	jmp    8012bc <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  80129f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012a2:	8b 52 18             	mov    0x18(%edx),%edx
  8012a5:	85 d2                	test   %edx,%edx
  8012a7:	74 0e                	je     8012b7 <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8012a9:	83 ec 08             	sub    $0x8,%esp
  8012ac:	ff 75 0c             	pushl  0xc(%ebp)
  8012af:	50                   	push   %eax
  8012b0:	ff d2                	call   *%edx
  8012b2:	83 c4 10             	add    $0x10,%esp
  8012b5:	eb 05                	jmp    8012bc <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8012b7:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8012bc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012bf:	c9                   	leave  
  8012c0:	c3                   	ret    

008012c1 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8012c1:	55                   	push   %ebp
  8012c2:	89 e5                	mov    %esp,%ebp
  8012c4:	53                   	push   %ebx
  8012c5:	83 ec 14             	sub    $0x14,%esp
  8012c8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012cb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012ce:	50                   	push   %eax
  8012cf:	ff 75 08             	pushl  0x8(%ebp)
  8012d2:	e8 63 fb ff ff       	call   800e3a <fd_lookup>
  8012d7:	83 c4 08             	add    $0x8,%esp
  8012da:	85 c0                	test   %eax,%eax
  8012dc:	78 52                	js     801330 <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012de:	83 ec 08             	sub    $0x8,%esp
  8012e1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012e4:	50                   	push   %eax
  8012e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012e8:	ff 30                	pushl  (%eax)
  8012ea:	e8 a2 fb ff ff       	call   800e91 <dev_lookup>
  8012ef:	83 c4 10             	add    $0x10,%esp
  8012f2:	85 c0                	test   %eax,%eax
  8012f4:	78 3a                	js     801330 <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  8012f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012f9:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8012fd:	74 2c                	je     80132b <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8012ff:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801302:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801309:	00 00 00 
	stat->st_isdir = 0;
  80130c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801313:	00 00 00 
	stat->st_dev = dev;
  801316:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80131c:	83 ec 08             	sub    $0x8,%esp
  80131f:	53                   	push   %ebx
  801320:	ff 75 f0             	pushl  -0x10(%ebp)
  801323:	ff 50 14             	call   *0x14(%eax)
  801326:	83 c4 10             	add    $0x10,%esp
  801329:	eb 05                	jmp    801330 <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80132b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801330:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801333:	c9                   	leave  
  801334:	c3                   	ret    

00801335 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801335:	55                   	push   %ebp
  801336:	89 e5                	mov    %esp,%ebp
  801338:	56                   	push   %esi
  801339:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80133a:	83 ec 08             	sub    $0x8,%esp
  80133d:	6a 00                	push   $0x0
  80133f:	ff 75 08             	pushl  0x8(%ebp)
  801342:	e8 75 01 00 00       	call   8014bc <open>
  801347:	89 c3                	mov    %eax,%ebx
  801349:	83 c4 10             	add    $0x10,%esp
  80134c:	85 c0                	test   %eax,%eax
  80134e:	78 1d                	js     80136d <stat+0x38>
		return fd;
	r = fstat(fd, stat);
  801350:	83 ec 08             	sub    $0x8,%esp
  801353:	ff 75 0c             	pushl  0xc(%ebp)
  801356:	50                   	push   %eax
  801357:	e8 65 ff ff ff       	call   8012c1 <fstat>
  80135c:	89 c6                	mov    %eax,%esi
	close(fd);
  80135e:	89 1c 24             	mov    %ebx,(%esp)
  801361:	e8 1d fc ff ff       	call   800f83 <close>
	return r;
  801366:	83 c4 10             	add    $0x10,%esp
  801369:	89 f0                	mov    %esi,%eax
  80136b:	eb 00                	jmp    80136d <stat+0x38>
}
  80136d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801370:	5b                   	pop    %ebx
  801371:	5e                   	pop    %esi
  801372:	5d                   	pop    %ebp
  801373:	c3                   	ret    

00801374 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801374:	55                   	push   %ebp
  801375:	89 e5                	mov    %esp,%ebp
  801377:	56                   	push   %esi
  801378:	53                   	push   %ebx
  801379:	89 c6                	mov    %eax,%esi
  80137b:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80137d:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801384:	75 12                	jne    801398 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801386:	83 ec 0c             	sub    $0xc,%esp
  801389:	6a 01                	push   $0x1
  80138b:	e8 c1 07 00 00       	call   801b51 <ipc_find_env>
  801390:	a3 00 40 80 00       	mov    %eax,0x804000
  801395:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801398:	6a 07                	push   $0x7
  80139a:	68 00 50 80 00       	push   $0x805000
  80139f:	56                   	push   %esi
  8013a0:	ff 35 00 40 80 00    	pushl  0x804000
  8013a6:	e8 47 07 00 00       	call   801af2 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8013ab:	83 c4 0c             	add    $0xc,%esp
  8013ae:	6a 00                	push   $0x0
  8013b0:	53                   	push   %ebx
  8013b1:	6a 00                	push   $0x0
  8013b3:	e8 c5 06 00 00       	call   801a7d <ipc_recv>
}
  8013b8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013bb:	5b                   	pop    %ebx
  8013bc:	5e                   	pop    %esi
  8013bd:	5d                   	pop    %ebp
  8013be:	c3                   	ret    

008013bf <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8013bf:	55                   	push   %ebp
  8013c0:	89 e5                	mov    %esp,%ebp
  8013c2:	53                   	push   %ebx
  8013c3:	83 ec 04             	sub    $0x4,%esp
  8013c6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8013c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8013cc:	8b 40 0c             	mov    0xc(%eax),%eax
  8013cf:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8013d4:	ba 00 00 00 00       	mov    $0x0,%edx
  8013d9:	b8 05 00 00 00       	mov    $0x5,%eax
  8013de:	e8 91 ff ff ff       	call   801374 <fsipc>
  8013e3:	85 c0                	test   %eax,%eax
  8013e5:	78 2c                	js     801413 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8013e7:	83 ec 08             	sub    $0x8,%esp
  8013ea:	68 00 50 80 00       	push   $0x805000
  8013ef:	53                   	push   %ebx
  8013f0:	e8 49 f3 ff ff       	call   80073e <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8013f5:	a1 80 50 80 00       	mov    0x805080,%eax
  8013fa:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801400:	a1 84 50 80 00       	mov    0x805084,%eax
  801405:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80140b:	83 c4 10             	add    $0x10,%esp
  80140e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801413:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801416:	c9                   	leave  
  801417:	c3                   	ret    

00801418 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801418:	55                   	push   %ebp
  801419:	89 e5                	mov    %esp,%ebp
  80141b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80141e:	8b 45 08             	mov    0x8(%ebp),%eax
  801421:	8b 40 0c             	mov    0xc(%eax),%eax
  801424:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801429:	ba 00 00 00 00       	mov    $0x0,%edx
  80142e:	b8 06 00 00 00       	mov    $0x6,%eax
  801433:	e8 3c ff ff ff       	call   801374 <fsipc>
}
  801438:	c9                   	leave  
  801439:	c3                   	ret    

0080143a <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80143a:	55                   	push   %ebp
  80143b:	89 e5                	mov    %esp,%ebp
  80143d:	56                   	push   %esi
  80143e:	53                   	push   %ebx
  80143f:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801442:	8b 45 08             	mov    0x8(%ebp),%eax
  801445:	8b 40 0c             	mov    0xc(%eax),%eax
  801448:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80144d:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801453:	ba 00 00 00 00       	mov    $0x0,%edx
  801458:	b8 03 00 00 00       	mov    $0x3,%eax
  80145d:	e8 12 ff ff ff       	call   801374 <fsipc>
  801462:	89 c3                	mov    %eax,%ebx
  801464:	85 c0                	test   %eax,%eax
  801466:	78 4b                	js     8014b3 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801468:	39 c6                	cmp    %eax,%esi
  80146a:	73 16                	jae    801482 <devfile_read+0x48>
  80146c:	68 46 22 80 00       	push   $0x802246
  801471:	68 4d 22 80 00       	push   $0x80224d
  801476:	6a 7a                	push   $0x7a
  801478:	68 62 22 80 00       	push   $0x802262
  80147d:	e8 b5 05 00 00       	call   801a37 <_panic>
	assert(r <= PGSIZE);
  801482:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801487:	7e 16                	jle    80149f <devfile_read+0x65>
  801489:	68 6d 22 80 00       	push   $0x80226d
  80148e:	68 4d 22 80 00       	push   $0x80224d
  801493:	6a 7b                	push   $0x7b
  801495:	68 62 22 80 00       	push   $0x802262
  80149a:	e8 98 05 00 00       	call   801a37 <_panic>
	memmove(buf, &fsipcbuf, r);
  80149f:	83 ec 04             	sub    $0x4,%esp
  8014a2:	50                   	push   %eax
  8014a3:	68 00 50 80 00       	push   $0x805000
  8014a8:	ff 75 0c             	pushl  0xc(%ebp)
  8014ab:	e8 5b f4 ff ff       	call   80090b <memmove>
	return r;
  8014b0:	83 c4 10             	add    $0x10,%esp
}
  8014b3:	89 d8                	mov    %ebx,%eax
  8014b5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014b8:	5b                   	pop    %ebx
  8014b9:	5e                   	pop    %esi
  8014ba:	5d                   	pop    %ebp
  8014bb:	c3                   	ret    

008014bc <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8014bc:	55                   	push   %ebp
  8014bd:	89 e5                	mov    %esp,%ebp
  8014bf:	53                   	push   %ebx
  8014c0:	83 ec 20             	sub    $0x20,%esp
  8014c3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8014c6:	53                   	push   %ebx
  8014c7:	e8 1b f2 ff ff       	call   8006e7 <strlen>
  8014cc:	83 c4 10             	add    $0x10,%esp
  8014cf:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8014d4:	7f 63                	jg     801539 <open+0x7d>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8014d6:	83 ec 0c             	sub    $0xc,%esp
  8014d9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014dc:	50                   	push   %eax
  8014dd:	e8 e4 f8 ff ff       	call   800dc6 <fd_alloc>
  8014e2:	83 c4 10             	add    $0x10,%esp
  8014e5:	85 c0                	test   %eax,%eax
  8014e7:	78 55                	js     80153e <open+0x82>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8014e9:	83 ec 08             	sub    $0x8,%esp
  8014ec:	53                   	push   %ebx
  8014ed:	68 00 50 80 00       	push   $0x805000
  8014f2:	e8 47 f2 ff ff       	call   80073e <strcpy>
	fsipcbuf.open.req_omode = mode;
  8014f7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014fa:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8014ff:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801502:	b8 01 00 00 00       	mov    $0x1,%eax
  801507:	e8 68 fe ff ff       	call   801374 <fsipc>
  80150c:	89 c3                	mov    %eax,%ebx
  80150e:	83 c4 10             	add    $0x10,%esp
  801511:	85 c0                	test   %eax,%eax
  801513:	79 14                	jns    801529 <open+0x6d>
		fd_close(fd, 0);
  801515:	83 ec 08             	sub    $0x8,%esp
  801518:	6a 00                	push   $0x0
  80151a:	ff 75 f4             	pushl  -0xc(%ebp)
  80151d:	e8 dd f9 ff ff       	call   800eff <fd_close>
		return r;
  801522:	83 c4 10             	add    $0x10,%esp
  801525:	89 d8                	mov    %ebx,%eax
  801527:	eb 15                	jmp    80153e <open+0x82>
	}

	return fd2num(fd);
  801529:	83 ec 0c             	sub    $0xc,%esp
  80152c:	ff 75 f4             	pushl  -0xc(%ebp)
  80152f:	e8 6b f8 ff ff       	call   800d9f <fd2num>
  801534:	83 c4 10             	add    $0x10,%esp
  801537:	eb 05                	jmp    80153e <open+0x82>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801539:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80153e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801541:	c9                   	leave  
  801542:	c3                   	ret    

00801543 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801543:	55                   	push   %ebp
  801544:	89 e5                	mov    %esp,%ebp
  801546:	56                   	push   %esi
  801547:	53                   	push   %ebx
  801548:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80154b:	83 ec 0c             	sub    $0xc,%esp
  80154e:	ff 75 08             	pushl  0x8(%ebp)
  801551:	e8 59 f8 ff ff       	call   800daf <fd2data>
  801556:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801558:	83 c4 08             	add    $0x8,%esp
  80155b:	68 79 22 80 00       	push   $0x802279
  801560:	53                   	push   %ebx
  801561:	e8 d8 f1 ff ff       	call   80073e <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801566:	8b 46 04             	mov    0x4(%esi),%eax
  801569:	2b 06                	sub    (%esi),%eax
  80156b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801571:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801578:	00 00 00 
	stat->st_dev = &devpipe;
  80157b:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801582:	30 80 00 
	return 0;
}
  801585:	b8 00 00 00 00       	mov    $0x0,%eax
  80158a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80158d:	5b                   	pop    %ebx
  80158e:	5e                   	pop    %esi
  80158f:	5d                   	pop    %ebp
  801590:	c3                   	ret    

00801591 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801591:	55                   	push   %ebp
  801592:	89 e5                	mov    %esp,%ebp
  801594:	53                   	push   %ebx
  801595:	83 ec 0c             	sub    $0xc,%esp
  801598:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80159b:	53                   	push   %ebx
  80159c:	6a 00                	push   $0x0
  80159e:	e8 90 f6 ff ff       	call   800c33 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8015a3:	89 1c 24             	mov    %ebx,(%esp)
  8015a6:	e8 04 f8 ff ff       	call   800daf <fd2data>
  8015ab:	83 c4 08             	add    $0x8,%esp
  8015ae:	50                   	push   %eax
  8015af:	6a 00                	push   $0x0
  8015b1:	e8 7d f6 ff ff       	call   800c33 <sys_page_unmap>
}
  8015b6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015b9:	c9                   	leave  
  8015ba:	c3                   	ret    

008015bb <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8015bb:	55                   	push   %ebp
  8015bc:	89 e5                	mov    %esp,%ebp
  8015be:	57                   	push   %edi
  8015bf:	56                   	push   %esi
  8015c0:	53                   	push   %ebx
  8015c1:	83 ec 1c             	sub    $0x1c,%esp
  8015c4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8015c7:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8015c9:	a1 04 40 80 00       	mov    0x804004,%eax
  8015ce:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8015d1:	83 ec 0c             	sub    $0xc,%esp
  8015d4:	ff 75 e0             	pushl  -0x20(%ebp)
  8015d7:	e8 d0 05 00 00       	call   801bac <pageref>
  8015dc:	89 c3                	mov    %eax,%ebx
  8015de:	89 3c 24             	mov    %edi,(%esp)
  8015e1:	e8 c6 05 00 00       	call   801bac <pageref>
  8015e6:	83 c4 10             	add    $0x10,%esp
  8015e9:	39 c3                	cmp    %eax,%ebx
  8015eb:	0f 94 c1             	sete   %cl
  8015ee:	0f b6 c9             	movzbl %cl,%ecx
  8015f1:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8015f4:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8015fa:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8015fd:	39 ce                	cmp    %ecx,%esi
  8015ff:	74 1b                	je     80161c <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801601:	39 c3                	cmp    %eax,%ebx
  801603:	75 c4                	jne    8015c9 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801605:	8b 42 58             	mov    0x58(%edx),%eax
  801608:	ff 75 e4             	pushl  -0x1c(%ebp)
  80160b:	50                   	push   %eax
  80160c:	56                   	push   %esi
  80160d:	68 80 22 80 00       	push   $0x802280
  801612:	e8 42 eb ff ff       	call   800159 <cprintf>
  801617:	83 c4 10             	add    $0x10,%esp
  80161a:	eb ad                	jmp    8015c9 <_pipeisclosed+0xe>
	}
}
  80161c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80161f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801622:	5b                   	pop    %ebx
  801623:	5e                   	pop    %esi
  801624:	5f                   	pop    %edi
  801625:	5d                   	pop    %ebp
  801626:	c3                   	ret    

00801627 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801627:	55                   	push   %ebp
  801628:	89 e5                	mov    %esp,%ebp
  80162a:	57                   	push   %edi
  80162b:	56                   	push   %esi
  80162c:	53                   	push   %ebx
  80162d:	83 ec 18             	sub    $0x18,%esp
  801630:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801633:	56                   	push   %esi
  801634:	e8 76 f7 ff ff       	call   800daf <fd2data>
  801639:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80163b:	83 c4 10             	add    $0x10,%esp
  80163e:	bf 00 00 00 00       	mov    $0x0,%edi
  801643:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801647:	75 42                	jne    80168b <devpipe_write+0x64>
  801649:	eb 4e                	jmp    801699 <devpipe_write+0x72>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80164b:	89 da                	mov    %ebx,%edx
  80164d:	89 f0                	mov    %esi,%eax
  80164f:	e8 67 ff ff ff       	call   8015bb <_pipeisclosed>
  801654:	85 c0                	test   %eax,%eax
  801656:	75 46                	jne    80169e <devpipe_write+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801658:	e8 32 f5 ff ff       	call   800b8f <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80165d:	8b 53 04             	mov    0x4(%ebx),%edx
  801660:	8b 03                	mov    (%ebx),%eax
  801662:	83 c0 20             	add    $0x20,%eax
  801665:	39 c2                	cmp    %eax,%edx
  801667:	73 e2                	jae    80164b <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801669:	8b 45 0c             	mov    0xc(%ebp),%eax
  80166c:	8a 0c 38             	mov    (%eax,%edi,1),%cl
  80166f:	89 d0                	mov    %edx,%eax
  801671:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801676:	79 05                	jns    80167d <devpipe_write+0x56>
  801678:	48                   	dec    %eax
  801679:	83 c8 e0             	or     $0xffffffe0,%eax
  80167c:	40                   	inc    %eax
  80167d:	88 4c 03 08          	mov    %cl,0x8(%ebx,%eax,1)
		p->p_wpos++;
  801681:	42                   	inc    %edx
  801682:	89 53 04             	mov    %edx,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801685:	47                   	inc    %edi
  801686:	39 7d 10             	cmp    %edi,0x10(%ebp)
  801689:	74 0e                	je     801699 <devpipe_write+0x72>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80168b:	8b 53 04             	mov    0x4(%ebx),%edx
  80168e:	8b 03                	mov    (%ebx),%eax
  801690:	83 c0 20             	add    $0x20,%eax
  801693:	39 c2                	cmp    %eax,%edx
  801695:	73 b4                	jae    80164b <devpipe_write+0x24>
  801697:	eb d0                	jmp    801669 <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801699:	8b 45 10             	mov    0x10(%ebp),%eax
  80169c:	eb 05                	jmp    8016a3 <devpipe_write+0x7c>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80169e:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8016a3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016a6:	5b                   	pop    %ebx
  8016a7:	5e                   	pop    %esi
  8016a8:	5f                   	pop    %edi
  8016a9:	5d                   	pop    %ebp
  8016aa:	c3                   	ret    

008016ab <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8016ab:	55                   	push   %ebp
  8016ac:	89 e5                	mov    %esp,%ebp
  8016ae:	57                   	push   %edi
  8016af:	56                   	push   %esi
  8016b0:	53                   	push   %ebx
  8016b1:	83 ec 18             	sub    $0x18,%esp
  8016b4:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8016b7:	57                   	push   %edi
  8016b8:	e8 f2 f6 ff ff       	call   800daf <fd2data>
  8016bd:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8016bf:	83 c4 10             	add    $0x10,%esp
  8016c2:	be 00 00 00 00       	mov    $0x0,%esi
  8016c7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8016cb:	75 3d                	jne    80170a <devpipe_read+0x5f>
  8016cd:	eb 48                	jmp    801717 <devpipe_read+0x6c>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  8016cf:	89 f0                	mov    %esi,%eax
  8016d1:	eb 4e                	jmp    801721 <devpipe_read+0x76>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8016d3:	89 da                	mov    %ebx,%edx
  8016d5:	89 f8                	mov    %edi,%eax
  8016d7:	e8 df fe ff ff       	call   8015bb <_pipeisclosed>
  8016dc:	85 c0                	test   %eax,%eax
  8016de:	75 3c                	jne    80171c <devpipe_read+0x71>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8016e0:	e8 aa f4 ff ff       	call   800b8f <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8016e5:	8b 03                	mov    (%ebx),%eax
  8016e7:	3b 43 04             	cmp    0x4(%ebx),%eax
  8016ea:	74 e7                	je     8016d3 <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8016ec:	25 1f 00 00 80       	and    $0x8000001f,%eax
  8016f1:	79 05                	jns    8016f8 <devpipe_read+0x4d>
  8016f3:	48                   	dec    %eax
  8016f4:	83 c8 e0             	or     $0xffffffe0,%eax
  8016f7:	40                   	inc    %eax
  8016f8:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  8016fc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016ff:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801702:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801704:	46                   	inc    %esi
  801705:	39 75 10             	cmp    %esi,0x10(%ebp)
  801708:	74 0d                	je     801717 <devpipe_read+0x6c>
		while (p->p_rpos == p->p_wpos) {
  80170a:	8b 03                	mov    (%ebx),%eax
  80170c:	3b 43 04             	cmp    0x4(%ebx),%eax
  80170f:	75 db                	jne    8016ec <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801711:	85 f6                	test   %esi,%esi
  801713:	75 ba                	jne    8016cf <devpipe_read+0x24>
  801715:	eb bc                	jmp    8016d3 <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801717:	8b 45 10             	mov    0x10(%ebp),%eax
  80171a:	eb 05                	jmp    801721 <devpipe_read+0x76>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80171c:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801721:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801724:	5b                   	pop    %ebx
  801725:	5e                   	pop    %esi
  801726:	5f                   	pop    %edi
  801727:	5d                   	pop    %ebp
  801728:	c3                   	ret    

00801729 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801729:	55                   	push   %ebp
  80172a:	89 e5                	mov    %esp,%ebp
  80172c:	56                   	push   %esi
  80172d:	53                   	push   %ebx
  80172e:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801731:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801734:	50                   	push   %eax
  801735:	e8 8c f6 ff ff       	call   800dc6 <fd_alloc>
  80173a:	83 c4 10             	add    $0x10,%esp
  80173d:	85 c0                	test   %eax,%eax
  80173f:	0f 88 2a 01 00 00    	js     80186f <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801745:	83 ec 04             	sub    $0x4,%esp
  801748:	68 07 04 00 00       	push   $0x407
  80174d:	ff 75 f4             	pushl  -0xc(%ebp)
  801750:	6a 00                	push   $0x0
  801752:	e8 57 f4 ff ff       	call   800bae <sys_page_alloc>
  801757:	83 c4 10             	add    $0x10,%esp
  80175a:	85 c0                	test   %eax,%eax
  80175c:	0f 88 0d 01 00 00    	js     80186f <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801762:	83 ec 0c             	sub    $0xc,%esp
  801765:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801768:	50                   	push   %eax
  801769:	e8 58 f6 ff ff       	call   800dc6 <fd_alloc>
  80176e:	89 c3                	mov    %eax,%ebx
  801770:	83 c4 10             	add    $0x10,%esp
  801773:	85 c0                	test   %eax,%eax
  801775:	0f 88 e2 00 00 00    	js     80185d <pipe+0x134>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80177b:	83 ec 04             	sub    $0x4,%esp
  80177e:	68 07 04 00 00       	push   $0x407
  801783:	ff 75 f0             	pushl  -0x10(%ebp)
  801786:	6a 00                	push   $0x0
  801788:	e8 21 f4 ff ff       	call   800bae <sys_page_alloc>
  80178d:	89 c3                	mov    %eax,%ebx
  80178f:	83 c4 10             	add    $0x10,%esp
  801792:	85 c0                	test   %eax,%eax
  801794:	0f 88 c3 00 00 00    	js     80185d <pipe+0x134>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80179a:	83 ec 0c             	sub    $0xc,%esp
  80179d:	ff 75 f4             	pushl  -0xc(%ebp)
  8017a0:	e8 0a f6 ff ff       	call   800daf <fd2data>
  8017a5:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017a7:	83 c4 0c             	add    $0xc,%esp
  8017aa:	68 07 04 00 00       	push   $0x407
  8017af:	50                   	push   %eax
  8017b0:	6a 00                	push   $0x0
  8017b2:	e8 f7 f3 ff ff       	call   800bae <sys_page_alloc>
  8017b7:	89 c3                	mov    %eax,%ebx
  8017b9:	83 c4 10             	add    $0x10,%esp
  8017bc:	85 c0                	test   %eax,%eax
  8017be:	0f 88 89 00 00 00    	js     80184d <pipe+0x124>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017c4:	83 ec 0c             	sub    $0xc,%esp
  8017c7:	ff 75 f0             	pushl  -0x10(%ebp)
  8017ca:	e8 e0 f5 ff ff       	call   800daf <fd2data>
  8017cf:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8017d6:	50                   	push   %eax
  8017d7:	6a 00                	push   $0x0
  8017d9:	56                   	push   %esi
  8017da:	6a 00                	push   $0x0
  8017dc:	e8 10 f4 ff ff       	call   800bf1 <sys_page_map>
  8017e1:	89 c3                	mov    %eax,%ebx
  8017e3:	83 c4 20             	add    $0x20,%esp
  8017e6:	85 c0                	test   %eax,%eax
  8017e8:	78 55                	js     80183f <pipe+0x116>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8017ea:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8017f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017f3:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8017f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017f8:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8017ff:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801805:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801808:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80180a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80180d:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801814:	83 ec 0c             	sub    $0xc,%esp
  801817:	ff 75 f4             	pushl  -0xc(%ebp)
  80181a:	e8 80 f5 ff ff       	call   800d9f <fd2num>
  80181f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801822:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801824:	83 c4 04             	add    $0x4,%esp
  801827:	ff 75 f0             	pushl  -0x10(%ebp)
  80182a:	e8 70 f5 ff ff       	call   800d9f <fd2num>
  80182f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801832:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801835:	83 c4 10             	add    $0x10,%esp
  801838:	b8 00 00 00 00       	mov    $0x0,%eax
  80183d:	eb 30                	jmp    80186f <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  80183f:	83 ec 08             	sub    $0x8,%esp
  801842:	56                   	push   %esi
  801843:	6a 00                	push   $0x0
  801845:	e8 e9 f3 ff ff       	call   800c33 <sys_page_unmap>
  80184a:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80184d:	83 ec 08             	sub    $0x8,%esp
  801850:	ff 75 f0             	pushl  -0x10(%ebp)
  801853:	6a 00                	push   $0x0
  801855:	e8 d9 f3 ff ff       	call   800c33 <sys_page_unmap>
  80185a:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80185d:	83 ec 08             	sub    $0x8,%esp
  801860:	ff 75 f4             	pushl  -0xc(%ebp)
  801863:	6a 00                	push   $0x0
  801865:	e8 c9 f3 ff ff       	call   800c33 <sys_page_unmap>
  80186a:	83 c4 10             	add    $0x10,%esp
  80186d:	89 d8                	mov    %ebx,%eax
    err:
	return r;
}
  80186f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801872:	5b                   	pop    %ebx
  801873:	5e                   	pop    %esi
  801874:	5d                   	pop    %ebp
  801875:	c3                   	ret    

00801876 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801876:	55                   	push   %ebp
  801877:	89 e5                	mov    %esp,%ebp
  801879:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80187c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80187f:	50                   	push   %eax
  801880:	ff 75 08             	pushl  0x8(%ebp)
  801883:	e8 b2 f5 ff ff       	call   800e3a <fd_lookup>
  801888:	83 c4 10             	add    $0x10,%esp
  80188b:	85 c0                	test   %eax,%eax
  80188d:	78 18                	js     8018a7 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80188f:	83 ec 0c             	sub    $0xc,%esp
  801892:	ff 75 f4             	pushl  -0xc(%ebp)
  801895:	e8 15 f5 ff ff       	call   800daf <fd2data>
	return _pipeisclosed(fd, p);
  80189a:	89 c2                	mov    %eax,%edx
  80189c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80189f:	e8 17 fd ff ff       	call   8015bb <_pipeisclosed>
  8018a4:	83 c4 10             	add    $0x10,%esp
}
  8018a7:	c9                   	leave  
  8018a8:	c3                   	ret    

008018a9 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8018a9:	55                   	push   %ebp
  8018aa:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8018ac:	b8 00 00 00 00       	mov    $0x0,%eax
  8018b1:	5d                   	pop    %ebp
  8018b2:	c3                   	ret    

008018b3 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8018b3:	55                   	push   %ebp
  8018b4:	89 e5                	mov    %esp,%ebp
  8018b6:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8018b9:	68 98 22 80 00       	push   $0x802298
  8018be:	ff 75 0c             	pushl  0xc(%ebp)
  8018c1:	e8 78 ee ff ff       	call   80073e <strcpy>
	return 0;
}
  8018c6:	b8 00 00 00 00       	mov    $0x0,%eax
  8018cb:	c9                   	leave  
  8018cc:	c3                   	ret    

008018cd <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8018cd:	55                   	push   %ebp
  8018ce:	89 e5                	mov    %esp,%ebp
  8018d0:	57                   	push   %edi
  8018d1:	56                   	push   %esi
  8018d2:	53                   	push   %ebx
  8018d3:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8018d9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8018dd:	74 45                	je     801924 <devcons_write+0x57>
  8018df:	b8 00 00 00 00       	mov    $0x0,%eax
  8018e4:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8018e9:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8018ef:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8018f2:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  8018f4:	83 fb 7f             	cmp    $0x7f,%ebx
  8018f7:	76 05                	jbe    8018fe <devcons_write+0x31>
			m = sizeof(buf) - 1;
  8018f9:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  8018fe:	83 ec 04             	sub    $0x4,%esp
  801901:	53                   	push   %ebx
  801902:	03 45 0c             	add    0xc(%ebp),%eax
  801905:	50                   	push   %eax
  801906:	57                   	push   %edi
  801907:	e8 ff ef ff ff       	call   80090b <memmove>
		sys_cputs(buf, m);
  80190c:	83 c4 08             	add    $0x8,%esp
  80190f:	53                   	push   %ebx
  801910:	57                   	push   %edi
  801911:	e8 dc f1 ff ff       	call   800af2 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801916:	01 de                	add    %ebx,%esi
  801918:	89 f0                	mov    %esi,%eax
  80191a:	83 c4 10             	add    $0x10,%esp
  80191d:	3b 75 10             	cmp    0x10(%ebp),%esi
  801920:	72 cd                	jb     8018ef <devcons_write+0x22>
  801922:	eb 05                	jmp    801929 <devcons_write+0x5c>
  801924:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801929:	89 f0                	mov    %esi,%eax
  80192b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80192e:	5b                   	pop    %ebx
  80192f:	5e                   	pop    %esi
  801930:	5f                   	pop    %edi
  801931:	5d                   	pop    %ebp
  801932:	c3                   	ret    

00801933 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801933:	55                   	push   %ebp
  801934:	89 e5                	mov    %esp,%ebp
  801936:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801939:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80193d:	75 07                	jne    801946 <devcons_read+0x13>
  80193f:	eb 23                	jmp    801964 <devcons_read+0x31>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801941:	e8 49 f2 ff ff       	call   800b8f <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801946:	e8 c5 f1 ff ff       	call   800b10 <sys_cgetc>
  80194b:	85 c0                	test   %eax,%eax
  80194d:	74 f2                	je     801941 <devcons_read+0xe>
		sys_yield();
	if (c < 0)
  80194f:	85 c0                	test   %eax,%eax
  801951:	78 1d                	js     801970 <devcons_read+0x3d>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801953:	83 f8 04             	cmp    $0x4,%eax
  801956:	74 13                	je     80196b <devcons_read+0x38>
		return 0;
	*(char*)vbuf = c;
  801958:	8b 55 0c             	mov    0xc(%ebp),%edx
  80195b:	88 02                	mov    %al,(%edx)
	return 1;
  80195d:	b8 01 00 00 00       	mov    $0x1,%eax
  801962:	eb 0c                	jmp    801970 <devcons_read+0x3d>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801964:	b8 00 00 00 00       	mov    $0x0,%eax
  801969:	eb 05                	jmp    801970 <devcons_read+0x3d>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80196b:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801970:	c9                   	leave  
  801971:	c3                   	ret    

00801972 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801972:	55                   	push   %ebp
  801973:	89 e5                	mov    %esp,%ebp
  801975:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801978:	8b 45 08             	mov    0x8(%ebp),%eax
  80197b:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80197e:	6a 01                	push   $0x1
  801980:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801983:	50                   	push   %eax
  801984:	e8 69 f1 ff ff       	call   800af2 <sys_cputs>
}
  801989:	83 c4 10             	add    $0x10,%esp
  80198c:	c9                   	leave  
  80198d:	c3                   	ret    

0080198e <getchar>:

int
getchar(void)
{
  80198e:	55                   	push   %ebp
  80198f:	89 e5                	mov    %esp,%ebp
  801991:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801994:	6a 01                	push   $0x1
  801996:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801999:	50                   	push   %eax
  80199a:	6a 00                	push   $0x0
  80199c:	e8 1a f7 ff ff       	call   8010bb <read>
	if (r < 0)
  8019a1:	83 c4 10             	add    $0x10,%esp
  8019a4:	85 c0                	test   %eax,%eax
  8019a6:	78 0f                	js     8019b7 <getchar+0x29>
		return r;
	if (r < 1)
  8019a8:	85 c0                	test   %eax,%eax
  8019aa:	7e 06                	jle    8019b2 <getchar+0x24>
		return -E_EOF;
	return c;
  8019ac:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8019b0:	eb 05                	jmp    8019b7 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8019b2:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8019b7:	c9                   	leave  
  8019b8:	c3                   	ret    

008019b9 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8019b9:	55                   	push   %ebp
  8019ba:	89 e5                	mov    %esp,%ebp
  8019bc:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8019bf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019c2:	50                   	push   %eax
  8019c3:	ff 75 08             	pushl  0x8(%ebp)
  8019c6:	e8 6f f4 ff ff       	call   800e3a <fd_lookup>
  8019cb:	83 c4 10             	add    $0x10,%esp
  8019ce:	85 c0                	test   %eax,%eax
  8019d0:	78 11                	js     8019e3 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8019d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019d5:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8019db:	39 10                	cmp    %edx,(%eax)
  8019dd:	0f 94 c0             	sete   %al
  8019e0:	0f b6 c0             	movzbl %al,%eax
}
  8019e3:	c9                   	leave  
  8019e4:	c3                   	ret    

008019e5 <opencons>:

int
opencons(void)
{
  8019e5:	55                   	push   %ebp
  8019e6:	89 e5                	mov    %esp,%ebp
  8019e8:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8019eb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019ee:	50                   	push   %eax
  8019ef:	e8 d2 f3 ff ff       	call   800dc6 <fd_alloc>
  8019f4:	83 c4 10             	add    $0x10,%esp
  8019f7:	85 c0                	test   %eax,%eax
  8019f9:	78 3a                	js     801a35 <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8019fb:	83 ec 04             	sub    $0x4,%esp
  8019fe:	68 07 04 00 00       	push   $0x407
  801a03:	ff 75 f4             	pushl  -0xc(%ebp)
  801a06:	6a 00                	push   $0x0
  801a08:	e8 a1 f1 ff ff       	call   800bae <sys_page_alloc>
  801a0d:	83 c4 10             	add    $0x10,%esp
  801a10:	85 c0                	test   %eax,%eax
  801a12:	78 21                	js     801a35 <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801a14:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801a1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a1d:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801a1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a22:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801a29:	83 ec 0c             	sub    $0xc,%esp
  801a2c:	50                   	push   %eax
  801a2d:	e8 6d f3 ff ff       	call   800d9f <fd2num>
  801a32:	83 c4 10             	add    $0x10,%esp
}
  801a35:	c9                   	leave  
  801a36:	c3                   	ret    

00801a37 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801a37:	55                   	push   %ebp
  801a38:	89 e5                	mov    %esp,%ebp
  801a3a:	56                   	push   %esi
  801a3b:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801a3c:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801a3f:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801a45:	e8 26 f1 ff ff       	call   800b70 <sys_getenvid>
  801a4a:	83 ec 0c             	sub    $0xc,%esp
  801a4d:	ff 75 0c             	pushl  0xc(%ebp)
  801a50:	ff 75 08             	pushl  0x8(%ebp)
  801a53:	56                   	push   %esi
  801a54:	50                   	push   %eax
  801a55:	68 a4 22 80 00       	push   $0x8022a4
  801a5a:	e8 fa e6 ff ff       	call   800159 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801a5f:	83 c4 18             	add    $0x18,%esp
  801a62:	53                   	push   %ebx
  801a63:	ff 75 10             	pushl  0x10(%ebp)
  801a66:	e8 9d e6 ff ff       	call   800108 <vcprintf>
	cprintf("\n");
  801a6b:	c7 04 24 91 22 80 00 	movl   $0x802291,(%esp)
  801a72:	e8 e2 e6 ff ff       	call   800159 <cprintf>
  801a77:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801a7a:	cc                   	int3   
  801a7b:	eb fd                	jmp    801a7a <_panic+0x43>

00801a7d <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a7d:	55                   	push   %ebp
  801a7e:	89 e5                	mov    %esp,%ebp
  801a80:	56                   	push   %esi
  801a81:	53                   	push   %ebx
  801a82:	8b 75 08             	mov    0x8(%ebp),%esi
  801a85:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a88:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");
	int r;
    if (pg != NULL) {
  801a8b:	85 c0                	test   %eax,%eax
  801a8d:	74 0e                	je     801a9d <ipc_recv+0x20>
        r = sys_ipc_recv(pg);
  801a8f:	83 ec 0c             	sub    $0xc,%esp
  801a92:	50                   	push   %eax
  801a93:	e8 c6 f2 ff ff       	call   800d5e <sys_ipc_recv>
  801a98:	83 c4 10             	add    $0x10,%esp
  801a9b:	eb 10                	jmp    801aad <ipc_recv+0x30>
    } else {
        r = sys_ipc_recv((void *) UTOP);
  801a9d:	83 ec 0c             	sub    $0xc,%esp
  801aa0:	68 00 00 c0 ee       	push   $0xeec00000
  801aa5:	e8 b4 f2 ff ff       	call   800d5e <sys_ipc_recv>
  801aaa:	83 c4 10             	add    $0x10,%esp
    }
    if (r < 0) {
  801aad:	85 c0                	test   %eax,%eax
  801aaf:	79 16                	jns    801ac7 <ipc_recv+0x4a>
        // failed
        if (from_env_store != NULL) *from_env_store = 0;
  801ab1:	85 f6                	test   %esi,%esi
  801ab3:	74 06                	je     801abb <ipc_recv+0x3e>
  801ab5:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        if (perm_store != NULL) *perm_store = 0;
  801abb:	85 db                	test   %ebx,%ebx
  801abd:	74 2c                	je     801aeb <ipc_recv+0x6e>
  801abf:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801ac5:	eb 24                	jmp    801aeb <ipc_recv+0x6e>
        return r;
    } else {
        if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801ac7:	85 f6                	test   %esi,%esi
  801ac9:	74 0a                	je     801ad5 <ipc_recv+0x58>
  801acb:	a1 04 40 80 00       	mov    0x804004,%eax
  801ad0:	8b 40 74             	mov    0x74(%eax),%eax
  801ad3:	89 06                	mov    %eax,(%esi)
        if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801ad5:	85 db                	test   %ebx,%ebx
  801ad7:	74 0a                	je     801ae3 <ipc_recv+0x66>
  801ad9:	a1 04 40 80 00       	mov    0x804004,%eax
  801ade:	8b 40 78             	mov    0x78(%eax),%eax
  801ae1:	89 03                	mov    %eax,(%ebx)
        return thisenv->env_ipc_value;
  801ae3:	a1 04 40 80 00       	mov    0x804004,%eax
  801ae8:	8b 40 70             	mov    0x70(%eax),%eax
    }
 
	return 0;
}
  801aeb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801aee:	5b                   	pop    %ebx
  801aef:	5e                   	pop    %esi
  801af0:	5d                   	pop    %ebp
  801af1:	c3                   	ret    

00801af2 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801af2:	55                   	push   %ebp
  801af3:	89 e5                	mov    %esp,%ebp
  801af5:	57                   	push   %edi
  801af6:	56                   	push   %esi
  801af7:	53                   	push   %ebx
  801af8:	83 ec 0c             	sub    $0xc,%esp
  801afb:	8b 75 10             	mov    0x10(%ebp),%esi
  801afe:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");
	int r;
    if (pg == NULL) pg = (void *)UTOP;
  801b01:	85 f6                	test   %esi,%esi
  801b03:	75 05                	jne    801b0a <ipc_send+0x18>
  801b05:	be 00 00 c0 ee       	mov    $0xeec00000,%esi
    do {
        r = sys_ipc_try_send(to_env, val, pg, perm);
  801b0a:	57                   	push   %edi
  801b0b:	56                   	push   %esi
  801b0c:	ff 75 0c             	pushl  0xc(%ebp)
  801b0f:	ff 75 08             	pushl  0x8(%ebp)
  801b12:	e8 24 f2 ff ff       	call   800d3b <sys_ipc_try_send>
  801b17:	89 c3                	mov    %eax,%ebx
        if (r < 0 && r != -E_IPC_NOT_RECV) panic("ipc send failed: %e", r);
  801b19:	83 c4 10             	add    $0x10,%esp
  801b1c:	85 c0                	test   %eax,%eax
  801b1e:	79 17                	jns    801b37 <ipc_send+0x45>
  801b20:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801b23:	74 1d                	je     801b42 <ipc_send+0x50>
  801b25:	50                   	push   %eax
  801b26:	68 c8 22 80 00       	push   $0x8022c8
  801b2b:	6a 40                	push   $0x40
  801b2d:	68 dc 22 80 00       	push   $0x8022dc
  801b32:	e8 00 ff ff ff       	call   801a37 <_panic>
        sys_yield();
  801b37:	e8 53 f0 ff ff       	call   800b8f <sys_yield>
    } while (r != 0);
  801b3c:	85 db                	test   %ebx,%ebx
  801b3e:	75 ca                	jne    801b0a <ipc_send+0x18>
  801b40:	eb 07                	jmp    801b49 <ipc_send+0x57>
	int r;
    if (pg == NULL) pg = (void *)UTOP;
    do {
        r = sys_ipc_try_send(to_env, val, pg, perm);
        if (r < 0 && r != -E_IPC_NOT_RECV) panic("ipc send failed: %e", r);
        sys_yield();
  801b42:	e8 48 f0 ff ff       	call   800b8f <sys_yield>
  801b47:	eb c1                	jmp    801b0a <ipc_send+0x18>
    } while (r != 0);
}
  801b49:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b4c:	5b                   	pop    %ebx
  801b4d:	5e                   	pop    %esi
  801b4e:	5f                   	pop    %edi
  801b4f:	5d                   	pop    %ebp
  801b50:	c3                   	ret    

00801b51 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b51:	55                   	push   %ebp
  801b52:	89 e5                	mov    %esp,%ebp
  801b54:	53                   	push   %ebx
  801b55:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801b58:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  801b5d:	39 c1                	cmp    %eax,%ecx
  801b5f:	74 21                	je     801b82 <ipc_find_env+0x31>
  801b61:	ba 01 00 00 00       	mov    $0x1,%edx
  801b66:	8d 1c 95 00 00 00 00 	lea    0x0(,%edx,4),%ebx
  801b6d:	89 d0                	mov    %edx,%eax
  801b6f:	c1 e0 07             	shl    $0x7,%eax
  801b72:	29 d8                	sub    %ebx,%eax
  801b74:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b79:	8b 40 50             	mov    0x50(%eax),%eax
  801b7c:	39 c8                	cmp    %ecx,%eax
  801b7e:	75 1b                	jne    801b9b <ipc_find_env+0x4a>
  801b80:	eb 05                	jmp    801b87 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b82:	ba 00 00 00 00       	mov    $0x0,%edx
		if (envs[i].env_type == type)
			return envs[i].env_id;
  801b87:	8d 04 95 00 00 00 00 	lea    0x0(,%edx,4),%eax
  801b8e:	c1 e2 07             	shl    $0x7,%edx
  801b91:	29 c2                	sub    %eax,%edx
  801b93:	8b 82 48 00 c0 ee    	mov    -0x113fffb8(%edx),%eax
  801b99:	eb 0e                	jmp    801ba9 <ipc_find_env+0x58>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b9b:	42                   	inc    %edx
  801b9c:	81 fa 00 04 00 00    	cmp    $0x400,%edx
  801ba2:	75 c2                	jne    801b66 <ipc_find_env+0x15>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801ba4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ba9:	5b                   	pop    %ebx
  801baa:	5d                   	pop    %ebp
  801bab:	c3                   	ret    

00801bac <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801bac:	55                   	push   %ebp
  801bad:	89 e5                	mov    %esp,%ebp
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801baf:	8b 45 08             	mov    0x8(%ebp),%eax
  801bb2:	c1 e8 16             	shr    $0x16,%eax
  801bb5:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801bbc:	a8 01                	test   $0x1,%al
  801bbe:	74 21                	je     801be1 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801bc0:	8b 45 08             	mov    0x8(%ebp),%eax
  801bc3:	c1 e8 0c             	shr    $0xc,%eax
  801bc6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801bcd:	a8 01                	test   $0x1,%al
  801bcf:	74 17                	je     801be8 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801bd1:	c1 e8 0c             	shr    $0xc,%eax
  801bd4:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801bdb:	ef 
  801bdc:	0f b7 c0             	movzwl %ax,%eax
  801bdf:	eb 0c                	jmp    801bed <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801be1:	b8 00 00 00 00       	mov    $0x0,%eax
  801be6:	eb 05                	jmp    801bed <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801be8:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801bed:	5d                   	pop    %ebp
  801bee:	c3                   	ret    
  801bef:	90                   	nop

00801bf0 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801bf0:	55                   	push   %ebp
  801bf1:	57                   	push   %edi
  801bf2:	56                   	push   %esi
  801bf3:	53                   	push   %ebx
  801bf4:	83 ec 1c             	sub    $0x1c,%esp
  801bf7:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801bfb:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801bff:	8b 7c 24 38          	mov    0x38(%esp),%edi
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801c03:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801c07:	89 ca                	mov    %ecx,%edx
  const DWunion dd = {.ll = d};
  801c09:	89 f8                	mov    %edi,%eax
  801c0b:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801c0f:	85 f6                	test   %esi,%esi
  801c11:	75 2d                	jne    801c40 <__udivdi3+0x50>
    {
      if (d0 > n1)
  801c13:	39 cf                	cmp    %ecx,%edi
  801c15:	77 65                	ja     801c7c <__udivdi3+0x8c>
  801c17:	89 fd                	mov    %edi,%ebp
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801c19:	85 ff                	test   %edi,%edi
  801c1b:	75 0b                	jne    801c28 <__udivdi3+0x38>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801c1d:	b8 01 00 00 00       	mov    $0x1,%eax
  801c22:	31 d2                	xor    %edx,%edx
  801c24:	f7 f7                	div    %edi
  801c26:	89 c5                	mov    %eax,%ebp

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801c28:	31 d2                	xor    %edx,%edx
  801c2a:	89 c8                	mov    %ecx,%eax
  801c2c:	f7 f5                	div    %ebp
  801c2e:	89 c1                	mov    %eax,%ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801c30:	89 d8                	mov    %ebx,%eax
  801c32:	f7 f5                	div    %ebp
  801c34:	89 cf                	mov    %ecx,%edi
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801c36:	89 fa                	mov    %edi,%edx
  801c38:	83 c4 1c             	add    $0x1c,%esp
  801c3b:	5b                   	pop    %ebx
  801c3c:	5e                   	pop    %esi
  801c3d:	5f                   	pop    %edi
  801c3e:	5d                   	pop    %ebp
  801c3f:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801c40:	39 ce                	cmp    %ecx,%esi
  801c42:	77 28                	ja     801c6c <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801c44:	0f bd fe             	bsr    %esi,%edi
	  if (bm == 0)
  801c47:	83 f7 1f             	xor    $0x1f,%edi
  801c4a:	75 40                	jne    801c8c <__udivdi3+0x9c>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801c4c:	39 ce                	cmp    %ecx,%esi
  801c4e:	72 0a                	jb     801c5a <__udivdi3+0x6a>
  801c50:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801c54:	0f 87 9e 00 00 00    	ja     801cf8 <__udivdi3+0x108>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801c5a:	b8 01 00 00 00       	mov    $0x1,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801c5f:	89 fa                	mov    %edi,%edx
  801c61:	83 c4 1c             	add    $0x1c,%esp
  801c64:	5b                   	pop    %ebx
  801c65:	5e                   	pop    %esi
  801c66:	5f                   	pop    %edi
  801c67:	5d                   	pop    %ebp
  801c68:	c3                   	ret    
  801c69:	8d 76 00             	lea    0x0(%esi),%esi
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801c6c:	31 ff                	xor    %edi,%edi
  801c6e:	31 c0                	xor    %eax,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801c70:	89 fa                	mov    %edi,%edx
  801c72:	83 c4 1c             	add    $0x1c,%esp
  801c75:	5b                   	pop    %ebx
  801c76:	5e                   	pop    %esi
  801c77:	5f                   	pop    %edi
  801c78:	5d                   	pop    %ebp
  801c79:	c3                   	ret    
  801c7a:	66 90                	xchg   %ax,%ax
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801c7c:	89 d8                	mov    %ebx,%eax
  801c7e:	f7 f7                	div    %edi
  801c80:	31 ff                	xor    %edi,%edi
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801c82:	89 fa                	mov    %edi,%edx
  801c84:	83 c4 1c             	add    $0x1c,%esp
  801c87:	5b                   	pop    %ebx
  801c88:	5e                   	pop    %esi
  801c89:	5f                   	pop    %edi
  801c8a:	5d                   	pop    %ebp
  801c8b:	c3                   	ret    
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801c8c:	bd 20 00 00 00       	mov    $0x20,%ebp
  801c91:	89 eb                	mov    %ebp,%ebx
  801c93:	29 fb                	sub    %edi,%ebx

	      d1 = (d1 << bm) | (d0 >> b);
  801c95:	89 f9                	mov    %edi,%ecx
  801c97:	d3 e6                	shl    %cl,%esi
  801c99:	89 c5                	mov    %eax,%ebp
  801c9b:	88 d9                	mov    %bl,%cl
  801c9d:	d3 ed                	shr    %cl,%ebp
  801c9f:	89 e9                	mov    %ebp,%ecx
  801ca1:	09 f1                	or     %esi,%ecx
  801ca3:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
	      d0 = d0 << bm;
  801ca7:	89 f9                	mov    %edi,%ecx
  801ca9:	d3 e0                	shl    %cl,%eax
  801cab:	89 c5                	mov    %eax,%ebp
	      n2 = n1 >> b;
  801cad:	89 d6                	mov    %edx,%esi
  801caf:	88 d9                	mov    %bl,%cl
  801cb1:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
  801cb3:	89 f9                	mov    %edi,%ecx
  801cb5:	d3 e2                	shl    %cl,%edx
  801cb7:	8b 44 24 08          	mov    0x8(%esp),%eax
  801cbb:	88 d9                	mov    %bl,%cl
  801cbd:	d3 e8                	shr    %cl,%eax
  801cbf:	09 c2                	or     %eax,%edx
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801cc1:	89 d0                	mov    %edx,%eax
  801cc3:	89 f2                	mov    %esi,%edx
  801cc5:	f7 74 24 0c          	divl   0xc(%esp)
  801cc9:	89 d6                	mov    %edx,%esi
  801ccb:	89 c3                	mov    %eax,%ebx
	      umul_ppmm (m1, m0, q0, d0);
  801ccd:	f7 e5                	mul    %ebp

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801ccf:	39 d6                	cmp    %edx,%esi
  801cd1:	72 19                	jb     801cec <__udivdi3+0xfc>
  801cd3:	74 0b                	je     801ce0 <__udivdi3+0xf0>
  801cd5:	89 d8                	mov    %ebx,%eax
  801cd7:	31 ff                	xor    %edi,%edi
  801cd9:	e9 58 ff ff ff       	jmp    801c36 <__udivdi3+0x46>
  801cde:	66 90                	xchg   %ax,%ax
  801ce0:	8b 54 24 08          	mov    0x8(%esp),%edx
  801ce4:	89 f9                	mov    %edi,%ecx
  801ce6:	d3 e2                	shl    %cl,%edx
  801ce8:	39 c2                	cmp    %eax,%edx
  801cea:	73 e9                	jae    801cd5 <__udivdi3+0xe5>
  801cec:	8d 43 ff             	lea    -0x1(%ebx),%eax
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801cef:	31 ff                	xor    %edi,%edi
  801cf1:	e9 40 ff ff ff       	jmp    801c36 <__udivdi3+0x46>
  801cf6:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801cf8:	31 c0                	xor    %eax,%eax
  801cfa:	e9 37 ff ff ff       	jmp    801c36 <__udivdi3+0x46>
  801cff:	90                   	nop

00801d00 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  801d00:	55                   	push   %ebp
  801d01:	57                   	push   %edi
  801d02:	56                   	push   %esi
  801d03:	53                   	push   %ebx
  801d04:	83 ec 1c             	sub    $0x1c,%esp
  801d07:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801d0b:	8b 74 24 34          	mov    0x34(%esp),%esi
  801d0f:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801d13:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801d17:	89 44 24 0c          	mov    %eax,0xc(%esp)
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801d1b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801d1f:	89 f3                	mov    %esi,%ebx
  const DWunion dd = {.ll = d};
  801d21:	89 fa                	mov    %edi,%edx
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  801d23:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  n1 = nn.s.high;
  801d27:	89 34 24             	mov    %esi,(%esp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801d2a:	85 c0                	test   %eax,%eax
  801d2c:	75 1a                	jne    801d48 <__umoddi3+0x48>
    {
      if (d0 > n1)
  801d2e:	39 f7                	cmp    %esi,%edi
  801d30:	0f 86 a2 00 00 00    	jbe    801dd8 <__umoddi3+0xd8>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801d36:	89 c8                	mov    %ecx,%eax
  801d38:	89 f2                	mov    %esi,%edx
  801d3a:	f7 f7                	div    %edi
  801d3c:	89 d0                	mov    %edx,%eax

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  801d3e:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801d40:	83 c4 1c             	add    $0x1c,%esp
  801d43:	5b                   	pop    %ebx
  801d44:	5e                   	pop    %esi
  801d45:	5f                   	pop    %edi
  801d46:	5d                   	pop    %ebp
  801d47:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801d48:	39 f0                	cmp    %esi,%eax
  801d4a:	0f 87 ac 00 00 00    	ja     801dfc <__umoddi3+0xfc>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801d50:	0f bd e8             	bsr    %eax,%ebp
	  if (bm == 0)
  801d53:	83 f5 1f             	xor    $0x1f,%ebp
  801d56:	0f 84 ac 00 00 00    	je     801e08 <__umoddi3+0x108>
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801d5c:	bf 20 00 00 00       	mov    $0x20,%edi
  801d61:	29 ef                	sub    %ebp,%edi
  801d63:	89 fe                	mov    %edi,%esi
  801d65:	89 7c 24 0c          	mov    %edi,0xc(%esp)

	      d1 = (d1 << bm) | (d0 >> b);
  801d69:	89 e9                	mov    %ebp,%ecx
  801d6b:	d3 e0                	shl    %cl,%eax
  801d6d:	89 d7                	mov    %edx,%edi
  801d6f:	89 f1                	mov    %esi,%ecx
  801d71:	d3 ef                	shr    %cl,%edi
  801d73:	09 c7                	or     %eax,%edi
	      d0 = d0 << bm;
  801d75:	89 e9                	mov    %ebp,%ecx
  801d77:	d3 e2                	shl    %cl,%edx
  801d79:	89 14 24             	mov    %edx,(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801d7c:	89 d8                	mov    %ebx,%eax
  801d7e:	d3 e0                	shl    %cl,%eax
  801d80:	89 c2                	mov    %eax,%edx
	      n0 = n0 << bm;
  801d82:	8b 44 24 08          	mov    0x8(%esp),%eax
  801d86:	d3 e0                	shl    %cl,%eax
  801d88:	89 44 24 04          	mov    %eax,0x4(%esp)

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801d8c:	8b 44 24 08          	mov    0x8(%esp),%eax
  801d90:	89 f1                	mov    %esi,%ecx
  801d92:	d3 e8                	shr    %cl,%eax
  801d94:	09 d0                	or     %edx,%eax
  801d96:	d3 eb                	shr    %cl,%ebx
  801d98:	89 da                	mov    %ebx,%edx
  801d9a:	f7 f7                	div    %edi
  801d9c:	89 d3                	mov    %edx,%ebx
	      umul_ppmm (m1, m0, q0, d0);
  801d9e:	f7 24 24             	mull   (%esp)
  801da1:	89 c6                	mov    %eax,%esi
  801da3:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801da5:	39 d3                	cmp    %edx,%ebx
  801da7:	0f 82 87 00 00 00    	jb     801e34 <__umoddi3+0x134>
  801dad:	0f 84 91 00 00 00    	je     801e44 <__umoddi3+0x144>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  801db3:	8b 54 24 04          	mov    0x4(%esp),%edx
  801db7:	29 f2                	sub    %esi,%edx
  801db9:	19 cb                	sbb    %ecx,%ebx
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801dbb:	89 d8                	mov    %ebx,%eax
  801dbd:	8a 4c 24 0c          	mov    0xc(%esp),%cl
  801dc1:	d3 e0                	shl    %cl,%eax
  801dc3:	89 e9                	mov    %ebp,%ecx
  801dc5:	d3 ea                	shr    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  801dc7:	09 d0                	or     %edx,%eax
  801dc9:	89 e9                	mov    %ebp,%ecx
  801dcb:	d3 eb                	shr    %cl,%ebx
  801dcd:	89 da                	mov    %ebx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801dcf:	83 c4 1c             	add    $0x1c,%esp
  801dd2:	5b                   	pop    %ebx
  801dd3:	5e                   	pop    %esi
  801dd4:	5f                   	pop    %edi
  801dd5:	5d                   	pop    %ebp
  801dd6:	c3                   	ret    
  801dd7:	90                   	nop
  801dd8:	89 fd                	mov    %edi,%ebp
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801dda:	85 ff                	test   %edi,%edi
  801ddc:	75 0b                	jne    801de9 <__umoddi3+0xe9>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801dde:	b8 01 00 00 00       	mov    $0x1,%eax
  801de3:	31 d2                	xor    %edx,%edx
  801de5:	f7 f7                	div    %edi
  801de7:	89 c5                	mov    %eax,%ebp

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801de9:	89 f0                	mov    %esi,%eax
  801deb:	31 d2                	xor    %edx,%edx
  801ded:	f7 f5                	div    %ebp
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801def:	89 c8                	mov    %ecx,%eax
  801df1:	f7 f5                	div    %ebp
  801df3:	89 d0                	mov    %edx,%eax
  801df5:	e9 44 ff ff ff       	jmp    801d3e <__umoddi3+0x3e>
  801dfa:	66 90                	xchg   %ax,%ax
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  801dfc:	89 c8                	mov    %ecx,%eax
  801dfe:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801e00:	83 c4 1c             	add    $0x1c,%esp
  801e03:	5b                   	pop    %ebx
  801e04:	5e                   	pop    %esi
  801e05:	5f                   	pop    %edi
  801e06:	5d                   	pop    %ebp
  801e07:	c3                   	ret    

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801e08:	3b 04 24             	cmp    (%esp),%eax
  801e0b:	72 06                	jb     801e13 <__umoddi3+0x113>
  801e0d:	3b 7c 24 04          	cmp    0x4(%esp),%edi
  801e11:	77 0f                	ja     801e22 <__umoddi3+0x122>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801e13:	89 f2                	mov    %esi,%edx
  801e15:	29 f9                	sub    %edi,%ecx
  801e17:	1b 54 24 0c          	sbb    0xc(%esp),%edx
  801e1b:	89 14 24             	mov    %edx,(%esp)
  801e1e:	89 4c 24 04          	mov    %ecx,0x4(%esp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  801e22:	8b 44 24 04          	mov    0x4(%esp),%eax
  801e26:	8b 14 24             	mov    (%esp),%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801e29:	83 c4 1c             	add    $0x1c,%esp
  801e2c:	5b                   	pop    %ebx
  801e2d:	5e                   	pop    %esi
  801e2e:	5f                   	pop    %edi
  801e2f:	5d                   	pop    %ebp
  801e30:	c3                   	ret    
  801e31:	8d 76 00             	lea    0x0(%esi),%esi
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801e34:	2b 04 24             	sub    (%esp),%eax
  801e37:	19 fa                	sbb    %edi,%edx
  801e39:	89 d1                	mov    %edx,%ecx
  801e3b:	89 c6                	mov    %eax,%esi
  801e3d:	e9 71 ff ff ff       	jmp    801db3 <__umoddi3+0xb3>
  801e42:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801e44:	39 44 24 04          	cmp    %eax,0x4(%esp)
  801e48:	72 ea                	jb     801e34 <__umoddi3+0x134>
  801e4a:	89 d9                	mov    %ebx,%ecx
  801e4c:	e9 62 ff ff ff       	jmp    801db3 <__umoddi3+0xb3>
