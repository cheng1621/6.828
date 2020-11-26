
obj/user/testbss.debug:     file format elf32-i386


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
  80002c:	e8 c5 00 00 00       	call   8000f6 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

uint32_t bigarray[ARRAYSIZE];

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 14             	sub    $0x14,%esp
	int i;

	cprintf("Making sure bss works right...\n");
  800039:	68 00 1f 80 00       	push   $0x801f00
  80003e:	e8 f4 01 00 00       	call   800237 <cprintf>
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != 0)
  800043:	83 c4 10             	add    $0x10,%esp
  800046:	83 3d 20 40 80 00 00 	cmpl   $0x0,0x804020
  80004d:	75 11                	jne    800060 <umain+0x2d>
  80004f:	b8 01 00 00 00       	mov    $0x1,%eax
  800054:	83 3c 85 20 40 80 00 	cmpl   $0x0,0x804020(,%eax,4)
  80005b:	00 
  80005c:	74 19                	je     800077 <umain+0x44>
  80005e:	eb 05                	jmp    800065 <umain+0x32>
umain(int argc, char **argv)
{
	int i;

	cprintf("Making sure bss works right...\n");
	for (i = 0; i < ARRAYSIZE; i++)
  800060:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
  800065:	50                   	push   %eax
  800066:	68 7b 1f 80 00       	push   $0x801f7b
  80006b:	6a 11                	push   $0x11
  80006d:	68 98 1f 80 00       	push   $0x801f98
  800072:	e8 e8 00 00 00       	call   80015f <_panic>
umain(int argc, char **argv)
{
	int i;

	cprintf("Making sure bss works right...\n");
	for (i = 0; i < ARRAYSIZE; i++)
  800077:	40                   	inc    %eax
  800078:	3d 00 00 10 00       	cmp    $0x100000,%eax
  80007d:	75 d5                	jne    800054 <umain+0x21>
  80007f:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
		bigarray[i] = i;
  800084:	89 04 85 20 40 80 00 	mov    %eax,0x804020(,%eax,4)

	cprintf("Making sure bss works right...\n");
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
  80008b:	40                   	inc    %eax
  80008c:	3d 00 00 10 00       	cmp    $0x100000,%eax
  800091:	75 f1                	jne    800084 <umain+0x51>
		bigarray[i] = i;
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != i)
  800093:	83 3d 20 40 80 00 00 	cmpl   $0x0,0x804020
  80009a:	75 10                	jne    8000ac <umain+0x79>
  80009c:	b8 01 00 00 00       	mov    $0x1,%eax
  8000a1:	3b 04 85 20 40 80 00 	cmp    0x804020(,%eax,4),%eax
  8000a8:	74 19                	je     8000c3 <umain+0x90>
  8000aa:	eb 05                	jmp    8000b1 <umain+0x7e>
  8000ac:	b8 00 00 00 00       	mov    $0x0,%eax
			panic("bigarray[%d] didn't hold its value!\n", i);
  8000b1:	50                   	push   %eax
  8000b2:	68 20 1f 80 00       	push   $0x801f20
  8000b7:	6a 16                	push   $0x16
  8000b9:	68 98 1f 80 00       	push   $0x801f98
  8000be:	e8 9c 00 00 00       	call   80015f <_panic>
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
		bigarray[i] = i;
	for (i = 0; i < ARRAYSIZE; i++)
  8000c3:	40                   	inc    %eax
  8000c4:	3d 00 00 10 00       	cmp    $0x100000,%eax
  8000c9:	75 d6                	jne    8000a1 <umain+0x6e>
		if (bigarray[i] != i)
			panic("bigarray[%d] didn't hold its value!\n", i);

	cprintf("Yes, good.  Now doing a wild write off the end...\n");
  8000cb:	83 ec 0c             	sub    $0xc,%esp
  8000ce:	68 48 1f 80 00       	push   $0x801f48
  8000d3:	e8 5f 01 00 00       	call   800237 <cprintf>
	bigarray[ARRAYSIZE+1024] = 0;
  8000d8:	c7 05 20 50 c0 00 00 	movl   $0x0,0xc05020
  8000df:	00 00 00 
	panic("SHOULD HAVE TRAPPED!!!");
  8000e2:	83 c4 0c             	add    $0xc,%esp
  8000e5:	68 a7 1f 80 00       	push   $0x801fa7
  8000ea:	6a 1a                	push   $0x1a
  8000ec:	68 98 1f 80 00       	push   $0x801f98
  8000f1:	e8 69 00 00 00       	call   80015f <_panic>

008000f6 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000f6:	55                   	push   %ebp
  8000f7:	89 e5                	mov    %esp,%ebp
  8000f9:	56                   	push   %esi
  8000fa:	53                   	push   %ebx
  8000fb:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000fe:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800101:	e8 48 0b 00 00       	call   800c4e <sys_getenvid>
  800106:	25 ff 03 00 00       	and    $0x3ff,%eax
  80010b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800112:	c1 e0 07             	shl    $0x7,%eax
  800115:	29 d0                	sub    %edx,%eax
  800117:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80011c:	a3 20 40 c0 00       	mov    %eax,0xc04020

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800121:	85 db                	test   %ebx,%ebx
  800123:	7e 07                	jle    80012c <libmain+0x36>
		binaryname = argv[0];
  800125:	8b 06                	mov    (%esi),%eax
  800127:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80012c:	83 ec 08             	sub    $0x8,%esp
  80012f:	56                   	push   %esi
  800130:	53                   	push   %ebx
  800131:	e8 fd fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800136:	e8 0a 00 00 00       	call   800145 <exit>
}
  80013b:	83 c4 10             	add    $0x10,%esp
  80013e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800141:	5b                   	pop    %ebx
  800142:	5e                   	pop    %esi
  800143:	5d                   	pop    %ebp
  800144:	c3                   	ret    

00800145 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800145:	55                   	push   %ebp
  800146:	89 e5                	mov    %esp,%ebp
  800148:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80014b:	e8 3c 0f 00 00       	call   80108c <close_all>
	sys_env_destroy(0);
  800150:	83 ec 0c             	sub    $0xc,%esp
  800153:	6a 00                	push   $0x0
  800155:	e8 b3 0a 00 00       	call   800c0d <sys_env_destroy>
}
  80015a:	83 c4 10             	add    $0x10,%esp
  80015d:	c9                   	leave  
  80015e:	c3                   	ret    

0080015f <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80015f:	55                   	push   %ebp
  800160:	89 e5                	mov    %esp,%ebp
  800162:	56                   	push   %esi
  800163:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800164:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800167:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80016d:	e8 dc 0a 00 00       	call   800c4e <sys_getenvid>
  800172:	83 ec 0c             	sub    $0xc,%esp
  800175:	ff 75 0c             	pushl  0xc(%ebp)
  800178:	ff 75 08             	pushl  0x8(%ebp)
  80017b:	56                   	push   %esi
  80017c:	50                   	push   %eax
  80017d:	68 c8 1f 80 00       	push   $0x801fc8
  800182:	e8 b0 00 00 00       	call   800237 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800187:	83 c4 18             	add    $0x18,%esp
  80018a:	53                   	push   %ebx
  80018b:	ff 75 10             	pushl  0x10(%ebp)
  80018e:	e8 53 00 00 00       	call   8001e6 <vcprintf>
	cprintf("\n");
  800193:	c7 04 24 96 1f 80 00 	movl   $0x801f96,(%esp)
  80019a:	e8 98 00 00 00       	call   800237 <cprintf>
  80019f:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001a2:	cc                   	int3   
  8001a3:	eb fd                	jmp    8001a2 <_panic+0x43>

008001a5 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001a5:	55                   	push   %ebp
  8001a6:	89 e5                	mov    %esp,%ebp
  8001a8:	53                   	push   %ebx
  8001a9:	83 ec 04             	sub    $0x4,%esp
  8001ac:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001af:	8b 13                	mov    (%ebx),%edx
  8001b1:	8d 42 01             	lea    0x1(%edx),%eax
  8001b4:	89 03                	mov    %eax,(%ebx)
  8001b6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001b9:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001bd:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001c2:	75 1a                	jne    8001de <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001c4:	83 ec 08             	sub    $0x8,%esp
  8001c7:	68 ff 00 00 00       	push   $0xff
  8001cc:	8d 43 08             	lea    0x8(%ebx),%eax
  8001cf:	50                   	push   %eax
  8001d0:	e8 fb 09 00 00       	call   800bd0 <sys_cputs>
		b->idx = 0;
  8001d5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001db:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001de:	ff 43 04             	incl   0x4(%ebx)
}
  8001e1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001e4:	c9                   	leave  
  8001e5:	c3                   	ret    

008001e6 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001e6:	55                   	push   %ebp
  8001e7:	89 e5                	mov    %esp,%ebp
  8001e9:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001ef:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001f6:	00 00 00 
	b.cnt = 0;
  8001f9:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800200:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800203:	ff 75 0c             	pushl  0xc(%ebp)
  800206:	ff 75 08             	pushl  0x8(%ebp)
  800209:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80020f:	50                   	push   %eax
  800210:	68 a5 01 80 00       	push   $0x8001a5
  800215:	e8 54 01 00 00       	call   80036e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80021a:	83 c4 08             	add    $0x8,%esp
  80021d:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800223:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800229:	50                   	push   %eax
  80022a:	e8 a1 09 00 00       	call   800bd0 <sys_cputs>

	return b.cnt;
}
  80022f:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800235:	c9                   	leave  
  800236:	c3                   	ret    

00800237 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800237:	55                   	push   %ebp
  800238:	89 e5                	mov    %esp,%ebp
  80023a:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80023d:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800240:	50                   	push   %eax
  800241:	ff 75 08             	pushl  0x8(%ebp)
  800244:	e8 9d ff ff ff       	call   8001e6 <vcprintf>
	va_end(ap);

	return cnt;
}
  800249:	c9                   	leave  
  80024a:	c3                   	ret    

0080024b <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80024b:	55                   	push   %ebp
  80024c:	89 e5                	mov    %esp,%ebp
  80024e:	57                   	push   %edi
  80024f:	56                   	push   %esi
  800250:	53                   	push   %ebx
  800251:	83 ec 1c             	sub    $0x1c,%esp
  800254:	89 c6                	mov    %eax,%esi
  800256:	89 d7                	mov    %edx,%edi
  800258:	8b 45 08             	mov    0x8(%ebp),%eax
  80025b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80025e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800261:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800264:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800267:	bb 00 00 00 00       	mov    $0x0,%ebx
  80026c:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80026f:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800272:	39 d3                	cmp    %edx,%ebx
  800274:	72 11                	jb     800287 <printnum+0x3c>
  800276:	39 45 10             	cmp    %eax,0x10(%ebp)
  800279:	76 0c                	jbe    800287 <printnum+0x3c>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80027b:	8b 45 14             	mov    0x14(%ebp),%eax
  80027e:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800281:	85 db                	test   %ebx,%ebx
  800283:	7f 37                	jg     8002bc <printnum+0x71>
  800285:	eb 44                	jmp    8002cb <printnum+0x80>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800287:	83 ec 0c             	sub    $0xc,%esp
  80028a:	ff 75 18             	pushl  0x18(%ebp)
  80028d:	8b 45 14             	mov    0x14(%ebp),%eax
  800290:	48                   	dec    %eax
  800291:	50                   	push   %eax
  800292:	ff 75 10             	pushl  0x10(%ebp)
  800295:	83 ec 08             	sub    $0x8,%esp
  800298:	ff 75 e4             	pushl  -0x1c(%ebp)
  80029b:	ff 75 e0             	pushl  -0x20(%ebp)
  80029e:	ff 75 dc             	pushl  -0x24(%ebp)
  8002a1:	ff 75 d8             	pushl  -0x28(%ebp)
  8002a4:	e8 df 19 00 00       	call   801c88 <__udivdi3>
  8002a9:	83 c4 18             	add    $0x18,%esp
  8002ac:	52                   	push   %edx
  8002ad:	50                   	push   %eax
  8002ae:	89 fa                	mov    %edi,%edx
  8002b0:	89 f0                	mov    %esi,%eax
  8002b2:	e8 94 ff ff ff       	call   80024b <printnum>
  8002b7:	83 c4 20             	add    $0x20,%esp
  8002ba:	eb 0f                	jmp    8002cb <printnum+0x80>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002bc:	83 ec 08             	sub    $0x8,%esp
  8002bf:	57                   	push   %edi
  8002c0:	ff 75 18             	pushl  0x18(%ebp)
  8002c3:	ff d6                	call   *%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002c5:	83 c4 10             	add    $0x10,%esp
  8002c8:	4b                   	dec    %ebx
  8002c9:	75 f1                	jne    8002bc <printnum+0x71>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002cb:	83 ec 08             	sub    $0x8,%esp
  8002ce:	57                   	push   %edi
  8002cf:	83 ec 04             	sub    $0x4,%esp
  8002d2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002d5:	ff 75 e0             	pushl  -0x20(%ebp)
  8002d8:	ff 75 dc             	pushl  -0x24(%ebp)
  8002db:	ff 75 d8             	pushl  -0x28(%ebp)
  8002de:	e8 b5 1a 00 00       	call   801d98 <__umoddi3>
  8002e3:	83 c4 14             	add    $0x14,%esp
  8002e6:	0f be 80 eb 1f 80 00 	movsbl 0x801feb(%eax),%eax
  8002ed:	50                   	push   %eax
  8002ee:	ff d6                	call   *%esi
}
  8002f0:	83 c4 10             	add    $0x10,%esp
  8002f3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002f6:	5b                   	pop    %ebx
  8002f7:	5e                   	pop    %esi
  8002f8:	5f                   	pop    %edi
  8002f9:	5d                   	pop    %ebp
  8002fa:	c3                   	ret    

008002fb <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002fb:	55                   	push   %ebp
  8002fc:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002fe:	83 fa 01             	cmp    $0x1,%edx
  800301:	7e 0e                	jle    800311 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800303:	8b 10                	mov    (%eax),%edx
  800305:	8d 4a 08             	lea    0x8(%edx),%ecx
  800308:	89 08                	mov    %ecx,(%eax)
  80030a:	8b 02                	mov    (%edx),%eax
  80030c:	8b 52 04             	mov    0x4(%edx),%edx
  80030f:	eb 22                	jmp    800333 <getuint+0x38>
	else if (lflag)
  800311:	85 d2                	test   %edx,%edx
  800313:	74 10                	je     800325 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800315:	8b 10                	mov    (%eax),%edx
  800317:	8d 4a 04             	lea    0x4(%edx),%ecx
  80031a:	89 08                	mov    %ecx,(%eax)
  80031c:	8b 02                	mov    (%edx),%eax
  80031e:	ba 00 00 00 00       	mov    $0x0,%edx
  800323:	eb 0e                	jmp    800333 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800325:	8b 10                	mov    (%eax),%edx
  800327:	8d 4a 04             	lea    0x4(%edx),%ecx
  80032a:	89 08                	mov    %ecx,(%eax)
  80032c:	8b 02                	mov    (%edx),%eax
  80032e:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800333:	5d                   	pop    %ebp
  800334:	c3                   	ret    

00800335 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800335:	55                   	push   %ebp
  800336:	89 e5                	mov    %esp,%ebp
  800338:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80033b:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  80033e:	8b 10                	mov    (%eax),%edx
  800340:	3b 50 04             	cmp    0x4(%eax),%edx
  800343:	73 0a                	jae    80034f <sprintputch+0x1a>
		*b->buf++ = ch;
  800345:	8d 4a 01             	lea    0x1(%edx),%ecx
  800348:	89 08                	mov    %ecx,(%eax)
  80034a:	8b 45 08             	mov    0x8(%ebp),%eax
  80034d:	88 02                	mov    %al,(%edx)
}
  80034f:	5d                   	pop    %ebp
  800350:	c3                   	ret    

00800351 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800351:	55                   	push   %ebp
  800352:	89 e5                	mov    %esp,%ebp
  800354:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800357:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80035a:	50                   	push   %eax
  80035b:	ff 75 10             	pushl  0x10(%ebp)
  80035e:	ff 75 0c             	pushl  0xc(%ebp)
  800361:	ff 75 08             	pushl  0x8(%ebp)
  800364:	e8 05 00 00 00       	call   80036e <vprintfmt>
	va_end(ap);
}
  800369:	83 c4 10             	add    $0x10,%esp
  80036c:	c9                   	leave  
  80036d:	c3                   	ret    

