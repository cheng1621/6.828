
obj/user/stresssched.debug:     file format elf32-i386


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
  80002c:	e8 da 00 00 00       	call   80010b <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

volatile int counter;

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
	int i, j;
	int seen;
	envid_t parent = sys_getenvid();
  800038:	e8 26 0c 00 00       	call   800c63 <sys_getenvid>
  80003d:	89 c6                	mov    %eax,%esi

	// Fork several environments
	for (i = 0; i < 20; i++)
  80003f:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (fork() == 0)
  800044:	e8 38 0f 00 00       	call   800f81 <fork>
  800049:	85 c0                	test   %eax,%eax
  80004b:	74 08                	je     800055 <umain+0x22>
	int i, j;
	int seen;
	envid_t parent = sys_getenvid();

	// Fork several environments
	for (i = 0; i < 20; i++)
  80004d:	43                   	inc    %ebx
  80004e:	83 fb 14             	cmp    $0x14,%ebx
  800051:	75 f1                	jne    800044 <umain+0x11>
  800053:	eb 2e                	jmp    800083 <umain+0x50>
		if (fork() == 0)
			break;
	if (i == 20) {
  800055:	83 fb 14             	cmp    $0x14,%ebx
  800058:	74 29                	je     800083 <umain+0x50>
		sys_yield();
		return;
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
  80005a:	89 f0                	mov    %esi,%eax
  80005c:	25 ff 03 00 00       	and    $0x3ff,%eax
  800061:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  800068:	89 c2                	mov    %eax,%edx
  80006a:	c1 e2 07             	shl    $0x7,%edx
  80006d:	29 ca                	sub    %ecx,%edx
  80006f:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  800075:	8b 52 54             	mov    0x54(%edx),%edx
  800078:	bb 0a 00 00 00       	mov    $0xa,%ebx
  80007d:	85 d2                	test   %edx,%edx
  80007f:	74 28                	je     8000a9 <umain+0x76>
  800081:	eb 07                	jmp    80008a <umain+0x57>
	// Fork several environments
	for (i = 0; i < 20; i++)
		if (fork() == 0)
			break;
	if (i == 20) {
		sys_yield();
  800083:	e8 fa 0b 00 00       	call   800c82 <sys_yield>
		return;
  800088:	eb 7a                	jmp    800104 <umain+0xd1>
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
  80008a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800091:	c1 e0 07             	shl    $0x7,%eax
  800094:	29 d0                	sub    %edx,%eax
  800096:	05 00 00 c0 ee       	add    $0xeec00000,%eax
		asm volatile("pause");
  80009b:	f3 90                	pause  
		sys_yield();
		return;
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
  80009d:	8b 50 54             	mov    0x54(%eax),%edx
  8000a0:	85 d2                	test   %edx,%edx
  8000a2:	75 f7                	jne    80009b <umain+0x68>
  8000a4:	bb 0a 00 00 00       	mov    $0xa,%ebx
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
		sys_yield();
  8000a9:	e8 d4 0b 00 00       	call   800c82 <sys_yield>
  8000ae:	ba 10 27 00 00       	mov    $0x2710,%edx
		for (j = 0; j < 10000; j++)
			counter++;
  8000b3:	a1 04 40 80 00       	mov    0x804004,%eax
  8000b8:	40                   	inc    %eax
  8000b9:	a3 04 40 80 00       	mov    %eax,0x804004
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
		sys_yield();
		for (j = 0; j < 10000; j++)
  8000be:	4a                   	dec    %edx
  8000bf:	75 f2                	jne    8000b3 <umain+0x80>
	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
  8000c1:	4b                   	dec    %ebx
  8000c2:	75 e5                	jne    8000a9 <umain+0x76>
		sys_yield();
		for (j = 0; j < 10000; j++)
			counter++;
	}

	if (counter != 10*10000)
  8000c4:	a1 04 40 80 00       	mov    0x804004,%eax
  8000c9:	3d a0 86 01 00       	cmp    $0x186a0,%eax
  8000ce:	74 17                	je     8000e7 <umain+0xb4>
		panic("ran on two CPUs at once (counter is %d)", counter);
  8000d0:	a1 04 40 80 00       	mov    0x804004,%eax
  8000d5:	50                   	push   %eax
  8000d6:	68 80 22 80 00       	push   $0x802280
  8000db:	6a 21                	push   $0x21
  8000dd:	68 a8 22 80 00       	push   $0x8022a8
  8000e2:	e8 8d 00 00 00       	call   800174 <_panic>

	// Check that we see environments running on different CPUs
	cprintf("[%08x] stresssched on CPU %d\n", thisenv->env_id, thisenv->env_cpunum);
  8000e7:	a1 08 40 80 00       	mov    0x804008,%eax
  8000ec:	8b 50 5c             	mov    0x5c(%eax),%edx
  8000ef:	8b 40 48             	mov    0x48(%eax),%eax
  8000f2:	83 ec 04             	sub    $0x4,%esp
  8000f5:	52                   	push   %edx
  8000f6:	50                   	push   %eax
  8000f7:	68 bb 22 80 00       	push   $0x8022bb
  8000fc:	e8 4b 01 00 00       	call   80024c <cprintf>
  800101:	83 c4 10             	add    $0x10,%esp

}
  800104:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800107:	5b                   	pop    %ebx
  800108:	5e                   	pop    %esi
  800109:	5d                   	pop    %ebp
  80010a:	c3                   	ret    

0080010b <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80010b:	55                   	push   %ebp
  80010c:	89 e5                	mov    %esp,%ebp
  80010e:	56                   	push   %esi
  80010f:	53                   	push   %ebx
  800110:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800113:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800116:	e8 48 0b 00 00       	call   800c63 <sys_getenvid>
  80011b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800120:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800127:	c1 e0 07             	shl    $0x7,%eax
  80012a:	29 d0                	sub    %edx,%eax
  80012c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800131:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800136:	85 db                	test   %ebx,%ebx
  800138:	7e 07                	jle    800141 <libmain+0x36>
		binaryname = argv[0];
  80013a:	8b 06                	mov    (%esi),%eax
  80013c:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800141:	83 ec 08             	sub    $0x8,%esp
  800144:	56                   	push   %esi
  800145:	53                   	push   %ebx
  800146:	e8 e8 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80014b:	e8 0a 00 00 00       	call   80015a <exit>
}
  800150:	83 c4 10             	add    $0x10,%esp
  800153:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800156:	5b                   	pop    %ebx
  800157:	5e                   	pop    %esi
  800158:	5d                   	pop    %ebp
  800159:	c3                   	ret    

0080015a <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80015a:	55                   	push   %ebp
  80015b:	89 e5                	mov    %esp,%ebp
  80015d:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800160:	e8 17 12 00 00       	call   80137c <close_all>
	sys_env_destroy(0);
  800165:	83 ec 0c             	sub    $0xc,%esp
  800168:	6a 00                	push   $0x0
  80016a:	e8 b3 0a 00 00       	call   800c22 <sys_env_destroy>
}
  80016f:	83 c4 10             	add    $0x10,%esp
  800172:	c9                   	leave  
  800173:	c3                   	ret    

00800174 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800174:	55                   	push   %ebp
  800175:	89 e5                	mov    %esp,%ebp
  800177:	56                   	push   %esi
  800178:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800179:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80017c:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800182:	e8 dc 0a 00 00       	call   800c63 <sys_getenvid>
  800187:	83 ec 0c             	sub    $0xc,%esp
  80018a:	ff 75 0c             	pushl  0xc(%ebp)
  80018d:	ff 75 08             	pushl  0x8(%ebp)
  800190:	56                   	push   %esi
  800191:	50                   	push   %eax
  800192:	68 e4 22 80 00       	push   $0x8022e4
  800197:	e8 b0 00 00 00       	call   80024c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80019c:	83 c4 18             	add    $0x18,%esp
  80019f:	53                   	push   %ebx
  8001a0:	ff 75 10             	pushl  0x10(%ebp)
  8001a3:	e8 53 00 00 00       	call   8001fb <vcprintf>
	cprintf("\n");
  8001a8:	c7 04 24 6b 26 80 00 	movl   $0x80266b,(%esp)
  8001af:	e8 98 00 00 00       	call   80024c <cprintf>
  8001b4:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001b7:	cc                   	int3   
  8001b8:	eb fd                	jmp    8001b7 <_panic+0x43>

008001ba <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001ba:	55                   	push   %ebp
  8001bb:	89 e5                	mov    %esp,%ebp
  8001bd:	53                   	push   %ebx
  8001be:	83 ec 04             	sub    $0x4,%esp
  8001c1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001c4:	8b 13                	mov    (%ebx),%edx
  8001c6:	8d 42 01             	lea    0x1(%edx),%eax
  8001c9:	89 03                	mov    %eax,(%ebx)
  8001cb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001ce:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001d2:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001d7:	75 1a                	jne    8001f3 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001d9:	83 ec 08             	sub    $0x8,%esp
  8001dc:	68 ff 00 00 00       	push   $0xff
  8001e1:	8d 43 08             	lea    0x8(%ebx),%eax
  8001e4:	50                   	push   %eax
  8001e5:	e8 fb 09 00 00       	call   800be5 <sys_cputs>
		b->idx = 0;
  8001ea:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001f0:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001f3:	ff 43 04             	incl   0x4(%ebx)
}
  8001f6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001f9:	c9                   	leave  
  8001fa:	c3                   	ret    

008001fb <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001fb:	55                   	push   %ebp
  8001fc:	89 e5                	mov    %esp,%ebp
  8001fe:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800204:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80020b:	00 00 00 
	b.cnt = 0;
  80020e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800215:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800218:	ff 75 0c             	pushl  0xc(%ebp)
  80021b:	ff 75 08             	pushl  0x8(%ebp)
  80021e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800224:	50                   	push   %eax
  800225:	68 ba 01 80 00       	push   $0x8001ba
  80022a:	e8 54 01 00 00       	call   800383 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80022f:	83 c4 08             	add    $0x8,%esp
  800232:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800238:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80023e:	50                   	push   %eax
  80023f:	e8 a1 09 00 00       	call   800be5 <sys_cputs>

	return b.cnt;
}
  800244:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80024a:	c9                   	leave  
  80024b:	c3                   	ret    

0080024c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80024c:	55                   	push   %ebp
  80024d:	89 e5                	mov    %esp,%ebp
  80024f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800252:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800255:	50                   	push   %eax
  800256:	ff 75 08             	pushl  0x8(%ebp)
  800259:	e8 9d ff ff ff       	call   8001fb <vcprintf>
	va_end(ap);

	return cnt;
}
  80025e:	c9                   	leave  
  80025f:	c3                   	ret    

00800260 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800260:	55                   	push   %ebp
  800261:	89 e5                	mov    %esp,%ebp
  800263:	57                   	push   %edi
  800264:	56                   	push   %esi
  800265:	53                   	push   %ebx
  800266:	83 ec 1c             	sub    $0x1c,%esp
  800269:	89 c6                	mov    %eax,%esi
  80026b:	89 d7                	mov    %edx,%edi
  80026d:	8b 45 08             	mov    0x8(%ebp),%eax
  800270:	8b 55 0c             	mov    0xc(%ebp),%edx
  800273:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800276:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800279:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80027c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800281:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800284:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800287:	39 d3                	cmp    %edx,%ebx
  800289:	72 11                	jb     80029c <printnum+0x3c>
  80028b:	39 45 10             	cmp    %eax,0x10(%ebp)
  80028e:	76 0c                	jbe    80029c <printnum+0x3c>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800290:	8b 45 14             	mov    0x14(%ebp),%eax
  800293:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800296:	85 db                	test   %ebx,%ebx
  800298:	7f 37                	jg     8002d1 <printnum+0x71>
  80029a:	eb 44                	jmp    8002e0 <printnum+0x80>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80029c:	83 ec 0c             	sub    $0xc,%esp
  80029f:	ff 75 18             	pushl  0x18(%ebp)
  8002a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8002a5:	48                   	dec    %eax
  8002a6:	50                   	push   %eax
  8002a7:	ff 75 10             	pushl  0x10(%ebp)
  8002aa:	83 ec 08             	sub    $0x8,%esp
  8002ad:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002b0:	ff 75 e0             	pushl  -0x20(%ebp)
  8002b3:	ff 75 dc             	pushl  -0x24(%ebp)
  8002b6:	ff 75 d8             	pushl  -0x28(%ebp)
  8002b9:	e8 5a 1d 00 00       	call   802018 <__udivdi3>
  8002be:	83 c4 18             	add    $0x18,%esp
  8002c1:	52                   	push   %edx
  8002c2:	50                   	push   %eax
  8002c3:	89 fa                	mov    %edi,%edx
  8002c5:	89 f0                	mov    %esi,%eax
  8002c7:	e8 94 ff ff ff       	call   800260 <printnum>
  8002cc:	83 c4 20             	add    $0x20,%esp
  8002cf:	eb 0f                	jmp    8002e0 <printnum+0x80>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002d1:	83 ec 08             	sub    $0x8,%esp
  8002d4:	57                   	push   %edi
  8002d5:	ff 75 18             	pushl  0x18(%ebp)
  8002d8:	ff d6                	call   *%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002da:	83 c4 10             	add    $0x10,%esp
  8002dd:	4b                   	dec    %ebx
  8002de:	75 f1                	jne    8002d1 <printnum+0x71>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002e0:	83 ec 08             	sub    $0x8,%esp
  8002e3:	57                   	push   %edi
  8002e4:	83 ec 04             	sub    $0x4,%esp
  8002e7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002ea:	ff 75 e0             	pushl  -0x20(%ebp)
  8002ed:	ff 75 dc             	pushl  -0x24(%ebp)
  8002f0:	ff 75 d8             	pushl  -0x28(%ebp)
  8002f3:	e8 30 1e 00 00       	call   802128 <__umoddi3>
  8002f8:	83 c4 14             	add    $0x14,%esp
  8002fb:	0f be 80 07 23 80 00 	movsbl 0x802307(%eax),%eax
  800302:	50                   	push   %eax
  800303:	ff d6                	call   *%esi
}
  800305:	83 c4 10             	add    $0x10,%esp
  800308:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80030b:	5b                   	pop    %ebx
  80030c:	5e                   	pop    %esi
  80030d:	5f                   	pop    %edi
  80030e:	5d                   	pop    %ebp
  80030f:	c3                   	ret    

00800310 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800310:	55                   	push   %ebp
  800311:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800313:	83 fa 01             	cmp    $0x1,%edx
  800316:	7e 0e                	jle    800326 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800318:	8b 10                	mov    (%eax),%edx
  80031a:	8d 4a 08             	lea    0x8(%edx),%ecx
  80031d:	89 08                	mov    %ecx,(%eax)
  80031f:	8b 02                	mov    (%edx),%eax
  800321:	8b 52 04             	mov    0x4(%edx),%edx
  800324:	eb 22                	jmp    800348 <getuint+0x38>
	else if (lflag)
  800326:	85 d2                	test   %edx,%edx
  800328:	74 10                	je     80033a <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80032a:	8b 10                	mov    (%eax),%edx
  80032c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80032f:	89 08                	mov    %ecx,(%eax)
  800331:	8b 02                	mov    (%edx),%eax
  800333:	ba 00 00 00 00       	mov    $0x0,%edx
  800338:	eb 0e                	jmp    800348 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80033a:	8b 10                	mov    (%eax),%edx
  80033c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80033f:	89 08                	mov    %ecx,(%eax)
  800341:	8b 02                	mov    (%edx),%eax
  800343:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800348:	5d                   	pop    %ebp
  800349:	c3                   	ret    

0080034a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80034a:	55                   	push   %ebp
  80034b:	89 e5                	mov    %esp,%ebp
  80034d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800350:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800353:	8b 10                	mov    (%eax),%edx
  800355:	3b 50 04             	cmp    0x4(%eax),%edx
  800358:	73 0a                	jae    800364 <sprintputch+0x1a>
		*b->buf++ = ch;
  80035a:	8d 4a 01             	lea    0x1(%edx),%ecx
  80035d:	89 08                	mov    %ecx,(%eax)
  80035f:	8b 45 08             	mov    0x8(%ebp),%eax
  800362:	88 02                	mov    %al,(%edx)
}
  800364:	5d                   	pop    %ebp
  800365:	c3                   	ret    

00800366 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800366:	55                   	push   %ebp
  800367:	89 e5                	mov    %esp,%ebp
  800369:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80036c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80036f:	50                   	push   %eax
  800370:	ff 75 10             	pushl  0x10(%ebp)
  800373:	ff 75 0c             	pushl  0xc(%ebp)
  800376:	ff 75 08             	pushl  0x8(%ebp)
  800379:	e8 05 00 00 00       	call   800383 <vprintfmt>
	va_end(ap);
}
  80037e:	83 c4 10             	add    $0x10,%esp
  800381:	c9                   	leave  
  800382:	c3                   	ret    

