
obj/user/yield.debug:     file format elf32-i386


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
  80002c:	e8 67 00 00 00       	call   800098 <libmain>
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
  800037:	83 ec 0c             	sub    $0xc,%esp
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
  80003a:	a1 04 40 80 00       	mov    0x804004,%eax
  80003f:	8b 40 48             	mov    0x48(%eax),%eax
  800042:	50                   	push   %eax
  800043:	68 a0 1e 80 00       	push   $0x801ea0
  800048:	e8 46 01 00 00       	call   800193 <cprintf>
  80004d:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 5; i++) {
  800050:	bb 00 00 00 00       	mov    $0x0,%ebx
		sys_yield();
  800055:	e8 6f 0b 00 00       	call   800bc9 <sys_yield>
		cprintf("Back in environment %08x, iteration %d.\n",
			thisenv->env_id, i);
  80005a:	a1 04 40 80 00       	mov    0x804004,%eax
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
	for (i = 0; i < 5; i++) {
		sys_yield();
		cprintf("Back in environment %08x, iteration %d.\n",
  80005f:	8b 40 48             	mov    0x48(%eax),%eax
  800062:	83 ec 04             	sub    $0x4,%esp
  800065:	53                   	push   %ebx
  800066:	50                   	push   %eax
  800067:	68 c0 1e 80 00       	push   $0x801ec0
  80006c:	e8 22 01 00 00       	call   800193 <cprintf>
umain(int argc, char **argv)
{
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
	for (i = 0; i < 5; i++) {
  800071:	43                   	inc    %ebx
  800072:	83 c4 10             	add    $0x10,%esp
  800075:	83 fb 05             	cmp    $0x5,%ebx
  800078:	75 db                	jne    800055 <umain+0x22>
		sys_yield();
		cprintf("Back in environment %08x, iteration %d.\n",
			thisenv->env_id, i);
	}
	cprintf("All done in environment %08x.\n", thisenv->env_id);
  80007a:	a1 04 40 80 00       	mov    0x804004,%eax
  80007f:	8b 40 48             	mov    0x48(%eax),%eax
  800082:	83 ec 08             	sub    $0x8,%esp
  800085:	50                   	push   %eax
  800086:	68 ec 1e 80 00       	push   $0x801eec
  80008b:	e8 03 01 00 00       	call   800193 <cprintf>
}
  800090:	83 c4 10             	add    $0x10,%esp
  800093:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800096:	c9                   	leave  
  800097:	c3                   	ret    

00800098 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800098:	55                   	push   %ebp
  800099:	89 e5                	mov    %esp,%ebp
  80009b:	56                   	push   %esi
  80009c:	53                   	push   %ebx
  80009d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000a0:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8000a3:	e8 02 0b 00 00       	call   800baa <sys_getenvid>
  8000a8:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000ad:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8000b4:	c1 e0 07             	shl    $0x7,%eax
  8000b7:	29 d0                	sub    %edx,%eax
  8000b9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000be:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000c3:	85 db                	test   %ebx,%ebx
  8000c5:	7e 07                	jle    8000ce <libmain+0x36>
		binaryname = argv[0];
  8000c7:	8b 06                	mov    (%esi),%eax
  8000c9:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000ce:	83 ec 08             	sub    $0x8,%esp
  8000d1:	56                   	push   %esi
  8000d2:	53                   	push   %ebx
  8000d3:	e8 5b ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000d8:	e8 0a 00 00 00       	call   8000e7 <exit>
}
  8000dd:	83 c4 10             	add    $0x10,%esp
  8000e0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000e3:	5b                   	pop    %ebx
  8000e4:	5e                   	pop    %esi
  8000e5:	5d                   	pop    %ebp
  8000e6:	c3                   	ret    

008000e7 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000e7:	55                   	push   %ebp
  8000e8:	89 e5                	mov    %esp,%ebp
  8000ea:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000ed:	e8 f6 0e 00 00       	call   800fe8 <close_all>
	sys_env_destroy(0);
  8000f2:	83 ec 0c             	sub    $0xc,%esp
  8000f5:	6a 00                	push   $0x0
  8000f7:	e8 6d 0a 00 00       	call   800b69 <sys_env_destroy>
}
  8000fc:	83 c4 10             	add    $0x10,%esp
  8000ff:	c9                   	leave  
  800100:	c3                   	ret    

00800101 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800101:	55                   	push   %ebp
  800102:	89 e5                	mov    %esp,%ebp
  800104:	53                   	push   %ebx
  800105:	83 ec 04             	sub    $0x4,%esp
  800108:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80010b:	8b 13                	mov    (%ebx),%edx
  80010d:	8d 42 01             	lea    0x1(%edx),%eax
  800110:	89 03                	mov    %eax,(%ebx)
  800112:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800115:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800119:	3d ff 00 00 00       	cmp    $0xff,%eax
  80011e:	75 1a                	jne    80013a <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800120:	83 ec 08             	sub    $0x8,%esp
  800123:	68 ff 00 00 00       	push   $0xff
  800128:	8d 43 08             	lea    0x8(%ebx),%eax
  80012b:	50                   	push   %eax
  80012c:	e8 fb 09 00 00       	call   800b2c <sys_cputs>
		b->idx = 0;
  800131:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800137:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80013a:	ff 43 04             	incl   0x4(%ebx)
}
  80013d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800140:	c9                   	leave  
  800141:	c3                   	ret    

00800142 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800142:	55                   	push   %ebp
  800143:	89 e5                	mov    %esp,%ebp
  800145:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80014b:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800152:	00 00 00 
	b.cnt = 0;
  800155:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80015c:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80015f:	ff 75 0c             	pushl  0xc(%ebp)
  800162:	ff 75 08             	pushl  0x8(%ebp)
  800165:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80016b:	50                   	push   %eax
  80016c:	68 01 01 80 00       	push   $0x800101
  800171:	e8 54 01 00 00       	call   8002ca <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800176:	83 c4 08             	add    $0x8,%esp
  800179:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80017f:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800185:	50                   	push   %eax
  800186:	e8 a1 09 00 00       	call   800b2c <sys_cputs>

	return b.cnt;
}
  80018b:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800191:	c9                   	leave  
  800192:	c3                   	ret    

00800193 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800193:	55                   	push   %ebp
  800194:	89 e5                	mov    %esp,%ebp
  800196:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800199:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80019c:	50                   	push   %eax
  80019d:	ff 75 08             	pushl  0x8(%ebp)
  8001a0:	e8 9d ff ff ff       	call   800142 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001a5:	c9                   	leave  
  8001a6:	c3                   	ret    

008001a7 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001a7:	55                   	push   %ebp
  8001a8:	89 e5                	mov    %esp,%ebp
  8001aa:	57                   	push   %edi
  8001ab:	56                   	push   %esi
  8001ac:	53                   	push   %ebx
  8001ad:	83 ec 1c             	sub    $0x1c,%esp
  8001b0:	89 c6                	mov    %eax,%esi
  8001b2:	89 d7                	mov    %edx,%edi
  8001b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8001b7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001ba:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001bd:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001c0:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001c3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001c8:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001cb:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001ce:	39 d3                	cmp    %edx,%ebx
  8001d0:	72 11                	jb     8001e3 <printnum+0x3c>
  8001d2:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001d5:	76 0c                	jbe    8001e3 <printnum+0x3c>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8001da:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001dd:	85 db                	test   %ebx,%ebx
  8001df:	7f 37                	jg     800218 <printnum+0x71>
  8001e1:	eb 44                	jmp    800227 <printnum+0x80>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001e3:	83 ec 0c             	sub    $0xc,%esp
  8001e6:	ff 75 18             	pushl  0x18(%ebp)
  8001e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8001ec:	48                   	dec    %eax
  8001ed:	50                   	push   %eax
  8001ee:	ff 75 10             	pushl  0x10(%ebp)
  8001f1:	83 ec 08             	sub    $0x8,%esp
  8001f4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001f7:	ff 75 e0             	pushl  -0x20(%ebp)
  8001fa:	ff 75 dc             	pushl  -0x24(%ebp)
  8001fd:	ff 75 d8             	pushl  -0x28(%ebp)
  800200:	e8 27 1a 00 00       	call   801c2c <__udivdi3>
  800205:	83 c4 18             	add    $0x18,%esp
  800208:	52                   	push   %edx
  800209:	50                   	push   %eax
  80020a:	89 fa                	mov    %edi,%edx
  80020c:	89 f0                	mov    %esi,%eax
  80020e:	e8 94 ff ff ff       	call   8001a7 <printnum>
  800213:	83 c4 20             	add    $0x20,%esp
  800216:	eb 0f                	jmp    800227 <printnum+0x80>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800218:	83 ec 08             	sub    $0x8,%esp
  80021b:	57                   	push   %edi
  80021c:	ff 75 18             	pushl  0x18(%ebp)
  80021f:	ff d6                	call   *%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800221:	83 c4 10             	add    $0x10,%esp
  800224:	4b                   	dec    %ebx
  800225:	75 f1                	jne    800218 <printnum+0x71>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800227:	83 ec 08             	sub    $0x8,%esp
  80022a:	57                   	push   %edi
  80022b:	83 ec 04             	sub    $0x4,%esp
  80022e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800231:	ff 75 e0             	pushl  -0x20(%ebp)
  800234:	ff 75 dc             	pushl  -0x24(%ebp)
  800237:	ff 75 d8             	pushl  -0x28(%ebp)
  80023a:	e8 fd 1a 00 00       	call   801d3c <__umoddi3>
  80023f:	83 c4 14             	add    $0x14,%esp
  800242:	0f be 80 15 1f 80 00 	movsbl 0x801f15(%eax),%eax
  800249:	50                   	push   %eax
  80024a:	ff d6                	call   *%esi
}
  80024c:	83 c4 10             	add    $0x10,%esp
  80024f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800252:	5b                   	pop    %ebx
  800253:	5e                   	pop    %esi
  800254:	5f                   	pop    %edi
  800255:	5d                   	pop    %ebp
  800256:	c3                   	ret    

00800257 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800257:	55                   	push   %ebp
  800258:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80025a:	83 fa 01             	cmp    $0x1,%edx
  80025d:	7e 0e                	jle    80026d <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80025f:	8b 10                	mov    (%eax),%edx
  800261:	8d 4a 08             	lea    0x8(%edx),%ecx
  800264:	89 08                	mov    %ecx,(%eax)
  800266:	8b 02                	mov    (%edx),%eax
  800268:	8b 52 04             	mov    0x4(%edx),%edx
  80026b:	eb 22                	jmp    80028f <getuint+0x38>
	else if (lflag)
  80026d:	85 d2                	test   %edx,%edx
  80026f:	74 10                	je     800281 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800271:	8b 10                	mov    (%eax),%edx
  800273:	8d 4a 04             	lea    0x4(%edx),%ecx
  800276:	89 08                	mov    %ecx,(%eax)
  800278:	8b 02                	mov    (%edx),%eax
  80027a:	ba 00 00 00 00       	mov    $0x0,%edx
  80027f:	eb 0e                	jmp    80028f <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800281:	8b 10                	mov    (%eax),%edx
  800283:	8d 4a 04             	lea    0x4(%edx),%ecx
  800286:	89 08                	mov    %ecx,(%eax)
  800288:	8b 02                	mov    (%edx),%eax
  80028a:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80028f:	5d                   	pop    %ebp
  800290:	c3                   	ret    

00800291 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800291:	55                   	push   %ebp
  800292:	89 e5                	mov    %esp,%ebp
  800294:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800297:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  80029a:	8b 10                	mov    (%eax),%edx
  80029c:	3b 50 04             	cmp    0x4(%eax),%edx
  80029f:	73 0a                	jae    8002ab <sprintputch+0x1a>
		*b->buf++ = ch;
  8002a1:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002a4:	89 08                	mov    %ecx,(%eax)
  8002a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8002a9:	88 02                	mov    %al,(%edx)
}
  8002ab:	5d                   	pop    %ebp
  8002ac:	c3                   	ret    

008002ad <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002ad:	55                   	push   %ebp
  8002ae:	89 e5                	mov    %esp,%ebp
  8002b0:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002b3:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002b6:	50                   	push   %eax
  8002b7:	ff 75 10             	pushl  0x10(%ebp)
  8002ba:	ff 75 0c             	pushl  0xc(%ebp)
  8002bd:	ff 75 08             	pushl  0x8(%ebp)
  8002c0:	e8 05 00 00 00       	call   8002ca <vprintfmt>
	va_end(ap);
}
  8002c5:	83 c4 10             	add    $0x10,%esp
  8002c8:	c9                   	leave  
  8002c9:	c3                   	ret    