0080036e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80036e:	55                   	push   %ebp
  80036f:	89 e5                	mov    %esp,%ebp
  800371:	57                   	push   %edi
  800372:	56                   	push   %esi
  800373:	53                   	push   %ebx
  800374:	83 ec 2c             	sub    $0x2c,%esp
  800377:	8b 7d 08             	mov    0x8(%ebp),%edi
  80037a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80037d:	eb 03                	jmp    800382 <vprintfmt+0x14>
			break;

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
			for (fmt--; fmt[-1] != '%'; fmt--)
  80037f:	89 75 10             	mov    %esi,0x10(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {    //遍历输入的第一个参数，即输出信息的格式，先把格式字符串中'%'之前的字符一个个输出，因为它们前面没有'%'，所以它们就是要直接显示在屏幕上的
  800382:	8b 45 10             	mov    0x10(%ebp),%eax
  800385:	8d 70 01             	lea    0x1(%eax),%esi
  800388:	0f b6 00             	movzbl (%eax),%eax
  80038b:	83 f8 25             	cmp    $0x25,%eax
  80038e:	74 25                	je     8003b5 <vprintfmt+0x47>
			if (ch == '\0')									//当然中间如果遇到'\0'，代表这个字符串的访问结束
  800390:	85 c0                	test   %eax,%eax
  800392:	75 0d                	jne    8003a1 <vprintfmt+0x33>
  800394:	e9 b5 03 00 00       	jmp    80074e <vprintfmt+0x3e0>
  800399:	85 c0                	test   %eax,%eax
  80039b:	0f 84 ad 03 00 00    	je     80074e <vprintfmt+0x3e0>
				return;
			putch(ch, putdat);								//调用putch函数，把一个字符ch输出到putdat指针所指向的地址中所存放的值对应的地址处
  8003a1:	83 ec 08             	sub    $0x8,%esp
  8003a4:	53                   	push   %ebx
  8003a5:	50                   	push   %eax
  8003a6:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {    //遍历输入的第一个参数，即输出信息的格式，先把格式字符串中'%'之前的字符一个个输出，因为它们前面没有'%'，所以它们就是要直接显示在屏幕上的
  8003a8:	46                   	inc    %esi
  8003a9:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  8003ad:	83 c4 10             	add    $0x10,%esp
  8003b0:	83 f8 25             	cmp    $0x25,%eax
  8003b3:	75 e4                	jne    800399 <vprintfmt+0x2b>
			if (width < 0)									//代表有小数点，但是小数点前面并没有数字，比如'%.6f'这种情况，此时代表整数部分全部显示
				width = 0;			
			goto reswitch;

		case '#':
			altflag = 1;
  8003b5:	c6 45 e3 20          	movb   $0x20,-0x1d(%ebp)
  8003b9:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8003c0:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003c7:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8003ce:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8003d5:	eb 07                	jmp    8003de <vprintfmt+0x70>
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  8003d7:	8b 75 10             	mov    0x10(%ebp),%esi

		// flag to pad on the right
		case '-':											//%后面的'-'代表要进行左对齐输出，右边填空格，如果省略代表右对齐
			padc = '-';										//如果有这个字符代表左对齐，则把对齐方式标志位变为'-'
  8003da:	c6 45 e3 2d          	movb   $0x2d,-0x1d(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  8003de:	8d 46 01             	lea    0x1(%esi),%eax
  8003e1:	89 45 10             	mov    %eax,0x10(%ebp)
  8003e4:	0f b6 16             	movzbl (%esi),%edx
  8003e7:	8a 06                	mov    (%esi),%al
  8003e9:	83 e8 23             	sub    $0x23,%eax
  8003ec:	3c 55                	cmp    $0x55,%al
  8003ee:	0f 87 03 03 00 00    	ja     8006f7 <vprintfmt+0x389>
  8003f4:	0f b6 c0             	movzbl %al,%eax
  8003f7:	ff 24 85 20 21 80 00 	jmp    *0x802120(,%eax,4)
  8003fe:	8b 75 10             	mov    0x10(%ebp),%esi
			padc = '-';										//如果有这个字符代表左对齐，则把对齐方式标志位变为'-'
			goto reswitch;									//处理下一个字符

		// flag to pad with 0's instead of spaces
		case '0':											//0--有0表示进行对齐输出时填0,如省略表示填入空格，并且如果为0，则一定是右对齐
			padc = '0';										//对其方式标志位变为0
  800401:	c6 45 e3 30          	movb   $0x30,-0x1d(%ebp)
  800405:	eb d7                	jmp    8003de <vprintfmt+0x70>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {					//把遇到的位数字符串转换为真实的位数，比如输入的'%40'，代表有效位数为40位，下面的循环就是把precesion的值设置为40
				precision = precision * 10 + ch - '0';
  800407:	8d 42 d0             	lea    -0x30(%edx),%eax
  80040a:	89 c1                	mov    %eax,%ecx
  80040c:	89 45 d0             	mov    %eax,-0x30(%ebp)
				ch = *fmt;
  80040f:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  800413:	8d 50 d0             	lea    -0x30(%eax),%edx
  800416:	83 fa 09             	cmp    $0x9,%edx
  800419:	77 51                	ja     80046c <vprintfmt+0xfe>
  80041b:	8b 75 10             	mov    0x10(%ebp),%esi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {					//把遇到的位数字符串转换为真实的位数，比如输入的'%40'，代表有效位数为40位，下面的循环就是把precesion的值设置为40
  80041e:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  80041f:	8d 14 89             	lea    (%ecx,%ecx,4),%edx
  800422:	01 d2                	add    %edx,%edx
  800424:	8d 4c 10 d0          	lea    -0x30(%eax,%edx,1),%ecx
				ch = *fmt;
  800428:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80042b:	8d 50 d0             	lea    -0x30(%eax),%edx
  80042e:	83 fa 09             	cmp    $0x9,%edx
  800431:	76 eb                	jbe    80041e <vprintfmt+0xb0>
  800433:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800436:	eb 37                	jmp    80046f <vprintfmt+0x101>
					break;
			}
			goto process_precision;							//跳转到process_precistion子过程

		case '*':											//*--代表有效数字的位数也是由输入参数指定的，比如printf("%*.*f", 10, 2, n)，其中10,2就是用来指定显示的有效数字位数的
			precision = va_arg(ap, int);
  800438:	8b 45 14             	mov    0x14(%ebp),%eax
  80043b:	8d 50 04             	lea    0x4(%eax),%edx
  80043e:	89 55 14             	mov    %edx,0x14(%ebp)
  800441:	8b 00                	mov    (%eax),%eax
  800443:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  800446:	8b 75 10             	mov    0x10(%ebp),%esi
			}
			goto process_precision;							//跳转到process_precistion子过程

		case '*':											//*--代表有效数字的位数也是由输入参数指定的，比如printf("%*.*f", 10, 2, n)，其中10,2就是用来指定显示的有效数字位数的
			precision = va_arg(ap, int);
			goto process_precision;
  800449:	eb 24                	jmp    80046f <vprintfmt+0x101>
  80044b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80044f:	79 07                	jns    800458 <vprintfmt+0xea>
  800451:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  800458:	8b 75 10             	mov    0x10(%ebp),%esi
  80045b:	eb 81                	jmp    8003de <vprintfmt+0x70>
  80045d:	8b 75 10             	mov    0x10(%ebp),%esi
			if (width < 0)									//代表有小数点，但是小数点前面并没有数字，比如'%.6f'这种情况，此时代表整数部分全部显示
				width = 0;			
			goto reswitch;

		case '#':
			altflag = 1;
  800460:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800467:	e9 72 ff ff ff       	jmp    8003de <vprintfmt+0x70>
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  80046c:	8b 75 10             	mov    0x10(%ebp),%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:									//处理输出精度，把width字段赋值为刚刚计算出来的precision值，所以width应该是整数部分的有效数字位数
			if (width < 0)
  80046f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800473:	0f 89 65 ff ff ff    	jns    8003de <vprintfmt+0x70>
				width = precision, precision = -1;
  800479:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80047c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80047f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800486:	e9 53 ff ff ff       	jmp    8003de <vprintfmt+0x70>
			goto reswitch;

		// long flag (doubled for long long)				
		case 'l':											//如果遇到'l'，代表应该是输入long类型，如果有两个'l'代表long long
			lflag++;										//此时把lflag++
  80048b:	ff 45 d4             	incl   -0x2c(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  80048e:	8b 75 10             	mov    0x10(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)				
		case 'l':											//如果遇到'l'，代表应该是输入long类型，如果有两个'l'代表long long
			lflag++;										//此时把lflag++
			goto reswitch;
  800491:	e9 48 ff ff ff       	jmp    8003de <vprintfmt+0x70>

		// character
		case 'c':											//如果是'c'代表显示一个字符
			putch(va_arg(ap, int), putdat);					//调用输出一个字符到内存的函数putch
  800496:	8b 45 14             	mov    0x14(%ebp),%eax
  800499:	8d 50 04             	lea    0x4(%eax),%edx
  80049c:	89 55 14             	mov    %edx,0x14(%ebp)
  80049f:	83 ec 08             	sub    $0x8,%esp
  8004a2:	53                   	push   %ebx
  8004a3:	ff 30                	pushl  (%eax)
  8004a5:	ff d7                	call   *%edi
			break;
  8004a7:	83 c4 10             	add    $0x10,%esp
  8004aa:	e9 d3 fe ff ff       	jmp    800382 <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004af:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b2:	8d 50 04             	lea    0x4(%eax),%edx
  8004b5:	89 55 14             	mov    %edx,0x14(%ebp)
  8004b8:	8b 00                	mov    (%eax),%eax
  8004ba:	85 c0                	test   %eax,%eax
  8004bc:	79 02                	jns    8004c0 <vprintfmt+0x152>
  8004be:	f7 d8                	neg    %eax
  8004c0:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004c2:	83 f8 0f             	cmp    $0xf,%eax
  8004c5:	7f 0b                	jg     8004d2 <vprintfmt+0x164>
  8004c7:	8b 04 85 80 22 80 00 	mov    0x802280(,%eax,4),%eax
  8004ce:	85 c0                	test   %eax,%eax
  8004d0:	75 15                	jne    8004e7 <vprintfmt+0x179>
				printfmt(putch, putdat, "error %d", err);
  8004d2:	52                   	push   %edx
  8004d3:	68 03 20 80 00       	push   $0x802003
  8004d8:	53                   	push   %ebx
  8004d9:	57                   	push   %edi
  8004da:	e8 72 fe ff ff       	call   800351 <printfmt>
  8004df:	83 c4 10             	add    $0x10,%esp
  8004e2:	e9 9b fe ff ff       	jmp    800382 <vprintfmt+0x14>
			else
				printfmt(putch, putdat, "%s", p);
  8004e7:	50                   	push   %eax
  8004e8:	68 a2 23 80 00       	push   $0x8023a2
  8004ed:	53                   	push   %ebx
  8004ee:	57                   	push   %edi
  8004ef:	e8 5d fe ff ff       	call   800351 <printfmt>
  8004f4:	83 c4 10             	add    $0x10,%esp
  8004f7:	e9 86 fe ff ff       	jmp    800382 <vprintfmt+0x14>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ff:	8d 50 04             	lea    0x4(%eax),%edx
  800502:	89 55 14             	mov    %edx,0x14(%ebp)
  800505:	8b 00                	mov    (%eax),%eax
  800507:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80050a:	85 c0                	test   %eax,%eax
  80050c:	75 07                	jne    800515 <vprintfmt+0x1a7>
				p = "(null)";
  80050e:	c7 45 d4 fc 1f 80 00 	movl   $0x801ffc,-0x2c(%ebp)
			if (width > 0 && padc != '-')
  800515:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800518:	85 f6                	test   %esi,%esi
  80051a:	0f 8e fb 01 00 00    	jle    80071b <vprintfmt+0x3ad>
  800520:	80 7d e3 2d          	cmpb   $0x2d,-0x1d(%ebp)
  800524:	0f 84 09 02 00 00    	je     800733 <vprintfmt+0x3c5>
				for (width -= strnlen(p, precision); width > 0; width--)
  80052a:	83 ec 08             	sub    $0x8,%esp
  80052d:	ff 75 d0             	pushl  -0x30(%ebp)
  800530:	ff 75 d4             	pushl  -0x2c(%ebp)
  800533:	e8 ad 02 00 00       	call   8007e5 <strnlen>
  800538:	89 f1                	mov    %esi,%ecx
  80053a:	29 c1                	sub    %eax,%ecx
  80053c:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  80053f:	83 c4 10             	add    $0x10,%esp
  800542:	85 c9                	test   %ecx,%ecx
  800544:	0f 8e d1 01 00 00    	jle    80071b <vprintfmt+0x3ad>
					putch(padc, putdat);
  80054a:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  80054e:	83 ec 08             	sub    $0x8,%esp
  800551:	53                   	push   %ebx
  800552:	56                   	push   %esi
  800553:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800555:	83 c4 10             	add    $0x10,%esp
  800558:	ff 4d e4             	decl   -0x1c(%ebp)
  80055b:	75 f1                	jne    80054e <vprintfmt+0x1e0>
  80055d:	e9 b9 01 00 00       	jmp    80071b <vprintfmt+0x3ad>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800562:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800566:	74 19                	je     800581 <vprintfmt+0x213>
  800568:	0f be c0             	movsbl %al,%eax
  80056b:	83 e8 20             	sub    $0x20,%eax
  80056e:	83 f8 5e             	cmp    $0x5e,%eax
  800571:	76 0e                	jbe    800581 <vprintfmt+0x213>
					putch('?', putdat);
  800573:	83 ec 08             	sub    $0x8,%esp
  800576:	53                   	push   %ebx
  800577:	6a 3f                	push   $0x3f
  800579:	ff 55 08             	call   *0x8(%ebp)
  80057c:	83 c4 10             	add    $0x10,%esp
  80057f:	eb 0b                	jmp    80058c <vprintfmt+0x21e>
				else
					putch(ch, putdat);
  800581:	83 ec 08             	sub    $0x8,%esp
  800584:	53                   	push   %ebx
  800585:	52                   	push   %edx
  800586:	ff 55 08             	call   *0x8(%ebp)
  800589:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80058c:	ff 4d e4             	decl   -0x1c(%ebp)
  80058f:	46                   	inc    %esi
  800590:	8a 46 ff             	mov    -0x1(%esi),%al
  800593:	0f be d0             	movsbl %al,%edx
  800596:	85 d2                	test   %edx,%edx
  800598:	75 1c                	jne    8005b6 <vprintfmt+0x248>
  80059a:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80059d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005a1:	7f 1f                	jg     8005c2 <vprintfmt+0x254>
  8005a3:	e9 da fd ff ff       	jmp    800382 <vprintfmt+0x14>
  8005a8:	89 7d 08             	mov    %edi,0x8(%ebp)
  8005ab:	8b 7d d0             	mov    -0x30(%ebp),%edi
  8005ae:	eb 06                	jmp    8005b6 <vprintfmt+0x248>
  8005b0:	89 7d 08             	mov    %edi,0x8(%ebp)
  8005b3:	8b 7d d0             	mov    -0x30(%ebp),%edi
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005b6:	85 ff                	test   %edi,%edi
  8005b8:	78 a8                	js     800562 <vprintfmt+0x1f4>
  8005ba:	4f                   	dec    %edi
  8005bb:	79 a5                	jns    800562 <vprintfmt+0x1f4>
  8005bd:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005c0:	eb db                	jmp    80059d <vprintfmt+0x22f>
  8005c2:	8b 75 e4             	mov    -0x1c(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005c5:	83 ec 08             	sub    $0x8,%esp
  8005c8:	53                   	push   %ebx
  8005c9:	6a 20                	push   $0x20
  8005cb:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005cd:	4e                   	dec    %esi
  8005ce:	83 c4 10             	add    $0x10,%esp
  8005d1:	85 f6                	test   %esi,%esi
  8005d3:	7f f0                	jg     8005c5 <vprintfmt+0x257>
  8005d5:	e9 a8 fd ff ff       	jmp    800382 <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005da:	83 7d d4 01          	cmpl   $0x1,-0x2c(%ebp)
  8005de:	7e 16                	jle    8005f6 <vprintfmt+0x288>
		return va_arg(*ap, long long);
  8005e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e3:	8d 50 08             	lea    0x8(%eax),%edx
  8005e6:	89 55 14             	mov    %edx,0x14(%ebp)
  8005e9:	8b 50 04             	mov    0x4(%eax),%edx
  8005ec:	8b 00                	mov    (%eax),%eax
  8005ee:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005f1:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005f4:	eb 34                	jmp    80062a <vprintfmt+0x2bc>
	else if (lflag)
  8005f6:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8005fa:	74 18                	je     800614 <vprintfmt+0x2a6>
		return va_arg(*ap, long);
  8005fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ff:	8d 50 04             	lea    0x4(%eax),%edx
  800602:	89 55 14             	mov    %edx,0x14(%ebp)
  800605:	8b 30                	mov    (%eax),%esi
  800607:	89 75 d8             	mov    %esi,-0x28(%ebp)
  80060a:	89 f0                	mov    %esi,%eax
  80060c:	c1 f8 1f             	sar    $0x1f,%eax
  80060f:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800612:	eb 16                	jmp    80062a <vprintfmt+0x2bc>
	else
		return va_arg(*ap, int);
  800614:	8b 45 14             	mov    0x14(%ebp),%eax
  800617:	8d 50 04             	lea    0x4(%eax),%edx
  80061a:	89 55 14             	mov    %edx,0x14(%ebp)
  80061d:	8b 30                	mov    (%eax),%esi
  80061f:	89 75 d8             	mov    %esi,-0x28(%ebp)
  800622:	89 f0                	mov    %esi,%eax
  800624:	c1 f8 1f             	sar    $0x1f,%eax
  800627:	89 45 dc             	mov    %eax,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80062a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80062d:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
  800630:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800634:	0f 89 8a 00 00 00    	jns    8006c4 <vprintfmt+0x356>
				putch('-', putdat);
  80063a:	83 ec 08             	sub    $0x8,%esp
  80063d:	53                   	push   %ebx
  80063e:	6a 2d                	push   $0x2d
  800640:	ff d7                	call   *%edi
				num = -(long long) num;
  800642:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800645:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800648:	f7 d8                	neg    %eax
  80064a:	83 d2 00             	adc    $0x0,%edx
  80064d:	f7 da                	neg    %edx
  80064f:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800652:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800657:	eb 70                	jmp    8006c9 <vprintfmt+0x35b>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800659:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80065c:	8d 45 14             	lea    0x14(%ebp),%eax
  80065f:	e8 97 fc ff ff       	call   8002fb <getuint>
			base = 10;
  800664:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800669:	eb 5e                	jmp    8006c9 <vprintfmt+0x35b>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
  80066b:	83 ec 08             	sub    $0x8,%esp
  80066e:	53                   	push   %ebx
  80066f:	6a 30                	push   $0x30
  800671:	ff d7                	call   *%edi
			num = getuint(&ap, lflag);
  800673:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800676:	8d 45 14             	lea    0x14(%ebp),%eax
  800679:	e8 7d fc ff ff       	call   8002fb <getuint>
			base = 8;
			goto number;
  80067e:	83 c4 10             	add    $0x10,%esp
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  800681:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800686:	eb 41                	jmp    8006c9 <vprintfmt+0x35b>
		// pointer
		case 'p':
			putch('0', putdat);
  800688:	83 ec 08             	sub    $0x8,%esp
  80068b:	53                   	push   %ebx
  80068c:	6a 30                	push   $0x30
  80068e:	ff d7                	call   *%edi
			putch('x', putdat);
  800690:	83 c4 08             	add    $0x8,%esp
  800693:	53                   	push   %ebx
  800694:	6a 78                	push   $0x78
  800696:	ff d7                	call   *%edi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800698:	8b 45 14             	mov    0x14(%ebp),%eax
  80069b:	8d 50 04             	lea    0x4(%eax),%edx
  80069e:	89 55 14             	mov    %edx,0x14(%ebp)
			goto number;
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006a1:	8b 00                	mov    (%eax),%eax
  8006a3:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006a8:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006ab:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8006b0:	eb 17                	jmp    8006c9 <vprintfmt+0x35b>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006b2:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8006b5:	8d 45 14             	lea    0x14(%ebp),%eax
  8006b8:	e8 3e fc ff ff       	call   8002fb <getuint>
			base = 16;
  8006bd:	b9 10 00 00 00       	mov    $0x10,%ecx
  8006c2:	eb 05                	jmp    8006c9 <vprintfmt+0x35b>
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006c4:	b9 0a 00 00 00       	mov    $0xa,%ecx
		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006c9:	83 ec 0c             	sub    $0xc,%esp
  8006cc:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  8006d0:	56                   	push   %esi
  8006d1:	ff 75 e4             	pushl  -0x1c(%ebp)
  8006d4:	51                   	push   %ecx
  8006d5:	52                   	push   %edx
  8006d6:	50                   	push   %eax
  8006d7:	89 da                	mov    %ebx,%edx
  8006d9:	89 f8                	mov    %edi,%eax
  8006db:	e8 6b fb ff ff       	call   80024b <printnum>
			break;
  8006e0:	83 c4 20             	add    $0x20,%esp
  8006e3:	e9 9a fc ff ff       	jmp    800382 <vprintfmt+0x14>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006e8:	83 ec 08             	sub    $0x8,%esp
  8006eb:	53                   	push   %ebx
  8006ec:	52                   	push   %edx
  8006ed:	ff d7                	call   *%edi
			break;
  8006ef:	83 c4 10             	add    $0x10,%esp
  8006f2:	e9 8b fc ff ff       	jmp    800382 <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006f7:	83 ec 08             	sub    $0x8,%esp
  8006fa:	53                   	push   %ebx
  8006fb:	6a 25                	push   $0x25
  8006fd:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006ff:	83 c4 10             	add    $0x10,%esp
  800702:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800706:	0f 84 73 fc ff ff    	je     80037f <vprintfmt+0x11>
  80070c:	4e                   	dec    %esi
  80070d:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800711:	75 f9                	jne    80070c <vprintfmt+0x39e>
  800713:	89 75 10             	mov    %esi,0x10(%ebp)
  800716:	e9 67 fc ff ff       	jmp    800382 <vprintfmt+0x14>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80071b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80071e:	8d 70 01             	lea    0x1(%eax),%esi
  800721:	8a 00                	mov    (%eax),%al
  800723:	0f be d0             	movsbl %al,%edx
  800726:	85 d2                	test   %edx,%edx
  800728:	0f 85 7a fe ff ff    	jne    8005a8 <vprintfmt+0x23a>
  80072e:	e9 4f fc ff ff       	jmp    800382 <vprintfmt+0x14>
  800733:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800736:	8d 70 01             	lea    0x1(%eax),%esi
  800739:	8a 00                	mov    (%eax),%al
  80073b:	0f be d0             	movsbl %al,%edx
  80073e:	85 d2                	test   %edx,%edx
  800740:	0f 85 6a fe ff ff    	jne    8005b0 <vprintfmt+0x242>
  800746:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800749:	e9 77 fe ff ff       	jmp    8005c5 <vprintfmt+0x257>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  80074e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800751:	5b                   	pop    %ebx
  800752:	5e                   	pop    %esi
  800753:	5f                   	pop    %edi
  800754:	5d                   	pop    %ebp
  800755:	c3                   	ret    

00800756 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800756:	55                   	push   %ebp
  800757:	89 e5                	mov    %esp,%ebp
  800759:	83 ec 18             	sub    $0x18,%esp
  80075c:	8b 45 08             	mov    0x8(%ebp),%eax
  80075f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800762:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800765:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800769:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80076c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800773:	85 c0                	test   %eax,%eax
  800775:	74 26                	je     80079d <vsnprintf+0x47>
  800777:	85 d2                	test   %edx,%edx
  800779:	7e 29                	jle    8007a4 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80077b:	ff 75 14             	pushl  0x14(%ebp)
  80077e:	ff 75 10             	pushl  0x10(%ebp)
  800781:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800784:	50                   	push   %eax
  800785:	68 35 03 80 00       	push   $0x800335
  80078a:	e8 df fb ff ff       	call   80036e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80078f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800792:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800795:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800798:	83 c4 10             	add    $0x10,%esp
  80079b:	eb 0c                	jmp    8007a9 <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80079d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007a2:	eb 05                	jmp    8007a9 <vsnprintf+0x53>
  8007a4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007a9:	c9                   	leave  
  8007aa:	c3                   	ret    

008007ab <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007ab:	55                   	push   %ebp
  8007ac:	89 e5                	mov    %esp,%ebp
  8007ae:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007b1:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007b4:	50                   	push   %eax
  8007b5:	ff 75 10             	pushl  0x10(%ebp)
  8007b8:	ff 75 0c             	pushl  0xc(%ebp)
  8007bb:	ff 75 08             	pushl  0x8(%ebp)
  8007be:	e8 93 ff ff ff       	call   800756 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007c3:	c9                   	leave  
  8007c4:	c3                   	ret    

008007c5 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007c5:	55                   	push   %ebp
  8007c6:	89 e5                	mov    %esp,%ebp
  8007c8:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007cb:	80 3a 00             	cmpb   $0x0,(%edx)
  8007ce:	74 0e                	je     8007de <strlen+0x19>
  8007d0:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8007d5:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007d6:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007da:	75 f9                	jne    8007d5 <strlen+0x10>
  8007dc:	eb 05                	jmp    8007e3 <strlen+0x1e>
  8007de:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8007e3:	5d                   	pop    %ebp
  8007e4:	c3                   	ret    

008007e5 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007e5:	55                   	push   %ebp
  8007e6:	89 e5                	mov    %esp,%ebp
  8007e8:	53                   	push   %ebx
  8007e9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8007ec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007ef:	85 c9                	test   %ecx,%ecx
  8007f1:	74 1a                	je     80080d <strnlen+0x28>
  8007f3:	80 3b 00             	cmpb   $0x0,(%ebx)
  8007f6:	74 1c                	je     800814 <strnlen+0x2f>
  8007f8:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  8007fd:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007ff:	39 ca                	cmp    %ecx,%edx
  800801:	74 16                	je     800819 <strnlen+0x34>
  800803:	42                   	inc    %edx
  800804:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800809:	75 f2                	jne    8007fd <strnlen+0x18>
  80080b:	eb 0c                	jmp    800819 <strnlen+0x34>
  80080d:	b8 00 00 00 00       	mov    $0x0,%eax
  800812:	eb 05                	jmp    800819 <strnlen+0x34>
  800814:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800819:	5b                   	pop    %ebx
  80081a:	5d                   	pop    %ebp
  80081b:	c3                   	ret    

0080081c <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80081c:	55                   	push   %ebp
  80081d:	89 e5                	mov    %esp,%ebp
  80081f:	53                   	push   %ebx
  800820:	8b 45 08             	mov    0x8(%ebp),%eax
  800823:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800826:	89 c2                	mov    %eax,%edx
  800828:	42                   	inc    %edx
  800829:	41                   	inc    %ecx
  80082a:	8a 59 ff             	mov    -0x1(%ecx),%bl
  80082d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800830:	84 db                	test   %bl,%bl
  800832:	75 f4                	jne    800828 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800834:	5b                   	pop    %ebx
  800835:	5d                   	pop    %ebp
  800836:	c3                   	ret    

00800837 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800837:	55                   	push   %ebp
  800838:	89 e5                	mov    %esp,%ebp
  80083a:	53                   	push   %ebx
  80083b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80083e:	53                   	push   %ebx
  80083f:	e8 81 ff ff ff       	call   8007c5 <strlen>
  800844:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800847:	ff 75 0c             	pushl  0xc(%ebp)
  80084a:	01 d8                	add    %ebx,%eax
  80084c:	50                   	push   %eax
  80084d:	e8 ca ff ff ff       	call   80081c <strcpy>
	return dst;
}
  800852:	89 d8                	mov    %ebx,%eax
  800854:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800857:	c9                   	leave  
  800858:	c3                   	ret    

00800859 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800859:	55                   	push   %ebp
  80085a:	89 e5                	mov    %esp,%ebp
  80085c:	56                   	push   %esi
  80085d:	53                   	push   %ebx
  80085e:	8b 75 08             	mov    0x8(%ebp),%esi
  800861:	8b 55 0c             	mov    0xc(%ebp),%edx
  800864:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800867:	85 db                	test   %ebx,%ebx
  800869:	74 14                	je     80087f <strncpy+0x26>
  80086b:	01 f3                	add    %esi,%ebx
  80086d:	89 f1                	mov    %esi,%ecx
		*dst++ = *src;
  80086f:	41                   	inc    %ecx
  800870:	8a 02                	mov    (%edx),%al
  800872:	88 41 ff             	mov    %al,-0x1(%ecx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800875:	80 3a 01             	cmpb   $0x1,(%edx)
  800878:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80087b:	39 cb                	cmp    %ecx,%ebx
  80087d:	75 f0                	jne    80086f <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80087f:	89 f0                	mov    %esi,%eax
  800881:	5b                   	pop    %ebx
  800882:	5e                   	pop    %esi
  800883:	5d                   	pop    %ebp
  800884:	c3                   	ret    

00800885 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800885:	55                   	push   %ebp
  800886:	89 e5                	mov    %esp,%ebp
  800888:	53                   	push   %ebx
  800889:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80088c:	8b 45 10             	mov    0x10(%ebp),%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80088f:	85 c0                	test   %eax,%eax
  800891:	74 30                	je     8008c3 <strlcpy+0x3e>
		while (--size > 0 && *src != '\0')
  800893:	48                   	dec    %eax
  800894:	74 20                	je     8008b6 <strlcpy+0x31>
  800896:	8a 0b                	mov    (%ebx),%cl
  800898:	84 c9                	test   %cl,%cl
  80089a:	74 1f                	je     8008bb <strlcpy+0x36>
  80089c:	8d 53 01             	lea    0x1(%ebx),%edx
  80089f:	01 c3                	add    %eax,%ebx
  8008a1:	8b 45 08             	mov    0x8(%ebp),%eax
			*dst++ = *src++;
  8008a4:	40                   	inc    %eax
  8008a5:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008a8:	39 da                	cmp    %ebx,%edx
  8008aa:	74 12                	je     8008be <strlcpy+0x39>
  8008ac:	42                   	inc    %edx
  8008ad:	8a 4a ff             	mov    -0x1(%edx),%cl
  8008b0:	84 c9                	test   %cl,%cl
  8008b2:	75 f0                	jne    8008a4 <strlcpy+0x1f>
  8008b4:	eb 08                	jmp    8008be <strlcpy+0x39>
  8008b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b9:	eb 03                	jmp    8008be <strlcpy+0x39>
  8008bb:	8b 45 08             	mov    0x8(%ebp),%eax
			*dst++ = *src++;
		*dst = '\0';
  8008be:	c6 00 00             	movb   $0x0,(%eax)
  8008c1:	eb 03                	jmp    8008c6 <strlcpy+0x41>
  8008c3:	8b 45 08             	mov    0x8(%ebp),%eax
	}
	return dst - dst_in;
  8008c6:	2b 45 08             	sub    0x8(%ebp),%eax
}
  8008c9:	5b                   	pop    %ebx
  8008ca:	5d                   	pop    %ebp
  8008cb:	c3                   	ret    

008008cc <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008cc:	55                   	push   %ebp
  8008cd:	89 e5                	mov    %esp,%ebp
  8008cf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008d2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008d5:	8a 01                	mov    (%ecx),%al
  8008d7:	84 c0                	test   %al,%al
  8008d9:	74 10                	je     8008eb <strcmp+0x1f>
  8008db:	3a 02                	cmp    (%edx),%al
  8008dd:	75 0c                	jne    8008eb <strcmp+0x1f>
		p++, q++;
  8008df:	41                   	inc    %ecx
  8008e0:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008e1:	8a 01                	mov    (%ecx),%al
  8008e3:	84 c0                	test   %al,%al
  8008e5:	74 04                	je     8008eb <strcmp+0x1f>
  8008e7:	3a 02                	cmp    (%edx),%al
  8008e9:	74 f4                	je     8008df <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008eb:	0f b6 c0             	movzbl %al,%eax
  8008ee:	0f b6 12             	movzbl (%edx),%edx
  8008f1:	29 d0                	sub    %edx,%eax
}
  8008f3:	5d                   	pop    %ebp
  8008f4:	c3                   	ret    

008008f5 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008f5:	55                   	push   %ebp
  8008f6:	89 e5                	mov    %esp,%ebp
  8008f8:	56                   	push   %esi
  8008f9:	53                   	push   %ebx
  8008fa:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8008fd:	8b 55 0c             	mov    0xc(%ebp),%edx
  800900:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  800903:	85 f6                	test   %esi,%esi
  800905:	74 23                	je     80092a <strncmp+0x35>
  800907:	8a 03                	mov    (%ebx),%al
  800909:	84 c0                	test   %al,%al
  80090b:	74 2b                	je     800938 <strncmp+0x43>
  80090d:	3a 02                	cmp    (%edx),%al
  80090f:	75 27                	jne    800938 <strncmp+0x43>
  800911:	8d 43 01             	lea    0x1(%ebx),%eax
  800914:	01 de                	add    %ebx,%esi
		n--, p++, q++;
  800916:	89 c3                	mov    %eax,%ebx
  800918:	42                   	inc    %edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800919:	39 c6                	cmp    %eax,%esi
  80091b:	74 14                	je     800931 <strncmp+0x3c>
  80091d:	8a 08                	mov    (%eax),%cl
  80091f:	84 c9                	test   %cl,%cl
  800921:	74 15                	je     800938 <strncmp+0x43>
  800923:	40                   	inc    %eax
  800924:	3a 0a                	cmp    (%edx),%cl
  800926:	74 ee                	je     800916 <strncmp+0x21>
  800928:	eb 0e                	jmp    800938 <strncmp+0x43>
		n--, p++, q++;
	if (n == 0)
		return 0;
  80092a:	b8 00 00 00 00       	mov    $0x0,%eax
  80092f:	eb 0f                	jmp    800940 <strncmp+0x4b>
  800931:	b8 00 00 00 00       	mov    $0x0,%eax
  800936:	eb 08                	jmp    800940 <strncmp+0x4b>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800938:	0f b6 03             	movzbl (%ebx),%eax
  80093b:	0f b6 12             	movzbl (%edx),%edx
  80093e:	29 d0                	sub    %edx,%eax
}
  800940:	5b                   	pop    %ebx
  800941:	5e                   	pop    %esi
  800942:	5d                   	pop    %ebp
  800943:	c3                   	ret    

00800944 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800944:	55                   	push   %ebp
  800945:	89 e5                	mov    %esp,%ebp
  800947:	53                   	push   %ebx
  800948:	8b 45 08             	mov    0x8(%ebp),%eax
  80094b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  80094e:	8a 10                	mov    (%eax),%dl
  800950:	84 d2                	test   %dl,%dl
  800952:	74 1a                	je     80096e <strchr+0x2a>
  800954:	88 d9                	mov    %bl,%cl
		if (*s == c)
  800956:	38 d3                	cmp    %dl,%bl
  800958:	75 06                	jne    800960 <strchr+0x1c>
  80095a:	eb 17                	jmp    800973 <strchr+0x2f>
  80095c:	38 ca                	cmp    %cl,%dl
  80095e:	74 13                	je     800973 <strchr+0x2f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800960:	40                   	inc    %eax
  800961:	8a 10                	mov    (%eax),%dl
  800963:	84 d2                	test   %dl,%dl
  800965:	75 f5                	jne    80095c <strchr+0x18>
		if (*s == c)
			return (char *) s;
	return 0;
  800967:	b8 00 00 00 00       	mov    $0x0,%eax
  80096c:	eb 05                	jmp    800973 <strchr+0x2f>
  80096e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800973:	5b                   	pop    %ebx
  800974:	5d                   	pop    %ebp
  800975:	c3                   	ret    

00800976 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800976:	55                   	push   %ebp
  800977:	89 e5                	mov    %esp,%ebp
  800979:	53                   	push   %ebx
  80097a:	8b 45 08             	mov    0x8(%ebp),%eax
  80097d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  800980:	8a 10                	mov    (%eax),%dl
  800982:	84 d2                	test   %dl,%dl
  800984:	74 13                	je     800999 <strfind+0x23>
  800986:	88 d9                	mov    %bl,%cl
		if (*s == c)
  800988:	38 d3                	cmp    %dl,%bl
  80098a:	75 06                	jne    800992 <strfind+0x1c>
  80098c:	eb 0b                	jmp    800999 <strfind+0x23>
  80098e:	38 ca                	cmp    %cl,%dl
  800990:	74 07                	je     800999 <strfind+0x23>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800992:	40                   	inc    %eax
  800993:	8a 10                	mov    (%eax),%dl
  800995:	84 d2                	test   %dl,%dl
  800997:	75 f5                	jne    80098e <strfind+0x18>
		if (*s == c)
			break;
	return (char *) s;
}
  800999:	5b                   	pop    %ebx
  80099a:	5d                   	pop    %ebp
  80099b:	c3                   	ret    

0080099c <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80099c:	55                   	push   %ebp
  80099d:	89 e5                	mov    %esp,%ebp
  80099f:	57                   	push   %edi
  8009a0:	56                   	push   %esi
  8009a1:	53                   	push   %ebx
  8009a2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009a5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009a8:	85 c9                	test   %ecx,%ecx
  8009aa:	74 36                	je     8009e2 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009ac:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009b2:	75 28                	jne    8009dc <memset+0x40>
  8009b4:	f6 c1 03             	test   $0x3,%cl
  8009b7:	75 23                	jne    8009dc <memset+0x40>
		c &= 0xFF;
  8009b9:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009bd:	89 d3                	mov    %edx,%ebx
  8009bf:	c1 e3 08             	shl    $0x8,%ebx
  8009c2:	89 d6                	mov    %edx,%esi
  8009c4:	c1 e6 18             	shl    $0x18,%esi
  8009c7:	89 d0                	mov    %edx,%eax
  8009c9:	c1 e0 10             	shl    $0x10,%eax
  8009cc:	09 f0                	or     %esi,%eax
  8009ce:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8009d0:	89 d8                	mov    %ebx,%eax
  8009d2:	09 d0                	or     %edx,%eax
  8009d4:	c1 e9 02             	shr    $0x2,%ecx
  8009d7:	fc                   	cld    
  8009d8:	f3 ab                	rep stos %eax,%es:(%edi)
  8009da:	eb 06                	jmp    8009e2 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009dc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009df:	fc                   	cld    
  8009e0:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009e2:	89 f8                	mov    %edi,%eax
  8009e4:	5b                   	pop    %ebx
  8009e5:	5e                   	pop    %esi
  8009e6:	5f                   	pop    %edi
  8009e7:	5d                   	pop    %ebp
  8009e8:	c3                   	ret    

008009e9 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009e9:	55                   	push   %ebp
  8009ea:	89 e5                	mov    %esp,%ebp
  8009ec:	57                   	push   %edi
  8009ed:	56                   	push   %esi
  8009ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f1:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009f4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009f7:	39 c6                	cmp    %eax,%esi
  8009f9:	73 33                	jae    800a2e <memmove+0x45>
  8009fb:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009fe:	39 d0                	cmp    %edx,%eax
  800a00:	73 2c                	jae    800a2e <memmove+0x45>
		s += n;
		d += n;
  800a02:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a05:	89 d6                	mov    %edx,%esi
  800a07:	09 fe                	or     %edi,%esi
  800a09:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a0f:	75 13                	jne    800a24 <memmove+0x3b>
  800a11:	f6 c1 03             	test   $0x3,%cl
  800a14:	75 0e                	jne    800a24 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800a16:	83 ef 04             	sub    $0x4,%edi
  800a19:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a1c:	c1 e9 02             	shr    $0x2,%ecx
  800a1f:	fd                   	std    
  800a20:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a22:	eb 07                	jmp    800a2b <memmove+0x42>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a24:	4f                   	dec    %edi
  800a25:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a28:	fd                   	std    
  800a29:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a2b:	fc                   	cld    
  800a2c:	eb 1d                	jmp    800a4b <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a2e:	89 f2                	mov    %esi,%edx
  800a30:	09 c2                	or     %eax,%edx
  800a32:	f6 c2 03             	test   $0x3,%dl
  800a35:	75 0f                	jne    800a46 <memmove+0x5d>
  800a37:	f6 c1 03             	test   $0x3,%cl
  800a3a:	75 0a                	jne    800a46 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
  800a3c:	c1 e9 02             	shr    $0x2,%ecx
  800a3f:	89 c7                	mov    %eax,%edi
  800a41:	fc                   	cld    
  800a42:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a44:	eb 05                	jmp    800a4b <memmove+0x62>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a46:	89 c7                	mov    %eax,%edi
  800a48:	fc                   	cld    
  800a49:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a4b:	5e                   	pop    %esi
  800a4c:	5f                   	pop    %edi
  800a4d:	5d                   	pop    %ebp
  800a4e:	c3                   	ret    

00800a4f <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a4f:	55                   	push   %ebp
  800a50:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a52:	ff 75 10             	pushl  0x10(%ebp)
  800a55:	ff 75 0c             	pushl  0xc(%ebp)
  800a58:	ff 75 08             	pushl  0x8(%ebp)
  800a5b:	e8 89 ff ff ff       	call   8009e9 <memmove>
}
  800a60:	c9                   	leave  
  800a61:	c3                   	ret    

