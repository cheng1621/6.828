
obj/user/cat.debug:     file format elf32-i386


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
  80002c:	e8 08 01 00 00       	call   800139 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <cat>:

char buf[8192];

void
cat(int f, char *s)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	8b 75 08             	mov    0x8(%ebp),%esi
	long n;
	int r;

	while ((n = read(f, buf, (long)sizeof(buf))) > 0)
  80003b:	eb 2f                	jmp    80006c <cat+0x39>
		if ((r = write(1, buf, n)) != n)
  80003d:	83 ec 04             	sub    $0x4,%esp
  800040:	53                   	push   %ebx
  800041:	68 20 40 80 00       	push   $0x804020
  800046:	6a 01                	push   $0x1
  800048:	e8 6b 12 00 00       	call   8012b8 <write>
  80004d:	83 c4 10             	add    $0x10,%esp
  800050:	39 c3                	cmp    %eax,%ebx
  800052:	74 18                	je     80006c <cat+0x39>
			panic("write error copying %s: %e", s, r);
  800054:	83 ec 0c             	sub    $0xc,%esp
  800057:	50                   	push   %eax
  800058:	ff 75 0c             	pushl  0xc(%ebp)
  80005b:	68 40 20 80 00       	push   $0x802040
  800060:	6a 0d                	push   $0xd
  800062:	68 5b 20 80 00       	push   $0x80205b
  800067:	e8 36 01 00 00       	call   8001a2 <_panic>
cat(int f, char *s)
{
	long n;
	int r;

	while ((n = read(f, buf, (long)sizeof(buf))) > 0)
  80006c:	83 ec 04             	sub    $0x4,%esp
  80006f:	68 00 20 00 00       	push   $0x2000
  800074:	68 20 40 80 00       	push   $0x804020
  800079:	56                   	push   %esi
  80007a:	e8 5d 11 00 00       	call   8011dc <read>
  80007f:	89 c3                	mov    %eax,%ebx
  800081:	83 c4 10             	add    $0x10,%esp
  800084:	85 c0                	test   %eax,%eax
  800086:	7f b5                	jg     80003d <cat+0xa>
		if ((r = write(1, buf, n)) != n)
			panic("write error copying %s: %e", s, r);
	if (n < 0)
  800088:	85 c0                	test   %eax,%eax
  80008a:	79 18                	jns    8000a4 <cat+0x71>
		panic("error reading %s: %e", s, n);
  80008c:	83 ec 0c             	sub    $0xc,%esp
  80008f:	50                   	push   %eax
  800090:	ff 75 0c             	pushl  0xc(%ebp)
  800093:	68 66 20 80 00       	push   $0x802066
  800098:	6a 0f                	push   $0xf
  80009a:	68 5b 20 80 00       	push   $0x80205b
  80009f:	e8 fe 00 00 00       	call   8001a2 <_panic>
}
  8000a4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000a7:	5b                   	pop    %ebx
  8000a8:	5e                   	pop    %esi
  8000a9:	5d                   	pop    %ebp
  8000aa:	c3                   	ret    

008000ab <umain>:

void
umain(int argc, char **argv)
{
  8000ab:	55                   	push   %ebp
  8000ac:	89 e5                	mov    %esp,%ebp
  8000ae:	57                   	push   %edi
  8000af:	56                   	push   %esi
  8000b0:	53                   	push   %ebx
  8000b1:	83 ec 0c             	sub    $0xc,%esp
  8000b4:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int f, i;

	binaryname = "cat";
  8000b7:	c7 05 00 30 80 00 7b 	movl   $0x80207b,0x803000
  8000be:	20 80 00 
	if (argc == 1)
  8000c1:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
  8000c5:	74 0d                	je     8000d4 <umain+0x29>
		cat(0, "<stdin>");
	else
		for (i = 1; i < argc; i++) {
  8000c7:	bb 01 00 00 00       	mov    $0x1,%ebx
  8000cc:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
  8000d0:	7f 16                	jg     8000e8 <umain+0x3d>
  8000d2:	eb 5d                	jmp    800131 <umain+0x86>
{
	int f, i;

	binaryname = "cat";
	if (argc == 1)
		cat(0, "<stdin>");
  8000d4:	83 ec 08             	sub    $0x8,%esp
  8000d7:	68 7f 20 80 00       	push   $0x80207f
  8000dc:	6a 00                	push   $0x0
  8000de:	e8 50 ff ff ff       	call   800033 <cat>
  8000e3:	83 c4 10             	add    $0x10,%esp
  8000e6:	eb 49                	jmp    800131 <umain+0x86>
	else
		for (i = 1; i < argc; i++) {
			f = open(argv[i], O_RDONLY);
  8000e8:	83 ec 08             	sub    $0x8,%esp
  8000eb:	6a 00                	push   $0x0
  8000ed:	ff 34 9f             	pushl  (%edi,%ebx,4)
  8000f0:	e8 e8 14 00 00       	call   8015dd <open>
  8000f5:	89 c6                	mov    %eax,%esi
			if (f < 0)
  8000f7:	83 c4 10             	add    $0x10,%esp
  8000fa:	85 c0                	test   %eax,%eax
  8000fc:	79 16                	jns    800114 <umain+0x69>
				printf("can't open %s: %e\n", argv[i], f);
  8000fe:	83 ec 04             	sub    $0x4,%esp
  800101:	50                   	push   %eax
  800102:	ff 34 9f             	pushl  (%edi,%ebx,4)
  800105:	68 87 20 80 00       	push   $0x802087
  80010a:	e8 50 16 00 00       	call   80175f <printf>
  80010f:	83 c4 10             	add    $0x10,%esp
  800112:	eb 17                	jmp    80012b <umain+0x80>
			else {
				cat(f, argv[i]);
  800114:	83 ec 08             	sub    $0x8,%esp
  800117:	ff 34 9f             	pushl  (%edi,%ebx,4)
  80011a:	50                   	push   %eax
  80011b:	e8 13 ff ff ff       	call   800033 <cat>
				close(f);
  800120:	89 34 24             	mov    %esi,(%esp)
  800123:	e8 7c 0f 00 00       	call   8010a4 <close>
  800128:	83 c4 10             	add    $0x10,%esp

	binaryname = "cat";
	if (argc == 1)
		cat(0, "<stdin>");
	else
		for (i = 1; i < argc; i++) {
  80012b:	43                   	inc    %ebx
  80012c:	39 5d 08             	cmp    %ebx,0x8(%ebp)
  80012f:	75 b7                	jne    8000e8 <umain+0x3d>
			else {
				cat(f, argv[i]);
				close(f);
			}
		}
}
  800131:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800134:	5b                   	pop    %ebx
  800135:	5e                   	pop    %esi
  800136:	5f                   	pop    %edi
  800137:	5d                   	pop    %ebp
  800138:	c3                   	ret    

00800139 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800139:	55                   	push   %ebp
  80013a:	89 e5                	mov    %esp,%ebp
  80013c:	56                   	push   %esi
  80013d:	53                   	push   %ebx
  80013e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800141:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800144:	e8 48 0b 00 00       	call   800c91 <sys_getenvid>
  800149:	25 ff 03 00 00       	and    $0x3ff,%eax
  80014e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800155:	c1 e0 07             	shl    $0x7,%eax
  800158:	29 d0                	sub    %edx,%eax
  80015a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80015f:	a3 20 60 80 00       	mov    %eax,0x806020

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800164:	85 db                	test   %ebx,%ebx
  800166:	7e 07                	jle    80016f <libmain+0x36>
		binaryname = argv[0];
  800168:	8b 06                	mov    (%esi),%eax
  80016a:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80016f:	83 ec 08             	sub    $0x8,%esp
  800172:	56                   	push   %esi
  800173:	53                   	push   %ebx
  800174:	e8 32 ff ff ff       	call   8000ab <umain>

	// exit gracefully
	exit();
  800179:	e8 0a 00 00 00       	call   800188 <exit>
}
  80017e:	83 c4 10             	add    $0x10,%esp
  800181:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800184:	5b                   	pop    %ebx
  800185:	5e                   	pop    %esi
  800186:	5d                   	pop    %ebp
  800187:	c3                   	ret    

00800188 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800188:	55                   	push   %ebp
  800189:	89 e5                	mov    %esp,%ebp
  80018b:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80018e:	e8 3c 0f 00 00       	call   8010cf <close_all>
	sys_env_destroy(0);
  800193:	83 ec 0c             	sub    $0xc,%esp
  800196:	6a 00                	push   $0x0
  800198:	e8 b3 0a 00 00       	call   800c50 <sys_env_destroy>
}
  80019d:	83 c4 10             	add    $0x10,%esp
  8001a0:	c9                   	leave  
  8001a1:	c3                   	ret    

008001a2 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8001a2:	55                   	push   %ebp
  8001a3:	89 e5                	mov    %esp,%ebp
  8001a5:	56                   	push   %esi
  8001a6:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8001a7:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001aa:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8001b0:	e8 dc 0a 00 00       	call   800c91 <sys_getenvid>
  8001b5:	83 ec 0c             	sub    $0xc,%esp
  8001b8:	ff 75 0c             	pushl  0xc(%ebp)
  8001bb:	ff 75 08             	pushl  0x8(%ebp)
  8001be:	56                   	push   %esi
  8001bf:	50                   	push   %eax
  8001c0:	68 a4 20 80 00       	push   $0x8020a4
  8001c5:	e8 b0 00 00 00       	call   80027a <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001ca:	83 c4 18             	add    $0x18,%esp
  8001cd:	53                   	push   %ebx
  8001ce:	ff 75 10             	pushl  0x10(%ebp)
  8001d1:	e8 53 00 00 00       	call   800229 <vcprintf>
	cprintf("\n");
  8001d6:	c7 04 24 b4 24 80 00 	movl   $0x8024b4,(%esp)
  8001dd:	e8 98 00 00 00       	call   80027a <cprintf>
  8001e2:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001e5:	cc                   	int3   
  8001e6:	eb fd                	jmp    8001e5 <_panic+0x43>

008001e8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001e8:	55                   	push   %ebp
  8001e9:	89 e5                	mov    %esp,%ebp
  8001eb:	53                   	push   %ebx
  8001ec:	83 ec 04             	sub    $0x4,%esp
  8001ef:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001f2:	8b 13                	mov    (%ebx),%edx
  8001f4:	8d 42 01             	lea    0x1(%edx),%eax
  8001f7:	89 03                	mov    %eax,(%ebx)
  8001f9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001fc:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800200:	3d ff 00 00 00       	cmp    $0xff,%eax
  800205:	75 1a                	jne    800221 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800207:	83 ec 08             	sub    $0x8,%esp
  80020a:	68 ff 00 00 00       	push   $0xff
  80020f:	8d 43 08             	lea    0x8(%ebx),%eax
  800212:	50                   	push   %eax
  800213:	e8 fb 09 00 00       	call   800c13 <sys_cputs>
		b->idx = 0;
  800218:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80021e:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800221:	ff 43 04             	incl   0x4(%ebx)
}
  800224:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800227:	c9                   	leave  
  800228:	c3                   	ret    

00800229 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800229:	55                   	push   %ebp
  80022a:	89 e5                	mov    %esp,%ebp
  80022c:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800232:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800239:	00 00 00 
	b.cnt = 0;
  80023c:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800243:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800246:	ff 75 0c             	pushl  0xc(%ebp)
  800249:	ff 75 08             	pushl  0x8(%ebp)
  80024c:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800252:	50                   	push   %eax
  800253:	68 e8 01 80 00       	push   $0x8001e8
  800258:	e8 54 01 00 00       	call   8003b1 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80025d:	83 c4 08             	add    $0x8,%esp
  800260:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800266:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80026c:	50                   	push   %eax
  80026d:	e8 a1 09 00 00       	call   800c13 <sys_cputs>

	return b.cnt;
}
  800272:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800278:	c9                   	leave  
  800279:	c3                   	ret    

0080027a <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80027a:	55                   	push   %ebp
  80027b:	89 e5                	mov    %esp,%ebp
  80027d:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800280:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800283:	50                   	push   %eax
  800284:	ff 75 08             	pushl  0x8(%ebp)
  800287:	e8 9d ff ff ff       	call   800229 <vcprintf>
	va_end(ap);

	return cnt;
}
  80028c:	c9                   	leave  
  80028d:	c3                   	ret    

0080028e <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80028e:	55                   	push   %ebp
  80028f:	89 e5                	mov    %esp,%ebp
  800291:	57                   	push   %edi
  800292:	56                   	push   %esi
  800293:	53                   	push   %ebx
  800294:	83 ec 1c             	sub    $0x1c,%esp
  800297:	89 c6                	mov    %eax,%esi
  800299:	89 d7                	mov    %edx,%edi
  80029b:	8b 45 08             	mov    0x8(%ebp),%eax
  80029e:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002a1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002a4:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002a7:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8002aa:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002af:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8002b2:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8002b5:	39 d3                	cmp    %edx,%ebx
  8002b7:	72 11                	jb     8002ca <printnum+0x3c>
  8002b9:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002bc:	76 0c                	jbe    8002ca <printnum+0x3c>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002be:	8b 45 14             	mov    0x14(%ebp),%eax
  8002c1:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8002c4:	85 db                	test   %ebx,%ebx
  8002c6:	7f 37                	jg     8002ff <printnum+0x71>
  8002c8:	eb 44                	jmp    80030e <printnum+0x80>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002ca:	83 ec 0c             	sub    $0xc,%esp
  8002cd:	ff 75 18             	pushl  0x18(%ebp)
  8002d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8002d3:	48                   	dec    %eax
  8002d4:	50                   	push   %eax
  8002d5:	ff 75 10             	pushl  0x10(%ebp)
  8002d8:	83 ec 08             	sub    $0x8,%esp
  8002db:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002de:	ff 75 e0             	pushl  -0x20(%ebp)
  8002e1:	ff 75 dc             	pushl  -0x24(%ebp)
  8002e4:	ff 75 d8             	pushl  -0x28(%ebp)
  8002e7:	e8 f0 1a 00 00       	call   801ddc <__udivdi3>
  8002ec:	83 c4 18             	add    $0x18,%esp
  8002ef:	52                   	push   %edx
  8002f0:	50                   	push   %eax
  8002f1:	89 fa                	mov    %edi,%edx
  8002f3:	89 f0                	mov    %esi,%eax
  8002f5:	e8 94 ff ff ff       	call   80028e <printnum>
  8002fa:	83 c4 20             	add    $0x20,%esp
  8002fd:	eb 0f                	jmp    80030e <printnum+0x80>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002ff:	83 ec 08             	sub    $0x8,%esp
  800302:	57                   	push   %edi
  800303:	ff 75 18             	pushl  0x18(%ebp)
  800306:	ff d6                	call   *%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800308:	83 c4 10             	add    $0x10,%esp
  80030b:	4b                   	dec    %ebx
  80030c:	75 f1                	jne    8002ff <printnum+0x71>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80030e:	83 ec 08             	sub    $0x8,%esp
  800311:	57                   	push   %edi
  800312:	83 ec 04             	sub    $0x4,%esp
  800315:	ff 75 e4             	pushl  -0x1c(%ebp)
  800318:	ff 75 e0             	pushl  -0x20(%ebp)
  80031b:	ff 75 dc             	pushl  -0x24(%ebp)
  80031e:	ff 75 d8             	pushl  -0x28(%ebp)
  800321:	e8 c6 1b 00 00       	call   801eec <__umoddi3>
  800326:	83 c4 14             	add    $0x14,%esp
  800329:	0f be 80 c7 20 80 00 	movsbl 0x8020c7(%eax),%eax
  800330:	50                   	push   %eax
  800331:	ff d6                	call   *%esi
}
  800333:	83 c4 10             	add    $0x10,%esp
  800336:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800339:	5b                   	pop    %ebx
  80033a:	5e                   	pop    %esi
  80033b:	5f                   	pop    %edi
  80033c:	5d                   	pop    %ebp
  80033d:	c3                   	ret    

0080033e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80033e:	55                   	push   %ebp
  80033f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800341:	83 fa 01             	cmp    $0x1,%edx
  800344:	7e 0e                	jle    800354 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800346:	8b 10                	mov    (%eax),%edx
  800348:	8d 4a 08             	lea    0x8(%edx),%ecx
  80034b:	89 08                	mov    %ecx,(%eax)
  80034d:	8b 02                	mov    (%edx),%eax
  80034f:	8b 52 04             	mov    0x4(%edx),%edx
  800352:	eb 22                	jmp    800376 <getuint+0x38>
	else if (lflag)
  800354:	85 d2                	test   %edx,%edx
  800356:	74 10                	je     800368 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800358:	8b 10                	mov    (%eax),%edx
  80035a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80035d:	89 08                	mov    %ecx,(%eax)
  80035f:	8b 02                	mov    (%edx),%eax
  800361:	ba 00 00 00 00       	mov    $0x0,%edx
  800366:	eb 0e                	jmp    800376 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800368:	8b 10                	mov    (%eax),%edx
  80036a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80036d:	89 08                	mov    %ecx,(%eax)
  80036f:	8b 02                	mov    (%edx),%eax
  800371:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800376:	5d                   	pop    %ebp
  800377:	c3                   	ret    

00800378 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800378:	55                   	push   %ebp
  800379:	89 e5                	mov    %esp,%ebp
  80037b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80037e:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800381:	8b 10                	mov    (%eax),%edx
  800383:	3b 50 04             	cmp    0x4(%eax),%edx
  800386:	73 0a                	jae    800392 <sprintputch+0x1a>
		*b->buf++ = ch;
  800388:	8d 4a 01             	lea    0x1(%edx),%ecx
  80038b:	89 08                	mov    %ecx,(%eax)
  80038d:	8b 45 08             	mov    0x8(%ebp),%eax
  800390:	88 02                	mov    %al,(%edx)
}
  800392:	5d                   	pop    %ebp
  800393:	c3                   	ret    

00800394 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800394:	55                   	push   %ebp
  800395:	89 e5                	mov    %esp,%ebp
  800397:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80039a:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80039d:	50                   	push   %eax
  80039e:	ff 75 10             	pushl  0x10(%ebp)
  8003a1:	ff 75 0c             	pushl  0xc(%ebp)
  8003a4:	ff 75 08             	pushl  0x8(%ebp)
  8003a7:	e8 05 00 00 00       	call   8003b1 <vprintfmt>
	va_end(ap);
}
  8003ac:	83 c4 10             	add    $0x10,%esp
  8003af:	c9                   	leave  
  8003b0:	c3                   	ret    

