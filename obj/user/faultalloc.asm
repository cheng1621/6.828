
obj/user/faultalloc.debug:     file format elf32-i386


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
  80002c:	e8 99 00 00 00       	call   8000ca <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 0c             	sub    $0xc,%esp
	int r;
	void *addr = (void*)utf->utf_fault_va;
  80003a:	8b 45 08             	mov    0x8(%ebp),%eax
  80003d:	8b 18                	mov    (%eax),%ebx

	cprintf("fault %x\n", addr);
  80003f:	53                   	push   %ebx
  800040:	68 60 1f 80 00       	push   $0x801f60
  800045:	e8 c1 01 00 00       	call   80020b <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  80004a:	83 c4 0c             	add    $0xc,%esp
  80004d:	6a 07                	push   $0x7
  80004f:	89 d8                	mov    %ebx,%eax
  800051:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800056:	50                   	push   %eax
  800057:	6a 00                	push   $0x0
  800059:	e8 02 0c 00 00       	call   800c60 <sys_page_alloc>
  80005e:	83 c4 10             	add    $0x10,%esp
  800061:	85 c0                	test   %eax,%eax
  800063:	79 16                	jns    80007b <handler+0x48>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
  800065:	83 ec 0c             	sub    $0xc,%esp
  800068:	50                   	push   %eax
  800069:	53                   	push   %ebx
  80006a:	68 80 1f 80 00       	push   $0x801f80
  80006f:	6a 0e                	push   $0xe
  800071:	68 6a 1f 80 00       	push   $0x801f6a
  800076:	e8 b8 00 00 00       	call   800133 <_panic>
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  80007b:	53                   	push   %ebx
  80007c:	68 ac 1f 80 00       	push   $0x801fac
  800081:	6a 64                	push   $0x64
  800083:	53                   	push   %ebx
  800084:	e8 f6 06 00 00       	call   80077f <snprintf>
}
  800089:	83 c4 10             	add    $0x10,%esp
  80008c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80008f:	c9                   	leave  
  800090:	c3                   	ret    

00800091 <umain>:

void
umain(int argc, char **argv)
{
  800091:	55                   	push   %ebp
  800092:	89 e5                	mov    %esp,%ebp
  800094:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(handler);
  800097:	68 33 00 80 00       	push   $0x800033
  80009c:	e8 b0 0d 00 00       	call   800e51 <set_pgfault_handler>
	cprintf("%s\n", (char*)0xDeadBeef);
  8000a1:	83 c4 08             	add    $0x8,%esp
  8000a4:	68 ef be ad de       	push   $0xdeadbeef
  8000a9:	68 7c 1f 80 00       	push   $0x801f7c
  8000ae:	e8 58 01 00 00       	call   80020b <cprintf>
	cprintf("%s\n", (char*)0xCafeBffe);
  8000b3:	83 c4 08             	add    $0x8,%esp
  8000b6:	68 fe bf fe ca       	push   $0xcafebffe
  8000bb:	68 7c 1f 80 00       	push   $0x801f7c
  8000c0:	e8 46 01 00 00       	call   80020b <cprintf>
}
  8000c5:	83 c4 10             	add    $0x10,%esp
  8000c8:	c9                   	leave  
  8000c9:	c3                   	ret    

008000ca <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000ca:	55                   	push   %ebp
  8000cb:	89 e5                	mov    %esp,%ebp
  8000cd:	56                   	push   %esi
  8000ce:	53                   	push   %ebx
  8000cf:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000d2:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8000d5:	e8 48 0b 00 00       	call   800c22 <sys_getenvid>
  8000da:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000df:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8000e6:	c1 e0 07             	shl    $0x7,%eax
  8000e9:	29 d0                	sub    %edx,%eax
  8000eb:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000f0:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000f5:	85 db                	test   %ebx,%ebx
  8000f7:	7e 07                	jle    800100 <libmain+0x36>
		binaryname = argv[0];
  8000f9:	8b 06                	mov    (%esi),%eax
  8000fb:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800100:	83 ec 08             	sub    $0x8,%esp
  800103:	56                   	push   %esi
  800104:	53                   	push   %ebx
  800105:	e8 87 ff ff ff       	call   800091 <umain>

	// exit gracefully
	exit();
  80010a:	e8 0a 00 00 00       	call   800119 <exit>
}
  80010f:	83 c4 10             	add    $0x10,%esp
  800112:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800115:	5b                   	pop    %ebx
  800116:	5e                   	pop    %esi
  800117:	5d                   	pop    %ebp
  800118:	c3                   	ret    

00800119 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800119:	55                   	push   %ebp
  80011a:	89 e5                	mov    %esp,%ebp
  80011c:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80011f:	e8 da 0f 00 00       	call   8010fe <close_all>
	sys_env_destroy(0);
  800124:	83 ec 0c             	sub    $0xc,%esp
  800127:	6a 00                	push   $0x0
  800129:	e8 b3 0a 00 00       	call   800be1 <sys_env_destroy>
}
  80012e:	83 c4 10             	add    $0x10,%esp
  800131:	c9                   	leave  
  800132:	c3                   	ret    

00800133 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800133:	55                   	push   %ebp
  800134:	89 e5                	mov    %esp,%ebp
  800136:	56                   	push   %esi
  800137:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800138:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80013b:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800141:	e8 dc 0a 00 00       	call   800c22 <sys_getenvid>
  800146:	83 ec 0c             	sub    $0xc,%esp
  800149:	ff 75 0c             	pushl  0xc(%ebp)
  80014c:	ff 75 08             	pushl  0x8(%ebp)
  80014f:	56                   	push   %esi
  800150:	50                   	push   %eax
  800151:	68 d8 1f 80 00       	push   $0x801fd8
  800156:	e8 b0 00 00 00       	call   80020b <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80015b:	83 c4 18             	add    $0x18,%esp
  80015e:	53                   	push   %ebx
  80015f:	ff 75 10             	pushl  0x10(%ebp)
  800162:	e8 53 00 00 00       	call   8001ba <vcprintf>
	cprintf("\n");
  800167:	c7 04 24 18 24 80 00 	movl   $0x802418,(%esp)
  80016e:	e8 98 00 00 00       	call   80020b <cprintf>
  800173:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800176:	cc                   	int3   
  800177:	eb fd                	jmp    800176 <_panic+0x43>

00800179 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800179:	55                   	push   %ebp
  80017a:	89 e5                	mov    %esp,%ebp
  80017c:	53                   	push   %ebx
  80017d:	83 ec 04             	sub    $0x4,%esp
  800180:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800183:	8b 13                	mov    (%ebx),%edx
  800185:	8d 42 01             	lea    0x1(%edx),%eax
  800188:	89 03                	mov    %eax,(%ebx)
  80018a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80018d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800191:	3d ff 00 00 00       	cmp    $0xff,%eax
  800196:	75 1a                	jne    8001b2 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800198:	83 ec 08             	sub    $0x8,%esp
  80019b:	68 ff 00 00 00       	push   $0xff
  8001a0:	8d 43 08             	lea    0x8(%ebx),%eax
  8001a3:	50                   	push   %eax
  8001a4:	e8 fb 09 00 00       	call   800ba4 <sys_cputs>
		b->idx = 0;
  8001a9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001af:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001b2:	ff 43 04             	incl   0x4(%ebx)
}
  8001b5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001b8:	c9                   	leave  
  8001b9:	c3                   	ret    

008001ba <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001ba:	55                   	push   %ebp
  8001bb:	89 e5                	mov    %esp,%ebp
  8001bd:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001c3:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001ca:	00 00 00 
	b.cnt = 0;
  8001cd:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001d4:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001d7:	ff 75 0c             	pushl  0xc(%ebp)
  8001da:	ff 75 08             	pushl  0x8(%ebp)
  8001dd:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001e3:	50                   	push   %eax
  8001e4:	68 79 01 80 00       	push   $0x800179
  8001e9:	e8 54 01 00 00       	call   800342 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001ee:	83 c4 08             	add    $0x8,%esp
  8001f1:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001f7:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001fd:	50                   	push   %eax
  8001fe:	e8 a1 09 00 00       	call   800ba4 <sys_cputs>

	return b.cnt;
}
  800203:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800209:	c9                   	leave  
  80020a:	c3                   	ret    

0080020b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80020b:	55                   	push   %ebp
  80020c:	89 e5                	mov    %esp,%ebp
  80020e:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800211:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800214:	50                   	push   %eax
  800215:	ff 75 08             	pushl  0x8(%ebp)
  800218:	e8 9d ff ff ff       	call   8001ba <vcprintf>
	va_end(ap);

	return cnt;
}
  80021d:	c9                   	leave  
  80021e:	c3                   	ret    

0080021f <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80021f:	55                   	push   %ebp
  800220:	89 e5                	mov    %esp,%ebp
  800222:	57                   	push   %edi
  800223:	56                   	push   %esi
  800224:	53                   	push   %ebx
  800225:	83 ec 1c             	sub    $0x1c,%esp
  800228:	89 c6                	mov    %eax,%esi
  80022a:	89 d7                	mov    %edx,%edi
  80022c:	8b 45 08             	mov    0x8(%ebp),%eax
  80022f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800232:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800235:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800238:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80023b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800240:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800243:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800246:	39 d3                	cmp    %edx,%ebx
  800248:	72 11                	jb     80025b <printnum+0x3c>
  80024a:	39 45 10             	cmp    %eax,0x10(%ebp)
  80024d:	76 0c                	jbe    80025b <printnum+0x3c>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80024f:	8b 45 14             	mov    0x14(%ebp),%eax
  800252:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800255:	85 db                	test   %ebx,%ebx
  800257:	7f 37                	jg     800290 <printnum+0x71>
  800259:	eb 44                	jmp    80029f <printnum+0x80>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80025b:	83 ec 0c             	sub    $0xc,%esp
  80025e:	ff 75 18             	pushl  0x18(%ebp)
  800261:	8b 45 14             	mov    0x14(%ebp),%eax
  800264:	48                   	dec    %eax
  800265:	50                   	push   %eax
  800266:	ff 75 10             	pushl  0x10(%ebp)
  800269:	83 ec 08             	sub    $0x8,%esp
  80026c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80026f:	ff 75 e0             	pushl  -0x20(%ebp)
  800272:	ff 75 dc             	pushl  -0x24(%ebp)
  800275:	ff 75 d8             	pushl  -0x28(%ebp)
  800278:	e8 7f 1a 00 00       	call   801cfc <__udivdi3>
  80027d:	83 c4 18             	add    $0x18,%esp
  800280:	52                   	push   %edx
  800281:	50                   	push   %eax
  800282:	89 fa                	mov    %edi,%edx
  800284:	89 f0                	mov    %esi,%eax
  800286:	e8 94 ff ff ff       	call   80021f <printnum>
  80028b:	83 c4 20             	add    $0x20,%esp
  80028e:	eb 0f                	jmp    80029f <printnum+0x80>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800290:	83 ec 08             	sub    $0x8,%esp
  800293:	57                   	push   %edi
  800294:	ff 75 18             	pushl  0x18(%ebp)
  800297:	ff d6                	call   *%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800299:	83 c4 10             	add    $0x10,%esp
  80029c:	4b                   	dec    %ebx
  80029d:	75 f1                	jne    800290 <printnum+0x71>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80029f:	83 ec 08             	sub    $0x8,%esp
  8002a2:	57                   	push   %edi
  8002a3:	83 ec 04             	sub    $0x4,%esp
  8002a6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002a9:	ff 75 e0             	pushl  -0x20(%ebp)
  8002ac:	ff 75 dc             	pushl  -0x24(%ebp)
  8002af:	ff 75 d8             	pushl  -0x28(%ebp)
  8002b2:	e8 55 1b 00 00       	call   801e0c <__umoddi3>
  8002b7:	83 c4 14             	add    $0x14,%esp
  8002ba:	0f be 80 fb 1f 80 00 	movsbl 0x801ffb(%eax),%eax
  8002c1:	50                   	push   %eax
  8002c2:	ff d6                	call   *%esi
}
  8002c4:	83 c4 10             	add    $0x10,%esp
  8002c7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ca:	5b                   	pop    %ebx
  8002cb:	5e                   	pop    %esi
  8002cc:	5f                   	pop    %edi
  8002cd:	5d                   	pop    %ebp
  8002ce:	c3                   	ret    

008002cf <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002cf:	55                   	push   %ebp
  8002d0:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002d2:	83 fa 01             	cmp    $0x1,%edx
  8002d5:	7e 0e                	jle    8002e5 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002d7:	8b 10                	mov    (%eax),%edx
  8002d9:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002dc:	89 08                	mov    %ecx,(%eax)
  8002de:	8b 02                	mov    (%edx),%eax
  8002e0:	8b 52 04             	mov    0x4(%edx),%edx
  8002e3:	eb 22                	jmp    800307 <getuint+0x38>
	else if (lflag)
  8002e5:	85 d2                	test   %edx,%edx
  8002e7:	74 10                	je     8002f9 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002e9:	8b 10                	mov    (%eax),%edx
  8002eb:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002ee:	89 08                	mov    %ecx,(%eax)
  8002f0:	8b 02                	mov    (%edx),%eax
  8002f2:	ba 00 00 00 00       	mov    $0x0,%edx
  8002f7:	eb 0e                	jmp    800307 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002f9:	8b 10                	mov    (%eax),%edx
  8002fb:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002fe:	89 08                	mov    %ecx,(%eax)
  800300:	8b 02                	mov    (%edx),%eax
  800302:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800307:	5d                   	pop    %ebp
  800308:	c3                   	ret    

00800309 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800309:	55                   	push   %ebp
  80030a:	89 e5                	mov    %esp,%ebp
  80030c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80030f:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800312:	8b 10                	mov    (%eax),%edx
  800314:	3b 50 04             	cmp    0x4(%eax),%edx
  800317:	73 0a                	jae    800323 <sprintputch+0x1a>
		*b->buf++ = ch;
  800319:	8d 4a 01             	lea    0x1(%edx),%ecx
  80031c:	89 08                	mov    %ecx,(%eax)
  80031e:	8b 45 08             	mov    0x8(%ebp),%eax
  800321:	88 02                	mov    %al,(%edx)
}
  800323:	5d                   	pop    %ebp
  800324:	c3                   	ret    

00800325 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800325:	55                   	push   %ebp
  800326:	89 e5                	mov    %esp,%ebp
  800328:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80032b:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80032e:	50                   	push   %eax
  80032f:	ff 75 10             	pushl  0x10(%ebp)
  800332:	ff 75 0c             	pushl  0xc(%ebp)
  800335:	ff 75 08             	pushl  0x8(%ebp)
  800338:	e8 05 00 00 00       	call   800342 <vprintfmt>
	va_end(ap);
}
  80033d:	83 c4 10             	add    $0x10,%esp
  800340:	c9                   	leave  
  800341:	c3                   	ret    

