
obj/user/divzero.debug:     file format elf32-i386


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
  80002c:	e8 2f 00 00 00       	call   800060 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

int zero;

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	zero = 0;
  800039:	c7 05 04 40 80 00 00 	movl   $0x0,0x804004
  800040:	00 00 00 
	cprintf("1/0 is %08x!\n", 1/zero);
  800043:	b8 01 00 00 00       	mov    $0x1,%eax
  800048:	b9 00 00 00 00       	mov    $0x0,%ecx
  80004d:	99                   	cltd   
  80004e:	f7 f9                	idiv   %ecx
  800050:	50                   	push   %eax
  800051:	68 60 1e 80 00       	push   $0x801e60
  800056:	e8 00 01 00 00       	call   80015b <cprintf>
}
  80005b:	83 c4 10             	add    $0x10,%esp
  80005e:	c9                   	leave  
  80005f:	c3                   	ret    

00800060 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800060:	55                   	push   %ebp
  800061:	89 e5                	mov    %esp,%ebp
  800063:	56                   	push   %esi
  800064:	53                   	push   %ebx
  800065:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800068:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80006b:	e8 02 0b 00 00       	call   800b72 <sys_getenvid>
  800070:	25 ff 03 00 00       	and    $0x3ff,%eax
  800075:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80007c:	c1 e0 07             	shl    $0x7,%eax
  80007f:	29 d0                	sub    %edx,%eax
  800081:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800086:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80008b:	85 db                	test   %ebx,%ebx
  80008d:	7e 07                	jle    800096 <libmain+0x36>
		binaryname = argv[0];
  80008f:	8b 06                	mov    (%esi),%eax
  800091:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800096:	83 ec 08             	sub    $0x8,%esp
  800099:	56                   	push   %esi
  80009a:	53                   	push   %ebx
  80009b:	e8 93 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000a0:	e8 0a 00 00 00       	call   8000af <exit>
}
  8000a5:	83 c4 10             	add    $0x10,%esp
  8000a8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000ab:	5b                   	pop    %ebx
  8000ac:	5e                   	pop    %esi
  8000ad:	5d                   	pop    %ebp
  8000ae:	c3                   	ret    

008000af <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000af:	55                   	push   %ebp
  8000b0:	89 e5                	mov    %esp,%ebp
  8000b2:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000b5:	e8 f6 0e 00 00       	call   800fb0 <close_all>
	sys_env_destroy(0);
  8000ba:	83 ec 0c             	sub    $0xc,%esp
  8000bd:	6a 00                	push   $0x0
  8000bf:	e8 6d 0a 00 00       	call   800b31 <sys_env_destroy>
}
  8000c4:	83 c4 10             	add    $0x10,%esp
  8000c7:	c9                   	leave  
  8000c8:	c3                   	ret    

008000c9 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000c9:	55                   	push   %ebp
  8000ca:	89 e5                	mov    %esp,%ebp
  8000cc:	53                   	push   %ebx
  8000cd:	83 ec 04             	sub    $0x4,%esp
  8000d0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000d3:	8b 13                	mov    (%ebx),%edx
  8000d5:	8d 42 01             	lea    0x1(%edx),%eax
  8000d8:	89 03                	mov    %eax,(%ebx)
  8000da:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000dd:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000e1:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000e6:	75 1a                	jne    800102 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8000e8:	83 ec 08             	sub    $0x8,%esp
  8000eb:	68 ff 00 00 00       	push   $0xff
  8000f0:	8d 43 08             	lea    0x8(%ebx),%eax
  8000f3:	50                   	push   %eax
  8000f4:	e8 fb 09 00 00       	call   800af4 <sys_cputs>
		b->idx = 0;
  8000f9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8000ff:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800102:	ff 43 04             	incl   0x4(%ebx)
}
  800105:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800108:	c9                   	leave  
  800109:	c3                   	ret    

0080010a <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80010a:	55                   	push   %ebp
  80010b:	89 e5                	mov    %esp,%ebp
  80010d:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800113:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80011a:	00 00 00 
	b.cnt = 0;
  80011d:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800124:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800127:	ff 75 0c             	pushl  0xc(%ebp)
  80012a:	ff 75 08             	pushl  0x8(%ebp)
  80012d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800133:	50                   	push   %eax
  800134:	68 c9 00 80 00       	push   $0x8000c9
  800139:	e8 54 01 00 00       	call   800292 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80013e:	83 c4 08             	add    $0x8,%esp
  800141:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800147:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80014d:	50                   	push   %eax
  80014e:	e8 a1 09 00 00       	call   800af4 <sys_cputs>

	return b.cnt;
}
  800153:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800159:	c9                   	leave  
  80015a:	c3                   	ret    

0080015b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80015b:	55                   	push   %ebp
  80015c:	89 e5                	mov    %esp,%ebp
  80015e:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800161:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800164:	50                   	push   %eax
  800165:	ff 75 08             	pushl  0x8(%ebp)
  800168:	e8 9d ff ff ff       	call   80010a <vcprintf>
	va_end(ap);

	return cnt;
}
  80016d:	c9                   	leave  
  80016e:	c3                   	ret    

0080016f <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80016f:	55                   	push   %ebp
  800170:	89 e5                	mov    %esp,%ebp
  800172:	57                   	push   %edi
  800173:	56                   	push   %esi
  800174:	53                   	push   %ebx
  800175:	83 ec 1c             	sub    $0x1c,%esp
  800178:	89 c6                	mov    %eax,%esi
  80017a:	89 d7                	mov    %edx,%edi
  80017c:	8b 45 08             	mov    0x8(%ebp),%eax
  80017f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800182:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800185:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800188:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80018b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800190:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800193:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800196:	39 d3                	cmp    %edx,%ebx
  800198:	72 11                	jb     8001ab <printnum+0x3c>
  80019a:	39 45 10             	cmp    %eax,0x10(%ebp)
  80019d:	76 0c                	jbe    8001ab <printnum+0x3c>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80019f:	8b 45 14             	mov    0x14(%ebp),%eax
  8001a2:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001a5:	85 db                	test   %ebx,%ebx
  8001a7:	7f 37                	jg     8001e0 <printnum+0x71>
  8001a9:	eb 44                	jmp    8001ef <printnum+0x80>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001ab:	83 ec 0c             	sub    $0xc,%esp
  8001ae:	ff 75 18             	pushl  0x18(%ebp)
  8001b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8001b4:	48                   	dec    %eax
  8001b5:	50                   	push   %eax
  8001b6:	ff 75 10             	pushl  0x10(%ebp)
  8001b9:	83 ec 08             	sub    $0x8,%esp
  8001bc:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001bf:	ff 75 e0             	pushl  -0x20(%ebp)
  8001c2:	ff 75 dc             	pushl  -0x24(%ebp)
  8001c5:	ff 75 d8             	pushl  -0x28(%ebp)
  8001c8:	e8 27 1a 00 00       	call   801bf4 <__udivdi3>
  8001cd:	83 c4 18             	add    $0x18,%esp
  8001d0:	52                   	push   %edx
  8001d1:	50                   	push   %eax
  8001d2:	89 fa                	mov    %edi,%edx
  8001d4:	89 f0                	mov    %esi,%eax
  8001d6:	e8 94 ff ff ff       	call   80016f <printnum>
  8001db:	83 c4 20             	add    $0x20,%esp
  8001de:	eb 0f                	jmp    8001ef <printnum+0x80>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001e0:	83 ec 08             	sub    $0x8,%esp
  8001e3:	57                   	push   %edi
  8001e4:	ff 75 18             	pushl  0x18(%ebp)
  8001e7:	ff d6                	call   *%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001e9:	83 c4 10             	add    $0x10,%esp
  8001ec:	4b                   	dec    %ebx
  8001ed:	75 f1                	jne    8001e0 <printnum+0x71>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001ef:	83 ec 08             	sub    $0x8,%esp
  8001f2:	57                   	push   %edi
  8001f3:	83 ec 04             	sub    $0x4,%esp
  8001f6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001f9:	ff 75 e0             	pushl  -0x20(%ebp)
  8001fc:	ff 75 dc             	pushl  -0x24(%ebp)
  8001ff:	ff 75 d8             	pushl  -0x28(%ebp)
  800202:	e8 fd 1a 00 00       	call   801d04 <__umoddi3>
  800207:	83 c4 14             	add    $0x14,%esp
  80020a:	0f be 80 78 1e 80 00 	movsbl 0x801e78(%eax),%eax
  800211:	50                   	push   %eax
  800212:	ff d6                	call   *%esi
}
  800214:	83 c4 10             	add    $0x10,%esp
  800217:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80021a:	5b                   	pop    %ebx
  80021b:	5e                   	pop    %esi
  80021c:	5f                   	pop    %edi
  80021d:	5d                   	pop    %ebp
  80021e:	c3                   	ret    

0080021f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80021f:	55                   	push   %ebp
  800220:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800222:	83 fa 01             	cmp    $0x1,%edx
  800225:	7e 0e                	jle    800235 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800227:	8b 10                	mov    (%eax),%edx
  800229:	8d 4a 08             	lea    0x8(%edx),%ecx
  80022c:	89 08                	mov    %ecx,(%eax)
  80022e:	8b 02                	mov    (%edx),%eax
  800230:	8b 52 04             	mov    0x4(%edx),%edx
  800233:	eb 22                	jmp    800257 <getuint+0x38>
	else if (lflag)
  800235:	85 d2                	test   %edx,%edx
  800237:	74 10                	je     800249 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800239:	8b 10                	mov    (%eax),%edx
  80023b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80023e:	89 08                	mov    %ecx,(%eax)
  800240:	8b 02                	mov    (%edx),%eax
  800242:	ba 00 00 00 00       	mov    $0x0,%edx
  800247:	eb 0e                	jmp    800257 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800249:	8b 10                	mov    (%eax),%edx
  80024b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80024e:	89 08                	mov    %ecx,(%eax)
  800250:	8b 02                	mov    (%edx),%eax
  800252:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800257:	5d                   	pop    %ebp
  800258:	c3                   	ret    

00800259 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800259:	55                   	push   %ebp
  80025a:	89 e5                	mov    %esp,%ebp
  80025c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80025f:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800262:	8b 10                	mov    (%eax),%edx
  800264:	3b 50 04             	cmp    0x4(%eax),%edx
  800267:	73 0a                	jae    800273 <sprintputch+0x1a>
		*b->buf++ = ch;
  800269:	8d 4a 01             	lea    0x1(%edx),%ecx
  80026c:	89 08                	mov    %ecx,(%eax)
  80026e:	8b 45 08             	mov    0x8(%ebp),%eax
  800271:	88 02                	mov    %al,(%edx)
}
  800273:	5d                   	pop    %ebp
  800274:	c3                   	ret    

00800275 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800275:	55                   	push   %ebp
  800276:	89 e5                	mov    %esp,%ebp
  800278:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80027b:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80027e:	50                   	push   %eax
  80027f:	ff 75 10             	pushl  0x10(%ebp)
  800282:	ff 75 0c             	pushl  0xc(%ebp)
  800285:	ff 75 08             	pushl  0x8(%ebp)
  800288:	e8 05 00 00 00       	call   800292 <vprintfmt>
	va_end(ap);
}
  80028d:	83 c4 10             	add    $0x10,%esp
  800290:	c9                   	leave  
  800291:	c3                   	ret    

