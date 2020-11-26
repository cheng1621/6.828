
obj/user/faultallocbad.debug:     file format elf32-i386


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
  800045:	e8 ac 01 00 00       	call   8001f6 <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  80004a:	83 c4 0c             	add    $0xc,%esp
  80004d:	6a 07                	push   $0x7
  80004f:	89 d8                	mov    %ebx,%eax
  800051:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800056:	50                   	push   %eax
  800057:	6a 00                	push   $0x0
  800059:	e8 ed 0b 00 00       	call   800c4b <sys_page_alloc>
  80005e:	83 c4 10             	add    $0x10,%esp
  800061:	85 c0                	test   %eax,%eax
  800063:	79 16                	jns    80007b <handler+0x48>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
  800065:	83 ec 0c             	sub    $0xc,%esp
  800068:	50                   	push   %eax
  800069:	53                   	push   %ebx
  80006a:	68 80 1f 80 00       	push   $0x801f80
  80006f:	6a 0f                	push   $0xf
  800071:	68 6a 1f 80 00       	push   $0x801f6a
  800076:	e8 a3 00 00 00       	call   80011e <_panic>
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  80007b:	53                   	push   %ebx
  80007c:	68 ac 1f 80 00       	push   $0x801fac
  800081:	6a 64                	push   $0x64
  800083:	53                   	push   %ebx
  800084:	e8 e1 06 00 00       	call   80076a <snprintf>
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
  80009c:	e8 9b 0d 00 00       	call   800e3c <set_pgfault_handler>
	sys_cputs((char*)0xDEADBEEF, 4);
  8000a1:	83 c4 08             	add    $0x8,%esp
  8000a4:	6a 04                	push   $0x4
  8000a6:	68 ef be ad de       	push   $0xdeadbeef
  8000ab:	e8 df 0a 00 00       	call   800b8f <sys_cputs>
}
  8000b0:	83 c4 10             	add    $0x10,%esp
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
  8000c0:	e8 48 0b 00 00       	call   800c0d <sys_getenvid>
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
  8000f0:	e8 9c ff ff ff       	call   800091 <umain>

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
  80010a:	e8 da 0f 00 00       	call   8010e9 <close_all>
	sys_env_destroy(0);
  80010f:	83 ec 0c             	sub    $0xc,%esp
  800112:	6a 00                	push   $0x0
  800114:	e8 b3 0a 00 00       	call   800bcc <sys_env_destroy>
}
  800119:	83 c4 10             	add    $0x10,%esp
  80011c:	c9                   	leave  
  80011d:	c3                   	ret    

0080011e <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80011e:	55                   	push   %ebp
  80011f:	89 e5                	mov    %esp,%ebp
  800121:	56                   	push   %esi
  800122:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800123:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800126:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80012c:	e8 dc 0a 00 00       	call   800c0d <sys_getenvid>
  800131:	83 ec 0c             	sub    $0xc,%esp
  800134:	ff 75 0c             	pushl  0xc(%ebp)
  800137:	ff 75 08             	pushl  0x8(%ebp)
  80013a:	56                   	push   %esi
  80013b:	50                   	push   %eax
  80013c:	68 d8 1f 80 00       	push   $0x801fd8
  800141:	e8 b0 00 00 00       	call   8001f6 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800146:	83 c4 18             	add    $0x18,%esp
  800149:	53                   	push   %ebx
  80014a:	ff 75 10             	pushl  0x10(%ebp)
  80014d:	e8 53 00 00 00       	call   8001a5 <vcprintf>
	cprintf("\n");
  800152:	c7 04 24 18 24 80 00 	movl   $0x802418,(%esp)
  800159:	e8 98 00 00 00       	call   8001f6 <cprintf>
  80015e:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800161:	cc                   	int3   
  800162:	eb fd                	jmp    800161 <_panic+0x43>

00800164 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800164:	55                   	push   %ebp
  800165:	89 e5                	mov    %esp,%ebp
  800167:	53                   	push   %ebx
  800168:	83 ec 04             	sub    $0x4,%esp
  80016b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80016e:	8b 13                	mov    (%ebx),%edx
  800170:	8d 42 01             	lea    0x1(%edx),%eax
  800173:	89 03                	mov    %eax,(%ebx)
  800175:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800178:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80017c:	3d ff 00 00 00       	cmp    $0xff,%eax
  800181:	75 1a                	jne    80019d <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800183:	83 ec 08             	sub    $0x8,%esp
  800186:	68 ff 00 00 00       	push   $0xff
  80018b:	8d 43 08             	lea    0x8(%ebx),%eax
  80018e:	50                   	push   %eax
  80018f:	e8 fb 09 00 00       	call   800b8f <sys_cputs>
		b->idx = 0;
  800194:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80019a:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80019d:	ff 43 04             	incl   0x4(%ebx)
}
  8001a0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001a3:	c9                   	leave  
  8001a4:	c3                   	ret    

008001a5 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001a5:	55                   	push   %ebp
  8001a6:	89 e5                	mov    %esp,%ebp
  8001a8:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001ae:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001b5:	00 00 00 
	b.cnt = 0;
  8001b8:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001bf:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001c2:	ff 75 0c             	pushl  0xc(%ebp)
  8001c5:	ff 75 08             	pushl  0x8(%ebp)
  8001c8:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001ce:	50                   	push   %eax
  8001cf:	68 64 01 80 00       	push   $0x800164
  8001d4:	e8 54 01 00 00       	call   80032d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001d9:	83 c4 08             	add    $0x8,%esp
  8001dc:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001e2:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001e8:	50                   	push   %eax
  8001e9:	e8 a1 09 00 00       	call   800b8f <sys_cputs>

	return b.cnt;
}
  8001ee:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001f4:	c9                   	leave  
  8001f5:	c3                   	ret    

008001f6 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001f6:	55                   	push   %ebp
  8001f7:	89 e5                	mov    %esp,%ebp
  8001f9:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001fc:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001ff:	50                   	push   %eax
  800200:	ff 75 08             	pushl  0x8(%ebp)
  800203:	e8 9d ff ff ff       	call   8001a5 <vcprintf>
	va_end(ap);

	return cnt;
}
  800208:	c9                   	leave  
  800209:	c3                   	ret    

0080020a <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80020a:	55                   	push   %ebp
  80020b:	89 e5                	mov    %esp,%ebp
  80020d:	57                   	push   %edi
  80020e:	56                   	push   %esi
  80020f:	53                   	push   %ebx
  800210:	83 ec 1c             	sub    $0x1c,%esp
  800213:	89 c6                	mov    %eax,%esi
  800215:	89 d7                	mov    %edx,%edi
  800217:	8b 45 08             	mov    0x8(%ebp),%eax
  80021a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80021d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800220:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800223:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800226:	bb 00 00 00 00       	mov    $0x0,%ebx
  80022b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80022e:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800231:	39 d3                	cmp    %edx,%ebx
  800233:	72 11                	jb     800246 <printnum+0x3c>
  800235:	39 45 10             	cmp    %eax,0x10(%ebp)
  800238:	76 0c                	jbe    800246 <printnum+0x3c>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80023a:	8b 45 14             	mov    0x14(%ebp),%eax
  80023d:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800240:	85 db                	test   %ebx,%ebx
  800242:	7f 37                	jg     80027b <printnum+0x71>
  800244:	eb 44                	jmp    80028a <printnum+0x80>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800246:	83 ec 0c             	sub    $0xc,%esp
  800249:	ff 75 18             	pushl  0x18(%ebp)
  80024c:	8b 45 14             	mov    0x14(%ebp),%eax
  80024f:	48                   	dec    %eax
  800250:	50                   	push   %eax
  800251:	ff 75 10             	pushl  0x10(%ebp)
  800254:	83 ec 08             	sub    $0x8,%esp
  800257:	ff 75 e4             	pushl  -0x1c(%ebp)
  80025a:	ff 75 e0             	pushl  -0x20(%ebp)
  80025d:	ff 75 dc             	pushl  -0x24(%ebp)
  800260:	ff 75 d8             	pushl  -0x28(%ebp)
  800263:	e8 7c 1a 00 00       	call   801ce4 <__udivdi3>
  800268:	83 c4 18             	add    $0x18,%esp
  80026b:	52                   	push   %edx
  80026c:	50                   	push   %eax
  80026d:	89 fa                	mov    %edi,%edx
  80026f:	89 f0                	mov    %esi,%eax
  800271:	e8 94 ff ff ff       	call   80020a <printnum>
  800276:	83 c4 20             	add    $0x20,%esp
  800279:	eb 0f                	jmp    80028a <printnum+0x80>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80027b:	83 ec 08             	sub    $0x8,%esp
  80027e:	57                   	push   %edi
  80027f:	ff 75 18             	pushl  0x18(%ebp)
  800282:	ff d6                	call   *%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800284:	83 c4 10             	add    $0x10,%esp
  800287:	4b                   	dec    %ebx
  800288:	75 f1                	jne    80027b <printnum+0x71>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80028a:	83 ec 08             	sub    $0x8,%esp
  80028d:	57                   	push   %edi
  80028e:	83 ec 04             	sub    $0x4,%esp
  800291:	ff 75 e4             	pushl  -0x1c(%ebp)
  800294:	ff 75 e0             	pushl  -0x20(%ebp)
  800297:	ff 75 dc             	pushl  -0x24(%ebp)
  80029a:	ff 75 d8             	pushl  -0x28(%ebp)
  80029d:	e8 52 1b 00 00       	call   801df4 <__umoddi3>
  8002a2:	83 c4 14             	add    $0x14,%esp
  8002a5:	0f be 80 fb 1f 80 00 	movsbl 0x801ffb(%eax),%eax
  8002ac:	50                   	push   %eax
  8002ad:	ff d6                	call   *%esi
}
  8002af:	83 c4 10             	add    $0x10,%esp
  8002b2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002b5:	5b                   	pop    %ebx
  8002b6:	5e                   	pop    %esi
  8002b7:	5f                   	pop    %edi
  8002b8:	5d                   	pop    %ebp
  8002b9:	c3                   	ret    

008002ba <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002ba:	55                   	push   %ebp
  8002bb:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002bd:	83 fa 01             	cmp    $0x1,%edx
  8002c0:	7e 0e                	jle    8002d0 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002c2:	8b 10                	mov    (%eax),%edx
  8002c4:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002c7:	89 08                	mov    %ecx,(%eax)
  8002c9:	8b 02                	mov    (%edx),%eax
  8002cb:	8b 52 04             	mov    0x4(%edx),%edx
  8002ce:	eb 22                	jmp    8002f2 <getuint+0x38>
	else if (lflag)
  8002d0:	85 d2                	test   %edx,%edx
  8002d2:	74 10                	je     8002e4 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002d4:	8b 10                	mov    (%eax),%edx
  8002d6:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002d9:	89 08                	mov    %ecx,(%eax)
  8002db:	8b 02                	mov    (%edx),%eax
  8002dd:	ba 00 00 00 00       	mov    $0x0,%edx
  8002e2:	eb 0e                	jmp    8002f2 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002e4:	8b 10                	mov    (%eax),%edx
  8002e6:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002e9:	89 08                	mov    %ecx,(%eax)
  8002eb:	8b 02                	mov    (%edx),%eax
  8002ed:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002f2:	5d                   	pop    %ebp
  8002f3:	c3                   	ret    

008002f4 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002f4:	55                   	push   %ebp
  8002f5:	89 e5                	mov    %esp,%ebp
  8002f7:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002fa:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8002fd:	8b 10                	mov    (%eax),%edx
  8002ff:	3b 50 04             	cmp    0x4(%eax),%edx
  800302:	73 0a                	jae    80030e <sprintputch+0x1a>
		*b->buf++ = ch;
  800304:	8d 4a 01             	lea    0x1(%edx),%ecx
  800307:	89 08                	mov    %ecx,(%eax)
  800309:	8b 45 08             	mov    0x8(%ebp),%eax
  80030c:	88 02                	mov    %al,(%edx)
}
  80030e:	5d                   	pop    %ebp
  80030f:	c3                   	ret    

00800310 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800310:	55                   	push   %ebp
  800311:	89 e5                	mov    %esp,%ebp
  800313:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800316:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800319:	50                   	push   %eax
  80031a:	ff 75 10             	pushl  0x10(%ebp)
  80031d:	ff 75 0c             	pushl  0xc(%ebp)
  800320:	ff 75 08             	pushl  0x8(%ebp)
  800323:	e8 05 00 00 00       	call   80032d <vprintfmt>
	va_end(ap);
}
  800328:	83 c4 10             	add    $0x10,%esp
  80032b:	c9                   	leave  
  80032c:	c3                   	ret    