00800342 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800342:	55                   	push   %ebp
  800343:	89 e5                	mov    %esp,%ebp
  800345:	57                   	push   %edi
  800346:	56                   	push   %esi
  800347:	53                   	push   %ebx
  800348:	83 ec 2c             	sub    $0x2c,%esp
  80034b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80034e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800351:	eb 03                	jmp    800356 <vprintfmt+0x14>
			break;

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
			for (fmt--; fmt[-1] != '%'; fmt--)
  800353:	89 75 10             	mov    %esi,0x10(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {    //遍历输入的第一个参数，即输出信息的格式，先把格式字符串中'%'之前的字符一个个输出，因为它们前面没有'%'，所以它们就是要直接显示在屏幕上的
  800356:	8b 45 10             	mov    0x10(%ebp),%eax
  800359:	8d 70 01             	lea    0x1(%eax),%esi
  80035c:	0f b6 00             	movzbl (%eax),%eax
  80035f:	83 f8 25             	cmp    $0x25,%eax
  800362:	74 25                	je     800389 <vprintfmt+0x47>
			if (ch == '\0')									//当然中间如果遇到'\0'，代表这个字符串的访问结束
  800364:	85 c0                	test   %eax,%eax
  800366:	75 0d                	jne    800375 <vprintfmt+0x33>
  800368:	e9 b5 03 00 00       	jmp    800722 <vprintfmt+0x3e0>
  80036d:	85 c0                	test   %eax,%eax
  80036f:	0f 84 ad 03 00 00    	je     800722 <vprintfmt+0x3e0>
				return;
			putch(ch, putdat);								//调用putch函数，把一个字符ch输出到putdat指针所指向的地址中所存放的值对应的地址处
  800375:	83 ec 08             	sub    $0x8,%esp
  800378:	53                   	push   %ebx
  800379:	50                   	push   %eax
  80037a:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {    //遍历输入的第一个参数，即输出信息的格式，先把格式字符串中'%'之前的字符一个个输出，因为它们前面没有'%'，所以它们就是要直接显示在屏幕上的
  80037c:	46                   	inc    %esi
  80037d:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  800381:	83 c4 10             	add    $0x10,%esp
  800384:	83 f8 25             	cmp    $0x25,%eax
  800387:	75 e4                	jne    80036d <vprintfmt+0x2b>
			if (width < 0)									//代表有小数点，但是小数点前面并没有数字，比如'%.6f'这种情况，此时代表整数部分全部显示
				width = 0;			
			goto reswitch;

		case '#':
			altflag = 1;
  800389:	c6 45 e3 20          	movb   $0x20,-0x1d(%ebp)
  80038d:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800394:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80039b:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8003a2:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8003a9:	eb 07                	jmp    8003b2 <vprintfmt+0x70>
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  8003ab:	8b 75 10             	mov    0x10(%ebp),%esi

		// flag to pad on the right
		case '-':											//%后面的'-'代表要进行左对齐输出，右边填空格，如果省略代表右对齐
			padc = '-';										//如果有这个字符代表左对齐，则把对齐方式标志位变为'-'
  8003ae:	c6 45 e3 2d          	movb   $0x2d,-0x1d(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  8003b2:	8d 46 01             	lea    0x1(%esi),%eax
  8003b5:	89 45 10             	mov    %eax,0x10(%ebp)
  8003b8:	0f b6 16             	movzbl (%esi),%edx
  8003bb:	8a 06                	mov    (%esi),%al
  8003bd:	83 e8 23             	sub    $0x23,%eax
  8003c0:	3c 55                	cmp    $0x55,%al
  8003c2:	0f 87 03 03 00 00    	ja     8006cb <vprintfmt+0x389>
  8003c8:	0f b6 c0             	movzbl %al,%eax
  8003cb:	ff 24 85 40 21 80 00 	jmp    *0x802140(,%eax,4)
  8003d2:	8b 75 10             	mov    0x10(%ebp),%esi
			padc = '-';										//如果有这个字符代表左对齐，则把对齐方式标志位变为'-'
			goto reswitch;									//处理下一个字符

		// flag to pad with 0's instead of spaces
		case '0':											//0--有0表示进行对齐输出时填0,如省略表示填入空格，并且如果为0，则一定是右对齐
			padc = '0';										//对其方式标志位变为0
  8003d5:	c6 45 e3 30          	movb   $0x30,-0x1d(%ebp)
  8003d9:	eb d7                	jmp    8003b2 <vprintfmt+0x70>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {					//把遇到的位数字符串转换为真实的位数，比如输入的'%40'，代表有效位数为40位，下面的循环就是把precesion的值设置为40
				precision = precision * 10 + ch - '0';
  8003db:	8d 42 d0             	lea    -0x30(%edx),%eax
  8003de:	89 c1                	mov    %eax,%ecx
  8003e0:	89 45 d0             	mov    %eax,-0x30(%ebp)
				ch = *fmt;
  8003e3:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  8003e7:	8d 50 d0             	lea    -0x30(%eax),%edx
  8003ea:	83 fa 09             	cmp    $0x9,%edx
  8003ed:	77 51                	ja     800440 <vprintfmt+0xfe>
  8003ef:	8b 75 10             	mov    0x10(%ebp),%esi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {					//把遇到的位数字符串转换为真实的位数，比如输入的'%40'，代表有效位数为40位，下面的循环就是把precesion的值设置为40
  8003f2:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  8003f3:	8d 14 89             	lea    (%ecx,%ecx,4),%edx
  8003f6:	01 d2                	add    %edx,%edx
  8003f8:	8d 4c 10 d0          	lea    -0x30(%eax,%edx,1),%ecx
				ch = *fmt;
  8003fc:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8003ff:	8d 50 d0             	lea    -0x30(%eax),%edx
  800402:	83 fa 09             	cmp    $0x9,%edx
  800405:	76 eb                	jbe    8003f2 <vprintfmt+0xb0>
  800407:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  80040a:	eb 37                	jmp    800443 <vprintfmt+0x101>
					break;
			}
			goto process_precision;							//跳转到process_precistion子过程

		case '*':											//*--代表有效数字的位数也是由输入参数指定的，比如printf("%*.*f", 10, 2, n)，其中10,2就是用来指定显示的有效数字位数的
			precision = va_arg(ap, int);
  80040c:	8b 45 14             	mov    0x14(%ebp),%eax
  80040f:	8d 50 04             	lea    0x4(%eax),%edx
  800412:	89 55 14             	mov    %edx,0x14(%ebp)
  800415:	8b 00                	mov    (%eax),%eax
  800417:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  80041a:	8b 75 10             	mov    0x10(%ebp),%esi
			}
			goto process_precision;							//跳转到process_precistion子过程

		case '*':											//*--代表有效数字的位数也是由输入参数指定的，比如printf("%*.*f", 10, 2, n)，其中10,2就是用来指定显示的有效数字位数的
			precision = va_arg(ap, int);
			goto process_precision;
  80041d:	eb 24                	jmp    800443 <vprintfmt+0x101>
  80041f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800423:	79 07                	jns    80042c <vprintfmt+0xea>
  800425:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  80042c:	8b 75 10             	mov    0x10(%ebp),%esi
  80042f:	eb 81                	jmp    8003b2 <vprintfmt+0x70>
  800431:	8b 75 10             	mov    0x10(%ebp),%esi
			if (width < 0)									//代表有小数点，但是小数点前面并没有数字，比如'%.6f'这种情况，此时代表整数部分全部显示
				width = 0;			
			goto reswitch;

		case '#':
			altflag = 1;
  800434:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80043b:	e9 72 ff ff ff       	jmp    8003b2 <vprintfmt+0x70>
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  800440:	8b 75 10             	mov    0x10(%ebp),%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:									//处理输出精度，把width字段赋值为刚刚计算出来的precision值，所以width应该是整数部分的有效数字位数
			if (width < 0)
  800443:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800447:	0f 89 65 ff ff ff    	jns    8003b2 <vprintfmt+0x70>
				width = precision, precision = -1;
  80044d:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800450:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800453:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80045a:	e9 53 ff ff ff       	jmp    8003b2 <vprintfmt+0x70>
			goto reswitch;

		// long flag (doubled for long long)				
		case 'l':											//如果遇到'l'，代表应该是输入long类型，如果有两个'l'代表long long
			lflag++;										//此时把lflag++
  80045f:	ff 45 d4             	incl   -0x2c(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  800462:	8b 75 10             	mov    0x10(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)				
		case 'l':											//如果遇到'l'，代表应该是输入long类型，如果有两个'l'代表long long
			lflag++;										//此时把lflag++
			goto reswitch;
  800465:	e9 48 ff ff ff       	jmp    8003b2 <vprintfmt+0x70>

		// character
		case 'c':											//如果是'c'代表显示一个字符
			putch(va_arg(ap, int), putdat);					//调用输出一个字符到内存的函数putch
  80046a:	8b 45 14             	mov    0x14(%ebp),%eax
  80046d:	8d 50 04             	lea    0x4(%eax),%edx
  800470:	89 55 14             	mov    %edx,0x14(%ebp)
  800473:	83 ec 08             	sub    $0x8,%esp
  800476:	53                   	push   %ebx
  800477:	ff 30                	pushl  (%eax)
  800479:	ff d7                	call   *%edi
			break;
  80047b:	83 c4 10             	add    $0x10,%esp
  80047e:	e9 d3 fe ff ff       	jmp    800356 <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800483:	8b 45 14             	mov    0x14(%ebp),%eax
  800486:	8d 50 04             	lea    0x4(%eax),%edx
  800489:	89 55 14             	mov    %edx,0x14(%ebp)
  80048c:	8b 00                	mov    (%eax),%eax
  80048e:	85 c0                	test   %eax,%eax
  800490:	79 02                	jns    800494 <vprintfmt+0x152>
  800492:	f7 d8                	neg    %eax
  800494:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800496:	83 f8 0f             	cmp    $0xf,%eax
  800499:	7f 0b                	jg     8004a6 <vprintfmt+0x164>
  80049b:	8b 04 85 a0 22 80 00 	mov    0x8022a0(,%eax,4),%eax
  8004a2:	85 c0                	test   %eax,%eax
  8004a4:	75 15                	jne    8004bb <vprintfmt+0x179>
				printfmt(putch, putdat, "error %d", err);
  8004a6:	52                   	push   %edx
  8004a7:	68 13 20 80 00       	push   $0x802013
  8004ac:	53                   	push   %ebx
  8004ad:	57                   	push   %edi
  8004ae:	e8 72 fe ff ff       	call   800325 <printfmt>
  8004b3:	83 c4 10             	add    $0x10,%esp
  8004b6:	e9 9b fe ff ff       	jmp    800356 <vprintfmt+0x14>
			else
				printfmt(putch, putdat, "%s", p);
  8004bb:	50                   	push   %eax
  8004bc:	68 e6 23 80 00       	push   $0x8023e6
  8004c1:	53                   	push   %ebx
  8004c2:	57                   	push   %edi
  8004c3:	e8 5d fe ff ff       	call   800325 <printfmt>
  8004c8:	83 c4 10             	add    $0x10,%esp
  8004cb:	e9 86 fe ff ff       	jmp    800356 <vprintfmt+0x14>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d3:	8d 50 04             	lea    0x4(%eax),%edx
  8004d6:	89 55 14             	mov    %edx,0x14(%ebp)
  8004d9:	8b 00                	mov    (%eax),%eax
  8004db:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8004de:	85 c0                	test   %eax,%eax
  8004e0:	75 07                	jne    8004e9 <vprintfmt+0x1a7>
				p = "(null)";
  8004e2:	c7 45 d4 0c 20 80 00 	movl   $0x80200c,-0x2c(%ebp)
			if (width > 0 && padc != '-')
  8004e9:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8004ec:	85 f6                	test   %esi,%esi
  8004ee:	0f 8e fb 01 00 00    	jle    8006ef <vprintfmt+0x3ad>
  8004f4:	80 7d e3 2d          	cmpb   $0x2d,-0x1d(%ebp)
  8004f8:	0f 84 09 02 00 00    	je     800707 <vprintfmt+0x3c5>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004fe:	83 ec 08             	sub    $0x8,%esp
  800501:	ff 75 d0             	pushl  -0x30(%ebp)
  800504:	ff 75 d4             	pushl  -0x2c(%ebp)
  800507:	e8 ad 02 00 00       	call   8007b9 <strnlen>
  80050c:	89 f1                	mov    %esi,%ecx
  80050e:	29 c1                	sub    %eax,%ecx
  800510:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  800513:	83 c4 10             	add    $0x10,%esp
  800516:	85 c9                	test   %ecx,%ecx
  800518:	0f 8e d1 01 00 00    	jle    8006ef <vprintfmt+0x3ad>
					putch(padc, putdat);
  80051e:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  800522:	83 ec 08             	sub    $0x8,%esp
  800525:	53                   	push   %ebx
  800526:	56                   	push   %esi
  800527:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800529:	83 c4 10             	add    $0x10,%esp
  80052c:	ff 4d e4             	decl   -0x1c(%ebp)
  80052f:	75 f1                	jne    800522 <vprintfmt+0x1e0>
  800531:	e9 b9 01 00 00       	jmp    8006ef <vprintfmt+0x3ad>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800536:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80053a:	74 19                	je     800555 <vprintfmt+0x213>
  80053c:	0f be c0             	movsbl %al,%eax
  80053f:	83 e8 20             	sub    $0x20,%eax
  800542:	83 f8 5e             	cmp    $0x5e,%eax
  800545:	76 0e                	jbe    800555 <vprintfmt+0x213>
					putch('?', putdat);
  800547:	83 ec 08             	sub    $0x8,%esp
  80054a:	53                   	push   %ebx
  80054b:	6a 3f                	push   $0x3f
  80054d:	ff 55 08             	call   *0x8(%ebp)
  800550:	83 c4 10             	add    $0x10,%esp
  800553:	eb 0b                	jmp    800560 <vprintfmt+0x21e>
				else
					putch(ch, putdat);
  800555:	83 ec 08             	sub    $0x8,%esp
  800558:	53                   	push   %ebx
  800559:	52                   	push   %edx
  80055a:	ff 55 08             	call   *0x8(%ebp)
  80055d:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800560:	ff 4d e4             	decl   -0x1c(%ebp)
  800563:	46                   	inc    %esi
  800564:	8a 46 ff             	mov    -0x1(%esi),%al
  800567:	0f be d0             	movsbl %al,%edx
  80056a:	85 d2                	test   %edx,%edx
  80056c:	75 1c                	jne    80058a <vprintfmt+0x248>
  80056e:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800571:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800575:	7f 1f                	jg     800596 <vprintfmt+0x254>
  800577:	e9 da fd ff ff       	jmp    800356 <vprintfmt+0x14>
  80057c:	89 7d 08             	mov    %edi,0x8(%ebp)
  80057f:	8b 7d d0             	mov    -0x30(%ebp),%edi
  800582:	eb 06                	jmp    80058a <vprintfmt+0x248>
  800584:	89 7d 08             	mov    %edi,0x8(%ebp)
  800587:	8b 7d d0             	mov    -0x30(%ebp),%edi
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80058a:	85 ff                	test   %edi,%edi
  80058c:	78 a8                	js     800536 <vprintfmt+0x1f4>
  80058e:	4f                   	dec    %edi
  80058f:	79 a5                	jns    800536 <vprintfmt+0x1f4>
  800591:	8b 7d 08             	mov    0x8(%ebp),%edi
  800594:	eb db                	jmp    800571 <vprintfmt+0x22f>
  800596:	8b 75 e4             	mov    -0x1c(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800599:	83 ec 08             	sub    $0x8,%esp
  80059c:	53                   	push   %ebx
  80059d:	6a 20                	push   $0x20
  80059f:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005a1:	4e                   	dec    %esi
  8005a2:	83 c4 10             	add    $0x10,%esp
  8005a5:	85 f6                	test   %esi,%esi
  8005a7:	7f f0                	jg     800599 <vprintfmt+0x257>
  8005a9:	e9 a8 fd ff ff       	jmp    800356 <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005ae:	83 7d d4 01          	cmpl   $0x1,-0x2c(%ebp)
  8005b2:	7e 16                	jle    8005ca <vprintfmt+0x288>
		return va_arg(*ap, long long);
  8005b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b7:	8d 50 08             	lea    0x8(%eax),%edx
  8005ba:	89 55 14             	mov    %edx,0x14(%ebp)
  8005bd:	8b 50 04             	mov    0x4(%eax),%edx
  8005c0:	8b 00                	mov    (%eax),%eax
  8005c2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005c5:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005c8:	eb 34                	jmp    8005fe <vprintfmt+0x2bc>
	else if (lflag)
  8005ca:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8005ce:	74 18                	je     8005e8 <vprintfmt+0x2a6>
		return va_arg(*ap, long);
  8005d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d3:	8d 50 04             	lea    0x4(%eax),%edx
  8005d6:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d9:	8b 30                	mov    (%eax),%esi
  8005db:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8005de:	89 f0                	mov    %esi,%eax
  8005e0:	c1 f8 1f             	sar    $0x1f,%eax
  8005e3:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8005e6:	eb 16                	jmp    8005fe <vprintfmt+0x2bc>
	else
		return va_arg(*ap, int);
  8005e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005eb:	8d 50 04             	lea    0x4(%eax),%edx
  8005ee:	89 55 14             	mov    %edx,0x14(%ebp)
  8005f1:	8b 30                	mov    (%eax),%esi
  8005f3:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8005f6:	89 f0                	mov    %esi,%eax
  8005f8:	c1 f8 1f             	sar    $0x1f,%eax
  8005fb:	89 45 dc             	mov    %eax,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005fe:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800601:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
  800604:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800608:	0f 89 8a 00 00 00    	jns    800698 <vprintfmt+0x356>
				putch('-', putdat);
  80060e:	83 ec 08             	sub    $0x8,%esp
  800611:	53                   	push   %ebx
  800612:	6a 2d                	push   $0x2d
  800614:	ff d7                	call   *%edi
				num = -(long long) num;
  800616:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800619:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80061c:	f7 d8                	neg    %eax
  80061e:	83 d2 00             	adc    $0x0,%edx
  800621:	f7 da                	neg    %edx
  800623:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800626:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80062b:	eb 70                	jmp    80069d <vprintfmt+0x35b>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80062d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800630:	8d 45 14             	lea    0x14(%ebp),%eax
  800633:	e8 97 fc ff ff       	call   8002cf <getuint>
			base = 10;
  800638:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80063d:	eb 5e                	jmp    80069d <vprintfmt+0x35b>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
  80063f:	83 ec 08             	sub    $0x8,%esp
  800642:	53                   	push   %ebx
  800643:	6a 30                	push   $0x30
  800645:	ff d7                	call   *%edi
			num = getuint(&ap, lflag);
  800647:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80064a:	8d 45 14             	lea    0x14(%ebp),%eax
  80064d:	e8 7d fc ff ff       	call   8002cf <getuint>
			base = 8;
			goto number;
  800652:	83 c4 10             	add    $0x10,%esp
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  800655:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80065a:	eb 41                	jmp    80069d <vprintfmt+0x35b>
		// pointer
		case 'p':
			putch('0', putdat);
  80065c:	83 ec 08             	sub    $0x8,%esp
  80065f:	53                   	push   %ebx
  800660:	6a 30                	push   $0x30
  800662:	ff d7                	call   *%edi
			putch('x', putdat);
  800664:	83 c4 08             	add    $0x8,%esp
  800667:	53                   	push   %ebx
  800668:	6a 78                	push   $0x78
  80066a:	ff d7                	call   *%edi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80066c:	8b 45 14             	mov    0x14(%ebp),%eax
  80066f:	8d 50 04             	lea    0x4(%eax),%edx
  800672:	89 55 14             	mov    %edx,0x14(%ebp)
			goto number;
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800675:	8b 00                	mov    (%eax),%eax
  800677:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80067c:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80067f:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800684:	eb 17                	jmp    80069d <vprintfmt+0x35b>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800686:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800689:	8d 45 14             	lea    0x14(%ebp),%eax
  80068c:	e8 3e fc ff ff       	call   8002cf <getuint>
			base = 16;
  800691:	b9 10 00 00 00       	mov    $0x10,%ecx
  800696:	eb 05                	jmp    80069d <vprintfmt+0x35b>
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800698:	b9 0a 00 00 00       	mov    $0xa,%ecx
		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  80069d:	83 ec 0c             	sub    $0xc,%esp
  8006a0:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  8006a4:	56                   	push   %esi
  8006a5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8006a8:	51                   	push   %ecx
  8006a9:	52                   	push   %edx
  8006aa:	50                   	push   %eax
  8006ab:	89 da                	mov    %ebx,%edx
  8006ad:	89 f8                	mov    %edi,%eax
  8006af:	e8 6b fb ff ff       	call   80021f <printnum>
			break;
  8006b4:	83 c4 20             	add    $0x20,%esp
  8006b7:	e9 9a fc ff ff       	jmp    800356 <vprintfmt+0x14>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006bc:	83 ec 08             	sub    $0x8,%esp
  8006bf:	53                   	push   %ebx
  8006c0:	52                   	push   %edx
  8006c1:	ff d7                	call   *%edi
			break;
  8006c3:	83 c4 10             	add    $0x10,%esp
  8006c6:	e9 8b fc ff ff       	jmp    800356 <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006cb:	83 ec 08             	sub    $0x8,%esp
  8006ce:	53                   	push   %ebx
  8006cf:	6a 25                	push   $0x25
  8006d1:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006d3:	83 c4 10             	add    $0x10,%esp
  8006d6:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8006da:	0f 84 73 fc ff ff    	je     800353 <vprintfmt+0x11>
  8006e0:	4e                   	dec    %esi
  8006e1:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8006e5:	75 f9                	jne    8006e0 <vprintfmt+0x39e>
  8006e7:	89 75 10             	mov    %esi,0x10(%ebp)
  8006ea:	e9 67 fc ff ff       	jmp    800356 <vprintfmt+0x14>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006ef:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8006f2:	8d 70 01             	lea    0x1(%eax),%esi
  8006f5:	8a 00                	mov    (%eax),%al
  8006f7:	0f be d0             	movsbl %al,%edx
  8006fa:	85 d2                	test   %edx,%edx
  8006fc:	0f 85 7a fe ff ff    	jne    80057c <vprintfmt+0x23a>
  800702:	e9 4f fc ff ff       	jmp    800356 <vprintfmt+0x14>
  800707:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80070a:	8d 70 01             	lea    0x1(%eax),%esi
  80070d:	8a 00                	mov    (%eax),%al
  80070f:	0f be d0             	movsbl %al,%edx
  800712:	85 d2                	test   %edx,%edx
  800714:	0f 85 6a fe ff ff    	jne    800584 <vprintfmt+0x242>
  80071a:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80071d:	e9 77 fe ff ff       	jmp    800599 <vprintfmt+0x257>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800722:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800725:	5b                   	pop    %ebx
  800726:	5e                   	pop    %esi
  800727:	5f                   	pop    %edi
  800728:	5d                   	pop    %ebp
  800729:	c3                   	ret    

0080072a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80072a:	55                   	push   %ebp
  80072b:	89 e5                	mov    %esp,%ebp
  80072d:	83 ec 18             	sub    $0x18,%esp
  800730:	8b 45 08             	mov    0x8(%ebp),%eax
  800733:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800736:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800739:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80073d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800740:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800747:	85 c0                	test   %eax,%eax
  800749:	74 26                	je     800771 <vsnprintf+0x47>
  80074b:	85 d2                	test   %edx,%edx
  80074d:	7e 29                	jle    800778 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80074f:	ff 75 14             	pushl  0x14(%ebp)
  800752:	ff 75 10             	pushl  0x10(%ebp)
  800755:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800758:	50                   	push   %eax
  800759:	68 09 03 80 00       	push   $0x800309
  80075e:	e8 df fb ff ff       	call   800342 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800763:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800766:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800769:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80076c:	83 c4 10             	add    $0x10,%esp
  80076f:	eb 0c                	jmp    80077d <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800771:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800776:	eb 05                	jmp    80077d <vsnprintf+0x53>
  800778:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80077d:	c9                   	leave  
  80077e:	c3                   	ret    

0080077f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80077f:	55                   	push   %ebp
  800780:	89 e5                	mov    %esp,%ebp
  800782:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800785:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800788:	50                   	push   %eax
  800789:	ff 75 10             	pushl  0x10(%ebp)
  80078c:	ff 75 0c             	pushl  0xc(%ebp)
  80078f:	ff 75 08             	pushl  0x8(%ebp)
  800792:	e8 93 ff ff ff       	call   80072a <vsnprintf>
	va_end(ap);

	return rc;
}
  800797:	c9                   	leave  
  800798:	c3                   	ret    

00800799 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800799:	55                   	push   %ebp
  80079a:	89 e5                	mov    %esp,%ebp
  80079c:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80079f:	80 3a 00             	cmpb   $0x0,(%edx)
  8007a2:	74 0e                	je     8007b2 <strlen+0x19>
  8007a4:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8007a9:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007aa:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007ae:	75 f9                	jne    8007a9 <strlen+0x10>
  8007b0:	eb 05                	jmp    8007b7 <strlen+0x1e>
  8007b2:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8007b7:	5d                   	pop    %ebp
  8007b8:	c3                   	ret    

008007b9 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007b9:	55                   	push   %ebp
  8007ba:	89 e5                	mov    %esp,%ebp
  8007bc:	53                   	push   %ebx
  8007bd:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8007c0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007c3:	85 c9                	test   %ecx,%ecx
  8007c5:	74 1a                	je     8007e1 <strnlen+0x28>
  8007c7:	80 3b 00             	cmpb   $0x0,(%ebx)
  8007ca:	74 1c                	je     8007e8 <strnlen+0x2f>
  8007cc:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  8007d1:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007d3:	39 ca                	cmp    %ecx,%edx
  8007d5:	74 16                	je     8007ed <strnlen+0x34>
  8007d7:	42                   	inc    %edx
  8007d8:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  8007dd:	75 f2                	jne    8007d1 <strnlen+0x18>
  8007df:	eb 0c                	jmp    8007ed <strnlen+0x34>
  8007e1:	b8 00 00 00 00       	mov    $0x0,%eax
  8007e6:	eb 05                	jmp    8007ed <strnlen+0x34>
  8007e8:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8007ed:	5b                   	pop    %ebx
  8007ee:	5d                   	pop    %ebp
  8007ef:	c3                   	ret    

008007f0 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007f0:	55                   	push   %ebp
  8007f1:	89 e5                	mov    %esp,%ebp
  8007f3:	53                   	push   %ebx
  8007f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007fa:	89 c2                	mov    %eax,%edx
  8007fc:	42                   	inc    %edx
  8007fd:	41                   	inc    %ecx
  8007fe:	8a 59 ff             	mov    -0x1(%ecx),%bl
  800801:	88 5a ff             	mov    %bl,-0x1(%edx)
  800804:	84 db                	test   %bl,%bl
  800806:	75 f4                	jne    8007fc <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800808:	5b                   	pop    %ebx
  800809:	5d                   	pop    %ebp
  80080a:	c3                   	ret    

0080080b <strcat>:

char *
strcat(char *dst, const char *src)
{
  80080b:	55                   	push   %ebp
  80080c:	89 e5                	mov    %esp,%ebp
  80080e:	53                   	push   %ebx
  80080f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800812:	53                   	push   %ebx
  800813:	e8 81 ff ff ff       	call   800799 <strlen>
  800818:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80081b:	ff 75 0c             	pushl  0xc(%ebp)
  80081e:	01 d8                	add    %ebx,%eax
  800820:	50                   	push   %eax
  800821:	e8 ca ff ff ff       	call   8007f0 <strcpy>
	return dst;
}
  800826:	89 d8                	mov    %ebx,%eax
  800828:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80082b:	c9                   	leave  
  80082c:	c3                   	ret    

0080082d <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80082d:	55                   	push   %ebp
  80082e:	89 e5                	mov    %esp,%ebp
  800830:	56                   	push   %esi
  800831:	53                   	push   %ebx
  800832:	8b 75 08             	mov    0x8(%ebp),%esi
  800835:	8b 55 0c             	mov    0xc(%ebp),%edx
  800838:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80083b:	85 db                	test   %ebx,%ebx
  80083d:	74 14                	je     800853 <strncpy+0x26>
  80083f:	01 f3                	add    %esi,%ebx
  800841:	89 f1                	mov    %esi,%ecx
		*dst++ = *src;
  800843:	41                   	inc    %ecx
  800844:	8a 02                	mov    (%edx),%al
  800846:	88 41 ff             	mov    %al,-0x1(%ecx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800849:	80 3a 01             	cmpb   $0x1,(%edx)
  80084c:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80084f:	39 cb                	cmp    %ecx,%ebx
  800851:	75 f0                	jne    800843 <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800853:	89 f0                	mov    %esi,%eax
  800855:	5b                   	pop    %ebx
  800856:	5e                   	pop    %esi
  800857:	5d                   	pop    %ebp
  800858:	c3                   	ret    

00800859 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800859:	55                   	push   %ebp
  80085a:	89 e5                	mov    %esp,%ebp
  80085c:	53                   	push   %ebx
  80085d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800860:	8b 45 10             	mov    0x10(%ebp),%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800863:	85 c0                	test   %eax,%eax
  800865:	74 30                	je     800897 <strlcpy+0x3e>
		while (--size > 0 && *src != '\0')
  800867:	48                   	dec    %eax
  800868:	74 20                	je     80088a <strlcpy+0x31>
  80086a:	8a 0b                	mov    (%ebx),%cl
  80086c:	84 c9                	test   %cl,%cl
  80086e:	74 1f                	je     80088f <strlcpy+0x36>
  800870:	8d 53 01             	lea    0x1(%ebx),%edx
  800873:	01 c3                	add    %eax,%ebx
  800875:	8b 45 08             	mov    0x8(%ebp),%eax
			*dst++ = *src++;
  800878:	40                   	inc    %eax
  800879:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80087c:	39 da                	cmp    %ebx,%edx
  80087e:	74 12                	je     800892 <strlcpy+0x39>
  800880:	42                   	inc    %edx
  800881:	8a 4a ff             	mov    -0x1(%edx),%cl
  800884:	84 c9                	test   %cl,%cl
  800886:	75 f0                	jne    800878 <strlcpy+0x1f>
  800888:	eb 08                	jmp    800892 <strlcpy+0x39>
  80088a:	8b 45 08             	mov    0x8(%ebp),%eax
  80088d:	eb 03                	jmp    800892 <strlcpy+0x39>
  80088f:	8b 45 08             	mov    0x8(%ebp),%eax
			*dst++ = *src++;
		*dst = '\0';
  800892:	c6 00 00             	movb   $0x0,(%eax)
  800895:	eb 03                	jmp    80089a <strlcpy+0x41>
  800897:	8b 45 08             	mov    0x8(%ebp),%eax
	}
	return dst - dst_in;
  80089a:	2b 45 08             	sub    0x8(%ebp),%eax
}
  80089d:	5b                   	pop    %ebx
  80089e:	5d                   	pop    %ebp
  80089f:	c3                   	ret    

008008a0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008a0:	55                   	push   %ebp
  8008a1:	89 e5                	mov    %esp,%ebp
  8008a3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008a6:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008a9:	8a 01                	mov    (%ecx),%al
  8008ab:	84 c0                	test   %al,%al
  8008ad:	74 10                	je     8008bf <strcmp+0x1f>
  8008af:	3a 02                	cmp    (%edx),%al
  8008b1:	75 0c                	jne    8008bf <strcmp+0x1f>
		p++, q++;
  8008b3:	41                   	inc    %ecx
  8008b4:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008b5:	8a 01                	mov    (%ecx),%al
  8008b7:	84 c0                	test   %al,%al
  8008b9:	74 04                	je     8008bf <strcmp+0x1f>
  8008bb:	3a 02                	cmp    (%edx),%al
  8008bd:	74 f4                	je     8008b3 <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008bf:	0f b6 c0             	movzbl %al,%eax
  8008c2:	0f b6 12             	movzbl (%edx),%edx
  8008c5:	29 d0                	sub    %edx,%eax
}
  8008c7:	5d                   	pop    %ebp
  8008c8:	c3                   	ret    

008008c9 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008c9:	55                   	push   %ebp
  8008ca:	89 e5                	mov    %esp,%ebp
  8008cc:	56                   	push   %esi
  8008cd:	53                   	push   %ebx
  8008ce:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8008d1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008d4:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  8008d7:	85 f6                	test   %esi,%esi
  8008d9:	74 23                	je     8008fe <strncmp+0x35>
  8008db:	8a 03                	mov    (%ebx),%al
  8008dd:	84 c0                	test   %al,%al
  8008df:	74 2b                	je     80090c <strncmp+0x43>
  8008e1:	3a 02                	cmp    (%edx),%al
  8008e3:	75 27                	jne    80090c <strncmp+0x43>
  8008e5:	8d 43 01             	lea    0x1(%ebx),%eax
  8008e8:	01 de                	add    %ebx,%esi
		n--, p++, q++;
  8008ea:	89 c3                	mov    %eax,%ebx
  8008ec:	42                   	inc    %edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008ed:	39 c6                	cmp    %eax,%esi
  8008ef:	74 14                	je     800905 <strncmp+0x3c>
  8008f1:	8a 08                	mov    (%eax),%cl
  8008f3:	84 c9                	test   %cl,%cl
  8008f5:	74 15                	je     80090c <strncmp+0x43>
  8008f7:	40                   	inc    %eax
  8008f8:	3a 0a                	cmp    (%edx),%cl
  8008fa:	74 ee                	je     8008ea <strncmp+0x21>
  8008fc:	eb 0e                	jmp    80090c <strncmp+0x43>
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008fe:	b8 00 00 00 00       	mov    $0x0,%eax
  800903:	eb 0f                	jmp    800914 <strncmp+0x4b>
  800905:	b8 00 00 00 00       	mov    $0x0,%eax
  80090a:	eb 08                	jmp    800914 <strncmp+0x4b>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80090c:	0f b6 03             	movzbl (%ebx),%eax
  80090f:	0f b6 12             	movzbl (%edx),%edx
  800912:	29 d0                	sub    %edx,%eax
}
  800914:	5b                   	pop    %ebx
  800915:	5e                   	pop    %esi
  800916:	5d                   	pop    %ebp
  800917:	c3                   	ret    

00800918 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800918:	55                   	push   %ebp
  800919:	89 e5                	mov    %esp,%ebp
  80091b:	53                   	push   %ebx
  80091c:	8b 45 08             	mov    0x8(%ebp),%eax
  80091f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  800922:	8a 10                	mov    (%eax),%dl
  800924:	84 d2                	test   %dl,%dl
  800926:	74 1a                	je     800942 <strchr+0x2a>
  800928:	88 d9                	mov    %bl,%cl
		if (*s == c)
  80092a:	38 d3                	cmp    %dl,%bl
  80092c:	75 06                	jne    800934 <strchr+0x1c>
  80092e:	eb 17                	jmp    800947 <strchr+0x2f>
  800930:	38 ca                	cmp    %cl,%dl
  800932:	74 13                	je     800947 <strchr+0x2f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800934:	40                   	inc    %eax
  800935:	8a 10                	mov    (%eax),%dl
  800937:	84 d2                	test   %dl,%dl
  800939:	75 f5                	jne    800930 <strchr+0x18>
		if (*s == c)
			return (char *) s;
	return 0;
  80093b:	b8 00 00 00 00       	mov    $0x0,%eax
  800940:	eb 05                	jmp    800947 <strchr+0x2f>
  800942:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800947:	5b                   	pop    %ebx
  800948:	5d                   	pop    %ebp
  800949:	c3                   	ret    

0080094a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80094a:	55                   	push   %ebp
  80094b:	89 e5                	mov    %esp,%ebp
  80094d:	53                   	push   %ebx
  80094e:	8b 45 08             	mov    0x8(%ebp),%eax
  800951:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  800954:	8a 10                	mov    (%eax),%dl
  800956:	84 d2                	test   %dl,%dl
  800958:	74 13                	je     80096d <strfind+0x23>
  80095a:	88 d9                	mov    %bl,%cl
		if (*s == c)
  80095c:	38 d3                	cmp    %dl,%bl
  80095e:	75 06                	jne    800966 <strfind+0x1c>
  800960:	eb 0b                	jmp    80096d <strfind+0x23>
  800962:	38 ca                	cmp    %cl,%dl
  800964:	74 07                	je     80096d <strfind+0x23>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800966:	40                   	inc    %eax
  800967:	8a 10                	mov    (%eax),%dl
  800969:	84 d2                	test   %dl,%dl
  80096b:	75 f5                	jne    800962 <strfind+0x18>
		if (*s == c)
			break;
	return (char *) s;
}
  80096d:	5b                   	pop    %ebx
  80096e:	5d                   	pop    %ebp
  80096f:	c3                   	ret    

00800970 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800970:	55                   	push   %ebp
  800971:	89 e5                	mov    %esp,%ebp
  800973:	57                   	push   %edi
  800974:	56                   	push   %esi
  800975:	53                   	push   %ebx
  800976:	8b 7d 08             	mov    0x8(%ebp),%edi
  800979:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80097c:	85 c9                	test   %ecx,%ecx
  80097e:	74 36                	je     8009b6 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800980:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800986:	75 28                	jne    8009b0 <memset+0x40>
  800988:	f6 c1 03             	test   $0x3,%cl
  80098b:	75 23                	jne    8009b0 <memset+0x40>
		c &= 0xFF;
  80098d:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800991:	89 d3                	mov    %edx,%ebx
  800993:	c1 e3 08             	shl    $0x8,%ebx
  800996:	89 d6                	mov    %edx,%esi
  800998:	c1 e6 18             	shl    $0x18,%esi
  80099b:	89 d0                	mov    %edx,%eax
  80099d:	c1 e0 10             	shl    $0x10,%eax
  8009a0:	09 f0                	or     %esi,%eax
  8009a2:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8009a4:	89 d8                	mov    %ebx,%eax
  8009a6:	09 d0                	or     %edx,%eax
  8009a8:	c1 e9 02             	shr    $0x2,%ecx
  8009ab:	fc                   	cld    
  8009ac:	f3 ab                	rep stos %eax,%es:(%edi)
  8009ae:	eb 06                	jmp    8009b6 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009b0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009b3:	fc                   	cld    
  8009b4:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009b6:	89 f8                	mov    %edi,%eax
  8009b8:	5b                   	pop    %ebx
  8009b9:	5e                   	pop    %esi
  8009ba:	5f                   	pop    %edi
  8009bb:	5d                   	pop    %ebp
  8009bc:	c3                   	ret    

008009bd <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009bd:	55                   	push   %ebp
  8009be:	89 e5                	mov    %esp,%ebp
  8009c0:	57                   	push   %edi
  8009c1:	56                   	push   %esi
  8009c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c5:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009c8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009cb:	39 c6                	cmp    %eax,%esi
  8009cd:	73 33                	jae    800a02 <memmove+0x45>
  8009cf:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009d2:	39 d0                	cmp    %edx,%eax
  8009d4:	73 2c                	jae    800a02 <memmove+0x45>
		s += n;
		d += n;
  8009d6:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009d9:	89 d6                	mov    %edx,%esi
  8009db:	09 fe                	or     %edi,%esi
  8009dd:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009e3:	75 13                	jne    8009f8 <memmove+0x3b>
  8009e5:	f6 c1 03             	test   $0x3,%cl
  8009e8:	75 0e                	jne    8009f8 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8009ea:	83 ef 04             	sub    $0x4,%edi
  8009ed:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009f0:	c1 e9 02             	shr    $0x2,%ecx
  8009f3:	fd                   	std    
  8009f4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009f6:	eb 07                	jmp    8009ff <memmove+0x42>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009f8:	4f                   	dec    %edi
  8009f9:	8d 72 ff             	lea    -0x1(%edx),%esi
  8009fc:	fd                   	std    
  8009fd:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009ff:	fc                   	cld    
  800a00:	eb 1d                	jmp    800a1f <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a02:	89 f2                	mov    %esi,%edx
  800a04:	09 c2                	or     %eax,%edx
  800a06:	f6 c2 03             	test   $0x3,%dl
  800a09:	75 0f                	jne    800a1a <memmove+0x5d>
  800a0b:	f6 c1 03             	test   $0x3,%cl
  800a0e:	75 0a                	jne    800a1a <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
  800a10:	c1 e9 02             	shr    $0x2,%ecx
  800a13:	89 c7                	mov    %eax,%edi
  800a15:	fc                   	cld    
  800a16:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a18:	eb 05                	jmp    800a1f <memmove+0x62>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a1a:	89 c7                	mov    %eax,%edi
  800a1c:	fc                   	cld    
  800a1d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a1f:	5e                   	pop    %esi
  800a20:	5f                   	pop    %edi
  800a21:	5d                   	pop    %ebp
  800a22:	c3                   	ret    

00800a23 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a23:	55                   	push   %ebp
  800a24:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a26:	ff 75 10             	pushl  0x10(%ebp)
  800a29:	ff 75 0c             	pushl  0xc(%ebp)
  800a2c:	ff 75 08             	pushl  0x8(%ebp)
  800a2f:	e8 89 ff ff ff       	call   8009bd <memmove>
}
  800a34:	c9                   	leave  
  800a35:	c3                   	ret    

