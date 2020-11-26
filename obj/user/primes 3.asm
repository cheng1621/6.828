
obj/user/primes.debug:     file format elf32-i386


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

00800033 <primeproc>:

#include <inc/lib.h>

unsigned
primeproc(void)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 1c             	sub    $0x1c,%esp
	int i, id, p;
	envid_t envid;

	// fetch a prime from our left neighbor
top:
	p = ipc_recv(&envid, 0, 0);
  80003c:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  80003f:	83 ec 04             	sub    $0x4,%esp
  800042:	6a 00                	push   $0x0
  800044:	6a 00                	push   $0x0
  800046:	56                   	push   %esi
  800047:	e8 0c 11 00 00       	call   801158 <ipc_recv>
  80004c:	89 c3                	mov    %eax,%ebx
	cprintf("CPU %d: %d ", thisenv->env_cpunum, p);
  80004e:	a1 04 40 80 00       	mov    0x804004,%eax
  800053:	8b 40 5c             	mov    0x5c(%eax),%eax
  800056:	83 c4 0c             	add    $0xc,%esp
  800059:	53                   	push   %ebx
  80005a:	50                   	push   %eax
  80005b:	68 80 22 80 00       	push   $0x802280
  800060:	e8 d2 01 00 00       	call   800237 <cprintf>

	// fork a right neighbor to continue the chain
	if ((id = fork()) < 0)
  800065:	e8 02 0f 00 00       	call   800f6c <fork>
  80006a:	89 c7                	mov    %eax,%edi
  80006c:	83 c4 10             	add    $0x10,%esp
  80006f:	85 c0                	test   %eax,%eax
  800071:	79 12                	jns    800085 <primeproc+0x52>
		panic("fork: %e", id);
  800073:	50                   	push   %eax
  800074:	68 8c 22 80 00       	push   $0x80228c
  800079:	6a 1a                	push   $0x1a
  80007b:	68 95 22 80 00       	push   $0x802295
  800080:	e8 da 00 00 00       	call   80015f <_panic>
	if (id == 0)
  800085:	85 c0                	test   %eax,%eax
  800087:	74 b6                	je     80003f <primeproc+0xc>
		goto top;

	// filter out multiples of our prime
	while (1) {
		i = ipc_recv(&envid, 0, 0);
  800089:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  80008c:	83 ec 04             	sub    $0x4,%esp
  80008f:	6a 00                	push   $0x0
  800091:	6a 00                	push   $0x0
  800093:	56                   	push   %esi
  800094:	e8 bf 10 00 00       	call   801158 <ipc_recv>
  800099:	89 c1                	mov    %eax,%ecx
		if (i % p)
  80009b:	99                   	cltd   
  80009c:	f7 fb                	idiv   %ebx
  80009e:	83 c4 10             	add    $0x10,%esp
  8000a1:	85 d2                	test   %edx,%edx
  8000a3:	74 e7                	je     80008c <primeproc+0x59>
			ipc_send(id, i, 0, 0);
  8000a5:	6a 00                	push   $0x0
  8000a7:	6a 00                	push   $0x0
  8000a9:	51                   	push   %ecx
  8000aa:	57                   	push   %edi
  8000ab:	e8 1d 11 00 00       	call   8011cd <ipc_send>
  8000b0:	83 c4 10             	add    $0x10,%esp
  8000b3:	eb d7                	jmp    80008c <primeproc+0x59>

008000b5 <umain>:
	}
}

void
umain(int argc, char **argv)
{
  8000b5:	55                   	push   %ebp
  8000b6:	89 e5                	mov    %esp,%ebp
  8000b8:	56                   	push   %esi
  8000b9:	53                   	push   %ebx
	int i, id;

	// fork the first prime process in the chain
	if ((id = fork()) < 0)
  8000ba:	e8 ad 0e 00 00       	call   800f6c <fork>
  8000bf:	89 c6                	mov    %eax,%esi
  8000c1:	85 c0                	test   %eax,%eax
  8000c3:	79 12                	jns    8000d7 <umain+0x22>
		panic("fork: %e", id);
  8000c5:	50                   	push   %eax
  8000c6:	68 8c 22 80 00       	push   $0x80228c
  8000cb:	6a 2d                	push   $0x2d
  8000cd:	68 95 22 80 00       	push   $0x802295
  8000d2:	e8 88 00 00 00       	call   80015f <_panic>
	if (id == 0)
  8000d7:	85 c0                	test   %eax,%eax
  8000d9:	75 05                	jne    8000e0 <umain+0x2b>
		primeproc();
  8000db:	e8 53 ff ff ff       	call   800033 <primeproc>
  8000e0:	bb 02 00 00 00       	mov    $0x2,%ebx

	// feed all the integers through
	for (i = 2; ; i++)
		ipc_send(id, i, 0, 0);
  8000e5:	6a 00                	push   $0x0
  8000e7:	6a 00                	push   $0x0
  8000e9:	53                   	push   %ebx
  8000ea:	56                   	push   %esi
  8000eb:	e8 dd 10 00 00       	call   8011cd <ipc_send>
		panic("fork: %e", id);
	if (id == 0)
		primeproc();

	// feed all the integers through
	for (i = 2; ; i++)
  8000f0:	43                   	inc    %ebx
  8000f1:	83 c4 10             	add    $0x10,%esp
  8000f4:	eb ef                	jmp    8000e5 <umain+0x30>

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
  80011c:	a3 04 40 80 00       	mov    %eax,0x804004

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
  800131:	e8 7f ff ff ff       	call   8000b5 <umain>

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
  80014b:	e8 46 13 00 00       	call   801496 <close_all>
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
  80017d:	68 b0 22 80 00       	push   $0x8022b0
  800182:	e8 b0 00 00 00       	call   800237 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800187:	83 c4 18             	add    $0x18,%esp
  80018a:	53                   	push   %ebx
  80018b:	ff 75 10             	pushl  0x10(%ebp)
  80018e:	e8 53 00 00 00       	call   8001e6 <vcprintf>
	cprintf("\n");
  800193:	c7 04 24 4b 26 80 00 	movl   $0x80264b,(%esp)
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
  8002a4:	e8 57 1d 00 00       	call   802000 <__udivdi3>
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
  8002de:	e8 2d 1e 00 00       	call   802110 <__umoddi3>
  8002e3:	83 c4 14             	add    $0x14,%esp
  8002e6:	0f be 80 d3 22 80 00 	movsbl 0x8022d3(%eax),%eax
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
  8003f7:	ff 24 85 20 24 80 00 	jmp    *0x802420(,%eax,4)
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
  8004c7:	8b 04 85 80 25 80 00 	mov    0x802580(,%eax,4),%eax
  8004ce:	85 c0                	test   %eax,%eax
  8004d0:	75 15                	jne    8004e7 <vprintfmt+0x179>
				printfmt(putch, putdat, "error %d", err);
  8004d2:	52                   	push   %edx
  8004d3:	68 eb 22 80 00       	push   $0x8022eb
  8004d8:	53                   	push   %ebx
  8004d9:	57                   	push   %edi
  8004da:	e8 72 fe ff ff       	call   800351 <printfmt>
  8004df:	83 c4 10             	add    $0x10,%esp
  8004e2:	e9 9b fe ff ff       	jmp    800382 <vprintfmt+0x14>
			else
				printfmt(putch, putdat, "%s", p);
  8004e7:	50                   	push   %eax
  8004e8:	68 aa 27 80 00       	push   $0x8027aa
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
  80050e:	c7 45 d4 e4 22 80 00 	movl   $0x8022e4,-0x2c(%ebp)
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
  800c35:	68 df 25 80 00       	push   $0x8025df
  800c3a:	6a 23                	push   $0x23
  800c3c:	68 fc 25 80 00       	push   $0x8025fc
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
  800cb6:	68 df 25 80 00       	push   $0x8025df
  800cbb:	6a 23                	push   $0x23
  800cbd:	68 fc 25 80 00       	push   $0x8025fc
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
  800cf8:	68 df 25 80 00       	push   $0x8025df
  800cfd:	6a 23                	push   $0x23
  800cff:	68 fc 25 80 00       	push   $0x8025fc
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
  800d3a:	68 df 25 80 00       	push   $0x8025df
  800d3f:	6a 23                	push   $0x23
  800d41:	68 fc 25 80 00       	push   $0x8025fc
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
  800d7c:	68 df 25 80 00       	push   $0x8025df
  800d81:	6a 23                	push   $0x23
  800d83:	68 fc 25 80 00       	push   $0x8025fc
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
  800dbe:	68 df 25 80 00       	push   $0x8025df
  800dc3:	6a 23                	push   $0x23
  800dc5:	68 fc 25 80 00       	push   $0x8025fc
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
  800e00:	68 df 25 80 00       	push   $0x8025df
  800e05:	6a 23                	push   $0x23
  800e07:	68 fc 25 80 00       	push   $0x8025fc
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
  800e64:	68 df 25 80 00       	push   $0x8025df
  800e69:	6a 23                	push   $0x23
  800e6b:	68 fc 25 80 00       	push   $0x8025fc
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

00800e7d <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e7d:	55                   	push   %ebp
  800e7e:	89 e5                	mov    %esp,%ebp
  800e80:	56                   	push   %esi
  800e81:	53                   	push   %ebx
  800e82:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e85:	8b 18                	mov    (%eax),%ebx
	// copy-on-write page.  If not, panic.
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).
	
	if((err & FEC_WR) == 0){
  800e87:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e8b:	75 14                	jne    800ea1 <pgfault+0x24>
		panic("pgfault not cause by write \n");
  800e8d:	83 ec 04             	sub    $0x4,%esp
  800e90:	68 0a 26 80 00       	push   $0x80260a
  800e95:	6a 1c                	push   $0x1c
  800e97:	68 27 26 80 00       	push   $0x802627
  800e9c:	e8 be f2 ff ff       	call   80015f <_panic>
	}
 
	if ((uvpt[PGNUM(addr)] & PTE_COW) == 0) 
  800ea1:	89 d8                	mov    %ebx,%eax
  800ea3:	c1 e8 0c             	shr    $0xc,%eax
  800ea6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800ead:	f6 c4 08             	test   $0x8,%ah
  800eb0:	75 14                	jne    800ec6 <pgfault+0x49>
    {
        panic("pgfault not cause by COW \n");
  800eb2:	83 ec 04             	sub    $0x4,%esp
  800eb5:	68 32 26 80 00       	push   $0x802632
  800eba:	6a 21                	push   $0x21
  800ebc:	68 27 26 80 00       	push   $0x802627
  800ec1:	e8 99 f2 ff ff       	call   80015f <_panic>
	// copy the data from the old page to the new page, then move the new
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.
	envid_t eid = sys_getenvid();
  800ec6:	e8 83 fd ff ff       	call   800c4e <sys_getenvid>
  800ecb:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(eid,(void*)PFTEMP,PTE_P|PTE_W|PTE_U)) < 0)
  800ecd:	83 ec 04             	sub    $0x4,%esp
  800ed0:	6a 07                	push   $0x7
  800ed2:	68 00 f0 7f 00       	push   $0x7ff000
  800ed7:	50                   	push   %eax
  800ed8:	e8 af fd ff ff       	call   800c8c <sys_page_alloc>
  800edd:	83 c4 10             	add    $0x10,%esp
  800ee0:	85 c0                	test   %eax,%eax
  800ee2:	79 14                	jns    800ef8 <pgfault+0x7b>
		panic("page alloction failed.\n");
  800ee4:	83 ec 04             	sub    $0x4,%esp
  800ee7:	68 4d 26 80 00       	push   $0x80264d
  800eec:	6a 2d                	push   $0x2d
  800eee:	68 27 26 80 00       	push   $0x802627
  800ef3:	e8 67 f2 ff ff       	call   80015f <_panic>
	addr = ROUNDDOWN(addr,PGSIZE);
  800ef8:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memmove(PFTEMP,addr,PGSIZE);
  800efe:	83 ec 04             	sub    $0x4,%esp
  800f01:	68 00 10 00 00       	push   $0x1000
  800f06:	53                   	push   %ebx
  800f07:	68 00 f0 7f 00       	push   $0x7ff000
  800f0c:	e8 d8 fa ff ff       	call   8009e9 <memmove>
	if ((r = sys_page_map(eid, PFTEMP, eid, addr, PTE_P | PTE_W |PTE_U)) < 0)
  800f11:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f18:	53                   	push   %ebx
  800f19:	56                   	push   %esi
  800f1a:	68 00 f0 7f 00       	push   $0x7ff000
  800f1f:	56                   	push   %esi
  800f20:	e8 aa fd ff ff       	call   800ccf <sys_page_map>
  800f25:	83 c4 20             	add    $0x20,%esp
  800f28:	85 c0                	test   %eax,%eax
  800f2a:	79 12                	jns    800f3e <pgfault+0xc1>
        panic("pgfault: page map failed %e\n", r);
  800f2c:	50                   	push   %eax
  800f2d:	68 65 26 80 00       	push   $0x802665
  800f32:	6a 31                	push   $0x31
  800f34:	68 27 26 80 00       	push   $0x802627
  800f39:	e8 21 f2 ff ff       	call   80015f <_panic>
	if ((r = sys_page_unmap(eid, PFTEMP)) < 0)
  800f3e:	83 ec 08             	sub    $0x8,%esp
  800f41:	68 00 f0 7f 00       	push   $0x7ff000
  800f46:	56                   	push   %esi
  800f47:	e8 c5 fd ff ff       	call   800d11 <sys_page_unmap>
  800f4c:	83 c4 10             	add    $0x10,%esp
  800f4f:	85 c0                	test   %eax,%eax
  800f51:	79 12                	jns    800f65 <pgfault+0xe8>
        panic("pgfault: page unmap failed %e\n", r);
  800f53:	50                   	push   %eax
  800f54:	68 d4 26 80 00       	push   $0x8026d4
  800f59:	6a 33                	push   $0x33
  800f5b:	68 27 26 80 00       	push   $0x802627
  800f60:	e8 fa f1 ff ff       	call   80015f <_panic>
	// LAB 4: Your code here.

	// panic("pgfault not implemented");
}
  800f65:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f68:	5b                   	pop    %ebx
  800f69:	5e                   	pop    %esi
  800f6a:	5d                   	pop    %ebp
  800f6b:	c3                   	ret    

