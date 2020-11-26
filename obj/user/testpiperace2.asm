
obj/user/testpiperace2.debug:     file format elf32-i386


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
  80002c:	e8 95 01 00 00       	call   8001c6 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 38             	sub    $0x38,%esp
	int p[2], r, i;
	struct Fd *fd;
	const volatile struct Env *kid;

	cprintf("testing for pipeisclosed race...\n");
  80003c:	68 40 23 80 00       	push   $0x802340
  800041:	e8 c1 02 00 00       	call   800307 <cprintf>
	if ((r = pipe(p)) < 0)
  800046:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800049:	89 04 24             	mov    %eax,(%esp)
  80004c:	e8 61 1b 00 00       	call   801bb2 <pipe>
  800051:	83 c4 10             	add    $0x10,%esp
  800054:	85 c0                	test   %eax,%eax
  800056:	79 12                	jns    80006a <umain+0x37>
		panic("pipe: %e", r);
  800058:	50                   	push   %eax
  800059:	68 8e 23 80 00       	push   $0x80238e
  80005e:	6a 0d                	push   $0xd
  800060:	68 97 23 80 00       	push   $0x802397
  800065:	e8 c5 01 00 00       	call   80022f <_panic>
	if ((r = fork()) < 0)
  80006a:	e8 cd 0f 00 00       	call   80103c <fork>
  80006f:	89 c6                	mov    %eax,%esi
  800071:	85 c0                	test   %eax,%eax
  800073:	79 12                	jns    800087 <umain+0x54>
		panic("fork: %e", r);
  800075:	50                   	push   %eax
  800076:	68 ac 23 80 00       	push   $0x8023ac
  80007b:	6a 0f                	push   $0xf
  80007d:	68 97 23 80 00       	push   $0x802397
  800082:	e8 a8 01 00 00       	call   80022f <_panic>
	if (r == 0) {
  800087:	85 c0                	test   %eax,%eax
  800089:	75 66                	jne    8000f1 <umain+0xbe>
		// child just dups and closes repeatedly,
		// yielding so the parent can see
		// the fd state between the two.
		close(p[1]);
  80008b:	83 ec 0c             	sub    $0xc,%esp
  80008e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800091:	e8 76 13 00 00       	call   80140c <close>
  800096:	83 c4 10             	add    $0x10,%esp
		for (i = 0; i < 200; i++) {
  800099:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (i % 10 == 0)
  80009e:	bf 0a 00 00 00       	mov    $0xa,%edi
  8000a3:	89 d8                	mov    %ebx,%eax
  8000a5:	99                   	cltd   
  8000a6:	f7 ff                	idiv   %edi
  8000a8:	85 d2                	test   %edx,%edx
  8000aa:	75 11                	jne    8000bd <umain+0x8a>
				cprintf("%d.", i);
  8000ac:	83 ec 08             	sub    $0x8,%esp
  8000af:	53                   	push   %ebx
  8000b0:	68 b5 23 80 00       	push   $0x8023b5
  8000b5:	e8 4d 02 00 00       	call   800307 <cprintf>
  8000ba:	83 c4 10             	add    $0x10,%esp
			// dup, then close.  yield so that other guy will
			// see us while we're between them.
			dup(p[0], 10);
  8000bd:	83 ec 08             	sub    $0x8,%esp
  8000c0:	6a 0a                	push   $0xa
  8000c2:	ff 75 e0             	pushl  -0x20(%ebp)
  8000c5:	e8 90 13 00 00       	call   80145a <dup>
			sys_yield();
  8000ca:	e8 6e 0c 00 00       	call   800d3d <sys_yield>
			close(10);
  8000cf:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  8000d6:	e8 31 13 00 00       	call   80140c <close>
			sys_yield();
  8000db:	e8 5d 0c 00 00       	call   800d3d <sys_yield>
	if (r == 0) {
		// child just dups and closes repeatedly,
		// yielding so the parent can see
		// the fd state between the two.
		close(p[1]);
		for (i = 0; i < 200; i++) {
  8000e0:	43                   	inc    %ebx
  8000e1:	83 c4 10             	add    $0x10,%esp
  8000e4:	81 fb c8 00 00 00    	cmp    $0xc8,%ebx
  8000ea:	75 b7                	jne    8000a3 <umain+0x70>
			dup(p[0], 10);
			sys_yield();
			close(10);
			sys_yield();
		}
		exit();
  8000ec:	e8 24 01 00 00       	call   800215 <exit>
	// pageref(p[0]) and gets 3, then it will return true when
	// it shouldn't.
	//
	// So either way, pipeisclosed is going give a wrong answer.
	//
	kid = &envs[ENVX(r)];
  8000f1:	89 f0                	mov    %esi,%eax
  8000f3:	25 ff 03 00 00       	and    $0x3ff,%eax
	while (kid->env_status == ENV_RUNNABLE)
  8000f8:	8d 3c 85 00 00 00 00 	lea    0x0(,%eax,4),%edi
  8000ff:	c1 e0 07             	shl    $0x7,%eax
  800102:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800105:	eb 2f                	jmp    800136 <umain+0x103>
		if (pipeisclosed(p[0]) != 0) {
  800107:	83 ec 0c             	sub    $0xc,%esp
  80010a:	ff 75 e0             	pushl  -0x20(%ebp)
  80010d:	e8 ed 1b 00 00       	call   801cff <pipeisclosed>
  800112:	83 c4 10             	add    $0x10,%esp
  800115:	85 c0                	test   %eax,%eax
  800117:	74 28                	je     800141 <umain+0x10e>
			cprintf("\nRACE: pipe appears closed\n");
  800119:	83 ec 0c             	sub    $0xc,%esp
  80011c:	68 b9 23 80 00       	push   $0x8023b9
  800121:	e8 e1 01 00 00       	call   800307 <cprintf>
			sys_env_destroy(r);
  800126:	89 34 24             	mov    %esi,(%esp)
  800129:	e8 af 0b 00 00       	call   800cdd <sys_env_destroy>
			exit();
  80012e:	e8 e2 00 00 00       	call   800215 <exit>
  800133:	83 c4 10             	add    $0x10,%esp
	// it shouldn't.
	//
	// So either way, pipeisclosed is going give a wrong answer.
	//
	kid = &envs[ENVX(r)];
	while (kid->env_status == ENV_RUNNABLE)
  800136:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800139:	29 fb                	sub    %edi,%ebx
  80013b:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  800141:	8b 43 54             	mov    0x54(%ebx),%eax
  800144:	83 f8 02             	cmp    $0x2,%eax
  800147:	74 be                	je     800107 <umain+0xd4>
		if (pipeisclosed(p[0]) != 0) {
			cprintf("\nRACE: pipe appears closed\n");
			sys_env_destroy(r);
			exit();
		}
	cprintf("child done with loop\n");
  800149:	83 ec 0c             	sub    $0xc,%esp
  80014c:	68 d5 23 80 00       	push   $0x8023d5
  800151:	e8 b1 01 00 00       	call   800307 <cprintf>
	if (pipeisclosed(p[0]))
  800156:	83 c4 04             	add    $0x4,%esp
  800159:	ff 75 e0             	pushl  -0x20(%ebp)
  80015c:	e8 9e 1b 00 00       	call   801cff <pipeisclosed>
  800161:	83 c4 10             	add    $0x10,%esp
  800164:	85 c0                	test   %eax,%eax
  800166:	74 14                	je     80017c <umain+0x149>
		panic("somehow the other end of p[0] got closed!");
  800168:	83 ec 04             	sub    $0x4,%esp
  80016b:	68 64 23 80 00       	push   $0x802364
  800170:	6a 40                	push   $0x40
  800172:	68 97 23 80 00       	push   $0x802397
  800177:	e8 b3 00 00 00       	call   80022f <_panic>
	if ((r = fd_lookup(p[0], &fd)) < 0)
  80017c:	83 ec 08             	sub    $0x8,%esp
  80017f:	8d 45 dc             	lea    -0x24(%ebp),%eax
  800182:	50                   	push   %eax
  800183:	ff 75 e0             	pushl  -0x20(%ebp)
  800186:	e8 38 11 00 00       	call   8012c3 <fd_lookup>
  80018b:	83 c4 10             	add    $0x10,%esp
  80018e:	85 c0                	test   %eax,%eax
  800190:	79 12                	jns    8001a4 <umain+0x171>
		panic("cannot look up p[0]: %e", r);
  800192:	50                   	push   %eax
  800193:	68 eb 23 80 00       	push   $0x8023eb
  800198:	6a 42                	push   $0x42
  80019a:	68 97 23 80 00       	push   $0x802397
  80019f:	e8 8b 00 00 00       	call   80022f <_panic>
	(void) fd2data(fd);
  8001a4:	83 ec 0c             	sub    $0xc,%esp
  8001a7:	ff 75 dc             	pushl  -0x24(%ebp)
  8001aa:	e8 89 10 00 00       	call   801238 <fd2data>
	cprintf("race didn't happen\n");
  8001af:	c7 04 24 03 24 80 00 	movl   $0x802403,(%esp)
  8001b6:	e8 4c 01 00 00       	call   800307 <cprintf>
}
  8001bb:	83 c4 10             	add    $0x10,%esp
  8001be:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001c1:	5b                   	pop    %ebx
  8001c2:	5e                   	pop    %esi
  8001c3:	5f                   	pop    %edi
  8001c4:	5d                   	pop    %ebp
  8001c5:	c3                   	ret    

008001c6 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001c6:	55                   	push   %ebp
  8001c7:	89 e5                	mov    %esp,%ebp
  8001c9:	56                   	push   %esi
  8001ca:	53                   	push   %ebx
  8001cb:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001ce:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8001d1:	e8 48 0b 00 00       	call   800d1e <sys_getenvid>
  8001d6:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001db:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8001e2:	c1 e0 07             	shl    $0x7,%eax
  8001e5:	29 d0                	sub    %edx,%eax
  8001e7:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001ec:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001f1:	85 db                	test   %ebx,%ebx
  8001f3:	7e 07                	jle    8001fc <libmain+0x36>
		binaryname = argv[0];
  8001f5:	8b 06                	mov    (%esi),%eax
  8001f7:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8001fc:	83 ec 08             	sub    $0x8,%esp
  8001ff:	56                   	push   %esi
  800200:	53                   	push   %ebx
  800201:	e8 2d fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800206:	e8 0a 00 00 00       	call   800215 <exit>
}
  80020b:	83 c4 10             	add    $0x10,%esp
  80020e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800211:	5b                   	pop    %ebx
  800212:	5e                   	pop    %esi
  800213:	5d                   	pop    %ebp
  800214:	c3                   	ret    

00800215 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800215:	55                   	push   %ebp
  800216:	89 e5                	mov    %esp,%ebp
  800218:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80021b:	e8 17 12 00 00       	call   801437 <close_all>
	sys_env_destroy(0);
  800220:	83 ec 0c             	sub    $0xc,%esp
  800223:	6a 00                	push   $0x0
  800225:	e8 b3 0a 00 00       	call   800cdd <sys_env_destroy>
}
  80022a:	83 c4 10             	add    $0x10,%esp
  80022d:	c9                   	leave  
  80022e:	c3                   	ret    

0080022f <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80022f:	55                   	push   %ebp
  800230:	89 e5                	mov    %esp,%ebp
  800232:	56                   	push   %esi
  800233:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800234:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800237:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80023d:	e8 dc 0a 00 00       	call   800d1e <sys_getenvid>
  800242:	83 ec 0c             	sub    $0xc,%esp
  800245:	ff 75 0c             	pushl  0xc(%ebp)
  800248:	ff 75 08             	pushl  0x8(%ebp)
  80024b:	56                   	push   %esi
  80024c:	50                   	push   %eax
  80024d:	68 24 24 80 00       	push   $0x802424
  800252:	e8 b0 00 00 00       	call   800307 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800257:	83 c4 18             	add    $0x18,%esp
  80025a:	53                   	push   %ebx
  80025b:	ff 75 10             	pushl  0x10(%ebp)
  80025e:	e8 53 00 00 00       	call   8002b6 <vcprintf>
	cprintf("\n");
  800263:	c7 04 24 ab 27 80 00 	movl   $0x8027ab,(%esp)
  80026a:	e8 98 00 00 00       	call   800307 <cprintf>
  80026f:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800272:	cc                   	int3   
  800273:	eb fd                	jmp    800272 <_panic+0x43>

00800275 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800275:	55                   	push   %ebp
  800276:	89 e5                	mov    %esp,%ebp
  800278:	53                   	push   %ebx
  800279:	83 ec 04             	sub    $0x4,%esp
  80027c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80027f:	8b 13                	mov    (%ebx),%edx
  800281:	8d 42 01             	lea    0x1(%edx),%eax
  800284:	89 03                	mov    %eax,(%ebx)
  800286:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800289:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80028d:	3d ff 00 00 00       	cmp    $0xff,%eax
  800292:	75 1a                	jne    8002ae <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800294:	83 ec 08             	sub    $0x8,%esp
  800297:	68 ff 00 00 00       	push   $0xff
  80029c:	8d 43 08             	lea    0x8(%ebx),%eax
  80029f:	50                   	push   %eax
  8002a0:	e8 fb 09 00 00       	call   800ca0 <sys_cputs>
		b->idx = 0;
  8002a5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8002ab:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8002ae:	ff 43 04             	incl   0x4(%ebx)
}
  8002b1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8002b4:	c9                   	leave  
  8002b5:	c3                   	ret    

008002b6 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002b6:	55                   	push   %ebp
  8002b7:	89 e5                	mov    %esp,%ebp
  8002b9:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8002bf:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002c6:	00 00 00 
	b.cnt = 0;
  8002c9:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002d0:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002d3:	ff 75 0c             	pushl  0xc(%ebp)
  8002d6:	ff 75 08             	pushl  0x8(%ebp)
  8002d9:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002df:	50                   	push   %eax
  8002e0:	68 75 02 80 00       	push   $0x800275
  8002e5:	e8 54 01 00 00       	call   80043e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002ea:	83 c4 08             	add    $0x8,%esp
  8002ed:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8002f3:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002f9:	50                   	push   %eax
  8002fa:	e8 a1 09 00 00       	call   800ca0 <sys_cputs>

	return b.cnt;
}
  8002ff:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800305:	c9                   	leave  
  800306:	c3                   	ret    

00800307 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800307:	55                   	push   %ebp
  800308:	89 e5                	mov    %esp,%ebp
  80030a:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80030d:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800310:	50                   	push   %eax
  800311:	ff 75 08             	pushl  0x8(%ebp)
  800314:	e8 9d ff ff ff       	call   8002b6 <vcprintf>
	va_end(ap);

	return cnt;
}
  800319:	c9                   	leave  
  80031a:	c3                   	ret    

0080031b <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80031b:	55                   	push   %ebp
  80031c:	89 e5                	mov    %esp,%ebp
  80031e:	57                   	push   %edi
  80031f:	56                   	push   %esi
  800320:	53                   	push   %ebx
  800321:	83 ec 1c             	sub    $0x1c,%esp
  800324:	89 c6                	mov    %eax,%esi
  800326:	89 d7                	mov    %edx,%edi
  800328:	8b 45 08             	mov    0x8(%ebp),%eax
  80032b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80032e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800331:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800334:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800337:	bb 00 00 00 00       	mov    $0x0,%ebx
  80033c:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80033f:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800342:	39 d3                	cmp    %edx,%ebx
  800344:	72 11                	jb     800357 <printnum+0x3c>
  800346:	39 45 10             	cmp    %eax,0x10(%ebp)
  800349:	76 0c                	jbe    800357 <printnum+0x3c>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80034b:	8b 45 14             	mov    0x14(%ebp),%eax
  80034e:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800351:	85 db                	test   %ebx,%ebx
  800353:	7f 37                	jg     80038c <printnum+0x71>
  800355:	eb 44                	jmp    80039b <printnum+0x80>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800357:	83 ec 0c             	sub    $0xc,%esp
  80035a:	ff 75 18             	pushl  0x18(%ebp)
  80035d:	8b 45 14             	mov    0x14(%ebp),%eax
  800360:	48                   	dec    %eax
  800361:	50                   	push   %eax
  800362:	ff 75 10             	pushl  0x10(%ebp)
  800365:	83 ec 08             	sub    $0x8,%esp
  800368:	ff 75 e4             	pushl  -0x1c(%ebp)
  80036b:	ff 75 e0             	pushl  -0x20(%ebp)
  80036e:	ff 75 dc             	pushl  -0x24(%ebp)
  800371:	ff 75 d8             	pushl  -0x28(%ebp)
  800374:	e8 57 1d 00 00       	call   8020d0 <__udivdi3>
  800379:	83 c4 18             	add    $0x18,%esp
  80037c:	52                   	push   %edx
  80037d:	50                   	push   %eax
  80037e:	89 fa                	mov    %edi,%edx
  800380:	89 f0                	mov    %esi,%eax
  800382:	e8 94 ff ff ff       	call   80031b <printnum>
  800387:	83 c4 20             	add    $0x20,%esp
  80038a:	eb 0f                	jmp    80039b <printnum+0x80>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80038c:	83 ec 08             	sub    $0x8,%esp
  80038f:	57                   	push   %edi
  800390:	ff 75 18             	pushl  0x18(%ebp)
  800393:	ff d6                	call   *%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800395:	83 c4 10             	add    $0x10,%esp
  800398:	4b                   	dec    %ebx
  800399:	75 f1                	jne    80038c <printnum+0x71>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80039b:	83 ec 08             	sub    $0x8,%esp
  80039e:	57                   	push   %edi
  80039f:	83 ec 04             	sub    $0x4,%esp
  8003a2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003a5:	ff 75 e0             	pushl  -0x20(%ebp)
  8003a8:	ff 75 dc             	pushl  -0x24(%ebp)
  8003ab:	ff 75 d8             	pushl  -0x28(%ebp)
  8003ae:	e8 2d 1e 00 00       	call   8021e0 <__umoddi3>
  8003b3:	83 c4 14             	add    $0x14,%esp
  8003b6:	0f be 80 47 24 80 00 	movsbl 0x802447(%eax),%eax
  8003bd:	50                   	push   %eax
  8003be:	ff d6                	call   *%esi
}
  8003c0:	83 c4 10             	add    $0x10,%esp
  8003c3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003c6:	5b                   	pop    %ebx
  8003c7:	5e                   	pop    %esi
  8003c8:	5f                   	pop    %edi
  8003c9:	5d                   	pop    %ebp
  8003ca:	c3                   	ret    

008003cb <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003cb:	55                   	push   %ebp
  8003cc:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003ce:	83 fa 01             	cmp    $0x1,%edx
  8003d1:	7e 0e                	jle    8003e1 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003d3:	8b 10                	mov    (%eax),%edx
  8003d5:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003d8:	89 08                	mov    %ecx,(%eax)
  8003da:	8b 02                	mov    (%edx),%eax
  8003dc:	8b 52 04             	mov    0x4(%edx),%edx
  8003df:	eb 22                	jmp    800403 <getuint+0x38>
	else if (lflag)
  8003e1:	85 d2                	test   %edx,%edx
  8003e3:	74 10                	je     8003f5 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003e5:	8b 10                	mov    (%eax),%edx
  8003e7:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003ea:	89 08                	mov    %ecx,(%eax)
  8003ec:	8b 02                	mov    (%edx),%eax
  8003ee:	ba 00 00 00 00       	mov    $0x0,%edx
  8003f3:	eb 0e                	jmp    800403 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003f5:	8b 10                	mov    (%eax),%edx
  8003f7:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003fa:	89 08                	mov    %ecx,(%eax)
  8003fc:	8b 02                	mov    (%edx),%eax
  8003fe:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800403:	5d                   	pop    %ebp
  800404:	c3                   	ret    

00800405 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800405:	55                   	push   %ebp
  800406:	89 e5                	mov    %esp,%ebp
  800408:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80040b:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  80040e:	8b 10                	mov    (%eax),%edx
  800410:	3b 50 04             	cmp    0x4(%eax),%edx
  800413:	73 0a                	jae    80041f <sprintputch+0x1a>
		*b->buf++ = ch;
  800415:	8d 4a 01             	lea    0x1(%edx),%ecx
  800418:	89 08                	mov    %ecx,(%eax)
  80041a:	8b 45 08             	mov    0x8(%ebp),%eax
  80041d:	88 02                	mov    %al,(%edx)
}
  80041f:	5d                   	pop    %ebp
  800420:	c3                   	ret    

00800421 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800421:	55                   	push   %ebp
  800422:	89 e5                	mov    %esp,%ebp
  800424:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800427:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80042a:	50                   	push   %eax
  80042b:	ff 75 10             	pushl  0x10(%ebp)
  80042e:	ff 75 0c             	pushl  0xc(%ebp)
  800431:	ff 75 08             	pushl  0x8(%ebp)
  800434:	e8 05 00 00 00       	call   80043e <vprintfmt>
	va_end(ap);
}
  800439:	83 c4 10             	add    $0x10,%esp
  80043c:	c9                   	leave  
  80043d:	c3                   	ret    