008003b1 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003b1:	55                   	push   %ebp
  8003b2:	89 e5                	mov    %esp,%ebp
  8003b4:	57                   	push   %edi
  8003b5:	56                   	push   %esi
  8003b6:	53                   	push   %ebx
  8003b7:	83 ec 2c             	sub    $0x2c,%esp
  8003ba:	8b 7d 08             	mov    0x8(%ebp),%edi
  8003bd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003c0:	eb 03                	jmp    8003c5 <vprintfmt+0x14>
			break;

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
			for (fmt--; fmt[-1] != '%'; fmt--)
  8003c2:	89 75 10             	mov    %esi,0x10(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {    //遍历输入的第一个参数，即输出信息的格式，先把格式字符串中'%'之前的字符一个个输出，因为它们前面没有'%'，所以它们就是要直接显示在屏幕上的
  8003c5:	8b 45 10             	mov    0x10(%ebp),%eax
  8003c8:	8d 70 01             	lea    0x1(%eax),%esi
  8003cb:	0f b6 00             	movzbl (%eax),%eax
  8003ce:	83 f8 25             	cmp    $0x25,%eax
  8003d1:	74 25                	je     8003f8 <vprintfmt+0x47>
			if (ch == '\0')									//当然中间如果遇到'\0'，代表这个字符串的访问结束
  8003d3:	85 c0                	test   %eax,%eax
  8003d5:	75 0d                	jne    8003e4 <vprintfmt+0x33>
  8003d7:	e9 b5 03 00 00       	jmp    800791 <vprintfmt+0x3e0>
  8003dc:	85 c0                	test   %eax,%eax
  8003de:	0f 84 ad 03 00 00    	je     800791 <vprintfmt+0x3e0>
				return;
			putch(ch, putdat);								//调用putch函数，把一个字符ch输出到putdat指针所指向的地址中所存放的值对应的地址处
  8003e4:	83 ec 08             	sub    $0x8,%esp
  8003e7:	53                   	push   %ebx
  8003e8:	50                   	push   %eax
  8003e9:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {    //遍历输入的第一个参数，即输出信息的格式，先把格式字符串中'%'之前的字符一个个输出，因为它们前面没有'%'，所以它们就是要直接显示在屏幕上的
  8003eb:	46                   	inc    %esi
  8003ec:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  8003f0:	83 c4 10             	add    $0x10,%esp
  8003f3:	83 f8 25             	cmp    $0x25,%eax
  8003f6:	75 e4                	jne    8003dc <vprintfmt+0x2b>
			if (width < 0)									//代表有小数点，但是小数点前面并没有数字，比如'%.6f'这种情况，此时代表整数部分全部显示
				width = 0;			
			goto reswitch;

		case '#':
			altflag = 1;
  8003f8:	c6 45 e3 20          	movb   $0x20,-0x1d(%ebp)
  8003fc:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800403:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80040a:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800411:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800418:	eb 07                	jmp    800421 <vprintfmt+0x70>
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  80041a:	8b 75 10             	mov    0x10(%ebp),%esi

		// flag to pad on the right
		case '-':											//%后面的'-'代表要进行左对齐输出，右边填空格，如果省略代表右对齐
			padc = '-';										//如果有这个字符代表左对齐，则把对齐方式标志位变为'-'
  80041d:	c6 45 e3 2d          	movb   $0x2d,-0x1d(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  800421:	8d 46 01             	lea    0x1(%esi),%eax
  800424:	89 45 10             	mov    %eax,0x10(%ebp)
  800427:	0f b6 16             	movzbl (%esi),%edx
  80042a:	8a 06                	mov    (%esi),%al
  80042c:	83 e8 23             	sub    $0x23,%eax
  80042f:	3c 55                	cmp    $0x55,%al
  800431:	0f 87 03 03 00 00    	ja     80073a <vprintfmt+0x389>
  800437:	0f b6 c0             	movzbl %al,%eax
  80043a:	ff 24 85 00 22 80 00 	jmp    *0x802200(,%eax,4)
  800441:	8b 75 10             	mov    0x10(%ebp),%esi
			padc = '-';										//如果有这个字符代表左对齐，则把对齐方式标志位变为'-'
			goto reswitch;									//处理下一个字符

		// flag to pad with 0's instead of spaces
		case '0':											//0--有0表示进行对齐输出时填0,如省略表示填入空格，并且如果为0，则一定是右对齐
			padc = '0';										//对其方式标志位变为0
  800444:	c6 45 e3 30          	movb   $0x30,-0x1d(%ebp)
  800448:	eb d7                	jmp    800421 <vprintfmt+0x70>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {					//把遇到的位数字符串转换为真实的位数，比如输入的'%40'，代表有效位数为40位，下面的循环就是把precesion的值设置为40
				precision = precision * 10 + ch - '0';
  80044a:	8d 42 d0             	lea    -0x30(%edx),%eax
  80044d:	89 c1                	mov    %eax,%ecx
  80044f:	89 45 d0             	mov    %eax,-0x30(%ebp)
				ch = *fmt;
  800452:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  800456:	8d 50 d0             	lea    -0x30(%eax),%edx
  800459:	83 fa 09             	cmp    $0x9,%edx
  80045c:	77 51                	ja     8004af <vprintfmt+0xfe>
  80045e:	8b 75 10             	mov    0x10(%ebp),%esi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {					//把遇到的位数字符串转换为真实的位数，比如输入的'%40'，代表有效位数为40位，下面的循环就是把precesion的值设置为40
  800461:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  800462:	8d 14 89             	lea    (%ecx,%ecx,4),%edx
  800465:	01 d2                	add    %edx,%edx
  800467:	8d 4c 10 d0          	lea    -0x30(%eax,%edx,1),%ecx
				ch = *fmt;
  80046b:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80046e:	8d 50 d0             	lea    -0x30(%eax),%edx
  800471:	83 fa 09             	cmp    $0x9,%edx
  800474:	76 eb                	jbe    800461 <vprintfmt+0xb0>
  800476:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800479:	eb 37                	jmp    8004b2 <vprintfmt+0x101>
					break;
			}
			goto process_precision;							//跳转到process_precistion子过程

		case '*':											//*--代表有效数字的位数也是由输入参数指定的，比如printf("%*.*f", 10, 2, n)，其中10,2就是用来指定显示的有效数字位数的
			precision = va_arg(ap, int);
  80047b:	8b 45 14             	mov    0x14(%ebp),%eax
  80047e:	8d 50 04             	lea    0x4(%eax),%edx
  800481:	89 55 14             	mov    %edx,0x14(%ebp)
  800484:	8b 00                	mov    (%eax),%eax
  800486:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  800489:	8b 75 10             	mov    0x10(%ebp),%esi
			}
			goto process_precision;							//跳转到process_precistion子过程

		case '*':											//*--代表有效数字的位数也是由输入参数指定的，比如printf("%*.*f", 10, 2, n)，其中10,2就是用来指定显示的有效数字位数的
			precision = va_arg(ap, int);
			goto process_precision;
  80048c:	eb 24                	jmp    8004b2 <vprintfmt+0x101>
  80048e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800492:	79 07                	jns    80049b <vprintfmt+0xea>
  800494:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  80049b:	8b 75 10             	mov    0x10(%ebp),%esi
  80049e:	eb 81                	jmp    800421 <vprintfmt+0x70>
  8004a0:	8b 75 10             	mov    0x10(%ebp),%esi
			if (width < 0)									//代表有小数点，但是小数点前面并没有数字，比如'%.6f'这种情况，此时代表整数部分全部显示
				width = 0;			
			goto reswitch;

		case '#':
			altflag = 1;
  8004a3:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8004aa:	e9 72 ff ff ff       	jmp    800421 <vprintfmt+0x70>
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  8004af:	8b 75 10             	mov    0x10(%ebp),%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:									//处理输出精度，把width字段赋值为刚刚计算出来的precision值，所以width应该是整数部分的有效数字位数
			if (width < 0)
  8004b2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004b6:	0f 89 65 ff ff ff    	jns    800421 <vprintfmt+0x70>
				width = precision, precision = -1;
  8004bc:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8004bf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004c2:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8004c9:	e9 53 ff ff ff       	jmp    800421 <vprintfmt+0x70>
			goto reswitch;

		// long flag (doubled for long long)				
		case 'l':											//如果遇到'l'，代表应该是输入long类型，如果有两个'l'代表long long
			lflag++;										//此时把lflag++
  8004ce:	ff 45 d4             	incl   -0x2c(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  8004d1:	8b 75 10             	mov    0x10(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)				
		case 'l':											//如果遇到'l'，代表应该是输入long类型，如果有两个'l'代表long long
			lflag++;										//此时把lflag++
			goto reswitch;
  8004d4:	e9 48 ff ff ff       	jmp    800421 <vprintfmt+0x70>

		// character
		case 'c':											//如果是'c'代表显示一个字符
			putch(va_arg(ap, int), putdat);					//调用输出一个字符到内存的函数putch
  8004d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8004dc:	8d 50 04             	lea    0x4(%eax),%edx
  8004df:	89 55 14             	mov    %edx,0x14(%ebp)
  8004e2:	83 ec 08             	sub    $0x8,%esp
  8004e5:	53                   	push   %ebx
  8004e6:	ff 30                	pushl  (%eax)
  8004e8:	ff d7                	call   *%edi
			break;
  8004ea:	83 c4 10             	add    $0x10,%esp
  8004ed:	e9 d3 fe ff ff       	jmp    8003c5 <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f5:	8d 50 04             	lea    0x4(%eax),%edx
  8004f8:	89 55 14             	mov    %edx,0x14(%ebp)
  8004fb:	8b 00                	mov    (%eax),%eax
  8004fd:	85 c0                	test   %eax,%eax
  8004ff:	79 02                	jns    800503 <vprintfmt+0x152>
  800501:	f7 d8                	neg    %eax
  800503:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800505:	83 f8 0f             	cmp    $0xf,%eax
  800508:	7f 0b                	jg     800515 <vprintfmt+0x164>
  80050a:	8b 04 85 60 23 80 00 	mov    0x802360(,%eax,4),%eax
  800511:	85 c0                	test   %eax,%eax
  800513:	75 15                	jne    80052a <vprintfmt+0x179>
				printfmt(putch, putdat, "error %d", err);
  800515:	52                   	push   %edx
  800516:	68 df 20 80 00       	push   $0x8020df
  80051b:	53                   	push   %ebx
  80051c:	57                   	push   %edi
  80051d:	e8 72 fe ff ff       	call   800394 <printfmt>
  800522:	83 c4 10             	add    $0x10,%esp
  800525:	e9 9b fe ff ff       	jmp    8003c5 <vprintfmt+0x14>
			else
				printfmt(putch, putdat, "%s", p);
  80052a:	50                   	push   %eax
  80052b:	68 82 24 80 00       	push   $0x802482
  800530:	53                   	push   %ebx
  800531:	57                   	push   %edi
  800532:	e8 5d fe ff ff       	call   800394 <printfmt>
  800537:	83 c4 10             	add    $0x10,%esp
  80053a:	e9 86 fe ff ff       	jmp    8003c5 <vprintfmt+0x14>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80053f:	8b 45 14             	mov    0x14(%ebp),%eax
  800542:	8d 50 04             	lea    0x4(%eax),%edx
  800545:	89 55 14             	mov    %edx,0x14(%ebp)
  800548:	8b 00                	mov    (%eax),%eax
  80054a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80054d:	85 c0                	test   %eax,%eax
  80054f:	75 07                	jne    800558 <vprintfmt+0x1a7>
				p = "(null)";
  800551:	c7 45 d4 d8 20 80 00 	movl   $0x8020d8,-0x2c(%ebp)
			if (width > 0 && padc != '-')
  800558:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80055b:	85 f6                	test   %esi,%esi
  80055d:	0f 8e fb 01 00 00    	jle    80075e <vprintfmt+0x3ad>
  800563:	80 7d e3 2d          	cmpb   $0x2d,-0x1d(%ebp)
  800567:	0f 84 09 02 00 00    	je     800776 <vprintfmt+0x3c5>
				for (width -= strnlen(p, precision); width > 0; width--)
  80056d:	83 ec 08             	sub    $0x8,%esp
  800570:	ff 75 d0             	pushl  -0x30(%ebp)
  800573:	ff 75 d4             	pushl  -0x2c(%ebp)
  800576:	e8 ad 02 00 00       	call   800828 <strnlen>
  80057b:	89 f1                	mov    %esi,%ecx
  80057d:	29 c1                	sub    %eax,%ecx
  80057f:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  800582:	83 c4 10             	add    $0x10,%esp
  800585:	85 c9                	test   %ecx,%ecx
  800587:	0f 8e d1 01 00 00    	jle    80075e <vprintfmt+0x3ad>
					putch(padc, putdat);
  80058d:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  800591:	83 ec 08             	sub    $0x8,%esp
  800594:	53                   	push   %ebx
  800595:	56                   	push   %esi
  800596:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800598:	83 c4 10             	add    $0x10,%esp
  80059b:	ff 4d e4             	decl   -0x1c(%ebp)
  80059e:	75 f1                	jne    800591 <vprintfmt+0x1e0>
  8005a0:	e9 b9 01 00 00       	jmp    80075e <vprintfmt+0x3ad>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005a5:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005a9:	74 19                	je     8005c4 <vprintfmt+0x213>
  8005ab:	0f be c0             	movsbl %al,%eax
  8005ae:	83 e8 20             	sub    $0x20,%eax
  8005b1:	83 f8 5e             	cmp    $0x5e,%eax
  8005b4:	76 0e                	jbe    8005c4 <vprintfmt+0x213>
					putch('?', putdat);
  8005b6:	83 ec 08             	sub    $0x8,%esp
  8005b9:	53                   	push   %ebx
  8005ba:	6a 3f                	push   $0x3f
  8005bc:	ff 55 08             	call   *0x8(%ebp)
  8005bf:	83 c4 10             	add    $0x10,%esp
  8005c2:	eb 0b                	jmp    8005cf <vprintfmt+0x21e>
				else
					putch(ch, putdat);
  8005c4:	83 ec 08             	sub    $0x8,%esp
  8005c7:	53                   	push   %ebx
  8005c8:	52                   	push   %edx
  8005c9:	ff 55 08             	call   *0x8(%ebp)
  8005cc:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005cf:	ff 4d e4             	decl   -0x1c(%ebp)
  8005d2:	46                   	inc    %esi
  8005d3:	8a 46 ff             	mov    -0x1(%esi),%al
  8005d6:	0f be d0             	movsbl %al,%edx
  8005d9:	85 d2                	test   %edx,%edx
  8005db:	75 1c                	jne    8005f9 <vprintfmt+0x248>
  8005dd:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005e0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005e4:	7f 1f                	jg     800605 <vprintfmt+0x254>
  8005e6:	e9 da fd ff ff       	jmp    8003c5 <vprintfmt+0x14>
  8005eb:	89 7d 08             	mov    %edi,0x8(%ebp)
  8005ee:	8b 7d d0             	mov    -0x30(%ebp),%edi
  8005f1:	eb 06                	jmp    8005f9 <vprintfmt+0x248>
  8005f3:	89 7d 08             	mov    %edi,0x8(%ebp)
  8005f6:	8b 7d d0             	mov    -0x30(%ebp),%edi
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005f9:	85 ff                	test   %edi,%edi
  8005fb:	78 a8                	js     8005a5 <vprintfmt+0x1f4>
  8005fd:	4f                   	dec    %edi
  8005fe:	79 a5                	jns    8005a5 <vprintfmt+0x1f4>
  800600:	8b 7d 08             	mov    0x8(%ebp),%edi
  800603:	eb db                	jmp    8005e0 <vprintfmt+0x22f>
  800605:	8b 75 e4             	mov    -0x1c(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800608:	83 ec 08             	sub    $0x8,%esp
  80060b:	53                   	push   %ebx
  80060c:	6a 20                	push   $0x20
  80060e:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800610:	4e                   	dec    %esi
  800611:	83 c4 10             	add    $0x10,%esp
  800614:	85 f6                	test   %esi,%esi
  800616:	7f f0                	jg     800608 <vprintfmt+0x257>
  800618:	e9 a8 fd ff ff       	jmp    8003c5 <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80061d:	83 7d d4 01          	cmpl   $0x1,-0x2c(%ebp)
  800621:	7e 16                	jle    800639 <vprintfmt+0x288>
		return va_arg(*ap, long long);
  800623:	8b 45 14             	mov    0x14(%ebp),%eax
  800626:	8d 50 08             	lea    0x8(%eax),%edx
  800629:	89 55 14             	mov    %edx,0x14(%ebp)
  80062c:	8b 50 04             	mov    0x4(%eax),%edx
  80062f:	8b 00                	mov    (%eax),%eax
  800631:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800634:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800637:	eb 34                	jmp    80066d <vprintfmt+0x2bc>
	else if (lflag)
  800639:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80063d:	74 18                	je     800657 <vprintfmt+0x2a6>
		return va_arg(*ap, long);
  80063f:	8b 45 14             	mov    0x14(%ebp),%eax
  800642:	8d 50 04             	lea    0x4(%eax),%edx
  800645:	89 55 14             	mov    %edx,0x14(%ebp)
  800648:	8b 30                	mov    (%eax),%esi
  80064a:	89 75 d8             	mov    %esi,-0x28(%ebp)
  80064d:	89 f0                	mov    %esi,%eax
  80064f:	c1 f8 1f             	sar    $0x1f,%eax
  800652:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800655:	eb 16                	jmp    80066d <vprintfmt+0x2bc>
	else
		return va_arg(*ap, int);
  800657:	8b 45 14             	mov    0x14(%ebp),%eax
  80065a:	8d 50 04             	lea    0x4(%eax),%edx
  80065d:	89 55 14             	mov    %edx,0x14(%ebp)
  800660:	8b 30                	mov    (%eax),%esi
  800662:	89 75 d8             	mov    %esi,-0x28(%ebp)
  800665:	89 f0                	mov    %esi,%eax
  800667:	c1 f8 1f             	sar    $0x1f,%eax
  80066a:	89 45 dc             	mov    %eax,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80066d:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800670:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
  800673:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800677:	0f 89 8a 00 00 00    	jns    800707 <vprintfmt+0x356>
				putch('-', putdat);
  80067d:	83 ec 08             	sub    $0x8,%esp
  800680:	53                   	push   %ebx
  800681:	6a 2d                	push   $0x2d
  800683:	ff d7                	call   *%edi
				num = -(long long) num;
  800685:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800688:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80068b:	f7 d8                	neg    %eax
  80068d:	83 d2 00             	adc    $0x0,%edx
  800690:	f7 da                	neg    %edx
  800692:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800695:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80069a:	eb 70                	jmp    80070c <vprintfmt+0x35b>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80069c:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80069f:	8d 45 14             	lea    0x14(%ebp),%eax
  8006a2:	e8 97 fc ff ff       	call   80033e <getuint>
			base = 10;
  8006a7:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8006ac:	eb 5e                	jmp    80070c <vprintfmt+0x35b>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
  8006ae:	83 ec 08             	sub    $0x8,%esp
  8006b1:	53                   	push   %ebx
  8006b2:	6a 30                	push   $0x30
  8006b4:	ff d7                	call   *%edi
			num = getuint(&ap, lflag);
  8006b6:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8006b9:	8d 45 14             	lea    0x14(%ebp),%eax
  8006bc:	e8 7d fc ff ff       	call   80033e <getuint>
			base = 8;
			goto number;
  8006c1:	83 c4 10             	add    $0x10,%esp
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  8006c4:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8006c9:	eb 41                	jmp    80070c <vprintfmt+0x35b>
		// pointer
		case 'p':
			putch('0', putdat);
  8006cb:	83 ec 08             	sub    $0x8,%esp
  8006ce:	53                   	push   %ebx
  8006cf:	6a 30                	push   $0x30
  8006d1:	ff d7                	call   *%edi
			putch('x', putdat);
  8006d3:	83 c4 08             	add    $0x8,%esp
  8006d6:	53                   	push   %ebx
  8006d7:	6a 78                	push   $0x78
  8006d9:	ff d7                	call   *%edi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006db:	8b 45 14             	mov    0x14(%ebp),%eax
  8006de:	8d 50 04             	lea    0x4(%eax),%edx
  8006e1:	89 55 14             	mov    %edx,0x14(%ebp)
			goto number;
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006e4:	8b 00                	mov    (%eax),%eax
  8006e6:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006eb:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006ee:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8006f3:	eb 17                	jmp    80070c <vprintfmt+0x35b>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006f5:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8006f8:	8d 45 14             	lea    0x14(%ebp),%eax
  8006fb:	e8 3e fc ff ff       	call   80033e <getuint>
			base = 16;
  800700:	b9 10 00 00 00       	mov    $0x10,%ecx
  800705:	eb 05                	jmp    80070c <vprintfmt+0x35b>
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800707:	b9 0a 00 00 00       	mov    $0xa,%ecx
		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  80070c:	83 ec 0c             	sub    $0xc,%esp
  80070f:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  800713:	56                   	push   %esi
  800714:	ff 75 e4             	pushl  -0x1c(%ebp)
  800717:	51                   	push   %ecx
  800718:	52                   	push   %edx
  800719:	50                   	push   %eax
  80071a:	89 da                	mov    %ebx,%edx
  80071c:	89 f8                	mov    %edi,%eax
  80071e:	e8 6b fb ff ff       	call   80028e <printnum>
			break;
  800723:	83 c4 20             	add    $0x20,%esp
  800726:	e9 9a fc ff ff       	jmp    8003c5 <vprintfmt+0x14>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80072b:	83 ec 08             	sub    $0x8,%esp
  80072e:	53                   	push   %ebx
  80072f:	52                   	push   %edx
  800730:	ff d7                	call   *%edi
			break;
  800732:	83 c4 10             	add    $0x10,%esp
  800735:	e9 8b fc ff ff       	jmp    8003c5 <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80073a:	83 ec 08             	sub    $0x8,%esp
  80073d:	53                   	push   %ebx
  80073e:	6a 25                	push   $0x25
  800740:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800742:	83 c4 10             	add    $0x10,%esp
  800745:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800749:	0f 84 73 fc ff ff    	je     8003c2 <vprintfmt+0x11>
  80074f:	4e                   	dec    %esi
  800750:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800754:	75 f9                	jne    80074f <vprintfmt+0x39e>
  800756:	89 75 10             	mov    %esi,0x10(%ebp)
  800759:	e9 67 fc ff ff       	jmp    8003c5 <vprintfmt+0x14>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80075e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800761:	8d 70 01             	lea    0x1(%eax),%esi
  800764:	8a 00                	mov    (%eax),%al
  800766:	0f be d0             	movsbl %al,%edx
  800769:	85 d2                	test   %edx,%edx
  80076b:	0f 85 7a fe ff ff    	jne    8005eb <vprintfmt+0x23a>
  800771:	e9 4f fc ff ff       	jmp    8003c5 <vprintfmt+0x14>
  800776:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800779:	8d 70 01             	lea    0x1(%eax),%esi
  80077c:	8a 00                	mov    (%eax),%al
  80077e:	0f be d0             	movsbl %al,%edx
  800781:	85 d2                	test   %edx,%edx
  800783:	0f 85 6a fe ff ff    	jne    8005f3 <vprintfmt+0x242>
  800789:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80078c:	e9 77 fe ff ff       	jmp    800608 <vprintfmt+0x257>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800791:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800794:	5b                   	pop    %ebx
  800795:	5e                   	pop    %esi
  800796:	5f                   	pop    %edi
  800797:	5d                   	pop    %ebp
  800798:	c3                   	ret    

00800799 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800799:	55                   	push   %ebp
  80079a:	89 e5                	mov    %esp,%ebp
  80079c:	83 ec 18             	sub    $0x18,%esp
  80079f:	8b 45 08             	mov    0x8(%ebp),%eax
  8007a2:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007a5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007a8:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007ac:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007af:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007b6:	85 c0                	test   %eax,%eax
  8007b8:	74 26                	je     8007e0 <vsnprintf+0x47>
  8007ba:	85 d2                	test   %edx,%edx
  8007bc:	7e 29                	jle    8007e7 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007be:	ff 75 14             	pushl  0x14(%ebp)
  8007c1:	ff 75 10             	pushl  0x10(%ebp)
  8007c4:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007c7:	50                   	push   %eax
  8007c8:	68 78 03 80 00       	push   $0x800378
  8007cd:	e8 df fb ff ff       	call   8003b1 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007d2:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007d5:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007db:	83 c4 10             	add    $0x10,%esp
  8007de:	eb 0c                	jmp    8007ec <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007e0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007e5:	eb 05                	jmp    8007ec <vsnprintf+0x53>
  8007e7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007ec:	c9                   	leave  
  8007ed:	c3                   	ret    

008007ee <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007ee:	55                   	push   %ebp
  8007ef:	89 e5                	mov    %esp,%ebp
  8007f1:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007f4:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007f7:	50                   	push   %eax
  8007f8:	ff 75 10             	pushl  0x10(%ebp)
  8007fb:	ff 75 0c             	pushl  0xc(%ebp)
  8007fe:	ff 75 08             	pushl  0x8(%ebp)
  800801:	e8 93 ff ff ff       	call   800799 <vsnprintf>
	va_end(ap);

	return rc;
}
  800806:	c9                   	leave  
  800807:	c3                   	ret    

00800808 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800808:	55                   	push   %ebp
  800809:	89 e5                	mov    %esp,%ebp
  80080b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80080e:	80 3a 00             	cmpb   $0x0,(%edx)
  800811:	74 0e                	je     800821 <strlen+0x19>
  800813:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800818:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800819:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80081d:	75 f9                	jne    800818 <strlen+0x10>
  80081f:	eb 05                	jmp    800826 <strlen+0x1e>
  800821:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800826:	5d                   	pop    %ebp
  800827:	c3                   	ret    

00800828 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800828:	55                   	push   %ebp
  800829:	89 e5                	mov    %esp,%ebp
  80082b:	53                   	push   %ebx
  80082c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80082f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800832:	85 c9                	test   %ecx,%ecx
  800834:	74 1a                	je     800850 <strnlen+0x28>
  800836:	80 3b 00             	cmpb   $0x0,(%ebx)
  800839:	74 1c                	je     800857 <strnlen+0x2f>
  80083b:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  800840:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800842:	39 ca                	cmp    %ecx,%edx
  800844:	74 16                	je     80085c <strnlen+0x34>
  800846:	42                   	inc    %edx
  800847:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  80084c:	75 f2                	jne    800840 <strnlen+0x18>
  80084e:	eb 0c                	jmp    80085c <strnlen+0x34>
  800850:	b8 00 00 00 00       	mov    $0x0,%eax
  800855:	eb 05                	jmp    80085c <strnlen+0x34>
  800857:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  80085c:	5b                   	pop    %ebx
  80085d:	5d                   	pop    %ebp
  80085e:	c3                   	ret    

0080085f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80085f:	55                   	push   %ebp
  800860:	89 e5                	mov    %esp,%ebp
  800862:	53                   	push   %ebx
  800863:	8b 45 08             	mov    0x8(%ebp),%eax
  800866:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800869:	89 c2                	mov    %eax,%edx
  80086b:	42                   	inc    %edx
  80086c:	41                   	inc    %ecx
  80086d:	8a 59 ff             	mov    -0x1(%ecx),%bl
  800870:	88 5a ff             	mov    %bl,-0x1(%edx)
  800873:	84 db                	test   %bl,%bl
  800875:	75 f4                	jne    80086b <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800877:	5b                   	pop    %ebx
  800878:	5d                   	pop    %ebp
  800879:	c3                   	ret    

0080087a <strcat>:

char *
strcat(char *dst, const char *src)
{
  80087a:	55                   	push   %ebp
  80087b:	89 e5                	mov    %esp,%ebp
  80087d:	53                   	push   %ebx
  80087e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800881:	53                   	push   %ebx
  800882:	e8 81 ff ff ff       	call   800808 <strlen>
  800887:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80088a:	ff 75 0c             	pushl  0xc(%ebp)
  80088d:	01 d8                	add    %ebx,%eax
  80088f:	50                   	push   %eax
  800890:	e8 ca ff ff ff       	call   80085f <strcpy>
	return dst;
}
  800895:	89 d8                	mov    %ebx,%eax
  800897:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80089a:	c9                   	leave  
  80089b:	c3                   	ret    

0080089c <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80089c:	55                   	push   %ebp
  80089d:	89 e5                	mov    %esp,%ebp
  80089f:	56                   	push   %esi
  8008a0:	53                   	push   %ebx
  8008a1:	8b 75 08             	mov    0x8(%ebp),%esi
  8008a4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008a7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008aa:	85 db                	test   %ebx,%ebx
  8008ac:	74 14                	je     8008c2 <strncpy+0x26>
  8008ae:	01 f3                	add    %esi,%ebx
  8008b0:	89 f1                	mov    %esi,%ecx
		*dst++ = *src;
  8008b2:	41                   	inc    %ecx
  8008b3:	8a 02                	mov    (%edx),%al
  8008b5:	88 41 ff             	mov    %al,-0x1(%ecx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008b8:	80 3a 01             	cmpb   $0x1,(%edx)
  8008bb:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008be:	39 cb                	cmp    %ecx,%ebx
  8008c0:	75 f0                	jne    8008b2 <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008c2:	89 f0                	mov    %esi,%eax
  8008c4:	5b                   	pop    %ebx
  8008c5:	5e                   	pop    %esi
  8008c6:	5d                   	pop    %ebp
  8008c7:	c3                   	ret    

008008c8 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008c8:	55                   	push   %ebp
  8008c9:	89 e5                	mov    %esp,%ebp
  8008cb:	53                   	push   %ebx
  8008cc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8008cf:	8b 45 10             	mov    0x10(%ebp),%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008d2:	85 c0                	test   %eax,%eax
  8008d4:	74 30                	je     800906 <strlcpy+0x3e>
		while (--size > 0 && *src != '\0')
  8008d6:	48                   	dec    %eax
  8008d7:	74 20                	je     8008f9 <strlcpy+0x31>
  8008d9:	8a 0b                	mov    (%ebx),%cl
  8008db:	84 c9                	test   %cl,%cl
  8008dd:	74 1f                	je     8008fe <strlcpy+0x36>
  8008df:	8d 53 01             	lea    0x1(%ebx),%edx
  8008e2:	01 c3                	add    %eax,%ebx
  8008e4:	8b 45 08             	mov    0x8(%ebp),%eax
			*dst++ = *src++;
  8008e7:	40                   	inc    %eax
  8008e8:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008eb:	39 da                	cmp    %ebx,%edx
  8008ed:	74 12                	je     800901 <strlcpy+0x39>
  8008ef:	42                   	inc    %edx
  8008f0:	8a 4a ff             	mov    -0x1(%edx),%cl
  8008f3:	84 c9                	test   %cl,%cl
  8008f5:	75 f0                	jne    8008e7 <strlcpy+0x1f>
  8008f7:	eb 08                	jmp    800901 <strlcpy+0x39>
  8008f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008fc:	eb 03                	jmp    800901 <strlcpy+0x39>
  8008fe:	8b 45 08             	mov    0x8(%ebp),%eax
			*dst++ = *src++;
		*dst = '\0';
  800901:	c6 00 00             	movb   $0x0,(%eax)
  800904:	eb 03                	jmp    800909 <strlcpy+0x41>
  800906:	8b 45 08             	mov    0x8(%ebp),%eax
	}
	return dst - dst_in;
  800909:	2b 45 08             	sub    0x8(%ebp),%eax
}
  80090c:	5b                   	pop    %ebx
  80090d:	5d                   	pop    %ebp
  80090e:	c3                   	ret    

0080090f <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80090f:	55                   	push   %ebp
  800910:	89 e5                	mov    %esp,%ebp
  800912:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800915:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800918:	8a 01                	mov    (%ecx),%al
  80091a:	84 c0                	test   %al,%al
  80091c:	74 10                	je     80092e <strcmp+0x1f>
  80091e:	3a 02                	cmp    (%edx),%al
  800920:	75 0c                	jne    80092e <strcmp+0x1f>
		p++, q++;
  800922:	41                   	inc    %ecx
  800923:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800924:	8a 01                	mov    (%ecx),%al
  800926:	84 c0                	test   %al,%al
  800928:	74 04                	je     80092e <strcmp+0x1f>
  80092a:	3a 02                	cmp    (%edx),%al
  80092c:	74 f4                	je     800922 <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80092e:	0f b6 c0             	movzbl %al,%eax
  800931:	0f b6 12             	movzbl (%edx),%edx
  800934:	29 d0                	sub    %edx,%eax
}
  800936:	5d                   	pop    %ebp
  800937:	c3                   	ret    

00800938 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800938:	55                   	push   %ebp
  800939:	89 e5                	mov    %esp,%ebp
  80093b:	56                   	push   %esi
  80093c:	53                   	push   %ebx
  80093d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800940:	8b 55 0c             	mov    0xc(%ebp),%edx
  800943:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  800946:	85 f6                	test   %esi,%esi
  800948:	74 23                	je     80096d <strncmp+0x35>
  80094a:	8a 03                	mov    (%ebx),%al
  80094c:	84 c0                	test   %al,%al
  80094e:	74 2b                	je     80097b <strncmp+0x43>
  800950:	3a 02                	cmp    (%edx),%al
  800952:	75 27                	jne    80097b <strncmp+0x43>
  800954:	8d 43 01             	lea    0x1(%ebx),%eax
  800957:	01 de                	add    %ebx,%esi
		n--, p++, q++;
  800959:	89 c3                	mov    %eax,%ebx
  80095b:	42                   	inc    %edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80095c:	39 c6                	cmp    %eax,%esi
  80095e:	74 14                	je     800974 <strncmp+0x3c>
  800960:	8a 08                	mov    (%eax),%cl
  800962:	84 c9                	test   %cl,%cl
  800964:	74 15                	je     80097b <strncmp+0x43>
  800966:	40                   	inc    %eax
  800967:	3a 0a                	cmp    (%edx),%cl
  800969:	74 ee                	je     800959 <strncmp+0x21>
  80096b:	eb 0e                	jmp    80097b <strncmp+0x43>
		n--, p++, q++;
	if (n == 0)
		return 0;
  80096d:	b8 00 00 00 00       	mov    $0x0,%eax
  800972:	eb 0f                	jmp    800983 <strncmp+0x4b>
  800974:	b8 00 00 00 00       	mov    $0x0,%eax
  800979:	eb 08                	jmp    800983 <strncmp+0x4b>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80097b:	0f b6 03             	movzbl (%ebx),%eax
  80097e:	0f b6 12             	movzbl (%edx),%edx
  800981:	29 d0                	sub    %edx,%eax
}
  800983:	5b                   	pop    %ebx
  800984:	5e                   	pop    %esi
  800985:	5d                   	pop    %ebp
  800986:	c3                   	ret    

00800987 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800987:	55                   	push   %ebp
  800988:	89 e5                	mov    %esp,%ebp
  80098a:	53                   	push   %ebx
  80098b:	8b 45 08             	mov    0x8(%ebp),%eax
  80098e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  800991:	8a 10                	mov    (%eax),%dl
  800993:	84 d2                	test   %dl,%dl
  800995:	74 1a                	je     8009b1 <strchr+0x2a>
  800997:	88 d9                	mov    %bl,%cl
		if (*s == c)
  800999:	38 d3                	cmp    %dl,%bl
  80099b:	75 06                	jne    8009a3 <strchr+0x1c>
  80099d:	eb 17                	jmp    8009b6 <strchr+0x2f>
  80099f:	38 ca                	cmp    %cl,%dl
  8009a1:	74 13                	je     8009b6 <strchr+0x2f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009a3:	40                   	inc    %eax
  8009a4:	8a 10                	mov    (%eax),%dl
  8009a6:	84 d2                	test   %dl,%dl
  8009a8:	75 f5                	jne    80099f <strchr+0x18>
		if (*s == c)
			return (char *) s;
	return 0;
  8009aa:	b8 00 00 00 00       	mov    $0x0,%eax
  8009af:	eb 05                	jmp    8009b6 <strchr+0x2f>
  8009b1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009b6:	5b                   	pop    %ebx
  8009b7:	5d                   	pop    %ebp
  8009b8:	c3                   	ret    

008009b9 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009b9:	55                   	push   %ebp
  8009ba:	89 e5                	mov    %esp,%ebp
  8009bc:	53                   	push   %ebx
  8009bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  8009c3:	8a 10                	mov    (%eax),%dl
  8009c5:	84 d2                	test   %dl,%dl
  8009c7:	74 13                	je     8009dc <strfind+0x23>
  8009c9:	88 d9                	mov    %bl,%cl
		if (*s == c)
  8009cb:	38 d3                	cmp    %dl,%bl
  8009cd:	75 06                	jne    8009d5 <strfind+0x1c>
  8009cf:	eb 0b                	jmp    8009dc <strfind+0x23>
  8009d1:	38 ca                	cmp    %cl,%dl
  8009d3:	74 07                	je     8009dc <strfind+0x23>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8009d5:	40                   	inc    %eax
  8009d6:	8a 10                	mov    (%eax),%dl
  8009d8:	84 d2                	test   %dl,%dl
  8009da:	75 f5                	jne    8009d1 <strfind+0x18>
		if (*s == c)
			break;
	return (char *) s;
}
  8009dc:	5b                   	pop    %ebx
  8009dd:	5d                   	pop    %ebp
  8009de:	c3                   	ret    

008009df <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009df:	55                   	push   %ebp
  8009e0:	89 e5                	mov    %esp,%ebp
  8009e2:	57                   	push   %edi
  8009e3:	56                   	push   %esi
  8009e4:	53                   	push   %ebx
  8009e5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009e8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009eb:	85 c9                	test   %ecx,%ecx
  8009ed:	74 36                	je     800a25 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009ef:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009f5:	75 28                	jne    800a1f <memset+0x40>
  8009f7:	f6 c1 03             	test   $0x3,%cl
  8009fa:	75 23                	jne    800a1f <memset+0x40>
		c &= 0xFF;
  8009fc:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a00:	89 d3                	mov    %edx,%ebx
  800a02:	c1 e3 08             	shl    $0x8,%ebx
  800a05:	89 d6                	mov    %edx,%esi
  800a07:	c1 e6 18             	shl    $0x18,%esi
  800a0a:	89 d0                	mov    %edx,%eax
  800a0c:	c1 e0 10             	shl    $0x10,%eax
  800a0f:	09 f0                	or     %esi,%eax
  800a11:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800a13:	89 d8                	mov    %ebx,%eax
  800a15:	09 d0                	or     %edx,%eax
  800a17:	c1 e9 02             	shr    $0x2,%ecx
  800a1a:	fc                   	cld    
  800a1b:	f3 ab                	rep stos %eax,%es:(%edi)
  800a1d:	eb 06                	jmp    800a25 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a1f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a22:	fc                   	cld    
  800a23:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a25:	89 f8                	mov    %edi,%eax
  800a27:	5b                   	pop    %ebx
  800a28:	5e                   	pop    %esi
  800a29:	5f                   	pop    %edi
  800a2a:	5d                   	pop    %ebp
  800a2b:	c3                   	ret    

00800a2c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a2c:	55                   	push   %ebp
  800a2d:	89 e5                	mov    %esp,%ebp
  800a2f:	57                   	push   %edi
  800a30:	56                   	push   %esi
  800a31:	8b 45 08             	mov    0x8(%ebp),%eax
  800a34:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a37:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a3a:	39 c6                	cmp    %eax,%esi
  800a3c:	73 33                	jae    800a71 <memmove+0x45>
  800a3e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a41:	39 d0                	cmp    %edx,%eax
  800a43:	73 2c                	jae    800a71 <memmove+0x45>
		s += n;
		d += n;
  800a45:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a48:	89 d6                	mov    %edx,%esi
  800a4a:	09 fe                	or     %edi,%esi
  800a4c:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a52:	75 13                	jne    800a67 <memmove+0x3b>
  800a54:	f6 c1 03             	test   $0x3,%cl
  800a57:	75 0e                	jne    800a67 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800a59:	83 ef 04             	sub    $0x4,%edi
  800a5c:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a5f:	c1 e9 02             	shr    $0x2,%ecx
  800a62:	fd                   	std    
  800a63:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a65:	eb 07                	jmp    800a6e <memmove+0x42>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a67:	4f                   	dec    %edi
  800a68:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a6b:	fd                   	std    
  800a6c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a6e:	fc                   	cld    
  800a6f:	eb 1d                	jmp    800a8e <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a71:	89 f2                	mov    %esi,%edx
  800a73:	09 c2                	or     %eax,%edx
  800a75:	f6 c2 03             	test   $0x3,%dl
  800a78:	75 0f                	jne    800a89 <memmove+0x5d>
  800a7a:	f6 c1 03             	test   $0x3,%cl
  800a7d:	75 0a                	jne    800a89 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
  800a7f:	c1 e9 02             	shr    $0x2,%ecx
  800a82:	89 c7                	mov    %eax,%edi
  800a84:	fc                   	cld    
  800a85:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a87:	eb 05                	jmp    800a8e <memmove+0x62>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a89:	89 c7                	mov    %eax,%edi
  800a8b:	fc                   	cld    
  800a8c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a8e:	5e                   	pop    %esi
  800a8f:	5f                   	pop    %edi
  800a90:	5d                   	pop    %ebp
  800a91:	c3                   	ret    

00800a92 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a92:	55                   	push   %ebp
  800a93:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a95:	ff 75 10             	pushl  0x10(%ebp)
  800a98:	ff 75 0c             	pushl  0xc(%ebp)
  800a9b:	ff 75 08             	pushl  0x8(%ebp)
  800a9e:	e8 89 ff ff ff       	call   800a2c <memmove>
}
  800aa3:	c9                   	leave  
  800aa4:	c3                   	ret    