00800292 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800292:	55                   	push   %ebp
  800293:	89 e5                	mov    %esp,%ebp
  800295:	57                   	push   %edi
  800296:	56                   	push   %esi
  800297:	53                   	push   %ebx
  800298:	83 ec 2c             	sub    $0x2c,%esp
  80029b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80029e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002a1:	eb 03                	jmp    8002a6 <vprintfmt+0x14>
			break;

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
			for (fmt--; fmt[-1] != '%'; fmt--)
  8002a3:	89 75 10             	mov    %esi,0x10(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {    //遍历输入的第一个参数，即输出信息的格式，先把格式字符串中'%'之前的字符一个个输出，因为它们前面没有'%'，所以它们就是要直接显示在屏幕上的
  8002a6:	8b 45 10             	mov    0x10(%ebp),%eax
  8002a9:	8d 70 01             	lea    0x1(%eax),%esi
  8002ac:	0f b6 00             	movzbl (%eax),%eax
  8002af:	83 f8 25             	cmp    $0x25,%eax
  8002b2:	74 25                	je     8002d9 <vprintfmt+0x47>
			if (ch == '\0')									//当然中间如果遇到'\0'，代表这个字符串的访问结束
  8002b4:	85 c0                	test   %eax,%eax
  8002b6:	75 0d                	jne    8002c5 <vprintfmt+0x33>
  8002b8:	e9 b5 03 00 00       	jmp    800672 <vprintfmt+0x3e0>
  8002bd:	85 c0                	test   %eax,%eax
  8002bf:	0f 84 ad 03 00 00    	je     800672 <vprintfmt+0x3e0>
				return;
			putch(ch, putdat);								//调用putch函数，把一个字符ch输出到putdat指针所指向的地址中所存放的值对应的地址处
  8002c5:	83 ec 08             	sub    $0x8,%esp
  8002c8:	53                   	push   %ebx
  8002c9:	50                   	push   %eax
  8002ca:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {    //遍历输入的第一个参数，即输出信息的格式，先把格式字符串中'%'之前的字符一个个输出，因为它们前面没有'%'，所以它们就是要直接显示在屏幕上的
  8002cc:	46                   	inc    %esi
  8002cd:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  8002d1:	83 c4 10             	add    $0x10,%esp
  8002d4:	83 f8 25             	cmp    $0x25,%eax
  8002d7:	75 e4                	jne    8002bd <vprintfmt+0x2b>
			if (width < 0)									//代表有小数点，但是小数点前面并没有数字，比如'%.6f'这种情况，此时代表整数部分全部显示
				width = 0;			
			goto reswitch;

		case '#':
			altflag = 1;
  8002d9:	c6 45 e3 20          	movb   $0x20,-0x1d(%ebp)
  8002dd:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8002e4:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8002eb:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8002f2:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8002f9:	eb 07                	jmp    800302 <vprintfmt+0x70>
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  8002fb:	8b 75 10             	mov    0x10(%ebp),%esi

		// flag to pad on the right
		case '-':											//%后面的'-'代表要进行左对齐输出，右边填空格，如果省略代表右对齐
			padc = '-';										//如果有这个字符代表左对齐，则把对齐方式标志位变为'-'
  8002fe:	c6 45 e3 2d          	movb   $0x2d,-0x1d(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  800302:	8d 46 01             	lea    0x1(%esi),%eax
  800305:	89 45 10             	mov    %eax,0x10(%ebp)
  800308:	0f b6 16             	movzbl (%esi),%edx
  80030b:	8a 06                	mov    (%esi),%al
  80030d:	83 e8 23             	sub    $0x23,%eax
  800310:	3c 55                	cmp    $0x55,%al
  800312:	0f 87 03 03 00 00    	ja     80061b <vprintfmt+0x389>
  800318:	0f b6 c0             	movzbl %al,%eax
  80031b:	ff 24 85 c0 1f 80 00 	jmp    *0x801fc0(,%eax,4)
  800322:	8b 75 10             	mov    0x10(%ebp),%esi
			padc = '-';										//如果有这个字符代表左对齐，则把对齐方式标志位变为'-'
			goto reswitch;									//处理下一个字符

		// flag to pad with 0's instead of spaces
		case '0':											//0--有0表示进行对齐输出时填0,如省略表示填入空格，并且如果为0，则一定是右对齐
			padc = '0';										//对其方式标志位变为0
  800325:	c6 45 e3 30          	movb   $0x30,-0x1d(%ebp)
  800329:	eb d7                	jmp    800302 <vprintfmt+0x70>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {					//把遇到的位数字符串转换为真实的位数，比如输入的'%40'，代表有效位数为40位，下面的循环就是把precesion的值设置为40
				precision = precision * 10 + ch - '0';
  80032b:	8d 42 d0             	lea    -0x30(%edx),%eax
  80032e:	89 c1                	mov    %eax,%ecx
  800330:	89 45 d0             	mov    %eax,-0x30(%ebp)
				ch = *fmt;
  800333:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  800337:	8d 50 d0             	lea    -0x30(%eax),%edx
  80033a:	83 fa 09             	cmp    $0x9,%edx
  80033d:	77 51                	ja     800390 <vprintfmt+0xfe>
  80033f:	8b 75 10             	mov    0x10(%ebp),%esi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {					//把遇到的位数字符串转换为真实的位数，比如输入的'%40'，代表有效位数为40位，下面的循环就是把precesion的值设置为40
  800342:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  800343:	8d 14 89             	lea    (%ecx,%ecx,4),%edx
  800346:	01 d2                	add    %edx,%edx
  800348:	8d 4c 10 d0          	lea    -0x30(%eax,%edx,1),%ecx
				ch = *fmt;
  80034c:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80034f:	8d 50 d0             	lea    -0x30(%eax),%edx
  800352:	83 fa 09             	cmp    $0x9,%edx
  800355:	76 eb                	jbe    800342 <vprintfmt+0xb0>
  800357:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  80035a:	eb 37                	jmp    800393 <vprintfmt+0x101>
					break;
			}
			goto process_precision;							//跳转到process_precistion子过程

		case '*':											//*--代表有效数字的位数也是由输入参数指定的，比如printf("%*.*f", 10, 2, n)，其中10,2就是用来指定显示的有效数字位数的
			precision = va_arg(ap, int);
  80035c:	8b 45 14             	mov    0x14(%ebp),%eax
  80035f:	8d 50 04             	lea    0x4(%eax),%edx
  800362:	89 55 14             	mov    %edx,0x14(%ebp)
  800365:	8b 00                	mov    (%eax),%eax
  800367:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  80036a:	8b 75 10             	mov    0x10(%ebp),%esi
			}
			goto process_precision;							//跳转到process_precistion子过程

		case '*':											//*--代表有效数字的位数也是由输入参数指定的，比如printf("%*.*f", 10, 2, n)，其中10,2就是用来指定显示的有效数字位数的
			precision = va_arg(ap, int);
			goto process_precision;
  80036d:	eb 24                	jmp    800393 <vprintfmt+0x101>
  80036f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800373:	79 07                	jns    80037c <vprintfmt+0xea>
  800375:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  80037c:	8b 75 10             	mov    0x10(%ebp),%esi
  80037f:	eb 81                	jmp    800302 <vprintfmt+0x70>
  800381:	8b 75 10             	mov    0x10(%ebp),%esi
			if (width < 0)									//代表有小数点，但是小数点前面并没有数字，比如'%.6f'这种情况，此时代表整数部分全部显示
				width = 0;			
			goto reswitch;

		case '#':
			altflag = 1;
  800384:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80038b:	e9 72 ff ff ff       	jmp    800302 <vprintfmt+0x70>
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  800390:	8b 75 10             	mov    0x10(%ebp),%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:									//处理输出精度，把width字段赋值为刚刚计算出来的precision值，所以width应该是整数部分的有效数字位数
			if (width < 0)
  800393:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800397:	0f 89 65 ff ff ff    	jns    800302 <vprintfmt+0x70>
				width = precision, precision = -1;
  80039d:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003a0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003a3:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003aa:	e9 53 ff ff ff       	jmp    800302 <vprintfmt+0x70>
			goto reswitch;

		// long flag (doubled for long long)				
		case 'l':											//如果遇到'l'，代表应该是输入long类型，如果有两个'l'代表long long
			lflag++;										//此时把lflag++
  8003af:	ff 45 d4             	incl   -0x2c(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  8003b2:	8b 75 10             	mov    0x10(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)				
		case 'l':											//如果遇到'l'，代表应该是输入long类型，如果有两个'l'代表long long
			lflag++;										//此时把lflag++
			goto reswitch;
  8003b5:	e9 48 ff ff ff       	jmp    800302 <vprintfmt+0x70>

		// character
		case 'c':											//如果是'c'代表显示一个字符
			putch(va_arg(ap, int), putdat);					//调用输出一个字符到内存的函数putch
  8003ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8003bd:	8d 50 04             	lea    0x4(%eax),%edx
  8003c0:	89 55 14             	mov    %edx,0x14(%ebp)
  8003c3:	83 ec 08             	sub    $0x8,%esp
  8003c6:	53                   	push   %ebx
  8003c7:	ff 30                	pushl  (%eax)
  8003c9:	ff d7                	call   *%edi
			break;
  8003cb:	83 c4 10             	add    $0x10,%esp
  8003ce:	e9 d3 fe ff ff       	jmp    8002a6 <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d6:	8d 50 04             	lea    0x4(%eax),%edx
  8003d9:	89 55 14             	mov    %edx,0x14(%ebp)
  8003dc:	8b 00                	mov    (%eax),%eax
  8003de:	85 c0                	test   %eax,%eax
  8003e0:	79 02                	jns    8003e4 <vprintfmt+0x152>
  8003e2:	f7 d8                	neg    %eax
  8003e4:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003e6:	83 f8 0f             	cmp    $0xf,%eax
  8003e9:	7f 0b                	jg     8003f6 <vprintfmt+0x164>
  8003eb:	8b 04 85 20 21 80 00 	mov    0x802120(,%eax,4),%eax
  8003f2:	85 c0                	test   %eax,%eax
  8003f4:	75 15                	jne    80040b <vprintfmt+0x179>
				printfmt(putch, putdat, "error %d", err);
  8003f6:	52                   	push   %edx
  8003f7:	68 90 1e 80 00       	push   $0x801e90
  8003fc:	53                   	push   %ebx
  8003fd:	57                   	push   %edi
  8003fe:	e8 72 fe ff ff       	call   800275 <printfmt>
  800403:	83 c4 10             	add    $0x10,%esp
  800406:	e9 9b fe ff ff       	jmp    8002a6 <vprintfmt+0x14>
			else
				printfmt(putch, putdat, "%s", p);
  80040b:	50                   	push   %eax
  80040c:	68 3f 22 80 00       	push   $0x80223f
  800411:	53                   	push   %ebx
  800412:	57                   	push   %edi
  800413:	e8 5d fe ff ff       	call   800275 <printfmt>
  800418:	83 c4 10             	add    $0x10,%esp
  80041b:	e9 86 fe ff ff       	jmp    8002a6 <vprintfmt+0x14>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800420:	8b 45 14             	mov    0x14(%ebp),%eax
  800423:	8d 50 04             	lea    0x4(%eax),%edx
  800426:	89 55 14             	mov    %edx,0x14(%ebp)
  800429:	8b 00                	mov    (%eax),%eax
  80042b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80042e:	85 c0                	test   %eax,%eax
  800430:	75 07                	jne    800439 <vprintfmt+0x1a7>
				p = "(null)";
  800432:	c7 45 d4 89 1e 80 00 	movl   $0x801e89,-0x2c(%ebp)
			if (width > 0 && padc != '-')
  800439:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80043c:	85 f6                	test   %esi,%esi
  80043e:	0f 8e fb 01 00 00    	jle    80063f <vprintfmt+0x3ad>
  800444:	80 7d e3 2d          	cmpb   $0x2d,-0x1d(%ebp)
  800448:	0f 84 09 02 00 00    	je     800657 <vprintfmt+0x3c5>
				for (width -= strnlen(p, precision); width > 0; width--)
  80044e:	83 ec 08             	sub    $0x8,%esp
  800451:	ff 75 d0             	pushl  -0x30(%ebp)
  800454:	ff 75 d4             	pushl  -0x2c(%ebp)
  800457:	e8 ad 02 00 00       	call   800709 <strnlen>
  80045c:	89 f1                	mov    %esi,%ecx
  80045e:	29 c1                	sub    %eax,%ecx
  800460:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  800463:	83 c4 10             	add    $0x10,%esp
  800466:	85 c9                	test   %ecx,%ecx
  800468:	0f 8e d1 01 00 00    	jle    80063f <vprintfmt+0x3ad>
					putch(padc, putdat);
  80046e:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  800472:	83 ec 08             	sub    $0x8,%esp
  800475:	53                   	push   %ebx
  800476:	56                   	push   %esi
  800477:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800479:	83 c4 10             	add    $0x10,%esp
  80047c:	ff 4d e4             	decl   -0x1c(%ebp)
  80047f:	75 f1                	jne    800472 <vprintfmt+0x1e0>
  800481:	e9 b9 01 00 00       	jmp    80063f <vprintfmt+0x3ad>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800486:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80048a:	74 19                	je     8004a5 <vprintfmt+0x213>
  80048c:	0f be c0             	movsbl %al,%eax
  80048f:	83 e8 20             	sub    $0x20,%eax
  800492:	83 f8 5e             	cmp    $0x5e,%eax
  800495:	76 0e                	jbe    8004a5 <vprintfmt+0x213>
					putch('?', putdat);
  800497:	83 ec 08             	sub    $0x8,%esp
  80049a:	53                   	push   %ebx
  80049b:	6a 3f                	push   $0x3f
  80049d:	ff 55 08             	call   *0x8(%ebp)
  8004a0:	83 c4 10             	add    $0x10,%esp
  8004a3:	eb 0b                	jmp    8004b0 <vprintfmt+0x21e>
				else
					putch(ch, putdat);
  8004a5:	83 ec 08             	sub    $0x8,%esp
  8004a8:	53                   	push   %ebx
  8004a9:	52                   	push   %edx
  8004aa:	ff 55 08             	call   *0x8(%ebp)
  8004ad:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004b0:	ff 4d e4             	decl   -0x1c(%ebp)
  8004b3:	46                   	inc    %esi
  8004b4:	8a 46 ff             	mov    -0x1(%esi),%al
  8004b7:	0f be d0             	movsbl %al,%edx
  8004ba:	85 d2                	test   %edx,%edx
  8004bc:	75 1c                	jne    8004da <vprintfmt+0x248>
  8004be:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004c1:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004c5:	7f 1f                	jg     8004e6 <vprintfmt+0x254>
  8004c7:	e9 da fd ff ff       	jmp    8002a6 <vprintfmt+0x14>
  8004cc:	89 7d 08             	mov    %edi,0x8(%ebp)
  8004cf:	8b 7d d0             	mov    -0x30(%ebp),%edi
  8004d2:	eb 06                	jmp    8004da <vprintfmt+0x248>
  8004d4:	89 7d 08             	mov    %edi,0x8(%ebp)
  8004d7:	8b 7d d0             	mov    -0x30(%ebp),%edi
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004da:	85 ff                	test   %edi,%edi
  8004dc:	78 a8                	js     800486 <vprintfmt+0x1f4>
  8004de:	4f                   	dec    %edi
  8004df:	79 a5                	jns    800486 <vprintfmt+0x1f4>
  8004e1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8004e4:	eb db                	jmp    8004c1 <vprintfmt+0x22f>
  8004e6:	8b 75 e4             	mov    -0x1c(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8004e9:	83 ec 08             	sub    $0x8,%esp
  8004ec:	53                   	push   %ebx
  8004ed:	6a 20                	push   $0x20
  8004ef:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004f1:	4e                   	dec    %esi
  8004f2:	83 c4 10             	add    $0x10,%esp
  8004f5:	85 f6                	test   %esi,%esi
  8004f7:	7f f0                	jg     8004e9 <vprintfmt+0x257>
  8004f9:	e9 a8 fd ff ff       	jmp    8002a6 <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8004fe:	83 7d d4 01          	cmpl   $0x1,-0x2c(%ebp)
  800502:	7e 16                	jle    80051a <vprintfmt+0x288>
		return va_arg(*ap, long long);
  800504:	8b 45 14             	mov    0x14(%ebp),%eax
  800507:	8d 50 08             	lea    0x8(%eax),%edx
  80050a:	89 55 14             	mov    %edx,0x14(%ebp)
  80050d:	8b 50 04             	mov    0x4(%eax),%edx
  800510:	8b 00                	mov    (%eax),%eax
  800512:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800515:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800518:	eb 34                	jmp    80054e <vprintfmt+0x2bc>
	else if (lflag)
  80051a:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80051e:	74 18                	je     800538 <vprintfmt+0x2a6>
		return va_arg(*ap, long);
  800520:	8b 45 14             	mov    0x14(%ebp),%eax
  800523:	8d 50 04             	lea    0x4(%eax),%edx
  800526:	89 55 14             	mov    %edx,0x14(%ebp)
  800529:	8b 30                	mov    (%eax),%esi
  80052b:	89 75 d8             	mov    %esi,-0x28(%ebp)
  80052e:	89 f0                	mov    %esi,%eax
  800530:	c1 f8 1f             	sar    $0x1f,%eax
  800533:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800536:	eb 16                	jmp    80054e <vprintfmt+0x2bc>
	else
		return va_arg(*ap, int);
  800538:	8b 45 14             	mov    0x14(%ebp),%eax
  80053b:	8d 50 04             	lea    0x4(%eax),%edx
  80053e:	89 55 14             	mov    %edx,0x14(%ebp)
  800541:	8b 30                	mov    (%eax),%esi
  800543:	89 75 d8             	mov    %esi,-0x28(%ebp)
  800546:	89 f0                	mov    %esi,%eax
  800548:	c1 f8 1f             	sar    $0x1f,%eax
  80054b:	89 45 dc             	mov    %eax,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80054e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800551:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
  800554:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800558:	0f 89 8a 00 00 00    	jns    8005e8 <vprintfmt+0x356>
				putch('-', putdat);
  80055e:	83 ec 08             	sub    $0x8,%esp
  800561:	53                   	push   %ebx
  800562:	6a 2d                	push   $0x2d
  800564:	ff d7                	call   *%edi
				num = -(long long) num;
  800566:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800569:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80056c:	f7 d8                	neg    %eax
  80056e:	83 d2 00             	adc    $0x0,%edx
  800571:	f7 da                	neg    %edx
  800573:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800576:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80057b:	eb 70                	jmp    8005ed <vprintfmt+0x35b>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80057d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800580:	8d 45 14             	lea    0x14(%ebp),%eax
  800583:	e8 97 fc ff ff       	call   80021f <getuint>
			base = 10;
  800588:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80058d:	eb 5e                	jmp    8005ed <vprintfmt+0x35b>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
  80058f:	83 ec 08             	sub    $0x8,%esp
  800592:	53                   	push   %ebx
  800593:	6a 30                	push   $0x30
  800595:	ff d7                	call   *%edi
			num = getuint(&ap, lflag);
  800597:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80059a:	8d 45 14             	lea    0x14(%ebp),%eax
  80059d:	e8 7d fc ff ff       	call   80021f <getuint>
			base = 8;
			goto number;
  8005a2:	83 c4 10             	add    $0x10,%esp
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  8005a5:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8005aa:	eb 41                	jmp    8005ed <vprintfmt+0x35b>
		// pointer
		case 'p':
			putch('0', putdat);
  8005ac:	83 ec 08             	sub    $0x8,%esp
  8005af:	53                   	push   %ebx
  8005b0:	6a 30                	push   $0x30
  8005b2:	ff d7                	call   *%edi
			putch('x', putdat);
  8005b4:	83 c4 08             	add    $0x8,%esp
  8005b7:	53                   	push   %ebx
  8005b8:	6a 78                	push   $0x78
  8005ba:	ff d7                	call   *%edi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005bc:	8b 45 14             	mov    0x14(%ebp),%eax
  8005bf:	8d 50 04             	lea    0x4(%eax),%edx
  8005c2:	89 55 14             	mov    %edx,0x14(%ebp)
			goto number;
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005c5:	8b 00                	mov    (%eax),%eax
  8005c7:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8005cc:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8005cf:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8005d4:	eb 17                	jmp    8005ed <vprintfmt+0x35b>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8005d6:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8005d9:	8d 45 14             	lea    0x14(%ebp),%eax
  8005dc:	e8 3e fc ff ff       	call   80021f <getuint>
			base = 16;
  8005e1:	b9 10 00 00 00       	mov    $0x10,%ecx
  8005e6:	eb 05                	jmp    8005ed <vprintfmt+0x35b>
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005e8:	b9 0a 00 00 00       	mov    $0xa,%ecx
		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  8005ed:	83 ec 0c             	sub    $0xc,%esp
  8005f0:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  8005f4:	56                   	push   %esi
  8005f5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8005f8:	51                   	push   %ecx
  8005f9:	52                   	push   %edx
  8005fa:	50                   	push   %eax
  8005fb:	89 da                	mov    %ebx,%edx
  8005fd:	89 f8                	mov    %edi,%eax
  8005ff:	e8 6b fb ff ff       	call   80016f <printnum>
			break;
  800604:	83 c4 20             	add    $0x20,%esp
  800607:	e9 9a fc ff ff       	jmp    8002a6 <vprintfmt+0x14>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80060c:	83 ec 08             	sub    $0x8,%esp
  80060f:	53                   	push   %ebx
  800610:	52                   	push   %edx
  800611:	ff d7                	call   *%edi
			break;
  800613:	83 c4 10             	add    $0x10,%esp
  800616:	e9 8b fc ff ff       	jmp    8002a6 <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80061b:	83 ec 08             	sub    $0x8,%esp
  80061e:	53                   	push   %ebx
  80061f:	6a 25                	push   $0x25
  800621:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800623:	83 c4 10             	add    $0x10,%esp
  800626:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80062a:	0f 84 73 fc ff ff    	je     8002a3 <vprintfmt+0x11>
  800630:	4e                   	dec    %esi
  800631:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800635:	75 f9                	jne    800630 <vprintfmt+0x39e>
  800637:	89 75 10             	mov    %esi,0x10(%ebp)
  80063a:	e9 67 fc ff ff       	jmp    8002a6 <vprintfmt+0x14>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80063f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800642:	8d 70 01             	lea    0x1(%eax),%esi
  800645:	8a 00                	mov    (%eax),%al
  800647:	0f be d0             	movsbl %al,%edx
  80064a:	85 d2                	test   %edx,%edx
  80064c:	0f 85 7a fe ff ff    	jne    8004cc <vprintfmt+0x23a>
  800652:	e9 4f fc ff ff       	jmp    8002a6 <vprintfmt+0x14>
  800657:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80065a:	8d 70 01             	lea    0x1(%eax),%esi
  80065d:	8a 00                	mov    (%eax),%al
  80065f:	0f be d0             	movsbl %al,%edx
  800662:	85 d2                	test   %edx,%edx
  800664:	0f 85 6a fe ff ff    	jne    8004d4 <vprintfmt+0x242>
  80066a:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80066d:	e9 77 fe ff ff       	jmp    8004e9 <vprintfmt+0x257>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800672:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800675:	5b                   	pop    %ebx
  800676:	5e                   	pop    %esi
  800677:	5f                   	pop    %edi
  800678:	5d                   	pop    %ebp
  800679:	c3                   	ret    

0080067a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80067a:	55                   	push   %ebp
  80067b:	89 e5                	mov    %esp,%ebp
  80067d:	83 ec 18             	sub    $0x18,%esp
  800680:	8b 45 08             	mov    0x8(%ebp),%eax
  800683:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800686:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800689:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80068d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800690:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800697:	85 c0                	test   %eax,%eax
  800699:	74 26                	je     8006c1 <vsnprintf+0x47>
  80069b:	85 d2                	test   %edx,%edx
  80069d:	7e 29                	jle    8006c8 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80069f:	ff 75 14             	pushl  0x14(%ebp)
  8006a2:	ff 75 10             	pushl  0x10(%ebp)
  8006a5:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006a8:	50                   	push   %eax
  8006a9:	68 59 02 80 00       	push   $0x800259
  8006ae:	e8 df fb ff ff       	call   800292 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006b3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006b6:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006bc:	83 c4 10             	add    $0x10,%esp
  8006bf:	eb 0c                	jmp    8006cd <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006c1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006c6:	eb 05                	jmp    8006cd <vsnprintf+0x53>
  8006c8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006cd:	c9                   	leave  
  8006ce:	c3                   	ret    

008006cf <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006cf:	55                   	push   %ebp
  8006d0:	89 e5                	mov    %esp,%ebp
  8006d2:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006d5:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006d8:	50                   	push   %eax
  8006d9:	ff 75 10             	pushl  0x10(%ebp)
  8006dc:	ff 75 0c             	pushl  0xc(%ebp)
  8006df:	ff 75 08             	pushl  0x8(%ebp)
  8006e2:	e8 93 ff ff ff       	call   80067a <vsnprintf>
	va_end(ap);

	return rc;
}
  8006e7:	c9                   	leave  
  8006e8:	c3                   	ret    

008006e9 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006e9:	55                   	push   %ebp
  8006ea:	89 e5                	mov    %esp,%ebp
  8006ec:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006ef:	80 3a 00             	cmpb   $0x0,(%edx)
  8006f2:	74 0e                	je     800702 <strlen+0x19>
  8006f4:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8006f9:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006fa:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006fe:	75 f9                	jne    8006f9 <strlen+0x10>
  800700:	eb 05                	jmp    800707 <strlen+0x1e>
  800702:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800707:	5d                   	pop    %ebp
  800708:	c3                   	ret    

00800709 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800709:	55                   	push   %ebp
  80070a:	89 e5                	mov    %esp,%ebp
  80070c:	53                   	push   %ebx
  80070d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800710:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800713:	85 c9                	test   %ecx,%ecx
  800715:	74 1a                	je     800731 <strnlen+0x28>
  800717:	80 3b 00             	cmpb   $0x0,(%ebx)
  80071a:	74 1c                	je     800738 <strnlen+0x2f>
  80071c:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  800721:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800723:	39 ca                	cmp    %ecx,%edx
  800725:	74 16                	je     80073d <strnlen+0x34>
  800727:	42                   	inc    %edx
  800728:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  80072d:	75 f2                	jne    800721 <strnlen+0x18>
  80072f:	eb 0c                	jmp    80073d <strnlen+0x34>
  800731:	b8 00 00 00 00       	mov    $0x0,%eax
  800736:	eb 05                	jmp    80073d <strnlen+0x34>
  800738:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  80073d:	5b                   	pop    %ebx
  80073e:	5d                   	pop    %ebp
  80073f:	c3                   	ret    

00800740 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800740:	55                   	push   %ebp
  800741:	89 e5                	mov    %esp,%ebp
  800743:	53                   	push   %ebx
  800744:	8b 45 08             	mov    0x8(%ebp),%eax
  800747:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80074a:	89 c2                	mov    %eax,%edx
  80074c:	42                   	inc    %edx
  80074d:	41                   	inc    %ecx
  80074e:	8a 59 ff             	mov    -0x1(%ecx),%bl
  800751:	88 5a ff             	mov    %bl,-0x1(%edx)
  800754:	84 db                	test   %bl,%bl
  800756:	75 f4                	jne    80074c <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800758:	5b                   	pop    %ebx
  800759:	5d                   	pop    %ebp
  80075a:	c3                   	ret    

0080075b <strcat>:

char *
strcat(char *dst, const char *src)
{
  80075b:	55                   	push   %ebp
  80075c:	89 e5                	mov    %esp,%ebp
  80075e:	53                   	push   %ebx
  80075f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800762:	53                   	push   %ebx
  800763:	e8 81 ff ff ff       	call   8006e9 <strlen>
  800768:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80076b:	ff 75 0c             	pushl  0xc(%ebp)
  80076e:	01 d8                	add    %ebx,%eax
  800770:	50                   	push   %eax
  800771:	e8 ca ff ff ff       	call   800740 <strcpy>
	return dst;
}
  800776:	89 d8                	mov    %ebx,%eax
  800778:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80077b:	c9                   	leave  
  80077c:	c3                   	ret    

0080077d <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80077d:	55                   	push   %ebp
  80077e:	89 e5                	mov    %esp,%ebp
  800780:	56                   	push   %esi
  800781:	53                   	push   %ebx
  800782:	8b 75 08             	mov    0x8(%ebp),%esi
  800785:	8b 55 0c             	mov    0xc(%ebp),%edx
  800788:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80078b:	85 db                	test   %ebx,%ebx
  80078d:	74 14                	je     8007a3 <strncpy+0x26>
  80078f:	01 f3                	add    %esi,%ebx
  800791:	89 f1                	mov    %esi,%ecx
		*dst++ = *src;
  800793:	41                   	inc    %ecx
  800794:	8a 02                	mov    (%edx),%al
  800796:	88 41 ff             	mov    %al,-0x1(%ecx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800799:	80 3a 01             	cmpb   $0x1,(%edx)
  80079c:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80079f:	39 cb                	cmp    %ecx,%ebx
  8007a1:	75 f0                	jne    800793 <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007a3:	89 f0                	mov    %esi,%eax
  8007a5:	5b                   	pop    %ebx
  8007a6:	5e                   	pop    %esi
  8007a7:	5d                   	pop    %ebp
  8007a8:	c3                   	ret    

008007a9 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007a9:	55                   	push   %ebp
  8007aa:	89 e5                	mov    %esp,%ebp
  8007ac:	53                   	push   %ebx
  8007ad:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007b0:	8b 45 10             	mov    0x10(%ebp),%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007b3:	85 c0                	test   %eax,%eax
  8007b5:	74 30                	je     8007e7 <strlcpy+0x3e>
		while (--size > 0 && *src != '\0')
  8007b7:	48                   	dec    %eax
  8007b8:	74 20                	je     8007da <strlcpy+0x31>
  8007ba:	8a 0b                	mov    (%ebx),%cl
  8007bc:	84 c9                	test   %cl,%cl
  8007be:	74 1f                	je     8007df <strlcpy+0x36>
  8007c0:	8d 53 01             	lea    0x1(%ebx),%edx
  8007c3:	01 c3                	add    %eax,%ebx
  8007c5:	8b 45 08             	mov    0x8(%ebp),%eax
			*dst++ = *src++;
  8007c8:	40                   	inc    %eax
  8007c9:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007cc:	39 da                	cmp    %ebx,%edx
  8007ce:	74 12                	je     8007e2 <strlcpy+0x39>
  8007d0:	42                   	inc    %edx
  8007d1:	8a 4a ff             	mov    -0x1(%edx),%cl
  8007d4:	84 c9                	test   %cl,%cl
  8007d6:	75 f0                	jne    8007c8 <strlcpy+0x1f>
  8007d8:	eb 08                	jmp    8007e2 <strlcpy+0x39>
  8007da:	8b 45 08             	mov    0x8(%ebp),%eax
  8007dd:	eb 03                	jmp    8007e2 <strlcpy+0x39>
  8007df:	8b 45 08             	mov    0x8(%ebp),%eax
			*dst++ = *src++;
		*dst = '\0';
  8007e2:	c6 00 00             	movb   $0x0,(%eax)
  8007e5:	eb 03                	jmp    8007ea <strlcpy+0x41>
  8007e7:	8b 45 08             	mov    0x8(%ebp),%eax
	}
	return dst - dst_in;
  8007ea:	2b 45 08             	sub    0x8(%ebp),%eax
}
  8007ed:	5b                   	pop    %ebx
  8007ee:	5d                   	pop    %ebp
  8007ef:	c3                   	ret    

008007f0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007f0:	55                   	push   %ebp
  8007f1:	89 e5                	mov    %esp,%ebp
  8007f3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007f6:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007f9:	8a 01                	mov    (%ecx),%al
  8007fb:	84 c0                	test   %al,%al
  8007fd:	74 10                	je     80080f <strcmp+0x1f>
  8007ff:	3a 02                	cmp    (%edx),%al
  800801:	75 0c                	jne    80080f <strcmp+0x1f>
		p++, q++;
  800803:	41                   	inc    %ecx
  800804:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800805:	8a 01                	mov    (%ecx),%al
  800807:	84 c0                	test   %al,%al
  800809:	74 04                	je     80080f <strcmp+0x1f>
  80080b:	3a 02                	cmp    (%edx),%al
  80080d:	74 f4                	je     800803 <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80080f:	0f b6 c0             	movzbl %al,%eax
  800812:	0f b6 12             	movzbl (%edx),%edx
  800815:	29 d0                	sub    %edx,%eax
}
  800817:	5d                   	pop    %ebp
  800818:	c3                   	ret    

00800819 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800819:	55                   	push   %ebp
  80081a:	89 e5                	mov    %esp,%ebp
  80081c:	56                   	push   %esi
  80081d:	53                   	push   %ebx
  80081e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800821:	8b 55 0c             	mov    0xc(%ebp),%edx
  800824:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  800827:	85 f6                	test   %esi,%esi
  800829:	74 23                	je     80084e <strncmp+0x35>
  80082b:	8a 03                	mov    (%ebx),%al
  80082d:	84 c0                	test   %al,%al
  80082f:	74 2b                	je     80085c <strncmp+0x43>
  800831:	3a 02                	cmp    (%edx),%al
  800833:	75 27                	jne    80085c <strncmp+0x43>
  800835:	8d 43 01             	lea    0x1(%ebx),%eax
  800838:	01 de                	add    %ebx,%esi
		n--, p++, q++;
  80083a:	89 c3                	mov    %eax,%ebx
  80083c:	42                   	inc    %edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80083d:	39 c6                	cmp    %eax,%esi
  80083f:	74 14                	je     800855 <strncmp+0x3c>
  800841:	8a 08                	mov    (%eax),%cl
  800843:	84 c9                	test   %cl,%cl
  800845:	74 15                	je     80085c <strncmp+0x43>
  800847:	40                   	inc    %eax
  800848:	3a 0a                	cmp    (%edx),%cl
  80084a:	74 ee                	je     80083a <strncmp+0x21>
  80084c:	eb 0e                	jmp    80085c <strncmp+0x43>
		n--, p++, q++;
	if (n == 0)
		return 0;
  80084e:	b8 00 00 00 00       	mov    $0x0,%eax
  800853:	eb 0f                	jmp    800864 <strncmp+0x4b>
  800855:	b8 00 00 00 00       	mov    $0x0,%eax
  80085a:	eb 08                	jmp    800864 <strncmp+0x4b>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80085c:	0f b6 03             	movzbl (%ebx),%eax
  80085f:	0f b6 12             	movzbl (%edx),%edx
  800862:	29 d0                	sub    %edx,%eax
}
  800864:	5b                   	pop    %ebx
  800865:	5e                   	pop    %esi
  800866:	5d                   	pop    %ebp
  800867:	c3                   	ret    

00800868 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800868:	55                   	push   %ebp
  800869:	89 e5                	mov    %esp,%ebp
  80086b:	53                   	push   %ebx
  80086c:	8b 45 08             	mov    0x8(%ebp),%eax
  80086f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  800872:	8a 10                	mov    (%eax),%dl
  800874:	84 d2                	test   %dl,%dl
  800876:	74 1a                	je     800892 <strchr+0x2a>
  800878:	88 d9                	mov    %bl,%cl
		if (*s == c)
  80087a:	38 d3                	cmp    %dl,%bl
  80087c:	75 06                	jne    800884 <strchr+0x1c>
  80087e:	eb 17                	jmp    800897 <strchr+0x2f>
  800880:	38 ca                	cmp    %cl,%dl
  800882:	74 13                	je     800897 <strchr+0x2f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800884:	40                   	inc    %eax
  800885:	8a 10                	mov    (%eax),%dl
  800887:	84 d2                	test   %dl,%dl
  800889:	75 f5                	jne    800880 <strchr+0x18>
		if (*s == c)
			return (char *) s;
	return 0;
  80088b:	b8 00 00 00 00       	mov    $0x0,%eax
  800890:	eb 05                	jmp    800897 <strchr+0x2f>
  800892:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800897:	5b                   	pop    %ebx
  800898:	5d                   	pop    %ebp
  800899:	c3                   	ret    

0080089a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80089a:	55                   	push   %ebp
  80089b:	89 e5                	mov    %esp,%ebp
  80089d:	53                   	push   %ebx
  80089e:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  8008a4:	8a 10                	mov    (%eax),%dl
  8008a6:	84 d2                	test   %dl,%dl
  8008a8:	74 13                	je     8008bd <strfind+0x23>
  8008aa:	88 d9                	mov    %bl,%cl
		if (*s == c)
  8008ac:	38 d3                	cmp    %dl,%bl
  8008ae:	75 06                	jne    8008b6 <strfind+0x1c>
  8008b0:	eb 0b                	jmp    8008bd <strfind+0x23>
  8008b2:	38 ca                	cmp    %cl,%dl
  8008b4:	74 07                	je     8008bd <strfind+0x23>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8008b6:	40                   	inc    %eax
  8008b7:	8a 10                	mov    (%eax),%dl
  8008b9:	84 d2                	test   %dl,%dl
  8008bb:	75 f5                	jne    8008b2 <strfind+0x18>
		if (*s == c)
			break;
	return (char *) s;
}
  8008bd:	5b                   	pop    %ebx
  8008be:	5d                   	pop    %ebp
  8008bf:	c3                   	ret    

008008c0 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008c0:	55                   	push   %ebp
  8008c1:	89 e5                	mov    %esp,%ebp
  8008c3:	57                   	push   %edi
  8008c4:	56                   	push   %esi
  8008c5:	53                   	push   %ebx
  8008c6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008c9:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008cc:	85 c9                	test   %ecx,%ecx
  8008ce:	74 36                	je     800906 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008d0:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008d6:	75 28                	jne    800900 <memset+0x40>
  8008d8:	f6 c1 03             	test   $0x3,%cl
  8008db:	75 23                	jne    800900 <memset+0x40>
		c &= 0xFF;
  8008dd:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008e1:	89 d3                	mov    %edx,%ebx
  8008e3:	c1 e3 08             	shl    $0x8,%ebx
  8008e6:	89 d6                	mov    %edx,%esi
  8008e8:	c1 e6 18             	shl    $0x18,%esi
  8008eb:	89 d0                	mov    %edx,%eax
  8008ed:	c1 e0 10             	shl    $0x10,%eax
  8008f0:	09 f0                	or     %esi,%eax
  8008f2:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8008f4:	89 d8                	mov    %ebx,%eax
  8008f6:	09 d0                	or     %edx,%eax
  8008f8:	c1 e9 02             	shr    $0x2,%ecx
  8008fb:	fc                   	cld    
  8008fc:	f3 ab                	rep stos %eax,%es:(%edi)
  8008fe:	eb 06                	jmp    800906 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800900:	8b 45 0c             	mov    0xc(%ebp),%eax
  800903:	fc                   	cld    
  800904:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800906:	89 f8                	mov    %edi,%eax
  800908:	5b                   	pop    %ebx
  800909:	5e                   	pop    %esi
  80090a:	5f                   	pop    %edi
  80090b:	5d                   	pop    %ebp
  80090c:	c3                   	ret    

0080090d <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80090d:	55                   	push   %ebp
  80090e:	89 e5                	mov    %esp,%ebp
  800910:	57                   	push   %edi
  800911:	56                   	push   %esi
  800912:	8b 45 08             	mov    0x8(%ebp),%eax
  800915:	8b 75 0c             	mov    0xc(%ebp),%esi
  800918:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80091b:	39 c6                	cmp    %eax,%esi
  80091d:	73 33                	jae    800952 <memmove+0x45>
  80091f:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800922:	39 d0                	cmp    %edx,%eax
  800924:	73 2c                	jae    800952 <memmove+0x45>
		s += n;
		d += n;
  800926:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800929:	89 d6                	mov    %edx,%esi
  80092b:	09 fe                	or     %edi,%esi
  80092d:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800933:	75 13                	jne    800948 <memmove+0x3b>
  800935:	f6 c1 03             	test   $0x3,%cl
  800938:	75 0e                	jne    800948 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  80093a:	83 ef 04             	sub    $0x4,%edi
  80093d:	8d 72 fc             	lea    -0x4(%edx),%esi
  800940:	c1 e9 02             	shr    $0x2,%ecx
  800943:	fd                   	std    
  800944:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800946:	eb 07                	jmp    80094f <memmove+0x42>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800948:	4f                   	dec    %edi
  800949:	8d 72 ff             	lea    -0x1(%edx),%esi
  80094c:	fd                   	std    
  80094d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80094f:	fc                   	cld    
  800950:	eb 1d                	jmp    80096f <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800952:	89 f2                	mov    %esi,%edx
  800954:	09 c2                	or     %eax,%edx
  800956:	f6 c2 03             	test   $0x3,%dl
  800959:	75 0f                	jne    80096a <memmove+0x5d>
  80095b:	f6 c1 03             	test   $0x3,%cl
  80095e:	75 0a                	jne    80096a <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
  800960:	c1 e9 02             	shr    $0x2,%ecx
  800963:	89 c7                	mov    %eax,%edi
  800965:	fc                   	cld    
  800966:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800968:	eb 05                	jmp    80096f <memmove+0x62>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80096a:	89 c7                	mov    %eax,%edi
  80096c:	fc                   	cld    
  80096d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80096f:	5e                   	pop    %esi
  800970:	5f                   	pop    %edi
  800971:	5d                   	pop    %ebp
  800972:	c3                   	ret    

00800973 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800973:	55                   	push   %ebp
  800974:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800976:	ff 75 10             	pushl  0x10(%ebp)
  800979:	ff 75 0c             	pushl  0xc(%ebp)
  80097c:	ff 75 08             	pushl  0x8(%ebp)
  80097f:	e8 89 ff ff ff       	call   80090d <memmove>
}
  800984:	c9                   	leave  
  800985:	c3                   	ret    

