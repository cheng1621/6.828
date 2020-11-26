
obj/user/lsfd.debug:     file format elf32-i386


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

00800033 <usage>:
#include <inc/lib.h>

void
usage(void)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 14             	sub    $0x14,%esp
	cprintf("usage: lsfd [-1]\n");
  800039:	68 80 21 80 00       	push   $0x802180
  80003e:	e8 c3 01 00 00       	call   800206 <cprintf>
	exit();
  800043:	e8 12 01 00 00       	call   80015a <exit>
}
  800048:	83 c4 10             	add    $0x10,%esp
  80004b:	c9                   	leave  
  80004c:	c3                   	ret    

0080004d <umain>:

void
umain(int argc, char **argv)
{
  80004d:	55                   	push   %ebp
  80004e:	89 e5                	mov    %esp,%ebp
  800050:	57                   	push   %edi
  800051:	56                   	push   %esi
  800052:	53                   	push   %ebx
  800053:	81 ec b0 00 00 00    	sub    $0xb0,%esp
	int i, usefprint = 0;
	struct Stat st;
	struct Argstate args;

	argstart(&argc, argv, &args);
  800059:	8d 85 4c ff ff ff    	lea    -0xb4(%ebp),%eax
  80005f:	50                   	push   %eax
  800060:	ff 75 0c             	pushl  0xc(%ebp)
  800063:	8d 45 08             	lea    0x8(%ebp),%eax
  800066:	50                   	push   %eax
  800067:	e8 e0 0d 00 00       	call   800e4c <argstart>
	while ((i = argnext(&args)) >= 0)
  80006c:	83 c4 10             	add    $0x10,%esp
}

void
umain(int argc, char **argv)
{
	int i, usefprint = 0;
  80006f:	be 00 00 00 00       	mov    $0x0,%esi
	struct Stat st;
	struct Argstate args;

	argstart(&argc, argv, &args);
	while ((i = argnext(&args)) >= 0)
  800074:	8d 9d 4c ff ff ff    	lea    -0xb4(%ebp),%ebx
  80007a:	eb 11                	jmp    80008d <umain+0x40>
		if (i == '1')
  80007c:	83 f8 31             	cmp    $0x31,%eax
  80007f:	74 07                	je     800088 <umain+0x3b>
			usefprint = 1;
		else
			usage();
  800081:	e8 ad ff ff ff       	call   800033 <usage>
  800086:	eb 05                	jmp    80008d <umain+0x40>
	struct Argstate args;

	argstart(&argc, argv, &args);
	while ((i = argnext(&args)) >= 0)
		if (i == '1')
			usefprint = 1;
  800088:	be 01 00 00 00       	mov    $0x1,%esi
	int i, usefprint = 0;
	struct Stat st;
	struct Argstate args;

	argstart(&argc, argv, &args);
	while ((i = argnext(&args)) >= 0)
  80008d:	83 ec 0c             	sub    $0xc,%esp
  800090:	53                   	push   %ebx
  800091:	e8 ef 0d 00 00       	call   800e85 <argnext>
  800096:	83 c4 10             	add    $0x10,%esp
  800099:	85 c0                	test   %eax,%eax
  80009b:	79 df                	jns    80007c <umain+0x2f>
  80009d:	bb 00 00 00 00       	mov    $0x0,%ebx
			usefprint = 1;
		else
			usage();

	for (i = 0; i < 32; i++)
		if (fstat(i, &st) >= 0) {
  8000a2:	8d bd 5c ff ff ff    	lea    -0xa4(%ebp),%edi
  8000a8:	83 ec 08             	sub    $0x8,%esp
  8000ab:	57                   	push   %edi
  8000ac:	53                   	push   %ebx
  8000ad:	e8 13 14 00 00       	call   8014c5 <fstat>
  8000b2:	83 c4 10             	add    $0x10,%esp
  8000b5:	85 c0                	test   %eax,%eax
  8000b7:	78 44                	js     8000fd <umain+0xb0>
			if (usefprint)
  8000b9:	85 f6                	test   %esi,%esi
  8000bb:	74 22                	je     8000df <umain+0x92>
				fprintf(1, "fd %d: name %s isdir %d size %d dev %s\n",
  8000bd:	83 ec 04             	sub    $0x4,%esp
  8000c0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8000c3:	ff 70 04             	pushl  0x4(%eax)
  8000c6:	ff 75 dc             	pushl  -0x24(%ebp)
  8000c9:	ff 75 e0             	pushl  -0x20(%ebp)
  8000cc:	57                   	push   %edi
  8000cd:	53                   	push   %ebx
  8000ce:	68 94 21 80 00       	push   $0x802194
  8000d3:	6a 01                	push   $0x1
  8000d5:	e8 51 17 00 00       	call   80182b <fprintf>
  8000da:	83 c4 20             	add    $0x20,%esp
  8000dd:	eb 1e                	jmp    8000fd <umain+0xb0>
					i, st.st_name, st.st_isdir,
					st.st_size, st.st_dev->dev_name);
			else
				cprintf("fd %d: name %s isdir %d size %d dev %s\n",
  8000df:	83 ec 08             	sub    $0x8,%esp
  8000e2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8000e5:	ff 70 04             	pushl  0x4(%eax)
  8000e8:	ff 75 dc             	pushl  -0x24(%ebp)
  8000eb:	ff 75 e0             	pushl  -0x20(%ebp)
  8000ee:	57                   	push   %edi
  8000ef:	53                   	push   %ebx
  8000f0:	68 94 21 80 00       	push   $0x802194
  8000f5:	e8 0c 01 00 00       	call   800206 <cprintf>
  8000fa:	83 c4 20             	add    $0x20,%esp
		if (i == '1')
			usefprint = 1;
		else
			usage();

	for (i = 0; i < 32; i++)
  8000fd:	43                   	inc    %ebx
  8000fe:	83 fb 20             	cmp    $0x20,%ebx
  800101:	75 a5                	jne    8000a8 <umain+0x5b>
			else
				cprintf("fd %d: name %s isdir %d size %d dev %s\n",
					i, st.st_name, st.st_isdir,
					st.st_size, st.st_dev->dev_name);
		}
}
  800103:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800106:	5b                   	pop    %ebx
  800107:	5e                   	pop    %esi
  800108:	5f                   	pop    %edi
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
  800116:	e8 02 0b 00 00       	call   800c1d <sys_getenvid>
  80011b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800120:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800127:	c1 e0 07             	shl    $0x7,%eax
  80012a:	29 d0                	sub    %edx,%eax
  80012c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800131:	a3 04 40 80 00       	mov    %eax,0x804004

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
  800146:	e8 02 ff ff ff       	call   80004d <umain>

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
  800160:	e8 4d 10 00 00       	call   8011b2 <close_all>
	sys_env_destroy(0);
  800165:	83 ec 0c             	sub    $0xc,%esp
  800168:	6a 00                	push   $0x0
  80016a:	e8 6d 0a 00 00       	call   800bdc <sys_env_destroy>
}
  80016f:	83 c4 10             	add    $0x10,%esp
  800172:	c9                   	leave  
  800173:	c3                   	ret    

00800174 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800174:	55                   	push   %ebp
  800175:	89 e5                	mov    %esp,%ebp
  800177:	53                   	push   %ebx
  800178:	83 ec 04             	sub    $0x4,%esp
  80017b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80017e:	8b 13                	mov    (%ebx),%edx
  800180:	8d 42 01             	lea    0x1(%edx),%eax
  800183:	89 03                	mov    %eax,(%ebx)
  800185:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800188:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80018c:	3d ff 00 00 00       	cmp    $0xff,%eax
  800191:	75 1a                	jne    8001ad <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800193:	83 ec 08             	sub    $0x8,%esp
  800196:	68 ff 00 00 00       	push   $0xff
  80019b:	8d 43 08             	lea    0x8(%ebx),%eax
  80019e:	50                   	push   %eax
  80019f:	e8 fb 09 00 00       	call   800b9f <sys_cputs>
		b->idx = 0;
  8001a4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001aa:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001ad:	ff 43 04             	incl   0x4(%ebx)
}
  8001b0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001b3:	c9                   	leave  
  8001b4:	c3                   	ret    

008001b5 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001b5:	55                   	push   %ebp
  8001b6:	89 e5                	mov    %esp,%ebp
  8001b8:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001be:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001c5:	00 00 00 
	b.cnt = 0;
  8001c8:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001cf:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001d2:	ff 75 0c             	pushl  0xc(%ebp)
  8001d5:	ff 75 08             	pushl  0x8(%ebp)
  8001d8:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001de:	50                   	push   %eax
  8001df:	68 74 01 80 00       	push   $0x800174
  8001e4:	e8 54 01 00 00       	call   80033d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001e9:	83 c4 08             	add    $0x8,%esp
  8001ec:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001f2:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001f8:	50                   	push   %eax
  8001f9:	e8 a1 09 00 00       	call   800b9f <sys_cputs>

	return b.cnt;
}
  8001fe:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800204:	c9                   	leave  
  800205:	c3                   	ret    

00800206 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800206:	55                   	push   %ebp
  800207:	89 e5                	mov    %esp,%ebp
  800209:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80020c:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80020f:	50                   	push   %eax
  800210:	ff 75 08             	pushl  0x8(%ebp)
  800213:	e8 9d ff ff ff       	call   8001b5 <vcprintf>
	va_end(ap);

	return cnt;
}
  800218:	c9                   	leave  
  800219:	c3                   	ret    

0080021a <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80021a:	55                   	push   %ebp
  80021b:	89 e5                	mov    %esp,%ebp
  80021d:	57                   	push   %edi
  80021e:	56                   	push   %esi
  80021f:	53                   	push   %ebx
  800220:	83 ec 1c             	sub    $0x1c,%esp
  800223:	89 c6                	mov    %eax,%esi
  800225:	89 d7                	mov    %edx,%edi
  800227:	8b 45 08             	mov    0x8(%ebp),%eax
  80022a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80022d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800230:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800233:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800236:	bb 00 00 00 00       	mov    $0x0,%ebx
  80023b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80023e:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800241:	39 d3                	cmp    %edx,%ebx
  800243:	72 11                	jb     800256 <printnum+0x3c>
  800245:	39 45 10             	cmp    %eax,0x10(%ebp)
  800248:	76 0c                	jbe    800256 <printnum+0x3c>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80024a:	8b 45 14             	mov    0x14(%ebp),%eax
  80024d:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800250:	85 db                	test   %ebx,%ebx
  800252:	7f 37                	jg     80028b <printnum+0x71>
  800254:	eb 44                	jmp    80029a <printnum+0x80>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800256:	83 ec 0c             	sub    $0xc,%esp
  800259:	ff 75 18             	pushl  0x18(%ebp)
  80025c:	8b 45 14             	mov    0x14(%ebp),%eax
  80025f:	48                   	dec    %eax
  800260:	50                   	push   %eax
  800261:	ff 75 10             	pushl  0x10(%ebp)
  800264:	83 ec 08             	sub    $0x8,%esp
  800267:	ff 75 e4             	pushl  -0x1c(%ebp)
  80026a:	ff 75 e0             	pushl  -0x20(%ebp)
  80026d:	ff 75 dc             	pushl  -0x24(%ebp)
  800270:	ff 75 d8             	pushl  -0x28(%ebp)
  800273:	e8 8c 1c 00 00       	call   801f04 <__udivdi3>
  800278:	83 c4 18             	add    $0x18,%esp
  80027b:	52                   	push   %edx
  80027c:	50                   	push   %eax
  80027d:	89 fa                	mov    %edi,%edx
  80027f:	89 f0                	mov    %esi,%eax
  800281:	e8 94 ff ff ff       	call   80021a <printnum>
  800286:	83 c4 20             	add    $0x20,%esp
  800289:	eb 0f                	jmp    80029a <printnum+0x80>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80028b:	83 ec 08             	sub    $0x8,%esp
  80028e:	57                   	push   %edi
  80028f:	ff 75 18             	pushl  0x18(%ebp)
  800292:	ff d6                	call   *%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800294:	83 c4 10             	add    $0x10,%esp
  800297:	4b                   	dec    %ebx
  800298:	75 f1                	jne    80028b <printnum+0x71>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80029a:	83 ec 08             	sub    $0x8,%esp
  80029d:	57                   	push   %edi
  80029e:	83 ec 04             	sub    $0x4,%esp
  8002a1:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002a4:	ff 75 e0             	pushl  -0x20(%ebp)
  8002a7:	ff 75 dc             	pushl  -0x24(%ebp)
  8002aa:	ff 75 d8             	pushl  -0x28(%ebp)
  8002ad:	e8 62 1d 00 00       	call   802014 <__umoddi3>
  8002b2:	83 c4 14             	add    $0x14,%esp
  8002b5:	0f be 80 c6 21 80 00 	movsbl 0x8021c6(%eax),%eax
  8002bc:	50                   	push   %eax
  8002bd:	ff d6                	call   *%esi
}
  8002bf:	83 c4 10             	add    $0x10,%esp
  8002c2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002c5:	5b                   	pop    %ebx
  8002c6:	5e                   	pop    %esi
  8002c7:	5f                   	pop    %edi
  8002c8:	5d                   	pop    %ebp
  8002c9:	c3                   	ret    

008002ca <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002ca:	55                   	push   %ebp
  8002cb:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002cd:	83 fa 01             	cmp    $0x1,%edx
  8002d0:	7e 0e                	jle    8002e0 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002d2:	8b 10                	mov    (%eax),%edx
  8002d4:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002d7:	89 08                	mov    %ecx,(%eax)
  8002d9:	8b 02                	mov    (%edx),%eax
  8002db:	8b 52 04             	mov    0x4(%edx),%edx
  8002de:	eb 22                	jmp    800302 <getuint+0x38>
	else if (lflag)
  8002e0:	85 d2                	test   %edx,%edx
  8002e2:	74 10                	je     8002f4 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002e4:	8b 10                	mov    (%eax),%edx
  8002e6:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002e9:	89 08                	mov    %ecx,(%eax)
  8002eb:	8b 02                	mov    (%edx),%eax
  8002ed:	ba 00 00 00 00       	mov    $0x0,%edx
  8002f2:	eb 0e                	jmp    800302 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002f4:	8b 10                	mov    (%eax),%edx
  8002f6:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002f9:	89 08                	mov    %ecx,(%eax)
  8002fb:	8b 02                	mov    (%edx),%eax
  8002fd:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800302:	5d                   	pop    %ebp
  800303:	c3                   	ret    

00800304 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800304:	55                   	push   %ebp
  800305:	89 e5                	mov    %esp,%ebp
  800307:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80030a:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  80030d:	8b 10                	mov    (%eax),%edx
  80030f:	3b 50 04             	cmp    0x4(%eax),%edx
  800312:	73 0a                	jae    80031e <sprintputch+0x1a>
		*b->buf++ = ch;
  800314:	8d 4a 01             	lea    0x1(%edx),%ecx
  800317:	89 08                	mov    %ecx,(%eax)
  800319:	8b 45 08             	mov    0x8(%ebp),%eax
  80031c:	88 02                	mov    %al,(%edx)
}
  80031e:	5d                   	pop    %ebp
  80031f:	c3                   	ret    

00800320 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800320:	55                   	push   %ebp
  800321:	89 e5                	mov    %esp,%ebp
  800323:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800326:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800329:	50                   	push   %eax
  80032a:	ff 75 10             	pushl  0x10(%ebp)
  80032d:	ff 75 0c             	pushl  0xc(%ebp)
  800330:	ff 75 08             	pushl  0x8(%ebp)
  800333:	e8 05 00 00 00       	call   80033d <vprintfmt>
	va_end(ap);
}
  800338:	83 c4 10             	add    $0x10,%esp
  80033b:	c9                   	leave  
  80033c:	c3                   	ret    