00800aa5 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800aa5:	55                   	push   %ebp
  800aa6:	89 e5                	mov    %esp,%ebp
  800aa8:	57                   	push   %edi
  800aa9:	56                   	push   %esi
  800aaa:	53                   	push   %ebx
  800aab:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800aae:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ab1:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ab4:	85 c0                	test   %eax,%eax
  800ab6:	74 33                	je     800aeb <memcmp+0x46>
  800ab8:	8d 78 ff             	lea    -0x1(%eax),%edi
		if (*s1 != *s2)
  800abb:	8a 13                	mov    (%ebx),%dl
  800abd:	8a 0e                	mov    (%esi),%cl
  800abf:	38 ca                	cmp    %cl,%dl
  800ac1:	75 13                	jne    800ad6 <memcmp+0x31>
  800ac3:	b8 00 00 00 00       	mov    $0x0,%eax
  800ac8:	eb 16                	jmp    800ae0 <memcmp+0x3b>
  800aca:	8a 54 03 01          	mov    0x1(%ebx,%eax,1),%dl
  800ace:	40                   	inc    %eax
  800acf:	8a 0c 06             	mov    (%esi,%eax,1),%cl
  800ad2:	38 ca                	cmp    %cl,%dl
  800ad4:	74 0a                	je     800ae0 <memcmp+0x3b>
			return (int) *s1 - (int) *s2;
  800ad6:	0f b6 c2             	movzbl %dl,%eax
  800ad9:	0f b6 c9             	movzbl %cl,%ecx
  800adc:	29 c8                	sub    %ecx,%eax
  800ade:	eb 10                	jmp    800af0 <memcmp+0x4b>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ae0:	39 f8                	cmp    %edi,%eax
  800ae2:	75 e6                	jne    800aca <memcmp+0x25>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800ae4:	b8 00 00 00 00       	mov    $0x0,%eax
  800ae9:	eb 05                	jmp    800af0 <memcmp+0x4b>
  800aeb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800af0:	5b                   	pop    %ebx
  800af1:	5e                   	pop    %esi
  800af2:	5f                   	pop    %edi
  800af3:	5d                   	pop    %ebp
  800af4:	c3                   	ret    

00800af5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800af5:	55                   	push   %ebp
  800af6:	89 e5                	mov    %esp,%ebp
  800af8:	53                   	push   %ebx
  800af9:	8b 55 08             	mov    0x8(%ebp),%edx
	const void *ends = (const char *) s + n;
  800afc:	89 d0                	mov    %edx,%eax
  800afe:	03 45 10             	add    0x10(%ebp),%eax
	for (; s < ends; s++)
  800b01:	39 c2                	cmp    %eax,%edx
  800b03:	73 1b                	jae    800b20 <memfind+0x2b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b05:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
  800b09:	0f b6 0a             	movzbl (%edx),%ecx
  800b0c:	39 d9                	cmp    %ebx,%ecx
  800b0e:	75 09                	jne    800b19 <memfind+0x24>
  800b10:	eb 12                	jmp    800b24 <memfind+0x2f>
  800b12:	0f b6 0a             	movzbl (%edx),%ecx
  800b15:	39 d9                	cmp    %ebx,%ecx
  800b17:	74 0f                	je     800b28 <memfind+0x33>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b19:	42                   	inc    %edx
  800b1a:	39 d0                	cmp    %edx,%eax
  800b1c:	75 f4                	jne    800b12 <memfind+0x1d>
  800b1e:	eb 0a                	jmp    800b2a <memfind+0x35>
  800b20:	89 d0                	mov    %edx,%eax
  800b22:	eb 06                	jmp    800b2a <memfind+0x35>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b24:	89 d0                	mov    %edx,%eax
  800b26:	eb 02                	jmp    800b2a <memfind+0x35>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b28:	89 d0                	mov    %edx,%eax
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b2a:	5b                   	pop    %ebx
  800b2b:	5d                   	pop    %ebp
  800b2c:	c3                   	ret    

