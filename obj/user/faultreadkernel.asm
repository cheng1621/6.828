
obj/user/faultreadkernel.debug:     file format elf32-i386


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
  80002c:	e8 1d 00 00 00       	call   80004e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	cprintf("I read %08x from location 0xf0100000!\n", *(unsigned*)0xf0100000);
  800039:	ff 35 00 00 10 f0    	pushl  0xf0100000
  80003f:	68 60 1e 80 00       	push   $0x801e60
  800044:	e8 00 01 00 00       	call   800149 <cprintf>
}
  800049:	83 c4 10             	add    $0x10,%esp
  80004c:	c9                   	leave  
  80004d:	c3                   	ret    

0080004e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004e:	55                   	push   %ebp
  80004f:	89 e5                	mov    %esp,%ebp
  800051:	56                   	push   %esi
  800052:	53                   	push   %ebx
  800053:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800056:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800059:	e8 02 0b 00 00       	call   800b60 <sys_getenvid>
  80005e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800063:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80006a:	c1 e0 07             	shl    $0x7,%eax
  80006d:	29 d0                	sub    %edx,%eax
  80006f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800074:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800079:	85 db                	test   %ebx,%ebx
  80007b:	7e 07                	jle    800084 <libmain+0x36>
		binaryname = argv[0];
  80007d:	8b 06                	mov    (%esi),%eax
  80007f:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800084:	83 ec 08             	sub    $0x8,%esp
  800087:	56                   	push   %esi
  800088:	53                   	push   %ebx
  800089:	e8 a5 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80008e:	e8 0a 00 00 00       	call   80009d <exit>
}
  800093:	83 c4 10             	add    $0x10,%esp
  800096:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800099:	5b                   	pop    %ebx
  80009a:	5e                   	pop    %esi
  80009b:	5d                   	pop    %ebp
  80009c:	c3                   	ret    

0080009d <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80009d:	55                   	push   %ebp
  80009e:	89 e5                	mov    %esp,%ebp
  8000a0:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000a3:	e8 f6 0e 00 00       	call   800f9e <close_all>
	sys_env_destroy(0);
  8000a8:	83 ec 0c             	sub    $0xc,%esp
  8000ab:	6a 00                	push   $0x0
  8000ad:	e8 6d 0a 00 00       	call   800b1f <sys_env_destroy>
}
  8000b2:	83 c4 10             	add    $0x10,%esp
  8000b5:	c9                   	leave  
  8000b6:	c3                   	ret    

008000b7 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000b7:	55                   	push   %ebp
  8000b8:	89 e5                	mov    %esp,%ebp
  8000ba:	53                   	push   %ebx
  8000bb:	83 ec 04             	sub    $0x4,%esp
  8000be:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000c1:	8b 13                	mov    (%ebx),%edx
  8000c3:	8d 42 01             	lea    0x1(%edx),%eax
  8000c6:	89 03                	mov    %eax,(%ebx)
  8000c8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000cb:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000cf:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000d4:	75 1a                	jne    8000f0 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8000d6:	83 ec 08             	sub    $0x8,%esp
  8000d9:	68 ff 00 00 00       	push   $0xff
  8000de:	8d 43 08             	lea    0x8(%ebx),%eax
  8000e1:	50                   	push   %eax
  8000e2:	e8 fb 09 00 00       	call   800ae2 <sys_cputs>
		b->idx = 0;
  8000e7:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8000ed:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8000f0:	ff 43 04             	incl   0x4(%ebx)
}
  8000f3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000f6:	c9                   	leave  
  8000f7:	c3                   	ret    

008000f8 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8000f8:	55                   	push   %ebp
  8000f9:	89 e5                	mov    %esp,%ebp
  8000fb:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800101:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800108:	00 00 00 
	b.cnt = 0;
  80010b:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800112:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800115:	ff 75 0c             	pushl  0xc(%ebp)
  800118:	ff 75 08             	pushl  0x8(%ebp)
  80011b:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800121:	50                   	push   %eax
  800122:	68 b7 00 80 00       	push   $0x8000b7
  800127:	e8 54 01 00 00       	call   800280 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80012c:	83 c4 08             	add    $0x8,%esp
  80012f:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800135:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80013b:	50                   	push   %eax
  80013c:	e8 a1 09 00 00       	call   800ae2 <sys_cputs>

	return b.cnt;
}
  800141:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800147:	c9                   	leave  
  800148:	c3                   	ret    

00800149 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800149:	55                   	push   %ebp
  80014a:	89 e5                	mov    %esp,%ebp
  80014c:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80014f:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800152:	50                   	push   %eax
  800153:	ff 75 08             	pushl  0x8(%ebp)
  800156:	e8 9d ff ff ff       	call   8000f8 <vcprintf>
	va_end(ap);

	return cnt;
}
  80015b:	c9                   	leave  
  80015c:	c3                   	ret    

0080015d <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80015d:	55                   	push   %ebp
  80015e:	89 e5                	mov    %esp,%ebp
  800160:	57                   	push   %edi
  800161:	56                   	push   %esi
  800162:	53                   	push   %ebx
  800163:	83 ec 1c             	sub    $0x1c,%esp
  800166:	89 c6                	mov    %eax,%esi
  800168:	89 d7                	mov    %edx,%edi
  80016a:	8b 45 08             	mov    0x8(%ebp),%eax
  80016d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800170:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800173:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800176:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800179:	bb 00 00 00 00       	mov    $0x0,%ebx
  80017e:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800181:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800184:	39 d3                	cmp    %edx,%ebx
  800186:	72 11                	jb     800199 <printnum+0x3c>
  800188:	39 45 10             	cmp    %eax,0x10(%ebp)
  80018b:	76 0c                	jbe    800199 <printnum+0x3c>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80018d:	8b 45 14             	mov    0x14(%ebp),%eax
  800190:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800193:	85 db                	test   %ebx,%ebx
  800195:	7f 37                	jg     8001ce <printnum+0x71>
  800197:	eb 44                	jmp    8001dd <printnum+0x80>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800199:	83 ec 0c             	sub    $0xc,%esp
  80019c:	ff 75 18             	pushl  0x18(%ebp)
  80019f:	8b 45 14             	mov    0x14(%ebp),%eax
  8001a2:	48                   	dec    %eax
  8001a3:	50                   	push   %eax
  8001a4:	ff 75 10             	pushl  0x10(%ebp)
  8001a7:	83 ec 08             	sub    $0x8,%esp
  8001aa:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001ad:	ff 75 e0             	pushl  -0x20(%ebp)
  8001b0:	ff 75 dc             	pushl  -0x24(%ebp)
  8001b3:	ff 75 d8             	pushl  -0x28(%ebp)
  8001b6:	e8 25 1a 00 00       	call   801be0 <__udivdi3>
  8001bb:	83 c4 18             	add    $0x18,%esp
  8001be:	52                   	push   %edx
  8001bf:	50                   	push   %eax
  8001c0:	89 fa                	mov    %edi,%edx
  8001c2:	89 f0                	mov    %esi,%eax
  8001c4:	e8 94 ff ff ff       	call   80015d <printnum>
  8001c9:	83 c4 20             	add    $0x20,%esp
  8001cc:	eb 0f                	jmp    8001dd <printnum+0x80>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001ce:	83 ec 08             	sub    $0x8,%esp
  8001d1:	57                   	push   %edi
  8001d2:	ff 75 18             	pushl  0x18(%ebp)
  8001d5:	ff d6                	call   *%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001d7:	83 c4 10             	add    $0x10,%esp
  8001da:	4b                   	dec    %ebx
  8001db:	75 f1                	jne    8001ce <printnum+0x71>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001dd:	83 ec 08             	sub    $0x8,%esp
  8001e0:	57                   	push   %edi
  8001e1:	83 ec 04             	sub    $0x4,%esp
  8001e4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001e7:	ff 75 e0             	pushl  -0x20(%ebp)
  8001ea:	ff 75 dc             	pushl  -0x24(%ebp)
  8001ed:	ff 75 d8             	pushl  -0x28(%ebp)
  8001f0:	e8 fb 1a 00 00       	call   801cf0 <__umoddi3>
  8001f5:	83 c4 14             	add    $0x14,%esp
  8001f8:	0f be 80 91 1e 80 00 	movsbl 0x801e91(%eax),%eax
  8001ff:	50                   	push   %eax
  800200:	ff d6                	call   *%esi
}
  800202:	83 c4 10             	add    $0x10,%esp
  800205:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800208:	5b                   	pop    %ebx
  800209:	5e                   	pop    %esi
  80020a:	5f                   	pop    %edi
  80020b:	5d                   	pop    %ebp
  80020c:	c3                   	ret    

0080020d <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80020d:	55                   	push   %ebp
  80020e:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800210:	83 fa 01             	cmp    $0x1,%edx
  800213:	7e 0e                	jle    800223 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800215:	8b 10                	mov    (%eax),%edx
  800217:	8d 4a 08             	lea    0x8(%edx),%ecx
  80021a:	89 08                	mov    %ecx,(%eax)
  80021c:	8b 02                	mov    (%edx),%eax
  80021e:	8b 52 04             	mov    0x4(%edx),%edx
  800221:	eb 22                	jmp    800245 <getuint+0x38>
	else if (lflag)
  800223:	85 d2                	test   %edx,%edx
  800225:	74 10                	je     800237 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800227:	8b 10                	mov    (%eax),%edx
  800229:	8d 4a 04             	lea    0x4(%edx),%ecx
  80022c:	89 08                	mov    %ecx,(%eax)
  80022e:	8b 02                	mov    (%edx),%eax
  800230:	ba 00 00 00 00       	mov    $0x0,%edx
  800235:	eb 0e                	jmp    800245 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800237:	8b 10                	mov    (%eax),%edx
  800239:	8d 4a 04             	lea    0x4(%edx),%ecx
  80023c:	89 08                	mov    %ecx,(%eax)
  80023e:	8b 02                	mov    (%edx),%eax
  800240:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800245:	5d                   	pop    %ebp
  800246:	c3                   	ret    

00800247 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800247:	55                   	push   %ebp
  800248:	89 e5                	mov    %esp,%ebp
  80024a:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80024d:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800250:	8b 10                	mov    (%eax),%edx
  800252:	3b 50 04             	cmp    0x4(%eax),%edx
  800255:	73 0a                	jae    800261 <sprintputch+0x1a>
		*b->buf++ = ch;
  800257:	8d 4a 01             	lea    0x1(%edx),%ecx
  80025a:	89 08                	mov    %ecx,(%eax)
  80025c:	8b 45 08             	mov    0x8(%ebp),%eax
  80025f:	88 02                	mov    %al,(%edx)
}
  800261:	5d                   	pop    %ebp
  800262:	c3                   	ret    

00800263 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800263:	55                   	push   %ebp
  800264:	89 e5                	mov    %esp,%ebp
  800266:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800269:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80026c:	50                   	push   %eax
  80026d:	ff 75 10             	pushl  0x10(%ebp)
  800270:	ff 75 0c             	pushl  0xc(%ebp)
  800273:	ff 75 08             	pushl  0x8(%ebp)
  800276:	e8 05 00 00 00       	call   800280 <vprintfmt>
	va_end(ap);
}
  80027b:	83 c4 10             	add    $0x10,%esp
  80027e:	c9                   	leave  
  80027f:	c3                   	ret    

