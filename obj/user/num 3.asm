
obj/user/num.debug:     file format elf32-i386


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
  80002c:	e8 52 01 00 00       	call   800183 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <num>:
int bol = 1;
int line = 0;

void
num(int f, const char *s)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	83 ec 10             	sub    $0x10,%esp
  80003b:	8b 75 08             	mov    0x8(%ebp),%esi
	long n;
	int r;
	char c;

	while ((n = read(f, &c, 1)) > 0) {
  80003e:	8d 5d f7             	lea    -0x9(%ebp),%ebx
  800041:	eb 6c                	jmp    8000af <num+0x7c>
		if (bol) {
  800043:	83 3d 00 30 80 00 00 	cmpl   $0x0,0x803000
  80004a:	74 26                	je     800072 <num+0x3f>
			printf("%5d ", ++line);
  80004c:	a1 00 40 80 00       	mov    0x804000,%eax
  800051:	40                   	inc    %eax
  800052:	a3 00 40 80 00       	mov    %eax,0x804000
  800057:	83 ec 08             	sub    $0x8,%esp
  80005a:	50                   	push   %eax
  80005b:	68 a0 20 80 00       	push   $0x8020a0
  800060:	e8 44 17 00 00       	call   8017a9 <printf>
			bol = 0;
  800065:	c7 05 00 30 80 00 00 	movl   $0x0,0x803000
  80006c:	00 00 00 
  80006f:	83 c4 10             	add    $0x10,%esp
		}
		if ((r = write(1, &c, 1)) != 1)
  800072:	83 ec 04             	sub    $0x4,%esp
  800075:	6a 01                	push   $0x1
  800077:	53                   	push   %ebx
  800078:	6a 01                	push   $0x1
  80007a:	e8 83 12 00 00       	call   801302 <write>
  80007f:	83 c4 10             	add    $0x10,%esp
  800082:	83 f8 01             	cmp    $0x1,%eax
  800085:	74 18                	je     80009f <num+0x6c>
			panic("write error copying %s: %e", s, r);
  800087:	83 ec 0c             	sub    $0xc,%esp
  80008a:	50                   	push   %eax
  80008b:	ff 75 0c             	pushl  0xc(%ebp)
  80008e:	68 a5 20 80 00       	push   $0x8020a5
  800093:	6a 13                	push   $0x13
  800095:	68 c0 20 80 00       	push   $0x8020c0
  80009a:	e8 4d 01 00 00       	call   8001ec <_panic>
		if (c == '\n')
  80009f:	80 7d f7 0a          	cmpb   $0xa,-0x9(%ebp)
  8000a3:	75 0a                	jne    8000af <num+0x7c>
			bol = 1;
  8000a5:	c7 05 00 30 80 00 01 	movl   $0x1,0x803000
  8000ac:	00 00 00 
{
	long n;
	int r;
	char c;

	while ((n = read(f, &c, 1)) > 0) {
  8000af:	83 ec 04             	sub    $0x4,%esp
  8000b2:	6a 01                	push   $0x1
  8000b4:	53                   	push   %ebx
  8000b5:	56                   	push   %esi
  8000b6:	e8 6b 11 00 00       	call   801226 <read>
  8000bb:	83 c4 10             	add    $0x10,%esp
  8000be:	85 c0                	test   %eax,%eax
  8000c0:	7f 81                	jg     800043 <num+0x10>
		if ((r = write(1, &c, 1)) != 1)
			panic("write error copying %s: %e", s, r);
		if (c == '\n')
			bol = 1;
	}
	if (n < 0)
  8000c2:	85 c0                	test   %eax,%eax
  8000c4:	79 18                	jns    8000de <num+0xab>
		panic("error reading %s: %e", s, n);
  8000c6:	83 ec 0c             	sub    $0xc,%esp
  8000c9:	50                   	push   %eax
  8000ca:	ff 75 0c             	pushl  0xc(%ebp)
  8000cd:	68 cb 20 80 00       	push   $0x8020cb
  8000d2:	6a 18                	push   $0x18
  8000d4:	68 c0 20 80 00       	push   $0x8020c0
  8000d9:	e8 0e 01 00 00       	call   8001ec <_panic>
}
  8000de:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000e1:	5b                   	pop    %ebx
  8000e2:	5e                   	pop    %esi
  8000e3:	5d                   	pop    %ebp
  8000e4:	c3                   	ret    

008000e5 <umain>:

void
umain(int argc, char **argv)
{
  8000e5:	55                   	push   %ebp
  8000e6:	89 e5                	mov    %esp,%ebp
  8000e8:	57                   	push   %edi
  8000e9:	56                   	push   %esi
  8000ea:	53                   	push   %ebx
  8000eb:	83 ec 1c             	sub    $0x1c,%esp
	int f, i;

	binaryname = "num";
  8000ee:	c7 05 04 30 80 00 e0 	movl   $0x8020e0,0x803004
  8000f5:	20 80 00 
	if (argc == 1)
  8000f8:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
  8000fc:	74 08                	je     800106 <umain+0x21>
		num(0, "<stdin>");
	else
		for (i = 1; i < argc; i++) {
  8000fe:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
  800102:	7f 16                	jg     80011a <umain+0x35>
  800104:	eb 70                	jmp    800176 <umain+0x91>
{
	int f, i;

	binaryname = "num";
	if (argc == 1)
		num(0, "<stdin>");
  800106:	83 ec 08             	sub    $0x8,%esp
  800109:	68 e4 20 80 00       	push   $0x8020e4
  80010e:	6a 00                	push   $0x0
  800110:	e8 1e ff ff ff       	call   800033 <num>
  800115:	83 c4 10             	add    $0x10,%esp
  800118:	eb 5c                	jmp    800176 <umain+0x91>
  80011a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80011d:	8d 58 04             	lea    0x4(%eax),%ebx
	else
		for (i = 1; i < argc; i++) {
  800120:	bf 01 00 00 00       	mov    $0x1,%edi
			f = open(argv[i], O_RDONLY);
  800125:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800128:	83 ec 08             	sub    $0x8,%esp
  80012b:	6a 00                	push   $0x0
  80012d:	ff 33                	pushl  (%ebx)
  80012f:	e8 f3 14 00 00       	call   801627 <open>
  800134:	89 c6                	mov    %eax,%esi
			if (f < 0)
  800136:	83 c4 10             	add    $0x10,%esp
  800139:	85 c0                	test   %eax,%eax
  80013b:	79 1a                	jns    800157 <umain+0x72>
				panic("can't open %s: %e", argv[i], f);
  80013d:	83 ec 0c             	sub    $0xc,%esp
  800140:	50                   	push   %eax
  800141:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800144:	ff 30                	pushl  (%eax)
  800146:	68 ec 20 80 00       	push   $0x8020ec
  80014b:	6a 27                	push   $0x27
  80014d:	68 c0 20 80 00       	push   $0x8020c0
  800152:	e8 95 00 00 00       	call   8001ec <_panic>
			else {
				num(f, argv[i]);
  800157:	83 ec 08             	sub    $0x8,%esp
  80015a:	ff 33                	pushl  (%ebx)
  80015c:	50                   	push   %eax
  80015d:	e8 d1 fe ff ff       	call   800033 <num>
				close(f);
  800162:	89 34 24             	mov    %esi,(%esp)
  800165:	e8 84 0f 00 00       	call   8010ee <close>

	binaryname = "num";
	if (argc == 1)
		num(0, "<stdin>");
	else
		for (i = 1; i < argc; i++) {
  80016a:	47                   	inc    %edi
  80016b:	83 c3 04             	add    $0x4,%ebx
  80016e:	83 c4 10             	add    $0x10,%esp
  800171:	39 7d 08             	cmp    %edi,0x8(%ebp)
  800174:	75 af                	jne    800125 <umain+0x40>
			else {
				num(f, argv[i]);
				close(f);
			}
		}
	exit();
  800176:	e8 57 00 00 00       	call   8001d2 <exit>
}
  80017b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80017e:	5b                   	pop    %ebx
  80017f:	5e                   	pop    %esi
  800180:	5f                   	pop    %edi
  800181:	5d                   	pop    %ebp
  800182:	c3                   	ret    

00800183 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800183:	55                   	push   %ebp
  800184:	89 e5                	mov    %esp,%ebp
  800186:	56                   	push   %esi
  800187:	53                   	push   %ebx
  800188:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80018b:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80018e:	e8 48 0b 00 00       	call   800cdb <sys_getenvid>
  800193:	25 ff 03 00 00       	and    $0x3ff,%eax
  800198:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80019f:	c1 e0 07             	shl    $0x7,%eax
  8001a2:	29 d0                	sub    %edx,%eax
  8001a4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001a9:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001ae:	85 db                	test   %ebx,%ebx
  8001b0:	7e 07                	jle    8001b9 <libmain+0x36>
		binaryname = argv[0];
  8001b2:	8b 06                	mov    (%esi),%eax
  8001b4:	a3 04 30 80 00       	mov    %eax,0x803004

	// call user main routine
	umain(argc, argv);
  8001b9:	83 ec 08             	sub    $0x8,%esp
  8001bc:	56                   	push   %esi
  8001bd:	53                   	push   %ebx
  8001be:	e8 22 ff ff ff       	call   8000e5 <umain>

	// exit gracefully
	exit();
  8001c3:	e8 0a 00 00 00       	call   8001d2 <exit>
}
  8001c8:	83 c4 10             	add    $0x10,%esp
  8001cb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001ce:	5b                   	pop    %ebx
  8001cf:	5e                   	pop    %esi
  8001d0:	5d                   	pop    %ebp
  8001d1:	c3                   	ret    

008001d2 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001d2:	55                   	push   %ebp
  8001d3:	89 e5                	mov    %esp,%ebp
  8001d5:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8001d8:	e8 3c 0f 00 00       	call   801119 <close_all>
	sys_env_destroy(0);
  8001dd:	83 ec 0c             	sub    $0xc,%esp
  8001e0:	6a 00                	push   $0x0
  8001e2:	e8 b3 0a 00 00       	call   800c9a <sys_env_destroy>
}
  8001e7:	83 c4 10             	add    $0x10,%esp
  8001ea:	c9                   	leave  
  8001eb:	c3                   	ret    

008001ec <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8001ec:	55                   	push   %ebp
  8001ed:	89 e5                	mov    %esp,%ebp
  8001ef:	56                   	push   %esi
  8001f0:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8001f1:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001f4:	8b 35 04 30 80 00    	mov    0x803004,%esi
  8001fa:	e8 dc 0a 00 00       	call   800cdb <sys_getenvid>
  8001ff:	83 ec 0c             	sub    $0xc,%esp
  800202:	ff 75 0c             	pushl  0xc(%ebp)
  800205:	ff 75 08             	pushl  0x8(%ebp)
  800208:	56                   	push   %esi
  800209:	50                   	push   %eax
  80020a:	68 08 21 80 00       	push   $0x802108
  80020f:	e8 b0 00 00 00       	call   8002c4 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800214:	83 c4 18             	add    $0x18,%esp
  800217:	53                   	push   %ebx
  800218:	ff 75 10             	pushl  0x10(%ebp)
  80021b:	e8 53 00 00 00       	call   800273 <vcprintf>
	cprintf("\n");
  800220:	c7 04 24 14 25 80 00 	movl   $0x802514,(%esp)
  800227:	e8 98 00 00 00       	call   8002c4 <cprintf>
  80022c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80022f:	cc                   	int3   
  800230:	eb fd                	jmp    80022f <_panic+0x43>

00800232 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800232:	55                   	push   %ebp
  800233:	89 e5                	mov    %esp,%ebp
  800235:	53                   	push   %ebx
  800236:	83 ec 04             	sub    $0x4,%esp
  800239:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80023c:	8b 13                	mov    (%ebx),%edx
  80023e:	8d 42 01             	lea    0x1(%edx),%eax
  800241:	89 03                	mov    %eax,(%ebx)
  800243:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800246:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80024a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80024f:	75 1a                	jne    80026b <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800251:	83 ec 08             	sub    $0x8,%esp
  800254:	68 ff 00 00 00       	push   $0xff
  800259:	8d 43 08             	lea    0x8(%ebx),%eax
  80025c:	50                   	push   %eax
  80025d:	e8 fb 09 00 00       	call   800c5d <sys_cputs>
		b->idx = 0;
  800262:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800268:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80026b:	ff 43 04             	incl   0x4(%ebx)
}
  80026e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800271:	c9                   	leave  
  800272:	c3                   	ret    

00800273 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800273:	55                   	push   %ebp
  800274:	89 e5                	mov    %esp,%ebp
  800276:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80027c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800283:	00 00 00 
	b.cnt = 0;
  800286:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80028d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800290:	ff 75 0c             	pushl  0xc(%ebp)
  800293:	ff 75 08             	pushl  0x8(%ebp)
  800296:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80029c:	50                   	push   %eax
  80029d:	68 32 02 80 00       	push   $0x800232
  8002a2:	e8 54 01 00 00       	call   8003fb <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002a7:	83 c4 08             	add    $0x8,%esp
  8002aa:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8002b0:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002b6:	50                   	push   %eax
  8002b7:	e8 a1 09 00 00       	call   800c5d <sys_cputs>

	return b.cnt;
}
  8002bc:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002c2:	c9                   	leave  
  8002c3:	c3                   	ret    

008002c4 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002c4:	55                   	push   %ebp
  8002c5:	89 e5                	mov    %esp,%ebp
  8002c7:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002ca:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002cd:	50                   	push   %eax
  8002ce:	ff 75 08             	pushl  0x8(%ebp)
  8002d1:	e8 9d ff ff ff       	call   800273 <vcprintf>
	va_end(ap);

	return cnt;
}
  8002d6:	c9                   	leave  
  8002d7:	c3                   	ret    

008002d8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002d8:	55                   	push   %ebp
  8002d9:	89 e5                	mov    %esp,%ebp
  8002db:	57                   	push   %edi
  8002dc:	56                   	push   %esi
  8002dd:	53                   	push   %ebx
  8002de:	83 ec 1c             	sub    $0x1c,%esp
  8002e1:	89 c6                	mov    %eax,%esi
  8002e3:	89 d7                	mov    %edx,%edi
  8002e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8002e8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002eb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002ee:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002f1:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8002f4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002f9:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8002fc:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8002ff:	39 d3                	cmp    %edx,%ebx
  800301:	72 11                	jb     800314 <printnum+0x3c>
  800303:	39 45 10             	cmp    %eax,0x10(%ebp)
  800306:	76 0c                	jbe    800314 <printnum+0x3c>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800308:	8b 45 14             	mov    0x14(%ebp),%eax
  80030b:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80030e:	85 db                	test   %ebx,%ebx
  800310:	7f 37                	jg     800349 <printnum+0x71>
  800312:	eb 44                	jmp    800358 <printnum+0x80>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800314:	83 ec 0c             	sub    $0xc,%esp
  800317:	ff 75 18             	pushl  0x18(%ebp)
  80031a:	8b 45 14             	mov    0x14(%ebp),%eax
  80031d:	48                   	dec    %eax
  80031e:	50                   	push   %eax
  80031f:	ff 75 10             	pushl  0x10(%ebp)
  800322:	83 ec 08             	sub    $0x8,%esp
  800325:	ff 75 e4             	pushl  -0x1c(%ebp)
  800328:	ff 75 e0             	pushl  -0x20(%ebp)
  80032b:	ff 75 dc             	pushl  -0x24(%ebp)
  80032e:	ff 75 d8             	pushl  -0x28(%ebp)
  800331:	e8 f2 1a 00 00       	call   801e28 <__udivdi3>
  800336:	83 c4 18             	add    $0x18,%esp
  800339:	52                   	push   %edx
  80033a:	50                   	push   %eax
  80033b:	89 fa                	mov    %edi,%edx
  80033d:	89 f0                	mov    %esi,%eax
  80033f:	e8 94 ff ff ff       	call   8002d8 <printnum>
  800344:	83 c4 20             	add    $0x20,%esp
  800347:	eb 0f                	jmp    800358 <printnum+0x80>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800349:	83 ec 08             	sub    $0x8,%esp
  80034c:	57                   	push   %edi
  80034d:	ff 75 18             	pushl  0x18(%ebp)
  800350:	ff d6                	call   *%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800352:	83 c4 10             	add    $0x10,%esp
  800355:	4b                   	dec    %ebx
  800356:	75 f1                	jne    800349 <printnum+0x71>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800358:	83 ec 08             	sub    $0x8,%esp
  80035b:	57                   	push   %edi
  80035c:	83 ec 04             	sub    $0x4,%esp
  80035f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800362:	ff 75 e0             	pushl  -0x20(%ebp)
  800365:	ff 75 dc             	pushl  -0x24(%ebp)
  800368:	ff 75 d8             	pushl  -0x28(%ebp)
  80036b:	e8 c8 1b 00 00       	call   801f38 <__umoddi3>
  800370:	83 c4 14             	add    $0x14,%esp
  800373:	0f be 80 2b 21 80 00 	movsbl 0x80212b(%eax),%eax
  80037a:	50                   	push   %eax
  80037b:	ff d6                	call   *%esi
}
  80037d:	83 c4 10             	add    $0x10,%esp
  800380:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800383:	5b                   	pop    %ebx
  800384:	5e                   	pop    %esi
  800385:	5f                   	pop    %edi
  800386:	5d                   	pop    %ebp
  800387:	c3                   	ret    

00800388 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800388:	55                   	push   %ebp
  800389:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80038b:	83 fa 01             	cmp    $0x1,%edx
  80038e:	7e 0e                	jle    80039e <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800390:	8b 10                	mov    (%eax),%edx
  800392:	8d 4a 08             	lea    0x8(%edx),%ecx
  800395:	89 08                	mov    %ecx,(%eax)
  800397:	8b 02                	mov    (%edx),%eax
  800399:	8b 52 04             	mov    0x4(%edx),%edx
  80039c:	eb 22                	jmp    8003c0 <getuint+0x38>
	else if (lflag)
  80039e:	85 d2                	test   %edx,%edx
  8003a0:	74 10                	je     8003b2 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003a2:	8b 10                	mov    (%eax),%edx
  8003a4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003a7:	89 08                	mov    %ecx,(%eax)
  8003a9:	8b 02                	mov    (%edx),%eax
  8003ab:	ba 00 00 00 00       	mov    $0x0,%edx
  8003b0:	eb 0e                	jmp    8003c0 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003b2:	8b 10                	mov    (%eax),%edx
  8003b4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003b7:	89 08                	mov    %ecx,(%eax)
  8003b9:	8b 02                	mov    (%edx),%eax
  8003bb:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003c0:	5d                   	pop    %ebp
  8003c1:	c3                   	ret    

008003c2 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003c2:	55                   	push   %ebp
  8003c3:	89 e5                	mov    %esp,%ebp
  8003c5:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003c8:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8003cb:	8b 10                	mov    (%eax),%edx
  8003cd:	3b 50 04             	cmp    0x4(%eax),%edx
  8003d0:	73 0a                	jae    8003dc <sprintputch+0x1a>
		*b->buf++ = ch;
  8003d2:	8d 4a 01             	lea    0x1(%edx),%ecx
  8003d5:	89 08                	mov    %ecx,(%eax)
  8003d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8003da:	88 02                	mov    %al,(%edx)
}
  8003dc:	5d                   	pop    %ebp
  8003dd:	c3                   	ret    

008003de <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003de:	55                   	push   %ebp
  8003df:	89 e5                	mov    %esp,%ebp
  8003e1:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8003e4:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003e7:	50                   	push   %eax
  8003e8:	ff 75 10             	pushl  0x10(%ebp)
  8003eb:	ff 75 0c             	pushl  0xc(%ebp)
  8003ee:	ff 75 08             	pushl  0x8(%ebp)
  8003f1:	e8 05 00 00 00       	call   8003fb <vprintfmt>
	va_end(ap);
}
  8003f6:	83 c4 10             	add    $0x10,%esp
  8003f9:	c9                   	leave  
  8003fa:	c3                   	ret    