00800a36 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a36:	55                   	push   %ebp
  800a37:	89 e5                	mov    %esp,%ebp
  800a39:	57                   	push   %edi
  800a3a:	56                   	push   %esi
  800a3b:	53                   	push   %ebx
  800a3c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800a3f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a42:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a45:	85 c0                	test   %eax,%eax
  800a47:	74 33                	je     800a7c <memcmp+0x46>
  800a49:	8d 78 ff             	lea    -0x1(%eax),%edi
		if (*s1 != *s2)
  800a4c:	8a 13                	mov    (%ebx),%dl
  800a4e:	8a 0e                	mov    (%esi),%cl
  800a50:	38 ca                	cmp    %cl,%dl
  800a52:	75 13                	jne    800a67 <memcmp+0x31>
  800a54:	b8 00 00 00 00       	mov    $0x0,%eax
  800a59:	eb 16                	jmp    800a71 <memcmp+0x3b>
  800a5b:	8a 54 03 01          	mov    0x1(%ebx,%eax,1),%dl
  800a5f:	40                   	inc    %eax
  800a60:	8a 0c 06             	mov    (%esi,%eax,1),%cl
  800a63:	38 ca                	cmp    %cl,%dl
  800a65:	74 0a                	je     800a71 <memcmp+0x3b>
			return (int) *s1 - (int) *s2;
  800a67:	0f b6 c2             	movzbl %dl,%eax
  800a6a:	0f b6 c9             	movzbl %cl,%ecx
  800a6d:	29 c8                	sub    %ecx,%eax
  800a6f:	eb 10                	jmp    800a81 <memcmp+0x4b>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a71:	39 f8                	cmp    %edi,%eax
  800a73:	75 e6                	jne    800a5b <memcmp+0x25>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a75:	b8 00 00 00 00       	mov    $0x0,%eax
  800a7a:	eb 05                	jmp    800a81 <memcmp+0x4b>
  800a7c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a81:	5b                   	pop    %ebx
  800a82:	5e                   	pop    %esi
  800a83:	5f                   	pop    %edi
  800a84:	5d                   	pop    %ebp
  800a85:	c3                   	ret    

00800a86 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a86:	55                   	push   %ebp
  800a87:	89 e5                	mov    %esp,%ebp
  800a89:	53                   	push   %ebx
  800a8a:	8b 55 08             	mov    0x8(%ebp),%edx
	const void *ends = (const char *) s + n;
  800a8d:	89 d0                	mov    %edx,%eax
  800a8f:	03 45 10             	add    0x10(%ebp),%eax
	for (; s < ends; s++)
  800a92:	39 c2                	cmp    %eax,%edx
  800a94:	73 1b                	jae    800ab1 <memfind+0x2b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a96:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
  800a9a:	0f b6 0a             	movzbl (%edx),%ecx
  800a9d:	39 d9                	cmp    %ebx,%ecx
  800a9f:	75 09                	jne    800aaa <memfind+0x24>
  800aa1:	eb 12                	jmp    800ab5 <memfind+0x2f>
  800aa3:	0f b6 0a             	movzbl (%edx),%ecx
  800aa6:	39 d9                	cmp    %ebx,%ecx
  800aa8:	74 0f                	je     800ab9 <memfind+0x33>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800aaa:	42                   	inc    %edx
  800aab:	39 d0                	cmp    %edx,%eax
  800aad:	75 f4                	jne    800aa3 <memfind+0x1d>
  800aaf:	eb 0a                	jmp    800abb <memfind+0x35>
  800ab1:	89 d0                	mov    %edx,%eax
  800ab3:	eb 06                	jmp    800abb <memfind+0x35>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ab5:	89 d0                	mov    %edx,%eax
  800ab7:	eb 02                	jmp    800abb <memfind+0x35>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ab9:	89 d0                	mov    %edx,%eax
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800abb:	5b                   	pop    %ebx
  800abc:	5d                   	pop    %ebp
  800abd:	c3                   	ret    

00800abe <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800abe:	55                   	push   %ebp
  800abf:	89 e5                	mov    %esp,%ebp
  800ac1:	57                   	push   %edi
  800ac2:	56                   	push   %esi
  800ac3:	53                   	push   %ebx
  800ac4:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ac7:	eb 01                	jmp    800aca <strtol+0xc>
		s++;
  800ac9:	41                   	inc    %ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800aca:	8a 01                	mov    (%ecx),%al
  800acc:	3c 20                	cmp    $0x20,%al
  800ace:	74 f9                	je     800ac9 <strtol+0xb>
  800ad0:	3c 09                	cmp    $0x9,%al
  800ad2:	74 f5                	je     800ac9 <strtol+0xb>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ad4:	3c 2b                	cmp    $0x2b,%al
  800ad6:	75 08                	jne    800ae0 <strtol+0x22>
		s++;
  800ad8:	41                   	inc    %ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ad9:	bf 00 00 00 00       	mov    $0x0,%edi
  800ade:	eb 11                	jmp    800af1 <strtol+0x33>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800ae0:	3c 2d                	cmp    $0x2d,%al
  800ae2:	75 08                	jne    800aec <strtol+0x2e>
		s++, neg = 1;
  800ae4:	41                   	inc    %ecx
  800ae5:	bf 01 00 00 00       	mov    $0x1,%edi
  800aea:	eb 05                	jmp    800af1 <strtol+0x33>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800aec:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800af1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800af5:	0f 84 87 00 00 00    	je     800b82 <strtol+0xc4>
  800afb:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  800aff:	75 27                	jne    800b28 <strtol+0x6a>
  800b01:	80 39 30             	cmpb   $0x30,(%ecx)
  800b04:	75 22                	jne    800b28 <strtol+0x6a>
  800b06:	e9 88 00 00 00       	jmp    800b93 <strtol+0xd5>
		s += 2, base = 16;
  800b0b:	83 c1 02             	add    $0x2,%ecx
  800b0e:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  800b15:	eb 11                	jmp    800b28 <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
  800b17:	41                   	inc    %ecx
  800b18:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  800b1f:	eb 07                	jmp    800b28 <strtol+0x6a>
	else if (base == 0)
		base = 10;
  800b21:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)
  800b28:	b8 00 00 00 00       	mov    $0x0,%eax

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b2d:	8a 11                	mov    (%ecx),%dl
  800b2f:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800b32:	80 fb 09             	cmp    $0x9,%bl
  800b35:	77 08                	ja     800b3f <strtol+0x81>
			dig = *s - '0';
  800b37:	0f be d2             	movsbl %dl,%edx
  800b3a:	83 ea 30             	sub    $0x30,%edx
  800b3d:	eb 22                	jmp    800b61 <strtol+0xa3>
		else if (*s >= 'a' && *s <= 'z')
  800b3f:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b42:	89 f3                	mov    %esi,%ebx
  800b44:	80 fb 19             	cmp    $0x19,%bl
  800b47:	77 08                	ja     800b51 <strtol+0x93>
			dig = *s - 'a' + 10;
  800b49:	0f be d2             	movsbl %dl,%edx
  800b4c:	83 ea 57             	sub    $0x57,%edx
  800b4f:	eb 10                	jmp    800b61 <strtol+0xa3>
		else if (*s >= 'A' && *s <= 'Z')
  800b51:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b54:	89 f3                	mov    %esi,%ebx
  800b56:	80 fb 19             	cmp    $0x19,%bl
  800b59:	77 14                	ja     800b6f <strtol+0xb1>
			dig = *s - 'A' + 10;
  800b5b:	0f be d2             	movsbl %dl,%edx
  800b5e:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b61:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b64:	7d 09                	jge    800b6f <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800b66:	41                   	inc    %ecx
  800b67:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b6b:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b6d:	eb be                	jmp    800b2d <strtol+0x6f>

	if (endptr)
  800b6f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b73:	74 05                	je     800b7a <strtol+0xbc>
		*endptr = (char *) s;
  800b75:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b78:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800b7a:	85 ff                	test   %edi,%edi
  800b7c:	74 21                	je     800b9f <strtol+0xe1>
  800b7e:	f7 d8                	neg    %eax
  800b80:	eb 1d                	jmp    800b9f <strtol+0xe1>
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b82:	80 39 30             	cmpb   $0x30,(%ecx)
  800b85:	75 9a                	jne    800b21 <strtol+0x63>
  800b87:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b8b:	0f 84 7a ff ff ff    	je     800b0b <strtol+0x4d>
  800b91:	eb 84                	jmp    800b17 <strtol+0x59>
  800b93:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b97:	0f 84 6e ff ff ff    	je     800b0b <strtol+0x4d>
  800b9d:	eb 89                	jmp    800b28 <strtol+0x6a>
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
}
  800b9f:	5b                   	pop    %ebx
  800ba0:	5e                   	pop    %esi
  800ba1:	5f                   	pop    %edi
  800ba2:	5d                   	pop    %ebp
  800ba3:	c3                   	ret    

