
obj/user/forktree.debug:     file format elf32-i386


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
  80002c:	e8 b0 00 00 00       	call   8000e1 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <forktree>:
	}
}

void
forktree(const char *cur)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 04             	sub    $0x4,%esp
  80003a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("%04x: I am '%s'\n", sys_getenvid(), cur);
  80003d:	e8 b1 0b 00 00       	call   800bf3 <sys_getenvid>
  800042:	83 ec 04             	sub    $0x4,%esp
  800045:	53                   	push   %ebx
  800046:	50                   	push   %eax
  800047:	68 60 22 80 00       	push   $0x802260
  80004c:	e8 8b 01 00 00       	call   8001dc <cprintf>

	forkchild(cur, '0');
  800051:	83 c4 08             	add    $0x8,%esp
  800054:	6a 30                	push   $0x30
  800056:	53                   	push   %ebx
  800057:	e8 13 00 00 00       	call   80006f <forkchild>
	forkchild(cur, '1');
  80005c:	83 c4 08             	add    $0x8,%esp
  80005f:	6a 31                	push   $0x31
  800061:	53                   	push   %ebx
  800062:	e8 08 00 00 00       	call   80006f <forkchild>
}
  800067:	83 c4 10             	add    $0x10,%esp
  80006a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80006d:	c9                   	leave  
  80006e:	c3                   	ret    

0080006f <forkchild>:

void forktree(const char *cur);

void
forkchild(const char *cur, char branch)
{
  80006f:	55                   	push   %ebp
  800070:	89 e5                	mov    %esp,%ebp
  800072:	56                   	push   %esi
  800073:	53                   	push   %ebx
  800074:	83 ec 1c             	sub    $0x1c,%esp
  800077:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80007a:	8b 75 0c             	mov    0xc(%ebp),%esi
	char nxt[DEPTH+1];

	if (strlen(cur) >= DEPTH)
  80007d:	53                   	push   %ebx
  80007e:	e8 e7 06 00 00       	call   80076a <strlen>
  800083:	83 c4 10             	add    $0x10,%esp
  800086:	83 f8 02             	cmp    $0x2,%eax
  800089:	7f 3a                	jg     8000c5 <forkchild+0x56>
		return;

	snprintf(nxt, DEPTH+1, "%s%c", cur, branch);
  80008b:	83 ec 0c             	sub    $0xc,%esp
  80008e:	89 f0                	mov    %esi,%eax
  800090:	0f be f0             	movsbl %al,%esi
  800093:	56                   	push   %esi
  800094:	53                   	push   %ebx
  800095:	68 71 22 80 00       	push   $0x802271
  80009a:	6a 04                	push   $0x4
  80009c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80009f:	50                   	push   %eax
  8000a0:	e8 ab 06 00 00       	call   800750 <snprintf>
	if (fork() == 0) {
  8000a5:	83 c4 20             	add    $0x20,%esp
  8000a8:	e8 64 0e 00 00       	call   800f11 <fork>
  8000ad:	85 c0                	test   %eax,%eax
  8000af:	75 14                	jne    8000c5 <forkchild+0x56>
		forktree(nxt);
  8000b1:	83 ec 0c             	sub    $0xc,%esp
  8000b4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000b7:	50                   	push   %eax
  8000b8:	e8 76 ff ff ff       	call   800033 <forktree>
		exit();
  8000bd:	e8 6e 00 00 00       	call   800130 <exit>
  8000c2:	83 c4 10             	add    $0x10,%esp
	}
}
  8000c5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000c8:	5b                   	pop    %ebx
  8000c9:	5e                   	pop    %esi
  8000ca:	5d                   	pop    %ebp
  8000cb:	c3                   	ret    

008000cc <umain>:
	forkchild(cur, '1');
}

void
umain(int argc, char **argv)
{
  8000cc:	55                   	push   %ebp
  8000cd:	89 e5                	mov    %esp,%ebp
  8000cf:	83 ec 14             	sub    $0x14,%esp
	forktree("");
  8000d2:	68 ec 25 80 00       	push   $0x8025ec
  8000d7:	e8 57 ff ff ff       	call   800033 <forktree>
}
  8000dc:	83 c4 10             	add    $0x10,%esp
  8000df:	c9                   	leave  
  8000e0:	c3                   	ret    

008000e1 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000e1:	55                   	push   %ebp
  8000e2:	89 e5                	mov    %esp,%ebp
  8000e4:	56                   	push   %esi
  8000e5:	53                   	push   %ebx
  8000e6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000e9:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8000ec:	e8 02 0b 00 00       	call   800bf3 <sys_getenvid>
  8000f1:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000f6:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8000fd:	c1 e0 07             	shl    $0x7,%eax
  800100:	29 d0                	sub    %edx,%eax
  800102:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800107:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80010c:	85 db                	test   %ebx,%ebx
  80010e:	7e 07                	jle    800117 <libmain+0x36>
		binaryname = argv[0];
  800110:	8b 06                	mov    (%esi),%eax
  800112:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800117:	83 ec 08             	sub    $0x8,%esp
  80011a:	56                   	push   %esi
  80011b:	53                   	push   %ebx
  80011c:	e8 ab ff ff ff       	call   8000cc <umain>

	// exit gracefully
	exit();
  800121:	e8 0a 00 00 00       	call   800130 <exit>
}
  800126:	83 c4 10             	add    $0x10,%esp
  800129:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80012c:	5b                   	pop    %ebx
  80012d:	5e                   	pop    %esi
  80012e:	5d                   	pop    %ebp
  80012f:	c3                   	ret    

00800130 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800130:	55                   	push   %ebp
  800131:	89 e5                	mov    %esp,%ebp
  800133:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800136:	e8 d1 11 00 00       	call   80130c <close_all>
	sys_env_destroy(0);
  80013b:	83 ec 0c             	sub    $0xc,%esp
  80013e:	6a 00                	push   $0x0
  800140:	e8 6d 0a 00 00       	call   800bb2 <sys_env_destroy>
}
  800145:	83 c4 10             	add    $0x10,%esp
  800148:	c9                   	leave  
  800149:	c3                   	ret    

0080014a <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80014a:	55                   	push   %ebp
  80014b:	89 e5                	mov    %esp,%ebp
  80014d:	53                   	push   %ebx
  80014e:	83 ec 04             	sub    $0x4,%esp
  800151:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800154:	8b 13                	mov    (%ebx),%edx
  800156:	8d 42 01             	lea    0x1(%edx),%eax
  800159:	89 03                	mov    %eax,(%ebx)
  80015b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80015e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800162:	3d ff 00 00 00       	cmp    $0xff,%eax
  800167:	75 1a                	jne    800183 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800169:	83 ec 08             	sub    $0x8,%esp
  80016c:	68 ff 00 00 00       	push   $0xff
  800171:	8d 43 08             	lea    0x8(%ebx),%eax
  800174:	50                   	push   %eax
  800175:	e8 fb 09 00 00       	call   800b75 <sys_cputs>
		b->idx = 0;
  80017a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800180:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800183:	ff 43 04             	incl   0x4(%ebx)
}
  800186:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800189:	c9                   	leave  
  80018a:	c3                   	ret    

0080018b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80018b:	55                   	push   %ebp
  80018c:	89 e5                	mov    %esp,%ebp
  80018e:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800194:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80019b:	00 00 00 
	b.cnt = 0;
  80019e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001a5:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001a8:	ff 75 0c             	pushl  0xc(%ebp)
  8001ab:	ff 75 08             	pushl  0x8(%ebp)
  8001ae:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001b4:	50                   	push   %eax
  8001b5:	68 4a 01 80 00       	push   $0x80014a
  8001ba:	e8 54 01 00 00       	call   800313 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001bf:	83 c4 08             	add    $0x8,%esp
  8001c2:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001c8:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001ce:	50                   	push   %eax
  8001cf:	e8 a1 09 00 00       	call   800b75 <sys_cputs>

	return b.cnt;
}
  8001d4:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001da:	c9                   	leave  
  8001db:	c3                   	ret    

008001dc <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001dc:	55                   	push   %ebp
  8001dd:	89 e5                	mov    %esp,%ebp
  8001df:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001e2:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001e5:	50                   	push   %eax
  8001e6:	ff 75 08             	pushl  0x8(%ebp)
  8001e9:	e8 9d ff ff ff       	call   80018b <vcprintf>
	va_end(ap);

	return cnt;
}
  8001ee:	c9                   	leave  
  8001ef:	c3                   	ret    

008001f0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001f0:	55                   	push   %ebp
  8001f1:	89 e5                	mov    %esp,%ebp
  8001f3:	57                   	push   %edi
  8001f4:	56                   	push   %esi
  8001f5:	53                   	push   %ebx
  8001f6:	83 ec 1c             	sub    $0x1c,%esp
  8001f9:	89 c6                	mov    %eax,%esi
  8001fb:	89 d7                	mov    %edx,%edi
  8001fd:	8b 45 08             	mov    0x8(%ebp),%eax
  800200:	8b 55 0c             	mov    0xc(%ebp),%edx
  800203:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800206:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800209:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80020c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800211:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800214:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800217:	39 d3                	cmp    %edx,%ebx
  800219:	72 11                	jb     80022c <printnum+0x3c>
  80021b:	39 45 10             	cmp    %eax,0x10(%ebp)
  80021e:	76 0c                	jbe    80022c <printnum+0x3c>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800220:	8b 45 14             	mov    0x14(%ebp),%eax
  800223:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800226:	85 db                	test   %ebx,%ebx
  800228:	7f 37                	jg     800261 <printnum+0x71>
  80022a:	eb 44                	jmp    800270 <printnum+0x80>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80022c:	83 ec 0c             	sub    $0xc,%esp
  80022f:	ff 75 18             	pushl  0x18(%ebp)
  800232:	8b 45 14             	mov    0x14(%ebp),%eax
  800235:	48                   	dec    %eax
  800236:	50                   	push   %eax
  800237:	ff 75 10             	pushl  0x10(%ebp)
  80023a:	83 ec 08             	sub    $0x8,%esp
  80023d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800240:	ff 75 e0             	pushl  -0x20(%ebp)
  800243:	ff 75 dc             	pushl  -0x24(%ebp)
  800246:	ff 75 d8             	pushl  -0x28(%ebp)
  800249:	e8 9e 1d 00 00       	call   801fec <__udivdi3>
  80024e:	83 c4 18             	add    $0x18,%esp
  800251:	52                   	push   %edx
  800252:	50                   	push   %eax
  800253:	89 fa                	mov    %edi,%edx
  800255:	89 f0                	mov    %esi,%eax
  800257:	e8 94 ff ff ff       	call   8001f0 <printnum>
  80025c:	83 c4 20             	add    $0x20,%esp
  80025f:	eb 0f                	jmp    800270 <printnum+0x80>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800261:	83 ec 08             	sub    $0x8,%esp
  800264:	57                   	push   %edi
  800265:	ff 75 18             	pushl  0x18(%ebp)
  800268:	ff d6                	call   *%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80026a:	83 c4 10             	add    $0x10,%esp
  80026d:	4b                   	dec    %ebx
  80026e:	75 f1                	jne    800261 <printnum+0x71>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800270:	83 ec 08             	sub    $0x8,%esp
  800273:	57                   	push   %edi
  800274:	83 ec 04             	sub    $0x4,%esp
  800277:	ff 75 e4             	pushl  -0x1c(%ebp)
  80027a:	ff 75 e0             	pushl  -0x20(%ebp)
  80027d:	ff 75 dc             	pushl  -0x24(%ebp)
  800280:	ff 75 d8             	pushl  -0x28(%ebp)
  800283:	e8 74 1e 00 00       	call   8020fc <__umoddi3>
  800288:	83 c4 14             	add    $0x14,%esp
  80028b:	0f be 80 80 22 80 00 	movsbl 0x802280(%eax),%eax
  800292:	50                   	push   %eax
  800293:	ff d6                	call   *%esi
}
  800295:	83 c4 10             	add    $0x10,%esp
  800298:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80029b:	5b                   	pop    %ebx
  80029c:	5e                   	pop    %esi
  80029d:	5f                   	pop    %edi
  80029e:	5d                   	pop    %ebp
  80029f:	c3                   	ret    

008002a0 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002a0:	55                   	push   %ebp
  8002a1:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002a3:	83 fa 01             	cmp    $0x1,%edx
  8002a6:	7e 0e                	jle    8002b6 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002a8:	8b 10                	mov    (%eax),%edx
  8002aa:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002ad:	89 08                	mov    %ecx,(%eax)
  8002af:	8b 02                	mov    (%edx),%eax
  8002b1:	8b 52 04             	mov    0x4(%edx),%edx
  8002b4:	eb 22                	jmp    8002d8 <getuint+0x38>
	else if (lflag)
  8002b6:	85 d2                	test   %edx,%edx
  8002b8:	74 10                	je     8002ca <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002ba:	8b 10                	mov    (%eax),%edx
  8002bc:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002bf:	89 08                	mov    %ecx,(%eax)
  8002c1:	8b 02                	mov    (%edx),%eax
  8002c3:	ba 00 00 00 00       	mov    $0x0,%edx
  8002c8:	eb 0e                	jmp    8002d8 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002ca:	8b 10                	mov    (%eax),%edx
  8002cc:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002cf:	89 08                	mov    %ecx,(%eax)
  8002d1:	8b 02                	mov    (%edx),%eax
  8002d3:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002d8:	5d                   	pop    %ebp
  8002d9:	c3                   	ret    

008002da <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002da:	55                   	push   %ebp
  8002db:	89 e5                	mov    %esp,%ebp
  8002dd:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002e0:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8002e3:	8b 10                	mov    (%eax),%edx
  8002e5:	3b 50 04             	cmp    0x4(%eax),%edx
  8002e8:	73 0a                	jae    8002f4 <sprintputch+0x1a>
		*b->buf++ = ch;
  8002ea:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002ed:	89 08                	mov    %ecx,(%eax)
  8002ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8002f2:	88 02                	mov    %al,(%edx)
}
  8002f4:	5d                   	pop    %ebp
  8002f5:	c3                   	ret    

008002f6 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002f6:	55                   	push   %ebp
  8002f7:	89 e5                	mov    %esp,%ebp
  8002f9:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002fc:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002ff:	50                   	push   %eax
  800300:	ff 75 10             	pushl  0x10(%ebp)
  800303:	ff 75 0c             	pushl  0xc(%ebp)
  800306:	ff 75 08             	pushl  0x8(%ebp)
  800309:	e8 05 00 00 00       	call   800313 <vprintfmt>
	va_end(ap);
}
  80030e:	83 c4 10             	add    $0x10,%esp
  800311:	c9                   	leave  
  800312:	c3                   	ret    

