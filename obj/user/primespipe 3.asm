
obj/user/primespipe.debug:     file format elf32-i386


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
  80002c:	e8 0a 02 00 00       	call   80023b <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <primeproc>:

#include <inc/lib.h>

unsigned
primeproc(int fd)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 1c             	sub    $0x1c,%esp
  80003c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i, id, p, pfd[2], wfd, r;

	// fetch a prime from our left neighbor
top:
	if ((r = readn(fd, &p, 4)) != 4)
  80003f:	8d 75 e0             	lea    -0x20(%ebp),%esi
		panic("primeproc could not read initial prime: %d, %e", r, r >= 0 ? 0 : r);

	cprintf("%d\n", p);

	// fork a right neighbor to continue the chain
	if ((i=pipe(pfd)) < 0)
  800042:	8d 7d d8             	lea    -0x28(%ebp),%edi
{
	int i, id, p, pfd[2], wfd, r;

	// fetch a prime from our left neighbor
top:
	if ((r = readn(fd, &p, 4)) != 4)
  800045:	83 ec 04             	sub    $0x4,%esp
  800048:	6a 04                	push   $0x4
  80004a:	56                   	push   %esi
  80004b:	53                   	push   %ebx
  80004c:	e8 ef 15 00 00       	call   801640 <readn>
  800051:	83 c4 10             	add    $0x10,%esp
  800054:	83 f8 04             	cmp    $0x4,%eax
  800057:	74 21                	je     80007a <primeproc+0x47>
		panic("primeproc could not read initial prime: %d, %e", r, r >= 0 ? 0 : r);
  800059:	83 ec 0c             	sub    $0xc,%esp
  80005c:	89 c2                	mov    %eax,%edx
  80005e:	85 c0                	test   %eax,%eax
  800060:	7e 05                	jle    800067 <primeproc+0x34>
  800062:	ba 00 00 00 00       	mov    $0x0,%edx
  800067:	52                   	push   %edx
  800068:	50                   	push   %eax
  800069:	68 c0 23 80 00       	push   $0x8023c0
  80006e:	6a 15                	push   $0x15
  800070:	68 ef 23 80 00       	push   $0x8023ef
  800075:	e8 2a 02 00 00       	call   8002a4 <_panic>

	cprintf("%d\n", p);
  80007a:	83 ec 08             	sub    $0x8,%esp
  80007d:	ff 75 e0             	pushl  -0x20(%ebp)
  800080:	68 01 24 80 00       	push   $0x802401
  800085:	e8 f2 02 00 00       	call   80037c <cprintf>

	// fork a right neighbor to continue the chain
	if ((i=pipe(pfd)) < 0)
  80008a:	89 3c 24             	mov    %edi,(%esp)
  80008d:	e8 95 1b 00 00       	call   801c27 <pipe>
  800092:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800095:	83 c4 10             	add    $0x10,%esp
  800098:	85 c0                	test   %eax,%eax
  80009a:	79 12                	jns    8000ae <primeproc+0x7b>
		panic("pipe: %e", i);
  80009c:	50                   	push   %eax
  80009d:	68 05 24 80 00       	push   $0x802405
  8000a2:	6a 1b                	push   $0x1b
  8000a4:	68 ef 23 80 00       	push   $0x8023ef
  8000a9:	e8 f6 01 00 00       	call   8002a4 <_panic>
	if ((id = fork()) < 0)
  8000ae:	e8 fe 0f 00 00       	call   8010b1 <fork>
  8000b3:	85 c0                	test   %eax,%eax
  8000b5:	79 12                	jns    8000c9 <primeproc+0x96>
		panic("fork: %e", id);
  8000b7:	50                   	push   %eax
  8000b8:	68 0e 24 80 00       	push   $0x80240e
  8000bd:	6a 1d                	push   $0x1d
  8000bf:	68 ef 23 80 00       	push   $0x8023ef
  8000c4:	e8 db 01 00 00       	call   8002a4 <_panic>
	if (id == 0) {
  8000c9:	85 c0                	test   %eax,%eax
  8000cb:	75 1f                	jne    8000ec <primeproc+0xb9>
		close(fd);
  8000cd:	83 ec 0c             	sub    $0xc,%esp
  8000d0:	53                   	push   %ebx
  8000d1:	e8 ab 13 00 00       	call   801481 <close>
		close(pfd[1]);
  8000d6:	83 c4 04             	add    $0x4,%esp
  8000d9:	ff 75 dc             	pushl  -0x24(%ebp)
  8000dc:	e8 a0 13 00 00       	call   801481 <close>
		fd = pfd[0];
  8000e1:	8b 5d d8             	mov    -0x28(%ebp),%ebx
		goto top;
  8000e4:	83 c4 10             	add    $0x10,%esp
  8000e7:	e9 59 ff ff ff       	jmp    800045 <primeproc+0x12>
	}

	close(pfd[0]);
  8000ec:	83 ec 0c             	sub    $0xc,%esp
  8000ef:	ff 75 d8             	pushl  -0x28(%ebp)
  8000f2:	e8 8a 13 00 00       	call   801481 <close>
	wfd = pfd[1];
  8000f7:	8b 7d dc             	mov    -0x24(%ebp),%edi
  8000fa:	83 c4 10             	add    $0x10,%esp

	// filter out multiples of our prime
	for (;;) {
		if ((r=readn(fd, &i, 4)) != 4)
  8000fd:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  800100:	83 ec 04             	sub    $0x4,%esp
  800103:	6a 04                	push   $0x4
  800105:	56                   	push   %esi
  800106:	53                   	push   %ebx
  800107:	e8 34 15 00 00       	call   801640 <readn>
  80010c:	83 c4 10             	add    $0x10,%esp
  80010f:	83 f8 04             	cmp    $0x4,%eax
  800112:	74 25                	je     800139 <primeproc+0x106>
			panic("primeproc %d readn %d %d %e", p, fd, r, r >= 0 ? 0 : r);
  800114:	83 ec 04             	sub    $0x4,%esp
  800117:	89 c2                	mov    %eax,%edx
  800119:	85 c0                	test   %eax,%eax
  80011b:	7e 05                	jle    800122 <primeproc+0xef>
  80011d:	ba 00 00 00 00       	mov    $0x0,%edx
  800122:	52                   	push   %edx
  800123:	50                   	push   %eax
  800124:	53                   	push   %ebx
  800125:	ff 75 e0             	pushl  -0x20(%ebp)
  800128:	68 17 24 80 00       	push   $0x802417
  80012d:	6a 2b                	push   $0x2b
  80012f:	68 ef 23 80 00       	push   $0x8023ef
  800134:	e8 6b 01 00 00       	call   8002a4 <_panic>
		if (i%p)
  800139:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80013c:	99                   	cltd   
  80013d:	f7 7d e0             	idivl  -0x20(%ebp)
  800140:	85 d2                	test   %edx,%edx
  800142:	74 bc                	je     800100 <primeproc+0xcd>
			if ((r=write(wfd, &i, 4)) != 4)
  800144:	83 ec 04             	sub    $0x4,%esp
  800147:	6a 04                	push   $0x4
  800149:	56                   	push   %esi
  80014a:	57                   	push   %edi
  80014b:	e8 45 15 00 00       	call   801695 <write>
  800150:	83 c4 10             	add    $0x10,%esp
  800153:	83 f8 04             	cmp    $0x4,%eax
  800156:	74 a8                	je     800100 <primeproc+0xcd>
				panic("primeproc %d write: %d %e", p, r, r >= 0 ? 0 : r);
  800158:	83 ec 08             	sub    $0x8,%esp
  80015b:	89 c2                	mov    %eax,%edx
  80015d:	85 c0                	test   %eax,%eax
  80015f:	7e 05                	jle    800166 <primeproc+0x133>
  800161:	ba 00 00 00 00       	mov    $0x0,%edx
  800166:	52                   	push   %edx
  800167:	50                   	push   %eax
  800168:	ff 75 e0             	pushl  -0x20(%ebp)
  80016b:	68 33 24 80 00       	push   $0x802433
  800170:	6a 2e                	push   $0x2e
  800172:	68 ef 23 80 00       	push   $0x8023ef
  800177:	e8 28 01 00 00       	call   8002a4 <_panic>

0080017c <umain>:
	}
}

void
umain(int argc, char **argv)
{
  80017c:	55                   	push   %ebp
  80017d:	89 e5                	mov    %esp,%ebp
  80017f:	53                   	push   %ebx
  800180:	83 ec 20             	sub    $0x20,%esp
	int i, id, p[2], r;

	binaryname = "primespipe";
  800183:	c7 05 00 30 80 00 4d 	movl   $0x80244d,0x803000
  80018a:	24 80 00 

	if ((i=pipe(p)) < 0)
  80018d:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800190:	50                   	push   %eax
  800191:	e8 91 1a 00 00       	call   801c27 <pipe>
  800196:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800199:	83 c4 10             	add    $0x10,%esp
  80019c:	85 c0                	test   %eax,%eax
  80019e:	79 12                	jns    8001b2 <umain+0x36>
		panic("pipe: %e", i);
  8001a0:	50                   	push   %eax
  8001a1:	68 05 24 80 00       	push   $0x802405
  8001a6:	6a 3a                	push   $0x3a
  8001a8:	68 ef 23 80 00       	push   $0x8023ef
  8001ad:	e8 f2 00 00 00       	call   8002a4 <_panic>

	// fork the first prime process in the chain
	if ((id=fork()) < 0)
  8001b2:	e8 fa 0e 00 00       	call   8010b1 <fork>
  8001b7:	85 c0                	test   %eax,%eax
  8001b9:	79 12                	jns    8001cd <umain+0x51>
		panic("fork: %e", id);
  8001bb:	50                   	push   %eax
  8001bc:	68 0e 24 80 00       	push   $0x80240e
  8001c1:	6a 3e                	push   $0x3e
  8001c3:	68 ef 23 80 00       	push   $0x8023ef
  8001c8:	e8 d7 00 00 00       	call   8002a4 <_panic>

	if (id == 0) {
  8001cd:	85 c0                	test   %eax,%eax
  8001cf:	75 16                	jne    8001e7 <umain+0x6b>
		close(p[1]);
  8001d1:	83 ec 0c             	sub    $0xc,%esp
  8001d4:	ff 75 f0             	pushl  -0x10(%ebp)
  8001d7:	e8 a5 12 00 00       	call   801481 <close>
		primeproc(p[0]);
  8001dc:	83 c4 04             	add    $0x4,%esp
  8001df:	ff 75 ec             	pushl  -0x14(%ebp)
  8001e2:	e8 4c fe ff ff       	call   800033 <primeproc>
	}

	close(p[0]);
  8001e7:	83 ec 0c             	sub    $0xc,%esp
  8001ea:	ff 75 ec             	pushl  -0x14(%ebp)
  8001ed:	e8 8f 12 00 00       	call   801481 <close>

	// feed all the integers through
	for (i=2;; i++)
  8001f2:	c7 45 f4 02 00 00 00 	movl   $0x2,-0xc(%ebp)
  8001f9:	83 c4 10             	add    $0x10,%esp
		if ((r=write(p[1], &i, 4)) != 4)
  8001fc:	8d 5d f4             	lea    -0xc(%ebp),%ebx
  8001ff:	83 ec 04             	sub    $0x4,%esp
  800202:	6a 04                	push   $0x4
  800204:	53                   	push   %ebx
  800205:	ff 75 f0             	pushl  -0x10(%ebp)
  800208:	e8 88 14 00 00       	call   801695 <write>
  80020d:	83 c4 10             	add    $0x10,%esp
  800210:	83 f8 04             	cmp    $0x4,%eax
  800213:	74 21                	je     800236 <umain+0xba>
			panic("generator write: %d, %e", r, r >= 0 ? 0 : r);
  800215:	83 ec 0c             	sub    $0xc,%esp
  800218:	89 c2                	mov    %eax,%edx
  80021a:	85 c0                	test   %eax,%eax
  80021c:	7e 05                	jle    800223 <umain+0xa7>
  80021e:	ba 00 00 00 00       	mov    $0x0,%edx
  800223:	52                   	push   %edx
  800224:	50                   	push   %eax
  800225:	68 58 24 80 00       	push   $0x802458
  80022a:	6a 4a                	push   $0x4a
  80022c:	68 ef 23 80 00       	push   $0x8023ef
  800231:	e8 6e 00 00 00       	call   8002a4 <_panic>
	}

	close(p[0]);

	// feed all the integers through
	for (i=2;; i++)
  800236:	ff 45 f4             	incl   -0xc(%ebp)
		if ((r=write(p[1], &i, 4)) != 4)
			panic("generator write: %d, %e", r, r >= 0 ? 0 : r);
}
  800239:	eb c4                	jmp    8001ff <umain+0x83>

0080023b <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80023b:	55                   	push   %ebp
  80023c:	89 e5                	mov    %esp,%ebp
  80023e:	56                   	push   %esi
  80023f:	53                   	push   %ebx
  800240:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800243:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800246:	e8 48 0b 00 00       	call   800d93 <sys_getenvid>
  80024b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800250:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800257:	c1 e0 07             	shl    $0x7,%eax
  80025a:	29 d0                	sub    %edx,%eax
  80025c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800261:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800266:	85 db                	test   %ebx,%ebx
  800268:	7e 07                	jle    800271 <libmain+0x36>
		binaryname = argv[0];
  80026a:	8b 06                	mov    (%esi),%eax
  80026c:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800271:	83 ec 08             	sub    $0x8,%esp
  800274:	56                   	push   %esi
  800275:	53                   	push   %ebx
  800276:	e8 01 ff ff ff       	call   80017c <umain>

	// exit gracefully
	exit();
  80027b:	e8 0a 00 00 00       	call   80028a <exit>
}
  800280:	83 c4 10             	add    $0x10,%esp
  800283:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800286:	5b                   	pop    %ebx
  800287:	5e                   	pop    %esi
  800288:	5d                   	pop    %ebp
  800289:	c3                   	ret    

0080028a <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80028a:	55                   	push   %ebp
  80028b:	89 e5                	mov    %esp,%ebp
  80028d:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800290:	e8 17 12 00 00       	call   8014ac <close_all>
	sys_env_destroy(0);
  800295:	83 ec 0c             	sub    $0xc,%esp
  800298:	6a 00                	push   $0x0
  80029a:	e8 b3 0a 00 00       	call   800d52 <sys_env_destroy>
}
  80029f:	83 c4 10             	add    $0x10,%esp
  8002a2:	c9                   	leave  
  8002a3:	c3                   	ret    

008002a4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8002a4:	55                   	push   %ebp
  8002a5:	89 e5                	mov    %esp,%ebp
  8002a7:	56                   	push   %esi
  8002a8:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8002a9:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8002ac:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8002b2:	e8 dc 0a 00 00       	call   800d93 <sys_getenvid>
  8002b7:	83 ec 0c             	sub    $0xc,%esp
  8002ba:	ff 75 0c             	pushl  0xc(%ebp)
  8002bd:	ff 75 08             	pushl  0x8(%ebp)
  8002c0:	56                   	push   %esi
  8002c1:	50                   	push   %eax
  8002c2:	68 7c 24 80 00       	push   $0x80247c
  8002c7:	e8 b0 00 00 00       	call   80037c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8002cc:	83 c4 18             	add    $0x18,%esp
  8002cf:	53                   	push   %ebx
  8002d0:	ff 75 10             	pushl  0x10(%ebp)
  8002d3:	e8 53 00 00 00       	call   80032b <vcprintf>
	cprintf("\n");
  8002d8:	c7 04 24 0b 28 80 00 	movl   $0x80280b,(%esp)
  8002df:	e8 98 00 00 00       	call   80037c <cprintf>
  8002e4:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8002e7:	cc                   	int3   
  8002e8:	eb fd                	jmp    8002e7 <_panic+0x43>

008002ea <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8002ea:	55                   	push   %ebp
  8002eb:	89 e5                	mov    %esp,%ebp
  8002ed:	53                   	push   %ebx
  8002ee:	83 ec 04             	sub    $0x4,%esp
  8002f1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8002f4:	8b 13                	mov    (%ebx),%edx
  8002f6:	8d 42 01             	lea    0x1(%edx),%eax
  8002f9:	89 03                	mov    %eax,(%ebx)
  8002fb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002fe:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800302:	3d ff 00 00 00       	cmp    $0xff,%eax
  800307:	75 1a                	jne    800323 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800309:	83 ec 08             	sub    $0x8,%esp
  80030c:	68 ff 00 00 00       	push   $0xff
  800311:	8d 43 08             	lea    0x8(%ebx),%eax
  800314:	50                   	push   %eax
  800315:	e8 fb 09 00 00       	call   800d15 <sys_cputs>
		b->idx = 0;
  80031a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800320:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800323:	ff 43 04             	incl   0x4(%ebx)
}
  800326:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800329:	c9                   	leave  
  80032a:	c3                   	ret    

0080032b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80032b:	55                   	push   %ebp
  80032c:	89 e5                	mov    %esp,%ebp
  80032e:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800334:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80033b:	00 00 00 
	b.cnt = 0;
  80033e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800345:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800348:	ff 75 0c             	pushl  0xc(%ebp)
  80034b:	ff 75 08             	pushl  0x8(%ebp)
  80034e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800354:	50                   	push   %eax
  800355:	68 ea 02 80 00       	push   $0x8002ea
  80035a:	e8 54 01 00 00       	call   8004b3 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80035f:	83 c4 08             	add    $0x8,%esp
  800362:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800368:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80036e:	50                   	push   %eax
  80036f:	e8 a1 09 00 00       	call   800d15 <sys_cputs>

	return b.cnt;
}
  800374:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80037a:	c9                   	leave  
  80037b:	c3                   	ret    

0080037c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80037c:	55                   	push   %ebp
  80037d:	89 e5                	mov    %esp,%ebp
  80037f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800382:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800385:	50                   	push   %eax
  800386:	ff 75 08             	pushl  0x8(%ebp)
  800389:	e8 9d ff ff ff       	call   80032b <vcprintf>
	va_end(ap);

	return cnt;
}
  80038e:	c9                   	leave  
  80038f:	c3                   	ret    

00800390 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800390:	55                   	push   %ebp
  800391:	89 e5                	mov    %esp,%ebp
  800393:	57                   	push   %edi
  800394:	56                   	push   %esi
  800395:	53                   	push   %ebx
  800396:	83 ec 1c             	sub    $0x1c,%esp
  800399:	89 c6                	mov    %eax,%esi
  80039b:	89 d7                	mov    %edx,%edi
  80039d:	8b 45 08             	mov    0x8(%ebp),%eax
  8003a0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003a3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003a6:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8003a9:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8003ac:	bb 00 00 00 00       	mov    $0x0,%ebx
  8003b1:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8003b4:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8003b7:	39 d3                	cmp    %edx,%ebx
  8003b9:	72 11                	jb     8003cc <printnum+0x3c>
  8003bb:	39 45 10             	cmp    %eax,0x10(%ebp)
  8003be:	76 0c                	jbe    8003cc <printnum+0x3c>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c3:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8003c6:	85 db                	test   %ebx,%ebx
  8003c8:	7f 37                	jg     800401 <printnum+0x71>
  8003ca:	eb 44                	jmp    800410 <printnum+0x80>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8003cc:	83 ec 0c             	sub    $0xc,%esp
  8003cf:	ff 75 18             	pushl  0x18(%ebp)
  8003d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d5:	48                   	dec    %eax
  8003d6:	50                   	push   %eax
  8003d7:	ff 75 10             	pushl  0x10(%ebp)
  8003da:	83 ec 08             	sub    $0x8,%esp
  8003dd:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003e0:	ff 75 e0             	pushl  -0x20(%ebp)
  8003e3:	ff 75 dc             	pushl  -0x24(%ebp)
  8003e6:	ff 75 d8             	pushl  -0x28(%ebp)
  8003e9:	e8 5a 1d 00 00       	call   802148 <__udivdi3>
  8003ee:	83 c4 18             	add    $0x18,%esp
  8003f1:	52                   	push   %edx
  8003f2:	50                   	push   %eax
  8003f3:	89 fa                	mov    %edi,%edx
  8003f5:	89 f0                	mov    %esi,%eax
  8003f7:	e8 94 ff ff ff       	call   800390 <printnum>
  8003fc:	83 c4 20             	add    $0x20,%esp
  8003ff:	eb 0f                	jmp    800410 <printnum+0x80>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800401:	83 ec 08             	sub    $0x8,%esp
  800404:	57                   	push   %edi
  800405:	ff 75 18             	pushl  0x18(%ebp)
  800408:	ff d6                	call   *%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80040a:	83 c4 10             	add    $0x10,%esp
  80040d:	4b                   	dec    %ebx
  80040e:	75 f1                	jne    800401 <printnum+0x71>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800410:	83 ec 08             	sub    $0x8,%esp
  800413:	57                   	push   %edi
  800414:	83 ec 04             	sub    $0x4,%esp
  800417:	ff 75 e4             	pushl  -0x1c(%ebp)
  80041a:	ff 75 e0             	pushl  -0x20(%ebp)
  80041d:	ff 75 dc             	pushl  -0x24(%ebp)
  800420:	ff 75 d8             	pushl  -0x28(%ebp)
  800423:	e8 30 1e 00 00       	call   802258 <__umoddi3>
  800428:	83 c4 14             	add    $0x14,%esp
  80042b:	0f be 80 9f 24 80 00 	movsbl 0x80249f(%eax),%eax
  800432:	50                   	push   %eax
  800433:	ff d6                	call   *%esi
}
  800435:	83 c4 10             	add    $0x10,%esp
  800438:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80043b:	5b                   	pop    %ebx
  80043c:	5e                   	pop    %esi
  80043d:	5f                   	pop    %edi
  80043e:	5d                   	pop    %ebp
  80043f:	c3                   	ret    

00800440 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800440:	55                   	push   %ebp
  800441:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800443:	83 fa 01             	cmp    $0x1,%edx
  800446:	7e 0e                	jle    800456 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800448:	8b 10                	mov    (%eax),%edx
  80044a:	8d 4a 08             	lea    0x8(%edx),%ecx
  80044d:	89 08                	mov    %ecx,(%eax)
  80044f:	8b 02                	mov    (%edx),%eax
  800451:	8b 52 04             	mov    0x4(%edx),%edx
  800454:	eb 22                	jmp    800478 <getuint+0x38>
	else if (lflag)
  800456:	85 d2                	test   %edx,%edx
  800458:	74 10                	je     80046a <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80045a:	8b 10                	mov    (%eax),%edx
  80045c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80045f:	89 08                	mov    %ecx,(%eax)
  800461:	8b 02                	mov    (%edx),%eax
  800463:	ba 00 00 00 00       	mov    $0x0,%edx
  800468:	eb 0e                	jmp    800478 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80046a:	8b 10                	mov    (%eax),%edx
  80046c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80046f:	89 08                	mov    %ecx,(%eax)
  800471:	8b 02                	mov    (%edx),%eax
  800473:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800478:	5d                   	pop    %ebp
  800479:	c3                   	ret    

0080047a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80047a:	55                   	push   %ebp
  80047b:	89 e5                	mov    %esp,%ebp
  80047d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800480:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800483:	8b 10                	mov    (%eax),%edx
  800485:	3b 50 04             	cmp    0x4(%eax),%edx
  800488:	73 0a                	jae    800494 <sprintputch+0x1a>
		*b->buf++ = ch;
  80048a:	8d 4a 01             	lea    0x1(%edx),%ecx
  80048d:	89 08                	mov    %ecx,(%eax)
  80048f:	8b 45 08             	mov    0x8(%ebp),%eax
  800492:	88 02                	mov    %al,(%edx)
}
  800494:	5d                   	pop    %ebp
  800495:	c3                   	ret    

00800496 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800496:	55                   	push   %ebp
  800497:	89 e5                	mov    %esp,%ebp
  800499:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80049c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80049f:	50                   	push   %eax
  8004a0:	ff 75 10             	pushl  0x10(%ebp)
  8004a3:	ff 75 0c             	pushl  0xc(%ebp)
  8004a6:	ff 75 08             	pushl  0x8(%ebp)
  8004a9:	e8 05 00 00 00       	call   8004b3 <vprintfmt>
	va_end(ap);
}
  8004ae:	83 c4 10             	add    $0x10,%esp
  8004b1:	c9                   	leave  
  8004b2:	c3                   	ret    