00800986 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800986:	55                   	push   %ebp
  800987:	89 e5                	mov    %esp,%ebp
  800989:	57                   	push   %edi
  80098a:	56                   	push   %esi
  80098b:	53                   	push   %ebx
  80098c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80098f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800992:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800995:	85 c0                	test   %eax,%eax
  800997:	74 33                	je     8009cc <memcmp+0x46>
  800999:	8d 78 ff             	lea    -0x1(%eax),%edi
		if (*s1 != *s2)
  80099c:	8a 13                	mov    (%ebx),%dl
  80099e:	8a 0e                	mov    (%esi),%cl
  8009a0:	38 ca                	cmp    %cl,%dl
  8009a2:	75 13                	jne    8009b7 <memcmp+0x31>
  8009a4:	b8 00 00 00 00       	mov    $0x0,%eax
  8009a9:	eb 16                	jmp    8009c1 <memcmp+0x3b>
  8009ab:	8a 54 03 01          	mov    0x1(%ebx,%eax,1),%dl
  8009af:	40                   	inc    %eax
  8009b0:	8a 0c 06             	mov    (%esi,%eax,1),%cl
  8009b3:	38 ca                	cmp    %cl,%dl
  8009b5:	74 0a                	je     8009c1 <memcmp+0x3b>
			return (int) *s1 - (int) *s2;
  8009b7:	0f b6 c2             	movzbl %dl,%eax
  8009ba:	0f b6 c9             	movzbl %cl,%ecx
  8009bd:	29 c8                	sub    %ecx,%eax
  8009bf:	eb 10                	jmp    8009d1 <memcmp+0x4b>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009c1:	39 f8                	cmp    %edi,%eax
  8009c3:	75 e6                	jne    8009ab <memcmp+0x25>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009c5:	b8 00 00 00 00       	mov    $0x0,%eax
  8009ca:	eb 05                	jmp    8009d1 <memcmp+0x4b>
  8009cc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009d1:	5b                   	pop    %ebx
  8009d2:	5e                   	pop    %esi
  8009d3:	5f                   	pop    %edi
  8009d4:	5d                   	pop    %ebp
  8009d5:	c3                   	ret    

008009d6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009d6:	55                   	push   %ebp
  8009d7:	89 e5                	mov    %esp,%ebp
  8009d9:	53                   	push   %ebx
  8009da:	8b 55 08             	mov    0x8(%ebp),%edx
	const void *ends = (const char *) s + n;
  8009dd:	89 d0                	mov    %edx,%eax
  8009df:	03 45 10             	add    0x10(%ebp),%eax
	for (; s < ends; s++)
  8009e2:	39 c2                	cmp    %eax,%edx
  8009e4:	73 1b                	jae    800a01 <memfind+0x2b>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009e6:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
  8009ea:	0f b6 0a             	movzbl (%edx),%ecx
  8009ed:	39 d9                	cmp    %ebx,%ecx
  8009ef:	75 09                	jne    8009fa <memfind+0x24>
  8009f1:	eb 12                	jmp    800a05 <memfind+0x2f>
  8009f3:	0f b6 0a             	movzbl (%edx),%ecx
  8009f6:	39 d9                	cmp    %ebx,%ecx
  8009f8:	74 0f                	je     800a09 <memfind+0x33>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009fa:	42                   	inc    %edx
  8009fb:	39 d0                	cmp    %edx,%eax
  8009fd:	75 f4                	jne    8009f3 <memfind+0x1d>
  8009ff:	eb 0a                	jmp    800a0b <memfind+0x35>
  800a01:	89 d0                	mov    %edx,%eax
  800a03:	eb 06                	jmp    800a0b <memfind+0x35>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a05:	89 d0                	mov    %edx,%eax
  800a07:	eb 02                	jmp    800a0b <memfind+0x35>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a09:	89 d0                	mov    %edx,%eax
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a0b:	5b                   	pop    %ebx
  800a0c:	5d                   	pop    %ebp
  800a0d:	c3                   	ret    

00800a0e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a0e:	55                   	push   %ebp
  800a0f:	89 e5                	mov    %esp,%ebp
  800a11:	57                   	push   %edi
  800a12:	56                   	push   %esi
  800a13:	53                   	push   %ebx
  800a14:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a17:	eb 01                	jmp    800a1a <strtol+0xc>
		s++;
  800a19:	41                   	inc    %ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a1a:	8a 01                	mov    (%ecx),%al
  800a1c:	3c 20                	cmp    $0x20,%al
  800a1e:	74 f9                	je     800a19 <strtol+0xb>
  800a20:	3c 09                	cmp    $0x9,%al
  800a22:	74 f5                	je     800a19 <strtol+0xb>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a24:	3c 2b                	cmp    $0x2b,%al
  800a26:	75 08                	jne    800a30 <strtol+0x22>
		s++;
  800a28:	41                   	inc    %ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a29:	bf 00 00 00 00       	mov    $0x0,%edi
  800a2e:	eb 11                	jmp    800a41 <strtol+0x33>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a30:	3c 2d                	cmp    $0x2d,%al
  800a32:	75 08                	jne    800a3c <strtol+0x2e>
		s++, neg = 1;
  800a34:	41                   	inc    %ecx
  800a35:	bf 01 00 00 00       	mov    $0x1,%edi
  800a3a:	eb 05                	jmp    800a41 <strtol+0x33>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a3c:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a41:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800a45:	0f 84 87 00 00 00    	je     800ad2 <strtol+0xc4>
  800a4b:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  800a4f:	75 27                	jne    800a78 <strtol+0x6a>
  800a51:	80 39 30             	cmpb   $0x30,(%ecx)
  800a54:	75 22                	jne    800a78 <strtol+0x6a>
  800a56:	e9 88 00 00 00       	jmp    800ae3 <strtol+0xd5>
		s += 2, base = 16;
  800a5b:	83 c1 02             	add    $0x2,%ecx
  800a5e:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  800a65:	eb 11                	jmp    800a78 <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
  800a67:	41                   	inc    %ecx
  800a68:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  800a6f:	eb 07                	jmp    800a78 <strtol+0x6a>
	else if (base == 0)
		base = 10;
  800a71:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)
  800a78:	b8 00 00 00 00       	mov    $0x0,%eax

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a7d:	8a 11                	mov    (%ecx),%dl
  800a7f:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800a82:	80 fb 09             	cmp    $0x9,%bl
  800a85:	77 08                	ja     800a8f <strtol+0x81>
			dig = *s - '0';
  800a87:	0f be d2             	movsbl %dl,%edx
  800a8a:	83 ea 30             	sub    $0x30,%edx
  800a8d:	eb 22                	jmp    800ab1 <strtol+0xa3>
		else if (*s >= 'a' && *s <= 'z')
  800a8f:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a92:	89 f3                	mov    %esi,%ebx
  800a94:	80 fb 19             	cmp    $0x19,%bl
  800a97:	77 08                	ja     800aa1 <strtol+0x93>
			dig = *s - 'a' + 10;
  800a99:	0f be d2             	movsbl %dl,%edx
  800a9c:	83 ea 57             	sub    $0x57,%edx
  800a9f:	eb 10                	jmp    800ab1 <strtol+0xa3>
		else if (*s >= 'A' && *s <= 'Z')
  800aa1:	8d 72 bf             	lea    -0x41(%edx),%esi
  800aa4:	89 f3                	mov    %esi,%ebx
  800aa6:	80 fb 19             	cmp    $0x19,%bl
  800aa9:	77 14                	ja     800abf <strtol+0xb1>
			dig = *s - 'A' + 10;
  800aab:	0f be d2             	movsbl %dl,%edx
  800aae:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800ab1:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ab4:	7d 09                	jge    800abf <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800ab6:	41                   	inc    %ecx
  800ab7:	0f af 45 10          	imul   0x10(%ebp),%eax
  800abb:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800abd:	eb be                	jmp    800a7d <strtol+0x6f>

	if (endptr)
  800abf:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ac3:	74 05                	je     800aca <strtol+0xbc>
		*endptr = (char *) s;
  800ac5:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ac8:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800aca:	85 ff                	test   %edi,%edi
  800acc:	74 21                	je     800aef <strtol+0xe1>
  800ace:	f7 d8                	neg    %eax
  800ad0:	eb 1d                	jmp    800aef <strtol+0xe1>
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ad2:	80 39 30             	cmpb   $0x30,(%ecx)
  800ad5:	75 9a                	jne    800a71 <strtol+0x63>
  800ad7:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800adb:	0f 84 7a ff ff ff    	je     800a5b <strtol+0x4d>
  800ae1:	eb 84                	jmp    800a67 <strtol+0x59>
  800ae3:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800ae7:	0f 84 6e ff ff ff    	je     800a5b <strtol+0x4d>
  800aed:	eb 89                	jmp    800a78 <strtol+0x6a>
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
}
  800aef:	5b                   	pop    %ebx
  800af0:	5e                   	pop    %esi
  800af1:	5f                   	pop    %edi
  800af2:	5d                   	pop    %ebp
  800af3:	c3                   	ret    