00800280 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800280:	55                   	push   %ebp
  800281:	89 e5                	mov    %esp,%ebp
  800283:	57                   	push   %edi
  800284:	56                   	push   %esi
  800285:	53                   	push   %ebx
  800286:	83 ec 2c             	sub    $0x2c,%esp
  800289:	8b 7d 08             	mov    0x8(%ebp),%edi
  80028c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80028f:	eb 03                	jmp    800294 <vprintfmt+0x14>
			break;

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
			for (fmt--; fmt[-1] != '%'; fmt--)
  800291:	89 75 10             	mov    %esi,0x10(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {    //遍历输入的第一个参数，即输出信息的格式，先把格式字符串中'%'之前的字符一个个输出，因为它们前面没有'%'，所以它们就是要直接显示在屏幕上的
  800294:	8b 45 10             	mov    0x10(%ebp),%eax
  800297:	8d 70 01             	lea    0x1(%eax),%esi
  80029a:	0f b6 00             	movzbl (%eax),%eax
  80029d:	83 f8 25             	cmp    $0x25,%eax
  8002a0:	74 25                	je     8002c7 <vprintfmt+0x47>
			if (ch == '\0')									//当然中间如果遇到'\0'，代表这个字符串的访问结束
  8002a2:	85 c0                	test   %eax,%eax
  8002a4:	75 0d                	jne    8002b3 <vprintfmt+0x33>
  8002a6:	e9 b5 03 00 00       	jmp    800660 <vprintfmt+0x3e0>
  8002ab:	85 c0                	test   %eax,%eax
  8002ad:	0f 84 ad 03 00 00    	je     800660 <vprintfmt+0x3e0>
				return;
			putch(ch, putdat);								//调用putch函数，把一个字符ch输出到putdat指针所指向的地址中所存放的值对应的地址处
  8002b3:	83 ec 08             	sub    $0x8,%esp
  8002b6:	53                   	push   %ebx
  8002b7:	50                   	push   %eax
  8002b8:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {    //遍历输入的第一个参数，即输出信息的格式，先把格式字符串中'%'之前的字符一个个输出，因为它们前面没有'%'，所以它们就是要直接显示在屏幕上的
  8002ba:	46                   	inc    %esi
  8002bb:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  8002bf:	83 c4 10             	add    $0x10,%esp
  8002c2:	83 f8 25             	cmp    $0x25,%eax
  8002c5:	75 e4                	jne    8002ab <vprintfmt+0x2b>
			if (width < 0)									//代表有小数点，但是小数点前面并没有数字，比如'%.6f'这种情况，此时代表整数部分全部显示
				width = 0;			
			goto reswitch;

		case '#':
			altflag = 1;
  8002c7:	c6 45 e3 20          	movb   $0x20,-0x1d(%ebp)
  8002cb:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8002d2:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8002d9:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8002e0:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8002e7:	eb 07                	jmp    8002f0 <vprintfmt+0x70>
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  8002e9:	8b 75 10             	mov    0x10(%ebp),%esi

		// flag to pad on the right
		case '-':											//%后面的'-'代表要进行左对齐输出，右边填空格，如果省略代表右对齐
			padc = '-';										//如果有这个字符代表左对齐，则把对齐方式标志位变为'-'
  8002ec:	c6 45 e3 2d          	movb   $0x2d,-0x1d(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  8002f0:	8d 46 01             	lea    0x1(%esi),%eax
  8002f3:	89 45 10             	mov    %eax,0x10(%ebp)
  8002f6:	0f b6 16             	movzbl (%esi),%edx
  8002f9:	8a 06                	mov    (%esi),%al
  8002fb:	83 e8 23             	sub    $0x23,%eax
  8002fe:	3c 55                	cmp    $0x55,%al
  800300:	0f 87 03 03 00 00    	ja     800609 <vprintfmt+0x389>
  800306:	0f b6 c0             	movzbl %al,%eax
  800309:	ff 24 85 e0 1f 80 00 	jmp    *0x801fe0(,%eax,4)
  800310:	8b 75 10             	mov    0x10(%ebp),%esi
			padc = '-';										//如果有这个字符代表左对齐，则把对齐方式标志位变为'-'
			goto reswitch;									//处理下一个字符

		// flag to pad with 0's instead of spaces
		case '0':											//0--有0表示进行对齐输出时填0,如省略表示填入空格，并且如果为0，则一定是右对齐
			padc = '0';										//对其方式标志位变为0
  800313:	c6 45 e3 30          	movb   $0x30,-0x1d(%ebp)
  800317:	eb d7                	jmp    8002f0 <vprintfmt+0x70>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {					//把遇到的位数字符串转换为真实的位数，比如输入的'%40'，代表有效位数为40位，下面的循环就是把precesion的值设置为40
				precision = precision * 10 + ch - '0';
  800319:	8d 42 d0             	lea    -0x30(%edx),%eax
  80031c:	89 c1                	mov    %eax,%ecx
  80031e:	89 45 d0             	mov    %eax,-0x30(%ebp)
				ch = *fmt;
  800321:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  800325:	8d 50 d0             	lea    -0x30(%eax),%edx
  800328:	83 fa 09             	cmp    $0x9,%edx
  80032b:	77 51                	ja     80037e <vprintfmt+0xfe>
  80032d:	8b 75 10             	mov    0x10(%ebp),%esi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {					//把遇到的位数字符串转换为真实的位数，比如输入的'%40'，代表有效位数为40位，下面的循环就是把precesion的值设置为40
  800330:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  800331:	8d 14 89             	lea    (%ecx,%ecx,4),%edx
  800334:	01 d2                	add    %edx,%edx
  800336:	8d 4c 10 d0          	lea    -0x30(%eax,%edx,1),%ecx
				ch = *fmt;
  80033a:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80033d:	8d 50 d0             	lea    -0x30(%eax),%edx
  800340:	83 fa 09             	cmp    $0x9,%edx
  800343:	76 eb                	jbe    800330 <vprintfmt+0xb0>
  800345:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800348:	eb 37                	jmp    800381 <vprintfmt+0x101>
					break;
			}
			goto process_precision;							//跳转到process_precistion子过程

		case '*':											//*--代表有效数字的位数也是由输入参数指定的，比如printf("%*.*f", 10, 2, n)，其中10,2就是用来指定显示的有效数字位数的
			precision = va_arg(ap, int);
  80034a:	8b 45 14             	mov    0x14(%ebp),%eax
  80034d:	8d 50 04             	lea    0x4(%eax),%edx
  800350:	89 55 14             	mov    %edx,0x14(%ebp)
  800353:	8b 00                	mov    (%eax),%eax
  800355:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  800358:	8b 75 10             	mov    0x10(%ebp),%esi
			}
			goto process_precision;							//跳转到process_precistion子过程

		case '*':											//*--代表有效数字的位数也是由输入参数指定的，比如printf("%*.*f", 10, 2, n)，其中10,2就是用来指定显示的有效数字位数的
			precision = va_arg(ap, int);
			goto process_precision;
  80035b:	eb 24                	jmp    800381 <vprintfmt+0x101>
  80035d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800361:	79 07                	jns    80036a <vprintfmt+0xea>
  800363:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  80036a:	8b 75 10             	mov    0x10(%ebp),%esi
  80036d:	eb 81                	jmp    8002f0 <vprintfmt+0x70>
  80036f:	8b 75 10             	mov    0x10(%ebp),%esi
			if (width < 0)									//代表有小数点，但是小数点前面并没有数字，比如'%.6f'这种情况，此时代表整数部分全部显示
				width = 0;			
			goto reswitch;

		case '#':
			altflag = 1;
  800372:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800379:	e9 72 ff ff ff       	jmp    8002f0 <vprintfmt+0x70>
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  80037e:	8b 75 10             	mov    0x10(%ebp),%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:									//处理输出精度，把width字段赋值为刚刚计算出来的precision值，所以width应该是整数部分的有效数字位数
			if (width < 0)
  800381:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800385:	0f 89 65 ff ff ff    	jns    8002f0 <vprintfmt+0x70>
				width = precision, precision = -1;
  80038b:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80038e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800391:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800398:	e9 53 ff ff ff       	jmp    8002f0 <vprintfmt+0x70>
			goto reswitch;

		// long flag (doubled for long long)				
		case 'l':											//如果遇到'l'，代表应该是输入long类型，如果有两个'l'代表long long
			lflag++;										//此时把lflag++
  80039d:	ff 45 d4             	incl   -0x2c(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  8003a0:	8b 75 10             	mov    0x10(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)				
		case 'l':											//如果遇到'l'，代表应该是输入long类型，如果有两个'l'代表long long
			lflag++;										//此时把lflag++
			goto reswitch;
  8003a3:	e9 48 ff ff ff       	jmp    8002f0 <vprintfmt+0x70>

		// character
		case 'c':											//如果是'c'代表显示一个字符
			putch(va_arg(ap, int), putdat);					//调用输出一个字符到内存的函数putch
  8003a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ab:	8d 50 04             	lea    0x4(%eax),%edx
  8003ae:	89 55 14             	mov    %edx,0x14(%ebp)
  8003b1:	83 ec 08             	sub    $0x8,%esp
  8003b4:	53                   	push   %ebx
  8003b5:	ff 30                	pushl  (%eax)
  8003b7:	ff d7                	call   *%edi
			break;
  8003b9:	83 c4 10             	add    $0x10,%esp
  8003bc:	e9 d3 fe ff ff       	jmp    800294 <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c4:	8d 50 04             	lea    0x4(%eax),%edx
  8003c7:	89 55 14             	mov    %edx,0x14(%ebp)
  8003ca:	8b 00                	mov    (%eax),%eax
  8003cc:	85 c0                	test   %eax,%eax
  8003ce:	79 02                	jns    8003d2 <vprintfmt+0x152>
  8003d0:	f7 d8                	neg    %eax
  8003d2:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003d4:	83 f8 0f             	cmp    $0xf,%eax
  8003d7:	7f 0b                	jg     8003e4 <vprintfmt+0x164>
  8003d9:	8b 04 85 40 21 80 00 	mov    0x802140(,%eax,4),%eax
  8003e0:	85 c0                	test   %eax,%eax
  8003e2:	75 15                	jne    8003f9 <vprintfmt+0x179>
				printfmt(putch, putdat, "error %d", err);
  8003e4:	52                   	push   %edx
  8003e5:	68 a9 1e 80 00       	push   $0x801ea9
  8003ea:	53                   	push   %ebx
  8003eb:	57                   	push   %edi
  8003ec:	e8 72 fe ff ff       	call   800263 <printfmt>
  8003f1:	83 c4 10             	add    $0x10,%esp
  8003f4:	e9 9b fe ff ff       	jmp    800294 <vprintfmt+0x14>
			else
				printfmt(putch, putdat, "%s", p);
  8003f9:	50                   	push   %eax
  8003fa:	68 5f 22 80 00       	push   $0x80225f
  8003ff:	53                   	push   %ebx
  800400:	57                   	push   %edi
  800401:	e8 5d fe ff ff       	call   800263 <printfmt>
  800406:	83 c4 10             	add    $0x10,%esp
  800409:	e9 86 fe ff ff       	jmp    800294 <vprintfmt+0x14>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80040e:	8b 45 14             	mov    0x14(%ebp),%eax
  800411:	8d 50 04             	lea    0x4(%eax),%edx
  800414:	89 55 14             	mov    %edx,0x14(%ebp)
  800417:	8b 00                	mov    (%eax),%eax
  800419:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80041c:	85 c0                	test   %eax,%eax
  80041e:	75 07                	jne    800427 <vprintfmt+0x1a7>
				p = "(null)";
  800420:	c7 45 d4 a2 1e 80 00 	movl   $0x801ea2,-0x2c(%ebp)
			if (width > 0 && padc != '-')
  800427:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80042a:	85 f6                	test   %esi,%esi
  80042c:	0f 8e fb 01 00 00    	jle    80062d <vprintfmt+0x3ad>
  800432:	80 7d e3 2d          	cmpb   $0x2d,-0x1d(%ebp)
  800436:	0f 84 09 02 00 00    	je     800645 <vprintfmt+0x3c5>
				for (width -= strnlen(p, precision); width > 0; width--)
  80043c:	83 ec 08             	sub    $0x8,%esp
  80043f:	ff 75 d0             	pushl  -0x30(%ebp)
  800442:	ff 75 d4             	pushl  -0x2c(%ebp)
  800445:	e8 ad 02 00 00       	call   8006f7 <strnlen>
  80044a:	89 f1                	mov    %esi,%ecx
  80044c:	29 c1                	sub    %eax,%ecx
  80044e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  800451:	83 c4 10             	add    $0x10,%esp
  800454:	85 c9                	test   %ecx,%ecx
  800456:	0f 8e d1 01 00 00    	jle    80062d <vprintfmt+0x3ad>
					putch(padc, putdat);
  80045c:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  800460:	83 ec 08             	sub    $0x8,%esp
  800463:	53                   	push   %ebx
  800464:	56                   	push   %esi
  800465:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800467:	83 c4 10             	add    $0x10,%esp
  80046a:	ff 4d e4             	decl   -0x1c(%ebp)
  80046d:	75 f1                	jne    800460 <vprintfmt+0x1e0>
  80046f:	e9 b9 01 00 00       	jmp    80062d <vprintfmt+0x3ad>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800474:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800478:	74 19                	je     800493 <vprintfmt+0x213>
  80047a:	0f be c0             	movsbl %al,%eax
  80047d:	83 e8 20             	sub    $0x20,%eax
  800480:	83 f8 5e             	cmp    $0x5e,%eax
  800483:	76 0e                	jbe    800493 <vprintfmt+0x213>
					putch('?', putdat);
  800485:	83 ec 08             	sub    $0x8,%esp
  800488:	53                   	push   %ebx
  800489:	6a 3f                	push   $0x3f
  80048b:	ff 55 08             	call   *0x8(%ebp)
  80048e:	83 c4 10             	add    $0x10,%esp
  800491:	eb 0b                	jmp    80049e <vprintfmt+0x21e>
				else
					putch(ch, putdat);
  800493:	83 ec 08             	sub    $0x8,%esp
  800496:	53                   	push   %ebx
  800497:	52                   	push   %edx
  800498:	ff 55 08             	call   *0x8(%ebp)
  80049b:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80049e:	ff 4d e4             	decl   -0x1c(%ebp)
  8004a1:	46                   	inc    %esi
  8004a2:	8a 46 ff             	mov    -0x1(%esi),%al
  8004a5:	0f be d0             	movsbl %al,%edx
  8004a8:	85 d2                	test   %edx,%edx
  8004aa:	75 1c                	jne    8004c8 <vprintfmt+0x248>
  8004ac:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004af:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004b3:	7f 1f                	jg     8004d4 <vprintfmt+0x254>
  8004b5:	e9 da fd ff ff       	jmp    800294 <vprintfmt+0x14>
  8004ba:	89 7d 08             	mov    %edi,0x8(%ebp)
  8004bd:	8b 7d d0             	mov    -0x30(%ebp),%edi
  8004c0:	eb 06                	jmp    8004c8 <vprintfmt+0x248>
  8004c2:	89 7d 08             	mov    %edi,0x8(%ebp)
  8004c5:	8b 7d d0             	mov    -0x30(%ebp),%edi
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004c8:	85 ff                	test   %edi,%edi
  8004ca:	78 a8                	js     800474 <vprintfmt+0x1f4>
  8004cc:	4f                   	dec    %edi
  8004cd:	79 a5                	jns    800474 <vprintfmt+0x1f4>
  8004cf:	8b 7d 08             	mov    0x8(%ebp),%edi
  8004d2:	eb db                	jmp    8004af <vprintfmt+0x22f>
  8004d4:	8b 75 e4             	mov    -0x1c(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8004d7:	83 ec 08             	sub    $0x8,%esp
  8004da:	53                   	push   %ebx
  8004db:	6a 20                	push   $0x20
  8004dd:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004df:	4e                   	dec    %esi
  8004e0:	83 c4 10             	add    $0x10,%esp
  8004e3:	85 f6                	test   %esi,%esi
  8004e5:	7f f0                	jg     8004d7 <vprintfmt+0x257>
  8004e7:	e9 a8 fd ff ff       	jmp    800294 <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8004ec:	83 7d d4 01          	cmpl   $0x1,-0x2c(%ebp)
  8004f0:	7e 16                	jle    800508 <vprintfmt+0x288>
		return va_arg(*ap, long long);
  8004f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f5:	8d 50 08             	lea    0x8(%eax),%edx
  8004f8:	89 55 14             	mov    %edx,0x14(%ebp)
  8004fb:	8b 50 04             	mov    0x4(%eax),%edx
  8004fe:	8b 00                	mov    (%eax),%eax
  800500:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800503:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800506:	eb 34                	jmp    80053c <vprintfmt+0x2bc>
	else if (lflag)
  800508:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80050c:	74 18                	je     800526 <vprintfmt+0x2a6>
		return va_arg(*ap, long);
  80050e:	8b 45 14             	mov    0x14(%ebp),%eax
  800511:	8d 50 04             	lea    0x4(%eax),%edx
  800514:	89 55 14             	mov    %edx,0x14(%ebp)
  800517:	8b 30                	mov    (%eax),%esi
  800519:	89 75 d8             	mov    %esi,-0x28(%ebp)
  80051c:	89 f0                	mov    %esi,%eax
  80051e:	c1 f8 1f             	sar    $0x1f,%eax
  800521:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800524:	eb 16                	jmp    80053c <vprintfmt+0x2bc>
	else
		return va_arg(*ap, int);
  800526:	8b 45 14             	mov    0x14(%ebp),%eax
  800529:	8d 50 04             	lea    0x4(%eax),%edx
  80052c:	89 55 14             	mov    %edx,0x14(%ebp)
  80052f:	8b 30                	mov    (%eax),%esi
  800531:	89 75 d8             	mov    %esi,-0x28(%ebp)
  800534:	89 f0                	mov    %esi,%eax
  800536:	c1 f8 1f             	sar    $0x1f,%eax
  800539:	89 45 dc             	mov    %eax,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80053c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80053f:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
  800542:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800546:	0f 89 8a 00 00 00    	jns    8005d6 <vprintfmt+0x356>
				putch('-', putdat);
  80054c:	83 ec 08             	sub    $0x8,%esp
  80054f:	53                   	push   %ebx
  800550:	6a 2d                	push   $0x2d
  800552:	ff d7                	call   *%edi
				num = -(long long) num;
  800554:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800557:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80055a:	f7 d8                	neg    %eax
  80055c:	83 d2 00             	adc    $0x0,%edx
  80055f:	f7 da                	neg    %edx
  800561:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800564:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800569:	eb 70                	jmp    8005db <vprintfmt+0x35b>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80056b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80056e:	8d 45 14             	lea    0x14(%ebp),%eax
  800571:	e8 97 fc ff ff       	call   80020d <getuint>
			base = 10;
  800576:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80057b:	eb 5e                	jmp    8005db <vprintfmt+0x35b>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
  80057d:	83 ec 08             	sub    $0x8,%esp
  800580:	53                   	push   %ebx
  800581:	6a 30                	push   $0x30
  800583:	ff d7                	call   *%edi
			num = getuint(&ap, lflag);
  800585:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800588:	8d 45 14             	lea    0x14(%ebp),%eax
  80058b:	e8 7d fc ff ff       	call   80020d <getuint>
			base = 8;
			goto number;
  800590:	83 c4 10             	add    $0x10,%esp
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  800593:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800598:	eb 41                	jmp    8005db <vprintfmt+0x35b>
		// pointer
		case 'p':
			putch('0', putdat);
  80059a:	83 ec 08             	sub    $0x8,%esp
  80059d:	53                   	push   %ebx
  80059e:	6a 30                	push   $0x30
  8005a0:	ff d7                	call   *%edi
			putch('x', putdat);
  8005a2:	83 c4 08             	add    $0x8,%esp
  8005a5:	53                   	push   %ebx
  8005a6:	6a 78                	push   $0x78
  8005a8:	ff d7                	call   *%edi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ad:	8d 50 04             	lea    0x4(%eax),%edx
  8005b0:	89 55 14             	mov    %edx,0x14(%ebp)
			goto number;
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005b3:	8b 00                	mov    (%eax),%eax
  8005b5:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8005ba:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8005bd:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8005c2:	eb 17                	jmp    8005db <vprintfmt+0x35b>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8005c4:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8005c7:	8d 45 14             	lea    0x14(%ebp),%eax
  8005ca:	e8 3e fc ff ff       	call   80020d <getuint>
			base = 16;
  8005cf:	b9 10 00 00 00       	mov    $0x10,%ecx
  8005d4:	eb 05                	jmp    8005db <vprintfmt+0x35b>
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005d6:	b9 0a 00 00 00       	mov    $0xa,%ecx
		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  8005db:	83 ec 0c             	sub    $0xc,%esp
  8005de:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  8005e2:	56                   	push   %esi
  8005e3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8005e6:	51                   	push   %ecx
  8005e7:	52                   	push   %edx
  8005e8:	50                   	push   %eax
  8005e9:	89 da                	mov    %ebx,%edx
  8005eb:	89 f8                	mov    %edi,%eax
  8005ed:	e8 6b fb ff ff       	call   80015d <printnum>
			break;
  8005f2:	83 c4 20             	add    $0x20,%esp
  8005f5:	e9 9a fc ff ff       	jmp    800294 <vprintfmt+0x14>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8005fa:	83 ec 08             	sub    $0x8,%esp
  8005fd:	53                   	push   %ebx
  8005fe:	52                   	push   %edx
  8005ff:	ff d7                	call   *%edi
			break;
  800601:	83 c4 10             	add    $0x10,%esp
  800604:	e9 8b fc ff ff       	jmp    800294 <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800609:	83 ec 08             	sub    $0x8,%esp
  80060c:	53                   	push   %ebx
  80060d:	6a 25                	push   $0x25
  80060f:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800611:	83 c4 10             	add    $0x10,%esp
  800614:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800618:	0f 84 73 fc ff ff    	je     800291 <vprintfmt+0x11>
  80061e:	4e                   	dec    %esi
  80061f:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800623:	75 f9                	jne    80061e <vprintfmt+0x39e>
  800625:	89 75 10             	mov    %esi,0x10(%ebp)
  800628:	e9 67 fc ff ff       	jmp    800294 <vprintfmt+0x14>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80062d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800630:	8d 70 01             	lea    0x1(%eax),%esi
  800633:	8a 00                	mov    (%eax),%al
  800635:	0f be d0             	movsbl %al,%edx
  800638:	85 d2                	test   %edx,%edx
  80063a:	0f 85 7a fe ff ff    	jne    8004ba <vprintfmt+0x23a>
  800640:	e9 4f fc ff ff       	jmp    800294 <vprintfmt+0x14>
  800645:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800648:	8d 70 01             	lea    0x1(%eax),%esi
  80064b:	8a 00                	mov    (%eax),%al
  80064d:	0f be d0             	movsbl %al,%edx
  800650:	85 d2                	test   %edx,%edx
  800652:	0f 85 6a fe ff ff    	jne    8004c2 <vprintfmt+0x242>
  800658:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80065b:	e9 77 fe ff ff       	jmp    8004d7 <vprintfmt+0x257>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800660:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800663:	5b                   	pop    %ebx
  800664:	5e                   	pop    %esi
  800665:	5f                   	pop    %edi
  800666:	5d                   	pop    %ebp
  800667:	c3                   	ret    

00800668 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800668:	55                   	push   %ebp
  800669:	89 e5                	mov    %esp,%ebp
  80066b:	83 ec 18             	sub    $0x18,%esp
  80066e:	8b 45 08             	mov    0x8(%ebp),%eax
  800671:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800674:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800677:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80067b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80067e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800685:	85 c0                	test   %eax,%eax
  800687:	74 26                	je     8006af <vsnprintf+0x47>
  800689:	85 d2                	test   %edx,%edx
  80068b:	7e 29                	jle    8006b6 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80068d:	ff 75 14             	pushl  0x14(%ebp)
  800690:	ff 75 10             	pushl  0x10(%ebp)
  800693:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800696:	50                   	push   %eax
  800697:	68 47 02 80 00       	push   $0x800247
  80069c:	e8 df fb ff ff       	call   800280 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006a1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006a4:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006aa:	83 c4 10             	add    $0x10,%esp
  8006ad:	eb 0c                	jmp    8006bb <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006af:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006b4:	eb 05                	jmp    8006bb <vsnprintf+0x53>
  8006b6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006bb:	c9                   	leave  
  8006bc:	c3                   	ret    

008006bd <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006bd:	55                   	push   %ebp
  8006be:	89 e5                	mov    %esp,%ebp
  8006c0:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006c3:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006c6:	50                   	push   %eax
  8006c7:	ff 75 10             	pushl  0x10(%ebp)
  8006ca:	ff 75 0c             	pushl  0xc(%ebp)
  8006cd:	ff 75 08             	pushl  0x8(%ebp)
  8006d0:	e8 93 ff ff ff       	call   800668 <vsnprintf>
	va_end(ap);

	return rc;
}
  8006d5:	c9                   	leave  
  8006d6:	c3                   	ret    

008006d7 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006d7:	55                   	push   %ebp
  8006d8:	89 e5                	mov    %esp,%ebp
  8006da:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006dd:	80 3a 00             	cmpb   $0x0,(%edx)
  8006e0:	74 0e                	je     8006f0 <strlen+0x19>
  8006e2:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8006e7:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006e8:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006ec:	75 f9                	jne    8006e7 <strlen+0x10>
  8006ee:	eb 05                	jmp    8006f5 <strlen+0x1e>
  8006f0:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8006f5:	5d                   	pop    %ebp
  8006f6:	c3                   	ret    

008006f7 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006f7:	55                   	push   %ebp
  8006f8:	89 e5                	mov    %esp,%ebp
  8006fa:	53                   	push   %ebx
  8006fb:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8006fe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800701:	85 c9                	test   %ecx,%ecx
  800703:	74 1a                	je     80071f <strnlen+0x28>
  800705:	80 3b 00             	cmpb   $0x0,(%ebx)
  800708:	74 1c                	je     800726 <strnlen+0x2f>
  80070a:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  80070f:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800711:	39 ca                	cmp    %ecx,%edx
  800713:	74 16                	je     80072b <strnlen+0x34>
  800715:	42                   	inc    %edx
  800716:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  80071b:	75 f2                	jne    80070f <strnlen+0x18>
  80071d:	eb 0c                	jmp    80072b <strnlen+0x34>
  80071f:	b8 00 00 00 00       	mov    $0x0,%eax
  800724:	eb 05                	jmp    80072b <strnlen+0x34>
  800726:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  80072b:	5b                   	pop    %ebx
  80072c:	5d                   	pop    %ebp
  80072d:	c3                   	ret    

0080072e <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80072e:	55                   	push   %ebp
  80072f:	89 e5                	mov    %esp,%ebp
  800731:	53                   	push   %ebx
  800732:	8b 45 08             	mov    0x8(%ebp),%eax
  800735:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800738:	89 c2                	mov    %eax,%edx
  80073a:	42                   	inc    %edx
  80073b:	41                   	inc    %ecx
  80073c:	8a 59 ff             	mov    -0x1(%ecx),%bl
  80073f:	88 5a ff             	mov    %bl,-0x1(%edx)
  800742:	84 db                	test   %bl,%bl
  800744:	75 f4                	jne    80073a <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800746:	5b                   	pop    %ebx
  800747:	5d                   	pop    %ebp
  800748:	c3                   	ret    

00800749 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800749:	55                   	push   %ebp
  80074a:	89 e5                	mov    %esp,%ebp
  80074c:	53                   	push   %ebx
  80074d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800750:	53                   	push   %ebx
  800751:	e8 81 ff ff ff       	call   8006d7 <strlen>
  800756:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800759:	ff 75 0c             	pushl  0xc(%ebp)
  80075c:	01 d8                	add    %ebx,%eax
  80075e:	50                   	push   %eax
  80075f:	e8 ca ff ff ff       	call   80072e <strcpy>
	return dst;
}
  800764:	89 d8                	mov    %ebx,%eax
  800766:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800769:	c9                   	leave  
  80076a:	c3                   	ret    

0080076b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80076b:	55                   	push   %ebp
  80076c:	89 e5                	mov    %esp,%ebp
  80076e:	56                   	push   %esi
  80076f:	53                   	push   %ebx
  800770:	8b 75 08             	mov    0x8(%ebp),%esi
  800773:	8b 55 0c             	mov    0xc(%ebp),%edx
  800776:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800779:	85 db                	test   %ebx,%ebx
  80077b:	74 14                	je     800791 <strncpy+0x26>
  80077d:	01 f3                	add    %esi,%ebx
  80077f:	89 f1                	mov    %esi,%ecx
		*dst++ = *src;
  800781:	41                   	inc    %ecx
  800782:	8a 02                	mov    (%edx),%al
  800784:	88 41 ff             	mov    %al,-0x1(%ecx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800787:	80 3a 01             	cmpb   $0x1,(%edx)
  80078a:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80078d:	39 cb                	cmp    %ecx,%ebx
  80078f:	75 f0                	jne    800781 <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800791:	89 f0                	mov    %esi,%eax
  800793:	5b                   	pop    %ebx
  800794:	5e                   	pop    %esi
  800795:	5d                   	pop    %ebp
  800796:	c3                   	ret    

00800797 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800797:	55                   	push   %ebp
  800798:	89 e5                	mov    %esp,%ebp
  80079a:	53                   	push   %ebx
  80079b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80079e:	8b 45 10             	mov    0x10(%ebp),%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007a1:	85 c0                	test   %eax,%eax
  8007a3:	74 30                	je     8007d5 <strlcpy+0x3e>
		while (--size > 0 && *src != '\0')
  8007a5:	48                   	dec    %eax
  8007a6:	74 20                	je     8007c8 <strlcpy+0x31>
  8007a8:	8a 0b                	mov    (%ebx),%cl
  8007aa:	84 c9                	test   %cl,%cl
  8007ac:	74 1f                	je     8007cd <strlcpy+0x36>
  8007ae:	8d 53 01             	lea    0x1(%ebx),%edx
  8007b1:	01 c3                	add    %eax,%ebx
  8007b3:	8b 45 08             	mov    0x8(%ebp),%eax
			*dst++ = *src++;
  8007b6:	40                   	inc    %eax
  8007b7:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007ba:	39 da                	cmp    %ebx,%edx
  8007bc:	74 12                	je     8007d0 <strlcpy+0x39>
  8007be:	42                   	inc    %edx
  8007bf:	8a 4a ff             	mov    -0x1(%edx),%cl
  8007c2:	84 c9                	test   %cl,%cl
  8007c4:	75 f0                	jne    8007b6 <strlcpy+0x1f>
  8007c6:	eb 08                	jmp    8007d0 <strlcpy+0x39>
  8007c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8007cb:	eb 03                	jmp    8007d0 <strlcpy+0x39>
  8007cd:	8b 45 08             	mov    0x8(%ebp),%eax
			*dst++ = *src++;
		*dst = '\0';
  8007d0:	c6 00 00             	movb   $0x0,(%eax)
  8007d3:	eb 03                	jmp    8007d8 <strlcpy+0x41>
  8007d5:	8b 45 08             	mov    0x8(%ebp),%eax
	}
	return dst - dst_in;
  8007d8:	2b 45 08             	sub    0x8(%ebp),%eax
}
  8007db:	5b                   	pop    %ebx
  8007dc:	5d                   	pop    %ebp
  8007dd:	c3                   	ret    

008007de <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007de:	55                   	push   %ebp
  8007df:	89 e5                	mov    %esp,%ebp
  8007e1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007e4:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007e7:	8a 01                	mov    (%ecx),%al
  8007e9:	84 c0                	test   %al,%al
  8007eb:	74 10                	je     8007fd <strcmp+0x1f>
  8007ed:	3a 02                	cmp    (%edx),%al
  8007ef:	75 0c                	jne    8007fd <strcmp+0x1f>
		p++, q++;
  8007f1:	41                   	inc    %ecx
  8007f2:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007f3:	8a 01                	mov    (%ecx),%al
  8007f5:	84 c0                	test   %al,%al
  8007f7:	74 04                	je     8007fd <strcmp+0x1f>
  8007f9:	3a 02                	cmp    (%edx),%al
  8007fb:	74 f4                	je     8007f1 <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007fd:	0f b6 c0             	movzbl %al,%eax
  800800:	0f b6 12             	movzbl (%edx),%edx
  800803:	29 d0                	sub    %edx,%eax
}
  800805:	5d                   	pop    %ebp
  800806:	c3                   	ret    

00800807 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800807:	55                   	push   %ebp
  800808:	89 e5                	mov    %esp,%ebp
  80080a:	56                   	push   %esi
  80080b:	53                   	push   %ebx
  80080c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80080f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800812:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  800815:	85 f6                	test   %esi,%esi
  800817:	74 23                	je     80083c <strncmp+0x35>
  800819:	8a 03                	mov    (%ebx),%al
  80081b:	84 c0                	test   %al,%al
  80081d:	74 2b                	je     80084a <strncmp+0x43>
  80081f:	3a 02                	cmp    (%edx),%al
  800821:	75 27                	jne    80084a <strncmp+0x43>
  800823:	8d 43 01             	lea    0x1(%ebx),%eax
  800826:	01 de                	add    %ebx,%esi
		n--, p++, q++;
  800828:	89 c3                	mov    %eax,%ebx
  80082a:	42                   	inc    %edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80082b:	39 c6                	cmp    %eax,%esi
  80082d:	74 14                	je     800843 <strncmp+0x3c>
  80082f:	8a 08                	mov    (%eax),%cl
  800831:	84 c9                	test   %cl,%cl
  800833:	74 15                	je     80084a <strncmp+0x43>
  800835:	40                   	inc    %eax
  800836:	3a 0a                	cmp    (%edx),%cl
  800838:	74 ee                	je     800828 <strncmp+0x21>
  80083a:	eb 0e                	jmp    80084a <strncmp+0x43>
		n--, p++, q++;
	if (n == 0)
		return 0;
  80083c:	b8 00 00 00 00       	mov    $0x0,%eax
  800841:	eb 0f                	jmp    800852 <strncmp+0x4b>
  800843:	b8 00 00 00 00       	mov    $0x0,%eax
  800848:	eb 08                	jmp    800852 <strncmp+0x4b>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80084a:	0f b6 03             	movzbl (%ebx),%eax
  80084d:	0f b6 12             	movzbl (%edx),%edx
  800850:	29 d0                	sub    %edx,%eax
}
  800852:	5b                   	pop    %ebx
  800853:	5e                   	pop    %esi
  800854:	5d                   	pop    %ebp
  800855:	c3                   	ret    

00800856 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800856:	55                   	push   %ebp
  800857:	89 e5                	mov    %esp,%ebp
  800859:	53                   	push   %ebx
  80085a:	8b 45 08             	mov    0x8(%ebp),%eax
  80085d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  800860:	8a 10                	mov    (%eax),%dl
  800862:	84 d2                	test   %dl,%dl
  800864:	74 1a                	je     800880 <strchr+0x2a>
  800866:	88 d9                	mov    %bl,%cl
		if (*s == c)
  800868:	38 d3                	cmp    %dl,%bl
  80086a:	75 06                	jne    800872 <strchr+0x1c>
  80086c:	eb 17                	jmp    800885 <strchr+0x2f>
  80086e:	38 ca                	cmp    %cl,%dl
  800870:	74 13                	je     800885 <strchr+0x2f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800872:	40                   	inc    %eax
  800873:	8a 10                	mov    (%eax),%dl
  800875:	84 d2                	test   %dl,%dl
  800877:	75 f5                	jne    80086e <strchr+0x18>
		if (*s == c)
			return (char *) s;
	return 0;
  800879:	b8 00 00 00 00       	mov    $0x0,%eax
  80087e:	eb 05                	jmp    800885 <strchr+0x2f>
  800880:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800885:	5b                   	pop    %ebx
  800886:	5d                   	pop    %ebp
  800887:	c3                   	ret    

00800888 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800888:	55                   	push   %ebp
  800889:	89 e5                	mov    %esp,%ebp
  80088b:	53                   	push   %ebx
  80088c:	8b 45 08             	mov    0x8(%ebp),%eax
  80088f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  800892:	8a 10                	mov    (%eax),%dl
  800894:	84 d2                	test   %dl,%dl
  800896:	74 13                	je     8008ab <strfind+0x23>
  800898:	88 d9                	mov    %bl,%cl
		if (*s == c)
  80089a:	38 d3                	cmp    %dl,%bl
  80089c:	75 06                	jne    8008a4 <strfind+0x1c>
  80089e:	eb 0b                	jmp    8008ab <strfind+0x23>
  8008a0:	38 ca                	cmp    %cl,%dl
  8008a2:	74 07                	je     8008ab <strfind+0x23>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8008a4:	40                   	inc    %eax
  8008a5:	8a 10                	mov    (%eax),%dl
  8008a7:	84 d2                	test   %dl,%dl
  8008a9:	75 f5                	jne    8008a0 <strfind+0x18>
		if (*s == c)
			break;
	return (char *) s;
}
  8008ab:	5b                   	pop    %ebx
  8008ac:	5d                   	pop    %ebp
  8008ad:	c3                   	ret    