008003fb <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003fb:	55                   	push   %ebp
  8003fc:	89 e5                	mov    %esp,%ebp
  8003fe:	57                   	push   %edi
  8003ff:	56                   	push   %esi
  800400:	53                   	push   %ebx
  800401:	83 ec 2c             	sub    $0x2c,%esp
  800404:	8b 7d 08             	mov    0x8(%ebp),%edi
  800407:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80040a:	eb 03                	jmp    80040f <vprintfmt+0x14>
			break;

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
			for (fmt--; fmt[-1] != '%'; fmt--)
  80040c:	89 75 10             	mov    %esi,0x10(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {    //遍历输入的第一个参数，即输出信息的格式，先把格式字符串中'%'之前的字符一个个输出，因为它们前面没有'%'，所以它们就是要直接显示在屏幕上的
  80040f:	8b 45 10             	mov    0x10(%ebp),%eax
  800412:	8d 70 01             	lea    0x1(%eax),%esi
  800415:	0f b6 00             	movzbl (%eax),%eax
  800418:	83 f8 25             	cmp    $0x25,%eax
  80041b:	74 25                	je     800442 <vprintfmt+0x47>
			if (ch == '\0')									//当然中间如果遇到'\0'，代表这个字符串的访问结束
  80041d:	85 c0                	test   %eax,%eax
  80041f:	75 0d                	jne    80042e <vprintfmt+0x33>
  800421:	e9 b5 03 00 00       	jmp    8007db <vprintfmt+0x3e0>
  800426:	85 c0                	test   %eax,%eax
  800428:	0f 84 ad 03 00 00    	je     8007db <vprintfmt+0x3e0>
				return;
			putch(ch, putdat);								//调用putch函数，把一个字符ch输出到putdat指针所指向的地址中所存放的值对应的地址处
  80042e:	83 ec 08             	sub    $0x8,%esp
  800431:	53                   	push   %ebx
  800432:	50                   	push   %eax
  800433:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {    //遍历输入的第一个参数，即输出信息的格式，先把格式字符串中'%'之前的字符一个个输出，因为它们前面没有'%'，所以它们就是要直接显示在屏幕上的
  800435:	46                   	inc    %esi
  800436:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  80043a:	83 c4 10             	add    $0x10,%esp
  80043d:	83 f8 25             	cmp    $0x25,%eax
  800440:	75 e4                	jne    800426 <vprintfmt+0x2b>
			if (width < 0)									//代表有小数点，但是小数点前面并没有数字，比如'%.6f'这种情况，此时代表整数部分全部显示
				width = 0;			
			goto reswitch;

		case '#':
			altflag = 1;
  800442:	c6 45 e3 20          	movb   $0x20,-0x1d(%ebp)
  800446:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80044d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800454:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80045b:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800462:	eb 07                	jmp    80046b <vprintfmt+0x70>
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  800464:	8b 75 10             	mov    0x10(%ebp),%esi

		// flag to pad on the right
		case '-':											//%后面的'-'代表要进行左对齐输出，右边填空格，如果省略代表右对齐
			padc = '-';										//如果有这个字符代表左对齐，则把对齐方式标志位变为'-'
  800467:	c6 45 e3 2d          	movb   $0x2d,-0x1d(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  80046b:	8d 46 01             	lea    0x1(%esi),%eax
  80046e:	89 45 10             	mov    %eax,0x10(%ebp)
  800471:	0f b6 16             	movzbl (%esi),%edx
  800474:	8a 06                	mov    (%esi),%al
  800476:	83 e8 23             	sub    $0x23,%eax
  800479:	3c 55                	cmp    $0x55,%al
  80047b:	0f 87 03 03 00 00    	ja     800784 <vprintfmt+0x389>
  800481:	0f b6 c0             	movzbl %al,%eax
  800484:	ff 24 85 60 22 80 00 	jmp    *0x802260(,%eax,4)
  80048b:	8b 75 10             	mov    0x10(%ebp),%esi
			padc = '-';										//如果有这个字符代表左对齐，则把对齐方式标志位变为'-'
			goto reswitch;									//处理下一个字符

		// flag to pad with 0's instead of spaces
		case '0':											//0--有0表示进行对齐输出时填0,如省略表示填入空格，并且如果为0，则一定是右对齐
			padc = '0';										//对其方式标志位变为0
  80048e:	c6 45 e3 30          	movb   $0x30,-0x1d(%ebp)
  800492:	eb d7                	jmp    80046b <vprintfmt+0x70>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {					//把遇到的位数字符串转换为真实的位数，比如输入的'%40'，代表有效位数为40位，下面的循环就是把precesion的值设置为40
				precision = precision * 10 + ch - '0';
  800494:	8d 42 d0             	lea    -0x30(%edx),%eax
  800497:	89 c1                	mov    %eax,%ecx
  800499:	89 45 d0             	mov    %eax,-0x30(%ebp)
				ch = *fmt;
  80049c:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  8004a0:	8d 50 d0             	lea    -0x30(%eax),%edx
  8004a3:	83 fa 09             	cmp    $0x9,%edx
  8004a6:	77 51                	ja     8004f9 <vprintfmt+0xfe>
  8004a8:	8b 75 10             	mov    0x10(%ebp),%esi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {					//把遇到的位数字符串转换为真实的位数，比如输入的'%40'，代表有效位数为40位，下面的循环就是把precesion的值设置为40
  8004ab:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  8004ac:	8d 14 89             	lea    (%ecx,%ecx,4),%edx
  8004af:	01 d2                	add    %edx,%edx
  8004b1:	8d 4c 10 d0          	lea    -0x30(%eax,%edx,1),%ecx
				ch = *fmt;
  8004b5:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8004b8:	8d 50 d0             	lea    -0x30(%eax),%edx
  8004bb:	83 fa 09             	cmp    $0x9,%edx
  8004be:	76 eb                	jbe    8004ab <vprintfmt+0xb0>
  8004c0:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8004c3:	eb 37                	jmp    8004fc <vprintfmt+0x101>
					break;
			}
			goto process_precision;							//跳转到process_precistion子过程

		case '*':											//*--代表有效数字的位数也是由输入参数指定的，比如printf("%*.*f", 10, 2, n)，其中10,2就是用来指定显示的有效数字位数的
			precision = va_arg(ap, int);
  8004c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c8:	8d 50 04             	lea    0x4(%eax),%edx
  8004cb:	89 55 14             	mov    %edx,0x14(%ebp)
  8004ce:	8b 00                	mov    (%eax),%eax
  8004d0:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  8004d3:	8b 75 10             	mov    0x10(%ebp),%esi
			}
			goto process_precision;							//跳转到process_precistion子过程

		case '*':											//*--代表有效数字的位数也是由输入参数指定的，比如printf("%*.*f", 10, 2, n)，其中10,2就是用来指定显示的有效数字位数的
			precision = va_arg(ap, int);
			goto process_precision;
  8004d6:	eb 24                	jmp    8004fc <vprintfmt+0x101>
  8004d8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004dc:	79 07                	jns    8004e5 <vprintfmt+0xea>
  8004de:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  8004e5:	8b 75 10             	mov    0x10(%ebp),%esi
  8004e8:	eb 81                	jmp    80046b <vprintfmt+0x70>
  8004ea:	8b 75 10             	mov    0x10(%ebp),%esi
			if (width < 0)									//代表有小数点，但是小数点前面并没有数字，比如'%.6f'这种情况，此时代表整数部分全部显示
				width = 0;			
			goto reswitch;

		case '#':
			altflag = 1;
  8004ed:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8004f4:	e9 72 ff ff ff       	jmp    80046b <vprintfmt+0x70>
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  8004f9:	8b 75 10             	mov    0x10(%ebp),%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:									//处理输出精度，把width字段赋值为刚刚计算出来的precision值，所以width应该是整数部分的有效数字位数
			if (width < 0)
  8004fc:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800500:	0f 89 65 ff ff ff    	jns    80046b <vprintfmt+0x70>
				width = precision, precision = -1;
  800506:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800509:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80050c:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800513:	e9 53 ff ff ff       	jmp    80046b <vprintfmt+0x70>
			goto reswitch;

		// long flag (doubled for long long)				
		case 'l':											//如果遇到'l'，代表应该是输入long类型，如果有两个'l'代表long long
			lflag++;										//此时把lflag++
  800518:	ff 45 d4             	incl   -0x2c(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  80051b:	8b 75 10             	mov    0x10(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)				
		case 'l':											//如果遇到'l'，代表应该是输入long类型，如果有两个'l'代表long long
			lflag++;										//此时把lflag++
			goto reswitch;
  80051e:	e9 48 ff ff ff       	jmp    80046b <vprintfmt+0x70>

		// character
		case 'c':											//如果是'c'代表显示一个字符
			putch(va_arg(ap, int), putdat);					//调用输出一个字符到内存的函数putch
  800523:	8b 45 14             	mov    0x14(%ebp),%eax
  800526:	8d 50 04             	lea    0x4(%eax),%edx
  800529:	89 55 14             	mov    %edx,0x14(%ebp)
  80052c:	83 ec 08             	sub    $0x8,%esp
  80052f:	53                   	push   %ebx
  800530:	ff 30                	pushl  (%eax)
  800532:	ff d7                	call   *%edi
			break;
  800534:	83 c4 10             	add    $0x10,%esp
  800537:	e9 d3 fe ff ff       	jmp    80040f <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80053c:	8b 45 14             	mov    0x14(%ebp),%eax
  80053f:	8d 50 04             	lea    0x4(%eax),%edx
  800542:	89 55 14             	mov    %edx,0x14(%ebp)
  800545:	8b 00                	mov    (%eax),%eax
  800547:	85 c0                	test   %eax,%eax
  800549:	79 02                	jns    80054d <vprintfmt+0x152>
  80054b:	f7 d8                	neg    %eax
  80054d:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80054f:	83 f8 0f             	cmp    $0xf,%eax
  800552:	7f 0b                	jg     80055f <vprintfmt+0x164>
  800554:	8b 04 85 c0 23 80 00 	mov    0x8023c0(,%eax,4),%eax
  80055b:	85 c0                	test   %eax,%eax
  80055d:	75 15                	jne    800574 <vprintfmt+0x179>
				printfmt(putch, putdat, "error %d", err);
  80055f:	52                   	push   %edx
  800560:	68 43 21 80 00       	push   $0x802143
  800565:	53                   	push   %ebx
  800566:	57                   	push   %edi
  800567:	e8 72 fe ff ff       	call   8003de <printfmt>
  80056c:	83 c4 10             	add    $0x10,%esp
  80056f:	e9 9b fe ff ff       	jmp    80040f <vprintfmt+0x14>
			else
				printfmt(putch, putdat, "%s", p);
  800574:	50                   	push   %eax
  800575:	68 e2 24 80 00       	push   $0x8024e2
  80057a:	53                   	push   %ebx
  80057b:	57                   	push   %edi
  80057c:	e8 5d fe ff ff       	call   8003de <printfmt>
  800581:	83 c4 10             	add    $0x10,%esp
  800584:	e9 86 fe ff ff       	jmp    80040f <vprintfmt+0x14>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800589:	8b 45 14             	mov    0x14(%ebp),%eax
  80058c:	8d 50 04             	lea    0x4(%eax),%edx
  80058f:	89 55 14             	mov    %edx,0x14(%ebp)
  800592:	8b 00                	mov    (%eax),%eax
  800594:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800597:	85 c0                	test   %eax,%eax
  800599:	75 07                	jne    8005a2 <vprintfmt+0x1a7>
				p = "(null)";
  80059b:	c7 45 d4 3c 21 80 00 	movl   $0x80213c,-0x2c(%ebp)
			if (width > 0 && padc != '-')
  8005a2:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8005a5:	85 f6                	test   %esi,%esi
  8005a7:	0f 8e fb 01 00 00    	jle    8007a8 <vprintfmt+0x3ad>
  8005ad:	80 7d e3 2d          	cmpb   $0x2d,-0x1d(%ebp)
  8005b1:	0f 84 09 02 00 00    	je     8007c0 <vprintfmt+0x3c5>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005b7:	83 ec 08             	sub    $0x8,%esp
  8005ba:	ff 75 d0             	pushl  -0x30(%ebp)
  8005bd:	ff 75 d4             	pushl  -0x2c(%ebp)
  8005c0:	e8 ad 02 00 00       	call   800872 <strnlen>
  8005c5:	89 f1                	mov    %esi,%ecx
  8005c7:	29 c1                	sub    %eax,%ecx
  8005c9:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  8005cc:	83 c4 10             	add    $0x10,%esp
  8005cf:	85 c9                	test   %ecx,%ecx
  8005d1:	0f 8e d1 01 00 00    	jle    8007a8 <vprintfmt+0x3ad>
					putch(padc, putdat);
  8005d7:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  8005db:	83 ec 08             	sub    $0x8,%esp
  8005de:	53                   	push   %ebx
  8005df:	56                   	push   %esi
  8005e0:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005e2:	83 c4 10             	add    $0x10,%esp
  8005e5:	ff 4d e4             	decl   -0x1c(%ebp)
  8005e8:	75 f1                	jne    8005db <vprintfmt+0x1e0>
  8005ea:	e9 b9 01 00 00       	jmp    8007a8 <vprintfmt+0x3ad>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005ef:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005f3:	74 19                	je     80060e <vprintfmt+0x213>
  8005f5:	0f be c0             	movsbl %al,%eax
  8005f8:	83 e8 20             	sub    $0x20,%eax
  8005fb:	83 f8 5e             	cmp    $0x5e,%eax
  8005fe:	76 0e                	jbe    80060e <vprintfmt+0x213>
					putch('?', putdat);
  800600:	83 ec 08             	sub    $0x8,%esp
  800603:	53                   	push   %ebx
  800604:	6a 3f                	push   $0x3f
  800606:	ff 55 08             	call   *0x8(%ebp)
  800609:	83 c4 10             	add    $0x10,%esp
  80060c:	eb 0b                	jmp    800619 <vprintfmt+0x21e>
				else
					putch(ch, putdat);
  80060e:	83 ec 08             	sub    $0x8,%esp
  800611:	53                   	push   %ebx
  800612:	52                   	push   %edx
  800613:	ff 55 08             	call   *0x8(%ebp)
  800616:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800619:	ff 4d e4             	decl   -0x1c(%ebp)
  80061c:	46                   	inc    %esi
  80061d:	8a 46 ff             	mov    -0x1(%esi),%al
  800620:	0f be d0             	movsbl %al,%edx
  800623:	85 d2                	test   %edx,%edx
  800625:	75 1c                	jne    800643 <vprintfmt+0x248>
  800627:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80062a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80062e:	7f 1f                	jg     80064f <vprintfmt+0x254>
  800630:	e9 da fd ff ff       	jmp    80040f <vprintfmt+0x14>
  800635:	89 7d 08             	mov    %edi,0x8(%ebp)
  800638:	8b 7d d0             	mov    -0x30(%ebp),%edi
  80063b:	eb 06                	jmp    800643 <vprintfmt+0x248>
  80063d:	89 7d 08             	mov    %edi,0x8(%ebp)
  800640:	8b 7d d0             	mov    -0x30(%ebp),%edi
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800643:	85 ff                	test   %edi,%edi
  800645:	78 a8                	js     8005ef <vprintfmt+0x1f4>
  800647:	4f                   	dec    %edi
  800648:	79 a5                	jns    8005ef <vprintfmt+0x1f4>
  80064a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80064d:	eb db                	jmp    80062a <vprintfmt+0x22f>
  80064f:	8b 75 e4             	mov    -0x1c(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800652:	83 ec 08             	sub    $0x8,%esp
  800655:	53                   	push   %ebx
  800656:	6a 20                	push   $0x20
  800658:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80065a:	4e                   	dec    %esi
  80065b:	83 c4 10             	add    $0x10,%esp
  80065e:	85 f6                	test   %esi,%esi
  800660:	7f f0                	jg     800652 <vprintfmt+0x257>
  800662:	e9 a8 fd ff ff       	jmp    80040f <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800667:	83 7d d4 01          	cmpl   $0x1,-0x2c(%ebp)
  80066b:	7e 16                	jle    800683 <vprintfmt+0x288>
		return va_arg(*ap, long long);
  80066d:	8b 45 14             	mov    0x14(%ebp),%eax
  800670:	8d 50 08             	lea    0x8(%eax),%edx
  800673:	89 55 14             	mov    %edx,0x14(%ebp)
  800676:	8b 50 04             	mov    0x4(%eax),%edx
  800679:	8b 00                	mov    (%eax),%eax
  80067b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80067e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800681:	eb 34                	jmp    8006b7 <vprintfmt+0x2bc>
	else if (lflag)
  800683:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800687:	74 18                	je     8006a1 <vprintfmt+0x2a6>
		return va_arg(*ap, long);
  800689:	8b 45 14             	mov    0x14(%ebp),%eax
  80068c:	8d 50 04             	lea    0x4(%eax),%edx
  80068f:	89 55 14             	mov    %edx,0x14(%ebp)
  800692:	8b 30                	mov    (%eax),%esi
  800694:	89 75 d8             	mov    %esi,-0x28(%ebp)
  800697:	89 f0                	mov    %esi,%eax
  800699:	c1 f8 1f             	sar    $0x1f,%eax
  80069c:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80069f:	eb 16                	jmp    8006b7 <vprintfmt+0x2bc>
	else
		return va_arg(*ap, int);
  8006a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a4:	8d 50 04             	lea    0x4(%eax),%edx
  8006a7:	89 55 14             	mov    %edx,0x14(%ebp)
  8006aa:	8b 30                	mov    (%eax),%esi
  8006ac:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8006af:	89 f0                	mov    %esi,%eax
  8006b1:	c1 f8 1f             	sar    $0x1f,%eax
  8006b4:	89 45 dc             	mov    %eax,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006b7:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8006ba:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
  8006bd:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8006c1:	0f 89 8a 00 00 00    	jns    800751 <vprintfmt+0x356>
				putch('-', putdat);
  8006c7:	83 ec 08             	sub    $0x8,%esp
  8006ca:	53                   	push   %ebx
  8006cb:	6a 2d                	push   $0x2d
  8006cd:	ff d7                	call   *%edi
				num = -(long long) num;
  8006cf:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8006d2:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8006d5:	f7 d8                	neg    %eax
  8006d7:	83 d2 00             	adc    $0x0,%edx
  8006da:	f7 da                	neg    %edx
  8006dc:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8006df:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8006e4:	eb 70                	jmp    800756 <vprintfmt+0x35b>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006e6:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8006e9:	8d 45 14             	lea    0x14(%ebp),%eax
  8006ec:	e8 97 fc ff ff       	call   800388 <getuint>
			base = 10;
  8006f1:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8006f6:	eb 5e                	jmp    800756 <vprintfmt+0x35b>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
  8006f8:	83 ec 08             	sub    $0x8,%esp
  8006fb:	53                   	push   %ebx
  8006fc:	6a 30                	push   $0x30
  8006fe:	ff d7                	call   *%edi
			num = getuint(&ap, lflag);
  800700:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800703:	8d 45 14             	lea    0x14(%ebp),%eax
  800706:	e8 7d fc ff ff       	call   800388 <getuint>
			base = 8;
			goto number;
  80070b:	83 c4 10             	add    $0x10,%esp
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  80070e:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800713:	eb 41                	jmp    800756 <vprintfmt+0x35b>
		// pointer
		case 'p':
			putch('0', putdat);
  800715:	83 ec 08             	sub    $0x8,%esp
  800718:	53                   	push   %ebx
  800719:	6a 30                	push   $0x30
  80071b:	ff d7                	call   *%edi
			putch('x', putdat);
  80071d:	83 c4 08             	add    $0x8,%esp
  800720:	53                   	push   %ebx
  800721:	6a 78                	push   $0x78
  800723:	ff d7                	call   *%edi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800725:	8b 45 14             	mov    0x14(%ebp),%eax
  800728:	8d 50 04             	lea    0x4(%eax),%edx
  80072b:	89 55 14             	mov    %edx,0x14(%ebp)
			goto number;
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80072e:	8b 00                	mov    (%eax),%eax
  800730:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800735:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800738:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80073d:	eb 17                	jmp    800756 <vprintfmt+0x35b>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80073f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800742:	8d 45 14             	lea    0x14(%ebp),%eax
  800745:	e8 3e fc ff ff       	call   800388 <getuint>
			base = 16;
  80074a:	b9 10 00 00 00       	mov    $0x10,%ecx
  80074f:	eb 05                	jmp    800756 <vprintfmt+0x35b>
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800751:	b9 0a 00 00 00       	mov    $0xa,%ecx
		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  800756:	83 ec 0c             	sub    $0xc,%esp
  800759:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  80075d:	56                   	push   %esi
  80075e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800761:	51                   	push   %ecx
  800762:	52                   	push   %edx
  800763:	50                   	push   %eax
  800764:	89 da                	mov    %ebx,%edx
  800766:	89 f8                	mov    %edi,%eax
  800768:	e8 6b fb ff ff       	call   8002d8 <printnum>
			break;
  80076d:	83 c4 20             	add    $0x20,%esp
  800770:	e9 9a fc ff ff       	jmp    80040f <vprintfmt+0x14>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800775:	83 ec 08             	sub    $0x8,%esp
  800778:	53                   	push   %ebx
  800779:	52                   	push   %edx
  80077a:	ff d7                	call   *%edi
			break;
  80077c:	83 c4 10             	add    $0x10,%esp
  80077f:	e9 8b fc ff ff       	jmp    80040f <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800784:	83 ec 08             	sub    $0x8,%esp
  800787:	53                   	push   %ebx
  800788:	6a 25                	push   $0x25
  80078a:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80078c:	83 c4 10             	add    $0x10,%esp
  80078f:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800793:	0f 84 73 fc ff ff    	je     80040c <vprintfmt+0x11>
  800799:	4e                   	dec    %esi
  80079a:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80079e:	75 f9                	jne    800799 <vprintfmt+0x39e>
  8007a0:	89 75 10             	mov    %esi,0x10(%ebp)
  8007a3:	e9 67 fc ff ff       	jmp    80040f <vprintfmt+0x14>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8007a8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8007ab:	8d 70 01             	lea    0x1(%eax),%esi
  8007ae:	8a 00                	mov    (%eax),%al
  8007b0:	0f be d0             	movsbl %al,%edx
  8007b3:	85 d2                	test   %edx,%edx
  8007b5:	0f 85 7a fe ff ff    	jne    800635 <vprintfmt+0x23a>
  8007bb:	e9 4f fc ff ff       	jmp    80040f <vprintfmt+0x14>
  8007c0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8007c3:	8d 70 01             	lea    0x1(%eax),%esi
  8007c6:	8a 00                	mov    (%eax),%al
  8007c8:	0f be d0             	movsbl %al,%edx
  8007cb:	85 d2                	test   %edx,%edx
  8007cd:	0f 85 6a fe ff ff    	jne    80063d <vprintfmt+0x242>
  8007d3:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8007d6:	e9 77 fe ff ff       	jmp    800652 <vprintfmt+0x257>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  8007db:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007de:	5b                   	pop    %ebx
  8007df:	5e                   	pop    %esi
  8007e0:	5f                   	pop    %edi
  8007e1:	5d                   	pop    %ebp
  8007e2:	c3                   	ret    

008007e3 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007e3:	55                   	push   %ebp
  8007e4:	89 e5                	mov    %esp,%ebp
  8007e6:	83 ec 18             	sub    $0x18,%esp
  8007e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ec:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007ef:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007f2:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007f6:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007f9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800800:	85 c0                	test   %eax,%eax
  800802:	74 26                	je     80082a <vsnprintf+0x47>
  800804:	85 d2                	test   %edx,%edx
  800806:	7e 29                	jle    800831 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800808:	ff 75 14             	pushl  0x14(%ebp)
  80080b:	ff 75 10             	pushl  0x10(%ebp)
  80080e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800811:	50                   	push   %eax
  800812:	68 c2 03 80 00       	push   $0x8003c2
  800817:	e8 df fb ff ff       	call   8003fb <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80081c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80081f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800822:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800825:	83 c4 10             	add    $0x10,%esp
  800828:	eb 0c                	jmp    800836 <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80082a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80082f:	eb 05                	jmp    800836 <vsnprintf+0x53>
  800831:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800836:	c9                   	leave  
  800837:	c3                   	ret    

00800838 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800838:	55                   	push   %ebp
  800839:	89 e5                	mov    %esp,%ebp
  80083b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80083e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800841:	50                   	push   %eax
  800842:	ff 75 10             	pushl  0x10(%ebp)
  800845:	ff 75 0c             	pushl  0xc(%ebp)
  800848:	ff 75 08             	pushl  0x8(%ebp)
  80084b:	e8 93 ff ff ff       	call   8007e3 <vsnprintf>
	va_end(ap);

	return rc;
}
  800850:	c9                   	leave  
  800851:	c3                   	ret    

00800852 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800852:	55                   	push   %ebp
  800853:	89 e5                	mov    %esp,%ebp
  800855:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800858:	80 3a 00             	cmpb   $0x0,(%edx)
  80085b:	74 0e                	je     80086b <strlen+0x19>
  80085d:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800862:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800863:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800867:	75 f9                	jne    800862 <strlen+0x10>
  800869:	eb 05                	jmp    800870 <strlen+0x1e>
  80086b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800870:	5d                   	pop    %ebp
  800871:	c3                   	ret    

00800872 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800872:	55                   	push   %ebp
  800873:	89 e5                	mov    %esp,%ebp
  800875:	53                   	push   %ebx
  800876:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800879:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80087c:	85 c9                	test   %ecx,%ecx
  80087e:	74 1a                	je     80089a <strnlen+0x28>
  800880:	80 3b 00             	cmpb   $0x0,(%ebx)
  800883:	74 1c                	je     8008a1 <strnlen+0x2f>
  800885:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  80088a:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80088c:	39 ca                	cmp    %ecx,%edx
  80088e:	74 16                	je     8008a6 <strnlen+0x34>
  800890:	42                   	inc    %edx
  800891:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800896:	75 f2                	jne    80088a <strnlen+0x18>
  800898:	eb 0c                	jmp    8008a6 <strnlen+0x34>
  80089a:	b8 00 00 00 00       	mov    $0x0,%eax
  80089f:	eb 05                	jmp    8008a6 <strnlen+0x34>
  8008a1:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8008a6:	5b                   	pop    %ebx
  8008a7:	5d                   	pop    %ebp
  8008a8:	c3                   	ret    

008008a9 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008a9:	55                   	push   %ebp
  8008aa:	89 e5                	mov    %esp,%ebp
  8008ac:	53                   	push   %ebx
  8008ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008b3:	89 c2                	mov    %eax,%edx
  8008b5:	42                   	inc    %edx
  8008b6:	41                   	inc    %ecx
  8008b7:	8a 59 ff             	mov    -0x1(%ecx),%bl
  8008ba:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008bd:	84 db                	test   %bl,%bl
  8008bf:	75 f4                	jne    8008b5 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8008c1:	5b                   	pop    %ebx
  8008c2:	5d                   	pop    %ebp
  8008c3:	c3                   	ret    

008008c4 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008c4:	55                   	push   %ebp
  8008c5:	89 e5                	mov    %esp,%ebp
  8008c7:	53                   	push   %ebx
  8008c8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008cb:	53                   	push   %ebx
  8008cc:	e8 81 ff ff ff       	call   800852 <strlen>
  8008d1:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8008d4:	ff 75 0c             	pushl  0xc(%ebp)
  8008d7:	01 d8                	add    %ebx,%eax
  8008d9:	50                   	push   %eax
  8008da:	e8 ca ff ff ff       	call   8008a9 <strcpy>
	return dst;
}
  8008df:	89 d8                	mov    %ebx,%eax
  8008e1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008e4:	c9                   	leave  
  8008e5:	c3                   	ret    

008008e6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008e6:	55                   	push   %ebp
  8008e7:	89 e5                	mov    %esp,%ebp
  8008e9:	56                   	push   %esi
  8008ea:	53                   	push   %ebx
  8008eb:	8b 75 08             	mov    0x8(%ebp),%esi
  8008ee:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008f1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008f4:	85 db                	test   %ebx,%ebx
  8008f6:	74 14                	je     80090c <strncpy+0x26>
  8008f8:	01 f3                	add    %esi,%ebx
  8008fa:	89 f1                	mov    %esi,%ecx
		*dst++ = *src;
  8008fc:	41                   	inc    %ecx
  8008fd:	8a 02                	mov    (%edx),%al
  8008ff:	88 41 ff             	mov    %al,-0x1(%ecx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800902:	80 3a 01             	cmpb   $0x1,(%edx)
  800905:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800908:	39 cb                	cmp    %ecx,%ebx
  80090a:	75 f0                	jne    8008fc <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80090c:	89 f0                	mov    %esi,%eax
  80090e:	5b                   	pop    %ebx
  80090f:	5e                   	pop    %esi
  800910:	5d                   	pop    %ebp
  800911:	c3                   	ret    

00800912 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800912:	55                   	push   %ebp
  800913:	89 e5                	mov    %esp,%ebp
  800915:	53                   	push   %ebx
  800916:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800919:	8b 45 10             	mov    0x10(%ebp),%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80091c:	85 c0                	test   %eax,%eax
  80091e:	74 30                	je     800950 <strlcpy+0x3e>
		while (--size > 0 && *src != '\0')
  800920:	48                   	dec    %eax
  800921:	74 20                	je     800943 <strlcpy+0x31>
  800923:	8a 0b                	mov    (%ebx),%cl
  800925:	84 c9                	test   %cl,%cl
  800927:	74 1f                	je     800948 <strlcpy+0x36>
  800929:	8d 53 01             	lea    0x1(%ebx),%edx
  80092c:	01 c3                	add    %eax,%ebx
  80092e:	8b 45 08             	mov    0x8(%ebp),%eax
			*dst++ = *src++;
  800931:	40                   	inc    %eax
  800932:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800935:	39 da                	cmp    %ebx,%edx
  800937:	74 12                	je     80094b <strlcpy+0x39>
  800939:	42                   	inc    %edx
  80093a:	8a 4a ff             	mov    -0x1(%edx),%cl
  80093d:	84 c9                	test   %cl,%cl
  80093f:	75 f0                	jne    800931 <strlcpy+0x1f>
  800941:	eb 08                	jmp    80094b <strlcpy+0x39>
  800943:	8b 45 08             	mov    0x8(%ebp),%eax
  800946:	eb 03                	jmp    80094b <strlcpy+0x39>
  800948:	8b 45 08             	mov    0x8(%ebp),%eax
			*dst++ = *src++;
		*dst = '\0';
  80094b:	c6 00 00             	movb   $0x0,(%eax)
  80094e:	eb 03                	jmp    800953 <strlcpy+0x41>
  800950:	8b 45 08             	mov    0x8(%ebp),%eax
	}
	return dst - dst_in;
  800953:	2b 45 08             	sub    0x8(%ebp),%eax
}
  800956:	5b                   	pop    %ebx
  800957:	5d                   	pop    %ebp
  800958:	c3                   	ret    

00800959 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800959:	55                   	push   %ebp
  80095a:	89 e5                	mov    %esp,%ebp
  80095c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80095f:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800962:	8a 01                	mov    (%ecx),%al
  800964:	84 c0                	test   %al,%al
  800966:	74 10                	je     800978 <strcmp+0x1f>
  800968:	3a 02                	cmp    (%edx),%al
  80096a:	75 0c                	jne    800978 <strcmp+0x1f>
		p++, q++;
  80096c:	41                   	inc    %ecx
  80096d:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80096e:	8a 01                	mov    (%ecx),%al
  800970:	84 c0                	test   %al,%al
  800972:	74 04                	je     800978 <strcmp+0x1f>
  800974:	3a 02                	cmp    (%edx),%al
  800976:	74 f4                	je     80096c <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800978:	0f b6 c0             	movzbl %al,%eax
  80097b:	0f b6 12             	movzbl (%edx),%edx
  80097e:	29 d0                	sub    %edx,%eax
}
  800980:	5d                   	pop    %ebp
  800981:	c3                   	ret    

00800982 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800982:	55                   	push   %ebp
  800983:	89 e5                	mov    %esp,%ebp
  800985:	56                   	push   %esi
  800986:	53                   	push   %ebx
  800987:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80098a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80098d:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  800990:	85 f6                	test   %esi,%esi
  800992:	74 23                	je     8009b7 <strncmp+0x35>
  800994:	8a 03                	mov    (%ebx),%al
  800996:	84 c0                	test   %al,%al
  800998:	74 2b                	je     8009c5 <strncmp+0x43>
  80099a:	3a 02                	cmp    (%edx),%al
  80099c:	75 27                	jne    8009c5 <strncmp+0x43>
  80099e:	8d 43 01             	lea    0x1(%ebx),%eax
  8009a1:	01 de                	add    %ebx,%esi
		n--, p++, q++;
  8009a3:	89 c3                	mov    %eax,%ebx
  8009a5:	42                   	inc    %edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009a6:	39 c6                	cmp    %eax,%esi
  8009a8:	74 14                	je     8009be <strncmp+0x3c>
  8009aa:	8a 08                	mov    (%eax),%cl
  8009ac:	84 c9                	test   %cl,%cl
  8009ae:	74 15                	je     8009c5 <strncmp+0x43>
  8009b0:	40                   	inc    %eax
  8009b1:	3a 0a                	cmp    (%edx),%cl
  8009b3:	74 ee                	je     8009a3 <strncmp+0x21>
  8009b5:	eb 0e                	jmp    8009c5 <strncmp+0x43>
		n--, p++, q++;
	if (n == 0)
		return 0;
  8009b7:	b8 00 00 00 00       	mov    $0x0,%eax
  8009bc:	eb 0f                	jmp    8009cd <strncmp+0x4b>
  8009be:	b8 00 00 00 00       	mov    $0x0,%eax
  8009c3:	eb 08                	jmp    8009cd <strncmp+0x4b>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009c5:	0f b6 03             	movzbl (%ebx),%eax
  8009c8:	0f b6 12             	movzbl (%edx),%edx
  8009cb:	29 d0                	sub    %edx,%eax
}
  8009cd:	5b                   	pop    %ebx
  8009ce:	5e                   	pop    %esi
  8009cf:	5d                   	pop    %ebp
  8009d0:	c3                   	ret    

008009d1 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009d1:	55                   	push   %ebp
  8009d2:	89 e5                	mov    %esp,%ebp
  8009d4:	53                   	push   %ebx
  8009d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  8009db:	8a 10                	mov    (%eax),%dl
  8009dd:	84 d2                	test   %dl,%dl
  8009df:	74 1a                	je     8009fb <strchr+0x2a>
  8009e1:	88 d9                	mov    %bl,%cl
		if (*s == c)
  8009e3:	38 d3                	cmp    %dl,%bl
  8009e5:	75 06                	jne    8009ed <strchr+0x1c>
  8009e7:	eb 17                	jmp    800a00 <strchr+0x2f>
  8009e9:	38 ca                	cmp    %cl,%dl
  8009eb:	74 13                	je     800a00 <strchr+0x2f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009ed:	40                   	inc    %eax
  8009ee:	8a 10                	mov    (%eax),%dl
  8009f0:	84 d2                	test   %dl,%dl
  8009f2:	75 f5                	jne    8009e9 <strchr+0x18>
		if (*s == c)
			return (char *) s;
	return 0;
  8009f4:	b8 00 00 00 00       	mov    $0x0,%eax
  8009f9:	eb 05                	jmp    800a00 <strchr+0x2f>
  8009fb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a00:	5b                   	pop    %ebx
  800a01:	5d                   	pop    %ebp
  800a02:	c3                   	ret    

00800a03 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a03:	55                   	push   %ebp
  800a04:	89 e5                	mov    %esp,%ebp
  800a06:	53                   	push   %ebx
  800a07:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  800a0d:	8a 10                	mov    (%eax),%dl
  800a0f:	84 d2                	test   %dl,%dl
  800a11:	74 13                	je     800a26 <strfind+0x23>
  800a13:	88 d9                	mov    %bl,%cl
		if (*s == c)
  800a15:	38 d3                	cmp    %dl,%bl
  800a17:	75 06                	jne    800a1f <strfind+0x1c>
  800a19:	eb 0b                	jmp    800a26 <strfind+0x23>
  800a1b:	38 ca                	cmp    %cl,%dl
  800a1d:	74 07                	je     800a26 <strfind+0x23>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a1f:	40                   	inc    %eax
  800a20:	8a 10                	mov    (%eax),%dl
  800a22:	84 d2                	test   %dl,%dl
  800a24:	75 f5                	jne    800a1b <strfind+0x18>
		if (*s == c)
			break;
	return (char *) s;
}
  800a26:	5b                   	pop    %ebx
  800a27:	5d                   	pop    %ebp
  800a28:	c3                   	ret    