00800313 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800313:	55                   	push   %ebp
  800314:	89 e5                	mov    %esp,%ebp
  800316:	57                   	push   %edi
  800317:	56                   	push   %esi
  800318:	53                   	push   %ebx
  800319:	83 ec 2c             	sub    $0x2c,%esp
  80031c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80031f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800322:	eb 03                	jmp    800327 <vprintfmt+0x14>
			break;

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
			for (fmt--; fmt[-1] != '%'; fmt--)
  800324:	89 75 10             	mov    %esi,0x10(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {    //遍历输入的第一个参数，即输出信息的格式，先把格式字符串中'%'之前的字符一个个输出，因为它们前面没有'%'，所以它们就是要直接显示在屏幕上的
  800327:	8b 45 10             	mov    0x10(%ebp),%eax
  80032a:	8d 70 01             	lea    0x1(%eax),%esi
  80032d:	0f b6 00             	movzbl (%eax),%eax
  800330:	83 f8 25             	cmp    $0x25,%eax
  800333:	74 25                	je     80035a <vprintfmt+0x47>
			if (ch == '\0')									//当然中间如果遇到'\0'，代表这个字符串的访问结束
  800335:	85 c0                	test   %eax,%eax
  800337:	75 0d                	jne    800346 <vprintfmt+0x33>
  800339:	e9 b5 03 00 00       	jmp    8006f3 <vprintfmt+0x3e0>
  80033e:	85 c0                	test   %eax,%eax
  800340:	0f 84 ad 03 00 00    	je     8006f3 <vprintfmt+0x3e0>
				return;
			putch(ch, putdat);								//调用putch函数，把一个字符ch输出到putdat指针所指向的地址中所存放的值对应的地址处
  800346:	83 ec 08             	sub    $0x8,%esp
  800349:	53                   	push   %ebx
  80034a:	50                   	push   %eax
  80034b:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {    //遍历输入的第一个参数，即输出信息的格式，先把格式字符串中'%'之前的字符一个个输出，因为它们前面没有'%'，所以它们就是要直接显示在屏幕上的
  80034d:	46                   	inc    %esi
  80034e:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  800352:	83 c4 10             	add    $0x10,%esp
  800355:	83 f8 25             	cmp    $0x25,%eax
  800358:	75 e4                	jne    80033e <vprintfmt+0x2b>
			if (width < 0)									//代表有小数点，但是小数点前面并没有数字，比如'%.6f'这种情况，此时代表整数部分全部显示
				width = 0;			
			goto reswitch;

		case '#':
			altflag = 1;
  80035a:	c6 45 e3 20          	movb   $0x20,-0x1d(%ebp)
  80035e:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800365:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80036c:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800373:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  80037a:	eb 07                	jmp    800383 <vprintfmt+0x70>
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  80037c:	8b 75 10             	mov    0x10(%ebp),%esi

		// flag to pad on the right
		case '-':											//%后面的'-'代表要进行左对齐输出，右边填空格，如果省略代表右对齐
			padc = '-';										//如果有这个字符代表左对齐，则把对齐方式标志位变为'-'
  80037f:	c6 45 e3 2d          	movb   $0x2d,-0x1d(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  800383:	8d 46 01             	lea    0x1(%esi),%eax
  800386:	89 45 10             	mov    %eax,0x10(%ebp)
  800389:	0f b6 16             	movzbl (%esi),%edx
  80038c:	8a 06                	mov    (%esi),%al
  80038e:	83 e8 23             	sub    $0x23,%eax
  800391:	3c 55                	cmp    $0x55,%al
  800393:	0f 87 03 03 00 00    	ja     80069c <vprintfmt+0x389>
  800399:	0f b6 c0             	movzbl %al,%eax
  80039c:	ff 24 85 c0 23 80 00 	jmp    *0x8023c0(,%eax,4)
  8003a3:	8b 75 10             	mov    0x10(%ebp),%esi
			padc = '-';										//如果有这个字符代表左对齐，则把对齐方式标志位变为'-'
			goto reswitch;									//处理下一个字符

		// flag to pad with 0's instead of spaces
		case '0':											//0--有0表示进行对齐输出时填0,如省略表示填入空格，并且如果为0，则一定是右对齐
			padc = '0';										//对其方式标志位变为0
  8003a6:	c6 45 e3 30          	movb   $0x30,-0x1d(%ebp)
  8003aa:	eb d7                	jmp    800383 <vprintfmt+0x70>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {					//把遇到的位数字符串转换为真实的位数，比如输入的'%40'，代表有效位数为40位，下面的循环就是把precesion的值设置为40
				precision = precision * 10 + ch - '0';
  8003ac:	8d 42 d0             	lea    -0x30(%edx),%eax
  8003af:	89 c1                	mov    %eax,%ecx
  8003b1:	89 45 d0             	mov    %eax,-0x30(%ebp)
				ch = *fmt;
  8003b4:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  8003b8:	8d 50 d0             	lea    -0x30(%eax),%edx
  8003bb:	83 fa 09             	cmp    $0x9,%edx
  8003be:	77 51                	ja     800411 <vprintfmt+0xfe>
  8003c0:	8b 75 10             	mov    0x10(%ebp),%esi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {					//把遇到的位数字符串转换为真实的位数，比如输入的'%40'，代表有效位数为40位，下面的循环就是把precesion的值设置为40
  8003c3:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  8003c4:	8d 14 89             	lea    (%ecx,%ecx,4),%edx
  8003c7:	01 d2                	add    %edx,%edx
  8003c9:	8d 4c 10 d0          	lea    -0x30(%eax,%edx,1),%ecx
				ch = *fmt;
  8003cd:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8003d0:	8d 50 d0             	lea    -0x30(%eax),%edx
  8003d3:	83 fa 09             	cmp    $0x9,%edx
  8003d6:	76 eb                	jbe    8003c3 <vprintfmt+0xb0>
  8003d8:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8003db:	eb 37                	jmp    800414 <vprintfmt+0x101>
					break;
			}
			goto process_precision;							//跳转到process_precistion子过程

		case '*':											//*--代表有效数字的位数也是由输入参数指定的，比如printf("%*.*f", 10, 2, n)，其中10,2就是用来指定显示的有效数字位数的
			precision = va_arg(ap, int);
  8003dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e0:	8d 50 04             	lea    0x4(%eax),%edx
  8003e3:	89 55 14             	mov    %edx,0x14(%ebp)
  8003e6:	8b 00                	mov    (%eax),%eax
  8003e8:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  8003eb:	8b 75 10             	mov    0x10(%ebp),%esi
			}
			goto process_precision;							//跳转到process_precistion子过程

		case '*':											//*--代表有效数字的位数也是由输入参数指定的，比如printf("%*.*f", 10, 2, n)，其中10,2就是用来指定显示的有效数字位数的
			precision = va_arg(ap, int);
			goto process_precision;
  8003ee:	eb 24                	jmp    800414 <vprintfmt+0x101>
  8003f0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003f4:	79 07                	jns    8003fd <vprintfmt+0xea>
  8003f6:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  8003fd:	8b 75 10             	mov    0x10(%ebp),%esi
  800400:	eb 81                	jmp    800383 <vprintfmt+0x70>
  800402:	8b 75 10             	mov    0x10(%ebp),%esi
			if (width < 0)									//代表有小数点，但是小数点前面并没有数字，比如'%.6f'这种情况，此时代表整数部分全部显示
				width = 0;			
			goto reswitch;

		case '#':
			altflag = 1;
  800405:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80040c:	e9 72 ff ff ff       	jmp    800383 <vprintfmt+0x70>
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  800411:	8b 75 10             	mov    0x10(%ebp),%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:									//处理输出精度，把width字段赋值为刚刚计算出来的precision值，所以width应该是整数部分的有效数字位数
			if (width < 0)
  800414:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800418:	0f 89 65 ff ff ff    	jns    800383 <vprintfmt+0x70>
				width = precision, precision = -1;
  80041e:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800421:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800424:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80042b:	e9 53 ff ff ff       	jmp    800383 <vprintfmt+0x70>
			goto reswitch;

		// long flag (doubled for long long)				
		case 'l':											//如果遇到'l'，代表应该是输入long类型，如果有两个'l'代表long long
			lflag++;										//此时把lflag++
  800430:	ff 45 d4             	incl   -0x2c(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  800433:	8b 75 10             	mov    0x10(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)				
		case 'l':											//如果遇到'l'，代表应该是输入long类型，如果有两个'l'代表long long
			lflag++;										//此时把lflag++
			goto reswitch;
  800436:	e9 48 ff ff ff       	jmp    800383 <vprintfmt+0x70>

		// character
		case 'c':											//如果是'c'代表显示一个字符
			putch(va_arg(ap, int), putdat);					//调用输出一个字符到内存的函数putch
  80043b:	8b 45 14             	mov    0x14(%ebp),%eax
  80043e:	8d 50 04             	lea    0x4(%eax),%edx
  800441:	89 55 14             	mov    %edx,0x14(%ebp)
  800444:	83 ec 08             	sub    $0x8,%esp
  800447:	53                   	push   %ebx
  800448:	ff 30                	pushl  (%eax)
  80044a:	ff d7                	call   *%edi
			break;
  80044c:	83 c4 10             	add    $0x10,%esp
  80044f:	e9 d3 fe ff ff       	jmp    800327 <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800454:	8b 45 14             	mov    0x14(%ebp),%eax
  800457:	8d 50 04             	lea    0x4(%eax),%edx
  80045a:	89 55 14             	mov    %edx,0x14(%ebp)
  80045d:	8b 00                	mov    (%eax),%eax
  80045f:	85 c0                	test   %eax,%eax
  800461:	79 02                	jns    800465 <vprintfmt+0x152>
  800463:	f7 d8                	neg    %eax
  800465:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800467:	83 f8 0f             	cmp    $0xf,%eax
  80046a:	7f 0b                	jg     800477 <vprintfmt+0x164>
  80046c:	8b 04 85 20 25 80 00 	mov    0x802520(,%eax,4),%eax
  800473:	85 c0                	test   %eax,%eax
  800475:	75 15                	jne    80048c <vprintfmt+0x179>
				printfmt(putch, putdat, "error %d", err);
  800477:	52                   	push   %edx
  800478:	68 98 22 80 00       	push   $0x802298
  80047d:	53                   	push   %ebx
  80047e:	57                   	push   %edi
  80047f:	e8 72 fe ff ff       	call   8002f6 <printfmt>
  800484:	83 c4 10             	add    $0x10,%esp
  800487:	e9 9b fe ff ff       	jmp    800327 <vprintfmt+0x14>
			else
				printfmt(putch, putdat, "%s", p);
  80048c:	50                   	push   %eax
  80048d:	68 27 27 80 00       	push   $0x802727
  800492:	53                   	push   %ebx
  800493:	57                   	push   %edi
  800494:	e8 5d fe ff ff       	call   8002f6 <printfmt>
  800499:	83 c4 10             	add    $0x10,%esp
  80049c:	e9 86 fe ff ff       	jmp    800327 <vprintfmt+0x14>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a4:	8d 50 04             	lea    0x4(%eax),%edx
  8004a7:	89 55 14             	mov    %edx,0x14(%ebp)
  8004aa:	8b 00                	mov    (%eax),%eax
  8004ac:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8004af:	85 c0                	test   %eax,%eax
  8004b1:	75 07                	jne    8004ba <vprintfmt+0x1a7>
				p = "(null)";
  8004b3:	c7 45 d4 91 22 80 00 	movl   $0x802291,-0x2c(%ebp)
			if (width > 0 && padc != '-')
  8004ba:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8004bd:	85 f6                	test   %esi,%esi
  8004bf:	0f 8e fb 01 00 00    	jle    8006c0 <vprintfmt+0x3ad>
  8004c5:	80 7d e3 2d          	cmpb   $0x2d,-0x1d(%ebp)
  8004c9:	0f 84 09 02 00 00    	je     8006d8 <vprintfmt+0x3c5>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004cf:	83 ec 08             	sub    $0x8,%esp
  8004d2:	ff 75 d0             	pushl  -0x30(%ebp)
  8004d5:	ff 75 d4             	pushl  -0x2c(%ebp)
  8004d8:	e8 ad 02 00 00       	call   80078a <strnlen>
  8004dd:	89 f1                	mov    %esi,%ecx
  8004df:	29 c1                	sub    %eax,%ecx
  8004e1:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  8004e4:	83 c4 10             	add    $0x10,%esp
  8004e7:	85 c9                	test   %ecx,%ecx
  8004e9:	0f 8e d1 01 00 00    	jle    8006c0 <vprintfmt+0x3ad>
					putch(padc, putdat);
  8004ef:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  8004f3:	83 ec 08             	sub    $0x8,%esp
  8004f6:	53                   	push   %ebx
  8004f7:	56                   	push   %esi
  8004f8:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004fa:	83 c4 10             	add    $0x10,%esp
  8004fd:	ff 4d e4             	decl   -0x1c(%ebp)
  800500:	75 f1                	jne    8004f3 <vprintfmt+0x1e0>
  800502:	e9 b9 01 00 00       	jmp    8006c0 <vprintfmt+0x3ad>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800507:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80050b:	74 19                	je     800526 <vprintfmt+0x213>
  80050d:	0f be c0             	movsbl %al,%eax
  800510:	83 e8 20             	sub    $0x20,%eax
  800513:	83 f8 5e             	cmp    $0x5e,%eax
  800516:	76 0e                	jbe    800526 <vprintfmt+0x213>
					putch('?', putdat);
  800518:	83 ec 08             	sub    $0x8,%esp
  80051b:	53                   	push   %ebx
  80051c:	6a 3f                	push   $0x3f
  80051e:	ff 55 08             	call   *0x8(%ebp)
  800521:	83 c4 10             	add    $0x10,%esp
  800524:	eb 0b                	jmp    800531 <vprintfmt+0x21e>
				else
					putch(ch, putdat);
  800526:	83 ec 08             	sub    $0x8,%esp
  800529:	53                   	push   %ebx
  80052a:	52                   	push   %edx
  80052b:	ff 55 08             	call   *0x8(%ebp)
  80052e:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800531:	ff 4d e4             	decl   -0x1c(%ebp)
  800534:	46                   	inc    %esi
  800535:	8a 46 ff             	mov    -0x1(%esi),%al
  800538:	0f be d0             	movsbl %al,%edx
  80053b:	85 d2                	test   %edx,%edx
  80053d:	75 1c                	jne    80055b <vprintfmt+0x248>
  80053f:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800542:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800546:	7f 1f                	jg     800567 <vprintfmt+0x254>
  800548:	e9 da fd ff ff       	jmp    800327 <vprintfmt+0x14>
  80054d:	89 7d 08             	mov    %edi,0x8(%ebp)
  800550:	8b 7d d0             	mov    -0x30(%ebp),%edi
  800553:	eb 06                	jmp    80055b <vprintfmt+0x248>
  800555:	89 7d 08             	mov    %edi,0x8(%ebp)
  800558:	8b 7d d0             	mov    -0x30(%ebp),%edi
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80055b:	85 ff                	test   %edi,%edi
  80055d:	78 a8                	js     800507 <vprintfmt+0x1f4>
  80055f:	4f                   	dec    %edi
  800560:	79 a5                	jns    800507 <vprintfmt+0x1f4>
  800562:	8b 7d 08             	mov    0x8(%ebp),%edi
  800565:	eb db                	jmp    800542 <vprintfmt+0x22f>
  800567:	8b 75 e4             	mov    -0x1c(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80056a:	83 ec 08             	sub    $0x8,%esp
  80056d:	53                   	push   %ebx
  80056e:	6a 20                	push   $0x20
  800570:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800572:	4e                   	dec    %esi
  800573:	83 c4 10             	add    $0x10,%esp
  800576:	85 f6                	test   %esi,%esi
  800578:	7f f0                	jg     80056a <vprintfmt+0x257>
  80057a:	e9 a8 fd ff ff       	jmp    800327 <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80057f:	83 7d d4 01          	cmpl   $0x1,-0x2c(%ebp)
  800583:	7e 16                	jle    80059b <vprintfmt+0x288>
		return va_arg(*ap, long long);
  800585:	8b 45 14             	mov    0x14(%ebp),%eax
  800588:	8d 50 08             	lea    0x8(%eax),%edx
  80058b:	89 55 14             	mov    %edx,0x14(%ebp)
  80058e:	8b 50 04             	mov    0x4(%eax),%edx
  800591:	8b 00                	mov    (%eax),%eax
  800593:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800596:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800599:	eb 34                	jmp    8005cf <vprintfmt+0x2bc>
	else if (lflag)
  80059b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80059f:	74 18                	je     8005b9 <vprintfmt+0x2a6>
		return va_arg(*ap, long);
  8005a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a4:	8d 50 04             	lea    0x4(%eax),%edx
  8005a7:	89 55 14             	mov    %edx,0x14(%ebp)
  8005aa:	8b 30                	mov    (%eax),%esi
  8005ac:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8005af:	89 f0                	mov    %esi,%eax
  8005b1:	c1 f8 1f             	sar    $0x1f,%eax
  8005b4:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8005b7:	eb 16                	jmp    8005cf <vprintfmt+0x2bc>
	else
		return va_arg(*ap, int);
  8005b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005bc:	8d 50 04             	lea    0x4(%eax),%edx
  8005bf:	89 55 14             	mov    %edx,0x14(%ebp)
  8005c2:	8b 30                	mov    (%eax),%esi
  8005c4:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8005c7:	89 f0                	mov    %esi,%eax
  8005c9:	c1 f8 1f             	sar    $0x1f,%eax
  8005cc:	89 45 dc             	mov    %eax,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005cf:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005d2:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
  8005d5:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005d9:	0f 89 8a 00 00 00    	jns    800669 <vprintfmt+0x356>
				putch('-', putdat);
  8005df:	83 ec 08             	sub    $0x8,%esp
  8005e2:	53                   	push   %ebx
  8005e3:	6a 2d                	push   $0x2d
  8005e5:	ff d7                	call   *%edi
				num = -(long long) num;
  8005e7:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005ea:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005ed:	f7 d8                	neg    %eax
  8005ef:	83 d2 00             	adc    $0x0,%edx
  8005f2:	f7 da                	neg    %edx
  8005f4:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005f7:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8005fc:	eb 70                	jmp    80066e <vprintfmt+0x35b>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005fe:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800601:	8d 45 14             	lea    0x14(%ebp),%eax
  800604:	e8 97 fc ff ff       	call   8002a0 <getuint>
			base = 10;
  800609:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80060e:	eb 5e                	jmp    80066e <vprintfmt+0x35b>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
  800610:	83 ec 08             	sub    $0x8,%esp
  800613:	53                   	push   %ebx
  800614:	6a 30                	push   $0x30
  800616:	ff d7                	call   *%edi
			num = getuint(&ap, lflag);
  800618:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80061b:	8d 45 14             	lea    0x14(%ebp),%eax
  80061e:	e8 7d fc ff ff       	call   8002a0 <getuint>
			base = 8;
			goto number;
  800623:	83 c4 10             	add    $0x10,%esp
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  800626:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80062b:	eb 41                	jmp    80066e <vprintfmt+0x35b>
		// pointer
		case 'p':
			putch('0', putdat);
  80062d:	83 ec 08             	sub    $0x8,%esp
  800630:	53                   	push   %ebx
  800631:	6a 30                	push   $0x30
  800633:	ff d7                	call   *%edi
			putch('x', putdat);
  800635:	83 c4 08             	add    $0x8,%esp
  800638:	53                   	push   %ebx
  800639:	6a 78                	push   $0x78
  80063b:	ff d7                	call   *%edi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80063d:	8b 45 14             	mov    0x14(%ebp),%eax
  800640:	8d 50 04             	lea    0x4(%eax),%edx
  800643:	89 55 14             	mov    %edx,0x14(%ebp)
			goto number;
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800646:	8b 00                	mov    (%eax),%eax
  800648:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80064d:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800650:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800655:	eb 17                	jmp    80066e <vprintfmt+0x35b>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800657:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80065a:	8d 45 14             	lea    0x14(%ebp),%eax
  80065d:	e8 3e fc ff ff       	call   8002a0 <getuint>
			base = 16;
  800662:	b9 10 00 00 00       	mov    $0x10,%ecx
  800667:	eb 05                	jmp    80066e <vprintfmt+0x35b>
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800669:	b9 0a 00 00 00       	mov    $0xa,%ecx
		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  80066e:	83 ec 0c             	sub    $0xc,%esp
  800671:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  800675:	56                   	push   %esi
  800676:	ff 75 e4             	pushl  -0x1c(%ebp)
  800679:	51                   	push   %ecx
  80067a:	52                   	push   %edx
  80067b:	50                   	push   %eax
  80067c:	89 da                	mov    %ebx,%edx
  80067e:	89 f8                	mov    %edi,%eax
  800680:	e8 6b fb ff ff       	call   8001f0 <printnum>
			break;
  800685:	83 c4 20             	add    $0x20,%esp
  800688:	e9 9a fc ff ff       	jmp    800327 <vprintfmt+0x14>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80068d:	83 ec 08             	sub    $0x8,%esp
  800690:	53                   	push   %ebx
  800691:	52                   	push   %edx
  800692:	ff d7                	call   *%edi
			break;
  800694:	83 c4 10             	add    $0x10,%esp
  800697:	e9 8b fc ff ff       	jmp    800327 <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80069c:	83 ec 08             	sub    $0x8,%esp
  80069f:	53                   	push   %ebx
  8006a0:	6a 25                	push   $0x25
  8006a2:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006a4:	83 c4 10             	add    $0x10,%esp
  8006a7:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8006ab:	0f 84 73 fc ff ff    	je     800324 <vprintfmt+0x11>
  8006b1:	4e                   	dec    %esi
  8006b2:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8006b6:	75 f9                	jne    8006b1 <vprintfmt+0x39e>
  8006b8:	89 75 10             	mov    %esi,0x10(%ebp)
  8006bb:	e9 67 fc ff ff       	jmp    800327 <vprintfmt+0x14>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006c0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8006c3:	8d 70 01             	lea    0x1(%eax),%esi
  8006c6:	8a 00                	mov    (%eax),%al
  8006c8:	0f be d0             	movsbl %al,%edx
  8006cb:	85 d2                	test   %edx,%edx
  8006cd:	0f 85 7a fe ff ff    	jne    80054d <vprintfmt+0x23a>
  8006d3:	e9 4f fc ff ff       	jmp    800327 <vprintfmt+0x14>
  8006d8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8006db:	8d 70 01             	lea    0x1(%eax),%esi
  8006de:	8a 00                	mov    (%eax),%al
  8006e0:	0f be d0             	movsbl %al,%edx
  8006e3:	85 d2                	test   %edx,%edx
  8006e5:	0f 85 6a fe ff ff    	jne    800555 <vprintfmt+0x242>
  8006eb:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8006ee:	e9 77 fe ff ff       	jmp    80056a <vprintfmt+0x257>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  8006f3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006f6:	5b                   	pop    %ebx
  8006f7:	5e                   	pop    %esi
  8006f8:	5f                   	pop    %edi
  8006f9:	5d                   	pop    %ebp
  8006fa:	c3                   	ret    

008006fb <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006fb:	55                   	push   %ebp
  8006fc:	89 e5                	mov    %esp,%ebp
  8006fe:	83 ec 18             	sub    $0x18,%esp
  800701:	8b 45 08             	mov    0x8(%ebp),%eax
  800704:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800707:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80070a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80070e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800711:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800718:	85 c0                	test   %eax,%eax
  80071a:	74 26                	je     800742 <vsnprintf+0x47>
  80071c:	85 d2                	test   %edx,%edx
  80071e:	7e 29                	jle    800749 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800720:	ff 75 14             	pushl  0x14(%ebp)
  800723:	ff 75 10             	pushl  0x10(%ebp)
  800726:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800729:	50                   	push   %eax
  80072a:	68 da 02 80 00       	push   $0x8002da
  80072f:	e8 df fb ff ff       	call   800313 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800734:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800737:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80073a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80073d:	83 c4 10             	add    $0x10,%esp
  800740:	eb 0c                	jmp    80074e <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800742:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800747:	eb 05                	jmp    80074e <vsnprintf+0x53>
  800749:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80074e:	c9                   	leave  
  80074f:	c3                   	ret    

00800750 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800750:	55                   	push   %ebp
  800751:	89 e5                	mov    %esp,%ebp
  800753:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800756:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800759:	50                   	push   %eax
  80075a:	ff 75 10             	pushl  0x10(%ebp)
  80075d:	ff 75 0c             	pushl  0xc(%ebp)
  800760:	ff 75 08             	pushl  0x8(%ebp)
  800763:	e8 93 ff ff ff       	call   8006fb <vsnprintf>
	va_end(ap);

	return rc;
}
  800768:	c9                   	leave  
  800769:	c3                   	ret    

0080076a <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80076a:	55                   	push   %ebp
  80076b:	89 e5                	mov    %esp,%ebp
  80076d:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800770:	80 3a 00             	cmpb   $0x0,(%edx)
  800773:	74 0e                	je     800783 <strlen+0x19>
  800775:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  80077a:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80077b:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80077f:	75 f9                	jne    80077a <strlen+0x10>
  800781:	eb 05                	jmp    800788 <strlen+0x1e>
  800783:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800788:	5d                   	pop    %ebp
  800789:	c3                   	ret    

0080078a <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80078a:	55                   	push   %ebp
  80078b:	89 e5                	mov    %esp,%ebp
  80078d:	53                   	push   %ebx
  80078e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800791:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800794:	85 c9                	test   %ecx,%ecx
  800796:	74 1a                	je     8007b2 <strnlen+0x28>
  800798:	80 3b 00             	cmpb   $0x0,(%ebx)
  80079b:	74 1c                	je     8007b9 <strnlen+0x2f>
  80079d:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  8007a2:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007a4:	39 ca                	cmp    %ecx,%edx
  8007a6:	74 16                	je     8007be <strnlen+0x34>
  8007a8:	42                   	inc    %edx
  8007a9:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  8007ae:	75 f2                	jne    8007a2 <strnlen+0x18>
  8007b0:	eb 0c                	jmp    8007be <strnlen+0x34>
  8007b2:	b8 00 00 00 00       	mov    $0x0,%eax
  8007b7:	eb 05                	jmp    8007be <strnlen+0x34>
  8007b9:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8007be:	5b                   	pop    %ebx
  8007bf:	5d                   	pop    %ebp
  8007c0:	c3                   	ret    

008007c1 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007c1:	55                   	push   %ebp
  8007c2:	89 e5                	mov    %esp,%ebp
  8007c4:	53                   	push   %ebx
  8007c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8007c8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007cb:	89 c2                	mov    %eax,%edx
  8007cd:	42                   	inc    %edx
  8007ce:	41                   	inc    %ecx
  8007cf:	8a 59 ff             	mov    -0x1(%ecx),%bl
  8007d2:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007d5:	84 db                	test   %bl,%bl
  8007d7:	75 f4                	jne    8007cd <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007d9:	5b                   	pop    %ebx
  8007da:	5d                   	pop    %ebp
  8007db:	c3                   	ret    

008007dc <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007dc:	55                   	push   %ebp
  8007dd:	89 e5                	mov    %esp,%ebp
  8007df:	53                   	push   %ebx
  8007e0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007e3:	53                   	push   %ebx
  8007e4:	e8 81 ff ff ff       	call   80076a <strlen>
  8007e9:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007ec:	ff 75 0c             	pushl  0xc(%ebp)
  8007ef:	01 d8                	add    %ebx,%eax
  8007f1:	50                   	push   %eax
  8007f2:	e8 ca ff ff ff       	call   8007c1 <strcpy>
	return dst;
}
  8007f7:	89 d8                	mov    %ebx,%eax
  8007f9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007fc:	c9                   	leave  
  8007fd:	c3                   	ret    

008007fe <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007fe:	55                   	push   %ebp
  8007ff:	89 e5                	mov    %esp,%ebp
  800801:	56                   	push   %esi
  800802:	53                   	push   %ebx
  800803:	8b 75 08             	mov    0x8(%ebp),%esi
  800806:	8b 55 0c             	mov    0xc(%ebp),%edx
  800809:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80080c:	85 db                	test   %ebx,%ebx
  80080e:	74 14                	je     800824 <strncpy+0x26>
  800810:	01 f3                	add    %esi,%ebx
  800812:	89 f1                	mov    %esi,%ecx
		*dst++ = *src;
  800814:	41                   	inc    %ecx
  800815:	8a 02                	mov    (%edx),%al
  800817:	88 41 ff             	mov    %al,-0x1(%ecx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80081a:	80 3a 01             	cmpb   $0x1,(%edx)
  80081d:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800820:	39 cb                	cmp    %ecx,%ebx
  800822:	75 f0                	jne    800814 <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800824:	89 f0                	mov    %esi,%eax
  800826:	5b                   	pop    %ebx
  800827:	5e                   	pop    %esi
  800828:	5d                   	pop    %ebp
  800829:	c3                   	ret    

0080082a <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80082a:	55                   	push   %ebp
  80082b:	89 e5                	mov    %esp,%ebp
  80082d:	53                   	push   %ebx
  80082e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800831:	8b 45 10             	mov    0x10(%ebp),%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800834:	85 c0                	test   %eax,%eax
  800836:	74 30                	je     800868 <strlcpy+0x3e>
		while (--size > 0 && *src != '\0')
  800838:	48                   	dec    %eax
  800839:	74 20                	je     80085b <strlcpy+0x31>
  80083b:	8a 0b                	mov    (%ebx),%cl
  80083d:	84 c9                	test   %cl,%cl
  80083f:	74 1f                	je     800860 <strlcpy+0x36>
  800841:	8d 53 01             	lea    0x1(%ebx),%edx
  800844:	01 c3                	add    %eax,%ebx
  800846:	8b 45 08             	mov    0x8(%ebp),%eax
			*dst++ = *src++;
  800849:	40                   	inc    %eax
  80084a:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80084d:	39 da                	cmp    %ebx,%edx
  80084f:	74 12                	je     800863 <strlcpy+0x39>
  800851:	42                   	inc    %edx
  800852:	8a 4a ff             	mov    -0x1(%edx),%cl
  800855:	84 c9                	test   %cl,%cl
  800857:	75 f0                	jne    800849 <strlcpy+0x1f>
  800859:	eb 08                	jmp    800863 <strlcpy+0x39>
  80085b:	8b 45 08             	mov    0x8(%ebp),%eax
  80085e:	eb 03                	jmp    800863 <strlcpy+0x39>
  800860:	8b 45 08             	mov    0x8(%ebp),%eax
			*dst++ = *src++;
		*dst = '\0';
  800863:	c6 00 00             	movb   $0x0,(%eax)
  800866:	eb 03                	jmp    80086b <strlcpy+0x41>
  800868:	8b 45 08             	mov    0x8(%ebp),%eax
	}
	return dst - dst_in;
  80086b:	2b 45 08             	sub    0x8(%ebp),%eax
}
  80086e:	5b                   	pop    %ebx
  80086f:	5d                   	pop    %ebp
  800870:	c3                   	ret    

00800871 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800871:	55                   	push   %ebp
  800872:	89 e5                	mov    %esp,%ebp
  800874:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800877:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80087a:	8a 01                	mov    (%ecx),%al
  80087c:	84 c0                	test   %al,%al
  80087e:	74 10                	je     800890 <strcmp+0x1f>
  800880:	3a 02                	cmp    (%edx),%al
  800882:	75 0c                	jne    800890 <strcmp+0x1f>
		p++, q++;
  800884:	41                   	inc    %ecx
  800885:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800886:	8a 01                	mov    (%ecx),%al
  800888:	84 c0                	test   %al,%al
  80088a:	74 04                	je     800890 <strcmp+0x1f>
  80088c:	3a 02                	cmp    (%edx),%al
  80088e:	74 f4                	je     800884 <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800890:	0f b6 c0             	movzbl %al,%eax
  800893:	0f b6 12             	movzbl (%edx),%edx
  800896:	29 d0                	sub    %edx,%eax
}
  800898:	5d                   	pop    %ebp
  800899:	c3                   	ret    

0080089a <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80089a:	55                   	push   %ebp
  80089b:	89 e5                	mov    %esp,%ebp
  80089d:	56                   	push   %esi
  80089e:	53                   	push   %ebx
  80089f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8008a2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008a5:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  8008a8:	85 f6                	test   %esi,%esi
  8008aa:	74 23                	je     8008cf <strncmp+0x35>
  8008ac:	8a 03                	mov    (%ebx),%al
  8008ae:	84 c0                	test   %al,%al
  8008b0:	74 2b                	je     8008dd <strncmp+0x43>
  8008b2:	3a 02                	cmp    (%edx),%al
  8008b4:	75 27                	jne    8008dd <strncmp+0x43>
  8008b6:	8d 43 01             	lea    0x1(%ebx),%eax
  8008b9:	01 de                	add    %ebx,%esi
		n--, p++, q++;
  8008bb:	89 c3                	mov    %eax,%ebx
  8008bd:	42                   	inc    %edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008be:	39 c6                	cmp    %eax,%esi
  8008c0:	74 14                	je     8008d6 <strncmp+0x3c>
  8008c2:	8a 08                	mov    (%eax),%cl
  8008c4:	84 c9                	test   %cl,%cl
  8008c6:	74 15                	je     8008dd <strncmp+0x43>
  8008c8:	40                   	inc    %eax
  8008c9:	3a 0a                	cmp    (%edx),%cl
  8008cb:	74 ee                	je     8008bb <strncmp+0x21>
  8008cd:	eb 0e                	jmp    8008dd <strncmp+0x43>
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008cf:	b8 00 00 00 00       	mov    $0x0,%eax
  8008d4:	eb 0f                	jmp    8008e5 <strncmp+0x4b>
  8008d6:	b8 00 00 00 00       	mov    $0x0,%eax
  8008db:	eb 08                	jmp    8008e5 <strncmp+0x4b>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008dd:	0f b6 03             	movzbl (%ebx),%eax
  8008e0:	0f b6 12             	movzbl (%edx),%edx
  8008e3:	29 d0                	sub    %edx,%eax
}
  8008e5:	5b                   	pop    %ebx
  8008e6:	5e                   	pop    %esi
  8008e7:	5d                   	pop    %ebp
  8008e8:	c3                   	ret    

008008e9 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008e9:	55                   	push   %ebp
  8008ea:	89 e5                	mov    %esp,%ebp
  8008ec:	53                   	push   %ebx
  8008ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  8008f3:	8a 10                	mov    (%eax),%dl
  8008f5:	84 d2                	test   %dl,%dl
  8008f7:	74 1a                	je     800913 <strchr+0x2a>
  8008f9:	88 d9                	mov    %bl,%cl
		if (*s == c)
  8008fb:	38 d3                	cmp    %dl,%bl
  8008fd:	75 06                	jne    800905 <strchr+0x1c>
  8008ff:	eb 17                	jmp    800918 <strchr+0x2f>
  800901:	38 ca                	cmp    %cl,%dl
  800903:	74 13                	je     800918 <strchr+0x2f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800905:	40                   	inc    %eax
  800906:	8a 10                	mov    (%eax),%dl
  800908:	84 d2                	test   %dl,%dl
  80090a:	75 f5                	jne    800901 <strchr+0x18>
		if (*s == c)
			return (char *) s;
	return 0;
  80090c:	b8 00 00 00 00       	mov    $0x0,%eax
  800911:	eb 05                	jmp    800918 <strchr+0x2f>
  800913:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800918:	5b                   	pop    %ebx
  800919:	5d                   	pop    %ebp
  80091a:	c3                   	ret    

0080091b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80091b:	55                   	push   %ebp
  80091c:	89 e5                	mov    %esp,%ebp
  80091e:	53                   	push   %ebx
  80091f:	8b 45 08             	mov    0x8(%ebp),%eax
  800922:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  800925:	8a 10                	mov    (%eax),%dl
  800927:	84 d2                	test   %dl,%dl
  800929:	74 13                	je     80093e <strfind+0x23>
  80092b:	88 d9                	mov    %bl,%cl
		if (*s == c)
  80092d:	38 d3                	cmp    %dl,%bl
  80092f:	75 06                	jne    800937 <strfind+0x1c>
  800931:	eb 0b                	jmp    80093e <strfind+0x23>
  800933:	38 ca                	cmp    %cl,%dl
  800935:	74 07                	je     80093e <strfind+0x23>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800937:	40                   	inc    %eax
  800938:	8a 10                	mov    (%eax),%dl
  80093a:	84 d2                	test   %dl,%dl
  80093c:	75 f5                	jne    800933 <strfind+0x18>
		if (*s == c)
			break;
	return (char *) s;
}
  80093e:	5b                   	pop    %ebx
  80093f:	5d                   	pop    %ebp
  800940:	c3                   	ret    

