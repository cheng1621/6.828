
obj/user/faultdie.debug:     file format elf32-i386


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
  80002c:	e8 4f 00 00 00       	call   800080 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 0c             	sub    $0xc,%esp
  800039:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void*)utf->utf_fault_va;
	uint32_t err = utf->utf_err;
	cprintf("i faulted at va %x, err %x\n", addr, err & 7);
  80003c:	8b 42 04             	mov    0x4(%edx),%eax
  80003f:	83 e0 07             	and    $0x7,%eax
  800042:	50                   	push   %eax
  800043:	ff 32                	pushl  (%edx)
  800045:	68 20 1f 80 00       	push   $0x801f20
  80004a:	e8 2c 01 00 00       	call   80017b <cprintf>
	sys_env_destroy(sys_getenvid());
  80004f:	e8 3e 0b 00 00       	call   800b92 <sys_getenvid>
  800054:	89 04 24             	mov    %eax,(%esp)
  800057:	e8 f5 0a 00 00       	call   800b51 <sys_env_destroy>
}
  80005c:	83 c4 10             	add    $0x10,%esp
  80005f:	c9                   	leave  
  800060:	c3                   	ret    

00800061 <umain>:

void
umain(int argc, char **argv)
{
  800061:	55                   	push   %ebp
  800062:	89 e5                	mov    %esp,%ebp
  800064:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(handler);
  800067:	68 33 00 80 00       	push   $0x800033
  80006c:	e8 50 0d 00 00       	call   800dc1 <set_pgfault_handler>
	*(int*)0xDeadBeef = 0;
  800071:	c7 05 ef be ad de 00 	movl   $0x0,0xdeadbeef
  800078:	00 00 00 
}
  80007b:	83 c4 10             	add    $0x10,%esp
  80007e:	c9                   	leave  
  80007f:	c3                   	ret    

00800080 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800080:	55                   	push   %ebp
  800081:	89 e5                	mov    %esp,%ebp
  800083:	56                   	push   %esi
  800084:	53                   	push   %ebx
  800085:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800088:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80008b:	e8 02 0b 00 00       	call   800b92 <sys_getenvid>
  800090:	25 ff 03 00 00       	and    $0x3ff,%eax
  800095:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80009c:	c1 e0 07             	shl    $0x7,%eax
  80009f:	29 d0                	sub    %edx,%eax
  8000a1:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000a6:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000ab:	85 db                	test   %ebx,%ebx
  8000ad:	7e 07                	jle    8000b6 <libmain+0x36>
		binaryname = argv[0];
  8000af:	8b 06                	mov    (%esi),%eax
  8000b1:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000b6:	83 ec 08             	sub    $0x8,%esp
  8000b9:	56                   	push   %esi
  8000ba:	53                   	push   %ebx
  8000bb:	e8 a1 ff ff ff       	call   800061 <umain>

	// exit gracefully
	exit();
  8000c0:	e8 0a 00 00 00       	call   8000cf <exit>
}
  8000c5:	83 c4 10             	add    $0x10,%esp
  8000c8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000cb:	5b                   	pop    %ebx
  8000cc:	5e                   	pop    %esi
  8000cd:	5d                   	pop    %ebp
  8000ce:	c3                   	ret    

008000cf <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000cf:	55                   	push   %ebp
  8000d0:	89 e5                	mov    %esp,%ebp
  8000d2:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000d5:	e8 94 0f 00 00       	call   80106e <close_all>
	sys_env_destroy(0);
  8000da:	83 ec 0c             	sub    $0xc,%esp
  8000dd:	6a 00                	push   $0x0
  8000df:	e8 6d 0a 00 00       	call   800b51 <sys_env_destroy>
}
  8000e4:	83 c4 10             	add    $0x10,%esp
  8000e7:	c9                   	leave  
  8000e8:	c3                   	ret    

008000e9 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000e9:	55                   	push   %ebp
  8000ea:	89 e5                	mov    %esp,%ebp
  8000ec:	53                   	push   %ebx
  8000ed:	83 ec 04             	sub    $0x4,%esp
  8000f0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000f3:	8b 13                	mov    (%ebx),%edx
  8000f5:	8d 42 01             	lea    0x1(%edx),%eax
  8000f8:	89 03                	mov    %eax,(%ebx)
  8000fa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000fd:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800101:	3d ff 00 00 00       	cmp    $0xff,%eax
  800106:	75 1a                	jne    800122 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800108:	83 ec 08             	sub    $0x8,%esp
  80010b:	68 ff 00 00 00       	push   $0xff
  800110:	8d 43 08             	lea    0x8(%ebx),%eax
  800113:	50                   	push   %eax
  800114:	e8 fb 09 00 00       	call   800b14 <sys_cputs>
		b->idx = 0;
  800119:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80011f:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800122:	ff 43 04             	incl   0x4(%ebx)
}
  800125:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800128:	c9                   	leave  
  800129:	c3                   	ret    

0080012a <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80012a:	55                   	push   %ebp
  80012b:	89 e5                	mov    %esp,%ebp
  80012d:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800133:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80013a:	00 00 00 
	b.cnt = 0;
  80013d:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800144:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800147:	ff 75 0c             	pushl  0xc(%ebp)
  80014a:	ff 75 08             	pushl  0x8(%ebp)
  80014d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800153:	50                   	push   %eax
  800154:	68 e9 00 80 00       	push   $0x8000e9
  800159:	e8 54 01 00 00       	call   8002b2 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80015e:	83 c4 08             	add    $0x8,%esp
  800161:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800167:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80016d:	50                   	push   %eax
  80016e:	e8 a1 09 00 00       	call   800b14 <sys_cputs>

	return b.cnt;
}
  800173:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800179:	c9                   	leave  
  80017a:	c3                   	ret    

0080017b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80017b:	55                   	push   %ebp
  80017c:	89 e5                	mov    %esp,%ebp
  80017e:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800181:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800184:	50                   	push   %eax
  800185:	ff 75 08             	pushl  0x8(%ebp)
  800188:	e8 9d ff ff ff       	call   80012a <vcprintf>
	va_end(ap);

	return cnt;
}
  80018d:	c9                   	leave  
  80018e:	c3                   	ret    

0080018f <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80018f:	55                   	push   %ebp
  800190:	89 e5                	mov    %esp,%ebp
  800192:	57                   	push   %edi
  800193:	56                   	push   %esi
  800194:	53                   	push   %ebx
  800195:	83 ec 1c             	sub    $0x1c,%esp
  800198:	89 c6                	mov    %eax,%esi
  80019a:	89 d7                	mov    %edx,%edi
  80019c:	8b 45 08             	mov    0x8(%ebp),%eax
  80019f:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001a2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001a5:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001a8:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001ab:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001b0:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001b3:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001b6:	39 d3                	cmp    %edx,%ebx
  8001b8:	72 11                	jb     8001cb <printnum+0x3c>
  8001ba:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001bd:	76 0c                	jbe    8001cb <printnum+0x3c>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001bf:	8b 45 14             	mov    0x14(%ebp),%eax
  8001c2:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001c5:	85 db                	test   %ebx,%ebx
  8001c7:	7f 37                	jg     800200 <printnum+0x71>
  8001c9:	eb 44                	jmp    80020f <printnum+0x80>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001cb:	83 ec 0c             	sub    $0xc,%esp
  8001ce:	ff 75 18             	pushl  0x18(%ebp)
  8001d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8001d4:	48                   	dec    %eax
  8001d5:	50                   	push   %eax
  8001d6:	ff 75 10             	pushl  0x10(%ebp)
  8001d9:	83 ec 08             	sub    $0x8,%esp
  8001dc:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001df:	ff 75 e0             	pushl  -0x20(%ebp)
  8001e2:	ff 75 dc             	pushl  -0x24(%ebp)
  8001e5:	ff 75 d8             	pushl  -0x28(%ebp)
  8001e8:	e8 c3 1a 00 00       	call   801cb0 <__udivdi3>
  8001ed:	83 c4 18             	add    $0x18,%esp
  8001f0:	52                   	push   %edx
  8001f1:	50                   	push   %eax
  8001f2:	89 fa                	mov    %edi,%edx
  8001f4:	89 f0                	mov    %esi,%eax
  8001f6:	e8 94 ff ff ff       	call   80018f <printnum>
  8001fb:	83 c4 20             	add    $0x20,%esp
  8001fe:	eb 0f                	jmp    80020f <printnum+0x80>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800200:	83 ec 08             	sub    $0x8,%esp
  800203:	57                   	push   %edi
  800204:	ff 75 18             	pushl  0x18(%ebp)
  800207:	ff d6                	call   *%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800209:	83 c4 10             	add    $0x10,%esp
  80020c:	4b                   	dec    %ebx
  80020d:	75 f1                	jne    800200 <printnum+0x71>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80020f:	83 ec 08             	sub    $0x8,%esp
  800212:	57                   	push   %edi
  800213:	83 ec 04             	sub    $0x4,%esp
  800216:	ff 75 e4             	pushl  -0x1c(%ebp)
  800219:	ff 75 e0             	pushl  -0x20(%ebp)
  80021c:	ff 75 dc             	pushl  -0x24(%ebp)
  80021f:	ff 75 d8             	pushl  -0x28(%ebp)
  800222:	e8 99 1b 00 00       	call   801dc0 <__umoddi3>
  800227:	83 c4 14             	add    $0x14,%esp
  80022a:	0f be 80 46 1f 80 00 	movsbl 0x801f46(%eax),%eax
  800231:	50                   	push   %eax
  800232:	ff d6                	call   *%esi
}
  800234:	83 c4 10             	add    $0x10,%esp
  800237:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80023a:	5b                   	pop    %ebx
  80023b:	5e                   	pop    %esi
  80023c:	5f                   	pop    %edi
  80023d:	5d                   	pop    %ebp
  80023e:	c3                   	ret    

0080023f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80023f:	55                   	push   %ebp
  800240:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800242:	83 fa 01             	cmp    $0x1,%edx
  800245:	7e 0e                	jle    800255 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800247:	8b 10                	mov    (%eax),%edx
  800249:	8d 4a 08             	lea    0x8(%edx),%ecx
  80024c:	89 08                	mov    %ecx,(%eax)
  80024e:	8b 02                	mov    (%edx),%eax
  800250:	8b 52 04             	mov    0x4(%edx),%edx
  800253:	eb 22                	jmp    800277 <getuint+0x38>
	else if (lflag)
  800255:	85 d2                	test   %edx,%edx
  800257:	74 10                	je     800269 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800259:	8b 10                	mov    (%eax),%edx
  80025b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80025e:	89 08                	mov    %ecx,(%eax)
  800260:	8b 02                	mov    (%edx),%eax
  800262:	ba 00 00 00 00       	mov    $0x0,%edx
  800267:	eb 0e                	jmp    800277 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800269:	8b 10                	mov    (%eax),%edx
  80026b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80026e:	89 08                	mov    %ecx,(%eax)
  800270:	8b 02                	mov    (%edx),%eax
  800272:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800277:	5d                   	pop    %ebp
  800278:	c3                   	ret    

00800279 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800279:	55                   	push   %ebp
  80027a:	89 e5                	mov    %esp,%ebp
  80027c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80027f:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800282:	8b 10                	mov    (%eax),%edx
  800284:	3b 50 04             	cmp    0x4(%eax),%edx
  800287:	73 0a                	jae    800293 <sprintputch+0x1a>
		*b->buf++ = ch;
  800289:	8d 4a 01             	lea    0x1(%edx),%ecx
  80028c:	89 08                	mov    %ecx,(%eax)
  80028e:	8b 45 08             	mov    0x8(%ebp),%eax
  800291:	88 02                	mov    %al,(%edx)
}
  800293:	5d                   	pop    %ebp
  800294:	c3                   	ret    

00800295 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800295:	55                   	push   %ebp
  800296:	89 e5                	mov    %esp,%ebp
  800298:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80029b:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80029e:	50                   	push   %eax
  80029f:	ff 75 10             	pushl  0x10(%ebp)
  8002a2:	ff 75 0c             	pushl  0xc(%ebp)
  8002a5:	ff 75 08             	pushl  0x8(%ebp)
  8002a8:	e8 05 00 00 00       	call   8002b2 <vprintfmt>
	va_end(ap);
}
  8002ad:	83 c4 10             	add    $0x10,%esp
  8002b0:	c9                   	leave  
  8002b1:	c3                   	ret    

