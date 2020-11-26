
obj/user/spawnhello.debug:     file format elf32-i386


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
  80002c:	e8 4a 00 00 00       	call   80007b <libmain>
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
	int r;
	cprintf("i am parent environment %08x\n", thisenv->env_id);
  800039:	a1 04 40 80 00       	mov    0x804004,%eax
  80003e:	8b 40 48             	mov    0x48(%eax),%eax
  800041:	50                   	push   %eax
  800042:	68 20 24 80 00       	push   $0x802420
  800047:	e8 70 01 00 00       	call   8001bc <cprintf>
	if ((r = spawnl("hello", "hello", 0)) < 0)
  80004c:	83 c4 0c             	add    $0xc,%esp
  80004f:	6a 00                	push   $0x0
  800051:	68 3e 24 80 00       	push   $0x80243e
  800056:	68 3e 24 80 00       	push   $0x80243e
  80005b:	e8 48 1a 00 00       	call   801aa8 <spawnl>
  800060:	83 c4 10             	add    $0x10,%esp
  800063:	85 c0                	test   %eax,%eax
  800065:	79 12                	jns    800079 <umain+0x46>
		panic("spawn(hello) failed: %e", r);
  800067:	50                   	push   %eax
  800068:	68 44 24 80 00       	push   $0x802444
  80006d:	6a 09                	push   $0x9
  80006f:	68 5c 24 80 00       	push   $0x80245c
  800074:	e8 6b 00 00 00       	call   8000e4 <_panic>
}
  800079:	c9                   	leave  
  80007a:	c3                   	ret    

0080007b <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80007b:	55                   	push   %ebp
  80007c:	89 e5                	mov    %esp,%ebp
  80007e:	56                   	push   %esi
  80007f:	53                   	push   %ebx
  800080:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800083:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800086:	e8 48 0b 00 00       	call   800bd3 <sys_getenvid>
  80008b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800090:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800097:	c1 e0 07             	shl    $0x7,%eax
  80009a:	29 d0                	sub    %edx,%eax
  80009c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000a1:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000a6:	85 db                	test   %ebx,%ebx
  8000a8:	7e 07                	jle    8000b1 <libmain+0x36>
		binaryname = argv[0];
  8000aa:	8b 06                	mov    (%esi),%eax
  8000ac:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000b1:	83 ec 08             	sub    $0x8,%esp
  8000b4:	56                   	push   %esi
  8000b5:	53                   	push   %ebx
  8000b6:	e8 78 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000bb:	e8 0a 00 00 00       	call   8000ca <exit>
}
  8000c0:	83 c4 10             	add    $0x10,%esp
  8000c3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000c6:	5b                   	pop    %ebx
  8000c7:	5e                   	pop    %esi
  8000c8:	5d                   	pop    %ebp
  8000c9:	c3                   	ret    

008000ca <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000ca:	55                   	push   %ebp
  8000cb:	89 e5                	mov    %esp,%ebp
  8000cd:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000d0:	e8 3c 0f 00 00       	call   801011 <close_all>
	sys_env_destroy(0);
  8000d5:	83 ec 0c             	sub    $0xc,%esp
  8000d8:	6a 00                	push   $0x0
  8000da:	e8 b3 0a 00 00       	call   800b92 <sys_env_destroy>
}
  8000df:	83 c4 10             	add    $0x10,%esp
  8000e2:	c9                   	leave  
  8000e3:	c3                   	ret    

008000e4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8000e4:	55                   	push   %ebp
  8000e5:	89 e5                	mov    %esp,%ebp
  8000e7:	56                   	push   %esi
  8000e8:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8000e9:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8000ec:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8000f2:	e8 dc 0a 00 00       	call   800bd3 <sys_getenvid>
  8000f7:	83 ec 0c             	sub    $0xc,%esp
  8000fa:	ff 75 0c             	pushl  0xc(%ebp)
  8000fd:	ff 75 08             	pushl  0x8(%ebp)
  800100:	56                   	push   %esi
  800101:	50                   	push   %eax
  800102:	68 78 24 80 00       	push   $0x802478
  800107:	e8 b0 00 00 00       	call   8001bc <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80010c:	83 c4 18             	add    $0x18,%esp
  80010f:	53                   	push   %ebx
  800110:	ff 75 10             	pushl  0x10(%ebp)
  800113:	e8 53 00 00 00       	call   80016b <vcprintf>
	cprintf("\n");
  800118:	c7 04 24 30 29 80 00 	movl   $0x802930,(%esp)
  80011f:	e8 98 00 00 00       	call   8001bc <cprintf>
  800124:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800127:	cc                   	int3   
  800128:	eb fd                	jmp    800127 <_panic+0x43>

0080012a <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80012a:	55                   	push   %ebp
  80012b:	89 e5                	mov    %esp,%ebp
  80012d:	53                   	push   %ebx
  80012e:	83 ec 04             	sub    $0x4,%esp
  800131:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800134:	8b 13                	mov    (%ebx),%edx
  800136:	8d 42 01             	lea    0x1(%edx),%eax
  800139:	89 03                	mov    %eax,(%ebx)
  80013b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80013e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800142:	3d ff 00 00 00       	cmp    $0xff,%eax
  800147:	75 1a                	jne    800163 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800149:	83 ec 08             	sub    $0x8,%esp
  80014c:	68 ff 00 00 00       	push   $0xff
  800151:	8d 43 08             	lea    0x8(%ebx),%eax
  800154:	50                   	push   %eax
  800155:	e8 fb 09 00 00       	call   800b55 <sys_cputs>
		b->idx = 0;
  80015a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800160:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800163:	ff 43 04             	incl   0x4(%ebx)
}
  800166:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800169:	c9                   	leave  
  80016a:	c3                   	ret    

0080016b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80016b:	55                   	push   %ebp
  80016c:	89 e5                	mov    %esp,%ebp
  80016e:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800174:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80017b:	00 00 00 
	b.cnt = 0;
  80017e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800185:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800188:	ff 75 0c             	pushl  0xc(%ebp)
  80018b:	ff 75 08             	pushl  0x8(%ebp)
  80018e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800194:	50                   	push   %eax
  800195:	68 2a 01 80 00       	push   $0x80012a
  80019a:	e8 54 01 00 00       	call   8002f3 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80019f:	83 c4 08             	add    $0x8,%esp
  8001a2:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001a8:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001ae:	50                   	push   %eax
  8001af:	e8 a1 09 00 00       	call   800b55 <sys_cputs>

	return b.cnt;
}
  8001b4:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001ba:	c9                   	leave  
  8001bb:	c3                   	ret    

008001bc <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001bc:	55                   	push   %ebp
  8001bd:	89 e5                	mov    %esp,%ebp
  8001bf:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001c2:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001c5:	50                   	push   %eax
  8001c6:	ff 75 08             	pushl  0x8(%ebp)
  8001c9:	e8 9d ff ff ff       	call   80016b <vcprintf>
	va_end(ap);

	return cnt;
}
  8001ce:	c9                   	leave  
  8001cf:	c3                   	ret    

008001d0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001d0:	55                   	push   %ebp
  8001d1:	89 e5                	mov    %esp,%ebp
  8001d3:	57                   	push   %edi
  8001d4:	56                   	push   %esi
  8001d5:	53                   	push   %ebx
  8001d6:	83 ec 1c             	sub    $0x1c,%esp
  8001d9:	89 c6                	mov    %eax,%esi
  8001db:	89 d7                	mov    %edx,%edi
  8001dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8001e0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001e3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001e6:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001e9:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001ec:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001f1:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001f4:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001f7:	39 d3                	cmp    %edx,%ebx
  8001f9:	72 11                	jb     80020c <printnum+0x3c>
  8001fb:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001fe:	76 0c                	jbe    80020c <printnum+0x3c>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800200:	8b 45 14             	mov    0x14(%ebp),%eax
  800203:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800206:	85 db                	test   %ebx,%ebx
  800208:	7f 37                	jg     800241 <printnum+0x71>
  80020a:	eb 44                	jmp    800250 <printnum+0x80>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80020c:	83 ec 0c             	sub    $0xc,%esp
  80020f:	ff 75 18             	pushl  0x18(%ebp)
  800212:	8b 45 14             	mov    0x14(%ebp),%eax
  800215:	48                   	dec    %eax
  800216:	50                   	push   %eax
  800217:	ff 75 10             	pushl  0x10(%ebp)
  80021a:	83 ec 08             	sub    $0x8,%esp
  80021d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800220:	ff 75 e0             	pushl  -0x20(%ebp)
  800223:	ff 75 dc             	pushl  -0x24(%ebp)
  800226:	ff 75 d8             	pushl  -0x28(%ebp)
  800229:	e8 72 1f 00 00       	call   8021a0 <__udivdi3>
  80022e:	83 c4 18             	add    $0x18,%esp
  800231:	52                   	push   %edx
  800232:	50                   	push   %eax
  800233:	89 fa                	mov    %edi,%edx
  800235:	89 f0                	mov    %esi,%eax
  800237:	e8 94 ff ff ff       	call   8001d0 <printnum>
  80023c:	83 c4 20             	add    $0x20,%esp
  80023f:	eb 0f                	jmp    800250 <printnum+0x80>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800241:	83 ec 08             	sub    $0x8,%esp
  800244:	57                   	push   %edi
  800245:	ff 75 18             	pushl  0x18(%ebp)
  800248:	ff d6                	call   *%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80024a:	83 c4 10             	add    $0x10,%esp
  80024d:	4b                   	dec    %ebx
  80024e:	75 f1                	jne    800241 <printnum+0x71>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800250:	83 ec 08             	sub    $0x8,%esp
  800253:	57                   	push   %edi
  800254:	83 ec 04             	sub    $0x4,%esp
  800257:	ff 75 e4             	pushl  -0x1c(%ebp)
  80025a:	ff 75 e0             	pushl  -0x20(%ebp)
  80025d:	ff 75 dc             	pushl  -0x24(%ebp)
  800260:	ff 75 d8             	pushl  -0x28(%ebp)
  800263:	e8 48 20 00 00       	call   8022b0 <__umoddi3>
  800268:	83 c4 14             	add    $0x14,%esp
  80026b:	0f be 80 9b 24 80 00 	movsbl 0x80249b(%eax),%eax
  800272:	50                   	push   %eax
  800273:	ff d6                	call   *%esi
}
  800275:	83 c4 10             	add    $0x10,%esp
  800278:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80027b:	5b                   	pop    %ebx
  80027c:	5e                   	pop    %esi
  80027d:	5f                   	pop    %edi
  80027e:	5d                   	pop    %ebp
  80027f:	c3                   	ret    

00800280 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800280:	55                   	push   %ebp
  800281:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800283:	83 fa 01             	cmp    $0x1,%edx
  800286:	7e 0e                	jle    800296 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800288:	8b 10                	mov    (%eax),%edx
  80028a:	8d 4a 08             	lea    0x8(%edx),%ecx
  80028d:	89 08                	mov    %ecx,(%eax)
  80028f:	8b 02                	mov    (%edx),%eax
  800291:	8b 52 04             	mov    0x4(%edx),%edx
  800294:	eb 22                	jmp    8002b8 <getuint+0x38>
	else if (lflag)
  800296:	85 d2                	test   %edx,%edx
  800298:	74 10                	je     8002aa <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80029a:	8b 10                	mov    (%eax),%edx
  80029c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80029f:	89 08                	mov    %ecx,(%eax)
  8002a1:	8b 02                	mov    (%edx),%eax
  8002a3:	ba 00 00 00 00       	mov    $0x0,%edx
  8002a8:	eb 0e                	jmp    8002b8 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002aa:	8b 10                	mov    (%eax),%edx
  8002ac:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002af:	89 08                	mov    %ecx,(%eax)
  8002b1:	8b 02                	mov    (%edx),%eax
  8002b3:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002b8:	5d                   	pop    %ebp
  8002b9:	c3                   	ret    

008002ba <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002ba:	55                   	push   %ebp
  8002bb:	89 e5                	mov    %esp,%ebp
  8002bd:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002c0:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8002c3:	8b 10                	mov    (%eax),%edx
  8002c5:	3b 50 04             	cmp    0x4(%eax),%edx
  8002c8:	73 0a                	jae    8002d4 <sprintputch+0x1a>
		*b->buf++ = ch;
  8002ca:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002cd:	89 08                	mov    %ecx,(%eax)
  8002cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8002d2:	88 02                	mov    %al,(%edx)
}
  8002d4:	5d                   	pop    %ebp
  8002d5:	c3                   	ret    

008002d6 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002d6:	55                   	push   %ebp
  8002d7:	89 e5                	mov    %esp,%ebp
  8002d9:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002dc:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002df:	50                   	push   %eax
  8002e0:	ff 75 10             	pushl  0x10(%ebp)
  8002e3:	ff 75 0c             	pushl  0xc(%ebp)
  8002e6:	ff 75 08             	pushl  0x8(%ebp)
  8002e9:	e8 05 00 00 00       	call   8002f3 <vprintfmt>
	va_end(ap);
}
  8002ee:	83 c4 10             	add    $0x10,%esp
  8002f1:	c9                   	leave  
  8002f2:	c3                   	ret    

