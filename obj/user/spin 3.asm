
obj/user/spin.debug:     file format elf32-i386


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
  80002c:	e8 84 00 00 00       	call   8000b5 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 10             	sub    $0x10,%esp
	envid_t env;

	cprintf("I am the parent.  Forking the child...\n");
  80003a:	68 40 22 80 00       	push   $0x802240
  80003f:	e8 6c 01 00 00       	call   8001b0 <cprintf>
	if ((env = fork()) == 0) {
  800044:	e8 9c 0e 00 00       	call   800ee5 <fork>
  800049:	83 c4 10             	add    $0x10,%esp
  80004c:	85 c0                	test   %eax,%eax
  80004e:	75 12                	jne    800062 <umain+0x2f>
		cprintf("I am the child.  Spinning...\n");
  800050:	83 ec 0c             	sub    $0xc,%esp
  800053:	68 b8 22 80 00       	push   $0x8022b8
  800058:	e8 53 01 00 00       	call   8001b0 <cprintf>
  80005d:	83 c4 10             	add    $0x10,%esp
  800060:	eb fe                	jmp    800060 <umain+0x2d>
  800062:	89 c3                	mov    %eax,%ebx
		while (1)
			/* do nothing */;
	}

	cprintf("I am the parent.  Running the child...\n");
  800064:	83 ec 0c             	sub    $0xc,%esp
  800067:	68 68 22 80 00       	push   $0x802268
  80006c:	e8 3f 01 00 00       	call   8001b0 <cprintf>
	sys_yield();
  800071:	e8 70 0b 00 00       	call   800be6 <sys_yield>
	sys_yield();
  800076:	e8 6b 0b 00 00       	call   800be6 <sys_yield>
	sys_yield();
  80007b:	e8 66 0b 00 00       	call   800be6 <sys_yield>
	sys_yield();
  800080:	e8 61 0b 00 00       	call   800be6 <sys_yield>
	sys_yield();
  800085:	e8 5c 0b 00 00       	call   800be6 <sys_yield>
	sys_yield();
  80008a:	e8 57 0b 00 00       	call   800be6 <sys_yield>
	sys_yield();
  80008f:	e8 52 0b 00 00       	call   800be6 <sys_yield>
	sys_yield();
  800094:	e8 4d 0b 00 00       	call   800be6 <sys_yield>

	cprintf("I am the parent.  Killing the child...\n");
  800099:	c7 04 24 90 22 80 00 	movl   $0x802290,(%esp)
  8000a0:	e8 0b 01 00 00       	call   8001b0 <cprintf>
	sys_env_destroy(env);
  8000a5:	89 1c 24             	mov    %ebx,(%esp)
  8000a8:	e8 d9 0a 00 00       	call   800b86 <sys_env_destroy>
}
  8000ad:	83 c4 10             	add    $0x10,%esp
  8000b0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000b3:	c9                   	leave  
  8000b4:	c3                   	ret    

008000b5 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000b5:	55                   	push   %ebp
  8000b6:	89 e5                	mov    %esp,%ebp
  8000b8:	56                   	push   %esi
  8000b9:	53                   	push   %ebx
  8000ba:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000bd:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8000c0:	e8 02 0b 00 00       	call   800bc7 <sys_getenvid>
  8000c5:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000ca:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8000d1:	c1 e0 07             	shl    $0x7,%eax
  8000d4:	29 d0                	sub    %edx,%eax
  8000d6:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000db:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000e0:	85 db                	test   %ebx,%ebx
  8000e2:	7e 07                	jle    8000eb <libmain+0x36>
		binaryname = argv[0];
  8000e4:	8b 06                	mov    (%esi),%eax
  8000e6:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000eb:	83 ec 08             	sub    $0x8,%esp
  8000ee:	56                   	push   %esi
  8000ef:	53                   	push   %ebx
  8000f0:	e8 3e ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000f5:	e8 0a 00 00 00       	call   800104 <exit>
}
  8000fa:	83 c4 10             	add    $0x10,%esp
  8000fd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800100:	5b                   	pop    %ebx
  800101:	5e                   	pop    %esi
  800102:	5d                   	pop    %ebp
  800103:	c3                   	ret    

00800104 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800104:	55                   	push   %ebp
  800105:	89 e5                	mov    %esp,%ebp
  800107:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80010a:	e8 d1 11 00 00       	call   8012e0 <close_all>
	sys_env_destroy(0);
  80010f:	83 ec 0c             	sub    $0xc,%esp
  800112:	6a 00                	push   $0x0
  800114:	e8 6d 0a 00 00       	call   800b86 <sys_env_destroy>
}
  800119:	83 c4 10             	add    $0x10,%esp
  80011c:	c9                   	leave  
  80011d:	c3                   	ret    

0080011e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80011e:	55                   	push   %ebp
  80011f:	89 e5                	mov    %esp,%ebp
  800121:	53                   	push   %ebx
  800122:	83 ec 04             	sub    $0x4,%esp
  800125:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800128:	8b 13                	mov    (%ebx),%edx
  80012a:	8d 42 01             	lea    0x1(%edx),%eax
  80012d:	89 03                	mov    %eax,(%ebx)
  80012f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800132:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800136:	3d ff 00 00 00       	cmp    $0xff,%eax
  80013b:	75 1a                	jne    800157 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80013d:	83 ec 08             	sub    $0x8,%esp
  800140:	68 ff 00 00 00       	push   $0xff
  800145:	8d 43 08             	lea    0x8(%ebx),%eax
  800148:	50                   	push   %eax
  800149:	e8 fb 09 00 00       	call   800b49 <sys_cputs>
		b->idx = 0;
  80014e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800154:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800157:	ff 43 04             	incl   0x4(%ebx)
}
  80015a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80015d:	c9                   	leave  
  80015e:	c3                   	ret    

0080015f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80015f:	55                   	push   %ebp
  800160:	89 e5                	mov    %esp,%ebp
  800162:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800168:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80016f:	00 00 00 
	b.cnt = 0;
  800172:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800179:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80017c:	ff 75 0c             	pushl  0xc(%ebp)
  80017f:	ff 75 08             	pushl  0x8(%ebp)
  800182:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800188:	50                   	push   %eax
  800189:	68 1e 01 80 00       	push   $0x80011e
  80018e:	e8 54 01 00 00       	call   8002e7 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800193:	83 c4 08             	add    $0x8,%esp
  800196:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80019c:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001a2:	50                   	push   %eax
  8001a3:	e8 a1 09 00 00       	call   800b49 <sys_cputs>

	return b.cnt;
}
  8001a8:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001ae:	c9                   	leave  
  8001af:	c3                   	ret    

008001b0 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001b0:	55                   	push   %ebp
  8001b1:	89 e5                	mov    %esp,%ebp
  8001b3:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001b6:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001b9:	50                   	push   %eax
  8001ba:	ff 75 08             	pushl  0x8(%ebp)
  8001bd:	e8 9d ff ff ff       	call   80015f <vcprintf>
	va_end(ap);

	return cnt;
}
  8001c2:	c9                   	leave  
  8001c3:	c3                   	ret    

008001c4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001c4:	55                   	push   %ebp
  8001c5:	89 e5                	mov    %esp,%ebp
  8001c7:	57                   	push   %edi
  8001c8:	56                   	push   %esi
  8001c9:	53                   	push   %ebx
  8001ca:	83 ec 1c             	sub    $0x1c,%esp
  8001cd:	89 c6                	mov    %eax,%esi
  8001cf:	89 d7                	mov    %edx,%edi
  8001d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8001d4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001d7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001da:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001dd:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001e0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001e5:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001e8:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001eb:	39 d3                	cmp    %edx,%ebx
  8001ed:	72 11                	jb     800200 <printnum+0x3c>
  8001ef:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001f2:	76 0c                	jbe    800200 <printnum+0x3c>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8001f7:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001fa:	85 db                	test   %ebx,%ebx
  8001fc:	7f 37                	jg     800235 <printnum+0x71>
  8001fe:	eb 44                	jmp    800244 <printnum+0x80>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800200:	83 ec 0c             	sub    $0xc,%esp
  800203:	ff 75 18             	pushl  0x18(%ebp)
  800206:	8b 45 14             	mov    0x14(%ebp),%eax
  800209:	48                   	dec    %eax
  80020a:	50                   	push   %eax
  80020b:	ff 75 10             	pushl  0x10(%ebp)
  80020e:	83 ec 08             	sub    $0x8,%esp
  800211:	ff 75 e4             	pushl  -0x1c(%ebp)
  800214:	ff 75 e0             	pushl  -0x20(%ebp)
  800217:	ff 75 dc             	pushl  -0x24(%ebp)
  80021a:	ff 75 d8             	pushl  -0x28(%ebp)
  80021d:	e8 9e 1d 00 00       	call   801fc0 <__udivdi3>
  800222:	83 c4 18             	add    $0x18,%esp
  800225:	52                   	push   %edx
  800226:	50                   	push   %eax
  800227:	89 fa                	mov    %edi,%edx
  800229:	89 f0                	mov    %esi,%eax
  80022b:	e8 94 ff ff ff       	call   8001c4 <printnum>
  800230:	83 c4 20             	add    $0x20,%esp
  800233:	eb 0f                	jmp    800244 <printnum+0x80>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800235:	83 ec 08             	sub    $0x8,%esp
  800238:	57                   	push   %edi
  800239:	ff 75 18             	pushl  0x18(%ebp)
  80023c:	ff d6                	call   *%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80023e:	83 c4 10             	add    $0x10,%esp
  800241:	4b                   	dec    %ebx
  800242:	75 f1                	jne    800235 <printnum+0x71>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800244:	83 ec 08             	sub    $0x8,%esp
  800247:	57                   	push   %edi
  800248:	83 ec 04             	sub    $0x4,%esp
  80024b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80024e:	ff 75 e0             	pushl  -0x20(%ebp)
  800251:	ff 75 dc             	pushl  -0x24(%ebp)
  800254:	ff 75 d8             	pushl  -0x28(%ebp)
  800257:	e8 74 1e 00 00       	call   8020d0 <__umoddi3>
  80025c:	83 c4 14             	add    $0x14,%esp
  80025f:	0f be 80 e0 22 80 00 	movsbl 0x8022e0(%eax),%eax
  800266:	50                   	push   %eax
  800267:	ff d6                	call   *%esi
}
  800269:	83 c4 10             	add    $0x10,%esp
  80026c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80026f:	5b                   	pop    %ebx
  800270:	5e                   	pop    %esi
  800271:	5f                   	pop    %edi
  800272:	5d                   	pop    %ebp
  800273:	c3                   	ret    

00800274 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800274:	55                   	push   %ebp
  800275:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800277:	83 fa 01             	cmp    $0x1,%edx
  80027a:	7e 0e                	jle    80028a <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80027c:	8b 10                	mov    (%eax),%edx
  80027e:	8d 4a 08             	lea    0x8(%edx),%ecx
  800281:	89 08                	mov    %ecx,(%eax)
  800283:	8b 02                	mov    (%edx),%eax
  800285:	8b 52 04             	mov    0x4(%edx),%edx
  800288:	eb 22                	jmp    8002ac <getuint+0x38>
	else if (lflag)
  80028a:	85 d2                	test   %edx,%edx
  80028c:	74 10                	je     80029e <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80028e:	8b 10                	mov    (%eax),%edx
  800290:	8d 4a 04             	lea    0x4(%edx),%ecx
  800293:	89 08                	mov    %ecx,(%eax)
  800295:	8b 02                	mov    (%edx),%eax
  800297:	ba 00 00 00 00       	mov    $0x0,%edx
  80029c:	eb 0e                	jmp    8002ac <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80029e:	8b 10                	mov    (%eax),%edx
  8002a0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002a3:	89 08                	mov    %ecx,(%eax)
  8002a5:	8b 02                	mov    (%edx),%eax
  8002a7:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002ac:	5d                   	pop    %ebp
  8002ad:	c3                   	ret    

008002ae <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002ae:	55                   	push   %ebp
  8002af:	89 e5                	mov    %esp,%ebp
  8002b1:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002b4:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8002b7:	8b 10                	mov    (%eax),%edx
  8002b9:	3b 50 04             	cmp    0x4(%eax),%edx
  8002bc:	73 0a                	jae    8002c8 <sprintputch+0x1a>
		*b->buf++ = ch;
  8002be:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002c1:	89 08                	mov    %ecx,(%eax)
  8002c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8002c6:	88 02                	mov    %al,(%edx)
}
  8002c8:	5d                   	pop    %ebp
  8002c9:	c3                   	ret    

008002ca <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002ca:	55                   	push   %ebp
  8002cb:	89 e5                	mov    %esp,%ebp
  8002cd:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002d0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002d3:	50                   	push   %eax
  8002d4:	ff 75 10             	pushl  0x10(%ebp)
  8002d7:	ff 75 0c             	pushl  0xc(%ebp)
  8002da:	ff 75 08             	pushl  0x8(%ebp)
  8002dd:	e8 05 00 00 00       	call   8002e7 <vprintfmt>
	va_end(ap);
}
  8002e2:	83 c4 10             	add    $0x10,%esp
  8002e5:	c9                   	leave  
  8002e6:	c3                   	ret    