00800a62 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a62:	55                   	push   %ebp
  800a63:	89 e5                	mov    %esp,%ebp
  800a65:	57                   	push   %edi
  800a66:	56                   	push   %esi
  800a67:	53                   	push   %ebx
  800a68:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800a6b:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a6e:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a71:	85 c0                	test   %eax,%eax
  800a73:	74 33                	je     800aa8 <memcmp+0x46>
  800a75:	8d 78 ff             	lea    -0x1(%eax),%edi
		if (*s1 != *s2)
  800a78:	8a 13                	mov    (%ebx),%dl
  800a7a:	8a 0e                	mov    (%esi),%cl
  800a7c:	38 ca                	cmp    %cl,%dl
  800a7e:	75 13                	jne    800a93 <memcmp+0x31>
  800a80:	b8 00 00 00 00       	mov    $0x0,%eax
  800a85:	eb 16                	jmp    800a9d <memcmp+0x3b>
  800a87:	8a 54 03 01          	mov    0x1(%ebx,%eax,1),%dl
  800a8b:	40                   	inc    %eax
  800a8c:	8a 0c 06             	mov    (%esi,%eax,1),%cl
  800a8f:	38 ca                	cmp    %cl,%dl
  800a91:	74 0a                	je     800a9d <memcmp+0x3b>
			return (int) *s1 - (int) *s2;
  800a93:	0f b6 c2             	movzbl %dl,%eax
  800a96:	0f b6 c9             	movzbl %cl,%ecx
  800a99:	29 c8                	sub    %ecx,%eax
  800a9b:	eb 10                	jmp    800aad <memcmp+0x4b>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a9d:	39 f8                	cmp    %edi,%eax
  800a9f:	75 e6                	jne    800a87 <memcmp+0x25>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800aa1:	b8 00 00 00 00       	mov    $0x0,%eax
  800aa6:	eb 05                	jmp    800aad <memcmp+0x4b>
  800aa8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800aad:	5b                   	pop    %ebx
  800aae:	5e                   	pop    %esi
  800aaf:	5f                   	pop    %edi
  800ab0:	5d                   	pop    %ebp
  800ab1:	c3                   	ret    

00800ab2 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ab2:	55                   	push   %ebp
  800ab3:	89 e5                	mov    %esp,%ebp
  800ab5:	53                   	push   %ebx
  800ab6:	8b 55 08             	mov    0x8(%ebp),%edx
	const void *ends = (const char *) s + n;
  800ab9:	89 d0                	mov    %edx,%eax
  800abb:	03 45 10             	add    0x10(%ebp),%eax
	for (; s < ends; s++)
  800abe:	39 c2                	cmp    %eax,%edx
  800ac0:	73 1b                	jae    800add <memfind+0x2b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ac2:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
  800ac6:	0f b6 0a             	movzbl (%edx),%ecx
  800ac9:	39 d9                	cmp    %ebx,%ecx
  800acb:	75 09                	jne    800ad6 <memfind+0x24>
  800acd:	eb 12                	jmp    800ae1 <memfind+0x2f>
  800acf:	0f b6 0a             	movzbl (%edx),%ecx
  800ad2:	39 d9                	cmp    %ebx,%ecx
  800ad4:	74 0f                	je     800ae5 <memfind+0x33>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ad6:	42                   	inc    %edx
  800ad7:	39 d0                	cmp    %edx,%eax
  800ad9:	75 f4                	jne    800acf <memfind+0x1d>
  800adb:	eb 0a                	jmp    800ae7 <memfind+0x35>
  800add:	89 d0                	mov    %edx,%eax
  800adf:	eb 06                	jmp    800ae7 <memfind+0x35>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ae1:	89 d0                	mov    %edx,%eax
  800ae3:	eb 02                	jmp    800ae7 <memfind+0x35>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ae5:	89 d0                	mov    %edx,%eax
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ae7:	5b                   	pop    %ebx
  800ae8:	5d                   	pop    %ebp
  800ae9:	c3                   	ret    