008002f3 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002f3:	55                   	push   %ebp
  8002f4:	89 e5                	mov    %esp,%ebp
  8002f6:	57                   	push   %edi
  8002f7:	56                   	push   %esi
  8002f8:	53                   	push   %ebx
  8002f9:	83 ec 2c             	sub    $0x2c,%esp
  8002fc:	8b 7d 08             	mov    0x8(%ebp),%edi
  8002ff:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800302:	eb 03                	jmp    800307 <vprintfmt+0x14>
			break;

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
			for (fmt--; fmt[-1] != '%'; fmt--)
  800304:	89 75 10             	mov    %esi,0x10(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {    //遍历输入的第一个参数，即输出信息的格式，先把格式字符串中'%'之前的字符一个个输出，因为它们前面没有'%'，所以它们就是要直接显示在屏幕上的
  800307:	8b 45 10             	mov    0x10(%ebp),%eax
  80030a:	8d 70 01             	lea    0x1(%eax),%esi
  80030d:	0f b6 00             	movzbl (%eax),%eax
  800310:	83 f8 25             	cmp    $0x25,%eax
  800313:	74 25                	je     80033a <vprintfmt+0x47>
			if (ch == '\0')									//当然中间如果遇到'\0'，代表这个字符串的访问结束
  800315:	85 c0                	test   %eax,%eax
  800317:	75 0d                	jne    800326 <vprintfmt+0x33>
  800319:	e9 b5 03 00 00       	jmp    8006d3 <vprintfmt+0x3e0>
  80031e:	85 c0                	test   %eax,%eax
  800320:	0f 84 ad 03 00 00    	je     8006d3 <vprintfmt+0x3e0>
				return;
			putch(ch, putdat);								//调用putch函数，把一个字符ch输出到putdat指针所指向的地址中所存放的值对应的地址处
  800326:	83 ec 08             	sub    $0x8,%esp
  800329:	53                   	push   %ebx
  80032a:	50                   	push   %eax
  80032b:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {    //遍历输入的第一个参数，即输出信息的格式，先把格式字符串中'%'之前的字符一个个输出，因为它们前面没有'%'，所以它们就是要直接显示在屏幕上的
  80032d:	46                   	inc    %esi
  80032e:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  800332:	83 c4 10             	add    $0x10,%esp
  800335:	83 f8 25             	cmp    $0x25,%eax
  800338:	75 e4                	jne    80031e <vprintfmt+0x2b>
			if (width < 0)									//代表有小数点，但是小数点前面并没有数字，比如'%.6f'这种情况，此时代表整数部分全部显示
				width = 0;			
			goto reswitch;

		case '#':
			altflag = 1;
  80033a:	c6 45 e3 20          	movb   $0x20,-0x1d(%ebp)
  80033e:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800345:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80034c:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800353:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  80035a:	eb 07                	jmp    800363 <vprintfmt+0x70>
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  80035c:	8b 75 10             	mov    0x10(%ebp),%esi

		// flag to pad on the right
		case '-':											//%后面的'-'代表要进行左对齐输出，右边填空格，如果省略代表右对齐
			padc = '-';										//如果有这个字符代表左对齐，则把对齐方式标志位变为'-'
  80035f:	c6 45 e3 2d          	movb   $0x2d,-0x1d(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  800363:	8d 46 01             	lea    0x1(%esi),%eax
  800366:	89 45 10             	mov    %eax,0x10(%ebp)
  800369:	0f b6 16             	movzbl (%esi),%edx
  80036c:	8a 06                	mov    (%esi),%al
  80036e:	83 e8 23             	sub    $0x23,%eax
  800371:	3c 55                	cmp    $0x55,%al
  800373:	0f 87 03 03 00 00    	ja     80067c <vprintfmt+0x389>
  800379:	0f b6 c0             	movzbl %al,%eax
  80037c:	ff 24 85 e0 25 80 00 	jmp    *0x8025e0(,%eax,4)
  800383:	8b 75 10             	mov    0x10(%ebp),%esi
			padc = '-';										//如果有这个字符代表左对齐，则把对齐方式标志位变为'-'
			goto reswitch;									//处理下一个字符

		// flag to pad with 0's instead of spaces
		case '0':											//0--有0表示进行对齐输出时填0,如省略表示填入空格，并且如果为0，则一定是右对齐
			padc = '0';										//对其方式标志位变为0
  800386:	c6 45 e3 30          	movb   $0x30,-0x1d(%ebp)
  80038a:	eb d7                	jmp    800363 <vprintfmt+0x70>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {					//把遇到的位数字符串转换为真实的位数，比如输入的'%40'，代表有效位数为40位，下面的循环就是把precesion的值设置为40
				precision = precision * 10 + ch - '0';
  80038c:	8d 42 d0             	lea    -0x30(%edx),%eax
  80038f:	89 c1                	mov    %eax,%ecx
  800391:	89 45 d0             	mov    %eax,-0x30(%ebp)
				ch = *fmt;
  800394:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  800398:	8d 50 d0             	lea    -0x30(%eax),%edx
  80039b:	83 fa 09             	cmp    $0x9,%edx
  80039e:	77 51                	ja     8003f1 <vprintfmt+0xfe>
  8003a0:	8b 75 10             	mov    0x10(%ebp),%esi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {					//把遇到的位数字符串转换为真实的位数，比如输入的'%40'，代表有效位数为40位，下面的循环就是把precesion的值设置为40
  8003a3:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  8003a4:	8d 14 89             	lea    (%ecx,%ecx,4),%edx
  8003a7:	01 d2                	add    %edx,%edx
  8003a9:	8d 4c 10 d0          	lea    -0x30(%eax,%edx,1),%ecx
				ch = *fmt;
  8003ad:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8003b0:	8d 50 d0             	lea    -0x30(%eax),%edx
  8003b3:	83 fa 09             	cmp    $0x9,%edx
  8003b6:	76 eb                	jbe    8003a3 <vprintfmt+0xb0>
  8003b8:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8003bb:	eb 37                	jmp    8003f4 <vprintfmt+0x101>
					break;
			}
			goto process_precision;							//跳转到process_precistion子过程

		case '*':											//*--代表有效数字的位数也是由输入参数指定的，比如printf("%*.*f", 10, 2, n)，其中10,2就是用来指定显示的有效数字位数的
			precision = va_arg(ap, int);
  8003bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c0:	8d 50 04             	lea    0x4(%eax),%edx
  8003c3:	89 55 14             	mov    %edx,0x14(%ebp)
  8003c6:	8b 00                	mov    (%eax),%eax
  8003c8:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  8003cb:	8b 75 10             	mov    0x10(%ebp),%esi
			}
			goto process_precision;							//跳转到process_precistion子过程

		case '*':											//*--代表有效数字的位数也是由输入参数指定的，比如printf("%*.*f", 10, 2, n)，其中10,2就是用来指定显示的有效数字位数的
			precision = va_arg(ap, int);
			goto process_precision;
  8003ce:	eb 24                	jmp    8003f4 <vprintfmt+0x101>
  8003d0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003d4:	79 07                	jns    8003dd <vprintfmt+0xea>
  8003d6:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  8003dd:	8b 75 10             	mov    0x10(%ebp),%esi
  8003e0:	eb 81                	jmp    800363 <vprintfmt+0x70>
  8003e2:	8b 75 10             	mov    0x10(%ebp),%esi
			if (width < 0)									//代表有小数点，但是小数点前面并没有数字，比如'%.6f'这种情况，此时代表整数部分全部显示
				width = 0;			
			goto reswitch;

		case '#':
			altflag = 1;
  8003e5:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003ec:	e9 72 ff ff ff       	jmp    800363 <vprintfmt+0x70>
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  8003f1:	8b 75 10             	mov    0x10(%ebp),%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:									//处理输出精度，把width字段赋值为刚刚计算出来的precision值，所以width应该是整数部分的有效数字位数
			if (width < 0)
  8003f4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003f8:	0f 89 65 ff ff ff    	jns    800363 <vprintfmt+0x70>
				width = precision, precision = -1;
  8003fe:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800401:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800404:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80040b:	e9 53 ff ff ff       	jmp    800363 <vprintfmt+0x70>
			goto reswitch;

		// long flag (doubled for long long)				
		case 'l':											//如果遇到'l'，代表应该是输入long类型，如果有两个'l'代表long long
			lflag++;										//此时把lflag++
  800410:	ff 45 d4             	incl   -0x2c(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  800413:	8b 75 10             	mov    0x10(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)				
		case 'l':											//如果遇到'l'，代表应该是输入long类型，如果有两个'l'代表long long
			lflag++;										//此时把lflag++
			goto reswitch;
  800416:	e9 48 ff ff ff       	jmp    800363 <vprintfmt+0x70>

		// character
		case 'c':											//如果是'c'代表显示一个字符
			putch(va_arg(ap, int), putdat);					//调用输出一个字符到内存的函数putch
  80041b:	8b 45 14             	mov    0x14(%ebp),%eax
  80041e:	8d 50 04             	lea    0x4(%eax),%edx
  800421:	89 55 14             	mov    %edx,0x14(%ebp)
  800424:	83 ec 08             	sub    $0x8,%esp
  800427:	53                   	push   %ebx
  800428:	ff 30                	pushl  (%eax)
  80042a:	ff d7                	call   *%edi
			break;
  80042c:	83 c4 10             	add    $0x10,%esp
  80042f:	e9 d3 fe ff ff       	jmp    800307 <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800434:	8b 45 14             	mov    0x14(%ebp),%eax
  800437:	8d 50 04             	lea    0x4(%eax),%edx
  80043a:	89 55 14             	mov    %edx,0x14(%ebp)
  80043d:	8b 00                	mov    (%eax),%eax
  80043f:	85 c0                	test   %eax,%eax
  800441:	79 02                	jns    800445 <vprintfmt+0x152>
  800443:	f7 d8                	neg    %eax
  800445:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800447:	83 f8 0f             	cmp    $0xf,%eax
  80044a:	7f 0b                	jg     800457 <vprintfmt+0x164>
  80044c:	8b 04 85 40 27 80 00 	mov    0x802740(,%eax,4),%eax
  800453:	85 c0                	test   %eax,%eax
  800455:	75 15                	jne    80046c <vprintfmt+0x179>
				printfmt(putch, putdat, "error %d", err);
  800457:	52                   	push   %edx
  800458:	68 b3 24 80 00       	push   $0x8024b3
  80045d:	53                   	push   %ebx
  80045e:	57                   	push   %edi
  80045f:	e8 72 fe ff ff       	call   8002d6 <printfmt>
  800464:	83 c4 10             	add    $0x10,%esp
  800467:	e9 9b fe ff ff       	jmp    800307 <vprintfmt+0x14>
			else
				printfmt(putch, putdat, "%s", p);
  80046c:	50                   	push   %eax
  80046d:	68 5f 28 80 00       	push   $0x80285f
  800472:	53                   	push   %ebx
  800473:	57                   	push   %edi
  800474:	e8 5d fe ff ff       	call   8002d6 <printfmt>
  800479:	83 c4 10             	add    $0x10,%esp
  80047c:	e9 86 fe ff ff       	jmp    800307 <vprintfmt+0x14>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800481:	8b 45 14             	mov    0x14(%ebp),%eax
  800484:	8d 50 04             	lea    0x4(%eax),%edx
  800487:	89 55 14             	mov    %edx,0x14(%ebp)
  80048a:	8b 00                	mov    (%eax),%eax
  80048c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80048f:	85 c0                	test   %eax,%eax
  800491:	75 07                	jne    80049a <vprintfmt+0x1a7>
				p = "(null)";
  800493:	c7 45 d4 ac 24 80 00 	movl   $0x8024ac,-0x2c(%ebp)
			if (width > 0 && padc != '-')
  80049a:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80049d:	85 f6                	test   %esi,%esi
  80049f:	0f 8e fb 01 00 00    	jle    8006a0 <vprintfmt+0x3ad>
  8004a5:	80 7d e3 2d          	cmpb   $0x2d,-0x1d(%ebp)
  8004a9:	0f 84 09 02 00 00    	je     8006b8 <vprintfmt+0x3c5>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004af:	83 ec 08             	sub    $0x8,%esp
  8004b2:	ff 75 d0             	pushl  -0x30(%ebp)
  8004b5:	ff 75 d4             	pushl  -0x2c(%ebp)
  8004b8:	e8 ad 02 00 00       	call   80076a <strnlen>
  8004bd:	89 f1                	mov    %esi,%ecx
  8004bf:	29 c1                	sub    %eax,%ecx
  8004c1:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  8004c4:	83 c4 10             	add    $0x10,%esp
  8004c7:	85 c9                	test   %ecx,%ecx
  8004c9:	0f 8e d1 01 00 00    	jle    8006a0 <vprintfmt+0x3ad>
					putch(padc, putdat);
  8004cf:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  8004d3:	83 ec 08             	sub    $0x8,%esp
  8004d6:	53                   	push   %ebx
  8004d7:	56                   	push   %esi
  8004d8:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004da:	83 c4 10             	add    $0x10,%esp
  8004dd:	ff 4d e4             	decl   -0x1c(%ebp)
  8004e0:	75 f1                	jne    8004d3 <vprintfmt+0x1e0>
  8004e2:	e9 b9 01 00 00       	jmp    8006a0 <vprintfmt+0x3ad>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004e7:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004eb:	74 19                	je     800506 <vprintfmt+0x213>
  8004ed:	0f be c0             	movsbl %al,%eax
  8004f0:	83 e8 20             	sub    $0x20,%eax
  8004f3:	83 f8 5e             	cmp    $0x5e,%eax
  8004f6:	76 0e                	jbe    800506 <vprintfmt+0x213>
					putch('?', putdat);
  8004f8:	83 ec 08             	sub    $0x8,%esp
  8004fb:	53                   	push   %ebx
  8004fc:	6a 3f                	push   $0x3f
  8004fe:	ff 55 08             	call   *0x8(%ebp)
  800501:	83 c4 10             	add    $0x10,%esp
  800504:	eb 0b                	jmp    800511 <vprintfmt+0x21e>
				else
					putch(ch, putdat);
  800506:	83 ec 08             	sub    $0x8,%esp
  800509:	53                   	push   %ebx
  80050a:	52                   	push   %edx
  80050b:	ff 55 08             	call   *0x8(%ebp)
  80050e:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800511:	ff 4d e4             	decl   -0x1c(%ebp)
  800514:	46                   	inc    %esi
  800515:	8a 46 ff             	mov    -0x1(%esi),%al
  800518:	0f be d0             	movsbl %al,%edx
  80051b:	85 d2                	test   %edx,%edx
  80051d:	75 1c                	jne    80053b <vprintfmt+0x248>
  80051f:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800522:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800526:	7f 1f                	jg     800547 <vprintfmt+0x254>
  800528:	e9 da fd ff ff       	jmp    800307 <vprintfmt+0x14>
  80052d:	89 7d 08             	mov    %edi,0x8(%ebp)
  800530:	8b 7d d0             	mov    -0x30(%ebp),%edi
  800533:	eb 06                	jmp    80053b <vprintfmt+0x248>
  800535:	89 7d 08             	mov    %edi,0x8(%ebp)
  800538:	8b 7d d0             	mov    -0x30(%ebp),%edi
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80053b:	85 ff                	test   %edi,%edi
  80053d:	78 a8                	js     8004e7 <vprintfmt+0x1f4>
  80053f:	4f                   	dec    %edi
  800540:	79 a5                	jns    8004e7 <vprintfmt+0x1f4>
  800542:	8b 7d 08             	mov    0x8(%ebp),%edi
  800545:	eb db                	jmp    800522 <vprintfmt+0x22f>
  800547:	8b 75 e4             	mov    -0x1c(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80054a:	83 ec 08             	sub    $0x8,%esp
  80054d:	53                   	push   %ebx
  80054e:	6a 20                	push   $0x20
  800550:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800552:	4e                   	dec    %esi
  800553:	83 c4 10             	add    $0x10,%esp
  800556:	85 f6                	test   %esi,%esi
  800558:	7f f0                	jg     80054a <vprintfmt+0x257>
  80055a:	e9 a8 fd ff ff       	jmp    800307 <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80055f:	83 7d d4 01          	cmpl   $0x1,-0x2c(%ebp)
  800563:	7e 16                	jle    80057b <vprintfmt+0x288>
		return va_arg(*ap, long long);
  800565:	8b 45 14             	mov    0x14(%ebp),%eax
  800568:	8d 50 08             	lea    0x8(%eax),%edx
  80056b:	89 55 14             	mov    %edx,0x14(%ebp)
  80056e:	8b 50 04             	mov    0x4(%eax),%edx
  800571:	8b 00                	mov    (%eax),%eax
  800573:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800576:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800579:	eb 34                	jmp    8005af <vprintfmt+0x2bc>
	else if (lflag)
  80057b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80057f:	74 18                	je     800599 <vprintfmt+0x2a6>
		return va_arg(*ap, long);
  800581:	8b 45 14             	mov    0x14(%ebp),%eax
  800584:	8d 50 04             	lea    0x4(%eax),%edx
  800587:	89 55 14             	mov    %edx,0x14(%ebp)
  80058a:	8b 30                	mov    (%eax),%esi
  80058c:	89 75 d8             	mov    %esi,-0x28(%ebp)
  80058f:	89 f0                	mov    %esi,%eax
  800591:	c1 f8 1f             	sar    $0x1f,%eax
  800594:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800597:	eb 16                	jmp    8005af <vprintfmt+0x2bc>
	else
		return va_arg(*ap, int);
  800599:	8b 45 14             	mov    0x14(%ebp),%eax
  80059c:	8d 50 04             	lea    0x4(%eax),%edx
  80059f:	89 55 14             	mov    %edx,0x14(%ebp)
  8005a2:	8b 30                	mov    (%eax),%esi
  8005a4:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8005a7:	89 f0                	mov    %esi,%eax
  8005a9:	c1 f8 1f             	sar    $0x1f,%eax
  8005ac:	89 45 dc             	mov    %eax,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005af:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005b2:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
  8005b5:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005b9:	0f 89 8a 00 00 00    	jns    800649 <vprintfmt+0x356>
				putch('-', putdat);
  8005bf:	83 ec 08             	sub    $0x8,%esp
  8005c2:	53                   	push   %ebx
  8005c3:	6a 2d                	push   $0x2d
  8005c5:	ff d7                	call   *%edi
				num = -(long long) num;
  8005c7:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005ca:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005cd:	f7 d8                	neg    %eax
  8005cf:	83 d2 00             	adc    $0x0,%edx
  8005d2:	f7 da                	neg    %edx
  8005d4:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005d7:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8005dc:	eb 70                	jmp    80064e <vprintfmt+0x35b>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005de:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8005e1:	8d 45 14             	lea    0x14(%ebp),%eax
  8005e4:	e8 97 fc ff ff       	call   800280 <getuint>
			base = 10;
  8005e9:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8005ee:	eb 5e                	jmp    80064e <vprintfmt+0x35b>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
  8005f0:	83 ec 08             	sub    $0x8,%esp
  8005f3:	53                   	push   %ebx
  8005f4:	6a 30                	push   $0x30
  8005f6:	ff d7                	call   *%edi
			num = getuint(&ap, lflag);
  8005f8:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8005fb:	8d 45 14             	lea    0x14(%ebp),%eax
  8005fe:	e8 7d fc ff ff       	call   800280 <getuint>
			base = 8;
			goto number;
  800603:	83 c4 10             	add    $0x10,%esp
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  800606:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80060b:	eb 41                	jmp    80064e <vprintfmt+0x35b>
		// pointer
		case 'p':
			putch('0', putdat);
  80060d:	83 ec 08             	sub    $0x8,%esp
  800610:	53                   	push   %ebx
  800611:	6a 30                	push   $0x30
  800613:	ff d7                	call   *%edi
			putch('x', putdat);
  800615:	83 c4 08             	add    $0x8,%esp
  800618:	53                   	push   %ebx
  800619:	6a 78                	push   $0x78
  80061b:	ff d7                	call   *%edi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80061d:	8b 45 14             	mov    0x14(%ebp),%eax
  800620:	8d 50 04             	lea    0x4(%eax),%edx
  800623:	89 55 14             	mov    %edx,0x14(%ebp)
			goto number;
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800626:	8b 00                	mov    (%eax),%eax
  800628:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80062d:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800630:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800635:	eb 17                	jmp    80064e <vprintfmt+0x35b>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800637:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80063a:	8d 45 14             	lea    0x14(%ebp),%eax
  80063d:	e8 3e fc ff ff       	call   800280 <getuint>
			base = 16;
  800642:	b9 10 00 00 00       	mov    $0x10,%ecx
  800647:	eb 05                	jmp    80064e <vprintfmt+0x35b>
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800649:	b9 0a 00 00 00       	mov    $0xa,%ecx
		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  80064e:	83 ec 0c             	sub    $0xc,%esp
  800651:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  800655:	56                   	push   %esi
  800656:	ff 75 e4             	pushl  -0x1c(%ebp)
  800659:	51                   	push   %ecx
  80065a:	52                   	push   %edx
  80065b:	50                   	push   %eax
  80065c:	89 da                	mov    %ebx,%edx
  80065e:	89 f8                	mov    %edi,%eax
  800660:	e8 6b fb ff ff       	call   8001d0 <printnum>
			break;
  800665:	83 c4 20             	add    $0x20,%esp
  800668:	e9 9a fc ff ff       	jmp    800307 <vprintfmt+0x14>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80066d:	83 ec 08             	sub    $0x8,%esp
  800670:	53                   	push   %ebx
  800671:	52                   	push   %edx
  800672:	ff d7                	call   *%edi
			break;
  800674:	83 c4 10             	add    $0x10,%esp
  800677:	e9 8b fc ff ff       	jmp    800307 <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80067c:	83 ec 08             	sub    $0x8,%esp
  80067f:	53                   	push   %ebx
  800680:	6a 25                	push   $0x25
  800682:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800684:	83 c4 10             	add    $0x10,%esp
  800687:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80068b:	0f 84 73 fc ff ff    	je     800304 <vprintfmt+0x11>
  800691:	4e                   	dec    %esi
  800692:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800696:	75 f9                	jne    800691 <vprintfmt+0x39e>
  800698:	89 75 10             	mov    %esi,0x10(%ebp)
  80069b:	e9 67 fc ff ff       	jmp    800307 <vprintfmt+0x14>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006a0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8006a3:	8d 70 01             	lea    0x1(%eax),%esi
  8006a6:	8a 00                	mov    (%eax),%al
  8006a8:	0f be d0             	movsbl %al,%edx
  8006ab:	85 d2                	test   %edx,%edx
  8006ad:	0f 85 7a fe ff ff    	jne    80052d <vprintfmt+0x23a>
  8006b3:	e9 4f fc ff ff       	jmp    800307 <vprintfmt+0x14>
  8006b8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8006bb:	8d 70 01             	lea    0x1(%eax),%esi
  8006be:	8a 00                	mov    (%eax),%al
  8006c0:	0f be d0             	movsbl %al,%edx
  8006c3:	85 d2                	test   %edx,%edx
  8006c5:	0f 85 6a fe ff ff    	jne    800535 <vprintfmt+0x242>
  8006cb:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8006ce:	e9 77 fe ff ff       	jmp    80054a <vprintfmt+0x257>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  8006d3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006d6:	5b                   	pop    %ebx
  8006d7:	5e                   	pop    %esi
  8006d8:	5f                   	pop    %edi
  8006d9:	5d                   	pop    %ebp
  8006da:	c3                   	ret    

008006db <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006db:	55                   	push   %ebp
  8006dc:	89 e5                	mov    %esp,%ebp
  8006de:	83 ec 18             	sub    $0x18,%esp
  8006e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8006e4:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006e7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006ea:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006ee:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006f1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006f8:	85 c0                	test   %eax,%eax
  8006fa:	74 26                	je     800722 <vsnprintf+0x47>
  8006fc:	85 d2                	test   %edx,%edx
  8006fe:	7e 29                	jle    800729 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800700:	ff 75 14             	pushl  0x14(%ebp)
  800703:	ff 75 10             	pushl  0x10(%ebp)
  800706:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800709:	50                   	push   %eax
  80070a:	68 ba 02 80 00       	push   $0x8002ba
  80070f:	e8 df fb ff ff       	call   8002f3 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800714:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800717:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80071a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80071d:	83 c4 10             	add    $0x10,%esp
  800720:	eb 0c                	jmp    80072e <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800722:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800727:	eb 05                	jmp    80072e <vsnprintf+0x53>
  800729:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80072e:	c9                   	leave  
  80072f:	c3                   	ret    

00800730 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800730:	55                   	push   %ebp
  800731:	89 e5                	mov    %esp,%ebp
  800733:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800736:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800739:	50                   	push   %eax
  80073a:	ff 75 10             	pushl  0x10(%ebp)
  80073d:	ff 75 0c             	pushl  0xc(%ebp)
  800740:	ff 75 08             	pushl  0x8(%ebp)
  800743:	e8 93 ff ff ff       	call   8006db <vsnprintf>
	va_end(ap);

	return rc;
}
  800748:	c9                   	leave  
  800749:	c3                   	ret    

0080074a <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80074a:	55                   	push   %ebp
  80074b:	89 e5                	mov    %esp,%ebp
  80074d:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800750:	80 3a 00             	cmpb   $0x0,(%edx)
  800753:	74 0e                	je     800763 <strlen+0x19>
  800755:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  80075a:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80075b:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80075f:	75 f9                	jne    80075a <strlen+0x10>
  800761:	eb 05                	jmp    800768 <strlen+0x1e>
  800763:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800768:	5d                   	pop    %ebp
  800769:	c3                   	ret    

0080076a <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80076a:	55                   	push   %ebp
  80076b:	89 e5                	mov    %esp,%ebp
  80076d:	53                   	push   %ebx
  80076e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800771:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800774:	85 c9                	test   %ecx,%ecx
  800776:	74 1a                	je     800792 <strnlen+0x28>
  800778:	80 3b 00             	cmpb   $0x0,(%ebx)
  80077b:	74 1c                	je     800799 <strnlen+0x2f>
  80077d:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  800782:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800784:	39 ca                	cmp    %ecx,%edx
  800786:	74 16                	je     80079e <strnlen+0x34>
  800788:	42                   	inc    %edx
  800789:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  80078e:	75 f2                	jne    800782 <strnlen+0x18>
  800790:	eb 0c                	jmp    80079e <strnlen+0x34>
  800792:	b8 00 00 00 00       	mov    $0x0,%eax
  800797:	eb 05                	jmp    80079e <strnlen+0x34>
  800799:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  80079e:	5b                   	pop    %ebx
  80079f:	5d                   	pop    %ebp
  8007a0:	c3                   	ret    

008007a1 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007a1:	55                   	push   %ebp
  8007a2:	89 e5                	mov    %esp,%ebp
  8007a4:	53                   	push   %ebx
  8007a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8007a8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007ab:	89 c2                	mov    %eax,%edx
  8007ad:	42                   	inc    %edx
  8007ae:	41                   	inc    %ecx
  8007af:	8a 59 ff             	mov    -0x1(%ecx),%bl
  8007b2:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007b5:	84 db                	test   %bl,%bl
  8007b7:	75 f4                	jne    8007ad <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007b9:	5b                   	pop    %ebx
  8007ba:	5d                   	pop    %ebp
  8007bb:	c3                   	ret    

008007bc <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007bc:	55                   	push   %ebp
  8007bd:	89 e5                	mov    %esp,%ebp
  8007bf:	53                   	push   %ebx
  8007c0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007c3:	53                   	push   %ebx
  8007c4:	e8 81 ff ff ff       	call   80074a <strlen>
  8007c9:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007cc:	ff 75 0c             	pushl  0xc(%ebp)
  8007cf:	01 d8                	add    %ebx,%eax
  8007d1:	50                   	push   %eax
  8007d2:	e8 ca ff ff ff       	call   8007a1 <strcpy>
	return dst;
}
  8007d7:	89 d8                	mov    %ebx,%eax
  8007d9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007dc:	c9                   	leave  
  8007dd:	c3                   	ret    

008007de <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007de:	55                   	push   %ebp
  8007df:	89 e5                	mov    %esp,%ebp
  8007e1:	56                   	push   %esi
  8007e2:	53                   	push   %ebx
  8007e3:	8b 75 08             	mov    0x8(%ebp),%esi
  8007e6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007e9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007ec:	85 db                	test   %ebx,%ebx
  8007ee:	74 14                	je     800804 <strncpy+0x26>
  8007f0:	01 f3                	add    %esi,%ebx
  8007f2:	89 f1                	mov    %esi,%ecx
		*dst++ = *src;
  8007f4:	41                   	inc    %ecx
  8007f5:	8a 02                	mov    (%edx),%al
  8007f7:	88 41 ff             	mov    %al,-0x1(%ecx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007fa:	80 3a 01             	cmpb   $0x1,(%edx)
  8007fd:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800800:	39 cb                	cmp    %ecx,%ebx
  800802:	75 f0                	jne    8007f4 <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800804:	89 f0                	mov    %esi,%eax
  800806:	5b                   	pop    %ebx
  800807:	5e                   	pop    %esi
  800808:	5d                   	pop    %ebp
  800809:	c3                   	ret    

0080080a <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80080a:	55                   	push   %ebp
  80080b:	89 e5                	mov    %esp,%ebp
  80080d:	53                   	push   %ebx
  80080e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800811:	8b 45 10             	mov    0x10(%ebp),%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800814:	85 c0                	test   %eax,%eax
  800816:	74 30                	je     800848 <strlcpy+0x3e>
		while (--size > 0 && *src != '\0')
  800818:	48                   	dec    %eax
  800819:	74 20                	je     80083b <strlcpy+0x31>
  80081b:	8a 0b                	mov    (%ebx),%cl
  80081d:	84 c9                	test   %cl,%cl
  80081f:	74 1f                	je     800840 <strlcpy+0x36>
  800821:	8d 53 01             	lea    0x1(%ebx),%edx
  800824:	01 c3                	add    %eax,%ebx
  800826:	8b 45 08             	mov    0x8(%ebp),%eax
			*dst++ = *src++;
  800829:	40                   	inc    %eax
  80082a:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80082d:	39 da                	cmp    %ebx,%edx
  80082f:	74 12                	je     800843 <strlcpy+0x39>
  800831:	42                   	inc    %edx
  800832:	8a 4a ff             	mov    -0x1(%edx),%cl
  800835:	84 c9                	test   %cl,%cl
  800837:	75 f0                	jne    800829 <strlcpy+0x1f>
  800839:	eb 08                	jmp    800843 <strlcpy+0x39>
  80083b:	8b 45 08             	mov    0x8(%ebp),%eax
  80083e:	eb 03                	jmp    800843 <strlcpy+0x39>
  800840:	8b 45 08             	mov    0x8(%ebp),%eax
			*dst++ = *src++;
		*dst = '\0';
  800843:	c6 00 00             	movb   $0x0,(%eax)
  800846:	eb 03                	jmp    80084b <strlcpy+0x41>
  800848:	8b 45 08             	mov    0x8(%ebp),%eax
	}
	return dst - dst_in;
  80084b:	2b 45 08             	sub    0x8(%ebp),%eax
}
  80084e:	5b                   	pop    %ebx
  80084f:	5d                   	pop    %ebp
  800850:	c3                   	ret    

00800851 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800851:	55                   	push   %ebp
  800852:	89 e5                	mov    %esp,%ebp
  800854:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800857:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80085a:	8a 01                	mov    (%ecx),%al
  80085c:	84 c0                	test   %al,%al
  80085e:	74 10                	je     800870 <strcmp+0x1f>
  800860:	3a 02                	cmp    (%edx),%al
  800862:	75 0c                	jne    800870 <strcmp+0x1f>
		p++, q++;
  800864:	41                   	inc    %ecx
  800865:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800866:	8a 01                	mov    (%ecx),%al
  800868:	84 c0                	test   %al,%al
  80086a:	74 04                	je     800870 <strcmp+0x1f>
  80086c:	3a 02                	cmp    (%edx),%al
  80086e:	74 f4                	je     800864 <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800870:	0f b6 c0             	movzbl %al,%eax
  800873:	0f b6 12             	movzbl (%edx),%edx
  800876:	29 d0                	sub    %edx,%eax
}
  800878:	5d                   	pop    %ebp
  800879:	c3                   	ret    

0080087a <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80087a:	55                   	push   %ebp
  80087b:	89 e5                	mov    %esp,%ebp
  80087d:	56                   	push   %esi
  80087e:	53                   	push   %ebx
  80087f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800882:	8b 55 0c             	mov    0xc(%ebp),%edx
  800885:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  800888:	85 f6                	test   %esi,%esi
  80088a:	74 23                	je     8008af <strncmp+0x35>
  80088c:	8a 03                	mov    (%ebx),%al
  80088e:	84 c0                	test   %al,%al
  800890:	74 2b                	je     8008bd <strncmp+0x43>
  800892:	3a 02                	cmp    (%edx),%al
  800894:	75 27                	jne    8008bd <strncmp+0x43>
  800896:	8d 43 01             	lea    0x1(%ebx),%eax
  800899:	01 de                	add    %ebx,%esi
		n--, p++, q++;
  80089b:	89 c3                	mov    %eax,%ebx
  80089d:	42                   	inc    %edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80089e:	39 c6                	cmp    %eax,%esi
  8008a0:	74 14                	je     8008b6 <strncmp+0x3c>
  8008a2:	8a 08                	mov    (%eax),%cl
  8008a4:	84 c9                	test   %cl,%cl
  8008a6:	74 15                	je     8008bd <strncmp+0x43>
  8008a8:	40                   	inc    %eax
  8008a9:	3a 0a                	cmp    (%edx),%cl
  8008ab:	74 ee                	je     80089b <strncmp+0x21>
  8008ad:	eb 0e                	jmp    8008bd <strncmp+0x43>
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008af:	b8 00 00 00 00       	mov    $0x0,%eax
  8008b4:	eb 0f                	jmp    8008c5 <strncmp+0x4b>
  8008b6:	b8 00 00 00 00       	mov    $0x0,%eax
  8008bb:	eb 08                	jmp    8008c5 <strncmp+0x4b>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008bd:	0f b6 03             	movzbl (%ebx),%eax
  8008c0:	0f b6 12             	movzbl (%edx),%edx
  8008c3:	29 d0                	sub    %edx,%eax
}
  8008c5:	5b                   	pop    %ebx
  8008c6:	5e                   	pop    %esi
  8008c7:	5d                   	pop    %ebp
  8008c8:	c3                   	ret    

008008c9 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008c9:	55                   	push   %ebp
  8008ca:	89 e5                	mov    %esp,%ebp
  8008cc:	53                   	push   %ebx
  8008cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  8008d3:	8a 10                	mov    (%eax),%dl
  8008d5:	84 d2                	test   %dl,%dl
  8008d7:	74 1a                	je     8008f3 <strchr+0x2a>
  8008d9:	88 d9                	mov    %bl,%cl
		if (*s == c)
  8008db:	38 d3                	cmp    %dl,%bl
  8008dd:	75 06                	jne    8008e5 <strchr+0x1c>
  8008df:	eb 17                	jmp    8008f8 <strchr+0x2f>
  8008e1:	38 ca                	cmp    %cl,%dl
  8008e3:	74 13                	je     8008f8 <strchr+0x2f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008e5:	40                   	inc    %eax
  8008e6:	8a 10                	mov    (%eax),%dl
  8008e8:	84 d2                	test   %dl,%dl
  8008ea:	75 f5                	jne    8008e1 <strchr+0x18>
		if (*s == c)
			return (char *) s;
	return 0;
  8008ec:	b8 00 00 00 00       	mov    $0x0,%eax
  8008f1:	eb 05                	jmp    8008f8 <strchr+0x2f>
  8008f3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008f8:	5b                   	pop    %ebx
  8008f9:	5d                   	pop    %ebp
  8008fa:	c3                   	ret    

008008fb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008fb:	55                   	push   %ebp
  8008fc:	89 e5                	mov    %esp,%ebp
  8008fe:	53                   	push   %ebx
  8008ff:	8b 45 08             	mov    0x8(%ebp),%eax
  800902:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  800905:	8a 10                	mov    (%eax),%dl
  800907:	84 d2                	test   %dl,%dl
  800909:	74 13                	je     80091e <strfind+0x23>
  80090b:	88 d9                	mov    %bl,%cl
		if (*s == c)
  80090d:	38 d3                	cmp    %dl,%bl
  80090f:	75 06                	jne    800917 <strfind+0x1c>
  800911:	eb 0b                	jmp    80091e <strfind+0x23>
  800913:	38 ca                	cmp    %cl,%dl
  800915:	74 07                	je     80091e <strfind+0x23>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800917:	40                   	inc    %eax
  800918:	8a 10                	mov    (%eax),%dl
  80091a:	84 d2                	test   %dl,%dl
  80091c:	75 f5                	jne    800913 <strfind+0x18>
		if (*s == c)
			break;
	return (char *) s;
}
  80091e:	5b                   	pop    %ebx
  80091f:	5d                   	pop    %ebp
  800920:	c3                   	ret    