008002ca <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002ca:	55                   	push   %ebp
  8002cb:	89 e5                	mov    %esp,%ebp
  8002cd:	57                   	push   %edi
  8002ce:	56                   	push   %esi
  8002cf:	53                   	push   %ebx
  8002d0:	83 ec 2c             	sub    $0x2c,%esp
  8002d3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8002d6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002d9:	eb 03                	jmp    8002de <vprintfmt+0x14>
			break;

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
			for (fmt--; fmt[-1] != '%'; fmt--)
  8002db:	89 75 10             	mov    %esi,0x10(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {    //遍历输入的第一个参数，即输出信息的格式，先把格式字符串中'%'之前的字符一个个输出，因为它们前面没有'%'，所以它们就是要直接显示在屏幕上的
  8002de:	8b 45 10             	mov    0x10(%ebp),%eax
  8002e1:	8d 70 01             	lea    0x1(%eax),%esi
  8002e4:	0f b6 00             	movzbl (%eax),%eax
  8002e7:	83 f8 25             	cmp    $0x25,%eax
  8002ea:	74 25                	je     800311 <vprintfmt+0x47>
			if (ch == '\0')									//当然中间如果遇到'\0'，代表这个字符串的访问结束
  8002ec:	85 c0                	test   %eax,%eax
  8002ee:	75 0d                	jne    8002fd <vprintfmt+0x33>
  8002f0:	e9 b5 03 00 00       	jmp    8006aa <vprintfmt+0x3e0>
  8002f5:	85 c0                	test   %eax,%eax
  8002f7:	0f 84 ad 03 00 00    	je     8006aa <vprintfmt+0x3e0>
				return;
			putch(ch, putdat);								//调用putch函数，把一个字符ch输出到putdat指针所指向的地址中所存放的值对应的地址处
  8002fd:	83 ec 08             	sub    $0x8,%esp
  800300:	53                   	push   %ebx
  800301:	50                   	push   %eax
  800302:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {    //遍历输入的第一个参数，即输出信息的格式，先把格式字符串中'%'之前的字符一个个输出，因为它们前面没有'%'，所以它们就是要直接显示在屏幕上的
  800304:	46                   	inc    %esi
  800305:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  800309:	83 c4 10             	add    $0x10,%esp
  80030c:	83 f8 25             	cmp    $0x25,%eax
  80030f:	75 e4                	jne    8002f5 <vprintfmt+0x2b>
			if (width < 0)									//代表有小数点，但是小数点前面并没有数字，比如'%.6f'这种情况，此时代表整数部分全部显示
				width = 0;			
			goto reswitch;

		case '#':
			altflag = 1;
  800311:	c6 45 e3 20          	movb   $0x20,-0x1d(%ebp)
  800315:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80031c:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800323:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80032a:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800331:	eb 07                	jmp    80033a <vprintfmt+0x70>
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  800333:	8b 75 10             	mov    0x10(%ebp),%esi

		// flag to pad on the right
		case '-':											//%后面的'-'代表要进行左对齐输出，右边填空格，如果省略代表右对齐
			padc = '-';										//如果有这个字符代表左对齐，则把对齐方式标志位变为'-'
  800336:	c6 45 e3 2d          	movb   $0x2d,-0x1d(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  80033a:	8d 46 01             	lea    0x1(%esi),%eax
  80033d:	89 45 10             	mov    %eax,0x10(%ebp)
  800340:	0f b6 16             	movzbl (%esi),%edx
  800343:	8a 06                	mov    (%esi),%al
  800345:	83 e8 23             	sub    $0x23,%eax
  800348:	3c 55                	cmp    $0x55,%al
  80034a:	0f 87 03 03 00 00    	ja     800653 <vprintfmt+0x389>
  800350:	0f b6 c0             	movzbl %al,%eax
  800353:	ff 24 85 60 20 80 00 	jmp    *0x802060(,%eax,4)
  80035a:	8b 75 10             	mov    0x10(%ebp),%esi
			padc = '-';										//如果有这个字符代表左对齐，则把对齐方式标志位变为'-'
			goto reswitch;									//处理下一个字符

		// flag to pad with 0's instead of spaces
		case '0':											//0--有0表示进行对齐输出时填0,如省略表示填入空格，并且如果为0，则一定是右对齐
			padc = '0';										//对其方式标志位变为0
  80035d:	c6 45 e3 30          	movb   $0x30,-0x1d(%ebp)
  800361:	eb d7                	jmp    80033a <vprintfmt+0x70>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {					//把遇到的位数字符串转换为真实的位数，比如输入的'%40'，代表有效位数为40位，下面的循环就是把precesion的值设置为40
				precision = precision * 10 + ch - '0';
  800363:	8d 42 d0             	lea    -0x30(%edx),%eax
  800366:	89 c1                	mov    %eax,%ecx
  800368:	89 45 d0             	mov    %eax,-0x30(%ebp)
				ch = *fmt;
  80036b:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  80036f:	8d 50 d0             	lea    -0x30(%eax),%edx
  800372:	83 fa 09             	cmp    $0x9,%edx
  800375:	77 51                	ja     8003c8 <vprintfmt+0xfe>
  800377:	8b 75 10             	mov    0x10(%ebp),%esi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {					//把遇到的位数字符串转换为真实的位数，比如输入的'%40'，代表有效位数为40位，下面的循环就是把precesion的值设置为40
  80037a:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  80037b:	8d 14 89             	lea    (%ecx,%ecx,4),%edx
  80037e:	01 d2                	add    %edx,%edx
  800380:	8d 4c 10 d0          	lea    -0x30(%eax,%edx,1),%ecx
				ch = *fmt;
  800384:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800387:	8d 50 d0             	lea    -0x30(%eax),%edx
  80038a:	83 fa 09             	cmp    $0x9,%edx
  80038d:	76 eb                	jbe    80037a <vprintfmt+0xb0>
  80038f:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800392:	eb 37                	jmp    8003cb <vprintfmt+0x101>
					break;
			}
			goto process_precision;							//跳转到process_precistion子过程

		case '*':											//*--代表有效数字的位数也是由输入参数指定的，比如printf("%*.*f", 10, 2, n)，其中10,2就是用来指定显示的有效数字位数的
			precision = va_arg(ap, int);
  800394:	8b 45 14             	mov    0x14(%ebp),%eax
  800397:	8d 50 04             	lea    0x4(%eax),%edx
  80039a:	89 55 14             	mov    %edx,0x14(%ebp)
  80039d:	8b 00                	mov    (%eax),%eax
  80039f:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  8003a2:	8b 75 10             	mov    0x10(%ebp),%esi
			}
			goto process_precision;							//跳转到process_precistion子过程

		case '*':											//*--代表有效数字的位数也是由输入参数指定的，比如printf("%*.*f", 10, 2, n)，其中10,2就是用来指定显示的有效数字位数的
			precision = va_arg(ap, int);
			goto process_precision;
  8003a5:	eb 24                	jmp    8003cb <vprintfmt+0x101>
  8003a7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003ab:	79 07                	jns    8003b4 <vprintfmt+0xea>
  8003ad:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  8003b4:	8b 75 10             	mov    0x10(%ebp),%esi
  8003b7:	eb 81                	jmp    80033a <vprintfmt+0x70>
  8003b9:	8b 75 10             	mov    0x10(%ebp),%esi
			if (width < 0)									//代表有小数点，但是小数点前面并没有数字，比如'%.6f'这种情况，此时代表整数部分全部显示
				width = 0;			
			goto reswitch;

		case '#':
			altflag = 1;
  8003bc:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003c3:	e9 72 ff ff ff       	jmp    80033a <vprintfmt+0x70>
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  8003c8:	8b 75 10             	mov    0x10(%ebp),%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:									//处理输出精度，把width字段赋值为刚刚计算出来的precision值，所以width应该是整数部分的有效数字位数
			if (width < 0)
  8003cb:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003cf:	0f 89 65 ff ff ff    	jns    80033a <vprintfmt+0x70>
				width = precision, precision = -1;
  8003d5:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003d8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003db:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003e2:	e9 53 ff ff ff       	jmp    80033a <vprintfmt+0x70>
			goto reswitch;

		// long flag (doubled for long long)				
		case 'l':											//如果遇到'l'，代表应该是输入long类型，如果有两个'l'代表long long
			lflag++;										//此时把lflag++
  8003e7:	ff 45 d4             	incl   -0x2c(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  8003ea:	8b 75 10             	mov    0x10(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)				
		case 'l':											//如果遇到'l'，代表应该是输入long类型，如果有两个'l'代表long long
			lflag++;										//此时把lflag++
			goto reswitch;
  8003ed:	e9 48 ff ff ff       	jmp    80033a <vprintfmt+0x70>

		// character
		case 'c':											//如果是'c'代表显示一个字符
			putch(va_arg(ap, int), putdat);					//调用输出一个字符到内存的函数putch
  8003f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f5:	8d 50 04             	lea    0x4(%eax),%edx
  8003f8:	89 55 14             	mov    %edx,0x14(%ebp)
  8003fb:	83 ec 08             	sub    $0x8,%esp
  8003fe:	53                   	push   %ebx
  8003ff:	ff 30                	pushl  (%eax)
  800401:	ff d7                	call   *%edi
			break;
  800403:	83 c4 10             	add    $0x10,%esp
  800406:	e9 d3 fe ff ff       	jmp    8002de <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80040b:	8b 45 14             	mov    0x14(%ebp),%eax
  80040e:	8d 50 04             	lea    0x4(%eax),%edx
  800411:	89 55 14             	mov    %edx,0x14(%ebp)
  800414:	8b 00                	mov    (%eax),%eax
  800416:	85 c0                	test   %eax,%eax
  800418:	79 02                	jns    80041c <vprintfmt+0x152>
  80041a:	f7 d8                	neg    %eax
  80041c:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80041e:	83 f8 0f             	cmp    $0xf,%eax
  800421:	7f 0b                	jg     80042e <vprintfmt+0x164>
  800423:	8b 04 85 c0 21 80 00 	mov    0x8021c0(,%eax,4),%eax
  80042a:	85 c0                	test   %eax,%eax
  80042c:	75 15                	jne    800443 <vprintfmt+0x179>
				printfmt(putch, putdat, "error %d", err);
  80042e:	52                   	push   %edx
  80042f:	68 2d 1f 80 00       	push   $0x801f2d
  800434:	53                   	push   %ebx
  800435:	57                   	push   %edi
  800436:	e8 72 fe ff ff       	call   8002ad <printfmt>
  80043b:	83 c4 10             	add    $0x10,%esp
  80043e:	e9 9b fe ff ff       	jmp    8002de <vprintfmt+0x14>
			else
				printfmt(putch, putdat, "%s", p);
  800443:	50                   	push   %eax
  800444:	68 df 22 80 00       	push   $0x8022df
  800449:	53                   	push   %ebx
  80044a:	57                   	push   %edi
  80044b:	e8 5d fe ff ff       	call   8002ad <printfmt>
  800450:	83 c4 10             	add    $0x10,%esp
  800453:	e9 86 fe ff ff       	jmp    8002de <vprintfmt+0x14>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800458:	8b 45 14             	mov    0x14(%ebp),%eax
  80045b:	8d 50 04             	lea    0x4(%eax),%edx
  80045e:	89 55 14             	mov    %edx,0x14(%ebp)
  800461:	8b 00                	mov    (%eax),%eax
  800463:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800466:	85 c0                	test   %eax,%eax
  800468:	75 07                	jne    800471 <vprintfmt+0x1a7>
				p = "(null)";
  80046a:	c7 45 d4 26 1f 80 00 	movl   $0x801f26,-0x2c(%ebp)
			if (width > 0 && padc != '-')
  800471:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800474:	85 f6                	test   %esi,%esi
  800476:	0f 8e fb 01 00 00    	jle    800677 <vprintfmt+0x3ad>
  80047c:	80 7d e3 2d          	cmpb   $0x2d,-0x1d(%ebp)
  800480:	0f 84 09 02 00 00    	je     80068f <vprintfmt+0x3c5>
				for (width -= strnlen(p, precision); width > 0; width--)
  800486:	83 ec 08             	sub    $0x8,%esp
  800489:	ff 75 d0             	pushl  -0x30(%ebp)
  80048c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80048f:	e8 ad 02 00 00       	call   800741 <strnlen>
  800494:	89 f1                	mov    %esi,%ecx
  800496:	29 c1                	sub    %eax,%ecx
  800498:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  80049b:	83 c4 10             	add    $0x10,%esp
  80049e:	85 c9                	test   %ecx,%ecx
  8004a0:	0f 8e d1 01 00 00    	jle    800677 <vprintfmt+0x3ad>
					putch(padc, putdat);
  8004a6:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  8004aa:	83 ec 08             	sub    $0x8,%esp
  8004ad:	53                   	push   %ebx
  8004ae:	56                   	push   %esi
  8004af:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004b1:	83 c4 10             	add    $0x10,%esp
  8004b4:	ff 4d e4             	decl   -0x1c(%ebp)
  8004b7:	75 f1                	jne    8004aa <vprintfmt+0x1e0>
  8004b9:	e9 b9 01 00 00       	jmp    800677 <vprintfmt+0x3ad>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004be:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004c2:	74 19                	je     8004dd <vprintfmt+0x213>
  8004c4:	0f be c0             	movsbl %al,%eax
  8004c7:	83 e8 20             	sub    $0x20,%eax
  8004ca:	83 f8 5e             	cmp    $0x5e,%eax
  8004cd:	76 0e                	jbe    8004dd <vprintfmt+0x213>
					putch('?', putdat);
  8004cf:	83 ec 08             	sub    $0x8,%esp
  8004d2:	53                   	push   %ebx
  8004d3:	6a 3f                	push   $0x3f
  8004d5:	ff 55 08             	call   *0x8(%ebp)
  8004d8:	83 c4 10             	add    $0x10,%esp
  8004db:	eb 0b                	jmp    8004e8 <vprintfmt+0x21e>
				else
					putch(ch, putdat);
  8004dd:	83 ec 08             	sub    $0x8,%esp
  8004e0:	53                   	push   %ebx
  8004e1:	52                   	push   %edx
  8004e2:	ff 55 08             	call   *0x8(%ebp)
  8004e5:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004e8:	ff 4d e4             	decl   -0x1c(%ebp)
  8004eb:	46                   	inc    %esi
  8004ec:	8a 46 ff             	mov    -0x1(%esi),%al
  8004ef:	0f be d0             	movsbl %al,%edx
  8004f2:	85 d2                	test   %edx,%edx
  8004f4:	75 1c                	jne    800512 <vprintfmt+0x248>
  8004f6:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004f9:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004fd:	7f 1f                	jg     80051e <vprintfmt+0x254>
  8004ff:	e9 da fd ff ff       	jmp    8002de <vprintfmt+0x14>
  800504:	89 7d 08             	mov    %edi,0x8(%ebp)
  800507:	8b 7d d0             	mov    -0x30(%ebp),%edi
  80050a:	eb 06                	jmp    800512 <vprintfmt+0x248>
  80050c:	89 7d 08             	mov    %edi,0x8(%ebp)
  80050f:	8b 7d d0             	mov    -0x30(%ebp),%edi
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800512:	85 ff                	test   %edi,%edi
  800514:	78 a8                	js     8004be <vprintfmt+0x1f4>
  800516:	4f                   	dec    %edi
  800517:	79 a5                	jns    8004be <vprintfmt+0x1f4>
  800519:	8b 7d 08             	mov    0x8(%ebp),%edi
  80051c:	eb db                	jmp    8004f9 <vprintfmt+0x22f>
  80051e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800521:	83 ec 08             	sub    $0x8,%esp
  800524:	53                   	push   %ebx
  800525:	6a 20                	push   $0x20
  800527:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800529:	4e                   	dec    %esi
  80052a:	83 c4 10             	add    $0x10,%esp
  80052d:	85 f6                	test   %esi,%esi
  80052f:	7f f0                	jg     800521 <vprintfmt+0x257>
  800531:	e9 a8 fd ff ff       	jmp    8002de <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800536:	83 7d d4 01          	cmpl   $0x1,-0x2c(%ebp)
  80053a:	7e 16                	jle    800552 <vprintfmt+0x288>
		return va_arg(*ap, long long);
  80053c:	8b 45 14             	mov    0x14(%ebp),%eax
  80053f:	8d 50 08             	lea    0x8(%eax),%edx
  800542:	89 55 14             	mov    %edx,0x14(%ebp)
  800545:	8b 50 04             	mov    0x4(%eax),%edx
  800548:	8b 00                	mov    (%eax),%eax
  80054a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80054d:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800550:	eb 34                	jmp    800586 <vprintfmt+0x2bc>
	else if (lflag)
  800552:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800556:	74 18                	je     800570 <vprintfmt+0x2a6>
		return va_arg(*ap, long);
  800558:	8b 45 14             	mov    0x14(%ebp),%eax
  80055b:	8d 50 04             	lea    0x4(%eax),%edx
  80055e:	89 55 14             	mov    %edx,0x14(%ebp)
  800561:	8b 30                	mov    (%eax),%esi
  800563:	89 75 d8             	mov    %esi,-0x28(%ebp)
  800566:	89 f0                	mov    %esi,%eax
  800568:	c1 f8 1f             	sar    $0x1f,%eax
  80056b:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80056e:	eb 16                	jmp    800586 <vprintfmt+0x2bc>
	else
		return va_arg(*ap, int);
  800570:	8b 45 14             	mov    0x14(%ebp),%eax
  800573:	8d 50 04             	lea    0x4(%eax),%edx
  800576:	89 55 14             	mov    %edx,0x14(%ebp)
  800579:	8b 30                	mov    (%eax),%esi
  80057b:	89 75 d8             	mov    %esi,-0x28(%ebp)
  80057e:	89 f0                	mov    %esi,%eax
  800580:	c1 f8 1f             	sar    $0x1f,%eax
  800583:	89 45 dc             	mov    %eax,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800586:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800589:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
  80058c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800590:	0f 89 8a 00 00 00    	jns    800620 <vprintfmt+0x356>
				putch('-', putdat);
  800596:	83 ec 08             	sub    $0x8,%esp
  800599:	53                   	push   %ebx
  80059a:	6a 2d                	push   $0x2d
  80059c:	ff d7                	call   *%edi
				num = -(long long) num;
  80059e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005a1:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005a4:	f7 d8                	neg    %eax
  8005a6:	83 d2 00             	adc    $0x0,%edx
  8005a9:	f7 da                	neg    %edx
  8005ab:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005ae:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8005b3:	eb 70                	jmp    800625 <vprintfmt+0x35b>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005b5:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8005b8:	8d 45 14             	lea    0x14(%ebp),%eax
  8005bb:	e8 97 fc ff ff       	call   800257 <getuint>
			base = 10;
  8005c0:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8005c5:	eb 5e                	jmp    800625 <vprintfmt+0x35b>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
  8005c7:	83 ec 08             	sub    $0x8,%esp
  8005ca:	53                   	push   %ebx
  8005cb:	6a 30                	push   $0x30
  8005cd:	ff d7                	call   *%edi
			num = getuint(&ap, lflag);
  8005cf:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8005d2:	8d 45 14             	lea    0x14(%ebp),%eax
  8005d5:	e8 7d fc ff ff       	call   800257 <getuint>
			base = 8;
			goto number;
  8005da:	83 c4 10             	add    $0x10,%esp
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  8005dd:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8005e2:	eb 41                	jmp    800625 <vprintfmt+0x35b>
		// pointer
		case 'p':
			putch('0', putdat);
  8005e4:	83 ec 08             	sub    $0x8,%esp
  8005e7:	53                   	push   %ebx
  8005e8:	6a 30                	push   $0x30
  8005ea:	ff d7                	call   *%edi
			putch('x', putdat);
  8005ec:	83 c4 08             	add    $0x8,%esp
  8005ef:	53                   	push   %ebx
  8005f0:	6a 78                	push   $0x78
  8005f2:	ff d7                	call   *%edi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f7:	8d 50 04             	lea    0x4(%eax),%edx
  8005fa:	89 55 14             	mov    %edx,0x14(%ebp)
			goto number;
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005fd:	8b 00                	mov    (%eax),%eax
  8005ff:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800604:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800607:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80060c:	eb 17                	jmp    800625 <vprintfmt+0x35b>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80060e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800611:	8d 45 14             	lea    0x14(%ebp),%eax
  800614:	e8 3e fc ff ff       	call   800257 <getuint>
			base = 16;
  800619:	b9 10 00 00 00       	mov    $0x10,%ecx
  80061e:	eb 05                	jmp    800625 <vprintfmt+0x35b>
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800620:	b9 0a 00 00 00       	mov    $0xa,%ecx
		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  800625:	83 ec 0c             	sub    $0xc,%esp
  800628:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  80062c:	56                   	push   %esi
  80062d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800630:	51                   	push   %ecx
  800631:	52                   	push   %edx
  800632:	50                   	push   %eax
  800633:	89 da                	mov    %ebx,%edx
  800635:	89 f8                	mov    %edi,%eax
  800637:	e8 6b fb ff ff       	call   8001a7 <printnum>
			break;
  80063c:	83 c4 20             	add    $0x20,%esp
  80063f:	e9 9a fc ff ff       	jmp    8002de <vprintfmt+0x14>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800644:	83 ec 08             	sub    $0x8,%esp
  800647:	53                   	push   %ebx
  800648:	52                   	push   %edx
  800649:	ff d7                	call   *%edi
			break;
  80064b:	83 c4 10             	add    $0x10,%esp
  80064e:	e9 8b fc ff ff       	jmp    8002de <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800653:	83 ec 08             	sub    $0x8,%esp
  800656:	53                   	push   %ebx
  800657:	6a 25                	push   $0x25
  800659:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80065b:	83 c4 10             	add    $0x10,%esp
  80065e:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800662:	0f 84 73 fc ff ff    	je     8002db <vprintfmt+0x11>
  800668:	4e                   	dec    %esi
  800669:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80066d:	75 f9                	jne    800668 <vprintfmt+0x39e>
  80066f:	89 75 10             	mov    %esi,0x10(%ebp)
  800672:	e9 67 fc ff ff       	jmp    8002de <vprintfmt+0x14>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800677:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80067a:	8d 70 01             	lea    0x1(%eax),%esi
  80067d:	8a 00                	mov    (%eax),%al
  80067f:	0f be d0             	movsbl %al,%edx
  800682:	85 d2                	test   %edx,%edx
  800684:	0f 85 7a fe ff ff    	jne    800504 <vprintfmt+0x23a>
  80068a:	e9 4f fc ff ff       	jmp    8002de <vprintfmt+0x14>
  80068f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800692:	8d 70 01             	lea    0x1(%eax),%esi
  800695:	8a 00                	mov    (%eax),%al
  800697:	0f be d0             	movsbl %al,%edx
  80069a:	85 d2                	test   %edx,%edx
  80069c:	0f 85 6a fe ff ff    	jne    80050c <vprintfmt+0x242>
  8006a2:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8006a5:	e9 77 fe ff ff       	jmp    800521 <vprintfmt+0x257>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  8006aa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006ad:	5b                   	pop    %ebx
  8006ae:	5e                   	pop    %esi
  8006af:	5f                   	pop    %edi
  8006b0:	5d                   	pop    %ebp
  8006b1:	c3                   	ret    

008006b2 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006b2:	55                   	push   %ebp
  8006b3:	89 e5                	mov    %esp,%ebp
  8006b5:	83 ec 18             	sub    $0x18,%esp
  8006b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8006bb:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006be:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006c1:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006c5:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006c8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006cf:	85 c0                	test   %eax,%eax
  8006d1:	74 26                	je     8006f9 <vsnprintf+0x47>
  8006d3:	85 d2                	test   %edx,%edx
  8006d5:	7e 29                	jle    800700 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006d7:	ff 75 14             	pushl  0x14(%ebp)
  8006da:	ff 75 10             	pushl  0x10(%ebp)
  8006dd:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006e0:	50                   	push   %eax
  8006e1:	68 91 02 80 00       	push   $0x800291
  8006e6:	e8 df fb ff ff       	call   8002ca <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006eb:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006ee:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006f4:	83 c4 10             	add    $0x10,%esp
  8006f7:	eb 0c                	jmp    800705 <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006f9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006fe:	eb 05                	jmp    800705 <vsnprintf+0x53>
  800700:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800705:	c9                   	leave  
  800706:	c3                   	ret    

00800707 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800707:	55                   	push   %ebp
  800708:	89 e5                	mov    %esp,%ebp
  80070a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80070d:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800710:	50                   	push   %eax
  800711:	ff 75 10             	pushl  0x10(%ebp)
  800714:	ff 75 0c             	pushl  0xc(%ebp)
  800717:	ff 75 08             	pushl  0x8(%ebp)
  80071a:	e8 93 ff ff ff       	call   8006b2 <vsnprintf>
	va_end(ap);

	return rc;
}
  80071f:	c9                   	leave  
  800720:	c3                   	ret    

00800721 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800721:	55                   	push   %ebp
  800722:	89 e5                	mov    %esp,%ebp
  800724:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800727:	80 3a 00             	cmpb   $0x0,(%edx)
  80072a:	74 0e                	je     80073a <strlen+0x19>
  80072c:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800731:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800732:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800736:	75 f9                	jne    800731 <strlen+0x10>
  800738:	eb 05                	jmp    80073f <strlen+0x1e>
  80073a:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  80073f:	5d                   	pop    %ebp
  800740:	c3                   	ret    

00800741 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800741:	55                   	push   %ebp
  800742:	89 e5                	mov    %esp,%ebp
  800744:	53                   	push   %ebx
  800745:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800748:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80074b:	85 c9                	test   %ecx,%ecx
  80074d:	74 1a                	je     800769 <strnlen+0x28>
  80074f:	80 3b 00             	cmpb   $0x0,(%ebx)
  800752:	74 1c                	je     800770 <strnlen+0x2f>
  800754:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  800759:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80075b:	39 ca                	cmp    %ecx,%edx
  80075d:	74 16                	je     800775 <strnlen+0x34>
  80075f:	42                   	inc    %edx
  800760:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800765:	75 f2                	jne    800759 <strnlen+0x18>
  800767:	eb 0c                	jmp    800775 <strnlen+0x34>
  800769:	b8 00 00 00 00       	mov    $0x0,%eax
  80076e:	eb 05                	jmp    800775 <strnlen+0x34>
  800770:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800775:	5b                   	pop    %ebx
  800776:	5d                   	pop    %ebp
  800777:	c3                   	ret    

00800778 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800778:	55                   	push   %ebp
  800779:	89 e5                	mov    %esp,%ebp
  80077b:	53                   	push   %ebx
  80077c:	8b 45 08             	mov    0x8(%ebp),%eax
  80077f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800782:	89 c2                	mov    %eax,%edx
  800784:	42                   	inc    %edx
  800785:	41                   	inc    %ecx
  800786:	8a 59 ff             	mov    -0x1(%ecx),%bl
  800789:	88 5a ff             	mov    %bl,-0x1(%edx)
  80078c:	84 db                	test   %bl,%bl
  80078e:	75 f4                	jne    800784 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800790:	5b                   	pop    %ebx
  800791:	5d                   	pop    %ebp
  800792:	c3                   	ret    

00800793 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800793:	55                   	push   %ebp
  800794:	89 e5                	mov    %esp,%ebp
  800796:	53                   	push   %ebx
  800797:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80079a:	53                   	push   %ebx
  80079b:	e8 81 ff ff ff       	call   800721 <strlen>
  8007a0:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007a3:	ff 75 0c             	pushl  0xc(%ebp)
  8007a6:	01 d8                	add    %ebx,%eax
  8007a8:	50                   	push   %eax
  8007a9:	e8 ca ff ff ff       	call   800778 <strcpy>
	return dst;
}
  8007ae:	89 d8                	mov    %ebx,%eax
  8007b0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007b3:	c9                   	leave  
  8007b4:	c3                   	ret    

008007b5 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007b5:	55                   	push   %ebp
  8007b6:	89 e5                	mov    %esp,%ebp
  8007b8:	56                   	push   %esi
  8007b9:	53                   	push   %ebx
  8007ba:	8b 75 08             	mov    0x8(%ebp),%esi
  8007bd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007c0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007c3:	85 db                	test   %ebx,%ebx
  8007c5:	74 14                	je     8007db <strncpy+0x26>
  8007c7:	01 f3                	add    %esi,%ebx
  8007c9:	89 f1                	mov    %esi,%ecx
		*dst++ = *src;
  8007cb:	41                   	inc    %ecx
  8007cc:	8a 02                	mov    (%edx),%al
  8007ce:	88 41 ff             	mov    %al,-0x1(%ecx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007d1:	80 3a 01             	cmpb   $0x1,(%edx)
  8007d4:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007d7:	39 cb                	cmp    %ecx,%ebx
  8007d9:	75 f0                	jne    8007cb <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007db:	89 f0                	mov    %esi,%eax
  8007dd:	5b                   	pop    %ebx
  8007de:	5e                   	pop    %esi
  8007df:	5d                   	pop    %ebp
  8007e0:	c3                   	ret    

008007e1 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007e1:	55                   	push   %ebp
  8007e2:	89 e5                	mov    %esp,%ebp
  8007e4:	53                   	push   %ebx
  8007e5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007e8:	8b 45 10             	mov    0x10(%ebp),%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007eb:	85 c0                	test   %eax,%eax
  8007ed:	74 30                	je     80081f <strlcpy+0x3e>
		while (--size > 0 && *src != '\0')
  8007ef:	48                   	dec    %eax
  8007f0:	74 20                	je     800812 <strlcpy+0x31>
  8007f2:	8a 0b                	mov    (%ebx),%cl
  8007f4:	84 c9                	test   %cl,%cl
  8007f6:	74 1f                	je     800817 <strlcpy+0x36>
  8007f8:	8d 53 01             	lea    0x1(%ebx),%edx
  8007fb:	01 c3                	add    %eax,%ebx
  8007fd:	8b 45 08             	mov    0x8(%ebp),%eax
			*dst++ = *src++;
  800800:	40                   	inc    %eax
  800801:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800804:	39 da                	cmp    %ebx,%edx
  800806:	74 12                	je     80081a <strlcpy+0x39>
  800808:	42                   	inc    %edx
  800809:	8a 4a ff             	mov    -0x1(%edx),%cl
  80080c:	84 c9                	test   %cl,%cl
  80080e:	75 f0                	jne    800800 <strlcpy+0x1f>
  800810:	eb 08                	jmp    80081a <strlcpy+0x39>
  800812:	8b 45 08             	mov    0x8(%ebp),%eax
  800815:	eb 03                	jmp    80081a <strlcpy+0x39>
  800817:	8b 45 08             	mov    0x8(%ebp),%eax
			*dst++ = *src++;
		*dst = '\0';
  80081a:	c6 00 00             	movb   $0x0,(%eax)
  80081d:	eb 03                	jmp    800822 <strlcpy+0x41>
  80081f:	8b 45 08             	mov    0x8(%ebp),%eax
	}
	return dst - dst_in;
  800822:	2b 45 08             	sub    0x8(%ebp),%eax
}
  800825:	5b                   	pop    %ebx
  800826:	5d                   	pop    %ebp
  800827:	c3                   	ret    

00800828 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800828:	55                   	push   %ebp
  800829:	89 e5                	mov    %esp,%ebp
  80082b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80082e:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800831:	8a 01                	mov    (%ecx),%al
  800833:	84 c0                	test   %al,%al
  800835:	74 10                	je     800847 <strcmp+0x1f>
  800837:	3a 02                	cmp    (%edx),%al
  800839:	75 0c                	jne    800847 <strcmp+0x1f>
		p++, q++;
  80083b:	41                   	inc    %ecx
  80083c:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80083d:	8a 01                	mov    (%ecx),%al
  80083f:	84 c0                	test   %al,%al
  800841:	74 04                	je     800847 <strcmp+0x1f>
  800843:	3a 02                	cmp    (%edx),%al
  800845:	74 f4                	je     80083b <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800847:	0f b6 c0             	movzbl %al,%eax
  80084a:	0f b6 12             	movzbl (%edx),%edx
  80084d:	29 d0                	sub    %edx,%eax
}
  80084f:	5d                   	pop    %ebp
  800850:	c3                   	ret    

00800851 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800851:	55                   	push   %ebp
  800852:	89 e5                	mov    %esp,%ebp
  800854:	56                   	push   %esi
  800855:	53                   	push   %ebx
  800856:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800859:	8b 55 0c             	mov    0xc(%ebp),%edx
  80085c:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  80085f:	85 f6                	test   %esi,%esi
  800861:	74 23                	je     800886 <strncmp+0x35>
  800863:	8a 03                	mov    (%ebx),%al
  800865:	84 c0                	test   %al,%al
  800867:	74 2b                	je     800894 <strncmp+0x43>
  800869:	3a 02                	cmp    (%edx),%al
  80086b:	75 27                	jne    800894 <strncmp+0x43>
  80086d:	8d 43 01             	lea    0x1(%ebx),%eax
  800870:	01 de                	add    %ebx,%esi
		n--, p++, q++;
  800872:	89 c3                	mov    %eax,%ebx
  800874:	42                   	inc    %edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800875:	39 c6                	cmp    %eax,%esi
  800877:	74 14                	je     80088d <strncmp+0x3c>
  800879:	8a 08                	mov    (%eax),%cl
  80087b:	84 c9                	test   %cl,%cl
  80087d:	74 15                	je     800894 <strncmp+0x43>
  80087f:	40                   	inc    %eax
  800880:	3a 0a                	cmp    (%edx),%cl
  800882:	74 ee                	je     800872 <strncmp+0x21>
  800884:	eb 0e                	jmp    800894 <strncmp+0x43>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800886:	b8 00 00 00 00       	mov    $0x0,%eax
  80088b:	eb 0f                	jmp    80089c <strncmp+0x4b>
  80088d:	b8 00 00 00 00       	mov    $0x0,%eax
  800892:	eb 08                	jmp    80089c <strncmp+0x4b>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800894:	0f b6 03             	movzbl (%ebx),%eax
  800897:	0f b6 12             	movzbl (%edx),%edx
  80089a:	29 d0                	sub    %edx,%eax
}
  80089c:	5b                   	pop    %ebx
  80089d:	5e                   	pop    %esi
  80089e:	5d                   	pop    %ebp
  80089f:	c3                   	ret    