00800383 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800383:	55                   	push   %ebp
  800384:	89 e5                	mov    %esp,%ebp
  800386:	57                   	push   %edi
  800387:	56                   	push   %esi
  800388:	53                   	push   %ebx
  800389:	83 ec 2c             	sub    $0x2c,%esp
  80038c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80038f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800392:	eb 03                	jmp    800397 <vprintfmt+0x14>
			break;

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
			for (fmt--; fmt[-1] != '%'; fmt--)
  800394:	89 75 10             	mov    %esi,0x10(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {    //遍历输入的第一个参数，即输出信息的格式，先把格式字符串中'%'之前的字符一个个输出，因为它们前面没有'%'，所以它们就是要直接显示在屏幕上的
  800397:	8b 45 10             	mov    0x10(%ebp),%eax
  80039a:	8d 70 01             	lea    0x1(%eax),%esi
  80039d:	0f b6 00             	movzbl (%eax),%eax
  8003a0:	83 f8 25             	cmp    $0x25,%eax
  8003a3:	74 25                	je     8003ca <vprintfmt+0x47>
			if (ch == '\0')									//当然中间如果遇到'\0'，代表这个字符串的访问结束
  8003a5:	85 c0                	test   %eax,%eax
  8003a7:	75 0d                	jne    8003b6 <vprintfmt+0x33>
  8003a9:	e9 b5 03 00 00       	jmp    800763 <vprintfmt+0x3e0>
  8003ae:	85 c0                	test   %eax,%eax
  8003b0:	0f 84 ad 03 00 00    	je     800763 <vprintfmt+0x3e0>
				return;
			putch(ch, putdat);								//调用putch函数，把一个字符ch输出到putdat指针所指向的地址中所存放的值对应的地址处
  8003b6:	83 ec 08             	sub    $0x8,%esp
  8003b9:	53                   	push   %ebx
  8003ba:	50                   	push   %eax
  8003bb:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {    //遍历输入的第一个参数，即输出信息的格式，先把格式字符串中'%'之前的字符一个个输出，因为它们前面没有'%'，所以它们就是要直接显示在屏幕上的
  8003bd:	46                   	inc    %esi
  8003be:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  8003c2:	83 c4 10             	add    $0x10,%esp
  8003c5:	83 f8 25             	cmp    $0x25,%eax
  8003c8:	75 e4                	jne    8003ae <vprintfmt+0x2b>
			if (width < 0)									//代表有小数点，但是小数点前面并没有数字，比如'%.6f'这种情况，此时代表整数部分全部显示
				width = 0;			
			goto reswitch;

		case '#':
			altflag = 1;
  8003ca:	c6 45 e3 20          	movb   $0x20,-0x1d(%ebp)
  8003ce:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8003d5:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003dc:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8003e3:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8003ea:	eb 07                	jmp    8003f3 <vprintfmt+0x70>
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  8003ec:	8b 75 10             	mov    0x10(%ebp),%esi

		// flag to pad on the right
		case '-':											//%后面的'-'代表要进行左对齐输出，右边填空格，如果省略代表右对齐
			padc = '-';										//如果有这个字符代表左对齐，则把对齐方式标志位变为'-'
  8003ef:	c6 45 e3 2d          	movb   $0x2d,-0x1d(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  8003f3:	8d 46 01             	lea    0x1(%esi),%eax
  8003f6:	89 45 10             	mov    %eax,0x10(%ebp)
  8003f9:	0f b6 16             	movzbl (%esi),%edx
  8003fc:	8a 06                	mov    (%esi),%al
  8003fe:	83 e8 23             	sub    $0x23,%eax
  800401:	3c 55                	cmp    $0x55,%al
  800403:	0f 87 03 03 00 00    	ja     80070c <vprintfmt+0x389>
  800409:	0f b6 c0             	movzbl %al,%eax
  80040c:	ff 24 85 40 24 80 00 	jmp    *0x802440(,%eax,4)
  800413:	8b 75 10             	mov    0x10(%ebp),%esi
			padc = '-';										//如果有这个字符代表左对齐，则把对齐方式标志位变为'-'
			goto reswitch;									//处理下一个字符

		// flag to pad with 0's instead of spaces
		case '0':											//0--有0表示进行对齐输出时填0,如省略表示填入空格，并且如果为0，则一定是右对齐
			padc = '0';										//对其方式标志位变为0
  800416:	c6 45 e3 30          	movb   $0x30,-0x1d(%ebp)
  80041a:	eb d7                	jmp    8003f3 <vprintfmt+0x70>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {					//把遇到的位数字符串转换为真实的位数，比如输入的'%40'，代表有效位数为40位，下面的循环就是把precesion的值设置为40
				precision = precision * 10 + ch - '0';
  80041c:	8d 42 d0             	lea    -0x30(%edx),%eax
  80041f:	89 c1                	mov    %eax,%ecx
  800421:	89 45 d0             	mov    %eax,-0x30(%ebp)
				ch = *fmt;
  800424:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  800428:	8d 50 d0             	lea    -0x30(%eax),%edx
  80042b:	83 fa 09             	cmp    $0x9,%edx
  80042e:	77 51                	ja     800481 <vprintfmt+0xfe>
  800430:	8b 75 10             	mov    0x10(%ebp),%esi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {					//把遇到的位数字符串转换为真实的位数，比如输入的'%40'，代表有效位数为40位，下面的循环就是把precesion的值设置为40
  800433:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  800434:	8d 14 89             	lea    (%ecx,%ecx,4),%edx
  800437:	01 d2                	add    %edx,%edx
  800439:	8d 4c 10 d0          	lea    -0x30(%eax,%edx,1),%ecx
				ch = *fmt;
  80043d:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800440:	8d 50 d0             	lea    -0x30(%eax),%edx
  800443:	83 fa 09             	cmp    $0x9,%edx
  800446:	76 eb                	jbe    800433 <vprintfmt+0xb0>
  800448:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  80044b:	eb 37                	jmp    800484 <vprintfmt+0x101>
					break;
			}
			goto process_precision;							//跳转到process_precistion子过程

		case '*':											//*--代表有效数字的位数也是由输入参数指定的，比如printf("%*.*f", 10, 2, n)，其中10,2就是用来指定显示的有效数字位数的
			precision = va_arg(ap, int);
  80044d:	8b 45 14             	mov    0x14(%ebp),%eax
  800450:	8d 50 04             	lea    0x4(%eax),%edx
  800453:	89 55 14             	mov    %edx,0x14(%ebp)
  800456:	8b 00                	mov    (%eax),%eax
  800458:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  80045b:	8b 75 10             	mov    0x10(%ebp),%esi
			}
			goto process_precision;							//跳转到process_precistion子过程

		case '*':											//*--代表有效数字的位数也是由输入参数指定的，比如printf("%*.*f", 10, 2, n)，其中10,2就是用来指定显示的有效数字位数的
			precision = va_arg(ap, int);
			goto process_precision;
  80045e:	eb 24                	jmp    800484 <vprintfmt+0x101>
  800460:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800464:	79 07                	jns    80046d <vprintfmt+0xea>
  800466:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  80046d:	8b 75 10             	mov    0x10(%ebp),%esi
  800470:	eb 81                	jmp    8003f3 <vprintfmt+0x70>
  800472:	8b 75 10             	mov    0x10(%ebp),%esi
			if (width < 0)									//代表有小数点，但是小数点前面并没有数字，比如'%.6f'这种情况，此时代表整数部分全部显示
				width = 0;			
			goto reswitch;

		case '#':
			altflag = 1;
  800475:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80047c:	e9 72 ff ff ff       	jmp    8003f3 <vprintfmt+0x70>
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  800481:	8b 75 10             	mov    0x10(%ebp),%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:									//处理输出精度，把width字段赋值为刚刚计算出来的precision值，所以width应该是整数部分的有效数字位数
			if (width < 0)
  800484:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800488:	0f 89 65 ff ff ff    	jns    8003f3 <vprintfmt+0x70>
				width = precision, precision = -1;
  80048e:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800491:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800494:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80049b:	e9 53 ff ff ff       	jmp    8003f3 <vprintfmt+0x70>
			goto reswitch;

		// long flag (doubled for long long)				
		case 'l':											//如果遇到'l'，代表应该是输入long类型，如果有两个'l'代表long long
			lflag++;										//此时把lflag++
  8004a0:	ff 45 d4             	incl   -0x2c(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  8004a3:	8b 75 10             	mov    0x10(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)				
		case 'l':											//如果遇到'l'，代表应该是输入long类型，如果有两个'l'代表long long
			lflag++;										//此时把lflag++
			goto reswitch;
  8004a6:	e9 48 ff ff ff       	jmp    8003f3 <vprintfmt+0x70>

		// character
		case 'c':											//如果是'c'代表显示一个字符
			putch(va_arg(ap, int), putdat);					//调用输出一个字符到内存的函数putch
  8004ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ae:	8d 50 04             	lea    0x4(%eax),%edx
  8004b1:	89 55 14             	mov    %edx,0x14(%ebp)
  8004b4:	83 ec 08             	sub    $0x8,%esp
  8004b7:	53                   	push   %ebx
  8004b8:	ff 30                	pushl  (%eax)
  8004ba:	ff d7                	call   *%edi
			break;
  8004bc:	83 c4 10             	add    $0x10,%esp
  8004bf:	e9 d3 fe ff ff       	jmp    800397 <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c7:	8d 50 04             	lea    0x4(%eax),%edx
  8004ca:	89 55 14             	mov    %edx,0x14(%ebp)
  8004cd:	8b 00                	mov    (%eax),%eax
  8004cf:	85 c0                	test   %eax,%eax
  8004d1:	79 02                	jns    8004d5 <vprintfmt+0x152>
  8004d3:	f7 d8                	neg    %eax
  8004d5:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004d7:	83 f8 0f             	cmp    $0xf,%eax
  8004da:	7f 0b                	jg     8004e7 <vprintfmt+0x164>
  8004dc:	8b 04 85 a0 25 80 00 	mov    0x8025a0(,%eax,4),%eax
  8004e3:	85 c0                	test   %eax,%eax
  8004e5:	75 15                	jne    8004fc <vprintfmt+0x179>
				printfmt(putch, putdat, "error %d", err);
  8004e7:	52                   	push   %edx
  8004e8:	68 1f 23 80 00       	push   $0x80231f
  8004ed:	53                   	push   %ebx
  8004ee:	57                   	push   %edi
  8004ef:	e8 72 fe ff ff       	call   800366 <printfmt>
  8004f4:	83 c4 10             	add    $0x10,%esp
  8004f7:	e9 9b fe ff ff       	jmp    800397 <vprintfmt+0x14>
			else
				printfmt(putch, putdat, "%s", p);
  8004fc:	50                   	push   %eax
  8004fd:	68 aa 27 80 00       	push   $0x8027aa
  800502:	53                   	push   %ebx
  800503:	57                   	push   %edi
  800504:	e8 5d fe ff ff       	call   800366 <printfmt>
  800509:	83 c4 10             	add    $0x10,%esp
  80050c:	e9 86 fe ff ff       	jmp    800397 <vprintfmt+0x14>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800511:	8b 45 14             	mov    0x14(%ebp),%eax
  800514:	8d 50 04             	lea    0x4(%eax),%edx
  800517:	89 55 14             	mov    %edx,0x14(%ebp)
  80051a:	8b 00                	mov    (%eax),%eax
  80051c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80051f:	85 c0                	test   %eax,%eax
  800521:	75 07                	jne    80052a <vprintfmt+0x1a7>
				p = "(null)";
  800523:	c7 45 d4 18 23 80 00 	movl   $0x802318,-0x2c(%ebp)
			if (width > 0 && padc != '-')
  80052a:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80052d:	85 f6                	test   %esi,%esi
  80052f:	0f 8e fb 01 00 00    	jle    800730 <vprintfmt+0x3ad>
  800535:	80 7d e3 2d          	cmpb   $0x2d,-0x1d(%ebp)
  800539:	0f 84 09 02 00 00    	je     800748 <vprintfmt+0x3c5>
				for (width -= strnlen(p, precision); width > 0; width--)
  80053f:	83 ec 08             	sub    $0x8,%esp
  800542:	ff 75 d0             	pushl  -0x30(%ebp)
  800545:	ff 75 d4             	pushl  -0x2c(%ebp)
  800548:	e8 ad 02 00 00       	call   8007fa <strnlen>
  80054d:	89 f1                	mov    %esi,%ecx
  80054f:	29 c1                	sub    %eax,%ecx
  800551:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  800554:	83 c4 10             	add    $0x10,%esp
  800557:	85 c9                	test   %ecx,%ecx
  800559:	0f 8e d1 01 00 00    	jle    800730 <vprintfmt+0x3ad>
					putch(padc, putdat);
  80055f:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  800563:	83 ec 08             	sub    $0x8,%esp
  800566:	53                   	push   %ebx
  800567:	56                   	push   %esi
  800568:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80056a:	83 c4 10             	add    $0x10,%esp
  80056d:	ff 4d e4             	decl   -0x1c(%ebp)
  800570:	75 f1                	jne    800563 <vprintfmt+0x1e0>
  800572:	e9 b9 01 00 00       	jmp    800730 <vprintfmt+0x3ad>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800577:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80057b:	74 19                	je     800596 <vprintfmt+0x213>
  80057d:	0f be c0             	movsbl %al,%eax
  800580:	83 e8 20             	sub    $0x20,%eax
  800583:	83 f8 5e             	cmp    $0x5e,%eax
  800586:	76 0e                	jbe    800596 <vprintfmt+0x213>
					putch('?', putdat);
  800588:	83 ec 08             	sub    $0x8,%esp
  80058b:	53                   	push   %ebx
  80058c:	6a 3f                	push   $0x3f
  80058e:	ff 55 08             	call   *0x8(%ebp)
  800591:	83 c4 10             	add    $0x10,%esp
  800594:	eb 0b                	jmp    8005a1 <vprintfmt+0x21e>
				else
					putch(ch, putdat);
  800596:	83 ec 08             	sub    $0x8,%esp
  800599:	53                   	push   %ebx
  80059a:	52                   	push   %edx
  80059b:	ff 55 08             	call   *0x8(%ebp)
  80059e:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005a1:	ff 4d e4             	decl   -0x1c(%ebp)
  8005a4:	46                   	inc    %esi
  8005a5:	8a 46 ff             	mov    -0x1(%esi),%al
  8005a8:	0f be d0             	movsbl %al,%edx
  8005ab:	85 d2                	test   %edx,%edx
  8005ad:	75 1c                	jne    8005cb <vprintfmt+0x248>
  8005af:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005b2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005b6:	7f 1f                	jg     8005d7 <vprintfmt+0x254>
  8005b8:	e9 da fd ff ff       	jmp    800397 <vprintfmt+0x14>
  8005bd:	89 7d 08             	mov    %edi,0x8(%ebp)
  8005c0:	8b 7d d0             	mov    -0x30(%ebp),%edi
  8005c3:	eb 06                	jmp    8005cb <vprintfmt+0x248>
  8005c5:	89 7d 08             	mov    %edi,0x8(%ebp)
  8005c8:	8b 7d d0             	mov    -0x30(%ebp),%edi
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005cb:	85 ff                	test   %edi,%edi
  8005cd:	78 a8                	js     800577 <vprintfmt+0x1f4>
  8005cf:	4f                   	dec    %edi
  8005d0:	79 a5                	jns    800577 <vprintfmt+0x1f4>
  8005d2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005d5:	eb db                	jmp    8005b2 <vprintfmt+0x22f>
  8005d7:	8b 75 e4             	mov    -0x1c(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005da:	83 ec 08             	sub    $0x8,%esp
  8005dd:	53                   	push   %ebx
  8005de:	6a 20                	push   $0x20
  8005e0:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005e2:	4e                   	dec    %esi
  8005e3:	83 c4 10             	add    $0x10,%esp
  8005e6:	85 f6                	test   %esi,%esi
  8005e8:	7f f0                	jg     8005da <vprintfmt+0x257>
  8005ea:	e9 a8 fd ff ff       	jmp    800397 <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005ef:	83 7d d4 01          	cmpl   $0x1,-0x2c(%ebp)
  8005f3:	7e 16                	jle    80060b <vprintfmt+0x288>
		return va_arg(*ap, long long);
  8005f5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f8:	8d 50 08             	lea    0x8(%eax),%edx
  8005fb:	89 55 14             	mov    %edx,0x14(%ebp)
  8005fe:	8b 50 04             	mov    0x4(%eax),%edx
  800601:	8b 00                	mov    (%eax),%eax
  800603:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800606:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800609:	eb 34                	jmp    80063f <vprintfmt+0x2bc>
	else if (lflag)
  80060b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80060f:	74 18                	je     800629 <vprintfmt+0x2a6>
		return va_arg(*ap, long);
  800611:	8b 45 14             	mov    0x14(%ebp),%eax
  800614:	8d 50 04             	lea    0x4(%eax),%edx
  800617:	89 55 14             	mov    %edx,0x14(%ebp)
  80061a:	8b 30                	mov    (%eax),%esi
  80061c:	89 75 d8             	mov    %esi,-0x28(%ebp)
  80061f:	89 f0                	mov    %esi,%eax
  800621:	c1 f8 1f             	sar    $0x1f,%eax
  800624:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800627:	eb 16                	jmp    80063f <vprintfmt+0x2bc>
	else
		return va_arg(*ap, int);
  800629:	8b 45 14             	mov    0x14(%ebp),%eax
  80062c:	8d 50 04             	lea    0x4(%eax),%edx
  80062f:	89 55 14             	mov    %edx,0x14(%ebp)
  800632:	8b 30                	mov    (%eax),%esi
  800634:	89 75 d8             	mov    %esi,-0x28(%ebp)
  800637:	89 f0                	mov    %esi,%eax
  800639:	c1 f8 1f             	sar    $0x1f,%eax
  80063c:	89 45 dc             	mov    %eax,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80063f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800642:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
  800645:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800649:	0f 89 8a 00 00 00    	jns    8006d9 <vprintfmt+0x356>
				putch('-', putdat);
  80064f:	83 ec 08             	sub    $0x8,%esp
  800652:	53                   	push   %ebx
  800653:	6a 2d                	push   $0x2d
  800655:	ff d7                	call   *%edi
				num = -(long long) num;
  800657:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80065a:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80065d:	f7 d8                	neg    %eax
  80065f:	83 d2 00             	adc    $0x0,%edx
  800662:	f7 da                	neg    %edx
  800664:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800667:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80066c:	eb 70                	jmp    8006de <vprintfmt+0x35b>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80066e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800671:	8d 45 14             	lea    0x14(%ebp),%eax
  800674:	e8 97 fc ff ff       	call   800310 <getuint>
			base = 10;
  800679:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80067e:	eb 5e                	jmp    8006de <vprintfmt+0x35b>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
  800680:	83 ec 08             	sub    $0x8,%esp
  800683:	53                   	push   %ebx
  800684:	6a 30                	push   $0x30
  800686:	ff d7                	call   *%edi
			num = getuint(&ap, lflag);
  800688:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80068b:	8d 45 14             	lea    0x14(%ebp),%eax
  80068e:	e8 7d fc ff ff       	call   800310 <getuint>
			base = 8;
			goto number;
  800693:	83 c4 10             	add    $0x10,%esp
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  800696:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80069b:	eb 41                	jmp    8006de <vprintfmt+0x35b>
		// pointer
		case 'p':
			putch('0', putdat);
  80069d:	83 ec 08             	sub    $0x8,%esp
  8006a0:	53                   	push   %ebx
  8006a1:	6a 30                	push   $0x30
  8006a3:	ff d7                	call   *%edi
			putch('x', putdat);
  8006a5:	83 c4 08             	add    $0x8,%esp
  8006a8:	53                   	push   %ebx
  8006a9:	6a 78                	push   $0x78
  8006ab:	ff d7                	call   *%edi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b0:	8d 50 04             	lea    0x4(%eax),%edx
  8006b3:	89 55 14             	mov    %edx,0x14(%ebp)
			goto number;
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006b6:	8b 00                	mov    (%eax),%eax
  8006b8:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006bd:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006c0:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8006c5:	eb 17                	jmp    8006de <vprintfmt+0x35b>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006c7:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8006ca:	8d 45 14             	lea    0x14(%ebp),%eax
  8006cd:	e8 3e fc ff ff       	call   800310 <getuint>
			base = 16;
  8006d2:	b9 10 00 00 00       	mov    $0x10,%ecx
  8006d7:	eb 05                	jmp    8006de <vprintfmt+0x35b>
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006d9:	b9 0a 00 00 00       	mov    $0xa,%ecx
		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006de:	83 ec 0c             	sub    $0xc,%esp
  8006e1:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  8006e5:	56                   	push   %esi
  8006e6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8006e9:	51                   	push   %ecx
  8006ea:	52                   	push   %edx
  8006eb:	50                   	push   %eax
  8006ec:	89 da                	mov    %ebx,%edx
  8006ee:	89 f8                	mov    %edi,%eax
  8006f0:	e8 6b fb ff ff       	call   800260 <printnum>
			break;
  8006f5:	83 c4 20             	add    $0x20,%esp
  8006f8:	e9 9a fc ff ff       	jmp    800397 <vprintfmt+0x14>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006fd:	83 ec 08             	sub    $0x8,%esp
  800700:	53                   	push   %ebx
  800701:	52                   	push   %edx
  800702:	ff d7                	call   *%edi
			break;
  800704:	83 c4 10             	add    $0x10,%esp
  800707:	e9 8b fc ff ff       	jmp    800397 <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80070c:	83 ec 08             	sub    $0x8,%esp
  80070f:	53                   	push   %ebx
  800710:	6a 25                	push   $0x25
  800712:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800714:	83 c4 10             	add    $0x10,%esp
  800717:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80071b:	0f 84 73 fc ff ff    	je     800394 <vprintfmt+0x11>
  800721:	4e                   	dec    %esi
  800722:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800726:	75 f9                	jne    800721 <vprintfmt+0x39e>
  800728:	89 75 10             	mov    %esi,0x10(%ebp)
  80072b:	e9 67 fc ff ff       	jmp    800397 <vprintfmt+0x14>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800730:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800733:	8d 70 01             	lea    0x1(%eax),%esi
  800736:	8a 00                	mov    (%eax),%al
  800738:	0f be d0             	movsbl %al,%edx
  80073b:	85 d2                	test   %edx,%edx
  80073d:	0f 85 7a fe ff ff    	jne    8005bd <vprintfmt+0x23a>
  800743:	e9 4f fc ff ff       	jmp    800397 <vprintfmt+0x14>
  800748:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80074b:	8d 70 01             	lea    0x1(%eax),%esi
  80074e:	8a 00                	mov    (%eax),%al
  800750:	0f be d0             	movsbl %al,%edx
  800753:	85 d2                	test   %edx,%edx
  800755:	0f 85 6a fe ff ff    	jne    8005c5 <vprintfmt+0x242>
  80075b:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80075e:	e9 77 fe ff ff       	jmp    8005da <vprintfmt+0x257>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800763:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800766:	5b                   	pop    %ebx
  800767:	5e                   	pop    %esi
  800768:	5f                   	pop    %edi
  800769:	5d                   	pop    %ebp
  80076a:	c3                   	ret    

0080076b <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80076b:	55                   	push   %ebp
  80076c:	89 e5                	mov    %esp,%ebp
  80076e:	83 ec 18             	sub    $0x18,%esp
  800771:	8b 45 08             	mov    0x8(%ebp),%eax
  800774:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800777:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80077a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80077e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800781:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800788:	85 c0                	test   %eax,%eax
  80078a:	74 26                	je     8007b2 <vsnprintf+0x47>
  80078c:	85 d2                	test   %edx,%edx
  80078e:	7e 29                	jle    8007b9 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800790:	ff 75 14             	pushl  0x14(%ebp)
  800793:	ff 75 10             	pushl  0x10(%ebp)
  800796:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800799:	50                   	push   %eax
  80079a:	68 4a 03 80 00       	push   $0x80034a
  80079f:	e8 df fb ff ff       	call   800383 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007a4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007a7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007ad:	83 c4 10             	add    $0x10,%esp
  8007b0:	eb 0c                	jmp    8007be <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007b2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007b7:	eb 05                	jmp    8007be <vsnprintf+0x53>
  8007b9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007be:	c9                   	leave  
  8007bf:	c3                   	ret    

008007c0 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007c0:	55                   	push   %ebp
  8007c1:	89 e5                	mov    %esp,%ebp
  8007c3:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007c6:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007c9:	50                   	push   %eax
  8007ca:	ff 75 10             	pushl  0x10(%ebp)
  8007cd:	ff 75 0c             	pushl  0xc(%ebp)
  8007d0:	ff 75 08             	pushl  0x8(%ebp)
  8007d3:	e8 93 ff ff ff       	call   80076b <vsnprintf>
	va_end(ap);

	return rc;
}
  8007d8:	c9                   	leave  
  8007d9:	c3                   	ret    

008007da <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007da:	55                   	push   %ebp
  8007db:	89 e5                	mov    %esp,%ebp
  8007dd:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007e0:	80 3a 00             	cmpb   $0x0,(%edx)
  8007e3:	74 0e                	je     8007f3 <strlen+0x19>
  8007e5:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8007ea:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007eb:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007ef:	75 f9                	jne    8007ea <strlen+0x10>
  8007f1:	eb 05                	jmp    8007f8 <strlen+0x1e>
  8007f3:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8007f8:	5d                   	pop    %ebp
  8007f9:	c3                   	ret    

008007fa <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007fa:	55                   	push   %ebp
  8007fb:	89 e5                	mov    %esp,%ebp
  8007fd:	53                   	push   %ebx
  8007fe:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800801:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800804:	85 c9                	test   %ecx,%ecx
  800806:	74 1a                	je     800822 <strnlen+0x28>
  800808:	80 3b 00             	cmpb   $0x0,(%ebx)
  80080b:	74 1c                	je     800829 <strnlen+0x2f>
  80080d:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  800812:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800814:	39 ca                	cmp    %ecx,%edx
  800816:	74 16                	je     80082e <strnlen+0x34>
  800818:	42                   	inc    %edx
  800819:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  80081e:	75 f2                	jne    800812 <strnlen+0x18>
  800820:	eb 0c                	jmp    80082e <strnlen+0x34>
  800822:	b8 00 00 00 00       	mov    $0x0,%eax
  800827:	eb 05                	jmp    80082e <strnlen+0x34>
  800829:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  80082e:	5b                   	pop    %ebx
  80082f:	5d                   	pop    %ebp
  800830:	c3                   	ret    

00800831 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800831:	55                   	push   %ebp
  800832:	89 e5                	mov    %esp,%ebp
  800834:	53                   	push   %ebx
  800835:	8b 45 08             	mov    0x8(%ebp),%eax
  800838:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80083b:	89 c2                	mov    %eax,%edx
  80083d:	42                   	inc    %edx
  80083e:	41                   	inc    %ecx
  80083f:	8a 59 ff             	mov    -0x1(%ecx),%bl
  800842:	88 5a ff             	mov    %bl,-0x1(%edx)
  800845:	84 db                	test   %bl,%bl
  800847:	75 f4                	jne    80083d <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800849:	5b                   	pop    %ebx
  80084a:	5d                   	pop    %ebp
  80084b:	c3                   	ret    

0080084c <strcat>:

char *
strcat(char *dst, const char *src)
{
  80084c:	55                   	push   %ebp
  80084d:	89 e5                	mov    %esp,%ebp
  80084f:	53                   	push   %ebx
  800850:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800853:	53                   	push   %ebx
  800854:	e8 81 ff ff ff       	call   8007da <strlen>
  800859:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80085c:	ff 75 0c             	pushl  0xc(%ebp)
  80085f:	01 d8                	add    %ebx,%eax
  800861:	50                   	push   %eax
  800862:	e8 ca ff ff ff       	call   800831 <strcpy>
	return dst;
}
  800867:	89 d8                	mov    %ebx,%eax
  800869:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80086c:	c9                   	leave  
  80086d:	c3                   	ret    

0080086e <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80086e:	55                   	push   %ebp
  80086f:	89 e5                	mov    %esp,%ebp
  800871:	56                   	push   %esi
  800872:	53                   	push   %ebx
  800873:	8b 75 08             	mov    0x8(%ebp),%esi
  800876:	8b 55 0c             	mov    0xc(%ebp),%edx
  800879:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80087c:	85 db                	test   %ebx,%ebx
  80087e:	74 14                	je     800894 <strncpy+0x26>
  800880:	01 f3                	add    %esi,%ebx
  800882:	89 f1                	mov    %esi,%ecx
		*dst++ = *src;
  800884:	41                   	inc    %ecx
  800885:	8a 02                	mov    (%edx),%al
  800887:	88 41 ff             	mov    %al,-0x1(%ecx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80088a:	80 3a 01             	cmpb   $0x1,(%edx)
  80088d:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800890:	39 cb                	cmp    %ecx,%ebx
  800892:	75 f0                	jne    800884 <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800894:	89 f0                	mov    %esi,%eax
  800896:	5b                   	pop    %ebx
  800897:	5e                   	pop    %esi
  800898:	5d                   	pop    %ebp
  800899:	c3                   	ret    

0080089a <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80089a:	55                   	push   %ebp
  80089b:	89 e5                	mov    %esp,%ebp
  80089d:	53                   	push   %ebx
  80089e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8008a1:	8b 45 10             	mov    0x10(%ebp),%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008a4:	85 c0                	test   %eax,%eax
  8008a6:	74 30                	je     8008d8 <strlcpy+0x3e>
		while (--size > 0 && *src != '\0')
  8008a8:	48                   	dec    %eax
  8008a9:	74 20                	je     8008cb <strlcpy+0x31>
  8008ab:	8a 0b                	mov    (%ebx),%cl
  8008ad:	84 c9                	test   %cl,%cl
  8008af:	74 1f                	je     8008d0 <strlcpy+0x36>
  8008b1:	8d 53 01             	lea    0x1(%ebx),%edx
  8008b4:	01 c3                	add    %eax,%ebx
  8008b6:	8b 45 08             	mov    0x8(%ebp),%eax
			*dst++ = *src++;
  8008b9:	40                   	inc    %eax
  8008ba:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008bd:	39 da                	cmp    %ebx,%edx
  8008bf:	74 12                	je     8008d3 <strlcpy+0x39>
  8008c1:	42                   	inc    %edx
  8008c2:	8a 4a ff             	mov    -0x1(%edx),%cl
  8008c5:	84 c9                	test   %cl,%cl
  8008c7:	75 f0                	jne    8008b9 <strlcpy+0x1f>
  8008c9:	eb 08                	jmp    8008d3 <strlcpy+0x39>
  8008cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ce:	eb 03                	jmp    8008d3 <strlcpy+0x39>
  8008d0:	8b 45 08             	mov    0x8(%ebp),%eax
			*dst++ = *src++;
		*dst = '\0';
  8008d3:	c6 00 00             	movb   $0x0,(%eax)
  8008d6:	eb 03                	jmp    8008db <strlcpy+0x41>
  8008d8:	8b 45 08             	mov    0x8(%ebp),%eax
	}
	return dst - dst_in;
  8008db:	2b 45 08             	sub    0x8(%ebp),%eax
}
  8008de:	5b                   	pop    %ebx
  8008df:	5d                   	pop    %ebp
  8008e0:	c3                   	ret    

008008e1 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008e1:	55                   	push   %ebp
  8008e2:	89 e5                	mov    %esp,%ebp
  8008e4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008e7:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008ea:	8a 01                	mov    (%ecx),%al
  8008ec:	84 c0                	test   %al,%al
  8008ee:	74 10                	je     800900 <strcmp+0x1f>
  8008f0:	3a 02                	cmp    (%edx),%al
  8008f2:	75 0c                	jne    800900 <strcmp+0x1f>
		p++, q++;
  8008f4:	41                   	inc    %ecx
  8008f5:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008f6:	8a 01                	mov    (%ecx),%al
  8008f8:	84 c0                	test   %al,%al
  8008fa:	74 04                	je     800900 <strcmp+0x1f>
  8008fc:	3a 02                	cmp    (%edx),%al
  8008fe:	74 f4                	je     8008f4 <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800900:	0f b6 c0             	movzbl %al,%eax
  800903:	0f b6 12             	movzbl (%edx),%edx
  800906:	29 d0                	sub    %edx,%eax
}
  800908:	5d                   	pop    %ebp
  800909:	c3                   	ret    

0080090a <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80090a:	55                   	push   %ebp
  80090b:	89 e5                	mov    %esp,%ebp
  80090d:	56                   	push   %esi
  80090e:	53                   	push   %ebx
  80090f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800912:	8b 55 0c             	mov    0xc(%ebp),%edx
  800915:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  800918:	85 f6                	test   %esi,%esi
  80091a:	74 23                	je     80093f <strncmp+0x35>
  80091c:	8a 03                	mov    (%ebx),%al
  80091e:	84 c0                	test   %al,%al
  800920:	74 2b                	je     80094d <strncmp+0x43>
  800922:	3a 02                	cmp    (%edx),%al
  800924:	75 27                	jne    80094d <strncmp+0x43>
  800926:	8d 43 01             	lea    0x1(%ebx),%eax
  800929:	01 de                	add    %ebx,%esi
		n--, p++, q++;
  80092b:	89 c3                	mov    %eax,%ebx
  80092d:	42                   	inc    %edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80092e:	39 c6                	cmp    %eax,%esi
  800930:	74 14                	je     800946 <strncmp+0x3c>
  800932:	8a 08                	mov    (%eax),%cl
  800934:	84 c9                	test   %cl,%cl
  800936:	74 15                	je     80094d <strncmp+0x43>
  800938:	40                   	inc    %eax
  800939:	3a 0a                	cmp    (%edx),%cl
  80093b:	74 ee                	je     80092b <strncmp+0x21>
  80093d:	eb 0e                	jmp    80094d <strncmp+0x43>
		n--, p++, q++;
	if (n == 0)
		return 0;
  80093f:	b8 00 00 00 00       	mov    $0x0,%eax
  800944:	eb 0f                	jmp    800955 <strncmp+0x4b>
  800946:	b8 00 00 00 00       	mov    $0x0,%eax
  80094b:	eb 08                	jmp    800955 <strncmp+0x4b>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80094d:	0f b6 03             	movzbl (%ebx),%eax
  800950:	0f b6 12             	movzbl (%edx),%edx
  800953:	29 d0                	sub    %edx,%eax
}
  800955:	5b                   	pop    %ebx
  800956:	5e                   	pop    %esi
  800957:	5d                   	pop    %ebp
  800958:	c3                   	ret    

00800959 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800959:	55                   	push   %ebp
  80095a:	89 e5                	mov    %esp,%ebp
  80095c:	53                   	push   %ebx
  80095d:	8b 45 08             	mov    0x8(%ebp),%eax
  800960:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  800963:	8a 10                	mov    (%eax),%dl
  800965:	84 d2                	test   %dl,%dl
  800967:	74 1a                	je     800983 <strchr+0x2a>
  800969:	88 d9                	mov    %bl,%cl
		if (*s == c)
  80096b:	38 d3                	cmp    %dl,%bl
  80096d:	75 06                	jne    800975 <strchr+0x1c>
  80096f:	eb 17                	jmp    800988 <strchr+0x2f>
  800971:	38 ca                	cmp    %cl,%dl
  800973:	74 13                	je     800988 <strchr+0x2f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800975:	40                   	inc    %eax
  800976:	8a 10                	mov    (%eax),%dl
  800978:	84 d2                	test   %dl,%dl
  80097a:	75 f5                	jne    800971 <strchr+0x18>
		if (*s == c)
			return (char *) s;
	return 0;
  80097c:	b8 00 00 00 00       	mov    $0x0,%eax
  800981:	eb 05                	jmp    800988 <strchr+0x2f>
  800983:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800988:	5b                   	pop    %ebx
  800989:	5d                   	pop    %ebp
  80098a:	c3                   	ret    

0080098b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80098b:	55                   	push   %ebp
  80098c:	89 e5                	mov    %esp,%ebp
  80098e:	53                   	push   %ebx
  80098f:	8b 45 08             	mov    0x8(%ebp),%eax
  800992:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  800995:	8a 10                	mov    (%eax),%dl
  800997:	84 d2                	test   %dl,%dl
  800999:	74 13                	je     8009ae <strfind+0x23>
  80099b:	88 d9                	mov    %bl,%cl
		if (*s == c)
  80099d:	38 d3                	cmp    %dl,%bl
  80099f:	75 06                	jne    8009a7 <strfind+0x1c>
  8009a1:	eb 0b                	jmp    8009ae <strfind+0x23>
  8009a3:	38 ca                	cmp    %cl,%dl
  8009a5:	74 07                	je     8009ae <strfind+0x23>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8009a7:	40                   	inc    %eax
  8009a8:	8a 10                	mov    (%eax),%dl
  8009aa:	84 d2                	test   %dl,%dl
  8009ac:	75 f5                	jne    8009a3 <strfind+0x18>
		if (*s == c)
			break;
	return (char *) s;
}
  8009ae:	5b                   	pop    %ebx
  8009af:	5d                   	pop    %ebp
  8009b0:	c3                   	ret    

008009b1 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009b1:	55                   	push   %ebp
  8009b2:	89 e5                	mov    %esp,%ebp
  8009b4:	57                   	push   %edi
  8009b5:	56                   	push   %esi
  8009b6:	53                   	push   %ebx
  8009b7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009ba:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009bd:	85 c9                	test   %ecx,%ecx
  8009bf:	74 36                	je     8009f7 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009c1:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009c7:	75 28                	jne    8009f1 <memset+0x40>
  8009c9:	f6 c1 03             	test   $0x3,%cl
  8009cc:	75 23                	jne    8009f1 <memset+0x40>
		c &= 0xFF;
  8009ce:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009d2:	89 d3                	mov    %edx,%ebx
  8009d4:	c1 e3 08             	shl    $0x8,%ebx
  8009d7:	89 d6                	mov    %edx,%esi
  8009d9:	c1 e6 18             	shl    $0x18,%esi
  8009dc:	89 d0                	mov    %edx,%eax
  8009de:	c1 e0 10             	shl    $0x10,%eax
  8009e1:	09 f0                	or     %esi,%eax
  8009e3:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8009e5:	89 d8                	mov    %ebx,%eax
  8009e7:	09 d0                	or     %edx,%eax
  8009e9:	c1 e9 02             	shr    $0x2,%ecx
  8009ec:	fc                   	cld    
  8009ed:	f3 ab                	rep stos %eax,%es:(%edi)
  8009ef:	eb 06                	jmp    8009f7 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009f1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009f4:	fc                   	cld    
  8009f5:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009f7:	89 f8                	mov    %edi,%eax
  8009f9:	5b                   	pop    %ebx
  8009fa:	5e                   	pop    %esi
  8009fb:	5f                   	pop    %edi
  8009fc:	5d                   	pop    %ebp
  8009fd:	c3                   	ret    

008009fe <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009fe:	55                   	push   %ebp
  8009ff:	89 e5                	mov    %esp,%ebp
  800a01:	57                   	push   %edi
  800a02:	56                   	push   %esi
  800a03:	8b 45 08             	mov    0x8(%ebp),%eax
  800a06:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a09:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a0c:	39 c6                	cmp    %eax,%esi
  800a0e:	73 33                	jae    800a43 <memmove+0x45>
  800a10:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a13:	39 d0                	cmp    %edx,%eax
  800a15:	73 2c                	jae    800a43 <memmove+0x45>
		s += n;
		d += n;
  800a17:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a1a:	89 d6                	mov    %edx,%esi
  800a1c:	09 fe                	or     %edi,%esi
  800a1e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a24:	75 13                	jne    800a39 <memmove+0x3b>
  800a26:	f6 c1 03             	test   $0x3,%cl
  800a29:	75 0e                	jne    800a39 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800a2b:	83 ef 04             	sub    $0x4,%edi
  800a2e:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a31:	c1 e9 02             	shr    $0x2,%ecx
  800a34:	fd                   	std    
  800a35:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a37:	eb 07                	jmp    800a40 <memmove+0x42>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a39:	4f                   	dec    %edi
  800a3a:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a3d:	fd                   	std    
  800a3e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a40:	fc                   	cld    
  800a41:	eb 1d                	jmp    800a60 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a43:	89 f2                	mov    %esi,%edx
  800a45:	09 c2                	or     %eax,%edx
  800a47:	f6 c2 03             	test   $0x3,%dl
  800a4a:	75 0f                	jne    800a5b <memmove+0x5d>
  800a4c:	f6 c1 03             	test   $0x3,%cl
  800a4f:	75 0a                	jne    800a5b <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
  800a51:	c1 e9 02             	shr    $0x2,%ecx
  800a54:	89 c7                	mov    %eax,%edi
  800a56:	fc                   	cld    
  800a57:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a59:	eb 05                	jmp    800a60 <memmove+0x62>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a5b:	89 c7                	mov    %eax,%edi
  800a5d:	fc                   	cld    
  800a5e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a60:	5e                   	pop    %esi
  800a61:	5f                   	pop    %edi
  800a62:	5d                   	pop    %ebp
  800a63:	c3                   	ret    

00800a64 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a64:	55                   	push   %ebp
  800a65:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a67:	ff 75 10             	pushl  0x10(%ebp)
  800a6a:	ff 75 0c             	pushl  0xc(%ebp)
  800a6d:	ff 75 08             	pushl  0x8(%ebp)
  800a70:	e8 89 ff ff ff       	call   8009fe <memmove>
}
  800a75:	c9                   	leave  
  800a76:	c3                   	ret    