00800aea <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800aea:	55                   	push   %ebp
  800aeb:	89 e5                	mov    %esp,%ebp
  800aed:	57                   	push   %edi
  800aee:	56                   	push   %esi
  800aef:	53                   	push   %ebx
  800af0:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800af3:	eb 01                	jmp    800af6 <strtol+0xc>
		s++;
  800af5:	41                   	inc    %ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800af6:	8a 01                	mov    (%ecx),%al
  800af8:	3c 20                	cmp    $0x20,%al
  800afa:	74 f9                	je     800af5 <strtol+0xb>
  800afc:	3c 09                	cmp    $0x9,%al
  800afe:	74 f5                	je     800af5 <strtol+0xb>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b00:	3c 2b                	cmp    $0x2b,%al
  800b02:	75 08                	jne    800b0c <strtol+0x22>
		s++;
  800b04:	41                   	inc    %ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b05:	bf 00 00 00 00       	mov    $0x0,%edi
  800b0a:	eb 11                	jmp    800b1d <strtol+0x33>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b0c:	3c 2d                	cmp    $0x2d,%al
  800b0e:	75 08                	jne    800b18 <strtol+0x2e>
		s++, neg = 1;
  800b10:	41                   	inc    %ecx
  800b11:	bf 01 00 00 00       	mov    $0x1,%edi
  800b16:	eb 05                	jmp    800b1d <strtol+0x33>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b18:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b1d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800b21:	0f 84 87 00 00 00    	je     800bae <strtol+0xc4>
  800b27:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  800b2b:	75 27                	jne    800b54 <strtol+0x6a>
  800b2d:	80 39 30             	cmpb   $0x30,(%ecx)
  800b30:	75 22                	jne    800b54 <strtol+0x6a>
  800b32:	e9 88 00 00 00       	jmp    800bbf <strtol+0xd5>
		s += 2, base = 16;
  800b37:	83 c1 02             	add    $0x2,%ecx
  800b3a:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  800b41:	eb 11                	jmp    800b54 <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
  800b43:	41                   	inc    %ecx
  800b44:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  800b4b:	eb 07                	jmp    800b54 <strtol+0x6a>
	else if (base == 0)
		base = 10;
  800b4d:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)
  800b54:	b8 00 00 00 00       	mov    $0x0,%eax

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b59:	8a 11                	mov    (%ecx),%dl
  800b5b:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800b5e:	80 fb 09             	cmp    $0x9,%bl
  800b61:	77 08                	ja     800b6b <strtol+0x81>
			dig = *s - '0';
  800b63:	0f be d2             	movsbl %dl,%edx
  800b66:	83 ea 30             	sub    $0x30,%edx
  800b69:	eb 22                	jmp    800b8d <strtol+0xa3>
		else if (*s >= 'a' && *s <= 'z')
  800b6b:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b6e:	89 f3                	mov    %esi,%ebx
  800b70:	80 fb 19             	cmp    $0x19,%bl
  800b73:	77 08                	ja     800b7d <strtol+0x93>
			dig = *s - 'a' + 10;
  800b75:	0f be d2             	movsbl %dl,%edx
  800b78:	83 ea 57             	sub    $0x57,%edx
  800b7b:	eb 10                	jmp    800b8d <strtol+0xa3>
		else if (*s >= 'A' && *s <= 'Z')
  800b7d:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b80:	89 f3                	mov    %esi,%ebx
  800b82:	80 fb 19             	cmp    $0x19,%bl
  800b85:	77 14                	ja     800b9b <strtol+0xb1>
			dig = *s - 'A' + 10;
  800b87:	0f be d2             	movsbl %dl,%edx
  800b8a:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b8d:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b90:	7d 09                	jge    800b9b <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800b92:	41                   	inc    %ecx
  800b93:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b97:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b99:	eb be                	jmp    800b59 <strtol+0x6f>

	if (endptr)
  800b9b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b9f:	74 05                	je     800ba6 <strtol+0xbc>
		*endptr = (char *) s;
  800ba1:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ba4:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800ba6:	85 ff                	test   %edi,%edi
  800ba8:	74 21                	je     800bcb <strtol+0xe1>
  800baa:	f7 d8                	neg    %eax
  800bac:	eb 1d                	jmp    800bcb <strtol+0xe1>
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bae:	80 39 30             	cmpb   $0x30,(%ecx)
  800bb1:	75 9a                	jne    800b4d <strtol+0x63>
  800bb3:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800bb7:	0f 84 7a ff ff ff    	je     800b37 <strtol+0x4d>
  800bbd:	eb 84                	jmp    800b43 <strtol+0x59>
  800bbf:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800bc3:	0f 84 6e ff ff ff    	je     800b37 <strtol+0x4d>
  800bc9:	eb 89                	jmp    800b54 <strtol+0x6a>
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
}
  800bcb:	5b                   	pop    %ebx
  800bcc:	5e                   	pop    %esi
  800bcd:	5f                   	pop    %edi
  800bce:	5d                   	pop    %ebp
  800bcf:	c3                   	ret    

00800bd0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800bd0:	55                   	push   %ebp
  800bd1:	89 e5                	mov    %esp,%ebp
  800bd3:	57                   	push   %edi
  800bd4:	56                   	push   %esi
  800bd5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bd6:	b8 00 00 00 00       	mov    $0x0,%eax
  800bdb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bde:	8b 55 08             	mov    0x8(%ebp),%edx
  800be1:	89 c3                	mov    %eax,%ebx
  800be3:	89 c7                	mov    %eax,%edi
  800be5:	89 c6                	mov    %eax,%esi
  800be7:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800be9:	5b                   	pop    %ebx
  800bea:	5e                   	pop    %esi
  800beb:	5f                   	pop    %edi
  800bec:	5d                   	pop    %ebp
  800bed:	c3                   	ret    

00800bee <sys_cgetc>:

int
sys_cgetc(void)
{
  800bee:	55                   	push   %ebp
  800bef:	89 e5                	mov    %esp,%ebp
  800bf1:	57                   	push   %edi
  800bf2:	56                   	push   %esi
  800bf3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bf4:	ba 00 00 00 00       	mov    $0x0,%edx
  800bf9:	b8 01 00 00 00       	mov    $0x1,%eax
  800bfe:	89 d1                	mov    %edx,%ecx
  800c00:	89 d3                	mov    %edx,%ebx
  800c02:	89 d7                	mov    %edx,%edi
  800c04:	89 d6                	mov    %edx,%esi
  800c06:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c08:	5b                   	pop    %ebx
  800c09:	5e                   	pop    %esi
  800c0a:	5f                   	pop    %edi
  800c0b:	5d                   	pop    %ebp
  800c0c:	c3                   	ret    

00800c0d <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c0d:	55                   	push   %ebp
  800c0e:	89 e5                	mov    %esp,%ebp
  800c10:	57                   	push   %edi
  800c11:	56                   	push   %esi
  800c12:	53                   	push   %ebx
  800c13:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c16:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c1b:	b8 03 00 00 00       	mov    $0x3,%eax
  800c20:	8b 55 08             	mov    0x8(%ebp),%edx
  800c23:	89 cb                	mov    %ecx,%ebx
  800c25:	89 cf                	mov    %ecx,%edi
  800c27:	89 ce                	mov    %ecx,%esi
  800c29:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c2b:	85 c0                	test   %eax,%eax
  800c2d:	7e 17                	jle    800c46 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c2f:	83 ec 0c             	sub    $0xc,%esp
  800c32:	50                   	push   %eax
  800c33:	6a 03                	push   $0x3
  800c35:	68 df 22 80 00       	push   $0x8022df
  800c3a:	6a 23                	push   $0x23
  800c3c:	68 fc 22 80 00       	push   $0x8022fc
  800c41:	e8 19 f5 ff ff       	call   80015f <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c46:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c49:	5b                   	pop    %ebx
  800c4a:	5e                   	pop    %esi
  800c4b:	5f                   	pop    %edi
  800c4c:	5d                   	pop    %ebp
  800c4d:	c3                   	ret    

00800c4e <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c4e:	55                   	push   %ebp
  800c4f:	89 e5                	mov    %esp,%ebp
  800c51:	57                   	push   %edi
  800c52:	56                   	push   %esi
  800c53:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c54:	ba 00 00 00 00       	mov    $0x0,%edx
  800c59:	b8 02 00 00 00       	mov    $0x2,%eax
  800c5e:	89 d1                	mov    %edx,%ecx
  800c60:	89 d3                	mov    %edx,%ebx
  800c62:	89 d7                	mov    %edx,%edi
  800c64:	89 d6                	mov    %edx,%esi
  800c66:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c68:	5b                   	pop    %ebx
  800c69:	5e                   	pop    %esi
  800c6a:	5f                   	pop    %edi
  800c6b:	5d                   	pop    %ebp
  800c6c:	c3                   	ret    

00800c6d <sys_yield>:

void
sys_yield(void)
{
  800c6d:	55                   	push   %ebp
  800c6e:	89 e5                	mov    %esp,%ebp
  800c70:	57                   	push   %edi
  800c71:	56                   	push   %esi
  800c72:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c73:	ba 00 00 00 00       	mov    $0x0,%edx
  800c78:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c7d:	89 d1                	mov    %edx,%ecx
  800c7f:	89 d3                	mov    %edx,%ebx
  800c81:	89 d7                	mov    %edx,%edi
  800c83:	89 d6                	mov    %edx,%esi
  800c85:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c87:	5b                   	pop    %ebx
  800c88:	5e                   	pop    %esi
  800c89:	5f                   	pop    %edi
  800c8a:	5d                   	pop    %ebp
  800c8b:	c3                   	ret    

00800c8c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c8c:	55                   	push   %ebp
  800c8d:	89 e5                	mov    %esp,%ebp
  800c8f:	57                   	push   %edi
  800c90:	56                   	push   %esi
  800c91:	53                   	push   %ebx
  800c92:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c95:	be 00 00 00 00       	mov    $0x0,%esi
  800c9a:	b8 04 00 00 00       	mov    $0x4,%eax
  800c9f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ca8:	89 f7                	mov    %esi,%edi
  800caa:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cac:	85 c0                	test   %eax,%eax
  800cae:	7e 17                	jle    800cc7 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb0:	83 ec 0c             	sub    $0xc,%esp
  800cb3:	50                   	push   %eax
  800cb4:	6a 04                	push   $0x4
  800cb6:	68 df 22 80 00       	push   $0x8022df
  800cbb:	6a 23                	push   $0x23
  800cbd:	68 fc 22 80 00       	push   $0x8022fc
  800cc2:	e8 98 f4 ff ff       	call   80015f <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800cc7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cca:	5b                   	pop    %ebx
  800ccb:	5e                   	pop    %esi
  800ccc:	5f                   	pop    %edi
  800ccd:	5d                   	pop    %ebp
  800cce:	c3                   	ret    

00800ccf <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ccf:	55                   	push   %ebp
  800cd0:	89 e5                	mov    %esp,%ebp
  800cd2:	57                   	push   %edi
  800cd3:	56                   	push   %esi
  800cd4:	53                   	push   %ebx
  800cd5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cd8:	b8 05 00 00 00       	mov    $0x5,%eax
  800cdd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ce6:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ce9:	8b 75 18             	mov    0x18(%ebp),%esi
  800cec:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cee:	85 c0                	test   %eax,%eax
  800cf0:	7e 17                	jle    800d09 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cf2:	83 ec 0c             	sub    $0xc,%esp
  800cf5:	50                   	push   %eax
  800cf6:	6a 05                	push   $0x5
  800cf8:	68 df 22 80 00       	push   $0x8022df
  800cfd:	6a 23                	push   $0x23
  800cff:	68 fc 22 80 00       	push   $0x8022fc
  800d04:	e8 56 f4 ff ff       	call   80015f <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d09:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d0c:	5b                   	pop    %ebx
  800d0d:	5e                   	pop    %esi
  800d0e:	5f                   	pop    %edi
  800d0f:	5d                   	pop    %ebp
  800d10:	c3                   	ret    

00800d11 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d11:	55                   	push   %ebp
  800d12:	89 e5                	mov    %esp,%ebp
  800d14:	57                   	push   %edi
  800d15:	56                   	push   %esi
  800d16:	53                   	push   %ebx
  800d17:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d1a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d1f:	b8 06 00 00 00       	mov    $0x6,%eax
  800d24:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d27:	8b 55 08             	mov    0x8(%ebp),%edx
  800d2a:	89 df                	mov    %ebx,%edi
  800d2c:	89 de                	mov    %ebx,%esi
  800d2e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d30:	85 c0                	test   %eax,%eax
  800d32:	7e 17                	jle    800d4b <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d34:	83 ec 0c             	sub    $0xc,%esp
  800d37:	50                   	push   %eax
  800d38:	6a 06                	push   $0x6
  800d3a:	68 df 22 80 00       	push   $0x8022df
  800d3f:	6a 23                	push   $0x23
  800d41:	68 fc 22 80 00       	push   $0x8022fc
  800d46:	e8 14 f4 ff ff       	call   80015f <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d4b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d4e:	5b                   	pop    %ebx
  800d4f:	5e                   	pop    %esi
  800d50:	5f                   	pop    %edi
  800d51:	5d                   	pop    %ebp
  800d52:	c3                   	ret    

00800d53 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d53:	55                   	push   %ebp
  800d54:	89 e5                	mov    %esp,%ebp
  800d56:	57                   	push   %edi
  800d57:	56                   	push   %esi
  800d58:	53                   	push   %ebx
  800d59:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d5c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d61:	b8 08 00 00 00       	mov    $0x8,%eax
  800d66:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d69:	8b 55 08             	mov    0x8(%ebp),%edx
  800d6c:	89 df                	mov    %ebx,%edi
  800d6e:	89 de                	mov    %ebx,%esi
  800d70:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d72:	85 c0                	test   %eax,%eax
  800d74:	7e 17                	jle    800d8d <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d76:	83 ec 0c             	sub    $0xc,%esp
  800d79:	50                   	push   %eax
  800d7a:	6a 08                	push   $0x8
  800d7c:	68 df 22 80 00       	push   $0x8022df
  800d81:	6a 23                	push   $0x23
  800d83:	68 fc 22 80 00       	push   $0x8022fc
  800d88:	e8 d2 f3 ff ff       	call   80015f <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d8d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d90:	5b                   	pop    %ebx
  800d91:	5e                   	pop    %esi
  800d92:	5f                   	pop    %edi
  800d93:	5d                   	pop    %ebp
  800d94:	c3                   	ret    

00800d95 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d95:	55                   	push   %ebp
  800d96:	89 e5                	mov    %esp,%ebp
  800d98:	57                   	push   %edi
  800d99:	56                   	push   %esi
  800d9a:	53                   	push   %ebx
  800d9b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d9e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800da3:	b8 09 00 00 00       	mov    $0x9,%eax
  800da8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dab:	8b 55 08             	mov    0x8(%ebp),%edx
  800dae:	89 df                	mov    %ebx,%edi
  800db0:	89 de                	mov    %ebx,%esi
  800db2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800db4:	85 c0                	test   %eax,%eax
  800db6:	7e 17                	jle    800dcf <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800db8:	83 ec 0c             	sub    $0xc,%esp
  800dbb:	50                   	push   %eax
  800dbc:	6a 09                	push   $0x9
  800dbe:	68 df 22 80 00       	push   $0x8022df
  800dc3:	6a 23                	push   $0x23
  800dc5:	68 fc 22 80 00       	push   $0x8022fc
  800dca:	e8 90 f3 ff ff       	call   80015f <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800dcf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dd2:	5b                   	pop    %ebx
  800dd3:	5e                   	pop    %esi
  800dd4:	5f                   	pop    %edi
  800dd5:	5d                   	pop    %ebp
  800dd6:	c3                   	ret    

00800dd7 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800dd7:	55                   	push   %ebp
  800dd8:	89 e5                	mov    %esp,%ebp
  800dda:	57                   	push   %edi
  800ddb:	56                   	push   %esi
  800ddc:	53                   	push   %ebx
  800ddd:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800de0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800de5:	b8 0a 00 00 00       	mov    $0xa,%eax
  800dea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ded:	8b 55 08             	mov    0x8(%ebp),%edx
  800df0:	89 df                	mov    %ebx,%edi
  800df2:	89 de                	mov    %ebx,%esi
  800df4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800df6:	85 c0                	test   %eax,%eax
  800df8:	7e 17                	jle    800e11 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dfa:	83 ec 0c             	sub    $0xc,%esp
  800dfd:	50                   	push   %eax
  800dfe:	6a 0a                	push   $0xa
  800e00:	68 df 22 80 00       	push   $0x8022df
  800e05:	6a 23                	push   $0x23
  800e07:	68 fc 22 80 00       	push   $0x8022fc
  800e0c:	e8 4e f3 ff ff       	call   80015f <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e11:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e14:	5b                   	pop    %ebx
  800e15:	5e                   	pop    %esi
  800e16:	5f                   	pop    %edi
  800e17:	5d                   	pop    %ebp
  800e18:	c3                   	ret    

00800e19 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e19:	55                   	push   %ebp
  800e1a:	89 e5                	mov    %esp,%ebp
  800e1c:	57                   	push   %edi
  800e1d:	56                   	push   %esi
  800e1e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e1f:	be 00 00 00 00       	mov    $0x0,%esi
  800e24:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e29:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e2c:	8b 55 08             	mov    0x8(%ebp),%edx
  800e2f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e32:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e35:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e37:	5b                   	pop    %ebx
  800e38:	5e                   	pop    %esi
  800e39:	5f                   	pop    %edi
  800e3a:	5d                   	pop    %ebp
  800e3b:	c3                   	ret    

00800e3c <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e3c:	55                   	push   %ebp
  800e3d:	89 e5                	mov    %esp,%ebp
  800e3f:	57                   	push   %edi
  800e40:	56                   	push   %esi
  800e41:	53                   	push   %ebx
  800e42:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e45:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e4a:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e4f:	8b 55 08             	mov    0x8(%ebp),%edx
  800e52:	89 cb                	mov    %ecx,%ebx
  800e54:	89 cf                	mov    %ecx,%edi
  800e56:	89 ce                	mov    %ecx,%esi
  800e58:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e5a:	85 c0                	test   %eax,%eax
  800e5c:	7e 17                	jle    800e75 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e5e:	83 ec 0c             	sub    $0xc,%esp
  800e61:	50                   	push   %eax
  800e62:	6a 0d                	push   $0xd
  800e64:	68 df 22 80 00       	push   $0x8022df
  800e69:	6a 23                	push   $0x23
  800e6b:	68 fc 22 80 00       	push   $0x8022fc
  800e70:	e8 ea f2 ff ff       	call   80015f <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e75:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e78:	5b                   	pop    %ebx
  800e79:	5e                   	pop    %esi
  800e7a:	5f                   	pop    %edi
  800e7b:	5d                   	pop    %ebp
  800e7c:	c3                   	ret    

00800e7d <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e7d:	55                   	push   %ebp
  800e7e:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e80:	8b 45 08             	mov    0x8(%ebp),%eax
  800e83:	05 00 00 00 30       	add    $0x30000000,%eax
  800e88:	c1 e8 0c             	shr    $0xc,%eax
}
  800e8b:	5d                   	pop    %ebp
  800e8c:	c3                   	ret    

00800e8d <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e8d:	55                   	push   %ebp
  800e8e:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800e90:	8b 45 08             	mov    0x8(%ebp),%eax
  800e93:	05 00 00 00 30       	add    $0x30000000,%eax
  800e98:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e9d:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800ea2:	5d                   	pop    %ebp
  800ea3:	c3                   	ret    

00800ea4 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800ea4:	55                   	push   %ebp
  800ea5:	89 e5                	mov    %esp,%ebp
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800ea7:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  800eac:	a8 01                	test   $0x1,%al
  800eae:	74 34                	je     800ee4 <fd_alloc+0x40>
  800eb0:	a1 00 00 74 ef       	mov    0xef740000,%eax
  800eb5:	a8 01                	test   $0x1,%al
  800eb7:	74 32                	je     800eeb <fd_alloc+0x47>
  800eb9:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800ebe:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800ec0:	89 c2                	mov    %eax,%edx
  800ec2:	c1 ea 16             	shr    $0x16,%edx
  800ec5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ecc:	f6 c2 01             	test   $0x1,%dl
  800ecf:	74 1f                	je     800ef0 <fd_alloc+0x4c>
  800ed1:	89 c2                	mov    %eax,%edx
  800ed3:	c1 ea 0c             	shr    $0xc,%edx
  800ed6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800edd:	f6 c2 01             	test   $0x1,%dl
  800ee0:	75 1a                	jne    800efc <fd_alloc+0x58>
  800ee2:	eb 0c                	jmp    800ef0 <fd_alloc+0x4c>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800ee4:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  800ee9:	eb 05                	jmp    800ef0 <fd_alloc+0x4c>
  800eeb:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  800ef0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ef3:	89 08                	mov    %ecx,(%eax)
			return 0;
  800ef5:	b8 00 00 00 00       	mov    $0x0,%eax
  800efa:	eb 1a                	jmp    800f16 <fd_alloc+0x72>
  800efc:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800f01:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800f06:	75 b6                	jne    800ebe <fd_alloc+0x1a>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800f08:	8b 45 08             	mov    0x8(%ebp),%eax
  800f0b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  800f11:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800f16:	5d                   	pop    %ebp
  800f17:	c3                   	ret    

00800f18 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800f18:	55                   	push   %ebp
  800f19:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800f1b:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
  800f1f:	77 39                	ja     800f5a <fd_lookup+0x42>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800f21:	8b 45 08             	mov    0x8(%ebp),%eax
  800f24:	c1 e0 0c             	shl    $0xc,%eax
  800f27:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800f2c:	89 c2                	mov    %eax,%edx
  800f2e:	c1 ea 16             	shr    $0x16,%edx
  800f31:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f38:	f6 c2 01             	test   $0x1,%dl
  800f3b:	74 24                	je     800f61 <fd_lookup+0x49>
  800f3d:	89 c2                	mov    %eax,%edx
  800f3f:	c1 ea 0c             	shr    $0xc,%edx
  800f42:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f49:	f6 c2 01             	test   $0x1,%dl
  800f4c:	74 1a                	je     800f68 <fd_lookup+0x50>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800f4e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f51:	89 02                	mov    %eax,(%edx)
	return 0;
  800f53:	b8 00 00 00 00       	mov    $0x0,%eax
  800f58:	eb 13                	jmp    800f6d <fd_lookup+0x55>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f5a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f5f:	eb 0c                	jmp    800f6d <fd_lookup+0x55>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f61:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f66:	eb 05                	jmp    800f6d <fd_lookup+0x55>
  800f68:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800f6d:	5d                   	pop    %ebp
  800f6e:	c3                   	ret    

00800f6f <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f6f:	55                   	push   %ebp
  800f70:	89 e5                	mov    %esp,%ebp
  800f72:	53                   	push   %ebx
  800f73:	83 ec 04             	sub    $0x4,%esp
  800f76:	8b 45 08             	mov    0x8(%ebp),%eax
  800f79:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  800f7c:	3b 05 04 30 80 00    	cmp    0x803004,%eax
  800f82:	75 1e                	jne    800fa2 <dev_lookup+0x33>
  800f84:	eb 0e                	jmp    800f94 <dev_lookup+0x25>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f86:	b8 20 30 80 00       	mov    $0x803020,%eax
  800f8b:	eb 0c                	jmp    800f99 <dev_lookup+0x2a>
  800f8d:	b8 3c 30 80 00       	mov    $0x80303c,%eax
  800f92:	eb 05                	jmp    800f99 <dev_lookup+0x2a>
  800f94:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  800f99:	89 03                	mov    %eax,(%ebx)
			return 0;
  800f9b:	b8 00 00 00 00       	mov    $0x0,%eax
  800fa0:	eb 36                	jmp    800fd8 <dev_lookup+0x69>
int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  800fa2:	3b 05 20 30 80 00    	cmp    0x803020,%eax
  800fa8:	74 dc                	je     800f86 <dev_lookup+0x17>
  800faa:	3b 05 3c 30 80 00    	cmp    0x80303c,%eax
  800fb0:	74 db                	je     800f8d <dev_lookup+0x1e>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800fb2:	8b 15 20 40 c0 00    	mov    0xc04020,%edx
  800fb8:	8b 52 48             	mov    0x48(%edx),%edx
  800fbb:	83 ec 04             	sub    $0x4,%esp
  800fbe:	50                   	push   %eax
  800fbf:	52                   	push   %edx
  800fc0:	68 0c 23 80 00       	push   $0x80230c
  800fc5:	e8 6d f2 ff ff       	call   800237 <cprintf>
	*dev = 0;
  800fca:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  800fd0:	83 c4 10             	add    $0x10,%esp
  800fd3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800fd8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fdb:	c9                   	leave  
  800fdc:	c3                   	ret    

00800fdd <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800fdd:	55                   	push   %ebp
  800fde:	89 e5                	mov    %esp,%ebp
  800fe0:	56                   	push   %esi
  800fe1:	53                   	push   %ebx
  800fe2:	83 ec 10             	sub    $0x10,%esp
  800fe5:	8b 75 08             	mov    0x8(%ebp),%esi
  800fe8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800feb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fee:	50                   	push   %eax
  800fef:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800ff5:	c1 e8 0c             	shr    $0xc,%eax
  800ff8:	50                   	push   %eax
  800ff9:	e8 1a ff ff ff       	call   800f18 <fd_lookup>
  800ffe:	83 c4 08             	add    $0x8,%esp
  801001:	85 c0                	test   %eax,%eax
  801003:	78 05                	js     80100a <fd_close+0x2d>
	    || fd != fd2)
  801005:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801008:	74 06                	je     801010 <fd_close+0x33>
		return (must_exist ? r : 0);
  80100a:	84 db                	test   %bl,%bl
  80100c:	74 47                	je     801055 <fd_close+0x78>
  80100e:	eb 4a                	jmp    80105a <fd_close+0x7d>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801010:	83 ec 08             	sub    $0x8,%esp
  801013:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801016:	50                   	push   %eax
  801017:	ff 36                	pushl  (%esi)
  801019:	e8 51 ff ff ff       	call   800f6f <dev_lookup>
  80101e:	89 c3                	mov    %eax,%ebx
  801020:	83 c4 10             	add    $0x10,%esp
  801023:	85 c0                	test   %eax,%eax
  801025:	78 1c                	js     801043 <fd_close+0x66>
		if (dev->dev_close)
  801027:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80102a:	8b 40 10             	mov    0x10(%eax),%eax
  80102d:	85 c0                	test   %eax,%eax
  80102f:	74 0d                	je     80103e <fd_close+0x61>
			r = (*dev->dev_close)(fd);
  801031:	83 ec 0c             	sub    $0xc,%esp
  801034:	56                   	push   %esi
  801035:	ff d0                	call   *%eax
  801037:	89 c3                	mov    %eax,%ebx
  801039:	83 c4 10             	add    $0x10,%esp
  80103c:	eb 05                	jmp    801043 <fd_close+0x66>
		else
			r = 0;
  80103e:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801043:	83 ec 08             	sub    $0x8,%esp
  801046:	56                   	push   %esi
  801047:	6a 00                	push   $0x0
  801049:	e8 c3 fc ff ff       	call   800d11 <sys_page_unmap>
	return r;
  80104e:	83 c4 10             	add    $0x10,%esp
  801051:	89 d8                	mov    %ebx,%eax
  801053:	eb 05                	jmp    80105a <fd_close+0x7d>
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
  801055:	b8 00 00 00 00       	mov    $0x0,%eax
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
	return r;
}
  80105a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80105d:	5b                   	pop    %ebx
  80105e:	5e                   	pop    %esi
  80105f:	5d                   	pop    %ebp
  801060:	c3                   	ret    