00800921 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800921:	55                   	push   %ebp
  800922:	89 e5                	mov    %esp,%ebp
  800924:	57                   	push   %edi
  800925:	56                   	push   %esi
  800926:	53                   	push   %ebx
  800927:	8b 7d 08             	mov    0x8(%ebp),%edi
  80092a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80092d:	85 c9                	test   %ecx,%ecx
  80092f:	74 36                	je     800967 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800931:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800937:	75 28                	jne    800961 <memset+0x40>
  800939:	f6 c1 03             	test   $0x3,%cl
  80093c:	75 23                	jne    800961 <memset+0x40>
		c &= 0xFF;
  80093e:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800942:	89 d3                	mov    %edx,%ebx
  800944:	c1 e3 08             	shl    $0x8,%ebx
  800947:	89 d6                	mov    %edx,%esi
  800949:	c1 e6 18             	shl    $0x18,%esi
  80094c:	89 d0                	mov    %edx,%eax
  80094e:	c1 e0 10             	shl    $0x10,%eax
  800951:	09 f0                	or     %esi,%eax
  800953:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800955:	89 d8                	mov    %ebx,%eax
  800957:	09 d0                	or     %edx,%eax
  800959:	c1 e9 02             	shr    $0x2,%ecx
  80095c:	fc                   	cld    
  80095d:	f3 ab                	rep stos %eax,%es:(%edi)
  80095f:	eb 06                	jmp    800967 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800961:	8b 45 0c             	mov    0xc(%ebp),%eax
  800964:	fc                   	cld    
  800965:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800967:	89 f8                	mov    %edi,%eax
  800969:	5b                   	pop    %ebx
  80096a:	5e                   	pop    %esi
  80096b:	5f                   	pop    %edi
  80096c:	5d                   	pop    %ebp
  80096d:	c3                   	ret    

0080096e <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80096e:	55                   	push   %ebp
  80096f:	89 e5                	mov    %esp,%ebp
  800971:	57                   	push   %edi
  800972:	56                   	push   %esi
  800973:	8b 45 08             	mov    0x8(%ebp),%eax
  800976:	8b 75 0c             	mov    0xc(%ebp),%esi
  800979:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80097c:	39 c6                	cmp    %eax,%esi
  80097e:	73 33                	jae    8009b3 <memmove+0x45>
  800980:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800983:	39 d0                	cmp    %edx,%eax
  800985:	73 2c                	jae    8009b3 <memmove+0x45>
		s += n;
		d += n;
  800987:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80098a:	89 d6                	mov    %edx,%esi
  80098c:	09 fe                	or     %edi,%esi
  80098e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800994:	75 13                	jne    8009a9 <memmove+0x3b>
  800996:	f6 c1 03             	test   $0x3,%cl
  800999:	75 0e                	jne    8009a9 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  80099b:	83 ef 04             	sub    $0x4,%edi
  80099e:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009a1:	c1 e9 02             	shr    $0x2,%ecx
  8009a4:	fd                   	std    
  8009a5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009a7:	eb 07                	jmp    8009b0 <memmove+0x42>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009a9:	4f                   	dec    %edi
  8009aa:	8d 72 ff             	lea    -0x1(%edx),%esi
  8009ad:	fd                   	std    
  8009ae:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009b0:	fc                   	cld    
  8009b1:	eb 1d                	jmp    8009d0 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009b3:	89 f2                	mov    %esi,%edx
  8009b5:	09 c2                	or     %eax,%edx
  8009b7:	f6 c2 03             	test   $0x3,%dl
  8009ba:	75 0f                	jne    8009cb <memmove+0x5d>
  8009bc:	f6 c1 03             	test   $0x3,%cl
  8009bf:	75 0a                	jne    8009cb <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
  8009c1:	c1 e9 02             	shr    $0x2,%ecx
  8009c4:	89 c7                	mov    %eax,%edi
  8009c6:	fc                   	cld    
  8009c7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009c9:	eb 05                	jmp    8009d0 <memmove+0x62>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009cb:	89 c7                	mov    %eax,%edi
  8009cd:	fc                   	cld    
  8009ce:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009d0:	5e                   	pop    %esi
  8009d1:	5f                   	pop    %edi
  8009d2:	5d                   	pop    %ebp
  8009d3:	c3                   	ret    

008009d4 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009d4:	55                   	push   %ebp
  8009d5:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009d7:	ff 75 10             	pushl  0x10(%ebp)
  8009da:	ff 75 0c             	pushl  0xc(%ebp)
  8009dd:	ff 75 08             	pushl  0x8(%ebp)
  8009e0:	e8 89 ff ff ff       	call   80096e <memmove>
}
  8009e5:	c9                   	leave  
  8009e6:	c3                   	ret    

008009e7 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009e7:	55                   	push   %ebp
  8009e8:	89 e5                	mov    %esp,%ebp
  8009ea:	57                   	push   %edi
  8009eb:	56                   	push   %esi
  8009ec:	53                   	push   %ebx
  8009ed:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8009f0:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009f3:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009f6:	85 c0                	test   %eax,%eax
  8009f8:	74 33                	je     800a2d <memcmp+0x46>
  8009fa:	8d 78 ff             	lea    -0x1(%eax),%edi
		if (*s1 != *s2)
  8009fd:	8a 13                	mov    (%ebx),%dl
  8009ff:	8a 0e                	mov    (%esi),%cl
  800a01:	38 ca                	cmp    %cl,%dl
  800a03:	75 13                	jne    800a18 <memcmp+0x31>
  800a05:	b8 00 00 00 00       	mov    $0x0,%eax
  800a0a:	eb 16                	jmp    800a22 <memcmp+0x3b>
  800a0c:	8a 54 03 01          	mov    0x1(%ebx,%eax,1),%dl
  800a10:	40                   	inc    %eax
  800a11:	8a 0c 06             	mov    (%esi,%eax,1),%cl
  800a14:	38 ca                	cmp    %cl,%dl
  800a16:	74 0a                	je     800a22 <memcmp+0x3b>
			return (int) *s1 - (int) *s2;
  800a18:	0f b6 c2             	movzbl %dl,%eax
  800a1b:	0f b6 c9             	movzbl %cl,%ecx
  800a1e:	29 c8                	sub    %ecx,%eax
  800a20:	eb 10                	jmp    800a32 <memcmp+0x4b>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a22:	39 f8                	cmp    %edi,%eax
  800a24:	75 e6                	jne    800a0c <memcmp+0x25>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a26:	b8 00 00 00 00       	mov    $0x0,%eax
  800a2b:	eb 05                	jmp    800a32 <memcmp+0x4b>
  800a2d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a32:	5b                   	pop    %ebx
  800a33:	5e                   	pop    %esi
  800a34:	5f                   	pop    %edi
  800a35:	5d                   	pop    %ebp
  800a36:	c3                   	ret    

00800a37 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a37:	55                   	push   %ebp
  800a38:	89 e5                	mov    %esp,%ebp
  800a3a:	53                   	push   %ebx
  800a3b:	8b 55 08             	mov    0x8(%ebp),%edx
	const void *ends = (const char *) s + n;
  800a3e:	89 d0                	mov    %edx,%eax
  800a40:	03 45 10             	add    0x10(%ebp),%eax
	for (; s < ends; s++)
  800a43:	39 c2                	cmp    %eax,%edx
  800a45:	73 1b                	jae    800a62 <memfind+0x2b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a47:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
  800a4b:	0f b6 0a             	movzbl (%edx),%ecx
  800a4e:	39 d9                	cmp    %ebx,%ecx
  800a50:	75 09                	jne    800a5b <memfind+0x24>
  800a52:	eb 12                	jmp    800a66 <memfind+0x2f>
  800a54:	0f b6 0a             	movzbl (%edx),%ecx
  800a57:	39 d9                	cmp    %ebx,%ecx
  800a59:	74 0f                	je     800a6a <memfind+0x33>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a5b:	42                   	inc    %edx
  800a5c:	39 d0                	cmp    %edx,%eax
  800a5e:	75 f4                	jne    800a54 <memfind+0x1d>
  800a60:	eb 0a                	jmp    800a6c <memfind+0x35>
  800a62:	89 d0                	mov    %edx,%eax
  800a64:	eb 06                	jmp    800a6c <memfind+0x35>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a66:	89 d0                	mov    %edx,%eax
  800a68:	eb 02                	jmp    800a6c <memfind+0x35>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a6a:	89 d0                	mov    %edx,%eax
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a6c:	5b                   	pop    %ebx
  800a6d:	5d                   	pop    %ebp
  800a6e:	c3                   	ret    

00800a6f <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a6f:	55                   	push   %ebp
  800a70:	89 e5                	mov    %esp,%ebp
  800a72:	57                   	push   %edi
  800a73:	56                   	push   %esi
  800a74:	53                   	push   %ebx
  800a75:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a78:	eb 01                	jmp    800a7b <strtol+0xc>
		s++;
  800a7a:	41                   	inc    %ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a7b:	8a 01                	mov    (%ecx),%al
  800a7d:	3c 20                	cmp    $0x20,%al
  800a7f:	74 f9                	je     800a7a <strtol+0xb>
  800a81:	3c 09                	cmp    $0x9,%al
  800a83:	74 f5                	je     800a7a <strtol+0xb>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a85:	3c 2b                	cmp    $0x2b,%al
  800a87:	75 08                	jne    800a91 <strtol+0x22>
		s++;
  800a89:	41                   	inc    %ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a8a:	bf 00 00 00 00       	mov    $0x0,%edi
  800a8f:	eb 11                	jmp    800aa2 <strtol+0x33>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a91:	3c 2d                	cmp    $0x2d,%al
  800a93:	75 08                	jne    800a9d <strtol+0x2e>
		s++, neg = 1;
  800a95:	41                   	inc    %ecx
  800a96:	bf 01 00 00 00       	mov    $0x1,%edi
  800a9b:	eb 05                	jmp    800aa2 <strtol+0x33>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a9d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800aa2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800aa6:	0f 84 87 00 00 00    	je     800b33 <strtol+0xc4>
  800aac:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  800ab0:	75 27                	jne    800ad9 <strtol+0x6a>
  800ab2:	80 39 30             	cmpb   $0x30,(%ecx)
  800ab5:	75 22                	jne    800ad9 <strtol+0x6a>
  800ab7:	e9 88 00 00 00       	jmp    800b44 <strtol+0xd5>
		s += 2, base = 16;
  800abc:	83 c1 02             	add    $0x2,%ecx
  800abf:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  800ac6:	eb 11                	jmp    800ad9 <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
  800ac8:	41                   	inc    %ecx
  800ac9:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  800ad0:	eb 07                	jmp    800ad9 <strtol+0x6a>
	else if (base == 0)
		base = 10;
  800ad2:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)
  800ad9:	b8 00 00 00 00       	mov    $0x0,%eax

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ade:	8a 11                	mov    (%ecx),%dl
  800ae0:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800ae3:	80 fb 09             	cmp    $0x9,%bl
  800ae6:	77 08                	ja     800af0 <strtol+0x81>
			dig = *s - '0';
  800ae8:	0f be d2             	movsbl %dl,%edx
  800aeb:	83 ea 30             	sub    $0x30,%edx
  800aee:	eb 22                	jmp    800b12 <strtol+0xa3>
		else if (*s >= 'a' && *s <= 'z')
  800af0:	8d 72 9f             	lea    -0x61(%edx),%esi
  800af3:	89 f3                	mov    %esi,%ebx
  800af5:	80 fb 19             	cmp    $0x19,%bl
  800af8:	77 08                	ja     800b02 <strtol+0x93>
			dig = *s - 'a' + 10;
  800afa:	0f be d2             	movsbl %dl,%edx
  800afd:	83 ea 57             	sub    $0x57,%edx
  800b00:	eb 10                	jmp    800b12 <strtol+0xa3>
		else if (*s >= 'A' && *s <= 'Z')
  800b02:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b05:	89 f3                	mov    %esi,%ebx
  800b07:	80 fb 19             	cmp    $0x19,%bl
  800b0a:	77 14                	ja     800b20 <strtol+0xb1>
			dig = *s - 'A' + 10;
  800b0c:	0f be d2             	movsbl %dl,%edx
  800b0f:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b12:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b15:	7d 09                	jge    800b20 <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800b17:	41                   	inc    %ecx
  800b18:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b1c:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b1e:	eb be                	jmp    800ade <strtol+0x6f>

	if (endptr)
  800b20:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b24:	74 05                	je     800b2b <strtol+0xbc>
		*endptr = (char *) s;
  800b26:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b29:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800b2b:	85 ff                	test   %edi,%edi
  800b2d:	74 21                	je     800b50 <strtol+0xe1>
  800b2f:	f7 d8                	neg    %eax
  800b31:	eb 1d                	jmp    800b50 <strtol+0xe1>
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b33:	80 39 30             	cmpb   $0x30,(%ecx)
  800b36:	75 9a                	jne    800ad2 <strtol+0x63>
  800b38:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b3c:	0f 84 7a ff ff ff    	je     800abc <strtol+0x4d>
  800b42:	eb 84                	jmp    800ac8 <strtol+0x59>
  800b44:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b48:	0f 84 6e ff ff ff    	je     800abc <strtol+0x4d>
  800b4e:	eb 89                	jmp    800ad9 <strtol+0x6a>
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
}
  800b50:	5b                   	pop    %ebx
  800b51:	5e                   	pop    %esi
  800b52:	5f                   	pop    %edi
  800b53:	5d                   	pop    %ebp
  800b54:	c3                   	ret    

00800b55 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b55:	55                   	push   %ebp
  800b56:	89 e5                	mov    %esp,%ebp
  800b58:	57                   	push   %edi
  800b59:	56                   	push   %esi
  800b5a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b5b:	b8 00 00 00 00       	mov    $0x0,%eax
  800b60:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b63:	8b 55 08             	mov    0x8(%ebp),%edx
  800b66:	89 c3                	mov    %eax,%ebx
  800b68:	89 c7                	mov    %eax,%edi
  800b6a:	89 c6                	mov    %eax,%esi
  800b6c:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b6e:	5b                   	pop    %ebx
  800b6f:	5e                   	pop    %esi
  800b70:	5f                   	pop    %edi
  800b71:	5d                   	pop    %ebp
  800b72:	c3                   	ret    

00800b73 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b73:	55                   	push   %ebp
  800b74:	89 e5                	mov    %esp,%ebp
  800b76:	57                   	push   %edi
  800b77:	56                   	push   %esi
  800b78:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b79:	ba 00 00 00 00       	mov    $0x0,%edx
  800b7e:	b8 01 00 00 00       	mov    $0x1,%eax
  800b83:	89 d1                	mov    %edx,%ecx
  800b85:	89 d3                	mov    %edx,%ebx
  800b87:	89 d7                	mov    %edx,%edi
  800b89:	89 d6                	mov    %edx,%esi
  800b8b:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b8d:	5b                   	pop    %ebx
  800b8e:	5e                   	pop    %esi
  800b8f:	5f                   	pop    %edi
  800b90:	5d                   	pop    %ebp
  800b91:	c3                   	ret    

00800b92 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b92:	55                   	push   %ebp
  800b93:	89 e5                	mov    %esp,%ebp
  800b95:	57                   	push   %edi
  800b96:	56                   	push   %esi
  800b97:	53                   	push   %ebx
  800b98:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b9b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ba0:	b8 03 00 00 00       	mov    $0x3,%eax
  800ba5:	8b 55 08             	mov    0x8(%ebp),%edx
  800ba8:	89 cb                	mov    %ecx,%ebx
  800baa:	89 cf                	mov    %ecx,%edi
  800bac:	89 ce                	mov    %ecx,%esi
  800bae:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bb0:	85 c0                	test   %eax,%eax
  800bb2:	7e 17                	jle    800bcb <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bb4:	83 ec 0c             	sub    $0xc,%esp
  800bb7:	50                   	push   %eax
  800bb8:	6a 03                	push   $0x3
  800bba:	68 9f 27 80 00       	push   $0x80279f
  800bbf:	6a 23                	push   $0x23
  800bc1:	68 bc 27 80 00       	push   $0x8027bc
  800bc6:	e8 19 f5 ff ff       	call   8000e4 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bcb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bce:	5b                   	pop    %ebx
  800bcf:	5e                   	pop    %esi
  800bd0:	5f                   	pop    %edi
  800bd1:	5d                   	pop    %ebp
  800bd2:	c3                   	ret    

00800bd3 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bd3:	55                   	push   %ebp
  800bd4:	89 e5                	mov    %esp,%ebp
  800bd6:	57                   	push   %edi
  800bd7:	56                   	push   %esi
  800bd8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bd9:	ba 00 00 00 00       	mov    $0x0,%edx
  800bde:	b8 02 00 00 00       	mov    $0x2,%eax
  800be3:	89 d1                	mov    %edx,%ecx
  800be5:	89 d3                	mov    %edx,%ebx
  800be7:	89 d7                	mov    %edx,%edi
  800be9:	89 d6                	mov    %edx,%esi
  800beb:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bed:	5b                   	pop    %ebx
  800bee:	5e                   	pop    %esi
  800bef:	5f                   	pop    %edi
  800bf0:	5d                   	pop    %ebp
  800bf1:	c3                   	ret    

00800bf2 <sys_yield>:

void
sys_yield(void)
{
  800bf2:	55                   	push   %ebp
  800bf3:	89 e5                	mov    %esp,%ebp
  800bf5:	57                   	push   %edi
  800bf6:	56                   	push   %esi
  800bf7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bf8:	ba 00 00 00 00       	mov    $0x0,%edx
  800bfd:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c02:	89 d1                	mov    %edx,%ecx
  800c04:	89 d3                	mov    %edx,%ebx
  800c06:	89 d7                	mov    %edx,%edi
  800c08:	89 d6                	mov    %edx,%esi
  800c0a:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c0c:	5b                   	pop    %ebx
  800c0d:	5e                   	pop    %esi
  800c0e:	5f                   	pop    %edi
  800c0f:	5d                   	pop    %ebp
  800c10:	c3                   	ret    

00800c11 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c11:	55                   	push   %ebp
  800c12:	89 e5                	mov    %esp,%ebp
  800c14:	57                   	push   %edi
  800c15:	56                   	push   %esi
  800c16:	53                   	push   %ebx
  800c17:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c1a:	be 00 00 00 00       	mov    $0x0,%esi
  800c1f:	b8 04 00 00 00       	mov    $0x4,%eax
  800c24:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c27:	8b 55 08             	mov    0x8(%ebp),%edx
  800c2a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c2d:	89 f7                	mov    %esi,%edi
  800c2f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c31:	85 c0                	test   %eax,%eax
  800c33:	7e 17                	jle    800c4c <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c35:	83 ec 0c             	sub    $0xc,%esp
  800c38:	50                   	push   %eax
  800c39:	6a 04                	push   $0x4
  800c3b:	68 9f 27 80 00       	push   $0x80279f
  800c40:	6a 23                	push   $0x23
  800c42:	68 bc 27 80 00       	push   $0x8027bc
  800c47:	e8 98 f4 ff ff       	call   8000e4 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c4c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c4f:	5b                   	pop    %ebx
  800c50:	5e                   	pop    %esi
  800c51:	5f                   	pop    %edi
  800c52:	5d                   	pop    %ebp
  800c53:	c3                   	ret    

00800c54 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c54:	55                   	push   %ebp
  800c55:	89 e5                	mov    %esp,%ebp
  800c57:	57                   	push   %edi
  800c58:	56                   	push   %esi
  800c59:	53                   	push   %ebx
  800c5a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c5d:	b8 05 00 00 00       	mov    $0x5,%eax
  800c62:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c65:	8b 55 08             	mov    0x8(%ebp),%edx
  800c68:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c6b:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c6e:	8b 75 18             	mov    0x18(%ebp),%esi
  800c71:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c73:	85 c0                	test   %eax,%eax
  800c75:	7e 17                	jle    800c8e <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c77:	83 ec 0c             	sub    $0xc,%esp
  800c7a:	50                   	push   %eax
  800c7b:	6a 05                	push   $0x5
  800c7d:	68 9f 27 80 00       	push   $0x80279f
  800c82:	6a 23                	push   $0x23
  800c84:	68 bc 27 80 00       	push   $0x8027bc
  800c89:	e8 56 f4 ff ff       	call   8000e4 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c8e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c91:	5b                   	pop    %ebx
  800c92:	5e                   	pop    %esi
  800c93:	5f                   	pop    %edi
  800c94:	5d                   	pop    %ebp
  800c95:	c3                   	ret    

00800c96 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c96:	55                   	push   %ebp
  800c97:	89 e5                	mov    %esp,%ebp
  800c99:	57                   	push   %edi
  800c9a:	56                   	push   %esi
  800c9b:	53                   	push   %ebx
  800c9c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c9f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ca4:	b8 06 00 00 00       	mov    $0x6,%eax
  800ca9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cac:	8b 55 08             	mov    0x8(%ebp),%edx
  800caf:	89 df                	mov    %ebx,%edi
  800cb1:	89 de                	mov    %ebx,%esi
  800cb3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cb5:	85 c0                	test   %eax,%eax
  800cb7:	7e 17                	jle    800cd0 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb9:	83 ec 0c             	sub    $0xc,%esp
  800cbc:	50                   	push   %eax
  800cbd:	6a 06                	push   $0x6
  800cbf:	68 9f 27 80 00       	push   $0x80279f
  800cc4:	6a 23                	push   $0x23
  800cc6:	68 bc 27 80 00       	push   $0x8027bc
  800ccb:	e8 14 f4 ff ff       	call   8000e4 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cd0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cd3:	5b                   	pop    %ebx
  800cd4:	5e                   	pop    %esi
  800cd5:	5f                   	pop    %edi
  800cd6:	5d                   	pop    %ebp
  800cd7:	c3                   	ret    

00800cd8 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cd8:	55                   	push   %ebp
  800cd9:	89 e5                	mov    %esp,%ebp
  800cdb:	57                   	push   %edi
  800cdc:	56                   	push   %esi
  800cdd:	53                   	push   %ebx
  800cde:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ce6:	b8 08 00 00 00       	mov    $0x8,%eax
  800ceb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cee:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf1:	89 df                	mov    %ebx,%edi
  800cf3:	89 de                	mov    %ebx,%esi
  800cf5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cf7:	85 c0                	test   %eax,%eax
  800cf9:	7e 17                	jle    800d12 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cfb:	83 ec 0c             	sub    $0xc,%esp
  800cfe:	50                   	push   %eax
  800cff:	6a 08                	push   $0x8
  800d01:	68 9f 27 80 00       	push   $0x80279f
  800d06:	6a 23                	push   $0x23
  800d08:	68 bc 27 80 00       	push   $0x8027bc
  800d0d:	e8 d2 f3 ff ff       	call   8000e4 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d12:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d15:	5b                   	pop    %ebx
  800d16:	5e                   	pop    %esi
  800d17:	5f                   	pop    %edi
  800d18:	5d                   	pop    %ebp
  800d19:	c3                   	ret    

00800d1a <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d1a:	55                   	push   %ebp
  800d1b:	89 e5                	mov    %esp,%ebp
  800d1d:	57                   	push   %edi
  800d1e:	56                   	push   %esi
  800d1f:	53                   	push   %ebx
  800d20:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d23:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d28:	b8 09 00 00 00       	mov    $0x9,%eax
  800d2d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d30:	8b 55 08             	mov    0x8(%ebp),%edx
  800d33:	89 df                	mov    %ebx,%edi
  800d35:	89 de                	mov    %ebx,%esi
  800d37:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d39:	85 c0                	test   %eax,%eax
  800d3b:	7e 17                	jle    800d54 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d3d:	83 ec 0c             	sub    $0xc,%esp
  800d40:	50                   	push   %eax
  800d41:	6a 09                	push   $0x9
  800d43:	68 9f 27 80 00       	push   $0x80279f
  800d48:	6a 23                	push   $0x23
  800d4a:	68 bc 27 80 00       	push   $0x8027bc
  800d4f:	e8 90 f3 ff ff       	call   8000e4 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d54:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d57:	5b                   	pop    %ebx
  800d58:	5e                   	pop    %esi
  800d59:	5f                   	pop    %edi
  800d5a:	5d                   	pop    %ebp
  800d5b:	c3                   	ret    

00800d5c <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d5c:	55                   	push   %ebp
  800d5d:	89 e5                	mov    %esp,%ebp
  800d5f:	57                   	push   %edi
  800d60:	56                   	push   %esi
  800d61:	53                   	push   %ebx
  800d62:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d65:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d6a:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d6f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d72:	8b 55 08             	mov    0x8(%ebp),%edx
  800d75:	89 df                	mov    %ebx,%edi
  800d77:	89 de                	mov    %ebx,%esi
  800d79:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d7b:	85 c0                	test   %eax,%eax
  800d7d:	7e 17                	jle    800d96 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d7f:	83 ec 0c             	sub    $0xc,%esp
  800d82:	50                   	push   %eax
  800d83:	6a 0a                	push   $0xa
  800d85:	68 9f 27 80 00       	push   $0x80279f
  800d8a:	6a 23                	push   $0x23
  800d8c:	68 bc 27 80 00       	push   $0x8027bc
  800d91:	e8 4e f3 ff ff       	call   8000e4 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d96:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d99:	5b                   	pop    %ebx
  800d9a:	5e                   	pop    %esi
  800d9b:	5f                   	pop    %edi
  800d9c:	5d                   	pop    %ebp
  800d9d:	c3                   	ret    

00800d9e <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d9e:	55                   	push   %ebp
  800d9f:	89 e5                	mov    %esp,%ebp
  800da1:	57                   	push   %edi
  800da2:	56                   	push   %esi
  800da3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800da4:	be 00 00 00 00       	mov    $0x0,%esi
  800da9:	b8 0c 00 00 00       	mov    $0xc,%eax
  800dae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db1:	8b 55 08             	mov    0x8(%ebp),%edx
  800db4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800db7:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dba:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800dbc:	5b                   	pop    %ebx
  800dbd:	5e                   	pop    %esi
  800dbe:	5f                   	pop    %edi
  800dbf:	5d                   	pop    %ebp
  800dc0:	c3                   	ret    

00800dc1 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800dc1:	55                   	push   %ebp
  800dc2:	89 e5                	mov    %esp,%ebp
  800dc4:	57                   	push   %edi
  800dc5:	56                   	push   %esi
  800dc6:	53                   	push   %ebx
  800dc7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dca:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dcf:	b8 0d 00 00 00       	mov    $0xd,%eax
  800dd4:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd7:	89 cb                	mov    %ecx,%ebx
  800dd9:	89 cf                	mov    %ecx,%edi
  800ddb:	89 ce                	mov    %ecx,%esi
  800ddd:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ddf:	85 c0                	test   %eax,%eax
  800de1:	7e 17                	jle    800dfa <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800de3:	83 ec 0c             	sub    $0xc,%esp
  800de6:	50                   	push   %eax
  800de7:	6a 0d                	push   $0xd
  800de9:	68 9f 27 80 00       	push   $0x80279f
  800dee:	6a 23                	push   $0x23
  800df0:	68 bc 27 80 00       	push   $0x8027bc
  800df5:	e8 ea f2 ff ff       	call   8000e4 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800dfa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dfd:	5b                   	pop    %ebx
  800dfe:	5e                   	pop    %esi
  800dff:	5f                   	pop    %edi
  800e00:	5d                   	pop    %ebp
  800e01:	c3                   	ret    

00800e02 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e02:	55                   	push   %ebp
  800e03:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e05:	8b 45 08             	mov    0x8(%ebp),%eax
  800e08:	05 00 00 00 30       	add    $0x30000000,%eax
  800e0d:	c1 e8 0c             	shr    $0xc,%eax
}
  800e10:	5d                   	pop    %ebp
  800e11:	c3                   	ret    

00800e12 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e12:	55                   	push   %ebp
  800e13:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800e15:	8b 45 08             	mov    0x8(%ebp),%eax
  800e18:	05 00 00 00 30       	add    $0x30000000,%eax
  800e1d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e22:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800e27:	5d                   	pop    %ebp
  800e28:	c3                   	ret    

00800e29 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e29:	55                   	push   %ebp
  800e2a:	89 e5                	mov    %esp,%ebp
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e2c:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  800e31:	a8 01                	test   $0x1,%al
  800e33:	74 34                	je     800e69 <fd_alloc+0x40>
  800e35:	a1 00 00 74 ef       	mov    0xef740000,%eax
  800e3a:	a8 01                	test   $0x1,%al
  800e3c:	74 32                	je     800e70 <fd_alloc+0x47>
  800e3e:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800e43:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e45:	89 c2                	mov    %eax,%edx
  800e47:	c1 ea 16             	shr    $0x16,%edx
  800e4a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e51:	f6 c2 01             	test   $0x1,%dl
  800e54:	74 1f                	je     800e75 <fd_alloc+0x4c>
  800e56:	89 c2                	mov    %eax,%edx
  800e58:	c1 ea 0c             	shr    $0xc,%edx
  800e5b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e62:	f6 c2 01             	test   $0x1,%dl
  800e65:	75 1a                	jne    800e81 <fd_alloc+0x58>
  800e67:	eb 0c                	jmp    800e75 <fd_alloc+0x4c>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800e69:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  800e6e:	eb 05                	jmp    800e75 <fd_alloc+0x4c>
  800e70:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  800e75:	8b 45 08             	mov    0x8(%ebp),%eax
  800e78:	89 08                	mov    %ecx,(%eax)
			return 0;
  800e7a:	b8 00 00 00 00       	mov    $0x0,%eax
  800e7f:	eb 1a                	jmp    800e9b <fd_alloc+0x72>
  800e81:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800e86:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e8b:	75 b6                	jne    800e43 <fd_alloc+0x1a>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800e8d:	8b 45 08             	mov    0x8(%ebp),%eax
  800e90:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  800e96:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800e9b:	5d                   	pop    %ebp
  800e9c:	c3                   	ret    

00800e9d <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e9d:	55                   	push   %ebp
  800e9e:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800ea0:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
  800ea4:	77 39                	ja     800edf <fd_lookup+0x42>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800ea6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ea9:	c1 e0 0c             	shl    $0xc,%eax
  800eac:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800eb1:	89 c2                	mov    %eax,%edx
  800eb3:	c1 ea 16             	shr    $0x16,%edx
  800eb6:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ebd:	f6 c2 01             	test   $0x1,%dl
  800ec0:	74 24                	je     800ee6 <fd_lookup+0x49>
  800ec2:	89 c2                	mov    %eax,%edx
  800ec4:	c1 ea 0c             	shr    $0xc,%edx
  800ec7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ece:	f6 c2 01             	test   $0x1,%dl
  800ed1:	74 1a                	je     800eed <fd_lookup+0x50>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800ed3:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ed6:	89 02                	mov    %eax,(%edx)
	return 0;
  800ed8:	b8 00 00 00 00       	mov    $0x0,%eax
  800edd:	eb 13                	jmp    800ef2 <fd_lookup+0x55>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800edf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ee4:	eb 0c                	jmp    800ef2 <fd_lookup+0x55>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800ee6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800eeb:	eb 05                	jmp    800ef2 <fd_lookup+0x55>
  800eed:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800ef2:	5d                   	pop    %ebp
  800ef3:	c3                   	ret    

00800ef4 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800ef4:	55                   	push   %ebp
  800ef5:	89 e5                	mov    %esp,%ebp
  800ef7:	53                   	push   %ebx
  800ef8:	83 ec 04             	sub    $0x4,%esp
  800efb:	8b 45 08             	mov    0x8(%ebp),%eax
  800efe:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  800f01:	3b 05 04 30 80 00    	cmp    0x803004,%eax
  800f07:	75 1e                	jne    800f27 <dev_lookup+0x33>
  800f09:	eb 0e                	jmp    800f19 <dev_lookup+0x25>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f0b:	b8 20 30 80 00       	mov    $0x803020,%eax
  800f10:	eb 0c                	jmp    800f1e <dev_lookup+0x2a>
  800f12:	b8 3c 30 80 00       	mov    $0x80303c,%eax
  800f17:	eb 05                	jmp    800f1e <dev_lookup+0x2a>
  800f19:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  800f1e:	89 03                	mov    %eax,(%ebx)
			return 0;
  800f20:	b8 00 00 00 00       	mov    $0x0,%eax
  800f25:	eb 36                	jmp    800f5d <dev_lookup+0x69>
int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  800f27:	3b 05 20 30 80 00    	cmp    0x803020,%eax
  800f2d:	74 dc                	je     800f0b <dev_lookup+0x17>
  800f2f:	3b 05 3c 30 80 00    	cmp    0x80303c,%eax
  800f35:	74 db                	je     800f12 <dev_lookup+0x1e>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f37:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800f3d:	8b 52 48             	mov    0x48(%edx),%edx
  800f40:	83 ec 04             	sub    $0x4,%esp
  800f43:	50                   	push   %eax
  800f44:	52                   	push   %edx
  800f45:	68 cc 27 80 00       	push   $0x8027cc
  800f4a:	e8 6d f2 ff ff       	call   8001bc <cprintf>
	*dev = 0;
  800f4f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  800f55:	83 c4 10             	add    $0x10,%esp
  800f58:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f5d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f60:	c9                   	leave  
  800f61:	c3                   	ret    

00800f62 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800f62:	55                   	push   %ebp
  800f63:	89 e5                	mov    %esp,%ebp
  800f65:	56                   	push   %esi
  800f66:	53                   	push   %ebx
  800f67:	83 ec 10             	sub    $0x10,%esp
  800f6a:	8b 75 08             	mov    0x8(%ebp),%esi
  800f6d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f70:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f73:	50                   	push   %eax
  800f74:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800f7a:	c1 e8 0c             	shr    $0xc,%eax
  800f7d:	50                   	push   %eax
  800f7e:	e8 1a ff ff ff       	call   800e9d <fd_lookup>
  800f83:	83 c4 08             	add    $0x8,%esp
  800f86:	85 c0                	test   %eax,%eax
  800f88:	78 05                	js     800f8f <fd_close+0x2d>
	    || fd != fd2)
  800f8a:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800f8d:	74 06                	je     800f95 <fd_close+0x33>
		return (must_exist ? r : 0);
  800f8f:	84 db                	test   %bl,%bl
  800f91:	74 47                	je     800fda <fd_close+0x78>
  800f93:	eb 4a                	jmp    800fdf <fd_close+0x7d>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f95:	83 ec 08             	sub    $0x8,%esp
  800f98:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800f9b:	50                   	push   %eax
  800f9c:	ff 36                	pushl  (%esi)
  800f9e:	e8 51 ff ff ff       	call   800ef4 <dev_lookup>
  800fa3:	89 c3                	mov    %eax,%ebx
  800fa5:	83 c4 10             	add    $0x10,%esp
  800fa8:	85 c0                	test   %eax,%eax
  800faa:	78 1c                	js     800fc8 <fd_close+0x66>
		if (dev->dev_close)
  800fac:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800faf:	8b 40 10             	mov    0x10(%eax),%eax
  800fb2:	85 c0                	test   %eax,%eax
  800fb4:	74 0d                	je     800fc3 <fd_close+0x61>
			r = (*dev->dev_close)(fd);
  800fb6:	83 ec 0c             	sub    $0xc,%esp
  800fb9:	56                   	push   %esi
  800fba:	ff d0                	call   *%eax
  800fbc:	89 c3                	mov    %eax,%ebx
  800fbe:	83 c4 10             	add    $0x10,%esp
  800fc1:	eb 05                	jmp    800fc8 <fd_close+0x66>
		else
			r = 0;
  800fc3:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800fc8:	83 ec 08             	sub    $0x8,%esp
  800fcb:	56                   	push   %esi
  800fcc:	6a 00                	push   $0x0
  800fce:	e8 c3 fc ff ff       	call   800c96 <sys_page_unmap>
	return r;
  800fd3:	83 c4 10             	add    $0x10,%esp
  800fd6:	89 d8                	mov    %ebx,%eax
  800fd8:	eb 05                	jmp    800fdf <fd_close+0x7d>
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
  800fda:	b8 00 00 00 00       	mov    $0x0,%eax
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
	return r;
}
  800fdf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fe2:	5b                   	pop    %ebx
  800fe3:	5e                   	pop    %esi
  800fe4:	5d                   	pop    %ebp
  800fe5:	c3                   	ret    

00800fe6 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800fe6:	55                   	push   %ebp
  800fe7:	89 e5                	mov    %esp,%ebp
  800fe9:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fec:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fef:	50                   	push   %eax
  800ff0:	ff 75 08             	pushl  0x8(%ebp)
  800ff3:	e8 a5 fe ff ff       	call   800e9d <fd_lookup>
  800ff8:	83 c4 08             	add    $0x8,%esp
  800ffb:	85 c0                	test   %eax,%eax
  800ffd:	78 10                	js     80100f <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800fff:	83 ec 08             	sub    $0x8,%esp
  801002:	6a 01                	push   $0x1
  801004:	ff 75 f4             	pushl  -0xc(%ebp)
  801007:	e8 56 ff ff ff       	call   800f62 <fd_close>
  80100c:	83 c4 10             	add    $0x10,%esp
}
  80100f:	c9                   	leave  
  801010:	c3                   	ret    

00801011 <close_all>:

void
close_all(void)
{
  801011:	55                   	push   %ebp
  801012:	89 e5                	mov    %esp,%ebp
  801014:	53                   	push   %ebx
  801015:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801018:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80101d:	83 ec 0c             	sub    $0xc,%esp
  801020:	53                   	push   %ebx
  801021:	e8 c0 ff ff ff       	call   800fe6 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801026:	43                   	inc    %ebx
  801027:	83 c4 10             	add    $0x10,%esp
  80102a:	83 fb 20             	cmp    $0x20,%ebx
  80102d:	75 ee                	jne    80101d <close_all+0xc>
		close(i);
}
  80102f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801032:	c9                   	leave  
  801033:	c3                   	ret    

00801034 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801034:	55                   	push   %ebp
  801035:	89 e5                	mov    %esp,%ebp
  801037:	57                   	push   %edi
  801038:	56                   	push   %esi
  801039:	53                   	push   %ebx
  80103a:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80103d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801040:	50                   	push   %eax
  801041:	ff 75 08             	pushl  0x8(%ebp)
  801044:	e8 54 fe ff ff       	call   800e9d <fd_lookup>
  801049:	83 c4 08             	add    $0x8,%esp
  80104c:	85 c0                	test   %eax,%eax
  80104e:	0f 88 c2 00 00 00    	js     801116 <dup+0xe2>
		return r;
	close(newfdnum);
  801054:	83 ec 0c             	sub    $0xc,%esp
  801057:	ff 75 0c             	pushl  0xc(%ebp)
  80105a:	e8 87 ff ff ff       	call   800fe6 <close>

	newfd = INDEX2FD(newfdnum);
  80105f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801062:	c1 e3 0c             	shl    $0xc,%ebx
  801065:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80106b:	83 c4 04             	add    $0x4,%esp
  80106e:	ff 75 e4             	pushl  -0x1c(%ebp)
  801071:	e8 9c fd ff ff       	call   800e12 <fd2data>
  801076:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  801078:	89 1c 24             	mov    %ebx,(%esp)
  80107b:	e8 92 fd ff ff       	call   800e12 <fd2data>
  801080:	83 c4 10             	add    $0x10,%esp
  801083:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801085:	89 f0                	mov    %esi,%eax
  801087:	c1 e8 16             	shr    $0x16,%eax
  80108a:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801091:	a8 01                	test   $0x1,%al
  801093:	74 35                	je     8010ca <dup+0x96>
  801095:	89 f0                	mov    %esi,%eax
  801097:	c1 e8 0c             	shr    $0xc,%eax
  80109a:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010a1:	f6 c2 01             	test   $0x1,%dl
  8010a4:	74 24                	je     8010ca <dup+0x96>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8010a6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010ad:	83 ec 0c             	sub    $0xc,%esp
  8010b0:	25 07 0e 00 00       	and    $0xe07,%eax
  8010b5:	50                   	push   %eax
  8010b6:	57                   	push   %edi
  8010b7:	6a 00                	push   $0x0
  8010b9:	56                   	push   %esi
  8010ba:	6a 00                	push   $0x0
  8010bc:	e8 93 fb ff ff       	call   800c54 <sys_page_map>
  8010c1:	89 c6                	mov    %eax,%esi
  8010c3:	83 c4 20             	add    $0x20,%esp
  8010c6:	85 c0                	test   %eax,%eax
  8010c8:	78 2c                	js     8010f6 <dup+0xc2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010ca:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8010cd:	89 d0                	mov    %edx,%eax
  8010cf:	c1 e8 0c             	shr    $0xc,%eax
  8010d2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010d9:	83 ec 0c             	sub    $0xc,%esp
  8010dc:	25 07 0e 00 00       	and    $0xe07,%eax
  8010e1:	50                   	push   %eax
  8010e2:	53                   	push   %ebx
  8010e3:	6a 00                	push   $0x0
  8010e5:	52                   	push   %edx
  8010e6:	6a 00                	push   $0x0
  8010e8:	e8 67 fb ff ff       	call   800c54 <sys_page_map>
  8010ed:	89 c6                	mov    %eax,%esi
  8010ef:	83 c4 20             	add    $0x20,%esp
  8010f2:	85 c0                	test   %eax,%eax
  8010f4:	79 1d                	jns    801113 <dup+0xdf>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8010f6:	83 ec 08             	sub    $0x8,%esp
  8010f9:	53                   	push   %ebx
  8010fa:	6a 00                	push   $0x0
  8010fc:	e8 95 fb ff ff       	call   800c96 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801101:	83 c4 08             	add    $0x8,%esp
  801104:	57                   	push   %edi
  801105:	6a 00                	push   $0x0
  801107:	e8 8a fb ff ff       	call   800c96 <sys_page_unmap>
	return r;
  80110c:	83 c4 10             	add    $0x10,%esp
  80110f:	89 f0                	mov    %esi,%eax
  801111:	eb 03                	jmp    801116 <dup+0xe2>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801113:	8b 45 0c             	mov    0xc(%ebp),%eax

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801116:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801119:	5b                   	pop    %ebx
  80111a:	5e                   	pop    %esi
  80111b:	5f                   	pop    %edi
  80111c:	5d                   	pop    %ebp
  80111d:	c3                   	ret    