0080033d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80033d:	55                   	push   %ebp
  80033e:	89 e5                	mov    %esp,%ebp
  800340:	57                   	push   %edi
  800341:	56                   	push   %esi
  800342:	53                   	push   %ebx
  800343:	83 ec 2c             	sub    $0x2c,%esp
  800346:	8b 7d 08             	mov    0x8(%ebp),%edi
  800349:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80034c:	eb 03                	jmp    800351 <vprintfmt+0x14>
			break;

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
			for (fmt--; fmt[-1] != '%'; fmt--)
  80034e:	89 75 10             	mov    %esi,0x10(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {    //遍历输入的第一个参数，即输出信息的格式，先把格式字符串中'%'之前的字符一个个输出，因为它们前面没有'%'，所以它们就是要直接显示在屏幕上的
  800351:	8b 45 10             	mov    0x10(%ebp),%eax
  800354:	8d 70 01             	lea    0x1(%eax),%esi
  800357:	0f b6 00             	movzbl (%eax),%eax
  80035a:	83 f8 25             	cmp    $0x25,%eax
  80035d:	74 25                	je     800384 <vprintfmt+0x47>
			if (ch == '\0')									//当然中间如果遇到'\0'，代表这个字符串的访问结束
  80035f:	85 c0                	test   %eax,%eax
  800361:	75 0d                	jne    800370 <vprintfmt+0x33>
  800363:	e9 b5 03 00 00       	jmp    80071d <vprintfmt+0x3e0>
  800368:	85 c0                	test   %eax,%eax
  80036a:	0f 84 ad 03 00 00    	je     80071d <vprintfmt+0x3e0>
				return;
			putch(ch, putdat);								//调用putch函数，把一个字符ch输出到putdat指针所指向的地址中所存放的值对应的地址处
  800370:	83 ec 08             	sub    $0x8,%esp
  800373:	53                   	push   %ebx
  800374:	50                   	push   %eax
  800375:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {    //遍历输入的第一个参数，即输出信息的格式，先把格式字符串中'%'之前的字符一个个输出，因为它们前面没有'%'，所以它们就是要直接显示在屏幕上的
  800377:	46                   	inc    %esi
  800378:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  80037c:	83 c4 10             	add    $0x10,%esp
  80037f:	83 f8 25             	cmp    $0x25,%eax
  800382:	75 e4                	jne    800368 <vprintfmt+0x2b>
			if (width < 0)									//代表有小数点，但是小数点前面并没有数字，比如'%.6f'这种情况，此时代表整数部分全部显示
				width = 0;			
			goto reswitch;

		case '#':
			altflag = 1;
  800384:	c6 45 e3 20          	movb   $0x20,-0x1d(%ebp)
  800388:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80038f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800396:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80039d:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8003a4:	eb 07                	jmp    8003ad <vprintfmt+0x70>
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  8003a6:	8b 75 10             	mov    0x10(%ebp),%esi

		// flag to pad on the right
		case '-':											//%后面的'-'代表要进行左对齐输出，右边填空格，如果省略代表右对齐
			padc = '-';										//如果有这个字符代表左对齐，则把对齐方式标志位变为'-'
  8003a9:	c6 45 e3 2d          	movb   $0x2d,-0x1d(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  8003ad:	8d 46 01             	lea    0x1(%esi),%eax
  8003b0:	89 45 10             	mov    %eax,0x10(%ebp)
  8003b3:	0f b6 16             	movzbl (%esi),%edx
  8003b6:	8a 06                	mov    (%esi),%al
  8003b8:	83 e8 23             	sub    $0x23,%eax
  8003bb:	3c 55                	cmp    $0x55,%al
  8003bd:	0f 87 03 03 00 00    	ja     8006c6 <vprintfmt+0x389>
  8003c3:	0f b6 c0             	movzbl %al,%eax
  8003c6:	ff 24 85 00 23 80 00 	jmp    *0x802300(,%eax,4)
  8003cd:	8b 75 10             	mov    0x10(%ebp),%esi
			padc = '-';										//如果有这个字符代表左对齐，则把对齐方式标志位变为'-'
			goto reswitch;									//处理下一个字符

		// flag to pad with 0's instead of spaces
		case '0':											//0--有0表示进行对齐输出时填0,如省略表示填入空格，并且如果为0，则一定是右对齐
			padc = '0';										//对其方式标志位变为0
  8003d0:	c6 45 e3 30          	movb   $0x30,-0x1d(%ebp)
  8003d4:	eb d7                	jmp    8003ad <vprintfmt+0x70>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {					//把遇到的位数字符串转换为真实的位数，比如输入的'%40'，代表有效位数为40位，下面的循环就是把precesion的值设置为40
				precision = precision * 10 + ch - '0';
  8003d6:	8d 42 d0             	lea    -0x30(%edx),%eax
  8003d9:	89 c1                	mov    %eax,%ecx
  8003db:	89 45 d0             	mov    %eax,-0x30(%ebp)
				ch = *fmt;
  8003de:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  8003e2:	8d 50 d0             	lea    -0x30(%eax),%edx
  8003e5:	83 fa 09             	cmp    $0x9,%edx
  8003e8:	77 51                	ja     80043b <vprintfmt+0xfe>
  8003ea:	8b 75 10             	mov    0x10(%ebp),%esi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {					//把遇到的位数字符串转换为真实的位数，比如输入的'%40'，代表有效位数为40位，下面的循环就是把precesion的值设置为40
  8003ed:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  8003ee:	8d 14 89             	lea    (%ecx,%ecx,4),%edx
  8003f1:	01 d2                	add    %edx,%edx
  8003f3:	8d 4c 10 d0          	lea    -0x30(%eax,%edx,1),%ecx
				ch = *fmt;
  8003f7:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8003fa:	8d 50 d0             	lea    -0x30(%eax),%edx
  8003fd:	83 fa 09             	cmp    $0x9,%edx
  800400:	76 eb                	jbe    8003ed <vprintfmt+0xb0>
  800402:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800405:	eb 37                	jmp    80043e <vprintfmt+0x101>
					break;
			}
			goto process_precision;							//跳转到process_precistion子过程

		case '*':											//*--代表有效数字的位数也是由输入参数指定的，比如printf("%*.*f", 10, 2, n)，其中10,2就是用来指定显示的有效数字位数的
			precision = va_arg(ap, int);
  800407:	8b 45 14             	mov    0x14(%ebp),%eax
  80040a:	8d 50 04             	lea    0x4(%eax),%edx
  80040d:	89 55 14             	mov    %edx,0x14(%ebp)
  800410:	8b 00                	mov    (%eax),%eax
  800412:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  800415:	8b 75 10             	mov    0x10(%ebp),%esi
			}
			goto process_precision;							//跳转到process_precistion子过程

		case '*':											//*--代表有效数字的位数也是由输入参数指定的，比如printf("%*.*f", 10, 2, n)，其中10,2就是用来指定显示的有效数字位数的
			precision = va_arg(ap, int);
			goto process_precision;
  800418:	eb 24                	jmp    80043e <vprintfmt+0x101>
  80041a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80041e:	79 07                	jns    800427 <vprintfmt+0xea>
  800420:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  800427:	8b 75 10             	mov    0x10(%ebp),%esi
  80042a:	eb 81                	jmp    8003ad <vprintfmt+0x70>
  80042c:	8b 75 10             	mov    0x10(%ebp),%esi
			if (width < 0)									//代表有小数点，但是小数点前面并没有数字，比如'%.6f'这种情况，此时代表整数部分全部显示
				width = 0;			
			goto reswitch;

		case '#':
			altflag = 1;
  80042f:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800436:	e9 72 ff ff ff       	jmp    8003ad <vprintfmt+0x70>
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  80043b:	8b 75 10             	mov    0x10(%ebp),%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:									//处理输出精度，把width字段赋值为刚刚计算出来的precision值，所以width应该是整数部分的有效数字位数
			if (width < 0)
  80043e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800442:	0f 89 65 ff ff ff    	jns    8003ad <vprintfmt+0x70>
				width = precision, precision = -1;
  800448:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80044b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80044e:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800455:	e9 53 ff ff ff       	jmp    8003ad <vprintfmt+0x70>
			goto reswitch;

		// long flag (doubled for long long)				
		case 'l':											//如果遇到'l'，代表应该是输入long类型，如果有两个'l'代表long long
			lflag++;										//此时把lflag++
  80045a:	ff 45 d4             	incl   -0x2c(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  80045d:	8b 75 10             	mov    0x10(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)				
		case 'l':											//如果遇到'l'，代表应该是输入long类型，如果有两个'l'代表long long
			lflag++;										//此时把lflag++
			goto reswitch;
  800460:	e9 48 ff ff ff       	jmp    8003ad <vprintfmt+0x70>

		// character
		case 'c':											//如果是'c'代表显示一个字符
			putch(va_arg(ap, int), putdat);					//调用输出一个字符到内存的函数putch
  800465:	8b 45 14             	mov    0x14(%ebp),%eax
  800468:	8d 50 04             	lea    0x4(%eax),%edx
  80046b:	89 55 14             	mov    %edx,0x14(%ebp)
  80046e:	83 ec 08             	sub    $0x8,%esp
  800471:	53                   	push   %ebx
  800472:	ff 30                	pushl  (%eax)
  800474:	ff d7                	call   *%edi
			break;
  800476:	83 c4 10             	add    $0x10,%esp
  800479:	e9 d3 fe ff ff       	jmp    800351 <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80047e:	8b 45 14             	mov    0x14(%ebp),%eax
  800481:	8d 50 04             	lea    0x4(%eax),%edx
  800484:	89 55 14             	mov    %edx,0x14(%ebp)
  800487:	8b 00                	mov    (%eax),%eax
  800489:	85 c0                	test   %eax,%eax
  80048b:	79 02                	jns    80048f <vprintfmt+0x152>
  80048d:	f7 d8                	neg    %eax
  80048f:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800491:	83 f8 0f             	cmp    $0xf,%eax
  800494:	7f 0b                	jg     8004a1 <vprintfmt+0x164>
  800496:	8b 04 85 60 24 80 00 	mov    0x802460(,%eax,4),%eax
  80049d:	85 c0                	test   %eax,%eax
  80049f:	75 15                	jne    8004b6 <vprintfmt+0x179>
				printfmt(putch, putdat, "error %d", err);
  8004a1:	52                   	push   %edx
  8004a2:	68 de 21 80 00       	push   $0x8021de
  8004a7:	53                   	push   %ebx
  8004a8:	57                   	push   %edi
  8004a9:	e8 72 fe ff ff       	call   800320 <printfmt>
  8004ae:	83 c4 10             	add    $0x10,%esp
  8004b1:	e9 9b fe ff ff       	jmp    800351 <vprintfmt+0x14>
			else
				printfmt(putch, putdat, "%s", p);
  8004b6:	50                   	push   %eax
  8004b7:	68 7f 25 80 00       	push   $0x80257f
  8004bc:	53                   	push   %ebx
  8004bd:	57                   	push   %edi
  8004be:	e8 5d fe ff ff       	call   800320 <printfmt>
  8004c3:	83 c4 10             	add    $0x10,%esp
  8004c6:	e9 86 fe ff ff       	jmp    800351 <vprintfmt+0x14>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ce:	8d 50 04             	lea    0x4(%eax),%edx
  8004d1:	89 55 14             	mov    %edx,0x14(%ebp)
  8004d4:	8b 00                	mov    (%eax),%eax
  8004d6:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8004d9:	85 c0                	test   %eax,%eax
  8004db:	75 07                	jne    8004e4 <vprintfmt+0x1a7>
				p = "(null)";
  8004dd:	c7 45 d4 d7 21 80 00 	movl   $0x8021d7,-0x2c(%ebp)
			if (width > 0 && padc != '-')
  8004e4:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8004e7:	85 f6                	test   %esi,%esi
  8004e9:	0f 8e fb 01 00 00    	jle    8006ea <vprintfmt+0x3ad>
  8004ef:	80 7d e3 2d          	cmpb   $0x2d,-0x1d(%ebp)
  8004f3:	0f 84 09 02 00 00    	je     800702 <vprintfmt+0x3c5>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004f9:	83 ec 08             	sub    $0x8,%esp
  8004fc:	ff 75 d0             	pushl  -0x30(%ebp)
  8004ff:	ff 75 d4             	pushl  -0x2c(%ebp)
  800502:	e8 ad 02 00 00       	call   8007b4 <strnlen>
  800507:	89 f1                	mov    %esi,%ecx
  800509:	29 c1                	sub    %eax,%ecx
  80050b:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  80050e:	83 c4 10             	add    $0x10,%esp
  800511:	85 c9                	test   %ecx,%ecx
  800513:	0f 8e d1 01 00 00    	jle    8006ea <vprintfmt+0x3ad>
					putch(padc, putdat);
  800519:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  80051d:	83 ec 08             	sub    $0x8,%esp
  800520:	53                   	push   %ebx
  800521:	56                   	push   %esi
  800522:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800524:	83 c4 10             	add    $0x10,%esp
  800527:	ff 4d e4             	decl   -0x1c(%ebp)
  80052a:	75 f1                	jne    80051d <vprintfmt+0x1e0>
  80052c:	e9 b9 01 00 00       	jmp    8006ea <vprintfmt+0x3ad>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800531:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800535:	74 19                	je     800550 <vprintfmt+0x213>
  800537:	0f be c0             	movsbl %al,%eax
  80053a:	83 e8 20             	sub    $0x20,%eax
  80053d:	83 f8 5e             	cmp    $0x5e,%eax
  800540:	76 0e                	jbe    800550 <vprintfmt+0x213>
					putch('?', putdat);
  800542:	83 ec 08             	sub    $0x8,%esp
  800545:	53                   	push   %ebx
  800546:	6a 3f                	push   $0x3f
  800548:	ff 55 08             	call   *0x8(%ebp)
  80054b:	83 c4 10             	add    $0x10,%esp
  80054e:	eb 0b                	jmp    80055b <vprintfmt+0x21e>
				else
					putch(ch, putdat);
  800550:	83 ec 08             	sub    $0x8,%esp
  800553:	53                   	push   %ebx
  800554:	52                   	push   %edx
  800555:	ff 55 08             	call   *0x8(%ebp)
  800558:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80055b:	ff 4d e4             	decl   -0x1c(%ebp)
  80055e:	46                   	inc    %esi
  80055f:	8a 46 ff             	mov    -0x1(%esi),%al
  800562:	0f be d0             	movsbl %al,%edx
  800565:	85 d2                	test   %edx,%edx
  800567:	75 1c                	jne    800585 <vprintfmt+0x248>
  800569:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80056c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800570:	7f 1f                	jg     800591 <vprintfmt+0x254>
  800572:	e9 da fd ff ff       	jmp    800351 <vprintfmt+0x14>
  800577:	89 7d 08             	mov    %edi,0x8(%ebp)
  80057a:	8b 7d d0             	mov    -0x30(%ebp),%edi
  80057d:	eb 06                	jmp    800585 <vprintfmt+0x248>
  80057f:	89 7d 08             	mov    %edi,0x8(%ebp)
  800582:	8b 7d d0             	mov    -0x30(%ebp),%edi
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800585:	85 ff                	test   %edi,%edi
  800587:	78 a8                	js     800531 <vprintfmt+0x1f4>
  800589:	4f                   	dec    %edi
  80058a:	79 a5                	jns    800531 <vprintfmt+0x1f4>
  80058c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80058f:	eb db                	jmp    80056c <vprintfmt+0x22f>
  800591:	8b 75 e4             	mov    -0x1c(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800594:	83 ec 08             	sub    $0x8,%esp
  800597:	53                   	push   %ebx
  800598:	6a 20                	push   $0x20
  80059a:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80059c:	4e                   	dec    %esi
  80059d:	83 c4 10             	add    $0x10,%esp
  8005a0:	85 f6                	test   %esi,%esi
  8005a2:	7f f0                	jg     800594 <vprintfmt+0x257>
  8005a4:	e9 a8 fd ff ff       	jmp    800351 <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005a9:	83 7d d4 01          	cmpl   $0x1,-0x2c(%ebp)
  8005ad:	7e 16                	jle    8005c5 <vprintfmt+0x288>
		return va_arg(*ap, long long);
  8005af:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b2:	8d 50 08             	lea    0x8(%eax),%edx
  8005b5:	89 55 14             	mov    %edx,0x14(%ebp)
  8005b8:	8b 50 04             	mov    0x4(%eax),%edx
  8005bb:	8b 00                	mov    (%eax),%eax
  8005bd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005c0:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005c3:	eb 34                	jmp    8005f9 <vprintfmt+0x2bc>
	else if (lflag)
  8005c5:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8005c9:	74 18                	je     8005e3 <vprintfmt+0x2a6>
		return va_arg(*ap, long);
  8005cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ce:	8d 50 04             	lea    0x4(%eax),%edx
  8005d1:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d4:	8b 30                	mov    (%eax),%esi
  8005d6:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8005d9:	89 f0                	mov    %esi,%eax
  8005db:	c1 f8 1f             	sar    $0x1f,%eax
  8005de:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8005e1:	eb 16                	jmp    8005f9 <vprintfmt+0x2bc>
	else
		return va_arg(*ap, int);
  8005e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e6:	8d 50 04             	lea    0x4(%eax),%edx
  8005e9:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ec:	8b 30                	mov    (%eax),%esi
  8005ee:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8005f1:	89 f0                	mov    %esi,%eax
  8005f3:	c1 f8 1f             	sar    $0x1f,%eax
  8005f6:	89 45 dc             	mov    %eax,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005f9:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005fc:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
  8005ff:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800603:	0f 89 8a 00 00 00    	jns    800693 <vprintfmt+0x356>
				putch('-', putdat);
  800609:	83 ec 08             	sub    $0x8,%esp
  80060c:	53                   	push   %ebx
  80060d:	6a 2d                	push   $0x2d
  80060f:	ff d7                	call   *%edi
				num = -(long long) num;
  800611:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800614:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800617:	f7 d8                	neg    %eax
  800619:	83 d2 00             	adc    $0x0,%edx
  80061c:	f7 da                	neg    %edx
  80061e:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800621:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800626:	eb 70                	jmp    800698 <vprintfmt+0x35b>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800628:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80062b:	8d 45 14             	lea    0x14(%ebp),%eax
  80062e:	e8 97 fc ff ff       	call   8002ca <getuint>
			base = 10;
  800633:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800638:	eb 5e                	jmp    800698 <vprintfmt+0x35b>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
  80063a:	83 ec 08             	sub    $0x8,%esp
  80063d:	53                   	push   %ebx
  80063e:	6a 30                	push   $0x30
  800640:	ff d7                	call   *%edi
			num = getuint(&ap, lflag);
  800642:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800645:	8d 45 14             	lea    0x14(%ebp),%eax
  800648:	e8 7d fc ff ff       	call   8002ca <getuint>
			base = 8;
			goto number;
  80064d:	83 c4 10             	add    $0x10,%esp
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  800650:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800655:	eb 41                	jmp    800698 <vprintfmt+0x35b>
		// pointer
		case 'p':
			putch('0', putdat);
  800657:	83 ec 08             	sub    $0x8,%esp
  80065a:	53                   	push   %ebx
  80065b:	6a 30                	push   $0x30
  80065d:	ff d7                	call   *%edi
			putch('x', putdat);
  80065f:	83 c4 08             	add    $0x8,%esp
  800662:	53                   	push   %ebx
  800663:	6a 78                	push   $0x78
  800665:	ff d7                	call   *%edi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800667:	8b 45 14             	mov    0x14(%ebp),%eax
  80066a:	8d 50 04             	lea    0x4(%eax),%edx
  80066d:	89 55 14             	mov    %edx,0x14(%ebp)
			goto number;
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800670:	8b 00                	mov    (%eax),%eax
  800672:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800677:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80067a:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80067f:	eb 17                	jmp    800698 <vprintfmt+0x35b>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800681:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800684:	8d 45 14             	lea    0x14(%ebp),%eax
  800687:	e8 3e fc ff ff       	call   8002ca <getuint>
			base = 16;
  80068c:	b9 10 00 00 00       	mov    $0x10,%ecx
  800691:	eb 05                	jmp    800698 <vprintfmt+0x35b>
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800693:	b9 0a 00 00 00       	mov    $0xa,%ecx
		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  800698:	83 ec 0c             	sub    $0xc,%esp
  80069b:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  80069f:	56                   	push   %esi
  8006a0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8006a3:	51                   	push   %ecx
  8006a4:	52                   	push   %edx
  8006a5:	50                   	push   %eax
  8006a6:	89 da                	mov    %ebx,%edx
  8006a8:	89 f8                	mov    %edi,%eax
  8006aa:	e8 6b fb ff ff       	call   80021a <printnum>
			break;
  8006af:	83 c4 20             	add    $0x20,%esp
  8006b2:	e9 9a fc ff ff       	jmp    800351 <vprintfmt+0x14>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006b7:	83 ec 08             	sub    $0x8,%esp
  8006ba:	53                   	push   %ebx
  8006bb:	52                   	push   %edx
  8006bc:	ff d7                	call   *%edi
			break;
  8006be:	83 c4 10             	add    $0x10,%esp
  8006c1:	e9 8b fc ff ff       	jmp    800351 <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006c6:	83 ec 08             	sub    $0x8,%esp
  8006c9:	53                   	push   %ebx
  8006ca:	6a 25                	push   $0x25
  8006cc:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006ce:	83 c4 10             	add    $0x10,%esp
  8006d1:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8006d5:	0f 84 73 fc ff ff    	je     80034e <vprintfmt+0x11>
  8006db:	4e                   	dec    %esi
  8006dc:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8006e0:	75 f9                	jne    8006db <vprintfmt+0x39e>
  8006e2:	89 75 10             	mov    %esi,0x10(%ebp)
  8006e5:	e9 67 fc ff ff       	jmp    800351 <vprintfmt+0x14>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006ea:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8006ed:	8d 70 01             	lea    0x1(%eax),%esi
  8006f0:	8a 00                	mov    (%eax),%al
  8006f2:	0f be d0             	movsbl %al,%edx
  8006f5:	85 d2                	test   %edx,%edx
  8006f7:	0f 85 7a fe ff ff    	jne    800577 <vprintfmt+0x23a>
  8006fd:	e9 4f fc ff ff       	jmp    800351 <vprintfmt+0x14>
  800702:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800705:	8d 70 01             	lea    0x1(%eax),%esi
  800708:	8a 00                	mov    (%eax),%al
  80070a:	0f be d0             	movsbl %al,%edx
  80070d:	85 d2                	test   %edx,%edx
  80070f:	0f 85 6a fe ff ff    	jne    80057f <vprintfmt+0x242>
  800715:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800718:	e9 77 fe ff ff       	jmp    800594 <vprintfmt+0x257>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  80071d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800720:	5b                   	pop    %ebx
  800721:	5e                   	pop    %esi
  800722:	5f                   	pop    %edi
  800723:	5d                   	pop    %ebp
  800724:	c3                   	ret    

00800725 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800725:	55                   	push   %ebp
  800726:	89 e5                	mov    %esp,%ebp
  800728:	83 ec 18             	sub    $0x18,%esp
  80072b:	8b 45 08             	mov    0x8(%ebp),%eax
  80072e:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800731:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800734:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800738:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80073b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800742:	85 c0                	test   %eax,%eax
  800744:	74 26                	je     80076c <vsnprintf+0x47>
  800746:	85 d2                	test   %edx,%edx
  800748:	7e 29                	jle    800773 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80074a:	ff 75 14             	pushl  0x14(%ebp)
  80074d:	ff 75 10             	pushl  0x10(%ebp)
  800750:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800753:	50                   	push   %eax
  800754:	68 04 03 80 00       	push   $0x800304
  800759:	e8 df fb ff ff       	call   80033d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80075e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800761:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800764:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800767:	83 c4 10             	add    $0x10,%esp
  80076a:	eb 0c                	jmp    800778 <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80076c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800771:	eb 05                	jmp    800778 <vsnprintf+0x53>
  800773:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800778:	c9                   	leave  
  800779:	c3                   	ret    

0080077a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80077a:	55                   	push   %ebp
  80077b:	89 e5                	mov    %esp,%ebp
  80077d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800780:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800783:	50                   	push   %eax
  800784:	ff 75 10             	pushl  0x10(%ebp)
  800787:	ff 75 0c             	pushl  0xc(%ebp)
  80078a:	ff 75 08             	pushl  0x8(%ebp)
  80078d:	e8 93 ff ff ff       	call   800725 <vsnprintf>
	va_end(ap);

	return rc;
}
  800792:	c9                   	leave  
  800793:	c3                   	ret    

00800794 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800794:	55                   	push   %ebp
  800795:	89 e5                	mov    %esp,%ebp
  800797:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80079a:	80 3a 00             	cmpb   $0x0,(%edx)
  80079d:	74 0e                	je     8007ad <strlen+0x19>
  80079f:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8007a4:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007a5:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007a9:	75 f9                	jne    8007a4 <strlen+0x10>
  8007ab:	eb 05                	jmp    8007b2 <strlen+0x1e>
  8007ad:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8007b2:	5d                   	pop    %ebp
  8007b3:	c3                   	ret    

008007b4 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007b4:	55                   	push   %ebp
  8007b5:	89 e5                	mov    %esp,%ebp
  8007b7:	53                   	push   %ebx
  8007b8:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8007bb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007be:	85 c9                	test   %ecx,%ecx
  8007c0:	74 1a                	je     8007dc <strnlen+0x28>
  8007c2:	80 3b 00             	cmpb   $0x0,(%ebx)
  8007c5:	74 1c                	je     8007e3 <strnlen+0x2f>
  8007c7:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  8007cc:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007ce:	39 ca                	cmp    %ecx,%edx
  8007d0:	74 16                	je     8007e8 <strnlen+0x34>
  8007d2:	42                   	inc    %edx
  8007d3:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  8007d8:	75 f2                	jne    8007cc <strnlen+0x18>
  8007da:	eb 0c                	jmp    8007e8 <strnlen+0x34>
  8007dc:	b8 00 00 00 00       	mov    $0x0,%eax
  8007e1:	eb 05                	jmp    8007e8 <strnlen+0x34>
  8007e3:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8007e8:	5b                   	pop    %ebx
  8007e9:	5d                   	pop    %ebp
  8007ea:	c3                   	ret    

008007eb <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007eb:	55                   	push   %ebp
  8007ec:	89 e5                	mov    %esp,%ebp
  8007ee:	53                   	push   %ebx
  8007ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007f5:	89 c2                	mov    %eax,%edx
  8007f7:	42                   	inc    %edx
  8007f8:	41                   	inc    %ecx
  8007f9:	8a 59 ff             	mov    -0x1(%ecx),%bl
  8007fc:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007ff:	84 db                	test   %bl,%bl
  800801:	75 f4                	jne    8007f7 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800803:	5b                   	pop    %ebx
  800804:	5d                   	pop    %ebp
  800805:	c3                   	ret    

00800806 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800806:	55                   	push   %ebp
  800807:	89 e5                	mov    %esp,%ebp
  800809:	53                   	push   %ebx
  80080a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80080d:	53                   	push   %ebx
  80080e:	e8 81 ff ff ff       	call   800794 <strlen>
  800813:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800816:	ff 75 0c             	pushl  0xc(%ebp)
  800819:	01 d8                	add    %ebx,%eax
  80081b:	50                   	push   %eax
  80081c:	e8 ca ff ff ff       	call   8007eb <strcpy>
	return dst;
}
  800821:	89 d8                	mov    %ebx,%eax
  800823:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800826:	c9                   	leave  
  800827:	c3                   	ret    

00800828 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800828:	55                   	push   %ebp
  800829:	89 e5                	mov    %esp,%ebp
  80082b:	56                   	push   %esi
  80082c:	53                   	push   %ebx
  80082d:	8b 75 08             	mov    0x8(%ebp),%esi
  800830:	8b 55 0c             	mov    0xc(%ebp),%edx
  800833:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800836:	85 db                	test   %ebx,%ebx
  800838:	74 14                	je     80084e <strncpy+0x26>
  80083a:	01 f3                	add    %esi,%ebx
  80083c:	89 f1                	mov    %esi,%ecx
		*dst++ = *src;
  80083e:	41                   	inc    %ecx
  80083f:	8a 02                	mov    (%edx),%al
  800841:	88 41 ff             	mov    %al,-0x1(%ecx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800844:	80 3a 01             	cmpb   $0x1,(%edx)
  800847:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80084a:	39 cb                	cmp    %ecx,%ebx
  80084c:	75 f0                	jne    80083e <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80084e:	89 f0                	mov    %esi,%eax
  800850:	5b                   	pop    %ebx
  800851:	5e                   	pop    %esi
  800852:	5d                   	pop    %ebp
  800853:	c3                   	ret    

00800854 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800854:	55                   	push   %ebp
  800855:	89 e5                	mov    %esp,%ebp
  800857:	53                   	push   %ebx
  800858:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80085b:	8b 45 10             	mov    0x10(%ebp),%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80085e:	85 c0                	test   %eax,%eax
  800860:	74 30                	je     800892 <strlcpy+0x3e>
		while (--size > 0 && *src != '\0')
  800862:	48                   	dec    %eax
  800863:	74 20                	je     800885 <strlcpy+0x31>
  800865:	8a 0b                	mov    (%ebx),%cl
  800867:	84 c9                	test   %cl,%cl
  800869:	74 1f                	je     80088a <strlcpy+0x36>
  80086b:	8d 53 01             	lea    0x1(%ebx),%edx
  80086e:	01 c3                	add    %eax,%ebx
  800870:	8b 45 08             	mov    0x8(%ebp),%eax
			*dst++ = *src++;
  800873:	40                   	inc    %eax
  800874:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800877:	39 da                	cmp    %ebx,%edx
  800879:	74 12                	je     80088d <strlcpy+0x39>
  80087b:	42                   	inc    %edx
  80087c:	8a 4a ff             	mov    -0x1(%edx),%cl
  80087f:	84 c9                	test   %cl,%cl
  800881:	75 f0                	jne    800873 <strlcpy+0x1f>
  800883:	eb 08                	jmp    80088d <strlcpy+0x39>
  800885:	8b 45 08             	mov    0x8(%ebp),%eax
  800888:	eb 03                	jmp    80088d <strlcpy+0x39>
  80088a:	8b 45 08             	mov    0x8(%ebp),%eax
			*dst++ = *src++;
		*dst = '\0';
  80088d:	c6 00 00             	movb   $0x0,(%eax)
  800890:	eb 03                	jmp    800895 <strlcpy+0x41>
  800892:	8b 45 08             	mov    0x8(%ebp),%eax
	}
	return dst - dst_in;
  800895:	2b 45 08             	sub    0x8(%ebp),%eax
}
  800898:	5b                   	pop    %ebx
  800899:	5d                   	pop    %ebp
  80089a:	c3                   	ret    

0080089b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80089b:	55                   	push   %ebp
  80089c:	89 e5                	mov    %esp,%ebp
  80089e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008a1:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008a4:	8a 01                	mov    (%ecx),%al
  8008a6:	84 c0                	test   %al,%al
  8008a8:	74 10                	je     8008ba <strcmp+0x1f>
  8008aa:	3a 02                	cmp    (%edx),%al
  8008ac:	75 0c                	jne    8008ba <strcmp+0x1f>
		p++, q++;
  8008ae:	41                   	inc    %ecx
  8008af:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008b0:	8a 01                	mov    (%ecx),%al
  8008b2:	84 c0                	test   %al,%al
  8008b4:	74 04                	je     8008ba <strcmp+0x1f>
  8008b6:	3a 02                	cmp    (%edx),%al
  8008b8:	74 f4                	je     8008ae <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008ba:	0f b6 c0             	movzbl %al,%eax
  8008bd:	0f b6 12             	movzbl (%edx),%edx
  8008c0:	29 d0                	sub    %edx,%eax
}
  8008c2:	5d                   	pop    %ebp
  8008c3:	c3                   	ret    

008008c4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008c4:	55                   	push   %ebp
  8008c5:	89 e5                	mov    %esp,%ebp
  8008c7:	56                   	push   %esi
  8008c8:	53                   	push   %ebx
  8008c9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8008cc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008cf:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  8008d2:	85 f6                	test   %esi,%esi
  8008d4:	74 23                	je     8008f9 <strncmp+0x35>
  8008d6:	8a 03                	mov    (%ebx),%al
  8008d8:	84 c0                	test   %al,%al
  8008da:	74 2b                	je     800907 <strncmp+0x43>
  8008dc:	3a 02                	cmp    (%edx),%al
  8008de:	75 27                	jne    800907 <strncmp+0x43>
  8008e0:	8d 43 01             	lea    0x1(%ebx),%eax
  8008e3:	01 de                	add    %ebx,%esi
		n--, p++, q++;
  8008e5:	89 c3                	mov    %eax,%ebx
  8008e7:	42                   	inc    %edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008e8:	39 c6                	cmp    %eax,%esi
  8008ea:	74 14                	je     800900 <strncmp+0x3c>
  8008ec:	8a 08                	mov    (%eax),%cl
  8008ee:	84 c9                	test   %cl,%cl
  8008f0:	74 15                	je     800907 <strncmp+0x43>
  8008f2:	40                   	inc    %eax
  8008f3:	3a 0a                	cmp    (%edx),%cl
  8008f5:	74 ee                	je     8008e5 <strncmp+0x21>
  8008f7:	eb 0e                	jmp    800907 <strncmp+0x43>
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008f9:	b8 00 00 00 00       	mov    $0x0,%eax
  8008fe:	eb 0f                	jmp    80090f <strncmp+0x4b>
  800900:	b8 00 00 00 00       	mov    $0x0,%eax
  800905:	eb 08                	jmp    80090f <strncmp+0x4b>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800907:	0f b6 03             	movzbl (%ebx),%eax
  80090a:	0f b6 12             	movzbl (%edx),%edx
  80090d:	29 d0                	sub    %edx,%eax
}
  80090f:	5b                   	pop    %ebx
  800910:	5e                   	pop    %esi
  800911:	5d                   	pop    %ebp
  800912:	c3                   	ret    

00800913 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800913:	55                   	push   %ebp
  800914:	89 e5                	mov    %esp,%ebp
  800916:	53                   	push   %ebx
  800917:	8b 45 08             	mov    0x8(%ebp),%eax
  80091a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  80091d:	8a 10                	mov    (%eax),%dl
  80091f:	84 d2                	test   %dl,%dl
  800921:	74 1a                	je     80093d <strchr+0x2a>
  800923:	88 d9                	mov    %bl,%cl
		if (*s == c)
  800925:	38 d3                	cmp    %dl,%bl
  800927:	75 06                	jne    80092f <strchr+0x1c>
  800929:	eb 17                	jmp    800942 <strchr+0x2f>
  80092b:	38 ca                	cmp    %cl,%dl
  80092d:	74 13                	je     800942 <strchr+0x2f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80092f:	40                   	inc    %eax
  800930:	8a 10                	mov    (%eax),%dl
  800932:	84 d2                	test   %dl,%dl
  800934:	75 f5                	jne    80092b <strchr+0x18>
		if (*s == c)
			return (char *) s;
	return 0;
  800936:	b8 00 00 00 00       	mov    $0x0,%eax
  80093b:	eb 05                	jmp    800942 <strchr+0x2f>
  80093d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800942:	5b                   	pop    %ebx
  800943:	5d                   	pop    %ebp
  800944:	c3                   	ret    

00800945 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800945:	55                   	push   %ebp
  800946:	89 e5                	mov    %esp,%ebp
  800948:	53                   	push   %ebx
  800949:	8b 45 08             	mov    0x8(%ebp),%eax
  80094c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  80094f:	8a 10                	mov    (%eax),%dl
  800951:	84 d2                	test   %dl,%dl
  800953:	74 13                	je     800968 <strfind+0x23>
  800955:	88 d9                	mov    %bl,%cl
		if (*s == c)
  800957:	38 d3                	cmp    %dl,%bl
  800959:	75 06                	jne    800961 <strfind+0x1c>
  80095b:	eb 0b                	jmp    800968 <strfind+0x23>
  80095d:	38 ca                	cmp    %cl,%dl
  80095f:	74 07                	je     800968 <strfind+0x23>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800961:	40                   	inc    %eax
  800962:	8a 10                	mov    (%eax),%dl
  800964:	84 d2                	test   %dl,%dl
  800966:	75 f5                	jne    80095d <strfind+0x18>
		if (*s == c)
			break;
	return (char *) s;
}
  800968:	5b                   	pop    %ebx
  800969:	5d                   	pop    %ebp
  80096a:	c3                   	ret    