008008ae <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008ae:	55                   	push   %ebp
  8008af:	89 e5                	mov    %esp,%ebp
  8008b1:	57                   	push   %edi
  8008b2:	56                   	push   %esi
  8008b3:	53                   	push   %ebx
  8008b4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008b7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008ba:	85 c9                	test   %ecx,%ecx
  8008bc:	74 36                	je     8008f4 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008be:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008c4:	75 28                	jne    8008ee <memset+0x40>
  8008c6:	f6 c1 03             	test   $0x3,%cl
  8008c9:	75 23                	jne    8008ee <memset+0x40>
		c &= 0xFF;
  8008cb:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008cf:	89 d3                	mov    %edx,%ebx
  8008d1:	c1 e3 08             	shl    $0x8,%ebx
  8008d4:	89 d6                	mov    %edx,%esi
  8008d6:	c1 e6 18             	shl    $0x18,%esi
  8008d9:	89 d0                	mov    %edx,%eax
  8008db:	c1 e0 10             	shl    $0x10,%eax
  8008de:	09 f0                	or     %esi,%eax
  8008e0:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8008e2:	89 d8                	mov    %ebx,%eax
  8008e4:	09 d0                	or     %edx,%eax
  8008e6:	c1 e9 02             	shr    $0x2,%ecx
  8008e9:	fc                   	cld    
  8008ea:	f3 ab                	rep stos %eax,%es:(%edi)
  8008ec:	eb 06                	jmp    8008f4 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008ee:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008f1:	fc                   	cld    
  8008f2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008f4:	89 f8                	mov    %edi,%eax
  8008f6:	5b                   	pop    %ebx
  8008f7:	5e                   	pop    %esi
  8008f8:	5f                   	pop    %edi
  8008f9:	5d                   	pop    %ebp
  8008fa:	c3                   	ret    

008008fb <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008fb:	55                   	push   %ebp
  8008fc:	89 e5                	mov    %esp,%ebp
  8008fe:	57                   	push   %edi
  8008ff:	56                   	push   %esi
  800900:	8b 45 08             	mov    0x8(%ebp),%eax
  800903:	8b 75 0c             	mov    0xc(%ebp),%esi
  800906:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800909:	39 c6                	cmp    %eax,%esi
  80090b:	73 33                	jae    800940 <memmove+0x45>
  80090d:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800910:	39 d0                	cmp    %edx,%eax
  800912:	73 2c                	jae    800940 <memmove+0x45>
		s += n;
		d += n;
  800914:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800917:	89 d6                	mov    %edx,%esi
  800919:	09 fe                	or     %edi,%esi
  80091b:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800921:	75 13                	jne    800936 <memmove+0x3b>
  800923:	f6 c1 03             	test   $0x3,%cl
  800926:	75 0e                	jne    800936 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800928:	83 ef 04             	sub    $0x4,%edi
  80092b:	8d 72 fc             	lea    -0x4(%edx),%esi
  80092e:	c1 e9 02             	shr    $0x2,%ecx
  800931:	fd                   	std    
  800932:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800934:	eb 07                	jmp    80093d <memmove+0x42>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800936:	4f                   	dec    %edi
  800937:	8d 72 ff             	lea    -0x1(%edx),%esi
  80093a:	fd                   	std    
  80093b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80093d:	fc                   	cld    
  80093e:	eb 1d                	jmp    80095d <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800940:	89 f2                	mov    %esi,%edx
  800942:	09 c2                	or     %eax,%edx
  800944:	f6 c2 03             	test   $0x3,%dl
  800947:	75 0f                	jne    800958 <memmove+0x5d>
  800949:	f6 c1 03             	test   $0x3,%cl
  80094c:	75 0a                	jne    800958 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
  80094e:	c1 e9 02             	shr    $0x2,%ecx
  800951:	89 c7                	mov    %eax,%edi
  800953:	fc                   	cld    
  800954:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800956:	eb 05                	jmp    80095d <memmove+0x62>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800958:	89 c7                	mov    %eax,%edi
  80095a:	fc                   	cld    
  80095b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80095d:	5e                   	pop    %esi
  80095e:	5f                   	pop    %edi
  80095f:	5d                   	pop    %ebp
  800960:	c3                   	ret    

00800961 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800961:	55                   	push   %ebp
  800962:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800964:	ff 75 10             	pushl  0x10(%ebp)
  800967:	ff 75 0c             	pushl  0xc(%ebp)
  80096a:	ff 75 08             	pushl  0x8(%ebp)
  80096d:	e8 89 ff ff ff       	call   8008fb <memmove>
}
  800972:	c9                   	leave  
  800973:	c3                   	ret    

00800974 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800974:	55                   	push   %ebp
  800975:	89 e5                	mov    %esp,%ebp
  800977:	57                   	push   %edi
  800978:	56                   	push   %esi
  800979:	53                   	push   %ebx
  80097a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80097d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800980:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800983:	85 c0                	test   %eax,%eax
  800985:	74 33                	je     8009ba <memcmp+0x46>
  800987:	8d 78 ff             	lea    -0x1(%eax),%edi
		if (*s1 != *s2)
  80098a:	8a 13                	mov    (%ebx),%dl
  80098c:	8a 0e                	mov    (%esi),%cl
  80098e:	38 ca                	cmp    %cl,%dl
  800990:	75 13                	jne    8009a5 <memcmp+0x31>
  800992:	b8 00 00 00 00       	mov    $0x0,%eax
  800997:	eb 16                	jmp    8009af <memcmp+0x3b>
  800999:	8a 54 03 01          	mov    0x1(%ebx,%eax,1),%dl
  80099d:	40                   	inc    %eax
  80099e:	8a 0c 06             	mov    (%esi,%eax,1),%cl
  8009a1:	38 ca                	cmp    %cl,%dl
  8009a3:	74 0a                	je     8009af <memcmp+0x3b>
			return (int) *s1 - (int) *s2;
  8009a5:	0f b6 c2             	movzbl %dl,%eax
  8009a8:	0f b6 c9             	movzbl %cl,%ecx
  8009ab:	29 c8                	sub    %ecx,%eax
  8009ad:	eb 10                	jmp    8009bf <memcmp+0x4b>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009af:	39 f8                	cmp    %edi,%eax
  8009b1:	75 e6                	jne    800999 <memcmp+0x25>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009b3:	b8 00 00 00 00       	mov    $0x0,%eax
  8009b8:	eb 05                	jmp    8009bf <memcmp+0x4b>
  8009ba:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009bf:	5b                   	pop    %ebx
  8009c0:	5e                   	pop    %esi
  8009c1:	5f                   	pop    %edi
  8009c2:	5d                   	pop    %ebp
  8009c3:	c3                   	ret    

008009c4 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009c4:	55                   	push   %ebp
  8009c5:	89 e5                	mov    %esp,%ebp
  8009c7:	53                   	push   %ebx
  8009c8:	8b 55 08             	mov    0x8(%ebp),%edx
	const void *ends = (const char *) s + n;
  8009cb:	89 d0                	mov    %edx,%eax
  8009cd:	03 45 10             	add    0x10(%ebp),%eax
	for (; s < ends; s++)
  8009d0:	39 c2                	cmp    %eax,%edx
  8009d2:	73 1b                	jae    8009ef <memfind+0x2b>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009d4:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
  8009d8:	0f b6 0a             	movzbl (%edx),%ecx
  8009db:	39 d9                	cmp    %ebx,%ecx
  8009dd:	75 09                	jne    8009e8 <memfind+0x24>
  8009df:	eb 12                	jmp    8009f3 <memfind+0x2f>
  8009e1:	0f b6 0a             	movzbl (%edx),%ecx
  8009e4:	39 d9                	cmp    %ebx,%ecx
  8009e6:	74 0f                	je     8009f7 <memfind+0x33>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009e8:	42                   	inc    %edx
  8009e9:	39 d0                	cmp    %edx,%eax
  8009eb:	75 f4                	jne    8009e1 <memfind+0x1d>
  8009ed:	eb 0a                	jmp    8009f9 <memfind+0x35>
  8009ef:	89 d0                	mov    %edx,%eax
  8009f1:	eb 06                	jmp    8009f9 <memfind+0x35>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009f3:	89 d0                	mov    %edx,%eax
  8009f5:	eb 02                	jmp    8009f9 <memfind+0x35>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009f7:	89 d0                	mov    %edx,%eax
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009f9:	5b                   	pop    %ebx
  8009fa:	5d                   	pop    %ebp
  8009fb:	c3                   	ret    

008009fc <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009fc:	55                   	push   %ebp
  8009fd:	89 e5                	mov    %esp,%ebp
  8009ff:	57                   	push   %edi
  800a00:	56                   	push   %esi
  800a01:	53                   	push   %ebx
  800a02:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a05:	eb 01                	jmp    800a08 <strtol+0xc>
		s++;
  800a07:	41                   	inc    %ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a08:	8a 01                	mov    (%ecx),%al
  800a0a:	3c 20                	cmp    $0x20,%al
  800a0c:	74 f9                	je     800a07 <strtol+0xb>
  800a0e:	3c 09                	cmp    $0x9,%al
  800a10:	74 f5                	je     800a07 <strtol+0xb>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a12:	3c 2b                	cmp    $0x2b,%al
  800a14:	75 08                	jne    800a1e <strtol+0x22>
		s++;
  800a16:	41                   	inc    %ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a17:	bf 00 00 00 00       	mov    $0x0,%edi
  800a1c:	eb 11                	jmp    800a2f <strtol+0x33>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a1e:	3c 2d                	cmp    $0x2d,%al
  800a20:	75 08                	jne    800a2a <strtol+0x2e>
		s++, neg = 1;
  800a22:	41                   	inc    %ecx
  800a23:	bf 01 00 00 00       	mov    $0x1,%edi
  800a28:	eb 05                	jmp    800a2f <strtol+0x33>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a2a:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a2f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800a33:	0f 84 87 00 00 00    	je     800ac0 <strtol+0xc4>
  800a39:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  800a3d:	75 27                	jne    800a66 <strtol+0x6a>
  800a3f:	80 39 30             	cmpb   $0x30,(%ecx)
  800a42:	75 22                	jne    800a66 <strtol+0x6a>
  800a44:	e9 88 00 00 00       	jmp    800ad1 <strtol+0xd5>
		s += 2, base = 16;
  800a49:	83 c1 02             	add    $0x2,%ecx
  800a4c:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  800a53:	eb 11                	jmp    800a66 <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
  800a55:	41                   	inc    %ecx
  800a56:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  800a5d:	eb 07                	jmp    800a66 <strtol+0x6a>
	else if (base == 0)
		base = 10;
  800a5f:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)
  800a66:	b8 00 00 00 00       	mov    $0x0,%eax

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a6b:	8a 11                	mov    (%ecx),%dl
  800a6d:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800a70:	80 fb 09             	cmp    $0x9,%bl
  800a73:	77 08                	ja     800a7d <strtol+0x81>
			dig = *s - '0';
  800a75:	0f be d2             	movsbl %dl,%edx
  800a78:	83 ea 30             	sub    $0x30,%edx
  800a7b:	eb 22                	jmp    800a9f <strtol+0xa3>
		else if (*s >= 'a' && *s <= 'z')
  800a7d:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a80:	89 f3                	mov    %esi,%ebx
  800a82:	80 fb 19             	cmp    $0x19,%bl
  800a85:	77 08                	ja     800a8f <strtol+0x93>
			dig = *s - 'a' + 10;
  800a87:	0f be d2             	movsbl %dl,%edx
  800a8a:	83 ea 57             	sub    $0x57,%edx
  800a8d:	eb 10                	jmp    800a9f <strtol+0xa3>
		else if (*s >= 'A' && *s <= 'Z')
  800a8f:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a92:	89 f3                	mov    %esi,%ebx
  800a94:	80 fb 19             	cmp    $0x19,%bl
  800a97:	77 14                	ja     800aad <strtol+0xb1>
			dig = *s - 'A' + 10;
  800a99:	0f be d2             	movsbl %dl,%edx
  800a9c:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a9f:	3b 55 10             	cmp    0x10(%ebp),%edx
  800aa2:	7d 09                	jge    800aad <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800aa4:	41                   	inc    %ecx
  800aa5:	0f af 45 10          	imul   0x10(%ebp),%eax
  800aa9:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800aab:	eb be                	jmp    800a6b <strtol+0x6f>

	if (endptr)
  800aad:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ab1:	74 05                	je     800ab8 <strtol+0xbc>
		*endptr = (char *) s;
  800ab3:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ab6:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800ab8:	85 ff                	test   %edi,%edi
  800aba:	74 21                	je     800add <strtol+0xe1>
  800abc:	f7 d8                	neg    %eax
  800abe:	eb 1d                	jmp    800add <strtol+0xe1>
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ac0:	80 39 30             	cmpb   $0x30,(%ecx)
  800ac3:	75 9a                	jne    800a5f <strtol+0x63>
  800ac5:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800ac9:	0f 84 7a ff ff ff    	je     800a49 <strtol+0x4d>
  800acf:	eb 84                	jmp    800a55 <strtol+0x59>
  800ad1:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800ad5:	0f 84 6e ff ff ff    	je     800a49 <strtol+0x4d>
  800adb:	eb 89                	jmp    800a66 <strtol+0x6a>
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
}
  800add:	5b                   	pop    %ebx
  800ade:	5e                   	pop    %esi
  800adf:	5f                   	pop    %edi
  800ae0:	5d                   	pop    %ebp
  800ae1:	c3                   	ret    