008008a0 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008a0:	55                   	push   %ebp
  8008a1:	89 e5                	mov    %esp,%ebp
  8008a3:	53                   	push   %ebx
  8008a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  8008aa:	8a 10                	mov    (%eax),%dl
  8008ac:	84 d2                	test   %dl,%dl
  8008ae:	74 1a                	je     8008ca <strchr+0x2a>
  8008b0:	88 d9                	mov    %bl,%cl
		if (*s == c)
  8008b2:	38 d3                	cmp    %dl,%bl
  8008b4:	75 06                	jne    8008bc <strchr+0x1c>
  8008b6:	eb 17                	jmp    8008cf <strchr+0x2f>
  8008b8:	38 ca                	cmp    %cl,%dl
  8008ba:	74 13                	je     8008cf <strchr+0x2f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008bc:	40                   	inc    %eax
  8008bd:	8a 10                	mov    (%eax),%dl
  8008bf:	84 d2                	test   %dl,%dl
  8008c1:	75 f5                	jne    8008b8 <strchr+0x18>
		if (*s == c)
			return (char *) s;
	return 0;
  8008c3:	b8 00 00 00 00       	mov    $0x0,%eax
  8008c8:	eb 05                	jmp    8008cf <strchr+0x2f>
  8008ca:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008cf:	5b                   	pop    %ebx
  8008d0:	5d                   	pop    %ebp
  8008d1:	c3                   	ret    

008008d2 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008d2:	55                   	push   %ebp
  8008d3:	89 e5                	mov    %esp,%ebp
  8008d5:	53                   	push   %ebx
  8008d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  8008dc:	8a 10                	mov    (%eax),%dl
  8008de:	84 d2                	test   %dl,%dl
  8008e0:	74 13                	je     8008f5 <strfind+0x23>
  8008e2:	88 d9                	mov    %bl,%cl
		if (*s == c)
  8008e4:	38 d3                	cmp    %dl,%bl
  8008e6:	75 06                	jne    8008ee <strfind+0x1c>
  8008e8:	eb 0b                	jmp    8008f5 <strfind+0x23>
  8008ea:	38 ca                	cmp    %cl,%dl
  8008ec:	74 07                	je     8008f5 <strfind+0x23>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8008ee:	40                   	inc    %eax
  8008ef:	8a 10                	mov    (%eax),%dl
  8008f1:	84 d2                	test   %dl,%dl
  8008f3:	75 f5                	jne    8008ea <strfind+0x18>
		if (*s == c)
			break;
	return (char *) s;
}
  8008f5:	5b                   	pop    %ebx
  8008f6:	5d                   	pop    %ebp
  8008f7:	c3                   	ret    

008008f8 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008f8:	55                   	push   %ebp
  8008f9:	89 e5                	mov    %esp,%ebp
  8008fb:	57                   	push   %edi
  8008fc:	56                   	push   %esi
  8008fd:	53                   	push   %ebx
  8008fe:	8b 7d 08             	mov    0x8(%ebp),%edi
  800901:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800904:	85 c9                	test   %ecx,%ecx
  800906:	74 36                	je     80093e <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800908:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80090e:	75 28                	jne    800938 <memset+0x40>
  800910:	f6 c1 03             	test   $0x3,%cl
  800913:	75 23                	jne    800938 <memset+0x40>
		c &= 0xFF;
  800915:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800919:	89 d3                	mov    %edx,%ebx
  80091b:	c1 e3 08             	shl    $0x8,%ebx
  80091e:	89 d6                	mov    %edx,%esi
  800920:	c1 e6 18             	shl    $0x18,%esi
  800923:	89 d0                	mov    %edx,%eax
  800925:	c1 e0 10             	shl    $0x10,%eax
  800928:	09 f0                	or     %esi,%eax
  80092a:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80092c:	89 d8                	mov    %ebx,%eax
  80092e:	09 d0                	or     %edx,%eax
  800930:	c1 e9 02             	shr    $0x2,%ecx
  800933:	fc                   	cld    
  800934:	f3 ab                	rep stos %eax,%es:(%edi)
  800936:	eb 06                	jmp    80093e <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800938:	8b 45 0c             	mov    0xc(%ebp),%eax
  80093b:	fc                   	cld    
  80093c:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80093e:	89 f8                	mov    %edi,%eax
  800940:	5b                   	pop    %ebx
  800941:	5e                   	pop    %esi
  800942:	5f                   	pop    %edi
  800943:	5d                   	pop    %ebp
  800944:	c3                   	ret    

00800945 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800945:	55                   	push   %ebp
  800946:	89 e5                	mov    %esp,%ebp
  800948:	57                   	push   %edi
  800949:	56                   	push   %esi
  80094a:	8b 45 08             	mov    0x8(%ebp),%eax
  80094d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800950:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800953:	39 c6                	cmp    %eax,%esi
  800955:	73 33                	jae    80098a <memmove+0x45>
  800957:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80095a:	39 d0                	cmp    %edx,%eax
  80095c:	73 2c                	jae    80098a <memmove+0x45>
		s += n;
		d += n;
  80095e:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800961:	89 d6                	mov    %edx,%esi
  800963:	09 fe                	or     %edi,%esi
  800965:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80096b:	75 13                	jne    800980 <memmove+0x3b>
  80096d:	f6 c1 03             	test   $0x3,%cl
  800970:	75 0e                	jne    800980 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800972:	83 ef 04             	sub    $0x4,%edi
  800975:	8d 72 fc             	lea    -0x4(%edx),%esi
  800978:	c1 e9 02             	shr    $0x2,%ecx
  80097b:	fd                   	std    
  80097c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80097e:	eb 07                	jmp    800987 <memmove+0x42>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800980:	4f                   	dec    %edi
  800981:	8d 72 ff             	lea    -0x1(%edx),%esi
  800984:	fd                   	std    
  800985:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800987:	fc                   	cld    
  800988:	eb 1d                	jmp    8009a7 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80098a:	89 f2                	mov    %esi,%edx
  80098c:	09 c2                	or     %eax,%edx
  80098e:	f6 c2 03             	test   $0x3,%dl
  800991:	75 0f                	jne    8009a2 <memmove+0x5d>
  800993:	f6 c1 03             	test   $0x3,%cl
  800996:	75 0a                	jne    8009a2 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
  800998:	c1 e9 02             	shr    $0x2,%ecx
  80099b:	89 c7                	mov    %eax,%edi
  80099d:	fc                   	cld    
  80099e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009a0:	eb 05                	jmp    8009a7 <memmove+0x62>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009a2:	89 c7                	mov    %eax,%edi
  8009a4:	fc                   	cld    
  8009a5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009a7:	5e                   	pop    %esi
  8009a8:	5f                   	pop    %edi
  8009a9:	5d                   	pop    %ebp
  8009aa:	c3                   	ret    

008009ab <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009ab:	55                   	push   %ebp
  8009ac:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009ae:	ff 75 10             	pushl  0x10(%ebp)
  8009b1:	ff 75 0c             	pushl  0xc(%ebp)
  8009b4:	ff 75 08             	pushl  0x8(%ebp)
  8009b7:	e8 89 ff ff ff       	call   800945 <memmove>
}
  8009bc:	c9                   	leave  
  8009bd:	c3                   	ret    

008009be <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009be:	55                   	push   %ebp
  8009bf:	89 e5                	mov    %esp,%ebp
  8009c1:	57                   	push   %edi
  8009c2:	56                   	push   %esi
  8009c3:	53                   	push   %ebx
  8009c4:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8009c7:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009ca:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009cd:	85 c0                	test   %eax,%eax
  8009cf:	74 33                	je     800a04 <memcmp+0x46>
  8009d1:	8d 78 ff             	lea    -0x1(%eax),%edi
		if (*s1 != *s2)
  8009d4:	8a 13                	mov    (%ebx),%dl
  8009d6:	8a 0e                	mov    (%esi),%cl
  8009d8:	38 ca                	cmp    %cl,%dl
  8009da:	75 13                	jne    8009ef <memcmp+0x31>
  8009dc:	b8 00 00 00 00       	mov    $0x0,%eax
  8009e1:	eb 16                	jmp    8009f9 <memcmp+0x3b>
  8009e3:	8a 54 03 01          	mov    0x1(%ebx,%eax,1),%dl
  8009e7:	40                   	inc    %eax
  8009e8:	8a 0c 06             	mov    (%esi,%eax,1),%cl
  8009eb:	38 ca                	cmp    %cl,%dl
  8009ed:	74 0a                	je     8009f9 <memcmp+0x3b>
			return (int) *s1 - (int) *s2;
  8009ef:	0f b6 c2             	movzbl %dl,%eax
  8009f2:	0f b6 c9             	movzbl %cl,%ecx
  8009f5:	29 c8                	sub    %ecx,%eax
  8009f7:	eb 10                	jmp    800a09 <memcmp+0x4b>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009f9:	39 f8                	cmp    %edi,%eax
  8009fb:	75 e6                	jne    8009e3 <memcmp+0x25>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009fd:	b8 00 00 00 00       	mov    $0x0,%eax
  800a02:	eb 05                	jmp    800a09 <memcmp+0x4b>
  800a04:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a09:	5b                   	pop    %ebx
  800a0a:	5e                   	pop    %esi
  800a0b:	5f                   	pop    %edi
  800a0c:	5d                   	pop    %ebp
  800a0d:	c3                   	ret    

00800a0e <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a0e:	55                   	push   %ebp
  800a0f:	89 e5                	mov    %esp,%ebp
  800a11:	53                   	push   %ebx
  800a12:	8b 55 08             	mov    0x8(%ebp),%edx
	const void *ends = (const char *) s + n;
  800a15:	89 d0                	mov    %edx,%eax
  800a17:	03 45 10             	add    0x10(%ebp),%eax
	for (; s < ends; s++)
  800a1a:	39 c2                	cmp    %eax,%edx
  800a1c:	73 1b                	jae    800a39 <memfind+0x2b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a1e:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
  800a22:	0f b6 0a             	movzbl (%edx),%ecx
  800a25:	39 d9                	cmp    %ebx,%ecx
  800a27:	75 09                	jne    800a32 <memfind+0x24>
  800a29:	eb 12                	jmp    800a3d <memfind+0x2f>
  800a2b:	0f b6 0a             	movzbl (%edx),%ecx
  800a2e:	39 d9                	cmp    %ebx,%ecx
  800a30:	74 0f                	je     800a41 <memfind+0x33>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a32:	42                   	inc    %edx
  800a33:	39 d0                	cmp    %edx,%eax
  800a35:	75 f4                	jne    800a2b <memfind+0x1d>
  800a37:	eb 0a                	jmp    800a43 <memfind+0x35>
  800a39:	89 d0                	mov    %edx,%eax
  800a3b:	eb 06                	jmp    800a43 <memfind+0x35>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a3d:	89 d0                	mov    %edx,%eax
  800a3f:	eb 02                	jmp    800a43 <memfind+0x35>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a41:	89 d0                	mov    %edx,%eax
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a43:	5b                   	pop    %ebx
  800a44:	5d                   	pop    %ebp
  800a45:	c3                   	ret    

00800a46 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a46:	55                   	push   %ebp
  800a47:	89 e5                	mov    %esp,%ebp
  800a49:	57                   	push   %edi
  800a4a:	56                   	push   %esi
  800a4b:	53                   	push   %ebx
  800a4c:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a4f:	eb 01                	jmp    800a52 <strtol+0xc>
		s++;
  800a51:	41                   	inc    %ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a52:	8a 01                	mov    (%ecx),%al
  800a54:	3c 20                	cmp    $0x20,%al
  800a56:	74 f9                	je     800a51 <strtol+0xb>
  800a58:	3c 09                	cmp    $0x9,%al
  800a5a:	74 f5                	je     800a51 <strtol+0xb>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a5c:	3c 2b                	cmp    $0x2b,%al
  800a5e:	75 08                	jne    800a68 <strtol+0x22>
		s++;
  800a60:	41                   	inc    %ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a61:	bf 00 00 00 00       	mov    $0x0,%edi
  800a66:	eb 11                	jmp    800a79 <strtol+0x33>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a68:	3c 2d                	cmp    $0x2d,%al
  800a6a:	75 08                	jne    800a74 <strtol+0x2e>
		s++, neg = 1;
  800a6c:	41                   	inc    %ecx
  800a6d:	bf 01 00 00 00       	mov    $0x1,%edi
  800a72:	eb 05                	jmp    800a79 <strtol+0x33>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a74:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a79:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800a7d:	0f 84 87 00 00 00    	je     800b0a <strtol+0xc4>
  800a83:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  800a87:	75 27                	jne    800ab0 <strtol+0x6a>
  800a89:	80 39 30             	cmpb   $0x30,(%ecx)
  800a8c:	75 22                	jne    800ab0 <strtol+0x6a>
  800a8e:	e9 88 00 00 00       	jmp    800b1b <strtol+0xd5>
		s += 2, base = 16;
  800a93:	83 c1 02             	add    $0x2,%ecx
  800a96:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  800a9d:	eb 11                	jmp    800ab0 <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
  800a9f:	41                   	inc    %ecx
  800aa0:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  800aa7:	eb 07                	jmp    800ab0 <strtol+0x6a>
	else if (base == 0)
		base = 10;
  800aa9:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)
  800ab0:	b8 00 00 00 00       	mov    $0x0,%eax

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ab5:	8a 11                	mov    (%ecx),%dl
  800ab7:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800aba:	80 fb 09             	cmp    $0x9,%bl
  800abd:	77 08                	ja     800ac7 <strtol+0x81>
			dig = *s - '0';
  800abf:	0f be d2             	movsbl %dl,%edx
  800ac2:	83 ea 30             	sub    $0x30,%edx
  800ac5:	eb 22                	jmp    800ae9 <strtol+0xa3>
		else if (*s >= 'a' && *s <= 'z')
  800ac7:	8d 72 9f             	lea    -0x61(%edx),%esi
  800aca:	89 f3                	mov    %esi,%ebx
  800acc:	80 fb 19             	cmp    $0x19,%bl
  800acf:	77 08                	ja     800ad9 <strtol+0x93>
			dig = *s - 'a' + 10;
  800ad1:	0f be d2             	movsbl %dl,%edx
  800ad4:	83 ea 57             	sub    $0x57,%edx
  800ad7:	eb 10                	jmp    800ae9 <strtol+0xa3>
		else if (*s >= 'A' && *s <= 'Z')
  800ad9:	8d 72 bf             	lea    -0x41(%edx),%esi
  800adc:	89 f3                	mov    %esi,%ebx
  800ade:	80 fb 19             	cmp    $0x19,%bl
  800ae1:	77 14                	ja     800af7 <strtol+0xb1>
			dig = *s - 'A' + 10;
  800ae3:	0f be d2             	movsbl %dl,%edx
  800ae6:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800ae9:	3b 55 10             	cmp    0x10(%ebp),%edx
  800aec:	7d 09                	jge    800af7 <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800aee:	41                   	inc    %ecx
  800aef:	0f af 45 10          	imul   0x10(%ebp),%eax
  800af3:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800af5:	eb be                	jmp    800ab5 <strtol+0x6f>

	if (endptr)
  800af7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800afb:	74 05                	je     800b02 <strtol+0xbc>
		*endptr = (char *) s;
  800afd:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b00:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800b02:	85 ff                	test   %edi,%edi
  800b04:	74 21                	je     800b27 <strtol+0xe1>
  800b06:	f7 d8                	neg    %eax
  800b08:	eb 1d                	jmp    800b27 <strtol+0xe1>
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b0a:	80 39 30             	cmpb   $0x30,(%ecx)
  800b0d:	75 9a                	jne    800aa9 <strtol+0x63>
  800b0f:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b13:	0f 84 7a ff ff ff    	je     800a93 <strtol+0x4d>
  800b19:	eb 84                	jmp    800a9f <strtol+0x59>
  800b1b:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b1f:	0f 84 6e ff ff ff    	je     800a93 <strtol+0x4d>
  800b25:	eb 89                	jmp    800ab0 <strtol+0x6a>
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
}
  800b27:	5b                   	pop    %ebx
  800b28:	5e                   	pop    %esi
  800b29:	5f                   	pop    %edi
  800b2a:	5d                   	pop    %ebp
  800b2b:	c3                   	ret    