0080096b <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80096b:	55                   	push   %ebp
  80096c:	89 e5                	mov    %esp,%ebp
  80096e:	57                   	push   %edi
  80096f:	56                   	push   %esi
  800970:	53                   	push   %ebx
  800971:	8b 7d 08             	mov    0x8(%ebp),%edi
  800974:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800977:	85 c9                	test   %ecx,%ecx
  800979:	74 36                	je     8009b1 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80097b:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800981:	75 28                	jne    8009ab <memset+0x40>
  800983:	f6 c1 03             	test   $0x3,%cl
  800986:	75 23                	jne    8009ab <memset+0x40>
		c &= 0xFF;
  800988:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80098c:	89 d3                	mov    %edx,%ebx
  80098e:	c1 e3 08             	shl    $0x8,%ebx
  800991:	89 d6                	mov    %edx,%esi
  800993:	c1 e6 18             	shl    $0x18,%esi
  800996:	89 d0                	mov    %edx,%eax
  800998:	c1 e0 10             	shl    $0x10,%eax
  80099b:	09 f0                	or     %esi,%eax
  80099d:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80099f:	89 d8                	mov    %ebx,%eax
  8009a1:	09 d0                	or     %edx,%eax
  8009a3:	c1 e9 02             	shr    $0x2,%ecx
  8009a6:	fc                   	cld    
  8009a7:	f3 ab                	rep stos %eax,%es:(%edi)
  8009a9:	eb 06                	jmp    8009b1 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009ab:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009ae:	fc                   	cld    
  8009af:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009b1:	89 f8                	mov    %edi,%eax
  8009b3:	5b                   	pop    %ebx
  8009b4:	5e                   	pop    %esi
  8009b5:	5f                   	pop    %edi
  8009b6:	5d                   	pop    %ebp
  8009b7:	c3                   	ret    

008009b8 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009b8:	55                   	push   %ebp
  8009b9:	89 e5                	mov    %esp,%ebp
  8009bb:	57                   	push   %edi
  8009bc:	56                   	push   %esi
  8009bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c0:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009c3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009c6:	39 c6                	cmp    %eax,%esi
  8009c8:	73 33                	jae    8009fd <memmove+0x45>
  8009ca:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009cd:	39 d0                	cmp    %edx,%eax
  8009cf:	73 2c                	jae    8009fd <memmove+0x45>
		s += n;
		d += n;
  8009d1:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009d4:	89 d6                	mov    %edx,%esi
  8009d6:	09 fe                	or     %edi,%esi
  8009d8:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009de:	75 13                	jne    8009f3 <memmove+0x3b>
  8009e0:	f6 c1 03             	test   $0x3,%cl
  8009e3:	75 0e                	jne    8009f3 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8009e5:	83 ef 04             	sub    $0x4,%edi
  8009e8:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009eb:	c1 e9 02             	shr    $0x2,%ecx
  8009ee:	fd                   	std    
  8009ef:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009f1:	eb 07                	jmp    8009fa <memmove+0x42>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009f3:	4f                   	dec    %edi
  8009f4:	8d 72 ff             	lea    -0x1(%edx),%esi
  8009f7:	fd                   	std    
  8009f8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009fa:	fc                   	cld    
  8009fb:	eb 1d                	jmp    800a1a <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009fd:	89 f2                	mov    %esi,%edx
  8009ff:	09 c2                	or     %eax,%edx
  800a01:	f6 c2 03             	test   $0x3,%dl
  800a04:	75 0f                	jne    800a15 <memmove+0x5d>
  800a06:	f6 c1 03             	test   $0x3,%cl
  800a09:	75 0a                	jne    800a15 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
  800a0b:	c1 e9 02             	shr    $0x2,%ecx
  800a0e:	89 c7                	mov    %eax,%edi
  800a10:	fc                   	cld    
  800a11:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a13:	eb 05                	jmp    800a1a <memmove+0x62>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a15:	89 c7                	mov    %eax,%edi
  800a17:	fc                   	cld    
  800a18:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a1a:	5e                   	pop    %esi
  800a1b:	5f                   	pop    %edi
  800a1c:	5d                   	pop    %ebp
  800a1d:	c3                   	ret    

00800a1e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a1e:	55                   	push   %ebp
  800a1f:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a21:	ff 75 10             	pushl  0x10(%ebp)
  800a24:	ff 75 0c             	pushl  0xc(%ebp)
  800a27:	ff 75 08             	pushl  0x8(%ebp)
  800a2a:	e8 89 ff ff ff       	call   8009b8 <memmove>
}
  800a2f:	c9                   	leave  
  800a30:	c3                   	ret    

00800a31 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a31:	55                   	push   %ebp
  800a32:	89 e5                	mov    %esp,%ebp
  800a34:	57                   	push   %edi
  800a35:	56                   	push   %esi
  800a36:	53                   	push   %ebx
  800a37:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800a3a:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a3d:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a40:	85 c0                	test   %eax,%eax
  800a42:	74 33                	je     800a77 <memcmp+0x46>
  800a44:	8d 78 ff             	lea    -0x1(%eax),%edi
		if (*s1 != *s2)
  800a47:	8a 13                	mov    (%ebx),%dl
  800a49:	8a 0e                	mov    (%esi),%cl
  800a4b:	38 ca                	cmp    %cl,%dl
  800a4d:	75 13                	jne    800a62 <memcmp+0x31>
  800a4f:	b8 00 00 00 00       	mov    $0x0,%eax
  800a54:	eb 16                	jmp    800a6c <memcmp+0x3b>
  800a56:	8a 54 03 01          	mov    0x1(%ebx,%eax,1),%dl
  800a5a:	40                   	inc    %eax
  800a5b:	8a 0c 06             	mov    (%esi,%eax,1),%cl
  800a5e:	38 ca                	cmp    %cl,%dl
  800a60:	74 0a                	je     800a6c <memcmp+0x3b>
			return (int) *s1 - (int) *s2;
  800a62:	0f b6 c2             	movzbl %dl,%eax
  800a65:	0f b6 c9             	movzbl %cl,%ecx
  800a68:	29 c8                	sub    %ecx,%eax
  800a6a:	eb 10                	jmp    800a7c <memcmp+0x4b>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a6c:	39 f8                	cmp    %edi,%eax
  800a6e:	75 e6                	jne    800a56 <memcmp+0x25>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a70:	b8 00 00 00 00       	mov    $0x0,%eax
  800a75:	eb 05                	jmp    800a7c <memcmp+0x4b>
  800a77:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a7c:	5b                   	pop    %ebx
  800a7d:	5e                   	pop    %esi
  800a7e:	5f                   	pop    %edi
  800a7f:	5d                   	pop    %ebp
  800a80:	c3                   	ret    

00800a81 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a81:	55                   	push   %ebp
  800a82:	89 e5                	mov    %esp,%ebp
  800a84:	53                   	push   %ebx
  800a85:	8b 55 08             	mov    0x8(%ebp),%edx
	const void *ends = (const char *) s + n;
  800a88:	89 d0                	mov    %edx,%eax
  800a8a:	03 45 10             	add    0x10(%ebp),%eax
	for (; s < ends; s++)
  800a8d:	39 c2                	cmp    %eax,%edx
  800a8f:	73 1b                	jae    800aac <memfind+0x2b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a91:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
  800a95:	0f b6 0a             	movzbl (%edx),%ecx
  800a98:	39 d9                	cmp    %ebx,%ecx
  800a9a:	75 09                	jne    800aa5 <memfind+0x24>
  800a9c:	eb 12                	jmp    800ab0 <memfind+0x2f>
  800a9e:	0f b6 0a             	movzbl (%edx),%ecx
  800aa1:	39 d9                	cmp    %ebx,%ecx
  800aa3:	74 0f                	je     800ab4 <memfind+0x33>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800aa5:	42                   	inc    %edx
  800aa6:	39 d0                	cmp    %edx,%eax
  800aa8:	75 f4                	jne    800a9e <memfind+0x1d>
  800aaa:	eb 0a                	jmp    800ab6 <memfind+0x35>
  800aac:	89 d0                	mov    %edx,%eax
  800aae:	eb 06                	jmp    800ab6 <memfind+0x35>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ab0:	89 d0                	mov    %edx,%eax
  800ab2:	eb 02                	jmp    800ab6 <memfind+0x35>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ab4:	89 d0                	mov    %edx,%eax
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ab6:	5b                   	pop    %ebx
  800ab7:	5d                   	pop    %ebp
  800ab8:	c3                   	ret    

00800ab9 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ab9:	55                   	push   %ebp
  800aba:	89 e5                	mov    %esp,%ebp
  800abc:	57                   	push   %edi
  800abd:	56                   	push   %esi
  800abe:	53                   	push   %ebx
  800abf:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ac2:	eb 01                	jmp    800ac5 <strtol+0xc>
		s++;
  800ac4:	41                   	inc    %ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ac5:	8a 01                	mov    (%ecx),%al
  800ac7:	3c 20                	cmp    $0x20,%al
  800ac9:	74 f9                	je     800ac4 <strtol+0xb>
  800acb:	3c 09                	cmp    $0x9,%al
  800acd:	74 f5                	je     800ac4 <strtol+0xb>
		s++;

	// plus/minus sign
	if (*s == '+')
  800acf:	3c 2b                	cmp    $0x2b,%al
  800ad1:	75 08                	jne    800adb <strtol+0x22>
		s++;
  800ad3:	41                   	inc    %ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ad4:	bf 00 00 00 00       	mov    $0x0,%edi
  800ad9:	eb 11                	jmp    800aec <strtol+0x33>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800adb:	3c 2d                	cmp    $0x2d,%al
  800add:	75 08                	jne    800ae7 <strtol+0x2e>
		s++, neg = 1;
  800adf:	41                   	inc    %ecx
  800ae0:	bf 01 00 00 00       	mov    $0x1,%edi
  800ae5:	eb 05                	jmp    800aec <strtol+0x33>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ae7:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800aec:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800af0:	0f 84 87 00 00 00    	je     800b7d <strtol+0xc4>
  800af6:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  800afa:	75 27                	jne    800b23 <strtol+0x6a>
  800afc:	80 39 30             	cmpb   $0x30,(%ecx)
  800aff:	75 22                	jne    800b23 <strtol+0x6a>
  800b01:	e9 88 00 00 00       	jmp    800b8e <strtol+0xd5>
		s += 2, base = 16;
  800b06:	83 c1 02             	add    $0x2,%ecx
  800b09:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  800b10:	eb 11                	jmp    800b23 <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
  800b12:	41                   	inc    %ecx
  800b13:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  800b1a:	eb 07                	jmp    800b23 <strtol+0x6a>
	else if (base == 0)
		base = 10;
  800b1c:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)
  800b23:	b8 00 00 00 00       	mov    $0x0,%eax

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b28:	8a 11                	mov    (%ecx),%dl
  800b2a:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800b2d:	80 fb 09             	cmp    $0x9,%bl
  800b30:	77 08                	ja     800b3a <strtol+0x81>
			dig = *s - '0';
  800b32:	0f be d2             	movsbl %dl,%edx
  800b35:	83 ea 30             	sub    $0x30,%edx
  800b38:	eb 22                	jmp    800b5c <strtol+0xa3>
		else if (*s >= 'a' && *s <= 'z')
  800b3a:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b3d:	89 f3                	mov    %esi,%ebx
  800b3f:	80 fb 19             	cmp    $0x19,%bl
  800b42:	77 08                	ja     800b4c <strtol+0x93>
			dig = *s - 'a' + 10;
  800b44:	0f be d2             	movsbl %dl,%edx
  800b47:	83 ea 57             	sub    $0x57,%edx
  800b4a:	eb 10                	jmp    800b5c <strtol+0xa3>
		else if (*s >= 'A' && *s <= 'Z')
  800b4c:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b4f:	89 f3                	mov    %esi,%ebx
  800b51:	80 fb 19             	cmp    $0x19,%bl
  800b54:	77 14                	ja     800b6a <strtol+0xb1>
			dig = *s - 'A' + 10;
  800b56:	0f be d2             	movsbl %dl,%edx
  800b59:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b5c:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b5f:	7d 09                	jge    800b6a <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800b61:	41                   	inc    %ecx
  800b62:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b66:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b68:	eb be                	jmp    800b28 <strtol+0x6f>

	if (endptr)
  800b6a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b6e:	74 05                	je     800b75 <strtol+0xbc>
		*endptr = (char *) s;
  800b70:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b73:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800b75:	85 ff                	test   %edi,%edi
  800b77:	74 21                	je     800b9a <strtol+0xe1>
  800b79:	f7 d8                	neg    %eax
  800b7b:	eb 1d                	jmp    800b9a <strtol+0xe1>
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b7d:	80 39 30             	cmpb   $0x30,(%ecx)
  800b80:	75 9a                	jne    800b1c <strtol+0x63>
  800b82:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b86:	0f 84 7a ff ff ff    	je     800b06 <strtol+0x4d>
  800b8c:	eb 84                	jmp    800b12 <strtol+0x59>
  800b8e:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b92:	0f 84 6e ff ff ff    	je     800b06 <strtol+0x4d>
  800b98:	eb 89                	jmp    800b23 <strtol+0x6a>
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
}
  800b9a:	5b                   	pop    %ebx
  800b9b:	5e                   	pop    %esi
  800b9c:	5f                   	pop    %edi
  800b9d:	5d                   	pop    %ebp
  800b9e:	c3                   	ret    

00800b9f <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b9f:	55                   	push   %ebp
  800ba0:	89 e5                	mov    %esp,%ebp
  800ba2:	57                   	push   %edi
  800ba3:	56                   	push   %esi
  800ba4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba5:	b8 00 00 00 00       	mov    $0x0,%eax
  800baa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bad:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb0:	89 c3                	mov    %eax,%ebx
  800bb2:	89 c7                	mov    %eax,%edi
  800bb4:	89 c6                	mov    %eax,%esi
  800bb6:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bb8:	5b                   	pop    %ebx
  800bb9:	5e                   	pop    %esi
  800bba:	5f                   	pop    %edi
  800bbb:	5d                   	pop    %ebp
  800bbc:	c3                   	ret    

00800bbd <sys_cgetc>:

int
sys_cgetc(void)
{
  800bbd:	55                   	push   %ebp
  800bbe:	89 e5                	mov    %esp,%ebp
  800bc0:	57                   	push   %edi
  800bc1:	56                   	push   %esi
  800bc2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc3:	ba 00 00 00 00       	mov    $0x0,%edx
  800bc8:	b8 01 00 00 00       	mov    $0x1,%eax
  800bcd:	89 d1                	mov    %edx,%ecx
  800bcf:	89 d3                	mov    %edx,%ebx
  800bd1:	89 d7                	mov    %edx,%edi
  800bd3:	89 d6                	mov    %edx,%esi
  800bd5:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bd7:	5b                   	pop    %ebx
  800bd8:	5e                   	pop    %esi
  800bd9:	5f                   	pop    %edi
  800bda:	5d                   	pop    %ebp
  800bdb:	c3                   	ret    

00800bdc <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bdc:	55                   	push   %ebp
  800bdd:	89 e5                	mov    %esp,%ebp
  800bdf:	57                   	push   %edi
  800be0:	56                   	push   %esi
  800be1:	53                   	push   %ebx
  800be2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be5:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bea:	b8 03 00 00 00       	mov    $0x3,%eax
  800bef:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf2:	89 cb                	mov    %ecx,%ebx
  800bf4:	89 cf                	mov    %ecx,%edi
  800bf6:	89 ce                	mov    %ecx,%esi
  800bf8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bfa:	85 c0                	test   %eax,%eax
  800bfc:	7e 17                	jle    800c15 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bfe:	83 ec 0c             	sub    $0xc,%esp
  800c01:	50                   	push   %eax
  800c02:	6a 03                	push   $0x3
  800c04:	68 bf 24 80 00       	push   $0x8024bf
  800c09:	6a 23                	push   $0x23
  800c0b:	68 dc 24 80 00       	push   $0x8024dc
  800c10:	e8 37 11 00 00       	call   801d4c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c15:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c18:	5b                   	pop    %ebx
  800c19:	5e                   	pop    %esi
  800c1a:	5f                   	pop    %edi
  800c1b:	5d                   	pop    %ebp
  800c1c:	c3                   	ret    

00800c1d <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c1d:	55                   	push   %ebp
  800c1e:	89 e5                	mov    %esp,%ebp
  800c20:	57                   	push   %edi
  800c21:	56                   	push   %esi
  800c22:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c23:	ba 00 00 00 00       	mov    $0x0,%edx
  800c28:	b8 02 00 00 00       	mov    $0x2,%eax
  800c2d:	89 d1                	mov    %edx,%ecx
  800c2f:	89 d3                	mov    %edx,%ebx
  800c31:	89 d7                	mov    %edx,%edi
  800c33:	89 d6                	mov    %edx,%esi
  800c35:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c37:	5b                   	pop    %ebx
  800c38:	5e                   	pop    %esi
  800c39:	5f                   	pop    %edi
  800c3a:	5d                   	pop    %ebp
  800c3b:	c3                   	ret    

00800c3c <sys_yield>:

void
sys_yield(void)
{
  800c3c:	55                   	push   %ebp
  800c3d:	89 e5                	mov    %esp,%ebp
  800c3f:	57                   	push   %edi
  800c40:	56                   	push   %esi
  800c41:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c42:	ba 00 00 00 00       	mov    $0x0,%edx
  800c47:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c4c:	89 d1                	mov    %edx,%ecx
  800c4e:	89 d3                	mov    %edx,%ebx
  800c50:	89 d7                	mov    %edx,%edi
  800c52:	89 d6                	mov    %edx,%esi
  800c54:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c56:	5b                   	pop    %ebx
  800c57:	5e                   	pop    %esi
  800c58:	5f                   	pop    %edi
  800c59:	5d                   	pop    %ebp
  800c5a:	c3                   	ret    

00800c5b <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c5b:	55                   	push   %ebp
  800c5c:	89 e5                	mov    %esp,%ebp
  800c5e:	57                   	push   %edi
  800c5f:	56                   	push   %esi
  800c60:	53                   	push   %ebx
  800c61:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c64:	be 00 00 00 00       	mov    $0x0,%esi
  800c69:	b8 04 00 00 00       	mov    $0x4,%eax
  800c6e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c71:	8b 55 08             	mov    0x8(%ebp),%edx
  800c74:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c77:	89 f7                	mov    %esi,%edi
  800c79:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c7b:	85 c0                	test   %eax,%eax
  800c7d:	7e 17                	jle    800c96 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c7f:	83 ec 0c             	sub    $0xc,%esp
  800c82:	50                   	push   %eax
  800c83:	6a 04                	push   $0x4
  800c85:	68 bf 24 80 00       	push   $0x8024bf
  800c8a:	6a 23                	push   $0x23
  800c8c:	68 dc 24 80 00       	push   $0x8024dc
  800c91:	e8 b6 10 00 00       	call   801d4c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c96:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c99:	5b                   	pop    %ebx
  800c9a:	5e                   	pop    %esi
  800c9b:	5f                   	pop    %edi
  800c9c:	5d                   	pop    %ebp
  800c9d:	c3                   	ret    

00800c9e <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c9e:	55                   	push   %ebp
  800c9f:	89 e5                	mov    %esp,%ebp
  800ca1:	57                   	push   %edi
  800ca2:	56                   	push   %esi
  800ca3:	53                   	push   %ebx
  800ca4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca7:	b8 05 00 00 00       	mov    $0x5,%eax
  800cac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800caf:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cb5:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cb8:	8b 75 18             	mov    0x18(%ebp),%esi
  800cbb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cbd:	85 c0                	test   %eax,%eax
  800cbf:	7e 17                	jle    800cd8 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc1:	83 ec 0c             	sub    $0xc,%esp
  800cc4:	50                   	push   %eax
  800cc5:	6a 05                	push   $0x5
  800cc7:	68 bf 24 80 00       	push   $0x8024bf
  800ccc:	6a 23                	push   $0x23
  800cce:	68 dc 24 80 00       	push   $0x8024dc
  800cd3:	e8 74 10 00 00       	call   801d4c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800cd8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cdb:	5b                   	pop    %ebx
  800cdc:	5e                   	pop    %esi
  800cdd:	5f                   	pop    %edi
  800cde:	5d                   	pop    %ebp
  800cdf:	c3                   	ret    

00800ce0 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800ce0:	55                   	push   %ebp
  800ce1:	89 e5                	mov    %esp,%ebp
  800ce3:	57                   	push   %edi
  800ce4:	56                   	push   %esi
  800ce5:	53                   	push   %ebx
  800ce6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cee:	b8 06 00 00 00       	mov    $0x6,%eax
  800cf3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf6:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf9:	89 df                	mov    %ebx,%edi
  800cfb:	89 de                	mov    %ebx,%esi
  800cfd:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cff:	85 c0                	test   %eax,%eax
  800d01:	7e 17                	jle    800d1a <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d03:	83 ec 0c             	sub    $0xc,%esp
  800d06:	50                   	push   %eax
  800d07:	6a 06                	push   $0x6
  800d09:	68 bf 24 80 00       	push   $0x8024bf
  800d0e:	6a 23                	push   $0x23
  800d10:	68 dc 24 80 00       	push   $0x8024dc
  800d15:	e8 32 10 00 00       	call   801d4c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d1a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d1d:	5b                   	pop    %ebx
  800d1e:	5e                   	pop    %esi
  800d1f:	5f                   	pop    %edi
  800d20:	5d                   	pop    %ebp
  800d21:	c3                   	ret    

00800d22 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d22:	55                   	push   %ebp
  800d23:	89 e5                	mov    %esp,%ebp
  800d25:	57                   	push   %edi
  800d26:	56                   	push   %esi
  800d27:	53                   	push   %ebx
  800d28:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d2b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d30:	b8 08 00 00 00       	mov    $0x8,%eax
  800d35:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d38:	8b 55 08             	mov    0x8(%ebp),%edx
  800d3b:	89 df                	mov    %ebx,%edi
  800d3d:	89 de                	mov    %ebx,%esi
  800d3f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d41:	85 c0                	test   %eax,%eax
  800d43:	7e 17                	jle    800d5c <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d45:	83 ec 0c             	sub    $0xc,%esp
  800d48:	50                   	push   %eax
  800d49:	6a 08                	push   $0x8
  800d4b:	68 bf 24 80 00       	push   $0x8024bf
  800d50:	6a 23                	push   $0x23
  800d52:	68 dc 24 80 00       	push   $0x8024dc
  800d57:	e8 f0 0f 00 00       	call   801d4c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d5c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d5f:	5b                   	pop    %ebx
  800d60:	5e                   	pop    %esi
  800d61:	5f                   	pop    %edi
  800d62:	5d                   	pop    %ebp
  800d63:	c3                   	ret    

00800d64 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d64:	55                   	push   %ebp
  800d65:	89 e5                	mov    %esp,%ebp
  800d67:	57                   	push   %edi
  800d68:	56                   	push   %esi
  800d69:	53                   	push   %ebx
  800d6a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d6d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d72:	b8 09 00 00 00       	mov    $0x9,%eax
  800d77:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d7a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d7d:	89 df                	mov    %ebx,%edi
  800d7f:	89 de                	mov    %ebx,%esi
  800d81:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d83:	85 c0                	test   %eax,%eax
  800d85:	7e 17                	jle    800d9e <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d87:	83 ec 0c             	sub    $0xc,%esp
  800d8a:	50                   	push   %eax
  800d8b:	6a 09                	push   $0x9
  800d8d:	68 bf 24 80 00       	push   $0x8024bf
  800d92:	6a 23                	push   $0x23
  800d94:	68 dc 24 80 00       	push   $0x8024dc
  800d99:	e8 ae 0f 00 00       	call   801d4c <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d9e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800da1:	5b                   	pop    %ebx
  800da2:	5e                   	pop    %esi
  800da3:	5f                   	pop    %edi
  800da4:	5d                   	pop    %ebp
  800da5:	c3                   	ret    

00800da6 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800da6:	55                   	push   %ebp
  800da7:	89 e5                	mov    %esp,%ebp
  800da9:	57                   	push   %edi
  800daa:	56                   	push   %esi
  800dab:	53                   	push   %ebx
  800dac:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800daf:	bb 00 00 00 00       	mov    $0x0,%ebx
  800db4:	b8 0a 00 00 00       	mov    $0xa,%eax
  800db9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dbc:	8b 55 08             	mov    0x8(%ebp),%edx
  800dbf:	89 df                	mov    %ebx,%edi
  800dc1:	89 de                	mov    %ebx,%esi
  800dc3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dc5:	85 c0                	test   %eax,%eax
  800dc7:	7e 17                	jle    800de0 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dc9:	83 ec 0c             	sub    $0xc,%esp
  800dcc:	50                   	push   %eax
  800dcd:	6a 0a                	push   $0xa
  800dcf:	68 bf 24 80 00       	push   $0x8024bf
  800dd4:	6a 23                	push   $0x23
  800dd6:	68 dc 24 80 00       	push   $0x8024dc
  800ddb:	e8 6c 0f 00 00       	call   801d4c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800de0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800de3:	5b                   	pop    %ebx
  800de4:	5e                   	pop    %esi
  800de5:	5f                   	pop    %edi
  800de6:	5d                   	pop    %ebp
  800de7:	c3                   	ret    

00800de8 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800de8:	55                   	push   %ebp
  800de9:	89 e5                	mov    %esp,%ebp
  800deb:	57                   	push   %edi
  800dec:	56                   	push   %esi
  800ded:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dee:	be 00 00 00 00       	mov    $0x0,%esi
  800df3:	b8 0c 00 00 00       	mov    $0xc,%eax
  800df8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dfb:	8b 55 08             	mov    0x8(%ebp),%edx
  800dfe:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e01:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e04:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e06:	5b                   	pop    %ebx
  800e07:	5e                   	pop    %esi
  800e08:	5f                   	pop    %edi
  800e09:	5d                   	pop    %ebp
  800e0a:	c3                   	ret    

00800e0b <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e0b:	55                   	push   %ebp
  800e0c:	89 e5                	mov    %esp,%ebp
  800e0e:	57                   	push   %edi
  800e0f:	56                   	push   %esi
  800e10:	53                   	push   %ebx
  800e11:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e14:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e19:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e1e:	8b 55 08             	mov    0x8(%ebp),%edx
  800e21:	89 cb                	mov    %ecx,%ebx
  800e23:	89 cf                	mov    %ecx,%edi
  800e25:	89 ce                	mov    %ecx,%esi
  800e27:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e29:	85 c0                	test   %eax,%eax
  800e2b:	7e 17                	jle    800e44 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e2d:	83 ec 0c             	sub    $0xc,%esp
  800e30:	50                   	push   %eax
  800e31:	6a 0d                	push   $0xd
  800e33:	68 bf 24 80 00       	push   $0x8024bf
  800e38:	6a 23                	push   $0x23
  800e3a:	68 dc 24 80 00       	push   $0x8024dc
  800e3f:	e8 08 0f 00 00       	call   801d4c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e44:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e47:	5b                   	pop    %ebx
  800e48:	5e                   	pop    %esi
  800e49:	5f                   	pop    %edi
  800e4a:	5d                   	pop    %ebp
  800e4b:	c3                   	ret    

00800e4c <argstart>:
#include <inc/args.h>
#include <inc/string.h>

void
argstart(int *argc, char **argv, struct Argstate *args)
{
  800e4c:	55                   	push   %ebp
  800e4d:	89 e5                	mov    %esp,%ebp
  800e4f:	8b 55 08             	mov    0x8(%ebp),%edx
  800e52:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e55:	8b 45 10             	mov    0x10(%ebp),%eax
	args->argc = argc;
  800e58:	89 10                	mov    %edx,(%eax)
	args->argv = (const char **) argv;
  800e5a:	89 48 04             	mov    %ecx,0x4(%eax)
	args->curarg = (*argc > 1 && argv ? "" : 0);
  800e5d:	83 3a 01             	cmpl   $0x1,(%edx)
  800e60:	7e 0b                	jle    800e6d <argstart+0x21>
  800e62:	85 c9                	test   %ecx,%ecx
  800e64:	74 0e                	je     800e74 <argstart+0x28>
  800e66:	ba 91 21 80 00       	mov    $0x802191,%edx
  800e6b:	eb 0c                	jmp    800e79 <argstart+0x2d>
  800e6d:	ba 00 00 00 00       	mov    $0x0,%edx
  800e72:	eb 05                	jmp    800e79 <argstart+0x2d>
  800e74:	ba 00 00 00 00       	mov    $0x0,%edx
  800e79:	89 50 08             	mov    %edx,0x8(%eax)
	args->argvalue = 0;
  800e7c:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
}
  800e83:	5d                   	pop    %ebp
  800e84:	c3                   	ret    

00800e85 <argnext>:

int
argnext(struct Argstate *args)
{
  800e85:	55                   	push   %ebp
  800e86:	89 e5                	mov    %esp,%ebp
  800e88:	53                   	push   %ebx
  800e89:	83 ec 04             	sub    $0x4,%esp
  800e8c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int arg;

	args->argvalue = 0;
  800e8f:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
  800e96:	8b 43 08             	mov    0x8(%ebx),%eax
  800e99:	85 c0                	test   %eax,%eax
  800e9b:	74 6a                	je     800f07 <argnext+0x82>
		return -1;

	if (!*args->curarg) {
  800e9d:	80 38 00             	cmpb   $0x0,(%eax)
  800ea0:	75 4b                	jne    800eed <argnext+0x68>
		// Need to process the next argument
		// Check for end of argument list
		if (*args->argc == 1
  800ea2:	8b 0b                	mov    (%ebx),%ecx
  800ea4:	83 39 01             	cmpl   $0x1,(%ecx)
  800ea7:	74 50                	je     800ef9 <argnext+0x74>
		    || args->argv[1][0] != '-'
  800ea9:	8b 53 04             	mov    0x4(%ebx),%edx
  800eac:	8b 42 04             	mov    0x4(%edx),%eax
  800eaf:	80 38 2d             	cmpb   $0x2d,(%eax)
  800eb2:	75 45                	jne    800ef9 <argnext+0x74>
		    || args->argv[1][1] == '\0')
  800eb4:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  800eb8:	74 3f                	je     800ef9 <argnext+0x74>
			goto endofargs;
		// Shift arguments down one
		args->curarg = args->argv[1] + 1;
  800eba:	40                   	inc    %eax
  800ebb:	89 43 08             	mov    %eax,0x8(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  800ebe:	83 ec 04             	sub    $0x4,%esp
  800ec1:	8b 01                	mov    (%ecx),%eax
  800ec3:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  800eca:	50                   	push   %eax
  800ecb:	8d 42 08             	lea    0x8(%edx),%eax
  800ece:	50                   	push   %eax
  800ecf:	83 c2 04             	add    $0x4,%edx
  800ed2:	52                   	push   %edx
  800ed3:	e8 e0 fa ff ff       	call   8009b8 <memmove>
		(*args->argc)--;
  800ed8:	8b 03                	mov    (%ebx),%eax
  800eda:	ff 08                	decl   (%eax)
		// Check for "--": end of argument list
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  800edc:	8b 43 08             	mov    0x8(%ebx),%eax
  800edf:	83 c4 10             	add    $0x10,%esp
  800ee2:	80 38 2d             	cmpb   $0x2d,(%eax)
  800ee5:	75 06                	jne    800eed <argnext+0x68>
  800ee7:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  800eeb:	74 0c                	je     800ef9 <argnext+0x74>
			goto endofargs;
	}

	arg = (unsigned char) *args->curarg;
  800eed:	8b 53 08             	mov    0x8(%ebx),%edx
  800ef0:	0f b6 02             	movzbl (%edx),%eax
	args->curarg++;
  800ef3:	42                   	inc    %edx
  800ef4:	89 53 08             	mov    %edx,0x8(%ebx)
	return arg;
  800ef7:	eb 13                	jmp    800f0c <argnext+0x87>

    endofargs:
	args->curarg = 0;
  800ef9:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	return -1;
  800f00:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  800f05:	eb 05                	jmp    800f0c <argnext+0x87>

	args->argvalue = 0;

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
		return -1;
  800f07:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return arg;

    endofargs:
	args->curarg = 0;
	return -1;
}
  800f0c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f0f:	c9                   	leave  
  800f10:	c3                   	ret    

00800f11 <argnextvalue>:
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
}

char *
argnextvalue(struct Argstate *args)
{
  800f11:	55                   	push   %ebp
  800f12:	89 e5                	mov    %esp,%ebp
  800f14:	53                   	push   %ebx
  800f15:	83 ec 04             	sub    $0x4,%esp
  800f18:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (!args->curarg)
  800f1b:	8b 43 08             	mov    0x8(%ebx),%eax
  800f1e:	85 c0                	test   %eax,%eax
  800f20:	74 57                	je     800f79 <argnextvalue+0x68>
		return 0;
	if (*args->curarg) {
  800f22:	80 38 00             	cmpb   $0x0,(%eax)
  800f25:	74 0c                	je     800f33 <argnextvalue+0x22>
		args->argvalue = args->curarg;
  800f27:	89 43 0c             	mov    %eax,0xc(%ebx)
		args->curarg = "";
  800f2a:	c7 43 08 91 21 80 00 	movl   $0x802191,0x8(%ebx)
  800f31:	eb 41                	jmp    800f74 <argnextvalue+0x63>
	} else if (*args->argc > 1) {
  800f33:	8b 13                	mov    (%ebx),%edx
  800f35:	83 3a 01             	cmpl   $0x1,(%edx)
  800f38:	7e 2c                	jle    800f66 <argnextvalue+0x55>
		args->argvalue = args->argv[1];
  800f3a:	8b 43 04             	mov    0x4(%ebx),%eax
  800f3d:	8b 48 04             	mov    0x4(%eax),%ecx
  800f40:	89 4b 0c             	mov    %ecx,0xc(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  800f43:	83 ec 04             	sub    $0x4,%esp
  800f46:	8b 12                	mov    (%edx),%edx
  800f48:	8d 14 95 fc ff ff ff 	lea    -0x4(,%edx,4),%edx
  800f4f:	52                   	push   %edx
  800f50:	8d 50 08             	lea    0x8(%eax),%edx
  800f53:	52                   	push   %edx
  800f54:	83 c0 04             	add    $0x4,%eax
  800f57:	50                   	push   %eax
  800f58:	e8 5b fa ff ff       	call   8009b8 <memmove>
		(*args->argc)--;
  800f5d:	8b 03                	mov    (%ebx),%eax
  800f5f:	ff 08                	decl   (%eax)
  800f61:	83 c4 10             	add    $0x10,%esp
  800f64:	eb 0e                	jmp    800f74 <argnextvalue+0x63>
	} else {
		args->argvalue = 0;
  800f66:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
		args->curarg = 0;
  800f6d:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	}
	return (char*) args->argvalue;
  800f74:	8b 43 0c             	mov    0xc(%ebx),%eax
  800f77:	eb 05                	jmp    800f7e <argnextvalue+0x6d>

char *
argnextvalue(struct Argstate *args)
{
	if (!args->curarg)
		return 0;
  800f79:	b8 00 00 00 00       	mov    $0x0,%eax
	} else {
		args->argvalue = 0;
		args->curarg = 0;
	}
	return (char*) args->argvalue;
}
  800f7e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f81:	c9                   	leave  
  800f82:	c3                   	ret    

00800f83 <argvalue>:
	return -1;
}

char *
argvalue(struct Argstate *args)
{
  800f83:	55                   	push   %ebp
  800f84:	89 e5                	mov    %esp,%ebp
  800f86:	83 ec 08             	sub    $0x8,%esp
  800f89:	8b 4d 08             	mov    0x8(%ebp),%ecx
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  800f8c:	8b 51 0c             	mov    0xc(%ecx),%edx
  800f8f:	89 d0                	mov    %edx,%eax
  800f91:	85 d2                	test   %edx,%edx
  800f93:	75 0c                	jne    800fa1 <argvalue+0x1e>
  800f95:	83 ec 0c             	sub    $0xc,%esp
  800f98:	51                   	push   %ecx
  800f99:	e8 73 ff ff ff       	call   800f11 <argnextvalue>
  800f9e:	83 c4 10             	add    $0x10,%esp
}
  800fa1:	c9                   	leave  
  800fa2:	c3                   	ret    

00800fa3 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800fa3:	55                   	push   %ebp
  800fa4:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800fa6:	8b 45 08             	mov    0x8(%ebp),%eax
  800fa9:	05 00 00 00 30       	add    $0x30000000,%eax
  800fae:	c1 e8 0c             	shr    $0xc,%eax
}
  800fb1:	5d                   	pop    %ebp
  800fb2:	c3                   	ret    

00800fb3 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800fb3:	55                   	push   %ebp
  800fb4:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800fb6:	8b 45 08             	mov    0x8(%ebp),%eax
  800fb9:	05 00 00 00 30       	add    $0x30000000,%eax
  800fbe:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800fc3:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800fc8:	5d                   	pop    %ebp
  800fc9:	c3                   	ret    

00800fca <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800fca:	55                   	push   %ebp
  800fcb:	89 e5                	mov    %esp,%ebp
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800fcd:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  800fd2:	a8 01                	test   $0x1,%al
  800fd4:	74 34                	je     80100a <fd_alloc+0x40>
  800fd6:	a1 00 00 74 ef       	mov    0xef740000,%eax
  800fdb:	a8 01                	test   $0x1,%al
  800fdd:	74 32                	je     801011 <fd_alloc+0x47>
  800fdf:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800fe4:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800fe6:	89 c2                	mov    %eax,%edx
  800fe8:	c1 ea 16             	shr    $0x16,%edx
  800feb:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ff2:	f6 c2 01             	test   $0x1,%dl
  800ff5:	74 1f                	je     801016 <fd_alloc+0x4c>
  800ff7:	89 c2                	mov    %eax,%edx
  800ff9:	c1 ea 0c             	shr    $0xc,%edx
  800ffc:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801003:	f6 c2 01             	test   $0x1,%dl
  801006:	75 1a                	jne    801022 <fd_alloc+0x58>
  801008:	eb 0c                	jmp    801016 <fd_alloc+0x4c>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  80100a:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  80100f:	eb 05                	jmp    801016 <fd_alloc+0x4c>
  801011:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  801016:	8b 45 08             	mov    0x8(%ebp),%eax
  801019:	89 08                	mov    %ecx,(%eax)
			return 0;
  80101b:	b8 00 00 00 00       	mov    $0x0,%eax
  801020:	eb 1a                	jmp    80103c <fd_alloc+0x72>
  801022:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801027:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80102c:	75 b6                	jne    800fe4 <fd_alloc+0x1a>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80102e:	8b 45 08             	mov    0x8(%ebp),%eax
  801031:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  801037:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80103c:	5d                   	pop    %ebp
  80103d:	c3                   	ret    

0080103e <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80103e:	55                   	push   %ebp
  80103f:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801041:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
  801045:	77 39                	ja     801080 <fd_lookup+0x42>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801047:	8b 45 08             	mov    0x8(%ebp),%eax
  80104a:	c1 e0 0c             	shl    $0xc,%eax
  80104d:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801052:	89 c2                	mov    %eax,%edx
  801054:	c1 ea 16             	shr    $0x16,%edx
  801057:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80105e:	f6 c2 01             	test   $0x1,%dl
  801061:	74 24                	je     801087 <fd_lookup+0x49>
  801063:	89 c2                	mov    %eax,%edx
  801065:	c1 ea 0c             	shr    $0xc,%edx
  801068:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80106f:	f6 c2 01             	test   $0x1,%dl
  801072:	74 1a                	je     80108e <fd_lookup+0x50>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801074:	8b 55 0c             	mov    0xc(%ebp),%edx
  801077:	89 02                	mov    %eax,(%edx)
	return 0;
  801079:	b8 00 00 00 00       	mov    $0x0,%eax
  80107e:	eb 13                	jmp    801093 <fd_lookup+0x55>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801080:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801085:	eb 0c                	jmp    801093 <fd_lookup+0x55>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801087:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80108c:	eb 05                	jmp    801093 <fd_lookup+0x55>
  80108e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801093:	5d                   	pop    %ebp
  801094:	c3                   	ret    

00801095 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801095:	55                   	push   %ebp
  801096:	89 e5                	mov    %esp,%ebp
  801098:	53                   	push   %ebx
  801099:	83 ec 04             	sub    $0x4,%esp
  80109c:	8b 45 08             	mov    0x8(%ebp),%eax
  80109f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  8010a2:	3b 05 04 30 80 00    	cmp    0x803004,%eax
  8010a8:	75 1e                	jne    8010c8 <dev_lookup+0x33>
  8010aa:	eb 0e                	jmp    8010ba <dev_lookup+0x25>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8010ac:	b8 20 30 80 00       	mov    $0x803020,%eax
  8010b1:	eb 0c                	jmp    8010bf <dev_lookup+0x2a>
  8010b3:	b8 3c 30 80 00       	mov    $0x80303c,%eax
  8010b8:	eb 05                	jmp    8010bf <dev_lookup+0x2a>
  8010ba:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  8010bf:	89 03                	mov    %eax,(%ebx)
			return 0;
  8010c1:	b8 00 00 00 00       	mov    $0x0,%eax
  8010c6:	eb 36                	jmp    8010fe <dev_lookup+0x69>
int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  8010c8:	3b 05 20 30 80 00    	cmp    0x803020,%eax
  8010ce:	74 dc                	je     8010ac <dev_lookup+0x17>
  8010d0:	3b 05 3c 30 80 00    	cmp    0x80303c,%eax
  8010d6:	74 db                	je     8010b3 <dev_lookup+0x1e>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8010d8:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8010de:	8b 52 48             	mov    0x48(%edx),%edx
  8010e1:	83 ec 04             	sub    $0x4,%esp
  8010e4:	50                   	push   %eax
  8010e5:	52                   	push   %edx
  8010e6:	68 ec 24 80 00       	push   $0x8024ec
  8010eb:	e8 16 f1 ff ff       	call   800206 <cprintf>
	*dev = 0;
  8010f0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  8010f6:	83 c4 10             	add    $0x10,%esp
  8010f9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8010fe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801101:	c9                   	leave  
  801102:	c3                   	ret    

00801103 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801103:	55                   	push   %ebp
  801104:	89 e5                	mov    %esp,%ebp
  801106:	56                   	push   %esi
  801107:	53                   	push   %ebx
  801108:	83 ec 10             	sub    $0x10,%esp
  80110b:	8b 75 08             	mov    0x8(%ebp),%esi
  80110e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801111:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801114:	50                   	push   %eax
  801115:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80111b:	c1 e8 0c             	shr    $0xc,%eax
  80111e:	50                   	push   %eax
  80111f:	e8 1a ff ff ff       	call   80103e <fd_lookup>
  801124:	83 c4 08             	add    $0x8,%esp
  801127:	85 c0                	test   %eax,%eax
  801129:	78 05                	js     801130 <fd_close+0x2d>
	    || fd != fd2)
  80112b:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80112e:	74 06                	je     801136 <fd_close+0x33>
		return (must_exist ? r : 0);
  801130:	84 db                	test   %bl,%bl
  801132:	74 47                	je     80117b <fd_close+0x78>
  801134:	eb 4a                	jmp    801180 <fd_close+0x7d>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801136:	83 ec 08             	sub    $0x8,%esp
  801139:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80113c:	50                   	push   %eax
  80113d:	ff 36                	pushl  (%esi)
  80113f:	e8 51 ff ff ff       	call   801095 <dev_lookup>
  801144:	89 c3                	mov    %eax,%ebx
  801146:	83 c4 10             	add    $0x10,%esp
  801149:	85 c0                	test   %eax,%eax
  80114b:	78 1c                	js     801169 <fd_close+0x66>
		if (dev->dev_close)
  80114d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801150:	8b 40 10             	mov    0x10(%eax),%eax
  801153:	85 c0                	test   %eax,%eax
  801155:	74 0d                	je     801164 <fd_close+0x61>
			r = (*dev->dev_close)(fd);
  801157:	83 ec 0c             	sub    $0xc,%esp
  80115a:	56                   	push   %esi
  80115b:	ff d0                	call   *%eax
  80115d:	89 c3                	mov    %eax,%ebx
  80115f:	83 c4 10             	add    $0x10,%esp
  801162:	eb 05                	jmp    801169 <fd_close+0x66>
		else
			r = 0;
  801164:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801169:	83 ec 08             	sub    $0x8,%esp
  80116c:	56                   	push   %esi
  80116d:	6a 00                	push   $0x0
  80116f:	e8 6c fb ff ff       	call   800ce0 <sys_page_unmap>
	return r;
  801174:	83 c4 10             	add    $0x10,%esp
  801177:	89 d8                	mov    %ebx,%eax
  801179:	eb 05                	jmp    801180 <fd_close+0x7d>
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
  80117b:	b8 00 00 00 00       	mov    $0x0,%eax
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
	return r;
}
  801180:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801183:	5b                   	pop    %ebx
  801184:	5e                   	pop    %esi
  801185:	5d                   	pop    %ebp
  801186:	c3                   	ret    