0080032d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80032d:	55                   	push   %ebp
  80032e:	89 e5                	mov    %esp,%ebp
  800330:	57                   	push   %edi
  800331:	56                   	push   %esi
  800332:	53                   	push   %ebx
  800333:	83 ec 2c             	sub    $0x2c,%esp
  800336:	8b 7d 08             	mov    0x8(%ebp),%edi
  800339:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80033c:	eb 03                	jmp    800341 <vprintfmt+0x14>
			break;

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
			for (fmt--; fmt[-1] != '%'; fmt--)
  80033e:	89 75 10             	mov    %esi,0x10(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {    //遍历输入的第一个参数，即输出信息的格式，先把格式字符串中'%'之前的字符一个个输出，因为它们前面没有'%'，所以它们就是要直接显示在屏幕上的
  800341:	8b 45 10             	mov    0x10(%ebp),%eax
  800344:	8d 70 01             	lea    0x1(%eax),%esi
  800347:	0f b6 00             	movzbl (%eax),%eax
  80034a:	83 f8 25             	cmp    $0x25,%eax
  80034d:	74 25                	je     800374 <vprintfmt+0x47>
			if (ch == '\0')									//当然中间如果遇到'\0'，代表这个字符串的访问结束
  80034f:	85 c0                	test   %eax,%eax
  800351:	75 0d                	jne    800360 <vprintfmt+0x33>
  800353:	e9 b5 03 00 00       	jmp    80070d <vprintfmt+0x3e0>
  800358:	85 c0                	test   %eax,%eax
  80035a:	0f 84 ad 03 00 00    	je     80070d <vprintfmt+0x3e0>
				return;
			putch(ch, putdat);								//调用putch函数，把一个字符ch输出到putdat指针所指向的地址中所存放的值对应的地址处
  800360:	83 ec 08             	sub    $0x8,%esp
  800363:	53                   	push   %ebx
  800364:	50                   	push   %eax
  800365:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {    //遍历输入的第一个参数，即输出信息的格式，先把格式字符串中'%'之前的字符一个个输出，因为它们前面没有'%'，所以它们就是要直接显示在屏幕上的
  800367:	46                   	inc    %esi
  800368:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  80036c:	83 c4 10             	add    $0x10,%esp
  80036f:	83 f8 25             	cmp    $0x25,%eax
  800372:	75 e4                	jne    800358 <vprintfmt+0x2b>
			if (width < 0)									//代表有小数点，但是小数点前面并没有数字，比如'%.6f'这种情况，此时代表整数部分全部显示
				width = 0;			
			goto reswitch;

		case '#':
			altflag = 1;
  800374:	c6 45 e3 20          	movb   $0x20,-0x1d(%ebp)
  800378:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80037f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800386:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80038d:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800394:	eb 07                	jmp    80039d <vprintfmt+0x70>
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  800396:	8b 75 10             	mov    0x10(%ebp),%esi

		// flag to pad on the right
		case '-':											//%后面的'-'代表要进行左对齐输出，右边填空格，如果省略代表右对齐
			padc = '-';										//如果有这个字符代表左对齐，则把对齐方式标志位变为'-'
  800399:	c6 45 e3 2d          	movb   $0x2d,-0x1d(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  80039d:	8d 46 01             	lea    0x1(%esi),%eax
  8003a0:	89 45 10             	mov    %eax,0x10(%ebp)
  8003a3:	0f b6 16             	movzbl (%esi),%edx
  8003a6:	8a 06                	mov    (%esi),%al
  8003a8:	83 e8 23             	sub    $0x23,%eax
  8003ab:	3c 55                	cmp    $0x55,%al
  8003ad:	0f 87 03 03 00 00    	ja     8006b6 <vprintfmt+0x389>
  8003b3:	0f b6 c0             	movzbl %al,%eax
  8003b6:	ff 24 85 40 21 80 00 	jmp    *0x802140(,%eax,4)
  8003bd:	8b 75 10             	mov    0x10(%ebp),%esi
			padc = '-';										//如果有这个字符代表左对齐，则把对齐方式标志位变为'-'
			goto reswitch;									//处理下一个字符

		// flag to pad with 0's instead of spaces
		case '0':											//0--有0表示进行对齐输出时填0,如省略表示填入空格，并且如果为0，则一定是右对齐
			padc = '0';										//对其方式标志位变为0
  8003c0:	c6 45 e3 30          	movb   $0x30,-0x1d(%ebp)
  8003c4:	eb d7                	jmp    80039d <vprintfmt+0x70>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {					//把遇到的位数字符串转换为真实的位数，比如输入的'%40'，代表有效位数为40位，下面的循环就是把precesion的值设置为40
				precision = precision * 10 + ch - '0';
  8003c6:	8d 42 d0             	lea    -0x30(%edx),%eax
  8003c9:	89 c1                	mov    %eax,%ecx
  8003cb:	89 45 d0             	mov    %eax,-0x30(%ebp)
				ch = *fmt;
  8003ce:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  8003d2:	8d 50 d0             	lea    -0x30(%eax),%edx
  8003d5:	83 fa 09             	cmp    $0x9,%edx
  8003d8:	77 51                	ja     80042b <vprintfmt+0xfe>
  8003da:	8b 75 10             	mov    0x10(%ebp),%esi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {					//把遇到的位数字符串转换为真实的位数，比如输入的'%40'，代表有效位数为40位，下面的循环就是把precesion的值设置为40
  8003dd:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  8003de:	8d 14 89             	lea    (%ecx,%ecx,4),%edx
  8003e1:	01 d2                	add    %edx,%edx
  8003e3:	8d 4c 10 d0          	lea    -0x30(%eax,%edx,1),%ecx
				ch = *fmt;
  8003e7:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8003ea:	8d 50 d0             	lea    -0x30(%eax),%edx
  8003ed:	83 fa 09             	cmp    $0x9,%edx
  8003f0:	76 eb                	jbe    8003dd <vprintfmt+0xb0>
  8003f2:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8003f5:	eb 37                	jmp    80042e <vprintfmt+0x101>
					break;
			}
			goto process_precision;							//跳转到process_precistion子过程

		case '*':											//*--代表有效数字的位数也是由输入参数指定的，比如printf("%*.*f", 10, 2, n)，其中10,2就是用来指定显示的有效数字位数的
			precision = va_arg(ap, int);
  8003f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8003fa:	8d 50 04             	lea    0x4(%eax),%edx
  8003fd:	89 55 14             	mov    %edx,0x14(%ebp)
  800400:	8b 00                	mov    (%eax),%eax
  800402:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  800405:	8b 75 10             	mov    0x10(%ebp),%esi
			}
			goto process_precision;							//跳转到process_precistion子过程

		case '*':											//*--代表有效数字的位数也是由输入参数指定的，比如printf("%*.*f", 10, 2, n)，其中10,2就是用来指定显示的有效数字位数的
			precision = va_arg(ap, int);
			goto process_precision;
  800408:	eb 24                	jmp    80042e <vprintfmt+0x101>
  80040a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80040e:	79 07                	jns    800417 <vprintfmt+0xea>
  800410:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  800417:	8b 75 10             	mov    0x10(%ebp),%esi
  80041a:	eb 81                	jmp    80039d <vprintfmt+0x70>
  80041c:	8b 75 10             	mov    0x10(%ebp),%esi
			if (width < 0)									//代表有小数点，但是小数点前面并没有数字，比如'%.6f'这种情况，此时代表整数部分全部显示
				width = 0;			
			goto reswitch;

		case '#':
			altflag = 1;
  80041f:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800426:	e9 72 ff ff ff       	jmp    80039d <vprintfmt+0x70>
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  80042b:	8b 75 10             	mov    0x10(%ebp),%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:									//处理输出精度，把width字段赋值为刚刚计算出来的precision值，所以width应该是整数部分的有效数字位数
			if (width < 0)
  80042e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800432:	0f 89 65 ff ff ff    	jns    80039d <vprintfmt+0x70>
				width = precision, precision = -1;
  800438:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80043b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80043e:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800445:	e9 53 ff ff ff       	jmp    80039d <vprintfmt+0x70>
			goto reswitch;

		// long flag (doubled for long long)				
		case 'l':											//如果遇到'l'，代表应该是输入long类型，如果有两个'l'代表long long
			lflag++;										//此时把lflag++
  80044a:	ff 45 d4             	incl   -0x2c(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  80044d:	8b 75 10             	mov    0x10(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)				
		case 'l':											//如果遇到'l'，代表应该是输入long类型，如果有两个'l'代表long long
			lflag++;										//此时把lflag++
			goto reswitch;
  800450:	e9 48 ff ff ff       	jmp    80039d <vprintfmt+0x70>

		// character
		case 'c':											//如果是'c'代表显示一个字符
			putch(va_arg(ap, int), putdat);					//调用输出一个字符到内存的函数putch
  800455:	8b 45 14             	mov    0x14(%ebp),%eax
  800458:	8d 50 04             	lea    0x4(%eax),%edx
  80045b:	89 55 14             	mov    %edx,0x14(%ebp)
  80045e:	83 ec 08             	sub    $0x8,%esp
  800461:	53                   	push   %ebx
  800462:	ff 30                	pushl  (%eax)
  800464:	ff d7                	call   *%edi
			break;
  800466:	83 c4 10             	add    $0x10,%esp
  800469:	e9 d3 fe ff ff       	jmp    800341 <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80046e:	8b 45 14             	mov    0x14(%ebp),%eax
  800471:	8d 50 04             	lea    0x4(%eax),%edx
  800474:	89 55 14             	mov    %edx,0x14(%ebp)
  800477:	8b 00                	mov    (%eax),%eax
  800479:	85 c0                	test   %eax,%eax
  80047b:	79 02                	jns    80047f <vprintfmt+0x152>
  80047d:	f7 d8                	neg    %eax
  80047f:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800481:	83 f8 0f             	cmp    $0xf,%eax
  800484:	7f 0b                	jg     800491 <vprintfmt+0x164>
  800486:	8b 04 85 a0 22 80 00 	mov    0x8022a0(,%eax,4),%eax
  80048d:	85 c0                	test   %eax,%eax
  80048f:	75 15                	jne    8004a6 <vprintfmt+0x179>
				printfmt(putch, putdat, "error %d", err);
  800491:	52                   	push   %edx
  800492:	68 13 20 80 00       	push   $0x802013
  800497:	53                   	push   %ebx
  800498:	57                   	push   %edi
  800499:	e8 72 fe ff ff       	call   800310 <printfmt>
  80049e:	83 c4 10             	add    $0x10,%esp
  8004a1:	e9 9b fe ff ff       	jmp    800341 <vprintfmt+0x14>
			else
				printfmt(putch, putdat, "%s", p);
  8004a6:	50                   	push   %eax
  8004a7:	68 e6 23 80 00       	push   $0x8023e6
  8004ac:	53                   	push   %ebx
  8004ad:	57                   	push   %edi
  8004ae:	e8 5d fe ff ff       	call   800310 <printfmt>
  8004b3:	83 c4 10             	add    $0x10,%esp
  8004b6:	e9 86 fe ff ff       	jmp    800341 <vprintfmt+0x14>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8004be:	8d 50 04             	lea    0x4(%eax),%edx
  8004c1:	89 55 14             	mov    %edx,0x14(%ebp)
  8004c4:	8b 00                	mov    (%eax),%eax
  8004c6:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8004c9:	85 c0                	test   %eax,%eax
  8004cb:	75 07                	jne    8004d4 <vprintfmt+0x1a7>
				p = "(null)";
  8004cd:	c7 45 d4 0c 20 80 00 	movl   $0x80200c,-0x2c(%ebp)
			if (width > 0 && padc != '-')
  8004d4:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8004d7:	85 f6                	test   %esi,%esi
  8004d9:	0f 8e fb 01 00 00    	jle    8006da <vprintfmt+0x3ad>
  8004df:	80 7d e3 2d          	cmpb   $0x2d,-0x1d(%ebp)
  8004e3:	0f 84 09 02 00 00    	je     8006f2 <vprintfmt+0x3c5>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004e9:	83 ec 08             	sub    $0x8,%esp
  8004ec:	ff 75 d0             	pushl  -0x30(%ebp)
  8004ef:	ff 75 d4             	pushl  -0x2c(%ebp)
  8004f2:	e8 ad 02 00 00       	call   8007a4 <strnlen>
  8004f7:	89 f1                	mov    %esi,%ecx
  8004f9:	29 c1                	sub    %eax,%ecx
  8004fb:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  8004fe:	83 c4 10             	add    $0x10,%esp
  800501:	85 c9                	test   %ecx,%ecx
  800503:	0f 8e d1 01 00 00    	jle    8006da <vprintfmt+0x3ad>
					putch(padc, putdat);
  800509:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  80050d:	83 ec 08             	sub    $0x8,%esp
  800510:	53                   	push   %ebx
  800511:	56                   	push   %esi
  800512:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800514:	83 c4 10             	add    $0x10,%esp
  800517:	ff 4d e4             	decl   -0x1c(%ebp)
  80051a:	75 f1                	jne    80050d <vprintfmt+0x1e0>
  80051c:	e9 b9 01 00 00       	jmp    8006da <vprintfmt+0x3ad>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800521:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800525:	74 19                	je     800540 <vprintfmt+0x213>
  800527:	0f be c0             	movsbl %al,%eax
  80052a:	83 e8 20             	sub    $0x20,%eax
  80052d:	83 f8 5e             	cmp    $0x5e,%eax
  800530:	76 0e                	jbe    800540 <vprintfmt+0x213>
					putch('?', putdat);
  800532:	83 ec 08             	sub    $0x8,%esp
  800535:	53                   	push   %ebx
  800536:	6a 3f                	push   $0x3f
  800538:	ff 55 08             	call   *0x8(%ebp)
  80053b:	83 c4 10             	add    $0x10,%esp
  80053e:	eb 0b                	jmp    80054b <vprintfmt+0x21e>
				else
					putch(ch, putdat);
  800540:	83 ec 08             	sub    $0x8,%esp
  800543:	53                   	push   %ebx
  800544:	52                   	push   %edx
  800545:	ff 55 08             	call   *0x8(%ebp)
  800548:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80054b:	ff 4d e4             	decl   -0x1c(%ebp)
  80054e:	46                   	inc    %esi
  80054f:	8a 46 ff             	mov    -0x1(%esi),%al
  800552:	0f be d0             	movsbl %al,%edx
  800555:	85 d2                	test   %edx,%edx
  800557:	75 1c                	jne    800575 <vprintfmt+0x248>
  800559:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80055c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800560:	7f 1f                	jg     800581 <vprintfmt+0x254>
  800562:	e9 da fd ff ff       	jmp    800341 <vprintfmt+0x14>
  800567:	89 7d 08             	mov    %edi,0x8(%ebp)
  80056a:	8b 7d d0             	mov    -0x30(%ebp),%edi
  80056d:	eb 06                	jmp    800575 <vprintfmt+0x248>
  80056f:	89 7d 08             	mov    %edi,0x8(%ebp)
  800572:	8b 7d d0             	mov    -0x30(%ebp),%edi
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800575:	85 ff                	test   %edi,%edi
  800577:	78 a8                	js     800521 <vprintfmt+0x1f4>
  800579:	4f                   	dec    %edi
  80057a:	79 a5                	jns    800521 <vprintfmt+0x1f4>
  80057c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80057f:	eb db                	jmp    80055c <vprintfmt+0x22f>
  800581:	8b 75 e4             	mov    -0x1c(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800584:	83 ec 08             	sub    $0x8,%esp
  800587:	53                   	push   %ebx
  800588:	6a 20                	push   $0x20
  80058a:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80058c:	4e                   	dec    %esi
  80058d:	83 c4 10             	add    $0x10,%esp
  800590:	85 f6                	test   %esi,%esi
  800592:	7f f0                	jg     800584 <vprintfmt+0x257>
  800594:	e9 a8 fd ff ff       	jmp    800341 <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800599:	83 7d d4 01          	cmpl   $0x1,-0x2c(%ebp)
  80059d:	7e 16                	jle    8005b5 <vprintfmt+0x288>
		return va_arg(*ap, long long);
  80059f:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a2:	8d 50 08             	lea    0x8(%eax),%edx
  8005a5:	89 55 14             	mov    %edx,0x14(%ebp)
  8005a8:	8b 50 04             	mov    0x4(%eax),%edx
  8005ab:	8b 00                	mov    (%eax),%eax
  8005ad:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005b0:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005b3:	eb 34                	jmp    8005e9 <vprintfmt+0x2bc>
	else if (lflag)
  8005b5:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8005b9:	74 18                	je     8005d3 <vprintfmt+0x2a6>
		return va_arg(*ap, long);
  8005bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8005be:	8d 50 04             	lea    0x4(%eax),%edx
  8005c1:	89 55 14             	mov    %edx,0x14(%ebp)
  8005c4:	8b 30                	mov    (%eax),%esi
  8005c6:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8005c9:	89 f0                	mov    %esi,%eax
  8005cb:	c1 f8 1f             	sar    $0x1f,%eax
  8005ce:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8005d1:	eb 16                	jmp    8005e9 <vprintfmt+0x2bc>
	else
		return va_arg(*ap, int);
  8005d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d6:	8d 50 04             	lea    0x4(%eax),%edx
  8005d9:	89 55 14             	mov    %edx,0x14(%ebp)
  8005dc:	8b 30                	mov    (%eax),%esi
  8005de:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8005e1:	89 f0                	mov    %esi,%eax
  8005e3:	c1 f8 1f             	sar    $0x1f,%eax
  8005e6:	89 45 dc             	mov    %eax,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005e9:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005ec:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
  8005ef:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005f3:	0f 89 8a 00 00 00    	jns    800683 <vprintfmt+0x356>
				putch('-', putdat);
  8005f9:	83 ec 08             	sub    $0x8,%esp
  8005fc:	53                   	push   %ebx
  8005fd:	6a 2d                	push   $0x2d
  8005ff:	ff d7                	call   *%edi
				num = -(long long) num;
  800601:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800604:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800607:	f7 d8                	neg    %eax
  800609:	83 d2 00             	adc    $0x0,%edx
  80060c:	f7 da                	neg    %edx
  80060e:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800611:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800616:	eb 70                	jmp    800688 <vprintfmt+0x35b>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800618:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80061b:	8d 45 14             	lea    0x14(%ebp),%eax
  80061e:	e8 97 fc ff ff       	call   8002ba <getuint>
			base = 10;
  800623:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800628:	eb 5e                	jmp    800688 <vprintfmt+0x35b>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
  80062a:	83 ec 08             	sub    $0x8,%esp
  80062d:	53                   	push   %ebx
  80062e:	6a 30                	push   $0x30
  800630:	ff d7                	call   *%edi
			num = getuint(&ap, lflag);
  800632:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800635:	8d 45 14             	lea    0x14(%ebp),%eax
  800638:	e8 7d fc ff ff       	call   8002ba <getuint>
			base = 8;
			goto number;
  80063d:	83 c4 10             	add    $0x10,%esp
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  800640:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800645:	eb 41                	jmp    800688 <vprintfmt+0x35b>
		// pointer
		case 'p':
			putch('0', putdat);
  800647:	83 ec 08             	sub    $0x8,%esp
  80064a:	53                   	push   %ebx
  80064b:	6a 30                	push   $0x30
  80064d:	ff d7                	call   *%edi
			putch('x', putdat);
  80064f:	83 c4 08             	add    $0x8,%esp
  800652:	53                   	push   %ebx
  800653:	6a 78                	push   $0x78
  800655:	ff d7                	call   *%edi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800657:	8b 45 14             	mov    0x14(%ebp),%eax
  80065a:	8d 50 04             	lea    0x4(%eax),%edx
  80065d:	89 55 14             	mov    %edx,0x14(%ebp)
			goto number;
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800660:	8b 00                	mov    (%eax),%eax
  800662:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800667:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80066a:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80066f:	eb 17                	jmp    800688 <vprintfmt+0x35b>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800671:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800674:	8d 45 14             	lea    0x14(%ebp),%eax
  800677:	e8 3e fc ff ff       	call   8002ba <getuint>
			base = 16;
  80067c:	b9 10 00 00 00       	mov    $0x10,%ecx
  800681:	eb 05                	jmp    800688 <vprintfmt+0x35b>
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800683:	b9 0a 00 00 00       	mov    $0xa,%ecx
		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  800688:	83 ec 0c             	sub    $0xc,%esp
  80068b:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  80068f:	56                   	push   %esi
  800690:	ff 75 e4             	pushl  -0x1c(%ebp)
  800693:	51                   	push   %ecx
  800694:	52                   	push   %edx
  800695:	50                   	push   %eax
  800696:	89 da                	mov    %ebx,%edx
  800698:	89 f8                	mov    %edi,%eax
  80069a:	e8 6b fb ff ff       	call   80020a <printnum>
			break;
  80069f:	83 c4 20             	add    $0x20,%esp
  8006a2:	e9 9a fc ff ff       	jmp    800341 <vprintfmt+0x14>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006a7:	83 ec 08             	sub    $0x8,%esp
  8006aa:	53                   	push   %ebx
  8006ab:	52                   	push   %edx
  8006ac:	ff d7                	call   *%edi
			break;
  8006ae:	83 c4 10             	add    $0x10,%esp
  8006b1:	e9 8b fc ff ff       	jmp    800341 <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006b6:	83 ec 08             	sub    $0x8,%esp
  8006b9:	53                   	push   %ebx
  8006ba:	6a 25                	push   $0x25
  8006bc:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006be:	83 c4 10             	add    $0x10,%esp
  8006c1:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8006c5:	0f 84 73 fc ff ff    	je     80033e <vprintfmt+0x11>
  8006cb:	4e                   	dec    %esi
  8006cc:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8006d0:	75 f9                	jne    8006cb <vprintfmt+0x39e>
  8006d2:	89 75 10             	mov    %esi,0x10(%ebp)
  8006d5:	e9 67 fc ff ff       	jmp    800341 <vprintfmt+0x14>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006da:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8006dd:	8d 70 01             	lea    0x1(%eax),%esi
  8006e0:	8a 00                	mov    (%eax),%al
  8006e2:	0f be d0             	movsbl %al,%edx
  8006e5:	85 d2                	test   %edx,%edx
  8006e7:	0f 85 7a fe ff ff    	jne    800567 <vprintfmt+0x23a>
  8006ed:	e9 4f fc ff ff       	jmp    800341 <vprintfmt+0x14>
  8006f2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8006f5:	8d 70 01             	lea    0x1(%eax),%esi
  8006f8:	8a 00                	mov    (%eax),%al
  8006fa:	0f be d0             	movsbl %al,%edx
  8006fd:	85 d2                	test   %edx,%edx
  8006ff:	0f 85 6a fe ff ff    	jne    80056f <vprintfmt+0x242>
  800705:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800708:	e9 77 fe ff ff       	jmp    800584 <vprintfmt+0x257>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  80070d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800710:	5b                   	pop    %ebx
  800711:	5e                   	pop    %esi
  800712:	5f                   	pop    %edi
  800713:	5d                   	pop    %ebp
  800714:	c3                   	ret    

00800715 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800715:	55                   	push   %ebp
  800716:	89 e5                	mov    %esp,%ebp
  800718:	83 ec 18             	sub    $0x18,%esp
  80071b:	8b 45 08             	mov    0x8(%ebp),%eax
  80071e:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800721:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800724:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800728:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80072b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800732:	85 c0                	test   %eax,%eax
  800734:	74 26                	je     80075c <vsnprintf+0x47>
  800736:	85 d2                	test   %edx,%edx
  800738:	7e 29                	jle    800763 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80073a:	ff 75 14             	pushl  0x14(%ebp)
  80073d:	ff 75 10             	pushl  0x10(%ebp)
  800740:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800743:	50                   	push   %eax
  800744:	68 f4 02 80 00       	push   $0x8002f4
  800749:	e8 df fb ff ff       	call   80032d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80074e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800751:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800754:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800757:	83 c4 10             	add    $0x10,%esp
  80075a:	eb 0c                	jmp    800768 <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80075c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800761:	eb 05                	jmp    800768 <vsnprintf+0x53>
  800763:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800768:	c9                   	leave  
  800769:	c3                   	ret    

0080076a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80076a:	55                   	push   %ebp
  80076b:	89 e5                	mov    %esp,%ebp
  80076d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800770:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800773:	50                   	push   %eax
  800774:	ff 75 10             	pushl  0x10(%ebp)
  800777:	ff 75 0c             	pushl  0xc(%ebp)
  80077a:	ff 75 08             	pushl  0x8(%ebp)
  80077d:	e8 93 ff ff ff       	call   800715 <vsnprintf>
	va_end(ap);

	return rc;
}
  800782:	c9                   	leave  
  800783:	c3                   	ret    

00800784 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800784:	55                   	push   %ebp
  800785:	89 e5                	mov    %esp,%ebp
  800787:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80078a:	80 3a 00             	cmpb   $0x0,(%edx)
  80078d:	74 0e                	je     80079d <strlen+0x19>
  80078f:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800794:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800795:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800799:	75 f9                	jne    800794 <strlen+0x10>
  80079b:	eb 05                	jmp    8007a2 <strlen+0x1e>
  80079d:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8007a2:	5d                   	pop    %ebp
  8007a3:	c3                   	ret    

008007a4 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007a4:	55                   	push   %ebp
  8007a5:	89 e5                	mov    %esp,%ebp
  8007a7:	53                   	push   %ebx
  8007a8:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8007ab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007ae:	85 c9                	test   %ecx,%ecx
  8007b0:	74 1a                	je     8007cc <strnlen+0x28>
  8007b2:	80 3b 00             	cmpb   $0x0,(%ebx)
  8007b5:	74 1c                	je     8007d3 <strnlen+0x2f>
  8007b7:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  8007bc:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007be:	39 ca                	cmp    %ecx,%edx
  8007c0:	74 16                	je     8007d8 <strnlen+0x34>
  8007c2:	42                   	inc    %edx
  8007c3:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  8007c8:	75 f2                	jne    8007bc <strnlen+0x18>
  8007ca:	eb 0c                	jmp    8007d8 <strnlen+0x34>
  8007cc:	b8 00 00 00 00       	mov    $0x0,%eax
  8007d1:	eb 05                	jmp    8007d8 <strnlen+0x34>
  8007d3:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8007d8:	5b                   	pop    %ebx
  8007d9:	5d                   	pop    %ebp
  8007da:	c3                   	ret    

008007db <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007db:	55                   	push   %ebp
  8007dc:	89 e5                	mov    %esp,%ebp
  8007de:	53                   	push   %ebx
  8007df:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007e5:	89 c2                	mov    %eax,%edx
  8007e7:	42                   	inc    %edx
  8007e8:	41                   	inc    %ecx
  8007e9:	8a 59 ff             	mov    -0x1(%ecx),%bl
  8007ec:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007ef:	84 db                	test   %bl,%bl
  8007f1:	75 f4                	jne    8007e7 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007f3:	5b                   	pop    %ebx
  8007f4:	5d                   	pop    %ebp
  8007f5:	c3                   	ret    

008007f6 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007f6:	55                   	push   %ebp
  8007f7:	89 e5                	mov    %esp,%ebp
  8007f9:	53                   	push   %ebx
  8007fa:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007fd:	53                   	push   %ebx
  8007fe:	e8 81 ff ff ff       	call   800784 <strlen>
  800803:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800806:	ff 75 0c             	pushl  0xc(%ebp)
  800809:	01 d8                	add    %ebx,%eax
  80080b:	50                   	push   %eax
  80080c:	e8 ca ff ff ff       	call   8007db <strcpy>
	return dst;
}
  800811:	89 d8                	mov    %ebx,%eax
  800813:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800816:	c9                   	leave  
  800817:	c3                   	ret    

00800818 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800818:	55                   	push   %ebp
  800819:	89 e5                	mov    %esp,%ebp
  80081b:	56                   	push   %esi
  80081c:	53                   	push   %ebx
  80081d:	8b 75 08             	mov    0x8(%ebp),%esi
  800820:	8b 55 0c             	mov    0xc(%ebp),%edx
  800823:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800826:	85 db                	test   %ebx,%ebx
  800828:	74 14                	je     80083e <strncpy+0x26>
  80082a:	01 f3                	add    %esi,%ebx
  80082c:	89 f1                	mov    %esi,%ecx
		*dst++ = *src;
  80082e:	41                   	inc    %ecx
  80082f:	8a 02                	mov    (%edx),%al
  800831:	88 41 ff             	mov    %al,-0x1(%ecx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800834:	80 3a 01             	cmpb   $0x1,(%edx)
  800837:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80083a:	39 cb                	cmp    %ecx,%ebx
  80083c:	75 f0                	jne    80082e <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80083e:	89 f0                	mov    %esi,%eax
  800840:	5b                   	pop    %ebx
  800841:	5e                   	pop    %esi
  800842:	5d                   	pop    %ebp
  800843:	c3                   	ret    

00800844 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800844:	55                   	push   %ebp
  800845:	89 e5                	mov    %esp,%ebp
  800847:	53                   	push   %ebx
  800848:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80084b:	8b 45 10             	mov    0x10(%ebp),%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80084e:	85 c0                	test   %eax,%eax
  800850:	74 30                	je     800882 <strlcpy+0x3e>
		while (--size > 0 && *src != '\0')
  800852:	48                   	dec    %eax
  800853:	74 20                	je     800875 <strlcpy+0x31>
  800855:	8a 0b                	mov    (%ebx),%cl
  800857:	84 c9                	test   %cl,%cl
  800859:	74 1f                	je     80087a <strlcpy+0x36>
  80085b:	8d 53 01             	lea    0x1(%ebx),%edx
  80085e:	01 c3                	add    %eax,%ebx
  800860:	8b 45 08             	mov    0x8(%ebp),%eax
			*dst++ = *src++;
  800863:	40                   	inc    %eax
  800864:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800867:	39 da                	cmp    %ebx,%edx
  800869:	74 12                	je     80087d <strlcpy+0x39>
  80086b:	42                   	inc    %edx
  80086c:	8a 4a ff             	mov    -0x1(%edx),%cl
  80086f:	84 c9                	test   %cl,%cl
  800871:	75 f0                	jne    800863 <strlcpy+0x1f>
  800873:	eb 08                	jmp    80087d <strlcpy+0x39>
  800875:	8b 45 08             	mov    0x8(%ebp),%eax
  800878:	eb 03                	jmp    80087d <strlcpy+0x39>
  80087a:	8b 45 08             	mov    0x8(%ebp),%eax
			*dst++ = *src++;
		*dst = '\0';
  80087d:	c6 00 00             	movb   $0x0,(%eax)
  800880:	eb 03                	jmp    800885 <strlcpy+0x41>
  800882:	8b 45 08             	mov    0x8(%ebp),%eax
	}
	return dst - dst_in;
  800885:	2b 45 08             	sub    0x8(%ebp),%eax
}
  800888:	5b                   	pop    %ebx
  800889:	5d                   	pop    %ebp
  80088a:	c3                   	ret    

0080088b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80088b:	55                   	push   %ebp
  80088c:	89 e5                	mov    %esp,%ebp
  80088e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800891:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800894:	8a 01                	mov    (%ecx),%al
  800896:	84 c0                	test   %al,%al
  800898:	74 10                	je     8008aa <strcmp+0x1f>
  80089a:	3a 02                	cmp    (%edx),%al
  80089c:	75 0c                	jne    8008aa <strcmp+0x1f>
		p++, q++;
  80089e:	41                   	inc    %ecx
  80089f:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008a0:	8a 01                	mov    (%ecx),%al
  8008a2:	84 c0                	test   %al,%al
  8008a4:	74 04                	je     8008aa <strcmp+0x1f>
  8008a6:	3a 02                	cmp    (%edx),%al
  8008a8:	74 f4                	je     80089e <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008aa:	0f b6 c0             	movzbl %al,%eax
  8008ad:	0f b6 12             	movzbl (%edx),%edx
  8008b0:	29 d0                	sub    %edx,%eax
}
  8008b2:	5d                   	pop    %ebp
  8008b3:	c3                   	ret    

008008b4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008b4:	55                   	push   %ebp
  8008b5:	89 e5                	mov    %esp,%ebp
  8008b7:	56                   	push   %esi
  8008b8:	53                   	push   %ebx
  8008b9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8008bc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008bf:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  8008c2:	85 f6                	test   %esi,%esi
  8008c4:	74 23                	je     8008e9 <strncmp+0x35>
  8008c6:	8a 03                	mov    (%ebx),%al
  8008c8:	84 c0                	test   %al,%al
  8008ca:	74 2b                	je     8008f7 <strncmp+0x43>
  8008cc:	3a 02                	cmp    (%edx),%al
  8008ce:	75 27                	jne    8008f7 <strncmp+0x43>
  8008d0:	8d 43 01             	lea    0x1(%ebx),%eax
  8008d3:	01 de                	add    %ebx,%esi
		n--, p++, q++;
  8008d5:	89 c3                	mov    %eax,%ebx
  8008d7:	42                   	inc    %edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008d8:	39 c6                	cmp    %eax,%esi
  8008da:	74 14                	je     8008f0 <strncmp+0x3c>
  8008dc:	8a 08                	mov    (%eax),%cl
  8008de:	84 c9                	test   %cl,%cl
  8008e0:	74 15                	je     8008f7 <strncmp+0x43>
  8008e2:	40                   	inc    %eax
  8008e3:	3a 0a                	cmp    (%edx),%cl
  8008e5:	74 ee                	je     8008d5 <strncmp+0x21>
  8008e7:	eb 0e                	jmp    8008f7 <strncmp+0x43>
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008e9:	b8 00 00 00 00       	mov    $0x0,%eax
  8008ee:	eb 0f                	jmp    8008ff <strncmp+0x4b>
  8008f0:	b8 00 00 00 00       	mov    $0x0,%eax
  8008f5:	eb 08                	jmp    8008ff <strncmp+0x4b>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008f7:	0f b6 03             	movzbl (%ebx),%eax
  8008fa:	0f b6 12             	movzbl (%edx),%edx
  8008fd:	29 d0                	sub    %edx,%eax
}
  8008ff:	5b                   	pop    %ebx
  800900:	5e                   	pop    %esi
  800901:	5d                   	pop    %ebp
  800902:	c3                   	ret    

00800903 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800903:	55                   	push   %ebp
  800904:	89 e5                	mov    %esp,%ebp
  800906:	53                   	push   %ebx
  800907:	8b 45 08             	mov    0x8(%ebp),%eax
  80090a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  80090d:	8a 10                	mov    (%eax),%dl
  80090f:	84 d2                	test   %dl,%dl
  800911:	74 1a                	je     80092d <strchr+0x2a>
  800913:	88 d9                	mov    %bl,%cl
		if (*s == c)
  800915:	38 d3                	cmp    %dl,%bl
  800917:	75 06                	jne    80091f <strchr+0x1c>
  800919:	eb 17                	jmp    800932 <strchr+0x2f>
  80091b:	38 ca                	cmp    %cl,%dl
  80091d:	74 13                	je     800932 <strchr+0x2f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80091f:	40                   	inc    %eax
  800920:	8a 10                	mov    (%eax),%dl
  800922:	84 d2                	test   %dl,%dl
  800924:	75 f5                	jne    80091b <strchr+0x18>
		if (*s == c)
			return (char *) s;
	return 0;
  800926:	b8 00 00 00 00       	mov    $0x0,%eax
  80092b:	eb 05                	jmp    800932 <strchr+0x2f>
  80092d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800932:	5b                   	pop    %ebx
  800933:	5d                   	pop    %ebp
  800934:	c3                   	ret    

00800935 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800935:	55                   	push   %ebp
  800936:	89 e5                	mov    %esp,%ebp
  800938:	53                   	push   %ebx
  800939:	8b 45 08             	mov    0x8(%ebp),%eax
  80093c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  80093f:	8a 10                	mov    (%eax),%dl
  800941:	84 d2                	test   %dl,%dl
  800943:	74 13                	je     800958 <strfind+0x23>
  800945:	88 d9                	mov    %bl,%cl
		if (*s == c)
  800947:	38 d3                	cmp    %dl,%bl
  800949:	75 06                	jne    800951 <strfind+0x1c>
  80094b:	eb 0b                	jmp    800958 <strfind+0x23>
  80094d:	38 ca                	cmp    %cl,%dl
  80094f:	74 07                	je     800958 <strfind+0x23>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800951:	40                   	inc    %eax
  800952:	8a 10                	mov    (%eax),%dl
  800954:	84 d2                	test   %dl,%dl
  800956:	75 f5                	jne    80094d <strfind+0x18>
		if (*s == c)
			break;
	return (char *) s;
}
  800958:	5b                   	pop    %ebx
  800959:	5d                   	pop    %ebp
  80095a:	c3                   	ret    