00800ae2 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ae2:	55                   	push   %ebp
  800ae3:	89 e5                	mov    %esp,%ebp
  800ae5:	57                   	push   %edi
  800ae6:	56                   	push   %esi
  800ae7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ae8:	b8 00 00 00 00       	mov    $0x0,%eax
  800aed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800af0:	8b 55 08             	mov    0x8(%ebp),%edx
  800af3:	89 c3                	mov    %eax,%ebx
  800af5:	89 c7                	mov    %eax,%edi
  800af7:	89 c6                	mov    %eax,%esi
  800af9:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800afb:	5b                   	pop    %ebx
  800afc:	5e                   	pop    %esi
  800afd:	5f                   	pop    %edi
  800afe:	5d                   	pop    %ebp
  800aff:	c3                   	ret    

00800b00 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b00:	55                   	push   %ebp
  800b01:	89 e5                	mov    %esp,%ebp
  800b03:	57                   	push   %edi
  800b04:	56                   	push   %esi
  800b05:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b06:	ba 00 00 00 00       	mov    $0x0,%edx
  800b0b:	b8 01 00 00 00       	mov    $0x1,%eax
  800b10:	89 d1                	mov    %edx,%ecx
  800b12:	89 d3                	mov    %edx,%ebx
  800b14:	89 d7                	mov    %edx,%edi
  800b16:	89 d6                	mov    %edx,%esi
  800b18:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b1a:	5b                   	pop    %ebx
  800b1b:	5e                   	pop    %esi
  800b1c:	5f                   	pop    %edi
  800b1d:	5d                   	pop    %ebp
  800b1e:	c3                   	ret    

00800b1f <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b1f:	55                   	push   %ebp
  800b20:	89 e5                	mov    %esp,%ebp
  800b22:	57                   	push   %edi
  800b23:	56                   	push   %esi
  800b24:	53                   	push   %ebx
  800b25:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b28:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b2d:	b8 03 00 00 00       	mov    $0x3,%eax
  800b32:	8b 55 08             	mov    0x8(%ebp),%edx
  800b35:	89 cb                	mov    %ecx,%ebx
  800b37:	89 cf                	mov    %ecx,%edi
  800b39:	89 ce                	mov    %ecx,%esi
  800b3b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b3d:	85 c0                	test   %eax,%eax
  800b3f:	7e 17                	jle    800b58 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b41:	83 ec 0c             	sub    $0xc,%esp
  800b44:	50                   	push   %eax
  800b45:	6a 03                	push   $0x3
  800b47:	68 9f 21 80 00       	push   $0x80219f
  800b4c:	6a 23                	push   $0x23
  800b4e:	68 bc 21 80 00       	push   $0x8021bc
  800b53:	e8 cf 0e 00 00       	call   801a27 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b58:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b5b:	5b                   	pop    %ebx
  800b5c:	5e                   	pop    %esi
  800b5d:	5f                   	pop    %edi
  800b5e:	5d                   	pop    %ebp
  800b5f:	c3                   	ret    

00800b60 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b60:	55                   	push   %ebp
  800b61:	89 e5                	mov    %esp,%ebp
  800b63:	57                   	push   %edi
  800b64:	56                   	push   %esi
  800b65:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b66:	ba 00 00 00 00       	mov    $0x0,%edx
  800b6b:	b8 02 00 00 00       	mov    $0x2,%eax
  800b70:	89 d1                	mov    %edx,%ecx
  800b72:	89 d3                	mov    %edx,%ebx
  800b74:	89 d7                	mov    %edx,%edi
  800b76:	89 d6                	mov    %edx,%esi
  800b78:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b7a:	5b                   	pop    %ebx
  800b7b:	5e                   	pop    %esi
  800b7c:	5f                   	pop    %edi
  800b7d:	5d                   	pop    %ebp
  800b7e:	c3                   	ret    

00800b7f <sys_yield>:

void
sys_yield(void)
{
  800b7f:	55                   	push   %ebp
  800b80:	89 e5                	mov    %esp,%ebp
  800b82:	57                   	push   %edi
  800b83:	56                   	push   %esi
  800b84:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b85:	ba 00 00 00 00       	mov    $0x0,%edx
  800b8a:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b8f:	89 d1                	mov    %edx,%ecx
  800b91:	89 d3                	mov    %edx,%ebx
  800b93:	89 d7                	mov    %edx,%edi
  800b95:	89 d6                	mov    %edx,%esi
  800b97:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b99:	5b                   	pop    %ebx
  800b9a:	5e                   	pop    %esi
  800b9b:	5f                   	pop    %edi
  800b9c:	5d                   	pop    %ebp
  800b9d:	c3                   	ret    

00800b9e <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b9e:	55                   	push   %ebp
  800b9f:	89 e5                	mov    %esp,%ebp
  800ba1:	57                   	push   %edi
  800ba2:	56                   	push   %esi
  800ba3:	53                   	push   %ebx
  800ba4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba7:	be 00 00 00 00       	mov    $0x0,%esi
  800bac:	b8 04 00 00 00       	mov    $0x4,%eax
  800bb1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bb4:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bba:	89 f7                	mov    %esi,%edi
  800bbc:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bbe:	85 c0                	test   %eax,%eax
  800bc0:	7e 17                	jle    800bd9 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bc2:	83 ec 0c             	sub    $0xc,%esp
  800bc5:	50                   	push   %eax
  800bc6:	6a 04                	push   $0x4
  800bc8:	68 9f 21 80 00       	push   $0x80219f
  800bcd:	6a 23                	push   $0x23
  800bcf:	68 bc 21 80 00       	push   $0x8021bc
  800bd4:	e8 4e 0e 00 00       	call   801a27 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bd9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bdc:	5b                   	pop    %ebx
  800bdd:	5e                   	pop    %esi
  800bde:	5f                   	pop    %edi
  800bdf:	5d                   	pop    %ebp
  800be0:	c3                   	ret    

00800be1 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800be1:	55                   	push   %ebp
  800be2:	89 e5                	mov    %esp,%ebp
  800be4:	57                   	push   %edi
  800be5:	56                   	push   %esi
  800be6:	53                   	push   %ebx
  800be7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bea:	b8 05 00 00 00       	mov    $0x5,%eax
  800bef:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bf2:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bf8:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bfb:	8b 75 18             	mov    0x18(%ebp),%esi
  800bfe:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c00:	85 c0                	test   %eax,%eax
  800c02:	7e 17                	jle    800c1b <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c04:	83 ec 0c             	sub    $0xc,%esp
  800c07:	50                   	push   %eax
  800c08:	6a 05                	push   $0x5
  800c0a:	68 9f 21 80 00       	push   $0x80219f
  800c0f:	6a 23                	push   $0x23
  800c11:	68 bc 21 80 00       	push   $0x8021bc
  800c16:	e8 0c 0e 00 00       	call   801a27 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c1b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c1e:	5b                   	pop    %ebx
  800c1f:	5e                   	pop    %esi
  800c20:	5f                   	pop    %edi
  800c21:	5d                   	pop    %ebp
  800c22:	c3                   	ret    

00800c23 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c23:	55                   	push   %ebp
  800c24:	89 e5                	mov    %esp,%ebp
  800c26:	57                   	push   %edi
  800c27:	56                   	push   %esi
  800c28:	53                   	push   %ebx
  800c29:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c2c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c31:	b8 06 00 00 00       	mov    $0x6,%eax
  800c36:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c39:	8b 55 08             	mov    0x8(%ebp),%edx
  800c3c:	89 df                	mov    %ebx,%edi
  800c3e:	89 de                	mov    %ebx,%esi
  800c40:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c42:	85 c0                	test   %eax,%eax
  800c44:	7e 17                	jle    800c5d <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c46:	83 ec 0c             	sub    $0xc,%esp
  800c49:	50                   	push   %eax
  800c4a:	6a 06                	push   $0x6
  800c4c:	68 9f 21 80 00       	push   $0x80219f
  800c51:	6a 23                	push   $0x23
  800c53:	68 bc 21 80 00       	push   $0x8021bc
  800c58:	e8 ca 0d 00 00       	call   801a27 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c5d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c60:	5b                   	pop    %ebx
  800c61:	5e                   	pop    %esi
  800c62:	5f                   	pop    %edi
  800c63:	5d                   	pop    %ebp
  800c64:	c3                   	ret    

00800c65 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c65:	55                   	push   %ebp
  800c66:	89 e5                	mov    %esp,%ebp
  800c68:	57                   	push   %edi
  800c69:	56                   	push   %esi
  800c6a:	53                   	push   %ebx
  800c6b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c6e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c73:	b8 08 00 00 00       	mov    $0x8,%eax
  800c78:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c7b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c7e:	89 df                	mov    %ebx,%edi
  800c80:	89 de                	mov    %ebx,%esi
  800c82:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c84:	85 c0                	test   %eax,%eax
  800c86:	7e 17                	jle    800c9f <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c88:	83 ec 0c             	sub    $0xc,%esp
  800c8b:	50                   	push   %eax
  800c8c:	6a 08                	push   $0x8
  800c8e:	68 9f 21 80 00       	push   $0x80219f
  800c93:	6a 23                	push   $0x23
  800c95:	68 bc 21 80 00       	push   $0x8021bc
  800c9a:	e8 88 0d 00 00       	call   801a27 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c9f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ca2:	5b                   	pop    %ebx
  800ca3:	5e                   	pop    %esi
  800ca4:	5f                   	pop    %edi
  800ca5:	5d                   	pop    %ebp
  800ca6:	c3                   	ret    

00800ca7 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800ca7:	55                   	push   %ebp
  800ca8:	89 e5                	mov    %esp,%ebp
  800caa:	57                   	push   %edi
  800cab:	56                   	push   %esi
  800cac:	53                   	push   %ebx
  800cad:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cb0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cb5:	b8 09 00 00 00       	mov    $0x9,%eax
  800cba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cbd:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc0:	89 df                	mov    %ebx,%edi
  800cc2:	89 de                	mov    %ebx,%esi
  800cc4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cc6:	85 c0                	test   %eax,%eax
  800cc8:	7e 17                	jle    800ce1 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cca:	83 ec 0c             	sub    $0xc,%esp
  800ccd:	50                   	push   %eax
  800cce:	6a 09                	push   $0x9
  800cd0:	68 9f 21 80 00       	push   $0x80219f
  800cd5:	6a 23                	push   $0x23
  800cd7:	68 bc 21 80 00       	push   $0x8021bc
  800cdc:	e8 46 0d 00 00       	call   801a27 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800ce1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ce4:	5b                   	pop    %ebx
  800ce5:	5e                   	pop    %esi
  800ce6:	5f                   	pop    %edi
  800ce7:	5d                   	pop    %ebp
  800ce8:	c3                   	ret    

00800ce9 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ce9:	55                   	push   %ebp
  800cea:	89 e5                	mov    %esp,%ebp
  800cec:	57                   	push   %edi
  800ced:	56                   	push   %esi
  800cee:	53                   	push   %ebx
  800cef:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cf2:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cf7:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cfc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cff:	8b 55 08             	mov    0x8(%ebp),%edx
  800d02:	89 df                	mov    %ebx,%edi
  800d04:	89 de                	mov    %ebx,%esi
  800d06:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d08:	85 c0                	test   %eax,%eax
  800d0a:	7e 17                	jle    800d23 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d0c:	83 ec 0c             	sub    $0xc,%esp
  800d0f:	50                   	push   %eax
  800d10:	6a 0a                	push   $0xa
  800d12:	68 9f 21 80 00       	push   $0x80219f
  800d17:	6a 23                	push   $0x23
  800d19:	68 bc 21 80 00       	push   $0x8021bc
  800d1e:	e8 04 0d 00 00       	call   801a27 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d23:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d26:	5b                   	pop    %ebx
  800d27:	5e                   	pop    %esi
  800d28:	5f                   	pop    %edi
  800d29:	5d                   	pop    %ebp
  800d2a:	c3                   	ret    

00800d2b <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d2b:	55                   	push   %ebp
  800d2c:	89 e5                	mov    %esp,%ebp
  800d2e:	57                   	push   %edi
  800d2f:	56                   	push   %esi
  800d30:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d31:	be 00 00 00 00       	mov    $0x0,%esi
  800d36:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d3b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d3e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d41:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d44:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d47:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d49:	5b                   	pop    %ebx
  800d4a:	5e                   	pop    %esi
  800d4b:	5f                   	pop    %edi
  800d4c:	5d                   	pop    %ebp
  800d4d:	c3                   	ret    

00800d4e <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
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
  800d57:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d5c:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d61:	8b 55 08             	mov    0x8(%ebp),%edx
  800d64:	89 cb                	mov    %ecx,%ebx
  800d66:	89 cf                	mov    %ecx,%edi
  800d68:	89 ce                	mov    %ecx,%esi
  800d6a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d6c:	85 c0                	test   %eax,%eax
  800d6e:	7e 17                	jle    800d87 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d70:	83 ec 0c             	sub    $0xc,%esp
  800d73:	50                   	push   %eax
  800d74:	6a 0d                	push   $0xd
  800d76:	68 9f 21 80 00       	push   $0x80219f
  800d7b:	6a 23                	push   $0x23
  800d7d:	68 bc 21 80 00       	push   $0x8021bc
  800d82:	e8 a0 0c 00 00       	call   801a27 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d87:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d8a:	5b                   	pop    %ebx
  800d8b:	5e                   	pop    %esi
  800d8c:	5f                   	pop    %edi
  800d8d:	5d                   	pop    %ebp
  800d8e:	c3                   	ret    

00800d8f <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800d8f:	55                   	push   %ebp
  800d90:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d92:	8b 45 08             	mov    0x8(%ebp),%eax
  800d95:	05 00 00 00 30       	add    $0x30000000,%eax
  800d9a:	c1 e8 0c             	shr    $0xc,%eax
}
  800d9d:	5d                   	pop    %ebp
  800d9e:	c3                   	ret    

00800d9f <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800d9f:	55                   	push   %ebp
  800da0:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800da2:	8b 45 08             	mov    0x8(%ebp),%eax
  800da5:	05 00 00 00 30       	add    $0x30000000,%eax
  800daa:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800daf:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800db4:	5d                   	pop    %ebp
  800db5:	c3                   	ret    

00800db6 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800db6:	55                   	push   %ebp
  800db7:	89 e5                	mov    %esp,%ebp
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800db9:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  800dbe:	a8 01                	test   $0x1,%al
  800dc0:	74 34                	je     800df6 <fd_alloc+0x40>
  800dc2:	a1 00 00 74 ef       	mov    0xef740000,%eax
  800dc7:	a8 01                	test   $0x1,%al
  800dc9:	74 32                	je     800dfd <fd_alloc+0x47>
  800dcb:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800dd0:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800dd2:	89 c2                	mov    %eax,%edx
  800dd4:	c1 ea 16             	shr    $0x16,%edx
  800dd7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800dde:	f6 c2 01             	test   $0x1,%dl
  800de1:	74 1f                	je     800e02 <fd_alloc+0x4c>
  800de3:	89 c2                	mov    %eax,%edx
  800de5:	c1 ea 0c             	shr    $0xc,%edx
  800de8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800def:	f6 c2 01             	test   $0x1,%dl
  800df2:	75 1a                	jne    800e0e <fd_alloc+0x58>
  800df4:	eb 0c                	jmp    800e02 <fd_alloc+0x4c>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800df6:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  800dfb:	eb 05                	jmp    800e02 <fd_alloc+0x4c>
  800dfd:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  800e02:	8b 45 08             	mov    0x8(%ebp),%eax
  800e05:	89 08                	mov    %ecx,(%eax)
			return 0;
  800e07:	b8 00 00 00 00       	mov    $0x0,%eax
  800e0c:	eb 1a                	jmp    800e28 <fd_alloc+0x72>
  800e0e:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800e13:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e18:	75 b6                	jne    800dd0 <fd_alloc+0x1a>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800e1a:	8b 45 08             	mov    0x8(%ebp),%eax
  800e1d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  800e23:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800e28:	5d                   	pop    %ebp
  800e29:	c3                   	ret    

00800e2a <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e2a:	55                   	push   %ebp
  800e2b:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e2d:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
  800e31:	77 39                	ja     800e6c <fd_lookup+0x42>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e33:	8b 45 08             	mov    0x8(%ebp),%eax
  800e36:	c1 e0 0c             	shl    $0xc,%eax
  800e39:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e3e:	89 c2                	mov    %eax,%edx
  800e40:	c1 ea 16             	shr    $0x16,%edx
  800e43:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e4a:	f6 c2 01             	test   $0x1,%dl
  800e4d:	74 24                	je     800e73 <fd_lookup+0x49>
  800e4f:	89 c2                	mov    %eax,%edx
  800e51:	c1 ea 0c             	shr    $0xc,%edx
  800e54:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e5b:	f6 c2 01             	test   $0x1,%dl
  800e5e:	74 1a                	je     800e7a <fd_lookup+0x50>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800e60:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e63:	89 02                	mov    %eax,(%edx)
	return 0;
  800e65:	b8 00 00 00 00       	mov    $0x0,%eax
  800e6a:	eb 13                	jmp    800e7f <fd_lookup+0x55>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e6c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e71:	eb 0c                	jmp    800e7f <fd_lookup+0x55>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e73:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e78:	eb 05                	jmp    800e7f <fd_lookup+0x55>
  800e7a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800e7f:	5d                   	pop    %ebp
  800e80:	c3                   	ret    

00800e81 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800e81:	55                   	push   %ebp
  800e82:	89 e5                	mov    %esp,%ebp
  800e84:	53                   	push   %ebx
  800e85:	83 ec 04             	sub    $0x4,%esp
  800e88:	8b 45 08             	mov    0x8(%ebp),%eax
  800e8b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  800e8e:	3b 05 04 30 80 00    	cmp    0x803004,%eax
  800e94:	75 1e                	jne    800eb4 <dev_lookup+0x33>
  800e96:	eb 0e                	jmp    800ea6 <dev_lookup+0x25>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800e98:	b8 20 30 80 00       	mov    $0x803020,%eax
  800e9d:	eb 0c                	jmp    800eab <dev_lookup+0x2a>
  800e9f:	b8 3c 30 80 00       	mov    $0x80303c,%eax
  800ea4:	eb 05                	jmp    800eab <dev_lookup+0x2a>
  800ea6:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  800eab:	89 03                	mov    %eax,(%ebx)
			return 0;
  800ead:	b8 00 00 00 00       	mov    $0x0,%eax
  800eb2:	eb 36                	jmp    800eea <dev_lookup+0x69>