00800ba4 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ba4:	55                   	push   %ebp
  800ba5:	89 e5                	mov    %esp,%ebp
  800ba7:	57                   	push   %edi
  800ba8:	56                   	push   %esi
  800ba9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800baa:	b8 00 00 00 00       	mov    $0x0,%eax
  800baf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bb2:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb5:	89 c3                	mov    %eax,%ebx
  800bb7:	89 c7                	mov    %eax,%edi
  800bb9:	89 c6                	mov    %eax,%esi
  800bbb:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bbd:	5b                   	pop    %ebx
  800bbe:	5e                   	pop    %esi
  800bbf:	5f                   	pop    %edi
  800bc0:	5d                   	pop    %ebp
  800bc1:	c3                   	ret    

00800bc2 <sys_cgetc>:

int
sys_cgetc(void)
{
  800bc2:	55                   	push   %ebp
  800bc3:	89 e5                	mov    %esp,%ebp
  800bc5:	57                   	push   %edi
  800bc6:	56                   	push   %esi
  800bc7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc8:	ba 00 00 00 00       	mov    $0x0,%edx
  800bcd:	b8 01 00 00 00       	mov    $0x1,%eax
  800bd2:	89 d1                	mov    %edx,%ecx
  800bd4:	89 d3                	mov    %edx,%ebx
  800bd6:	89 d7                	mov    %edx,%edi
  800bd8:	89 d6                	mov    %edx,%esi
  800bda:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bdc:	5b                   	pop    %ebx
  800bdd:	5e                   	pop    %esi
  800bde:	5f                   	pop    %edi
  800bdf:	5d                   	pop    %ebp
  800be0:	c3                   	ret    

00800be1 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
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
  800bea:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bef:	b8 03 00 00 00       	mov    $0x3,%eax
  800bf4:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf7:	89 cb                	mov    %ecx,%ebx
  800bf9:	89 cf                	mov    %ecx,%edi
  800bfb:	89 ce                	mov    %ecx,%esi
  800bfd:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bff:	85 c0                	test   %eax,%eax
  800c01:	7e 17                	jle    800c1a <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c03:	83 ec 0c             	sub    $0xc,%esp
  800c06:	50                   	push   %eax
  800c07:	6a 03                	push   $0x3
  800c09:	68 ff 22 80 00       	push   $0x8022ff
  800c0e:	6a 23                	push   $0x23
  800c10:	68 1c 23 80 00       	push   $0x80231c
  800c15:	e8 19 f5 ff ff       	call   800133 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c1a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c1d:	5b                   	pop    %ebx
  800c1e:	5e                   	pop    %esi
  800c1f:	5f                   	pop    %edi
  800c20:	5d                   	pop    %ebp
  800c21:	c3                   	ret    

00800c22 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c22:	55                   	push   %ebp
  800c23:	89 e5                	mov    %esp,%ebp
  800c25:	57                   	push   %edi
  800c26:	56                   	push   %esi
  800c27:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c28:	ba 00 00 00 00       	mov    $0x0,%edx
  800c2d:	b8 02 00 00 00       	mov    $0x2,%eax
  800c32:	89 d1                	mov    %edx,%ecx
  800c34:	89 d3                	mov    %edx,%ebx
  800c36:	89 d7                	mov    %edx,%edi
  800c38:	89 d6                	mov    %edx,%esi
  800c3a:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c3c:	5b                   	pop    %ebx
  800c3d:	5e                   	pop    %esi
  800c3e:	5f                   	pop    %edi
  800c3f:	5d                   	pop    %ebp
  800c40:	c3                   	ret    

00800c41 <sys_yield>:

void
sys_yield(void)
{
  800c41:	55                   	push   %ebp
  800c42:	89 e5                	mov    %esp,%ebp
  800c44:	57                   	push   %edi
  800c45:	56                   	push   %esi
  800c46:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c47:	ba 00 00 00 00       	mov    $0x0,%edx
  800c4c:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c51:	89 d1                	mov    %edx,%ecx
  800c53:	89 d3                	mov    %edx,%ebx
  800c55:	89 d7                	mov    %edx,%edi
  800c57:	89 d6                	mov    %edx,%esi
  800c59:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c5b:	5b                   	pop    %ebx
  800c5c:	5e                   	pop    %esi
  800c5d:	5f                   	pop    %edi
  800c5e:	5d                   	pop    %ebp
  800c5f:	c3                   	ret    

00800c60 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c60:	55                   	push   %ebp
  800c61:	89 e5                	mov    %esp,%ebp
  800c63:	57                   	push   %edi
  800c64:	56                   	push   %esi
  800c65:	53                   	push   %ebx
  800c66:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c69:	be 00 00 00 00       	mov    $0x0,%esi
  800c6e:	b8 04 00 00 00       	mov    $0x4,%eax
  800c73:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c76:	8b 55 08             	mov    0x8(%ebp),%edx
  800c79:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c7c:	89 f7                	mov    %esi,%edi
  800c7e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c80:	85 c0                	test   %eax,%eax
  800c82:	7e 17                	jle    800c9b <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c84:	83 ec 0c             	sub    $0xc,%esp
  800c87:	50                   	push   %eax
  800c88:	6a 04                	push   $0x4
  800c8a:	68 ff 22 80 00       	push   $0x8022ff
  800c8f:	6a 23                	push   $0x23
  800c91:	68 1c 23 80 00       	push   $0x80231c
  800c96:	e8 98 f4 ff ff       	call   800133 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c9b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c9e:	5b                   	pop    %ebx
  800c9f:	5e                   	pop    %esi
  800ca0:	5f                   	pop    %edi
  800ca1:	5d                   	pop    %ebp
  800ca2:	c3                   	ret    

00800ca3 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ca3:	55                   	push   %ebp
  800ca4:	89 e5                	mov    %esp,%ebp
  800ca6:	57                   	push   %edi
  800ca7:	56                   	push   %esi
  800ca8:	53                   	push   %ebx
  800ca9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cac:	b8 05 00 00 00       	mov    $0x5,%eax
  800cb1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb4:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cba:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cbd:	8b 75 18             	mov    0x18(%ebp),%esi
  800cc0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cc2:	85 c0                	test   %eax,%eax
  800cc4:	7e 17                	jle    800cdd <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc6:	83 ec 0c             	sub    $0xc,%esp
  800cc9:	50                   	push   %eax
  800cca:	6a 05                	push   $0x5
  800ccc:	68 ff 22 80 00       	push   $0x8022ff
  800cd1:	6a 23                	push   $0x23
  800cd3:	68 1c 23 80 00       	push   $0x80231c
  800cd8:	e8 56 f4 ff ff       	call   800133 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800cdd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ce0:	5b                   	pop    %ebx
  800ce1:	5e                   	pop    %esi
  800ce2:	5f                   	pop    %edi
  800ce3:	5d                   	pop    %ebp
  800ce4:	c3                   	ret    

00800ce5 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800ce5:	55                   	push   %ebp
  800ce6:	89 e5                	mov    %esp,%ebp
  800ce8:	57                   	push   %edi
  800ce9:	56                   	push   %esi
  800cea:	53                   	push   %ebx
  800ceb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cee:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cf3:	b8 06 00 00 00       	mov    $0x6,%eax
  800cf8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cfb:	8b 55 08             	mov    0x8(%ebp),%edx
  800cfe:	89 df                	mov    %ebx,%edi
  800d00:	89 de                	mov    %ebx,%esi
  800d02:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d04:	85 c0                	test   %eax,%eax
  800d06:	7e 17                	jle    800d1f <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d08:	83 ec 0c             	sub    $0xc,%esp
  800d0b:	50                   	push   %eax
  800d0c:	6a 06                	push   $0x6
  800d0e:	68 ff 22 80 00       	push   $0x8022ff
  800d13:	6a 23                	push   $0x23
  800d15:	68 1c 23 80 00       	push   $0x80231c
  800d1a:	e8 14 f4 ff ff       	call   800133 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d1f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d22:	5b                   	pop    %ebx
  800d23:	5e                   	pop    %esi
  800d24:	5f                   	pop    %edi
  800d25:	5d                   	pop    %ebp
  800d26:	c3                   	ret    

00800d27 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d27:	55                   	push   %ebp
  800d28:	89 e5                	mov    %esp,%ebp
  800d2a:	57                   	push   %edi
  800d2b:	56                   	push   %esi
  800d2c:	53                   	push   %ebx
  800d2d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d30:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d35:	b8 08 00 00 00       	mov    $0x8,%eax
  800d3a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d3d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d40:	89 df                	mov    %ebx,%edi
  800d42:	89 de                	mov    %ebx,%esi
  800d44:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d46:	85 c0                	test   %eax,%eax
  800d48:	7e 17                	jle    800d61 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d4a:	83 ec 0c             	sub    $0xc,%esp
  800d4d:	50                   	push   %eax
  800d4e:	6a 08                	push   $0x8
  800d50:	68 ff 22 80 00       	push   $0x8022ff
  800d55:	6a 23                	push   $0x23
  800d57:	68 1c 23 80 00       	push   $0x80231c
  800d5c:	e8 d2 f3 ff ff       	call   800133 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d61:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d64:	5b                   	pop    %ebx
  800d65:	5e                   	pop    %esi
  800d66:	5f                   	pop    %edi
  800d67:	5d                   	pop    %ebp
  800d68:	c3                   	ret    

00800d69 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d69:	55                   	push   %ebp
  800d6a:	89 e5                	mov    %esp,%ebp
  800d6c:	57                   	push   %edi
  800d6d:	56                   	push   %esi
  800d6e:	53                   	push   %ebx
  800d6f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d72:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d77:	b8 09 00 00 00       	mov    $0x9,%eax
  800d7c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d7f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d82:	89 df                	mov    %ebx,%edi
  800d84:	89 de                	mov    %ebx,%esi
  800d86:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d88:	85 c0                	test   %eax,%eax
  800d8a:	7e 17                	jle    800da3 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d8c:	83 ec 0c             	sub    $0xc,%esp
  800d8f:	50                   	push   %eax
  800d90:	6a 09                	push   $0x9
  800d92:	68 ff 22 80 00       	push   $0x8022ff
  800d97:	6a 23                	push   $0x23
  800d99:	68 1c 23 80 00       	push   $0x80231c
  800d9e:	e8 90 f3 ff ff       	call   800133 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800da3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800da6:	5b                   	pop    %ebx
  800da7:	5e                   	pop    %esi
  800da8:	5f                   	pop    %edi
  800da9:	5d                   	pop    %ebp
  800daa:	c3                   	ret    

00800dab <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800dab:	55                   	push   %ebp
  800dac:	89 e5                	mov    %esp,%ebp
  800dae:	57                   	push   %edi
  800daf:	56                   	push   %esi
  800db0:	53                   	push   %ebx
  800db1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800db4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800db9:	b8 0a 00 00 00       	mov    $0xa,%eax
  800dbe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dc1:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc4:	89 df                	mov    %ebx,%edi
  800dc6:	89 de                	mov    %ebx,%esi
  800dc8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dca:	85 c0                	test   %eax,%eax
  800dcc:	7e 17                	jle    800de5 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dce:	83 ec 0c             	sub    $0xc,%esp
  800dd1:	50                   	push   %eax
  800dd2:	6a 0a                	push   $0xa
  800dd4:	68 ff 22 80 00       	push   $0x8022ff
  800dd9:	6a 23                	push   $0x23
  800ddb:	68 1c 23 80 00       	push   $0x80231c
  800de0:	e8 4e f3 ff ff       	call   800133 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800de5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800de8:	5b                   	pop    %ebx
  800de9:	5e                   	pop    %esi
  800dea:	5f                   	pop    %edi
  800deb:	5d                   	pop    %ebp
  800dec:	c3                   	ret    

00800ded <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ded:	55                   	push   %ebp
  800dee:	89 e5                	mov    %esp,%ebp
  800df0:	57                   	push   %edi
  800df1:	56                   	push   %esi
  800df2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800df3:	be 00 00 00 00       	mov    $0x0,%esi
  800df8:	b8 0c 00 00 00       	mov    $0xc,%eax
  800dfd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e00:	8b 55 08             	mov    0x8(%ebp),%edx
  800e03:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e06:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e09:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e0b:	5b                   	pop    %ebx
  800e0c:	5e                   	pop    %esi
  800e0d:	5f                   	pop    %edi
  800e0e:	5d                   	pop    %ebp
  800e0f:	c3                   	ret    

00800e10 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e10:	55                   	push   %ebp
  800e11:	89 e5                	mov    %esp,%ebp
  800e13:	57                   	push   %edi
  800e14:	56                   	push   %esi
  800e15:	53                   	push   %ebx
  800e16:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e19:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e1e:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e23:	8b 55 08             	mov    0x8(%ebp),%edx
  800e26:	89 cb                	mov    %ecx,%ebx
  800e28:	89 cf                	mov    %ecx,%edi
  800e2a:	89 ce                	mov    %ecx,%esi
  800e2c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e2e:	85 c0                	test   %eax,%eax
  800e30:	7e 17                	jle    800e49 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e32:	83 ec 0c             	sub    $0xc,%esp
  800e35:	50                   	push   %eax
  800e36:	6a 0d                	push   $0xd
  800e38:	68 ff 22 80 00       	push   $0x8022ff
  800e3d:	6a 23                	push   $0x23
  800e3f:	68 1c 23 80 00       	push   $0x80231c
  800e44:	e8 ea f2 ff ff       	call   800133 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e49:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e4c:	5b                   	pop    %ebx
  800e4d:	5e                   	pop    %esi
  800e4e:	5f                   	pop    %edi
  800e4f:	5d                   	pop    %ebp
  800e50:	c3                   	ret    

00800e51 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800e51:	55                   	push   %ebp
  800e52:	89 e5                	mov    %esp,%ebp
  800e54:	53                   	push   %ebx
  800e55:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (_pgfault_handler == 0) {
  800e58:	83 3d 08 40 80 00 00 	cmpl   $0x0,0x804008
  800e5f:	75 5b                	jne    800ebc <set_pgfault_handler+0x6b>
		// First time through!
		// LAB 4: Your code here.
		void *va = (void *)(UXSTACKTOP - PGSIZE);
		envid_t eid = sys_getenvid();
  800e61:	e8 bc fd ff ff       	call   800c22 <sys_getenvid>
  800e66:	89 c3                	mov    %eax,%ebx
		r = sys_page_alloc(eid,va,PTE_P | PTE_U | PTE_W);
  800e68:	83 ec 04             	sub    $0x4,%esp
  800e6b:	6a 07                	push   $0x7
  800e6d:	68 00 f0 bf ee       	push   $0xeebff000
  800e72:	50                   	push   %eax
  800e73:	e8 e8 fd ff ff       	call   800c60 <sys_page_alloc>
		if(r<0) panic("set_pgfault_handler\n");
  800e78:	83 c4 10             	add    $0x10,%esp
  800e7b:	85 c0                	test   %eax,%eax
  800e7d:	79 14                	jns    800e93 <set_pgfault_handler+0x42>
  800e7f:	83 ec 04             	sub    $0x4,%esp
  800e82:	68 2a 23 80 00       	push   $0x80232a
  800e87:	6a 23                	push   $0x23
  800e89:	68 3f 23 80 00       	push   $0x80233f
  800e8e:	e8 a0 f2 ff ff       	call   800133 <_panic>
		r = sys_env_set_pgfault_upcall(eid,_pgfault_upcall);
  800e93:	83 ec 08             	sub    $0x8,%esp
  800e96:	68 c9 0e 80 00       	push   $0x800ec9
  800e9b:	53                   	push   %ebx
  800e9c:	e8 0a ff ff ff       	call   800dab <sys_env_set_pgfault_upcall>
		if(r<0) panic("set_pgfault_handler\n");
  800ea1:	83 c4 10             	add    $0x10,%esp
  800ea4:	85 c0                	test   %eax,%eax
  800ea6:	79 14                	jns    800ebc <set_pgfault_handler+0x6b>
  800ea8:	83 ec 04             	sub    $0x4,%esp
  800eab:	68 2a 23 80 00       	push   $0x80232a
  800eb0:	6a 25                	push   $0x25
  800eb2:	68 3f 23 80 00       	push   $0x80233f
  800eb7:	e8 77 f2 ff ff       	call   800133 <_panic>
		// panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800ebc:	8b 45 08             	mov    0x8(%ebp),%eax
  800ebf:	a3 08 40 80 00       	mov    %eax,0x804008
}
  800ec4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ec7:	c9                   	leave  
  800ec8:	c3                   	ret    

00800ec9 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800ec9:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800eca:	a1 08 40 80 00       	mov    0x804008,%eax
	call *%eax
  800ecf:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800ed1:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl %esp,%ebx
  800ed4:	89 e3                	mov    %esp,%ebx
	movl 40(%esp),%eax 	// esp from utf_fault_va to utf_regs(end)
  800ed6:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl 48(%esp),%esp 	// 
  800eda:	8b 64 24 30          	mov    0x30(%esp),%esp
	pushl %eax
  800ede:	50                   	push   %eax
 
 
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	movl %ebx,%esp
  800edf:	89 dc                	mov    %ebx,%esp
	subl $4,48(%esp)
  800ee1:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	popl %eax
  800ee6:	58                   	pop    %eax
	popl %eax
  800ee7:	58                   	pop    %eax
	popal
  800ee8:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	add $4,%esp
  800ee9:	83 c4 04             	add    $0x4,%esp
	popfl
  800eec:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  800eed:	5c                   	pop    %esp
 
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  800eee:	c3                   	ret    

00800eef <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800eef:	55                   	push   %ebp
  800ef0:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800ef2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ef5:	05 00 00 00 30       	add    $0x30000000,%eax
  800efa:	c1 e8 0c             	shr    $0xc,%eax
}
  800efd:	5d                   	pop    %ebp
  800efe:	c3                   	ret    

00800eff <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800eff:	55                   	push   %ebp
  800f00:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800f02:	8b 45 08             	mov    0x8(%ebp),%eax
  800f05:	05 00 00 00 30       	add    $0x30000000,%eax
  800f0a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800f0f:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800f14:	5d                   	pop    %ebp
  800f15:	c3                   	ret    

00800f16 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800f16:	55                   	push   %ebp
  800f17:	89 e5                	mov    %esp,%ebp
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800f19:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  800f1e:	a8 01                	test   $0x1,%al
  800f20:	74 34                	je     800f56 <fd_alloc+0x40>
  800f22:	a1 00 00 74 ef       	mov    0xef740000,%eax
  800f27:	a8 01                	test   $0x1,%al
  800f29:	74 32                	je     800f5d <fd_alloc+0x47>
  800f2b:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800f30:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800f32:	89 c2                	mov    %eax,%edx
  800f34:	c1 ea 16             	shr    $0x16,%edx
  800f37:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f3e:	f6 c2 01             	test   $0x1,%dl
  800f41:	74 1f                	je     800f62 <fd_alloc+0x4c>
  800f43:	89 c2                	mov    %eax,%edx
  800f45:	c1 ea 0c             	shr    $0xc,%edx
  800f48:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f4f:	f6 c2 01             	test   $0x1,%dl
  800f52:	75 1a                	jne    800f6e <fd_alloc+0x58>
  800f54:	eb 0c                	jmp    800f62 <fd_alloc+0x4c>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800f56:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  800f5b:	eb 05                	jmp    800f62 <fd_alloc+0x4c>
  800f5d:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  800f62:	8b 45 08             	mov    0x8(%ebp),%eax
  800f65:	89 08                	mov    %ecx,(%eax)
			return 0;
  800f67:	b8 00 00 00 00       	mov    $0x0,%eax
  800f6c:	eb 1a                	jmp    800f88 <fd_alloc+0x72>
  800f6e:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800f73:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800f78:	75 b6                	jne    800f30 <fd_alloc+0x1a>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800f7a:	8b 45 08             	mov    0x8(%ebp),%eax
  800f7d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  800f83:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800f88:	5d                   	pop    %ebp
  800f89:	c3                   	ret    

00800f8a <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800f8a:	55                   	push   %ebp
  800f8b:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800f8d:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
  800f91:	77 39                	ja     800fcc <fd_lookup+0x42>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800f93:	8b 45 08             	mov    0x8(%ebp),%eax
  800f96:	c1 e0 0c             	shl    $0xc,%eax
  800f99:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800f9e:	89 c2                	mov    %eax,%edx
  800fa0:	c1 ea 16             	shr    $0x16,%edx
  800fa3:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800faa:	f6 c2 01             	test   $0x1,%dl
  800fad:	74 24                	je     800fd3 <fd_lookup+0x49>
  800faf:	89 c2                	mov    %eax,%edx
  800fb1:	c1 ea 0c             	shr    $0xc,%edx
  800fb4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800fbb:	f6 c2 01             	test   $0x1,%dl
  800fbe:	74 1a                	je     800fda <fd_lookup+0x50>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800fc0:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fc3:	89 02                	mov    %eax,(%edx)
	return 0;
  800fc5:	b8 00 00 00 00       	mov    $0x0,%eax
  800fca:	eb 13                	jmp    800fdf <fd_lookup+0x55>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800fcc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800fd1:	eb 0c                	jmp    800fdf <fd_lookup+0x55>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800fd3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800fd8:	eb 05                	jmp    800fdf <fd_lookup+0x55>
  800fda:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800fdf:	5d                   	pop    %ebp
  800fe0:	c3                   	ret    

00800fe1 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800fe1:	55                   	push   %ebp
  800fe2:	89 e5                	mov    %esp,%ebp
  800fe4:	53                   	push   %ebx
  800fe5:	83 ec 04             	sub    $0x4,%esp
  800fe8:	8b 45 08             	mov    0x8(%ebp),%eax
  800feb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  800fee:	3b 05 04 30 80 00    	cmp    0x803004,%eax
  800ff4:	75 1e                	jne    801014 <dev_lookup+0x33>
  800ff6:	eb 0e                	jmp    801006 <dev_lookup+0x25>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800ff8:	b8 20 30 80 00       	mov    $0x803020,%eax
  800ffd:	eb 0c                	jmp    80100b <dev_lookup+0x2a>
  800fff:	b8 3c 30 80 00       	mov    $0x80303c,%eax
  801004:	eb 05                	jmp    80100b <dev_lookup+0x2a>
  801006:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  80100b:	89 03                	mov    %eax,(%ebx)
			return 0;
  80100d:	b8 00 00 00 00       	mov    $0x0,%eax
  801012:	eb 36                	jmp    80104a <dev_lookup+0x69>
int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  801014:	3b 05 20 30 80 00    	cmp    0x803020,%eax
  80101a:	74 dc                	je     800ff8 <dev_lookup+0x17>
  80101c:	3b 05 3c 30 80 00    	cmp    0x80303c,%eax
  801022:	74 db                	je     800fff <dev_lookup+0x1e>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801024:	8b 15 04 40 80 00    	mov    0x804004,%edx
  80102a:	8b 52 48             	mov    0x48(%edx),%edx
  80102d:	83 ec 04             	sub    $0x4,%esp
  801030:	50                   	push   %eax
  801031:	52                   	push   %edx
  801032:	68 50 23 80 00       	push   $0x802350
  801037:	e8 cf f1 ff ff       	call   80020b <cprintf>
	*dev = 0;
  80103c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  801042:	83 c4 10             	add    $0x10,%esp
  801045:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80104a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80104d:	c9                   	leave  
  80104e:	c3                   	ret    

0080104f <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80104f:	55                   	push   %ebp
  801050:	89 e5                	mov    %esp,%ebp
  801052:	56                   	push   %esi
  801053:	53                   	push   %ebx
  801054:	83 ec 10             	sub    $0x10,%esp
  801057:	8b 75 08             	mov    0x8(%ebp),%esi
  80105a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80105d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801060:	50                   	push   %eax
  801061:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801067:	c1 e8 0c             	shr    $0xc,%eax
  80106a:	50                   	push   %eax
  80106b:	e8 1a ff ff ff       	call   800f8a <fd_lookup>
  801070:	83 c4 08             	add    $0x8,%esp
  801073:	85 c0                	test   %eax,%eax
  801075:	78 05                	js     80107c <fd_close+0x2d>
	    || fd != fd2)
  801077:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80107a:	74 06                	je     801082 <fd_close+0x33>
		return (must_exist ? r : 0);
  80107c:	84 db                	test   %bl,%bl
  80107e:	74 47                	je     8010c7 <fd_close+0x78>
  801080:	eb 4a                	jmp    8010cc <fd_close+0x7d>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801082:	83 ec 08             	sub    $0x8,%esp
  801085:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801088:	50                   	push   %eax
  801089:	ff 36                	pushl  (%esi)
  80108b:	e8 51 ff ff ff       	call   800fe1 <dev_lookup>
  801090:	89 c3                	mov    %eax,%ebx
  801092:	83 c4 10             	add    $0x10,%esp
  801095:	85 c0                	test   %eax,%eax
  801097:	78 1c                	js     8010b5 <fd_close+0x66>
		if (dev->dev_close)
  801099:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80109c:	8b 40 10             	mov    0x10(%eax),%eax
  80109f:	85 c0                	test   %eax,%eax
  8010a1:	74 0d                	je     8010b0 <fd_close+0x61>
			r = (*dev->dev_close)(fd);
  8010a3:	83 ec 0c             	sub    $0xc,%esp
  8010a6:	56                   	push   %esi
  8010a7:	ff d0                	call   *%eax
  8010a9:	89 c3                	mov    %eax,%ebx
  8010ab:	83 c4 10             	add    $0x10,%esp
  8010ae:	eb 05                	jmp    8010b5 <fd_close+0x66>
		else
			r = 0;
  8010b0:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8010b5:	83 ec 08             	sub    $0x8,%esp
  8010b8:	56                   	push   %esi
  8010b9:	6a 00                	push   $0x0
  8010bb:	e8 25 fc ff ff       	call   800ce5 <sys_page_unmap>
	return r;
  8010c0:	83 c4 10             	add    $0x10,%esp
  8010c3:	89 d8                	mov    %ebx,%eax
  8010c5:	eb 05                	jmp    8010cc <fd_close+0x7d>
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
  8010c7:	b8 00 00 00 00       	mov    $0x0,%eax
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
	return r;
}
  8010cc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010cf:	5b                   	pop    %ebx
  8010d0:	5e                   	pop    %esi
  8010d1:	5d                   	pop    %ebp
  8010d2:	c3                   	ret    