0080095b <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80095b:	55                   	push   %ebp
  80095c:	89 e5                	mov    %esp,%ebp
  80095e:	57                   	push   %edi
  80095f:	56                   	push   %esi
  800960:	53                   	push   %ebx
  800961:	8b 7d 08             	mov    0x8(%ebp),%edi
  800964:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800967:	85 c9                	test   %ecx,%ecx
  800969:	74 36                	je     8009a1 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80096b:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800971:	75 28                	jne    80099b <memset+0x40>
  800973:	f6 c1 03             	test   $0x3,%cl
  800976:	75 23                	jne    80099b <memset+0x40>
		c &= 0xFF;
  800978:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80097c:	89 d3                	mov    %edx,%ebx
  80097e:	c1 e3 08             	shl    $0x8,%ebx
  800981:	89 d6                	mov    %edx,%esi
  800983:	c1 e6 18             	shl    $0x18,%esi
  800986:	89 d0                	mov    %edx,%eax
  800988:	c1 e0 10             	shl    $0x10,%eax
  80098b:	09 f0                	or     %esi,%eax
  80098d:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80098f:	89 d8                	mov    %ebx,%eax
  800991:	09 d0                	or     %edx,%eax
  800993:	c1 e9 02             	shr    $0x2,%ecx
  800996:	fc                   	cld    
  800997:	f3 ab                	rep stos %eax,%es:(%edi)
  800999:	eb 06                	jmp    8009a1 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80099b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80099e:	fc                   	cld    
  80099f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009a1:	89 f8                	mov    %edi,%eax
  8009a3:	5b                   	pop    %ebx
  8009a4:	5e                   	pop    %esi
  8009a5:	5f                   	pop    %edi
  8009a6:	5d                   	pop    %ebp
  8009a7:	c3                   	ret    

008009a8 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009a8:	55                   	push   %ebp
  8009a9:	89 e5                	mov    %esp,%ebp
  8009ab:	57                   	push   %edi
  8009ac:	56                   	push   %esi
  8009ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b0:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009b3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009b6:	39 c6                	cmp    %eax,%esi
  8009b8:	73 33                	jae    8009ed <memmove+0x45>
  8009ba:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009bd:	39 d0                	cmp    %edx,%eax
  8009bf:	73 2c                	jae    8009ed <memmove+0x45>
		s += n;
		d += n;
  8009c1:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009c4:	89 d6                	mov    %edx,%esi
  8009c6:	09 fe                	or     %edi,%esi
  8009c8:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009ce:	75 13                	jne    8009e3 <memmove+0x3b>
  8009d0:	f6 c1 03             	test   $0x3,%cl
  8009d3:	75 0e                	jne    8009e3 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8009d5:	83 ef 04             	sub    $0x4,%edi
  8009d8:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009db:	c1 e9 02             	shr    $0x2,%ecx
  8009de:	fd                   	std    
  8009df:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009e1:	eb 07                	jmp    8009ea <memmove+0x42>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009e3:	4f                   	dec    %edi
  8009e4:	8d 72 ff             	lea    -0x1(%edx),%esi
  8009e7:	fd                   	std    
  8009e8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009ea:	fc                   	cld    
  8009eb:	eb 1d                	jmp    800a0a <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009ed:	89 f2                	mov    %esi,%edx
  8009ef:	09 c2                	or     %eax,%edx
  8009f1:	f6 c2 03             	test   $0x3,%dl
  8009f4:	75 0f                	jne    800a05 <memmove+0x5d>
  8009f6:	f6 c1 03             	test   $0x3,%cl
  8009f9:	75 0a                	jne    800a05 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
  8009fb:	c1 e9 02             	shr    $0x2,%ecx
  8009fe:	89 c7                	mov    %eax,%edi
  800a00:	fc                   	cld    
  800a01:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a03:	eb 05                	jmp    800a0a <memmove+0x62>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a05:	89 c7                	mov    %eax,%edi
  800a07:	fc                   	cld    
  800a08:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a0a:	5e                   	pop    %esi
  800a0b:	5f                   	pop    %edi
  800a0c:	5d                   	pop    %ebp
  800a0d:	c3                   	ret    

00800a0e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a0e:	55                   	push   %ebp
  800a0f:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a11:	ff 75 10             	pushl  0x10(%ebp)
  800a14:	ff 75 0c             	pushl  0xc(%ebp)
  800a17:	ff 75 08             	pushl  0x8(%ebp)
  800a1a:	e8 89 ff ff ff       	call   8009a8 <memmove>
}
  800a1f:	c9                   	leave  
  800a20:	c3                   	ret    

00800a21 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a21:	55                   	push   %ebp
  800a22:	89 e5                	mov    %esp,%ebp
  800a24:	57                   	push   %edi
  800a25:	56                   	push   %esi
  800a26:	53                   	push   %ebx
  800a27:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800a2a:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a2d:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a30:	85 c0                	test   %eax,%eax
  800a32:	74 33                	je     800a67 <memcmp+0x46>
  800a34:	8d 78 ff             	lea    -0x1(%eax),%edi
		if (*s1 != *s2)
  800a37:	8a 13                	mov    (%ebx),%dl
  800a39:	8a 0e                	mov    (%esi),%cl
  800a3b:	38 ca                	cmp    %cl,%dl
  800a3d:	75 13                	jne    800a52 <memcmp+0x31>
  800a3f:	b8 00 00 00 00       	mov    $0x0,%eax
  800a44:	eb 16                	jmp    800a5c <memcmp+0x3b>
  800a46:	8a 54 03 01          	mov    0x1(%ebx,%eax,1),%dl
  800a4a:	40                   	inc    %eax
  800a4b:	8a 0c 06             	mov    (%esi,%eax,1),%cl
  800a4e:	38 ca                	cmp    %cl,%dl
  800a50:	74 0a                	je     800a5c <memcmp+0x3b>
			return (int) *s1 - (int) *s2;
  800a52:	0f b6 c2             	movzbl %dl,%eax
  800a55:	0f b6 c9             	movzbl %cl,%ecx
  800a58:	29 c8                	sub    %ecx,%eax
  800a5a:	eb 10                	jmp    800a6c <memcmp+0x4b>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a5c:	39 f8                	cmp    %edi,%eax
  800a5e:	75 e6                	jne    800a46 <memcmp+0x25>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a60:	b8 00 00 00 00       	mov    $0x0,%eax
  800a65:	eb 05                	jmp    800a6c <memcmp+0x4b>
  800a67:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a6c:	5b                   	pop    %ebx
  800a6d:	5e                   	pop    %esi
  800a6e:	5f                   	pop    %edi
  800a6f:	5d                   	pop    %ebp
  800a70:	c3                   	ret    

00800a71 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a71:	55                   	push   %ebp
  800a72:	89 e5                	mov    %esp,%ebp
  800a74:	53                   	push   %ebx
  800a75:	8b 55 08             	mov    0x8(%ebp),%edx
	const void *ends = (const char *) s + n;
  800a78:	89 d0                	mov    %edx,%eax
  800a7a:	03 45 10             	add    0x10(%ebp),%eax
	for (; s < ends; s++)
  800a7d:	39 c2                	cmp    %eax,%edx
  800a7f:	73 1b                	jae    800a9c <memfind+0x2b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a81:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
  800a85:	0f b6 0a             	movzbl (%edx),%ecx
  800a88:	39 d9                	cmp    %ebx,%ecx
  800a8a:	75 09                	jne    800a95 <memfind+0x24>
  800a8c:	eb 12                	jmp    800aa0 <memfind+0x2f>
  800a8e:	0f b6 0a             	movzbl (%edx),%ecx
  800a91:	39 d9                	cmp    %ebx,%ecx
  800a93:	74 0f                	je     800aa4 <memfind+0x33>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a95:	42                   	inc    %edx
  800a96:	39 d0                	cmp    %edx,%eax
  800a98:	75 f4                	jne    800a8e <memfind+0x1d>
  800a9a:	eb 0a                	jmp    800aa6 <memfind+0x35>
  800a9c:	89 d0                	mov    %edx,%eax
  800a9e:	eb 06                	jmp    800aa6 <memfind+0x35>
		if (*(const unsigned char *) s == (unsigned char) c)
  800aa0:	89 d0                	mov    %edx,%eax
  800aa2:	eb 02                	jmp    800aa6 <memfind+0x35>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800aa4:	89 d0                	mov    %edx,%eax
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800aa6:	5b                   	pop    %ebx
  800aa7:	5d                   	pop    %ebp
  800aa8:	c3                   	ret    

00800aa9 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800aa9:	55                   	push   %ebp
  800aaa:	89 e5                	mov    %esp,%ebp
  800aac:	57                   	push   %edi
  800aad:	56                   	push   %esi
  800aae:	53                   	push   %ebx
  800aaf:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ab2:	eb 01                	jmp    800ab5 <strtol+0xc>
		s++;
  800ab4:	41                   	inc    %ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ab5:	8a 01                	mov    (%ecx),%al
  800ab7:	3c 20                	cmp    $0x20,%al
  800ab9:	74 f9                	je     800ab4 <strtol+0xb>
  800abb:	3c 09                	cmp    $0x9,%al
  800abd:	74 f5                	je     800ab4 <strtol+0xb>
		s++;

	// plus/minus sign
	if (*s == '+')
  800abf:	3c 2b                	cmp    $0x2b,%al
  800ac1:	75 08                	jne    800acb <strtol+0x22>
		s++;
  800ac3:	41                   	inc    %ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ac4:	bf 00 00 00 00       	mov    $0x0,%edi
  800ac9:	eb 11                	jmp    800adc <strtol+0x33>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800acb:	3c 2d                	cmp    $0x2d,%al
  800acd:	75 08                	jne    800ad7 <strtol+0x2e>
		s++, neg = 1;
  800acf:	41                   	inc    %ecx
  800ad0:	bf 01 00 00 00       	mov    $0x1,%edi
  800ad5:	eb 05                	jmp    800adc <strtol+0x33>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ad7:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800adc:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800ae0:	0f 84 87 00 00 00    	je     800b6d <strtol+0xc4>
  800ae6:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  800aea:	75 27                	jne    800b13 <strtol+0x6a>
  800aec:	80 39 30             	cmpb   $0x30,(%ecx)
  800aef:	75 22                	jne    800b13 <strtol+0x6a>
  800af1:	e9 88 00 00 00       	jmp    800b7e <strtol+0xd5>
		s += 2, base = 16;
  800af6:	83 c1 02             	add    $0x2,%ecx
  800af9:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  800b00:	eb 11                	jmp    800b13 <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
  800b02:	41                   	inc    %ecx
  800b03:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  800b0a:	eb 07                	jmp    800b13 <strtol+0x6a>
	else if (base == 0)
		base = 10;
  800b0c:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)
  800b13:	b8 00 00 00 00       	mov    $0x0,%eax

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b18:	8a 11                	mov    (%ecx),%dl
  800b1a:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800b1d:	80 fb 09             	cmp    $0x9,%bl
  800b20:	77 08                	ja     800b2a <strtol+0x81>
			dig = *s - '0';
  800b22:	0f be d2             	movsbl %dl,%edx
  800b25:	83 ea 30             	sub    $0x30,%edx
  800b28:	eb 22                	jmp    800b4c <strtol+0xa3>
		else if (*s >= 'a' && *s <= 'z')
  800b2a:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b2d:	89 f3                	mov    %esi,%ebx
  800b2f:	80 fb 19             	cmp    $0x19,%bl
  800b32:	77 08                	ja     800b3c <strtol+0x93>
			dig = *s - 'a' + 10;
  800b34:	0f be d2             	movsbl %dl,%edx
  800b37:	83 ea 57             	sub    $0x57,%edx
  800b3a:	eb 10                	jmp    800b4c <strtol+0xa3>
		else if (*s >= 'A' && *s <= 'Z')
  800b3c:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b3f:	89 f3                	mov    %esi,%ebx
  800b41:	80 fb 19             	cmp    $0x19,%bl
  800b44:	77 14                	ja     800b5a <strtol+0xb1>
			dig = *s - 'A' + 10;
  800b46:	0f be d2             	movsbl %dl,%edx
  800b49:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b4c:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b4f:	7d 09                	jge    800b5a <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800b51:	41                   	inc    %ecx
  800b52:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b56:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b58:	eb be                	jmp    800b18 <strtol+0x6f>

	if (endptr)
  800b5a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b5e:	74 05                	je     800b65 <strtol+0xbc>
		*endptr = (char *) s;
  800b60:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b63:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800b65:	85 ff                	test   %edi,%edi
  800b67:	74 21                	je     800b8a <strtol+0xe1>
  800b69:	f7 d8                	neg    %eax
  800b6b:	eb 1d                	jmp    800b8a <strtol+0xe1>
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b6d:	80 39 30             	cmpb   $0x30,(%ecx)
  800b70:	75 9a                	jne    800b0c <strtol+0x63>
  800b72:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b76:	0f 84 7a ff ff ff    	je     800af6 <strtol+0x4d>
  800b7c:	eb 84                	jmp    800b02 <strtol+0x59>
  800b7e:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b82:	0f 84 6e ff ff ff    	je     800af6 <strtol+0x4d>
  800b88:	eb 89                	jmp    800b13 <strtol+0x6a>
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
}
  800b8a:	5b                   	pop    %ebx
  800b8b:	5e                   	pop    %esi
  800b8c:	5f                   	pop    %edi
  800b8d:	5d                   	pop    %ebp
  800b8e:	c3                   	ret    