00800941 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800941:	55                   	push   %ebp
  800942:	89 e5                	mov    %esp,%ebp
  800944:	57                   	push   %edi
  800945:	56                   	push   %esi
  800946:	53                   	push   %ebx
  800947:	8b 7d 08             	mov    0x8(%ebp),%edi
  80094a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80094d:	85 c9                	test   %ecx,%ecx
  80094f:	74 36                	je     800987 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800951:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800957:	75 28                	jne    800981 <memset+0x40>
  800959:	f6 c1 03             	test   $0x3,%cl
  80095c:	75 23                	jne    800981 <memset+0x40>
		c &= 0xFF;
  80095e:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800962:	89 d3                	mov    %edx,%ebx
  800964:	c1 e3 08             	shl    $0x8,%ebx
  800967:	89 d6                	mov    %edx,%esi
  800969:	c1 e6 18             	shl    $0x18,%esi
  80096c:	89 d0                	mov    %edx,%eax
  80096e:	c1 e0 10             	shl    $0x10,%eax
  800971:	09 f0                	or     %esi,%eax
  800973:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800975:	89 d8                	mov    %ebx,%eax
  800977:	09 d0                	or     %edx,%eax
  800979:	c1 e9 02             	shr    $0x2,%ecx
  80097c:	fc                   	cld    
  80097d:	f3 ab                	rep stos %eax,%es:(%edi)
  80097f:	eb 06                	jmp    800987 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800981:	8b 45 0c             	mov    0xc(%ebp),%eax
  800984:	fc                   	cld    
  800985:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800987:	89 f8                	mov    %edi,%eax
  800989:	5b                   	pop    %ebx
  80098a:	5e                   	pop    %esi
  80098b:	5f                   	pop    %edi
  80098c:	5d                   	pop    %ebp
  80098d:	c3                   	ret    

0080098e <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80098e:	55                   	push   %ebp
  80098f:	89 e5                	mov    %esp,%ebp
  800991:	57                   	push   %edi
  800992:	56                   	push   %esi
  800993:	8b 45 08             	mov    0x8(%ebp),%eax
  800996:	8b 75 0c             	mov    0xc(%ebp),%esi
  800999:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80099c:	39 c6                	cmp    %eax,%esi
  80099e:	73 33                	jae    8009d3 <memmove+0x45>
  8009a0:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009a3:	39 d0                	cmp    %edx,%eax
  8009a5:	73 2c                	jae    8009d3 <memmove+0x45>
		s += n;
		d += n;
  8009a7:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009aa:	89 d6                	mov    %edx,%esi
  8009ac:	09 fe                	or     %edi,%esi
  8009ae:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009b4:	75 13                	jne    8009c9 <memmove+0x3b>
  8009b6:	f6 c1 03             	test   $0x3,%cl
  8009b9:	75 0e                	jne    8009c9 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8009bb:	83 ef 04             	sub    $0x4,%edi
  8009be:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009c1:	c1 e9 02             	shr    $0x2,%ecx
  8009c4:	fd                   	std    
  8009c5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009c7:	eb 07                	jmp    8009d0 <memmove+0x42>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009c9:	4f                   	dec    %edi
  8009ca:	8d 72 ff             	lea    -0x1(%edx),%esi
  8009cd:	fd                   	std    
  8009ce:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009d0:	fc                   	cld    
  8009d1:	eb 1d                	jmp    8009f0 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009d3:	89 f2                	mov    %esi,%edx
  8009d5:	09 c2                	or     %eax,%edx
  8009d7:	f6 c2 03             	test   $0x3,%dl
  8009da:	75 0f                	jne    8009eb <memmove+0x5d>
  8009dc:	f6 c1 03             	test   $0x3,%cl
  8009df:	75 0a                	jne    8009eb <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
  8009e1:	c1 e9 02             	shr    $0x2,%ecx
  8009e4:	89 c7                	mov    %eax,%edi
  8009e6:	fc                   	cld    
  8009e7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009e9:	eb 05                	jmp    8009f0 <memmove+0x62>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009eb:	89 c7                	mov    %eax,%edi
  8009ed:	fc                   	cld    
  8009ee:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009f0:	5e                   	pop    %esi
  8009f1:	5f                   	pop    %edi
  8009f2:	5d                   	pop    %ebp
  8009f3:	c3                   	ret    

008009f4 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009f4:	55                   	push   %ebp
  8009f5:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009f7:	ff 75 10             	pushl  0x10(%ebp)
  8009fa:	ff 75 0c             	pushl  0xc(%ebp)
  8009fd:	ff 75 08             	pushl  0x8(%ebp)
  800a00:	e8 89 ff ff ff       	call   80098e <memmove>
}
  800a05:	c9                   	leave  
  800a06:	c3                   	ret    

00800a07 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a07:	55                   	push   %ebp
  800a08:	89 e5                	mov    %esp,%ebp
  800a0a:	57                   	push   %edi
  800a0b:	56                   	push   %esi
  800a0c:	53                   	push   %ebx
  800a0d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800a10:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a13:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a16:	85 c0                	test   %eax,%eax
  800a18:	74 33                	je     800a4d <memcmp+0x46>
  800a1a:	8d 78 ff             	lea    -0x1(%eax),%edi
		if (*s1 != *s2)
  800a1d:	8a 13                	mov    (%ebx),%dl
  800a1f:	8a 0e                	mov    (%esi),%cl
  800a21:	38 ca                	cmp    %cl,%dl
  800a23:	75 13                	jne    800a38 <memcmp+0x31>
  800a25:	b8 00 00 00 00       	mov    $0x0,%eax
  800a2a:	eb 16                	jmp    800a42 <memcmp+0x3b>
  800a2c:	8a 54 03 01          	mov    0x1(%ebx,%eax,1),%dl
  800a30:	40                   	inc    %eax
  800a31:	8a 0c 06             	mov    (%esi,%eax,1),%cl
  800a34:	38 ca                	cmp    %cl,%dl
  800a36:	74 0a                	je     800a42 <memcmp+0x3b>
			return (int) *s1 - (int) *s2;
  800a38:	0f b6 c2             	movzbl %dl,%eax
  800a3b:	0f b6 c9             	movzbl %cl,%ecx
  800a3e:	29 c8                	sub    %ecx,%eax
  800a40:	eb 10                	jmp    800a52 <memcmp+0x4b>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a42:	39 f8                	cmp    %edi,%eax
  800a44:	75 e6                	jne    800a2c <memcmp+0x25>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a46:	b8 00 00 00 00       	mov    $0x0,%eax
  800a4b:	eb 05                	jmp    800a52 <memcmp+0x4b>
  800a4d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a52:	5b                   	pop    %ebx
  800a53:	5e                   	pop    %esi
  800a54:	5f                   	pop    %edi
  800a55:	5d                   	pop    %ebp
  800a56:	c3                   	ret    

00800a57 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a57:	55                   	push   %ebp
  800a58:	89 e5                	mov    %esp,%ebp
  800a5a:	53                   	push   %ebx
  800a5b:	8b 55 08             	mov    0x8(%ebp),%edx
	const void *ends = (const char *) s + n;
  800a5e:	89 d0                	mov    %edx,%eax
  800a60:	03 45 10             	add    0x10(%ebp),%eax
	for (; s < ends; s++)
  800a63:	39 c2                	cmp    %eax,%edx
  800a65:	73 1b                	jae    800a82 <memfind+0x2b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a67:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
  800a6b:	0f b6 0a             	movzbl (%edx),%ecx
  800a6e:	39 d9                	cmp    %ebx,%ecx
  800a70:	75 09                	jne    800a7b <memfind+0x24>
  800a72:	eb 12                	jmp    800a86 <memfind+0x2f>
  800a74:	0f b6 0a             	movzbl (%edx),%ecx
  800a77:	39 d9                	cmp    %ebx,%ecx
  800a79:	74 0f                	je     800a8a <memfind+0x33>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a7b:	42                   	inc    %edx
  800a7c:	39 d0                	cmp    %edx,%eax
  800a7e:	75 f4                	jne    800a74 <memfind+0x1d>
  800a80:	eb 0a                	jmp    800a8c <memfind+0x35>
  800a82:	89 d0                	mov    %edx,%eax
  800a84:	eb 06                	jmp    800a8c <memfind+0x35>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a86:	89 d0                	mov    %edx,%eax
  800a88:	eb 02                	jmp    800a8c <memfind+0x35>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a8a:	89 d0                	mov    %edx,%eax
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a8c:	5b                   	pop    %ebx
  800a8d:	5d                   	pop    %ebp
  800a8e:	c3                   	ret    

00800a8f <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a8f:	55                   	push   %ebp
  800a90:	89 e5                	mov    %esp,%ebp
  800a92:	57                   	push   %edi
  800a93:	56                   	push   %esi
  800a94:	53                   	push   %ebx
  800a95:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a98:	eb 01                	jmp    800a9b <strtol+0xc>
		s++;
  800a9a:	41                   	inc    %ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a9b:	8a 01                	mov    (%ecx),%al
  800a9d:	3c 20                	cmp    $0x20,%al
  800a9f:	74 f9                	je     800a9a <strtol+0xb>
  800aa1:	3c 09                	cmp    $0x9,%al
  800aa3:	74 f5                	je     800a9a <strtol+0xb>
		s++;

	// plus/minus sign
	if (*s == '+')
  800aa5:	3c 2b                	cmp    $0x2b,%al
  800aa7:	75 08                	jne    800ab1 <strtol+0x22>
		s++;
  800aa9:	41                   	inc    %ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800aaa:	bf 00 00 00 00       	mov    $0x0,%edi
  800aaf:	eb 11                	jmp    800ac2 <strtol+0x33>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800ab1:	3c 2d                	cmp    $0x2d,%al
  800ab3:	75 08                	jne    800abd <strtol+0x2e>
		s++, neg = 1;
  800ab5:	41                   	inc    %ecx
  800ab6:	bf 01 00 00 00       	mov    $0x1,%edi
  800abb:	eb 05                	jmp    800ac2 <strtol+0x33>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800abd:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ac2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800ac6:	0f 84 87 00 00 00    	je     800b53 <strtol+0xc4>
  800acc:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  800ad0:	75 27                	jne    800af9 <strtol+0x6a>
  800ad2:	80 39 30             	cmpb   $0x30,(%ecx)
  800ad5:	75 22                	jne    800af9 <strtol+0x6a>
  800ad7:	e9 88 00 00 00       	jmp    800b64 <strtol+0xd5>
		s += 2, base = 16;
  800adc:	83 c1 02             	add    $0x2,%ecx
  800adf:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  800ae6:	eb 11                	jmp    800af9 <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
  800ae8:	41                   	inc    %ecx
  800ae9:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  800af0:	eb 07                	jmp    800af9 <strtol+0x6a>
	else if (base == 0)
		base = 10;
  800af2:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)
  800af9:	b8 00 00 00 00       	mov    $0x0,%eax

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800afe:	8a 11                	mov    (%ecx),%dl
  800b00:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800b03:	80 fb 09             	cmp    $0x9,%bl
  800b06:	77 08                	ja     800b10 <strtol+0x81>
			dig = *s - '0';
  800b08:	0f be d2             	movsbl %dl,%edx
  800b0b:	83 ea 30             	sub    $0x30,%edx
  800b0e:	eb 22                	jmp    800b32 <strtol+0xa3>
		else if (*s >= 'a' && *s <= 'z')
  800b10:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b13:	89 f3                	mov    %esi,%ebx
  800b15:	80 fb 19             	cmp    $0x19,%bl
  800b18:	77 08                	ja     800b22 <strtol+0x93>
			dig = *s - 'a' + 10;
  800b1a:	0f be d2             	movsbl %dl,%edx
  800b1d:	83 ea 57             	sub    $0x57,%edx
  800b20:	eb 10                	jmp    800b32 <strtol+0xa3>
		else if (*s >= 'A' && *s <= 'Z')
  800b22:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b25:	89 f3                	mov    %esi,%ebx
  800b27:	80 fb 19             	cmp    $0x19,%bl
  800b2a:	77 14                	ja     800b40 <strtol+0xb1>
			dig = *s - 'A' + 10;
  800b2c:	0f be d2             	movsbl %dl,%edx
  800b2f:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b32:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b35:	7d 09                	jge    800b40 <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800b37:	41                   	inc    %ecx
  800b38:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b3c:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b3e:	eb be                	jmp    800afe <strtol+0x6f>

	if (endptr)
  800b40:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b44:	74 05                	je     800b4b <strtol+0xbc>
		*endptr = (char *) s;
  800b46:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b49:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800b4b:	85 ff                	test   %edi,%edi
  800b4d:	74 21                	je     800b70 <strtol+0xe1>
  800b4f:	f7 d8                	neg    %eax
  800b51:	eb 1d                	jmp    800b70 <strtol+0xe1>
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b53:	80 39 30             	cmpb   $0x30,(%ecx)
  800b56:	75 9a                	jne    800af2 <strtol+0x63>
  800b58:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b5c:	0f 84 7a ff ff ff    	je     800adc <strtol+0x4d>
  800b62:	eb 84                	jmp    800ae8 <strtol+0x59>
  800b64:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b68:	0f 84 6e ff ff ff    	je     800adc <strtol+0x4d>
  800b6e:	eb 89                	jmp    800af9 <strtol+0x6a>
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
}
  800b70:	5b                   	pop    %ebx
  800b71:	5e                   	pop    %esi
  800b72:	5f                   	pop    %edi
  800b73:	5d                   	pop    %ebp
  800b74:	c3                   	ret    

00800b75 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b75:	55                   	push   %ebp
  800b76:	89 e5                	mov    %esp,%ebp
  800b78:	57                   	push   %edi
  800b79:	56                   	push   %esi
  800b7a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b7b:	b8 00 00 00 00       	mov    $0x0,%eax
  800b80:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b83:	8b 55 08             	mov    0x8(%ebp),%edx
  800b86:	89 c3                	mov    %eax,%ebx
  800b88:	89 c7                	mov    %eax,%edi
  800b8a:	89 c6                	mov    %eax,%esi
  800b8c:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b8e:	5b                   	pop    %ebx
  800b8f:	5e                   	pop    %esi
  800b90:	5f                   	pop    %edi
  800b91:	5d                   	pop    %ebp
  800b92:	c3                   	ret    

00800b93 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b93:	55                   	push   %ebp
  800b94:	89 e5                	mov    %esp,%ebp
  800b96:	57                   	push   %edi
  800b97:	56                   	push   %esi
  800b98:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b99:	ba 00 00 00 00       	mov    $0x0,%edx
  800b9e:	b8 01 00 00 00       	mov    $0x1,%eax
  800ba3:	89 d1                	mov    %edx,%ecx
  800ba5:	89 d3                	mov    %edx,%ebx
  800ba7:	89 d7                	mov    %edx,%edi
  800ba9:	89 d6                	mov    %edx,%esi
  800bab:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bad:	5b                   	pop    %ebx
  800bae:	5e                   	pop    %esi
  800baf:	5f                   	pop    %edi
  800bb0:	5d                   	pop    %ebp
  800bb1:	c3                   	ret    

00800bb2 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bb2:	55                   	push   %ebp
  800bb3:	89 e5                	mov    %esp,%ebp
  800bb5:	57                   	push   %edi
  800bb6:	56                   	push   %esi
  800bb7:	53                   	push   %ebx
  800bb8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bbb:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bc0:	b8 03 00 00 00       	mov    $0x3,%eax
  800bc5:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc8:	89 cb                	mov    %ecx,%ebx
  800bca:	89 cf                	mov    %ecx,%edi
  800bcc:	89 ce                	mov    %ecx,%esi
  800bce:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bd0:	85 c0                	test   %eax,%eax
  800bd2:	7e 17                	jle    800beb <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bd4:	83 ec 0c             	sub    $0xc,%esp
  800bd7:	50                   	push   %eax
  800bd8:	6a 03                	push   $0x3
  800bda:	68 7f 25 80 00       	push   $0x80257f
  800bdf:	6a 23                	push   $0x23
  800be1:	68 9c 25 80 00       	push   $0x80259c
  800be6:	e8 aa 11 00 00       	call   801d95 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800beb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bee:	5b                   	pop    %ebx
  800bef:	5e                   	pop    %esi
  800bf0:	5f                   	pop    %edi
  800bf1:	5d                   	pop    %ebp
  800bf2:	c3                   	ret    

00800bf3 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bf3:	55                   	push   %ebp
  800bf4:	89 e5                	mov    %esp,%ebp
  800bf6:	57                   	push   %edi
  800bf7:	56                   	push   %esi
  800bf8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bf9:	ba 00 00 00 00       	mov    $0x0,%edx
  800bfe:	b8 02 00 00 00       	mov    $0x2,%eax
  800c03:	89 d1                	mov    %edx,%ecx
  800c05:	89 d3                	mov    %edx,%ebx
  800c07:	89 d7                	mov    %edx,%edi
  800c09:	89 d6                	mov    %edx,%esi
  800c0b:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c0d:	5b                   	pop    %ebx
  800c0e:	5e                   	pop    %esi
  800c0f:	5f                   	pop    %edi
  800c10:	5d                   	pop    %ebp
  800c11:	c3                   	ret    

00800c12 <sys_yield>:

void
sys_yield(void)
{
  800c12:	55                   	push   %ebp
  800c13:	89 e5                	mov    %esp,%ebp
  800c15:	57                   	push   %edi
  800c16:	56                   	push   %esi
  800c17:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c18:	ba 00 00 00 00       	mov    $0x0,%edx
  800c1d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c22:	89 d1                	mov    %edx,%ecx
  800c24:	89 d3                	mov    %edx,%ebx
  800c26:	89 d7                	mov    %edx,%edi
  800c28:	89 d6                	mov    %edx,%esi
  800c2a:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c2c:	5b                   	pop    %ebx
  800c2d:	5e                   	pop    %esi
  800c2e:	5f                   	pop    %edi
  800c2f:	5d                   	pop    %ebp
  800c30:	c3                   	ret    

00800c31 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c31:	55                   	push   %ebp
  800c32:	89 e5                	mov    %esp,%ebp
  800c34:	57                   	push   %edi
  800c35:	56                   	push   %esi
  800c36:	53                   	push   %ebx
  800c37:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c3a:	be 00 00 00 00       	mov    $0x0,%esi
  800c3f:	b8 04 00 00 00       	mov    $0x4,%eax
  800c44:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c47:	8b 55 08             	mov    0x8(%ebp),%edx
  800c4a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c4d:	89 f7                	mov    %esi,%edi
  800c4f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c51:	85 c0                	test   %eax,%eax
  800c53:	7e 17                	jle    800c6c <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c55:	83 ec 0c             	sub    $0xc,%esp
  800c58:	50                   	push   %eax
  800c59:	6a 04                	push   $0x4
  800c5b:	68 7f 25 80 00       	push   $0x80257f
  800c60:	6a 23                	push   $0x23
  800c62:	68 9c 25 80 00       	push   $0x80259c
  800c67:	e8 29 11 00 00       	call   801d95 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c6c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c6f:	5b                   	pop    %ebx
  800c70:	5e                   	pop    %esi
  800c71:	5f                   	pop    %edi
  800c72:	5d                   	pop    %ebp
  800c73:	c3                   	ret    

00800c74 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c74:	55                   	push   %ebp
  800c75:	89 e5                	mov    %esp,%ebp
  800c77:	57                   	push   %edi
  800c78:	56                   	push   %esi
  800c79:	53                   	push   %ebx
  800c7a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c7d:	b8 05 00 00 00       	mov    $0x5,%eax
  800c82:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c85:	8b 55 08             	mov    0x8(%ebp),%edx
  800c88:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c8b:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c8e:	8b 75 18             	mov    0x18(%ebp),%esi
  800c91:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c93:	85 c0                	test   %eax,%eax
  800c95:	7e 17                	jle    800cae <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c97:	83 ec 0c             	sub    $0xc,%esp
  800c9a:	50                   	push   %eax
  800c9b:	6a 05                	push   $0x5
  800c9d:	68 7f 25 80 00       	push   $0x80257f
  800ca2:	6a 23                	push   $0x23
  800ca4:	68 9c 25 80 00       	push   $0x80259c
  800ca9:	e8 e7 10 00 00       	call   801d95 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800cae:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb1:	5b                   	pop    %ebx
  800cb2:	5e                   	pop    %esi
  800cb3:	5f                   	pop    %edi
  800cb4:	5d                   	pop    %ebp
  800cb5:	c3                   	ret    

00800cb6 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cb6:	55                   	push   %ebp
  800cb7:	89 e5                	mov    %esp,%ebp
  800cb9:	57                   	push   %edi
  800cba:	56                   	push   %esi
  800cbb:	53                   	push   %ebx
  800cbc:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cbf:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cc4:	b8 06 00 00 00       	mov    $0x6,%eax
  800cc9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ccc:	8b 55 08             	mov    0x8(%ebp),%edx
  800ccf:	89 df                	mov    %ebx,%edi
  800cd1:	89 de                	mov    %ebx,%esi
  800cd3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cd5:	85 c0                	test   %eax,%eax
  800cd7:	7e 17                	jle    800cf0 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cd9:	83 ec 0c             	sub    $0xc,%esp
  800cdc:	50                   	push   %eax
  800cdd:	6a 06                	push   $0x6
  800cdf:	68 7f 25 80 00       	push   $0x80257f
  800ce4:	6a 23                	push   $0x23
  800ce6:	68 9c 25 80 00       	push   $0x80259c
  800ceb:	e8 a5 10 00 00       	call   801d95 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cf0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf3:	5b                   	pop    %ebx
  800cf4:	5e                   	pop    %esi
  800cf5:	5f                   	pop    %edi
  800cf6:	5d                   	pop    %ebp
  800cf7:	c3                   	ret    

00800cf8 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cf8:	55                   	push   %ebp
  800cf9:	89 e5                	mov    %esp,%ebp
  800cfb:	57                   	push   %edi
  800cfc:	56                   	push   %esi
  800cfd:	53                   	push   %ebx
  800cfe:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d01:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d06:	b8 08 00 00 00       	mov    $0x8,%eax
  800d0b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d0e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d11:	89 df                	mov    %ebx,%edi
  800d13:	89 de                	mov    %ebx,%esi
  800d15:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d17:	85 c0                	test   %eax,%eax
  800d19:	7e 17                	jle    800d32 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d1b:	83 ec 0c             	sub    $0xc,%esp
  800d1e:	50                   	push   %eax
  800d1f:	6a 08                	push   $0x8
  800d21:	68 7f 25 80 00       	push   $0x80257f
  800d26:	6a 23                	push   $0x23
  800d28:	68 9c 25 80 00       	push   $0x80259c
  800d2d:	e8 63 10 00 00       	call   801d95 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d32:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d35:	5b                   	pop    %ebx
  800d36:	5e                   	pop    %esi
  800d37:	5f                   	pop    %edi
  800d38:	5d                   	pop    %ebp
  800d39:	c3                   	ret    

00800d3a <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d3a:	55                   	push   %ebp
  800d3b:	89 e5                	mov    %esp,%ebp
  800d3d:	57                   	push   %edi
  800d3e:	56                   	push   %esi
  800d3f:	53                   	push   %ebx
  800d40:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d43:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d48:	b8 09 00 00 00       	mov    $0x9,%eax
  800d4d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d50:	8b 55 08             	mov    0x8(%ebp),%edx
  800d53:	89 df                	mov    %ebx,%edi
  800d55:	89 de                	mov    %ebx,%esi
  800d57:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d59:	85 c0                	test   %eax,%eax
  800d5b:	7e 17                	jle    800d74 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d5d:	83 ec 0c             	sub    $0xc,%esp
  800d60:	50                   	push   %eax
  800d61:	6a 09                	push   $0x9
  800d63:	68 7f 25 80 00       	push   $0x80257f
  800d68:	6a 23                	push   $0x23
  800d6a:	68 9c 25 80 00       	push   $0x80259c
  800d6f:	e8 21 10 00 00       	call   801d95 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d74:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d77:	5b                   	pop    %ebx
  800d78:	5e                   	pop    %esi
  800d79:	5f                   	pop    %edi
  800d7a:	5d                   	pop    %ebp
  800d7b:	c3                   	ret    

00800d7c <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d7c:	55                   	push   %ebp
  800d7d:	89 e5                	mov    %esp,%ebp
  800d7f:	57                   	push   %edi
  800d80:	56                   	push   %esi
  800d81:	53                   	push   %ebx
  800d82:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d85:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d8a:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d8f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d92:	8b 55 08             	mov    0x8(%ebp),%edx
  800d95:	89 df                	mov    %ebx,%edi
  800d97:	89 de                	mov    %ebx,%esi
  800d99:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d9b:	85 c0                	test   %eax,%eax
  800d9d:	7e 17                	jle    800db6 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d9f:	83 ec 0c             	sub    $0xc,%esp
  800da2:	50                   	push   %eax
  800da3:	6a 0a                	push   $0xa
  800da5:	68 7f 25 80 00       	push   $0x80257f
  800daa:	6a 23                	push   $0x23
  800dac:	68 9c 25 80 00       	push   $0x80259c
  800db1:	e8 df 0f 00 00       	call   801d95 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800db6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800db9:	5b                   	pop    %ebx
  800dba:	5e                   	pop    %esi
  800dbb:	5f                   	pop    %edi
  800dbc:	5d                   	pop    %ebp
  800dbd:	c3                   	ret    

00800dbe <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800dbe:	55                   	push   %ebp
  800dbf:	89 e5                	mov    %esp,%ebp
  800dc1:	57                   	push   %edi
  800dc2:	56                   	push   %esi
  800dc3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dc4:	be 00 00 00 00       	mov    $0x0,%esi
  800dc9:	b8 0c 00 00 00       	mov    $0xc,%eax
  800dce:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd1:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dd7:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dda:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ddc:	5b                   	pop    %ebx
  800ddd:	5e                   	pop    %esi
  800dde:	5f                   	pop    %edi
  800ddf:	5d                   	pop    %ebp
  800de0:	c3                   	ret    

00800de1 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
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
  800dea:	b9 00 00 00 00       	mov    $0x0,%ecx
  800def:	b8 0d 00 00 00       	mov    $0xd,%eax
  800df4:	8b 55 08             	mov    0x8(%ebp),%edx
  800df7:	89 cb                	mov    %ecx,%ebx
  800df9:	89 cf                	mov    %ecx,%edi
  800dfb:	89 ce                	mov    %ecx,%esi
  800dfd:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dff:	85 c0                	test   %eax,%eax
  800e01:	7e 17                	jle    800e1a <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e03:	83 ec 0c             	sub    $0xc,%esp
  800e06:	50                   	push   %eax
  800e07:	6a 0d                	push   $0xd
  800e09:	68 7f 25 80 00       	push   $0x80257f
  800e0e:	6a 23                	push   $0x23
  800e10:	68 9c 25 80 00       	push   $0x80259c
  800e15:	e8 7b 0f 00 00       	call   801d95 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e1a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e1d:	5b                   	pop    %ebx
  800e1e:	5e                   	pop    %esi
  800e1f:	5f                   	pop    %edi
  800e20:	5d                   	pop    %ebp
  800e21:	c3                   	ret    

00800e22 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e22:	55                   	push   %ebp
  800e23:	89 e5                	mov    %esp,%ebp
  800e25:	56                   	push   %esi
  800e26:	53                   	push   %ebx
  800e27:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e2a:	8b 18                	mov    (%eax),%ebx
	// copy-on-write page.  If not, panic.
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).
	
	if((err & FEC_WR) == 0){
  800e2c:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e30:	75 14                	jne    800e46 <pgfault+0x24>
		panic("pgfault not cause by write \n");
  800e32:	83 ec 04             	sub    $0x4,%esp
  800e35:	68 aa 25 80 00       	push   $0x8025aa
  800e3a:	6a 1c                	push   $0x1c
  800e3c:	68 c7 25 80 00       	push   $0x8025c7
  800e41:	e8 4f 0f 00 00       	call   801d95 <_panic>
	}
 
	if ((uvpt[PGNUM(addr)] & PTE_COW) == 0) 
  800e46:	89 d8                	mov    %ebx,%eax
  800e48:	c1 e8 0c             	shr    $0xc,%eax
  800e4b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e52:	f6 c4 08             	test   $0x8,%ah
  800e55:	75 14                	jne    800e6b <pgfault+0x49>
    {
        panic("pgfault not cause by COW \n");
  800e57:	83 ec 04             	sub    $0x4,%esp
  800e5a:	68 d2 25 80 00       	push   $0x8025d2
  800e5f:	6a 21                	push   $0x21
  800e61:	68 c7 25 80 00       	push   $0x8025c7
  800e66:	e8 2a 0f 00 00       	call   801d95 <_panic>
	// copy the data from the old page to the new page, then move the new
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.
	envid_t eid = sys_getenvid();
  800e6b:	e8 83 fd ff ff       	call   800bf3 <sys_getenvid>
  800e70:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(eid,(void*)PFTEMP,PTE_P|PTE_W|PTE_U)) < 0)
  800e72:	83 ec 04             	sub    $0x4,%esp
  800e75:	6a 07                	push   $0x7
  800e77:	68 00 f0 7f 00       	push   $0x7ff000
  800e7c:	50                   	push   %eax
  800e7d:	e8 af fd ff ff       	call   800c31 <sys_page_alloc>
  800e82:	83 c4 10             	add    $0x10,%esp
  800e85:	85 c0                	test   %eax,%eax
  800e87:	79 14                	jns    800e9d <pgfault+0x7b>
		panic("page alloction failed.\n");
  800e89:	83 ec 04             	sub    $0x4,%esp
  800e8c:	68 ed 25 80 00       	push   $0x8025ed
  800e91:	6a 2d                	push   $0x2d
  800e93:	68 c7 25 80 00       	push   $0x8025c7
  800e98:	e8 f8 0e 00 00       	call   801d95 <_panic>
	addr = ROUNDDOWN(addr,PGSIZE);
  800e9d:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memmove(PFTEMP,addr,PGSIZE);
  800ea3:	83 ec 04             	sub    $0x4,%esp
  800ea6:	68 00 10 00 00       	push   $0x1000
  800eab:	53                   	push   %ebx
  800eac:	68 00 f0 7f 00       	push   $0x7ff000
  800eb1:	e8 d8 fa ff ff       	call   80098e <memmove>
	if ((r = sys_page_map(eid, PFTEMP, eid, addr, PTE_P | PTE_W |PTE_U)) < 0)
  800eb6:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800ebd:	53                   	push   %ebx
  800ebe:	56                   	push   %esi
  800ebf:	68 00 f0 7f 00       	push   $0x7ff000
  800ec4:	56                   	push   %esi
  800ec5:	e8 aa fd ff ff       	call   800c74 <sys_page_map>
  800eca:	83 c4 20             	add    $0x20,%esp
  800ecd:	85 c0                	test   %eax,%eax
  800ecf:	79 12                	jns    800ee3 <pgfault+0xc1>
        panic("pgfault: page map failed %e\n", r);
  800ed1:	50                   	push   %eax
  800ed2:	68 05 26 80 00       	push   $0x802605
  800ed7:	6a 31                	push   $0x31
  800ed9:	68 c7 25 80 00       	push   $0x8025c7
  800ede:	e8 b2 0e 00 00       	call   801d95 <_panic>
	if ((r = sys_page_unmap(eid, PFTEMP)) < 0)
  800ee3:	83 ec 08             	sub    $0x8,%esp
  800ee6:	68 00 f0 7f 00       	push   $0x7ff000
  800eeb:	56                   	push   %esi
  800eec:	e8 c5 fd ff ff       	call   800cb6 <sys_page_unmap>
  800ef1:	83 c4 10             	add    $0x10,%esp
  800ef4:	85 c0                	test   %eax,%eax
  800ef6:	79 12                	jns    800f0a <pgfault+0xe8>
        panic("pgfault: page unmap failed %e\n", r);
  800ef8:	50                   	push   %eax
  800ef9:	68 74 26 80 00       	push   $0x802674
  800efe:	6a 33                	push   $0x33
  800f00:	68 c7 25 80 00       	push   $0x8025c7
  800f05:	e8 8b 0e 00 00       	call   801d95 <_panic>
	// LAB 4: Your code here.

	// panic("pgfault not implemented");
}
  800f0a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f0d:	5b                   	pop    %ebx
  800f0e:	5e                   	pop    %esi
  800f0f:	5d                   	pop    %ebp
  800f10:	c3                   	ret    