0080043e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80043e:	55                   	push   %ebp
  80043f:	89 e5                	mov    %esp,%ebp
  800441:	57                   	push   %edi
  800442:	56                   	push   %esi
  800443:	53                   	push   %ebx
  800444:	83 ec 2c             	sub    $0x2c,%esp
  800447:	8b 7d 08             	mov    0x8(%ebp),%edi
  80044a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80044d:	eb 03                	jmp    800452 <vprintfmt+0x14>
			break;

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
			for (fmt--; fmt[-1] != '%'; fmt--)
  80044f:	89 75 10             	mov    %esi,0x10(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {    //遍历输入的第一个参数，即输出信息的格式，先把格式字符串中'%'之前的字符一个个输出，因为它们前面没有'%'，所以它们就是要直接显示在屏幕上的
  800452:	8b 45 10             	mov    0x10(%ebp),%eax
  800455:	8d 70 01             	lea    0x1(%eax),%esi
  800458:	0f b6 00             	movzbl (%eax),%eax
  80045b:	83 f8 25             	cmp    $0x25,%eax
  80045e:	74 25                	je     800485 <vprintfmt+0x47>
			if (ch == '\0')									//当然中间如果遇到'\0'，代表这个字符串的访问结束
  800460:	85 c0                	test   %eax,%eax
  800462:	75 0d                	jne    800471 <vprintfmt+0x33>
  800464:	e9 b5 03 00 00       	jmp    80081e <vprintfmt+0x3e0>
  800469:	85 c0                	test   %eax,%eax
  80046b:	0f 84 ad 03 00 00    	je     80081e <vprintfmt+0x3e0>
				return;
			putch(ch, putdat);								//调用putch函数，把一个字符ch输出到putdat指针所指向的地址中所存放的值对应的地址处
  800471:	83 ec 08             	sub    $0x8,%esp
  800474:	53                   	push   %ebx
  800475:	50                   	push   %eax
  800476:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {    //遍历输入的第一个参数，即输出信息的格式，先把格式字符串中'%'之前的字符一个个输出，因为它们前面没有'%'，所以它们就是要直接显示在屏幕上的
  800478:	46                   	inc    %esi
  800479:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  80047d:	83 c4 10             	add    $0x10,%esp
  800480:	83 f8 25             	cmp    $0x25,%eax
  800483:	75 e4                	jne    800469 <vprintfmt+0x2b>
			if (width < 0)									//代表有小数点，但是小数点前面并没有数字，比如'%.6f'这种情况，此时代表整数部分全部显示
				width = 0;			
			goto reswitch;

		case '#':
			altflag = 1;
  800485:	c6 45 e3 20          	movb   $0x20,-0x1d(%ebp)
  800489:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800490:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800497:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80049e:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8004a5:	eb 07                	jmp    8004ae <vprintfmt+0x70>
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  8004a7:	8b 75 10             	mov    0x10(%ebp),%esi

		// flag to pad on the right
		case '-':											//%后面的'-'代表要进行左对齐输出，右边填空格，如果省略代表右对齐
			padc = '-';										//如果有这个字符代表左对齐，则把对齐方式标志位变为'-'
  8004aa:	c6 45 e3 2d          	movb   $0x2d,-0x1d(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  8004ae:	8d 46 01             	lea    0x1(%esi),%eax
  8004b1:	89 45 10             	mov    %eax,0x10(%ebp)
  8004b4:	0f b6 16             	movzbl (%esi),%edx
  8004b7:	8a 06                	mov    (%esi),%al
  8004b9:	83 e8 23             	sub    $0x23,%eax
  8004bc:	3c 55                	cmp    $0x55,%al
  8004be:	0f 87 03 03 00 00    	ja     8007c7 <vprintfmt+0x389>
  8004c4:	0f b6 c0             	movzbl %al,%eax
  8004c7:	ff 24 85 80 25 80 00 	jmp    *0x802580(,%eax,4)
  8004ce:	8b 75 10             	mov    0x10(%ebp),%esi
			padc = '-';										//如果有这个字符代表左对齐，则把对齐方式标志位变为'-'
			goto reswitch;									//处理下一个字符

		// flag to pad with 0's instead of spaces
		case '0':											//0--有0表示进行对齐输出时填0,如省略表示填入空格，并且如果为0，则一定是右对齐
			padc = '0';										//对其方式标志位变为0
  8004d1:	c6 45 e3 30          	movb   $0x30,-0x1d(%ebp)
  8004d5:	eb d7                	jmp    8004ae <vprintfmt+0x70>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {					//把遇到的位数字符串转换为真实的位数，比如输入的'%40'，代表有效位数为40位，下面的循环就是把precesion的值设置为40
				precision = precision * 10 + ch - '0';
  8004d7:	8d 42 d0             	lea    -0x30(%edx),%eax
  8004da:	89 c1                	mov    %eax,%ecx
  8004dc:	89 45 d0             	mov    %eax,-0x30(%ebp)
				ch = *fmt;
  8004df:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  8004e3:	8d 50 d0             	lea    -0x30(%eax),%edx
  8004e6:	83 fa 09             	cmp    $0x9,%edx
  8004e9:	77 51                	ja     80053c <vprintfmt+0xfe>
  8004eb:	8b 75 10             	mov    0x10(%ebp),%esi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {					//把遇到的位数字符串转换为真实的位数，比如输入的'%40'，代表有效位数为40位，下面的循环就是把precesion的值设置为40
  8004ee:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  8004ef:	8d 14 89             	lea    (%ecx,%ecx,4),%edx
  8004f2:	01 d2                	add    %edx,%edx
  8004f4:	8d 4c 10 d0          	lea    -0x30(%eax,%edx,1),%ecx
				ch = *fmt;
  8004f8:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8004fb:	8d 50 d0             	lea    -0x30(%eax),%edx
  8004fe:	83 fa 09             	cmp    $0x9,%edx
  800501:	76 eb                	jbe    8004ee <vprintfmt+0xb0>
  800503:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800506:	eb 37                	jmp    80053f <vprintfmt+0x101>
					break;
			}
			goto process_precision;							//跳转到process_precistion子过程

		case '*':											//*--代表有效数字的位数也是由输入参数指定的，比如printf("%*.*f", 10, 2, n)，其中10,2就是用来指定显示的有效数字位数的
			precision = va_arg(ap, int);
  800508:	8b 45 14             	mov    0x14(%ebp),%eax
  80050b:	8d 50 04             	lea    0x4(%eax),%edx
  80050e:	89 55 14             	mov    %edx,0x14(%ebp)
  800511:	8b 00                	mov    (%eax),%eax
  800513:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  800516:	8b 75 10             	mov    0x10(%ebp),%esi
			}
			goto process_precision;							//跳转到process_precistion子过程

		case '*':											//*--代表有效数字的位数也是由输入参数指定的，比如printf("%*.*f", 10, 2, n)，其中10,2就是用来指定显示的有效数字位数的
			precision = va_arg(ap, int);
			goto process_precision;
  800519:	eb 24                	jmp    80053f <vprintfmt+0x101>
  80051b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80051f:	79 07                	jns    800528 <vprintfmt+0xea>
  800521:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  800528:	8b 75 10             	mov    0x10(%ebp),%esi
  80052b:	eb 81                	jmp    8004ae <vprintfmt+0x70>
  80052d:	8b 75 10             	mov    0x10(%ebp),%esi
			if (width < 0)									//代表有小数点，但是小数点前面并没有数字，比如'%.6f'这种情况，此时代表整数部分全部显示
				width = 0;			
			goto reswitch;

		case '#':
			altflag = 1;
  800530:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800537:	e9 72 ff ff ff       	jmp    8004ae <vprintfmt+0x70>
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  80053c:	8b 75 10             	mov    0x10(%ebp),%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:									//处理输出精度，把width字段赋值为刚刚计算出来的precision值，所以width应该是整数部分的有效数字位数
			if (width < 0)
  80053f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800543:	0f 89 65 ff ff ff    	jns    8004ae <vprintfmt+0x70>
				width = precision, precision = -1;
  800549:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80054c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80054f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800556:	e9 53 ff ff ff       	jmp    8004ae <vprintfmt+0x70>
			goto reswitch;

		// long flag (doubled for long long)				
		case 'l':											//如果遇到'l'，代表应该是输入long类型，如果有两个'l'代表long long
			lflag++;										//此时把lflag++
  80055b:	ff 45 d4             	incl   -0x2c(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  80055e:	8b 75 10             	mov    0x10(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)				
		case 'l':											//如果遇到'l'，代表应该是输入long类型，如果有两个'l'代表long long
			lflag++;										//此时把lflag++
			goto reswitch;
  800561:	e9 48 ff ff ff       	jmp    8004ae <vprintfmt+0x70>

		// character
		case 'c':											//如果是'c'代表显示一个字符
			putch(va_arg(ap, int), putdat);					//调用输出一个字符到内存的函数putch
  800566:	8b 45 14             	mov    0x14(%ebp),%eax
  800569:	8d 50 04             	lea    0x4(%eax),%edx
  80056c:	89 55 14             	mov    %edx,0x14(%ebp)
  80056f:	83 ec 08             	sub    $0x8,%esp
  800572:	53                   	push   %ebx
  800573:	ff 30                	pushl  (%eax)
  800575:	ff d7                	call   *%edi
			break;
  800577:	83 c4 10             	add    $0x10,%esp
  80057a:	e9 d3 fe ff ff       	jmp    800452 <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80057f:	8b 45 14             	mov    0x14(%ebp),%eax
  800582:	8d 50 04             	lea    0x4(%eax),%edx
  800585:	89 55 14             	mov    %edx,0x14(%ebp)
  800588:	8b 00                	mov    (%eax),%eax
  80058a:	85 c0                	test   %eax,%eax
  80058c:	79 02                	jns    800590 <vprintfmt+0x152>
  80058e:	f7 d8                	neg    %eax
  800590:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800592:	83 f8 0f             	cmp    $0xf,%eax
  800595:	7f 0b                	jg     8005a2 <vprintfmt+0x164>
  800597:	8b 04 85 e0 26 80 00 	mov    0x8026e0(,%eax,4),%eax
  80059e:	85 c0                	test   %eax,%eax
  8005a0:	75 15                	jne    8005b7 <vprintfmt+0x179>
				printfmt(putch, putdat, "error %d", err);
  8005a2:	52                   	push   %edx
  8005a3:	68 5f 24 80 00       	push   $0x80245f
  8005a8:	53                   	push   %ebx
  8005a9:	57                   	push   %edi
  8005aa:	e8 72 fe ff ff       	call   800421 <printfmt>
  8005af:	83 c4 10             	add    $0x10,%esp
  8005b2:	e9 9b fe ff ff       	jmp    800452 <vprintfmt+0x14>
			else
				printfmt(putch, putdat, "%s", p);
  8005b7:	50                   	push   %eax
  8005b8:	68 ea 28 80 00       	push   $0x8028ea
  8005bd:	53                   	push   %ebx
  8005be:	57                   	push   %edi
  8005bf:	e8 5d fe ff ff       	call   800421 <printfmt>
  8005c4:	83 c4 10             	add    $0x10,%esp
  8005c7:	e9 86 fe ff ff       	jmp    800452 <vprintfmt+0x14>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cf:	8d 50 04             	lea    0x4(%eax),%edx
  8005d2:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d5:	8b 00                	mov    (%eax),%eax
  8005d7:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8005da:	85 c0                	test   %eax,%eax
  8005dc:	75 07                	jne    8005e5 <vprintfmt+0x1a7>
				p = "(null)";
  8005de:	c7 45 d4 58 24 80 00 	movl   $0x802458,-0x2c(%ebp)
			if (width > 0 && padc != '-')
  8005e5:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8005e8:	85 f6                	test   %esi,%esi
  8005ea:	0f 8e fb 01 00 00    	jle    8007eb <vprintfmt+0x3ad>
  8005f0:	80 7d e3 2d          	cmpb   $0x2d,-0x1d(%ebp)
  8005f4:	0f 84 09 02 00 00    	je     800803 <vprintfmt+0x3c5>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005fa:	83 ec 08             	sub    $0x8,%esp
  8005fd:	ff 75 d0             	pushl  -0x30(%ebp)
  800600:	ff 75 d4             	pushl  -0x2c(%ebp)
  800603:	e8 ad 02 00 00       	call   8008b5 <strnlen>
  800608:	89 f1                	mov    %esi,%ecx
  80060a:	29 c1                	sub    %eax,%ecx
  80060c:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  80060f:	83 c4 10             	add    $0x10,%esp
  800612:	85 c9                	test   %ecx,%ecx
  800614:	0f 8e d1 01 00 00    	jle    8007eb <vprintfmt+0x3ad>
					putch(padc, putdat);
  80061a:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  80061e:	83 ec 08             	sub    $0x8,%esp
  800621:	53                   	push   %ebx
  800622:	56                   	push   %esi
  800623:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800625:	83 c4 10             	add    $0x10,%esp
  800628:	ff 4d e4             	decl   -0x1c(%ebp)
  80062b:	75 f1                	jne    80061e <vprintfmt+0x1e0>
  80062d:	e9 b9 01 00 00       	jmp    8007eb <vprintfmt+0x3ad>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800632:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800636:	74 19                	je     800651 <vprintfmt+0x213>
  800638:	0f be c0             	movsbl %al,%eax
  80063b:	83 e8 20             	sub    $0x20,%eax
  80063e:	83 f8 5e             	cmp    $0x5e,%eax
  800641:	76 0e                	jbe    800651 <vprintfmt+0x213>
					putch('?', putdat);
  800643:	83 ec 08             	sub    $0x8,%esp
  800646:	53                   	push   %ebx
  800647:	6a 3f                	push   $0x3f
  800649:	ff 55 08             	call   *0x8(%ebp)
  80064c:	83 c4 10             	add    $0x10,%esp
  80064f:	eb 0b                	jmp    80065c <vprintfmt+0x21e>
				else
					putch(ch, putdat);
  800651:	83 ec 08             	sub    $0x8,%esp
  800654:	53                   	push   %ebx
  800655:	52                   	push   %edx
  800656:	ff 55 08             	call   *0x8(%ebp)
  800659:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80065c:	ff 4d e4             	decl   -0x1c(%ebp)
  80065f:	46                   	inc    %esi
  800660:	8a 46 ff             	mov    -0x1(%esi),%al
  800663:	0f be d0             	movsbl %al,%edx
  800666:	85 d2                	test   %edx,%edx
  800668:	75 1c                	jne    800686 <vprintfmt+0x248>
  80066a:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80066d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800671:	7f 1f                	jg     800692 <vprintfmt+0x254>
  800673:	e9 da fd ff ff       	jmp    800452 <vprintfmt+0x14>
  800678:	89 7d 08             	mov    %edi,0x8(%ebp)
  80067b:	8b 7d d0             	mov    -0x30(%ebp),%edi
  80067e:	eb 06                	jmp    800686 <vprintfmt+0x248>
  800680:	89 7d 08             	mov    %edi,0x8(%ebp)
  800683:	8b 7d d0             	mov    -0x30(%ebp),%edi
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800686:	85 ff                	test   %edi,%edi
  800688:	78 a8                	js     800632 <vprintfmt+0x1f4>
  80068a:	4f                   	dec    %edi
  80068b:	79 a5                	jns    800632 <vprintfmt+0x1f4>
  80068d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800690:	eb db                	jmp    80066d <vprintfmt+0x22f>
  800692:	8b 75 e4             	mov    -0x1c(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800695:	83 ec 08             	sub    $0x8,%esp
  800698:	53                   	push   %ebx
  800699:	6a 20                	push   $0x20
  80069b:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80069d:	4e                   	dec    %esi
  80069e:	83 c4 10             	add    $0x10,%esp
  8006a1:	85 f6                	test   %esi,%esi
  8006a3:	7f f0                	jg     800695 <vprintfmt+0x257>
  8006a5:	e9 a8 fd ff ff       	jmp    800452 <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006aa:	83 7d d4 01          	cmpl   $0x1,-0x2c(%ebp)
  8006ae:	7e 16                	jle    8006c6 <vprintfmt+0x288>
		return va_arg(*ap, long long);
  8006b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b3:	8d 50 08             	lea    0x8(%eax),%edx
  8006b6:	89 55 14             	mov    %edx,0x14(%ebp)
  8006b9:	8b 50 04             	mov    0x4(%eax),%edx
  8006bc:	8b 00                	mov    (%eax),%eax
  8006be:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006c1:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006c4:	eb 34                	jmp    8006fa <vprintfmt+0x2bc>
	else if (lflag)
  8006c6:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8006ca:	74 18                	je     8006e4 <vprintfmt+0x2a6>
		return va_arg(*ap, long);
  8006cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8006cf:	8d 50 04             	lea    0x4(%eax),%edx
  8006d2:	89 55 14             	mov    %edx,0x14(%ebp)
  8006d5:	8b 30                	mov    (%eax),%esi
  8006d7:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8006da:	89 f0                	mov    %esi,%eax
  8006dc:	c1 f8 1f             	sar    $0x1f,%eax
  8006df:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8006e2:	eb 16                	jmp    8006fa <vprintfmt+0x2bc>
	else
		return va_arg(*ap, int);
  8006e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e7:	8d 50 04             	lea    0x4(%eax),%edx
  8006ea:	89 55 14             	mov    %edx,0x14(%ebp)
  8006ed:	8b 30                	mov    (%eax),%esi
  8006ef:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8006f2:	89 f0                	mov    %esi,%eax
  8006f4:	c1 f8 1f             	sar    $0x1f,%eax
  8006f7:	89 45 dc             	mov    %eax,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006fa:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8006fd:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
  800700:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800704:	0f 89 8a 00 00 00    	jns    800794 <vprintfmt+0x356>
				putch('-', putdat);
  80070a:	83 ec 08             	sub    $0x8,%esp
  80070d:	53                   	push   %ebx
  80070e:	6a 2d                	push   $0x2d
  800710:	ff d7                	call   *%edi
				num = -(long long) num;
  800712:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800715:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800718:	f7 d8                	neg    %eax
  80071a:	83 d2 00             	adc    $0x0,%edx
  80071d:	f7 da                	neg    %edx
  80071f:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800722:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800727:	eb 70                	jmp    800799 <vprintfmt+0x35b>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800729:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80072c:	8d 45 14             	lea    0x14(%ebp),%eax
  80072f:	e8 97 fc ff ff       	call   8003cb <getuint>
			base = 10;
  800734:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800739:	eb 5e                	jmp    800799 <vprintfmt+0x35b>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
  80073b:	83 ec 08             	sub    $0x8,%esp
  80073e:	53                   	push   %ebx
  80073f:	6a 30                	push   $0x30
  800741:	ff d7                	call   *%edi
			num = getuint(&ap, lflag);
  800743:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800746:	8d 45 14             	lea    0x14(%ebp),%eax
  800749:	e8 7d fc ff ff       	call   8003cb <getuint>
			base = 8;
			goto number;
  80074e:	83 c4 10             	add    $0x10,%esp
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  800751:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800756:	eb 41                	jmp    800799 <vprintfmt+0x35b>
		// pointer
		case 'p':
			putch('0', putdat);
  800758:	83 ec 08             	sub    $0x8,%esp
  80075b:	53                   	push   %ebx
  80075c:	6a 30                	push   $0x30
  80075e:	ff d7                	call   *%edi
			putch('x', putdat);
  800760:	83 c4 08             	add    $0x8,%esp
  800763:	53                   	push   %ebx
  800764:	6a 78                	push   $0x78
  800766:	ff d7                	call   *%edi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800768:	8b 45 14             	mov    0x14(%ebp),%eax
  80076b:	8d 50 04             	lea    0x4(%eax),%edx
  80076e:	89 55 14             	mov    %edx,0x14(%ebp)
			goto number;
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800771:	8b 00                	mov    (%eax),%eax
  800773:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800778:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80077b:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800780:	eb 17                	jmp    800799 <vprintfmt+0x35b>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800782:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800785:	8d 45 14             	lea    0x14(%ebp),%eax
  800788:	e8 3e fc ff ff       	call   8003cb <getuint>
			base = 16;
  80078d:	b9 10 00 00 00       	mov    $0x10,%ecx
  800792:	eb 05                	jmp    800799 <vprintfmt+0x35b>
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800794:	b9 0a 00 00 00       	mov    $0xa,%ecx
		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  800799:	83 ec 0c             	sub    $0xc,%esp
  80079c:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  8007a0:	56                   	push   %esi
  8007a1:	ff 75 e4             	pushl  -0x1c(%ebp)
  8007a4:	51                   	push   %ecx
  8007a5:	52                   	push   %edx
  8007a6:	50                   	push   %eax
  8007a7:	89 da                	mov    %ebx,%edx
  8007a9:	89 f8                	mov    %edi,%eax
  8007ab:	e8 6b fb ff ff       	call   80031b <printnum>
			break;
  8007b0:	83 c4 20             	add    $0x20,%esp
  8007b3:	e9 9a fc ff ff       	jmp    800452 <vprintfmt+0x14>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007b8:	83 ec 08             	sub    $0x8,%esp
  8007bb:	53                   	push   %ebx
  8007bc:	52                   	push   %edx
  8007bd:	ff d7                	call   *%edi
			break;
  8007bf:	83 c4 10             	add    $0x10,%esp
  8007c2:	e9 8b fc ff ff       	jmp    800452 <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007c7:	83 ec 08             	sub    $0x8,%esp
  8007ca:	53                   	push   %ebx
  8007cb:	6a 25                	push   $0x25
  8007cd:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007cf:	83 c4 10             	add    $0x10,%esp
  8007d2:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8007d6:	0f 84 73 fc ff ff    	je     80044f <vprintfmt+0x11>
  8007dc:	4e                   	dec    %esi
  8007dd:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8007e1:	75 f9                	jne    8007dc <vprintfmt+0x39e>
  8007e3:	89 75 10             	mov    %esi,0x10(%ebp)
  8007e6:	e9 67 fc ff ff       	jmp    800452 <vprintfmt+0x14>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8007eb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8007ee:	8d 70 01             	lea    0x1(%eax),%esi
  8007f1:	8a 00                	mov    (%eax),%al
  8007f3:	0f be d0             	movsbl %al,%edx
  8007f6:	85 d2                	test   %edx,%edx
  8007f8:	0f 85 7a fe ff ff    	jne    800678 <vprintfmt+0x23a>
  8007fe:	e9 4f fc ff ff       	jmp    800452 <vprintfmt+0x14>
  800803:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800806:	8d 70 01             	lea    0x1(%eax),%esi
  800809:	8a 00                	mov    (%eax),%al
  80080b:	0f be d0             	movsbl %al,%edx
  80080e:	85 d2                	test   %edx,%edx
  800810:	0f 85 6a fe ff ff    	jne    800680 <vprintfmt+0x242>
  800816:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800819:	e9 77 fe ff ff       	jmp    800695 <vprintfmt+0x257>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  80081e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800821:	5b                   	pop    %ebx
  800822:	5e                   	pop    %esi
  800823:	5f                   	pop    %edi
  800824:	5d                   	pop    %ebp
  800825:	c3                   	ret    

00800826 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800826:	55                   	push   %ebp
  800827:	89 e5                	mov    %esp,%ebp
  800829:	83 ec 18             	sub    $0x18,%esp
  80082c:	8b 45 08             	mov    0x8(%ebp),%eax
  80082f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800832:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800835:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800839:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80083c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800843:	85 c0                	test   %eax,%eax
  800845:	74 26                	je     80086d <vsnprintf+0x47>
  800847:	85 d2                	test   %edx,%edx
  800849:	7e 29                	jle    800874 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80084b:	ff 75 14             	pushl  0x14(%ebp)
  80084e:	ff 75 10             	pushl  0x10(%ebp)
  800851:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800854:	50                   	push   %eax
  800855:	68 05 04 80 00       	push   $0x800405
  80085a:	e8 df fb ff ff       	call   80043e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80085f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800862:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800865:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800868:	83 c4 10             	add    $0x10,%esp
  80086b:	eb 0c                	jmp    800879 <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80086d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800872:	eb 05                	jmp    800879 <vsnprintf+0x53>
  800874:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800879:	c9                   	leave  
  80087a:	c3                   	ret    

0080087b <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80087b:	55                   	push   %ebp
  80087c:	89 e5                	mov    %esp,%ebp
  80087e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800881:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800884:	50                   	push   %eax
  800885:	ff 75 10             	pushl  0x10(%ebp)
  800888:	ff 75 0c             	pushl  0xc(%ebp)
  80088b:	ff 75 08             	pushl  0x8(%ebp)
  80088e:	e8 93 ff ff ff       	call   800826 <vsnprintf>
	va_end(ap);

	return rc;
}
  800893:	c9                   	leave  
  800894:	c3                   	ret    

00800895 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800895:	55                   	push   %ebp
  800896:	89 e5                	mov    %esp,%ebp
  800898:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80089b:	80 3a 00             	cmpb   $0x0,(%edx)
  80089e:	74 0e                	je     8008ae <strlen+0x19>
  8008a0:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8008a5:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8008a6:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008aa:	75 f9                	jne    8008a5 <strlen+0x10>
  8008ac:	eb 05                	jmp    8008b3 <strlen+0x1e>
  8008ae:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8008b3:	5d                   	pop    %ebp
  8008b4:	c3                   	ret    

008008b5 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008b5:	55                   	push   %ebp
  8008b6:	89 e5                	mov    %esp,%ebp
  8008b8:	53                   	push   %ebx
  8008b9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8008bc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008bf:	85 c9                	test   %ecx,%ecx
  8008c1:	74 1a                	je     8008dd <strnlen+0x28>
  8008c3:	80 3b 00             	cmpb   $0x0,(%ebx)
  8008c6:	74 1c                	je     8008e4 <strnlen+0x2f>
  8008c8:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  8008cd:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008cf:	39 ca                	cmp    %ecx,%edx
  8008d1:	74 16                	je     8008e9 <strnlen+0x34>
  8008d3:	42                   	inc    %edx
  8008d4:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  8008d9:	75 f2                	jne    8008cd <strnlen+0x18>
  8008db:	eb 0c                	jmp    8008e9 <strnlen+0x34>
  8008dd:	b8 00 00 00 00       	mov    $0x0,%eax
  8008e2:	eb 05                	jmp    8008e9 <strnlen+0x34>
  8008e4:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8008e9:	5b                   	pop    %ebx
  8008ea:	5d                   	pop    %ebp
  8008eb:	c3                   	ret    

008008ec <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008ec:	55                   	push   %ebp
  8008ed:	89 e5                	mov    %esp,%ebp
  8008ef:	53                   	push   %ebx
  8008f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008f6:	89 c2                	mov    %eax,%edx
  8008f8:	42                   	inc    %edx
  8008f9:	41                   	inc    %ecx
  8008fa:	8a 59 ff             	mov    -0x1(%ecx),%bl
  8008fd:	88 5a ff             	mov    %bl,-0x1(%edx)
  800900:	84 db                	test   %bl,%bl
  800902:	75 f4                	jne    8008f8 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800904:	5b                   	pop    %ebx
  800905:	5d                   	pop    %ebp
  800906:	c3                   	ret    

00800907 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800907:	55                   	push   %ebp
  800908:	89 e5                	mov    %esp,%ebp
  80090a:	53                   	push   %ebx
  80090b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80090e:	53                   	push   %ebx
  80090f:	e8 81 ff ff ff       	call   800895 <strlen>
  800914:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800917:	ff 75 0c             	pushl  0xc(%ebp)
  80091a:	01 d8                	add    %ebx,%eax
  80091c:	50                   	push   %eax
  80091d:	e8 ca ff ff ff       	call   8008ec <strcpy>
	return dst;
}
  800922:	89 d8                	mov    %ebx,%eax
  800924:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800927:	c9                   	leave  
  800928:	c3                   	ret    

00800929 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800929:	55                   	push   %ebp
  80092a:	89 e5                	mov    %esp,%ebp
  80092c:	56                   	push   %esi
  80092d:	53                   	push   %ebx
  80092e:	8b 75 08             	mov    0x8(%ebp),%esi
  800931:	8b 55 0c             	mov    0xc(%ebp),%edx
  800934:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800937:	85 db                	test   %ebx,%ebx
  800939:	74 14                	je     80094f <strncpy+0x26>
  80093b:	01 f3                	add    %esi,%ebx
  80093d:	89 f1                	mov    %esi,%ecx
		*dst++ = *src;
  80093f:	41                   	inc    %ecx
  800940:	8a 02                	mov    (%edx),%al
  800942:	88 41 ff             	mov    %al,-0x1(%ecx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800945:	80 3a 01             	cmpb   $0x1,(%edx)
  800948:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80094b:	39 cb                	cmp    %ecx,%ebx
  80094d:	75 f0                	jne    80093f <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80094f:	89 f0                	mov    %esi,%eax
  800951:	5b                   	pop    %ebx
  800952:	5e                   	pop    %esi
  800953:	5d                   	pop    %ebp
  800954:	c3                   	ret    

00800955 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800955:	55                   	push   %ebp
  800956:	89 e5                	mov    %esp,%ebp
  800958:	53                   	push   %ebx
  800959:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80095c:	8b 45 10             	mov    0x10(%ebp),%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80095f:	85 c0                	test   %eax,%eax
  800961:	74 30                	je     800993 <strlcpy+0x3e>
		while (--size > 0 && *src != '\0')
  800963:	48                   	dec    %eax
  800964:	74 20                	je     800986 <strlcpy+0x31>
  800966:	8a 0b                	mov    (%ebx),%cl
  800968:	84 c9                	test   %cl,%cl
  80096a:	74 1f                	je     80098b <strlcpy+0x36>
  80096c:	8d 53 01             	lea    0x1(%ebx),%edx
  80096f:	01 c3                	add    %eax,%ebx
  800971:	8b 45 08             	mov    0x8(%ebp),%eax
			*dst++ = *src++;
  800974:	40                   	inc    %eax
  800975:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800978:	39 da                	cmp    %ebx,%edx
  80097a:	74 12                	je     80098e <strlcpy+0x39>
  80097c:	42                   	inc    %edx
  80097d:	8a 4a ff             	mov    -0x1(%edx),%cl
  800980:	84 c9                	test   %cl,%cl
  800982:	75 f0                	jne    800974 <strlcpy+0x1f>
  800984:	eb 08                	jmp    80098e <strlcpy+0x39>
  800986:	8b 45 08             	mov    0x8(%ebp),%eax
  800989:	eb 03                	jmp    80098e <strlcpy+0x39>
  80098b:	8b 45 08             	mov    0x8(%ebp),%eax
			*dst++ = *src++;
		*dst = '\0';
  80098e:	c6 00 00             	movb   $0x0,(%eax)
  800991:	eb 03                	jmp    800996 <strlcpy+0x41>
  800993:	8b 45 08             	mov    0x8(%ebp),%eax
	}
	return dst - dst_in;
  800996:	2b 45 08             	sub    0x8(%ebp),%eax
}
  800999:	5b                   	pop    %ebx
  80099a:	5d                   	pop    %ebp
  80099b:	c3                   	ret    

0080099c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80099c:	55                   	push   %ebp
  80099d:	89 e5                	mov    %esp,%ebp
  80099f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009a2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009a5:	8a 01                	mov    (%ecx),%al
  8009a7:	84 c0                	test   %al,%al
  8009a9:	74 10                	je     8009bb <strcmp+0x1f>
  8009ab:	3a 02                	cmp    (%edx),%al
  8009ad:	75 0c                	jne    8009bb <strcmp+0x1f>
		p++, q++;
  8009af:	41                   	inc    %ecx
  8009b0:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8009b1:	8a 01                	mov    (%ecx),%al
  8009b3:	84 c0                	test   %al,%al
  8009b5:	74 04                	je     8009bb <strcmp+0x1f>
  8009b7:	3a 02                	cmp    (%edx),%al
  8009b9:	74 f4                	je     8009af <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009bb:	0f b6 c0             	movzbl %al,%eax
  8009be:	0f b6 12             	movzbl (%edx),%edx
  8009c1:	29 d0                	sub    %edx,%eax
}
  8009c3:	5d                   	pop    %ebp
  8009c4:	c3                   	ret    

008009c5 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009c5:	55                   	push   %ebp
  8009c6:	89 e5                	mov    %esp,%ebp
  8009c8:	56                   	push   %esi
  8009c9:	53                   	push   %ebx
  8009ca:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8009cd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009d0:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  8009d3:	85 f6                	test   %esi,%esi
  8009d5:	74 23                	je     8009fa <strncmp+0x35>
  8009d7:	8a 03                	mov    (%ebx),%al
  8009d9:	84 c0                	test   %al,%al
  8009db:	74 2b                	je     800a08 <strncmp+0x43>
  8009dd:	3a 02                	cmp    (%edx),%al
  8009df:	75 27                	jne    800a08 <strncmp+0x43>
  8009e1:	8d 43 01             	lea    0x1(%ebx),%eax
  8009e4:	01 de                	add    %ebx,%esi
		n--, p++, q++;
  8009e6:	89 c3                	mov    %eax,%ebx
  8009e8:	42                   	inc    %edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009e9:	39 c6                	cmp    %eax,%esi
  8009eb:	74 14                	je     800a01 <strncmp+0x3c>
  8009ed:	8a 08                	mov    (%eax),%cl
  8009ef:	84 c9                	test   %cl,%cl
  8009f1:	74 15                	je     800a08 <strncmp+0x43>
  8009f3:	40                   	inc    %eax
  8009f4:	3a 0a                	cmp    (%edx),%cl
  8009f6:	74 ee                	je     8009e6 <strncmp+0x21>
  8009f8:	eb 0e                	jmp    800a08 <strncmp+0x43>
		n--, p++, q++;
	if (n == 0)
		return 0;
  8009fa:	b8 00 00 00 00       	mov    $0x0,%eax
  8009ff:	eb 0f                	jmp    800a10 <strncmp+0x4b>
  800a01:	b8 00 00 00 00       	mov    $0x0,%eax
  800a06:	eb 08                	jmp    800a10 <strncmp+0x4b>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a08:	0f b6 03             	movzbl (%ebx),%eax
  800a0b:	0f b6 12             	movzbl (%edx),%edx
  800a0e:	29 d0                	sub    %edx,%eax
}
  800a10:	5b                   	pop    %ebx
  800a11:	5e                   	pop    %esi
  800a12:	5d                   	pop    %ebp
  800a13:	c3                   	ret    

00800a14 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a14:	55                   	push   %ebp
  800a15:	89 e5                	mov    %esp,%ebp
  800a17:	53                   	push   %ebx
  800a18:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  800a1e:	8a 10                	mov    (%eax),%dl
  800a20:	84 d2                	test   %dl,%dl
  800a22:	74 1a                	je     800a3e <strchr+0x2a>
  800a24:	88 d9                	mov    %bl,%cl
		if (*s == c)
  800a26:	38 d3                	cmp    %dl,%bl
  800a28:	75 06                	jne    800a30 <strchr+0x1c>
  800a2a:	eb 17                	jmp    800a43 <strchr+0x2f>
  800a2c:	38 ca                	cmp    %cl,%dl
  800a2e:	74 13                	je     800a43 <strchr+0x2f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a30:	40                   	inc    %eax
  800a31:	8a 10                	mov    (%eax),%dl
  800a33:	84 d2                	test   %dl,%dl
  800a35:	75 f5                	jne    800a2c <strchr+0x18>
		if (*s == c)
			return (char *) s;
	return 0;
  800a37:	b8 00 00 00 00       	mov    $0x0,%eax
  800a3c:	eb 05                	jmp    800a43 <strchr+0x2f>
  800a3e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a43:	5b                   	pop    %ebx
  800a44:	5d                   	pop    %ebp
  800a45:	c3                   	ret    

00800a46 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a46:	55                   	push   %ebp
  800a47:	89 e5                	mov    %esp,%ebp
  800a49:	53                   	push   %ebx
  800a4a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a4d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  800a50:	8a 10                	mov    (%eax),%dl
  800a52:	84 d2                	test   %dl,%dl
  800a54:	74 13                	je     800a69 <strfind+0x23>
  800a56:	88 d9                	mov    %bl,%cl
		if (*s == c)
  800a58:	38 d3                	cmp    %dl,%bl
  800a5a:	75 06                	jne    800a62 <strfind+0x1c>
  800a5c:	eb 0b                	jmp    800a69 <strfind+0x23>
  800a5e:	38 ca                	cmp    %cl,%dl
  800a60:	74 07                	je     800a69 <strfind+0x23>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a62:	40                   	inc    %eax
  800a63:	8a 10                	mov    (%eax),%dl
  800a65:	84 d2                	test   %dl,%dl
  800a67:	75 f5                	jne    800a5e <strfind+0x18>
		if (*s == c)
			break;
	return (char *) s;
}
  800a69:	5b                   	pop    %ebx
  800a6a:	5d                   	pop    %ebp
  800a6b:	c3                   	ret    