00800a29 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a29:	55                   	push   %ebp
  800a2a:	89 e5                	mov    %esp,%ebp
  800a2c:	57                   	push   %edi
  800a2d:	56                   	push   %esi
  800a2e:	53                   	push   %ebx
  800a2f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a32:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a35:	85 c9                	test   %ecx,%ecx
  800a37:	74 36                	je     800a6f <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a39:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a3f:	75 28                	jne    800a69 <memset+0x40>
  800a41:	f6 c1 03             	test   $0x3,%cl
  800a44:	75 23                	jne    800a69 <memset+0x40>
		c &= 0xFF;
  800a46:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a4a:	89 d3                	mov    %edx,%ebx
  800a4c:	c1 e3 08             	shl    $0x8,%ebx
  800a4f:	89 d6                	mov    %edx,%esi
  800a51:	c1 e6 18             	shl    $0x18,%esi
  800a54:	89 d0                	mov    %edx,%eax
  800a56:	c1 e0 10             	shl    $0x10,%eax
  800a59:	09 f0                	or     %esi,%eax
  800a5b:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800a5d:	89 d8                	mov    %ebx,%eax
  800a5f:	09 d0                	or     %edx,%eax
  800a61:	c1 e9 02             	shr    $0x2,%ecx
  800a64:	fc                   	cld    
  800a65:	f3 ab                	rep stos %eax,%es:(%edi)
  800a67:	eb 06                	jmp    800a6f <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a69:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a6c:	fc                   	cld    
  800a6d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a6f:	89 f8                	mov    %edi,%eax
  800a71:	5b                   	pop    %ebx
  800a72:	5e                   	pop    %esi
  800a73:	5f                   	pop    %edi
  800a74:	5d                   	pop    %ebp
  800a75:	c3                   	ret    

00800a76 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a76:	55                   	push   %ebp
  800a77:	89 e5                	mov    %esp,%ebp
  800a79:	57                   	push   %edi
  800a7a:	56                   	push   %esi
  800a7b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a7e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a81:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a84:	39 c6                	cmp    %eax,%esi
  800a86:	73 33                	jae    800abb <memmove+0x45>
  800a88:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a8b:	39 d0                	cmp    %edx,%eax
  800a8d:	73 2c                	jae    800abb <memmove+0x45>
		s += n;
		d += n;
  800a8f:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a92:	89 d6                	mov    %edx,%esi
  800a94:	09 fe                	or     %edi,%esi
  800a96:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a9c:	75 13                	jne    800ab1 <memmove+0x3b>
  800a9e:	f6 c1 03             	test   $0x3,%cl
  800aa1:	75 0e                	jne    800ab1 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800aa3:	83 ef 04             	sub    $0x4,%edi
  800aa6:	8d 72 fc             	lea    -0x4(%edx),%esi
  800aa9:	c1 e9 02             	shr    $0x2,%ecx
  800aac:	fd                   	std    
  800aad:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800aaf:	eb 07                	jmp    800ab8 <memmove+0x42>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800ab1:	4f                   	dec    %edi
  800ab2:	8d 72 ff             	lea    -0x1(%edx),%esi
  800ab5:	fd                   	std    
  800ab6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ab8:	fc                   	cld    
  800ab9:	eb 1d                	jmp    800ad8 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800abb:	89 f2                	mov    %esi,%edx
  800abd:	09 c2                	or     %eax,%edx
  800abf:	f6 c2 03             	test   $0x3,%dl
  800ac2:	75 0f                	jne    800ad3 <memmove+0x5d>
  800ac4:	f6 c1 03             	test   $0x3,%cl
  800ac7:	75 0a                	jne    800ad3 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
  800ac9:	c1 e9 02             	shr    $0x2,%ecx
  800acc:	89 c7                	mov    %eax,%edi
  800ace:	fc                   	cld    
  800acf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ad1:	eb 05                	jmp    800ad8 <memmove+0x62>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800ad3:	89 c7                	mov    %eax,%edi
  800ad5:	fc                   	cld    
  800ad6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ad8:	5e                   	pop    %esi
  800ad9:	5f                   	pop    %edi
  800ada:	5d                   	pop    %ebp
  800adb:	c3                   	ret    

00800adc <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800adc:	55                   	push   %ebp
  800add:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800adf:	ff 75 10             	pushl  0x10(%ebp)
  800ae2:	ff 75 0c             	pushl  0xc(%ebp)
  800ae5:	ff 75 08             	pushl  0x8(%ebp)
  800ae8:	e8 89 ff ff ff       	call   800a76 <memmove>
}
  800aed:	c9                   	leave  
  800aee:	c3                   	ret    

00800aef <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800aef:	55                   	push   %ebp
  800af0:	89 e5                	mov    %esp,%ebp
  800af2:	57                   	push   %edi
  800af3:	56                   	push   %esi
  800af4:	53                   	push   %ebx
  800af5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800af8:	8b 75 0c             	mov    0xc(%ebp),%esi
  800afb:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800afe:	85 c0                	test   %eax,%eax
  800b00:	74 33                	je     800b35 <memcmp+0x46>
  800b02:	8d 78 ff             	lea    -0x1(%eax),%edi
		if (*s1 != *s2)
  800b05:	8a 13                	mov    (%ebx),%dl
  800b07:	8a 0e                	mov    (%esi),%cl
  800b09:	38 ca                	cmp    %cl,%dl
  800b0b:	75 13                	jne    800b20 <memcmp+0x31>
  800b0d:	b8 00 00 00 00       	mov    $0x0,%eax
  800b12:	eb 16                	jmp    800b2a <memcmp+0x3b>
  800b14:	8a 54 03 01          	mov    0x1(%ebx,%eax,1),%dl
  800b18:	40                   	inc    %eax
  800b19:	8a 0c 06             	mov    (%esi,%eax,1),%cl
  800b1c:	38 ca                	cmp    %cl,%dl
  800b1e:	74 0a                	je     800b2a <memcmp+0x3b>
			return (int) *s1 - (int) *s2;
  800b20:	0f b6 c2             	movzbl %dl,%eax
  800b23:	0f b6 c9             	movzbl %cl,%ecx
  800b26:	29 c8                	sub    %ecx,%eax
  800b28:	eb 10                	jmp    800b3a <memcmp+0x4b>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b2a:	39 f8                	cmp    %edi,%eax
  800b2c:	75 e6                	jne    800b14 <memcmp+0x25>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b2e:	b8 00 00 00 00       	mov    $0x0,%eax
  800b33:	eb 05                	jmp    800b3a <memcmp+0x4b>
  800b35:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b3a:	5b                   	pop    %ebx
  800b3b:	5e                   	pop    %esi
  800b3c:	5f                   	pop    %edi
  800b3d:	5d                   	pop    %ebp
  800b3e:	c3                   	ret    

00800b3f <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b3f:	55                   	push   %ebp
  800b40:	89 e5                	mov    %esp,%ebp
  800b42:	53                   	push   %ebx
  800b43:	8b 55 08             	mov    0x8(%ebp),%edx
	const void *ends = (const char *) s + n;
  800b46:	89 d0                	mov    %edx,%eax
  800b48:	03 45 10             	add    0x10(%ebp),%eax
	for (; s < ends; s++)
  800b4b:	39 c2                	cmp    %eax,%edx
  800b4d:	73 1b                	jae    800b6a <memfind+0x2b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b4f:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
  800b53:	0f b6 0a             	movzbl (%edx),%ecx
  800b56:	39 d9                	cmp    %ebx,%ecx
  800b58:	75 09                	jne    800b63 <memfind+0x24>
  800b5a:	eb 12                	jmp    800b6e <memfind+0x2f>
  800b5c:	0f b6 0a             	movzbl (%edx),%ecx
  800b5f:	39 d9                	cmp    %ebx,%ecx
  800b61:	74 0f                	je     800b72 <memfind+0x33>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b63:	42                   	inc    %edx
  800b64:	39 d0                	cmp    %edx,%eax
  800b66:	75 f4                	jne    800b5c <memfind+0x1d>
  800b68:	eb 0a                	jmp    800b74 <memfind+0x35>
  800b6a:	89 d0                	mov    %edx,%eax
  800b6c:	eb 06                	jmp    800b74 <memfind+0x35>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b6e:	89 d0                	mov    %edx,%eax
  800b70:	eb 02                	jmp    800b74 <memfind+0x35>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b72:	89 d0                	mov    %edx,%eax
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b74:	5b                   	pop    %ebx
  800b75:	5d                   	pop    %ebp
  800b76:	c3                   	ret    