008002e7 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002e7:	55                   	push   %ebp
  8002e8:	89 e5                	mov    %esp,%ebp
  8002ea:	57                   	push   %edi
  8002eb:	56                   	push   %esi
  8002ec:	53                   	push   %ebx
  8002ed:	83 ec 2c             	sub    $0x2c,%esp
  8002f0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8002f3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002f6:	eb 03                	jmp    8002fb <vprintfmt+0x14>
			break;

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
			for (fmt--; fmt[-1] != '%'; fmt--)
  8002f8:	89 75 10             	mov    %esi,0x10(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {    //遍历输入的第一个参数，即输出信息的格式，先把格式字符串中'%'之前的字符一个个输出，因为它们前面没有'%'，所以它们就是要直接显示在屏幕上的
  8002fb:	8b 45 10             	mov    0x10(%ebp),%eax
  8002fe:	8d 70 01             	lea    0x1(%eax),%esi
  800301:	0f b6 00             	movzbl (%eax),%eax
  800304:	83 f8 25             	cmp    $0x25,%eax
  800307:	74 25                	je     80032e <vprintfmt+0x47>
			if (ch == '\0')									//当然中间如果遇到'\0'，代表这个字符串的访问结束
  800309:	85 c0                	test   %eax,%eax
  80030b:	75 0d                	jne    80031a <vprintfmt+0x33>
  80030d:	e9 b5 03 00 00       	jmp    8006c7 <vprintfmt+0x3e0>
  800312:	85 c0                	test   %eax,%eax
  800314:	0f 84 ad 03 00 00    	je     8006c7 <vprintfmt+0x3e0>
				return;
			putch(ch, putdat);								//调用putch函数，把一个字符ch输出到putdat指针所指向的地址中所存放的值对应的地址处
  80031a:	83 ec 08             	sub    $0x8,%esp
  80031d:	53                   	push   %ebx
  80031e:	50                   	push   %eax
  80031f:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {    //遍历输入的第一个参数，即输出信息的格式，先把格式字符串中'%'之前的字符一个个输出，因为它们前面没有'%'，所以它们就是要直接显示在屏幕上的
  800321:	46                   	inc    %esi
  800322:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  800326:	83 c4 10             	add    $0x10,%esp
  800329:	83 f8 25             	cmp    $0x25,%eax
  80032c:	75 e4                	jne    800312 <vprintfmt+0x2b>
			if (width < 0)									//代表有小数点，但是小数点前面并没有数字，比如'%.6f'这种情况，此时代表整数部分全部显示
				width = 0;			
			goto reswitch;

		case '#':
			altflag = 1;
  80032e:	c6 45 e3 20          	movb   $0x20,-0x1d(%ebp)
  800332:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800339:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800340:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800347:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  80034e:	eb 07                	jmp    800357 <vprintfmt+0x70>
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  800350:	8b 75 10             	mov    0x10(%ebp),%esi

		// flag to pad on the right
		case '-':											//%后面的'-'代表要进行左对齐输出，右边填空格，如果省略代表右对齐
			padc = '-';										//如果有这个字符代表左对齐，则把对齐方式标志位变为'-'
  800353:	c6 45 e3 2d          	movb   $0x2d,-0x1d(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  800357:	8d 46 01             	lea    0x1(%esi),%eax
  80035a:	89 45 10             	mov    %eax,0x10(%ebp)
  80035d:	0f b6 16             	movzbl (%esi),%edx
  800360:	8a 06                	mov    (%esi),%al
  800362:	83 e8 23             	sub    $0x23,%eax
  800365:	3c 55                	cmp    $0x55,%al
  800367:	0f 87 03 03 00 00    	ja     800670 <vprintfmt+0x389>
  80036d:	0f b6 c0             	movzbl %al,%eax
  800370:	ff 24 85 20 24 80 00 	jmp    *0x802420(,%eax,4)
  800377:	8b 75 10             	mov    0x10(%ebp),%esi
			padc = '-';										//如果有这个字符代表左对齐，则把对齐方式标志位变为'-'
			goto reswitch;									//处理下一个字符

		// flag to pad with 0's instead of spaces
		case '0':											//0--有0表示进行对齐输出时填0,如省略表示填入空格，并且如果为0，则一定是右对齐
			padc = '0';										//对其方式标志位变为0
  80037a:	c6 45 e3 30          	movb   $0x30,-0x1d(%ebp)
  80037e:	eb d7                	jmp    800357 <vprintfmt+0x70>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {					//把遇到的位数字符串转换为真实的位数，比如输入的'%40'，代表有效位数为40位，下面的循环就是把precesion的值设置为40
				precision = precision * 10 + ch - '0';
  800380:	8d 42 d0             	lea    -0x30(%edx),%eax
  800383:	89 c1                	mov    %eax,%ecx
  800385:	89 45 d0             	mov    %eax,-0x30(%ebp)
				ch = *fmt;
  800388:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  80038c:	8d 50 d0             	lea    -0x30(%eax),%edx
  80038f:	83 fa 09             	cmp    $0x9,%edx
  800392:	77 51                	ja     8003e5 <vprintfmt+0xfe>
  800394:	8b 75 10             	mov    0x10(%ebp),%esi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {					//把遇到的位数字符串转换为真实的位数，比如输入的'%40'，代表有效位数为40位，下面的循环就是把precesion的值设置为40
  800397:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  800398:	8d 14 89             	lea    (%ecx,%ecx,4),%edx
  80039b:	01 d2                	add    %edx,%edx
  80039d:	8d 4c 10 d0          	lea    -0x30(%eax,%edx,1),%ecx
				ch = *fmt;
  8003a1:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8003a4:	8d 50 d0             	lea    -0x30(%eax),%edx
  8003a7:	83 fa 09             	cmp    $0x9,%edx
  8003aa:	76 eb                	jbe    800397 <vprintfmt+0xb0>
  8003ac:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8003af:	eb 37                	jmp    8003e8 <vprintfmt+0x101>
					break;
			}
			goto process_precision;							//跳转到process_precistion子过程

		case '*':											//*--代表有效数字的位数也是由输入参数指定的，比如printf("%*.*f", 10, 2, n)，其中10,2就是用来指定显示的有效数字位数的
			precision = va_arg(ap, int);
  8003b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b4:	8d 50 04             	lea    0x4(%eax),%edx
  8003b7:	89 55 14             	mov    %edx,0x14(%ebp)
  8003ba:	8b 00                	mov    (%eax),%eax
  8003bc:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  8003bf:	8b 75 10             	mov    0x10(%ebp),%esi
			}
			goto process_precision;							//跳转到process_precistion子过程

		case '*':											//*--代表有效数字的位数也是由输入参数指定的，比如printf("%*.*f", 10, 2, n)，其中10,2就是用来指定显示的有效数字位数的
			precision = va_arg(ap, int);
			goto process_precision;
  8003c2:	eb 24                	jmp    8003e8 <vprintfmt+0x101>
  8003c4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003c8:	79 07                	jns    8003d1 <vprintfmt+0xea>
  8003ca:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  8003d1:	8b 75 10             	mov    0x10(%ebp),%esi
  8003d4:	eb 81                	jmp    800357 <vprintfmt+0x70>
  8003d6:	8b 75 10             	mov    0x10(%ebp),%esi
			if (width < 0)									//代表有小数点，但是小数点前面并没有数字，比如'%.6f'这种情况，此时代表整数部分全部显示
				width = 0;			
			goto reswitch;

		case '#':
			altflag = 1;
  8003d9:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003e0:	e9 72 ff ff ff       	jmp    800357 <vprintfmt+0x70>
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  8003e5:	8b 75 10             	mov    0x10(%ebp),%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:									//处理输出精度，把width字段赋值为刚刚计算出来的precision值，所以width应该是整数部分的有效数字位数
			if (width < 0)
  8003e8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003ec:	0f 89 65 ff ff ff    	jns    800357 <vprintfmt+0x70>
				width = precision, precision = -1;
  8003f2:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003f5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003f8:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003ff:	e9 53 ff ff ff       	jmp    800357 <vprintfmt+0x70>
			goto reswitch;

		// long flag (doubled for long long)				
		case 'l':											//如果遇到'l'，代表应该是输入long类型，如果有两个'l'代表long long
			lflag++;										//此时把lflag++
  800404:	ff 45 d4             	incl   -0x2c(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  800407:	8b 75 10             	mov    0x10(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)				
		case 'l':											//如果遇到'l'，代表应该是输入long类型，如果有两个'l'代表long long
			lflag++;										//此时把lflag++
			goto reswitch;
  80040a:	e9 48 ff ff ff       	jmp    800357 <vprintfmt+0x70>

		// character
		case 'c':											//如果是'c'代表显示一个字符
			putch(va_arg(ap, int), putdat);					//调用输出一个字符到内存的函数putch
  80040f:	8b 45 14             	mov    0x14(%ebp),%eax
  800412:	8d 50 04             	lea    0x4(%eax),%edx
  800415:	89 55 14             	mov    %edx,0x14(%ebp)
  800418:	83 ec 08             	sub    $0x8,%esp
  80041b:	53                   	push   %ebx
  80041c:	ff 30                	pushl  (%eax)
  80041e:	ff d7                	call   *%edi
			break;
  800420:	83 c4 10             	add    $0x10,%esp
  800423:	e9 d3 fe ff ff       	jmp    8002fb <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800428:	8b 45 14             	mov    0x14(%ebp),%eax
  80042b:	8d 50 04             	lea    0x4(%eax),%edx
  80042e:	89 55 14             	mov    %edx,0x14(%ebp)
  800431:	8b 00                	mov    (%eax),%eax
  800433:	85 c0                	test   %eax,%eax
  800435:	79 02                	jns    800439 <vprintfmt+0x152>
  800437:	f7 d8                	neg    %eax
  800439:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80043b:	83 f8 0f             	cmp    $0xf,%eax
  80043e:	7f 0b                	jg     80044b <vprintfmt+0x164>
  800440:	8b 04 85 80 25 80 00 	mov    0x802580(,%eax,4),%eax
  800447:	85 c0                	test   %eax,%eax
  800449:	75 15                	jne    800460 <vprintfmt+0x179>
				printfmt(putch, putdat, "error %d", err);
  80044b:	52                   	push   %edx
  80044c:	68 f8 22 80 00       	push   $0x8022f8
  800451:	53                   	push   %ebx
  800452:	57                   	push   %edi
  800453:	e8 72 fe ff ff       	call   8002ca <printfmt>
  800458:	83 c4 10             	add    $0x10,%esp
  80045b:	e9 9b fe ff ff       	jmp    8002fb <vprintfmt+0x14>
			else
				printfmt(putch, putdat, "%s", p);
  800460:	50                   	push   %eax
  800461:	68 87 27 80 00       	push   $0x802787
  800466:	53                   	push   %ebx
  800467:	57                   	push   %edi
  800468:	e8 5d fe ff ff       	call   8002ca <printfmt>
  80046d:	83 c4 10             	add    $0x10,%esp
  800470:	e9 86 fe ff ff       	jmp    8002fb <vprintfmt+0x14>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800475:	8b 45 14             	mov    0x14(%ebp),%eax
  800478:	8d 50 04             	lea    0x4(%eax),%edx
  80047b:	89 55 14             	mov    %edx,0x14(%ebp)
  80047e:	8b 00                	mov    (%eax),%eax
  800480:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800483:	85 c0                	test   %eax,%eax
  800485:	75 07                	jne    80048e <vprintfmt+0x1a7>
				p = "(null)";
  800487:	c7 45 d4 f1 22 80 00 	movl   $0x8022f1,-0x2c(%ebp)
			if (width > 0 && padc != '-')
  80048e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800491:	85 f6                	test   %esi,%esi
  800493:	0f 8e fb 01 00 00    	jle    800694 <vprintfmt+0x3ad>
  800499:	80 7d e3 2d          	cmpb   $0x2d,-0x1d(%ebp)
  80049d:	0f 84 09 02 00 00    	je     8006ac <vprintfmt+0x3c5>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a3:	83 ec 08             	sub    $0x8,%esp
  8004a6:	ff 75 d0             	pushl  -0x30(%ebp)
  8004a9:	ff 75 d4             	pushl  -0x2c(%ebp)
  8004ac:	e8 ad 02 00 00       	call   80075e <strnlen>
  8004b1:	89 f1                	mov    %esi,%ecx
  8004b3:	29 c1                	sub    %eax,%ecx
  8004b5:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  8004b8:	83 c4 10             	add    $0x10,%esp
  8004bb:	85 c9                	test   %ecx,%ecx
  8004bd:	0f 8e d1 01 00 00    	jle    800694 <vprintfmt+0x3ad>
					putch(padc, putdat);
  8004c3:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  8004c7:	83 ec 08             	sub    $0x8,%esp
  8004ca:	53                   	push   %ebx
  8004cb:	56                   	push   %esi
  8004cc:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ce:	83 c4 10             	add    $0x10,%esp
  8004d1:	ff 4d e4             	decl   -0x1c(%ebp)
  8004d4:	75 f1                	jne    8004c7 <vprintfmt+0x1e0>
  8004d6:	e9 b9 01 00 00       	jmp    800694 <vprintfmt+0x3ad>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004db:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004df:	74 19                	je     8004fa <vprintfmt+0x213>
  8004e1:	0f be c0             	movsbl %al,%eax
  8004e4:	83 e8 20             	sub    $0x20,%eax
  8004e7:	83 f8 5e             	cmp    $0x5e,%eax
  8004ea:	76 0e                	jbe    8004fa <vprintfmt+0x213>
					putch('?', putdat);
  8004ec:	83 ec 08             	sub    $0x8,%esp
  8004ef:	53                   	push   %ebx
  8004f0:	6a 3f                	push   $0x3f
  8004f2:	ff 55 08             	call   *0x8(%ebp)
  8004f5:	83 c4 10             	add    $0x10,%esp
  8004f8:	eb 0b                	jmp    800505 <vprintfmt+0x21e>
				else
					putch(ch, putdat);
  8004fa:	83 ec 08             	sub    $0x8,%esp
  8004fd:	53                   	push   %ebx
  8004fe:	52                   	push   %edx
  8004ff:	ff 55 08             	call   *0x8(%ebp)
  800502:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800505:	ff 4d e4             	decl   -0x1c(%ebp)
  800508:	46                   	inc    %esi
  800509:	8a 46 ff             	mov    -0x1(%esi),%al
  80050c:	0f be d0             	movsbl %al,%edx
  80050f:	85 d2                	test   %edx,%edx
  800511:	75 1c                	jne    80052f <vprintfmt+0x248>
  800513:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800516:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80051a:	7f 1f                	jg     80053b <vprintfmt+0x254>
  80051c:	e9 da fd ff ff       	jmp    8002fb <vprintfmt+0x14>
  800521:	89 7d 08             	mov    %edi,0x8(%ebp)
  800524:	8b 7d d0             	mov    -0x30(%ebp),%edi
  800527:	eb 06                	jmp    80052f <vprintfmt+0x248>
  800529:	89 7d 08             	mov    %edi,0x8(%ebp)
  80052c:	8b 7d d0             	mov    -0x30(%ebp),%edi
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80052f:	85 ff                	test   %edi,%edi
  800531:	78 a8                	js     8004db <vprintfmt+0x1f4>
  800533:	4f                   	dec    %edi
  800534:	79 a5                	jns    8004db <vprintfmt+0x1f4>
  800536:	8b 7d 08             	mov    0x8(%ebp),%edi
  800539:	eb db                	jmp    800516 <vprintfmt+0x22f>
  80053b:	8b 75 e4             	mov    -0x1c(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80053e:	83 ec 08             	sub    $0x8,%esp
  800541:	53                   	push   %ebx
  800542:	6a 20                	push   $0x20
  800544:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800546:	4e                   	dec    %esi
  800547:	83 c4 10             	add    $0x10,%esp
  80054a:	85 f6                	test   %esi,%esi
  80054c:	7f f0                	jg     80053e <vprintfmt+0x257>
  80054e:	e9 a8 fd ff ff       	jmp    8002fb <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800553:	83 7d d4 01          	cmpl   $0x1,-0x2c(%ebp)
  800557:	7e 16                	jle    80056f <vprintfmt+0x288>
		return va_arg(*ap, long long);
  800559:	8b 45 14             	mov    0x14(%ebp),%eax
  80055c:	8d 50 08             	lea    0x8(%eax),%edx
  80055f:	89 55 14             	mov    %edx,0x14(%ebp)
  800562:	8b 50 04             	mov    0x4(%eax),%edx
  800565:	8b 00                	mov    (%eax),%eax
  800567:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80056a:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80056d:	eb 34                	jmp    8005a3 <vprintfmt+0x2bc>
	else if (lflag)
  80056f:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800573:	74 18                	je     80058d <vprintfmt+0x2a6>
		return va_arg(*ap, long);
  800575:	8b 45 14             	mov    0x14(%ebp),%eax
  800578:	8d 50 04             	lea    0x4(%eax),%edx
  80057b:	89 55 14             	mov    %edx,0x14(%ebp)
  80057e:	8b 30                	mov    (%eax),%esi
  800580:	89 75 d8             	mov    %esi,-0x28(%ebp)
  800583:	89 f0                	mov    %esi,%eax
  800585:	c1 f8 1f             	sar    $0x1f,%eax
  800588:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80058b:	eb 16                	jmp    8005a3 <vprintfmt+0x2bc>
	else
		return va_arg(*ap, int);
  80058d:	8b 45 14             	mov    0x14(%ebp),%eax
  800590:	8d 50 04             	lea    0x4(%eax),%edx
  800593:	89 55 14             	mov    %edx,0x14(%ebp)
  800596:	8b 30                	mov    (%eax),%esi
  800598:	89 75 d8             	mov    %esi,-0x28(%ebp)
  80059b:	89 f0                	mov    %esi,%eax
  80059d:	c1 f8 1f             	sar    $0x1f,%eax
  8005a0:	89 45 dc             	mov    %eax,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005a3:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005a6:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
  8005a9:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005ad:	0f 89 8a 00 00 00    	jns    80063d <vprintfmt+0x356>
				putch('-', putdat);
  8005b3:	83 ec 08             	sub    $0x8,%esp
  8005b6:	53                   	push   %ebx
  8005b7:	6a 2d                	push   $0x2d
  8005b9:	ff d7                	call   *%edi
				num = -(long long) num;
  8005bb:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005be:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005c1:	f7 d8                	neg    %eax
  8005c3:	83 d2 00             	adc    $0x0,%edx
  8005c6:	f7 da                	neg    %edx
  8005c8:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005cb:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8005d0:	eb 70                	jmp    800642 <vprintfmt+0x35b>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005d2:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8005d5:	8d 45 14             	lea    0x14(%ebp),%eax
  8005d8:	e8 97 fc ff ff       	call   800274 <getuint>
			base = 10;
  8005dd:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8005e2:	eb 5e                	jmp    800642 <vprintfmt+0x35b>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
  8005e4:	83 ec 08             	sub    $0x8,%esp
  8005e7:	53                   	push   %ebx
  8005e8:	6a 30                	push   $0x30
  8005ea:	ff d7                	call   *%edi
			num = getuint(&ap, lflag);
  8005ec:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8005ef:	8d 45 14             	lea    0x14(%ebp),%eax
  8005f2:	e8 7d fc ff ff       	call   800274 <getuint>
			base = 8;
			goto number;
  8005f7:	83 c4 10             	add    $0x10,%esp
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  8005fa:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8005ff:	eb 41                	jmp    800642 <vprintfmt+0x35b>
		// pointer
		case 'p':
			putch('0', putdat);
  800601:	83 ec 08             	sub    $0x8,%esp
  800604:	53                   	push   %ebx
  800605:	6a 30                	push   $0x30
  800607:	ff d7                	call   *%edi
			putch('x', putdat);
  800609:	83 c4 08             	add    $0x8,%esp
  80060c:	53                   	push   %ebx
  80060d:	6a 78                	push   $0x78
  80060f:	ff d7                	call   *%edi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800611:	8b 45 14             	mov    0x14(%ebp),%eax
  800614:	8d 50 04             	lea    0x4(%eax),%edx
  800617:	89 55 14             	mov    %edx,0x14(%ebp)
			goto number;
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80061a:	8b 00                	mov    (%eax),%eax
  80061c:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800621:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800624:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800629:	eb 17                	jmp    800642 <vprintfmt+0x35b>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80062b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80062e:	8d 45 14             	lea    0x14(%ebp),%eax
  800631:	e8 3e fc ff ff       	call   800274 <getuint>
			base = 16;
  800636:	b9 10 00 00 00       	mov    $0x10,%ecx
  80063b:	eb 05                	jmp    800642 <vprintfmt+0x35b>
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80063d:	b9 0a 00 00 00       	mov    $0xa,%ecx
		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  800642:	83 ec 0c             	sub    $0xc,%esp
  800645:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  800649:	56                   	push   %esi
  80064a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80064d:	51                   	push   %ecx
  80064e:	52                   	push   %edx
  80064f:	50                   	push   %eax
  800650:	89 da                	mov    %ebx,%edx
  800652:	89 f8                	mov    %edi,%eax
  800654:	e8 6b fb ff ff       	call   8001c4 <printnum>
			break;
  800659:	83 c4 20             	add    $0x20,%esp
  80065c:	e9 9a fc ff ff       	jmp    8002fb <vprintfmt+0x14>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800661:	83 ec 08             	sub    $0x8,%esp
  800664:	53                   	push   %ebx
  800665:	52                   	push   %edx
  800666:	ff d7                	call   *%edi
			break;
  800668:	83 c4 10             	add    $0x10,%esp
  80066b:	e9 8b fc ff ff       	jmp    8002fb <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800670:	83 ec 08             	sub    $0x8,%esp
  800673:	53                   	push   %ebx
  800674:	6a 25                	push   $0x25
  800676:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800678:	83 c4 10             	add    $0x10,%esp
  80067b:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80067f:	0f 84 73 fc ff ff    	je     8002f8 <vprintfmt+0x11>
  800685:	4e                   	dec    %esi
  800686:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80068a:	75 f9                	jne    800685 <vprintfmt+0x39e>
  80068c:	89 75 10             	mov    %esi,0x10(%ebp)
  80068f:	e9 67 fc ff ff       	jmp    8002fb <vprintfmt+0x14>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800694:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800697:	8d 70 01             	lea    0x1(%eax),%esi
  80069a:	8a 00                	mov    (%eax),%al
  80069c:	0f be d0             	movsbl %al,%edx
  80069f:	85 d2                	test   %edx,%edx
  8006a1:	0f 85 7a fe ff ff    	jne    800521 <vprintfmt+0x23a>
  8006a7:	e9 4f fc ff ff       	jmp    8002fb <vprintfmt+0x14>
  8006ac:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8006af:	8d 70 01             	lea    0x1(%eax),%esi
  8006b2:	8a 00                	mov    (%eax),%al
  8006b4:	0f be d0             	movsbl %al,%edx
  8006b7:	85 d2                	test   %edx,%edx
  8006b9:	0f 85 6a fe ff ff    	jne    800529 <vprintfmt+0x242>
  8006bf:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8006c2:	e9 77 fe ff ff       	jmp    80053e <vprintfmt+0x257>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  8006c7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006ca:	5b                   	pop    %ebx
  8006cb:	5e                   	pop    %esi
  8006cc:	5f                   	pop    %edi
  8006cd:	5d                   	pop    %ebp
  8006ce:	c3                   	ret    

008006cf <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006cf:	55                   	push   %ebp
  8006d0:	89 e5                	mov    %esp,%ebp
  8006d2:	83 ec 18             	sub    $0x18,%esp
  8006d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8006d8:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006db:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006de:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006e2:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006e5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006ec:	85 c0                	test   %eax,%eax
  8006ee:	74 26                	je     800716 <vsnprintf+0x47>
  8006f0:	85 d2                	test   %edx,%edx
  8006f2:	7e 29                	jle    80071d <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006f4:	ff 75 14             	pushl  0x14(%ebp)
  8006f7:	ff 75 10             	pushl  0x10(%ebp)
  8006fa:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006fd:	50                   	push   %eax
  8006fe:	68 ae 02 80 00       	push   $0x8002ae
  800703:	e8 df fb ff ff       	call   8002e7 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800708:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80070b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80070e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800711:	83 c4 10             	add    $0x10,%esp
  800714:	eb 0c                	jmp    800722 <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800716:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80071b:	eb 05                	jmp    800722 <vsnprintf+0x53>
  80071d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800722:	c9                   	leave  
  800723:	c3                   	ret    

00800724 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800724:	55                   	push   %ebp
  800725:	89 e5                	mov    %esp,%ebp
  800727:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80072a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80072d:	50                   	push   %eax
  80072e:	ff 75 10             	pushl  0x10(%ebp)
  800731:	ff 75 0c             	pushl  0xc(%ebp)
  800734:	ff 75 08             	pushl  0x8(%ebp)
  800737:	e8 93 ff ff ff       	call   8006cf <vsnprintf>
	va_end(ap);

	return rc;
}
  80073c:	c9                   	leave  
  80073d:	c3                   	ret    

0080073e <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80073e:	55                   	push   %ebp
  80073f:	89 e5                	mov    %esp,%ebp
  800741:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800744:	80 3a 00             	cmpb   $0x0,(%edx)
  800747:	74 0e                	je     800757 <strlen+0x19>
  800749:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  80074e:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80074f:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800753:	75 f9                	jne    80074e <strlen+0x10>
  800755:	eb 05                	jmp    80075c <strlen+0x1e>
  800757:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  80075c:	5d                   	pop    %ebp
  80075d:	c3                   	ret    

0080075e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80075e:	55                   	push   %ebp
  80075f:	89 e5                	mov    %esp,%ebp
  800761:	53                   	push   %ebx
  800762:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800765:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800768:	85 c9                	test   %ecx,%ecx
  80076a:	74 1a                	je     800786 <strnlen+0x28>
  80076c:	80 3b 00             	cmpb   $0x0,(%ebx)
  80076f:	74 1c                	je     80078d <strnlen+0x2f>
  800771:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  800776:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800778:	39 ca                	cmp    %ecx,%edx
  80077a:	74 16                	je     800792 <strnlen+0x34>
  80077c:	42                   	inc    %edx
  80077d:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800782:	75 f2                	jne    800776 <strnlen+0x18>
  800784:	eb 0c                	jmp    800792 <strnlen+0x34>
  800786:	b8 00 00 00 00       	mov    $0x0,%eax
  80078b:	eb 05                	jmp    800792 <strnlen+0x34>
  80078d:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800792:	5b                   	pop    %ebx
  800793:	5d                   	pop    %ebp
  800794:	c3                   	ret    

00800795 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800795:	55                   	push   %ebp
  800796:	89 e5                	mov    %esp,%ebp
  800798:	53                   	push   %ebx
  800799:	8b 45 08             	mov    0x8(%ebp),%eax
  80079c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80079f:	89 c2                	mov    %eax,%edx
  8007a1:	42                   	inc    %edx
  8007a2:	41                   	inc    %ecx
  8007a3:	8a 59 ff             	mov    -0x1(%ecx),%bl
  8007a6:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007a9:	84 db                	test   %bl,%bl
  8007ab:	75 f4                	jne    8007a1 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007ad:	5b                   	pop    %ebx
  8007ae:	5d                   	pop    %ebp
  8007af:	c3                   	ret    

008007b0 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007b0:	55                   	push   %ebp
  8007b1:	89 e5                	mov    %esp,%ebp
  8007b3:	53                   	push   %ebx
  8007b4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007b7:	53                   	push   %ebx
  8007b8:	e8 81 ff ff ff       	call   80073e <strlen>
  8007bd:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007c0:	ff 75 0c             	pushl  0xc(%ebp)
  8007c3:	01 d8                	add    %ebx,%eax
  8007c5:	50                   	push   %eax
  8007c6:	e8 ca ff ff ff       	call   800795 <strcpy>
	return dst;
}
  8007cb:	89 d8                	mov    %ebx,%eax
  8007cd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007d0:	c9                   	leave  
  8007d1:	c3                   	ret    

008007d2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007d2:	55                   	push   %ebp
  8007d3:	89 e5                	mov    %esp,%ebp
  8007d5:	56                   	push   %esi
  8007d6:	53                   	push   %ebx
  8007d7:	8b 75 08             	mov    0x8(%ebp),%esi
  8007da:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007dd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007e0:	85 db                	test   %ebx,%ebx
  8007e2:	74 14                	je     8007f8 <strncpy+0x26>
  8007e4:	01 f3                	add    %esi,%ebx
  8007e6:	89 f1                	mov    %esi,%ecx
		*dst++ = *src;
  8007e8:	41                   	inc    %ecx
  8007e9:	8a 02                	mov    (%edx),%al
  8007eb:	88 41 ff             	mov    %al,-0x1(%ecx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007ee:	80 3a 01             	cmpb   $0x1,(%edx)
  8007f1:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007f4:	39 cb                	cmp    %ecx,%ebx
  8007f6:	75 f0                	jne    8007e8 <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007f8:	89 f0                	mov    %esi,%eax
  8007fa:	5b                   	pop    %ebx
  8007fb:	5e                   	pop    %esi
  8007fc:	5d                   	pop    %ebp
  8007fd:	c3                   	ret    

008007fe <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007fe:	55                   	push   %ebp
  8007ff:	89 e5                	mov    %esp,%ebp
  800801:	53                   	push   %ebx
  800802:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800805:	8b 45 10             	mov    0x10(%ebp),%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800808:	85 c0                	test   %eax,%eax
  80080a:	74 30                	je     80083c <strlcpy+0x3e>
		while (--size > 0 && *src != '\0')
  80080c:	48                   	dec    %eax
  80080d:	74 20                	je     80082f <strlcpy+0x31>
  80080f:	8a 0b                	mov    (%ebx),%cl
  800811:	84 c9                	test   %cl,%cl
  800813:	74 1f                	je     800834 <strlcpy+0x36>
  800815:	8d 53 01             	lea    0x1(%ebx),%edx
  800818:	01 c3                	add    %eax,%ebx
  80081a:	8b 45 08             	mov    0x8(%ebp),%eax
			*dst++ = *src++;
  80081d:	40                   	inc    %eax
  80081e:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800821:	39 da                	cmp    %ebx,%edx
  800823:	74 12                	je     800837 <strlcpy+0x39>
  800825:	42                   	inc    %edx
  800826:	8a 4a ff             	mov    -0x1(%edx),%cl
  800829:	84 c9                	test   %cl,%cl
  80082b:	75 f0                	jne    80081d <strlcpy+0x1f>
  80082d:	eb 08                	jmp    800837 <strlcpy+0x39>
  80082f:	8b 45 08             	mov    0x8(%ebp),%eax
  800832:	eb 03                	jmp    800837 <strlcpy+0x39>
  800834:	8b 45 08             	mov    0x8(%ebp),%eax
			*dst++ = *src++;
		*dst = '\0';
  800837:	c6 00 00             	movb   $0x0,(%eax)
  80083a:	eb 03                	jmp    80083f <strlcpy+0x41>
  80083c:	8b 45 08             	mov    0x8(%ebp),%eax
	}
	return dst - dst_in;
  80083f:	2b 45 08             	sub    0x8(%ebp),%eax
}
  800842:	5b                   	pop    %ebx
  800843:	5d                   	pop    %ebp
  800844:	c3                   	ret    

00800845 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800845:	55                   	push   %ebp
  800846:	89 e5                	mov    %esp,%ebp
  800848:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80084b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80084e:	8a 01                	mov    (%ecx),%al
  800850:	84 c0                	test   %al,%al
  800852:	74 10                	je     800864 <strcmp+0x1f>
  800854:	3a 02                	cmp    (%edx),%al
  800856:	75 0c                	jne    800864 <strcmp+0x1f>
		p++, q++;
  800858:	41                   	inc    %ecx
  800859:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80085a:	8a 01                	mov    (%ecx),%al
  80085c:	84 c0                	test   %al,%al
  80085e:	74 04                	je     800864 <strcmp+0x1f>
  800860:	3a 02                	cmp    (%edx),%al
  800862:	74 f4                	je     800858 <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800864:	0f b6 c0             	movzbl %al,%eax
  800867:	0f b6 12             	movzbl (%edx),%edx
  80086a:	29 d0                	sub    %edx,%eax
}
  80086c:	5d                   	pop    %ebp
  80086d:	c3                   	ret    

0080086e <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80086e:	55                   	push   %ebp
  80086f:	89 e5                	mov    %esp,%ebp
  800871:	56                   	push   %esi
  800872:	53                   	push   %ebx
  800873:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800876:	8b 55 0c             	mov    0xc(%ebp),%edx
  800879:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  80087c:	85 f6                	test   %esi,%esi
  80087e:	74 23                	je     8008a3 <strncmp+0x35>
  800880:	8a 03                	mov    (%ebx),%al
  800882:	84 c0                	test   %al,%al
  800884:	74 2b                	je     8008b1 <strncmp+0x43>
  800886:	3a 02                	cmp    (%edx),%al
  800888:	75 27                	jne    8008b1 <strncmp+0x43>
  80088a:	8d 43 01             	lea    0x1(%ebx),%eax
  80088d:	01 de                	add    %ebx,%esi
		n--, p++, q++;
  80088f:	89 c3                	mov    %eax,%ebx
  800891:	42                   	inc    %edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800892:	39 c6                	cmp    %eax,%esi
  800894:	74 14                	je     8008aa <strncmp+0x3c>
  800896:	8a 08                	mov    (%eax),%cl
  800898:	84 c9                	test   %cl,%cl
  80089a:	74 15                	je     8008b1 <strncmp+0x43>
  80089c:	40                   	inc    %eax
  80089d:	3a 0a                	cmp    (%edx),%cl
  80089f:	74 ee                	je     80088f <strncmp+0x21>
  8008a1:	eb 0e                	jmp    8008b1 <strncmp+0x43>
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008a3:	b8 00 00 00 00       	mov    $0x0,%eax
  8008a8:	eb 0f                	jmp    8008b9 <strncmp+0x4b>
  8008aa:	b8 00 00 00 00       	mov    $0x0,%eax
  8008af:	eb 08                	jmp    8008b9 <strncmp+0x4b>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008b1:	0f b6 03             	movzbl (%ebx),%eax
  8008b4:	0f b6 12             	movzbl (%edx),%edx
  8008b7:	29 d0                	sub    %edx,%eax
}
  8008b9:	5b                   	pop    %ebx
  8008ba:	5e                   	pop    %esi
  8008bb:	5d                   	pop    %ebp
  8008bc:	c3                   	ret    

008008bd <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008bd:	55                   	push   %ebp
  8008be:	89 e5                	mov    %esp,%ebp
  8008c0:	53                   	push   %ebx
  8008c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  8008c7:	8a 10                	mov    (%eax),%dl
  8008c9:	84 d2                	test   %dl,%dl
  8008cb:	74 1a                	je     8008e7 <strchr+0x2a>
  8008cd:	88 d9                	mov    %bl,%cl
		if (*s == c)
  8008cf:	38 d3                	cmp    %dl,%bl
  8008d1:	75 06                	jne    8008d9 <strchr+0x1c>
  8008d3:	eb 17                	jmp    8008ec <strchr+0x2f>
  8008d5:	38 ca                	cmp    %cl,%dl
  8008d7:	74 13                	je     8008ec <strchr+0x2f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008d9:	40                   	inc    %eax
  8008da:	8a 10                	mov    (%eax),%dl
  8008dc:	84 d2                	test   %dl,%dl
  8008de:	75 f5                	jne    8008d5 <strchr+0x18>
		if (*s == c)
			return (char *) s;
	return 0;
  8008e0:	b8 00 00 00 00       	mov    $0x0,%eax
  8008e5:	eb 05                	jmp    8008ec <strchr+0x2f>
  8008e7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008ec:	5b                   	pop    %ebx
  8008ed:	5d                   	pop    %ebp
  8008ee:	c3                   	ret    

008008ef <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008ef:	55                   	push   %ebp
  8008f0:	89 e5                	mov    %esp,%ebp
  8008f2:	53                   	push   %ebx
  8008f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  8008f9:	8a 10                	mov    (%eax),%dl
  8008fb:	84 d2                	test   %dl,%dl
  8008fd:	74 13                	je     800912 <strfind+0x23>
  8008ff:	88 d9                	mov    %bl,%cl
		if (*s == c)
  800901:	38 d3                	cmp    %dl,%bl
  800903:	75 06                	jne    80090b <strfind+0x1c>
  800905:	eb 0b                	jmp    800912 <strfind+0x23>
  800907:	38 ca                	cmp    %cl,%dl
  800909:	74 07                	je     800912 <strfind+0x23>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80090b:	40                   	inc    %eax
  80090c:	8a 10                	mov    (%eax),%dl
  80090e:	84 d2                	test   %dl,%dl
  800910:	75 f5                	jne    800907 <strfind+0x18>
		if (*s == c)
			break;
	return (char *) s;
}
  800912:	5b                   	pop    %ebx
  800913:	5d                   	pop    %ebp
  800914:	c3                   	ret    