00800a77 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a77:	55                   	push   %ebp
  800a78:	89 e5                	mov    %esp,%ebp
  800a7a:	57                   	push   %edi
  800a7b:	56                   	push   %esi
  800a7c:	53                   	push   %ebx
  800a7d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800a80:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a83:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a86:	85 c0                	test   %eax,%eax
  800a88:	74 33                	je     800abd <memcmp+0x46>
  800a8a:	8d 78 ff             	lea    -0x1(%eax),%edi
		if (*s1 != *s2)
  800a8d:	8a 13                	mov    (%ebx),%dl
  800a8f:	8a 0e                	mov    (%esi),%cl
  800a91:	38 ca                	cmp    %cl,%dl
  800a93:	75 13                	jne    800aa8 <memcmp+0x31>
  800a95:	b8 00 00 00 00       	mov    $0x0,%eax
  800a9a:	eb 16                	jmp    800ab2 <memcmp+0x3b>
  800a9c:	8a 54 03 01          	mov    0x1(%ebx,%eax,1),%dl
  800aa0:	40                   	inc    %eax
  800aa1:	8a 0c 06             	mov    (%esi,%eax,1),%cl
  800aa4:	38 ca                	cmp    %cl,%dl
  800aa6:	74 0a                	je     800ab2 <memcmp+0x3b>
			return (int) *s1 - (int) *s2;
  800aa8:	0f b6 c2             	movzbl %dl,%eax
  800aab:	0f b6 c9             	movzbl %cl,%ecx
  800aae:	29 c8                	sub    %ecx,%eax
  800ab0:	eb 10                	jmp    800ac2 <memcmp+0x4b>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ab2:	39 f8                	cmp    %edi,%eax
  800ab4:	75 e6                	jne    800a9c <memcmp+0x25>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800ab6:	b8 00 00 00 00       	mov    $0x0,%eax
  800abb:	eb 05                	jmp    800ac2 <memcmp+0x4b>
  800abd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ac2:	5b                   	pop    %ebx
  800ac3:	5e                   	pop    %esi
  800ac4:	5f                   	pop    %edi
  800ac5:	5d                   	pop    %ebp
  800ac6:	c3                   	ret    

00800ac7 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ac7:	55                   	push   %ebp
  800ac8:	89 e5                	mov    %esp,%ebp
  800aca:	53                   	push   %ebx
  800acb:	8b 55 08             	mov    0x8(%ebp),%edx
	const void *ends = (const char *) s + n;
  800ace:	89 d0                	mov    %edx,%eax
  800ad0:	03 45 10             	add    0x10(%ebp),%eax
	for (; s < ends; s++)
  800ad3:	39 c2                	cmp    %eax,%edx
  800ad5:	73 1b                	jae    800af2 <memfind+0x2b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ad7:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
  800adb:	0f b6 0a             	movzbl (%edx),%ecx
  800ade:	39 d9                	cmp    %ebx,%ecx
  800ae0:	75 09                	jne    800aeb <memfind+0x24>
  800ae2:	eb 12                	jmp    800af6 <memfind+0x2f>
  800ae4:	0f b6 0a             	movzbl (%edx),%ecx
  800ae7:	39 d9                	cmp    %ebx,%ecx
  800ae9:	74 0f                	je     800afa <memfind+0x33>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800aeb:	42                   	inc    %edx
  800aec:	39 d0                	cmp    %edx,%eax
  800aee:	75 f4                	jne    800ae4 <memfind+0x1d>
  800af0:	eb 0a                	jmp    800afc <memfind+0x35>
  800af2:	89 d0                	mov    %edx,%eax
  800af4:	eb 06                	jmp    800afc <memfind+0x35>
		if (*(const unsigned char *) s == (unsigned char) c)
  800af6:	89 d0                	mov    %edx,%eax
  800af8:	eb 02                	jmp    800afc <memfind+0x35>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800afa:	89 d0                	mov    %edx,%eax
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800afc:	5b                   	pop    %ebx
  800afd:	5d                   	pop    %ebp
  800afe:	c3                   	ret    

00800aff <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800aff:	55                   	push   %ebp
  800b00:	89 e5                	mov    %esp,%ebp
  800b02:	57                   	push   %edi
  800b03:	56                   	push   %esi
  800b04:	53                   	push   %ebx
  800b05:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b08:	eb 01                	jmp    800b0b <strtol+0xc>
		s++;
  800b0a:	41                   	inc    %ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b0b:	8a 01                	mov    (%ecx),%al
  800b0d:	3c 20                	cmp    $0x20,%al
  800b0f:	74 f9                	je     800b0a <strtol+0xb>
  800b11:	3c 09                	cmp    $0x9,%al
  800b13:	74 f5                	je     800b0a <strtol+0xb>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b15:	3c 2b                	cmp    $0x2b,%al
  800b17:	75 08                	jne    800b21 <strtol+0x22>
		s++;
  800b19:	41                   	inc    %ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b1a:	bf 00 00 00 00       	mov    $0x0,%edi
  800b1f:	eb 11                	jmp    800b32 <strtol+0x33>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b21:	3c 2d                	cmp    $0x2d,%al
  800b23:	75 08                	jne    800b2d <strtol+0x2e>
		s++, neg = 1;
  800b25:	41                   	inc    %ecx
  800b26:	bf 01 00 00 00       	mov    $0x1,%edi
  800b2b:	eb 05                	jmp    800b32 <strtol+0x33>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b2d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b32:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800b36:	0f 84 87 00 00 00    	je     800bc3 <strtol+0xc4>
  800b3c:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  800b40:	75 27                	jne    800b69 <strtol+0x6a>
  800b42:	80 39 30             	cmpb   $0x30,(%ecx)
  800b45:	75 22                	jne    800b69 <strtol+0x6a>
  800b47:	e9 88 00 00 00       	jmp    800bd4 <strtol+0xd5>
		s += 2, base = 16;
  800b4c:	83 c1 02             	add    $0x2,%ecx
  800b4f:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  800b56:	eb 11                	jmp    800b69 <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
  800b58:	41                   	inc    %ecx
  800b59:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  800b60:	eb 07                	jmp    800b69 <strtol+0x6a>
	else if (base == 0)
		base = 10;
  800b62:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)
  800b69:	b8 00 00 00 00       	mov    $0x0,%eax

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b6e:	8a 11                	mov    (%ecx),%dl
  800b70:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800b73:	80 fb 09             	cmp    $0x9,%bl
  800b76:	77 08                	ja     800b80 <strtol+0x81>
			dig = *s - '0';
  800b78:	0f be d2             	movsbl %dl,%edx
  800b7b:	83 ea 30             	sub    $0x30,%edx
  800b7e:	eb 22                	jmp    800ba2 <strtol+0xa3>
		else if (*s >= 'a' && *s <= 'z')
  800b80:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b83:	89 f3                	mov    %esi,%ebx
  800b85:	80 fb 19             	cmp    $0x19,%bl
  800b88:	77 08                	ja     800b92 <strtol+0x93>
			dig = *s - 'a' + 10;
  800b8a:	0f be d2             	movsbl %dl,%edx
  800b8d:	83 ea 57             	sub    $0x57,%edx
  800b90:	eb 10                	jmp    800ba2 <strtol+0xa3>
		else if (*s >= 'A' && *s <= 'Z')
  800b92:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b95:	89 f3                	mov    %esi,%ebx
  800b97:	80 fb 19             	cmp    $0x19,%bl
  800b9a:	77 14                	ja     800bb0 <strtol+0xb1>
			dig = *s - 'A' + 10;
  800b9c:	0f be d2             	movsbl %dl,%edx
  800b9f:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800ba2:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ba5:	7d 09                	jge    800bb0 <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800ba7:	41                   	inc    %ecx
  800ba8:	0f af 45 10          	imul   0x10(%ebp),%eax
  800bac:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800bae:	eb be                	jmp    800b6e <strtol+0x6f>

	if (endptr)
  800bb0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bb4:	74 05                	je     800bbb <strtol+0xbc>
		*endptr = (char *) s;
  800bb6:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bb9:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800bbb:	85 ff                	test   %edi,%edi
  800bbd:	74 21                	je     800be0 <strtol+0xe1>
  800bbf:	f7 d8                	neg    %eax
  800bc1:	eb 1d                	jmp    800be0 <strtol+0xe1>
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bc3:	80 39 30             	cmpb   $0x30,(%ecx)
  800bc6:	75 9a                	jne    800b62 <strtol+0x63>
  800bc8:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800bcc:	0f 84 7a ff ff ff    	je     800b4c <strtol+0x4d>
  800bd2:	eb 84                	jmp    800b58 <strtol+0x59>
  800bd4:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800bd8:	0f 84 6e ff ff ff    	je     800b4c <strtol+0x4d>
  800bde:	eb 89                	jmp    800b69 <strtol+0x6a>
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
}
  800be0:	5b                   	pop    %ebx
  800be1:	5e                   	pop    %esi
  800be2:	5f                   	pop    %edi
  800be3:	5d                   	pop    %ebp
  800be4:	c3                   	ret    

00800be5 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800be5:	55                   	push   %ebp
  800be6:	89 e5                	mov    %esp,%ebp
  800be8:	57                   	push   %edi
  800be9:	56                   	push   %esi
  800bea:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800beb:	b8 00 00 00 00       	mov    $0x0,%eax
  800bf0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bf3:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf6:	89 c3                	mov    %eax,%ebx
  800bf8:	89 c7                	mov    %eax,%edi
  800bfa:	89 c6                	mov    %eax,%esi
  800bfc:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bfe:	5b                   	pop    %ebx
  800bff:	5e                   	pop    %esi
  800c00:	5f                   	pop    %edi
  800c01:	5d                   	pop    %ebp
  800c02:	c3                   	ret    

00800c03 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c03:	55                   	push   %ebp
  800c04:	89 e5                	mov    %esp,%ebp
  800c06:	57                   	push   %edi
  800c07:	56                   	push   %esi
  800c08:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c09:	ba 00 00 00 00       	mov    $0x0,%edx
  800c0e:	b8 01 00 00 00       	mov    $0x1,%eax
  800c13:	89 d1                	mov    %edx,%ecx
  800c15:	89 d3                	mov    %edx,%ebx
  800c17:	89 d7                	mov    %edx,%edi
  800c19:	89 d6                	mov    %edx,%esi
  800c1b:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c1d:	5b                   	pop    %ebx
  800c1e:	5e                   	pop    %esi
  800c1f:	5f                   	pop    %edi
  800c20:	5d                   	pop    %ebp
  800c21:	c3                   	ret    