00800b77 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b77:	55                   	push   %ebp
  800b78:	89 e5                	mov    %esp,%ebp
  800b7a:	57                   	push   %edi
  800b7b:	56                   	push   %esi
  800b7c:	53                   	push   %ebx
  800b7d:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b80:	eb 01                	jmp    800b83 <strtol+0xc>
		s++;
  800b82:	41                   	inc    %ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b83:	8a 01                	mov    (%ecx),%al
  800b85:	3c 20                	cmp    $0x20,%al
  800b87:	74 f9                	je     800b82 <strtol+0xb>
  800b89:	3c 09                	cmp    $0x9,%al
  800b8b:	74 f5                	je     800b82 <strtol+0xb>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b8d:	3c 2b                	cmp    $0x2b,%al
  800b8f:	75 08                	jne    800b99 <strtol+0x22>
		s++;
  800b91:	41                   	inc    %ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b92:	bf 00 00 00 00       	mov    $0x0,%edi
  800b97:	eb 11                	jmp    800baa <strtol+0x33>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b99:	3c 2d                	cmp    $0x2d,%al
  800b9b:	75 08                	jne    800ba5 <strtol+0x2e>
		s++, neg = 1;
  800b9d:	41                   	inc    %ecx
  800b9e:	bf 01 00 00 00       	mov    $0x1,%edi
  800ba3:	eb 05                	jmp    800baa <strtol+0x33>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ba5:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800baa:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800bae:	0f 84 87 00 00 00    	je     800c3b <strtol+0xc4>
  800bb4:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  800bb8:	75 27                	jne    800be1 <strtol+0x6a>
  800bba:	80 39 30             	cmpb   $0x30,(%ecx)
  800bbd:	75 22                	jne    800be1 <strtol+0x6a>
  800bbf:	e9 88 00 00 00       	jmp    800c4c <strtol+0xd5>
		s += 2, base = 16;
  800bc4:	83 c1 02             	add    $0x2,%ecx
  800bc7:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  800bce:	eb 11                	jmp    800be1 <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
  800bd0:	41                   	inc    %ecx
  800bd1:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  800bd8:	eb 07                	jmp    800be1 <strtol+0x6a>
	else if (base == 0)
		base = 10;
  800bda:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)
  800be1:	b8 00 00 00 00       	mov    $0x0,%eax

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800be6:	8a 11                	mov    (%ecx),%dl
  800be8:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800beb:	80 fb 09             	cmp    $0x9,%bl
  800bee:	77 08                	ja     800bf8 <strtol+0x81>
			dig = *s - '0';
  800bf0:	0f be d2             	movsbl %dl,%edx
  800bf3:	83 ea 30             	sub    $0x30,%edx
  800bf6:	eb 22                	jmp    800c1a <strtol+0xa3>
		else if (*s >= 'a' && *s <= 'z')
  800bf8:	8d 72 9f             	lea    -0x61(%edx),%esi
  800bfb:	89 f3                	mov    %esi,%ebx
  800bfd:	80 fb 19             	cmp    $0x19,%bl
  800c00:	77 08                	ja     800c0a <strtol+0x93>
			dig = *s - 'a' + 10;
  800c02:	0f be d2             	movsbl %dl,%edx
  800c05:	83 ea 57             	sub    $0x57,%edx
  800c08:	eb 10                	jmp    800c1a <strtol+0xa3>
		else if (*s >= 'A' && *s <= 'Z')
  800c0a:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c0d:	89 f3                	mov    %esi,%ebx
  800c0f:	80 fb 19             	cmp    $0x19,%bl
  800c12:	77 14                	ja     800c28 <strtol+0xb1>
			dig = *s - 'A' + 10;
  800c14:	0f be d2             	movsbl %dl,%edx
  800c17:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800c1a:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c1d:	7d 09                	jge    800c28 <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800c1f:	41                   	inc    %ecx
  800c20:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c24:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800c26:	eb be                	jmp    800be6 <strtol+0x6f>

	if (endptr)
  800c28:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c2c:	74 05                	je     800c33 <strtol+0xbc>
		*endptr = (char *) s;
  800c2e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c31:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800c33:	85 ff                	test   %edi,%edi
  800c35:	74 21                	je     800c58 <strtol+0xe1>
  800c37:	f7 d8                	neg    %eax
  800c39:	eb 1d                	jmp    800c58 <strtol+0xe1>
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c3b:	80 39 30             	cmpb   $0x30,(%ecx)
  800c3e:	75 9a                	jne    800bda <strtol+0x63>
  800c40:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c44:	0f 84 7a ff ff ff    	je     800bc4 <strtol+0x4d>
  800c4a:	eb 84                	jmp    800bd0 <strtol+0x59>
  800c4c:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c50:	0f 84 6e ff ff ff    	je     800bc4 <strtol+0x4d>
  800c56:	eb 89                	jmp    800be1 <strtol+0x6a>
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
}
  800c58:	5b                   	pop    %ebx
  800c59:	5e                   	pop    %esi
  800c5a:	5f                   	pop    %edi
  800c5b:	5d                   	pop    %ebp
  800c5c:	c3                   	ret    

00800c5d <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c5d:	55                   	push   %ebp
  800c5e:	89 e5                	mov    %esp,%ebp
  800c60:	57                   	push   %edi
  800c61:	56                   	push   %esi
  800c62:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c63:	b8 00 00 00 00       	mov    $0x0,%eax
  800c68:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c6b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c6e:	89 c3                	mov    %eax,%ebx
  800c70:	89 c7                	mov    %eax,%edi
  800c72:	89 c6                	mov    %eax,%esi
  800c74:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c76:	5b                   	pop    %ebx
  800c77:	5e                   	pop    %esi
  800c78:	5f                   	pop    %edi
  800c79:	5d                   	pop    %ebp
  800c7a:	c3                   	ret    

00800c7b <sys_cgetc>:

int
sys_cgetc(void)
{
  800c7b:	55                   	push   %ebp
  800c7c:	89 e5                	mov    %esp,%ebp
  800c7e:	57                   	push   %edi
  800c7f:	56                   	push   %esi
  800c80:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c81:	ba 00 00 00 00       	mov    $0x0,%edx
  800c86:	b8 01 00 00 00       	mov    $0x1,%eax
  800c8b:	89 d1                	mov    %edx,%ecx
  800c8d:	89 d3                	mov    %edx,%ebx
  800c8f:	89 d7                	mov    %edx,%edi
  800c91:	89 d6                	mov    %edx,%esi
  800c93:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c95:	5b                   	pop    %ebx
  800c96:	5e                   	pop    %esi
  800c97:	5f                   	pop    %edi
  800c98:	5d                   	pop    %ebp
  800c99:	c3                   	ret    

00800c9a <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c9a:	55                   	push   %ebp
  800c9b:	89 e5                	mov    %esp,%ebp
  800c9d:	57                   	push   %edi
  800c9e:	56                   	push   %esi
  800c9f:	53                   	push   %ebx
  800ca0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca3:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ca8:	b8 03 00 00 00       	mov    $0x3,%eax
  800cad:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb0:	89 cb                	mov    %ecx,%ebx
  800cb2:	89 cf                	mov    %ecx,%edi
  800cb4:	89 ce                	mov    %ecx,%esi
  800cb6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cb8:	85 c0                	test   %eax,%eax
  800cba:	7e 17                	jle    800cd3 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cbc:	83 ec 0c             	sub    $0xc,%esp
  800cbf:	50                   	push   %eax
  800cc0:	6a 03                	push   $0x3
  800cc2:	68 1f 24 80 00       	push   $0x80241f
  800cc7:	6a 23                	push   $0x23
  800cc9:	68 3c 24 80 00       	push   $0x80243c
  800cce:	e8 19 f5 ff ff       	call   8001ec <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800cd3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cd6:	5b                   	pop    %ebx
  800cd7:	5e                   	pop    %esi
  800cd8:	5f                   	pop    %edi
  800cd9:	5d                   	pop    %ebp
  800cda:	c3                   	ret    

00800cdb <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800cdb:	55                   	push   %ebp
  800cdc:	89 e5                	mov    %esp,%ebp
  800cde:	57                   	push   %edi
  800cdf:	56                   	push   %esi
  800ce0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce1:	ba 00 00 00 00       	mov    $0x0,%edx
  800ce6:	b8 02 00 00 00       	mov    $0x2,%eax
  800ceb:	89 d1                	mov    %edx,%ecx
  800ced:	89 d3                	mov    %edx,%ebx
  800cef:	89 d7                	mov    %edx,%edi
  800cf1:	89 d6                	mov    %edx,%esi
  800cf3:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800cf5:	5b                   	pop    %ebx
  800cf6:	5e                   	pop    %esi
  800cf7:	5f                   	pop    %edi
  800cf8:	5d                   	pop    %ebp
  800cf9:	c3                   	ret    

00800cfa <sys_yield>:

void
sys_yield(void)
{
  800cfa:	55                   	push   %ebp
  800cfb:	89 e5                	mov    %esp,%ebp
  800cfd:	57                   	push   %edi
  800cfe:	56                   	push   %esi
  800cff:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d00:	ba 00 00 00 00       	mov    $0x0,%edx
  800d05:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d0a:	89 d1                	mov    %edx,%ecx
  800d0c:	89 d3                	mov    %edx,%ebx
  800d0e:	89 d7                	mov    %edx,%edi
  800d10:	89 d6                	mov    %edx,%esi
  800d12:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d14:	5b                   	pop    %ebx
  800d15:	5e                   	pop    %esi
  800d16:	5f                   	pop    %edi
  800d17:	5d                   	pop    %ebp
  800d18:	c3                   	ret    

00800d19 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d19:	55                   	push   %ebp
  800d1a:	89 e5                	mov    %esp,%ebp
  800d1c:	57                   	push   %edi
  800d1d:	56                   	push   %esi
  800d1e:	53                   	push   %ebx
  800d1f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d22:	be 00 00 00 00       	mov    $0x0,%esi
  800d27:	b8 04 00 00 00       	mov    $0x4,%eax
  800d2c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d2f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d32:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d35:	89 f7                	mov    %esi,%edi
  800d37:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d39:	85 c0                	test   %eax,%eax
  800d3b:	7e 17                	jle    800d54 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d3d:	83 ec 0c             	sub    $0xc,%esp
  800d40:	50                   	push   %eax
  800d41:	6a 04                	push   $0x4
  800d43:	68 1f 24 80 00       	push   $0x80241f
  800d48:	6a 23                	push   $0x23
  800d4a:	68 3c 24 80 00       	push   $0x80243c
  800d4f:	e8 98 f4 ff ff       	call   8001ec <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d54:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d57:	5b                   	pop    %ebx
  800d58:	5e                   	pop    %esi
  800d59:	5f                   	pop    %edi
  800d5a:	5d                   	pop    %ebp
  800d5b:	c3                   	ret    

00800d5c <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
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
  800d65:	b8 05 00 00 00       	mov    $0x5,%eax
  800d6a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d6d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d70:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d73:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d76:	8b 75 18             	mov    0x18(%ebp),%esi
  800d79:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d7b:	85 c0                	test   %eax,%eax
  800d7d:	7e 17                	jle    800d96 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d7f:	83 ec 0c             	sub    $0xc,%esp
  800d82:	50                   	push   %eax
  800d83:	6a 05                	push   $0x5
  800d85:	68 1f 24 80 00       	push   $0x80241f
  800d8a:	6a 23                	push   $0x23
  800d8c:	68 3c 24 80 00       	push   $0x80243c
  800d91:	e8 56 f4 ff ff       	call   8001ec <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d96:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d99:	5b                   	pop    %ebx
  800d9a:	5e                   	pop    %esi
  800d9b:	5f                   	pop    %edi
  800d9c:	5d                   	pop    %ebp
  800d9d:	c3                   	ret    

00800d9e <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d9e:	55                   	push   %ebp
  800d9f:	89 e5                	mov    %esp,%ebp
  800da1:	57                   	push   %edi
  800da2:	56                   	push   %esi
  800da3:	53                   	push   %ebx
  800da4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800da7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dac:	b8 06 00 00 00       	mov    $0x6,%eax
  800db1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db4:	8b 55 08             	mov    0x8(%ebp),%edx
  800db7:	89 df                	mov    %ebx,%edi
  800db9:	89 de                	mov    %ebx,%esi
  800dbb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dbd:	85 c0                	test   %eax,%eax
  800dbf:	7e 17                	jle    800dd8 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dc1:	83 ec 0c             	sub    $0xc,%esp
  800dc4:	50                   	push   %eax
  800dc5:	6a 06                	push   $0x6
  800dc7:	68 1f 24 80 00       	push   $0x80241f
  800dcc:	6a 23                	push   $0x23
  800dce:	68 3c 24 80 00       	push   $0x80243c
  800dd3:	e8 14 f4 ff ff       	call   8001ec <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800dd8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ddb:	5b                   	pop    %ebx
  800ddc:	5e                   	pop    %esi
  800ddd:	5f                   	pop    %edi
  800dde:	5d                   	pop    %ebp
  800ddf:	c3                   	ret    

00800de0 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800de0:	55                   	push   %ebp
  800de1:	89 e5                	mov    %esp,%ebp
  800de3:	57                   	push   %edi
  800de4:	56                   	push   %esi
  800de5:	53                   	push   %ebx
  800de6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800de9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dee:	b8 08 00 00 00       	mov    $0x8,%eax
  800df3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800df6:	8b 55 08             	mov    0x8(%ebp),%edx
  800df9:	89 df                	mov    %ebx,%edi
  800dfb:	89 de                	mov    %ebx,%esi
  800dfd:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dff:	85 c0                	test   %eax,%eax
  800e01:	7e 17                	jle    800e1a <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e03:	83 ec 0c             	sub    $0xc,%esp
  800e06:	50                   	push   %eax
  800e07:	6a 08                	push   $0x8
  800e09:	68 1f 24 80 00       	push   $0x80241f
  800e0e:	6a 23                	push   $0x23
  800e10:	68 3c 24 80 00       	push   $0x80243c
  800e15:	e8 d2 f3 ff ff       	call   8001ec <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e1a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e1d:	5b                   	pop    %ebx
  800e1e:	5e                   	pop    %esi
  800e1f:	5f                   	pop    %edi
  800e20:	5d                   	pop    %ebp
  800e21:	c3                   	ret    

00800e22 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e22:	55                   	push   %ebp
  800e23:	89 e5                	mov    %esp,%ebp
  800e25:	57                   	push   %edi
  800e26:	56                   	push   %esi
  800e27:	53                   	push   %ebx
  800e28:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e2b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e30:	b8 09 00 00 00       	mov    $0x9,%eax
  800e35:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e38:	8b 55 08             	mov    0x8(%ebp),%edx
  800e3b:	89 df                	mov    %ebx,%edi
  800e3d:	89 de                	mov    %ebx,%esi
  800e3f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e41:	85 c0                	test   %eax,%eax
  800e43:	7e 17                	jle    800e5c <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e45:	83 ec 0c             	sub    $0xc,%esp
  800e48:	50                   	push   %eax
  800e49:	6a 09                	push   $0x9
  800e4b:	68 1f 24 80 00       	push   $0x80241f
  800e50:	6a 23                	push   $0x23
  800e52:	68 3c 24 80 00       	push   $0x80243c
  800e57:	e8 90 f3 ff ff       	call   8001ec <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e5c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e5f:	5b                   	pop    %ebx
  800e60:	5e                   	pop    %esi
  800e61:	5f                   	pop    %edi
  800e62:	5d                   	pop    %ebp
  800e63:	c3                   	ret    

00800e64 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e64:	55                   	push   %ebp
  800e65:	89 e5                	mov    %esp,%ebp
  800e67:	57                   	push   %edi
  800e68:	56                   	push   %esi
  800e69:	53                   	push   %ebx
  800e6a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e6d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e72:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e77:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e7a:	8b 55 08             	mov    0x8(%ebp),%edx
  800e7d:	89 df                	mov    %ebx,%edi
  800e7f:	89 de                	mov    %ebx,%esi
  800e81:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e83:	85 c0                	test   %eax,%eax
  800e85:	7e 17                	jle    800e9e <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e87:	83 ec 0c             	sub    $0xc,%esp
  800e8a:	50                   	push   %eax
  800e8b:	6a 0a                	push   $0xa
  800e8d:	68 1f 24 80 00       	push   $0x80241f
  800e92:	6a 23                	push   $0x23
  800e94:	68 3c 24 80 00       	push   $0x80243c
  800e99:	e8 4e f3 ff ff       	call   8001ec <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e9e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ea1:	5b                   	pop    %ebx
  800ea2:	5e                   	pop    %esi
  800ea3:	5f                   	pop    %edi
  800ea4:	5d                   	pop    %ebp
  800ea5:	c3                   	ret    

00800ea6 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ea6:	55                   	push   %ebp
  800ea7:	89 e5                	mov    %esp,%ebp
  800ea9:	57                   	push   %edi
  800eaa:	56                   	push   %esi
  800eab:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eac:	be 00 00 00 00       	mov    $0x0,%esi
  800eb1:	b8 0c 00 00 00       	mov    $0xc,%eax
  800eb6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eb9:	8b 55 08             	mov    0x8(%ebp),%edx
  800ebc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ebf:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ec2:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ec4:	5b                   	pop    %ebx
  800ec5:	5e                   	pop    %esi
  800ec6:	5f                   	pop    %edi
  800ec7:	5d                   	pop    %ebp
  800ec8:	c3                   	ret    

00800ec9 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ec9:	55                   	push   %ebp
  800eca:	89 e5                	mov    %esp,%ebp
  800ecc:	57                   	push   %edi
  800ecd:	56                   	push   %esi
  800ece:	53                   	push   %ebx
  800ecf:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ed2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ed7:	b8 0d 00 00 00       	mov    $0xd,%eax
  800edc:	8b 55 08             	mov    0x8(%ebp),%edx
  800edf:	89 cb                	mov    %ecx,%ebx
  800ee1:	89 cf                	mov    %ecx,%edi
  800ee3:	89 ce                	mov    %ecx,%esi
  800ee5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ee7:	85 c0                	test   %eax,%eax
  800ee9:	7e 17                	jle    800f02 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800eeb:	83 ec 0c             	sub    $0xc,%esp
  800eee:	50                   	push   %eax
  800eef:	6a 0d                	push   $0xd
  800ef1:	68 1f 24 80 00       	push   $0x80241f
  800ef6:	6a 23                	push   $0x23
  800ef8:	68 3c 24 80 00       	push   $0x80243c
  800efd:	e8 ea f2 ff ff       	call   8001ec <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f02:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f05:	5b                   	pop    %ebx
  800f06:	5e                   	pop    %esi
  800f07:	5f                   	pop    %edi
  800f08:	5d                   	pop    %ebp
  800f09:	c3                   	ret    

00800f0a <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800f0a:	55                   	push   %ebp
  800f0b:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800f0d:	8b 45 08             	mov    0x8(%ebp),%eax
  800f10:	05 00 00 00 30       	add    $0x30000000,%eax
  800f15:	c1 e8 0c             	shr    $0xc,%eax
}
  800f18:	5d                   	pop    %ebp
  800f19:	c3                   	ret    

00800f1a <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800f1a:	55                   	push   %ebp
  800f1b:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800f1d:	8b 45 08             	mov    0x8(%ebp),%eax
  800f20:	05 00 00 00 30       	add    $0x30000000,%eax
  800f25:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800f2a:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800f2f:	5d                   	pop    %ebp
  800f30:	c3                   	ret    

00800f31 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800f31:	55                   	push   %ebp
  800f32:	89 e5                	mov    %esp,%ebp
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800f34:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  800f39:	a8 01                	test   $0x1,%al
  800f3b:	74 34                	je     800f71 <fd_alloc+0x40>
  800f3d:	a1 00 00 74 ef       	mov    0xef740000,%eax
  800f42:	a8 01                	test   $0x1,%al
  800f44:	74 32                	je     800f78 <fd_alloc+0x47>
  800f46:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800f4b:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800f4d:	89 c2                	mov    %eax,%edx
  800f4f:	c1 ea 16             	shr    $0x16,%edx
  800f52:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f59:	f6 c2 01             	test   $0x1,%dl
  800f5c:	74 1f                	je     800f7d <fd_alloc+0x4c>
  800f5e:	89 c2                	mov    %eax,%edx
  800f60:	c1 ea 0c             	shr    $0xc,%edx
  800f63:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f6a:	f6 c2 01             	test   $0x1,%dl
  800f6d:	75 1a                	jne    800f89 <fd_alloc+0x58>
  800f6f:	eb 0c                	jmp    800f7d <fd_alloc+0x4c>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800f71:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  800f76:	eb 05                	jmp    800f7d <fd_alloc+0x4c>
  800f78:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  800f7d:	8b 45 08             	mov    0x8(%ebp),%eax
  800f80:	89 08                	mov    %ecx,(%eax)
			return 0;
  800f82:	b8 00 00 00 00       	mov    $0x0,%eax
  800f87:	eb 1a                	jmp    800fa3 <fd_alloc+0x72>
  800f89:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800f8e:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800f93:	75 b6                	jne    800f4b <fd_alloc+0x1a>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800f95:	8b 45 08             	mov    0x8(%ebp),%eax
  800f98:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  800f9e:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800fa3:	5d                   	pop    %ebp
  800fa4:	c3                   	ret    

00800fa5 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800fa5:	55                   	push   %ebp
  800fa6:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800fa8:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
  800fac:	77 39                	ja     800fe7 <fd_lookup+0x42>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800fae:	8b 45 08             	mov    0x8(%ebp),%eax
  800fb1:	c1 e0 0c             	shl    $0xc,%eax
  800fb4:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800fb9:	89 c2                	mov    %eax,%edx
  800fbb:	c1 ea 16             	shr    $0x16,%edx
  800fbe:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800fc5:	f6 c2 01             	test   $0x1,%dl
  800fc8:	74 24                	je     800fee <fd_lookup+0x49>
  800fca:	89 c2                	mov    %eax,%edx
  800fcc:	c1 ea 0c             	shr    $0xc,%edx
  800fcf:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800fd6:	f6 c2 01             	test   $0x1,%dl
  800fd9:	74 1a                	je     800ff5 <fd_lookup+0x50>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800fdb:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fde:	89 02                	mov    %eax,(%edx)
	return 0;
  800fe0:	b8 00 00 00 00       	mov    $0x0,%eax
  800fe5:	eb 13                	jmp    800ffa <fd_lookup+0x55>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800fe7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800fec:	eb 0c                	jmp    800ffa <fd_lookup+0x55>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800fee:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ff3:	eb 05                	jmp    800ffa <fd_lookup+0x55>
  800ff5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800ffa:	5d                   	pop    %ebp
  800ffb:	c3                   	ret    

00800ffc <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800ffc:	55                   	push   %ebp
  800ffd:	89 e5                	mov    %esp,%ebp
  800fff:	53                   	push   %ebx
  801000:	83 ec 04             	sub    $0x4,%esp
  801003:	8b 45 08             	mov    0x8(%ebp),%eax
  801006:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  801009:	3b 05 08 30 80 00    	cmp    0x803008,%eax
  80100f:	75 1e                	jne    80102f <dev_lookup+0x33>
  801011:	eb 0e                	jmp    801021 <dev_lookup+0x25>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801013:	b8 24 30 80 00       	mov    $0x803024,%eax
  801018:	eb 0c                	jmp    801026 <dev_lookup+0x2a>
  80101a:	b8 40 30 80 00       	mov    $0x803040,%eax
  80101f:	eb 05                	jmp    801026 <dev_lookup+0x2a>
  801021:	b8 08 30 80 00       	mov    $0x803008,%eax
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  801026:	89 03                	mov    %eax,(%ebx)
			return 0;
  801028:	b8 00 00 00 00       	mov    $0x0,%eax
  80102d:	eb 36                	jmp    801065 <dev_lookup+0x69>
int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  80102f:	3b 05 24 30 80 00    	cmp    0x803024,%eax
  801035:	74 dc                	je     801013 <dev_lookup+0x17>
  801037:	3b 05 40 30 80 00    	cmp    0x803040,%eax
  80103d:	74 db                	je     80101a <dev_lookup+0x1e>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80103f:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801045:	8b 52 48             	mov    0x48(%edx),%edx
  801048:	83 ec 04             	sub    $0x4,%esp
  80104b:	50                   	push   %eax
  80104c:	52                   	push   %edx
  80104d:	68 4c 24 80 00       	push   $0x80244c
  801052:	e8 6d f2 ff ff       	call   8002c4 <cprintf>
	*dev = 0;
  801057:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  80105d:	83 c4 10             	add    $0x10,%esp
  801060:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801065:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801068:	c9                   	leave  
  801069:	c3                   	ret    

0080106a <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80106a:	55                   	push   %ebp
  80106b:	89 e5                	mov    %esp,%ebp
  80106d:	56                   	push   %esi
  80106e:	53                   	push   %ebx
  80106f:	83 ec 10             	sub    $0x10,%esp
  801072:	8b 75 08             	mov    0x8(%ebp),%esi
  801075:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801078:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80107b:	50                   	push   %eax
  80107c:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801082:	c1 e8 0c             	shr    $0xc,%eax
  801085:	50                   	push   %eax
  801086:	e8 1a ff ff ff       	call   800fa5 <fd_lookup>
  80108b:	83 c4 08             	add    $0x8,%esp
  80108e:	85 c0                	test   %eax,%eax
  801090:	78 05                	js     801097 <fd_close+0x2d>
	    || fd != fd2)
  801092:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801095:	74 06                	je     80109d <fd_close+0x33>
		return (must_exist ? r : 0);
  801097:	84 db                	test   %bl,%bl
  801099:	74 47                	je     8010e2 <fd_close+0x78>
  80109b:	eb 4a                	jmp    8010e7 <fd_close+0x7d>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80109d:	83 ec 08             	sub    $0x8,%esp
  8010a0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010a3:	50                   	push   %eax
  8010a4:	ff 36                	pushl  (%esi)
  8010a6:	e8 51 ff ff ff       	call   800ffc <dev_lookup>
  8010ab:	89 c3                	mov    %eax,%ebx
  8010ad:	83 c4 10             	add    $0x10,%esp
  8010b0:	85 c0                	test   %eax,%eax
  8010b2:	78 1c                	js     8010d0 <fd_close+0x66>
		if (dev->dev_close)
  8010b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010b7:	8b 40 10             	mov    0x10(%eax),%eax
  8010ba:	85 c0                	test   %eax,%eax
  8010bc:	74 0d                	je     8010cb <fd_close+0x61>
			r = (*dev->dev_close)(fd);
  8010be:	83 ec 0c             	sub    $0xc,%esp
  8010c1:	56                   	push   %esi
  8010c2:	ff d0                	call   *%eax
  8010c4:	89 c3                	mov    %eax,%ebx
  8010c6:	83 c4 10             	add    $0x10,%esp
  8010c9:	eb 05                	jmp    8010d0 <fd_close+0x66>
		else
			r = 0;
  8010cb:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8010d0:	83 ec 08             	sub    $0x8,%esp
  8010d3:	56                   	push   %esi
  8010d4:	6a 00                	push   $0x0
  8010d6:	e8 c3 fc ff ff       	call   800d9e <sys_page_unmap>
	return r;
  8010db:	83 c4 10             	add    $0x10,%esp
  8010de:	89 d8                	mov    %ebx,%eax
  8010e0:	eb 05                	jmp    8010e7 <fd_close+0x7d>
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
  8010e2:	b8 00 00 00 00       	mov    $0x0,%eax
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
	return r;
}
  8010e7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010ea:	5b                   	pop    %ebx
  8010eb:	5e                   	pop    %esi
  8010ec:	5d                   	pop    %ebp
  8010ed:	c3                   	ret    