00801061 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801061:	55                   	push   %ebp
  801062:	89 e5                	mov    %esp,%ebp
  801064:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801067:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80106a:	50                   	push   %eax
  80106b:	ff 75 08             	pushl  0x8(%ebp)
  80106e:	e8 a5 fe ff ff       	call   800f18 <fd_lookup>
  801073:	83 c4 08             	add    $0x8,%esp
  801076:	85 c0                	test   %eax,%eax
  801078:	78 10                	js     80108a <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80107a:	83 ec 08             	sub    $0x8,%esp
  80107d:	6a 01                	push   $0x1
  80107f:	ff 75 f4             	pushl  -0xc(%ebp)
  801082:	e8 56 ff ff ff       	call   800fdd <fd_close>
  801087:	83 c4 10             	add    $0x10,%esp
}
  80108a:	c9                   	leave  
  80108b:	c3                   	ret    

0080108c <close_all>:

void
close_all(void)
{
  80108c:	55                   	push   %ebp
  80108d:	89 e5                	mov    %esp,%ebp
  80108f:	53                   	push   %ebx
  801090:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801093:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801098:	83 ec 0c             	sub    $0xc,%esp
  80109b:	53                   	push   %ebx
  80109c:	e8 c0 ff ff ff       	call   801061 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8010a1:	43                   	inc    %ebx
  8010a2:	83 c4 10             	add    $0x10,%esp
  8010a5:	83 fb 20             	cmp    $0x20,%ebx
  8010a8:	75 ee                	jne    801098 <close_all+0xc>
		close(i);
}
  8010aa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010ad:	c9                   	leave  
  8010ae:	c3                   	ret    

008010af <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8010af:	55                   	push   %ebp
  8010b0:	89 e5                	mov    %esp,%ebp
  8010b2:	57                   	push   %edi
  8010b3:	56                   	push   %esi
  8010b4:	53                   	push   %ebx
  8010b5:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8010b8:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8010bb:	50                   	push   %eax
  8010bc:	ff 75 08             	pushl  0x8(%ebp)
  8010bf:	e8 54 fe ff ff       	call   800f18 <fd_lookup>
  8010c4:	83 c4 08             	add    $0x8,%esp
  8010c7:	85 c0                	test   %eax,%eax
  8010c9:	0f 88 c2 00 00 00    	js     801191 <dup+0xe2>
		return r;
	close(newfdnum);
  8010cf:	83 ec 0c             	sub    $0xc,%esp
  8010d2:	ff 75 0c             	pushl  0xc(%ebp)
  8010d5:	e8 87 ff ff ff       	call   801061 <close>

	newfd = INDEX2FD(newfdnum);
  8010da:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8010dd:	c1 e3 0c             	shl    $0xc,%ebx
  8010e0:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8010e6:	83 c4 04             	add    $0x4,%esp
  8010e9:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010ec:	e8 9c fd ff ff       	call   800e8d <fd2data>
  8010f1:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  8010f3:	89 1c 24             	mov    %ebx,(%esp)
  8010f6:	e8 92 fd ff ff       	call   800e8d <fd2data>
  8010fb:	83 c4 10             	add    $0x10,%esp
  8010fe:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801100:	89 f0                	mov    %esi,%eax
  801102:	c1 e8 16             	shr    $0x16,%eax
  801105:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80110c:	a8 01                	test   $0x1,%al
  80110e:	74 35                	je     801145 <dup+0x96>
  801110:	89 f0                	mov    %esi,%eax
  801112:	c1 e8 0c             	shr    $0xc,%eax
  801115:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80111c:	f6 c2 01             	test   $0x1,%dl
  80111f:	74 24                	je     801145 <dup+0x96>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801121:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801128:	83 ec 0c             	sub    $0xc,%esp
  80112b:	25 07 0e 00 00       	and    $0xe07,%eax
  801130:	50                   	push   %eax
  801131:	57                   	push   %edi
  801132:	6a 00                	push   $0x0
  801134:	56                   	push   %esi
  801135:	6a 00                	push   $0x0
  801137:	e8 93 fb ff ff       	call   800ccf <sys_page_map>
  80113c:	89 c6                	mov    %eax,%esi
  80113e:	83 c4 20             	add    $0x20,%esp
  801141:	85 c0                	test   %eax,%eax
  801143:	78 2c                	js     801171 <dup+0xc2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801145:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801148:	89 d0                	mov    %edx,%eax
  80114a:	c1 e8 0c             	shr    $0xc,%eax
  80114d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801154:	83 ec 0c             	sub    $0xc,%esp
  801157:	25 07 0e 00 00       	and    $0xe07,%eax
  80115c:	50                   	push   %eax
  80115d:	53                   	push   %ebx
  80115e:	6a 00                	push   $0x0
  801160:	52                   	push   %edx
  801161:	6a 00                	push   $0x0
  801163:	e8 67 fb ff ff       	call   800ccf <sys_page_map>
  801168:	89 c6                	mov    %eax,%esi
  80116a:	83 c4 20             	add    $0x20,%esp
  80116d:	85 c0                	test   %eax,%eax
  80116f:	79 1d                	jns    80118e <dup+0xdf>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801171:	83 ec 08             	sub    $0x8,%esp
  801174:	53                   	push   %ebx
  801175:	6a 00                	push   $0x0
  801177:	e8 95 fb ff ff       	call   800d11 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80117c:	83 c4 08             	add    $0x8,%esp
  80117f:	57                   	push   %edi
  801180:	6a 00                	push   $0x0
  801182:	e8 8a fb ff ff       	call   800d11 <sys_page_unmap>
	return r;
  801187:	83 c4 10             	add    $0x10,%esp
  80118a:	89 f0                	mov    %esi,%eax
  80118c:	eb 03                	jmp    801191 <dup+0xe2>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  80118e:	8b 45 0c             	mov    0xc(%ebp),%eax

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801191:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801194:	5b                   	pop    %ebx
  801195:	5e                   	pop    %esi
  801196:	5f                   	pop    %edi
  801197:	5d                   	pop    %ebp
  801198:	c3                   	ret    

00801199 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
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
  8011a8:	e8 6b fd ff ff       	call   800f18 <fd_lookup>
  8011ad:	83 c4 08             	add    $0x8,%esp
  8011b0:	85 c0                	test   %eax,%eax
  8011b2:	78 67                	js     80121b <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011b4:	83 ec 08             	sub    $0x8,%esp
  8011b7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011ba:	50                   	push   %eax
  8011bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011be:	ff 30                	pushl  (%eax)
  8011c0:	e8 aa fd ff ff       	call   800f6f <dev_lookup>
  8011c5:	83 c4 10             	add    $0x10,%esp
  8011c8:	85 c0                	test   %eax,%eax
  8011ca:	78 4f                	js     80121b <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8011cc:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8011cf:	8b 42 08             	mov    0x8(%edx),%eax
  8011d2:	83 e0 03             	and    $0x3,%eax
  8011d5:	83 f8 01             	cmp    $0x1,%eax
  8011d8:	75 21                	jne    8011fb <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8011da:	a1 20 40 c0 00       	mov    0xc04020,%eax
  8011df:	8b 40 48             	mov    0x48(%eax),%eax
  8011e2:	83 ec 04             	sub    $0x4,%esp
  8011e5:	53                   	push   %ebx
  8011e6:	50                   	push   %eax
  8011e7:	68 50 23 80 00       	push   $0x802350
  8011ec:	e8 46 f0 ff ff       	call   800237 <cprintf>
		return -E_INVAL;
  8011f1:	83 c4 10             	add    $0x10,%esp
  8011f4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011f9:	eb 20                	jmp    80121b <read+0x82>
	}
	if (!dev->dev_read)
  8011fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011fe:	8b 40 08             	mov    0x8(%eax),%eax
  801201:	85 c0                	test   %eax,%eax
  801203:	74 11                	je     801216 <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801205:	83 ec 04             	sub    $0x4,%esp
  801208:	ff 75 10             	pushl  0x10(%ebp)
  80120b:	ff 75 0c             	pushl  0xc(%ebp)
  80120e:	52                   	push   %edx
  80120f:	ff d0                	call   *%eax
  801211:	83 c4 10             	add    $0x10,%esp
  801214:	eb 05                	jmp    80121b <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801216:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  80121b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80121e:	c9                   	leave  
  80121f:	c3                   	ret    

00801220 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801220:	55                   	push   %ebp
  801221:	89 e5                	mov    %esp,%ebp
  801223:	57                   	push   %edi
  801224:	56                   	push   %esi
  801225:	53                   	push   %ebx
  801226:	83 ec 0c             	sub    $0xc,%esp
  801229:	8b 7d 08             	mov    0x8(%ebp),%edi
  80122c:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80122f:	85 f6                	test   %esi,%esi
  801231:	74 31                	je     801264 <readn+0x44>
  801233:	b8 00 00 00 00       	mov    $0x0,%eax
  801238:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  80123d:	83 ec 04             	sub    $0x4,%esp
  801240:	89 f2                	mov    %esi,%edx
  801242:	29 c2                	sub    %eax,%edx
  801244:	52                   	push   %edx
  801245:	03 45 0c             	add    0xc(%ebp),%eax
  801248:	50                   	push   %eax
  801249:	57                   	push   %edi
  80124a:	e8 4a ff ff ff       	call   801199 <read>
		if (m < 0)
  80124f:	83 c4 10             	add    $0x10,%esp
  801252:	85 c0                	test   %eax,%eax
  801254:	78 17                	js     80126d <readn+0x4d>
			return m;
		if (m == 0)
  801256:	85 c0                	test   %eax,%eax
  801258:	74 11                	je     80126b <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80125a:	01 c3                	add    %eax,%ebx
  80125c:	89 d8                	mov    %ebx,%eax
  80125e:	39 f3                	cmp    %esi,%ebx
  801260:	72 db                	jb     80123d <readn+0x1d>
  801262:	eb 09                	jmp    80126d <readn+0x4d>
  801264:	b8 00 00 00 00       	mov    $0x0,%eax
  801269:	eb 02                	jmp    80126d <readn+0x4d>
  80126b:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80126d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801270:	5b                   	pop    %ebx
  801271:	5e                   	pop    %esi
  801272:	5f                   	pop    %edi
  801273:	5d                   	pop    %ebp
  801274:	c3                   	ret    

00801275 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801275:	55                   	push   %ebp
  801276:	89 e5                	mov    %esp,%ebp
  801278:	53                   	push   %ebx
  801279:	83 ec 14             	sub    $0x14,%esp
  80127c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80127f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801282:	50                   	push   %eax
  801283:	53                   	push   %ebx
  801284:	e8 8f fc ff ff       	call   800f18 <fd_lookup>
  801289:	83 c4 08             	add    $0x8,%esp
  80128c:	85 c0                	test   %eax,%eax
  80128e:	78 62                	js     8012f2 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801290:	83 ec 08             	sub    $0x8,%esp
  801293:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801296:	50                   	push   %eax
  801297:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80129a:	ff 30                	pushl  (%eax)
  80129c:	e8 ce fc ff ff       	call   800f6f <dev_lookup>
  8012a1:	83 c4 10             	add    $0x10,%esp
  8012a4:	85 c0                	test   %eax,%eax
  8012a6:	78 4a                	js     8012f2 <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012ab:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012af:	75 21                	jne    8012d2 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8012b1:	a1 20 40 c0 00       	mov    0xc04020,%eax
  8012b6:	8b 40 48             	mov    0x48(%eax),%eax
  8012b9:	83 ec 04             	sub    $0x4,%esp
  8012bc:	53                   	push   %ebx
  8012bd:	50                   	push   %eax
  8012be:	68 6c 23 80 00       	push   $0x80236c
  8012c3:	e8 6f ef ff ff       	call   800237 <cprintf>
		return -E_INVAL;
  8012c8:	83 c4 10             	add    $0x10,%esp
  8012cb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012d0:	eb 20                	jmp    8012f2 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8012d2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012d5:	8b 52 0c             	mov    0xc(%edx),%edx
  8012d8:	85 d2                	test   %edx,%edx
  8012da:	74 11                	je     8012ed <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8012dc:	83 ec 04             	sub    $0x4,%esp
  8012df:	ff 75 10             	pushl  0x10(%ebp)
  8012e2:	ff 75 0c             	pushl  0xc(%ebp)
  8012e5:	50                   	push   %eax
  8012e6:	ff d2                	call   *%edx
  8012e8:	83 c4 10             	add    $0x10,%esp
  8012eb:	eb 05                	jmp    8012f2 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8012ed:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8012f2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012f5:	c9                   	leave  
  8012f6:	c3                   	ret    

008012f7 <seek>:

int
seek(int fdnum, off_t offset)
{
  8012f7:	55                   	push   %ebp
  8012f8:	89 e5                	mov    %esp,%ebp
  8012fa:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012fd:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801300:	50                   	push   %eax
  801301:	ff 75 08             	pushl  0x8(%ebp)
  801304:	e8 0f fc ff ff       	call   800f18 <fd_lookup>
  801309:	83 c4 08             	add    $0x8,%esp
  80130c:	85 c0                	test   %eax,%eax
  80130e:	78 0e                	js     80131e <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801310:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801313:	8b 55 0c             	mov    0xc(%ebp),%edx
  801316:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801319:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80131e:	c9                   	leave  
  80131f:	c3                   	ret    

00801320 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801320:	55                   	push   %ebp
  801321:	89 e5                	mov    %esp,%ebp
  801323:	53                   	push   %ebx
  801324:	83 ec 14             	sub    $0x14,%esp
  801327:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80132a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80132d:	50                   	push   %eax
  80132e:	53                   	push   %ebx
  80132f:	e8 e4 fb ff ff       	call   800f18 <fd_lookup>
  801334:	83 c4 08             	add    $0x8,%esp
  801337:	85 c0                	test   %eax,%eax
  801339:	78 5f                	js     80139a <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80133b:	83 ec 08             	sub    $0x8,%esp
  80133e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801341:	50                   	push   %eax
  801342:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801345:	ff 30                	pushl  (%eax)
  801347:	e8 23 fc ff ff       	call   800f6f <dev_lookup>
  80134c:	83 c4 10             	add    $0x10,%esp
  80134f:	85 c0                	test   %eax,%eax
  801351:	78 47                	js     80139a <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801353:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801356:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80135a:	75 21                	jne    80137d <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80135c:	a1 20 40 c0 00       	mov    0xc04020,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801361:	8b 40 48             	mov    0x48(%eax),%eax
  801364:	83 ec 04             	sub    $0x4,%esp
  801367:	53                   	push   %ebx
  801368:	50                   	push   %eax
  801369:	68 2c 23 80 00       	push   $0x80232c
  80136e:	e8 c4 ee ff ff       	call   800237 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801373:	83 c4 10             	add    $0x10,%esp
  801376:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80137b:	eb 1d                	jmp    80139a <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  80137d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801380:	8b 52 18             	mov    0x18(%edx),%edx
  801383:	85 d2                	test   %edx,%edx
  801385:	74 0e                	je     801395 <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801387:	83 ec 08             	sub    $0x8,%esp
  80138a:	ff 75 0c             	pushl  0xc(%ebp)
  80138d:	50                   	push   %eax
  80138e:	ff d2                	call   *%edx
  801390:	83 c4 10             	add    $0x10,%esp
  801393:	eb 05                	jmp    80139a <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801395:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  80139a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80139d:	c9                   	leave  
  80139e:	c3                   	ret    

0080139f <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80139f:	55                   	push   %ebp
  8013a0:	89 e5                	mov    %esp,%ebp
  8013a2:	53                   	push   %ebx
  8013a3:	83 ec 14             	sub    $0x14,%esp
  8013a6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013a9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013ac:	50                   	push   %eax
  8013ad:	ff 75 08             	pushl  0x8(%ebp)
  8013b0:	e8 63 fb ff ff       	call   800f18 <fd_lookup>
  8013b5:	83 c4 08             	add    $0x8,%esp
  8013b8:	85 c0                	test   %eax,%eax
  8013ba:	78 52                	js     80140e <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013bc:	83 ec 08             	sub    $0x8,%esp
  8013bf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013c2:	50                   	push   %eax
  8013c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013c6:	ff 30                	pushl  (%eax)
  8013c8:	e8 a2 fb ff ff       	call   800f6f <dev_lookup>
  8013cd:	83 c4 10             	add    $0x10,%esp
  8013d0:	85 c0                	test   %eax,%eax
  8013d2:	78 3a                	js     80140e <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  8013d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013d7:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8013db:	74 2c                	je     801409 <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8013dd:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8013e0:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8013e7:	00 00 00 
	stat->st_isdir = 0;
  8013ea:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8013f1:	00 00 00 
	stat->st_dev = dev;
  8013f4:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8013fa:	83 ec 08             	sub    $0x8,%esp
  8013fd:	53                   	push   %ebx
  8013fe:	ff 75 f0             	pushl  -0x10(%ebp)
  801401:	ff 50 14             	call   *0x14(%eax)
  801404:	83 c4 10             	add    $0x10,%esp
  801407:	eb 05                	jmp    80140e <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801409:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80140e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801411:	c9                   	leave  
  801412:	c3                   	ret    

00801413 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801413:	55                   	push   %ebp
  801414:	89 e5                	mov    %esp,%ebp
  801416:	56                   	push   %esi
  801417:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801418:	83 ec 08             	sub    $0x8,%esp
  80141b:	6a 00                	push   $0x0
  80141d:	ff 75 08             	pushl  0x8(%ebp)
  801420:	e8 75 01 00 00       	call   80159a <open>
  801425:	89 c3                	mov    %eax,%ebx
  801427:	83 c4 10             	add    $0x10,%esp
  80142a:	85 c0                	test   %eax,%eax
  80142c:	78 1d                	js     80144b <stat+0x38>
		return fd;
	r = fstat(fd, stat);
  80142e:	83 ec 08             	sub    $0x8,%esp
  801431:	ff 75 0c             	pushl  0xc(%ebp)
  801434:	50                   	push   %eax
  801435:	e8 65 ff ff ff       	call   80139f <fstat>
  80143a:	89 c6                	mov    %eax,%esi
	close(fd);
  80143c:	89 1c 24             	mov    %ebx,(%esp)
  80143f:	e8 1d fc ff ff       	call   801061 <close>
	return r;
  801444:	83 c4 10             	add    $0x10,%esp
  801447:	89 f0                	mov    %esi,%eax
  801449:	eb 00                	jmp    80144b <stat+0x38>
}
  80144b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80144e:	5b                   	pop    %ebx
  80144f:	5e                   	pop    %esi
  801450:	5d                   	pop    %ebp
  801451:	c3                   	ret    

00801452 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801452:	55                   	push   %ebp
  801453:	89 e5                	mov    %esp,%ebp
  801455:	56                   	push   %esi
  801456:	53                   	push   %ebx
  801457:	89 c6                	mov    %eax,%esi
  801459:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80145b:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801462:	75 12                	jne    801476 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801464:	83 ec 0c             	sub    $0xc,%esp
  801467:	6a 01                	push   $0x1
  801469:	e8 7b 07 00 00       	call   801be9 <ipc_find_env>
  80146e:	a3 00 40 80 00       	mov    %eax,0x804000
  801473:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801476:	6a 07                	push   $0x7
  801478:	68 00 50 c0 00       	push   $0xc05000
  80147d:	56                   	push   %esi
  80147e:	ff 35 00 40 80 00    	pushl  0x804000
  801484:	e8 01 07 00 00       	call   801b8a <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801489:	83 c4 0c             	add    $0xc,%esp
  80148c:	6a 00                	push   $0x0
  80148e:	53                   	push   %ebx
  80148f:	6a 00                	push   $0x0
  801491:	e8 7f 06 00 00       	call   801b15 <ipc_recv>
}
  801496:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801499:	5b                   	pop    %ebx
  80149a:	5e                   	pop    %esi
  80149b:	5d                   	pop    %ebp
  80149c:	c3                   	ret    

0080149d <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80149d:	55                   	push   %ebp
  80149e:	89 e5                	mov    %esp,%ebp
  8014a0:	53                   	push   %ebx
  8014a1:	83 ec 04             	sub    $0x4,%esp
  8014a4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8014a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8014aa:	8b 40 0c             	mov    0xc(%eax),%eax
  8014ad:	a3 00 50 c0 00       	mov    %eax,0xc05000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8014b2:	ba 00 00 00 00       	mov    $0x0,%edx
  8014b7:	b8 05 00 00 00       	mov    $0x5,%eax
  8014bc:	e8 91 ff ff ff       	call   801452 <fsipc>
  8014c1:	85 c0                	test   %eax,%eax
  8014c3:	78 2c                	js     8014f1 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8014c5:	83 ec 08             	sub    $0x8,%esp
  8014c8:	68 00 50 c0 00       	push   $0xc05000
  8014cd:	53                   	push   %ebx
  8014ce:	e8 49 f3 ff ff       	call   80081c <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8014d3:	a1 80 50 c0 00       	mov    0xc05080,%eax
  8014d8:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8014de:	a1 84 50 c0 00       	mov    0xc05084,%eax
  8014e3:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8014e9:	83 c4 10             	add    $0x10,%esp
  8014ec:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014f1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014f4:	c9                   	leave  
  8014f5:	c3                   	ret    

008014f6 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8014f6:	55                   	push   %ebp
  8014f7:	89 e5                	mov    %esp,%ebp
  8014f9:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8014fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8014ff:	8b 40 0c             	mov    0xc(%eax),%eax
  801502:	a3 00 50 c0 00       	mov    %eax,0xc05000
	return fsipc(FSREQ_FLUSH, NULL);
  801507:	ba 00 00 00 00       	mov    $0x0,%edx
  80150c:	b8 06 00 00 00       	mov    $0x6,%eax
  801511:	e8 3c ff ff ff       	call   801452 <fsipc>
}
  801516:	c9                   	leave  
  801517:	c3                   	ret    

00801518 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801518:	55                   	push   %ebp
  801519:	89 e5                	mov    %esp,%ebp
  80151b:	56                   	push   %esi
  80151c:	53                   	push   %ebx
  80151d:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801520:	8b 45 08             	mov    0x8(%ebp),%eax
  801523:	8b 40 0c             	mov    0xc(%eax),%eax
  801526:	a3 00 50 c0 00       	mov    %eax,0xc05000
	fsipcbuf.read.req_n = n;
  80152b:	89 35 04 50 c0 00    	mov    %esi,0xc05004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801531:	ba 00 00 00 00       	mov    $0x0,%edx
  801536:	b8 03 00 00 00       	mov    $0x3,%eax
  80153b:	e8 12 ff ff ff       	call   801452 <fsipc>
  801540:	89 c3                	mov    %eax,%ebx
  801542:	85 c0                	test   %eax,%eax
  801544:	78 4b                	js     801591 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801546:	39 c6                	cmp    %eax,%esi
  801548:	73 16                	jae    801560 <devfile_read+0x48>
  80154a:	68 89 23 80 00       	push   $0x802389
  80154f:	68 90 23 80 00       	push   $0x802390
  801554:	6a 7a                	push   $0x7a
  801556:	68 a5 23 80 00       	push   $0x8023a5
  80155b:	e8 ff eb ff ff       	call   80015f <_panic>
	assert(r <= PGSIZE);
  801560:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801565:	7e 16                	jle    80157d <devfile_read+0x65>
  801567:	68 b0 23 80 00       	push   $0x8023b0
  80156c:	68 90 23 80 00       	push   $0x802390
  801571:	6a 7b                	push   $0x7b
  801573:	68 a5 23 80 00       	push   $0x8023a5
  801578:	e8 e2 eb ff ff       	call   80015f <_panic>
	memmove(buf, &fsipcbuf, r);
  80157d:	83 ec 04             	sub    $0x4,%esp
  801580:	50                   	push   %eax
  801581:	68 00 50 c0 00       	push   $0xc05000
  801586:	ff 75 0c             	pushl  0xc(%ebp)
  801589:	e8 5b f4 ff ff       	call   8009e9 <memmove>
	return r;
  80158e:	83 c4 10             	add    $0x10,%esp
}
  801591:	89 d8                	mov    %ebx,%eax
  801593:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801596:	5b                   	pop    %ebx
  801597:	5e                   	pop    %esi
  801598:	5d                   	pop    %ebp
  801599:	c3                   	ret    

0080159a <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80159a:	55                   	push   %ebp
  80159b:	89 e5                	mov    %esp,%ebp
  80159d:	53                   	push   %ebx
  80159e:	83 ec 20             	sub    $0x20,%esp
  8015a1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8015a4:	53                   	push   %ebx
  8015a5:	e8 1b f2 ff ff       	call   8007c5 <strlen>
  8015aa:	83 c4 10             	add    $0x10,%esp
  8015ad:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8015b2:	7f 63                	jg     801617 <open+0x7d>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015b4:	83 ec 0c             	sub    $0xc,%esp
  8015b7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015ba:	50                   	push   %eax
  8015bb:	e8 e4 f8 ff ff       	call   800ea4 <fd_alloc>
  8015c0:	83 c4 10             	add    $0x10,%esp
  8015c3:	85 c0                	test   %eax,%eax
  8015c5:	78 55                	js     80161c <open+0x82>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8015c7:	83 ec 08             	sub    $0x8,%esp
  8015ca:	53                   	push   %ebx
  8015cb:	68 00 50 c0 00       	push   $0xc05000
  8015d0:	e8 47 f2 ff ff       	call   80081c <strcpy>
	fsipcbuf.open.req_omode = mode;
  8015d5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015d8:	a3 00 54 c0 00       	mov    %eax,0xc05400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8015dd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015e0:	b8 01 00 00 00       	mov    $0x1,%eax
  8015e5:	e8 68 fe ff ff       	call   801452 <fsipc>
  8015ea:	89 c3                	mov    %eax,%ebx
  8015ec:	83 c4 10             	add    $0x10,%esp
  8015ef:	85 c0                	test   %eax,%eax
  8015f1:	79 14                	jns    801607 <open+0x6d>
		fd_close(fd, 0);
  8015f3:	83 ec 08             	sub    $0x8,%esp
  8015f6:	6a 00                	push   $0x0
  8015f8:	ff 75 f4             	pushl  -0xc(%ebp)
  8015fb:	e8 dd f9 ff ff       	call   800fdd <fd_close>
		return r;
  801600:	83 c4 10             	add    $0x10,%esp
  801603:	89 d8                	mov    %ebx,%eax
  801605:	eb 15                	jmp    80161c <open+0x82>
	}

	return fd2num(fd);
  801607:	83 ec 0c             	sub    $0xc,%esp
  80160a:	ff 75 f4             	pushl  -0xc(%ebp)
  80160d:	e8 6b f8 ff ff       	call   800e7d <fd2num>
  801612:	83 c4 10             	add    $0x10,%esp
  801615:	eb 05                	jmp    80161c <open+0x82>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801617:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80161c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80161f:	c9                   	leave  
  801620:	c3                   	ret    

00801621 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801621:	55                   	push   %ebp
  801622:	89 e5                	mov    %esp,%ebp
  801624:	56                   	push   %esi
  801625:	53                   	push   %ebx
  801626:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801629:	83 ec 0c             	sub    $0xc,%esp
  80162c:	ff 75 08             	pushl  0x8(%ebp)
  80162f:	e8 59 f8 ff ff       	call   800e8d <fd2data>
  801634:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801636:	83 c4 08             	add    $0x8,%esp
  801639:	68 bc 23 80 00       	push   $0x8023bc
  80163e:	53                   	push   %ebx
  80163f:	e8 d8 f1 ff ff       	call   80081c <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801644:	8b 46 04             	mov    0x4(%esi),%eax
  801647:	2b 06                	sub    (%esi),%eax
  801649:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80164f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801656:	00 00 00 
	stat->st_dev = &devpipe;
  801659:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801660:	30 80 00 
	return 0;
}
  801663:	b8 00 00 00 00       	mov    $0x0,%eax
  801668:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80166b:	5b                   	pop    %ebx
  80166c:	5e                   	pop    %esi
  80166d:	5d                   	pop    %ebp
  80166e:	c3                   	ret    

0080166f <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80166f:	55                   	push   %ebp
  801670:	89 e5                	mov    %esp,%ebp
  801672:	53                   	push   %ebx
  801673:	83 ec 0c             	sub    $0xc,%esp
  801676:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801679:	53                   	push   %ebx
  80167a:	6a 00                	push   $0x0
  80167c:	e8 90 f6 ff ff       	call   800d11 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801681:	89 1c 24             	mov    %ebx,(%esp)
  801684:	e8 04 f8 ff ff       	call   800e8d <fd2data>
  801689:	83 c4 08             	add    $0x8,%esp
  80168c:	50                   	push   %eax
  80168d:	6a 00                	push   $0x0
  80168f:	e8 7d f6 ff ff       	call   800d11 <sys_page_unmap>
}
  801694:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801697:	c9                   	leave  
  801698:	c3                   	ret    

00801699 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801699:	55                   	push   %ebp
  80169a:	89 e5                	mov    %esp,%ebp
  80169c:	57                   	push   %edi
  80169d:	56                   	push   %esi
  80169e:	53                   	push   %ebx
  80169f:	83 ec 1c             	sub    $0x1c,%esp
  8016a2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8016a5:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8016a7:	a1 20 40 c0 00       	mov    0xc04020,%eax
  8016ac:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8016af:	83 ec 0c             	sub    $0xc,%esp
  8016b2:	ff 75 e0             	pushl  -0x20(%ebp)
  8016b5:	e8 8a 05 00 00       	call   801c44 <pageref>
  8016ba:	89 c3                	mov    %eax,%ebx
  8016bc:	89 3c 24             	mov    %edi,(%esp)
  8016bf:	e8 80 05 00 00       	call   801c44 <pageref>
  8016c4:	83 c4 10             	add    $0x10,%esp
  8016c7:	39 c3                	cmp    %eax,%ebx
  8016c9:	0f 94 c1             	sete   %cl
  8016cc:	0f b6 c9             	movzbl %cl,%ecx
  8016cf:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8016d2:	8b 15 20 40 c0 00    	mov    0xc04020,%edx
  8016d8:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8016db:	39 ce                	cmp    %ecx,%esi
  8016dd:	74 1b                	je     8016fa <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8016df:	39 c3                	cmp    %eax,%ebx
  8016e1:	75 c4                	jne    8016a7 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8016e3:	8b 42 58             	mov    0x58(%edx),%eax
  8016e6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8016e9:	50                   	push   %eax
  8016ea:	56                   	push   %esi
  8016eb:	68 c3 23 80 00       	push   $0x8023c3
  8016f0:	e8 42 eb ff ff       	call   800237 <cprintf>
  8016f5:	83 c4 10             	add    $0x10,%esp
  8016f8:	eb ad                	jmp    8016a7 <_pipeisclosed+0xe>
	}
}
  8016fa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8016fd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801700:	5b                   	pop    %ebx
  801701:	5e                   	pop    %esi
  801702:	5f                   	pop    %edi
  801703:	5d                   	pop    %ebp
  801704:	c3                   	ret    

00801705 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801705:	55                   	push   %ebp
  801706:	89 e5                	mov    %esp,%ebp
  801708:	57                   	push   %edi
  801709:	56                   	push   %esi
  80170a:	53                   	push   %ebx
  80170b:	83 ec 18             	sub    $0x18,%esp
  80170e:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801711:	56                   	push   %esi
  801712:	e8 76 f7 ff ff       	call   800e8d <fd2data>
  801717:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801719:	83 c4 10             	add    $0x10,%esp
  80171c:	bf 00 00 00 00       	mov    $0x0,%edi
  801721:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801725:	75 42                	jne    801769 <devpipe_write+0x64>
  801727:	eb 4e                	jmp    801777 <devpipe_write+0x72>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801729:	89 da                	mov    %ebx,%edx
  80172b:	89 f0                	mov    %esi,%eax
  80172d:	e8 67 ff ff ff       	call   801699 <_pipeisclosed>
  801732:	85 c0                	test   %eax,%eax
  801734:	75 46                	jne    80177c <devpipe_write+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801736:	e8 32 f5 ff ff       	call   800c6d <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80173b:	8b 53 04             	mov    0x4(%ebx),%edx
  80173e:	8b 03                	mov    (%ebx),%eax
  801740:	83 c0 20             	add    $0x20,%eax
  801743:	39 c2                	cmp    %eax,%edx
  801745:	73 e2                	jae    801729 <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801747:	8b 45 0c             	mov    0xc(%ebp),%eax
  80174a:	8a 0c 38             	mov    (%eax,%edi,1),%cl
  80174d:	89 d0                	mov    %edx,%eax
  80174f:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801754:	79 05                	jns    80175b <devpipe_write+0x56>
  801756:	48                   	dec    %eax
  801757:	83 c8 e0             	or     $0xffffffe0,%eax
  80175a:	40                   	inc    %eax
  80175b:	88 4c 03 08          	mov    %cl,0x8(%ebx,%eax,1)
		p->p_wpos++;
  80175f:	42                   	inc    %edx
  801760:	89 53 04             	mov    %edx,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801763:	47                   	inc    %edi
  801764:	39 7d 10             	cmp    %edi,0x10(%ebp)
  801767:	74 0e                	je     801777 <devpipe_write+0x72>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801769:	8b 53 04             	mov    0x4(%ebx),%edx
  80176c:	8b 03                	mov    (%ebx),%eax
  80176e:	83 c0 20             	add    $0x20,%eax
  801771:	39 c2                	cmp    %eax,%edx
  801773:	73 b4                	jae    801729 <devpipe_write+0x24>
  801775:	eb d0                	jmp    801747 <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801777:	8b 45 10             	mov    0x10(%ebp),%eax
  80177a:	eb 05                	jmp    801781 <devpipe_write+0x7c>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80177c:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801781:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801784:	5b                   	pop    %ebx
  801785:	5e                   	pop    %esi
  801786:	5f                   	pop    %edi
  801787:	5d                   	pop    %ebp
  801788:	c3                   	ret    