008004b3 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8004b3:	55                   	push   %ebp
  8004b4:	89 e5                	mov    %esp,%ebp
  8004b6:	57                   	push   %edi
  8004b7:	56                   	push   %esi
  8004b8:	53                   	push   %ebx
  8004b9:	83 ec 2c             	sub    $0x2c,%esp
  8004bc:	8b 7d 08             	mov    0x8(%ebp),%edi
  8004bf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004c2:	eb 03                	jmp    8004c7 <vprintfmt+0x14>
			break;

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
			for (fmt--; fmt[-1] != '%'; fmt--)
  8004c4:	89 75 10             	mov    %esi,0x10(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {    //遍历输入的第一个参数，即输出信息的格式，先把格式字符串中'%'之前的字符一个个输出，因为它们前面没有'%'，所以它们就是要直接显示在屏幕上的
  8004c7:	8b 45 10             	mov    0x10(%ebp),%eax
  8004ca:	8d 70 01             	lea    0x1(%eax),%esi
  8004cd:	0f b6 00             	movzbl (%eax),%eax
  8004d0:	83 f8 25             	cmp    $0x25,%eax
  8004d3:	74 25                	je     8004fa <vprintfmt+0x47>
			if (ch == '\0')									//当然中间如果遇到'\0'，代表这个字符串的访问结束
  8004d5:	85 c0                	test   %eax,%eax
  8004d7:	75 0d                	jne    8004e6 <vprintfmt+0x33>
  8004d9:	e9 b5 03 00 00       	jmp    800893 <vprintfmt+0x3e0>
  8004de:	85 c0                	test   %eax,%eax
  8004e0:	0f 84 ad 03 00 00    	je     800893 <vprintfmt+0x3e0>
				return;
			putch(ch, putdat);								//调用putch函数，把一个字符ch输出到putdat指针所指向的地址中所存放的值对应的地址处
  8004e6:	83 ec 08             	sub    $0x8,%esp
  8004e9:	53                   	push   %ebx
  8004ea:	50                   	push   %eax
  8004eb:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {    //遍历输入的第一个参数，即输出信息的格式，先把格式字符串中'%'之前的字符一个个输出，因为它们前面没有'%'，所以它们就是要直接显示在屏幕上的
  8004ed:	46                   	inc    %esi
  8004ee:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  8004f2:	83 c4 10             	add    $0x10,%esp
  8004f5:	83 f8 25             	cmp    $0x25,%eax
  8004f8:	75 e4                	jne    8004de <vprintfmt+0x2b>
			if (width < 0)									//代表有小数点，但是小数点前面并没有数字，比如'%.6f'这种情况，此时代表整数部分全部显示
				width = 0;			
			goto reswitch;

		case '#':
			altflag = 1;
  8004fa:	c6 45 e3 20          	movb   $0x20,-0x1d(%ebp)
  8004fe:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800505:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80050c:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800513:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  80051a:	eb 07                	jmp    800523 <vprintfmt+0x70>
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  80051c:	8b 75 10             	mov    0x10(%ebp),%esi

		// flag to pad on the right
		case '-':											//%后面的'-'代表要进行左对齐输出，右边填空格，如果省略代表右对齐
			padc = '-';										//如果有这个字符代表左对齐，则把对齐方式标志位变为'-'
  80051f:	c6 45 e3 2d          	movb   $0x2d,-0x1d(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  800523:	8d 46 01             	lea    0x1(%esi),%eax
  800526:	89 45 10             	mov    %eax,0x10(%ebp)
  800529:	0f b6 16             	movzbl (%esi),%edx
  80052c:	8a 06                	mov    (%esi),%al
  80052e:	83 e8 23             	sub    $0x23,%eax
  800531:	3c 55                	cmp    $0x55,%al
  800533:	0f 87 03 03 00 00    	ja     80083c <vprintfmt+0x389>
  800539:	0f b6 c0             	movzbl %al,%eax
  80053c:	ff 24 85 e0 25 80 00 	jmp    *0x8025e0(,%eax,4)
  800543:	8b 75 10             	mov    0x10(%ebp),%esi
			padc = '-';										//如果有这个字符代表左对齐，则把对齐方式标志位变为'-'
			goto reswitch;									//处理下一个字符

		// flag to pad with 0's instead of spaces
		case '0':											//0--有0表示进行对齐输出时填0,如省略表示填入空格，并且如果为0，则一定是右对齐
			padc = '0';										//对其方式标志位变为0
  800546:	c6 45 e3 30          	movb   $0x30,-0x1d(%ebp)
  80054a:	eb d7                	jmp    800523 <vprintfmt+0x70>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {					//把遇到的位数字符串转换为真实的位数，比如输入的'%40'，代表有效位数为40位，下面的循环就是把precesion的值设置为40
				precision = precision * 10 + ch - '0';
  80054c:	8d 42 d0             	lea    -0x30(%edx),%eax
  80054f:	89 c1                	mov    %eax,%ecx
  800551:	89 45 d0             	mov    %eax,-0x30(%ebp)
				ch = *fmt;
  800554:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  800558:	8d 50 d0             	lea    -0x30(%eax),%edx
  80055b:	83 fa 09             	cmp    $0x9,%edx
  80055e:	77 51                	ja     8005b1 <vprintfmt+0xfe>
  800560:	8b 75 10             	mov    0x10(%ebp),%esi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {					//把遇到的位数字符串转换为真实的位数，比如输入的'%40'，代表有效位数为40位，下面的循环就是把precesion的值设置为40
  800563:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  800564:	8d 14 89             	lea    (%ecx,%ecx,4),%edx
  800567:	01 d2                	add    %edx,%edx
  800569:	8d 4c 10 d0          	lea    -0x30(%eax,%edx,1),%ecx
				ch = *fmt;
  80056d:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800570:	8d 50 d0             	lea    -0x30(%eax),%edx
  800573:	83 fa 09             	cmp    $0x9,%edx
  800576:	76 eb                	jbe    800563 <vprintfmt+0xb0>
  800578:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  80057b:	eb 37                	jmp    8005b4 <vprintfmt+0x101>
					break;
			}
			goto process_precision;							//跳转到process_precistion子过程

		case '*':											//*--代表有效数字的位数也是由输入参数指定的，比如printf("%*.*f", 10, 2, n)，其中10,2就是用来指定显示的有效数字位数的
			precision = va_arg(ap, int);
  80057d:	8b 45 14             	mov    0x14(%ebp),%eax
  800580:	8d 50 04             	lea    0x4(%eax),%edx
  800583:	89 55 14             	mov    %edx,0x14(%ebp)
  800586:	8b 00                	mov    (%eax),%eax
  800588:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  80058b:	8b 75 10             	mov    0x10(%ebp),%esi
			}
			goto process_precision;							//跳转到process_precistion子过程

		case '*':											//*--代表有效数字的位数也是由输入参数指定的，比如printf("%*.*f", 10, 2, n)，其中10,2就是用来指定显示的有效数字位数的
			precision = va_arg(ap, int);
			goto process_precision;
  80058e:	eb 24                	jmp    8005b4 <vprintfmt+0x101>
  800590:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800594:	79 07                	jns    80059d <vprintfmt+0xea>
  800596:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  80059d:	8b 75 10             	mov    0x10(%ebp),%esi
  8005a0:	eb 81                	jmp    800523 <vprintfmt+0x70>
  8005a2:	8b 75 10             	mov    0x10(%ebp),%esi
			if (width < 0)									//代表有小数点，但是小数点前面并没有数字，比如'%.6f'这种情况，此时代表整数部分全部显示
				width = 0;			
			goto reswitch;

		case '#':
			altflag = 1;
  8005a5:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8005ac:	e9 72 ff ff ff       	jmp    800523 <vprintfmt+0x70>
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  8005b1:	8b 75 10             	mov    0x10(%ebp),%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:									//处理输出精度，把width字段赋值为刚刚计算出来的precision值，所以width应该是整数部分的有效数字位数
			if (width < 0)
  8005b4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005b8:	0f 89 65 ff ff ff    	jns    800523 <vprintfmt+0x70>
				width = precision, precision = -1;
  8005be:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8005c1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8005c4:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8005cb:	e9 53 ff ff ff       	jmp    800523 <vprintfmt+0x70>
			goto reswitch;

		// long flag (doubled for long long)				
		case 'l':											//如果遇到'l'，代表应该是输入long类型，如果有两个'l'代表long long
			lflag++;										//此时把lflag++
  8005d0:	ff 45 d4             	incl   -0x2c(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  8005d3:	8b 75 10             	mov    0x10(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)				
		case 'l':											//如果遇到'l'，代表应该是输入long类型，如果有两个'l'代表long long
			lflag++;										//此时把lflag++
			goto reswitch;
  8005d6:	e9 48 ff ff ff       	jmp    800523 <vprintfmt+0x70>

		// character
		case 'c':											//如果是'c'代表显示一个字符
			putch(va_arg(ap, int), putdat);					//调用输出一个字符到内存的函数putch
  8005db:	8b 45 14             	mov    0x14(%ebp),%eax
  8005de:	8d 50 04             	lea    0x4(%eax),%edx
  8005e1:	89 55 14             	mov    %edx,0x14(%ebp)
  8005e4:	83 ec 08             	sub    $0x8,%esp
  8005e7:	53                   	push   %ebx
  8005e8:	ff 30                	pushl  (%eax)
  8005ea:	ff d7                	call   *%edi
			break;
  8005ec:	83 c4 10             	add    $0x10,%esp
  8005ef:	e9 d3 fe ff ff       	jmp    8004c7 <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8005f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f7:	8d 50 04             	lea    0x4(%eax),%edx
  8005fa:	89 55 14             	mov    %edx,0x14(%ebp)
  8005fd:	8b 00                	mov    (%eax),%eax
  8005ff:	85 c0                	test   %eax,%eax
  800601:	79 02                	jns    800605 <vprintfmt+0x152>
  800603:	f7 d8                	neg    %eax
  800605:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800607:	83 f8 0f             	cmp    $0xf,%eax
  80060a:	7f 0b                	jg     800617 <vprintfmt+0x164>
  80060c:	8b 04 85 40 27 80 00 	mov    0x802740(,%eax,4),%eax
  800613:	85 c0                	test   %eax,%eax
  800615:	75 15                	jne    80062c <vprintfmt+0x179>
				printfmt(putch, putdat, "error %d", err);
  800617:	52                   	push   %edx
  800618:	68 b7 24 80 00       	push   $0x8024b7
  80061d:	53                   	push   %ebx
  80061e:	57                   	push   %edi
  80061f:	e8 72 fe ff ff       	call   800496 <printfmt>
  800624:	83 c4 10             	add    $0x10,%esp
  800627:	e9 9b fe ff ff       	jmp    8004c7 <vprintfmt+0x14>
			else
				printfmt(putch, putdat, "%s", p);
  80062c:	50                   	push   %eax
  80062d:	68 4a 29 80 00       	push   $0x80294a
  800632:	53                   	push   %ebx
  800633:	57                   	push   %edi
  800634:	e8 5d fe ff ff       	call   800496 <printfmt>
  800639:	83 c4 10             	add    $0x10,%esp
  80063c:	e9 86 fe ff ff       	jmp    8004c7 <vprintfmt+0x14>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800641:	8b 45 14             	mov    0x14(%ebp),%eax
  800644:	8d 50 04             	lea    0x4(%eax),%edx
  800647:	89 55 14             	mov    %edx,0x14(%ebp)
  80064a:	8b 00                	mov    (%eax),%eax
  80064c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80064f:	85 c0                	test   %eax,%eax
  800651:	75 07                	jne    80065a <vprintfmt+0x1a7>
				p = "(null)";
  800653:	c7 45 d4 b0 24 80 00 	movl   $0x8024b0,-0x2c(%ebp)
			if (width > 0 && padc != '-')
  80065a:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80065d:	85 f6                	test   %esi,%esi
  80065f:	0f 8e fb 01 00 00    	jle    800860 <vprintfmt+0x3ad>
  800665:	80 7d e3 2d          	cmpb   $0x2d,-0x1d(%ebp)
  800669:	0f 84 09 02 00 00    	je     800878 <vprintfmt+0x3c5>
				for (width -= strnlen(p, precision); width > 0; width--)
  80066f:	83 ec 08             	sub    $0x8,%esp
  800672:	ff 75 d0             	pushl  -0x30(%ebp)
  800675:	ff 75 d4             	pushl  -0x2c(%ebp)
  800678:	e8 ad 02 00 00       	call   80092a <strnlen>
  80067d:	89 f1                	mov    %esi,%ecx
  80067f:	29 c1                	sub    %eax,%ecx
  800681:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  800684:	83 c4 10             	add    $0x10,%esp
  800687:	85 c9                	test   %ecx,%ecx
  800689:	0f 8e d1 01 00 00    	jle    800860 <vprintfmt+0x3ad>
					putch(padc, putdat);
  80068f:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  800693:	83 ec 08             	sub    $0x8,%esp
  800696:	53                   	push   %ebx
  800697:	56                   	push   %esi
  800698:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80069a:	83 c4 10             	add    $0x10,%esp
  80069d:	ff 4d e4             	decl   -0x1c(%ebp)
  8006a0:	75 f1                	jne    800693 <vprintfmt+0x1e0>
  8006a2:	e9 b9 01 00 00       	jmp    800860 <vprintfmt+0x3ad>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8006a7:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8006ab:	74 19                	je     8006c6 <vprintfmt+0x213>
  8006ad:	0f be c0             	movsbl %al,%eax
  8006b0:	83 e8 20             	sub    $0x20,%eax
  8006b3:	83 f8 5e             	cmp    $0x5e,%eax
  8006b6:	76 0e                	jbe    8006c6 <vprintfmt+0x213>
					putch('?', putdat);
  8006b8:	83 ec 08             	sub    $0x8,%esp
  8006bb:	53                   	push   %ebx
  8006bc:	6a 3f                	push   $0x3f
  8006be:	ff 55 08             	call   *0x8(%ebp)
  8006c1:	83 c4 10             	add    $0x10,%esp
  8006c4:	eb 0b                	jmp    8006d1 <vprintfmt+0x21e>
				else
					putch(ch, putdat);
  8006c6:	83 ec 08             	sub    $0x8,%esp
  8006c9:	53                   	push   %ebx
  8006ca:	52                   	push   %edx
  8006cb:	ff 55 08             	call   *0x8(%ebp)
  8006ce:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006d1:	ff 4d e4             	decl   -0x1c(%ebp)
  8006d4:	46                   	inc    %esi
  8006d5:	8a 46 ff             	mov    -0x1(%esi),%al
  8006d8:	0f be d0             	movsbl %al,%edx
  8006db:	85 d2                	test   %edx,%edx
  8006dd:	75 1c                	jne    8006fb <vprintfmt+0x248>
  8006df:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006e2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8006e6:	7f 1f                	jg     800707 <vprintfmt+0x254>
  8006e8:	e9 da fd ff ff       	jmp    8004c7 <vprintfmt+0x14>
  8006ed:	89 7d 08             	mov    %edi,0x8(%ebp)
  8006f0:	8b 7d d0             	mov    -0x30(%ebp),%edi
  8006f3:	eb 06                	jmp    8006fb <vprintfmt+0x248>
  8006f5:	89 7d 08             	mov    %edi,0x8(%ebp)
  8006f8:	8b 7d d0             	mov    -0x30(%ebp),%edi
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006fb:	85 ff                	test   %edi,%edi
  8006fd:	78 a8                	js     8006a7 <vprintfmt+0x1f4>
  8006ff:	4f                   	dec    %edi
  800700:	79 a5                	jns    8006a7 <vprintfmt+0x1f4>
  800702:	8b 7d 08             	mov    0x8(%ebp),%edi
  800705:	eb db                	jmp    8006e2 <vprintfmt+0x22f>
  800707:	8b 75 e4             	mov    -0x1c(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80070a:	83 ec 08             	sub    $0x8,%esp
  80070d:	53                   	push   %ebx
  80070e:	6a 20                	push   $0x20
  800710:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800712:	4e                   	dec    %esi
  800713:	83 c4 10             	add    $0x10,%esp
  800716:	85 f6                	test   %esi,%esi
  800718:	7f f0                	jg     80070a <vprintfmt+0x257>
  80071a:	e9 a8 fd ff ff       	jmp    8004c7 <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80071f:	83 7d d4 01          	cmpl   $0x1,-0x2c(%ebp)
  800723:	7e 16                	jle    80073b <vprintfmt+0x288>
		return va_arg(*ap, long long);
  800725:	8b 45 14             	mov    0x14(%ebp),%eax
  800728:	8d 50 08             	lea    0x8(%eax),%edx
  80072b:	89 55 14             	mov    %edx,0x14(%ebp)
  80072e:	8b 50 04             	mov    0x4(%eax),%edx
  800731:	8b 00                	mov    (%eax),%eax
  800733:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800736:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800739:	eb 34                	jmp    80076f <vprintfmt+0x2bc>
	else if (lflag)
  80073b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80073f:	74 18                	je     800759 <vprintfmt+0x2a6>
		return va_arg(*ap, long);
  800741:	8b 45 14             	mov    0x14(%ebp),%eax
  800744:	8d 50 04             	lea    0x4(%eax),%edx
  800747:	89 55 14             	mov    %edx,0x14(%ebp)
  80074a:	8b 30                	mov    (%eax),%esi
  80074c:	89 75 d8             	mov    %esi,-0x28(%ebp)
  80074f:	89 f0                	mov    %esi,%eax
  800751:	c1 f8 1f             	sar    $0x1f,%eax
  800754:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800757:	eb 16                	jmp    80076f <vprintfmt+0x2bc>
	else
		return va_arg(*ap, int);
  800759:	8b 45 14             	mov    0x14(%ebp),%eax
  80075c:	8d 50 04             	lea    0x4(%eax),%edx
  80075f:	89 55 14             	mov    %edx,0x14(%ebp)
  800762:	8b 30                	mov    (%eax),%esi
  800764:	89 75 d8             	mov    %esi,-0x28(%ebp)
  800767:	89 f0                	mov    %esi,%eax
  800769:	c1 f8 1f             	sar    $0x1f,%eax
  80076c:	89 45 dc             	mov    %eax,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80076f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800772:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
  800775:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800779:	0f 89 8a 00 00 00    	jns    800809 <vprintfmt+0x356>
				putch('-', putdat);
  80077f:	83 ec 08             	sub    $0x8,%esp
  800782:	53                   	push   %ebx
  800783:	6a 2d                	push   $0x2d
  800785:	ff d7                	call   *%edi
				num = -(long long) num;
  800787:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80078a:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80078d:	f7 d8                	neg    %eax
  80078f:	83 d2 00             	adc    $0x0,%edx
  800792:	f7 da                	neg    %edx
  800794:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800797:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80079c:	eb 70                	jmp    80080e <vprintfmt+0x35b>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80079e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8007a1:	8d 45 14             	lea    0x14(%ebp),%eax
  8007a4:	e8 97 fc ff ff       	call   800440 <getuint>
			base = 10;
  8007a9:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8007ae:	eb 5e                	jmp    80080e <vprintfmt+0x35b>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
  8007b0:	83 ec 08             	sub    $0x8,%esp
  8007b3:	53                   	push   %ebx
  8007b4:	6a 30                	push   $0x30
  8007b6:	ff d7                	call   *%edi
			num = getuint(&ap, lflag);
  8007b8:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8007bb:	8d 45 14             	lea    0x14(%ebp),%eax
  8007be:	e8 7d fc ff ff       	call   800440 <getuint>
			base = 8;
			goto number;
  8007c3:	83 c4 10             	add    $0x10,%esp
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  8007c6:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8007cb:	eb 41                	jmp    80080e <vprintfmt+0x35b>
		// pointer
		case 'p':
			putch('0', putdat);
  8007cd:	83 ec 08             	sub    $0x8,%esp
  8007d0:	53                   	push   %ebx
  8007d1:	6a 30                	push   $0x30
  8007d3:	ff d7                	call   *%edi
			putch('x', putdat);
  8007d5:	83 c4 08             	add    $0x8,%esp
  8007d8:	53                   	push   %ebx
  8007d9:	6a 78                	push   $0x78
  8007db:	ff d7                	call   *%edi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8007dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e0:	8d 50 04             	lea    0x4(%eax),%edx
  8007e3:	89 55 14             	mov    %edx,0x14(%ebp)
			goto number;
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8007e6:	8b 00                	mov    (%eax),%eax
  8007e8:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8007ed:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8007f0:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8007f5:	eb 17                	jmp    80080e <vprintfmt+0x35b>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8007f7:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8007fa:	8d 45 14             	lea    0x14(%ebp),%eax
  8007fd:	e8 3e fc ff ff       	call   800440 <getuint>
			base = 16;
  800802:	b9 10 00 00 00       	mov    $0x10,%ecx
  800807:	eb 05                	jmp    80080e <vprintfmt+0x35b>
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800809:	b9 0a 00 00 00       	mov    $0xa,%ecx
		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  80080e:	83 ec 0c             	sub    $0xc,%esp
  800811:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  800815:	56                   	push   %esi
  800816:	ff 75 e4             	pushl  -0x1c(%ebp)
  800819:	51                   	push   %ecx
  80081a:	52                   	push   %edx
  80081b:	50                   	push   %eax
  80081c:	89 da                	mov    %ebx,%edx
  80081e:	89 f8                	mov    %edi,%eax
  800820:	e8 6b fb ff ff       	call   800390 <printnum>
			break;
  800825:	83 c4 20             	add    $0x20,%esp
  800828:	e9 9a fc ff ff       	jmp    8004c7 <vprintfmt+0x14>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80082d:	83 ec 08             	sub    $0x8,%esp
  800830:	53                   	push   %ebx
  800831:	52                   	push   %edx
  800832:	ff d7                	call   *%edi
			break;
  800834:	83 c4 10             	add    $0x10,%esp
  800837:	e9 8b fc ff ff       	jmp    8004c7 <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80083c:	83 ec 08             	sub    $0x8,%esp
  80083f:	53                   	push   %ebx
  800840:	6a 25                	push   $0x25
  800842:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800844:	83 c4 10             	add    $0x10,%esp
  800847:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80084b:	0f 84 73 fc ff ff    	je     8004c4 <vprintfmt+0x11>
  800851:	4e                   	dec    %esi
  800852:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800856:	75 f9                	jne    800851 <vprintfmt+0x39e>
  800858:	89 75 10             	mov    %esi,0x10(%ebp)
  80085b:	e9 67 fc ff ff       	jmp    8004c7 <vprintfmt+0x14>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800860:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800863:	8d 70 01             	lea    0x1(%eax),%esi
  800866:	8a 00                	mov    (%eax),%al
  800868:	0f be d0             	movsbl %al,%edx
  80086b:	85 d2                	test   %edx,%edx
  80086d:	0f 85 7a fe ff ff    	jne    8006ed <vprintfmt+0x23a>
  800873:	e9 4f fc ff ff       	jmp    8004c7 <vprintfmt+0x14>
  800878:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80087b:	8d 70 01             	lea    0x1(%eax),%esi
  80087e:	8a 00                	mov    (%eax),%al
  800880:	0f be d0             	movsbl %al,%edx
  800883:	85 d2                	test   %edx,%edx
  800885:	0f 85 6a fe ff ff    	jne    8006f5 <vprintfmt+0x242>
  80088b:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80088e:	e9 77 fe ff ff       	jmp    80070a <vprintfmt+0x257>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800893:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800896:	5b                   	pop    %ebx
  800897:	5e                   	pop    %esi
  800898:	5f                   	pop    %edi
  800899:	5d                   	pop    %ebp
  80089a:	c3                   	ret    

0080089b <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80089b:	55                   	push   %ebp
  80089c:	89 e5                	mov    %esp,%ebp
  80089e:	83 ec 18             	sub    $0x18,%esp
  8008a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a4:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008a7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008aa:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008ae:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008b1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008b8:	85 c0                	test   %eax,%eax
  8008ba:	74 26                	je     8008e2 <vsnprintf+0x47>
  8008bc:	85 d2                	test   %edx,%edx
  8008be:	7e 29                	jle    8008e9 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008c0:	ff 75 14             	pushl  0x14(%ebp)
  8008c3:	ff 75 10             	pushl  0x10(%ebp)
  8008c6:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008c9:	50                   	push   %eax
  8008ca:	68 7a 04 80 00       	push   $0x80047a
  8008cf:	e8 df fb ff ff       	call   8004b3 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008d4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008d7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008da:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008dd:	83 c4 10             	add    $0x10,%esp
  8008e0:	eb 0c                	jmp    8008ee <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8008e2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008e7:	eb 05                	jmp    8008ee <vsnprintf+0x53>
  8008e9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8008ee:	c9                   	leave  
  8008ef:	c3                   	ret    

008008f0 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008f0:	55                   	push   %ebp
  8008f1:	89 e5                	mov    %esp,%ebp
  8008f3:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008f6:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008f9:	50                   	push   %eax
  8008fa:	ff 75 10             	pushl  0x10(%ebp)
  8008fd:	ff 75 0c             	pushl  0xc(%ebp)
  800900:	ff 75 08             	pushl  0x8(%ebp)
  800903:	e8 93 ff ff ff       	call   80089b <vsnprintf>
	va_end(ap);

	return rc;
}
  800908:	c9                   	leave  
  800909:	c3                   	ret    

0080090a <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80090a:	55                   	push   %ebp
  80090b:	89 e5                	mov    %esp,%ebp
  80090d:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800910:	80 3a 00             	cmpb   $0x0,(%edx)
  800913:	74 0e                	je     800923 <strlen+0x19>
  800915:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  80091a:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80091b:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80091f:	75 f9                	jne    80091a <strlen+0x10>
  800921:	eb 05                	jmp    800928 <strlen+0x1e>
  800923:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800928:	5d                   	pop    %ebp
  800929:	c3                   	ret    

0080092a <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80092a:	55                   	push   %ebp
  80092b:	89 e5                	mov    %esp,%ebp
  80092d:	53                   	push   %ebx
  80092e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800931:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800934:	85 c9                	test   %ecx,%ecx
  800936:	74 1a                	je     800952 <strnlen+0x28>
  800938:	80 3b 00             	cmpb   $0x0,(%ebx)
  80093b:	74 1c                	je     800959 <strnlen+0x2f>
  80093d:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  800942:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800944:	39 ca                	cmp    %ecx,%edx
  800946:	74 16                	je     80095e <strnlen+0x34>
  800948:	42                   	inc    %edx
  800949:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  80094e:	75 f2                	jne    800942 <strnlen+0x18>
  800950:	eb 0c                	jmp    80095e <strnlen+0x34>
  800952:	b8 00 00 00 00       	mov    $0x0,%eax
  800957:	eb 05                	jmp    80095e <strnlen+0x34>
  800959:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  80095e:	5b                   	pop    %ebx
  80095f:	5d                   	pop    %ebp
  800960:	c3                   	ret    

00800961 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800961:	55                   	push   %ebp
  800962:	89 e5                	mov    %esp,%ebp
  800964:	53                   	push   %ebx
  800965:	8b 45 08             	mov    0x8(%ebp),%eax
  800968:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80096b:	89 c2                	mov    %eax,%edx
  80096d:	42                   	inc    %edx
  80096e:	41                   	inc    %ecx
  80096f:	8a 59 ff             	mov    -0x1(%ecx),%bl
  800972:	88 5a ff             	mov    %bl,-0x1(%edx)
  800975:	84 db                	test   %bl,%bl
  800977:	75 f4                	jne    80096d <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800979:	5b                   	pop    %ebx
  80097a:	5d                   	pop    %ebp
  80097b:	c3                   	ret    

0080097c <strcat>:

char *
strcat(char *dst, const char *src)
{
  80097c:	55                   	push   %ebp
  80097d:	89 e5                	mov    %esp,%ebp
  80097f:	53                   	push   %ebx
  800980:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800983:	53                   	push   %ebx
  800984:	e8 81 ff ff ff       	call   80090a <strlen>
  800989:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80098c:	ff 75 0c             	pushl  0xc(%ebp)
  80098f:	01 d8                	add    %ebx,%eax
  800991:	50                   	push   %eax
  800992:	e8 ca ff ff ff       	call   800961 <strcpy>
	return dst;
}
  800997:	89 d8                	mov    %ebx,%eax
  800999:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80099c:	c9                   	leave  
  80099d:	c3                   	ret    

0080099e <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80099e:	55                   	push   %ebp
  80099f:	89 e5                	mov    %esp,%ebp
  8009a1:	56                   	push   %esi
  8009a2:	53                   	push   %ebx
  8009a3:	8b 75 08             	mov    0x8(%ebp),%esi
  8009a6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009a9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009ac:	85 db                	test   %ebx,%ebx
  8009ae:	74 14                	je     8009c4 <strncpy+0x26>
  8009b0:	01 f3                	add    %esi,%ebx
  8009b2:	89 f1                	mov    %esi,%ecx
		*dst++ = *src;
  8009b4:	41                   	inc    %ecx
  8009b5:	8a 02                	mov    (%edx),%al
  8009b7:	88 41 ff             	mov    %al,-0x1(%ecx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009ba:	80 3a 01             	cmpb   $0x1,(%edx)
  8009bd:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009c0:	39 cb                	cmp    %ecx,%ebx
  8009c2:	75 f0                	jne    8009b4 <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8009c4:	89 f0                	mov    %esi,%eax
  8009c6:	5b                   	pop    %ebx
  8009c7:	5e                   	pop    %esi
  8009c8:	5d                   	pop    %ebp
  8009c9:	c3                   	ret    

008009ca <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009ca:	55                   	push   %ebp
  8009cb:	89 e5                	mov    %esp,%ebp
  8009cd:	53                   	push   %ebx
  8009ce:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8009d1:	8b 45 10             	mov    0x10(%ebp),%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009d4:	85 c0                	test   %eax,%eax
  8009d6:	74 30                	je     800a08 <strlcpy+0x3e>
		while (--size > 0 && *src != '\0')
  8009d8:	48                   	dec    %eax
  8009d9:	74 20                	je     8009fb <strlcpy+0x31>
  8009db:	8a 0b                	mov    (%ebx),%cl
  8009dd:	84 c9                	test   %cl,%cl
  8009df:	74 1f                	je     800a00 <strlcpy+0x36>
  8009e1:	8d 53 01             	lea    0x1(%ebx),%edx
  8009e4:	01 c3                	add    %eax,%ebx
  8009e6:	8b 45 08             	mov    0x8(%ebp),%eax
			*dst++ = *src++;
  8009e9:	40                   	inc    %eax
  8009ea:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8009ed:	39 da                	cmp    %ebx,%edx
  8009ef:	74 12                	je     800a03 <strlcpy+0x39>
  8009f1:	42                   	inc    %edx
  8009f2:	8a 4a ff             	mov    -0x1(%edx),%cl
  8009f5:	84 c9                	test   %cl,%cl
  8009f7:	75 f0                	jne    8009e9 <strlcpy+0x1f>
  8009f9:	eb 08                	jmp    800a03 <strlcpy+0x39>
  8009fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8009fe:	eb 03                	jmp    800a03 <strlcpy+0x39>
  800a00:	8b 45 08             	mov    0x8(%ebp),%eax
			*dst++ = *src++;
		*dst = '\0';
  800a03:	c6 00 00             	movb   $0x0,(%eax)
  800a06:	eb 03                	jmp    800a0b <strlcpy+0x41>
  800a08:	8b 45 08             	mov    0x8(%ebp),%eax
	}
	return dst - dst_in;
  800a0b:	2b 45 08             	sub    0x8(%ebp),%eax
}
  800a0e:	5b                   	pop    %ebx
  800a0f:	5d                   	pop    %ebp
  800a10:	c3                   	ret    

00800a11 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a11:	55                   	push   %ebp
  800a12:	89 e5                	mov    %esp,%ebp
  800a14:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a17:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a1a:	8a 01                	mov    (%ecx),%al
  800a1c:	84 c0                	test   %al,%al
  800a1e:	74 10                	je     800a30 <strcmp+0x1f>
  800a20:	3a 02                	cmp    (%edx),%al
  800a22:	75 0c                	jne    800a30 <strcmp+0x1f>
		p++, q++;
  800a24:	41                   	inc    %ecx
  800a25:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a26:	8a 01                	mov    (%ecx),%al
  800a28:	84 c0                	test   %al,%al
  800a2a:	74 04                	je     800a30 <strcmp+0x1f>
  800a2c:	3a 02                	cmp    (%edx),%al
  800a2e:	74 f4                	je     800a24 <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a30:	0f b6 c0             	movzbl %al,%eax
  800a33:	0f b6 12             	movzbl (%edx),%edx
  800a36:	29 d0                	sub    %edx,%eax
}
  800a38:	5d                   	pop    %ebp
  800a39:	c3                   	ret    

00800a3a <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a3a:	55                   	push   %ebp
  800a3b:	89 e5                	mov    %esp,%ebp
  800a3d:	56                   	push   %esi
  800a3e:	53                   	push   %ebx
  800a3f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800a42:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a45:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  800a48:	85 f6                	test   %esi,%esi
  800a4a:	74 23                	je     800a6f <strncmp+0x35>
  800a4c:	8a 03                	mov    (%ebx),%al
  800a4e:	84 c0                	test   %al,%al
  800a50:	74 2b                	je     800a7d <strncmp+0x43>
  800a52:	3a 02                	cmp    (%edx),%al
  800a54:	75 27                	jne    800a7d <strncmp+0x43>
  800a56:	8d 43 01             	lea    0x1(%ebx),%eax
  800a59:	01 de                	add    %ebx,%esi
		n--, p++, q++;
  800a5b:	89 c3                	mov    %eax,%ebx
  800a5d:	42                   	inc    %edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a5e:	39 c6                	cmp    %eax,%esi
  800a60:	74 14                	je     800a76 <strncmp+0x3c>
  800a62:	8a 08                	mov    (%eax),%cl
  800a64:	84 c9                	test   %cl,%cl
  800a66:	74 15                	je     800a7d <strncmp+0x43>
  800a68:	40                   	inc    %eax
  800a69:	3a 0a                	cmp    (%edx),%cl
  800a6b:	74 ee                	je     800a5b <strncmp+0x21>
  800a6d:	eb 0e                	jmp    800a7d <strncmp+0x43>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a6f:	b8 00 00 00 00       	mov    $0x0,%eax
  800a74:	eb 0f                	jmp    800a85 <strncmp+0x4b>
  800a76:	b8 00 00 00 00       	mov    $0x0,%eax
  800a7b:	eb 08                	jmp    800a85 <strncmp+0x4b>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a7d:	0f b6 03             	movzbl (%ebx),%eax
  800a80:	0f b6 12             	movzbl (%edx),%edx
  800a83:	29 d0                	sub    %edx,%eax
}
  800a85:	5b                   	pop    %ebx
  800a86:	5e                   	pop    %esi
  800a87:	5d                   	pop    %ebp
  800a88:	c3                   	ret    

00800a89 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a89:	55                   	push   %ebp
  800a8a:	89 e5                	mov    %esp,%ebp
  800a8c:	53                   	push   %ebx
  800a8d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a90:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  800a93:	8a 10                	mov    (%eax),%dl
  800a95:	84 d2                	test   %dl,%dl
  800a97:	74 1a                	je     800ab3 <strchr+0x2a>
  800a99:	88 d9                	mov    %bl,%cl
		if (*s == c)
  800a9b:	38 d3                	cmp    %dl,%bl
  800a9d:	75 06                	jne    800aa5 <strchr+0x1c>
  800a9f:	eb 17                	jmp    800ab8 <strchr+0x2f>
  800aa1:	38 ca                	cmp    %cl,%dl
  800aa3:	74 13                	je     800ab8 <strchr+0x2f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800aa5:	40                   	inc    %eax
  800aa6:	8a 10                	mov    (%eax),%dl
  800aa8:	84 d2                	test   %dl,%dl
  800aaa:	75 f5                	jne    800aa1 <strchr+0x18>
		if (*s == c)
			return (char *) s;
	return 0;
  800aac:	b8 00 00 00 00       	mov    $0x0,%eax
  800ab1:	eb 05                	jmp    800ab8 <strchr+0x2f>
  800ab3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ab8:	5b                   	pop    %ebx
  800ab9:	5d                   	pop    %ebp
  800aba:	c3                   	ret    

00800abb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800abb:	55                   	push   %ebp
  800abc:	89 e5                	mov    %esp,%ebp
  800abe:	53                   	push   %ebx
  800abf:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  800ac5:	8a 10                	mov    (%eax),%dl
  800ac7:	84 d2                	test   %dl,%dl
  800ac9:	74 13                	je     800ade <strfind+0x23>
  800acb:	88 d9                	mov    %bl,%cl
		if (*s == c)
  800acd:	38 d3                	cmp    %dl,%bl
  800acf:	75 06                	jne    800ad7 <strfind+0x1c>
  800ad1:	eb 0b                	jmp    800ade <strfind+0x23>
  800ad3:	38 ca                	cmp    %cl,%dl
  800ad5:	74 07                	je     800ade <strfind+0x23>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800ad7:	40                   	inc    %eax
  800ad8:	8a 10                	mov    (%eax),%dl
  800ada:	84 d2                	test   %dl,%dl
  800adc:	75 f5                	jne    800ad3 <strfind+0x18>
		if (*s == c)
			break;
	return (char *) s;
}
  800ade:	5b                   	pop    %ebx
  800adf:	5d                   	pop    %ebp
  800ae0:	c3                   	ret    

00800ae1 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ae1:	55                   	push   %ebp
  800ae2:	89 e5                	mov    %esp,%ebp
  800ae4:	57                   	push   %edi
  800ae5:	56                   	push   %esi
  800ae6:	53                   	push   %ebx
  800ae7:	8b 7d 08             	mov    0x8(%ebp),%edi
  800aea:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800aed:	85 c9                	test   %ecx,%ecx
  800aef:	74 36                	je     800b27 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800af1:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800af7:	75 28                	jne    800b21 <memset+0x40>
  800af9:	f6 c1 03             	test   $0x3,%cl
  800afc:	75 23                	jne    800b21 <memset+0x40>
		c &= 0xFF;
  800afe:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b02:	89 d3                	mov    %edx,%ebx
  800b04:	c1 e3 08             	shl    $0x8,%ebx
  800b07:	89 d6                	mov    %edx,%esi
  800b09:	c1 e6 18             	shl    $0x18,%esi
  800b0c:	89 d0                	mov    %edx,%eax
  800b0e:	c1 e0 10             	shl    $0x10,%eax
  800b11:	09 f0                	or     %esi,%eax
  800b13:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800b15:	89 d8                	mov    %ebx,%eax
  800b17:	09 d0                	or     %edx,%eax
  800b19:	c1 e9 02             	shr    $0x2,%ecx
  800b1c:	fc                   	cld    
  800b1d:	f3 ab                	rep stos %eax,%es:(%edi)
  800b1f:	eb 06                	jmp    800b27 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b21:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b24:	fc                   	cld    
  800b25:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b27:	89 f8                	mov    %edi,%eax
  800b29:	5b                   	pop    %ebx
  800b2a:	5e                   	pop    %esi
  800b2b:	5f                   	pop    %edi
  800b2c:	5d                   	pop    %ebp
  800b2d:	c3                   	ret    

00800b2e <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b2e:	55                   	push   %ebp
  800b2f:	89 e5                	mov    %esp,%ebp
  800b31:	57                   	push   %edi
  800b32:	56                   	push   %esi
  800b33:	8b 45 08             	mov    0x8(%ebp),%eax
  800b36:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b39:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b3c:	39 c6                	cmp    %eax,%esi
  800b3e:	73 33                	jae    800b73 <memmove+0x45>
  800b40:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b43:	39 d0                	cmp    %edx,%eax
  800b45:	73 2c                	jae    800b73 <memmove+0x45>
		s += n;
		d += n;
  800b47:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b4a:	89 d6                	mov    %edx,%esi
  800b4c:	09 fe                	or     %edi,%esi
  800b4e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b54:	75 13                	jne    800b69 <memmove+0x3b>
  800b56:	f6 c1 03             	test   $0x3,%cl
  800b59:	75 0e                	jne    800b69 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800b5b:	83 ef 04             	sub    $0x4,%edi
  800b5e:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b61:	c1 e9 02             	shr    $0x2,%ecx
  800b64:	fd                   	std    
  800b65:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b67:	eb 07                	jmp    800b70 <memmove+0x42>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b69:	4f                   	dec    %edi
  800b6a:	8d 72 ff             	lea    -0x1(%edx),%esi
  800b6d:	fd                   	std    
  800b6e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b70:	fc                   	cld    
  800b71:	eb 1d                	jmp    800b90 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b73:	89 f2                	mov    %esi,%edx
  800b75:	09 c2                	or     %eax,%edx
  800b77:	f6 c2 03             	test   $0x3,%dl
  800b7a:	75 0f                	jne    800b8b <memmove+0x5d>
  800b7c:	f6 c1 03             	test   $0x3,%cl
  800b7f:	75 0a                	jne    800b8b <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
  800b81:	c1 e9 02             	shr    $0x2,%ecx
  800b84:	89 c7                	mov    %eax,%edi
  800b86:	fc                   	cld    
  800b87:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b89:	eb 05                	jmp    800b90 <memmove+0x62>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b8b:	89 c7                	mov    %eax,%edi
  800b8d:	fc                   	cld    
  800b8e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b90:	5e                   	pop    %esi
  800b91:	5f                   	pop    %edi
  800b92:	5d                   	pop    %ebp
  800b93:	c3                   	ret    

00800b94 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b94:	55                   	push   %ebp
  800b95:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b97:	ff 75 10             	pushl  0x10(%ebp)
  800b9a:	ff 75 0c             	pushl  0xc(%ebp)
  800b9d:	ff 75 08             	pushl  0x8(%ebp)
  800ba0:	e8 89 ff ff ff       	call   800b2e <memmove>
}
  800ba5:	c9                   	leave  
  800ba6:	c3                   	ret    