008002b2 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002b2:	55                   	push   %ebp
  8002b3:	89 e5                	mov    %esp,%ebp
  8002b5:	57                   	push   %edi
  8002b6:	56                   	push   %esi
  8002b7:	53                   	push   %ebx
  8002b8:	83 ec 2c             	sub    $0x2c,%esp
  8002bb:	8b 7d 08             	mov    0x8(%ebp),%edi
  8002be:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002c1:	eb 03                	jmp    8002c6 <vprintfmt+0x14>
			break;

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
			for (fmt--; fmt[-1] != '%'; fmt--)
  8002c3:	89 75 10             	mov    %esi,0x10(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {    //遍历输入的第一个参数，即输出信息的格式，先把格式字符串中'%'之前的字符一个个输出，因为它们前面没有'%'，所以它们就是要直接显示在屏幕上的
  8002c6:	8b 45 10             	mov    0x10(%ebp),%eax
  8002c9:	8d 70 01             	lea    0x1(%eax),%esi
  8002cc:	0f b6 00             	movzbl (%eax),%eax
  8002cf:	83 f8 25             	cmp    $0x25,%eax
  8002d2:	74 25                	je     8002f9 <vprintfmt+0x47>
			if (ch == '\0')									//当然中间如果遇到'\0'，代表这个字符串的访问结束
  8002d4:	85 c0                	test   %eax,%eax
  8002d6:	75 0d                	jne    8002e5 <vprintfmt+0x33>
  8002d8:	e9 b5 03 00 00       	jmp    800692 <vprintfmt+0x3e0>
  8002dd:	85 c0                	test   %eax,%eax
  8002df:	0f 84 ad 03 00 00    	je     800692 <vprintfmt+0x3e0>
				return;
			putch(ch, putdat);								//调用putch函数，把一个字符ch输出到putdat指针所指向的地址中所存放的值对应的地址处
  8002e5:	83 ec 08             	sub    $0x8,%esp
  8002e8:	53                   	push   %ebx
  8002e9:	50                   	push   %eax
  8002ea:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {    //遍历输入的第一个参数，即输出信息的格式，先把格式字符串中'%'之前的字符一个个输出，因为它们前面没有'%'，所以它们就是要直接显示在屏幕上的
  8002ec:	46                   	inc    %esi
  8002ed:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  8002f1:	83 c4 10             	add    $0x10,%esp
  8002f4:	83 f8 25             	cmp    $0x25,%eax
  8002f7:	75 e4                	jne    8002dd <vprintfmt+0x2b>
			if (width < 0)									//代表有小数点，但是小数点前面并没有数字，比如'%.6f'这种情况，此时代表整数部分全部显示
				width = 0;			
			goto reswitch;

		case '#':
			altflag = 1;
  8002f9:	c6 45 e3 20          	movb   $0x20,-0x1d(%ebp)
  8002fd:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800304:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80030b:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800312:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800319:	eb 07                	jmp    800322 <vprintfmt+0x70>
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  80031b:	8b 75 10             	mov    0x10(%ebp),%esi

		// flag to pad on the right
		case '-':											//%后面的'-'代表要进行左对齐输出，右边填空格，如果省略代表右对齐
			padc = '-';										//如果有这个字符代表左对齐，则把对齐方式标志位变为'-'
  80031e:	c6 45 e3 2d          	movb   $0x2d,-0x1d(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  800322:	8d 46 01             	lea    0x1(%esi),%eax
  800325:	89 45 10             	mov    %eax,0x10(%ebp)
  800328:	0f b6 16             	movzbl (%esi),%edx
  80032b:	8a 06                	mov    (%esi),%al
  80032d:	83 e8 23             	sub    $0x23,%eax
  800330:	3c 55                	cmp    $0x55,%al
  800332:	0f 87 03 03 00 00    	ja     80063b <vprintfmt+0x389>
  800338:	0f b6 c0             	movzbl %al,%eax
  80033b:	ff 24 85 80 20 80 00 	jmp    *0x802080(,%eax,4)
  800342:	8b 75 10             	mov    0x10(%ebp),%esi
			padc = '-';										//如果有这个字符代表左对齐，则把对齐方式标志位变为'-'
			goto reswitch;									//处理下一个字符

		// flag to pad with 0's instead of spaces
		case '0':											//0--有0表示进行对齐输出时填0,如省略表示填入空格，并且如果为0，则一定是右对齐
			padc = '0';										//对其方式标志位变为0
  800345:	c6 45 e3 30          	movb   $0x30,-0x1d(%ebp)
  800349:	eb d7                	jmp    800322 <vprintfmt+0x70>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {					//把遇到的位数字符串转换为真实的位数，比如输入的'%40'，代表有效位数为40位，下面的循环就是把precesion的值设置为40
				precision = precision * 10 + ch - '0';
  80034b:	8d 42 d0             	lea    -0x30(%edx),%eax
  80034e:	89 c1                	mov    %eax,%ecx
  800350:	89 45 d0             	mov    %eax,-0x30(%ebp)
				ch = *fmt;
  800353:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  800357:	8d 50 d0             	lea    -0x30(%eax),%edx
  80035a:	83 fa 09             	cmp    $0x9,%edx
  80035d:	77 51                	ja     8003b0 <vprintfmt+0xfe>
  80035f:	8b 75 10             	mov    0x10(%ebp),%esi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {					//把遇到的位数字符串转换为真实的位数，比如输入的'%40'，代表有效位数为40位，下面的循环就是把precesion的值设置为40
  800362:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  800363:	8d 14 89             	lea    (%ecx,%ecx,4),%edx
  800366:	01 d2                	add    %edx,%edx
  800368:	8d 4c 10 d0          	lea    -0x30(%eax,%edx,1),%ecx
				ch = *fmt;
  80036c:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80036f:	8d 50 d0             	lea    -0x30(%eax),%edx
  800372:	83 fa 09             	cmp    $0x9,%edx
  800375:	76 eb                	jbe    800362 <vprintfmt+0xb0>
  800377:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  80037a:	eb 37                	jmp    8003b3 <vprintfmt+0x101>
					break;
			}
			goto process_precision;							//跳转到process_precistion子过程

		case '*':											//*--代表有效数字的位数也是由输入参数指定的，比如printf("%*.*f", 10, 2, n)，其中10,2就是用来指定显示的有效数字位数的
			precision = va_arg(ap, int);
  80037c:	8b 45 14             	mov    0x14(%ebp),%eax
  80037f:	8d 50 04             	lea    0x4(%eax),%edx
  800382:	89 55 14             	mov    %edx,0x14(%ebp)
  800385:	8b 00                	mov    (%eax),%eax
  800387:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  80038a:	8b 75 10             	mov    0x10(%ebp),%esi
			}
			goto process_precision;							//跳转到process_precistion子过程

		case '*':											//*--代表有效数字的位数也是由输入参数指定的，比如printf("%*.*f", 10, 2, n)，其中10,2就是用来指定显示的有效数字位数的
			precision = va_arg(ap, int);
			goto process_precision;
  80038d:	eb 24                	jmp    8003b3 <vprintfmt+0x101>
  80038f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800393:	79 07                	jns    80039c <vprintfmt+0xea>
  800395:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  80039c:	8b 75 10             	mov    0x10(%ebp),%esi
  80039f:	eb 81                	jmp    800322 <vprintfmt+0x70>
  8003a1:	8b 75 10             	mov    0x10(%ebp),%esi
			if (width < 0)									//代表有小数点，但是小数点前面并没有数字，比如'%.6f'这种情况，此时代表整数部分全部显示
				width = 0;			
			goto reswitch;

		case '#':
			altflag = 1;
  8003a4:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003ab:	e9 72 ff ff ff       	jmp    800322 <vprintfmt+0x70>
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  8003b0:	8b 75 10             	mov    0x10(%ebp),%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:									//处理输出精度，把width字段赋值为刚刚计算出来的precision值，所以width应该是整数部分的有效数字位数
			if (width < 0)
  8003b3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003b7:	0f 89 65 ff ff ff    	jns    800322 <vprintfmt+0x70>
				width = precision, precision = -1;
  8003bd:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003c0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003c3:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003ca:	e9 53 ff ff ff       	jmp    800322 <vprintfmt+0x70>
			goto reswitch;

		// long flag (doubled for long long)				
		case 'l':											//如果遇到'l'，代表应该是输入long类型，如果有两个'l'代表long long
			lflag++;										//此时把lflag++
  8003cf:	ff 45 d4             	incl   -0x2c(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  8003d2:	8b 75 10             	mov    0x10(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)				
		case 'l':											//如果遇到'l'，代表应该是输入long类型，如果有两个'l'代表long long
			lflag++;										//此时把lflag++
			goto reswitch;
  8003d5:	e9 48 ff ff ff       	jmp    800322 <vprintfmt+0x70>

		// character
		case 'c':											//如果是'c'代表显示一个字符
			putch(va_arg(ap, int), putdat);					//调用输出一个字符到内存的函数putch
  8003da:	8b 45 14             	mov    0x14(%ebp),%eax
  8003dd:	8d 50 04             	lea    0x4(%eax),%edx
  8003e0:	89 55 14             	mov    %edx,0x14(%ebp)
  8003e3:	83 ec 08             	sub    $0x8,%esp
  8003e6:	53                   	push   %ebx
  8003e7:	ff 30                	pushl  (%eax)
  8003e9:	ff d7                	call   *%edi
			break;
  8003eb:	83 c4 10             	add    $0x10,%esp
  8003ee:	e9 d3 fe ff ff       	jmp    8002c6 <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f6:	8d 50 04             	lea    0x4(%eax),%edx
  8003f9:	89 55 14             	mov    %edx,0x14(%ebp)
  8003fc:	8b 00                	mov    (%eax),%eax
  8003fe:	85 c0                	test   %eax,%eax
  800400:	79 02                	jns    800404 <vprintfmt+0x152>
  800402:	f7 d8                	neg    %eax
  800404:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800406:	83 f8 0f             	cmp    $0xf,%eax
  800409:	7f 0b                	jg     800416 <vprintfmt+0x164>
  80040b:	8b 04 85 e0 21 80 00 	mov    0x8021e0(,%eax,4),%eax
  800412:	85 c0                	test   %eax,%eax
  800414:	75 15                	jne    80042b <vprintfmt+0x179>
				printfmt(putch, putdat, "error %d", err);
  800416:	52                   	push   %edx
  800417:	68 5e 1f 80 00       	push   $0x801f5e
  80041c:	53                   	push   %ebx
  80041d:	57                   	push   %edi
  80041e:	e8 72 fe ff ff       	call   800295 <printfmt>
  800423:	83 c4 10             	add    $0x10,%esp
  800426:	e9 9b fe ff ff       	jmp    8002c6 <vprintfmt+0x14>
			else
				printfmt(putch, putdat, "%s", p);
  80042b:	50                   	push   %eax
  80042c:	68 23 23 80 00       	push   $0x802323
  800431:	53                   	push   %ebx
  800432:	57                   	push   %edi
  800433:	e8 5d fe ff ff       	call   800295 <printfmt>
  800438:	83 c4 10             	add    $0x10,%esp
  80043b:	e9 86 fe ff ff       	jmp    8002c6 <vprintfmt+0x14>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800440:	8b 45 14             	mov    0x14(%ebp),%eax
  800443:	8d 50 04             	lea    0x4(%eax),%edx
  800446:	89 55 14             	mov    %edx,0x14(%ebp)
  800449:	8b 00                	mov    (%eax),%eax
  80044b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80044e:	85 c0                	test   %eax,%eax
  800450:	75 07                	jne    800459 <vprintfmt+0x1a7>
				p = "(null)";
  800452:	c7 45 d4 57 1f 80 00 	movl   $0x801f57,-0x2c(%ebp)
			if (width > 0 && padc != '-')
  800459:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80045c:	85 f6                	test   %esi,%esi
  80045e:	0f 8e fb 01 00 00    	jle    80065f <vprintfmt+0x3ad>
  800464:	80 7d e3 2d          	cmpb   $0x2d,-0x1d(%ebp)
  800468:	0f 84 09 02 00 00    	je     800677 <vprintfmt+0x3c5>
				for (width -= strnlen(p, precision); width > 0; width--)
  80046e:	83 ec 08             	sub    $0x8,%esp
  800471:	ff 75 d0             	pushl  -0x30(%ebp)
  800474:	ff 75 d4             	pushl  -0x2c(%ebp)
  800477:	e8 ad 02 00 00       	call   800729 <strnlen>
  80047c:	89 f1                	mov    %esi,%ecx
  80047e:	29 c1                	sub    %eax,%ecx
  800480:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  800483:	83 c4 10             	add    $0x10,%esp
  800486:	85 c9                	test   %ecx,%ecx
  800488:	0f 8e d1 01 00 00    	jle    80065f <vprintfmt+0x3ad>
					putch(padc, putdat);
  80048e:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  800492:	83 ec 08             	sub    $0x8,%esp
  800495:	53                   	push   %ebx
  800496:	56                   	push   %esi
  800497:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800499:	83 c4 10             	add    $0x10,%esp
  80049c:	ff 4d e4             	decl   -0x1c(%ebp)
  80049f:	75 f1                	jne    800492 <vprintfmt+0x1e0>
  8004a1:	e9 b9 01 00 00       	jmp    80065f <vprintfmt+0x3ad>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004a6:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004aa:	74 19                	je     8004c5 <vprintfmt+0x213>
  8004ac:	0f be c0             	movsbl %al,%eax
  8004af:	83 e8 20             	sub    $0x20,%eax
  8004b2:	83 f8 5e             	cmp    $0x5e,%eax
  8004b5:	76 0e                	jbe    8004c5 <vprintfmt+0x213>
					putch('?', putdat);
  8004b7:	83 ec 08             	sub    $0x8,%esp
  8004ba:	53                   	push   %ebx
  8004bb:	6a 3f                	push   $0x3f
  8004bd:	ff 55 08             	call   *0x8(%ebp)
  8004c0:	83 c4 10             	add    $0x10,%esp
  8004c3:	eb 0b                	jmp    8004d0 <vprintfmt+0x21e>
				else
					putch(ch, putdat);
  8004c5:	83 ec 08             	sub    $0x8,%esp
  8004c8:	53                   	push   %ebx
  8004c9:	52                   	push   %edx
  8004ca:	ff 55 08             	call   *0x8(%ebp)
  8004cd:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004d0:	ff 4d e4             	decl   -0x1c(%ebp)
  8004d3:	46                   	inc    %esi
  8004d4:	8a 46 ff             	mov    -0x1(%esi),%al
  8004d7:	0f be d0             	movsbl %al,%edx
  8004da:	85 d2                	test   %edx,%edx
  8004dc:	75 1c                	jne    8004fa <vprintfmt+0x248>
  8004de:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004e1:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004e5:	7f 1f                	jg     800506 <vprintfmt+0x254>
  8004e7:	e9 da fd ff ff       	jmp    8002c6 <vprintfmt+0x14>
  8004ec:	89 7d 08             	mov    %edi,0x8(%ebp)
  8004ef:	8b 7d d0             	mov    -0x30(%ebp),%edi
  8004f2:	eb 06                	jmp    8004fa <vprintfmt+0x248>
  8004f4:	89 7d 08             	mov    %edi,0x8(%ebp)
  8004f7:	8b 7d d0             	mov    -0x30(%ebp),%edi
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004fa:	85 ff                	test   %edi,%edi
  8004fc:	78 a8                	js     8004a6 <vprintfmt+0x1f4>
  8004fe:	4f                   	dec    %edi
  8004ff:	79 a5                	jns    8004a6 <vprintfmt+0x1f4>
  800501:	8b 7d 08             	mov    0x8(%ebp),%edi
  800504:	eb db                	jmp    8004e1 <vprintfmt+0x22f>
  800506:	8b 75 e4             	mov    -0x1c(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800509:	83 ec 08             	sub    $0x8,%esp
  80050c:	53                   	push   %ebx
  80050d:	6a 20                	push   $0x20
  80050f:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800511:	4e                   	dec    %esi
  800512:	83 c4 10             	add    $0x10,%esp
  800515:	85 f6                	test   %esi,%esi
  800517:	7f f0                	jg     800509 <vprintfmt+0x257>
  800519:	e9 a8 fd ff ff       	jmp    8002c6 <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80051e:	83 7d d4 01          	cmpl   $0x1,-0x2c(%ebp)
  800522:	7e 16                	jle    80053a <vprintfmt+0x288>
		return va_arg(*ap, long long);
  800524:	8b 45 14             	mov    0x14(%ebp),%eax
  800527:	8d 50 08             	lea    0x8(%eax),%edx
  80052a:	89 55 14             	mov    %edx,0x14(%ebp)
  80052d:	8b 50 04             	mov    0x4(%eax),%edx
  800530:	8b 00                	mov    (%eax),%eax
  800532:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800535:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800538:	eb 34                	jmp    80056e <vprintfmt+0x2bc>
	else if (lflag)
  80053a:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80053e:	74 18                	je     800558 <vprintfmt+0x2a6>
		return va_arg(*ap, long);
  800540:	8b 45 14             	mov    0x14(%ebp),%eax
  800543:	8d 50 04             	lea    0x4(%eax),%edx
  800546:	89 55 14             	mov    %edx,0x14(%ebp)
  800549:	8b 30                	mov    (%eax),%esi
  80054b:	89 75 d8             	mov    %esi,-0x28(%ebp)
  80054e:	89 f0                	mov    %esi,%eax
  800550:	c1 f8 1f             	sar    $0x1f,%eax
  800553:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800556:	eb 16                	jmp    80056e <vprintfmt+0x2bc>
	else
		return va_arg(*ap, int);
  800558:	8b 45 14             	mov    0x14(%ebp),%eax
  80055b:	8d 50 04             	lea    0x4(%eax),%edx
  80055e:	89 55 14             	mov    %edx,0x14(%ebp)
  800561:	8b 30                	mov    (%eax),%esi
  800563:	89 75 d8             	mov    %esi,-0x28(%ebp)
  800566:	89 f0                	mov    %esi,%eax
  800568:	c1 f8 1f             	sar    $0x1f,%eax
  80056b:	89 45 dc             	mov    %eax,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80056e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800571:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
  800574:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800578:	0f 89 8a 00 00 00    	jns    800608 <vprintfmt+0x356>
				putch('-', putdat);
  80057e:	83 ec 08             	sub    $0x8,%esp
  800581:	53                   	push   %ebx
  800582:	6a 2d                	push   $0x2d
  800584:	ff d7                	call   *%edi
				num = -(long long) num;
  800586:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800589:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80058c:	f7 d8                	neg    %eax
  80058e:	83 d2 00             	adc    $0x0,%edx
  800591:	f7 da                	neg    %edx
  800593:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800596:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80059b:	eb 70                	jmp    80060d <vprintfmt+0x35b>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80059d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8005a0:	8d 45 14             	lea    0x14(%ebp),%eax
  8005a3:	e8 97 fc ff ff       	call   80023f <getuint>
			base = 10;
  8005a8:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8005ad:	eb 5e                	jmp    80060d <vprintfmt+0x35b>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
  8005af:	83 ec 08             	sub    $0x8,%esp
  8005b2:	53                   	push   %ebx
  8005b3:	6a 30                	push   $0x30
  8005b5:	ff d7                	call   *%edi
			num = getuint(&ap, lflag);
  8005b7:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8005ba:	8d 45 14             	lea    0x14(%ebp),%eax
  8005bd:	e8 7d fc ff ff       	call   80023f <getuint>
			base = 8;
			goto number;
  8005c2:	83 c4 10             	add    $0x10,%esp
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  8005c5:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8005ca:	eb 41                	jmp    80060d <vprintfmt+0x35b>
		// pointer
		case 'p':
			putch('0', putdat);
  8005cc:	83 ec 08             	sub    $0x8,%esp
  8005cf:	53                   	push   %ebx
  8005d0:	6a 30                	push   $0x30
  8005d2:	ff d7                	call   *%edi
			putch('x', putdat);
  8005d4:	83 c4 08             	add    $0x8,%esp
  8005d7:	53                   	push   %ebx
  8005d8:	6a 78                	push   $0x78
  8005da:	ff d7                	call   *%edi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8005df:	8d 50 04             	lea    0x4(%eax),%edx
  8005e2:	89 55 14             	mov    %edx,0x14(%ebp)
			goto number;
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005e5:	8b 00                	mov    (%eax),%eax
  8005e7:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8005ec:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8005ef:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8005f4:	eb 17                	jmp    80060d <vprintfmt+0x35b>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8005f6:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8005f9:	8d 45 14             	lea    0x14(%ebp),%eax
  8005fc:	e8 3e fc ff ff       	call   80023f <getuint>
			base = 16;
  800601:	b9 10 00 00 00       	mov    $0x10,%ecx
  800606:	eb 05                	jmp    80060d <vprintfmt+0x35b>
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800608:	b9 0a 00 00 00       	mov    $0xa,%ecx
		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  80060d:	83 ec 0c             	sub    $0xc,%esp
  800610:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  800614:	56                   	push   %esi
  800615:	ff 75 e4             	pushl  -0x1c(%ebp)
  800618:	51                   	push   %ecx
  800619:	52                   	push   %edx
  80061a:	50                   	push   %eax
  80061b:	89 da                	mov    %ebx,%edx
  80061d:	89 f8                	mov    %edi,%eax
  80061f:	e8 6b fb ff ff       	call   80018f <printnum>
			break;
  800624:	83 c4 20             	add    $0x20,%esp
  800627:	e9 9a fc ff ff       	jmp    8002c6 <vprintfmt+0x14>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80062c:	83 ec 08             	sub    $0x8,%esp
  80062f:	53                   	push   %ebx
  800630:	52                   	push   %edx
  800631:	ff d7                	call   *%edi
			break;
  800633:	83 c4 10             	add    $0x10,%esp
  800636:	e9 8b fc ff ff       	jmp    8002c6 <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80063b:	83 ec 08             	sub    $0x8,%esp
  80063e:	53                   	push   %ebx
  80063f:	6a 25                	push   $0x25
  800641:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800643:	83 c4 10             	add    $0x10,%esp
  800646:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80064a:	0f 84 73 fc ff ff    	je     8002c3 <vprintfmt+0x11>
  800650:	4e                   	dec    %esi
  800651:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800655:	75 f9                	jne    800650 <vprintfmt+0x39e>
  800657:	89 75 10             	mov    %esi,0x10(%ebp)
  80065a:	e9 67 fc ff ff       	jmp    8002c6 <vprintfmt+0x14>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80065f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800662:	8d 70 01             	lea    0x1(%eax),%esi
  800665:	8a 00                	mov    (%eax),%al
  800667:	0f be d0             	movsbl %al,%edx
  80066a:	85 d2                	test   %edx,%edx
  80066c:	0f 85 7a fe ff ff    	jne    8004ec <vprintfmt+0x23a>
  800672:	e9 4f fc ff ff       	jmp    8002c6 <vprintfmt+0x14>
  800677:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80067a:	8d 70 01             	lea    0x1(%eax),%esi
  80067d:	8a 00                	mov    (%eax),%al
  80067f:	0f be d0             	movsbl %al,%edx
  800682:	85 d2                	test   %edx,%edx
  800684:	0f 85 6a fe ff ff    	jne    8004f4 <vprintfmt+0x242>
  80068a:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80068d:	e9 77 fe ff ff       	jmp    800509 <vprintfmt+0x257>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800692:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800695:	5b                   	pop    %ebx
  800696:	5e                   	pop    %esi
  800697:	5f                   	pop    %edi
  800698:	5d                   	pop    %ebp
  800699:	c3                   	ret    

0080069a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80069a:	55                   	push   %ebp
  80069b:	89 e5                	mov    %esp,%ebp
  80069d:	83 ec 18             	sub    $0x18,%esp
  8006a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8006a3:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006a6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006a9:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006ad:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006b0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006b7:	85 c0                	test   %eax,%eax
  8006b9:	74 26                	je     8006e1 <vsnprintf+0x47>
  8006bb:	85 d2                	test   %edx,%edx
  8006bd:	7e 29                	jle    8006e8 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006bf:	ff 75 14             	pushl  0x14(%ebp)
  8006c2:	ff 75 10             	pushl  0x10(%ebp)
  8006c5:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006c8:	50                   	push   %eax
  8006c9:	68 79 02 80 00       	push   $0x800279
  8006ce:	e8 df fb ff ff       	call   8002b2 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006d3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006d6:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006dc:	83 c4 10             	add    $0x10,%esp
  8006df:	eb 0c                	jmp    8006ed <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006e1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006e6:	eb 05                	jmp    8006ed <vsnprintf+0x53>
  8006e8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006ed:	c9                   	leave  
  8006ee:	c3                   	ret    

008006ef <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006ef:	55                   	push   %ebp
  8006f0:	89 e5                	mov    %esp,%ebp
  8006f2:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006f5:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006f8:	50                   	push   %eax
  8006f9:	ff 75 10             	pushl  0x10(%ebp)
  8006fc:	ff 75 0c             	pushl  0xc(%ebp)
  8006ff:	ff 75 08             	pushl  0x8(%ebp)
  800702:	e8 93 ff ff ff       	call   80069a <vsnprintf>
	va_end(ap);

	return rc;
}
  800707:	c9                   	leave  
  800708:	c3                   	ret    

00800709 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800709:	55                   	push   %ebp
  80070a:	89 e5                	mov    %esp,%ebp
  80070c:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80070f:	80 3a 00             	cmpb   $0x0,(%edx)
  800712:	74 0e                	je     800722 <strlen+0x19>
  800714:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800719:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80071a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80071e:	75 f9                	jne    800719 <strlen+0x10>
  800720:	eb 05                	jmp    800727 <strlen+0x1e>
  800722:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800727:	5d                   	pop    %ebp
  800728:	c3                   	ret    

00800729 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800729:	55                   	push   %ebp
  80072a:	89 e5                	mov    %esp,%ebp
  80072c:	53                   	push   %ebx
  80072d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800730:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800733:	85 c9                	test   %ecx,%ecx
  800735:	74 1a                	je     800751 <strnlen+0x28>
  800737:	80 3b 00             	cmpb   $0x0,(%ebx)
  80073a:	74 1c                	je     800758 <strnlen+0x2f>
  80073c:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  800741:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800743:	39 ca                	cmp    %ecx,%edx
  800745:	74 16                	je     80075d <strnlen+0x34>
  800747:	42                   	inc    %edx
  800748:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  80074d:	75 f2                	jne    800741 <strnlen+0x18>
  80074f:	eb 0c                	jmp    80075d <strnlen+0x34>
  800751:	b8 00 00 00 00       	mov    $0x0,%eax
  800756:	eb 05                	jmp    80075d <strnlen+0x34>
  800758:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  80075d:	5b                   	pop    %ebx
  80075e:	5d                   	pop    %ebp
  80075f:	c3                   	ret    

00800760 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800760:	55                   	push   %ebp
  800761:	89 e5                	mov    %esp,%ebp
  800763:	53                   	push   %ebx
  800764:	8b 45 08             	mov    0x8(%ebp),%eax
  800767:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80076a:	89 c2                	mov    %eax,%edx
  80076c:	42                   	inc    %edx
  80076d:	41                   	inc    %ecx
  80076e:	8a 59 ff             	mov    -0x1(%ecx),%bl
  800771:	88 5a ff             	mov    %bl,-0x1(%edx)
  800774:	84 db                	test   %bl,%bl
  800776:	75 f4                	jne    80076c <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800778:	5b                   	pop    %ebx
  800779:	5d                   	pop    %ebp
  80077a:	c3                   	ret    

0080077b <strcat>:

char *
strcat(char *dst, const char *src)
{
  80077b:	55                   	push   %ebp
  80077c:	89 e5                	mov    %esp,%ebp
  80077e:	53                   	push   %ebx
  80077f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800782:	53                   	push   %ebx
  800783:	e8 81 ff ff ff       	call   800709 <strlen>
  800788:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80078b:	ff 75 0c             	pushl  0xc(%ebp)
  80078e:	01 d8                	add    %ebx,%eax
  800790:	50                   	push   %eax
  800791:	e8 ca ff ff ff       	call   800760 <strcpy>
	return dst;
}
  800796:	89 d8                	mov    %ebx,%eax
  800798:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80079b:	c9                   	leave  
  80079c:	c3                   	ret    

0080079d <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80079d:	55                   	push   %ebp
  80079e:	89 e5                	mov    %esp,%ebp
  8007a0:	56                   	push   %esi
  8007a1:	53                   	push   %ebx
  8007a2:	8b 75 08             	mov    0x8(%ebp),%esi
  8007a5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007a8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007ab:	85 db                	test   %ebx,%ebx
  8007ad:	74 14                	je     8007c3 <strncpy+0x26>
  8007af:	01 f3                	add    %esi,%ebx
  8007b1:	89 f1                	mov    %esi,%ecx
		*dst++ = *src;
  8007b3:	41                   	inc    %ecx
  8007b4:	8a 02                	mov    (%edx),%al
  8007b6:	88 41 ff             	mov    %al,-0x1(%ecx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007b9:	80 3a 01             	cmpb   $0x1,(%edx)
  8007bc:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007bf:	39 cb                	cmp    %ecx,%ebx
  8007c1:	75 f0                	jne    8007b3 <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007c3:	89 f0                	mov    %esi,%eax
  8007c5:	5b                   	pop    %ebx
  8007c6:	5e                   	pop    %esi
  8007c7:	5d                   	pop    %ebp
  8007c8:	c3                   	ret    

008007c9 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007c9:	55                   	push   %ebp
  8007ca:	89 e5                	mov    %esp,%ebp
  8007cc:	53                   	push   %ebx
  8007cd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007d0:	8b 45 10             	mov    0x10(%ebp),%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007d3:	85 c0                	test   %eax,%eax
  8007d5:	74 30                	je     800807 <strlcpy+0x3e>
		while (--size > 0 && *src != '\0')
  8007d7:	48                   	dec    %eax
  8007d8:	74 20                	je     8007fa <strlcpy+0x31>
  8007da:	8a 0b                	mov    (%ebx),%cl
  8007dc:	84 c9                	test   %cl,%cl
  8007de:	74 1f                	je     8007ff <strlcpy+0x36>
  8007e0:	8d 53 01             	lea    0x1(%ebx),%edx
  8007e3:	01 c3                	add    %eax,%ebx
  8007e5:	8b 45 08             	mov    0x8(%ebp),%eax
			*dst++ = *src++;
  8007e8:	40                   	inc    %eax
  8007e9:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007ec:	39 da                	cmp    %ebx,%edx
  8007ee:	74 12                	je     800802 <strlcpy+0x39>
  8007f0:	42                   	inc    %edx
  8007f1:	8a 4a ff             	mov    -0x1(%edx),%cl
  8007f4:	84 c9                	test   %cl,%cl
  8007f6:	75 f0                	jne    8007e8 <strlcpy+0x1f>
  8007f8:	eb 08                	jmp    800802 <strlcpy+0x39>
  8007fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8007fd:	eb 03                	jmp    800802 <strlcpy+0x39>
  8007ff:	8b 45 08             	mov    0x8(%ebp),%eax
			*dst++ = *src++;
		*dst = '\0';
  800802:	c6 00 00             	movb   $0x0,(%eax)
  800805:	eb 03                	jmp    80080a <strlcpy+0x41>
  800807:	8b 45 08             	mov    0x8(%ebp),%eax
	}
	return dst - dst_in;
  80080a:	2b 45 08             	sub    0x8(%ebp),%eax
}
  80080d:	5b                   	pop    %ebx
  80080e:	5d                   	pop    %ebp
  80080f:	c3                   	ret    

00800810 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800810:	55                   	push   %ebp
  800811:	89 e5                	mov    %esp,%ebp
  800813:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800816:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800819:	8a 01                	mov    (%ecx),%al
  80081b:	84 c0                	test   %al,%al
  80081d:	74 10                	je     80082f <strcmp+0x1f>
  80081f:	3a 02                	cmp    (%edx),%al
  800821:	75 0c                	jne    80082f <strcmp+0x1f>
		p++, q++;
  800823:	41                   	inc    %ecx
  800824:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800825:	8a 01                	mov    (%ecx),%al
  800827:	84 c0                	test   %al,%al
  800829:	74 04                	je     80082f <strcmp+0x1f>
  80082b:	3a 02                	cmp    (%edx),%al
  80082d:	74 f4                	je     800823 <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80082f:	0f b6 c0             	movzbl %al,%eax
  800832:	0f b6 12             	movzbl (%edx),%edx
  800835:	29 d0                	sub    %edx,%eax
}
  800837:	5d                   	pop    %ebp
  800838:	c3                   	ret    

00800839 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800839:	55                   	push   %ebp
  80083a:	89 e5                	mov    %esp,%ebp
  80083c:	56                   	push   %esi
  80083d:	53                   	push   %ebx
  80083e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800841:	8b 55 0c             	mov    0xc(%ebp),%edx
  800844:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  800847:	85 f6                	test   %esi,%esi
  800849:	74 23                	je     80086e <strncmp+0x35>
  80084b:	8a 03                	mov    (%ebx),%al
  80084d:	84 c0                	test   %al,%al
  80084f:	74 2b                	je     80087c <strncmp+0x43>
  800851:	3a 02                	cmp    (%edx),%al
  800853:	75 27                	jne    80087c <strncmp+0x43>
  800855:	8d 43 01             	lea    0x1(%ebx),%eax
  800858:	01 de                	add    %ebx,%esi
		n--, p++, q++;
  80085a:	89 c3                	mov    %eax,%ebx
  80085c:	42                   	inc    %edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80085d:	39 c6                	cmp    %eax,%esi
  80085f:	74 14                	je     800875 <strncmp+0x3c>
  800861:	8a 08                	mov    (%eax),%cl
  800863:	84 c9                	test   %cl,%cl
  800865:	74 15                	je     80087c <strncmp+0x43>
  800867:	40                   	inc    %eax
  800868:	3a 0a                	cmp    (%edx),%cl
  80086a:	74 ee                	je     80085a <strncmp+0x21>
  80086c:	eb 0e                	jmp    80087c <strncmp+0x43>
		n--, p++, q++;
	if (n == 0)
		return 0;
  80086e:	b8 00 00 00 00       	mov    $0x0,%eax
  800873:	eb 0f                	jmp    800884 <strncmp+0x4b>
  800875:	b8 00 00 00 00       	mov    $0x0,%eax
  80087a:	eb 08                	jmp    800884 <strncmp+0x4b>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80087c:	0f b6 03             	movzbl (%ebx),%eax
  80087f:	0f b6 12             	movzbl (%edx),%edx
  800882:	29 d0                	sub    %edx,%eax
}
  800884:	5b                   	pop    %ebx
  800885:	5e                   	pop    %esi
  800886:	5d                   	pop    %ebp
  800887:	c3                   	ret    

00800888 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800888:	55                   	push   %ebp
  800889:	89 e5                	mov    %esp,%ebp
  80088b:	53                   	push   %ebx
  80088c:	8b 45 08             	mov    0x8(%ebp),%eax
  80088f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  800892:	8a 10                	mov    (%eax),%dl
  800894:	84 d2                	test   %dl,%dl
  800896:	74 1a                	je     8008b2 <strchr+0x2a>
  800898:	88 d9                	mov    %bl,%cl
		if (*s == c)
  80089a:	38 d3                	cmp    %dl,%bl
  80089c:	75 06                	jne    8008a4 <strchr+0x1c>
  80089e:	eb 17                	jmp    8008b7 <strchr+0x2f>
  8008a0:	38 ca                	cmp    %cl,%dl
  8008a2:	74 13                	je     8008b7 <strchr+0x2f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008a4:	40                   	inc    %eax
  8008a5:	8a 10                	mov    (%eax),%dl
  8008a7:	84 d2                	test   %dl,%dl
  8008a9:	75 f5                	jne    8008a0 <strchr+0x18>
		if (*s == c)
			return (char *) s;
	return 0;
  8008ab:	b8 00 00 00 00       	mov    $0x0,%eax
  8008b0:	eb 05                	jmp    8008b7 <strchr+0x2f>
  8008b2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008b7:	5b                   	pop    %ebx
  8008b8:	5d                   	pop    %ebp
  8008b9:	c3                   	ret    

008008ba <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008ba:	55                   	push   %ebp
  8008bb:	89 e5                	mov    %esp,%ebp
  8008bd:	53                   	push   %ebx
  8008be:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  8008c4:	8a 10                	mov    (%eax),%dl
  8008c6:	84 d2                	test   %dl,%dl
  8008c8:	74 13                	je     8008dd <strfind+0x23>
  8008ca:	88 d9                	mov    %bl,%cl
		if (*s == c)
  8008cc:	38 d3                	cmp    %dl,%bl
  8008ce:	75 06                	jne    8008d6 <strfind+0x1c>
  8008d0:	eb 0b                	jmp    8008dd <strfind+0x23>
  8008d2:	38 ca                	cmp    %cl,%dl
  8008d4:	74 07                	je     8008dd <strfind+0x23>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8008d6:	40                   	inc    %eax
  8008d7:	8a 10                	mov    (%eax),%dl
  8008d9:	84 d2                	test   %dl,%dl
  8008db:	75 f5                	jne    8008d2 <strfind+0x18>
		if (*s == c)
			break;
	return (char *) s;
}
  8008dd:	5b                   	pop    %ebx
  8008de:	5d                   	pop    %ebp
  8008df:	c3                   	ret    

008008e0 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008e0:	55                   	push   %ebp
  8008e1:	89 e5                	mov    %esp,%ebp
  8008e3:	57                   	push   %edi
  8008e4:	56                   	push   %esi
  8008e5:	53                   	push   %ebx
  8008e6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008e9:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008ec:	85 c9                	test   %ecx,%ecx
  8008ee:	74 36                	je     800926 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008f0:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008f6:	75 28                	jne    800920 <memset+0x40>
  8008f8:	f6 c1 03             	test   $0x3,%cl
  8008fb:	75 23                	jne    800920 <memset+0x40>
		c &= 0xFF;
  8008fd:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800901:	89 d3                	mov    %edx,%ebx
  800903:	c1 e3 08             	shl    $0x8,%ebx
  800906:	89 d6                	mov    %edx,%esi
  800908:	c1 e6 18             	shl    $0x18,%esi
  80090b:	89 d0                	mov    %edx,%eax
  80090d:	c1 e0 10             	shl    $0x10,%eax
  800910:	09 f0                	or     %esi,%eax
  800912:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800914:	89 d8                	mov    %ebx,%eax
  800916:	09 d0                	or     %edx,%eax
  800918:	c1 e9 02             	shr    $0x2,%ecx
  80091b:	fc                   	cld    
  80091c:	f3 ab                	rep stos %eax,%es:(%edi)
  80091e:	eb 06                	jmp    800926 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800920:	8b 45 0c             	mov    0xc(%ebp),%eax
  800923:	fc                   	cld    
  800924:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800926:	89 f8                	mov    %edi,%eax
  800928:	5b                   	pop    %ebx
  800929:	5e                   	pop    %esi
  80092a:	5f                   	pop    %edi
  80092b:	5d                   	pop    %ebp
  80092c:	c3                   	ret    

0080092d <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80092d:	55                   	push   %ebp
  80092e:	89 e5                	mov    %esp,%ebp
  800930:	57                   	push   %edi
  800931:	56                   	push   %esi
  800932:	8b 45 08             	mov    0x8(%ebp),%eax
  800935:	8b 75 0c             	mov    0xc(%ebp),%esi
  800938:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80093b:	39 c6                	cmp    %eax,%esi
  80093d:	73 33                	jae    800972 <memmove+0x45>
  80093f:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800942:	39 d0                	cmp    %edx,%eax
  800944:	73 2c                	jae    800972 <memmove+0x45>
		s += n;
		d += n;
  800946:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800949:	89 d6                	mov    %edx,%esi
  80094b:	09 fe                	or     %edi,%esi
  80094d:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800953:	75 13                	jne    800968 <memmove+0x3b>
  800955:	f6 c1 03             	test   $0x3,%cl
  800958:	75 0e                	jne    800968 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  80095a:	83 ef 04             	sub    $0x4,%edi
  80095d:	8d 72 fc             	lea    -0x4(%edx),%esi
  800960:	c1 e9 02             	shr    $0x2,%ecx
  800963:	fd                   	std    
  800964:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800966:	eb 07                	jmp    80096f <memmove+0x42>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800968:	4f                   	dec    %edi
  800969:	8d 72 ff             	lea    -0x1(%edx),%esi
  80096c:	fd                   	std    
  80096d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80096f:	fc                   	cld    
  800970:	eb 1d                	jmp    80098f <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800972:	89 f2                	mov    %esi,%edx
  800974:	09 c2                	or     %eax,%edx
  800976:	f6 c2 03             	test   $0x3,%dl
  800979:	75 0f                	jne    80098a <memmove+0x5d>
  80097b:	f6 c1 03             	test   $0x3,%cl
  80097e:	75 0a                	jne    80098a <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
  800980:	c1 e9 02             	shr    $0x2,%ecx
  800983:	89 c7                	mov    %eax,%edi
  800985:	fc                   	cld    
  800986:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800988:	eb 05                	jmp    80098f <memmove+0x62>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80098a:	89 c7                	mov    %eax,%edi
  80098c:	fc                   	cld    
  80098d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80098f:	5e                   	pop    %esi
  800990:	5f                   	pop    %edi
  800991:	5d                   	pop    %ebp
  800992:	c3                   	ret    

00800993 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800993:	55                   	push   %ebp
  800994:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800996:	ff 75 10             	pushl  0x10(%ebp)
  800999:	ff 75 0c             	pushl  0xc(%ebp)
  80099c:	ff 75 08             	pushl  0x8(%ebp)
  80099f:	e8 89 ff ff ff       	call   80092d <memmove>
}
  8009a4:	c9                   	leave  
  8009a5:	c3                   	ret    