00801187 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801187:	55                   	push   %ebp
  801188:	89 e5                	mov    %esp,%ebp
  80118a:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80118d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801190:	50                   	push   %eax
  801191:	ff 75 08             	pushl  0x8(%ebp)
  801194:	e8 a5 fe ff ff       	call   80103e <fd_lookup>
  801199:	83 c4 08             	add    $0x8,%esp
  80119c:	85 c0                	test   %eax,%eax
  80119e:	78 10                	js     8011b0 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8011a0:	83 ec 08             	sub    $0x8,%esp
  8011a3:	6a 01                	push   $0x1
  8011a5:	ff 75 f4             	pushl  -0xc(%ebp)
  8011a8:	e8 56 ff ff ff       	call   801103 <fd_close>
  8011ad:	83 c4 10             	add    $0x10,%esp
}
  8011b0:	c9                   	leave  
  8011b1:	c3                   	ret    

008011b2 <close_all>:

void
close_all(void)
{
  8011b2:	55                   	push   %ebp
  8011b3:	89 e5                	mov    %esp,%ebp
  8011b5:	53                   	push   %ebx
  8011b6:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8011b9:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8011be:	83 ec 0c             	sub    $0xc,%esp
  8011c1:	53                   	push   %ebx
  8011c2:	e8 c0 ff ff ff       	call   801187 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8011c7:	43                   	inc    %ebx
  8011c8:	83 c4 10             	add    $0x10,%esp
  8011cb:	83 fb 20             	cmp    $0x20,%ebx
  8011ce:	75 ee                	jne    8011be <close_all+0xc>
		close(i);
}
  8011d0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011d3:	c9                   	leave  
  8011d4:	c3                   	ret    

008011d5 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8011d5:	55                   	push   %ebp
  8011d6:	89 e5                	mov    %esp,%ebp
  8011d8:	57                   	push   %edi
  8011d9:	56                   	push   %esi
  8011da:	53                   	push   %ebx
  8011db:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8011de:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8011e1:	50                   	push   %eax
  8011e2:	ff 75 08             	pushl  0x8(%ebp)
  8011e5:	e8 54 fe ff ff       	call   80103e <fd_lookup>
  8011ea:	83 c4 08             	add    $0x8,%esp
  8011ed:	85 c0                	test   %eax,%eax
  8011ef:	0f 88 c2 00 00 00    	js     8012b7 <dup+0xe2>
		return r;
	close(newfdnum);
  8011f5:	83 ec 0c             	sub    $0xc,%esp
  8011f8:	ff 75 0c             	pushl  0xc(%ebp)
  8011fb:	e8 87 ff ff ff       	call   801187 <close>

	newfd = INDEX2FD(newfdnum);
  801200:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801203:	c1 e3 0c             	shl    $0xc,%ebx
  801206:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80120c:	83 c4 04             	add    $0x4,%esp
  80120f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801212:	e8 9c fd ff ff       	call   800fb3 <fd2data>
  801217:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  801219:	89 1c 24             	mov    %ebx,(%esp)
  80121c:	e8 92 fd ff ff       	call   800fb3 <fd2data>
  801221:	83 c4 10             	add    $0x10,%esp
  801224:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801226:	89 f0                	mov    %esi,%eax
  801228:	c1 e8 16             	shr    $0x16,%eax
  80122b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801232:	a8 01                	test   $0x1,%al
  801234:	74 35                	je     80126b <dup+0x96>
  801236:	89 f0                	mov    %esi,%eax
  801238:	c1 e8 0c             	shr    $0xc,%eax
  80123b:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801242:	f6 c2 01             	test   $0x1,%dl
  801245:	74 24                	je     80126b <dup+0x96>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801247:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80124e:	83 ec 0c             	sub    $0xc,%esp
  801251:	25 07 0e 00 00       	and    $0xe07,%eax
  801256:	50                   	push   %eax
  801257:	57                   	push   %edi
  801258:	6a 00                	push   $0x0
  80125a:	56                   	push   %esi
  80125b:	6a 00                	push   $0x0
  80125d:	e8 3c fa ff ff       	call   800c9e <sys_page_map>
  801262:	89 c6                	mov    %eax,%esi
  801264:	83 c4 20             	add    $0x20,%esp
  801267:	85 c0                	test   %eax,%eax
  801269:	78 2c                	js     801297 <dup+0xc2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80126b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80126e:	89 d0                	mov    %edx,%eax
  801270:	c1 e8 0c             	shr    $0xc,%eax
  801273:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80127a:	83 ec 0c             	sub    $0xc,%esp
  80127d:	25 07 0e 00 00       	and    $0xe07,%eax
  801282:	50                   	push   %eax
  801283:	53                   	push   %ebx
  801284:	6a 00                	push   $0x0
  801286:	52                   	push   %edx
  801287:	6a 00                	push   $0x0
  801289:	e8 10 fa ff ff       	call   800c9e <sys_page_map>
  80128e:	89 c6                	mov    %eax,%esi
  801290:	83 c4 20             	add    $0x20,%esp
  801293:	85 c0                	test   %eax,%eax
  801295:	79 1d                	jns    8012b4 <dup+0xdf>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801297:	83 ec 08             	sub    $0x8,%esp
  80129a:	53                   	push   %ebx
  80129b:	6a 00                	push   $0x0
  80129d:	e8 3e fa ff ff       	call   800ce0 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8012a2:	83 c4 08             	add    $0x8,%esp
  8012a5:	57                   	push   %edi
  8012a6:	6a 00                	push   $0x0
  8012a8:	e8 33 fa ff ff       	call   800ce0 <sys_page_unmap>
	return r;
  8012ad:	83 c4 10             	add    $0x10,%esp
  8012b0:	89 f0                	mov    %esi,%eax
  8012b2:	eb 03                	jmp    8012b7 <dup+0xe2>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  8012b4:	8b 45 0c             	mov    0xc(%ebp),%eax

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8012b7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012ba:	5b                   	pop    %ebx
  8012bb:	5e                   	pop    %esi
  8012bc:	5f                   	pop    %edi
  8012bd:	5d                   	pop    %ebp
  8012be:	c3                   	ret    

008012bf <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8012bf:	55                   	push   %ebp
  8012c0:	89 e5                	mov    %esp,%ebp
  8012c2:	53                   	push   %ebx
  8012c3:	83 ec 14             	sub    $0x14,%esp
  8012c6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012c9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012cc:	50                   	push   %eax
  8012cd:	53                   	push   %ebx
  8012ce:	e8 6b fd ff ff       	call   80103e <fd_lookup>
  8012d3:	83 c4 08             	add    $0x8,%esp
  8012d6:	85 c0                	test   %eax,%eax
  8012d8:	78 67                	js     801341 <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012da:	83 ec 08             	sub    $0x8,%esp
  8012dd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012e0:	50                   	push   %eax
  8012e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012e4:	ff 30                	pushl  (%eax)
  8012e6:	e8 aa fd ff ff       	call   801095 <dev_lookup>
  8012eb:	83 c4 10             	add    $0x10,%esp
  8012ee:	85 c0                	test   %eax,%eax
  8012f0:	78 4f                	js     801341 <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8012f2:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8012f5:	8b 42 08             	mov    0x8(%edx),%eax
  8012f8:	83 e0 03             	and    $0x3,%eax
  8012fb:	83 f8 01             	cmp    $0x1,%eax
  8012fe:	75 21                	jne    801321 <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801300:	a1 04 40 80 00       	mov    0x804004,%eax
  801305:	8b 40 48             	mov    0x48(%eax),%eax
  801308:	83 ec 04             	sub    $0x4,%esp
  80130b:	53                   	push   %ebx
  80130c:	50                   	push   %eax
  80130d:	68 2d 25 80 00       	push   $0x80252d
  801312:	e8 ef ee ff ff       	call   800206 <cprintf>
		return -E_INVAL;
  801317:	83 c4 10             	add    $0x10,%esp
  80131a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80131f:	eb 20                	jmp    801341 <read+0x82>
	}
	if (!dev->dev_read)
  801321:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801324:	8b 40 08             	mov    0x8(%eax),%eax
  801327:	85 c0                	test   %eax,%eax
  801329:	74 11                	je     80133c <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80132b:	83 ec 04             	sub    $0x4,%esp
  80132e:	ff 75 10             	pushl  0x10(%ebp)
  801331:	ff 75 0c             	pushl  0xc(%ebp)
  801334:	52                   	push   %edx
  801335:	ff d0                	call   *%eax
  801337:	83 c4 10             	add    $0x10,%esp
  80133a:	eb 05                	jmp    801341 <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80133c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801341:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801344:	c9                   	leave  
  801345:	c3                   	ret    

00801346 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801346:	55                   	push   %ebp
  801347:	89 e5                	mov    %esp,%ebp
  801349:	57                   	push   %edi
  80134a:	56                   	push   %esi
  80134b:	53                   	push   %ebx
  80134c:	83 ec 0c             	sub    $0xc,%esp
  80134f:	8b 7d 08             	mov    0x8(%ebp),%edi
  801352:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801355:	85 f6                	test   %esi,%esi
  801357:	74 31                	je     80138a <readn+0x44>
  801359:	b8 00 00 00 00       	mov    $0x0,%eax
  80135e:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  801363:	83 ec 04             	sub    $0x4,%esp
  801366:	89 f2                	mov    %esi,%edx
  801368:	29 c2                	sub    %eax,%edx
  80136a:	52                   	push   %edx
  80136b:	03 45 0c             	add    0xc(%ebp),%eax
  80136e:	50                   	push   %eax
  80136f:	57                   	push   %edi
  801370:	e8 4a ff ff ff       	call   8012bf <read>
		if (m < 0)
  801375:	83 c4 10             	add    $0x10,%esp
  801378:	85 c0                	test   %eax,%eax
  80137a:	78 17                	js     801393 <readn+0x4d>
			return m;
		if (m == 0)
  80137c:	85 c0                	test   %eax,%eax
  80137e:	74 11                	je     801391 <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801380:	01 c3                	add    %eax,%ebx
  801382:	89 d8                	mov    %ebx,%eax
  801384:	39 f3                	cmp    %esi,%ebx
  801386:	72 db                	jb     801363 <readn+0x1d>
  801388:	eb 09                	jmp    801393 <readn+0x4d>
  80138a:	b8 00 00 00 00       	mov    $0x0,%eax
  80138f:	eb 02                	jmp    801393 <readn+0x4d>
  801391:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801393:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801396:	5b                   	pop    %ebx
  801397:	5e                   	pop    %esi
  801398:	5f                   	pop    %edi
  801399:	5d                   	pop    %ebp
  80139a:	c3                   	ret    

0080139b <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80139b:	55                   	push   %ebp
  80139c:	89 e5                	mov    %esp,%ebp
  80139e:	53                   	push   %ebx
  80139f:	83 ec 14             	sub    $0x14,%esp
  8013a2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013a5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013a8:	50                   	push   %eax
  8013a9:	53                   	push   %ebx
  8013aa:	e8 8f fc ff ff       	call   80103e <fd_lookup>
  8013af:	83 c4 08             	add    $0x8,%esp
  8013b2:	85 c0                	test   %eax,%eax
  8013b4:	78 62                	js     801418 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013b6:	83 ec 08             	sub    $0x8,%esp
  8013b9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013bc:	50                   	push   %eax
  8013bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013c0:	ff 30                	pushl  (%eax)
  8013c2:	e8 ce fc ff ff       	call   801095 <dev_lookup>
  8013c7:	83 c4 10             	add    $0x10,%esp
  8013ca:	85 c0                	test   %eax,%eax
  8013cc:	78 4a                	js     801418 <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8013ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013d1:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8013d5:	75 21                	jne    8013f8 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8013d7:	a1 04 40 80 00       	mov    0x804004,%eax
  8013dc:	8b 40 48             	mov    0x48(%eax),%eax
  8013df:	83 ec 04             	sub    $0x4,%esp
  8013e2:	53                   	push   %ebx
  8013e3:	50                   	push   %eax
  8013e4:	68 49 25 80 00       	push   $0x802549
  8013e9:	e8 18 ee ff ff       	call   800206 <cprintf>
		return -E_INVAL;
  8013ee:	83 c4 10             	add    $0x10,%esp
  8013f1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013f6:	eb 20                	jmp    801418 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8013f8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8013fb:	8b 52 0c             	mov    0xc(%edx),%edx
  8013fe:	85 d2                	test   %edx,%edx
  801400:	74 11                	je     801413 <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801402:	83 ec 04             	sub    $0x4,%esp
  801405:	ff 75 10             	pushl  0x10(%ebp)
  801408:	ff 75 0c             	pushl  0xc(%ebp)
  80140b:	50                   	push   %eax
  80140c:	ff d2                	call   *%edx
  80140e:	83 c4 10             	add    $0x10,%esp
  801411:	eb 05                	jmp    801418 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801413:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801418:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80141b:	c9                   	leave  
  80141c:	c3                   	ret    

0080141d <seek>:

int
seek(int fdnum, off_t offset)
{
  80141d:	55                   	push   %ebp
  80141e:	89 e5                	mov    %esp,%ebp
  801420:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801423:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801426:	50                   	push   %eax
  801427:	ff 75 08             	pushl  0x8(%ebp)
  80142a:	e8 0f fc ff ff       	call   80103e <fd_lookup>
  80142f:	83 c4 08             	add    $0x8,%esp
  801432:	85 c0                	test   %eax,%eax
  801434:	78 0e                	js     801444 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801436:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801439:	8b 55 0c             	mov    0xc(%ebp),%edx
  80143c:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80143f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801444:	c9                   	leave  
  801445:	c3                   	ret    

00801446 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801446:	55                   	push   %ebp
  801447:	89 e5                	mov    %esp,%ebp
  801449:	53                   	push   %ebx
  80144a:	83 ec 14             	sub    $0x14,%esp
  80144d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801450:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801453:	50                   	push   %eax
  801454:	53                   	push   %ebx
  801455:	e8 e4 fb ff ff       	call   80103e <fd_lookup>
  80145a:	83 c4 08             	add    $0x8,%esp
  80145d:	85 c0                	test   %eax,%eax
  80145f:	78 5f                	js     8014c0 <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801461:	83 ec 08             	sub    $0x8,%esp
  801464:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801467:	50                   	push   %eax
  801468:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80146b:	ff 30                	pushl  (%eax)
  80146d:	e8 23 fc ff ff       	call   801095 <dev_lookup>
  801472:	83 c4 10             	add    $0x10,%esp
  801475:	85 c0                	test   %eax,%eax
  801477:	78 47                	js     8014c0 <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801479:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80147c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801480:	75 21                	jne    8014a3 <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801482:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801487:	8b 40 48             	mov    0x48(%eax),%eax
  80148a:	83 ec 04             	sub    $0x4,%esp
  80148d:	53                   	push   %ebx
  80148e:	50                   	push   %eax
  80148f:	68 0c 25 80 00       	push   $0x80250c
  801494:	e8 6d ed ff ff       	call   800206 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801499:	83 c4 10             	add    $0x10,%esp
  80149c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014a1:	eb 1d                	jmp    8014c0 <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  8014a3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014a6:	8b 52 18             	mov    0x18(%edx),%edx
  8014a9:	85 d2                	test   %edx,%edx
  8014ab:	74 0e                	je     8014bb <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8014ad:	83 ec 08             	sub    $0x8,%esp
  8014b0:	ff 75 0c             	pushl  0xc(%ebp)
  8014b3:	50                   	push   %eax
  8014b4:	ff d2                	call   *%edx
  8014b6:	83 c4 10             	add    $0x10,%esp
  8014b9:	eb 05                	jmp    8014c0 <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8014bb:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8014c0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014c3:	c9                   	leave  
  8014c4:	c3                   	ret    

008014c5 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8014c5:	55                   	push   %ebp
  8014c6:	89 e5                	mov    %esp,%ebp
  8014c8:	53                   	push   %ebx
  8014c9:	83 ec 14             	sub    $0x14,%esp
  8014cc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014cf:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014d2:	50                   	push   %eax
  8014d3:	ff 75 08             	pushl  0x8(%ebp)
  8014d6:	e8 63 fb ff ff       	call   80103e <fd_lookup>
  8014db:	83 c4 08             	add    $0x8,%esp
  8014de:	85 c0                	test   %eax,%eax
  8014e0:	78 52                	js     801534 <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014e2:	83 ec 08             	sub    $0x8,%esp
  8014e5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014e8:	50                   	push   %eax
  8014e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014ec:	ff 30                	pushl  (%eax)
  8014ee:	e8 a2 fb ff ff       	call   801095 <dev_lookup>
  8014f3:	83 c4 10             	add    $0x10,%esp
  8014f6:	85 c0                	test   %eax,%eax
  8014f8:	78 3a                	js     801534 <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  8014fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014fd:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801501:	74 2c                	je     80152f <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801503:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801506:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80150d:	00 00 00 
	stat->st_isdir = 0;
  801510:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801517:	00 00 00 
	stat->st_dev = dev;
  80151a:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801520:	83 ec 08             	sub    $0x8,%esp
  801523:	53                   	push   %ebx
  801524:	ff 75 f0             	pushl  -0x10(%ebp)
  801527:	ff 50 14             	call   *0x14(%eax)
  80152a:	83 c4 10             	add    $0x10,%esp
  80152d:	eb 05                	jmp    801534 <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80152f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801534:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801537:	c9                   	leave  
  801538:	c3                   	ret    

00801539 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801539:	55                   	push   %ebp
  80153a:	89 e5                	mov    %esp,%ebp
  80153c:	56                   	push   %esi
  80153d:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80153e:	83 ec 08             	sub    $0x8,%esp
  801541:	6a 00                	push   $0x0
  801543:	ff 75 08             	pushl  0x8(%ebp)
  801546:	e8 75 01 00 00       	call   8016c0 <open>
  80154b:	89 c3                	mov    %eax,%ebx
  80154d:	83 c4 10             	add    $0x10,%esp
  801550:	85 c0                	test   %eax,%eax
  801552:	78 1d                	js     801571 <stat+0x38>
		return fd;
	r = fstat(fd, stat);
  801554:	83 ec 08             	sub    $0x8,%esp
  801557:	ff 75 0c             	pushl  0xc(%ebp)
  80155a:	50                   	push   %eax
  80155b:	e8 65 ff ff ff       	call   8014c5 <fstat>
  801560:	89 c6                	mov    %eax,%esi
	close(fd);
  801562:	89 1c 24             	mov    %ebx,(%esp)
  801565:	e8 1d fc ff ff       	call   801187 <close>
	return r;
  80156a:	83 c4 10             	add    $0x10,%esp
  80156d:	89 f0                	mov    %esi,%eax
  80156f:	eb 00                	jmp    801571 <stat+0x38>
}
  801571:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801574:	5b                   	pop    %ebx
  801575:	5e                   	pop    %esi
  801576:	5d                   	pop    %ebp
  801577:	c3                   	ret    

00801578 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801578:	55                   	push   %ebp
  801579:	89 e5                	mov    %esp,%ebp
  80157b:	56                   	push   %esi
  80157c:	53                   	push   %ebx
  80157d:	89 c6                	mov    %eax,%esi
  80157f:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801581:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801588:	75 12                	jne    80159c <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80158a:	83 ec 0c             	sub    $0xc,%esp
  80158d:	6a 01                	push   $0x1
  80158f:	e8 d2 08 00 00       	call   801e66 <ipc_find_env>
  801594:	a3 00 40 80 00       	mov    %eax,0x804000
  801599:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80159c:	6a 07                	push   $0x7
  80159e:	68 00 50 80 00       	push   $0x805000
  8015a3:	56                   	push   %esi
  8015a4:	ff 35 00 40 80 00    	pushl  0x804000
  8015aa:	e8 58 08 00 00       	call   801e07 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8015af:	83 c4 0c             	add    $0xc,%esp
  8015b2:	6a 00                	push   $0x0
  8015b4:	53                   	push   %ebx
  8015b5:	6a 00                	push   $0x0
  8015b7:	e8 d6 07 00 00       	call   801d92 <ipc_recv>
}
  8015bc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015bf:	5b                   	pop    %ebx
  8015c0:	5e                   	pop    %esi
  8015c1:	5d                   	pop    %ebp
  8015c2:	c3                   	ret    

008015c3 <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8015c3:	55                   	push   %ebp
  8015c4:	89 e5                	mov    %esp,%ebp
  8015c6:	53                   	push   %ebx
  8015c7:	83 ec 04             	sub    $0x4,%esp
  8015ca:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8015cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8015d0:	8b 40 0c             	mov    0xc(%eax),%eax
  8015d3:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8015d8:	ba 00 00 00 00       	mov    $0x0,%edx
  8015dd:	b8 05 00 00 00       	mov    $0x5,%eax
  8015e2:	e8 91 ff ff ff       	call   801578 <fsipc>
  8015e7:	85 c0                	test   %eax,%eax
  8015e9:	78 2c                	js     801617 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8015eb:	83 ec 08             	sub    $0x8,%esp
  8015ee:	68 00 50 80 00       	push   $0x805000
  8015f3:	53                   	push   %ebx
  8015f4:	e8 f2 f1 ff ff       	call   8007eb <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8015f9:	a1 80 50 80 00       	mov    0x805080,%eax
  8015fe:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801604:	a1 84 50 80 00       	mov    0x805084,%eax
  801609:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80160f:	83 c4 10             	add    $0x10,%esp
  801612:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801617:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80161a:	c9                   	leave  
  80161b:	c3                   	ret    

0080161c <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80161c:	55                   	push   %ebp
  80161d:	89 e5                	mov    %esp,%ebp
  80161f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801622:	8b 45 08             	mov    0x8(%ebp),%eax
  801625:	8b 40 0c             	mov    0xc(%eax),%eax
  801628:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80162d:	ba 00 00 00 00       	mov    $0x0,%edx
  801632:	b8 06 00 00 00       	mov    $0x6,%eax
  801637:	e8 3c ff ff ff       	call   801578 <fsipc>
}
  80163c:	c9                   	leave  
  80163d:	c3                   	ret    

0080163e <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80163e:	55                   	push   %ebp
  80163f:	89 e5                	mov    %esp,%ebp
  801641:	56                   	push   %esi
  801642:	53                   	push   %ebx
  801643:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801646:	8b 45 08             	mov    0x8(%ebp),%eax
  801649:	8b 40 0c             	mov    0xc(%eax),%eax
  80164c:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801651:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801657:	ba 00 00 00 00       	mov    $0x0,%edx
  80165c:	b8 03 00 00 00       	mov    $0x3,%eax
  801661:	e8 12 ff ff ff       	call   801578 <fsipc>
  801666:	89 c3                	mov    %eax,%ebx
  801668:	85 c0                	test   %eax,%eax
  80166a:	78 4b                	js     8016b7 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80166c:	39 c6                	cmp    %eax,%esi
  80166e:	73 16                	jae    801686 <devfile_read+0x48>
  801670:	68 66 25 80 00       	push   $0x802566
  801675:	68 6d 25 80 00       	push   $0x80256d
  80167a:	6a 7a                	push   $0x7a
  80167c:	68 82 25 80 00       	push   $0x802582
  801681:	e8 c6 06 00 00       	call   801d4c <_panic>
	assert(r <= PGSIZE);
  801686:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80168b:	7e 16                	jle    8016a3 <devfile_read+0x65>
  80168d:	68 8d 25 80 00       	push   $0x80258d
  801692:	68 6d 25 80 00       	push   $0x80256d
  801697:	6a 7b                	push   $0x7b
  801699:	68 82 25 80 00       	push   $0x802582
  80169e:	e8 a9 06 00 00       	call   801d4c <_panic>
	memmove(buf, &fsipcbuf, r);
  8016a3:	83 ec 04             	sub    $0x4,%esp
  8016a6:	50                   	push   %eax
  8016a7:	68 00 50 80 00       	push   $0x805000
  8016ac:	ff 75 0c             	pushl  0xc(%ebp)
  8016af:	e8 04 f3 ff ff       	call   8009b8 <memmove>
	return r;
  8016b4:	83 c4 10             	add    $0x10,%esp
}
  8016b7:	89 d8                	mov    %ebx,%eax
  8016b9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016bc:	5b                   	pop    %ebx
  8016bd:	5e                   	pop    %esi
  8016be:	5d                   	pop    %ebp
  8016bf:	c3                   	ret    

008016c0 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8016c0:	55                   	push   %ebp
  8016c1:	89 e5                	mov    %esp,%ebp
  8016c3:	53                   	push   %ebx
  8016c4:	83 ec 20             	sub    $0x20,%esp
  8016c7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8016ca:	53                   	push   %ebx
  8016cb:	e8 c4 f0 ff ff       	call   800794 <strlen>
  8016d0:	83 c4 10             	add    $0x10,%esp
  8016d3:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8016d8:	7f 63                	jg     80173d <open+0x7d>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8016da:	83 ec 0c             	sub    $0xc,%esp
  8016dd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016e0:	50                   	push   %eax
  8016e1:	e8 e4 f8 ff ff       	call   800fca <fd_alloc>
  8016e6:	83 c4 10             	add    $0x10,%esp
  8016e9:	85 c0                	test   %eax,%eax
  8016eb:	78 55                	js     801742 <open+0x82>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8016ed:	83 ec 08             	sub    $0x8,%esp
  8016f0:	53                   	push   %ebx
  8016f1:	68 00 50 80 00       	push   $0x805000
  8016f6:	e8 f0 f0 ff ff       	call   8007eb <strcpy>
	fsipcbuf.open.req_omode = mode;
  8016fb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016fe:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801703:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801706:	b8 01 00 00 00       	mov    $0x1,%eax
  80170b:	e8 68 fe ff ff       	call   801578 <fsipc>
  801710:	89 c3                	mov    %eax,%ebx
  801712:	83 c4 10             	add    $0x10,%esp
  801715:	85 c0                	test   %eax,%eax
  801717:	79 14                	jns    80172d <open+0x6d>
		fd_close(fd, 0);
  801719:	83 ec 08             	sub    $0x8,%esp
  80171c:	6a 00                	push   $0x0
  80171e:	ff 75 f4             	pushl  -0xc(%ebp)
  801721:	e8 dd f9 ff ff       	call   801103 <fd_close>
		return r;
  801726:	83 c4 10             	add    $0x10,%esp
  801729:	89 d8                	mov    %ebx,%eax
  80172b:	eb 15                	jmp    801742 <open+0x82>
	}

	return fd2num(fd);
  80172d:	83 ec 0c             	sub    $0xc,%esp
  801730:	ff 75 f4             	pushl  -0xc(%ebp)
  801733:	e8 6b f8 ff ff       	call   800fa3 <fd2num>
  801738:	83 c4 10             	add    $0x10,%esp
  80173b:	eb 05                	jmp    801742 <open+0x82>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80173d:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801742:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801745:	c9                   	leave  
  801746:	c3                   	ret    

00801747 <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  801747:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  80174b:	7e 38                	jle    801785 <writebuf+0x3e>
};


static void
writebuf(struct printbuf *b)
{
  80174d:	55                   	push   %ebp
  80174e:	89 e5                	mov    %esp,%ebp
  801750:	53                   	push   %ebx
  801751:	83 ec 08             	sub    $0x8,%esp
  801754:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
		ssize_t result = write(b->fd, b->buf, b->idx);
  801756:	ff 70 04             	pushl  0x4(%eax)
  801759:	8d 40 10             	lea    0x10(%eax),%eax
  80175c:	50                   	push   %eax
  80175d:	ff 33                	pushl  (%ebx)
  80175f:	e8 37 fc ff ff       	call   80139b <write>
		if (result > 0)
  801764:	83 c4 10             	add    $0x10,%esp
  801767:	85 c0                	test   %eax,%eax
  801769:	7e 03                	jle    80176e <writebuf+0x27>
			b->result += result;
  80176b:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  80176e:	3b 43 04             	cmp    0x4(%ebx),%eax
  801771:	74 0e                	je     801781 <writebuf+0x3a>
			b->error = (result < 0 ? result : 0);
  801773:	89 c2                	mov    %eax,%edx
  801775:	85 c0                	test   %eax,%eax
  801777:	7e 05                	jle    80177e <writebuf+0x37>
  801779:	ba 00 00 00 00       	mov    $0x0,%edx
  80177e:	89 53 0c             	mov    %edx,0xc(%ebx)
	}
}
  801781:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801784:	c9                   	leave  
  801785:	c3                   	ret    

00801786 <putch>:

static void
putch(int ch, void *thunk)
{
  801786:	55                   	push   %ebp
  801787:	89 e5                	mov    %esp,%ebp
  801789:	53                   	push   %ebx
  80178a:	83 ec 04             	sub    $0x4,%esp
  80178d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  801790:	8b 53 04             	mov    0x4(%ebx),%edx
  801793:	8d 42 01             	lea    0x1(%edx),%eax
  801796:	89 43 04             	mov    %eax,0x4(%ebx)
  801799:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80179c:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  8017a0:	3d 00 01 00 00       	cmp    $0x100,%eax
  8017a5:	75 0e                	jne    8017b5 <putch+0x2f>
		writebuf(b);
  8017a7:	89 d8                	mov    %ebx,%eax
  8017a9:	e8 99 ff ff ff       	call   801747 <writebuf>
		b->idx = 0;
  8017ae:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  8017b5:	83 c4 04             	add    $0x4,%esp
  8017b8:	5b                   	pop    %ebx
  8017b9:	5d                   	pop    %ebp
  8017ba:	c3                   	ret    

008017bb <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  8017bb:	55                   	push   %ebp
  8017bc:	89 e5                	mov    %esp,%ebp
  8017be:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  8017c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8017c7:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  8017cd:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  8017d4:	00 00 00 
	b.result = 0;
  8017d7:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8017de:	00 00 00 
	b.error = 1;
  8017e1:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  8017e8:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  8017eb:	ff 75 10             	pushl  0x10(%ebp)
  8017ee:	ff 75 0c             	pushl  0xc(%ebp)
  8017f1:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8017f7:	50                   	push   %eax
  8017f8:	68 86 17 80 00       	push   $0x801786
  8017fd:	e8 3b eb ff ff       	call   80033d <vprintfmt>
	if (b.idx > 0)
  801802:	83 c4 10             	add    $0x10,%esp
  801805:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  80180c:	7e 0b                	jle    801819 <vfprintf+0x5e>
		writebuf(&b);
  80180e:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801814:	e8 2e ff ff ff       	call   801747 <writebuf>

	return (b.result ? b.result : b.error);
  801819:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80181f:	85 c0                	test   %eax,%eax
  801821:	75 06                	jne    801829 <vfprintf+0x6e>
  801823:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  801829:	c9                   	leave  
  80182a:	c3                   	ret    

0080182b <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  80182b:	55                   	push   %ebp
  80182c:	89 e5                	mov    %esp,%ebp
  80182e:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801831:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  801834:	50                   	push   %eax
  801835:	ff 75 0c             	pushl  0xc(%ebp)
  801838:	ff 75 08             	pushl  0x8(%ebp)
  80183b:	e8 7b ff ff ff       	call   8017bb <vfprintf>
	va_end(ap);

	return cnt;
}
  801840:	c9                   	leave  
  801841:	c3                   	ret    

00801842 <printf>:

int
printf(const char *fmt, ...)
{
  801842:	55                   	push   %ebp
  801843:	89 e5                	mov    %esp,%ebp
  801845:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801848:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  80184b:	50                   	push   %eax
  80184c:	ff 75 08             	pushl  0x8(%ebp)
  80184f:	6a 01                	push   $0x1
  801851:	e8 65 ff ff ff       	call   8017bb <vfprintf>
	va_end(ap);

	return cnt;
}
  801856:	c9                   	leave  
  801857:	c3                   	ret    

00801858 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801858:	55                   	push   %ebp
  801859:	89 e5                	mov    %esp,%ebp
  80185b:	56                   	push   %esi
  80185c:	53                   	push   %ebx
  80185d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801860:	83 ec 0c             	sub    $0xc,%esp
  801863:	ff 75 08             	pushl  0x8(%ebp)
  801866:	e8 48 f7 ff ff       	call   800fb3 <fd2data>
  80186b:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80186d:	83 c4 08             	add    $0x8,%esp
  801870:	68 99 25 80 00       	push   $0x802599
  801875:	53                   	push   %ebx
  801876:	e8 70 ef ff ff       	call   8007eb <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80187b:	8b 46 04             	mov    0x4(%esi),%eax
  80187e:	2b 06                	sub    (%esi),%eax
  801880:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801886:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80188d:	00 00 00 
	stat->st_dev = &devpipe;
  801890:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801897:	30 80 00 
	return 0;
}
  80189a:	b8 00 00 00 00       	mov    $0x0,%eax
  80189f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018a2:	5b                   	pop    %ebx
  8018a3:	5e                   	pop    %esi
  8018a4:	5d                   	pop    %ebp
  8018a5:	c3                   	ret    

008018a6 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8018a6:	55                   	push   %ebp
  8018a7:	89 e5                	mov    %esp,%ebp
  8018a9:	53                   	push   %ebx
  8018aa:	83 ec 0c             	sub    $0xc,%esp
  8018ad:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8018b0:	53                   	push   %ebx
  8018b1:	6a 00                	push   $0x0
  8018b3:	e8 28 f4 ff ff       	call   800ce0 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8018b8:	89 1c 24             	mov    %ebx,(%esp)
  8018bb:	e8 f3 f6 ff ff       	call   800fb3 <fd2data>
  8018c0:	83 c4 08             	add    $0x8,%esp
  8018c3:	50                   	push   %eax
  8018c4:	6a 00                	push   $0x0
  8018c6:	e8 15 f4 ff ff       	call   800ce0 <sys_page_unmap>
}
  8018cb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018ce:	c9                   	leave  
  8018cf:	c3                   	ret    

008018d0 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8018d0:	55                   	push   %ebp
  8018d1:	89 e5                	mov    %esp,%ebp
  8018d3:	57                   	push   %edi
  8018d4:	56                   	push   %esi
  8018d5:	53                   	push   %ebx
  8018d6:	83 ec 1c             	sub    $0x1c,%esp
  8018d9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8018dc:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8018de:	a1 04 40 80 00       	mov    0x804004,%eax
  8018e3:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8018e6:	83 ec 0c             	sub    $0xc,%esp
  8018e9:	ff 75 e0             	pushl  -0x20(%ebp)
  8018ec:	e8 d0 05 00 00       	call   801ec1 <pageref>
  8018f1:	89 c3                	mov    %eax,%ebx
  8018f3:	89 3c 24             	mov    %edi,(%esp)
  8018f6:	e8 c6 05 00 00       	call   801ec1 <pageref>
  8018fb:	83 c4 10             	add    $0x10,%esp
  8018fe:	39 c3                	cmp    %eax,%ebx
  801900:	0f 94 c1             	sete   %cl
  801903:	0f b6 c9             	movzbl %cl,%ecx
  801906:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801909:	8b 15 04 40 80 00    	mov    0x804004,%edx
  80190f:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801912:	39 ce                	cmp    %ecx,%esi
  801914:	74 1b                	je     801931 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801916:	39 c3                	cmp    %eax,%ebx
  801918:	75 c4                	jne    8018de <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80191a:	8b 42 58             	mov    0x58(%edx),%eax
  80191d:	ff 75 e4             	pushl  -0x1c(%ebp)
  801920:	50                   	push   %eax
  801921:	56                   	push   %esi
  801922:	68 a0 25 80 00       	push   $0x8025a0
  801927:	e8 da e8 ff ff       	call   800206 <cprintf>
  80192c:	83 c4 10             	add    $0x10,%esp
  80192f:	eb ad                	jmp    8018de <_pipeisclosed+0xe>
	}
}
  801931:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801934:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801937:	5b                   	pop    %ebx
  801938:	5e                   	pop    %esi
  801939:	5f                   	pop    %edi
  80193a:	5d                   	pop    %ebp
  80193b:	c3                   	ret    