00800f6c <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f6c:	55                   	push   %ebp
  800f6d:	89 e5                	mov    %esp,%ebp
  800f6f:	57                   	push   %edi
  800f70:	56                   	push   %esi
  800f71:	53                   	push   %ebx
  800f72:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	struct PageInfo* pg = NULL;
	set_pgfault_handler(pgfault);
  800f75:	68 7d 0e 80 00       	push   $0x800e7d
  800f7a:	e8 a0 0f 00 00       	call   801f1f <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800f7f:	b8 07 00 00 00       	mov    $0x7,%eax
  800f84:	cd 30                	int    $0x30
  800f86:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800f89:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t eid = sys_exofork();
	if (eid < 0) panic("fork fault.\n");
  800f8c:	83 c4 10             	add    $0x10,%esp
  800f8f:	85 c0                	test   %eax,%eax
  800f91:	79 14                	jns    800fa7 <fork+0x3b>
  800f93:	83 ec 04             	sub    $0x4,%esp
  800f96:	68 82 26 80 00       	push   $0x802682
  800f9b:	6a 71                	push   $0x71
  800f9d:	68 27 26 80 00       	push   $0x802627
  800fa2:	e8 b8 f1 ff ff       	call   80015f <_panic>
	if (eid == 0){
  800fa7:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800fab:	75 25                	jne    800fd2 <fork+0x66>
		thisenv = &envs[ENVX(sys_getenvid())];
  800fad:	e8 9c fc ff ff       	call   800c4e <sys_getenvid>
  800fb2:	25 ff 03 00 00       	and    $0x3ff,%eax
  800fb7:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800fbe:	c1 e0 07             	shl    $0x7,%eax
  800fc1:	29 d0                	sub    %edx,%eax
  800fc3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800fc8:	a3 04 40 80 00       	mov    %eax,0x804004
		return eid;
  800fcd:	e9 61 01 00 00       	jmp    801133 <fork+0x1c7>
  800fd2:	bb 00 00 80 00       	mov    $0x800000,%ebx
	}
	// copy something to the child page.
	for (uintptr_t i = UTEXT;i <= USTACKTOP;i += PGSIZE){
		if (uvpd[PDX(i)] & PTE_P && (uvpt[PGNUM(i)] & PTE_P)){
  800fd7:	89 d8                	mov    %ebx,%eax
  800fd9:	c1 e8 16             	shr    $0x16,%eax
  800fdc:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fe3:	a8 01                	test   $0x1,%al
  800fe5:	74 52                	je     801039 <fork+0xcd>
  800fe7:	89 de                	mov    %ebx,%esi
  800fe9:	c1 ee 0c             	shr    $0xc,%esi
  800fec:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800ff3:	a8 01                	test   $0x1,%al
  800ff5:	74 42                	je     801039 <fork+0xcd>
duppage(envid_t envid, unsigned pn)
{
	int r;

	// LAB 4: Your code here.
	envid_t myenvid = sys_getenvid();
  800ff7:	e8 52 fc ff ff       	call   800c4e <sys_getenvid>
  800ffc:	89 c7                	mov    %eax,%edi
	pte_t pte = uvpt[pn];
  800ffe:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
	int perm = PTE_U | PTE_P;
	if(pte & PTE_W || pte & PTE_COW)
  801005:	a9 02 08 00 00       	test   $0x802,%eax
  80100a:	0f 85 de 00 00 00    	jne    8010ee <fork+0x182>
  801010:	e9 fb 00 00 00       	jmp    801110 <fork+0x1a4>
		perm |= PTE_COW;
	if((r = sys_page_map(myenvid,(void*)(pn*PGSIZE),envid,(void*)(pn*PGSIZE),perm))<0){
		panic("duppage fault :%e\n",r);
  801015:	50                   	push   %eax
  801016:	68 8f 26 80 00       	push   $0x80268f
  80101b:	6a 50                	push   $0x50
  80101d:	68 27 26 80 00       	push   $0x802627
  801022:	e8 38 f1 ff ff       	call   80015f <_panic>
	}
	if(perm & PTE_COW){
		if((r = sys_page_map(myenvid,(void*)(pn*PGSIZE),myenvid,(void*)(pn*PGSIZE),perm))<0)
			panic("duppage fault :%e\n",r);
  801027:	50                   	push   %eax
  801028:	68 8f 26 80 00       	push   $0x80268f
  80102d:	6a 54                	push   $0x54
  80102f:	68 27 26 80 00       	push   $0x802627
  801034:	e8 26 f1 ff ff       	call   80015f <_panic>
	if (eid == 0){
		thisenv = &envs[ENVX(sys_getenvid())];
		return eid;
	}
	// copy something to the child page.
	for (uintptr_t i = UTEXT;i <= USTACKTOP;i += PGSIZE){
  801039:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80103f:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  801045:	75 90                	jne    800fd7 <fork+0x6b>
		if (uvpd[PDX(i)] & PTE_P && (uvpt[PGNUM(i)] & PTE_P)){
			duppage(eid,PGNUM(i));
		}
	}
	int r = sys_page_alloc(eid,(void*)(UXSTACKTOP-PGSIZE),PTE_U|PTE_P|PTE_W);
  801047:	83 ec 04             	sub    $0x4,%esp
  80104a:	6a 07                	push   $0x7
  80104c:	68 00 f0 bf ee       	push   $0xeebff000
  801051:	ff 75 e0             	pushl  -0x20(%ebp)
  801054:	e8 33 fc ff ff       	call   800c8c <sys_page_alloc>
	if (r < 0) panic("fork fault.\n");
  801059:	83 c4 10             	add    $0x10,%esp
  80105c:	85 c0                	test   %eax,%eax
  80105e:	79 14                	jns    801074 <fork+0x108>
  801060:	83 ec 04             	sub    $0x4,%esp
  801063:	68 82 26 80 00       	push   $0x802682
  801068:	6a 7d                	push   $0x7d
  80106a:	68 27 26 80 00       	push   $0x802627
  80106f:	e8 eb f0 ff ff       	call   80015f <_panic>

	extern void _pgfault_upcall();
    r = sys_env_set_pgfault_upcall(eid, _pgfault_upcall);
  801074:	83 ec 08             	sub    $0x8,%esp
  801077:	68 97 1f 80 00       	push   $0x801f97
  80107c:	ff 75 e0             	pushl  -0x20(%ebp)
  80107f:	e8 53 fd ff ff       	call   800dd7 <sys_env_set_pgfault_upcall>
    if (r < 0) panic("fork fault 3\n");
  801084:	83 c4 10             	add    $0x10,%esp
  801087:	85 c0                	test   %eax,%eax
  801089:	79 17                	jns    8010a2 <fork+0x136>
  80108b:	83 ec 04             	sub    $0x4,%esp
  80108e:	68 a2 26 80 00       	push   $0x8026a2
  801093:	68 81 00 00 00       	push   $0x81
  801098:	68 27 26 80 00       	push   $0x802627
  80109d:	e8 bd f0 ff ff       	call   80015f <_panic>

	if ((r = sys_env_set_status(eid, ENV_RUNNABLE)) < 0)
  8010a2:	83 ec 08             	sub    $0x8,%esp
  8010a5:	6a 02                	push   $0x2
  8010a7:	ff 75 e0             	pushl  -0x20(%ebp)
  8010aa:	e8 a4 fc ff ff       	call   800d53 <sys_env_set_status>
  8010af:	83 c4 10             	add    $0x10,%esp
  8010b2:	85 c0                	test   %eax,%eax
  8010b4:	79 7d                	jns    801133 <fork+0x1c7>
        panic("fork fault 4\n");
  8010b6:	83 ec 04             	sub    $0x4,%esp
  8010b9:	68 b0 26 80 00       	push   $0x8026b0
  8010be:	68 84 00 00 00       	push   $0x84
  8010c3:	68 27 26 80 00       	push   $0x802627
  8010c8:	e8 92 f0 ff ff       	call   80015f <_panic>
		perm |= PTE_COW;
	if((r = sys_page_map(myenvid,(void*)(pn*PGSIZE),envid,(void*)(pn*PGSIZE),perm))<0){
		panic("duppage fault :%e\n",r);
	}
	if(perm & PTE_COW){
		if((r = sys_page_map(myenvid,(void*)(pn*PGSIZE),myenvid,(void*)(pn*PGSIZE),perm))<0)
  8010cd:	83 ec 0c             	sub    $0xc,%esp
  8010d0:	68 05 08 00 00       	push   $0x805
  8010d5:	56                   	push   %esi
  8010d6:	57                   	push   %edi
  8010d7:	56                   	push   %esi
  8010d8:	57                   	push   %edi
  8010d9:	e8 f1 fb ff ff       	call   800ccf <sys_page_map>
  8010de:	83 c4 20             	add    $0x20,%esp
  8010e1:	85 c0                	test   %eax,%eax
  8010e3:	0f 89 50 ff ff ff    	jns    801039 <fork+0xcd>
  8010e9:	e9 39 ff ff ff       	jmp    801027 <fork+0xbb>
	envid_t myenvid = sys_getenvid();
	pte_t pte = uvpt[pn];
	int perm = PTE_U | PTE_P;
	if(pte & PTE_W || pte & PTE_COW)
		perm |= PTE_COW;
	if((r = sys_page_map(myenvid,(void*)(pn*PGSIZE),envid,(void*)(pn*PGSIZE),perm))<0){
  8010ee:	c1 e6 0c             	shl    $0xc,%esi
  8010f1:	83 ec 0c             	sub    $0xc,%esp
  8010f4:	68 05 08 00 00       	push   $0x805
  8010f9:	56                   	push   %esi
  8010fa:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010fd:	56                   	push   %esi
  8010fe:	57                   	push   %edi
  8010ff:	e8 cb fb ff ff       	call   800ccf <sys_page_map>
  801104:	83 c4 20             	add    $0x20,%esp
  801107:	85 c0                	test   %eax,%eax
  801109:	79 c2                	jns    8010cd <fork+0x161>
  80110b:	e9 05 ff ff ff       	jmp    801015 <fork+0xa9>
  801110:	c1 e6 0c             	shl    $0xc,%esi
  801113:	83 ec 0c             	sub    $0xc,%esp
  801116:	6a 05                	push   $0x5
  801118:	56                   	push   %esi
  801119:	ff 75 e4             	pushl  -0x1c(%ebp)
  80111c:	56                   	push   %esi
  80111d:	57                   	push   %edi
  80111e:	e8 ac fb ff ff       	call   800ccf <sys_page_map>
  801123:	83 c4 20             	add    $0x20,%esp
  801126:	85 c0                	test   %eax,%eax
  801128:	0f 89 0b ff ff ff    	jns    801039 <fork+0xcd>
  80112e:	e9 e2 fe ff ff       	jmp    801015 <fork+0xa9>
    if (r < 0) panic("fork fault 3\n");

	if ((r = sys_env_set_status(eid, ENV_RUNNABLE)) < 0)
        panic("fork fault 4\n");
    return eid;
}
  801133:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801136:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801139:	5b                   	pop    %ebx
  80113a:	5e                   	pop    %esi
  80113b:	5f                   	pop    %edi
  80113c:	5d                   	pop    %ebp
  80113d:	c3                   	ret    

0080113e <sfork>:

// Challenge!
int
sfork(void)
{
  80113e:	55                   	push   %ebp
  80113f:	89 e5                	mov    %esp,%ebp
  801141:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801144:	68 be 26 80 00       	push   $0x8026be
  801149:	68 8c 00 00 00       	push   $0x8c
  80114e:	68 27 26 80 00       	push   $0x802627
  801153:	e8 07 f0 ff ff       	call   80015f <_panic>

00801158 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801158:	55                   	push   %ebp
  801159:	89 e5                	mov    %esp,%ebp
  80115b:	56                   	push   %esi
  80115c:	53                   	push   %ebx
  80115d:	8b 75 08             	mov    0x8(%ebp),%esi
  801160:	8b 45 0c             	mov    0xc(%ebp),%eax
  801163:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");
	int r;
    if (pg != NULL) {
  801166:	85 c0                	test   %eax,%eax
  801168:	74 0e                	je     801178 <ipc_recv+0x20>
        r = sys_ipc_recv(pg);
  80116a:	83 ec 0c             	sub    $0xc,%esp
  80116d:	50                   	push   %eax
  80116e:	e8 c9 fc ff ff       	call   800e3c <sys_ipc_recv>
  801173:	83 c4 10             	add    $0x10,%esp
  801176:	eb 10                	jmp    801188 <ipc_recv+0x30>
    } else {
        r = sys_ipc_recv((void *) UTOP);
  801178:	83 ec 0c             	sub    $0xc,%esp
  80117b:	68 00 00 c0 ee       	push   $0xeec00000
  801180:	e8 b7 fc ff ff       	call   800e3c <sys_ipc_recv>
  801185:	83 c4 10             	add    $0x10,%esp
    }
    if (r < 0) {
  801188:	85 c0                	test   %eax,%eax
  80118a:	79 16                	jns    8011a2 <ipc_recv+0x4a>
        // failed
        if (from_env_store != NULL) *from_env_store = 0;
  80118c:	85 f6                	test   %esi,%esi
  80118e:	74 06                	je     801196 <ipc_recv+0x3e>
  801190:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        if (perm_store != NULL) *perm_store = 0;
  801196:	85 db                	test   %ebx,%ebx
  801198:	74 2c                	je     8011c6 <ipc_recv+0x6e>
  80119a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8011a0:	eb 24                	jmp    8011c6 <ipc_recv+0x6e>
        return r;
    } else {
        if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  8011a2:	85 f6                	test   %esi,%esi
  8011a4:	74 0a                	je     8011b0 <ipc_recv+0x58>
  8011a6:	a1 04 40 80 00       	mov    0x804004,%eax
  8011ab:	8b 40 74             	mov    0x74(%eax),%eax
  8011ae:	89 06                	mov    %eax,(%esi)
        if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  8011b0:	85 db                	test   %ebx,%ebx
  8011b2:	74 0a                	je     8011be <ipc_recv+0x66>
  8011b4:	a1 04 40 80 00       	mov    0x804004,%eax
  8011b9:	8b 40 78             	mov    0x78(%eax),%eax
  8011bc:	89 03                	mov    %eax,(%ebx)
        return thisenv->env_ipc_value;
  8011be:	a1 04 40 80 00       	mov    0x804004,%eax
  8011c3:	8b 40 70             	mov    0x70(%eax),%eax
    }
 
	return 0;
}
  8011c6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011c9:	5b                   	pop    %ebx
  8011ca:	5e                   	pop    %esi
  8011cb:	5d                   	pop    %ebp
  8011cc:	c3                   	ret    

008011cd <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8011cd:	55                   	push   %ebp
  8011ce:	89 e5                	mov    %esp,%ebp
  8011d0:	57                   	push   %edi
  8011d1:	56                   	push   %esi
  8011d2:	53                   	push   %ebx
  8011d3:	83 ec 0c             	sub    $0xc,%esp
  8011d6:	8b 75 10             	mov    0x10(%ebp),%esi
  8011d9:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");
	int r;
    if (pg == NULL) pg = (void *)UTOP;
  8011dc:	85 f6                	test   %esi,%esi
  8011de:	75 05                	jne    8011e5 <ipc_send+0x18>
  8011e0:	be 00 00 c0 ee       	mov    $0xeec00000,%esi
    do {
        r = sys_ipc_try_send(to_env, val, pg, perm);
  8011e5:	57                   	push   %edi
  8011e6:	56                   	push   %esi
  8011e7:	ff 75 0c             	pushl  0xc(%ebp)
  8011ea:	ff 75 08             	pushl  0x8(%ebp)
  8011ed:	e8 27 fc ff ff       	call   800e19 <sys_ipc_try_send>
  8011f2:	89 c3                	mov    %eax,%ebx
        if (r < 0 && r != -E_IPC_NOT_RECV) panic("ipc send failed: %e", r);
  8011f4:	83 c4 10             	add    $0x10,%esp
  8011f7:	85 c0                	test   %eax,%eax
  8011f9:	79 17                	jns    801212 <ipc_send+0x45>
  8011fb:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8011fe:	74 1d                	je     80121d <ipc_send+0x50>
  801200:	50                   	push   %eax
  801201:	68 f3 26 80 00       	push   $0x8026f3
  801206:	6a 40                	push   $0x40
  801208:	68 07 27 80 00       	push   $0x802707
  80120d:	e8 4d ef ff ff       	call   80015f <_panic>
        sys_yield();
  801212:	e8 56 fa ff ff       	call   800c6d <sys_yield>
    } while (r != 0);
  801217:	85 db                	test   %ebx,%ebx
  801219:	75 ca                	jne    8011e5 <ipc_send+0x18>
  80121b:	eb 07                	jmp    801224 <ipc_send+0x57>
	int r;
    if (pg == NULL) pg = (void *)UTOP;
    do {
        r = sys_ipc_try_send(to_env, val, pg, perm);
        if (r < 0 && r != -E_IPC_NOT_RECV) panic("ipc send failed: %e", r);
        sys_yield();
  80121d:	e8 4b fa ff ff       	call   800c6d <sys_yield>
  801222:	eb c1                	jmp    8011e5 <ipc_send+0x18>
    } while (r != 0);
}
  801224:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801227:	5b                   	pop    %ebx
  801228:	5e                   	pop    %esi
  801229:	5f                   	pop    %edi
  80122a:	5d                   	pop    %ebp
  80122b:	c3                   	ret    

0080122c <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80122c:	55                   	push   %ebp
  80122d:	89 e5                	mov    %esp,%ebp
  80122f:	53                   	push   %ebx
  801230:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801233:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  801238:	39 c1                	cmp    %eax,%ecx
  80123a:	74 21                	je     80125d <ipc_find_env+0x31>
  80123c:	ba 01 00 00 00       	mov    $0x1,%edx
  801241:	8d 1c 95 00 00 00 00 	lea    0x0(,%edx,4),%ebx
  801248:	89 d0                	mov    %edx,%eax
  80124a:	c1 e0 07             	shl    $0x7,%eax
  80124d:	29 d8                	sub    %ebx,%eax
  80124f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801254:	8b 40 50             	mov    0x50(%eax),%eax
  801257:	39 c8                	cmp    %ecx,%eax
  801259:	75 1b                	jne    801276 <ipc_find_env+0x4a>
  80125b:	eb 05                	jmp    801262 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80125d:	ba 00 00 00 00       	mov    $0x0,%edx
		if (envs[i].env_type == type)
			return envs[i].env_id;
  801262:	8d 04 95 00 00 00 00 	lea    0x0(,%edx,4),%eax
  801269:	c1 e2 07             	shl    $0x7,%edx
  80126c:	29 c2                	sub    %eax,%edx
  80126e:	8b 82 48 00 c0 ee    	mov    -0x113fffb8(%edx),%eax
  801274:	eb 0e                	jmp    801284 <ipc_find_env+0x58>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801276:	42                   	inc    %edx
  801277:	81 fa 00 04 00 00    	cmp    $0x400,%edx
  80127d:	75 c2                	jne    801241 <ipc_find_env+0x15>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80127f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801284:	5b                   	pop    %ebx
  801285:	5d                   	pop    %ebp
  801286:	c3                   	ret    

00801287 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801287:	55                   	push   %ebp
  801288:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80128a:	8b 45 08             	mov    0x8(%ebp),%eax
  80128d:	05 00 00 00 30       	add    $0x30000000,%eax
  801292:	c1 e8 0c             	shr    $0xc,%eax
}
  801295:	5d                   	pop    %ebp
  801296:	c3                   	ret    

00801297 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801297:	55                   	push   %ebp
  801298:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80129a:	8b 45 08             	mov    0x8(%ebp),%eax
  80129d:	05 00 00 00 30       	add    $0x30000000,%eax
  8012a2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8012a7:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8012ac:	5d                   	pop    %ebp
  8012ad:	c3                   	ret    

008012ae <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8012ae:	55                   	push   %ebp
  8012af:	89 e5                	mov    %esp,%ebp
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8012b1:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  8012b6:	a8 01                	test   $0x1,%al
  8012b8:	74 34                	je     8012ee <fd_alloc+0x40>
  8012ba:	a1 00 00 74 ef       	mov    0xef740000,%eax
  8012bf:	a8 01                	test   $0x1,%al
  8012c1:	74 32                	je     8012f5 <fd_alloc+0x47>
  8012c3:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8012c8:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8012ca:	89 c2                	mov    %eax,%edx
  8012cc:	c1 ea 16             	shr    $0x16,%edx
  8012cf:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012d6:	f6 c2 01             	test   $0x1,%dl
  8012d9:	74 1f                	je     8012fa <fd_alloc+0x4c>
  8012db:	89 c2                	mov    %eax,%edx
  8012dd:	c1 ea 0c             	shr    $0xc,%edx
  8012e0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012e7:	f6 c2 01             	test   $0x1,%dl
  8012ea:	75 1a                	jne    801306 <fd_alloc+0x58>
  8012ec:	eb 0c                	jmp    8012fa <fd_alloc+0x4c>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8012ee:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  8012f3:	eb 05                	jmp    8012fa <fd_alloc+0x4c>
  8012f5:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  8012fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8012fd:	89 08                	mov    %ecx,(%eax)
			return 0;
  8012ff:	b8 00 00 00 00       	mov    $0x0,%eax
  801304:	eb 1a                	jmp    801320 <fd_alloc+0x72>
  801306:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80130b:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801310:	75 b6                	jne    8012c8 <fd_alloc+0x1a>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801312:	8b 45 08             	mov    0x8(%ebp),%eax
  801315:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  80131b:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801320:	5d                   	pop    %ebp
  801321:	c3                   	ret    

00801322 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801322:	55                   	push   %ebp
  801323:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801325:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
  801329:	77 39                	ja     801364 <fd_lookup+0x42>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80132b:	8b 45 08             	mov    0x8(%ebp),%eax
  80132e:	c1 e0 0c             	shl    $0xc,%eax
  801331:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801336:	89 c2                	mov    %eax,%edx
  801338:	c1 ea 16             	shr    $0x16,%edx
  80133b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801342:	f6 c2 01             	test   $0x1,%dl
  801345:	74 24                	je     80136b <fd_lookup+0x49>
  801347:	89 c2                	mov    %eax,%edx
  801349:	c1 ea 0c             	shr    $0xc,%edx
  80134c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801353:	f6 c2 01             	test   $0x1,%dl
  801356:	74 1a                	je     801372 <fd_lookup+0x50>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801358:	8b 55 0c             	mov    0xc(%ebp),%edx
  80135b:	89 02                	mov    %eax,(%edx)
	return 0;
  80135d:	b8 00 00 00 00       	mov    $0x0,%eax
  801362:	eb 13                	jmp    801377 <fd_lookup+0x55>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801364:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801369:	eb 0c                	jmp    801377 <fd_lookup+0x55>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80136b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801370:	eb 05                	jmp    801377 <fd_lookup+0x55>
  801372:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801377:	5d                   	pop    %ebp
  801378:	c3                   	ret    

00801379 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801379:	55                   	push   %ebp
  80137a:	89 e5                	mov    %esp,%ebp
  80137c:	53                   	push   %ebx
  80137d:	83 ec 04             	sub    $0x4,%esp
  801380:	8b 45 08             	mov    0x8(%ebp),%eax
  801383:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  801386:	3b 05 04 30 80 00    	cmp    0x803004,%eax
  80138c:	75 1e                	jne    8013ac <dev_lookup+0x33>
  80138e:	eb 0e                	jmp    80139e <dev_lookup+0x25>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801390:	b8 20 30 80 00       	mov    $0x803020,%eax
  801395:	eb 0c                	jmp    8013a3 <dev_lookup+0x2a>
  801397:	b8 3c 30 80 00       	mov    $0x80303c,%eax
  80139c:	eb 05                	jmp    8013a3 <dev_lookup+0x2a>
  80139e:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  8013a3:	89 03                	mov    %eax,(%ebx)
			return 0;
  8013a5:	b8 00 00 00 00       	mov    $0x0,%eax
  8013aa:	eb 36                	jmp    8013e2 <dev_lookup+0x69>
int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  8013ac:	3b 05 20 30 80 00    	cmp    0x803020,%eax
  8013b2:	74 dc                	je     801390 <dev_lookup+0x17>
  8013b4:	3b 05 3c 30 80 00    	cmp    0x80303c,%eax
  8013ba:	74 db                	je     801397 <dev_lookup+0x1e>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8013bc:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8013c2:	8b 52 48             	mov    0x48(%edx),%edx
  8013c5:	83 ec 04             	sub    $0x4,%esp
  8013c8:	50                   	push   %eax
  8013c9:	52                   	push   %edx
  8013ca:	68 14 27 80 00       	push   $0x802714
  8013cf:	e8 63 ee ff ff       	call   800237 <cprintf>
	*dev = 0;
  8013d4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  8013da:	83 c4 10             	add    $0x10,%esp
  8013dd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8013e2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013e5:	c9                   	leave  
  8013e6:	c3                   	ret    

008013e7 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8013e7:	55                   	push   %ebp
  8013e8:	89 e5                	mov    %esp,%ebp
  8013ea:	56                   	push   %esi
  8013eb:	53                   	push   %ebx
  8013ec:	83 ec 10             	sub    $0x10,%esp
  8013ef:	8b 75 08             	mov    0x8(%ebp),%esi
  8013f2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8013f5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013f8:	50                   	push   %eax
  8013f9:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8013ff:	c1 e8 0c             	shr    $0xc,%eax
  801402:	50                   	push   %eax
  801403:	e8 1a ff ff ff       	call   801322 <fd_lookup>
  801408:	83 c4 08             	add    $0x8,%esp
  80140b:	85 c0                	test   %eax,%eax
  80140d:	78 05                	js     801414 <fd_close+0x2d>
	    || fd != fd2)
  80140f:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801412:	74 06                	je     80141a <fd_close+0x33>
		return (must_exist ? r : 0);
  801414:	84 db                	test   %bl,%bl
  801416:	74 47                	je     80145f <fd_close+0x78>
  801418:	eb 4a                	jmp    801464 <fd_close+0x7d>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80141a:	83 ec 08             	sub    $0x8,%esp
  80141d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801420:	50                   	push   %eax
  801421:	ff 36                	pushl  (%esi)
  801423:	e8 51 ff ff ff       	call   801379 <dev_lookup>
  801428:	89 c3                	mov    %eax,%ebx
  80142a:	83 c4 10             	add    $0x10,%esp
  80142d:	85 c0                	test   %eax,%eax
  80142f:	78 1c                	js     80144d <fd_close+0x66>
		if (dev->dev_close)
  801431:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801434:	8b 40 10             	mov    0x10(%eax),%eax
  801437:	85 c0                	test   %eax,%eax
  801439:	74 0d                	je     801448 <fd_close+0x61>
			r = (*dev->dev_close)(fd);
  80143b:	83 ec 0c             	sub    $0xc,%esp
  80143e:	56                   	push   %esi
  80143f:	ff d0                	call   *%eax
  801441:	89 c3                	mov    %eax,%ebx
  801443:	83 c4 10             	add    $0x10,%esp
  801446:	eb 05                	jmp    80144d <fd_close+0x66>
		else
			r = 0;
  801448:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80144d:	83 ec 08             	sub    $0x8,%esp
  801450:	56                   	push   %esi
  801451:	6a 00                	push   $0x0
  801453:	e8 b9 f8 ff ff       	call   800d11 <sys_page_unmap>
	return r;
  801458:	83 c4 10             	add    $0x10,%esp
  80145b:	89 d8                	mov    %ebx,%eax
  80145d:	eb 05                	jmp    801464 <fd_close+0x7d>
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
  80145f:	b8 00 00 00 00       	mov    $0x0,%eax
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
	return r;
}
  801464:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801467:	5b                   	pop    %ebx
  801468:	5e                   	pop    %esi
  801469:	5d                   	pop    %ebp
  80146a:	c3                   	ret    

0080146b <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80146b:	55                   	push   %ebp
  80146c:	89 e5                	mov    %esp,%ebp
  80146e:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801471:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801474:	50                   	push   %eax
  801475:	ff 75 08             	pushl  0x8(%ebp)
  801478:	e8 a5 fe ff ff       	call   801322 <fd_lookup>
  80147d:	83 c4 08             	add    $0x8,%esp
  801480:	85 c0                	test   %eax,%eax
  801482:	78 10                	js     801494 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801484:	83 ec 08             	sub    $0x8,%esp
  801487:	6a 01                	push   $0x1
  801489:	ff 75 f4             	pushl  -0xc(%ebp)
  80148c:	e8 56 ff ff ff       	call   8013e7 <fd_close>
  801491:	83 c4 10             	add    $0x10,%esp
}
  801494:	c9                   	leave  
  801495:	c3                   	ret    