00800af4 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800af4:	55                   	push   %ebp
  800af5:	89 e5                	mov    %esp,%ebp
  800af7:	57                   	push   %edi
  800af8:	56                   	push   %esi
  800af9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800afa:	b8 00 00 00 00       	mov    $0x0,%eax
  800aff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b02:	8b 55 08             	mov    0x8(%ebp),%edx
  800b05:	89 c3                	mov    %eax,%ebx
  800b07:	89 c7                	mov    %eax,%edi
  800b09:	89 c6                	mov    %eax,%esi
  800b0b:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b0d:	5b                   	pop    %ebx
  800b0e:	5e                   	pop    %esi
  800b0f:	5f                   	pop    %edi
  800b10:	5d                   	pop    %ebp
  800b11:	c3                   	ret    

00800b12 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b12:	55                   	push   %ebp
  800b13:	89 e5                	mov    %esp,%ebp
  800b15:	57                   	push   %edi
  800b16:	56                   	push   %esi
  800b17:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b18:	ba 00 00 00 00       	mov    $0x0,%edx
  800b1d:	b8 01 00 00 00       	mov    $0x1,%eax
  800b22:	89 d1                	mov    %edx,%ecx
  800b24:	89 d3                	mov    %edx,%ebx
  800b26:	89 d7                	mov    %edx,%edi
  800b28:	89 d6                	mov    %edx,%esi
  800b2a:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b2c:	5b                   	pop    %ebx
  800b2d:	5e                   	pop    %esi
  800b2e:	5f                   	pop    %edi
  800b2f:	5d                   	pop    %ebp
  800b30:	c3                   	ret    

00800b31 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b31:	55                   	push   %ebp
  800b32:	89 e5                	mov    %esp,%ebp
  800b34:	57                   	push   %edi
  800b35:	56                   	push   %esi
  800b36:	53                   	push   %ebx
  800b37:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b3a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b3f:	b8 03 00 00 00       	mov    $0x3,%eax
  800b44:	8b 55 08             	mov    0x8(%ebp),%edx
  800b47:	89 cb                	mov    %ecx,%ebx
  800b49:	89 cf                	mov    %ecx,%edi
  800b4b:	89 ce                	mov    %ecx,%esi
  800b4d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b4f:	85 c0                	test   %eax,%eax
  800b51:	7e 17                	jle    800b6a <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b53:	83 ec 0c             	sub    $0xc,%esp
  800b56:	50                   	push   %eax
  800b57:	6a 03                	push   $0x3
  800b59:	68 7f 21 80 00       	push   $0x80217f
  800b5e:	6a 23                	push   $0x23
  800b60:	68 9c 21 80 00       	push   $0x80219c
  800b65:	e8 cf 0e 00 00       	call   801a39 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b6a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b6d:	5b                   	pop    %ebx
  800b6e:	5e                   	pop    %esi
  800b6f:	5f                   	pop    %edi
  800b70:	5d                   	pop    %ebp
  800b71:	c3                   	ret    

00800b72 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b72:	55                   	push   %ebp
  800b73:	89 e5                	mov    %esp,%ebp
  800b75:	57                   	push   %edi
  800b76:	56                   	push   %esi
  800b77:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b78:	ba 00 00 00 00       	mov    $0x0,%edx
  800b7d:	b8 02 00 00 00       	mov    $0x2,%eax
  800b82:	89 d1                	mov    %edx,%ecx
  800b84:	89 d3                	mov    %edx,%ebx
  800b86:	89 d7                	mov    %edx,%edi
  800b88:	89 d6                	mov    %edx,%esi
  800b8a:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b8c:	5b                   	pop    %ebx
  800b8d:	5e                   	pop    %esi
  800b8e:	5f                   	pop    %edi
  800b8f:	5d                   	pop    %ebp
  800b90:	c3                   	ret    

00800b91 <sys_yield>:

void
sys_yield(void)
{
  800b91:	55                   	push   %ebp
  800b92:	89 e5                	mov    %esp,%ebp
  800b94:	57                   	push   %edi
  800b95:	56                   	push   %esi
  800b96:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b97:	ba 00 00 00 00       	mov    $0x0,%edx
  800b9c:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ba1:	89 d1                	mov    %edx,%ecx
  800ba3:	89 d3                	mov    %edx,%ebx
  800ba5:	89 d7                	mov    %edx,%edi
  800ba7:	89 d6                	mov    %edx,%esi
  800ba9:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bab:	5b                   	pop    %ebx
  800bac:	5e                   	pop    %esi
  800bad:	5f                   	pop    %edi
  800bae:	5d                   	pop    %ebp
  800baf:	c3                   	ret    

00800bb0 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bb0:	55                   	push   %ebp
  800bb1:	89 e5                	mov    %esp,%ebp
  800bb3:	57                   	push   %edi
  800bb4:	56                   	push   %esi
  800bb5:	53                   	push   %ebx
  800bb6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bb9:	be 00 00 00 00       	mov    $0x0,%esi
  800bbe:	b8 04 00 00 00       	mov    $0x4,%eax
  800bc3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bc6:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bcc:	89 f7                	mov    %esi,%edi
  800bce:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bd0:	85 c0                	test   %eax,%eax
  800bd2:	7e 17                	jle    800beb <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bd4:	83 ec 0c             	sub    $0xc,%esp
  800bd7:	50                   	push   %eax
  800bd8:	6a 04                	push   $0x4
  800bda:	68 7f 21 80 00       	push   $0x80217f
  800bdf:	6a 23                	push   $0x23
  800be1:	68 9c 21 80 00       	push   $0x80219c
  800be6:	e8 4e 0e 00 00       	call   801a39 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800beb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bee:	5b                   	pop    %ebx
  800bef:	5e                   	pop    %esi
  800bf0:	5f                   	pop    %edi
  800bf1:	5d                   	pop    %ebp
  800bf2:	c3                   	ret    

00800bf3 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bf3:	55                   	push   %ebp
  800bf4:	89 e5                	mov    %esp,%ebp
  800bf6:	57                   	push   %edi
  800bf7:	56                   	push   %esi
  800bf8:	53                   	push   %ebx
  800bf9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bfc:	b8 05 00 00 00       	mov    $0x5,%eax
  800c01:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c04:	8b 55 08             	mov    0x8(%ebp),%edx
  800c07:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c0a:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c0d:	8b 75 18             	mov    0x18(%ebp),%esi
  800c10:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c12:	85 c0                	test   %eax,%eax
  800c14:	7e 17                	jle    800c2d <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c16:	83 ec 0c             	sub    $0xc,%esp
  800c19:	50                   	push   %eax
  800c1a:	6a 05                	push   $0x5
  800c1c:	68 7f 21 80 00       	push   $0x80217f
  800c21:	6a 23                	push   $0x23
  800c23:	68 9c 21 80 00       	push   $0x80219c
  800c28:	e8 0c 0e 00 00       	call   801a39 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c2d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c30:	5b                   	pop    %ebx
  800c31:	5e                   	pop    %esi
  800c32:	5f                   	pop    %edi
  800c33:	5d                   	pop    %ebp
  800c34:	c3                   	ret    

00800c35 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c35:	55                   	push   %ebp
  800c36:	89 e5                	mov    %esp,%ebp
  800c38:	57                   	push   %edi
  800c39:	56                   	push   %esi
  800c3a:	53                   	push   %ebx
  800c3b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c3e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c43:	b8 06 00 00 00       	mov    $0x6,%eax
  800c48:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c4b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c4e:	89 df                	mov    %ebx,%edi
  800c50:	89 de                	mov    %ebx,%esi
  800c52:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c54:	85 c0                	test   %eax,%eax
  800c56:	7e 17                	jle    800c6f <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c58:	83 ec 0c             	sub    $0xc,%esp
  800c5b:	50                   	push   %eax
  800c5c:	6a 06                	push   $0x6
  800c5e:	68 7f 21 80 00       	push   $0x80217f
  800c63:	6a 23                	push   $0x23
  800c65:	68 9c 21 80 00       	push   $0x80219c
  800c6a:	e8 ca 0d 00 00       	call   801a39 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c6f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c72:	5b                   	pop    %ebx
  800c73:	5e                   	pop    %esi
  800c74:	5f                   	pop    %edi
  800c75:	5d                   	pop    %ebp
  800c76:	c3                   	ret    

00800c77 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c77:	55                   	push   %ebp
  800c78:	89 e5                	mov    %esp,%ebp
  800c7a:	57                   	push   %edi
  800c7b:	56                   	push   %esi
  800c7c:	53                   	push   %ebx
  800c7d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c80:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c85:	b8 08 00 00 00       	mov    $0x8,%eax
  800c8a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c8d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c90:	89 df                	mov    %ebx,%edi
  800c92:	89 de                	mov    %ebx,%esi
  800c94:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c96:	85 c0                	test   %eax,%eax
  800c98:	7e 17                	jle    800cb1 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c9a:	83 ec 0c             	sub    $0xc,%esp
  800c9d:	50                   	push   %eax
  800c9e:	6a 08                	push   $0x8
  800ca0:	68 7f 21 80 00       	push   $0x80217f
  800ca5:	6a 23                	push   $0x23
  800ca7:	68 9c 21 80 00       	push   $0x80219c
  800cac:	e8 88 0d 00 00       	call   801a39 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cb1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb4:	5b                   	pop    %ebx
  800cb5:	5e                   	pop    %esi
  800cb6:	5f                   	pop    %edi
  800cb7:	5d                   	pop    %ebp
  800cb8:	c3                   	ret    

00800cb9 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800cb9:	55                   	push   %ebp
  800cba:	89 e5                	mov    %esp,%ebp
  800cbc:	57                   	push   %edi
  800cbd:	56                   	push   %esi
  800cbe:	53                   	push   %ebx
  800cbf:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc2:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cc7:	b8 09 00 00 00       	mov    $0x9,%eax
  800ccc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ccf:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd2:	89 df                	mov    %ebx,%edi
  800cd4:	89 de                	mov    %ebx,%esi
  800cd6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cd8:	85 c0                	test   %eax,%eax
  800cda:	7e 17                	jle    800cf3 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cdc:	83 ec 0c             	sub    $0xc,%esp
  800cdf:	50                   	push   %eax
  800ce0:	6a 09                	push   $0x9
  800ce2:	68 7f 21 80 00       	push   $0x80217f
  800ce7:	6a 23                	push   $0x23
  800ce9:	68 9c 21 80 00       	push   $0x80219c
  800cee:	e8 46 0d 00 00       	call   801a39 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cf3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf6:	5b                   	pop    %ebx
  800cf7:	5e                   	pop    %esi
  800cf8:	5f                   	pop    %edi
  800cf9:	5d                   	pop    %ebp
  800cfa:	c3                   	ret    

00800cfb <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cfb:	55                   	push   %ebp
  800cfc:	89 e5                	mov    %esp,%ebp
  800cfe:	57                   	push   %edi
  800cff:	56                   	push   %esi
  800d00:	53                   	push   %ebx
  800d01:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d04:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d09:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d0e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d11:	8b 55 08             	mov    0x8(%ebp),%edx
  800d14:	89 df                	mov    %ebx,%edi
  800d16:	89 de                	mov    %ebx,%esi
  800d18:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d1a:	85 c0                	test   %eax,%eax
  800d1c:	7e 17                	jle    800d35 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d1e:	83 ec 0c             	sub    $0xc,%esp
  800d21:	50                   	push   %eax
  800d22:	6a 0a                	push   $0xa
  800d24:	68 7f 21 80 00       	push   $0x80217f
  800d29:	6a 23                	push   $0x23
  800d2b:	68 9c 21 80 00       	push   $0x80219c
  800d30:	e8 04 0d 00 00       	call   801a39 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d35:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d38:	5b                   	pop    %ebx
  800d39:	5e                   	pop    %esi
  800d3a:	5f                   	pop    %edi
  800d3b:	5d                   	pop    %ebp
  800d3c:	c3                   	ret    

00800d3d <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d3d:	55                   	push   %ebp
  800d3e:	89 e5                	mov    %esp,%ebp
  800d40:	57                   	push   %edi
  800d41:	56                   	push   %esi
  800d42:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d43:	be 00 00 00 00       	mov    $0x0,%esi
  800d48:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d4d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d50:	8b 55 08             	mov    0x8(%ebp),%edx
  800d53:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d56:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d59:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d5b:	5b                   	pop    %ebx
  800d5c:	5e                   	pop    %esi
  800d5d:	5f                   	pop    %edi
  800d5e:	5d                   	pop    %ebp
  800d5f:	c3                   	ret    

00800d60 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d60:	55                   	push   %ebp
  800d61:	89 e5                	mov    %esp,%ebp
  800d63:	57                   	push   %edi
  800d64:	56                   	push   %esi
  800d65:	53                   	push   %ebx
  800d66:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d69:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d6e:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d73:	8b 55 08             	mov    0x8(%ebp),%edx
  800d76:	89 cb                	mov    %ecx,%ebx
  800d78:	89 cf                	mov    %ecx,%edi
  800d7a:	89 ce                	mov    %ecx,%esi
  800d7c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d7e:	85 c0                	test   %eax,%eax
  800d80:	7e 17                	jle    800d99 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d82:	83 ec 0c             	sub    $0xc,%esp
  800d85:	50                   	push   %eax
  800d86:	6a 0d                	push   $0xd
  800d88:	68 7f 21 80 00       	push   $0x80217f
  800d8d:	6a 23                	push   $0x23
  800d8f:	68 9c 21 80 00       	push   $0x80219c
  800d94:	e8 a0 0c 00 00       	call   801a39 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d99:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d9c:	5b                   	pop    %ebx
  800d9d:	5e                   	pop    %esi
  800d9e:	5f                   	pop    %edi
  800d9f:	5d                   	pop    %ebp
  800da0:	c3                   	ret    

00800da1 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800da1:	55                   	push   %ebp
  800da2:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800da4:	8b 45 08             	mov    0x8(%ebp),%eax
  800da7:	05 00 00 00 30       	add    $0x30000000,%eax
  800dac:	c1 e8 0c             	shr    $0xc,%eax
}
  800daf:	5d                   	pop    %ebp
  800db0:	c3                   	ret    

00800db1 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800db1:	55                   	push   %ebp
  800db2:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800db4:	8b 45 08             	mov    0x8(%ebp),%eax
  800db7:	05 00 00 00 30       	add    $0x30000000,%eax
  800dbc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800dc1:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800dc6:	5d                   	pop    %ebp
  800dc7:	c3                   	ret    

00800dc8 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800dc8:	55                   	push   %ebp
  800dc9:	89 e5                	mov    %esp,%ebp
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800dcb:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  800dd0:	a8 01                	test   $0x1,%al
  800dd2:	74 34                	je     800e08 <fd_alloc+0x40>
  800dd4:	a1 00 00 74 ef       	mov    0xef740000,%eax
  800dd9:	a8 01                	test   $0x1,%al
  800ddb:	74 32                	je     800e0f <fd_alloc+0x47>
  800ddd:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800de2:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800de4:	89 c2                	mov    %eax,%edx
  800de6:	c1 ea 16             	shr    $0x16,%edx
  800de9:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800df0:	f6 c2 01             	test   $0x1,%dl
  800df3:	74 1f                	je     800e14 <fd_alloc+0x4c>
  800df5:	89 c2                	mov    %eax,%edx
  800df7:	c1 ea 0c             	shr    $0xc,%edx
  800dfa:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e01:	f6 c2 01             	test   $0x1,%dl
  800e04:	75 1a                	jne    800e20 <fd_alloc+0x58>
  800e06:	eb 0c                	jmp    800e14 <fd_alloc+0x4c>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800e08:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  800e0d:	eb 05                	jmp    800e14 <fd_alloc+0x4c>
  800e0f:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  800e14:	8b 45 08             	mov    0x8(%ebp),%eax
  800e17:	89 08                	mov    %ecx,(%eax)
			return 0;
  800e19:	b8 00 00 00 00       	mov    $0x0,%eax
  800e1e:	eb 1a                	jmp    800e3a <fd_alloc+0x72>
  800e20:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800e25:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e2a:	75 b6                	jne    800de2 <fd_alloc+0x1a>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800e2c:	8b 45 08             	mov    0x8(%ebp),%eax
  800e2f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  800e35:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800e3a:	5d                   	pop    %ebp
  800e3b:	c3                   	ret    

00800e3c <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e3c:	55                   	push   %ebp
  800e3d:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e3f:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
  800e43:	77 39                	ja     800e7e <fd_lookup+0x42>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e45:	8b 45 08             	mov    0x8(%ebp),%eax
  800e48:	c1 e0 0c             	shl    $0xc,%eax
  800e4b:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e50:	89 c2                	mov    %eax,%edx
  800e52:	c1 ea 16             	shr    $0x16,%edx
  800e55:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e5c:	f6 c2 01             	test   $0x1,%dl
  800e5f:	74 24                	je     800e85 <fd_lookup+0x49>
  800e61:	89 c2                	mov    %eax,%edx
  800e63:	c1 ea 0c             	shr    $0xc,%edx
  800e66:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e6d:	f6 c2 01             	test   $0x1,%dl
  800e70:	74 1a                	je     800e8c <fd_lookup+0x50>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800e72:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e75:	89 02                	mov    %eax,(%edx)
	return 0;
  800e77:	b8 00 00 00 00       	mov    $0x0,%eax
  800e7c:	eb 13                	jmp    800e91 <fd_lookup+0x55>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e7e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e83:	eb 0c                	jmp    800e91 <fd_lookup+0x55>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e85:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e8a:	eb 05                	jmp    800e91 <fd_lookup+0x55>
  800e8c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800e91:	5d                   	pop    %ebp
  800e92:	c3                   	ret    

00800e93 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800e93:	55                   	push   %ebp
  800e94:	89 e5                	mov    %esp,%ebp
  800e96:	53                   	push   %ebx
  800e97:	83 ec 04             	sub    $0x4,%esp
  800e9a:	8b 45 08             	mov    0x8(%ebp),%eax
  800e9d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  800ea0:	3b 05 04 30 80 00    	cmp    0x803004,%eax
  800ea6:	75 1e                	jne    800ec6 <dev_lookup+0x33>
  800ea8:	eb 0e                	jmp    800eb8 <dev_lookup+0x25>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800eaa:	b8 20 30 80 00       	mov    $0x803020,%eax
  800eaf:	eb 0c                	jmp    800ebd <dev_lookup+0x2a>
  800eb1:	b8 3c 30 80 00       	mov    $0x80303c,%eax
  800eb6:	eb 05                	jmp    800ebd <dev_lookup+0x2a>
  800eb8:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  800ebd:	89 03                	mov    %eax,(%ebx)
			return 0;
  800ebf:	b8 00 00 00 00       	mov    $0x0,%eax
  800ec4:	eb 36                	jmp    800efc <dev_lookup+0x69>