00800c22 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c22:	55                   	push   %ebp
  800c23:	89 e5                	mov    %esp,%ebp
  800c25:	57                   	push   %edi
  800c26:	56                   	push   %esi
  800c27:	53                   	push   %ebx
  800c28:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c2b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c30:	b8 03 00 00 00       	mov    $0x3,%eax
  800c35:	8b 55 08             	mov    0x8(%ebp),%edx
  800c38:	89 cb                	mov    %ecx,%ebx
  800c3a:	89 cf                	mov    %ecx,%edi
  800c3c:	89 ce                	mov    %ecx,%esi
  800c3e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c40:	85 c0                	test   %eax,%eax
  800c42:	7e 17                	jle    800c5b <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c44:	83 ec 0c             	sub    $0xc,%esp
  800c47:	50                   	push   %eax
  800c48:	6a 03                	push   $0x3
  800c4a:	68 ff 25 80 00       	push   $0x8025ff
  800c4f:	6a 23                	push   $0x23
  800c51:	68 1c 26 80 00       	push   $0x80261c
  800c56:	e8 19 f5 ff ff       	call   800174 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c5b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c5e:	5b                   	pop    %ebx
  800c5f:	5e                   	pop    %esi
  800c60:	5f                   	pop    %edi
  800c61:	5d                   	pop    %ebp
  800c62:	c3                   	ret    

00800c63 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c63:	55                   	push   %ebp
  800c64:	89 e5                	mov    %esp,%ebp
  800c66:	57                   	push   %edi
  800c67:	56                   	push   %esi
  800c68:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c69:	ba 00 00 00 00       	mov    $0x0,%edx
  800c6e:	b8 02 00 00 00       	mov    $0x2,%eax
  800c73:	89 d1                	mov    %edx,%ecx
  800c75:	89 d3                	mov    %edx,%ebx
  800c77:	89 d7                	mov    %edx,%edi
  800c79:	89 d6                	mov    %edx,%esi
  800c7b:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c7d:	5b                   	pop    %ebx
  800c7e:	5e                   	pop    %esi
  800c7f:	5f                   	pop    %edi
  800c80:	5d                   	pop    %ebp
  800c81:	c3                   	ret    

00800c82 <sys_yield>:

void
sys_yield(void)
{
  800c82:	55                   	push   %ebp
  800c83:	89 e5                	mov    %esp,%ebp
  800c85:	57                   	push   %edi
  800c86:	56                   	push   %esi
  800c87:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c88:	ba 00 00 00 00       	mov    $0x0,%edx
  800c8d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c92:	89 d1                	mov    %edx,%ecx
  800c94:	89 d3                	mov    %edx,%ebx
  800c96:	89 d7                	mov    %edx,%edi
  800c98:	89 d6                	mov    %edx,%esi
  800c9a:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c9c:	5b                   	pop    %ebx
  800c9d:	5e                   	pop    %esi
  800c9e:	5f                   	pop    %edi
  800c9f:	5d                   	pop    %ebp
  800ca0:	c3                   	ret    

00800ca1 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ca1:	55                   	push   %ebp
  800ca2:	89 e5                	mov    %esp,%ebp
  800ca4:	57                   	push   %edi
  800ca5:	56                   	push   %esi
  800ca6:	53                   	push   %ebx
  800ca7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800caa:	be 00 00 00 00       	mov    $0x0,%esi
  800caf:	b8 04 00 00 00       	mov    $0x4,%eax
  800cb4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb7:	8b 55 08             	mov    0x8(%ebp),%edx
  800cba:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cbd:	89 f7                	mov    %esi,%edi
  800cbf:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cc1:	85 c0                	test   %eax,%eax
  800cc3:	7e 17                	jle    800cdc <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc5:	83 ec 0c             	sub    $0xc,%esp
  800cc8:	50                   	push   %eax
  800cc9:	6a 04                	push   $0x4
  800ccb:	68 ff 25 80 00       	push   $0x8025ff
  800cd0:	6a 23                	push   $0x23
  800cd2:	68 1c 26 80 00       	push   $0x80261c
  800cd7:	e8 98 f4 ff ff       	call   800174 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800cdc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cdf:	5b                   	pop    %ebx
  800ce0:	5e                   	pop    %esi
  800ce1:	5f                   	pop    %edi
  800ce2:	5d                   	pop    %ebp
  800ce3:	c3                   	ret    

00800ce4 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ce4:	55                   	push   %ebp
  800ce5:	89 e5                	mov    %esp,%ebp
  800ce7:	57                   	push   %edi
  800ce8:	56                   	push   %esi
  800ce9:	53                   	push   %ebx
  800cea:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ced:	b8 05 00 00 00       	mov    $0x5,%eax
  800cf2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf5:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cfb:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cfe:	8b 75 18             	mov    0x18(%ebp),%esi
  800d01:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d03:	85 c0                	test   %eax,%eax
  800d05:	7e 17                	jle    800d1e <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d07:	83 ec 0c             	sub    $0xc,%esp
  800d0a:	50                   	push   %eax
  800d0b:	6a 05                	push   $0x5
  800d0d:	68 ff 25 80 00       	push   $0x8025ff
  800d12:	6a 23                	push   $0x23
  800d14:	68 1c 26 80 00       	push   $0x80261c
  800d19:	e8 56 f4 ff ff       	call   800174 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d1e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d21:	5b                   	pop    %ebx
  800d22:	5e                   	pop    %esi
  800d23:	5f                   	pop    %edi
  800d24:	5d                   	pop    %ebp
  800d25:	c3                   	ret    

00800d26 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d26:	55                   	push   %ebp
  800d27:	89 e5                	mov    %esp,%ebp
  800d29:	57                   	push   %edi
  800d2a:	56                   	push   %esi
  800d2b:	53                   	push   %ebx
  800d2c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d2f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d34:	b8 06 00 00 00       	mov    $0x6,%eax
  800d39:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d3c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d3f:	89 df                	mov    %ebx,%edi
  800d41:	89 de                	mov    %ebx,%esi
  800d43:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d45:	85 c0                	test   %eax,%eax
  800d47:	7e 17                	jle    800d60 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d49:	83 ec 0c             	sub    $0xc,%esp
  800d4c:	50                   	push   %eax
  800d4d:	6a 06                	push   $0x6
  800d4f:	68 ff 25 80 00       	push   $0x8025ff
  800d54:	6a 23                	push   $0x23
  800d56:	68 1c 26 80 00       	push   $0x80261c
  800d5b:	e8 14 f4 ff ff       	call   800174 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d60:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d63:	5b                   	pop    %ebx
  800d64:	5e                   	pop    %esi
  800d65:	5f                   	pop    %edi
  800d66:	5d                   	pop    %ebp
  800d67:	c3                   	ret    

00800d68 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d68:	55                   	push   %ebp
  800d69:	89 e5                	mov    %esp,%ebp
  800d6b:	57                   	push   %edi
  800d6c:	56                   	push   %esi
  800d6d:	53                   	push   %ebx
  800d6e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d71:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d76:	b8 08 00 00 00       	mov    $0x8,%eax
  800d7b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d7e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d81:	89 df                	mov    %ebx,%edi
  800d83:	89 de                	mov    %ebx,%esi
  800d85:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d87:	85 c0                	test   %eax,%eax
  800d89:	7e 17                	jle    800da2 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d8b:	83 ec 0c             	sub    $0xc,%esp
  800d8e:	50                   	push   %eax
  800d8f:	6a 08                	push   $0x8
  800d91:	68 ff 25 80 00       	push   $0x8025ff
  800d96:	6a 23                	push   $0x23
  800d98:	68 1c 26 80 00       	push   $0x80261c
  800d9d:	e8 d2 f3 ff ff       	call   800174 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800da2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800da5:	5b                   	pop    %ebx
  800da6:	5e                   	pop    %esi
  800da7:	5f                   	pop    %edi
  800da8:	5d                   	pop    %ebp
  800da9:	c3                   	ret    

00800daa <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800daa:	55                   	push   %ebp
  800dab:	89 e5                	mov    %esp,%ebp
  800dad:	57                   	push   %edi
  800dae:	56                   	push   %esi
  800daf:	53                   	push   %ebx
  800db0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800db3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800db8:	b8 09 00 00 00       	mov    $0x9,%eax
  800dbd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dc0:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc3:	89 df                	mov    %ebx,%edi
  800dc5:	89 de                	mov    %ebx,%esi
  800dc7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dc9:	85 c0                	test   %eax,%eax
  800dcb:	7e 17                	jle    800de4 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dcd:	83 ec 0c             	sub    $0xc,%esp
  800dd0:	50                   	push   %eax
  800dd1:	6a 09                	push   $0x9
  800dd3:	68 ff 25 80 00       	push   $0x8025ff
  800dd8:	6a 23                	push   $0x23
  800dda:	68 1c 26 80 00       	push   $0x80261c
  800ddf:	e8 90 f3 ff ff       	call   800174 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800de4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800de7:	5b                   	pop    %ebx
  800de8:	5e                   	pop    %esi
  800de9:	5f                   	pop    %edi
  800dea:	5d                   	pop    %ebp
  800deb:	c3                   	ret    

00800dec <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800dec:	55                   	push   %ebp
  800ded:	89 e5                	mov    %esp,%ebp
  800def:	57                   	push   %edi
  800df0:	56                   	push   %esi
  800df1:	53                   	push   %ebx
  800df2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800df5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dfa:	b8 0a 00 00 00       	mov    $0xa,%eax
  800dff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e02:	8b 55 08             	mov    0x8(%ebp),%edx
  800e05:	89 df                	mov    %ebx,%edi
  800e07:	89 de                	mov    %ebx,%esi
  800e09:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e0b:	85 c0                	test   %eax,%eax
  800e0d:	7e 17                	jle    800e26 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e0f:	83 ec 0c             	sub    $0xc,%esp
  800e12:	50                   	push   %eax
  800e13:	6a 0a                	push   $0xa
  800e15:	68 ff 25 80 00       	push   $0x8025ff
  800e1a:	6a 23                	push   $0x23
  800e1c:	68 1c 26 80 00       	push   $0x80261c
  800e21:	e8 4e f3 ff ff       	call   800174 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e26:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e29:	5b                   	pop    %ebx
  800e2a:	5e                   	pop    %esi
  800e2b:	5f                   	pop    %edi
  800e2c:	5d                   	pop    %ebp
  800e2d:	c3                   	ret    

00800e2e <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e2e:	55                   	push   %ebp
  800e2f:	89 e5                	mov    %esp,%ebp
  800e31:	57                   	push   %edi
  800e32:	56                   	push   %esi
  800e33:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e34:	be 00 00 00 00       	mov    $0x0,%esi
  800e39:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e3e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e41:	8b 55 08             	mov    0x8(%ebp),%edx
  800e44:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e47:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e4a:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e4c:	5b                   	pop    %ebx
  800e4d:	5e                   	pop    %esi
  800e4e:	5f                   	pop    %edi
  800e4f:	5d                   	pop    %ebp
  800e50:	c3                   	ret    

00800e51 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e51:	55                   	push   %ebp
  800e52:	89 e5                	mov    %esp,%ebp
  800e54:	57                   	push   %edi
  800e55:	56                   	push   %esi
  800e56:	53                   	push   %ebx
  800e57:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e5a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e5f:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e64:	8b 55 08             	mov    0x8(%ebp),%edx
  800e67:	89 cb                	mov    %ecx,%ebx
  800e69:	89 cf                	mov    %ecx,%edi
  800e6b:	89 ce                	mov    %ecx,%esi
  800e6d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e6f:	85 c0                	test   %eax,%eax
  800e71:	7e 17                	jle    800e8a <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e73:	83 ec 0c             	sub    $0xc,%esp
  800e76:	50                   	push   %eax
  800e77:	6a 0d                	push   $0xd
  800e79:	68 ff 25 80 00       	push   $0x8025ff
  800e7e:	6a 23                	push   $0x23
  800e80:	68 1c 26 80 00       	push   $0x80261c
  800e85:	e8 ea f2 ff ff       	call   800174 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e8a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e8d:	5b                   	pop    %ebx
  800e8e:	5e                   	pop    %esi
  800e8f:	5f                   	pop    %edi
  800e90:	5d                   	pop    %ebp
  800e91:	c3                   	ret    

00800e92 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e92:	55                   	push   %ebp
  800e93:	89 e5                	mov    %esp,%ebp
  800e95:	56                   	push   %esi
  800e96:	53                   	push   %ebx
  800e97:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e9a:	8b 18                	mov    (%eax),%ebx
	// copy-on-write page.  If not, panic.
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).
	
	if((err & FEC_WR) == 0){
  800e9c:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800ea0:	75 14                	jne    800eb6 <pgfault+0x24>
		panic("pgfault not cause by write \n");
  800ea2:	83 ec 04             	sub    $0x4,%esp
  800ea5:	68 2a 26 80 00       	push   $0x80262a
  800eaa:	6a 1c                	push   $0x1c
  800eac:	68 47 26 80 00       	push   $0x802647
  800eb1:	e8 be f2 ff ff       	call   800174 <_panic>
	}
 
	if ((uvpt[PGNUM(addr)] & PTE_COW) == 0) 
  800eb6:	89 d8                	mov    %ebx,%eax
  800eb8:	c1 e8 0c             	shr    $0xc,%eax
  800ebb:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800ec2:	f6 c4 08             	test   $0x8,%ah
  800ec5:	75 14                	jne    800edb <pgfault+0x49>
    {
        panic("pgfault not cause by COW \n");
  800ec7:	83 ec 04             	sub    $0x4,%esp
  800eca:	68 52 26 80 00       	push   $0x802652
  800ecf:	6a 21                	push   $0x21
  800ed1:	68 47 26 80 00       	push   $0x802647
  800ed6:	e8 99 f2 ff ff       	call   800174 <_panic>
	// copy the data from the old page to the new page, then move the new
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.
	envid_t eid = sys_getenvid();
  800edb:	e8 83 fd ff ff       	call   800c63 <sys_getenvid>
  800ee0:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(eid,(void*)PFTEMP,PTE_P|PTE_W|PTE_U)) < 0)
  800ee2:	83 ec 04             	sub    $0x4,%esp
  800ee5:	6a 07                	push   $0x7
  800ee7:	68 00 f0 7f 00       	push   $0x7ff000
  800eec:	50                   	push   %eax
  800eed:	e8 af fd ff ff       	call   800ca1 <sys_page_alloc>
  800ef2:	83 c4 10             	add    $0x10,%esp
  800ef5:	85 c0                	test   %eax,%eax
  800ef7:	79 14                	jns    800f0d <pgfault+0x7b>
		panic("page alloction failed.\n");
  800ef9:	83 ec 04             	sub    $0x4,%esp
  800efc:	68 6d 26 80 00       	push   $0x80266d
  800f01:	6a 2d                	push   $0x2d
  800f03:	68 47 26 80 00       	push   $0x802647
  800f08:	e8 67 f2 ff ff       	call   800174 <_panic>
	addr = ROUNDDOWN(addr,PGSIZE);
  800f0d:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memmove(PFTEMP,addr,PGSIZE);
  800f13:	83 ec 04             	sub    $0x4,%esp
  800f16:	68 00 10 00 00       	push   $0x1000
  800f1b:	53                   	push   %ebx
  800f1c:	68 00 f0 7f 00       	push   $0x7ff000
  800f21:	e8 d8 fa ff ff       	call   8009fe <memmove>
	if ((r = sys_page_map(eid, PFTEMP, eid, addr, PTE_P | PTE_W |PTE_U)) < 0)
  800f26:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f2d:	53                   	push   %ebx
  800f2e:	56                   	push   %esi
  800f2f:	68 00 f0 7f 00       	push   $0x7ff000
  800f34:	56                   	push   %esi
  800f35:	e8 aa fd ff ff       	call   800ce4 <sys_page_map>
  800f3a:	83 c4 20             	add    $0x20,%esp
  800f3d:	85 c0                	test   %eax,%eax
  800f3f:	79 12                	jns    800f53 <pgfault+0xc1>
        panic("pgfault: page map failed %e\n", r);
  800f41:	50                   	push   %eax
  800f42:	68 85 26 80 00       	push   $0x802685
  800f47:	6a 31                	push   $0x31
  800f49:	68 47 26 80 00       	push   $0x802647
  800f4e:	e8 21 f2 ff ff       	call   800174 <_panic>
	if ((r = sys_page_unmap(eid, PFTEMP)) < 0)
  800f53:	83 ec 08             	sub    $0x8,%esp
  800f56:	68 00 f0 7f 00       	push   $0x7ff000
  800f5b:	56                   	push   %esi
  800f5c:	e8 c5 fd ff ff       	call   800d26 <sys_page_unmap>
  800f61:	83 c4 10             	add    $0x10,%esp
  800f64:	85 c0                	test   %eax,%eax
  800f66:	79 12                	jns    800f7a <pgfault+0xe8>
        panic("pgfault: page unmap failed %e\n", r);
  800f68:	50                   	push   %eax
  800f69:	68 f4 26 80 00       	push   $0x8026f4
  800f6e:	6a 33                	push   $0x33
  800f70:	68 47 26 80 00       	push   $0x802647
  800f75:	e8 fa f1 ff ff       	call   800174 <_panic>
	// LAB 4: Your code here.

	// panic("pgfault not implemented");
}
  800f7a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f7d:	5b                   	pop    %ebx
  800f7e:	5e                   	pop    %esi
  800f7f:	5d                   	pop    %ebp
  800f80:	c3                   	ret    