00801496 <close_all>:

void
close_all(void)
{
  801496:	55                   	push   %ebp
  801497:	89 e5                	mov    %esp,%ebp
  801499:	53                   	push   %ebx
  80149a:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80149d:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8014a2:	83 ec 0c             	sub    $0xc,%esp
  8014a5:	53                   	push   %ebx
  8014a6:	e8 c0 ff ff ff       	call   80146b <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8014ab:	43                   	inc    %ebx
  8014ac:	83 c4 10             	add    $0x10,%esp
  8014af:	83 fb 20             	cmp    $0x20,%ebx
  8014b2:	75 ee                	jne    8014a2 <close_all+0xc>
		close(i);
}
  8014b4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014b7:	c9                   	leave  
  8014b8:	c3                   	ret    

008014b9 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8014b9:	55                   	push   %ebp
  8014ba:	89 e5                	mov    %esp,%ebp
  8014bc:	57                   	push   %edi
  8014bd:	56                   	push   %esi
  8014be:	53                   	push   %ebx
  8014bf:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8014c2:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8014c5:	50                   	push   %eax
  8014c6:	ff 75 08             	pushl  0x8(%ebp)
  8014c9:	e8 54 fe ff ff       	call   801322 <fd_lookup>
  8014ce:	83 c4 08             	add    $0x8,%esp
  8014d1:	85 c0                	test   %eax,%eax
  8014d3:	0f 88 c2 00 00 00    	js     80159b <dup+0xe2>
		return r;
	close(newfdnum);
  8014d9:	83 ec 0c             	sub    $0xc,%esp
  8014dc:	ff 75 0c             	pushl  0xc(%ebp)
  8014df:	e8 87 ff ff ff       	call   80146b <close>

	newfd = INDEX2FD(newfdnum);
  8014e4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8014e7:	c1 e3 0c             	shl    $0xc,%ebx
  8014ea:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8014f0:	83 c4 04             	add    $0x4,%esp
  8014f3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8014f6:	e8 9c fd ff ff       	call   801297 <fd2data>
  8014fb:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  8014fd:	89 1c 24             	mov    %ebx,(%esp)
  801500:	e8 92 fd ff ff       	call   801297 <fd2data>
  801505:	83 c4 10             	add    $0x10,%esp
  801508:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80150a:	89 f0                	mov    %esi,%eax
  80150c:	c1 e8 16             	shr    $0x16,%eax
  80150f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801516:	a8 01                	test   $0x1,%al
  801518:	74 35                	je     80154f <dup+0x96>
  80151a:	89 f0                	mov    %esi,%eax
  80151c:	c1 e8 0c             	shr    $0xc,%eax
  80151f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801526:	f6 c2 01             	test   $0x1,%dl
  801529:	74 24                	je     80154f <dup+0x96>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80152b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801532:	83 ec 0c             	sub    $0xc,%esp
  801535:	25 07 0e 00 00       	and    $0xe07,%eax
  80153a:	50                   	push   %eax
  80153b:	57                   	push   %edi
  80153c:	6a 00                	push   $0x0
  80153e:	56                   	push   %esi
  80153f:	6a 00                	push   $0x0
  801541:	e8 89 f7 ff ff       	call   800ccf <sys_page_map>
  801546:	89 c6                	mov    %eax,%esi
  801548:	83 c4 20             	add    $0x20,%esp
  80154b:	85 c0                	test   %eax,%eax
  80154d:	78 2c                	js     80157b <dup+0xc2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80154f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801552:	89 d0                	mov    %edx,%eax
  801554:	c1 e8 0c             	shr    $0xc,%eax
  801557:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80155e:	83 ec 0c             	sub    $0xc,%esp
  801561:	25 07 0e 00 00       	and    $0xe07,%eax
  801566:	50                   	push   %eax
  801567:	53                   	push   %ebx
  801568:	6a 00                	push   $0x0
  80156a:	52                   	push   %edx
  80156b:	6a 00                	push   $0x0
  80156d:	e8 5d f7 ff ff       	call   800ccf <sys_page_map>
  801572:	89 c6                	mov    %eax,%esi
  801574:	83 c4 20             	add    $0x20,%esp
  801577:	85 c0                	test   %eax,%eax
  801579:	79 1d                	jns    801598 <dup+0xdf>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80157b:	83 ec 08             	sub    $0x8,%esp
  80157e:	53                   	push   %ebx
  80157f:	6a 00                	push   $0x0
  801581:	e8 8b f7 ff ff       	call   800d11 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801586:	83 c4 08             	add    $0x8,%esp
  801589:	57                   	push   %edi
  80158a:	6a 00                	push   $0x0
  80158c:	e8 80 f7 ff ff       	call   800d11 <sys_page_unmap>
	return r;
  801591:	83 c4 10             	add    $0x10,%esp
  801594:	89 f0                	mov    %esi,%eax
  801596:	eb 03                	jmp    80159b <dup+0xe2>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801598:	8b 45 0c             	mov    0xc(%ebp),%eax

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80159b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80159e:	5b                   	pop    %ebx
  80159f:	5e                   	pop    %esi
  8015a0:	5f                   	pop    %edi
  8015a1:	5d                   	pop    %ebp
  8015a2:	c3                   	ret    