0080111e <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80111e:	55                   	push   %ebp
  80111f:	89 e5                	mov    %esp,%ebp
  801121:	53                   	push   %ebx
  801122:	83 ec 14             	sub    $0x14,%esp
  801125:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801128:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80112b:	50                   	push   %eax
  80112c:	53                   	push   %ebx
  80112d:	e8 6b fd ff ff       	call   800e9d <fd_lookup>
  801132:	83 c4 08             	add    $0x8,%esp
  801135:	85 c0                	test   %eax,%eax
  801137:	78 67                	js     8011a0 <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801139:	83 ec 08             	sub    $0x8,%esp
  80113c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80113f:	50                   	push   %eax
  801140:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801143:	ff 30                	pushl  (%eax)
  801145:	e8 aa fd ff ff       	call   800ef4 <dev_lookup>
  80114a:	83 c4 10             	add    $0x10,%esp
  80114d:	85 c0                	test   %eax,%eax
  80114f:	78 4f                	js     8011a0 <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801151:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801154:	8b 42 08             	mov    0x8(%edx),%eax
  801157:	83 e0 03             	and    $0x3,%eax
  80115a:	83 f8 01             	cmp    $0x1,%eax
  80115d:	75 21                	jne    801180 <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80115f:	a1 04 40 80 00       	mov    0x804004,%eax
  801164:	8b 40 48             	mov    0x48(%eax),%eax
  801167:	83 ec 04             	sub    $0x4,%esp
  80116a:	53                   	push   %ebx
  80116b:	50                   	push   %eax
  80116c:	68 0d 28 80 00       	push   $0x80280d
  801171:	e8 46 f0 ff ff       	call   8001bc <cprintf>
		return -E_INVAL;
  801176:	83 c4 10             	add    $0x10,%esp
  801179:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80117e:	eb 20                	jmp    8011a0 <read+0x82>
	}
	if (!dev->dev_read)
  801180:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801183:	8b 40 08             	mov    0x8(%eax),%eax
  801186:	85 c0                	test   %eax,%eax
  801188:	74 11                	je     80119b <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80118a:	83 ec 04             	sub    $0x4,%esp
  80118d:	ff 75 10             	pushl  0x10(%ebp)
  801190:	ff 75 0c             	pushl  0xc(%ebp)
  801193:	52                   	push   %edx
  801194:	ff d0                	call   *%eax
  801196:	83 c4 10             	add    $0x10,%esp
  801199:	eb 05                	jmp    8011a0 <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80119b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8011a0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011a3:	c9                   	leave  
  8011a4:	c3                   	ret    

008011a5 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8011a5:	55                   	push   %ebp
  8011a6:	89 e5                	mov    %esp,%ebp
  8011a8:	57                   	push   %edi
  8011a9:	56                   	push   %esi
  8011aa:	53                   	push   %ebx
  8011ab:	83 ec 0c             	sub    $0xc,%esp
  8011ae:	8b 7d 08             	mov    0x8(%ebp),%edi
  8011b1:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011b4:	85 f6                	test   %esi,%esi
  8011b6:	74 31                	je     8011e9 <readn+0x44>
  8011b8:	b8 00 00 00 00       	mov    $0x0,%eax
  8011bd:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  8011c2:	83 ec 04             	sub    $0x4,%esp
  8011c5:	89 f2                	mov    %esi,%edx
  8011c7:	29 c2                	sub    %eax,%edx
  8011c9:	52                   	push   %edx
  8011ca:	03 45 0c             	add    0xc(%ebp),%eax
  8011cd:	50                   	push   %eax
  8011ce:	57                   	push   %edi
  8011cf:	e8 4a ff ff ff       	call   80111e <read>
		if (m < 0)
  8011d4:	83 c4 10             	add    $0x10,%esp
  8011d7:	85 c0                	test   %eax,%eax
  8011d9:	78 17                	js     8011f2 <readn+0x4d>
			return m;
		if (m == 0)
  8011db:	85 c0                	test   %eax,%eax
  8011dd:	74 11                	je     8011f0 <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011df:	01 c3                	add    %eax,%ebx
  8011e1:	89 d8                	mov    %ebx,%eax
  8011e3:	39 f3                	cmp    %esi,%ebx
  8011e5:	72 db                	jb     8011c2 <readn+0x1d>
  8011e7:	eb 09                	jmp    8011f2 <readn+0x4d>
  8011e9:	b8 00 00 00 00       	mov    $0x0,%eax
  8011ee:	eb 02                	jmp    8011f2 <readn+0x4d>
  8011f0:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8011f2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011f5:	5b                   	pop    %ebx
  8011f6:	5e                   	pop    %esi
  8011f7:	5f                   	pop    %edi
  8011f8:	5d                   	pop    %ebp
  8011f9:	c3                   	ret    

008011fa <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8011fa:	55                   	push   %ebp
  8011fb:	89 e5                	mov    %esp,%ebp
  8011fd:	53                   	push   %ebx
  8011fe:	83 ec 14             	sub    $0x14,%esp
  801201:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801204:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801207:	50                   	push   %eax
  801208:	53                   	push   %ebx
  801209:	e8 8f fc ff ff       	call   800e9d <fd_lookup>
  80120e:	83 c4 08             	add    $0x8,%esp
  801211:	85 c0                	test   %eax,%eax
  801213:	78 62                	js     801277 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801215:	83 ec 08             	sub    $0x8,%esp
  801218:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80121b:	50                   	push   %eax
  80121c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80121f:	ff 30                	pushl  (%eax)
  801221:	e8 ce fc ff ff       	call   800ef4 <dev_lookup>
  801226:	83 c4 10             	add    $0x10,%esp
  801229:	85 c0                	test   %eax,%eax
  80122b:	78 4a                	js     801277 <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80122d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801230:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801234:	75 21                	jne    801257 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801236:	a1 04 40 80 00       	mov    0x804004,%eax
  80123b:	8b 40 48             	mov    0x48(%eax),%eax
  80123e:	83 ec 04             	sub    $0x4,%esp
  801241:	53                   	push   %ebx
  801242:	50                   	push   %eax
  801243:	68 29 28 80 00       	push   $0x802829
  801248:	e8 6f ef ff ff       	call   8001bc <cprintf>
		return -E_INVAL;
  80124d:	83 c4 10             	add    $0x10,%esp
  801250:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801255:	eb 20                	jmp    801277 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801257:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80125a:	8b 52 0c             	mov    0xc(%edx),%edx
  80125d:	85 d2                	test   %edx,%edx
  80125f:	74 11                	je     801272 <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801261:	83 ec 04             	sub    $0x4,%esp
  801264:	ff 75 10             	pushl  0x10(%ebp)
  801267:	ff 75 0c             	pushl  0xc(%ebp)
  80126a:	50                   	push   %eax
  80126b:	ff d2                	call   *%edx
  80126d:	83 c4 10             	add    $0x10,%esp
  801270:	eb 05                	jmp    801277 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801272:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801277:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80127a:	c9                   	leave  
  80127b:	c3                   	ret    

0080127c <seek>:

int
seek(int fdnum, off_t offset)
{
  80127c:	55                   	push   %ebp
  80127d:	89 e5                	mov    %esp,%ebp
  80127f:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801282:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801285:	50                   	push   %eax
  801286:	ff 75 08             	pushl  0x8(%ebp)
  801289:	e8 0f fc ff ff       	call   800e9d <fd_lookup>
  80128e:	83 c4 08             	add    $0x8,%esp
  801291:	85 c0                	test   %eax,%eax
  801293:	78 0e                	js     8012a3 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801295:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801298:	8b 55 0c             	mov    0xc(%ebp),%edx
  80129b:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80129e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012a3:	c9                   	leave  
  8012a4:	c3                   	ret    

008012a5 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8012a5:	55                   	push   %ebp
  8012a6:	89 e5                	mov    %esp,%ebp
  8012a8:	53                   	push   %ebx
  8012a9:	83 ec 14             	sub    $0x14,%esp
  8012ac:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012af:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012b2:	50                   	push   %eax
  8012b3:	53                   	push   %ebx
  8012b4:	e8 e4 fb ff ff       	call   800e9d <fd_lookup>
  8012b9:	83 c4 08             	add    $0x8,%esp
  8012bc:	85 c0                	test   %eax,%eax
  8012be:	78 5f                	js     80131f <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012c0:	83 ec 08             	sub    $0x8,%esp
  8012c3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012c6:	50                   	push   %eax
  8012c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012ca:	ff 30                	pushl  (%eax)
  8012cc:	e8 23 fc ff ff       	call   800ef4 <dev_lookup>
  8012d1:	83 c4 10             	add    $0x10,%esp
  8012d4:	85 c0                	test   %eax,%eax
  8012d6:	78 47                	js     80131f <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012db:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012df:	75 21                	jne    801302 <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8012e1:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8012e6:	8b 40 48             	mov    0x48(%eax),%eax
  8012e9:	83 ec 04             	sub    $0x4,%esp
  8012ec:	53                   	push   %ebx
  8012ed:	50                   	push   %eax
  8012ee:	68 ec 27 80 00       	push   $0x8027ec
  8012f3:	e8 c4 ee ff ff       	call   8001bc <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8012f8:	83 c4 10             	add    $0x10,%esp
  8012fb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801300:	eb 1d                	jmp    80131f <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  801302:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801305:	8b 52 18             	mov    0x18(%edx),%edx
  801308:	85 d2                	test   %edx,%edx
  80130a:	74 0e                	je     80131a <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80130c:	83 ec 08             	sub    $0x8,%esp
  80130f:	ff 75 0c             	pushl  0xc(%ebp)
  801312:	50                   	push   %eax
  801313:	ff d2                	call   *%edx
  801315:	83 c4 10             	add    $0x10,%esp
  801318:	eb 05                	jmp    80131f <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80131a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  80131f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801322:	c9                   	leave  
  801323:	c3                   	ret    

00801324 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801324:	55                   	push   %ebp
  801325:	89 e5                	mov    %esp,%ebp
  801327:	53                   	push   %ebx
  801328:	83 ec 14             	sub    $0x14,%esp
  80132b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80132e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801331:	50                   	push   %eax
  801332:	ff 75 08             	pushl  0x8(%ebp)
  801335:	e8 63 fb ff ff       	call   800e9d <fd_lookup>
  80133a:	83 c4 08             	add    $0x8,%esp
  80133d:	85 c0                	test   %eax,%eax
  80133f:	78 52                	js     801393 <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801341:	83 ec 08             	sub    $0x8,%esp
  801344:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801347:	50                   	push   %eax
  801348:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80134b:	ff 30                	pushl  (%eax)
  80134d:	e8 a2 fb ff ff       	call   800ef4 <dev_lookup>
  801352:	83 c4 10             	add    $0x10,%esp
  801355:	85 c0                	test   %eax,%eax
  801357:	78 3a                	js     801393 <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  801359:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80135c:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801360:	74 2c                	je     80138e <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801362:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801365:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80136c:	00 00 00 
	stat->st_isdir = 0;
  80136f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801376:	00 00 00 
	stat->st_dev = dev;
  801379:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80137f:	83 ec 08             	sub    $0x8,%esp
  801382:	53                   	push   %ebx
  801383:	ff 75 f0             	pushl  -0x10(%ebp)
  801386:	ff 50 14             	call   *0x14(%eax)
  801389:	83 c4 10             	add    $0x10,%esp
  80138c:	eb 05                	jmp    801393 <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80138e:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801393:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801396:	c9                   	leave  
  801397:	c3                   	ret    

00801398 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801398:	55                   	push   %ebp
  801399:	89 e5                	mov    %esp,%ebp
  80139b:	56                   	push   %esi
  80139c:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80139d:	83 ec 08             	sub    $0x8,%esp
  8013a0:	6a 00                	push   $0x0
  8013a2:	ff 75 08             	pushl  0x8(%ebp)
  8013a5:	e8 75 01 00 00       	call   80151f <open>
  8013aa:	89 c3                	mov    %eax,%ebx
  8013ac:	83 c4 10             	add    $0x10,%esp
  8013af:	85 c0                	test   %eax,%eax
  8013b1:	78 1d                	js     8013d0 <stat+0x38>
		return fd;
	r = fstat(fd, stat);
  8013b3:	83 ec 08             	sub    $0x8,%esp
  8013b6:	ff 75 0c             	pushl  0xc(%ebp)
  8013b9:	50                   	push   %eax
  8013ba:	e8 65 ff ff ff       	call   801324 <fstat>
  8013bf:	89 c6                	mov    %eax,%esi
	close(fd);
  8013c1:	89 1c 24             	mov    %ebx,(%esp)
  8013c4:	e8 1d fc ff ff       	call   800fe6 <close>
	return r;
  8013c9:	83 c4 10             	add    $0x10,%esp
  8013cc:	89 f0                	mov    %esi,%eax
  8013ce:	eb 00                	jmp    8013d0 <stat+0x38>
}
  8013d0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013d3:	5b                   	pop    %ebx
  8013d4:	5e                   	pop    %esi
  8013d5:	5d                   	pop    %ebp
  8013d6:	c3                   	ret    

008013d7 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8013d7:	55                   	push   %ebp
  8013d8:	89 e5                	mov    %esp,%ebp
  8013da:	56                   	push   %esi
  8013db:	53                   	push   %ebx
  8013dc:	89 c6                	mov    %eax,%esi
  8013de:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8013e0:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8013e7:	75 12                	jne    8013fb <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8013e9:	83 ec 0c             	sub    $0xc,%esp
  8013ec:	6a 01                	push   $0x1
  8013ee:	e8 0f 0d 00 00       	call   802102 <ipc_find_env>
  8013f3:	a3 00 40 80 00       	mov    %eax,0x804000
  8013f8:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8013fb:	6a 07                	push   $0x7
  8013fd:	68 00 50 80 00       	push   $0x805000
  801402:	56                   	push   %esi
  801403:	ff 35 00 40 80 00    	pushl  0x804000
  801409:	e8 95 0c 00 00       	call   8020a3 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80140e:	83 c4 0c             	add    $0xc,%esp
  801411:	6a 00                	push   $0x0
  801413:	53                   	push   %ebx
  801414:	6a 00                	push   $0x0
  801416:	e8 13 0c 00 00       	call   80202e <ipc_recv>
}
  80141b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80141e:	5b                   	pop    %ebx
  80141f:	5e                   	pop    %esi
  801420:	5d                   	pop    %ebp
  801421:	c3                   	ret    

00801422 <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801422:	55                   	push   %ebp
  801423:	89 e5                	mov    %esp,%ebp
  801425:	53                   	push   %ebx
  801426:	83 ec 04             	sub    $0x4,%esp
  801429:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80142c:	8b 45 08             	mov    0x8(%ebp),%eax
  80142f:	8b 40 0c             	mov    0xc(%eax),%eax
  801432:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801437:	ba 00 00 00 00       	mov    $0x0,%edx
  80143c:	b8 05 00 00 00       	mov    $0x5,%eax
  801441:	e8 91 ff ff ff       	call   8013d7 <fsipc>
  801446:	85 c0                	test   %eax,%eax
  801448:	78 2c                	js     801476 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80144a:	83 ec 08             	sub    $0x8,%esp
  80144d:	68 00 50 80 00       	push   $0x805000
  801452:	53                   	push   %ebx
  801453:	e8 49 f3 ff ff       	call   8007a1 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801458:	a1 80 50 80 00       	mov    0x805080,%eax
  80145d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801463:	a1 84 50 80 00       	mov    0x805084,%eax
  801468:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80146e:	83 c4 10             	add    $0x10,%esp
  801471:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801476:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801479:	c9                   	leave  
  80147a:	c3                   	ret    

0080147b <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80147b:	55                   	push   %ebp
  80147c:	89 e5                	mov    %esp,%ebp
  80147e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801481:	8b 45 08             	mov    0x8(%ebp),%eax
  801484:	8b 40 0c             	mov    0xc(%eax),%eax
  801487:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80148c:	ba 00 00 00 00       	mov    $0x0,%edx
  801491:	b8 06 00 00 00       	mov    $0x6,%eax
  801496:	e8 3c ff ff ff       	call   8013d7 <fsipc>
}
  80149b:	c9                   	leave  
  80149c:	c3                   	ret    

0080149d <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80149d:	55                   	push   %ebp
  80149e:	89 e5                	mov    %esp,%ebp
  8014a0:	56                   	push   %esi
  8014a1:	53                   	push   %ebx
  8014a2:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8014a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8014a8:	8b 40 0c             	mov    0xc(%eax),%eax
  8014ab:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8014b0:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8014b6:	ba 00 00 00 00       	mov    $0x0,%edx
  8014bb:	b8 03 00 00 00       	mov    $0x3,%eax
  8014c0:	e8 12 ff ff ff       	call   8013d7 <fsipc>
  8014c5:	89 c3                	mov    %eax,%ebx
  8014c7:	85 c0                	test   %eax,%eax
  8014c9:	78 4b                	js     801516 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8014cb:	39 c6                	cmp    %eax,%esi
  8014cd:	73 16                	jae    8014e5 <devfile_read+0x48>
  8014cf:	68 46 28 80 00       	push   $0x802846
  8014d4:	68 4d 28 80 00       	push   $0x80284d
  8014d9:	6a 7a                	push   $0x7a
  8014db:	68 62 28 80 00       	push   $0x802862
  8014e0:	e8 ff eb ff ff       	call   8000e4 <_panic>
	assert(r <= PGSIZE);
  8014e5:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8014ea:	7e 16                	jle    801502 <devfile_read+0x65>
  8014ec:	68 6d 28 80 00       	push   $0x80286d
  8014f1:	68 4d 28 80 00       	push   $0x80284d
  8014f6:	6a 7b                	push   $0x7b
  8014f8:	68 62 28 80 00       	push   $0x802862
  8014fd:	e8 e2 eb ff ff       	call   8000e4 <_panic>
	memmove(buf, &fsipcbuf, r);
  801502:	83 ec 04             	sub    $0x4,%esp
  801505:	50                   	push   %eax
  801506:	68 00 50 80 00       	push   $0x805000
  80150b:	ff 75 0c             	pushl  0xc(%ebp)
  80150e:	e8 5b f4 ff ff       	call   80096e <memmove>
	return r;
  801513:	83 c4 10             	add    $0x10,%esp
}
  801516:	89 d8                	mov    %ebx,%eax
  801518:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80151b:	5b                   	pop    %ebx
  80151c:	5e                   	pop    %esi
  80151d:	5d                   	pop    %ebp
  80151e:	c3                   	ret    

0080151f <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80151f:	55                   	push   %ebp
  801520:	89 e5                	mov    %esp,%ebp
  801522:	53                   	push   %ebx
  801523:	83 ec 20             	sub    $0x20,%esp
  801526:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801529:	53                   	push   %ebx
  80152a:	e8 1b f2 ff ff       	call   80074a <strlen>
  80152f:	83 c4 10             	add    $0x10,%esp
  801532:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801537:	7f 63                	jg     80159c <open+0x7d>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801539:	83 ec 0c             	sub    $0xc,%esp
  80153c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80153f:	50                   	push   %eax
  801540:	e8 e4 f8 ff ff       	call   800e29 <fd_alloc>
  801545:	83 c4 10             	add    $0x10,%esp
  801548:	85 c0                	test   %eax,%eax
  80154a:	78 55                	js     8015a1 <open+0x82>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80154c:	83 ec 08             	sub    $0x8,%esp
  80154f:	53                   	push   %ebx
  801550:	68 00 50 80 00       	push   $0x805000
  801555:	e8 47 f2 ff ff       	call   8007a1 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80155a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80155d:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801562:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801565:	b8 01 00 00 00       	mov    $0x1,%eax
  80156a:	e8 68 fe ff ff       	call   8013d7 <fsipc>
  80156f:	89 c3                	mov    %eax,%ebx
  801571:	83 c4 10             	add    $0x10,%esp
  801574:	85 c0                	test   %eax,%eax
  801576:	79 14                	jns    80158c <open+0x6d>
		fd_close(fd, 0);
  801578:	83 ec 08             	sub    $0x8,%esp
  80157b:	6a 00                	push   $0x0
  80157d:	ff 75 f4             	pushl  -0xc(%ebp)
  801580:	e8 dd f9 ff ff       	call   800f62 <fd_close>
		return r;
  801585:	83 c4 10             	add    $0x10,%esp
  801588:	89 d8                	mov    %ebx,%eax
  80158a:	eb 15                	jmp    8015a1 <open+0x82>
	}

	return fd2num(fd);
  80158c:	83 ec 0c             	sub    $0xc,%esp
  80158f:	ff 75 f4             	pushl  -0xc(%ebp)
  801592:	e8 6b f8 ff ff       	call   800e02 <fd2num>
  801597:	83 c4 10             	add    $0x10,%esp
  80159a:	eb 05                	jmp    8015a1 <open+0x82>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80159c:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8015a1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015a4:	c9                   	leave  
  8015a5:	c3                   	ret    