00800915 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800915:	55                   	push   %ebp
  800916:	89 e5                	mov    %esp,%ebp
  800918:	57                   	push   %edi
  800919:	56                   	push   %esi
  80091a:	53                   	push   %ebx
  80091b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80091e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800921:	85 c9                	test   %ecx,%ecx
  800923:	74 36                	je     80095b <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800925:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80092b:	75 28                	jne    800955 <memset+0x40>
  80092d:	f6 c1 03             	test   $0x3,%cl
  800930:	75 23                	jne    800955 <memset+0x40>
		c &= 0xFF;
  800932:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800936:	89 d3                	mov    %edx,%ebx
  800938:	c1 e3 08             	shl    $0x8,%ebx
  80093b:	89 d6                	mov    %edx,%esi
  80093d:	c1 e6 18             	shl    $0x18,%esi
  800940:	89 d0                	mov    %edx,%eax
  800942:	c1 e0 10             	shl    $0x10,%eax
  800945:	09 f0                	or     %esi,%eax
  800947:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800949:	89 d8                	mov    %ebx,%eax
  80094b:	09 d0                	or     %edx,%eax
  80094d:	c1 e9 02             	shr    $0x2,%ecx
  800950:	fc                   	cld    
  800951:	f3 ab                	rep stos %eax,%es:(%edi)
  800953:	eb 06                	jmp    80095b <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800955:	8b 45 0c             	mov    0xc(%ebp),%eax
  800958:	fc                   	cld    
  800959:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80095b:	89 f8                	mov    %edi,%eax
  80095d:	5b                   	pop    %ebx
  80095e:	5e                   	pop    %esi
  80095f:	5f                   	pop    %edi
  800960:	5d                   	pop    %ebp
  800961:	c3                   	ret    

00800962 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800962:	55                   	push   %ebp
  800963:	89 e5                	mov    %esp,%ebp
  800965:	57                   	push   %edi
  800966:	56                   	push   %esi
  800967:	8b 45 08             	mov    0x8(%ebp),%eax
  80096a:	8b 75 0c             	mov    0xc(%ebp),%esi
  80096d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800970:	39 c6                	cmp    %eax,%esi
  800972:	73 33                	jae    8009a7 <memmove+0x45>
  800974:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800977:	39 d0                	cmp    %edx,%eax
  800979:	73 2c                	jae    8009a7 <memmove+0x45>
		s += n;
		d += n;
  80097b:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80097e:	89 d6                	mov    %edx,%esi
  800980:	09 fe                	or     %edi,%esi
  800982:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800988:	75 13                	jne    80099d <memmove+0x3b>
  80098a:	f6 c1 03             	test   $0x3,%cl
  80098d:	75 0e                	jne    80099d <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  80098f:	83 ef 04             	sub    $0x4,%edi
  800992:	8d 72 fc             	lea    -0x4(%edx),%esi
  800995:	c1 e9 02             	shr    $0x2,%ecx
  800998:	fd                   	std    
  800999:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80099b:	eb 07                	jmp    8009a4 <memmove+0x42>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80099d:	4f                   	dec    %edi
  80099e:	8d 72 ff             	lea    -0x1(%edx),%esi
  8009a1:	fd                   	std    
  8009a2:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009a4:	fc                   	cld    
  8009a5:	eb 1d                	jmp    8009c4 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009a7:	89 f2                	mov    %esi,%edx
  8009a9:	09 c2                	or     %eax,%edx
  8009ab:	f6 c2 03             	test   $0x3,%dl
  8009ae:	75 0f                	jne    8009bf <memmove+0x5d>
  8009b0:	f6 c1 03             	test   $0x3,%cl
  8009b3:	75 0a                	jne    8009bf <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
  8009b5:	c1 e9 02             	shr    $0x2,%ecx
  8009b8:	89 c7                	mov    %eax,%edi
  8009ba:	fc                   	cld    
  8009bb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009bd:	eb 05                	jmp    8009c4 <memmove+0x62>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009bf:	89 c7                	mov    %eax,%edi
  8009c1:	fc                   	cld    
  8009c2:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009c4:	5e                   	pop    %esi
  8009c5:	5f                   	pop    %edi
  8009c6:	5d                   	pop    %ebp
  8009c7:	c3                   	ret    

008009c8 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009c8:	55                   	push   %ebp
  8009c9:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009cb:	ff 75 10             	pushl  0x10(%ebp)
  8009ce:	ff 75 0c             	pushl  0xc(%ebp)
  8009d1:	ff 75 08             	pushl  0x8(%ebp)
  8009d4:	e8 89 ff ff ff       	call   800962 <memmove>
}
  8009d9:	c9                   	leave  
  8009da:	c3                   	ret    

008009db <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009db:	55                   	push   %ebp
  8009dc:	89 e5                	mov    %esp,%ebp
  8009de:	57                   	push   %edi
  8009df:	56                   	push   %esi
  8009e0:	53                   	push   %ebx
  8009e1:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8009e4:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009e7:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009ea:	85 c0                	test   %eax,%eax
  8009ec:	74 33                	je     800a21 <memcmp+0x46>
  8009ee:	8d 78 ff             	lea    -0x1(%eax),%edi
		if (*s1 != *s2)
  8009f1:	8a 13                	mov    (%ebx),%dl
  8009f3:	8a 0e                	mov    (%esi),%cl
  8009f5:	38 ca                	cmp    %cl,%dl
  8009f7:	75 13                	jne    800a0c <memcmp+0x31>
  8009f9:	b8 00 00 00 00       	mov    $0x0,%eax
  8009fe:	eb 16                	jmp    800a16 <memcmp+0x3b>
  800a00:	8a 54 03 01          	mov    0x1(%ebx,%eax,1),%dl
  800a04:	40                   	inc    %eax
  800a05:	8a 0c 06             	mov    (%esi,%eax,1),%cl
  800a08:	38 ca                	cmp    %cl,%dl
  800a0a:	74 0a                	je     800a16 <memcmp+0x3b>
			return (int) *s1 - (int) *s2;
  800a0c:	0f b6 c2             	movzbl %dl,%eax
  800a0f:	0f b6 c9             	movzbl %cl,%ecx
  800a12:	29 c8                	sub    %ecx,%eax
  800a14:	eb 10                	jmp    800a26 <memcmp+0x4b>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a16:	39 f8                	cmp    %edi,%eax
  800a18:	75 e6                	jne    800a00 <memcmp+0x25>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a1a:	b8 00 00 00 00       	mov    $0x0,%eax
  800a1f:	eb 05                	jmp    800a26 <memcmp+0x4b>
  800a21:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a26:	5b                   	pop    %ebx
  800a27:	5e                   	pop    %esi
  800a28:	5f                   	pop    %edi
  800a29:	5d                   	pop    %ebp
  800a2a:	c3                   	ret    

00800a2b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a2b:	55                   	push   %ebp
  800a2c:	89 e5                	mov    %esp,%ebp
  800a2e:	53                   	push   %ebx
  800a2f:	8b 55 08             	mov    0x8(%ebp),%edx
	const void *ends = (const char *) s + n;
  800a32:	89 d0                	mov    %edx,%eax
  800a34:	03 45 10             	add    0x10(%ebp),%eax
	for (; s < ends; s++)
  800a37:	39 c2                	cmp    %eax,%edx
  800a39:	73 1b                	jae    800a56 <memfind+0x2b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a3b:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
  800a3f:	0f b6 0a             	movzbl (%edx),%ecx
  800a42:	39 d9                	cmp    %ebx,%ecx
  800a44:	75 09                	jne    800a4f <memfind+0x24>
  800a46:	eb 12                	jmp    800a5a <memfind+0x2f>
  800a48:	0f b6 0a             	movzbl (%edx),%ecx
  800a4b:	39 d9                	cmp    %ebx,%ecx
  800a4d:	74 0f                	je     800a5e <memfind+0x33>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a4f:	42                   	inc    %edx
  800a50:	39 d0                	cmp    %edx,%eax
  800a52:	75 f4                	jne    800a48 <memfind+0x1d>
  800a54:	eb 0a                	jmp    800a60 <memfind+0x35>
  800a56:	89 d0                	mov    %edx,%eax
  800a58:	eb 06                	jmp    800a60 <memfind+0x35>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a5a:	89 d0                	mov    %edx,%eax
  800a5c:	eb 02                	jmp    800a60 <memfind+0x35>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a5e:	89 d0                	mov    %edx,%eax
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a60:	5b                   	pop    %ebx
  800a61:	5d                   	pop    %ebp
  800a62:	c3                   	ret    

00800a63 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a63:	55                   	push   %ebp
  800a64:	89 e5                	mov    %esp,%ebp
  800a66:	57                   	push   %edi
  800a67:	56                   	push   %esi
  800a68:	53                   	push   %ebx
  800a69:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a6c:	eb 01                	jmp    800a6f <strtol+0xc>
		s++;
  800a6e:	41                   	inc    %ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a6f:	8a 01                	mov    (%ecx),%al
  800a71:	3c 20                	cmp    $0x20,%al
  800a73:	74 f9                	je     800a6e <strtol+0xb>
  800a75:	3c 09                	cmp    $0x9,%al
  800a77:	74 f5                	je     800a6e <strtol+0xb>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a79:	3c 2b                	cmp    $0x2b,%al
  800a7b:	75 08                	jne    800a85 <strtol+0x22>
		s++;
  800a7d:	41                   	inc    %ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a7e:	bf 00 00 00 00       	mov    $0x0,%edi
  800a83:	eb 11                	jmp    800a96 <strtol+0x33>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a85:	3c 2d                	cmp    $0x2d,%al
  800a87:	75 08                	jne    800a91 <strtol+0x2e>
		s++, neg = 1;
  800a89:	41                   	inc    %ecx
  800a8a:	bf 01 00 00 00       	mov    $0x1,%edi
  800a8f:	eb 05                	jmp    800a96 <strtol+0x33>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a91:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a96:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800a9a:	0f 84 87 00 00 00    	je     800b27 <strtol+0xc4>
  800aa0:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  800aa4:	75 27                	jne    800acd <strtol+0x6a>
  800aa6:	80 39 30             	cmpb   $0x30,(%ecx)
  800aa9:	75 22                	jne    800acd <strtol+0x6a>
  800aab:	e9 88 00 00 00       	jmp    800b38 <strtol+0xd5>
		s += 2, base = 16;
  800ab0:	83 c1 02             	add    $0x2,%ecx
  800ab3:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  800aba:	eb 11                	jmp    800acd <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
  800abc:	41                   	inc    %ecx
  800abd:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  800ac4:	eb 07                	jmp    800acd <strtol+0x6a>
	else if (base == 0)
		base = 10;
  800ac6:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)
  800acd:	b8 00 00 00 00       	mov    $0x0,%eax

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ad2:	8a 11                	mov    (%ecx),%dl
  800ad4:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800ad7:	80 fb 09             	cmp    $0x9,%bl
  800ada:	77 08                	ja     800ae4 <strtol+0x81>
			dig = *s - '0';
  800adc:	0f be d2             	movsbl %dl,%edx
  800adf:	83 ea 30             	sub    $0x30,%edx
  800ae2:	eb 22                	jmp    800b06 <strtol+0xa3>
		else if (*s >= 'a' && *s <= 'z')
  800ae4:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ae7:	89 f3                	mov    %esi,%ebx
  800ae9:	80 fb 19             	cmp    $0x19,%bl
  800aec:	77 08                	ja     800af6 <strtol+0x93>
			dig = *s - 'a' + 10;
  800aee:	0f be d2             	movsbl %dl,%edx
  800af1:	83 ea 57             	sub    $0x57,%edx
  800af4:	eb 10                	jmp    800b06 <strtol+0xa3>
		else if (*s >= 'A' && *s <= 'Z')
  800af6:	8d 72 bf             	lea    -0x41(%edx),%esi
  800af9:	89 f3                	mov    %esi,%ebx
  800afb:	80 fb 19             	cmp    $0x19,%bl
  800afe:	77 14                	ja     800b14 <strtol+0xb1>
			dig = *s - 'A' + 10;
  800b00:	0f be d2             	movsbl %dl,%edx
  800b03:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b06:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b09:	7d 09                	jge    800b14 <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800b0b:	41                   	inc    %ecx
  800b0c:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b10:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b12:	eb be                	jmp    800ad2 <strtol+0x6f>

	if (endptr)
  800b14:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b18:	74 05                	je     800b1f <strtol+0xbc>
		*endptr = (char *) s;
  800b1a:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b1d:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800b1f:	85 ff                	test   %edi,%edi
  800b21:	74 21                	je     800b44 <strtol+0xe1>
  800b23:	f7 d8                	neg    %eax
  800b25:	eb 1d                	jmp    800b44 <strtol+0xe1>
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b27:	80 39 30             	cmpb   $0x30,(%ecx)
  800b2a:	75 9a                	jne    800ac6 <strtol+0x63>
  800b2c:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b30:	0f 84 7a ff ff ff    	je     800ab0 <strtol+0x4d>
  800b36:	eb 84                	jmp    800abc <strtol+0x59>
  800b38:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b3c:	0f 84 6e ff ff ff    	je     800ab0 <strtol+0x4d>
  800b42:	eb 89                	jmp    800acd <strtol+0x6a>
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
}
  800b44:	5b                   	pop    %ebx
  800b45:	5e                   	pop    %esi
  800b46:	5f                   	pop    %edi
  800b47:	5d                   	pop    %ebp
  800b48:	c3                   	ret    

00800b49 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b49:	55                   	push   %ebp
  800b4a:	89 e5                	mov    %esp,%ebp
  800b4c:	57                   	push   %edi
  800b4d:	56                   	push   %esi
  800b4e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b4f:	b8 00 00 00 00       	mov    $0x0,%eax
  800b54:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b57:	8b 55 08             	mov    0x8(%ebp),%edx
  800b5a:	89 c3                	mov    %eax,%ebx
  800b5c:	89 c7                	mov    %eax,%edi
  800b5e:	89 c6                	mov    %eax,%esi
  800b60:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b62:	5b                   	pop    %ebx
  800b63:	5e                   	pop    %esi
  800b64:	5f                   	pop    %edi
  800b65:	5d                   	pop    %ebp
  800b66:	c3                   	ret    

00800b67 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b67:	55                   	push   %ebp
  800b68:	89 e5                	mov    %esp,%ebp
  800b6a:	57                   	push   %edi
  800b6b:	56                   	push   %esi
  800b6c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b6d:	ba 00 00 00 00       	mov    $0x0,%edx
  800b72:	b8 01 00 00 00       	mov    $0x1,%eax
  800b77:	89 d1                	mov    %edx,%ecx
  800b79:	89 d3                	mov    %edx,%ebx
  800b7b:	89 d7                	mov    %edx,%edi
  800b7d:	89 d6                	mov    %edx,%esi
  800b7f:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b81:	5b                   	pop    %ebx
  800b82:	5e                   	pop    %esi
  800b83:	5f                   	pop    %edi
  800b84:	5d                   	pop    %ebp
  800b85:	c3                   	ret    

00800b86 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b86:	55                   	push   %ebp
  800b87:	89 e5                	mov    %esp,%ebp
  800b89:	57                   	push   %edi
  800b8a:	56                   	push   %esi
  800b8b:	53                   	push   %ebx
  800b8c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b8f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b94:	b8 03 00 00 00       	mov    $0x3,%eax
  800b99:	8b 55 08             	mov    0x8(%ebp),%edx
  800b9c:	89 cb                	mov    %ecx,%ebx
  800b9e:	89 cf                	mov    %ecx,%edi
  800ba0:	89 ce                	mov    %ecx,%esi
  800ba2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ba4:	85 c0                	test   %eax,%eax
  800ba6:	7e 17                	jle    800bbf <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ba8:	83 ec 0c             	sub    $0xc,%esp
  800bab:	50                   	push   %eax
  800bac:	6a 03                	push   $0x3
  800bae:	68 df 25 80 00       	push   $0x8025df
  800bb3:	6a 23                	push   $0x23
  800bb5:	68 fc 25 80 00       	push   $0x8025fc
  800bba:	e8 aa 11 00 00       	call   801d69 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bbf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bc2:	5b                   	pop    %ebx
  800bc3:	5e                   	pop    %esi
  800bc4:	5f                   	pop    %edi
  800bc5:	5d                   	pop    %ebp
  800bc6:	c3                   	ret    

00800bc7 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bc7:	55                   	push   %ebp
  800bc8:	89 e5                	mov    %esp,%ebp
  800bca:	57                   	push   %edi
  800bcb:	56                   	push   %esi
  800bcc:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bcd:	ba 00 00 00 00       	mov    $0x0,%edx
  800bd2:	b8 02 00 00 00       	mov    $0x2,%eax
  800bd7:	89 d1                	mov    %edx,%ecx
  800bd9:	89 d3                	mov    %edx,%ebx
  800bdb:	89 d7                	mov    %edx,%edi
  800bdd:	89 d6                	mov    %edx,%esi
  800bdf:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800be1:	5b                   	pop    %ebx
  800be2:	5e                   	pop    %esi
  800be3:	5f                   	pop    %edi
  800be4:	5d                   	pop    %ebp
  800be5:	c3                   	ret    

00800be6 <sys_yield>:

void
sys_yield(void)
{
  800be6:	55                   	push   %ebp
  800be7:	89 e5                	mov    %esp,%ebp
  800be9:	57                   	push   %edi
  800bea:	56                   	push   %esi
  800beb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bec:	ba 00 00 00 00       	mov    $0x0,%edx
  800bf1:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bf6:	89 d1                	mov    %edx,%ecx
  800bf8:	89 d3                	mov    %edx,%ebx
  800bfa:	89 d7                	mov    %edx,%edi
  800bfc:	89 d6                	mov    %edx,%esi
  800bfe:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c00:	5b                   	pop    %ebx
  800c01:	5e                   	pop    %esi
  800c02:	5f                   	pop    %edi
  800c03:	5d                   	pop    %ebp
  800c04:	c3                   	ret    

00800c05 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c05:	55                   	push   %ebp
  800c06:	89 e5                	mov    %esp,%ebp
  800c08:	57                   	push   %edi
  800c09:	56                   	push   %esi
  800c0a:	53                   	push   %ebx
  800c0b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c0e:	be 00 00 00 00       	mov    $0x0,%esi
  800c13:	b8 04 00 00 00       	mov    $0x4,%eax
  800c18:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c1b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c1e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c21:	89 f7                	mov    %esi,%edi
  800c23:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c25:	85 c0                	test   %eax,%eax
  800c27:	7e 17                	jle    800c40 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c29:	83 ec 0c             	sub    $0xc,%esp
  800c2c:	50                   	push   %eax
  800c2d:	6a 04                	push   $0x4
  800c2f:	68 df 25 80 00       	push   $0x8025df
  800c34:	6a 23                	push   $0x23
  800c36:	68 fc 25 80 00       	push   $0x8025fc
  800c3b:	e8 29 11 00 00       	call   801d69 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c40:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c43:	5b                   	pop    %ebx
  800c44:	5e                   	pop    %esi
  800c45:	5f                   	pop    %edi
  800c46:	5d                   	pop    %ebp
  800c47:	c3                   	ret    

00800c48 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c48:	55                   	push   %ebp
  800c49:	89 e5                	mov    %esp,%ebp
  800c4b:	57                   	push   %edi
  800c4c:	56                   	push   %esi
  800c4d:	53                   	push   %ebx
  800c4e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c51:	b8 05 00 00 00       	mov    $0x5,%eax
  800c56:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c59:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c5f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c62:	8b 75 18             	mov    0x18(%ebp),%esi
  800c65:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c67:	85 c0                	test   %eax,%eax
  800c69:	7e 17                	jle    800c82 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c6b:	83 ec 0c             	sub    $0xc,%esp
  800c6e:	50                   	push   %eax
  800c6f:	6a 05                	push   $0x5
  800c71:	68 df 25 80 00       	push   $0x8025df
  800c76:	6a 23                	push   $0x23
  800c78:	68 fc 25 80 00       	push   $0x8025fc
  800c7d:	e8 e7 10 00 00       	call   801d69 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c82:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c85:	5b                   	pop    %ebx
  800c86:	5e                   	pop    %esi
  800c87:	5f                   	pop    %edi
  800c88:	5d                   	pop    %ebp
  800c89:	c3                   	ret    

00800c8a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c8a:	55                   	push   %ebp
  800c8b:	89 e5                	mov    %esp,%ebp
  800c8d:	57                   	push   %edi
  800c8e:	56                   	push   %esi
  800c8f:	53                   	push   %ebx
  800c90:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c93:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c98:	b8 06 00 00 00       	mov    $0x6,%eax
  800c9d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca3:	89 df                	mov    %ebx,%edi
  800ca5:	89 de                	mov    %ebx,%esi
  800ca7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ca9:	85 c0                	test   %eax,%eax
  800cab:	7e 17                	jle    800cc4 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cad:	83 ec 0c             	sub    $0xc,%esp
  800cb0:	50                   	push   %eax
  800cb1:	6a 06                	push   $0x6
  800cb3:	68 df 25 80 00       	push   $0x8025df
  800cb8:	6a 23                	push   $0x23
  800cba:	68 fc 25 80 00       	push   $0x8025fc
  800cbf:	e8 a5 10 00 00       	call   801d69 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cc4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc7:	5b                   	pop    %ebx
  800cc8:	5e                   	pop    %esi
  800cc9:	5f                   	pop    %edi
  800cca:	5d                   	pop    %ebp
  800ccb:	c3                   	ret    

00800ccc <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ccc:	55                   	push   %ebp
  800ccd:	89 e5                	mov    %esp,%ebp
  800ccf:	57                   	push   %edi
  800cd0:	56                   	push   %esi
  800cd1:	53                   	push   %ebx
  800cd2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cd5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cda:	b8 08 00 00 00       	mov    $0x8,%eax
  800cdf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce5:	89 df                	mov    %ebx,%edi
  800ce7:	89 de                	mov    %ebx,%esi
  800ce9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ceb:	85 c0                	test   %eax,%eax
  800ced:	7e 17                	jle    800d06 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cef:	83 ec 0c             	sub    $0xc,%esp
  800cf2:	50                   	push   %eax
  800cf3:	6a 08                	push   $0x8
  800cf5:	68 df 25 80 00       	push   $0x8025df
  800cfa:	6a 23                	push   $0x23
  800cfc:	68 fc 25 80 00       	push   $0x8025fc
  800d01:	e8 63 10 00 00       	call   801d69 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d06:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d09:	5b                   	pop    %ebx
  800d0a:	5e                   	pop    %esi
  800d0b:	5f                   	pop    %edi
  800d0c:	5d                   	pop    %ebp
  800d0d:	c3                   	ret    

00800d0e <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d0e:	55                   	push   %ebp
  800d0f:	89 e5                	mov    %esp,%ebp
  800d11:	57                   	push   %edi
  800d12:	56                   	push   %esi
  800d13:	53                   	push   %ebx
  800d14:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d17:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d1c:	b8 09 00 00 00       	mov    $0x9,%eax
  800d21:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d24:	8b 55 08             	mov    0x8(%ebp),%edx
  800d27:	89 df                	mov    %ebx,%edi
  800d29:	89 de                	mov    %ebx,%esi
  800d2b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d2d:	85 c0                	test   %eax,%eax
  800d2f:	7e 17                	jle    800d48 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d31:	83 ec 0c             	sub    $0xc,%esp
  800d34:	50                   	push   %eax
  800d35:	6a 09                	push   $0x9
  800d37:	68 df 25 80 00       	push   $0x8025df
  800d3c:	6a 23                	push   $0x23
  800d3e:	68 fc 25 80 00       	push   $0x8025fc
  800d43:	e8 21 10 00 00       	call   801d69 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d48:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d4b:	5b                   	pop    %ebx
  800d4c:	5e                   	pop    %esi
  800d4d:	5f                   	pop    %edi
  800d4e:	5d                   	pop    %ebp
  800d4f:	c3                   	ret    

00800d50 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d50:	55                   	push   %ebp
  800d51:	89 e5                	mov    %esp,%ebp
  800d53:	57                   	push   %edi
  800d54:	56                   	push   %esi
  800d55:	53                   	push   %ebx
  800d56:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d59:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d5e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d63:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d66:	8b 55 08             	mov    0x8(%ebp),%edx
  800d69:	89 df                	mov    %ebx,%edi
  800d6b:	89 de                	mov    %ebx,%esi
  800d6d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d6f:	85 c0                	test   %eax,%eax
  800d71:	7e 17                	jle    800d8a <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d73:	83 ec 0c             	sub    $0xc,%esp
  800d76:	50                   	push   %eax
  800d77:	6a 0a                	push   $0xa
  800d79:	68 df 25 80 00       	push   $0x8025df
  800d7e:	6a 23                	push   $0x23
  800d80:	68 fc 25 80 00       	push   $0x8025fc
  800d85:	e8 df 0f 00 00       	call   801d69 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d8a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d8d:	5b                   	pop    %ebx
  800d8e:	5e                   	pop    %esi
  800d8f:	5f                   	pop    %edi
  800d90:	5d                   	pop    %ebp
  800d91:	c3                   	ret    

00800d92 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d92:	55                   	push   %ebp
  800d93:	89 e5                	mov    %esp,%ebp
  800d95:	57                   	push   %edi
  800d96:	56                   	push   %esi
  800d97:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d98:	be 00 00 00 00       	mov    $0x0,%esi
  800d9d:	b8 0c 00 00 00       	mov    $0xc,%eax
  800da2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800da5:	8b 55 08             	mov    0x8(%ebp),%edx
  800da8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dab:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dae:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800db0:	5b                   	pop    %ebx
  800db1:	5e                   	pop    %esi
  800db2:	5f                   	pop    %edi
  800db3:	5d                   	pop    %ebp
  800db4:	c3                   	ret    

00800db5 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800db5:	55                   	push   %ebp
  800db6:	89 e5                	mov    %esp,%ebp
  800db8:	57                   	push   %edi
  800db9:	56                   	push   %esi
  800dba:	53                   	push   %ebx
  800dbb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dbe:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dc3:	b8 0d 00 00 00       	mov    $0xd,%eax
  800dc8:	8b 55 08             	mov    0x8(%ebp),%edx
  800dcb:	89 cb                	mov    %ecx,%ebx
  800dcd:	89 cf                	mov    %ecx,%edi
  800dcf:	89 ce                	mov    %ecx,%esi
  800dd1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dd3:	85 c0                	test   %eax,%eax
  800dd5:	7e 17                	jle    800dee <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dd7:	83 ec 0c             	sub    $0xc,%esp
  800dda:	50                   	push   %eax
  800ddb:	6a 0d                	push   $0xd
  800ddd:	68 df 25 80 00       	push   $0x8025df
  800de2:	6a 23                	push   $0x23
  800de4:	68 fc 25 80 00       	push   $0x8025fc
  800de9:	e8 7b 0f 00 00       	call   801d69 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800dee:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800df1:	5b                   	pop    %ebx
  800df2:	5e                   	pop    %esi
  800df3:	5f                   	pop    %edi
  800df4:	5d                   	pop    %ebp
  800df5:	c3                   	ret    

00800df6 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800df6:	55                   	push   %ebp
  800df7:	89 e5                	mov    %esp,%ebp
  800df9:	56                   	push   %esi
  800dfa:	53                   	push   %ebx
  800dfb:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800dfe:	8b 18                	mov    (%eax),%ebx
	// copy-on-write page.  If not, panic.
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).
	
	if((err & FEC_WR) == 0){
  800e00:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e04:	75 14                	jne    800e1a <pgfault+0x24>
		panic("pgfault not cause by write \n");
  800e06:	83 ec 04             	sub    $0x4,%esp
  800e09:	68 0a 26 80 00       	push   $0x80260a
  800e0e:	6a 1c                	push   $0x1c
  800e10:	68 27 26 80 00       	push   $0x802627
  800e15:	e8 4f 0f 00 00       	call   801d69 <_panic>
	}
 
	if ((uvpt[PGNUM(addr)] & PTE_COW) == 0) 
  800e1a:	89 d8                	mov    %ebx,%eax
  800e1c:	c1 e8 0c             	shr    $0xc,%eax
  800e1f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e26:	f6 c4 08             	test   $0x8,%ah
  800e29:	75 14                	jne    800e3f <pgfault+0x49>
    {
        panic("pgfault not cause by COW \n");
  800e2b:	83 ec 04             	sub    $0x4,%esp
  800e2e:	68 32 26 80 00       	push   $0x802632
  800e33:	6a 21                	push   $0x21
  800e35:	68 27 26 80 00       	push   $0x802627
  800e3a:	e8 2a 0f 00 00       	call   801d69 <_panic>
	// copy the data from the old page to the new page, then move the new
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.
	envid_t eid = sys_getenvid();
  800e3f:	e8 83 fd ff ff       	call   800bc7 <sys_getenvid>
  800e44:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(eid,(void*)PFTEMP,PTE_P|PTE_W|PTE_U)) < 0)
  800e46:	83 ec 04             	sub    $0x4,%esp
  800e49:	6a 07                	push   $0x7
  800e4b:	68 00 f0 7f 00       	push   $0x7ff000
  800e50:	50                   	push   %eax
  800e51:	e8 af fd ff ff       	call   800c05 <sys_page_alloc>
  800e56:	83 c4 10             	add    $0x10,%esp
  800e59:	85 c0                	test   %eax,%eax
  800e5b:	79 14                	jns    800e71 <pgfault+0x7b>
		panic("page alloction failed.\n");
  800e5d:	83 ec 04             	sub    $0x4,%esp
  800e60:	68 4d 26 80 00       	push   $0x80264d
  800e65:	6a 2d                	push   $0x2d
  800e67:	68 27 26 80 00       	push   $0x802627
  800e6c:	e8 f8 0e 00 00       	call   801d69 <_panic>
	addr = ROUNDDOWN(addr,PGSIZE);
  800e71:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memmove(PFTEMP,addr,PGSIZE);
  800e77:	83 ec 04             	sub    $0x4,%esp
  800e7a:	68 00 10 00 00       	push   $0x1000
  800e7f:	53                   	push   %ebx
  800e80:	68 00 f0 7f 00       	push   $0x7ff000
  800e85:	e8 d8 fa ff ff       	call   800962 <memmove>
	if ((r = sys_page_map(eid, PFTEMP, eid, addr, PTE_P | PTE_W |PTE_U)) < 0)
  800e8a:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e91:	53                   	push   %ebx
  800e92:	56                   	push   %esi
  800e93:	68 00 f0 7f 00       	push   $0x7ff000
  800e98:	56                   	push   %esi
  800e99:	e8 aa fd ff ff       	call   800c48 <sys_page_map>
  800e9e:	83 c4 20             	add    $0x20,%esp
  800ea1:	85 c0                	test   %eax,%eax
  800ea3:	79 12                	jns    800eb7 <pgfault+0xc1>
        panic("pgfault: page map failed %e\n", r);
  800ea5:	50                   	push   %eax
  800ea6:	68 65 26 80 00       	push   $0x802665
  800eab:	6a 31                	push   $0x31
  800ead:	68 27 26 80 00       	push   $0x802627
  800eb2:	e8 b2 0e 00 00       	call   801d69 <_panic>
	if ((r = sys_page_unmap(eid, PFTEMP)) < 0)
  800eb7:	83 ec 08             	sub    $0x8,%esp
  800eba:	68 00 f0 7f 00       	push   $0x7ff000
  800ebf:	56                   	push   %esi
  800ec0:	e8 c5 fd ff ff       	call   800c8a <sys_page_unmap>
  800ec5:	83 c4 10             	add    $0x10,%esp
  800ec8:	85 c0                	test   %eax,%eax
  800eca:	79 12                	jns    800ede <pgfault+0xe8>
        panic("pgfault: page unmap failed %e\n", r);
  800ecc:	50                   	push   %eax
  800ecd:	68 d4 26 80 00       	push   $0x8026d4
  800ed2:	6a 33                	push   $0x33
  800ed4:	68 27 26 80 00       	push   $0x802627
  800ed9:	e8 8b 0e 00 00       	call   801d69 <_panic>
	// LAB 4: Your code here.

	// panic("pgfault not implemented");
}
  800ede:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ee1:	5b                   	pop    %ebx
  800ee2:	5e                   	pop    %esi
  800ee3:	5d                   	pop    %ebp
  800ee4:	c3                   	ret    