008015a3 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8015a3:	55                   	push   %ebp
  8015a4:	89 e5                	mov    %esp,%ebp
  8015a6:	53                   	push   %ebx
  8015a7:	83 ec 14             	sub    $0x14,%esp
  8015aa:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015ad:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015b0:	50                   	push   %eax
  8015b1:	53                   	push   %ebx
  8015b2:	e8 6b fd ff ff       	call   801322 <fd_lookup>
  8015b7:	83 c4 08             	add    $0x8,%esp
  8015ba:	85 c0                	test   %eax,%eax
  8015bc:	78 67                	js     801625 <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015be:	83 ec 08             	sub    $0x8,%esp
  8015c1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015c4:	50                   	push   %eax
  8015c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015c8:	ff 30                	pushl  (%eax)
  8015ca:	e8 aa fd ff ff       	call   801379 <dev_lookup>
  8015cf:	83 c4 10             	add    $0x10,%esp
  8015d2:	85 c0                	test   %eax,%eax
  8015d4:	78 4f                	js     801625 <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8015d6:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8015d9:	8b 42 08             	mov    0x8(%edx),%eax
  8015dc:	83 e0 03             	and    $0x3,%eax
  8015df:	83 f8 01             	cmp    $0x1,%eax
  8015e2:	75 21                	jne    801605 <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8015e4:	a1 04 40 80 00       	mov    0x804004,%eax
  8015e9:	8b 40 48             	mov    0x48(%eax),%eax
  8015ec:	83 ec 04             	sub    $0x4,%esp
  8015ef:	53                   	push   %ebx
  8015f0:	50                   	push   %eax
  8015f1:	68 58 27 80 00       	push   $0x802758
  8015f6:	e8 3c ec ff ff       	call   800237 <cprintf>
		return -E_INVAL;
  8015fb:	83 c4 10             	add    $0x10,%esp
  8015fe:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801603:	eb 20                	jmp    801625 <read+0x82>
	}
	if (!dev->dev_read)
  801605:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801608:	8b 40 08             	mov    0x8(%eax),%eax
  80160b:	85 c0                	test   %eax,%eax
  80160d:	74 11                	je     801620 <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80160f:	83 ec 04             	sub    $0x4,%esp
  801612:	ff 75 10             	pushl  0x10(%ebp)
  801615:	ff 75 0c             	pushl  0xc(%ebp)
  801618:	52                   	push   %edx
  801619:	ff d0                	call   *%eax
  80161b:	83 c4 10             	add    $0x10,%esp
  80161e:	eb 05                	jmp    801625 <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801620:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801625:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801628:	c9                   	leave  
  801629:	c3                   	ret    

0080162a <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80162a:	55                   	push   %ebp
  80162b:	89 e5                	mov    %esp,%ebp
  80162d:	57                   	push   %edi
  80162e:	56                   	push   %esi
  80162f:	53                   	push   %ebx
  801630:	83 ec 0c             	sub    $0xc,%esp
  801633:	8b 7d 08             	mov    0x8(%ebp),%edi
  801636:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801639:	85 f6                	test   %esi,%esi
  80163b:	74 31                	je     80166e <readn+0x44>
  80163d:	b8 00 00 00 00       	mov    $0x0,%eax
  801642:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  801647:	83 ec 04             	sub    $0x4,%esp
  80164a:	89 f2                	mov    %esi,%edx
  80164c:	29 c2                	sub    %eax,%edx
  80164e:	52                   	push   %edx
  80164f:	03 45 0c             	add    0xc(%ebp),%eax
  801652:	50                   	push   %eax
  801653:	57                   	push   %edi
  801654:	e8 4a ff ff ff       	call   8015a3 <read>
		if (m < 0)
  801659:	83 c4 10             	add    $0x10,%esp
  80165c:	85 c0                	test   %eax,%eax
  80165e:	78 17                	js     801677 <readn+0x4d>
			return m;
		if (m == 0)
  801660:	85 c0                	test   %eax,%eax
  801662:	74 11                	je     801675 <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801664:	01 c3                	add    %eax,%ebx
  801666:	89 d8                	mov    %ebx,%eax
  801668:	39 f3                	cmp    %esi,%ebx
  80166a:	72 db                	jb     801647 <readn+0x1d>
  80166c:	eb 09                	jmp    801677 <readn+0x4d>
  80166e:	b8 00 00 00 00       	mov    $0x0,%eax
  801673:	eb 02                	jmp    801677 <readn+0x4d>
  801675:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801677:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80167a:	5b                   	pop    %ebx
  80167b:	5e                   	pop    %esi
  80167c:	5f                   	pop    %edi
  80167d:	5d                   	pop    %ebp
  80167e:	c3                   	ret    

0080167f <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80167f:	55                   	push   %ebp
  801680:	89 e5                	mov    %esp,%ebp
  801682:	53                   	push   %ebx
  801683:	83 ec 14             	sub    $0x14,%esp
  801686:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801689:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80168c:	50                   	push   %eax
  80168d:	53                   	push   %ebx
  80168e:	e8 8f fc ff ff       	call   801322 <fd_lookup>
  801693:	83 c4 08             	add    $0x8,%esp
  801696:	85 c0                	test   %eax,%eax
  801698:	78 62                	js     8016fc <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80169a:	83 ec 08             	sub    $0x8,%esp
  80169d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016a0:	50                   	push   %eax
  8016a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016a4:	ff 30                	pushl  (%eax)
  8016a6:	e8 ce fc ff ff       	call   801379 <dev_lookup>
  8016ab:	83 c4 10             	add    $0x10,%esp
  8016ae:	85 c0                	test   %eax,%eax
  8016b0:	78 4a                	js     8016fc <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016b5:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016b9:	75 21                	jne    8016dc <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8016bb:	a1 04 40 80 00       	mov    0x804004,%eax
  8016c0:	8b 40 48             	mov    0x48(%eax),%eax
  8016c3:	83 ec 04             	sub    $0x4,%esp
  8016c6:	53                   	push   %ebx
  8016c7:	50                   	push   %eax
  8016c8:	68 74 27 80 00       	push   $0x802774
  8016cd:	e8 65 eb ff ff       	call   800237 <cprintf>
		return -E_INVAL;
  8016d2:	83 c4 10             	add    $0x10,%esp
  8016d5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016da:	eb 20                	jmp    8016fc <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8016dc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016df:	8b 52 0c             	mov    0xc(%edx),%edx
  8016e2:	85 d2                	test   %edx,%edx
  8016e4:	74 11                	je     8016f7 <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8016e6:	83 ec 04             	sub    $0x4,%esp
  8016e9:	ff 75 10             	pushl  0x10(%ebp)
  8016ec:	ff 75 0c             	pushl  0xc(%ebp)
  8016ef:	50                   	push   %eax
  8016f0:	ff d2                	call   *%edx
  8016f2:	83 c4 10             	add    $0x10,%esp
  8016f5:	eb 05                	jmp    8016fc <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8016f7:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8016fc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016ff:	c9                   	leave  
  801700:	c3                   	ret    

00801701 <seek>:

int
seek(int fdnum, off_t offset)
{
  801701:	55                   	push   %ebp
  801702:	89 e5                	mov    %esp,%ebp
  801704:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801707:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80170a:	50                   	push   %eax
  80170b:	ff 75 08             	pushl  0x8(%ebp)
  80170e:	e8 0f fc ff ff       	call   801322 <fd_lookup>
  801713:	83 c4 08             	add    $0x8,%esp
  801716:	85 c0                	test   %eax,%eax
  801718:	78 0e                	js     801728 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80171a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80171d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801720:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801723:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801728:	c9                   	leave  
  801729:	c3                   	ret    

0080172a <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80172a:	55                   	push   %ebp
  80172b:	89 e5                	mov    %esp,%ebp
  80172d:	53                   	push   %ebx
  80172e:	83 ec 14             	sub    $0x14,%esp
  801731:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801734:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801737:	50                   	push   %eax
  801738:	53                   	push   %ebx
  801739:	e8 e4 fb ff ff       	call   801322 <fd_lookup>
  80173e:	83 c4 08             	add    $0x8,%esp
  801741:	85 c0                	test   %eax,%eax
  801743:	78 5f                	js     8017a4 <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801745:	83 ec 08             	sub    $0x8,%esp
  801748:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80174b:	50                   	push   %eax
  80174c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80174f:	ff 30                	pushl  (%eax)
  801751:	e8 23 fc ff ff       	call   801379 <dev_lookup>
  801756:	83 c4 10             	add    $0x10,%esp
  801759:	85 c0                	test   %eax,%eax
  80175b:	78 47                	js     8017a4 <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80175d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801760:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801764:	75 21                	jne    801787 <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801766:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80176b:	8b 40 48             	mov    0x48(%eax),%eax
  80176e:	83 ec 04             	sub    $0x4,%esp
  801771:	53                   	push   %ebx
  801772:	50                   	push   %eax
  801773:	68 34 27 80 00       	push   $0x802734
  801778:	e8 ba ea ff ff       	call   800237 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80177d:	83 c4 10             	add    $0x10,%esp
  801780:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801785:	eb 1d                	jmp    8017a4 <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  801787:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80178a:	8b 52 18             	mov    0x18(%edx),%edx
  80178d:	85 d2                	test   %edx,%edx
  80178f:	74 0e                	je     80179f <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801791:	83 ec 08             	sub    $0x8,%esp
  801794:	ff 75 0c             	pushl  0xc(%ebp)
  801797:	50                   	push   %eax
  801798:	ff d2                	call   *%edx
  80179a:	83 c4 10             	add    $0x10,%esp
  80179d:	eb 05                	jmp    8017a4 <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80179f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8017a4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017a7:	c9                   	leave  
  8017a8:	c3                   	ret    

008017a9 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8017a9:	55                   	push   %ebp
  8017aa:	89 e5                	mov    %esp,%ebp
  8017ac:	53                   	push   %ebx
  8017ad:	83 ec 14             	sub    $0x14,%esp
  8017b0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017b3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017b6:	50                   	push   %eax
  8017b7:	ff 75 08             	pushl  0x8(%ebp)
  8017ba:	e8 63 fb ff ff       	call   801322 <fd_lookup>
  8017bf:	83 c4 08             	add    $0x8,%esp
  8017c2:	85 c0                	test   %eax,%eax
  8017c4:	78 52                	js     801818 <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017c6:	83 ec 08             	sub    $0x8,%esp
  8017c9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017cc:	50                   	push   %eax
  8017cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017d0:	ff 30                	pushl  (%eax)
  8017d2:	e8 a2 fb ff ff       	call   801379 <dev_lookup>
  8017d7:	83 c4 10             	add    $0x10,%esp
  8017da:	85 c0                	test   %eax,%eax
  8017dc:	78 3a                	js     801818 <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  8017de:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017e1:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8017e5:	74 2c                	je     801813 <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8017e7:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8017ea:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8017f1:	00 00 00 
	stat->st_isdir = 0;
  8017f4:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8017fb:	00 00 00 
	stat->st_dev = dev;
  8017fe:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801804:	83 ec 08             	sub    $0x8,%esp
  801807:	53                   	push   %ebx
  801808:	ff 75 f0             	pushl  -0x10(%ebp)
  80180b:	ff 50 14             	call   *0x14(%eax)
  80180e:	83 c4 10             	add    $0x10,%esp
  801811:	eb 05                	jmp    801818 <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801813:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801818:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80181b:	c9                   	leave  
  80181c:	c3                   	ret    

0080181d <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80181d:	55                   	push   %ebp
  80181e:	89 e5                	mov    %esp,%ebp
  801820:	56                   	push   %esi
  801821:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801822:	83 ec 08             	sub    $0x8,%esp
  801825:	6a 00                	push   $0x0
  801827:	ff 75 08             	pushl  0x8(%ebp)
  80182a:	e8 75 01 00 00       	call   8019a4 <open>
  80182f:	89 c3                	mov    %eax,%ebx
  801831:	83 c4 10             	add    $0x10,%esp
  801834:	85 c0                	test   %eax,%eax
  801836:	78 1d                	js     801855 <stat+0x38>
		return fd;
	r = fstat(fd, stat);
  801838:	83 ec 08             	sub    $0x8,%esp
  80183b:	ff 75 0c             	pushl  0xc(%ebp)
  80183e:	50                   	push   %eax
  80183f:	e8 65 ff ff ff       	call   8017a9 <fstat>
  801844:	89 c6                	mov    %eax,%esi
	close(fd);
  801846:	89 1c 24             	mov    %ebx,(%esp)
  801849:	e8 1d fc ff ff       	call   80146b <close>
	return r;
  80184e:	83 c4 10             	add    $0x10,%esp
  801851:	89 f0                	mov    %esi,%eax
  801853:	eb 00                	jmp    801855 <stat+0x38>
}
  801855:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801858:	5b                   	pop    %ebx
  801859:	5e                   	pop    %esi
  80185a:	5d                   	pop    %ebp
  80185b:	c3                   	ret    

0080185c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80185c:	55                   	push   %ebp
  80185d:	89 e5                	mov    %esp,%ebp
  80185f:	56                   	push   %esi
  801860:	53                   	push   %ebx
  801861:	89 c6                	mov    %eax,%esi
  801863:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801865:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80186c:	75 12                	jne    801880 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80186e:	83 ec 0c             	sub    $0xc,%esp
  801871:	6a 01                	push   $0x1
  801873:	e8 b4 f9 ff ff       	call   80122c <ipc_find_env>
  801878:	a3 00 40 80 00       	mov    %eax,0x804000
  80187d:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801880:	6a 07                	push   $0x7
  801882:	68 00 50 80 00       	push   $0x805000
  801887:	56                   	push   %esi
  801888:	ff 35 00 40 80 00    	pushl  0x804000
  80188e:	e8 3a f9 ff ff       	call   8011cd <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801893:	83 c4 0c             	add    $0xc,%esp
  801896:	6a 00                	push   $0x0
  801898:	53                   	push   %ebx
  801899:	6a 00                	push   $0x0
  80189b:	e8 b8 f8 ff ff       	call   801158 <ipc_recv>
}
  8018a0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018a3:	5b                   	pop    %ebx
  8018a4:	5e                   	pop    %esi
  8018a5:	5d                   	pop    %ebp
  8018a6:	c3                   	ret    

008018a7 <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8018a7:	55                   	push   %ebp
  8018a8:	89 e5                	mov    %esp,%ebp
  8018aa:	53                   	push   %ebx
  8018ab:	83 ec 04             	sub    $0x4,%esp
  8018ae:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8018b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8018b4:	8b 40 0c             	mov    0xc(%eax),%eax
  8018b7:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8018bc:	ba 00 00 00 00       	mov    $0x0,%edx
  8018c1:	b8 05 00 00 00       	mov    $0x5,%eax
  8018c6:	e8 91 ff ff ff       	call   80185c <fsipc>
  8018cb:	85 c0                	test   %eax,%eax
  8018cd:	78 2c                	js     8018fb <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8018cf:	83 ec 08             	sub    $0x8,%esp
  8018d2:	68 00 50 80 00       	push   $0x805000
  8018d7:	53                   	push   %ebx
  8018d8:	e8 3f ef ff ff       	call   80081c <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8018dd:	a1 80 50 80 00       	mov    0x805080,%eax
  8018e2:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8018e8:	a1 84 50 80 00       	mov    0x805084,%eax
  8018ed:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8018f3:	83 c4 10             	add    $0x10,%esp
  8018f6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018fb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018fe:	c9                   	leave  
  8018ff:	c3                   	ret    

00801900 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801900:	55                   	push   %ebp
  801901:	89 e5                	mov    %esp,%ebp
  801903:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801906:	8b 45 08             	mov    0x8(%ebp),%eax
  801909:	8b 40 0c             	mov    0xc(%eax),%eax
  80190c:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801911:	ba 00 00 00 00       	mov    $0x0,%edx
  801916:	b8 06 00 00 00       	mov    $0x6,%eax
  80191b:	e8 3c ff ff ff       	call   80185c <fsipc>
}
  801920:	c9                   	leave  
  801921:	c3                   	ret    

00801922 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801922:	55                   	push   %ebp
  801923:	89 e5                	mov    %esp,%ebp
  801925:	56                   	push   %esi
  801926:	53                   	push   %ebx
  801927:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80192a:	8b 45 08             	mov    0x8(%ebp),%eax
  80192d:	8b 40 0c             	mov    0xc(%eax),%eax
  801930:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801935:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80193b:	ba 00 00 00 00       	mov    $0x0,%edx
  801940:	b8 03 00 00 00       	mov    $0x3,%eax
  801945:	e8 12 ff ff ff       	call   80185c <fsipc>
  80194a:	89 c3                	mov    %eax,%ebx
  80194c:	85 c0                	test   %eax,%eax
  80194e:	78 4b                	js     80199b <devfile_read+0x79>
		return r;
	assert(r <= n);
  801950:	39 c6                	cmp    %eax,%esi
  801952:	73 16                	jae    80196a <devfile_read+0x48>
  801954:	68 91 27 80 00       	push   $0x802791
  801959:	68 98 27 80 00       	push   $0x802798
  80195e:	6a 7a                	push   $0x7a
  801960:	68 ad 27 80 00       	push   $0x8027ad
  801965:	e8 f5 e7 ff ff       	call   80015f <_panic>
	assert(r <= PGSIZE);
  80196a:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80196f:	7e 16                	jle    801987 <devfile_read+0x65>
  801971:	68 b8 27 80 00       	push   $0x8027b8
  801976:	68 98 27 80 00       	push   $0x802798
  80197b:	6a 7b                	push   $0x7b
  80197d:	68 ad 27 80 00       	push   $0x8027ad
  801982:	e8 d8 e7 ff ff       	call   80015f <_panic>
	memmove(buf, &fsipcbuf, r);
  801987:	83 ec 04             	sub    $0x4,%esp
  80198a:	50                   	push   %eax
  80198b:	68 00 50 80 00       	push   $0x805000
  801990:	ff 75 0c             	pushl  0xc(%ebp)
  801993:	e8 51 f0 ff ff       	call   8009e9 <memmove>
	return r;
  801998:	83 c4 10             	add    $0x10,%esp
}
  80199b:	89 d8                	mov    %ebx,%eax
  80199d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019a0:	5b                   	pop    %ebx
  8019a1:	5e                   	pop    %esi
  8019a2:	5d                   	pop    %ebp
  8019a3:	c3                   	ret    

008019a4 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8019a4:	55                   	push   %ebp
  8019a5:	89 e5                	mov    %esp,%ebp
  8019a7:	53                   	push   %ebx
  8019a8:	83 ec 20             	sub    $0x20,%esp
  8019ab:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8019ae:	53                   	push   %ebx
  8019af:	e8 11 ee ff ff       	call   8007c5 <strlen>
  8019b4:	83 c4 10             	add    $0x10,%esp
  8019b7:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8019bc:	7f 63                	jg     801a21 <open+0x7d>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8019be:	83 ec 0c             	sub    $0xc,%esp
  8019c1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019c4:	50                   	push   %eax
  8019c5:	e8 e4 f8 ff ff       	call   8012ae <fd_alloc>
  8019ca:	83 c4 10             	add    $0x10,%esp
  8019cd:	85 c0                	test   %eax,%eax
  8019cf:	78 55                	js     801a26 <open+0x82>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8019d1:	83 ec 08             	sub    $0x8,%esp
  8019d4:	53                   	push   %ebx
  8019d5:	68 00 50 80 00       	push   $0x805000
  8019da:	e8 3d ee ff ff       	call   80081c <strcpy>
	fsipcbuf.open.req_omode = mode;
  8019df:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019e2:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8019e7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019ea:	b8 01 00 00 00       	mov    $0x1,%eax
  8019ef:	e8 68 fe ff ff       	call   80185c <fsipc>
  8019f4:	89 c3                	mov    %eax,%ebx
  8019f6:	83 c4 10             	add    $0x10,%esp
  8019f9:	85 c0                	test   %eax,%eax
  8019fb:	79 14                	jns    801a11 <open+0x6d>
		fd_close(fd, 0);
  8019fd:	83 ec 08             	sub    $0x8,%esp
  801a00:	6a 00                	push   $0x0
  801a02:	ff 75 f4             	pushl  -0xc(%ebp)
  801a05:	e8 dd f9 ff ff       	call   8013e7 <fd_close>
		return r;
  801a0a:	83 c4 10             	add    $0x10,%esp
  801a0d:	89 d8                	mov    %ebx,%eax
  801a0f:	eb 15                	jmp    801a26 <open+0x82>
	}

	return fd2num(fd);
  801a11:	83 ec 0c             	sub    $0xc,%esp
  801a14:	ff 75 f4             	pushl  -0xc(%ebp)
  801a17:	e8 6b f8 ff ff       	call   801287 <fd2num>
  801a1c:	83 c4 10             	add    $0x10,%esp
  801a1f:	eb 05                	jmp    801a26 <open+0x82>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801a21:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801a26:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a29:	c9                   	leave  
  801a2a:	c3                   	ret    

00801a2b <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801a2b:	55                   	push   %ebp
  801a2c:	89 e5                	mov    %esp,%ebp
  801a2e:	56                   	push   %esi
  801a2f:	53                   	push   %ebx
  801a30:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a33:	83 ec 0c             	sub    $0xc,%esp
  801a36:	ff 75 08             	pushl  0x8(%ebp)
  801a39:	e8 59 f8 ff ff       	call   801297 <fd2data>
  801a3e:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801a40:	83 c4 08             	add    $0x8,%esp
  801a43:	68 c4 27 80 00       	push   $0x8027c4
  801a48:	53                   	push   %ebx
  801a49:	e8 ce ed ff ff       	call   80081c <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801a4e:	8b 46 04             	mov    0x4(%esi),%eax
  801a51:	2b 06                	sub    (%esi),%eax
  801a53:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801a59:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a60:	00 00 00 
	stat->st_dev = &devpipe;
  801a63:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801a6a:	30 80 00 
	return 0;
}
  801a6d:	b8 00 00 00 00       	mov    $0x0,%eax
  801a72:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a75:	5b                   	pop    %ebx
  801a76:	5e                   	pop    %esi
  801a77:	5d                   	pop    %ebp
  801a78:	c3                   	ret    

00801a79 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a79:	55                   	push   %ebp
  801a7a:	89 e5                	mov    %esp,%ebp
  801a7c:	53                   	push   %ebx
  801a7d:	83 ec 0c             	sub    $0xc,%esp
  801a80:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a83:	53                   	push   %ebx
  801a84:	6a 00                	push   $0x0
  801a86:	e8 86 f2 ff ff       	call   800d11 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a8b:	89 1c 24             	mov    %ebx,(%esp)
  801a8e:	e8 04 f8 ff ff       	call   801297 <fd2data>
  801a93:	83 c4 08             	add    $0x8,%esp
  801a96:	50                   	push   %eax
  801a97:	6a 00                	push   $0x0
  801a99:	e8 73 f2 ff ff       	call   800d11 <sys_page_unmap>
}
  801a9e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801aa1:	c9                   	leave  
  801aa2:	c3                   	ret    