00800f81 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f81:	55                   	push   %ebp
  800f82:	89 e5                	mov    %esp,%ebp
  800f84:	57                   	push   %edi
  800f85:	56                   	push   %esi
  800f86:	53                   	push   %ebx
  800f87:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	struct PageInfo* pg = NULL;
	set_pgfault_handler(pgfault);
  800f8a:	68 92 0e 80 00       	push   $0x800e92
  800f8f:	e8 71 0e 00 00       	call   801e05 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800f94:	b8 07 00 00 00       	mov    $0x7,%eax
  800f99:	cd 30                	int    $0x30
  800f9b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800f9e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t eid = sys_exofork();
	if (eid < 0) panic("fork fault.\n");
  800fa1:	83 c4 10             	add    $0x10,%esp
  800fa4:	85 c0                	test   %eax,%eax
  800fa6:	79 14                	jns    800fbc <fork+0x3b>
  800fa8:	83 ec 04             	sub    $0x4,%esp
  800fab:	68 a2 26 80 00       	push   $0x8026a2
  800fb0:	6a 71                	push   $0x71
  800fb2:	68 47 26 80 00       	push   $0x802647
  800fb7:	e8 b8 f1 ff ff       	call   800174 <_panic>
	if (eid == 0){
  800fbc:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800fc0:	75 25                	jne    800fe7 <fork+0x66>
		thisenv = &envs[ENVX(sys_getenvid())];
  800fc2:	e8 9c fc ff ff       	call   800c63 <sys_getenvid>
  800fc7:	25 ff 03 00 00       	and    $0x3ff,%eax
  800fcc:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800fd3:	c1 e0 07             	shl    $0x7,%eax
  800fd6:	29 d0                	sub    %edx,%eax
  800fd8:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800fdd:	a3 08 40 80 00       	mov    %eax,0x804008
		return eid;
  800fe2:	e9 61 01 00 00       	jmp    801148 <fork+0x1c7>
  800fe7:	bb 00 00 80 00       	mov    $0x800000,%ebx
	}
	// copy something to the child page.
	for (uintptr_t i = UTEXT;i <= USTACKTOP;i += PGSIZE){
		if (uvpd[PDX(i)] & PTE_P && (uvpt[PGNUM(i)] & PTE_P)){
  800fec:	89 d8                	mov    %ebx,%eax
  800fee:	c1 e8 16             	shr    $0x16,%eax
  800ff1:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800ff8:	a8 01                	test   $0x1,%al
  800ffa:	74 52                	je     80104e <fork+0xcd>
  800ffc:	89 de                	mov    %ebx,%esi
  800ffe:	c1 ee 0c             	shr    $0xc,%esi
  801001:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801008:	a8 01                	test   $0x1,%al
  80100a:	74 42                	je     80104e <fork+0xcd>
duppage(envid_t envid, unsigned pn)
{
	int r;

	// LAB 4: Your code here.
	envid_t myenvid = sys_getenvid();
  80100c:	e8 52 fc ff ff       	call   800c63 <sys_getenvid>
  801011:	89 c7                	mov    %eax,%edi
	pte_t pte = uvpt[pn];
  801013:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
	int perm = PTE_U | PTE_P;
	if(pte & PTE_W || pte & PTE_COW)
  80101a:	a9 02 08 00 00       	test   $0x802,%eax
  80101f:	0f 85 de 00 00 00    	jne    801103 <fork+0x182>
  801025:	e9 fb 00 00 00       	jmp    801125 <fork+0x1a4>
		perm |= PTE_COW;
	if((r = sys_page_map(myenvid,(void*)(pn*PGSIZE),envid,(void*)(pn*PGSIZE),perm))<0){
		panic("duppage fault :%e\n",r);
  80102a:	50                   	push   %eax
  80102b:	68 af 26 80 00       	push   $0x8026af
  801030:	6a 50                	push   $0x50
  801032:	68 47 26 80 00       	push   $0x802647
  801037:	e8 38 f1 ff ff       	call   800174 <_panic>
	}
	if(perm & PTE_COW){
		if((r = sys_page_map(myenvid,(void*)(pn*PGSIZE),myenvid,(void*)(pn*PGSIZE),perm))<0)
			panic("duppage fault :%e\n",r);
  80103c:	50                   	push   %eax
  80103d:	68 af 26 80 00       	push   $0x8026af
  801042:	6a 54                	push   $0x54
  801044:	68 47 26 80 00       	push   $0x802647
  801049:	e8 26 f1 ff ff       	call   800174 <_panic>
	if (eid == 0){
		thisenv = &envs[ENVX(sys_getenvid())];
		return eid;
	}
	// copy something to the child page.
	for (uintptr_t i = UTEXT;i <= USTACKTOP;i += PGSIZE){
  80104e:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801054:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  80105a:	75 90                	jne    800fec <fork+0x6b>
		if (uvpd[PDX(i)] & PTE_P && (uvpt[PGNUM(i)] & PTE_P)){
			duppage(eid,PGNUM(i));
		}
	}
	int r = sys_page_alloc(eid,(void*)(UXSTACKTOP-PGSIZE),PTE_U|PTE_P|PTE_W);
  80105c:	83 ec 04             	sub    $0x4,%esp
  80105f:	6a 07                	push   $0x7
  801061:	68 00 f0 bf ee       	push   $0xeebff000
  801066:	ff 75 e0             	pushl  -0x20(%ebp)
  801069:	e8 33 fc ff ff       	call   800ca1 <sys_page_alloc>
	if (r < 0) panic("fork fault.\n");
  80106e:	83 c4 10             	add    $0x10,%esp
  801071:	85 c0                	test   %eax,%eax
  801073:	79 14                	jns    801089 <fork+0x108>
  801075:	83 ec 04             	sub    $0x4,%esp
  801078:	68 a2 26 80 00       	push   $0x8026a2
  80107d:	6a 7d                	push   $0x7d
  80107f:	68 47 26 80 00       	push   $0x802647
  801084:	e8 eb f0 ff ff       	call   800174 <_panic>

	extern void _pgfault_upcall();
    r = sys_env_set_pgfault_upcall(eid, _pgfault_upcall);
  801089:	83 ec 08             	sub    $0x8,%esp
  80108c:	68 7d 1e 80 00       	push   $0x801e7d
  801091:	ff 75 e0             	pushl  -0x20(%ebp)
  801094:	e8 53 fd ff ff       	call   800dec <sys_env_set_pgfault_upcall>
    if (r < 0) panic("fork fault 3\n");
  801099:	83 c4 10             	add    $0x10,%esp
  80109c:	85 c0                	test   %eax,%eax
  80109e:	79 17                	jns    8010b7 <fork+0x136>
  8010a0:	83 ec 04             	sub    $0x4,%esp
  8010a3:	68 c2 26 80 00       	push   $0x8026c2
  8010a8:	68 81 00 00 00       	push   $0x81
  8010ad:	68 47 26 80 00       	push   $0x802647
  8010b2:	e8 bd f0 ff ff       	call   800174 <_panic>

	if ((r = sys_env_set_status(eid, ENV_RUNNABLE)) < 0)
  8010b7:	83 ec 08             	sub    $0x8,%esp
  8010ba:	6a 02                	push   $0x2
  8010bc:	ff 75 e0             	pushl  -0x20(%ebp)
  8010bf:	e8 a4 fc ff ff       	call   800d68 <sys_env_set_status>
  8010c4:	83 c4 10             	add    $0x10,%esp
  8010c7:	85 c0                	test   %eax,%eax
  8010c9:	79 7d                	jns    801148 <fork+0x1c7>
        panic("fork fault 4\n");
  8010cb:	83 ec 04             	sub    $0x4,%esp
  8010ce:	68 d0 26 80 00       	push   $0x8026d0
  8010d3:	68 84 00 00 00       	push   $0x84
  8010d8:	68 47 26 80 00       	push   $0x802647
  8010dd:	e8 92 f0 ff ff       	call   800174 <_panic>
		perm |= PTE_COW;
	if((r = sys_page_map(myenvid,(void*)(pn*PGSIZE),envid,(void*)(pn*PGSIZE),perm))<0){
		panic("duppage fault :%e\n",r);
	}
	if(perm & PTE_COW){
		if((r = sys_page_map(myenvid,(void*)(pn*PGSIZE),myenvid,(void*)(pn*PGSIZE),perm))<0)
  8010e2:	83 ec 0c             	sub    $0xc,%esp
  8010e5:	68 05 08 00 00       	push   $0x805
  8010ea:	56                   	push   %esi
  8010eb:	57                   	push   %edi
  8010ec:	56                   	push   %esi
  8010ed:	57                   	push   %edi
  8010ee:	e8 f1 fb ff ff       	call   800ce4 <sys_page_map>
  8010f3:	83 c4 20             	add    $0x20,%esp
  8010f6:	85 c0                	test   %eax,%eax
  8010f8:	0f 89 50 ff ff ff    	jns    80104e <fork+0xcd>
  8010fe:	e9 39 ff ff ff       	jmp    80103c <fork+0xbb>
	envid_t myenvid = sys_getenvid();
	pte_t pte = uvpt[pn];
	int perm = PTE_U | PTE_P;
	if(pte & PTE_W || pte & PTE_COW)
		perm |= PTE_COW;
	if((r = sys_page_map(myenvid,(void*)(pn*PGSIZE),envid,(void*)(pn*PGSIZE),perm))<0){
  801103:	c1 e6 0c             	shl    $0xc,%esi
  801106:	83 ec 0c             	sub    $0xc,%esp
  801109:	68 05 08 00 00       	push   $0x805
  80110e:	56                   	push   %esi
  80110f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801112:	56                   	push   %esi
  801113:	57                   	push   %edi
  801114:	e8 cb fb ff ff       	call   800ce4 <sys_page_map>
  801119:	83 c4 20             	add    $0x20,%esp
  80111c:	85 c0                	test   %eax,%eax
  80111e:	79 c2                	jns    8010e2 <fork+0x161>
  801120:	e9 05 ff ff ff       	jmp    80102a <fork+0xa9>
  801125:	c1 e6 0c             	shl    $0xc,%esi
  801128:	83 ec 0c             	sub    $0xc,%esp
  80112b:	6a 05                	push   $0x5
  80112d:	56                   	push   %esi
  80112e:	ff 75 e4             	pushl  -0x1c(%ebp)
  801131:	56                   	push   %esi
  801132:	57                   	push   %edi
  801133:	e8 ac fb ff ff       	call   800ce4 <sys_page_map>
  801138:	83 c4 20             	add    $0x20,%esp
  80113b:	85 c0                	test   %eax,%eax
  80113d:	0f 89 0b ff ff ff    	jns    80104e <fork+0xcd>
  801143:	e9 e2 fe ff ff       	jmp    80102a <fork+0xa9>
    if (r < 0) panic("fork fault 3\n");

	if ((r = sys_env_set_status(eid, ENV_RUNNABLE)) < 0)
        panic("fork fault 4\n");
    return eid;
}
  801148:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80114b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80114e:	5b                   	pop    %ebx
  80114f:	5e                   	pop    %esi
  801150:	5f                   	pop    %edi
  801151:	5d                   	pop    %ebp
  801152:	c3                   	ret    

00801153 <sfork>:

// Challenge!
int
sfork(void)
{
  801153:	55                   	push   %ebp
  801154:	89 e5                	mov    %esp,%ebp
  801156:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801159:	68 de 26 80 00       	push   $0x8026de
  80115e:	68 8c 00 00 00       	push   $0x8c
  801163:	68 47 26 80 00       	push   $0x802647
  801168:	e8 07 f0 ff ff       	call   800174 <_panic>

0080116d <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80116d:	55                   	push   %ebp
  80116e:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801170:	8b 45 08             	mov    0x8(%ebp),%eax
  801173:	05 00 00 00 30       	add    $0x30000000,%eax
  801178:	c1 e8 0c             	shr    $0xc,%eax
}
  80117b:	5d                   	pop    %ebp
  80117c:	c3                   	ret    

0080117d <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80117d:	55                   	push   %ebp
  80117e:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801180:	8b 45 08             	mov    0x8(%ebp),%eax
  801183:	05 00 00 00 30       	add    $0x30000000,%eax
  801188:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80118d:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801192:	5d                   	pop    %ebp
  801193:	c3                   	ret    

00801194 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801194:	55                   	push   %ebp
  801195:	89 e5                	mov    %esp,%ebp
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801197:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  80119c:	a8 01                	test   $0x1,%al
  80119e:	74 34                	je     8011d4 <fd_alloc+0x40>
  8011a0:	a1 00 00 74 ef       	mov    0xef740000,%eax
  8011a5:	a8 01                	test   $0x1,%al
  8011a7:	74 32                	je     8011db <fd_alloc+0x47>
  8011a9:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8011ae:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8011b0:	89 c2                	mov    %eax,%edx
  8011b2:	c1 ea 16             	shr    $0x16,%edx
  8011b5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011bc:	f6 c2 01             	test   $0x1,%dl
  8011bf:	74 1f                	je     8011e0 <fd_alloc+0x4c>
  8011c1:	89 c2                	mov    %eax,%edx
  8011c3:	c1 ea 0c             	shr    $0xc,%edx
  8011c6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011cd:	f6 c2 01             	test   $0x1,%dl
  8011d0:	75 1a                	jne    8011ec <fd_alloc+0x58>
  8011d2:	eb 0c                	jmp    8011e0 <fd_alloc+0x4c>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8011d4:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  8011d9:	eb 05                	jmp    8011e0 <fd_alloc+0x4c>
  8011db:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  8011e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8011e3:	89 08                	mov    %ecx,(%eax)
			return 0;
  8011e5:	b8 00 00 00 00       	mov    $0x0,%eax
  8011ea:	eb 1a                	jmp    801206 <fd_alloc+0x72>
  8011ec:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8011f1:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8011f6:	75 b6                	jne    8011ae <fd_alloc+0x1a>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8011f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8011fb:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  801201:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801206:	5d                   	pop    %ebp
  801207:	c3                   	ret    

00801208 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801208:	55                   	push   %ebp
  801209:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80120b:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
  80120f:	77 39                	ja     80124a <fd_lookup+0x42>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801211:	8b 45 08             	mov    0x8(%ebp),%eax
  801214:	c1 e0 0c             	shl    $0xc,%eax
  801217:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80121c:	89 c2                	mov    %eax,%edx
  80121e:	c1 ea 16             	shr    $0x16,%edx
  801221:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801228:	f6 c2 01             	test   $0x1,%dl
  80122b:	74 24                	je     801251 <fd_lookup+0x49>
  80122d:	89 c2                	mov    %eax,%edx
  80122f:	c1 ea 0c             	shr    $0xc,%edx
  801232:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801239:	f6 c2 01             	test   $0x1,%dl
  80123c:	74 1a                	je     801258 <fd_lookup+0x50>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80123e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801241:	89 02                	mov    %eax,(%edx)
	return 0;
  801243:	b8 00 00 00 00       	mov    $0x0,%eax
  801248:	eb 13                	jmp    80125d <fd_lookup+0x55>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80124a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80124f:	eb 0c                	jmp    80125d <fd_lookup+0x55>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801251:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801256:	eb 05                	jmp    80125d <fd_lookup+0x55>
  801258:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80125d:	5d                   	pop    %ebp
  80125e:	c3                   	ret    

0080125f <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80125f:	55                   	push   %ebp
  801260:	89 e5                	mov    %esp,%ebp
  801262:	53                   	push   %ebx
  801263:	83 ec 04             	sub    $0x4,%esp
  801266:	8b 45 08             	mov    0x8(%ebp),%eax
  801269:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  80126c:	3b 05 04 30 80 00    	cmp    0x803004,%eax
  801272:	75 1e                	jne    801292 <dev_lookup+0x33>
  801274:	eb 0e                	jmp    801284 <dev_lookup+0x25>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801276:	b8 20 30 80 00       	mov    $0x803020,%eax
  80127b:	eb 0c                	jmp    801289 <dev_lookup+0x2a>
  80127d:	b8 3c 30 80 00       	mov    $0x80303c,%eax
  801282:	eb 05                	jmp    801289 <dev_lookup+0x2a>
  801284:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  801289:	89 03                	mov    %eax,(%ebx)
			return 0;
  80128b:	b8 00 00 00 00       	mov    $0x0,%eax
  801290:	eb 36                	jmp    8012c8 <dev_lookup+0x69>
int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  801292:	3b 05 20 30 80 00    	cmp    0x803020,%eax
  801298:	74 dc                	je     801276 <dev_lookup+0x17>
  80129a:	3b 05 3c 30 80 00    	cmp    0x80303c,%eax
  8012a0:	74 db                	je     80127d <dev_lookup+0x1e>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8012a2:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8012a8:	8b 52 48             	mov    0x48(%edx),%edx
  8012ab:	83 ec 04             	sub    $0x4,%esp
  8012ae:	50                   	push   %eax
  8012af:	52                   	push   %edx
  8012b0:	68 14 27 80 00       	push   $0x802714
  8012b5:	e8 92 ef ff ff       	call   80024c <cprintf>
	*dev = 0;
  8012ba:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  8012c0:	83 c4 10             	add    $0x10,%esp
  8012c3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8012c8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012cb:	c9                   	leave  
  8012cc:	c3                   	ret    

008012cd <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8012cd:	55                   	push   %ebp
  8012ce:	89 e5                	mov    %esp,%ebp
  8012d0:	56                   	push   %esi
  8012d1:	53                   	push   %ebx
  8012d2:	83 ec 10             	sub    $0x10,%esp
  8012d5:	8b 75 08             	mov    0x8(%ebp),%esi
  8012d8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012db:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012de:	50                   	push   %eax
  8012df:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8012e5:	c1 e8 0c             	shr    $0xc,%eax
  8012e8:	50                   	push   %eax
  8012e9:	e8 1a ff ff ff       	call   801208 <fd_lookup>
  8012ee:	83 c4 08             	add    $0x8,%esp
  8012f1:	85 c0                	test   %eax,%eax
  8012f3:	78 05                	js     8012fa <fd_close+0x2d>
	    || fd != fd2)
  8012f5:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8012f8:	74 06                	je     801300 <fd_close+0x33>
		return (must_exist ? r : 0);
  8012fa:	84 db                	test   %bl,%bl
  8012fc:	74 47                	je     801345 <fd_close+0x78>
  8012fe:	eb 4a                	jmp    80134a <fd_close+0x7d>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801300:	83 ec 08             	sub    $0x8,%esp
  801303:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801306:	50                   	push   %eax
  801307:	ff 36                	pushl  (%esi)
  801309:	e8 51 ff ff ff       	call   80125f <dev_lookup>
  80130e:	89 c3                	mov    %eax,%ebx
  801310:	83 c4 10             	add    $0x10,%esp
  801313:	85 c0                	test   %eax,%eax
  801315:	78 1c                	js     801333 <fd_close+0x66>
		if (dev->dev_close)
  801317:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80131a:	8b 40 10             	mov    0x10(%eax),%eax
  80131d:	85 c0                	test   %eax,%eax
  80131f:	74 0d                	je     80132e <fd_close+0x61>
			r = (*dev->dev_close)(fd);
  801321:	83 ec 0c             	sub    $0xc,%esp
  801324:	56                   	push   %esi
  801325:	ff d0                	call   *%eax
  801327:	89 c3                	mov    %eax,%ebx
  801329:	83 c4 10             	add    $0x10,%esp
  80132c:	eb 05                	jmp    801333 <fd_close+0x66>
		else
			r = 0;
  80132e:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801333:	83 ec 08             	sub    $0x8,%esp
  801336:	56                   	push   %esi
  801337:	6a 00                	push   $0x0
  801339:	e8 e8 f9 ff ff       	call   800d26 <sys_page_unmap>
	return r;
  80133e:	83 c4 10             	add    $0x10,%esp
  801341:	89 d8                	mov    %ebx,%eax
  801343:	eb 05                	jmp    80134a <fd_close+0x7d>
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
  801345:	b8 00 00 00 00       	mov    $0x0,%eax
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
	return r;
}
  80134a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80134d:	5b                   	pop    %ebx
  80134e:	5e                   	pop    %esi
  80134f:	5d                   	pop    %ebp
  801350:	c3                   	ret    

00801351 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801351:	55                   	push   %ebp
  801352:	89 e5                	mov    %esp,%ebp
  801354:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801357:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80135a:	50                   	push   %eax
  80135b:	ff 75 08             	pushl  0x8(%ebp)
  80135e:	e8 a5 fe ff ff       	call   801208 <fd_lookup>
  801363:	83 c4 08             	add    $0x8,%esp
  801366:	85 c0                	test   %eax,%eax
  801368:	78 10                	js     80137a <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80136a:	83 ec 08             	sub    $0x8,%esp
  80136d:	6a 01                	push   $0x1
  80136f:	ff 75 f4             	pushl  -0xc(%ebp)
  801372:	e8 56 ff ff ff       	call   8012cd <fd_close>
  801377:	83 c4 10             	add    $0x10,%esp
}
  80137a:	c9                   	leave  
  80137b:	c3                   	ret    

0080137c <close_all>:

void
close_all(void)
{
  80137c:	55                   	push   %ebp
  80137d:	89 e5                	mov    %esp,%ebp
  80137f:	53                   	push   %ebx
  801380:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801383:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801388:	83 ec 0c             	sub    $0xc,%esp
  80138b:	53                   	push   %ebx
  80138c:	e8 c0 ff ff ff       	call   801351 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801391:	43                   	inc    %ebx
  801392:	83 c4 10             	add    $0x10,%esp
  801395:	83 fb 20             	cmp    $0x20,%ebx
  801398:	75 ee                	jne    801388 <close_all+0xc>
		close(i);
}
  80139a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80139d:	c9                   	leave  
  80139e:	c3                   	ret    

0080139f <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80139f:	55                   	push   %ebp
  8013a0:	89 e5                	mov    %esp,%ebp
  8013a2:	57                   	push   %edi
  8013a3:	56                   	push   %esi
  8013a4:	53                   	push   %ebx
  8013a5:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8013a8:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8013ab:	50                   	push   %eax
  8013ac:	ff 75 08             	pushl  0x8(%ebp)
  8013af:	e8 54 fe ff ff       	call   801208 <fd_lookup>
  8013b4:	83 c4 08             	add    $0x8,%esp
  8013b7:	85 c0                	test   %eax,%eax
  8013b9:	0f 88 c2 00 00 00    	js     801481 <dup+0xe2>
		return r;
	close(newfdnum);
  8013bf:	83 ec 0c             	sub    $0xc,%esp
  8013c2:	ff 75 0c             	pushl  0xc(%ebp)
  8013c5:	e8 87 ff ff ff       	call   801351 <close>

	newfd = INDEX2FD(newfdnum);
  8013ca:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8013cd:	c1 e3 0c             	shl    $0xc,%ebx
  8013d0:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8013d6:	83 c4 04             	add    $0x4,%esp
  8013d9:	ff 75 e4             	pushl  -0x1c(%ebp)
  8013dc:	e8 9c fd ff ff       	call   80117d <fd2data>
  8013e1:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  8013e3:	89 1c 24             	mov    %ebx,(%esp)
  8013e6:	e8 92 fd ff ff       	call   80117d <fd2data>
  8013eb:	83 c4 10             	add    $0x10,%esp
  8013ee:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8013f0:	89 f0                	mov    %esi,%eax
  8013f2:	c1 e8 16             	shr    $0x16,%eax
  8013f5:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8013fc:	a8 01                	test   $0x1,%al
  8013fe:	74 35                	je     801435 <dup+0x96>
  801400:	89 f0                	mov    %esi,%eax
  801402:	c1 e8 0c             	shr    $0xc,%eax
  801405:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80140c:	f6 c2 01             	test   $0x1,%dl
  80140f:	74 24                	je     801435 <dup+0x96>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801411:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801418:	83 ec 0c             	sub    $0xc,%esp
  80141b:	25 07 0e 00 00       	and    $0xe07,%eax
  801420:	50                   	push   %eax
  801421:	57                   	push   %edi
  801422:	6a 00                	push   $0x0
  801424:	56                   	push   %esi
  801425:	6a 00                	push   $0x0
  801427:	e8 b8 f8 ff ff       	call   800ce4 <sys_page_map>
  80142c:	89 c6                	mov    %eax,%esi
  80142e:	83 c4 20             	add    $0x20,%esp
  801431:	85 c0                	test   %eax,%eax
  801433:	78 2c                	js     801461 <dup+0xc2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801435:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801438:	89 d0                	mov    %edx,%eax
  80143a:	c1 e8 0c             	shr    $0xc,%eax
  80143d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801444:	83 ec 0c             	sub    $0xc,%esp
  801447:	25 07 0e 00 00       	and    $0xe07,%eax
  80144c:	50                   	push   %eax
  80144d:	53                   	push   %ebx
  80144e:	6a 00                	push   $0x0
  801450:	52                   	push   %edx
  801451:	6a 00                	push   $0x0
  801453:	e8 8c f8 ff ff       	call   800ce4 <sys_page_map>
  801458:	89 c6                	mov    %eax,%esi
  80145a:	83 c4 20             	add    $0x20,%esp
  80145d:	85 c0                	test   %eax,%eax
  80145f:	79 1d                	jns    80147e <dup+0xdf>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801461:	83 ec 08             	sub    $0x8,%esp
  801464:	53                   	push   %ebx
  801465:	6a 00                	push   $0x0
  801467:	e8 ba f8 ff ff       	call   800d26 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80146c:	83 c4 08             	add    $0x8,%esp
  80146f:	57                   	push   %edi
  801470:	6a 00                	push   $0x0
  801472:	e8 af f8 ff ff       	call   800d26 <sys_page_unmap>
	return r;
  801477:	83 c4 10             	add    $0x10,%esp
  80147a:	89 f0                	mov    %esi,%eax
  80147c:	eb 03                	jmp    801481 <dup+0xe2>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  80147e:	8b 45 0c             	mov    0xc(%ebp),%eax

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801481:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801484:	5b                   	pop    %ebx
  801485:	5e                   	pop    %esi
  801486:	5f                   	pop    %edi
  801487:	5d                   	pop    %ebp
  801488:	c3                   	ret    

00801489 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801489:	55                   	push   %ebp
  80148a:	89 e5                	mov    %esp,%ebp
  80148c:	53                   	push   %ebx
  80148d:	83 ec 14             	sub    $0x14,%esp
  801490:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801493:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801496:	50                   	push   %eax
  801497:	53                   	push   %ebx
  801498:	e8 6b fd ff ff       	call   801208 <fd_lookup>
  80149d:	83 c4 08             	add    $0x8,%esp
  8014a0:	85 c0                	test   %eax,%eax
  8014a2:	78 67                	js     80150b <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014a4:	83 ec 08             	sub    $0x8,%esp
  8014a7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014aa:	50                   	push   %eax
  8014ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014ae:	ff 30                	pushl  (%eax)
  8014b0:	e8 aa fd ff ff       	call   80125f <dev_lookup>
  8014b5:	83 c4 10             	add    $0x10,%esp
  8014b8:	85 c0                	test   %eax,%eax
  8014ba:	78 4f                	js     80150b <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8014bc:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8014bf:	8b 42 08             	mov    0x8(%edx),%eax
  8014c2:	83 e0 03             	and    $0x3,%eax
  8014c5:	83 f8 01             	cmp    $0x1,%eax
  8014c8:	75 21                	jne    8014eb <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8014ca:	a1 08 40 80 00       	mov    0x804008,%eax
  8014cf:	8b 40 48             	mov    0x48(%eax),%eax
  8014d2:	83 ec 04             	sub    $0x4,%esp
  8014d5:	53                   	push   %ebx
  8014d6:	50                   	push   %eax
  8014d7:	68 58 27 80 00       	push   $0x802758
  8014dc:	e8 6b ed ff ff       	call   80024c <cprintf>
		return -E_INVAL;
  8014e1:	83 c4 10             	add    $0x10,%esp
  8014e4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014e9:	eb 20                	jmp    80150b <read+0x82>
	}
	if (!dev->dev_read)
  8014eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014ee:	8b 40 08             	mov    0x8(%eax),%eax
  8014f1:	85 c0                	test   %eax,%eax
  8014f3:	74 11                	je     801506 <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8014f5:	83 ec 04             	sub    $0x4,%esp
  8014f8:	ff 75 10             	pushl  0x10(%ebp)
  8014fb:	ff 75 0c             	pushl  0xc(%ebp)
  8014fe:	52                   	push   %edx
  8014ff:	ff d0                	call   *%eax
  801501:	83 c4 10             	add    $0x10,%esp
  801504:	eb 05                	jmp    80150b <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801506:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  80150b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80150e:	c9                   	leave  
  80150f:	c3                   	ret    

00801510 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801510:	55                   	push   %ebp
  801511:	89 e5                	mov    %esp,%ebp
  801513:	57                   	push   %edi
  801514:	56                   	push   %esi
  801515:	53                   	push   %ebx
  801516:	83 ec 0c             	sub    $0xc,%esp
  801519:	8b 7d 08             	mov    0x8(%ebp),%edi
  80151c:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80151f:	85 f6                	test   %esi,%esi
  801521:	74 31                	je     801554 <readn+0x44>
  801523:	b8 00 00 00 00       	mov    $0x0,%eax
  801528:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  80152d:	83 ec 04             	sub    $0x4,%esp
  801530:	89 f2                	mov    %esi,%edx
  801532:	29 c2                	sub    %eax,%edx
  801534:	52                   	push   %edx
  801535:	03 45 0c             	add    0xc(%ebp),%eax
  801538:	50                   	push   %eax
  801539:	57                   	push   %edi
  80153a:	e8 4a ff ff ff       	call   801489 <read>
		if (m < 0)
  80153f:	83 c4 10             	add    $0x10,%esp
  801542:	85 c0                	test   %eax,%eax
  801544:	78 17                	js     80155d <readn+0x4d>
			return m;
		if (m == 0)
  801546:	85 c0                	test   %eax,%eax
  801548:	74 11                	je     80155b <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80154a:	01 c3                	add    %eax,%ebx
  80154c:	89 d8                	mov    %ebx,%eax
  80154e:	39 f3                	cmp    %esi,%ebx
  801550:	72 db                	jb     80152d <readn+0x1d>
  801552:	eb 09                	jmp    80155d <readn+0x4d>
  801554:	b8 00 00 00 00       	mov    $0x0,%eax
  801559:	eb 02                	jmp    80155d <readn+0x4d>
  80155b:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80155d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801560:	5b                   	pop    %ebx
  801561:	5e                   	pop    %esi
  801562:	5f                   	pop    %edi
  801563:	5d                   	pop    %ebp
  801564:	c3                   	ret    

00801565 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801565:	55                   	push   %ebp
  801566:	89 e5                	mov    %esp,%ebp
  801568:	53                   	push   %ebx
  801569:	83 ec 14             	sub    $0x14,%esp
  80156c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80156f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801572:	50                   	push   %eax
  801573:	53                   	push   %ebx
  801574:	e8 8f fc ff ff       	call   801208 <fd_lookup>
  801579:	83 c4 08             	add    $0x8,%esp
  80157c:	85 c0                	test   %eax,%eax
  80157e:	78 62                	js     8015e2 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801580:	83 ec 08             	sub    $0x8,%esp
  801583:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801586:	50                   	push   %eax
  801587:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80158a:	ff 30                	pushl  (%eax)
  80158c:	e8 ce fc ff ff       	call   80125f <dev_lookup>
  801591:	83 c4 10             	add    $0x10,%esp
  801594:	85 c0                	test   %eax,%eax
  801596:	78 4a                	js     8015e2 <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801598:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80159b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80159f:	75 21                	jne    8015c2 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8015a1:	a1 08 40 80 00       	mov    0x804008,%eax
  8015a6:	8b 40 48             	mov    0x48(%eax),%eax
  8015a9:	83 ec 04             	sub    $0x4,%esp
  8015ac:	53                   	push   %ebx
  8015ad:	50                   	push   %eax
  8015ae:	68 74 27 80 00       	push   $0x802774
  8015b3:	e8 94 ec ff ff       	call   80024c <cprintf>
		return -E_INVAL;
  8015b8:	83 c4 10             	add    $0x10,%esp
  8015bb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015c0:	eb 20                	jmp    8015e2 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8015c2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015c5:	8b 52 0c             	mov    0xc(%edx),%edx
  8015c8:	85 d2                	test   %edx,%edx
  8015ca:	74 11                	je     8015dd <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8015cc:	83 ec 04             	sub    $0x4,%esp
  8015cf:	ff 75 10             	pushl  0x10(%ebp)
  8015d2:	ff 75 0c             	pushl  0xc(%ebp)
  8015d5:	50                   	push   %eax
  8015d6:	ff d2                	call   *%edx
  8015d8:	83 c4 10             	add    $0x10,%esp
  8015db:	eb 05                	jmp    8015e2 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8015dd:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8015e2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015e5:	c9                   	leave  
  8015e6:	c3                   	ret    

008015e7 <seek>:

int
seek(int fdnum, off_t offset)
{
  8015e7:	55                   	push   %ebp
  8015e8:	89 e5                	mov    %esp,%ebp
  8015ea:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015ed:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8015f0:	50                   	push   %eax
  8015f1:	ff 75 08             	pushl  0x8(%ebp)
  8015f4:	e8 0f fc ff ff       	call   801208 <fd_lookup>
  8015f9:	83 c4 08             	add    $0x8,%esp
  8015fc:	85 c0                	test   %eax,%eax
  8015fe:	78 0e                	js     80160e <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801600:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801603:	8b 55 0c             	mov    0xc(%ebp),%edx
  801606:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801609:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80160e:	c9                   	leave  
  80160f:	c3                   	ret    

00801610 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801610:	55                   	push   %ebp
  801611:	89 e5                	mov    %esp,%ebp
  801613:	53                   	push   %ebx
  801614:	83 ec 14             	sub    $0x14,%esp
  801617:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80161a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80161d:	50                   	push   %eax
  80161e:	53                   	push   %ebx
  80161f:	e8 e4 fb ff ff       	call   801208 <fd_lookup>
  801624:	83 c4 08             	add    $0x8,%esp
  801627:	85 c0                	test   %eax,%eax
  801629:	78 5f                	js     80168a <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80162b:	83 ec 08             	sub    $0x8,%esp
  80162e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801631:	50                   	push   %eax
  801632:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801635:	ff 30                	pushl  (%eax)
  801637:	e8 23 fc ff ff       	call   80125f <dev_lookup>
  80163c:	83 c4 10             	add    $0x10,%esp
  80163f:	85 c0                	test   %eax,%eax
  801641:	78 47                	js     80168a <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801643:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801646:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80164a:	75 21                	jne    80166d <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80164c:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801651:	8b 40 48             	mov    0x48(%eax),%eax
  801654:	83 ec 04             	sub    $0x4,%esp
  801657:	53                   	push   %ebx
  801658:	50                   	push   %eax
  801659:	68 34 27 80 00       	push   $0x802734
  80165e:	e8 e9 eb ff ff       	call   80024c <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801663:	83 c4 10             	add    $0x10,%esp
  801666:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80166b:	eb 1d                	jmp    80168a <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  80166d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801670:	8b 52 18             	mov    0x18(%edx),%edx
  801673:	85 d2                	test   %edx,%edx
  801675:	74 0e                	je     801685 <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801677:	83 ec 08             	sub    $0x8,%esp
  80167a:	ff 75 0c             	pushl  0xc(%ebp)
  80167d:	50                   	push   %eax
  80167e:	ff d2                	call   *%edx
  801680:	83 c4 10             	add    $0x10,%esp
  801683:	eb 05                	jmp    80168a <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801685:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  80168a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80168d:	c9                   	leave  
  80168e:	c3                   	ret    

0080168f <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80168f:	55                   	push   %ebp
  801690:	89 e5                	mov    %esp,%ebp
  801692:	53                   	push   %ebx
  801693:	83 ec 14             	sub    $0x14,%esp
  801696:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801699:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80169c:	50                   	push   %eax
  80169d:	ff 75 08             	pushl  0x8(%ebp)
  8016a0:	e8 63 fb ff ff       	call   801208 <fd_lookup>
  8016a5:	83 c4 08             	add    $0x8,%esp
  8016a8:	85 c0                	test   %eax,%eax
  8016aa:	78 52                	js     8016fe <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016ac:	83 ec 08             	sub    $0x8,%esp
  8016af:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016b2:	50                   	push   %eax
  8016b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016b6:	ff 30                	pushl  (%eax)
  8016b8:	e8 a2 fb ff ff       	call   80125f <dev_lookup>
  8016bd:	83 c4 10             	add    $0x10,%esp
  8016c0:	85 c0                	test   %eax,%eax
  8016c2:	78 3a                	js     8016fe <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  8016c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016c7:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8016cb:	74 2c                	je     8016f9 <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8016cd:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8016d0:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8016d7:	00 00 00 
	stat->st_isdir = 0;
  8016da:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016e1:	00 00 00 
	stat->st_dev = dev;
  8016e4:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8016ea:	83 ec 08             	sub    $0x8,%esp
  8016ed:	53                   	push   %ebx
  8016ee:	ff 75 f0             	pushl  -0x10(%ebp)
  8016f1:	ff 50 14             	call   *0x14(%eax)
  8016f4:	83 c4 10             	add    $0x10,%esp
  8016f7:	eb 05                	jmp    8016fe <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8016f9:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8016fe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801701:	c9                   	leave  
  801702:	c3                   	ret    

00801703 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801703:	55                   	push   %ebp
  801704:	89 e5                	mov    %esp,%ebp
  801706:	56                   	push   %esi
  801707:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801708:	83 ec 08             	sub    $0x8,%esp
  80170b:	6a 00                	push   $0x0
  80170d:	ff 75 08             	pushl  0x8(%ebp)
  801710:	e8 75 01 00 00       	call   80188a <open>
  801715:	89 c3                	mov    %eax,%ebx
  801717:	83 c4 10             	add    $0x10,%esp
  80171a:	85 c0                	test   %eax,%eax
  80171c:	78 1d                	js     80173b <stat+0x38>
		return fd;
	r = fstat(fd, stat);
  80171e:	83 ec 08             	sub    $0x8,%esp
  801721:	ff 75 0c             	pushl  0xc(%ebp)
  801724:	50                   	push   %eax
  801725:	e8 65 ff ff ff       	call   80168f <fstat>
  80172a:	89 c6                	mov    %eax,%esi
	close(fd);
  80172c:	89 1c 24             	mov    %ebx,(%esp)
  80172f:	e8 1d fc ff ff       	call   801351 <close>
	return r;
  801734:	83 c4 10             	add    $0x10,%esp
  801737:	89 f0                	mov    %esi,%eax
  801739:	eb 00                	jmp    80173b <stat+0x38>
}
  80173b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80173e:	5b                   	pop    %ebx
  80173f:	5e                   	pop    %esi
  801740:	5d                   	pop    %ebp
  801741:	c3                   	ret    

00801742 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801742:	55                   	push   %ebp
  801743:	89 e5                	mov    %esp,%ebp
  801745:	56                   	push   %esi
  801746:	53                   	push   %ebx
  801747:	89 c6                	mov    %eax,%esi
  801749:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80174b:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801752:	75 12                	jne    801766 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801754:	83 ec 0c             	sub    $0xc,%esp
  801757:	6a 01                	push   $0x1
  801759:	e8 19 08 00 00       	call   801f77 <ipc_find_env>
  80175e:	a3 00 40 80 00       	mov    %eax,0x804000
  801763:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801766:	6a 07                	push   $0x7
  801768:	68 00 50 80 00       	push   $0x805000
  80176d:	56                   	push   %esi
  80176e:	ff 35 00 40 80 00    	pushl  0x804000
  801774:	e8 9f 07 00 00       	call   801f18 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801779:	83 c4 0c             	add    $0xc,%esp
  80177c:	6a 00                	push   $0x0
  80177e:	53                   	push   %ebx
  80177f:	6a 00                	push   $0x0
  801781:	e8 1d 07 00 00       	call   801ea3 <ipc_recv>
}
  801786:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801789:	5b                   	pop    %ebx
  80178a:	5e                   	pop    %esi
  80178b:	5d                   	pop    %ebp
  80178c:	c3                   	ret    