00800f11 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f11:	55                   	push   %ebp
  800f12:	89 e5                	mov    %esp,%ebp
  800f14:	57                   	push   %edi
  800f15:	56                   	push   %esi
  800f16:	53                   	push   %ebx
  800f17:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	struct PageInfo* pg = NULL;
	set_pgfault_handler(pgfault);
  800f1a:	68 22 0e 80 00       	push   $0x800e22
  800f1f:	e8 b7 0e 00 00       	call   801ddb <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800f24:	b8 07 00 00 00       	mov    $0x7,%eax
  800f29:	cd 30                	int    $0x30
  800f2b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800f2e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t eid = sys_exofork();
	if (eid < 0) panic("fork fault.\n");
  800f31:	83 c4 10             	add    $0x10,%esp
  800f34:	85 c0                	test   %eax,%eax
  800f36:	79 14                	jns    800f4c <fork+0x3b>
  800f38:	83 ec 04             	sub    $0x4,%esp
  800f3b:	68 22 26 80 00       	push   $0x802622
  800f40:	6a 71                	push   $0x71
  800f42:	68 c7 25 80 00       	push   $0x8025c7
  800f47:	e8 49 0e 00 00       	call   801d95 <_panic>
	if (eid == 0){
  800f4c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800f50:	75 25                	jne    800f77 <fork+0x66>
		thisenv = &envs[ENVX(sys_getenvid())];
  800f52:	e8 9c fc ff ff       	call   800bf3 <sys_getenvid>
  800f57:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f5c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800f63:	c1 e0 07             	shl    $0x7,%eax
  800f66:	29 d0                	sub    %edx,%eax
  800f68:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f6d:	a3 04 40 80 00       	mov    %eax,0x804004
		return eid;
  800f72:	e9 61 01 00 00       	jmp    8010d8 <fork+0x1c7>
  800f77:	bb 00 00 80 00       	mov    $0x800000,%ebx
	}
	// copy something to the child page.
	for (uintptr_t i = UTEXT;i <= USTACKTOP;i += PGSIZE){
		if (uvpd[PDX(i)] & PTE_P && (uvpt[PGNUM(i)] & PTE_P)){
  800f7c:	89 d8                	mov    %ebx,%eax
  800f7e:	c1 e8 16             	shr    $0x16,%eax
  800f81:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f88:	a8 01                	test   $0x1,%al
  800f8a:	74 52                	je     800fde <fork+0xcd>
  800f8c:	89 de                	mov    %ebx,%esi
  800f8e:	c1 ee 0c             	shr    $0xc,%esi
  800f91:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800f98:	a8 01                	test   $0x1,%al
  800f9a:	74 42                	je     800fde <fork+0xcd>
duppage(envid_t envid, unsigned pn)
{
	int r;

	// LAB 4: Your code here.
	envid_t myenvid = sys_getenvid();
  800f9c:	e8 52 fc ff ff       	call   800bf3 <sys_getenvid>
  800fa1:	89 c7                	mov    %eax,%edi
	pte_t pte = uvpt[pn];
  800fa3:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
	int perm = PTE_U | PTE_P;
	if(pte & PTE_W || pte & PTE_COW)
  800faa:	a9 02 08 00 00       	test   $0x802,%eax
  800faf:	0f 85 de 00 00 00    	jne    801093 <fork+0x182>
  800fb5:	e9 fb 00 00 00       	jmp    8010b5 <fork+0x1a4>
		perm |= PTE_COW;
	if((r = sys_page_map(myenvid,(void*)(pn*PGSIZE),envid,(void*)(pn*PGSIZE),perm))<0){
		panic("duppage fault :%e\n",r);
  800fba:	50                   	push   %eax
  800fbb:	68 2f 26 80 00       	push   $0x80262f
  800fc0:	6a 50                	push   $0x50
  800fc2:	68 c7 25 80 00       	push   $0x8025c7
  800fc7:	e8 c9 0d 00 00       	call   801d95 <_panic>
	}
	if(perm & PTE_COW){
		if((r = sys_page_map(myenvid,(void*)(pn*PGSIZE),myenvid,(void*)(pn*PGSIZE),perm))<0)
			panic("duppage fault :%e\n",r);
  800fcc:	50                   	push   %eax
  800fcd:	68 2f 26 80 00       	push   $0x80262f
  800fd2:	6a 54                	push   $0x54
  800fd4:	68 c7 25 80 00       	push   $0x8025c7
  800fd9:	e8 b7 0d 00 00       	call   801d95 <_panic>
	if (eid == 0){
		thisenv = &envs[ENVX(sys_getenvid())];
		return eid;
	}
	// copy something to the child page.
	for (uintptr_t i = UTEXT;i <= USTACKTOP;i += PGSIZE){
  800fde:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800fe4:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  800fea:	75 90                	jne    800f7c <fork+0x6b>
		if (uvpd[PDX(i)] & PTE_P && (uvpt[PGNUM(i)] & PTE_P)){
			duppage(eid,PGNUM(i));
		}
	}
	int r = sys_page_alloc(eid,(void*)(UXSTACKTOP-PGSIZE),PTE_U|PTE_P|PTE_W);
  800fec:	83 ec 04             	sub    $0x4,%esp
  800fef:	6a 07                	push   $0x7
  800ff1:	68 00 f0 bf ee       	push   $0xeebff000
  800ff6:	ff 75 e0             	pushl  -0x20(%ebp)
  800ff9:	e8 33 fc ff ff       	call   800c31 <sys_page_alloc>
	if (r < 0) panic("fork fault.\n");
  800ffe:	83 c4 10             	add    $0x10,%esp
  801001:	85 c0                	test   %eax,%eax
  801003:	79 14                	jns    801019 <fork+0x108>
  801005:	83 ec 04             	sub    $0x4,%esp
  801008:	68 22 26 80 00       	push   $0x802622
  80100d:	6a 7d                	push   $0x7d
  80100f:	68 c7 25 80 00       	push   $0x8025c7
  801014:	e8 7c 0d 00 00       	call   801d95 <_panic>

	extern void _pgfault_upcall();
    r = sys_env_set_pgfault_upcall(eid, _pgfault_upcall);
  801019:	83 ec 08             	sub    $0x8,%esp
  80101c:	68 53 1e 80 00       	push   $0x801e53
  801021:	ff 75 e0             	pushl  -0x20(%ebp)
  801024:	e8 53 fd ff ff       	call   800d7c <sys_env_set_pgfault_upcall>
    if (r < 0) panic("fork fault 3\n");
  801029:	83 c4 10             	add    $0x10,%esp
  80102c:	85 c0                	test   %eax,%eax
  80102e:	79 17                	jns    801047 <fork+0x136>
  801030:	83 ec 04             	sub    $0x4,%esp
  801033:	68 42 26 80 00       	push   $0x802642
  801038:	68 81 00 00 00       	push   $0x81
  80103d:	68 c7 25 80 00       	push   $0x8025c7
  801042:	e8 4e 0d 00 00       	call   801d95 <_panic>

	if ((r = sys_env_set_status(eid, ENV_RUNNABLE)) < 0)
  801047:	83 ec 08             	sub    $0x8,%esp
  80104a:	6a 02                	push   $0x2
  80104c:	ff 75 e0             	pushl  -0x20(%ebp)
  80104f:	e8 a4 fc ff ff       	call   800cf8 <sys_env_set_status>
  801054:	83 c4 10             	add    $0x10,%esp
  801057:	85 c0                	test   %eax,%eax
  801059:	79 7d                	jns    8010d8 <fork+0x1c7>
        panic("fork fault 4\n");
  80105b:	83 ec 04             	sub    $0x4,%esp
  80105e:	68 50 26 80 00       	push   $0x802650
  801063:	68 84 00 00 00       	push   $0x84
  801068:	68 c7 25 80 00       	push   $0x8025c7
  80106d:	e8 23 0d 00 00       	call   801d95 <_panic>
		perm |= PTE_COW;
	if((r = sys_page_map(myenvid,(void*)(pn*PGSIZE),envid,(void*)(pn*PGSIZE),perm))<0){
		panic("duppage fault :%e\n",r);
	}
	if(perm & PTE_COW){
		if((r = sys_page_map(myenvid,(void*)(pn*PGSIZE),myenvid,(void*)(pn*PGSIZE),perm))<0)
  801072:	83 ec 0c             	sub    $0xc,%esp
  801075:	68 05 08 00 00       	push   $0x805
  80107a:	56                   	push   %esi
  80107b:	57                   	push   %edi
  80107c:	56                   	push   %esi
  80107d:	57                   	push   %edi
  80107e:	e8 f1 fb ff ff       	call   800c74 <sys_page_map>
  801083:	83 c4 20             	add    $0x20,%esp
  801086:	85 c0                	test   %eax,%eax
  801088:	0f 89 50 ff ff ff    	jns    800fde <fork+0xcd>
  80108e:	e9 39 ff ff ff       	jmp    800fcc <fork+0xbb>
	envid_t myenvid = sys_getenvid();
	pte_t pte = uvpt[pn];
	int perm = PTE_U | PTE_P;
	if(pte & PTE_W || pte & PTE_COW)
		perm |= PTE_COW;
	if((r = sys_page_map(myenvid,(void*)(pn*PGSIZE),envid,(void*)(pn*PGSIZE),perm))<0){
  801093:	c1 e6 0c             	shl    $0xc,%esi
  801096:	83 ec 0c             	sub    $0xc,%esp
  801099:	68 05 08 00 00       	push   $0x805
  80109e:	56                   	push   %esi
  80109f:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010a2:	56                   	push   %esi
  8010a3:	57                   	push   %edi
  8010a4:	e8 cb fb ff ff       	call   800c74 <sys_page_map>
  8010a9:	83 c4 20             	add    $0x20,%esp
  8010ac:	85 c0                	test   %eax,%eax
  8010ae:	79 c2                	jns    801072 <fork+0x161>
  8010b0:	e9 05 ff ff ff       	jmp    800fba <fork+0xa9>
  8010b5:	c1 e6 0c             	shl    $0xc,%esi
  8010b8:	83 ec 0c             	sub    $0xc,%esp
  8010bb:	6a 05                	push   $0x5
  8010bd:	56                   	push   %esi
  8010be:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010c1:	56                   	push   %esi
  8010c2:	57                   	push   %edi
  8010c3:	e8 ac fb ff ff       	call   800c74 <sys_page_map>
  8010c8:	83 c4 20             	add    $0x20,%esp
  8010cb:	85 c0                	test   %eax,%eax
  8010cd:	0f 89 0b ff ff ff    	jns    800fde <fork+0xcd>
  8010d3:	e9 e2 fe ff ff       	jmp    800fba <fork+0xa9>
    if (r < 0) panic("fork fault 3\n");

	if ((r = sys_env_set_status(eid, ENV_RUNNABLE)) < 0)
        panic("fork fault 4\n");
    return eid;
}
  8010d8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8010db:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010de:	5b                   	pop    %ebx
  8010df:	5e                   	pop    %esi
  8010e0:	5f                   	pop    %edi
  8010e1:	5d                   	pop    %ebp
  8010e2:	c3                   	ret    

008010e3 <sfork>:

// Challenge!
int
sfork(void)
{
  8010e3:	55                   	push   %ebp
  8010e4:	89 e5                	mov    %esp,%ebp
  8010e6:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8010e9:	68 5e 26 80 00       	push   $0x80265e
  8010ee:	68 8c 00 00 00       	push   $0x8c
  8010f3:	68 c7 25 80 00       	push   $0x8025c7
  8010f8:	e8 98 0c 00 00       	call   801d95 <_panic>

008010fd <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8010fd:	55                   	push   %ebp
  8010fe:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801100:	8b 45 08             	mov    0x8(%ebp),%eax
  801103:	05 00 00 00 30       	add    $0x30000000,%eax
  801108:	c1 e8 0c             	shr    $0xc,%eax
}
  80110b:	5d                   	pop    %ebp
  80110c:	c3                   	ret    

0080110d <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80110d:	55                   	push   %ebp
  80110e:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801110:	8b 45 08             	mov    0x8(%ebp),%eax
  801113:	05 00 00 00 30       	add    $0x30000000,%eax
  801118:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80111d:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801122:	5d                   	pop    %ebp
  801123:	c3                   	ret    

00801124 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801124:	55                   	push   %ebp
  801125:	89 e5                	mov    %esp,%ebp
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801127:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  80112c:	a8 01                	test   $0x1,%al
  80112e:	74 34                	je     801164 <fd_alloc+0x40>
  801130:	a1 00 00 74 ef       	mov    0xef740000,%eax
  801135:	a8 01                	test   $0x1,%al
  801137:	74 32                	je     80116b <fd_alloc+0x47>
  801139:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  80113e:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801140:	89 c2                	mov    %eax,%edx
  801142:	c1 ea 16             	shr    $0x16,%edx
  801145:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80114c:	f6 c2 01             	test   $0x1,%dl
  80114f:	74 1f                	je     801170 <fd_alloc+0x4c>
  801151:	89 c2                	mov    %eax,%edx
  801153:	c1 ea 0c             	shr    $0xc,%edx
  801156:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80115d:	f6 c2 01             	test   $0x1,%dl
  801160:	75 1a                	jne    80117c <fd_alloc+0x58>
  801162:	eb 0c                	jmp    801170 <fd_alloc+0x4c>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  801164:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  801169:	eb 05                	jmp    801170 <fd_alloc+0x4c>
  80116b:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  801170:	8b 45 08             	mov    0x8(%ebp),%eax
  801173:	89 08                	mov    %ecx,(%eax)
			return 0;
  801175:	b8 00 00 00 00       	mov    $0x0,%eax
  80117a:	eb 1a                	jmp    801196 <fd_alloc+0x72>
  80117c:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801181:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801186:	75 b6                	jne    80113e <fd_alloc+0x1a>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801188:	8b 45 08             	mov    0x8(%ebp),%eax
  80118b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  801191:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801196:	5d                   	pop    %ebp
  801197:	c3                   	ret    

00801198 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801198:	55                   	push   %ebp
  801199:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80119b:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
  80119f:	77 39                	ja     8011da <fd_lookup+0x42>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8011a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8011a4:	c1 e0 0c             	shl    $0xc,%eax
  8011a7:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8011ac:	89 c2                	mov    %eax,%edx
  8011ae:	c1 ea 16             	shr    $0x16,%edx
  8011b1:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011b8:	f6 c2 01             	test   $0x1,%dl
  8011bb:	74 24                	je     8011e1 <fd_lookup+0x49>
  8011bd:	89 c2                	mov    %eax,%edx
  8011bf:	c1 ea 0c             	shr    $0xc,%edx
  8011c2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011c9:	f6 c2 01             	test   $0x1,%dl
  8011cc:	74 1a                	je     8011e8 <fd_lookup+0x50>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8011ce:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011d1:	89 02                	mov    %eax,(%edx)
	return 0;
  8011d3:	b8 00 00 00 00       	mov    $0x0,%eax
  8011d8:	eb 13                	jmp    8011ed <fd_lookup+0x55>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011da:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011df:	eb 0c                	jmp    8011ed <fd_lookup+0x55>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011e1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011e6:	eb 05                	jmp    8011ed <fd_lookup+0x55>
  8011e8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8011ed:	5d                   	pop    %ebp
  8011ee:	c3                   	ret    

008011ef <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8011ef:	55                   	push   %ebp
  8011f0:	89 e5                	mov    %esp,%ebp
  8011f2:	53                   	push   %ebx
  8011f3:	83 ec 04             	sub    $0x4,%esp
  8011f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8011f9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  8011fc:	3b 05 04 30 80 00    	cmp    0x803004,%eax
  801202:	75 1e                	jne    801222 <dev_lookup+0x33>
  801204:	eb 0e                	jmp    801214 <dev_lookup+0x25>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801206:	b8 20 30 80 00       	mov    $0x803020,%eax
  80120b:	eb 0c                	jmp    801219 <dev_lookup+0x2a>
  80120d:	b8 3c 30 80 00       	mov    $0x80303c,%eax
  801212:	eb 05                	jmp    801219 <dev_lookup+0x2a>
  801214:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  801219:	89 03                	mov    %eax,(%ebx)
			return 0;
  80121b:	b8 00 00 00 00       	mov    $0x0,%eax
  801220:	eb 36                	jmp    801258 <dev_lookup+0x69>
int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  801222:	3b 05 20 30 80 00    	cmp    0x803020,%eax
  801228:	74 dc                	je     801206 <dev_lookup+0x17>
  80122a:	3b 05 3c 30 80 00    	cmp    0x80303c,%eax
  801230:	74 db                	je     80120d <dev_lookup+0x1e>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801232:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801238:	8b 52 48             	mov    0x48(%edx),%edx
  80123b:	83 ec 04             	sub    $0x4,%esp
  80123e:	50                   	push   %eax
  80123f:	52                   	push   %edx
  801240:	68 94 26 80 00       	push   $0x802694
  801245:	e8 92 ef ff ff       	call   8001dc <cprintf>
	*dev = 0;
  80124a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  801250:	83 c4 10             	add    $0x10,%esp
  801253:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801258:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80125b:	c9                   	leave  
  80125c:	c3                   	ret    

0080125d <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80125d:	55                   	push   %ebp
  80125e:	89 e5                	mov    %esp,%ebp
  801260:	56                   	push   %esi
  801261:	53                   	push   %ebx
  801262:	83 ec 10             	sub    $0x10,%esp
  801265:	8b 75 08             	mov    0x8(%ebp),%esi
  801268:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80126b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80126e:	50                   	push   %eax
  80126f:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801275:	c1 e8 0c             	shr    $0xc,%eax
  801278:	50                   	push   %eax
  801279:	e8 1a ff ff ff       	call   801198 <fd_lookup>
  80127e:	83 c4 08             	add    $0x8,%esp
  801281:	85 c0                	test   %eax,%eax
  801283:	78 05                	js     80128a <fd_close+0x2d>
	    || fd != fd2)
  801285:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801288:	74 06                	je     801290 <fd_close+0x33>
		return (must_exist ? r : 0);
  80128a:	84 db                	test   %bl,%bl
  80128c:	74 47                	je     8012d5 <fd_close+0x78>
  80128e:	eb 4a                	jmp    8012da <fd_close+0x7d>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801290:	83 ec 08             	sub    $0x8,%esp
  801293:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801296:	50                   	push   %eax
  801297:	ff 36                	pushl  (%esi)
  801299:	e8 51 ff ff ff       	call   8011ef <dev_lookup>
  80129e:	89 c3                	mov    %eax,%ebx
  8012a0:	83 c4 10             	add    $0x10,%esp
  8012a3:	85 c0                	test   %eax,%eax
  8012a5:	78 1c                	js     8012c3 <fd_close+0x66>
		if (dev->dev_close)
  8012a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012aa:	8b 40 10             	mov    0x10(%eax),%eax
  8012ad:	85 c0                	test   %eax,%eax
  8012af:	74 0d                	je     8012be <fd_close+0x61>
			r = (*dev->dev_close)(fd);
  8012b1:	83 ec 0c             	sub    $0xc,%esp
  8012b4:	56                   	push   %esi
  8012b5:	ff d0                	call   *%eax
  8012b7:	89 c3                	mov    %eax,%ebx
  8012b9:	83 c4 10             	add    $0x10,%esp
  8012bc:	eb 05                	jmp    8012c3 <fd_close+0x66>
		else
			r = 0;
  8012be:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8012c3:	83 ec 08             	sub    $0x8,%esp
  8012c6:	56                   	push   %esi
  8012c7:	6a 00                	push   $0x0
  8012c9:	e8 e8 f9 ff ff       	call   800cb6 <sys_page_unmap>
	return r;
  8012ce:	83 c4 10             	add    $0x10,%esp
  8012d1:	89 d8                	mov    %ebx,%eax
  8012d3:	eb 05                	jmp    8012da <fd_close+0x7d>
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
  8012d5:	b8 00 00 00 00       	mov    $0x0,%eax
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
	return r;
}
  8012da:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012dd:	5b                   	pop    %ebx
  8012de:	5e                   	pop    %esi
  8012df:	5d                   	pop    %ebp
  8012e0:	c3                   	ret    

008012e1 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8012e1:	55                   	push   %ebp
  8012e2:	89 e5                	mov    %esp,%ebp
  8012e4:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012e7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012ea:	50                   	push   %eax
  8012eb:	ff 75 08             	pushl  0x8(%ebp)
  8012ee:	e8 a5 fe ff ff       	call   801198 <fd_lookup>
  8012f3:	83 c4 08             	add    $0x8,%esp
  8012f6:	85 c0                	test   %eax,%eax
  8012f8:	78 10                	js     80130a <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8012fa:	83 ec 08             	sub    $0x8,%esp
  8012fd:	6a 01                	push   $0x1
  8012ff:	ff 75 f4             	pushl  -0xc(%ebp)
  801302:	e8 56 ff ff ff       	call   80125d <fd_close>
  801307:	83 c4 10             	add    $0x10,%esp
}
  80130a:	c9                   	leave  
  80130b:	c3                   	ret    

0080130c <close_all>:

void
close_all(void)
{
  80130c:	55                   	push   %ebp
  80130d:	89 e5                	mov    %esp,%ebp
  80130f:	53                   	push   %ebx
  801310:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801313:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801318:	83 ec 0c             	sub    $0xc,%esp
  80131b:	53                   	push   %ebx
  80131c:	e8 c0 ff ff ff       	call   8012e1 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801321:	43                   	inc    %ebx
  801322:	83 c4 10             	add    $0x10,%esp
  801325:	83 fb 20             	cmp    $0x20,%ebx
  801328:	75 ee                	jne    801318 <close_all+0xc>
		close(i);
}
  80132a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80132d:	c9                   	leave  
  80132e:	c3                   	ret    

0080132f <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80132f:	55                   	push   %ebp
  801330:	89 e5                	mov    %esp,%ebp
  801332:	57                   	push   %edi
  801333:	56                   	push   %esi
  801334:	53                   	push   %ebx
  801335:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801338:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80133b:	50                   	push   %eax
  80133c:	ff 75 08             	pushl  0x8(%ebp)
  80133f:	e8 54 fe ff ff       	call   801198 <fd_lookup>
  801344:	83 c4 08             	add    $0x8,%esp
  801347:	85 c0                	test   %eax,%eax
  801349:	0f 88 c2 00 00 00    	js     801411 <dup+0xe2>
		return r;
	close(newfdnum);
  80134f:	83 ec 0c             	sub    $0xc,%esp
  801352:	ff 75 0c             	pushl  0xc(%ebp)
  801355:	e8 87 ff ff ff       	call   8012e1 <close>

	newfd = INDEX2FD(newfdnum);
  80135a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80135d:	c1 e3 0c             	shl    $0xc,%ebx
  801360:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801366:	83 c4 04             	add    $0x4,%esp
  801369:	ff 75 e4             	pushl  -0x1c(%ebp)
  80136c:	e8 9c fd ff ff       	call   80110d <fd2data>
  801371:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  801373:	89 1c 24             	mov    %ebx,(%esp)
  801376:	e8 92 fd ff ff       	call   80110d <fd2data>
  80137b:	83 c4 10             	add    $0x10,%esp
  80137e:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801380:	89 f0                	mov    %esi,%eax
  801382:	c1 e8 16             	shr    $0x16,%eax
  801385:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80138c:	a8 01                	test   $0x1,%al
  80138e:	74 35                	je     8013c5 <dup+0x96>
  801390:	89 f0                	mov    %esi,%eax
  801392:	c1 e8 0c             	shr    $0xc,%eax
  801395:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80139c:	f6 c2 01             	test   $0x1,%dl
  80139f:	74 24                	je     8013c5 <dup+0x96>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8013a1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013a8:	83 ec 0c             	sub    $0xc,%esp
  8013ab:	25 07 0e 00 00       	and    $0xe07,%eax
  8013b0:	50                   	push   %eax
  8013b1:	57                   	push   %edi
  8013b2:	6a 00                	push   $0x0
  8013b4:	56                   	push   %esi
  8013b5:	6a 00                	push   $0x0
  8013b7:	e8 b8 f8 ff ff       	call   800c74 <sys_page_map>
  8013bc:	89 c6                	mov    %eax,%esi
  8013be:	83 c4 20             	add    $0x20,%esp
  8013c1:	85 c0                	test   %eax,%eax
  8013c3:	78 2c                	js     8013f1 <dup+0xc2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013c5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8013c8:	89 d0                	mov    %edx,%eax
  8013ca:	c1 e8 0c             	shr    $0xc,%eax
  8013cd:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013d4:	83 ec 0c             	sub    $0xc,%esp
  8013d7:	25 07 0e 00 00       	and    $0xe07,%eax
  8013dc:	50                   	push   %eax
  8013dd:	53                   	push   %ebx
  8013de:	6a 00                	push   $0x0
  8013e0:	52                   	push   %edx
  8013e1:	6a 00                	push   $0x0
  8013e3:	e8 8c f8 ff ff       	call   800c74 <sys_page_map>
  8013e8:	89 c6                	mov    %eax,%esi
  8013ea:	83 c4 20             	add    $0x20,%esp
  8013ed:	85 c0                	test   %eax,%eax
  8013ef:	79 1d                	jns    80140e <dup+0xdf>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8013f1:	83 ec 08             	sub    $0x8,%esp
  8013f4:	53                   	push   %ebx
  8013f5:	6a 00                	push   $0x0
  8013f7:	e8 ba f8 ff ff       	call   800cb6 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8013fc:	83 c4 08             	add    $0x8,%esp
  8013ff:	57                   	push   %edi
  801400:	6a 00                	push   $0x0
  801402:	e8 af f8 ff ff       	call   800cb6 <sys_page_unmap>
	return r;
  801407:	83 c4 10             	add    $0x10,%esp
  80140a:	89 f0                	mov    %esi,%eax
  80140c:	eb 03                	jmp    801411 <dup+0xe2>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  80140e:	8b 45 0c             	mov    0xc(%ebp),%eax

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801411:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801414:	5b                   	pop    %ebx
  801415:	5e                   	pop    %esi
  801416:	5f                   	pop    %edi
  801417:	5d                   	pop    %ebp
  801418:	c3                   	ret    

00801419 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801419:	55                   	push   %ebp
  80141a:	89 e5                	mov    %esp,%ebp
  80141c:	53                   	push   %ebx
  80141d:	83 ec 14             	sub    $0x14,%esp
  801420:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801423:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801426:	50                   	push   %eax
  801427:	53                   	push   %ebx
  801428:	e8 6b fd ff ff       	call   801198 <fd_lookup>
  80142d:	83 c4 08             	add    $0x8,%esp
  801430:	85 c0                	test   %eax,%eax
  801432:	78 67                	js     80149b <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801434:	83 ec 08             	sub    $0x8,%esp
  801437:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80143a:	50                   	push   %eax
  80143b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80143e:	ff 30                	pushl  (%eax)
  801440:	e8 aa fd ff ff       	call   8011ef <dev_lookup>
  801445:	83 c4 10             	add    $0x10,%esp
  801448:	85 c0                	test   %eax,%eax
  80144a:	78 4f                	js     80149b <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80144c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80144f:	8b 42 08             	mov    0x8(%edx),%eax
  801452:	83 e0 03             	and    $0x3,%eax
  801455:	83 f8 01             	cmp    $0x1,%eax
  801458:	75 21                	jne    80147b <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80145a:	a1 04 40 80 00       	mov    0x804004,%eax
  80145f:	8b 40 48             	mov    0x48(%eax),%eax
  801462:	83 ec 04             	sub    $0x4,%esp
  801465:	53                   	push   %ebx
  801466:	50                   	push   %eax
  801467:	68 d5 26 80 00       	push   $0x8026d5
  80146c:	e8 6b ed ff ff       	call   8001dc <cprintf>
		return -E_INVAL;
  801471:	83 c4 10             	add    $0x10,%esp
  801474:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801479:	eb 20                	jmp    80149b <read+0x82>
	}
	if (!dev->dev_read)
  80147b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80147e:	8b 40 08             	mov    0x8(%eax),%eax
  801481:	85 c0                	test   %eax,%eax
  801483:	74 11                	je     801496 <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801485:	83 ec 04             	sub    $0x4,%esp
  801488:	ff 75 10             	pushl  0x10(%ebp)
  80148b:	ff 75 0c             	pushl  0xc(%ebp)
  80148e:	52                   	push   %edx
  80148f:	ff d0                	call   *%eax
  801491:	83 c4 10             	add    $0x10,%esp
  801494:	eb 05                	jmp    80149b <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801496:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  80149b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80149e:	c9                   	leave  
  80149f:	c3                   	ret    

008014a0 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8014a0:	55                   	push   %ebp
  8014a1:	89 e5                	mov    %esp,%ebp
  8014a3:	57                   	push   %edi
  8014a4:	56                   	push   %esi
  8014a5:	53                   	push   %ebx
  8014a6:	83 ec 0c             	sub    $0xc,%esp
  8014a9:	8b 7d 08             	mov    0x8(%ebp),%edi
  8014ac:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014af:	85 f6                	test   %esi,%esi
  8014b1:	74 31                	je     8014e4 <readn+0x44>
  8014b3:	b8 00 00 00 00       	mov    $0x0,%eax
  8014b8:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  8014bd:	83 ec 04             	sub    $0x4,%esp
  8014c0:	89 f2                	mov    %esi,%edx
  8014c2:	29 c2                	sub    %eax,%edx
  8014c4:	52                   	push   %edx
  8014c5:	03 45 0c             	add    0xc(%ebp),%eax
  8014c8:	50                   	push   %eax
  8014c9:	57                   	push   %edi
  8014ca:	e8 4a ff ff ff       	call   801419 <read>
		if (m < 0)
  8014cf:	83 c4 10             	add    $0x10,%esp
  8014d2:	85 c0                	test   %eax,%eax
  8014d4:	78 17                	js     8014ed <readn+0x4d>
			return m;
		if (m == 0)
  8014d6:	85 c0                	test   %eax,%eax
  8014d8:	74 11                	je     8014eb <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014da:	01 c3                	add    %eax,%ebx
  8014dc:	89 d8                	mov    %ebx,%eax
  8014de:	39 f3                	cmp    %esi,%ebx
  8014e0:	72 db                	jb     8014bd <readn+0x1d>
  8014e2:	eb 09                	jmp    8014ed <readn+0x4d>
  8014e4:	b8 00 00 00 00       	mov    $0x0,%eax
  8014e9:	eb 02                	jmp    8014ed <readn+0x4d>
  8014eb:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8014ed:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014f0:	5b                   	pop    %ebx
  8014f1:	5e                   	pop    %esi
  8014f2:	5f                   	pop    %edi
  8014f3:	5d                   	pop    %ebp
  8014f4:	c3                   	ret    

008014f5 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8014f5:	55                   	push   %ebp
  8014f6:	89 e5                	mov    %esp,%ebp
  8014f8:	53                   	push   %ebx
  8014f9:	83 ec 14             	sub    $0x14,%esp
  8014fc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014ff:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801502:	50                   	push   %eax
  801503:	53                   	push   %ebx
  801504:	e8 8f fc ff ff       	call   801198 <fd_lookup>
  801509:	83 c4 08             	add    $0x8,%esp
  80150c:	85 c0                	test   %eax,%eax
  80150e:	78 62                	js     801572 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801510:	83 ec 08             	sub    $0x8,%esp
  801513:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801516:	50                   	push   %eax
  801517:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80151a:	ff 30                	pushl  (%eax)
  80151c:	e8 ce fc ff ff       	call   8011ef <dev_lookup>
  801521:	83 c4 10             	add    $0x10,%esp
  801524:	85 c0                	test   %eax,%eax
  801526:	78 4a                	js     801572 <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801528:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80152b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80152f:	75 21                	jne    801552 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801531:	a1 04 40 80 00       	mov    0x804004,%eax
  801536:	8b 40 48             	mov    0x48(%eax),%eax
  801539:	83 ec 04             	sub    $0x4,%esp
  80153c:	53                   	push   %ebx
  80153d:	50                   	push   %eax
  80153e:	68 f1 26 80 00       	push   $0x8026f1
  801543:	e8 94 ec ff ff       	call   8001dc <cprintf>
		return -E_INVAL;
  801548:	83 c4 10             	add    $0x10,%esp
  80154b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801550:	eb 20                	jmp    801572 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801552:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801555:	8b 52 0c             	mov    0xc(%edx),%edx
  801558:	85 d2                	test   %edx,%edx
  80155a:	74 11                	je     80156d <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80155c:	83 ec 04             	sub    $0x4,%esp
  80155f:	ff 75 10             	pushl  0x10(%ebp)
  801562:	ff 75 0c             	pushl  0xc(%ebp)
  801565:	50                   	push   %eax
  801566:	ff d2                	call   *%edx
  801568:	83 c4 10             	add    $0x10,%esp
  80156b:	eb 05                	jmp    801572 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80156d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801572:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801575:	c9                   	leave  
  801576:	c3                   	ret    

00801577 <seek>:

int
seek(int fdnum, off_t offset)
{
  801577:	55                   	push   %ebp
  801578:	89 e5                	mov    %esp,%ebp
  80157a:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80157d:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801580:	50                   	push   %eax
  801581:	ff 75 08             	pushl  0x8(%ebp)
  801584:	e8 0f fc ff ff       	call   801198 <fd_lookup>
  801589:	83 c4 08             	add    $0x8,%esp
  80158c:	85 c0                	test   %eax,%eax
  80158e:	78 0e                	js     80159e <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801590:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801593:	8b 55 0c             	mov    0xc(%ebp),%edx
  801596:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801599:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80159e:	c9                   	leave  
  80159f:	c3                   	ret    

008015a0 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8015a0:	55                   	push   %ebp
  8015a1:	89 e5                	mov    %esp,%ebp
  8015a3:	53                   	push   %ebx
  8015a4:	83 ec 14             	sub    $0x14,%esp
  8015a7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015aa:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015ad:	50                   	push   %eax
  8015ae:	53                   	push   %ebx
  8015af:	e8 e4 fb ff ff       	call   801198 <fd_lookup>
  8015b4:	83 c4 08             	add    $0x8,%esp
  8015b7:	85 c0                	test   %eax,%eax
  8015b9:	78 5f                	js     80161a <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015bb:	83 ec 08             	sub    $0x8,%esp
  8015be:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015c1:	50                   	push   %eax
  8015c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015c5:	ff 30                	pushl  (%eax)
  8015c7:	e8 23 fc ff ff       	call   8011ef <dev_lookup>
  8015cc:	83 c4 10             	add    $0x10,%esp
  8015cf:	85 c0                	test   %eax,%eax
  8015d1:	78 47                	js     80161a <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015d6:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015da:	75 21                	jne    8015fd <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8015dc:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8015e1:	8b 40 48             	mov    0x48(%eax),%eax
  8015e4:	83 ec 04             	sub    $0x4,%esp
  8015e7:	53                   	push   %ebx
  8015e8:	50                   	push   %eax
  8015e9:	68 b4 26 80 00       	push   $0x8026b4
  8015ee:	e8 e9 eb ff ff       	call   8001dc <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8015f3:	83 c4 10             	add    $0x10,%esp
  8015f6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015fb:	eb 1d                	jmp    80161a <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  8015fd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801600:	8b 52 18             	mov    0x18(%edx),%edx
  801603:	85 d2                	test   %edx,%edx
  801605:	74 0e                	je     801615 <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801607:	83 ec 08             	sub    $0x8,%esp
  80160a:	ff 75 0c             	pushl  0xc(%ebp)
  80160d:	50                   	push   %eax
  80160e:	ff d2                	call   *%edx
  801610:	83 c4 10             	add    $0x10,%esp
  801613:	eb 05                	jmp    80161a <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801615:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  80161a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80161d:	c9                   	leave  
  80161e:	c3                   	ret    

0080161f <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80161f:	55                   	push   %ebp
  801620:	89 e5                	mov    %esp,%ebp
  801622:	53                   	push   %ebx
  801623:	83 ec 14             	sub    $0x14,%esp
  801626:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801629:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80162c:	50                   	push   %eax
  80162d:	ff 75 08             	pushl  0x8(%ebp)
  801630:	e8 63 fb ff ff       	call   801198 <fd_lookup>
  801635:	83 c4 08             	add    $0x8,%esp
  801638:	85 c0                	test   %eax,%eax
  80163a:	78 52                	js     80168e <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80163c:	83 ec 08             	sub    $0x8,%esp
  80163f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801642:	50                   	push   %eax
  801643:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801646:	ff 30                	pushl  (%eax)
  801648:	e8 a2 fb ff ff       	call   8011ef <dev_lookup>
  80164d:	83 c4 10             	add    $0x10,%esp
  801650:	85 c0                	test   %eax,%eax
  801652:	78 3a                	js     80168e <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  801654:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801657:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80165b:	74 2c                	je     801689 <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80165d:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801660:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801667:	00 00 00 
	stat->st_isdir = 0;
  80166a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801671:	00 00 00 
	stat->st_dev = dev;
  801674:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80167a:	83 ec 08             	sub    $0x8,%esp
  80167d:	53                   	push   %ebx
  80167e:	ff 75 f0             	pushl  -0x10(%ebp)
  801681:	ff 50 14             	call   *0x14(%eax)
  801684:	83 c4 10             	add    $0x10,%esp
  801687:	eb 05                	jmp    80168e <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801689:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80168e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801691:	c9                   	leave  
  801692:	c3                   	ret    

00801693 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801693:	55                   	push   %ebp
  801694:	89 e5                	mov    %esp,%ebp
  801696:	56                   	push   %esi
  801697:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801698:	83 ec 08             	sub    $0x8,%esp
  80169b:	6a 00                	push   $0x0
  80169d:	ff 75 08             	pushl  0x8(%ebp)
  8016a0:	e8 75 01 00 00       	call   80181a <open>
  8016a5:	89 c3                	mov    %eax,%ebx
  8016a7:	83 c4 10             	add    $0x10,%esp
  8016aa:	85 c0                	test   %eax,%eax
  8016ac:	78 1d                	js     8016cb <stat+0x38>
		return fd;
	r = fstat(fd, stat);
  8016ae:	83 ec 08             	sub    $0x8,%esp
  8016b1:	ff 75 0c             	pushl  0xc(%ebp)
  8016b4:	50                   	push   %eax
  8016b5:	e8 65 ff ff ff       	call   80161f <fstat>
  8016ba:	89 c6                	mov    %eax,%esi
	close(fd);
  8016bc:	89 1c 24             	mov    %ebx,(%esp)
  8016bf:	e8 1d fc ff ff       	call   8012e1 <close>
	return r;
  8016c4:	83 c4 10             	add    $0x10,%esp
  8016c7:	89 f0                	mov    %esi,%eax
  8016c9:	eb 00                	jmp    8016cb <stat+0x38>
}
  8016cb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016ce:	5b                   	pop    %ebx
  8016cf:	5e                   	pop    %esi
  8016d0:	5d                   	pop    %ebp
  8016d1:	c3                   	ret    

008016d2 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8016d2:	55                   	push   %ebp
  8016d3:	89 e5                	mov    %esp,%ebp
  8016d5:	56                   	push   %esi
  8016d6:	53                   	push   %ebx
  8016d7:	89 c6                	mov    %eax,%esi
  8016d9:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8016db:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8016e2:	75 12                	jne    8016f6 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8016e4:	83 ec 0c             	sub    $0xc,%esp
  8016e7:	6a 01                	push   $0x1
  8016e9:	e8 5f 08 00 00       	call   801f4d <ipc_find_env>
  8016ee:	a3 00 40 80 00       	mov    %eax,0x804000
  8016f3:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8016f6:	6a 07                	push   $0x7
  8016f8:	68 00 50 80 00       	push   $0x805000
  8016fd:	56                   	push   %esi
  8016fe:	ff 35 00 40 80 00    	pushl  0x804000
  801704:	e8 e5 07 00 00       	call   801eee <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801709:	83 c4 0c             	add    $0xc,%esp
  80170c:	6a 00                	push   $0x0
  80170e:	53                   	push   %ebx
  80170f:	6a 00                	push   $0x0
  801711:	e8 63 07 00 00       	call   801e79 <ipc_recv>
}
  801716:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801719:	5b                   	pop    %ebx
  80171a:	5e                   	pop    %esi
  80171b:	5d                   	pop    %ebp
  80171c:	c3                   	ret    