00800b2d <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b2d:	55                   	push   %ebp
  800b2e:	89 e5                	mov    %esp,%ebp
  800b30:	57                   	push   %edi
  800b31:	56                   	push   %esi
  800b32:	53                   	push   %ebx
  800b33:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b36:	eb 01                	jmp    800b39 <strtol+0xc>
		s++;
  800b38:	41                   	inc    %ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b39:	8a 01                	mov    (%ecx),%al
  800b3b:	3c 20                	cmp    $0x20,%al
  800b3d:	74 f9                	je     800b38 <strtol+0xb>
  800b3f:	3c 09                	cmp    $0x9,%al
  800b41:	74 f5                	je     800b38 <strtol+0xb>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b43:	3c 2b                	cmp    $0x2b,%al
  800b45:	75 08                	jne    800b4f <strtol+0x22>
		s++;
  800b47:	41                   	inc    %ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b48:	bf 00 00 00 00       	mov    $0x0,%edi
  800b4d:	eb 11                	jmp    800b60 <strtol+0x33>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b4f:	3c 2d                	cmp    $0x2d,%al
  800b51:	75 08                	jne    800b5b <strtol+0x2e>
		s++, neg = 1;
  800b53:	41                   	inc    %ecx
  800b54:	bf 01 00 00 00       	mov    $0x1,%edi
  800b59:	eb 05                	jmp    800b60 <strtol+0x33>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b5b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b60:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800b64:	0f 84 87 00 00 00    	je     800bf1 <strtol+0xc4>
  800b6a:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  800b6e:	75 27                	jne    800b97 <strtol+0x6a>
  800b70:	80 39 30             	cmpb   $0x30,(%ecx)
  800b73:	75 22                	jne    800b97 <strtol+0x6a>
  800b75:	e9 88 00 00 00       	jmp    800c02 <strtol+0xd5>
		s += 2, base = 16;
  800b7a:	83 c1 02             	add    $0x2,%ecx
  800b7d:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  800b84:	eb 11                	jmp    800b97 <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
  800b86:	41                   	inc    %ecx
  800b87:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  800b8e:	eb 07                	jmp    800b97 <strtol+0x6a>
	else if (base == 0)
		base = 10;
  800b90:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)
  800b97:	b8 00 00 00 00       	mov    $0x0,%eax

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b9c:	8a 11                	mov    (%ecx),%dl
  800b9e:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800ba1:	80 fb 09             	cmp    $0x9,%bl
  800ba4:	77 08                	ja     800bae <strtol+0x81>
			dig = *s - '0';
  800ba6:	0f be d2             	movsbl %dl,%edx
  800ba9:	83 ea 30             	sub    $0x30,%edx
  800bac:	eb 22                	jmp    800bd0 <strtol+0xa3>
		else if (*s >= 'a' && *s <= 'z')
  800bae:	8d 72 9f             	lea    -0x61(%edx),%esi
  800bb1:	89 f3                	mov    %esi,%ebx
  800bb3:	80 fb 19             	cmp    $0x19,%bl
  800bb6:	77 08                	ja     800bc0 <strtol+0x93>
			dig = *s - 'a' + 10;
  800bb8:	0f be d2             	movsbl %dl,%edx
  800bbb:	83 ea 57             	sub    $0x57,%edx
  800bbe:	eb 10                	jmp    800bd0 <strtol+0xa3>
		else if (*s >= 'A' && *s <= 'Z')
  800bc0:	8d 72 bf             	lea    -0x41(%edx),%esi
  800bc3:	89 f3                	mov    %esi,%ebx
  800bc5:	80 fb 19             	cmp    $0x19,%bl
  800bc8:	77 14                	ja     800bde <strtol+0xb1>
			dig = *s - 'A' + 10;
  800bca:	0f be d2             	movsbl %dl,%edx
  800bcd:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800bd0:	3b 55 10             	cmp    0x10(%ebp),%edx
  800bd3:	7d 09                	jge    800bde <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800bd5:	41                   	inc    %ecx
  800bd6:	0f af 45 10          	imul   0x10(%ebp),%eax
  800bda:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800bdc:	eb be                	jmp    800b9c <strtol+0x6f>

	if (endptr)
  800bde:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800be2:	74 05                	je     800be9 <strtol+0xbc>
		*endptr = (char *) s;
  800be4:	8b 75 0c             	mov    0xc(%ebp),%esi
  800be7:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800be9:	85 ff                	test   %edi,%edi
  800beb:	74 21                	je     800c0e <strtol+0xe1>
  800bed:	f7 d8                	neg    %eax
  800bef:	eb 1d                	jmp    800c0e <strtol+0xe1>
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bf1:	80 39 30             	cmpb   $0x30,(%ecx)
  800bf4:	75 9a                	jne    800b90 <strtol+0x63>
  800bf6:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800bfa:	0f 84 7a ff ff ff    	je     800b7a <strtol+0x4d>
  800c00:	eb 84                	jmp    800b86 <strtol+0x59>
  800c02:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c06:	0f 84 6e ff ff ff    	je     800b7a <strtol+0x4d>
  800c0c:	eb 89                	jmp    800b97 <strtol+0x6a>
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
}
  800c0e:	5b                   	pop    %ebx
  800c0f:	5e                   	pop    %esi
  800c10:	5f                   	pop    %edi
  800c11:	5d                   	pop    %ebp
  800c12:	c3                   	ret    

00800c13 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c13:	55                   	push   %ebp
  800c14:	89 e5                	mov    %esp,%ebp
  800c16:	57                   	push   %edi
  800c17:	56                   	push   %esi
  800c18:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c19:	b8 00 00 00 00       	mov    $0x0,%eax
  800c1e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c21:	8b 55 08             	mov    0x8(%ebp),%edx
  800c24:	89 c3                	mov    %eax,%ebx
  800c26:	89 c7                	mov    %eax,%edi
  800c28:	89 c6                	mov    %eax,%esi
  800c2a:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c2c:	5b                   	pop    %ebx
  800c2d:	5e                   	pop    %esi
  800c2e:	5f                   	pop    %edi
  800c2f:	5d                   	pop    %ebp
  800c30:	c3                   	ret    

00800c31 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c31:	55                   	push   %ebp
  800c32:	89 e5                	mov    %esp,%ebp
  800c34:	57                   	push   %edi
  800c35:	56                   	push   %esi
  800c36:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c37:	ba 00 00 00 00       	mov    $0x0,%edx
  800c3c:	b8 01 00 00 00       	mov    $0x1,%eax
  800c41:	89 d1                	mov    %edx,%ecx
  800c43:	89 d3                	mov    %edx,%ebx
  800c45:	89 d7                	mov    %edx,%edi
  800c47:	89 d6                	mov    %edx,%esi
  800c49:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c4b:	5b                   	pop    %ebx
  800c4c:	5e                   	pop    %esi
  800c4d:	5f                   	pop    %edi
  800c4e:	5d                   	pop    %ebp
  800c4f:	c3                   	ret    

00800c50 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c50:	55                   	push   %ebp
  800c51:	89 e5                	mov    %esp,%ebp
  800c53:	57                   	push   %edi
  800c54:	56                   	push   %esi
  800c55:	53                   	push   %ebx
  800c56:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c59:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c5e:	b8 03 00 00 00       	mov    $0x3,%eax
  800c63:	8b 55 08             	mov    0x8(%ebp),%edx
  800c66:	89 cb                	mov    %ecx,%ebx
  800c68:	89 cf                	mov    %ecx,%edi
  800c6a:	89 ce                	mov    %ecx,%esi
  800c6c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c6e:	85 c0                	test   %eax,%eax
  800c70:	7e 17                	jle    800c89 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c72:	83 ec 0c             	sub    $0xc,%esp
  800c75:	50                   	push   %eax
  800c76:	6a 03                	push   $0x3
  800c78:	68 bf 23 80 00       	push   $0x8023bf
  800c7d:	6a 23                	push   $0x23
  800c7f:	68 dc 23 80 00       	push   $0x8023dc
  800c84:	e8 19 f5 ff ff       	call   8001a2 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c89:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c8c:	5b                   	pop    %ebx
  800c8d:	5e                   	pop    %esi
  800c8e:	5f                   	pop    %edi
  800c8f:	5d                   	pop    %ebp
  800c90:	c3                   	ret    

00800c91 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c91:	55                   	push   %ebp
  800c92:	89 e5                	mov    %esp,%ebp
  800c94:	57                   	push   %edi
  800c95:	56                   	push   %esi
  800c96:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c97:	ba 00 00 00 00       	mov    $0x0,%edx
  800c9c:	b8 02 00 00 00       	mov    $0x2,%eax
  800ca1:	89 d1                	mov    %edx,%ecx
  800ca3:	89 d3                	mov    %edx,%ebx
  800ca5:	89 d7                	mov    %edx,%edi
  800ca7:	89 d6                	mov    %edx,%esi
  800ca9:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800cab:	5b                   	pop    %ebx
  800cac:	5e                   	pop    %esi
  800cad:	5f                   	pop    %edi
  800cae:	5d                   	pop    %ebp
  800caf:	c3                   	ret    

00800cb0 <sys_yield>:

void
sys_yield(void)
{
  800cb0:	55                   	push   %ebp
  800cb1:	89 e5                	mov    %esp,%ebp
  800cb3:	57                   	push   %edi
  800cb4:	56                   	push   %esi
  800cb5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cb6:	ba 00 00 00 00       	mov    $0x0,%edx
  800cbb:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cc0:	89 d1                	mov    %edx,%ecx
  800cc2:	89 d3                	mov    %edx,%ebx
  800cc4:	89 d7                	mov    %edx,%edi
  800cc6:	89 d6                	mov    %edx,%esi
  800cc8:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800cca:	5b                   	pop    %ebx
  800ccb:	5e                   	pop    %esi
  800ccc:	5f                   	pop    %edi
  800ccd:	5d                   	pop    %ebp
  800cce:	c3                   	ret    

00800ccf <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
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
  800cd8:	be 00 00 00 00       	mov    $0x0,%esi
  800cdd:	b8 04 00 00 00       	mov    $0x4,%eax
  800ce2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce5:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ceb:	89 f7                	mov    %esi,%edi
  800ced:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cef:	85 c0                	test   %eax,%eax
  800cf1:	7e 17                	jle    800d0a <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cf3:	83 ec 0c             	sub    $0xc,%esp
  800cf6:	50                   	push   %eax
  800cf7:	6a 04                	push   $0x4
  800cf9:	68 bf 23 80 00       	push   $0x8023bf
  800cfe:	6a 23                	push   $0x23
  800d00:	68 dc 23 80 00       	push   $0x8023dc
  800d05:	e8 98 f4 ff ff       	call   8001a2 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d0a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d0d:	5b                   	pop    %ebx
  800d0e:	5e                   	pop    %esi
  800d0f:	5f                   	pop    %edi
  800d10:	5d                   	pop    %ebp
  800d11:	c3                   	ret    

00800d12 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
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
  800d1b:	b8 05 00 00 00       	mov    $0x5,%eax
  800d20:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d23:	8b 55 08             	mov    0x8(%ebp),%edx
  800d26:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d29:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d2c:	8b 75 18             	mov    0x18(%ebp),%esi
  800d2f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d31:	85 c0                	test   %eax,%eax
  800d33:	7e 17                	jle    800d4c <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d35:	83 ec 0c             	sub    $0xc,%esp
  800d38:	50                   	push   %eax
  800d39:	6a 05                	push   $0x5
  800d3b:	68 bf 23 80 00       	push   $0x8023bf
  800d40:	6a 23                	push   $0x23
  800d42:	68 dc 23 80 00       	push   $0x8023dc
  800d47:	e8 56 f4 ff ff       	call   8001a2 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d4c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d4f:	5b                   	pop    %ebx
  800d50:	5e                   	pop    %esi
  800d51:	5f                   	pop    %edi
  800d52:	5d                   	pop    %ebp
  800d53:	c3                   	ret    

00800d54 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
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
  800d62:	b8 06 00 00 00       	mov    $0x6,%eax
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
  800d75:	7e 17                	jle    800d8e <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d77:	83 ec 0c             	sub    $0xc,%esp
  800d7a:	50                   	push   %eax
  800d7b:	6a 06                	push   $0x6
  800d7d:	68 bf 23 80 00       	push   $0x8023bf
  800d82:	6a 23                	push   $0x23
  800d84:	68 dc 23 80 00       	push   $0x8023dc
  800d89:	e8 14 f4 ff ff       	call   8001a2 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d8e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d91:	5b                   	pop    %ebx
  800d92:	5e                   	pop    %esi
  800d93:	5f                   	pop    %edi
  800d94:	5d                   	pop    %ebp
  800d95:	c3                   	ret    

00800d96 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
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
  800da4:	b8 08 00 00 00       	mov    $0x8,%eax
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
  800db7:	7e 17                	jle    800dd0 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800db9:	83 ec 0c             	sub    $0xc,%esp
  800dbc:	50                   	push   %eax
  800dbd:	6a 08                	push   $0x8
  800dbf:	68 bf 23 80 00       	push   $0x8023bf
  800dc4:	6a 23                	push   $0x23
  800dc6:	68 dc 23 80 00       	push   $0x8023dc
  800dcb:	e8 d2 f3 ff ff       	call   8001a2 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800dd0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dd3:	5b                   	pop    %ebx
  800dd4:	5e                   	pop    %esi
  800dd5:	5f                   	pop    %edi
  800dd6:	5d                   	pop    %ebp
  800dd7:	c3                   	ret    

00800dd8 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800dd8:	55                   	push   %ebp
  800dd9:	89 e5                	mov    %esp,%ebp
  800ddb:	57                   	push   %edi
  800ddc:	56                   	push   %esi
  800ddd:	53                   	push   %ebx
  800dde:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800de1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800de6:	b8 09 00 00 00       	mov    $0x9,%eax
  800deb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dee:	8b 55 08             	mov    0x8(%ebp),%edx
  800df1:	89 df                	mov    %ebx,%edi
  800df3:	89 de                	mov    %ebx,%esi
  800df5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800df7:	85 c0                	test   %eax,%eax
  800df9:	7e 17                	jle    800e12 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dfb:	83 ec 0c             	sub    $0xc,%esp
  800dfe:	50                   	push   %eax
  800dff:	6a 09                	push   $0x9
  800e01:	68 bf 23 80 00       	push   $0x8023bf
  800e06:	6a 23                	push   $0x23
  800e08:	68 dc 23 80 00       	push   $0x8023dc
  800e0d:	e8 90 f3 ff ff       	call   8001a2 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e12:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e15:	5b                   	pop    %ebx
  800e16:	5e                   	pop    %esi
  800e17:	5f                   	pop    %edi
  800e18:	5d                   	pop    %ebp
  800e19:	c3                   	ret    

00800e1a <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e1a:	55                   	push   %ebp
  800e1b:	89 e5                	mov    %esp,%ebp
  800e1d:	57                   	push   %edi
  800e1e:	56                   	push   %esi
  800e1f:	53                   	push   %ebx
  800e20:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e23:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e28:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e2d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e30:	8b 55 08             	mov    0x8(%ebp),%edx
  800e33:	89 df                	mov    %ebx,%edi
  800e35:	89 de                	mov    %ebx,%esi
  800e37:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e39:	85 c0                	test   %eax,%eax
  800e3b:	7e 17                	jle    800e54 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e3d:	83 ec 0c             	sub    $0xc,%esp
  800e40:	50                   	push   %eax
  800e41:	6a 0a                	push   $0xa
  800e43:	68 bf 23 80 00       	push   $0x8023bf
  800e48:	6a 23                	push   $0x23
  800e4a:	68 dc 23 80 00       	push   $0x8023dc
  800e4f:	e8 4e f3 ff ff       	call   8001a2 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e54:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e57:	5b                   	pop    %ebx
  800e58:	5e                   	pop    %esi
  800e59:	5f                   	pop    %edi
  800e5a:	5d                   	pop    %ebp
  800e5b:	c3                   	ret    

00800e5c <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e5c:	55                   	push   %ebp
  800e5d:	89 e5                	mov    %esp,%ebp
  800e5f:	57                   	push   %edi
  800e60:	56                   	push   %esi
  800e61:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e62:	be 00 00 00 00       	mov    $0x0,%esi
  800e67:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e6c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e6f:	8b 55 08             	mov    0x8(%ebp),%edx
  800e72:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e75:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e78:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e7a:	5b                   	pop    %ebx
  800e7b:	5e                   	pop    %esi
  800e7c:	5f                   	pop    %edi
  800e7d:	5d                   	pop    %ebp
  800e7e:	c3                   	ret    

00800e7f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e7f:	55                   	push   %ebp
  800e80:	89 e5                	mov    %esp,%ebp
  800e82:	57                   	push   %edi
  800e83:	56                   	push   %esi
  800e84:	53                   	push   %ebx
  800e85:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e88:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e8d:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e92:	8b 55 08             	mov    0x8(%ebp),%edx
  800e95:	89 cb                	mov    %ecx,%ebx
  800e97:	89 cf                	mov    %ecx,%edi
  800e99:	89 ce                	mov    %ecx,%esi
  800e9b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e9d:	85 c0                	test   %eax,%eax
  800e9f:	7e 17                	jle    800eb8 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ea1:	83 ec 0c             	sub    $0xc,%esp
  800ea4:	50                   	push   %eax
  800ea5:	6a 0d                	push   $0xd
  800ea7:	68 bf 23 80 00       	push   $0x8023bf
  800eac:	6a 23                	push   $0x23
  800eae:	68 dc 23 80 00       	push   $0x8023dc
  800eb3:	e8 ea f2 ff ff       	call   8001a2 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800eb8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ebb:	5b                   	pop    %ebx
  800ebc:	5e                   	pop    %esi
  800ebd:	5f                   	pop    %edi
  800ebe:	5d                   	pop    %ebp
  800ebf:	c3                   	ret    

00800ec0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800ec0:	55                   	push   %ebp
  800ec1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800ec3:	8b 45 08             	mov    0x8(%ebp),%eax
  800ec6:	05 00 00 00 30       	add    $0x30000000,%eax
  800ecb:	c1 e8 0c             	shr    $0xc,%eax
}
  800ece:	5d                   	pop    %ebp
  800ecf:	c3                   	ret    

00800ed0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800ed0:	55                   	push   %ebp
  800ed1:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800ed3:	8b 45 08             	mov    0x8(%ebp),%eax
  800ed6:	05 00 00 00 30       	add    $0x30000000,%eax
  800edb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800ee0:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800ee5:	5d                   	pop    %ebp
  800ee6:	c3                   	ret    

00800ee7 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800ee7:	55                   	push   %ebp
  800ee8:	89 e5                	mov    %esp,%ebp
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800eea:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  800eef:	a8 01                	test   $0x1,%al
  800ef1:	74 34                	je     800f27 <fd_alloc+0x40>
  800ef3:	a1 00 00 74 ef       	mov    0xef740000,%eax
  800ef8:	a8 01                	test   $0x1,%al
  800efa:	74 32                	je     800f2e <fd_alloc+0x47>
  800efc:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800f01:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800f03:	89 c2                	mov    %eax,%edx
  800f05:	c1 ea 16             	shr    $0x16,%edx
  800f08:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f0f:	f6 c2 01             	test   $0x1,%dl
  800f12:	74 1f                	je     800f33 <fd_alloc+0x4c>
  800f14:	89 c2                	mov    %eax,%edx
  800f16:	c1 ea 0c             	shr    $0xc,%edx
  800f19:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f20:	f6 c2 01             	test   $0x1,%dl
  800f23:	75 1a                	jne    800f3f <fd_alloc+0x58>
  800f25:	eb 0c                	jmp    800f33 <fd_alloc+0x4c>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800f27:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  800f2c:	eb 05                	jmp    800f33 <fd_alloc+0x4c>
  800f2e:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  800f33:	8b 45 08             	mov    0x8(%ebp),%eax
  800f36:	89 08                	mov    %ecx,(%eax)
			return 0;
  800f38:	b8 00 00 00 00       	mov    $0x0,%eax
  800f3d:	eb 1a                	jmp    800f59 <fd_alloc+0x72>
  800f3f:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800f44:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800f49:	75 b6                	jne    800f01 <fd_alloc+0x1a>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800f4b:	8b 45 08             	mov    0x8(%ebp),%eax
  800f4e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  800f54:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800f59:	5d                   	pop    %ebp
  800f5a:	c3                   	ret    

00800f5b <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800f5b:	55                   	push   %ebp
  800f5c:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800f5e:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
  800f62:	77 39                	ja     800f9d <fd_lookup+0x42>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800f64:	8b 45 08             	mov    0x8(%ebp),%eax
  800f67:	c1 e0 0c             	shl    $0xc,%eax
  800f6a:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800f6f:	89 c2                	mov    %eax,%edx
  800f71:	c1 ea 16             	shr    $0x16,%edx
  800f74:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f7b:	f6 c2 01             	test   $0x1,%dl
  800f7e:	74 24                	je     800fa4 <fd_lookup+0x49>
  800f80:	89 c2                	mov    %eax,%edx
  800f82:	c1 ea 0c             	shr    $0xc,%edx
  800f85:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f8c:	f6 c2 01             	test   $0x1,%dl
  800f8f:	74 1a                	je     800fab <fd_lookup+0x50>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800f91:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f94:	89 02                	mov    %eax,(%edx)
	return 0;
  800f96:	b8 00 00 00 00       	mov    $0x0,%eax
  800f9b:	eb 13                	jmp    800fb0 <fd_lookup+0x55>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f9d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800fa2:	eb 0c                	jmp    800fb0 <fd_lookup+0x55>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800fa4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800fa9:	eb 05                	jmp    800fb0 <fd_lookup+0x55>
  800fab:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800fb0:	5d                   	pop    %ebp
  800fb1:	c3                   	ret    