00800b2c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b2c:	55                   	push   %ebp
  800b2d:	89 e5                	mov    %esp,%ebp
  800b2f:	57                   	push   %edi
  800b30:	56                   	push   %esi
  800b31:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b32:	b8 00 00 00 00       	mov    $0x0,%eax
  800b37:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b3a:	8b 55 08             	mov    0x8(%ebp),%edx
  800b3d:	89 c3                	mov    %eax,%ebx
  800b3f:	89 c7                	mov    %eax,%edi
  800b41:	89 c6                	mov    %eax,%esi
  800b43:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b45:	5b                   	pop    %ebx
  800b46:	5e                   	pop    %esi
  800b47:	5f                   	pop    %edi
  800b48:	5d                   	pop    %ebp
  800b49:	c3                   	ret    

00800b4a <sys_cgetc>:

int
sys_cgetc(void)
{
  800b4a:	55                   	push   %ebp
  800b4b:	89 e5                	mov    %esp,%ebp
  800b4d:	57                   	push   %edi
  800b4e:	56                   	push   %esi
  800b4f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b50:	ba 00 00 00 00       	mov    $0x0,%edx
  800b55:	b8 01 00 00 00       	mov    $0x1,%eax
  800b5a:	89 d1                	mov    %edx,%ecx
  800b5c:	89 d3                	mov    %edx,%ebx
  800b5e:	89 d7                	mov    %edx,%edi
  800b60:	89 d6                	mov    %edx,%esi
  800b62:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b64:	5b                   	pop    %ebx
  800b65:	5e                   	pop    %esi
  800b66:	5f                   	pop    %edi
  800b67:	5d                   	pop    %ebp
  800b68:	c3                   	ret    

00800b69 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b69:	55                   	push   %ebp
  800b6a:	89 e5                	mov    %esp,%ebp
  800b6c:	57                   	push   %edi
  800b6d:	56                   	push   %esi
  800b6e:	53                   	push   %ebx
  800b6f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b72:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b77:	b8 03 00 00 00       	mov    $0x3,%eax
  800b7c:	8b 55 08             	mov    0x8(%ebp),%edx
  800b7f:	89 cb                	mov    %ecx,%ebx
  800b81:	89 cf                	mov    %ecx,%edi
  800b83:	89 ce                	mov    %ecx,%esi
  800b85:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b87:	85 c0                	test   %eax,%eax
  800b89:	7e 17                	jle    800ba2 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b8b:	83 ec 0c             	sub    $0xc,%esp
  800b8e:	50                   	push   %eax
  800b8f:	6a 03                	push   $0x3
  800b91:	68 1f 22 80 00       	push   $0x80221f
  800b96:	6a 23                	push   $0x23
  800b98:	68 3c 22 80 00       	push   $0x80223c
  800b9d:	e8 cf 0e 00 00       	call   801a71 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ba2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ba5:	5b                   	pop    %ebx
  800ba6:	5e                   	pop    %esi
  800ba7:	5f                   	pop    %edi
  800ba8:	5d                   	pop    %ebp
  800ba9:	c3                   	ret    

00800baa <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800baa:	55                   	push   %ebp
  800bab:	89 e5                	mov    %esp,%ebp
  800bad:	57                   	push   %edi
  800bae:	56                   	push   %esi
  800baf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bb0:	ba 00 00 00 00       	mov    $0x0,%edx
  800bb5:	b8 02 00 00 00       	mov    $0x2,%eax
  800bba:	89 d1                	mov    %edx,%ecx
  800bbc:	89 d3                	mov    %edx,%ebx
  800bbe:	89 d7                	mov    %edx,%edi
  800bc0:	89 d6                	mov    %edx,%esi
  800bc2:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bc4:	5b                   	pop    %ebx
  800bc5:	5e                   	pop    %esi
  800bc6:	5f                   	pop    %edi
  800bc7:	5d                   	pop    %ebp
  800bc8:	c3                   	ret    

00800bc9 <sys_yield>:

void
sys_yield(void)
{
  800bc9:	55                   	push   %ebp
  800bca:	89 e5                	mov    %esp,%ebp
  800bcc:	57                   	push   %edi
  800bcd:	56                   	push   %esi
  800bce:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bcf:	ba 00 00 00 00       	mov    $0x0,%edx
  800bd4:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bd9:	89 d1                	mov    %edx,%ecx
  800bdb:	89 d3                	mov    %edx,%ebx
  800bdd:	89 d7                	mov    %edx,%edi
  800bdf:	89 d6                	mov    %edx,%esi
  800be1:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800be3:	5b                   	pop    %ebx
  800be4:	5e                   	pop    %esi
  800be5:	5f                   	pop    %edi
  800be6:	5d                   	pop    %ebp
  800be7:	c3                   	ret    

00800be8 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800be8:	55                   	push   %ebp
  800be9:	89 e5                	mov    %esp,%ebp
  800beb:	57                   	push   %edi
  800bec:	56                   	push   %esi
  800bed:	53                   	push   %ebx
  800bee:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bf1:	be 00 00 00 00       	mov    $0x0,%esi
  800bf6:	b8 04 00 00 00       	mov    $0x4,%eax
  800bfb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bfe:	8b 55 08             	mov    0x8(%ebp),%edx
  800c01:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c04:	89 f7                	mov    %esi,%edi
  800c06:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c08:	85 c0                	test   %eax,%eax
  800c0a:	7e 17                	jle    800c23 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c0c:	83 ec 0c             	sub    $0xc,%esp
  800c0f:	50                   	push   %eax
  800c10:	6a 04                	push   $0x4
  800c12:	68 1f 22 80 00       	push   $0x80221f
  800c17:	6a 23                	push   $0x23
  800c19:	68 3c 22 80 00       	push   $0x80223c
  800c1e:	e8 4e 0e 00 00       	call   801a71 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c23:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c26:	5b                   	pop    %ebx
  800c27:	5e                   	pop    %esi
  800c28:	5f                   	pop    %edi
  800c29:	5d                   	pop    %ebp
  800c2a:	c3                   	ret    

00800c2b <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c2b:	55                   	push   %ebp
  800c2c:	89 e5                	mov    %esp,%ebp
  800c2e:	57                   	push   %edi
  800c2f:	56                   	push   %esi
  800c30:	53                   	push   %ebx
  800c31:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c34:	b8 05 00 00 00       	mov    $0x5,%eax
  800c39:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c3c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c3f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c42:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c45:	8b 75 18             	mov    0x18(%ebp),%esi
  800c48:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c4a:	85 c0                	test   %eax,%eax
  800c4c:	7e 17                	jle    800c65 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c4e:	83 ec 0c             	sub    $0xc,%esp
  800c51:	50                   	push   %eax
  800c52:	6a 05                	push   $0x5
  800c54:	68 1f 22 80 00       	push   $0x80221f
  800c59:	6a 23                	push   $0x23
  800c5b:	68 3c 22 80 00       	push   $0x80223c
  800c60:	e8 0c 0e 00 00       	call   801a71 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c65:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c68:	5b                   	pop    %ebx
  800c69:	5e                   	pop    %esi
  800c6a:	5f                   	pop    %edi
  800c6b:	5d                   	pop    %ebp
  800c6c:	c3                   	ret    

00800c6d <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c6d:	55                   	push   %ebp
  800c6e:	89 e5                	mov    %esp,%ebp
  800c70:	57                   	push   %edi
  800c71:	56                   	push   %esi
  800c72:	53                   	push   %ebx
  800c73:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c76:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c7b:	b8 06 00 00 00       	mov    $0x6,%eax
  800c80:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c83:	8b 55 08             	mov    0x8(%ebp),%edx
  800c86:	89 df                	mov    %ebx,%edi
  800c88:	89 de                	mov    %ebx,%esi
  800c8a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c8c:	85 c0                	test   %eax,%eax
  800c8e:	7e 17                	jle    800ca7 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c90:	83 ec 0c             	sub    $0xc,%esp
  800c93:	50                   	push   %eax
  800c94:	6a 06                	push   $0x6
  800c96:	68 1f 22 80 00       	push   $0x80221f
  800c9b:	6a 23                	push   $0x23
  800c9d:	68 3c 22 80 00       	push   $0x80223c
  800ca2:	e8 ca 0d 00 00       	call   801a71 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800ca7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800caa:	5b                   	pop    %ebx
  800cab:	5e                   	pop    %esi
  800cac:	5f                   	pop    %edi
  800cad:	5d                   	pop    %ebp
  800cae:	c3                   	ret    

00800caf <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800caf:	55                   	push   %ebp
  800cb0:	89 e5                	mov    %esp,%ebp
  800cb2:	57                   	push   %edi
  800cb3:	56                   	push   %esi
  800cb4:	53                   	push   %ebx
  800cb5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cb8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cbd:	b8 08 00 00 00       	mov    $0x8,%eax
  800cc2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc5:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc8:	89 df                	mov    %ebx,%edi
  800cca:	89 de                	mov    %ebx,%esi
  800ccc:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cce:	85 c0                	test   %eax,%eax
  800cd0:	7e 17                	jle    800ce9 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cd2:	83 ec 0c             	sub    $0xc,%esp
  800cd5:	50                   	push   %eax
  800cd6:	6a 08                	push   $0x8
  800cd8:	68 1f 22 80 00       	push   $0x80221f
  800cdd:	6a 23                	push   $0x23
  800cdf:	68 3c 22 80 00       	push   $0x80223c
  800ce4:	e8 88 0d 00 00       	call   801a71 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800ce9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cec:	5b                   	pop    %ebx
  800ced:	5e                   	pop    %esi
  800cee:	5f                   	pop    %edi
  800cef:	5d                   	pop    %ebp
  800cf0:	c3                   	ret    

00800cf1 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800cf1:	55                   	push   %ebp
  800cf2:	89 e5                	mov    %esp,%ebp
  800cf4:	57                   	push   %edi
  800cf5:	56                   	push   %esi
  800cf6:	53                   	push   %ebx
  800cf7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cfa:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cff:	b8 09 00 00 00       	mov    $0x9,%eax
  800d04:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d07:	8b 55 08             	mov    0x8(%ebp),%edx
  800d0a:	89 df                	mov    %ebx,%edi
  800d0c:	89 de                	mov    %ebx,%esi
  800d0e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d10:	85 c0                	test   %eax,%eax
  800d12:	7e 17                	jle    800d2b <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d14:	83 ec 0c             	sub    $0xc,%esp
  800d17:	50                   	push   %eax
  800d18:	6a 09                	push   $0x9
  800d1a:	68 1f 22 80 00       	push   $0x80221f
  800d1f:	6a 23                	push   $0x23
  800d21:	68 3c 22 80 00       	push   $0x80223c
  800d26:	e8 46 0d 00 00       	call   801a71 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d2b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d2e:	5b                   	pop    %ebx
  800d2f:	5e                   	pop    %esi
  800d30:	5f                   	pop    %edi
  800d31:	5d                   	pop    %ebp
  800d32:	c3                   	ret    

00800d33 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d33:	55                   	push   %ebp
  800d34:	89 e5                	mov    %esp,%ebp
  800d36:	57                   	push   %edi
  800d37:	56                   	push   %esi
  800d38:	53                   	push   %ebx
  800d39:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d3c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d41:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d46:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d49:	8b 55 08             	mov    0x8(%ebp),%edx
  800d4c:	89 df                	mov    %ebx,%edi
  800d4e:	89 de                	mov    %ebx,%esi
  800d50:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d52:	85 c0                	test   %eax,%eax
  800d54:	7e 17                	jle    800d6d <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d56:	83 ec 0c             	sub    $0xc,%esp
  800d59:	50                   	push   %eax
  800d5a:	6a 0a                	push   $0xa
  800d5c:	68 1f 22 80 00       	push   $0x80221f
  800d61:	6a 23                	push   $0x23
  800d63:	68 3c 22 80 00       	push   $0x80223c
  800d68:	e8 04 0d 00 00       	call   801a71 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d6d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d70:	5b                   	pop    %ebx
  800d71:	5e                   	pop    %esi
  800d72:	5f                   	pop    %edi
  800d73:	5d                   	pop    %ebp
  800d74:	c3                   	ret    

00800d75 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d75:	55                   	push   %ebp
  800d76:	89 e5                	mov    %esp,%ebp
  800d78:	57                   	push   %edi
  800d79:	56                   	push   %esi
  800d7a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d7b:	be 00 00 00 00       	mov    $0x0,%esi
  800d80:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d85:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d88:	8b 55 08             	mov    0x8(%ebp),%edx
  800d8b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d8e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d91:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d93:	5b                   	pop    %ebx
  800d94:	5e                   	pop    %esi
  800d95:	5f                   	pop    %edi
  800d96:	5d                   	pop    %ebp
  800d97:	c3                   	ret    

00800d98 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d98:	55                   	push   %ebp
  800d99:	89 e5                	mov    %esp,%ebp
  800d9b:	57                   	push   %edi
  800d9c:	56                   	push   %esi
  800d9d:	53                   	push   %ebx
  800d9e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800da1:	b9 00 00 00 00       	mov    $0x0,%ecx
  800da6:	b8 0d 00 00 00       	mov    $0xd,%eax
  800dab:	8b 55 08             	mov    0x8(%ebp),%edx
  800dae:	89 cb                	mov    %ecx,%ebx
  800db0:	89 cf                	mov    %ecx,%edi
  800db2:	89 ce                	mov    %ecx,%esi
  800db4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800db6:	85 c0                	test   %eax,%eax
  800db8:	7e 17                	jle    800dd1 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dba:	83 ec 0c             	sub    $0xc,%esp
  800dbd:	50                   	push   %eax
  800dbe:	6a 0d                	push   $0xd
  800dc0:	68 1f 22 80 00       	push   $0x80221f
  800dc5:	6a 23                	push   $0x23
  800dc7:	68 3c 22 80 00       	push   $0x80223c
  800dcc:	e8 a0 0c 00 00       	call   801a71 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800dd1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dd4:	5b                   	pop    %ebx
  800dd5:	5e                   	pop    %esi
  800dd6:	5f                   	pop    %edi
  800dd7:	5d                   	pop    %ebp
  800dd8:	c3                   	ret    

00800dd9 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800dd9:	55                   	push   %ebp
  800dda:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800ddc:	8b 45 08             	mov    0x8(%ebp),%eax
  800ddf:	05 00 00 00 30       	add    $0x30000000,%eax
  800de4:	c1 e8 0c             	shr    $0xc,%eax
}
  800de7:	5d                   	pop    %ebp
  800de8:	c3                   	ret    

00800de9 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800de9:	55                   	push   %ebp
  800dea:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800dec:	8b 45 08             	mov    0x8(%ebp),%eax
  800def:	05 00 00 00 30       	add    $0x30000000,%eax
  800df4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800df9:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800dfe:	5d                   	pop    %ebp
  800dff:	c3                   	ret    

00800e00 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e00:	55                   	push   %ebp
  800e01:	89 e5                	mov    %esp,%ebp
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e03:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  800e08:	a8 01                	test   $0x1,%al
  800e0a:	74 34                	je     800e40 <fd_alloc+0x40>
  800e0c:	a1 00 00 74 ef       	mov    0xef740000,%eax
  800e11:	a8 01                	test   $0x1,%al
  800e13:	74 32                	je     800e47 <fd_alloc+0x47>
  800e15:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800e1a:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e1c:	89 c2                	mov    %eax,%edx
  800e1e:	c1 ea 16             	shr    $0x16,%edx
  800e21:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e28:	f6 c2 01             	test   $0x1,%dl
  800e2b:	74 1f                	je     800e4c <fd_alloc+0x4c>
  800e2d:	89 c2                	mov    %eax,%edx
  800e2f:	c1 ea 0c             	shr    $0xc,%edx
  800e32:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e39:	f6 c2 01             	test   $0x1,%dl
  800e3c:	75 1a                	jne    800e58 <fd_alloc+0x58>
  800e3e:	eb 0c                	jmp    800e4c <fd_alloc+0x4c>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800e40:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  800e45:	eb 05                	jmp    800e4c <fd_alloc+0x4c>
  800e47:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  800e4c:	8b 45 08             	mov    0x8(%ebp),%eax
  800e4f:	89 08                	mov    %ecx,(%eax)
			return 0;
  800e51:	b8 00 00 00 00       	mov    $0x0,%eax
  800e56:	eb 1a                	jmp    800e72 <fd_alloc+0x72>
  800e58:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800e5d:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e62:	75 b6                	jne    800e1a <fd_alloc+0x1a>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800e64:	8b 45 08             	mov    0x8(%ebp),%eax
  800e67:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  800e6d:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800e72:	5d                   	pop    %ebp
  800e73:	c3                   	ret    

00800e74 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e74:	55                   	push   %ebp
  800e75:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e77:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
  800e7b:	77 39                	ja     800eb6 <fd_lookup+0x42>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e7d:	8b 45 08             	mov    0x8(%ebp),%eax
  800e80:	c1 e0 0c             	shl    $0xc,%eax
  800e83:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e88:	89 c2                	mov    %eax,%edx
  800e8a:	c1 ea 16             	shr    $0x16,%edx
  800e8d:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e94:	f6 c2 01             	test   $0x1,%dl
  800e97:	74 24                	je     800ebd <fd_lookup+0x49>
  800e99:	89 c2                	mov    %eax,%edx
  800e9b:	c1 ea 0c             	shr    $0xc,%edx
  800e9e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ea5:	f6 c2 01             	test   $0x1,%dl
  800ea8:	74 1a                	je     800ec4 <fd_lookup+0x50>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800eaa:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ead:	89 02                	mov    %eax,(%edx)
	return 0;
  800eaf:	b8 00 00 00 00       	mov    $0x0,%eax
  800eb4:	eb 13                	jmp    800ec9 <fd_lookup+0x55>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800eb6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ebb:	eb 0c                	jmp    800ec9 <fd_lookup+0x55>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800ebd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ec2:	eb 05                	jmp    800ec9 <fd_lookup+0x55>
  800ec4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800ec9:	5d                   	pop    %ebp
  800eca:	c3                   	ret    

00800ecb <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800ecb:	55                   	push   %ebp
  800ecc:	89 e5                	mov    %esp,%ebp
  800ece:	53                   	push   %ebx
  800ecf:	83 ec 04             	sub    $0x4,%esp
  800ed2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ed5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  800ed8:	3b 05 04 30 80 00    	cmp    0x803004,%eax
  800ede:	75 1e                	jne    800efe <dev_lookup+0x33>
  800ee0:	eb 0e                	jmp    800ef0 <dev_lookup+0x25>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800ee2:	b8 20 30 80 00       	mov    $0x803020,%eax
  800ee7:	eb 0c                	jmp    800ef5 <dev_lookup+0x2a>
  800ee9:	b8 3c 30 80 00       	mov    $0x80303c,%eax
  800eee:	eb 05                	jmp    800ef5 <dev_lookup+0x2a>
  800ef0:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  800ef5:	89 03                	mov    %eax,(%ebx)
			return 0;
  800ef7:	b8 00 00 00 00       	mov    $0x0,%eax
  800efc:	eb 36                	jmp    800f34 <dev_lookup+0x69>
int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  800efe:	3b 05 20 30 80 00    	cmp    0x803020,%eax
  800f04:	74 dc                	je     800ee2 <dev_lookup+0x17>
  800f06:	3b 05 3c 30 80 00    	cmp    0x80303c,%eax
  800f0c:	74 db                	je     800ee9 <dev_lookup+0x1e>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f0e:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800f14:	8b 52 48             	mov    0x48(%edx),%edx
  800f17:	83 ec 04             	sub    $0x4,%esp
  800f1a:	50                   	push   %eax
  800f1b:	52                   	push   %edx
  800f1c:	68 4c 22 80 00       	push   $0x80224c
  800f21:	e8 6d f2 ff ff       	call   800193 <cprintf>
	*dev = 0;
  800f26:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  800f2c:	83 c4 10             	add    $0x10,%esp
  800f2f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f34:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f37:	c9                   	leave  
  800f38:	c3                   	ret    

00800f39 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800f39:	55                   	push   %ebp
  800f3a:	89 e5                	mov    %esp,%ebp
  800f3c:	56                   	push   %esi
  800f3d:	53                   	push   %ebx
  800f3e:	83 ec 10             	sub    $0x10,%esp
  800f41:	8b 75 08             	mov    0x8(%ebp),%esi
  800f44:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f47:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f4a:	50                   	push   %eax
  800f4b:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800f51:	c1 e8 0c             	shr    $0xc,%eax
  800f54:	50                   	push   %eax
  800f55:	e8 1a ff ff ff       	call   800e74 <fd_lookup>
  800f5a:	83 c4 08             	add    $0x8,%esp
  800f5d:	85 c0                	test   %eax,%eax
  800f5f:	78 05                	js     800f66 <fd_close+0x2d>
	    || fd != fd2)
  800f61:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800f64:	74 06                	je     800f6c <fd_close+0x33>
		return (must_exist ? r : 0);
  800f66:	84 db                	test   %bl,%bl
  800f68:	74 47                	je     800fb1 <fd_close+0x78>
  800f6a:	eb 4a                	jmp    800fb6 <fd_close+0x7d>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f6c:	83 ec 08             	sub    $0x8,%esp
  800f6f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800f72:	50                   	push   %eax
  800f73:	ff 36                	pushl  (%esi)
  800f75:	e8 51 ff ff ff       	call   800ecb <dev_lookup>
  800f7a:	89 c3                	mov    %eax,%ebx
  800f7c:	83 c4 10             	add    $0x10,%esp
  800f7f:	85 c0                	test   %eax,%eax
  800f81:	78 1c                	js     800f9f <fd_close+0x66>
		if (dev->dev_close)
  800f83:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f86:	8b 40 10             	mov    0x10(%eax),%eax
  800f89:	85 c0                	test   %eax,%eax
  800f8b:	74 0d                	je     800f9a <fd_close+0x61>
			r = (*dev->dev_close)(fd);
  800f8d:	83 ec 0c             	sub    $0xc,%esp
  800f90:	56                   	push   %esi
  800f91:	ff d0                	call   *%eax
  800f93:	89 c3                	mov    %eax,%ebx
  800f95:	83 c4 10             	add    $0x10,%esp
  800f98:	eb 05                	jmp    800f9f <fd_close+0x66>
		else
			r = 0;
  800f9a:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800f9f:	83 ec 08             	sub    $0x8,%esp
  800fa2:	56                   	push   %esi
  800fa3:	6a 00                	push   $0x0
  800fa5:	e8 c3 fc ff ff       	call   800c6d <sys_page_unmap>
	return r;
  800faa:	83 c4 10             	add    $0x10,%esp
  800fad:	89 d8                	mov    %ebx,%eax
  800faf:	eb 05                	jmp    800fb6 <fd_close+0x7d>
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
  800fb1:	b8 00 00 00 00       	mov    $0x0,%eax
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
	return r;
}
  800fb6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fb9:	5b                   	pop    %ebx
  800fba:	5e                   	pop    %esi
  800fbb:	5d                   	pop    %ebp
  800fbc:	c3                   	ret    