0080171d <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80171d:	55                   	push   %ebp
  80171e:	89 e5                	mov    %esp,%ebp
  801720:	53                   	push   %ebx
  801721:	83 ec 04             	sub    $0x4,%esp
  801724:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801727:	8b 45 08             	mov    0x8(%ebp),%eax
  80172a:	8b 40 0c             	mov    0xc(%eax),%eax
  80172d:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801732:	ba 00 00 00 00       	mov    $0x0,%edx
  801737:	b8 05 00 00 00       	mov    $0x5,%eax
  80173c:	e8 91 ff ff ff       	call   8016d2 <fsipc>
  801741:	85 c0                	test   %eax,%eax
  801743:	78 2c                	js     801771 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801745:	83 ec 08             	sub    $0x8,%esp
  801748:	68 00 50 80 00       	push   $0x805000
  80174d:	53                   	push   %ebx
  80174e:	e8 6e f0 ff ff       	call   8007c1 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801753:	a1 80 50 80 00       	mov    0x805080,%eax
  801758:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80175e:	a1 84 50 80 00       	mov    0x805084,%eax
  801763:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801769:	83 c4 10             	add    $0x10,%esp
  80176c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801771:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801774:	c9                   	leave  
  801775:	c3                   	ret    

00801776 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801776:	55                   	push   %ebp
  801777:	89 e5                	mov    %esp,%ebp
  801779:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80177c:	8b 45 08             	mov    0x8(%ebp),%eax
  80177f:	8b 40 0c             	mov    0xc(%eax),%eax
  801782:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801787:	ba 00 00 00 00       	mov    $0x0,%edx
  80178c:	b8 06 00 00 00       	mov    $0x6,%eax
  801791:	e8 3c ff ff ff       	call   8016d2 <fsipc>
}
  801796:	c9                   	leave  
  801797:	c3                   	ret    

00801798 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801798:	55                   	push   %ebp
  801799:	89 e5                	mov    %esp,%ebp
  80179b:	56                   	push   %esi
  80179c:	53                   	push   %ebx
  80179d:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8017a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8017a3:	8b 40 0c             	mov    0xc(%eax),%eax
  8017a6:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8017ab:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8017b1:	ba 00 00 00 00       	mov    $0x0,%edx
  8017b6:	b8 03 00 00 00       	mov    $0x3,%eax
  8017bb:	e8 12 ff ff ff       	call   8016d2 <fsipc>
  8017c0:	89 c3                	mov    %eax,%ebx
  8017c2:	85 c0                	test   %eax,%eax
  8017c4:	78 4b                	js     801811 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8017c6:	39 c6                	cmp    %eax,%esi
  8017c8:	73 16                	jae    8017e0 <devfile_read+0x48>
  8017ca:	68 0e 27 80 00       	push   $0x80270e
  8017cf:	68 15 27 80 00       	push   $0x802715
  8017d4:	6a 7a                	push   $0x7a
  8017d6:	68 2a 27 80 00       	push   $0x80272a
  8017db:	e8 b5 05 00 00       	call   801d95 <_panic>
	assert(r <= PGSIZE);
  8017e0:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8017e5:	7e 16                	jle    8017fd <devfile_read+0x65>
  8017e7:	68 35 27 80 00       	push   $0x802735
  8017ec:	68 15 27 80 00       	push   $0x802715
  8017f1:	6a 7b                	push   $0x7b
  8017f3:	68 2a 27 80 00       	push   $0x80272a
  8017f8:	e8 98 05 00 00       	call   801d95 <_panic>
	memmove(buf, &fsipcbuf, r);
  8017fd:	83 ec 04             	sub    $0x4,%esp
  801800:	50                   	push   %eax
  801801:	68 00 50 80 00       	push   $0x805000
  801806:	ff 75 0c             	pushl  0xc(%ebp)
  801809:	e8 80 f1 ff ff       	call   80098e <memmove>
	return r;
  80180e:	83 c4 10             	add    $0x10,%esp
}
  801811:	89 d8                	mov    %ebx,%eax
  801813:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801816:	5b                   	pop    %ebx
  801817:	5e                   	pop    %esi
  801818:	5d                   	pop    %ebp
  801819:	c3                   	ret    

0080181a <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80181a:	55                   	push   %ebp
  80181b:	89 e5                	mov    %esp,%ebp
  80181d:	53                   	push   %ebx
  80181e:	83 ec 20             	sub    $0x20,%esp
  801821:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801824:	53                   	push   %ebx
  801825:	e8 40 ef ff ff       	call   80076a <strlen>
  80182a:	83 c4 10             	add    $0x10,%esp
  80182d:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801832:	7f 63                	jg     801897 <open+0x7d>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801834:	83 ec 0c             	sub    $0xc,%esp
  801837:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80183a:	50                   	push   %eax
  80183b:	e8 e4 f8 ff ff       	call   801124 <fd_alloc>
  801840:	83 c4 10             	add    $0x10,%esp
  801843:	85 c0                	test   %eax,%eax
  801845:	78 55                	js     80189c <open+0x82>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801847:	83 ec 08             	sub    $0x8,%esp
  80184a:	53                   	push   %ebx
  80184b:	68 00 50 80 00       	push   $0x805000
  801850:	e8 6c ef ff ff       	call   8007c1 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801855:	8b 45 0c             	mov    0xc(%ebp),%eax
  801858:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80185d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801860:	b8 01 00 00 00       	mov    $0x1,%eax
  801865:	e8 68 fe ff ff       	call   8016d2 <fsipc>
  80186a:	89 c3                	mov    %eax,%ebx
  80186c:	83 c4 10             	add    $0x10,%esp
  80186f:	85 c0                	test   %eax,%eax
  801871:	79 14                	jns    801887 <open+0x6d>
		fd_close(fd, 0);
  801873:	83 ec 08             	sub    $0x8,%esp
  801876:	6a 00                	push   $0x0
  801878:	ff 75 f4             	pushl  -0xc(%ebp)
  80187b:	e8 dd f9 ff ff       	call   80125d <fd_close>
		return r;
  801880:	83 c4 10             	add    $0x10,%esp
  801883:	89 d8                	mov    %ebx,%eax
  801885:	eb 15                	jmp    80189c <open+0x82>
	}

	return fd2num(fd);
  801887:	83 ec 0c             	sub    $0xc,%esp
  80188a:	ff 75 f4             	pushl  -0xc(%ebp)
  80188d:	e8 6b f8 ff ff       	call   8010fd <fd2num>
  801892:	83 c4 10             	add    $0x10,%esp
  801895:	eb 05                	jmp    80189c <open+0x82>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801897:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80189c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80189f:	c9                   	leave  
  8018a0:	c3                   	ret    

008018a1 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8018a1:	55                   	push   %ebp
  8018a2:	89 e5                	mov    %esp,%ebp
  8018a4:	56                   	push   %esi
  8018a5:	53                   	push   %ebx
  8018a6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8018a9:	83 ec 0c             	sub    $0xc,%esp
  8018ac:	ff 75 08             	pushl  0x8(%ebp)
  8018af:	e8 59 f8 ff ff       	call   80110d <fd2data>
  8018b4:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8018b6:	83 c4 08             	add    $0x8,%esp
  8018b9:	68 41 27 80 00       	push   $0x802741
  8018be:	53                   	push   %ebx
  8018bf:	e8 fd ee ff ff       	call   8007c1 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8018c4:	8b 46 04             	mov    0x4(%esi),%eax
  8018c7:	2b 06                	sub    (%esi),%eax
  8018c9:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8018cf:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8018d6:	00 00 00 
	stat->st_dev = &devpipe;
  8018d9:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8018e0:	30 80 00 
	return 0;
}
  8018e3:	b8 00 00 00 00       	mov    $0x0,%eax
  8018e8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018eb:	5b                   	pop    %ebx
  8018ec:	5e                   	pop    %esi
  8018ed:	5d                   	pop    %ebp
  8018ee:	c3                   	ret    

008018ef <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8018ef:	55                   	push   %ebp
  8018f0:	89 e5                	mov    %esp,%ebp
  8018f2:	53                   	push   %ebx
  8018f3:	83 ec 0c             	sub    $0xc,%esp
  8018f6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8018f9:	53                   	push   %ebx
  8018fa:	6a 00                	push   $0x0
  8018fc:	e8 b5 f3 ff ff       	call   800cb6 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801901:	89 1c 24             	mov    %ebx,(%esp)
  801904:	e8 04 f8 ff ff       	call   80110d <fd2data>
  801909:	83 c4 08             	add    $0x8,%esp
  80190c:	50                   	push   %eax
  80190d:	6a 00                	push   $0x0
  80190f:	e8 a2 f3 ff ff       	call   800cb6 <sys_page_unmap>
}
  801914:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801917:	c9                   	leave  
  801918:	c3                   	ret    

00801919 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801919:	55                   	push   %ebp
  80191a:	89 e5                	mov    %esp,%ebp
  80191c:	57                   	push   %edi
  80191d:	56                   	push   %esi
  80191e:	53                   	push   %ebx
  80191f:	83 ec 1c             	sub    $0x1c,%esp
  801922:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801925:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801927:	a1 04 40 80 00       	mov    0x804004,%eax
  80192c:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  80192f:	83 ec 0c             	sub    $0xc,%esp
  801932:	ff 75 e0             	pushl  -0x20(%ebp)
  801935:	e8 6e 06 00 00       	call   801fa8 <pageref>
  80193a:	89 c3                	mov    %eax,%ebx
  80193c:	89 3c 24             	mov    %edi,(%esp)
  80193f:	e8 64 06 00 00       	call   801fa8 <pageref>
  801944:	83 c4 10             	add    $0x10,%esp
  801947:	39 c3                	cmp    %eax,%ebx
  801949:	0f 94 c1             	sete   %cl
  80194c:	0f b6 c9             	movzbl %cl,%ecx
  80194f:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801952:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801958:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  80195b:	39 ce                	cmp    %ecx,%esi
  80195d:	74 1b                	je     80197a <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  80195f:	39 c3                	cmp    %eax,%ebx
  801961:	75 c4                	jne    801927 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801963:	8b 42 58             	mov    0x58(%edx),%eax
  801966:	ff 75 e4             	pushl  -0x1c(%ebp)
  801969:	50                   	push   %eax
  80196a:	56                   	push   %esi
  80196b:	68 48 27 80 00       	push   $0x802748
  801970:	e8 67 e8 ff ff       	call   8001dc <cprintf>
  801975:	83 c4 10             	add    $0x10,%esp
  801978:	eb ad                	jmp    801927 <_pipeisclosed+0xe>
	}
}
  80197a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80197d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801980:	5b                   	pop    %ebx
  801981:	5e                   	pop    %esi
  801982:	5f                   	pop    %edi
  801983:	5d                   	pop    %ebp
  801984:	c3                   	ret    

00801985 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801985:	55                   	push   %ebp
  801986:	89 e5                	mov    %esp,%ebp
  801988:	57                   	push   %edi
  801989:	56                   	push   %esi
  80198a:	53                   	push   %ebx
  80198b:	83 ec 18             	sub    $0x18,%esp
  80198e:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801991:	56                   	push   %esi
  801992:	e8 76 f7 ff ff       	call   80110d <fd2data>
  801997:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801999:	83 c4 10             	add    $0x10,%esp
  80199c:	bf 00 00 00 00       	mov    $0x0,%edi
  8019a1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8019a5:	75 42                	jne    8019e9 <devpipe_write+0x64>
  8019a7:	eb 4e                	jmp    8019f7 <devpipe_write+0x72>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8019a9:	89 da                	mov    %ebx,%edx
  8019ab:	89 f0                	mov    %esi,%eax
  8019ad:	e8 67 ff ff ff       	call   801919 <_pipeisclosed>
  8019b2:	85 c0                	test   %eax,%eax
  8019b4:	75 46                	jne    8019fc <devpipe_write+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8019b6:	e8 57 f2 ff ff       	call   800c12 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8019bb:	8b 53 04             	mov    0x4(%ebx),%edx
  8019be:	8b 03                	mov    (%ebx),%eax
  8019c0:	83 c0 20             	add    $0x20,%eax
  8019c3:	39 c2                	cmp    %eax,%edx
  8019c5:	73 e2                	jae    8019a9 <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8019c7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019ca:	8a 0c 38             	mov    (%eax,%edi,1),%cl
  8019cd:	89 d0                	mov    %edx,%eax
  8019cf:	25 1f 00 00 80       	and    $0x8000001f,%eax
  8019d4:	79 05                	jns    8019db <devpipe_write+0x56>
  8019d6:	48                   	dec    %eax
  8019d7:	83 c8 e0             	or     $0xffffffe0,%eax
  8019da:	40                   	inc    %eax
  8019db:	88 4c 03 08          	mov    %cl,0x8(%ebx,%eax,1)
		p->p_wpos++;
  8019df:	42                   	inc    %edx
  8019e0:	89 53 04             	mov    %edx,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019e3:	47                   	inc    %edi
  8019e4:	39 7d 10             	cmp    %edi,0x10(%ebp)
  8019e7:	74 0e                	je     8019f7 <devpipe_write+0x72>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8019e9:	8b 53 04             	mov    0x4(%ebx),%edx
  8019ec:	8b 03                	mov    (%ebx),%eax
  8019ee:	83 c0 20             	add    $0x20,%eax
  8019f1:	39 c2                	cmp    %eax,%edx
  8019f3:	73 b4                	jae    8019a9 <devpipe_write+0x24>
  8019f5:	eb d0                	jmp    8019c7 <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8019f7:	8b 45 10             	mov    0x10(%ebp),%eax
  8019fa:	eb 05                	jmp    801a01 <devpipe_write+0x7c>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8019fc:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801a01:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a04:	5b                   	pop    %ebx
  801a05:	5e                   	pop    %esi
  801a06:	5f                   	pop    %edi
  801a07:	5d                   	pop    %ebp
  801a08:	c3                   	ret    