int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  800ec6:	3b 05 20 30 80 00    	cmp    0x803020,%eax
  800ecc:	74 dc                	je     800eaa <dev_lookup+0x17>
  800ece:	3b 05 3c 30 80 00    	cmp    0x80303c,%eax
  800ed4:	74 db                	je     800eb1 <dev_lookup+0x1e>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800ed6:	8b 15 08 40 80 00    	mov    0x804008,%edx
  800edc:	8b 52 48             	mov    0x48(%edx),%edx
  800edf:	83 ec 04             	sub    $0x4,%esp
  800ee2:	50                   	push   %eax
  800ee3:	52                   	push   %edx
  800ee4:	68 ac 21 80 00       	push   $0x8021ac
  800ee9:	e8 6d f2 ff ff       	call   80015b <cprintf>
	*dev = 0;
  800eee:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  800ef4:	83 c4 10             	add    $0x10,%esp
  800ef7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800efc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800eff:	c9                   	leave  
  800f00:	c3                   	ret    

00800f01 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800f01:	55                   	push   %ebp
  800f02:	89 e5                	mov    %esp,%ebp
  800f04:	56                   	push   %esi
  800f05:	53                   	push   %ebx
  800f06:	83 ec 10             	sub    $0x10,%esp
  800f09:	8b 75 08             	mov    0x8(%ebp),%esi
  800f0c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f0f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f12:	50                   	push   %eax
  800f13:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800f19:	c1 e8 0c             	shr    $0xc,%eax
  800f1c:	50                   	push   %eax
  800f1d:	e8 1a ff ff ff       	call   800e3c <fd_lookup>
  800f22:	83 c4 08             	add    $0x8,%esp
  800f25:	85 c0                	test   %eax,%eax
  800f27:	78 05                	js     800f2e <fd_close+0x2d>
	    || fd != fd2)
  800f29:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800f2c:	74 06                	je     800f34 <fd_close+0x33>
		return (must_exist ? r : 0);
  800f2e:	84 db                	test   %bl,%bl
  800f30:	74 47                	je     800f79 <fd_close+0x78>
  800f32:	eb 4a                	jmp    800f7e <fd_close+0x7d>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f34:	83 ec 08             	sub    $0x8,%esp
  800f37:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800f3a:	50                   	push   %eax
  800f3b:	ff 36                	pushl  (%esi)
  800f3d:	e8 51 ff ff ff       	call   800e93 <dev_lookup>
  800f42:	89 c3                	mov    %eax,%ebx
  800f44:	83 c4 10             	add    $0x10,%esp
  800f47:	85 c0                	test   %eax,%eax
  800f49:	78 1c                	js     800f67 <fd_close+0x66>
		if (dev->dev_close)
  800f4b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f4e:	8b 40 10             	mov    0x10(%eax),%eax
  800f51:	85 c0                	test   %eax,%eax
  800f53:	74 0d                	je     800f62 <fd_close+0x61>
			r = (*dev->dev_close)(fd);
  800f55:	83 ec 0c             	sub    $0xc,%esp
  800f58:	56                   	push   %esi
  800f59:	ff d0                	call   *%eax
  800f5b:	89 c3                	mov    %eax,%ebx
  800f5d:	83 c4 10             	add    $0x10,%esp
  800f60:	eb 05                	jmp    800f67 <fd_close+0x66>
		else
			r = 0;
  800f62:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800f67:	83 ec 08             	sub    $0x8,%esp
  800f6a:	56                   	push   %esi
  800f6b:	6a 00                	push   $0x0
  800f6d:	e8 c3 fc ff ff       	call   800c35 <sys_page_unmap>
	return r;
  800f72:	83 c4 10             	add    $0x10,%esp
  800f75:	89 d8                	mov    %ebx,%eax
  800f77:	eb 05                	jmp    800f7e <fd_close+0x7d>
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
  800f79:	b8 00 00 00 00       	mov    $0x0,%eax
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
	return r;
}
  800f7e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f81:	5b                   	pop    %ebx
  800f82:	5e                   	pop    %esi
  800f83:	5d                   	pop    %ebp
  800f84:	c3                   	ret    

00800f85 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800f85:	55                   	push   %ebp
  800f86:	89 e5                	mov    %esp,%ebp
  800f88:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f8b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f8e:	50                   	push   %eax
  800f8f:	ff 75 08             	pushl  0x8(%ebp)
  800f92:	e8 a5 fe ff ff       	call   800e3c <fd_lookup>
  800f97:	83 c4 08             	add    $0x8,%esp
  800f9a:	85 c0                	test   %eax,%eax
  800f9c:	78 10                	js     800fae <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800f9e:	83 ec 08             	sub    $0x8,%esp
  800fa1:	6a 01                	push   $0x1
  800fa3:	ff 75 f4             	pushl  -0xc(%ebp)
  800fa6:	e8 56 ff ff ff       	call   800f01 <fd_close>
  800fab:	83 c4 10             	add    $0x10,%esp
}
  800fae:	c9                   	leave  
  800faf:	c3                   	ret    

00800fb0 <close_all>:

void
close_all(void)
{
  800fb0:	55                   	push   %ebp
  800fb1:	89 e5                	mov    %esp,%ebp
  800fb3:	53                   	push   %ebx
  800fb4:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800fb7:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800fbc:	83 ec 0c             	sub    $0xc,%esp
  800fbf:	53                   	push   %ebx
  800fc0:	e8 c0 ff ff ff       	call   800f85 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800fc5:	43                   	inc    %ebx
  800fc6:	83 c4 10             	add    $0x10,%esp
  800fc9:	83 fb 20             	cmp    $0x20,%ebx
  800fcc:	75 ee                	jne    800fbc <close_all+0xc>
		close(i);
}
  800fce:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fd1:	c9                   	leave  
  800fd2:	c3                   	ret    

00800fd3 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800fd3:	55                   	push   %ebp
  800fd4:	89 e5                	mov    %esp,%ebp
  800fd6:	57                   	push   %edi
  800fd7:	56                   	push   %esi
  800fd8:	53                   	push   %ebx
  800fd9:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800fdc:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800fdf:	50                   	push   %eax
  800fe0:	ff 75 08             	pushl  0x8(%ebp)
  800fe3:	e8 54 fe ff ff       	call   800e3c <fd_lookup>
  800fe8:	83 c4 08             	add    $0x8,%esp
  800feb:	85 c0                	test   %eax,%eax
  800fed:	0f 88 c2 00 00 00    	js     8010b5 <dup+0xe2>
		return r;
	close(newfdnum);
  800ff3:	83 ec 0c             	sub    $0xc,%esp
  800ff6:	ff 75 0c             	pushl  0xc(%ebp)
  800ff9:	e8 87 ff ff ff       	call   800f85 <close>

	newfd = INDEX2FD(newfdnum);
  800ffe:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801001:	c1 e3 0c             	shl    $0xc,%ebx
  801004:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80100a:	83 c4 04             	add    $0x4,%esp
  80100d:	ff 75 e4             	pushl  -0x1c(%ebp)
  801010:	e8 9c fd ff ff       	call   800db1 <fd2data>
  801015:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  801017:	89 1c 24             	mov    %ebx,(%esp)
  80101a:	e8 92 fd ff ff       	call   800db1 <fd2data>
  80101f:	83 c4 10             	add    $0x10,%esp
  801022:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801024:	89 f0                	mov    %esi,%eax
  801026:	c1 e8 16             	shr    $0x16,%eax
  801029:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801030:	a8 01                	test   $0x1,%al
  801032:	74 35                	je     801069 <dup+0x96>
  801034:	89 f0                	mov    %esi,%eax
  801036:	c1 e8 0c             	shr    $0xc,%eax
  801039:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801040:	f6 c2 01             	test   $0x1,%dl
  801043:	74 24                	je     801069 <dup+0x96>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801045:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80104c:	83 ec 0c             	sub    $0xc,%esp
  80104f:	25 07 0e 00 00       	and    $0xe07,%eax
  801054:	50                   	push   %eax
  801055:	57                   	push   %edi
  801056:	6a 00                	push   $0x0
  801058:	56                   	push   %esi
  801059:	6a 00                	push   $0x0
  80105b:	e8 93 fb ff ff       	call   800bf3 <sys_page_map>
  801060:	89 c6                	mov    %eax,%esi
  801062:	83 c4 20             	add    $0x20,%esp
  801065:	85 c0                	test   %eax,%eax
  801067:	78 2c                	js     801095 <dup+0xc2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801069:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80106c:	89 d0                	mov    %edx,%eax
  80106e:	c1 e8 0c             	shr    $0xc,%eax
  801071:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801078:	83 ec 0c             	sub    $0xc,%esp
  80107b:	25 07 0e 00 00       	and    $0xe07,%eax
  801080:	50                   	push   %eax
  801081:	53                   	push   %ebx
  801082:	6a 00                	push   $0x0
  801084:	52                   	push   %edx
  801085:	6a 00                	push   $0x0
  801087:	e8 67 fb ff ff       	call   800bf3 <sys_page_map>
  80108c:	89 c6                	mov    %eax,%esi
  80108e:	83 c4 20             	add    $0x20,%esp
  801091:	85 c0                	test   %eax,%eax
  801093:	79 1d                	jns    8010b2 <dup+0xdf>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801095:	83 ec 08             	sub    $0x8,%esp
  801098:	53                   	push   %ebx
  801099:	6a 00                	push   $0x0
  80109b:	e8 95 fb ff ff       	call   800c35 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8010a0:	83 c4 08             	add    $0x8,%esp
  8010a3:	57                   	push   %edi
  8010a4:	6a 00                	push   $0x0
  8010a6:	e8 8a fb ff ff       	call   800c35 <sys_page_unmap>
	return r;
  8010ab:	83 c4 10             	add    $0x10,%esp
  8010ae:	89 f0                	mov    %esi,%eax
  8010b0:	eb 03                	jmp    8010b5 <dup+0xe2>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  8010b2:	8b 45 0c             	mov    0xc(%ebp),%eax

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8010b5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010b8:	5b                   	pop    %ebx
  8010b9:	5e                   	pop    %esi
  8010ba:	5f                   	pop    %edi
  8010bb:	5d                   	pop    %ebp
  8010bc:	c3                   	ret    

008010bd <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8010bd:	55                   	push   %ebp
  8010be:	89 e5                	mov    %esp,%ebp
  8010c0:	53                   	push   %ebx
  8010c1:	83 ec 14             	sub    $0x14,%esp
  8010c4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010c7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010ca:	50                   	push   %eax
  8010cb:	53                   	push   %ebx
  8010cc:	e8 6b fd ff ff       	call   800e3c <fd_lookup>
  8010d1:	83 c4 08             	add    $0x8,%esp
  8010d4:	85 c0                	test   %eax,%eax
  8010d6:	78 67                	js     80113f <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010d8:	83 ec 08             	sub    $0x8,%esp
  8010db:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010de:	50                   	push   %eax
  8010df:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010e2:	ff 30                	pushl  (%eax)
  8010e4:	e8 aa fd ff ff       	call   800e93 <dev_lookup>
  8010e9:	83 c4 10             	add    $0x10,%esp
  8010ec:	85 c0                	test   %eax,%eax
  8010ee:	78 4f                	js     80113f <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8010f0:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8010f3:	8b 42 08             	mov    0x8(%edx),%eax
  8010f6:	83 e0 03             	and    $0x3,%eax
  8010f9:	83 f8 01             	cmp    $0x1,%eax
  8010fc:	75 21                	jne    80111f <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8010fe:	a1 08 40 80 00       	mov    0x804008,%eax
  801103:	8b 40 48             	mov    0x48(%eax),%eax
  801106:	83 ec 04             	sub    $0x4,%esp
  801109:	53                   	push   %ebx
  80110a:	50                   	push   %eax
  80110b:	68 ed 21 80 00       	push   $0x8021ed
  801110:	e8 46 f0 ff ff       	call   80015b <cprintf>
		return -E_INVAL;
  801115:	83 c4 10             	add    $0x10,%esp
  801118:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80111d:	eb 20                	jmp    80113f <read+0x82>
	}
	if (!dev->dev_read)
  80111f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801122:	8b 40 08             	mov    0x8(%eax),%eax
  801125:	85 c0                	test   %eax,%eax
  801127:	74 11                	je     80113a <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801129:	83 ec 04             	sub    $0x4,%esp
  80112c:	ff 75 10             	pushl  0x10(%ebp)
  80112f:	ff 75 0c             	pushl  0xc(%ebp)
  801132:	52                   	push   %edx
  801133:	ff d0                	call   *%eax
  801135:	83 c4 10             	add    $0x10,%esp
  801138:	eb 05                	jmp    80113f <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80113a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  80113f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801142:	c9                   	leave  
  801143:	c3                   	ret    

00801144 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801144:	55                   	push   %ebp
  801145:	89 e5                	mov    %esp,%ebp
  801147:	57                   	push   %edi
  801148:	56                   	push   %esi
  801149:	53                   	push   %ebx
  80114a:	83 ec 0c             	sub    $0xc,%esp
  80114d:	8b 7d 08             	mov    0x8(%ebp),%edi
  801150:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801153:	85 f6                	test   %esi,%esi
  801155:	74 31                	je     801188 <readn+0x44>
  801157:	b8 00 00 00 00       	mov    $0x0,%eax
  80115c:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  801161:	83 ec 04             	sub    $0x4,%esp
  801164:	89 f2                	mov    %esi,%edx
  801166:	29 c2                	sub    %eax,%edx
  801168:	52                   	push   %edx
  801169:	03 45 0c             	add    0xc(%ebp),%eax
  80116c:	50                   	push   %eax
  80116d:	57                   	push   %edi
  80116e:	e8 4a ff ff ff       	call   8010bd <read>
		if (m < 0)
  801173:	83 c4 10             	add    $0x10,%esp
  801176:	85 c0                	test   %eax,%eax
  801178:	78 17                	js     801191 <readn+0x4d>
			return m;
		if (m == 0)
  80117a:	85 c0                	test   %eax,%eax
  80117c:	74 11                	je     80118f <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80117e:	01 c3                	add    %eax,%ebx
  801180:	89 d8                	mov    %ebx,%eax
  801182:	39 f3                	cmp    %esi,%ebx
  801184:	72 db                	jb     801161 <readn+0x1d>
  801186:	eb 09                	jmp    801191 <readn+0x4d>
  801188:	b8 00 00 00 00       	mov    $0x0,%eax
  80118d:	eb 02                	jmp    801191 <readn+0x4d>
  80118f:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801191:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801194:	5b                   	pop    %ebx
  801195:	5e                   	pop    %esi
  801196:	5f                   	pop    %edi
  801197:	5d                   	pop    %ebp
  801198:	c3                   	ret    

00801199 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801199:	55                   	push   %ebp
  80119a:	89 e5                	mov    %esp,%ebp
  80119c:	53                   	push   %ebx
  80119d:	83 ec 14             	sub    $0x14,%esp
  8011a0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011a3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011a6:	50                   	push   %eax
  8011a7:	53                   	push   %ebx
  8011a8:	e8 8f fc ff ff       	call   800e3c <fd_lookup>
  8011ad:	83 c4 08             	add    $0x8,%esp
  8011b0:	85 c0                	test   %eax,%eax
  8011b2:	78 62                	js     801216 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011b4:	83 ec 08             	sub    $0x8,%esp
  8011b7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011ba:	50                   	push   %eax
  8011bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011be:	ff 30                	pushl  (%eax)
  8011c0:	e8 ce fc ff ff       	call   800e93 <dev_lookup>
  8011c5:	83 c4 10             	add    $0x10,%esp
  8011c8:	85 c0                	test   %eax,%eax
  8011ca:	78 4a                	js     801216 <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011cf:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011d3:	75 21                	jne    8011f6 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8011d5:	a1 08 40 80 00       	mov    0x804008,%eax
  8011da:	8b 40 48             	mov    0x48(%eax),%eax
  8011dd:	83 ec 04             	sub    $0x4,%esp
  8011e0:	53                   	push   %ebx
  8011e1:	50                   	push   %eax
  8011e2:	68 09 22 80 00       	push   $0x802209
  8011e7:	e8 6f ef ff ff       	call   80015b <cprintf>
		return -E_INVAL;
  8011ec:	83 c4 10             	add    $0x10,%esp
  8011ef:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011f4:	eb 20                	jmp    801216 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8011f6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011f9:	8b 52 0c             	mov    0xc(%edx),%edx
  8011fc:	85 d2                	test   %edx,%edx
  8011fe:	74 11                	je     801211 <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801200:	83 ec 04             	sub    $0x4,%esp
  801203:	ff 75 10             	pushl  0x10(%ebp)
  801206:	ff 75 0c             	pushl  0xc(%ebp)
  801209:	50                   	push   %eax
  80120a:	ff d2                	call   *%edx
  80120c:	83 c4 10             	add    $0x10,%esp
  80120f:	eb 05                	jmp    801216 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801211:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801216:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801219:	c9                   	leave  
  80121a:	c3                   	ret    

0080121b <seek>:

int
seek(int fdnum, off_t offset)
{
  80121b:	55                   	push   %ebp
  80121c:	89 e5                	mov    %esp,%ebp
  80121e:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801221:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801224:	50                   	push   %eax
  801225:	ff 75 08             	pushl  0x8(%ebp)
  801228:	e8 0f fc ff ff       	call   800e3c <fd_lookup>
  80122d:	83 c4 08             	add    $0x8,%esp
  801230:	85 c0                	test   %eax,%eax
  801232:	78 0e                	js     801242 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801234:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801237:	8b 55 0c             	mov    0xc(%ebp),%edx
  80123a:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80123d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801242:	c9                   	leave  
  801243:	c3                   	ret    

00801244 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801244:	55                   	push   %ebp
  801245:	89 e5                	mov    %esp,%ebp
  801247:	53                   	push   %ebx
  801248:	83 ec 14             	sub    $0x14,%esp
  80124b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80124e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801251:	50                   	push   %eax
  801252:	53                   	push   %ebx
  801253:	e8 e4 fb ff ff       	call   800e3c <fd_lookup>
  801258:	83 c4 08             	add    $0x8,%esp
  80125b:	85 c0                	test   %eax,%eax
  80125d:	78 5f                	js     8012be <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80125f:	83 ec 08             	sub    $0x8,%esp
  801262:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801265:	50                   	push   %eax
  801266:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801269:	ff 30                	pushl  (%eax)
  80126b:	e8 23 fc ff ff       	call   800e93 <dev_lookup>
  801270:	83 c4 10             	add    $0x10,%esp
  801273:	85 c0                	test   %eax,%eax
  801275:	78 47                	js     8012be <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801277:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80127a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80127e:	75 21                	jne    8012a1 <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801280:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801285:	8b 40 48             	mov    0x48(%eax),%eax
  801288:	83 ec 04             	sub    $0x4,%esp
  80128b:	53                   	push   %ebx
  80128c:	50                   	push   %eax
  80128d:	68 cc 21 80 00       	push   $0x8021cc
  801292:	e8 c4 ee ff ff       	call   80015b <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801297:	83 c4 10             	add    $0x10,%esp
  80129a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80129f:	eb 1d                	jmp    8012be <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  8012a1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012a4:	8b 52 18             	mov    0x18(%edx),%edx
  8012a7:	85 d2                	test   %edx,%edx
  8012a9:	74 0e                	je     8012b9 <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8012ab:	83 ec 08             	sub    $0x8,%esp
  8012ae:	ff 75 0c             	pushl  0xc(%ebp)
  8012b1:	50                   	push   %eax
  8012b2:	ff d2                	call   *%edx
  8012b4:	83 c4 10             	add    $0x10,%esp
  8012b7:	eb 05                	jmp    8012be <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8012b9:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8012be:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012c1:	c9                   	leave  
  8012c2:	c3                   	ret    

008012c3 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8012c3:	55                   	push   %ebp
  8012c4:	89 e5                	mov    %esp,%ebp
  8012c6:	53                   	push   %ebx
  8012c7:	83 ec 14             	sub    $0x14,%esp
  8012ca:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012cd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012d0:	50                   	push   %eax
  8012d1:	ff 75 08             	pushl  0x8(%ebp)
  8012d4:	e8 63 fb ff ff       	call   800e3c <fd_lookup>
  8012d9:	83 c4 08             	add    $0x8,%esp
  8012dc:	85 c0                	test   %eax,%eax
  8012de:	78 52                	js     801332 <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012e0:	83 ec 08             	sub    $0x8,%esp
  8012e3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012e6:	50                   	push   %eax
  8012e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012ea:	ff 30                	pushl  (%eax)
  8012ec:	e8 a2 fb ff ff       	call   800e93 <dev_lookup>
  8012f1:	83 c4 10             	add    $0x10,%esp
  8012f4:	85 c0                	test   %eax,%eax
  8012f6:	78 3a                	js     801332 <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  8012f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012fb:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8012ff:	74 2c                	je     80132d <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801301:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801304:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80130b:	00 00 00 
	stat->st_isdir = 0;
  80130e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801315:	00 00 00 
	stat->st_dev = dev;
  801318:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80131e:	83 ec 08             	sub    $0x8,%esp
  801321:	53                   	push   %ebx
  801322:	ff 75 f0             	pushl  -0x10(%ebp)
  801325:	ff 50 14             	call   *0x14(%eax)
  801328:	83 c4 10             	add    $0x10,%esp
  80132b:	eb 05                	jmp    801332 <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80132d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801332:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801335:	c9                   	leave  
  801336:	c3                   	ret    

00801337 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801337:	55                   	push   %ebp
  801338:	89 e5                	mov    %esp,%ebp
  80133a:	56                   	push   %esi
  80133b:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80133c:	83 ec 08             	sub    $0x8,%esp
  80133f:	6a 00                	push   $0x0
  801341:	ff 75 08             	pushl  0x8(%ebp)
  801344:	e8 75 01 00 00       	call   8014be <open>
  801349:	89 c3                	mov    %eax,%ebx
  80134b:	83 c4 10             	add    $0x10,%esp
  80134e:	85 c0                	test   %eax,%eax
  801350:	78 1d                	js     80136f <stat+0x38>
		return fd;
	r = fstat(fd, stat);
  801352:	83 ec 08             	sub    $0x8,%esp
  801355:	ff 75 0c             	pushl  0xc(%ebp)
  801358:	50                   	push   %eax
  801359:	e8 65 ff ff ff       	call   8012c3 <fstat>
  80135e:	89 c6                	mov    %eax,%esi
	close(fd);
  801360:	89 1c 24             	mov    %ebx,(%esp)
  801363:	e8 1d fc ff ff       	call   800f85 <close>
	return r;
  801368:	83 c4 10             	add    $0x10,%esp
  80136b:	89 f0                	mov    %esi,%eax
  80136d:	eb 00                	jmp    80136f <stat+0x38>
}
  80136f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801372:	5b                   	pop    %ebx
  801373:	5e                   	pop    %esi
  801374:	5d                   	pop    %ebp
  801375:	c3                   	ret    

00801376 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801376:	55                   	push   %ebp
  801377:	89 e5                	mov    %esp,%ebp
  801379:	56                   	push   %esi
  80137a:	53                   	push   %ebx
  80137b:	89 c6                	mov    %eax,%esi
  80137d:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80137f:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801386:	75 12                	jne    80139a <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801388:	83 ec 0c             	sub    $0xc,%esp
  80138b:	6a 01                	push   $0x1
  80138d:	e8 c1 07 00 00       	call   801b53 <ipc_find_env>
  801392:	a3 00 40 80 00       	mov    %eax,0x804000
  801397:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80139a:	6a 07                	push   $0x7
  80139c:	68 00 50 80 00       	push   $0x805000
  8013a1:	56                   	push   %esi
  8013a2:	ff 35 00 40 80 00    	pushl  0x804000
  8013a8:	e8 47 07 00 00       	call   801af4 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8013ad:	83 c4 0c             	add    $0xc,%esp
  8013b0:	6a 00                	push   $0x0
  8013b2:	53                   	push   %ebx
  8013b3:	6a 00                	push   $0x0
  8013b5:	e8 c5 06 00 00       	call   801a7f <ipc_recv>
}
  8013ba:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013bd:	5b                   	pop    %ebx
  8013be:	5e                   	pop    %esi
  8013bf:	5d                   	pop    %ebp
  8013c0:	c3                   	ret    

008013c1 <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8013c1:	55                   	push   %ebp
  8013c2:	89 e5                	mov    %esp,%ebp
  8013c4:	53                   	push   %ebx
  8013c5:	83 ec 04             	sub    $0x4,%esp
  8013c8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8013cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8013ce:	8b 40 0c             	mov    0xc(%eax),%eax
  8013d1:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8013d6:	ba 00 00 00 00       	mov    $0x0,%edx
  8013db:	b8 05 00 00 00       	mov    $0x5,%eax
  8013e0:	e8 91 ff ff ff       	call   801376 <fsipc>
  8013e5:	85 c0                	test   %eax,%eax
  8013e7:	78 2c                	js     801415 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8013e9:	83 ec 08             	sub    $0x8,%esp
  8013ec:	68 00 50 80 00       	push   $0x805000
  8013f1:	53                   	push   %ebx
  8013f2:	e8 49 f3 ff ff       	call   800740 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8013f7:	a1 80 50 80 00       	mov    0x805080,%eax
  8013fc:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801402:	a1 84 50 80 00       	mov    0x805084,%eax
  801407:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80140d:	83 c4 10             	add    $0x10,%esp
  801410:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801415:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801418:	c9                   	leave  
  801419:	c3                   	ret    

0080141a <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80141a:	55                   	push   %ebp
  80141b:	89 e5                	mov    %esp,%ebp
  80141d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801420:	8b 45 08             	mov    0x8(%ebp),%eax
  801423:	8b 40 0c             	mov    0xc(%eax),%eax
  801426:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80142b:	ba 00 00 00 00       	mov    $0x0,%edx
  801430:	b8 06 00 00 00       	mov    $0x6,%eax
  801435:	e8 3c ff ff ff       	call   801376 <fsipc>
}
  80143a:	c9                   	leave  
  80143b:	c3                   	ret    

0080143c <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80143c:	55                   	push   %ebp
  80143d:	89 e5                	mov    %esp,%ebp
  80143f:	56                   	push   %esi
  801440:	53                   	push   %ebx
  801441:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801444:	8b 45 08             	mov    0x8(%ebp),%eax
  801447:	8b 40 0c             	mov    0xc(%eax),%eax
  80144a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80144f:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801455:	ba 00 00 00 00       	mov    $0x0,%edx
  80145a:	b8 03 00 00 00       	mov    $0x3,%eax
  80145f:	e8 12 ff ff ff       	call   801376 <fsipc>
  801464:	89 c3                	mov    %eax,%ebx
  801466:	85 c0                	test   %eax,%eax
  801468:	78 4b                	js     8014b5 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80146a:	39 c6                	cmp    %eax,%esi
  80146c:	73 16                	jae    801484 <devfile_read+0x48>
  80146e:	68 26 22 80 00       	push   $0x802226
  801473:	68 2d 22 80 00       	push   $0x80222d
  801478:	6a 7a                	push   $0x7a
  80147a:	68 42 22 80 00       	push   $0x802242
  80147f:	e8 b5 05 00 00       	call   801a39 <_panic>
	assert(r <= PGSIZE);
  801484:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801489:	7e 16                	jle    8014a1 <devfile_read+0x65>
  80148b:	68 4d 22 80 00       	push   $0x80224d
  801490:	68 2d 22 80 00       	push   $0x80222d
  801495:	6a 7b                	push   $0x7b
  801497:	68 42 22 80 00       	push   $0x802242
  80149c:	e8 98 05 00 00       	call   801a39 <_panic>
	memmove(buf, &fsipcbuf, r);
  8014a1:	83 ec 04             	sub    $0x4,%esp
  8014a4:	50                   	push   %eax
  8014a5:	68 00 50 80 00       	push   $0x805000
  8014aa:	ff 75 0c             	pushl  0xc(%ebp)
  8014ad:	e8 5b f4 ff ff       	call   80090d <memmove>
	return r;
  8014b2:	83 c4 10             	add    $0x10,%esp
}
  8014b5:	89 d8                	mov    %ebx,%eax
  8014b7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014ba:	5b                   	pop    %ebx
  8014bb:	5e                   	pop    %esi
  8014bc:	5d                   	pop    %ebp
  8014bd:	c3                   	ret    

008014be <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8014be:	55                   	push   %ebp
  8014bf:	89 e5                	mov    %esp,%ebp
  8014c1:	53                   	push   %ebx
  8014c2:	83 ec 20             	sub    $0x20,%esp
  8014c5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8014c8:	53                   	push   %ebx
  8014c9:	e8 1b f2 ff ff       	call   8006e9 <strlen>
  8014ce:	83 c4 10             	add    $0x10,%esp
  8014d1:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8014d6:	7f 63                	jg     80153b <open+0x7d>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8014d8:	83 ec 0c             	sub    $0xc,%esp
  8014db:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014de:	50                   	push   %eax
  8014df:	e8 e4 f8 ff ff       	call   800dc8 <fd_alloc>
  8014e4:	83 c4 10             	add    $0x10,%esp
  8014e7:	85 c0                	test   %eax,%eax
  8014e9:	78 55                	js     801540 <open+0x82>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8014eb:	83 ec 08             	sub    $0x8,%esp
  8014ee:	53                   	push   %ebx
  8014ef:	68 00 50 80 00       	push   $0x805000
  8014f4:	e8 47 f2 ff ff       	call   800740 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8014f9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014fc:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801501:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801504:	b8 01 00 00 00       	mov    $0x1,%eax
  801509:	e8 68 fe ff ff       	call   801376 <fsipc>
  80150e:	89 c3                	mov    %eax,%ebx
  801510:	83 c4 10             	add    $0x10,%esp
  801513:	85 c0                	test   %eax,%eax
  801515:	79 14                	jns    80152b <open+0x6d>
		fd_close(fd, 0);
  801517:	83 ec 08             	sub    $0x8,%esp
  80151a:	6a 00                	push   $0x0
  80151c:	ff 75 f4             	pushl  -0xc(%ebp)
  80151f:	e8 dd f9 ff ff       	call   800f01 <fd_close>
		return r;
  801524:	83 c4 10             	add    $0x10,%esp
  801527:	89 d8                	mov    %ebx,%eax
  801529:	eb 15                	jmp    801540 <open+0x82>
	}

	return fd2num(fd);
  80152b:	83 ec 0c             	sub    $0xc,%esp
  80152e:	ff 75 f4             	pushl  -0xc(%ebp)
  801531:	e8 6b f8 ff ff       	call   800da1 <fd2num>
  801536:	83 c4 10             	add    $0x10,%esp
  801539:	eb 05                	jmp    801540 <open+0x82>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80153b:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801540:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801543:	c9                   	leave  
  801544:	c3                   	ret    

00801545 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801545:	55                   	push   %ebp
  801546:	89 e5                	mov    %esp,%ebp
  801548:	56                   	push   %esi
  801549:	53                   	push   %ebx
  80154a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80154d:	83 ec 0c             	sub    $0xc,%esp
  801550:	ff 75 08             	pushl  0x8(%ebp)
  801553:	e8 59 f8 ff ff       	call   800db1 <fd2data>
  801558:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80155a:	83 c4 08             	add    $0x8,%esp
  80155d:	68 59 22 80 00       	push   $0x802259
  801562:	53                   	push   %ebx
  801563:	e8 d8 f1 ff ff       	call   800740 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801568:	8b 46 04             	mov    0x4(%esi),%eax
  80156b:	2b 06                	sub    (%esi),%eax
  80156d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801573:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80157a:	00 00 00 
	stat->st_dev = &devpipe;
  80157d:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801584:	30 80 00 
	return 0;
}
  801587:	b8 00 00 00 00       	mov    $0x0,%eax
  80158c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80158f:	5b                   	pop    %ebx
  801590:	5e                   	pop    %esi
  801591:	5d                   	pop    %ebp
  801592:	c3                   	ret    

00801593 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801593:	55                   	push   %ebp
  801594:	89 e5                	mov    %esp,%ebp
  801596:	53                   	push   %ebx
  801597:	83 ec 0c             	sub    $0xc,%esp
  80159a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80159d:	53                   	push   %ebx
  80159e:	6a 00                	push   $0x0
  8015a0:	e8 90 f6 ff ff       	call   800c35 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8015a5:	89 1c 24             	mov    %ebx,(%esp)
  8015a8:	e8 04 f8 ff ff       	call   800db1 <fd2data>
  8015ad:	83 c4 08             	add    $0x8,%esp
  8015b0:	50                   	push   %eax
  8015b1:	6a 00                	push   $0x0
  8015b3:	e8 7d f6 ff ff       	call   800c35 <sys_page_unmap>
}
  8015b8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015bb:	c9                   	leave  
  8015bc:	c3                   	ret    

008015bd <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8015bd:	55                   	push   %ebp
  8015be:	89 e5                	mov    %esp,%ebp
  8015c0:	57                   	push   %edi
  8015c1:	56                   	push   %esi
  8015c2:	53                   	push   %ebx
  8015c3:	83 ec 1c             	sub    $0x1c,%esp
  8015c6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8015c9:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8015cb:	a1 08 40 80 00       	mov    0x804008,%eax
  8015d0:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8015d3:	83 ec 0c             	sub    $0xc,%esp
  8015d6:	ff 75 e0             	pushl  -0x20(%ebp)
  8015d9:	e8 d0 05 00 00       	call   801bae <pageref>
  8015de:	89 c3                	mov    %eax,%ebx
  8015e0:	89 3c 24             	mov    %edi,(%esp)
  8015e3:	e8 c6 05 00 00       	call   801bae <pageref>
  8015e8:	83 c4 10             	add    $0x10,%esp
  8015eb:	39 c3                	cmp    %eax,%ebx
  8015ed:	0f 94 c1             	sete   %cl
  8015f0:	0f b6 c9             	movzbl %cl,%ecx
  8015f3:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8015f6:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8015fc:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8015ff:	39 ce                	cmp    %ecx,%esi
  801601:	74 1b                	je     80161e <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801603:	39 c3                	cmp    %eax,%ebx
  801605:	75 c4                	jne    8015cb <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801607:	8b 42 58             	mov    0x58(%edx),%eax
  80160a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80160d:	50                   	push   %eax
  80160e:	56                   	push   %esi
  80160f:	68 60 22 80 00       	push   $0x802260
  801614:	e8 42 eb ff ff       	call   80015b <cprintf>
  801619:	83 c4 10             	add    $0x10,%esp
  80161c:	eb ad                	jmp    8015cb <_pipeisclosed+0xe>
	}
}
  80161e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801621:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801624:	5b                   	pop    %ebx
  801625:	5e                   	pop    %esi
  801626:	5f                   	pop    %edi
  801627:	5d                   	pop    %ebp
  801628:	c3                   	ret    

00801629 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801629:	55                   	push   %ebp
  80162a:	89 e5                	mov    %esp,%ebp
  80162c:	57                   	push   %edi
  80162d:	56                   	push   %esi
  80162e:	53                   	push   %ebx
  80162f:	83 ec 18             	sub    $0x18,%esp
  801632:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801635:	56                   	push   %esi
  801636:	e8 76 f7 ff ff       	call   800db1 <fd2data>
  80163b:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80163d:	83 c4 10             	add    $0x10,%esp
  801640:	bf 00 00 00 00       	mov    $0x0,%edi
  801645:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801649:	75 42                	jne    80168d <devpipe_write+0x64>
  80164b:	eb 4e                	jmp    80169b <devpipe_write+0x72>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80164d:	89 da                	mov    %ebx,%edx
  80164f:	89 f0                	mov    %esi,%eax
  801651:	e8 67 ff ff ff       	call   8015bd <_pipeisclosed>
  801656:	85 c0                	test   %eax,%eax
  801658:	75 46                	jne    8016a0 <devpipe_write+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80165a:	e8 32 f5 ff ff       	call   800b91 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80165f:	8b 53 04             	mov    0x4(%ebx),%edx
  801662:	8b 03                	mov    (%ebx),%eax
  801664:	83 c0 20             	add    $0x20,%eax
  801667:	39 c2                	cmp    %eax,%edx
  801669:	73 e2                	jae    80164d <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80166b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80166e:	8a 0c 38             	mov    (%eax,%edi,1),%cl
  801671:	89 d0                	mov    %edx,%eax
  801673:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801678:	79 05                	jns    80167f <devpipe_write+0x56>
  80167a:	48                   	dec    %eax
  80167b:	83 c8 e0             	or     $0xffffffe0,%eax
  80167e:	40                   	inc    %eax
  80167f:	88 4c 03 08          	mov    %cl,0x8(%ebx,%eax,1)
		p->p_wpos++;
  801683:	42                   	inc    %edx
  801684:	89 53 04             	mov    %edx,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801687:	47                   	inc    %edi
  801688:	39 7d 10             	cmp    %edi,0x10(%ebp)
  80168b:	74 0e                	je     80169b <devpipe_write+0x72>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80168d:	8b 53 04             	mov    0x4(%ebx),%edx
  801690:	8b 03                	mov    (%ebx),%eax
  801692:	83 c0 20             	add    $0x20,%eax
  801695:	39 c2                	cmp    %eax,%edx
  801697:	73 b4                	jae    80164d <devpipe_write+0x24>
  801699:	eb d0                	jmp    80166b <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80169b:	8b 45 10             	mov    0x10(%ebp),%eax
  80169e:	eb 05                	jmp    8016a5 <devpipe_write+0x7c>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8016a0:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8016a5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016a8:	5b                   	pop    %ebx
  8016a9:	5e                   	pop    %esi
  8016aa:	5f                   	pop    %edi
  8016ab:	5d                   	pop    %ebp
  8016ac:	c3                   	ret    