00800ee5 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800ee5:	55                   	push   %ebp
  800ee6:	89 e5                	mov    %esp,%ebp
  800ee8:	57                   	push   %edi
  800ee9:	56                   	push   %esi
  800eea:	53                   	push   %ebx
  800eeb:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	struct PageInfo* pg = NULL;
	set_pgfault_handler(pgfault);
  800eee:	68 f6 0d 80 00       	push   $0x800df6
  800ef3:	e8 b7 0e 00 00       	call   801daf <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800ef8:	b8 07 00 00 00       	mov    $0x7,%eax
  800efd:	cd 30                	int    $0x30
  800eff:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800f02:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t eid = sys_exofork();
	if (eid < 0) panic("fork fault.\n");
  800f05:	83 c4 10             	add    $0x10,%esp
  800f08:	85 c0                	test   %eax,%eax
  800f0a:	79 14                	jns    800f20 <fork+0x3b>
  800f0c:	83 ec 04             	sub    $0x4,%esp
  800f0f:	68 82 26 80 00       	push   $0x802682
  800f14:	6a 71                	push   $0x71
  800f16:	68 27 26 80 00       	push   $0x802627
  800f1b:	e8 49 0e 00 00       	call   801d69 <_panic>
	if (eid == 0){
  800f20:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800f24:	75 25                	jne    800f4b <fork+0x66>
		thisenv = &envs[ENVX(sys_getenvid())];
  800f26:	e8 9c fc ff ff       	call   800bc7 <sys_getenvid>
  800f2b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f30:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800f37:	c1 e0 07             	shl    $0x7,%eax
  800f3a:	29 d0                	sub    %edx,%eax
  800f3c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f41:	a3 04 40 80 00       	mov    %eax,0x804004
		return eid;
  800f46:	e9 61 01 00 00       	jmp    8010ac <fork+0x1c7>
  800f4b:	bb 00 00 80 00       	mov    $0x800000,%ebx
	}
	// copy something to the child page.
	for (uintptr_t i = UTEXT;i <= USTACKTOP;i += PGSIZE){
		if (uvpd[PDX(i)] & PTE_P && (uvpt[PGNUM(i)] & PTE_P)){
  800f50:	89 d8                	mov    %ebx,%eax
  800f52:	c1 e8 16             	shr    $0x16,%eax
  800f55:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f5c:	a8 01                	test   $0x1,%al
  800f5e:	74 52                	je     800fb2 <fork+0xcd>
  800f60:	89 de                	mov    %ebx,%esi
  800f62:	c1 ee 0c             	shr    $0xc,%esi
  800f65:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800f6c:	a8 01                	test   $0x1,%al
  800f6e:	74 42                	je     800fb2 <fork+0xcd>
duppage(envid_t envid, unsigned pn)
{
	int r;

	// LAB 4: Your code here.
	envid_t myenvid = sys_getenvid();
  800f70:	e8 52 fc ff ff       	call   800bc7 <sys_getenvid>
  800f75:	89 c7                	mov    %eax,%edi
	pte_t pte = uvpt[pn];
  800f77:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
	int perm = PTE_U | PTE_P;
	if(pte & PTE_W || pte & PTE_COW)
  800f7e:	a9 02 08 00 00       	test   $0x802,%eax
  800f83:	0f 85 de 00 00 00    	jne    801067 <fork+0x182>
  800f89:	e9 fb 00 00 00       	jmp    801089 <fork+0x1a4>
		perm |= PTE_COW;
	if((r = sys_page_map(myenvid,(void*)(pn*PGSIZE),envid,(void*)(pn*PGSIZE),perm))<0){
		panic("duppage fault :%e\n",r);
  800f8e:	50                   	push   %eax
  800f8f:	68 8f 26 80 00       	push   $0x80268f
  800f94:	6a 50                	push   $0x50
  800f96:	68 27 26 80 00       	push   $0x802627
  800f9b:	e8 c9 0d 00 00       	call   801d69 <_panic>
	}
	if(perm & PTE_COW){
		if((r = sys_page_map(myenvid,(void*)(pn*PGSIZE),myenvid,(void*)(pn*PGSIZE),perm))<0)
			panic("duppage fault :%e\n",r);
  800fa0:	50                   	push   %eax
  800fa1:	68 8f 26 80 00       	push   $0x80268f
  800fa6:	6a 54                	push   $0x54
  800fa8:	68 27 26 80 00       	push   $0x802627
  800fad:	e8 b7 0d 00 00       	call   801d69 <_panic>
	if (eid == 0){
		thisenv = &envs[ENVX(sys_getenvid())];
		return eid;
	}
	// copy something to the child page.
	for (uintptr_t i = UTEXT;i <= USTACKTOP;i += PGSIZE){
  800fb2:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800fb8:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  800fbe:	75 90                	jne    800f50 <fork+0x6b>
		if (uvpd[PDX(i)] & PTE_P && (uvpt[PGNUM(i)] & PTE_P)){
			duppage(eid,PGNUM(i));
		}
	}
	int r = sys_page_alloc(eid,(void*)(UXSTACKTOP-PGSIZE),PTE_U|PTE_P|PTE_W);
  800fc0:	83 ec 04             	sub    $0x4,%esp
  800fc3:	6a 07                	push   $0x7
  800fc5:	68 00 f0 bf ee       	push   $0xeebff000
  800fca:	ff 75 e0             	pushl  -0x20(%ebp)
  800fcd:	e8 33 fc ff ff       	call   800c05 <sys_page_alloc>
	if (r < 0) panic("fork fault.\n");
  800fd2:	83 c4 10             	add    $0x10,%esp
  800fd5:	85 c0                	test   %eax,%eax
  800fd7:	79 14                	jns    800fed <fork+0x108>
  800fd9:	83 ec 04             	sub    $0x4,%esp
  800fdc:	68 82 26 80 00       	push   $0x802682
  800fe1:	6a 7d                	push   $0x7d
  800fe3:	68 27 26 80 00       	push   $0x802627
  800fe8:	e8 7c 0d 00 00       	call   801d69 <_panic>

	extern void _pgfault_upcall();
    r = sys_env_set_pgfault_upcall(eid, _pgfault_upcall);
  800fed:	83 ec 08             	sub    $0x8,%esp
  800ff0:	68 27 1e 80 00       	push   $0x801e27
  800ff5:	ff 75 e0             	pushl  -0x20(%ebp)
  800ff8:	e8 53 fd ff ff       	call   800d50 <sys_env_set_pgfault_upcall>
    if (r < 0) panic("fork fault 3\n");
  800ffd:	83 c4 10             	add    $0x10,%esp
  801000:	85 c0                	test   %eax,%eax
  801002:	79 17                	jns    80101b <fork+0x136>
  801004:	83 ec 04             	sub    $0x4,%esp
  801007:	68 a2 26 80 00       	push   $0x8026a2
  80100c:	68 81 00 00 00       	push   $0x81
  801011:	68 27 26 80 00       	push   $0x802627
  801016:	e8 4e 0d 00 00       	call   801d69 <_panic>

	if ((r = sys_env_set_status(eid, ENV_RUNNABLE)) < 0)
  80101b:	83 ec 08             	sub    $0x8,%esp
  80101e:	6a 02                	push   $0x2
  801020:	ff 75 e0             	pushl  -0x20(%ebp)
  801023:	e8 a4 fc ff ff       	call   800ccc <sys_env_set_status>
  801028:	83 c4 10             	add    $0x10,%esp
  80102b:	85 c0                	test   %eax,%eax
  80102d:	79 7d                	jns    8010ac <fork+0x1c7>
        panic("fork fault 4\n");
  80102f:	83 ec 04             	sub    $0x4,%esp
  801032:	68 b0 26 80 00       	push   $0x8026b0
  801037:	68 84 00 00 00       	push   $0x84
  80103c:	68 27 26 80 00       	push   $0x802627
  801041:	e8 23 0d 00 00       	call   801d69 <_panic>
		perm |= PTE_COW;
	if((r = sys_page_map(myenvid,(void*)(pn*PGSIZE),envid,(void*)(pn*PGSIZE),perm))<0){
		panic("duppage fault :%e\n",r);
	}
	if(perm & PTE_COW){
		if((r = sys_page_map(myenvid,(void*)(pn*PGSIZE),myenvid,(void*)(pn*PGSIZE),perm))<0)
  801046:	83 ec 0c             	sub    $0xc,%esp
  801049:	68 05 08 00 00       	push   $0x805
  80104e:	56                   	push   %esi
  80104f:	57                   	push   %edi
  801050:	56                   	push   %esi
  801051:	57                   	push   %edi
  801052:	e8 f1 fb ff ff       	call   800c48 <sys_page_map>
  801057:	83 c4 20             	add    $0x20,%esp
  80105a:	85 c0                	test   %eax,%eax
  80105c:	0f 89 50 ff ff ff    	jns    800fb2 <fork+0xcd>
  801062:	e9 39 ff ff ff       	jmp    800fa0 <fork+0xbb>
	envid_t myenvid = sys_getenvid();
	pte_t pte = uvpt[pn];
	int perm = PTE_U | PTE_P;
	if(pte & PTE_W || pte & PTE_COW)
		perm |= PTE_COW;
	if((r = sys_page_map(myenvid,(void*)(pn*PGSIZE),envid,(void*)(pn*PGSIZE),perm))<0){
  801067:	c1 e6 0c             	shl    $0xc,%esi
  80106a:	83 ec 0c             	sub    $0xc,%esp
  80106d:	68 05 08 00 00       	push   $0x805
  801072:	56                   	push   %esi
  801073:	ff 75 e4             	pushl  -0x1c(%ebp)
  801076:	56                   	push   %esi
  801077:	57                   	push   %edi
  801078:	e8 cb fb ff ff       	call   800c48 <sys_page_map>
  80107d:	83 c4 20             	add    $0x20,%esp
  801080:	85 c0                	test   %eax,%eax
  801082:	79 c2                	jns    801046 <fork+0x161>
  801084:	e9 05 ff ff ff       	jmp    800f8e <fork+0xa9>
  801089:	c1 e6 0c             	shl    $0xc,%esi
  80108c:	83 ec 0c             	sub    $0xc,%esp
  80108f:	6a 05                	push   $0x5
  801091:	56                   	push   %esi
  801092:	ff 75 e4             	pushl  -0x1c(%ebp)
  801095:	56                   	push   %esi
  801096:	57                   	push   %edi
  801097:	e8 ac fb ff ff       	call   800c48 <sys_page_map>
  80109c:	83 c4 20             	add    $0x20,%esp
  80109f:	85 c0                	test   %eax,%eax
  8010a1:	0f 89 0b ff ff ff    	jns    800fb2 <fork+0xcd>
  8010a7:	e9 e2 fe ff ff       	jmp    800f8e <fork+0xa9>
    if (r < 0) panic("fork fault 3\n");

	if ((r = sys_env_set_status(eid, ENV_RUNNABLE)) < 0)
        panic("fork fault 4\n");
    return eid;
}
  8010ac:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8010af:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010b2:	5b                   	pop    %ebx
  8010b3:	5e                   	pop    %esi
  8010b4:	5f                   	pop    %edi
  8010b5:	5d                   	pop    %ebp
  8010b6:	c3                   	ret    

008010b7 <sfork>:

// Challenge!
int
sfork(void)
{
  8010b7:	55                   	push   %ebp
  8010b8:	89 e5                	mov    %esp,%ebp
  8010ba:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8010bd:	68 be 26 80 00       	push   $0x8026be
  8010c2:	68 8c 00 00 00       	push   $0x8c
  8010c7:	68 27 26 80 00       	push   $0x802627
  8010cc:	e8 98 0c 00 00       	call   801d69 <_panic>

008010d1 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8010d1:	55                   	push   %ebp
  8010d2:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8010d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8010d7:	05 00 00 00 30       	add    $0x30000000,%eax
  8010dc:	c1 e8 0c             	shr    $0xc,%eax
}
  8010df:	5d                   	pop    %ebp
  8010e0:	c3                   	ret    

008010e1 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8010e1:	55                   	push   %ebp
  8010e2:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8010e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8010e7:	05 00 00 00 30       	add    $0x30000000,%eax
  8010ec:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8010f1:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8010f6:	5d                   	pop    %ebp
  8010f7:	c3                   	ret    

008010f8 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8010f8:	55                   	push   %ebp
  8010f9:	89 e5                	mov    %esp,%ebp
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8010fb:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  801100:	a8 01                	test   $0x1,%al
  801102:	74 34                	je     801138 <fd_alloc+0x40>
  801104:	a1 00 00 74 ef       	mov    0xef740000,%eax
  801109:	a8 01                	test   $0x1,%al
  80110b:	74 32                	je     80113f <fd_alloc+0x47>
  80110d:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  801112:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801114:	89 c2                	mov    %eax,%edx
  801116:	c1 ea 16             	shr    $0x16,%edx
  801119:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801120:	f6 c2 01             	test   $0x1,%dl
  801123:	74 1f                	je     801144 <fd_alloc+0x4c>
  801125:	89 c2                	mov    %eax,%edx
  801127:	c1 ea 0c             	shr    $0xc,%edx
  80112a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801131:	f6 c2 01             	test   $0x1,%dl
  801134:	75 1a                	jne    801150 <fd_alloc+0x58>
  801136:	eb 0c                	jmp    801144 <fd_alloc+0x4c>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  801138:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  80113d:	eb 05                	jmp    801144 <fd_alloc+0x4c>
  80113f:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  801144:	8b 45 08             	mov    0x8(%ebp),%eax
  801147:	89 08                	mov    %ecx,(%eax)
			return 0;
  801149:	b8 00 00 00 00       	mov    $0x0,%eax
  80114e:	eb 1a                	jmp    80116a <fd_alloc+0x72>
  801150:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801155:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80115a:	75 b6                	jne    801112 <fd_alloc+0x1a>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80115c:	8b 45 08             	mov    0x8(%ebp),%eax
  80115f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  801165:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80116a:	5d                   	pop    %ebp
  80116b:	c3                   	ret    

0080116c <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80116c:	55                   	push   %ebp
  80116d:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80116f:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
  801173:	77 39                	ja     8011ae <fd_lookup+0x42>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801175:	8b 45 08             	mov    0x8(%ebp),%eax
  801178:	c1 e0 0c             	shl    $0xc,%eax
  80117b:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801180:	89 c2                	mov    %eax,%edx
  801182:	c1 ea 16             	shr    $0x16,%edx
  801185:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80118c:	f6 c2 01             	test   $0x1,%dl
  80118f:	74 24                	je     8011b5 <fd_lookup+0x49>
  801191:	89 c2                	mov    %eax,%edx
  801193:	c1 ea 0c             	shr    $0xc,%edx
  801196:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80119d:	f6 c2 01             	test   $0x1,%dl
  8011a0:	74 1a                	je     8011bc <fd_lookup+0x50>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8011a2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011a5:	89 02                	mov    %eax,(%edx)
	return 0;
  8011a7:	b8 00 00 00 00       	mov    $0x0,%eax
  8011ac:	eb 13                	jmp    8011c1 <fd_lookup+0x55>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011ae:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011b3:	eb 0c                	jmp    8011c1 <fd_lookup+0x55>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011b5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011ba:	eb 05                	jmp    8011c1 <fd_lookup+0x55>
  8011bc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8011c1:	5d                   	pop    %ebp
  8011c2:	c3                   	ret    

008011c3 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8011c3:	55                   	push   %ebp
  8011c4:	89 e5                	mov    %esp,%ebp
  8011c6:	53                   	push   %ebx
  8011c7:	83 ec 04             	sub    $0x4,%esp
  8011ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8011cd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  8011d0:	3b 05 04 30 80 00    	cmp    0x803004,%eax
  8011d6:	75 1e                	jne    8011f6 <dev_lookup+0x33>
  8011d8:	eb 0e                	jmp    8011e8 <dev_lookup+0x25>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8011da:	b8 20 30 80 00       	mov    $0x803020,%eax
  8011df:	eb 0c                	jmp    8011ed <dev_lookup+0x2a>
  8011e1:	b8 3c 30 80 00       	mov    $0x80303c,%eax
  8011e6:	eb 05                	jmp    8011ed <dev_lookup+0x2a>
  8011e8:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  8011ed:	89 03                	mov    %eax,(%ebx)
			return 0;
  8011ef:	b8 00 00 00 00       	mov    $0x0,%eax
  8011f4:	eb 36                	jmp    80122c <dev_lookup+0x69>
int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  8011f6:	3b 05 20 30 80 00    	cmp    0x803020,%eax
  8011fc:	74 dc                	je     8011da <dev_lookup+0x17>
  8011fe:	3b 05 3c 30 80 00    	cmp    0x80303c,%eax
  801204:	74 db                	je     8011e1 <dev_lookup+0x1e>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801206:	8b 15 04 40 80 00    	mov    0x804004,%edx
  80120c:	8b 52 48             	mov    0x48(%edx),%edx
  80120f:	83 ec 04             	sub    $0x4,%esp
  801212:	50                   	push   %eax
  801213:	52                   	push   %edx
  801214:	68 f4 26 80 00       	push   $0x8026f4
  801219:	e8 92 ef ff ff       	call   8001b0 <cprintf>
	*dev = 0;
  80121e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  801224:	83 c4 10             	add    $0x10,%esp
  801227:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80122c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80122f:	c9                   	leave  
  801230:	c3                   	ret    

00801231 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801231:	55                   	push   %ebp
  801232:	89 e5                	mov    %esp,%ebp
  801234:	56                   	push   %esi
  801235:	53                   	push   %ebx
  801236:	83 ec 10             	sub    $0x10,%esp
  801239:	8b 75 08             	mov    0x8(%ebp),%esi
  80123c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80123f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801242:	50                   	push   %eax
  801243:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801249:	c1 e8 0c             	shr    $0xc,%eax
  80124c:	50                   	push   %eax
  80124d:	e8 1a ff ff ff       	call   80116c <fd_lookup>
  801252:	83 c4 08             	add    $0x8,%esp
  801255:	85 c0                	test   %eax,%eax
  801257:	78 05                	js     80125e <fd_close+0x2d>
	    || fd != fd2)
  801259:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80125c:	74 06                	je     801264 <fd_close+0x33>
		return (must_exist ? r : 0);
  80125e:	84 db                	test   %bl,%bl
  801260:	74 47                	je     8012a9 <fd_close+0x78>
  801262:	eb 4a                	jmp    8012ae <fd_close+0x7d>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801264:	83 ec 08             	sub    $0x8,%esp
  801267:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80126a:	50                   	push   %eax
  80126b:	ff 36                	pushl  (%esi)
  80126d:	e8 51 ff ff ff       	call   8011c3 <dev_lookup>
  801272:	89 c3                	mov    %eax,%ebx
  801274:	83 c4 10             	add    $0x10,%esp
  801277:	85 c0                	test   %eax,%eax
  801279:	78 1c                	js     801297 <fd_close+0x66>
		if (dev->dev_close)
  80127b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80127e:	8b 40 10             	mov    0x10(%eax),%eax
  801281:	85 c0                	test   %eax,%eax
  801283:	74 0d                	je     801292 <fd_close+0x61>
			r = (*dev->dev_close)(fd);
  801285:	83 ec 0c             	sub    $0xc,%esp
  801288:	56                   	push   %esi
  801289:	ff d0                	call   *%eax
  80128b:	89 c3                	mov    %eax,%ebx
  80128d:	83 c4 10             	add    $0x10,%esp
  801290:	eb 05                	jmp    801297 <fd_close+0x66>
		else
			r = 0;
  801292:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801297:	83 ec 08             	sub    $0x8,%esp
  80129a:	56                   	push   %esi
  80129b:	6a 00                	push   $0x0
  80129d:	e8 e8 f9 ff ff       	call   800c8a <sys_page_unmap>
	return r;
  8012a2:	83 c4 10             	add    $0x10,%esp
  8012a5:	89 d8                	mov    %ebx,%eax
  8012a7:	eb 05                	jmp    8012ae <fd_close+0x7d>
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
  8012a9:	b8 00 00 00 00       	mov    $0x0,%eax
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
	return r;
}
  8012ae:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012b1:	5b                   	pop    %ebx
  8012b2:	5e                   	pop    %esi
  8012b3:	5d                   	pop    %ebp
  8012b4:	c3                   	ret    

008012b5 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8012b5:	55                   	push   %ebp
  8012b6:	89 e5                	mov    %esp,%ebp
  8012b8:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012bb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012be:	50                   	push   %eax
  8012bf:	ff 75 08             	pushl  0x8(%ebp)
  8012c2:	e8 a5 fe ff ff       	call   80116c <fd_lookup>
  8012c7:	83 c4 08             	add    $0x8,%esp
  8012ca:	85 c0                	test   %eax,%eax
  8012cc:	78 10                	js     8012de <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8012ce:	83 ec 08             	sub    $0x8,%esp
  8012d1:	6a 01                	push   $0x1
  8012d3:	ff 75 f4             	pushl  -0xc(%ebp)
  8012d6:	e8 56 ff ff ff       	call   801231 <fd_close>
  8012db:	83 c4 10             	add    $0x10,%esp
}
  8012de:	c9                   	leave  
  8012df:	c3                   	ret    

008012e0 <close_all>:

void
close_all(void)
{
  8012e0:	55                   	push   %ebp
  8012e1:	89 e5                	mov    %esp,%ebp
  8012e3:	53                   	push   %ebx
  8012e4:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8012e7:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8012ec:	83 ec 0c             	sub    $0xc,%esp
  8012ef:	53                   	push   %ebx
  8012f0:	e8 c0 ff ff ff       	call   8012b5 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8012f5:	43                   	inc    %ebx
  8012f6:	83 c4 10             	add    $0x10,%esp
  8012f9:	83 fb 20             	cmp    $0x20,%ebx
  8012fc:	75 ee                	jne    8012ec <close_all+0xc>
		close(i);
}
  8012fe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801301:	c9                   	leave  
  801302:	c3                   	ret    

00801303 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801303:	55                   	push   %ebp
  801304:	89 e5                	mov    %esp,%ebp
  801306:	57                   	push   %edi
  801307:	56                   	push   %esi
  801308:	53                   	push   %ebx
  801309:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80130c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80130f:	50                   	push   %eax
  801310:	ff 75 08             	pushl  0x8(%ebp)
  801313:	e8 54 fe ff ff       	call   80116c <fd_lookup>
  801318:	83 c4 08             	add    $0x8,%esp
  80131b:	85 c0                	test   %eax,%eax
  80131d:	0f 88 c2 00 00 00    	js     8013e5 <dup+0xe2>
		return r;
	close(newfdnum);
  801323:	83 ec 0c             	sub    $0xc,%esp
  801326:	ff 75 0c             	pushl  0xc(%ebp)
  801329:	e8 87 ff ff ff       	call   8012b5 <close>

	newfd = INDEX2FD(newfdnum);
  80132e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801331:	c1 e3 0c             	shl    $0xc,%ebx
  801334:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80133a:	83 c4 04             	add    $0x4,%esp
  80133d:	ff 75 e4             	pushl  -0x1c(%ebp)
  801340:	e8 9c fd ff ff       	call   8010e1 <fd2data>
  801345:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  801347:	89 1c 24             	mov    %ebx,(%esp)
  80134a:	e8 92 fd ff ff       	call   8010e1 <fd2data>
  80134f:	83 c4 10             	add    $0x10,%esp
  801352:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801354:	89 f0                	mov    %esi,%eax
  801356:	c1 e8 16             	shr    $0x16,%eax
  801359:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801360:	a8 01                	test   $0x1,%al
  801362:	74 35                	je     801399 <dup+0x96>
  801364:	89 f0                	mov    %esi,%eax
  801366:	c1 e8 0c             	shr    $0xc,%eax
  801369:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801370:	f6 c2 01             	test   $0x1,%dl
  801373:	74 24                	je     801399 <dup+0x96>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801375:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80137c:	83 ec 0c             	sub    $0xc,%esp
  80137f:	25 07 0e 00 00       	and    $0xe07,%eax
  801384:	50                   	push   %eax
  801385:	57                   	push   %edi
  801386:	6a 00                	push   $0x0
  801388:	56                   	push   %esi
  801389:	6a 00                	push   $0x0
  80138b:	e8 b8 f8 ff ff       	call   800c48 <sys_page_map>
  801390:	89 c6                	mov    %eax,%esi
  801392:	83 c4 20             	add    $0x20,%esp
  801395:	85 c0                	test   %eax,%eax
  801397:	78 2c                	js     8013c5 <dup+0xc2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801399:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80139c:	89 d0                	mov    %edx,%eax
  80139e:	c1 e8 0c             	shr    $0xc,%eax
  8013a1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013a8:	83 ec 0c             	sub    $0xc,%esp
  8013ab:	25 07 0e 00 00       	and    $0xe07,%eax
  8013b0:	50                   	push   %eax
  8013b1:	53                   	push   %ebx
  8013b2:	6a 00                	push   $0x0
  8013b4:	52                   	push   %edx
  8013b5:	6a 00                	push   $0x0
  8013b7:	e8 8c f8 ff ff       	call   800c48 <sys_page_map>
  8013bc:	89 c6                	mov    %eax,%esi
  8013be:	83 c4 20             	add    $0x20,%esp
  8013c1:	85 c0                	test   %eax,%eax
  8013c3:	79 1d                	jns    8013e2 <dup+0xdf>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8013c5:	83 ec 08             	sub    $0x8,%esp
  8013c8:	53                   	push   %ebx
  8013c9:	6a 00                	push   $0x0
  8013cb:	e8 ba f8 ff ff       	call   800c8a <sys_page_unmap>
	sys_page_unmap(0, nva);
  8013d0:	83 c4 08             	add    $0x8,%esp
  8013d3:	57                   	push   %edi
  8013d4:	6a 00                	push   $0x0
  8013d6:	e8 af f8 ff ff       	call   800c8a <sys_page_unmap>
	return r;
  8013db:	83 c4 10             	add    $0x10,%esp
  8013de:	89 f0                	mov    %esi,%eax
  8013e0:	eb 03                	jmp    8013e5 <dup+0xe2>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  8013e2:	8b 45 0c             	mov    0xc(%ebp),%eax

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8013e5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013e8:	5b                   	pop    %ebx
  8013e9:	5e                   	pop    %esi
  8013ea:	5f                   	pop    %edi
  8013eb:	5d                   	pop    %ebp
  8013ec:	c3                   	ret    

008013ed <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8013ed:	55                   	push   %ebp
  8013ee:	89 e5                	mov    %esp,%ebp
  8013f0:	53                   	push   %ebx
  8013f1:	83 ec 14             	sub    $0x14,%esp
  8013f4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013f7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013fa:	50                   	push   %eax
  8013fb:	53                   	push   %ebx
  8013fc:	e8 6b fd ff ff       	call   80116c <fd_lookup>
  801401:	83 c4 08             	add    $0x8,%esp
  801404:	85 c0                	test   %eax,%eax
  801406:	78 67                	js     80146f <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801408:	83 ec 08             	sub    $0x8,%esp
  80140b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80140e:	50                   	push   %eax
  80140f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801412:	ff 30                	pushl  (%eax)
  801414:	e8 aa fd ff ff       	call   8011c3 <dev_lookup>
  801419:	83 c4 10             	add    $0x10,%esp
  80141c:	85 c0                	test   %eax,%eax
  80141e:	78 4f                	js     80146f <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801420:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801423:	8b 42 08             	mov    0x8(%edx),%eax
  801426:	83 e0 03             	and    $0x3,%eax
  801429:	83 f8 01             	cmp    $0x1,%eax
  80142c:	75 21                	jne    80144f <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80142e:	a1 04 40 80 00       	mov    0x804004,%eax
  801433:	8b 40 48             	mov    0x48(%eax),%eax
  801436:	83 ec 04             	sub    $0x4,%esp
  801439:	53                   	push   %ebx
  80143a:	50                   	push   %eax
  80143b:	68 35 27 80 00       	push   $0x802735
  801440:	e8 6b ed ff ff       	call   8001b0 <cprintf>
		return -E_INVAL;
  801445:	83 c4 10             	add    $0x10,%esp
  801448:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80144d:	eb 20                	jmp    80146f <read+0x82>
	}
	if (!dev->dev_read)
  80144f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801452:	8b 40 08             	mov    0x8(%eax),%eax
  801455:	85 c0                	test   %eax,%eax
  801457:	74 11                	je     80146a <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801459:	83 ec 04             	sub    $0x4,%esp
  80145c:	ff 75 10             	pushl  0x10(%ebp)
  80145f:	ff 75 0c             	pushl  0xc(%ebp)
  801462:	52                   	push   %edx
  801463:	ff d0                	call   *%eax
  801465:	83 c4 10             	add    $0x10,%esp
  801468:	eb 05                	jmp    80146f <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80146a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  80146f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801472:	c9                   	leave  
  801473:	c3                   	ret    

00801474 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801474:	55                   	push   %ebp
  801475:	89 e5                	mov    %esp,%ebp
  801477:	57                   	push   %edi
  801478:	56                   	push   %esi
  801479:	53                   	push   %ebx
  80147a:	83 ec 0c             	sub    $0xc,%esp
  80147d:	8b 7d 08             	mov    0x8(%ebp),%edi
  801480:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801483:	85 f6                	test   %esi,%esi
  801485:	74 31                	je     8014b8 <readn+0x44>
  801487:	b8 00 00 00 00       	mov    $0x0,%eax
  80148c:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  801491:	83 ec 04             	sub    $0x4,%esp
  801494:	89 f2                	mov    %esi,%edx
  801496:	29 c2                	sub    %eax,%edx
  801498:	52                   	push   %edx
  801499:	03 45 0c             	add    0xc(%ebp),%eax
  80149c:	50                   	push   %eax
  80149d:	57                   	push   %edi
  80149e:	e8 4a ff ff ff       	call   8013ed <read>
		if (m < 0)
  8014a3:	83 c4 10             	add    $0x10,%esp
  8014a6:	85 c0                	test   %eax,%eax
  8014a8:	78 17                	js     8014c1 <readn+0x4d>
			return m;
		if (m == 0)
  8014aa:	85 c0                	test   %eax,%eax
  8014ac:	74 11                	je     8014bf <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014ae:	01 c3                	add    %eax,%ebx
  8014b0:	89 d8                	mov    %ebx,%eax
  8014b2:	39 f3                	cmp    %esi,%ebx
  8014b4:	72 db                	jb     801491 <readn+0x1d>
  8014b6:	eb 09                	jmp    8014c1 <readn+0x4d>
  8014b8:	b8 00 00 00 00       	mov    $0x0,%eax
  8014bd:	eb 02                	jmp    8014c1 <readn+0x4d>
  8014bf:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8014c1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014c4:	5b                   	pop    %ebx
  8014c5:	5e                   	pop    %esi
  8014c6:	5f                   	pop    %edi
  8014c7:	5d                   	pop    %ebp
  8014c8:	c3                   	ret    

008014c9 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8014c9:	55                   	push   %ebp
  8014ca:	89 e5                	mov    %esp,%ebp
  8014cc:	53                   	push   %ebx
  8014cd:	83 ec 14             	sub    $0x14,%esp
  8014d0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014d3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014d6:	50                   	push   %eax
  8014d7:	53                   	push   %ebx
  8014d8:	e8 8f fc ff ff       	call   80116c <fd_lookup>
  8014dd:	83 c4 08             	add    $0x8,%esp
  8014e0:	85 c0                	test   %eax,%eax
  8014e2:	78 62                	js     801546 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014e4:	83 ec 08             	sub    $0x8,%esp
  8014e7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014ea:	50                   	push   %eax
  8014eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014ee:	ff 30                	pushl  (%eax)
  8014f0:	e8 ce fc ff ff       	call   8011c3 <dev_lookup>
  8014f5:	83 c4 10             	add    $0x10,%esp
  8014f8:	85 c0                	test   %eax,%eax
  8014fa:	78 4a                	js     801546 <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014ff:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801503:	75 21                	jne    801526 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801505:	a1 04 40 80 00       	mov    0x804004,%eax
  80150a:	8b 40 48             	mov    0x48(%eax),%eax
  80150d:	83 ec 04             	sub    $0x4,%esp
  801510:	53                   	push   %ebx
  801511:	50                   	push   %eax
  801512:	68 51 27 80 00       	push   $0x802751
  801517:	e8 94 ec ff ff       	call   8001b0 <cprintf>
		return -E_INVAL;
  80151c:	83 c4 10             	add    $0x10,%esp
  80151f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801524:	eb 20                	jmp    801546 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801526:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801529:	8b 52 0c             	mov    0xc(%edx),%edx
  80152c:	85 d2                	test   %edx,%edx
  80152e:	74 11                	je     801541 <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801530:	83 ec 04             	sub    $0x4,%esp
  801533:	ff 75 10             	pushl  0x10(%ebp)
  801536:	ff 75 0c             	pushl  0xc(%ebp)
  801539:	50                   	push   %eax
  80153a:	ff d2                	call   *%edx
  80153c:	83 c4 10             	add    $0x10,%esp
  80153f:	eb 05                	jmp    801546 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801541:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801546:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801549:	c9                   	leave  
  80154a:	c3                   	ret    

0080154b <seek>:

int
seek(int fdnum, off_t offset)
{
  80154b:	55                   	push   %ebp
  80154c:	89 e5                	mov    %esp,%ebp
  80154e:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801551:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801554:	50                   	push   %eax
  801555:	ff 75 08             	pushl  0x8(%ebp)
  801558:	e8 0f fc ff ff       	call   80116c <fd_lookup>
  80155d:	83 c4 08             	add    $0x8,%esp
  801560:	85 c0                	test   %eax,%eax
  801562:	78 0e                	js     801572 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801564:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801567:	8b 55 0c             	mov    0xc(%ebp),%edx
  80156a:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80156d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801572:	c9                   	leave  
  801573:	c3                   	ret    

00801574 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801574:	55                   	push   %ebp
  801575:	89 e5                	mov    %esp,%ebp
  801577:	53                   	push   %ebx
  801578:	83 ec 14             	sub    $0x14,%esp
  80157b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80157e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801581:	50                   	push   %eax
  801582:	53                   	push   %ebx
  801583:	e8 e4 fb ff ff       	call   80116c <fd_lookup>
  801588:	83 c4 08             	add    $0x8,%esp
  80158b:	85 c0                	test   %eax,%eax
  80158d:	78 5f                	js     8015ee <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80158f:	83 ec 08             	sub    $0x8,%esp
  801592:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801595:	50                   	push   %eax
  801596:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801599:	ff 30                	pushl  (%eax)
  80159b:	e8 23 fc ff ff       	call   8011c3 <dev_lookup>
  8015a0:	83 c4 10             	add    $0x10,%esp
  8015a3:	85 c0                	test   %eax,%eax
  8015a5:	78 47                	js     8015ee <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015aa:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015ae:	75 21                	jne    8015d1 <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8015b0:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8015b5:	8b 40 48             	mov    0x48(%eax),%eax
  8015b8:	83 ec 04             	sub    $0x4,%esp
  8015bb:	53                   	push   %ebx
  8015bc:	50                   	push   %eax
  8015bd:	68 14 27 80 00       	push   $0x802714
  8015c2:	e8 e9 eb ff ff       	call   8001b0 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8015c7:	83 c4 10             	add    $0x10,%esp
  8015ca:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015cf:	eb 1d                	jmp    8015ee <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  8015d1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015d4:	8b 52 18             	mov    0x18(%edx),%edx
  8015d7:	85 d2                	test   %edx,%edx
  8015d9:	74 0e                	je     8015e9 <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8015db:	83 ec 08             	sub    $0x8,%esp
  8015de:	ff 75 0c             	pushl  0xc(%ebp)
  8015e1:	50                   	push   %eax
  8015e2:	ff d2                	call   *%edx
  8015e4:	83 c4 10             	add    $0x10,%esp
  8015e7:	eb 05                	jmp    8015ee <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8015e9:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8015ee:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015f1:	c9                   	leave  
  8015f2:	c3                   	ret    

008015f3 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8015f3:	55                   	push   %ebp
  8015f4:	89 e5                	mov    %esp,%ebp
  8015f6:	53                   	push   %ebx
  8015f7:	83 ec 14             	sub    $0x14,%esp
  8015fa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015fd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801600:	50                   	push   %eax
  801601:	ff 75 08             	pushl  0x8(%ebp)
  801604:	e8 63 fb ff ff       	call   80116c <fd_lookup>
  801609:	83 c4 08             	add    $0x8,%esp
  80160c:	85 c0                	test   %eax,%eax
  80160e:	78 52                	js     801662 <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801610:	83 ec 08             	sub    $0x8,%esp
  801613:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801616:	50                   	push   %eax
  801617:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80161a:	ff 30                	pushl  (%eax)
  80161c:	e8 a2 fb ff ff       	call   8011c3 <dev_lookup>
  801621:	83 c4 10             	add    $0x10,%esp
  801624:	85 c0                	test   %eax,%eax
  801626:	78 3a                	js     801662 <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  801628:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80162b:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80162f:	74 2c                	je     80165d <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801631:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801634:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80163b:	00 00 00 
	stat->st_isdir = 0;
  80163e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801645:	00 00 00 
	stat->st_dev = dev;
  801648:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80164e:	83 ec 08             	sub    $0x8,%esp
  801651:	53                   	push   %ebx
  801652:	ff 75 f0             	pushl  -0x10(%ebp)
  801655:	ff 50 14             	call   *0x14(%eax)
  801658:	83 c4 10             	add    $0x10,%esp
  80165b:	eb 05                	jmp    801662 <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80165d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801662:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801665:	c9                   	leave  
  801666:	c3                   	ret    

00801667 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801667:	55                   	push   %ebp
  801668:	89 e5                	mov    %esp,%ebp
  80166a:	56                   	push   %esi
  80166b:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80166c:	83 ec 08             	sub    $0x8,%esp
  80166f:	6a 00                	push   $0x0
  801671:	ff 75 08             	pushl  0x8(%ebp)
  801674:	e8 75 01 00 00       	call   8017ee <open>
  801679:	89 c3                	mov    %eax,%ebx
  80167b:	83 c4 10             	add    $0x10,%esp
  80167e:	85 c0                	test   %eax,%eax
  801680:	78 1d                	js     80169f <stat+0x38>
		return fd;
	r = fstat(fd, stat);
  801682:	83 ec 08             	sub    $0x8,%esp
  801685:	ff 75 0c             	pushl  0xc(%ebp)
  801688:	50                   	push   %eax
  801689:	e8 65 ff ff ff       	call   8015f3 <fstat>
  80168e:	89 c6                	mov    %eax,%esi
	close(fd);
  801690:	89 1c 24             	mov    %ebx,(%esp)
  801693:	e8 1d fc ff ff       	call   8012b5 <close>
	return r;
  801698:	83 c4 10             	add    $0x10,%esp
  80169b:	89 f0                	mov    %esi,%eax
  80169d:	eb 00                	jmp    80169f <stat+0x38>
}
  80169f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016a2:	5b                   	pop    %ebx
  8016a3:	5e                   	pop    %esi
  8016a4:	5d                   	pop    %ebp
  8016a5:	c3                   	ret    

008016a6 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8016a6:	55                   	push   %ebp
  8016a7:	89 e5                	mov    %esp,%ebp
  8016a9:	56                   	push   %esi
  8016aa:	53                   	push   %ebx
  8016ab:	89 c6                	mov    %eax,%esi
  8016ad:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8016af:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8016b6:	75 12                	jne    8016ca <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8016b8:	83 ec 0c             	sub    $0xc,%esp
  8016bb:	6a 01                	push   $0x1
  8016bd:	e8 5f 08 00 00       	call   801f21 <ipc_find_env>
  8016c2:	a3 00 40 80 00       	mov    %eax,0x804000
  8016c7:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8016ca:	6a 07                	push   $0x7
  8016cc:	68 00 50 80 00       	push   $0x805000
  8016d1:	56                   	push   %esi
  8016d2:	ff 35 00 40 80 00    	pushl  0x804000
  8016d8:	e8 e5 07 00 00       	call   801ec2 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8016dd:	83 c4 0c             	add    $0xc,%esp
  8016e0:	6a 00                	push   $0x0
  8016e2:	53                   	push   %ebx
  8016e3:	6a 00                	push   $0x0
  8016e5:	e8 63 07 00 00       	call   801e4d <ipc_recv>
}
  8016ea:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016ed:	5b                   	pop    %ebx
  8016ee:	5e                   	pop    %esi
  8016ef:	5d                   	pop    %ebp
  8016f0:	c3                   	ret    