00800ba7 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ba7:	55                   	push   %ebp
  800ba8:	89 e5                	mov    %esp,%ebp
  800baa:	57                   	push   %edi
  800bab:	56                   	push   %esi
  800bac:	53                   	push   %ebx
  800bad:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800bb0:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bb3:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bb6:	85 c0                	test   %eax,%eax
  800bb8:	74 33                	je     800bed <memcmp+0x46>
  800bba:	8d 78 ff             	lea    -0x1(%eax),%edi
		if (*s1 != *s2)
  800bbd:	8a 13                	mov    (%ebx),%dl
  800bbf:	8a 0e                	mov    (%esi),%cl
  800bc1:	38 ca                	cmp    %cl,%dl
  800bc3:	75 13                	jne    800bd8 <memcmp+0x31>
  800bc5:	b8 00 00 00 00       	mov    $0x0,%eax
  800bca:	eb 16                	jmp    800be2 <memcmp+0x3b>
  800bcc:	8a 54 03 01          	mov    0x1(%ebx,%eax,1),%dl
  800bd0:	40                   	inc    %eax
  800bd1:	8a 0c 06             	mov    (%esi,%eax,1),%cl
  800bd4:	38 ca                	cmp    %cl,%dl
  800bd6:	74 0a                	je     800be2 <memcmp+0x3b>
			return (int) *s1 - (int) *s2;
  800bd8:	0f b6 c2             	movzbl %dl,%eax
  800bdb:	0f b6 c9             	movzbl %cl,%ecx
  800bde:	29 c8                	sub    %ecx,%eax
  800be0:	eb 10                	jmp    800bf2 <memcmp+0x4b>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800be2:	39 f8                	cmp    %edi,%eax
  800be4:	75 e6                	jne    800bcc <memcmp+0x25>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800be6:	b8 00 00 00 00       	mov    $0x0,%eax
  800beb:	eb 05                	jmp    800bf2 <memcmp+0x4b>
  800bed:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bf2:	5b                   	pop    %ebx
  800bf3:	5e                   	pop    %esi
  800bf4:	5f                   	pop    %edi
  800bf5:	5d                   	pop    %ebp
  800bf6:	c3                   	ret    

00800bf7 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800bf7:	55                   	push   %ebp
  800bf8:	89 e5                	mov    %esp,%ebp
  800bfa:	53                   	push   %ebx
  800bfb:	8b 55 08             	mov    0x8(%ebp),%edx
	const void *ends = (const char *) s + n;
  800bfe:	89 d0                	mov    %edx,%eax
  800c00:	03 45 10             	add    0x10(%ebp),%eax
	for (; s < ends; s++)
  800c03:	39 c2                	cmp    %eax,%edx
  800c05:	73 1b                	jae    800c22 <memfind+0x2b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c07:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
  800c0b:	0f b6 0a             	movzbl (%edx),%ecx
  800c0e:	39 d9                	cmp    %ebx,%ecx
  800c10:	75 09                	jne    800c1b <memfind+0x24>
  800c12:	eb 12                	jmp    800c26 <memfind+0x2f>
  800c14:	0f b6 0a             	movzbl (%edx),%ecx
  800c17:	39 d9                	cmp    %ebx,%ecx
  800c19:	74 0f                	je     800c2a <memfind+0x33>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c1b:	42                   	inc    %edx
  800c1c:	39 d0                	cmp    %edx,%eax
  800c1e:	75 f4                	jne    800c14 <memfind+0x1d>
  800c20:	eb 0a                	jmp    800c2c <memfind+0x35>
  800c22:	89 d0                	mov    %edx,%eax
  800c24:	eb 06                	jmp    800c2c <memfind+0x35>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c26:	89 d0                	mov    %edx,%eax
  800c28:	eb 02                	jmp    800c2c <memfind+0x35>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c2a:	89 d0                	mov    %edx,%eax
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c2c:	5b                   	pop    %ebx
  800c2d:	5d                   	pop    %ebp
  800c2e:	c3                   	ret    