00800b8f <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
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
  800b95:	b8 00 00 00 00       	mov    $0x0,%eax
  800b9a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b9d:	8b 55 08             	mov    0x8(%ebp),%edx
  800ba0:	89 c3                	mov    %eax,%ebx
  800ba2:	89 c7                	mov    %eax,%edi
  800ba4:	89 c6                	mov    %eax,%esi
  800ba6:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ba8:	5b                   	pop    %ebx
  800ba9:	5e                   	pop    %esi
  800baa:	5f                   	pop    %edi
  800bab:	5d                   	pop    %ebp
  800bac:	c3                   	ret    

00800bad <sys_cgetc>:

int
sys_cgetc(void)
{
  800bad:	55                   	push   %ebp
  800bae:	89 e5                	mov    %esp,%ebp
  800bb0:	57                   	push   %edi
  800bb1:	56                   	push   %esi
  800bb2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bb3:	ba 00 00 00 00       	mov    $0x0,%edx
  800bb8:	b8 01 00 00 00       	mov    $0x1,%eax
  800bbd:	89 d1                	mov    %edx,%ecx
  800bbf:	89 d3                	mov    %edx,%ebx
  800bc1:	89 d7                	mov    %edx,%edi
  800bc3:	89 d6                	mov    %edx,%esi
  800bc5:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bc7:	5b                   	pop    %ebx
  800bc8:	5e                   	pop    %esi
  800bc9:	5f                   	pop    %edi
  800bca:	5d                   	pop    %ebp
  800bcb:	c3                   	ret    

00800bcc <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bcc:	55                   	push   %ebp
  800bcd:	89 e5                	mov    %esp,%ebp
  800bcf:	57                   	push   %edi
  800bd0:	56                   	push   %esi
  800bd1:	53                   	push   %ebx
  800bd2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bd5:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bda:	b8 03 00 00 00       	mov    $0x3,%eax
  800bdf:	8b 55 08             	mov    0x8(%ebp),%edx
  800be2:	89 cb                	mov    %ecx,%ebx
  800be4:	89 cf                	mov    %ecx,%edi
  800be6:	89 ce                	mov    %ecx,%esi
  800be8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bea:	85 c0                	test   %eax,%eax
  800bec:	7e 17                	jle    800c05 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bee:	83 ec 0c             	sub    $0xc,%esp
  800bf1:	50                   	push   %eax
  800bf2:	6a 03                	push   $0x3
  800bf4:	68 ff 22 80 00       	push   $0x8022ff
  800bf9:	6a 23                	push   $0x23
  800bfb:	68 1c 23 80 00       	push   $0x80231c
  800c00:	e8 19 f5 ff ff       	call   80011e <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c05:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c08:	5b                   	pop    %ebx
  800c09:	5e                   	pop    %esi
  800c0a:	5f                   	pop    %edi
  800c0b:	5d                   	pop    %ebp
  800c0c:	c3                   	ret    

00800c0d <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c0d:	55                   	push   %ebp
  800c0e:	89 e5                	mov    %esp,%ebp
  800c10:	57                   	push   %edi
  800c11:	56                   	push   %esi
  800c12:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c13:	ba 00 00 00 00       	mov    $0x0,%edx
  800c18:	b8 02 00 00 00       	mov    $0x2,%eax
  800c1d:	89 d1                	mov    %edx,%ecx
  800c1f:	89 d3                	mov    %edx,%ebx
  800c21:	89 d7                	mov    %edx,%edi
  800c23:	89 d6                	mov    %edx,%esi
  800c25:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c27:	5b                   	pop    %ebx
  800c28:	5e                   	pop    %esi
  800c29:	5f                   	pop    %edi
  800c2a:	5d                   	pop    %ebp
  800c2b:	c3                   	ret    

00800c2c <sys_yield>:

void
sys_yield(void)
{
  800c2c:	55                   	push   %ebp
  800c2d:	89 e5                	mov    %esp,%ebp
  800c2f:	57                   	push   %edi
  800c30:	56                   	push   %esi
  800c31:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c32:	ba 00 00 00 00       	mov    $0x0,%edx
  800c37:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c3c:	89 d1                	mov    %edx,%ecx
  800c3e:	89 d3                	mov    %edx,%ebx
  800c40:	89 d7                	mov    %edx,%edi
  800c42:	89 d6                	mov    %edx,%esi
  800c44:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c46:	5b                   	pop    %ebx
  800c47:	5e                   	pop    %esi
  800c48:	5f                   	pop    %edi
  800c49:	5d                   	pop    %ebp
  800c4a:	c3                   	ret    

00800c4b <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c4b:	55                   	push   %ebp
  800c4c:	89 e5                	mov    %esp,%ebp
  800c4e:	57                   	push   %edi
  800c4f:	56                   	push   %esi
  800c50:	53                   	push   %ebx
  800c51:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c54:	be 00 00 00 00       	mov    $0x0,%esi
  800c59:	b8 04 00 00 00       	mov    $0x4,%eax
  800c5e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c61:	8b 55 08             	mov    0x8(%ebp),%edx
  800c64:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c67:	89 f7                	mov    %esi,%edi
  800c69:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c6b:	85 c0                	test   %eax,%eax
  800c6d:	7e 17                	jle    800c86 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c6f:	83 ec 0c             	sub    $0xc,%esp
  800c72:	50                   	push   %eax
  800c73:	6a 04                	push   $0x4
  800c75:	68 ff 22 80 00       	push   $0x8022ff
  800c7a:	6a 23                	push   $0x23
  800c7c:	68 1c 23 80 00       	push   $0x80231c
  800c81:	e8 98 f4 ff ff       	call   80011e <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c86:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c89:	5b                   	pop    %ebx
  800c8a:	5e                   	pop    %esi
  800c8b:	5f                   	pop    %edi
  800c8c:	5d                   	pop    %ebp
  800c8d:	c3                   	ret    

00800c8e <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c8e:	55                   	push   %ebp
  800c8f:	89 e5                	mov    %esp,%ebp
  800c91:	57                   	push   %edi
  800c92:	56                   	push   %esi
  800c93:	53                   	push   %ebx
  800c94:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c97:	b8 05 00 00 00       	mov    $0x5,%eax
  800c9c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c9f:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ca5:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ca8:	8b 75 18             	mov    0x18(%ebp),%esi
  800cab:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cad:	85 c0                	test   %eax,%eax
  800caf:	7e 17                	jle    800cc8 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb1:	83 ec 0c             	sub    $0xc,%esp
  800cb4:	50                   	push   %eax
  800cb5:	6a 05                	push   $0x5
  800cb7:	68 ff 22 80 00       	push   $0x8022ff
  800cbc:	6a 23                	push   $0x23
  800cbe:	68 1c 23 80 00       	push   $0x80231c
  800cc3:	e8 56 f4 ff ff       	call   80011e <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800cc8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ccb:	5b                   	pop    %ebx
  800ccc:	5e                   	pop    %esi
  800ccd:	5f                   	pop    %edi
  800cce:	5d                   	pop    %ebp
  800ccf:	c3                   	ret    

00800cd0 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cd0:	55                   	push   %ebp
  800cd1:	89 e5                	mov    %esp,%ebp
  800cd3:	57                   	push   %edi
  800cd4:	56                   	push   %esi
  800cd5:	53                   	push   %ebx
  800cd6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cd9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cde:	b8 06 00 00 00       	mov    $0x6,%eax
  800ce3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce9:	89 df                	mov    %ebx,%edi
  800ceb:	89 de                	mov    %ebx,%esi
  800ced:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cef:	85 c0                	test   %eax,%eax
  800cf1:	7e 17                	jle    800d0a <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cf3:	83 ec 0c             	sub    $0xc,%esp
  800cf6:	50                   	push   %eax
  800cf7:	6a 06                	push   $0x6
  800cf9:	68 ff 22 80 00       	push   $0x8022ff
  800cfe:	6a 23                	push   $0x23
  800d00:	68 1c 23 80 00       	push   $0x80231c
  800d05:	e8 14 f4 ff ff       	call   80011e <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d0a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d0d:	5b                   	pop    %ebx
  800d0e:	5e                   	pop    %esi
  800d0f:	5f                   	pop    %edi
  800d10:	5d                   	pop    %ebp
  800d11:	c3                   	ret    

00800d12 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d12:	55                   	push   %ebp
  800d13:	89 e5                	mov    %esp,%ebp
  800d15:	57                   	push   %edi
  800d16:	56                   	push   %esi
  800d17:	53                   	push   %ebx
  800d18:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d1b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d20:	b8 08 00 00 00       	mov    $0x8,%eax
  800d25:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d28:	8b 55 08             	mov    0x8(%ebp),%edx
  800d2b:	89 df                	mov    %ebx,%edi
  800d2d:	89 de                	mov    %ebx,%esi
  800d2f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d31:	85 c0                	test   %eax,%eax
  800d33:	7e 17                	jle    800d4c <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d35:	83 ec 0c             	sub    $0xc,%esp
  800d38:	50                   	push   %eax
  800d39:	6a 08                	push   $0x8
  800d3b:	68 ff 22 80 00       	push   $0x8022ff
  800d40:	6a 23                	push   $0x23
  800d42:	68 1c 23 80 00       	push   $0x80231c
  800d47:	e8 d2 f3 ff ff       	call   80011e <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d4c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d4f:	5b                   	pop    %ebx
  800d50:	5e                   	pop    %esi
  800d51:	5f                   	pop    %edi
  800d52:	5d                   	pop    %ebp
  800d53:	c3                   	ret    

00800d54 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d54:	55                   	push   %ebp
  800d55:	89 e5                	mov    %esp,%ebp
  800d57:	57                   	push   %edi
  800d58:	56                   	push   %esi
  800d59:	53                   	push   %ebx
  800d5a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d5d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d62:	b8 09 00 00 00       	mov    $0x9,%eax
  800d67:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d6a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d6d:	89 df                	mov    %ebx,%edi
  800d6f:	89 de                	mov    %ebx,%esi
  800d71:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d73:	85 c0                	test   %eax,%eax
  800d75:	7e 17                	jle    800d8e <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d77:	83 ec 0c             	sub    $0xc,%esp
  800d7a:	50                   	push   %eax
  800d7b:	6a 09                	push   $0x9
  800d7d:	68 ff 22 80 00       	push   $0x8022ff
  800d82:	6a 23                	push   $0x23
  800d84:	68 1c 23 80 00       	push   $0x80231c
  800d89:	e8 90 f3 ff ff       	call   80011e <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d8e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d91:	5b                   	pop    %ebx
  800d92:	5e                   	pop    %esi
  800d93:	5f                   	pop    %edi
  800d94:	5d                   	pop    %ebp
  800d95:	c3                   	ret    

00800d96 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d96:	55                   	push   %ebp
  800d97:	89 e5                	mov    %esp,%ebp
  800d99:	57                   	push   %edi
  800d9a:	56                   	push   %esi
  800d9b:	53                   	push   %ebx
  800d9c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d9f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800da4:	b8 0a 00 00 00       	mov    $0xa,%eax
  800da9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dac:	8b 55 08             	mov    0x8(%ebp),%edx
  800daf:	89 df                	mov    %ebx,%edi
  800db1:	89 de                	mov    %ebx,%esi
  800db3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800db5:	85 c0                	test   %eax,%eax
  800db7:	7e 17                	jle    800dd0 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800db9:	83 ec 0c             	sub    $0xc,%esp
  800dbc:	50                   	push   %eax
  800dbd:	6a 0a                	push   $0xa
  800dbf:	68 ff 22 80 00       	push   $0x8022ff
  800dc4:	6a 23                	push   $0x23
  800dc6:	68 1c 23 80 00       	push   $0x80231c
  800dcb:	e8 4e f3 ff ff       	call   80011e <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800dd0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dd3:	5b                   	pop    %ebx
  800dd4:	5e                   	pop    %esi
  800dd5:	5f                   	pop    %edi
  800dd6:	5d                   	pop    %ebp
  800dd7:	c3                   	ret    

00800dd8 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800dd8:	55                   	push   %ebp
  800dd9:	89 e5                	mov    %esp,%ebp
  800ddb:	57                   	push   %edi
  800ddc:	56                   	push   %esi
  800ddd:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dde:	be 00 00 00 00       	mov    $0x0,%esi
  800de3:	b8 0c 00 00 00       	mov    $0xc,%eax
  800de8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800deb:	8b 55 08             	mov    0x8(%ebp),%edx
  800dee:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800df1:	8b 7d 14             	mov    0x14(%ebp),%edi
  800df4:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800df6:	5b                   	pop    %ebx
  800df7:	5e                   	pop    %esi
  800df8:	5f                   	pop    %edi
  800df9:	5d                   	pop    %ebp
  800dfa:	c3                   	ret    

00800dfb <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800dfb:	55                   	push   %ebp
  800dfc:	89 e5                	mov    %esp,%ebp
  800dfe:	57                   	push   %edi
  800dff:	56                   	push   %esi
  800e00:	53                   	push   %ebx
  800e01:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e04:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e09:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e0e:	8b 55 08             	mov    0x8(%ebp),%edx
  800e11:	89 cb                	mov    %ecx,%ebx
  800e13:	89 cf                	mov    %ecx,%edi
  800e15:	89 ce                	mov    %ecx,%esi
  800e17:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e19:	85 c0                	test   %eax,%eax
  800e1b:	7e 17                	jle    800e34 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e1d:	83 ec 0c             	sub    $0xc,%esp
  800e20:	50                   	push   %eax
  800e21:	6a 0d                	push   $0xd
  800e23:	68 ff 22 80 00       	push   $0x8022ff
  800e28:	6a 23                	push   $0x23
  800e2a:	68 1c 23 80 00       	push   $0x80231c
  800e2f:	e8 ea f2 ff ff       	call   80011e <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e34:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e37:	5b                   	pop    %ebx
  800e38:	5e                   	pop    %esi
  800e39:	5f                   	pop    %edi
  800e3a:	5d                   	pop    %ebp
  800e3b:	c3                   	ret    

00800e3c <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800e3c:	55                   	push   %ebp
  800e3d:	89 e5                	mov    %esp,%ebp
  800e3f:	53                   	push   %ebx
  800e40:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (_pgfault_handler == 0) {
  800e43:	83 3d 08 40 80 00 00 	cmpl   $0x0,0x804008
  800e4a:	75 5b                	jne    800ea7 <set_pgfault_handler+0x6b>
		// First time through!
		// LAB 4: Your code here.
		void *va = (void *)(UXSTACKTOP - PGSIZE);
		envid_t eid = sys_getenvid();
  800e4c:	e8 bc fd ff ff       	call   800c0d <sys_getenvid>
  800e51:	89 c3                	mov    %eax,%ebx
		r = sys_page_alloc(eid,va,PTE_P | PTE_U | PTE_W);
  800e53:	83 ec 04             	sub    $0x4,%esp
  800e56:	6a 07                	push   $0x7
  800e58:	68 00 f0 bf ee       	push   $0xeebff000
  800e5d:	50                   	push   %eax
  800e5e:	e8 e8 fd ff ff       	call   800c4b <sys_page_alloc>
		if(r<0) panic("set_pgfault_handler\n");
  800e63:	83 c4 10             	add    $0x10,%esp
  800e66:	85 c0                	test   %eax,%eax
  800e68:	79 14                	jns    800e7e <set_pgfault_handler+0x42>
  800e6a:	83 ec 04             	sub    $0x4,%esp
  800e6d:	68 2a 23 80 00       	push   $0x80232a
  800e72:	6a 23                	push   $0x23
  800e74:	68 3f 23 80 00       	push   $0x80233f
  800e79:	e8 a0 f2 ff ff       	call   80011e <_panic>
		r = sys_env_set_pgfault_upcall(eid,_pgfault_upcall);
  800e7e:	83 ec 08             	sub    $0x8,%esp
  800e81:	68 b4 0e 80 00       	push   $0x800eb4
  800e86:	53                   	push   %ebx
  800e87:	e8 0a ff ff ff       	call   800d96 <sys_env_set_pgfault_upcall>
		if(r<0) panic("set_pgfault_handler\n");
  800e8c:	83 c4 10             	add    $0x10,%esp
  800e8f:	85 c0                	test   %eax,%eax
  800e91:	79 14                	jns    800ea7 <set_pgfault_handler+0x6b>
  800e93:	83 ec 04             	sub    $0x4,%esp
  800e96:	68 2a 23 80 00       	push   $0x80232a
  800e9b:	6a 25                	push   $0x25
  800e9d:	68 3f 23 80 00       	push   $0x80233f
  800ea2:	e8 77 f2 ff ff       	call   80011e <_panic>
		// panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800ea7:	8b 45 08             	mov    0x8(%ebp),%eax
  800eaa:	a3 08 40 80 00       	mov    %eax,0x804008
}
  800eaf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800eb2:	c9                   	leave  
  800eb3:	c3                   	ret    

00800eb4 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800eb4:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800eb5:	a1 08 40 80 00       	mov    0x804008,%eax
	call *%eax
  800eba:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800ebc:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl %esp,%ebx
  800ebf:	89 e3                	mov    %esp,%ebx
	movl 40(%esp),%eax 	// esp from utf_fault_va to utf_regs(end)
  800ec1:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl 48(%esp),%esp 	// 
  800ec5:	8b 64 24 30          	mov    0x30(%esp),%esp
	pushl %eax
  800ec9:	50                   	push   %eax
 
 
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	movl %ebx,%esp
  800eca:	89 dc                	mov    %ebx,%esp
	subl $4,48(%esp)
  800ecc:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	popl %eax
  800ed1:	58                   	pop    %eax
	popl %eax
  800ed2:	58                   	pop    %eax
	popal
  800ed3:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	add $4,%esp
  800ed4:	83 c4 04             	add    $0x4,%esp
	popfl
  800ed7:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  800ed8:	5c                   	pop    %esp
 
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  800ed9:	c3                   	ret    

00800eda <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800eda:	55                   	push   %ebp
  800edb:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800edd:	8b 45 08             	mov    0x8(%ebp),%eax
  800ee0:	05 00 00 00 30       	add    $0x30000000,%eax
  800ee5:	c1 e8 0c             	shr    $0xc,%eax
}
  800ee8:	5d                   	pop    %ebp
  800ee9:	c3                   	ret    

00800eea <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800eea:	55                   	push   %ebp
  800eeb:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800eed:	8b 45 08             	mov    0x8(%ebp),%eax
  800ef0:	05 00 00 00 30       	add    $0x30000000,%eax
  800ef5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800efa:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800eff:	5d                   	pop    %ebp
  800f00:	c3                   	ret    

00800f01 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800f01:	55                   	push   %ebp
  800f02:	89 e5                	mov    %esp,%ebp
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800f04:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  800f09:	a8 01                	test   $0x1,%al
  800f0b:	74 34                	je     800f41 <fd_alloc+0x40>
  800f0d:	a1 00 00 74 ef       	mov    0xef740000,%eax
  800f12:	a8 01                	test   $0x1,%al
  800f14:	74 32                	je     800f48 <fd_alloc+0x47>
  800f16:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800f1b:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800f1d:	89 c2                	mov    %eax,%edx
  800f1f:	c1 ea 16             	shr    $0x16,%edx
  800f22:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f29:	f6 c2 01             	test   $0x1,%dl
  800f2c:	74 1f                	je     800f4d <fd_alloc+0x4c>
  800f2e:	89 c2                	mov    %eax,%edx
  800f30:	c1 ea 0c             	shr    $0xc,%edx
  800f33:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f3a:	f6 c2 01             	test   $0x1,%dl
  800f3d:	75 1a                	jne    800f59 <fd_alloc+0x58>
  800f3f:	eb 0c                	jmp    800f4d <fd_alloc+0x4c>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800f41:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  800f46:	eb 05                	jmp    800f4d <fd_alloc+0x4c>
  800f48:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  800f4d:	8b 45 08             	mov    0x8(%ebp),%eax
  800f50:	89 08                	mov    %ecx,(%eax)
			return 0;
  800f52:	b8 00 00 00 00       	mov    $0x0,%eax
  800f57:	eb 1a                	jmp    800f73 <fd_alloc+0x72>
  800f59:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800f5e:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800f63:	75 b6                	jne    800f1b <fd_alloc+0x1a>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800f65:	8b 45 08             	mov    0x8(%ebp),%eax
  800f68:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  800f6e:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800f73:	5d                   	pop    %ebp
  800f74:	c3                   	ret    

00800f75 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800f75:	55                   	push   %ebp
  800f76:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800f78:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
  800f7c:	77 39                	ja     800fb7 <fd_lookup+0x42>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800f7e:	8b 45 08             	mov    0x8(%ebp),%eax
  800f81:	c1 e0 0c             	shl    $0xc,%eax
  800f84:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800f89:	89 c2                	mov    %eax,%edx
  800f8b:	c1 ea 16             	shr    $0x16,%edx
  800f8e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f95:	f6 c2 01             	test   $0x1,%dl
  800f98:	74 24                	je     800fbe <fd_lookup+0x49>
  800f9a:	89 c2                	mov    %eax,%edx
  800f9c:	c1 ea 0c             	shr    $0xc,%edx
  800f9f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800fa6:	f6 c2 01             	test   $0x1,%dl
  800fa9:	74 1a                	je     800fc5 <fd_lookup+0x50>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800fab:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fae:	89 02                	mov    %eax,(%edx)
	return 0;
  800fb0:	b8 00 00 00 00       	mov    $0x0,%eax
  800fb5:	eb 13                	jmp    800fca <fd_lookup+0x55>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800fb7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800fbc:	eb 0c                	jmp    800fca <fd_lookup+0x55>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800fbe:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800fc3:	eb 05                	jmp    800fca <fd_lookup+0x55>
  800fc5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800fca:	5d                   	pop    %ebp
  800fcb:	c3                   	ret    

00800fcc <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800fcc:	55                   	push   %ebp
  800fcd:	89 e5                	mov    %esp,%ebp
  800fcf:	53                   	push   %ebx
  800fd0:	83 ec 04             	sub    $0x4,%esp
  800fd3:	8b 45 08             	mov    0x8(%ebp),%eax
  800fd6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  800fd9:	3b 05 04 30 80 00    	cmp    0x803004,%eax
  800fdf:	75 1e                	jne    800fff <dev_lookup+0x33>
  800fe1:	eb 0e                	jmp    800ff1 <dev_lookup+0x25>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800fe3:	b8 20 30 80 00       	mov    $0x803020,%eax
  800fe8:	eb 0c                	jmp    800ff6 <dev_lookup+0x2a>
  800fea:	b8 3c 30 80 00       	mov    $0x80303c,%eax
  800fef:	eb 05                	jmp    800ff6 <dev_lookup+0x2a>
  800ff1:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  800ff6:	89 03                	mov    %eax,(%ebx)
			return 0;
  800ff8:	b8 00 00 00 00       	mov    $0x0,%eax
  800ffd:	eb 36                	jmp    801035 <dev_lookup+0x69>
int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  800fff:	3b 05 20 30 80 00    	cmp    0x803020,%eax
  801005:	74 dc                	je     800fe3 <dev_lookup+0x17>
  801007:	3b 05 3c 30 80 00    	cmp    0x80303c,%eax
  80100d:	74 db                	je     800fea <dev_lookup+0x1e>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80100f:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801015:	8b 52 48             	mov    0x48(%edx),%edx
  801018:	83 ec 04             	sub    $0x4,%esp
  80101b:	50                   	push   %eax
  80101c:	52                   	push   %edx
  80101d:	68 50 23 80 00       	push   $0x802350
  801022:	e8 cf f1 ff ff       	call   8001f6 <cprintf>
	*dev = 0;
  801027:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  80102d:	83 c4 10             	add    $0x10,%esp
  801030:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801035:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801038:	c9                   	leave  
  801039:	c3                   	ret    

0080103a <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80103a:	55                   	push   %ebp
  80103b:	89 e5                	mov    %esp,%ebp
  80103d:	56                   	push   %esi
  80103e:	53                   	push   %ebx
  80103f:	83 ec 10             	sub    $0x10,%esp
  801042:	8b 75 08             	mov    0x8(%ebp),%esi
  801045:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801048:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80104b:	50                   	push   %eax
  80104c:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801052:	c1 e8 0c             	shr    $0xc,%eax
  801055:	50                   	push   %eax
  801056:	e8 1a ff ff ff       	call   800f75 <fd_lookup>
  80105b:	83 c4 08             	add    $0x8,%esp
  80105e:	85 c0                	test   %eax,%eax
  801060:	78 05                	js     801067 <fd_close+0x2d>
	    || fd != fd2)
  801062:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801065:	74 06                	je     80106d <fd_close+0x33>
		return (must_exist ? r : 0);
  801067:	84 db                	test   %bl,%bl
  801069:	74 47                	je     8010b2 <fd_close+0x78>
  80106b:	eb 4a                	jmp    8010b7 <fd_close+0x7d>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80106d:	83 ec 08             	sub    $0x8,%esp
  801070:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801073:	50                   	push   %eax
  801074:	ff 36                	pushl  (%esi)
  801076:	e8 51 ff ff ff       	call   800fcc <dev_lookup>
  80107b:	89 c3                	mov    %eax,%ebx
  80107d:	83 c4 10             	add    $0x10,%esp
  801080:	85 c0                	test   %eax,%eax
  801082:	78 1c                	js     8010a0 <fd_close+0x66>
		if (dev->dev_close)
  801084:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801087:	8b 40 10             	mov    0x10(%eax),%eax
  80108a:	85 c0                	test   %eax,%eax
  80108c:	74 0d                	je     80109b <fd_close+0x61>
			r = (*dev->dev_close)(fd);
  80108e:	83 ec 0c             	sub    $0xc,%esp
  801091:	56                   	push   %esi
  801092:	ff d0                	call   *%eax
  801094:	89 c3                	mov    %eax,%ebx
  801096:	83 c4 10             	add    $0x10,%esp
  801099:	eb 05                	jmp    8010a0 <fd_close+0x66>
		else
			r = 0;
  80109b:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8010a0:	83 ec 08             	sub    $0x8,%esp
  8010a3:	56                   	push   %esi
  8010a4:	6a 00                	push   $0x0
  8010a6:	e8 25 fc ff ff       	call   800cd0 <sys_page_unmap>
	return r;
  8010ab:	83 c4 10             	add    $0x10,%esp
  8010ae:	89 d8                	mov    %ebx,%eax
  8010b0:	eb 05                	jmp    8010b7 <fd_close+0x7d>
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
  8010b2:	b8 00 00 00 00       	mov    $0x0,%eax
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
	return r;
}
  8010b7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010ba:	5b                   	pop    %ebx
  8010bb:	5e                   	pop    %esi
  8010bc:	5d                   	pop    %ebp
  8010bd:	c3                   	ret    