008016f1 <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8016f1:	55                   	push   %ebp
  8016f2:	89 e5                	mov    %esp,%ebp
  8016f4:	53                   	push   %ebx
  8016f5:	83 ec 04             	sub    $0x4,%esp
  8016f8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8016fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8016fe:	8b 40 0c             	mov    0xc(%eax),%eax
  801701:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801706:	ba 00 00 00 00       	mov    $0x0,%edx
  80170b:	b8 05 00 00 00       	mov    $0x5,%eax
  801710:	e8 91 ff ff ff       	call   8016a6 <fsipc>
  801715:	85 c0                	test   %eax,%eax
  801717:	78 2c                	js     801745 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801719:	83 ec 08             	sub    $0x8,%esp
  80171c:	68 00 50 80 00       	push   $0x805000
  801721:	53                   	push   %ebx
  801722:	e8 6e f0 ff ff       	call   800795 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801727:	a1 80 50 80 00       	mov    0x805080,%eax
  80172c:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801732:	a1 84 50 80 00       	mov    0x805084,%eax
  801737:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80173d:	83 c4 10             	add    $0x10,%esp
  801740:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801745:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801748:	c9                   	leave  
  801749:	c3                   	ret    

0080174a <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80174a:	55                   	push   %ebp
  80174b:	89 e5                	mov    %esp,%ebp
  80174d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801750:	8b 45 08             	mov    0x8(%ebp),%eax
  801753:	8b 40 0c             	mov    0xc(%eax),%eax
  801756:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80175b:	ba 00 00 00 00       	mov    $0x0,%edx
  801760:	b8 06 00 00 00       	mov    $0x6,%eax
  801765:	e8 3c ff ff ff       	call   8016a6 <fsipc>
}
  80176a:	c9                   	leave  
  80176b:	c3                   	ret    

0080176c <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80176c:	55                   	push   %ebp
  80176d:	89 e5                	mov    %esp,%ebp
  80176f:	56                   	push   %esi
  801770:	53                   	push   %ebx
  801771:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801774:	8b 45 08             	mov    0x8(%ebp),%eax
  801777:	8b 40 0c             	mov    0xc(%eax),%eax
  80177a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80177f:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801785:	ba 00 00 00 00       	mov    $0x0,%edx
  80178a:	b8 03 00 00 00       	mov    $0x3,%eax
  80178f:	e8 12 ff ff ff       	call   8016a6 <fsipc>
  801794:	89 c3                	mov    %eax,%ebx
  801796:	85 c0                	test   %eax,%eax
  801798:	78 4b                	js     8017e5 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80179a:	39 c6                	cmp    %eax,%esi
  80179c:	73 16                	jae    8017b4 <devfile_read+0x48>
  80179e:	68 6e 27 80 00       	push   $0x80276e
  8017a3:	68 75 27 80 00       	push   $0x802775
  8017a8:	6a 7a                	push   $0x7a
  8017aa:	68 8a 27 80 00       	push   $0x80278a
  8017af:	e8 b5 05 00 00       	call   801d69 <_panic>
	assert(r <= PGSIZE);
  8017b4:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8017b9:	7e 16                	jle    8017d1 <devfile_read+0x65>
  8017bb:	68 95 27 80 00       	push   $0x802795
  8017c0:	68 75 27 80 00       	push   $0x802775
  8017c5:	6a 7b                	push   $0x7b
  8017c7:	68 8a 27 80 00       	push   $0x80278a
  8017cc:	e8 98 05 00 00       	call   801d69 <_panic>
	memmove(buf, &fsipcbuf, r);
  8017d1:	83 ec 04             	sub    $0x4,%esp
  8017d4:	50                   	push   %eax
  8017d5:	68 00 50 80 00       	push   $0x805000
  8017da:	ff 75 0c             	pushl  0xc(%ebp)
  8017dd:	e8 80 f1 ff ff       	call   800962 <memmove>
	return r;
  8017e2:	83 c4 10             	add    $0x10,%esp
}
  8017e5:	89 d8                	mov    %ebx,%eax
  8017e7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017ea:	5b                   	pop    %ebx
  8017eb:	5e                   	pop    %esi
  8017ec:	5d                   	pop    %ebp
  8017ed:	c3                   	ret    

008017ee <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8017ee:	55                   	push   %ebp
  8017ef:	89 e5                	mov    %esp,%ebp
  8017f1:	53                   	push   %ebx
  8017f2:	83 ec 20             	sub    $0x20,%esp
  8017f5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8017f8:	53                   	push   %ebx
  8017f9:	e8 40 ef ff ff       	call   80073e <strlen>
  8017fe:	83 c4 10             	add    $0x10,%esp
  801801:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801806:	7f 63                	jg     80186b <open+0x7d>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801808:	83 ec 0c             	sub    $0xc,%esp
  80180b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80180e:	50                   	push   %eax
  80180f:	e8 e4 f8 ff ff       	call   8010f8 <fd_alloc>
  801814:	83 c4 10             	add    $0x10,%esp
  801817:	85 c0                	test   %eax,%eax
  801819:	78 55                	js     801870 <open+0x82>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80181b:	83 ec 08             	sub    $0x8,%esp
  80181e:	53                   	push   %ebx
  80181f:	68 00 50 80 00       	push   $0x805000
  801824:	e8 6c ef ff ff       	call   800795 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801829:	8b 45 0c             	mov    0xc(%ebp),%eax
  80182c:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801831:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801834:	b8 01 00 00 00       	mov    $0x1,%eax
  801839:	e8 68 fe ff ff       	call   8016a6 <fsipc>
  80183e:	89 c3                	mov    %eax,%ebx
  801840:	83 c4 10             	add    $0x10,%esp
  801843:	85 c0                	test   %eax,%eax
  801845:	79 14                	jns    80185b <open+0x6d>
		fd_close(fd, 0);
  801847:	83 ec 08             	sub    $0x8,%esp
  80184a:	6a 00                	push   $0x0
  80184c:	ff 75 f4             	pushl  -0xc(%ebp)
  80184f:	e8 dd f9 ff ff       	call   801231 <fd_close>
		return r;
  801854:	83 c4 10             	add    $0x10,%esp
  801857:	89 d8                	mov    %ebx,%eax
  801859:	eb 15                	jmp    801870 <open+0x82>
	}

	return fd2num(fd);
  80185b:	83 ec 0c             	sub    $0xc,%esp
  80185e:	ff 75 f4             	pushl  -0xc(%ebp)
  801861:	e8 6b f8 ff ff       	call   8010d1 <fd2num>
  801866:	83 c4 10             	add    $0x10,%esp
  801869:	eb 05                	jmp    801870 <open+0x82>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80186b:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801870:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801873:	c9                   	leave  
  801874:	c3                   	ret    

00801875 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801875:	55                   	push   %ebp
  801876:	89 e5                	mov    %esp,%ebp
  801878:	56                   	push   %esi
  801879:	53                   	push   %ebx
  80187a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80187d:	83 ec 0c             	sub    $0xc,%esp
  801880:	ff 75 08             	pushl  0x8(%ebp)
  801883:	e8 59 f8 ff ff       	call   8010e1 <fd2data>
  801888:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80188a:	83 c4 08             	add    $0x8,%esp
  80188d:	68 a1 27 80 00       	push   $0x8027a1
  801892:	53                   	push   %ebx
  801893:	e8 fd ee ff ff       	call   800795 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801898:	8b 46 04             	mov    0x4(%esi),%eax
  80189b:	2b 06                	sub    (%esi),%eax
  80189d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8018a3:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8018aa:	00 00 00 
	stat->st_dev = &devpipe;
  8018ad:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8018b4:	30 80 00 
	return 0;
}
  8018b7:	b8 00 00 00 00       	mov    $0x0,%eax
  8018bc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018bf:	5b                   	pop    %ebx
  8018c0:	5e                   	pop    %esi
  8018c1:	5d                   	pop    %ebp
  8018c2:	c3                   	ret    

008018c3 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8018c3:	55                   	push   %ebp
  8018c4:	89 e5                	mov    %esp,%ebp
  8018c6:	53                   	push   %ebx
  8018c7:	83 ec 0c             	sub    $0xc,%esp
  8018ca:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8018cd:	53                   	push   %ebx
  8018ce:	6a 00                	push   $0x0
  8018d0:	e8 b5 f3 ff ff       	call   800c8a <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8018d5:	89 1c 24             	mov    %ebx,(%esp)
  8018d8:	e8 04 f8 ff ff       	call   8010e1 <fd2data>
  8018dd:	83 c4 08             	add    $0x8,%esp
  8018e0:	50                   	push   %eax
  8018e1:	6a 00                	push   $0x0
  8018e3:	e8 a2 f3 ff ff       	call   800c8a <sys_page_unmap>
}
  8018e8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018eb:	c9                   	leave  
  8018ec:	c3                   	ret    

008018ed <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8018ed:	55                   	push   %ebp
  8018ee:	89 e5                	mov    %esp,%ebp
  8018f0:	57                   	push   %edi
  8018f1:	56                   	push   %esi
  8018f2:	53                   	push   %ebx
  8018f3:	83 ec 1c             	sub    $0x1c,%esp
  8018f6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8018f9:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8018fb:	a1 04 40 80 00       	mov    0x804004,%eax
  801900:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801903:	83 ec 0c             	sub    $0xc,%esp
  801906:	ff 75 e0             	pushl  -0x20(%ebp)
  801909:	e8 6e 06 00 00       	call   801f7c <pageref>
  80190e:	89 c3                	mov    %eax,%ebx
  801910:	89 3c 24             	mov    %edi,(%esp)
  801913:	e8 64 06 00 00       	call   801f7c <pageref>
  801918:	83 c4 10             	add    $0x10,%esp
  80191b:	39 c3                	cmp    %eax,%ebx
  80191d:	0f 94 c1             	sete   %cl
  801920:	0f b6 c9             	movzbl %cl,%ecx
  801923:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801926:	8b 15 04 40 80 00    	mov    0x804004,%edx
  80192c:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  80192f:	39 ce                	cmp    %ecx,%esi
  801931:	74 1b                	je     80194e <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801933:	39 c3                	cmp    %eax,%ebx
  801935:	75 c4                	jne    8018fb <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801937:	8b 42 58             	mov    0x58(%edx),%eax
  80193a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80193d:	50                   	push   %eax
  80193e:	56                   	push   %esi
  80193f:	68 a8 27 80 00       	push   $0x8027a8
  801944:	e8 67 e8 ff ff       	call   8001b0 <cprintf>
  801949:	83 c4 10             	add    $0x10,%esp
  80194c:	eb ad                	jmp    8018fb <_pipeisclosed+0xe>
	}
}
  80194e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801951:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801954:	5b                   	pop    %ebx
  801955:	5e                   	pop    %esi
  801956:	5f                   	pop    %edi
  801957:	5d                   	pop    %ebp
  801958:	c3                   	ret    

00801959 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801959:	55                   	push   %ebp
  80195a:	89 e5                	mov    %esp,%ebp
  80195c:	57                   	push   %edi
  80195d:	56                   	push   %esi
  80195e:	53                   	push   %ebx
  80195f:	83 ec 18             	sub    $0x18,%esp
  801962:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801965:	56                   	push   %esi
  801966:	e8 76 f7 ff ff       	call   8010e1 <fd2data>
  80196b:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80196d:	83 c4 10             	add    $0x10,%esp
  801970:	bf 00 00 00 00       	mov    $0x0,%edi
  801975:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801979:	75 42                	jne    8019bd <devpipe_write+0x64>
  80197b:	eb 4e                	jmp    8019cb <devpipe_write+0x72>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80197d:	89 da                	mov    %ebx,%edx
  80197f:	89 f0                	mov    %esi,%eax
  801981:	e8 67 ff ff ff       	call   8018ed <_pipeisclosed>
  801986:	85 c0                	test   %eax,%eax
  801988:	75 46                	jne    8019d0 <devpipe_write+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80198a:	e8 57 f2 ff ff       	call   800be6 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80198f:	8b 53 04             	mov    0x4(%ebx),%edx
  801992:	8b 03                	mov    (%ebx),%eax
  801994:	83 c0 20             	add    $0x20,%eax
  801997:	39 c2                	cmp    %eax,%edx
  801999:	73 e2                	jae    80197d <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80199b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80199e:	8a 0c 38             	mov    (%eax,%edi,1),%cl
  8019a1:	89 d0                	mov    %edx,%eax
  8019a3:	25 1f 00 00 80       	and    $0x8000001f,%eax
  8019a8:	79 05                	jns    8019af <devpipe_write+0x56>
  8019aa:	48                   	dec    %eax
  8019ab:	83 c8 e0             	or     $0xffffffe0,%eax
  8019ae:	40                   	inc    %eax
  8019af:	88 4c 03 08          	mov    %cl,0x8(%ebx,%eax,1)
		p->p_wpos++;
  8019b3:	42                   	inc    %edx
  8019b4:	89 53 04             	mov    %edx,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019b7:	47                   	inc    %edi
  8019b8:	39 7d 10             	cmp    %edi,0x10(%ebp)
  8019bb:	74 0e                	je     8019cb <devpipe_write+0x72>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8019bd:	8b 53 04             	mov    0x4(%ebx),%edx
  8019c0:	8b 03                	mov    (%ebx),%eax
  8019c2:	83 c0 20             	add    $0x20,%eax
  8019c5:	39 c2                	cmp    %eax,%edx
  8019c7:	73 b4                	jae    80197d <devpipe_write+0x24>
  8019c9:	eb d0                	jmp    80199b <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8019cb:	8b 45 10             	mov    0x10(%ebp),%eax
  8019ce:	eb 05                	jmp    8019d5 <devpipe_write+0x7c>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8019d0:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8019d5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019d8:	5b                   	pop    %ebx
  8019d9:	5e                   	pop    %esi
  8019da:	5f                   	pop    %edi
  8019db:	5d                   	pop    %ebp
  8019dc:	c3                   	ret    