00801789 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801789:	55                   	push   %ebp
  80178a:	89 e5                	mov    %esp,%ebp
  80178c:	57                   	push   %edi
  80178d:	56                   	push   %esi
  80178e:	53                   	push   %ebx
  80178f:	83 ec 18             	sub    $0x18,%esp
  801792:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801795:	57                   	push   %edi
  801796:	e8 f2 f6 ff ff       	call   800e8d <fd2data>
  80179b:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80179d:	83 c4 10             	add    $0x10,%esp
  8017a0:	be 00 00 00 00       	mov    $0x0,%esi
  8017a5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8017a9:	75 3d                	jne    8017e8 <devpipe_read+0x5f>
  8017ab:	eb 48                	jmp    8017f5 <devpipe_read+0x6c>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  8017ad:	89 f0                	mov    %esi,%eax
  8017af:	eb 4e                	jmp    8017ff <devpipe_read+0x76>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8017b1:	89 da                	mov    %ebx,%edx
  8017b3:	89 f8                	mov    %edi,%eax
  8017b5:	e8 df fe ff ff       	call   801699 <_pipeisclosed>
  8017ba:	85 c0                	test   %eax,%eax
  8017bc:	75 3c                	jne    8017fa <devpipe_read+0x71>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8017be:	e8 aa f4 ff ff       	call   800c6d <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8017c3:	8b 03                	mov    (%ebx),%eax
  8017c5:	3b 43 04             	cmp    0x4(%ebx),%eax
  8017c8:	74 e7                	je     8017b1 <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8017ca:	25 1f 00 00 80       	and    $0x8000001f,%eax
  8017cf:	79 05                	jns    8017d6 <devpipe_read+0x4d>
  8017d1:	48                   	dec    %eax
  8017d2:	83 c8 e0             	or     $0xffffffe0,%eax
  8017d5:	40                   	inc    %eax
  8017d6:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  8017da:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017dd:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  8017e0:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8017e2:	46                   	inc    %esi
  8017e3:	39 75 10             	cmp    %esi,0x10(%ebp)
  8017e6:	74 0d                	je     8017f5 <devpipe_read+0x6c>
		while (p->p_rpos == p->p_wpos) {
  8017e8:	8b 03                	mov    (%ebx),%eax
  8017ea:	3b 43 04             	cmp    0x4(%ebx),%eax
  8017ed:	75 db                	jne    8017ca <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8017ef:	85 f6                	test   %esi,%esi
  8017f1:	75 ba                	jne    8017ad <devpipe_read+0x24>
  8017f3:	eb bc                	jmp    8017b1 <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8017f5:	8b 45 10             	mov    0x10(%ebp),%eax
  8017f8:	eb 05                	jmp    8017ff <devpipe_read+0x76>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8017fa:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8017ff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801802:	5b                   	pop    %ebx
  801803:	5e                   	pop    %esi
  801804:	5f                   	pop    %edi
  801805:	5d                   	pop    %ebp
  801806:	c3                   	ret    

00801807 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801807:	55                   	push   %ebp
  801808:	89 e5                	mov    %esp,%ebp
  80180a:	56                   	push   %esi
  80180b:	53                   	push   %ebx
  80180c:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80180f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801812:	50                   	push   %eax
  801813:	e8 8c f6 ff ff       	call   800ea4 <fd_alloc>
  801818:	83 c4 10             	add    $0x10,%esp
  80181b:	85 c0                	test   %eax,%eax
  80181d:	0f 88 2a 01 00 00    	js     80194d <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801823:	83 ec 04             	sub    $0x4,%esp
  801826:	68 07 04 00 00       	push   $0x407
  80182b:	ff 75 f4             	pushl  -0xc(%ebp)
  80182e:	6a 00                	push   $0x0
  801830:	e8 57 f4 ff ff       	call   800c8c <sys_page_alloc>
  801835:	83 c4 10             	add    $0x10,%esp
  801838:	85 c0                	test   %eax,%eax
  80183a:	0f 88 0d 01 00 00    	js     80194d <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801840:	83 ec 0c             	sub    $0xc,%esp
  801843:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801846:	50                   	push   %eax
  801847:	e8 58 f6 ff ff       	call   800ea4 <fd_alloc>
  80184c:	89 c3                	mov    %eax,%ebx
  80184e:	83 c4 10             	add    $0x10,%esp
  801851:	85 c0                	test   %eax,%eax
  801853:	0f 88 e2 00 00 00    	js     80193b <pipe+0x134>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801859:	83 ec 04             	sub    $0x4,%esp
  80185c:	68 07 04 00 00       	push   $0x407
  801861:	ff 75 f0             	pushl  -0x10(%ebp)
  801864:	6a 00                	push   $0x0
  801866:	e8 21 f4 ff ff       	call   800c8c <sys_page_alloc>
  80186b:	89 c3                	mov    %eax,%ebx
  80186d:	83 c4 10             	add    $0x10,%esp
  801870:	85 c0                	test   %eax,%eax
  801872:	0f 88 c3 00 00 00    	js     80193b <pipe+0x134>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801878:	83 ec 0c             	sub    $0xc,%esp
  80187b:	ff 75 f4             	pushl  -0xc(%ebp)
  80187e:	e8 0a f6 ff ff       	call   800e8d <fd2data>
  801883:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801885:	83 c4 0c             	add    $0xc,%esp
  801888:	68 07 04 00 00       	push   $0x407
  80188d:	50                   	push   %eax
  80188e:	6a 00                	push   $0x0
  801890:	e8 f7 f3 ff ff       	call   800c8c <sys_page_alloc>
  801895:	89 c3                	mov    %eax,%ebx
  801897:	83 c4 10             	add    $0x10,%esp
  80189a:	85 c0                	test   %eax,%eax
  80189c:	0f 88 89 00 00 00    	js     80192b <pipe+0x124>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018a2:	83 ec 0c             	sub    $0xc,%esp
  8018a5:	ff 75 f0             	pushl  -0x10(%ebp)
  8018a8:	e8 e0 f5 ff ff       	call   800e8d <fd2data>
  8018ad:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8018b4:	50                   	push   %eax
  8018b5:	6a 00                	push   $0x0
  8018b7:	56                   	push   %esi
  8018b8:	6a 00                	push   $0x0
  8018ba:	e8 10 f4 ff ff       	call   800ccf <sys_page_map>
  8018bf:	89 c3                	mov    %eax,%ebx
  8018c1:	83 c4 20             	add    $0x20,%esp
  8018c4:	85 c0                	test   %eax,%eax
  8018c6:	78 55                	js     80191d <pipe+0x116>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8018c8:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8018ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018d1:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8018d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018d6:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8018dd:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8018e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018e6:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8018e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018eb:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8018f2:	83 ec 0c             	sub    $0xc,%esp
  8018f5:	ff 75 f4             	pushl  -0xc(%ebp)
  8018f8:	e8 80 f5 ff ff       	call   800e7d <fd2num>
  8018fd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801900:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801902:	83 c4 04             	add    $0x4,%esp
  801905:	ff 75 f0             	pushl  -0x10(%ebp)
  801908:	e8 70 f5 ff ff       	call   800e7d <fd2num>
  80190d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801910:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801913:	83 c4 10             	add    $0x10,%esp
  801916:	b8 00 00 00 00       	mov    $0x0,%eax
  80191b:	eb 30                	jmp    80194d <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  80191d:	83 ec 08             	sub    $0x8,%esp
  801920:	56                   	push   %esi
  801921:	6a 00                	push   $0x0
  801923:	e8 e9 f3 ff ff       	call   800d11 <sys_page_unmap>
  801928:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80192b:	83 ec 08             	sub    $0x8,%esp
  80192e:	ff 75 f0             	pushl  -0x10(%ebp)
  801931:	6a 00                	push   $0x0
  801933:	e8 d9 f3 ff ff       	call   800d11 <sys_page_unmap>
  801938:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80193b:	83 ec 08             	sub    $0x8,%esp
  80193e:	ff 75 f4             	pushl  -0xc(%ebp)
  801941:	6a 00                	push   $0x0
  801943:	e8 c9 f3 ff ff       	call   800d11 <sys_page_unmap>
  801948:	83 c4 10             	add    $0x10,%esp
  80194b:	89 d8                	mov    %ebx,%eax
    err:
	return r;
}
  80194d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801950:	5b                   	pop    %ebx
  801951:	5e                   	pop    %esi
  801952:	5d                   	pop    %ebp
  801953:	c3                   	ret    

00801954 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801954:	55                   	push   %ebp
  801955:	89 e5                	mov    %esp,%ebp
  801957:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80195a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80195d:	50                   	push   %eax
  80195e:	ff 75 08             	pushl  0x8(%ebp)
  801961:	e8 b2 f5 ff ff       	call   800f18 <fd_lookup>
  801966:	83 c4 10             	add    $0x10,%esp
  801969:	85 c0                	test   %eax,%eax
  80196b:	78 18                	js     801985 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80196d:	83 ec 0c             	sub    $0xc,%esp
  801970:	ff 75 f4             	pushl  -0xc(%ebp)
  801973:	e8 15 f5 ff ff       	call   800e8d <fd2data>
	return _pipeisclosed(fd, p);
  801978:	89 c2                	mov    %eax,%edx
  80197a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80197d:	e8 17 fd ff ff       	call   801699 <_pipeisclosed>
  801982:	83 c4 10             	add    $0x10,%esp
}
  801985:	c9                   	leave  
  801986:	c3                   	ret    

00801987 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801987:	55                   	push   %ebp
  801988:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80198a:	b8 00 00 00 00       	mov    $0x0,%eax
  80198f:	5d                   	pop    %ebp
  801990:	c3                   	ret    

00801991 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801991:	55                   	push   %ebp
  801992:	89 e5                	mov    %esp,%ebp
  801994:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801997:	68 db 23 80 00       	push   $0x8023db
  80199c:	ff 75 0c             	pushl  0xc(%ebp)
  80199f:	e8 78 ee ff ff       	call   80081c <strcpy>
	return 0;
}
  8019a4:	b8 00 00 00 00       	mov    $0x0,%eax
  8019a9:	c9                   	leave  
  8019aa:	c3                   	ret    

008019ab <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8019ab:	55                   	push   %ebp
  8019ac:	89 e5                	mov    %esp,%ebp
  8019ae:	57                   	push   %edi
  8019af:	56                   	push   %esi
  8019b0:	53                   	push   %ebx
  8019b1:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8019b7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8019bb:	74 45                	je     801a02 <devcons_write+0x57>
  8019bd:	b8 00 00 00 00       	mov    $0x0,%eax
  8019c2:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8019c7:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8019cd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8019d0:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  8019d2:	83 fb 7f             	cmp    $0x7f,%ebx
  8019d5:	76 05                	jbe    8019dc <devcons_write+0x31>
			m = sizeof(buf) - 1;
  8019d7:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  8019dc:	83 ec 04             	sub    $0x4,%esp
  8019df:	53                   	push   %ebx
  8019e0:	03 45 0c             	add    0xc(%ebp),%eax
  8019e3:	50                   	push   %eax
  8019e4:	57                   	push   %edi
  8019e5:	e8 ff ef ff ff       	call   8009e9 <memmove>
		sys_cputs(buf, m);
  8019ea:	83 c4 08             	add    $0x8,%esp
  8019ed:	53                   	push   %ebx
  8019ee:	57                   	push   %edi
  8019ef:	e8 dc f1 ff ff       	call   800bd0 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8019f4:	01 de                	add    %ebx,%esi
  8019f6:	89 f0                	mov    %esi,%eax
  8019f8:	83 c4 10             	add    $0x10,%esp
  8019fb:	3b 75 10             	cmp    0x10(%ebp),%esi
  8019fe:	72 cd                	jb     8019cd <devcons_write+0x22>
  801a00:	eb 05                	jmp    801a07 <devcons_write+0x5c>
  801a02:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801a07:	89 f0                	mov    %esi,%eax
  801a09:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a0c:	5b                   	pop    %ebx
  801a0d:	5e                   	pop    %esi
  801a0e:	5f                   	pop    %edi
  801a0f:	5d                   	pop    %ebp
  801a10:	c3                   	ret    

00801a11 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801a11:	55                   	push   %ebp
  801a12:	89 e5                	mov    %esp,%ebp
  801a14:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801a17:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801a1b:	75 07                	jne    801a24 <devcons_read+0x13>
  801a1d:	eb 23                	jmp    801a42 <devcons_read+0x31>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801a1f:	e8 49 f2 ff ff       	call   800c6d <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801a24:	e8 c5 f1 ff ff       	call   800bee <sys_cgetc>
  801a29:	85 c0                	test   %eax,%eax
  801a2b:	74 f2                	je     801a1f <devcons_read+0xe>
		sys_yield();
	if (c < 0)
  801a2d:	85 c0                	test   %eax,%eax
  801a2f:	78 1d                	js     801a4e <devcons_read+0x3d>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801a31:	83 f8 04             	cmp    $0x4,%eax
  801a34:	74 13                	je     801a49 <devcons_read+0x38>
		return 0;
	*(char*)vbuf = c;
  801a36:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a39:	88 02                	mov    %al,(%edx)
	return 1;
  801a3b:	b8 01 00 00 00       	mov    $0x1,%eax
  801a40:	eb 0c                	jmp    801a4e <devcons_read+0x3d>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801a42:	b8 00 00 00 00       	mov    $0x0,%eax
  801a47:	eb 05                	jmp    801a4e <devcons_read+0x3d>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801a49:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801a4e:	c9                   	leave  
  801a4f:	c3                   	ret    

00801a50 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801a50:	55                   	push   %ebp
  801a51:	89 e5                	mov    %esp,%ebp
  801a53:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801a56:	8b 45 08             	mov    0x8(%ebp),%eax
  801a59:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801a5c:	6a 01                	push   $0x1
  801a5e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a61:	50                   	push   %eax
  801a62:	e8 69 f1 ff ff       	call   800bd0 <sys_cputs>
}
  801a67:	83 c4 10             	add    $0x10,%esp
  801a6a:	c9                   	leave  
  801a6b:	c3                   	ret    

00801a6c <getchar>:

int
getchar(void)
{
  801a6c:	55                   	push   %ebp
  801a6d:	89 e5                	mov    %esp,%ebp
  801a6f:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801a72:	6a 01                	push   $0x1
  801a74:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a77:	50                   	push   %eax
  801a78:	6a 00                	push   $0x0
  801a7a:	e8 1a f7 ff ff       	call   801199 <read>
	if (r < 0)
  801a7f:	83 c4 10             	add    $0x10,%esp
  801a82:	85 c0                	test   %eax,%eax
  801a84:	78 0f                	js     801a95 <getchar+0x29>
		return r;
	if (r < 1)
  801a86:	85 c0                	test   %eax,%eax
  801a88:	7e 06                	jle    801a90 <getchar+0x24>
		return -E_EOF;
	return c;
  801a8a:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801a8e:	eb 05                	jmp    801a95 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801a90:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801a95:	c9                   	leave  
  801a96:	c3                   	ret    

00801a97 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801a97:	55                   	push   %ebp
  801a98:	89 e5                	mov    %esp,%ebp
  801a9a:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a9d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801aa0:	50                   	push   %eax
  801aa1:	ff 75 08             	pushl  0x8(%ebp)
  801aa4:	e8 6f f4 ff ff       	call   800f18 <fd_lookup>
  801aa9:	83 c4 10             	add    $0x10,%esp
  801aac:	85 c0                	test   %eax,%eax
  801aae:	78 11                	js     801ac1 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801ab0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ab3:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ab9:	39 10                	cmp    %edx,(%eax)
  801abb:	0f 94 c0             	sete   %al
  801abe:	0f b6 c0             	movzbl %al,%eax
}
  801ac1:	c9                   	leave  
  801ac2:	c3                   	ret    

00801ac3 <opencons>:

int
opencons(void)
{
  801ac3:	55                   	push   %ebp
  801ac4:	89 e5                	mov    %esp,%ebp
  801ac6:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ac9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801acc:	50                   	push   %eax
  801acd:	e8 d2 f3 ff ff       	call   800ea4 <fd_alloc>
  801ad2:	83 c4 10             	add    $0x10,%esp
  801ad5:	85 c0                	test   %eax,%eax
  801ad7:	78 3a                	js     801b13 <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ad9:	83 ec 04             	sub    $0x4,%esp
  801adc:	68 07 04 00 00       	push   $0x407
  801ae1:	ff 75 f4             	pushl  -0xc(%ebp)
  801ae4:	6a 00                	push   $0x0
  801ae6:	e8 a1 f1 ff ff       	call   800c8c <sys_page_alloc>
  801aeb:	83 c4 10             	add    $0x10,%esp
  801aee:	85 c0                	test   %eax,%eax
  801af0:	78 21                	js     801b13 <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801af2:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801af8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801afb:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801afd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b00:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801b07:	83 ec 0c             	sub    $0xc,%esp
  801b0a:	50                   	push   %eax
  801b0b:	e8 6d f3 ff ff       	call   800e7d <fd2num>
  801b10:	83 c4 10             	add    $0x10,%esp
}
  801b13:	c9                   	leave  
  801b14:	c3                   	ret    

00801b15 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801b15:	55                   	push   %ebp
  801b16:	89 e5                	mov    %esp,%ebp
  801b18:	56                   	push   %esi
  801b19:	53                   	push   %ebx
  801b1a:	8b 75 08             	mov    0x8(%ebp),%esi
  801b1d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b20:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");
	int r;
    if (pg != NULL) {
  801b23:	85 c0                	test   %eax,%eax
  801b25:	74 0e                	je     801b35 <ipc_recv+0x20>
        r = sys_ipc_recv(pg);
  801b27:	83 ec 0c             	sub    $0xc,%esp
  801b2a:	50                   	push   %eax
  801b2b:	e8 0c f3 ff ff       	call   800e3c <sys_ipc_recv>
  801b30:	83 c4 10             	add    $0x10,%esp
  801b33:	eb 10                	jmp    801b45 <ipc_recv+0x30>
    } else {
        r = sys_ipc_recv((void *) UTOP);
  801b35:	83 ec 0c             	sub    $0xc,%esp
  801b38:	68 00 00 c0 ee       	push   $0xeec00000
  801b3d:	e8 fa f2 ff ff       	call   800e3c <sys_ipc_recv>
  801b42:	83 c4 10             	add    $0x10,%esp
    }
    if (r < 0) {
  801b45:	85 c0                	test   %eax,%eax
  801b47:	79 16                	jns    801b5f <ipc_recv+0x4a>
        // failed
        if (from_env_store != NULL) *from_env_store = 0;
  801b49:	85 f6                	test   %esi,%esi
  801b4b:	74 06                	je     801b53 <ipc_recv+0x3e>
  801b4d:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        if (perm_store != NULL) *perm_store = 0;
  801b53:	85 db                	test   %ebx,%ebx
  801b55:	74 2c                	je     801b83 <ipc_recv+0x6e>
  801b57:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801b5d:	eb 24                	jmp    801b83 <ipc_recv+0x6e>
        return r;
    } else {
        if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801b5f:	85 f6                	test   %esi,%esi
  801b61:	74 0a                	je     801b6d <ipc_recv+0x58>
  801b63:	a1 20 40 c0 00       	mov    0xc04020,%eax
  801b68:	8b 40 74             	mov    0x74(%eax),%eax
  801b6b:	89 06                	mov    %eax,(%esi)
        if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801b6d:	85 db                	test   %ebx,%ebx
  801b6f:	74 0a                	je     801b7b <ipc_recv+0x66>
  801b71:	a1 20 40 c0 00       	mov    0xc04020,%eax
  801b76:	8b 40 78             	mov    0x78(%eax),%eax
  801b79:	89 03                	mov    %eax,(%ebx)
        return thisenv->env_ipc_value;
  801b7b:	a1 20 40 c0 00       	mov    0xc04020,%eax
  801b80:	8b 40 70             	mov    0x70(%eax),%eax
    }
 
	return 0;
}
  801b83:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b86:	5b                   	pop    %ebx
  801b87:	5e                   	pop    %esi
  801b88:	5d                   	pop    %ebp
  801b89:	c3                   	ret    