00800c2f <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c2f:	55                   	push   %ebp
  800c30:	89 e5                	mov    %esp,%ebp
  800c32:	57                   	push   %edi
  800c33:	56                   	push   %esi
  800c34:	53                   	push   %ebx
  800c35:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c38:	eb 01                	jmp    800c3b <strtol+0xc>
		s++;
  800c3a:	41                   	inc    %ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c3b:	8a 01                	mov    (%ecx),%al
  800c3d:	3c 20                	cmp    $0x20,%al
  800c3f:	74 f9                	je     800c3a <strtol+0xb>
  800c41:	3c 09                	cmp    $0x9,%al
  800c43:	74 f5                	je     800c3a <strtol+0xb>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c45:	3c 2b                	cmp    $0x2b,%al
  800c47:	75 08                	jne    800c51 <strtol+0x22>
		s++;
  800c49:	41                   	inc    %ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c4a:	bf 00 00 00 00       	mov    $0x0,%edi
  800c4f:	eb 11                	jmp    800c62 <strtol+0x33>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c51:	3c 2d                	cmp    $0x2d,%al
  800c53:	75 08                	jne    800c5d <strtol+0x2e>
		s++, neg = 1;
  800c55:	41                   	inc    %ecx
  800c56:	bf 01 00 00 00       	mov    $0x1,%edi
  800c5b:	eb 05                	jmp    800c62 <strtol+0x33>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c5d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c62:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800c66:	0f 84 87 00 00 00    	je     800cf3 <strtol+0xc4>
  800c6c:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  800c70:	75 27                	jne    800c99 <strtol+0x6a>
  800c72:	80 39 30             	cmpb   $0x30,(%ecx)
  800c75:	75 22                	jne    800c99 <strtol+0x6a>
  800c77:	e9 88 00 00 00       	jmp    800d04 <strtol+0xd5>
		s += 2, base = 16;
  800c7c:	83 c1 02             	add    $0x2,%ecx
  800c7f:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  800c86:	eb 11                	jmp    800c99 <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
  800c88:	41                   	inc    %ecx
  800c89:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  800c90:	eb 07                	jmp    800c99 <strtol+0x6a>
	else if (base == 0)
		base = 10;
  800c92:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)
  800c99:	b8 00 00 00 00       	mov    $0x0,%eax

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c9e:	8a 11                	mov    (%ecx),%dl
  800ca0:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800ca3:	80 fb 09             	cmp    $0x9,%bl
  800ca6:	77 08                	ja     800cb0 <strtol+0x81>
			dig = *s - '0';
  800ca8:	0f be d2             	movsbl %dl,%edx
  800cab:	83 ea 30             	sub    $0x30,%edx
  800cae:	eb 22                	jmp    800cd2 <strtol+0xa3>
		else if (*s >= 'a' && *s <= 'z')
  800cb0:	8d 72 9f             	lea    -0x61(%edx),%esi
  800cb3:	89 f3                	mov    %esi,%ebx
  800cb5:	80 fb 19             	cmp    $0x19,%bl
  800cb8:	77 08                	ja     800cc2 <strtol+0x93>
			dig = *s - 'a' + 10;
  800cba:	0f be d2             	movsbl %dl,%edx
  800cbd:	83 ea 57             	sub    $0x57,%edx
  800cc0:	eb 10                	jmp    800cd2 <strtol+0xa3>
		else if (*s >= 'A' && *s <= 'Z')
  800cc2:	8d 72 bf             	lea    -0x41(%edx),%esi
  800cc5:	89 f3                	mov    %esi,%ebx
  800cc7:	80 fb 19             	cmp    $0x19,%bl
  800cca:	77 14                	ja     800ce0 <strtol+0xb1>
			dig = *s - 'A' + 10;
  800ccc:	0f be d2             	movsbl %dl,%edx
  800ccf:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800cd2:	3b 55 10             	cmp    0x10(%ebp),%edx
  800cd5:	7d 09                	jge    800ce0 <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800cd7:	41                   	inc    %ecx
  800cd8:	0f af 45 10          	imul   0x10(%ebp),%eax
  800cdc:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800cde:	eb be                	jmp    800c9e <strtol+0x6f>

	if (endptr)
  800ce0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ce4:	74 05                	je     800ceb <strtol+0xbc>
		*endptr = (char *) s;
  800ce6:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ce9:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800ceb:	85 ff                	test   %edi,%edi
  800ced:	74 21                	je     800d10 <strtol+0xe1>
  800cef:	f7 d8                	neg    %eax
  800cf1:	eb 1d                	jmp    800d10 <strtol+0xe1>
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800cf3:	80 39 30             	cmpb   $0x30,(%ecx)
  800cf6:	75 9a                	jne    800c92 <strtol+0x63>
  800cf8:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800cfc:	0f 84 7a ff ff ff    	je     800c7c <strtol+0x4d>
  800d02:	eb 84                	jmp    800c88 <strtol+0x59>
  800d04:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800d08:	0f 84 6e ff ff ff    	je     800c7c <strtol+0x4d>
  800d0e:	eb 89                	jmp    800c99 <strtol+0x6a>
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
}
  800d10:	5b                   	pop    %ebx
  800d11:	5e                   	pop    %esi
  800d12:	5f                   	pop    %edi
  800d13:	5d                   	pop    %ebp
  800d14:	c3                   	ret    

00800d15 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800d15:	55                   	push   %ebp
  800d16:	89 e5                	mov    %esp,%ebp
  800d18:	57                   	push   %edi
  800d19:	56                   	push   %esi
  800d1a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d1b:	b8 00 00 00 00       	mov    $0x0,%eax
  800d20:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d23:	8b 55 08             	mov    0x8(%ebp),%edx
  800d26:	89 c3                	mov    %eax,%ebx
  800d28:	89 c7                	mov    %eax,%edi
  800d2a:	89 c6                	mov    %eax,%esi
  800d2c:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800d2e:	5b                   	pop    %ebx
  800d2f:	5e                   	pop    %esi
  800d30:	5f                   	pop    %edi
  800d31:	5d                   	pop    %ebp
  800d32:	c3                   	ret    

00800d33 <sys_cgetc>:

int
sys_cgetc(void)
{
  800d33:	55                   	push   %ebp
  800d34:	89 e5                	mov    %esp,%ebp
  800d36:	57                   	push   %edi
  800d37:	56                   	push   %esi
  800d38:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d39:	ba 00 00 00 00       	mov    $0x0,%edx
  800d3e:	b8 01 00 00 00       	mov    $0x1,%eax
  800d43:	89 d1                	mov    %edx,%ecx
  800d45:	89 d3                	mov    %edx,%ebx
  800d47:	89 d7                	mov    %edx,%edi
  800d49:	89 d6                	mov    %edx,%esi
  800d4b:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800d4d:	5b                   	pop    %ebx
  800d4e:	5e                   	pop    %esi
  800d4f:	5f                   	pop    %edi
  800d50:	5d                   	pop    %ebp
  800d51:	c3                   	ret    

00800d52 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800d52:	55                   	push   %ebp
  800d53:	89 e5                	mov    %esp,%ebp
  800d55:	57                   	push   %edi
  800d56:	56                   	push   %esi
  800d57:	53                   	push   %ebx
  800d58:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d5b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d60:	b8 03 00 00 00       	mov    $0x3,%eax
  800d65:	8b 55 08             	mov    0x8(%ebp),%edx
  800d68:	89 cb                	mov    %ecx,%ebx
  800d6a:	89 cf                	mov    %ecx,%edi
  800d6c:	89 ce                	mov    %ecx,%esi
  800d6e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d70:	85 c0                	test   %eax,%eax
  800d72:	7e 17                	jle    800d8b <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d74:	83 ec 0c             	sub    $0xc,%esp
  800d77:	50                   	push   %eax
  800d78:	6a 03                	push   $0x3
  800d7a:	68 9f 27 80 00       	push   $0x80279f
  800d7f:	6a 23                	push   $0x23
  800d81:	68 bc 27 80 00       	push   $0x8027bc
  800d86:	e8 19 f5 ff ff       	call   8002a4 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d8b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d8e:	5b                   	pop    %ebx
  800d8f:	5e                   	pop    %esi
  800d90:	5f                   	pop    %edi
  800d91:	5d                   	pop    %ebp
  800d92:	c3                   	ret    

00800d93 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d93:	55                   	push   %ebp
  800d94:	89 e5                	mov    %esp,%ebp
  800d96:	57                   	push   %edi
  800d97:	56                   	push   %esi
  800d98:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d99:	ba 00 00 00 00       	mov    $0x0,%edx
  800d9e:	b8 02 00 00 00       	mov    $0x2,%eax
  800da3:	89 d1                	mov    %edx,%ecx
  800da5:	89 d3                	mov    %edx,%ebx
  800da7:	89 d7                	mov    %edx,%edi
  800da9:	89 d6                	mov    %edx,%esi
  800dab:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800dad:	5b                   	pop    %ebx
  800dae:	5e                   	pop    %esi
  800daf:	5f                   	pop    %edi
  800db0:	5d                   	pop    %ebp
  800db1:	c3                   	ret    

00800db2 <sys_yield>:

void
sys_yield(void)
{
  800db2:	55                   	push   %ebp
  800db3:	89 e5                	mov    %esp,%ebp
  800db5:	57                   	push   %edi
  800db6:	56                   	push   %esi
  800db7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800db8:	ba 00 00 00 00       	mov    $0x0,%edx
  800dbd:	b8 0b 00 00 00       	mov    $0xb,%eax
  800dc2:	89 d1                	mov    %edx,%ecx
  800dc4:	89 d3                	mov    %edx,%ebx
  800dc6:	89 d7                	mov    %edx,%edi
  800dc8:	89 d6                	mov    %edx,%esi
  800dca:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800dcc:	5b                   	pop    %ebx
  800dcd:	5e                   	pop    %esi
  800dce:	5f                   	pop    %edi
  800dcf:	5d                   	pop    %ebp
  800dd0:	c3                   	ret    

00800dd1 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800dd1:	55                   	push   %ebp
  800dd2:	89 e5                	mov    %esp,%ebp
  800dd4:	57                   	push   %edi
  800dd5:	56                   	push   %esi
  800dd6:	53                   	push   %ebx
  800dd7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dda:	be 00 00 00 00       	mov    $0x0,%esi
  800ddf:	b8 04 00 00 00       	mov    $0x4,%eax
  800de4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800de7:	8b 55 08             	mov    0x8(%ebp),%edx
  800dea:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ded:	89 f7                	mov    %esi,%edi
  800def:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800df1:	85 c0                	test   %eax,%eax
  800df3:	7e 17                	jle    800e0c <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800df5:	83 ec 0c             	sub    $0xc,%esp
  800df8:	50                   	push   %eax
  800df9:	6a 04                	push   $0x4
  800dfb:	68 9f 27 80 00       	push   $0x80279f
  800e00:	6a 23                	push   $0x23
  800e02:	68 bc 27 80 00       	push   $0x8027bc
  800e07:	e8 98 f4 ff ff       	call   8002a4 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800e0c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e0f:	5b                   	pop    %ebx
  800e10:	5e                   	pop    %esi
  800e11:	5f                   	pop    %edi
  800e12:	5d                   	pop    %ebp
  800e13:	c3                   	ret    

00800e14 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800e14:	55                   	push   %ebp
  800e15:	89 e5                	mov    %esp,%ebp
  800e17:	57                   	push   %edi
  800e18:	56                   	push   %esi
  800e19:	53                   	push   %ebx
  800e1a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e1d:	b8 05 00 00 00       	mov    $0x5,%eax
  800e22:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e25:	8b 55 08             	mov    0x8(%ebp),%edx
  800e28:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e2b:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e2e:	8b 75 18             	mov    0x18(%ebp),%esi
  800e31:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e33:	85 c0                	test   %eax,%eax
  800e35:	7e 17                	jle    800e4e <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e37:	83 ec 0c             	sub    $0xc,%esp
  800e3a:	50                   	push   %eax
  800e3b:	6a 05                	push   $0x5
  800e3d:	68 9f 27 80 00       	push   $0x80279f
  800e42:	6a 23                	push   $0x23
  800e44:	68 bc 27 80 00       	push   $0x8027bc
  800e49:	e8 56 f4 ff ff       	call   8002a4 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800e4e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e51:	5b                   	pop    %ebx
  800e52:	5e                   	pop    %esi
  800e53:	5f                   	pop    %edi
  800e54:	5d                   	pop    %ebp
  800e55:	c3                   	ret    

00800e56 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800e56:	55                   	push   %ebp
  800e57:	89 e5                	mov    %esp,%ebp
  800e59:	57                   	push   %edi
  800e5a:	56                   	push   %esi
  800e5b:	53                   	push   %ebx
  800e5c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e5f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e64:	b8 06 00 00 00       	mov    $0x6,%eax
  800e69:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e6c:	8b 55 08             	mov    0x8(%ebp),%edx
  800e6f:	89 df                	mov    %ebx,%edi
  800e71:	89 de                	mov    %ebx,%esi
  800e73:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e75:	85 c0                	test   %eax,%eax
  800e77:	7e 17                	jle    800e90 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e79:	83 ec 0c             	sub    $0xc,%esp
  800e7c:	50                   	push   %eax
  800e7d:	6a 06                	push   $0x6
  800e7f:	68 9f 27 80 00       	push   $0x80279f
  800e84:	6a 23                	push   $0x23
  800e86:	68 bc 27 80 00       	push   $0x8027bc
  800e8b:	e8 14 f4 ff ff       	call   8002a4 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e90:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e93:	5b                   	pop    %ebx
  800e94:	5e                   	pop    %esi
  800e95:	5f                   	pop    %edi
  800e96:	5d                   	pop    %ebp
  800e97:	c3                   	ret    

00800e98 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e98:	55                   	push   %ebp
  800e99:	89 e5                	mov    %esp,%ebp
  800e9b:	57                   	push   %edi
  800e9c:	56                   	push   %esi
  800e9d:	53                   	push   %ebx
  800e9e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ea1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ea6:	b8 08 00 00 00       	mov    $0x8,%eax
  800eab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eae:	8b 55 08             	mov    0x8(%ebp),%edx
  800eb1:	89 df                	mov    %ebx,%edi
  800eb3:	89 de                	mov    %ebx,%esi
  800eb5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800eb7:	85 c0                	test   %eax,%eax
  800eb9:	7e 17                	jle    800ed2 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ebb:	83 ec 0c             	sub    $0xc,%esp
  800ebe:	50                   	push   %eax
  800ebf:	6a 08                	push   $0x8
  800ec1:	68 9f 27 80 00       	push   $0x80279f
  800ec6:	6a 23                	push   $0x23
  800ec8:	68 bc 27 80 00       	push   $0x8027bc
  800ecd:	e8 d2 f3 ff ff       	call   8002a4 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800ed2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ed5:	5b                   	pop    %ebx
  800ed6:	5e                   	pop    %esi
  800ed7:	5f                   	pop    %edi
  800ed8:	5d                   	pop    %ebp
  800ed9:	c3                   	ret    

00800eda <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800eda:	55                   	push   %ebp
  800edb:	89 e5                	mov    %esp,%ebp
  800edd:	57                   	push   %edi
  800ede:	56                   	push   %esi
  800edf:	53                   	push   %ebx
  800ee0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ee3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ee8:	b8 09 00 00 00       	mov    $0x9,%eax
  800eed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ef0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ef3:	89 df                	mov    %ebx,%edi
  800ef5:	89 de                	mov    %ebx,%esi
  800ef7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ef9:	85 c0                	test   %eax,%eax
  800efb:	7e 17                	jle    800f14 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800efd:	83 ec 0c             	sub    $0xc,%esp
  800f00:	50                   	push   %eax
  800f01:	6a 09                	push   $0x9
  800f03:	68 9f 27 80 00       	push   $0x80279f
  800f08:	6a 23                	push   $0x23
  800f0a:	68 bc 27 80 00       	push   $0x8027bc
  800f0f:	e8 90 f3 ff ff       	call   8002a4 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800f14:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f17:	5b                   	pop    %ebx
  800f18:	5e                   	pop    %esi
  800f19:	5f                   	pop    %edi
  800f1a:	5d                   	pop    %ebp
  800f1b:	c3                   	ret    

00800f1c <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800f1c:	55                   	push   %ebp
  800f1d:	89 e5                	mov    %esp,%ebp
  800f1f:	57                   	push   %edi
  800f20:	56                   	push   %esi
  800f21:	53                   	push   %ebx
  800f22:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f25:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f2a:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f2f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f32:	8b 55 08             	mov    0x8(%ebp),%edx
  800f35:	89 df                	mov    %ebx,%edi
  800f37:	89 de                	mov    %ebx,%esi
  800f39:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f3b:	85 c0                	test   %eax,%eax
  800f3d:	7e 17                	jle    800f56 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f3f:	83 ec 0c             	sub    $0xc,%esp
  800f42:	50                   	push   %eax
  800f43:	6a 0a                	push   $0xa
  800f45:	68 9f 27 80 00       	push   $0x80279f
  800f4a:	6a 23                	push   $0x23
  800f4c:	68 bc 27 80 00       	push   $0x8027bc
  800f51:	e8 4e f3 ff ff       	call   8002a4 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800f56:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f59:	5b                   	pop    %ebx
  800f5a:	5e                   	pop    %esi
  800f5b:	5f                   	pop    %edi
  800f5c:	5d                   	pop    %ebp
  800f5d:	c3                   	ret    

00800f5e <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f5e:	55                   	push   %ebp
  800f5f:	89 e5                	mov    %esp,%ebp
  800f61:	57                   	push   %edi
  800f62:	56                   	push   %esi
  800f63:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f64:	be 00 00 00 00       	mov    $0x0,%esi
  800f69:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f6e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f71:	8b 55 08             	mov    0x8(%ebp),%edx
  800f74:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f77:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f7a:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f7c:	5b                   	pop    %ebx
  800f7d:	5e                   	pop    %esi
  800f7e:	5f                   	pop    %edi
  800f7f:	5d                   	pop    %ebp
  800f80:	c3                   	ret    

00800f81 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800f81:	55                   	push   %ebp
  800f82:	89 e5                	mov    %esp,%ebp
  800f84:	57                   	push   %edi
  800f85:	56                   	push   %esi
  800f86:	53                   	push   %ebx
  800f87:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f8a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f8f:	b8 0d 00 00 00       	mov    $0xd,%eax
  800f94:	8b 55 08             	mov    0x8(%ebp),%edx
  800f97:	89 cb                	mov    %ecx,%ebx
  800f99:	89 cf                	mov    %ecx,%edi
  800f9b:	89 ce                	mov    %ecx,%esi
  800f9d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f9f:	85 c0                	test   %eax,%eax
  800fa1:	7e 17                	jle    800fba <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fa3:	83 ec 0c             	sub    $0xc,%esp
  800fa6:	50                   	push   %eax
  800fa7:	6a 0d                	push   $0xd
  800fa9:	68 9f 27 80 00       	push   $0x80279f
  800fae:	6a 23                	push   $0x23
  800fb0:	68 bc 27 80 00       	push   $0x8027bc
  800fb5:	e8 ea f2 ff ff       	call   8002a4 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800fba:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fbd:	5b                   	pop    %ebx
  800fbe:	5e                   	pop    %esi
  800fbf:	5f                   	pop    %edi
  800fc0:	5d                   	pop    %ebp
  800fc1:	c3                   	ret    

00800fc2 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800fc2:	55                   	push   %ebp
  800fc3:	89 e5                	mov    %esp,%ebp
  800fc5:	56                   	push   %esi
  800fc6:	53                   	push   %ebx
  800fc7:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800fca:	8b 18                	mov    (%eax),%ebx
	// copy-on-write page.  If not, panic.
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).
	
	if((err & FEC_WR) == 0){
  800fcc:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800fd0:	75 14                	jne    800fe6 <pgfault+0x24>
		panic("pgfault not cause by write \n");
  800fd2:	83 ec 04             	sub    $0x4,%esp
  800fd5:	68 ca 27 80 00       	push   $0x8027ca
  800fda:	6a 1c                	push   $0x1c
  800fdc:	68 e7 27 80 00       	push   $0x8027e7
  800fe1:	e8 be f2 ff ff       	call   8002a4 <_panic>
	}
 
	if ((uvpt[PGNUM(addr)] & PTE_COW) == 0) 
  800fe6:	89 d8                	mov    %ebx,%eax
  800fe8:	c1 e8 0c             	shr    $0xc,%eax
  800feb:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800ff2:	f6 c4 08             	test   $0x8,%ah
  800ff5:	75 14                	jne    80100b <pgfault+0x49>
    {
        panic("pgfault not cause by COW \n");
  800ff7:	83 ec 04             	sub    $0x4,%esp
  800ffa:	68 f2 27 80 00       	push   $0x8027f2
  800fff:	6a 21                	push   $0x21
  801001:	68 e7 27 80 00       	push   $0x8027e7
  801006:	e8 99 f2 ff ff       	call   8002a4 <_panic>
	// copy the data from the old page to the new page, then move the new
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.
	envid_t eid = sys_getenvid();
  80100b:	e8 83 fd ff ff       	call   800d93 <sys_getenvid>
  801010:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(eid,(void*)PFTEMP,PTE_P|PTE_W|PTE_U)) < 0)
  801012:	83 ec 04             	sub    $0x4,%esp
  801015:	6a 07                	push   $0x7
  801017:	68 00 f0 7f 00       	push   $0x7ff000
  80101c:	50                   	push   %eax
  80101d:	e8 af fd ff ff       	call   800dd1 <sys_page_alloc>
  801022:	83 c4 10             	add    $0x10,%esp
  801025:	85 c0                	test   %eax,%eax
  801027:	79 14                	jns    80103d <pgfault+0x7b>
		panic("page alloction failed.\n");
  801029:	83 ec 04             	sub    $0x4,%esp
  80102c:	68 0d 28 80 00       	push   $0x80280d
  801031:	6a 2d                	push   $0x2d
  801033:	68 e7 27 80 00       	push   $0x8027e7
  801038:	e8 67 f2 ff ff       	call   8002a4 <_panic>
	addr = ROUNDDOWN(addr,PGSIZE);
  80103d:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memmove(PFTEMP,addr,PGSIZE);
  801043:	83 ec 04             	sub    $0x4,%esp
  801046:	68 00 10 00 00       	push   $0x1000
  80104b:	53                   	push   %ebx
  80104c:	68 00 f0 7f 00       	push   $0x7ff000
  801051:	e8 d8 fa ff ff       	call   800b2e <memmove>
	if ((r = sys_page_map(eid, PFTEMP, eid, addr, PTE_P | PTE_W |PTE_U)) < 0)
  801056:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  80105d:	53                   	push   %ebx
  80105e:	56                   	push   %esi
  80105f:	68 00 f0 7f 00       	push   $0x7ff000
  801064:	56                   	push   %esi
  801065:	e8 aa fd ff ff       	call   800e14 <sys_page_map>
  80106a:	83 c4 20             	add    $0x20,%esp
  80106d:	85 c0                	test   %eax,%eax
  80106f:	79 12                	jns    801083 <pgfault+0xc1>
        panic("pgfault: page map failed %e\n", r);
  801071:	50                   	push   %eax
  801072:	68 25 28 80 00       	push   $0x802825
  801077:	6a 31                	push   $0x31
  801079:	68 e7 27 80 00       	push   $0x8027e7
  80107e:	e8 21 f2 ff ff       	call   8002a4 <_panic>
	if ((r = sys_page_unmap(eid, PFTEMP)) < 0)
  801083:	83 ec 08             	sub    $0x8,%esp
  801086:	68 00 f0 7f 00       	push   $0x7ff000
  80108b:	56                   	push   %esi
  80108c:	e8 c5 fd ff ff       	call   800e56 <sys_page_unmap>
  801091:	83 c4 10             	add    $0x10,%esp
  801094:	85 c0                	test   %eax,%eax
  801096:	79 12                	jns    8010aa <pgfault+0xe8>
        panic("pgfault: page unmap failed %e\n", r);
  801098:	50                   	push   %eax
  801099:	68 94 28 80 00       	push   $0x802894
  80109e:	6a 33                	push   $0x33
  8010a0:	68 e7 27 80 00       	push   $0x8027e7
  8010a5:	e8 fa f1 ff ff       	call   8002a4 <_panic>
	// LAB 4: Your code here.

	// panic("pgfault not implemented");
}
  8010aa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010ad:	5b                   	pop    %ebx
  8010ae:	5e                   	pop    %esi
  8010af:	5d                   	pop    %ebp
  8010b0:	c3                   	ret    