0080193c <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80193c:	55                   	push   %ebp
  80193d:	89 e5                	mov    %esp,%ebp
  80193f:	57                   	push   %edi
  801940:	56                   	push   %esi
  801941:	53                   	push   %ebx
  801942:	83 ec 18             	sub    $0x18,%esp
  801945:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801948:	56                   	push   %esi
  801949:	e8 65 f6 ff ff       	call   800fb3 <fd2data>
  80194e:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801950:	83 c4 10             	add    $0x10,%esp
  801953:	bf 00 00 00 00       	mov    $0x0,%edi
  801958:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80195c:	75 42                	jne    8019a0 <devpipe_write+0x64>
  80195e:	eb 4e                	jmp    8019ae <devpipe_write+0x72>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801960:	89 da                	mov    %ebx,%edx
  801962:	89 f0                	mov    %esi,%eax
  801964:	e8 67 ff ff ff       	call   8018d0 <_pipeisclosed>
  801969:	85 c0                	test   %eax,%eax
  80196b:	75 46                	jne    8019b3 <devpipe_write+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80196d:	e8 ca f2 ff ff       	call   800c3c <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801972:	8b 53 04             	mov    0x4(%ebx),%edx
  801975:	8b 03                	mov    (%ebx),%eax
  801977:	83 c0 20             	add    $0x20,%eax
  80197a:	39 c2                	cmp    %eax,%edx
  80197c:	73 e2                	jae    801960 <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80197e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801981:	8a 0c 38             	mov    (%eax,%edi,1),%cl
  801984:	89 d0                	mov    %edx,%eax
  801986:	25 1f 00 00 80       	and    $0x8000001f,%eax
  80198b:	79 05                	jns    801992 <devpipe_write+0x56>
  80198d:	48                   	dec    %eax
  80198e:	83 c8 e0             	or     $0xffffffe0,%eax
  801991:	40                   	inc    %eax
  801992:	88 4c 03 08          	mov    %cl,0x8(%ebx,%eax,1)
		p->p_wpos++;
  801996:	42                   	inc    %edx
  801997:	89 53 04             	mov    %edx,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80199a:	47                   	inc    %edi
  80199b:	39 7d 10             	cmp    %edi,0x10(%ebp)
  80199e:	74 0e                	je     8019ae <devpipe_write+0x72>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8019a0:	8b 53 04             	mov    0x4(%ebx),%edx
  8019a3:	8b 03                	mov    (%ebx),%eax
  8019a5:	83 c0 20             	add    $0x20,%eax
  8019a8:	39 c2                	cmp    %eax,%edx
  8019aa:	73 b4                	jae    801960 <devpipe_write+0x24>
  8019ac:	eb d0                	jmp    80197e <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8019ae:	8b 45 10             	mov    0x10(%ebp),%eax
  8019b1:	eb 05                	jmp    8019b8 <devpipe_write+0x7c>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8019b3:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8019b8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019bb:	5b                   	pop    %ebx
  8019bc:	5e                   	pop    %esi
  8019bd:	5f                   	pop    %edi
  8019be:	5d                   	pop    %ebp
  8019bf:	c3                   	ret    

008019c0 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8019c0:	55                   	push   %ebp
  8019c1:	89 e5                	mov    %esp,%ebp
  8019c3:	57                   	push   %edi
  8019c4:	56                   	push   %esi
  8019c5:	53                   	push   %ebx
  8019c6:	83 ec 18             	sub    $0x18,%esp
  8019c9:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8019cc:	57                   	push   %edi
  8019cd:	e8 e1 f5 ff ff       	call   800fb3 <fd2data>
  8019d2:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019d4:	83 c4 10             	add    $0x10,%esp
  8019d7:	be 00 00 00 00       	mov    $0x0,%esi
  8019dc:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8019e0:	75 3d                	jne    801a1f <devpipe_read+0x5f>
  8019e2:	eb 48                	jmp    801a2c <devpipe_read+0x6c>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  8019e4:	89 f0                	mov    %esi,%eax
  8019e6:	eb 4e                	jmp    801a36 <devpipe_read+0x76>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8019e8:	89 da                	mov    %ebx,%edx
  8019ea:	89 f8                	mov    %edi,%eax
  8019ec:	e8 df fe ff ff       	call   8018d0 <_pipeisclosed>
  8019f1:	85 c0                	test   %eax,%eax
  8019f3:	75 3c                	jne    801a31 <devpipe_read+0x71>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8019f5:	e8 42 f2 ff ff       	call   800c3c <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8019fa:	8b 03                	mov    (%ebx),%eax
  8019fc:	3b 43 04             	cmp    0x4(%ebx),%eax
  8019ff:	74 e7                	je     8019e8 <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801a01:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801a06:	79 05                	jns    801a0d <devpipe_read+0x4d>
  801a08:	48                   	dec    %eax
  801a09:	83 c8 e0             	or     $0xffffffe0,%eax
  801a0c:	40                   	inc    %eax
  801a0d:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801a11:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a14:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801a17:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a19:	46                   	inc    %esi
  801a1a:	39 75 10             	cmp    %esi,0x10(%ebp)
  801a1d:	74 0d                	je     801a2c <devpipe_read+0x6c>
		while (p->p_rpos == p->p_wpos) {
  801a1f:	8b 03                	mov    (%ebx),%eax
  801a21:	3b 43 04             	cmp    0x4(%ebx),%eax
  801a24:	75 db                	jne    801a01 <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801a26:	85 f6                	test   %esi,%esi
  801a28:	75 ba                	jne    8019e4 <devpipe_read+0x24>
  801a2a:	eb bc                	jmp    8019e8 <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801a2c:	8b 45 10             	mov    0x10(%ebp),%eax
  801a2f:	eb 05                	jmp    801a36 <devpipe_read+0x76>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801a31:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801a36:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a39:	5b                   	pop    %ebx
  801a3a:	5e                   	pop    %esi
  801a3b:	5f                   	pop    %edi
  801a3c:	5d                   	pop    %ebp
  801a3d:	c3                   	ret    

00801a3e <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801a3e:	55                   	push   %ebp
  801a3f:	89 e5                	mov    %esp,%ebp
  801a41:	56                   	push   %esi
  801a42:	53                   	push   %ebx
  801a43:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801a46:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a49:	50                   	push   %eax
  801a4a:	e8 7b f5 ff ff       	call   800fca <fd_alloc>
  801a4f:	83 c4 10             	add    $0x10,%esp
  801a52:	85 c0                	test   %eax,%eax
  801a54:	0f 88 2a 01 00 00    	js     801b84 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a5a:	83 ec 04             	sub    $0x4,%esp
  801a5d:	68 07 04 00 00       	push   $0x407
  801a62:	ff 75 f4             	pushl  -0xc(%ebp)
  801a65:	6a 00                	push   $0x0
  801a67:	e8 ef f1 ff ff       	call   800c5b <sys_page_alloc>
  801a6c:	83 c4 10             	add    $0x10,%esp
  801a6f:	85 c0                	test   %eax,%eax
  801a71:	0f 88 0d 01 00 00    	js     801b84 <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801a77:	83 ec 0c             	sub    $0xc,%esp
  801a7a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a7d:	50                   	push   %eax
  801a7e:	e8 47 f5 ff ff       	call   800fca <fd_alloc>
  801a83:	89 c3                	mov    %eax,%ebx
  801a85:	83 c4 10             	add    $0x10,%esp
  801a88:	85 c0                	test   %eax,%eax
  801a8a:	0f 88 e2 00 00 00    	js     801b72 <pipe+0x134>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a90:	83 ec 04             	sub    $0x4,%esp
  801a93:	68 07 04 00 00       	push   $0x407
  801a98:	ff 75 f0             	pushl  -0x10(%ebp)
  801a9b:	6a 00                	push   $0x0
  801a9d:	e8 b9 f1 ff ff       	call   800c5b <sys_page_alloc>
  801aa2:	89 c3                	mov    %eax,%ebx
  801aa4:	83 c4 10             	add    $0x10,%esp
  801aa7:	85 c0                	test   %eax,%eax
  801aa9:	0f 88 c3 00 00 00    	js     801b72 <pipe+0x134>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801aaf:	83 ec 0c             	sub    $0xc,%esp
  801ab2:	ff 75 f4             	pushl  -0xc(%ebp)
  801ab5:	e8 f9 f4 ff ff       	call   800fb3 <fd2data>
  801aba:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801abc:	83 c4 0c             	add    $0xc,%esp
  801abf:	68 07 04 00 00       	push   $0x407
  801ac4:	50                   	push   %eax
  801ac5:	6a 00                	push   $0x0
  801ac7:	e8 8f f1 ff ff       	call   800c5b <sys_page_alloc>
  801acc:	89 c3                	mov    %eax,%ebx
  801ace:	83 c4 10             	add    $0x10,%esp
  801ad1:	85 c0                	test   %eax,%eax
  801ad3:	0f 88 89 00 00 00    	js     801b62 <pipe+0x124>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ad9:	83 ec 0c             	sub    $0xc,%esp
  801adc:	ff 75 f0             	pushl  -0x10(%ebp)
  801adf:	e8 cf f4 ff ff       	call   800fb3 <fd2data>
  801ae4:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801aeb:	50                   	push   %eax
  801aec:	6a 00                	push   $0x0
  801aee:	56                   	push   %esi
  801aef:	6a 00                	push   $0x0
  801af1:	e8 a8 f1 ff ff       	call   800c9e <sys_page_map>
  801af6:	89 c3                	mov    %eax,%ebx
  801af8:	83 c4 20             	add    $0x20,%esp
  801afb:	85 c0                	test   %eax,%eax
  801afd:	78 55                	js     801b54 <pipe+0x116>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801aff:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b05:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b08:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801b0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b0d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801b14:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b1a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b1d:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801b1f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b22:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801b29:	83 ec 0c             	sub    $0xc,%esp
  801b2c:	ff 75 f4             	pushl  -0xc(%ebp)
  801b2f:	e8 6f f4 ff ff       	call   800fa3 <fd2num>
  801b34:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b37:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801b39:	83 c4 04             	add    $0x4,%esp
  801b3c:	ff 75 f0             	pushl  -0x10(%ebp)
  801b3f:	e8 5f f4 ff ff       	call   800fa3 <fd2num>
  801b44:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b47:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801b4a:	83 c4 10             	add    $0x10,%esp
  801b4d:	b8 00 00 00 00       	mov    $0x0,%eax
  801b52:	eb 30                	jmp    801b84 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  801b54:	83 ec 08             	sub    $0x8,%esp
  801b57:	56                   	push   %esi
  801b58:	6a 00                	push   $0x0
  801b5a:	e8 81 f1 ff ff       	call   800ce0 <sys_page_unmap>
  801b5f:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801b62:	83 ec 08             	sub    $0x8,%esp
  801b65:	ff 75 f0             	pushl  -0x10(%ebp)
  801b68:	6a 00                	push   $0x0
  801b6a:	e8 71 f1 ff ff       	call   800ce0 <sys_page_unmap>
  801b6f:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801b72:	83 ec 08             	sub    $0x8,%esp
  801b75:	ff 75 f4             	pushl  -0xc(%ebp)
  801b78:	6a 00                	push   $0x0
  801b7a:	e8 61 f1 ff ff       	call   800ce0 <sys_page_unmap>
  801b7f:	83 c4 10             	add    $0x10,%esp
  801b82:	89 d8                	mov    %ebx,%eax
    err:
	return r;
}
  801b84:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b87:	5b                   	pop    %ebx
  801b88:	5e                   	pop    %esi
  801b89:	5d                   	pop    %ebp
  801b8a:	c3                   	ret    

00801b8b <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801b8b:	55                   	push   %ebp
  801b8c:	89 e5                	mov    %esp,%ebp
  801b8e:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b91:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b94:	50                   	push   %eax
  801b95:	ff 75 08             	pushl  0x8(%ebp)
  801b98:	e8 a1 f4 ff ff       	call   80103e <fd_lookup>
  801b9d:	83 c4 10             	add    $0x10,%esp
  801ba0:	85 c0                	test   %eax,%eax
  801ba2:	78 18                	js     801bbc <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801ba4:	83 ec 0c             	sub    $0xc,%esp
  801ba7:	ff 75 f4             	pushl  -0xc(%ebp)
  801baa:	e8 04 f4 ff ff       	call   800fb3 <fd2data>
	return _pipeisclosed(fd, p);
  801baf:	89 c2                	mov    %eax,%edx
  801bb1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bb4:	e8 17 fd ff ff       	call   8018d0 <_pipeisclosed>
  801bb9:	83 c4 10             	add    $0x10,%esp
}
  801bbc:	c9                   	leave  
  801bbd:	c3                   	ret    

00801bbe <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801bbe:	55                   	push   %ebp
  801bbf:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801bc1:	b8 00 00 00 00       	mov    $0x0,%eax
  801bc6:	5d                   	pop    %ebp
  801bc7:	c3                   	ret    

00801bc8 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801bc8:	55                   	push   %ebp
  801bc9:	89 e5                	mov    %esp,%ebp
  801bcb:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801bce:	68 b8 25 80 00       	push   $0x8025b8
  801bd3:	ff 75 0c             	pushl  0xc(%ebp)
  801bd6:	e8 10 ec ff ff       	call   8007eb <strcpy>
	return 0;
}
  801bdb:	b8 00 00 00 00       	mov    $0x0,%eax
  801be0:	c9                   	leave  
  801be1:	c3                   	ret    

00801be2 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801be2:	55                   	push   %ebp
  801be3:	89 e5                	mov    %esp,%ebp
  801be5:	57                   	push   %edi
  801be6:	56                   	push   %esi
  801be7:	53                   	push   %ebx
  801be8:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801bee:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801bf2:	74 45                	je     801c39 <devcons_write+0x57>
  801bf4:	b8 00 00 00 00       	mov    $0x0,%eax
  801bf9:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801bfe:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801c04:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801c07:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  801c09:	83 fb 7f             	cmp    $0x7f,%ebx
  801c0c:	76 05                	jbe    801c13 <devcons_write+0x31>
			m = sizeof(buf) - 1;
  801c0e:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801c13:	83 ec 04             	sub    $0x4,%esp
  801c16:	53                   	push   %ebx
  801c17:	03 45 0c             	add    0xc(%ebp),%eax
  801c1a:	50                   	push   %eax
  801c1b:	57                   	push   %edi
  801c1c:	e8 97 ed ff ff       	call   8009b8 <memmove>
		sys_cputs(buf, m);
  801c21:	83 c4 08             	add    $0x8,%esp
  801c24:	53                   	push   %ebx
  801c25:	57                   	push   %edi
  801c26:	e8 74 ef ff ff       	call   800b9f <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c2b:	01 de                	add    %ebx,%esi
  801c2d:	89 f0                	mov    %esi,%eax
  801c2f:	83 c4 10             	add    $0x10,%esp
  801c32:	3b 75 10             	cmp    0x10(%ebp),%esi
  801c35:	72 cd                	jb     801c04 <devcons_write+0x22>
  801c37:	eb 05                	jmp    801c3e <devcons_write+0x5c>
  801c39:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801c3e:	89 f0                	mov    %esi,%eax
  801c40:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c43:	5b                   	pop    %ebx
  801c44:	5e                   	pop    %esi
  801c45:	5f                   	pop    %edi
  801c46:	5d                   	pop    %ebp
  801c47:	c3                   	ret    

00801c48 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c48:	55                   	push   %ebp
  801c49:	89 e5                	mov    %esp,%ebp
  801c4b:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801c4e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801c52:	75 07                	jne    801c5b <devcons_read+0x13>
  801c54:	eb 23                	jmp    801c79 <devcons_read+0x31>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801c56:	e8 e1 ef ff ff       	call   800c3c <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801c5b:	e8 5d ef ff ff       	call   800bbd <sys_cgetc>
  801c60:	85 c0                	test   %eax,%eax
  801c62:	74 f2                	je     801c56 <devcons_read+0xe>
		sys_yield();
	if (c < 0)
  801c64:	85 c0                	test   %eax,%eax
  801c66:	78 1d                	js     801c85 <devcons_read+0x3d>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801c68:	83 f8 04             	cmp    $0x4,%eax
  801c6b:	74 13                	je     801c80 <devcons_read+0x38>
		return 0;
	*(char*)vbuf = c;
  801c6d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c70:	88 02                	mov    %al,(%edx)
	return 1;
  801c72:	b8 01 00 00 00       	mov    $0x1,%eax
  801c77:	eb 0c                	jmp    801c85 <devcons_read+0x3d>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801c79:	b8 00 00 00 00       	mov    $0x0,%eax
  801c7e:	eb 05                	jmp    801c85 <devcons_read+0x3d>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801c80:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801c85:	c9                   	leave  
  801c86:	c3                   	ret    

00801c87 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801c87:	55                   	push   %ebp
  801c88:	89 e5                	mov    %esp,%ebp
  801c8a:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801c8d:	8b 45 08             	mov    0x8(%ebp),%eax
  801c90:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801c93:	6a 01                	push   $0x1
  801c95:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801c98:	50                   	push   %eax
  801c99:	e8 01 ef ff ff       	call   800b9f <sys_cputs>
}
  801c9e:	83 c4 10             	add    $0x10,%esp
  801ca1:	c9                   	leave  
  801ca2:	c3                   	ret    

00801ca3 <getchar>:

int
getchar(void)
{
  801ca3:	55                   	push   %ebp
  801ca4:	89 e5                	mov    %esp,%ebp
  801ca6:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801ca9:	6a 01                	push   $0x1
  801cab:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801cae:	50                   	push   %eax
  801caf:	6a 00                	push   $0x0
  801cb1:	e8 09 f6 ff ff       	call   8012bf <read>
	if (r < 0)
  801cb6:	83 c4 10             	add    $0x10,%esp
  801cb9:	85 c0                	test   %eax,%eax
  801cbb:	78 0f                	js     801ccc <getchar+0x29>
		return r;
	if (r < 1)
  801cbd:	85 c0                	test   %eax,%eax
  801cbf:	7e 06                	jle    801cc7 <getchar+0x24>
		return -E_EOF;
	return c;
  801cc1:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801cc5:	eb 05                	jmp    801ccc <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801cc7:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801ccc:	c9                   	leave  
  801ccd:	c3                   	ret    

00801cce <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801cce:	55                   	push   %ebp
  801ccf:	89 e5                	mov    %esp,%ebp
  801cd1:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801cd4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cd7:	50                   	push   %eax
  801cd8:	ff 75 08             	pushl  0x8(%ebp)
  801cdb:	e8 5e f3 ff ff       	call   80103e <fd_lookup>
  801ce0:	83 c4 10             	add    $0x10,%esp
  801ce3:	85 c0                	test   %eax,%eax
  801ce5:	78 11                	js     801cf8 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801ce7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cea:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801cf0:	39 10                	cmp    %edx,(%eax)
  801cf2:	0f 94 c0             	sete   %al
  801cf5:	0f b6 c0             	movzbl %al,%eax
}
  801cf8:	c9                   	leave  
  801cf9:	c3                   	ret    

00801cfa <opencons>:

int
opencons(void)
{
  801cfa:	55                   	push   %ebp
  801cfb:	89 e5                	mov    %esp,%ebp
  801cfd:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801d00:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d03:	50                   	push   %eax
  801d04:	e8 c1 f2 ff ff       	call   800fca <fd_alloc>
  801d09:	83 c4 10             	add    $0x10,%esp
  801d0c:	85 c0                	test   %eax,%eax
  801d0e:	78 3a                	js     801d4a <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801d10:	83 ec 04             	sub    $0x4,%esp
  801d13:	68 07 04 00 00       	push   $0x407
  801d18:	ff 75 f4             	pushl  -0xc(%ebp)
  801d1b:	6a 00                	push   $0x0
  801d1d:	e8 39 ef ff ff       	call   800c5b <sys_page_alloc>
  801d22:	83 c4 10             	add    $0x10,%esp
  801d25:	85 c0                	test   %eax,%eax
  801d27:	78 21                	js     801d4a <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801d29:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d32:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801d34:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d37:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801d3e:	83 ec 0c             	sub    $0xc,%esp
  801d41:	50                   	push   %eax
  801d42:	e8 5c f2 ff ff       	call   800fa3 <fd2num>
  801d47:	83 c4 10             	add    $0x10,%esp
}
  801d4a:	c9                   	leave  
  801d4b:	c3                   	ret    

00801d4c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801d4c:	55                   	push   %ebp
  801d4d:	89 e5                	mov    %esp,%ebp
  801d4f:	56                   	push   %esi
  801d50:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801d51:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801d54:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801d5a:	e8 be ee ff ff       	call   800c1d <sys_getenvid>
  801d5f:	83 ec 0c             	sub    $0xc,%esp
  801d62:	ff 75 0c             	pushl  0xc(%ebp)
  801d65:	ff 75 08             	pushl  0x8(%ebp)
  801d68:	56                   	push   %esi
  801d69:	50                   	push   %eax
  801d6a:	68 c4 25 80 00       	push   $0x8025c4
  801d6f:	e8 92 e4 ff ff       	call   800206 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801d74:	83 c4 18             	add    $0x18,%esp
  801d77:	53                   	push   %ebx
  801d78:	ff 75 10             	pushl  0x10(%ebp)
  801d7b:	e8 35 e4 ff ff       	call   8001b5 <vcprintf>
	cprintf("\n");
  801d80:	c7 04 24 90 21 80 00 	movl   $0x802190,(%esp)
  801d87:	e8 7a e4 ff ff       	call   800206 <cprintf>
  801d8c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801d8f:	cc                   	int3   
  801d90:	eb fd                	jmp    801d8f <_panic+0x43>

00801d92 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801d92:	55                   	push   %ebp
  801d93:	89 e5                	mov    %esp,%ebp
  801d95:	56                   	push   %esi
  801d96:	53                   	push   %ebx
  801d97:	8b 75 08             	mov    0x8(%ebp),%esi
  801d9a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d9d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");
	int r;
    if (pg != NULL) {
  801da0:	85 c0                	test   %eax,%eax
  801da2:	74 0e                	je     801db2 <ipc_recv+0x20>
        r = sys_ipc_recv(pg);
  801da4:	83 ec 0c             	sub    $0xc,%esp
  801da7:	50                   	push   %eax
  801da8:	e8 5e f0 ff ff       	call   800e0b <sys_ipc_recv>
  801dad:	83 c4 10             	add    $0x10,%esp
  801db0:	eb 10                	jmp    801dc2 <ipc_recv+0x30>
    } else {
        r = sys_ipc_recv((void *) UTOP);
  801db2:	83 ec 0c             	sub    $0xc,%esp
  801db5:	68 00 00 c0 ee       	push   $0xeec00000
  801dba:	e8 4c f0 ff ff       	call   800e0b <sys_ipc_recv>
  801dbf:	83 c4 10             	add    $0x10,%esp
    }
    if (r < 0) {
  801dc2:	85 c0                	test   %eax,%eax
  801dc4:	79 16                	jns    801ddc <ipc_recv+0x4a>
        // failed
        if (from_env_store != NULL) *from_env_store = 0;
  801dc6:	85 f6                	test   %esi,%esi
  801dc8:	74 06                	je     801dd0 <ipc_recv+0x3e>
  801dca:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        if (perm_store != NULL) *perm_store = 0;
  801dd0:	85 db                	test   %ebx,%ebx
  801dd2:	74 2c                	je     801e00 <ipc_recv+0x6e>
  801dd4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801dda:	eb 24                	jmp    801e00 <ipc_recv+0x6e>
        return r;
    } else {
        if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801ddc:	85 f6                	test   %esi,%esi
  801dde:	74 0a                	je     801dea <ipc_recv+0x58>
  801de0:	a1 04 40 80 00       	mov    0x804004,%eax
  801de5:	8b 40 74             	mov    0x74(%eax),%eax
  801de8:	89 06                	mov    %eax,(%esi)
        if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801dea:	85 db                	test   %ebx,%ebx
  801dec:	74 0a                	je     801df8 <ipc_recv+0x66>
  801dee:	a1 04 40 80 00       	mov    0x804004,%eax
  801df3:	8b 40 78             	mov    0x78(%eax),%eax
  801df6:	89 03                	mov    %eax,(%ebx)
        return thisenv->env_ipc_value;
  801df8:	a1 04 40 80 00       	mov    0x804004,%eax
  801dfd:	8b 40 70             	mov    0x70(%eax),%eax
    }
 
	return 0;
}
  801e00:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e03:	5b                   	pop    %ebx
  801e04:	5e                   	pop    %esi
  801e05:	5d                   	pop    %ebp
  801e06:	c3                   	ret    