008010ee <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8010ee:	55                   	push   %ebp
  8010ef:	89 e5                	mov    %esp,%ebp
  8010f1:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8010f4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010f7:	50                   	push   %eax
  8010f8:	ff 75 08             	pushl  0x8(%ebp)
  8010fb:	e8 a5 fe ff ff       	call   800fa5 <fd_lookup>
  801100:	83 c4 08             	add    $0x8,%esp
  801103:	85 c0                	test   %eax,%eax
  801105:	78 10                	js     801117 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801107:	83 ec 08             	sub    $0x8,%esp
  80110a:	6a 01                	push   $0x1
  80110c:	ff 75 f4             	pushl  -0xc(%ebp)
  80110f:	e8 56 ff ff ff       	call   80106a <fd_close>
  801114:	83 c4 10             	add    $0x10,%esp
}
  801117:	c9                   	leave  
  801118:	c3                   	ret    

00801119 <close_all>:

void
close_all(void)
{
  801119:	55                   	push   %ebp
  80111a:	89 e5                	mov    %esp,%ebp
  80111c:	53                   	push   %ebx
  80111d:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801120:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801125:	83 ec 0c             	sub    $0xc,%esp
  801128:	53                   	push   %ebx
  801129:	e8 c0 ff ff ff       	call   8010ee <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80112e:	43                   	inc    %ebx
  80112f:	83 c4 10             	add    $0x10,%esp
  801132:	83 fb 20             	cmp    $0x20,%ebx
  801135:	75 ee                	jne    801125 <close_all+0xc>
		close(i);
}
  801137:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80113a:	c9                   	leave  
  80113b:	c3                   	ret    

0080113c <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80113c:	55                   	push   %ebp
  80113d:	89 e5                	mov    %esp,%ebp
  80113f:	57                   	push   %edi
  801140:	56                   	push   %esi
  801141:	53                   	push   %ebx
  801142:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801145:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801148:	50                   	push   %eax
  801149:	ff 75 08             	pushl  0x8(%ebp)
  80114c:	e8 54 fe ff ff       	call   800fa5 <fd_lookup>
  801151:	83 c4 08             	add    $0x8,%esp
  801154:	85 c0                	test   %eax,%eax
  801156:	0f 88 c2 00 00 00    	js     80121e <dup+0xe2>
		return r;
	close(newfdnum);
  80115c:	83 ec 0c             	sub    $0xc,%esp
  80115f:	ff 75 0c             	pushl  0xc(%ebp)
  801162:	e8 87 ff ff ff       	call   8010ee <close>

	newfd = INDEX2FD(newfdnum);
  801167:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80116a:	c1 e3 0c             	shl    $0xc,%ebx
  80116d:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801173:	83 c4 04             	add    $0x4,%esp
  801176:	ff 75 e4             	pushl  -0x1c(%ebp)
  801179:	e8 9c fd ff ff       	call   800f1a <fd2data>
  80117e:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  801180:	89 1c 24             	mov    %ebx,(%esp)
  801183:	e8 92 fd ff ff       	call   800f1a <fd2data>
  801188:	83 c4 10             	add    $0x10,%esp
  80118b:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80118d:	89 f0                	mov    %esi,%eax
  80118f:	c1 e8 16             	shr    $0x16,%eax
  801192:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801199:	a8 01                	test   $0x1,%al
  80119b:	74 35                	je     8011d2 <dup+0x96>
  80119d:	89 f0                	mov    %esi,%eax
  80119f:	c1 e8 0c             	shr    $0xc,%eax
  8011a2:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8011a9:	f6 c2 01             	test   $0x1,%dl
  8011ac:	74 24                	je     8011d2 <dup+0x96>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8011ae:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8011b5:	83 ec 0c             	sub    $0xc,%esp
  8011b8:	25 07 0e 00 00       	and    $0xe07,%eax
  8011bd:	50                   	push   %eax
  8011be:	57                   	push   %edi
  8011bf:	6a 00                	push   $0x0
  8011c1:	56                   	push   %esi
  8011c2:	6a 00                	push   $0x0
  8011c4:	e8 93 fb ff ff       	call   800d5c <sys_page_map>
  8011c9:	89 c6                	mov    %eax,%esi
  8011cb:	83 c4 20             	add    $0x20,%esp
  8011ce:	85 c0                	test   %eax,%eax
  8011d0:	78 2c                	js     8011fe <dup+0xc2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8011d2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8011d5:	89 d0                	mov    %edx,%eax
  8011d7:	c1 e8 0c             	shr    $0xc,%eax
  8011da:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8011e1:	83 ec 0c             	sub    $0xc,%esp
  8011e4:	25 07 0e 00 00       	and    $0xe07,%eax
  8011e9:	50                   	push   %eax
  8011ea:	53                   	push   %ebx
  8011eb:	6a 00                	push   $0x0
  8011ed:	52                   	push   %edx
  8011ee:	6a 00                	push   $0x0
  8011f0:	e8 67 fb ff ff       	call   800d5c <sys_page_map>
  8011f5:	89 c6                	mov    %eax,%esi
  8011f7:	83 c4 20             	add    $0x20,%esp
  8011fa:	85 c0                	test   %eax,%eax
  8011fc:	79 1d                	jns    80121b <dup+0xdf>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8011fe:	83 ec 08             	sub    $0x8,%esp
  801201:	53                   	push   %ebx
  801202:	6a 00                	push   $0x0
  801204:	e8 95 fb ff ff       	call   800d9e <sys_page_unmap>
	sys_page_unmap(0, nva);
  801209:	83 c4 08             	add    $0x8,%esp
  80120c:	57                   	push   %edi
  80120d:	6a 00                	push   $0x0
  80120f:	e8 8a fb ff ff       	call   800d9e <sys_page_unmap>
	return r;
  801214:	83 c4 10             	add    $0x10,%esp
  801217:	89 f0                	mov    %esi,%eax
  801219:	eb 03                	jmp    80121e <dup+0xe2>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  80121b:	8b 45 0c             	mov    0xc(%ebp),%eax

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80121e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801221:	5b                   	pop    %ebx
  801222:	5e                   	pop    %esi
  801223:	5f                   	pop    %edi
  801224:	5d                   	pop    %ebp
  801225:	c3                   	ret    

00801226 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801226:	55                   	push   %ebp
  801227:	89 e5                	mov    %esp,%ebp
  801229:	53                   	push   %ebx
  80122a:	83 ec 14             	sub    $0x14,%esp
  80122d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801230:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801233:	50                   	push   %eax
  801234:	53                   	push   %ebx
  801235:	e8 6b fd ff ff       	call   800fa5 <fd_lookup>
  80123a:	83 c4 08             	add    $0x8,%esp
  80123d:	85 c0                	test   %eax,%eax
  80123f:	78 67                	js     8012a8 <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801241:	83 ec 08             	sub    $0x8,%esp
  801244:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801247:	50                   	push   %eax
  801248:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80124b:	ff 30                	pushl  (%eax)
  80124d:	e8 aa fd ff ff       	call   800ffc <dev_lookup>
  801252:	83 c4 10             	add    $0x10,%esp
  801255:	85 c0                	test   %eax,%eax
  801257:	78 4f                	js     8012a8 <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801259:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80125c:	8b 42 08             	mov    0x8(%edx),%eax
  80125f:	83 e0 03             	and    $0x3,%eax
  801262:	83 f8 01             	cmp    $0x1,%eax
  801265:	75 21                	jne    801288 <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801267:	a1 08 40 80 00       	mov    0x804008,%eax
  80126c:	8b 40 48             	mov    0x48(%eax),%eax
  80126f:	83 ec 04             	sub    $0x4,%esp
  801272:	53                   	push   %ebx
  801273:	50                   	push   %eax
  801274:	68 90 24 80 00       	push   $0x802490
  801279:	e8 46 f0 ff ff       	call   8002c4 <cprintf>
		return -E_INVAL;
  80127e:	83 c4 10             	add    $0x10,%esp
  801281:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801286:	eb 20                	jmp    8012a8 <read+0x82>
	}
	if (!dev->dev_read)
  801288:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80128b:	8b 40 08             	mov    0x8(%eax),%eax
  80128e:	85 c0                	test   %eax,%eax
  801290:	74 11                	je     8012a3 <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801292:	83 ec 04             	sub    $0x4,%esp
  801295:	ff 75 10             	pushl  0x10(%ebp)
  801298:	ff 75 0c             	pushl  0xc(%ebp)
  80129b:	52                   	push   %edx
  80129c:	ff d0                	call   *%eax
  80129e:	83 c4 10             	add    $0x10,%esp
  8012a1:	eb 05                	jmp    8012a8 <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8012a3:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8012a8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012ab:	c9                   	leave  
  8012ac:	c3                   	ret    

008012ad <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8012ad:	55                   	push   %ebp
  8012ae:	89 e5                	mov    %esp,%ebp
  8012b0:	57                   	push   %edi
  8012b1:	56                   	push   %esi
  8012b2:	53                   	push   %ebx
  8012b3:	83 ec 0c             	sub    $0xc,%esp
  8012b6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8012b9:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8012bc:	85 f6                	test   %esi,%esi
  8012be:	74 31                	je     8012f1 <readn+0x44>
  8012c0:	b8 00 00 00 00       	mov    $0x0,%eax
  8012c5:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  8012ca:	83 ec 04             	sub    $0x4,%esp
  8012cd:	89 f2                	mov    %esi,%edx
  8012cf:	29 c2                	sub    %eax,%edx
  8012d1:	52                   	push   %edx
  8012d2:	03 45 0c             	add    0xc(%ebp),%eax
  8012d5:	50                   	push   %eax
  8012d6:	57                   	push   %edi
  8012d7:	e8 4a ff ff ff       	call   801226 <read>
		if (m < 0)
  8012dc:	83 c4 10             	add    $0x10,%esp
  8012df:	85 c0                	test   %eax,%eax
  8012e1:	78 17                	js     8012fa <readn+0x4d>
			return m;
		if (m == 0)
  8012e3:	85 c0                	test   %eax,%eax
  8012e5:	74 11                	je     8012f8 <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8012e7:	01 c3                	add    %eax,%ebx
  8012e9:	89 d8                	mov    %ebx,%eax
  8012eb:	39 f3                	cmp    %esi,%ebx
  8012ed:	72 db                	jb     8012ca <readn+0x1d>
  8012ef:	eb 09                	jmp    8012fa <readn+0x4d>
  8012f1:	b8 00 00 00 00       	mov    $0x0,%eax
  8012f6:	eb 02                	jmp    8012fa <readn+0x4d>
  8012f8:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8012fa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012fd:	5b                   	pop    %ebx
  8012fe:	5e                   	pop    %esi
  8012ff:	5f                   	pop    %edi
  801300:	5d                   	pop    %ebp
  801301:	c3                   	ret    

00801302 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
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
  801311:	e8 8f fc ff ff       	call   800fa5 <fd_lookup>
  801316:	83 c4 08             	add    $0x8,%esp
  801319:	85 c0                	test   %eax,%eax
  80131b:	78 62                	js     80137f <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80131d:	83 ec 08             	sub    $0x8,%esp
  801320:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801323:	50                   	push   %eax
  801324:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801327:	ff 30                	pushl  (%eax)
  801329:	e8 ce fc ff ff       	call   800ffc <dev_lookup>
  80132e:	83 c4 10             	add    $0x10,%esp
  801331:	85 c0                	test   %eax,%eax
  801333:	78 4a                	js     80137f <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801335:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801338:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80133c:	75 21                	jne    80135f <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80133e:	a1 08 40 80 00       	mov    0x804008,%eax
  801343:	8b 40 48             	mov    0x48(%eax),%eax
  801346:	83 ec 04             	sub    $0x4,%esp
  801349:	53                   	push   %ebx
  80134a:	50                   	push   %eax
  80134b:	68 ac 24 80 00       	push   $0x8024ac
  801350:	e8 6f ef ff ff       	call   8002c4 <cprintf>
		return -E_INVAL;
  801355:	83 c4 10             	add    $0x10,%esp
  801358:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80135d:	eb 20                	jmp    80137f <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80135f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801362:	8b 52 0c             	mov    0xc(%edx),%edx
  801365:	85 d2                	test   %edx,%edx
  801367:	74 11                	je     80137a <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801369:	83 ec 04             	sub    $0x4,%esp
  80136c:	ff 75 10             	pushl  0x10(%ebp)
  80136f:	ff 75 0c             	pushl  0xc(%ebp)
  801372:	50                   	push   %eax
  801373:	ff d2                	call   *%edx
  801375:	83 c4 10             	add    $0x10,%esp
  801378:	eb 05                	jmp    80137f <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80137a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  80137f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801382:	c9                   	leave  
  801383:	c3                   	ret    

00801384 <seek>:

int
seek(int fdnum, off_t offset)
{
  801384:	55                   	push   %ebp
  801385:	89 e5                	mov    %esp,%ebp
  801387:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80138a:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80138d:	50                   	push   %eax
  80138e:	ff 75 08             	pushl  0x8(%ebp)
  801391:	e8 0f fc ff ff       	call   800fa5 <fd_lookup>
  801396:	83 c4 08             	add    $0x8,%esp
  801399:	85 c0                	test   %eax,%eax
  80139b:	78 0e                	js     8013ab <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80139d:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8013a0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013a3:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8013a6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013ab:	c9                   	leave  
  8013ac:	c3                   	ret    

008013ad <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8013ad:	55                   	push   %ebp
  8013ae:	89 e5                	mov    %esp,%ebp
  8013b0:	53                   	push   %ebx
  8013b1:	83 ec 14             	sub    $0x14,%esp
  8013b4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013b7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013ba:	50                   	push   %eax
  8013bb:	53                   	push   %ebx
  8013bc:	e8 e4 fb ff ff       	call   800fa5 <fd_lookup>
  8013c1:	83 c4 08             	add    $0x8,%esp
  8013c4:	85 c0                	test   %eax,%eax
  8013c6:	78 5f                	js     801427 <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013c8:	83 ec 08             	sub    $0x8,%esp
  8013cb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013ce:	50                   	push   %eax
  8013cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013d2:	ff 30                	pushl  (%eax)
  8013d4:	e8 23 fc ff ff       	call   800ffc <dev_lookup>
  8013d9:	83 c4 10             	add    $0x10,%esp
  8013dc:	85 c0                	test   %eax,%eax
  8013de:	78 47                	js     801427 <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8013e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013e3:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8013e7:	75 21                	jne    80140a <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8013e9:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8013ee:	8b 40 48             	mov    0x48(%eax),%eax
  8013f1:	83 ec 04             	sub    $0x4,%esp
  8013f4:	53                   	push   %ebx
  8013f5:	50                   	push   %eax
  8013f6:	68 6c 24 80 00       	push   $0x80246c
  8013fb:	e8 c4 ee ff ff       	call   8002c4 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801400:	83 c4 10             	add    $0x10,%esp
  801403:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801408:	eb 1d                	jmp    801427 <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  80140a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80140d:	8b 52 18             	mov    0x18(%edx),%edx
  801410:	85 d2                	test   %edx,%edx
  801412:	74 0e                	je     801422 <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801414:	83 ec 08             	sub    $0x8,%esp
  801417:	ff 75 0c             	pushl  0xc(%ebp)
  80141a:	50                   	push   %eax
  80141b:	ff d2                	call   *%edx
  80141d:	83 c4 10             	add    $0x10,%esp
  801420:	eb 05                	jmp    801427 <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801422:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801427:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80142a:	c9                   	leave  
  80142b:	c3                   	ret    

0080142c <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80142c:	55                   	push   %ebp
  80142d:	89 e5                	mov    %esp,%ebp
  80142f:	53                   	push   %ebx
  801430:	83 ec 14             	sub    $0x14,%esp
  801433:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801436:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801439:	50                   	push   %eax
  80143a:	ff 75 08             	pushl  0x8(%ebp)
  80143d:	e8 63 fb ff ff       	call   800fa5 <fd_lookup>
  801442:	83 c4 08             	add    $0x8,%esp
  801445:	85 c0                	test   %eax,%eax
  801447:	78 52                	js     80149b <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801449:	83 ec 08             	sub    $0x8,%esp
  80144c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80144f:	50                   	push   %eax
  801450:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801453:	ff 30                	pushl  (%eax)
  801455:	e8 a2 fb ff ff       	call   800ffc <dev_lookup>
  80145a:	83 c4 10             	add    $0x10,%esp
  80145d:	85 c0                	test   %eax,%eax
  80145f:	78 3a                	js     80149b <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  801461:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801464:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801468:	74 2c                	je     801496 <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80146a:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80146d:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801474:	00 00 00 
	stat->st_isdir = 0;
  801477:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80147e:	00 00 00 
	stat->st_dev = dev;
  801481:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801487:	83 ec 08             	sub    $0x8,%esp
  80148a:	53                   	push   %ebx
  80148b:	ff 75 f0             	pushl  -0x10(%ebp)
  80148e:	ff 50 14             	call   *0x14(%eax)
  801491:	83 c4 10             	add    $0x10,%esp
  801494:	eb 05                	jmp    80149b <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801496:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80149b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80149e:	c9                   	leave  
  80149f:	c3                   	ret    

008014a0 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8014a0:	55                   	push   %ebp
  8014a1:	89 e5                	mov    %esp,%ebp
  8014a3:	56                   	push   %esi
  8014a4:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8014a5:	83 ec 08             	sub    $0x8,%esp
  8014a8:	6a 00                	push   $0x0
  8014aa:	ff 75 08             	pushl  0x8(%ebp)
  8014ad:	e8 75 01 00 00       	call   801627 <open>
  8014b2:	89 c3                	mov    %eax,%ebx
  8014b4:	83 c4 10             	add    $0x10,%esp
  8014b7:	85 c0                	test   %eax,%eax
  8014b9:	78 1d                	js     8014d8 <stat+0x38>
		return fd;
	r = fstat(fd, stat);
  8014bb:	83 ec 08             	sub    $0x8,%esp
  8014be:	ff 75 0c             	pushl  0xc(%ebp)
  8014c1:	50                   	push   %eax
  8014c2:	e8 65 ff ff ff       	call   80142c <fstat>
  8014c7:	89 c6                	mov    %eax,%esi
	close(fd);
  8014c9:	89 1c 24             	mov    %ebx,(%esp)
  8014cc:	e8 1d fc ff ff       	call   8010ee <close>
	return r;
  8014d1:	83 c4 10             	add    $0x10,%esp
  8014d4:	89 f0                	mov    %esi,%eax
  8014d6:	eb 00                	jmp    8014d8 <stat+0x38>
}
  8014d8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014db:	5b                   	pop    %ebx
  8014dc:	5e                   	pop    %esi
  8014dd:	5d                   	pop    %ebp
  8014de:	c3                   	ret    

008014df <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8014df:	55                   	push   %ebp
  8014e0:	89 e5                	mov    %esp,%ebp
  8014e2:	56                   	push   %esi
  8014e3:	53                   	push   %ebx
  8014e4:	89 c6                	mov    %eax,%esi
  8014e6:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8014e8:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  8014ef:	75 12                	jne    801503 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8014f1:	83 ec 0c             	sub    $0xc,%esp
  8014f4:	6a 01                	push   $0x1
  8014f6:	e8 8c 08 00 00       	call   801d87 <ipc_find_env>
  8014fb:	a3 04 40 80 00       	mov    %eax,0x804004
  801500:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801503:	6a 07                	push   $0x7
  801505:	68 00 50 80 00       	push   $0x805000
  80150a:	56                   	push   %esi
  80150b:	ff 35 04 40 80 00    	pushl  0x804004
  801511:	e8 12 08 00 00       	call   801d28 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801516:	83 c4 0c             	add    $0xc,%esp
  801519:	6a 00                	push   $0x0
  80151b:	53                   	push   %ebx
  80151c:	6a 00                	push   $0x0
  80151e:	e8 90 07 00 00       	call   801cb3 <ipc_recv>
}
  801523:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801526:	5b                   	pop    %ebx
  801527:	5e                   	pop    %esi
  801528:	5d                   	pop    %ebp
  801529:	c3                   	ret    

0080152a <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80152a:	55                   	push   %ebp
  80152b:	89 e5                	mov    %esp,%ebp
  80152d:	53                   	push   %ebx
  80152e:	83 ec 04             	sub    $0x4,%esp
  801531:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801534:	8b 45 08             	mov    0x8(%ebp),%eax
  801537:	8b 40 0c             	mov    0xc(%eax),%eax
  80153a:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80153f:	ba 00 00 00 00       	mov    $0x0,%edx
  801544:	b8 05 00 00 00       	mov    $0x5,%eax
  801549:	e8 91 ff ff ff       	call   8014df <fsipc>
  80154e:	85 c0                	test   %eax,%eax
  801550:	78 2c                	js     80157e <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801552:	83 ec 08             	sub    $0x8,%esp
  801555:	68 00 50 80 00       	push   $0x805000
  80155a:	53                   	push   %ebx
  80155b:	e8 49 f3 ff ff       	call   8008a9 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801560:	a1 80 50 80 00       	mov    0x805080,%eax
  801565:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80156b:	a1 84 50 80 00       	mov    0x805084,%eax
  801570:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801576:	83 c4 10             	add    $0x10,%esp
  801579:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80157e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801581:	c9                   	leave  
  801582:	c3                   	ret    

00801583 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801583:	55                   	push   %ebp
  801584:	89 e5                	mov    %esp,%ebp
  801586:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801589:	8b 45 08             	mov    0x8(%ebp),%eax
  80158c:	8b 40 0c             	mov    0xc(%eax),%eax
  80158f:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801594:	ba 00 00 00 00       	mov    $0x0,%edx
  801599:	b8 06 00 00 00       	mov    $0x6,%eax
  80159e:	e8 3c ff ff ff       	call   8014df <fsipc>
}
  8015a3:	c9                   	leave  
  8015a4:	c3                   	ret    

008015a5 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8015a5:	55                   	push   %ebp
  8015a6:	89 e5                	mov    %esp,%ebp
  8015a8:	56                   	push   %esi
  8015a9:	53                   	push   %ebx
  8015aa:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8015ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8015b0:	8b 40 0c             	mov    0xc(%eax),%eax
  8015b3:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8015b8:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8015be:	ba 00 00 00 00       	mov    $0x0,%edx
  8015c3:	b8 03 00 00 00       	mov    $0x3,%eax
  8015c8:	e8 12 ff ff ff       	call   8014df <fsipc>
  8015cd:	89 c3                	mov    %eax,%ebx
  8015cf:	85 c0                	test   %eax,%eax
  8015d1:	78 4b                	js     80161e <devfile_read+0x79>
		return r;
	assert(r <= n);
  8015d3:	39 c6                	cmp    %eax,%esi
  8015d5:	73 16                	jae    8015ed <devfile_read+0x48>
  8015d7:	68 c9 24 80 00       	push   $0x8024c9
  8015dc:	68 d0 24 80 00       	push   $0x8024d0
  8015e1:	6a 7a                	push   $0x7a
  8015e3:	68 e5 24 80 00       	push   $0x8024e5
  8015e8:	e8 ff eb ff ff       	call   8001ec <_panic>
	assert(r <= PGSIZE);
  8015ed:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8015f2:	7e 16                	jle    80160a <devfile_read+0x65>
  8015f4:	68 f0 24 80 00       	push   $0x8024f0
  8015f9:	68 d0 24 80 00       	push   $0x8024d0
  8015fe:	6a 7b                	push   $0x7b
  801600:	68 e5 24 80 00       	push   $0x8024e5
  801605:	e8 e2 eb ff ff       	call   8001ec <_panic>
	memmove(buf, &fsipcbuf, r);
  80160a:	83 ec 04             	sub    $0x4,%esp
  80160d:	50                   	push   %eax
  80160e:	68 00 50 80 00       	push   $0x805000
  801613:	ff 75 0c             	pushl  0xc(%ebp)
  801616:	e8 5b f4 ff ff       	call   800a76 <memmove>
	return r;
  80161b:	83 c4 10             	add    $0x10,%esp
}
  80161e:	89 d8                	mov    %ebx,%eax
  801620:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801623:	5b                   	pop    %ebx
  801624:	5e                   	pop    %esi
  801625:	5d                   	pop    %ebp
  801626:	c3                   	ret    

00801627 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801627:	55                   	push   %ebp
  801628:	89 e5                	mov    %esp,%ebp
  80162a:	53                   	push   %ebx
  80162b:	83 ec 20             	sub    $0x20,%esp
  80162e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801631:	53                   	push   %ebx
  801632:	e8 1b f2 ff ff       	call   800852 <strlen>
  801637:	83 c4 10             	add    $0x10,%esp
  80163a:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80163f:	7f 63                	jg     8016a4 <open+0x7d>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801641:	83 ec 0c             	sub    $0xc,%esp
  801644:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801647:	50                   	push   %eax
  801648:	e8 e4 f8 ff ff       	call   800f31 <fd_alloc>
  80164d:	83 c4 10             	add    $0x10,%esp
  801650:	85 c0                	test   %eax,%eax
  801652:	78 55                	js     8016a9 <open+0x82>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801654:	83 ec 08             	sub    $0x8,%esp
  801657:	53                   	push   %ebx
  801658:	68 00 50 80 00       	push   $0x805000
  80165d:	e8 47 f2 ff ff       	call   8008a9 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801662:	8b 45 0c             	mov    0xc(%ebp),%eax
  801665:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80166a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80166d:	b8 01 00 00 00       	mov    $0x1,%eax
  801672:	e8 68 fe ff ff       	call   8014df <fsipc>
  801677:	89 c3                	mov    %eax,%ebx
  801679:	83 c4 10             	add    $0x10,%esp
  80167c:	85 c0                	test   %eax,%eax
  80167e:	79 14                	jns    801694 <open+0x6d>
		fd_close(fd, 0);
  801680:	83 ec 08             	sub    $0x8,%esp
  801683:	6a 00                	push   $0x0
  801685:	ff 75 f4             	pushl  -0xc(%ebp)
  801688:	e8 dd f9 ff ff       	call   80106a <fd_close>
		return r;
  80168d:	83 c4 10             	add    $0x10,%esp
  801690:	89 d8                	mov    %ebx,%eax
  801692:	eb 15                	jmp    8016a9 <open+0x82>
	}

	return fd2num(fd);
  801694:	83 ec 0c             	sub    $0xc,%esp
  801697:	ff 75 f4             	pushl  -0xc(%ebp)
  80169a:	e8 6b f8 ff ff       	call   800f0a <fd2num>
  80169f:	83 c4 10             	add    $0x10,%esp
  8016a2:	eb 05                	jmp    8016a9 <open+0x82>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8016a4:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8016a9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016ac:	c9                   	leave  
  8016ad:	c3                   	ret    

008016ae <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  8016ae:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  8016b2:	7e 38                	jle    8016ec <writebuf+0x3e>
};


static void
writebuf(struct printbuf *b)
{
  8016b4:	55                   	push   %ebp
  8016b5:	89 e5                	mov    %esp,%ebp
  8016b7:	53                   	push   %ebx
  8016b8:	83 ec 08             	sub    $0x8,%esp
  8016bb:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
		ssize_t result = write(b->fd, b->buf, b->idx);
  8016bd:	ff 70 04             	pushl  0x4(%eax)
  8016c0:	8d 40 10             	lea    0x10(%eax),%eax
  8016c3:	50                   	push   %eax
  8016c4:	ff 33                	pushl  (%ebx)
  8016c6:	e8 37 fc ff ff       	call   801302 <write>
		if (result > 0)
  8016cb:	83 c4 10             	add    $0x10,%esp
  8016ce:	85 c0                	test   %eax,%eax
  8016d0:	7e 03                	jle    8016d5 <writebuf+0x27>
			b->result += result;
  8016d2:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  8016d5:	3b 43 04             	cmp    0x4(%ebx),%eax
  8016d8:	74 0e                	je     8016e8 <writebuf+0x3a>
			b->error = (result < 0 ? result : 0);
  8016da:	89 c2                	mov    %eax,%edx
  8016dc:	85 c0                	test   %eax,%eax
  8016de:	7e 05                	jle    8016e5 <writebuf+0x37>
  8016e0:	ba 00 00 00 00       	mov    $0x0,%edx
  8016e5:	89 53 0c             	mov    %edx,0xc(%ebx)
	}
}
  8016e8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016eb:	c9                   	leave  
  8016ec:	c3                   	ret    

008016ed <putch>:

static void
putch(int ch, void *thunk)
{
  8016ed:	55                   	push   %ebp
  8016ee:	89 e5                	mov    %esp,%ebp
  8016f0:	53                   	push   %ebx
  8016f1:	83 ec 04             	sub    $0x4,%esp
  8016f4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  8016f7:	8b 53 04             	mov    0x4(%ebx),%edx
  8016fa:	8d 42 01             	lea    0x1(%edx),%eax
  8016fd:	89 43 04             	mov    %eax,0x4(%ebx)
  801700:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801703:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  801707:	3d 00 01 00 00       	cmp    $0x100,%eax
  80170c:	75 0e                	jne    80171c <putch+0x2f>
		writebuf(b);
  80170e:	89 d8                	mov    %ebx,%eax
  801710:	e8 99 ff ff ff       	call   8016ae <writebuf>
		b->idx = 0;
  801715:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  80171c:	83 c4 04             	add    $0x4,%esp
  80171f:	5b                   	pop    %ebx
  801720:	5d                   	pop    %ebp
  801721:	c3                   	ret    

00801722 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  801722:	55                   	push   %ebp
  801723:	89 e5                	mov    %esp,%ebp
  801725:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  80172b:	8b 45 08             	mov    0x8(%ebp),%eax
  80172e:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  801734:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  80173b:	00 00 00 
	b.result = 0;
  80173e:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801745:	00 00 00 
	b.error = 1;
  801748:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  80174f:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  801752:	ff 75 10             	pushl  0x10(%ebp)
  801755:	ff 75 0c             	pushl  0xc(%ebp)
  801758:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  80175e:	50                   	push   %eax
  80175f:	68 ed 16 80 00       	push   $0x8016ed
  801764:	e8 92 ec ff ff       	call   8003fb <vprintfmt>
	if (b.idx > 0)
  801769:	83 c4 10             	add    $0x10,%esp
  80176c:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  801773:	7e 0b                	jle    801780 <vfprintf+0x5e>
		writebuf(&b);
  801775:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  80177b:	e8 2e ff ff ff       	call   8016ae <writebuf>

	return (b.result ? b.result : b.error);
  801780:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801786:	85 c0                	test   %eax,%eax
  801788:	75 06                	jne    801790 <vfprintf+0x6e>
  80178a:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  801790:	c9                   	leave  
  801791:	c3                   	ret    

00801792 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  801792:	55                   	push   %ebp
  801793:	89 e5                	mov    %esp,%ebp
  801795:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801798:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  80179b:	50                   	push   %eax
  80179c:	ff 75 0c             	pushl  0xc(%ebp)
  80179f:	ff 75 08             	pushl  0x8(%ebp)
  8017a2:	e8 7b ff ff ff       	call   801722 <vfprintf>
	va_end(ap);

	return cnt;
}
  8017a7:	c9                   	leave  
  8017a8:	c3                   	ret    

008017a9 <printf>:

int
printf(const char *fmt, ...)
{
  8017a9:	55                   	push   %ebp
  8017aa:	89 e5                	mov    %esp,%ebp
  8017ac:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8017af:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  8017b2:	50                   	push   %eax
  8017b3:	ff 75 08             	pushl  0x8(%ebp)
  8017b6:	6a 01                	push   $0x1
  8017b8:	e8 65 ff ff ff       	call   801722 <vfprintf>
	va_end(ap);

	return cnt;
}
  8017bd:	c9                   	leave  
  8017be:	c3                   	ret    

008017bf <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8017bf:	55                   	push   %ebp
  8017c0:	89 e5                	mov    %esp,%ebp
  8017c2:	56                   	push   %esi
  8017c3:	53                   	push   %ebx
  8017c4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8017c7:	83 ec 0c             	sub    $0xc,%esp
  8017ca:	ff 75 08             	pushl  0x8(%ebp)
  8017cd:	e8 48 f7 ff ff       	call   800f1a <fd2data>
  8017d2:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8017d4:	83 c4 08             	add    $0x8,%esp
  8017d7:	68 fc 24 80 00       	push   $0x8024fc
  8017dc:	53                   	push   %ebx
  8017dd:	e8 c7 f0 ff ff       	call   8008a9 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8017e2:	8b 46 04             	mov    0x4(%esi),%eax
  8017e5:	2b 06                	sub    (%esi),%eax
  8017e7:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8017ed:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8017f4:	00 00 00 
	stat->st_dev = &devpipe;
  8017f7:	c7 83 88 00 00 00 24 	movl   $0x803024,0x88(%ebx)
  8017fe:	30 80 00 
	return 0;
}
  801801:	b8 00 00 00 00       	mov    $0x0,%eax
  801806:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801809:	5b                   	pop    %ebx
  80180a:	5e                   	pop    %esi
  80180b:	5d                   	pop    %ebp
  80180c:	c3                   	ret    

0080180d <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80180d:	55                   	push   %ebp
  80180e:	89 e5                	mov    %esp,%ebp
  801810:	53                   	push   %ebx
  801811:	83 ec 0c             	sub    $0xc,%esp
  801814:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801817:	53                   	push   %ebx
  801818:	6a 00                	push   $0x0
  80181a:	e8 7f f5 ff ff       	call   800d9e <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80181f:	89 1c 24             	mov    %ebx,(%esp)
  801822:	e8 f3 f6 ff ff       	call   800f1a <fd2data>
  801827:	83 c4 08             	add    $0x8,%esp
  80182a:	50                   	push   %eax
  80182b:	6a 00                	push   $0x0
  80182d:	e8 6c f5 ff ff       	call   800d9e <sys_page_unmap>
}
  801832:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801835:	c9                   	leave  
  801836:	c3                   	ret    

00801837 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801837:	55                   	push   %ebp
  801838:	89 e5                	mov    %esp,%ebp
  80183a:	57                   	push   %edi
  80183b:	56                   	push   %esi
  80183c:	53                   	push   %ebx
  80183d:	83 ec 1c             	sub    $0x1c,%esp
  801840:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801843:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801845:	a1 08 40 80 00       	mov    0x804008,%eax
  80184a:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  80184d:	83 ec 0c             	sub    $0xc,%esp
  801850:	ff 75 e0             	pushl  -0x20(%ebp)
  801853:	e8 8a 05 00 00       	call   801de2 <pageref>
  801858:	89 c3                	mov    %eax,%ebx
  80185a:	89 3c 24             	mov    %edi,(%esp)
  80185d:	e8 80 05 00 00       	call   801de2 <pageref>
  801862:	83 c4 10             	add    $0x10,%esp
  801865:	39 c3                	cmp    %eax,%ebx
  801867:	0f 94 c1             	sete   %cl
  80186a:	0f b6 c9             	movzbl %cl,%ecx
  80186d:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801870:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801876:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801879:	39 ce                	cmp    %ecx,%esi
  80187b:	74 1b                	je     801898 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  80187d:	39 c3                	cmp    %eax,%ebx
  80187f:	75 c4                	jne    801845 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801881:	8b 42 58             	mov    0x58(%edx),%eax
  801884:	ff 75 e4             	pushl  -0x1c(%ebp)
  801887:	50                   	push   %eax
  801888:	56                   	push   %esi
  801889:	68 03 25 80 00       	push   $0x802503
  80188e:	e8 31 ea ff ff       	call   8002c4 <cprintf>
  801893:	83 c4 10             	add    $0x10,%esp
  801896:	eb ad                	jmp    801845 <_pipeisclosed+0xe>
	}
}
  801898:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80189b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80189e:	5b                   	pop    %ebx
  80189f:	5e                   	pop    %esi
  8018a0:	5f                   	pop    %edi
  8018a1:	5d                   	pop    %ebp
  8018a2:	c3                   	ret    