00801b8a <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801b8a:	55                   	push   %ebp
  801b8b:	89 e5                	mov    %esp,%ebp
  801b8d:	57                   	push   %edi
  801b8e:	56                   	push   %esi
  801b8f:	53                   	push   %ebx
  801b90:	83 ec 0c             	sub    $0xc,%esp
  801b93:	8b 75 10             	mov    0x10(%ebp),%esi
  801b96:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");
	int r;
    if (pg == NULL) pg = (void *)UTOP;
  801b99:	85 f6                	test   %esi,%esi
  801b9b:	75 05                	jne    801ba2 <ipc_send+0x18>
  801b9d:	be 00 00 c0 ee       	mov    $0xeec00000,%esi
    do {
        r = sys_ipc_try_send(to_env, val, pg, perm);
  801ba2:	57                   	push   %edi
  801ba3:	56                   	push   %esi
  801ba4:	ff 75 0c             	pushl  0xc(%ebp)
  801ba7:	ff 75 08             	pushl  0x8(%ebp)
  801baa:	e8 6a f2 ff ff       	call   800e19 <sys_ipc_try_send>
  801baf:	89 c3                	mov    %eax,%ebx
        if (r < 0 && r != -E_IPC_NOT_RECV) panic("ipc send failed: %e", r);
  801bb1:	83 c4 10             	add    $0x10,%esp
  801bb4:	85 c0                	test   %eax,%eax
  801bb6:	79 17                	jns    801bcf <ipc_send+0x45>
  801bb8:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801bbb:	74 1d                	je     801bda <ipc_send+0x50>
  801bbd:	50                   	push   %eax
  801bbe:	68 e7 23 80 00       	push   $0x8023e7
  801bc3:	6a 40                	push   $0x40
  801bc5:	68 fb 23 80 00       	push   $0x8023fb
  801bca:	e8 90 e5 ff ff       	call   80015f <_panic>
        sys_yield();
  801bcf:	e8 99 f0 ff ff       	call   800c6d <sys_yield>
    } while (r != 0);
  801bd4:	85 db                	test   %ebx,%ebx
  801bd6:	75 ca                	jne    801ba2 <ipc_send+0x18>
  801bd8:	eb 07                	jmp    801be1 <ipc_send+0x57>
	int r;
    if (pg == NULL) pg = (void *)UTOP;
    do {
        r = sys_ipc_try_send(to_env, val, pg, perm);
        if (r < 0 && r != -E_IPC_NOT_RECV) panic("ipc send failed: %e", r);
        sys_yield();
  801bda:	e8 8e f0 ff ff       	call   800c6d <sys_yield>
  801bdf:	eb c1                	jmp    801ba2 <ipc_send+0x18>
    } while (r != 0);
}
  801be1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801be4:	5b                   	pop    %ebx
  801be5:	5e                   	pop    %esi
  801be6:	5f                   	pop    %edi
  801be7:	5d                   	pop    %ebp
  801be8:	c3                   	ret    

00801be9 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801be9:	55                   	push   %ebp
  801bea:	89 e5                	mov    %esp,%ebp
  801bec:	53                   	push   %ebx
  801bed:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801bf0:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  801bf5:	39 c1                	cmp    %eax,%ecx
  801bf7:	74 21                	je     801c1a <ipc_find_env+0x31>
  801bf9:	ba 01 00 00 00       	mov    $0x1,%edx
  801bfe:	8d 1c 95 00 00 00 00 	lea    0x0(,%edx,4),%ebx
  801c05:	89 d0                	mov    %edx,%eax
  801c07:	c1 e0 07             	shl    $0x7,%eax
  801c0a:	29 d8                	sub    %ebx,%eax
  801c0c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801c11:	8b 40 50             	mov    0x50(%eax),%eax
  801c14:	39 c8                	cmp    %ecx,%eax
  801c16:	75 1b                	jne    801c33 <ipc_find_env+0x4a>
  801c18:	eb 05                	jmp    801c1f <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801c1a:	ba 00 00 00 00       	mov    $0x0,%edx
		if (envs[i].env_type == type)
			return envs[i].env_id;
  801c1f:	8d 04 95 00 00 00 00 	lea    0x0(,%edx,4),%eax
  801c26:	c1 e2 07             	shl    $0x7,%edx
  801c29:	29 c2                	sub    %eax,%edx
  801c2b:	8b 82 48 00 c0 ee    	mov    -0x113fffb8(%edx),%eax
  801c31:	eb 0e                	jmp    801c41 <ipc_find_env+0x58>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801c33:	42                   	inc    %edx
  801c34:	81 fa 00 04 00 00    	cmp    $0x400,%edx
  801c3a:	75 c2                	jne    801bfe <ipc_find_env+0x15>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801c3c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c41:	5b                   	pop    %ebx
  801c42:	5d                   	pop    %ebp
  801c43:	c3                   	ret    

00801c44 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801c44:	55                   	push   %ebp
  801c45:	89 e5                	mov    %esp,%ebp
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c47:	8b 45 08             	mov    0x8(%ebp),%eax
  801c4a:	c1 e8 16             	shr    $0x16,%eax
  801c4d:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801c54:	a8 01                	test   $0x1,%al
  801c56:	74 21                	je     801c79 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801c58:	8b 45 08             	mov    0x8(%ebp),%eax
  801c5b:	c1 e8 0c             	shr    $0xc,%eax
  801c5e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801c65:	a8 01                	test   $0x1,%al
  801c67:	74 17                	je     801c80 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801c69:	c1 e8 0c             	shr    $0xc,%eax
  801c6c:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801c73:	ef 
  801c74:	0f b7 c0             	movzwl %ax,%eax
  801c77:	eb 0c                	jmp    801c85 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801c79:	b8 00 00 00 00       	mov    $0x0,%eax
  801c7e:	eb 05                	jmp    801c85 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801c80:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801c85:	5d                   	pop    %ebp
  801c86:	c3                   	ret    
  801c87:	90                   	nop

00801c88 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801c88:	55                   	push   %ebp
  801c89:	57                   	push   %edi
  801c8a:	56                   	push   %esi
  801c8b:	53                   	push   %ebx
  801c8c:	83 ec 1c             	sub    $0x1c,%esp
  801c8f:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801c93:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801c97:	8b 7c 24 38          	mov    0x38(%esp),%edi
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801c9b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801c9f:	89 ca                	mov    %ecx,%edx
  const DWunion dd = {.ll = d};
  801ca1:	89 f8                	mov    %edi,%eax
  801ca3:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801ca7:	85 f6                	test   %esi,%esi
  801ca9:	75 2d                	jne    801cd8 <__udivdi3+0x50>
    {
      if (d0 > n1)
  801cab:	39 cf                	cmp    %ecx,%edi
  801cad:	77 65                	ja     801d14 <__udivdi3+0x8c>
  801caf:	89 fd                	mov    %edi,%ebp
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801cb1:	85 ff                	test   %edi,%edi
  801cb3:	75 0b                	jne    801cc0 <__udivdi3+0x38>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801cb5:	b8 01 00 00 00       	mov    $0x1,%eax
  801cba:	31 d2                	xor    %edx,%edx
  801cbc:	f7 f7                	div    %edi
  801cbe:	89 c5                	mov    %eax,%ebp

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801cc0:	31 d2                	xor    %edx,%edx
  801cc2:	89 c8                	mov    %ecx,%eax
  801cc4:	f7 f5                	div    %ebp
  801cc6:	89 c1                	mov    %eax,%ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801cc8:	89 d8                	mov    %ebx,%eax
  801cca:	f7 f5                	div    %ebp
  801ccc:	89 cf                	mov    %ecx,%edi
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801cce:	89 fa                	mov    %edi,%edx
  801cd0:	83 c4 1c             	add    $0x1c,%esp
  801cd3:	5b                   	pop    %ebx
  801cd4:	5e                   	pop    %esi
  801cd5:	5f                   	pop    %edi
  801cd6:	5d                   	pop    %ebp
  801cd7:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801cd8:	39 ce                	cmp    %ecx,%esi
  801cda:	77 28                	ja     801d04 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801cdc:	0f bd fe             	bsr    %esi,%edi
	  if (bm == 0)
  801cdf:	83 f7 1f             	xor    $0x1f,%edi
  801ce2:	75 40                	jne    801d24 <__udivdi3+0x9c>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801ce4:	39 ce                	cmp    %ecx,%esi
  801ce6:	72 0a                	jb     801cf2 <__udivdi3+0x6a>
  801ce8:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801cec:	0f 87 9e 00 00 00    	ja     801d90 <__udivdi3+0x108>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801cf2:	b8 01 00 00 00       	mov    $0x1,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801cf7:	89 fa                	mov    %edi,%edx
  801cf9:	83 c4 1c             	add    $0x1c,%esp
  801cfc:	5b                   	pop    %ebx
  801cfd:	5e                   	pop    %esi
  801cfe:	5f                   	pop    %edi
  801cff:	5d                   	pop    %ebp
  801d00:	c3                   	ret    
  801d01:	8d 76 00             	lea    0x0(%esi),%esi
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801d04:	31 ff                	xor    %edi,%edi
  801d06:	31 c0                	xor    %eax,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801d08:	89 fa                	mov    %edi,%edx
  801d0a:	83 c4 1c             	add    $0x1c,%esp
  801d0d:	5b                   	pop    %ebx
  801d0e:	5e                   	pop    %esi
  801d0f:	5f                   	pop    %edi
  801d10:	5d                   	pop    %ebp
  801d11:	c3                   	ret    
  801d12:	66 90                	xchg   %ax,%ax
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801d14:	89 d8                	mov    %ebx,%eax
  801d16:	f7 f7                	div    %edi
  801d18:	31 ff                	xor    %edi,%edi
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801d1a:	89 fa                	mov    %edi,%edx
  801d1c:	83 c4 1c             	add    $0x1c,%esp
  801d1f:	5b                   	pop    %ebx
  801d20:	5e                   	pop    %esi
  801d21:	5f                   	pop    %edi
  801d22:	5d                   	pop    %ebp
  801d23:	c3                   	ret    
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801d24:	bd 20 00 00 00       	mov    $0x20,%ebp
  801d29:	89 eb                	mov    %ebp,%ebx
  801d2b:	29 fb                	sub    %edi,%ebx

	      d1 = (d1 << bm) | (d0 >> b);
  801d2d:	89 f9                	mov    %edi,%ecx
  801d2f:	d3 e6                	shl    %cl,%esi
  801d31:	89 c5                	mov    %eax,%ebp
  801d33:	88 d9                	mov    %bl,%cl
  801d35:	d3 ed                	shr    %cl,%ebp
  801d37:	89 e9                	mov    %ebp,%ecx
  801d39:	09 f1                	or     %esi,%ecx
  801d3b:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
	      d0 = d0 << bm;
  801d3f:	89 f9                	mov    %edi,%ecx
  801d41:	d3 e0                	shl    %cl,%eax
  801d43:	89 c5                	mov    %eax,%ebp
	      n2 = n1 >> b;
  801d45:	89 d6                	mov    %edx,%esi
  801d47:	88 d9                	mov    %bl,%cl
  801d49:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
  801d4b:	89 f9                	mov    %edi,%ecx
  801d4d:	d3 e2                	shl    %cl,%edx
  801d4f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801d53:	88 d9                	mov    %bl,%cl
  801d55:	d3 e8                	shr    %cl,%eax
  801d57:	09 c2                	or     %eax,%edx
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801d59:	89 d0                	mov    %edx,%eax
  801d5b:	89 f2                	mov    %esi,%edx
  801d5d:	f7 74 24 0c          	divl   0xc(%esp)
  801d61:	89 d6                	mov    %edx,%esi
  801d63:	89 c3                	mov    %eax,%ebx
	      umul_ppmm (m1, m0, q0, d0);
  801d65:	f7 e5                	mul    %ebp

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801d67:	39 d6                	cmp    %edx,%esi
  801d69:	72 19                	jb     801d84 <__udivdi3+0xfc>
  801d6b:	74 0b                	je     801d78 <__udivdi3+0xf0>
  801d6d:	89 d8                	mov    %ebx,%eax
  801d6f:	31 ff                	xor    %edi,%edi
  801d71:	e9 58 ff ff ff       	jmp    801cce <__udivdi3+0x46>
  801d76:	66 90                	xchg   %ax,%ax
  801d78:	8b 54 24 08          	mov    0x8(%esp),%edx
  801d7c:	89 f9                	mov    %edi,%ecx
  801d7e:	d3 e2                	shl    %cl,%edx
  801d80:	39 c2                	cmp    %eax,%edx
  801d82:	73 e9                	jae    801d6d <__udivdi3+0xe5>
  801d84:	8d 43 ff             	lea    -0x1(%ebx),%eax
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801d87:	31 ff                	xor    %edi,%edi
  801d89:	e9 40 ff ff ff       	jmp    801cce <__udivdi3+0x46>
  801d8e:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801d90:	31 c0                	xor    %eax,%eax
  801d92:	e9 37 ff ff ff       	jmp    801cce <__udivdi3+0x46>
  801d97:	90                   	nop

00801d98 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  801d98:	55                   	push   %ebp
  801d99:	57                   	push   %edi
  801d9a:	56                   	push   %esi
  801d9b:	53                   	push   %ebx
  801d9c:	83 ec 1c             	sub    $0x1c,%esp
  801d9f:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801da3:	8b 74 24 34          	mov    0x34(%esp),%esi
  801da7:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801dab:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801daf:	89 44 24 0c          	mov    %eax,0xc(%esp)
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801db3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801db7:	89 f3                	mov    %esi,%ebx
  const DWunion dd = {.ll = d};
  801db9:	89 fa                	mov    %edi,%edx
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  801dbb:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  n1 = nn.s.high;
  801dbf:	89 34 24             	mov    %esi,(%esp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801dc2:	85 c0                	test   %eax,%eax
  801dc4:	75 1a                	jne    801de0 <__umoddi3+0x48>
    {
      if (d0 > n1)
  801dc6:	39 f7                	cmp    %esi,%edi
  801dc8:	0f 86 a2 00 00 00    	jbe    801e70 <__umoddi3+0xd8>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801dce:	89 c8                	mov    %ecx,%eax
  801dd0:	89 f2                	mov    %esi,%edx
  801dd2:	f7 f7                	div    %edi
  801dd4:	89 d0                	mov    %edx,%eax

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  801dd6:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801dd8:	83 c4 1c             	add    $0x1c,%esp
  801ddb:	5b                   	pop    %ebx
  801ddc:	5e                   	pop    %esi
  801ddd:	5f                   	pop    %edi
  801dde:	5d                   	pop    %ebp
  801ddf:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801de0:	39 f0                	cmp    %esi,%eax
  801de2:	0f 87 ac 00 00 00    	ja     801e94 <__umoddi3+0xfc>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801de8:	0f bd e8             	bsr    %eax,%ebp
	  if (bm == 0)
  801deb:	83 f5 1f             	xor    $0x1f,%ebp
  801dee:	0f 84 ac 00 00 00    	je     801ea0 <__umoddi3+0x108>
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801df4:	bf 20 00 00 00       	mov    $0x20,%edi
  801df9:	29 ef                	sub    %ebp,%edi
  801dfb:	89 fe                	mov    %edi,%esi
  801dfd:	89 7c 24 0c          	mov    %edi,0xc(%esp)

	      d1 = (d1 << bm) | (d0 >> b);
  801e01:	89 e9                	mov    %ebp,%ecx
  801e03:	d3 e0                	shl    %cl,%eax
  801e05:	89 d7                	mov    %edx,%edi
  801e07:	89 f1                	mov    %esi,%ecx
  801e09:	d3 ef                	shr    %cl,%edi
  801e0b:	09 c7                	or     %eax,%edi
	      d0 = d0 << bm;
  801e0d:	89 e9                	mov    %ebp,%ecx
  801e0f:	d3 e2                	shl    %cl,%edx
  801e11:	89 14 24             	mov    %edx,(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801e14:	89 d8                	mov    %ebx,%eax
  801e16:	d3 e0                	shl    %cl,%eax
  801e18:	89 c2                	mov    %eax,%edx
	      n0 = n0 << bm;
  801e1a:	8b 44 24 08          	mov    0x8(%esp),%eax
  801e1e:	d3 e0                	shl    %cl,%eax
  801e20:	89 44 24 04          	mov    %eax,0x4(%esp)

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801e24:	8b 44 24 08          	mov    0x8(%esp),%eax
  801e28:	89 f1                	mov    %esi,%ecx
  801e2a:	d3 e8                	shr    %cl,%eax
  801e2c:	09 d0                	or     %edx,%eax
  801e2e:	d3 eb                	shr    %cl,%ebx
  801e30:	89 da                	mov    %ebx,%edx
  801e32:	f7 f7                	div    %edi
  801e34:	89 d3                	mov    %edx,%ebx
	      umul_ppmm (m1, m0, q0, d0);
  801e36:	f7 24 24             	mull   (%esp)
  801e39:	89 c6                	mov    %eax,%esi
  801e3b:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801e3d:	39 d3                	cmp    %edx,%ebx
  801e3f:	0f 82 87 00 00 00    	jb     801ecc <__umoddi3+0x134>
  801e45:	0f 84 91 00 00 00    	je     801edc <__umoddi3+0x144>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  801e4b:	8b 54 24 04          	mov    0x4(%esp),%edx
  801e4f:	29 f2                	sub    %esi,%edx
  801e51:	19 cb                	sbb    %ecx,%ebx
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801e53:	89 d8                	mov    %ebx,%eax
  801e55:	8a 4c 24 0c          	mov    0xc(%esp),%cl
  801e59:	d3 e0                	shl    %cl,%eax
  801e5b:	89 e9                	mov    %ebp,%ecx
  801e5d:	d3 ea                	shr    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  801e5f:	09 d0                	or     %edx,%eax
  801e61:	89 e9                	mov    %ebp,%ecx
  801e63:	d3 eb                	shr    %cl,%ebx
  801e65:	89 da                	mov    %ebx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801e67:	83 c4 1c             	add    $0x1c,%esp
  801e6a:	5b                   	pop    %ebx
  801e6b:	5e                   	pop    %esi
  801e6c:	5f                   	pop    %edi
  801e6d:	5d                   	pop    %ebp
  801e6e:	c3                   	ret    
  801e6f:	90                   	nop
  801e70:	89 fd                	mov    %edi,%ebp
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801e72:	85 ff                	test   %edi,%edi
  801e74:	75 0b                	jne    801e81 <__umoddi3+0xe9>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801e76:	b8 01 00 00 00       	mov    $0x1,%eax
  801e7b:	31 d2                	xor    %edx,%edx
  801e7d:	f7 f7                	div    %edi
  801e7f:	89 c5                	mov    %eax,%ebp

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801e81:	89 f0                	mov    %esi,%eax
  801e83:	31 d2                	xor    %edx,%edx
  801e85:	f7 f5                	div    %ebp
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801e87:	89 c8                	mov    %ecx,%eax
  801e89:	f7 f5                	div    %ebp
  801e8b:	89 d0                	mov    %edx,%eax
  801e8d:	e9 44 ff ff ff       	jmp    801dd6 <__umoddi3+0x3e>
  801e92:	66 90                	xchg   %ax,%ax
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  801e94:	89 c8                	mov    %ecx,%eax
  801e96:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801e98:	83 c4 1c             	add    $0x1c,%esp
  801e9b:	5b                   	pop    %ebx
  801e9c:	5e                   	pop    %esi
  801e9d:	5f                   	pop    %edi
  801e9e:	5d                   	pop    %ebp
  801e9f:	c3                   	ret    

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801ea0:	3b 04 24             	cmp    (%esp),%eax
  801ea3:	72 06                	jb     801eab <__umoddi3+0x113>
  801ea5:	3b 7c 24 04          	cmp    0x4(%esp),%edi
  801ea9:	77 0f                	ja     801eba <__umoddi3+0x122>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801eab:	89 f2                	mov    %esi,%edx
  801ead:	29 f9                	sub    %edi,%ecx
  801eaf:	1b 54 24 0c          	sbb    0xc(%esp),%edx
  801eb3:	89 14 24             	mov    %edx,(%esp)
  801eb6:	89 4c 24 04          	mov    %ecx,0x4(%esp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  801eba:	8b 44 24 04          	mov    0x4(%esp),%eax
  801ebe:	8b 14 24             	mov    (%esp),%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801ec1:	83 c4 1c             	add    $0x1c,%esp
  801ec4:	5b                   	pop    %ebx
  801ec5:	5e                   	pop    %esi
  801ec6:	5f                   	pop    %edi
  801ec7:	5d                   	pop    %ebp
  801ec8:	c3                   	ret    
  801ec9:	8d 76 00             	lea    0x0(%esi),%esi
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801ecc:	2b 04 24             	sub    (%esp),%eax
  801ecf:	19 fa                	sbb    %edi,%edx
  801ed1:	89 d1                	mov    %edx,%ecx
  801ed3:	89 c6                	mov    %eax,%esi
  801ed5:	e9 71 ff ff ff       	jmp    801e4b <__umoddi3+0xb3>
  801eda:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801edc:	39 44 24 04          	cmp    %eax,0x4(%esp)
  801ee0:	72 ea                	jb     801ecc <__umoddi3+0x134>
  801ee2:	89 d9                	mov    %ebx,%ecx
  801ee4:	e9 62 ff ff ff       	jmp    801e4b <__umoddi3+0xb3>