0080178d <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80178d:	55                   	push   %ebp
  80178e:	89 e5                	mov    %esp,%ebp
  801790:	53                   	push   %ebx
  801791:	83 ec 04             	sub    $0x4,%esp
  801794:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801797:	8b 45 08             	mov    0x8(%ebp),%eax
  80179a:	8b 40 0c             	mov    0xc(%eax),%eax
  80179d:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8017a2:	ba 00 00 00 00       	mov    $0x0,%edx
  8017a7:	b8 05 00 00 00       	mov    $0x5,%eax
  8017ac:	e8 91 ff ff ff       	call   801742 <fsipc>
  8017b1:	85 c0                	test   %eax,%eax
  8017b3:	78 2c                	js     8017e1 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8017b5:	83 ec 08             	sub    $0x8,%esp
  8017b8:	68 00 50 80 00       	push   $0x805000
  8017bd:	53                   	push   %ebx
  8017be:	e8 6e f0 ff ff       	call   800831 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8017c3:	a1 80 50 80 00       	mov    0x805080,%eax
  8017c8:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8017ce:	a1 84 50 80 00       	mov    0x805084,%eax
  8017d3:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8017d9:	83 c4 10             	add    $0x10,%esp
  8017dc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017e1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017e4:	c9                   	leave  
  8017e5:	c3                   	ret    

008017e6 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8017e6:	55                   	push   %ebp
  8017e7:	89 e5                	mov    %esp,%ebp
  8017e9:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8017ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ef:	8b 40 0c             	mov    0xc(%eax),%eax
  8017f2:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8017f7:	ba 00 00 00 00       	mov    $0x0,%edx
  8017fc:	b8 06 00 00 00       	mov    $0x6,%eax
  801801:	e8 3c ff ff ff       	call   801742 <fsipc>
}
  801806:	c9                   	leave  
  801807:	c3                   	ret    

00801808 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801808:	55                   	push   %ebp
  801809:	89 e5                	mov    %esp,%ebp
  80180b:	56                   	push   %esi
  80180c:	53                   	push   %ebx
  80180d:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801810:	8b 45 08             	mov    0x8(%ebp),%eax
  801813:	8b 40 0c             	mov    0xc(%eax),%eax
  801816:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80181b:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801821:	ba 00 00 00 00       	mov    $0x0,%edx
  801826:	b8 03 00 00 00       	mov    $0x3,%eax
  80182b:	e8 12 ff ff ff       	call   801742 <fsipc>
  801830:	89 c3                	mov    %eax,%ebx
  801832:	85 c0                	test   %eax,%eax
  801834:	78 4b                	js     801881 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801836:	39 c6                	cmp    %eax,%esi
  801838:	73 16                	jae    801850 <devfile_read+0x48>
  80183a:	68 91 27 80 00       	push   $0x802791
  80183f:	68 98 27 80 00       	push   $0x802798
  801844:	6a 7a                	push   $0x7a
  801846:	68 ad 27 80 00       	push   $0x8027ad
  80184b:	e8 24 e9 ff ff       	call   800174 <_panic>
	assert(r <= PGSIZE);
  801850:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801855:	7e 16                	jle    80186d <devfile_read+0x65>
  801857:	68 b8 27 80 00       	push   $0x8027b8
  80185c:	68 98 27 80 00       	push   $0x802798
  801861:	6a 7b                	push   $0x7b
  801863:	68 ad 27 80 00       	push   $0x8027ad
  801868:	e8 07 e9 ff ff       	call   800174 <_panic>
	memmove(buf, &fsipcbuf, r);
  80186d:	83 ec 04             	sub    $0x4,%esp
  801870:	50                   	push   %eax
  801871:	68 00 50 80 00       	push   $0x805000
  801876:	ff 75 0c             	pushl  0xc(%ebp)
  801879:	e8 80 f1 ff ff       	call   8009fe <memmove>
	return r;
  80187e:	83 c4 10             	add    $0x10,%esp
}
  801881:	89 d8                	mov    %ebx,%eax
  801883:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801886:	5b                   	pop    %ebx
  801887:	5e                   	pop    %esi
  801888:	5d                   	pop    %ebp
  801889:	c3                   	ret    

0080188a <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80188a:	55                   	push   %ebp
  80188b:	89 e5                	mov    %esp,%ebp
  80188d:	53                   	push   %ebx
  80188e:	83 ec 20             	sub    $0x20,%esp
  801891:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801894:	53                   	push   %ebx
  801895:	e8 40 ef ff ff       	call   8007da <strlen>
  80189a:	83 c4 10             	add    $0x10,%esp
  80189d:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8018a2:	7f 63                	jg     801907 <open+0x7d>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018a4:	83 ec 0c             	sub    $0xc,%esp
  8018a7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018aa:	50                   	push   %eax
  8018ab:	e8 e4 f8 ff ff       	call   801194 <fd_alloc>
  8018b0:	83 c4 10             	add    $0x10,%esp
  8018b3:	85 c0                	test   %eax,%eax
  8018b5:	78 55                	js     80190c <open+0x82>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8018b7:	83 ec 08             	sub    $0x8,%esp
  8018ba:	53                   	push   %ebx
  8018bb:	68 00 50 80 00       	push   $0x805000
  8018c0:	e8 6c ef ff ff       	call   800831 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8018c5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018c8:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8018cd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018d0:	b8 01 00 00 00       	mov    $0x1,%eax
  8018d5:	e8 68 fe ff ff       	call   801742 <fsipc>
  8018da:	89 c3                	mov    %eax,%ebx
  8018dc:	83 c4 10             	add    $0x10,%esp
  8018df:	85 c0                	test   %eax,%eax
  8018e1:	79 14                	jns    8018f7 <open+0x6d>
		fd_close(fd, 0);
  8018e3:	83 ec 08             	sub    $0x8,%esp
  8018e6:	6a 00                	push   $0x0
  8018e8:	ff 75 f4             	pushl  -0xc(%ebp)
  8018eb:	e8 dd f9 ff ff       	call   8012cd <fd_close>
		return r;
  8018f0:	83 c4 10             	add    $0x10,%esp
  8018f3:	89 d8                	mov    %ebx,%eax
  8018f5:	eb 15                	jmp    80190c <open+0x82>
	}

	return fd2num(fd);
  8018f7:	83 ec 0c             	sub    $0xc,%esp
  8018fa:	ff 75 f4             	pushl  -0xc(%ebp)
  8018fd:	e8 6b f8 ff ff       	call   80116d <fd2num>
  801902:	83 c4 10             	add    $0x10,%esp
  801905:	eb 05                	jmp    80190c <open+0x82>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801907:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80190c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80190f:	c9                   	leave  
  801910:	c3                   	ret    

00801911 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801911:	55                   	push   %ebp
  801912:	89 e5                	mov    %esp,%ebp
  801914:	56                   	push   %esi
  801915:	53                   	push   %ebx
  801916:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801919:	83 ec 0c             	sub    $0xc,%esp
  80191c:	ff 75 08             	pushl  0x8(%ebp)
  80191f:	e8 59 f8 ff ff       	call   80117d <fd2data>
  801924:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801926:	83 c4 08             	add    $0x8,%esp
  801929:	68 c4 27 80 00       	push   $0x8027c4
  80192e:	53                   	push   %ebx
  80192f:	e8 fd ee ff ff       	call   800831 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801934:	8b 46 04             	mov    0x4(%esi),%eax
  801937:	2b 06                	sub    (%esi),%eax
  801939:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80193f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801946:	00 00 00 
	stat->st_dev = &devpipe;
  801949:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801950:	30 80 00 
	return 0;
}
  801953:	b8 00 00 00 00       	mov    $0x0,%eax
  801958:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80195b:	5b                   	pop    %ebx
  80195c:	5e                   	pop    %esi
  80195d:	5d                   	pop    %ebp
  80195e:	c3                   	ret    

0080195f <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80195f:	55                   	push   %ebp
  801960:	89 e5                	mov    %esp,%ebp
  801962:	53                   	push   %ebx
  801963:	83 ec 0c             	sub    $0xc,%esp
  801966:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801969:	53                   	push   %ebx
  80196a:	6a 00                	push   $0x0
  80196c:	e8 b5 f3 ff ff       	call   800d26 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801971:	89 1c 24             	mov    %ebx,(%esp)
  801974:	e8 04 f8 ff ff       	call   80117d <fd2data>
  801979:	83 c4 08             	add    $0x8,%esp
  80197c:	50                   	push   %eax
  80197d:	6a 00                	push   $0x0
  80197f:	e8 a2 f3 ff ff       	call   800d26 <sys_page_unmap>
}
  801984:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801987:	c9                   	leave  
  801988:	c3                   	ret    

00801989 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801989:	55                   	push   %ebp
  80198a:	89 e5                	mov    %esp,%ebp
  80198c:	57                   	push   %edi
  80198d:	56                   	push   %esi
  80198e:	53                   	push   %ebx
  80198f:	83 ec 1c             	sub    $0x1c,%esp
  801992:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801995:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801997:	a1 08 40 80 00       	mov    0x804008,%eax
  80199c:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  80199f:	83 ec 0c             	sub    $0xc,%esp
  8019a2:	ff 75 e0             	pushl  -0x20(%ebp)
  8019a5:	e8 28 06 00 00       	call   801fd2 <pageref>
  8019aa:	89 c3                	mov    %eax,%ebx
  8019ac:	89 3c 24             	mov    %edi,(%esp)
  8019af:	e8 1e 06 00 00       	call   801fd2 <pageref>
  8019b4:	83 c4 10             	add    $0x10,%esp
  8019b7:	39 c3                	cmp    %eax,%ebx
  8019b9:	0f 94 c1             	sete   %cl
  8019bc:	0f b6 c9             	movzbl %cl,%ecx
  8019bf:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8019c2:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8019c8:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8019cb:	39 ce                	cmp    %ecx,%esi
  8019cd:	74 1b                	je     8019ea <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8019cf:	39 c3                	cmp    %eax,%ebx
  8019d1:	75 c4                	jne    801997 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8019d3:	8b 42 58             	mov    0x58(%edx),%eax
  8019d6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8019d9:	50                   	push   %eax
  8019da:	56                   	push   %esi
  8019db:	68 cb 27 80 00       	push   $0x8027cb
  8019e0:	e8 67 e8 ff ff       	call   80024c <cprintf>
  8019e5:	83 c4 10             	add    $0x10,%esp
  8019e8:	eb ad                	jmp    801997 <_pipeisclosed+0xe>
	}
}
  8019ea:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8019ed:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019f0:	5b                   	pop    %ebx
  8019f1:	5e                   	pop    %esi
  8019f2:	5f                   	pop    %edi
  8019f3:	5d                   	pop    %ebp
  8019f4:	c3                   	ret    

008019f5 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8019f5:	55                   	push   %ebp
  8019f6:	89 e5                	mov    %esp,%ebp
  8019f8:	57                   	push   %edi
  8019f9:	56                   	push   %esi
  8019fa:	53                   	push   %ebx
  8019fb:	83 ec 18             	sub    $0x18,%esp
  8019fe:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801a01:	56                   	push   %esi
  801a02:	e8 76 f7 ff ff       	call   80117d <fd2data>
  801a07:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a09:	83 c4 10             	add    $0x10,%esp
  801a0c:	bf 00 00 00 00       	mov    $0x0,%edi
  801a11:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801a15:	75 42                	jne    801a59 <devpipe_write+0x64>
  801a17:	eb 4e                	jmp    801a67 <devpipe_write+0x72>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801a19:	89 da                	mov    %ebx,%edx
  801a1b:	89 f0                	mov    %esi,%eax
  801a1d:	e8 67 ff ff ff       	call   801989 <_pipeisclosed>
  801a22:	85 c0                	test   %eax,%eax
  801a24:	75 46                	jne    801a6c <devpipe_write+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801a26:	e8 57 f2 ff ff       	call   800c82 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801a2b:	8b 53 04             	mov    0x4(%ebx),%edx
  801a2e:	8b 03                	mov    (%ebx),%eax
  801a30:	83 c0 20             	add    $0x20,%eax
  801a33:	39 c2                	cmp    %eax,%edx
  801a35:	73 e2                	jae    801a19 <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801a37:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a3a:	8a 0c 38             	mov    (%eax,%edi,1),%cl
  801a3d:	89 d0                	mov    %edx,%eax
  801a3f:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801a44:	79 05                	jns    801a4b <devpipe_write+0x56>
  801a46:	48                   	dec    %eax
  801a47:	83 c8 e0             	or     $0xffffffe0,%eax
  801a4a:	40                   	inc    %eax
  801a4b:	88 4c 03 08          	mov    %cl,0x8(%ebx,%eax,1)
		p->p_wpos++;
  801a4f:	42                   	inc    %edx
  801a50:	89 53 04             	mov    %edx,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a53:	47                   	inc    %edi
  801a54:	39 7d 10             	cmp    %edi,0x10(%ebp)
  801a57:	74 0e                	je     801a67 <devpipe_write+0x72>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801a59:	8b 53 04             	mov    0x4(%ebx),%edx
  801a5c:	8b 03                	mov    (%ebx),%eax
  801a5e:	83 c0 20             	add    $0x20,%eax
  801a61:	39 c2                	cmp    %eax,%edx
  801a63:	73 b4                	jae    801a19 <devpipe_write+0x24>
  801a65:	eb d0                	jmp    801a37 <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801a67:	8b 45 10             	mov    0x10(%ebp),%eax
  801a6a:	eb 05                	jmp    801a71 <devpipe_write+0x7c>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801a6c:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801a71:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a74:	5b                   	pop    %ebx
  801a75:	5e                   	pop    %esi
  801a76:	5f                   	pop    %edi
  801a77:	5d                   	pop    %ebp
  801a78:	c3                   	ret    