008009a6 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009a6:	55                   	push   %ebp
  8009a7:	89 e5                	mov    %esp,%ebp
  8009a9:	57                   	push   %edi
  8009aa:	56                   	push   %esi
  8009ab:	53                   	push   %ebx
  8009ac:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8009af:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009b2:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009b5:	85 c0                	test   %eax,%eax
  8009b7:	74 33                	je     8009ec <memcmp+0x46>
  8009b9:	8d 78 ff             	lea    -0x1(%eax),%edi
		if (*s1 != *s2)
  8009bc:	8a 13                	mov    (%ebx),%dl
  8009be:	8a 0e                	mov    (%esi),%cl
  8009c0:	38 ca                	cmp    %cl,%dl
  8009c2:	75 13                	jne    8009d7 <memcmp+0x31>
  8009c4:	b8 00 00 00 00       	mov    $0x0,%eax
  8009c9:	eb 16                	jmp    8009e1 <memcmp+0x3b>
  8009cb:	8a 54 03 01          	mov    0x1(%ebx,%eax,1),%dl
  8009cf:	40                   	inc    %eax
  8009d0:	8a 0c 06             	mov    (%esi,%eax,1),%cl
  8009d3:	38 ca                	cmp    %cl,%dl
  8009d5:	74 0a                	je     8009e1 <memcmp+0x3b>
			return (int) *s1 - (int) *s2;
  8009d7:	0f b6 c2             	movzbl %dl,%eax
  8009da:	0f b6 c9             	movzbl %cl,%ecx
  8009dd:	29 c8                	sub    %ecx,%eax
  8009df:	eb 10                	jmp    8009f1 <memcmp+0x4b>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009e1:	39 f8                	cmp    %edi,%eax
  8009e3:	75 e6                	jne    8009cb <memcmp+0x25>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009e5:	b8 00 00 00 00       	mov    $0x0,%eax
  8009ea:	eb 05                	jmp    8009f1 <memcmp+0x4b>
  8009ec:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009f1:	5b                   	pop    %ebx
  8009f2:	5e                   	pop    %esi
  8009f3:	5f                   	pop    %edi
  8009f4:	5d                   	pop    %ebp
  8009f5:	c3                   	ret    

008009f6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009f6:	55                   	push   %ebp
  8009f7:	89 e5                	mov    %esp,%ebp
  8009f9:	53                   	push   %ebx
  8009fa:	8b 55 08             	mov    0x8(%ebp),%edx
	const void *ends = (const char *) s + n;
  8009fd:	89 d0                	mov    %edx,%eax
  8009ff:	03 45 10             	add    0x10(%ebp),%eax
	for (; s < ends; s++)
  800a02:	39 c2                	cmp    %eax,%edx
  800a04:	73 1b                	jae    800a21 <memfind+0x2b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a06:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
  800a0a:	0f b6 0a             	movzbl (%edx),%ecx
  800a0d:	39 d9                	cmp    %ebx,%ecx
  800a0f:	75 09                	jne    800a1a <memfind+0x24>
  800a11:	eb 12                	jmp    800a25 <memfind+0x2f>
  800a13:	0f b6 0a             	movzbl (%edx),%ecx
  800a16:	39 d9                	cmp    %ebx,%ecx
  800a18:	74 0f                	je     800a29 <memfind+0x33>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a1a:	42                   	inc    %edx
  800a1b:	39 d0                	cmp    %edx,%eax
  800a1d:	75 f4                	jne    800a13 <memfind+0x1d>
  800a1f:	eb 0a                	jmp    800a2b <memfind+0x35>
  800a21:	89 d0                	mov    %edx,%eax
  800a23:	eb 06                	jmp    800a2b <memfind+0x35>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a25:	89 d0                	mov    %edx,%eax
  800a27:	eb 02                	jmp    800a2b <memfind+0x35>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a29:	89 d0                	mov    %edx,%eax
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a2b:	5b                   	pop    %ebx
  800a2c:	5d                   	pop    %ebp
  800a2d:	c3                   	ret    

00800a2e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a2e:	55                   	push   %ebp
  800a2f:	89 e5                	mov    %esp,%ebp
  800a31:	57                   	push   %edi
  800a32:	56                   	push   %esi
  800a33:	53                   	push   %ebx
  800a34:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a37:	eb 01                	jmp    800a3a <strtol+0xc>
		s++;
  800a39:	41                   	inc    %ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a3a:	8a 01                	mov    (%ecx),%al
  800a3c:	3c 20                	cmp    $0x20,%al
  800a3e:	74 f9                	je     800a39 <strtol+0xb>
  800a40:	3c 09                	cmp    $0x9,%al
  800a42:	74 f5                	je     800a39 <strtol+0xb>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a44:	3c 2b                	cmp    $0x2b,%al
  800a46:	75 08                	jne    800a50 <strtol+0x22>
		s++;
  800a48:	41                   	inc    %ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a49:	bf 00 00 00 00       	mov    $0x0,%edi
  800a4e:	eb 11                	jmp    800a61 <strtol+0x33>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a50:	3c 2d                	cmp    $0x2d,%al
  800a52:	75 08                	jne    800a5c <strtol+0x2e>
		s++, neg = 1;
  800a54:	41                   	inc    %ecx
  800a55:	bf 01 00 00 00       	mov    $0x1,%edi
  800a5a:	eb 05                	jmp    800a61 <strtol+0x33>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a5c:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a61:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800a65:	0f 84 87 00 00 00    	je     800af2 <strtol+0xc4>
  800a6b:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  800a6f:	75 27                	jne    800a98 <strtol+0x6a>
  800a71:	80 39 30             	cmpb   $0x30,(%ecx)
  800a74:	75 22                	jne    800a98 <strtol+0x6a>
  800a76:	e9 88 00 00 00       	jmp    800b03 <strtol+0xd5>
		s += 2, base = 16;
  800a7b:	83 c1 02             	add    $0x2,%ecx
  800a7e:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  800a85:	eb 11                	jmp    800a98 <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
  800a87:	41                   	inc    %ecx
  800a88:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  800a8f:	eb 07                	jmp    800a98 <strtol+0x6a>
	else if (base == 0)
		base = 10;
  800a91:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)
  800a98:	b8 00 00 00 00       	mov    $0x0,%eax

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a9d:	8a 11                	mov    (%ecx),%dl
  800a9f:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800aa2:	80 fb 09             	cmp    $0x9,%bl
  800aa5:	77 08                	ja     800aaf <strtol+0x81>
			dig = *s - '0';
  800aa7:	0f be d2             	movsbl %dl,%edx
  800aaa:	83 ea 30             	sub    $0x30,%edx
  800aad:	eb 22                	jmp    800ad1 <strtol+0xa3>
		else if (*s >= 'a' && *s <= 'z')
  800aaf:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ab2:	89 f3                	mov    %esi,%ebx
  800ab4:	80 fb 19             	cmp    $0x19,%bl
  800ab7:	77 08                	ja     800ac1 <strtol+0x93>
			dig = *s - 'a' + 10;
  800ab9:	0f be d2             	movsbl %dl,%edx
  800abc:	83 ea 57             	sub    $0x57,%edx
  800abf:	eb 10                	jmp    800ad1 <strtol+0xa3>
		else if (*s >= 'A' && *s <= 'Z')
  800ac1:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ac4:	89 f3                	mov    %esi,%ebx
  800ac6:	80 fb 19             	cmp    $0x19,%bl
  800ac9:	77 14                	ja     800adf <strtol+0xb1>
			dig = *s - 'A' + 10;
  800acb:	0f be d2             	movsbl %dl,%edx
  800ace:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800ad1:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ad4:	7d 09                	jge    800adf <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800ad6:	41                   	inc    %ecx
  800ad7:	0f af 45 10          	imul   0x10(%ebp),%eax
  800adb:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800add:	eb be                	jmp    800a9d <strtol+0x6f>

	if (endptr)
  800adf:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ae3:	74 05                	je     800aea <strtol+0xbc>
		*endptr = (char *) s;
  800ae5:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ae8:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800aea:	85 ff                	test   %edi,%edi
  800aec:	74 21                	je     800b0f <strtol+0xe1>
  800aee:	f7 d8                	neg    %eax
  800af0:	eb 1d                	jmp    800b0f <strtol+0xe1>
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800af2:	80 39 30             	cmpb   $0x30,(%ecx)
  800af5:	75 9a                	jne    800a91 <strtol+0x63>
  800af7:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800afb:	0f 84 7a ff ff ff    	je     800a7b <strtol+0x4d>
  800b01:	eb 84                	jmp    800a87 <strtol+0x59>
  800b03:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b07:	0f 84 6e ff ff ff    	je     800a7b <strtol+0x4d>
  800b0d:	eb 89                	jmp    800a98 <strtol+0x6a>
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
}
  800b0f:	5b                   	pop    %ebx
  800b10:	5e                   	pop    %esi
  800b11:	5f                   	pop    %edi
  800b12:	5d                   	pop    %ebp
  800b13:	c3                   	ret    