008010d3 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8010d3:	55                   	push   %ebp
  8010d4:	89 e5                	mov    %esp,%ebp
  8010d6:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8010d9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010dc:	50                   	push   %eax
  8010dd:	ff 75 08             	pushl  0x8(%ebp)
  8010e0:	e8 a5 fe ff ff       	call   800f8a <fd_lookup>
  8010e5:	83 c4 08             	add    $0x8,%esp
  8010e8:	85 c0                	test   %eax,%eax
  8010ea:	78 10                	js     8010fc <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8010ec:	83 ec 08             	sub    $0x8,%esp
  8010ef:	6a 01                	push   $0x1
  8010f1:	ff 75 f4             	pushl  -0xc(%ebp)
  8010f4:	e8 56 ff ff ff       	call   80104f <fd_close>
  8010f9:	83 c4 10             	add    $0x10,%esp
}
  8010fc:	c9                   	leave  
  8010fd:	c3                   	ret    

008010fe <close_all>:

void
close_all(void)
{
  8010fe:	55                   	push   %ebp
  8010ff:	89 e5                	mov    %esp,%ebp
  801101:	53                   	push   %ebx
  801102:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801105:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80110a:	83 ec 0c             	sub    $0xc,%esp
  80110d:	53                   	push   %ebx
  80110e:	e8 c0 ff ff ff       	call   8010d3 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801113:	43                   	inc    %ebx
  801114:	83 c4 10             	add    $0x10,%esp
  801117:	83 fb 20             	cmp    $0x20,%ebx
  80111a:	75 ee                	jne    80110a <close_all+0xc>
		close(i);
}
  80111c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80111f:	c9                   	leave  
  801120:	c3                   	ret    

00801121 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801121:	55                   	push   %ebp
  801122:	89 e5                	mov    %esp,%ebp
  801124:	57                   	push   %edi
  801125:	56                   	push   %esi
  801126:	53                   	push   %ebx
  801127:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80112a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80112d:	50                   	push   %eax
  80112e:	ff 75 08             	pushl  0x8(%ebp)
  801131:	e8 54 fe ff ff       	call   800f8a <fd_lookup>
  801136:	83 c4 08             	add    $0x8,%esp
  801139:	85 c0                	test   %eax,%eax
  80113b:	0f 88 c2 00 00 00    	js     801203 <dup+0xe2>
		return r;
	close(newfdnum);
  801141:	83 ec 0c             	sub    $0xc,%esp
  801144:	ff 75 0c             	pushl  0xc(%ebp)
  801147:	e8 87 ff ff ff       	call   8010d3 <close>

	newfd = INDEX2FD(newfdnum);
  80114c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80114f:	c1 e3 0c             	shl    $0xc,%ebx
  801152:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801158:	83 c4 04             	add    $0x4,%esp
  80115b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80115e:	e8 9c fd ff ff       	call   800eff <fd2data>
  801163:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  801165:	89 1c 24             	mov    %ebx,(%esp)
  801168:	e8 92 fd ff ff       	call   800eff <fd2data>
  80116d:	83 c4 10             	add    $0x10,%esp
  801170:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801172:	89 f0                	mov    %esi,%eax
  801174:	c1 e8 16             	shr    $0x16,%eax
  801177:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80117e:	a8 01                	test   $0x1,%al
  801180:	74 35                	je     8011b7 <dup+0x96>
  801182:	89 f0                	mov    %esi,%eax
  801184:	c1 e8 0c             	shr    $0xc,%eax
  801187:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80118e:	f6 c2 01             	test   $0x1,%dl
  801191:	74 24                	je     8011b7 <dup+0x96>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801193:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80119a:	83 ec 0c             	sub    $0xc,%esp
  80119d:	25 07 0e 00 00       	and    $0xe07,%eax
  8011a2:	50                   	push   %eax
  8011a3:	57                   	push   %edi
  8011a4:	6a 00                	push   $0x0
  8011a6:	56                   	push   %esi
  8011a7:	6a 00                	push   $0x0
  8011a9:	e8 f5 fa ff ff       	call   800ca3 <sys_page_map>
  8011ae:	89 c6                	mov    %eax,%esi
  8011b0:	83 c4 20             	add    $0x20,%esp
  8011b3:	85 c0                	test   %eax,%eax
  8011b5:	78 2c                	js     8011e3 <dup+0xc2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8011b7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8011ba:	89 d0                	mov    %edx,%eax
  8011bc:	c1 e8 0c             	shr    $0xc,%eax
  8011bf:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8011c6:	83 ec 0c             	sub    $0xc,%esp
  8011c9:	25 07 0e 00 00       	and    $0xe07,%eax
  8011ce:	50                   	push   %eax
  8011cf:	53                   	push   %ebx
  8011d0:	6a 00                	push   $0x0
  8011d2:	52                   	push   %edx
  8011d3:	6a 00                	push   $0x0
  8011d5:	e8 c9 fa ff ff       	call   800ca3 <sys_page_map>
  8011da:	89 c6                	mov    %eax,%esi
  8011dc:	83 c4 20             	add    $0x20,%esp
  8011df:	85 c0                	test   %eax,%eax
  8011e1:	79 1d                	jns    801200 <dup+0xdf>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8011e3:	83 ec 08             	sub    $0x8,%esp
  8011e6:	53                   	push   %ebx
  8011e7:	6a 00                	push   $0x0
  8011e9:	e8 f7 fa ff ff       	call   800ce5 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8011ee:	83 c4 08             	add    $0x8,%esp
  8011f1:	57                   	push   %edi
  8011f2:	6a 00                	push   $0x0
  8011f4:	e8 ec fa ff ff       	call   800ce5 <sys_page_unmap>
	return r;
  8011f9:	83 c4 10             	add    $0x10,%esp
  8011fc:	89 f0                	mov    %esi,%eax
  8011fe:	eb 03                	jmp    801203 <dup+0xe2>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801200:	8b 45 0c             	mov    0xc(%ebp),%eax

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801203:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801206:	5b                   	pop    %ebx
  801207:	5e                   	pop    %esi
  801208:	5f                   	pop    %edi
  801209:	5d                   	pop    %ebp
  80120a:	c3                   	ret    

0080120b <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80120b:	55                   	push   %ebp
  80120c:	89 e5                	mov    %esp,%ebp
  80120e:	53                   	push   %ebx
  80120f:	83 ec 14             	sub    $0x14,%esp
  801212:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801215:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801218:	50                   	push   %eax
  801219:	53                   	push   %ebx
  80121a:	e8 6b fd ff ff       	call   800f8a <fd_lookup>
  80121f:	83 c4 08             	add    $0x8,%esp
  801222:	85 c0                	test   %eax,%eax
  801224:	78 67                	js     80128d <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801226:	83 ec 08             	sub    $0x8,%esp
  801229:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80122c:	50                   	push   %eax
  80122d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801230:	ff 30                	pushl  (%eax)
  801232:	e8 aa fd ff ff       	call   800fe1 <dev_lookup>
  801237:	83 c4 10             	add    $0x10,%esp
  80123a:	85 c0                	test   %eax,%eax
  80123c:	78 4f                	js     80128d <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80123e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801241:	8b 42 08             	mov    0x8(%edx),%eax
  801244:	83 e0 03             	and    $0x3,%eax
  801247:	83 f8 01             	cmp    $0x1,%eax
  80124a:	75 21                	jne    80126d <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80124c:	a1 04 40 80 00       	mov    0x804004,%eax
  801251:	8b 40 48             	mov    0x48(%eax),%eax
  801254:	83 ec 04             	sub    $0x4,%esp
  801257:	53                   	push   %ebx
  801258:	50                   	push   %eax
  801259:	68 94 23 80 00       	push   $0x802394
  80125e:	e8 a8 ef ff ff       	call   80020b <cprintf>
		return -E_INVAL;
  801263:	83 c4 10             	add    $0x10,%esp
  801266:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80126b:	eb 20                	jmp    80128d <read+0x82>
	}
	if (!dev->dev_read)
  80126d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801270:	8b 40 08             	mov    0x8(%eax),%eax
  801273:	85 c0                	test   %eax,%eax
  801275:	74 11                	je     801288 <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801277:	83 ec 04             	sub    $0x4,%esp
  80127a:	ff 75 10             	pushl  0x10(%ebp)
  80127d:	ff 75 0c             	pushl  0xc(%ebp)
  801280:	52                   	push   %edx
  801281:	ff d0                	call   *%eax
  801283:	83 c4 10             	add    $0x10,%esp
  801286:	eb 05                	jmp    80128d <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801288:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  80128d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801290:	c9                   	leave  
  801291:	c3                   	ret    

00801292 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801292:	55                   	push   %ebp
  801293:	89 e5                	mov    %esp,%ebp
  801295:	57                   	push   %edi
  801296:	56                   	push   %esi
  801297:	53                   	push   %ebx
  801298:	83 ec 0c             	sub    $0xc,%esp
  80129b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80129e:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8012a1:	85 f6                	test   %esi,%esi
  8012a3:	74 31                	je     8012d6 <readn+0x44>
  8012a5:	b8 00 00 00 00       	mov    $0x0,%eax
  8012aa:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  8012af:	83 ec 04             	sub    $0x4,%esp
  8012b2:	89 f2                	mov    %esi,%edx
  8012b4:	29 c2                	sub    %eax,%edx
  8012b6:	52                   	push   %edx
  8012b7:	03 45 0c             	add    0xc(%ebp),%eax
  8012ba:	50                   	push   %eax
  8012bb:	57                   	push   %edi
  8012bc:	e8 4a ff ff ff       	call   80120b <read>
		if (m < 0)
  8012c1:	83 c4 10             	add    $0x10,%esp
  8012c4:	85 c0                	test   %eax,%eax
  8012c6:	78 17                	js     8012df <readn+0x4d>
			return m;
		if (m == 0)
  8012c8:	85 c0                	test   %eax,%eax
  8012ca:	74 11                	je     8012dd <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8012cc:	01 c3                	add    %eax,%ebx
  8012ce:	89 d8                	mov    %ebx,%eax
  8012d0:	39 f3                	cmp    %esi,%ebx
  8012d2:	72 db                	jb     8012af <readn+0x1d>
  8012d4:	eb 09                	jmp    8012df <readn+0x4d>
  8012d6:	b8 00 00 00 00       	mov    $0x0,%eax
  8012db:	eb 02                	jmp    8012df <readn+0x4d>
  8012dd:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8012df:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012e2:	5b                   	pop    %ebx
  8012e3:	5e                   	pop    %esi
  8012e4:	5f                   	pop    %edi
  8012e5:	5d                   	pop    %ebp
  8012e6:	c3                   	ret    

008012e7 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8012e7:	55                   	push   %ebp
  8012e8:	89 e5                	mov    %esp,%ebp
  8012ea:	53                   	push   %ebx
  8012eb:	83 ec 14             	sub    $0x14,%esp
  8012ee:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012f1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012f4:	50                   	push   %eax
  8012f5:	53                   	push   %ebx
  8012f6:	e8 8f fc ff ff       	call   800f8a <fd_lookup>
  8012fb:	83 c4 08             	add    $0x8,%esp
  8012fe:	85 c0                	test   %eax,%eax
  801300:	78 62                	js     801364 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801302:	83 ec 08             	sub    $0x8,%esp
  801305:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801308:	50                   	push   %eax
  801309:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80130c:	ff 30                	pushl  (%eax)
  80130e:	e8 ce fc ff ff       	call   800fe1 <dev_lookup>
  801313:	83 c4 10             	add    $0x10,%esp
  801316:	85 c0                	test   %eax,%eax
  801318:	78 4a                	js     801364 <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80131a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80131d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801321:	75 21                	jne    801344 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801323:	a1 04 40 80 00       	mov    0x804004,%eax
  801328:	8b 40 48             	mov    0x48(%eax),%eax
  80132b:	83 ec 04             	sub    $0x4,%esp
  80132e:	53                   	push   %ebx
  80132f:	50                   	push   %eax
  801330:	68 b0 23 80 00       	push   $0x8023b0
  801335:	e8 d1 ee ff ff       	call   80020b <cprintf>
		return -E_INVAL;
  80133a:	83 c4 10             	add    $0x10,%esp
  80133d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801342:	eb 20                	jmp    801364 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801344:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801347:	8b 52 0c             	mov    0xc(%edx),%edx
  80134a:	85 d2                	test   %edx,%edx
  80134c:	74 11                	je     80135f <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80134e:	83 ec 04             	sub    $0x4,%esp
  801351:	ff 75 10             	pushl  0x10(%ebp)
  801354:	ff 75 0c             	pushl  0xc(%ebp)
  801357:	50                   	push   %eax
  801358:	ff d2                	call   *%edx
  80135a:	83 c4 10             	add    $0x10,%esp
  80135d:	eb 05                	jmp    801364 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80135f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801364:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801367:	c9                   	leave  
  801368:	c3                   	ret    

00801369 <seek>:

int
seek(int fdnum, off_t offset)
{
  801369:	55                   	push   %ebp
  80136a:	89 e5                	mov    %esp,%ebp
  80136c:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80136f:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801372:	50                   	push   %eax
  801373:	ff 75 08             	pushl  0x8(%ebp)
  801376:	e8 0f fc ff ff       	call   800f8a <fd_lookup>
  80137b:	83 c4 08             	add    $0x8,%esp
  80137e:	85 c0                	test   %eax,%eax
  801380:	78 0e                	js     801390 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801382:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801385:	8b 55 0c             	mov    0xc(%ebp),%edx
  801388:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80138b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801390:	c9                   	leave  
  801391:	c3                   	ret    

00801392 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801392:	55                   	push   %ebp
  801393:	89 e5                	mov    %esp,%ebp
  801395:	53                   	push   %ebx
  801396:	83 ec 14             	sub    $0x14,%esp
  801399:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80139c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80139f:	50                   	push   %eax
  8013a0:	53                   	push   %ebx
  8013a1:	e8 e4 fb ff ff       	call   800f8a <fd_lookup>
  8013a6:	83 c4 08             	add    $0x8,%esp
  8013a9:	85 c0                	test   %eax,%eax
  8013ab:	78 5f                	js     80140c <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013ad:	83 ec 08             	sub    $0x8,%esp
  8013b0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013b3:	50                   	push   %eax
  8013b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013b7:	ff 30                	pushl  (%eax)
  8013b9:	e8 23 fc ff ff       	call   800fe1 <dev_lookup>
  8013be:	83 c4 10             	add    $0x10,%esp
  8013c1:	85 c0                	test   %eax,%eax
  8013c3:	78 47                	js     80140c <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8013c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013c8:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8013cc:	75 21                	jne    8013ef <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8013ce:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8013d3:	8b 40 48             	mov    0x48(%eax),%eax
  8013d6:	83 ec 04             	sub    $0x4,%esp
  8013d9:	53                   	push   %ebx
  8013da:	50                   	push   %eax
  8013db:	68 70 23 80 00       	push   $0x802370
  8013e0:	e8 26 ee ff ff       	call   80020b <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8013e5:	83 c4 10             	add    $0x10,%esp
  8013e8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013ed:	eb 1d                	jmp    80140c <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  8013ef:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8013f2:	8b 52 18             	mov    0x18(%edx),%edx
  8013f5:	85 d2                	test   %edx,%edx
  8013f7:	74 0e                	je     801407 <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8013f9:	83 ec 08             	sub    $0x8,%esp
  8013fc:	ff 75 0c             	pushl  0xc(%ebp)
  8013ff:	50                   	push   %eax
  801400:	ff d2                	call   *%edx
  801402:	83 c4 10             	add    $0x10,%esp
  801405:	eb 05                	jmp    80140c <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801407:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  80140c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80140f:	c9                   	leave  
  801410:	c3                   	ret    

00801411 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801411:	55                   	push   %ebp
  801412:	89 e5                	mov    %esp,%ebp
  801414:	53                   	push   %ebx
  801415:	83 ec 14             	sub    $0x14,%esp
  801418:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80141b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80141e:	50                   	push   %eax
  80141f:	ff 75 08             	pushl  0x8(%ebp)
  801422:	e8 63 fb ff ff       	call   800f8a <fd_lookup>
  801427:	83 c4 08             	add    $0x8,%esp
  80142a:	85 c0                	test   %eax,%eax
  80142c:	78 52                	js     801480 <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80142e:	83 ec 08             	sub    $0x8,%esp
  801431:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801434:	50                   	push   %eax
  801435:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801438:	ff 30                	pushl  (%eax)
  80143a:	e8 a2 fb ff ff       	call   800fe1 <dev_lookup>
  80143f:	83 c4 10             	add    $0x10,%esp
  801442:	85 c0                	test   %eax,%eax
  801444:	78 3a                	js     801480 <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  801446:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801449:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80144d:	74 2c                	je     80147b <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80144f:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801452:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801459:	00 00 00 
	stat->st_isdir = 0;
  80145c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801463:	00 00 00 
	stat->st_dev = dev;
  801466:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80146c:	83 ec 08             	sub    $0x8,%esp
  80146f:	53                   	push   %ebx
  801470:	ff 75 f0             	pushl  -0x10(%ebp)
  801473:	ff 50 14             	call   *0x14(%eax)
  801476:	83 c4 10             	add    $0x10,%esp
  801479:	eb 05                	jmp    801480 <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80147b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801480:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801483:	c9                   	leave  
  801484:	c3                   	ret    

00801485 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801485:	55                   	push   %ebp
  801486:	89 e5                	mov    %esp,%ebp
  801488:	56                   	push   %esi
  801489:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80148a:	83 ec 08             	sub    $0x8,%esp
  80148d:	6a 00                	push   $0x0
  80148f:	ff 75 08             	pushl  0x8(%ebp)
  801492:	e8 75 01 00 00       	call   80160c <open>
  801497:	89 c3                	mov    %eax,%ebx
  801499:	83 c4 10             	add    $0x10,%esp
  80149c:	85 c0                	test   %eax,%eax
  80149e:	78 1d                	js     8014bd <stat+0x38>
		return fd;
	r = fstat(fd, stat);
  8014a0:	83 ec 08             	sub    $0x8,%esp
  8014a3:	ff 75 0c             	pushl  0xc(%ebp)
  8014a6:	50                   	push   %eax
  8014a7:	e8 65 ff ff ff       	call   801411 <fstat>
  8014ac:	89 c6                	mov    %eax,%esi
	close(fd);
  8014ae:	89 1c 24             	mov    %ebx,(%esp)
  8014b1:	e8 1d fc ff ff       	call   8010d3 <close>
	return r;
  8014b6:	83 c4 10             	add    $0x10,%esp
  8014b9:	89 f0                	mov    %esi,%eax
  8014bb:	eb 00                	jmp    8014bd <stat+0x38>
}
  8014bd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014c0:	5b                   	pop    %ebx
  8014c1:	5e                   	pop    %esi
  8014c2:	5d                   	pop    %ebp
  8014c3:	c3                   	ret    

008014c4 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8014c4:	55                   	push   %ebp
  8014c5:	89 e5                	mov    %esp,%ebp
  8014c7:	56                   	push   %esi
  8014c8:	53                   	push   %ebx
  8014c9:	89 c6                	mov    %eax,%esi
  8014cb:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8014cd:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8014d4:	75 12                	jne    8014e8 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8014d6:	83 ec 0c             	sub    $0xc,%esp
  8014d9:	6a 01                	push   $0x1
  8014db:	e8 7b 07 00 00       	call   801c5b <ipc_find_env>
  8014e0:	a3 00 40 80 00       	mov    %eax,0x804000
  8014e5:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8014e8:	6a 07                	push   $0x7
  8014ea:	68 00 50 80 00       	push   $0x805000
  8014ef:	56                   	push   %esi
  8014f0:	ff 35 00 40 80 00    	pushl  0x804000
  8014f6:	e8 01 07 00 00       	call   801bfc <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8014fb:	83 c4 0c             	add    $0xc,%esp
  8014fe:	6a 00                	push   $0x0
  801500:	53                   	push   %ebx
  801501:	6a 00                	push   $0x0
  801503:	e8 7f 06 00 00       	call   801b87 <ipc_recv>
}
  801508:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80150b:	5b                   	pop    %ebx
  80150c:	5e                   	pop    %esi
  80150d:	5d                   	pop    %ebp
  80150e:	c3                   	ret    

0080150f <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80150f:	55                   	push   %ebp
  801510:	89 e5                	mov    %esp,%ebp
  801512:	53                   	push   %ebx
  801513:	83 ec 04             	sub    $0x4,%esp
  801516:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801519:	8b 45 08             	mov    0x8(%ebp),%eax
  80151c:	8b 40 0c             	mov    0xc(%eax),%eax
  80151f:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801524:	ba 00 00 00 00       	mov    $0x0,%edx
  801529:	b8 05 00 00 00       	mov    $0x5,%eax
  80152e:	e8 91 ff ff ff       	call   8014c4 <fsipc>
  801533:	85 c0                	test   %eax,%eax
  801535:	78 2c                	js     801563 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801537:	83 ec 08             	sub    $0x8,%esp
  80153a:	68 00 50 80 00       	push   $0x805000
  80153f:	53                   	push   %ebx
  801540:	e8 ab f2 ff ff       	call   8007f0 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801545:	a1 80 50 80 00       	mov    0x805080,%eax
  80154a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801550:	a1 84 50 80 00       	mov    0x805084,%eax
  801555:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80155b:	83 c4 10             	add    $0x10,%esp
  80155e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801563:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801566:	c9                   	leave  
  801567:	c3                   	ret    

00801568 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801568:	55                   	push   %ebp
  801569:	89 e5                	mov    %esp,%ebp
  80156b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80156e:	8b 45 08             	mov    0x8(%ebp),%eax
  801571:	8b 40 0c             	mov    0xc(%eax),%eax
  801574:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801579:	ba 00 00 00 00       	mov    $0x0,%edx
  80157e:	b8 06 00 00 00       	mov    $0x6,%eax
  801583:	e8 3c ff ff ff       	call   8014c4 <fsipc>
}
  801588:	c9                   	leave  
  801589:	c3                   	ret    

0080158a <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80158a:	55                   	push   %ebp
  80158b:	89 e5                	mov    %esp,%ebp
  80158d:	56                   	push   %esi
  80158e:	53                   	push   %ebx
  80158f:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801592:	8b 45 08             	mov    0x8(%ebp),%eax
  801595:	8b 40 0c             	mov    0xc(%eax),%eax
  801598:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80159d:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8015a3:	ba 00 00 00 00       	mov    $0x0,%edx
  8015a8:	b8 03 00 00 00       	mov    $0x3,%eax
  8015ad:	e8 12 ff ff ff       	call   8014c4 <fsipc>
  8015b2:	89 c3                	mov    %eax,%ebx
  8015b4:	85 c0                	test   %eax,%eax
  8015b6:	78 4b                	js     801603 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8015b8:	39 c6                	cmp    %eax,%esi
  8015ba:	73 16                	jae    8015d2 <devfile_read+0x48>
  8015bc:	68 cd 23 80 00       	push   $0x8023cd
  8015c1:	68 d4 23 80 00       	push   $0x8023d4
  8015c6:	6a 7a                	push   $0x7a
  8015c8:	68 e9 23 80 00       	push   $0x8023e9
  8015cd:	e8 61 eb ff ff       	call   800133 <_panic>
	assert(r <= PGSIZE);
  8015d2:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8015d7:	7e 16                	jle    8015ef <devfile_read+0x65>
  8015d9:	68 f4 23 80 00       	push   $0x8023f4
  8015de:	68 d4 23 80 00       	push   $0x8023d4
  8015e3:	6a 7b                	push   $0x7b
  8015e5:	68 e9 23 80 00       	push   $0x8023e9
  8015ea:	e8 44 eb ff ff       	call   800133 <_panic>
	memmove(buf, &fsipcbuf, r);
  8015ef:	83 ec 04             	sub    $0x4,%esp
  8015f2:	50                   	push   %eax
  8015f3:	68 00 50 80 00       	push   $0x805000
  8015f8:	ff 75 0c             	pushl  0xc(%ebp)
  8015fb:	e8 bd f3 ff ff       	call   8009bd <memmove>
	return r;
  801600:	83 c4 10             	add    $0x10,%esp
}
  801603:	89 d8                	mov    %ebx,%eax
  801605:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801608:	5b                   	pop    %ebx
  801609:	5e                   	pop    %esi
  80160a:	5d                   	pop    %ebp
  80160b:	c3                   	ret    

0080160c <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80160c:	55                   	push   %ebp
  80160d:	89 e5                	mov    %esp,%ebp
  80160f:	53                   	push   %ebx
  801610:	83 ec 20             	sub    $0x20,%esp
  801613:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801616:	53                   	push   %ebx
  801617:	e8 7d f1 ff ff       	call   800799 <strlen>
  80161c:	83 c4 10             	add    $0x10,%esp
  80161f:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801624:	7f 63                	jg     801689 <open+0x7d>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801626:	83 ec 0c             	sub    $0xc,%esp
  801629:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80162c:	50                   	push   %eax
  80162d:	e8 e4 f8 ff ff       	call   800f16 <fd_alloc>
  801632:	83 c4 10             	add    $0x10,%esp
  801635:	85 c0                	test   %eax,%eax
  801637:	78 55                	js     80168e <open+0x82>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801639:	83 ec 08             	sub    $0x8,%esp
  80163c:	53                   	push   %ebx
  80163d:	68 00 50 80 00       	push   $0x805000
  801642:	e8 a9 f1 ff ff       	call   8007f0 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801647:	8b 45 0c             	mov    0xc(%ebp),%eax
  80164a:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80164f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801652:	b8 01 00 00 00       	mov    $0x1,%eax
  801657:	e8 68 fe ff ff       	call   8014c4 <fsipc>
  80165c:	89 c3                	mov    %eax,%ebx
  80165e:	83 c4 10             	add    $0x10,%esp
  801661:	85 c0                	test   %eax,%eax
  801663:	79 14                	jns    801679 <open+0x6d>
		fd_close(fd, 0);
  801665:	83 ec 08             	sub    $0x8,%esp
  801668:	6a 00                	push   $0x0
  80166a:	ff 75 f4             	pushl  -0xc(%ebp)
  80166d:	e8 dd f9 ff ff       	call   80104f <fd_close>
		return r;
  801672:	83 c4 10             	add    $0x10,%esp
  801675:	89 d8                	mov    %ebx,%eax
  801677:	eb 15                	jmp    80168e <open+0x82>
	}

	return fd2num(fd);
  801679:	83 ec 0c             	sub    $0xc,%esp
  80167c:	ff 75 f4             	pushl  -0xc(%ebp)
  80167f:	e8 6b f8 ff ff       	call   800eef <fd2num>
  801684:	83 c4 10             	add    $0x10,%esp
  801687:	eb 05                	jmp    80168e <open+0x82>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801689:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80168e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801691:	c9                   	leave  
  801692:	c3                   	ret    

00801693 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801693:	55                   	push   %ebp
  801694:	89 e5                	mov    %esp,%ebp
  801696:	56                   	push   %esi
  801697:	53                   	push   %ebx
  801698:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80169b:	83 ec 0c             	sub    $0xc,%esp
  80169e:	ff 75 08             	pushl  0x8(%ebp)
  8016a1:	e8 59 f8 ff ff       	call   800eff <fd2data>
  8016a6:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8016a8:	83 c4 08             	add    $0x8,%esp
  8016ab:	68 00 24 80 00       	push   $0x802400
  8016b0:	53                   	push   %ebx
  8016b1:	e8 3a f1 ff ff       	call   8007f0 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8016b6:	8b 46 04             	mov    0x4(%esi),%eax
  8016b9:	2b 06                	sub    (%esi),%eax
  8016bb:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8016c1:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016c8:	00 00 00 
	stat->st_dev = &devpipe;
  8016cb:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8016d2:	30 80 00 
	return 0;
}
  8016d5:	b8 00 00 00 00       	mov    $0x0,%eax
  8016da:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016dd:	5b                   	pop    %ebx
  8016de:	5e                   	pop    %esi
  8016df:	5d                   	pop    %ebp
  8016e0:	c3                   	ret    

008016e1 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8016e1:	55                   	push   %ebp
  8016e2:	89 e5                	mov    %esp,%ebp
  8016e4:	53                   	push   %ebx
  8016e5:	83 ec 0c             	sub    $0xc,%esp
  8016e8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8016eb:	53                   	push   %ebx
  8016ec:	6a 00                	push   $0x0
  8016ee:	e8 f2 f5 ff ff       	call   800ce5 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8016f3:	89 1c 24             	mov    %ebx,(%esp)
  8016f6:	e8 04 f8 ff ff       	call   800eff <fd2data>
  8016fb:	83 c4 08             	add    $0x8,%esp
  8016fe:	50                   	push   %eax
  8016ff:	6a 00                	push   $0x0
  801701:	e8 df f5 ff ff       	call   800ce5 <sys_page_unmap>
}
  801706:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801709:	c9                   	leave  
  80170a:	c3                   	ret    

0080170b <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80170b:	55                   	push   %ebp
  80170c:	89 e5                	mov    %esp,%ebp
  80170e:	57                   	push   %edi
  80170f:	56                   	push   %esi
  801710:	53                   	push   %ebx
  801711:	83 ec 1c             	sub    $0x1c,%esp
  801714:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801717:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801719:	a1 04 40 80 00       	mov    0x804004,%eax
  80171e:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801721:	83 ec 0c             	sub    $0xc,%esp
  801724:	ff 75 e0             	pushl  -0x20(%ebp)
  801727:	e8 8a 05 00 00       	call   801cb6 <pageref>
  80172c:	89 c3                	mov    %eax,%ebx
  80172e:	89 3c 24             	mov    %edi,(%esp)
  801731:	e8 80 05 00 00       	call   801cb6 <pageref>
  801736:	83 c4 10             	add    $0x10,%esp
  801739:	39 c3                	cmp    %eax,%ebx
  80173b:	0f 94 c1             	sete   %cl
  80173e:	0f b6 c9             	movzbl %cl,%ecx
  801741:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801744:	8b 15 04 40 80 00    	mov    0x804004,%edx
  80174a:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  80174d:	39 ce                	cmp    %ecx,%esi
  80174f:	74 1b                	je     80176c <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801751:	39 c3                	cmp    %eax,%ebx
  801753:	75 c4                	jne    801719 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801755:	8b 42 58             	mov    0x58(%edx),%eax
  801758:	ff 75 e4             	pushl  -0x1c(%ebp)
  80175b:	50                   	push   %eax
  80175c:	56                   	push   %esi
  80175d:	68 07 24 80 00       	push   $0x802407
  801762:	e8 a4 ea ff ff       	call   80020b <cprintf>
  801767:	83 c4 10             	add    $0x10,%esp
  80176a:	eb ad                	jmp    801719 <_pipeisclosed+0xe>
	}
}
  80176c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80176f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801772:	5b                   	pop    %ebx
  801773:	5e                   	pop    %esi
  801774:	5f                   	pop    %edi
  801775:	5d                   	pop    %ebp
  801776:	c3                   	ret    

00801777 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801777:	55                   	push   %ebp
  801778:	89 e5                	mov    %esp,%ebp
  80177a:	57                   	push   %edi
  80177b:	56                   	push   %esi
  80177c:	53                   	push   %ebx
  80177d:	83 ec 18             	sub    $0x18,%esp
  801780:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801783:	56                   	push   %esi
  801784:	e8 76 f7 ff ff       	call   800eff <fd2data>
  801789:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80178b:	83 c4 10             	add    $0x10,%esp
  80178e:	bf 00 00 00 00       	mov    $0x0,%edi
  801793:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801797:	75 42                	jne    8017db <devpipe_write+0x64>
  801799:	eb 4e                	jmp    8017e9 <devpipe_write+0x72>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80179b:	89 da                	mov    %ebx,%edx
  80179d:	89 f0                	mov    %esi,%eax
  80179f:	e8 67 ff ff ff       	call   80170b <_pipeisclosed>
  8017a4:	85 c0                	test   %eax,%eax
  8017a6:	75 46                	jne    8017ee <devpipe_write+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8017a8:	e8 94 f4 ff ff       	call   800c41 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8017ad:	8b 53 04             	mov    0x4(%ebx),%edx
  8017b0:	8b 03                	mov    (%ebx),%eax
  8017b2:	83 c0 20             	add    $0x20,%eax
  8017b5:	39 c2                	cmp    %eax,%edx
  8017b7:	73 e2                	jae    80179b <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8017b9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017bc:	8a 0c 38             	mov    (%eax,%edi,1),%cl
  8017bf:	89 d0                	mov    %edx,%eax
  8017c1:	25 1f 00 00 80       	and    $0x8000001f,%eax
  8017c6:	79 05                	jns    8017cd <devpipe_write+0x56>
  8017c8:	48                   	dec    %eax
  8017c9:	83 c8 e0             	or     $0xffffffe0,%eax
  8017cc:	40                   	inc    %eax
  8017cd:	88 4c 03 08          	mov    %cl,0x8(%ebx,%eax,1)
		p->p_wpos++;
  8017d1:	42                   	inc    %edx
  8017d2:	89 53 04             	mov    %edx,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8017d5:	47                   	inc    %edi
  8017d6:	39 7d 10             	cmp    %edi,0x10(%ebp)
  8017d9:	74 0e                	je     8017e9 <devpipe_write+0x72>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8017db:	8b 53 04             	mov    0x4(%ebx),%edx
  8017de:	8b 03                	mov    (%ebx),%eax
  8017e0:	83 c0 20             	add    $0x20,%eax
  8017e3:	39 c2                	cmp    %eax,%edx
  8017e5:	73 b4                	jae    80179b <devpipe_write+0x24>
  8017e7:	eb d0                	jmp    8017b9 <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8017e9:	8b 45 10             	mov    0x10(%ebp),%eax
  8017ec:	eb 05                	jmp    8017f3 <devpipe_write+0x7c>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8017ee:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8017f3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017f6:	5b                   	pop    %ebx
  8017f7:	5e                   	pop    %esi
  8017f8:	5f                   	pop    %edi
  8017f9:	5d                   	pop    %ebp
  8017fa:	c3                   	ret    