008010be <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8010be:	55                   	push   %ebp
  8010bf:	89 e5                	mov    %esp,%ebp
  8010c1:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8010c4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010c7:	50                   	push   %eax
  8010c8:	ff 75 08             	pushl  0x8(%ebp)
  8010cb:	e8 a5 fe ff ff       	call   800f75 <fd_lookup>
  8010d0:	83 c4 08             	add    $0x8,%esp
  8010d3:	85 c0                	test   %eax,%eax
  8010d5:	78 10                	js     8010e7 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8010d7:	83 ec 08             	sub    $0x8,%esp
  8010da:	6a 01                	push   $0x1
  8010dc:	ff 75 f4             	pushl  -0xc(%ebp)
  8010df:	e8 56 ff ff ff       	call   80103a <fd_close>
  8010e4:	83 c4 10             	add    $0x10,%esp
}
  8010e7:	c9                   	leave  
  8010e8:	c3                   	ret    

008010e9 <close_all>:

void
close_all(void)
{
  8010e9:	55                   	push   %ebp
  8010ea:	89 e5                	mov    %esp,%ebp
  8010ec:	53                   	push   %ebx
  8010ed:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8010f0:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8010f5:	83 ec 0c             	sub    $0xc,%esp
  8010f8:	53                   	push   %ebx
  8010f9:	e8 c0 ff ff ff       	call   8010be <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8010fe:	43                   	inc    %ebx
  8010ff:	83 c4 10             	add    $0x10,%esp
  801102:	83 fb 20             	cmp    $0x20,%ebx
  801105:	75 ee                	jne    8010f5 <close_all+0xc>
		close(i);
}
  801107:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80110a:	c9                   	leave  
  80110b:	c3                   	ret    

0080110c <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80110c:	55                   	push   %ebp
  80110d:	89 e5                	mov    %esp,%ebp
  80110f:	57                   	push   %edi
  801110:	56                   	push   %esi
  801111:	53                   	push   %ebx
  801112:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801115:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801118:	50                   	push   %eax
  801119:	ff 75 08             	pushl  0x8(%ebp)
  80111c:	e8 54 fe ff ff       	call   800f75 <fd_lookup>
  801121:	83 c4 08             	add    $0x8,%esp
  801124:	85 c0                	test   %eax,%eax
  801126:	0f 88 c2 00 00 00    	js     8011ee <dup+0xe2>
		return r;
	close(newfdnum);
  80112c:	83 ec 0c             	sub    $0xc,%esp
  80112f:	ff 75 0c             	pushl  0xc(%ebp)
  801132:	e8 87 ff ff ff       	call   8010be <close>

	newfd = INDEX2FD(newfdnum);
  801137:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80113a:	c1 e3 0c             	shl    $0xc,%ebx
  80113d:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801143:	83 c4 04             	add    $0x4,%esp
  801146:	ff 75 e4             	pushl  -0x1c(%ebp)
  801149:	e8 9c fd ff ff       	call   800eea <fd2data>
  80114e:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  801150:	89 1c 24             	mov    %ebx,(%esp)
  801153:	e8 92 fd ff ff       	call   800eea <fd2data>
  801158:	83 c4 10             	add    $0x10,%esp
  80115b:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80115d:	89 f0                	mov    %esi,%eax
  80115f:	c1 e8 16             	shr    $0x16,%eax
  801162:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801169:	a8 01                	test   $0x1,%al
  80116b:	74 35                	je     8011a2 <dup+0x96>
  80116d:	89 f0                	mov    %esi,%eax
  80116f:	c1 e8 0c             	shr    $0xc,%eax
  801172:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801179:	f6 c2 01             	test   $0x1,%dl
  80117c:	74 24                	je     8011a2 <dup+0x96>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80117e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801185:	83 ec 0c             	sub    $0xc,%esp
  801188:	25 07 0e 00 00       	and    $0xe07,%eax
  80118d:	50                   	push   %eax
  80118e:	57                   	push   %edi
  80118f:	6a 00                	push   $0x0
  801191:	56                   	push   %esi
  801192:	6a 00                	push   $0x0
  801194:	e8 f5 fa ff ff       	call   800c8e <sys_page_map>
  801199:	89 c6                	mov    %eax,%esi
  80119b:	83 c4 20             	add    $0x20,%esp
  80119e:	85 c0                	test   %eax,%eax
  8011a0:	78 2c                	js     8011ce <dup+0xc2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8011a2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8011a5:	89 d0                	mov    %edx,%eax
  8011a7:	c1 e8 0c             	shr    $0xc,%eax
  8011aa:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8011b1:	83 ec 0c             	sub    $0xc,%esp
  8011b4:	25 07 0e 00 00       	and    $0xe07,%eax
  8011b9:	50                   	push   %eax
  8011ba:	53                   	push   %ebx
  8011bb:	6a 00                	push   $0x0
  8011bd:	52                   	push   %edx
  8011be:	6a 00                	push   $0x0
  8011c0:	e8 c9 fa ff ff       	call   800c8e <sys_page_map>
  8011c5:	89 c6                	mov    %eax,%esi
  8011c7:	83 c4 20             	add    $0x20,%esp
  8011ca:	85 c0                	test   %eax,%eax
  8011cc:	79 1d                	jns    8011eb <dup+0xdf>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8011ce:	83 ec 08             	sub    $0x8,%esp
  8011d1:	53                   	push   %ebx
  8011d2:	6a 00                	push   $0x0
  8011d4:	e8 f7 fa ff ff       	call   800cd0 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8011d9:	83 c4 08             	add    $0x8,%esp
  8011dc:	57                   	push   %edi
  8011dd:	6a 00                	push   $0x0
  8011df:	e8 ec fa ff ff       	call   800cd0 <sys_page_unmap>
	return r;
  8011e4:	83 c4 10             	add    $0x10,%esp
  8011e7:	89 f0                	mov    %esi,%eax
  8011e9:	eb 03                	jmp    8011ee <dup+0xe2>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  8011eb:	8b 45 0c             	mov    0xc(%ebp),%eax

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8011ee:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011f1:	5b                   	pop    %ebx
  8011f2:	5e                   	pop    %esi
  8011f3:	5f                   	pop    %edi
  8011f4:	5d                   	pop    %ebp
  8011f5:	c3                   	ret    

008011f6 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8011f6:	55                   	push   %ebp
  8011f7:	89 e5                	mov    %esp,%ebp
  8011f9:	53                   	push   %ebx
  8011fa:	83 ec 14             	sub    $0x14,%esp
  8011fd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801200:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801203:	50                   	push   %eax
  801204:	53                   	push   %ebx
  801205:	e8 6b fd ff ff       	call   800f75 <fd_lookup>
  80120a:	83 c4 08             	add    $0x8,%esp
  80120d:	85 c0                	test   %eax,%eax
  80120f:	78 67                	js     801278 <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801211:	83 ec 08             	sub    $0x8,%esp
  801214:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801217:	50                   	push   %eax
  801218:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80121b:	ff 30                	pushl  (%eax)
  80121d:	e8 aa fd ff ff       	call   800fcc <dev_lookup>
  801222:	83 c4 10             	add    $0x10,%esp
  801225:	85 c0                	test   %eax,%eax
  801227:	78 4f                	js     801278 <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801229:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80122c:	8b 42 08             	mov    0x8(%edx),%eax
  80122f:	83 e0 03             	and    $0x3,%eax
  801232:	83 f8 01             	cmp    $0x1,%eax
  801235:	75 21                	jne    801258 <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801237:	a1 04 40 80 00       	mov    0x804004,%eax
  80123c:	8b 40 48             	mov    0x48(%eax),%eax
  80123f:	83 ec 04             	sub    $0x4,%esp
  801242:	53                   	push   %ebx
  801243:	50                   	push   %eax
  801244:	68 94 23 80 00       	push   $0x802394
  801249:	e8 a8 ef ff ff       	call   8001f6 <cprintf>
		return -E_INVAL;
  80124e:	83 c4 10             	add    $0x10,%esp
  801251:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801256:	eb 20                	jmp    801278 <read+0x82>
	}
	if (!dev->dev_read)
  801258:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80125b:	8b 40 08             	mov    0x8(%eax),%eax
  80125e:	85 c0                	test   %eax,%eax
  801260:	74 11                	je     801273 <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801262:	83 ec 04             	sub    $0x4,%esp
  801265:	ff 75 10             	pushl  0x10(%ebp)
  801268:	ff 75 0c             	pushl  0xc(%ebp)
  80126b:	52                   	push   %edx
  80126c:	ff d0                	call   *%eax
  80126e:	83 c4 10             	add    $0x10,%esp
  801271:	eb 05                	jmp    801278 <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801273:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801278:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80127b:	c9                   	leave  
  80127c:	c3                   	ret    

0080127d <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80127d:	55                   	push   %ebp
  80127e:	89 e5                	mov    %esp,%ebp
  801280:	57                   	push   %edi
  801281:	56                   	push   %esi
  801282:	53                   	push   %ebx
  801283:	83 ec 0c             	sub    $0xc,%esp
  801286:	8b 7d 08             	mov    0x8(%ebp),%edi
  801289:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80128c:	85 f6                	test   %esi,%esi
  80128e:	74 31                	je     8012c1 <readn+0x44>
  801290:	b8 00 00 00 00       	mov    $0x0,%eax
  801295:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  80129a:	83 ec 04             	sub    $0x4,%esp
  80129d:	89 f2                	mov    %esi,%edx
  80129f:	29 c2                	sub    %eax,%edx
  8012a1:	52                   	push   %edx
  8012a2:	03 45 0c             	add    0xc(%ebp),%eax
  8012a5:	50                   	push   %eax
  8012a6:	57                   	push   %edi
  8012a7:	e8 4a ff ff ff       	call   8011f6 <read>
		if (m < 0)
  8012ac:	83 c4 10             	add    $0x10,%esp
  8012af:	85 c0                	test   %eax,%eax
  8012b1:	78 17                	js     8012ca <readn+0x4d>
			return m;
		if (m == 0)
  8012b3:	85 c0                	test   %eax,%eax
  8012b5:	74 11                	je     8012c8 <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8012b7:	01 c3                	add    %eax,%ebx
  8012b9:	89 d8                	mov    %ebx,%eax
  8012bb:	39 f3                	cmp    %esi,%ebx
  8012bd:	72 db                	jb     80129a <readn+0x1d>
  8012bf:	eb 09                	jmp    8012ca <readn+0x4d>
  8012c1:	b8 00 00 00 00       	mov    $0x0,%eax
  8012c6:	eb 02                	jmp    8012ca <readn+0x4d>
  8012c8:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8012ca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012cd:	5b                   	pop    %ebx
  8012ce:	5e                   	pop    %esi
  8012cf:	5f                   	pop    %edi
  8012d0:	5d                   	pop    %ebp
  8012d1:	c3                   	ret    

008012d2 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8012d2:	55                   	push   %ebp
  8012d3:	89 e5                	mov    %esp,%ebp
  8012d5:	53                   	push   %ebx
  8012d6:	83 ec 14             	sub    $0x14,%esp
  8012d9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012dc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012df:	50                   	push   %eax
  8012e0:	53                   	push   %ebx
  8012e1:	e8 8f fc ff ff       	call   800f75 <fd_lookup>
  8012e6:	83 c4 08             	add    $0x8,%esp
  8012e9:	85 c0                	test   %eax,%eax
  8012eb:	78 62                	js     80134f <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012ed:	83 ec 08             	sub    $0x8,%esp
  8012f0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012f3:	50                   	push   %eax
  8012f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012f7:	ff 30                	pushl  (%eax)
  8012f9:	e8 ce fc ff ff       	call   800fcc <dev_lookup>
  8012fe:	83 c4 10             	add    $0x10,%esp
  801301:	85 c0                	test   %eax,%eax
  801303:	78 4a                	js     80134f <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801305:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801308:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80130c:	75 21                	jne    80132f <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80130e:	a1 04 40 80 00       	mov    0x804004,%eax
  801313:	8b 40 48             	mov    0x48(%eax),%eax
  801316:	83 ec 04             	sub    $0x4,%esp
  801319:	53                   	push   %ebx
  80131a:	50                   	push   %eax
  80131b:	68 b0 23 80 00       	push   $0x8023b0
  801320:	e8 d1 ee ff ff       	call   8001f6 <cprintf>
		return -E_INVAL;
  801325:	83 c4 10             	add    $0x10,%esp
  801328:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80132d:	eb 20                	jmp    80134f <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80132f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801332:	8b 52 0c             	mov    0xc(%edx),%edx
  801335:	85 d2                	test   %edx,%edx
  801337:	74 11                	je     80134a <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801339:	83 ec 04             	sub    $0x4,%esp
  80133c:	ff 75 10             	pushl  0x10(%ebp)
  80133f:	ff 75 0c             	pushl  0xc(%ebp)
  801342:	50                   	push   %eax
  801343:	ff d2                	call   *%edx
  801345:	83 c4 10             	add    $0x10,%esp
  801348:	eb 05                	jmp    80134f <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80134a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  80134f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801352:	c9                   	leave  
  801353:	c3                   	ret    

00801354 <seek>:

int
seek(int fdnum, off_t offset)
{
  801354:	55                   	push   %ebp
  801355:	89 e5                	mov    %esp,%ebp
  801357:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80135a:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80135d:	50                   	push   %eax
  80135e:	ff 75 08             	pushl  0x8(%ebp)
  801361:	e8 0f fc ff ff       	call   800f75 <fd_lookup>
  801366:	83 c4 08             	add    $0x8,%esp
  801369:	85 c0                	test   %eax,%eax
  80136b:	78 0e                	js     80137b <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80136d:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801370:	8b 55 0c             	mov    0xc(%ebp),%edx
  801373:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801376:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80137b:	c9                   	leave  
  80137c:	c3                   	ret    

0080137d <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80137d:	55                   	push   %ebp
  80137e:	89 e5                	mov    %esp,%ebp
  801380:	53                   	push   %ebx
  801381:	83 ec 14             	sub    $0x14,%esp
  801384:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801387:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80138a:	50                   	push   %eax
  80138b:	53                   	push   %ebx
  80138c:	e8 e4 fb ff ff       	call   800f75 <fd_lookup>
  801391:	83 c4 08             	add    $0x8,%esp
  801394:	85 c0                	test   %eax,%eax
  801396:	78 5f                	js     8013f7 <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801398:	83 ec 08             	sub    $0x8,%esp
  80139b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80139e:	50                   	push   %eax
  80139f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013a2:	ff 30                	pushl  (%eax)
  8013a4:	e8 23 fc ff ff       	call   800fcc <dev_lookup>
  8013a9:	83 c4 10             	add    $0x10,%esp
  8013ac:	85 c0                	test   %eax,%eax
  8013ae:	78 47                	js     8013f7 <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8013b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013b3:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8013b7:	75 21                	jne    8013da <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8013b9:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8013be:	8b 40 48             	mov    0x48(%eax),%eax
  8013c1:	83 ec 04             	sub    $0x4,%esp
  8013c4:	53                   	push   %ebx
  8013c5:	50                   	push   %eax
  8013c6:	68 70 23 80 00       	push   $0x802370
  8013cb:	e8 26 ee ff ff       	call   8001f6 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8013d0:	83 c4 10             	add    $0x10,%esp
  8013d3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013d8:	eb 1d                	jmp    8013f7 <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  8013da:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8013dd:	8b 52 18             	mov    0x18(%edx),%edx
  8013e0:	85 d2                	test   %edx,%edx
  8013e2:	74 0e                	je     8013f2 <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8013e4:	83 ec 08             	sub    $0x8,%esp
  8013e7:	ff 75 0c             	pushl  0xc(%ebp)
  8013ea:	50                   	push   %eax
  8013eb:	ff d2                	call   *%edx
  8013ed:	83 c4 10             	add    $0x10,%esp
  8013f0:	eb 05                	jmp    8013f7 <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8013f2:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8013f7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013fa:	c9                   	leave  
  8013fb:	c3                   	ret    

008013fc <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8013fc:	55                   	push   %ebp
  8013fd:	89 e5                	mov    %esp,%ebp
  8013ff:	53                   	push   %ebx
  801400:	83 ec 14             	sub    $0x14,%esp
  801403:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801406:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801409:	50                   	push   %eax
  80140a:	ff 75 08             	pushl  0x8(%ebp)
  80140d:	e8 63 fb ff ff       	call   800f75 <fd_lookup>
  801412:	83 c4 08             	add    $0x8,%esp
  801415:	85 c0                	test   %eax,%eax
  801417:	78 52                	js     80146b <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801419:	83 ec 08             	sub    $0x8,%esp
  80141c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80141f:	50                   	push   %eax
  801420:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801423:	ff 30                	pushl  (%eax)
  801425:	e8 a2 fb ff ff       	call   800fcc <dev_lookup>
  80142a:	83 c4 10             	add    $0x10,%esp
  80142d:	85 c0                	test   %eax,%eax
  80142f:	78 3a                	js     80146b <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  801431:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801434:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801438:	74 2c                	je     801466 <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80143a:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80143d:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801444:	00 00 00 
	stat->st_isdir = 0;
  801447:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80144e:	00 00 00 
	stat->st_dev = dev;
  801451:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801457:	83 ec 08             	sub    $0x8,%esp
  80145a:	53                   	push   %ebx
  80145b:	ff 75 f0             	pushl  -0x10(%ebp)
  80145e:	ff 50 14             	call   *0x14(%eax)
  801461:	83 c4 10             	add    $0x10,%esp
  801464:	eb 05                	jmp    80146b <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801466:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80146b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80146e:	c9                   	leave  
  80146f:	c3                   	ret    

00801470 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801470:	55                   	push   %ebp
  801471:	89 e5                	mov    %esp,%ebp
  801473:	56                   	push   %esi
  801474:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801475:	83 ec 08             	sub    $0x8,%esp
  801478:	6a 00                	push   $0x0
  80147a:	ff 75 08             	pushl  0x8(%ebp)
  80147d:	e8 75 01 00 00       	call   8015f7 <open>
  801482:	89 c3                	mov    %eax,%ebx
  801484:	83 c4 10             	add    $0x10,%esp
  801487:	85 c0                	test   %eax,%eax
  801489:	78 1d                	js     8014a8 <stat+0x38>
		return fd;
	r = fstat(fd, stat);
  80148b:	83 ec 08             	sub    $0x8,%esp
  80148e:	ff 75 0c             	pushl  0xc(%ebp)
  801491:	50                   	push   %eax
  801492:	e8 65 ff ff ff       	call   8013fc <fstat>
  801497:	89 c6                	mov    %eax,%esi
	close(fd);
  801499:	89 1c 24             	mov    %ebx,(%esp)
  80149c:	e8 1d fc ff ff       	call   8010be <close>
	return r;
  8014a1:	83 c4 10             	add    $0x10,%esp
  8014a4:	89 f0                	mov    %esi,%eax
  8014a6:	eb 00                	jmp    8014a8 <stat+0x38>
}
  8014a8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014ab:	5b                   	pop    %ebx
  8014ac:	5e                   	pop    %esi
  8014ad:	5d                   	pop    %ebp
  8014ae:	c3                   	ret    

008014af <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8014af:	55                   	push   %ebp
  8014b0:	89 e5                	mov    %esp,%ebp
  8014b2:	56                   	push   %esi
  8014b3:	53                   	push   %ebx
  8014b4:	89 c6                	mov    %eax,%esi
  8014b6:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8014b8:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8014bf:	75 12                	jne    8014d3 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8014c1:	83 ec 0c             	sub    $0xc,%esp
  8014c4:	6a 01                	push   $0x1
  8014c6:	e8 7b 07 00 00       	call   801c46 <ipc_find_env>
  8014cb:	a3 00 40 80 00       	mov    %eax,0x804000
  8014d0:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8014d3:	6a 07                	push   $0x7
  8014d5:	68 00 50 80 00       	push   $0x805000
  8014da:	56                   	push   %esi
  8014db:	ff 35 00 40 80 00    	pushl  0x804000
  8014e1:	e8 01 07 00 00       	call   801be7 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8014e6:	83 c4 0c             	add    $0xc,%esp
  8014e9:	6a 00                	push   $0x0
  8014eb:	53                   	push   %ebx
  8014ec:	6a 00                	push   $0x0
  8014ee:	e8 7f 06 00 00       	call   801b72 <ipc_recv>
}
  8014f3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014f6:	5b                   	pop    %ebx
  8014f7:	5e                   	pop    %esi
  8014f8:	5d                   	pop    %ebp
  8014f9:	c3                   	ret    

008014fa <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8014fa:	55                   	push   %ebp
  8014fb:	89 e5                	mov    %esp,%ebp
  8014fd:	53                   	push   %ebx
  8014fe:	83 ec 04             	sub    $0x4,%esp
  801501:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801504:	8b 45 08             	mov    0x8(%ebp),%eax
  801507:	8b 40 0c             	mov    0xc(%eax),%eax
  80150a:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80150f:	ba 00 00 00 00       	mov    $0x0,%edx
  801514:	b8 05 00 00 00       	mov    $0x5,%eax
  801519:	e8 91 ff ff ff       	call   8014af <fsipc>
  80151e:	85 c0                	test   %eax,%eax
  801520:	78 2c                	js     80154e <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801522:	83 ec 08             	sub    $0x8,%esp
  801525:	68 00 50 80 00       	push   $0x805000
  80152a:	53                   	push   %ebx
  80152b:	e8 ab f2 ff ff       	call   8007db <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801530:	a1 80 50 80 00       	mov    0x805080,%eax
  801535:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80153b:	a1 84 50 80 00       	mov    0x805084,%eax
  801540:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801546:	83 c4 10             	add    $0x10,%esp
  801549:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80154e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801551:	c9                   	leave  
  801552:	c3                   	ret    

00801553 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801553:	55                   	push   %ebp
  801554:	89 e5                	mov    %esp,%ebp
  801556:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801559:	8b 45 08             	mov    0x8(%ebp),%eax
  80155c:	8b 40 0c             	mov    0xc(%eax),%eax
  80155f:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801564:	ba 00 00 00 00       	mov    $0x0,%edx
  801569:	b8 06 00 00 00       	mov    $0x6,%eax
  80156e:	e8 3c ff ff ff       	call   8014af <fsipc>
}
  801573:	c9                   	leave  
  801574:	c3                   	ret    

00801575 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801575:	55                   	push   %ebp
  801576:	89 e5                	mov    %esp,%ebp
  801578:	56                   	push   %esi
  801579:	53                   	push   %ebx
  80157a:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80157d:	8b 45 08             	mov    0x8(%ebp),%eax
  801580:	8b 40 0c             	mov    0xc(%eax),%eax
  801583:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801588:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80158e:	ba 00 00 00 00       	mov    $0x0,%edx
  801593:	b8 03 00 00 00       	mov    $0x3,%eax
  801598:	e8 12 ff ff ff       	call   8014af <fsipc>
  80159d:	89 c3                	mov    %eax,%ebx
  80159f:	85 c0                	test   %eax,%eax
  8015a1:	78 4b                	js     8015ee <devfile_read+0x79>
		return r;
	assert(r <= n);
  8015a3:	39 c6                	cmp    %eax,%esi
  8015a5:	73 16                	jae    8015bd <devfile_read+0x48>
  8015a7:	68 cd 23 80 00       	push   $0x8023cd
  8015ac:	68 d4 23 80 00       	push   $0x8023d4
  8015b1:	6a 7a                	push   $0x7a
  8015b3:	68 e9 23 80 00       	push   $0x8023e9
  8015b8:	e8 61 eb ff ff       	call   80011e <_panic>
	assert(r <= PGSIZE);
  8015bd:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8015c2:	7e 16                	jle    8015da <devfile_read+0x65>
  8015c4:	68 f4 23 80 00       	push   $0x8023f4
  8015c9:	68 d4 23 80 00       	push   $0x8023d4
  8015ce:	6a 7b                	push   $0x7b
  8015d0:	68 e9 23 80 00       	push   $0x8023e9
  8015d5:	e8 44 eb ff ff       	call   80011e <_panic>
	memmove(buf, &fsipcbuf, r);
  8015da:	83 ec 04             	sub    $0x4,%esp
  8015dd:	50                   	push   %eax
  8015de:	68 00 50 80 00       	push   $0x805000
  8015e3:	ff 75 0c             	pushl  0xc(%ebp)
  8015e6:	e8 bd f3 ff ff       	call   8009a8 <memmove>
	return r;
  8015eb:	83 c4 10             	add    $0x10,%esp
}
  8015ee:	89 d8                	mov    %ebx,%eax
  8015f0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015f3:	5b                   	pop    %ebx
  8015f4:	5e                   	pop    %esi
  8015f5:	5d                   	pop    %ebp
  8015f6:	c3                   	ret    

008015f7 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8015f7:	55                   	push   %ebp
  8015f8:	89 e5                	mov    %esp,%ebp
  8015fa:	53                   	push   %ebx
  8015fb:	83 ec 20             	sub    $0x20,%esp
  8015fe:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801601:	53                   	push   %ebx
  801602:	e8 7d f1 ff ff       	call   800784 <strlen>
  801607:	83 c4 10             	add    $0x10,%esp
  80160a:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80160f:	7f 63                	jg     801674 <open+0x7d>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801611:	83 ec 0c             	sub    $0xc,%esp
  801614:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801617:	50                   	push   %eax
  801618:	e8 e4 f8 ff ff       	call   800f01 <fd_alloc>
  80161d:	83 c4 10             	add    $0x10,%esp
  801620:	85 c0                	test   %eax,%eax
  801622:	78 55                	js     801679 <open+0x82>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801624:	83 ec 08             	sub    $0x8,%esp
  801627:	53                   	push   %ebx
  801628:	68 00 50 80 00       	push   $0x805000
  80162d:	e8 a9 f1 ff ff       	call   8007db <strcpy>
	fsipcbuf.open.req_omode = mode;
  801632:	8b 45 0c             	mov    0xc(%ebp),%eax
  801635:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80163a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80163d:	b8 01 00 00 00       	mov    $0x1,%eax
  801642:	e8 68 fe ff ff       	call   8014af <fsipc>
  801647:	89 c3                	mov    %eax,%ebx
  801649:	83 c4 10             	add    $0x10,%esp
  80164c:	85 c0                	test   %eax,%eax
  80164e:	79 14                	jns    801664 <open+0x6d>
		fd_close(fd, 0);
  801650:	83 ec 08             	sub    $0x8,%esp
  801653:	6a 00                	push   $0x0
  801655:	ff 75 f4             	pushl  -0xc(%ebp)
  801658:	e8 dd f9 ff ff       	call   80103a <fd_close>
		return r;
  80165d:	83 c4 10             	add    $0x10,%esp
  801660:	89 d8                	mov    %ebx,%eax
  801662:	eb 15                	jmp    801679 <open+0x82>
	}

	return fd2num(fd);
  801664:	83 ec 0c             	sub    $0xc,%esp
  801667:	ff 75 f4             	pushl  -0xc(%ebp)
  80166a:	e8 6b f8 ff ff       	call   800eda <fd2num>
  80166f:	83 c4 10             	add    $0x10,%esp
  801672:	eb 05                	jmp    801679 <open+0x82>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801674:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801679:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80167c:	c9                   	leave  
  80167d:	c3                   	ret    

0080167e <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80167e:	55                   	push   %ebp
  80167f:	89 e5                	mov    %esp,%ebp
  801681:	56                   	push   %esi
  801682:	53                   	push   %ebx
  801683:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801686:	83 ec 0c             	sub    $0xc,%esp
  801689:	ff 75 08             	pushl  0x8(%ebp)
  80168c:	e8 59 f8 ff ff       	call   800eea <fd2data>
  801691:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801693:	83 c4 08             	add    $0x8,%esp
  801696:	68 00 24 80 00       	push   $0x802400
  80169b:	53                   	push   %ebx
  80169c:	e8 3a f1 ff ff       	call   8007db <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8016a1:	8b 46 04             	mov    0x4(%esi),%eax
  8016a4:	2b 06                	sub    (%esi),%eax
  8016a6:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8016ac:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016b3:	00 00 00 
	stat->st_dev = &devpipe;
  8016b6:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8016bd:	30 80 00 
	return 0;
}
  8016c0:	b8 00 00 00 00       	mov    $0x0,%eax
  8016c5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016c8:	5b                   	pop    %ebx
  8016c9:	5e                   	pop    %esi
  8016ca:	5d                   	pop    %ebp
  8016cb:	c3                   	ret    

008016cc <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8016cc:	55                   	push   %ebp
  8016cd:	89 e5                	mov    %esp,%ebp
  8016cf:	53                   	push   %ebx
  8016d0:	83 ec 0c             	sub    $0xc,%esp
  8016d3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8016d6:	53                   	push   %ebx
  8016d7:	6a 00                	push   $0x0
  8016d9:	e8 f2 f5 ff ff       	call   800cd0 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8016de:	89 1c 24             	mov    %ebx,(%esp)
  8016e1:	e8 04 f8 ff ff       	call   800eea <fd2data>
  8016e6:	83 c4 08             	add    $0x8,%esp
  8016e9:	50                   	push   %eax
  8016ea:	6a 00                	push   $0x0
  8016ec:	e8 df f5 ff ff       	call   800cd0 <sys_page_unmap>
}
  8016f1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016f4:	c9                   	leave  
  8016f5:	c3                   	ret    

008016f6 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8016f6:	55                   	push   %ebp
  8016f7:	89 e5                	mov    %esp,%ebp
  8016f9:	57                   	push   %edi
  8016fa:	56                   	push   %esi
  8016fb:	53                   	push   %ebx
  8016fc:	83 ec 1c             	sub    $0x1c,%esp
  8016ff:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801702:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801704:	a1 04 40 80 00       	mov    0x804004,%eax
  801709:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  80170c:	83 ec 0c             	sub    $0xc,%esp
  80170f:	ff 75 e0             	pushl  -0x20(%ebp)
  801712:	e8 8a 05 00 00       	call   801ca1 <pageref>
  801717:	89 c3                	mov    %eax,%ebx
  801719:	89 3c 24             	mov    %edi,(%esp)
  80171c:	e8 80 05 00 00       	call   801ca1 <pageref>
  801721:	83 c4 10             	add    $0x10,%esp
  801724:	39 c3                	cmp    %eax,%ebx
  801726:	0f 94 c1             	sete   %cl
  801729:	0f b6 c9             	movzbl %cl,%ecx
  80172c:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  80172f:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801735:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801738:	39 ce                	cmp    %ecx,%esi
  80173a:	74 1b                	je     801757 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  80173c:	39 c3                	cmp    %eax,%ebx
  80173e:	75 c4                	jne    801704 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801740:	8b 42 58             	mov    0x58(%edx),%eax
  801743:	ff 75 e4             	pushl  -0x1c(%ebp)
  801746:	50                   	push   %eax
  801747:	56                   	push   %esi
  801748:	68 07 24 80 00       	push   $0x802407
  80174d:	e8 a4 ea ff ff       	call   8001f6 <cprintf>
  801752:	83 c4 10             	add    $0x10,%esp
  801755:	eb ad                	jmp    801704 <_pipeisclosed+0xe>
	}
}
  801757:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80175a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80175d:	5b                   	pop    %ebx
  80175e:	5e                   	pop    %esi
  80175f:	5f                   	pop    %edi
  801760:	5d                   	pop    %ebp
  801761:	c3                   	ret    

00801762 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801762:	55                   	push   %ebp
  801763:	89 e5                	mov    %esp,%ebp
  801765:	57                   	push   %edi
  801766:	56                   	push   %esi
  801767:	53                   	push   %ebx
  801768:	83 ec 18             	sub    $0x18,%esp
  80176b:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80176e:	56                   	push   %esi
  80176f:	e8 76 f7 ff ff       	call   800eea <fd2data>
  801774:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801776:	83 c4 10             	add    $0x10,%esp
  801779:	bf 00 00 00 00       	mov    $0x0,%edi
  80177e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801782:	75 42                	jne    8017c6 <devpipe_write+0x64>
  801784:	eb 4e                	jmp    8017d4 <devpipe_write+0x72>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801786:	89 da                	mov    %ebx,%edx
  801788:	89 f0                	mov    %esi,%eax
  80178a:	e8 67 ff ff ff       	call   8016f6 <_pipeisclosed>
  80178f:	85 c0                	test   %eax,%eax
  801791:	75 46                	jne    8017d9 <devpipe_write+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801793:	e8 94 f4 ff ff       	call   800c2c <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801798:	8b 53 04             	mov    0x4(%ebx),%edx
  80179b:	8b 03                	mov    (%ebx),%eax
  80179d:	83 c0 20             	add    $0x20,%eax
  8017a0:	39 c2                	cmp    %eax,%edx
  8017a2:	73 e2                	jae    801786 <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8017a4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017a7:	8a 0c 38             	mov    (%eax,%edi,1),%cl
  8017aa:	89 d0                	mov    %edx,%eax
  8017ac:	25 1f 00 00 80       	and    $0x8000001f,%eax
  8017b1:	79 05                	jns    8017b8 <devpipe_write+0x56>
  8017b3:	48                   	dec    %eax
  8017b4:	83 c8 e0             	or     $0xffffffe0,%eax
  8017b7:	40                   	inc    %eax
  8017b8:	88 4c 03 08          	mov    %cl,0x8(%ebx,%eax,1)
		p->p_wpos++;
  8017bc:	42                   	inc    %edx
  8017bd:	89 53 04             	mov    %edx,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8017c0:	47                   	inc    %edi
  8017c1:	39 7d 10             	cmp    %edi,0x10(%ebp)
  8017c4:	74 0e                	je     8017d4 <devpipe_write+0x72>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8017c6:	8b 53 04             	mov    0x4(%ebx),%edx
  8017c9:	8b 03                	mov    (%ebx),%eax
  8017cb:	83 c0 20             	add    $0x20,%eax
  8017ce:	39 c2                	cmp    %eax,%edx
  8017d0:	73 b4                	jae    801786 <devpipe_write+0x24>
  8017d2:	eb d0                	jmp    8017a4 <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8017d4:	8b 45 10             	mov    0x10(%ebp),%eax
  8017d7:	eb 05                	jmp    8017de <devpipe_write+0x7c>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8017d9:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8017de:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017e1:	5b                   	pop    %ebx
  8017e2:	5e                   	pop    %esi
  8017e3:	5f                   	pop    %edi
  8017e4:	5d                   	pop    %ebp
  8017e5:	c3                   	ret    