int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  800eb4:	3b 05 20 30 80 00    	cmp    0x803020,%eax
  800eba:	74 dc                	je     800e98 <dev_lookup+0x17>
  800ebc:	3b 05 3c 30 80 00    	cmp    0x80303c,%eax
  800ec2:	74 db                	je     800e9f <dev_lookup+0x1e>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800ec4:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800eca:	8b 52 48             	mov    0x48(%edx),%edx
  800ecd:	83 ec 04             	sub    $0x4,%esp
  800ed0:	50                   	push   %eax
  800ed1:	52                   	push   %edx
  800ed2:	68 cc 21 80 00       	push   $0x8021cc
  800ed7:	e8 6d f2 ff ff       	call   800149 <cprintf>
	*dev = 0;
  800edc:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  800ee2:	83 c4 10             	add    $0x10,%esp
  800ee5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800eea:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800eed:	c9                   	leave  
  800eee:	c3                   	ret    

00800eef <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800eef:	55                   	push   %ebp
  800ef0:	89 e5                	mov    %esp,%ebp
  800ef2:	56                   	push   %esi
  800ef3:	53                   	push   %ebx
  800ef4:	83 ec 10             	sub    $0x10,%esp
  800ef7:	8b 75 08             	mov    0x8(%ebp),%esi
  800efa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800efd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f00:	50                   	push   %eax
  800f01:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800f07:	c1 e8 0c             	shr    $0xc,%eax
  800f0a:	50                   	push   %eax
  800f0b:	e8 1a ff ff ff       	call   800e2a <fd_lookup>
  800f10:	83 c4 08             	add    $0x8,%esp
  800f13:	85 c0                	test   %eax,%eax
  800f15:	78 05                	js     800f1c <fd_close+0x2d>
	    || fd != fd2)
  800f17:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800f1a:	74 06                	je     800f22 <fd_close+0x33>
		return (must_exist ? r : 0);
  800f1c:	84 db                	test   %bl,%bl
  800f1e:	74 47                	je     800f67 <fd_close+0x78>
  800f20:	eb 4a                	jmp    800f6c <fd_close+0x7d>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f22:	83 ec 08             	sub    $0x8,%esp
  800f25:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800f28:	50                   	push   %eax
  800f29:	ff 36                	pushl  (%esi)
  800f2b:	e8 51 ff ff ff       	call   800e81 <dev_lookup>
  800f30:	89 c3                	mov    %eax,%ebx
  800f32:	83 c4 10             	add    $0x10,%esp
  800f35:	85 c0                	test   %eax,%eax
  800f37:	78 1c                	js     800f55 <fd_close+0x66>
		if (dev->dev_close)
  800f39:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f3c:	8b 40 10             	mov    0x10(%eax),%eax
  800f3f:	85 c0                	test   %eax,%eax
  800f41:	74 0d                	je     800f50 <fd_close+0x61>
			r = (*dev->dev_close)(fd);
  800f43:	83 ec 0c             	sub    $0xc,%esp
  800f46:	56                   	push   %esi
  800f47:	ff d0                	call   *%eax
  800f49:	89 c3                	mov    %eax,%ebx
  800f4b:	83 c4 10             	add    $0x10,%esp
  800f4e:	eb 05                	jmp    800f55 <fd_close+0x66>
		else
			r = 0;
  800f50:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800f55:	83 ec 08             	sub    $0x8,%esp
  800f58:	56                   	push   %esi
  800f59:	6a 00                	push   $0x0
  800f5b:	e8 c3 fc ff ff       	call   800c23 <sys_page_unmap>
	return r;
  800f60:	83 c4 10             	add    $0x10,%esp
  800f63:	89 d8                	mov    %ebx,%eax
  800f65:	eb 05                	jmp    800f6c <fd_close+0x7d>
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
  800f67:	b8 00 00 00 00       	mov    $0x0,%eax
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
	return r;
}
  800f6c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f6f:	5b                   	pop    %ebx
  800f70:	5e                   	pop    %esi
  800f71:	5d                   	pop    %ebp
  800f72:	c3                   	ret    

00800f73 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800f73:	55                   	push   %ebp
  800f74:	89 e5                	mov    %esp,%ebp
  800f76:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f79:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f7c:	50                   	push   %eax
  800f7d:	ff 75 08             	pushl  0x8(%ebp)
  800f80:	e8 a5 fe ff ff       	call   800e2a <fd_lookup>
  800f85:	83 c4 08             	add    $0x8,%esp
  800f88:	85 c0                	test   %eax,%eax
  800f8a:	78 10                	js     800f9c <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800f8c:	83 ec 08             	sub    $0x8,%esp
  800f8f:	6a 01                	push   $0x1
  800f91:	ff 75 f4             	pushl  -0xc(%ebp)
  800f94:	e8 56 ff ff ff       	call   800eef <fd_close>
  800f99:	83 c4 10             	add    $0x10,%esp
}
  800f9c:	c9                   	leave  
  800f9d:	c3                   	ret    

00800f9e <close_all>:

void
close_all(void)
{
  800f9e:	55                   	push   %ebp
  800f9f:	89 e5                	mov    %esp,%ebp
  800fa1:	53                   	push   %ebx
  800fa2:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800fa5:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800faa:	83 ec 0c             	sub    $0xc,%esp
  800fad:	53                   	push   %ebx
  800fae:	e8 c0 ff ff ff       	call   800f73 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800fb3:	43                   	inc    %ebx
  800fb4:	83 c4 10             	add    $0x10,%esp
  800fb7:	83 fb 20             	cmp    $0x20,%ebx
  800fba:	75 ee                	jne    800faa <close_all+0xc>
		close(i);
}
  800fbc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fbf:	c9                   	leave  
  800fc0:	c3                   	ret    

00800fc1 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800fc1:	55                   	push   %ebp
  800fc2:	89 e5                	mov    %esp,%ebp
  800fc4:	57                   	push   %edi
  800fc5:	56                   	push   %esi
  800fc6:	53                   	push   %ebx
  800fc7:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800fca:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800fcd:	50                   	push   %eax
  800fce:	ff 75 08             	pushl  0x8(%ebp)
  800fd1:	e8 54 fe ff ff       	call   800e2a <fd_lookup>
  800fd6:	83 c4 08             	add    $0x8,%esp
  800fd9:	85 c0                	test   %eax,%eax
  800fdb:	0f 88 c2 00 00 00    	js     8010a3 <dup+0xe2>
		return r;
	close(newfdnum);
  800fe1:	83 ec 0c             	sub    $0xc,%esp
  800fe4:	ff 75 0c             	pushl  0xc(%ebp)
  800fe7:	e8 87 ff ff ff       	call   800f73 <close>

	newfd = INDEX2FD(newfdnum);
  800fec:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800fef:	c1 e3 0c             	shl    $0xc,%ebx
  800ff2:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800ff8:	83 c4 04             	add    $0x4,%esp
  800ffb:	ff 75 e4             	pushl  -0x1c(%ebp)
  800ffe:	e8 9c fd ff ff       	call   800d9f <fd2data>
  801003:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  801005:	89 1c 24             	mov    %ebx,(%esp)
  801008:	e8 92 fd ff ff       	call   800d9f <fd2data>
  80100d:	83 c4 10             	add    $0x10,%esp
  801010:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801012:	89 f0                	mov    %esi,%eax
  801014:	c1 e8 16             	shr    $0x16,%eax
  801017:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80101e:	a8 01                	test   $0x1,%al
  801020:	74 35                	je     801057 <dup+0x96>
  801022:	89 f0                	mov    %esi,%eax
  801024:	c1 e8 0c             	shr    $0xc,%eax
  801027:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80102e:	f6 c2 01             	test   $0x1,%dl
  801031:	74 24                	je     801057 <dup+0x96>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801033:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80103a:	83 ec 0c             	sub    $0xc,%esp
  80103d:	25 07 0e 00 00       	and    $0xe07,%eax
  801042:	50                   	push   %eax
  801043:	57                   	push   %edi
  801044:	6a 00                	push   $0x0
  801046:	56                   	push   %esi
  801047:	6a 00                	push   $0x0
  801049:	e8 93 fb ff ff       	call   800be1 <sys_page_map>
  80104e:	89 c6                	mov    %eax,%esi
  801050:	83 c4 20             	add    $0x20,%esp
  801053:	85 c0                	test   %eax,%eax
  801055:	78 2c                	js     801083 <dup+0xc2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801057:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80105a:	89 d0                	mov    %edx,%eax
  80105c:	c1 e8 0c             	shr    $0xc,%eax
  80105f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801066:	83 ec 0c             	sub    $0xc,%esp
  801069:	25 07 0e 00 00       	and    $0xe07,%eax
  80106e:	50                   	push   %eax
  80106f:	53                   	push   %ebx
  801070:	6a 00                	push   $0x0
  801072:	52                   	push   %edx
  801073:	6a 00                	push   $0x0
  801075:	e8 67 fb ff ff       	call   800be1 <sys_page_map>
  80107a:	89 c6                	mov    %eax,%esi
  80107c:	83 c4 20             	add    $0x20,%esp
  80107f:	85 c0                	test   %eax,%eax
  801081:	79 1d                	jns    8010a0 <dup+0xdf>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801083:	83 ec 08             	sub    $0x8,%esp
  801086:	53                   	push   %ebx
  801087:	6a 00                	push   $0x0
  801089:	e8 95 fb ff ff       	call   800c23 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80108e:	83 c4 08             	add    $0x8,%esp
  801091:	57                   	push   %edi
  801092:	6a 00                	push   $0x0
  801094:	e8 8a fb ff ff       	call   800c23 <sys_page_unmap>
	return r;
  801099:	83 c4 10             	add    $0x10,%esp
  80109c:	89 f0                	mov    %esi,%eax
  80109e:	eb 03                	jmp    8010a3 <dup+0xe2>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  8010a0:	8b 45 0c             	mov    0xc(%ebp),%eax

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8010a3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010a6:	5b                   	pop    %ebx
  8010a7:	5e                   	pop    %esi
  8010a8:	5f                   	pop    %edi
  8010a9:	5d                   	pop    %ebp
  8010aa:	c3                   	ret    

008010ab <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8010ab:	55                   	push   %ebp
  8010ac:	89 e5                	mov    %esp,%ebp
  8010ae:	53                   	push   %ebx
  8010af:	83 ec 14             	sub    $0x14,%esp
  8010b2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010b5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010b8:	50                   	push   %eax
  8010b9:	53                   	push   %ebx
  8010ba:	e8 6b fd ff ff       	call   800e2a <fd_lookup>
  8010bf:	83 c4 08             	add    $0x8,%esp
  8010c2:	85 c0                	test   %eax,%eax
  8010c4:	78 67                	js     80112d <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010c6:	83 ec 08             	sub    $0x8,%esp
  8010c9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010cc:	50                   	push   %eax
  8010cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010d0:	ff 30                	pushl  (%eax)
  8010d2:	e8 aa fd ff ff       	call   800e81 <dev_lookup>
  8010d7:	83 c4 10             	add    $0x10,%esp
  8010da:	85 c0                	test   %eax,%eax
  8010dc:	78 4f                	js     80112d <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8010de:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8010e1:	8b 42 08             	mov    0x8(%edx),%eax
  8010e4:	83 e0 03             	and    $0x3,%eax
  8010e7:	83 f8 01             	cmp    $0x1,%eax
  8010ea:	75 21                	jne    80110d <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8010ec:	a1 04 40 80 00       	mov    0x804004,%eax
  8010f1:	8b 40 48             	mov    0x48(%eax),%eax
  8010f4:	83 ec 04             	sub    $0x4,%esp
  8010f7:	53                   	push   %ebx
  8010f8:	50                   	push   %eax
  8010f9:	68 0d 22 80 00       	push   $0x80220d
  8010fe:	e8 46 f0 ff ff       	call   800149 <cprintf>
		return -E_INVAL;
  801103:	83 c4 10             	add    $0x10,%esp
  801106:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80110b:	eb 20                	jmp    80112d <read+0x82>
	}
	if (!dev->dev_read)
  80110d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801110:	8b 40 08             	mov    0x8(%eax),%eax
  801113:	85 c0                	test   %eax,%eax
  801115:	74 11                	je     801128 <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801117:	83 ec 04             	sub    $0x4,%esp
  80111a:	ff 75 10             	pushl  0x10(%ebp)
  80111d:	ff 75 0c             	pushl  0xc(%ebp)
  801120:	52                   	push   %edx
  801121:	ff d0                	call   *%eax
  801123:	83 c4 10             	add    $0x10,%esp
  801126:	eb 05                	jmp    80112d <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801128:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  80112d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801130:	c9                   	leave  
  801131:	c3                   	ret    

00801132 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801132:	55                   	push   %ebp
  801133:	89 e5                	mov    %esp,%ebp
  801135:	57                   	push   %edi
  801136:	56                   	push   %esi
  801137:	53                   	push   %ebx
  801138:	83 ec 0c             	sub    $0xc,%esp
  80113b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80113e:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801141:	85 f6                	test   %esi,%esi
  801143:	74 31                	je     801176 <readn+0x44>
  801145:	b8 00 00 00 00       	mov    $0x0,%eax
  80114a:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  80114f:	83 ec 04             	sub    $0x4,%esp
  801152:	89 f2                	mov    %esi,%edx
  801154:	29 c2                	sub    %eax,%edx
  801156:	52                   	push   %edx
  801157:	03 45 0c             	add    0xc(%ebp),%eax
  80115a:	50                   	push   %eax
  80115b:	57                   	push   %edi
  80115c:	e8 4a ff ff ff       	call   8010ab <read>
		if (m < 0)
  801161:	83 c4 10             	add    $0x10,%esp
  801164:	85 c0                	test   %eax,%eax
  801166:	78 17                	js     80117f <readn+0x4d>
			return m;
		if (m == 0)
  801168:	85 c0                	test   %eax,%eax
  80116a:	74 11                	je     80117d <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80116c:	01 c3                	add    %eax,%ebx
  80116e:	89 d8                	mov    %ebx,%eax
  801170:	39 f3                	cmp    %esi,%ebx
  801172:	72 db                	jb     80114f <readn+0x1d>
  801174:	eb 09                	jmp    80117f <readn+0x4d>
  801176:	b8 00 00 00 00       	mov    $0x0,%eax
  80117b:	eb 02                	jmp    80117f <readn+0x4d>
  80117d:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80117f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801182:	5b                   	pop    %ebx
  801183:	5e                   	pop    %esi
  801184:	5f                   	pop    %edi
  801185:	5d                   	pop    %ebp
  801186:	c3                   	ret    

00801187 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801187:	55                   	push   %ebp
  801188:	89 e5                	mov    %esp,%ebp
  80118a:	53                   	push   %ebx
  80118b:	83 ec 14             	sub    $0x14,%esp
  80118e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801191:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801194:	50                   	push   %eax
  801195:	53                   	push   %ebx
  801196:	e8 8f fc ff ff       	call   800e2a <fd_lookup>
  80119b:	83 c4 08             	add    $0x8,%esp
  80119e:	85 c0                	test   %eax,%eax
  8011a0:	78 62                	js     801204 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011a2:	83 ec 08             	sub    $0x8,%esp
  8011a5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011a8:	50                   	push   %eax
  8011a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011ac:	ff 30                	pushl  (%eax)
  8011ae:	e8 ce fc ff ff       	call   800e81 <dev_lookup>
  8011b3:	83 c4 10             	add    $0x10,%esp
  8011b6:	85 c0                	test   %eax,%eax
  8011b8:	78 4a                	js     801204 <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011bd:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011c1:	75 21                	jne    8011e4 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8011c3:	a1 04 40 80 00       	mov    0x804004,%eax
  8011c8:	8b 40 48             	mov    0x48(%eax),%eax
  8011cb:	83 ec 04             	sub    $0x4,%esp
  8011ce:	53                   	push   %ebx
  8011cf:	50                   	push   %eax
  8011d0:	68 29 22 80 00       	push   $0x802229
  8011d5:	e8 6f ef ff ff       	call   800149 <cprintf>
		return -E_INVAL;
  8011da:	83 c4 10             	add    $0x10,%esp
  8011dd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011e2:	eb 20                	jmp    801204 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8011e4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011e7:	8b 52 0c             	mov    0xc(%edx),%edx
  8011ea:	85 d2                	test   %edx,%edx
  8011ec:	74 11                	je     8011ff <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8011ee:	83 ec 04             	sub    $0x4,%esp
  8011f1:	ff 75 10             	pushl  0x10(%ebp)
  8011f4:	ff 75 0c             	pushl  0xc(%ebp)
  8011f7:	50                   	push   %eax
  8011f8:	ff d2                	call   *%edx
  8011fa:	83 c4 10             	add    $0x10,%esp
  8011fd:	eb 05                	jmp    801204 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8011ff:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801204:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801207:	c9                   	leave  
  801208:	c3                   	ret    

00801209 <seek>:

int
seek(int fdnum, off_t offset)
{
  801209:	55                   	push   %ebp
  80120a:	89 e5                	mov    %esp,%ebp
  80120c:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80120f:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801212:	50                   	push   %eax
  801213:	ff 75 08             	pushl  0x8(%ebp)
  801216:	e8 0f fc ff ff       	call   800e2a <fd_lookup>
  80121b:	83 c4 08             	add    $0x8,%esp
  80121e:	85 c0                	test   %eax,%eax
  801220:	78 0e                	js     801230 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801222:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801225:	8b 55 0c             	mov    0xc(%ebp),%edx
  801228:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80122b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801230:	c9                   	leave  
  801231:	c3                   	ret    

00801232 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801232:	55                   	push   %ebp
  801233:	89 e5                	mov    %esp,%ebp
  801235:	53                   	push   %ebx
  801236:	83 ec 14             	sub    $0x14,%esp
  801239:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80123c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80123f:	50                   	push   %eax
  801240:	53                   	push   %ebx
  801241:	e8 e4 fb ff ff       	call   800e2a <fd_lookup>
  801246:	83 c4 08             	add    $0x8,%esp
  801249:	85 c0                	test   %eax,%eax
  80124b:	78 5f                	js     8012ac <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80124d:	83 ec 08             	sub    $0x8,%esp
  801250:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801253:	50                   	push   %eax
  801254:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801257:	ff 30                	pushl  (%eax)
  801259:	e8 23 fc ff ff       	call   800e81 <dev_lookup>
  80125e:	83 c4 10             	add    $0x10,%esp
  801261:	85 c0                	test   %eax,%eax
  801263:	78 47                	js     8012ac <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801265:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801268:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80126c:	75 21                	jne    80128f <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80126e:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801273:	8b 40 48             	mov    0x48(%eax),%eax
  801276:	83 ec 04             	sub    $0x4,%esp
  801279:	53                   	push   %ebx
  80127a:	50                   	push   %eax
  80127b:	68 ec 21 80 00       	push   $0x8021ec
  801280:	e8 c4 ee ff ff       	call   800149 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801285:	83 c4 10             	add    $0x10,%esp
  801288:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80128d:	eb 1d                	jmp    8012ac <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  80128f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801292:	8b 52 18             	mov    0x18(%edx),%edx
  801295:	85 d2                	test   %edx,%edx
  801297:	74 0e                	je     8012a7 <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801299:	83 ec 08             	sub    $0x8,%esp
  80129c:	ff 75 0c             	pushl  0xc(%ebp)
  80129f:	50                   	push   %eax
  8012a0:	ff d2                	call   *%edx
  8012a2:	83 c4 10             	add    $0x10,%esp
  8012a5:	eb 05                	jmp    8012ac <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8012a7:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8012ac:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012af:	c9                   	leave  
  8012b0:	c3                   	ret    

008012b1 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8012b1:	55                   	push   %ebp
  8012b2:	89 e5                	mov    %esp,%ebp
  8012b4:	53                   	push   %ebx
  8012b5:	83 ec 14             	sub    $0x14,%esp
  8012b8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012bb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012be:	50                   	push   %eax
  8012bf:	ff 75 08             	pushl  0x8(%ebp)
  8012c2:	e8 63 fb ff ff       	call   800e2a <fd_lookup>
  8012c7:	83 c4 08             	add    $0x8,%esp
  8012ca:	85 c0                	test   %eax,%eax
  8012cc:	78 52                	js     801320 <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012ce:	83 ec 08             	sub    $0x8,%esp
  8012d1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012d4:	50                   	push   %eax
  8012d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012d8:	ff 30                	pushl  (%eax)
  8012da:	e8 a2 fb ff ff       	call   800e81 <dev_lookup>
  8012df:	83 c4 10             	add    $0x10,%esp
  8012e2:	85 c0                	test   %eax,%eax
  8012e4:	78 3a                	js     801320 <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  8012e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012e9:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8012ed:	74 2c                	je     80131b <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8012ef:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8012f2:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8012f9:	00 00 00 
	stat->st_isdir = 0;
  8012fc:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801303:	00 00 00 
	stat->st_dev = dev;
  801306:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80130c:	83 ec 08             	sub    $0x8,%esp
  80130f:	53                   	push   %ebx
  801310:	ff 75 f0             	pushl  -0x10(%ebp)
  801313:	ff 50 14             	call   *0x14(%eax)
  801316:	83 c4 10             	add    $0x10,%esp
  801319:	eb 05                	jmp    801320 <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80131b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801320:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801323:	c9                   	leave  
  801324:	c3                   	ret    

00801325 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801325:	55                   	push   %ebp
  801326:	89 e5                	mov    %esp,%ebp
  801328:	56                   	push   %esi
  801329:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80132a:	83 ec 08             	sub    $0x8,%esp
  80132d:	6a 00                	push   $0x0
  80132f:	ff 75 08             	pushl  0x8(%ebp)
  801332:	e8 75 01 00 00       	call   8014ac <open>
  801337:	89 c3                	mov    %eax,%ebx
  801339:	83 c4 10             	add    $0x10,%esp
  80133c:	85 c0                	test   %eax,%eax
  80133e:	78 1d                	js     80135d <stat+0x38>
		return fd;
	r = fstat(fd, stat);
  801340:	83 ec 08             	sub    $0x8,%esp
  801343:	ff 75 0c             	pushl  0xc(%ebp)
  801346:	50                   	push   %eax
  801347:	e8 65 ff ff ff       	call   8012b1 <fstat>
  80134c:	89 c6                	mov    %eax,%esi
	close(fd);
  80134e:	89 1c 24             	mov    %ebx,(%esp)
  801351:	e8 1d fc ff ff       	call   800f73 <close>
	return r;
  801356:	83 c4 10             	add    $0x10,%esp
  801359:	89 f0                	mov    %esi,%eax
  80135b:	eb 00                	jmp    80135d <stat+0x38>
}
  80135d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801360:	5b                   	pop    %ebx
  801361:	5e                   	pop    %esi
  801362:	5d                   	pop    %ebp
  801363:	c3                   	ret    