00801aa3 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801aa3:	55                   	push   %ebp
  801aa4:	89 e5                	mov    %esp,%ebp
  801aa6:	57                   	push   %edi
  801aa7:	56                   	push   %esi
  801aa8:	53                   	push   %ebx
  801aa9:	83 ec 1c             	sub    $0x1c,%esp
  801aac:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801aaf:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801ab1:	a1 04 40 80 00       	mov    0x804004,%eax
  801ab6:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801ab9:	83 ec 0c             	sub    $0xc,%esp
  801abc:	ff 75 e0             	pushl  -0x20(%ebp)
  801abf:	e8 f9 04 00 00       	call   801fbd <pageref>
  801ac4:	89 c3                	mov    %eax,%ebx
  801ac6:	89 3c 24             	mov    %edi,(%esp)
  801ac9:	e8 ef 04 00 00       	call   801fbd <pageref>
  801ace:	83 c4 10             	add    $0x10,%esp
  801ad1:	39 c3                	cmp    %eax,%ebx
  801ad3:	0f 94 c1             	sete   %cl
  801ad6:	0f b6 c9             	movzbl %cl,%ecx
  801ad9:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801adc:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801ae2:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801ae5:	39 ce                	cmp    %ecx,%esi
  801ae7:	74 1b                	je     801b04 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801ae9:	39 c3                	cmp    %eax,%ebx
  801aeb:	75 c4                	jne    801ab1 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801aed:	8b 42 58             	mov    0x58(%edx),%eax
  801af0:	ff 75 e4             	pushl  -0x1c(%ebp)
  801af3:	50                   	push   %eax
  801af4:	56                   	push   %esi
  801af5:	68 cb 27 80 00       	push   $0x8027cb
  801afa:	e8 38 e7 ff ff       	call   800237 <cprintf>
  801aff:	83 c4 10             	add    $0x10,%esp
  801b02:	eb ad                	jmp    801ab1 <_pipeisclosed+0xe>
	}
}
  801b04:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b07:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b0a:	5b                   	pop    %ebx
  801b0b:	5e                   	pop    %esi
  801b0c:	5f                   	pop    %edi
  801b0d:	5d                   	pop    %ebp
  801b0e:	c3                   	ret    

00801b0f <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801b0f:	55                   	push   %ebp
  801b10:	89 e5                	mov    %esp,%ebp
  801b12:	57                   	push   %edi
  801b13:	56                   	push   %esi
  801b14:	53                   	push   %ebx
  801b15:	83 ec 18             	sub    $0x18,%esp
  801b18:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801b1b:	56                   	push   %esi
  801b1c:	e8 76 f7 ff ff       	call   801297 <fd2data>
  801b21:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b23:	83 c4 10             	add    $0x10,%esp
  801b26:	bf 00 00 00 00       	mov    $0x0,%edi
  801b2b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801b2f:	75 42                	jne    801b73 <devpipe_write+0x64>
  801b31:	eb 4e                	jmp    801b81 <devpipe_write+0x72>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801b33:	89 da                	mov    %ebx,%edx
  801b35:	89 f0                	mov    %esi,%eax
  801b37:	e8 67 ff ff ff       	call   801aa3 <_pipeisclosed>
  801b3c:	85 c0                	test   %eax,%eax
  801b3e:	75 46                	jne    801b86 <devpipe_write+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801b40:	e8 28 f1 ff ff       	call   800c6d <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b45:	8b 53 04             	mov    0x4(%ebx),%edx
  801b48:	8b 03                	mov    (%ebx),%eax
  801b4a:	83 c0 20             	add    $0x20,%eax
  801b4d:	39 c2                	cmp    %eax,%edx
  801b4f:	73 e2                	jae    801b33 <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801b51:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b54:	8a 0c 38             	mov    (%eax,%edi,1),%cl
  801b57:	89 d0                	mov    %edx,%eax
  801b59:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801b5e:	79 05                	jns    801b65 <devpipe_write+0x56>
  801b60:	48                   	dec    %eax
  801b61:	83 c8 e0             	or     $0xffffffe0,%eax
  801b64:	40                   	inc    %eax
  801b65:	88 4c 03 08          	mov    %cl,0x8(%ebx,%eax,1)
		p->p_wpos++;
  801b69:	42                   	inc    %edx
  801b6a:	89 53 04             	mov    %edx,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b6d:	47                   	inc    %edi
  801b6e:	39 7d 10             	cmp    %edi,0x10(%ebp)
  801b71:	74 0e                	je     801b81 <devpipe_write+0x72>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b73:	8b 53 04             	mov    0x4(%ebx),%edx
  801b76:	8b 03                	mov    (%ebx),%eax
  801b78:	83 c0 20             	add    $0x20,%eax
  801b7b:	39 c2                	cmp    %eax,%edx
  801b7d:	73 b4                	jae    801b33 <devpipe_write+0x24>
  801b7f:	eb d0                	jmp    801b51 <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801b81:	8b 45 10             	mov    0x10(%ebp),%eax
  801b84:	eb 05                	jmp    801b8b <devpipe_write+0x7c>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b86:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801b8b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b8e:	5b                   	pop    %ebx
  801b8f:	5e                   	pop    %esi
  801b90:	5f                   	pop    %edi
  801b91:	5d                   	pop    %ebp
  801b92:	c3                   	ret    

00801b93 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b93:	55                   	push   %ebp
  801b94:	89 e5                	mov    %esp,%ebp
  801b96:	57                   	push   %edi
  801b97:	56                   	push   %esi
  801b98:	53                   	push   %ebx
  801b99:	83 ec 18             	sub    $0x18,%esp
  801b9c:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801b9f:	57                   	push   %edi
  801ba0:	e8 f2 f6 ff ff       	call   801297 <fd2data>
  801ba5:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ba7:	83 c4 10             	add    $0x10,%esp
  801baa:	be 00 00 00 00       	mov    $0x0,%esi
  801baf:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801bb3:	75 3d                	jne    801bf2 <devpipe_read+0x5f>
  801bb5:	eb 48                	jmp    801bff <devpipe_read+0x6c>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  801bb7:	89 f0                	mov    %esi,%eax
  801bb9:	eb 4e                	jmp    801c09 <devpipe_read+0x76>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801bbb:	89 da                	mov    %ebx,%edx
  801bbd:	89 f8                	mov    %edi,%eax
  801bbf:	e8 df fe ff ff       	call   801aa3 <_pipeisclosed>
  801bc4:	85 c0                	test   %eax,%eax
  801bc6:	75 3c                	jne    801c04 <devpipe_read+0x71>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801bc8:	e8 a0 f0 ff ff       	call   800c6d <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801bcd:	8b 03                	mov    (%ebx),%eax
  801bcf:	3b 43 04             	cmp    0x4(%ebx),%eax
  801bd2:	74 e7                	je     801bbb <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801bd4:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801bd9:	79 05                	jns    801be0 <devpipe_read+0x4d>
  801bdb:	48                   	dec    %eax
  801bdc:	83 c8 e0             	or     $0xffffffe0,%eax
  801bdf:	40                   	inc    %eax
  801be0:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801be4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801be7:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801bea:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bec:	46                   	inc    %esi
  801bed:	39 75 10             	cmp    %esi,0x10(%ebp)
  801bf0:	74 0d                	je     801bff <devpipe_read+0x6c>
		while (p->p_rpos == p->p_wpos) {
  801bf2:	8b 03                	mov    (%ebx),%eax
  801bf4:	3b 43 04             	cmp    0x4(%ebx),%eax
  801bf7:	75 db                	jne    801bd4 <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801bf9:	85 f6                	test   %esi,%esi
  801bfb:	75 ba                	jne    801bb7 <devpipe_read+0x24>
  801bfd:	eb bc                	jmp    801bbb <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801bff:	8b 45 10             	mov    0x10(%ebp),%eax
  801c02:	eb 05                	jmp    801c09 <devpipe_read+0x76>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c04:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801c09:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c0c:	5b                   	pop    %ebx
  801c0d:	5e                   	pop    %esi
  801c0e:	5f                   	pop    %edi
  801c0f:	5d                   	pop    %ebp
  801c10:	c3                   	ret    

00801c11 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801c11:	55                   	push   %ebp
  801c12:	89 e5                	mov    %esp,%ebp
  801c14:	56                   	push   %esi
  801c15:	53                   	push   %ebx
  801c16:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801c19:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c1c:	50                   	push   %eax
  801c1d:	e8 8c f6 ff ff       	call   8012ae <fd_alloc>
  801c22:	83 c4 10             	add    $0x10,%esp
  801c25:	85 c0                	test   %eax,%eax
  801c27:	0f 88 2a 01 00 00    	js     801d57 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c2d:	83 ec 04             	sub    $0x4,%esp
  801c30:	68 07 04 00 00       	push   $0x407
  801c35:	ff 75 f4             	pushl  -0xc(%ebp)
  801c38:	6a 00                	push   $0x0
  801c3a:	e8 4d f0 ff ff       	call   800c8c <sys_page_alloc>
  801c3f:	83 c4 10             	add    $0x10,%esp
  801c42:	85 c0                	test   %eax,%eax
  801c44:	0f 88 0d 01 00 00    	js     801d57 <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801c4a:	83 ec 0c             	sub    $0xc,%esp
  801c4d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c50:	50                   	push   %eax
  801c51:	e8 58 f6 ff ff       	call   8012ae <fd_alloc>
  801c56:	89 c3                	mov    %eax,%ebx
  801c58:	83 c4 10             	add    $0x10,%esp
  801c5b:	85 c0                	test   %eax,%eax
  801c5d:	0f 88 e2 00 00 00    	js     801d45 <pipe+0x134>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c63:	83 ec 04             	sub    $0x4,%esp
  801c66:	68 07 04 00 00       	push   $0x407
  801c6b:	ff 75 f0             	pushl  -0x10(%ebp)
  801c6e:	6a 00                	push   $0x0
  801c70:	e8 17 f0 ff ff       	call   800c8c <sys_page_alloc>
  801c75:	89 c3                	mov    %eax,%ebx
  801c77:	83 c4 10             	add    $0x10,%esp
  801c7a:	85 c0                	test   %eax,%eax
  801c7c:	0f 88 c3 00 00 00    	js     801d45 <pipe+0x134>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801c82:	83 ec 0c             	sub    $0xc,%esp
  801c85:	ff 75 f4             	pushl  -0xc(%ebp)
  801c88:	e8 0a f6 ff ff       	call   801297 <fd2data>
  801c8d:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c8f:	83 c4 0c             	add    $0xc,%esp
  801c92:	68 07 04 00 00       	push   $0x407
  801c97:	50                   	push   %eax
  801c98:	6a 00                	push   $0x0
  801c9a:	e8 ed ef ff ff       	call   800c8c <sys_page_alloc>
  801c9f:	89 c3                	mov    %eax,%ebx
  801ca1:	83 c4 10             	add    $0x10,%esp
  801ca4:	85 c0                	test   %eax,%eax
  801ca6:	0f 88 89 00 00 00    	js     801d35 <pipe+0x124>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cac:	83 ec 0c             	sub    $0xc,%esp
  801caf:	ff 75 f0             	pushl  -0x10(%ebp)
  801cb2:	e8 e0 f5 ff ff       	call   801297 <fd2data>
  801cb7:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801cbe:	50                   	push   %eax
  801cbf:	6a 00                	push   $0x0
  801cc1:	56                   	push   %esi
  801cc2:	6a 00                	push   $0x0
  801cc4:	e8 06 f0 ff ff       	call   800ccf <sys_page_map>
  801cc9:	89 c3                	mov    %eax,%ebx
  801ccb:	83 c4 20             	add    $0x20,%esp
  801cce:	85 c0                	test   %eax,%eax
  801cd0:	78 55                	js     801d27 <pipe+0x116>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801cd2:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801cd8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cdb:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801cdd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ce0:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801ce7:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801ced:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cf0:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801cf2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cf5:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801cfc:	83 ec 0c             	sub    $0xc,%esp
  801cff:	ff 75 f4             	pushl  -0xc(%ebp)
  801d02:	e8 80 f5 ff ff       	call   801287 <fd2num>
  801d07:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d0a:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801d0c:	83 c4 04             	add    $0x4,%esp
  801d0f:	ff 75 f0             	pushl  -0x10(%ebp)
  801d12:	e8 70 f5 ff ff       	call   801287 <fd2num>
  801d17:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d1a:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801d1d:	83 c4 10             	add    $0x10,%esp
  801d20:	b8 00 00 00 00       	mov    $0x0,%eax
  801d25:	eb 30                	jmp    801d57 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  801d27:	83 ec 08             	sub    $0x8,%esp
  801d2a:	56                   	push   %esi
  801d2b:	6a 00                	push   $0x0
  801d2d:	e8 df ef ff ff       	call   800d11 <sys_page_unmap>
  801d32:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801d35:	83 ec 08             	sub    $0x8,%esp
  801d38:	ff 75 f0             	pushl  -0x10(%ebp)
  801d3b:	6a 00                	push   $0x0
  801d3d:	e8 cf ef ff ff       	call   800d11 <sys_page_unmap>
  801d42:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801d45:	83 ec 08             	sub    $0x8,%esp
  801d48:	ff 75 f4             	pushl  -0xc(%ebp)
  801d4b:	6a 00                	push   $0x0
  801d4d:	e8 bf ef ff ff       	call   800d11 <sys_page_unmap>
  801d52:	83 c4 10             	add    $0x10,%esp
  801d55:	89 d8                	mov    %ebx,%eax
    err:
	return r;
}
  801d57:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d5a:	5b                   	pop    %ebx
  801d5b:	5e                   	pop    %esi
  801d5c:	5d                   	pop    %ebp
  801d5d:	c3                   	ret    