008017e6 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8017e6:	55                   	push   %ebp
  8017e7:	89 e5                	mov    %esp,%ebp
  8017e9:	57                   	push   %edi
  8017ea:	56                   	push   %esi
  8017eb:	53                   	push   %ebx
  8017ec:	83 ec 18             	sub    $0x18,%esp
  8017ef:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8017f2:	57                   	push   %edi
  8017f3:	e8 f2 f6 ff ff       	call   800eea <fd2data>
  8017f8:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8017fa:	83 c4 10             	add    $0x10,%esp
  8017fd:	be 00 00 00 00       	mov    $0x0,%esi
  801802:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801806:	75 3d                	jne    801845 <devpipe_read+0x5f>
  801808:	eb 48                	jmp    801852 <devpipe_read+0x6c>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  80180a:	89 f0                	mov    %esi,%eax
  80180c:	eb 4e                	jmp    80185c <devpipe_read+0x76>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80180e:	89 da                	mov    %ebx,%edx
  801810:	89 f8                	mov    %edi,%eax
  801812:	e8 df fe ff ff       	call   8016f6 <_pipeisclosed>
  801817:	85 c0                	test   %eax,%eax
  801819:	75 3c                	jne    801857 <devpipe_read+0x71>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80181b:	e8 0c f4 ff ff       	call   800c2c <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801820:	8b 03                	mov    (%ebx),%eax
  801822:	3b 43 04             	cmp    0x4(%ebx),%eax
  801825:	74 e7                	je     80180e <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801827:	25 1f 00 00 80       	and    $0x8000001f,%eax
  80182c:	79 05                	jns    801833 <devpipe_read+0x4d>
  80182e:	48                   	dec    %eax
  80182f:	83 c8 e0             	or     $0xffffffe0,%eax
  801832:	40                   	inc    %eax
  801833:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801837:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80183a:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  80183d:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80183f:	46                   	inc    %esi
  801840:	39 75 10             	cmp    %esi,0x10(%ebp)
  801843:	74 0d                	je     801852 <devpipe_read+0x6c>
		while (p->p_rpos == p->p_wpos) {
  801845:	8b 03                	mov    (%ebx),%eax
  801847:	3b 43 04             	cmp    0x4(%ebx),%eax
  80184a:	75 db                	jne    801827 <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80184c:	85 f6                	test   %esi,%esi
  80184e:	75 ba                	jne    80180a <devpipe_read+0x24>
  801850:	eb bc                	jmp    80180e <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801852:	8b 45 10             	mov    0x10(%ebp),%eax
  801855:	eb 05                	jmp    80185c <devpipe_read+0x76>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801857:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80185c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80185f:	5b                   	pop    %ebx
  801860:	5e                   	pop    %esi
  801861:	5f                   	pop    %edi
  801862:	5d                   	pop    %ebp
  801863:	c3                   	ret    

00801864 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801864:	55                   	push   %ebp
  801865:	89 e5                	mov    %esp,%ebp
  801867:	56                   	push   %esi
  801868:	53                   	push   %ebx
  801869:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80186c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80186f:	50                   	push   %eax
  801870:	e8 8c f6 ff ff       	call   800f01 <fd_alloc>
  801875:	83 c4 10             	add    $0x10,%esp
  801878:	85 c0                	test   %eax,%eax
  80187a:	0f 88 2a 01 00 00    	js     8019aa <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801880:	83 ec 04             	sub    $0x4,%esp
  801883:	68 07 04 00 00       	push   $0x407
  801888:	ff 75 f4             	pushl  -0xc(%ebp)
  80188b:	6a 00                	push   $0x0
  80188d:	e8 b9 f3 ff ff       	call   800c4b <sys_page_alloc>
  801892:	83 c4 10             	add    $0x10,%esp
  801895:	85 c0                	test   %eax,%eax
  801897:	0f 88 0d 01 00 00    	js     8019aa <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80189d:	83 ec 0c             	sub    $0xc,%esp
  8018a0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018a3:	50                   	push   %eax
  8018a4:	e8 58 f6 ff ff       	call   800f01 <fd_alloc>
  8018a9:	89 c3                	mov    %eax,%ebx
  8018ab:	83 c4 10             	add    $0x10,%esp
  8018ae:	85 c0                	test   %eax,%eax
  8018b0:	0f 88 e2 00 00 00    	js     801998 <pipe+0x134>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018b6:	83 ec 04             	sub    $0x4,%esp
  8018b9:	68 07 04 00 00       	push   $0x407
  8018be:	ff 75 f0             	pushl  -0x10(%ebp)
  8018c1:	6a 00                	push   $0x0
  8018c3:	e8 83 f3 ff ff       	call   800c4b <sys_page_alloc>
  8018c8:	89 c3                	mov    %eax,%ebx
  8018ca:	83 c4 10             	add    $0x10,%esp
  8018cd:	85 c0                	test   %eax,%eax
  8018cf:	0f 88 c3 00 00 00    	js     801998 <pipe+0x134>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8018d5:	83 ec 0c             	sub    $0xc,%esp
  8018d8:	ff 75 f4             	pushl  -0xc(%ebp)
  8018db:	e8 0a f6 ff ff       	call   800eea <fd2data>
  8018e0:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018e2:	83 c4 0c             	add    $0xc,%esp
  8018e5:	68 07 04 00 00       	push   $0x407
  8018ea:	50                   	push   %eax
  8018eb:	6a 00                	push   $0x0
  8018ed:	e8 59 f3 ff ff       	call   800c4b <sys_page_alloc>
  8018f2:	89 c3                	mov    %eax,%ebx
  8018f4:	83 c4 10             	add    $0x10,%esp
  8018f7:	85 c0                	test   %eax,%eax
  8018f9:	0f 88 89 00 00 00    	js     801988 <pipe+0x124>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018ff:	83 ec 0c             	sub    $0xc,%esp
  801902:	ff 75 f0             	pushl  -0x10(%ebp)
  801905:	e8 e0 f5 ff ff       	call   800eea <fd2data>
  80190a:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801911:	50                   	push   %eax
  801912:	6a 00                	push   $0x0
  801914:	56                   	push   %esi
  801915:	6a 00                	push   $0x0
  801917:	e8 72 f3 ff ff       	call   800c8e <sys_page_map>
  80191c:	89 c3                	mov    %eax,%ebx
  80191e:	83 c4 20             	add    $0x20,%esp
  801921:	85 c0                	test   %eax,%eax
  801923:	78 55                	js     80197a <pipe+0x116>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801925:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80192b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80192e:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801930:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801933:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80193a:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801940:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801943:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801945:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801948:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80194f:	83 ec 0c             	sub    $0xc,%esp
  801952:	ff 75 f4             	pushl  -0xc(%ebp)
  801955:	e8 80 f5 ff ff       	call   800eda <fd2num>
  80195a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80195d:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80195f:	83 c4 04             	add    $0x4,%esp
  801962:	ff 75 f0             	pushl  -0x10(%ebp)
  801965:	e8 70 f5 ff ff       	call   800eda <fd2num>
  80196a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80196d:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801970:	83 c4 10             	add    $0x10,%esp
  801973:	b8 00 00 00 00       	mov    $0x0,%eax
  801978:	eb 30                	jmp    8019aa <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  80197a:	83 ec 08             	sub    $0x8,%esp
  80197d:	56                   	push   %esi
  80197e:	6a 00                	push   $0x0
  801980:	e8 4b f3 ff ff       	call   800cd0 <sys_page_unmap>
  801985:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801988:	83 ec 08             	sub    $0x8,%esp
  80198b:	ff 75 f0             	pushl  -0x10(%ebp)
  80198e:	6a 00                	push   $0x0
  801990:	e8 3b f3 ff ff       	call   800cd0 <sys_page_unmap>
  801995:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801998:	83 ec 08             	sub    $0x8,%esp
  80199b:	ff 75 f4             	pushl  -0xc(%ebp)
  80199e:	6a 00                	push   $0x0
  8019a0:	e8 2b f3 ff ff       	call   800cd0 <sys_page_unmap>
  8019a5:	83 c4 10             	add    $0x10,%esp
  8019a8:	89 d8                	mov    %ebx,%eax
    err:
	return r;
}
  8019aa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019ad:	5b                   	pop    %ebx
  8019ae:	5e                   	pop    %esi
  8019af:	5d                   	pop    %ebp
  8019b0:	c3                   	ret    

008019b1 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8019b1:	55                   	push   %ebp
  8019b2:	89 e5                	mov    %esp,%ebp
  8019b4:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8019b7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019ba:	50                   	push   %eax
  8019bb:	ff 75 08             	pushl  0x8(%ebp)
  8019be:	e8 b2 f5 ff ff       	call   800f75 <fd_lookup>
  8019c3:	83 c4 10             	add    $0x10,%esp
  8019c6:	85 c0                	test   %eax,%eax
  8019c8:	78 18                	js     8019e2 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8019ca:	83 ec 0c             	sub    $0xc,%esp
  8019cd:	ff 75 f4             	pushl  -0xc(%ebp)
  8019d0:	e8 15 f5 ff ff       	call   800eea <fd2data>
	return _pipeisclosed(fd, p);
  8019d5:	89 c2                	mov    %eax,%edx
  8019d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019da:	e8 17 fd ff ff       	call   8016f6 <_pipeisclosed>
  8019df:	83 c4 10             	add    $0x10,%esp
}
  8019e2:	c9                   	leave  
  8019e3:	c3                   	ret    

008019e4 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8019e4:	55                   	push   %ebp
  8019e5:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8019e7:	b8 00 00 00 00       	mov    $0x0,%eax
  8019ec:	5d                   	pop    %ebp
  8019ed:	c3                   	ret    

008019ee <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8019ee:	55                   	push   %ebp
  8019ef:	89 e5                	mov    %esp,%ebp
  8019f1:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8019f4:	68 1f 24 80 00       	push   $0x80241f
  8019f9:	ff 75 0c             	pushl  0xc(%ebp)
  8019fc:	e8 da ed ff ff       	call   8007db <strcpy>
	return 0;
}
  801a01:	b8 00 00 00 00       	mov    $0x0,%eax
  801a06:	c9                   	leave  
  801a07:	c3                   	ret    

00801a08 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a08:	55                   	push   %ebp
  801a09:	89 e5                	mov    %esp,%ebp
  801a0b:	57                   	push   %edi
  801a0c:	56                   	push   %esi
  801a0d:	53                   	push   %ebx
  801a0e:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801a14:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801a18:	74 45                	je     801a5f <devcons_write+0x57>
  801a1a:	b8 00 00 00 00       	mov    $0x0,%eax
  801a1f:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801a24:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801a2a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801a2d:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  801a2f:	83 fb 7f             	cmp    $0x7f,%ebx
  801a32:	76 05                	jbe    801a39 <devcons_write+0x31>
			m = sizeof(buf) - 1;
  801a34:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801a39:	83 ec 04             	sub    $0x4,%esp
  801a3c:	53                   	push   %ebx
  801a3d:	03 45 0c             	add    0xc(%ebp),%eax
  801a40:	50                   	push   %eax
  801a41:	57                   	push   %edi
  801a42:	e8 61 ef ff ff       	call   8009a8 <memmove>
		sys_cputs(buf, m);
  801a47:	83 c4 08             	add    $0x8,%esp
  801a4a:	53                   	push   %ebx
  801a4b:	57                   	push   %edi
  801a4c:	e8 3e f1 ff ff       	call   800b8f <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801a51:	01 de                	add    %ebx,%esi
  801a53:	89 f0                	mov    %esi,%eax
  801a55:	83 c4 10             	add    $0x10,%esp
  801a58:	3b 75 10             	cmp    0x10(%ebp),%esi
  801a5b:	72 cd                	jb     801a2a <devcons_write+0x22>
  801a5d:	eb 05                	jmp    801a64 <devcons_write+0x5c>
  801a5f:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801a64:	89 f0                	mov    %esi,%eax
  801a66:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a69:	5b                   	pop    %ebx
  801a6a:	5e                   	pop    %esi
  801a6b:	5f                   	pop    %edi
  801a6c:	5d                   	pop    %ebp
  801a6d:	c3                   	ret    

00801a6e <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801a6e:	55                   	push   %ebp
  801a6f:	89 e5                	mov    %esp,%ebp
  801a71:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801a74:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801a78:	75 07                	jne    801a81 <devcons_read+0x13>
  801a7a:	eb 23                	jmp    801a9f <devcons_read+0x31>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801a7c:	e8 ab f1 ff ff       	call   800c2c <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801a81:	e8 27 f1 ff ff       	call   800bad <sys_cgetc>
  801a86:	85 c0                	test   %eax,%eax
  801a88:	74 f2                	je     801a7c <devcons_read+0xe>
		sys_yield();
	if (c < 0)
  801a8a:	85 c0                	test   %eax,%eax
  801a8c:	78 1d                	js     801aab <devcons_read+0x3d>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801a8e:	83 f8 04             	cmp    $0x4,%eax
  801a91:	74 13                	je     801aa6 <devcons_read+0x38>
		return 0;
	*(char*)vbuf = c;
  801a93:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a96:	88 02                	mov    %al,(%edx)
	return 1;
  801a98:	b8 01 00 00 00       	mov    $0x1,%eax
  801a9d:	eb 0c                	jmp    801aab <devcons_read+0x3d>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801a9f:	b8 00 00 00 00       	mov    $0x0,%eax
  801aa4:	eb 05                	jmp    801aab <devcons_read+0x3d>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801aa6:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801aab:	c9                   	leave  
  801aac:	c3                   	ret    

00801aad <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801aad:	55                   	push   %ebp
  801aae:	89 e5                	mov    %esp,%ebp
  801ab0:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801ab3:	8b 45 08             	mov    0x8(%ebp),%eax
  801ab6:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801ab9:	6a 01                	push   $0x1
  801abb:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801abe:	50                   	push   %eax
  801abf:	e8 cb f0 ff ff       	call   800b8f <sys_cputs>
}
  801ac4:	83 c4 10             	add    $0x10,%esp
  801ac7:	c9                   	leave  
  801ac8:	c3                   	ret    

00801ac9 <getchar>:

int
getchar(void)
{
  801ac9:	55                   	push   %ebp
  801aca:	89 e5                	mov    %esp,%ebp
  801acc:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801acf:	6a 01                	push   $0x1
  801ad1:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ad4:	50                   	push   %eax
  801ad5:	6a 00                	push   $0x0
  801ad7:	e8 1a f7 ff ff       	call   8011f6 <read>
	if (r < 0)
  801adc:	83 c4 10             	add    $0x10,%esp
  801adf:	85 c0                	test   %eax,%eax
  801ae1:	78 0f                	js     801af2 <getchar+0x29>
		return r;
	if (r < 1)
  801ae3:	85 c0                	test   %eax,%eax
  801ae5:	7e 06                	jle    801aed <getchar+0x24>
		return -E_EOF;
	return c;
  801ae7:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801aeb:	eb 05                	jmp    801af2 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801aed:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801af2:	c9                   	leave  
  801af3:	c3                   	ret    

00801af4 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801af4:	55                   	push   %ebp
  801af5:	89 e5                	mov    %esp,%ebp
  801af7:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801afa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801afd:	50                   	push   %eax
  801afe:	ff 75 08             	pushl  0x8(%ebp)
  801b01:	e8 6f f4 ff ff       	call   800f75 <fd_lookup>
  801b06:	83 c4 10             	add    $0x10,%esp
  801b09:	85 c0                	test   %eax,%eax
  801b0b:	78 11                	js     801b1e <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801b0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b10:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801b16:	39 10                	cmp    %edx,(%eax)
  801b18:	0f 94 c0             	sete   %al
  801b1b:	0f b6 c0             	movzbl %al,%eax
}
  801b1e:	c9                   	leave  
  801b1f:	c3                   	ret    

00801b20 <opencons>:

int
opencons(void)
{
  801b20:	55                   	push   %ebp
  801b21:	89 e5                	mov    %esp,%ebp
  801b23:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801b26:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b29:	50                   	push   %eax
  801b2a:	e8 d2 f3 ff ff       	call   800f01 <fd_alloc>
  801b2f:	83 c4 10             	add    $0x10,%esp
  801b32:	85 c0                	test   %eax,%eax
  801b34:	78 3a                	js     801b70 <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801b36:	83 ec 04             	sub    $0x4,%esp
  801b39:	68 07 04 00 00       	push   $0x407
  801b3e:	ff 75 f4             	pushl  -0xc(%ebp)
  801b41:	6a 00                	push   $0x0
  801b43:	e8 03 f1 ff ff       	call   800c4b <sys_page_alloc>
  801b48:	83 c4 10             	add    $0x10,%esp
  801b4b:	85 c0                	test   %eax,%eax
  801b4d:	78 21                	js     801b70 <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801b4f:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801b55:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b58:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801b5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b5d:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801b64:	83 ec 0c             	sub    $0xc,%esp
  801b67:	50                   	push   %eax
  801b68:	e8 6d f3 ff ff       	call   800eda <fd2num>
  801b6d:	83 c4 10             	add    $0x10,%esp
}
  801b70:	c9                   	leave  
  801b71:	c3                   	ret    

00801b72 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801b72:	55                   	push   %ebp
  801b73:	89 e5                	mov    %esp,%ebp
  801b75:	56                   	push   %esi
  801b76:	53                   	push   %ebx
  801b77:	8b 75 08             	mov    0x8(%ebp),%esi
  801b7a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b7d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");
	int r;
    if (pg != NULL) {
  801b80:	85 c0                	test   %eax,%eax
  801b82:	74 0e                	je     801b92 <ipc_recv+0x20>
        r = sys_ipc_recv(pg);
  801b84:	83 ec 0c             	sub    $0xc,%esp
  801b87:	50                   	push   %eax
  801b88:	e8 6e f2 ff ff       	call   800dfb <sys_ipc_recv>
  801b8d:	83 c4 10             	add    $0x10,%esp
  801b90:	eb 10                	jmp    801ba2 <ipc_recv+0x30>
    } else {
        r = sys_ipc_recv((void *) UTOP);
  801b92:	83 ec 0c             	sub    $0xc,%esp
  801b95:	68 00 00 c0 ee       	push   $0xeec00000
  801b9a:	e8 5c f2 ff ff       	call   800dfb <sys_ipc_recv>
  801b9f:	83 c4 10             	add    $0x10,%esp
    }
    if (r < 0) {
  801ba2:	85 c0                	test   %eax,%eax
  801ba4:	79 16                	jns    801bbc <ipc_recv+0x4a>
        // failed
        if (from_env_store != NULL) *from_env_store = 0;
  801ba6:	85 f6                	test   %esi,%esi
  801ba8:	74 06                	je     801bb0 <ipc_recv+0x3e>
  801baa:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        if (perm_store != NULL) *perm_store = 0;
  801bb0:	85 db                	test   %ebx,%ebx
  801bb2:	74 2c                	je     801be0 <ipc_recv+0x6e>
  801bb4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801bba:	eb 24                	jmp    801be0 <ipc_recv+0x6e>
        return r;
    } else {
        if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801bbc:	85 f6                	test   %esi,%esi
  801bbe:	74 0a                	je     801bca <ipc_recv+0x58>
  801bc0:	a1 04 40 80 00       	mov    0x804004,%eax
  801bc5:	8b 40 74             	mov    0x74(%eax),%eax
  801bc8:	89 06                	mov    %eax,(%esi)
        if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801bca:	85 db                	test   %ebx,%ebx
  801bcc:	74 0a                	je     801bd8 <ipc_recv+0x66>
  801bce:	a1 04 40 80 00       	mov    0x804004,%eax
  801bd3:	8b 40 78             	mov    0x78(%eax),%eax
  801bd6:	89 03                	mov    %eax,(%ebx)
        return thisenv->env_ipc_value;
  801bd8:	a1 04 40 80 00       	mov    0x804004,%eax
  801bdd:	8b 40 70             	mov    0x70(%eax),%eax
    }
 
	return 0;
}
  801be0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801be3:	5b                   	pop    %ebx
  801be4:	5e                   	pop    %esi
  801be5:	5d                   	pop    %ebp
  801be6:	c3                   	ret    