00801a09 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801a09:	55                   	push   %ebp
  801a0a:	89 e5                	mov    %esp,%ebp
  801a0c:	57                   	push   %edi
  801a0d:	56                   	push   %esi
  801a0e:	53                   	push   %ebx
  801a0f:	83 ec 18             	sub    $0x18,%esp
  801a12:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801a15:	57                   	push   %edi
  801a16:	e8 f2 f6 ff ff       	call   80110d <fd2data>
  801a1b:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a1d:	83 c4 10             	add    $0x10,%esp
  801a20:	be 00 00 00 00       	mov    $0x0,%esi
  801a25:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801a29:	75 3d                	jne    801a68 <devpipe_read+0x5f>
  801a2b:	eb 48                	jmp    801a75 <devpipe_read+0x6c>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  801a2d:	89 f0                	mov    %esi,%eax
  801a2f:	eb 4e                	jmp    801a7f <devpipe_read+0x76>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801a31:	89 da                	mov    %ebx,%edx
  801a33:	89 f8                	mov    %edi,%eax
  801a35:	e8 df fe ff ff       	call   801919 <_pipeisclosed>
  801a3a:	85 c0                	test   %eax,%eax
  801a3c:	75 3c                	jne    801a7a <devpipe_read+0x71>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801a3e:	e8 cf f1 ff ff       	call   800c12 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801a43:	8b 03                	mov    (%ebx),%eax
  801a45:	3b 43 04             	cmp    0x4(%ebx),%eax
  801a48:	74 e7                	je     801a31 <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801a4a:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801a4f:	79 05                	jns    801a56 <devpipe_read+0x4d>
  801a51:	48                   	dec    %eax
  801a52:	83 c8 e0             	or     $0xffffffe0,%eax
  801a55:	40                   	inc    %eax
  801a56:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801a5a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a5d:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801a60:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a62:	46                   	inc    %esi
  801a63:	39 75 10             	cmp    %esi,0x10(%ebp)
  801a66:	74 0d                	je     801a75 <devpipe_read+0x6c>
		while (p->p_rpos == p->p_wpos) {
  801a68:	8b 03                	mov    (%ebx),%eax
  801a6a:	3b 43 04             	cmp    0x4(%ebx),%eax
  801a6d:	75 db                	jne    801a4a <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801a6f:	85 f6                	test   %esi,%esi
  801a71:	75 ba                	jne    801a2d <devpipe_read+0x24>
  801a73:	eb bc                	jmp    801a31 <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801a75:	8b 45 10             	mov    0x10(%ebp),%eax
  801a78:	eb 05                	jmp    801a7f <devpipe_read+0x76>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801a7a:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801a7f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a82:	5b                   	pop    %ebx
  801a83:	5e                   	pop    %esi
  801a84:	5f                   	pop    %edi
  801a85:	5d                   	pop    %ebp
  801a86:	c3                   	ret    

00801a87 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801a87:	55                   	push   %ebp
  801a88:	89 e5                	mov    %esp,%ebp
  801a8a:	56                   	push   %esi
  801a8b:	53                   	push   %ebx
  801a8c:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801a8f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a92:	50                   	push   %eax
  801a93:	e8 8c f6 ff ff       	call   801124 <fd_alloc>
  801a98:	83 c4 10             	add    $0x10,%esp
  801a9b:	85 c0                	test   %eax,%eax
  801a9d:	0f 88 2a 01 00 00    	js     801bcd <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801aa3:	83 ec 04             	sub    $0x4,%esp
  801aa6:	68 07 04 00 00       	push   $0x407
  801aab:	ff 75 f4             	pushl  -0xc(%ebp)
  801aae:	6a 00                	push   $0x0
  801ab0:	e8 7c f1 ff ff       	call   800c31 <sys_page_alloc>
  801ab5:	83 c4 10             	add    $0x10,%esp
  801ab8:	85 c0                	test   %eax,%eax
  801aba:	0f 88 0d 01 00 00    	js     801bcd <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801ac0:	83 ec 0c             	sub    $0xc,%esp
  801ac3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801ac6:	50                   	push   %eax
  801ac7:	e8 58 f6 ff ff       	call   801124 <fd_alloc>
  801acc:	89 c3                	mov    %eax,%ebx
  801ace:	83 c4 10             	add    $0x10,%esp
  801ad1:	85 c0                	test   %eax,%eax
  801ad3:	0f 88 e2 00 00 00    	js     801bbb <pipe+0x134>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ad9:	83 ec 04             	sub    $0x4,%esp
  801adc:	68 07 04 00 00       	push   $0x407
  801ae1:	ff 75 f0             	pushl  -0x10(%ebp)
  801ae4:	6a 00                	push   $0x0
  801ae6:	e8 46 f1 ff ff       	call   800c31 <sys_page_alloc>
  801aeb:	89 c3                	mov    %eax,%ebx
  801aed:	83 c4 10             	add    $0x10,%esp
  801af0:	85 c0                	test   %eax,%eax
  801af2:	0f 88 c3 00 00 00    	js     801bbb <pipe+0x134>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801af8:	83 ec 0c             	sub    $0xc,%esp
  801afb:	ff 75 f4             	pushl  -0xc(%ebp)
  801afe:	e8 0a f6 ff ff       	call   80110d <fd2data>
  801b03:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b05:	83 c4 0c             	add    $0xc,%esp
  801b08:	68 07 04 00 00       	push   $0x407
  801b0d:	50                   	push   %eax
  801b0e:	6a 00                	push   $0x0
  801b10:	e8 1c f1 ff ff       	call   800c31 <sys_page_alloc>
  801b15:	89 c3                	mov    %eax,%ebx
  801b17:	83 c4 10             	add    $0x10,%esp
  801b1a:	85 c0                	test   %eax,%eax
  801b1c:	0f 88 89 00 00 00    	js     801bab <pipe+0x124>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b22:	83 ec 0c             	sub    $0xc,%esp
  801b25:	ff 75 f0             	pushl  -0x10(%ebp)
  801b28:	e8 e0 f5 ff ff       	call   80110d <fd2data>
  801b2d:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801b34:	50                   	push   %eax
  801b35:	6a 00                	push   $0x0
  801b37:	56                   	push   %esi
  801b38:	6a 00                	push   $0x0
  801b3a:	e8 35 f1 ff ff       	call   800c74 <sys_page_map>
  801b3f:	89 c3                	mov    %eax,%ebx
  801b41:	83 c4 20             	add    $0x20,%esp
  801b44:	85 c0                	test   %eax,%eax
  801b46:	78 55                	js     801b9d <pipe+0x116>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801b48:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b51:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801b53:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b56:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801b5d:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b63:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b66:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801b68:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b6b:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801b72:	83 ec 0c             	sub    $0xc,%esp
  801b75:	ff 75 f4             	pushl  -0xc(%ebp)
  801b78:	e8 80 f5 ff ff       	call   8010fd <fd2num>
  801b7d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b80:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801b82:	83 c4 04             	add    $0x4,%esp
  801b85:	ff 75 f0             	pushl  -0x10(%ebp)
  801b88:	e8 70 f5 ff ff       	call   8010fd <fd2num>
  801b8d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b90:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801b93:	83 c4 10             	add    $0x10,%esp
  801b96:	b8 00 00 00 00       	mov    $0x0,%eax
  801b9b:	eb 30                	jmp    801bcd <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  801b9d:	83 ec 08             	sub    $0x8,%esp
  801ba0:	56                   	push   %esi
  801ba1:	6a 00                	push   $0x0
  801ba3:	e8 0e f1 ff ff       	call   800cb6 <sys_page_unmap>
  801ba8:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801bab:	83 ec 08             	sub    $0x8,%esp
  801bae:	ff 75 f0             	pushl  -0x10(%ebp)
  801bb1:	6a 00                	push   $0x0
  801bb3:	e8 fe f0 ff ff       	call   800cb6 <sys_page_unmap>
  801bb8:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801bbb:	83 ec 08             	sub    $0x8,%esp
  801bbe:	ff 75 f4             	pushl  -0xc(%ebp)
  801bc1:	6a 00                	push   $0x0
  801bc3:	e8 ee f0 ff ff       	call   800cb6 <sys_page_unmap>
  801bc8:	83 c4 10             	add    $0x10,%esp
  801bcb:	89 d8                	mov    %ebx,%eax
    err:
	return r;
}
  801bcd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bd0:	5b                   	pop    %ebx
  801bd1:	5e                   	pop    %esi
  801bd2:	5d                   	pop    %ebp
  801bd3:	c3                   	ret    

00801bd4 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801bd4:	55                   	push   %ebp
  801bd5:	89 e5                	mov    %esp,%ebp
  801bd7:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801bda:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bdd:	50                   	push   %eax
  801bde:	ff 75 08             	pushl  0x8(%ebp)
  801be1:	e8 b2 f5 ff ff       	call   801198 <fd_lookup>
  801be6:	83 c4 10             	add    $0x10,%esp
  801be9:	85 c0                	test   %eax,%eax
  801beb:	78 18                	js     801c05 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801bed:	83 ec 0c             	sub    $0xc,%esp
  801bf0:	ff 75 f4             	pushl  -0xc(%ebp)
  801bf3:	e8 15 f5 ff ff       	call   80110d <fd2data>
	return _pipeisclosed(fd, p);
  801bf8:	89 c2                	mov    %eax,%edx
  801bfa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bfd:	e8 17 fd ff ff       	call   801919 <_pipeisclosed>
  801c02:	83 c4 10             	add    $0x10,%esp
}
  801c05:	c9                   	leave  
  801c06:	c3                   	ret    

00801c07 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801c07:	55                   	push   %ebp
  801c08:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801c0a:	b8 00 00 00 00       	mov    $0x0,%eax
  801c0f:	5d                   	pop    %ebp
  801c10:	c3                   	ret    

00801c11 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801c11:	55                   	push   %ebp
  801c12:	89 e5                	mov    %esp,%ebp
  801c14:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801c17:	68 60 27 80 00       	push   $0x802760
  801c1c:	ff 75 0c             	pushl  0xc(%ebp)
  801c1f:	e8 9d eb ff ff       	call   8007c1 <strcpy>
	return 0;
}
  801c24:	b8 00 00 00 00       	mov    $0x0,%eax
  801c29:	c9                   	leave  
  801c2a:	c3                   	ret    

00801c2b <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801c2b:	55                   	push   %ebp
  801c2c:	89 e5                	mov    %esp,%ebp
  801c2e:	57                   	push   %edi
  801c2f:	56                   	push   %esi
  801c30:	53                   	push   %ebx
  801c31:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c37:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801c3b:	74 45                	je     801c82 <devcons_write+0x57>
  801c3d:	b8 00 00 00 00       	mov    $0x0,%eax
  801c42:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801c47:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801c4d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801c50:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  801c52:	83 fb 7f             	cmp    $0x7f,%ebx
  801c55:	76 05                	jbe    801c5c <devcons_write+0x31>
			m = sizeof(buf) - 1;
  801c57:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801c5c:	83 ec 04             	sub    $0x4,%esp
  801c5f:	53                   	push   %ebx
  801c60:	03 45 0c             	add    0xc(%ebp),%eax
  801c63:	50                   	push   %eax
  801c64:	57                   	push   %edi
  801c65:	e8 24 ed ff ff       	call   80098e <memmove>
		sys_cputs(buf, m);
  801c6a:	83 c4 08             	add    $0x8,%esp
  801c6d:	53                   	push   %ebx
  801c6e:	57                   	push   %edi
  801c6f:	e8 01 ef ff ff       	call   800b75 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c74:	01 de                	add    %ebx,%esi
  801c76:	89 f0                	mov    %esi,%eax
  801c78:	83 c4 10             	add    $0x10,%esp
  801c7b:	3b 75 10             	cmp    0x10(%ebp),%esi
  801c7e:	72 cd                	jb     801c4d <devcons_write+0x22>
  801c80:	eb 05                	jmp    801c87 <devcons_write+0x5c>
  801c82:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801c87:	89 f0                	mov    %esi,%eax
  801c89:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c8c:	5b                   	pop    %ebx
  801c8d:	5e                   	pop    %esi
  801c8e:	5f                   	pop    %edi
  801c8f:	5d                   	pop    %ebp
  801c90:	c3                   	ret    

00801c91 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c91:	55                   	push   %ebp
  801c92:	89 e5                	mov    %esp,%ebp
  801c94:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801c97:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801c9b:	75 07                	jne    801ca4 <devcons_read+0x13>
  801c9d:	eb 23                	jmp    801cc2 <devcons_read+0x31>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801c9f:	e8 6e ef ff ff       	call   800c12 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801ca4:	e8 ea ee ff ff       	call   800b93 <sys_cgetc>
  801ca9:	85 c0                	test   %eax,%eax
  801cab:	74 f2                	je     801c9f <devcons_read+0xe>
		sys_yield();
	if (c < 0)
  801cad:	85 c0                	test   %eax,%eax
  801caf:	78 1d                	js     801cce <devcons_read+0x3d>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801cb1:	83 f8 04             	cmp    $0x4,%eax
  801cb4:	74 13                	je     801cc9 <devcons_read+0x38>
		return 0;
	*(char*)vbuf = c;
  801cb6:	8b 55 0c             	mov    0xc(%ebp),%edx
  801cb9:	88 02                	mov    %al,(%edx)
	return 1;
  801cbb:	b8 01 00 00 00       	mov    $0x1,%eax
  801cc0:	eb 0c                	jmp    801cce <devcons_read+0x3d>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801cc2:	b8 00 00 00 00       	mov    $0x0,%eax
  801cc7:	eb 05                	jmp    801cce <devcons_read+0x3d>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801cc9:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801cce:	c9                   	leave  
  801ccf:	c3                   	ret    

00801cd0 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801cd0:	55                   	push   %ebp
  801cd1:	89 e5                	mov    %esp,%ebp
  801cd3:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801cd6:	8b 45 08             	mov    0x8(%ebp),%eax
  801cd9:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801cdc:	6a 01                	push   $0x1
  801cde:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ce1:	50                   	push   %eax
  801ce2:	e8 8e ee ff ff       	call   800b75 <sys_cputs>
}
  801ce7:	83 c4 10             	add    $0x10,%esp
  801cea:	c9                   	leave  
  801ceb:	c3                   	ret    

00801cec <getchar>:

int
getchar(void)
{
  801cec:	55                   	push   %ebp
  801ced:	89 e5                	mov    %esp,%ebp
  801cef:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801cf2:	6a 01                	push   $0x1
  801cf4:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801cf7:	50                   	push   %eax
  801cf8:	6a 00                	push   $0x0
  801cfa:	e8 1a f7 ff ff       	call   801419 <read>
	if (r < 0)
  801cff:	83 c4 10             	add    $0x10,%esp
  801d02:	85 c0                	test   %eax,%eax
  801d04:	78 0f                	js     801d15 <getchar+0x29>
		return r;
	if (r < 1)
  801d06:	85 c0                	test   %eax,%eax
  801d08:	7e 06                	jle    801d10 <getchar+0x24>
		return -E_EOF;
	return c;
  801d0a:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801d0e:	eb 05                	jmp    801d15 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801d10:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801d15:	c9                   	leave  
  801d16:	c3                   	ret    

00801d17 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801d17:	55                   	push   %ebp
  801d18:	89 e5                	mov    %esp,%ebp
  801d1a:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d1d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d20:	50                   	push   %eax
  801d21:	ff 75 08             	pushl  0x8(%ebp)
  801d24:	e8 6f f4 ff ff       	call   801198 <fd_lookup>
  801d29:	83 c4 10             	add    $0x10,%esp
  801d2c:	85 c0                	test   %eax,%eax
  801d2e:	78 11                	js     801d41 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801d30:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d33:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d39:	39 10                	cmp    %edx,(%eax)
  801d3b:	0f 94 c0             	sete   %al
  801d3e:	0f b6 c0             	movzbl %al,%eax
}
  801d41:	c9                   	leave  
  801d42:	c3                   	ret    

00801d43 <opencons>:

int
opencons(void)
{
  801d43:	55                   	push   %ebp
  801d44:	89 e5                	mov    %esp,%ebp
  801d46:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801d49:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d4c:	50                   	push   %eax
  801d4d:	e8 d2 f3 ff ff       	call   801124 <fd_alloc>
  801d52:	83 c4 10             	add    $0x10,%esp
  801d55:	85 c0                	test   %eax,%eax
  801d57:	78 3a                	js     801d93 <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801d59:	83 ec 04             	sub    $0x4,%esp
  801d5c:	68 07 04 00 00       	push   $0x407
  801d61:	ff 75 f4             	pushl  -0xc(%ebp)
  801d64:	6a 00                	push   $0x0
  801d66:	e8 c6 ee ff ff       	call   800c31 <sys_page_alloc>
  801d6b:	83 c4 10             	add    $0x10,%esp
  801d6e:	85 c0                	test   %eax,%eax
  801d70:	78 21                	js     801d93 <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801d72:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d78:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d7b:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801d7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d80:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801d87:	83 ec 0c             	sub    $0xc,%esp
  801d8a:	50                   	push   %eax
  801d8b:	e8 6d f3 ff ff       	call   8010fd <fd2num>
  801d90:	83 c4 10             	add    $0x10,%esp
}
  801d93:	c9                   	leave  
  801d94:	c3                   	ret    

00801d95 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801d95:	55                   	push   %ebp
  801d96:	89 e5                	mov    %esp,%ebp
  801d98:	56                   	push   %esi
  801d99:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801d9a:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801d9d:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801da3:	e8 4b ee ff ff       	call   800bf3 <sys_getenvid>
  801da8:	83 ec 0c             	sub    $0xc,%esp
  801dab:	ff 75 0c             	pushl  0xc(%ebp)
  801dae:	ff 75 08             	pushl  0x8(%ebp)
  801db1:	56                   	push   %esi
  801db2:	50                   	push   %eax
  801db3:	68 6c 27 80 00       	push   $0x80276c
  801db8:	e8 1f e4 ff ff       	call   8001dc <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801dbd:	83 c4 18             	add    $0x18,%esp
  801dc0:	53                   	push   %ebx
  801dc1:	ff 75 10             	pushl  0x10(%ebp)
  801dc4:	e8 c2 e3 ff ff       	call   80018b <vcprintf>
	cprintf("\n");
  801dc9:	c7 04 24 eb 25 80 00 	movl   $0x8025eb,(%esp)
  801dd0:	e8 07 e4 ff ff       	call   8001dc <cprintf>
  801dd5:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801dd8:	cc                   	int3   
  801dd9:	eb fd                	jmp    801dd8 <_panic+0x43>

00801ddb <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801ddb:	55                   	push   %ebp
  801ddc:	89 e5                	mov    %esp,%ebp
  801dde:	53                   	push   %ebx
  801ddf:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (_pgfault_handler == 0) {
  801de2:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801de9:	75 5b                	jne    801e46 <set_pgfault_handler+0x6b>
		// First time through!
		// LAB 4: Your code here.
		void *va = (void *)(UXSTACKTOP - PGSIZE);
		envid_t eid = sys_getenvid();
  801deb:	e8 03 ee ff ff       	call   800bf3 <sys_getenvid>
  801df0:	89 c3                	mov    %eax,%ebx
		r = sys_page_alloc(eid,va,PTE_P | PTE_U | PTE_W);
  801df2:	83 ec 04             	sub    $0x4,%esp
  801df5:	6a 07                	push   $0x7
  801df7:	68 00 f0 bf ee       	push   $0xeebff000
  801dfc:	50                   	push   %eax
  801dfd:	e8 2f ee ff ff       	call   800c31 <sys_page_alloc>
		if(r<0) panic("set_pgfault_handler\n");
  801e02:	83 c4 10             	add    $0x10,%esp
  801e05:	85 c0                	test   %eax,%eax
  801e07:	79 14                	jns    801e1d <set_pgfault_handler+0x42>
  801e09:	83 ec 04             	sub    $0x4,%esp
  801e0c:	68 90 27 80 00       	push   $0x802790
  801e11:	6a 23                	push   $0x23
  801e13:	68 a5 27 80 00       	push   $0x8027a5
  801e18:	e8 78 ff ff ff       	call   801d95 <_panic>
		r = sys_env_set_pgfault_upcall(eid,_pgfault_upcall);
  801e1d:	83 ec 08             	sub    $0x8,%esp
  801e20:	68 53 1e 80 00       	push   $0x801e53
  801e25:	53                   	push   %ebx
  801e26:	e8 51 ef ff ff       	call   800d7c <sys_env_set_pgfault_upcall>
		if(r<0) panic("set_pgfault_handler\n");
  801e2b:	83 c4 10             	add    $0x10,%esp
  801e2e:	85 c0                	test   %eax,%eax
  801e30:	79 14                	jns    801e46 <set_pgfault_handler+0x6b>
  801e32:	83 ec 04             	sub    $0x4,%esp
  801e35:	68 90 27 80 00       	push   $0x802790
  801e3a:	6a 25                	push   $0x25
  801e3c:	68 a5 27 80 00       	push   $0x8027a5
  801e41:	e8 4f ff ff ff       	call   801d95 <_panic>
		// panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801e46:	8b 45 08             	mov    0x8(%ebp),%eax
  801e49:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801e4e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e51:	c9                   	leave  
  801e52:	c3                   	ret    

00801e53 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801e53:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801e54:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801e59:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801e5b:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl %esp,%ebx
  801e5e:	89 e3                	mov    %esp,%ebx
	movl 40(%esp),%eax 	// esp from utf_fault_va to utf_regs(end)
  801e60:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl 48(%esp),%esp 	// 
  801e64:	8b 64 24 30          	mov    0x30(%esp),%esp
	pushl %eax
  801e68:	50                   	push   %eax
 
 
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	movl %ebx,%esp
  801e69:	89 dc                	mov    %ebx,%esp
	subl $4,48(%esp)
  801e6b:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	popl %eax
  801e70:	58                   	pop    %eax
	popl %eax
  801e71:	58                   	pop    %eax
	popal
  801e72:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	add $4,%esp
  801e73:	83 c4 04             	add    $0x4,%esp
	popfl
  801e76:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  801e77:	5c                   	pop    %esp
 
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801e78:	c3                   	ret    

00801e79 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e79:	55                   	push   %ebp
  801e7a:	89 e5                	mov    %esp,%ebp
  801e7c:	56                   	push   %esi
  801e7d:	53                   	push   %ebx
  801e7e:	8b 75 08             	mov    0x8(%ebp),%esi
  801e81:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e84:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");
	int r;
    if (pg != NULL) {
  801e87:	85 c0                	test   %eax,%eax
  801e89:	74 0e                	je     801e99 <ipc_recv+0x20>
        r = sys_ipc_recv(pg);
  801e8b:	83 ec 0c             	sub    $0xc,%esp
  801e8e:	50                   	push   %eax
  801e8f:	e8 4d ef ff ff       	call   800de1 <sys_ipc_recv>
  801e94:	83 c4 10             	add    $0x10,%esp
  801e97:	eb 10                	jmp    801ea9 <ipc_recv+0x30>
    } else {
        r = sys_ipc_recv((void *) UTOP);
  801e99:	83 ec 0c             	sub    $0xc,%esp
  801e9c:	68 00 00 c0 ee       	push   $0xeec00000
  801ea1:	e8 3b ef ff ff       	call   800de1 <sys_ipc_recv>
  801ea6:	83 c4 10             	add    $0x10,%esp
    }
    if (r < 0) {
  801ea9:	85 c0                	test   %eax,%eax
  801eab:	79 16                	jns    801ec3 <ipc_recv+0x4a>
        // failed
        if (from_env_store != NULL) *from_env_store = 0;
  801ead:	85 f6                	test   %esi,%esi
  801eaf:	74 06                	je     801eb7 <ipc_recv+0x3e>
  801eb1:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        if (perm_store != NULL) *perm_store = 0;
  801eb7:	85 db                	test   %ebx,%ebx
  801eb9:	74 2c                	je     801ee7 <ipc_recv+0x6e>
  801ebb:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801ec1:	eb 24                	jmp    801ee7 <ipc_recv+0x6e>
        return r;
    } else {
        if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801ec3:	85 f6                	test   %esi,%esi
  801ec5:	74 0a                	je     801ed1 <ipc_recv+0x58>
  801ec7:	a1 04 40 80 00       	mov    0x804004,%eax
  801ecc:	8b 40 74             	mov    0x74(%eax),%eax
  801ecf:	89 06                	mov    %eax,(%esi)
        if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801ed1:	85 db                	test   %ebx,%ebx
  801ed3:	74 0a                	je     801edf <ipc_recv+0x66>
  801ed5:	a1 04 40 80 00       	mov    0x804004,%eax
  801eda:	8b 40 78             	mov    0x78(%eax),%eax
  801edd:	89 03                	mov    %eax,(%ebx)
        return thisenv->env_ipc_value;
  801edf:	a1 04 40 80 00       	mov    0x804004,%eax
  801ee4:	8b 40 70             	mov    0x70(%eax),%eax
    }
 
	return 0;
}
  801ee7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801eea:	5b                   	pop    %ebx
  801eeb:	5e                   	pop    %esi
  801eec:	5d                   	pop    %ebp
  801eed:	c3                   	ret    