00800fb2 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800fb2:	55                   	push   %ebp
  800fb3:	89 e5                	mov    %esp,%ebp
  800fb5:	53                   	push   %ebx
  800fb6:	83 ec 04             	sub    $0x4,%esp
  800fb9:	8b 45 08             	mov    0x8(%ebp),%eax
  800fbc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  800fbf:	3b 05 04 30 80 00    	cmp    0x803004,%eax
  800fc5:	75 1e                	jne    800fe5 <dev_lookup+0x33>
  800fc7:	eb 0e                	jmp    800fd7 <dev_lookup+0x25>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800fc9:	b8 20 30 80 00       	mov    $0x803020,%eax
  800fce:	eb 0c                	jmp    800fdc <dev_lookup+0x2a>
  800fd0:	b8 3c 30 80 00       	mov    $0x80303c,%eax
  800fd5:	eb 05                	jmp    800fdc <dev_lookup+0x2a>
  800fd7:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  800fdc:	89 03                	mov    %eax,(%ebx)
			return 0;
  800fde:	b8 00 00 00 00       	mov    $0x0,%eax
  800fe3:	eb 36                	jmp    80101b <dev_lookup+0x69>
int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  800fe5:	3b 05 20 30 80 00    	cmp    0x803020,%eax
  800feb:	74 dc                	je     800fc9 <dev_lookup+0x17>
  800fed:	3b 05 3c 30 80 00    	cmp    0x80303c,%eax
  800ff3:	74 db                	je     800fd0 <dev_lookup+0x1e>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800ff5:	8b 15 20 60 80 00    	mov    0x806020,%edx
  800ffb:	8b 52 48             	mov    0x48(%edx),%edx
  800ffe:	83 ec 04             	sub    $0x4,%esp
  801001:	50                   	push   %eax
  801002:	52                   	push   %edx
  801003:	68 ec 23 80 00       	push   $0x8023ec
  801008:	e8 6d f2 ff ff       	call   80027a <cprintf>
	*dev = 0;
  80100d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  801013:	83 c4 10             	add    $0x10,%esp
  801016:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80101b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80101e:	c9                   	leave  
  80101f:	c3                   	ret    

00801020 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801020:	55                   	push   %ebp
  801021:	89 e5                	mov    %esp,%ebp
  801023:	56                   	push   %esi
  801024:	53                   	push   %ebx
  801025:	83 ec 10             	sub    $0x10,%esp
  801028:	8b 75 08             	mov    0x8(%ebp),%esi
  80102b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80102e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801031:	50                   	push   %eax
  801032:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801038:	c1 e8 0c             	shr    $0xc,%eax
  80103b:	50                   	push   %eax
  80103c:	e8 1a ff ff ff       	call   800f5b <fd_lookup>
  801041:	83 c4 08             	add    $0x8,%esp
  801044:	85 c0                	test   %eax,%eax
  801046:	78 05                	js     80104d <fd_close+0x2d>
	    || fd != fd2)
  801048:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80104b:	74 06                	je     801053 <fd_close+0x33>
		return (must_exist ? r : 0);
  80104d:	84 db                	test   %bl,%bl
  80104f:	74 47                	je     801098 <fd_close+0x78>
  801051:	eb 4a                	jmp    80109d <fd_close+0x7d>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801053:	83 ec 08             	sub    $0x8,%esp
  801056:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801059:	50                   	push   %eax
  80105a:	ff 36                	pushl  (%esi)
  80105c:	e8 51 ff ff ff       	call   800fb2 <dev_lookup>
  801061:	89 c3                	mov    %eax,%ebx
  801063:	83 c4 10             	add    $0x10,%esp
  801066:	85 c0                	test   %eax,%eax
  801068:	78 1c                	js     801086 <fd_close+0x66>
		if (dev->dev_close)
  80106a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80106d:	8b 40 10             	mov    0x10(%eax),%eax
  801070:	85 c0                	test   %eax,%eax
  801072:	74 0d                	je     801081 <fd_close+0x61>
			r = (*dev->dev_close)(fd);
  801074:	83 ec 0c             	sub    $0xc,%esp
  801077:	56                   	push   %esi
  801078:	ff d0                	call   *%eax
  80107a:	89 c3                	mov    %eax,%ebx
  80107c:	83 c4 10             	add    $0x10,%esp
  80107f:	eb 05                	jmp    801086 <fd_close+0x66>
		else
			r = 0;
  801081:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801086:	83 ec 08             	sub    $0x8,%esp
  801089:	56                   	push   %esi
  80108a:	6a 00                	push   $0x0
  80108c:	e8 c3 fc ff ff       	call   800d54 <sys_page_unmap>
	return r;
  801091:	83 c4 10             	add    $0x10,%esp
  801094:	89 d8                	mov    %ebx,%eax
  801096:	eb 05                	jmp    80109d <fd_close+0x7d>
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
  801098:	b8 00 00 00 00       	mov    $0x0,%eax
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
	return r;
}
  80109d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010a0:	5b                   	pop    %ebx
  8010a1:	5e                   	pop    %esi
  8010a2:	5d                   	pop    %ebp
  8010a3:	c3                   	ret    

008010a4 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8010a4:	55                   	push   %ebp
  8010a5:	89 e5                	mov    %esp,%ebp
  8010a7:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8010aa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010ad:	50                   	push   %eax
  8010ae:	ff 75 08             	pushl  0x8(%ebp)
  8010b1:	e8 a5 fe ff ff       	call   800f5b <fd_lookup>
  8010b6:	83 c4 08             	add    $0x8,%esp
  8010b9:	85 c0                	test   %eax,%eax
  8010bb:	78 10                	js     8010cd <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8010bd:	83 ec 08             	sub    $0x8,%esp
  8010c0:	6a 01                	push   $0x1
  8010c2:	ff 75 f4             	pushl  -0xc(%ebp)
  8010c5:	e8 56 ff ff ff       	call   801020 <fd_close>
  8010ca:	83 c4 10             	add    $0x10,%esp
}
  8010cd:	c9                   	leave  
  8010ce:	c3                   	ret    

008010cf <close_all>:

void
close_all(void)
{
  8010cf:	55                   	push   %ebp
  8010d0:	89 e5                	mov    %esp,%ebp
  8010d2:	53                   	push   %ebx
  8010d3:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8010d6:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8010db:	83 ec 0c             	sub    $0xc,%esp
  8010de:	53                   	push   %ebx
  8010df:	e8 c0 ff ff ff       	call   8010a4 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8010e4:	43                   	inc    %ebx
  8010e5:	83 c4 10             	add    $0x10,%esp
  8010e8:	83 fb 20             	cmp    $0x20,%ebx
  8010eb:	75 ee                	jne    8010db <close_all+0xc>
		close(i);
}
  8010ed:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010f0:	c9                   	leave  
  8010f1:	c3                   	ret    

008010f2 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8010f2:	55                   	push   %ebp
  8010f3:	89 e5                	mov    %esp,%ebp
  8010f5:	57                   	push   %edi
  8010f6:	56                   	push   %esi
  8010f7:	53                   	push   %ebx
  8010f8:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8010fb:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8010fe:	50                   	push   %eax
  8010ff:	ff 75 08             	pushl  0x8(%ebp)
  801102:	e8 54 fe ff ff       	call   800f5b <fd_lookup>
  801107:	83 c4 08             	add    $0x8,%esp
  80110a:	85 c0                	test   %eax,%eax
  80110c:	0f 88 c2 00 00 00    	js     8011d4 <dup+0xe2>
		return r;
	close(newfdnum);
  801112:	83 ec 0c             	sub    $0xc,%esp
  801115:	ff 75 0c             	pushl  0xc(%ebp)
  801118:	e8 87 ff ff ff       	call   8010a4 <close>

	newfd = INDEX2FD(newfdnum);
  80111d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801120:	c1 e3 0c             	shl    $0xc,%ebx
  801123:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801129:	83 c4 04             	add    $0x4,%esp
  80112c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80112f:	e8 9c fd ff ff       	call   800ed0 <fd2data>
  801134:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  801136:	89 1c 24             	mov    %ebx,(%esp)
  801139:	e8 92 fd ff ff       	call   800ed0 <fd2data>
  80113e:	83 c4 10             	add    $0x10,%esp
  801141:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801143:	89 f0                	mov    %esi,%eax
  801145:	c1 e8 16             	shr    $0x16,%eax
  801148:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80114f:	a8 01                	test   $0x1,%al
  801151:	74 35                	je     801188 <dup+0x96>
  801153:	89 f0                	mov    %esi,%eax
  801155:	c1 e8 0c             	shr    $0xc,%eax
  801158:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80115f:	f6 c2 01             	test   $0x1,%dl
  801162:	74 24                	je     801188 <dup+0x96>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801164:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80116b:	83 ec 0c             	sub    $0xc,%esp
  80116e:	25 07 0e 00 00       	and    $0xe07,%eax
  801173:	50                   	push   %eax
  801174:	57                   	push   %edi
  801175:	6a 00                	push   $0x0
  801177:	56                   	push   %esi
  801178:	6a 00                	push   $0x0
  80117a:	e8 93 fb ff ff       	call   800d12 <sys_page_map>
  80117f:	89 c6                	mov    %eax,%esi
  801181:	83 c4 20             	add    $0x20,%esp
  801184:	85 c0                	test   %eax,%eax
  801186:	78 2c                	js     8011b4 <dup+0xc2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801188:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80118b:	89 d0                	mov    %edx,%eax
  80118d:	c1 e8 0c             	shr    $0xc,%eax
  801190:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801197:	83 ec 0c             	sub    $0xc,%esp
  80119a:	25 07 0e 00 00       	and    $0xe07,%eax
  80119f:	50                   	push   %eax
  8011a0:	53                   	push   %ebx
  8011a1:	6a 00                	push   $0x0
  8011a3:	52                   	push   %edx
  8011a4:	6a 00                	push   $0x0
  8011a6:	e8 67 fb ff ff       	call   800d12 <sys_page_map>
  8011ab:	89 c6                	mov    %eax,%esi
  8011ad:	83 c4 20             	add    $0x20,%esp
  8011b0:	85 c0                	test   %eax,%eax
  8011b2:	79 1d                	jns    8011d1 <dup+0xdf>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8011b4:	83 ec 08             	sub    $0x8,%esp
  8011b7:	53                   	push   %ebx
  8011b8:	6a 00                	push   $0x0
  8011ba:	e8 95 fb ff ff       	call   800d54 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8011bf:	83 c4 08             	add    $0x8,%esp
  8011c2:	57                   	push   %edi
  8011c3:	6a 00                	push   $0x0
  8011c5:	e8 8a fb ff ff       	call   800d54 <sys_page_unmap>
	return r;
  8011ca:	83 c4 10             	add    $0x10,%esp
  8011cd:	89 f0                	mov    %esi,%eax
  8011cf:	eb 03                	jmp    8011d4 <dup+0xe2>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  8011d1:	8b 45 0c             	mov    0xc(%ebp),%eax

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8011d4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011d7:	5b                   	pop    %ebx
  8011d8:	5e                   	pop    %esi
  8011d9:	5f                   	pop    %edi
  8011da:	5d                   	pop    %ebp
  8011db:	c3                   	ret    

008011dc <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8011dc:	55                   	push   %ebp
  8011dd:	89 e5                	mov    %esp,%ebp
  8011df:	53                   	push   %ebx
  8011e0:	83 ec 14             	sub    $0x14,%esp
  8011e3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011e6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011e9:	50                   	push   %eax
  8011ea:	53                   	push   %ebx
  8011eb:	e8 6b fd ff ff       	call   800f5b <fd_lookup>
  8011f0:	83 c4 08             	add    $0x8,%esp
  8011f3:	85 c0                	test   %eax,%eax
  8011f5:	78 67                	js     80125e <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011f7:	83 ec 08             	sub    $0x8,%esp
  8011fa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011fd:	50                   	push   %eax
  8011fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801201:	ff 30                	pushl  (%eax)
  801203:	e8 aa fd ff ff       	call   800fb2 <dev_lookup>
  801208:	83 c4 10             	add    $0x10,%esp
  80120b:	85 c0                	test   %eax,%eax
  80120d:	78 4f                	js     80125e <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80120f:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801212:	8b 42 08             	mov    0x8(%edx),%eax
  801215:	83 e0 03             	and    $0x3,%eax
  801218:	83 f8 01             	cmp    $0x1,%eax
  80121b:	75 21                	jne    80123e <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80121d:	a1 20 60 80 00       	mov    0x806020,%eax
  801222:	8b 40 48             	mov    0x48(%eax),%eax
  801225:	83 ec 04             	sub    $0x4,%esp
  801228:	53                   	push   %ebx
  801229:	50                   	push   %eax
  80122a:	68 30 24 80 00       	push   $0x802430
  80122f:	e8 46 f0 ff ff       	call   80027a <cprintf>
		return -E_INVAL;
  801234:	83 c4 10             	add    $0x10,%esp
  801237:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80123c:	eb 20                	jmp    80125e <read+0x82>
	}
	if (!dev->dev_read)
  80123e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801241:	8b 40 08             	mov    0x8(%eax),%eax
  801244:	85 c0                	test   %eax,%eax
  801246:	74 11                	je     801259 <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801248:	83 ec 04             	sub    $0x4,%esp
  80124b:	ff 75 10             	pushl  0x10(%ebp)
  80124e:	ff 75 0c             	pushl  0xc(%ebp)
  801251:	52                   	push   %edx
  801252:	ff d0                	call   *%eax
  801254:	83 c4 10             	add    $0x10,%esp
  801257:	eb 05                	jmp    80125e <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801259:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  80125e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801261:	c9                   	leave  
  801262:	c3                   	ret    

00801263 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801263:	55                   	push   %ebp
  801264:	89 e5                	mov    %esp,%ebp
  801266:	57                   	push   %edi
  801267:	56                   	push   %esi
  801268:	53                   	push   %ebx
  801269:	83 ec 0c             	sub    $0xc,%esp
  80126c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80126f:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801272:	85 f6                	test   %esi,%esi
  801274:	74 31                	je     8012a7 <readn+0x44>
  801276:	b8 00 00 00 00       	mov    $0x0,%eax
  80127b:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  801280:	83 ec 04             	sub    $0x4,%esp
  801283:	89 f2                	mov    %esi,%edx
  801285:	29 c2                	sub    %eax,%edx
  801287:	52                   	push   %edx
  801288:	03 45 0c             	add    0xc(%ebp),%eax
  80128b:	50                   	push   %eax
  80128c:	57                   	push   %edi
  80128d:	e8 4a ff ff ff       	call   8011dc <read>
		if (m < 0)
  801292:	83 c4 10             	add    $0x10,%esp
  801295:	85 c0                	test   %eax,%eax
  801297:	78 17                	js     8012b0 <readn+0x4d>
			return m;
		if (m == 0)
  801299:	85 c0                	test   %eax,%eax
  80129b:	74 11                	je     8012ae <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80129d:	01 c3                	add    %eax,%ebx
  80129f:	89 d8                	mov    %ebx,%eax
  8012a1:	39 f3                	cmp    %esi,%ebx
  8012a3:	72 db                	jb     801280 <readn+0x1d>
  8012a5:	eb 09                	jmp    8012b0 <readn+0x4d>
  8012a7:	b8 00 00 00 00       	mov    $0x0,%eax
  8012ac:	eb 02                	jmp    8012b0 <readn+0x4d>
  8012ae:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8012b0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012b3:	5b                   	pop    %ebx
  8012b4:	5e                   	pop    %esi
  8012b5:	5f                   	pop    %edi
  8012b6:	5d                   	pop    %ebp
  8012b7:	c3                   	ret    

008012b8 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8012b8:	55                   	push   %ebp
  8012b9:	89 e5                	mov    %esp,%ebp
  8012bb:	53                   	push   %ebx
  8012bc:	83 ec 14             	sub    $0x14,%esp
  8012bf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012c2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012c5:	50                   	push   %eax
  8012c6:	53                   	push   %ebx
  8012c7:	e8 8f fc ff ff       	call   800f5b <fd_lookup>
  8012cc:	83 c4 08             	add    $0x8,%esp
  8012cf:	85 c0                	test   %eax,%eax
  8012d1:	78 62                	js     801335 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012d3:	83 ec 08             	sub    $0x8,%esp
  8012d6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012d9:	50                   	push   %eax
  8012da:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012dd:	ff 30                	pushl  (%eax)
  8012df:	e8 ce fc ff ff       	call   800fb2 <dev_lookup>
  8012e4:	83 c4 10             	add    $0x10,%esp
  8012e7:	85 c0                	test   %eax,%eax
  8012e9:	78 4a                	js     801335 <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012ee:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012f2:	75 21                	jne    801315 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8012f4:	a1 20 60 80 00       	mov    0x806020,%eax
  8012f9:	8b 40 48             	mov    0x48(%eax),%eax
  8012fc:	83 ec 04             	sub    $0x4,%esp
  8012ff:	53                   	push   %ebx
  801300:	50                   	push   %eax
  801301:	68 4c 24 80 00       	push   $0x80244c
  801306:	e8 6f ef ff ff       	call   80027a <cprintf>
		return -E_INVAL;
  80130b:	83 c4 10             	add    $0x10,%esp
  80130e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801313:	eb 20                	jmp    801335 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801315:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801318:	8b 52 0c             	mov    0xc(%edx),%edx
  80131b:	85 d2                	test   %edx,%edx
  80131d:	74 11                	je     801330 <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80131f:	83 ec 04             	sub    $0x4,%esp
  801322:	ff 75 10             	pushl  0x10(%ebp)
  801325:	ff 75 0c             	pushl  0xc(%ebp)
  801328:	50                   	push   %eax
  801329:	ff d2                	call   *%edx
  80132b:	83 c4 10             	add    $0x10,%esp
  80132e:	eb 05                	jmp    801335 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801330:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801335:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801338:	c9                   	leave  
  801339:	c3                   	ret    

0080133a <seek>:

int
seek(int fdnum, off_t offset)
{
  80133a:	55                   	push   %ebp
  80133b:	89 e5                	mov    %esp,%ebp
  80133d:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801340:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801343:	50                   	push   %eax
  801344:	ff 75 08             	pushl  0x8(%ebp)
  801347:	e8 0f fc ff ff       	call   800f5b <fd_lookup>
  80134c:	83 c4 08             	add    $0x8,%esp
  80134f:	85 c0                	test   %eax,%eax
  801351:	78 0e                	js     801361 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801353:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801356:	8b 55 0c             	mov    0xc(%ebp),%edx
  801359:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80135c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801361:	c9                   	leave  
  801362:	c3                   	ret    

00801363 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801363:	55                   	push   %ebp
  801364:	89 e5                	mov    %esp,%ebp
  801366:	53                   	push   %ebx
  801367:	83 ec 14             	sub    $0x14,%esp
  80136a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80136d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801370:	50                   	push   %eax
  801371:	53                   	push   %ebx
  801372:	e8 e4 fb ff ff       	call   800f5b <fd_lookup>
  801377:	83 c4 08             	add    $0x8,%esp
  80137a:	85 c0                	test   %eax,%eax
  80137c:	78 5f                	js     8013dd <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80137e:	83 ec 08             	sub    $0x8,%esp
  801381:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801384:	50                   	push   %eax
  801385:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801388:	ff 30                	pushl  (%eax)
  80138a:	e8 23 fc ff ff       	call   800fb2 <dev_lookup>
  80138f:	83 c4 10             	add    $0x10,%esp
  801392:	85 c0                	test   %eax,%eax
  801394:	78 47                	js     8013dd <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801396:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801399:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80139d:	75 21                	jne    8013c0 <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80139f:	a1 20 60 80 00       	mov    0x806020,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8013a4:	8b 40 48             	mov    0x48(%eax),%eax
  8013a7:	83 ec 04             	sub    $0x4,%esp
  8013aa:	53                   	push   %ebx
  8013ab:	50                   	push   %eax
  8013ac:	68 0c 24 80 00       	push   $0x80240c
  8013b1:	e8 c4 ee ff ff       	call   80027a <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8013b6:	83 c4 10             	add    $0x10,%esp
  8013b9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013be:	eb 1d                	jmp    8013dd <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  8013c0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8013c3:	8b 52 18             	mov    0x18(%edx),%edx
  8013c6:	85 d2                	test   %edx,%edx
  8013c8:	74 0e                	je     8013d8 <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8013ca:	83 ec 08             	sub    $0x8,%esp
  8013cd:	ff 75 0c             	pushl  0xc(%ebp)
  8013d0:	50                   	push   %eax
  8013d1:	ff d2                	call   *%edx
  8013d3:	83 c4 10             	add    $0x10,%esp
  8013d6:	eb 05                	jmp    8013dd <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8013d8:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8013dd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013e0:	c9                   	leave  
  8013e1:	c3                   	ret    

008013e2 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8013e2:	55                   	push   %ebp
  8013e3:	89 e5                	mov    %esp,%ebp
  8013e5:	53                   	push   %ebx
  8013e6:	83 ec 14             	sub    $0x14,%esp
  8013e9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013ec:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013ef:	50                   	push   %eax
  8013f0:	ff 75 08             	pushl  0x8(%ebp)
  8013f3:	e8 63 fb ff ff       	call   800f5b <fd_lookup>
  8013f8:	83 c4 08             	add    $0x8,%esp
  8013fb:	85 c0                	test   %eax,%eax
  8013fd:	78 52                	js     801451 <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013ff:	83 ec 08             	sub    $0x8,%esp
  801402:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801405:	50                   	push   %eax
  801406:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801409:	ff 30                	pushl  (%eax)
  80140b:	e8 a2 fb ff ff       	call   800fb2 <dev_lookup>
  801410:	83 c4 10             	add    $0x10,%esp
  801413:	85 c0                	test   %eax,%eax
  801415:	78 3a                	js     801451 <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  801417:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80141a:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80141e:	74 2c                	je     80144c <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801420:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801423:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80142a:	00 00 00 
	stat->st_isdir = 0;
  80142d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801434:	00 00 00 
	stat->st_dev = dev;
  801437:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80143d:	83 ec 08             	sub    $0x8,%esp
  801440:	53                   	push   %ebx
  801441:	ff 75 f0             	pushl  -0x10(%ebp)
  801444:	ff 50 14             	call   *0x14(%eax)
  801447:	83 c4 10             	add    $0x10,%esp
  80144a:	eb 05                	jmp    801451 <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80144c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801451:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801454:	c9                   	leave  
  801455:	c3                   	ret    

00801456 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801456:	55                   	push   %ebp
  801457:	89 e5                	mov    %esp,%ebp
  801459:	56                   	push   %esi
  80145a:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80145b:	83 ec 08             	sub    $0x8,%esp
  80145e:	6a 00                	push   $0x0
  801460:	ff 75 08             	pushl  0x8(%ebp)
  801463:	e8 75 01 00 00       	call   8015dd <open>
  801468:	89 c3                	mov    %eax,%ebx
  80146a:	83 c4 10             	add    $0x10,%esp
  80146d:	85 c0                	test   %eax,%eax
  80146f:	78 1d                	js     80148e <stat+0x38>
		return fd;
	r = fstat(fd, stat);
  801471:	83 ec 08             	sub    $0x8,%esp
  801474:	ff 75 0c             	pushl  0xc(%ebp)
  801477:	50                   	push   %eax
  801478:	e8 65 ff ff ff       	call   8013e2 <fstat>
  80147d:	89 c6                	mov    %eax,%esi
	close(fd);
  80147f:	89 1c 24             	mov    %ebx,(%esp)
  801482:	e8 1d fc ff ff       	call   8010a4 <close>
	return r;
  801487:	83 c4 10             	add    $0x10,%esp
  80148a:	89 f0                	mov    %esi,%eax
  80148c:	eb 00                	jmp    80148e <stat+0x38>
}
  80148e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801491:	5b                   	pop    %ebx
  801492:	5e                   	pop    %esi
  801493:	5d                   	pop    %ebp
  801494:	c3                   	ret    