00800a6c <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a6c:	55                   	push   %ebp
  800a6d:	89 e5                	mov    %esp,%ebp
  800a6f:	57                   	push   %edi
  800a70:	56                   	push   %esi
  800a71:	53                   	push   %ebx
  800a72:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a75:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a78:	85 c9                	test   %ecx,%ecx
  800a7a:	74 36                	je     800ab2 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a7c:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a82:	75 28                	jne    800aac <memset+0x40>
  800a84:	f6 c1 03             	test   $0x3,%cl
  800a87:	75 23                	jne    800aac <memset+0x40>
		c &= 0xFF;
  800a89:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a8d:	89 d3                	mov    %edx,%ebx
  800a8f:	c1 e3 08             	shl    $0x8,%ebx
  800a92:	89 d6                	mov    %edx,%esi
  800a94:	c1 e6 18             	shl    $0x18,%esi
  800a97:	89 d0                	mov    %edx,%eax
  800a99:	c1 e0 10             	shl    $0x10,%eax
  800a9c:	09 f0                	or     %esi,%eax
  800a9e:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800aa0:	89 d8                	mov    %ebx,%eax
  800aa2:	09 d0                	or     %edx,%eax
  800aa4:	c1 e9 02             	shr    $0x2,%ecx
  800aa7:	fc                   	cld    
  800aa8:	f3 ab                	rep stos %eax,%es:(%edi)
  800aaa:	eb 06                	jmp    800ab2 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800aac:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aaf:	fc                   	cld    
  800ab0:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800ab2:	89 f8                	mov    %edi,%eax
  800ab4:	5b                   	pop    %ebx
  800ab5:	5e                   	pop    %esi
  800ab6:	5f                   	pop    %edi
  800ab7:	5d                   	pop    %ebp
  800ab8:	c3                   	ret    

00800ab9 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ab9:	55                   	push   %ebp
  800aba:	89 e5                	mov    %esp,%ebp
  800abc:	57                   	push   %edi
  800abd:	56                   	push   %esi
  800abe:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac1:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ac4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ac7:	39 c6                	cmp    %eax,%esi
  800ac9:	73 33                	jae    800afe <memmove+0x45>
  800acb:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ace:	39 d0                	cmp    %edx,%eax
  800ad0:	73 2c                	jae    800afe <memmove+0x45>
		s += n;
		d += n;
  800ad2:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ad5:	89 d6                	mov    %edx,%esi
  800ad7:	09 fe                	or     %edi,%esi
  800ad9:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800adf:	75 13                	jne    800af4 <memmove+0x3b>
  800ae1:	f6 c1 03             	test   $0x3,%cl
  800ae4:	75 0e                	jne    800af4 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800ae6:	83 ef 04             	sub    $0x4,%edi
  800ae9:	8d 72 fc             	lea    -0x4(%edx),%esi
  800aec:	c1 e9 02             	shr    $0x2,%ecx
  800aef:	fd                   	std    
  800af0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800af2:	eb 07                	jmp    800afb <memmove+0x42>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800af4:	4f                   	dec    %edi
  800af5:	8d 72 ff             	lea    -0x1(%edx),%esi
  800af8:	fd                   	std    
  800af9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800afb:	fc                   	cld    
  800afc:	eb 1d                	jmp    800b1b <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800afe:	89 f2                	mov    %esi,%edx
  800b00:	09 c2                	or     %eax,%edx
  800b02:	f6 c2 03             	test   $0x3,%dl
  800b05:	75 0f                	jne    800b16 <memmove+0x5d>
  800b07:	f6 c1 03             	test   $0x3,%cl
  800b0a:	75 0a                	jne    800b16 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
  800b0c:	c1 e9 02             	shr    $0x2,%ecx
  800b0f:	89 c7                	mov    %eax,%edi
  800b11:	fc                   	cld    
  800b12:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b14:	eb 05                	jmp    800b1b <memmove+0x62>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b16:	89 c7                	mov    %eax,%edi
  800b18:	fc                   	cld    
  800b19:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b1b:	5e                   	pop    %esi
  800b1c:	5f                   	pop    %edi
  800b1d:	5d                   	pop    %ebp
  800b1e:	c3                   	ret    

00800b1f <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b1f:	55                   	push   %ebp
  800b20:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b22:	ff 75 10             	pushl  0x10(%ebp)
  800b25:	ff 75 0c             	pushl  0xc(%ebp)
  800b28:	ff 75 08             	pushl  0x8(%ebp)
  800b2b:	e8 89 ff ff ff       	call   800ab9 <memmove>
}
  800b30:	c9                   	leave  
  800b31:	c3                   	ret    

00800b32 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b32:	55                   	push   %ebp
  800b33:	89 e5                	mov    %esp,%ebp
  800b35:	57                   	push   %edi
  800b36:	56                   	push   %esi
  800b37:	53                   	push   %ebx
  800b38:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800b3b:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b3e:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b41:	85 c0                	test   %eax,%eax
  800b43:	74 33                	je     800b78 <memcmp+0x46>
  800b45:	8d 78 ff             	lea    -0x1(%eax),%edi
		if (*s1 != *s2)
  800b48:	8a 13                	mov    (%ebx),%dl
  800b4a:	8a 0e                	mov    (%esi),%cl
  800b4c:	38 ca                	cmp    %cl,%dl
  800b4e:	75 13                	jne    800b63 <memcmp+0x31>
  800b50:	b8 00 00 00 00       	mov    $0x0,%eax
  800b55:	eb 16                	jmp    800b6d <memcmp+0x3b>
  800b57:	8a 54 03 01          	mov    0x1(%ebx,%eax,1),%dl
  800b5b:	40                   	inc    %eax
  800b5c:	8a 0c 06             	mov    (%esi,%eax,1),%cl
  800b5f:	38 ca                	cmp    %cl,%dl
  800b61:	74 0a                	je     800b6d <memcmp+0x3b>
			return (int) *s1 - (int) *s2;
  800b63:	0f b6 c2             	movzbl %dl,%eax
  800b66:	0f b6 c9             	movzbl %cl,%ecx
  800b69:	29 c8                	sub    %ecx,%eax
  800b6b:	eb 10                	jmp    800b7d <memcmp+0x4b>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b6d:	39 f8                	cmp    %edi,%eax
  800b6f:	75 e6                	jne    800b57 <memcmp+0x25>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b71:	b8 00 00 00 00       	mov    $0x0,%eax
  800b76:	eb 05                	jmp    800b7d <memcmp+0x4b>
  800b78:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b7d:	5b                   	pop    %ebx
  800b7e:	5e                   	pop    %esi
  800b7f:	5f                   	pop    %edi
  800b80:	5d                   	pop    %ebp
  800b81:	c3                   	ret    

00800b82 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b82:	55                   	push   %ebp
  800b83:	89 e5                	mov    %esp,%ebp
  800b85:	53                   	push   %ebx
  800b86:	8b 55 08             	mov    0x8(%ebp),%edx
	const void *ends = (const char *) s + n;
  800b89:	89 d0                	mov    %edx,%eax
  800b8b:	03 45 10             	add    0x10(%ebp),%eax
	for (; s < ends; s++)
  800b8e:	39 c2                	cmp    %eax,%edx
  800b90:	73 1b                	jae    800bad <memfind+0x2b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b92:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
  800b96:	0f b6 0a             	movzbl (%edx),%ecx
  800b99:	39 d9                	cmp    %ebx,%ecx
  800b9b:	75 09                	jne    800ba6 <memfind+0x24>
  800b9d:	eb 12                	jmp    800bb1 <memfind+0x2f>
  800b9f:	0f b6 0a             	movzbl (%edx),%ecx
  800ba2:	39 d9                	cmp    %ebx,%ecx
  800ba4:	74 0f                	je     800bb5 <memfind+0x33>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ba6:	42                   	inc    %edx
  800ba7:	39 d0                	cmp    %edx,%eax
  800ba9:	75 f4                	jne    800b9f <memfind+0x1d>
  800bab:	eb 0a                	jmp    800bb7 <memfind+0x35>
  800bad:	89 d0                	mov    %edx,%eax
  800baf:	eb 06                	jmp    800bb7 <memfind+0x35>
		if (*(const unsigned char *) s == (unsigned char) c)
  800bb1:	89 d0                	mov    %edx,%eax
  800bb3:	eb 02                	jmp    800bb7 <memfind+0x35>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bb5:	89 d0                	mov    %edx,%eax
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800bb7:	5b                   	pop    %ebx
  800bb8:	5d                   	pop    %ebp
  800bb9:	c3                   	ret    

00800bba <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800bba:	55                   	push   %ebp
  800bbb:	89 e5                	mov    %esp,%ebp
  800bbd:	57                   	push   %edi
  800bbe:	56                   	push   %esi
  800bbf:	53                   	push   %ebx
  800bc0:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bc3:	eb 01                	jmp    800bc6 <strtol+0xc>
		s++;
  800bc5:	41                   	inc    %ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bc6:	8a 01                	mov    (%ecx),%al
  800bc8:	3c 20                	cmp    $0x20,%al
  800bca:	74 f9                	je     800bc5 <strtol+0xb>
  800bcc:	3c 09                	cmp    $0x9,%al
  800bce:	74 f5                	je     800bc5 <strtol+0xb>
		s++;

	// plus/minus sign
	if (*s == '+')
  800bd0:	3c 2b                	cmp    $0x2b,%al
  800bd2:	75 08                	jne    800bdc <strtol+0x22>
		s++;
  800bd4:	41                   	inc    %ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800bd5:	bf 00 00 00 00       	mov    $0x0,%edi
  800bda:	eb 11                	jmp    800bed <strtol+0x33>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800bdc:	3c 2d                	cmp    $0x2d,%al
  800bde:	75 08                	jne    800be8 <strtol+0x2e>
		s++, neg = 1;
  800be0:	41                   	inc    %ecx
  800be1:	bf 01 00 00 00       	mov    $0x1,%edi
  800be6:	eb 05                	jmp    800bed <strtol+0x33>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800be8:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bed:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800bf1:	0f 84 87 00 00 00    	je     800c7e <strtol+0xc4>
  800bf7:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  800bfb:	75 27                	jne    800c24 <strtol+0x6a>
  800bfd:	80 39 30             	cmpb   $0x30,(%ecx)
  800c00:	75 22                	jne    800c24 <strtol+0x6a>
  800c02:	e9 88 00 00 00       	jmp    800c8f <strtol+0xd5>
		s += 2, base = 16;
  800c07:	83 c1 02             	add    $0x2,%ecx
  800c0a:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  800c11:	eb 11                	jmp    800c24 <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
  800c13:	41                   	inc    %ecx
  800c14:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  800c1b:	eb 07                	jmp    800c24 <strtol+0x6a>
	else if (base == 0)
		base = 10;
  800c1d:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)
  800c24:	b8 00 00 00 00       	mov    $0x0,%eax

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c29:	8a 11                	mov    (%ecx),%dl
  800c2b:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800c2e:	80 fb 09             	cmp    $0x9,%bl
  800c31:	77 08                	ja     800c3b <strtol+0x81>
			dig = *s - '0';
  800c33:	0f be d2             	movsbl %dl,%edx
  800c36:	83 ea 30             	sub    $0x30,%edx
  800c39:	eb 22                	jmp    800c5d <strtol+0xa3>
		else if (*s >= 'a' && *s <= 'z')
  800c3b:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c3e:	89 f3                	mov    %esi,%ebx
  800c40:	80 fb 19             	cmp    $0x19,%bl
  800c43:	77 08                	ja     800c4d <strtol+0x93>
			dig = *s - 'a' + 10;
  800c45:	0f be d2             	movsbl %dl,%edx
  800c48:	83 ea 57             	sub    $0x57,%edx
  800c4b:	eb 10                	jmp    800c5d <strtol+0xa3>
		else if (*s >= 'A' && *s <= 'Z')
  800c4d:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c50:	89 f3                	mov    %esi,%ebx
  800c52:	80 fb 19             	cmp    $0x19,%bl
  800c55:	77 14                	ja     800c6b <strtol+0xb1>
			dig = *s - 'A' + 10;
  800c57:	0f be d2             	movsbl %dl,%edx
  800c5a:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800c5d:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c60:	7d 09                	jge    800c6b <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800c62:	41                   	inc    %ecx
  800c63:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c67:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800c69:	eb be                	jmp    800c29 <strtol+0x6f>

	if (endptr)
  800c6b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c6f:	74 05                	je     800c76 <strtol+0xbc>
		*endptr = (char *) s;
  800c71:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c74:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800c76:	85 ff                	test   %edi,%edi
  800c78:	74 21                	je     800c9b <strtol+0xe1>
  800c7a:	f7 d8                	neg    %eax
  800c7c:	eb 1d                	jmp    800c9b <strtol+0xe1>
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c7e:	80 39 30             	cmpb   $0x30,(%ecx)
  800c81:	75 9a                	jne    800c1d <strtol+0x63>
  800c83:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c87:	0f 84 7a ff ff ff    	je     800c07 <strtol+0x4d>
  800c8d:	eb 84                	jmp    800c13 <strtol+0x59>
  800c8f:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c93:	0f 84 6e ff ff ff    	je     800c07 <strtol+0x4d>
  800c99:	eb 89                	jmp    800c24 <strtol+0x6a>
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
}
  800c9b:	5b                   	pop    %ebx
  800c9c:	5e                   	pop    %esi
  800c9d:	5f                   	pop    %edi
  800c9e:	5d                   	pop    %ebp
  800c9f:	c3                   	ret    