00801d5e <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801d5e:	55                   	push   %ebp
  801d5f:	89 e5                	mov    %esp,%ebp
  801d61:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d64:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d67:	50                   	push   %eax
  801d68:	ff 75 08             	pushl  0x8(%ebp)
  801d6b:	e8 b2 f5 ff ff       	call   801322 <fd_lookup>
  801d70:	83 c4 10             	add    $0x10,%esp
  801d73:	85 c0                	test   %eax,%eax
  801d75:	78 18                	js     801d8f <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801d77:	83 ec 0c             	sub    $0xc,%esp
  801d7a:	ff 75 f4             	pushl  -0xc(%ebp)
  801d7d:	e8 15 f5 ff ff       	call   801297 <fd2data>
	return _pipeisclosed(fd, p);
  801d82:	89 c2                	mov    %eax,%edx
  801d84:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d87:	e8 17 fd ff ff       	call   801aa3 <_pipeisclosed>
  801d8c:	83 c4 10             	add    $0x10,%esp
}
  801d8f:	c9                   	leave  
  801d90:	c3                   	ret    

00801d91 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801d91:	55                   	push   %ebp
  801d92:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801d94:	b8 00 00 00 00       	mov    $0x0,%eax
  801d99:	5d                   	pop    %ebp
  801d9a:	c3                   	ret    

00801d9b <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801d9b:	55                   	push   %ebp
  801d9c:	89 e5                	mov    %esp,%ebp
  801d9e:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801da1:	68 e3 27 80 00       	push   $0x8027e3
  801da6:	ff 75 0c             	pushl  0xc(%ebp)
  801da9:	e8 6e ea ff ff       	call   80081c <strcpy>
	return 0;
}
  801dae:	b8 00 00 00 00       	mov    $0x0,%eax
  801db3:	c9                   	leave  
  801db4:	c3                   	ret    

00801db5 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801db5:	55                   	push   %ebp
  801db6:	89 e5                	mov    %esp,%ebp
  801db8:	57                   	push   %edi
  801db9:	56                   	push   %esi
  801dba:	53                   	push   %ebx
  801dbb:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801dc1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801dc5:	74 45                	je     801e0c <devcons_write+0x57>
  801dc7:	b8 00 00 00 00       	mov    $0x0,%eax
  801dcc:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801dd1:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801dd7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801dda:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  801ddc:	83 fb 7f             	cmp    $0x7f,%ebx
  801ddf:	76 05                	jbe    801de6 <devcons_write+0x31>
			m = sizeof(buf) - 1;
  801de1:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801de6:	83 ec 04             	sub    $0x4,%esp
  801de9:	53                   	push   %ebx
  801dea:	03 45 0c             	add    0xc(%ebp),%eax
  801ded:	50                   	push   %eax
  801dee:	57                   	push   %edi
  801def:	e8 f5 eb ff ff       	call   8009e9 <memmove>
		sys_cputs(buf, m);
  801df4:	83 c4 08             	add    $0x8,%esp
  801df7:	53                   	push   %ebx
  801df8:	57                   	push   %edi
  801df9:	e8 d2 ed ff ff       	call   800bd0 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801dfe:	01 de                	add    %ebx,%esi
  801e00:	89 f0                	mov    %esi,%eax
  801e02:	83 c4 10             	add    $0x10,%esp
  801e05:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e08:	72 cd                	jb     801dd7 <devcons_write+0x22>
  801e0a:	eb 05                	jmp    801e11 <devcons_write+0x5c>
  801e0c:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801e11:	89 f0                	mov    %esi,%eax
  801e13:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e16:	5b                   	pop    %ebx
  801e17:	5e                   	pop    %esi
  801e18:	5f                   	pop    %edi
  801e19:	5d                   	pop    %ebp
  801e1a:	c3                   	ret    

00801e1b <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801e1b:	55                   	push   %ebp
  801e1c:	89 e5                	mov    %esp,%ebp
  801e1e:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801e21:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801e25:	75 07                	jne    801e2e <devcons_read+0x13>
  801e27:	eb 23                	jmp    801e4c <devcons_read+0x31>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801e29:	e8 3f ee ff ff       	call   800c6d <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801e2e:	e8 bb ed ff ff       	call   800bee <sys_cgetc>
  801e33:	85 c0                	test   %eax,%eax
  801e35:	74 f2                	je     801e29 <devcons_read+0xe>
		sys_yield();
	if (c < 0)
  801e37:	85 c0                	test   %eax,%eax
  801e39:	78 1d                	js     801e58 <devcons_read+0x3d>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801e3b:	83 f8 04             	cmp    $0x4,%eax
  801e3e:	74 13                	je     801e53 <devcons_read+0x38>
		return 0;
	*(char*)vbuf = c;
  801e40:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e43:	88 02                	mov    %al,(%edx)
	return 1;
  801e45:	b8 01 00 00 00       	mov    $0x1,%eax
  801e4a:	eb 0c                	jmp    801e58 <devcons_read+0x3d>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801e4c:	b8 00 00 00 00       	mov    $0x0,%eax
  801e51:	eb 05                	jmp    801e58 <devcons_read+0x3d>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801e53:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801e58:	c9                   	leave  
  801e59:	c3                   	ret    

00801e5a <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801e5a:	55                   	push   %ebp
  801e5b:	89 e5                	mov    %esp,%ebp
  801e5d:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801e60:	8b 45 08             	mov    0x8(%ebp),%eax
  801e63:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801e66:	6a 01                	push   $0x1
  801e68:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e6b:	50                   	push   %eax
  801e6c:	e8 5f ed ff ff       	call   800bd0 <sys_cputs>
}
  801e71:	83 c4 10             	add    $0x10,%esp
  801e74:	c9                   	leave  
  801e75:	c3                   	ret    

00801e76 <getchar>:

int
getchar(void)
{
  801e76:	55                   	push   %ebp
  801e77:	89 e5                	mov    %esp,%ebp
  801e79:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801e7c:	6a 01                	push   $0x1
  801e7e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e81:	50                   	push   %eax
  801e82:	6a 00                	push   $0x0
  801e84:	e8 1a f7 ff ff       	call   8015a3 <read>
	if (r < 0)
  801e89:	83 c4 10             	add    $0x10,%esp
  801e8c:	85 c0                	test   %eax,%eax
  801e8e:	78 0f                	js     801e9f <getchar+0x29>
		return r;
	if (r < 1)
  801e90:	85 c0                	test   %eax,%eax
  801e92:	7e 06                	jle    801e9a <getchar+0x24>
		return -E_EOF;
	return c;
  801e94:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801e98:	eb 05                	jmp    801e9f <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801e9a:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801e9f:	c9                   	leave  
  801ea0:	c3                   	ret    

00801ea1 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801ea1:	55                   	push   %ebp
  801ea2:	89 e5                	mov    %esp,%ebp
  801ea4:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ea7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801eaa:	50                   	push   %eax
  801eab:	ff 75 08             	pushl  0x8(%ebp)
  801eae:	e8 6f f4 ff ff       	call   801322 <fd_lookup>
  801eb3:	83 c4 10             	add    $0x10,%esp
  801eb6:	85 c0                	test   %eax,%eax
  801eb8:	78 11                	js     801ecb <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801eba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ebd:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ec3:	39 10                	cmp    %edx,(%eax)
  801ec5:	0f 94 c0             	sete   %al
  801ec8:	0f b6 c0             	movzbl %al,%eax
}
  801ecb:	c9                   	leave  
  801ecc:	c3                   	ret    

00801ecd <opencons>:

int
opencons(void)
{
  801ecd:	55                   	push   %ebp
  801ece:	89 e5                	mov    %esp,%ebp
  801ed0:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ed3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ed6:	50                   	push   %eax
  801ed7:	e8 d2 f3 ff ff       	call   8012ae <fd_alloc>
  801edc:	83 c4 10             	add    $0x10,%esp
  801edf:	85 c0                	test   %eax,%eax
  801ee1:	78 3a                	js     801f1d <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ee3:	83 ec 04             	sub    $0x4,%esp
  801ee6:	68 07 04 00 00       	push   $0x407
  801eeb:	ff 75 f4             	pushl  -0xc(%ebp)
  801eee:	6a 00                	push   $0x0
  801ef0:	e8 97 ed ff ff       	call   800c8c <sys_page_alloc>
  801ef5:	83 c4 10             	add    $0x10,%esp
  801ef8:	85 c0                	test   %eax,%eax
  801efa:	78 21                	js     801f1d <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801efc:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f02:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f05:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801f07:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f0a:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801f11:	83 ec 0c             	sub    $0xc,%esp
  801f14:	50                   	push   %eax
  801f15:	e8 6d f3 ff ff       	call   801287 <fd2num>
  801f1a:	83 c4 10             	add    $0x10,%esp
}
  801f1d:	c9                   	leave  
  801f1e:	c3                   	ret    