00801e07 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801e07:	55                   	push   %ebp
  801e08:	89 e5                	mov    %esp,%ebp
  801e0a:	57                   	push   %edi
  801e0b:	56                   	push   %esi
  801e0c:	53                   	push   %ebx
  801e0d:	83 ec 0c             	sub    $0xc,%esp
  801e10:	8b 75 10             	mov    0x10(%ebp),%esi
  801e13:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");
	int r;
    if (pg == NULL) pg = (void *)UTOP;
  801e16:	85 f6                	test   %esi,%esi
  801e18:	75 05                	jne    801e1f <ipc_send+0x18>
  801e1a:	be 00 00 c0 ee       	mov    $0xeec00000,%esi
    do {
        r = sys_ipc_try_send(to_env, val, pg, perm);
  801e1f:	57                   	push   %edi
  801e20:	56                   	push   %esi
  801e21:	ff 75 0c             	pushl  0xc(%ebp)
  801e24:	ff 75 08             	pushl  0x8(%ebp)
  801e27:	e8 bc ef ff ff       	call   800de8 <sys_ipc_try_send>
  801e2c:	89 c3                	mov    %eax,%ebx
        if (r < 0 && r != -E_IPC_NOT_RECV) panic("ipc send failed: %e", r);
  801e2e:	83 c4 10             	add    $0x10,%esp
  801e31:	85 c0                	test   %eax,%eax
  801e33:	79 17                	jns    801e4c <ipc_send+0x45>
  801e35:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801e38:	74 1d                	je     801e57 <ipc_send+0x50>
  801e3a:	50                   	push   %eax
  801e3b:	68 e8 25 80 00       	push   $0x8025e8
  801e40:	6a 40                	push   $0x40
  801e42:	68 fc 25 80 00       	push   $0x8025fc
  801e47:	e8 00 ff ff ff       	call   801d4c <_panic>
        sys_yield();
  801e4c:	e8 eb ed ff ff       	call   800c3c <sys_yield>
    } while (r != 0);
  801e51:	85 db                	test   %ebx,%ebx
  801e53:	75 ca                	jne    801e1f <ipc_send+0x18>
  801e55:	eb 07                	jmp    801e5e <ipc_send+0x57>
	int r;
    if (pg == NULL) pg = (void *)UTOP;
    do {
        r = sys_ipc_try_send(to_env, val, pg, perm);
        if (r < 0 && r != -E_IPC_NOT_RECV) panic("ipc send failed: %e", r);
        sys_yield();
  801e57:	e8 e0 ed ff ff       	call   800c3c <sys_yield>
  801e5c:	eb c1                	jmp    801e1f <ipc_send+0x18>
    } while (r != 0);
}
  801e5e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e61:	5b                   	pop    %ebx
  801e62:	5e                   	pop    %esi
  801e63:	5f                   	pop    %edi
  801e64:	5d                   	pop    %ebp
  801e65:	c3                   	ret    

00801e66 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801e66:	55                   	push   %ebp
  801e67:	89 e5                	mov    %esp,%ebp
  801e69:	53                   	push   %ebx
  801e6a:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801e6d:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  801e72:	39 c1                	cmp    %eax,%ecx
  801e74:	74 21                	je     801e97 <ipc_find_env+0x31>
  801e76:	ba 01 00 00 00       	mov    $0x1,%edx
  801e7b:	8d 1c 95 00 00 00 00 	lea    0x0(,%edx,4),%ebx
  801e82:	89 d0                	mov    %edx,%eax
  801e84:	c1 e0 07             	shl    $0x7,%eax
  801e87:	29 d8                	sub    %ebx,%eax
  801e89:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801e8e:	8b 40 50             	mov    0x50(%eax),%eax
  801e91:	39 c8                	cmp    %ecx,%eax
  801e93:	75 1b                	jne    801eb0 <ipc_find_env+0x4a>
  801e95:	eb 05                	jmp    801e9c <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801e97:	ba 00 00 00 00       	mov    $0x0,%edx
		if (envs[i].env_type == type)
			return envs[i].env_id;
  801e9c:	8d 04 95 00 00 00 00 	lea    0x0(,%edx,4),%eax
  801ea3:	c1 e2 07             	shl    $0x7,%edx
  801ea6:	29 c2                	sub    %eax,%edx
  801ea8:	8b 82 48 00 c0 ee    	mov    -0x113fffb8(%edx),%eax
  801eae:	eb 0e                	jmp    801ebe <ipc_find_env+0x58>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801eb0:	42                   	inc    %edx
  801eb1:	81 fa 00 04 00 00    	cmp    $0x400,%edx
  801eb7:	75 c2                	jne    801e7b <ipc_find_env+0x15>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801eb9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ebe:	5b                   	pop    %ebx
  801ebf:	5d                   	pop    %ebp
  801ec0:	c3                   	ret    

00801ec1 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801ec1:	55                   	push   %ebp
  801ec2:	89 e5                	mov    %esp,%ebp
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ec4:	8b 45 08             	mov    0x8(%ebp),%eax
  801ec7:	c1 e8 16             	shr    $0x16,%eax
  801eca:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801ed1:	a8 01                	test   $0x1,%al
  801ed3:	74 21                	je     801ef6 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801ed5:	8b 45 08             	mov    0x8(%ebp),%eax
  801ed8:	c1 e8 0c             	shr    $0xc,%eax
  801edb:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801ee2:	a8 01                	test   $0x1,%al
  801ee4:	74 17                	je     801efd <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801ee6:	c1 e8 0c             	shr    $0xc,%eax
  801ee9:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801ef0:	ef 
  801ef1:	0f b7 c0             	movzwl %ax,%eax
  801ef4:	eb 0c                	jmp    801f02 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801ef6:	b8 00 00 00 00       	mov    $0x0,%eax
  801efb:	eb 05                	jmp    801f02 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801efd:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801f02:	5d                   	pop    %ebp
  801f03:	c3                   	ret    

00801f04 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801f04:	55                   	push   %ebp
  801f05:	57                   	push   %edi
  801f06:	56                   	push   %esi
  801f07:	53                   	push   %ebx
  801f08:	83 ec 1c             	sub    $0x1c,%esp
  801f0b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801f0f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801f13:	8b 7c 24 38          	mov    0x38(%esp),%edi
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801f17:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f1b:	89 ca                	mov    %ecx,%edx
  const DWunion dd = {.ll = d};
  801f1d:	89 f8                	mov    %edi,%eax
  801f1f:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801f23:	85 f6                	test   %esi,%esi
  801f25:	75 2d                	jne    801f54 <__udivdi3+0x50>
    {
      if (d0 > n1)
  801f27:	39 cf                	cmp    %ecx,%edi
  801f29:	77 65                	ja     801f90 <__udivdi3+0x8c>
  801f2b:	89 fd                	mov    %edi,%ebp
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801f2d:	85 ff                	test   %edi,%edi
  801f2f:	75 0b                	jne    801f3c <__udivdi3+0x38>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801f31:	b8 01 00 00 00       	mov    $0x1,%eax
  801f36:	31 d2                	xor    %edx,%edx
  801f38:	f7 f7                	div    %edi
  801f3a:	89 c5                	mov    %eax,%ebp

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801f3c:	31 d2                	xor    %edx,%edx
  801f3e:	89 c8                	mov    %ecx,%eax
  801f40:	f7 f5                	div    %ebp
  801f42:	89 c1                	mov    %eax,%ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801f44:	89 d8                	mov    %ebx,%eax
  801f46:	f7 f5                	div    %ebp
  801f48:	89 cf                	mov    %ecx,%edi
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801f4a:	89 fa                	mov    %edi,%edx
  801f4c:	83 c4 1c             	add    $0x1c,%esp
  801f4f:	5b                   	pop    %ebx
  801f50:	5e                   	pop    %esi
  801f51:	5f                   	pop    %edi
  801f52:	5d                   	pop    %ebp
  801f53:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801f54:	39 ce                	cmp    %ecx,%esi
  801f56:	77 28                	ja     801f80 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801f58:	0f bd fe             	bsr    %esi,%edi
	  if (bm == 0)
  801f5b:	83 f7 1f             	xor    $0x1f,%edi
  801f5e:	75 40                	jne    801fa0 <__udivdi3+0x9c>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801f60:	39 ce                	cmp    %ecx,%esi
  801f62:	72 0a                	jb     801f6e <__udivdi3+0x6a>
  801f64:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801f68:	0f 87 9e 00 00 00    	ja     80200c <__udivdi3+0x108>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801f6e:	b8 01 00 00 00       	mov    $0x1,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801f73:	89 fa                	mov    %edi,%edx
  801f75:	83 c4 1c             	add    $0x1c,%esp
  801f78:	5b                   	pop    %ebx
  801f79:	5e                   	pop    %esi
  801f7a:	5f                   	pop    %edi
  801f7b:	5d                   	pop    %ebp
  801f7c:	c3                   	ret    
  801f7d:	8d 76 00             	lea    0x0(%esi),%esi
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801f80:	31 ff                	xor    %edi,%edi
  801f82:	31 c0                	xor    %eax,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801f84:	89 fa                	mov    %edi,%edx
  801f86:	83 c4 1c             	add    $0x1c,%esp
  801f89:	5b                   	pop    %ebx
  801f8a:	5e                   	pop    %esi
  801f8b:	5f                   	pop    %edi
  801f8c:	5d                   	pop    %ebp
  801f8d:	c3                   	ret    
  801f8e:	66 90                	xchg   %ax,%ax
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801f90:	89 d8                	mov    %ebx,%eax
  801f92:	f7 f7                	div    %edi
  801f94:	31 ff                	xor    %edi,%edi
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801f96:	89 fa                	mov    %edi,%edx
  801f98:	83 c4 1c             	add    $0x1c,%esp
  801f9b:	5b                   	pop    %ebx
  801f9c:	5e                   	pop    %esi
  801f9d:	5f                   	pop    %edi
  801f9e:	5d                   	pop    %ebp
  801f9f:	c3                   	ret    
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801fa0:	bd 20 00 00 00       	mov    $0x20,%ebp
  801fa5:	89 eb                	mov    %ebp,%ebx
  801fa7:	29 fb                	sub    %edi,%ebx

	      d1 = (d1 << bm) | (d0 >> b);
  801fa9:	89 f9                	mov    %edi,%ecx
  801fab:	d3 e6                	shl    %cl,%esi
  801fad:	89 c5                	mov    %eax,%ebp
  801faf:	88 d9                	mov    %bl,%cl
  801fb1:	d3 ed                	shr    %cl,%ebp
  801fb3:	89 e9                	mov    %ebp,%ecx
  801fb5:	09 f1                	or     %esi,%ecx
  801fb7:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
	      d0 = d0 << bm;
  801fbb:	89 f9                	mov    %edi,%ecx
  801fbd:	d3 e0                	shl    %cl,%eax
  801fbf:	89 c5                	mov    %eax,%ebp
	      n2 = n1 >> b;
  801fc1:	89 d6                	mov    %edx,%esi
  801fc3:	88 d9                	mov    %bl,%cl
  801fc5:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
  801fc7:	89 f9                	mov    %edi,%ecx
  801fc9:	d3 e2                	shl    %cl,%edx
  801fcb:	8b 44 24 08          	mov    0x8(%esp),%eax
  801fcf:	88 d9                	mov    %bl,%cl
  801fd1:	d3 e8                	shr    %cl,%eax
  801fd3:	09 c2                	or     %eax,%edx
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801fd5:	89 d0                	mov    %edx,%eax
  801fd7:	89 f2                	mov    %esi,%edx
  801fd9:	f7 74 24 0c          	divl   0xc(%esp)
  801fdd:	89 d6                	mov    %edx,%esi
  801fdf:	89 c3                	mov    %eax,%ebx
	      umul_ppmm (m1, m0, q0, d0);
  801fe1:	f7 e5                	mul    %ebp

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801fe3:	39 d6                	cmp    %edx,%esi
  801fe5:	72 19                	jb     802000 <__udivdi3+0xfc>
  801fe7:	74 0b                	je     801ff4 <__udivdi3+0xf0>
  801fe9:	89 d8                	mov    %ebx,%eax
  801feb:	31 ff                	xor    %edi,%edi
  801fed:	e9 58 ff ff ff       	jmp    801f4a <__udivdi3+0x46>
  801ff2:	66 90                	xchg   %ax,%ax
  801ff4:	8b 54 24 08          	mov    0x8(%esp),%edx
  801ff8:	89 f9                	mov    %edi,%ecx
  801ffa:	d3 e2                	shl    %cl,%edx
  801ffc:	39 c2                	cmp    %eax,%edx
  801ffe:	73 e9                	jae    801fe9 <__udivdi3+0xe5>
  802000:	8d 43 ff             	lea    -0x1(%ebx),%eax
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802003:	31 ff                	xor    %edi,%edi
  802005:	e9 40 ff ff ff       	jmp    801f4a <__udivdi3+0x46>
  80200a:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  80200c:	31 c0                	xor    %eax,%eax
  80200e:	e9 37 ff ff ff       	jmp    801f4a <__udivdi3+0x46>
  802013:	90                   	nop

00802014 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  802014:	55                   	push   %ebp
  802015:	57                   	push   %edi
  802016:	56                   	push   %esi
  802017:	53                   	push   %ebx
  802018:	83 ec 1c             	sub    $0x1c,%esp
  80201b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80201f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802023:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802027:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80202b:	89 44 24 0c          	mov    %eax,0xc(%esp)
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  80202f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802033:	89 f3                	mov    %esi,%ebx
  const DWunion dd = {.ll = d};
  802035:	89 fa                	mov    %edi,%edx
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  802037:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  n1 = nn.s.high;
  80203b:	89 34 24             	mov    %esi,(%esp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  80203e:	85 c0                	test   %eax,%eax
  802040:	75 1a                	jne    80205c <__umoddi3+0x48>
    {
      if (d0 > n1)
  802042:	39 f7                	cmp    %esi,%edi
  802044:	0f 86 a2 00 00 00    	jbe    8020ec <__umoddi3+0xd8>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80204a:	89 c8                	mov    %ecx,%eax
  80204c:	89 f2                	mov    %esi,%edx
  80204e:	f7 f7                	div    %edi
  802050:	89 d0                	mov    %edx,%eax

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  802052:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802054:	83 c4 1c             	add    $0x1c,%esp
  802057:	5b                   	pop    %ebx
  802058:	5e                   	pop    %esi
  802059:	5f                   	pop    %edi
  80205a:	5d                   	pop    %ebp
  80205b:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  80205c:	39 f0                	cmp    %esi,%eax
  80205e:	0f 87 ac 00 00 00    	ja     802110 <__umoddi3+0xfc>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802064:	0f bd e8             	bsr    %eax,%ebp
	  if (bm == 0)
  802067:	83 f5 1f             	xor    $0x1f,%ebp
  80206a:	0f 84 ac 00 00 00    	je     80211c <__umoddi3+0x108>
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802070:	bf 20 00 00 00       	mov    $0x20,%edi
  802075:	29 ef                	sub    %ebp,%edi
  802077:	89 fe                	mov    %edi,%esi
  802079:	89 7c 24 0c          	mov    %edi,0xc(%esp)

	      d1 = (d1 << bm) | (d0 >> b);
  80207d:	89 e9                	mov    %ebp,%ecx
  80207f:	d3 e0                	shl    %cl,%eax
  802081:	89 d7                	mov    %edx,%edi
  802083:	89 f1                	mov    %esi,%ecx
  802085:	d3 ef                	shr    %cl,%edi
  802087:	09 c7                	or     %eax,%edi
	      d0 = d0 << bm;
  802089:	89 e9                	mov    %ebp,%ecx
  80208b:	d3 e2                	shl    %cl,%edx
  80208d:	89 14 24             	mov    %edx,(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802090:	89 d8                	mov    %ebx,%eax
  802092:	d3 e0                	shl    %cl,%eax
  802094:	89 c2                	mov    %eax,%edx
	      n0 = n0 << bm;
  802096:	8b 44 24 08          	mov    0x8(%esp),%eax
  80209a:	d3 e0                	shl    %cl,%eax
  80209c:	89 44 24 04          	mov    %eax,0x4(%esp)

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8020a0:	8b 44 24 08          	mov    0x8(%esp),%eax
  8020a4:	89 f1                	mov    %esi,%ecx
  8020a6:	d3 e8                	shr    %cl,%eax
  8020a8:	09 d0                	or     %edx,%eax
  8020aa:	d3 eb                	shr    %cl,%ebx
  8020ac:	89 da                	mov    %ebx,%edx
  8020ae:	f7 f7                	div    %edi
  8020b0:	89 d3                	mov    %edx,%ebx
	      umul_ppmm (m1, m0, q0, d0);
  8020b2:	f7 24 24             	mull   (%esp)
  8020b5:	89 c6                	mov    %eax,%esi
  8020b7:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8020b9:	39 d3                	cmp    %edx,%ebx
  8020bb:	0f 82 87 00 00 00    	jb     802148 <__umoddi3+0x134>
  8020c1:	0f 84 91 00 00 00    	je     802158 <__umoddi3+0x144>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  8020c7:	8b 54 24 04          	mov    0x4(%esp),%edx
  8020cb:	29 f2                	sub    %esi,%edx
  8020cd:	19 cb                	sbb    %ecx,%ebx
		  rr.s.low = (n1 << b) | (n0 >> bm);
  8020cf:	89 d8                	mov    %ebx,%eax
  8020d1:	8a 4c 24 0c          	mov    0xc(%esp),%cl
  8020d5:	d3 e0                	shl    %cl,%eax
  8020d7:	89 e9                	mov    %ebp,%ecx
  8020d9:	d3 ea                	shr    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  8020db:	09 d0                	or     %edx,%eax
  8020dd:	89 e9                	mov    %ebp,%ecx
  8020df:	d3 eb                	shr    %cl,%ebx
  8020e1:	89 da                	mov    %ebx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8020e3:	83 c4 1c             	add    $0x1c,%esp
  8020e6:	5b                   	pop    %ebx
  8020e7:	5e                   	pop    %esi
  8020e8:	5f                   	pop    %edi
  8020e9:	5d                   	pop    %ebp
  8020ea:	c3                   	ret    
  8020eb:	90                   	nop
  8020ec:	89 fd                	mov    %edi,%ebp
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8020ee:	85 ff                	test   %edi,%edi
  8020f0:	75 0b                	jne    8020fd <__umoddi3+0xe9>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8020f2:	b8 01 00 00 00       	mov    $0x1,%eax
  8020f7:	31 d2                	xor    %edx,%edx
  8020f9:	f7 f7                	div    %edi
  8020fb:	89 c5                	mov    %eax,%ebp

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8020fd:	89 f0                	mov    %esi,%eax
  8020ff:	31 d2                	xor    %edx,%edx
  802101:	f7 f5                	div    %ebp
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802103:	89 c8                	mov    %ecx,%eax
  802105:	f7 f5                	div    %ebp
  802107:	89 d0                	mov    %edx,%eax
  802109:	e9 44 ff ff ff       	jmp    802052 <__umoddi3+0x3e>
  80210e:	66 90                	xchg   %ax,%ax
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  802110:	89 c8                	mov    %ecx,%eax
  802112:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802114:	83 c4 1c             	add    $0x1c,%esp
  802117:	5b                   	pop    %ebx
  802118:	5e                   	pop    %esi
  802119:	5f                   	pop    %edi
  80211a:	5d                   	pop    %ebp
  80211b:	c3                   	ret    

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  80211c:	3b 04 24             	cmp    (%esp),%eax
  80211f:	72 06                	jb     802127 <__umoddi3+0x113>
  802121:	3b 7c 24 04          	cmp    0x4(%esp),%edi
  802125:	77 0f                	ja     802136 <__umoddi3+0x122>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802127:	89 f2                	mov    %esi,%edx
  802129:	29 f9                	sub    %edi,%ecx
  80212b:	1b 54 24 0c          	sbb    0xc(%esp),%edx
  80212f:	89 14 24             	mov    %edx,(%esp)
  802132:	89 4c 24 04          	mov    %ecx,0x4(%esp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  802136:	8b 44 24 04          	mov    0x4(%esp),%eax
  80213a:	8b 14 24             	mov    (%esp),%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80213d:	83 c4 1c             	add    $0x1c,%esp
  802140:	5b                   	pop    %ebx
  802141:	5e                   	pop    %esi
  802142:	5f                   	pop    %edi
  802143:	5d                   	pop    %ebp
  802144:	c3                   	ret    
  802145:	8d 76 00             	lea    0x0(%esi),%esi
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802148:	2b 04 24             	sub    (%esp),%eax
  80214b:	19 fa                	sbb    %edi,%edx
  80214d:	89 d1                	mov    %edx,%ecx
  80214f:	89 c6                	mov    %eax,%esi
  802151:	e9 71 ff ff ff       	jmp    8020c7 <__umoddi3+0xb3>
  802156:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802158:	39 44 24 04          	cmp    %eax,0x4(%esp)
  80215c:	72 ea                	jb     802148 <__umoddi3+0x134>
  80215e:	89 d9                	mov    %ebx,%ecx
  802160:	e9 62 ff ff ff       	jmp    8020c7 <__umoddi3+0xb3>