008016ad <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8016ad:	55                   	push   %ebp
  8016ae:	89 e5                	mov    %esp,%ebp
  8016b0:	57                   	push   %edi
  8016b1:	56                   	push   %esi
  8016b2:	53                   	push   %ebx
  8016b3:	83 ec 18             	sub    $0x18,%esp
  8016b6:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8016b9:	57                   	push   %edi
  8016ba:	e8 f2 f6 ff ff       	call   800db1 <fd2data>
  8016bf:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8016c1:	83 c4 10             	add    $0x10,%esp
  8016c4:	be 00 00 00 00       	mov    $0x0,%esi
  8016c9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8016cd:	75 3d                	jne    80170c <devpipe_read+0x5f>
  8016cf:	eb 48                	jmp    801719 <devpipe_read+0x6c>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  8016d1:	89 f0                	mov    %esi,%eax
  8016d3:	eb 4e                	jmp    801723 <devpipe_read+0x76>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8016d5:	89 da                	mov    %ebx,%edx
  8016d7:	89 f8                	mov    %edi,%eax
  8016d9:	e8 df fe ff ff       	call   8015bd <_pipeisclosed>
  8016de:	85 c0                	test   %eax,%eax
  8016e0:	75 3c                	jne    80171e <devpipe_read+0x71>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8016e2:	e8 aa f4 ff ff       	call   800b91 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8016e7:	8b 03                	mov    (%ebx),%eax
  8016e9:	3b 43 04             	cmp    0x4(%ebx),%eax
  8016ec:	74 e7                	je     8016d5 <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8016ee:	25 1f 00 00 80       	and    $0x8000001f,%eax
  8016f3:	79 05                	jns    8016fa <devpipe_read+0x4d>
  8016f5:	48                   	dec    %eax
  8016f6:	83 c8 e0             	or     $0xffffffe0,%eax
  8016f9:	40                   	inc    %eax
  8016fa:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  8016fe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801701:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801704:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801706:	46                   	inc    %esi
  801707:	39 75 10             	cmp    %esi,0x10(%ebp)
  80170a:	74 0d                	je     801719 <devpipe_read+0x6c>
		while (p->p_rpos == p->p_wpos) {
  80170c:	8b 03                	mov    (%ebx),%eax
  80170e:	3b 43 04             	cmp    0x4(%ebx),%eax
  801711:	75 db                	jne    8016ee <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801713:	85 f6                	test   %esi,%esi
  801715:	75 ba                	jne    8016d1 <devpipe_read+0x24>
  801717:	eb bc                	jmp    8016d5 <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801719:	8b 45 10             	mov    0x10(%ebp),%eax
  80171c:	eb 05                	jmp    801723 <devpipe_read+0x76>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80171e:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801723:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801726:	5b                   	pop    %ebx
  801727:	5e                   	pop    %esi
  801728:	5f                   	pop    %edi
  801729:	5d                   	pop    %ebp
  80172a:	c3                   	ret    

0080172b <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80172b:	55                   	push   %ebp
  80172c:	89 e5                	mov    %esp,%ebp
  80172e:	56                   	push   %esi
  80172f:	53                   	push   %ebx
  801730:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801733:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801736:	50                   	push   %eax
  801737:	e8 8c f6 ff ff       	call   800dc8 <fd_alloc>
  80173c:	83 c4 10             	add    $0x10,%esp
  80173f:	85 c0                	test   %eax,%eax
  801741:	0f 88 2a 01 00 00    	js     801871 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801747:	83 ec 04             	sub    $0x4,%esp
  80174a:	68 07 04 00 00       	push   $0x407
  80174f:	ff 75 f4             	pushl  -0xc(%ebp)
  801752:	6a 00                	push   $0x0
  801754:	e8 57 f4 ff ff       	call   800bb0 <sys_page_alloc>
  801759:	83 c4 10             	add    $0x10,%esp
  80175c:	85 c0                	test   %eax,%eax
  80175e:	0f 88 0d 01 00 00    	js     801871 <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801764:	83 ec 0c             	sub    $0xc,%esp
  801767:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80176a:	50                   	push   %eax
  80176b:	e8 58 f6 ff ff       	call   800dc8 <fd_alloc>
  801770:	89 c3                	mov    %eax,%ebx
  801772:	83 c4 10             	add    $0x10,%esp
  801775:	85 c0                	test   %eax,%eax
  801777:	0f 88 e2 00 00 00    	js     80185f <pipe+0x134>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80177d:	83 ec 04             	sub    $0x4,%esp
  801780:	68 07 04 00 00       	push   $0x407
  801785:	ff 75 f0             	pushl  -0x10(%ebp)
  801788:	6a 00                	push   $0x0
  80178a:	e8 21 f4 ff ff       	call   800bb0 <sys_page_alloc>
  80178f:	89 c3                	mov    %eax,%ebx
  801791:	83 c4 10             	add    $0x10,%esp
  801794:	85 c0                	test   %eax,%eax
  801796:	0f 88 c3 00 00 00    	js     80185f <pipe+0x134>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80179c:	83 ec 0c             	sub    $0xc,%esp
  80179f:	ff 75 f4             	pushl  -0xc(%ebp)
  8017a2:	e8 0a f6 ff ff       	call   800db1 <fd2data>
  8017a7:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017a9:	83 c4 0c             	add    $0xc,%esp
  8017ac:	68 07 04 00 00       	push   $0x407
  8017b1:	50                   	push   %eax
  8017b2:	6a 00                	push   $0x0
  8017b4:	e8 f7 f3 ff ff       	call   800bb0 <sys_page_alloc>
  8017b9:	89 c3                	mov    %eax,%ebx
  8017bb:	83 c4 10             	add    $0x10,%esp
  8017be:	85 c0                	test   %eax,%eax
  8017c0:	0f 88 89 00 00 00    	js     80184f <pipe+0x124>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017c6:	83 ec 0c             	sub    $0xc,%esp
  8017c9:	ff 75 f0             	pushl  -0x10(%ebp)
  8017cc:	e8 e0 f5 ff ff       	call   800db1 <fd2data>
  8017d1:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8017d8:	50                   	push   %eax
  8017d9:	6a 00                	push   $0x0
  8017db:	56                   	push   %esi
  8017dc:	6a 00                	push   $0x0
  8017de:	e8 10 f4 ff ff       	call   800bf3 <sys_page_map>
  8017e3:	89 c3                	mov    %eax,%ebx
  8017e5:	83 c4 20             	add    $0x20,%esp
  8017e8:	85 c0                	test   %eax,%eax
  8017ea:	78 55                	js     801841 <pipe+0x116>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8017ec:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8017f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017f5:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8017f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017fa:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801801:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801807:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80180a:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80180c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80180f:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801816:	83 ec 0c             	sub    $0xc,%esp
  801819:	ff 75 f4             	pushl  -0xc(%ebp)
  80181c:	e8 80 f5 ff ff       	call   800da1 <fd2num>
  801821:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801824:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801826:	83 c4 04             	add    $0x4,%esp
  801829:	ff 75 f0             	pushl  -0x10(%ebp)
  80182c:	e8 70 f5 ff ff       	call   800da1 <fd2num>
  801831:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801834:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801837:	83 c4 10             	add    $0x10,%esp
  80183a:	b8 00 00 00 00       	mov    $0x0,%eax
  80183f:	eb 30                	jmp    801871 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  801841:	83 ec 08             	sub    $0x8,%esp
  801844:	56                   	push   %esi
  801845:	6a 00                	push   $0x0
  801847:	e8 e9 f3 ff ff       	call   800c35 <sys_page_unmap>
  80184c:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80184f:	83 ec 08             	sub    $0x8,%esp
  801852:	ff 75 f0             	pushl  -0x10(%ebp)
  801855:	6a 00                	push   $0x0
  801857:	e8 d9 f3 ff ff       	call   800c35 <sys_page_unmap>
  80185c:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80185f:	83 ec 08             	sub    $0x8,%esp
  801862:	ff 75 f4             	pushl  -0xc(%ebp)
  801865:	6a 00                	push   $0x0
  801867:	e8 c9 f3 ff ff       	call   800c35 <sys_page_unmap>
  80186c:	83 c4 10             	add    $0x10,%esp
  80186f:	89 d8                	mov    %ebx,%eax
    err:
	return r;
}
  801871:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801874:	5b                   	pop    %ebx
  801875:	5e                   	pop    %esi
  801876:	5d                   	pop    %ebp
  801877:	c3                   	ret    

00801878 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801878:	55                   	push   %ebp
  801879:	89 e5                	mov    %esp,%ebp
  80187b:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80187e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801881:	50                   	push   %eax
  801882:	ff 75 08             	pushl  0x8(%ebp)
  801885:	e8 b2 f5 ff ff       	call   800e3c <fd_lookup>
  80188a:	83 c4 10             	add    $0x10,%esp
  80188d:	85 c0                	test   %eax,%eax
  80188f:	78 18                	js     8018a9 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801891:	83 ec 0c             	sub    $0xc,%esp
  801894:	ff 75 f4             	pushl  -0xc(%ebp)
  801897:	e8 15 f5 ff ff       	call   800db1 <fd2data>
	return _pipeisclosed(fd, p);
  80189c:	89 c2                	mov    %eax,%edx
  80189e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018a1:	e8 17 fd ff ff       	call   8015bd <_pipeisclosed>
  8018a6:	83 c4 10             	add    $0x10,%esp
}
  8018a9:	c9                   	leave  
  8018aa:	c3                   	ret    

008018ab <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8018ab:	55                   	push   %ebp
  8018ac:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8018ae:	b8 00 00 00 00       	mov    $0x0,%eax
  8018b3:	5d                   	pop    %ebp
  8018b4:	c3                   	ret    

008018b5 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8018b5:	55                   	push   %ebp
  8018b6:	89 e5                	mov    %esp,%ebp
  8018b8:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8018bb:	68 78 22 80 00       	push   $0x802278
  8018c0:	ff 75 0c             	pushl  0xc(%ebp)
  8018c3:	e8 78 ee ff ff       	call   800740 <strcpy>
	return 0;
}
  8018c8:	b8 00 00 00 00       	mov    $0x0,%eax
  8018cd:	c9                   	leave  
  8018ce:	c3                   	ret    

008018cf <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8018cf:	55                   	push   %ebp
  8018d0:	89 e5                	mov    %esp,%ebp
  8018d2:	57                   	push   %edi
  8018d3:	56                   	push   %esi
  8018d4:	53                   	push   %ebx
  8018d5:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8018db:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8018df:	74 45                	je     801926 <devcons_write+0x57>
  8018e1:	b8 00 00 00 00       	mov    $0x0,%eax
  8018e6:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8018eb:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8018f1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8018f4:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  8018f6:	83 fb 7f             	cmp    $0x7f,%ebx
  8018f9:	76 05                	jbe    801900 <devcons_write+0x31>
			m = sizeof(buf) - 1;
  8018fb:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801900:	83 ec 04             	sub    $0x4,%esp
  801903:	53                   	push   %ebx
  801904:	03 45 0c             	add    0xc(%ebp),%eax
  801907:	50                   	push   %eax
  801908:	57                   	push   %edi
  801909:	e8 ff ef ff ff       	call   80090d <memmove>
		sys_cputs(buf, m);
  80190e:	83 c4 08             	add    $0x8,%esp
  801911:	53                   	push   %ebx
  801912:	57                   	push   %edi
  801913:	e8 dc f1 ff ff       	call   800af4 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801918:	01 de                	add    %ebx,%esi
  80191a:	89 f0                	mov    %esi,%eax
  80191c:	83 c4 10             	add    $0x10,%esp
  80191f:	3b 75 10             	cmp    0x10(%ebp),%esi
  801922:	72 cd                	jb     8018f1 <devcons_write+0x22>
  801924:	eb 05                	jmp    80192b <devcons_write+0x5c>
  801926:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80192b:	89 f0                	mov    %esi,%eax
  80192d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801930:	5b                   	pop    %ebx
  801931:	5e                   	pop    %esi
  801932:	5f                   	pop    %edi
  801933:	5d                   	pop    %ebp
  801934:	c3                   	ret    

00801935 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801935:	55                   	push   %ebp
  801936:	89 e5                	mov    %esp,%ebp
  801938:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  80193b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80193f:	75 07                	jne    801948 <devcons_read+0x13>
  801941:	eb 23                	jmp    801966 <devcons_read+0x31>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801943:	e8 49 f2 ff ff       	call   800b91 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801948:	e8 c5 f1 ff ff       	call   800b12 <sys_cgetc>
  80194d:	85 c0                	test   %eax,%eax
  80194f:	74 f2                	je     801943 <devcons_read+0xe>
		sys_yield();
	if (c < 0)
  801951:	85 c0                	test   %eax,%eax
  801953:	78 1d                	js     801972 <devcons_read+0x3d>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801955:	83 f8 04             	cmp    $0x4,%eax
  801958:	74 13                	je     80196d <devcons_read+0x38>
		return 0;
	*(char*)vbuf = c;
  80195a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80195d:	88 02                	mov    %al,(%edx)
	return 1;
  80195f:	b8 01 00 00 00       	mov    $0x1,%eax
  801964:	eb 0c                	jmp    801972 <devcons_read+0x3d>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801966:	b8 00 00 00 00       	mov    $0x0,%eax
  80196b:	eb 05                	jmp    801972 <devcons_read+0x3d>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80196d:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801972:	c9                   	leave  
  801973:	c3                   	ret    

00801974 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801974:	55                   	push   %ebp
  801975:	89 e5                	mov    %esp,%ebp
  801977:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80197a:	8b 45 08             	mov    0x8(%ebp),%eax
  80197d:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801980:	6a 01                	push   $0x1
  801982:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801985:	50                   	push   %eax
  801986:	e8 69 f1 ff ff       	call   800af4 <sys_cputs>
}
  80198b:	83 c4 10             	add    $0x10,%esp
  80198e:	c9                   	leave  
  80198f:	c3                   	ret    

00801990 <getchar>:

int
getchar(void)
{
  801990:	55                   	push   %ebp
  801991:	89 e5                	mov    %esp,%ebp
  801993:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801996:	6a 01                	push   $0x1
  801998:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80199b:	50                   	push   %eax
  80199c:	6a 00                	push   $0x0
  80199e:	e8 1a f7 ff ff       	call   8010bd <read>
	if (r < 0)
  8019a3:	83 c4 10             	add    $0x10,%esp
  8019a6:	85 c0                	test   %eax,%eax
  8019a8:	78 0f                	js     8019b9 <getchar+0x29>
		return r;
	if (r < 1)
  8019aa:	85 c0                	test   %eax,%eax
  8019ac:	7e 06                	jle    8019b4 <getchar+0x24>
		return -E_EOF;
	return c;
  8019ae:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8019b2:	eb 05                	jmp    8019b9 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8019b4:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8019b9:	c9                   	leave  
  8019ba:	c3                   	ret    

008019bb <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8019bb:	55                   	push   %ebp
  8019bc:	89 e5                	mov    %esp,%ebp
  8019be:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8019c1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019c4:	50                   	push   %eax
  8019c5:	ff 75 08             	pushl  0x8(%ebp)
  8019c8:	e8 6f f4 ff ff       	call   800e3c <fd_lookup>
  8019cd:	83 c4 10             	add    $0x10,%esp
  8019d0:	85 c0                	test   %eax,%eax
  8019d2:	78 11                	js     8019e5 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8019d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019d7:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8019dd:	39 10                	cmp    %edx,(%eax)
  8019df:	0f 94 c0             	sete   %al
  8019e2:	0f b6 c0             	movzbl %al,%eax
}
  8019e5:	c9                   	leave  
  8019e6:	c3                   	ret    

008019e7 <opencons>:

int
opencons(void)
{
  8019e7:	55                   	push   %ebp
  8019e8:	89 e5                	mov    %esp,%ebp
  8019ea:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8019ed:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019f0:	50                   	push   %eax
  8019f1:	e8 d2 f3 ff ff       	call   800dc8 <fd_alloc>
  8019f6:	83 c4 10             	add    $0x10,%esp
  8019f9:	85 c0                	test   %eax,%eax
  8019fb:	78 3a                	js     801a37 <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8019fd:	83 ec 04             	sub    $0x4,%esp
  801a00:	68 07 04 00 00       	push   $0x407
  801a05:	ff 75 f4             	pushl  -0xc(%ebp)
  801a08:	6a 00                	push   $0x0
  801a0a:	e8 a1 f1 ff ff       	call   800bb0 <sys_page_alloc>
  801a0f:	83 c4 10             	add    $0x10,%esp
  801a12:	85 c0                	test   %eax,%eax
  801a14:	78 21                	js     801a37 <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801a16:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801a1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a1f:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801a21:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a24:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801a2b:	83 ec 0c             	sub    $0xc,%esp
  801a2e:	50                   	push   %eax
  801a2f:	e8 6d f3 ff ff       	call   800da1 <fd2num>
  801a34:	83 c4 10             	add    $0x10,%esp
}
  801a37:	c9                   	leave  
  801a38:	c3                   	ret    

00801a39 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801a39:	55                   	push   %ebp
  801a3a:	89 e5                	mov    %esp,%ebp
  801a3c:	56                   	push   %esi
  801a3d:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801a3e:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801a41:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801a47:	e8 26 f1 ff ff       	call   800b72 <sys_getenvid>
  801a4c:	83 ec 0c             	sub    $0xc,%esp
  801a4f:	ff 75 0c             	pushl  0xc(%ebp)
  801a52:	ff 75 08             	pushl  0x8(%ebp)
  801a55:	56                   	push   %esi
  801a56:	50                   	push   %eax
  801a57:	68 84 22 80 00       	push   $0x802284
  801a5c:	e8 fa e6 ff ff       	call   80015b <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801a61:	83 c4 18             	add    $0x18,%esp
  801a64:	53                   	push   %ebx
  801a65:	ff 75 10             	pushl  0x10(%ebp)
  801a68:	e8 9d e6 ff ff       	call   80010a <vcprintf>
	cprintf("\n");
  801a6d:	c7 04 24 6c 1e 80 00 	movl   $0x801e6c,(%esp)
  801a74:	e8 e2 e6 ff ff       	call   80015b <cprintf>
  801a79:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801a7c:	cc                   	int3   
  801a7d:	eb fd                	jmp    801a7c <_panic+0x43>

00801a7f <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a7f:	55                   	push   %ebp
  801a80:	89 e5                	mov    %esp,%ebp
  801a82:	56                   	push   %esi
  801a83:	53                   	push   %ebx
  801a84:	8b 75 08             	mov    0x8(%ebp),%esi
  801a87:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a8a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");
	int r;
    if (pg != NULL) {
  801a8d:	85 c0                	test   %eax,%eax
  801a8f:	74 0e                	je     801a9f <ipc_recv+0x20>
        r = sys_ipc_recv(pg);
  801a91:	83 ec 0c             	sub    $0xc,%esp
  801a94:	50                   	push   %eax
  801a95:	e8 c6 f2 ff ff       	call   800d60 <sys_ipc_recv>
  801a9a:	83 c4 10             	add    $0x10,%esp
  801a9d:	eb 10                	jmp    801aaf <ipc_recv+0x30>
    } else {
        r = sys_ipc_recv((void *) UTOP);
  801a9f:	83 ec 0c             	sub    $0xc,%esp
  801aa2:	68 00 00 c0 ee       	push   $0xeec00000
  801aa7:	e8 b4 f2 ff ff       	call   800d60 <sys_ipc_recv>
  801aac:	83 c4 10             	add    $0x10,%esp
    }
    if (r < 0) {
  801aaf:	85 c0                	test   %eax,%eax
  801ab1:	79 16                	jns    801ac9 <ipc_recv+0x4a>
        // failed
        if (from_env_store != NULL) *from_env_store = 0;
  801ab3:	85 f6                	test   %esi,%esi
  801ab5:	74 06                	je     801abd <ipc_recv+0x3e>
  801ab7:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        if (perm_store != NULL) *perm_store = 0;
  801abd:	85 db                	test   %ebx,%ebx
  801abf:	74 2c                	je     801aed <ipc_recv+0x6e>
  801ac1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801ac7:	eb 24                	jmp    801aed <ipc_recv+0x6e>
        return r;
    } else {
        if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801ac9:	85 f6                	test   %esi,%esi
  801acb:	74 0a                	je     801ad7 <ipc_recv+0x58>
  801acd:	a1 08 40 80 00       	mov    0x804008,%eax
  801ad2:	8b 40 74             	mov    0x74(%eax),%eax
  801ad5:	89 06                	mov    %eax,(%esi)
        if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801ad7:	85 db                	test   %ebx,%ebx
  801ad9:	74 0a                	je     801ae5 <ipc_recv+0x66>
  801adb:	a1 08 40 80 00       	mov    0x804008,%eax
  801ae0:	8b 40 78             	mov    0x78(%eax),%eax
  801ae3:	89 03                	mov    %eax,(%ebx)
        return thisenv->env_ipc_value;
  801ae5:	a1 08 40 80 00       	mov    0x804008,%eax
  801aea:	8b 40 70             	mov    0x70(%eax),%eax
    }
 
	return 0;
}
  801aed:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801af0:	5b                   	pop    %ebx
  801af1:	5e                   	pop    %esi
  801af2:	5d                   	pop    %ebp
  801af3:	c3                   	ret    