00801a79 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801a79:	55                   	push   %ebp
  801a7a:	89 e5                	mov    %esp,%ebp
  801a7c:	57                   	push   %edi
  801a7d:	56                   	push   %esi
  801a7e:	53                   	push   %ebx
  801a7f:	83 ec 18             	sub    $0x18,%esp
  801a82:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801a85:	57                   	push   %edi
  801a86:	e8 f2 f6 ff ff       	call   80117d <fd2data>
  801a8b:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a8d:	83 c4 10             	add    $0x10,%esp
  801a90:	be 00 00 00 00       	mov    $0x0,%esi
  801a95:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801a99:	75 3d                	jne    801ad8 <devpipe_read+0x5f>
  801a9b:	eb 48                	jmp    801ae5 <devpipe_read+0x6c>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  801a9d:	89 f0                	mov    %esi,%eax
  801a9f:	eb 4e                	jmp    801aef <devpipe_read+0x76>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801aa1:	89 da                	mov    %ebx,%edx
  801aa3:	89 f8                	mov    %edi,%eax
  801aa5:	e8 df fe ff ff       	call   801989 <_pipeisclosed>
  801aaa:	85 c0                	test   %eax,%eax
  801aac:	75 3c                	jne    801aea <devpipe_read+0x71>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801aae:	e8 cf f1 ff ff       	call   800c82 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801ab3:	8b 03                	mov    (%ebx),%eax
  801ab5:	3b 43 04             	cmp    0x4(%ebx),%eax
  801ab8:	74 e7                	je     801aa1 <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801aba:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801abf:	79 05                	jns    801ac6 <devpipe_read+0x4d>
  801ac1:	48                   	dec    %eax
  801ac2:	83 c8 e0             	or     $0xffffffe0,%eax
  801ac5:	40                   	inc    %eax
  801ac6:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801aca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801acd:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801ad0:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ad2:	46                   	inc    %esi
  801ad3:	39 75 10             	cmp    %esi,0x10(%ebp)
  801ad6:	74 0d                	je     801ae5 <devpipe_read+0x6c>
		while (p->p_rpos == p->p_wpos) {
  801ad8:	8b 03                	mov    (%ebx),%eax
  801ada:	3b 43 04             	cmp    0x4(%ebx),%eax
  801add:	75 db                	jne    801aba <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801adf:	85 f6                	test   %esi,%esi
  801ae1:	75 ba                	jne    801a9d <devpipe_read+0x24>
  801ae3:	eb bc                	jmp    801aa1 <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801ae5:	8b 45 10             	mov    0x10(%ebp),%eax
  801ae8:	eb 05                	jmp    801aef <devpipe_read+0x76>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801aea:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801aef:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801af2:	5b                   	pop    %ebx
  801af3:	5e                   	pop    %esi
  801af4:	5f                   	pop    %edi
  801af5:	5d                   	pop    %ebp
  801af6:	c3                   	ret    

00801af7 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801af7:	55                   	push   %ebp
  801af8:	89 e5                	mov    %esp,%ebp
  801afa:	56                   	push   %esi
  801afb:	53                   	push   %ebx
  801afc:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801aff:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b02:	50                   	push   %eax
  801b03:	e8 8c f6 ff ff       	call   801194 <fd_alloc>
  801b08:	83 c4 10             	add    $0x10,%esp
  801b0b:	85 c0                	test   %eax,%eax
  801b0d:	0f 88 2a 01 00 00    	js     801c3d <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b13:	83 ec 04             	sub    $0x4,%esp
  801b16:	68 07 04 00 00       	push   $0x407
  801b1b:	ff 75 f4             	pushl  -0xc(%ebp)
  801b1e:	6a 00                	push   $0x0
  801b20:	e8 7c f1 ff ff       	call   800ca1 <sys_page_alloc>
  801b25:	83 c4 10             	add    $0x10,%esp
  801b28:	85 c0                	test   %eax,%eax
  801b2a:	0f 88 0d 01 00 00    	js     801c3d <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801b30:	83 ec 0c             	sub    $0xc,%esp
  801b33:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b36:	50                   	push   %eax
  801b37:	e8 58 f6 ff ff       	call   801194 <fd_alloc>
  801b3c:	89 c3                	mov    %eax,%ebx
  801b3e:	83 c4 10             	add    $0x10,%esp
  801b41:	85 c0                	test   %eax,%eax
  801b43:	0f 88 e2 00 00 00    	js     801c2b <pipe+0x134>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b49:	83 ec 04             	sub    $0x4,%esp
  801b4c:	68 07 04 00 00       	push   $0x407
  801b51:	ff 75 f0             	pushl  -0x10(%ebp)
  801b54:	6a 00                	push   $0x0
  801b56:	e8 46 f1 ff ff       	call   800ca1 <sys_page_alloc>
  801b5b:	89 c3                	mov    %eax,%ebx
  801b5d:	83 c4 10             	add    $0x10,%esp
  801b60:	85 c0                	test   %eax,%eax
  801b62:	0f 88 c3 00 00 00    	js     801c2b <pipe+0x134>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801b68:	83 ec 0c             	sub    $0xc,%esp
  801b6b:	ff 75 f4             	pushl  -0xc(%ebp)
  801b6e:	e8 0a f6 ff ff       	call   80117d <fd2data>
  801b73:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b75:	83 c4 0c             	add    $0xc,%esp
  801b78:	68 07 04 00 00       	push   $0x407
  801b7d:	50                   	push   %eax
  801b7e:	6a 00                	push   $0x0
  801b80:	e8 1c f1 ff ff       	call   800ca1 <sys_page_alloc>
  801b85:	89 c3                	mov    %eax,%ebx
  801b87:	83 c4 10             	add    $0x10,%esp
  801b8a:	85 c0                	test   %eax,%eax
  801b8c:	0f 88 89 00 00 00    	js     801c1b <pipe+0x124>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b92:	83 ec 0c             	sub    $0xc,%esp
  801b95:	ff 75 f0             	pushl  -0x10(%ebp)
  801b98:	e8 e0 f5 ff ff       	call   80117d <fd2data>
  801b9d:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801ba4:	50                   	push   %eax
  801ba5:	6a 00                	push   $0x0
  801ba7:	56                   	push   %esi
  801ba8:	6a 00                	push   $0x0
  801baa:	e8 35 f1 ff ff       	call   800ce4 <sys_page_map>
  801baf:	89 c3                	mov    %eax,%ebx
  801bb1:	83 c4 20             	add    $0x20,%esp
  801bb4:	85 c0                	test   %eax,%eax
  801bb6:	78 55                	js     801c0d <pipe+0x116>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801bb8:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801bbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bc1:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801bc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bc6:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801bcd:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801bd3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801bd6:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801bd8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801bdb:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801be2:	83 ec 0c             	sub    $0xc,%esp
  801be5:	ff 75 f4             	pushl  -0xc(%ebp)
  801be8:	e8 80 f5 ff ff       	call   80116d <fd2num>
  801bed:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bf0:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801bf2:	83 c4 04             	add    $0x4,%esp
  801bf5:	ff 75 f0             	pushl  -0x10(%ebp)
  801bf8:	e8 70 f5 ff ff       	call   80116d <fd2num>
  801bfd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c00:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801c03:	83 c4 10             	add    $0x10,%esp
  801c06:	b8 00 00 00 00       	mov    $0x0,%eax
  801c0b:	eb 30                	jmp    801c3d <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  801c0d:	83 ec 08             	sub    $0x8,%esp
  801c10:	56                   	push   %esi
  801c11:	6a 00                	push   $0x0
  801c13:	e8 0e f1 ff ff       	call   800d26 <sys_page_unmap>
  801c18:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801c1b:	83 ec 08             	sub    $0x8,%esp
  801c1e:	ff 75 f0             	pushl  -0x10(%ebp)
  801c21:	6a 00                	push   $0x0
  801c23:	e8 fe f0 ff ff       	call   800d26 <sys_page_unmap>
  801c28:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801c2b:	83 ec 08             	sub    $0x8,%esp
  801c2e:	ff 75 f4             	pushl  -0xc(%ebp)
  801c31:	6a 00                	push   $0x0
  801c33:	e8 ee f0 ff ff       	call   800d26 <sys_page_unmap>
  801c38:	83 c4 10             	add    $0x10,%esp
  801c3b:	89 d8                	mov    %ebx,%eax
    err:
	return r;
}
  801c3d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c40:	5b                   	pop    %ebx
  801c41:	5e                   	pop    %esi
  801c42:	5d                   	pop    %ebp
  801c43:	c3                   	ret    

00801c44 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801c44:	55                   	push   %ebp
  801c45:	89 e5                	mov    %esp,%ebp
  801c47:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c4a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c4d:	50                   	push   %eax
  801c4e:	ff 75 08             	pushl  0x8(%ebp)
  801c51:	e8 b2 f5 ff ff       	call   801208 <fd_lookup>
  801c56:	83 c4 10             	add    $0x10,%esp
  801c59:	85 c0                	test   %eax,%eax
  801c5b:	78 18                	js     801c75 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801c5d:	83 ec 0c             	sub    $0xc,%esp
  801c60:	ff 75 f4             	pushl  -0xc(%ebp)
  801c63:	e8 15 f5 ff ff       	call   80117d <fd2data>
	return _pipeisclosed(fd, p);
  801c68:	89 c2                	mov    %eax,%edx
  801c6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c6d:	e8 17 fd ff ff       	call   801989 <_pipeisclosed>
  801c72:	83 c4 10             	add    $0x10,%esp
}
  801c75:	c9                   	leave  
  801c76:	c3                   	ret    

00801c77 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801c77:	55                   	push   %ebp
  801c78:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801c7a:	b8 00 00 00 00       	mov    $0x0,%eax
  801c7f:	5d                   	pop    %ebp
  801c80:	c3                   	ret    

00801c81 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801c81:	55                   	push   %ebp
  801c82:	89 e5                	mov    %esp,%ebp
  801c84:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801c87:	68 e3 27 80 00       	push   $0x8027e3
  801c8c:	ff 75 0c             	pushl  0xc(%ebp)
  801c8f:	e8 9d eb ff ff       	call   800831 <strcpy>
	return 0;
}
  801c94:	b8 00 00 00 00       	mov    $0x0,%eax
  801c99:	c9                   	leave  
  801c9a:	c3                   	ret    

00801c9b <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801c9b:	55                   	push   %ebp
  801c9c:	89 e5                	mov    %esp,%ebp
  801c9e:	57                   	push   %edi
  801c9f:	56                   	push   %esi
  801ca0:	53                   	push   %ebx
  801ca1:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ca7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801cab:	74 45                	je     801cf2 <devcons_write+0x57>
  801cad:	b8 00 00 00 00       	mov    $0x0,%eax
  801cb2:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801cb7:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801cbd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801cc0:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  801cc2:	83 fb 7f             	cmp    $0x7f,%ebx
  801cc5:	76 05                	jbe    801ccc <devcons_write+0x31>
			m = sizeof(buf) - 1;
  801cc7:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801ccc:	83 ec 04             	sub    $0x4,%esp
  801ccf:	53                   	push   %ebx
  801cd0:	03 45 0c             	add    0xc(%ebp),%eax
  801cd3:	50                   	push   %eax
  801cd4:	57                   	push   %edi
  801cd5:	e8 24 ed ff ff       	call   8009fe <memmove>
		sys_cputs(buf, m);
  801cda:	83 c4 08             	add    $0x8,%esp
  801cdd:	53                   	push   %ebx
  801cde:	57                   	push   %edi
  801cdf:	e8 01 ef ff ff       	call   800be5 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ce4:	01 de                	add    %ebx,%esi
  801ce6:	89 f0                	mov    %esi,%eax
  801ce8:	83 c4 10             	add    $0x10,%esp
  801ceb:	3b 75 10             	cmp    0x10(%ebp),%esi
  801cee:	72 cd                	jb     801cbd <devcons_write+0x22>
  801cf0:	eb 05                	jmp    801cf7 <devcons_write+0x5c>
  801cf2:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801cf7:	89 f0                	mov    %esi,%eax
  801cf9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cfc:	5b                   	pop    %ebx
  801cfd:	5e                   	pop    %esi
  801cfe:	5f                   	pop    %edi
  801cff:	5d                   	pop    %ebp
  801d00:	c3                   	ret    

00801d01 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d01:	55                   	push   %ebp
  801d02:	89 e5                	mov    %esp,%ebp
  801d04:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801d07:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d0b:	75 07                	jne    801d14 <devcons_read+0x13>
  801d0d:	eb 23                	jmp    801d32 <devcons_read+0x31>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801d0f:	e8 6e ef ff ff       	call   800c82 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801d14:	e8 ea ee ff ff       	call   800c03 <sys_cgetc>
  801d19:	85 c0                	test   %eax,%eax
  801d1b:	74 f2                	je     801d0f <devcons_read+0xe>
		sys_yield();
	if (c < 0)
  801d1d:	85 c0                	test   %eax,%eax
  801d1f:	78 1d                	js     801d3e <devcons_read+0x3d>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801d21:	83 f8 04             	cmp    $0x4,%eax
  801d24:	74 13                	je     801d39 <devcons_read+0x38>
		return 0;
	*(char*)vbuf = c;
  801d26:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d29:	88 02                	mov    %al,(%edx)
	return 1;
  801d2b:	b8 01 00 00 00       	mov    $0x1,%eax
  801d30:	eb 0c                	jmp    801d3e <devcons_read+0x3d>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801d32:	b8 00 00 00 00       	mov    $0x0,%eax
  801d37:	eb 05                	jmp    801d3e <devcons_read+0x3d>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801d39:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801d3e:	c9                   	leave  
  801d3f:	c3                   	ret    

00801d40 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801d40:	55                   	push   %ebp
  801d41:	89 e5                	mov    %esp,%ebp
  801d43:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801d46:	8b 45 08             	mov    0x8(%ebp),%eax
  801d49:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801d4c:	6a 01                	push   $0x1
  801d4e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d51:	50                   	push   %eax
  801d52:	e8 8e ee ff ff       	call   800be5 <sys_cputs>
}
  801d57:	83 c4 10             	add    $0x10,%esp
  801d5a:	c9                   	leave  
  801d5b:	c3                   	ret    

00801d5c <getchar>:

int
getchar(void)
{
  801d5c:	55                   	push   %ebp
  801d5d:	89 e5                	mov    %esp,%ebp
  801d5f:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801d62:	6a 01                	push   $0x1
  801d64:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d67:	50                   	push   %eax
  801d68:	6a 00                	push   $0x0
  801d6a:	e8 1a f7 ff ff       	call   801489 <read>
	if (r < 0)
  801d6f:	83 c4 10             	add    $0x10,%esp
  801d72:	85 c0                	test   %eax,%eax
  801d74:	78 0f                	js     801d85 <getchar+0x29>
		return r;
	if (r < 1)
  801d76:	85 c0                	test   %eax,%eax
  801d78:	7e 06                	jle    801d80 <getchar+0x24>
		return -E_EOF;
	return c;
  801d7a:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801d7e:	eb 05                	jmp    801d85 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801d80:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801d85:	c9                   	leave  
  801d86:	c3                   	ret    

00801d87 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801d87:	55                   	push   %ebp
  801d88:	89 e5                	mov    %esp,%ebp
  801d8a:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d8d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d90:	50                   	push   %eax
  801d91:	ff 75 08             	pushl  0x8(%ebp)
  801d94:	e8 6f f4 ff ff       	call   801208 <fd_lookup>
  801d99:	83 c4 10             	add    $0x10,%esp
  801d9c:	85 c0                	test   %eax,%eax
  801d9e:	78 11                	js     801db1 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801da0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801da3:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801da9:	39 10                	cmp    %edx,(%eax)
  801dab:	0f 94 c0             	sete   %al
  801dae:	0f b6 c0             	movzbl %al,%eax
}
  801db1:	c9                   	leave  
  801db2:	c3                   	ret    

00801db3 <opencons>:

int
opencons(void)
{
  801db3:	55                   	push   %ebp
  801db4:	89 e5                	mov    %esp,%ebp
  801db6:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801db9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801dbc:	50                   	push   %eax
  801dbd:	e8 d2 f3 ff ff       	call   801194 <fd_alloc>
  801dc2:	83 c4 10             	add    $0x10,%esp
  801dc5:	85 c0                	test   %eax,%eax
  801dc7:	78 3a                	js     801e03 <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801dc9:	83 ec 04             	sub    $0x4,%esp
  801dcc:	68 07 04 00 00       	push   $0x407
  801dd1:	ff 75 f4             	pushl  -0xc(%ebp)
  801dd4:	6a 00                	push   $0x0
  801dd6:	e8 c6 ee ff ff       	call   800ca1 <sys_page_alloc>
  801ddb:	83 c4 10             	add    $0x10,%esp
  801dde:	85 c0                	test   %eax,%eax
  801de0:	78 21                	js     801e03 <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801de2:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801de8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801deb:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801ded:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801df0:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801df7:	83 ec 0c             	sub    $0xc,%esp
  801dfa:	50                   	push   %eax
  801dfb:	e8 6d f3 ff ff       	call   80116d <fd2num>
  801e00:	83 c4 10             	add    $0x10,%esp
}
  801e03:	c9                   	leave  
  801e04:	c3                   	ret    

00801e05 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801e05:	55                   	push   %ebp
  801e06:	89 e5                	mov    %esp,%ebp
  801e08:	53                   	push   %ebx
  801e09:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (_pgfault_handler == 0) {
  801e0c:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801e13:	75 5b                	jne    801e70 <set_pgfault_handler+0x6b>
		// First time through!
		// LAB 4: Your code here.
		void *va = (void *)(UXSTACKTOP - PGSIZE);
		envid_t eid = sys_getenvid();
  801e15:	e8 49 ee ff ff       	call   800c63 <sys_getenvid>
  801e1a:	89 c3                	mov    %eax,%ebx
		r = sys_page_alloc(eid,va,PTE_P | PTE_U | PTE_W);
  801e1c:	83 ec 04             	sub    $0x4,%esp
  801e1f:	6a 07                	push   $0x7
  801e21:	68 00 f0 bf ee       	push   $0xeebff000
  801e26:	50                   	push   %eax
  801e27:	e8 75 ee ff ff       	call   800ca1 <sys_page_alloc>
		if(r<0) panic("set_pgfault_handler\n");
  801e2c:	83 c4 10             	add    $0x10,%esp
  801e2f:	85 c0                	test   %eax,%eax
  801e31:	79 14                	jns    801e47 <set_pgfault_handler+0x42>
  801e33:	83 ec 04             	sub    $0x4,%esp
  801e36:	68 ef 27 80 00       	push   $0x8027ef
  801e3b:	6a 23                	push   $0x23
  801e3d:	68 04 28 80 00       	push   $0x802804
  801e42:	e8 2d e3 ff ff       	call   800174 <_panic>
		r = sys_env_set_pgfault_upcall(eid,_pgfault_upcall);
  801e47:	83 ec 08             	sub    $0x8,%esp
  801e4a:	68 7d 1e 80 00       	push   $0x801e7d
  801e4f:	53                   	push   %ebx
  801e50:	e8 97 ef ff ff       	call   800dec <sys_env_set_pgfault_upcall>
		if(r<0) panic("set_pgfault_handler\n");
  801e55:	83 c4 10             	add    $0x10,%esp
  801e58:	85 c0                	test   %eax,%eax
  801e5a:	79 14                	jns    801e70 <set_pgfault_handler+0x6b>
  801e5c:	83 ec 04             	sub    $0x4,%esp
  801e5f:	68 ef 27 80 00       	push   $0x8027ef
  801e64:	6a 25                	push   $0x25
  801e66:	68 04 28 80 00       	push   $0x802804
  801e6b:	e8 04 e3 ff ff       	call   800174 <_panic>
		// panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801e70:	8b 45 08             	mov    0x8(%ebp),%eax
  801e73:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801e78:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e7b:	c9                   	leave  
  801e7c:	c3                   	ret    

00801e7d <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801e7d:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801e7e:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801e83:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801e85:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl %esp,%ebx
  801e88:	89 e3                	mov    %esp,%ebx
	movl 40(%esp),%eax 	// esp from utf_fault_va to utf_regs(end)
  801e8a:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl 48(%esp),%esp 	// 
  801e8e:	8b 64 24 30          	mov    0x30(%esp),%esp
	pushl %eax
  801e92:	50                   	push   %eax
 
 
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	movl %ebx,%esp
  801e93:	89 dc                	mov    %ebx,%esp
	subl $4,48(%esp)
  801e95:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	popl %eax
  801e9a:	58                   	pop    %eax
	popl %eax
  801e9b:	58                   	pop    %eax
	popal
  801e9c:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	add $4,%esp
  801e9d:	83 c4 04             	add    $0x4,%esp
	popfl
  801ea0:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  801ea1:	5c                   	pop    %esp
 
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801ea2:	c3                   	ret    

00801ea3 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801ea3:	55                   	push   %ebp
  801ea4:	89 e5                	mov    %esp,%ebp
  801ea6:	56                   	push   %esi
  801ea7:	53                   	push   %ebx
  801ea8:	8b 75 08             	mov    0x8(%ebp),%esi
  801eab:	8b 45 0c             	mov    0xc(%ebp),%eax
  801eae:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");
	int r;
    if (pg != NULL) {
  801eb1:	85 c0                	test   %eax,%eax
  801eb3:	74 0e                	je     801ec3 <ipc_recv+0x20>
        r = sys_ipc_recv(pg);
  801eb5:	83 ec 0c             	sub    $0xc,%esp
  801eb8:	50                   	push   %eax
  801eb9:	e8 93 ef ff ff       	call   800e51 <sys_ipc_recv>
  801ebe:	83 c4 10             	add    $0x10,%esp
  801ec1:	eb 10                	jmp    801ed3 <ipc_recv+0x30>
    } else {
        r = sys_ipc_recv((void *) UTOP);
  801ec3:	83 ec 0c             	sub    $0xc,%esp
  801ec6:	68 00 00 c0 ee       	push   $0xeec00000
  801ecb:	e8 81 ef ff ff       	call   800e51 <sys_ipc_recv>
  801ed0:	83 c4 10             	add    $0x10,%esp
    }
    if (r < 0) {
  801ed3:	85 c0                	test   %eax,%eax
  801ed5:	79 16                	jns    801eed <ipc_recv+0x4a>
        // failed
        if (from_env_store != NULL) *from_env_store = 0;
  801ed7:	85 f6                	test   %esi,%esi
  801ed9:	74 06                	je     801ee1 <ipc_recv+0x3e>
  801edb:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        if (perm_store != NULL) *perm_store = 0;
  801ee1:	85 db                	test   %ebx,%ebx
  801ee3:	74 2c                	je     801f11 <ipc_recv+0x6e>
  801ee5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801eeb:	eb 24                	jmp    801f11 <ipc_recv+0x6e>
        return r;
    } else {
        if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801eed:	85 f6                	test   %esi,%esi
  801eef:	74 0a                	je     801efb <ipc_recv+0x58>
  801ef1:	a1 08 40 80 00       	mov    0x804008,%eax
  801ef6:	8b 40 74             	mov    0x74(%eax),%eax
  801ef9:	89 06                	mov    %eax,(%esi)
        if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801efb:	85 db                	test   %ebx,%ebx
  801efd:	74 0a                	je     801f09 <ipc_recv+0x66>
  801eff:	a1 08 40 80 00       	mov    0x804008,%eax
  801f04:	8b 40 78             	mov    0x78(%eax),%eax
  801f07:	89 03                	mov    %eax,(%ebx)
        return thisenv->env_ipc_value;
  801f09:	a1 08 40 80 00       	mov    0x804008,%eax
  801f0e:	8b 40 70             	mov    0x70(%eax),%eax
    }
 
	return 0;
}
  801f11:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f14:	5b                   	pop    %ebx
  801f15:	5e                   	pop    %esi
  801f16:	5d                   	pop    %ebp
  801f17:	c3                   	ret    