008019dd <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8019dd:	55                   	push   %ebp
  8019de:	89 e5                	mov    %esp,%ebp
  8019e0:	57                   	push   %edi
  8019e1:	56                   	push   %esi
  8019e2:	53                   	push   %ebx
  8019e3:	83 ec 18             	sub    $0x18,%esp
  8019e6:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8019e9:	57                   	push   %edi
  8019ea:	e8 f2 f6 ff ff       	call   8010e1 <fd2data>
  8019ef:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019f1:	83 c4 10             	add    $0x10,%esp
  8019f4:	be 00 00 00 00       	mov    $0x0,%esi
  8019f9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8019fd:	75 3d                	jne    801a3c <devpipe_read+0x5f>
  8019ff:	eb 48                	jmp    801a49 <devpipe_read+0x6c>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  801a01:	89 f0                	mov    %esi,%eax
  801a03:	eb 4e                	jmp    801a53 <devpipe_read+0x76>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801a05:	89 da                	mov    %ebx,%edx
  801a07:	89 f8                	mov    %edi,%eax
  801a09:	e8 df fe ff ff       	call   8018ed <_pipeisclosed>
  801a0e:	85 c0                	test   %eax,%eax
  801a10:	75 3c                	jne    801a4e <devpipe_read+0x71>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801a12:	e8 cf f1 ff ff       	call   800be6 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801a17:	8b 03                	mov    (%ebx),%eax
  801a19:	3b 43 04             	cmp    0x4(%ebx),%eax
  801a1c:	74 e7                	je     801a05 <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801a1e:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801a23:	79 05                	jns    801a2a <devpipe_read+0x4d>
  801a25:	48                   	dec    %eax
  801a26:	83 c8 e0             	or     $0xffffffe0,%eax
  801a29:	40                   	inc    %eax
  801a2a:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801a2e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a31:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801a34:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a36:	46                   	inc    %esi
  801a37:	39 75 10             	cmp    %esi,0x10(%ebp)
  801a3a:	74 0d                	je     801a49 <devpipe_read+0x6c>
		while (p->p_rpos == p->p_wpos) {
  801a3c:	8b 03                	mov    (%ebx),%eax
  801a3e:	3b 43 04             	cmp    0x4(%ebx),%eax
  801a41:	75 db                	jne    801a1e <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801a43:	85 f6                	test   %esi,%esi
  801a45:	75 ba                	jne    801a01 <devpipe_read+0x24>
  801a47:	eb bc                	jmp    801a05 <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801a49:	8b 45 10             	mov    0x10(%ebp),%eax
  801a4c:	eb 05                	jmp    801a53 <devpipe_read+0x76>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801a4e:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801a53:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a56:	5b                   	pop    %ebx
  801a57:	5e                   	pop    %esi
  801a58:	5f                   	pop    %edi
  801a59:	5d                   	pop    %ebp
  801a5a:	c3                   	ret    

00801a5b <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801a5b:	55                   	push   %ebp
  801a5c:	89 e5                	mov    %esp,%ebp
  801a5e:	56                   	push   %esi
  801a5f:	53                   	push   %ebx
  801a60:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801a63:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a66:	50                   	push   %eax
  801a67:	e8 8c f6 ff ff       	call   8010f8 <fd_alloc>
  801a6c:	83 c4 10             	add    $0x10,%esp
  801a6f:	85 c0                	test   %eax,%eax
  801a71:	0f 88 2a 01 00 00    	js     801ba1 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a77:	83 ec 04             	sub    $0x4,%esp
  801a7a:	68 07 04 00 00       	push   $0x407
  801a7f:	ff 75 f4             	pushl  -0xc(%ebp)
  801a82:	6a 00                	push   $0x0
  801a84:	e8 7c f1 ff ff       	call   800c05 <sys_page_alloc>
  801a89:	83 c4 10             	add    $0x10,%esp
  801a8c:	85 c0                	test   %eax,%eax
  801a8e:	0f 88 0d 01 00 00    	js     801ba1 <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801a94:	83 ec 0c             	sub    $0xc,%esp
  801a97:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a9a:	50                   	push   %eax
  801a9b:	e8 58 f6 ff ff       	call   8010f8 <fd_alloc>
  801aa0:	89 c3                	mov    %eax,%ebx
  801aa2:	83 c4 10             	add    $0x10,%esp
  801aa5:	85 c0                	test   %eax,%eax
  801aa7:	0f 88 e2 00 00 00    	js     801b8f <pipe+0x134>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801aad:	83 ec 04             	sub    $0x4,%esp
  801ab0:	68 07 04 00 00       	push   $0x407
  801ab5:	ff 75 f0             	pushl  -0x10(%ebp)
  801ab8:	6a 00                	push   $0x0
  801aba:	e8 46 f1 ff ff       	call   800c05 <sys_page_alloc>
  801abf:	89 c3                	mov    %eax,%ebx
  801ac1:	83 c4 10             	add    $0x10,%esp
  801ac4:	85 c0                	test   %eax,%eax
  801ac6:	0f 88 c3 00 00 00    	js     801b8f <pipe+0x134>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801acc:	83 ec 0c             	sub    $0xc,%esp
  801acf:	ff 75 f4             	pushl  -0xc(%ebp)
  801ad2:	e8 0a f6 ff ff       	call   8010e1 <fd2data>
  801ad7:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ad9:	83 c4 0c             	add    $0xc,%esp
  801adc:	68 07 04 00 00       	push   $0x407
  801ae1:	50                   	push   %eax
  801ae2:	6a 00                	push   $0x0
  801ae4:	e8 1c f1 ff ff       	call   800c05 <sys_page_alloc>
  801ae9:	89 c3                	mov    %eax,%ebx
  801aeb:	83 c4 10             	add    $0x10,%esp
  801aee:	85 c0                	test   %eax,%eax
  801af0:	0f 88 89 00 00 00    	js     801b7f <pipe+0x124>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801af6:	83 ec 0c             	sub    $0xc,%esp
  801af9:	ff 75 f0             	pushl  -0x10(%ebp)
  801afc:	e8 e0 f5 ff ff       	call   8010e1 <fd2data>
  801b01:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801b08:	50                   	push   %eax
  801b09:	6a 00                	push   $0x0
  801b0b:	56                   	push   %esi
  801b0c:	6a 00                	push   $0x0
  801b0e:	e8 35 f1 ff ff       	call   800c48 <sys_page_map>
  801b13:	89 c3                	mov    %eax,%ebx
  801b15:	83 c4 20             	add    $0x20,%esp
  801b18:	85 c0                	test   %eax,%eax
  801b1a:	78 55                	js     801b71 <pipe+0x116>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801b1c:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b22:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b25:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801b27:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b2a:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801b31:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b37:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b3a:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801b3c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b3f:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801b46:	83 ec 0c             	sub    $0xc,%esp
  801b49:	ff 75 f4             	pushl  -0xc(%ebp)
  801b4c:	e8 80 f5 ff ff       	call   8010d1 <fd2num>
  801b51:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b54:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801b56:	83 c4 04             	add    $0x4,%esp
  801b59:	ff 75 f0             	pushl  -0x10(%ebp)
  801b5c:	e8 70 f5 ff ff       	call   8010d1 <fd2num>
  801b61:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b64:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801b67:	83 c4 10             	add    $0x10,%esp
  801b6a:	b8 00 00 00 00       	mov    $0x0,%eax
  801b6f:	eb 30                	jmp    801ba1 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  801b71:	83 ec 08             	sub    $0x8,%esp
  801b74:	56                   	push   %esi
  801b75:	6a 00                	push   $0x0
  801b77:	e8 0e f1 ff ff       	call   800c8a <sys_page_unmap>
  801b7c:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801b7f:	83 ec 08             	sub    $0x8,%esp
  801b82:	ff 75 f0             	pushl  -0x10(%ebp)
  801b85:	6a 00                	push   $0x0
  801b87:	e8 fe f0 ff ff       	call   800c8a <sys_page_unmap>
  801b8c:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801b8f:	83 ec 08             	sub    $0x8,%esp
  801b92:	ff 75 f4             	pushl  -0xc(%ebp)
  801b95:	6a 00                	push   $0x0
  801b97:	e8 ee f0 ff ff       	call   800c8a <sys_page_unmap>
  801b9c:	83 c4 10             	add    $0x10,%esp
  801b9f:	89 d8                	mov    %ebx,%eax
    err:
	return r;
}
  801ba1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ba4:	5b                   	pop    %ebx
  801ba5:	5e                   	pop    %esi
  801ba6:	5d                   	pop    %ebp
  801ba7:	c3                   	ret    

00801ba8 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801ba8:	55                   	push   %ebp
  801ba9:	89 e5                	mov    %esp,%ebp
  801bab:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801bae:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bb1:	50                   	push   %eax
  801bb2:	ff 75 08             	pushl  0x8(%ebp)
  801bb5:	e8 b2 f5 ff ff       	call   80116c <fd_lookup>
  801bba:	83 c4 10             	add    $0x10,%esp
  801bbd:	85 c0                	test   %eax,%eax
  801bbf:	78 18                	js     801bd9 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801bc1:	83 ec 0c             	sub    $0xc,%esp
  801bc4:	ff 75 f4             	pushl  -0xc(%ebp)
  801bc7:	e8 15 f5 ff ff       	call   8010e1 <fd2data>
	return _pipeisclosed(fd, p);
  801bcc:	89 c2                	mov    %eax,%edx
  801bce:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bd1:	e8 17 fd ff ff       	call   8018ed <_pipeisclosed>
  801bd6:	83 c4 10             	add    $0x10,%esp
}
  801bd9:	c9                   	leave  
  801bda:	c3                   	ret    

00801bdb <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801bdb:	55                   	push   %ebp
  801bdc:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801bde:	b8 00 00 00 00       	mov    $0x0,%eax
  801be3:	5d                   	pop    %ebp
  801be4:	c3                   	ret    

00801be5 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801be5:	55                   	push   %ebp
  801be6:	89 e5                	mov    %esp,%ebp
  801be8:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801beb:	68 c0 27 80 00       	push   $0x8027c0
  801bf0:	ff 75 0c             	pushl  0xc(%ebp)
  801bf3:	e8 9d eb ff ff       	call   800795 <strcpy>
	return 0;
}
  801bf8:	b8 00 00 00 00       	mov    $0x0,%eax
  801bfd:	c9                   	leave  
  801bfe:	c3                   	ret    

00801bff <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801bff:	55                   	push   %ebp
  801c00:	89 e5                	mov    %esp,%ebp
  801c02:	57                   	push   %edi
  801c03:	56                   	push   %esi
  801c04:	53                   	push   %ebx
  801c05:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c0b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801c0f:	74 45                	je     801c56 <devcons_write+0x57>
  801c11:	b8 00 00 00 00       	mov    $0x0,%eax
  801c16:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801c1b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801c21:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801c24:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  801c26:	83 fb 7f             	cmp    $0x7f,%ebx
  801c29:	76 05                	jbe    801c30 <devcons_write+0x31>
			m = sizeof(buf) - 1;
  801c2b:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801c30:	83 ec 04             	sub    $0x4,%esp
  801c33:	53                   	push   %ebx
  801c34:	03 45 0c             	add    0xc(%ebp),%eax
  801c37:	50                   	push   %eax
  801c38:	57                   	push   %edi
  801c39:	e8 24 ed ff ff       	call   800962 <memmove>
		sys_cputs(buf, m);
  801c3e:	83 c4 08             	add    $0x8,%esp
  801c41:	53                   	push   %ebx
  801c42:	57                   	push   %edi
  801c43:	e8 01 ef ff ff       	call   800b49 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c48:	01 de                	add    %ebx,%esi
  801c4a:	89 f0                	mov    %esi,%eax
  801c4c:	83 c4 10             	add    $0x10,%esp
  801c4f:	3b 75 10             	cmp    0x10(%ebp),%esi
  801c52:	72 cd                	jb     801c21 <devcons_write+0x22>
  801c54:	eb 05                	jmp    801c5b <devcons_write+0x5c>
  801c56:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801c5b:	89 f0                	mov    %esi,%eax
  801c5d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c60:	5b                   	pop    %ebx
  801c61:	5e                   	pop    %esi
  801c62:	5f                   	pop    %edi
  801c63:	5d                   	pop    %ebp
  801c64:	c3                   	ret    

00801c65 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c65:	55                   	push   %ebp
  801c66:	89 e5                	mov    %esp,%ebp
  801c68:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801c6b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801c6f:	75 07                	jne    801c78 <devcons_read+0x13>
  801c71:	eb 23                	jmp    801c96 <devcons_read+0x31>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801c73:	e8 6e ef ff ff       	call   800be6 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801c78:	e8 ea ee ff ff       	call   800b67 <sys_cgetc>
  801c7d:	85 c0                	test   %eax,%eax
  801c7f:	74 f2                	je     801c73 <devcons_read+0xe>
		sys_yield();
	if (c < 0)
  801c81:	85 c0                	test   %eax,%eax
  801c83:	78 1d                	js     801ca2 <devcons_read+0x3d>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801c85:	83 f8 04             	cmp    $0x4,%eax
  801c88:	74 13                	je     801c9d <devcons_read+0x38>
		return 0;
	*(char*)vbuf = c;
  801c8a:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c8d:	88 02                	mov    %al,(%edx)
	return 1;
  801c8f:	b8 01 00 00 00       	mov    $0x1,%eax
  801c94:	eb 0c                	jmp    801ca2 <devcons_read+0x3d>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801c96:	b8 00 00 00 00       	mov    $0x0,%eax
  801c9b:	eb 05                	jmp    801ca2 <devcons_read+0x3d>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801c9d:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801ca2:	c9                   	leave  
  801ca3:	c3                   	ret    

00801ca4 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801ca4:	55                   	push   %ebp
  801ca5:	89 e5                	mov    %esp,%ebp
  801ca7:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801caa:	8b 45 08             	mov    0x8(%ebp),%eax
  801cad:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801cb0:	6a 01                	push   $0x1
  801cb2:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801cb5:	50                   	push   %eax
  801cb6:	e8 8e ee ff ff       	call   800b49 <sys_cputs>
}
  801cbb:	83 c4 10             	add    $0x10,%esp
  801cbe:	c9                   	leave  
  801cbf:	c3                   	ret    

00801cc0 <getchar>:

int
getchar(void)
{
  801cc0:	55                   	push   %ebp
  801cc1:	89 e5                	mov    %esp,%ebp
  801cc3:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801cc6:	6a 01                	push   $0x1
  801cc8:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ccb:	50                   	push   %eax
  801ccc:	6a 00                	push   $0x0
  801cce:	e8 1a f7 ff ff       	call   8013ed <read>
	if (r < 0)
  801cd3:	83 c4 10             	add    $0x10,%esp
  801cd6:	85 c0                	test   %eax,%eax
  801cd8:	78 0f                	js     801ce9 <getchar+0x29>
		return r;
	if (r < 1)
  801cda:	85 c0                	test   %eax,%eax
  801cdc:	7e 06                	jle    801ce4 <getchar+0x24>
		return -E_EOF;
	return c;
  801cde:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801ce2:	eb 05                	jmp    801ce9 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801ce4:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801ce9:	c9                   	leave  
  801cea:	c3                   	ret    

00801ceb <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801ceb:	55                   	push   %ebp
  801cec:	89 e5                	mov    %esp,%ebp
  801cee:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801cf1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cf4:	50                   	push   %eax
  801cf5:	ff 75 08             	pushl  0x8(%ebp)
  801cf8:	e8 6f f4 ff ff       	call   80116c <fd_lookup>
  801cfd:	83 c4 10             	add    $0x10,%esp
  801d00:	85 c0                	test   %eax,%eax
  801d02:	78 11                	js     801d15 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801d04:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d07:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d0d:	39 10                	cmp    %edx,(%eax)
  801d0f:	0f 94 c0             	sete   %al
  801d12:	0f b6 c0             	movzbl %al,%eax
}
  801d15:	c9                   	leave  
  801d16:	c3                   	ret    

00801d17 <opencons>:

int
opencons(void)
{
  801d17:	55                   	push   %ebp
  801d18:	89 e5                	mov    %esp,%ebp
  801d1a:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801d1d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d20:	50                   	push   %eax
  801d21:	e8 d2 f3 ff ff       	call   8010f8 <fd_alloc>
  801d26:	83 c4 10             	add    $0x10,%esp
  801d29:	85 c0                	test   %eax,%eax
  801d2b:	78 3a                	js     801d67 <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801d2d:	83 ec 04             	sub    $0x4,%esp
  801d30:	68 07 04 00 00       	push   $0x407
  801d35:	ff 75 f4             	pushl  -0xc(%ebp)
  801d38:	6a 00                	push   $0x0
  801d3a:	e8 c6 ee ff ff       	call   800c05 <sys_page_alloc>
  801d3f:	83 c4 10             	add    $0x10,%esp
  801d42:	85 c0                	test   %eax,%eax
  801d44:	78 21                	js     801d67 <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801d46:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d4f:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801d51:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d54:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801d5b:	83 ec 0c             	sub    $0xc,%esp
  801d5e:	50                   	push   %eax
  801d5f:	e8 6d f3 ff ff       	call   8010d1 <fd2num>
  801d64:	83 c4 10             	add    $0x10,%esp
}
  801d67:	c9                   	leave  
  801d68:	c3                   	ret    

00801d69 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801d69:	55                   	push   %ebp
  801d6a:	89 e5                	mov    %esp,%ebp
  801d6c:	56                   	push   %esi
  801d6d:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801d6e:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801d71:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801d77:	e8 4b ee ff ff       	call   800bc7 <sys_getenvid>
  801d7c:	83 ec 0c             	sub    $0xc,%esp
  801d7f:	ff 75 0c             	pushl  0xc(%ebp)
  801d82:	ff 75 08             	pushl  0x8(%ebp)
  801d85:	56                   	push   %esi
  801d86:	50                   	push   %eax
  801d87:	68 cc 27 80 00       	push   $0x8027cc
  801d8c:	e8 1f e4 ff ff       	call   8001b0 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801d91:	83 c4 18             	add    $0x18,%esp
  801d94:	53                   	push   %ebx
  801d95:	ff 75 10             	pushl  0x10(%ebp)
  801d98:	e8 c2 e3 ff ff       	call   80015f <vcprintf>
	cprintf("\n");
  801d9d:	c7 04 24 4b 26 80 00 	movl   $0x80264b,(%esp)
  801da4:	e8 07 e4 ff ff       	call   8001b0 <cprintf>
  801da9:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801dac:	cc                   	int3   
  801dad:	eb fd                	jmp    801dac <_panic+0x43>

00801daf <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801daf:	55                   	push   %ebp
  801db0:	89 e5                	mov    %esp,%ebp
  801db2:	53                   	push   %ebx
  801db3:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (_pgfault_handler == 0) {
  801db6:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801dbd:	75 5b                	jne    801e1a <set_pgfault_handler+0x6b>
		// First time through!
		// LAB 4: Your code here.
		void *va = (void *)(UXSTACKTOP - PGSIZE);
		envid_t eid = sys_getenvid();
  801dbf:	e8 03 ee ff ff       	call   800bc7 <sys_getenvid>
  801dc4:	89 c3                	mov    %eax,%ebx
		r = sys_page_alloc(eid,va,PTE_P | PTE_U | PTE_W);
  801dc6:	83 ec 04             	sub    $0x4,%esp
  801dc9:	6a 07                	push   $0x7
  801dcb:	68 00 f0 bf ee       	push   $0xeebff000
  801dd0:	50                   	push   %eax
  801dd1:	e8 2f ee ff ff       	call   800c05 <sys_page_alloc>
		if(r<0) panic("set_pgfault_handler\n");
  801dd6:	83 c4 10             	add    $0x10,%esp
  801dd9:	85 c0                	test   %eax,%eax
  801ddb:	79 14                	jns    801df1 <set_pgfault_handler+0x42>
  801ddd:	83 ec 04             	sub    $0x4,%esp
  801de0:	68 f0 27 80 00       	push   $0x8027f0
  801de5:	6a 23                	push   $0x23
  801de7:	68 05 28 80 00       	push   $0x802805
  801dec:	e8 78 ff ff ff       	call   801d69 <_panic>
		r = sys_env_set_pgfault_upcall(eid,_pgfault_upcall);
  801df1:	83 ec 08             	sub    $0x8,%esp
  801df4:	68 27 1e 80 00       	push   $0x801e27
  801df9:	53                   	push   %ebx
  801dfa:	e8 51 ef ff ff       	call   800d50 <sys_env_set_pgfault_upcall>
		if(r<0) panic("set_pgfault_handler\n");
  801dff:	83 c4 10             	add    $0x10,%esp
  801e02:	85 c0                	test   %eax,%eax
  801e04:	79 14                	jns    801e1a <set_pgfault_handler+0x6b>
  801e06:	83 ec 04             	sub    $0x4,%esp
  801e09:	68 f0 27 80 00       	push   $0x8027f0
  801e0e:	6a 25                	push   $0x25
  801e10:	68 05 28 80 00       	push   $0x802805
  801e15:	e8 4f ff ff ff       	call   801d69 <_panic>
		// panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801e1a:	8b 45 08             	mov    0x8(%ebp),%eax
  801e1d:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801e22:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e25:	c9                   	leave  
  801e26:	c3                   	ret    

00801e27 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801e27:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801e28:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801e2d:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801e2f:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl %esp,%ebx
  801e32:	89 e3                	mov    %esp,%ebx
	movl 40(%esp),%eax 	// esp from utf_fault_va to utf_regs(end)
  801e34:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl 48(%esp),%esp 	// 
  801e38:	8b 64 24 30          	mov    0x30(%esp),%esp
	pushl %eax
  801e3c:	50                   	push   %eax
 
 
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	movl %ebx,%esp
  801e3d:	89 dc                	mov    %ebx,%esp
	subl $4,48(%esp)
  801e3f:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	popl %eax
  801e44:	58                   	pop    %eax
	popl %eax
  801e45:	58                   	pop    %eax
	popal
  801e46:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	add $4,%esp
  801e47:	83 c4 04             	add    $0x4,%esp
	popfl
  801e4a:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  801e4b:	5c                   	pop    %esp
 
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801e4c:	c3                   	ret    

00801e4d <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e4d:	55                   	push   %ebp
  801e4e:	89 e5                	mov    %esp,%ebp
  801e50:	56                   	push   %esi
  801e51:	53                   	push   %ebx
  801e52:	8b 75 08             	mov    0x8(%ebp),%esi
  801e55:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e58:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");
	int r;
    if (pg != NULL) {
  801e5b:	85 c0                	test   %eax,%eax
  801e5d:	74 0e                	je     801e6d <ipc_recv+0x20>
        r = sys_ipc_recv(pg);
  801e5f:	83 ec 0c             	sub    $0xc,%esp
  801e62:	50                   	push   %eax
  801e63:	e8 4d ef ff ff       	call   800db5 <sys_ipc_recv>
  801e68:	83 c4 10             	add    $0x10,%esp
  801e6b:	eb 10                	jmp    801e7d <ipc_recv+0x30>
    } else {
        r = sys_ipc_recv((void *) UTOP);
  801e6d:	83 ec 0c             	sub    $0xc,%esp
  801e70:	68 00 00 c0 ee       	push   $0xeec00000
  801e75:	e8 3b ef ff ff       	call   800db5 <sys_ipc_recv>
  801e7a:	83 c4 10             	add    $0x10,%esp
    }
    if (r < 0) {
  801e7d:	85 c0                	test   %eax,%eax
  801e7f:	79 16                	jns    801e97 <ipc_recv+0x4a>
        // failed
        if (from_env_store != NULL) *from_env_store = 0;
  801e81:	85 f6                	test   %esi,%esi
  801e83:	74 06                	je     801e8b <ipc_recv+0x3e>
  801e85:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        if (perm_store != NULL) *perm_store = 0;
  801e8b:	85 db                	test   %ebx,%ebx
  801e8d:	74 2c                	je     801ebb <ipc_recv+0x6e>
  801e8f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801e95:	eb 24                	jmp    801ebb <ipc_recv+0x6e>
        return r;
    } else {
        if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801e97:	85 f6                	test   %esi,%esi
  801e99:	74 0a                	je     801ea5 <ipc_recv+0x58>
  801e9b:	a1 04 40 80 00       	mov    0x804004,%eax
  801ea0:	8b 40 74             	mov    0x74(%eax),%eax
  801ea3:	89 06                	mov    %eax,(%esi)
        if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801ea5:	85 db                	test   %ebx,%ebx
  801ea7:	74 0a                	je     801eb3 <ipc_recv+0x66>
  801ea9:	a1 04 40 80 00       	mov    0x804004,%eax
  801eae:	8b 40 78             	mov    0x78(%eax),%eax
  801eb1:	89 03                	mov    %eax,(%ebx)
        return thisenv->env_ipc_value;
  801eb3:	a1 04 40 80 00       	mov    0x804004,%eax
  801eb8:	8b 40 70             	mov    0x70(%eax),%eax
    }
 
	return 0;
}
  801ebb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ebe:	5b                   	pop    %ebx
  801ebf:	5e                   	pop    %esi
  801ec0:	5d                   	pop    %ebp
  801ec1:	c3                   	ret    