00800b14 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b14:	55                   	push   %ebp
  800b15:	89 e5                	mov    %esp,%ebp
  800b17:	57                   	push   %edi
  800b18:	56                   	push   %esi
  800b19:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b1a:	b8 00 00 00 00       	mov    $0x0,%eax
  800b1f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b22:	8b 55 08             	mov    0x8(%ebp),%edx
  800b25:	89 c3                	mov    %eax,%ebx
  800b27:	89 c7                	mov    %eax,%edi
  800b29:	89 c6                	mov    %eax,%esi
  800b2b:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b2d:	5b                   	pop    %ebx
  800b2e:	5e                   	pop    %esi
  800b2f:	5f                   	pop    %edi
  800b30:	5d                   	pop    %ebp
  800b31:	c3                   	ret    

00800b32 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b32:	55                   	push   %ebp
  800b33:	89 e5                	mov    %esp,%ebp
  800b35:	57                   	push   %edi
  800b36:	56                   	push   %esi
  800b37:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b38:	ba 00 00 00 00       	mov    $0x0,%edx
  800b3d:	b8 01 00 00 00       	mov    $0x1,%eax
  800b42:	89 d1                	mov    %edx,%ecx
  800b44:	89 d3                	mov    %edx,%ebx
  800b46:	89 d7                	mov    %edx,%edi
  800b48:	89 d6                	mov    %edx,%esi
  800b4a:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b4c:	5b                   	pop    %ebx
  800b4d:	5e                   	pop    %esi
  800b4e:	5f                   	pop    %edi
  800b4f:	5d                   	pop    %ebp
  800b50:	c3                   	ret    

00800b51 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b51:	55                   	push   %ebp
  800b52:	89 e5                	mov    %esp,%ebp
  800b54:	57                   	push   %edi
  800b55:	56                   	push   %esi
  800b56:	53                   	push   %ebx
  800b57:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b5a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b5f:	b8 03 00 00 00       	mov    $0x3,%eax
  800b64:	8b 55 08             	mov    0x8(%ebp),%edx
  800b67:	89 cb                	mov    %ecx,%ebx
  800b69:	89 cf                	mov    %ecx,%edi
  800b6b:	89 ce                	mov    %ecx,%esi
  800b6d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b6f:	85 c0                	test   %eax,%eax
  800b71:	7e 17                	jle    800b8a <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b73:	83 ec 0c             	sub    $0xc,%esp
  800b76:	50                   	push   %eax
  800b77:	6a 03                	push   $0x3
  800b79:	68 3f 22 80 00       	push   $0x80223f
  800b7e:	6a 23                	push   $0x23
  800b80:	68 5c 22 80 00       	push   $0x80225c
  800b85:	e8 6d 0f 00 00       	call   801af7 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b8a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b8d:	5b                   	pop    %ebx
  800b8e:	5e                   	pop    %esi
  800b8f:	5f                   	pop    %edi
  800b90:	5d                   	pop    %ebp
  800b91:	c3                   	ret    

00800b92 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b92:	55                   	push   %ebp
  800b93:	89 e5                	mov    %esp,%ebp
  800b95:	57                   	push   %edi
  800b96:	56                   	push   %esi
  800b97:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b98:	ba 00 00 00 00       	mov    $0x0,%edx
  800b9d:	b8 02 00 00 00       	mov    $0x2,%eax
  800ba2:	89 d1                	mov    %edx,%ecx
  800ba4:	89 d3                	mov    %edx,%ebx
  800ba6:	89 d7                	mov    %edx,%edi
  800ba8:	89 d6                	mov    %edx,%esi
  800baa:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bac:	5b                   	pop    %ebx
  800bad:	5e                   	pop    %esi
  800bae:	5f                   	pop    %edi
  800baf:	5d                   	pop    %ebp
  800bb0:	c3                   	ret    

00800bb1 <sys_yield>:

void
sys_yield(void)
{
  800bb1:	55                   	push   %ebp
  800bb2:	89 e5                	mov    %esp,%ebp
  800bb4:	57                   	push   %edi
  800bb5:	56                   	push   %esi
  800bb6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bb7:	ba 00 00 00 00       	mov    $0x0,%edx
  800bbc:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bc1:	89 d1                	mov    %edx,%ecx
  800bc3:	89 d3                	mov    %edx,%ebx
  800bc5:	89 d7                	mov    %edx,%edi
  800bc7:	89 d6                	mov    %edx,%esi
  800bc9:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bcb:	5b                   	pop    %ebx
  800bcc:	5e                   	pop    %esi
  800bcd:	5f                   	pop    %edi
  800bce:	5d                   	pop    %ebp
  800bcf:	c3                   	ret    

00800bd0 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bd0:	55                   	push   %ebp
  800bd1:	89 e5                	mov    %esp,%ebp
  800bd3:	57                   	push   %edi
  800bd4:	56                   	push   %esi
  800bd5:	53                   	push   %ebx
  800bd6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bd9:	be 00 00 00 00       	mov    $0x0,%esi
  800bde:	b8 04 00 00 00       	mov    $0x4,%eax
  800be3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800be6:	8b 55 08             	mov    0x8(%ebp),%edx
  800be9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bec:	89 f7                	mov    %esi,%edi
  800bee:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bf0:	85 c0                	test   %eax,%eax
  800bf2:	7e 17                	jle    800c0b <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bf4:	83 ec 0c             	sub    $0xc,%esp
  800bf7:	50                   	push   %eax
  800bf8:	6a 04                	push   $0x4
  800bfa:	68 3f 22 80 00       	push   $0x80223f
  800bff:	6a 23                	push   $0x23
  800c01:	68 5c 22 80 00       	push   $0x80225c
  800c06:	e8 ec 0e 00 00       	call   801af7 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c0b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c0e:	5b                   	pop    %ebx
  800c0f:	5e                   	pop    %esi
  800c10:	5f                   	pop    %edi
  800c11:	5d                   	pop    %ebp
  800c12:	c3                   	ret    

00800c13 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c13:	55                   	push   %ebp
  800c14:	89 e5                	mov    %esp,%ebp
  800c16:	57                   	push   %edi
  800c17:	56                   	push   %esi
  800c18:	53                   	push   %ebx
  800c19:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c1c:	b8 05 00 00 00       	mov    $0x5,%eax
  800c21:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c24:	8b 55 08             	mov    0x8(%ebp),%edx
  800c27:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c2a:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c2d:	8b 75 18             	mov    0x18(%ebp),%esi
  800c30:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c32:	85 c0                	test   %eax,%eax
  800c34:	7e 17                	jle    800c4d <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c36:	83 ec 0c             	sub    $0xc,%esp
  800c39:	50                   	push   %eax
  800c3a:	6a 05                	push   $0x5
  800c3c:	68 3f 22 80 00       	push   $0x80223f
  800c41:	6a 23                	push   $0x23
  800c43:	68 5c 22 80 00       	push   $0x80225c
  800c48:	e8 aa 0e 00 00       	call   801af7 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c4d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c50:	5b                   	pop    %ebx
  800c51:	5e                   	pop    %esi
  800c52:	5f                   	pop    %edi
  800c53:	5d                   	pop    %ebp
  800c54:	c3                   	ret    

00800c55 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c55:	55                   	push   %ebp
  800c56:	89 e5                	mov    %esp,%ebp
  800c58:	57                   	push   %edi
  800c59:	56                   	push   %esi
  800c5a:	53                   	push   %ebx
  800c5b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c5e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c63:	b8 06 00 00 00       	mov    $0x6,%eax
  800c68:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c6b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c6e:	89 df                	mov    %ebx,%edi
  800c70:	89 de                	mov    %ebx,%esi
  800c72:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c74:	85 c0                	test   %eax,%eax
  800c76:	7e 17                	jle    800c8f <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c78:	83 ec 0c             	sub    $0xc,%esp
  800c7b:	50                   	push   %eax
  800c7c:	6a 06                	push   $0x6
  800c7e:	68 3f 22 80 00       	push   $0x80223f
  800c83:	6a 23                	push   $0x23
  800c85:	68 5c 22 80 00       	push   $0x80225c
  800c8a:	e8 68 0e 00 00       	call   801af7 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c8f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c92:	5b                   	pop    %ebx
  800c93:	5e                   	pop    %esi
  800c94:	5f                   	pop    %edi
  800c95:	5d                   	pop    %ebp
  800c96:	c3                   	ret    

00800c97 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
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
  800ca0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ca5:	b8 08 00 00 00       	mov    $0x8,%eax
  800caa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cad:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb0:	89 df                	mov    %ebx,%edi
  800cb2:	89 de                	mov    %ebx,%esi
  800cb4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cb6:	85 c0                	test   %eax,%eax
  800cb8:	7e 17                	jle    800cd1 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cba:	83 ec 0c             	sub    $0xc,%esp
  800cbd:	50                   	push   %eax
  800cbe:	6a 08                	push   $0x8
  800cc0:	68 3f 22 80 00       	push   $0x80223f
  800cc5:	6a 23                	push   $0x23
  800cc7:	68 5c 22 80 00       	push   $0x80225c
  800ccc:	e8 26 0e 00 00       	call   801af7 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cd1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cd4:	5b                   	pop    %ebx
  800cd5:	5e                   	pop    %esi
  800cd6:	5f                   	pop    %edi
  800cd7:	5d                   	pop    %ebp
  800cd8:	c3                   	ret    

00800cd9 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800cd9:	55                   	push   %ebp
  800cda:	89 e5                	mov    %esp,%ebp
  800cdc:	57                   	push   %edi
  800cdd:	56                   	push   %esi
  800cde:	53                   	push   %ebx
  800cdf:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce2:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ce7:	b8 09 00 00 00       	mov    $0x9,%eax
  800cec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cef:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf2:	89 df                	mov    %ebx,%edi
  800cf4:	89 de                	mov    %ebx,%esi
  800cf6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cf8:	85 c0                	test   %eax,%eax
  800cfa:	7e 17                	jle    800d13 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cfc:	83 ec 0c             	sub    $0xc,%esp
  800cff:	50                   	push   %eax
  800d00:	6a 09                	push   $0x9
  800d02:	68 3f 22 80 00       	push   $0x80223f
  800d07:	6a 23                	push   $0x23
  800d09:	68 5c 22 80 00       	push   $0x80225c
  800d0e:	e8 e4 0d 00 00       	call   801af7 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d13:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d16:	5b                   	pop    %ebx
  800d17:	5e                   	pop    %esi
  800d18:	5f                   	pop    %edi
  800d19:	5d                   	pop    %ebp
  800d1a:	c3                   	ret    

00800d1b <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d1b:	55                   	push   %ebp
  800d1c:	89 e5                	mov    %esp,%ebp
  800d1e:	57                   	push   %edi
  800d1f:	56                   	push   %esi
  800d20:	53                   	push   %ebx
  800d21:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d24:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d29:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d2e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d31:	8b 55 08             	mov    0x8(%ebp),%edx
  800d34:	89 df                	mov    %ebx,%edi
  800d36:	89 de                	mov    %ebx,%esi
  800d38:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d3a:	85 c0                	test   %eax,%eax
  800d3c:	7e 17                	jle    800d55 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d3e:	83 ec 0c             	sub    $0xc,%esp
  800d41:	50                   	push   %eax
  800d42:	6a 0a                	push   $0xa
  800d44:	68 3f 22 80 00       	push   $0x80223f
  800d49:	6a 23                	push   $0x23
  800d4b:	68 5c 22 80 00       	push   $0x80225c
  800d50:	e8 a2 0d 00 00       	call   801af7 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d55:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d58:	5b                   	pop    %ebx
  800d59:	5e                   	pop    %esi
  800d5a:	5f                   	pop    %edi
  800d5b:	5d                   	pop    %ebp
  800d5c:	c3                   	ret    

00800d5d <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d5d:	55                   	push   %ebp
  800d5e:	89 e5                	mov    %esp,%ebp
  800d60:	57                   	push   %edi
  800d61:	56                   	push   %esi
  800d62:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d63:	be 00 00 00 00       	mov    $0x0,%esi
  800d68:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d6d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d70:	8b 55 08             	mov    0x8(%ebp),%edx
  800d73:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d76:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d79:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d7b:	5b                   	pop    %ebx
  800d7c:	5e                   	pop    %esi
  800d7d:	5f                   	pop    %edi
  800d7e:	5d                   	pop    %ebp
  800d7f:	c3                   	ret    

00800d80 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d80:	55                   	push   %ebp
  800d81:	89 e5                	mov    %esp,%ebp
  800d83:	57                   	push   %edi
  800d84:	56                   	push   %esi
  800d85:	53                   	push   %ebx
  800d86:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d89:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d8e:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d93:	8b 55 08             	mov    0x8(%ebp),%edx
  800d96:	89 cb                	mov    %ecx,%ebx
  800d98:	89 cf                	mov    %ecx,%edi
  800d9a:	89 ce                	mov    %ecx,%esi
  800d9c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d9e:	85 c0                	test   %eax,%eax
  800da0:	7e 17                	jle    800db9 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800da2:	83 ec 0c             	sub    $0xc,%esp
  800da5:	50                   	push   %eax
  800da6:	6a 0d                	push   $0xd
  800da8:	68 3f 22 80 00       	push   $0x80223f
  800dad:	6a 23                	push   $0x23
  800daf:	68 5c 22 80 00       	push   $0x80225c
  800db4:	e8 3e 0d 00 00       	call   801af7 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800db9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dbc:	5b                   	pop    %ebx
  800dbd:	5e                   	pop    %esi
  800dbe:	5f                   	pop    %edi
  800dbf:	5d                   	pop    %ebp
  800dc0:	c3                   	ret    

00800dc1 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800dc1:	55                   	push   %ebp
  800dc2:	89 e5                	mov    %esp,%ebp
  800dc4:	53                   	push   %ebx
  800dc5:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (_pgfault_handler == 0) {
  800dc8:	83 3d 08 40 80 00 00 	cmpl   $0x0,0x804008
  800dcf:	75 5b                	jne    800e2c <set_pgfault_handler+0x6b>
		// First time through!
		// LAB 4: Your code here.
		void *va = (void *)(UXSTACKTOP - PGSIZE);
		envid_t eid = sys_getenvid();
  800dd1:	e8 bc fd ff ff       	call   800b92 <sys_getenvid>
  800dd6:	89 c3                	mov    %eax,%ebx
		r = sys_page_alloc(eid,va,PTE_P | PTE_U | PTE_W);
  800dd8:	83 ec 04             	sub    $0x4,%esp
  800ddb:	6a 07                	push   $0x7
  800ddd:	68 00 f0 bf ee       	push   $0xeebff000
  800de2:	50                   	push   %eax
  800de3:	e8 e8 fd ff ff       	call   800bd0 <sys_page_alloc>
		if(r<0) panic("set_pgfault_handler\n");
  800de8:	83 c4 10             	add    $0x10,%esp
  800deb:	85 c0                	test   %eax,%eax
  800ded:	79 14                	jns    800e03 <set_pgfault_handler+0x42>
  800def:	83 ec 04             	sub    $0x4,%esp
  800df2:	68 6a 22 80 00       	push   $0x80226a
  800df7:	6a 23                	push   $0x23
  800df9:	68 7f 22 80 00       	push   $0x80227f
  800dfe:	e8 f4 0c 00 00       	call   801af7 <_panic>
		r = sys_env_set_pgfault_upcall(eid,_pgfault_upcall);
  800e03:	83 ec 08             	sub    $0x8,%esp
  800e06:	68 39 0e 80 00       	push   $0x800e39
  800e0b:	53                   	push   %ebx
  800e0c:	e8 0a ff ff ff       	call   800d1b <sys_env_set_pgfault_upcall>
		if(r<0) panic("set_pgfault_handler\n");
  800e11:	83 c4 10             	add    $0x10,%esp
  800e14:	85 c0                	test   %eax,%eax
  800e16:	79 14                	jns    800e2c <set_pgfault_handler+0x6b>
  800e18:	83 ec 04             	sub    $0x4,%esp
  800e1b:	68 6a 22 80 00       	push   $0x80226a
  800e20:	6a 25                	push   $0x25
  800e22:	68 7f 22 80 00       	push   $0x80227f
  800e27:	e8 cb 0c 00 00       	call   801af7 <_panic>
		// panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800e2c:	8b 45 08             	mov    0x8(%ebp),%eax
  800e2f:	a3 08 40 80 00       	mov    %eax,0x804008
}
  800e34:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e37:	c9                   	leave  
  800e38:	c3                   	ret    

00800e39 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800e39:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800e3a:	a1 08 40 80 00       	mov    0x804008,%eax
	call *%eax
  800e3f:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800e41:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl %esp,%ebx
  800e44:	89 e3                	mov    %esp,%ebx
	movl 40(%esp),%eax 	// esp from utf_fault_va to utf_regs(end)
  800e46:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl 48(%esp),%esp 	// 
  800e4a:	8b 64 24 30          	mov    0x30(%esp),%esp
	pushl %eax
  800e4e:	50                   	push   %eax
 
 
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	movl %ebx,%esp
  800e4f:	89 dc                	mov    %ebx,%esp
	subl $4,48(%esp)
  800e51:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	popl %eax
  800e56:	58                   	pop    %eax
	popl %eax
  800e57:	58                   	pop    %eax
	popal
  800e58:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	add $4,%esp
  800e59:	83 c4 04             	add    $0x4,%esp
	popfl
  800e5c:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  800e5d:	5c                   	pop    %esp
 
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  800e5e:	c3                   	ret    

00800e5f <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e5f:	55                   	push   %ebp
  800e60:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e62:	8b 45 08             	mov    0x8(%ebp),%eax
  800e65:	05 00 00 00 30       	add    $0x30000000,%eax
  800e6a:	c1 e8 0c             	shr    $0xc,%eax
}
  800e6d:	5d                   	pop    %ebp
  800e6e:	c3                   	ret    

00800e6f <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e6f:	55                   	push   %ebp
  800e70:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800e72:	8b 45 08             	mov    0x8(%ebp),%eax
  800e75:	05 00 00 00 30       	add    $0x30000000,%eax
  800e7a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e7f:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800e84:	5d                   	pop    %ebp
  800e85:	c3                   	ret    

00800e86 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e86:	55                   	push   %ebp
  800e87:	89 e5                	mov    %esp,%ebp
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e89:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  800e8e:	a8 01                	test   $0x1,%al
  800e90:	74 34                	je     800ec6 <fd_alloc+0x40>
  800e92:	a1 00 00 74 ef       	mov    0xef740000,%eax
  800e97:	a8 01                	test   $0x1,%al
  800e99:	74 32                	je     800ecd <fd_alloc+0x47>
  800e9b:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800ea0:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800ea2:	89 c2                	mov    %eax,%edx
  800ea4:	c1 ea 16             	shr    $0x16,%edx
  800ea7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800eae:	f6 c2 01             	test   $0x1,%dl
  800eb1:	74 1f                	je     800ed2 <fd_alloc+0x4c>
  800eb3:	89 c2                	mov    %eax,%edx
  800eb5:	c1 ea 0c             	shr    $0xc,%edx
  800eb8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ebf:	f6 c2 01             	test   $0x1,%dl
  800ec2:	75 1a                	jne    800ede <fd_alloc+0x58>
  800ec4:	eb 0c                	jmp    800ed2 <fd_alloc+0x4c>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800ec6:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  800ecb:	eb 05                	jmp    800ed2 <fd_alloc+0x4c>
  800ecd:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  800ed2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ed5:	89 08                	mov    %ecx,(%eax)
			return 0;
  800ed7:	b8 00 00 00 00       	mov    $0x0,%eax
  800edc:	eb 1a                	jmp    800ef8 <fd_alloc+0x72>
  800ede:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800ee3:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800ee8:	75 b6                	jne    800ea0 <fd_alloc+0x1a>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800eea:	8b 45 08             	mov    0x8(%ebp),%eax
  800eed:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  800ef3:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800ef8:	5d                   	pop    %ebp
  800ef9:	c3                   	ret    