00801495 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801495:	55                   	push   %ebp
  801496:	89 e5                	mov    %esp,%ebp
  801498:	56                   	push   %esi
  801499:	53                   	push   %ebx
  80149a:	89 c6                	mov    %eax,%esi
  80149c:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80149e:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8014a5:	75 12                	jne    8014b9 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8014a7:	83 ec 0c             	sub    $0xc,%esp
  8014aa:	6a 01                	push   $0x1
  8014ac:	e8 8c 08 00 00       	call   801d3d <ipc_find_env>
  8014b1:	a3 00 40 80 00       	mov    %eax,0x804000
  8014b6:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8014b9:	6a 07                	push   $0x7
  8014bb:	68 00 70 80 00       	push   $0x807000
  8014c0:	56                   	push   %esi
  8014c1:	ff 35 00 40 80 00    	pushl  0x804000
  8014c7:	e8 12 08 00 00       	call   801cde <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8014cc:	83 c4 0c             	add    $0xc,%esp
  8014cf:	6a 00                	push   $0x0
  8014d1:	53                   	push   %ebx
  8014d2:	6a 00                	push   $0x0
  8014d4:	e8 90 07 00 00       	call   801c69 <ipc_recv>
}
  8014d9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014dc:	5b                   	pop    %ebx
  8014dd:	5e                   	pop    %esi
  8014de:	5d                   	pop    %ebp
  8014df:	c3                   	ret    

008014e0 <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8014e0:	55                   	push   %ebp
  8014e1:	89 e5                	mov    %esp,%ebp
  8014e3:	53                   	push   %ebx
  8014e4:	83 ec 04             	sub    $0x4,%esp
  8014e7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8014ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8014ed:	8b 40 0c             	mov    0xc(%eax),%eax
  8014f0:	a3 00 70 80 00       	mov    %eax,0x807000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8014f5:	ba 00 00 00 00       	mov    $0x0,%edx
  8014fa:	b8 05 00 00 00       	mov    $0x5,%eax
  8014ff:	e8 91 ff ff ff       	call   801495 <fsipc>
  801504:	85 c0                	test   %eax,%eax
  801506:	78 2c                	js     801534 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801508:	83 ec 08             	sub    $0x8,%esp
  80150b:	68 00 70 80 00       	push   $0x807000
  801510:	53                   	push   %ebx
  801511:	e8 49 f3 ff ff       	call   80085f <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801516:	a1 80 70 80 00       	mov    0x807080,%eax
  80151b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801521:	a1 84 70 80 00       	mov    0x807084,%eax
  801526:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80152c:	83 c4 10             	add    $0x10,%esp
  80152f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801534:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801537:	c9                   	leave  
  801538:	c3                   	ret    

00801539 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801539:	55                   	push   %ebp
  80153a:	89 e5                	mov    %esp,%ebp
  80153c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80153f:	8b 45 08             	mov    0x8(%ebp),%eax
  801542:	8b 40 0c             	mov    0xc(%eax),%eax
  801545:	a3 00 70 80 00       	mov    %eax,0x807000
	return fsipc(FSREQ_FLUSH, NULL);
  80154a:	ba 00 00 00 00       	mov    $0x0,%edx
  80154f:	b8 06 00 00 00       	mov    $0x6,%eax
  801554:	e8 3c ff ff ff       	call   801495 <fsipc>
}
  801559:	c9                   	leave  
  80155a:	c3                   	ret    

0080155b <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80155b:	55                   	push   %ebp
  80155c:	89 e5                	mov    %esp,%ebp
  80155e:	56                   	push   %esi
  80155f:	53                   	push   %ebx
  801560:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801563:	8b 45 08             	mov    0x8(%ebp),%eax
  801566:	8b 40 0c             	mov    0xc(%eax),%eax
  801569:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.read.req_n = n;
  80156e:	89 35 04 70 80 00    	mov    %esi,0x807004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801574:	ba 00 00 00 00       	mov    $0x0,%edx
  801579:	b8 03 00 00 00       	mov    $0x3,%eax
  80157e:	e8 12 ff ff ff       	call   801495 <fsipc>
  801583:	89 c3                	mov    %eax,%ebx
  801585:	85 c0                	test   %eax,%eax
  801587:	78 4b                	js     8015d4 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801589:	39 c6                	cmp    %eax,%esi
  80158b:	73 16                	jae    8015a3 <devfile_read+0x48>
  80158d:	68 69 24 80 00       	push   $0x802469
  801592:	68 70 24 80 00       	push   $0x802470
  801597:	6a 7a                	push   $0x7a
  801599:	68 85 24 80 00       	push   $0x802485
  80159e:	e8 ff eb ff ff       	call   8001a2 <_panic>
	assert(r <= PGSIZE);
  8015a3:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8015a8:	7e 16                	jle    8015c0 <devfile_read+0x65>
  8015aa:	68 90 24 80 00       	push   $0x802490
  8015af:	68 70 24 80 00       	push   $0x802470
  8015b4:	6a 7b                	push   $0x7b
  8015b6:	68 85 24 80 00       	push   $0x802485
  8015bb:	e8 e2 eb ff ff       	call   8001a2 <_panic>
	memmove(buf, &fsipcbuf, r);
  8015c0:	83 ec 04             	sub    $0x4,%esp
  8015c3:	50                   	push   %eax
  8015c4:	68 00 70 80 00       	push   $0x807000
  8015c9:	ff 75 0c             	pushl  0xc(%ebp)
  8015cc:	e8 5b f4 ff ff       	call   800a2c <memmove>
	return r;
  8015d1:	83 c4 10             	add    $0x10,%esp
}
  8015d4:	89 d8                	mov    %ebx,%eax
  8015d6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015d9:	5b                   	pop    %ebx
  8015da:	5e                   	pop    %esi
  8015db:	5d                   	pop    %ebp
  8015dc:	c3                   	ret    

008015dd <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8015dd:	55                   	push   %ebp
  8015de:	89 e5                	mov    %esp,%ebp
  8015e0:	53                   	push   %ebx
  8015e1:	83 ec 20             	sub    $0x20,%esp
  8015e4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8015e7:	53                   	push   %ebx
  8015e8:	e8 1b f2 ff ff       	call   800808 <strlen>
  8015ed:	83 c4 10             	add    $0x10,%esp
  8015f0:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8015f5:	7f 63                	jg     80165a <open+0x7d>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015f7:	83 ec 0c             	sub    $0xc,%esp
  8015fa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015fd:	50                   	push   %eax
  8015fe:	e8 e4 f8 ff ff       	call   800ee7 <fd_alloc>
  801603:	83 c4 10             	add    $0x10,%esp
  801606:	85 c0                	test   %eax,%eax
  801608:	78 55                	js     80165f <open+0x82>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80160a:	83 ec 08             	sub    $0x8,%esp
  80160d:	53                   	push   %ebx
  80160e:	68 00 70 80 00       	push   $0x807000
  801613:	e8 47 f2 ff ff       	call   80085f <strcpy>
	fsipcbuf.open.req_omode = mode;
  801618:	8b 45 0c             	mov    0xc(%ebp),%eax
  80161b:	a3 00 74 80 00       	mov    %eax,0x807400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801620:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801623:	b8 01 00 00 00       	mov    $0x1,%eax
  801628:	e8 68 fe ff ff       	call   801495 <fsipc>
  80162d:	89 c3                	mov    %eax,%ebx
  80162f:	83 c4 10             	add    $0x10,%esp
  801632:	85 c0                	test   %eax,%eax
  801634:	79 14                	jns    80164a <open+0x6d>
		fd_close(fd, 0);
  801636:	83 ec 08             	sub    $0x8,%esp
  801639:	6a 00                	push   $0x0
  80163b:	ff 75 f4             	pushl  -0xc(%ebp)
  80163e:	e8 dd f9 ff ff       	call   801020 <fd_close>
		return r;
  801643:	83 c4 10             	add    $0x10,%esp
  801646:	89 d8                	mov    %ebx,%eax
  801648:	eb 15                	jmp    80165f <open+0x82>
	}

	return fd2num(fd);
  80164a:	83 ec 0c             	sub    $0xc,%esp
  80164d:	ff 75 f4             	pushl  -0xc(%ebp)
  801650:	e8 6b f8 ff ff       	call   800ec0 <fd2num>
  801655:	83 c4 10             	add    $0x10,%esp
  801658:	eb 05                	jmp    80165f <open+0x82>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80165a:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80165f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801662:	c9                   	leave  
  801663:	c3                   	ret    

00801664 <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  801664:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  801668:	7e 38                	jle    8016a2 <writebuf+0x3e>
};


static void
writebuf(struct printbuf *b)
{
  80166a:	55                   	push   %ebp
  80166b:	89 e5                	mov    %esp,%ebp
  80166d:	53                   	push   %ebx
  80166e:	83 ec 08             	sub    $0x8,%esp
  801671:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
		ssize_t result = write(b->fd, b->buf, b->idx);
  801673:	ff 70 04             	pushl  0x4(%eax)
  801676:	8d 40 10             	lea    0x10(%eax),%eax
  801679:	50                   	push   %eax
  80167a:	ff 33                	pushl  (%ebx)
  80167c:	e8 37 fc ff ff       	call   8012b8 <write>
		if (result > 0)
  801681:	83 c4 10             	add    $0x10,%esp
  801684:	85 c0                	test   %eax,%eax
  801686:	7e 03                	jle    80168b <writebuf+0x27>
			b->result += result;
  801688:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  80168b:	3b 43 04             	cmp    0x4(%ebx),%eax
  80168e:	74 0e                	je     80169e <writebuf+0x3a>
			b->error = (result < 0 ? result : 0);
  801690:	89 c2                	mov    %eax,%edx
  801692:	85 c0                	test   %eax,%eax
  801694:	7e 05                	jle    80169b <writebuf+0x37>
  801696:	ba 00 00 00 00       	mov    $0x0,%edx
  80169b:	89 53 0c             	mov    %edx,0xc(%ebx)
	}
}
  80169e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016a1:	c9                   	leave  
  8016a2:	c3                   	ret    

008016a3 <putch>:

static void
putch(int ch, void *thunk)
{
  8016a3:	55                   	push   %ebp
  8016a4:	89 e5                	mov    %esp,%ebp
  8016a6:	53                   	push   %ebx
  8016a7:	83 ec 04             	sub    $0x4,%esp
  8016aa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  8016ad:	8b 53 04             	mov    0x4(%ebx),%edx
  8016b0:	8d 42 01             	lea    0x1(%edx),%eax
  8016b3:	89 43 04             	mov    %eax,0x4(%ebx)
  8016b6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016b9:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  8016bd:	3d 00 01 00 00       	cmp    $0x100,%eax
  8016c2:	75 0e                	jne    8016d2 <putch+0x2f>
		writebuf(b);
  8016c4:	89 d8                	mov    %ebx,%eax
  8016c6:	e8 99 ff ff ff       	call   801664 <writebuf>
		b->idx = 0;
  8016cb:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  8016d2:	83 c4 04             	add    $0x4,%esp
  8016d5:	5b                   	pop    %ebx
  8016d6:	5d                   	pop    %ebp
  8016d7:	c3                   	ret    

008016d8 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  8016d8:	55                   	push   %ebp
  8016d9:	89 e5                	mov    %esp,%ebp
  8016db:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  8016e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8016e4:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  8016ea:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  8016f1:	00 00 00 
	b.result = 0;
  8016f4:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8016fb:	00 00 00 
	b.error = 1;
  8016fe:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  801705:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  801708:	ff 75 10             	pushl  0x10(%ebp)
  80170b:	ff 75 0c             	pushl  0xc(%ebp)
  80170e:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801714:	50                   	push   %eax
  801715:	68 a3 16 80 00       	push   $0x8016a3
  80171a:	e8 92 ec ff ff       	call   8003b1 <vprintfmt>
	if (b.idx > 0)
  80171f:	83 c4 10             	add    $0x10,%esp
  801722:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  801729:	7e 0b                	jle    801736 <vfprintf+0x5e>
		writebuf(&b);
  80172b:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801731:	e8 2e ff ff ff       	call   801664 <writebuf>

	return (b.result ? b.result : b.error);
  801736:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80173c:	85 c0                	test   %eax,%eax
  80173e:	75 06                	jne    801746 <vfprintf+0x6e>
  801740:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  801746:	c9                   	leave  
  801747:	c3                   	ret    

00801748 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  801748:	55                   	push   %ebp
  801749:	89 e5                	mov    %esp,%ebp
  80174b:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80174e:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  801751:	50                   	push   %eax
  801752:	ff 75 0c             	pushl  0xc(%ebp)
  801755:	ff 75 08             	pushl  0x8(%ebp)
  801758:	e8 7b ff ff ff       	call   8016d8 <vfprintf>
	va_end(ap);

	return cnt;
}
  80175d:	c9                   	leave  
  80175e:	c3                   	ret    

0080175f <printf>:

int
printf(const char *fmt, ...)
{
  80175f:	55                   	push   %ebp
  801760:	89 e5                	mov    %esp,%ebp
  801762:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801765:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  801768:	50                   	push   %eax
  801769:	ff 75 08             	pushl  0x8(%ebp)
  80176c:	6a 01                	push   $0x1
  80176e:	e8 65 ff ff ff       	call   8016d8 <vfprintf>
	va_end(ap);

	return cnt;
}
  801773:	c9                   	leave  
  801774:	c3                   	ret    

00801775 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801775:	55                   	push   %ebp
  801776:	89 e5                	mov    %esp,%ebp
  801778:	56                   	push   %esi
  801779:	53                   	push   %ebx
  80177a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80177d:	83 ec 0c             	sub    $0xc,%esp
  801780:	ff 75 08             	pushl  0x8(%ebp)
  801783:	e8 48 f7 ff ff       	call   800ed0 <fd2data>
  801788:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80178a:	83 c4 08             	add    $0x8,%esp
  80178d:	68 9c 24 80 00       	push   $0x80249c
  801792:	53                   	push   %ebx
  801793:	e8 c7 f0 ff ff       	call   80085f <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801798:	8b 46 04             	mov    0x4(%esi),%eax
  80179b:	2b 06                	sub    (%esi),%eax
  80179d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8017a3:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8017aa:	00 00 00 
	stat->st_dev = &devpipe;
  8017ad:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8017b4:	30 80 00 
	return 0;
}
  8017b7:	b8 00 00 00 00       	mov    $0x0,%eax
  8017bc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017bf:	5b                   	pop    %ebx
  8017c0:	5e                   	pop    %esi
  8017c1:	5d                   	pop    %ebp
  8017c2:	c3                   	ret    

008017c3 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8017c3:	55                   	push   %ebp
  8017c4:	89 e5                	mov    %esp,%ebp
  8017c6:	53                   	push   %ebx
  8017c7:	83 ec 0c             	sub    $0xc,%esp
  8017ca:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8017cd:	53                   	push   %ebx
  8017ce:	6a 00                	push   $0x0
  8017d0:	e8 7f f5 ff ff       	call   800d54 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8017d5:	89 1c 24             	mov    %ebx,(%esp)
  8017d8:	e8 f3 f6 ff ff       	call   800ed0 <fd2data>
  8017dd:	83 c4 08             	add    $0x8,%esp
  8017e0:	50                   	push   %eax
  8017e1:	6a 00                	push   $0x0
  8017e3:	e8 6c f5 ff ff       	call   800d54 <sys_page_unmap>
}
  8017e8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017eb:	c9                   	leave  
  8017ec:	c3                   	ret    

008017ed <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8017ed:	55                   	push   %ebp
  8017ee:	89 e5                	mov    %esp,%ebp
  8017f0:	57                   	push   %edi
  8017f1:	56                   	push   %esi
  8017f2:	53                   	push   %ebx
  8017f3:	83 ec 1c             	sub    $0x1c,%esp
  8017f6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8017f9:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8017fb:	a1 20 60 80 00       	mov    0x806020,%eax
  801800:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801803:	83 ec 0c             	sub    $0xc,%esp
  801806:	ff 75 e0             	pushl  -0x20(%ebp)
  801809:	e8 8a 05 00 00       	call   801d98 <pageref>
  80180e:	89 c3                	mov    %eax,%ebx
  801810:	89 3c 24             	mov    %edi,(%esp)
  801813:	e8 80 05 00 00       	call   801d98 <pageref>
  801818:	83 c4 10             	add    $0x10,%esp
  80181b:	39 c3                	cmp    %eax,%ebx
  80181d:	0f 94 c1             	sete   %cl
  801820:	0f b6 c9             	movzbl %cl,%ecx
  801823:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801826:	8b 15 20 60 80 00    	mov    0x806020,%edx
  80182c:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  80182f:	39 ce                	cmp    %ecx,%esi
  801831:	74 1b                	je     80184e <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801833:	39 c3                	cmp    %eax,%ebx
  801835:	75 c4                	jne    8017fb <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801837:	8b 42 58             	mov    0x58(%edx),%eax
  80183a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80183d:	50                   	push   %eax
  80183e:	56                   	push   %esi
  80183f:	68 a3 24 80 00       	push   $0x8024a3
  801844:	e8 31 ea ff ff       	call   80027a <cprintf>
  801849:	83 c4 10             	add    $0x10,%esp
  80184c:	eb ad                	jmp    8017fb <_pipeisclosed+0xe>
	}
}
  80184e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801851:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801854:	5b                   	pop    %ebx
  801855:	5e                   	pop    %esi
  801856:	5f                   	pop    %edi
  801857:	5d                   	pop    %ebp
  801858:	c3                   	ret    

00801859 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801859:	55                   	push   %ebp
  80185a:	89 e5                	mov    %esp,%ebp
  80185c:	57                   	push   %edi
  80185d:	56                   	push   %esi
  80185e:	53                   	push   %ebx
  80185f:	83 ec 18             	sub    $0x18,%esp
  801862:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801865:	56                   	push   %esi
  801866:	e8 65 f6 ff ff       	call   800ed0 <fd2data>
  80186b:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80186d:	83 c4 10             	add    $0x10,%esp
  801870:	bf 00 00 00 00       	mov    $0x0,%edi
  801875:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801879:	75 42                	jne    8018bd <devpipe_write+0x64>
  80187b:	eb 4e                	jmp    8018cb <devpipe_write+0x72>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80187d:	89 da                	mov    %ebx,%edx
  80187f:	89 f0                	mov    %esi,%eax
  801881:	e8 67 ff ff ff       	call   8017ed <_pipeisclosed>
  801886:	85 c0                	test   %eax,%eax
  801888:	75 46                	jne    8018d0 <devpipe_write+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80188a:	e8 21 f4 ff ff       	call   800cb0 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80188f:	8b 53 04             	mov    0x4(%ebx),%edx
  801892:	8b 03                	mov    (%ebx),%eax
  801894:	83 c0 20             	add    $0x20,%eax
  801897:	39 c2                	cmp    %eax,%edx
  801899:	73 e2                	jae    80187d <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80189b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80189e:	8a 0c 38             	mov    (%eax,%edi,1),%cl
  8018a1:	89 d0                	mov    %edx,%eax
  8018a3:	25 1f 00 00 80       	and    $0x8000001f,%eax
  8018a8:	79 05                	jns    8018af <devpipe_write+0x56>
  8018aa:	48                   	dec    %eax
  8018ab:	83 c8 e0             	or     $0xffffffe0,%eax
  8018ae:	40                   	inc    %eax
  8018af:	88 4c 03 08          	mov    %cl,0x8(%ebx,%eax,1)
		p->p_wpos++;
  8018b3:	42                   	inc    %edx
  8018b4:	89 53 04             	mov    %edx,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8018b7:	47                   	inc    %edi
  8018b8:	39 7d 10             	cmp    %edi,0x10(%ebp)
  8018bb:	74 0e                	je     8018cb <devpipe_write+0x72>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8018bd:	8b 53 04             	mov    0x4(%ebx),%edx
  8018c0:	8b 03                	mov    (%ebx),%eax
  8018c2:	83 c0 20             	add    $0x20,%eax
  8018c5:	39 c2                	cmp    %eax,%edx
  8018c7:	73 b4                	jae    80187d <devpipe_write+0x24>
  8018c9:	eb d0                	jmp    80189b <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8018cb:	8b 45 10             	mov    0x10(%ebp),%eax
  8018ce:	eb 05                	jmp    8018d5 <devpipe_write+0x7c>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8018d0:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8018d5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018d8:	5b                   	pop    %ebx
  8018d9:	5e                   	pop    %esi
  8018da:	5f                   	pop    %edi
  8018db:	5d                   	pop    %ebp
  8018dc:	c3                   	ret    