008015a6 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  8015a6:	55                   	push   %ebp
  8015a7:	89 e5                	mov    %esp,%ebp
  8015a9:	57                   	push   %edi
  8015aa:	56                   	push   %esi
  8015ab:	53                   	push   %ebx
  8015ac:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  8015b2:	6a 00                	push   $0x0
  8015b4:	ff 75 08             	pushl  0x8(%ebp)
  8015b7:	e8 63 ff ff ff       	call   80151f <open>
  8015bc:	89 c1                	mov    %eax,%ecx
  8015be:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  8015c4:	83 c4 10             	add    $0x10,%esp
  8015c7:	85 c0                	test   %eax,%eax
  8015c9:	0f 88 6f 04 00 00    	js     801a3e <spawn+0x498>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  8015cf:	83 ec 04             	sub    $0x4,%esp
  8015d2:	68 00 02 00 00       	push   $0x200
  8015d7:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  8015dd:	50                   	push   %eax
  8015de:	51                   	push   %ecx
  8015df:	e8 c1 fb ff ff       	call   8011a5 <readn>
  8015e4:	83 c4 10             	add    $0x10,%esp
  8015e7:	3d 00 02 00 00       	cmp    $0x200,%eax
  8015ec:	75 0c                	jne    8015fa <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  8015ee:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  8015f5:	45 4c 46 
  8015f8:	74 33                	je     80162d <spawn+0x87>
		close(fd);
  8015fa:	83 ec 0c             	sub    $0xc,%esp
  8015fd:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801603:	e8 de f9 ff ff       	call   800fe6 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801608:	83 c4 0c             	add    $0xc,%esp
  80160b:	68 7f 45 4c 46       	push   $0x464c457f
  801610:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  801616:	68 79 28 80 00       	push   $0x802879
  80161b:	e8 9c eb ff ff       	call   8001bc <cprintf>
		return -E_NOT_EXEC;
  801620:	83 c4 10             	add    $0x10,%esp
  801623:	bb f2 ff ff ff       	mov    $0xfffffff2,%ebx
  801628:	e9 71 04 00 00       	jmp    801a9e <spawn+0x4f8>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  80162d:	b8 07 00 00 00       	mov    $0x7,%eax
  801632:	cd 30                	int    $0x30
  801634:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  80163a:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801640:	85 c0                	test   %eax,%eax
  801642:	0f 88 fe 03 00 00    	js     801a46 <spawn+0x4a0>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801648:	89 c6                	mov    %eax,%esi
  80164a:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  801650:	8d 04 b5 00 00 00 00 	lea    0x0(,%esi,4),%eax
  801657:	c1 e6 07             	shl    $0x7,%esi
  80165a:	29 c6                	sub    %eax,%esi
  80165c:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  801662:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801668:	b9 11 00 00 00       	mov    $0x11,%ecx
  80166d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  80166f:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801675:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  80167b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80167e:	8b 00                	mov    (%eax),%eax
  801680:	85 c0                	test   %eax,%eax
  801682:	74 3a                	je     8016be <spawn+0x118>
  801684:	bb 00 00 00 00       	mov    $0x0,%ebx
  801689:	be 00 00 00 00       	mov    $0x0,%esi
  80168e:	8b 7d 0c             	mov    0xc(%ebp),%edi
		string_size += strlen(argv[argc]) + 1;
  801691:	83 ec 0c             	sub    $0xc,%esp
  801694:	50                   	push   %eax
  801695:	e8 b0 f0 ff ff       	call   80074a <strlen>
  80169a:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  80169e:	43                   	inc    %ebx
  80169f:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  8016a6:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  8016a9:	83 c4 10             	add    $0x10,%esp
  8016ac:	85 c0                	test   %eax,%eax
  8016ae:	75 e1                	jne    801691 <spawn+0xeb>
  8016b0:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  8016b6:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
  8016bc:	eb 1e                	jmp    8016dc <spawn+0x136>
  8016be:	c7 85 80 fd ff ff 00 	movl   $0x0,-0x280(%ebp)
  8016c5:	00 00 00 
  8016c8:	c7 85 88 fd ff ff 00 	movl   $0x0,-0x278(%ebp)
  8016cf:	00 00 00 
  8016d2:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  8016d7:	be 00 00 00 00       	mov    $0x0,%esi
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  8016dc:	bf 00 10 40 00       	mov    $0x401000,%edi
  8016e1:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  8016e3:	89 fa                	mov    %edi,%edx
  8016e5:	83 e2 fc             	and    $0xfffffffc,%edx
  8016e8:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  8016ef:	29 c2                	sub    %eax,%edx
  8016f1:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  8016f7:	8d 42 f8             	lea    -0x8(%edx),%eax
  8016fa:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  8016ff:	0f 86 51 03 00 00    	jbe    801a56 <spawn+0x4b0>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801705:	83 ec 04             	sub    $0x4,%esp
  801708:	6a 07                	push   $0x7
  80170a:	68 00 00 40 00       	push   $0x400000
  80170f:	6a 00                	push   $0x0
  801711:	e8 fb f4 ff ff       	call   800c11 <sys_page_alloc>
  801716:	83 c4 10             	add    $0x10,%esp
  801719:	85 c0                	test   %eax,%eax
  80171b:	0f 88 3c 03 00 00    	js     801a5d <spawn+0x4b7>
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801721:	85 db                	test   %ebx,%ebx
  801723:	7e 44                	jle    801769 <spawn+0x1c3>
  801725:	be 00 00 00 00       	mov    $0x0,%esi
  80172a:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  801730:	8b 5d 0c             	mov    0xc(%ebp),%ebx
		argv_store[i] = UTEMP2USTACK(string_store);
  801733:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801739:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  80173f:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  801742:	83 ec 08             	sub    $0x8,%esp
  801745:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801748:	57                   	push   %edi
  801749:	e8 53 f0 ff ff       	call   8007a1 <strcpy>
		string_store += strlen(argv[i]) + 1;
  80174e:	83 c4 04             	add    $0x4,%esp
  801751:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801754:	e8 f1 ef ff ff       	call   80074a <strlen>
  801759:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  80175d:	46                   	inc    %esi
  80175e:	83 c4 10             	add    $0x10,%esp
  801761:	3b b5 90 fd ff ff    	cmp    -0x270(%ebp),%esi
  801767:	75 ca                	jne    801733 <spawn+0x18d>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  801769:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  80176f:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  801775:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  80177c:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801782:	74 19                	je     80179d <spawn+0x1f7>
  801784:	68 f0 28 80 00       	push   $0x8028f0
  801789:	68 4d 28 80 00       	push   $0x80284d
  80178e:	68 f1 00 00 00       	push   $0xf1
  801793:	68 93 28 80 00       	push   $0x802893
  801798:	e8 47 e9 ff ff       	call   8000e4 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  80179d:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  8017a3:	89 c8                	mov    %ecx,%eax
  8017a5:	2d 00 30 80 11       	sub    $0x11803000,%eax
  8017aa:	89 41 fc             	mov    %eax,-0x4(%ecx)
	argv_store[-2] = argc;
  8017ad:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  8017b3:	89 41 f8             	mov    %eax,-0x8(%ecx)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  8017b6:	8d 81 f8 cf 7f ee    	lea    -0x11803008(%ecx),%eax
  8017bc:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  8017c2:	83 ec 0c             	sub    $0xc,%esp
  8017c5:	6a 07                	push   $0x7
  8017c7:	68 00 d0 bf ee       	push   $0xeebfd000
  8017cc:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  8017d2:	68 00 00 40 00       	push   $0x400000
  8017d7:	6a 00                	push   $0x0
  8017d9:	e8 76 f4 ff ff       	call   800c54 <sys_page_map>
  8017de:	89 c3                	mov    %eax,%ebx
  8017e0:	83 c4 20             	add    $0x20,%esp
  8017e3:	85 c0                	test   %eax,%eax
  8017e5:	0f 88 a1 02 00 00    	js     801a8c <spawn+0x4e6>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  8017eb:	83 ec 08             	sub    $0x8,%esp
  8017ee:	68 00 00 40 00       	push   $0x400000
  8017f3:	6a 00                	push   $0x0
  8017f5:	e8 9c f4 ff ff       	call   800c96 <sys_page_unmap>
  8017fa:	89 c3                	mov    %eax,%ebx
  8017fc:	83 c4 10             	add    $0x10,%esp
  8017ff:	85 c0                	test   %eax,%eax
  801801:	0f 88 85 02 00 00    	js     801a8c <spawn+0x4e6>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801807:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  80180d:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  801814:	89 85 78 fd ff ff    	mov    %eax,-0x288(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  80181a:	66 83 bd 14 fe ff ff 	cmpw   $0x0,-0x1ec(%ebp)
  801821:	00 
  801822:	0f 84 ab 01 00 00    	je     8019d3 <spawn+0x42d>
  801828:	c7 85 80 fd ff ff 00 	movl   $0x0,-0x280(%ebp)
  80182f:	00 00 00 
		if (ph->p_type != ELF_PROG_LOAD)
  801832:	8b 85 78 fd ff ff    	mov    -0x288(%ebp),%eax
  801838:	83 38 01             	cmpl   $0x1,(%eax)
  80183b:	0f 85 70 01 00 00    	jne    8019b1 <spawn+0x40b>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801841:	89 c1                	mov    %eax,%ecx
  801843:	8b 40 18             	mov    0x18(%eax),%eax
  801846:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  801849:	83 f8 01             	cmp    $0x1,%eax
  80184c:	19 c0                	sbb    %eax,%eax
  80184e:	83 e0 fe             	and    $0xfffffffe,%eax
  801851:	83 c0 07             	add    $0x7,%eax
  801854:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  80185a:	89 c8                	mov    %ecx,%eax
  80185c:	8b 49 04             	mov    0x4(%ecx),%ecx
  80185f:	89 8d 7c fd ff ff    	mov    %ecx,-0x284(%ebp)
  801865:	8b 50 10             	mov    0x10(%eax),%edx
  801868:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)
  80186e:	8b 78 14             	mov    0x14(%eax),%edi
  801871:	89 bd 90 fd ff ff    	mov    %edi,-0x270(%ebp)
  801877:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  80187a:	89 f0                	mov    %esi,%eax
  80187c:	25 ff 0f 00 00       	and    $0xfff,%eax
  801881:	74 1a                	je     80189d <spawn+0x2f7>
		va -= i;
  801883:	29 c6                	sub    %eax,%esi
		memsz += i;
  801885:	01 c7                	add    %eax,%edi
  801887:	89 bd 90 fd ff ff    	mov    %edi,-0x270(%ebp)
		filesz += i;
  80188d:	01 c2                	add    %eax,%edx
  80188f:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)
		fileoffset -= i;
  801895:	29 c1                	sub    %eax,%ecx
  801897:	89 8d 7c fd ff ff    	mov    %ecx,-0x284(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  80189d:	83 bd 90 fd ff ff 00 	cmpl   $0x0,-0x270(%ebp)
  8018a4:	0f 84 07 01 00 00    	je     8019b1 <spawn+0x40b>
  8018aa:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (i >= filesz) {
  8018af:	39 9d 94 fd ff ff    	cmp    %ebx,-0x26c(%ebp)
  8018b5:	77 27                	ja     8018de <spawn+0x338>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  8018b7:	83 ec 04             	sub    $0x4,%esp
  8018ba:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  8018c0:	56                   	push   %esi
  8018c1:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  8018c7:	e8 45 f3 ff ff       	call   800c11 <sys_page_alloc>
  8018cc:	83 c4 10             	add    $0x10,%esp
  8018cf:	85 c0                	test   %eax,%eax
  8018d1:	0f 89 c2 00 00 00    	jns    801999 <spawn+0x3f3>
  8018d7:	89 c3                	mov    %eax,%ebx
  8018d9:	e9 8d 01 00 00       	jmp    801a6b <spawn+0x4c5>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8018de:	83 ec 04             	sub    $0x4,%esp
  8018e1:	6a 07                	push   $0x7
  8018e3:	68 00 00 40 00       	push   $0x400000
  8018e8:	6a 00                	push   $0x0
  8018ea:	e8 22 f3 ff ff       	call   800c11 <sys_page_alloc>
  8018ef:	83 c4 10             	add    $0x10,%esp
  8018f2:	85 c0                	test   %eax,%eax
  8018f4:	0f 88 67 01 00 00    	js     801a61 <spawn+0x4bb>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  8018fa:	83 ec 08             	sub    $0x8,%esp
  8018fd:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  801903:	01 d8                	add    %ebx,%eax
  801905:	50                   	push   %eax
  801906:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  80190c:	e8 6b f9 ff ff       	call   80127c <seek>
  801911:	83 c4 10             	add    $0x10,%esp
  801914:	85 c0                	test   %eax,%eax
  801916:	0f 88 49 01 00 00    	js     801a65 <spawn+0x4bf>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  80191c:	83 ec 04             	sub    $0x4,%esp
  80191f:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801925:	29 d8                	sub    %ebx,%eax
  801927:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80192c:	76 05                	jbe    801933 <spawn+0x38d>
  80192e:	b8 00 10 00 00       	mov    $0x1000,%eax
  801933:	50                   	push   %eax
  801934:	68 00 00 40 00       	push   $0x400000
  801939:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  80193f:	e8 61 f8 ff ff       	call   8011a5 <readn>
  801944:	83 c4 10             	add    $0x10,%esp
  801947:	85 c0                	test   %eax,%eax
  801949:	0f 88 1a 01 00 00    	js     801a69 <spawn+0x4c3>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  80194f:	83 ec 0c             	sub    $0xc,%esp
  801952:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801958:	56                   	push   %esi
  801959:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  80195f:	68 00 00 40 00       	push   $0x400000
  801964:	6a 00                	push   $0x0
  801966:	e8 e9 f2 ff ff       	call   800c54 <sys_page_map>
  80196b:	83 c4 20             	add    $0x20,%esp
  80196e:	85 c0                	test   %eax,%eax
  801970:	79 15                	jns    801987 <spawn+0x3e1>
				panic("spawn: sys_page_map data: %e", r);
  801972:	50                   	push   %eax
  801973:	68 9f 28 80 00       	push   $0x80289f
  801978:	68 24 01 00 00       	push   $0x124
  80197d:	68 93 28 80 00       	push   $0x802893
  801982:	e8 5d e7 ff ff       	call   8000e4 <_panic>
			sys_page_unmap(0, UTEMP);
  801987:	83 ec 08             	sub    $0x8,%esp
  80198a:	68 00 00 40 00       	push   $0x400000
  80198f:	6a 00                	push   $0x0
  801991:	e8 00 f3 ff ff       	call   800c96 <sys_page_unmap>
  801996:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801999:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80199f:	81 c6 00 10 00 00    	add    $0x1000,%esi
  8019a5:	3b 9d 90 fd ff ff    	cmp    -0x270(%ebp),%ebx
  8019ab:	0f 82 fe fe ff ff    	jb     8018af <spawn+0x309>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  8019b1:	ff 85 80 fd ff ff    	incl   -0x280(%ebp)
  8019b7:	8b 95 80 fd ff ff    	mov    -0x280(%ebp),%edx
  8019bd:	83 85 78 fd ff ff 20 	addl   $0x20,-0x288(%ebp)
  8019c4:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  8019cb:	39 d0                	cmp    %edx,%eax
  8019cd:	0f 8f 5f fe ff ff    	jg     801832 <spawn+0x28c>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  8019d3:	83 ec 0c             	sub    $0xc,%esp
  8019d6:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8019dc:	e8 05 f6 ff ff       	call   800fe6 <close>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  8019e1:	83 c4 08             	add    $0x8,%esp
  8019e4:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  8019ea:	50                   	push   %eax
  8019eb:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  8019f1:	e8 24 f3 ff ff       	call   800d1a <sys_env_set_trapframe>
  8019f6:	83 c4 10             	add    $0x10,%esp
  8019f9:	85 c0                	test   %eax,%eax
  8019fb:	79 15                	jns    801a12 <spawn+0x46c>
		panic("sys_env_set_trapframe: %e", r);
  8019fd:	50                   	push   %eax
  8019fe:	68 bc 28 80 00       	push   $0x8028bc
  801a03:	68 85 00 00 00       	push   $0x85
  801a08:	68 93 28 80 00       	push   $0x802893
  801a0d:	e8 d2 e6 ff ff       	call   8000e4 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801a12:	83 ec 08             	sub    $0x8,%esp
  801a15:	6a 02                	push   $0x2
  801a17:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801a1d:	e8 b6 f2 ff ff       	call   800cd8 <sys_env_set_status>
  801a22:	83 c4 10             	add    $0x10,%esp
  801a25:	85 c0                	test   %eax,%eax
  801a27:	79 25                	jns    801a4e <spawn+0x4a8>
		panic("sys_env_set_status: %e", r);
  801a29:	50                   	push   %eax
  801a2a:	68 d6 28 80 00       	push   $0x8028d6
  801a2f:	68 88 00 00 00       	push   $0x88
  801a34:	68 93 28 80 00       	push   $0x802893
  801a39:	e8 a6 e6 ff ff       	call   8000e4 <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  801a3e:	8b 9d 8c fd ff ff    	mov    -0x274(%ebp),%ebx
  801a44:	eb 58                	jmp    801a9e <spawn+0x4f8>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  801a46:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801a4c:	eb 50                	jmp    801a9e <spawn+0x4f8>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  801a4e:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801a54:	eb 48                	jmp    801a9e <spawn+0x4f8>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  801a56:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
  801a5b:	eb 41                	jmp    801a9e <spawn+0x4f8>

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		return r;
  801a5d:	89 c3                	mov    %eax,%ebx
  801a5f:	eb 3d                	jmp    801a9e <spawn+0x4f8>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801a61:	89 c3                	mov    %eax,%ebx
  801a63:	eb 06                	jmp    801a6b <spawn+0x4c5>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801a65:	89 c3                	mov    %eax,%ebx
  801a67:	eb 02                	jmp    801a6b <spawn+0x4c5>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801a69:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  801a6b:	83 ec 0c             	sub    $0xc,%esp
  801a6e:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801a74:	e8 19 f1 ff ff       	call   800b92 <sys_env_destroy>
	close(fd);
  801a79:	83 c4 04             	add    $0x4,%esp
  801a7c:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801a82:	e8 5f f5 ff ff       	call   800fe6 <close>
	return r;
  801a87:	83 c4 10             	add    $0x10,%esp
  801a8a:	eb 12                	jmp    801a9e <spawn+0x4f8>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  801a8c:	83 ec 08             	sub    $0x8,%esp
  801a8f:	68 00 00 40 00       	push   $0x400000
  801a94:	6a 00                	push   $0x0
  801a96:	e8 fb f1 ff ff       	call   800c96 <sys_page_unmap>
  801a9b:	83 c4 10             	add    $0x10,%esp

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  801a9e:	89 d8                	mov    %ebx,%eax
  801aa0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801aa3:	5b                   	pop    %ebx
  801aa4:	5e                   	pop    %esi
  801aa5:	5f                   	pop    %edi
  801aa6:	5d                   	pop    %ebp
  801aa7:	c3                   	ret    

00801aa8 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  801aa8:	55                   	push   %ebp
  801aa9:	89 e5                	mov    %esp,%ebp
  801aab:	57                   	push   %edi
  801aac:	56                   	push   %esi
  801aad:	53                   	push   %ebx
  801aae:	83 ec 1c             	sub    $0x1c,%esp
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801ab1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801ab5:	74 5f                	je     801b16 <spawnl+0x6e>
  801ab7:	8d 45 14             	lea    0x14(%ebp),%eax
  801aba:	ba 00 00 00 00       	mov    $0x0,%edx
  801abf:	eb 02                	jmp    801ac3 <spawnl+0x1b>
		argc++;
  801ac1:	89 ca                	mov    %ecx,%edx
  801ac3:	8d 4a 01             	lea    0x1(%edx),%ecx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801ac6:	83 c0 04             	add    $0x4,%eax
  801ac9:	83 78 fc 00          	cmpl   $0x0,-0x4(%eax)
  801acd:	75 f2                	jne    801ac1 <spawnl+0x19>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801acf:	8d 04 95 1e 00 00 00 	lea    0x1e(,%edx,4),%eax
  801ad6:	83 e0 f0             	and    $0xfffffff0,%eax
  801ad9:	29 c4                	sub    %eax,%esp
  801adb:	8d 44 24 03          	lea    0x3(%esp),%eax
  801adf:	c1 e8 02             	shr    $0x2,%eax
  801ae2:	8d 34 85 00 00 00 00 	lea    0x0(,%eax,4),%esi
  801ae9:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  801aeb:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801aee:	89 3c 85 00 00 00 00 	mov    %edi,0x0(,%eax,4)
	argv[argc+1] = NULL;
  801af5:	c7 44 96 08 00 00 00 	movl   $0x0,0x8(%esi,%edx,4)
  801afc:	00 

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801afd:	89 ce                	mov    %ecx,%esi
  801aff:	85 c9                	test   %ecx,%ecx
  801b01:	74 23                	je     801b26 <spawnl+0x7e>
  801b03:	b8 00 00 00 00       	mov    $0x0,%eax
		argv[i+1] = va_arg(vl, const char *);
  801b08:	40                   	inc    %eax
  801b09:	8b 54 85 0c          	mov    0xc(%ebp,%eax,4),%edx
  801b0d:	89 14 83             	mov    %edx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801b10:	39 f0                	cmp    %esi,%eax
  801b12:	75 f4                	jne    801b08 <spawnl+0x60>
  801b14:	eb 10                	jmp    801b26 <spawnl+0x7e>
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
	argv[0] = arg0;
  801b16:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b19:	89 45 e0             	mov    %eax,-0x20(%ebp)
	argv[argc+1] = NULL;
  801b1c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801b23:	8d 5d e0             	lea    -0x20(%ebp),%ebx
	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  801b26:	83 ec 08             	sub    $0x8,%esp
  801b29:	53                   	push   %ebx
  801b2a:	ff 75 08             	pushl  0x8(%ebp)
  801b2d:	e8 74 fa ff ff       	call   8015a6 <spawn>
}
  801b32:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b35:	5b                   	pop    %ebx
  801b36:	5e                   	pop    %esi
  801b37:	5f                   	pop    %edi
  801b38:	5d                   	pop    %ebp
  801b39:	c3                   	ret    

00801b3a <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801b3a:	55                   	push   %ebp
  801b3b:	89 e5                	mov    %esp,%ebp
  801b3d:	56                   	push   %esi
  801b3e:	53                   	push   %ebx
  801b3f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801b42:	83 ec 0c             	sub    $0xc,%esp
  801b45:	ff 75 08             	pushl  0x8(%ebp)
  801b48:	e8 c5 f2 ff ff       	call   800e12 <fd2data>
  801b4d:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801b4f:	83 c4 08             	add    $0x8,%esp
  801b52:	68 18 29 80 00       	push   $0x802918
  801b57:	53                   	push   %ebx
  801b58:	e8 44 ec ff ff       	call   8007a1 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801b5d:	8b 46 04             	mov    0x4(%esi),%eax
  801b60:	2b 06                	sub    (%esi),%eax
  801b62:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801b68:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801b6f:	00 00 00 
	stat->st_dev = &devpipe;
  801b72:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801b79:	30 80 00 
	return 0;
}
  801b7c:	b8 00 00 00 00       	mov    $0x0,%eax
  801b81:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b84:	5b                   	pop    %ebx
  801b85:	5e                   	pop    %esi
  801b86:	5d                   	pop    %ebp
  801b87:	c3                   	ret    

00801b88 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801b88:	55                   	push   %ebp
  801b89:	89 e5                	mov    %esp,%ebp
  801b8b:	53                   	push   %ebx
  801b8c:	83 ec 0c             	sub    $0xc,%esp
  801b8f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801b92:	53                   	push   %ebx
  801b93:	6a 00                	push   $0x0
  801b95:	e8 fc f0 ff ff       	call   800c96 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801b9a:	89 1c 24             	mov    %ebx,(%esp)
  801b9d:	e8 70 f2 ff ff       	call   800e12 <fd2data>
  801ba2:	83 c4 08             	add    $0x8,%esp
  801ba5:	50                   	push   %eax
  801ba6:	6a 00                	push   $0x0
  801ba8:	e8 e9 f0 ff ff       	call   800c96 <sys_page_unmap>
}
  801bad:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bb0:	c9                   	leave  
  801bb1:	c3                   	ret    