00800fbd <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800fbd:	55                   	push   %ebp
  800fbe:	89 e5                	mov    %esp,%ebp
  800fc0:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fc3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fc6:	50                   	push   %eax
  800fc7:	ff 75 08             	pushl  0x8(%ebp)
  800fca:	e8 a5 fe ff ff       	call   800e74 <fd_lookup>
  800fcf:	83 c4 08             	add    $0x8,%esp
  800fd2:	85 c0                	test   %eax,%eax
  800fd4:	78 10                	js     800fe6 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800fd6:	83 ec 08             	sub    $0x8,%esp
  800fd9:	6a 01                	push   $0x1
  800fdb:	ff 75 f4             	pushl  -0xc(%ebp)
  800fde:	e8 56 ff ff ff       	call   800f39 <fd_close>
  800fe3:	83 c4 10             	add    $0x10,%esp
}
  800fe6:	c9                   	leave  
  800fe7:	c3                   	ret    

00800fe8 <close_all>:

void
close_all(void)
{
  800fe8:	55                   	push   %ebp
  800fe9:	89 e5                	mov    %esp,%ebp
  800feb:	53                   	push   %ebx
  800fec:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800fef:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800ff4:	83 ec 0c             	sub    $0xc,%esp
  800ff7:	53                   	push   %ebx
  800ff8:	e8 c0 ff ff ff       	call   800fbd <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800ffd:	43                   	inc    %ebx
  800ffe:	83 c4 10             	add    $0x10,%esp
  801001:	83 fb 20             	cmp    $0x20,%ebx
  801004:	75 ee                	jne    800ff4 <close_all+0xc>
		close(i);
}
  801006:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801009:	c9                   	leave  
  80100a:	c3                   	ret    

0080100b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80100b:	55                   	push   %ebp
  80100c:	89 e5                	mov    %esp,%ebp
  80100e:	57                   	push   %edi
  80100f:	56                   	push   %esi
  801010:	53                   	push   %ebx
  801011:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801014:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801017:	50                   	push   %eax
  801018:	ff 75 08             	pushl  0x8(%ebp)
  80101b:	e8 54 fe ff ff       	call   800e74 <fd_lookup>
  801020:	83 c4 08             	add    $0x8,%esp
  801023:	85 c0                	test   %eax,%eax
  801025:	0f 88 c2 00 00 00    	js     8010ed <dup+0xe2>
		return r;
	close(newfdnum);
  80102b:	83 ec 0c             	sub    $0xc,%esp
  80102e:	ff 75 0c             	pushl  0xc(%ebp)
  801031:	e8 87 ff ff ff       	call   800fbd <close>

	newfd = INDEX2FD(newfdnum);
  801036:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801039:	c1 e3 0c             	shl    $0xc,%ebx
  80103c:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801042:	83 c4 04             	add    $0x4,%esp
  801045:	ff 75 e4             	pushl  -0x1c(%ebp)
  801048:	e8 9c fd ff ff       	call   800de9 <fd2data>
  80104d:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  80104f:	89 1c 24             	mov    %ebx,(%esp)
  801052:	e8 92 fd ff ff       	call   800de9 <fd2data>
  801057:	83 c4 10             	add    $0x10,%esp
  80105a:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80105c:	89 f0                	mov    %esi,%eax
  80105e:	c1 e8 16             	shr    $0x16,%eax
  801061:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801068:	a8 01                	test   $0x1,%al
  80106a:	74 35                	je     8010a1 <dup+0x96>
  80106c:	89 f0                	mov    %esi,%eax
  80106e:	c1 e8 0c             	shr    $0xc,%eax
  801071:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801078:	f6 c2 01             	test   $0x1,%dl
  80107b:	74 24                	je     8010a1 <dup+0x96>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80107d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801084:	83 ec 0c             	sub    $0xc,%esp
  801087:	25 07 0e 00 00       	and    $0xe07,%eax
  80108c:	50                   	push   %eax
  80108d:	57                   	push   %edi
  80108e:	6a 00                	push   $0x0
  801090:	56                   	push   %esi
  801091:	6a 00                	push   $0x0
  801093:	e8 93 fb ff ff       	call   800c2b <sys_page_map>
  801098:	89 c6                	mov    %eax,%esi
  80109a:	83 c4 20             	add    $0x20,%esp
  80109d:	85 c0                	test   %eax,%eax
  80109f:	78 2c                	js     8010cd <dup+0xc2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010a1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8010a4:	89 d0                	mov    %edx,%eax
  8010a6:	c1 e8 0c             	shr    $0xc,%eax
  8010a9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010b0:	83 ec 0c             	sub    $0xc,%esp
  8010b3:	25 07 0e 00 00       	and    $0xe07,%eax
  8010b8:	50                   	push   %eax
  8010b9:	53                   	push   %ebx
  8010ba:	6a 00                	push   $0x0
  8010bc:	52                   	push   %edx
  8010bd:	6a 00                	push   $0x0
  8010bf:	e8 67 fb ff ff       	call   800c2b <sys_page_map>
  8010c4:	89 c6                	mov    %eax,%esi
  8010c6:	83 c4 20             	add    $0x20,%esp
  8010c9:	85 c0                	test   %eax,%eax
  8010cb:	79 1d                	jns    8010ea <dup+0xdf>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8010cd:	83 ec 08             	sub    $0x8,%esp
  8010d0:	53                   	push   %ebx
  8010d1:	6a 00                	push   $0x0
  8010d3:	e8 95 fb ff ff       	call   800c6d <sys_page_unmap>
	sys_page_unmap(0, nva);
  8010d8:	83 c4 08             	add    $0x8,%esp
  8010db:	57                   	push   %edi
  8010dc:	6a 00                	push   $0x0
  8010de:	e8 8a fb ff ff       	call   800c6d <sys_page_unmap>
	return r;
  8010e3:	83 c4 10             	add    $0x10,%esp
  8010e6:	89 f0                	mov    %esi,%eax
  8010e8:	eb 03                	jmp    8010ed <dup+0xe2>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  8010ea:	8b 45 0c             	mov    0xc(%ebp),%eax

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8010ed:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010f0:	5b                   	pop    %ebx
  8010f1:	5e                   	pop    %esi
  8010f2:	5f                   	pop    %edi
  8010f3:	5d                   	pop    %ebp
  8010f4:	c3                   	ret    

008010f5 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8010f5:	55                   	push   %ebp
  8010f6:	89 e5                	mov    %esp,%ebp
  8010f8:	53                   	push   %ebx
  8010f9:	83 ec 14             	sub    $0x14,%esp
  8010fc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010ff:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801102:	50                   	push   %eax
  801103:	53                   	push   %ebx
  801104:	e8 6b fd ff ff       	call   800e74 <fd_lookup>
  801109:	83 c4 08             	add    $0x8,%esp
  80110c:	85 c0                	test   %eax,%eax
  80110e:	78 67                	js     801177 <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801110:	83 ec 08             	sub    $0x8,%esp
  801113:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801116:	50                   	push   %eax
  801117:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80111a:	ff 30                	pushl  (%eax)
  80111c:	e8 aa fd ff ff       	call   800ecb <dev_lookup>
  801121:	83 c4 10             	add    $0x10,%esp
  801124:	85 c0                	test   %eax,%eax
  801126:	78 4f                	js     801177 <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801128:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80112b:	8b 42 08             	mov    0x8(%edx),%eax
  80112e:	83 e0 03             	and    $0x3,%eax
  801131:	83 f8 01             	cmp    $0x1,%eax
  801134:	75 21                	jne    801157 <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801136:	a1 04 40 80 00       	mov    0x804004,%eax
  80113b:	8b 40 48             	mov    0x48(%eax),%eax
  80113e:	83 ec 04             	sub    $0x4,%esp
  801141:	53                   	push   %ebx
  801142:	50                   	push   %eax
  801143:	68 8d 22 80 00       	push   $0x80228d
  801148:	e8 46 f0 ff ff       	call   800193 <cprintf>
		return -E_INVAL;
  80114d:	83 c4 10             	add    $0x10,%esp
  801150:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801155:	eb 20                	jmp    801177 <read+0x82>
	}
	if (!dev->dev_read)
  801157:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80115a:	8b 40 08             	mov    0x8(%eax),%eax
  80115d:	85 c0                	test   %eax,%eax
  80115f:	74 11                	je     801172 <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801161:	83 ec 04             	sub    $0x4,%esp
  801164:	ff 75 10             	pushl  0x10(%ebp)
  801167:	ff 75 0c             	pushl  0xc(%ebp)
  80116a:	52                   	push   %edx
  80116b:	ff d0                	call   *%eax
  80116d:	83 c4 10             	add    $0x10,%esp
  801170:	eb 05                	jmp    801177 <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801172:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801177:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80117a:	c9                   	leave  
  80117b:	c3                   	ret    

0080117c <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80117c:	55                   	push   %ebp
  80117d:	89 e5                	mov    %esp,%ebp
  80117f:	57                   	push   %edi
  801180:	56                   	push   %esi
  801181:	53                   	push   %ebx
  801182:	83 ec 0c             	sub    $0xc,%esp
  801185:	8b 7d 08             	mov    0x8(%ebp),%edi
  801188:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80118b:	85 f6                	test   %esi,%esi
  80118d:	74 31                	je     8011c0 <readn+0x44>
  80118f:	b8 00 00 00 00       	mov    $0x0,%eax
  801194:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  801199:	83 ec 04             	sub    $0x4,%esp
  80119c:	89 f2                	mov    %esi,%edx
  80119e:	29 c2                	sub    %eax,%edx
  8011a0:	52                   	push   %edx
  8011a1:	03 45 0c             	add    0xc(%ebp),%eax
  8011a4:	50                   	push   %eax
  8011a5:	57                   	push   %edi
  8011a6:	e8 4a ff ff ff       	call   8010f5 <read>
		if (m < 0)
  8011ab:	83 c4 10             	add    $0x10,%esp
  8011ae:	85 c0                	test   %eax,%eax
  8011b0:	78 17                	js     8011c9 <readn+0x4d>
			return m;
		if (m == 0)
  8011b2:	85 c0                	test   %eax,%eax
  8011b4:	74 11                	je     8011c7 <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011b6:	01 c3                	add    %eax,%ebx
  8011b8:	89 d8                	mov    %ebx,%eax
  8011ba:	39 f3                	cmp    %esi,%ebx
  8011bc:	72 db                	jb     801199 <readn+0x1d>
  8011be:	eb 09                	jmp    8011c9 <readn+0x4d>
  8011c0:	b8 00 00 00 00       	mov    $0x0,%eax
  8011c5:	eb 02                	jmp    8011c9 <readn+0x4d>
  8011c7:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8011c9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011cc:	5b                   	pop    %ebx
  8011cd:	5e                   	pop    %esi
  8011ce:	5f                   	pop    %edi
  8011cf:	5d                   	pop    %ebp
  8011d0:	c3                   	ret    

008011d1 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8011d1:	55                   	push   %ebp
  8011d2:	89 e5                	mov    %esp,%ebp
  8011d4:	53                   	push   %ebx
  8011d5:	83 ec 14             	sub    $0x14,%esp
  8011d8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011db:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011de:	50                   	push   %eax
  8011df:	53                   	push   %ebx
  8011e0:	e8 8f fc ff ff       	call   800e74 <fd_lookup>
  8011e5:	83 c4 08             	add    $0x8,%esp
  8011e8:	85 c0                	test   %eax,%eax
  8011ea:	78 62                	js     80124e <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011ec:	83 ec 08             	sub    $0x8,%esp
  8011ef:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011f2:	50                   	push   %eax
  8011f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011f6:	ff 30                	pushl  (%eax)
  8011f8:	e8 ce fc ff ff       	call   800ecb <dev_lookup>
  8011fd:	83 c4 10             	add    $0x10,%esp
  801200:	85 c0                	test   %eax,%eax
  801202:	78 4a                	js     80124e <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801204:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801207:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80120b:	75 21                	jne    80122e <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80120d:	a1 04 40 80 00       	mov    0x804004,%eax
  801212:	8b 40 48             	mov    0x48(%eax),%eax
  801215:	83 ec 04             	sub    $0x4,%esp
  801218:	53                   	push   %ebx
  801219:	50                   	push   %eax
  80121a:	68 a9 22 80 00       	push   $0x8022a9
  80121f:	e8 6f ef ff ff       	call   800193 <cprintf>
		return -E_INVAL;
  801224:	83 c4 10             	add    $0x10,%esp
  801227:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80122c:	eb 20                	jmp    80124e <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80122e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801231:	8b 52 0c             	mov    0xc(%edx),%edx
  801234:	85 d2                	test   %edx,%edx
  801236:	74 11                	je     801249 <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801238:	83 ec 04             	sub    $0x4,%esp
  80123b:	ff 75 10             	pushl  0x10(%ebp)
  80123e:	ff 75 0c             	pushl  0xc(%ebp)
  801241:	50                   	push   %eax
  801242:	ff d2                	call   *%edx
  801244:	83 c4 10             	add    $0x10,%esp
  801247:	eb 05                	jmp    80124e <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801249:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  80124e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801251:	c9                   	leave  
  801252:	c3                   	ret    

00801253 <seek>:

int
seek(int fdnum, off_t offset)
{
  801253:	55                   	push   %ebp
  801254:	89 e5                	mov    %esp,%ebp
  801256:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801259:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80125c:	50                   	push   %eax
  80125d:	ff 75 08             	pushl  0x8(%ebp)
  801260:	e8 0f fc ff ff       	call   800e74 <fd_lookup>
  801265:	83 c4 08             	add    $0x8,%esp
  801268:	85 c0                	test   %eax,%eax
  80126a:	78 0e                	js     80127a <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80126c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80126f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801272:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801275:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80127a:	c9                   	leave  
  80127b:	c3                   	ret    

0080127c <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80127c:	55                   	push   %ebp
  80127d:	89 e5                	mov    %esp,%ebp
  80127f:	53                   	push   %ebx
  801280:	83 ec 14             	sub    $0x14,%esp
  801283:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801286:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801289:	50                   	push   %eax
  80128a:	53                   	push   %ebx
  80128b:	e8 e4 fb ff ff       	call   800e74 <fd_lookup>
  801290:	83 c4 08             	add    $0x8,%esp
  801293:	85 c0                	test   %eax,%eax
  801295:	78 5f                	js     8012f6 <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801297:	83 ec 08             	sub    $0x8,%esp
  80129a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80129d:	50                   	push   %eax
  80129e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012a1:	ff 30                	pushl  (%eax)
  8012a3:	e8 23 fc ff ff       	call   800ecb <dev_lookup>
  8012a8:	83 c4 10             	add    $0x10,%esp
  8012ab:	85 c0                	test   %eax,%eax
  8012ad:	78 47                	js     8012f6 <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012af:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012b2:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012b6:	75 21                	jne    8012d9 <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8012b8:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8012bd:	8b 40 48             	mov    0x48(%eax),%eax
  8012c0:	83 ec 04             	sub    $0x4,%esp
  8012c3:	53                   	push   %ebx
  8012c4:	50                   	push   %eax
  8012c5:	68 6c 22 80 00       	push   $0x80226c
  8012ca:	e8 c4 ee ff ff       	call   800193 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8012cf:	83 c4 10             	add    $0x10,%esp
  8012d2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012d7:	eb 1d                	jmp    8012f6 <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  8012d9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012dc:	8b 52 18             	mov    0x18(%edx),%edx
  8012df:	85 d2                	test   %edx,%edx
  8012e1:	74 0e                	je     8012f1 <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8012e3:	83 ec 08             	sub    $0x8,%esp
  8012e6:	ff 75 0c             	pushl  0xc(%ebp)
  8012e9:	50                   	push   %eax
  8012ea:	ff d2                	call   *%edx
  8012ec:	83 c4 10             	add    $0x10,%esp
  8012ef:	eb 05                	jmp    8012f6 <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8012f1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8012f6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012f9:	c9                   	leave  
  8012fa:	c3                   	ret    

008012fb <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8012fb:	55                   	push   %ebp
  8012fc:	89 e5                	mov    %esp,%ebp
  8012fe:	53                   	push   %ebx
  8012ff:	83 ec 14             	sub    $0x14,%esp
  801302:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801305:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801308:	50                   	push   %eax
  801309:	ff 75 08             	pushl  0x8(%ebp)
  80130c:	e8 63 fb ff ff       	call   800e74 <fd_lookup>
  801311:	83 c4 08             	add    $0x8,%esp
  801314:	85 c0                	test   %eax,%eax
  801316:	78 52                	js     80136a <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801318:	83 ec 08             	sub    $0x8,%esp
  80131b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80131e:	50                   	push   %eax
  80131f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801322:	ff 30                	pushl  (%eax)
  801324:	e8 a2 fb ff ff       	call   800ecb <dev_lookup>
  801329:	83 c4 10             	add    $0x10,%esp
  80132c:	85 c0                	test   %eax,%eax
  80132e:	78 3a                	js     80136a <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  801330:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801333:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801337:	74 2c                	je     801365 <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801339:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80133c:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801343:	00 00 00 
	stat->st_isdir = 0;
  801346:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80134d:	00 00 00 
	stat->st_dev = dev;
  801350:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801356:	83 ec 08             	sub    $0x8,%esp
  801359:	53                   	push   %ebx
  80135a:	ff 75 f0             	pushl  -0x10(%ebp)
  80135d:	ff 50 14             	call   *0x14(%eax)
  801360:	83 c4 10             	add    $0x10,%esp
  801363:	eb 05                	jmp    80136a <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801365:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80136a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80136d:	c9                   	leave  
  80136e:	c3                   	ret    

0080136f <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80136f:	55                   	push   %ebp
  801370:	89 e5                	mov    %esp,%ebp
  801372:	56                   	push   %esi
  801373:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801374:	83 ec 08             	sub    $0x8,%esp
  801377:	6a 00                	push   $0x0
  801379:	ff 75 08             	pushl  0x8(%ebp)
  80137c:	e8 75 01 00 00       	call   8014f6 <open>
  801381:	89 c3                	mov    %eax,%ebx
  801383:	83 c4 10             	add    $0x10,%esp
  801386:	85 c0                	test   %eax,%eax
  801388:	78 1d                	js     8013a7 <stat+0x38>
		return fd;
	r = fstat(fd, stat);
  80138a:	83 ec 08             	sub    $0x8,%esp
  80138d:	ff 75 0c             	pushl  0xc(%ebp)
  801390:	50                   	push   %eax
  801391:	e8 65 ff ff ff       	call   8012fb <fstat>
  801396:	89 c6                	mov    %eax,%esi
	close(fd);
  801398:	89 1c 24             	mov    %ebx,(%esp)
  80139b:	e8 1d fc ff ff       	call   800fbd <close>
	return r;
  8013a0:	83 c4 10             	add    $0x10,%esp
  8013a3:	89 f0                	mov    %esi,%eax
  8013a5:	eb 00                	jmp    8013a7 <stat+0x38>
}
  8013a7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013aa:	5b                   	pop    %ebx
  8013ab:	5e                   	pop    %esi
  8013ac:	5d                   	pop    %ebp
  8013ad:	c3                   	ret    

008013ae <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8013ae:	55                   	push   %ebp
  8013af:	89 e5                	mov    %esp,%ebp
  8013b1:	56                   	push   %esi
  8013b2:	53                   	push   %ebx
  8013b3:	89 c6                	mov    %eax,%esi
  8013b5:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8013b7:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8013be:	75 12                	jne    8013d2 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8013c0:	83 ec 0c             	sub    $0xc,%esp
  8013c3:	6a 01                	push   $0x1
  8013c5:	e8 c1 07 00 00       	call   801b8b <ipc_find_env>
  8013ca:	a3 00 40 80 00       	mov    %eax,0x804000
  8013cf:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8013d2:	6a 07                	push   $0x7
  8013d4:	68 00 50 80 00       	push   $0x805000
  8013d9:	56                   	push   %esi
  8013da:	ff 35 00 40 80 00    	pushl  0x804000
  8013e0:	e8 47 07 00 00       	call   801b2c <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8013e5:	83 c4 0c             	add    $0xc,%esp
  8013e8:	6a 00                	push   $0x0
  8013ea:	53                   	push   %ebx
  8013eb:	6a 00                	push   $0x0
  8013ed:	e8 c5 06 00 00       	call   801ab7 <ipc_recv>
}
  8013f2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013f5:	5b                   	pop    %ebx
  8013f6:	5e                   	pop    %esi
  8013f7:	5d                   	pop    %ebp
  8013f8:	c3                   	ret    

008013f9 <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8013f9:	55                   	push   %ebp
  8013fa:	89 e5                	mov    %esp,%ebp
  8013fc:	53                   	push   %ebx
  8013fd:	83 ec 04             	sub    $0x4,%esp
  801400:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801403:	8b 45 08             	mov    0x8(%ebp),%eax
  801406:	8b 40 0c             	mov    0xc(%eax),%eax
  801409:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80140e:	ba 00 00 00 00       	mov    $0x0,%edx
  801413:	b8 05 00 00 00       	mov    $0x5,%eax
  801418:	e8 91 ff ff ff       	call   8013ae <fsipc>
  80141d:	85 c0                	test   %eax,%eax
  80141f:	78 2c                	js     80144d <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801421:	83 ec 08             	sub    $0x8,%esp
  801424:	68 00 50 80 00       	push   $0x805000
  801429:	53                   	push   %ebx
  80142a:	e8 49 f3 ff ff       	call   800778 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80142f:	a1 80 50 80 00       	mov    0x805080,%eax
  801434:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80143a:	a1 84 50 80 00       	mov    0x805084,%eax
  80143f:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801445:	83 c4 10             	add    $0x10,%esp
  801448:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80144d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801450:	c9                   	leave  
  801451:	c3                   	ret    

00801452 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801452:	55                   	push   %ebp
  801453:	89 e5                	mov    %esp,%ebp
  801455:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801458:	8b 45 08             	mov    0x8(%ebp),%eax
  80145b:	8b 40 0c             	mov    0xc(%eax),%eax
  80145e:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801463:	ba 00 00 00 00       	mov    $0x0,%edx
  801468:	b8 06 00 00 00       	mov    $0x6,%eax
  80146d:	e8 3c ff ff ff       	call   8013ae <fsipc>
}
  801472:	c9                   	leave  
  801473:	c3                   	ret    

00801474 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801474:	55                   	push   %ebp
  801475:	89 e5                	mov    %esp,%ebp
  801477:	56                   	push   %esi
  801478:	53                   	push   %ebx
  801479:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80147c:	8b 45 08             	mov    0x8(%ebp),%eax
  80147f:	8b 40 0c             	mov    0xc(%eax),%eax
  801482:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801487:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80148d:	ba 00 00 00 00       	mov    $0x0,%edx
  801492:	b8 03 00 00 00       	mov    $0x3,%eax
  801497:	e8 12 ff ff ff       	call   8013ae <fsipc>
  80149c:	89 c3                	mov    %eax,%ebx
  80149e:	85 c0                	test   %eax,%eax
  8014a0:	78 4b                	js     8014ed <devfile_read+0x79>
		return r;
	assert(r <= n);
  8014a2:	39 c6                	cmp    %eax,%esi
  8014a4:	73 16                	jae    8014bc <devfile_read+0x48>
  8014a6:	68 c6 22 80 00       	push   $0x8022c6
  8014ab:	68 cd 22 80 00       	push   $0x8022cd
  8014b0:	6a 7a                	push   $0x7a
  8014b2:	68 e2 22 80 00       	push   $0x8022e2
  8014b7:	e8 b5 05 00 00       	call   801a71 <_panic>
	assert(r <= PGSIZE);
  8014bc:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8014c1:	7e 16                	jle    8014d9 <devfile_read+0x65>
  8014c3:	68 ed 22 80 00       	push   $0x8022ed
  8014c8:	68 cd 22 80 00       	push   $0x8022cd
  8014cd:	6a 7b                	push   $0x7b
  8014cf:	68 e2 22 80 00       	push   $0x8022e2
  8014d4:	e8 98 05 00 00       	call   801a71 <_panic>
	memmove(buf, &fsipcbuf, r);
  8014d9:	83 ec 04             	sub    $0x4,%esp
  8014dc:	50                   	push   %eax
  8014dd:	68 00 50 80 00       	push   $0x805000
  8014e2:	ff 75 0c             	pushl  0xc(%ebp)
  8014e5:	e8 5b f4 ff ff       	call   800945 <memmove>
	return r;
  8014ea:	83 c4 10             	add    $0x10,%esp
}
  8014ed:	89 d8                	mov    %ebx,%eax
  8014ef:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014f2:	5b                   	pop    %ebx
  8014f3:	5e                   	pop    %esi
  8014f4:	5d                   	pop    %ebp
  8014f5:	c3                   	ret    

008014f6 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8014f6:	55                   	push   %ebp
  8014f7:	89 e5                	mov    %esp,%ebp
  8014f9:	53                   	push   %ebx
  8014fa:	83 ec 20             	sub    $0x20,%esp
  8014fd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801500:	53                   	push   %ebx
  801501:	e8 1b f2 ff ff       	call   800721 <strlen>
  801506:	83 c4 10             	add    $0x10,%esp
  801509:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80150e:	7f 63                	jg     801573 <open+0x7d>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801510:	83 ec 0c             	sub    $0xc,%esp
  801513:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801516:	50                   	push   %eax
  801517:	e8 e4 f8 ff ff       	call   800e00 <fd_alloc>
  80151c:	83 c4 10             	add    $0x10,%esp
  80151f:	85 c0                	test   %eax,%eax
  801521:	78 55                	js     801578 <open+0x82>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801523:	83 ec 08             	sub    $0x8,%esp
  801526:	53                   	push   %ebx
  801527:	68 00 50 80 00       	push   $0x805000
  80152c:	e8 47 f2 ff ff       	call   800778 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801531:	8b 45 0c             	mov    0xc(%ebp),%eax
  801534:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801539:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80153c:	b8 01 00 00 00       	mov    $0x1,%eax
  801541:	e8 68 fe ff ff       	call   8013ae <fsipc>
  801546:	89 c3                	mov    %eax,%ebx
  801548:	83 c4 10             	add    $0x10,%esp
  80154b:	85 c0                	test   %eax,%eax
  80154d:	79 14                	jns    801563 <open+0x6d>
		fd_close(fd, 0);
  80154f:	83 ec 08             	sub    $0x8,%esp
  801552:	6a 00                	push   $0x0
  801554:	ff 75 f4             	pushl  -0xc(%ebp)
  801557:	e8 dd f9 ff ff       	call   800f39 <fd_close>
		return r;
  80155c:	83 c4 10             	add    $0x10,%esp
  80155f:	89 d8                	mov    %ebx,%eax
  801561:	eb 15                	jmp    801578 <open+0x82>
	}

	return fd2num(fd);
  801563:	83 ec 0c             	sub    $0xc,%esp
  801566:	ff 75 f4             	pushl  -0xc(%ebp)
  801569:	e8 6b f8 ff ff       	call   800dd9 <fd2num>
  80156e:	83 c4 10             	add    $0x10,%esp
  801571:	eb 05                	jmp    801578 <open+0x82>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801573:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801578:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80157b:	c9                   	leave  
  80157c:	c3                   	ret    

0080157d <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80157d:	55                   	push   %ebp
  80157e:	89 e5                	mov    %esp,%ebp
  801580:	56                   	push   %esi
  801581:	53                   	push   %ebx
  801582:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801585:	83 ec 0c             	sub    $0xc,%esp
  801588:	ff 75 08             	pushl  0x8(%ebp)
  80158b:	e8 59 f8 ff ff       	call   800de9 <fd2data>
  801590:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801592:	83 c4 08             	add    $0x8,%esp
  801595:	68 f9 22 80 00       	push   $0x8022f9
  80159a:	53                   	push   %ebx
  80159b:	e8 d8 f1 ff ff       	call   800778 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8015a0:	8b 46 04             	mov    0x4(%esi),%eax
  8015a3:	2b 06                	sub    (%esi),%eax
  8015a5:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8015ab:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8015b2:	00 00 00 
	stat->st_dev = &devpipe;
  8015b5:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8015bc:	30 80 00 
	return 0;
}
  8015bf:	b8 00 00 00 00       	mov    $0x0,%eax
  8015c4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015c7:	5b                   	pop    %ebx
  8015c8:	5e                   	pop    %esi
  8015c9:	5d                   	pop    %ebp
  8015ca:	c3                   	ret    

008015cb <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8015cb:	55                   	push   %ebp
  8015cc:	89 e5                	mov    %esp,%ebp
  8015ce:	53                   	push   %ebx
  8015cf:	83 ec 0c             	sub    $0xc,%esp
  8015d2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8015d5:	53                   	push   %ebx
  8015d6:	6a 00                	push   $0x0
  8015d8:	e8 90 f6 ff ff       	call   800c6d <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8015dd:	89 1c 24             	mov    %ebx,(%esp)
  8015e0:	e8 04 f8 ff ff       	call   800de9 <fd2data>
  8015e5:	83 c4 08             	add    $0x8,%esp
  8015e8:	50                   	push   %eax
  8015e9:	6a 00                	push   $0x0
  8015eb:	e8 7d f6 ff ff       	call   800c6d <sys_page_unmap>
}
  8015f0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015f3:	c9                   	leave  
  8015f4:	c3                   	ret    

008015f5 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8015f5:	55                   	push   %ebp
  8015f6:	89 e5                	mov    %esp,%ebp
  8015f8:	57                   	push   %edi
  8015f9:	56                   	push   %esi
  8015fa:	53                   	push   %ebx
  8015fb:	83 ec 1c             	sub    $0x1c,%esp
  8015fe:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801601:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801603:	a1 04 40 80 00       	mov    0x804004,%eax
  801608:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  80160b:	83 ec 0c             	sub    $0xc,%esp
  80160e:	ff 75 e0             	pushl  -0x20(%ebp)
  801611:	e8 d0 05 00 00       	call   801be6 <pageref>
  801616:	89 c3                	mov    %eax,%ebx
  801618:	89 3c 24             	mov    %edi,(%esp)
  80161b:	e8 c6 05 00 00       	call   801be6 <pageref>
  801620:	83 c4 10             	add    $0x10,%esp
  801623:	39 c3                	cmp    %eax,%ebx
  801625:	0f 94 c1             	sete   %cl
  801628:	0f b6 c9             	movzbl %cl,%ecx
  80162b:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  80162e:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801634:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801637:	39 ce                	cmp    %ecx,%esi
  801639:	74 1b                	je     801656 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  80163b:	39 c3                	cmp    %eax,%ebx
  80163d:	75 c4                	jne    801603 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80163f:	8b 42 58             	mov    0x58(%edx),%eax
  801642:	ff 75 e4             	pushl  -0x1c(%ebp)
  801645:	50                   	push   %eax
  801646:	56                   	push   %esi
  801647:	68 00 23 80 00       	push   $0x802300
  80164c:	e8 42 eb ff ff       	call   800193 <cprintf>
  801651:	83 c4 10             	add    $0x10,%esp
  801654:	eb ad                	jmp    801603 <_pipeisclosed+0xe>
	}
}
  801656:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801659:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80165c:	5b                   	pop    %ebx
  80165d:	5e                   	pop    %esi
  80165e:	5f                   	pop    %edi
  80165f:	5d                   	pop    %ebp
  801660:	c3                   	ret    

00801661 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801661:	55                   	push   %ebp
  801662:	89 e5                	mov    %esp,%ebp
  801664:	57                   	push   %edi
  801665:	56                   	push   %esi
  801666:	53                   	push   %ebx
  801667:	83 ec 18             	sub    $0x18,%esp
  80166a:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80166d:	56                   	push   %esi
  80166e:	e8 76 f7 ff ff       	call   800de9 <fd2data>
  801673:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801675:	83 c4 10             	add    $0x10,%esp
  801678:	bf 00 00 00 00       	mov    $0x0,%edi
  80167d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801681:	75 42                	jne    8016c5 <devpipe_write+0x64>
  801683:	eb 4e                	jmp    8016d3 <devpipe_write+0x72>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801685:	89 da                	mov    %ebx,%edx
  801687:	89 f0                	mov    %esi,%eax
  801689:	e8 67 ff ff ff       	call   8015f5 <_pipeisclosed>
  80168e:	85 c0                	test   %eax,%eax
  801690:	75 46                	jne    8016d8 <devpipe_write+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801692:	e8 32 f5 ff ff       	call   800bc9 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801697:	8b 53 04             	mov    0x4(%ebx),%edx
  80169a:	8b 03                	mov    (%ebx),%eax
  80169c:	83 c0 20             	add    $0x20,%eax
  80169f:	39 c2                	cmp    %eax,%edx
  8016a1:	73 e2                	jae    801685 <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8016a3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016a6:	8a 0c 38             	mov    (%eax,%edi,1),%cl
  8016a9:	89 d0                	mov    %edx,%eax
  8016ab:	25 1f 00 00 80       	and    $0x8000001f,%eax
  8016b0:	79 05                	jns    8016b7 <devpipe_write+0x56>
  8016b2:	48                   	dec    %eax
  8016b3:	83 c8 e0             	or     $0xffffffe0,%eax
  8016b6:	40                   	inc    %eax
  8016b7:	88 4c 03 08          	mov    %cl,0x8(%ebx,%eax,1)
		p->p_wpos++;
  8016bb:	42                   	inc    %edx
  8016bc:	89 53 04             	mov    %edx,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8016bf:	47                   	inc    %edi
  8016c0:	39 7d 10             	cmp    %edi,0x10(%ebp)
  8016c3:	74 0e                	je     8016d3 <devpipe_write+0x72>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8016c5:	8b 53 04             	mov    0x4(%ebx),%edx
  8016c8:	8b 03                	mov    (%ebx),%eax
  8016ca:	83 c0 20             	add    $0x20,%eax
  8016cd:	39 c2                	cmp    %eax,%edx
  8016cf:	73 b4                	jae    801685 <devpipe_write+0x24>
  8016d1:	eb d0                	jmp    8016a3 <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8016d3:	8b 45 10             	mov    0x10(%ebp),%eax
  8016d6:	eb 05                	jmp    8016dd <devpipe_write+0x7c>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8016d8:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8016dd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016e0:	5b                   	pop    %ebx
  8016e1:	5e                   	pop    %esi
  8016e2:	5f                   	pop    %edi
  8016e3:	5d                   	pop    %ebp
  8016e4:	c3                   	ret    