008018dd <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8018dd:	55                   	push   %ebp
  8018de:	89 e5                	mov    %esp,%ebp
  8018e0:	57                   	push   %edi
  8018e1:	56                   	push   %esi
  8018e2:	53                   	push   %ebx
  8018e3:	83 ec 18             	sub    $0x18,%esp
  8018e6:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8018e9:	57                   	push   %edi
  8018ea:	e8 e1 f5 ff ff       	call   800ed0 <fd2data>
  8018ef:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8018f1:	83 c4 10             	add    $0x10,%esp
  8018f4:	be 00 00 00 00       	mov    $0x0,%esi
  8018f9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8018fd:	75 3d                	jne    80193c <devpipe_read+0x5f>
  8018ff:	eb 48                	jmp    801949 <devpipe_read+0x6c>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  801901:	89 f0                	mov    %esi,%eax
  801903:	eb 4e                	jmp    801953 <devpipe_read+0x76>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801905:	89 da                	mov    %ebx,%edx
  801907:	89 f8                	mov    %edi,%eax
  801909:	e8 df fe ff ff       	call   8017ed <_pipeisclosed>
  80190e:	85 c0                	test   %eax,%eax
  801910:	75 3c                	jne    80194e <devpipe_read+0x71>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801912:	e8 99 f3 ff ff       	call   800cb0 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801917:	8b 03                	mov    (%ebx),%eax
  801919:	3b 43 04             	cmp    0x4(%ebx),%eax
  80191c:	74 e7                	je     801905 <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80191e:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801923:	79 05                	jns    80192a <devpipe_read+0x4d>
  801925:	48                   	dec    %eax
  801926:	83 c8 e0             	or     $0xffffffe0,%eax
  801929:	40                   	inc    %eax
  80192a:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  80192e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801931:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801934:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801936:	46                   	inc    %esi
  801937:	39 75 10             	cmp    %esi,0x10(%ebp)
  80193a:	74 0d                	je     801949 <devpipe_read+0x6c>
		while (p->p_rpos == p->p_wpos) {
  80193c:	8b 03                	mov    (%ebx),%eax
  80193e:	3b 43 04             	cmp    0x4(%ebx),%eax
  801941:	75 db                	jne    80191e <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801943:	85 f6                	test   %esi,%esi
  801945:	75 ba                	jne    801901 <devpipe_read+0x24>
  801947:	eb bc                	jmp    801905 <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801949:	8b 45 10             	mov    0x10(%ebp),%eax
  80194c:	eb 05                	jmp    801953 <devpipe_read+0x76>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80194e:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801953:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801956:	5b                   	pop    %ebx
  801957:	5e                   	pop    %esi
  801958:	5f                   	pop    %edi
  801959:	5d                   	pop    %ebp
  80195a:	c3                   	ret    

0080195b <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80195b:	55                   	push   %ebp
  80195c:	89 e5                	mov    %esp,%ebp
  80195e:	56                   	push   %esi
  80195f:	53                   	push   %ebx
  801960:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801963:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801966:	50                   	push   %eax
  801967:	e8 7b f5 ff ff       	call   800ee7 <fd_alloc>
  80196c:	83 c4 10             	add    $0x10,%esp
  80196f:	85 c0                	test   %eax,%eax
  801971:	0f 88 2a 01 00 00    	js     801aa1 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801977:	83 ec 04             	sub    $0x4,%esp
  80197a:	68 07 04 00 00       	push   $0x407
  80197f:	ff 75 f4             	pushl  -0xc(%ebp)
  801982:	6a 00                	push   $0x0
  801984:	e8 46 f3 ff ff       	call   800ccf <sys_page_alloc>
  801989:	83 c4 10             	add    $0x10,%esp
  80198c:	85 c0                	test   %eax,%eax
  80198e:	0f 88 0d 01 00 00    	js     801aa1 <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801994:	83 ec 0c             	sub    $0xc,%esp
  801997:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80199a:	50                   	push   %eax
  80199b:	e8 47 f5 ff ff       	call   800ee7 <fd_alloc>
  8019a0:	89 c3                	mov    %eax,%ebx
  8019a2:	83 c4 10             	add    $0x10,%esp
  8019a5:	85 c0                	test   %eax,%eax
  8019a7:	0f 88 e2 00 00 00    	js     801a8f <pipe+0x134>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8019ad:	83 ec 04             	sub    $0x4,%esp
  8019b0:	68 07 04 00 00       	push   $0x407
  8019b5:	ff 75 f0             	pushl  -0x10(%ebp)
  8019b8:	6a 00                	push   $0x0
  8019ba:	e8 10 f3 ff ff       	call   800ccf <sys_page_alloc>
  8019bf:	89 c3                	mov    %eax,%ebx
  8019c1:	83 c4 10             	add    $0x10,%esp
  8019c4:	85 c0                	test   %eax,%eax
  8019c6:	0f 88 c3 00 00 00    	js     801a8f <pipe+0x134>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8019cc:	83 ec 0c             	sub    $0xc,%esp
  8019cf:	ff 75 f4             	pushl  -0xc(%ebp)
  8019d2:	e8 f9 f4 ff ff       	call   800ed0 <fd2data>
  8019d7:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8019d9:	83 c4 0c             	add    $0xc,%esp
  8019dc:	68 07 04 00 00       	push   $0x407
  8019e1:	50                   	push   %eax
  8019e2:	6a 00                	push   $0x0
  8019e4:	e8 e6 f2 ff ff       	call   800ccf <sys_page_alloc>
  8019e9:	89 c3                	mov    %eax,%ebx
  8019eb:	83 c4 10             	add    $0x10,%esp
  8019ee:	85 c0                	test   %eax,%eax
  8019f0:	0f 88 89 00 00 00    	js     801a7f <pipe+0x124>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8019f6:	83 ec 0c             	sub    $0xc,%esp
  8019f9:	ff 75 f0             	pushl  -0x10(%ebp)
  8019fc:	e8 cf f4 ff ff       	call   800ed0 <fd2data>
  801a01:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801a08:	50                   	push   %eax
  801a09:	6a 00                	push   $0x0
  801a0b:	56                   	push   %esi
  801a0c:	6a 00                	push   $0x0
  801a0e:	e8 ff f2 ff ff       	call   800d12 <sys_page_map>
  801a13:	89 c3                	mov    %eax,%ebx
  801a15:	83 c4 20             	add    $0x20,%esp
  801a18:	85 c0                	test   %eax,%eax
  801a1a:	78 55                	js     801a71 <pipe+0x116>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801a1c:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801a22:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a25:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801a27:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a2a:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801a31:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801a37:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a3a:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801a3c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a3f:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801a46:	83 ec 0c             	sub    $0xc,%esp
  801a49:	ff 75 f4             	pushl  -0xc(%ebp)
  801a4c:	e8 6f f4 ff ff       	call   800ec0 <fd2num>
  801a51:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801a54:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801a56:	83 c4 04             	add    $0x4,%esp
  801a59:	ff 75 f0             	pushl  -0x10(%ebp)
  801a5c:	e8 5f f4 ff ff       	call   800ec0 <fd2num>
  801a61:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801a64:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801a67:	83 c4 10             	add    $0x10,%esp
  801a6a:	b8 00 00 00 00       	mov    $0x0,%eax
  801a6f:	eb 30                	jmp    801aa1 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  801a71:	83 ec 08             	sub    $0x8,%esp
  801a74:	56                   	push   %esi
  801a75:	6a 00                	push   $0x0
  801a77:	e8 d8 f2 ff ff       	call   800d54 <sys_page_unmap>
  801a7c:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801a7f:	83 ec 08             	sub    $0x8,%esp
  801a82:	ff 75 f0             	pushl  -0x10(%ebp)
  801a85:	6a 00                	push   $0x0
  801a87:	e8 c8 f2 ff ff       	call   800d54 <sys_page_unmap>
  801a8c:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801a8f:	83 ec 08             	sub    $0x8,%esp
  801a92:	ff 75 f4             	pushl  -0xc(%ebp)
  801a95:	6a 00                	push   $0x0
  801a97:	e8 b8 f2 ff ff       	call   800d54 <sys_page_unmap>
  801a9c:	83 c4 10             	add    $0x10,%esp
  801a9f:	89 d8                	mov    %ebx,%eax
    err:
	return r;
}
  801aa1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801aa4:	5b                   	pop    %ebx
  801aa5:	5e                   	pop    %esi
  801aa6:	5d                   	pop    %ebp
  801aa7:	c3                   	ret    

00801aa8 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801aa8:	55                   	push   %ebp
  801aa9:	89 e5                	mov    %esp,%ebp
  801aab:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801aae:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ab1:	50                   	push   %eax
  801ab2:	ff 75 08             	pushl  0x8(%ebp)
  801ab5:	e8 a1 f4 ff ff       	call   800f5b <fd_lookup>
  801aba:	83 c4 10             	add    $0x10,%esp
  801abd:	85 c0                	test   %eax,%eax
  801abf:	78 18                	js     801ad9 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801ac1:	83 ec 0c             	sub    $0xc,%esp
  801ac4:	ff 75 f4             	pushl  -0xc(%ebp)
  801ac7:	e8 04 f4 ff ff       	call   800ed0 <fd2data>
	return _pipeisclosed(fd, p);
  801acc:	89 c2                	mov    %eax,%edx
  801ace:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ad1:	e8 17 fd ff ff       	call   8017ed <_pipeisclosed>
  801ad6:	83 c4 10             	add    $0x10,%esp
}
  801ad9:	c9                   	leave  
  801ada:	c3                   	ret    

00801adb <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801adb:	55                   	push   %ebp
  801adc:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801ade:	b8 00 00 00 00       	mov    $0x0,%eax
  801ae3:	5d                   	pop    %ebp
  801ae4:	c3                   	ret    

00801ae5 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801ae5:	55                   	push   %ebp
  801ae6:	89 e5                	mov    %esp,%ebp
  801ae8:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801aeb:	68 bb 24 80 00       	push   $0x8024bb
  801af0:	ff 75 0c             	pushl  0xc(%ebp)
  801af3:	e8 67 ed ff ff       	call   80085f <strcpy>
	return 0;
}
  801af8:	b8 00 00 00 00       	mov    $0x0,%eax
  801afd:	c9                   	leave  
  801afe:	c3                   	ret    

00801aff <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801aff:	55                   	push   %ebp
  801b00:	89 e5                	mov    %esp,%ebp
  801b02:	57                   	push   %edi
  801b03:	56                   	push   %esi
  801b04:	53                   	push   %ebx
  801b05:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801b0b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801b0f:	74 45                	je     801b56 <devcons_write+0x57>
  801b11:	b8 00 00 00 00       	mov    $0x0,%eax
  801b16:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801b1b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801b21:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801b24:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  801b26:	83 fb 7f             	cmp    $0x7f,%ebx
  801b29:	76 05                	jbe    801b30 <devcons_write+0x31>
			m = sizeof(buf) - 1;
  801b2b:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801b30:	83 ec 04             	sub    $0x4,%esp
  801b33:	53                   	push   %ebx
  801b34:	03 45 0c             	add    0xc(%ebp),%eax
  801b37:	50                   	push   %eax
  801b38:	57                   	push   %edi
  801b39:	e8 ee ee ff ff       	call   800a2c <memmove>
		sys_cputs(buf, m);
  801b3e:	83 c4 08             	add    $0x8,%esp
  801b41:	53                   	push   %ebx
  801b42:	57                   	push   %edi
  801b43:	e8 cb f0 ff ff       	call   800c13 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801b48:	01 de                	add    %ebx,%esi
  801b4a:	89 f0                	mov    %esi,%eax
  801b4c:	83 c4 10             	add    $0x10,%esp
  801b4f:	3b 75 10             	cmp    0x10(%ebp),%esi
  801b52:	72 cd                	jb     801b21 <devcons_write+0x22>
  801b54:	eb 05                	jmp    801b5b <devcons_write+0x5c>
  801b56:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801b5b:	89 f0                	mov    %esi,%eax
  801b5d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b60:	5b                   	pop    %ebx
  801b61:	5e                   	pop    %esi
  801b62:	5f                   	pop    %edi
  801b63:	5d                   	pop    %ebp
  801b64:	c3                   	ret    

00801b65 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b65:	55                   	push   %ebp
  801b66:	89 e5                	mov    %esp,%ebp
  801b68:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801b6b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801b6f:	75 07                	jne    801b78 <devcons_read+0x13>
  801b71:	eb 23                	jmp    801b96 <devcons_read+0x31>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801b73:	e8 38 f1 ff ff       	call   800cb0 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801b78:	e8 b4 f0 ff ff       	call   800c31 <sys_cgetc>
  801b7d:	85 c0                	test   %eax,%eax
  801b7f:	74 f2                	je     801b73 <devcons_read+0xe>
		sys_yield();
	if (c < 0)
  801b81:	85 c0                	test   %eax,%eax
  801b83:	78 1d                	js     801ba2 <devcons_read+0x3d>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801b85:	83 f8 04             	cmp    $0x4,%eax
  801b88:	74 13                	je     801b9d <devcons_read+0x38>
		return 0;
	*(char*)vbuf = c;
  801b8a:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b8d:	88 02                	mov    %al,(%edx)
	return 1;
  801b8f:	b8 01 00 00 00       	mov    $0x1,%eax
  801b94:	eb 0c                	jmp    801ba2 <devcons_read+0x3d>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801b96:	b8 00 00 00 00       	mov    $0x0,%eax
  801b9b:	eb 05                	jmp    801ba2 <devcons_read+0x3d>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801b9d:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801ba2:	c9                   	leave  
  801ba3:	c3                   	ret    

00801ba4 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801ba4:	55                   	push   %ebp
  801ba5:	89 e5                	mov    %esp,%ebp
  801ba7:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801baa:	8b 45 08             	mov    0x8(%ebp),%eax
  801bad:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801bb0:	6a 01                	push   $0x1
  801bb2:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801bb5:	50                   	push   %eax
  801bb6:	e8 58 f0 ff ff       	call   800c13 <sys_cputs>
}
  801bbb:	83 c4 10             	add    $0x10,%esp
  801bbe:	c9                   	leave  
  801bbf:	c3                   	ret    

00801bc0 <getchar>:

int
getchar(void)
{
  801bc0:	55                   	push   %ebp
  801bc1:	89 e5                	mov    %esp,%ebp
  801bc3:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801bc6:	6a 01                	push   $0x1
  801bc8:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801bcb:	50                   	push   %eax
  801bcc:	6a 00                	push   $0x0
  801bce:	e8 09 f6 ff ff       	call   8011dc <read>
	if (r < 0)
  801bd3:	83 c4 10             	add    $0x10,%esp
  801bd6:	85 c0                	test   %eax,%eax
  801bd8:	78 0f                	js     801be9 <getchar+0x29>
		return r;
	if (r < 1)
  801bda:	85 c0                	test   %eax,%eax
  801bdc:	7e 06                	jle    801be4 <getchar+0x24>
		return -E_EOF;
	return c;
  801bde:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801be2:	eb 05                	jmp    801be9 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801be4:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801be9:	c9                   	leave  
  801bea:	c3                   	ret    

00801beb <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801beb:	55                   	push   %ebp
  801bec:	89 e5                	mov    %esp,%ebp
  801bee:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801bf1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bf4:	50                   	push   %eax
  801bf5:	ff 75 08             	pushl  0x8(%ebp)
  801bf8:	e8 5e f3 ff ff       	call   800f5b <fd_lookup>
  801bfd:	83 c4 10             	add    $0x10,%esp
  801c00:	85 c0                	test   %eax,%eax
  801c02:	78 11                	js     801c15 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801c04:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c07:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801c0d:	39 10                	cmp    %edx,(%eax)
  801c0f:	0f 94 c0             	sete   %al
  801c12:	0f b6 c0             	movzbl %al,%eax
}
  801c15:	c9                   	leave  
  801c16:	c3                   	ret    

00801c17 <opencons>:

int
opencons(void)
{
  801c17:	55                   	push   %ebp
  801c18:	89 e5                	mov    %esp,%ebp
  801c1a:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801c1d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c20:	50                   	push   %eax
  801c21:	e8 c1 f2 ff ff       	call   800ee7 <fd_alloc>
  801c26:	83 c4 10             	add    $0x10,%esp
  801c29:	85 c0                	test   %eax,%eax
  801c2b:	78 3a                	js     801c67 <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801c2d:	83 ec 04             	sub    $0x4,%esp
  801c30:	68 07 04 00 00       	push   $0x407
  801c35:	ff 75 f4             	pushl  -0xc(%ebp)
  801c38:	6a 00                	push   $0x0
  801c3a:	e8 90 f0 ff ff       	call   800ccf <sys_page_alloc>
  801c3f:	83 c4 10             	add    $0x10,%esp
  801c42:	85 c0                	test   %eax,%eax
  801c44:	78 21                	js     801c67 <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801c46:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801c4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c4f:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801c51:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c54:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801c5b:	83 ec 0c             	sub    $0xc,%esp
  801c5e:	50                   	push   %eax
  801c5f:	e8 5c f2 ff ff       	call   800ec0 <fd2num>
  801c64:	83 c4 10             	add    $0x10,%esp
}
  801c67:	c9                   	leave  
  801c68:	c3                   	ret    

00801c69 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801c69:	55                   	push   %ebp
  801c6a:	89 e5                	mov    %esp,%ebp
  801c6c:	56                   	push   %esi
  801c6d:	53                   	push   %ebx
  801c6e:	8b 75 08             	mov    0x8(%ebp),%esi
  801c71:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c74:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");
	int r;
    if (pg != NULL) {
  801c77:	85 c0                	test   %eax,%eax
  801c79:	74 0e                	je     801c89 <ipc_recv+0x20>
        r = sys_ipc_recv(pg);
  801c7b:	83 ec 0c             	sub    $0xc,%esp
  801c7e:	50                   	push   %eax
  801c7f:	e8 fb f1 ff ff       	call   800e7f <sys_ipc_recv>
  801c84:	83 c4 10             	add    $0x10,%esp
  801c87:	eb 10                	jmp    801c99 <ipc_recv+0x30>
    } else {
        r = sys_ipc_recv((void *) UTOP);
  801c89:	83 ec 0c             	sub    $0xc,%esp
  801c8c:	68 00 00 c0 ee       	push   $0xeec00000
  801c91:	e8 e9 f1 ff ff       	call   800e7f <sys_ipc_recv>
  801c96:	83 c4 10             	add    $0x10,%esp
    }
    if (r < 0) {
  801c99:	85 c0                	test   %eax,%eax
  801c9b:	79 16                	jns    801cb3 <ipc_recv+0x4a>
        // failed
        if (from_env_store != NULL) *from_env_store = 0;
  801c9d:	85 f6                	test   %esi,%esi
  801c9f:	74 06                	je     801ca7 <ipc_recv+0x3e>
  801ca1:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        if (perm_store != NULL) *perm_store = 0;
  801ca7:	85 db                	test   %ebx,%ebx
  801ca9:	74 2c                	je     801cd7 <ipc_recv+0x6e>
  801cab:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801cb1:	eb 24                	jmp    801cd7 <ipc_recv+0x6e>
        return r;
    } else {
        if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801cb3:	85 f6                	test   %esi,%esi
  801cb5:	74 0a                	je     801cc1 <ipc_recv+0x58>
  801cb7:	a1 20 60 80 00       	mov    0x806020,%eax
  801cbc:	8b 40 74             	mov    0x74(%eax),%eax
  801cbf:	89 06                	mov    %eax,(%esi)
        if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801cc1:	85 db                	test   %ebx,%ebx
  801cc3:	74 0a                	je     801ccf <ipc_recv+0x66>
  801cc5:	a1 20 60 80 00       	mov    0x806020,%eax
  801cca:	8b 40 78             	mov    0x78(%eax),%eax
  801ccd:	89 03                	mov    %eax,(%ebx)
        return thisenv->env_ipc_value;
  801ccf:	a1 20 60 80 00       	mov    0x806020,%eax
  801cd4:	8b 40 70             	mov    0x70(%eax),%eax
    }
 
	return 0;
}
  801cd7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cda:	5b                   	pop    %ebx
  801cdb:	5e                   	pop    %esi
  801cdc:	5d                   	pop    %ebp
  801cdd:	c3                   	ret    