00801bb2 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801bb2:	55                   	push   %ebp
  801bb3:	89 e5                	mov    %esp,%ebp
  801bb5:	57                   	push   %edi
  801bb6:	56                   	push   %esi
  801bb7:	53                   	push   %ebx
  801bb8:	83 ec 1c             	sub    $0x1c,%esp
  801bbb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801bbe:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801bc0:	a1 04 40 80 00       	mov    0x804004,%eax
  801bc5:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801bc8:	83 ec 0c             	sub    $0xc,%esp
  801bcb:	ff 75 e0             	pushl  -0x20(%ebp)
  801bce:	e8 8a 05 00 00       	call   80215d <pageref>
  801bd3:	89 c3                	mov    %eax,%ebx
  801bd5:	89 3c 24             	mov    %edi,(%esp)
  801bd8:	e8 80 05 00 00       	call   80215d <pageref>
  801bdd:	83 c4 10             	add    $0x10,%esp
  801be0:	39 c3                	cmp    %eax,%ebx
  801be2:	0f 94 c1             	sete   %cl
  801be5:	0f b6 c9             	movzbl %cl,%ecx
  801be8:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801beb:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801bf1:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801bf4:	39 ce                	cmp    %ecx,%esi
  801bf6:	74 1b                	je     801c13 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801bf8:	39 c3                	cmp    %eax,%ebx
  801bfa:	75 c4                	jne    801bc0 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801bfc:	8b 42 58             	mov    0x58(%edx),%eax
  801bff:	ff 75 e4             	pushl  -0x1c(%ebp)
  801c02:	50                   	push   %eax
  801c03:	56                   	push   %esi
  801c04:	68 1f 29 80 00       	push   $0x80291f
  801c09:	e8 ae e5 ff ff       	call   8001bc <cprintf>
  801c0e:	83 c4 10             	add    $0x10,%esp
  801c11:	eb ad                	jmp    801bc0 <_pipeisclosed+0xe>
	}
}
  801c13:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c16:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c19:	5b                   	pop    %ebx
  801c1a:	5e                   	pop    %esi
  801c1b:	5f                   	pop    %edi
  801c1c:	5d                   	pop    %ebp
  801c1d:	c3                   	ret    

00801c1e <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801c1e:	55                   	push   %ebp
  801c1f:	89 e5                	mov    %esp,%ebp
  801c21:	57                   	push   %edi
  801c22:	56                   	push   %esi
  801c23:	53                   	push   %ebx
  801c24:	83 ec 18             	sub    $0x18,%esp
  801c27:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801c2a:	56                   	push   %esi
  801c2b:	e8 e2 f1 ff ff       	call   800e12 <fd2data>
  801c30:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c32:	83 c4 10             	add    $0x10,%esp
  801c35:	bf 00 00 00 00       	mov    $0x0,%edi
  801c3a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801c3e:	75 42                	jne    801c82 <devpipe_write+0x64>
  801c40:	eb 4e                	jmp    801c90 <devpipe_write+0x72>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801c42:	89 da                	mov    %ebx,%edx
  801c44:	89 f0                	mov    %esi,%eax
  801c46:	e8 67 ff ff ff       	call   801bb2 <_pipeisclosed>
  801c4b:	85 c0                	test   %eax,%eax
  801c4d:	75 46                	jne    801c95 <devpipe_write+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801c4f:	e8 9e ef ff ff       	call   800bf2 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801c54:	8b 53 04             	mov    0x4(%ebx),%edx
  801c57:	8b 03                	mov    (%ebx),%eax
  801c59:	83 c0 20             	add    $0x20,%eax
  801c5c:	39 c2                	cmp    %eax,%edx
  801c5e:	73 e2                	jae    801c42 <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801c60:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c63:	8a 0c 38             	mov    (%eax,%edi,1),%cl
  801c66:	89 d0                	mov    %edx,%eax
  801c68:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801c6d:	79 05                	jns    801c74 <devpipe_write+0x56>
  801c6f:	48                   	dec    %eax
  801c70:	83 c8 e0             	or     $0xffffffe0,%eax
  801c73:	40                   	inc    %eax
  801c74:	88 4c 03 08          	mov    %cl,0x8(%ebx,%eax,1)
		p->p_wpos++;
  801c78:	42                   	inc    %edx
  801c79:	89 53 04             	mov    %edx,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c7c:	47                   	inc    %edi
  801c7d:	39 7d 10             	cmp    %edi,0x10(%ebp)
  801c80:	74 0e                	je     801c90 <devpipe_write+0x72>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801c82:	8b 53 04             	mov    0x4(%ebx),%edx
  801c85:	8b 03                	mov    (%ebx),%eax
  801c87:	83 c0 20             	add    $0x20,%eax
  801c8a:	39 c2                	cmp    %eax,%edx
  801c8c:	73 b4                	jae    801c42 <devpipe_write+0x24>
  801c8e:	eb d0                	jmp    801c60 <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801c90:	8b 45 10             	mov    0x10(%ebp),%eax
  801c93:	eb 05                	jmp    801c9a <devpipe_write+0x7c>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c95:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801c9a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c9d:	5b                   	pop    %ebx
  801c9e:	5e                   	pop    %esi
  801c9f:	5f                   	pop    %edi
  801ca0:	5d                   	pop    %ebp
  801ca1:	c3                   	ret    

00801ca2 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ca2:	55                   	push   %ebp
  801ca3:	89 e5                	mov    %esp,%ebp
  801ca5:	57                   	push   %edi
  801ca6:	56                   	push   %esi
  801ca7:	53                   	push   %ebx
  801ca8:	83 ec 18             	sub    $0x18,%esp
  801cab:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801cae:	57                   	push   %edi
  801caf:	e8 5e f1 ff ff       	call   800e12 <fd2data>
  801cb4:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801cb6:	83 c4 10             	add    $0x10,%esp
  801cb9:	be 00 00 00 00       	mov    $0x0,%esi
  801cbe:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801cc2:	75 3d                	jne    801d01 <devpipe_read+0x5f>
  801cc4:	eb 48                	jmp    801d0e <devpipe_read+0x6c>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  801cc6:	89 f0                	mov    %esi,%eax
  801cc8:	eb 4e                	jmp    801d18 <devpipe_read+0x76>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801cca:	89 da                	mov    %ebx,%edx
  801ccc:	89 f8                	mov    %edi,%eax
  801cce:	e8 df fe ff ff       	call   801bb2 <_pipeisclosed>
  801cd3:	85 c0                	test   %eax,%eax
  801cd5:	75 3c                	jne    801d13 <devpipe_read+0x71>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801cd7:	e8 16 ef ff ff       	call   800bf2 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801cdc:	8b 03                	mov    (%ebx),%eax
  801cde:	3b 43 04             	cmp    0x4(%ebx),%eax
  801ce1:	74 e7                	je     801cca <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801ce3:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801ce8:	79 05                	jns    801cef <devpipe_read+0x4d>
  801cea:	48                   	dec    %eax
  801ceb:	83 c8 e0             	or     $0xffffffe0,%eax
  801cee:	40                   	inc    %eax
  801cef:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801cf3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801cf6:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801cf9:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801cfb:	46                   	inc    %esi
  801cfc:	39 75 10             	cmp    %esi,0x10(%ebp)
  801cff:	74 0d                	je     801d0e <devpipe_read+0x6c>
		while (p->p_rpos == p->p_wpos) {
  801d01:	8b 03                	mov    (%ebx),%eax
  801d03:	3b 43 04             	cmp    0x4(%ebx),%eax
  801d06:	75 db                	jne    801ce3 <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801d08:	85 f6                	test   %esi,%esi
  801d0a:	75 ba                	jne    801cc6 <devpipe_read+0x24>
  801d0c:	eb bc                	jmp    801cca <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801d0e:	8b 45 10             	mov    0x10(%ebp),%eax
  801d11:	eb 05                	jmp    801d18 <devpipe_read+0x76>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801d13:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801d18:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d1b:	5b                   	pop    %ebx
  801d1c:	5e                   	pop    %esi
  801d1d:	5f                   	pop    %edi
  801d1e:	5d                   	pop    %ebp
  801d1f:	c3                   	ret    

00801d20 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801d20:	55                   	push   %ebp
  801d21:	89 e5                	mov    %esp,%ebp
  801d23:	56                   	push   %esi
  801d24:	53                   	push   %ebx
  801d25:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801d28:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d2b:	50                   	push   %eax
  801d2c:	e8 f8 f0 ff ff       	call   800e29 <fd_alloc>
  801d31:	83 c4 10             	add    $0x10,%esp
  801d34:	85 c0                	test   %eax,%eax
  801d36:	0f 88 2a 01 00 00    	js     801e66 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d3c:	83 ec 04             	sub    $0x4,%esp
  801d3f:	68 07 04 00 00       	push   $0x407
  801d44:	ff 75 f4             	pushl  -0xc(%ebp)
  801d47:	6a 00                	push   $0x0
  801d49:	e8 c3 ee ff ff       	call   800c11 <sys_page_alloc>
  801d4e:	83 c4 10             	add    $0x10,%esp
  801d51:	85 c0                	test   %eax,%eax
  801d53:	0f 88 0d 01 00 00    	js     801e66 <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801d59:	83 ec 0c             	sub    $0xc,%esp
  801d5c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d5f:	50                   	push   %eax
  801d60:	e8 c4 f0 ff ff       	call   800e29 <fd_alloc>
  801d65:	89 c3                	mov    %eax,%ebx
  801d67:	83 c4 10             	add    $0x10,%esp
  801d6a:	85 c0                	test   %eax,%eax
  801d6c:	0f 88 e2 00 00 00    	js     801e54 <pipe+0x134>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d72:	83 ec 04             	sub    $0x4,%esp
  801d75:	68 07 04 00 00       	push   $0x407
  801d7a:	ff 75 f0             	pushl  -0x10(%ebp)
  801d7d:	6a 00                	push   $0x0
  801d7f:	e8 8d ee ff ff       	call   800c11 <sys_page_alloc>
  801d84:	89 c3                	mov    %eax,%ebx
  801d86:	83 c4 10             	add    $0x10,%esp
  801d89:	85 c0                	test   %eax,%eax
  801d8b:	0f 88 c3 00 00 00    	js     801e54 <pipe+0x134>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801d91:	83 ec 0c             	sub    $0xc,%esp
  801d94:	ff 75 f4             	pushl  -0xc(%ebp)
  801d97:	e8 76 f0 ff ff       	call   800e12 <fd2data>
  801d9c:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d9e:	83 c4 0c             	add    $0xc,%esp
  801da1:	68 07 04 00 00       	push   $0x407
  801da6:	50                   	push   %eax
  801da7:	6a 00                	push   $0x0
  801da9:	e8 63 ee ff ff       	call   800c11 <sys_page_alloc>
  801dae:	89 c3                	mov    %eax,%ebx
  801db0:	83 c4 10             	add    $0x10,%esp
  801db3:	85 c0                	test   %eax,%eax
  801db5:	0f 88 89 00 00 00    	js     801e44 <pipe+0x124>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801dbb:	83 ec 0c             	sub    $0xc,%esp
  801dbe:	ff 75 f0             	pushl  -0x10(%ebp)
  801dc1:	e8 4c f0 ff ff       	call   800e12 <fd2data>
  801dc6:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801dcd:	50                   	push   %eax
  801dce:	6a 00                	push   $0x0
  801dd0:	56                   	push   %esi
  801dd1:	6a 00                	push   $0x0
  801dd3:	e8 7c ee ff ff       	call   800c54 <sys_page_map>
  801dd8:	89 c3                	mov    %eax,%ebx
  801dda:	83 c4 20             	add    $0x20,%esp
  801ddd:	85 c0                	test   %eax,%eax
  801ddf:	78 55                	js     801e36 <pipe+0x116>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801de1:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801de7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dea:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801dec:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801def:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801df6:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801dfc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801dff:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801e01:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e04:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801e0b:	83 ec 0c             	sub    $0xc,%esp
  801e0e:	ff 75 f4             	pushl  -0xc(%ebp)
  801e11:	e8 ec ef ff ff       	call   800e02 <fd2num>
  801e16:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e19:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801e1b:	83 c4 04             	add    $0x4,%esp
  801e1e:	ff 75 f0             	pushl  -0x10(%ebp)
  801e21:	e8 dc ef ff ff       	call   800e02 <fd2num>
  801e26:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e29:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801e2c:	83 c4 10             	add    $0x10,%esp
  801e2f:	b8 00 00 00 00       	mov    $0x0,%eax
  801e34:	eb 30                	jmp    801e66 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  801e36:	83 ec 08             	sub    $0x8,%esp
  801e39:	56                   	push   %esi
  801e3a:	6a 00                	push   $0x0
  801e3c:	e8 55 ee ff ff       	call   800c96 <sys_page_unmap>
  801e41:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801e44:	83 ec 08             	sub    $0x8,%esp
  801e47:	ff 75 f0             	pushl  -0x10(%ebp)
  801e4a:	6a 00                	push   $0x0
  801e4c:	e8 45 ee ff ff       	call   800c96 <sys_page_unmap>
  801e51:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801e54:	83 ec 08             	sub    $0x8,%esp
  801e57:	ff 75 f4             	pushl  -0xc(%ebp)
  801e5a:	6a 00                	push   $0x0
  801e5c:	e8 35 ee ff ff       	call   800c96 <sys_page_unmap>
  801e61:	83 c4 10             	add    $0x10,%esp
  801e64:	89 d8                	mov    %ebx,%eax
    err:
	return r;
}
  801e66:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e69:	5b                   	pop    %ebx
  801e6a:	5e                   	pop    %esi
  801e6b:	5d                   	pop    %ebp
  801e6c:	c3                   	ret    

00801e6d <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801e6d:	55                   	push   %ebp
  801e6e:	89 e5                	mov    %esp,%ebp
  801e70:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e73:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e76:	50                   	push   %eax
  801e77:	ff 75 08             	pushl  0x8(%ebp)
  801e7a:	e8 1e f0 ff ff       	call   800e9d <fd_lookup>
  801e7f:	83 c4 10             	add    $0x10,%esp
  801e82:	85 c0                	test   %eax,%eax
  801e84:	78 18                	js     801e9e <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801e86:	83 ec 0c             	sub    $0xc,%esp
  801e89:	ff 75 f4             	pushl  -0xc(%ebp)
  801e8c:	e8 81 ef ff ff       	call   800e12 <fd2data>
	return _pipeisclosed(fd, p);
  801e91:	89 c2                	mov    %eax,%edx
  801e93:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e96:	e8 17 fd ff ff       	call   801bb2 <_pipeisclosed>
  801e9b:	83 c4 10             	add    $0x10,%esp
}
  801e9e:	c9                   	leave  
  801e9f:	c3                   	ret    

00801ea0 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801ea0:	55                   	push   %ebp
  801ea1:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801ea3:	b8 00 00 00 00       	mov    $0x0,%eax
  801ea8:	5d                   	pop    %ebp
  801ea9:	c3                   	ret    

00801eaa <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801eaa:	55                   	push   %ebp
  801eab:	89 e5                	mov    %esp,%ebp
  801ead:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801eb0:	68 37 29 80 00       	push   $0x802937
  801eb5:	ff 75 0c             	pushl  0xc(%ebp)
  801eb8:	e8 e4 e8 ff ff       	call   8007a1 <strcpy>
	return 0;
}
  801ebd:	b8 00 00 00 00       	mov    $0x0,%eax
  801ec2:	c9                   	leave  
  801ec3:	c3                   	ret    

00801ec4 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ec4:	55                   	push   %ebp
  801ec5:	89 e5                	mov    %esp,%ebp
  801ec7:	57                   	push   %edi
  801ec8:	56                   	push   %esi
  801ec9:	53                   	push   %ebx
  801eca:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ed0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801ed4:	74 45                	je     801f1b <devcons_write+0x57>
  801ed6:	b8 00 00 00 00       	mov    $0x0,%eax
  801edb:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801ee0:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801ee6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801ee9:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  801eeb:	83 fb 7f             	cmp    $0x7f,%ebx
  801eee:	76 05                	jbe    801ef5 <devcons_write+0x31>
			m = sizeof(buf) - 1;
  801ef0:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801ef5:	83 ec 04             	sub    $0x4,%esp
  801ef8:	53                   	push   %ebx
  801ef9:	03 45 0c             	add    0xc(%ebp),%eax
  801efc:	50                   	push   %eax
  801efd:	57                   	push   %edi
  801efe:	e8 6b ea ff ff       	call   80096e <memmove>
		sys_cputs(buf, m);
  801f03:	83 c4 08             	add    $0x8,%esp
  801f06:	53                   	push   %ebx
  801f07:	57                   	push   %edi
  801f08:	e8 48 ec ff ff       	call   800b55 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f0d:	01 de                	add    %ebx,%esi
  801f0f:	89 f0                	mov    %esi,%eax
  801f11:	83 c4 10             	add    $0x10,%esp
  801f14:	3b 75 10             	cmp    0x10(%ebp),%esi
  801f17:	72 cd                	jb     801ee6 <devcons_write+0x22>
  801f19:	eb 05                	jmp    801f20 <devcons_write+0x5c>
  801f1b:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801f20:	89 f0                	mov    %esi,%eax
  801f22:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f25:	5b                   	pop    %ebx
  801f26:	5e                   	pop    %esi
  801f27:	5f                   	pop    %edi
  801f28:	5d                   	pop    %ebp
  801f29:	c3                   	ret    

00801f2a <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801f2a:	55                   	push   %ebp
  801f2b:	89 e5                	mov    %esp,%ebp
  801f2d:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801f30:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801f34:	75 07                	jne    801f3d <devcons_read+0x13>
  801f36:	eb 23                	jmp    801f5b <devcons_read+0x31>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801f38:	e8 b5 ec ff ff       	call   800bf2 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801f3d:	e8 31 ec ff ff       	call   800b73 <sys_cgetc>
  801f42:	85 c0                	test   %eax,%eax
  801f44:	74 f2                	je     801f38 <devcons_read+0xe>
		sys_yield();
	if (c < 0)
  801f46:	85 c0                	test   %eax,%eax
  801f48:	78 1d                	js     801f67 <devcons_read+0x3d>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801f4a:	83 f8 04             	cmp    $0x4,%eax
  801f4d:	74 13                	je     801f62 <devcons_read+0x38>
		return 0;
	*(char*)vbuf = c;
  801f4f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f52:	88 02                	mov    %al,(%edx)
	return 1;
  801f54:	b8 01 00 00 00       	mov    $0x1,%eax
  801f59:	eb 0c                	jmp    801f67 <devcons_read+0x3d>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801f5b:	b8 00 00 00 00       	mov    $0x0,%eax
  801f60:	eb 05                	jmp    801f67 <devcons_read+0x3d>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801f62:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801f67:	c9                   	leave  
  801f68:	c3                   	ret    

00801f69 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801f69:	55                   	push   %ebp
  801f6a:	89 e5                	mov    %esp,%ebp
  801f6c:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801f6f:	8b 45 08             	mov    0x8(%ebp),%eax
  801f72:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801f75:	6a 01                	push   $0x1
  801f77:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f7a:	50                   	push   %eax
  801f7b:	e8 d5 eb ff ff       	call   800b55 <sys_cputs>
}
  801f80:	83 c4 10             	add    $0x10,%esp
  801f83:	c9                   	leave  
  801f84:	c3                   	ret    

00801f85 <getchar>:

int
getchar(void)
{
  801f85:	55                   	push   %ebp
  801f86:	89 e5                	mov    %esp,%ebp
  801f88:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801f8b:	6a 01                	push   $0x1
  801f8d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f90:	50                   	push   %eax
  801f91:	6a 00                	push   $0x0
  801f93:	e8 86 f1 ff ff       	call   80111e <read>
	if (r < 0)
  801f98:	83 c4 10             	add    $0x10,%esp
  801f9b:	85 c0                	test   %eax,%eax
  801f9d:	78 0f                	js     801fae <getchar+0x29>
		return r;
	if (r < 1)
  801f9f:	85 c0                	test   %eax,%eax
  801fa1:	7e 06                	jle    801fa9 <getchar+0x24>
		return -E_EOF;
	return c;
  801fa3:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801fa7:	eb 05                	jmp    801fae <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801fa9:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801fae:	c9                   	leave  
  801faf:	c3                   	ret    

00801fb0 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801fb0:	55                   	push   %ebp
  801fb1:	89 e5                	mov    %esp,%ebp
  801fb3:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801fb6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fb9:	50                   	push   %eax
  801fba:	ff 75 08             	pushl  0x8(%ebp)
  801fbd:	e8 db ee ff ff       	call   800e9d <fd_lookup>
  801fc2:	83 c4 10             	add    $0x10,%esp
  801fc5:	85 c0                	test   %eax,%eax
  801fc7:	78 11                	js     801fda <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801fc9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fcc:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801fd2:	39 10                	cmp    %edx,(%eax)
  801fd4:	0f 94 c0             	sete   %al
  801fd7:	0f b6 c0             	movzbl %al,%eax
}
  801fda:	c9                   	leave  
  801fdb:	c3                   	ret    

00801fdc <opencons>:

int
opencons(void)
{
  801fdc:	55                   	push   %ebp
  801fdd:	89 e5                	mov    %esp,%ebp
  801fdf:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801fe2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fe5:	50                   	push   %eax
  801fe6:	e8 3e ee ff ff       	call   800e29 <fd_alloc>
  801feb:	83 c4 10             	add    $0x10,%esp
  801fee:	85 c0                	test   %eax,%eax
  801ff0:	78 3a                	js     80202c <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ff2:	83 ec 04             	sub    $0x4,%esp
  801ff5:	68 07 04 00 00       	push   $0x407
  801ffa:	ff 75 f4             	pushl  -0xc(%ebp)
  801ffd:	6a 00                	push   $0x0
  801fff:	e8 0d ec ff ff       	call   800c11 <sys_page_alloc>
  802004:	83 c4 10             	add    $0x10,%esp
  802007:	85 c0                	test   %eax,%eax
  802009:	78 21                	js     80202c <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80200b:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802011:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802014:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802016:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802019:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802020:	83 ec 0c             	sub    $0xc,%esp
  802023:	50                   	push   %eax
  802024:	e8 d9 ed ff ff       	call   800e02 <fd2num>
  802029:	83 c4 10             	add    $0x10,%esp
}
  80202c:	c9                   	leave  
  80202d:	c3                   	ret    