00800ca0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ca0:	55                   	push   %ebp
  800ca1:	89 e5                	mov    %esp,%ebp
  800ca3:	57                   	push   %edi
  800ca4:	56                   	push   %esi
  800ca5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca6:	b8 00 00 00 00       	mov    $0x0,%eax
  800cab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cae:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb1:	89 c3                	mov    %eax,%ebx
  800cb3:	89 c7                	mov    %eax,%edi
  800cb5:	89 c6                	mov    %eax,%esi
  800cb7:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800cb9:	5b                   	pop    %ebx
  800cba:	5e                   	pop    %esi
  800cbb:	5f                   	pop    %edi
  800cbc:	5d                   	pop    %ebp
  800cbd:	c3                   	ret    

00800cbe <sys_cgetc>:

int
sys_cgetc(void)
{
  800cbe:	55                   	push   %ebp
  800cbf:	89 e5                	mov    %esp,%ebp
  800cc1:	57                   	push   %edi
  800cc2:	56                   	push   %esi
  800cc3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc4:	ba 00 00 00 00       	mov    $0x0,%edx
  800cc9:	b8 01 00 00 00       	mov    $0x1,%eax
  800cce:	89 d1                	mov    %edx,%ecx
  800cd0:	89 d3                	mov    %edx,%ebx
  800cd2:	89 d7                	mov    %edx,%edi
  800cd4:	89 d6                	mov    %edx,%esi
  800cd6:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800cd8:	5b                   	pop    %ebx
  800cd9:	5e                   	pop    %esi
  800cda:	5f                   	pop    %edi
  800cdb:	5d                   	pop    %ebp
  800cdc:	c3                   	ret    

00800cdd <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800cdd:	55                   	push   %ebp
  800cde:	89 e5                	mov    %esp,%ebp
  800ce0:	57                   	push   %edi
  800ce1:	56                   	push   %esi
  800ce2:	53                   	push   %ebx
  800ce3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ceb:	b8 03 00 00 00       	mov    $0x3,%eax
  800cf0:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf3:	89 cb                	mov    %ecx,%ebx
  800cf5:	89 cf                	mov    %ecx,%edi
  800cf7:	89 ce                	mov    %ecx,%esi
  800cf9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cfb:	85 c0                	test   %eax,%eax
  800cfd:	7e 17                	jle    800d16 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cff:	83 ec 0c             	sub    $0xc,%esp
  800d02:	50                   	push   %eax
  800d03:	6a 03                	push   $0x3
  800d05:	68 3f 27 80 00       	push   $0x80273f
  800d0a:	6a 23                	push   $0x23
  800d0c:	68 5c 27 80 00       	push   $0x80275c
  800d11:	e8 19 f5 ff ff       	call   80022f <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d16:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d19:	5b                   	pop    %ebx
  800d1a:	5e                   	pop    %esi
  800d1b:	5f                   	pop    %edi
  800d1c:	5d                   	pop    %ebp
  800d1d:	c3                   	ret    

00800d1e <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d1e:	55                   	push   %ebp
  800d1f:	89 e5                	mov    %esp,%ebp
  800d21:	57                   	push   %edi
  800d22:	56                   	push   %esi
  800d23:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d24:	ba 00 00 00 00       	mov    $0x0,%edx
  800d29:	b8 02 00 00 00       	mov    $0x2,%eax
  800d2e:	89 d1                	mov    %edx,%ecx
  800d30:	89 d3                	mov    %edx,%ebx
  800d32:	89 d7                	mov    %edx,%edi
  800d34:	89 d6                	mov    %edx,%esi
  800d36:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d38:	5b                   	pop    %ebx
  800d39:	5e                   	pop    %esi
  800d3a:	5f                   	pop    %edi
  800d3b:	5d                   	pop    %ebp
  800d3c:	c3                   	ret    

00800d3d <sys_yield>:

void
sys_yield(void)
{
  800d3d:	55                   	push   %ebp
  800d3e:	89 e5                	mov    %esp,%ebp
  800d40:	57                   	push   %edi
  800d41:	56                   	push   %esi
  800d42:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d43:	ba 00 00 00 00       	mov    $0x0,%edx
  800d48:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d4d:	89 d1                	mov    %edx,%ecx
  800d4f:	89 d3                	mov    %edx,%ebx
  800d51:	89 d7                	mov    %edx,%edi
  800d53:	89 d6                	mov    %edx,%esi
  800d55:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d57:	5b                   	pop    %ebx
  800d58:	5e                   	pop    %esi
  800d59:	5f                   	pop    %edi
  800d5a:	5d                   	pop    %ebp
  800d5b:	c3                   	ret    

00800d5c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
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
  800d65:	be 00 00 00 00       	mov    $0x0,%esi
  800d6a:	b8 04 00 00 00       	mov    $0x4,%eax
  800d6f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d72:	8b 55 08             	mov    0x8(%ebp),%edx
  800d75:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d78:	89 f7                	mov    %esi,%edi
  800d7a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d7c:	85 c0                	test   %eax,%eax
  800d7e:	7e 17                	jle    800d97 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d80:	83 ec 0c             	sub    $0xc,%esp
  800d83:	50                   	push   %eax
  800d84:	6a 04                	push   $0x4
  800d86:	68 3f 27 80 00       	push   $0x80273f
  800d8b:	6a 23                	push   $0x23
  800d8d:	68 5c 27 80 00       	push   $0x80275c
  800d92:	e8 98 f4 ff ff       	call   80022f <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d97:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d9a:	5b                   	pop    %ebx
  800d9b:	5e                   	pop    %esi
  800d9c:	5f                   	pop    %edi
  800d9d:	5d                   	pop    %ebp
  800d9e:	c3                   	ret    

00800d9f <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d9f:	55                   	push   %ebp
  800da0:	89 e5                	mov    %esp,%ebp
  800da2:	57                   	push   %edi
  800da3:	56                   	push   %esi
  800da4:	53                   	push   %ebx
  800da5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800da8:	b8 05 00 00 00       	mov    $0x5,%eax
  800dad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db0:	8b 55 08             	mov    0x8(%ebp),%edx
  800db3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800db6:	8b 7d 14             	mov    0x14(%ebp),%edi
  800db9:	8b 75 18             	mov    0x18(%ebp),%esi
  800dbc:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dbe:	85 c0                	test   %eax,%eax
  800dc0:	7e 17                	jle    800dd9 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dc2:	83 ec 0c             	sub    $0xc,%esp
  800dc5:	50                   	push   %eax
  800dc6:	6a 05                	push   $0x5
  800dc8:	68 3f 27 80 00       	push   $0x80273f
  800dcd:	6a 23                	push   $0x23
  800dcf:	68 5c 27 80 00       	push   $0x80275c
  800dd4:	e8 56 f4 ff ff       	call   80022f <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800dd9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ddc:	5b                   	pop    %ebx
  800ddd:	5e                   	pop    %esi
  800dde:	5f                   	pop    %edi
  800ddf:	5d                   	pop    %ebp
  800de0:	c3                   	ret    

00800de1 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800de1:	55                   	push   %ebp
  800de2:	89 e5                	mov    %esp,%ebp
  800de4:	57                   	push   %edi
  800de5:	56                   	push   %esi
  800de6:	53                   	push   %ebx
  800de7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dea:	bb 00 00 00 00       	mov    $0x0,%ebx
  800def:	b8 06 00 00 00       	mov    $0x6,%eax
  800df4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800df7:	8b 55 08             	mov    0x8(%ebp),%edx
  800dfa:	89 df                	mov    %ebx,%edi
  800dfc:	89 de                	mov    %ebx,%esi
  800dfe:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e00:	85 c0                	test   %eax,%eax
  800e02:	7e 17                	jle    800e1b <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e04:	83 ec 0c             	sub    $0xc,%esp
  800e07:	50                   	push   %eax
  800e08:	6a 06                	push   $0x6
  800e0a:	68 3f 27 80 00       	push   $0x80273f
  800e0f:	6a 23                	push   $0x23
  800e11:	68 5c 27 80 00       	push   $0x80275c
  800e16:	e8 14 f4 ff ff       	call   80022f <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e1b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e1e:	5b                   	pop    %ebx
  800e1f:	5e                   	pop    %esi
  800e20:	5f                   	pop    %edi
  800e21:	5d                   	pop    %ebp
  800e22:	c3                   	ret    

00800e23 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e23:	55                   	push   %ebp
  800e24:	89 e5                	mov    %esp,%ebp
  800e26:	57                   	push   %edi
  800e27:	56                   	push   %esi
  800e28:	53                   	push   %ebx
  800e29:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e2c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e31:	b8 08 00 00 00       	mov    $0x8,%eax
  800e36:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e39:	8b 55 08             	mov    0x8(%ebp),%edx
  800e3c:	89 df                	mov    %ebx,%edi
  800e3e:	89 de                	mov    %ebx,%esi
  800e40:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e42:	85 c0                	test   %eax,%eax
  800e44:	7e 17                	jle    800e5d <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e46:	83 ec 0c             	sub    $0xc,%esp
  800e49:	50                   	push   %eax
  800e4a:	6a 08                	push   $0x8
  800e4c:	68 3f 27 80 00       	push   $0x80273f
  800e51:	6a 23                	push   $0x23
  800e53:	68 5c 27 80 00       	push   $0x80275c
  800e58:	e8 d2 f3 ff ff       	call   80022f <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e5d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e60:	5b                   	pop    %ebx
  800e61:	5e                   	pop    %esi
  800e62:	5f                   	pop    %edi
  800e63:	5d                   	pop    %ebp
  800e64:	c3                   	ret    

00800e65 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e65:	55                   	push   %ebp
  800e66:	89 e5                	mov    %esp,%ebp
  800e68:	57                   	push   %edi
  800e69:	56                   	push   %esi
  800e6a:	53                   	push   %ebx
  800e6b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e6e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e73:	b8 09 00 00 00       	mov    $0x9,%eax
  800e78:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e7b:	8b 55 08             	mov    0x8(%ebp),%edx
  800e7e:	89 df                	mov    %ebx,%edi
  800e80:	89 de                	mov    %ebx,%esi
  800e82:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e84:	85 c0                	test   %eax,%eax
  800e86:	7e 17                	jle    800e9f <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e88:	83 ec 0c             	sub    $0xc,%esp
  800e8b:	50                   	push   %eax
  800e8c:	6a 09                	push   $0x9
  800e8e:	68 3f 27 80 00       	push   $0x80273f
  800e93:	6a 23                	push   $0x23
  800e95:	68 5c 27 80 00       	push   $0x80275c
  800e9a:	e8 90 f3 ff ff       	call   80022f <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e9f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ea2:	5b                   	pop    %ebx
  800ea3:	5e                   	pop    %esi
  800ea4:	5f                   	pop    %edi
  800ea5:	5d                   	pop    %ebp
  800ea6:	c3                   	ret    

00800ea7 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ea7:	55                   	push   %ebp
  800ea8:	89 e5                	mov    %esp,%ebp
  800eaa:	57                   	push   %edi
  800eab:	56                   	push   %esi
  800eac:	53                   	push   %ebx
  800ead:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eb0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800eb5:	b8 0a 00 00 00       	mov    $0xa,%eax
  800eba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ebd:	8b 55 08             	mov    0x8(%ebp),%edx
  800ec0:	89 df                	mov    %ebx,%edi
  800ec2:	89 de                	mov    %ebx,%esi
  800ec4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ec6:	85 c0                	test   %eax,%eax
  800ec8:	7e 17                	jle    800ee1 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800eca:	83 ec 0c             	sub    $0xc,%esp
  800ecd:	50                   	push   %eax
  800ece:	6a 0a                	push   $0xa
  800ed0:	68 3f 27 80 00       	push   $0x80273f
  800ed5:	6a 23                	push   $0x23
  800ed7:	68 5c 27 80 00       	push   $0x80275c
  800edc:	e8 4e f3 ff ff       	call   80022f <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ee1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ee4:	5b                   	pop    %ebx
  800ee5:	5e                   	pop    %esi
  800ee6:	5f                   	pop    %edi
  800ee7:	5d                   	pop    %ebp
  800ee8:	c3                   	ret    

00800ee9 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ee9:	55                   	push   %ebp
  800eea:	89 e5                	mov    %esp,%ebp
  800eec:	57                   	push   %edi
  800eed:	56                   	push   %esi
  800eee:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eef:	be 00 00 00 00       	mov    $0x0,%esi
  800ef4:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ef9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800efc:	8b 55 08             	mov    0x8(%ebp),%edx
  800eff:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f02:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f05:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f07:	5b                   	pop    %ebx
  800f08:	5e                   	pop    %esi
  800f09:	5f                   	pop    %edi
  800f0a:	5d                   	pop    %ebp
  800f0b:	c3                   	ret    

00800f0c <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800f0c:	55                   	push   %ebp
  800f0d:	89 e5                	mov    %esp,%ebp
  800f0f:	57                   	push   %edi
  800f10:	56                   	push   %esi
  800f11:	53                   	push   %ebx
  800f12:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f15:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f1a:	b8 0d 00 00 00       	mov    $0xd,%eax
  800f1f:	8b 55 08             	mov    0x8(%ebp),%edx
  800f22:	89 cb                	mov    %ecx,%ebx
  800f24:	89 cf                	mov    %ecx,%edi
  800f26:	89 ce                	mov    %ecx,%esi
  800f28:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f2a:	85 c0                	test   %eax,%eax
  800f2c:	7e 17                	jle    800f45 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f2e:	83 ec 0c             	sub    $0xc,%esp
  800f31:	50                   	push   %eax
  800f32:	6a 0d                	push   $0xd
  800f34:	68 3f 27 80 00       	push   $0x80273f
  800f39:	6a 23                	push   $0x23
  800f3b:	68 5c 27 80 00       	push   $0x80275c
  800f40:	e8 ea f2 ff ff       	call   80022f <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f45:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f48:	5b                   	pop    %ebx
  800f49:	5e                   	pop    %esi
  800f4a:	5f                   	pop    %edi
  800f4b:	5d                   	pop    %ebp
  800f4c:	c3                   	ret    

00800f4d <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800f4d:	55                   	push   %ebp
  800f4e:	89 e5                	mov    %esp,%ebp
  800f50:	56                   	push   %esi
  800f51:	53                   	push   %ebx
  800f52:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800f55:	8b 18                	mov    (%eax),%ebx
	// copy-on-write page.  If not, panic.
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).
	
	if((err & FEC_WR) == 0){
  800f57:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800f5b:	75 14                	jne    800f71 <pgfault+0x24>
		panic("pgfault not cause by write \n");
  800f5d:	83 ec 04             	sub    $0x4,%esp
  800f60:	68 6a 27 80 00       	push   $0x80276a
  800f65:	6a 1c                	push   $0x1c
  800f67:	68 87 27 80 00       	push   $0x802787
  800f6c:	e8 be f2 ff ff       	call   80022f <_panic>
	}
 
	if ((uvpt[PGNUM(addr)] & PTE_COW) == 0) 
  800f71:	89 d8                	mov    %ebx,%eax
  800f73:	c1 e8 0c             	shr    $0xc,%eax
  800f76:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f7d:	f6 c4 08             	test   $0x8,%ah
  800f80:	75 14                	jne    800f96 <pgfault+0x49>
    {
        panic("pgfault not cause by COW \n");
  800f82:	83 ec 04             	sub    $0x4,%esp
  800f85:	68 92 27 80 00       	push   $0x802792
  800f8a:	6a 21                	push   $0x21
  800f8c:	68 87 27 80 00       	push   $0x802787
  800f91:	e8 99 f2 ff ff       	call   80022f <_panic>
	// copy the data from the old page to the new page, then move the new
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.
	envid_t eid = sys_getenvid();
  800f96:	e8 83 fd ff ff       	call   800d1e <sys_getenvid>
  800f9b:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(eid,(void*)PFTEMP,PTE_P|PTE_W|PTE_U)) < 0)
  800f9d:	83 ec 04             	sub    $0x4,%esp
  800fa0:	6a 07                	push   $0x7
  800fa2:	68 00 f0 7f 00       	push   $0x7ff000
  800fa7:	50                   	push   %eax
  800fa8:	e8 af fd ff ff       	call   800d5c <sys_page_alloc>
  800fad:	83 c4 10             	add    $0x10,%esp
  800fb0:	85 c0                	test   %eax,%eax
  800fb2:	79 14                	jns    800fc8 <pgfault+0x7b>
		panic("page alloction failed.\n");
  800fb4:	83 ec 04             	sub    $0x4,%esp
  800fb7:	68 ad 27 80 00       	push   $0x8027ad
  800fbc:	6a 2d                	push   $0x2d
  800fbe:	68 87 27 80 00       	push   $0x802787
  800fc3:	e8 67 f2 ff ff       	call   80022f <_panic>
	addr = ROUNDDOWN(addr,PGSIZE);
  800fc8:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memmove(PFTEMP,addr,PGSIZE);
  800fce:	83 ec 04             	sub    $0x4,%esp
  800fd1:	68 00 10 00 00       	push   $0x1000
  800fd6:	53                   	push   %ebx
  800fd7:	68 00 f0 7f 00       	push   $0x7ff000
  800fdc:	e8 d8 fa ff ff       	call   800ab9 <memmove>
	if ((r = sys_page_map(eid, PFTEMP, eid, addr, PTE_P | PTE_W |PTE_U)) < 0)
  800fe1:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800fe8:	53                   	push   %ebx
  800fe9:	56                   	push   %esi
  800fea:	68 00 f0 7f 00       	push   $0x7ff000
  800fef:	56                   	push   %esi
  800ff0:	e8 aa fd ff ff       	call   800d9f <sys_page_map>
  800ff5:	83 c4 20             	add    $0x20,%esp
  800ff8:	85 c0                	test   %eax,%eax
  800ffa:	79 12                	jns    80100e <pgfault+0xc1>
        panic("pgfault: page map failed %e\n", r);
  800ffc:	50                   	push   %eax
  800ffd:	68 c5 27 80 00       	push   $0x8027c5
  801002:	6a 31                	push   $0x31
  801004:	68 87 27 80 00       	push   $0x802787
  801009:	e8 21 f2 ff ff       	call   80022f <_panic>
	if ((r = sys_page_unmap(eid, PFTEMP)) < 0)
  80100e:	83 ec 08             	sub    $0x8,%esp
  801011:	68 00 f0 7f 00       	push   $0x7ff000
  801016:	56                   	push   %esi
  801017:	e8 c5 fd ff ff       	call   800de1 <sys_page_unmap>
  80101c:	83 c4 10             	add    $0x10,%esp
  80101f:	85 c0                	test   %eax,%eax
  801021:	79 12                	jns    801035 <pgfault+0xe8>
        panic("pgfault: page unmap failed %e\n", r);
  801023:	50                   	push   %eax
  801024:	68 34 28 80 00       	push   $0x802834
  801029:	6a 33                	push   $0x33
  80102b:	68 87 27 80 00       	push   $0x802787
  801030:	e8 fa f1 ff ff       	call   80022f <_panic>
	// LAB 4: Your code here.

	// panic("pgfault not implemented");
}
  801035:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801038:	5b                   	pop    %ebx
  801039:	5e                   	pop    %esi
  80103a:	5d                   	pop    %ebp
  80103b:	c3                   	ret    