00801eee <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801eee:	55                   	push   %ebp
  801eef:	89 e5                	mov    %esp,%ebp
  801ef1:	57                   	push   %edi
  801ef2:	56                   	push   %esi
  801ef3:	53                   	push   %ebx
  801ef4:	83 ec 0c             	sub    $0xc,%esp
  801ef7:	8b 75 10             	mov    0x10(%ebp),%esi
  801efa:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");
	int r;
    if (pg == NULL) pg = (void *)UTOP;
  801efd:	85 f6                	test   %esi,%esi
  801eff:	75 05                	jne    801f06 <ipc_send+0x18>
  801f01:	be 00 00 c0 ee       	mov    $0xeec00000,%esi
    do {
        r = sys_ipc_try_send(to_env, val, pg, perm);
  801f06:	57                   	push   %edi
  801f07:	56                   	push   %esi
  801f08:	ff 75 0c             	pushl  0xc(%ebp)
  801f0b:	ff 75 08             	pushl  0x8(%ebp)
  801f0e:	e8 ab ee ff ff       	call   800dbe <sys_ipc_try_send>
  801f13:	89 c3                	mov    %eax,%ebx
        if (r < 0 && r != -E_IPC_NOT_RECV) panic("ipc send failed: %e", r);
  801f15:	83 c4 10             	add    $0x10,%esp
  801f18:	85 c0                	test   %eax,%eax
  801f1a:	79 17                	jns    801f33 <ipc_send+0x45>
  801f1c:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f1f:	74 1d                	je     801f3e <ipc_send+0x50>
  801f21:	50                   	push   %eax
  801f22:	68 b3 27 80 00       	push   $0x8027b3
  801f27:	6a 40                	push   $0x40
  801f29:	68 c7 27 80 00       	push   $0x8027c7
  801f2e:	e8 62 fe ff ff       	call   801d95 <_panic>
        sys_yield();
  801f33:	e8 da ec ff ff       	call   800c12 <sys_yield>
    } while (r != 0);
  801f38:	85 db                	test   %ebx,%ebx
  801f3a:	75 ca                	jne    801f06 <ipc_send+0x18>
  801f3c:	eb 07                	jmp    801f45 <ipc_send+0x57>
	int r;
    if (pg == NULL) pg = (void *)UTOP;
    do {
        r = sys_ipc_try_send(to_env, val, pg, perm);
        if (r < 0 && r != -E_IPC_NOT_RECV) panic("ipc send failed: %e", r);
        sys_yield();
  801f3e:	e8 cf ec ff ff       	call   800c12 <sys_yield>
  801f43:	eb c1                	jmp    801f06 <ipc_send+0x18>
    } while (r != 0);
}
  801f45:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f48:	5b                   	pop    %ebx
  801f49:	5e                   	pop    %esi
  801f4a:	5f                   	pop    %edi
  801f4b:	5d                   	pop    %ebp
  801f4c:	c3                   	ret    

00801f4d <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f4d:	55                   	push   %ebp
  801f4e:	89 e5                	mov    %esp,%ebp
  801f50:	53                   	push   %ebx
  801f51:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801f54:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  801f59:	39 c1                	cmp    %eax,%ecx
  801f5b:	74 21                	je     801f7e <ipc_find_env+0x31>
  801f5d:	ba 01 00 00 00       	mov    $0x1,%edx
  801f62:	8d 1c 95 00 00 00 00 	lea    0x0(,%edx,4),%ebx
  801f69:	89 d0                	mov    %edx,%eax
  801f6b:	c1 e0 07             	shl    $0x7,%eax
  801f6e:	29 d8                	sub    %ebx,%eax
  801f70:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801f75:	8b 40 50             	mov    0x50(%eax),%eax
  801f78:	39 c8                	cmp    %ecx,%eax
  801f7a:	75 1b                	jne    801f97 <ipc_find_env+0x4a>
  801f7c:	eb 05                	jmp    801f83 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f7e:	ba 00 00 00 00       	mov    $0x0,%edx
		if (envs[i].env_type == type)
			return envs[i].env_id;
  801f83:	8d 04 95 00 00 00 00 	lea    0x0(,%edx,4),%eax
  801f8a:	c1 e2 07             	shl    $0x7,%edx
  801f8d:	29 c2                	sub    %eax,%edx
  801f8f:	8b 82 48 00 c0 ee    	mov    -0x113fffb8(%edx),%eax
  801f95:	eb 0e                	jmp    801fa5 <ipc_find_env+0x58>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f97:	42                   	inc    %edx
  801f98:	81 fa 00 04 00 00    	cmp    $0x400,%edx
  801f9e:	75 c2                	jne    801f62 <ipc_find_env+0x15>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801fa0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801fa5:	5b                   	pop    %ebx
  801fa6:	5d                   	pop    %ebp
  801fa7:	c3                   	ret    

00801fa8 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801fa8:	55                   	push   %ebp
  801fa9:	89 e5                	mov    %esp,%ebp
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fab:	8b 45 08             	mov    0x8(%ebp),%eax
  801fae:	c1 e8 16             	shr    $0x16,%eax
  801fb1:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801fb8:	a8 01                	test   $0x1,%al
  801fba:	74 21                	je     801fdd <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801fbc:	8b 45 08             	mov    0x8(%ebp),%eax
  801fbf:	c1 e8 0c             	shr    $0xc,%eax
  801fc2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801fc9:	a8 01                	test   $0x1,%al
  801fcb:	74 17                	je     801fe4 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801fcd:	c1 e8 0c             	shr    $0xc,%eax
  801fd0:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801fd7:	ef 
  801fd8:	0f b7 c0             	movzwl %ax,%eax
  801fdb:	eb 0c                	jmp    801fe9 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801fdd:	b8 00 00 00 00       	mov    $0x0,%eax
  801fe2:	eb 05                	jmp    801fe9 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801fe4:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801fe9:	5d                   	pop    %ebp
  801fea:	c3                   	ret    
  801feb:	90                   	nop

00801fec <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801fec:	55                   	push   %ebp
  801fed:	57                   	push   %edi
  801fee:	56                   	push   %esi
  801fef:	53                   	push   %ebx
  801ff0:	83 ec 1c             	sub    $0x1c,%esp
  801ff3:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801ff7:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801ffb:	8b 7c 24 38          	mov    0x38(%esp),%edi
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801fff:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802003:	89 ca                	mov    %ecx,%edx
  const DWunion dd = {.ll = d};
  802005:	89 f8                	mov    %edi,%eax
  802007:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  80200b:	85 f6                	test   %esi,%esi
  80200d:	75 2d                	jne    80203c <__udivdi3+0x50>
    {
      if (d0 > n1)
  80200f:	39 cf                	cmp    %ecx,%edi
  802011:	77 65                	ja     802078 <__udivdi3+0x8c>
  802013:	89 fd                	mov    %edi,%ebp
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802015:	85 ff                	test   %edi,%edi
  802017:	75 0b                	jne    802024 <__udivdi3+0x38>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802019:	b8 01 00 00 00       	mov    $0x1,%eax
  80201e:	31 d2                	xor    %edx,%edx
  802020:	f7 f7                	div    %edi
  802022:	89 c5                	mov    %eax,%ebp

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802024:	31 d2                	xor    %edx,%edx
  802026:	89 c8                	mov    %ecx,%eax
  802028:	f7 f5                	div    %ebp
  80202a:	89 c1                	mov    %eax,%ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80202c:	89 d8                	mov    %ebx,%eax
  80202e:	f7 f5                	div    %ebp
  802030:	89 cf                	mov    %ecx,%edi
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802032:	89 fa                	mov    %edi,%edx
  802034:	83 c4 1c             	add    $0x1c,%esp
  802037:	5b                   	pop    %ebx
  802038:	5e                   	pop    %esi
  802039:	5f                   	pop    %edi
  80203a:	5d                   	pop    %ebp
  80203b:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  80203c:	39 ce                	cmp    %ecx,%esi
  80203e:	77 28                	ja     802068 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802040:	0f bd fe             	bsr    %esi,%edi
	  if (bm == 0)
  802043:	83 f7 1f             	xor    $0x1f,%edi
  802046:	75 40                	jne    802088 <__udivdi3+0x9c>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802048:	39 ce                	cmp    %ecx,%esi
  80204a:	72 0a                	jb     802056 <__udivdi3+0x6a>
  80204c:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802050:	0f 87 9e 00 00 00    	ja     8020f4 <__udivdi3+0x108>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802056:	b8 01 00 00 00       	mov    $0x1,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80205b:	89 fa                	mov    %edi,%edx
  80205d:	83 c4 1c             	add    $0x1c,%esp
  802060:	5b                   	pop    %ebx
  802061:	5e                   	pop    %esi
  802062:	5f                   	pop    %edi
  802063:	5d                   	pop    %ebp
  802064:	c3                   	ret    
  802065:	8d 76 00             	lea    0x0(%esi),%esi
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802068:	31 ff                	xor    %edi,%edi
  80206a:	31 c0                	xor    %eax,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80206c:	89 fa                	mov    %edi,%edx
  80206e:	83 c4 1c             	add    $0x1c,%esp
  802071:	5b                   	pop    %ebx
  802072:	5e                   	pop    %esi
  802073:	5f                   	pop    %edi
  802074:	5d                   	pop    %ebp
  802075:	c3                   	ret    
  802076:	66 90                	xchg   %ax,%ax
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802078:	89 d8                	mov    %ebx,%eax
  80207a:	f7 f7                	div    %edi
  80207c:	31 ff                	xor    %edi,%edi
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80207e:	89 fa                	mov    %edi,%edx
  802080:	83 c4 1c             	add    $0x1c,%esp
  802083:	5b                   	pop    %ebx
  802084:	5e                   	pop    %esi
  802085:	5f                   	pop    %edi
  802086:	5d                   	pop    %ebp
  802087:	c3                   	ret    
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802088:	bd 20 00 00 00       	mov    $0x20,%ebp
  80208d:	89 eb                	mov    %ebp,%ebx
  80208f:	29 fb                	sub    %edi,%ebx

	      d1 = (d1 << bm) | (d0 >> b);
  802091:	89 f9                	mov    %edi,%ecx
  802093:	d3 e6                	shl    %cl,%esi
  802095:	89 c5                	mov    %eax,%ebp
  802097:	88 d9                	mov    %bl,%cl
  802099:	d3 ed                	shr    %cl,%ebp
  80209b:	89 e9                	mov    %ebp,%ecx
  80209d:	09 f1                	or     %esi,%ecx
  80209f:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
	      d0 = d0 << bm;
  8020a3:	89 f9                	mov    %edi,%ecx
  8020a5:	d3 e0                	shl    %cl,%eax
  8020a7:	89 c5                	mov    %eax,%ebp
	      n2 = n1 >> b;
  8020a9:	89 d6                	mov    %edx,%esi
  8020ab:	88 d9                	mov    %bl,%cl
  8020ad:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
  8020af:	89 f9                	mov    %edi,%ecx
  8020b1:	d3 e2                	shl    %cl,%edx
  8020b3:	8b 44 24 08          	mov    0x8(%esp),%eax
  8020b7:	88 d9                	mov    %bl,%cl
  8020b9:	d3 e8                	shr    %cl,%eax
  8020bb:	09 c2                	or     %eax,%edx
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8020bd:	89 d0                	mov    %edx,%eax
  8020bf:	89 f2                	mov    %esi,%edx
  8020c1:	f7 74 24 0c          	divl   0xc(%esp)
  8020c5:	89 d6                	mov    %edx,%esi
  8020c7:	89 c3                	mov    %eax,%ebx
	      umul_ppmm (m1, m0, q0, d0);
  8020c9:	f7 e5                	mul    %ebp

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8020cb:	39 d6                	cmp    %edx,%esi
  8020cd:	72 19                	jb     8020e8 <__udivdi3+0xfc>
  8020cf:	74 0b                	je     8020dc <__udivdi3+0xf0>
  8020d1:	89 d8                	mov    %ebx,%eax
  8020d3:	31 ff                	xor    %edi,%edi
  8020d5:	e9 58 ff ff ff       	jmp    802032 <__udivdi3+0x46>
  8020da:	66 90                	xchg   %ax,%ax
  8020dc:	8b 54 24 08          	mov    0x8(%esp),%edx
  8020e0:	89 f9                	mov    %edi,%ecx
  8020e2:	d3 e2                	shl    %cl,%edx
  8020e4:	39 c2                	cmp    %eax,%edx
  8020e6:	73 e9                	jae    8020d1 <__udivdi3+0xe5>
  8020e8:	8d 43 ff             	lea    -0x1(%ebx),%eax
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8020eb:	31 ff                	xor    %edi,%edi
  8020ed:	e9 40 ff ff ff       	jmp    802032 <__udivdi3+0x46>
  8020f2:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8020f4:	31 c0                	xor    %eax,%eax
  8020f6:	e9 37 ff ff ff       	jmp    802032 <__udivdi3+0x46>
  8020fb:	90                   	nop

008020fc <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  8020fc:	55                   	push   %ebp
  8020fd:	57                   	push   %edi
  8020fe:	56                   	push   %esi
  8020ff:	53                   	push   %ebx
  802100:	83 ec 1c             	sub    $0x1c,%esp
  802103:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  802107:	8b 74 24 34          	mov    0x34(%esp),%esi
  80210b:	8b 7c 24 38          	mov    0x38(%esp),%edi
  80210f:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  802113:	89 44 24 0c          	mov    %eax,0xc(%esp)
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  802117:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80211b:	89 f3                	mov    %esi,%ebx
  const DWunion dd = {.ll = d};
  80211d:	89 fa                	mov    %edi,%edx
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  80211f:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  n1 = nn.s.high;
  802123:	89 34 24             	mov    %esi,(%esp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802126:	85 c0                	test   %eax,%eax
  802128:	75 1a                	jne    802144 <__umoddi3+0x48>
    {
      if (d0 > n1)
  80212a:	39 f7                	cmp    %esi,%edi
  80212c:	0f 86 a2 00 00 00    	jbe    8021d4 <__umoddi3+0xd8>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802132:	89 c8                	mov    %ecx,%eax
  802134:	89 f2                	mov    %esi,%edx
  802136:	f7 f7                	div    %edi
  802138:	89 d0                	mov    %edx,%eax

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  80213a:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80213c:	83 c4 1c             	add    $0x1c,%esp
  80213f:	5b                   	pop    %ebx
  802140:	5e                   	pop    %esi
  802141:	5f                   	pop    %edi
  802142:	5d                   	pop    %ebp
  802143:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802144:	39 f0                	cmp    %esi,%eax
  802146:	0f 87 ac 00 00 00    	ja     8021f8 <__umoddi3+0xfc>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  80214c:	0f bd e8             	bsr    %eax,%ebp
	  if (bm == 0)
  80214f:	83 f5 1f             	xor    $0x1f,%ebp
  802152:	0f 84 ac 00 00 00    	je     802204 <__umoddi3+0x108>
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802158:	bf 20 00 00 00       	mov    $0x20,%edi
  80215d:	29 ef                	sub    %ebp,%edi
  80215f:	89 fe                	mov    %edi,%esi
  802161:	89 7c 24 0c          	mov    %edi,0xc(%esp)

	      d1 = (d1 << bm) | (d0 >> b);
  802165:	89 e9                	mov    %ebp,%ecx
  802167:	d3 e0                	shl    %cl,%eax
  802169:	89 d7                	mov    %edx,%edi
  80216b:	89 f1                	mov    %esi,%ecx
  80216d:	d3 ef                	shr    %cl,%edi
  80216f:	09 c7                	or     %eax,%edi
	      d0 = d0 << bm;
  802171:	89 e9                	mov    %ebp,%ecx
  802173:	d3 e2                	shl    %cl,%edx
  802175:	89 14 24             	mov    %edx,(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802178:	89 d8                	mov    %ebx,%eax
  80217a:	d3 e0                	shl    %cl,%eax
  80217c:	89 c2                	mov    %eax,%edx
	      n0 = n0 << bm;
  80217e:	8b 44 24 08          	mov    0x8(%esp),%eax
  802182:	d3 e0                	shl    %cl,%eax
  802184:	89 44 24 04          	mov    %eax,0x4(%esp)

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802188:	8b 44 24 08          	mov    0x8(%esp),%eax
  80218c:	89 f1                	mov    %esi,%ecx
  80218e:	d3 e8                	shr    %cl,%eax
  802190:	09 d0                	or     %edx,%eax
  802192:	d3 eb                	shr    %cl,%ebx
  802194:	89 da                	mov    %ebx,%edx
  802196:	f7 f7                	div    %edi
  802198:	89 d3                	mov    %edx,%ebx
	      umul_ppmm (m1, m0, q0, d0);
  80219a:	f7 24 24             	mull   (%esp)
  80219d:	89 c6                	mov    %eax,%esi
  80219f:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8021a1:	39 d3                	cmp    %edx,%ebx
  8021a3:	0f 82 87 00 00 00    	jb     802230 <__umoddi3+0x134>
  8021a9:	0f 84 91 00 00 00    	je     802240 <__umoddi3+0x144>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  8021af:	8b 54 24 04          	mov    0x4(%esp),%edx
  8021b3:	29 f2                	sub    %esi,%edx
  8021b5:	19 cb                	sbb    %ecx,%ebx
		  rr.s.low = (n1 << b) | (n0 >> bm);
  8021b7:	89 d8                	mov    %ebx,%eax
  8021b9:	8a 4c 24 0c          	mov    0xc(%esp),%cl
  8021bd:	d3 e0                	shl    %cl,%eax
  8021bf:	89 e9                	mov    %ebp,%ecx
  8021c1:	d3 ea                	shr    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  8021c3:	09 d0                	or     %edx,%eax
  8021c5:	89 e9                	mov    %ebp,%ecx
  8021c7:	d3 eb                	shr    %cl,%ebx
  8021c9:	89 da                	mov    %ebx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8021cb:	83 c4 1c             	add    $0x1c,%esp
  8021ce:	5b                   	pop    %ebx
  8021cf:	5e                   	pop    %esi
  8021d0:	5f                   	pop    %edi
  8021d1:	5d                   	pop    %ebp
  8021d2:	c3                   	ret    
  8021d3:	90                   	nop
  8021d4:	89 fd                	mov    %edi,%ebp
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8021d6:	85 ff                	test   %edi,%edi
  8021d8:	75 0b                	jne    8021e5 <__umoddi3+0xe9>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8021da:	b8 01 00 00 00       	mov    $0x1,%eax
  8021df:	31 d2                	xor    %edx,%edx
  8021e1:	f7 f7                	div    %edi
  8021e3:	89 c5                	mov    %eax,%ebp

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8021e5:	89 f0                	mov    %esi,%eax
  8021e7:	31 d2                	xor    %edx,%edx
  8021e9:	f7 f5                	div    %ebp
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8021eb:	89 c8                	mov    %ecx,%eax
  8021ed:	f7 f5                	div    %ebp
  8021ef:	89 d0                	mov    %edx,%eax
  8021f1:	e9 44 ff ff ff       	jmp    80213a <__umoddi3+0x3e>
  8021f6:	66 90                	xchg   %ax,%ax
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  8021f8:	89 c8                	mov    %ecx,%eax
  8021fa:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8021fc:	83 c4 1c             	add    $0x1c,%esp
  8021ff:	5b                   	pop    %ebx
  802200:	5e                   	pop    %esi
  802201:	5f                   	pop    %edi
  802202:	5d                   	pop    %ebp
  802203:	c3                   	ret    

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802204:	3b 04 24             	cmp    (%esp),%eax
  802207:	72 06                	jb     80220f <__umoddi3+0x113>
  802209:	3b 7c 24 04          	cmp    0x4(%esp),%edi
  80220d:	77 0f                	ja     80221e <__umoddi3+0x122>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  80220f:	89 f2                	mov    %esi,%edx
  802211:	29 f9                	sub    %edi,%ecx
  802213:	1b 54 24 0c          	sbb    0xc(%esp),%edx
  802217:	89 14 24             	mov    %edx,(%esp)
  80221a:	89 4c 24 04          	mov    %ecx,0x4(%esp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  80221e:	8b 44 24 04          	mov    0x4(%esp),%eax
  802222:	8b 14 24             	mov    (%esp),%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802225:	83 c4 1c             	add    $0x1c,%esp
  802228:	5b                   	pop    %ebx
  802229:	5e                   	pop    %esi
  80222a:	5f                   	pop    %edi
  80222b:	5d                   	pop    %ebp
  80222c:	c3                   	ret    
  80222d:	8d 76 00             	lea    0x0(%esi),%esi
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802230:	2b 04 24             	sub    (%esp),%eax
  802233:	19 fa                	sbb    %edi,%edx
  802235:	89 d1                	mov    %edx,%ecx
  802237:	89 c6                	mov    %eax,%esi
  802239:	e9 71 ff ff ff       	jmp    8021af <__umoddi3+0xb3>
  80223e:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802240:	39 44 24 04          	cmp    %eax,0x4(%esp)
  802244:	72 ea                	jb     802230 <__umoddi3+0x134>
  802246:	89 d9                	mov    %ebx,%ecx
  802248:	e9 62 ff ff ff       	jmp    8021af <__umoddi3+0xb3>