008016e5 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8016e5:	55                   	push   %ebp
  8016e6:	89 e5                	mov    %esp,%ebp
  8016e8:	57                   	push   %edi
  8016e9:	56                   	push   %esi
  8016ea:	53                   	push   %ebx
  8016eb:	83 ec 18             	sub    $0x18,%esp
  8016ee:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8016f1:	57                   	push   %edi
  8016f2:	e8 f2 f6 ff ff       	call   800de9 <fd2data>
  8016f7:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8016f9:	83 c4 10             	add    $0x10,%esp
  8016fc:	be 00 00 00 00       	mov    $0x0,%esi
  801701:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801705:	75 3d                	jne    801744 <devpipe_read+0x5f>
  801707:	eb 48                	jmp    801751 <devpipe_read+0x6c>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  801709:	89 f0                	mov    %esi,%eax
  80170b:	eb 4e                	jmp    80175b <devpipe_read+0x76>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80170d:	89 da                	mov    %ebx,%edx
  80170f:	89 f8                	mov    %edi,%eax
  801711:	e8 df fe ff ff       	call   8015f5 <_pipeisclosed>
  801716:	85 c0                	test   %eax,%eax
  801718:	75 3c                	jne    801756 <devpipe_read+0x71>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80171a:	e8 aa f4 ff ff       	call   800bc9 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80171f:	8b 03                	mov    (%ebx),%eax
  801721:	3b 43 04             	cmp    0x4(%ebx),%eax
  801724:	74 e7                	je     80170d <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801726:	25 1f 00 00 80       	and    $0x8000001f,%eax
  80172b:	79 05                	jns    801732 <devpipe_read+0x4d>
  80172d:	48                   	dec    %eax
  80172e:	83 c8 e0             	or     $0xffffffe0,%eax
  801731:	40                   	inc    %eax
  801732:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801736:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801739:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  80173c:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80173e:	46                   	inc    %esi
  80173f:	39 75 10             	cmp    %esi,0x10(%ebp)
  801742:	74 0d                	je     801751 <devpipe_read+0x6c>
		while (p->p_rpos == p->p_wpos) {
  801744:	8b 03                	mov    (%ebx),%eax
  801746:	3b 43 04             	cmp    0x4(%ebx),%eax
  801749:	75 db                	jne    801726 <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80174b:	85 f6                	test   %esi,%esi
  80174d:	75 ba                	jne    801709 <devpipe_read+0x24>
  80174f:	eb bc                	jmp    80170d <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801751:	8b 45 10             	mov    0x10(%ebp),%eax
  801754:	eb 05                	jmp    80175b <devpipe_read+0x76>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801756:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80175b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80175e:	5b                   	pop    %ebx
  80175f:	5e                   	pop    %esi
  801760:	5f                   	pop    %edi
  801761:	5d                   	pop    %ebp
  801762:	c3                   	ret    

00801763 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801763:	55                   	push   %ebp
  801764:	89 e5                	mov    %esp,%ebp
  801766:	56                   	push   %esi
  801767:	53                   	push   %ebx
  801768:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80176b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80176e:	50                   	push   %eax
  80176f:	e8 8c f6 ff ff       	call   800e00 <fd_alloc>
  801774:	83 c4 10             	add    $0x10,%esp
  801777:	85 c0                	test   %eax,%eax
  801779:	0f 88 2a 01 00 00    	js     8018a9 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80177f:	83 ec 04             	sub    $0x4,%esp
  801782:	68 07 04 00 00       	push   $0x407
  801787:	ff 75 f4             	pushl  -0xc(%ebp)
  80178a:	6a 00                	push   $0x0
  80178c:	e8 57 f4 ff ff       	call   800be8 <sys_page_alloc>
  801791:	83 c4 10             	add    $0x10,%esp
  801794:	85 c0                	test   %eax,%eax
  801796:	0f 88 0d 01 00 00    	js     8018a9 <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80179c:	83 ec 0c             	sub    $0xc,%esp
  80179f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017a2:	50                   	push   %eax
  8017a3:	e8 58 f6 ff ff       	call   800e00 <fd_alloc>
  8017a8:	89 c3                	mov    %eax,%ebx
  8017aa:	83 c4 10             	add    $0x10,%esp
  8017ad:	85 c0                	test   %eax,%eax
  8017af:	0f 88 e2 00 00 00    	js     801897 <pipe+0x134>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017b5:	83 ec 04             	sub    $0x4,%esp
  8017b8:	68 07 04 00 00       	push   $0x407
  8017bd:	ff 75 f0             	pushl  -0x10(%ebp)
  8017c0:	6a 00                	push   $0x0
  8017c2:	e8 21 f4 ff ff       	call   800be8 <sys_page_alloc>
  8017c7:	89 c3                	mov    %eax,%ebx
  8017c9:	83 c4 10             	add    $0x10,%esp
  8017cc:	85 c0                	test   %eax,%eax
  8017ce:	0f 88 c3 00 00 00    	js     801897 <pipe+0x134>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8017d4:	83 ec 0c             	sub    $0xc,%esp
  8017d7:	ff 75 f4             	pushl  -0xc(%ebp)
  8017da:	e8 0a f6 ff ff       	call   800de9 <fd2data>
  8017df:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017e1:	83 c4 0c             	add    $0xc,%esp
  8017e4:	68 07 04 00 00       	push   $0x407
  8017e9:	50                   	push   %eax
  8017ea:	6a 00                	push   $0x0
  8017ec:	e8 f7 f3 ff ff       	call   800be8 <sys_page_alloc>
  8017f1:	89 c3                	mov    %eax,%ebx
  8017f3:	83 c4 10             	add    $0x10,%esp
  8017f6:	85 c0                	test   %eax,%eax
  8017f8:	0f 88 89 00 00 00    	js     801887 <pipe+0x124>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017fe:	83 ec 0c             	sub    $0xc,%esp
  801801:	ff 75 f0             	pushl  -0x10(%ebp)
  801804:	e8 e0 f5 ff ff       	call   800de9 <fd2data>
  801809:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801810:	50                   	push   %eax
  801811:	6a 00                	push   $0x0
  801813:	56                   	push   %esi
  801814:	6a 00                	push   $0x0
  801816:	e8 10 f4 ff ff       	call   800c2b <sys_page_map>
  80181b:	89 c3                	mov    %eax,%ebx
  80181d:	83 c4 20             	add    $0x20,%esp
  801820:	85 c0                	test   %eax,%eax
  801822:	78 55                	js     801879 <pipe+0x116>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801824:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80182a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80182d:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80182f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801832:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801839:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80183f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801842:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801844:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801847:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80184e:	83 ec 0c             	sub    $0xc,%esp
  801851:	ff 75 f4             	pushl  -0xc(%ebp)
  801854:	e8 80 f5 ff ff       	call   800dd9 <fd2num>
  801859:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80185c:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80185e:	83 c4 04             	add    $0x4,%esp
  801861:	ff 75 f0             	pushl  -0x10(%ebp)
  801864:	e8 70 f5 ff ff       	call   800dd9 <fd2num>
  801869:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80186c:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  80186f:	83 c4 10             	add    $0x10,%esp
  801872:	b8 00 00 00 00       	mov    $0x0,%eax
  801877:	eb 30                	jmp    8018a9 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  801879:	83 ec 08             	sub    $0x8,%esp
  80187c:	56                   	push   %esi
  80187d:	6a 00                	push   $0x0
  80187f:	e8 e9 f3 ff ff       	call   800c6d <sys_page_unmap>
  801884:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801887:	83 ec 08             	sub    $0x8,%esp
  80188a:	ff 75 f0             	pushl  -0x10(%ebp)
  80188d:	6a 00                	push   $0x0
  80188f:	e8 d9 f3 ff ff       	call   800c6d <sys_page_unmap>
  801894:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801897:	83 ec 08             	sub    $0x8,%esp
  80189a:	ff 75 f4             	pushl  -0xc(%ebp)
  80189d:	6a 00                	push   $0x0
  80189f:	e8 c9 f3 ff ff       	call   800c6d <sys_page_unmap>
  8018a4:	83 c4 10             	add    $0x10,%esp
  8018a7:	89 d8                	mov    %ebx,%eax
    err:
	return r;
}
  8018a9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018ac:	5b                   	pop    %ebx
  8018ad:	5e                   	pop    %esi
  8018ae:	5d                   	pop    %ebp
  8018af:	c3                   	ret    

008018b0 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8018b0:	55                   	push   %ebp
  8018b1:	89 e5                	mov    %esp,%ebp
  8018b3:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8018b6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018b9:	50                   	push   %eax
  8018ba:	ff 75 08             	pushl  0x8(%ebp)
  8018bd:	e8 b2 f5 ff ff       	call   800e74 <fd_lookup>
  8018c2:	83 c4 10             	add    $0x10,%esp
  8018c5:	85 c0                	test   %eax,%eax
  8018c7:	78 18                	js     8018e1 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8018c9:	83 ec 0c             	sub    $0xc,%esp
  8018cc:	ff 75 f4             	pushl  -0xc(%ebp)
  8018cf:	e8 15 f5 ff ff       	call   800de9 <fd2data>
	return _pipeisclosed(fd, p);
  8018d4:	89 c2                	mov    %eax,%edx
  8018d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018d9:	e8 17 fd ff ff       	call   8015f5 <_pipeisclosed>
  8018de:	83 c4 10             	add    $0x10,%esp
}
  8018e1:	c9                   	leave  
  8018e2:	c3                   	ret    

008018e3 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8018e3:	55                   	push   %ebp
  8018e4:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8018e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8018eb:	5d                   	pop    %ebp
  8018ec:	c3                   	ret    

008018ed <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8018ed:	55                   	push   %ebp
  8018ee:	89 e5                	mov    %esp,%ebp
  8018f0:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8018f3:	68 18 23 80 00       	push   $0x802318
  8018f8:	ff 75 0c             	pushl  0xc(%ebp)
  8018fb:	e8 78 ee ff ff       	call   800778 <strcpy>
	return 0;
}
  801900:	b8 00 00 00 00       	mov    $0x0,%eax
  801905:	c9                   	leave  
  801906:	c3                   	ret    

00801907 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801907:	55                   	push   %ebp
  801908:	89 e5                	mov    %esp,%ebp
  80190a:	57                   	push   %edi
  80190b:	56                   	push   %esi
  80190c:	53                   	push   %ebx
  80190d:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801913:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801917:	74 45                	je     80195e <devcons_write+0x57>
  801919:	b8 00 00 00 00       	mov    $0x0,%eax
  80191e:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801923:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801929:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80192c:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  80192e:	83 fb 7f             	cmp    $0x7f,%ebx
  801931:	76 05                	jbe    801938 <devcons_write+0x31>
			m = sizeof(buf) - 1;
  801933:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801938:	83 ec 04             	sub    $0x4,%esp
  80193b:	53                   	push   %ebx
  80193c:	03 45 0c             	add    0xc(%ebp),%eax
  80193f:	50                   	push   %eax
  801940:	57                   	push   %edi
  801941:	e8 ff ef ff ff       	call   800945 <memmove>
		sys_cputs(buf, m);
  801946:	83 c4 08             	add    $0x8,%esp
  801949:	53                   	push   %ebx
  80194a:	57                   	push   %edi
  80194b:	e8 dc f1 ff ff       	call   800b2c <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801950:	01 de                	add    %ebx,%esi
  801952:	89 f0                	mov    %esi,%eax
  801954:	83 c4 10             	add    $0x10,%esp
  801957:	3b 75 10             	cmp    0x10(%ebp),%esi
  80195a:	72 cd                	jb     801929 <devcons_write+0x22>
  80195c:	eb 05                	jmp    801963 <devcons_write+0x5c>
  80195e:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801963:	89 f0                	mov    %esi,%eax
  801965:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801968:	5b                   	pop    %ebx
  801969:	5e                   	pop    %esi
  80196a:	5f                   	pop    %edi
  80196b:	5d                   	pop    %ebp
  80196c:	c3                   	ret    

0080196d <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80196d:	55                   	push   %ebp
  80196e:	89 e5                	mov    %esp,%ebp
  801970:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801973:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801977:	75 07                	jne    801980 <devcons_read+0x13>
  801979:	eb 23                	jmp    80199e <devcons_read+0x31>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80197b:	e8 49 f2 ff ff       	call   800bc9 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801980:	e8 c5 f1 ff ff       	call   800b4a <sys_cgetc>
  801985:	85 c0                	test   %eax,%eax
  801987:	74 f2                	je     80197b <devcons_read+0xe>
		sys_yield();
	if (c < 0)
  801989:	85 c0                	test   %eax,%eax
  80198b:	78 1d                	js     8019aa <devcons_read+0x3d>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80198d:	83 f8 04             	cmp    $0x4,%eax
  801990:	74 13                	je     8019a5 <devcons_read+0x38>
		return 0;
	*(char*)vbuf = c;
  801992:	8b 55 0c             	mov    0xc(%ebp),%edx
  801995:	88 02                	mov    %al,(%edx)
	return 1;
  801997:	b8 01 00 00 00       	mov    $0x1,%eax
  80199c:	eb 0c                	jmp    8019aa <devcons_read+0x3d>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  80199e:	b8 00 00 00 00       	mov    $0x0,%eax
  8019a3:	eb 05                	jmp    8019aa <devcons_read+0x3d>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8019a5:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8019aa:	c9                   	leave  
  8019ab:	c3                   	ret    

008019ac <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8019ac:	55                   	push   %ebp
  8019ad:	89 e5                	mov    %esp,%ebp
  8019af:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8019b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8019b5:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8019b8:	6a 01                	push   $0x1
  8019ba:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8019bd:	50                   	push   %eax
  8019be:	e8 69 f1 ff ff       	call   800b2c <sys_cputs>
}
  8019c3:	83 c4 10             	add    $0x10,%esp
  8019c6:	c9                   	leave  
  8019c7:	c3                   	ret    

008019c8 <getchar>:

int
getchar(void)
{
  8019c8:	55                   	push   %ebp
  8019c9:	89 e5                	mov    %esp,%ebp
  8019cb:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8019ce:	6a 01                	push   $0x1
  8019d0:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8019d3:	50                   	push   %eax
  8019d4:	6a 00                	push   $0x0
  8019d6:	e8 1a f7 ff ff       	call   8010f5 <read>
	if (r < 0)
  8019db:	83 c4 10             	add    $0x10,%esp
  8019de:	85 c0                	test   %eax,%eax
  8019e0:	78 0f                	js     8019f1 <getchar+0x29>
		return r;
	if (r < 1)
  8019e2:	85 c0                	test   %eax,%eax
  8019e4:	7e 06                	jle    8019ec <getchar+0x24>
		return -E_EOF;
	return c;
  8019e6:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8019ea:	eb 05                	jmp    8019f1 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8019ec:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8019f1:	c9                   	leave  
  8019f2:	c3                   	ret    

008019f3 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8019f3:	55                   	push   %ebp
  8019f4:	89 e5                	mov    %esp,%ebp
  8019f6:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8019f9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019fc:	50                   	push   %eax
  8019fd:	ff 75 08             	pushl  0x8(%ebp)
  801a00:	e8 6f f4 ff ff       	call   800e74 <fd_lookup>
  801a05:	83 c4 10             	add    $0x10,%esp
  801a08:	85 c0                	test   %eax,%eax
  801a0a:	78 11                	js     801a1d <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801a0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a0f:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801a15:	39 10                	cmp    %edx,(%eax)
  801a17:	0f 94 c0             	sete   %al
  801a1a:	0f b6 c0             	movzbl %al,%eax
}
  801a1d:	c9                   	leave  
  801a1e:	c3                   	ret    

00801a1f <opencons>:

int
opencons(void)
{
  801a1f:	55                   	push   %ebp
  801a20:	89 e5                	mov    %esp,%ebp
  801a22:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801a25:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a28:	50                   	push   %eax
  801a29:	e8 d2 f3 ff ff       	call   800e00 <fd_alloc>
  801a2e:	83 c4 10             	add    $0x10,%esp
  801a31:	85 c0                	test   %eax,%eax
  801a33:	78 3a                	js     801a6f <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801a35:	83 ec 04             	sub    $0x4,%esp
  801a38:	68 07 04 00 00       	push   $0x407
  801a3d:	ff 75 f4             	pushl  -0xc(%ebp)
  801a40:	6a 00                	push   $0x0
  801a42:	e8 a1 f1 ff ff       	call   800be8 <sys_page_alloc>
  801a47:	83 c4 10             	add    $0x10,%esp
  801a4a:	85 c0                	test   %eax,%eax
  801a4c:	78 21                	js     801a6f <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801a4e:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801a54:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a57:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801a59:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a5c:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801a63:	83 ec 0c             	sub    $0xc,%esp
  801a66:	50                   	push   %eax
  801a67:	e8 6d f3 ff ff       	call   800dd9 <fd2num>
  801a6c:	83 c4 10             	add    $0x10,%esp
}
  801a6f:	c9                   	leave  
  801a70:	c3                   	ret    

00801a71 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801a71:	55                   	push   %ebp
  801a72:	89 e5                	mov    %esp,%ebp
  801a74:	56                   	push   %esi
  801a75:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801a76:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801a79:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801a7f:	e8 26 f1 ff ff       	call   800baa <sys_getenvid>
  801a84:	83 ec 0c             	sub    $0xc,%esp
  801a87:	ff 75 0c             	pushl  0xc(%ebp)
  801a8a:	ff 75 08             	pushl  0x8(%ebp)
  801a8d:	56                   	push   %esi
  801a8e:	50                   	push   %eax
  801a8f:	68 24 23 80 00       	push   $0x802324
  801a94:	e8 fa e6 ff ff       	call   800193 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801a99:	83 c4 18             	add    $0x18,%esp
  801a9c:	53                   	push   %ebx
  801a9d:	ff 75 10             	pushl  0x10(%ebp)
  801aa0:	e8 9d e6 ff ff       	call   800142 <vcprintf>
	cprintf("\n");
  801aa5:	c7 04 24 11 23 80 00 	movl   $0x802311,(%esp)
  801aac:	e8 e2 e6 ff ff       	call   800193 <cprintf>
  801ab1:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801ab4:	cc                   	int3   
  801ab5:	eb fd                	jmp    801ab4 <_panic+0x43>

00801ab7 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801ab7:	55                   	push   %ebp
  801ab8:	89 e5                	mov    %esp,%ebp
  801aba:	56                   	push   %esi
  801abb:	53                   	push   %ebx
  801abc:	8b 75 08             	mov    0x8(%ebp),%esi
  801abf:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ac2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");
	int r;
    if (pg != NULL) {
  801ac5:	85 c0                	test   %eax,%eax
  801ac7:	74 0e                	je     801ad7 <ipc_recv+0x20>
        r = sys_ipc_recv(pg);
  801ac9:	83 ec 0c             	sub    $0xc,%esp
  801acc:	50                   	push   %eax
  801acd:	e8 c6 f2 ff ff       	call   800d98 <sys_ipc_recv>
  801ad2:	83 c4 10             	add    $0x10,%esp
  801ad5:	eb 10                	jmp    801ae7 <ipc_recv+0x30>
    } else {
        r = sys_ipc_recv((void *) UTOP);
  801ad7:	83 ec 0c             	sub    $0xc,%esp
  801ada:	68 00 00 c0 ee       	push   $0xeec00000
  801adf:	e8 b4 f2 ff ff       	call   800d98 <sys_ipc_recv>
  801ae4:	83 c4 10             	add    $0x10,%esp
    }
    if (r < 0) {
  801ae7:	85 c0                	test   %eax,%eax
  801ae9:	79 16                	jns    801b01 <ipc_recv+0x4a>
        // failed
        if (from_env_store != NULL) *from_env_store = 0;
  801aeb:	85 f6                	test   %esi,%esi
  801aed:	74 06                	je     801af5 <ipc_recv+0x3e>
  801aef:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        if (perm_store != NULL) *perm_store = 0;
  801af5:	85 db                	test   %ebx,%ebx
  801af7:	74 2c                	je     801b25 <ipc_recv+0x6e>
  801af9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801aff:	eb 24                	jmp    801b25 <ipc_recv+0x6e>
        return r;
    } else {
        if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801b01:	85 f6                	test   %esi,%esi
  801b03:	74 0a                	je     801b0f <ipc_recv+0x58>
  801b05:	a1 04 40 80 00       	mov    0x804004,%eax
  801b0a:	8b 40 74             	mov    0x74(%eax),%eax
  801b0d:	89 06                	mov    %eax,(%esi)
        if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801b0f:	85 db                	test   %ebx,%ebx
  801b11:	74 0a                	je     801b1d <ipc_recv+0x66>
  801b13:	a1 04 40 80 00       	mov    0x804004,%eax
  801b18:	8b 40 78             	mov    0x78(%eax),%eax
  801b1b:	89 03                	mov    %eax,(%ebx)
        return thisenv->env_ipc_value;
  801b1d:	a1 04 40 80 00       	mov    0x804004,%eax
  801b22:	8b 40 70             	mov    0x70(%eax),%eax
    }
 
	return 0;
}
  801b25:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b28:	5b                   	pop    %ebx
  801b29:	5e                   	pop    %esi
  801b2a:	5d                   	pop    %ebp
  801b2b:	c3                   	ret    