00801364 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801364:	55                   	push   %ebp
  801365:	89 e5                	mov    %esp,%ebp
  801367:	56                   	push   %esi
  801368:	53                   	push   %ebx
  801369:	89 c6                	mov    %eax,%esi
  80136b:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80136d:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801374:	75 12                	jne    801388 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801376:	83 ec 0c             	sub    $0xc,%esp
  801379:	6a 01                	push   $0x1
  80137b:	e8 c1 07 00 00       	call   801b41 <ipc_find_env>
  801380:	a3 00 40 80 00       	mov    %eax,0x804000
  801385:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801388:	6a 07                	push   $0x7
  80138a:	68 00 50 80 00       	push   $0x805000
  80138f:	56                   	push   %esi
  801390:	ff 35 00 40 80 00    	pushl  0x804000
  801396:	e8 47 07 00 00       	call   801ae2 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80139b:	83 c4 0c             	add    $0xc,%esp
  80139e:	6a 00                	push   $0x0
  8013a0:	53                   	push   %ebx
  8013a1:	6a 00                	push   $0x0
  8013a3:	e8 c5 06 00 00       	call   801a6d <ipc_recv>
}
  8013a8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013ab:	5b                   	pop    %ebx
  8013ac:	5e                   	pop    %esi
  8013ad:	5d                   	pop    %ebp
  8013ae:	c3                   	ret    

008013af <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8013af:	55                   	push   %ebp
  8013b0:	89 e5                	mov    %esp,%ebp
  8013b2:	53                   	push   %ebx
  8013b3:	83 ec 04             	sub    $0x4,%esp
  8013b6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8013b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8013bc:	8b 40 0c             	mov    0xc(%eax),%eax
  8013bf:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8013c4:	ba 00 00 00 00       	mov    $0x0,%edx
  8013c9:	b8 05 00 00 00       	mov    $0x5,%eax
  8013ce:	e8 91 ff ff ff       	call   801364 <fsipc>
  8013d3:	85 c0                	test   %eax,%eax
  8013d5:	78 2c                	js     801403 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8013d7:	83 ec 08             	sub    $0x8,%esp
  8013da:	68 00 50 80 00       	push   $0x805000
  8013df:	53                   	push   %ebx
  8013e0:	e8 49 f3 ff ff       	call   80072e <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8013e5:	a1 80 50 80 00       	mov    0x805080,%eax
  8013ea:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8013f0:	a1 84 50 80 00       	mov    0x805084,%eax
  8013f5:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8013fb:	83 c4 10             	add    $0x10,%esp
  8013fe:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801403:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801406:	c9                   	leave  
  801407:	c3                   	ret    

00801408 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801408:	55                   	push   %ebp
  801409:	89 e5                	mov    %esp,%ebp
  80140b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80140e:	8b 45 08             	mov    0x8(%ebp),%eax
  801411:	8b 40 0c             	mov    0xc(%eax),%eax
  801414:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801419:	ba 00 00 00 00       	mov    $0x0,%edx
  80141e:	b8 06 00 00 00       	mov    $0x6,%eax
  801423:	e8 3c ff ff ff       	call   801364 <fsipc>
}
  801428:	c9                   	leave  
  801429:	c3                   	ret    

0080142a <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80142a:	55                   	push   %ebp
  80142b:	89 e5                	mov    %esp,%ebp
  80142d:	56                   	push   %esi
  80142e:	53                   	push   %ebx
  80142f:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801432:	8b 45 08             	mov    0x8(%ebp),%eax
  801435:	8b 40 0c             	mov    0xc(%eax),%eax
  801438:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80143d:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801443:	ba 00 00 00 00       	mov    $0x0,%edx
  801448:	b8 03 00 00 00       	mov    $0x3,%eax
  80144d:	e8 12 ff ff ff       	call   801364 <fsipc>
  801452:	89 c3                	mov    %eax,%ebx
  801454:	85 c0                	test   %eax,%eax
  801456:	78 4b                	js     8014a3 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801458:	39 c6                	cmp    %eax,%esi
  80145a:	73 16                	jae    801472 <devfile_read+0x48>
  80145c:	68 46 22 80 00       	push   $0x802246
  801461:	68 4d 22 80 00       	push   $0x80224d
  801466:	6a 7a                	push   $0x7a
  801468:	68 62 22 80 00       	push   $0x802262
  80146d:	e8 b5 05 00 00       	call   801a27 <_panic>
	assert(r <= PGSIZE);
  801472:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801477:	7e 16                	jle    80148f <devfile_read+0x65>
  801479:	68 6d 22 80 00       	push   $0x80226d
  80147e:	68 4d 22 80 00       	push   $0x80224d
  801483:	6a 7b                	push   $0x7b
  801485:	68 62 22 80 00       	push   $0x802262
  80148a:	e8 98 05 00 00       	call   801a27 <_panic>
	memmove(buf, &fsipcbuf, r);
  80148f:	83 ec 04             	sub    $0x4,%esp
  801492:	50                   	push   %eax
  801493:	68 00 50 80 00       	push   $0x805000
  801498:	ff 75 0c             	pushl  0xc(%ebp)
  80149b:	e8 5b f4 ff ff       	call   8008fb <memmove>
	return r;
  8014a0:	83 c4 10             	add    $0x10,%esp
}
  8014a3:	89 d8                	mov    %ebx,%eax
  8014a5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014a8:	5b                   	pop    %ebx
  8014a9:	5e                   	pop    %esi
  8014aa:	5d                   	pop    %ebp
  8014ab:	c3                   	ret    

008014ac <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8014ac:	55                   	push   %ebp
  8014ad:	89 e5                	mov    %esp,%ebp
  8014af:	53                   	push   %ebx
  8014b0:	83 ec 20             	sub    $0x20,%esp
  8014b3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8014b6:	53                   	push   %ebx
  8014b7:	e8 1b f2 ff ff       	call   8006d7 <strlen>
  8014bc:	83 c4 10             	add    $0x10,%esp
  8014bf:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8014c4:	7f 63                	jg     801529 <open+0x7d>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8014c6:	83 ec 0c             	sub    $0xc,%esp
  8014c9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014cc:	50                   	push   %eax
  8014cd:	e8 e4 f8 ff ff       	call   800db6 <fd_alloc>
  8014d2:	83 c4 10             	add    $0x10,%esp
  8014d5:	85 c0                	test   %eax,%eax
  8014d7:	78 55                	js     80152e <open+0x82>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8014d9:	83 ec 08             	sub    $0x8,%esp
  8014dc:	53                   	push   %ebx
  8014dd:	68 00 50 80 00       	push   $0x805000
  8014e2:	e8 47 f2 ff ff       	call   80072e <strcpy>
	fsipcbuf.open.req_omode = mode;
  8014e7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014ea:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8014ef:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014f2:	b8 01 00 00 00       	mov    $0x1,%eax
  8014f7:	e8 68 fe ff ff       	call   801364 <fsipc>
  8014fc:	89 c3                	mov    %eax,%ebx
  8014fe:	83 c4 10             	add    $0x10,%esp
  801501:	85 c0                	test   %eax,%eax
  801503:	79 14                	jns    801519 <open+0x6d>
		fd_close(fd, 0);
  801505:	83 ec 08             	sub    $0x8,%esp
  801508:	6a 00                	push   $0x0
  80150a:	ff 75 f4             	pushl  -0xc(%ebp)
  80150d:	e8 dd f9 ff ff       	call   800eef <fd_close>
		return r;
  801512:	83 c4 10             	add    $0x10,%esp
  801515:	89 d8                	mov    %ebx,%eax
  801517:	eb 15                	jmp    80152e <open+0x82>
	}

	return fd2num(fd);
  801519:	83 ec 0c             	sub    $0xc,%esp
  80151c:	ff 75 f4             	pushl  -0xc(%ebp)
  80151f:	e8 6b f8 ff ff       	call   800d8f <fd2num>
  801524:	83 c4 10             	add    $0x10,%esp
  801527:	eb 05                	jmp    80152e <open+0x82>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801529:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80152e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801531:	c9                   	leave  
  801532:	c3                   	ret    

00801533 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801533:	55                   	push   %ebp
  801534:	89 e5                	mov    %esp,%ebp
  801536:	56                   	push   %esi
  801537:	53                   	push   %ebx
  801538:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80153b:	83 ec 0c             	sub    $0xc,%esp
  80153e:	ff 75 08             	pushl  0x8(%ebp)
  801541:	e8 59 f8 ff ff       	call   800d9f <fd2data>
  801546:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801548:	83 c4 08             	add    $0x8,%esp
  80154b:	68 79 22 80 00       	push   $0x802279
  801550:	53                   	push   %ebx
  801551:	e8 d8 f1 ff ff       	call   80072e <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801556:	8b 46 04             	mov    0x4(%esi),%eax
  801559:	2b 06                	sub    (%esi),%eax
  80155b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801561:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801568:	00 00 00 
	stat->st_dev = &devpipe;
  80156b:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801572:	30 80 00 
	return 0;
}
  801575:	b8 00 00 00 00       	mov    $0x0,%eax
  80157a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80157d:	5b                   	pop    %ebx
  80157e:	5e                   	pop    %esi
  80157f:	5d                   	pop    %ebp
  801580:	c3                   	ret    

00801581 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801581:	55                   	push   %ebp
  801582:	89 e5                	mov    %esp,%ebp
  801584:	53                   	push   %ebx
  801585:	83 ec 0c             	sub    $0xc,%esp
  801588:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80158b:	53                   	push   %ebx
  80158c:	6a 00                	push   $0x0
  80158e:	e8 90 f6 ff ff       	call   800c23 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801593:	89 1c 24             	mov    %ebx,(%esp)
  801596:	e8 04 f8 ff ff       	call   800d9f <fd2data>
  80159b:	83 c4 08             	add    $0x8,%esp
  80159e:	50                   	push   %eax
  80159f:	6a 00                	push   $0x0
  8015a1:	e8 7d f6 ff ff       	call   800c23 <sys_page_unmap>
}
  8015a6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015a9:	c9                   	leave  
  8015aa:	c3                   	ret    

008015ab <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8015ab:	55                   	push   %ebp
  8015ac:	89 e5                	mov    %esp,%ebp
  8015ae:	57                   	push   %edi
  8015af:	56                   	push   %esi
  8015b0:	53                   	push   %ebx
  8015b1:	83 ec 1c             	sub    $0x1c,%esp
  8015b4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8015b7:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8015b9:	a1 04 40 80 00       	mov    0x804004,%eax
  8015be:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8015c1:	83 ec 0c             	sub    $0xc,%esp
  8015c4:	ff 75 e0             	pushl  -0x20(%ebp)
  8015c7:	e8 d0 05 00 00       	call   801b9c <pageref>
  8015cc:	89 c3                	mov    %eax,%ebx
  8015ce:	89 3c 24             	mov    %edi,(%esp)
  8015d1:	e8 c6 05 00 00       	call   801b9c <pageref>
  8015d6:	83 c4 10             	add    $0x10,%esp
  8015d9:	39 c3                	cmp    %eax,%ebx
  8015db:	0f 94 c1             	sete   %cl
  8015de:	0f b6 c9             	movzbl %cl,%ecx
  8015e1:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8015e4:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8015ea:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8015ed:	39 ce                	cmp    %ecx,%esi
  8015ef:	74 1b                	je     80160c <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8015f1:	39 c3                	cmp    %eax,%ebx
  8015f3:	75 c4                	jne    8015b9 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8015f5:	8b 42 58             	mov    0x58(%edx),%eax
  8015f8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8015fb:	50                   	push   %eax
  8015fc:	56                   	push   %esi
  8015fd:	68 80 22 80 00       	push   $0x802280
  801602:	e8 42 eb ff ff       	call   800149 <cprintf>
  801607:	83 c4 10             	add    $0x10,%esp
  80160a:	eb ad                	jmp    8015b9 <_pipeisclosed+0xe>
	}
}
  80160c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80160f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801612:	5b                   	pop    %ebx
  801613:	5e                   	pop    %esi
  801614:	5f                   	pop    %edi
  801615:	5d                   	pop    %ebp
  801616:	c3                   	ret    

00801617 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801617:	55                   	push   %ebp
  801618:	89 e5                	mov    %esp,%ebp
  80161a:	57                   	push   %edi
  80161b:	56                   	push   %esi
  80161c:	53                   	push   %ebx
  80161d:	83 ec 18             	sub    $0x18,%esp
  801620:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801623:	56                   	push   %esi
  801624:	e8 76 f7 ff ff       	call   800d9f <fd2data>
  801629:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80162b:	83 c4 10             	add    $0x10,%esp
  80162e:	bf 00 00 00 00       	mov    $0x0,%edi
  801633:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801637:	75 42                	jne    80167b <devpipe_write+0x64>
  801639:	eb 4e                	jmp    801689 <devpipe_write+0x72>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80163b:	89 da                	mov    %ebx,%edx
  80163d:	89 f0                	mov    %esi,%eax
  80163f:	e8 67 ff ff ff       	call   8015ab <_pipeisclosed>
  801644:	85 c0                	test   %eax,%eax
  801646:	75 46                	jne    80168e <devpipe_write+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801648:	e8 32 f5 ff ff       	call   800b7f <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80164d:	8b 53 04             	mov    0x4(%ebx),%edx
  801650:	8b 03                	mov    (%ebx),%eax
  801652:	83 c0 20             	add    $0x20,%eax
  801655:	39 c2                	cmp    %eax,%edx
  801657:	73 e2                	jae    80163b <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801659:	8b 45 0c             	mov    0xc(%ebp),%eax
  80165c:	8a 0c 38             	mov    (%eax,%edi,1),%cl
  80165f:	89 d0                	mov    %edx,%eax
  801661:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801666:	79 05                	jns    80166d <devpipe_write+0x56>
  801668:	48                   	dec    %eax
  801669:	83 c8 e0             	or     $0xffffffe0,%eax
  80166c:	40                   	inc    %eax
  80166d:	88 4c 03 08          	mov    %cl,0x8(%ebx,%eax,1)
		p->p_wpos++;
  801671:	42                   	inc    %edx
  801672:	89 53 04             	mov    %edx,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801675:	47                   	inc    %edi
  801676:	39 7d 10             	cmp    %edi,0x10(%ebp)
  801679:	74 0e                	je     801689 <devpipe_write+0x72>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80167b:	8b 53 04             	mov    0x4(%ebx),%edx
  80167e:	8b 03                	mov    (%ebx),%eax
  801680:	83 c0 20             	add    $0x20,%eax
  801683:	39 c2                	cmp    %eax,%edx
  801685:	73 b4                	jae    80163b <devpipe_write+0x24>
  801687:	eb d0                	jmp    801659 <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801689:	8b 45 10             	mov    0x10(%ebp),%eax
  80168c:	eb 05                	jmp    801693 <devpipe_write+0x7c>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80168e:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801693:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801696:	5b                   	pop    %ebx
  801697:	5e                   	pop    %esi
  801698:	5f                   	pop    %edi
  801699:	5d                   	pop    %ebp
  80169a:	c3                   	ret    