008010b1 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8010b1:	55                   	push   %ebp
  8010b2:	89 e5                	mov    %esp,%ebp
  8010b4:	57                   	push   %edi
  8010b5:	56                   	push   %esi
  8010b6:	53                   	push   %ebx
  8010b7:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	struct PageInfo* pg = NULL;
	set_pgfault_handler(pgfault);
  8010ba:	68 c2 0f 80 00       	push   $0x800fc2
  8010bf:	e8 71 0e 00 00       	call   801f35 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  8010c4:	b8 07 00 00 00       	mov    $0x7,%eax
  8010c9:	cd 30                	int    $0x30
  8010cb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8010ce:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t eid = sys_exofork();
	if (eid < 0) panic("fork fault.\n");
  8010d1:	83 c4 10             	add    $0x10,%esp
  8010d4:	85 c0                	test   %eax,%eax
  8010d6:	79 14                	jns    8010ec <fork+0x3b>
  8010d8:	83 ec 04             	sub    $0x4,%esp
  8010db:	68 42 28 80 00       	push   $0x802842
  8010e0:	6a 71                	push   $0x71
  8010e2:	68 e7 27 80 00       	push   $0x8027e7
  8010e7:	e8 b8 f1 ff ff       	call   8002a4 <_panic>
	if (eid == 0){
  8010ec:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8010f0:	75 25                	jne    801117 <fork+0x66>
		thisenv = &envs[ENVX(sys_getenvid())];
  8010f2:	e8 9c fc ff ff       	call   800d93 <sys_getenvid>
  8010f7:	25 ff 03 00 00       	and    $0x3ff,%eax
  8010fc:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801103:	c1 e0 07             	shl    $0x7,%eax
  801106:	29 d0                	sub    %edx,%eax
  801108:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80110d:	a3 04 40 80 00       	mov    %eax,0x804004
		return eid;
  801112:	e9 61 01 00 00       	jmp    801278 <fork+0x1c7>
  801117:	bb 00 00 80 00       	mov    $0x800000,%ebx
	}
	// copy something to the child page.
	for (uintptr_t i = UTEXT;i <= USTACKTOP;i += PGSIZE){
		if (uvpd[PDX(i)] & PTE_P && (uvpt[PGNUM(i)] & PTE_P)){
  80111c:	89 d8                	mov    %ebx,%eax
  80111e:	c1 e8 16             	shr    $0x16,%eax
  801121:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801128:	a8 01                	test   $0x1,%al
  80112a:	74 52                	je     80117e <fork+0xcd>
  80112c:	89 de                	mov    %ebx,%esi
  80112e:	c1 ee 0c             	shr    $0xc,%esi
  801131:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801138:	a8 01                	test   $0x1,%al
  80113a:	74 42                	je     80117e <fork+0xcd>
duppage(envid_t envid, unsigned pn)
{
	int r;

	// LAB 4: Your code here.
	envid_t myenvid = sys_getenvid();
  80113c:	e8 52 fc ff ff       	call   800d93 <sys_getenvid>
  801141:	89 c7                	mov    %eax,%edi
	pte_t pte = uvpt[pn];
  801143:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
	int perm = PTE_U | PTE_P;
	if(pte & PTE_W || pte & PTE_COW)
  80114a:	a9 02 08 00 00       	test   $0x802,%eax
  80114f:	0f 85 de 00 00 00    	jne    801233 <fork+0x182>
  801155:	e9 fb 00 00 00       	jmp    801255 <fork+0x1a4>
		perm |= PTE_COW;
	if((r = sys_page_map(myenvid,(void*)(pn*PGSIZE),envid,(void*)(pn*PGSIZE),perm))<0){
		panic("duppage fault :%e\n",r);
  80115a:	50                   	push   %eax
  80115b:	68 4f 28 80 00       	push   $0x80284f
  801160:	6a 50                	push   $0x50
  801162:	68 e7 27 80 00       	push   $0x8027e7
  801167:	e8 38 f1 ff ff       	call   8002a4 <_panic>
	}
	if(perm & PTE_COW){
		if((r = sys_page_map(myenvid,(void*)(pn*PGSIZE),myenvid,(void*)(pn*PGSIZE),perm))<0)
			panic("duppage fault :%e\n",r);
  80116c:	50                   	push   %eax
  80116d:	68 4f 28 80 00       	push   $0x80284f
  801172:	6a 54                	push   $0x54
  801174:	68 e7 27 80 00       	push   $0x8027e7
  801179:	e8 26 f1 ff ff       	call   8002a4 <_panic>
	if (eid == 0){
		thisenv = &envs[ENVX(sys_getenvid())];
		return eid;
	}
	// copy something to the child page.
	for (uintptr_t i = UTEXT;i <= USTACKTOP;i += PGSIZE){
  80117e:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801184:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  80118a:	75 90                	jne    80111c <fork+0x6b>
		if (uvpd[PDX(i)] & PTE_P && (uvpt[PGNUM(i)] & PTE_P)){
			duppage(eid,PGNUM(i));
		}
	}
	int r = sys_page_alloc(eid,(void*)(UXSTACKTOP-PGSIZE),PTE_U|PTE_P|PTE_W);
  80118c:	83 ec 04             	sub    $0x4,%esp
  80118f:	6a 07                	push   $0x7
  801191:	68 00 f0 bf ee       	push   $0xeebff000
  801196:	ff 75 e0             	pushl  -0x20(%ebp)
  801199:	e8 33 fc ff ff       	call   800dd1 <sys_page_alloc>
	if (r < 0) panic("fork fault.\n");
  80119e:	83 c4 10             	add    $0x10,%esp
  8011a1:	85 c0                	test   %eax,%eax
  8011a3:	79 14                	jns    8011b9 <fork+0x108>
  8011a5:	83 ec 04             	sub    $0x4,%esp
  8011a8:	68 42 28 80 00       	push   $0x802842
  8011ad:	6a 7d                	push   $0x7d
  8011af:	68 e7 27 80 00       	push   $0x8027e7
  8011b4:	e8 eb f0 ff ff       	call   8002a4 <_panic>

	extern void _pgfault_upcall();
    r = sys_env_set_pgfault_upcall(eid, _pgfault_upcall);
  8011b9:	83 ec 08             	sub    $0x8,%esp
  8011bc:	68 ad 1f 80 00       	push   $0x801fad
  8011c1:	ff 75 e0             	pushl  -0x20(%ebp)
  8011c4:	e8 53 fd ff ff       	call   800f1c <sys_env_set_pgfault_upcall>
    if (r < 0) panic("fork fault 3\n");
  8011c9:	83 c4 10             	add    $0x10,%esp
  8011cc:	85 c0                	test   %eax,%eax
  8011ce:	79 17                	jns    8011e7 <fork+0x136>
  8011d0:	83 ec 04             	sub    $0x4,%esp
  8011d3:	68 62 28 80 00       	push   $0x802862
  8011d8:	68 81 00 00 00       	push   $0x81
  8011dd:	68 e7 27 80 00       	push   $0x8027e7
  8011e2:	e8 bd f0 ff ff       	call   8002a4 <_panic>

	if ((r = sys_env_set_status(eid, ENV_RUNNABLE)) < 0)
  8011e7:	83 ec 08             	sub    $0x8,%esp
  8011ea:	6a 02                	push   $0x2
  8011ec:	ff 75 e0             	pushl  -0x20(%ebp)
  8011ef:	e8 a4 fc ff ff       	call   800e98 <sys_env_set_status>
  8011f4:	83 c4 10             	add    $0x10,%esp
  8011f7:	85 c0                	test   %eax,%eax
  8011f9:	79 7d                	jns    801278 <fork+0x1c7>
        panic("fork fault 4\n");
  8011fb:	83 ec 04             	sub    $0x4,%esp
  8011fe:	68 70 28 80 00       	push   $0x802870
  801203:	68 84 00 00 00       	push   $0x84
  801208:	68 e7 27 80 00       	push   $0x8027e7
  80120d:	e8 92 f0 ff ff       	call   8002a4 <_panic>
		perm |= PTE_COW;
	if((r = sys_page_map(myenvid,(void*)(pn*PGSIZE),envid,(void*)(pn*PGSIZE),perm))<0){
		panic("duppage fault :%e\n",r);
	}
	if(perm & PTE_COW){
		if((r = sys_page_map(myenvid,(void*)(pn*PGSIZE),myenvid,(void*)(pn*PGSIZE),perm))<0)
  801212:	83 ec 0c             	sub    $0xc,%esp
  801215:	68 05 08 00 00       	push   $0x805
  80121a:	56                   	push   %esi
  80121b:	57                   	push   %edi
  80121c:	56                   	push   %esi
  80121d:	57                   	push   %edi
  80121e:	e8 f1 fb ff ff       	call   800e14 <sys_page_map>
  801223:	83 c4 20             	add    $0x20,%esp
  801226:	85 c0                	test   %eax,%eax
  801228:	0f 89 50 ff ff ff    	jns    80117e <fork+0xcd>
  80122e:	e9 39 ff ff ff       	jmp    80116c <fork+0xbb>
	envid_t myenvid = sys_getenvid();
	pte_t pte = uvpt[pn];
	int perm = PTE_U | PTE_P;
	if(pte & PTE_W || pte & PTE_COW)
		perm |= PTE_COW;
	if((r = sys_page_map(myenvid,(void*)(pn*PGSIZE),envid,(void*)(pn*PGSIZE),perm))<0){
  801233:	c1 e6 0c             	shl    $0xc,%esi
  801236:	83 ec 0c             	sub    $0xc,%esp
  801239:	68 05 08 00 00       	push   $0x805
  80123e:	56                   	push   %esi
  80123f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801242:	56                   	push   %esi
  801243:	57                   	push   %edi
  801244:	e8 cb fb ff ff       	call   800e14 <sys_page_map>
  801249:	83 c4 20             	add    $0x20,%esp
  80124c:	85 c0                	test   %eax,%eax
  80124e:	79 c2                	jns    801212 <fork+0x161>
  801250:	e9 05 ff ff ff       	jmp    80115a <fork+0xa9>
  801255:	c1 e6 0c             	shl    $0xc,%esi
  801258:	83 ec 0c             	sub    $0xc,%esp
  80125b:	6a 05                	push   $0x5
  80125d:	56                   	push   %esi
  80125e:	ff 75 e4             	pushl  -0x1c(%ebp)
  801261:	56                   	push   %esi
  801262:	57                   	push   %edi
  801263:	e8 ac fb ff ff       	call   800e14 <sys_page_map>
  801268:	83 c4 20             	add    $0x20,%esp
  80126b:	85 c0                	test   %eax,%eax
  80126d:	0f 89 0b ff ff ff    	jns    80117e <fork+0xcd>
  801273:	e9 e2 fe ff ff       	jmp    80115a <fork+0xa9>
    if (r < 0) panic("fork fault 3\n");

	if ((r = sys_env_set_status(eid, ENV_RUNNABLE)) < 0)
        panic("fork fault 4\n");
    return eid;
}
  801278:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80127b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80127e:	5b                   	pop    %ebx
  80127f:	5e                   	pop    %esi
  801280:	5f                   	pop    %edi
  801281:	5d                   	pop    %ebp
  801282:	c3                   	ret    

00801283 <sfork>:

// Challenge!
int
sfork(void)
{
  801283:	55                   	push   %ebp
  801284:	89 e5                	mov    %esp,%ebp
  801286:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801289:	68 7e 28 80 00       	push   $0x80287e
  80128e:	68 8c 00 00 00       	push   $0x8c
  801293:	68 e7 27 80 00       	push   $0x8027e7
  801298:	e8 07 f0 ff ff       	call   8002a4 <_panic>

0080129d <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80129d:	55                   	push   %ebp
  80129e:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8012a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8012a3:	05 00 00 00 30       	add    $0x30000000,%eax
  8012a8:	c1 e8 0c             	shr    $0xc,%eax
}
  8012ab:	5d                   	pop    %ebp
  8012ac:	c3                   	ret    

008012ad <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8012ad:	55                   	push   %ebp
  8012ae:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8012b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8012b3:	05 00 00 00 30       	add    $0x30000000,%eax
  8012b8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8012bd:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8012c2:	5d                   	pop    %ebp
  8012c3:	c3                   	ret    

008012c4 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8012c4:	55                   	push   %ebp
  8012c5:	89 e5                	mov    %esp,%ebp
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8012c7:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  8012cc:	a8 01                	test   $0x1,%al
  8012ce:	74 34                	je     801304 <fd_alloc+0x40>
  8012d0:	a1 00 00 74 ef       	mov    0xef740000,%eax
  8012d5:	a8 01                	test   $0x1,%al
  8012d7:	74 32                	je     80130b <fd_alloc+0x47>
  8012d9:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8012de:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8012e0:	89 c2                	mov    %eax,%edx
  8012e2:	c1 ea 16             	shr    $0x16,%edx
  8012e5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012ec:	f6 c2 01             	test   $0x1,%dl
  8012ef:	74 1f                	je     801310 <fd_alloc+0x4c>
  8012f1:	89 c2                	mov    %eax,%edx
  8012f3:	c1 ea 0c             	shr    $0xc,%edx
  8012f6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012fd:	f6 c2 01             	test   $0x1,%dl
  801300:	75 1a                	jne    80131c <fd_alloc+0x58>
  801302:	eb 0c                	jmp    801310 <fd_alloc+0x4c>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  801304:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  801309:	eb 05                	jmp    801310 <fd_alloc+0x4c>
  80130b:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  801310:	8b 45 08             	mov    0x8(%ebp),%eax
  801313:	89 08                	mov    %ecx,(%eax)
			return 0;
  801315:	b8 00 00 00 00       	mov    $0x0,%eax
  80131a:	eb 1a                	jmp    801336 <fd_alloc+0x72>
  80131c:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801321:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801326:	75 b6                	jne    8012de <fd_alloc+0x1a>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801328:	8b 45 08             	mov    0x8(%ebp),%eax
  80132b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  801331:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801336:	5d                   	pop    %ebp
  801337:	c3                   	ret    

00801338 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801338:	55                   	push   %ebp
  801339:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80133b:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
  80133f:	77 39                	ja     80137a <fd_lookup+0x42>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801341:	8b 45 08             	mov    0x8(%ebp),%eax
  801344:	c1 e0 0c             	shl    $0xc,%eax
  801347:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80134c:	89 c2                	mov    %eax,%edx
  80134e:	c1 ea 16             	shr    $0x16,%edx
  801351:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801358:	f6 c2 01             	test   $0x1,%dl
  80135b:	74 24                	je     801381 <fd_lookup+0x49>
  80135d:	89 c2                	mov    %eax,%edx
  80135f:	c1 ea 0c             	shr    $0xc,%edx
  801362:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801369:	f6 c2 01             	test   $0x1,%dl
  80136c:	74 1a                	je     801388 <fd_lookup+0x50>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80136e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801371:	89 02                	mov    %eax,(%edx)
	return 0;
  801373:	b8 00 00 00 00       	mov    $0x0,%eax
  801378:	eb 13                	jmp    80138d <fd_lookup+0x55>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80137a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80137f:	eb 0c                	jmp    80138d <fd_lookup+0x55>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801381:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801386:	eb 05                	jmp    80138d <fd_lookup+0x55>
  801388:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80138d:	5d                   	pop    %ebp
  80138e:	c3                   	ret    

0080138f <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80138f:	55                   	push   %ebp
  801390:	89 e5                	mov    %esp,%ebp
  801392:	53                   	push   %ebx
  801393:	83 ec 04             	sub    $0x4,%esp
  801396:	8b 45 08             	mov    0x8(%ebp),%eax
  801399:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  80139c:	3b 05 04 30 80 00    	cmp    0x803004,%eax
  8013a2:	75 1e                	jne    8013c2 <dev_lookup+0x33>
  8013a4:	eb 0e                	jmp    8013b4 <dev_lookup+0x25>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8013a6:	b8 20 30 80 00       	mov    $0x803020,%eax
  8013ab:	eb 0c                	jmp    8013b9 <dev_lookup+0x2a>
  8013ad:	b8 3c 30 80 00       	mov    $0x80303c,%eax
  8013b2:	eb 05                	jmp    8013b9 <dev_lookup+0x2a>
  8013b4:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  8013b9:	89 03                	mov    %eax,(%ebx)
			return 0;
  8013bb:	b8 00 00 00 00       	mov    $0x0,%eax
  8013c0:	eb 36                	jmp    8013f8 <dev_lookup+0x69>
int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  8013c2:	3b 05 20 30 80 00    	cmp    0x803020,%eax
  8013c8:	74 dc                	je     8013a6 <dev_lookup+0x17>
  8013ca:	3b 05 3c 30 80 00    	cmp    0x80303c,%eax
  8013d0:	74 db                	je     8013ad <dev_lookup+0x1e>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8013d2:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8013d8:	8b 52 48             	mov    0x48(%edx),%edx
  8013db:	83 ec 04             	sub    $0x4,%esp
  8013de:	50                   	push   %eax
  8013df:	52                   	push   %edx
  8013e0:	68 b4 28 80 00       	push   $0x8028b4
  8013e5:	e8 92 ef ff ff       	call   80037c <cprintf>
	*dev = 0;
  8013ea:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  8013f0:	83 c4 10             	add    $0x10,%esp
  8013f3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8013f8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013fb:	c9                   	leave  
  8013fc:	c3                   	ret    

008013fd <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8013fd:	55                   	push   %ebp
  8013fe:	89 e5                	mov    %esp,%ebp
  801400:	56                   	push   %esi
  801401:	53                   	push   %ebx
  801402:	83 ec 10             	sub    $0x10,%esp
  801405:	8b 75 08             	mov    0x8(%ebp),%esi
  801408:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80140b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80140e:	50                   	push   %eax
  80140f:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801415:	c1 e8 0c             	shr    $0xc,%eax
  801418:	50                   	push   %eax
  801419:	e8 1a ff ff ff       	call   801338 <fd_lookup>
  80141e:	83 c4 08             	add    $0x8,%esp
  801421:	85 c0                	test   %eax,%eax
  801423:	78 05                	js     80142a <fd_close+0x2d>
	    || fd != fd2)
  801425:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801428:	74 06                	je     801430 <fd_close+0x33>
		return (must_exist ? r : 0);
  80142a:	84 db                	test   %bl,%bl
  80142c:	74 47                	je     801475 <fd_close+0x78>
  80142e:	eb 4a                	jmp    80147a <fd_close+0x7d>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801430:	83 ec 08             	sub    $0x8,%esp
  801433:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801436:	50                   	push   %eax
  801437:	ff 36                	pushl  (%esi)
  801439:	e8 51 ff ff ff       	call   80138f <dev_lookup>
  80143e:	89 c3                	mov    %eax,%ebx
  801440:	83 c4 10             	add    $0x10,%esp
  801443:	85 c0                	test   %eax,%eax
  801445:	78 1c                	js     801463 <fd_close+0x66>
		if (dev->dev_close)
  801447:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80144a:	8b 40 10             	mov    0x10(%eax),%eax
  80144d:	85 c0                	test   %eax,%eax
  80144f:	74 0d                	je     80145e <fd_close+0x61>
			r = (*dev->dev_close)(fd);
  801451:	83 ec 0c             	sub    $0xc,%esp
  801454:	56                   	push   %esi
  801455:	ff d0                	call   *%eax
  801457:	89 c3                	mov    %eax,%ebx
  801459:	83 c4 10             	add    $0x10,%esp
  80145c:	eb 05                	jmp    801463 <fd_close+0x66>
		else
			r = 0;
  80145e:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801463:	83 ec 08             	sub    $0x8,%esp
  801466:	56                   	push   %esi
  801467:	6a 00                	push   $0x0
  801469:	e8 e8 f9 ff ff       	call   800e56 <sys_page_unmap>
	return r;
  80146e:	83 c4 10             	add    $0x10,%esp
  801471:	89 d8                	mov    %ebx,%eax
  801473:	eb 05                	jmp    80147a <fd_close+0x7d>
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
  801475:	b8 00 00 00 00       	mov    $0x0,%eax
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
	return r;
}
  80147a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80147d:	5b                   	pop    %ebx
  80147e:	5e                   	pop    %esi
  80147f:	5d                   	pop    %ebp
  801480:	c3                   	ret    

00801481 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801481:	55                   	push   %ebp
  801482:	89 e5                	mov    %esp,%ebp
  801484:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801487:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80148a:	50                   	push   %eax
  80148b:	ff 75 08             	pushl  0x8(%ebp)
  80148e:	e8 a5 fe ff ff       	call   801338 <fd_lookup>
  801493:	83 c4 08             	add    $0x8,%esp
  801496:	85 c0                	test   %eax,%eax
  801498:	78 10                	js     8014aa <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80149a:	83 ec 08             	sub    $0x8,%esp
  80149d:	6a 01                	push   $0x1
  80149f:	ff 75 f4             	pushl  -0xc(%ebp)
  8014a2:	e8 56 ff ff ff       	call   8013fd <fd_close>
  8014a7:	83 c4 10             	add    $0x10,%esp
}
  8014aa:	c9                   	leave  
  8014ab:	c3                   	ret    

008014ac <close_all>:

void
close_all(void)
{
  8014ac:	55                   	push   %ebp
  8014ad:	89 e5                	mov    %esp,%ebp
  8014af:	53                   	push   %ebx
  8014b0:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8014b3:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8014b8:	83 ec 0c             	sub    $0xc,%esp
  8014bb:	53                   	push   %ebx
  8014bc:	e8 c0 ff ff ff       	call   801481 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8014c1:	43                   	inc    %ebx
  8014c2:	83 c4 10             	add    $0x10,%esp
  8014c5:	83 fb 20             	cmp    $0x20,%ebx
  8014c8:	75 ee                	jne    8014b8 <close_all+0xc>
		close(i);
}
  8014ca:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014cd:	c9                   	leave  
  8014ce:	c3                   	ret    

008014cf <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8014cf:	55                   	push   %ebp
  8014d0:	89 e5                	mov    %esp,%ebp
  8014d2:	57                   	push   %edi
  8014d3:	56                   	push   %esi
  8014d4:	53                   	push   %ebx
  8014d5:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8014d8:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8014db:	50                   	push   %eax
  8014dc:	ff 75 08             	pushl  0x8(%ebp)
  8014df:	e8 54 fe ff ff       	call   801338 <fd_lookup>
  8014e4:	83 c4 08             	add    $0x8,%esp
  8014e7:	85 c0                	test   %eax,%eax
  8014e9:	0f 88 c2 00 00 00    	js     8015b1 <dup+0xe2>
		return r;
	close(newfdnum);
  8014ef:	83 ec 0c             	sub    $0xc,%esp
  8014f2:	ff 75 0c             	pushl  0xc(%ebp)
  8014f5:	e8 87 ff ff ff       	call   801481 <close>

	newfd = INDEX2FD(newfdnum);
  8014fa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8014fd:	c1 e3 0c             	shl    $0xc,%ebx
  801500:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801506:	83 c4 04             	add    $0x4,%esp
  801509:	ff 75 e4             	pushl  -0x1c(%ebp)
  80150c:	e8 9c fd ff ff       	call   8012ad <fd2data>
  801511:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  801513:	89 1c 24             	mov    %ebx,(%esp)
  801516:	e8 92 fd ff ff       	call   8012ad <fd2data>
  80151b:	83 c4 10             	add    $0x10,%esp
  80151e:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801520:	89 f0                	mov    %esi,%eax
  801522:	c1 e8 16             	shr    $0x16,%eax
  801525:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80152c:	a8 01                	test   $0x1,%al
  80152e:	74 35                	je     801565 <dup+0x96>
  801530:	89 f0                	mov    %esi,%eax
  801532:	c1 e8 0c             	shr    $0xc,%eax
  801535:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80153c:	f6 c2 01             	test   $0x1,%dl
  80153f:	74 24                	je     801565 <dup+0x96>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801541:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801548:	83 ec 0c             	sub    $0xc,%esp
  80154b:	25 07 0e 00 00       	and    $0xe07,%eax
  801550:	50                   	push   %eax
  801551:	57                   	push   %edi
  801552:	6a 00                	push   $0x0
  801554:	56                   	push   %esi
  801555:	6a 00                	push   $0x0
  801557:	e8 b8 f8 ff ff       	call   800e14 <sys_page_map>
  80155c:	89 c6                	mov    %eax,%esi
  80155e:	83 c4 20             	add    $0x20,%esp
  801561:	85 c0                	test   %eax,%eax
  801563:	78 2c                	js     801591 <dup+0xc2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801565:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801568:	89 d0                	mov    %edx,%eax
  80156a:	c1 e8 0c             	shr    $0xc,%eax
  80156d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801574:	83 ec 0c             	sub    $0xc,%esp
  801577:	25 07 0e 00 00       	and    $0xe07,%eax
  80157c:	50                   	push   %eax
  80157d:	53                   	push   %ebx
  80157e:	6a 00                	push   $0x0
  801580:	52                   	push   %edx
  801581:	6a 00                	push   $0x0
  801583:	e8 8c f8 ff ff       	call   800e14 <sys_page_map>
  801588:	89 c6                	mov    %eax,%esi
  80158a:	83 c4 20             	add    $0x20,%esp
  80158d:	85 c0                	test   %eax,%eax
  80158f:	79 1d                	jns    8015ae <dup+0xdf>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801591:	83 ec 08             	sub    $0x8,%esp
  801594:	53                   	push   %ebx
  801595:	6a 00                	push   $0x0
  801597:	e8 ba f8 ff ff       	call   800e56 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80159c:	83 c4 08             	add    $0x8,%esp
  80159f:	57                   	push   %edi
  8015a0:	6a 00                	push   $0x0
  8015a2:	e8 af f8 ff ff       	call   800e56 <sys_page_unmap>
	return r;
  8015a7:	83 c4 10             	add    $0x10,%esp
  8015aa:	89 f0                	mov    %esi,%eax
  8015ac:	eb 03                	jmp    8015b1 <dup+0xe2>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  8015ae:	8b 45 0c             	mov    0xc(%ebp),%eax

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8015b1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015b4:	5b                   	pop    %ebx
  8015b5:	5e                   	pop    %esi
  8015b6:	5f                   	pop    %edi
  8015b7:	5d                   	pop    %ebp
  8015b8:	c3                   	ret    

008015b9 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8015b9:	55                   	push   %ebp
  8015ba:	89 e5                	mov    %esp,%ebp
  8015bc:	53                   	push   %ebx
  8015bd:	83 ec 14             	sub    $0x14,%esp
  8015c0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015c3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015c6:	50                   	push   %eax
  8015c7:	53                   	push   %ebx
  8015c8:	e8 6b fd ff ff       	call   801338 <fd_lookup>
  8015cd:	83 c4 08             	add    $0x8,%esp
  8015d0:	85 c0                	test   %eax,%eax
  8015d2:	78 67                	js     80163b <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015d4:	83 ec 08             	sub    $0x8,%esp
  8015d7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015da:	50                   	push   %eax
  8015db:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015de:	ff 30                	pushl  (%eax)
  8015e0:	e8 aa fd ff ff       	call   80138f <dev_lookup>
  8015e5:	83 c4 10             	add    $0x10,%esp
  8015e8:	85 c0                	test   %eax,%eax
  8015ea:	78 4f                	js     80163b <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8015ec:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8015ef:	8b 42 08             	mov    0x8(%edx),%eax
  8015f2:	83 e0 03             	and    $0x3,%eax
  8015f5:	83 f8 01             	cmp    $0x1,%eax
  8015f8:	75 21                	jne    80161b <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8015fa:	a1 04 40 80 00       	mov    0x804004,%eax
  8015ff:	8b 40 48             	mov    0x48(%eax),%eax
  801602:	83 ec 04             	sub    $0x4,%esp
  801605:	53                   	push   %ebx
  801606:	50                   	push   %eax
  801607:	68 f8 28 80 00       	push   $0x8028f8
  80160c:	e8 6b ed ff ff       	call   80037c <cprintf>
		return -E_INVAL;
  801611:	83 c4 10             	add    $0x10,%esp
  801614:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801619:	eb 20                	jmp    80163b <read+0x82>
	}
	if (!dev->dev_read)
  80161b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80161e:	8b 40 08             	mov    0x8(%eax),%eax
  801621:	85 c0                	test   %eax,%eax
  801623:	74 11                	je     801636 <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801625:	83 ec 04             	sub    $0x4,%esp
  801628:	ff 75 10             	pushl  0x10(%ebp)
  80162b:	ff 75 0c             	pushl  0xc(%ebp)
  80162e:	52                   	push   %edx
  80162f:	ff d0                	call   *%eax
  801631:	83 c4 10             	add    $0x10,%esp
  801634:	eb 05                	jmp    80163b <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801636:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  80163b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80163e:	c9                   	leave  
  80163f:	c3                   	ret    

00801640 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801640:	55                   	push   %ebp
  801641:	89 e5                	mov    %esp,%ebp
  801643:	57                   	push   %edi
  801644:	56                   	push   %esi
  801645:	53                   	push   %ebx
  801646:	83 ec 0c             	sub    $0xc,%esp
  801649:	8b 7d 08             	mov    0x8(%ebp),%edi
  80164c:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80164f:	85 f6                	test   %esi,%esi
  801651:	74 31                	je     801684 <readn+0x44>
  801653:	b8 00 00 00 00       	mov    $0x0,%eax
  801658:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  80165d:	83 ec 04             	sub    $0x4,%esp
  801660:	89 f2                	mov    %esi,%edx
  801662:	29 c2                	sub    %eax,%edx
  801664:	52                   	push   %edx
  801665:	03 45 0c             	add    0xc(%ebp),%eax
  801668:	50                   	push   %eax
  801669:	57                   	push   %edi
  80166a:	e8 4a ff ff ff       	call   8015b9 <read>
		if (m < 0)
  80166f:	83 c4 10             	add    $0x10,%esp
  801672:	85 c0                	test   %eax,%eax
  801674:	78 17                	js     80168d <readn+0x4d>
			return m;
		if (m == 0)
  801676:	85 c0                	test   %eax,%eax
  801678:	74 11                	je     80168b <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80167a:	01 c3                	add    %eax,%ebx
  80167c:	89 d8                	mov    %ebx,%eax
  80167e:	39 f3                	cmp    %esi,%ebx
  801680:	72 db                	jb     80165d <readn+0x1d>
  801682:	eb 09                	jmp    80168d <readn+0x4d>
  801684:	b8 00 00 00 00       	mov    $0x0,%eax
  801689:	eb 02                	jmp    80168d <readn+0x4d>
  80168b:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80168d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801690:	5b                   	pop    %ebx
  801691:	5e                   	pop    %esi
  801692:	5f                   	pop    %edi
  801693:	5d                   	pop    %ebp
  801694:	c3                   	ret    

00801695 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801695:	55                   	push   %ebp
  801696:	89 e5                	mov    %esp,%ebp
  801698:	53                   	push   %ebx
  801699:	83 ec 14             	sub    $0x14,%esp
  80169c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80169f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016a2:	50                   	push   %eax
  8016a3:	53                   	push   %ebx
  8016a4:	e8 8f fc ff ff       	call   801338 <fd_lookup>
  8016a9:	83 c4 08             	add    $0x8,%esp
  8016ac:	85 c0                	test   %eax,%eax
  8016ae:	78 62                	js     801712 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016b0:	83 ec 08             	sub    $0x8,%esp
  8016b3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016b6:	50                   	push   %eax
  8016b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016ba:	ff 30                	pushl  (%eax)
  8016bc:	e8 ce fc ff ff       	call   80138f <dev_lookup>
  8016c1:	83 c4 10             	add    $0x10,%esp
  8016c4:	85 c0                	test   %eax,%eax
  8016c6:	78 4a                	js     801712 <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016cb:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016cf:	75 21                	jne    8016f2 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8016d1:	a1 04 40 80 00       	mov    0x804004,%eax
  8016d6:	8b 40 48             	mov    0x48(%eax),%eax
  8016d9:	83 ec 04             	sub    $0x4,%esp
  8016dc:	53                   	push   %ebx
  8016dd:	50                   	push   %eax
  8016de:	68 14 29 80 00       	push   $0x802914
  8016e3:	e8 94 ec ff ff       	call   80037c <cprintf>
		return -E_INVAL;
  8016e8:	83 c4 10             	add    $0x10,%esp
  8016eb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016f0:	eb 20                	jmp    801712 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8016f2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016f5:	8b 52 0c             	mov    0xc(%edx),%edx
  8016f8:	85 d2                	test   %edx,%edx
  8016fa:	74 11                	je     80170d <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8016fc:	83 ec 04             	sub    $0x4,%esp
  8016ff:	ff 75 10             	pushl  0x10(%ebp)
  801702:	ff 75 0c             	pushl  0xc(%ebp)
  801705:	50                   	push   %eax
  801706:	ff d2                	call   *%edx
  801708:	83 c4 10             	add    $0x10,%esp
  80170b:	eb 05                	jmp    801712 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80170d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801712:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801715:	c9                   	leave  
  801716:	c3                   	ret    

00801717 <seek>:

int
seek(int fdnum, off_t offset)
{
  801717:	55                   	push   %ebp
  801718:	89 e5                	mov    %esp,%ebp
  80171a:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80171d:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801720:	50                   	push   %eax
  801721:	ff 75 08             	pushl  0x8(%ebp)
  801724:	e8 0f fc ff ff       	call   801338 <fd_lookup>
  801729:	83 c4 08             	add    $0x8,%esp
  80172c:	85 c0                	test   %eax,%eax
  80172e:	78 0e                	js     80173e <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801730:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801733:	8b 55 0c             	mov    0xc(%ebp),%edx
  801736:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801739:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80173e:	c9                   	leave  
  80173f:	c3                   	ret    

00801740 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801740:	55                   	push   %ebp
  801741:	89 e5                	mov    %esp,%ebp
  801743:	53                   	push   %ebx
  801744:	83 ec 14             	sub    $0x14,%esp
  801747:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80174a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80174d:	50                   	push   %eax
  80174e:	53                   	push   %ebx
  80174f:	e8 e4 fb ff ff       	call   801338 <fd_lookup>
  801754:	83 c4 08             	add    $0x8,%esp
  801757:	85 c0                	test   %eax,%eax
  801759:	78 5f                	js     8017ba <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80175b:	83 ec 08             	sub    $0x8,%esp
  80175e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801761:	50                   	push   %eax
  801762:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801765:	ff 30                	pushl  (%eax)
  801767:	e8 23 fc ff ff       	call   80138f <dev_lookup>
  80176c:	83 c4 10             	add    $0x10,%esp
  80176f:	85 c0                	test   %eax,%eax
  801771:	78 47                	js     8017ba <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801773:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801776:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80177a:	75 21                	jne    80179d <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80177c:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801781:	8b 40 48             	mov    0x48(%eax),%eax
  801784:	83 ec 04             	sub    $0x4,%esp
  801787:	53                   	push   %ebx
  801788:	50                   	push   %eax
  801789:	68 d4 28 80 00       	push   $0x8028d4
  80178e:	e8 e9 eb ff ff       	call   80037c <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801793:	83 c4 10             	add    $0x10,%esp
  801796:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80179b:	eb 1d                	jmp    8017ba <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  80179d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017a0:	8b 52 18             	mov    0x18(%edx),%edx
  8017a3:	85 d2                	test   %edx,%edx
  8017a5:	74 0e                	je     8017b5 <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8017a7:	83 ec 08             	sub    $0x8,%esp
  8017aa:	ff 75 0c             	pushl  0xc(%ebp)
  8017ad:	50                   	push   %eax
  8017ae:	ff d2                	call   *%edx
  8017b0:	83 c4 10             	add    $0x10,%esp
  8017b3:	eb 05                	jmp    8017ba <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8017b5:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8017ba:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017bd:	c9                   	leave  
  8017be:	c3                   	ret    

008017bf <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8017bf:	55                   	push   %ebp
  8017c0:	89 e5                	mov    %esp,%ebp
  8017c2:	53                   	push   %ebx
  8017c3:	83 ec 14             	sub    $0x14,%esp
  8017c6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017c9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017cc:	50                   	push   %eax
  8017cd:	ff 75 08             	pushl  0x8(%ebp)
  8017d0:	e8 63 fb ff ff       	call   801338 <fd_lookup>
  8017d5:	83 c4 08             	add    $0x8,%esp
  8017d8:	85 c0                	test   %eax,%eax
  8017da:	78 52                	js     80182e <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017dc:	83 ec 08             	sub    $0x8,%esp
  8017df:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017e2:	50                   	push   %eax
  8017e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017e6:	ff 30                	pushl  (%eax)
  8017e8:	e8 a2 fb ff ff       	call   80138f <dev_lookup>
  8017ed:	83 c4 10             	add    $0x10,%esp
  8017f0:	85 c0                	test   %eax,%eax
  8017f2:	78 3a                	js     80182e <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  8017f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017f7:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8017fb:	74 2c                	je     801829 <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8017fd:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801800:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801807:	00 00 00 
	stat->st_isdir = 0;
  80180a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801811:	00 00 00 
	stat->st_dev = dev;
  801814:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80181a:	83 ec 08             	sub    $0x8,%esp
  80181d:	53                   	push   %ebx
  80181e:	ff 75 f0             	pushl  -0x10(%ebp)
  801821:	ff 50 14             	call   *0x14(%eax)
  801824:	83 c4 10             	add    $0x10,%esp
  801827:	eb 05                	jmp    80182e <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801829:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80182e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801831:	c9                   	leave  
  801832:	c3                   	ret    

00801833 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801833:	55                   	push   %ebp
  801834:	89 e5                	mov    %esp,%ebp
  801836:	56                   	push   %esi
  801837:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801838:	83 ec 08             	sub    $0x8,%esp
  80183b:	6a 00                	push   $0x0
  80183d:	ff 75 08             	pushl  0x8(%ebp)
  801840:	e8 75 01 00 00       	call   8019ba <open>
  801845:	89 c3                	mov    %eax,%ebx
  801847:	83 c4 10             	add    $0x10,%esp
  80184a:	85 c0                	test   %eax,%eax
  80184c:	78 1d                	js     80186b <stat+0x38>
		return fd;
	r = fstat(fd, stat);
  80184e:	83 ec 08             	sub    $0x8,%esp
  801851:	ff 75 0c             	pushl  0xc(%ebp)
  801854:	50                   	push   %eax
  801855:	e8 65 ff ff ff       	call   8017bf <fstat>
  80185a:	89 c6                	mov    %eax,%esi
	close(fd);
  80185c:	89 1c 24             	mov    %ebx,(%esp)
  80185f:	e8 1d fc ff ff       	call   801481 <close>
	return r;
  801864:	83 c4 10             	add    $0x10,%esp
  801867:	89 f0                	mov    %esi,%eax
  801869:	eb 00                	jmp    80186b <stat+0x38>
}
  80186b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80186e:	5b                   	pop    %ebx
  80186f:	5e                   	pop    %esi
  801870:	5d                   	pop    %ebp
  801871:	c3                   	ret    

00801872 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801872:	55                   	push   %ebp
  801873:	89 e5                	mov    %esp,%ebp
  801875:	56                   	push   %esi
  801876:	53                   	push   %ebx
  801877:	89 c6                	mov    %eax,%esi
  801879:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80187b:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801882:	75 12                	jne    801896 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801884:	83 ec 0c             	sub    $0xc,%esp
  801887:	6a 01                	push   $0x1
  801889:	e8 19 08 00 00       	call   8020a7 <ipc_find_env>
  80188e:	a3 00 40 80 00       	mov    %eax,0x804000
  801893:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801896:	6a 07                	push   $0x7
  801898:	68 00 50 80 00       	push   $0x805000
  80189d:	56                   	push   %esi
  80189e:	ff 35 00 40 80 00    	pushl  0x804000
  8018a4:	e8 9f 07 00 00       	call   802048 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8018a9:	83 c4 0c             	add    $0xc,%esp
  8018ac:	6a 00                	push   $0x0
  8018ae:	53                   	push   %ebx
  8018af:	6a 00                	push   $0x0
  8018b1:	e8 1d 07 00 00       	call   801fd3 <ipc_recv>
}
  8018b6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018b9:	5b                   	pop    %ebx
  8018ba:	5e                   	pop    %esi
  8018bb:	5d                   	pop    %ebp
  8018bc:	c3                   	ret    