0080103c <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  80103c:	55                   	push   %ebp
  80103d:	89 e5                	mov    %esp,%ebp
  80103f:	57                   	push   %edi
  801040:	56                   	push   %esi
  801041:	53                   	push   %ebx
  801042:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	struct PageInfo* pg = NULL;
	set_pgfault_handler(pgfault);
  801045:	68 4d 0f 80 00       	push   $0x800f4d
  80104a:	e8 71 0e 00 00       	call   801ec0 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  80104f:	b8 07 00 00 00       	mov    $0x7,%eax
  801054:	cd 30                	int    $0x30
  801056:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801059:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t eid = sys_exofork();
	if (eid < 0) panic("fork fault.\n");
  80105c:	83 c4 10             	add    $0x10,%esp
  80105f:	85 c0                	test   %eax,%eax
  801061:	79 14                	jns    801077 <fork+0x3b>
  801063:	83 ec 04             	sub    $0x4,%esp
  801066:	68 e2 27 80 00       	push   $0x8027e2
  80106b:	6a 71                	push   $0x71
  80106d:	68 87 27 80 00       	push   $0x802787
  801072:	e8 b8 f1 ff ff       	call   80022f <_panic>
	if (eid == 0){
  801077:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80107b:	75 25                	jne    8010a2 <fork+0x66>
		thisenv = &envs[ENVX(sys_getenvid())];
  80107d:	e8 9c fc ff ff       	call   800d1e <sys_getenvid>
  801082:	25 ff 03 00 00       	and    $0x3ff,%eax
  801087:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80108e:	c1 e0 07             	shl    $0x7,%eax
  801091:	29 d0                	sub    %edx,%eax
  801093:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801098:	a3 04 40 80 00       	mov    %eax,0x804004
		return eid;
  80109d:	e9 61 01 00 00       	jmp    801203 <fork+0x1c7>
  8010a2:	bb 00 00 80 00       	mov    $0x800000,%ebx
	}
	// copy something to the child page.
	for (uintptr_t i = UTEXT;i <= USTACKTOP;i += PGSIZE){
		if (uvpd[PDX(i)] & PTE_P && (uvpt[PGNUM(i)] & PTE_P)){
  8010a7:	89 d8                	mov    %ebx,%eax
  8010a9:	c1 e8 16             	shr    $0x16,%eax
  8010ac:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010b3:	a8 01                	test   $0x1,%al
  8010b5:	74 52                	je     801109 <fork+0xcd>
  8010b7:	89 de                	mov    %ebx,%esi
  8010b9:	c1 ee 0c             	shr    $0xc,%esi
  8010bc:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8010c3:	a8 01                	test   $0x1,%al
  8010c5:	74 42                	je     801109 <fork+0xcd>
duppage(envid_t envid, unsigned pn)
{
	int r;

	// LAB 4: Your code here.
	envid_t myenvid = sys_getenvid();
  8010c7:	e8 52 fc ff ff       	call   800d1e <sys_getenvid>
  8010cc:	89 c7                	mov    %eax,%edi
	pte_t pte = uvpt[pn];
  8010ce:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
	int perm = PTE_U | PTE_P;
	if(pte & PTE_W || pte & PTE_COW)
  8010d5:	a9 02 08 00 00       	test   $0x802,%eax
  8010da:	0f 85 de 00 00 00    	jne    8011be <fork+0x182>
  8010e0:	e9 fb 00 00 00       	jmp    8011e0 <fork+0x1a4>
		perm |= PTE_COW;
	if((r = sys_page_map(myenvid,(void*)(pn*PGSIZE),envid,(void*)(pn*PGSIZE),perm))<0){
		panic("duppage fault :%e\n",r);
  8010e5:	50                   	push   %eax
  8010e6:	68 ef 27 80 00       	push   $0x8027ef
  8010eb:	6a 50                	push   $0x50
  8010ed:	68 87 27 80 00       	push   $0x802787
  8010f2:	e8 38 f1 ff ff       	call   80022f <_panic>
	}
	if(perm & PTE_COW){
		if((r = sys_page_map(myenvid,(void*)(pn*PGSIZE),myenvid,(void*)(pn*PGSIZE),perm))<0)
			panic("duppage fault :%e\n",r);
  8010f7:	50                   	push   %eax
  8010f8:	68 ef 27 80 00       	push   $0x8027ef
  8010fd:	6a 54                	push   $0x54
  8010ff:	68 87 27 80 00       	push   $0x802787
  801104:	e8 26 f1 ff ff       	call   80022f <_panic>
	if (eid == 0){
		thisenv = &envs[ENVX(sys_getenvid())];
		return eid;
	}
	// copy something to the child page.
	for (uintptr_t i = UTEXT;i <= USTACKTOP;i += PGSIZE){
  801109:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80110f:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  801115:	75 90                	jne    8010a7 <fork+0x6b>
		if (uvpd[PDX(i)] & PTE_P && (uvpt[PGNUM(i)] & PTE_P)){
			duppage(eid,PGNUM(i));
		}
	}
	int r = sys_page_alloc(eid,(void*)(UXSTACKTOP-PGSIZE),PTE_U|PTE_P|PTE_W);
  801117:	83 ec 04             	sub    $0x4,%esp
  80111a:	6a 07                	push   $0x7
  80111c:	68 00 f0 bf ee       	push   $0xeebff000
  801121:	ff 75 e0             	pushl  -0x20(%ebp)
  801124:	e8 33 fc ff ff       	call   800d5c <sys_page_alloc>
	if (r < 0) panic("fork fault.\n");
  801129:	83 c4 10             	add    $0x10,%esp
  80112c:	85 c0                	test   %eax,%eax
  80112e:	79 14                	jns    801144 <fork+0x108>
  801130:	83 ec 04             	sub    $0x4,%esp
  801133:	68 e2 27 80 00       	push   $0x8027e2
  801138:	6a 7d                	push   $0x7d
  80113a:	68 87 27 80 00       	push   $0x802787
  80113f:	e8 eb f0 ff ff       	call   80022f <_panic>

	extern void _pgfault_upcall();
    r = sys_env_set_pgfault_upcall(eid, _pgfault_upcall);
  801144:	83 ec 08             	sub    $0x8,%esp
  801147:	68 38 1f 80 00       	push   $0x801f38
  80114c:	ff 75 e0             	pushl  -0x20(%ebp)
  80114f:	e8 53 fd ff ff       	call   800ea7 <sys_env_set_pgfault_upcall>
    if (r < 0) panic("fork fault 3\n");
  801154:	83 c4 10             	add    $0x10,%esp
  801157:	85 c0                	test   %eax,%eax
  801159:	79 17                	jns    801172 <fork+0x136>
  80115b:	83 ec 04             	sub    $0x4,%esp
  80115e:	68 02 28 80 00       	push   $0x802802
  801163:	68 81 00 00 00       	push   $0x81
  801168:	68 87 27 80 00       	push   $0x802787
  80116d:	e8 bd f0 ff ff       	call   80022f <_panic>

	if ((r = sys_env_set_status(eid, ENV_RUNNABLE)) < 0)
  801172:	83 ec 08             	sub    $0x8,%esp
  801175:	6a 02                	push   $0x2
  801177:	ff 75 e0             	pushl  -0x20(%ebp)
  80117a:	e8 a4 fc ff ff       	call   800e23 <sys_env_set_status>
  80117f:	83 c4 10             	add    $0x10,%esp
  801182:	85 c0                	test   %eax,%eax
  801184:	79 7d                	jns    801203 <fork+0x1c7>
        panic("fork fault 4\n");
  801186:	83 ec 04             	sub    $0x4,%esp
  801189:	68 10 28 80 00       	push   $0x802810
  80118e:	68 84 00 00 00       	push   $0x84
  801193:	68 87 27 80 00       	push   $0x802787
  801198:	e8 92 f0 ff ff       	call   80022f <_panic>
		perm |= PTE_COW;
	if((r = sys_page_map(myenvid,(void*)(pn*PGSIZE),envid,(void*)(pn*PGSIZE),perm))<0){
		panic("duppage fault :%e\n",r);
	}
	if(perm & PTE_COW){
		if((r = sys_page_map(myenvid,(void*)(pn*PGSIZE),myenvid,(void*)(pn*PGSIZE),perm))<0)
  80119d:	83 ec 0c             	sub    $0xc,%esp
  8011a0:	68 05 08 00 00       	push   $0x805
  8011a5:	56                   	push   %esi
  8011a6:	57                   	push   %edi
  8011a7:	56                   	push   %esi
  8011a8:	57                   	push   %edi
  8011a9:	e8 f1 fb ff ff       	call   800d9f <sys_page_map>
  8011ae:	83 c4 20             	add    $0x20,%esp
  8011b1:	85 c0                	test   %eax,%eax
  8011b3:	0f 89 50 ff ff ff    	jns    801109 <fork+0xcd>
  8011b9:	e9 39 ff ff ff       	jmp    8010f7 <fork+0xbb>
	envid_t myenvid = sys_getenvid();
	pte_t pte = uvpt[pn];
	int perm = PTE_U | PTE_P;
	if(pte & PTE_W || pte & PTE_COW)
		perm |= PTE_COW;
	if((r = sys_page_map(myenvid,(void*)(pn*PGSIZE),envid,(void*)(pn*PGSIZE),perm))<0){
  8011be:	c1 e6 0c             	shl    $0xc,%esi
  8011c1:	83 ec 0c             	sub    $0xc,%esp
  8011c4:	68 05 08 00 00       	push   $0x805
  8011c9:	56                   	push   %esi
  8011ca:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011cd:	56                   	push   %esi
  8011ce:	57                   	push   %edi
  8011cf:	e8 cb fb ff ff       	call   800d9f <sys_page_map>
  8011d4:	83 c4 20             	add    $0x20,%esp
  8011d7:	85 c0                	test   %eax,%eax
  8011d9:	79 c2                	jns    80119d <fork+0x161>
  8011db:	e9 05 ff ff ff       	jmp    8010e5 <fork+0xa9>
  8011e0:	c1 e6 0c             	shl    $0xc,%esi
  8011e3:	83 ec 0c             	sub    $0xc,%esp
  8011e6:	6a 05                	push   $0x5
  8011e8:	56                   	push   %esi
  8011e9:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011ec:	56                   	push   %esi
  8011ed:	57                   	push   %edi
  8011ee:	e8 ac fb ff ff       	call   800d9f <sys_page_map>
  8011f3:	83 c4 20             	add    $0x20,%esp
  8011f6:	85 c0                	test   %eax,%eax
  8011f8:	0f 89 0b ff ff ff    	jns    801109 <fork+0xcd>
  8011fe:	e9 e2 fe ff ff       	jmp    8010e5 <fork+0xa9>
    if (r < 0) panic("fork fault 3\n");

	if ((r = sys_env_set_status(eid, ENV_RUNNABLE)) < 0)
        panic("fork fault 4\n");
    return eid;
}
  801203:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801206:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801209:	5b                   	pop    %ebx
  80120a:	5e                   	pop    %esi
  80120b:	5f                   	pop    %edi
  80120c:	5d                   	pop    %ebp
  80120d:	c3                   	ret    

0080120e <sfork>:

// Challenge!
int
sfork(void)
{
  80120e:	55                   	push   %ebp
  80120f:	89 e5                	mov    %esp,%ebp
  801211:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801214:	68 1e 28 80 00       	push   $0x80281e
  801219:	68 8c 00 00 00       	push   $0x8c
  80121e:	68 87 27 80 00       	push   $0x802787
  801223:	e8 07 f0 ff ff       	call   80022f <_panic>

00801228 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801228:	55                   	push   %ebp
  801229:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80122b:	8b 45 08             	mov    0x8(%ebp),%eax
  80122e:	05 00 00 00 30       	add    $0x30000000,%eax
  801233:	c1 e8 0c             	shr    $0xc,%eax
}
  801236:	5d                   	pop    %ebp
  801237:	c3                   	ret    

00801238 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801238:	55                   	push   %ebp
  801239:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80123b:	8b 45 08             	mov    0x8(%ebp),%eax
  80123e:	05 00 00 00 30       	add    $0x30000000,%eax
  801243:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801248:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80124d:	5d                   	pop    %ebp
  80124e:	c3                   	ret    

0080124f <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80124f:	55                   	push   %ebp
  801250:	89 e5                	mov    %esp,%ebp
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801252:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  801257:	a8 01                	test   $0x1,%al
  801259:	74 34                	je     80128f <fd_alloc+0x40>
  80125b:	a1 00 00 74 ef       	mov    0xef740000,%eax
  801260:	a8 01                	test   $0x1,%al
  801262:	74 32                	je     801296 <fd_alloc+0x47>
  801264:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  801269:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80126b:	89 c2                	mov    %eax,%edx
  80126d:	c1 ea 16             	shr    $0x16,%edx
  801270:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801277:	f6 c2 01             	test   $0x1,%dl
  80127a:	74 1f                	je     80129b <fd_alloc+0x4c>
  80127c:	89 c2                	mov    %eax,%edx
  80127e:	c1 ea 0c             	shr    $0xc,%edx
  801281:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801288:	f6 c2 01             	test   $0x1,%dl
  80128b:	75 1a                	jne    8012a7 <fd_alloc+0x58>
  80128d:	eb 0c                	jmp    80129b <fd_alloc+0x4c>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  80128f:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  801294:	eb 05                	jmp    80129b <fd_alloc+0x4c>
  801296:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  80129b:	8b 45 08             	mov    0x8(%ebp),%eax
  80129e:	89 08                	mov    %ecx,(%eax)
			return 0;
  8012a0:	b8 00 00 00 00       	mov    $0x0,%eax
  8012a5:	eb 1a                	jmp    8012c1 <fd_alloc+0x72>
  8012a7:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8012ac:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8012b1:	75 b6                	jne    801269 <fd_alloc+0x1a>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8012b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8012b6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  8012bc:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8012c1:	5d                   	pop    %ebp
  8012c2:	c3                   	ret    

008012c3 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8012c3:	55                   	push   %ebp
  8012c4:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8012c6:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
  8012ca:	77 39                	ja     801305 <fd_lookup+0x42>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8012cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8012cf:	c1 e0 0c             	shl    $0xc,%eax
  8012d2:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8012d7:	89 c2                	mov    %eax,%edx
  8012d9:	c1 ea 16             	shr    $0x16,%edx
  8012dc:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012e3:	f6 c2 01             	test   $0x1,%dl
  8012e6:	74 24                	je     80130c <fd_lookup+0x49>
  8012e8:	89 c2                	mov    %eax,%edx
  8012ea:	c1 ea 0c             	shr    $0xc,%edx
  8012ed:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012f4:	f6 c2 01             	test   $0x1,%dl
  8012f7:	74 1a                	je     801313 <fd_lookup+0x50>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8012f9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012fc:	89 02                	mov    %eax,(%edx)
	return 0;
  8012fe:	b8 00 00 00 00       	mov    $0x0,%eax
  801303:	eb 13                	jmp    801318 <fd_lookup+0x55>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801305:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80130a:	eb 0c                	jmp    801318 <fd_lookup+0x55>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80130c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801311:	eb 05                	jmp    801318 <fd_lookup+0x55>
  801313:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801318:	5d                   	pop    %ebp
  801319:	c3                   	ret    

0080131a <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80131a:	55                   	push   %ebp
  80131b:	89 e5                	mov    %esp,%ebp
  80131d:	53                   	push   %ebx
  80131e:	83 ec 04             	sub    $0x4,%esp
  801321:	8b 45 08             	mov    0x8(%ebp),%eax
  801324:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  801327:	3b 05 04 30 80 00    	cmp    0x803004,%eax
  80132d:	75 1e                	jne    80134d <dev_lookup+0x33>
  80132f:	eb 0e                	jmp    80133f <dev_lookup+0x25>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801331:	b8 20 30 80 00       	mov    $0x803020,%eax
  801336:	eb 0c                	jmp    801344 <dev_lookup+0x2a>
  801338:	b8 3c 30 80 00       	mov    $0x80303c,%eax
  80133d:	eb 05                	jmp    801344 <dev_lookup+0x2a>
  80133f:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  801344:	89 03                	mov    %eax,(%ebx)
			return 0;
  801346:	b8 00 00 00 00       	mov    $0x0,%eax
  80134b:	eb 36                	jmp    801383 <dev_lookup+0x69>
int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  80134d:	3b 05 20 30 80 00    	cmp    0x803020,%eax
  801353:	74 dc                	je     801331 <dev_lookup+0x17>
  801355:	3b 05 3c 30 80 00    	cmp    0x80303c,%eax
  80135b:	74 db                	je     801338 <dev_lookup+0x1e>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80135d:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801363:	8b 52 48             	mov    0x48(%edx),%edx
  801366:	83 ec 04             	sub    $0x4,%esp
  801369:	50                   	push   %eax
  80136a:	52                   	push   %edx
  80136b:	68 54 28 80 00       	push   $0x802854
  801370:	e8 92 ef ff ff       	call   800307 <cprintf>
	*dev = 0;
  801375:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  80137b:	83 c4 10             	add    $0x10,%esp
  80137e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801383:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801386:	c9                   	leave  
  801387:	c3                   	ret    

00801388 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801388:	55                   	push   %ebp
  801389:	89 e5                	mov    %esp,%ebp
  80138b:	56                   	push   %esi
  80138c:	53                   	push   %ebx
  80138d:	83 ec 10             	sub    $0x10,%esp
  801390:	8b 75 08             	mov    0x8(%ebp),%esi
  801393:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801396:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801399:	50                   	push   %eax
  80139a:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8013a0:	c1 e8 0c             	shr    $0xc,%eax
  8013a3:	50                   	push   %eax
  8013a4:	e8 1a ff ff ff       	call   8012c3 <fd_lookup>
  8013a9:	83 c4 08             	add    $0x8,%esp
  8013ac:	85 c0                	test   %eax,%eax
  8013ae:	78 05                	js     8013b5 <fd_close+0x2d>
	    || fd != fd2)
  8013b0:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8013b3:	74 06                	je     8013bb <fd_close+0x33>
		return (must_exist ? r : 0);
  8013b5:	84 db                	test   %bl,%bl
  8013b7:	74 47                	je     801400 <fd_close+0x78>
  8013b9:	eb 4a                	jmp    801405 <fd_close+0x7d>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8013bb:	83 ec 08             	sub    $0x8,%esp
  8013be:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013c1:	50                   	push   %eax
  8013c2:	ff 36                	pushl  (%esi)
  8013c4:	e8 51 ff ff ff       	call   80131a <dev_lookup>
  8013c9:	89 c3                	mov    %eax,%ebx
  8013cb:	83 c4 10             	add    $0x10,%esp
  8013ce:	85 c0                	test   %eax,%eax
  8013d0:	78 1c                	js     8013ee <fd_close+0x66>
		if (dev->dev_close)
  8013d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013d5:	8b 40 10             	mov    0x10(%eax),%eax
  8013d8:	85 c0                	test   %eax,%eax
  8013da:	74 0d                	je     8013e9 <fd_close+0x61>
			r = (*dev->dev_close)(fd);
  8013dc:	83 ec 0c             	sub    $0xc,%esp
  8013df:	56                   	push   %esi
  8013e0:	ff d0                	call   *%eax
  8013e2:	89 c3                	mov    %eax,%ebx
  8013e4:	83 c4 10             	add    $0x10,%esp
  8013e7:	eb 05                	jmp    8013ee <fd_close+0x66>
		else
			r = 0;
  8013e9:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8013ee:	83 ec 08             	sub    $0x8,%esp
  8013f1:	56                   	push   %esi
  8013f2:	6a 00                	push   $0x0
  8013f4:	e8 e8 f9 ff ff       	call   800de1 <sys_page_unmap>
	return r;
  8013f9:	83 c4 10             	add    $0x10,%esp
  8013fc:	89 d8                	mov    %ebx,%eax
  8013fe:	eb 05                	jmp    801405 <fd_close+0x7d>
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
  801400:	b8 00 00 00 00       	mov    $0x0,%eax
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
	return r;
}
  801405:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801408:	5b                   	pop    %ebx
  801409:	5e                   	pop    %esi
  80140a:	5d                   	pop    %ebp
  80140b:	c3                   	ret    

0080140c <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80140c:	55                   	push   %ebp
  80140d:	89 e5                	mov    %esp,%ebp
  80140f:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801412:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801415:	50                   	push   %eax
  801416:	ff 75 08             	pushl  0x8(%ebp)
  801419:	e8 a5 fe ff ff       	call   8012c3 <fd_lookup>
  80141e:	83 c4 08             	add    $0x8,%esp
  801421:	85 c0                	test   %eax,%eax
  801423:	78 10                	js     801435 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801425:	83 ec 08             	sub    $0x8,%esp
  801428:	6a 01                	push   $0x1
  80142a:	ff 75 f4             	pushl  -0xc(%ebp)
  80142d:	e8 56 ff ff ff       	call   801388 <fd_close>
  801432:	83 c4 10             	add    $0x10,%esp
}
  801435:	c9                   	leave  
  801436:	c3                   	ret    

00801437 <close_all>:

void
close_all(void)
{
  801437:	55                   	push   %ebp
  801438:	89 e5                	mov    %esp,%ebp
  80143a:	53                   	push   %ebx
  80143b:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80143e:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801443:	83 ec 0c             	sub    $0xc,%esp
  801446:	53                   	push   %ebx
  801447:	e8 c0 ff ff ff       	call   80140c <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80144c:	43                   	inc    %ebx
  80144d:	83 c4 10             	add    $0x10,%esp
  801450:	83 fb 20             	cmp    $0x20,%ebx
  801453:	75 ee                	jne    801443 <close_all+0xc>
		close(i);
}
  801455:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801458:	c9                   	leave  
  801459:	c3                   	ret    

0080145a <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80145a:	55                   	push   %ebp
  80145b:	89 e5                	mov    %esp,%ebp
  80145d:	57                   	push   %edi
  80145e:	56                   	push   %esi
  80145f:	53                   	push   %ebx
  801460:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801463:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801466:	50                   	push   %eax
  801467:	ff 75 08             	pushl  0x8(%ebp)
  80146a:	e8 54 fe ff ff       	call   8012c3 <fd_lookup>
  80146f:	83 c4 08             	add    $0x8,%esp
  801472:	85 c0                	test   %eax,%eax
  801474:	0f 88 c2 00 00 00    	js     80153c <dup+0xe2>
		return r;
	close(newfdnum);
  80147a:	83 ec 0c             	sub    $0xc,%esp
  80147d:	ff 75 0c             	pushl  0xc(%ebp)
  801480:	e8 87 ff ff ff       	call   80140c <close>

	newfd = INDEX2FD(newfdnum);
  801485:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801488:	c1 e3 0c             	shl    $0xc,%ebx
  80148b:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801491:	83 c4 04             	add    $0x4,%esp
  801494:	ff 75 e4             	pushl  -0x1c(%ebp)
  801497:	e8 9c fd ff ff       	call   801238 <fd2data>
  80149c:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  80149e:	89 1c 24             	mov    %ebx,(%esp)
  8014a1:	e8 92 fd ff ff       	call   801238 <fd2data>
  8014a6:	83 c4 10             	add    $0x10,%esp
  8014a9:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8014ab:	89 f0                	mov    %esi,%eax
  8014ad:	c1 e8 16             	shr    $0x16,%eax
  8014b0:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8014b7:	a8 01                	test   $0x1,%al
  8014b9:	74 35                	je     8014f0 <dup+0x96>
  8014bb:	89 f0                	mov    %esi,%eax
  8014bd:	c1 e8 0c             	shr    $0xc,%eax
  8014c0:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8014c7:	f6 c2 01             	test   $0x1,%dl
  8014ca:	74 24                	je     8014f0 <dup+0x96>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8014cc:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014d3:	83 ec 0c             	sub    $0xc,%esp
  8014d6:	25 07 0e 00 00       	and    $0xe07,%eax
  8014db:	50                   	push   %eax
  8014dc:	57                   	push   %edi
  8014dd:	6a 00                	push   $0x0
  8014df:	56                   	push   %esi
  8014e0:	6a 00                	push   $0x0
  8014e2:	e8 b8 f8 ff ff       	call   800d9f <sys_page_map>
  8014e7:	89 c6                	mov    %eax,%esi
  8014e9:	83 c4 20             	add    $0x20,%esp
  8014ec:	85 c0                	test   %eax,%eax
  8014ee:	78 2c                	js     80151c <dup+0xc2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014f0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8014f3:	89 d0                	mov    %edx,%eax
  8014f5:	c1 e8 0c             	shr    $0xc,%eax
  8014f8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014ff:	83 ec 0c             	sub    $0xc,%esp
  801502:	25 07 0e 00 00       	and    $0xe07,%eax
  801507:	50                   	push   %eax
  801508:	53                   	push   %ebx
  801509:	6a 00                	push   $0x0
  80150b:	52                   	push   %edx
  80150c:	6a 00                	push   $0x0
  80150e:	e8 8c f8 ff ff       	call   800d9f <sys_page_map>
  801513:	89 c6                	mov    %eax,%esi
  801515:	83 c4 20             	add    $0x20,%esp
  801518:	85 c0                	test   %eax,%eax
  80151a:	79 1d                	jns    801539 <dup+0xdf>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80151c:	83 ec 08             	sub    $0x8,%esp
  80151f:	53                   	push   %ebx
  801520:	6a 00                	push   $0x0
  801522:	e8 ba f8 ff ff       	call   800de1 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801527:	83 c4 08             	add    $0x8,%esp
  80152a:	57                   	push   %edi
  80152b:	6a 00                	push   $0x0
  80152d:	e8 af f8 ff ff       	call   800de1 <sys_page_unmap>
	return r;
  801532:	83 c4 10             	add    $0x10,%esp
  801535:	89 f0                	mov    %esi,%eax
  801537:	eb 03                	jmp    80153c <dup+0xe2>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801539:	8b 45 0c             	mov    0xc(%ebp),%eax

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80153c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80153f:	5b                   	pop    %ebx
  801540:	5e                   	pop    %esi
  801541:	5f                   	pop    %edi
  801542:	5d                   	pop    %ebp
  801543:	c3                   	ret    

00801544 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801544:	55                   	push   %ebp
  801545:	89 e5                	mov    %esp,%ebp
  801547:	53                   	push   %ebx
  801548:	83 ec 14             	sub    $0x14,%esp
  80154b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80154e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801551:	50                   	push   %eax
  801552:	53                   	push   %ebx
  801553:	e8 6b fd ff ff       	call   8012c3 <fd_lookup>
  801558:	83 c4 08             	add    $0x8,%esp
  80155b:	85 c0                	test   %eax,%eax
  80155d:	78 67                	js     8015c6 <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80155f:	83 ec 08             	sub    $0x8,%esp
  801562:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801565:	50                   	push   %eax
  801566:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801569:	ff 30                	pushl  (%eax)
  80156b:	e8 aa fd ff ff       	call   80131a <dev_lookup>
  801570:	83 c4 10             	add    $0x10,%esp
  801573:	85 c0                	test   %eax,%eax
  801575:	78 4f                	js     8015c6 <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801577:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80157a:	8b 42 08             	mov    0x8(%edx),%eax
  80157d:	83 e0 03             	and    $0x3,%eax
  801580:	83 f8 01             	cmp    $0x1,%eax
  801583:	75 21                	jne    8015a6 <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801585:	a1 04 40 80 00       	mov    0x804004,%eax
  80158a:	8b 40 48             	mov    0x48(%eax),%eax
  80158d:	83 ec 04             	sub    $0x4,%esp
  801590:	53                   	push   %ebx
  801591:	50                   	push   %eax
  801592:	68 98 28 80 00       	push   $0x802898
  801597:	e8 6b ed ff ff       	call   800307 <cprintf>
		return -E_INVAL;
  80159c:	83 c4 10             	add    $0x10,%esp
  80159f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015a4:	eb 20                	jmp    8015c6 <read+0x82>
	}
	if (!dev->dev_read)
  8015a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015a9:	8b 40 08             	mov    0x8(%eax),%eax
  8015ac:	85 c0                	test   %eax,%eax
  8015ae:	74 11                	je     8015c1 <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8015b0:	83 ec 04             	sub    $0x4,%esp
  8015b3:	ff 75 10             	pushl  0x10(%ebp)
  8015b6:	ff 75 0c             	pushl  0xc(%ebp)
  8015b9:	52                   	push   %edx
  8015ba:	ff d0                	call   *%eax
  8015bc:	83 c4 10             	add    $0x10,%esp
  8015bf:	eb 05                	jmp    8015c6 <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8015c1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8015c6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015c9:	c9                   	leave  
  8015ca:	c3                   	ret    

008015cb <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8015cb:	55                   	push   %ebp
  8015cc:	89 e5                	mov    %esp,%ebp
  8015ce:	57                   	push   %edi
  8015cf:	56                   	push   %esi
  8015d0:	53                   	push   %ebx
  8015d1:	83 ec 0c             	sub    $0xc,%esp
  8015d4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8015d7:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015da:	85 f6                	test   %esi,%esi
  8015dc:	74 31                	je     80160f <readn+0x44>
  8015de:	b8 00 00 00 00       	mov    $0x0,%eax
  8015e3:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  8015e8:	83 ec 04             	sub    $0x4,%esp
  8015eb:	89 f2                	mov    %esi,%edx
  8015ed:	29 c2                	sub    %eax,%edx
  8015ef:	52                   	push   %edx
  8015f0:	03 45 0c             	add    0xc(%ebp),%eax
  8015f3:	50                   	push   %eax
  8015f4:	57                   	push   %edi
  8015f5:	e8 4a ff ff ff       	call   801544 <read>
		if (m < 0)
  8015fa:	83 c4 10             	add    $0x10,%esp
  8015fd:	85 c0                	test   %eax,%eax
  8015ff:	78 17                	js     801618 <readn+0x4d>
			return m;
		if (m == 0)
  801601:	85 c0                	test   %eax,%eax
  801603:	74 11                	je     801616 <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801605:	01 c3                	add    %eax,%ebx
  801607:	89 d8                	mov    %ebx,%eax
  801609:	39 f3                	cmp    %esi,%ebx
  80160b:	72 db                	jb     8015e8 <readn+0x1d>
  80160d:	eb 09                	jmp    801618 <readn+0x4d>
  80160f:	b8 00 00 00 00       	mov    $0x0,%eax
  801614:	eb 02                	jmp    801618 <readn+0x4d>
  801616:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801618:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80161b:	5b                   	pop    %ebx
  80161c:	5e                   	pop    %esi
  80161d:	5f                   	pop    %edi
  80161e:	5d                   	pop    %ebp
  80161f:	c3                   	ret    

00801620 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801620:	55                   	push   %ebp
  801621:	89 e5                	mov    %esp,%ebp
  801623:	53                   	push   %ebx
  801624:	83 ec 14             	sub    $0x14,%esp
  801627:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80162a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80162d:	50                   	push   %eax
  80162e:	53                   	push   %ebx
  80162f:	e8 8f fc ff ff       	call   8012c3 <fd_lookup>
  801634:	83 c4 08             	add    $0x8,%esp
  801637:	85 c0                	test   %eax,%eax
  801639:	78 62                	js     80169d <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80163b:	83 ec 08             	sub    $0x8,%esp
  80163e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801641:	50                   	push   %eax
  801642:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801645:	ff 30                	pushl  (%eax)
  801647:	e8 ce fc ff ff       	call   80131a <dev_lookup>
  80164c:	83 c4 10             	add    $0x10,%esp
  80164f:	85 c0                	test   %eax,%eax
  801651:	78 4a                	js     80169d <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801653:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801656:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80165a:	75 21                	jne    80167d <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80165c:	a1 04 40 80 00       	mov    0x804004,%eax
  801661:	8b 40 48             	mov    0x48(%eax),%eax
  801664:	83 ec 04             	sub    $0x4,%esp
  801667:	53                   	push   %ebx
  801668:	50                   	push   %eax
  801669:	68 b4 28 80 00       	push   $0x8028b4
  80166e:	e8 94 ec ff ff       	call   800307 <cprintf>
		return -E_INVAL;
  801673:	83 c4 10             	add    $0x10,%esp
  801676:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80167b:	eb 20                	jmp    80169d <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80167d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801680:	8b 52 0c             	mov    0xc(%edx),%edx
  801683:	85 d2                	test   %edx,%edx
  801685:	74 11                	je     801698 <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801687:	83 ec 04             	sub    $0x4,%esp
  80168a:	ff 75 10             	pushl  0x10(%ebp)
  80168d:	ff 75 0c             	pushl  0xc(%ebp)
  801690:	50                   	push   %eax
  801691:	ff d2                	call   *%edx
  801693:	83 c4 10             	add    $0x10,%esp
  801696:	eb 05                	jmp    80169d <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801698:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  80169d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016a0:	c9                   	leave  
  8016a1:	c3                   	ret    

008016a2 <seek>:

int
seek(int fdnum, off_t offset)
{
  8016a2:	55                   	push   %ebp
  8016a3:	89 e5                	mov    %esp,%ebp
  8016a5:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8016a8:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8016ab:	50                   	push   %eax
  8016ac:	ff 75 08             	pushl  0x8(%ebp)
  8016af:	e8 0f fc ff ff       	call   8012c3 <fd_lookup>
  8016b4:	83 c4 08             	add    $0x8,%esp
  8016b7:	85 c0                	test   %eax,%eax
  8016b9:	78 0e                	js     8016c9 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8016bb:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8016be:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016c1:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8016c4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016c9:	c9                   	leave  
  8016ca:	c3                   	ret    

008016cb <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8016cb:	55                   	push   %ebp
  8016cc:	89 e5                	mov    %esp,%ebp
  8016ce:	53                   	push   %ebx
  8016cf:	83 ec 14             	sub    $0x14,%esp
  8016d2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016d5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016d8:	50                   	push   %eax
  8016d9:	53                   	push   %ebx
  8016da:	e8 e4 fb ff ff       	call   8012c3 <fd_lookup>
  8016df:	83 c4 08             	add    $0x8,%esp
  8016e2:	85 c0                	test   %eax,%eax
  8016e4:	78 5f                	js     801745 <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016e6:	83 ec 08             	sub    $0x8,%esp
  8016e9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016ec:	50                   	push   %eax
  8016ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016f0:	ff 30                	pushl  (%eax)
  8016f2:	e8 23 fc ff ff       	call   80131a <dev_lookup>
  8016f7:	83 c4 10             	add    $0x10,%esp
  8016fa:	85 c0                	test   %eax,%eax
  8016fc:	78 47                	js     801745 <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801701:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801705:	75 21                	jne    801728 <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801707:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80170c:	8b 40 48             	mov    0x48(%eax),%eax
  80170f:	83 ec 04             	sub    $0x4,%esp
  801712:	53                   	push   %ebx
  801713:	50                   	push   %eax
  801714:	68 74 28 80 00       	push   $0x802874
  801719:	e8 e9 eb ff ff       	call   800307 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80171e:	83 c4 10             	add    $0x10,%esp
  801721:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801726:	eb 1d                	jmp    801745 <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  801728:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80172b:	8b 52 18             	mov    0x18(%edx),%edx
  80172e:	85 d2                	test   %edx,%edx
  801730:	74 0e                	je     801740 <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801732:	83 ec 08             	sub    $0x8,%esp
  801735:	ff 75 0c             	pushl  0xc(%ebp)
  801738:	50                   	push   %eax
  801739:	ff d2                	call   *%edx
  80173b:	83 c4 10             	add    $0x10,%esp
  80173e:	eb 05                	jmp    801745 <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801740:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801745:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801748:	c9                   	leave  
  801749:	c3                   	ret    

0080174a <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80174a:	55                   	push   %ebp
  80174b:	89 e5                	mov    %esp,%ebp
  80174d:	53                   	push   %ebx
  80174e:	83 ec 14             	sub    $0x14,%esp
  801751:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801754:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801757:	50                   	push   %eax
  801758:	ff 75 08             	pushl  0x8(%ebp)
  80175b:	e8 63 fb ff ff       	call   8012c3 <fd_lookup>
  801760:	83 c4 08             	add    $0x8,%esp
  801763:	85 c0                	test   %eax,%eax
  801765:	78 52                	js     8017b9 <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801767:	83 ec 08             	sub    $0x8,%esp
  80176a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80176d:	50                   	push   %eax
  80176e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801771:	ff 30                	pushl  (%eax)
  801773:	e8 a2 fb ff ff       	call   80131a <dev_lookup>
  801778:	83 c4 10             	add    $0x10,%esp
  80177b:	85 c0                	test   %eax,%eax
  80177d:	78 3a                	js     8017b9 <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  80177f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801782:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801786:	74 2c                	je     8017b4 <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801788:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80178b:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801792:	00 00 00 
	stat->st_isdir = 0;
  801795:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80179c:	00 00 00 
	stat->st_dev = dev;
  80179f:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8017a5:	83 ec 08             	sub    $0x8,%esp
  8017a8:	53                   	push   %ebx
  8017a9:	ff 75 f0             	pushl  -0x10(%ebp)
  8017ac:	ff 50 14             	call   *0x14(%eax)
  8017af:	83 c4 10             	add    $0x10,%esp
  8017b2:	eb 05                	jmp    8017b9 <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8017b4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8017b9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017bc:	c9                   	leave  
  8017bd:	c3                   	ret    

008017be <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8017be:	55                   	push   %ebp
  8017bf:	89 e5                	mov    %esp,%ebp
  8017c1:	56                   	push   %esi
  8017c2:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8017c3:	83 ec 08             	sub    $0x8,%esp
  8017c6:	6a 00                	push   $0x0
  8017c8:	ff 75 08             	pushl  0x8(%ebp)
  8017cb:	e8 75 01 00 00       	call   801945 <open>
  8017d0:	89 c3                	mov    %eax,%ebx
  8017d2:	83 c4 10             	add    $0x10,%esp
  8017d5:	85 c0                	test   %eax,%eax
  8017d7:	78 1d                	js     8017f6 <stat+0x38>
		return fd;
	r = fstat(fd, stat);
  8017d9:	83 ec 08             	sub    $0x8,%esp
  8017dc:	ff 75 0c             	pushl  0xc(%ebp)
  8017df:	50                   	push   %eax
  8017e0:	e8 65 ff ff ff       	call   80174a <fstat>
  8017e5:	89 c6                	mov    %eax,%esi
	close(fd);
  8017e7:	89 1c 24             	mov    %ebx,(%esp)
  8017ea:	e8 1d fc ff ff       	call   80140c <close>
	return r;
  8017ef:	83 c4 10             	add    $0x10,%esp
  8017f2:	89 f0                	mov    %esi,%eax
  8017f4:	eb 00                	jmp    8017f6 <stat+0x38>
}
  8017f6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017f9:	5b                   	pop    %ebx
  8017fa:	5e                   	pop    %esi
  8017fb:	5d                   	pop    %ebp
  8017fc:	c3                   	ret    

008017fd <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8017fd:	55                   	push   %ebp
  8017fe:	89 e5                	mov    %esp,%ebp
  801800:	56                   	push   %esi
  801801:	53                   	push   %ebx
  801802:	89 c6                	mov    %eax,%esi
  801804:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801806:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80180d:	75 12                	jne    801821 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80180f:	83 ec 0c             	sub    $0xc,%esp
  801812:	6a 01                	push   $0x1
  801814:	e8 19 08 00 00       	call   802032 <ipc_find_env>
  801819:	a3 00 40 80 00       	mov    %eax,0x804000
  80181e:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801821:	6a 07                	push   $0x7
  801823:	68 00 50 80 00       	push   $0x805000
  801828:	56                   	push   %esi
  801829:	ff 35 00 40 80 00    	pushl  0x804000
  80182f:	e8 9f 07 00 00       	call   801fd3 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801834:	83 c4 0c             	add    $0xc,%esp
  801837:	6a 00                	push   $0x0
  801839:	53                   	push   %ebx
  80183a:	6a 00                	push   $0x0
  80183c:	e8 1d 07 00 00       	call   801f5e <ipc_recv>
}
  801841:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801844:	5b                   	pop    %ebx
  801845:	5e                   	pop    %esi
  801846:	5d                   	pop    %ebp
  801847:	c3                   	ret    