00801f18 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f18:	55                   	push   %ebp
  801f19:	89 e5                	mov    %esp,%ebp
  801f1b:	57                   	push   %edi
  801f1c:	56                   	push   %esi
  801f1d:	53                   	push   %ebx
  801f1e:	83 ec 0c             	sub    $0xc,%esp
  801f21:	8b 75 10             	mov    0x10(%ebp),%esi
  801f24:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");
	int r;
    if (pg == NULL) pg = (void *)UTOP;
  801f27:	85 f6                	test   %esi,%esi
  801f29:	75 05                	jne    801f30 <ipc_send+0x18>
  801f2b:	be 00 00 c0 ee       	mov    $0xeec00000,%esi
    do {
        r = sys_ipc_try_send(to_env, val, pg, perm);
  801f30:	57                   	push   %edi
  801f31:	56                   	push   %esi
  801f32:	ff 75 0c             	pushl  0xc(%ebp)
  801f35:	ff 75 08             	pushl  0x8(%ebp)
  801f38:	e8 f1 ee ff ff       	call   800e2e <sys_ipc_try_send>
  801f3d:	89 c3                	mov    %eax,%ebx
        if (r < 0 && r != -E_IPC_NOT_RECV) panic("ipc send failed: %e", r);
  801f3f:	83 c4 10             	add    $0x10,%esp
  801f42:	85 c0                	test   %eax,%eax
  801f44:	79 17                	jns    801f5d <ipc_send+0x45>
  801f46:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f49:	74 1d                	je     801f68 <ipc_send+0x50>
  801f4b:	50                   	push   %eax
  801f4c:	68 12 28 80 00       	push   $0x802812
  801f51:	6a 40                	push   $0x40
  801f53:	68 26 28 80 00       	push   $0x802826
  801f58:	e8 17 e2 ff ff       	call   800174 <_panic>
        sys_yield();
  801f5d:	e8 20 ed ff ff       	call   800c82 <sys_yield>
    } while (r != 0);
  801f62:	85 db                	test   %ebx,%ebx
  801f64:	75 ca                	jne    801f30 <ipc_send+0x18>
  801f66:	eb 07                	jmp    801f6f <ipc_send+0x57>
	int r;
    if (pg == NULL) pg = (void *)UTOP;
    do {
        r = sys_ipc_try_send(to_env, val, pg, perm);
        if (r < 0 && r != -E_IPC_NOT_RECV) panic("ipc send failed: %e", r);
        sys_yield();
  801f68:	e8 15 ed ff ff       	call   800c82 <sys_yield>
  801f6d:	eb c1                	jmp    801f30 <ipc_send+0x18>
    } while (r != 0);
}
  801f6f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f72:	5b                   	pop    %ebx
  801f73:	5e                   	pop    %esi
  801f74:	5f                   	pop    %edi
  801f75:	5d                   	pop    %ebp
  801f76:	c3                   	ret    

00801f77 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f77:	55                   	push   %ebp
  801f78:	89 e5                	mov    %esp,%ebp
  801f7a:	53                   	push   %ebx
  801f7b:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801f7e:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  801f83:	39 c1                	cmp    %eax,%ecx
  801f85:	74 21                	je     801fa8 <ipc_find_env+0x31>
  801f87:	ba 01 00 00 00       	mov    $0x1,%edx
  801f8c:	8d 1c 95 00 00 00 00 	lea    0x0(,%edx,4),%ebx
  801f93:	89 d0                	mov    %edx,%eax
  801f95:	c1 e0 07             	shl    $0x7,%eax
  801f98:	29 d8                	sub    %ebx,%eax
  801f9a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801f9f:	8b 40 50             	mov    0x50(%eax),%eax
  801fa2:	39 c8                	cmp    %ecx,%eax
  801fa4:	75 1b                	jne    801fc1 <ipc_find_env+0x4a>
  801fa6:	eb 05                	jmp    801fad <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801fa8:	ba 00 00 00 00       	mov    $0x0,%edx
		if (envs[i].env_type == type)
			return envs[i].env_id;
  801fad:	8d 04 95 00 00 00 00 	lea    0x0(,%edx,4),%eax
  801fb4:	c1 e2 07             	shl    $0x7,%edx
  801fb7:	29 c2                	sub    %eax,%edx
  801fb9:	8b 82 48 00 c0 ee    	mov    -0x113fffb8(%edx),%eax
  801fbf:	eb 0e                	jmp    801fcf <ipc_find_env+0x58>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801fc1:	42                   	inc    %edx
  801fc2:	81 fa 00 04 00 00    	cmp    $0x400,%edx
  801fc8:	75 c2                	jne    801f8c <ipc_find_env+0x15>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801fca:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801fcf:	5b                   	pop    %ebx
  801fd0:	5d                   	pop    %ebp
  801fd1:	c3                   	ret    

00801fd2 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801fd2:	55                   	push   %ebp
  801fd3:	89 e5                	mov    %esp,%ebp
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fd5:	8b 45 08             	mov    0x8(%ebp),%eax
  801fd8:	c1 e8 16             	shr    $0x16,%eax
  801fdb:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801fe2:	a8 01                	test   $0x1,%al
  801fe4:	74 21                	je     802007 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801fe6:	8b 45 08             	mov    0x8(%ebp),%eax
  801fe9:	c1 e8 0c             	shr    $0xc,%eax
  801fec:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801ff3:	a8 01                	test   $0x1,%al
  801ff5:	74 17                	je     80200e <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801ff7:	c1 e8 0c             	shr    $0xc,%eax
  801ffa:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  802001:	ef 
  802002:	0f b7 c0             	movzwl %ax,%eax
  802005:	eb 0c                	jmp    802013 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  802007:	b8 00 00 00 00       	mov    $0x0,%eax
  80200c:	eb 05                	jmp    802013 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  80200e:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  802013:	5d                   	pop    %ebp
  802014:	c3                   	ret    
  802015:	66 90                	xchg   %ax,%ax
  802017:	90                   	nop

00802018 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  802018:	55                   	push   %ebp
  802019:	57                   	push   %edi
  80201a:	56                   	push   %esi
  80201b:	53                   	push   %ebx
  80201c:	83 ec 1c             	sub    $0x1c,%esp
  80201f:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  802023:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802027:	8b 7c 24 38          	mov    0x38(%esp),%edi
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  80202b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80202f:	89 ca                	mov    %ecx,%edx
  const DWunion dd = {.ll = d};
  802031:	89 f8                	mov    %edi,%eax
  802033:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802037:	85 f6                	test   %esi,%esi
  802039:	75 2d                	jne    802068 <__udivdi3+0x50>
    {
      if (d0 > n1)
  80203b:	39 cf                	cmp    %ecx,%edi
  80203d:	77 65                	ja     8020a4 <__udivdi3+0x8c>
  80203f:	89 fd                	mov    %edi,%ebp
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802041:	85 ff                	test   %edi,%edi
  802043:	75 0b                	jne    802050 <__udivdi3+0x38>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802045:	b8 01 00 00 00       	mov    $0x1,%eax
  80204a:	31 d2                	xor    %edx,%edx
  80204c:	f7 f7                	div    %edi
  80204e:	89 c5                	mov    %eax,%ebp

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802050:	31 d2                	xor    %edx,%edx
  802052:	89 c8                	mov    %ecx,%eax
  802054:	f7 f5                	div    %ebp
  802056:	89 c1                	mov    %eax,%ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802058:	89 d8                	mov    %ebx,%eax
  80205a:	f7 f5                	div    %ebp
  80205c:	89 cf                	mov    %ecx,%edi
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80205e:	89 fa                	mov    %edi,%edx
  802060:	83 c4 1c             	add    $0x1c,%esp
  802063:	5b                   	pop    %ebx
  802064:	5e                   	pop    %esi
  802065:	5f                   	pop    %edi
  802066:	5d                   	pop    %ebp
  802067:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802068:	39 ce                	cmp    %ecx,%esi
  80206a:	77 28                	ja     802094 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  80206c:	0f bd fe             	bsr    %esi,%edi
	  if (bm == 0)
  80206f:	83 f7 1f             	xor    $0x1f,%edi
  802072:	75 40                	jne    8020b4 <__udivdi3+0x9c>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802074:	39 ce                	cmp    %ecx,%esi
  802076:	72 0a                	jb     802082 <__udivdi3+0x6a>
  802078:	3b 44 24 08          	cmp    0x8(%esp),%eax
  80207c:	0f 87 9e 00 00 00    	ja     802120 <__udivdi3+0x108>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802082:	b8 01 00 00 00       	mov    $0x1,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802087:	89 fa                	mov    %edi,%edx
  802089:	83 c4 1c             	add    $0x1c,%esp
  80208c:	5b                   	pop    %ebx
  80208d:	5e                   	pop    %esi
  80208e:	5f                   	pop    %edi
  80208f:	5d                   	pop    %ebp
  802090:	c3                   	ret    
  802091:	8d 76 00             	lea    0x0(%esi),%esi
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802094:	31 ff                	xor    %edi,%edi
  802096:	31 c0                	xor    %eax,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802098:	89 fa                	mov    %edi,%edx
  80209a:	83 c4 1c             	add    $0x1c,%esp
  80209d:	5b                   	pop    %ebx
  80209e:	5e                   	pop    %esi
  80209f:	5f                   	pop    %edi
  8020a0:	5d                   	pop    %ebp
  8020a1:	c3                   	ret    
  8020a2:	66 90                	xchg   %ax,%ax
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8020a4:	89 d8                	mov    %ebx,%eax
  8020a6:	f7 f7                	div    %edi
  8020a8:	31 ff                	xor    %edi,%edi
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8020aa:	89 fa                	mov    %edi,%edx
  8020ac:	83 c4 1c             	add    $0x1c,%esp
  8020af:	5b                   	pop    %ebx
  8020b0:	5e                   	pop    %esi
  8020b1:	5f                   	pop    %edi
  8020b2:	5d                   	pop    %ebp
  8020b3:	c3                   	ret    
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8020b4:	bd 20 00 00 00       	mov    $0x20,%ebp
  8020b9:	89 eb                	mov    %ebp,%ebx
  8020bb:	29 fb                	sub    %edi,%ebx

	      d1 = (d1 << bm) | (d0 >> b);
  8020bd:	89 f9                	mov    %edi,%ecx
  8020bf:	d3 e6                	shl    %cl,%esi
  8020c1:	89 c5                	mov    %eax,%ebp
  8020c3:	88 d9                	mov    %bl,%cl
  8020c5:	d3 ed                	shr    %cl,%ebp
  8020c7:	89 e9                	mov    %ebp,%ecx
  8020c9:	09 f1                	or     %esi,%ecx
  8020cb:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
	      d0 = d0 << bm;
  8020cf:	89 f9                	mov    %edi,%ecx
  8020d1:	d3 e0                	shl    %cl,%eax
  8020d3:	89 c5                	mov    %eax,%ebp
	      n2 = n1 >> b;
  8020d5:	89 d6                	mov    %edx,%esi
  8020d7:	88 d9                	mov    %bl,%cl
  8020d9:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
  8020db:	89 f9                	mov    %edi,%ecx
  8020dd:	d3 e2                	shl    %cl,%edx
  8020df:	8b 44 24 08          	mov    0x8(%esp),%eax
  8020e3:	88 d9                	mov    %bl,%cl
  8020e5:	d3 e8                	shr    %cl,%eax
  8020e7:	09 c2                	or     %eax,%edx
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8020e9:	89 d0                	mov    %edx,%eax
  8020eb:	89 f2                	mov    %esi,%edx
  8020ed:	f7 74 24 0c          	divl   0xc(%esp)
  8020f1:	89 d6                	mov    %edx,%esi
  8020f3:	89 c3                	mov    %eax,%ebx
	      umul_ppmm (m1, m0, q0, d0);
  8020f5:	f7 e5                	mul    %ebp

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8020f7:	39 d6                	cmp    %edx,%esi
  8020f9:	72 19                	jb     802114 <__udivdi3+0xfc>
  8020fb:	74 0b                	je     802108 <__udivdi3+0xf0>
  8020fd:	89 d8                	mov    %ebx,%eax
  8020ff:	31 ff                	xor    %edi,%edi
  802101:	e9 58 ff ff ff       	jmp    80205e <__udivdi3+0x46>
  802106:	66 90                	xchg   %ax,%ax
  802108:	8b 54 24 08          	mov    0x8(%esp),%edx
  80210c:	89 f9                	mov    %edi,%ecx
  80210e:	d3 e2                	shl    %cl,%edx
  802110:	39 c2                	cmp    %eax,%edx
  802112:	73 e9                	jae    8020fd <__udivdi3+0xe5>
  802114:	8d 43 ff             	lea    -0x1(%ebx),%eax
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802117:	31 ff                	xor    %edi,%edi
  802119:	e9 40 ff ff ff       	jmp    80205e <__udivdi3+0x46>
  80211e:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802120:	31 c0                	xor    %eax,%eax
  802122:	e9 37 ff ff ff       	jmp    80205e <__udivdi3+0x46>
  802127:	90                   	nop

00802128 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  802128:	55                   	push   %ebp
  802129:	57                   	push   %edi
  80212a:	56                   	push   %esi
  80212b:	53                   	push   %ebx
  80212c:	83 ec 1c             	sub    $0x1c,%esp
  80212f:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  802133:	8b 74 24 34          	mov    0x34(%esp),%esi
  802137:	8b 7c 24 38          	mov    0x38(%esp),%edi
  80213b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80213f:	89 44 24 0c          	mov    %eax,0xc(%esp)
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  802143:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802147:	89 f3                	mov    %esi,%ebx
  const DWunion dd = {.ll = d};
  802149:	89 fa                	mov    %edi,%edx
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  80214b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  n1 = nn.s.high;
  80214f:	89 34 24             	mov    %esi,(%esp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802152:	85 c0                	test   %eax,%eax
  802154:	75 1a                	jne    802170 <__umoddi3+0x48>
    {
      if (d0 > n1)
  802156:	39 f7                	cmp    %esi,%edi
  802158:	0f 86 a2 00 00 00    	jbe    802200 <__umoddi3+0xd8>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80215e:	89 c8                	mov    %ecx,%eax
  802160:	89 f2                	mov    %esi,%edx
  802162:	f7 f7                	div    %edi
  802164:	89 d0                	mov    %edx,%eax

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  802166:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802168:	83 c4 1c             	add    $0x1c,%esp
  80216b:	5b                   	pop    %ebx
  80216c:	5e                   	pop    %esi
  80216d:	5f                   	pop    %edi
  80216e:	5d                   	pop    %ebp
  80216f:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802170:	39 f0                	cmp    %esi,%eax
  802172:	0f 87 ac 00 00 00    	ja     802224 <__umoddi3+0xfc>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802178:	0f bd e8             	bsr    %eax,%ebp
	  if (bm == 0)
  80217b:	83 f5 1f             	xor    $0x1f,%ebp
  80217e:	0f 84 ac 00 00 00    	je     802230 <__umoddi3+0x108>
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802184:	bf 20 00 00 00       	mov    $0x20,%edi
  802189:	29 ef                	sub    %ebp,%edi
  80218b:	89 fe                	mov    %edi,%esi
  80218d:	89 7c 24 0c          	mov    %edi,0xc(%esp)

	      d1 = (d1 << bm) | (d0 >> b);
  802191:	89 e9                	mov    %ebp,%ecx
  802193:	d3 e0                	shl    %cl,%eax
  802195:	89 d7                	mov    %edx,%edi
  802197:	89 f1                	mov    %esi,%ecx
  802199:	d3 ef                	shr    %cl,%edi
  80219b:	09 c7                	or     %eax,%edi
	      d0 = d0 << bm;
  80219d:	89 e9                	mov    %ebp,%ecx
  80219f:	d3 e2                	shl    %cl,%edx
  8021a1:	89 14 24             	mov    %edx,(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8021a4:	89 d8                	mov    %ebx,%eax
  8021a6:	d3 e0                	shl    %cl,%eax
  8021a8:	89 c2                	mov    %eax,%edx
	      n0 = n0 << bm;
  8021aa:	8b 44 24 08          	mov    0x8(%esp),%eax
  8021ae:	d3 e0                	shl    %cl,%eax
  8021b0:	89 44 24 04          	mov    %eax,0x4(%esp)

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8021b4:	8b 44 24 08          	mov    0x8(%esp),%eax
  8021b8:	89 f1                	mov    %esi,%ecx
  8021ba:	d3 e8                	shr    %cl,%eax
  8021bc:	09 d0                	or     %edx,%eax
  8021be:	d3 eb                	shr    %cl,%ebx
  8021c0:	89 da                	mov    %ebx,%edx
  8021c2:	f7 f7                	div    %edi
  8021c4:	89 d3                	mov    %edx,%ebx
	      umul_ppmm (m1, m0, q0, d0);
  8021c6:	f7 24 24             	mull   (%esp)
  8021c9:	89 c6                	mov    %eax,%esi
  8021cb:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8021cd:	39 d3                	cmp    %edx,%ebx
  8021cf:	0f 82 87 00 00 00    	jb     80225c <__umoddi3+0x134>
  8021d5:	0f 84 91 00 00 00    	je     80226c <__umoddi3+0x144>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  8021db:	8b 54 24 04          	mov    0x4(%esp),%edx
  8021df:	29 f2                	sub    %esi,%edx
  8021e1:	19 cb                	sbb    %ecx,%ebx
		  rr.s.low = (n1 << b) | (n0 >> bm);
  8021e3:	89 d8                	mov    %ebx,%eax
  8021e5:	8a 4c 24 0c          	mov    0xc(%esp),%cl
  8021e9:	d3 e0                	shl    %cl,%eax
  8021eb:	89 e9                	mov    %ebp,%ecx
  8021ed:	d3 ea                	shr    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  8021ef:	09 d0                	or     %edx,%eax
  8021f1:	89 e9                	mov    %ebp,%ecx
  8021f3:	d3 eb                	shr    %cl,%ebx
  8021f5:	89 da                	mov    %ebx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8021f7:	83 c4 1c             	add    $0x1c,%esp
  8021fa:	5b                   	pop    %ebx
  8021fb:	5e                   	pop    %esi
  8021fc:	5f                   	pop    %edi
  8021fd:	5d                   	pop    %ebp
  8021fe:	c3                   	ret    
  8021ff:	90                   	nop
  802200:	89 fd                	mov    %edi,%ebp
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802202:	85 ff                	test   %edi,%edi
  802204:	75 0b                	jne    802211 <__umoddi3+0xe9>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802206:	b8 01 00 00 00       	mov    $0x1,%eax
  80220b:	31 d2                	xor    %edx,%edx
  80220d:	f7 f7                	div    %edi
  80220f:	89 c5                	mov    %eax,%ebp

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802211:	89 f0                	mov    %esi,%eax
  802213:	31 d2                	xor    %edx,%edx
  802215:	f7 f5                	div    %ebp
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802217:	89 c8                	mov    %ecx,%eax
  802219:	f7 f5                	div    %ebp
  80221b:	89 d0                	mov    %edx,%eax
  80221d:	e9 44 ff ff ff       	jmp    802166 <__umoddi3+0x3e>
  802222:	66 90                	xchg   %ax,%ax
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  802224:	89 c8                	mov    %ecx,%eax
  802226:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802228:	83 c4 1c             	add    $0x1c,%esp
  80222b:	5b                   	pop    %ebx
  80222c:	5e                   	pop    %esi
  80222d:	5f                   	pop    %edi
  80222e:	5d                   	pop    %ebp
  80222f:	c3                   	ret    

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802230:	3b 04 24             	cmp    (%esp),%eax
  802233:	72 06                	jb     80223b <__umoddi3+0x113>
  802235:	3b 7c 24 04          	cmp    0x4(%esp),%edi
  802239:	77 0f                	ja     80224a <__umoddi3+0x122>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  80223b:	89 f2                	mov    %esi,%edx
  80223d:	29 f9                	sub    %edi,%ecx
  80223f:	1b 54 24 0c          	sbb    0xc(%esp),%edx
  802243:	89 14 24             	mov    %edx,(%esp)
  802246:	89 4c 24 04          	mov    %ecx,0x4(%esp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  80224a:	8b 44 24 04          	mov    0x4(%esp),%eax
  80224e:	8b 14 24             	mov    (%esp),%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802251:	83 c4 1c             	add    $0x1c,%esp
  802254:	5b                   	pop    %ebx
  802255:	5e                   	pop    %esi
  802256:	5f                   	pop    %edi
  802257:	5d                   	pop    %ebp
  802258:	c3                   	ret    
  802259:	8d 76 00             	lea    0x0(%esi),%esi
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  80225c:	2b 04 24             	sub    (%esp),%eax
  80225f:	19 fa                	sbb    %edi,%edx
  802261:	89 d1                	mov    %edx,%ecx
  802263:	89 c6                	mov    %eax,%esi
  802265:	e9 71 ff ff ff       	jmp    8021db <__umoddi3+0xb3>
  80226a:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80226c:	39 44 24 04          	cmp    %eax,0x4(%esp)
  802270:	72 ea                	jb     80225c <__umoddi3+0x134>
  802272:	89 d9                	mov    %ebx,%ecx
  802274:	e9 62 ff ff ff       	jmp    8021db <__umoddi3+0xb3>