008018bd <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8018bd:	55                   	push   %ebp
  8018be:	89 e5                	mov    %esp,%ebp
  8018c0:	53                   	push   %ebx
  8018c1:	83 ec 04             	sub    $0x4,%esp
  8018c4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8018c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8018ca:	8b 40 0c             	mov    0xc(%eax),%eax
  8018cd:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8018d2:	ba 00 00 00 00       	mov    $0x0,%edx
  8018d7:	b8 05 00 00 00       	mov    $0x5,%eax
  8018dc:	e8 91 ff ff ff       	call   801872 <fsipc>
  8018e1:	85 c0                	test   %eax,%eax
  8018e3:	78 2c                	js     801911 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8018e5:	83 ec 08             	sub    $0x8,%esp
  8018e8:	68 00 50 80 00       	push   $0x805000
  8018ed:	53                   	push   %ebx
  8018ee:	e8 6e f0 ff ff       	call   800961 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8018f3:	a1 80 50 80 00       	mov    0x805080,%eax
  8018f8:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8018fe:	a1 84 50 80 00       	mov    0x805084,%eax
  801903:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801909:	83 c4 10             	add    $0x10,%esp
  80190c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801911:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801914:	c9                   	leave  
  801915:	c3                   	ret    

00801916 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801916:	55                   	push   %ebp
  801917:	89 e5                	mov    %esp,%ebp
  801919:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80191c:	8b 45 08             	mov    0x8(%ebp),%eax
  80191f:	8b 40 0c             	mov    0xc(%eax),%eax
  801922:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801927:	ba 00 00 00 00       	mov    $0x0,%edx
  80192c:	b8 06 00 00 00       	mov    $0x6,%eax
  801931:	e8 3c ff ff ff       	call   801872 <fsipc>
}
  801936:	c9                   	leave  
  801937:	c3                   	ret    

00801938 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801938:	55                   	push   %ebp
  801939:	89 e5                	mov    %esp,%ebp
  80193b:	56                   	push   %esi
  80193c:	53                   	push   %ebx
  80193d:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801940:	8b 45 08             	mov    0x8(%ebp),%eax
  801943:	8b 40 0c             	mov    0xc(%eax),%eax
  801946:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80194b:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801951:	ba 00 00 00 00       	mov    $0x0,%edx
  801956:	b8 03 00 00 00       	mov    $0x3,%eax
  80195b:	e8 12 ff ff ff       	call   801872 <fsipc>
  801960:	89 c3                	mov    %eax,%ebx
  801962:	85 c0                	test   %eax,%eax
  801964:	78 4b                	js     8019b1 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801966:	39 c6                	cmp    %eax,%esi
  801968:	73 16                	jae    801980 <devfile_read+0x48>
  80196a:	68 31 29 80 00       	push   $0x802931
  80196f:	68 38 29 80 00       	push   $0x802938
  801974:	6a 7a                	push   $0x7a
  801976:	68 4d 29 80 00       	push   $0x80294d
  80197b:	e8 24 e9 ff ff       	call   8002a4 <_panic>
	assert(r <= PGSIZE);
  801980:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801985:	7e 16                	jle    80199d <devfile_read+0x65>
  801987:	68 58 29 80 00       	push   $0x802958
  80198c:	68 38 29 80 00       	push   $0x802938
  801991:	6a 7b                	push   $0x7b
  801993:	68 4d 29 80 00       	push   $0x80294d
  801998:	e8 07 e9 ff ff       	call   8002a4 <_panic>
	memmove(buf, &fsipcbuf, r);
  80199d:	83 ec 04             	sub    $0x4,%esp
  8019a0:	50                   	push   %eax
  8019a1:	68 00 50 80 00       	push   $0x805000
  8019a6:	ff 75 0c             	pushl  0xc(%ebp)
  8019a9:	e8 80 f1 ff ff       	call   800b2e <memmove>
	return r;
  8019ae:	83 c4 10             	add    $0x10,%esp
}
  8019b1:	89 d8                	mov    %ebx,%eax
  8019b3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019b6:	5b                   	pop    %ebx
  8019b7:	5e                   	pop    %esi
  8019b8:	5d                   	pop    %ebp
  8019b9:	c3                   	ret    

008019ba <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8019ba:	55                   	push   %ebp
  8019bb:	89 e5                	mov    %esp,%ebp
  8019bd:	53                   	push   %ebx
  8019be:	83 ec 20             	sub    $0x20,%esp
  8019c1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8019c4:	53                   	push   %ebx
  8019c5:	e8 40 ef ff ff       	call   80090a <strlen>
  8019ca:	83 c4 10             	add    $0x10,%esp
  8019cd:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8019d2:	7f 63                	jg     801a37 <open+0x7d>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8019d4:	83 ec 0c             	sub    $0xc,%esp
  8019d7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019da:	50                   	push   %eax
  8019db:	e8 e4 f8 ff ff       	call   8012c4 <fd_alloc>
  8019e0:	83 c4 10             	add    $0x10,%esp
  8019e3:	85 c0                	test   %eax,%eax
  8019e5:	78 55                	js     801a3c <open+0x82>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8019e7:	83 ec 08             	sub    $0x8,%esp
  8019ea:	53                   	push   %ebx
  8019eb:	68 00 50 80 00       	push   $0x805000
  8019f0:	e8 6c ef ff ff       	call   800961 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8019f5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019f8:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8019fd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a00:	b8 01 00 00 00       	mov    $0x1,%eax
  801a05:	e8 68 fe ff ff       	call   801872 <fsipc>
  801a0a:	89 c3                	mov    %eax,%ebx
  801a0c:	83 c4 10             	add    $0x10,%esp
  801a0f:	85 c0                	test   %eax,%eax
  801a11:	79 14                	jns    801a27 <open+0x6d>
		fd_close(fd, 0);
  801a13:	83 ec 08             	sub    $0x8,%esp
  801a16:	6a 00                	push   $0x0
  801a18:	ff 75 f4             	pushl  -0xc(%ebp)
  801a1b:	e8 dd f9 ff ff       	call   8013fd <fd_close>
		return r;
  801a20:	83 c4 10             	add    $0x10,%esp
  801a23:	89 d8                	mov    %ebx,%eax
  801a25:	eb 15                	jmp    801a3c <open+0x82>
	}

	return fd2num(fd);
  801a27:	83 ec 0c             	sub    $0xc,%esp
  801a2a:	ff 75 f4             	pushl  -0xc(%ebp)
  801a2d:	e8 6b f8 ff ff       	call   80129d <fd2num>
  801a32:	83 c4 10             	add    $0x10,%esp
  801a35:	eb 05                	jmp    801a3c <open+0x82>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801a37:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801a3c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a3f:	c9                   	leave  
  801a40:	c3                   	ret    

00801a41 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801a41:	55                   	push   %ebp
  801a42:	89 e5                	mov    %esp,%ebp
  801a44:	56                   	push   %esi
  801a45:	53                   	push   %ebx
  801a46:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a49:	83 ec 0c             	sub    $0xc,%esp
  801a4c:	ff 75 08             	pushl  0x8(%ebp)
  801a4f:	e8 59 f8 ff ff       	call   8012ad <fd2data>
  801a54:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801a56:	83 c4 08             	add    $0x8,%esp
  801a59:	68 64 29 80 00       	push   $0x802964
  801a5e:	53                   	push   %ebx
  801a5f:	e8 fd ee ff ff       	call   800961 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801a64:	8b 46 04             	mov    0x4(%esi),%eax
  801a67:	2b 06                	sub    (%esi),%eax
  801a69:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801a6f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a76:	00 00 00 
	stat->st_dev = &devpipe;
  801a79:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801a80:	30 80 00 
	return 0;
}
  801a83:	b8 00 00 00 00       	mov    $0x0,%eax
  801a88:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a8b:	5b                   	pop    %ebx
  801a8c:	5e                   	pop    %esi
  801a8d:	5d                   	pop    %ebp
  801a8e:	c3                   	ret    

00801a8f <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a8f:	55                   	push   %ebp
  801a90:	89 e5                	mov    %esp,%ebp
  801a92:	53                   	push   %ebx
  801a93:	83 ec 0c             	sub    $0xc,%esp
  801a96:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a99:	53                   	push   %ebx
  801a9a:	6a 00                	push   $0x0
  801a9c:	e8 b5 f3 ff ff       	call   800e56 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801aa1:	89 1c 24             	mov    %ebx,(%esp)
  801aa4:	e8 04 f8 ff ff       	call   8012ad <fd2data>
  801aa9:	83 c4 08             	add    $0x8,%esp
  801aac:	50                   	push   %eax
  801aad:	6a 00                	push   $0x0
  801aaf:	e8 a2 f3 ff ff       	call   800e56 <sys_page_unmap>
}
  801ab4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ab7:	c9                   	leave  
  801ab8:	c3                   	ret    

00801ab9 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801ab9:	55                   	push   %ebp
  801aba:	89 e5                	mov    %esp,%ebp
  801abc:	57                   	push   %edi
  801abd:	56                   	push   %esi
  801abe:	53                   	push   %ebx
  801abf:	83 ec 1c             	sub    $0x1c,%esp
  801ac2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801ac5:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801ac7:	a1 04 40 80 00       	mov    0x804004,%eax
  801acc:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801acf:	83 ec 0c             	sub    $0xc,%esp
  801ad2:	ff 75 e0             	pushl  -0x20(%ebp)
  801ad5:	e8 28 06 00 00       	call   802102 <pageref>
  801ada:	89 c3                	mov    %eax,%ebx
  801adc:	89 3c 24             	mov    %edi,(%esp)
  801adf:	e8 1e 06 00 00       	call   802102 <pageref>
  801ae4:	83 c4 10             	add    $0x10,%esp
  801ae7:	39 c3                	cmp    %eax,%ebx
  801ae9:	0f 94 c1             	sete   %cl
  801aec:	0f b6 c9             	movzbl %cl,%ecx
  801aef:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801af2:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801af8:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801afb:	39 ce                	cmp    %ecx,%esi
  801afd:	74 1b                	je     801b1a <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801aff:	39 c3                	cmp    %eax,%ebx
  801b01:	75 c4                	jne    801ac7 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801b03:	8b 42 58             	mov    0x58(%edx),%eax
  801b06:	ff 75 e4             	pushl  -0x1c(%ebp)
  801b09:	50                   	push   %eax
  801b0a:	56                   	push   %esi
  801b0b:	68 6b 29 80 00       	push   $0x80296b
  801b10:	e8 67 e8 ff ff       	call   80037c <cprintf>
  801b15:	83 c4 10             	add    $0x10,%esp
  801b18:	eb ad                	jmp    801ac7 <_pipeisclosed+0xe>
	}
}
  801b1a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b1d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b20:	5b                   	pop    %ebx
  801b21:	5e                   	pop    %esi
  801b22:	5f                   	pop    %edi
  801b23:	5d                   	pop    %ebp
  801b24:	c3                   	ret    