00800efa <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800efa:	55                   	push   %ebp
  800efb:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800efd:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
  800f01:	77 39                	ja     800f3c <fd_lookup+0x42>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800f03:	8b 45 08             	mov    0x8(%ebp),%eax
  800f06:	c1 e0 0c             	shl    $0xc,%eax
  800f09:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800f0e:	89 c2                	mov    %eax,%edx
  800f10:	c1 ea 16             	shr    $0x16,%edx
  800f13:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f1a:	f6 c2 01             	test   $0x1,%dl
  800f1d:	74 24                	je     800f43 <fd_lookup+0x49>
  800f1f:	89 c2                	mov    %eax,%edx
  800f21:	c1 ea 0c             	shr    $0xc,%edx
  800f24:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f2b:	f6 c2 01             	test   $0x1,%dl
  800f2e:	74 1a                	je     800f4a <fd_lookup+0x50>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800f30:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f33:	89 02                	mov    %eax,(%edx)
	return 0;
  800f35:	b8 00 00 00 00       	mov    $0x0,%eax
  800f3a:	eb 13                	jmp    800f4f <fd_lookup+0x55>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f3c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f41:	eb 0c                	jmp    800f4f <fd_lookup+0x55>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f43:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f48:	eb 05                	jmp    800f4f <fd_lookup+0x55>
  800f4a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800f4f:	5d                   	pop    %ebp
  800f50:	c3                   	ret    

00800f51 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f51:	55                   	push   %ebp
  800f52:	89 e5                	mov    %esp,%ebp
  800f54:	53                   	push   %ebx
  800f55:	83 ec 04             	sub    $0x4,%esp
  800f58:	8b 45 08             	mov    0x8(%ebp),%eax
  800f5b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  800f5e:	3b 05 04 30 80 00    	cmp    0x803004,%eax
  800f64:	75 1e                	jne    800f84 <dev_lookup+0x33>
  800f66:	eb 0e                	jmp    800f76 <dev_lookup+0x25>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f68:	b8 20 30 80 00       	mov    $0x803020,%eax
  800f6d:	eb 0c                	jmp    800f7b <dev_lookup+0x2a>
  800f6f:	b8 3c 30 80 00       	mov    $0x80303c,%eax
  800f74:	eb 05                	jmp    800f7b <dev_lookup+0x2a>
  800f76:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  800f7b:	89 03                	mov    %eax,(%ebx)
			return 0;
  800f7d:	b8 00 00 00 00       	mov    $0x0,%eax
  800f82:	eb 36                	jmp    800fba <dev_lookup+0x69>
int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  800f84:	3b 05 20 30 80 00    	cmp    0x803020,%eax
  800f8a:	74 dc                	je     800f68 <dev_lookup+0x17>
  800f8c:	3b 05 3c 30 80 00    	cmp    0x80303c,%eax
  800f92:	74 db                	je     800f6f <dev_lookup+0x1e>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f94:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800f9a:	8b 52 48             	mov    0x48(%edx),%edx
  800f9d:	83 ec 04             	sub    $0x4,%esp
  800fa0:	50                   	push   %eax
  800fa1:	52                   	push   %edx
  800fa2:	68 90 22 80 00       	push   $0x802290
  800fa7:	e8 cf f1 ff ff       	call   80017b <cprintf>
	*dev = 0;
  800fac:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  800fb2:	83 c4 10             	add    $0x10,%esp
  800fb5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800fba:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fbd:	c9                   	leave  
  800fbe:	c3                   	ret    

00800fbf <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800fbf:	55                   	push   %ebp
  800fc0:	89 e5                	mov    %esp,%ebp
  800fc2:	56                   	push   %esi
  800fc3:	53                   	push   %ebx
  800fc4:	83 ec 10             	sub    $0x10,%esp
  800fc7:	8b 75 08             	mov    0x8(%ebp),%esi
  800fca:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800fcd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fd0:	50                   	push   %eax
  800fd1:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800fd7:	c1 e8 0c             	shr    $0xc,%eax
  800fda:	50                   	push   %eax
  800fdb:	e8 1a ff ff ff       	call   800efa <fd_lookup>
  800fe0:	83 c4 08             	add    $0x8,%esp
  800fe3:	85 c0                	test   %eax,%eax
  800fe5:	78 05                	js     800fec <fd_close+0x2d>
	    || fd != fd2)
  800fe7:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800fea:	74 06                	je     800ff2 <fd_close+0x33>
		return (must_exist ? r : 0);
  800fec:	84 db                	test   %bl,%bl
  800fee:	74 47                	je     801037 <fd_close+0x78>
  800ff0:	eb 4a                	jmp    80103c <fd_close+0x7d>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800ff2:	83 ec 08             	sub    $0x8,%esp
  800ff5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800ff8:	50                   	push   %eax
  800ff9:	ff 36                	pushl  (%esi)
  800ffb:	e8 51 ff ff ff       	call   800f51 <dev_lookup>
  801000:	89 c3                	mov    %eax,%ebx
  801002:	83 c4 10             	add    $0x10,%esp
  801005:	85 c0                	test   %eax,%eax
  801007:	78 1c                	js     801025 <fd_close+0x66>
		if (dev->dev_close)
  801009:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80100c:	8b 40 10             	mov    0x10(%eax),%eax
  80100f:	85 c0                	test   %eax,%eax
  801011:	74 0d                	je     801020 <fd_close+0x61>
			r = (*dev->dev_close)(fd);
  801013:	83 ec 0c             	sub    $0xc,%esp
  801016:	56                   	push   %esi
  801017:	ff d0                	call   *%eax
  801019:	89 c3                	mov    %eax,%ebx
  80101b:	83 c4 10             	add    $0x10,%esp
  80101e:	eb 05                	jmp    801025 <fd_close+0x66>
		else
			r = 0;
  801020:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801025:	83 ec 08             	sub    $0x8,%esp
  801028:	56                   	push   %esi
  801029:	6a 00                	push   $0x0
  80102b:	e8 25 fc ff ff       	call   800c55 <sys_page_unmap>
	return r;
  801030:	83 c4 10             	add    $0x10,%esp
  801033:	89 d8                	mov    %ebx,%eax
  801035:	eb 05                	jmp    80103c <fd_close+0x7d>
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
  801037:	b8 00 00 00 00       	mov    $0x0,%eax
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
	return r;
}
  80103c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80103f:	5b                   	pop    %ebx
  801040:	5e                   	pop    %esi
  801041:	5d                   	pop    %ebp
  801042:	c3                   	ret    

00801043 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801043:	55                   	push   %ebp
  801044:	89 e5                	mov    %esp,%ebp
  801046:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801049:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80104c:	50                   	push   %eax
  80104d:	ff 75 08             	pushl  0x8(%ebp)
  801050:	e8 a5 fe ff ff       	call   800efa <fd_lookup>
  801055:	83 c4 08             	add    $0x8,%esp
  801058:	85 c0                	test   %eax,%eax
  80105a:	78 10                	js     80106c <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80105c:	83 ec 08             	sub    $0x8,%esp
  80105f:	6a 01                	push   $0x1
  801061:	ff 75 f4             	pushl  -0xc(%ebp)
  801064:	e8 56 ff ff ff       	call   800fbf <fd_close>
  801069:	83 c4 10             	add    $0x10,%esp
}
  80106c:	c9                   	leave  
  80106d:	c3                   	ret    

0080106e <close_all>:

void
close_all(void)
{
  80106e:	55                   	push   %ebp
  80106f:	89 e5                	mov    %esp,%ebp
  801071:	53                   	push   %ebx
  801072:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801075:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80107a:	83 ec 0c             	sub    $0xc,%esp
  80107d:	53                   	push   %ebx
  80107e:	e8 c0 ff ff ff       	call   801043 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801083:	43                   	inc    %ebx
  801084:	83 c4 10             	add    $0x10,%esp
  801087:	83 fb 20             	cmp    $0x20,%ebx
  80108a:	75 ee                	jne    80107a <close_all+0xc>
		close(i);
}
  80108c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80108f:	c9                   	leave  
  801090:	c3                   	ret    

00801091 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801091:	55                   	push   %ebp
  801092:	89 e5                	mov    %esp,%ebp
  801094:	57                   	push   %edi
  801095:	56                   	push   %esi
  801096:	53                   	push   %ebx
  801097:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80109a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80109d:	50                   	push   %eax
  80109e:	ff 75 08             	pushl  0x8(%ebp)
  8010a1:	e8 54 fe ff ff       	call   800efa <fd_lookup>
  8010a6:	83 c4 08             	add    $0x8,%esp
  8010a9:	85 c0                	test   %eax,%eax
  8010ab:	0f 88 c2 00 00 00    	js     801173 <dup+0xe2>
		return r;
	close(newfdnum);
  8010b1:	83 ec 0c             	sub    $0xc,%esp
  8010b4:	ff 75 0c             	pushl  0xc(%ebp)
  8010b7:	e8 87 ff ff ff       	call   801043 <close>

	newfd = INDEX2FD(newfdnum);
  8010bc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8010bf:	c1 e3 0c             	shl    $0xc,%ebx
  8010c2:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8010c8:	83 c4 04             	add    $0x4,%esp
  8010cb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010ce:	e8 9c fd ff ff       	call   800e6f <fd2data>
  8010d3:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  8010d5:	89 1c 24             	mov    %ebx,(%esp)
  8010d8:	e8 92 fd ff ff       	call   800e6f <fd2data>
  8010dd:	83 c4 10             	add    $0x10,%esp
  8010e0:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8010e2:	89 f0                	mov    %esi,%eax
  8010e4:	c1 e8 16             	shr    $0x16,%eax
  8010e7:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010ee:	a8 01                	test   $0x1,%al
  8010f0:	74 35                	je     801127 <dup+0x96>
  8010f2:	89 f0                	mov    %esi,%eax
  8010f4:	c1 e8 0c             	shr    $0xc,%eax
  8010f7:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010fe:	f6 c2 01             	test   $0x1,%dl
  801101:	74 24                	je     801127 <dup+0x96>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801103:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80110a:	83 ec 0c             	sub    $0xc,%esp
  80110d:	25 07 0e 00 00       	and    $0xe07,%eax
  801112:	50                   	push   %eax
  801113:	57                   	push   %edi
  801114:	6a 00                	push   $0x0
  801116:	56                   	push   %esi
  801117:	6a 00                	push   $0x0
  801119:	e8 f5 fa ff ff       	call   800c13 <sys_page_map>
  80111e:	89 c6                	mov    %eax,%esi
  801120:	83 c4 20             	add    $0x20,%esp
  801123:	85 c0                	test   %eax,%eax
  801125:	78 2c                	js     801153 <dup+0xc2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801127:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80112a:	89 d0                	mov    %edx,%eax
  80112c:	c1 e8 0c             	shr    $0xc,%eax
  80112f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801136:	83 ec 0c             	sub    $0xc,%esp
  801139:	25 07 0e 00 00       	and    $0xe07,%eax
  80113e:	50                   	push   %eax
  80113f:	53                   	push   %ebx
  801140:	6a 00                	push   $0x0
  801142:	52                   	push   %edx
  801143:	6a 00                	push   $0x0
  801145:	e8 c9 fa ff ff       	call   800c13 <sys_page_map>
  80114a:	89 c6                	mov    %eax,%esi
  80114c:	83 c4 20             	add    $0x20,%esp
  80114f:	85 c0                	test   %eax,%eax
  801151:	79 1d                	jns    801170 <dup+0xdf>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801153:	83 ec 08             	sub    $0x8,%esp
  801156:	53                   	push   %ebx
  801157:	6a 00                	push   $0x0
  801159:	e8 f7 fa ff ff       	call   800c55 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80115e:	83 c4 08             	add    $0x8,%esp
  801161:	57                   	push   %edi
  801162:	6a 00                	push   $0x0
  801164:	e8 ec fa ff ff       	call   800c55 <sys_page_unmap>
	return r;
  801169:	83 c4 10             	add    $0x10,%esp
  80116c:	89 f0                	mov    %esi,%eax
  80116e:	eb 03                	jmp    801173 <dup+0xe2>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801170:	8b 45 0c             	mov    0xc(%ebp),%eax

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801173:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801176:	5b                   	pop    %ebx
  801177:	5e                   	pop    %esi
  801178:	5f                   	pop    %edi
  801179:	5d                   	pop    %ebp
  80117a:	c3                   	ret    

0080117b <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80117b:	55                   	push   %ebp
  80117c:	89 e5                	mov    %esp,%ebp
  80117e:	53                   	push   %ebx
  80117f:	83 ec 14             	sub    $0x14,%esp
  801182:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801185:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801188:	50                   	push   %eax
  801189:	53                   	push   %ebx
  80118a:	e8 6b fd ff ff       	call   800efa <fd_lookup>
  80118f:	83 c4 08             	add    $0x8,%esp
  801192:	85 c0                	test   %eax,%eax
  801194:	78 67                	js     8011fd <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801196:	83 ec 08             	sub    $0x8,%esp
  801199:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80119c:	50                   	push   %eax
  80119d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011a0:	ff 30                	pushl  (%eax)
  8011a2:	e8 aa fd ff ff       	call   800f51 <dev_lookup>
  8011a7:	83 c4 10             	add    $0x10,%esp
  8011aa:	85 c0                	test   %eax,%eax
  8011ac:	78 4f                	js     8011fd <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8011ae:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8011b1:	8b 42 08             	mov    0x8(%edx),%eax
  8011b4:	83 e0 03             	and    $0x3,%eax
  8011b7:	83 f8 01             	cmp    $0x1,%eax
  8011ba:	75 21                	jne    8011dd <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8011bc:	a1 04 40 80 00       	mov    0x804004,%eax
  8011c1:	8b 40 48             	mov    0x48(%eax),%eax
  8011c4:	83 ec 04             	sub    $0x4,%esp
  8011c7:	53                   	push   %ebx
  8011c8:	50                   	push   %eax
  8011c9:	68 d1 22 80 00       	push   $0x8022d1
  8011ce:	e8 a8 ef ff ff       	call   80017b <cprintf>
		return -E_INVAL;
  8011d3:	83 c4 10             	add    $0x10,%esp
  8011d6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011db:	eb 20                	jmp    8011fd <read+0x82>
	}
	if (!dev->dev_read)
  8011dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011e0:	8b 40 08             	mov    0x8(%eax),%eax
  8011e3:	85 c0                	test   %eax,%eax
  8011e5:	74 11                	je     8011f8 <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8011e7:	83 ec 04             	sub    $0x4,%esp
  8011ea:	ff 75 10             	pushl  0x10(%ebp)
  8011ed:	ff 75 0c             	pushl  0xc(%ebp)
  8011f0:	52                   	push   %edx
  8011f1:	ff d0                	call   *%eax
  8011f3:	83 c4 10             	add    $0x10,%esp
  8011f6:	eb 05                	jmp    8011fd <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8011f8:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8011fd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801200:	c9                   	leave  
  801201:	c3                   	ret    

00801202 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801202:	55                   	push   %ebp
  801203:	89 e5                	mov    %esp,%ebp
  801205:	57                   	push   %edi
  801206:	56                   	push   %esi
  801207:	53                   	push   %ebx
  801208:	83 ec 0c             	sub    $0xc,%esp
  80120b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80120e:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801211:	85 f6                	test   %esi,%esi
  801213:	74 31                	je     801246 <readn+0x44>
  801215:	b8 00 00 00 00       	mov    $0x0,%eax
  80121a:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  80121f:	83 ec 04             	sub    $0x4,%esp
  801222:	89 f2                	mov    %esi,%edx
  801224:	29 c2                	sub    %eax,%edx
  801226:	52                   	push   %edx
  801227:	03 45 0c             	add    0xc(%ebp),%eax
  80122a:	50                   	push   %eax
  80122b:	57                   	push   %edi
  80122c:	e8 4a ff ff ff       	call   80117b <read>
		if (m < 0)
  801231:	83 c4 10             	add    $0x10,%esp
  801234:	85 c0                	test   %eax,%eax
  801236:	78 17                	js     80124f <readn+0x4d>
			return m;
		if (m == 0)
  801238:	85 c0                	test   %eax,%eax
  80123a:	74 11                	je     80124d <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80123c:	01 c3                	add    %eax,%ebx
  80123e:	89 d8                	mov    %ebx,%eax
  801240:	39 f3                	cmp    %esi,%ebx
  801242:	72 db                	jb     80121f <readn+0x1d>
  801244:	eb 09                	jmp    80124f <readn+0x4d>
  801246:	b8 00 00 00 00       	mov    $0x0,%eax
  80124b:	eb 02                	jmp    80124f <readn+0x4d>
  80124d:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80124f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801252:	5b                   	pop    %ebx
  801253:	5e                   	pop    %esi
  801254:	5f                   	pop    %edi
  801255:	5d                   	pop    %ebp
  801256:	c3                   	ret    

00801257 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801257:	55                   	push   %ebp
  801258:	89 e5                	mov    %esp,%ebp
  80125a:	53                   	push   %ebx
  80125b:	83 ec 14             	sub    $0x14,%esp
  80125e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801261:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801264:	50                   	push   %eax
  801265:	53                   	push   %ebx
  801266:	e8 8f fc ff ff       	call   800efa <fd_lookup>
  80126b:	83 c4 08             	add    $0x8,%esp
  80126e:	85 c0                	test   %eax,%eax
  801270:	78 62                	js     8012d4 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801272:	83 ec 08             	sub    $0x8,%esp
  801275:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801278:	50                   	push   %eax
  801279:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80127c:	ff 30                	pushl  (%eax)
  80127e:	e8 ce fc ff ff       	call   800f51 <dev_lookup>
  801283:	83 c4 10             	add    $0x10,%esp
  801286:	85 c0                	test   %eax,%eax
  801288:	78 4a                	js     8012d4 <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80128a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80128d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801291:	75 21                	jne    8012b4 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801293:	a1 04 40 80 00       	mov    0x804004,%eax
  801298:	8b 40 48             	mov    0x48(%eax),%eax
  80129b:	83 ec 04             	sub    $0x4,%esp
  80129e:	53                   	push   %ebx
  80129f:	50                   	push   %eax
  8012a0:	68 ed 22 80 00       	push   $0x8022ed
  8012a5:	e8 d1 ee ff ff       	call   80017b <cprintf>
		return -E_INVAL;
  8012aa:	83 c4 10             	add    $0x10,%esp
  8012ad:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012b2:	eb 20                	jmp    8012d4 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8012b4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012b7:	8b 52 0c             	mov    0xc(%edx),%edx
  8012ba:	85 d2                	test   %edx,%edx
  8012bc:	74 11                	je     8012cf <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8012be:	83 ec 04             	sub    $0x4,%esp
  8012c1:	ff 75 10             	pushl  0x10(%ebp)
  8012c4:	ff 75 0c             	pushl  0xc(%ebp)
  8012c7:	50                   	push   %eax
  8012c8:	ff d2                	call   *%edx
  8012ca:	83 c4 10             	add    $0x10,%esp
  8012cd:	eb 05                	jmp    8012d4 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8012cf:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8012d4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012d7:	c9                   	leave  
  8012d8:	c3                   	ret    

008012d9 <seek>:

int
seek(int fdnum, off_t offset)
{
  8012d9:	55                   	push   %ebp
  8012da:	89 e5                	mov    %esp,%ebp
  8012dc:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012df:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8012e2:	50                   	push   %eax
  8012e3:	ff 75 08             	pushl  0x8(%ebp)
  8012e6:	e8 0f fc ff ff       	call   800efa <fd_lookup>
  8012eb:	83 c4 08             	add    $0x8,%esp
  8012ee:	85 c0                	test   %eax,%eax
  8012f0:	78 0e                	js     801300 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8012f2:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8012f5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012f8:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8012fb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801300:	c9                   	leave  
  801301:	c3                   	ret    

00801302 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801302:	55                   	push   %ebp
  801303:	89 e5                	mov    %esp,%ebp
  801305:	53                   	push   %ebx
  801306:	83 ec 14             	sub    $0x14,%esp
  801309:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80130c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80130f:	50                   	push   %eax
  801310:	53                   	push   %ebx
  801311:	e8 e4 fb ff ff       	call   800efa <fd_lookup>
  801316:	83 c4 08             	add    $0x8,%esp
  801319:	85 c0                	test   %eax,%eax
  80131b:	78 5f                	js     80137c <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80131d:	83 ec 08             	sub    $0x8,%esp
  801320:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801323:	50                   	push   %eax
  801324:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801327:	ff 30                	pushl  (%eax)
  801329:	e8 23 fc ff ff       	call   800f51 <dev_lookup>
  80132e:	83 c4 10             	add    $0x10,%esp
  801331:	85 c0                	test   %eax,%eax
  801333:	78 47                	js     80137c <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801335:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801338:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80133c:	75 21                	jne    80135f <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80133e:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801343:	8b 40 48             	mov    0x48(%eax),%eax
  801346:	83 ec 04             	sub    $0x4,%esp
  801349:	53                   	push   %ebx
  80134a:	50                   	push   %eax
  80134b:	68 b0 22 80 00       	push   $0x8022b0
  801350:	e8 26 ee ff ff       	call   80017b <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801355:	83 c4 10             	add    $0x10,%esp
  801358:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80135d:	eb 1d                	jmp    80137c <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  80135f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801362:	8b 52 18             	mov    0x18(%edx),%edx
  801365:	85 d2                	test   %edx,%edx
  801367:	74 0e                	je     801377 <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801369:	83 ec 08             	sub    $0x8,%esp
  80136c:	ff 75 0c             	pushl  0xc(%ebp)
  80136f:	50                   	push   %eax
  801370:	ff d2                	call   *%edx
  801372:	83 c4 10             	add    $0x10,%esp
  801375:	eb 05                	jmp    80137c <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801377:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  80137c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80137f:	c9                   	leave  
  801380:	c3                   	ret    

00801381 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801381:	55                   	push   %ebp
  801382:	89 e5                	mov    %esp,%ebp
  801384:	53                   	push   %ebx
  801385:	83 ec 14             	sub    $0x14,%esp
  801388:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80138b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80138e:	50                   	push   %eax
  80138f:	ff 75 08             	pushl  0x8(%ebp)
  801392:	e8 63 fb ff ff       	call   800efa <fd_lookup>
  801397:	83 c4 08             	add    $0x8,%esp
  80139a:	85 c0                	test   %eax,%eax
  80139c:	78 52                	js     8013f0 <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80139e:	83 ec 08             	sub    $0x8,%esp
  8013a1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013a4:	50                   	push   %eax
  8013a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013a8:	ff 30                	pushl  (%eax)
  8013aa:	e8 a2 fb ff ff       	call   800f51 <dev_lookup>
  8013af:	83 c4 10             	add    $0x10,%esp
  8013b2:	85 c0                	test   %eax,%eax
  8013b4:	78 3a                	js     8013f0 <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  8013b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013b9:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8013bd:	74 2c                	je     8013eb <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8013bf:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8013c2:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8013c9:	00 00 00 
	stat->st_isdir = 0;
  8013cc:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8013d3:	00 00 00 
	stat->st_dev = dev;
  8013d6:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8013dc:	83 ec 08             	sub    $0x8,%esp
  8013df:	53                   	push   %ebx
  8013e0:	ff 75 f0             	pushl  -0x10(%ebp)
  8013e3:	ff 50 14             	call   *0x14(%eax)
  8013e6:	83 c4 10             	add    $0x10,%esp
  8013e9:	eb 05                	jmp    8013f0 <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8013eb:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8013f0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013f3:	c9                   	leave  
  8013f4:	c3                   	ret    

008013f5 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8013f5:	55                   	push   %ebp
  8013f6:	89 e5                	mov    %esp,%ebp
  8013f8:	56                   	push   %esi
  8013f9:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8013fa:	83 ec 08             	sub    $0x8,%esp
  8013fd:	6a 00                	push   $0x0
  8013ff:	ff 75 08             	pushl  0x8(%ebp)
  801402:	e8 75 01 00 00       	call   80157c <open>
  801407:	89 c3                	mov    %eax,%ebx
  801409:	83 c4 10             	add    $0x10,%esp
  80140c:	85 c0                	test   %eax,%eax
  80140e:	78 1d                	js     80142d <stat+0x38>
		return fd;
	r = fstat(fd, stat);
  801410:	83 ec 08             	sub    $0x8,%esp
  801413:	ff 75 0c             	pushl  0xc(%ebp)
  801416:	50                   	push   %eax
  801417:	e8 65 ff ff ff       	call   801381 <fstat>
  80141c:	89 c6                	mov    %eax,%esi
	close(fd);
  80141e:	89 1c 24             	mov    %ebx,(%esp)
  801421:	e8 1d fc ff ff       	call   801043 <close>
	return r;
  801426:	83 c4 10             	add    $0x10,%esp
  801429:	89 f0                	mov    %esi,%eax
  80142b:	eb 00                	jmp    80142d <stat+0x38>
}
  80142d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801430:	5b                   	pop    %ebx
  801431:	5e                   	pop    %esi
  801432:	5d                   	pop    %ebp
  801433:	c3                   	ret    

00801434 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801434:	55                   	push   %ebp
  801435:	89 e5                	mov    %esp,%ebp
  801437:	56                   	push   %esi
  801438:	53                   	push   %ebx
  801439:	89 c6                	mov    %eax,%esi
  80143b:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80143d:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801444:	75 12                	jne    801458 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801446:	83 ec 0c             	sub    $0xc,%esp
  801449:	6a 01                	push   $0x1
  80144b:	e8 c1 07 00 00       	call   801c11 <ipc_find_env>
  801450:	a3 00 40 80 00       	mov    %eax,0x804000
  801455:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801458:	6a 07                	push   $0x7
  80145a:	68 00 50 80 00       	push   $0x805000
  80145f:	56                   	push   %esi
  801460:	ff 35 00 40 80 00    	pushl  0x804000
  801466:	e8 47 07 00 00       	call   801bb2 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80146b:	83 c4 0c             	add    $0xc,%esp
  80146e:	6a 00                	push   $0x0
  801470:	53                   	push   %ebx
  801471:	6a 00                	push   $0x0
  801473:	e8 c5 06 00 00       	call   801b3d <ipc_recv>
}
  801478:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80147b:	5b                   	pop    %ebx
  80147c:	5e                   	pop    %esi
  80147d:	5d                   	pop    %ebp
  80147e:	c3                   	ret    

0080147f <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80147f:	55                   	push   %ebp
  801480:	89 e5                	mov    %esp,%ebp
  801482:	53                   	push   %ebx
  801483:	83 ec 04             	sub    $0x4,%esp
  801486:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801489:	8b 45 08             	mov    0x8(%ebp),%eax
  80148c:	8b 40 0c             	mov    0xc(%eax),%eax
  80148f:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801494:	ba 00 00 00 00       	mov    $0x0,%edx
  801499:	b8 05 00 00 00       	mov    $0x5,%eax
  80149e:	e8 91 ff ff ff       	call   801434 <fsipc>
  8014a3:	85 c0                	test   %eax,%eax
  8014a5:	78 2c                	js     8014d3 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8014a7:	83 ec 08             	sub    $0x8,%esp
  8014aa:	68 00 50 80 00       	push   $0x805000
  8014af:	53                   	push   %ebx
  8014b0:	e8 ab f2 ff ff       	call   800760 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8014b5:	a1 80 50 80 00       	mov    0x805080,%eax
  8014ba:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8014c0:	a1 84 50 80 00       	mov    0x805084,%eax
  8014c5:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8014cb:	83 c4 10             	add    $0x10,%esp
  8014ce:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014d3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014d6:	c9                   	leave  
  8014d7:	c3                   	ret    

008014d8 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8014d8:	55                   	push   %ebp
  8014d9:	89 e5                	mov    %esp,%ebp
  8014db:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8014de:	8b 45 08             	mov    0x8(%ebp),%eax
  8014e1:	8b 40 0c             	mov    0xc(%eax),%eax
  8014e4:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8014e9:	ba 00 00 00 00       	mov    $0x0,%edx
  8014ee:	b8 06 00 00 00       	mov    $0x6,%eax
  8014f3:	e8 3c ff ff ff       	call   801434 <fsipc>
}
  8014f8:	c9                   	leave  
  8014f9:	c3                   	ret    

008014fa <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8014fa:	55                   	push   %ebp
  8014fb:	89 e5                	mov    %esp,%ebp
  8014fd:	56                   	push   %esi
  8014fe:	53                   	push   %ebx
  8014ff:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801502:	8b 45 08             	mov    0x8(%ebp),%eax
  801505:	8b 40 0c             	mov    0xc(%eax),%eax
  801508:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80150d:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801513:	ba 00 00 00 00       	mov    $0x0,%edx
  801518:	b8 03 00 00 00       	mov    $0x3,%eax
  80151d:	e8 12 ff ff ff       	call   801434 <fsipc>
  801522:	89 c3                	mov    %eax,%ebx
  801524:	85 c0                	test   %eax,%eax
  801526:	78 4b                	js     801573 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801528:	39 c6                	cmp    %eax,%esi
  80152a:	73 16                	jae    801542 <devfile_read+0x48>
  80152c:	68 0a 23 80 00       	push   $0x80230a
  801531:	68 11 23 80 00       	push   $0x802311
  801536:	6a 7a                	push   $0x7a
  801538:	68 26 23 80 00       	push   $0x802326
  80153d:	e8 b5 05 00 00       	call   801af7 <_panic>
	assert(r <= PGSIZE);
  801542:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801547:	7e 16                	jle    80155f <devfile_read+0x65>
  801549:	68 31 23 80 00       	push   $0x802331
  80154e:	68 11 23 80 00       	push   $0x802311
  801553:	6a 7b                	push   $0x7b
  801555:	68 26 23 80 00       	push   $0x802326
  80155a:	e8 98 05 00 00       	call   801af7 <_panic>
	memmove(buf, &fsipcbuf, r);
  80155f:	83 ec 04             	sub    $0x4,%esp
  801562:	50                   	push   %eax
  801563:	68 00 50 80 00       	push   $0x805000
  801568:	ff 75 0c             	pushl  0xc(%ebp)
  80156b:	e8 bd f3 ff ff       	call   80092d <memmove>
	return r;
  801570:	83 c4 10             	add    $0x10,%esp
}
  801573:	89 d8                	mov    %ebx,%eax
  801575:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801578:	5b                   	pop    %ebx
  801579:	5e                   	pop    %esi
  80157a:	5d                   	pop    %ebp
  80157b:	c3                   	ret    

0080157c <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80157c:	55                   	push   %ebp
  80157d:	89 e5                	mov    %esp,%ebp
  80157f:	53                   	push   %ebx
  801580:	83 ec 20             	sub    $0x20,%esp
  801583:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801586:	53                   	push   %ebx
  801587:	e8 7d f1 ff ff       	call   800709 <strlen>
  80158c:	83 c4 10             	add    $0x10,%esp
  80158f:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801594:	7f 63                	jg     8015f9 <open+0x7d>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801596:	83 ec 0c             	sub    $0xc,%esp
  801599:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80159c:	50                   	push   %eax
  80159d:	e8 e4 f8 ff ff       	call   800e86 <fd_alloc>
  8015a2:	83 c4 10             	add    $0x10,%esp
  8015a5:	85 c0                	test   %eax,%eax
  8015a7:	78 55                	js     8015fe <open+0x82>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8015a9:	83 ec 08             	sub    $0x8,%esp
  8015ac:	53                   	push   %ebx
  8015ad:	68 00 50 80 00       	push   $0x805000
  8015b2:	e8 a9 f1 ff ff       	call   800760 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8015b7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015ba:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8015bf:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015c2:	b8 01 00 00 00       	mov    $0x1,%eax
  8015c7:	e8 68 fe ff ff       	call   801434 <fsipc>
  8015cc:	89 c3                	mov    %eax,%ebx
  8015ce:	83 c4 10             	add    $0x10,%esp
  8015d1:	85 c0                	test   %eax,%eax
  8015d3:	79 14                	jns    8015e9 <open+0x6d>
		fd_close(fd, 0);
  8015d5:	83 ec 08             	sub    $0x8,%esp
  8015d8:	6a 00                	push   $0x0
  8015da:	ff 75 f4             	pushl  -0xc(%ebp)
  8015dd:	e8 dd f9 ff ff       	call   800fbf <fd_close>
		return r;
  8015e2:	83 c4 10             	add    $0x10,%esp
  8015e5:	89 d8                	mov    %ebx,%eax
  8015e7:	eb 15                	jmp    8015fe <open+0x82>
	}

	return fd2num(fd);
  8015e9:	83 ec 0c             	sub    $0xc,%esp
  8015ec:	ff 75 f4             	pushl  -0xc(%ebp)
  8015ef:	e8 6b f8 ff ff       	call   800e5f <fd2num>
  8015f4:	83 c4 10             	add    $0x10,%esp
  8015f7:	eb 05                	jmp    8015fe <open+0x82>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8015f9:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8015fe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801601:	c9                   	leave  
  801602:	c3                   	ret    

00801603 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801603:	55                   	push   %ebp
  801604:	89 e5                	mov    %esp,%ebp
  801606:	56                   	push   %esi
  801607:	53                   	push   %ebx
  801608:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80160b:	83 ec 0c             	sub    $0xc,%esp
  80160e:	ff 75 08             	pushl  0x8(%ebp)
  801611:	e8 59 f8 ff ff       	call   800e6f <fd2data>
  801616:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801618:	83 c4 08             	add    $0x8,%esp
  80161b:	68 3d 23 80 00       	push   $0x80233d
  801620:	53                   	push   %ebx
  801621:	e8 3a f1 ff ff       	call   800760 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801626:	8b 46 04             	mov    0x4(%esi),%eax
  801629:	2b 06                	sub    (%esi),%eax
  80162b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801631:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801638:	00 00 00 
	stat->st_dev = &devpipe;
  80163b:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801642:	30 80 00 
	return 0;
}
  801645:	b8 00 00 00 00       	mov    $0x0,%eax
  80164a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80164d:	5b                   	pop    %ebx
  80164e:	5e                   	pop    %esi
  80164f:	5d                   	pop    %ebp
  801650:	c3                   	ret    

00801651 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801651:	55                   	push   %ebp
  801652:	89 e5                	mov    %esp,%ebp
  801654:	53                   	push   %ebx
  801655:	83 ec 0c             	sub    $0xc,%esp
  801658:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80165b:	53                   	push   %ebx
  80165c:	6a 00                	push   $0x0
  80165e:	e8 f2 f5 ff ff       	call   800c55 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801663:	89 1c 24             	mov    %ebx,(%esp)
  801666:	e8 04 f8 ff ff       	call   800e6f <fd2data>
  80166b:	83 c4 08             	add    $0x8,%esp
  80166e:	50                   	push   %eax
  80166f:	6a 00                	push   $0x0
  801671:	e8 df f5 ff ff       	call   800c55 <sys_page_unmap>
}
  801676:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801679:	c9                   	leave  
  80167a:	c3                   	ret    

0080167b <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80167b:	55                   	push   %ebp
  80167c:	89 e5                	mov    %esp,%ebp
  80167e:	57                   	push   %edi
  80167f:	56                   	push   %esi
  801680:	53                   	push   %ebx
  801681:	83 ec 1c             	sub    $0x1c,%esp
  801684:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801687:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801689:	a1 04 40 80 00       	mov    0x804004,%eax
  80168e:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801691:	83 ec 0c             	sub    $0xc,%esp
  801694:	ff 75 e0             	pushl  -0x20(%ebp)
  801697:	e8 d0 05 00 00       	call   801c6c <pageref>
  80169c:	89 c3                	mov    %eax,%ebx
  80169e:	89 3c 24             	mov    %edi,(%esp)
  8016a1:	e8 c6 05 00 00       	call   801c6c <pageref>
  8016a6:	83 c4 10             	add    $0x10,%esp
  8016a9:	39 c3                	cmp    %eax,%ebx
  8016ab:	0f 94 c1             	sete   %cl
  8016ae:	0f b6 c9             	movzbl %cl,%ecx
  8016b1:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8016b4:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8016ba:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8016bd:	39 ce                	cmp    %ecx,%esi
  8016bf:	74 1b                	je     8016dc <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8016c1:	39 c3                	cmp    %eax,%ebx
  8016c3:	75 c4                	jne    801689 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8016c5:	8b 42 58             	mov    0x58(%edx),%eax
  8016c8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8016cb:	50                   	push   %eax
  8016cc:	56                   	push   %esi
  8016cd:	68 44 23 80 00       	push   $0x802344
  8016d2:	e8 a4 ea ff ff       	call   80017b <cprintf>
  8016d7:	83 c4 10             	add    $0x10,%esp
  8016da:	eb ad                	jmp    801689 <_pipeisclosed+0xe>
	}
}
  8016dc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8016df:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016e2:	5b                   	pop    %ebx
  8016e3:	5e                   	pop    %esi
  8016e4:	5f                   	pop    %edi
  8016e5:	5d                   	pop    %ebp
  8016e6:	c3                   	ret    

008016e7 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8016e7:	55                   	push   %ebp
  8016e8:	89 e5                	mov    %esp,%ebp
  8016ea:	57                   	push   %edi
  8016eb:	56                   	push   %esi
  8016ec:	53                   	push   %ebx
  8016ed:	83 ec 18             	sub    $0x18,%esp
  8016f0:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8016f3:	56                   	push   %esi
  8016f4:	e8 76 f7 ff ff       	call   800e6f <fd2data>
  8016f9:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8016fb:	83 c4 10             	add    $0x10,%esp
  8016fe:	bf 00 00 00 00       	mov    $0x0,%edi
  801703:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801707:	75 42                	jne    80174b <devpipe_write+0x64>
  801709:	eb 4e                	jmp    801759 <devpipe_write+0x72>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80170b:	89 da                	mov    %ebx,%edx
  80170d:	89 f0                	mov    %esi,%eax
  80170f:	e8 67 ff ff ff       	call   80167b <_pipeisclosed>
  801714:	85 c0                	test   %eax,%eax
  801716:	75 46                	jne    80175e <devpipe_write+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801718:	e8 94 f4 ff ff       	call   800bb1 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80171d:	8b 53 04             	mov    0x4(%ebx),%edx
  801720:	8b 03                	mov    (%ebx),%eax
  801722:	83 c0 20             	add    $0x20,%eax
  801725:	39 c2                	cmp    %eax,%edx
  801727:	73 e2                	jae    80170b <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801729:	8b 45 0c             	mov    0xc(%ebp),%eax
  80172c:	8a 0c 38             	mov    (%eax,%edi,1),%cl
  80172f:	89 d0                	mov    %edx,%eax
  801731:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801736:	79 05                	jns    80173d <devpipe_write+0x56>
  801738:	48                   	dec    %eax
  801739:	83 c8 e0             	or     $0xffffffe0,%eax
  80173c:	40                   	inc    %eax
  80173d:	88 4c 03 08          	mov    %cl,0x8(%ebx,%eax,1)
		p->p_wpos++;
  801741:	42                   	inc    %edx
  801742:	89 53 04             	mov    %edx,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801745:	47                   	inc    %edi
  801746:	39 7d 10             	cmp    %edi,0x10(%ebp)
  801749:	74 0e                	je     801759 <devpipe_write+0x72>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80174b:	8b 53 04             	mov    0x4(%ebx),%edx
  80174e:	8b 03                	mov    (%ebx),%eax
  801750:	83 c0 20             	add    $0x20,%eax
  801753:	39 c2                	cmp    %eax,%edx
  801755:	73 b4                	jae    80170b <devpipe_write+0x24>
  801757:	eb d0                	jmp    801729 <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801759:	8b 45 10             	mov    0x10(%ebp),%eax
  80175c:	eb 05                	jmp    801763 <devpipe_write+0x7c>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80175e:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801763:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801766:	5b                   	pop    %ebx
  801767:	5e                   	pop    %esi
  801768:	5f                   	pop    %edi
  801769:	5d                   	pop    %ebp
  80176a:	c3                   	ret    