0080169b <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80169b:	55                   	push   %ebp
  80169c:	89 e5                	mov    %esp,%ebp
  80169e:	57                   	push   %edi
  80169f:	56                   	push   %esi
  8016a0:	53                   	push   %ebx
  8016a1:	83 ec 18             	sub    $0x18,%esp
  8016a4:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8016a7:	57                   	push   %edi
  8016a8:	e8 f2 f6 ff ff       	call   800d9f <fd2data>
  8016ad:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8016af:	83 c4 10             	add    $0x10,%esp
  8016b2:	be 00 00 00 00       	mov    $0x0,%esi
  8016b7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8016bb:	75 3d                	jne    8016fa <devpipe_read+0x5f>
  8016bd:	eb 48                	jmp    801707 <devpipe_read+0x6c>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  8016bf:	89 f0                	mov    %esi,%eax
  8016c1:	eb 4e                	jmp    801711 <devpipe_read+0x76>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8016c3:	89 da                	mov    %ebx,%edx
  8016c5:	89 f8                	mov    %edi,%eax
  8016c7:	e8 df fe ff ff       	call   8015ab <_pipeisclosed>
  8016cc:	85 c0                	test   %eax,%eax
  8016ce:	75 3c                	jne    80170c <devpipe_read+0x71>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8016d0:	e8 aa f4 ff ff       	call   800b7f <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8016d5:	8b 03                	mov    (%ebx),%eax
  8016d7:	3b 43 04             	cmp    0x4(%ebx),%eax
  8016da:	74 e7                	je     8016c3 <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8016dc:	25 1f 00 00 80       	and    $0x8000001f,%eax
  8016e1:	79 05                	jns    8016e8 <devpipe_read+0x4d>
  8016e3:	48                   	dec    %eax
  8016e4:	83 c8 e0             	or     $0xffffffe0,%eax
  8016e7:	40                   	inc    %eax
  8016e8:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  8016ec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016ef:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  8016f2:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8016f4:	46                   	inc    %esi
  8016f5:	39 75 10             	cmp    %esi,0x10(%ebp)
  8016f8:	74 0d                	je     801707 <devpipe_read+0x6c>
		while (p->p_rpos == p->p_wpos) {
  8016fa:	8b 03                	mov    (%ebx),%eax
  8016fc:	3b 43 04             	cmp    0x4(%ebx),%eax
  8016ff:	75 db                	jne    8016dc <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801701:	85 f6                	test   %esi,%esi
  801703:	75 ba                	jne    8016bf <devpipe_read+0x24>
  801705:	eb bc                	jmp    8016c3 <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801707:	8b 45 10             	mov    0x10(%ebp),%eax
  80170a:	eb 05                	jmp    801711 <devpipe_read+0x76>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80170c:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801711:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801714:	5b                   	pop    %ebx
  801715:	5e                   	pop    %esi
  801716:	5f                   	pop    %edi
  801717:	5d                   	pop    %ebp
  801718:	c3                   	ret    

00801719 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801719:	55                   	push   %ebp
  80171a:	89 e5                	mov    %esp,%ebp
  80171c:	56                   	push   %esi
  80171d:	53                   	push   %ebx
  80171e:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801721:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801724:	50                   	push   %eax
  801725:	e8 8c f6 ff ff       	call   800db6 <fd_alloc>
  80172a:	83 c4 10             	add    $0x10,%esp
  80172d:	85 c0                	test   %eax,%eax
  80172f:	0f 88 2a 01 00 00    	js     80185f <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801735:	83 ec 04             	sub    $0x4,%esp
  801738:	68 07 04 00 00       	push   $0x407
  80173d:	ff 75 f4             	pushl  -0xc(%ebp)
  801740:	6a 00                	push   $0x0
  801742:	e8 57 f4 ff ff       	call   800b9e <sys_page_alloc>
  801747:	83 c4 10             	add    $0x10,%esp
  80174a:	85 c0                	test   %eax,%eax
  80174c:	0f 88 0d 01 00 00    	js     80185f <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801752:	83 ec 0c             	sub    $0xc,%esp
  801755:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801758:	50                   	push   %eax
  801759:	e8 58 f6 ff ff       	call   800db6 <fd_alloc>
  80175e:	89 c3                	mov    %eax,%ebx
  801760:	83 c4 10             	add    $0x10,%esp
  801763:	85 c0                	test   %eax,%eax
  801765:	0f 88 e2 00 00 00    	js     80184d <pipe+0x134>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80176b:	83 ec 04             	sub    $0x4,%esp
  80176e:	68 07 04 00 00       	push   $0x407
  801773:	ff 75 f0             	pushl  -0x10(%ebp)
  801776:	6a 00                	push   $0x0
  801778:	e8 21 f4 ff ff       	call   800b9e <sys_page_alloc>
  80177d:	89 c3                	mov    %eax,%ebx
  80177f:	83 c4 10             	add    $0x10,%esp
  801782:	85 c0                	test   %eax,%eax
  801784:	0f 88 c3 00 00 00    	js     80184d <pipe+0x134>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80178a:	83 ec 0c             	sub    $0xc,%esp
  80178d:	ff 75 f4             	pushl  -0xc(%ebp)
  801790:	e8 0a f6 ff ff       	call   800d9f <fd2data>
  801795:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801797:	83 c4 0c             	add    $0xc,%esp
  80179a:	68 07 04 00 00       	push   $0x407
  80179f:	50                   	push   %eax
  8017a0:	6a 00                	push   $0x0
  8017a2:	e8 f7 f3 ff ff       	call   800b9e <sys_page_alloc>
  8017a7:	89 c3                	mov    %eax,%ebx
  8017a9:	83 c4 10             	add    $0x10,%esp
  8017ac:	85 c0                	test   %eax,%eax
  8017ae:	0f 88 89 00 00 00    	js     80183d <pipe+0x124>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017b4:	83 ec 0c             	sub    $0xc,%esp
  8017b7:	ff 75 f0             	pushl  -0x10(%ebp)
  8017ba:	e8 e0 f5 ff ff       	call   800d9f <fd2data>
  8017bf:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8017c6:	50                   	push   %eax
  8017c7:	6a 00                	push   $0x0
  8017c9:	56                   	push   %esi
  8017ca:	6a 00                	push   $0x0
  8017cc:	e8 10 f4 ff ff       	call   800be1 <sys_page_map>
  8017d1:	89 c3                	mov    %eax,%ebx
  8017d3:	83 c4 20             	add    $0x20,%esp
  8017d6:	85 c0                	test   %eax,%eax
  8017d8:	78 55                	js     80182f <pipe+0x116>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8017da:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8017e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017e3:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8017e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017e8:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8017ef:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8017f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017f8:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8017fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017fd:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801804:	83 ec 0c             	sub    $0xc,%esp
  801807:	ff 75 f4             	pushl  -0xc(%ebp)
  80180a:	e8 80 f5 ff ff       	call   800d8f <fd2num>
  80180f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801812:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801814:	83 c4 04             	add    $0x4,%esp
  801817:	ff 75 f0             	pushl  -0x10(%ebp)
  80181a:	e8 70 f5 ff ff       	call   800d8f <fd2num>
  80181f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801822:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801825:	83 c4 10             	add    $0x10,%esp
  801828:	b8 00 00 00 00       	mov    $0x0,%eax
  80182d:	eb 30                	jmp    80185f <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  80182f:	83 ec 08             	sub    $0x8,%esp
  801832:	56                   	push   %esi
  801833:	6a 00                	push   $0x0
  801835:	e8 e9 f3 ff ff       	call   800c23 <sys_page_unmap>
  80183a:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80183d:	83 ec 08             	sub    $0x8,%esp
  801840:	ff 75 f0             	pushl  -0x10(%ebp)
  801843:	6a 00                	push   $0x0
  801845:	e8 d9 f3 ff ff       	call   800c23 <sys_page_unmap>
  80184a:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80184d:	83 ec 08             	sub    $0x8,%esp
  801850:	ff 75 f4             	pushl  -0xc(%ebp)
  801853:	6a 00                	push   $0x0
  801855:	e8 c9 f3 ff ff       	call   800c23 <sys_page_unmap>
  80185a:	83 c4 10             	add    $0x10,%esp
  80185d:	89 d8                	mov    %ebx,%eax
    err:
	return r;
}
  80185f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801862:	5b                   	pop    %ebx
  801863:	5e                   	pop    %esi
  801864:	5d                   	pop    %ebp
  801865:	c3                   	ret    

00801866 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801866:	55                   	push   %ebp
  801867:	89 e5                	mov    %esp,%ebp
  801869:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80186c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80186f:	50                   	push   %eax
  801870:	ff 75 08             	pushl  0x8(%ebp)
  801873:	e8 b2 f5 ff ff       	call   800e2a <fd_lookup>
  801878:	83 c4 10             	add    $0x10,%esp
  80187b:	85 c0                	test   %eax,%eax
  80187d:	78 18                	js     801897 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80187f:	83 ec 0c             	sub    $0xc,%esp
  801882:	ff 75 f4             	pushl  -0xc(%ebp)
  801885:	e8 15 f5 ff ff       	call   800d9f <fd2data>
	return _pipeisclosed(fd, p);
  80188a:	89 c2                	mov    %eax,%edx
  80188c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80188f:	e8 17 fd ff ff       	call   8015ab <_pipeisclosed>
  801894:	83 c4 10             	add    $0x10,%esp
}
  801897:	c9                   	leave  
  801898:	c3                   	ret    

00801899 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801899:	55                   	push   %ebp
  80189a:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80189c:	b8 00 00 00 00       	mov    $0x0,%eax
  8018a1:	5d                   	pop    %ebp
  8018a2:	c3                   	ret    

008018a3 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8018a3:	55                   	push   %ebp
  8018a4:	89 e5                	mov    %esp,%ebp
  8018a6:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8018a9:	68 98 22 80 00       	push   $0x802298
  8018ae:	ff 75 0c             	pushl  0xc(%ebp)
  8018b1:	e8 78 ee ff ff       	call   80072e <strcpy>
	return 0;
}
  8018b6:	b8 00 00 00 00       	mov    $0x0,%eax
  8018bb:	c9                   	leave  
  8018bc:	c3                   	ret    

008018bd <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8018bd:	55                   	push   %ebp
  8018be:	89 e5                	mov    %esp,%ebp
  8018c0:	57                   	push   %edi
  8018c1:	56                   	push   %esi
  8018c2:	53                   	push   %ebx
  8018c3:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8018c9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8018cd:	74 45                	je     801914 <devcons_write+0x57>
  8018cf:	b8 00 00 00 00       	mov    $0x0,%eax
  8018d4:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8018d9:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8018df:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8018e2:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  8018e4:	83 fb 7f             	cmp    $0x7f,%ebx
  8018e7:	76 05                	jbe    8018ee <devcons_write+0x31>
			m = sizeof(buf) - 1;
  8018e9:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  8018ee:	83 ec 04             	sub    $0x4,%esp
  8018f1:	53                   	push   %ebx
  8018f2:	03 45 0c             	add    0xc(%ebp),%eax
  8018f5:	50                   	push   %eax
  8018f6:	57                   	push   %edi
  8018f7:	e8 ff ef ff ff       	call   8008fb <memmove>
		sys_cputs(buf, m);
  8018fc:	83 c4 08             	add    $0x8,%esp
  8018ff:	53                   	push   %ebx
  801900:	57                   	push   %edi
  801901:	e8 dc f1 ff ff       	call   800ae2 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801906:	01 de                	add    %ebx,%esi
  801908:	89 f0                	mov    %esi,%eax
  80190a:	83 c4 10             	add    $0x10,%esp
  80190d:	3b 75 10             	cmp    0x10(%ebp),%esi
  801910:	72 cd                	jb     8018df <devcons_write+0x22>
  801912:	eb 05                	jmp    801919 <devcons_write+0x5c>
  801914:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801919:	89 f0                	mov    %esi,%eax
  80191b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80191e:	5b                   	pop    %ebx
  80191f:	5e                   	pop    %esi
  801920:	5f                   	pop    %edi
  801921:	5d                   	pop    %ebp
  801922:	c3                   	ret    

00801923 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801923:	55                   	push   %ebp
  801924:	89 e5                	mov    %esp,%ebp
  801926:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801929:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80192d:	75 07                	jne    801936 <devcons_read+0x13>
  80192f:	eb 23                	jmp    801954 <devcons_read+0x31>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801931:	e8 49 f2 ff ff       	call   800b7f <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801936:	e8 c5 f1 ff ff       	call   800b00 <sys_cgetc>
  80193b:	85 c0                	test   %eax,%eax
  80193d:	74 f2                	je     801931 <devcons_read+0xe>
		sys_yield();
	if (c < 0)
  80193f:	85 c0                	test   %eax,%eax
  801941:	78 1d                	js     801960 <devcons_read+0x3d>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801943:	83 f8 04             	cmp    $0x4,%eax
  801946:	74 13                	je     80195b <devcons_read+0x38>
		return 0;
	*(char*)vbuf = c;
  801948:	8b 55 0c             	mov    0xc(%ebp),%edx
  80194b:	88 02                	mov    %al,(%edx)
	return 1;
  80194d:	b8 01 00 00 00       	mov    $0x1,%eax
  801952:	eb 0c                	jmp    801960 <devcons_read+0x3d>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801954:	b8 00 00 00 00       	mov    $0x0,%eax
  801959:	eb 05                	jmp    801960 <devcons_read+0x3d>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80195b:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801960:	c9                   	leave  
  801961:	c3                   	ret    

00801962 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801962:	55                   	push   %ebp
  801963:	89 e5                	mov    %esp,%ebp
  801965:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801968:	8b 45 08             	mov    0x8(%ebp),%eax
  80196b:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80196e:	6a 01                	push   $0x1
  801970:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801973:	50                   	push   %eax
  801974:	e8 69 f1 ff ff       	call   800ae2 <sys_cputs>
}
  801979:	83 c4 10             	add    $0x10,%esp
  80197c:	c9                   	leave  
  80197d:	c3                   	ret    

0080197e <getchar>:

int
getchar(void)
{
  80197e:	55                   	push   %ebp
  80197f:	89 e5                	mov    %esp,%ebp
  801981:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801984:	6a 01                	push   $0x1
  801986:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801989:	50                   	push   %eax
  80198a:	6a 00                	push   $0x0
  80198c:	e8 1a f7 ff ff       	call   8010ab <read>
	if (r < 0)
  801991:	83 c4 10             	add    $0x10,%esp
  801994:	85 c0                	test   %eax,%eax
  801996:	78 0f                	js     8019a7 <getchar+0x29>
		return r;
	if (r < 1)
  801998:	85 c0                	test   %eax,%eax
  80199a:	7e 06                	jle    8019a2 <getchar+0x24>
		return -E_EOF;
	return c;
  80199c:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8019a0:	eb 05                	jmp    8019a7 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8019a2:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8019a7:	c9                   	leave  
  8019a8:	c3                   	ret    

008019a9 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8019a9:	55                   	push   %ebp
  8019aa:	89 e5                	mov    %esp,%ebp
  8019ac:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8019af:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019b2:	50                   	push   %eax
  8019b3:	ff 75 08             	pushl  0x8(%ebp)
  8019b6:	e8 6f f4 ff ff       	call   800e2a <fd_lookup>
  8019bb:	83 c4 10             	add    $0x10,%esp
  8019be:	85 c0                	test   %eax,%eax
  8019c0:	78 11                	js     8019d3 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8019c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019c5:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8019cb:	39 10                	cmp    %edx,(%eax)
  8019cd:	0f 94 c0             	sete   %al
  8019d0:	0f b6 c0             	movzbl %al,%eax
}
  8019d3:	c9                   	leave  
  8019d4:	c3                   	ret    

008019d5 <opencons>:

int
opencons(void)
{
  8019d5:	55                   	push   %ebp
  8019d6:	89 e5                	mov    %esp,%ebp
  8019d8:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8019db:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019de:	50                   	push   %eax
  8019df:	e8 d2 f3 ff ff       	call   800db6 <fd_alloc>
  8019e4:	83 c4 10             	add    $0x10,%esp
  8019e7:	85 c0                	test   %eax,%eax
  8019e9:	78 3a                	js     801a25 <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8019eb:	83 ec 04             	sub    $0x4,%esp
  8019ee:	68 07 04 00 00       	push   $0x407
  8019f3:	ff 75 f4             	pushl  -0xc(%ebp)
  8019f6:	6a 00                	push   $0x0
  8019f8:	e8 a1 f1 ff ff       	call   800b9e <sys_page_alloc>
  8019fd:	83 c4 10             	add    $0x10,%esp
  801a00:	85 c0                	test   %eax,%eax
  801a02:	78 21                	js     801a25 <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801a04:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801a0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a0d:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801a0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a12:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801a19:	83 ec 0c             	sub    $0xc,%esp
  801a1c:	50                   	push   %eax
  801a1d:	e8 6d f3 ff ff       	call   800d8f <fd2num>
  801a22:	83 c4 10             	add    $0x10,%esp
}
  801a25:	c9                   	leave  
  801a26:	c3                   	ret    

00801a27 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801a27:	55                   	push   %ebp
  801a28:	89 e5                	mov    %esp,%ebp
  801a2a:	56                   	push   %esi
  801a2b:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801a2c:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801a2f:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801a35:	e8 26 f1 ff ff       	call   800b60 <sys_getenvid>
  801a3a:	83 ec 0c             	sub    $0xc,%esp
  801a3d:	ff 75 0c             	pushl  0xc(%ebp)
  801a40:	ff 75 08             	pushl  0x8(%ebp)
  801a43:	56                   	push   %esi
  801a44:	50                   	push   %eax
  801a45:	68 a4 22 80 00       	push   $0x8022a4
  801a4a:	e8 fa e6 ff ff       	call   800149 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801a4f:	83 c4 18             	add    $0x18,%esp
  801a52:	53                   	push   %ebx
  801a53:	ff 75 10             	pushl  0x10(%ebp)
  801a56:	e8 9d e6 ff ff       	call   8000f8 <vcprintf>
	cprintf("\n");
  801a5b:	c7 04 24 91 22 80 00 	movl   $0x802291,(%esp)
  801a62:	e8 e2 e6 ff ff       	call   800149 <cprintf>
  801a67:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801a6a:	cc                   	int3   
  801a6b:	eb fd                	jmp    801a6a <_panic+0x43>

00801a6d <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a6d:	55                   	push   %ebp
  801a6e:	89 e5                	mov    %esp,%ebp
  801a70:	56                   	push   %esi
  801a71:	53                   	push   %ebx
  801a72:	8b 75 08             	mov    0x8(%ebp),%esi
  801a75:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a78:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");
	int r;
    if (pg != NULL) {
  801a7b:	85 c0                	test   %eax,%eax
  801a7d:	74 0e                	je     801a8d <ipc_recv+0x20>
        r = sys_ipc_recv(pg);
  801a7f:	83 ec 0c             	sub    $0xc,%esp
  801a82:	50                   	push   %eax
  801a83:	e8 c6 f2 ff ff       	call   800d4e <sys_ipc_recv>
  801a88:	83 c4 10             	add    $0x10,%esp
  801a8b:	eb 10                	jmp    801a9d <ipc_recv+0x30>
    } else {
        r = sys_ipc_recv((void *) UTOP);
  801a8d:	83 ec 0c             	sub    $0xc,%esp
  801a90:	68 00 00 c0 ee       	push   $0xeec00000
  801a95:	e8 b4 f2 ff ff       	call   800d4e <sys_ipc_recv>
  801a9a:	83 c4 10             	add    $0x10,%esp
    }
    if (r < 0) {
  801a9d:	85 c0                	test   %eax,%eax
  801a9f:	79 16                	jns    801ab7 <ipc_recv+0x4a>
        // failed
        if (from_env_store != NULL) *from_env_store = 0;
  801aa1:	85 f6                	test   %esi,%esi
  801aa3:	74 06                	je     801aab <ipc_recv+0x3e>
  801aa5:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        if (perm_store != NULL) *perm_store = 0;
  801aab:	85 db                	test   %ebx,%ebx
  801aad:	74 2c                	je     801adb <ipc_recv+0x6e>
  801aaf:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801ab5:	eb 24                	jmp    801adb <ipc_recv+0x6e>
        return r;
    } else {
        if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801ab7:	85 f6                	test   %esi,%esi
  801ab9:	74 0a                	je     801ac5 <ipc_recv+0x58>
  801abb:	a1 04 40 80 00       	mov    0x804004,%eax
  801ac0:	8b 40 74             	mov    0x74(%eax),%eax
  801ac3:	89 06                	mov    %eax,(%esi)
        if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801ac5:	85 db                	test   %ebx,%ebx
  801ac7:	74 0a                	je     801ad3 <ipc_recv+0x66>
  801ac9:	a1 04 40 80 00       	mov    0x804004,%eax
  801ace:	8b 40 78             	mov    0x78(%eax),%eax
  801ad1:	89 03                	mov    %eax,(%ebx)
        return thisenv->env_ipc_value;
  801ad3:	a1 04 40 80 00       	mov    0x804004,%eax
  801ad8:	8b 40 70             	mov    0x70(%eax),%eax
    }
 
	return 0;
}
  801adb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ade:	5b                   	pop    %ebx
  801adf:	5e                   	pop    %esi
  801ae0:	5d                   	pop    %ebp
  801ae1:	c3                   	ret    