00801f1f <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801f1f:	55                   	push   %ebp
  801f20:	89 e5                	mov    %esp,%ebp
  801f22:	53                   	push   %ebx
  801f23:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (_pgfault_handler == 0) {
  801f26:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801f2d:	75 5b                	jne    801f8a <set_pgfault_handler+0x6b>
		// First time through!
		// LAB 4: Your code here.
		void *va = (void *)(UXSTACKTOP - PGSIZE);
		envid_t eid = sys_getenvid();
  801f2f:	e8 1a ed ff ff       	call   800c4e <sys_getenvid>
  801f34:	89 c3                	mov    %eax,%ebx
		r = sys_page_alloc(eid,va,PTE_P | PTE_U | PTE_W);
  801f36:	83 ec 04             	sub    $0x4,%esp
  801f39:	6a 07                	push   $0x7
  801f3b:	68 00 f0 bf ee       	push   $0xeebff000
  801f40:	50                   	push   %eax
  801f41:	e8 46 ed ff ff       	call   800c8c <sys_page_alloc>
		if(r<0) panic("set_pgfault_handler\n");
  801f46:	83 c4 10             	add    $0x10,%esp
  801f49:	85 c0                	test   %eax,%eax
  801f4b:	79 14                	jns    801f61 <set_pgfault_handler+0x42>
  801f4d:	83 ec 04             	sub    $0x4,%esp
  801f50:	68 ef 27 80 00       	push   $0x8027ef
  801f55:	6a 23                	push   $0x23
  801f57:	68 04 28 80 00       	push   $0x802804
  801f5c:	e8 fe e1 ff ff       	call   80015f <_panic>
		r = sys_env_set_pgfault_upcall(eid,_pgfault_upcall);
  801f61:	83 ec 08             	sub    $0x8,%esp
  801f64:	68 97 1f 80 00       	push   $0x801f97
  801f69:	53                   	push   %ebx
  801f6a:	e8 68 ee ff ff       	call   800dd7 <sys_env_set_pgfault_upcall>
		if(r<0) panic("set_pgfault_handler\n");
  801f6f:	83 c4 10             	add    $0x10,%esp
  801f72:	85 c0                	test   %eax,%eax
  801f74:	79 14                	jns    801f8a <set_pgfault_handler+0x6b>
  801f76:	83 ec 04             	sub    $0x4,%esp
  801f79:	68 ef 27 80 00       	push   $0x8027ef
  801f7e:	6a 25                	push   $0x25
  801f80:	68 04 28 80 00       	push   $0x802804
  801f85:	e8 d5 e1 ff ff       	call   80015f <_panic>
		// panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801f8a:	8b 45 08             	mov    0x8(%ebp),%eax
  801f8d:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801f92:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f95:	c9                   	leave  
  801f96:	c3                   	ret    

00801f97 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801f97:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801f98:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801f9d:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801f9f:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl %esp,%ebx
  801fa2:	89 e3                	mov    %esp,%ebx
	movl 40(%esp),%eax 	// esp from utf_fault_va to utf_regs(end)
  801fa4:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl 48(%esp),%esp 	// 
  801fa8:	8b 64 24 30          	mov    0x30(%esp),%esp
	pushl %eax
  801fac:	50                   	push   %eax
 
 
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	movl %ebx,%esp
  801fad:	89 dc                	mov    %ebx,%esp
	subl $4,48(%esp)
  801faf:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	popl %eax
  801fb4:	58                   	pop    %eax
	popl %eax
  801fb5:	58                   	pop    %eax
	popal
  801fb6:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	add $4,%esp
  801fb7:	83 c4 04             	add    $0x4,%esp
	popfl
  801fba:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  801fbb:	5c                   	pop    %esp
 
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801fbc:	c3                   	ret    

00801fbd <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801fbd:	55                   	push   %ebp
  801fbe:	89 e5                	mov    %esp,%ebp
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fc0:	8b 45 08             	mov    0x8(%ebp),%eax
  801fc3:	c1 e8 16             	shr    $0x16,%eax
  801fc6:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801fcd:	a8 01                	test   $0x1,%al
  801fcf:	74 21                	je     801ff2 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801fd1:	8b 45 08             	mov    0x8(%ebp),%eax
  801fd4:	c1 e8 0c             	shr    $0xc,%eax
  801fd7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801fde:	a8 01                	test   $0x1,%al
  801fe0:	74 17                	je     801ff9 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801fe2:	c1 e8 0c             	shr    $0xc,%eax
  801fe5:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801fec:	ef 
  801fed:	0f b7 c0             	movzwl %ax,%eax
  801ff0:	eb 0c                	jmp    801ffe <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801ff2:	b8 00 00 00 00       	mov    $0x0,%eax
  801ff7:	eb 05                	jmp    801ffe <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801ff9:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801ffe:	5d                   	pop    %ebp
  801fff:	c3                   	ret    

00802000 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  802000:	55                   	push   %ebp
  802001:	57                   	push   %edi
  802002:	56                   	push   %esi
  802003:	53                   	push   %ebx
  802004:	83 ec 1c             	sub    $0x1c,%esp
  802007:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80200b:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  80200f:	8b 7c 24 38          	mov    0x38(%esp),%edi
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  802013:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802017:	89 ca                	mov    %ecx,%edx
  const DWunion dd = {.ll = d};
  802019:	89 f8                	mov    %edi,%eax
  80201b:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  80201f:	85 f6                	test   %esi,%esi
  802021:	75 2d                	jne    802050 <__udivdi3+0x50>
    {
      if (d0 > n1)
  802023:	39 cf                	cmp    %ecx,%edi
  802025:	77 65                	ja     80208c <__udivdi3+0x8c>
  802027:	89 fd                	mov    %edi,%ebp
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802029:	85 ff                	test   %edi,%edi
  80202b:	75 0b                	jne    802038 <__udivdi3+0x38>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  80202d:	b8 01 00 00 00       	mov    $0x1,%eax
  802032:	31 d2                	xor    %edx,%edx
  802034:	f7 f7                	div    %edi
  802036:	89 c5                	mov    %eax,%ebp

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802038:	31 d2                	xor    %edx,%edx
  80203a:	89 c8                	mov    %ecx,%eax
  80203c:	f7 f5                	div    %ebp
  80203e:	89 c1                	mov    %eax,%ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802040:	89 d8                	mov    %ebx,%eax
  802042:	f7 f5                	div    %ebp
  802044:	89 cf                	mov    %ecx,%edi
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802046:	89 fa                	mov    %edi,%edx
  802048:	83 c4 1c             	add    $0x1c,%esp
  80204b:	5b                   	pop    %ebx
  80204c:	5e                   	pop    %esi
  80204d:	5f                   	pop    %edi
  80204e:	5d                   	pop    %ebp
  80204f:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802050:	39 ce                	cmp    %ecx,%esi
  802052:	77 28                	ja     80207c <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802054:	0f bd fe             	bsr    %esi,%edi
	  if (bm == 0)
  802057:	83 f7 1f             	xor    $0x1f,%edi
  80205a:	75 40                	jne    80209c <__udivdi3+0x9c>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  80205c:	39 ce                	cmp    %ecx,%esi
  80205e:	72 0a                	jb     80206a <__udivdi3+0x6a>
  802060:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802064:	0f 87 9e 00 00 00    	ja     802108 <__udivdi3+0x108>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  80206a:	b8 01 00 00 00       	mov    $0x1,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80206f:	89 fa                	mov    %edi,%edx
  802071:	83 c4 1c             	add    $0x1c,%esp
  802074:	5b                   	pop    %ebx
  802075:	5e                   	pop    %esi
  802076:	5f                   	pop    %edi
  802077:	5d                   	pop    %ebp
  802078:	c3                   	ret    
  802079:	8d 76 00             	lea    0x0(%esi),%esi
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  80207c:	31 ff                	xor    %edi,%edi
  80207e:	31 c0                	xor    %eax,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802080:	89 fa                	mov    %edi,%edx
  802082:	83 c4 1c             	add    $0x1c,%esp
  802085:	5b                   	pop    %ebx
  802086:	5e                   	pop    %esi
  802087:	5f                   	pop    %edi
  802088:	5d                   	pop    %ebp
  802089:	c3                   	ret    
  80208a:	66 90                	xchg   %ax,%ax
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80208c:	89 d8                	mov    %ebx,%eax
  80208e:	f7 f7                	div    %edi
  802090:	31 ff                	xor    %edi,%edi
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802092:	89 fa                	mov    %edi,%edx
  802094:	83 c4 1c             	add    $0x1c,%esp
  802097:	5b                   	pop    %ebx
  802098:	5e                   	pop    %esi
  802099:	5f                   	pop    %edi
  80209a:	5d                   	pop    %ebp
  80209b:	c3                   	ret    
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  80209c:	bd 20 00 00 00       	mov    $0x20,%ebp
  8020a1:	89 eb                	mov    %ebp,%ebx
  8020a3:	29 fb                	sub    %edi,%ebx

	      d1 = (d1 << bm) | (d0 >> b);
  8020a5:	89 f9                	mov    %edi,%ecx
  8020a7:	d3 e6                	shl    %cl,%esi
  8020a9:	89 c5                	mov    %eax,%ebp
  8020ab:	88 d9                	mov    %bl,%cl
  8020ad:	d3 ed                	shr    %cl,%ebp
  8020af:	89 e9                	mov    %ebp,%ecx
  8020b1:	09 f1                	or     %esi,%ecx
  8020b3:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
	      d0 = d0 << bm;
  8020b7:	89 f9                	mov    %edi,%ecx
  8020b9:	d3 e0                	shl    %cl,%eax
  8020bb:	89 c5                	mov    %eax,%ebp
	      n2 = n1 >> b;
  8020bd:	89 d6                	mov    %edx,%esi
  8020bf:	88 d9                	mov    %bl,%cl
  8020c1:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
  8020c3:	89 f9                	mov    %edi,%ecx
  8020c5:	d3 e2                	shl    %cl,%edx
  8020c7:	8b 44 24 08          	mov    0x8(%esp),%eax
  8020cb:	88 d9                	mov    %bl,%cl
  8020cd:	d3 e8                	shr    %cl,%eax
  8020cf:	09 c2                	or     %eax,%edx
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8020d1:	89 d0                	mov    %edx,%eax
  8020d3:	89 f2                	mov    %esi,%edx
  8020d5:	f7 74 24 0c          	divl   0xc(%esp)
  8020d9:	89 d6                	mov    %edx,%esi
  8020db:	89 c3                	mov    %eax,%ebx
	      umul_ppmm (m1, m0, q0, d0);
  8020dd:	f7 e5                	mul    %ebp

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8020df:	39 d6                	cmp    %edx,%esi
  8020e1:	72 19                	jb     8020fc <__udivdi3+0xfc>
  8020e3:	74 0b                	je     8020f0 <__udivdi3+0xf0>
  8020e5:	89 d8                	mov    %ebx,%eax
  8020e7:	31 ff                	xor    %edi,%edi
  8020e9:	e9 58 ff ff ff       	jmp    802046 <__udivdi3+0x46>
  8020ee:	66 90                	xchg   %ax,%ax
  8020f0:	8b 54 24 08          	mov    0x8(%esp),%edx
  8020f4:	89 f9                	mov    %edi,%ecx
  8020f6:	d3 e2                	shl    %cl,%edx
  8020f8:	39 c2                	cmp    %eax,%edx
  8020fa:	73 e9                	jae    8020e5 <__udivdi3+0xe5>
  8020fc:	8d 43 ff             	lea    -0x1(%ebx),%eax
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8020ff:	31 ff                	xor    %edi,%edi
  802101:	e9 40 ff ff ff       	jmp    802046 <__udivdi3+0x46>
  802106:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802108:	31 c0                	xor    %eax,%eax
  80210a:	e9 37 ff ff ff       	jmp    802046 <__udivdi3+0x46>
  80210f:	90                   	nop

00802110 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  802110:	55                   	push   %ebp
  802111:	57                   	push   %edi
  802112:	56                   	push   %esi
  802113:	53                   	push   %ebx
  802114:	83 ec 1c             	sub    $0x1c,%esp
  802117:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80211b:	8b 74 24 34          	mov    0x34(%esp),%esi
  80211f:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802123:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  802127:	89 44 24 0c          	mov    %eax,0xc(%esp)
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  80212b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80212f:	89 f3                	mov    %esi,%ebx
  const DWunion dd = {.ll = d};
  802131:	89 fa                	mov    %edi,%edx
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  802133:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  n1 = nn.s.high;
  802137:	89 34 24             	mov    %esi,(%esp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  80213a:	85 c0                	test   %eax,%eax
  80213c:	75 1a                	jne    802158 <__umoddi3+0x48>
    {
      if (d0 > n1)
  80213e:	39 f7                	cmp    %esi,%edi
  802140:	0f 86 a2 00 00 00    	jbe    8021e8 <__umoddi3+0xd8>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802146:	89 c8                	mov    %ecx,%eax
  802148:	89 f2                	mov    %esi,%edx
  80214a:	f7 f7                	div    %edi
  80214c:	89 d0                	mov    %edx,%eax

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  80214e:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802150:	83 c4 1c             	add    $0x1c,%esp
  802153:	5b                   	pop    %ebx
  802154:	5e                   	pop    %esi
  802155:	5f                   	pop    %edi
  802156:	5d                   	pop    %ebp
  802157:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802158:	39 f0                	cmp    %esi,%eax
  80215a:	0f 87 ac 00 00 00    	ja     80220c <__umoddi3+0xfc>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802160:	0f bd e8             	bsr    %eax,%ebp
	  if (bm == 0)
  802163:	83 f5 1f             	xor    $0x1f,%ebp
  802166:	0f 84 ac 00 00 00    	je     802218 <__umoddi3+0x108>
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  80216c:	bf 20 00 00 00       	mov    $0x20,%edi
  802171:	29 ef                	sub    %ebp,%edi
  802173:	89 fe                	mov    %edi,%esi
  802175:	89 7c 24 0c          	mov    %edi,0xc(%esp)

	      d1 = (d1 << bm) | (d0 >> b);
  802179:	89 e9                	mov    %ebp,%ecx
  80217b:	d3 e0                	shl    %cl,%eax
  80217d:	89 d7                	mov    %edx,%edi
  80217f:	89 f1                	mov    %esi,%ecx
  802181:	d3 ef                	shr    %cl,%edi
  802183:	09 c7                	or     %eax,%edi
	      d0 = d0 << bm;
  802185:	89 e9                	mov    %ebp,%ecx
  802187:	d3 e2                	shl    %cl,%edx
  802189:	89 14 24             	mov    %edx,(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  80218c:	89 d8                	mov    %ebx,%eax
  80218e:	d3 e0                	shl    %cl,%eax
  802190:	89 c2                	mov    %eax,%edx
	      n0 = n0 << bm;
  802192:	8b 44 24 08          	mov    0x8(%esp),%eax
  802196:	d3 e0                	shl    %cl,%eax
  802198:	89 44 24 04          	mov    %eax,0x4(%esp)

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  80219c:	8b 44 24 08          	mov    0x8(%esp),%eax
  8021a0:	89 f1                	mov    %esi,%ecx
  8021a2:	d3 e8                	shr    %cl,%eax
  8021a4:	09 d0                	or     %edx,%eax
  8021a6:	d3 eb                	shr    %cl,%ebx
  8021a8:	89 da                	mov    %ebx,%edx
  8021aa:	f7 f7                	div    %edi
  8021ac:	89 d3                	mov    %edx,%ebx
	      umul_ppmm (m1, m0, q0, d0);
  8021ae:	f7 24 24             	mull   (%esp)
  8021b1:	89 c6                	mov    %eax,%esi
  8021b3:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8021b5:	39 d3                	cmp    %edx,%ebx
  8021b7:	0f 82 87 00 00 00    	jb     802244 <__umoddi3+0x134>
  8021bd:	0f 84 91 00 00 00    	je     802254 <__umoddi3+0x144>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  8021c3:	8b 54 24 04          	mov    0x4(%esp),%edx
  8021c7:	29 f2                	sub    %esi,%edx
  8021c9:	19 cb                	sbb    %ecx,%ebx
		  rr.s.low = (n1 << b) | (n0 >> bm);
  8021cb:	89 d8                	mov    %ebx,%eax
  8021cd:	8a 4c 24 0c          	mov    0xc(%esp),%cl
  8021d1:	d3 e0                	shl    %cl,%eax
  8021d3:	89 e9                	mov    %ebp,%ecx
  8021d5:	d3 ea                	shr    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  8021d7:	09 d0                	or     %edx,%eax
  8021d9:	89 e9                	mov    %ebp,%ecx
  8021db:	d3 eb                	shr    %cl,%ebx
  8021dd:	89 da                	mov    %ebx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8021df:	83 c4 1c             	add    $0x1c,%esp
  8021e2:	5b                   	pop    %ebx
  8021e3:	5e                   	pop    %esi
  8021e4:	5f                   	pop    %edi
  8021e5:	5d                   	pop    %ebp
  8021e6:	c3                   	ret    
  8021e7:	90                   	nop
  8021e8:	89 fd                	mov    %edi,%ebp
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8021ea:	85 ff                	test   %edi,%edi
  8021ec:	75 0b                	jne    8021f9 <__umoddi3+0xe9>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8021ee:	b8 01 00 00 00       	mov    $0x1,%eax
  8021f3:	31 d2                	xor    %edx,%edx
  8021f5:	f7 f7                	div    %edi
  8021f7:	89 c5                	mov    %eax,%ebp

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8021f9:	89 f0                	mov    %esi,%eax
  8021fb:	31 d2                	xor    %edx,%edx
  8021fd:	f7 f5                	div    %ebp
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8021ff:	89 c8                	mov    %ecx,%eax
  802201:	f7 f5                	div    %ebp
  802203:	89 d0                	mov    %edx,%eax
  802205:	e9 44 ff ff ff       	jmp    80214e <__umoddi3+0x3e>
  80220a:	66 90                	xchg   %ax,%ax
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  80220c:	89 c8                	mov    %ecx,%eax
  80220e:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802210:	83 c4 1c             	add    $0x1c,%esp
  802213:	5b                   	pop    %ebx
  802214:	5e                   	pop    %esi
  802215:	5f                   	pop    %edi
  802216:	5d                   	pop    %ebp
  802217:	c3                   	ret    

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802218:	3b 04 24             	cmp    (%esp),%eax
  80221b:	72 06                	jb     802223 <__umoddi3+0x113>
  80221d:	3b 7c 24 04          	cmp    0x4(%esp),%edi
  802221:	77 0f                	ja     802232 <__umoddi3+0x122>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802223:	89 f2                	mov    %esi,%edx
  802225:	29 f9                	sub    %edi,%ecx
  802227:	1b 54 24 0c          	sbb    0xc(%esp),%edx
  80222b:	89 14 24             	mov    %edx,(%esp)
  80222e:	89 4c 24 04          	mov    %ecx,0x4(%esp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  802232:	8b 44 24 04          	mov    0x4(%esp),%eax
  802236:	8b 14 24             	mov    (%esp),%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802239:	83 c4 1c             	add    $0x1c,%esp
  80223c:	5b                   	pop    %ebx
  80223d:	5e                   	pop    %esi
  80223e:	5f                   	pop    %edi
  80223f:	5d                   	pop    %ebp
  802240:	c3                   	ret    
  802241:	8d 76 00             	lea    0x0(%esi),%esi
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802244:	2b 04 24             	sub    (%esp),%eax
  802247:	19 fa                	sbb    %edi,%edx
  802249:	89 d1                	mov    %edx,%ecx
  80224b:	89 c6                	mov    %eax,%esi
  80224d:	e9 71 ff ff ff       	jmp    8021c3 <__umoddi3+0xb3>
  802252:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802254:	39 44 24 04          	cmp    %eax,0x4(%esp)
  802258:	72 ea                	jb     802244 <__umoddi3+0x134>
  80225a:	89 d9                	mov    %ebx,%ecx
  80225c:	e9 62 ff ff ff       	jmp    8021c3 <__umoddi3+0xb3>