0080176b <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80176b:	55                   	push   %ebp
  80176c:	89 e5                	mov    %esp,%ebp
  80176e:	57                   	push   %edi
  80176f:	56                   	push   %esi
  801770:	53                   	push   %ebx
  801771:	83 ec 18             	sub    $0x18,%esp
  801774:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801777:	57                   	push   %edi
  801778:	e8 f2 f6 ff ff       	call   800e6f <fd2data>
  80177d:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80177f:	83 c4 10             	add    $0x10,%esp
  801782:	be 00 00 00 00       	mov    $0x0,%esi
  801787:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80178b:	75 3d                	jne    8017ca <devpipe_read+0x5f>
  80178d:	eb 48                	jmp    8017d7 <devpipe_read+0x6c>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  80178f:	89 f0                	mov    %esi,%eax
  801791:	eb 4e                	jmp    8017e1 <devpipe_read+0x76>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801793:	89 da                	mov    %ebx,%edx
  801795:	89 f8                	mov    %edi,%eax
  801797:	e8 df fe ff ff       	call   80167b <_pipeisclosed>
  80179c:	85 c0                	test   %eax,%eax
  80179e:	75 3c                	jne    8017dc <devpipe_read+0x71>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8017a0:	e8 0c f4 ff ff       	call   800bb1 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8017a5:	8b 03                	mov    (%ebx),%eax
  8017a7:	3b 43 04             	cmp    0x4(%ebx),%eax
  8017aa:	74 e7                	je     801793 <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8017ac:	25 1f 00 00 80       	and    $0x8000001f,%eax
  8017b1:	79 05                	jns    8017b8 <devpipe_read+0x4d>
  8017b3:	48                   	dec    %eax
  8017b4:	83 c8 e0             	or     $0xffffffe0,%eax
  8017b7:	40                   	inc    %eax
  8017b8:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  8017bc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017bf:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  8017c2:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8017c4:	46                   	inc    %esi
  8017c5:	39 75 10             	cmp    %esi,0x10(%ebp)
  8017c8:	74 0d                	je     8017d7 <devpipe_read+0x6c>
		while (p->p_rpos == p->p_wpos) {
  8017ca:	8b 03                	mov    (%ebx),%eax
  8017cc:	3b 43 04             	cmp    0x4(%ebx),%eax
  8017cf:	75 db                	jne    8017ac <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8017d1:	85 f6                	test   %esi,%esi
  8017d3:	75 ba                	jne    80178f <devpipe_read+0x24>
  8017d5:	eb bc                	jmp    801793 <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8017d7:	8b 45 10             	mov    0x10(%ebp),%eax
  8017da:	eb 05                	jmp    8017e1 <devpipe_read+0x76>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8017dc:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8017e1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017e4:	5b                   	pop    %ebx
  8017e5:	5e                   	pop    %esi
  8017e6:	5f                   	pop    %edi
  8017e7:	5d                   	pop    %ebp
  8017e8:	c3                   	ret    

008017e9 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8017e9:	55                   	push   %ebp
  8017ea:	89 e5                	mov    %esp,%ebp
  8017ec:	56                   	push   %esi
  8017ed:	53                   	push   %ebx
  8017ee:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8017f1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017f4:	50                   	push   %eax
  8017f5:	e8 8c f6 ff ff       	call   800e86 <fd_alloc>
  8017fa:	83 c4 10             	add    $0x10,%esp
  8017fd:	85 c0                	test   %eax,%eax
  8017ff:	0f 88 2a 01 00 00    	js     80192f <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801805:	83 ec 04             	sub    $0x4,%esp
  801808:	68 07 04 00 00       	push   $0x407
  80180d:	ff 75 f4             	pushl  -0xc(%ebp)
  801810:	6a 00                	push   $0x0
  801812:	e8 b9 f3 ff ff       	call   800bd0 <sys_page_alloc>
  801817:	83 c4 10             	add    $0x10,%esp
  80181a:	85 c0                	test   %eax,%eax
  80181c:	0f 88 0d 01 00 00    	js     80192f <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801822:	83 ec 0c             	sub    $0xc,%esp
  801825:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801828:	50                   	push   %eax
  801829:	e8 58 f6 ff ff       	call   800e86 <fd_alloc>
  80182e:	89 c3                	mov    %eax,%ebx
  801830:	83 c4 10             	add    $0x10,%esp
  801833:	85 c0                	test   %eax,%eax
  801835:	0f 88 e2 00 00 00    	js     80191d <pipe+0x134>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80183b:	83 ec 04             	sub    $0x4,%esp
  80183e:	68 07 04 00 00       	push   $0x407
  801843:	ff 75 f0             	pushl  -0x10(%ebp)
  801846:	6a 00                	push   $0x0
  801848:	e8 83 f3 ff ff       	call   800bd0 <sys_page_alloc>
  80184d:	89 c3                	mov    %eax,%ebx
  80184f:	83 c4 10             	add    $0x10,%esp
  801852:	85 c0                	test   %eax,%eax
  801854:	0f 88 c3 00 00 00    	js     80191d <pipe+0x134>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80185a:	83 ec 0c             	sub    $0xc,%esp
  80185d:	ff 75 f4             	pushl  -0xc(%ebp)
  801860:	e8 0a f6 ff ff       	call   800e6f <fd2data>
  801865:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801867:	83 c4 0c             	add    $0xc,%esp
  80186a:	68 07 04 00 00       	push   $0x407
  80186f:	50                   	push   %eax
  801870:	6a 00                	push   $0x0
  801872:	e8 59 f3 ff ff       	call   800bd0 <sys_page_alloc>
  801877:	89 c3                	mov    %eax,%ebx
  801879:	83 c4 10             	add    $0x10,%esp
  80187c:	85 c0                	test   %eax,%eax
  80187e:	0f 88 89 00 00 00    	js     80190d <pipe+0x124>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801884:	83 ec 0c             	sub    $0xc,%esp
  801887:	ff 75 f0             	pushl  -0x10(%ebp)
  80188a:	e8 e0 f5 ff ff       	call   800e6f <fd2data>
  80188f:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801896:	50                   	push   %eax
  801897:	6a 00                	push   $0x0
  801899:	56                   	push   %esi
  80189a:	6a 00                	push   $0x0
  80189c:	e8 72 f3 ff ff       	call   800c13 <sys_page_map>
  8018a1:	89 c3                	mov    %eax,%ebx
  8018a3:	83 c4 20             	add    $0x20,%esp
  8018a6:	85 c0                	test   %eax,%eax
  8018a8:	78 55                	js     8018ff <pipe+0x116>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8018aa:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8018b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018b3:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8018b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018b8:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8018bf:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8018c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018c8:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8018ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018cd:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8018d4:	83 ec 0c             	sub    $0xc,%esp
  8018d7:	ff 75 f4             	pushl  -0xc(%ebp)
  8018da:	e8 80 f5 ff ff       	call   800e5f <fd2num>
  8018df:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8018e2:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8018e4:	83 c4 04             	add    $0x4,%esp
  8018e7:	ff 75 f0             	pushl  -0x10(%ebp)
  8018ea:	e8 70 f5 ff ff       	call   800e5f <fd2num>
  8018ef:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8018f2:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8018f5:	83 c4 10             	add    $0x10,%esp
  8018f8:	b8 00 00 00 00       	mov    $0x0,%eax
  8018fd:	eb 30                	jmp    80192f <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  8018ff:	83 ec 08             	sub    $0x8,%esp
  801902:	56                   	push   %esi
  801903:	6a 00                	push   $0x0
  801905:	e8 4b f3 ff ff       	call   800c55 <sys_page_unmap>
  80190a:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80190d:	83 ec 08             	sub    $0x8,%esp
  801910:	ff 75 f0             	pushl  -0x10(%ebp)
  801913:	6a 00                	push   $0x0
  801915:	e8 3b f3 ff ff       	call   800c55 <sys_page_unmap>
  80191a:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80191d:	83 ec 08             	sub    $0x8,%esp
  801920:	ff 75 f4             	pushl  -0xc(%ebp)
  801923:	6a 00                	push   $0x0
  801925:	e8 2b f3 ff ff       	call   800c55 <sys_page_unmap>
  80192a:	83 c4 10             	add    $0x10,%esp
  80192d:	89 d8                	mov    %ebx,%eax
    err:
	return r;
}
  80192f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801932:	5b                   	pop    %ebx
  801933:	5e                   	pop    %esi
  801934:	5d                   	pop    %ebp
  801935:	c3                   	ret    

00801936 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801936:	55                   	push   %ebp
  801937:	89 e5                	mov    %esp,%ebp
  801939:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80193c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80193f:	50                   	push   %eax
  801940:	ff 75 08             	pushl  0x8(%ebp)
  801943:	e8 b2 f5 ff ff       	call   800efa <fd_lookup>
  801948:	83 c4 10             	add    $0x10,%esp
  80194b:	85 c0                	test   %eax,%eax
  80194d:	78 18                	js     801967 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80194f:	83 ec 0c             	sub    $0xc,%esp
  801952:	ff 75 f4             	pushl  -0xc(%ebp)
  801955:	e8 15 f5 ff ff       	call   800e6f <fd2data>
	return _pipeisclosed(fd, p);
  80195a:	89 c2                	mov    %eax,%edx
  80195c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80195f:	e8 17 fd ff ff       	call   80167b <_pipeisclosed>
  801964:	83 c4 10             	add    $0x10,%esp
}
  801967:	c9                   	leave  
  801968:	c3                   	ret    

00801969 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801969:	55                   	push   %ebp
  80196a:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80196c:	b8 00 00 00 00       	mov    $0x0,%eax
  801971:	5d                   	pop    %ebp
  801972:	c3                   	ret    

00801973 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801973:	55                   	push   %ebp
  801974:	89 e5                	mov    %esp,%ebp
  801976:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801979:	68 5c 23 80 00       	push   $0x80235c
  80197e:	ff 75 0c             	pushl  0xc(%ebp)
  801981:	e8 da ed ff ff       	call   800760 <strcpy>
	return 0;
}
  801986:	b8 00 00 00 00       	mov    $0x0,%eax
  80198b:	c9                   	leave  
  80198c:	c3                   	ret    

0080198d <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80198d:	55                   	push   %ebp
  80198e:	89 e5                	mov    %esp,%ebp
  801990:	57                   	push   %edi
  801991:	56                   	push   %esi
  801992:	53                   	push   %ebx
  801993:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801999:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80199d:	74 45                	je     8019e4 <devcons_write+0x57>
  80199f:	b8 00 00 00 00       	mov    $0x0,%eax
  8019a4:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8019a9:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8019af:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8019b2:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  8019b4:	83 fb 7f             	cmp    $0x7f,%ebx
  8019b7:	76 05                	jbe    8019be <devcons_write+0x31>
			m = sizeof(buf) - 1;
  8019b9:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  8019be:	83 ec 04             	sub    $0x4,%esp
  8019c1:	53                   	push   %ebx
  8019c2:	03 45 0c             	add    0xc(%ebp),%eax
  8019c5:	50                   	push   %eax
  8019c6:	57                   	push   %edi
  8019c7:	e8 61 ef ff ff       	call   80092d <memmove>
		sys_cputs(buf, m);
  8019cc:	83 c4 08             	add    $0x8,%esp
  8019cf:	53                   	push   %ebx
  8019d0:	57                   	push   %edi
  8019d1:	e8 3e f1 ff ff       	call   800b14 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8019d6:	01 de                	add    %ebx,%esi
  8019d8:	89 f0                	mov    %esi,%eax
  8019da:	83 c4 10             	add    $0x10,%esp
  8019dd:	3b 75 10             	cmp    0x10(%ebp),%esi
  8019e0:	72 cd                	jb     8019af <devcons_write+0x22>
  8019e2:	eb 05                	jmp    8019e9 <devcons_write+0x5c>
  8019e4:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8019e9:	89 f0                	mov    %esi,%eax
  8019eb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019ee:	5b                   	pop    %ebx
  8019ef:	5e                   	pop    %esi
  8019f0:	5f                   	pop    %edi
  8019f1:	5d                   	pop    %ebp
  8019f2:	c3                   	ret    

008019f3 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8019f3:	55                   	push   %ebp
  8019f4:	89 e5                	mov    %esp,%ebp
  8019f6:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  8019f9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8019fd:	75 07                	jne    801a06 <devcons_read+0x13>
  8019ff:	eb 23                	jmp    801a24 <devcons_read+0x31>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801a01:	e8 ab f1 ff ff       	call   800bb1 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801a06:	e8 27 f1 ff ff       	call   800b32 <sys_cgetc>
  801a0b:	85 c0                	test   %eax,%eax
  801a0d:	74 f2                	je     801a01 <devcons_read+0xe>
		sys_yield();
	if (c < 0)
  801a0f:	85 c0                	test   %eax,%eax
  801a11:	78 1d                	js     801a30 <devcons_read+0x3d>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801a13:	83 f8 04             	cmp    $0x4,%eax
  801a16:	74 13                	je     801a2b <devcons_read+0x38>
		return 0;
	*(char*)vbuf = c;
  801a18:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a1b:	88 02                	mov    %al,(%edx)
	return 1;
  801a1d:	b8 01 00 00 00       	mov    $0x1,%eax
  801a22:	eb 0c                	jmp    801a30 <devcons_read+0x3d>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801a24:	b8 00 00 00 00       	mov    $0x0,%eax
  801a29:	eb 05                	jmp    801a30 <devcons_read+0x3d>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801a2b:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801a30:	c9                   	leave  
  801a31:	c3                   	ret    

00801a32 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801a32:	55                   	push   %ebp
  801a33:	89 e5                	mov    %esp,%ebp
  801a35:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801a38:	8b 45 08             	mov    0x8(%ebp),%eax
  801a3b:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801a3e:	6a 01                	push   $0x1
  801a40:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a43:	50                   	push   %eax
  801a44:	e8 cb f0 ff ff       	call   800b14 <sys_cputs>
}
  801a49:	83 c4 10             	add    $0x10,%esp
  801a4c:	c9                   	leave  
  801a4d:	c3                   	ret    

00801a4e <getchar>:

int
getchar(void)
{
  801a4e:	55                   	push   %ebp
  801a4f:	89 e5                	mov    %esp,%ebp
  801a51:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801a54:	6a 01                	push   $0x1
  801a56:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a59:	50                   	push   %eax
  801a5a:	6a 00                	push   $0x0
  801a5c:	e8 1a f7 ff ff       	call   80117b <read>
	if (r < 0)
  801a61:	83 c4 10             	add    $0x10,%esp
  801a64:	85 c0                	test   %eax,%eax
  801a66:	78 0f                	js     801a77 <getchar+0x29>
		return r;
	if (r < 1)
  801a68:	85 c0                	test   %eax,%eax
  801a6a:	7e 06                	jle    801a72 <getchar+0x24>
		return -E_EOF;
	return c;
  801a6c:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801a70:	eb 05                	jmp    801a77 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801a72:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801a77:	c9                   	leave  
  801a78:	c3                   	ret    

00801a79 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801a79:	55                   	push   %ebp
  801a7a:	89 e5                	mov    %esp,%ebp
  801a7c:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a7f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a82:	50                   	push   %eax
  801a83:	ff 75 08             	pushl  0x8(%ebp)
  801a86:	e8 6f f4 ff ff       	call   800efa <fd_lookup>
  801a8b:	83 c4 10             	add    $0x10,%esp
  801a8e:	85 c0                	test   %eax,%eax
  801a90:	78 11                	js     801aa3 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801a92:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a95:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801a9b:	39 10                	cmp    %edx,(%eax)
  801a9d:	0f 94 c0             	sete   %al
  801aa0:	0f b6 c0             	movzbl %al,%eax
}
  801aa3:	c9                   	leave  
  801aa4:	c3                   	ret    

00801aa5 <opencons>:

int
opencons(void)
{
  801aa5:	55                   	push   %ebp
  801aa6:	89 e5                	mov    %esp,%ebp
  801aa8:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801aab:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801aae:	50                   	push   %eax
  801aaf:	e8 d2 f3 ff ff       	call   800e86 <fd_alloc>
  801ab4:	83 c4 10             	add    $0x10,%esp
  801ab7:	85 c0                	test   %eax,%eax
  801ab9:	78 3a                	js     801af5 <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801abb:	83 ec 04             	sub    $0x4,%esp
  801abe:	68 07 04 00 00       	push   $0x407
  801ac3:	ff 75 f4             	pushl  -0xc(%ebp)
  801ac6:	6a 00                	push   $0x0
  801ac8:	e8 03 f1 ff ff       	call   800bd0 <sys_page_alloc>
  801acd:	83 c4 10             	add    $0x10,%esp
  801ad0:	85 c0                	test   %eax,%eax
  801ad2:	78 21                	js     801af5 <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801ad4:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ada:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801add:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801adf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ae2:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801ae9:	83 ec 0c             	sub    $0xc,%esp
  801aec:	50                   	push   %eax
  801aed:	e8 6d f3 ff ff       	call   800e5f <fd2num>
  801af2:	83 c4 10             	add    $0x10,%esp
}
  801af5:	c9                   	leave  
  801af6:	c3                   	ret    

00801af7 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801af7:	55                   	push   %ebp
  801af8:	89 e5                	mov    %esp,%ebp
  801afa:	56                   	push   %esi
  801afb:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801afc:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801aff:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801b05:	e8 88 f0 ff ff       	call   800b92 <sys_getenvid>
  801b0a:	83 ec 0c             	sub    $0xc,%esp
  801b0d:	ff 75 0c             	pushl  0xc(%ebp)
  801b10:	ff 75 08             	pushl  0x8(%ebp)
  801b13:	56                   	push   %esi
  801b14:	50                   	push   %eax
  801b15:	68 68 23 80 00       	push   $0x802368
  801b1a:	e8 5c e6 ff ff       	call   80017b <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801b1f:	83 c4 18             	add    $0x18,%esp
  801b22:	53                   	push   %ebx
  801b23:	ff 75 10             	pushl  0x10(%ebp)
  801b26:	e8 ff e5 ff ff       	call   80012a <vcprintf>
	cprintf("\n");
  801b2b:	c7 04 24 55 23 80 00 	movl   $0x802355,(%esp)
  801b32:	e8 44 e6 ff ff       	call   80017b <cprintf>
  801b37:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801b3a:	cc                   	int3   
  801b3b:	eb fd                	jmp    801b3a <_panic+0x43>

00801b3d <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801b3d:	55                   	push   %ebp
  801b3e:	89 e5                	mov    %esp,%ebp
  801b40:	56                   	push   %esi
  801b41:	53                   	push   %ebx
  801b42:	8b 75 08             	mov    0x8(%ebp),%esi
  801b45:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b48:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");
	int r;
    if (pg != NULL) {
  801b4b:	85 c0                	test   %eax,%eax
  801b4d:	74 0e                	je     801b5d <ipc_recv+0x20>
        r = sys_ipc_recv(pg);
  801b4f:	83 ec 0c             	sub    $0xc,%esp
  801b52:	50                   	push   %eax
  801b53:	e8 28 f2 ff ff       	call   800d80 <sys_ipc_recv>
  801b58:	83 c4 10             	add    $0x10,%esp
  801b5b:	eb 10                	jmp    801b6d <ipc_recv+0x30>
    } else {
        r = sys_ipc_recv((void *) UTOP);
  801b5d:	83 ec 0c             	sub    $0xc,%esp
  801b60:	68 00 00 c0 ee       	push   $0xeec00000
  801b65:	e8 16 f2 ff ff       	call   800d80 <sys_ipc_recv>
  801b6a:	83 c4 10             	add    $0x10,%esp
    }
    if (r < 0) {
  801b6d:	85 c0                	test   %eax,%eax
  801b6f:	79 16                	jns    801b87 <ipc_recv+0x4a>
        // failed
        if (from_env_store != NULL) *from_env_store = 0;
  801b71:	85 f6                	test   %esi,%esi
  801b73:	74 06                	je     801b7b <ipc_recv+0x3e>
  801b75:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        if (perm_store != NULL) *perm_store = 0;
  801b7b:	85 db                	test   %ebx,%ebx
  801b7d:	74 2c                	je     801bab <ipc_recv+0x6e>
  801b7f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801b85:	eb 24                	jmp    801bab <ipc_recv+0x6e>
        return r;
    } else {
        if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801b87:	85 f6                	test   %esi,%esi
  801b89:	74 0a                	je     801b95 <ipc_recv+0x58>
  801b8b:	a1 04 40 80 00       	mov    0x804004,%eax
  801b90:	8b 40 74             	mov    0x74(%eax),%eax
  801b93:	89 06                	mov    %eax,(%esi)
        if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801b95:	85 db                	test   %ebx,%ebx
  801b97:	74 0a                	je     801ba3 <ipc_recv+0x66>
  801b99:	a1 04 40 80 00       	mov    0x804004,%eax
  801b9e:	8b 40 78             	mov    0x78(%eax),%eax
  801ba1:	89 03                	mov    %eax,(%ebx)
        return thisenv->env_ipc_value;
  801ba3:	a1 04 40 80 00       	mov    0x804004,%eax
  801ba8:	8b 40 70             	mov    0x70(%eax),%eax
    }
 
	return 0;
}
  801bab:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bae:	5b                   	pop    %ebx
  801baf:	5e                   	pop    %esi
  801bb0:	5d                   	pop    %ebp
  801bb1:	c3                   	ret    