00801848 <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801848:	55                   	push   %ebp
  801849:	89 e5                	mov    %esp,%ebp
  80184b:	53                   	push   %ebx
  80184c:	83 ec 04             	sub    $0x4,%esp
  80184f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801852:	8b 45 08             	mov    0x8(%ebp),%eax
  801855:	8b 40 0c             	mov    0xc(%eax),%eax
  801858:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80185d:	ba 00 00 00 00       	mov    $0x0,%edx
  801862:	b8 05 00 00 00       	mov    $0x5,%eax
  801867:	e8 91 ff ff ff       	call   8017fd <fsipc>
  80186c:	85 c0                	test   %eax,%eax
  80186e:	78 2c                	js     80189c <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801870:	83 ec 08             	sub    $0x8,%esp
  801873:	68 00 50 80 00       	push   $0x805000
  801878:	53                   	push   %ebx
  801879:	e8 6e f0 ff ff       	call   8008ec <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80187e:	a1 80 50 80 00       	mov    0x805080,%eax
  801883:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801889:	a1 84 50 80 00       	mov    0x805084,%eax
  80188e:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801894:	83 c4 10             	add    $0x10,%esp
  801897:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80189c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80189f:	c9                   	leave  
  8018a0:	c3                   	ret    

008018a1 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8018a1:	55                   	push   %ebp
  8018a2:	89 e5                	mov    %esp,%ebp
  8018a4:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8018a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8018aa:	8b 40 0c             	mov    0xc(%eax),%eax
  8018ad:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8018b2:	ba 00 00 00 00       	mov    $0x0,%edx
  8018b7:	b8 06 00 00 00       	mov    $0x6,%eax
  8018bc:	e8 3c ff ff ff       	call   8017fd <fsipc>
}
  8018c1:	c9                   	leave  
  8018c2:	c3                   	ret    

008018c3 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8018c3:	55                   	push   %ebp
  8018c4:	89 e5                	mov    %esp,%ebp
  8018c6:	56                   	push   %esi
  8018c7:	53                   	push   %ebx
  8018c8:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8018cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8018ce:	8b 40 0c             	mov    0xc(%eax),%eax
  8018d1:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8018d6:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8018dc:	ba 00 00 00 00       	mov    $0x0,%edx
  8018e1:	b8 03 00 00 00       	mov    $0x3,%eax
  8018e6:	e8 12 ff ff ff       	call   8017fd <fsipc>
  8018eb:	89 c3                	mov    %eax,%ebx
  8018ed:	85 c0                	test   %eax,%eax
  8018ef:	78 4b                	js     80193c <devfile_read+0x79>
		return r;
	assert(r <= n);
  8018f1:	39 c6                	cmp    %eax,%esi
  8018f3:	73 16                	jae    80190b <devfile_read+0x48>
  8018f5:	68 d1 28 80 00       	push   $0x8028d1
  8018fa:	68 d8 28 80 00       	push   $0x8028d8
  8018ff:	6a 7a                	push   $0x7a
  801901:	68 ed 28 80 00       	push   $0x8028ed
  801906:	e8 24 e9 ff ff       	call   80022f <_panic>
	assert(r <= PGSIZE);
  80190b:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801910:	7e 16                	jle    801928 <devfile_read+0x65>
  801912:	68 f8 28 80 00       	push   $0x8028f8
  801917:	68 d8 28 80 00       	push   $0x8028d8
  80191c:	6a 7b                	push   $0x7b
  80191e:	68 ed 28 80 00       	push   $0x8028ed
  801923:	e8 07 e9 ff ff       	call   80022f <_panic>
	memmove(buf, &fsipcbuf, r);
  801928:	83 ec 04             	sub    $0x4,%esp
  80192b:	50                   	push   %eax
  80192c:	68 00 50 80 00       	push   $0x805000
  801931:	ff 75 0c             	pushl  0xc(%ebp)
  801934:	e8 80 f1 ff ff       	call   800ab9 <memmove>
	return r;
  801939:	83 c4 10             	add    $0x10,%esp
}
  80193c:	89 d8                	mov    %ebx,%eax
  80193e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801941:	5b                   	pop    %ebx
  801942:	5e                   	pop    %esi
  801943:	5d                   	pop    %ebp
  801944:	c3                   	ret    

00801945 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801945:	55                   	push   %ebp
  801946:	89 e5                	mov    %esp,%ebp
  801948:	53                   	push   %ebx
  801949:	83 ec 20             	sub    $0x20,%esp
  80194c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80194f:	53                   	push   %ebx
  801950:	e8 40 ef ff ff       	call   800895 <strlen>
  801955:	83 c4 10             	add    $0x10,%esp
  801958:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80195d:	7f 63                	jg     8019c2 <open+0x7d>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80195f:	83 ec 0c             	sub    $0xc,%esp
  801962:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801965:	50                   	push   %eax
  801966:	e8 e4 f8 ff ff       	call   80124f <fd_alloc>
  80196b:	83 c4 10             	add    $0x10,%esp
  80196e:	85 c0                	test   %eax,%eax
  801970:	78 55                	js     8019c7 <open+0x82>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801972:	83 ec 08             	sub    $0x8,%esp
  801975:	53                   	push   %ebx
  801976:	68 00 50 80 00       	push   $0x805000
  80197b:	e8 6c ef ff ff       	call   8008ec <strcpy>
	fsipcbuf.open.req_omode = mode;
  801980:	8b 45 0c             	mov    0xc(%ebp),%eax
  801983:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801988:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80198b:	b8 01 00 00 00       	mov    $0x1,%eax
  801990:	e8 68 fe ff ff       	call   8017fd <fsipc>
  801995:	89 c3                	mov    %eax,%ebx
  801997:	83 c4 10             	add    $0x10,%esp
  80199a:	85 c0                	test   %eax,%eax
  80199c:	79 14                	jns    8019b2 <open+0x6d>
		fd_close(fd, 0);
  80199e:	83 ec 08             	sub    $0x8,%esp
  8019a1:	6a 00                	push   $0x0
  8019a3:	ff 75 f4             	pushl  -0xc(%ebp)
  8019a6:	e8 dd f9 ff ff       	call   801388 <fd_close>
		return r;
  8019ab:	83 c4 10             	add    $0x10,%esp
  8019ae:	89 d8                	mov    %ebx,%eax
  8019b0:	eb 15                	jmp    8019c7 <open+0x82>
	}

	return fd2num(fd);
  8019b2:	83 ec 0c             	sub    $0xc,%esp
  8019b5:	ff 75 f4             	pushl  -0xc(%ebp)
  8019b8:	e8 6b f8 ff ff       	call   801228 <fd2num>
  8019bd:	83 c4 10             	add    $0x10,%esp
  8019c0:	eb 05                	jmp    8019c7 <open+0x82>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8019c2:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8019c7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019ca:	c9                   	leave  
  8019cb:	c3                   	ret    

008019cc <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8019cc:	55                   	push   %ebp
  8019cd:	89 e5                	mov    %esp,%ebp
  8019cf:	56                   	push   %esi
  8019d0:	53                   	push   %ebx
  8019d1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8019d4:	83 ec 0c             	sub    $0xc,%esp
  8019d7:	ff 75 08             	pushl  0x8(%ebp)
  8019da:	e8 59 f8 ff ff       	call   801238 <fd2data>
  8019df:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8019e1:	83 c4 08             	add    $0x8,%esp
  8019e4:	68 04 29 80 00       	push   $0x802904
  8019e9:	53                   	push   %ebx
  8019ea:	e8 fd ee ff ff       	call   8008ec <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8019ef:	8b 46 04             	mov    0x4(%esi),%eax
  8019f2:	2b 06                	sub    (%esi),%eax
  8019f4:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8019fa:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a01:	00 00 00 
	stat->st_dev = &devpipe;
  801a04:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801a0b:	30 80 00 
	return 0;
}
  801a0e:	b8 00 00 00 00       	mov    $0x0,%eax
  801a13:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a16:	5b                   	pop    %ebx
  801a17:	5e                   	pop    %esi
  801a18:	5d                   	pop    %ebp
  801a19:	c3                   	ret    

00801a1a <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a1a:	55                   	push   %ebp
  801a1b:	89 e5                	mov    %esp,%ebp
  801a1d:	53                   	push   %ebx
  801a1e:	83 ec 0c             	sub    $0xc,%esp
  801a21:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a24:	53                   	push   %ebx
  801a25:	6a 00                	push   $0x0
  801a27:	e8 b5 f3 ff ff       	call   800de1 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a2c:	89 1c 24             	mov    %ebx,(%esp)
  801a2f:	e8 04 f8 ff ff       	call   801238 <fd2data>
  801a34:	83 c4 08             	add    $0x8,%esp
  801a37:	50                   	push   %eax
  801a38:	6a 00                	push   $0x0
  801a3a:	e8 a2 f3 ff ff       	call   800de1 <sys_page_unmap>
}
  801a3f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a42:	c9                   	leave  
  801a43:	c3                   	ret    

00801a44 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801a44:	55                   	push   %ebp
  801a45:	89 e5                	mov    %esp,%ebp
  801a47:	57                   	push   %edi
  801a48:	56                   	push   %esi
  801a49:	53                   	push   %ebx
  801a4a:	83 ec 1c             	sub    $0x1c,%esp
  801a4d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801a50:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801a52:	a1 04 40 80 00       	mov    0x804004,%eax
  801a57:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801a5a:	83 ec 0c             	sub    $0xc,%esp
  801a5d:	ff 75 e0             	pushl  -0x20(%ebp)
  801a60:	e8 28 06 00 00       	call   80208d <pageref>
  801a65:	89 c3                	mov    %eax,%ebx
  801a67:	89 3c 24             	mov    %edi,(%esp)
  801a6a:	e8 1e 06 00 00       	call   80208d <pageref>
  801a6f:	83 c4 10             	add    $0x10,%esp
  801a72:	39 c3                	cmp    %eax,%ebx
  801a74:	0f 94 c1             	sete   %cl
  801a77:	0f b6 c9             	movzbl %cl,%ecx
  801a7a:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801a7d:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801a83:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801a86:	39 ce                	cmp    %ecx,%esi
  801a88:	74 1b                	je     801aa5 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801a8a:	39 c3                	cmp    %eax,%ebx
  801a8c:	75 c4                	jne    801a52 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a8e:	8b 42 58             	mov    0x58(%edx),%eax
  801a91:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a94:	50                   	push   %eax
  801a95:	56                   	push   %esi
  801a96:	68 0b 29 80 00       	push   $0x80290b
  801a9b:	e8 67 e8 ff ff       	call   800307 <cprintf>
  801aa0:	83 c4 10             	add    $0x10,%esp
  801aa3:	eb ad                	jmp    801a52 <_pipeisclosed+0xe>
	}
}
  801aa5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801aa8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801aab:	5b                   	pop    %ebx
  801aac:	5e                   	pop    %esi
  801aad:	5f                   	pop    %edi
  801aae:	5d                   	pop    %ebp
  801aaf:	c3                   	ret    