00801ae2 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801ae2:	55                   	push   %ebp
  801ae3:	89 e5                	mov    %esp,%ebp
  801ae5:	57                   	push   %edi
  801ae6:	56                   	push   %esi
  801ae7:	53                   	push   %ebx
  801ae8:	83 ec 0c             	sub    $0xc,%esp
  801aeb:	8b 75 10             	mov    0x10(%ebp),%esi
  801aee:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");
	int r;
    if (pg == NULL) pg = (void *)UTOP;
  801af1:	85 f6                	test   %esi,%esi
  801af3:	75 05                	jne    801afa <ipc_send+0x18>
  801af5:	be 00 00 c0 ee       	mov    $0xeec00000,%esi
    do {
        r = sys_ipc_try_send(to_env, val, pg, perm);
  801afa:	57                   	push   %edi
  801afb:	56                   	push   %esi
  801afc:	ff 75 0c             	pushl  0xc(%ebp)
  801aff:	ff 75 08             	pushl  0x8(%ebp)
  801b02:	e8 24 f2 ff ff       	call   800d2b <sys_ipc_try_send>
  801b07:	89 c3                	mov    %eax,%ebx
        if (r < 0 && r != -E_IPC_NOT_RECV) panic("ipc send failed: %e", r);
  801b09:	83 c4 10             	add    $0x10,%esp
  801b0c:	85 c0                	test   %eax,%eax
  801b0e:	79 17                	jns    801b27 <ipc_send+0x45>
  801b10:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801b13:	74 1d                	je     801b32 <ipc_send+0x50>
  801b15:	50                   	push   %eax
  801b16:	68 c8 22 80 00       	push   $0x8022c8
  801b1b:	6a 40                	push   $0x40
  801b1d:	68 dc 22 80 00       	push   $0x8022dc
  801b22:	e8 00 ff ff ff       	call   801a27 <_panic>
        sys_yield();
  801b27:	e8 53 f0 ff ff       	call   800b7f <sys_yield>
    } while (r != 0);
  801b2c:	85 db                	test   %ebx,%ebx
  801b2e:	75 ca                	jne    801afa <ipc_send+0x18>
  801b30:	eb 07                	jmp    801b39 <ipc_send+0x57>
	int r;
    if (pg == NULL) pg = (void *)UTOP;
    do {
        r = sys_ipc_try_send(to_env, val, pg, perm);
        if (r < 0 && r != -E_IPC_NOT_RECV) panic("ipc send failed: %e", r);
        sys_yield();
  801b32:	e8 48 f0 ff ff       	call   800b7f <sys_yield>
  801b37:	eb c1                	jmp    801afa <ipc_send+0x18>
    } while (r != 0);
}
  801b39:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b3c:	5b                   	pop    %ebx
  801b3d:	5e                   	pop    %esi
  801b3e:	5f                   	pop    %edi
  801b3f:	5d                   	pop    %ebp
  801b40:	c3                   	ret    

00801b41 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b41:	55                   	push   %ebp
  801b42:	89 e5                	mov    %esp,%ebp
  801b44:	53                   	push   %ebx
  801b45:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801b48:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  801b4d:	39 c1                	cmp    %eax,%ecx
  801b4f:	74 21                	je     801b72 <ipc_find_env+0x31>
  801b51:	ba 01 00 00 00       	mov    $0x1,%edx
  801b56:	8d 1c 95 00 00 00 00 	lea    0x0(,%edx,4),%ebx
  801b5d:	89 d0                	mov    %edx,%eax
  801b5f:	c1 e0 07             	shl    $0x7,%eax
  801b62:	29 d8                	sub    %ebx,%eax
  801b64:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b69:	8b 40 50             	mov    0x50(%eax),%eax
  801b6c:	39 c8                	cmp    %ecx,%eax
  801b6e:	75 1b                	jne    801b8b <ipc_find_env+0x4a>
  801b70:	eb 05                	jmp    801b77 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b72:	ba 00 00 00 00       	mov    $0x0,%edx
		if (envs[i].env_type == type)
			return envs[i].env_id;
  801b77:	8d 04 95 00 00 00 00 	lea    0x0(,%edx,4),%eax
  801b7e:	c1 e2 07             	shl    $0x7,%edx
  801b81:	29 c2                	sub    %eax,%edx
  801b83:	8b 82 48 00 c0 ee    	mov    -0x113fffb8(%edx),%eax
  801b89:	eb 0e                	jmp    801b99 <ipc_find_env+0x58>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b8b:	42                   	inc    %edx
  801b8c:	81 fa 00 04 00 00    	cmp    $0x400,%edx
  801b92:	75 c2                	jne    801b56 <ipc_find_env+0x15>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801b94:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b99:	5b                   	pop    %ebx
  801b9a:	5d                   	pop    %ebp
  801b9b:	c3                   	ret    

00801b9c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b9c:	55                   	push   %ebp
  801b9d:	89 e5                	mov    %esp,%ebp
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b9f:	8b 45 08             	mov    0x8(%ebp),%eax
  801ba2:	c1 e8 16             	shr    $0x16,%eax
  801ba5:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801bac:	a8 01                	test   $0x1,%al
  801bae:	74 21                	je     801bd1 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801bb0:	8b 45 08             	mov    0x8(%ebp),%eax
  801bb3:	c1 e8 0c             	shr    $0xc,%eax
  801bb6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801bbd:	a8 01                	test   $0x1,%al
  801bbf:	74 17                	je     801bd8 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801bc1:	c1 e8 0c             	shr    $0xc,%eax
  801bc4:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801bcb:	ef 
  801bcc:	0f b7 c0             	movzwl %ax,%eax
  801bcf:	eb 0c                	jmp    801bdd <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801bd1:	b8 00 00 00 00       	mov    $0x0,%eax
  801bd6:	eb 05                	jmp    801bdd <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801bd8:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801bdd:	5d                   	pop    %ebp
  801bde:	c3                   	ret    
  801bdf:	90                   	nop

00801be0 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801be0:	55                   	push   %ebp
  801be1:	57                   	push   %edi
  801be2:	56                   	push   %esi
  801be3:	53                   	push   %ebx
  801be4:	83 ec 1c             	sub    $0x1c,%esp
  801be7:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801beb:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801bef:	8b 7c 24 38          	mov    0x38(%esp),%edi
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801bf3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801bf7:	89 ca                	mov    %ecx,%edx
  const DWunion dd = {.ll = d};
  801bf9:	89 f8                	mov    %edi,%eax
  801bfb:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801bff:	85 f6                	test   %esi,%esi
  801c01:	75 2d                	jne    801c30 <__udivdi3+0x50>
    {
      if (d0 > n1)
  801c03:	39 cf                	cmp    %ecx,%edi
  801c05:	77 65                	ja     801c6c <__udivdi3+0x8c>
  801c07:	89 fd                	mov    %edi,%ebp
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801c09:	85 ff                	test   %edi,%edi
  801c0b:	75 0b                	jne    801c18 <__udivdi3+0x38>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801c0d:	b8 01 00 00 00       	mov    $0x1,%eax
  801c12:	31 d2                	xor    %edx,%edx
  801c14:	f7 f7                	div    %edi
  801c16:	89 c5                	mov    %eax,%ebp

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801c18:	31 d2                	xor    %edx,%edx
  801c1a:	89 c8                	mov    %ecx,%eax
  801c1c:	f7 f5                	div    %ebp
  801c1e:	89 c1                	mov    %eax,%ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801c20:	89 d8                	mov    %ebx,%eax
  801c22:	f7 f5                	div    %ebp
  801c24:	89 cf                	mov    %ecx,%edi
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801c26:	89 fa                	mov    %edi,%edx
  801c28:	83 c4 1c             	add    $0x1c,%esp
  801c2b:	5b                   	pop    %ebx
  801c2c:	5e                   	pop    %esi
  801c2d:	5f                   	pop    %edi
  801c2e:	5d                   	pop    %ebp
  801c2f:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801c30:	39 ce                	cmp    %ecx,%esi
  801c32:	77 28                	ja     801c5c <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801c34:	0f bd fe             	bsr    %esi,%edi
	  if (bm == 0)
  801c37:	83 f7 1f             	xor    $0x1f,%edi
  801c3a:	75 40                	jne    801c7c <__udivdi3+0x9c>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801c3c:	39 ce                	cmp    %ecx,%esi
  801c3e:	72 0a                	jb     801c4a <__udivdi3+0x6a>
  801c40:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801c44:	0f 87 9e 00 00 00    	ja     801ce8 <__udivdi3+0x108>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801c4a:	b8 01 00 00 00       	mov    $0x1,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801c4f:	89 fa                	mov    %edi,%edx
  801c51:	83 c4 1c             	add    $0x1c,%esp
  801c54:	5b                   	pop    %ebx
  801c55:	5e                   	pop    %esi
  801c56:	5f                   	pop    %edi
  801c57:	5d                   	pop    %ebp
  801c58:	c3                   	ret    
  801c59:	8d 76 00             	lea    0x0(%esi),%esi
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801c5c:	31 ff                	xor    %edi,%edi
  801c5e:	31 c0                	xor    %eax,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801c60:	89 fa                	mov    %edi,%edx
  801c62:	83 c4 1c             	add    $0x1c,%esp
  801c65:	5b                   	pop    %ebx
  801c66:	5e                   	pop    %esi
  801c67:	5f                   	pop    %edi
  801c68:	5d                   	pop    %ebp
  801c69:	c3                   	ret    
  801c6a:	66 90                	xchg   %ax,%ax
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801c6c:	89 d8                	mov    %ebx,%eax
  801c6e:	f7 f7                	div    %edi
  801c70:	31 ff                	xor    %edi,%edi
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801c72:	89 fa                	mov    %edi,%edx
  801c74:	83 c4 1c             	add    $0x1c,%esp
  801c77:	5b                   	pop    %ebx
  801c78:	5e                   	pop    %esi
  801c79:	5f                   	pop    %edi
  801c7a:	5d                   	pop    %ebp
  801c7b:	c3                   	ret    
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801c7c:	bd 20 00 00 00       	mov    $0x20,%ebp
  801c81:	89 eb                	mov    %ebp,%ebx
  801c83:	29 fb                	sub    %edi,%ebx

	      d1 = (d1 << bm) | (d0 >> b);
  801c85:	89 f9                	mov    %edi,%ecx
  801c87:	d3 e6                	shl    %cl,%esi
  801c89:	89 c5                	mov    %eax,%ebp
  801c8b:	88 d9                	mov    %bl,%cl
  801c8d:	d3 ed                	shr    %cl,%ebp
  801c8f:	89 e9                	mov    %ebp,%ecx
  801c91:	09 f1                	or     %esi,%ecx
  801c93:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
	      d0 = d0 << bm;
  801c97:	89 f9                	mov    %edi,%ecx
  801c99:	d3 e0                	shl    %cl,%eax
  801c9b:	89 c5                	mov    %eax,%ebp
	      n2 = n1 >> b;
  801c9d:	89 d6                	mov    %edx,%esi
  801c9f:	88 d9                	mov    %bl,%cl
  801ca1:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
  801ca3:	89 f9                	mov    %edi,%ecx
  801ca5:	d3 e2                	shl    %cl,%edx
  801ca7:	8b 44 24 08          	mov    0x8(%esp),%eax
  801cab:	88 d9                	mov    %bl,%cl
  801cad:	d3 e8                	shr    %cl,%eax
  801caf:	09 c2                	or     %eax,%edx
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801cb1:	89 d0                	mov    %edx,%eax
  801cb3:	89 f2                	mov    %esi,%edx
  801cb5:	f7 74 24 0c          	divl   0xc(%esp)
  801cb9:	89 d6                	mov    %edx,%esi
  801cbb:	89 c3                	mov    %eax,%ebx
	      umul_ppmm (m1, m0, q0, d0);
  801cbd:	f7 e5                	mul    %ebp

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801cbf:	39 d6                	cmp    %edx,%esi
  801cc1:	72 19                	jb     801cdc <__udivdi3+0xfc>
  801cc3:	74 0b                	je     801cd0 <__udivdi3+0xf0>
  801cc5:	89 d8                	mov    %ebx,%eax
  801cc7:	31 ff                	xor    %edi,%edi
  801cc9:	e9 58 ff ff ff       	jmp    801c26 <__udivdi3+0x46>
  801cce:	66 90                	xchg   %ax,%ax
  801cd0:	8b 54 24 08          	mov    0x8(%esp),%edx
  801cd4:	89 f9                	mov    %edi,%ecx
  801cd6:	d3 e2                	shl    %cl,%edx
  801cd8:	39 c2                	cmp    %eax,%edx
  801cda:	73 e9                	jae    801cc5 <__udivdi3+0xe5>
  801cdc:	8d 43 ff             	lea    -0x1(%ebx),%eax
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801cdf:	31 ff                	xor    %edi,%edi
  801ce1:	e9 40 ff ff ff       	jmp    801c26 <__udivdi3+0x46>
  801ce6:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801ce8:	31 c0                	xor    %eax,%eax
  801cea:	e9 37 ff ff ff       	jmp    801c26 <__udivdi3+0x46>
  801cef:	90                   	nop

00801cf0 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  801cf0:	55                   	push   %ebp
  801cf1:	57                   	push   %edi
  801cf2:	56                   	push   %esi
  801cf3:	53                   	push   %ebx
  801cf4:	83 ec 1c             	sub    $0x1c,%esp
  801cf7:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801cfb:	8b 74 24 34          	mov    0x34(%esp),%esi
  801cff:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801d03:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801d07:	89 44 24 0c          	mov    %eax,0xc(%esp)
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801d0b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801d0f:	89 f3                	mov    %esi,%ebx
  const DWunion dd = {.ll = d};
  801d11:	89 fa                	mov    %edi,%edx
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  801d13:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  n1 = nn.s.high;
  801d17:	89 34 24             	mov    %esi,(%esp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801d1a:	85 c0                	test   %eax,%eax
  801d1c:	75 1a                	jne    801d38 <__umoddi3+0x48>
    {
      if (d0 > n1)
  801d1e:	39 f7                	cmp    %esi,%edi
  801d20:	0f 86 a2 00 00 00    	jbe    801dc8 <__umoddi3+0xd8>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801d26:	89 c8                	mov    %ecx,%eax
  801d28:	89 f2                	mov    %esi,%edx
  801d2a:	f7 f7                	div    %edi
  801d2c:	89 d0                	mov    %edx,%eax

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  801d2e:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801d30:	83 c4 1c             	add    $0x1c,%esp
  801d33:	5b                   	pop    %ebx
  801d34:	5e                   	pop    %esi
  801d35:	5f                   	pop    %edi
  801d36:	5d                   	pop    %ebp
  801d37:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801d38:	39 f0                	cmp    %esi,%eax
  801d3a:	0f 87 ac 00 00 00    	ja     801dec <__umoddi3+0xfc>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801d40:	0f bd e8             	bsr    %eax,%ebp
	  if (bm == 0)
  801d43:	83 f5 1f             	xor    $0x1f,%ebp
  801d46:	0f 84 ac 00 00 00    	je     801df8 <__umoddi3+0x108>
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801d4c:	bf 20 00 00 00       	mov    $0x20,%edi
  801d51:	29 ef                	sub    %ebp,%edi
  801d53:	89 fe                	mov    %edi,%esi
  801d55:	89 7c 24 0c          	mov    %edi,0xc(%esp)

	      d1 = (d1 << bm) | (d0 >> b);
  801d59:	89 e9                	mov    %ebp,%ecx
  801d5b:	d3 e0                	shl    %cl,%eax
  801d5d:	89 d7                	mov    %edx,%edi
  801d5f:	89 f1                	mov    %esi,%ecx
  801d61:	d3 ef                	shr    %cl,%edi
  801d63:	09 c7                	or     %eax,%edi
	      d0 = d0 << bm;
  801d65:	89 e9                	mov    %ebp,%ecx
  801d67:	d3 e2                	shl    %cl,%edx
  801d69:	89 14 24             	mov    %edx,(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801d6c:	89 d8                	mov    %ebx,%eax
  801d6e:	d3 e0                	shl    %cl,%eax
  801d70:	89 c2                	mov    %eax,%edx
	      n0 = n0 << bm;
  801d72:	8b 44 24 08          	mov    0x8(%esp),%eax
  801d76:	d3 e0                	shl    %cl,%eax
  801d78:	89 44 24 04          	mov    %eax,0x4(%esp)

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801d7c:	8b 44 24 08          	mov    0x8(%esp),%eax
  801d80:	89 f1                	mov    %esi,%ecx
  801d82:	d3 e8                	shr    %cl,%eax
  801d84:	09 d0                	or     %edx,%eax
  801d86:	d3 eb                	shr    %cl,%ebx
  801d88:	89 da                	mov    %ebx,%edx
  801d8a:	f7 f7                	div    %edi
  801d8c:	89 d3                	mov    %edx,%ebx
	      umul_ppmm (m1, m0, q0, d0);
  801d8e:	f7 24 24             	mull   (%esp)
  801d91:	89 c6                	mov    %eax,%esi
  801d93:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801d95:	39 d3                	cmp    %edx,%ebx
  801d97:	0f 82 87 00 00 00    	jb     801e24 <__umoddi3+0x134>
  801d9d:	0f 84 91 00 00 00    	je     801e34 <__umoddi3+0x144>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  801da3:	8b 54 24 04          	mov    0x4(%esp),%edx
  801da7:	29 f2                	sub    %esi,%edx
  801da9:	19 cb                	sbb    %ecx,%ebx
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801dab:	89 d8                	mov    %ebx,%eax
  801dad:	8a 4c 24 0c          	mov    0xc(%esp),%cl
  801db1:	d3 e0                	shl    %cl,%eax
  801db3:	89 e9                	mov    %ebp,%ecx
  801db5:	d3 ea                	shr    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  801db7:	09 d0                	or     %edx,%eax
  801db9:	89 e9                	mov    %ebp,%ecx
  801dbb:	d3 eb                	shr    %cl,%ebx
  801dbd:	89 da                	mov    %ebx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801dbf:	83 c4 1c             	add    $0x1c,%esp
  801dc2:	5b                   	pop    %ebx
  801dc3:	5e                   	pop    %esi
  801dc4:	5f                   	pop    %edi
  801dc5:	5d                   	pop    %ebp
  801dc6:	c3                   	ret    
  801dc7:	90                   	nop
  801dc8:	89 fd                	mov    %edi,%ebp
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801dca:	85 ff                	test   %edi,%edi
  801dcc:	75 0b                	jne    801dd9 <__umoddi3+0xe9>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801dce:	b8 01 00 00 00       	mov    $0x1,%eax
  801dd3:	31 d2                	xor    %edx,%edx
  801dd5:	f7 f7                	div    %edi
  801dd7:	89 c5                	mov    %eax,%ebp

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801dd9:	89 f0                	mov    %esi,%eax
  801ddb:	31 d2                	xor    %edx,%edx
  801ddd:	f7 f5                	div    %ebp
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801ddf:	89 c8                	mov    %ecx,%eax
  801de1:	f7 f5                	div    %ebp
  801de3:	89 d0                	mov    %edx,%eax
  801de5:	e9 44 ff ff ff       	jmp    801d2e <__umoddi3+0x3e>
  801dea:	66 90                	xchg   %ax,%ax
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  801dec:	89 c8                	mov    %ecx,%eax
  801dee:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801df0:	83 c4 1c             	add    $0x1c,%esp
  801df3:	5b                   	pop    %ebx
  801df4:	5e                   	pop    %esi
  801df5:	5f                   	pop    %edi
  801df6:	5d                   	pop    %ebp
  801df7:	c3                   	ret    

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801df8:	3b 04 24             	cmp    (%esp),%eax
  801dfb:	72 06                	jb     801e03 <__umoddi3+0x113>
  801dfd:	3b 7c 24 04          	cmp    0x4(%esp),%edi
  801e01:	77 0f                	ja     801e12 <__umoddi3+0x122>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801e03:	89 f2                	mov    %esi,%edx
  801e05:	29 f9                	sub    %edi,%ecx
  801e07:	1b 54 24 0c          	sbb    0xc(%esp),%edx
  801e0b:	89 14 24             	mov    %edx,(%esp)
  801e0e:	89 4c 24 04          	mov    %ecx,0x4(%esp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  801e12:	8b 44 24 04          	mov    0x4(%esp),%eax
  801e16:	8b 14 24             	mov    (%esp),%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801e19:	83 c4 1c             	add    $0x1c,%esp
  801e1c:	5b                   	pop    %ebx
  801e1d:	5e                   	pop    %esi
  801e1e:	5f                   	pop    %edi
  801e1f:	5d                   	pop    %ebp
  801e20:	c3                   	ret    
  801e21:	8d 76 00             	lea    0x0(%esi),%esi
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801e24:	2b 04 24             	sub    (%esp),%eax
  801e27:	19 fa                	sbb    %edi,%edx
  801e29:	89 d1                	mov    %edx,%ecx
  801e2b:	89 c6                	mov    %eax,%esi
  801e2d:	e9 71 ff ff ff       	jmp    801da3 <__umoddi3+0xb3>
  801e32:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801e34:	39 44 24 04          	cmp    %eax,0x4(%esp)
  801e38:	72 ea                	jb     801e24 <__umoddi3+0x134>
  801e3a:	89 d9                	mov    %ebx,%ecx
  801e3c:	e9 62 ff ff ff       	jmp    801da3 <__umoddi3+0xb3>