00801b25 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801b25:	55                   	push   %ebp
  801b26:	89 e5                	mov    %esp,%ebp
  801b28:	57                   	push   %edi
  801b29:	56                   	push   %esi
  801b2a:	53                   	push   %ebx
  801b2b:	83 ec 18             	sub    $0x18,%esp
  801b2e:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801b31:	56                   	push   %esi
  801b32:	e8 76 f7 ff ff       	call   8012ad <fd2data>
  801b37:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b39:	83 c4 10             	add    $0x10,%esp
  801b3c:	bf 00 00 00 00       	mov    $0x0,%edi
  801b41:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801b45:	75 42                	jne    801b89 <devpipe_write+0x64>
  801b47:	eb 4e                	jmp    801b97 <devpipe_write+0x72>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801b49:	89 da                	mov    %ebx,%edx
  801b4b:	89 f0                	mov    %esi,%eax
  801b4d:	e8 67 ff ff ff       	call   801ab9 <_pipeisclosed>
  801b52:	85 c0                	test   %eax,%eax
  801b54:	75 46                	jne    801b9c <devpipe_write+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801b56:	e8 57 f2 ff ff       	call   800db2 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b5b:	8b 53 04             	mov    0x4(%ebx),%edx
  801b5e:	8b 03                	mov    (%ebx),%eax
  801b60:	83 c0 20             	add    $0x20,%eax
  801b63:	39 c2                	cmp    %eax,%edx
  801b65:	73 e2                	jae    801b49 <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801b67:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b6a:	8a 0c 38             	mov    (%eax,%edi,1),%cl
  801b6d:	89 d0                	mov    %edx,%eax
  801b6f:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801b74:	79 05                	jns    801b7b <devpipe_write+0x56>
  801b76:	48                   	dec    %eax
  801b77:	83 c8 e0             	or     $0xffffffe0,%eax
  801b7a:	40                   	inc    %eax
  801b7b:	88 4c 03 08          	mov    %cl,0x8(%ebx,%eax,1)
		p->p_wpos++;
  801b7f:	42                   	inc    %edx
  801b80:	89 53 04             	mov    %edx,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b83:	47                   	inc    %edi
  801b84:	39 7d 10             	cmp    %edi,0x10(%ebp)
  801b87:	74 0e                	je     801b97 <devpipe_write+0x72>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b89:	8b 53 04             	mov    0x4(%ebx),%edx
  801b8c:	8b 03                	mov    (%ebx),%eax
  801b8e:	83 c0 20             	add    $0x20,%eax
  801b91:	39 c2                	cmp    %eax,%edx
  801b93:	73 b4                	jae    801b49 <devpipe_write+0x24>
  801b95:	eb d0                	jmp    801b67 <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801b97:	8b 45 10             	mov    0x10(%ebp),%eax
  801b9a:	eb 05                	jmp    801ba1 <devpipe_write+0x7c>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b9c:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801ba1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ba4:	5b                   	pop    %ebx
  801ba5:	5e                   	pop    %esi
  801ba6:	5f                   	pop    %edi
  801ba7:	5d                   	pop    %ebp
  801ba8:	c3                   	ret    

00801ba9 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ba9:	55                   	push   %ebp
  801baa:	89 e5                	mov    %esp,%ebp
  801bac:	57                   	push   %edi
  801bad:	56                   	push   %esi
  801bae:	53                   	push   %ebx
  801baf:	83 ec 18             	sub    $0x18,%esp
  801bb2:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801bb5:	57                   	push   %edi
  801bb6:	e8 f2 f6 ff ff       	call   8012ad <fd2data>
  801bbb:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bbd:	83 c4 10             	add    $0x10,%esp
  801bc0:	be 00 00 00 00       	mov    $0x0,%esi
  801bc5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801bc9:	75 3d                	jne    801c08 <devpipe_read+0x5f>
  801bcb:	eb 48                	jmp    801c15 <devpipe_read+0x6c>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  801bcd:	89 f0                	mov    %esi,%eax
  801bcf:	eb 4e                	jmp    801c1f <devpipe_read+0x76>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801bd1:	89 da                	mov    %ebx,%edx
  801bd3:	89 f8                	mov    %edi,%eax
  801bd5:	e8 df fe ff ff       	call   801ab9 <_pipeisclosed>
  801bda:	85 c0                	test   %eax,%eax
  801bdc:	75 3c                	jne    801c1a <devpipe_read+0x71>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801bde:	e8 cf f1 ff ff       	call   800db2 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801be3:	8b 03                	mov    (%ebx),%eax
  801be5:	3b 43 04             	cmp    0x4(%ebx),%eax
  801be8:	74 e7                	je     801bd1 <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801bea:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801bef:	79 05                	jns    801bf6 <devpipe_read+0x4d>
  801bf1:	48                   	dec    %eax
  801bf2:	83 c8 e0             	or     $0xffffffe0,%eax
  801bf5:	40                   	inc    %eax
  801bf6:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801bfa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bfd:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801c00:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c02:	46                   	inc    %esi
  801c03:	39 75 10             	cmp    %esi,0x10(%ebp)
  801c06:	74 0d                	je     801c15 <devpipe_read+0x6c>
		while (p->p_rpos == p->p_wpos) {
  801c08:	8b 03                	mov    (%ebx),%eax
  801c0a:	3b 43 04             	cmp    0x4(%ebx),%eax
  801c0d:	75 db                	jne    801bea <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801c0f:	85 f6                	test   %esi,%esi
  801c11:	75 ba                	jne    801bcd <devpipe_read+0x24>
  801c13:	eb bc                	jmp    801bd1 <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801c15:	8b 45 10             	mov    0x10(%ebp),%eax
  801c18:	eb 05                	jmp    801c1f <devpipe_read+0x76>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c1a:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801c1f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c22:	5b                   	pop    %ebx
  801c23:	5e                   	pop    %esi
  801c24:	5f                   	pop    %edi
  801c25:	5d                   	pop    %ebp
  801c26:	c3                   	ret    

00801c27 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801c27:	55                   	push   %ebp
  801c28:	89 e5                	mov    %esp,%ebp
  801c2a:	56                   	push   %esi
  801c2b:	53                   	push   %ebx
  801c2c:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801c2f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c32:	50                   	push   %eax
  801c33:	e8 8c f6 ff ff       	call   8012c4 <fd_alloc>
  801c38:	83 c4 10             	add    $0x10,%esp
  801c3b:	85 c0                	test   %eax,%eax
  801c3d:	0f 88 2a 01 00 00    	js     801d6d <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c43:	83 ec 04             	sub    $0x4,%esp
  801c46:	68 07 04 00 00       	push   $0x407
  801c4b:	ff 75 f4             	pushl  -0xc(%ebp)
  801c4e:	6a 00                	push   $0x0
  801c50:	e8 7c f1 ff ff       	call   800dd1 <sys_page_alloc>
  801c55:	83 c4 10             	add    $0x10,%esp
  801c58:	85 c0                	test   %eax,%eax
  801c5a:	0f 88 0d 01 00 00    	js     801d6d <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801c60:	83 ec 0c             	sub    $0xc,%esp
  801c63:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c66:	50                   	push   %eax
  801c67:	e8 58 f6 ff ff       	call   8012c4 <fd_alloc>
  801c6c:	89 c3                	mov    %eax,%ebx
  801c6e:	83 c4 10             	add    $0x10,%esp
  801c71:	85 c0                	test   %eax,%eax
  801c73:	0f 88 e2 00 00 00    	js     801d5b <pipe+0x134>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c79:	83 ec 04             	sub    $0x4,%esp
  801c7c:	68 07 04 00 00       	push   $0x407
  801c81:	ff 75 f0             	pushl  -0x10(%ebp)
  801c84:	6a 00                	push   $0x0
  801c86:	e8 46 f1 ff ff       	call   800dd1 <sys_page_alloc>
  801c8b:	89 c3                	mov    %eax,%ebx
  801c8d:	83 c4 10             	add    $0x10,%esp
  801c90:	85 c0                	test   %eax,%eax
  801c92:	0f 88 c3 00 00 00    	js     801d5b <pipe+0x134>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801c98:	83 ec 0c             	sub    $0xc,%esp
  801c9b:	ff 75 f4             	pushl  -0xc(%ebp)
  801c9e:	e8 0a f6 ff ff       	call   8012ad <fd2data>
  801ca3:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ca5:	83 c4 0c             	add    $0xc,%esp
  801ca8:	68 07 04 00 00       	push   $0x407
  801cad:	50                   	push   %eax
  801cae:	6a 00                	push   $0x0
  801cb0:	e8 1c f1 ff ff       	call   800dd1 <sys_page_alloc>
  801cb5:	89 c3                	mov    %eax,%ebx
  801cb7:	83 c4 10             	add    $0x10,%esp
  801cba:	85 c0                	test   %eax,%eax
  801cbc:	0f 88 89 00 00 00    	js     801d4b <pipe+0x124>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cc2:	83 ec 0c             	sub    $0xc,%esp
  801cc5:	ff 75 f0             	pushl  -0x10(%ebp)
  801cc8:	e8 e0 f5 ff ff       	call   8012ad <fd2data>
  801ccd:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801cd4:	50                   	push   %eax
  801cd5:	6a 00                	push   $0x0
  801cd7:	56                   	push   %esi
  801cd8:	6a 00                	push   $0x0
  801cda:	e8 35 f1 ff ff       	call   800e14 <sys_page_map>
  801cdf:	89 c3                	mov    %eax,%ebx
  801ce1:	83 c4 20             	add    $0x20,%esp
  801ce4:	85 c0                	test   %eax,%eax
  801ce6:	78 55                	js     801d3d <pipe+0x116>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801ce8:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801cee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cf1:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801cf3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cf6:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801cfd:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801d03:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d06:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801d08:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d0b:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801d12:	83 ec 0c             	sub    $0xc,%esp
  801d15:	ff 75 f4             	pushl  -0xc(%ebp)
  801d18:	e8 80 f5 ff ff       	call   80129d <fd2num>
  801d1d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d20:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801d22:	83 c4 04             	add    $0x4,%esp
  801d25:	ff 75 f0             	pushl  -0x10(%ebp)
  801d28:	e8 70 f5 ff ff       	call   80129d <fd2num>
  801d2d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d30:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801d33:	83 c4 10             	add    $0x10,%esp
  801d36:	b8 00 00 00 00       	mov    $0x0,%eax
  801d3b:	eb 30                	jmp    801d6d <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  801d3d:	83 ec 08             	sub    $0x8,%esp
  801d40:	56                   	push   %esi
  801d41:	6a 00                	push   $0x0
  801d43:	e8 0e f1 ff ff       	call   800e56 <sys_page_unmap>
  801d48:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801d4b:	83 ec 08             	sub    $0x8,%esp
  801d4e:	ff 75 f0             	pushl  -0x10(%ebp)
  801d51:	6a 00                	push   $0x0
  801d53:	e8 fe f0 ff ff       	call   800e56 <sys_page_unmap>
  801d58:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801d5b:	83 ec 08             	sub    $0x8,%esp
  801d5e:	ff 75 f4             	pushl  -0xc(%ebp)
  801d61:	6a 00                	push   $0x0
  801d63:	e8 ee f0 ff ff       	call   800e56 <sys_page_unmap>
  801d68:	83 c4 10             	add    $0x10,%esp
  801d6b:	89 d8                	mov    %ebx,%eax
    err:
	return r;
}
  801d6d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d70:	5b                   	pop    %ebx
  801d71:	5e                   	pop    %esi
  801d72:	5d                   	pop    %ebp
  801d73:	c3                   	ret    

00801d74 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801d74:	55                   	push   %ebp
  801d75:	89 e5                	mov    %esp,%ebp
  801d77:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d7a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d7d:	50                   	push   %eax
  801d7e:	ff 75 08             	pushl  0x8(%ebp)
  801d81:	e8 b2 f5 ff ff       	call   801338 <fd_lookup>
  801d86:	83 c4 10             	add    $0x10,%esp
  801d89:	85 c0                	test   %eax,%eax
  801d8b:	78 18                	js     801da5 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801d8d:	83 ec 0c             	sub    $0xc,%esp
  801d90:	ff 75 f4             	pushl  -0xc(%ebp)
  801d93:	e8 15 f5 ff ff       	call   8012ad <fd2data>
	return _pipeisclosed(fd, p);
  801d98:	89 c2                	mov    %eax,%edx
  801d9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d9d:	e8 17 fd ff ff       	call   801ab9 <_pipeisclosed>
  801da2:	83 c4 10             	add    $0x10,%esp
}
  801da5:	c9                   	leave  
  801da6:	c3                   	ret    

00801da7 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801da7:	55                   	push   %ebp
  801da8:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801daa:	b8 00 00 00 00       	mov    $0x0,%eax
  801daf:	5d                   	pop    %ebp
  801db0:	c3                   	ret    

00801db1 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801db1:	55                   	push   %ebp
  801db2:	89 e5                	mov    %esp,%ebp
  801db4:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801db7:	68 7e 29 80 00       	push   $0x80297e
  801dbc:	ff 75 0c             	pushl  0xc(%ebp)
  801dbf:	e8 9d eb ff ff       	call   800961 <strcpy>
	return 0;
}
  801dc4:	b8 00 00 00 00       	mov    $0x0,%eax
  801dc9:	c9                   	leave  
  801dca:	c3                   	ret    

00801dcb <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801dcb:	55                   	push   %ebp
  801dcc:	89 e5                	mov    %esp,%ebp
  801dce:	57                   	push   %edi
  801dcf:	56                   	push   %esi
  801dd0:	53                   	push   %ebx
  801dd1:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801dd7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801ddb:	74 45                	je     801e22 <devcons_write+0x57>
  801ddd:	b8 00 00 00 00       	mov    $0x0,%eax
  801de2:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801de7:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801ded:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801df0:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  801df2:	83 fb 7f             	cmp    $0x7f,%ebx
  801df5:	76 05                	jbe    801dfc <devcons_write+0x31>
			m = sizeof(buf) - 1;
  801df7:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801dfc:	83 ec 04             	sub    $0x4,%esp
  801dff:	53                   	push   %ebx
  801e00:	03 45 0c             	add    0xc(%ebp),%eax
  801e03:	50                   	push   %eax
  801e04:	57                   	push   %edi
  801e05:	e8 24 ed ff ff       	call   800b2e <memmove>
		sys_cputs(buf, m);
  801e0a:	83 c4 08             	add    $0x8,%esp
  801e0d:	53                   	push   %ebx
  801e0e:	57                   	push   %edi
  801e0f:	e8 01 ef ff ff       	call   800d15 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e14:	01 de                	add    %ebx,%esi
  801e16:	89 f0                	mov    %esi,%eax
  801e18:	83 c4 10             	add    $0x10,%esp
  801e1b:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e1e:	72 cd                	jb     801ded <devcons_write+0x22>
  801e20:	eb 05                	jmp    801e27 <devcons_write+0x5c>
  801e22:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801e27:	89 f0                	mov    %esi,%eax
  801e29:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e2c:	5b                   	pop    %ebx
  801e2d:	5e                   	pop    %esi
  801e2e:	5f                   	pop    %edi
  801e2f:	5d                   	pop    %ebp
  801e30:	c3                   	ret    

00801e31 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801e31:	55                   	push   %ebp
  801e32:	89 e5                	mov    %esp,%ebp
  801e34:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801e37:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801e3b:	75 07                	jne    801e44 <devcons_read+0x13>
  801e3d:	eb 23                	jmp    801e62 <devcons_read+0x31>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801e3f:	e8 6e ef ff ff       	call   800db2 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801e44:	e8 ea ee ff ff       	call   800d33 <sys_cgetc>
  801e49:	85 c0                	test   %eax,%eax
  801e4b:	74 f2                	je     801e3f <devcons_read+0xe>
		sys_yield();
	if (c < 0)
  801e4d:	85 c0                	test   %eax,%eax
  801e4f:	78 1d                	js     801e6e <devcons_read+0x3d>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801e51:	83 f8 04             	cmp    $0x4,%eax
  801e54:	74 13                	je     801e69 <devcons_read+0x38>
		return 0;
	*(char*)vbuf = c;
  801e56:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e59:	88 02                	mov    %al,(%edx)
	return 1;
  801e5b:	b8 01 00 00 00       	mov    $0x1,%eax
  801e60:	eb 0c                	jmp    801e6e <devcons_read+0x3d>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801e62:	b8 00 00 00 00       	mov    $0x0,%eax
  801e67:	eb 05                	jmp    801e6e <devcons_read+0x3d>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801e69:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801e6e:	c9                   	leave  
  801e6f:	c3                   	ret    

00801e70 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801e70:	55                   	push   %ebp
  801e71:	89 e5                	mov    %esp,%ebp
  801e73:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801e76:	8b 45 08             	mov    0x8(%ebp),%eax
  801e79:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801e7c:	6a 01                	push   $0x1
  801e7e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e81:	50                   	push   %eax
  801e82:	e8 8e ee ff ff       	call   800d15 <sys_cputs>
}
  801e87:	83 c4 10             	add    $0x10,%esp
  801e8a:	c9                   	leave  
  801e8b:	c3                   	ret    

00801e8c <getchar>:

int
getchar(void)
{
  801e8c:	55                   	push   %ebp
  801e8d:	89 e5                	mov    %esp,%ebp
  801e8f:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801e92:	6a 01                	push   $0x1
  801e94:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e97:	50                   	push   %eax
  801e98:	6a 00                	push   $0x0
  801e9a:	e8 1a f7 ff ff       	call   8015b9 <read>
	if (r < 0)
  801e9f:	83 c4 10             	add    $0x10,%esp
  801ea2:	85 c0                	test   %eax,%eax
  801ea4:	78 0f                	js     801eb5 <getchar+0x29>
		return r;
	if (r < 1)
  801ea6:	85 c0                	test   %eax,%eax
  801ea8:	7e 06                	jle    801eb0 <getchar+0x24>
		return -E_EOF;
	return c;
  801eaa:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801eae:	eb 05                	jmp    801eb5 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801eb0:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801eb5:	c9                   	leave  
  801eb6:	c3                   	ret    

00801eb7 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801eb7:	55                   	push   %ebp
  801eb8:	89 e5                	mov    %esp,%ebp
  801eba:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ebd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ec0:	50                   	push   %eax
  801ec1:	ff 75 08             	pushl  0x8(%ebp)
  801ec4:	e8 6f f4 ff ff       	call   801338 <fd_lookup>
  801ec9:	83 c4 10             	add    $0x10,%esp
  801ecc:	85 c0                	test   %eax,%eax
  801ece:	78 11                	js     801ee1 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801ed0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ed3:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ed9:	39 10                	cmp    %edx,(%eax)
  801edb:	0f 94 c0             	sete   %al
  801ede:	0f b6 c0             	movzbl %al,%eax
}
  801ee1:	c9                   	leave  
  801ee2:	c3                   	ret    

00801ee3 <opencons>:

int
opencons(void)
{
  801ee3:	55                   	push   %ebp
  801ee4:	89 e5                	mov    %esp,%ebp
  801ee6:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ee9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801eec:	50                   	push   %eax
  801eed:	e8 d2 f3 ff ff       	call   8012c4 <fd_alloc>
  801ef2:	83 c4 10             	add    $0x10,%esp
  801ef5:	85 c0                	test   %eax,%eax
  801ef7:	78 3a                	js     801f33 <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ef9:	83 ec 04             	sub    $0x4,%esp
  801efc:	68 07 04 00 00       	push   $0x407
  801f01:	ff 75 f4             	pushl  -0xc(%ebp)
  801f04:	6a 00                	push   $0x0
  801f06:	e8 c6 ee ff ff       	call   800dd1 <sys_page_alloc>
  801f0b:	83 c4 10             	add    $0x10,%esp
  801f0e:	85 c0                	test   %eax,%eax
  801f10:	78 21                	js     801f33 <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801f12:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f18:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f1b:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801f1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f20:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801f27:	83 ec 0c             	sub    $0xc,%esp
  801f2a:	50                   	push   %eax
  801f2b:	e8 6d f3 ff ff       	call   80129d <fd2num>
  801f30:	83 c4 10             	add    $0x10,%esp
}
  801f33:	c9                   	leave  
  801f34:	c3                   	ret    

00801f35 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801f35:	55                   	push   %ebp
  801f36:	89 e5                	mov    %esp,%ebp
  801f38:	53                   	push   %ebx
  801f39:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (_pgfault_handler == 0) {
  801f3c:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801f43:	75 5b                	jne    801fa0 <set_pgfault_handler+0x6b>
		// First time through!
		// LAB 4: Your code here.
		void *va = (void *)(UXSTACKTOP - PGSIZE);
		envid_t eid = sys_getenvid();
  801f45:	e8 49 ee ff ff       	call   800d93 <sys_getenvid>
  801f4a:	89 c3                	mov    %eax,%ebx
		r = sys_page_alloc(eid,va,PTE_P | PTE_U | PTE_W);
  801f4c:	83 ec 04             	sub    $0x4,%esp
  801f4f:	6a 07                	push   $0x7
  801f51:	68 00 f0 bf ee       	push   $0xeebff000
  801f56:	50                   	push   %eax
  801f57:	e8 75 ee ff ff       	call   800dd1 <sys_page_alloc>
		if(r<0) panic("set_pgfault_handler\n");
  801f5c:	83 c4 10             	add    $0x10,%esp
  801f5f:	85 c0                	test   %eax,%eax
  801f61:	79 14                	jns    801f77 <set_pgfault_handler+0x42>
  801f63:	83 ec 04             	sub    $0x4,%esp
  801f66:	68 8a 29 80 00       	push   $0x80298a
  801f6b:	6a 23                	push   $0x23
  801f6d:	68 9f 29 80 00       	push   $0x80299f
  801f72:	e8 2d e3 ff ff       	call   8002a4 <_panic>
		r = sys_env_set_pgfault_upcall(eid,_pgfault_upcall);
  801f77:	83 ec 08             	sub    $0x8,%esp
  801f7a:	68 ad 1f 80 00       	push   $0x801fad
  801f7f:	53                   	push   %ebx
  801f80:	e8 97 ef ff ff       	call   800f1c <sys_env_set_pgfault_upcall>
		if(r<0) panic("set_pgfault_handler\n");
  801f85:	83 c4 10             	add    $0x10,%esp
  801f88:	85 c0                	test   %eax,%eax
  801f8a:	79 14                	jns    801fa0 <set_pgfault_handler+0x6b>
  801f8c:	83 ec 04             	sub    $0x4,%esp
  801f8f:	68 8a 29 80 00       	push   $0x80298a
  801f94:	6a 25                	push   $0x25
  801f96:	68 9f 29 80 00       	push   $0x80299f
  801f9b:	e8 04 e3 ff ff       	call   8002a4 <_panic>
		// panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801fa0:	8b 45 08             	mov    0x8(%ebp),%eax
  801fa3:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801fa8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801fab:	c9                   	leave  
  801fac:	c3                   	ret    

00801fad <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801fad:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801fae:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801fb3:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801fb5:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl %esp,%ebx
  801fb8:	89 e3                	mov    %esp,%ebx
	movl 40(%esp),%eax 	// esp from utf_fault_va to utf_regs(end)
  801fba:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl 48(%esp),%esp 	// 
  801fbe:	8b 64 24 30          	mov    0x30(%esp),%esp
	pushl %eax
  801fc2:	50                   	push   %eax
 
 
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	movl %ebx,%esp
  801fc3:	89 dc                	mov    %ebx,%esp
	subl $4,48(%esp)
  801fc5:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	popl %eax
  801fca:	58                   	pop    %eax
	popl %eax
  801fcb:	58                   	pop    %eax
	popal
  801fcc:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	add $4,%esp
  801fcd:	83 c4 04             	add    $0x4,%esp
	popfl
  801fd0:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  801fd1:	5c                   	pop    %esp
 
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801fd2:	c3                   	ret    

00801fd3 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801fd3:	55                   	push   %ebp
  801fd4:	89 e5                	mov    %esp,%ebp
  801fd6:	56                   	push   %esi
  801fd7:	53                   	push   %ebx
  801fd8:	8b 75 08             	mov    0x8(%ebp),%esi
  801fdb:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fde:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");
	int r;
    if (pg != NULL) {
  801fe1:	85 c0                	test   %eax,%eax
  801fe3:	74 0e                	je     801ff3 <ipc_recv+0x20>
        r = sys_ipc_recv(pg);
  801fe5:	83 ec 0c             	sub    $0xc,%esp
  801fe8:	50                   	push   %eax
  801fe9:	e8 93 ef ff ff       	call   800f81 <sys_ipc_recv>
  801fee:	83 c4 10             	add    $0x10,%esp
  801ff1:	eb 10                	jmp    802003 <ipc_recv+0x30>
    } else {
        r = sys_ipc_recv((void *) UTOP);
  801ff3:	83 ec 0c             	sub    $0xc,%esp
  801ff6:	68 00 00 c0 ee       	push   $0xeec00000
  801ffb:	e8 81 ef ff ff       	call   800f81 <sys_ipc_recv>
  802000:	83 c4 10             	add    $0x10,%esp
    }
    if (r < 0) {
  802003:	85 c0                	test   %eax,%eax
  802005:	79 16                	jns    80201d <ipc_recv+0x4a>
        // failed
        if (from_env_store != NULL) *from_env_store = 0;
  802007:	85 f6                	test   %esi,%esi
  802009:	74 06                	je     802011 <ipc_recv+0x3e>
  80200b:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        if (perm_store != NULL) *perm_store = 0;
  802011:	85 db                	test   %ebx,%ebx
  802013:	74 2c                	je     802041 <ipc_recv+0x6e>
  802015:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80201b:	eb 24                	jmp    802041 <ipc_recv+0x6e>
        return r;
    } else {
        if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  80201d:	85 f6                	test   %esi,%esi
  80201f:	74 0a                	je     80202b <ipc_recv+0x58>
  802021:	a1 04 40 80 00       	mov    0x804004,%eax
  802026:	8b 40 74             	mov    0x74(%eax),%eax
  802029:	89 06                	mov    %eax,(%esi)
        if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  80202b:	85 db                	test   %ebx,%ebx
  80202d:	74 0a                	je     802039 <ipc_recv+0x66>
  80202f:	a1 04 40 80 00       	mov    0x804004,%eax
  802034:	8b 40 78             	mov    0x78(%eax),%eax
  802037:	89 03                	mov    %eax,(%ebx)
        return thisenv->env_ipc_value;
  802039:	a1 04 40 80 00       	mov    0x804004,%eax
  80203e:	8b 40 70             	mov    0x70(%eax),%eax
    }
 
	return 0;
}
  802041:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802044:	5b                   	pop    %ebx
  802045:	5e                   	pop    %esi
  802046:	5d                   	pop    %ebp
  802047:	c3                   	ret    