008018a3 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8018a3:	55                   	push   %ebp
  8018a4:	89 e5                	mov    %esp,%ebp
  8018a6:	57                   	push   %edi
  8018a7:	56                   	push   %esi
  8018a8:	53                   	push   %ebx
  8018a9:	83 ec 18             	sub    $0x18,%esp
  8018ac:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8018af:	56                   	push   %esi
  8018b0:	e8 65 f6 ff ff       	call   800f1a <fd2data>
  8018b5:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8018b7:	83 c4 10             	add    $0x10,%esp
  8018ba:	bf 00 00 00 00       	mov    $0x0,%edi
  8018bf:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8018c3:	75 42                	jne    801907 <devpipe_write+0x64>
  8018c5:	eb 4e                	jmp    801915 <devpipe_write+0x72>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8018c7:	89 da                	mov    %ebx,%edx
  8018c9:	89 f0                	mov    %esi,%eax
  8018cb:	e8 67 ff ff ff       	call   801837 <_pipeisclosed>
  8018d0:	85 c0                	test   %eax,%eax
  8018d2:	75 46                	jne    80191a <devpipe_write+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8018d4:	e8 21 f4 ff ff       	call   800cfa <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8018d9:	8b 53 04             	mov    0x4(%ebx),%edx
  8018dc:	8b 03                	mov    (%ebx),%eax
  8018de:	83 c0 20             	add    $0x20,%eax
  8018e1:	39 c2                	cmp    %eax,%edx
  8018e3:	73 e2                	jae    8018c7 <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8018e5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018e8:	8a 0c 38             	mov    (%eax,%edi,1),%cl
  8018eb:	89 d0                	mov    %edx,%eax
  8018ed:	25 1f 00 00 80       	and    $0x8000001f,%eax
  8018f2:	79 05                	jns    8018f9 <devpipe_write+0x56>
  8018f4:	48                   	dec    %eax
  8018f5:	83 c8 e0             	or     $0xffffffe0,%eax
  8018f8:	40                   	inc    %eax
  8018f9:	88 4c 03 08          	mov    %cl,0x8(%ebx,%eax,1)
		p->p_wpos++;
  8018fd:	42                   	inc    %edx
  8018fe:	89 53 04             	mov    %edx,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801901:	47                   	inc    %edi
  801902:	39 7d 10             	cmp    %edi,0x10(%ebp)
  801905:	74 0e                	je     801915 <devpipe_write+0x72>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801907:	8b 53 04             	mov    0x4(%ebx),%edx
  80190a:	8b 03                	mov    (%ebx),%eax
  80190c:	83 c0 20             	add    $0x20,%eax
  80190f:	39 c2                	cmp    %eax,%edx
  801911:	73 b4                	jae    8018c7 <devpipe_write+0x24>
  801913:	eb d0                	jmp    8018e5 <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801915:	8b 45 10             	mov    0x10(%ebp),%eax
  801918:	eb 05                	jmp    80191f <devpipe_write+0x7c>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80191a:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80191f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801922:	5b                   	pop    %ebx
  801923:	5e                   	pop    %esi
  801924:	5f                   	pop    %edi
  801925:	5d                   	pop    %ebp
  801926:	c3                   	ret    

00801927 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801927:	55                   	push   %ebp
  801928:	89 e5                	mov    %esp,%ebp
  80192a:	57                   	push   %edi
  80192b:	56                   	push   %esi
  80192c:	53                   	push   %ebx
  80192d:	83 ec 18             	sub    $0x18,%esp
  801930:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801933:	57                   	push   %edi
  801934:	e8 e1 f5 ff ff       	call   800f1a <fd2data>
  801939:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80193b:	83 c4 10             	add    $0x10,%esp
  80193e:	be 00 00 00 00       	mov    $0x0,%esi
  801943:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801947:	75 3d                	jne    801986 <devpipe_read+0x5f>
  801949:	eb 48                	jmp    801993 <devpipe_read+0x6c>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  80194b:	89 f0                	mov    %esi,%eax
  80194d:	eb 4e                	jmp    80199d <devpipe_read+0x76>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80194f:	89 da                	mov    %ebx,%edx
  801951:	89 f8                	mov    %edi,%eax
  801953:	e8 df fe ff ff       	call   801837 <_pipeisclosed>
  801958:	85 c0                	test   %eax,%eax
  80195a:	75 3c                	jne    801998 <devpipe_read+0x71>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80195c:	e8 99 f3 ff ff       	call   800cfa <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801961:	8b 03                	mov    (%ebx),%eax
  801963:	3b 43 04             	cmp    0x4(%ebx),%eax
  801966:	74 e7                	je     80194f <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801968:	25 1f 00 00 80       	and    $0x8000001f,%eax
  80196d:	79 05                	jns    801974 <devpipe_read+0x4d>
  80196f:	48                   	dec    %eax
  801970:	83 c8 e0             	or     $0xffffffe0,%eax
  801973:	40                   	inc    %eax
  801974:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801978:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80197b:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  80197e:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801980:	46                   	inc    %esi
  801981:	39 75 10             	cmp    %esi,0x10(%ebp)
  801984:	74 0d                	je     801993 <devpipe_read+0x6c>
		while (p->p_rpos == p->p_wpos) {
  801986:	8b 03                	mov    (%ebx),%eax
  801988:	3b 43 04             	cmp    0x4(%ebx),%eax
  80198b:	75 db                	jne    801968 <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80198d:	85 f6                	test   %esi,%esi
  80198f:	75 ba                	jne    80194b <devpipe_read+0x24>
  801991:	eb bc                	jmp    80194f <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801993:	8b 45 10             	mov    0x10(%ebp),%eax
  801996:	eb 05                	jmp    80199d <devpipe_read+0x76>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801998:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80199d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019a0:	5b                   	pop    %ebx
  8019a1:	5e                   	pop    %esi
  8019a2:	5f                   	pop    %edi
  8019a3:	5d                   	pop    %ebp
  8019a4:	c3                   	ret    

008019a5 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8019a5:	55                   	push   %ebp
  8019a6:	89 e5                	mov    %esp,%ebp
  8019a8:	56                   	push   %esi
  8019a9:	53                   	push   %ebx
  8019aa:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8019ad:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019b0:	50                   	push   %eax
  8019b1:	e8 7b f5 ff ff       	call   800f31 <fd_alloc>
  8019b6:	83 c4 10             	add    $0x10,%esp
  8019b9:	85 c0                	test   %eax,%eax
  8019bb:	0f 88 2a 01 00 00    	js     801aeb <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8019c1:	83 ec 04             	sub    $0x4,%esp
  8019c4:	68 07 04 00 00       	push   $0x407
  8019c9:	ff 75 f4             	pushl  -0xc(%ebp)
  8019cc:	6a 00                	push   $0x0
  8019ce:	e8 46 f3 ff ff       	call   800d19 <sys_page_alloc>
  8019d3:	83 c4 10             	add    $0x10,%esp
  8019d6:	85 c0                	test   %eax,%eax
  8019d8:	0f 88 0d 01 00 00    	js     801aeb <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8019de:	83 ec 0c             	sub    $0xc,%esp
  8019e1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8019e4:	50                   	push   %eax
  8019e5:	e8 47 f5 ff ff       	call   800f31 <fd_alloc>
  8019ea:	89 c3                	mov    %eax,%ebx
  8019ec:	83 c4 10             	add    $0x10,%esp
  8019ef:	85 c0                	test   %eax,%eax
  8019f1:	0f 88 e2 00 00 00    	js     801ad9 <pipe+0x134>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8019f7:	83 ec 04             	sub    $0x4,%esp
  8019fa:	68 07 04 00 00       	push   $0x407
  8019ff:	ff 75 f0             	pushl  -0x10(%ebp)
  801a02:	6a 00                	push   $0x0
  801a04:	e8 10 f3 ff ff       	call   800d19 <sys_page_alloc>
  801a09:	89 c3                	mov    %eax,%ebx
  801a0b:	83 c4 10             	add    $0x10,%esp
  801a0e:	85 c0                	test   %eax,%eax
  801a10:	0f 88 c3 00 00 00    	js     801ad9 <pipe+0x134>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801a16:	83 ec 0c             	sub    $0xc,%esp
  801a19:	ff 75 f4             	pushl  -0xc(%ebp)
  801a1c:	e8 f9 f4 ff ff       	call   800f1a <fd2data>
  801a21:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a23:	83 c4 0c             	add    $0xc,%esp
  801a26:	68 07 04 00 00       	push   $0x407
  801a2b:	50                   	push   %eax
  801a2c:	6a 00                	push   $0x0
  801a2e:	e8 e6 f2 ff ff       	call   800d19 <sys_page_alloc>
  801a33:	89 c3                	mov    %eax,%ebx
  801a35:	83 c4 10             	add    $0x10,%esp
  801a38:	85 c0                	test   %eax,%eax
  801a3a:	0f 88 89 00 00 00    	js     801ac9 <pipe+0x124>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a40:	83 ec 0c             	sub    $0xc,%esp
  801a43:	ff 75 f0             	pushl  -0x10(%ebp)
  801a46:	e8 cf f4 ff ff       	call   800f1a <fd2data>
  801a4b:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801a52:	50                   	push   %eax
  801a53:	6a 00                	push   $0x0
  801a55:	56                   	push   %esi
  801a56:	6a 00                	push   $0x0
  801a58:	e8 ff f2 ff ff       	call   800d5c <sys_page_map>
  801a5d:	89 c3                	mov    %eax,%ebx
  801a5f:	83 c4 20             	add    $0x20,%esp
  801a62:	85 c0                	test   %eax,%eax
  801a64:	78 55                	js     801abb <pipe+0x116>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801a66:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801a6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a6f:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801a71:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a74:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801a7b:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801a81:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a84:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801a86:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a89:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801a90:	83 ec 0c             	sub    $0xc,%esp
  801a93:	ff 75 f4             	pushl  -0xc(%ebp)
  801a96:	e8 6f f4 ff ff       	call   800f0a <fd2num>
  801a9b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801a9e:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801aa0:	83 c4 04             	add    $0x4,%esp
  801aa3:	ff 75 f0             	pushl  -0x10(%ebp)
  801aa6:	e8 5f f4 ff ff       	call   800f0a <fd2num>
  801aab:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801aae:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801ab1:	83 c4 10             	add    $0x10,%esp
  801ab4:	b8 00 00 00 00       	mov    $0x0,%eax
  801ab9:	eb 30                	jmp    801aeb <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  801abb:	83 ec 08             	sub    $0x8,%esp
  801abe:	56                   	push   %esi
  801abf:	6a 00                	push   $0x0
  801ac1:	e8 d8 f2 ff ff       	call   800d9e <sys_page_unmap>
  801ac6:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801ac9:	83 ec 08             	sub    $0x8,%esp
  801acc:	ff 75 f0             	pushl  -0x10(%ebp)
  801acf:	6a 00                	push   $0x0
  801ad1:	e8 c8 f2 ff ff       	call   800d9e <sys_page_unmap>
  801ad6:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801ad9:	83 ec 08             	sub    $0x8,%esp
  801adc:	ff 75 f4             	pushl  -0xc(%ebp)
  801adf:	6a 00                	push   $0x0
  801ae1:	e8 b8 f2 ff ff       	call   800d9e <sys_page_unmap>
  801ae6:	83 c4 10             	add    $0x10,%esp
  801ae9:	89 d8                	mov    %ebx,%eax
    err:
	return r;
}
  801aeb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801aee:	5b                   	pop    %ebx
  801aef:	5e                   	pop    %esi
  801af0:	5d                   	pop    %ebp
  801af1:	c3                   	ret    

00801af2 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801af2:	55                   	push   %ebp
  801af3:	89 e5                	mov    %esp,%ebp
  801af5:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801af8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801afb:	50                   	push   %eax
  801afc:	ff 75 08             	pushl  0x8(%ebp)
  801aff:	e8 a1 f4 ff ff       	call   800fa5 <fd_lookup>
  801b04:	83 c4 10             	add    $0x10,%esp
  801b07:	85 c0                	test   %eax,%eax
  801b09:	78 18                	js     801b23 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801b0b:	83 ec 0c             	sub    $0xc,%esp
  801b0e:	ff 75 f4             	pushl  -0xc(%ebp)
  801b11:	e8 04 f4 ff ff       	call   800f1a <fd2data>
	return _pipeisclosed(fd, p);
  801b16:	89 c2                	mov    %eax,%edx
  801b18:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b1b:	e8 17 fd ff ff       	call   801837 <_pipeisclosed>
  801b20:	83 c4 10             	add    $0x10,%esp
}
  801b23:	c9                   	leave  
  801b24:	c3                   	ret    

00801b25 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801b25:	55                   	push   %ebp
  801b26:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801b28:	b8 00 00 00 00       	mov    $0x0,%eax
  801b2d:	5d                   	pop    %ebp
  801b2e:	c3                   	ret    

00801b2f <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801b2f:	55                   	push   %ebp
  801b30:	89 e5                	mov    %esp,%ebp
  801b32:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801b35:	68 1b 25 80 00       	push   $0x80251b
  801b3a:	ff 75 0c             	pushl  0xc(%ebp)
  801b3d:	e8 67 ed ff ff       	call   8008a9 <strcpy>
	return 0;
}
  801b42:	b8 00 00 00 00       	mov    $0x0,%eax
  801b47:	c9                   	leave  
  801b48:	c3                   	ret    

00801b49 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801b49:	55                   	push   %ebp
  801b4a:	89 e5                	mov    %esp,%ebp
  801b4c:	57                   	push   %edi
  801b4d:	56                   	push   %esi
  801b4e:	53                   	push   %ebx
  801b4f:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801b55:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801b59:	74 45                	je     801ba0 <devcons_write+0x57>
  801b5b:	b8 00 00 00 00       	mov    $0x0,%eax
  801b60:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801b65:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801b6b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801b6e:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  801b70:	83 fb 7f             	cmp    $0x7f,%ebx
  801b73:	76 05                	jbe    801b7a <devcons_write+0x31>
			m = sizeof(buf) - 1;
  801b75:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801b7a:	83 ec 04             	sub    $0x4,%esp
  801b7d:	53                   	push   %ebx
  801b7e:	03 45 0c             	add    0xc(%ebp),%eax
  801b81:	50                   	push   %eax
  801b82:	57                   	push   %edi
  801b83:	e8 ee ee ff ff       	call   800a76 <memmove>
		sys_cputs(buf, m);
  801b88:	83 c4 08             	add    $0x8,%esp
  801b8b:	53                   	push   %ebx
  801b8c:	57                   	push   %edi
  801b8d:	e8 cb f0 ff ff       	call   800c5d <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801b92:	01 de                	add    %ebx,%esi
  801b94:	89 f0                	mov    %esi,%eax
  801b96:	83 c4 10             	add    $0x10,%esp
  801b99:	3b 75 10             	cmp    0x10(%ebp),%esi
  801b9c:	72 cd                	jb     801b6b <devcons_write+0x22>
  801b9e:	eb 05                	jmp    801ba5 <devcons_write+0x5c>
  801ba0:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801ba5:	89 f0                	mov    %esi,%eax
  801ba7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801baa:	5b                   	pop    %ebx
  801bab:	5e                   	pop    %esi
  801bac:	5f                   	pop    %edi
  801bad:	5d                   	pop    %ebp
  801bae:	c3                   	ret    

00801baf <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801baf:	55                   	push   %ebp
  801bb0:	89 e5                	mov    %esp,%ebp
  801bb2:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801bb5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801bb9:	75 07                	jne    801bc2 <devcons_read+0x13>
  801bbb:	eb 23                	jmp    801be0 <devcons_read+0x31>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801bbd:	e8 38 f1 ff ff       	call   800cfa <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801bc2:	e8 b4 f0 ff ff       	call   800c7b <sys_cgetc>
  801bc7:	85 c0                	test   %eax,%eax
  801bc9:	74 f2                	je     801bbd <devcons_read+0xe>
		sys_yield();
	if (c < 0)
  801bcb:	85 c0                	test   %eax,%eax
  801bcd:	78 1d                	js     801bec <devcons_read+0x3d>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801bcf:	83 f8 04             	cmp    $0x4,%eax
  801bd2:	74 13                	je     801be7 <devcons_read+0x38>
		return 0;
	*(char*)vbuf = c;
  801bd4:	8b 55 0c             	mov    0xc(%ebp),%edx
  801bd7:	88 02                	mov    %al,(%edx)
	return 1;
  801bd9:	b8 01 00 00 00       	mov    $0x1,%eax
  801bde:	eb 0c                	jmp    801bec <devcons_read+0x3d>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801be0:	b8 00 00 00 00       	mov    $0x0,%eax
  801be5:	eb 05                	jmp    801bec <devcons_read+0x3d>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801be7:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801bec:	c9                   	leave  
  801bed:	c3                   	ret    

00801bee <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801bee:	55                   	push   %ebp
  801bef:	89 e5                	mov    %esp,%ebp
  801bf1:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801bf4:	8b 45 08             	mov    0x8(%ebp),%eax
  801bf7:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801bfa:	6a 01                	push   $0x1
  801bfc:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801bff:	50                   	push   %eax
  801c00:	e8 58 f0 ff ff       	call   800c5d <sys_cputs>
}
  801c05:	83 c4 10             	add    $0x10,%esp
  801c08:	c9                   	leave  
  801c09:	c3                   	ret    

00801c0a <getchar>:

int
getchar(void)
{
  801c0a:	55                   	push   %ebp
  801c0b:	89 e5                	mov    %esp,%ebp
  801c0d:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801c10:	6a 01                	push   $0x1
  801c12:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801c15:	50                   	push   %eax
  801c16:	6a 00                	push   $0x0
  801c18:	e8 09 f6 ff ff       	call   801226 <read>
	if (r < 0)
  801c1d:	83 c4 10             	add    $0x10,%esp
  801c20:	85 c0                	test   %eax,%eax
  801c22:	78 0f                	js     801c33 <getchar+0x29>
		return r;
	if (r < 1)
  801c24:	85 c0                	test   %eax,%eax
  801c26:	7e 06                	jle    801c2e <getchar+0x24>
		return -E_EOF;
	return c;
  801c28:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801c2c:	eb 05                	jmp    801c33 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801c2e:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801c33:	c9                   	leave  
  801c34:	c3                   	ret    

00801c35 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801c35:	55                   	push   %ebp
  801c36:	89 e5                	mov    %esp,%ebp
  801c38:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c3b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c3e:	50                   	push   %eax
  801c3f:	ff 75 08             	pushl  0x8(%ebp)
  801c42:	e8 5e f3 ff ff       	call   800fa5 <fd_lookup>
  801c47:	83 c4 10             	add    $0x10,%esp
  801c4a:	85 c0                	test   %eax,%eax
  801c4c:	78 11                	js     801c5f <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801c4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c51:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801c57:	39 10                	cmp    %edx,(%eax)
  801c59:	0f 94 c0             	sete   %al
  801c5c:	0f b6 c0             	movzbl %al,%eax
}
  801c5f:	c9                   	leave  
  801c60:	c3                   	ret    

00801c61 <opencons>:

int
opencons(void)
{
  801c61:	55                   	push   %ebp
  801c62:	89 e5                	mov    %esp,%ebp
  801c64:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801c67:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c6a:	50                   	push   %eax
  801c6b:	e8 c1 f2 ff ff       	call   800f31 <fd_alloc>
  801c70:	83 c4 10             	add    $0x10,%esp
  801c73:	85 c0                	test   %eax,%eax
  801c75:	78 3a                	js     801cb1 <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801c77:	83 ec 04             	sub    $0x4,%esp
  801c7a:	68 07 04 00 00       	push   $0x407
  801c7f:	ff 75 f4             	pushl  -0xc(%ebp)
  801c82:	6a 00                	push   $0x0
  801c84:	e8 90 f0 ff ff       	call   800d19 <sys_page_alloc>
  801c89:	83 c4 10             	add    $0x10,%esp
  801c8c:	85 c0                	test   %eax,%eax
  801c8e:	78 21                	js     801cb1 <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801c90:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801c96:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c99:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801c9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c9e:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801ca5:	83 ec 0c             	sub    $0xc,%esp
  801ca8:	50                   	push   %eax
  801ca9:	e8 5c f2 ff ff       	call   800f0a <fd2num>
  801cae:	83 c4 10             	add    $0x10,%esp
}
  801cb1:	c9                   	leave  
  801cb2:	c3                   	ret    

00801cb3 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801cb3:	55                   	push   %ebp
  801cb4:	89 e5                	mov    %esp,%ebp
  801cb6:	56                   	push   %esi
  801cb7:	53                   	push   %ebx
  801cb8:	8b 75 08             	mov    0x8(%ebp),%esi
  801cbb:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cbe:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");
	int r;
    if (pg != NULL) {
  801cc1:	85 c0                	test   %eax,%eax
  801cc3:	74 0e                	je     801cd3 <ipc_recv+0x20>
        r = sys_ipc_recv(pg);
  801cc5:	83 ec 0c             	sub    $0xc,%esp
  801cc8:	50                   	push   %eax
  801cc9:	e8 fb f1 ff ff       	call   800ec9 <sys_ipc_recv>
  801cce:	83 c4 10             	add    $0x10,%esp
  801cd1:	eb 10                	jmp    801ce3 <ipc_recv+0x30>
    } else {
        r = sys_ipc_recv((void *) UTOP);
  801cd3:	83 ec 0c             	sub    $0xc,%esp
  801cd6:	68 00 00 c0 ee       	push   $0xeec00000
  801cdb:	e8 e9 f1 ff ff       	call   800ec9 <sys_ipc_recv>
  801ce0:	83 c4 10             	add    $0x10,%esp
    }
    if (r < 0) {
  801ce3:	85 c0                	test   %eax,%eax
  801ce5:	79 16                	jns    801cfd <ipc_recv+0x4a>
        // failed
        if (from_env_store != NULL) *from_env_store = 0;
  801ce7:	85 f6                	test   %esi,%esi
  801ce9:	74 06                	je     801cf1 <ipc_recv+0x3e>
  801ceb:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        if (perm_store != NULL) *perm_store = 0;
  801cf1:	85 db                	test   %ebx,%ebx
  801cf3:	74 2c                	je     801d21 <ipc_recv+0x6e>
  801cf5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801cfb:	eb 24                	jmp    801d21 <ipc_recv+0x6e>
        return r;
    } else {
        if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801cfd:	85 f6                	test   %esi,%esi
  801cff:	74 0a                	je     801d0b <ipc_recv+0x58>
  801d01:	a1 08 40 80 00       	mov    0x804008,%eax
  801d06:	8b 40 74             	mov    0x74(%eax),%eax
  801d09:	89 06                	mov    %eax,(%esi)
        if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801d0b:	85 db                	test   %ebx,%ebx
  801d0d:	74 0a                	je     801d19 <ipc_recv+0x66>
  801d0f:	a1 08 40 80 00       	mov    0x804008,%eax
  801d14:	8b 40 78             	mov    0x78(%eax),%eax
  801d17:	89 03                	mov    %eax,(%ebx)
        return thisenv->env_ipc_value;
  801d19:	a1 08 40 80 00       	mov    0x804008,%eax
  801d1e:	8b 40 70             	mov    0x70(%eax),%eax
    }
 
	return 0;
}
  801d21:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d24:	5b                   	pop    %ebx
  801d25:	5e                   	pop    %esi
  801d26:	5d                   	pop    %ebp
  801d27:	c3                   	ret    