00801b2c <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801b2c:	55                   	push   %ebp
  801b2d:	89 e5                	mov    %esp,%ebp
  801b2f:	57                   	push   %edi
  801b30:	56                   	push   %esi
  801b31:	53                   	push   %ebx
  801b32:	83 ec 0c             	sub    $0xc,%esp
  801b35:	8b 75 10             	mov    0x10(%ebp),%esi
  801b38:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");
	int r;
    if (pg == NULL) pg = (void *)UTOP;
  801b3b:	85 f6                	test   %esi,%esi
  801b3d:	75 05                	jne    801b44 <ipc_send+0x18>
  801b3f:	be 00 00 c0 ee       	mov    $0xeec00000,%esi
    do {
        r = sys_ipc_try_send(to_env, val, pg, perm);
  801b44:	57                   	push   %edi
  801b45:	56                   	push   %esi
  801b46:	ff 75 0c             	pushl  0xc(%ebp)
  801b49:	ff 75 08             	pushl  0x8(%ebp)
  801b4c:	e8 24 f2 ff ff       	call   800d75 <sys_ipc_try_send>
  801b51:	89 c3                	mov    %eax,%ebx
        if (r < 0 && r != -E_IPC_NOT_RECV) panic("ipc send failed: %e", r);
  801b53:	83 c4 10             	add    $0x10,%esp
  801b56:	85 c0                	test   %eax,%eax
  801b58:	79 17                	jns    801b71 <ipc_send+0x45>
  801b5a:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801b5d:	74 1d                	je     801b7c <ipc_send+0x50>
  801b5f:	50                   	push   %eax
  801b60:	68 48 23 80 00       	push   $0x802348
  801b65:	6a 40                	push   $0x40
  801b67:	68 5c 23 80 00       	push   $0x80235c
  801b6c:	e8 00 ff ff ff       	call   801a71 <_panic>
        sys_yield();
  801b71:	e8 53 f0 ff ff       	call   800bc9 <sys_yield>
    } while (r != 0);
  801b76:	85 db                	test   %ebx,%ebx
  801b78:	75 ca                	jne    801b44 <ipc_send+0x18>
  801b7a:	eb 07                	jmp    801b83 <ipc_send+0x57>
	int r;
    if (pg == NULL) pg = (void *)UTOP;
    do {
        r = sys_ipc_try_send(to_env, val, pg, perm);
        if (r < 0 && r != -E_IPC_NOT_RECV) panic("ipc send failed: %e", r);
        sys_yield();
  801b7c:	e8 48 f0 ff ff       	call   800bc9 <sys_yield>
  801b81:	eb c1                	jmp    801b44 <ipc_send+0x18>
    } while (r != 0);
}
  801b83:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b86:	5b                   	pop    %ebx
  801b87:	5e                   	pop    %esi
  801b88:	5f                   	pop    %edi
  801b89:	5d                   	pop    %ebp
  801b8a:	c3                   	ret    

00801b8b <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b8b:	55                   	push   %ebp
  801b8c:	89 e5                	mov    %esp,%ebp
  801b8e:	53                   	push   %ebx
  801b8f:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801b92:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  801b97:	39 c1                	cmp    %eax,%ecx
  801b99:	74 21                	je     801bbc <ipc_find_env+0x31>
  801b9b:	ba 01 00 00 00       	mov    $0x1,%edx
  801ba0:	8d 1c 95 00 00 00 00 	lea    0x0(,%edx,4),%ebx
  801ba7:	89 d0                	mov    %edx,%eax
  801ba9:	c1 e0 07             	shl    $0x7,%eax
  801bac:	29 d8                	sub    %ebx,%eax
  801bae:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801bb3:	8b 40 50             	mov    0x50(%eax),%eax
  801bb6:	39 c8                	cmp    %ecx,%eax
  801bb8:	75 1b                	jne    801bd5 <ipc_find_env+0x4a>
  801bba:	eb 05                	jmp    801bc1 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801bbc:	ba 00 00 00 00       	mov    $0x0,%edx
		if (envs[i].env_type == type)
			return envs[i].env_id;
  801bc1:	8d 04 95 00 00 00 00 	lea    0x0(,%edx,4),%eax
  801bc8:	c1 e2 07             	shl    $0x7,%edx
  801bcb:	29 c2                	sub    %eax,%edx
  801bcd:	8b 82 48 00 c0 ee    	mov    -0x113fffb8(%edx),%eax
  801bd3:	eb 0e                	jmp    801be3 <ipc_find_env+0x58>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801bd5:	42                   	inc    %edx
  801bd6:	81 fa 00 04 00 00    	cmp    $0x400,%edx
  801bdc:	75 c2                	jne    801ba0 <ipc_find_env+0x15>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801bde:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801be3:	5b                   	pop    %ebx
  801be4:	5d                   	pop    %ebp
  801be5:	c3                   	ret    

00801be6 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801be6:	55                   	push   %ebp
  801be7:	89 e5                	mov    %esp,%ebp
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801be9:	8b 45 08             	mov    0x8(%ebp),%eax
  801bec:	c1 e8 16             	shr    $0x16,%eax
  801bef:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801bf6:	a8 01                	test   $0x1,%al
  801bf8:	74 21                	je     801c1b <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801bfa:	8b 45 08             	mov    0x8(%ebp),%eax
  801bfd:	c1 e8 0c             	shr    $0xc,%eax
  801c00:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801c07:	a8 01                	test   $0x1,%al
  801c09:	74 17                	je     801c22 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801c0b:	c1 e8 0c             	shr    $0xc,%eax
  801c0e:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801c15:	ef 
  801c16:	0f b7 c0             	movzwl %ax,%eax
  801c19:	eb 0c                	jmp    801c27 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801c1b:	b8 00 00 00 00       	mov    $0x0,%eax
  801c20:	eb 05                	jmp    801c27 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801c22:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801c27:	5d                   	pop    %ebp
  801c28:	c3                   	ret    
  801c29:	66 90                	xchg   %ax,%ax
  801c2b:	90                   	nop

00801c2c <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801c2c:	55                   	push   %ebp
  801c2d:	57                   	push   %edi
  801c2e:	56                   	push   %esi
  801c2f:	53                   	push   %ebx
  801c30:	83 ec 1c             	sub    $0x1c,%esp
  801c33:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801c37:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801c3b:	8b 7c 24 38          	mov    0x38(%esp),%edi
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801c3f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801c43:	89 ca                	mov    %ecx,%edx
  const DWunion dd = {.ll = d};
  801c45:	89 f8                	mov    %edi,%eax
  801c47:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801c4b:	85 f6                	test   %esi,%esi
  801c4d:	75 2d                	jne    801c7c <__udivdi3+0x50>
    {
      if (d0 > n1)
  801c4f:	39 cf                	cmp    %ecx,%edi
  801c51:	77 65                	ja     801cb8 <__udivdi3+0x8c>
  801c53:	89 fd                	mov    %edi,%ebp
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801c55:	85 ff                	test   %edi,%edi
  801c57:	75 0b                	jne    801c64 <__udivdi3+0x38>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801c59:	b8 01 00 00 00       	mov    $0x1,%eax
  801c5e:	31 d2                	xor    %edx,%edx
  801c60:	f7 f7                	div    %edi
  801c62:	89 c5                	mov    %eax,%ebp

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801c64:	31 d2                	xor    %edx,%edx
  801c66:	89 c8                	mov    %ecx,%eax
  801c68:	f7 f5                	div    %ebp
  801c6a:	89 c1                	mov    %eax,%ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801c6c:	89 d8                	mov    %ebx,%eax
  801c6e:	f7 f5                	div    %ebp
  801c70:	89 cf                	mov    %ecx,%edi
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
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801c7c:	39 ce                	cmp    %ecx,%esi
  801c7e:	77 28                	ja     801ca8 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801c80:	0f bd fe             	bsr    %esi,%edi
	  if (bm == 0)
  801c83:	83 f7 1f             	xor    $0x1f,%edi
  801c86:	75 40                	jne    801cc8 <__udivdi3+0x9c>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801c88:	39 ce                	cmp    %ecx,%esi
  801c8a:	72 0a                	jb     801c96 <__udivdi3+0x6a>
  801c8c:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801c90:	0f 87 9e 00 00 00    	ja     801d34 <__udivdi3+0x108>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801c96:	b8 01 00 00 00       	mov    $0x1,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801c9b:	89 fa                	mov    %edi,%edx
  801c9d:	83 c4 1c             	add    $0x1c,%esp
  801ca0:	5b                   	pop    %ebx
  801ca1:	5e                   	pop    %esi
  801ca2:	5f                   	pop    %edi
  801ca3:	5d                   	pop    %ebp
  801ca4:	c3                   	ret    
  801ca5:	8d 76 00             	lea    0x0(%esi),%esi
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801ca8:	31 ff                	xor    %edi,%edi
  801caa:	31 c0                	xor    %eax,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801cac:	89 fa                	mov    %edi,%edx
  801cae:	83 c4 1c             	add    $0x1c,%esp
  801cb1:	5b                   	pop    %ebx
  801cb2:	5e                   	pop    %esi
  801cb3:	5f                   	pop    %edi
  801cb4:	5d                   	pop    %ebp
  801cb5:	c3                   	ret    
  801cb6:	66 90                	xchg   %ax,%ax
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801cb8:	89 d8                	mov    %ebx,%eax
  801cba:	f7 f7                	div    %edi
  801cbc:	31 ff                	xor    %edi,%edi
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801cbe:	89 fa                	mov    %edi,%edx
  801cc0:	83 c4 1c             	add    $0x1c,%esp
  801cc3:	5b                   	pop    %ebx
  801cc4:	5e                   	pop    %esi
  801cc5:	5f                   	pop    %edi
  801cc6:	5d                   	pop    %ebp
  801cc7:	c3                   	ret    
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801cc8:	bd 20 00 00 00       	mov    $0x20,%ebp
  801ccd:	89 eb                	mov    %ebp,%ebx
  801ccf:	29 fb                	sub    %edi,%ebx

	      d1 = (d1 << bm) | (d0 >> b);
  801cd1:	89 f9                	mov    %edi,%ecx
  801cd3:	d3 e6                	shl    %cl,%esi
  801cd5:	89 c5                	mov    %eax,%ebp
  801cd7:	88 d9                	mov    %bl,%cl
  801cd9:	d3 ed                	shr    %cl,%ebp
  801cdb:	89 e9                	mov    %ebp,%ecx
  801cdd:	09 f1                	or     %esi,%ecx
  801cdf:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
	      d0 = d0 << bm;
  801ce3:	89 f9                	mov    %edi,%ecx
  801ce5:	d3 e0                	shl    %cl,%eax
  801ce7:	89 c5                	mov    %eax,%ebp
	      n2 = n1 >> b;
  801ce9:	89 d6                	mov    %edx,%esi
  801ceb:	88 d9                	mov    %bl,%cl
  801ced:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
  801cef:	89 f9                	mov    %edi,%ecx
  801cf1:	d3 e2                	shl    %cl,%edx
  801cf3:	8b 44 24 08          	mov    0x8(%esp),%eax
  801cf7:	88 d9                	mov    %bl,%cl
  801cf9:	d3 e8                	shr    %cl,%eax
  801cfb:	09 c2                	or     %eax,%edx
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801cfd:	89 d0                	mov    %edx,%eax
  801cff:	89 f2                	mov    %esi,%edx
  801d01:	f7 74 24 0c          	divl   0xc(%esp)
  801d05:	89 d6                	mov    %edx,%esi
  801d07:	89 c3                	mov    %eax,%ebx
	      umul_ppmm (m1, m0, q0, d0);
  801d09:	f7 e5                	mul    %ebp

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801d0b:	39 d6                	cmp    %edx,%esi
  801d0d:	72 19                	jb     801d28 <__udivdi3+0xfc>
  801d0f:	74 0b                	je     801d1c <__udivdi3+0xf0>
  801d11:	89 d8                	mov    %ebx,%eax
  801d13:	31 ff                	xor    %edi,%edi
  801d15:	e9 58 ff ff ff       	jmp    801c72 <__udivdi3+0x46>
  801d1a:	66 90                	xchg   %ax,%ax
  801d1c:	8b 54 24 08          	mov    0x8(%esp),%edx
  801d20:	89 f9                	mov    %edi,%ecx
  801d22:	d3 e2                	shl    %cl,%edx
  801d24:	39 c2                	cmp    %eax,%edx
  801d26:	73 e9                	jae    801d11 <__udivdi3+0xe5>
  801d28:	8d 43 ff             	lea    -0x1(%ebx),%eax
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801d2b:	31 ff                	xor    %edi,%edi
  801d2d:	e9 40 ff ff ff       	jmp    801c72 <__udivdi3+0x46>
  801d32:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801d34:	31 c0                	xor    %eax,%eax
  801d36:	e9 37 ff ff ff       	jmp    801c72 <__udivdi3+0x46>
  801d3b:	90                   	nop

00801d3c <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  801d3c:	55                   	push   %ebp
  801d3d:	57                   	push   %edi
  801d3e:	56                   	push   %esi
  801d3f:	53                   	push   %ebx
  801d40:	83 ec 1c             	sub    $0x1c,%esp
  801d43:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801d47:	8b 74 24 34          	mov    0x34(%esp),%esi
  801d4b:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801d4f:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801d53:	89 44 24 0c          	mov    %eax,0xc(%esp)
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801d57:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801d5b:	89 f3                	mov    %esi,%ebx
  const DWunion dd = {.ll = d};
  801d5d:	89 fa                	mov    %edi,%edx
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  801d5f:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  n1 = nn.s.high;
  801d63:	89 34 24             	mov    %esi,(%esp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801d66:	85 c0                	test   %eax,%eax
  801d68:	75 1a                	jne    801d84 <__umoddi3+0x48>
    {
      if (d0 > n1)
  801d6a:	39 f7                	cmp    %esi,%edi
  801d6c:	0f 86 a2 00 00 00    	jbe    801e14 <__umoddi3+0xd8>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801d72:	89 c8                	mov    %ecx,%eax
  801d74:	89 f2                	mov    %esi,%edx
  801d76:	f7 f7                	div    %edi
  801d78:	89 d0                	mov    %edx,%eax

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  801d7a:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801d7c:	83 c4 1c             	add    $0x1c,%esp
  801d7f:	5b                   	pop    %ebx
  801d80:	5e                   	pop    %esi
  801d81:	5f                   	pop    %edi
  801d82:	5d                   	pop    %ebp
  801d83:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801d84:	39 f0                	cmp    %esi,%eax
  801d86:	0f 87 ac 00 00 00    	ja     801e38 <__umoddi3+0xfc>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801d8c:	0f bd e8             	bsr    %eax,%ebp
	  if (bm == 0)
  801d8f:	83 f5 1f             	xor    $0x1f,%ebp
  801d92:	0f 84 ac 00 00 00    	je     801e44 <__umoddi3+0x108>
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801d98:	bf 20 00 00 00       	mov    $0x20,%edi
  801d9d:	29 ef                	sub    %ebp,%edi
  801d9f:	89 fe                	mov    %edi,%esi
  801da1:	89 7c 24 0c          	mov    %edi,0xc(%esp)

	      d1 = (d1 << bm) | (d0 >> b);
  801da5:	89 e9                	mov    %ebp,%ecx
  801da7:	d3 e0                	shl    %cl,%eax
  801da9:	89 d7                	mov    %edx,%edi
  801dab:	89 f1                	mov    %esi,%ecx
  801dad:	d3 ef                	shr    %cl,%edi
  801daf:	09 c7                	or     %eax,%edi
	      d0 = d0 << bm;
  801db1:	89 e9                	mov    %ebp,%ecx
  801db3:	d3 e2                	shl    %cl,%edx
  801db5:	89 14 24             	mov    %edx,(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801db8:	89 d8                	mov    %ebx,%eax
  801dba:	d3 e0                	shl    %cl,%eax
  801dbc:	89 c2                	mov    %eax,%edx
	      n0 = n0 << bm;
  801dbe:	8b 44 24 08          	mov    0x8(%esp),%eax
  801dc2:	d3 e0                	shl    %cl,%eax
  801dc4:	89 44 24 04          	mov    %eax,0x4(%esp)

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801dc8:	8b 44 24 08          	mov    0x8(%esp),%eax
  801dcc:	89 f1                	mov    %esi,%ecx
  801dce:	d3 e8                	shr    %cl,%eax
  801dd0:	09 d0                	or     %edx,%eax
  801dd2:	d3 eb                	shr    %cl,%ebx
  801dd4:	89 da                	mov    %ebx,%edx
  801dd6:	f7 f7                	div    %edi
  801dd8:	89 d3                	mov    %edx,%ebx
	      umul_ppmm (m1, m0, q0, d0);
  801dda:	f7 24 24             	mull   (%esp)
  801ddd:	89 c6                	mov    %eax,%esi
  801ddf:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801de1:	39 d3                	cmp    %edx,%ebx
  801de3:	0f 82 87 00 00 00    	jb     801e70 <__umoddi3+0x134>
  801de9:	0f 84 91 00 00 00    	je     801e80 <__umoddi3+0x144>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  801def:	8b 54 24 04          	mov    0x4(%esp),%edx
  801df3:	29 f2                	sub    %esi,%edx
  801df5:	19 cb                	sbb    %ecx,%ebx
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801df7:	89 d8                	mov    %ebx,%eax
  801df9:	8a 4c 24 0c          	mov    0xc(%esp),%cl
  801dfd:	d3 e0                	shl    %cl,%eax
  801dff:	89 e9                	mov    %ebp,%ecx
  801e01:	d3 ea                	shr    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  801e03:	09 d0                	or     %edx,%eax
  801e05:	89 e9                	mov    %ebp,%ecx
  801e07:	d3 eb                	shr    %cl,%ebx
  801e09:	89 da                	mov    %ebx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801e0b:	83 c4 1c             	add    $0x1c,%esp
  801e0e:	5b                   	pop    %ebx
  801e0f:	5e                   	pop    %esi
  801e10:	5f                   	pop    %edi
  801e11:	5d                   	pop    %ebp
  801e12:	c3                   	ret    
  801e13:	90                   	nop
  801e14:	89 fd                	mov    %edi,%ebp
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801e16:	85 ff                	test   %edi,%edi
  801e18:	75 0b                	jne    801e25 <__umoddi3+0xe9>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801e1a:	b8 01 00 00 00       	mov    $0x1,%eax
  801e1f:	31 d2                	xor    %edx,%edx
  801e21:	f7 f7                	div    %edi
  801e23:	89 c5                	mov    %eax,%ebp

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801e25:	89 f0                	mov    %esi,%eax
  801e27:	31 d2                	xor    %edx,%edx
  801e29:	f7 f5                	div    %ebp
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801e2b:	89 c8                	mov    %ecx,%eax
  801e2d:	f7 f5                	div    %ebp
  801e2f:	89 d0                	mov    %edx,%eax
  801e31:	e9 44 ff ff ff       	jmp    801d7a <__umoddi3+0x3e>
  801e36:	66 90                	xchg   %ax,%ax
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  801e38:	89 c8                	mov    %ecx,%eax
  801e3a:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801e3c:	83 c4 1c             	add    $0x1c,%esp
  801e3f:	5b                   	pop    %ebx
  801e40:	5e                   	pop    %esi
  801e41:	5f                   	pop    %edi
  801e42:	5d                   	pop    %ebp
  801e43:	c3                   	ret    

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801e44:	3b 04 24             	cmp    (%esp),%eax
  801e47:	72 06                	jb     801e4f <__umoddi3+0x113>
  801e49:	3b 7c 24 04          	cmp    0x4(%esp),%edi
  801e4d:	77 0f                	ja     801e5e <__umoddi3+0x122>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801e4f:	89 f2                	mov    %esi,%edx
  801e51:	29 f9                	sub    %edi,%ecx
  801e53:	1b 54 24 0c          	sbb    0xc(%esp),%edx
  801e57:	89 14 24             	mov    %edx,(%esp)
  801e5a:	89 4c 24 04          	mov    %ecx,0x4(%esp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  801e5e:	8b 44 24 04          	mov    0x4(%esp),%eax
  801e62:	8b 14 24             	mov    (%esp),%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801e65:	83 c4 1c             	add    $0x1c,%esp
  801e68:	5b                   	pop    %ebx
  801e69:	5e                   	pop    %esi
  801e6a:	5f                   	pop    %edi
  801e6b:	5d                   	pop    %ebp
  801e6c:	c3                   	ret    
  801e6d:	8d 76 00             	lea    0x0(%esi),%esi
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801e70:	2b 04 24             	sub    (%esp),%eax
  801e73:	19 fa                	sbb    %edi,%edx
  801e75:	89 d1                	mov    %edx,%ecx
  801e77:	89 c6                	mov    %eax,%esi
  801e79:	e9 71 ff ff ff       	jmp    801def <__umoddi3+0xb3>
  801e7e:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801e80:	39 44 24 04          	cmp    %eax,0x4(%esp)
  801e84:	72 ea                	jb     801e70 <__umoddi3+0x134>
  801e86:	89 d9                	mov    %ebx,%ecx
  801e88:	e9 62 ff ff ff       	jmp    801def <__umoddi3+0xb3>