00801be7 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801be7:	55                   	push   %ebp
  801be8:	89 e5                	mov    %esp,%ebp
  801bea:	57                   	push   %edi
  801beb:	56                   	push   %esi
  801bec:	53                   	push   %ebx
  801bed:	83 ec 0c             	sub    $0xc,%esp
  801bf0:	8b 75 10             	mov    0x10(%ebp),%esi
  801bf3:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");
	int r;
    if (pg == NULL) pg = (void *)UTOP;
  801bf6:	85 f6                	test   %esi,%esi
  801bf8:	75 05                	jne    801bff <ipc_send+0x18>
  801bfa:	be 00 00 c0 ee       	mov    $0xeec00000,%esi
    do {
        r = sys_ipc_try_send(to_env, val, pg, perm);
  801bff:	57                   	push   %edi
  801c00:	56                   	push   %esi
  801c01:	ff 75 0c             	pushl  0xc(%ebp)
  801c04:	ff 75 08             	pushl  0x8(%ebp)
  801c07:	e8 cc f1 ff ff       	call   800dd8 <sys_ipc_try_send>
  801c0c:	89 c3                	mov    %eax,%ebx
        if (r < 0 && r != -E_IPC_NOT_RECV) panic("ipc send failed: %e", r);
  801c0e:	83 c4 10             	add    $0x10,%esp
  801c11:	85 c0                	test   %eax,%eax
  801c13:	79 17                	jns    801c2c <ipc_send+0x45>
  801c15:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801c18:	74 1d                	je     801c37 <ipc_send+0x50>
  801c1a:	50                   	push   %eax
  801c1b:	68 2b 24 80 00       	push   $0x80242b
  801c20:	6a 40                	push   $0x40
  801c22:	68 3f 24 80 00       	push   $0x80243f
  801c27:	e8 f2 e4 ff ff       	call   80011e <_panic>
        sys_yield();
  801c2c:	e8 fb ef ff ff       	call   800c2c <sys_yield>
    } while (r != 0);
  801c31:	85 db                	test   %ebx,%ebx
  801c33:	75 ca                	jne    801bff <ipc_send+0x18>
  801c35:	eb 07                	jmp    801c3e <ipc_send+0x57>
	int r;
    if (pg == NULL) pg = (void *)UTOP;
    do {
        r = sys_ipc_try_send(to_env, val, pg, perm);
        if (r < 0 && r != -E_IPC_NOT_RECV) panic("ipc send failed: %e", r);
        sys_yield();
  801c37:	e8 f0 ef ff ff       	call   800c2c <sys_yield>
  801c3c:	eb c1                	jmp    801bff <ipc_send+0x18>
    } while (r != 0);
}
  801c3e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c41:	5b                   	pop    %ebx
  801c42:	5e                   	pop    %esi
  801c43:	5f                   	pop    %edi
  801c44:	5d                   	pop    %ebp
  801c45:	c3                   	ret    

00801c46 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801c46:	55                   	push   %ebp
  801c47:	89 e5                	mov    %esp,%ebp
  801c49:	53                   	push   %ebx
  801c4a:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801c4d:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  801c52:	39 c1                	cmp    %eax,%ecx
  801c54:	74 21                	je     801c77 <ipc_find_env+0x31>
  801c56:	ba 01 00 00 00       	mov    $0x1,%edx
  801c5b:	8d 1c 95 00 00 00 00 	lea    0x0(,%edx,4),%ebx
  801c62:	89 d0                	mov    %edx,%eax
  801c64:	c1 e0 07             	shl    $0x7,%eax
  801c67:	29 d8                	sub    %ebx,%eax
  801c69:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801c6e:	8b 40 50             	mov    0x50(%eax),%eax
  801c71:	39 c8                	cmp    %ecx,%eax
  801c73:	75 1b                	jne    801c90 <ipc_find_env+0x4a>
  801c75:	eb 05                	jmp    801c7c <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801c77:	ba 00 00 00 00       	mov    $0x0,%edx
		if (envs[i].env_type == type)
			return envs[i].env_id;
  801c7c:	8d 04 95 00 00 00 00 	lea    0x0(,%edx,4),%eax
  801c83:	c1 e2 07             	shl    $0x7,%edx
  801c86:	29 c2                	sub    %eax,%edx
  801c88:	8b 82 48 00 c0 ee    	mov    -0x113fffb8(%edx),%eax
  801c8e:	eb 0e                	jmp    801c9e <ipc_find_env+0x58>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801c90:	42                   	inc    %edx
  801c91:	81 fa 00 04 00 00    	cmp    $0x400,%edx
  801c97:	75 c2                	jne    801c5b <ipc_find_env+0x15>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801c99:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c9e:	5b                   	pop    %ebx
  801c9f:	5d                   	pop    %ebp
  801ca0:	c3                   	ret    

00801ca1 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801ca1:	55                   	push   %ebp
  801ca2:	89 e5                	mov    %esp,%ebp
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ca4:	8b 45 08             	mov    0x8(%ebp),%eax
  801ca7:	c1 e8 16             	shr    $0x16,%eax
  801caa:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801cb1:	a8 01                	test   $0x1,%al
  801cb3:	74 21                	je     801cd6 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801cb5:	8b 45 08             	mov    0x8(%ebp),%eax
  801cb8:	c1 e8 0c             	shr    $0xc,%eax
  801cbb:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801cc2:	a8 01                	test   $0x1,%al
  801cc4:	74 17                	je     801cdd <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801cc6:	c1 e8 0c             	shr    $0xc,%eax
  801cc9:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801cd0:	ef 
  801cd1:	0f b7 c0             	movzwl %ax,%eax
  801cd4:	eb 0c                	jmp    801ce2 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801cd6:	b8 00 00 00 00       	mov    $0x0,%eax
  801cdb:	eb 05                	jmp    801ce2 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801cdd:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801ce2:	5d                   	pop    %ebp
  801ce3:	c3                   	ret    

00801ce4 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801ce4:	55                   	push   %ebp
  801ce5:	57                   	push   %edi
  801ce6:	56                   	push   %esi
  801ce7:	53                   	push   %ebx
  801ce8:	83 ec 1c             	sub    $0x1c,%esp
  801ceb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801cef:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801cf3:	8b 7c 24 38          	mov    0x38(%esp),%edi
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801cf7:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801cfb:	89 ca                	mov    %ecx,%edx
  const DWunion dd = {.ll = d};
  801cfd:	89 f8                	mov    %edi,%eax
  801cff:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801d03:	85 f6                	test   %esi,%esi
  801d05:	75 2d                	jne    801d34 <__udivdi3+0x50>
    {
      if (d0 > n1)
  801d07:	39 cf                	cmp    %ecx,%edi
  801d09:	77 65                	ja     801d70 <__udivdi3+0x8c>
  801d0b:	89 fd                	mov    %edi,%ebp
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801d0d:	85 ff                	test   %edi,%edi
  801d0f:	75 0b                	jne    801d1c <__udivdi3+0x38>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801d11:	b8 01 00 00 00       	mov    $0x1,%eax
  801d16:	31 d2                	xor    %edx,%edx
  801d18:	f7 f7                	div    %edi
  801d1a:	89 c5                	mov    %eax,%ebp

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801d1c:	31 d2                	xor    %edx,%edx
  801d1e:	89 c8                	mov    %ecx,%eax
  801d20:	f7 f5                	div    %ebp
  801d22:	89 c1                	mov    %eax,%ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801d24:	89 d8                	mov    %ebx,%eax
  801d26:	f7 f5                	div    %ebp
  801d28:	89 cf                	mov    %ecx,%edi
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801d2a:	89 fa                	mov    %edi,%edx
  801d2c:	83 c4 1c             	add    $0x1c,%esp
  801d2f:	5b                   	pop    %ebx
  801d30:	5e                   	pop    %esi
  801d31:	5f                   	pop    %edi
  801d32:	5d                   	pop    %ebp
  801d33:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801d34:	39 ce                	cmp    %ecx,%esi
  801d36:	77 28                	ja     801d60 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801d38:	0f bd fe             	bsr    %esi,%edi
	  if (bm == 0)
  801d3b:	83 f7 1f             	xor    $0x1f,%edi
  801d3e:	75 40                	jne    801d80 <__udivdi3+0x9c>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801d40:	39 ce                	cmp    %ecx,%esi
  801d42:	72 0a                	jb     801d4e <__udivdi3+0x6a>
  801d44:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801d48:	0f 87 9e 00 00 00    	ja     801dec <__udivdi3+0x108>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801d4e:	b8 01 00 00 00       	mov    $0x1,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801d53:	89 fa                	mov    %edi,%edx
  801d55:	83 c4 1c             	add    $0x1c,%esp
  801d58:	5b                   	pop    %ebx
  801d59:	5e                   	pop    %esi
  801d5a:	5f                   	pop    %edi
  801d5b:	5d                   	pop    %ebp
  801d5c:	c3                   	ret    
  801d5d:	8d 76 00             	lea    0x0(%esi),%esi
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801d60:	31 ff                	xor    %edi,%edi
  801d62:	31 c0                	xor    %eax,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801d64:	89 fa                	mov    %edi,%edx
  801d66:	83 c4 1c             	add    $0x1c,%esp
  801d69:	5b                   	pop    %ebx
  801d6a:	5e                   	pop    %esi
  801d6b:	5f                   	pop    %edi
  801d6c:	5d                   	pop    %ebp
  801d6d:	c3                   	ret    
  801d6e:	66 90                	xchg   %ax,%ax
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801d70:	89 d8                	mov    %ebx,%eax
  801d72:	f7 f7                	div    %edi
  801d74:	31 ff                	xor    %edi,%edi
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801d76:	89 fa                	mov    %edi,%edx
  801d78:	83 c4 1c             	add    $0x1c,%esp
  801d7b:	5b                   	pop    %ebx
  801d7c:	5e                   	pop    %esi
  801d7d:	5f                   	pop    %edi
  801d7e:	5d                   	pop    %ebp
  801d7f:	c3                   	ret    
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801d80:	bd 20 00 00 00       	mov    $0x20,%ebp
  801d85:	89 eb                	mov    %ebp,%ebx
  801d87:	29 fb                	sub    %edi,%ebx

	      d1 = (d1 << bm) | (d0 >> b);
  801d89:	89 f9                	mov    %edi,%ecx
  801d8b:	d3 e6                	shl    %cl,%esi
  801d8d:	89 c5                	mov    %eax,%ebp
  801d8f:	88 d9                	mov    %bl,%cl
  801d91:	d3 ed                	shr    %cl,%ebp
  801d93:	89 e9                	mov    %ebp,%ecx
  801d95:	09 f1                	or     %esi,%ecx
  801d97:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
	      d0 = d0 << bm;
  801d9b:	89 f9                	mov    %edi,%ecx
  801d9d:	d3 e0                	shl    %cl,%eax
  801d9f:	89 c5                	mov    %eax,%ebp
	      n2 = n1 >> b;
  801da1:	89 d6                	mov    %edx,%esi
  801da3:	88 d9                	mov    %bl,%cl
  801da5:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
  801da7:	89 f9                	mov    %edi,%ecx
  801da9:	d3 e2                	shl    %cl,%edx
  801dab:	8b 44 24 08          	mov    0x8(%esp),%eax
  801daf:	88 d9                	mov    %bl,%cl
  801db1:	d3 e8                	shr    %cl,%eax
  801db3:	09 c2                	or     %eax,%edx
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801db5:	89 d0                	mov    %edx,%eax
  801db7:	89 f2                	mov    %esi,%edx
  801db9:	f7 74 24 0c          	divl   0xc(%esp)
  801dbd:	89 d6                	mov    %edx,%esi
  801dbf:	89 c3                	mov    %eax,%ebx
	      umul_ppmm (m1, m0, q0, d0);
  801dc1:	f7 e5                	mul    %ebp

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801dc3:	39 d6                	cmp    %edx,%esi
  801dc5:	72 19                	jb     801de0 <__udivdi3+0xfc>
  801dc7:	74 0b                	je     801dd4 <__udivdi3+0xf0>
  801dc9:	89 d8                	mov    %ebx,%eax
  801dcb:	31 ff                	xor    %edi,%edi
  801dcd:	e9 58 ff ff ff       	jmp    801d2a <__udivdi3+0x46>
  801dd2:	66 90                	xchg   %ax,%ax
  801dd4:	8b 54 24 08          	mov    0x8(%esp),%edx
  801dd8:	89 f9                	mov    %edi,%ecx
  801dda:	d3 e2                	shl    %cl,%edx
  801ddc:	39 c2                	cmp    %eax,%edx
  801dde:	73 e9                	jae    801dc9 <__udivdi3+0xe5>
  801de0:	8d 43 ff             	lea    -0x1(%ebx),%eax
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801de3:	31 ff                	xor    %edi,%edi
  801de5:	e9 40 ff ff ff       	jmp    801d2a <__udivdi3+0x46>
  801dea:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801dec:	31 c0                	xor    %eax,%eax
  801dee:	e9 37 ff ff ff       	jmp    801d2a <__udivdi3+0x46>
  801df3:	90                   	nop

00801df4 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  801df4:	55                   	push   %ebp
  801df5:	57                   	push   %edi
  801df6:	56                   	push   %esi
  801df7:	53                   	push   %ebx
  801df8:	83 ec 1c             	sub    $0x1c,%esp
  801dfb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801dff:	8b 74 24 34          	mov    0x34(%esp),%esi
  801e03:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801e07:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801e0b:	89 44 24 0c          	mov    %eax,0xc(%esp)
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801e0f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801e13:	89 f3                	mov    %esi,%ebx
  const DWunion dd = {.ll = d};
  801e15:	89 fa                	mov    %edi,%edx
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  801e17:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  n1 = nn.s.high;
  801e1b:	89 34 24             	mov    %esi,(%esp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801e1e:	85 c0                	test   %eax,%eax
  801e20:	75 1a                	jne    801e3c <__umoddi3+0x48>
    {
      if (d0 > n1)
  801e22:	39 f7                	cmp    %esi,%edi
  801e24:	0f 86 a2 00 00 00    	jbe    801ecc <__umoddi3+0xd8>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801e2a:	89 c8                	mov    %ecx,%eax
  801e2c:	89 f2                	mov    %esi,%edx
  801e2e:	f7 f7                	div    %edi
  801e30:	89 d0                	mov    %edx,%eax

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  801e32:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801e34:	83 c4 1c             	add    $0x1c,%esp
  801e37:	5b                   	pop    %ebx
  801e38:	5e                   	pop    %esi
  801e39:	5f                   	pop    %edi
  801e3a:	5d                   	pop    %ebp
  801e3b:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801e3c:	39 f0                	cmp    %esi,%eax
  801e3e:	0f 87 ac 00 00 00    	ja     801ef0 <__umoddi3+0xfc>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801e44:	0f bd e8             	bsr    %eax,%ebp
	  if (bm == 0)
  801e47:	83 f5 1f             	xor    $0x1f,%ebp
  801e4a:	0f 84 ac 00 00 00    	je     801efc <__umoddi3+0x108>
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801e50:	bf 20 00 00 00       	mov    $0x20,%edi
  801e55:	29 ef                	sub    %ebp,%edi
  801e57:	89 fe                	mov    %edi,%esi
  801e59:	89 7c 24 0c          	mov    %edi,0xc(%esp)

	      d1 = (d1 << bm) | (d0 >> b);
  801e5d:	89 e9                	mov    %ebp,%ecx
  801e5f:	d3 e0                	shl    %cl,%eax
  801e61:	89 d7                	mov    %edx,%edi
  801e63:	89 f1                	mov    %esi,%ecx
  801e65:	d3 ef                	shr    %cl,%edi
  801e67:	09 c7                	or     %eax,%edi
	      d0 = d0 << bm;
  801e69:	89 e9                	mov    %ebp,%ecx
  801e6b:	d3 e2                	shl    %cl,%edx
  801e6d:	89 14 24             	mov    %edx,(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801e70:	89 d8                	mov    %ebx,%eax
  801e72:	d3 e0                	shl    %cl,%eax
  801e74:	89 c2                	mov    %eax,%edx
	      n0 = n0 << bm;
  801e76:	8b 44 24 08          	mov    0x8(%esp),%eax
  801e7a:	d3 e0                	shl    %cl,%eax
  801e7c:	89 44 24 04          	mov    %eax,0x4(%esp)

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801e80:	8b 44 24 08          	mov    0x8(%esp),%eax
  801e84:	89 f1                	mov    %esi,%ecx
  801e86:	d3 e8                	shr    %cl,%eax
  801e88:	09 d0                	or     %edx,%eax
  801e8a:	d3 eb                	shr    %cl,%ebx
  801e8c:	89 da                	mov    %ebx,%edx
  801e8e:	f7 f7                	div    %edi
  801e90:	89 d3                	mov    %edx,%ebx
	      umul_ppmm (m1, m0, q0, d0);
  801e92:	f7 24 24             	mull   (%esp)
  801e95:	89 c6                	mov    %eax,%esi
  801e97:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801e99:	39 d3                	cmp    %edx,%ebx
  801e9b:	0f 82 87 00 00 00    	jb     801f28 <__umoddi3+0x134>
  801ea1:	0f 84 91 00 00 00    	je     801f38 <__umoddi3+0x144>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  801ea7:	8b 54 24 04          	mov    0x4(%esp),%edx
  801eab:	29 f2                	sub    %esi,%edx
  801ead:	19 cb                	sbb    %ecx,%ebx
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801eaf:	89 d8                	mov    %ebx,%eax
  801eb1:	8a 4c 24 0c          	mov    0xc(%esp),%cl
  801eb5:	d3 e0                	shl    %cl,%eax
  801eb7:	89 e9                	mov    %ebp,%ecx
  801eb9:	d3 ea                	shr    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  801ebb:	09 d0                	or     %edx,%eax
  801ebd:	89 e9                	mov    %ebp,%ecx
  801ebf:	d3 eb                	shr    %cl,%ebx
  801ec1:	89 da                	mov    %ebx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801ec3:	83 c4 1c             	add    $0x1c,%esp
  801ec6:	5b                   	pop    %ebx
  801ec7:	5e                   	pop    %esi
  801ec8:	5f                   	pop    %edi
  801ec9:	5d                   	pop    %ebp
  801eca:	c3                   	ret    
  801ecb:	90                   	nop
  801ecc:	89 fd                	mov    %edi,%ebp
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801ece:	85 ff                	test   %edi,%edi
  801ed0:	75 0b                	jne    801edd <__umoddi3+0xe9>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801ed2:	b8 01 00 00 00       	mov    $0x1,%eax
  801ed7:	31 d2                	xor    %edx,%edx
  801ed9:	f7 f7                	div    %edi
  801edb:	89 c5                	mov    %eax,%ebp

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801edd:	89 f0                	mov    %esi,%eax
  801edf:	31 d2                	xor    %edx,%edx
  801ee1:	f7 f5                	div    %ebp
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801ee3:	89 c8                	mov    %ecx,%eax
  801ee5:	f7 f5                	div    %ebp
  801ee7:	89 d0                	mov    %edx,%eax
  801ee9:	e9 44 ff ff ff       	jmp    801e32 <__umoddi3+0x3e>
  801eee:	66 90                	xchg   %ax,%ax
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  801ef0:	89 c8                	mov    %ecx,%eax
  801ef2:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801ef4:	83 c4 1c             	add    $0x1c,%esp
  801ef7:	5b                   	pop    %ebx
  801ef8:	5e                   	pop    %esi
  801ef9:	5f                   	pop    %edi
  801efa:	5d                   	pop    %ebp
  801efb:	c3                   	ret    

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801efc:	3b 04 24             	cmp    (%esp),%eax
  801eff:	72 06                	jb     801f07 <__umoddi3+0x113>
  801f01:	3b 7c 24 04          	cmp    0x4(%esp),%edi
  801f05:	77 0f                	ja     801f16 <__umoddi3+0x122>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801f07:	89 f2                	mov    %esi,%edx
  801f09:	29 f9                	sub    %edi,%ecx
  801f0b:	1b 54 24 0c          	sbb    0xc(%esp),%edx
  801f0f:	89 14 24             	mov    %edx,(%esp)
  801f12:	89 4c 24 04          	mov    %ecx,0x4(%esp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  801f16:	8b 44 24 04          	mov    0x4(%esp),%eax
  801f1a:	8b 14 24             	mov    (%esp),%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801f1d:	83 c4 1c             	add    $0x1c,%esp
  801f20:	5b                   	pop    %ebx
  801f21:	5e                   	pop    %esi
  801f22:	5f                   	pop    %edi
  801f23:	5d                   	pop    %ebp
  801f24:	c3                   	ret    
  801f25:	8d 76 00             	lea    0x0(%esi),%esi
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801f28:	2b 04 24             	sub    (%esp),%eax
  801f2b:	19 fa                	sbb    %edi,%edx
  801f2d:	89 d1                	mov    %edx,%ecx
  801f2f:	89 c6                	mov    %eax,%esi
  801f31:	e9 71 ff ff ff       	jmp    801ea7 <__umoddi3+0xb3>
  801f36:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801f38:	39 44 24 04          	cmp    %eax,0x4(%esp)
  801f3c:	72 ea                	jb     801f28 <__umoddi3+0x134>
  801f3e:	89 d9                	mov    %ebx,%ecx
  801f40:	e9 62 ff ff ff       	jmp    801ea7 <__umoddi3+0xb3>