00801d28 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801d28:	55                   	push   %ebp
  801d29:	89 e5                	mov    %esp,%ebp
  801d2b:	57                   	push   %edi
  801d2c:	56                   	push   %esi
  801d2d:	53                   	push   %ebx
  801d2e:	83 ec 0c             	sub    $0xc,%esp
  801d31:	8b 75 10             	mov    0x10(%ebp),%esi
  801d34:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");
	int r;
    if (pg == NULL) pg = (void *)UTOP;
  801d37:	85 f6                	test   %esi,%esi
  801d39:	75 05                	jne    801d40 <ipc_send+0x18>
  801d3b:	be 00 00 c0 ee       	mov    $0xeec00000,%esi
    do {
        r = sys_ipc_try_send(to_env, val, pg, perm);
  801d40:	57                   	push   %edi
  801d41:	56                   	push   %esi
  801d42:	ff 75 0c             	pushl  0xc(%ebp)
  801d45:	ff 75 08             	pushl  0x8(%ebp)
  801d48:	e8 59 f1 ff ff       	call   800ea6 <sys_ipc_try_send>
  801d4d:	89 c3                	mov    %eax,%ebx
        if (r < 0 && r != -E_IPC_NOT_RECV) panic("ipc send failed: %e", r);
  801d4f:	83 c4 10             	add    $0x10,%esp
  801d52:	85 c0                	test   %eax,%eax
  801d54:	79 17                	jns    801d6d <ipc_send+0x45>
  801d56:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801d59:	74 1d                	je     801d78 <ipc_send+0x50>
  801d5b:	50                   	push   %eax
  801d5c:	68 27 25 80 00       	push   $0x802527
  801d61:	6a 40                	push   $0x40
  801d63:	68 3b 25 80 00       	push   $0x80253b
  801d68:	e8 7f e4 ff ff       	call   8001ec <_panic>
        sys_yield();
  801d6d:	e8 88 ef ff ff       	call   800cfa <sys_yield>
    } while (r != 0);
  801d72:	85 db                	test   %ebx,%ebx
  801d74:	75 ca                	jne    801d40 <ipc_send+0x18>
  801d76:	eb 07                	jmp    801d7f <ipc_send+0x57>
	int r;
    if (pg == NULL) pg = (void *)UTOP;
    do {
        r = sys_ipc_try_send(to_env, val, pg, perm);
        if (r < 0 && r != -E_IPC_NOT_RECV) panic("ipc send failed: %e", r);
        sys_yield();
  801d78:	e8 7d ef ff ff       	call   800cfa <sys_yield>
  801d7d:	eb c1                	jmp    801d40 <ipc_send+0x18>
    } while (r != 0);
}
  801d7f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d82:	5b                   	pop    %ebx
  801d83:	5e                   	pop    %esi
  801d84:	5f                   	pop    %edi
  801d85:	5d                   	pop    %ebp
  801d86:	c3                   	ret    

00801d87 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801d87:	55                   	push   %ebp
  801d88:	89 e5                	mov    %esp,%ebp
  801d8a:	53                   	push   %ebx
  801d8b:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801d8e:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  801d93:	39 c1                	cmp    %eax,%ecx
  801d95:	74 21                	je     801db8 <ipc_find_env+0x31>
  801d97:	ba 01 00 00 00       	mov    $0x1,%edx
  801d9c:	8d 1c 95 00 00 00 00 	lea    0x0(,%edx,4),%ebx
  801da3:	89 d0                	mov    %edx,%eax
  801da5:	c1 e0 07             	shl    $0x7,%eax
  801da8:	29 d8                	sub    %ebx,%eax
  801daa:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801daf:	8b 40 50             	mov    0x50(%eax),%eax
  801db2:	39 c8                	cmp    %ecx,%eax
  801db4:	75 1b                	jne    801dd1 <ipc_find_env+0x4a>
  801db6:	eb 05                	jmp    801dbd <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801db8:	ba 00 00 00 00       	mov    $0x0,%edx
		if (envs[i].env_type == type)
			return envs[i].env_id;
  801dbd:	8d 04 95 00 00 00 00 	lea    0x0(,%edx,4),%eax
  801dc4:	c1 e2 07             	shl    $0x7,%edx
  801dc7:	29 c2                	sub    %eax,%edx
  801dc9:	8b 82 48 00 c0 ee    	mov    -0x113fffb8(%edx),%eax
  801dcf:	eb 0e                	jmp    801ddf <ipc_find_env+0x58>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801dd1:	42                   	inc    %edx
  801dd2:	81 fa 00 04 00 00    	cmp    $0x400,%edx
  801dd8:	75 c2                	jne    801d9c <ipc_find_env+0x15>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801dda:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ddf:	5b                   	pop    %ebx
  801de0:	5d                   	pop    %ebp
  801de1:	c3                   	ret    

00801de2 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801de2:	55                   	push   %ebp
  801de3:	89 e5                	mov    %esp,%ebp
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801de5:	8b 45 08             	mov    0x8(%ebp),%eax
  801de8:	c1 e8 16             	shr    $0x16,%eax
  801deb:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801df2:	a8 01                	test   $0x1,%al
  801df4:	74 21                	je     801e17 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801df6:	8b 45 08             	mov    0x8(%ebp),%eax
  801df9:	c1 e8 0c             	shr    $0xc,%eax
  801dfc:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801e03:	a8 01                	test   $0x1,%al
  801e05:	74 17                	je     801e1e <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801e07:	c1 e8 0c             	shr    $0xc,%eax
  801e0a:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801e11:	ef 
  801e12:	0f b7 c0             	movzwl %ax,%eax
  801e15:	eb 0c                	jmp    801e23 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801e17:	b8 00 00 00 00       	mov    $0x0,%eax
  801e1c:	eb 05                	jmp    801e23 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801e1e:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801e23:	5d                   	pop    %ebp
  801e24:	c3                   	ret    
  801e25:	66 90                	xchg   %ax,%ax
  801e27:	90                   	nop

00801e28 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801e28:	55                   	push   %ebp
  801e29:	57                   	push   %edi
  801e2a:	56                   	push   %esi
  801e2b:	53                   	push   %ebx
  801e2c:	83 ec 1c             	sub    $0x1c,%esp
  801e2f:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801e33:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801e37:	8b 7c 24 38          	mov    0x38(%esp),%edi
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801e3b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801e3f:	89 ca                	mov    %ecx,%edx
  const DWunion dd = {.ll = d};
  801e41:	89 f8                	mov    %edi,%eax
  801e43:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801e47:	85 f6                	test   %esi,%esi
  801e49:	75 2d                	jne    801e78 <__udivdi3+0x50>
    {
      if (d0 > n1)
  801e4b:	39 cf                	cmp    %ecx,%edi
  801e4d:	77 65                	ja     801eb4 <__udivdi3+0x8c>
  801e4f:	89 fd                	mov    %edi,%ebp
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801e51:	85 ff                	test   %edi,%edi
  801e53:	75 0b                	jne    801e60 <__udivdi3+0x38>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801e55:	b8 01 00 00 00       	mov    $0x1,%eax
  801e5a:	31 d2                	xor    %edx,%edx
  801e5c:	f7 f7                	div    %edi
  801e5e:	89 c5                	mov    %eax,%ebp

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801e60:	31 d2                	xor    %edx,%edx
  801e62:	89 c8                	mov    %ecx,%eax
  801e64:	f7 f5                	div    %ebp
  801e66:	89 c1                	mov    %eax,%ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801e68:	89 d8                	mov    %ebx,%eax
  801e6a:	f7 f5                	div    %ebp
  801e6c:	89 cf                	mov    %ecx,%edi
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
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801e78:	39 ce                	cmp    %ecx,%esi
  801e7a:	77 28                	ja     801ea4 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801e7c:	0f bd fe             	bsr    %esi,%edi
	  if (bm == 0)
  801e7f:	83 f7 1f             	xor    $0x1f,%edi
  801e82:	75 40                	jne    801ec4 <__udivdi3+0x9c>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801e84:	39 ce                	cmp    %ecx,%esi
  801e86:	72 0a                	jb     801e92 <__udivdi3+0x6a>
  801e88:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801e8c:	0f 87 9e 00 00 00    	ja     801f30 <__udivdi3+0x108>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801e92:	b8 01 00 00 00       	mov    $0x1,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801e97:	89 fa                	mov    %edi,%edx
  801e99:	83 c4 1c             	add    $0x1c,%esp
  801e9c:	5b                   	pop    %ebx
  801e9d:	5e                   	pop    %esi
  801e9e:	5f                   	pop    %edi
  801e9f:	5d                   	pop    %ebp
  801ea0:	c3                   	ret    
  801ea1:	8d 76 00             	lea    0x0(%esi),%esi
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801ea4:	31 ff                	xor    %edi,%edi
  801ea6:	31 c0                	xor    %eax,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801ea8:	89 fa                	mov    %edi,%edx
  801eaa:	83 c4 1c             	add    $0x1c,%esp
  801ead:	5b                   	pop    %ebx
  801eae:	5e                   	pop    %esi
  801eaf:	5f                   	pop    %edi
  801eb0:	5d                   	pop    %ebp
  801eb1:	c3                   	ret    
  801eb2:	66 90                	xchg   %ax,%ax
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801eb4:	89 d8                	mov    %ebx,%eax
  801eb6:	f7 f7                	div    %edi
  801eb8:	31 ff                	xor    %edi,%edi
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801eba:	89 fa                	mov    %edi,%edx
  801ebc:	83 c4 1c             	add    $0x1c,%esp
  801ebf:	5b                   	pop    %ebx
  801ec0:	5e                   	pop    %esi
  801ec1:	5f                   	pop    %edi
  801ec2:	5d                   	pop    %ebp
  801ec3:	c3                   	ret    
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801ec4:	bd 20 00 00 00       	mov    $0x20,%ebp
  801ec9:	89 eb                	mov    %ebp,%ebx
  801ecb:	29 fb                	sub    %edi,%ebx

	      d1 = (d1 << bm) | (d0 >> b);
  801ecd:	89 f9                	mov    %edi,%ecx
  801ecf:	d3 e6                	shl    %cl,%esi
  801ed1:	89 c5                	mov    %eax,%ebp
  801ed3:	88 d9                	mov    %bl,%cl
  801ed5:	d3 ed                	shr    %cl,%ebp
  801ed7:	89 e9                	mov    %ebp,%ecx
  801ed9:	09 f1                	or     %esi,%ecx
  801edb:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
	      d0 = d0 << bm;
  801edf:	89 f9                	mov    %edi,%ecx
  801ee1:	d3 e0                	shl    %cl,%eax
  801ee3:	89 c5                	mov    %eax,%ebp
	      n2 = n1 >> b;
  801ee5:	89 d6                	mov    %edx,%esi
  801ee7:	88 d9                	mov    %bl,%cl
  801ee9:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
  801eeb:	89 f9                	mov    %edi,%ecx
  801eed:	d3 e2                	shl    %cl,%edx
  801eef:	8b 44 24 08          	mov    0x8(%esp),%eax
  801ef3:	88 d9                	mov    %bl,%cl
  801ef5:	d3 e8                	shr    %cl,%eax
  801ef7:	09 c2                	or     %eax,%edx
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801ef9:	89 d0                	mov    %edx,%eax
  801efb:	89 f2                	mov    %esi,%edx
  801efd:	f7 74 24 0c          	divl   0xc(%esp)
  801f01:	89 d6                	mov    %edx,%esi
  801f03:	89 c3                	mov    %eax,%ebx
	      umul_ppmm (m1, m0, q0, d0);
  801f05:	f7 e5                	mul    %ebp

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801f07:	39 d6                	cmp    %edx,%esi
  801f09:	72 19                	jb     801f24 <__udivdi3+0xfc>
  801f0b:	74 0b                	je     801f18 <__udivdi3+0xf0>
  801f0d:	89 d8                	mov    %ebx,%eax
  801f0f:	31 ff                	xor    %edi,%edi
  801f11:	e9 58 ff ff ff       	jmp    801e6e <__udivdi3+0x46>
  801f16:	66 90                	xchg   %ax,%ax
  801f18:	8b 54 24 08          	mov    0x8(%esp),%edx
  801f1c:	89 f9                	mov    %edi,%ecx
  801f1e:	d3 e2                	shl    %cl,%edx
  801f20:	39 c2                	cmp    %eax,%edx
  801f22:	73 e9                	jae    801f0d <__udivdi3+0xe5>
  801f24:	8d 43 ff             	lea    -0x1(%ebx),%eax
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801f27:	31 ff                	xor    %edi,%edi
  801f29:	e9 40 ff ff ff       	jmp    801e6e <__udivdi3+0x46>
  801f2e:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801f30:	31 c0                	xor    %eax,%eax
  801f32:	e9 37 ff ff ff       	jmp    801e6e <__udivdi3+0x46>
  801f37:	90                   	nop

00801f38 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  801f38:	55                   	push   %ebp
  801f39:	57                   	push   %edi
  801f3a:	56                   	push   %esi
  801f3b:	53                   	push   %ebx
  801f3c:	83 ec 1c             	sub    $0x1c,%esp
  801f3f:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801f43:	8b 74 24 34          	mov    0x34(%esp),%esi
  801f47:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801f4b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801f4f:	89 44 24 0c          	mov    %eax,0xc(%esp)
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801f53:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801f57:	89 f3                	mov    %esi,%ebx
  const DWunion dd = {.ll = d};
  801f59:	89 fa                	mov    %edi,%edx
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  801f5b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  n1 = nn.s.high;
  801f5f:	89 34 24             	mov    %esi,(%esp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801f62:	85 c0                	test   %eax,%eax
  801f64:	75 1a                	jne    801f80 <__umoddi3+0x48>
    {
      if (d0 > n1)
  801f66:	39 f7                	cmp    %esi,%edi
  801f68:	0f 86 a2 00 00 00    	jbe    802010 <__umoddi3+0xd8>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801f6e:	89 c8                	mov    %ecx,%eax
  801f70:	89 f2                	mov    %esi,%edx
  801f72:	f7 f7                	div    %edi
  801f74:	89 d0                	mov    %edx,%eax

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  801f76:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801f78:	83 c4 1c             	add    $0x1c,%esp
  801f7b:	5b                   	pop    %ebx
  801f7c:	5e                   	pop    %esi
  801f7d:	5f                   	pop    %edi
  801f7e:	5d                   	pop    %ebp
  801f7f:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801f80:	39 f0                	cmp    %esi,%eax
  801f82:	0f 87 ac 00 00 00    	ja     802034 <__umoddi3+0xfc>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801f88:	0f bd e8             	bsr    %eax,%ebp
	  if (bm == 0)
  801f8b:	83 f5 1f             	xor    $0x1f,%ebp
  801f8e:	0f 84 ac 00 00 00    	je     802040 <__umoddi3+0x108>
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801f94:	bf 20 00 00 00       	mov    $0x20,%edi
  801f99:	29 ef                	sub    %ebp,%edi
  801f9b:	89 fe                	mov    %edi,%esi
  801f9d:	89 7c 24 0c          	mov    %edi,0xc(%esp)

	      d1 = (d1 << bm) | (d0 >> b);
  801fa1:	89 e9                	mov    %ebp,%ecx
  801fa3:	d3 e0                	shl    %cl,%eax
  801fa5:	89 d7                	mov    %edx,%edi
  801fa7:	89 f1                	mov    %esi,%ecx
  801fa9:	d3 ef                	shr    %cl,%edi
  801fab:	09 c7                	or     %eax,%edi
	      d0 = d0 << bm;
  801fad:	89 e9                	mov    %ebp,%ecx
  801faf:	d3 e2                	shl    %cl,%edx
  801fb1:	89 14 24             	mov    %edx,(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801fb4:	89 d8                	mov    %ebx,%eax
  801fb6:	d3 e0                	shl    %cl,%eax
  801fb8:	89 c2                	mov    %eax,%edx
	      n0 = n0 << bm;
  801fba:	8b 44 24 08          	mov    0x8(%esp),%eax
  801fbe:	d3 e0                	shl    %cl,%eax
  801fc0:	89 44 24 04          	mov    %eax,0x4(%esp)

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801fc4:	8b 44 24 08          	mov    0x8(%esp),%eax
  801fc8:	89 f1                	mov    %esi,%ecx
  801fca:	d3 e8                	shr    %cl,%eax
  801fcc:	09 d0                	or     %edx,%eax
  801fce:	d3 eb                	shr    %cl,%ebx
  801fd0:	89 da                	mov    %ebx,%edx
  801fd2:	f7 f7                	div    %edi
  801fd4:	89 d3                	mov    %edx,%ebx
	      umul_ppmm (m1, m0, q0, d0);
  801fd6:	f7 24 24             	mull   (%esp)
  801fd9:	89 c6                	mov    %eax,%esi
  801fdb:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801fdd:	39 d3                	cmp    %edx,%ebx
  801fdf:	0f 82 87 00 00 00    	jb     80206c <__umoddi3+0x134>
  801fe5:	0f 84 91 00 00 00    	je     80207c <__umoddi3+0x144>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  801feb:	8b 54 24 04          	mov    0x4(%esp),%edx
  801fef:	29 f2                	sub    %esi,%edx
  801ff1:	19 cb                	sbb    %ecx,%ebx
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801ff3:	89 d8                	mov    %ebx,%eax
  801ff5:	8a 4c 24 0c          	mov    0xc(%esp),%cl
  801ff9:	d3 e0                	shl    %cl,%eax
  801ffb:	89 e9                	mov    %ebp,%ecx
  801ffd:	d3 ea                	shr    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  801fff:	09 d0                	or     %edx,%eax
  802001:	89 e9                	mov    %ebp,%ecx
  802003:	d3 eb                	shr    %cl,%ebx
  802005:	89 da                	mov    %ebx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802007:	83 c4 1c             	add    $0x1c,%esp
  80200a:	5b                   	pop    %ebx
  80200b:	5e                   	pop    %esi
  80200c:	5f                   	pop    %edi
  80200d:	5d                   	pop    %ebp
  80200e:	c3                   	ret    
  80200f:	90                   	nop
  802010:	89 fd                	mov    %edi,%ebp
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802012:	85 ff                	test   %edi,%edi
  802014:	75 0b                	jne    802021 <__umoddi3+0xe9>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802016:	b8 01 00 00 00       	mov    $0x1,%eax
  80201b:	31 d2                	xor    %edx,%edx
  80201d:	f7 f7                	div    %edi
  80201f:	89 c5                	mov    %eax,%ebp

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802021:	89 f0                	mov    %esi,%eax
  802023:	31 d2                	xor    %edx,%edx
  802025:	f7 f5                	div    %ebp
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802027:	89 c8                	mov    %ecx,%eax
  802029:	f7 f5                	div    %ebp
  80202b:	89 d0                	mov    %edx,%eax
  80202d:	e9 44 ff ff ff       	jmp    801f76 <__umoddi3+0x3e>
  802032:	66 90                	xchg   %ax,%ax
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  802034:	89 c8                	mov    %ecx,%eax
  802036:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802038:	83 c4 1c             	add    $0x1c,%esp
  80203b:	5b                   	pop    %ebx
  80203c:	5e                   	pop    %esi
  80203d:	5f                   	pop    %edi
  80203e:	5d                   	pop    %ebp
  80203f:	c3                   	ret    

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802040:	3b 04 24             	cmp    (%esp),%eax
  802043:	72 06                	jb     80204b <__umoddi3+0x113>
  802045:	3b 7c 24 04          	cmp    0x4(%esp),%edi
  802049:	77 0f                	ja     80205a <__umoddi3+0x122>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  80204b:	89 f2                	mov    %esi,%edx
  80204d:	29 f9                	sub    %edi,%ecx
  80204f:	1b 54 24 0c          	sbb    0xc(%esp),%edx
  802053:	89 14 24             	mov    %edx,(%esp)
  802056:	89 4c 24 04          	mov    %ecx,0x4(%esp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  80205a:	8b 44 24 04          	mov    0x4(%esp),%eax
  80205e:	8b 14 24             	mov    (%esp),%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802061:	83 c4 1c             	add    $0x1c,%esp
  802064:	5b                   	pop    %ebx
  802065:	5e                   	pop    %esi
  802066:	5f                   	pop    %edi
  802067:	5d                   	pop    %ebp
  802068:	c3                   	ret    
  802069:	8d 76 00             	lea    0x0(%esi),%esi
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  80206c:	2b 04 24             	sub    (%esp),%eax
  80206f:	19 fa                	sbb    %edi,%edx
  802071:	89 d1                	mov    %edx,%ecx
  802073:	89 c6                	mov    %eax,%esi
  802075:	e9 71 ff ff ff       	jmp    801feb <__umoddi3+0xb3>
  80207a:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80207c:	39 44 24 04          	cmp    %eax,0x4(%esp)
  802080:	72 ea                	jb     80206c <__umoddi3+0x134>
  802082:	89 d9                	mov    %ebx,%ecx
  802084:	e9 62 ff ff ff       	jmp    801feb <__umoddi3+0xb3>