00801af4 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801af4:	55                   	push   %ebp
  801af5:	89 e5                	mov    %esp,%ebp
  801af7:	57                   	push   %edi
  801af8:	56                   	push   %esi
  801af9:	53                   	push   %ebx
  801afa:	83 ec 0c             	sub    $0xc,%esp
  801afd:	8b 75 10             	mov    0x10(%ebp),%esi
  801b00:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");
	int r;
    if (pg == NULL) pg = (void *)UTOP;
  801b03:	85 f6                	test   %esi,%esi
  801b05:	75 05                	jne    801b0c <ipc_send+0x18>
  801b07:	be 00 00 c0 ee       	mov    $0xeec00000,%esi
    do {
        r = sys_ipc_try_send(to_env, val, pg, perm);
  801b0c:	57                   	push   %edi
  801b0d:	56                   	push   %esi
  801b0e:	ff 75 0c             	pushl  0xc(%ebp)
  801b11:	ff 75 08             	pushl  0x8(%ebp)
  801b14:	e8 24 f2 ff ff       	call   800d3d <sys_ipc_try_send>
  801b19:	89 c3                	mov    %eax,%ebx
        if (r < 0 && r != -E_IPC_NOT_RECV) panic("ipc send failed: %e", r);
  801b1b:	83 c4 10             	add    $0x10,%esp
  801b1e:	85 c0                	test   %eax,%eax
  801b20:	79 17                	jns    801b39 <ipc_send+0x45>
  801b22:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801b25:	74 1d                	je     801b44 <ipc_send+0x50>
  801b27:	50                   	push   %eax
  801b28:	68 a8 22 80 00       	push   $0x8022a8
  801b2d:	6a 40                	push   $0x40
  801b2f:	68 bc 22 80 00       	push   $0x8022bc
  801b34:	e8 00 ff ff ff       	call   801a39 <_panic>
        sys_yield();
  801b39:	e8 53 f0 ff ff       	call   800b91 <sys_yield>
    } while (r != 0);
  801b3e:	85 db                	test   %ebx,%ebx
  801b40:	75 ca                	jne    801b0c <ipc_send+0x18>
  801b42:	eb 07                	jmp    801b4b <ipc_send+0x57>
	int r;
    if (pg == NULL) pg = (void *)UTOP;
    do {
        r = sys_ipc_try_send(to_env, val, pg, perm);
        if (r < 0 && r != -E_IPC_NOT_RECV) panic("ipc send failed: %e", r);
        sys_yield();
  801b44:	e8 48 f0 ff ff       	call   800b91 <sys_yield>
  801b49:	eb c1                	jmp    801b0c <ipc_send+0x18>
    } while (r != 0);
}
  801b4b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b4e:	5b                   	pop    %ebx
  801b4f:	5e                   	pop    %esi
  801b50:	5f                   	pop    %edi
  801b51:	5d                   	pop    %ebp
  801b52:	c3                   	ret    

00801b53 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b53:	55                   	push   %ebp
  801b54:	89 e5                	mov    %esp,%ebp
  801b56:	53                   	push   %ebx
  801b57:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801b5a:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  801b5f:	39 c1                	cmp    %eax,%ecx
  801b61:	74 21                	je     801b84 <ipc_find_env+0x31>
  801b63:	ba 01 00 00 00       	mov    $0x1,%edx
  801b68:	8d 1c 95 00 00 00 00 	lea    0x0(,%edx,4),%ebx
  801b6f:	89 d0                	mov    %edx,%eax
  801b71:	c1 e0 07             	shl    $0x7,%eax
  801b74:	29 d8                	sub    %ebx,%eax
  801b76:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b7b:	8b 40 50             	mov    0x50(%eax),%eax
  801b7e:	39 c8                	cmp    %ecx,%eax
  801b80:	75 1b                	jne    801b9d <ipc_find_env+0x4a>
  801b82:	eb 05                	jmp    801b89 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b84:	ba 00 00 00 00       	mov    $0x0,%edx
		if (envs[i].env_type == type)
			return envs[i].env_id;
  801b89:	8d 04 95 00 00 00 00 	lea    0x0(,%edx,4),%eax
  801b90:	c1 e2 07             	shl    $0x7,%edx
  801b93:	29 c2                	sub    %eax,%edx
  801b95:	8b 82 48 00 c0 ee    	mov    -0x113fffb8(%edx),%eax
  801b9b:	eb 0e                	jmp    801bab <ipc_find_env+0x58>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b9d:	42                   	inc    %edx
  801b9e:	81 fa 00 04 00 00    	cmp    $0x400,%edx
  801ba4:	75 c2                	jne    801b68 <ipc_find_env+0x15>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801ba6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801bab:	5b                   	pop    %ebx
  801bac:	5d                   	pop    %ebp
  801bad:	c3                   	ret    

00801bae <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801bae:	55                   	push   %ebp
  801baf:	89 e5                	mov    %esp,%ebp
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801bb1:	8b 45 08             	mov    0x8(%ebp),%eax
  801bb4:	c1 e8 16             	shr    $0x16,%eax
  801bb7:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801bbe:	a8 01                	test   $0x1,%al
  801bc0:	74 21                	je     801be3 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801bc2:	8b 45 08             	mov    0x8(%ebp),%eax
  801bc5:	c1 e8 0c             	shr    $0xc,%eax
  801bc8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801bcf:	a8 01                	test   $0x1,%al
  801bd1:	74 17                	je     801bea <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801bd3:	c1 e8 0c             	shr    $0xc,%eax
  801bd6:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801bdd:	ef 
  801bde:	0f b7 c0             	movzwl %ax,%eax
  801be1:	eb 0c                	jmp    801bef <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801be3:	b8 00 00 00 00       	mov    $0x0,%eax
  801be8:	eb 05                	jmp    801bef <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801bea:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801bef:	5d                   	pop    %ebp
  801bf0:	c3                   	ret    
  801bf1:	66 90                	xchg   %ax,%ax
  801bf3:	90                   	nop

00801bf4 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801bf4:	55                   	push   %ebp
  801bf5:	57                   	push   %edi
  801bf6:	56                   	push   %esi
  801bf7:	53                   	push   %ebx
  801bf8:	83 ec 1c             	sub    $0x1c,%esp
  801bfb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801bff:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801c03:	8b 7c 24 38          	mov    0x38(%esp),%edi
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801c07:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801c0b:	89 ca                	mov    %ecx,%edx
  const DWunion dd = {.ll = d};
  801c0d:	89 f8                	mov    %edi,%eax
  801c0f:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801c13:	85 f6                	test   %esi,%esi
  801c15:	75 2d                	jne    801c44 <__udivdi3+0x50>
    {
      if (d0 > n1)
  801c17:	39 cf                	cmp    %ecx,%edi
  801c19:	77 65                	ja     801c80 <__udivdi3+0x8c>
  801c1b:	89 fd                	mov    %edi,%ebp
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801c1d:	85 ff                	test   %edi,%edi
  801c1f:	75 0b                	jne    801c2c <__udivdi3+0x38>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801c21:	b8 01 00 00 00       	mov    $0x1,%eax
  801c26:	31 d2                	xor    %edx,%edx
  801c28:	f7 f7                	div    %edi
  801c2a:	89 c5                	mov    %eax,%ebp

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801c2c:	31 d2                	xor    %edx,%edx
  801c2e:	89 c8                	mov    %ecx,%eax
  801c30:	f7 f5                	div    %ebp
  801c32:	89 c1                	mov    %eax,%ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801c34:	89 d8                	mov    %ebx,%eax
  801c36:	f7 f5                	div    %ebp
  801c38:	89 cf                	mov    %ecx,%edi
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801c3a:	89 fa                	mov    %edi,%edx
  801c3c:	83 c4 1c             	add    $0x1c,%esp
  801c3f:	5b                   	pop    %ebx
  801c40:	5e                   	pop    %esi
  801c41:	5f                   	pop    %edi
  801c42:	5d                   	pop    %ebp
  801c43:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801c44:	39 ce                	cmp    %ecx,%esi
  801c46:	77 28                	ja     801c70 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801c48:	0f bd fe             	bsr    %esi,%edi
	  if (bm == 0)
  801c4b:	83 f7 1f             	xor    $0x1f,%edi
  801c4e:	75 40                	jne    801c90 <__udivdi3+0x9c>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801c50:	39 ce                	cmp    %ecx,%esi
  801c52:	72 0a                	jb     801c5e <__udivdi3+0x6a>
  801c54:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801c58:	0f 87 9e 00 00 00    	ja     801cfc <__udivdi3+0x108>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801c5e:	b8 01 00 00 00       	mov    $0x1,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801c63:	89 fa                	mov    %edi,%edx
  801c65:	83 c4 1c             	add    $0x1c,%esp
  801c68:	5b                   	pop    %ebx
  801c69:	5e                   	pop    %esi
  801c6a:	5f                   	pop    %edi
  801c6b:	5d                   	pop    %ebp
  801c6c:	c3                   	ret    
  801c6d:	8d 76 00             	lea    0x0(%esi),%esi
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801c70:	31 ff                	xor    %edi,%edi
  801c72:	31 c0                	xor    %eax,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801c74:	89 fa                	mov    %edi,%edx
  801c76:	83 c4 1c             	add    $0x1c,%esp
  801c79:	5b                   	pop    %ebx
  801c7a:	5e                   	pop    %esi
  801c7b:	5f                   	pop    %edi
  801c7c:	5d                   	pop    %ebp
  801c7d:	c3                   	ret    
  801c7e:	66 90                	xchg   %ax,%ax
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801c80:	89 d8                	mov    %ebx,%eax
  801c82:	f7 f7                	div    %edi
  801c84:	31 ff                	xor    %edi,%edi
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801c86:	89 fa                	mov    %edi,%edx
  801c88:	83 c4 1c             	add    $0x1c,%esp
  801c8b:	5b                   	pop    %ebx
  801c8c:	5e                   	pop    %esi
  801c8d:	5f                   	pop    %edi
  801c8e:	5d                   	pop    %ebp
  801c8f:	c3                   	ret    
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801c90:	bd 20 00 00 00       	mov    $0x20,%ebp
  801c95:	89 eb                	mov    %ebp,%ebx
  801c97:	29 fb                	sub    %edi,%ebx

	      d1 = (d1 << bm) | (d0 >> b);
  801c99:	89 f9                	mov    %edi,%ecx
  801c9b:	d3 e6                	shl    %cl,%esi
  801c9d:	89 c5                	mov    %eax,%ebp
  801c9f:	88 d9                	mov    %bl,%cl
  801ca1:	d3 ed                	shr    %cl,%ebp
  801ca3:	89 e9                	mov    %ebp,%ecx
  801ca5:	09 f1                	or     %esi,%ecx
  801ca7:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
	      d0 = d0 << bm;
  801cab:	89 f9                	mov    %edi,%ecx
  801cad:	d3 e0                	shl    %cl,%eax
  801caf:	89 c5                	mov    %eax,%ebp
	      n2 = n1 >> b;
  801cb1:	89 d6                	mov    %edx,%esi
  801cb3:	88 d9                	mov    %bl,%cl
  801cb5:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
  801cb7:	89 f9                	mov    %edi,%ecx
  801cb9:	d3 e2                	shl    %cl,%edx
  801cbb:	8b 44 24 08          	mov    0x8(%esp),%eax
  801cbf:	88 d9                	mov    %bl,%cl
  801cc1:	d3 e8                	shr    %cl,%eax
  801cc3:	09 c2                	or     %eax,%edx
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801cc5:	89 d0                	mov    %edx,%eax
  801cc7:	89 f2                	mov    %esi,%edx
  801cc9:	f7 74 24 0c          	divl   0xc(%esp)
  801ccd:	89 d6                	mov    %edx,%esi
  801ccf:	89 c3                	mov    %eax,%ebx
	      umul_ppmm (m1, m0, q0, d0);
  801cd1:	f7 e5                	mul    %ebp

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801cd3:	39 d6                	cmp    %edx,%esi
  801cd5:	72 19                	jb     801cf0 <__udivdi3+0xfc>
  801cd7:	74 0b                	je     801ce4 <__udivdi3+0xf0>
  801cd9:	89 d8                	mov    %ebx,%eax
  801cdb:	31 ff                	xor    %edi,%edi
  801cdd:	e9 58 ff ff ff       	jmp    801c3a <__udivdi3+0x46>
  801ce2:	66 90                	xchg   %ax,%ax
  801ce4:	8b 54 24 08          	mov    0x8(%esp),%edx
  801ce8:	89 f9                	mov    %edi,%ecx
  801cea:	d3 e2                	shl    %cl,%edx
  801cec:	39 c2                	cmp    %eax,%edx
  801cee:	73 e9                	jae    801cd9 <__udivdi3+0xe5>
  801cf0:	8d 43 ff             	lea    -0x1(%ebx),%eax
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801cf3:	31 ff                	xor    %edi,%edi
  801cf5:	e9 40 ff ff ff       	jmp    801c3a <__udivdi3+0x46>
  801cfa:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801cfc:	31 c0                	xor    %eax,%eax
  801cfe:	e9 37 ff ff ff       	jmp    801c3a <__udivdi3+0x46>
  801d03:	90                   	nop

00801d04 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  801d04:	55                   	push   %ebp
  801d05:	57                   	push   %edi
  801d06:	56                   	push   %esi
  801d07:	53                   	push   %ebx
  801d08:	83 ec 1c             	sub    $0x1c,%esp
  801d0b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801d0f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801d13:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801d17:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801d1b:	89 44 24 0c          	mov    %eax,0xc(%esp)
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801d1f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801d23:	89 f3                	mov    %esi,%ebx
  const DWunion dd = {.ll = d};
  801d25:	89 fa                	mov    %edi,%edx
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  801d27:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  n1 = nn.s.high;
  801d2b:	89 34 24             	mov    %esi,(%esp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801d2e:	85 c0                	test   %eax,%eax
  801d30:	75 1a                	jne    801d4c <__umoddi3+0x48>
    {
      if (d0 > n1)
  801d32:	39 f7                	cmp    %esi,%edi
  801d34:	0f 86 a2 00 00 00    	jbe    801ddc <__umoddi3+0xd8>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801d3a:	89 c8                	mov    %ecx,%eax
  801d3c:	89 f2                	mov    %esi,%edx
  801d3e:	f7 f7                	div    %edi
  801d40:	89 d0                	mov    %edx,%eax

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  801d42:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801d44:	83 c4 1c             	add    $0x1c,%esp
  801d47:	5b                   	pop    %ebx
  801d48:	5e                   	pop    %esi
  801d49:	5f                   	pop    %edi
  801d4a:	5d                   	pop    %ebp
  801d4b:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801d4c:	39 f0                	cmp    %esi,%eax
  801d4e:	0f 87 ac 00 00 00    	ja     801e00 <__umoddi3+0xfc>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801d54:	0f bd e8             	bsr    %eax,%ebp
	  if (bm == 0)
  801d57:	83 f5 1f             	xor    $0x1f,%ebp
  801d5a:	0f 84 ac 00 00 00    	je     801e0c <__umoddi3+0x108>
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801d60:	bf 20 00 00 00       	mov    $0x20,%edi
  801d65:	29 ef                	sub    %ebp,%edi
  801d67:	89 fe                	mov    %edi,%esi
  801d69:	89 7c 24 0c          	mov    %edi,0xc(%esp)

	      d1 = (d1 << bm) | (d0 >> b);
  801d6d:	89 e9                	mov    %ebp,%ecx
  801d6f:	d3 e0                	shl    %cl,%eax
  801d71:	89 d7                	mov    %edx,%edi
  801d73:	89 f1                	mov    %esi,%ecx
  801d75:	d3 ef                	shr    %cl,%edi
  801d77:	09 c7                	or     %eax,%edi
	      d0 = d0 << bm;
  801d79:	89 e9                	mov    %ebp,%ecx
  801d7b:	d3 e2                	shl    %cl,%edx
  801d7d:	89 14 24             	mov    %edx,(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801d80:	89 d8                	mov    %ebx,%eax
  801d82:	d3 e0                	shl    %cl,%eax
  801d84:	89 c2                	mov    %eax,%edx
	      n0 = n0 << bm;
  801d86:	8b 44 24 08          	mov    0x8(%esp),%eax
  801d8a:	d3 e0                	shl    %cl,%eax
  801d8c:	89 44 24 04          	mov    %eax,0x4(%esp)

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801d90:	8b 44 24 08          	mov    0x8(%esp),%eax
  801d94:	89 f1                	mov    %esi,%ecx
  801d96:	d3 e8                	shr    %cl,%eax
  801d98:	09 d0                	or     %edx,%eax
  801d9a:	d3 eb                	shr    %cl,%ebx
  801d9c:	89 da                	mov    %ebx,%edx
  801d9e:	f7 f7                	div    %edi
  801da0:	89 d3                	mov    %edx,%ebx
	      umul_ppmm (m1, m0, q0, d0);
  801da2:	f7 24 24             	mull   (%esp)
  801da5:	89 c6                	mov    %eax,%esi
  801da7:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801da9:	39 d3                	cmp    %edx,%ebx
  801dab:	0f 82 87 00 00 00    	jb     801e38 <__umoddi3+0x134>
  801db1:	0f 84 91 00 00 00    	je     801e48 <__umoddi3+0x144>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  801db7:	8b 54 24 04          	mov    0x4(%esp),%edx
  801dbb:	29 f2                	sub    %esi,%edx
  801dbd:	19 cb                	sbb    %ecx,%ebx
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801dbf:	89 d8                	mov    %ebx,%eax
  801dc1:	8a 4c 24 0c          	mov    0xc(%esp),%cl
  801dc5:	d3 e0                	shl    %cl,%eax
  801dc7:	89 e9                	mov    %ebp,%ecx
  801dc9:	d3 ea                	shr    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  801dcb:	09 d0                	or     %edx,%eax
  801dcd:	89 e9                	mov    %ebp,%ecx
  801dcf:	d3 eb                	shr    %cl,%ebx
  801dd1:	89 da                	mov    %ebx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801dd3:	83 c4 1c             	add    $0x1c,%esp
  801dd6:	5b                   	pop    %ebx
  801dd7:	5e                   	pop    %esi
  801dd8:	5f                   	pop    %edi
  801dd9:	5d                   	pop    %ebp
  801dda:	c3                   	ret    
  801ddb:	90                   	nop
  801ddc:	89 fd                	mov    %edi,%ebp
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801dde:	85 ff                	test   %edi,%edi
  801de0:	75 0b                	jne    801ded <__umoddi3+0xe9>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801de2:	b8 01 00 00 00       	mov    $0x1,%eax
  801de7:	31 d2                	xor    %edx,%edx
  801de9:	f7 f7                	div    %edi
  801deb:	89 c5                	mov    %eax,%ebp

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801ded:	89 f0                	mov    %esi,%eax
  801def:	31 d2                	xor    %edx,%edx
  801df1:	f7 f5                	div    %ebp
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801df3:	89 c8                	mov    %ecx,%eax
  801df5:	f7 f5                	div    %ebp
  801df7:	89 d0                	mov    %edx,%eax
  801df9:	e9 44 ff ff ff       	jmp    801d42 <__umoddi3+0x3e>
  801dfe:	66 90                	xchg   %ax,%ax
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  801e00:	89 c8                	mov    %ecx,%eax
  801e02:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801e04:	83 c4 1c             	add    $0x1c,%esp
  801e07:	5b                   	pop    %ebx
  801e08:	5e                   	pop    %esi
  801e09:	5f                   	pop    %edi
  801e0a:	5d                   	pop    %ebp
  801e0b:	c3                   	ret    

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801e0c:	3b 04 24             	cmp    (%esp),%eax
  801e0f:	72 06                	jb     801e17 <__umoddi3+0x113>
  801e11:	3b 7c 24 04          	cmp    0x4(%esp),%edi
  801e15:	77 0f                	ja     801e26 <__umoddi3+0x122>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801e17:	89 f2                	mov    %esi,%edx
  801e19:	29 f9                	sub    %edi,%ecx
  801e1b:	1b 54 24 0c          	sbb    0xc(%esp),%edx
  801e1f:	89 14 24             	mov    %edx,(%esp)
  801e22:	89 4c 24 04          	mov    %ecx,0x4(%esp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  801e26:	8b 44 24 04          	mov    0x4(%esp),%eax
  801e2a:	8b 14 24             	mov    (%esp),%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801e2d:	83 c4 1c             	add    $0x1c,%esp
  801e30:	5b                   	pop    %ebx
  801e31:	5e                   	pop    %esi
  801e32:	5f                   	pop    %edi
  801e33:	5d                   	pop    %ebp
  801e34:	c3                   	ret    
  801e35:	8d 76 00             	lea    0x0(%esi),%esi
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801e38:	2b 04 24             	sub    (%esp),%eax
  801e3b:	19 fa                	sbb    %edi,%edx
  801e3d:	89 d1                	mov    %edx,%ecx
  801e3f:	89 c6                	mov    %eax,%esi
  801e41:	e9 71 ff ff ff       	jmp    801db7 <__umoddi3+0xb3>
  801e46:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801e48:	39 44 24 04          	cmp    %eax,0x4(%esp)
  801e4c:	72 ea                	jb     801e38 <__umoddi3+0x134>
  801e4e:	89 d9                	mov    %ebx,%ecx
  801e50:	e9 62 ff ff ff       	jmp    801db7 <__umoddi3+0xb3>