008017fb <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8017fb:	55                   	push   %ebp
  8017fc:	89 e5                	mov    %esp,%ebp
  8017fe:	57                   	push   %edi
  8017ff:	56                   	push   %esi
  801800:	53                   	push   %ebx
  801801:	83 ec 18             	sub    $0x18,%esp
  801804:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801807:	57                   	push   %edi
  801808:	e8 f2 f6 ff ff       	call   800eff <fd2data>
  80180d:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80180f:	83 c4 10             	add    $0x10,%esp
  801812:	be 00 00 00 00       	mov    $0x0,%esi
  801817:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80181b:	75 3d                	jne    80185a <devpipe_read+0x5f>
  80181d:	eb 48                	jmp    801867 <devpipe_read+0x6c>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  80181f:	89 f0                	mov    %esi,%eax
  801821:	eb 4e                	jmp    801871 <devpipe_read+0x76>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801823:	89 da                	mov    %ebx,%edx
  801825:	89 f8                	mov    %edi,%eax
  801827:	e8 df fe ff ff       	call   80170b <_pipeisclosed>
  80182c:	85 c0                	test   %eax,%eax
  80182e:	75 3c                	jne    80186c <devpipe_read+0x71>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801830:	e8 0c f4 ff ff       	call   800c41 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801835:	8b 03                	mov    (%ebx),%eax
  801837:	3b 43 04             	cmp    0x4(%ebx),%eax
  80183a:	74 e7                	je     801823 <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80183c:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801841:	79 05                	jns    801848 <devpipe_read+0x4d>
  801843:	48                   	dec    %eax
  801844:	83 c8 e0             	or     $0xffffffe0,%eax
  801847:	40                   	inc    %eax
  801848:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  80184c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80184f:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801852:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801854:	46                   	inc    %esi
  801855:	39 75 10             	cmp    %esi,0x10(%ebp)
  801858:	74 0d                	je     801867 <devpipe_read+0x6c>
		while (p->p_rpos == p->p_wpos) {
  80185a:	8b 03                	mov    (%ebx),%eax
  80185c:	3b 43 04             	cmp    0x4(%ebx),%eax
  80185f:	75 db                	jne    80183c <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801861:	85 f6                	test   %esi,%esi
  801863:	75 ba                	jne    80181f <devpipe_read+0x24>
  801865:	eb bc                	jmp    801823 <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801867:	8b 45 10             	mov    0x10(%ebp),%eax
  80186a:	eb 05                	jmp    801871 <devpipe_read+0x76>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80186c:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801871:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801874:	5b                   	pop    %ebx
  801875:	5e                   	pop    %esi
  801876:	5f                   	pop    %edi
  801877:	5d                   	pop    %ebp
  801878:	c3                   	ret    

00801879 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801879:	55                   	push   %ebp
  80187a:	89 e5                	mov    %esp,%ebp
  80187c:	56                   	push   %esi
  80187d:	53                   	push   %ebx
  80187e:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801881:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801884:	50                   	push   %eax
  801885:	e8 8c f6 ff ff       	call   800f16 <fd_alloc>
  80188a:	83 c4 10             	add    $0x10,%esp
  80188d:	85 c0                	test   %eax,%eax
  80188f:	0f 88 2a 01 00 00    	js     8019bf <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801895:	83 ec 04             	sub    $0x4,%esp
  801898:	68 07 04 00 00       	push   $0x407
  80189d:	ff 75 f4             	pushl  -0xc(%ebp)
  8018a0:	6a 00                	push   $0x0
  8018a2:	e8 b9 f3 ff ff       	call   800c60 <sys_page_alloc>
  8018a7:	83 c4 10             	add    $0x10,%esp
  8018aa:	85 c0                	test   %eax,%eax
  8018ac:	0f 88 0d 01 00 00    	js     8019bf <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8018b2:	83 ec 0c             	sub    $0xc,%esp
  8018b5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018b8:	50                   	push   %eax
  8018b9:	e8 58 f6 ff ff       	call   800f16 <fd_alloc>
  8018be:	89 c3                	mov    %eax,%ebx
  8018c0:	83 c4 10             	add    $0x10,%esp
  8018c3:	85 c0                	test   %eax,%eax
  8018c5:	0f 88 e2 00 00 00    	js     8019ad <pipe+0x134>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018cb:	83 ec 04             	sub    $0x4,%esp
  8018ce:	68 07 04 00 00       	push   $0x407
  8018d3:	ff 75 f0             	pushl  -0x10(%ebp)
  8018d6:	6a 00                	push   $0x0
  8018d8:	e8 83 f3 ff ff       	call   800c60 <sys_page_alloc>
  8018dd:	89 c3                	mov    %eax,%ebx
  8018df:	83 c4 10             	add    $0x10,%esp
  8018e2:	85 c0                	test   %eax,%eax
  8018e4:	0f 88 c3 00 00 00    	js     8019ad <pipe+0x134>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8018ea:	83 ec 0c             	sub    $0xc,%esp
  8018ed:	ff 75 f4             	pushl  -0xc(%ebp)
  8018f0:	e8 0a f6 ff ff       	call   800eff <fd2data>
  8018f5:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018f7:	83 c4 0c             	add    $0xc,%esp
  8018fa:	68 07 04 00 00       	push   $0x407
  8018ff:	50                   	push   %eax
  801900:	6a 00                	push   $0x0
  801902:	e8 59 f3 ff ff       	call   800c60 <sys_page_alloc>
  801907:	89 c3                	mov    %eax,%ebx
  801909:	83 c4 10             	add    $0x10,%esp
  80190c:	85 c0                	test   %eax,%eax
  80190e:	0f 88 89 00 00 00    	js     80199d <pipe+0x124>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801914:	83 ec 0c             	sub    $0xc,%esp
  801917:	ff 75 f0             	pushl  -0x10(%ebp)
  80191a:	e8 e0 f5 ff ff       	call   800eff <fd2data>
  80191f:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801926:	50                   	push   %eax
  801927:	6a 00                	push   $0x0
  801929:	56                   	push   %esi
  80192a:	6a 00                	push   $0x0
  80192c:	e8 72 f3 ff ff       	call   800ca3 <sys_page_map>
  801931:	89 c3                	mov    %eax,%ebx
  801933:	83 c4 20             	add    $0x20,%esp
  801936:	85 c0                	test   %eax,%eax
  801938:	78 55                	js     80198f <pipe+0x116>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80193a:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801940:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801943:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801945:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801948:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80194f:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801955:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801958:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80195a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80195d:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801964:	83 ec 0c             	sub    $0xc,%esp
  801967:	ff 75 f4             	pushl  -0xc(%ebp)
  80196a:	e8 80 f5 ff ff       	call   800eef <fd2num>
  80196f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801972:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801974:	83 c4 04             	add    $0x4,%esp
  801977:	ff 75 f0             	pushl  -0x10(%ebp)
  80197a:	e8 70 f5 ff ff       	call   800eef <fd2num>
  80197f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801982:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801985:	83 c4 10             	add    $0x10,%esp
  801988:	b8 00 00 00 00       	mov    $0x0,%eax
  80198d:	eb 30                	jmp    8019bf <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  80198f:	83 ec 08             	sub    $0x8,%esp
  801992:	56                   	push   %esi
  801993:	6a 00                	push   $0x0
  801995:	e8 4b f3 ff ff       	call   800ce5 <sys_page_unmap>
  80199a:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80199d:	83 ec 08             	sub    $0x8,%esp
  8019a0:	ff 75 f0             	pushl  -0x10(%ebp)
  8019a3:	6a 00                	push   $0x0
  8019a5:	e8 3b f3 ff ff       	call   800ce5 <sys_page_unmap>
  8019aa:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8019ad:	83 ec 08             	sub    $0x8,%esp
  8019b0:	ff 75 f4             	pushl  -0xc(%ebp)
  8019b3:	6a 00                	push   $0x0
  8019b5:	e8 2b f3 ff ff       	call   800ce5 <sys_page_unmap>
  8019ba:	83 c4 10             	add    $0x10,%esp
  8019bd:	89 d8                	mov    %ebx,%eax
    err:
	return r;
}
  8019bf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019c2:	5b                   	pop    %ebx
  8019c3:	5e                   	pop    %esi
  8019c4:	5d                   	pop    %ebp
  8019c5:	c3                   	ret    

008019c6 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8019c6:	55                   	push   %ebp
  8019c7:	89 e5                	mov    %esp,%ebp
  8019c9:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8019cc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019cf:	50                   	push   %eax
  8019d0:	ff 75 08             	pushl  0x8(%ebp)
  8019d3:	e8 b2 f5 ff ff       	call   800f8a <fd_lookup>
  8019d8:	83 c4 10             	add    $0x10,%esp
  8019db:	85 c0                	test   %eax,%eax
  8019dd:	78 18                	js     8019f7 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8019df:	83 ec 0c             	sub    $0xc,%esp
  8019e2:	ff 75 f4             	pushl  -0xc(%ebp)
  8019e5:	e8 15 f5 ff ff       	call   800eff <fd2data>
	return _pipeisclosed(fd, p);
  8019ea:	89 c2                	mov    %eax,%edx
  8019ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019ef:	e8 17 fd ff ff       	call   80170b <_pipeisclosed>
  8019f4:	83 c4 10             	add    $0x10,%esp
}
  8019f7:	c9                   	leave  
  8019f8:	c3                   	ret    

008019f9 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8019f9:	55                   	push   %ebp
  8019fa:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8019fc:	b8 00 00 00 00       	mov    $0x0,%eax
  801a01:	5d                   	pop    %ebp
  801a02:	c3                   	ret    

00801a03 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801a03:	55                   	push   %ebp
  801a04:	89 e5                	mov    %esp,%ebp
  801a06:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801a09:	68 1f 24 80 00       	push   $0x80241f
  801a0e:	ff 75 0c             	pushl  0xc(%ebp)
  801a11:	e8 da ed ff ff       	call   8007f0 <strcpy>
	return 0;
}
  801a16:	b8 00 00 00 00       	mov    $0x0,%eax
  801a1b:	c9                   	leave  
  801a1c:	c3                   	ret    

00801a1d <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a1d:	55                   	push   %ebp
  801a1e:	89 e5                	mov    %esp,%ebp
  801a20:	57                   	push   %edi
  801a21:	56                   	push   %esi
  801a22:	53                   	push   %ebx
  801a23:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801a29:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801a2d:	74 45                	je     801a74 <devcons_write+0x57>
  801a2f:	b8 00 00 00 00       	mov    $0x0,%eax
  801a34:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801a39:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801a3f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801a42:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  801a44:	83 fb 7f             	cmp    $0x7f,%ebx
  801a47:	76 05                	jbe    801a4e <devcons_write+0x31>
			m = sizeof(buf) - 1;
  801a49:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801a4e:	83 ec 04             	sub    $0x4,%esp
  801a51:	53                   	push   %ebx
  801a52:	03 45 0c             	add    0xc(%ebp),%eax
  801a55:	50                   	push   %eax
  801a56:	57                   	push   %edi
  801a57:	e8 61 ef ff ff       	call   8009bd <memmove>
		sys_cputs(buf, m);
  801a5c:	83 c4 08             	add    $0x8,%esp
  801a5f:	53                   	push   %ebx
  801a60:	57                   	push   %edi
  801a61:	e8 3e f1 ff ff       	call   800ba4 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801a66:	01 de                	add    %ebx,%esi
  801a68:	89 f0                	mov    %esi,%eax
  801a6a:	83 c4 10             	add    $0x10,%esp
  801a6d:	3b 75 10             	cmp    0x10(%ebp),%esi
  801a70:	72 cd                	jb     801a3f <devcons_write+0x22>
  801a72:	eb 05                	jmp    801a79 <devcons_write+0x5c>
  801a74:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801a79:	89 f0                	mov    %esi,%eax
  801a7b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a7e:	5b                   	pop    %ebx
  801a7f:	5e                   	pop    %esi
  801a80:	5f                   	pop    %edi
  801a81:	5d                   	pop    %ebp
  801a82:	c3                   	ret    

00801a83 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801a83:	55                   	push   %ebp
  801a84:	89 e5                	mov    %esp,%ebp
  801a86:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801a89:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801a8d:	75 07                	jne    801a96 <devcons_read+0x13>
  801a8f:	eb 23                	jmp    801ab4 <devcons_read+0x31>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801a91:	e8 ab f1 ff ff       	call   800c41 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801a96:	e8 27 f1 ff ff       	call   800bc2 <sys_cgetc>
  801a9b:	85 c0                	test   %eax,%eax
  801a9d:	74 f2                	je     801a91 <devcons_read+0xe>
		sys_yield();
	if (c < 0)
  801a9f:	85 c0                	test   %eax,%eax
  801aa1:	78 1d                	js     801ac0 <devcons_read+0x3d>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801aa3:	83 f8 04             	cmp    $0x4,%eax
  801aa6:	74 13                	je     801abb <devcons_read+0x38>
		return 0;
	*(char*)vbuf = c;
  801aa8:	8b 55 0c             	mov    0xc(%ebp),%edx
  801aab:	88 02                	mov    %al,(%edx)
	return 1;
  801aad:	b8 01 00 00 00       	mov    $0x1,%eax
  801ab2:	eb 0c                	jmp    801ac0 <devcons_read+0x3d>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801ab4:	b8 00 00 00 00       	mov    $0x0,%eax
  801ab9:	eb 05                	jmp    801ac0 <devcons_read+0x3d>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801abb:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801ac0:	c9                   	leave  
  801ac1:	c3                   	ret    

00801ac2 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801ac2:	55                   	push   %ebp
  801ac3:	89 e5                	mov    %esp,%ebp
  801ac5:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801ac8:	8b 45 08             	mov    0x8(%ebp),%eax
  801acb:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801ace:	6a 01                	push   $0x1
  801ad0:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ad3:	50                   	push   %eax
  801ad4:	e8 cb f0 ff ff       	call   800ba4 <sys_cputs>
}
  801ad9:	83 c4 10             	add    $0x10,%esp
  801adc:	c9                   	leave  
  801add:	c3                   	ret    

00801ade <getchar>:

int
getchar(void)
{
  801ade:	55                   	push   %ebp
  801adf:	89 e5                	mov    %esp,%ebp
  801ae1:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801ae4:	6a 01                	push   $0x1
  801ae6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ae9:	50                   	push   %eax
  801aea:	6a 00                	push   $0x0
  801aec:	e8 1a f7 ff ff       	call   80120b <read>
	if (r < 0)
  801af1:	83 c4 10             	add    $0x10,%esp
  801af4:	85 c0                	test   %eax,%eax
  801af6:	78 0f                	js     801b07 <getchar+0x29>
		return r;
	if (r < 1)
  801af8:	85 c0                	test   %eax,%eax
  801afa:	7e 06                	jle    801b02 <getchar+0x24>
		return -E_EOF;
	return c;
  801afc:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801b00:	eb 05                	jmp    801b07 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801b02:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801b07:	c9                   	leave  
  801b08:	c3                   	ret    

00801b09 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801b09:	55                   	push   %ebp
  801b0a:	89 e5                	mov    %esp,%ebp
  801b0c:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b0f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b12:	50                   	push   %eax
  801b13:	ff 75 08             	pushl  0x8(%ebp)
  801b16:	e8 6f f4 ff ff       	call   800f8a <fd_lookup>
  801b1b:	83 c4 10             	add    $0x10,%esp
  801b1e:	85 c0                	test   %eax,%eax
  801b20:	78 11                	js     801b33 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801b22:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b25:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801b2b:	39 10                	cmp    %edx,(%eax)
  801b2d:	0f 94 c0             	sete   %al
  801b30:	0f b6 c0             	movzbl %al,%eax
}
  801b33:	c9                   	leave  
  801b34:	c3                   	ret    

00801b35 <opencons>:

int
opencons(void)
{
  801b35:	55                   	push   %ebp
  801b36:	89 e5                	mov    %esp,%ebp
  801b38:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801b3b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b3e:	50                   	push   %eax
  801b3f:	e8 d2 f3 ff ff       	call   800f16 <fd_alloc>
  801b44:	83 c4 10             	add    $0x10,%esp
  801b47:	85 c0                	test   %eax,%eax
  801b49:	78 3a                	js     801b85 <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801b4b:	83 ec 04             	sub    $0x4,%esp
  801b4e:	68 07 04 00 00       	push   $0x407
  801b53:	ff 75 f4             	pushl  -0xc(%ebp)
  801b56:	6a 00                	push   $0x0
  801b58:	e8 03 f1 ff ff       	call   800c60 <sys_page_alloc>
  801b5d:	83 c4 10             	add    $0x10,%esp
  801b60:	85 c0                	test   %eax,%eax
  801b62:	78 21                	js     801b85 <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801b64:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801b6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b6d:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801b6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b72:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801b79:	83 ec 0c             	sub    $0xc,%esp
  801b7c:	50                   	push   %eax
  801b7d:	e8 6d f3 ff ff       	call   800eef <fd2num>
  801b82:	83 c4 10             	add    $0x10,%esp
}
  801b85:	c9                   	leave  
  801b86:	c3                   	ret    

00801b87 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801b87:	55                   	push   %ebp
  801b88:	89 e5                	mov    %esp,%ebp
  801b8a:	56                   	push   %esi
  801b8b:	53                   	push   %ebx
  801b8c:	8b 75 08             	mov    0x8(%ebp),%esi
  801b8f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b92:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");
	int r;
    if (pg != NULL) {
  801b95:	85 c0                	test   %eax,%eax
  801b97:	74 0e                	je     801ba7 <ipc_recv+0x20>
        r = sys_ipc_recv(pg);
  801b99:	83 ec 0c             	sub    $0xc,%esp
  801b9c:	50                   	push   %eax
  801b9d:	e8 6e f2 ff ff       	call   800e10 <sys_ipc_recv>
  801ba2:	83 c4 10             	add    $0x10,%esp
  801ba5:	eb 10                	jmp    801bb7 <ipc_recv+0x30>
    } else {
        r = sys_ipc_recv((void *) UTOP);
  801ba7:	83 ec 0c             	sub    $0xc,%esp
  801baa:	68 00 00 c0 ee       	push   $0xeec00000
  801baf:	e8 5c f2 ff ff       	call   800e10 <sys_ipc_recv>
  801bb4:	83 c4 10             	add    $0x10,%esp
    }
    if (r < 0) {
  801bb7:	85 c0                	test   %eax,%eax
  801bb9:	79 16                	jns    801bd1 <ipc_recv+0x4a>
        // failed
        if (from_env_store != NULL) *from_env_store = 0;
  801bbb:	85 f6                	test   %esi,%esi
  801bbd:	74 06                	je     801bc5 <ipc_recv+0x3e>
  801bbf:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        if (perm_store != NULL) *perm_store = 0;
  801bc5:	85 db                	test   %ebx,%ebx
  801bc7:	74 2c                	je     801bf5 <ipc_recv+0x6e>
  801bc9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801bcf:	eb 24                	jmp    801bf5 <ipc_recv+0x6e>
        return r;
    } else {
        if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801bd1:	85 f6                	test   %esi,%esi
  801bd3:	74 0a                	je     801bdf <ipc_recv+0x58>
  801bd5:	a1 04 40 80 00       	mov    0x804004,%eax
  801bda:	8b 40 74             	mov    0x74(%eax),%eax
  801bdd:	89 06                	mov    %eax,(%esi)
        if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801bdf:	85 db                	test   %ebx,%ebx
  801be1:	74 0a                	je     801bed <ipc_recv+0x66>
  801be3:	a1 04 40 80 00       	mov    0x804004,%eax
  801be8:	8b 40 78             	mov    0x78(%eax),%eax
  801beb:	89 03                	mov    %eax,(%ebx)
        return thisenv->env_ipc_value;
  801bed:	a1 04 40 80 00       	mov    0x804004,%eax
  801bf2:	8b 40 70             	mov    0x70(%eax),%eax
    }
 
	return 0;
}
  801bf5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bf8:	5b                   	pop    %ebx
  801bf9:	5e                   	pop    %esi
  801bfa:	5d                   	pop    %ebp
  801bfb:	c3                   	ret    