0080202e <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80202e:	55                   	push   %ebp
  80202f:	89 e5                	mov    %esp,%ebp
  802031:	56                   	push   %esi
  802032:	53                   	push   %ebx
  802033:	8b 75 08             	mov    0x8(%ebp),%esi
  802036:	8b 45 0c             	mov    0xc(%ebp),%eax
  802039:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");
	int r;
    if (pg != NULL) {
  80203c:	85 c0                	test   %eax,%eax
  80203e:	74 0e                	je     80204e <ipc_recv+0x20>
        r = sys_ipc_recv(pg);
  802040:	83 ec 0c             	sub    $0xc,%esp
  802043:	50                   	push   %eax
  802044:	e8 78 ed ff ff       	call   800dc1 <sys_ipc_recv>
  802049:	83 c4 10             	add    $0x10,%esp
  80204c:	eb 10                	jmp    80205e <ipc_recv+0x30>
    } else {
        r = sys_ipc_recv((void *) UTOP);
  80204e:	83 ec 0c             	sub    $0xc,%esp
  802051:	68 00 00 c0 ee       	push   $0xeec00000
  802056:	e8 66 ed ff ff       	call   800dc1 <sys_ipc_recv>
  80205b:	83 c4 10             	add    $0x10,%esp
    }
    if (r < 0) {
  80205e:	85 c0                	test   %eax,%eax
  802060:	79 16                	jns    802078 <ipc_recv+0x4a>
        // failed
        if (from_env_store != NULL) *from_env_store = 0;
  802062:	85 f6                	test   %esi,%esi
  802064:	74 06                	je     80206c <ipc_recv+0x3e>
  802066:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        if (perm_store != NULL) *perm_store = 0;
  80206c:	85 db                	test   %ebx,%ebx
  80206e:	74 2c                	je     80209c <ipc_recv+0x6e>
  802070:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  802076:	eb 24                	jmp    80209c <ipc_recv+0x6e>
        return r;
    } else {
        if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  802078:	85 f6                	test   %esi,%esi
  80207a:	74 0a                	je     802086 <ipc_recv+0x58>
  80207c:	a1 04 40 80 00       	mov    0x804004,%eax
  802081:	8b 40 74             	mov    0x74(%eax),%eax
  802084:	89 06                	mov    %eax,(%esi)
        if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  802086:	85 db                	test   %ebx,%ebx
  802088:	74 0a                	je     802094 <ipc_recv+0x66>
  80208a:	a1 04 40 80 00       	mov    0x804004,%eax
  80208f:	8b 40 78             	mov    0x78(%eax),%eax
  802092:	89 03                	mov    %eax,(%ebx)
        return thisenv->env_ipc_value;
  802094:	a1 04 40 80 00       	mov    0x804004,%eax
  802099:	8b 40 70             	mov    0x70(%eax),%eax
    }
 
	return 0;
}
  80209c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80209f:	5b                   	pop    %ebx
  8020a0:	5e                   	pop    %esi
  8020a1:	5d                   	pop    %ebp
  8020a2:	c3                   	ret    

008020a3 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8020a3:	55                   	push   %ebp
  8020a4:	89 e5                	mov    %esp,%ebp
  8020a6:	57                   	push   %edi
  8020a7:	56                   	push   %esi
  8020a8:	53                   	push   %ebx
  8020a9:	83 ec 0c             	sub    $0xc,%esp
  8020ac:	8b 75 10             	mov    0x10(%ebp),%esi
  8020af:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");
	int r;
    if (pg == NULL) pg = (void *)UTOP;
  8020b2:	85 f6                	test   %esi,%esi
  8020b4:	75 05                	jne    8020bb <ipc_send+0x18>
  8020b6:	be 00 00 c0 ee       	mov    $0xeec00000,%esi
    do {
        r = sys_ipc_try_send(to_env, val, pg, perm);
  8020bb:	57                   	push   %edi
  8020bc:	56                   	push   %esi
  8020bd:	ff 75 0c             	pushl  0xc(%ebp)
  8020c0:	ff 75 08             	pushl  0x8(%ebp)
  8020c3:	e8 d6 ec ff ff       	call   800d9e <sys_ipc_try_send>
  8020c8:	89 c3                	mov    %eax,%ebx
        if (r < 0 && r != -E_IPC_NOT_RECV) panic("ipc send failed: %e", r);
  8020ca:	83 c4 10             	add    $0x10,%esp
  8020cd:	85 c0                	test   %eax,%eax
  8020cf:	79 17                	jns    8020e8 <ipc_send+0x45>
  8020d1:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8020d4:	74 1d                	je     8020f3 <ipc_send+0x50>
  8020d6:	50                   	push   %eax
  8020d7:	68 43 29 80 00       	push   $0x802943
  8020dc:	6a 40                	push   $0x40
  8020de:	68 57 29 80 00       	push   $0x802957
  8020e3:	e8 fc df ff ff       	call   8000e4 <_panic>
        sys_yield();
  8020e8:	e8 05 eb ff ff       	call   800bf2 <sys_yield>
    } while (r != 0);
  8020ed:	85 db                	test   %ebx,%ebx
  8020ef:	75 ca                	jne    8020bb <ipc_send+0x18>
  8020f1:	eb 07                	jmp    8020fa <ipc_send+0x57>
	int r;
    if (pg == NULL) pg = (void *)UTOP;
    do {
        r = sys_ipc_try_send(to_env, val, pg, perm);
        if (r < 0 && r != -E_IPC_NOT_RECV) panic("ipc send failed: %e", r);
        sys_yield();
  8020f3:	e8 fa ea ff ff       	call   800bf2 <sys_yield>
  8020f8:	eb c1                	jmp    8020bb <ipc_send+0x18>
    } while (r != 0);
}
  8020fa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020fd:	5b                   	pop    %ebx
  8020fe:	5e                   	pop    %esi
  8020ff:	5f                   	pop    %edi
  802100:	5d                   	pop    %ebp
  802101:	c3                   	ret    

00802102 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802102:	55                   	push   %ebp
  802103:	89 e5                	mov    %esp,%ebp
  802105:	53                   	push   %ebx
  802106:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  802109:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  80210e:	39 c1                	cmp    %eax,%ecx
  802110:	74 21                	je     802133 <ipc_find_env+0x31>
  802112:	ba 01 00 00 00       	mov    $0x1,%edx
  802117:	8d 1c 95 00 00 00 00 	lea    0x0(,%edx,4),%ebx
  80211e:	89 d0                	mov    %edx,%eax
  802120:	c1 e0 07             	shl    $0x7,%eax
  802123:	29 d8                	sub    %ebx,%eax
  802125:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80212a:	8b 40 50             	mov    0x50(%eax),%eax
  80212d:	39 c8                	cmp    %ecx,%eax
  80212f:	75 1b                	jne    80214c <ipc_find_env+0x4a>
  802131:	eb 05                	jmp    802138 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802133:	ba 00 00 00 00       	mov    $0x0,%edx
		if (envs[i].env_type == type)
			return envs[i].env_id;
  802138:	8d 04 95 00 00 00 00 	lea    0x0(,%edx,4),%eax
  80213f:	c1 e2 07             	shl    $0x7,%edx
  802142:	29 c2                	sub    %eax,%edx
  802144:	8b 82 48 00 c0 ee    	mov    -0x113fffb8(%edx),%eax
  80214a:	eb 0e                	jmp    80215a <ipc_find_env+0x58>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80214c:	42                   	inc    %edx
  80214d:	81 fa 00 04 00 00    	cmp    $0x400,%edx
  802153:	75 c2                	jne    802117 <ipc_find_env+0x15>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802155:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80215a:	5b                   	pop    %ebx
  80215b:	5d                   	pop    %ebp
  80215c:	c3                   	ret    

0080215d <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80215d:	55                   	push   %ebp
  80215e:	89 e5                	mov    %esp,%ebp
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802160:	8b 45 08             	mov    0x8(%ebp),%eax
  802163:	c1 e8 16             	shr    $0x16,%eax
  802166:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80216d:	a8 01                	test   $0x1,%al
  80216f:	74 21                	je     802192 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  802171:	8b 45 08             	mov    0x8(%ebp),%eax
  802174:	c1 e8 0c             	shr    $0xc,%eax
  802177:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  80217e:	a8 01                	test   $0x1,%al
  802180:	74 17                	je     802199 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802182:	c1 e8 0c             	shr    $0xc,%eax
  802185:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  80218c:	ef 
  80218d:	0f b7 c0             	movzwl %ax,%eax
  802190:	eb 0c                	jmp    80219e <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  802192:	b8 00 00 00 00       	mov    $0x0,%eax
  802197:	eb 05                	jmp    80219e <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  802199:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  80219e:	5d                   	pop    %ebp
  80219f:	c3                   	ret    

008021a0 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  8021a0:	55                   	push   %ebp
  8021a1:	57                   	push   %edi
  8021a2:	56                   	push   %esi
  8021a3:	53                   	push   %ebx
  8021a4:	83 ec 1c             	sub    $0x1c,%esp
  8021a7:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8021ab:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8021af:	8b 7c 24 38          	mov    0x38(%esp),%edi
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8021b3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8021b7:	89 ca                	mov    %ecx,%edx
  const DWunion dd = {.ll = d};
  8021b9:	89 f8                	mov    %edi,%eax
  8021bb:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8021bf:	85 f6                	test   %esi,%esi
  8021c1:	75 2d                	jne    8021f0 <__udivdi3+0x50>
    {
      if (d0 > n1)
  8021c3:	39 cf                	cmp    %ecx,%edi
  8021c5:	77 65                	ja     80222c <__udivdi3+0x8c>
  8021c7:	89 fd                	mov    %edi,%ebp
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8021c9:	85 ff                	test   %edi,%edi
  8021cb:	75 0b                	jne    8021d8 <__udivdi3+0x38>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8021cd:	b8 01 00 00 00       	mov    $0x1,%eax
  8021d2:	31 d2                	xor    %edx,%edx
  8021d4:	f7 f7                	div    %edi
  8021d6:	89 c5                	mov    %eax,%ebp

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8021d8:	31 d2                	xor    %edx,%edx
  8021da:	89 c8                	mov    %ecx,%eax
  8021dc:	f7 f5                	div    %ebp
  8021de:	89 c1                	mov    %eax,%ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8021e0:	89 d8                	mov    %ebx,%eax
  8021e2:	f7 f5                	div    %ebp
  8021e4:	89 cf                	mov    %ecx,%edi
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8021e6:	89 fa                	mov    %edi,%edx
  8021e8:	83 c4 1c             	add    $0x1c,%esp
  8021eb:	5b                   	pop    %ebx
  8021ec:	5e                   	pop    %esi
  8021ed:	5f                   	pop    %edi
  8021ee:	5d                   	pop    %ebp
  8021ef:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8021f0:	39 ce                	cmp    %ecx,%esi
  8021f2:	77 28                	ja     80221c <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8021f4:	0f bd fe             	bsr    %esi,%edi
	  if (bm == 0)
  8021f7:	83 f7 1f             	xor    $0x1f,%edi
  8021fa:	75 40                	jne    80223c <__udivdi3+0x9c>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8021fc:	39 ce                	cmp    %ecx,%esi
  8021fe:	72 0a                	jb     80220a <__udivdi3+0x6a>
  802200:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802204:	0f 87 9e 00 00 00    	ja     8022a8 <__udivdi3+0x108>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  80220a:	b8 01 00 00 00       	mov    $0x1,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80220f:	89 fa                	mov    %edi,%edx
  802211:	83 c4 1c             	add    $0x1c,%esp
  802214:	5b                   	pop    %ebx
  802215:	5e                   	pop    %esi
  802216:	5f                   	pop    %edi
  802217:	5d                   	pop    %ebp
  802218:	c3                   	ret    
  802219:	8d 76 00             	lea    0x0(%esi),%esi
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  80221c:	31 ff                	xor    %edi,%edi
  80221e:	31 c0                	xor    %eax,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802220:	89 fa                	mov    %edi,%edx
  802222:	83 c4 1c             	add    $0x1c,%esp
  802225:	5b                   	pop    %ebx
  802226:	5e                   	pop    %esi
  802227:	5f                   	pop    %edi
  802228:	5d                   	pop    %ebp
  802229:	c3                   	ret    
  80222a:	66 90                	xchg   %ax,%ax
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80222c:	89 d8                	mov    %ebx,%eax
  80222e:	f7 f7                	div    %edi
  802230:	31 ff                	xor    %edi,%edi
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802232:	89 fa                	mov    %edi,%edx
  802234:	83 c4 1c             	add    $0x1c,%esp
  802237:	5b                   	pop    %ebx
  802238:	5e                   	pop    %esi
  802239:	5f                   	pop    %edi
  80223a:	5d                   	pop    %ebp
  80223b:	c3                   	ret    
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  80223c:	bd 20 00 00 00       	mov    $0x20,%ebp
  802241:	89 eb                	mov    %ebp,%ebx
  802243:	29 fb                	sub    %edi,%ebx

	      d1 = (d1 << bm) | (d0 >> b);
  802245:	89 f9                	mov    %edi,%ecx
  802247:	d3 e6                	shl    %cl,%esi
  802249:	89 c5                	mov    %eax,%ebp
  80224b:	88 d9                	mov    %bl,%cl
  80224d:	d3 ed                	shr    %cl,%ebp
  80224f:	89 e9                	mov    %ebp,%ecx
  802251:	09 f1                	or     %esi,%ecx
  802253:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
	      d0 = d0 << bm;
  802257:	89 f9                	mov    %edi,%ecx
  802259:	d3 e0                	shl    %cl,%eax
  80225b:	89 c5                	mov    %eax,%ebp
	      n2 = n1 >> b;
  80225d:	89 d6                	mov    %edx,%esi
  80225f:	88 d9                	mov    %bl,%cl
  802261:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
  802263:	89 f9                	mov    %edi,%ecx
  802265:	d3 e2                	shl    %cl,%edx
  802267:	8b 44 24 08          	mov    0x8(%esp),%eax
  80226b:	88 d9                	mov    %bl,%cl
  80226d:	d3 e8                	shr    %cl,%eax
  80226f:	09 c2                	or     %eax,%edx
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802271:	89 d0                	mov    %edx,%eax
  802273:	89 f2                	mov    %esi,%edx
  802275:	f7 74 24 0c          	divl   0xc(%esp)
  802279:	89 d6                	mov    %edx,%esi
  80227b:	89 c3                	mov    %eax,%ebx
	      umul_ppmm (m1, m0, q0, d0);
  80227d:	f7 e5                	mul    %ebp

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80227f:	39 d6                	cmp    %edx,%esi
  802281:	72 19                	jb     80229c <__udivdi3+0xfc>
  802283:	74 0b                	je     802290 <__udivdi3+0xf0>
  802285:	89 d8                	mov    %ebx,%eax
  802287:	31 ff                	xor    %edi,%edi
  802289:	e9 58 ff ff ff       	jmp    8021e6 <__udivdi3+0x46>
  80228e:	66 90                	xchg   %ax,%ax
  802290:	8b 54 24 08          	mov    0x8(%esp),%edx
  802294:	89 f9                	mov    %edi,%ecx
  802296:	d3 e2                	shl    %cl,%edx
  802298:	39 c2                	cmp    %eax,%edx
  80229a:	73 e9                	jae    802285 <__udivdi3+0xe5>
  80229c:	8d 43 ff             	lea    -0x1(%ebx),%eax
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  80229f:	31 ff                	xor    %edi,%edi
  8022a1:	e9 40 ff ff ff       	jmp    8021e6 <__udivdi3+0x46>
  8022a6:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8022a8:	31 c0                	xor    %eax,%eax
  8022aa:	e9 37 ff ff ff       	jmp    8021e6 <__udivdi3+0x46>
  8022af:	90                   	nop

008022b0 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  8022b0:	55                   	push   %ebp
  8022b1:	57                   	push   %edi
  8022b2:	56                   	push   %esi
  8022b3:	53                   	push   %ebx
  8022b4:	83 ec 1c             	sub    $0x1c,%esp
  8022b7:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8022bb:	8b 74 24 34          	mov    0x34(%esp),%esi
  8022bf:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8022c3:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8022c7:	89 44 24 0c          	mov    %eax,0xc(%esp)
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8022cb:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8022cf:	89 f3                	mov    %esi,%ebx
  const DWunion dd = {.ll = d};
  8022d1:	89 fa                	mov    %edi,%edx
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  8022d3:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  n1 = nn.s.high;
  8022d7:	89 34 24             	mov    %esi,(%esp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8022da:	85 c0                	test   %eax,%eax
  8022dc:	75 1a                	jne    8022f8 <__umoddi3+0x48>
    {
      if (d0 > n1)
  8022de:	39 f7                	cmp    %esi,%edi
  8022e0:	0f 86 a2 00 00 00    	jbe    802388 <__umoddi3+0xd8>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8022e6:	89 c8                	mov    %ecx,%eax
  8022e8:	89 f2                	mov    %esi,%edx
  8022ea:	f7 f7                	div    %edi
  8022ec:	89 d0                	mov    %edx,%eax

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  8022ee:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8022f0:	83 c4 1c             	add    $0x1c,%esp
  8022f3:	5b                   	pop    %ebx
  8022f4:	5e                   	pop    %esi
  8022f5:	5f                   	pop    %edi
  8022f6:	5d                   	pop    %ebp
  8022f7:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8022f8:	39 f0                	cmp    %esi,%eax
  8022fa:	0f 87 ac 00 00 00    	ja     8023ac <__umoddi3+0xfc>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802300:	0f bd e8             	bsr    %eax,%ebp
	  if (bm == 0)
  802303:	83 f5 1f             	xor    $0x1f,%ebp
  802306:	0f 84 ac 00 00 00    	je     8023b8 <__umoddi3+0x108>
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  80230c:	bf 20 00 00 00       	mov    $0x20,%edi
  802311:	29 ef                	sub    %ebp,%edi
  802313:	89 fe                	mov    %edi,%esi
  802315:	89 7c 24 0c          	mov    %edi,0xc(%esp)

	      d1 = (d1 << bm) | (d0 >> b);
  802319:	89 e9                	mov    %ebp,%ecx
  80231b:	d3 e0                	shl    %cl,%eax
  80231d:	89 d7                	mov    %edx,%edi
  80231f:	89 f1                	mov    %esi,%ecx
  802321:	d3 ef                	shr    %cl,%edi
  802323:	09 c7                	or     %eax,%edi
	      d0 = d0 << bm;
  802325:	89 e9                	mov    %ebp,%ecx
  802327:	d3 e2                	shl    %cl,%edx
  802329:	89 14 24             	mov    %edx,(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  80232c:	89 d8                	mov    %ebx,%eax
  80232e:	d3 e0                	shl    %cl,%eax
  802330:	89 c2                	mov    %eax,%edx
	      n0 = n0 << bm;
  802332:	8b 44 24 08          	mov    0x8(%esp),%eax
  802336:	d3 e0                	shl    %cl,%eax
  802338:	89 44 24 04          	mov    %eax,0x4(%esp)

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  80233c:	8b 44 24 08          	mov    0x8(%esp),%eax
  802340:	89 f1                	mov    %esi,%ecx
  802342:	d3 e8                	shr    %cl,%eax
  802344:	09 d0                	or     %edx,%eax
  802346:	d3 eb                	shr    %cl,%ebx
  802348:	89 da                	mov    %ebx,%edx
  80234a:	f7 f7                	div    %edi
  80234c:	89 d3                	mov    %edx,%ebx
	      umul_ppmm (m1, m0, q0, d0);
  80234e:	f7 24 24             	mull   (%esp)
  802351:	89 c6                	mov    %eax,%esi
  802353:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802355:	39 d3                	cmp    %edx,%ebx
  802357:	0f 82 87 00 00 00    	jb     8023e4 <__umoddi3+0x134>
  80235d:	0f 84 91 00 00 00    	je     8023f4 <__umoddi3+0x144>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  802363:	8b 54 24 04          	mov    0x4(%esp),%edx
  802367:	29 f2                	sub    %esi,%edx
  802369:	19 cb                	sbb    %ecx,%ebx
		  rr.s.low = (n1 << b) | (n0 >> bm);
  80236b:	89 d8                	mov    %ebx,%eax
  80236d:	8a 4c 24 0c          	mov    0xc(%esp),%cl
  802371:	d3 e0                	shl    %cl,%eax
  802373:	89 e9                	mov    %ebp,%ecx
  802375:	d3 ea                	shr    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  802377:	09 d0                	or     %edx,%eax
  802379:	89 e9                	mov    %ebp,%ecx
  80237b:	d3 eb                	shr    %cl,%ebx
  80237d:	89 da                	mov    %ebx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80237f:	83 c4 1c             	add    $0x1c,%esp
  802382:	5b                   	pop    %ebx
  802383:	5e                   	pop    %esi
  802384:	5f                   	pop    %edi
  802385:	5d                   	pop    %ebp
  802386:	c3                   	ret    
  802387:	90                   	nop
  802388:	89 fd                	mov    %edi,%ebp
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  80238a:	85 ff                	test   %edi,%edi
  80238c:	75 0b                	jne    802399 <__umoddi3+0xe9>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  80238e:	b8 01 00 00 00       	mov    $0x1,%eax
  802393:	31 d2                	xor    %edx,%edx
  802395:	f7 f7                	div    %edi
  802397:	89 c5                	mov    %eax,%ebp

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802399:	89 f0                	mov    %esi,%eax
  80239b:	31 d2                	xor    %edx,%edx
  80239d:	f7 f5                	div    %ebp
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80239f:	89 c8                	mov    %ecx,%eax
  8023a1:	f7 f5                	div    %ebp
  8023a3:	89 d0                	mov    %edx,%eax
  8023a5:	e9 44 ff ff ff       	jmp    8022ee <__umoddi3+0x3e>
  8023aa:	66 90                	xchg   %ax,%ax
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  8023ac:	89 c8                	mov    %ecx,%eax
  8023ae:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8023b0:	83 c4 1c             	add    $0x1c,%esp
  8023b3:	5b                   	pop    %ebx
  8023b4:	5e                   	pop    %esi
  8023b5:	5f                   	pop    %edi
  8023b6:	5d                   	pop    %ebp
  8023b7:	c3                   	ret    

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8023b8:	3b 04 24             	cmp    (%esp),%eax
  8023bb:	72 06                	jb     8023c3 <__umoddi3+0x113>
  8023bd:	3b 7c 24 04          	cmp    0x4(%esp),%edi
  8023c1:	77 0f                	ja     8023d2 <__umoddi3+0x122>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8023c3:	89 f2                	mov    %esi,%edx
  8023c5:	29 f9                	sub    %edi,%ecx
  8023c7:	1b 54 24 0c          	sbb    0xc(%esp),%edx
  8023cb:	89 14 24             	mov    %edx,(%esp)
  8023ce:	89 4c 24 04          	mov    %ecx,0x4(%esp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  8023d2:	8b 44 24 04          	mov    0x4(%esp),%eax
  8023d6:	8b 14 24             	mov    (%esp),%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8023d9:	83 c4 1c             	add    $0x1c,%esp
  8023dc:	5b                   	pop    %ebx
  8023dd:	5e                   	pop    %esi
  8023de:	5f                   	pop    %edi
  8023df:	5d                   	pop    %ebp
  8023e0:	c3                   	ret    
  8023e1:	8d 76 00             	lea    0x0(%esi),%esi
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8023e4:	2b 04 24             	sub    (%esp),%eax
  8023e7:	19 fa                	sbb    %edi,%edx
  8023e9:	89 d1                	mov    %edx,%ecx
  8023eb:	89 c6                	mov    %eax,%esi
  8023ed:	e9 71 ff ff ff       	jmp    802363 <__umoddi3+0xb3>
  8023f2:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8023f4:	39 44 24 04          	cmp    %eax,0x4(%esp)
  8023f8:	72 ea                	jb     8023e4 <__umoddi3+0x134>
  8023fa:	89 d9                	mov    %ebx,%ecx
  8023fc:	e9 62 ff ff ff       	jmp    802363 <__umoddi3+0xb3>