00801ab0 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ab0:	55                   	push   %ebp
  801ab1:	89 e5                	mov    %esp,%ebp
  801ab3:	57                   	push   %edi
  801ab4:	56                   	push   %esi
  801ab5:	53                   	push   %ebx
  801ab6:	83 ec 18             	sub    $0x18,%esp
  801ab9:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801abc:	56                   	push   %esi
  801abd:	e8 76 f7 ff ff       	call   801238 <fd2data>
  801ac2:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ac4:	83 c4 10             	add    $0x10,%esp
  801ac7:	bf 00 00 00 00       	mov    $0x0,%edi
  801acc:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801ad0:	75 42                	jne    801b14 <devpipe_write+0x64>
  801ad2:	eb 4e                	jmp    801b22 <devpipe_write+0x72>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801ad4:	89 da                	mov    %ebx,%edx
  801ad6:	89 f0                	mov    %esi,%eax
  801ad8:	e8 67 ff ff ff       	call   801a44 <_pipeisclosed>
  801add:	85 c0                	test   %eax,%eax
  801adf:	75 46                	jne    801b27 <devpipe_write+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801ae1:	e8 57 f2 ff ff       	call   800d3d <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801ae6:	8b 53 04             	mov    0x4(%ebx),%edx
  801ae9:	8b 03                	mov    (%ebx),%eax
  801aeb:	83 c0 20             	add    $0x20,%eax
  801aee:	39 c2                	cmp    %eax,%edx
  801af0:	73 e2                	jae    801ad4 <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801af2:	8b 45 0c             	mov    0xc(%ebp),%eax
  801af5:	8a 0c 38             	mov    (%eax,%edi,1),%cl
  801af8:	89 d0                	mov    %edx,%eax
  801afa:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801aff:	79 05                	jns    801b06 <devpipe_write+0x56>
  801b01:	48                   	dec    %eax
  801b02:	83 c8 e0             	or     $0xffffffe0,%eax
  801b05:	40                   	inc    %eax
  801b06:	88 4c 03 08          	mov    %cl,0x8(%ebx,%eax,1)
		p->p_wpos++;
  801b0a:	42                   	inc    %edx
  801b0b:	89 53 04             	mov    %edx,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b0e:	47                   	inc    %edi
  801b0f:	39 7d 10             	cmp    %edi,0x10(%ebp)
  801b12:	74 0e                	je     801b22 <devpipe_write+0x72>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b14:	8b 53 04             	mov    0x4(%ebx),%edx
  801b17:	8b 03                	mov    (%ebx),%eax
  801b19:	83 c0 20             	add    $0x20,%eax
  801b1c:	39 c2                	cmp    %eax,%edx
  801b1e:	73 b4                	jae    801ad4 <devpipe_write+0x24>
  801b20:	eb d0                	jmp    801af2 <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801b22:	8b 45 10             	mov    0x10(%ebp),%eax
  801b25:	eb 05                	jmp    801b2c <devpipe_write+0x7c>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b27:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801b2c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b2f:	5b                   	pop    %ebx
  801b30:	5e                   	pop    %esi
  801b31:	5f                   	pop    %edi
  801b32:	5d                   	pop    %ebp
  801b33:	c3                   	ret    

00801b34 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b34:	55                   	push   %ebp
  801b35:	89 e5                	mov    %esp,%ebp
  801b37:	57                   	push   %edi
  801b38:	56                   	push   %esi
  801b39:	53                   	push   %ebx
  801b3a:	83 ec 18             	sub    $0x18,%esp
  801b3d:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801b40:	57                   	push   %edi
  801b41:	e8 f2 f6 ff ff       	call   801238 <fd2data>
  801b46:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b48:	83 c4 10             	add    $0x10,%esp
  801b4b:	be 00 00 00 00       	mov    $0x0,%esi
  801b50:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801b54:	75 3d                	jne    801b93 <devpipe_read+0x5f>
  801b56:	eb 48                	jmp    801ba0 <devpipe_read+0x6c>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  801b58:	89 f0                	mov    %esi,%eax
  801b5a:	eb 4e                	jmp    801baa <devpipe_read+0x76>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801b5c:	89 da                	mov    %ebx,%edx
  801b5e:	89 f8                	mov    %edi,%eax
  801b60:	e8 df fe ff ff       	call   801a44 <_pipeisclosed>
  801b65:	85 c0                	test   %eax,%eax
  801b67:	75 3c                	jne    801ba5 <devpipe_read+0x71>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801b69:	e8 cf f1 ff ff       	call   800d3d <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801b6e:	8b 03                	mov    (%ebx),%eax
  801b70:	3b 43 04             	cmp    0x4(%ebx),%eax
  801b73:	74 e7                	je     801b5c <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b75:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801b7a:	79 05                	jns    801b81 <devpipe_read+0x4d>
  801b7c:	48                   	dec    %eax
  801b7d:	83 c8 e0             	or     $0xffffffe0,%eax
  801b80:	40                   	inc    %eax
  801b81:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801b85:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b88:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801b8b:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b8d:	46                   	inc    %esi
  801b8e:	39 75 10             	cmp    %esi,0x10(%ebp)
  801b91:	74 0d                	je     801ba0 <devpipe_read+0x6c>
		while (p->p_rpos == p->p_wpos) {
  801b93:	8b 03                	mov    (%ebx),%eax
  801b95:	3b 43 04             	cmp    0x4(%ebx),%eax
  801b98:	75 db                	jne    801b75 <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801b9a:	85 f6                	test   %esi,%esi
  801b9c:	75 ba                	jne    801b58 <devpipe_read+0x24>
  801b9e:	eb bc                	jmp    801b5c <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801ba0:	8b 45 10             	mov    0x10(%ebp),%eax
  801ba3:	eb 05                	jmp    801baa <devpipe_read+0x76>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801ba5:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801baa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bad:	5b                   	pop    %ebx
  801bae:	5e                   	pop    %esi
  801baf:	5f                   	pop    %edi
  801bb0:	5d                   	pop    %ebp
  801bb1:	c3                   	ret    

00801bb2 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801bb2:	55                   	push   %ebp
  801bb3:	89 e5                	mov    %esp,%ebp
  801bb5:	56                   	push   %esi
  801bb6:	53                   	push   %ebx
  801bb7:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801bba:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bbd:	50                   	push   %eax
  801bbe:	e8 8c f6 ff ff       	call   80124f <fd_alloc>
  801bc3:	83 c4 10             	add    $0x10,%esp
  801bc6:	85 c0                	test   %eax,%eax
  801bc8:	0f 88 2a 01 00 00    	js     801cf8 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bce:	83 ec 04             	sub    $0x4,%esp
  801bd1:	68 07 04 00 00       	push   $0x407
  801bd6:	ff 75 f4             	pushl  -0xc(%ebp)
  801bd9:	6a 00                	push   $0x0
  801bdb:	e8 7c f1 ff ff       	call   800d5c <sys_page_alloc>
  801be0:	83 c4 10             	add    $0x10,%esp
  801be3:	85 c0                	test   %eax,%eax
  801be5:	0f 88 0d 01 00 00    	js     801cf8 <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801beb:	83 ec 0c             	sub    $0xc,%esp
  801bee:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801bf1:	50                   	push   %eax
  801bf2:	e8 58 f6 ff ff       	call   80124f <fd_alloc>
  801bf7:	89 c3                	mov    %eax,%ebx
  801bf9:	83 c4 10             	add    $0x10,%esp
  801bfc:	85 c0                	test   %eax,%eax
  801bfe:	0f 88 e2 00 00 00    	js     801ce6 <pipe+0x134>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c04:	83 ec 04             	sub    $0x4,%esp
  801c07:	68 07 04 00 00       	push   $0x407
  801c0c:	ff 75 f0             	pushl  -0x10(%ebp)
  801c0f:	6a 00                	push   $0x0
  801c11:	e8 46 f1 ff ff       	call   800d5c <sys_page_alloc>
  801c16:	89 c3                	mov    %eax,%ebx
  801c18:	83 c4 10             	add    $0x10,%esp
  801c1b:	85 c0                	test   %eax,%eax
  801c1d:	0f 88 c3 00 00 00    	js     801ce6 <pipe+0x134>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801c23:	83 ec 0c             	sub    $0xc,%esp
  801c26:	ff 75 f4             	pushl  -0xc(%ebp)
  801c29:	e8 0a f6 ff ff       	call   801238 <fd2data>
  801c2e:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c30:	83 c4 0c             	add    $0xc,%esp
  801c33:	68 07 04 00 00       	push   $0x407
  801c38:	50                   	push   %eax
  801c39:	6a 00                	push   $0x0
  801c3b:	e8 1c f1 ff ff       	call   800d5c <sys_page_alloc>
  801c40:	89 c3                	mov    %eax,%ebx
  801c42:	83 c4 10             	add    $0x10,%esp
  801c45:	85 c0                	test   %eax,%eax
  801c47:	0f 88 89 00 00 00    	js     801cd6 <pipe+0x124>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c4d:	83 ec 0c             	sub    $0xc,%esp
  801c50:	ff 75 f0             	pushl  -0x10(%ebp)
  801c53:	e8 e0 f5 ff ff       	call   801238 <fd2data>
  801c58:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c5f:	50                   	push   %eax
  801c60:	6a 00                	push   $0x0
  801c62:	56                   	push   %esi
  801c63:	6a 00                	push   $0x0
  801c65:	e8 35 f1 ff ff       	call   800d9f <sys_page_map>
  801c6a:	89 c3                	mov    %eax,%ebx
  801c6c:	83 c4 20             	add    $0x20,%esp
  801c6f:	85 c0                	test   %eax,%eax
  801c71:	78 55                	js     801cc8 <pipe+0x116>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801c73:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c79:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c7c:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801c7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c81:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801c88:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c8e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c91:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801c93:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c96:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801c9d:	83 ec 0c             	sub    $0xc,%esp
  801ca0:	ff 75 f4             	pushl  -0xc(%ebp)
  801ca3:	e8 80 f5 ff ff       	call   801228 <fd2num>
  801ca8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cab:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801cad:	83 c4 04             	add    $0x4,%esp
  801cb0:	ff 75 f0             	pushl  -0x10(%ebp)
  801cb3:	e8 70 f5 ff ff       	call   801228 <fd2num>
  801cb8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cbb:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801cbe:	83 c4 10             	add    $0x10,%esp
  801cc1:	b8 00 00 00 00       	mov    $0x0,%eax
  801cc6:	eb 30                	jmp    801cf8 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  801cc8:	83 ec 08             	sub    $0x8,%esp
  801ccb:	56                   	push   %esi
  801ccc:	6a 00                	push   $0x0
  801cce:	e8 0e f1 ff ff       	call   800de1 <sys_page_unmap>
  801cd3:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801cd6:	83 ec 08             	sub    $0x8,%esp
  801cd9:	ff 75 f0             	pushl  -0x10(%ebp)
  801cdc:	6a 00                	push   $0x0
  801cde:	e8 fe f0 ff ff       	call   800de1 <sys_page_unmap>
  801ce3:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801ce6:	83 ec 08             	sub    $0x8,%esp
  801ce9:	ff 75 f4             	pushl  -0xc(%ebp)
  801cec:	6a 00                	push   $0x0
  801cee:	e8 ee f0 ff ff       	call   800de1 <sys_page_unmap>
  801cf3:	83 c4 10             	add    $0x10,%esp
  801cf6:	89 d8                	mov    %ebx,%eax
    err:
	return r;
}
  801cf8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cfb:	5b                   	pop    %ebx
  801cfc:	5e                   	pop    %esi
  801cfd:	5d                   	pop    %ebp
  801cfe:	c3                   	ret    

00801cff <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801cff:	55                   	push   %ebp
  801d00:	89 e5                	mov    %esp,%ebp
  801d02:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d05:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d08:	50                   	push   %eax
  801d09:	ff 75 08             	pushl  0x8(%ebp)
  801d0c:	e8 b2 f5 ff ff       	call   8012c3 <fd_lookup>
  801d11:	83 c4 10             	add    $0x10,%esp
  801d14:	85 c0                	test   %eax,%eax
  801d16:	78 18                	js     801d30 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801d18:	83 ec 0c             	sub    $0xc,%esp
  801d1b:	ff 75 f4             	pushl  -0xc(%ebp)
  801d1e:	e8 15 f5 ff ff       	call   801238 <fd2data>
	return _pipeisclosed(fd, p);
  801d23:	89 c2                	mov    %eax,%edx
  801d25:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d28:	e8 17 fd ff ff       	call   801a44 <_pipeisclosed>
  801d2d:	83 c4 10             	add    $0x10,%esp
}
  801d30:	c9                   	leave  
  801d31:	c3                   	ret    

00801d32 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801d32:	55                   	push   %ebp
  801d33:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801d35:	b8 00 00 00 00       	mov    $0x0,%eax
  801d3a:	5d                   	pop    %ebp
  801d3b:	c3                   	ret    

00801d3c <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801d3c:	55                   	push   %ebp
  801d3d:	89 e5                	mov    %esp,%ebp
  801d3f:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801d42:	68 23 29 80 00       	push   $0x802923
  801d47:	ff 75 0c             	pushl  0xc(%ebp)
  801d4a:	e8 9d eb ff ff       	call   8008ec <strcpy>
	return 0;
}
  801d4f:	b8 00 00 00 00       	mov    $0x0,%eax
  801d54:	c9                   	leave  
  801d55:	c3                   	ret    

00801d56 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d56:	55                   	push   %ebp
  801d57:	89 e5                	mov    %esp,%ebp
  801d59:	57                   	push   %edi
  801d5a:	56                   	push   %esi
  801d5b:	53                   	push   %ebx
  801d5c:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d62:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d66:	74 45                	je     801dad <devcons_write+0x57>
  801d68:	b8 00 00 00 00       	mov    $0x0,%eax
  801d6d:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d72:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801d78:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801d7b:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  801d7d:	83 fb 7f             	cmp    $0x7f,%ebx
  801d80:	76 05                	jbe    801d87 <devcons_write+0x31>
			m = sizeof(buf) - 1;
  801d82:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801d87:	83 ec 04             	sub    $0x4,%esp
  801d8a:	53                   	push   %ebx
  801d8b:	03 45 0c             	add    0xc(%ebp),%eax
  801d8e:	50                   	push   %eax
  801d8f:	57                   	push   %edi
  801d90:	e8 24 ed ff ff       	call   800ab9 <memmove>
		sys_cputs(buf, m);
  801d95:	83 c4 08             	add    $0x8,%esp
  801d98:	53                   	push   %ebx
  801d99:	57                   	push   %edi
  801d9a:	e8 01 ef ff ff       	call   800ca0 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d9f:	01 de                	add    %ebx,%esi
  801da1:	89 f0                	mov    %esi,%eax
  801da3:	83 c4 10             	add    $0x10,%esp
  801da6:	3b 75 10             	cmp    0x10(%ebp),%esi
  801da9:	72 cd                	jb     801d78 <devcons_write+0x22>
  801dab:	eb 05                	jmp    801db2 <devcons_write+0x5c>
  801dad:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801db2:	89 f0                	mov    %esi,%eax
  801db4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801db7:	5b                   	pop    %ebx
  801db8:	5e                   	pop    %esi
  801db9:	5f                   	pop    %edi
  801dba:	5d                   	pop    %ebp
  801dbb:	c3                   	ret    

00801dbc <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801dbc:	55                   	push   %ebp
  801dbd:	89 e5                	mov    %esp,%ebp
  801dbf:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801dc2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801dc6:	75 07                	jne    801dcf <devcons_read+0x13>
  801dc8:	eb 23                	jmp    801ded <devcons_read+0x31>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801dca:	e8 6e ef ff ff       	call   800d3d <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801dcf:	e8 ea ee ff ff       	call   800cbe <sys_cgetc>
  801dd4:	85 c0                	test   %eax,%eax
  801dd6:	74 f2                	je     801dca <devcons_read+0xe>
		sys_yield();
	if (c < 0)
  801dd8:	85 c0                	test   %eax,%eax
  801dda:	78 1d                	js     801df9 <devcons_read+0x3d>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801ddc:	83 f8 04             	cmp    $0x4,%eax
  801ddf:	74 13                	je     801df4 <devcons_read+0x38>
		return 0;
	*(char*)vbuf = c;
  801de1:	8b 55 0c             	mov    0xc(%ebp),%edx
  801de4:	88 02                	mov    %al,(%edx)
	return 1;
  801de6:	b8 01 00 00 00       	mov    $0x1,%eax
  801deb:	eb 0c                	jmp    801df9 <devcons_read+0x3d>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801ded:	b8 00 00 00 00       	mov    $0x0,%eax
  801df2:	eb 05                	jmp    801df9 <devcons_read+0x3d>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801df4:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801df9:	c9                   	leave  
  801dfa:	c3                   	ret    

00801dfb <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801dfb:	55                   	push   %ebp
  801dfc:	89 e5                	mov    %esp,%ebp
  801dfe:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801e01:	8b 45 08             	mov    0x8(%ebp),%eax
  801e04:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801e07:	6a 01                	push   $0x1
  801e09:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e0c:	50                   	push   %eax
  801e0d:	e8 8e ee ff ff       	call   800ca0 <sys_cputs>
}
  801e12:	83 c4 10             	add    $0x10,%esp
  801e15:	c9                   	leave  
  801e16:	c3                   	ret    

00801e17 <getchar>:

int
getchar(void)
{
  801e17:	55                   	push   %ebp
  801e18:	89 e5                	mov    %esp,%ebp
  801e1a:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801e1d:	6a 01                	push   $0x1
  801e1f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e22:	50                   	push   %eax
  801e23:	6a 00                	push   $0x0
  801e25:	e8 1a f7 ff ff       	call   801544 <read>
	if (r < 0)
  801e2a:	83 c4 10             	add    $0x10,%esp
  801e2d:	85 c0                	test   %eax,%eax
  801e2f:	78 0f                	js     801e40 <getchar+0x29>
		return r;
	if (r < 1)
  801e31:	85 c0                	test   %eax,%eax
  801e33:	7e 06                	jle    801e3b <getchar+0x24>
		return -E_EOF;
	return c;
  801e35:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801e39:	eb 05                	jmp    801e40 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801e3b:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801e40:	c9                   	leave  
  801e41:	c3                   	ret    

00801e42 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801e42:	55                   	push   %ebp
  801e43:	89 e5                	mov    %esp,%ebp
  801e45:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e48:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e4b:	50                   	push   %eax
  801e4c:	ff 75 08             	pushl  0x8(%ebp)
  801e4f:	e8 6f f4 ff ff       	call   8012c3 <fd_lookup>
  801e54:	83 c4 10             	add    $0x10,%esp
  801e57:	85 c0                	test   %eax,%eax
  801e59:	78 11                	js     801e6c <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801e5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e5e:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e64:	39 10                	cmp    %edx,(%eax)
  801e66:	0f 94 c0             	sete   %al
  801e69:	0f b6 c0             	movzbl %al,%eax
}
  801e6c:	c9                   	leave  
  801e6d:	c3                   	ret    

00801e6e <opencons>:

int
opencons(void)
{
  801e6e:	55                   	push   %ebp
  801e6f:	89 e5                	mov    %esp,%ebp
  801e71:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e74:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e77:	50                   	push   %eax
  801e78:	e8 d2 f3 ff ff       	call   80124f <fd_alloc>
  801e7d:	83 c4 10             	add    $0x10,%esp
  801e80:	85 c0                	test   %eax,%eax
  801e82:	78 3a                	js     801ebe <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e84:	83 ec 04             	sub    $0x4,%esp
  801e87:	68 07 04 00 00       	push   $0x407
  801e8c:	ff 75 f4             	pushl  -0xc(%ebp)
  801e8f:	6a 00                	push   $0x0
  801e91:	e8 c6 ee ff ff       	call   800d5c <sys_page_alloc>
  801e96:	83 c4 10             	add    $0x10,%esp
  801e99:	85 c0                	test   %eax,%eax
  801e9b:	78 21                	js     801ebe <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801e9d:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ea3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ea6:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801ea8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801eab:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801eb2:	83 ec 0c             	sub    $0xc,%esp
  801eb5:	50                   	push   %eax
  801eb6:	e8 6d f3 ff ff       	call   801228 <fd2num>
  801ebb:	83 c4 10             	add    $0x10,%esp
}
  801ebe:	c9                   	leave  
  801ebf:	c3                   	ret    

00801ec0 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801ec0:	55                   	push   %ebp
  801ec1:	89 e5                	mov    %esp,%ebp
  801ec3:	53                   	push   %ebx
  801ec4:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (_pgfault_handler == 0) {
  801ec7:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801ece:	75 5b                	jne    801f2b <set_pgfault_handler+0x6b>
		// First time through!
		// LAB 4: Your code here.
		void *va = (void *)(UXSTACKTOP - PGSIZE);
		envid_t eid = sys_getenvid();
  801ed0:	e8 49 ee ff ff       	call   800d1e <sys_getenvid>
  801ed5:	89 c3                	mov    %eax,%ebx
		r = sys_page_alloc(eid,va,PTE_P | PTE_U | PTE_W);
  801ed7:	83 ec 04             	sub    $0x4,%esp
  801eda:	6a 07                	push   $0x7
  801edc:	68 00 f0 bf ee       	push   $0xeebff000
  801ee1:	50                   	push   %eax
  801ee2:	e8 75 ee ff ff       	call   800d5c <sys_page_alloc>
		if(r<0) panic("set_pgfault_handler\n");
  801ee7:	83 c4 10             	add    $0x10,%esp
  801eea:	85 c0                	test   %eax,%eax
  801eec:	79 14                	jns    801f02 <set_pgfault_handler+0x42>
  801eee:	83 ec 04             	sub    $0x4,%esp
  801ef1:	68 2f 29 80 00       	push   $0x80292f
  801ef6:	6a 23                	push   $0x23
  801ef8:	68 44 29 80 00       	push   $0x802944
  801efd:	e8 2d e3 ff ff       	call   80022f <_panic>
		r = sys_env_set_pgfault_upcall(eid,_pgfault_upcall);
  801f02:	83 ec 08             	sub    $0x8,%esp
  801f05:	68 38 1f 80 00       	push   $0x801f38
  801f0a:	53                   	push   %ebx
  801f0b:	e8 97 ef ff ff       	call   800ea7 <sys_env_set_pgfault_upcall>
		if(r<0) panic("set_pgfault_handler\n");
  801f10:	83 c4 10             	add    $0x10,%esp
  801f13:	85 c0                	test   %eax,%eax
  801f15:	79 14                	jns    801f2b <set_pgfault_handler+0x6b>
  801f17:	83 ec 04             	sub    $0x4,%esp
  801f1a:	68 2f 29 80 00       	push   $0x80292f
  801f1f:	6a 25                	push   $0x25
  801f21:	68 44 29 80 00       	push   $0x802944
  801f26:	e8 04 e3 ff ff       	call   80022f <_panic>
		// panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801f2b:	8b 45 08             	mov    0x8(%ebp),%eax
  801f2e:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801f33:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f36:	c9                   	leave  
  801f37:	c3                   	ret    

00801f38 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801f38:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801f39:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801f3e:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801f40:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl %esp,%ebx
  801f43:	89 e3                	mov    %esp,%ebx
	movl 40(%esp),%eax 	// esp from utf_fault_va to utf_regs(end)
  801f45:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl 48(%esp),%esp 	// 
  801f49:	8b 64 24 30          	mov    0x30(%esp),%esp
	pushl %eax
  801f4d:	50                   	push   %eax
 
 
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	movl %ebx,%esp
  801f4e:	89 dc                	mov    %ebx,%esp
	subl $4,48(%esp)
  801f50:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	popl %eax
  801f55:	58                   	pop    %eax
	popl %eax
  801f56:	58                   	pop    %eax
	popal
  801f57:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	add $4,%esp
  801f58:	83 c4 04             	add    $0x4,%esp
	popfl
  801f5b:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  801f5c:	5c                   	pop    %esp
 
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801f5d:	c3                   	ret    

00801f5e <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f5e:	55                   	push   %ebp
  801f5f:	89 e5                	mov    %esp,%ebp
  801f61:	56                   	push   %esi
  801f62:	53                   	push   %ebx
  801f63:	8b 75 08             	mov    0x8(%ebp),%esi
  801f66:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f69:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");
	int r;
    if (pg != NULL) {
  801f6c:	85 c0                	test   %eax,%eax
  801f6e:	74 0e                	je     801f7e <ipc_recv+0x20>
        r = sys_ipc_recv(pg);
  801f70:	83 ec 0c             	sub    $0xc,%esp
  801f73:	50                   	push   %eax
  801f74:	e8 93 ef ff ff       	call   800f0c <sys_ipc_recv>
  801f79:	83 c4 10             	add    $0x10,%esp
  801f7c:	eb 10                	jmp    801f8e <ipc_recv+0x30>
    } else {
        r = sys_ipc_recv((void *) UTOP);
  801f7e:	83 ec 0c             	sub    $0xc,%esp
  801f81:	68 00 00 c0 ee       	push   $0xeec00000
  801f86:	e8 81 ef ff ff       	call   800f0c <sys_ipc_recv>
  801f8b:	83 c4 10             	add    $0x10,%esp
    }
    if (r < 0) {
  801f8e:	85 c0                	test   %eax,%eax
  801f90:	79 16                	jns    801fa8 <ipc_recv+0x4a>
        // failed
        if (from_env_store != NULL) *from_env_store = 0;
  801f92:	85 f6                	test   %esi,%esi
  801f94:	74 06                	je     801f9c <ipc_recv+0x3e>
  801f96:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        if (perm_store != NULL) *perm_store = 0;
  801f9c:	85 db                	test   %ebx,%ebx
  801f9e:	74 2c                	je     801fcc <ipc_recv+0x6e>
  801fa0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801fa6:	eb 24                	jmp    801fcc <ipc_recv+0x6e>
        return r;
    } else {
        if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801fa8:	85 f6                	test   %esi,%esi
  801faa:	74 0a                	je     801fb6 <ipc_recv+0x58>
  801fac:	a1 04 40 80 00       	mov    0x804004,%eax
  801fb1:	8b 40 74             	mov    0x74(%eax),%eax
  801fb4:	89 06                	mov    %eax,(%esi)
        if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801fb6:	85 db                	test   %ebx,%ebx
  801fb8:	74 0a                	je     801fc4 <ipc_recv+0x66>
  801fba:	a1 04 40 80 00       	mov    0x804004,%eax
  801fbf:	8b 40 78             	mov    0x78(%eax),%eax
  801fc2:	89 03                	mov    %eax,(%ebx)
        return thisenv->env_ipc_value;
  801fc4:	a1 04 40 80 00       	mov    0x804004,%eax
  801fc9:	8b 40 70             	mov    0x70(%eax),%eax
    }
 
	return 0;
}
  801fcc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801fcf:	5b                   	pop    %ebx
  801fd0:	5e                   	pop    %esi
  801fd1:	5d                   	pop    %ebp
  801fd2:	c3                   	ret    