00801bfc <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801bfc:	55                   	push   %ebp
  801bfd:	89 e5                	mov    %esp,%ebp
  801bff:	57                   	push   %edi
  801c00:	56                   	push   %esi
  801c01:	53                   	push   %ebx
  801c02:	83 ec 0c             	sub    $0xc,%esp
  801c05:	8b 75 10             	mov    0x10(%ebp),%esi
  801c08:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");
	int r;
    if (pg == NULL) pg = (void *)UTOP;
  801c0b:	85 f6                	test   %esi,%esi
  801c0d:	75 05                	jne    801c14 <ipc_send+0x18>
  801c0f:	be 00 00 c0 ee       	mov    $0xeec00000,%esi
    do {
        r = sys_ipc_try_send(to_env, val, pg, perm);
  801c14:	57                   	push   %edi
  801c15:	56                   	push   %esi
  801c16:	ff 75 0c             	pushl  0xc(%ebp)
  801c19:	ff 75 08             	pushl  0x8(%ebp)
  801c1c:	e8 cc f1 ff ff       	call   800ded <sys_ipc_try_send>
  801c21:	89 c3                	mov    %eax,%ebx
        if (r < 0 && r != -E_IPC_NOT_RECV) panic("ipc send failed: %e", r);
  801c23:	83 c4 10             	add    $0x10,%esp
  801c26:	85 c0                	test   %eax,%eax
  801c28:	79 17                	jns    801c41 <ipc_send+0x45>
  801c2a:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801c2d:	74 1d                	je     801c4c <ipc_send+0x50>
  801c2f:	50                   	push   %eax
  801c30:	68 2b 24 80 00       	push   $0x80242b
  801c35:	6a 40                	push   $0x40
  801c37:	68 3f 24 80 00       	push   $0x80243f
  801c3c:	e8 f2 e4 ff ff       	call   800133 <_panic>
        sys_yield();
  801c41:	e8 fb ef ff ff       	call   800c41 <sys_yield>
    } while (r != 0);
  801c46:	85 db                	test   %ebx,%ebx
  801c48:	75 ca                	jne    801c14 <ipc_send+0x18>
  801c4a:	eb 07                	jmp    801c53 <ipc_send+0x57>
	int r;
    if (pg == NULL) pg = (void *)UTOP;
    do {
        r = sys_ipc_try_send(to_env, val, pg, perm);
        if (r < 0 && r != -E_IPC_NOT_RECV) panic("ipc send failed: %e", r);
        sys_yield();
  801c4c:	e8 f0 ef ff ff       	call   800c41 <sys_yield>
  801c51:	eb c1                	jmp    801c14 <ipc_send+0x18>
    } while (r != 0);
}
  801c53:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c56:	5b                   	pop    %ebx
  801c57:	5e                   	pop    %esi
  801c58:	5f                   	pop    %edi
  801c59:	5d                   	pop    %ebp
  801c5a:	c3                   	ret    

00801c5b <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801c5b:	55                   	push   %ebp
  801c5c:	89 e5                	mov    %esp,%ebp
  801c5e:	53                   	push   %ebx
  801c5f:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801c62:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  801c67:	39 c1                	cmp    %eax,%ecx
  801c69:	74 21                	je     801c8c <ipc_find_env+0x31>
  801c6b:	ba 01 00 00 00       	mov    $0x1,%edx
  801c70:	8d 1c 95 00 00 00 00 	lea    0x0(,%edx,4),%ebx
  801c77:	89 d0                	mov    %edx,%eax
  801c79:	c1 e0 07             	shl    $0x7,%eax
  801c7c:	29 d8                	sub    %ebx,%eax
  801c7e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801c83:	8b 40 50             	mov    0x50(%eax),%eax
  801c86:	39 c8                	cmp    %ecx,%eax
  801c88:	75 1b                	jne    801ca5 <ipc_find_env+0x4a>
  801c8a:	eb 05                	jmp    801c91 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801c8c:	ba 00 00 00 00       	mov    $0x0,%edx
		if (envs[i].env_type == type)
			return envs[i].env_id;
  801c91:	8d 04 95 00 00 00 00 	lea    0x0(,%edx,4),%eax
  801c98:	c1 e2 07             	shl    $0x7,%edx
  801c9b:	29 c2                	sub    %eax,%edx
  801c9d:	8b 82 48 00 c0 ee    	mov    -0x113fffb8(%edx),%eax
  801ca3:	eb 0e                	jmp    801cb3 <ipc_find_env+0x58>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801ca5:	42                   	inc    %edx
  801ca6:	81 fa 00 04 00 00    	cmp    $0x400,%edx
  801cac:	75 c2                	jne    801c70 <ipc_find_env+0x15>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801cae:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801cb3:	5b                   	pop    %ebx
  801cb4:	5d                   	pop    %ebp
  801cb5:	c3                   	ret    

00801cb6 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801cb6:	55                   	push   %ebp
  801cb7:	89 e5                	mov    %esp,%ebp
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801cb9:	8b 45 08             	mov    0x8(%ebp),%eax
  801cbc:	c1 e8 16             	shr    $0x16,%eax
  801cbf:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801cc6:	a8 01                	test   $0x1,%al
  801cc8:	74 21                	je     801ceb <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801cca:	8b 45 08             	mov    0x8(%ebp),%eax
  801ccd:	c1 e8 0c             	shr    $0xc,%eax
  801cd0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801cd7:	a8 01                	test   $0x1,%al
  801cd9:	74 17                	je     801cf2 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801cdb:	c1 e8 0c             	shr    $0xc,%eax
  801cde:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801ce5:	ef 
  801ce6:	0f b7 c0             	movzwl %ax,%eax
  801ce9:	eb 0c                	jmp    801cf7 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801ceb:	b8 00 00 00 00       	mov    $0x0,%eax
  801cf0:	eb 05                	jmp    801cf7 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801cf2:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801cf7:	5d                   	pop    %ebp
  801cf8:	c3                   	ret    
  801cf9:	66 90                	xchg   %ax,%ax
  801cfb:	90                   	nop

00801cfc <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801cfc:	55                   	push   %ebp
  801cfd:	57                   	push   %edi
  801cfe:	56                   	push   %esi
  801cff:	53                   	push   %ebx
  801d00:	83 ec 1c             	sub    $0x1c,%esp
  801d03:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801d07:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801d0b:	8b 7c 24 38          	mov    0x38(%esp),%edi
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801d0f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801d13:	89 ca                	mov    %ecx,%edx
  const DWunion dd = {.ll = d};
  801d15:	89 f8                	mov    %edi,%eax
  801d17:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801d1b:	85 f6                	test   %esi,%esi
  801d1d:	75 2d                	jne    801d4c <__udivdi3+0x50>
    {
      if (d0 > n1)
  801d1f:	39 cf                	cmp    %ecx,%edi
  801d21:	77 65                	ja     801d88 <__udivdi3+0x8c>
  801d23:	89 fd                	mov    %edi,%ebp
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801d25:	85 ff                	test   %edi,%edi
  801d27:	75 0b                	jne    801d34 <__udivdi3+0x38>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801d29:	b8 01 00 00 00       	mov    $0x1,%eax
  801d2e:	31 d2                	xor    %edx,%edx
  801d30:	f7 f7                	div    %edi
  801d32:	89 c5                	mov    %eax,%ebp

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801d34:	31 d2                	xor    %edx,%edx
  801d36:	89 c8                	mov    %ecx,%eax
  801d38:	f7 f5                	div    %ebp
  801d3a:	89 c1                	mov    %eax,%ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801d3c:	89 d8                	mov    %ebx,%eax
  801d3e:	f7 f5                	div    %ebp
  801d40:	89 cf                	mov    %ecx,%edi
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
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801d4c:	39 ce                	cmp    %ecx,%esi
  801d4e:	77 28                	ja     801d78 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801d50:	0f bd fe             	bsr    %esi,%edi
	  if (bm == 0)
  801d53:	83 f7 1f             	xor    $0x1f,%edi
  801d56:	75 40                	jne    801d98 <__udivdi3+0x9c>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801d58:	39 ce                	cmp    %ecx,%esi
  801d5a:	72 0a                	jb     801d66 <__udivdi3+0x6a>
  801d5c:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801d60:	0f 87 9e 00 00 00    	ja     801e04 <__udivdi3+0x108>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801d66:	b8 01 00 00 00       	mov    $0x1,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801d6b:	89 fa                	mov    %edi,%edx
  801d6d:	83 c4 1c             	add    $0x1c,%esp
  801d70:	5b                   	pop    %ebx
  801d71:	5e                   	pop    %esi
  801d72:	5f                   	pop    %edi
  801d73:	5d                   	pop    %ebp
  801d74:	c3                   	ret    
  801d75:	8d 76 00             	lea    0x0(%esi),%esi
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801d78:	31 ff                	xor    %edi,%edi
  801d7a:	31 c0                	xor    %eax,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801d7c:	89 fa                	mov    %edi,%edx
  801d7e:	83 c4 1c             	add    $0x1c,%esp
  801d81:	5b                   	pop    %ebx
  801d82:	5e                   	pop    %esi
  801d83:	5f                   	pop    %edi
  801d84:	5d                   	pop    %ebp
  801d85:	c3                   	ret    
  801d86:	66 90                	xchg   %ax,%ax
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801d88:	89 d8                	mov    %ebx,%eax
  801d8a:	f7 f7                	div    %edi
  801d8c:	31 ff                	xor    %edi,%edi
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801d8e:	89 fa                	mov    %edi,%edx
  801d90:	83 c4 1c             	add    $0x1c,%esp
  801d93:	5b                   	pop    %ebx
  801d94:	5e                   	pop    %esi
  801d95:	5f                   	pop    %edi
  801d96:	5d                   	pop    %ebp
  801d97:	c3                   	ret    
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801d98:	bd 20 00 00 00       	mov    $0x20,%ebp
  801d9d:	89 eb                	mov    %ebp,%ebx
  801d9f:	29 fb                	sub    %edi,%ebx

	      d1 = (d1 << bm) | (d0 >> b);
  801da1:	89 f9                	mov    %edi,%ecx
  801da3:	d3 e6                	shl    %cl,%esi
  801da5:	89 c5                	mov    %eax,%ebp
  801da7:	88 d9                	mov    %bl,%cl
  801da9:	d3 ed                	shr    %cl,%ebp
  801dab:	89 e9                	mov    %ebp,%ecx
  801dad:	09 f1                	or     %esi,%ecx
  801daf:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
	      d0 = d0 << bm;
  801db3:	89 f9                	mov    %edi,%ecx
  801db5:	d3 e0                	shl    %cl,%eax
  801db7:	89 c5                	mov    %eax,%ebp
	      n2 = n1 >> b;
  801db9:	89 d6                	mov    %edx,%esi
  801dbb:	88 d9                	mov    %bl,%cl
  801dbd:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
  801dbf:	89 f9                	mov    %edi,%ecx
  801dc1:	d3 e2                	shl    %cl,%edx
  801dc3:	8b 44 24 08          	mov    0x8(%esp),%eax
  801dc7:	88 d9                	mov    %bl,%cl
  801dc9:	d3 e8                	shr    %cl,%eax
  801dcb:	09 c2                	or     %eax,%edx
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801dcd:	89 d0                	mov    %edx,%eax
  801dcf:	89 f2                	mov    %esi,%edx
  801dd1:	f7 74 24 0c          	divl   0xc(%esp)
  801dd5:	89 d6                	mov    %edx,%esi
  801dd7:	89 c3                	mov    %eax,%ebx
	      umul_ppmm (m1, m0, q0, d0);
  801dd9:	f7 e5                	mul    %ebp

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801ddb:	39 d6                	cmp    %edx,%esi
  801ddd:	72 19                	jb     801df8 <__udivdi3+0xfc>
  801ddf:	74 0b                	je     801dec <__udivdi3+0xf0>
  801de1:	89 d8                	mov    %ebx,%eax
  801de3:	31 ff                	xor    %edi,%edi
  801de5:	e9 58 ff ff ff       	jmp    801d42 <__udivdi3+0x46>
  801dea:	66 90                	xchg   %ax,%ax
  801dec:	8b 54 24 08          	mov    0x8(%esp),%edx
  801df0:	89 f9                	mov    %edi,%ecx
  801df2:	d3 e2                	shl    %cl,%edx
  801df4:	39 c2                	cmp    %eax,%edx
  801df6:	73 e9                	jae    801de1 <__udivdi3+0xe5>
  801df8:	8d 43 ff             	lea    -0x1(%ebx),%eax
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801dfb:	31 ff                	xor    %edi,%edi
  801dfd:	e9 40 ff ff ff       	jmp    801d42 <__udivdi3+0x46>
  801e02:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801e04:	31 c0                	xor    %eax,%eax
  801e06:	e9 37 ff ff ff       	jmp    801d42 <__udivdi3+0x46>
  801e0b:	90                   	nop

00801e0c <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  801e0c:	55                   	push   %ebp
  801e0d:	57                   	push   %edi
  801e0e:	56                   	push   %esi
  801e0f:	53                   	push   %ebx
  801e10:	83 ec 1c             	sub    $0x1c,%esp
  801e13:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801e17:	8b 74 24 34          	mov    0x34(%esp),%esi
  801e1b:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801e1f:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801e23:	89 44 24 0c          	mov    %eax,0xc(%esp)
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801e27:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801e2b:	89 f3                	mov    %esi,%ebx
  const DWunion dd = {.ll = d};
  801e2d:	89 fa                	mov    %edi,%edx
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  801e2f:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  n1 = nn.s.high;
  801e33:	89 34 24             	mov    %esi,(%esp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801e36:	85 c0                	test   %eax,%eax
  801e38:	75 1a                	jne    801e54 <__umoddi3+0x48>
    {
      if (d0 > n1)
  801e3a:	39 f7                	cmp    %esi,%edi
  801e3c:	0f 86 a2 00 00 00    	jbe    801ee4 <__umoddi3+0xd8>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801e42:	89 c8                	mov    %ecx,%eax
  801e44:	89 f2                	mov    %esi,%edx
  801e46:	f7 f7                	div    %edi
  801e48:	89 d0                	mov    %edx,%eax

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  801e4a:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801e4c:	83 c4 1c             	add    $0x1c,%esp
  801e4f:	5b                   	pop    %ebx
  801e50:	5e                   	pop    %esi
  801e51:	5f                   	pop    %edi
  801e52:	5d                   	pop    %ebp
  801e53:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801e54:	39 f0                	cmp    %esi,%eax
  801e56:	0f 87 ac 00 00 00    	ja     801f08 <__umoddi3+0xfc>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801e5c:	0f bd e8             	bsr    %eax,%ebp
	  if (bm == 0)
  801e5f:	83 f5 1f             	xor    $0x1f,%ebp
  801e62:	0f 84 ac 00 00 00    	je     801f14 <__umoddi3+0x108>
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801e68:	bf 20 00 00 00       	mov    $0x20,%edi
  801e6d:	29 ef                	sub    %ebp,%edi
  801e6f:	89 fe                	mov    %edi,%esi
  801e71:	89 7c 24 0c          	mov    %edi,0xc(%esp)

	      d1 = (d1 << bm) | (d0 >> b);
  801e75:	89 e9                	mov    %ebp,%ecx
  801e77:	d3 e0                	shl    %cl,%eax
  801e79:	89 d7                	mov    %edx,%edi
  801e7b:	89 f1                	mov    %esi,%ecx
  801e7d:	d3 ef                	shr    %cl,%edi
  801e7f:	09 c7                	or     %eax,%edi
	      d0 = d0 << bm;
  801e81:	89 e9                	mov    %ebp,%ecx
  801e83:	d3 e2                	shl    %cl,%edx
  801e85:	89 14 24             	mov    %edx,(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801e88:	89 d8                	mov    %ebx,%eax
  801e8a:	d3 e0                	shl    %cl,%eax
  801e8c:	89 c2                	mov    %eax,%edx
	      n0 = n0 << bm;
  801e8e:	8b 44 24 08          	mov    0x8(%esp),%eax
  801e92:	d3 e0                	shl    %cl,%eax
  801e94:	89 44 24 04          	mov    %eax,0x4(%esp)

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801e98:	8b 44 24 08          	mov    0x8(%esp),%eax
  801e9c:	89 f1                	mov    %esi,%ecx
  801e9e:	d3 e8                	shr    %cl,%eax
  801ea0:	09 d0                	or     %edx,%eax
  801ea2:	d3 eb                	shr    %cl,%ebx
  801ea4:	89 da                	mov    %ebx,%edx
  801ea6:	f7 f7                	div    %edi
  801ea8:	89 d3                	mov    %edx,%ebx
	      umul_ppmm (m1, m0, q0, d0);
  801eaa:	f7 24 24             	mull   (%esp)
  801ead:	89 c6                	mov    %eax,%esi
  801eaf:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801eb1:	39 d3                	cmp    %edx,%ebx
  801eb3:	0f 82 87 00 00 00    	jb     801f40 <__umoddi3+0x134>
  801eb9:	0f 84 91 00 00 00    	je     801f50 <__umoddi3+0x144>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  801ebf:	8b 54 24 04          	mov    0x4(%esp),%edx
  801ec3:	29 f2                	sub    %esi,%edx
  801ec5:	19 cb                	sbb    %ecx,%ebx
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801ec7:	89 d8                	mov    %ebx,%eax
  801ec9:	8a 4c 24 0c          	mov    0xc(%esp),%cl
  801ecd:	d3 e0                	shl    %cl,%eax
  801ecf:	89 e9                	mov    %ebp,%ecx
  801ed1:	d3 ea                	shr    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  801ed3:	09 d0                	or     %edx,%eax
  801ed5:	89 e9                	mov    %ebp,%ecx
  801ed7:	d3 eb                	shr    %cl,%ebx
  801ed9:	89 da                	mov    %ebx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801edb:	83 c4 1c             	add    $0x1c,%esp
  801ede:	5b                   	pop    %ebx
  801edf:	5e                   	pop    %esi
  801ee0:	5f                   	pop    %edi
  801ee1:	5d                   	pop    %ebp
  801ee2:	c3                   	ret    
  801ee3:	90                   	nop
  801ee4:	89 fd                	mov    %edi,%ebp
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801ee6:	85 ff                	test   %edi,%edi
  801ee8:	75 0b                	jne    801ef5 <__umoddi3+0xe9>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801eea:	b8 01 00 00 00       	mov    $0x1,%eax
  801eef:	31 d2                	xor    %edx,%edx
  801ef1:	f7 f7                	div    %edi
  801ef3:	89 c5                	mov    %eax,%ebp

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801ef5:	89 f0                	mov    %esi,%eax
  801ef7:	31 d2                	xor    %edx,%edx
  801ef9:	f7 f5                	div    %ebp
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801efb:	89 c8                	mov    %ecx,%eax
  801efd:	f7 f5                	div    %ebp
  801eff:	89 d0                	mov    %edx,%eax
  801f01:	e9 44 ff ff ff       	jmp    801e4a <__umoddi3+0x3e>
  801f06:	66 90                	xchg   %ax,%ax
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  801f08:	89 c8                	mov    %ecx,%eax
  801f0a:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801f0c:	83 c4 1c             	add    $0x1c,%esp
  801f0f:	5b                   	pop    %ebx
  801f10:	5e                   	pop    %esi
  801f11:	5f                   	pop    %edi
  801f12:	5d                   	pop    %ebp
  801f13:	c3                   	ret    

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801f14:	3b 04 24             	cmp    (%esp),%eax
  801f17:	72 06                	jb     801f1f <__umoddi3+0x113>
  801f19:	3b 7c 24 04          	cmp    0x4(%esp),%edi
  801f1d:	77 0f                	ja     801f2e <__umoddi3+0x122>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801f1f:	89 f2                	mov    %esi,%edx
  801f21:	29 f9                	sub    %edi,%ecx
  801f23:	1b 54 24 0c          	sbb    0xc(%esp),%edx
  801f27:	89 14 24             	mov    %edx,(%esp)
  801f2a:	89 4c 24 04          	mov    %ecx,0x4(%esp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  801f2e:	8b 44 24 04          	mov    0x4(%esp),%eax
  801f32:	8b 14 24             	mov    (%esp),%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801f35:	83 c4 1c             	add    $0x1c,%esp
  801f38:	5b                   	pop    %ebx
  801f39:	5e                   	pop    %esi
  801f3a:	5f                   	pop    %edi
  801f3b:	5d                   	pop    %ebp
  801f3c:	c3                   	ret    
  801f3d:	8d 76 00             	lea    0x0(%esi),%esi
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801f40:	2b 04 24             	sub    (%esp),%eax
  801f43:	19 fa                	sbb    %edi,%edx
  801f45:	89 d1                	mov    %edx,%ecx
  801f47:	89 c6                	mov    %eax,%esi
  801f49:	e9 71 ff ff ff       	jmp    801ebf <__umoddi3+0xb3>
  801f4e:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801f50:	39 44 24 04          	cmp    %eax,0x4(%esp)
  801f54:	72 ea                	jb     801f40 <__umoddi3+0x134>
  801f56:	89 d9                	mov    %ebx,%ecx
  801f58:	e9 62 ff ff ff       	jmp    801ebf <__umoddi3+0xb3>