00802048 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802048:	55                   	push   %ebp
  802049:	89 e5                	mov    %esp,%ebp
  80204b:	57                   	push   %edi
  80204c:	56                   	push   %esi
  80204d:	53                   	push   %ebx
  80204e:	83 ec 0c             	sub    $0xc,%esp
  802051:	8b 75 10             	mov    0x10(%ebp),%esi
  802054:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");
	int r;
    if (pg == NULL) pg = (void *)UTOP;
  802057:	85 f6                	test   %esi,%esi
  802059:	75 05                	jne    802060 <ipc_send+0x18>
  80205b:	be 00 00 c0 ee       	mov    $0xeec00000,%esi
    do {
        r = sys_ipc_try_send(to_env, val, pg, perm);
  802060:	57                   	push   %edi
  802061:	56                   	push   %esi
  802062:	ff 75 0c             	pushl  0xc(%ebp)
  802065:	ff 75 08             	pushl  0x8(%ebp)
  802068:	e8 f1 ee ff ff       	call   800f5e <sys_ipc_try_send>
  80206d:	89 c3                	mov    %eax,%ebx
        if (r < 0 && r != -E_IPC_NOT_RECV) panic("ipc send failed: %e", r);
  80206f:	83 c4 10             	add    $0x10,%esp
  802072:	85 c0                	test   %eax,%eax
  802074:	79 17                	jns    80208d <ipc_send+0x45>
  802076:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802079:	74 1d                	je     802098 <ipc_send+0x50>
  80207b:	50                   	push   %eax
  80207c:	68 ad 29 80 00       	push   $0x8029ad
  802081:	6a 40                	push   $0x40
  802083:	68 c1 29 80 00       	push   $0x8029c1
  802088:	e8 17 e2 ff ff       	call   8002a4 <_panic>
        sys_yield();
  80208d:	e8 20 ed ff ff       	call   800db2 <sys_yield>
    } while (r != 0);
  802092:	85 db                	test   %ebx,%ebx
  802094:	75 ca                	jne    802060 <ipc_send+0x18>
  802096:	eb 07                	jmp    80209f <ipc_send+0x57>
	int r;
    if (pg == NULL) pg = (void *)UTOP;
    do {
        r = sys_ipc_try_send(to_env, val, pg, perm);
        if (r < 0 && r != -E_IPC_NOT_RECV) panic("ipc send failed: %e", r);
        sys_yield();
  802098:	e8 15 ed ff ff       	call   800db2 <sys_yield>
  80209d:	eb c1                	jmp    802060 <ipc_send+0x18>
    } while (r != 0);
}
  80209f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020a2:	5b                   	pop    %ebx
  8020a3:	5e                   	pop    %esi
  8020a4:	5f                   	pop    %edi
  8020a5:	5d                   	pop    %ebp
  8020a6:	c3                   	ret    

008020a7 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8020a7:	55                   	push   %ebp
  8020a8:	89 e5                	mov    %esp,%ebp
  8020aa:	53                   	push   %ebx
  8020ab:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  8020ae:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  8020b3:	39 c1                	cmp    %eax,%ecx
  8020b5:	74 21                	je     8020d8 <ipc_find_env+0x31>
  8020b7:	ba 01 00 00 00       	mov    $0x1,%edx
  8020bc:	8d 1c 95 00 00 00 00 	lea    0x0(,%edx,4),%ebx
  8020c3:	89 d0                	mov    %edx,%eax
  8020c5:	c1 e0 07             	shl    $0x7,%eax
  8020c8:	29 d8                	sub    %ebx,%eax
  8020ca:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8020cf:	8b 40 50             	mov    0x50(%eax),%eax
  8020d2:	39 c8                	cmp    %ecx,%eax
  8020d4:	75 1b                	jne    8020f1 <ipc_find_env+0x4a>
  8020d6:	eb 05                	jmp    8020dd <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8020d8:	ba 00 00 00 00       	mov    $0x0,%edx
		if (envs[i].env_type == type)
			return envs[i].env_id;
  8020dd:	8d 04 95 00 00 00 00 	lea    0x0(,%edx,4),%eax
  8020e4:	c1 e2 07             	shl    $0x7,%edx
  8020e7:	29 c2                	sub    %eax,%edx
  8020e9:	8b 82 48 00 c0 ee    	mov    -0x113fffb8(%edx),%eax
  8020ef:	eb 0e                	jmp    8020ff <ipc_find_env+0x58>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8020f1:	42                   	inc    %edx
  8020f2:	81 fa 00 04 00 00    	cmp    $0x400,%edx
  8020f8:	75 c2                	jne    8020bc <ipc_find_env+0x15>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8020fa:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8020ff:	5b                   	pop    %ebx
  802100:	5d                   	pop    %ebp
  802101:	c3                   	ret    

00802102 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802102:	55                   	push   %ebp
  802103:	89 e5                	mov    %esp,%ebp
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802105:	8b 45 08             	mov    0x8(%ebp),%eax
  802108:	c1 e8 16             	shr    $0x16,%eax
  80210b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  802112:	a8 01                	test   $0x1,%al
  802114:	74 21                	je     802137 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  802116:	8b 45 08             	mov    0x8(%ebp),%eax
  802119:	c1 e8 0c             	shr    $0xc,%eax
  80211c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802123:	a8 01                	test   $0x1,%al
  802125:	74 17                	je     80213e <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802127:	c1 e8 0c             	shr    $0xc,%eax
  80212a:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  802131:	ef 
  802132:	0f b7 c0             	movzwl %ax,%eax
  802135:	eb 0c                	jmp    802143 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  802137:	b8 00 00 00 00       	mov    $0x0,%eax
  80213c:	eb 05                	jmp    802143 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  80213e:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  802143:	5d                   	pop    %ebp
  802144:	c3                   	ret    
  802145:	66 90                	xchg   %ax,%ax
  802147:	90                   	nop

00802148 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  802148:	55                   	push   %ebp
  802149:	57                   	push   %edi
  80214a:	56                   	push   %esi
  80214b:	53                   	push   %ebx
  80214c:	83 ec 1c             	sub    $0x1c,%esp
  80214f:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  802153:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802157:	8b 7c 24 38          	mov    0x38(%esp),%edi
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  80215b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80215f:	89 ca                	mov    %ecx,%edx
  const DWunion dd = {.ll = d};
  802161:	89 f8                	mov    %edi,%eax
  802163:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802167:	85 f6                	test   %esi,%esi
  802169:	75 2d                	jne    802198 <__udivdi3+0x50>
    {
      if (d0 > n1)
  80216b:	39 cf                	cmp    %ecx,%edi
  80216d:	77 65                	ja     8021d4 <__udivdi3+0x8c>
  80216f:	89 fd                	mov    %edi,%ebp
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802171:	85 ff                	test   %edi,%edi
  802173:	75 0b                	jne    802180 <__udivdi3+0x38>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802175:	b8 01 00 00 00       	mov    $0x1,%eax
  80217a:	31 d2                	xor    %edx,%edx
  80217c:	f7 f7                	div    %edi
  80217e:	89 c5                	mov    %eax,%ebp

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802180:	31 d2                	xor    %edx,%edx
  802182:	89 c8                	mov    %ecx,%eax
  802184:	f7 f5                	div    %ebp
  802186:	89 c1                	mov    %eax,%ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802188:	89 d8                	mov    %ebx,%eax
  80218a:	f7 f5                	div    %ebp
  80218c:	89 cf                	mov    %ecx,%edi
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80218e:	89 fa                	mov    %edi,%edx
  802190:	83 c4 1c             	add    $0x1c,%esp
  802193:	5b                   	pop    %ebx
  802194:	5e                   	pop    %esi
  802195:	5f                   	pop    %edi
  802196:	5d                   	pop    %ebp
  802197:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802198:	39 ce                	cmp    %ecx,%esi
  80219a:	77 28                	ja     8021c4 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  80219c:	0f bd fe             	bsr    %esi,%edi
	  if (bm == 0)
  80219f:	83 f7 1f             	xor    $0x1f,%edi
  8021a2:	75 40                	jne    8021e4 <__udivdi3+0x9c>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8021a4:	39 ce                	cmp    %ecx,%esi
  8021a6:	72 0a                	jb     8021b2 <__udivdi3+0x6a>
  8021a8:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8021ac:	0f 87 9e 00 00 00    	ja     802250 <__udivdi3+0x108>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8021b2:	b8 01 00 00 00       	mov    $0x1,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8021b7:	89 fa                	mov    %edi,%edx
  8021b9:	83 c4 1c             	add    $0x1c,%esp
  8021bc:	5b                   	pop    %ebx
  8021bd:	5e                   	pop    %esi
  8021be:	5f                   	pop    %edi
  8021bf:	5d                   	pop    %ebp
  8021c0:	c3                   	ret    
  8021c1:	8d 76 00             	lea    0x0(%esi),%esi
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8021c4:	31 ff                	xor    %edi,%edi
  8021c6:	31 c0                	xor    %eax,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8021c8:	89 fa                	mov    %edi,%edx
  8021ca:	83 c4 1c             	add    $0x1c,%esp
  8021cd:	5b                   	pop    %ebx
  8021ce:	5e                   	pop    %esi
  8021cf:	5f                   	pop    %edi
  8021d0:	5d                   	pop    %ebp
  8021d1:	c3                   	ret    
  8021d2:	66 90                	xchg   %ax,%ax
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8021d4:	89 d8                	mov    %ebx,%eax
  8021d6:	f7 f7                	div    %edi
  8021d8:	31 ff                	xor    %edi,%edi
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8021da:	89 fa                	mov    %edi,%edx
  8021dc:	83 c4 1c             	add    $0x1c,%esp
  8021df:	5b                   	pop    %ebx
  8021e0:	5e                   	pop    %esi
  8021e1:	5f                   	pop    %edi
  8021e2:	5d                   	pop    %ebp
  8021e3:	c3                   	ret    
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8021e4:	bd 20 00 00 00       	mov    $0x20,%ebp
  8021e9:	89 eb                	mov    %ebp,%ebx
  8021eb:	29 fb                	sub    %edi,%ebx

	      d1 = (d1 << bm) | (d0 >> b);
  8021ed:	89 f9                	mov    %edi,%ecx
  8021ef:	d3 e6                	shl    %cl,%esi
  8021f1:	89 c5                	mov    %eax,%ebp
  8021f3:	88 d9                	mov    %bl,%cl
  8021f5:	d3 ed                	shr    %cl,%ebp
  8021f7:	89 e9                	mov    %ebp,%ecx
  8021f9:	09 f1                	or     %esi,%ecx
  8021fb:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
	      d0 = d0 << bm;
  8021ff:	89 f9                	mov    %edi,%ecx
  802201:	d3 e0                	shl    %cl,%eax
  802203:	89 c5                	mov    %eax,%ebp
	      n2 = n1 >> b;
  802205:	89 d6                	mov    %edx,%esi
  802207:	88 d9                	mov    %bl,%cl
  802209:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
  80220b:	89 f9                	mov    %edi,%ecx
  80220d:	d3 e2                	shl    %cl,%edx
  80220f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802213:	88 d9                	mov    %bl,%cl
  802215:	d3 e8                	shr    %cl,%eax
  802217:	09 c2                	or     %eax,%edx
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802219:	89 d0                	mov    %edx,%eax
  80221b:	89 f2                	mov    %esi,%edx
  80221d:	f7 74 24 0c          	divl   0xc(%esp)
  802221:	89 d6                	mov    %edx,%esi
  802223:	89 c3                	mov    %eax,%ebx
	      umul_ppmm (m1, m0, q0, d0);
  802225:	f7 e5                	mul    %ebp

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802227:	39 d6                	cmp    %edx,%esi
  802229:	72 19                	jb     802244 <__udivdi3+0xfc>
  80222b:	74 0b                	je     802238 <__udivdi3+0xf0>
  80222d:	89 d8                	mov    %ebx,%eax
  80222f:	31 ff                	xor    %edi,%edi
  802231:	e9 58 ff ff ff       	jmp    80218e <__udivdi3+0x46>
  802236:	66 90                	xchg   %ax,%ax
  802238:	8b 54 24 08          	mov    0x8(%esp),%edx
  80223c:	89 f9                	mov    %edi,%ecx
  80223e:	d3 e2                	shl    %cl,%edx
  802240:	39 c2                	cmp    %eax,%edx
  802242:	73 e9                	jae    80222d <__udivdi3+0xe5>
  802244:	8d 43 ff             	lea    -0x1(%ebx),%eax
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802247:	31 ff                	xor    %edi,%edi
  802249:	e9 40 ff ff ff       	jmp    80218e <__udivdi3+0x46>
  80224e:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802250:	31 c0                	xor    %eax,%eax
  802252:	e9 37 ff ff ff       	jmp    80218e <__udivdi3+0x46>
  802257:	90                   	nop

00802258 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  802258:	55                   	push   %ebp
  802259:	57                   	push   %edi
  80225a:	56                   	push   %esi
  80225b:	53                   	push   %ebx
  80225c:	83 ec 1c             	sub    $0x1c,%esp
  80225f:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  802263:	8b 74 24 34          	mov    0x34(%esp),%esi
  802267:	8b 7c 24 38          	mov    0x38(%esp),%edi
  80226b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80226f:	89 44 24 0c          	mov    %eax,0xc(%esp)
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  802273:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802277:	89 f3                	mov    %esi,%ebx
  const DWunion dd = {.ll = d};
  802279:	89 fa                	mov    %edi,%edx
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  80227b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  n1 = nn.s.high;
  80227f:	89 34 24             	mov    %esi,(%esp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802282:	85 c0                	test   %eax,%eax
  802284:	75 1a                	jne    8022a0 <__umoddi3+0x48>
    {
      if (d0 > n1)
  802286:	39 f7                	cmp    %esi,%edi
  802288:	0f 86 a2 00 00 00    	jbe    802330 <__umoddi3+0xd8>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80228e:	89 c8                	mov    %ecx,%eax
  802290:	89 f2                	mov    %esi,%edx
  802292:	f7 f7                	div    %edi
  802294:	89 d0                	mov    %edx,%eax

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  802296:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802298:	83 c4 1c             	add    $0x1c,%esp
  80229b:	5b                   	pop    %ebx
  80229c:	5e                   	pop    %esi
  80229d:	5f                   	pop    %edi
  80229e:	5d                   	pop    %ebp
  80229f:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8022a0:	39 f0                	cmp    %esi,%eax
  8022a2:	0f 87 ac 00 00 00    	ja     802354 <__umoddi3+0xfc>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8022a8:	0f bd e8             	bsr    %eax,%ebp
	  if (bm == 0)
  8022ab:	83 f5 1f             	xor    $0x1f,%ebp
  8022ae:	0f 84 ac 00 00 00    	je     802360 <__umoddi3+0x108>
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8022b4:	bf 20 00 00 00       	mov    $0x20,%edi
  8022b9:	29 ef                	sub    %ebp,%edi
  8022bb:	89 fe                	mov    %edi,%esi
  8022bd:	89 7c 24 0c          	mov    %edi,0xc(%esp)

	      d1 = (d1 << bm) | (d0 >> b);
  8022c1:	89 e9                	mov    %ebp,%ecx
  8022c3:	d3 e0                	shl    %cl,%eax
  8022c5:	89 d7                	mov    %edx,%edi
  8022c7:	89 f1                	mov    %esi,%ecx
  8022c9:	d3 ef                	shr    %cl,%edi
  8022cb:	09 c7                	or     %eax,%edi
	      d0 = d0 << bm;
  8022cd:	89 e9                	mov    %ebp,%ecx
  8022cf:	d3 e2                	shl    %cl,%edx
  8022d1:	89 14 24             	mov    %edx,(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8022d4:	89 d8                	mov    %ebx,%eax
  8022d6:	d3 e0                	shl    %cl,%eax
  8022d8:	89 c2                	mov    %eax,%edx
	      n0 = n0 << bm;
  8022da:	8b 44 24 08          	mov    0x8(%esp),%eax
  8022de:	d3 e0                	shl    %cl,%eax
  8022e0:	89 44 24 04          	mov    %eax,0x4(%esp)

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8022e4:	8b 44 24 08          	mov    0x8(%esp),%eax
  8022e8:	89 f1                	mov    %esi,%ecx
  8022ea:	d3 e8                	shr    %cl,%eax
  8022ec:	09 d0                	or     %edx,%eax
  8022ee:	d3 eb                	shr    %cl,%ebx
  8022f0:	89 da                	mov    %ebx,%edx
  8022f2:	f7 f7                	div    %edi
  8022f4:	89 d3                	mov    %edx,%ebx
	      umul_ppmm (m1, m0, q0, d0);
  8022f6:	f7 24 24             	mull   (%esp)
  8022f9:	89 c6                	mov    %eax,%esi
  8022fb:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8022fd:	39 d3                	cmp    %edx,%ebx
  8022ff:	0f 82 87 00 00 00    	jb     80238c <__umoddi3+0x134>
  802305:	0f 84 91 00 00 00    	je     80239c <__umoddi3+0x144>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  80230b:	8b 54 24 04          	mov    0x4(%esp),%edx
  80230f:	29 f2                	sub    %esi,%edx
  802311:	19 cb                	sbb    %ecx,%ebx
		  rr.s.low = (n1 << b) | (n0 >> bm);
  802313:	89 d8                	mov    %ebx,%eax
  802315:	8a 4c 24 0c          	mov    0xc(%esp),%cl
  802319:	d3 e0                	shl    %cl,%eax
  80231b:	89 e9                	mov    %ebp,%ecx
  80231d:	d3 ea                	shr    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  80231f:	09 d0                	or     %edx,%eax
  802321:	89 e9                	mov    %ebp,%ecx
  802323:	d3 eb                	shr    %cl,%ebx
  802325:	89 da                	mov    %ebx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802327:	83 c4 1c             	add    $0x1c,%esp
  80232a:	5b                   	pop    %ebx
  80232b:	5e                   	pop    %esi
  80232c:	5f                   	pop    %edi
  80232d:	5d                   	pop    %ebp
  80232e:	c3                   	ret    
  80232f:	90                   	nop
  802330:	89 fd                	mov    %edi,%ebp
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802332:	85 ff                	test   %edi,%edi
  802334:	75 0b                	jne    802341 <__umoddi3+0xe9>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802336:	b8 01 00 00 00       	mov    $0x1,%eax
  80233b:	31 d2                	xor    %edx,%edx
  80233d:	f7 f7                	div    %edi
  80233f:	89 c5                	mov    %eax,%ebp

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802341:	89 f0                	mov    %esi,%eax
  802343:	31 d2                	xor    %edx,%edx
  802345:	f7 f5                	div    %ebp
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802347:	89 c8                	mov    %ecx,%eax
  802349:	f7 f5                	div    %ebp
  80234b:	89 d0                	mov    %edx,%eax
  80234d:	e9 44 ff ff ff       	jmp    802296 <__umoddi3+0x3e>
  802352:	66 90                	xchg   %ax,%ax
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  802354:	89 c8                	mov    %ecx,%eax
  802356:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802358:	83 c4 1c             	add    $0x1c,%esp
  80235b:	5b                   	pop    %ebx
  80235c:	5e                   	pop    %esi
  80235d:	5f                   	pop    %edi
  80235e:	5d                   	pop    %ebp
  80235f:	c3                   	ret    

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802360:	3b 04 24             	cmp    (%esp),%eax
  802363:	72 06                	jb     80236b <__umoddi3+0x113>
  802365:	3b 7c 24 04          	cmp    0x4(%esp),%edi
  802369:	77 0f                	ja     80237a <__umoddi3+0x122>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  80236b:	89 f2                	mov    %esi,%edx
  80236d:	29 f9                	sub    %edi,%ecx
  80236f:	1b 54 24 0c          	sbb    0xc(%esp),%edx
  802373:	89 14 24             	mov    %edx,(%esp)
  802376:	89 4c 24 04          	mov    %ecx,0x4(%esp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  80237a:	8b 44 24 04          	mov    0x4(%esp),%eax
  80237e:	8b 14 24             	mov    (%esp),%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802381:	83 c4 1c             	add    $0x1c,%esp
  802384:	5b                   	pop    %ebx
  802385:	5e                   	pop    %esi
  802386:	5f                   	pop    %edi
  802387:	5d                   	pop    %ebp
  802388:	c3                   	ret    
  802389:	8d 76 00             	lea    0x0(%esi),%esi
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  80238c:	2b 04 24             	sub    (%esp),%eax
  80238f:	19 fa                	sbb    %edi,%edx
  802391:	89 d1                	mov    %edx,%ecx
  802393:	89 c6                	mov    %eax,%esi
  802395:	e9 71 ff ff ff       	jmp    80230b <__umoddi3+0xb3>
  80239a:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80239c:	39 44 24 04          	cmp    %eax,0x4(%esp)
  8023a0:	72 ea                	jb     80238c <__umoddi3+0x134>
  8023a2:	89 d9                	mov    %ebx,%ecx
  8023a4:	e9 62 ff ff ff       	jmp    80230b <__umoddi3+0xb3>