00801fd3 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801fd3:	55                   	push   %ebp
  801fd4:	89 e5                	mov    %esp,%ebp
  801fd6:	57                   	push   %edi
  801fd7:	56                   	push   %esi
  801fd8:	53                   	push   %ebx
  801fd9:	83 ec 0c             	sub    $0xc,%esp
  801fdc:	8b 75 10             	mov    0x10(%ebp),%esi
  801fdf:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");
	int r;
    if (pg == NULL) pg = (void *)UTOP;
  801fe2:	85 f6                	test   %esi,%esi
  801fe4:	75 05                	jne    801feb <ipc_send+0x18>
  801fe6:	be 00 00 c0 ee       	mov    $0xeec00000,%esi
    do {
        r = sys_ipc_try_send(to_env, val, pg, perm);
  801feb:	57                   	push   %edi
  801fec:	56                   	push   %esi
  801fed:	ff 75 0c             	pushl  0xc(%ebp)
  801ff0:	ff 75 08             	pushl  0x8(%ebp)
  801ff3:	e8 f1 ee ff ff       	call   800ee9 <sys_ipc_try_send>
  801ff8:	89 c3                	mov    %eax,%ebx
        if (r < 0 && r != -E_IPC_NOT_RECV) panic("ipc send failed: %e", r);
  801ffa:	83 c4 10             	add    $0x10,%esp
  801ffd:	85 c0                	test   %eax,%eax
  801fff:	79 17                	jns    802018 <ipc_send+0x45>
  802001:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802004:	74 1d                	je     802023 <ipc_send+0x50>
  802006:	50                   	push   %eax
  802007:	68 52 29 80 00       	push   $0x802952
  80200c:	6a 40                	push   $0x40
  80200e:	68 66 29 80 00       	push   $0x802966
  802013:	e8 17 e2 ff ff       	call   80022f <_panic>
        sys_yield();
  802018:	e8 20 ed ff ff       	call   800d3d <sys_yield>
    } while (r != 0);
  80201d:	85 db                	test   %ebx,%ebx
  80201f:	75 ca                	jne    801feb <ipc_send+0x18>
  802021:	eb 07                	jmp    80202a <ipc_send+0x57>
	int r;
    if (pg == NULL) pg = (void *)UTOP;
    do {
        r = sys_ipc_try_send(to_env, val, pg, perm);
        if (r < 0 && r != -E_IPC_NOT_RECV) panic("ipc send failed: %e", r);
        sys_yield();
  802023:	e8 15 ed ff ff       	call   800d3d <sys_yield>
  802028:	eb c1                	jmp    801feb <ipc_send+0x18>
    } while (r != 0);
}
  80202a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80202d:	5b                   	pop    %ebx
  80202e:	5e                   	pop    %esi
  80202f:	5f                   	pop    %edi
  802030:	5d                   	pop    %ebp
  802031:	c3                   	ret    

00802032 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802032:	55                   	push   %ebp
  802033:	89 e5                	mov    %esp,%ebp
  802035:	53                   	push   %ebx
  802036:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  802039:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  80203e:	39 c1                	cmp    %eax,%ecx
  802040:	74 21                	je     802063 <ipc_find_env+0x31>
  802042:	ba 01 00 00 00       	mov    $0x1,%edx
  802047:	8d 1c 95 00 00 00 00 	lea    0x0(,%edx,4),%ebx
  80204e:	89 d0                	mov    %edx,%eax
  802050:	c1 e0 07             	shl    $0x7,%eax
  802053:	29 d8                	sub    %ebx,%eax
  802055:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80205a:	8b 40 50             	mov    0x50(%eax),%eax
  80205d:	39 c8                	cmp    %ecx,%eax
  80205f:	75 1b                	jne    80207c <ipc_find_env+0x4a>
  802061:	eb 05                	jmp    802068 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802063:	ba 00 00 00 00       	mov    $0x0,%edx
		if (envs[i].env_type == type)
			return envs[i].env_id;
  802068:	8d 04 95 00 00 00 00 	lea    0x0(,%edx,4),%eax
  80206f:	c1 e2 07             	shl    $0x7,%edx
  802072:	29 c2                	sub    %eax,%edx
  802074:	8b 82 48 00 c0 ee    	mov    -0x113fffb8(%edx),%eax
  80207a:	eb 0e                	jmp    80208a <ipc_find_env+0x58>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80207c:	42                   	inc    %edx
  80207d:	81 fa 00 04 00 00    	cmp    $0x400,%edx
  802083:	75 c2                	jne    802047 <ipc_find_env+0x15>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802085:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80208a:	5b                   	pop    %ebx
  80208b:	5d                   	pop    %ebp
  80208c:	c3                   	ret    

0080208d <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80208d:	55                   	push   %ebp
  80208e:	89 e5                	mov    %esp,%ebp
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802090:	8b 45 08             	mov    0x8(%ebp),%eax
  802093:	c1 e8 16             	shr    $0x16,%eax
  802096:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80209d:	a8 01                	test   $0x1,%al
  80209f:	74 21                	je     8020c2 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  8020a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8020a4:	c1 e8 0c             	shr    $0xc,%eax
  8020a7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8020ae:	a8 01                	test   $0x1,%al
  8020b0:	74 17                	je     8020c9 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8020b2:	c1 e8 0c             	shr    $0xc,%eax
  8020b5:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  8020bc:	ef 
  8020bd:	0f b7 c0             	movzwl %ax,%eax
  8020c0:	eb 0c                	jmp    8020ce <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  8020c2:	b8 00 00 00 00       	mov    $0x0,%eax
  8020c7:	eb 05                	jmp    8020ce <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  8020c9:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  8020ce:	5d                   	pop    %ebp
  8020cf:	c3                   	ret    

008020d0 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  8020d0:	55                   	push   %ebp
  8020d1:	57                   	push   %edi
  8020d2:	56                   	push   %esi
  8020d3:	53                   	push   %ebx
  8020d4:	83 ec 1c             	sub    $0x1c,%esp
  8020d7:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8020db:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8020df:	8b 7c 24 38          	mov    0x38(%esp),%edi
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8020e3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8020e7:	89 ca                	mov    %ecx,%edx
  const DWunion dd = {.ll = d};
  8020e9:	89 f8                	mov    %edi,%eax
  8020eb:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8020ef:	85 f6                	test   %esi,%esi
  8020f1:	75 2d                	jne    802120 <__udivdi3+0x50>
    {
      if (d0 > n1)
  8020f3:	39 cf                	cmp    %ecx,%edi
  8020f5:	77 65                	ja     80215c <__udivdi3+0x8c>
  8020f7:	89 fd                	mov    %edi,%ebp
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8020f9:	85 ff                	test   %edi,%edi
  8020fb:	75 0b                	jne    802108 <__udivdi3+0x38>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8020fd:	b8 01 00 00 00       	mov    $0x1,%eax
  802102:	31 d2                	xor    %edx,%edx
  802104:	f7 f7                	div    %edi
  802106:	89 c5                	mov    %eax,%ebp

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802108:	31 d2                	xor    %edx,%edx
  80210a:	89 c8                	mov    %ecx,%eax
  80210c:	f7 f5                	div    %ebp
  80210e:	89 c1                	mov    %eax,%ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802110:	89 d8                	mov    %ebx,%eax
  802112:	f7 f5                	div    %ebp
  802114:	89 cf                	mov    %ecx,%edi
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802116:	89 fa                	mov    %edi,%edx
  802118:	83 c4 1c             	add    $0x1c,%esp
  80211b:	5b                   	pop    %ebx
  80211c:	5e                   	pop    %esi
  80211d:	5f                   	pop    %edi
  80211e:	5d                   	pop    %ebp
  80211f:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802120:	39 ce                	cmp    %ecx,%esi
  802122:	77 28                	ja     80214c <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802124:	0f bd fe             	bsr    %esi,%edi
	  if (bm == 0)
  802127:	83 f7 1f             	xor    $0x1f,%edi
  80212a:	75 40                	jne    80216c <__udivdi3+0x9c>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  80212c:	39 ce                	cmp    %ecx,%esi
  80212e:	72 0a                	jb     80213a <__udivdi3+0x6a>
  802130:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802134:	0f 87 9e 00 00 00    	ja     8021d8 <__udivdi3+0x108>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  80213a:	b8 01 00 00 00       	mov    $0x1,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80213f:	89 fa                	mov    %edi,%edx
  802141:	83 c4 1c             	add    $0x1c,%esp
  802144:	5b                   	pop    %ebx
  802145:	5e                   	pop    %esi
  802146:	5f                   	pop    %edi
  802147:	5d                   	pop    %ebp
  802148:	c3                   	ret    
  802149:	8d 76 00             	lea    0x0(%esi),%esi
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  80214c:	31 ff                	xor    %edi,%edi
  80214e:	31 c0                	xor    %eax,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802150:	89 fa                	mov    %edi,%edx
  802152:	83 c4 1c             	add    $0x1c,%esp
  802155:	5b                   	pop    %ebx
  802156:	5e                   	pop    %esi
  802157:	5f                   	pop    %edi
  802158:	5d                   	pop    %ebp
  802159:	c3                   	ret    
  80215a:	66 90                	xchg   %ax,%ax
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80215c:	89 d8                	mov    %ebx,%eax
  80215e:	f7 f7                	div    %edi
  802160:	31 ff                	xor    %edi,%edi
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802162:	89 fa                	mov    %edi,%edx
  802164:	83 c4 1c             	add    $0x1c,%esp
  802167:	5b                   	pop    %ebx
  802168:	5e                   	pop    %esi
  802169:	5f                   	pop    %edi
  80216a:	5d                   	pop    %ebp
  80216b:	c3                   	ret    
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  80216c:	bd 20 00 00 00       	mov    $0x20,%ebp
  802171:	89 eb                	mov    %ebp,%ebx
  802173:	29 fb                	sub    %edi,%ebx

	      d1 = (d1 << bm) | (d0 >> b);
  802175:	89 f9                	mov    %edi,%ecx
  802177:	d3 e6                	shl    %cl,%esi
  802179:	89 c5                	mov    %eax,%ebp
  80217b:	88 d9                	mov    %bl,%cl
  80217d:	d3 ed                	shr    %cl,%ebp
  80217f:	89 e9                	mov    %ebp,%ecx
  802181:	09 f1                	or     %esi,%ecx
  802183:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
	      d0 = d0 << bm;
  802187:	89 f9                	mov    %edi,%ecx
  802189:	d3 e0                	shl    %cl,%eax
  80218b:	89 c5                	mov    %eax,%ebp
	      n2 = n1 >> b;
  80218d:	89 d6                	mov    %edx,%esi
  80218f:	88 d9                	mov    %bl,%cl
  802191:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
  802193:	89 f9                	mov    %edi,%ecx
  802195:	d3 e2                	shl    %cl,%edx
  802197:	8b 44 24 08          	mov    0x8(%esp),%eax
  80219b:	88 d9                	mov    %bl,%cl
  80219d:	d3 e8                	shr    %cl,%eax
  80219f:	09 c2                	or     %eax,%edx
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8021a1:	89 d0                	mov    %edx,%eax
  8021a3:	89 f2                	mov    %esi,%edx
  8021a5:	f7 74 24 0c          	divl   0xc(%esp)
  8021a9:	89 d6                	mov    %edx,%esi
  8021ab:	89 c3                	mov    %eax,%ebx
	      umul_ppmm (m1, m0, q0, d0);
  8021ad:	f7 e5                	mul    %ebp

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8021af:	39 d6                	cmp    %edx,%esi
  8021b1:	72 19                	jb     8021cc <__udivdi3+0xfc>
  8021b3:	74 0b                	je     8021c0 <__udivdi3+0xf0>
  8021b5:	89 d8                	mov    %ebx,%eax
  8021b7:	31 ff                	xor    %edi,%edi
  8021b9:	e9 58 ff ff ff       	jmp    802116 <__udivdi3+0x46>
  8021be:	66 90                	xchg   %ax,%ax
  8021c0:	8b 54 24 08          	mov    0x8(%esp),%edx
  8021c4:	89 f9                	mov    %edi,%ecx
  8021c6:	d3 e2                	shl    %cl,%edx
  8021c8:	39 c2                	cmp    %eax,%edx
  8021ca:	73 e9                	jae    8021b5 <__udivdi3+0xe5>
  8021cc:	8d 43 ff             	lea    -0x1(%ebx),%eax
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8021cf:	31 ff                	xor    %edi,%edi
  8021d1:	e9 40 ff ff ff       	jmp    802116 <__udivdi3+0x46>
  8021d6:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8021d8:	31 c0                	xor    %eax,%eax
  8021da:	e9 37 ff ff ff       	jmp    802116 <__udivdi3+0x46>
  8021df:	90                   	nop

008021e0 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  8021e0:	55                   	push   %ebp
  8021e1:	57                   	push   %edi
  8021e2:	56                   	push   %esi
  8021e3:	53                   	push   %ebx
  8021e4:	83 ec 1c             	sub    $0x1c,%esp
  8021e7:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8021eb:	8b 74 24 34          	mov    0x34(%esp),%esi
  8021ef:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8021f3:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8021f7:	89 44 24 0c          	mov    %eax,0xc(%esp)
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8021fb:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021ff:	89 f3                	mov    %esi,%ebx
  const DWunion dd = {.ll = d};
  802201:	89 fa                	mov    %edi,%edx
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  802203:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  n1 = nn.s.high;
  802207:	89 34 24             	mov    %esi,(%esp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  80220a:	85 c0                	test   %eax,%eax
  80220c:	75 1a                	jne    802228 <__umoddi3+0x48>
    {
      if (d0 > n1)
  80220e:	39 f7                	cmp    %esi,%edi
  802210:	0f 86 a2 00 00 00    	jbe    8022b8 <__umoddi3+0xd8>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802216:	89 c8                	mov    %ecx,%eax
  802218:	89 f2                	mov    %esi,%edx
  80221a:	f7 f7                	div    %edi
  80221c:	89 d0                	mov    %edx,%eax

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  80221e:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802220:	83 c4 1c             	add    $0x1c,%esp
  802223:	5b                   	pop    %ebx
  802224:	5e                   	pop    %esi
  802225:	5f                   	pop    %edi
  802226:	5d                   	pop    %ebp
  802227:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802228:	39 f0                	cmp    %esi,%eax
  80222a:	0f 87 ac 00 00 00    	ja     8022dc <__umoddi3+0xfc>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802230:	0f bd e8             	bsr    %eax,%ebp
	  if (bm == 0)
  802233:	83 f5 1f             	xor    $0x1f,%ebp
  802236:	0f 84 ac 00 00 00    	je     8022e8 <__umoddi3+0x108>
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  80223c:	bf 20 00 00 00       	mov    $0x20,%edi
  802241:	29 ef                	sub    %ebp,%edi
  802243:	89 fe                	mov    %edi,%esi
  802245:	89 7c 24 0c          	mov    %edi,0xc(%esp)

	      d1 = (d1 << bm) | (d0 >> b);
  802249:	89 e9                	mov    %ebp,%ecx
  80224b:	d3 e0                	shl    %cl,%eax
  80224d:	89 d7                	mov    %edx,%edi
  80224f:	89 f1                	mov    %esi,%ecx
  802251:	d3 ef                	shr    %cl,%edi
  802253:	09 c7                	or     %eax,%edi
	      d0 = d0 << bm;
  802255:	89 e9                	mov    %ebp,%ecx
  802257:	d3 e2                	shl    %cl,%edx
  802259:	89 14 24             	mov    %edx,(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  80225c:	89 d8                	mov    %ebx,%eax
  80225e:	d3 e0                	shl    %cl,%eax
  802260:	89 c2                	mov    %eax,%edx
	      n0 = n0 << bm;
  802262:	8b 44 24 08          	mov    0x8(%esp),%eax
  802266:	d3 e0                	shl    %cl,%eax
  802268:	89 44 24 04          	mov    %eax,0x4(%esp)

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  80226c:	8b 44 24 08          	mov    0x8(%esp),%eax
  802270:	89 f1                	mov    %esi,%ecx
  802272:	d3 e8                	shr    %cl,%eax
  802274:	09 d0                	or     %edx,%eax
  802276:	d3 eb                	shr    %cl,%ebx
  802278:	89 da                	mov    %ebx,%edx
  80227a:	f7 f7                	div    %edi
  80227c:	89 d3                	mov    %edx,%ebx
	      umul_ppmm (m1, m0, q0, d0);
  80227e:	f7 24 24             	mull   (%esp)
  802281:	89 c6                	mov    %eax,%esi
  802283:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802285:	39 d3                	cmp    %edx,%ebx
  802287:	0f 82 87 00 00 00    	jb     802314 <__umoddi3+0x134>
  80228d:	0f 84 91 00 00 00    	je     802324 <__umoddi3+0x144>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  802293:	8b 54 24 04          	mov    0x4(%esp),%edx
  802297:	29 f2                	sub    %esi,%edx
  802299:	19 cb                	sbb    %ecx,%ebx
		  rr.s.low = (n1 << b) | (n0 >> bm);
  80229b:	89 d8                	mov    %ebx,%eax
  80229d:	8a 4c 24 0c          	mov    0xc(%esp),%cl
  8022a1:	d3 e0                	shl    %cl,%eax
  8022a3:	89 e9                	mov    %ebp,%ecx
  8022a5:	d3 ea                	shr    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  8022a7:	09 d0                	or     %edx,%eax
  8022a9:	89 e9                	mov    %ebp,%ecx
  8022ab:	d3 eb                	shr    %cl,%ebx
  8022ad:	89 da                	mov    %ebx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8022af:	83 c4 1c             	add    $0x1c,%esp
  8022b2:	5b                   	pop    %ebx
  8022b3:	5e                   	pop    %esi
  8022b4:	5f                   	pop    %edi
  8022b5:	5d                   	pop    %ebp
  8022b6:	c3                   	ret    
  8022b7:	90                   	nop
  8022b8:	89 fd                	mov    %edi,%ebp
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8022ba:	85 ff                	test   %edi,%edi
  8022bc:	75 0b                	jne    8022c9 <__umoddi3+0xe9>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8022be:	b8 01 00 00 00       	mov    $0x1,%eax
  8022c3:	31 d2                	xor    %edx,%edx
  8022c5:	f7 f7                	div    %edi
  8022c7:	89 c5                	mov    %eax,%ebp

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8022c9:	89 f0                	mov    %esi,%eax
  8022cb:	31 d2                	xor    %edx,%edx
  8022cd:	f7 f5                	div    %ebp
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8022cf:	89 c8                	mov    %ecx,%eax
  8022d1:	f7 f5                	div    %ebp
  8022d3:	89 d0                	mov    %edx,%eax
  8022d5:	e9 44 ff ff ff       	jmp    80221e <__umoddi3+0x3e>
  8022da:	66 90                	xchg   %ax,%ax
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  8022dc:	89 c8                	mov    %ecx,%eax
  8022de:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8022e0:	83 c4 1c             	add    $0x1c,%esp
  8022e3:	5b                   	pop    %ebx
  8022e4:	5e                   	pop    %esi
  8022e5:	5f                   	pop    %edi
  8022e6:	5d                   	pop    %ebp
  8022e7:	c3                   	ret    

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8022e8:	3b 04 24             	cmp    (%esp),%eax
  8022eb:	72 06                	jb     8022f3 <__umoddi3+0x113>
  8022ed:	3b 7c 24 04          	cmp    0x4(%esp),%edi
  8022f1:	77 0f                	ja     802302 <__umoddi3+0x122>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8022f3:	89 f2                	mov    %esi,%edx
  8022f5:	29 f9                	sub    %edi,%ecx
  8022f7:	1b 54 24 0c          	sbb    0xc(%esp),%edx
  8022fb:	89 14 24             	mov    %edx,(%esp)
  8022fe:	89 4c 24 04          	mov    %ecx,0x4(%esp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  802302:	8b 44 24 04          	mov    0x4(%esp),%eax
  802306:	8b 14 24             	mov    (%esp),%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802309:	83 c4 1c             	add    $0x1c,%esp
  80230c:	5b                   	pop    %ebx
  80230d:	5e                   	pop    %esi
  80230e:	5f                   	pop    %edi
  80230f:	5d                   	pop    %ebp
  802310:	c3                   	ret    
  802311:	8d 76 00             	lea    0x0(%esi),%esi
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802314:	2b 04 24             	sub    (%esp),%eax
  802317:	19 fa                	sbb    %edi,%edx
  802319:	89 d1                	mov    %edx,%ecx
  80231b:	89 c6                	mov    %eax,%esi
  80231d:	e9 71 ff ff ff       	jmp    802293 <__umoddi3+0xb3>
  802322:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802324:	39 44 24 04          	cmp    %eax,0x4(%esp)
  802328:	72 ea                	jb     802314 <__umoddi3+0x134>
  80232a:	89 d9                	mov    %ebx,%ecx
  80232c:	e9 62 ff ff ff       	jmp    802293 <__umoddi3+0xb3>