00801bb2 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801bb2:	55                   	push   %ebp
  801bb3:	89 e5                	mov    %esp,%ebp
  801bb5:	57                   	push   %edi
  801bb6:	56                   	push   %esi
  801bb7:	53                   	push   %ebx
  801bb8:	83 ec 0c             	sub    $0xc,%esp
  801bbb:	8b 75 10             	mov    0x10(%ebp),%esi
  801bbe:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");
	int r;
    if (pg == NULL) pg = (void *)UTOP;
  801bc1:	85 f6                	test   %esi,%esi
  801bc3:	75 05                	jne    801bca <ipc_send+0x18>
  801bc5:	be 00 00 c0 ee       	mov    $0xeec00000,%esi
    do {
        r = sys_ipc_try_send(to_env, val, pg, perm);
  801bca:	57                   	push   %edi
  801bcb:	56                   	push   %esi
  801bcc:	ff 75 0c             	pushl  0xc(%ebp)
  801bcf:	ff 75 08             	pushl  0x8(%ebp)
  801bd2:	e8 86 f1 ff ff       	call   800d5d <sys_ipc_try_send>
  801bd7:	89 c3                	mov    %eax,%ebx
        if (r < 0 && r != -E_IPC_NOT_RECV) panic("ipc send failed: %e", r);
  801bd9:	83 c4 10             	add    $0x10,%esp
  801bdc:	85 c0                	test   %eax,%eax
  801bde:	79 17                	jns    801bf7 <ipc_send+0x45>
  801be0:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801be3:	74 1d                	je     801c02 <ipc_send+0x50>
  801be5:	50                   	push   %eax
  801be6:	68 8c 23 80 00       	push   $0x80238c
  801beb:	6a 40                	push   $0x40
  801bed:	68 a0 23 80 00       	push   $0x8023a0
  801bf2:	e8 00 ff ff ff       	call   801af7 <_panic>
        sys_yield();
  801bf7:	e8 b5 ef ff ff       	call   800bb1 <sys_yield>
    } while (r != 0);
  801bfc:	85 db                	test   %ebx,%ebx
  801bfe:	75 ca                	jne    801bca <ipc_send+0x18>
  801c00:	eb 07                	jmp    801c09 <ipc_send+0x57>
	int r;
    if (pg == NULL) pg = (void *)UTOP;
    do {
        r = sys_ipc_try_send(to_env, val, pg, perm);
        if (r < 0 && r != -E_IPC_NOT_RECV) panic("ipc send failed: %e", r);
        sys_yield();
  801c02:	e8 aa ef ff ff       	call   800bb1 <sys_yield>
  801c07:	eb c1                	jmp    801bca <ipc_send+0x18>
    } while (r != 0);
}
  801c09:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c0c:	5b                   	pop    %ebx
  801c0d:	5e                   	pop    %esi
  801c0e:	5f                   	pop    %edi
  801c0f:	5d                   	pop    %ebp
  801c10:	c3                   	ret    

00801c11 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801c11:	55                   	push   %ebp
  801c12:	89 e5                	mov    %esp,%ebp
  801c14:	53                   	push   %ebx
  801c15:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801c18:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  801c1d:	39 c1                	cmp    %eax,%ecx
  801c1f:	74 21                	je     801c42 <ipc_find_env+0x31>
  801c21:	ba 01 00 00 00       	mov    $0x1,%edx
  801c26:	8d 1c 95 00 00 00 00 	lea    0x0(,%edx,4),%ebx
  801c2d:	89 d0                	mov    %edx,%eax
  801c2f:	c1 e0 07             	shl    $0x7,%eax
  801c32:	29 d8                	sub    %ebx,%eax
  801c34:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801c39:	8b 40 50             	mov    0x50(%eax),%eax
  801c3c:	39 c8                	cmp    %ecx,%eax
  801c3e:	75 1b                	jne    801c5b <ipc_find_env+0x4a>
  801c40:	eb 05                	jmp    801c47 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801c42:	ba 00 00 00 00       	mov    $0x0,%edx
		if (envs[i].env_type == type)
			return envs[i].env_id;
  801c47:	8d 04 95 00 00 00 00 	lea    0x0(,%edx,4),%eax
  801c4e:	c1 e2 07             	shl    $0x7,%edx
  801c51:	29 c2                	sub    %eax,%edx
  801c53:	8b 82 48 00 c0 ee    	mov    -0x113fffb8(%edx),%eax
  801c59:	eb 0e                	jmp    801c69 <ipc_find_env+0x58>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801c5b:	42                   	inc    %edx
  801c5c:	81 fa 00 04 00 00    	cmp    $0x400,%edx
  801c62:	75 c2                	jne    801c26 <ipc_find_env+0x15>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801c64:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c69:	5b                   	pop    %ebx
  801c6a:	5d                   	pop    %ebp
  801c6b:	c3                   	ret    

00801c6c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801c6c:	55                   	push   %ebp
  801c6d:	89 e5                	mov    %esp,%ebp
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c6f:	8b 45 08             	mov    0x8(%ebp),%eax
  801c72:	c1 e8 16             	shr    $0x16,%eax
  801c75:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801c7c:	a8 01                	test   $0x1,%al
  801c7e:	74 21                	je     801ca1 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801c80:	8b 45 08             	mov    0x8(%ebp),%eax
  801c83:	c1 e8 0c             	shr    $0xc,%eax
  801c86:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801c8d:	a8 01                	test   $0x1,%al
  801c8f:	74 17                	je     801ca8 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801c91:	c1 e8 0c             	shr    $0xc,%eax
  801c94:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801c9b:	ef 
  801c9c:	0f b7 c0             	movzwl %ax,%eax
  801c9f:	eb 0c                	jmp    801cad <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801ca1:	b8 00 00 00 00       	mov    $0x0,%eax
  801ca6:	eb 05                	jmp    801cad <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801ca8:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801cad:	5d                   	pop    %ebp
  801cae:	c3                   	ret    
  801caf:	90                   	nop

00801cb0 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801cb0:	55                   	push   %ebp
  801cb1:	57                   	push   %edi
  801cb2:	56                   	push   %esi
  801cb3:	53                   	push   %ebx
  801cb4:	83 ec 1c             	sub    $0x1c,%esp
  801cb7:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801cbb:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801cbf:	8b 7c 24 38          	mov    0x38(%esp),%edi
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801cc3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801cc7:	89 ca                	mov    %ecx,%edx
  const DWunion dd = {.ll = d};
  801cc9:	89 f8                	mov    %edi,%eax
  801ccb:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801ccf:	85 f6                	test   %esi,%esi
  801cd1:	75 2d                	jne    801d00 <__udivdi3+0x50>
    {
      if (d0 > n1)
  801cd3:	39 cf                	cmp    %ecx,%edi
  801cd5:	77 65                	ja     801d3c <__udivdi3+0x8c>
  801cd7:	89 fd                	mov    %edi,%ebp
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801cd9:	85 ff                	test   %edi,%edi
  801cdb:	75 0b                	jne    801ce8 <__udivdi3+0x38>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801cdd:	b8 01 00 00 00       	mov    $0x1,%eax
  801ce2:	31 d2                	xor    %edx,%edx
  801ce4:	f7 f7                	div    %edi
  801ce6:	89 c5                	mov    %eax,%ebp

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801ce8:	31 d2                	xor    %edx,%edx
  801cea:	89 c8                	mov    %ecx,%eax
  801cec:	f7 f5                	div    %ebp
  801cee:	89 c1                	mov    %eax,%ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801cf0:	89 d8                	mov    %ebx,%eax
  801cf2:	f7 f5                	div    %ebp
  801cf4:	89 cf                	mov    %ecx,%edi
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801cf6:	89 fa                	mov    %edi,%edx
  801cf8:	83 c4 1c             	add    $0x1c,%esp
  801cfb:	5b                   	pop    %ebx
  801cfc:	5e                   	pop    %esi
  801cfd:	5f                   	pop    %edi
  801cfe:	5d                   	pop    %ebp
  801cff:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801d00:	39 ce                	cmp    %ecx,%esi
  801d02:	77 28                	ja     801d2c <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801d04:	0f bd fe             	bsr    %esi,%edi
	  if (bm == 0)
  801d07:	83 f7 1f             	xor    $0x1f,%edi
  801d0a:	75 40                	jne    801d4c <__udivdi3+0x9c>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801d0c:	39 ce                	cmp    %ecx,%esi
  801d0e:	72 0a                	jb     801d1a <__udivdi3+0x6a>
  801d10:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801d14:	0f 87 9e 00 00 00    	ja     801db8 <__udivdi3+0x108>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801d1a:	b8 01 00 00 00       	mov    $0x1,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801d1f:	89 fa                	mov    %edi,%edx
  801d21:	83 c4 1c             	add    $0x1c,%esp
  801d24:	5b                   	pop    %ebx
  801d25:	5e                   	pop    %esi
  801d26:	5f                   	pop    %edi
  801d27:	5d                   	pop    %ebp
  801d28:	c3                   	ret    
  801d29:	8d 76 00             	lea    0x0(%esi),%esi
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801d2c:	31 ff                	xor    %edi,%edi
  801d2e:	31 c0                	xor    %eax,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801d30:	89 fa                	mov    %edi,%edx
  801d32:	83 c4 1c             	add    $0x1c,%esp
  801d35:	5b                   	pop    %ebx
  801d36:	5e                   	pop    %esi
  801d37:	5f                   	pop    %edi
  801d38:	5d                   	pop    %ebp
  801d39:	c3                   	ret    
  801d3a:	66 90                	xchg   %ax,%ax
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801d3c:	89 d8                	mov    %ebx,%eax
  801d3e:	f7 f7                	div    %edi
  801d40:	31 ff                	xor    %edi,%edi
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801d42:	89 fa                	mov    %edi,%edx
  801d44:	83 c4 1c             	add    $0x1c,%esp
  801d47:	5b                   	pop    %ebx
  801d48:	5e                   	pop    %esi
  801d49:	5f                   	pop    %edi
  801d4a:	5d                   	pop    %ebp
  801d4b:	c3                   	ret    
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801d4c:	bd 20 00 00 00       	mov    $0x20,%ebp
  801d51:	89 eb                	mov    %ebp,%ebx
  801d53:	29 fb                	sub    %edi,%ebx

	      d1 = (d1 << bm) | (d0 >> b);
  801d55:	89 f9                	mov    %edi,%ecx
  801d57:	d3 e6                	shl    %cl,%esi
  801d59:	89 c5                	mov    %eax,%ebp
  801d5b:	88 d9                	mov    %bl,%cl
  801d5d:	d3 ed                	shr    %cl,%ebp
  801d5f:	89 e9                	mov    %ebp,%ecx
  801d61:	09 f1                	or     %esi,%ecx
  801d63:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
	      d0 = d0 << bm;
  801d67:	89 f9                	mov    %edi,%ecx
  801d69:	d3 e0                	shl    %cl,%eax
  801d6b:	89 c5                	mov    %eax,%ebp
	      n2 = n1 >> b;
  801d6d:	89 d6                	mov    %edx,%esi
  801d6f:	88 d9                	mov    %bl,%cl
  801d71:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
  801d73:	89 f9                	mov    %edi,%ecx
  801d75:	d3 e2                	shl    %cl,%edx
  801d77:	8b 44 24 08          	mov    0x8(%esp),%eax
  801d7b:	88 d9                	mov    %bl,%cl
  801d7d:	d3 e8                	shr    %cl,%eax
  801d7f:	09 c2                	or     %eax,%edx
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801d81:	89 d0                	mov    %edx,%eax
  801d83:	89 f2                	mov    %esi,%edx
  801d85:	f7 74 24 0c          	divl   0xc(%esp)
  801d89:	89 d6                	mov    %edx,%esi
  801d8b:	89 c3                	mov    %eax,%ebx
	      umul_ppmm (m1, m0, q0, d0);
  801d8d:	f7 e5                	mul    %ebp

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801d8f:	39 d6                	cmp    %edx,%esi
  801d91:	72 19                	jb     801dac <__udivdi3+0xfc>
  801d93:	74 0b                	je     801da0 <__udivdi3+0xf0>
  801d95:	89 d8                	mov    %ebx,%eax
  801d97:	31 ff                	xor    %edi,%edi
  801d99:	e9 58 ff ff ff       	jmp    801cf6 <__udivdi3+0x46>
  801d9e:	66 90                	xchg   %ax,%ax
  801da0:	8b 54 24 08          	mov    0x8(%esp),%edx
  801da4:	89 f9                	mov    %edi,%ecx
  801da6:	d3 e2                	shl    %cl,%edx
  801da8:	39 c2                	cmp    %eax,%edx
  801daa:	73 e9                	jae    801d95 <__udivdi3+0xe5>
  801dac:	8d 43 ff             	lea    -0x1(%ebx),%eax
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801daf:	31 ff                	xor    %edi,%edi
  801db1:	e9 40 ff ff ff       	jmp    801cf6 <__udivdi3+0x46>
  801db6:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801db8:	31 c0                	xor    %eax,%eax
  801dba:	e9 37 ff ff ff       	jmp    801cf6 <__udivdi3+0x46>
  801dbf:	90                   	nop

00801dc0 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  801dc0:	55                   	push   %ebp
  801dc1:	57                   	push   %edi
  801dc2:	56                   	push   %esi
  801dc3:	53                   	push   %ebx
  801dc4:	83 ec 1c             	sub    $0x1c,%esp
  801dc7:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801dcb:	8b 74 24 34          	mov    0x34(%esp),%esi
  801dcf:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801dd3:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801dd7:	89 44 24 0c          	mov    %eax,0xc(%esp)
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801ddb:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801ddf:	89 f3                	mov    %esi,%ebx
  const DWunion dd = {.ll = d};
  801de1:	89 fa                	mov    %edi,%edx
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  801de3:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  n1 = nn.s.high;
  801de7:	89 34 24             	mov    %esi,(%esp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801dea:	85 c0                	test   %eax,%eax
  801dec:	75 1a                	jne    801e08 <__umoddi3+0x48>
    {
      if (d0 > n1)
  801dee:	39 f7                	cmp    %esi,%edi
  801df0:	0f 86 a2 00 00 00    	jbe    801e98 <__umoddi3+0xd8>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801df6:	89 c8                	mov    %ecx,%eax
  801df8:	89 f2                	mov    %esi,%edx
  801dfa:	f7 f7                	div    %edi
  801dfc:	89 d0                	mov    %edx,%eax

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  801dfe:	31 d2                	xor    %edx,%edx
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
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801e08:	39 f0                	cmp    %esi,%eax
  801e0a:	0f 87 ac 00 00 00    	ja     801ebc <__umoddi3+0xfc>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801e10:	0f bd e8             	bsr    %eax,%ebp
	  if (bm == 0)
  801e13:	83 f5 1f             	xor    $0x1f,%ebp
  801e16:	0f 84 ac 00 00 00    	je     801ec8 <__umoddi3+0x108>
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801e1c:	bf 20 00 00 00       	mov    $0x20,%edi
  801e21:	29 ef                	sub    %ebp,%edi
  801e23:	89 fe                	mov    %edi,%esi
  801e25:	89 7c 24 0c          	mov    %edi,0xc(%esp)

	      d1 = (d1 << bm) | (d0 >> b);
  801e29:	89 e9                	mov    %ebp,%ecx
  801e2b:	d3 e0                	shl    %cl,%eax
  801e2d:	89 d7                	mov    %edx,%edi
  801e2f:	89 f1                	mov    %esi,%ecx
  801e31:	d3 ef                	shr    %cl,%edi
  801e33:	09 c7                	or     %eax,%edi
	      d0 = d0 << bm;
  801e35:	89 e9                	mov    %ebp,%ecx
  801e37:	d3 e2                	shl    %cl,%edx
  801e39:	89 14 24             	mov    %edx,(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801e3c:	89 d8                	mov    %ebx,%eax
  801e3e:	d3 e0                	shl    %cl,%eax
  801e40:	89 c2                	mov    %eax,%edx
	      n0 = n0 << bm;
  801e42:	8b 44 24 08          	mov    0x8(%esp),%eax
  801e46:	d3 e0                	shl    %cl,%eax
  801e48:	89 44 24 04          	mov    %eax,0x4(%esp)

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801e4c:	8b 44 24 08          	mov    0x8(%esp),%eax
  801e50:	89 f1                	mov    %esi,%ecx
  801e52:	d3 e8                	shr    %cl,%eax
  801e54:	09 d0                	or     %edx,%eax
  801e56:	d3 eb                	shr    %cl,%ebx
  801e58:	89 da                	mov    %ebx,%edx
  801e5a:	f7 f7                	div    %edi
  801e5c:	89 d3                	mov    %edx,%ebx
	      umul_ppmm (m1, m0, q0, d0);
  801e5e:	f7 24 24             	mull   (%esp)
  801e61:	89 c6                	mov    %eax,%esi
  801e63:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801e65:	39 d3                	cmp    %edx,%ebx
  801e67:	0f 82 87 00 00 00    	jb     801ef4 <__umoddi3+0x134>
  801e6d:	0f 84 91 00 00 00    	je     801f04 <__umoddi3+0x144>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  801e73:	8b 54 24 04          	mov    0x4(%esp),%edx
  801e77:	29 f2                	sub    %esi,%edx
  801e79:	19 cb                	sbb    %ecx,%ebx
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801e7b:	89 d8                	mov    %ebx,%eax
  801e7d:	8a 4c 24 0c          	mov    0xc(%esp),%cl
  801e81:	d3 e0                	shl    %cl,%eax
  801e83:	89 e9                	mov    %ebp,%ecx
  801e85:	d3 ea                	shr    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  801e87:	09 d0                	or     %edx,%eax
  801e89:	89 e9                	mov    %ebp,%ecx
  801e8b:	d3 eb                	shr    %cl,%ebx
  801e8d:	89 da                	mov    %ebx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801e8f:	83 c4 1c             	add    $0x1c,%esp
  801e92:	5b                   	pop    %ebx
  801e93:	5e                   	pop    %esi
  801e94:	5f                   	pop    %edi
  801e95:	5d                   	pop    %ebp
  801e96:	c3                   	ret    
  801e97:	90                   	nop
  801e98:	89 fd                	mov    %edi,%ebp
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801e9a:	85 ff                	test   %edi,%edi
  801e9c:	75 0b                	jne    801ea9 <__umoddi3+0xe9>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801e9e:	b8 01 00 00 00       	mov    $0x1,%eax
  801ea3:	31 d2                	xor    %edx,%edx
  801ea5:	f7 f7                	div    %edi
  801ea7:	89 c5                	mov    %eax,%ebp

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801ea9:	89 f0                	mov    %esi,%eax
  801eab:	31 d2                	xor    %edx,%edx
  801ead:	f7 f5                	div    %ebp
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801eaf:	89 c8                	mov    %ecx,%eax
  801eb1:	f7 f5                	div    %ebp
  801eb3:	89 d0                	mov    %edx,%eax
  801eb5:	e9 44 ff ff ff       	jmp    801dfe <__umoddi3+0x3e>
  801eba:	66 90                	xchg   %ax,%ax
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  801ebc:	89 c8                	mov    %ecx,%eax
  801ebe:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801ec0:	83 c4 1c             	add    $0x1c,%esp
  801ec3:	5b                   	pop    %ebx
  801ec4:	5e                   	pop    %esi
  801ec5:	5f                   	pop    %edi
  801ec6:	5d                   	pop    %ebp
  801ec7:	c3                   	ret    

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801ec8:	3b 04 24             	cmp    (%esp),%eax
  801ecb:	72 06                	jb     801ed3 <__umoddi3+0x113>
  801ecd:	3b 7c 24 04          	cmp    0x4(%esp),%edi
  801ed1:	77 0f                	ja     801ee2 <__umoddi3+0x122>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801ed3:	89 f2                	mov    %esi,%edx
  801ed5:	29 f9                	sub    %edi,%ecx
  801ed7:	1b 54 24 0c          	sbb    0xc(%esp),%edx
  801edb:	89 14 24             	mov    %edx,(%esp)
  801ede:	89 4c 24 04          	mov    %ecx,0x4(%esp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  801ee2:	8b 44 24 04          	mov    0x4(%esp),%eax
  801ee6:	8b 14 24             	mov    (%esp),%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801ee9:	83 c4 1c             	add    $0x1c,%esp
  801eec:	5b                   	pop    %ebx
  801eed:	5e                   	pop    %esi
  801eee:	5f                   	pop    %edi
  801eef:	5d                   	pop    %ebp
  801ef0:	c3                   	ret    
  801ef1:	8d 76 00             	lea    0x0(%esi),%esi
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801ef4:	2b 04 24             	sub    (%esp),%eax
  801ef7:	19 fa                	sbb    %edi,%edx
  801ef9:	89 d1                	mov    %edx,%ecx
  801efb:	89 c6                	mov    %eax,%esi
  801efd:	e9 71 ff ff ff       	jmp    801e73 <__umoddi3+0xb3>
  801f02:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801f04:	39 44 24 04          	cmp    %eax,0x4(%esp)
  801f08:	72 ea                	jb     801ef4 <__umoddi3+0x134>
  801f0a:	89 d9                	mov    %ebx,%ecx
  801f0c:	e9 62 ff ff ff       	jmp    801e73 <__umoddi3+0xb3>