00801ec2 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801ec2:	55                   	push   %ebp
  801ec3:	89 e5                	mov    %esp,%ebp
  801ec5:	57                   	push   %edi
  801ec6:	56                   	push   %esi
  801ec7:	53                   	push   %ebx
  801ec8:	83 ec 0c             	sub    $0xc,%esp
  801ecb:	8b 75 10             	mov    0x10(%ebp),%esi
  801ece:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");
	int r;
    if (pg == NULL) pg = (void *)UTOP;
  801ed1:	85 f6                	test   %esi,%esi
  801ed3:	75 05                	jne    801eda <ipc_send+0x18>
  801ed5:	be 00 00 c0 ee       	mov    $0xeec00000,%esi
    do {
        r = sys_ipc_try_send(to_env, val, pg, perm);
  801eda:	57                   	push   %edi
  801edb:	56                   	push   %esi
  801edc:	ff 75 0c             	pushl  0xc(%ebp)
  801edf:	ff 75 08             	pushl  0x8(%ebp)
  801ee2:	e8 ab ee ff ff       	call   800d92 <sys_ipc_try_send>
  801ee7:	89 c3                	mov    %eax,%ebx
        if (r < 0 && r != -E_IPC_NOT_RECV) panic("ipc send failed: %e", r);
  801ee9:	83 c4 10             	add    $0x10,%esp
  801eec:	85 c0                	test   %eax,%eax
  801eee:	79 17                	jns    801f07 <ipc_send+0x45>
  801ef0:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ef3:	74 1d                	je     801f12 <ipc_send+0x50>
  801ef5:	50                   	push   %eax
  801ef6:	68 13 28 80 00       	push   $0x802813
  801efb:	6a 40                	push   $0x40
  801efd:	68 27 28 80 00       	push   $0x802827
  801f02:	e8 62 fe ff ff       	call   801d69 <_panic>
        sys_yield();
  801f07:	e8 da ec ff ff       	call   800be6 <sys_yield>
    } while (r != 0);
  801f0c:	85 db                	test   %ebx,%ebx
  801f0e:	75 ca                	jne    801eda <ipc_send+0x18>
  801f10:	eb 07                	jmp    801f19 <ipc_send+0x57>
	int r;
    if (pg == NULL) pg = (void *)UTOP;
    do {
        r = sys_ipc_try_send(to_env, val, pg, perm);
        if (r < 0 && r != -E_IPC_NOT_RECV) panic("ipc send failed: %e", r);
        sys_yield();
  801f12:	e8 cf ec ff ff       	call   800be6 <sys_yield>
  801f17:	eb c1                	jmp    801eda <ipc_send+0x18>
    } while (r != 0);
}
  801f19:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f1c:	5b                   	pop    %ebx
  801f1d:	5e                   	pop    %esi
  801f1e:	5f                   	pop    %edi
  801f1f:	5d                   	pop    %ebp
  801f20:	c3                   	ret    

00801f21 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f21:	55                   	push   %ebp
  801f22:	89 e5                	mov    %esp,%ebp
  801f24:	53                   	push   %ebx
  801f25:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801f28:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  801f2d:	39 c1                	cmp    %eax,%ecx
  801f2f:	74 21                	je     801f52 <ipc_find_env+0x31>
  801f31:	ba 01 00 00 00       	mov    $0x1,%edx
  801f36:	8d 1c 95 00 00 00 00 	lea    0x0(,%edx,4),%ebx
  801f3d:	89 d0                	mov    %edx,%eax
  801f3f:	c1 e0 07             	shl    $0x7,%eax
  801f42:	29 d8                	sub    %ebx,%eax
  801f44:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801f49:	8b 40 50             	mov    0x50(%eax),%eax
  801f4c:	39 c8                	cmp    %ecx,%eax
  801f4e:	75 1b                	jne    801f6b <ipc_find_env+0x4a>
  801f50:	eb 05                	jmp    801f57 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f52:	ba 00 00 00 00       	mov    $0x0,%edx
		if (envs[i].env_type == type)
			return envs[i].env_id;
  801f57:	8d 04 95 00 00 00 00 	lea    0x0(,%edx,4),%eax
  801f5e:	c1 e2 07             	shl    $0x7,%edx
  801f61:	29 c2                	sub    %eax,%edx
  801f63:	8b 82 48 00 c0 ee    	mov    -0x113fffb8(%edx),%eax
  801f69:	eb 0e                	jmp    801f79 <ipc_find_env+0x58>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f6b:	42                   	inc    %edx
  801f6c:	81 fa 00 04 00 00    	cmp    $0x400,%edx
  801f72:	75 c2                	jne    801f36 <ipc_find_env+0x15>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801f74:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801f79:	5b                   	pop    %ebx
  801f7a:	5d                   	pop    %ebp
  801f7b:	c3                   	ret    

00801f7c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f7c:	55                   	push   %ebp
  801f7d:	89 e5                	mov    %esp,%ebp
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f7f:	8b 45 08             	mov    0x8(%ebp),%eax
  801f82:	c1 e8 16             	shr    $0x16,%eax
  801f85:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801f8c:	a8 01                	test   $0x1,%al
  801f8e:	74 21                	je     801fb1 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f90:	8b 45 08             	mov    0x8(%ebp),%eax
  801f93:	c1 e8 0c             	shr    $0xc,%eax
  801f96:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801f9d:	a8 01                	test   $0x1,%al
  801f9f:	74 17                	je     801fb8 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801fa1:	c1 e8 0c             	shr    $0xc,%eax
  801fa4:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801fab:	ef 
  801fac:	0f b7 c0             	movzwl %ax,%eax
  801faf:	eb 0c                	jmp    801fbd <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801fb1:	b8 00 00 00 00       	mov    $0x0,%eax
  801fb6:	eb 05                	jmp    801fbd <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801fb8:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801fbd:	5d                   	pop    %ebp
  801fbe:	c3                   	ret    
  801fbf:	90                   	nop

00801fc0 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801fc0:	55                   	push   %ebp
  801fc1:	57                   	push   %edi
  801fc2:	56                   	push   %esi
  801fc3:	53                   	push   %ebx
  801fc4:	83 ec 1c             	sub    $0x1c,%esp
  801fc7:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801fcb:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801fcf:	8b 7c 24 38          	mov    0x38(%esp),%edi
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801fd3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801fd7:	89 ca                	mov    %ecx,%edx
  const DWunion dd = {.ll = d};
  801fd9:	89 f8                	mov    %edi,%eax
  801fdb:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801fdf:	85 f6                	test   %esi,%esi
  801fe1:	75 2d                	jne    802010 <__udivdi3+0x50>
    {
      if (d0 > n1)
  801fe3:	39 cf                	cmp    %ecx,%edi
  801fe5:	77 65                	ja     80204c <__udivdi3+0x8c>
  801fe7:	89 fd                	mov    %edi,%ebp
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801fe9:	85 ff                	test   %edi,%edi
  801feb:	75 0b                	jne    801ff8 <__udivdi3+0x38>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801fed:	b8 01 00 00 00       	mov    $0x1,%eax
  801ff2:	31 d2                	xor    %edx,%edx
  801ff4:	f7 f7                	div    %edi
  801ff6:	89 c5                	mov    %eax,%ebp

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801ff8:	31 d2                	xor    %edx,%edx
  801ffa:	89 c8                	mov    %ecx,%eax
  801ffc:	f7 f5                	div    %ebp
  801ffe:	89 c1                	mov    %eax,%ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802000:	89 d8                	mov    %ebx,%eax
  802002:	f7 f5                	div    %ebp
  802004:	89 cf                	mov    %ecx,%edi
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802006:	89 fa                	mov    %edi,%edx
  802008:	83 c4 1c             	add    $0x1c,%esp
  80200b:	5b                   	pop    %ebx
  80200c:	5e                   	pop    %esi
  80200d:	5f                   	pop    %edi
  80200e:	5d                   	pop    %ebp
  80200f:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802010:	39 ce                	cmp    %ecx,%esi
  802012:	77 28                	ja     80203c <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802014:	0f bd fe             	bsr    %esi,%edi
	  if (bm == 0)
  802017:	83 f7 1f             	xor    $0x1f,%edi
  80201a:	75 40                	jne    80205c <__udivdi3+0x9c>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  80201c:	39 ce                	cmp    %ecx,%esi
  80201e:	72 0a                	jb     80202a <__udivdi3+0x6a>
  802020:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802024:	0f 87 9e 00 00 00    	ja     8020c8 <__udivdi3+0x108>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  80202a:	b8 01 00 00 00       	mov    $0x1,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80202f:	89 fa                	mov    %edi,%edx
  802031:	83 c4 1c             	add    $0x1c,%esp
  802034:	5b                   	pop    %ebx
  802035:	5e                   	pop    %esi
  802036:	5f                   	pop    %edi
  802037:	5d                   	pop    %ebp
  802038:	c3                   	ret    
  802039:	8d 76 00             	lea    0x0(%esi),%esi
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  80203c:	31 ff                	xor    %edi,%edi
  80203e:	31 c0                	xor    %eax,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802040:	89 fa                	mov    %edi,%edx
  802042:	83 c4 1c             	add    $0x1c,%esp
  802045:	5b                   	pop    %ebx
  802046:	5e                   	pop    %esi
  802047:	5f                   	pop    %edi
  802048:	5d                   	pop    %ebp
  802049:	c3                   	ret    
  80204a:	66 90                	xchg   %ax,%ax
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80204c:	89 d8                	mov    %ebx,%eax
  80204e:	f7 f7                	div    %edi
  802050:	31 ff                	xor    %edi,%edi
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802052:	89 fa                	mov    %edi,%edx
  802054:	83 c4 1c             	add    $0x1c,%esp
  802057:	5b                   	pop    %ebx
  802058:	5e                   	pop    %esi
  802059:	5f                   	pop    %edi
  80205a:	5d                   	pop    %ebp
  80205b:	c3                   	ret    
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  80205c:	bd 20 00 00 00       	mov    $0x20,%ebp
  802061:	89 eb                	mov    %ebp,%ebx
  802063:	29 fb                	sub    %edi,%ebx

	      d1 = (d1 << bm) | (d0 >> b);
  802065:	89 f9                	mov    %edi,%ecx
  802067:	d3 e6                	shl    %cl,%esi
  802069:	89 c5                	mov    %eax,%ebp
  80206b:	88 d9                	mov    %bl,%cl
  80206d:	d3 ed                	shr    %cl,%ebp
  80206f:	89 e9                	mov    %ebp,%ecx
  802071:	09 f1                	or     %esi,%ecx
  802073:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
	      d0 = d0 << bm;
  802077:	89 f9                	mov    %edi,%ecx
  802079:	d3 e0                	shl    %cl,%eax
  80207b:	89 c5                	mov    %eax,%ebp
	      n2 = n1 >> b;
  80207d:	89 d6                	mov    %edx,%esi
  80207f:	88 d9                	mov    %bl,%cl
  802081:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
  802083:	89 f9                	mov    %edi,%ecx
  802085:	d3 e2                	shl    %cl,%edx
  802087:	8b 44 24 08          	mov    0x8(%esp),%eax
  80208b:	88 d9                	mov    %bl,%cl
  80208d:	d3 e8                	shr    %cl,%eax
  80208f:	09 c2                	or     %eax,%edx
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802091:	89 d0                	mov    %edx,%eax
  802093:	89 f2                	mov    %esi,%edx
  802095:	f7 74 24 0c          	divl   0xc(%esp)
  802099:	89 d6                	mov    %edx,%esi
  80209b:	89 c3                	mov    %eax,%ebx
	      umul_ppmm (m1, m0, q0, d0);
  80209d:	f7 e5                	mul    %ebp

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80209f:	39 d6                	cmp    %edx,%esi
  8020a1:	72 19                	jb     8020bc <__udivdi3+0xfc>
  8020a3:	74 0b                	je     8020b0 <__udivdi3+0xf0>
  8020a5:	89 d8                	mov    %ebx,%eax
  8020a7:	31 ff                	xor    %edi,%edi
  8020a9:	e9 58 ff ff ff       	jmp    802006 <__udivdi3+0x46>
  8020ae:	66 90                	xchg   %ax,%ax
  8020b0:	8b 54 24 08          	mov    0x8(%esp),%edx
  8020b4:	89 f9                	mov    %edi,%ecx
  8020b6:	d3 e2                	shl    %cl,%edx
  8020b8:	39 c2                	cmp    %eax,%edx
  8020ba:	73 e9                	jae    8020a5 <__udivdi3+0xe5>
  8020bc:	8d 43 ff             	lea    -0x1(%ebx),%eax
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8020bf:	31 ff                	xor    %edi,%edi
  8020c1:	e9 40 ff ff ff       	jmp    802006 <__udivdi3+0x46>
  8020c6:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8020c8:	31 c0                	xor    %eax,%eax
  8020ca:	e9 37 ff ff ff       	jmp    802006 <__udivdi3+0x46>
  8020cf:	90                   	nop

008020d0 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  8020d0:	55                   	push   %ebp
  8020d1:	57                   	push   %edi
  8020d2:	56                   	push   %esi
  8020d3:	53                   	push   %ebx
  8020d4:	83 ec 1c             	sub    $0x1c,%esp
  8020d7:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8020db:	8b 74 24 34          	mov    0x34(%esp),%esi
  8020df:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8020e3:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8020e7:	89 44 24 0c          	mov    %eax,0xc(%esp)
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8020eb:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8020ef:	89 f3                	mov    %esi,%ebx
  const DWunion dd = {.ll = d};
  8020f1:	89 fa                	mov    %edi,%edx
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  8020f3:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  n1 = nn.s.high;
  8020f7:	89 34 24             	mov    %esi,(%esp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8020fa:	85 c0                	test   %eax,%eax
  8020fc:	75 1a                	jne    802118 <__umoddi3+0x48>
    {
      if (d0 > n1)
  8020fe:	39 f7                	cmp    %esi,%edi
  802100:	0f 86 a2 00 00 00    	jbe    8021a8 <__umoddi3+0xd8>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802106:	89 c8                	mov    %ecx,%eax
  802108:	89 f2                	mov    %esi,%edx
  80210a:	f7 f7                	div    %edi
  80210c:	89 d0                	mov    %edx,%eax

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  80210e:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802110:	83 c4 1c             	add    $0x1c,%esp
  802113:	5b                   	pop    %ebx
  802114:	5e                   	pop    %esi
  802115:	5f                   	pop    %edi
  802116:	5d                   	pop    %ebp
  802117:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802118:	39 f0                	cmp    %esi,%eax
  80211a:	0f 87 ac 00 00 00    	ja     8021cc <__umoddi3+0xfc>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802120:	0f bd e8             	bsr    %eax,%ebp
	  if (bm == 0)
  802123:	83 f5 1f             	xor    $0x1f,%ebp
  802126:	0f 84 ac 00 00 00    	je     8021d8 <__umoddi3+0x108>
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  80212c:	bf 20 00 00 00       	mov    $0x20,%edi
  802131:	29 ef                	sub    %ebp,%edi
  802133:	89 fe                	mov    %edi,%esi
  802135:	89 7c 24 0c          	mov    %edi,0xc(%esp)

	      d1 = (d1 << bm) | (d0 >> b);
  802139:	89 e9                	mov    %ebp,%ecx
  80213b:	d3 e0                	shl    %cl,%eax
  80213d:	89 d7                	mov    %edx,%edi
  80213f:	89 f1                	mov    %esi,%ecx
  802141:	d3 ef                	shr    %cl,%edi
  802143:	09 c7                	or     %eax,%edi
	      d0 = d0 << bm;
  802145:	89 e9                	mov    %ebp,%ecx
  802147:	d3 e2                	shl    %cl,%edx
  802149:	89 14 24             	mov    %edx,(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  80214c:	89 d8                	mov    %ebx,%eax
  80214e:	d3 e0                	shl    %cl,%eax
  802150:	89 c2                	mov    %eax,%edx
	      n0 = n0 << bm;
  802152:	8b 44 24 08          	mov    0x8(%esp),%eax
  802156:	d3 e0                	shl    %cl,%eax
  802158:	89 44 24 04          	mov    %eax,0x4(%esp)

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  80215c:	8b 44 24 08          	mov    0x8(%esp),%eax
  802160:	89 f1                	mov    %esi,%ecx
  802162:	d3 e8                	shr    %cl,%eax
  802164:	09 d0                	or     %edx,%eax
  802166:	d3 eb                	shr    %cl,%ebx
  802168:	89 da                	mov    %ebx,%edx
  80216a:	f7 f7                	div    %edi
  80216c:	89 d3                	mov    %edx,%ebx
	      umul_ppmm (m1, m0, q0, d0);
  80216e:	f7 24 24             	mull   (%esp)
  802171:	89 c6                	mov    %eax,%esi
  802173:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802175:	39 d3                	cmp    %edx,%ebx
  802177:	0f 82 87 00 00 00    	jb     802204 <__umoddi3+0x134>
  80217d:	0f 84 91 00 00 00    	je     802214 <__umoddi3+0x144>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  802183:	8b 54 24 04          	mov    0x4(%esp),%edx
  802187:	29 f2                	sub    %esi,%edx
  802189:	19 cb                	sbb    %ecx,%ebx
		  rr.s.low = (n1 << b) | (n0 >> bm);
  80218b:	89 d8                	mov    %ebx,%eax
  80218d:	8a 4c 24 0c          	mov    0xc(%esp),%cl
  802191:	d3 e0                	shl    %cl,%eax
  802193:	89 e9                	mov    %ebp,%ecx
  802195:	d3 ea                	shr    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  802197:	09 d0                	or     %edx,%eax
  802199:	89 e9                	mov    %ebp,%ecx
  80219b:	d3 eb                	shr    %cl,%ebx
  80219d:	89 da                	mov    %ebx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80219f:	83 c4 1c             	add    $0x1c,%esp
  8021a2:	5b                   	pop    %ebx
  8021a3:	5e                   	pop    %esi
  8021a4:	5f                   	pop    %edi
  8021a5:	5d                   	pop    %ebp
  8021a6:	c3                   	ret    
  8021a7:	90                   	nop
  8021a8:	89 fd                	mov    %edi,%ebp
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8021aa:	85 ff                	test   %edi,%edi
  8021ac:	75 0b                	jne    8021b9 <__umoddi3+0xe9>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8021ae:	b8 01 00 00 00       	mov    $0x1,%eax
  8021b3:	31 d2                	xor    %edx,%edx
  8021b5:	f7 f7                	div    %edi
  8021b7:	89 c5                	mov    %eax,%ebp

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8021b9:	89 f0                	mov    %esi,%eax
  8021bb:	31 d2                	xor    %edx,%edx
  8021bd:	f7 f5                	div    %ebp
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8021bf:	89 c8                	mov    %ecx,%eax
  8021c1:	f7 f5                	div    %ebp
  8021c3:	89 d0                	mov    %edx,%eax
  8021c5:	e9 44 ff ff ff       	jmp    80210e <__umoddi3+0x3e>
  8021ca:	66 90                	xchg   %ax,%ax
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  8021cc:	89 c8                	mov    %ecx,%eax
  8021ce:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8021d0:	83 c4 1c             	add    $0x1c,%esp
  8021d3:	5b                   	pop    %ebx
  8021d4:	5e                   	pop    %esi
  8021d5:	5f                   	pop    %edi
  8021d6:	5d                   	pop    %ebp
  8021d7:	c3                   	ret    

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8021d8:	3b 04 24             	cmp    (%esp),%eax
  8021db:	72 06                	jb     8021e3 <__umoddi3+0x113>
  8021dd:	3b 7c 24 04          	cmp    0x4(%esp),%edi
  8021e1:	77 0f                	ja     8021f2 <__umoddi3+0x122>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8021e3:	89 f2                	mov    %esi,%edx
  8021e5:	29 f9                	sub    %edi,%ecx
  8021e7:	1b 54 24 0c          	sbb    0xc(%esp),%edx
  8021eb:	89 14 24             	mov    %edx,(%esp)
  8021ee:	89 4c 24 04          	mov    %ecx,0x4(%esp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  8021f2:	8b 44 24 04          	mov    0x4(%esp),%eax
  8021f6:	8b 14 24             	mov    (%esp),%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8021f9:	83 c4 1c             	add    $0x1c,%esp
  8021fc:	5b                   	pop    %ebx
  8021fd:	5e                   	pop    %esi
  8021fe:	5f                   	pop    %edi
  8021ff:	5d                   	pop    %ebp
  802200:	c3                   	ret    
  802201:	8d 76 00             	lea    0x0(%esi),%esi
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802204:	2b 04 24             	sub    (%esp),%eax
  802207:	19 fa                	sbb    %edi,%edx
  802209:	89 d1                	mov    %edx,%ecx
  80220b:	89 c6                	mov    %eax,%esi
  80220d:	e9 71 ff ff ff       	jmp    802183 <__umoddi3+0xb3>
  802212:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802214:	39 44 24 04          	cmp    %eax,0x4(%esp)
  802218:	72 ea                	jb     802204 <__umoddi3+0x134>
  80221a:	89 d9                	mov    %ebx,%ecx
  80221c:	e9 62 ff ff ff       	jmp    802183 <__umoddi3+0xb3>