00801cde <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801cde:	55                   	push   %ebp
  801cdf:	89 e5                	mov    %esp,%ebp
  801ce1:	57                   	push   %edi
  801ce2:	56                   	push   %esi
  801ce3:	53                   	push   %ebx
  801ce4:	83 ec 0c             	sub    $0xc,%esp
  801ce7:	8b 75 10             	mov    0x10(%ebp),%esi
  801cea:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");
	int r;
    if (pg == NULL) pg = (void *)UTOP;
  801ced:	85 f6                	test   %esi,%esi
  801cef:	75 05                	jne    801cf6 <ipc_send+0x18>
  801cf1:	be 00 00 c0 ee       	mov    $0xeec00000,%esi
    do {
        r = sys_ipc_try_send(to_env, val, pg, perm);
  801cf6:	57                   	push   %edi
  801cf7:	56                   	push   %esi
  801cf8:	ff 75 0c             	pushl  0xc(%ebp)
  801cfb:	ff 75 08             	pushl  0x8(%ebp)
  801cfe:	e8 59 f1 ff ff       	call   800e5c <sys_ipc_try_send>
  801d03:	89 c3                	mov    %eax,%ebx
        if (r < 0 && r != -E_IPC_NOT_RECV) panic("ipc send failed: %e", r);
  801d05:	83 c4 10             	add    $0x10,%esp
  801d08:	85 c0                	test   %eax,%eax
  801d0a:	79 17                	jns    801d23 <ipc_send+0x45>
  801d0c:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801d0f:	74 1d                	je     801d2e <ipc_send+0x50>
  801d11:	50                   	push   %eax
  801d12:	68 c7 24 80 00       	push   $0x8024c7
  801d17:	6a 40                	push   $0x40
  801d19:	68 db 24 80 00       	push   $0x8024db
  801d1e:	e8 7f e4 ff ff       	call   8001a2 <_panic>
        sys_yield();
  801d23:	e8 88 ef ff ff       	call   800cb0 <sys_yield>
    } while (r != 0);
  801d28:	85 db                	test   %ebx,%ebx
  801d2a:	75 ca                	jne    801cf6 <ipc_send+0x18>
  801d2c:	eb 07                	jmp    801d35 <ipc_send+0x57>
	int r;
    if (pg == NULL) pg = (void *)UTOP;
    do {
        r = sys_ipc_try_send(to_env, val, pg, perm);
        if (r < 0 && r != -E_IPC_NOT_RECV) panic("ipc send failed: %e", r);
        sys_yield();
  801d2e:	e8 7d ef ff ff       	call   800cb0 <sys_yield>
  801d33:	eb c1                	jmp    801cf6 <ipc_send+0x18>
    } while (r != 0);
}
  801d35:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d38:	5b                   	pop    %ebx
  801d39:	5e                   	pop    %esi
  801d3a:	5f                   	pop    %edi
  801d3b:	5d                   	pop    %ebp
  801d3c:	c3                   	ret    

00801d3d <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801d3d:	55                   	push   %ebp
  801d3e:	89 e5                	mov    %esp,%ebp
  801d40:	53                   	push   %ebx
  801d41:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801d44:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  801d49:	39 c1                	cmp    %eax,%ecx
  801d4b:	74 21                	je     801d6e <ipc_find_env+0x31>
  801d4d:	ba 01 00 00 00       	mov    $0x1,%edx
  801d52:	8d 1c 95 00 00 00 00 	lea    0x0(,%edx,4),%ebx
  801d59:	89 d0                	mov    %edx,%eax
  801d5b:	c1 e0 07             	shl    $0x7,%eax
  801d5e:	29 d8                	sub    %ebx,%eax
  801d60:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801d65:	8b 40 50             	mov    0x50(%eax),%eax
  801d68:	39 c8                	cmp    %ecx,%eax
  801d6a:	75 1b                	jne    801d87 <ipc_find_env+0x4a>
  801d6c:	eb 05                	jmp    801d73 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801d6e:	ba 00 00 00 00       	mov    $0x0,%edx
		if (envs[i].env_type == type)
			return envs[i].env_id;
  801d73:	8d 04 95 00 00 00 00 	lea    0x0(,%edx,4),%eax
  801d7a:	c1 e2 07             	shl    $0x7,%edx
  801d7d:	29 c2                	sub    %eax,%edx
  801d7f:	8b 82 48 00 c0 ee    	mov    -0x113fffb8(%edx),%eax
  801d85:	eb 0e                	jmp    801d95 <ipc_find_env+0x58>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801d87:	42                   	inc    %edx
  801d88:	81 fa 00 04 00 00    	cmp    $0x400,%edx
  801d8e:	75 c2                	jne    801d52 <ipc_find_env+0x15>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801d90:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d95:	5b                   	pop    %ebx
  801d96:	5d                   	pop    %ebp
  801d97:	c3                   	ret    

00801d98 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801d98:	55                   	push   %ebp
  801d99:	89 e5                	mov    %esp,%ebp
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801d9b:	8b 45 08             	mov    0x8(%ebp),%eax
  801d9e:	c1 e8 16             	shr    $0x16,%eax
  801da1:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801da8:	a8 01                	test   $0x1,%al
  801daa:	74 21                	je     801dcd <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801dac:	8b 45 08             	mov    0x8(%ebp),%eax
  801daf:	c1 e8 0c             	shr    $0xc,%eax
  801db2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801db9:	a8 01                	test   $0x1,%al
  801dbb:	74 17                	je     801dd4 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801dbd:	c1 e8 0c             	shr    $0xc,%eax
  801dc0:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801dc7:	ef 
  801dc8:	0f b7 c0             	movzwl %ax,%eax
  801dcb:	eb 0c                	jmp    801dd9 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801dcd:	b8 00 00 00 00       	mov    $0x0,%eax
  801dd2:	eb 05                	jmp    801dd9 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801dd4:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801dd9:	5d                   	pop    %ebp
  801dda:	c3                   	ret    
  801ddb:	90                   	nop

00801ddc <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801ddc:	55                   	push   %ebp
  801ddd:	57                   	push   %edi
  801dde:	56                   	push   %esi
  801ddf:	53                   	push   %ebx
  801de0:	83 ec 1c             	sub    $0x1c,%esp
  801de3:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801de7:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801deb:	8b 7c 24 38          	mov    0x38(%esp),%edi
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801def:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801df3:	89 ca                	mov    %ecx,%edx
  const DWunion dd = {.ll = d};
  801df5:	89 f8                	mov    %edi,%eax
  801df7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801dfb:	85 f6                	test   %esi,%esi
  801dfd:	75 2d                	jne    801e2c <__udivdi3+0x50>
    {
      if (d0 > n1)
  801dff:	39 cf                	cmp    %ecx,%edi
  801e01:	77 65                	ja     801e68 <__udivdi3+0x8c>
  801e03:	89 fd                	mov    %edi,%ebp
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801e05:	85 ff                	test   %edi,%edi
  801e07:	75 0b                	jne    801e14 <__udivdi3+0x38>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801e09:	b8 01 00 00 00       	mov    $0x1,%eax
  801e0e:	31 d2                	xor    %edx,%edx
  801e10:	f7 f7                	div    %edi
  801e12:	89 c5                	mov    %eax,%ebp

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801e14:	31 d2                	xor    %edx,%edx
  801e16:	89 c8                	mov    %ecx,%eax
  801e18:	f7 f5                	div    %ebp
  801e1a:	89 c1                	mov    %eax,%ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801e1c:	89 d8                	mov    %ebx,%eax
  801e1e:	f7 f5                	div    %ebp
  801e20:	89 cf                	mov    %ecx,%edi
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801e22:	89 fa                	mov    %edi,%edx
  801e24:	83 c4 1c             	add    $0x1c,%esp
  801e27:	5b                   	pop    %ebx
  801e28:	5e                   	pop    %esi
  801e29:	5f                   	pop    %edi
  801e2a:	5d                   	pop    %ebp
  801e2b:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801e2c:	39 ce                	cmp    %ecx,%esi
  801e2e:	77 28                	ja     801e58 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801e30:	0f bd fe             	bsr    %esi,%edi
	  if (bm == 0)
  801e33:	83 f7 1f             	xor    $0x1f,%edi
  801e36:	75 40                	jne    801e78 <__udivdi3+0x9c>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801e38:	39 ce                	cmp    %ecx,%esi
  801e3a:	72 0a                	jb     801e46 <__udivdi3+0x6a>
  801e3c:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801e40:	0f 87 9e 00 00 00    	ja     801ee4 <__udivdi3+0x108>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801e46:	b8 01 00 00 00       	mov    $0x1,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801e4b:	89 fa                	mov    %edi,%edx
  801e4d:	83 c4 1c             	add    $0x1c,%esp
  801e50:	5b                   	pop    %ebx
  801e51:	5e                   	pop    %esi
  801e52:	5f                   	pop    %edi
  801e53:	5d                   	pop    %ebp
  801e54:	c3                   	ret    
  801e55:	8d 76 00             	lea    0x0(%esi),%esi
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801e58:	31 ff                	xor    %edi,%edi
  801e5a:	31 c0                	xor    %eax,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801e5c:	89 fa                	mov    %edi,%edx
  801e5e:	83 c4 1c             	add    $0x1c,%esp
  801e61:	5b                   	pop    %ebx
  801e62:	5e                   	pop    %esi
  801e63:	5f                   	pop    %edi
  801e64:	5d                   	pop    %ebp
  801e65:	c3                   	ret    
  801e66:	66 90                	xchg   %ax,%ax
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801e68:	89 d8                	mov    %ebx,%eax
  801e6a:	f7 f7                	div    %edi
  801e6c:	31 ff                	xor    %edi,%edi
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801e6e:	89 fa                	mov    %edi,%edx
  801e70:	83 c4 1c             	add    $0x1c,%esp
  801e73:	5b                   	pop    %ebx
  801e74:	5e                   	pop    %esi
  801e75:	5f                   	pop    %edi
  801e76:	5d                   	pop    %ebp
  801e77:	c3                   	ret    
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801e78:	bd 20 00 00 00       	mov    $0x20,%ebp
  801e7d:	89 eb                	mov    %ebp,%ebx
  801e7f:	29 fb                	sub    %edi,%ebx

	      d1 = (d1 << bm) | (d0 >> b);
  801e81:	89 f9                	mov    %edi,%ecx
  801e83:	d3 e6                	shl    %cl,%esi
  801e85:	89 c5                	mov    %eax,%ebp
  801e87:	88 d9                	mov    %bl,%cl
  801e89:	d3 ed                	shr    %cl,%ebp
  801e8b:	89 e9                	mov    %ebp,%ecx
  801e8d:	09 f1                	or     %esi,%ecx
  801e8f:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
	      d0 = d0 << bm;
  801e93:	89 f9                	mov    %edi,%ecx
  801e95:	d3 e0                	shl    %cl,%eax
  801e97:	89 c5                	mov    %eax,%ebp
	      n2 = n1 >> b;
  801e99:	89 d6                	mov    %edx,%esi
  801e9b:	88 d9                	mov    %bl,%cl
  801e9d:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
  801e9f:	89 f9                	mov    %edi,%ecx
  801ea1:	d3 e2                	shl    %cl,%edx
  801ea3:	8b 44 24 08          	mov    0x8(%esp),%eax
  801ea7:	88 d9                	mov    %bl,%cl
  801ea9:	d3 e8                	shr    %cl,%eax
  801eab:	09 c2                	or     %eax,%edx
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801ead:	89 d0                	mov    %edx,%eax
  801eaf:	89 f2                	mov    %esi,%edx
  801eb1:	f7 74 24 0c          	divl   0xc(%esp)
  801eb5:	89 d6                	mov    %edx,%esi
  801eb7:	89 c3                	mov    %eax,%ebx
	      umul_ppmm (m1, m0, q0, d0);
  801eb9:	f7 e5                	mul    %ebp

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801ebb:	39 d6                	cmp    %edx,%esi
  801ebd:	72 19                	jb     801ed8 <__udivdi3+0xfc>
  801ebf:	74 0b                	je     801ecc <__udivdi3+0xf0>
  801ec1:	89 d8                	mov    %ebx,%eax
  801ec3:	31 ff                	xor    %edi,%edi
  801ec5:	e9 58 ff ff ff       	jmp    801e22 <__udivdi3+0x46>
  801eca:	66 90                	xchg   %ax,%ax
  801ecc:	8b 54 24 08          	mov    0x8(%esp),%edx
  801ed0:	89 f9                	mov    %edi,%ecx
  801ed2:	d3 e2                	shl    %cl,%edx
  801ed4:	39 c2                	cmp    %eax,%edx
  801ed6:	73 e9                	jae    801ec1 <__udivdi3+0xe5>
  801ed8:	8d 43 ff             	lea    -0x1(%ebx),%eax
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801edb:	31 ff                	xor    %edi,%edi
  801edd:	e9 40 ff ff ff       	jmp    801e22 <__udivdi3+0x46>
  801ee2:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801ee4:	31 c0                	xor    %eax,%eax
  801ee6:	e9 37 ff ff ff       	jmp    801e22 <__udivdi3+0x46>
  801eeb:	90                   	nop

00801eec <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  801eec:	55                   	push   %ebp
  801eed:	57                   	push   %edi
  801eee:	56                   	push   %esi
  801eef:	53                   	push   %ebx
  801ef0:	83 ec 1c             	sub    $0x1c,%esp
  801ef3:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801ef7:	8b 74 24 34          	mov    0x34(%esp),%esi
  801efb:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801eff:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801f03:	89 44 24 0c          	mov    %eax,0xc(%esp)
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801f07:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801f0b:	89 f3                	mov    %esi,%ebx
  const DWunion dd = {.ll = d};
  801f0d:	89 fa                	mov    %edi,%edx
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  801f0f:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  n1 = nn.s.high;
  801f13:	89 34 24             	mov    %esi,(%esp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801f16:	85 c0                	test   %eax,%eax
  801f18:	75 1a                	jne    801f34 <__umoddi3+0x48>
    {
      if (d0 > n1)
  801f1a:	39 f7                	cmp    %esi,%edi
  801f1c:	0f 86 a2 00 00 00    	jbe    801fc4 <__umoddi3+0xd8>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801f22:	89 c8                	mov    %ecx,%eax
  801f24:	89 f2                	mov    %esi,%edx
  801f26:	f7 f7                	div    %edi
  801f28:	89 d0                	mov    %edx,%eax

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  801f2a:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801f2c:	83 c4 1c             	add    $0x1c,%esp
  801f2f:	5b                   	pop    %ebx
  801f30:	5e                   	pop    %esi
  801f31:	5f                   	pop    %edi
  801f32:	5d                   	pop    %ebp
  801f33:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801f34:	39 f0                	cmp    %esi,%eax
  801f36:	0f 87 ac 00 00 00    	ja     801fe8 <__umoddi3+0xfc>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801f3c:	0f bd e8             	bsr    %eax,%ebp
	  if (bm == 0)
  801f3f:	83 f5 1f             	xor    $0x1f,%ebp
  801f42:	0f 84 ac 00 00 00    	je     801ff4 <__umoddi3+0x108>
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801f48:	bf 20 00 00 00       	mov    $0x20,%edi
  801f4d:	29 ef                	sub    %ebp,%edi
  801f4f:	89 fe                	mov    %edi,%esi
  801f51:	89 7c 24 0c          	mov    %edi,0xc(%esp)

	      d1 = (d1 << bm) | (d0 >> b);
  801f55:	89 e9                	mov    %ebp,%ecx
  801f57:	d3 e0                	shl    %cl,%eax
  801f59:	89 d7                	mov    %edx,%edi
  801f5b:	89 f1                	mov    %esi,%ecx
  801f5d:	d3 ef                	shr    %cl,%edi
  801f5f:	09 c7                	or     %eax,%edi
	      d0 = d0 << bm;
  801f61:	89 e9                	mov    %ebp,%ecx
  801f63:	d3 e2                	shl    %cl,%edx
  801f65:	89 14 24             	mov    %edx,(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801f68:	89 d8                	mov    %ebx,%eax
  801f6a:	d3 e0                	shl    %cl,%eax
  801f6c:	89 c2                	mov    %eax,%edx
	      n0 = n0 << bm;
  801f6e:	8b 44 24 08          	mov    0x8(%esp),%eax
  801f72:	d3 e0                	shl    %cl,%eax
  801f74:	89 44 24 04          	mov    %eax,0x4(%esp)

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801f78:	8b 44 24 08          	mov    0x8(%esp),%eax
  801f7c:	89 f1                	mov    %esi,%ecx
  801f7e:	d3 e8                	shr    %cl,%eax
  801f80:	09 d0                	or     %edx,%eax
  801f82:	d3 eb                	shr    %cl,%ebx
  801f84:	89 da                	mov    %ebx,%edx
  801f86:	f7 f7                	div    %edi
  801f88:	89 d3                	mov    %edx,%ebx
	      umul_ppmm (m1, m0, q0, d0);
  801f8a:	f7 24 24             	mull   (%esp)
  801f8d:	89 c6                	mov    %eax,%esi
  801f8f:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801f91:	39 d3                	cmp    %edx,%ebx
  801f93:	0f 82 87 00 00 00    	jb     802020 <__umoddi3+0x134>
  801f99:	0f 84 91 00 00 00    	je     802030 <__umoddi3+0x144>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  801f9f:	8b 54 24 04          	mov    0x4(%esp),%edx
  801fa3:	29 f2                	sub    %esi,%edx
  801fa5:	19 cb                	sbb    %ecx,%ebx
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801fa7:	89 d8                	mov    %ebx,%eax
  801fa9:	8a 4c 24 0c          	mov    0xc(%esp),%cl
  801fad:	d3 e0                	shl    %cl,%eax
  801faf:	89 e9                	mov    %ebp,%ecx
  801fb1:	d3 ea                	shr    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  801fb3:	09 d0                	or     %edx,%eax
  801fb5:	89 e9                	mov    %ebp,%ecx
  801fb7:	d3 eb                	shr    %cl,%ebx
  801fb9:	89 da                	mov    %ebx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801fbb:	83 c4 1c             	add    $0x1c,%esp
  801fbe:	5b                   	pop    %ebx
  801fbf:	5e                   	pop    %esi
  801fc0:	5f                   	pop    %edi
  801fc1:	5d                   	pop    %ebp
  801fc2:	c3                   	ret    
  801fc3:	90                   	nop
  801fc4:	89 fd                	mov    %edi,%ebp
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801fc6:	85 ff                	test   %edi,%edi
  801fc8:	75 0b                	jne    801fd5 <__umoddi3+0xe9>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801fca:	b8 01 00 00 00       	mov    $0x1,%eax
  801fcf:	31 d2                	xor    %edx,%edx
  801fd1:	f7 f7                	div    %edi
  801fd3:	89 c5                	mov    %eax,%ebp

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801fd5:	89 f0                	mov    %esi,%eax
  801fd7:	31 d2                	xor    %edx,%edx
  801fd9:	f7 f5                	div    %ebp
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801fdb:	89 c8                	mov    %ecx,%eax
  801fdd:	f7 f5                	div    %ebp
  801fdf:	89 d0                	mov    %edx,%eax
  801fe1:	e9 44 ff ff ff       	jmp    801f2a <__umoddi3+0x3e>
  801fe6:	66 90                	xchg   %ax,%ax
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  801fe8:	89 c8                	mov    %ecx,%eax
  801fea:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801fec:	83 c4 1c             	add    $0x1c,%esp
  801fef:	5b                   	pop    %ebx
  801ff0:	5e                   	pop    %esi
  801ff1:	5f                   	pop    %edi
  801ff2:	5d                   	pop    %ebp
  801ff3:	c3                   	ret    

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801ff4:	3b 04 24             	cmp    (%esp),%eax
  801ff7:	72 06                	jb     801fff <__umoddi3+0x113>
  801ff9:	3b 7c 24 04          	cmp    0x4(%esp),%edi
  801ffd:	77 0f                	ja     80200e <__umoddi3+0x122>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801fff:	89 f2                	mov    %esi,%edx
  802001:	29 f9                	sub    %edi,%ecx
  802003:	1b 54 24 0c          	sbb    0xc(%esp),%edx
  802007:	89 14 24             	mov    %edx,(%esp)
  80200a:	89 4c 24 04          	mov    %ecx,0x4(%esp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  80200e:	8b 44 24 04          	mov    0x4(%esp),%eax
  802012:	8b 14 24             	mov    (%esp),%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802015:	83 c4 1c             	add    $0x1c,%esp
  802018:	5b                   	pop    %ebx
  802019:	5e                   	pop    %esi
  80201a:	5f                   	pop    %edi
  80201b:	5d                   	pop    %ebp
  80201c:	c3                   	ret    
  80201d:	8d 76 00             	lea    0x0(%esi),%esi
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802020:	2b 04 24             	sub    (%esp),%eax
  802023:	19 fa                	sbb    %edi,%edx
  802025:	89 d1                	mov    %edx,%ecx
  802027:	89 c6                	mov    %eax,%esi
  802029:	e9 71 ff ff ff       	jmp    801f9f <__umoddi3+0xb3>
  80202e:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802030:	39 44 24 04          	cmp    %eax,0x4(%esp)
  802034:	72 ea                	jb     802020 <__umoddi3+0x134>
  802036:	89 d9                	mov    %ebx,%ecx
  802038:	e9 62 ff ff ff       	jmp    801f9f <__umoddi3+0xb3>
