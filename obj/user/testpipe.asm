
obj/user/testpipe.debug:     file format elf32-i386


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
  80002c:	e8 81 02 00 00       	call   8002b2 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

char *msg = "Now is the time for all good men to come to the aid of their party.";

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	83 ec 7c             	sub    $0x7c,%esp
	char buf[100];
	int i, pid, p[2];

	binaryname = "pipereadeof";
  80003b:	c7 05 04 30 80 00 a0 	movl   $0x8024a0,0x803004
  800042:	24 80 00 

	if ((i = pipe(p)) < 0)
  800045:	8d 45 8c             	lea    -0x74(%ebp),%eax
  800048:	50                   	push   %eax
  800049:	e8 50 1c 00 00       	call   801c9e <pipe>
  80004e:	89 c6                	mov    %eax,%esi
  800050:	83 c4 10             	add    $0x10,%esp
  800053:	85 c0                	test   %eax,%eax
  800055:	79 12                	jns    800069 <umain+0x36>
		panic("pipe: %e", i);
  800057:	50                   	push   %eax
  800058:	68 ac 24 80 00       	push   $0x8024ac
  80005d:	6a 0e                	push   $0xe
  80005f:	68 b5 24 80 00       	push   $0x8024b5
  800064:	e8 b2 02 00 00       	call   80031b <_panic>

	if ((pid = fork()) < 0)
  800069:	e8 ba 10 00 00       	call   801128 <fork>
  80006e:	89 c3                	mov    %eax,%ebx
  800070:	85 c0                	test   %eax,%eax
  800072:	79 12                	jns    800086 <umain+0x53>
		panic("fork: %e", i);
  800074:	56                   	push   %esi
  800075:	68 c5 24 80 00       	push   $0x8024c5
  80007a:	6a 11                	push   $0x11
  80007c:	68 b5 24 80 00       	push   $0x8024b5
  800081:	e8 95 02 00 00       	call   80031b <_panic>

	if (pid == 0) {
  800086:	85 c0                	test   %eax,%eax
  800088:	0f 85 b8 00 00 00    	jne    800146 <umain+0x113>
		cprintf("[%08x] pipereadeof close %d\n", thisenv->env_id, p[1]);
  80008e:	a1 04 40 80 00       	mov    0x804004,%eax
  800093:	8b 40 48             	mov    0x48(%eax),%eax
  800096:	83 ec 04             	sub    $0x4,%esp
  800099:	ff 75 90             	pushl  -0x70(%ebp)
  80009c:	50                   	push   %eax
  80009d:	68 ce 24 80 00       	push   $0x8024ce
  8000a2:	e8 4c 03 00 00       	call   8003f3 <cprintf>
		close(p[1]);
  8000a7:	83 c4 04             	add    $0x4,%esp
  8000aa:	ff 75 90             	pushl  -0x70(%ebp)
  8000ad:	e8 46 14 00 00       	call   8014f8 <close>
		cprintf("[%08x] pipereadeof readn %d\n", thisenv->env_id, p[0]);
  8000b2:	a1 04 40 80 00       	mov    0x804004,%eax
  8000b7:	8b 40 48             	mov    0x48(%eax),%eax
  8000ba:	83 c4 0c             	add    $0xc,%esp
  8000bd:	ff 75 8c             	pushl  -0x74(%ebp)
  8000c0:	50                   	push   %eax
  8000c1:	68 eb 24 80 00       	push   $0x8024eb
  8000c6:	e8 28 03 00 00       	call   8003f3 <cprintf>
		i = readn(p[0], buf, sizeof buf-1);
  8000cb:	83 c4 0c             	add    $0xc,%esp
  8000ce:	6a 63                	push   $0x63
  8000d0:	8d 45 94             	lea    -0x6c(%ebp),%eax
  8000d3:	50                   	push   %eax
  8000d4:	ff 75 8c             	pushl  -0x74(%ebp)
  8000d7:	e8 db 15 00 00       	call   8016b7 <readn>
  8000dc:	89 c6                	mov    %eax,%esi
		if (i < 0)
  8000de:	83 c4 10             	add    $0x10,%esp
  8000e1:	85 c0                	test   %eax,%eax
  8000e3:	79 12                	jns    8000f7 <umain+0xc4>
			panic("read: %e", i);
  8000e5:	50                   	push   %eax
  8000e6:	68 08 25 80 00       	push   $0x802508
  8000eb:	6a 19                	push   $0x19
  8000ed:	68 b5 24 80 00       	push   $0x8024b5
  8000f2:	e8 24 02 00 00       	call   80031b <_panic>
		buf[i] = 0;
  8000f7:	c6 44 05 94 00       	movb   $0x0,-0x6c(%ebp,%eax,1)
		if (strcmp(buf, msg) == 0)
  8000fc:	83 ec 08             	sub    $0x8,%esp
  8000ff:	ff 35 00 30 80 00    	pushl  0x803000
  800105:	8d 45 94             	lea    -0x6c(%ebp),%eax
  800108:	50                   	push   %eax
  800109:	e8 7a 09 00 00       	call   800a88 <strcmp>
  80010e:	83 c4 10             	add    $0x10,%esp
  800111:	85 c0                	test   %eax,%eax
  800113:	75 12                	jne    800127 <umain+0xf4>
			cprintf("\npipe read closed properly\n");
  800115:	83 ec 0c             	sub    $0xc,%esp
  800118:	68 11 25 80 00       	push   $0x802511
  80011d:	e8 d1 02 00 00       	call   8003f3 <cprintf>
  800122:	83 c4 10             	add    $0x10,%esp
  800125:	eb 15                	jmp    80013c <umain+0x109>
		else
			cprintf("\ngot %d bytes: %s\n", i, buf);
  800127:	83 ec 04             	sub    $0x4,%esp
  80012a:	8d 45 94             	lea    -0x6c(%ebp),%eax
  80012d:	50                   	push   %eax
  80012e:	56                   	push   %esi
  80012f:	68 2d 25 80 00       	push   $0x80252d
  800134:	e8 ba 02 00 00       	call   8003f3 <cprintf>
  800139:	83 c4 10             	add    $0x10,%esp
		exit();
  80013c:	e8 c0 01 00 00       	call   800301 <exit>
  800141:	e9 94 00 00 00       	jmp    8001da <umain+0x1a7>
	} else {
		cprintf("[%08x] pipereadeof close %d\n", thisenv->env_id, p[0]);
  800146:	a1 04 40 80 00       	mov    0x804004,%eax
  80014b:	8b 40 48             	mov    0x48(%eax),%eax
  80014e:	83 ec 04             	sub    $0x4,%esp
  800151:	ff 75 8c             	pushl  -0x74(%ebp)
  800154:	50                   	push   %eax
  800155:	68 ce 24 80 00       	push   $0x8024ce
  80015a:	e8 94 02 00 00       	call   8003f3 <cprintf>
		close(p[0]);
  80015f:	83 c4 04             	add    $0x4,%esp
  800162:	ff 75 8c             	pushl  -0x74(%ebp)
  800165:	e8 8e 13 00 00       	call   8014f8 <close>
		cprintf("[%08x] pipereadeof write %d\n", thisenv->env_id, p[1]);
  80016a:	a1 04 40 80 00       	mov    0x804004,%eax
  80016f:	8b 40 48             	mov    0x48(%eax),%eax
  800172:	83 c4 0c             	add    $0xc,%esp
  800175:	ff 75 90             	pushl  -0x70(%ebp)
  800178:	50                   	push   %eax
  800179:	68 40 25 80 00       	push   $0x802540
  80017e:	e8 70 02 00 00       	call   8003f3 <cprintf>
		if ((i = write(p[1], msg, strlen(msg))) != strlen(msg))
  800183:	83 c4 04             	add    $0x4,%esp
  800186:	ff 35 00 30 80 00    	pushl  0x803000
  80018c:	e8 f0 07 00 00       	call   800981 <strlen>
  800191:	83 c4 0c             	add    $0xc,%esp
  800194:	50                   	push   %eax
  800195:	ff 35 00 30 80 00    	pushl  0x803000
  80019b:	ff 75 90             	pushl  -0x70(%ebp)
  80019e:	e8 69 15 00 00       	call   80170c <write>
  8001a3:	89 c6                	mov    %eax,%esi
  8001a5:	83 c4 04             	add    $0x4,%esp
  8001a8:	ff 35 00 30 80 00    	pushl  0x803000
  8001ae:	e8 ce 07 00 00       	call   800981 <strlen>
  8001b3:	83 c4 10             	add    $0x10,%esp
  8001b6:	39 c6                	cmp    %eax,%esi
  8001b8:	74 12                	je     8001cc <umain+0x199>
			panic("write: %e", i);
  8001ba:	56                   	push   %esi
  8001bb:	68 5d 25 80 00       	push   $0x80255d
  8001c0:	6a 25                	push   $0x25
  8001c2:	68 b5 24 80 00       	push   $0x8024b5
  8001c7:	e8 4f 01 00 00       	call   80031b <_panic>
		close(p[1]);
  8001cc:	83 ec 0c             	sub    $0xc,%esp
  8001cf:	ff 75 90             	pushl  -0x70(%ebp)
  8001d2:	e8 21 13 00 00       	call   8014f8 <close>
  8001d7:	83 c4 10             	add    $0x10,%esp
	}
	wait(pid);
  8001da:	83 ec 0c             	sub    $0xc,%esp
  8001dd:	53                   	push   %ebx
  8001de:	e8 3b 1c 00 00       	call   801e1e <wait>

	binaryname = "pipewriteeof";
  8001e3:	c7 05 04 30 80 00 67 	movl   $0x802567,0x803004
  8001ea:	25 80 00 
	if ((i = pipe(p)) < 0)
  8001ed:	8d 45 8c             	lea    -0x74(%ebp),%eax
  8001f0:	89 04 24             	mov    %eax,(%esp)
  8001f3:	e8 a6 1a 00 00       	call   801c9e <pipe>
  8001f8:	89 c6                	mov    %eax,%esi
  8001fa:	83 c4 10             	add    $0x10,%esp
  8001fd:	85 c0                	test   %eax,%eax
  8001ff:	79 12                	jns    800213 <umain+0x1e0>
		panic("pipe: %e", i);
  800201:	50                   	push   %eax
  800202:	68 ac 24 80 00       	push   $0x8024ac
  800207:	6a 2c                	push   $0x2c
  800209:	68 b5 24 80 00       	push   $0x8024b5
  80020e:	e8 08 01 00 00       	call   80031b <_panic>

	if ((pid = fork()) < 0)
  800213:	e8 10 0f 00 00       	call   801128 <fork>
  800218:	89 c3                	mov    %eax,%ebx
  80021a:	85 c0                	test   %eax,%eax
  80021c:	79 12                	jns    800230 <umain+0x1fd>
		panic("fork: %e", i);
  80021e:	56                   	push   %esi
  80021f:	68 c5 24 80 00       	push   $0x8024c5
  800224:	6a 2f                	push   $0x2f
  800226:	68 b5 24 80 00       	push   $0x8024b5
  80022b:	e8 eb 00 00 00       	call   80031b <_panic>

	if (pid == 0) {
  800230:	85 c0                	test   %eax,%eax
  800232:	75 4a                	jne    80027e <umain+0x24b>
		close(p[0]);
  800234:	83 ec 0c             	sub    $0xc,%esp
  800237:	ff 75 8c             	pushl  -0x74(%ebp)
  80023a:	e8 b9 12 00 00       	call   8014f8 <close>
  80023f:	83 c4 10             	add    $0x10,%esp
		while (1) {
			cprintf(".");
  800242:	83 ec 0c             	sub    $0xc,%esp
  800245:	68 74 25 80 00       	push   $0x802574
  80024a:	e8 a4 01 00 00       	call   8003f3 <cprintf>
			if (write(p[1], "x", 1) != 1)
  80024f:	83 c4 0c             	add    $0xc,%esp
  800252:	6a 01                	push   $0x1
  800254:	68 76 25 80 00       	push   $0x802576
  800259:	ff 75 90             	pushl  -0x70(%ebp)
  80025c:	e8 ab 14 00 00       	call   80170c <write>
  800261:	83 c4 10             	add    $0x10,%esp
  800264:	83 f8 01             	cmp    $0x1,%eax
  800267:	74 d9                	je     800242 <umain+0x20f>
				break;
		}
		cprintf("\npipe write closed properly\n");
  800269:	83 ec 0c             	sub    $0xc,%esp
  80026c:	68 78 25 80 00       	push   $0x802578
  800271:	e8 7d 01 00 00       	call   8003f3 <cprintf>
		exit();
  800276:	e8 86 00 00 00       	call   800301 <exit>
  80027b:	83 c4 10             	add    $0x10,%esp
	}
	close(p[0]);
  80027e:	83 ec 0c             	sub    $0xc,%esp
  800281:	ff 75 8c             	pushl  -0x74(%ebp)
  800284:	e8 6f 12 00 00       	call   8014f8 <close>
	close(p[1]);
  800289:	83 c4 04             	add    $0x4,%esp
  80028c:	ff 75 90             	pushl  -0x70(%ebp)
  80028f:	e8 64 12 00 00       	call   8014f8 <close>
	wait(pid);
  800294:	89 1c 24             	mov    %ebx,(%esp)
  800297:	e8 82 1b 00 00       	call   801e1e <wait>

	cprintf("pipe tests passed\n");
  80029c:	c7 04 24 95 25 80 00 	movl   $0x802595,(%esp)
  8002a3:	e8 4b 01 00 00       	call   8003f3 <cprintf>
}
  8002a8:	83 c4 10             	add    $0x10,%esp
  8002ab:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8002ae:	5b                   	pop    %ebx
  8002af:	5e                   	pop    %esi
  8002b0:	5d                   	pop    %ebp
  8002b1:	c3                   	ret    

008002b2 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8002b2:	55                   	push   %ebp
  8002b3:	89 e5                	mov    %esp,%ebp
  8002b5:	56                   	push   %esi
  8002b6:	53                   	push   %ebx
  8002b7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8002ba:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8002bd:	e8 48 0b 00 00       	call   800e0a <sys_getenvid>
  8002c2:	25 ff 03 00 00       	and    $0x3ff,%eax
  8002c7:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8002ce:	c1 e0 07             	shl    $0x7,%eax
  8002d1:	29 d0                	sub    %edx,%eax
  8002d3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8002d8:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8002dd:	85 db                	test   %ebx,%ebx
  8002df:	7e 07                	jle    8002e8 <libmain+0x36>
		binaryname = argv[0];
  8002e1:	8b 06                	mov    (%esi),%eax
  8002e3:	a3 04 30 80 00       	mov    %eax,0x803004

	// call user main routine
	umain(argc, argv);
  8002e8:	83 ec 08             	sub    $0x8,%esp
  8002eb:	56                   	push   %esi
  8002ec:	53                   	push   %ebx
  8002ed:	e8 41 fd ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8002f2:	e8 0a 00 00 00       	call   800301 <exit>
}
  8002f7:	83 c4 10             	add    $0x10,%esp
  8002fa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8002fd:	5b                   	pop    %ebx
  8002fe:	5e                   	pop    %esi
  8002ff:	5d                   	pop    %ebp
  800300:	c3                   	ret    

00800301 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800301:	55                   	push   %ebp
  800302:	89 e5                	mov    %esp,%ebp
  800304:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800307:	e8 17 12 00 00       	call   801523 <close_all>
	sys_env_destroy(0);
  80030c:	83 ec 0c             	sub    $0xc,%esp
  80030f:	6a 00                	push   $0x0
  800311:	e8 b3 0a 00 00       	call   800dc9 <sys_env_destroy>
}
  800316:	83 c4 10             	add    $0x10,%esp
  800319:	c9                   	leave  
  80031a:	c3                   	ret    

0080031b <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80031b:	55                   	push   %ebp
  80031c:	89 e5                	mov    %esp,%ebp
  80031e:	56                   	push   %esi
  80031f:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800320:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800323:	8b 35 04 30 80 00    	mov    0x803004,%esi
  800329:	e8 dc 0a 00 00       	call   800e0a <sys_getenvid>
  80032e:	83 ec 0c             	sub    $0xc,%esp
  800331:	ff 75 0c             	pushl  0xc(%ebp)
  800334:	ff 75 08             	pushl  0x8(%ebp)
  800337:	56                   	push   %esi
  800338:	50                   	push   %eax
  800339:	68 f8 25 80 00       	push   $0x8025f8
  80033e:	e8 b0 00 00 00       	call   8003f3 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800343:	83 c4 18             	add    $0x18,%esp
  800346:	53                   	push   %ebx
  800347:	ff 75 10             	pushl  0x10(%ebp)
  80034a:	e8 53 00 00 00       	call   8003a2 <vcprintf>
	cprintf("\n");
  80034f:	c7 04 24 8b 29 80 00 	movl   $0x80298b,(%esp)
  800356:	e8 98 00 00 00       	call   8003f3 <cprintf>
  80035b:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80035e:	cc                   	int3   
  80035f:	eb fd                	jmp    80035e <_panic+0x43>

00800361 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800361:	55                   	push   %ebp
  800362:	89 e5                	mov    %esp,%ebp
  800364:	53                   	push   %ebx
  800365:	83 ec 04             	sub    $0x4,%esp
  800368:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80036b:	8b 13                	mov    (%ebx),%edx
  80036d:	8d 42 01             	lea    0x1(%edx),%eax
  800370:	89 03                	mov    %eax,(%ebx)
  800372:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800375:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800379:	3d ff 00 00 00       	cmp    $0xff,%eax
  80037e:	75 1a                	jne    80039a <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800380:	83 ec 08             	sub    $0x8,%esp
  800383:	68 ff 00 00 00       	push   $0xff
  800388:	8d 43 08             	lea    0x8(%ebx),%eax
  80038b:	50                   	push   %eax
  80038c:	e8 fb 09 00 00       	call   800d8c <sys_cputs>
		b->idx = 0;
  800391:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800397:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80039a:	ff 43 04             	incl   0x4(%ebx)
}
  80039d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8003a0:	c9                   	leave  
  8003a1:	c3                   	ret    

008003a2 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003a2:	55                   	push   %ebp
  8003a3:	89 e5                	mov    %esp,%ebp
  8003a5:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003ab:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003b2:	00 00 00 
	b.cnt = 0;
  8003b5:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003bc:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003bf:	ff 75 0c             	pushl  0xc(%ebp)
  8003c2:	ff 75 08             	pushl  0x8(%ebp)
  8003c5:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003cb:	50                   	push   %eax
  8003cc:	68 61 03 80 00       	push   $0x800361
  8003d1:	e8 54 01 00 00       	call   80052a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003d6:	83 c4 08             	add    $0x8,%esp
  8003d9:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8003df:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003e5:	50                   	push   %eax
  8003e6:	e8 a1 09 00 00       	call   800d8c <sys_cputs>

	return b.cnt;
}
  8003eb:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003f1:	c9                   	leave  
  8003f2:	c3                   	ret    

008003f3 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003f3:	55                   	push   %ebp
  8003f4:	89 e5                	mov    %esp,%ebp
  8003f6:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003f9:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003fc:	50                   	push   %eax
  8003fd:	ff 75 08             	pushl  0x8(%ebp)
  800400:	e8 9d ff ff ff       	call   8003a2 <vcprintf>
	va_end(ap);

	return cnt;
}
  800405:	c9                   	leave  
  800406:	c3                   	ret    

00800407 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800407:	55                   	push   %ebp
  800408:	89 e5                	mov    %esp,%ebp
  80040a:	57                   	push   %edi
  80040b:	56                   	push   %esi
  80040c:	53                   	push   %ebx
  80040d:	83 ec 1c             	sub    $0x1c,%esp
  800410:	89 c6                	mov    %eax,%esi
  800412:	89 d7                	mov    %edx,%edi
  800414:	8b 45 08             	mov    0x8(%ebp),%eax
  800417:	8b 55 0c             	mov    0xc(%ebp),%edx
  80041a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80041d:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800420:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800423:	bb 00 00 00 00       	mov    $0x0,%ebx
  800428:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80042b:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80042e:	39 d3                	cmp    %edx,%ebx
  800430:	72 11                	jb     800443 <printnum+0x3c>
  800432:	39 45 10             	cmp    %eax,0x10(%ebp)
  800435:	76 0c                	jbe    800443 <printnum+0x3c>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800437:	8b 45 14             	mov    0x14(%ebp),%eax
  80043a:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80043d:	85 db                	test   %ebx,%ebx
  80043f:	7f 37                	jg     800478 <printnum+0x71>
  800441:	eb 44                	jmp    800487 <printnum+0x80>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800443:	83 ec 0c             	sub    $0xc,%esp
  800446:	ff 75 18             	pushl  0x18(%ebp)
  800449:	8b 45 14             	mov    0x14(%ebp),%eax
  80044c:	48                   	dec    %eax
  80044d:	50                   	push   %eax
  80044e:	ff 75 10             	pushl  0x10(%ebp)
  800451:	83 ec 08             	sub    $0x8,%esp
  800454:	ff 75 e4             	pushl  -0x1c(%ebp)
  800457:	ff 75 e0             	pushl  -0x20(%ebp)
  80045a:	ff 75 dc             	pushl  -0x24(%ebp)
  80045d:	ff 75 d8             	pushl  -0x28(%ebp)
  800460:	e8 d3 1d 00 00       	call   802238 <__udivdi3>
  800465:	83 c4 18             	add    $0x18,%esp
  800468:	52                   	push   %edx
  800469:	50                   	push   %eax
  80046a:	89 fa                	mov    %edi,%edx
  80046c:	89 f0                	mov    %esi,%eax
  80046e:	e8 94 ff ff ff       	call   800407 <printnum>
  800473:	83 c4 20             	add    $0x20,%esp
  800476:	eb 0f                	jmp    800487 <printnum+0x80>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800478:	83 ec 08             	sub    $0x8,%esp
  80047b:	57                   	push   %edi
  80047c:	ff 75 18             	pushl  0x18(%ebp)
  80047f:	ff d6                	call   *%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800481:	83 c4 10             	add    $0x10,%esp
  800484:	4b                   	dec    %ebx
  800485:	75 f1                	jne    800478 <printnum+0x71>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800487:	83 ec 08             	sub    $0x8,%esp
  80048a:	57                   	push   %edi
  80048b:	83 ec 04             	sub    $0x4,%esp
  80048e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800491:	ff 75 e0             	pushl  -0x20(%ebp)
  800494:	ff 75 dc             	pushl  -0x24(%ebp)
  800497:	ff 75 d8             	pushl  -0x28(%ebp)
  80049a:	e8 a9 1e 00 00       	call   802348 <__umoddi3>
  80049f:	83 c4 14             	add    $0x14,%esp
  8004a2:	0f be 80 1b 26 80 00 	movsbl 0x80261b(%eax),%eax
  8004a9:	50                   	push   %eax
  8004aa:	ff d6                	call   *%esi
}
  8004ac:	83 c4 10             	add    $0x10,%esp
  8004af:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004b2:	5b                   	pop    %ebx
  8004b3:	5e                   	pop    %esi
  8004b4:	5f                   	pop    %edi
  8004b5:	5d                   	pop    %ebp
  8004b6:	c3                   	ret    

008004b7 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8004b7:	55                   	push   %ebp
  8004b8:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8004ba:	83 fa 01             	cmp    $0x1,%edx
  8004bd:	7e 0e                	jle    8004cd <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8004bf:	8b 10                	mov    (%eax),%edx
  8004c1:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004c4:	89 08                	mov    %ecx,(%eax)
  8004c6:	8b 02                	mov    (%edx),%eax
  8004c8:	8b 52 04             	mov    0x4(%edx),%edx
  8004cb:	eb 22                	jmp    8004ef <getuint+0x38>
	else if (lflag)
  8004cd:	85 d2                	test   %edx,%edx
  8004cf:	74 10                	je     8004e1 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8004d1:	8b 10                	mov    (%eax),%edx
  8004d3:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004d6:	89 08                	mov    %ecx,(%eax)
  8004d8:	8b 02                	mov    (%edx),%eax
  8004da:	ba 00 00 00 00       	mov    $0x0,%edx
  8004df:	eb 0e                	jmp    8004ef <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8004e1:	8b 10                	mov    (%eax),%edx
  8004e3:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004e6:	89 08                	mov    %ecx,(%eax)
  8004e8:	8b 02                	mov    (%edx),%eax
  8004ea:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004ef:	5d                   	pop    %ebp
  8004f0:	c3                   	ret    

008004f1 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004f1:	55                   	push   %ebp
  8004f2:	89 e5                	mov    %esp,%ebp
  8004f4:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004f7:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8004fa:	8b 10                	mov    (%eax),%edx
  8004fc:	3b 50 04             	cmp    0x4(%eax),%edx
  8004ff:	73 0a                	jae    80050b <sprintputch+0x1a>
		*b->buf++ = ch;
  800501:	8d 4a 01             	lea    0x1(%edx),%ecx
  800504:	89 08                	mov    %ecx,(%eax)
  800506:	8b 45 08             	mov    0x8(%ebp),%eax
  800509:	88 02                	mov    %al,(%edx)
}
  80050b:	5d                   	pop    %ebp
  80050c:	c3                   	ret    

0080050d <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80050d:	55                   	push   %ebp
  80050e:	89 e5                	mov    %esp,%ebp
  800510:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800513:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800516:	50                   	push   %eax
  800517:	ff 75 10             	pushl  0x10(%ebp)
  80051a:	ff 75 0c             	pushl  0xc(%ebp)
  80051d:	ff 75 08             	pushl  0x8(%ebp)
  800520:	e8 05 00 00 00       	call   80052a <vprintfmt>
	va_end(ap);
}
  800525:	83 c4 10             	add    $0x10,%esp
  800528:	c9                   	leave  
  800529:	c3                   	ret    

0080052a <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80052a:	55                   	push   %ebp
  80052b:	89 e5                	mov    %esp,%ebp
  80052d:	57                   	push   %edi
  80052e:	56                   	push   %esi
  80052f:	53                   	push   %ebx
  800530:	83 ec 2c             	sub    $0x2c,%esp
  800533:	8b 7d 08             	mov    0x8(%ebp),%edi
  800536:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800539:	eb 03                	jmp    80053e <vprintfmt+0x14>
			break;

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
			for (fmt--; fmt[-1] != '%'; fmt--)
  80053b:	89 75 10             	mov    %esi,0x10(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {    //遍历输入的第一个参数，即输出信息的格式，先把格式字符串中'%'之前的字符一个个输出，因为它们前面没有'%'，所以它们就是要直接显示在屏幕上的
  80053e:	8b 45 10             	mov    0x10(%ebp),%eax
  800541:	8d 70 01             	lea    0x1(%eax),%esi
  800544:	0f b6 00             	movzbl (%eax),%eax
  800547:	83 f8 25             	cmp    $0x25,%eax
  80054a:	74 25                	je     800571 <vprintfmt+0x47>
			if (ch == '\0')									//当然中间如果遇到'\0'，代表这个字符串的访问结束
  80054c:	85 c0                	test   %eax,%eax
  80054e:	75 0d                	jne    80055d <vprintfmt+0x33>
  800550:	e9 b5 03 00 00       	jmp    80090a <vprintfmt+0x3e0>
  800555:	85 c0                	test   %eax,%eax
  800557:	0f 84 ad 03 00 00    	je     80090a <vprintfmt+0x3e0>
				return;
			putch(ch, putdat);								//调用putch函数，把一个字符ch输出到putdat指针所指向的地址中所存放的值对应的地址处
  80055d:	83 ec 08             	sub    $0x8,%esp
  800560:	53                   	push   %ebx
  800561:	50                   	push   %eax
  800562:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {    //遍历输入的第一个参数，即输出信息的格式，先把格式字符串中'%'之前的字符一个个输出，因为它们前面没有'%'，所以它们就是要直接显示在屏幕上的
  800564:	46                   	inc    %esi
  800565:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  800569:	83 c4 10             	add    $0x10,%esp
  80056c:	83 f8 25             	cmp    $0x25,%eax
  80056f:	75 e4                	jne    800555 <vprintfmt+0x2b>
			if (width < 0)									//代表有小数点，但是小数点前面并没有数字，比如'%.6f'这种情况，此时代表整数部分全部显示
				width = 0;			
			goto reswitch;

		case '#':
			altflag = 1;
  800571:	c6 45 e3 20          	movb   $0x20,-0x1d(%ebp)
  800575:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80057c:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800583:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80058a:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800591:	eb 07                	jmp    80059a <vprintfmt+0x70>
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  800593:	8b 75 10             	mov    0x10(%ebp),%esi

		// flag to pad on the right
		case '-':											//%后面的'-'代表要进行左对齐输出，右边填空格，如果省略代表右对齐
			padc = '-';										//如果有这个字符代表左对齐，则把对齐方式标志位变为'-'
  800596:	c6 45 e3 2d          	movb   $0x2d,-0x1d(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  80059a:	8d 46 01             	lea    0x1(%esi),%eax
  80059d:	89 45 10             	mov    %eax,0x10(%ebp)
  8005a0:	0f b6 16             	movzbl (%esi),%edx
  8005a3:	8a 06                	mov    (%esi),%al
  8005a5:	83 e8 23             	sub    $0x23,%eax
  8005a8:	3c 55                	cmp    $0x55,%al
  8005aa:	0f 87 03 03 00 00    	ja     8008b3 <vprintfmt+0x389>
  8005b0:	0f b6 c0             	movzbl %al,%eax
  8005b3:	ff 24 85 60 27 80 00 	jmp    *0x802760(,%eax,4)
  8005ba:	8b 75 10             	mov    0x10(%ebp),%esi
			padc = '-';										//如果有这个字符代表左对齐，则把对齐方式标志位变为'-'
			goto reswitch;									//处理下一个字符

		// flag to pad with 0's instead of spaces
		case '0':											//0--有0表示进行对齐输出时填0,如省略表示填入空格，并且如果为0，则一定是右对齐
			padc = '0';										//对其方式标志位变为0
  8005bd:	c6 45 e3 30          	movb   $0x30,-0x1d(%ebp)
  8005c1:	eb d7                	jmp    80059a <vprintfmt+0x70>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {					//把遇到的位数字符串转换为真实的位数，比如输入的'%40'，代表有效位数为40位，下面的循环就是把precesion的值设置为40
				precision = precision * 10 + ch - '0';
  8005c3:	8d 42 d0             	lea    -0x30(%edx),%eax
  8005c6:	89 c1                	mov    %eax,%ecx
  8005c8:	89 45 d0             	mov    %eax,-0x30(%ebp)
				ch = *fmt;
  8005cb:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  8005cf:	8d 50 d0             	lea    -0x30(%eax),%edx
  8005d2:	83 fa 09             	cmp    $0x9,%edx
  8005d5:	77 51                	ja     800628 <vprintfmt+0xfe>
  8005d7:	8b 75 10             	mov    0x10(%ebp),%esi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {					//把遇到的位数字符串转换为真实的位数，比如输入的'%40'，代表有效位数为40位，下面的循环就是把precesion的值设置为40
  8005da:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  8005db:	8d 14 89             	lea    (%ecx,%ecx,4),%edx
  8005de:	01 d2                	add    %edx,%edx
  8005e0:	8d 4c 10 d0          	lea    -0x30(%eax,%edx,1),%ecx
				ch = *fmt;
  8005e4:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8005e7:	8d 50 d0             	lea    -0x30(%eax),%edx
  8005ea:	83 fa 09             	cmp    $0x9,%edx
  8005ed:	76 eb                	jbe    8005da <vprintfmt+0xb0>
  8005ef:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8005f2:	eb 37                	jmp    80062b <vprintfmt+0x101>
					break;
			}
			goto process_precision;							//跳转到process_precistion子过程

		case '*':											//*--代表有效数字的位数也是由输入参数指定的，比如printf("%*.*f", 10, 2, n)，其中10,2就是用来指定显示的有效数字位数的
			precision = va_arg(ap, int);
  8005f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f7:	8d 50 04             	lea    0x4(%eax),%edx
  8005fa:	89 55 14             	mov    %edx,0x14(%ebp)
  8005fd:	8b 00                	mov    (%eax),%eax
  8005ff:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  800602:	8b 75 10             	mov    0x10(%ebp),%esi
			}
			goto process_precision;							//跳转到process_precistion子过程

		case '*':											//*--代表有效数字的位数也是由输入参数指定的，比如printf("%*.*f", 10, 2, n)，其中10,2就是用来指定显示的有效数字位数的
			precision = va_arg(ap, int);
			goto process_precision;
  800605:	eb 24                	jmp    80062b <vprintfmt+0x101>
  800607:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80060b:	79 07                	jns    800614 <vprintfmt+0xea>
  80060d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  800614:	8b 75 10             	mov    0x10(%ebp),%esi
  800617:	eb 81                	jmp    80059a <vprintfmt+0x70>
  800619:	8b 75 10             	mov    0x10(%ebp),%esi
			if (width < 0)									//代表有小数点，但是小数点前面并没有数字，比如'%.6f'这种情况，此时代表整数部分全部显示
				width = 0;			
			goto reswitch;

		case '#':
			altflag = 1;
  80061c:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800623:	e9 72 ff ff ff       	jmp    80059a <vprintfmt+0x70>
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  800628:	8b 75 10             	mov    0x10(%ebp),%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:									//处理输出精度，把width字段赋值为刚刚计算出来的precision值，所以width应该是整数部分的有效数字位数
			if (width < 0)
  80062b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80062f:	0f 89 65 ff ff ff    	jns    80059a <vprintfmt+0x70>
				width = precision, precision = -1;
  800635:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800638:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80063b:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800642:	e9 53 ff ff ff       	jmp    80059a <vprintfmt+0x70>
			goto reswitch;

		// long flag (doubled for long long)				
		case 'l':											//如果遇到'l'，代表应该是输入long类型，如果有两个'l'代表long long
			lflag++;										//此时把lflag++
  800647:	ff 45 d4             	incl   -0x2c(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  80064a:	8b 75 10             	mov    0x10(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)				
		case 'l':											//如果遇到'l'，代表应该是输入long类型，如果有两个'l'代表long long
			lflag++;										//此时把lflag++
			goto reswitch;
  80064d:	e9 48 ff ff ff       	jmp    80059a <vprintfmt+0x70>

		// character
		case 'c':											//如果是'c'代表显示一个字符
			putch(va_arg(ap, int), putdat);					//调用输出一个字符到内存的函数putch
  800652:	8b 45 14             	mov    0x14(%ebp),%eax
  800655:	8d 50 04             	lea    0x4(%eax),%edx
  800658:	89 55 14             	mov    %edx,0x14(%ebp)
  80065b:	83 ec 08             	sub    $0x8,%esp
  80065e:	53                   	push   %ebx
  80065f:	ff 30                	pushl  (%eax)
  800661:	ff d7                	call   *%edi
			break;
  800663:	83 c4 10             	add    $0x10,%esp
  800666:	e9 d3 fe ff ff       	jmp    80053e <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80066b:	8b 45 14             	mov    0x14(%ebp),%eax
  80066e:	8d 50 04             	lea    0x4(%eax),%edx
  800671:	89 55 14             	mov    %edx,0x14(%ebp)
  800674:	8b 00                	mov    (%eax),%eax
  800676:	85 c0                	test   %eax,%eax
  800678:	79 02                	jns    80067c <vprintfmt+0x152>
  80067a:	f7 d8                	neg    %eax
  80067c:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80067e:	83 f8 0f             	cmp    $0xf,%eax
  800681:	7f 0b                	jg     80068e <vprintfmt+0x164>
  800683:	8b 04 85 c0 28 80 00 	mov    0x8028c0(,%eax,4),%eax
  80068a:	85 c0                	test   %eax,%eax
  80068c:	75 15                	jne    8006a3 <vprintfmt+0x179>
				printfmt(putch, putdat, "error %d", err);
  80068e:	52                   	push   %edx
  80068f:	68 33 26 80 00       	push   $0x802633
  800694:	53                   	push   %ebx
  800695:	57                   	push   %edi
  800696:	e8 72 fe ff ff       	call   80050d <printfmt>
  80069b:	83 c4 10             	add    $0x10,%esp
  80069e:	e9 9b fe ff ff       	jmp    80053e <vprintfmt+0x14>
			else
				printfmt(putch, putdat, "%s", p);
  8006a3:	50                   	push   %eax
  8006a4:	68 ca 2a 80 00       	push   $0x802aca
  8006a9:	53                   	push   %ebx
  8006aa:	57                   	push   %edi
  8006ab:	e8 5d fe ff ff       	call   80050d <printfmt>
  8006b0:	83 c4 10             	add    $0x10,%esp
  8006b3:	e9 86 fe ff ff       	jmp    80053e <vprintfmt+0x14>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8006b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006bb:	8d 50 04             	lea    0x4(%eax),%edx
  8006be:	89 55 14             	mov    %edx,0x14(%ebp)
  8006c1:	8b 00                	mov    (%eax),%eax
  8006c3:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8006c6:	85 c0                	test   %eax,%eax
  8006c8:	75 07                	jne    8006d1 <vprintfmt+0x1a7>
				p = "(null)";
  8006ca:	c7 45 d4 2c 26 80 00 	movl   $0x80262c,-0x2c(%ebp)
			if (width > 0 && padc != '-')
  8006d1:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8006d4:	85 f6                	test   %esi,%esi
  8006d6:	0f 8e fb 01 00 00    	jle    8008d7 <vprintfmt+0x3ad>
  8006dc:	80 7d e3 2d          	cmpb   $0x2d,-0x1d(%ebp)
  8006e0:	0f 84 09 02 00 00    	je     8008ef <vprintfmt+0x3c5>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006e6:	83 ec 08             	sub    $0x8,%esp
  8006e9:	ff 75 d0             	pushl  -0x30(%ebp)
  8006ec:	ff 75 d4             	pushl  -0x2c(%ebp)
  8006ef:	e8 ad 02 00 00       	call   8009a1 <strnlen>
  8006f4:	89 f1                	mov    %esi,%ecx
  8006f6:	29 c1                	sub    %eax,%ecx
  8006f8:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  8006fb:	83 c4 10             	add    $0x10,%esp
  8006fe:	85 c9                	test   %ecx,%ecx
  800700:	0f 8e d1 01 00 00    	jle    8008d7 <vprintfmt+0x3ad>
					putch(padc, putdat);
  800706:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  80070a:	83 ec 08             	sub    $0x8,%esp
  80070d:	53                   	push   %ebx
  80070e:	56                   	push   %esi
  80070f:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800711:	83 c4 10             	add    $0x10,%esp
  800714:	ff 4d e4             	decl   -0x1c(%ebp)
  800717:	75 f1                	jne    80070a <vprintfmt+0x1e0>
  800719:	e9 b9 01 00 00       	jmp    8008d7 <vprintfmt+0x3ad>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80071e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800722:	74 19                	je     80073d <vprintfmt+0x213>
  800724:	0f be c0             	movsbl %al,%eax
  800727:	83 e8 20             	sub    $0x20,%eax
  80072a:	83 f8 5e             	cmp    $0x5e,%eax
  80072d:	76 0e                	jbe    80073d <vprintfmt+0x213>
					putch('?', putdat);
  80072f:	83 ec 08             	sub    $0x8,%esp
  800732:	53                   	push   %ebx
  800733:	6a 3f                	push   $0x3f
  800735:	ff 55 08             	call   *0x8(%ebp)
  800738:	83 c4 10             	add    $0x10,%esp
  80073b:	eb 0b                	jmp    800748 <vprintfmt+0x21e>
				else
					putch(ch, putdat);
  80073d:	83 ec 08             	sub    $0x8,%esp
  800740:	53                   	push   %ebx
  800741:	52                   	push   %edx
  800742:	ff 55 08             	call   *0x8(%ebp)
  800745:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800748:	ff 4d e4             	decl   -0x1c(%ebp)
  80074b:	46                   	inc    %esi
  80074c:	8a 46 ff             	mov    -0x1(%esi),%al
  80074f:	0f be d0             	movsbl %al,%edx
  800752:	85 d2                	test   %edx,%edx
  800754:	75 1c                	jne    800772 <vprintfmt+0x248>
  800756:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800759:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80075d:	7f 1f                	jg     80077e <vprintfmt+0x254>
  80075f:	e9 da fd ff ff       	jmp    80053e <vprintfmt+0x14>
  800764:	89 7d 08             	mov    %edi,0x8(%ebp)
  800767:	8b 7d d0             	mov    -0x30(%ebp),%edi
  80076a:	eb 06                	jmp    800772 <vprintfmt+0x248>
  80076c:	89 7d 08             	mov    %edi,0x8(%ebp)
  80076f:	8b 7d d0             	mov    -0x30(%ebp),%edi
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800772:	85 ff                	test   %edi,%edi
  800774:	78 a8                	js     80071e <vprintfmt+0x1f4>
  800776:	4f                   	dec    %edi
  800777:	79 a5                	jns    80071e <vprintfmt+0x1f4>
  800779:	8b 7d 08             	mov    0x8(%ebp),%edi
  80077c:	eb db                	jmp    800759 <vprintfmt+0x22f>
  80077e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800781:	83 ec 08             	sub    $0x8,%esp
  800784:	53                   	push   %ebx
  800785:	6a 20                	push   $0x20
  800787:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800789:	4e                   	dec    %esi
  80078a:	83 c4 10             	add    $0x10,%esp
  80078d:	85 f6                	test   %esi,%esi
  80078f:	7f f0                	jg     800781 <vprintfmt+0x257>
  800791:	e9 a8 fd ff ff       	jmp    80053e <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800796:	83 7d d4 01          	cmpl   $0x1,-0x2c(%ebp)
  80079a:	7e 16                	jle    8007b2 <vprintfmt+0x288>
		return va_arg(*ap, long long);
  80079c:	8b 45 14             	mov    0x14(%ebp),%eax
  80079f:	8d 50 08             	lea    0x8(%eax),%edx
  8007a2:	89 55 14             	mov    %edx,0x14(%ebp)
  8007a5:	8b 50 04             	mov    0x4(%eax),%edx
  8007a8:	8b 00                	mov    (%eax),%eax
  8007aa:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007ad:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007b0:	eb 34                	jmp    8007e6 <vprintfmt+0x2bc>
	else if (lflag)
  8007b2:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8007b6:	74 18                	je     8007d0 <vprintfmt+0x2a6>
		return va_arg(*ap, long);
  8007b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8007bb:	8d 50 04             	lea    0x4(%eax),%edx
  8007be:	89 55 14             	mov    %edx,0x14(%ebp)
  8007c1:	8b 30                	mov    (%eax),%esi
  8007c3:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8007c6:	89 f0                	mov    %esi,%eax
  8007c8:	c1 f8 1f             	sar    $0x1f,%eax
  8007cb:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8007ce:	eb 16                	jmp    8007e6 <vprintfmt+0x2bc>
	else
		return va_arg(*ap, int);
  8007d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d3:	8d 50 04             	lea    0x4(%eax),%edx
  8007d6:	89 55 14             	mov    %edx,0x14(%ebp)
  8007d9:	8b 30                	mov    (%eax),%esi
  8007db:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8007de:	89 f0                	mov    %esi,%eax
  8007e0:	c1 f8 1f             	sar    $0x1f,%eax
  8007e3:	89 45 dc             	mov    %eax,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8007e6:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8007e9:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
  8007ec:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8007f0:	0f 89 8a 00 00 00    	jns    800880 <vprintfmt+0x356>
				putch('-', putdat);
  8007f6:	83 ec 08             	sub    $0x8,%esp
  8007f9:	53                   	push   %ebx
  8007fa:	6a 2d                	push   $0x2d
  8007fc:	ff d7                	call   *%edi
				num = -(long long) num;
  8007fe:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800801:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800804:	f7 d8                	neg    %eax
  800806:	83 d2 00             	adc    $0x0,%edx
  800809:	f7 da                	neg    %edx
  80080b:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80080e:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800813:	eb 70                	jmp    800885 <vprintfmt+0x35b>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800815:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800818:	8d 45 14             	lea    0x14(%ebp),%eax
  80081b:	e8 97 fc ff ff       	call   8004b7 <getuint>
			base = 10;
  800820:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800825:	eb 5e                	jmp    800885 <vprintfmt+0x35b>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
  800827:	83 ec 08             	sub    $0x8,%esp
  80082a:	53                   	push   %ebx
  80082b:	6a 30                	push   $0x30
  80082d:	ff d7                	call   *%edi
			num = getuint(&ap, lflag);
  80082f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800832:	8d 45 14             	lea    0x14(%ebp),%eax
  800835:	e8 7d fc ff ff       	call   8004b7 <getuint>
			base = 8;
			goto number;
  80083a:	83 c4 10             	add    $0x10,%esp
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  80083d:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800842:	eb 41                	jmp    800885 <vprintfmt+0x35b>
		// pointer
		case 'p':
			putch('0', putdat);
  800844:	83 ec 08             	sub    $0x8,%esp
  800847:	53                   	push   %ebx
  800848:	6a 30                	push   $0x30
  80084a:	ff d7                	call   *%edi
			putch('x', putdat);
  80084c:	83 c4 08             	add    $0x8,%esp
  80084f:	53                   	push   %ebx
  800850:	6a 78                	push   $0x78
  800852:	ff d7                	call   *%edi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800854:	8b 45 14             	mov    0x14(%ebp),%eax
  800857:	8d 50 04             	lea    0x4(%eax),%edx
  80085a:	89 55 14             	mov    %edx,0x14(%ebp)
			goto number;
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80085d:	8b 00                	mov    (%eax),%eax
  80085f:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800864:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800867:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80086c:	eb 17                	jmp    800885 <vprintfmt+0x35b>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80086e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800871:	8d 45 14             	lea    0x14(%ebp),%eax
  800874:	e8 3e fc ff ff       	call   8004b7 <getuint>
			base = 16;
  800879:	b9 10 00 00 00       	mov    $0x10,%ecx
  80087e:	eb 05                	jmp    800885 <vprintfmt+0x35b>
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800880:	b9 0a 00 00 00       	mov    $0xa,%ecx
		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  800885:	83 ec 0c             	sub    $0xc,%esp
  800888:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  80088c:	56                   	push   %esi
  80088d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800890:	51                   	push   %ecx
  800891:	52                   	push   %edx
  800892:	50                   	push   %eax
  800893:	89 da                	mov    %ebx,%edx
  800895:	89 f8                	mov    %edi,%eax
  800897:	e8 6b fb ff ff       	call   800407 <printnum>
			break;
  80089c:	83 c4 20             	add    $0x20,%esp
  80089f:	e9 9a fc ff ff       	jmp    80053e <vprintfmt+0x14>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8008a4:	83 ec 08             	sub    $0x8,%esp
  8008a7:	53                   	push   %ebx
  8008a8:	52                   	push   %edx
  8008a9:	ff d7                	call   *%edi
			break;
  8008ab:	83 c4 10             	add    $0x10,%esp
  8008ae:	e9 8b fc ff ff       	jmp    80053e <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8008b3:	83 ec 08             	sub    $0x8,%esp
  8008b6:	53                   	push   %ebx
  8008b7:	6a 25                	push   $0x25
  8008b9:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008bb:	83 c4 10             	add    $0x10,%esp
  8008be:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8008c2:	0f 84 73 fc ff ff    	je     80053b <vprintfmt+0x11>
  8008c8:	4e                   	dec    %esi
  8008c9:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8008cd:	75 f9                	jne    8008c8 <vprintfmt+0x39e>
  8008cf:	89 75 10             	mov    %esi,0x10(%ebp)
  8008d2:	e9 67 fc ff ff       	jmp    80053e <vprintfmt+0x14>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8008d7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8008da:	8d 70 01             	lea    0x1(%eax),%esi
  8008dd:	8a 00                	mov    (%eax),%al
  8008df:	0f be d0             	movsbl %al,%edx
  8008e2:	85 d2                	test   %edx,%edx
  8008e4:	0f 85 7a fe ff ff    	jne    800764 <vprintfmt+0x23a>
  8008ea:	e9 4f fc ff ff       	jmp    80053e <vprintfmt+0x14>
  8008ef:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8008f2:	8d 70 01             	lea    0x1(%eax),%esi
  8008f5:	8a 00                	mov    (%eax),%al
  8008f7:	0f be d0             	movsbl %al,%edx
  8008fa:	85 d2                	test   %edx,%edx
  8008fc:	0f 85 6a fe ff ff    	jne    80076c <vprintfmt+0x242>
  800902:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800905:	e9 77 fe ff ff       	jmp    800781 <vprintfmt+0x257>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  80090a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80090d:	5b                   	pop    %ebx
  80090e:	5e                   	pop    %esi
  80090f:	5f                   	pop    %edi
  800910:	5d                   	pop    %ebp
  800911:	c3                   	ret    

00800912 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800912:	55                   	push   %ebp
  800913:	89 e5                	mov    %esp,%ebp
  800915:	83 ec 18             	sub    $0x18,%esp
  800918:	8b 45 08             	mov    0x8(%ebp),%eax
  80091b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80091e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800921:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800925:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800928:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80092f:	85 c0                	test   %eax,%eax
  800931:	74 26                	je     800959 <vsnprintf+0x47>
  800933:	85 d2                	test   %edx,%edx
  800935:	7e 29                	jle    800960 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800937:	ff 75 14             	pushl  0x14(%ebp)
  80093a:	ff 75 10             	pushl  0x10(%ebp)
  80093d:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800940:	50                   	push   %eax
  800941:	68 f1 04 80 00       	push   $0x8004f1
  800946:	e8 df fb ff ff       	call   80052a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80094b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80094e:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800951:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800954:	83 c4 10             	add    $0x10,%esp
  800957:	eb 0c                	jmp    800965 <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800959:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80095e:	eb 05                	jmp    800965 <vsnprintf+0x53>
  800960:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800965:	c9                   	leave  
  800966:	c3                   	ret    

00800967 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800967:	55                   	push   %ebp
  800968:	89 e5                	mov    %esp,%ebp
  80096a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80096d:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800970:	50                   	push   %eax
  800971:	ff 75 10             	pushl  0x10(%ebp)
  800974:	ff 75 0c             	pushl  0xc(%ebp)
  800977:	ff 75 08             	pushl  0x8(%ebp)
  80097a:	e8 93 ff ff ff       	call   800912 <vsnprintf>
	va_end(ap);

	return rc;
}
  80097f:	c9                   	leave  
  800980:	c3                   	ret    

00800981 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800981:	55                   	push   %ebp
  800982:	89 e5                	mov    %esp,%ebp
  800984:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800987:	80 3a 00             	cmpb   $0x0,(%edx)
  80098a:	74 0e                	je     80099a <strlen+0x19>
  80098c:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800991:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800992:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800996:	75 f9                	jne    800991 <strlen+0x10>
  800998:	eb 05                	jmp    80099f <strlen+0x1e>
  80099a:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  80099f:	5d                   	pop    %ebp
  8009a0:	c3                   	ret    

008009a1 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8009a1:	55                   	push   %ebp
  8009a2:	89 e5                	mov    %esp,%ebp
  8009a4:	53                   	push   %ebx
  8009a5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8009a8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009ab:	85 c9                	test   %ecx,%ecx
  8009ad:	74 1a                	je     8009c9 <strnlen+0x28>
  8009af:	80 3b 00             	cmpb   $0x0,(%ebx)
  8009b2:	74 1c                	je     8009d0 <strnlen+0x2f>
  8009b4:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  8009b9:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009bb:	39 ca                	cmp    %ecx,%edx
  8009bd:	74 16                	je     8009d5 <strnlen+0x34>
  8009bf:	42                   	inc    %edx
  8009c0:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  8009c5:	75 f2                	jne    8009b9 <strnlen+0x18>
  8009c7:	eb 0c                	jmp    8009d5 <strnlen+0x34>
  8009c9:	b8 00 00 00 00       	mov    $0x0,%eax
  8009ce:	eb 05                	jmp    8009d5 <strnlen+0x34>
  8009d0:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8009d5:	5b                   	pop    %ebx
  8009d6:	5d                   	pop    %ebp
  8009d7:	c3                   	ret    

008009d8 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009d8:	55                   	push   %ebp
  8009d9:	89 e5                	mov    %esp,%ebp
  8009db:	53                   	push   %ebx
  8009dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8009df:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009e2:	89 c2                	mov    %eax,%edx
  8009e4:	42                   	inc    %edx
  8009e5:	41                   	inc    %ecx
  8009e6:	8a 59 ff             	mov    -0x1(%ecx),%bl
  8009e9:	88 5a ff             	mov    %bl,-0x1(%edx)
  8009ec:	84 db                	test   %bl,%bl
  8009ee:	75 f4                	jne    8009e4 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8009f0:	5b                   	pop    %ebx
  8009f1:	5d                   	pop    %ebp
  8009f2:	c3                   	ret    

008009f3 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009f3:	55                   	push   %ebp
  8009f4:	89 e5                	mov    %esp,%ebp
  8009f6:	53                   	push   %ebx
  8009f7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8009fa:	53                   	push   %ebx
  8009fb:	e8 81 ff ff ff       	call   800981 <strlen>
  800a00:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800a03:	ff 75 0c             	pushl  0xc(%ebp)
  800a06:	01 d8                	add    %ebx,%eax
  800a08:	50                   	push   %eax
  800a09:	e8 ca ff ff ff       	call   8009d8 <strcpy>
	return dst;
}
  800a0e:	89 d8                	mov    %ebx,%eax
  800a10:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a13:	c9                   	leave  
  800a14:	c3                   	ret    

00800a15 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a15:	55                   	push   %ebp
  800a16:	89 e5                	mov    %esp,%ebp
  800a18:	56                   	push   %esi
  800a19:	53                   	push   %ebx
  800a1a:	8b 75 08             	mov    0x8(%ebp),%esi
  800a1d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a20:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a23:	85 db                	test   %ebx,%ebx
  800a25:	74 14                	je     800a3b <strncpy+0x26>
  800a27:	01 f3                	add    %esi,%ebx
  800a29:	89 f1                	mov    %esi,%ecx
		*dst++ = *src;
  800a2b:	41                   	inc    %ecx
  800a2c:	8a 02                	mov    (%edx),%al
  800a2e:	88 41 ff             	mov    %al,-0x1(%ecx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a31:	80 3a 01             	cmpb   $0x1,(%edx)
  800a34:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a37:	39 cb                	cmp    %ecx,%ebx
  800a39:	75 f0                	jne    800a2b <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a3b:	89 f0                	mov    %esi,%eax
  800a3d:	5b                   	pop    %ebx
  800a3e:	5e                   	pop    %esi
  800a3f:	5d                   	pop    %ebp
  800a40:	c3                   	ret    

00800a41 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a41:	55                   	push   %ebp
  800a42:	89 e5                	mov    %esp,%ebp
  800a44:	53                   	push   %ebx
  800a45:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a48:	8b 45 10             	mov    0x10(%ebp),%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a4b:	85 c0                	test   %eax,%eax
  800a4d:	74 30                	je     800a7f <strlcpy+0x3e>
		while (--size > 0 && *src != '\0')
  800a4f:	48                   	dec    %eax
  800a50:	74 20                	je     800a72 <strlcpy+0x31>
  800a52:	8a 0b                	mov    (%ebx),%cl
  800a54:	84 c9                	test   %cl,%cl
  800a56:	74 1f                	je     800a77 <strlcpy+0x36>
  800a58:	8d 53 01             	lea    0x1(%ebx),%edx
  800a5b:	01 c3                	add    %eax,%ebx
  800a5d:	8b 45 08             	mov    0x8(%ebp),%eax
			*dst++ = *src++;
  800a60:	40                   	inc    %eax
  800a61:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a64:	39 da                	cmp    %ebx,%edx
  800a66:	74 12                	je     800a7a <strlcpy+0x39>
  800a68:	42                   	inc    %edx
  800a69:	8a 4a ff             	mov    -0x1(%edx),%cl
  800a6c:	84 c9                	test   %cl,%cl
  800a6e:	75 f0                	jne    800a60 <strlcpy+0x1f>
  800a70:	eb 08                	jmp    800a7a <strlcpy+0x39>
  800a72:	8b 45 08             	mov    0x8(%ebp),%eax
  800a75:	eb 03                	jmp    800a7a <strlcpy+0x39>
  800a77:	8b 45 08             	mov    0x8(%ebp),%eax
			*dst++ = *src++;
		*dst = '\0';
  800a7a:	c6 00 00             	movb   $0x0,(%eax)
  800a7d:	eb 03                	jmp    800a82 <strlcpy+0x41>
  800a7f:	8b 45 08             	mov    0x8(%ebp),%eax
	}
	return dst - dst_in;
  800a82:	2b 45 08             	sub    0x8(%ebp),%eax
}
  800a85:	5b                   	pop    %ebx
  800a86:	5d                   	pop    %ebp
  800a87:	c3                   	ret    

00800a88 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a88:	55                   	push   %ebp
  800a89:	89 e5                	mov    %esp,%ebp
  800a8b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a8e:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a91:	8a 01                	mov    (%ecx),%al
  800a93:	84 c0                	test   %al,%al
  800a95:	74 10                	je     800aa7 <strcmp+0x1f>
  800a97:	3a 02                	cmp    (%edx),%al
  800a99:	75 0c                	jne    800aa7 <strcmp+0x1f>
		p++, q++;
  800a9b:	41                   	inc    %ecx
  800a9c:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a9d:	8a 01                	mov    (%ecx),%al
  800a9f:	84 c0                	test   %al,%al
  800aa1:	74 04                	je     800aa7 <strcmp+0x1f>
  800aa3:	3a 02                	cmp    (%edx),%al
  800aa5:	74 f4                	je     800a9b <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800aa7:	0f b6 c0             	movzbl %al,%eax
  800aaa:	0f b6 12             	movzbl (%edx),%edx
  800aad:	29 d0                	sub    %edx,%eax
}
  800aaf:	5d                   	pop    %ebp
  800ab0:	c3                   	ret    

00800ab1 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800ab1:	55                   	push   %ebp
  800ab2:	89 e5                	mov    %esp,%ebp
  800ab4:	56                   	push   %esi
  800ab5:	53                   	push   %ebx
  800ab6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800ab9:	8b 55 0c             	mov    0xc(%ebp),%edx
  800abc:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  800abf:	85 f6                	test   %esi,%esi
  800ac1:	74 23                	je     800ae6 <strncmp+0x35>
  800ac3:	8a 03                	mov    (%ebx),%al
  800ac5:	84 c0                	test   %al,%al
  800ac7:	74 2b                	je     800af4 <strncmp+0x43>
  800ac9:	3a 02                	cmp    (%edx),%al
  800acb:	75 27                	jne    800af4 <strncmp+0x43>
  800acd:	8d 43 01             	lea    0x1(%ebx),%eax
  800ad0:	01 de                	add    %ebx,%esi
		n--, p++, q++;
  800ad2:	89 c3                	mov    %eax,%ebx
  800ad4:	42                   	inc    %edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800ad5:	39 c6                	cmp    %eax,%esi
  800ad7:	74 14                	je     800aed <strncmp+0x3c>
  800ad9:	8a 08                	mov    (%eax),%cl
  800adb:	84 c9                	test   %cl,%cl
  800add:	74 15                	je     800af4 <strncmp+0x43>
  800adf:	40                   	inc    %eax
  800ae0:	3a 0a                	cmp    (%edx),%cl
  800ae2:	74 ee                	je     800ad2 <strncmp+0x21>
  800ae4:	eb 0e                	jmp    800af4 <strncmp+0x43>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800ae6:	b8 00 00 00 00       	mov    $0x0,%eax
  800aeb:	eb 0f                	jmp    800afc <strncmp+0x4b>
  800aed:	b8 00 00 00 00       	mov    $0x0,%eax
  800af2:	eb 08                	jmp    800afc <strncmp+0x4b>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800af4:	0f b6 03             	movzbl (%ebx),%eax
  800af7:	0f b6 12             	movzbl (%edx),%edx
  800afa:	29 d0                	sub    %edx,%eax
}
  800afc:	5b                   	pop    %ebx
  800afd:	5e                   	pop    %esi
  800afe:	5d                   	pop    %ebp
  800aff:	c3                   	ret    

00800b00 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b00:	55                   	push   %ebp
  800b01:	89 e5                	mov    %esp,%ebp
  800b03:	53                   	push   %ebx
  800b04:	8b 45 08             	mov    0x8(%ebp),%eax
  800b07:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  800b0a:	8a 10                	mov    (%eax),%dl
  800b0c:	84 d2                	test   %dl,%dl
  800b0e:	74 1a                	je     800b2a <strchr+0x2a>
  800b10:	88 d9                	mov    %bl,%cl
		if (*s == c)
  800b12:	38 d3                	cmp    %dl,%bl
  800b14:	75 06                	jne    800b1c <strchr+0x1c>
  800b16:	eb 17                	jmp    800b2f <strchr+0x2f>
  800b18:	38 ca                	cmp    %cl,%dl
  800b1a:	74 13                	je     800b2f <strchr+0x2f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b1c:	40                   	inc    %eax
  800b1d:	8a 10                	mov    (%eax),%dl
  800b1f:	84 d2                	test   %dl,%dl
  800b21:	75 f5                	jne    800b18 <strchr+0x18>
		if (*s == c)
			return (char *) s;
	return 0;
  800b23:	b8 00 00 00 00       	mov    $0x0,%eax
  800b28:	eb 05                	jmp    800b2f <strchr+0x2f>
  800b2a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b2f:	5b                   	pop    %ebx
  800b30:	5d                   	pop    %ebp
  800b31:	c3                   	ret    

00800b32 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b32:	55                   	push   %ebp
  800b33:	89 e5                	mov    %esp,%ebp
  800b35:	53                   	push   %ebx
  800b36:	8b 45 08             	mov    0x8(%ebp),%eax
  800b39:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  800b3c:	8a 10                	mov    (%eax),%dl
  800b3e:	84 d2                	test   %dl,%dl
  800b40:	74 13                	je     800b55 <strfind+0x23>
  800b42:	88 d9                	mov    %bl,%cl
		if (*s == c)
  800b44:	38 d3                	cmp    %dl,%bl
  800b46:	75 06                	jne    800b4e <strfind+0x1c>
  800b48:	eb 0b                	jmp    800b55 <strfind+0x23>
  800b4a:	38 ca                	cmp    %cl,%dl
  800b4c:	74 07                	je     800b55 <strfind+0x23>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800b4e:	40                   	inc    %eax
  800b4f:	8a 10                	mov    (%eax),%dl
  800b51:	84 d2                	test   %dl,%dl
  800b53:	75 f5                	jne    800b4a <strfind+0x18>
		if (*s == c)
			break;
	return (char *) s;
}
  800b55:	5b                   	pop    %ebx
  800b56:	5d                   	pop    %ebp
  800b57:	c3                   	ret    

00800b58 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b58:	55                   	push   %ebp
  800b59:	89 e5                	mov    %esp,%ebp
  800b5b:	57                   	push   %edi
  800b5c:	56                   	push   %esi
  800b5d:	53                   	push   %ebx
  800b5e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b61:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b64:	85 c9                	test   %ecx,%ecx
  800b66:	74 36                	je     800b9e <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b68:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b6e:	75 28                	jne    800b98 <memset+0x40>
  800b70:	f6 c1 03             	test   $0x3,%cl
  800b73:	75 23                	jne    800b98 <memset+0x40>
		c &= 0xFF;
  800b75:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b79:	89 d3                	mov    %edx,%ebx
  800b7b:	c1 e3 08             	shl    $0x8,%ebx
  800b7e:	89 d6                	mov    %edx,%esi
  800b80:	c1 e6 18             	shl    $0x18,%esi
  800b83:	89 d0                	mov    %edx,%eax
  800b85:	c1 e0 10             	shl    $0x10,%eax
  800b88:	09 f0                	or     %esi,%eax
  800b8a:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800b8c:	89 d8                	mov    %ebx,%eax
  800b8e:	09 d0                	or     %edx,%eax
  800b90:	c1 e9 02             	shr    $0x2,%ecx
  800b93:	fc                   	cld    
  800b94:	f3 ab                	rep stos %eax,%es:(%edi)
  800b96:	eb 06                	jmp    800b9e <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b98:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b9b:	fc                   	cld    
  800b9c:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b9e:	89 f8                	mov    %edi,%eax
  800ba0:	5b                   	pop    %ebx
  800ba1:	5e                   	pop    %esi
  800ba2:	5f                   	pop    %edi
  800ba3:	5d                   	pop    %ebp
  800ba4:	c3                   	ret    

00800ba5 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ba5:	55                   	push   %ebp
  800ba6:	89 e5                	mov    %esp,%ebp
  800ba8:	57                   	push   %edi
  800ba9:	56                   	push   %esi
  800baa:	8b 45 08             	mov    0x8(%ebp),%eax
  800bad:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bb0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800bb3:	39 c6                	cmp    %eax,%esi
  800bb5:	73 33                	jae    800bea <memmove+0x45>
  800bb7:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800bba:	39 d0                	cmp    %edx,%eax
  800bbc:	73 2c                	jae    800bea <memmove+0x45>
		s += n;
		d += n;
  800bbe:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bc1:	89 d6                	mov    %edx,%esi
  800bc3:	09 fe                	or     %edi,%esi
  800bc5:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800bcb:	75 13                	jne    800be0 <memmove+0x3b>
  800bcd:	f6 c1 03             	test   $0x3,%cl
  800bd0:	75 0e                	jne    800be0 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800bd2:	83 ef 04             	sub    $0x4,%edi
  800bd5:	8d 72 fc             	lea    -0x4(%edx),%esi
  800bd8:	c1 e9 02             	shr    $0x2,%ecx
  800bdb:	fd                   	std    
  800bdc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bde:	eb 07                	jmp    800be7 <memmove+0x42>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800be0:	4f                   	dec    %edi
  800be1:	8d 72 ff             	lea    -0x1(%edx),%esi
  800be4:	fd                   	std    
  800be5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800be7:	fc                   	cld    
  800be8:	eb 1d                	jmp    800c07 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bea:	89 f2                	mov    %esi,%edx
  800bec:	09 c2                	or     %eax,%edx
  800bee:	f6 c2 03             	test   $0x3,%dl
  800bf1:	75 0f                	jne    800c02 <memmove+0x5d>
  800bf3:	f6 c1 03             	test   $0x3,%cl
  800bf6:	75 0a                	jne    800c02 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
  800bf8:	c1 e9 02             	shr    $0x2,%ecx
  800bfb:	89 c7                	mov    %eax,%edi
  800bfd:	fc                   	cld    
  800bfe:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c00:	eb 05                	jmp    800c07 <memmove+0x62>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c02:	89 c7                	mov    %eax,%edi
  800c04:	fc                   	cld    
  800c05:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c07:	5e                   	pop    %esi
  800c08:	5f                   	pop    %edi
  800c09:	5d                   	pop    %ebp
  800c0a:	c3                   	ret    

00800c0b <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c0b:	55                   	push   %ebp
  800c0c:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800c0e:	ff 75 10             	pushl  0x10(%ebp)
  800c11:	ff 75 0c             	pushl  0xc(%ebp)
  800c14:	ff 75 08             	pushl  0x8(%ebp)
  800c17:	e8 89 ff ff ff       	call   800ba5 <memmove>
}
  800c1c:	c9                   	leave  
  800c1d:	c3                   	ret    

00800c1e <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c1e:	55                   	push   %ebp
  800c1f:	89 e5                	mov    %esp,%ebp
  800c21:	57                   	push   %edi
  800c22:	56                   	push   %esi
  800c23:	53                   	push   %ebx
  800c24:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800c27:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c2a:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c2d:	85 c0                	test   %eax,%eax
  800c2f:	74 33                	je     800c64 <memcmp+0x46>
  800c31:	8d 78 ff             	lea    -0x1(%eax),%edi
		if (*s1 != *s2)
  800c34:	8a 13                	mov    (%ebx),%dl
  800c36:	8a 0e                	mov    (%esi),%cl
  800c38:	38 ca                	cmp    %cl,%dl
  800c3a:	75 13                	jne    800c4f <memcmp+0x31>
  800c3c:	b8 00 00 00 00       	mov    $0x0,%eax
  800c41:	eb 16                	jmp    800c59 <memcmp+0x3b>
  800c43:	8a 54 03 01          	mov    0x1(%ebx,%eax,1),%dl
  800c47:	40                   	inc    %eax
  800c48:	8a 0c 06             	mov    (%esi,%eax,1),%cl
  800c4b:	38 ca                	cmp    %cl,%dl
  800c4d:	74 0a                	je     800c59 <memcmp+0x3b>
			return (int) *s1 - (int) *s2;
  800c4f:	0f b6 c2             	movzbl %dl,%eax
  800c52:	0f b6 c9             	movzbl %cl,%ecx
  800c55:	29 c8                	sub    %ecx,%eax
  800c57:	eb 10                	jmp    800c69 <memcmp+0x4b>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c59:	39 f8                	cmp    %edi,%eax
  800c5b:	75 e6                	jne    800c43 <memcmp+0x25>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c5d:	b8 00 00 00 00       	mov    $0x0,%eax
  800c62:	eb 05                	jmp    800c69 <memcmp+0x4b>
  800c64:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c69:	5b                   	pop    %ebx
  800c6a:	5e                   	pop    %esi
  800c6b:	5f                   	pop    %edi
  800c6c:	5d                   	pop    %ebp
  800c6d:	c3                   	ret    

00800c6e <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c6e:	55                   	push   %ebp
  800c6f:	89 e5                	mov    %esp,%ebp
  800c71:	53                   	push   %ebx
  800c72:	8b 55 08             	mov    0x8(%ebp),%edx
	const void *ends = (const char *) s + n;
  800c75:	89 d0                	mov    %edx,%eax
  800c77:	03 45 10             	add    0x10(%ebp),%eax
	for (; s < ends; s++)
  800c7a:	39 c2                	cmp    %eax,%edx
  800c7c:	73 1b                	jae    800c99 <memfind+0x2b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c7e:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
  800c82:	0f b6 0a             	movzbl (%edx),%ecx
  800c85:	39 d9                	cmp    %ebx,%ecx
  800c87:	75 09                	jne    800c92 <memfind+0x24>
  800c89:	eb 12                	jmp    800c9d <memfind+0x2f>
  800c8b:	0f b6 0a             	movzbl (%edx),%ecx
  800c8e:	39 d9                	cmp    %ebx,%ecx
  800c90:	74 0f                	je     800ca1 <memfind+0x33>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c92:	42                   	inc    %edx
  800c93:	39 d0                	cmp    %edx,%eax
  800c95:	75 f4                	jne    800c8b <memfind+0x1d>
  800c97:	eb 0a                	jmp    800ca3 <memfind+0x35>
  800c99:	89 d0                	mov    %edx,%eax
  800c9b:	eb 06                	jmp    800ca3 <memfind+0x35>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c9d:	89 d0                	mov    %edx,%eax
  800c9f:	eb 02                	jmp    800ca3 <memfind+0x35>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ca1:	89 d0                	mov    %edx,%eax
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ca3:	5b                   	pop    %ebx
  800ca4:	5d                   	pop    %ebp
  800ca5:	c3                   	ret    

00800ca6 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ca6:	55                   	push   %ebp
  800ca7:	89 e5                	mov    %esp,%ebp
  800ca9:	57                   	push   %edi
  800caa:	56                   	push   %esi
  800cab:	53                   	push   %ebx
  800cac:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800caf:	eb 01                	jmp    800cb2 <strtol+0xc>
		s++;
  800cb1:	41                   	inc    %ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cb2:	8a 01                	mov    (%ecx),%al
  800cb4:	3c 20                	cmp    $0x20,%al
  800cb6:	74 f9                	je     800cb1 <strtol+0xb>
  800cb8:	3c 09                	cmp    $0x9,%al
  800cba:	74 f5                	je     800cb1 <strtol+0xb>
		s++;

	// plus/minus sign
	if (*s == '+')
  800cbc:	3c 2b                	cmp    $0x2b,%al
  800cbe:	75 08                	jne    800cc8 <strtol+0x22>
		s++;
  800cc0:	41                   	inc    %ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800cc1:	bf 00 00 00 00       	mov    $0x0,%edi
  800cc6:	eb 11                	jmp    800cd9 <strtol+0x33>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800cc8:	3c 2d                	cmp    $0x2d,%al
  800cca:	75 08                	jne    800cd4 <strtol+0x2e>
		s++, neg = 1;
  800ccc:	41                   	inc    %ecx
  800ccd:	bf 01 00 00 00       	mov    $0x1,%edi
  800cd2:	eb 05                	jmp    800cd9 <strtol+0x33>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800cd4:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800cd9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800cdd:	0f 84 87 00 00 00    	je     800d6a <strtol+0xc4>
  800ce3:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  800ce7:	75 27                	jne    800d10 <strtol+0x6a>
  800ce9:	80 39 30             	cmpb   $0x30,(%ecx)
  800cec:	75 22                	jne    800d10 <strtol+0x6a>
  800cee:	e9 88 00 00 00       	jmp    800d7b <strtol+0xd5>
		s += 2, base = 16;
  800cf3:	83 c1 02             	add    $0x2,%ecx
  800cf6:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  800cfd:	eb 11                	jmp    800d10 <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
  800cff:	41                   	inc    %ecx
  800d00:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  800d07:	eb 07                	jmp    800d10 <strtol+0x6a>
	else if (base == 0)
		base = 10;
  800d09:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)
  800d10:	b8 00 00 00 00       	mov    $0x0,%eax

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d15:	8a 11                	mov    (%ecx),%dl
  800d17:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800d1a:	80 fb 09             	cmp    $0x9,%bl
  800d1d:	77 08                	ja     800d27 <strtol+0x81>
			dig = *s - '0';
  800d1f:	0f be d2             	movsbl %dl,%edx
  800d22:	83 ea 30             	sub    $0x30,%edx
  800d25:	eb 22                	jmp    800d49 <strtol+0xa3>
		else if (*s >= 'a' && *s <= 'z')
  800d27:	8d 72 9f             	lea    -0x61(%edx),%esi
  800d2a:	89 f3                	mov    %esi,%ebx
  800d2c:	80 fb 19             	cmp    $0x19,%bl
  800d2f:	77 08                	ja     800d39 <strtol+0x93>
			dig = *s - 'a' + 10;
  800d31:	0f be d2             	movsbl %dl,%edx
  800d34:	83 ea 57             	sub    $0x57,%edx
  800d37:	eb 10                	jmp    800d49 <strtol+0xa3>
		else if (*s >= 'A' && *s <= 'Z')
  800d39:	8d 72 bf             	lea    -0x41(%edx),%esi
  800d3c:	89 f3                	mov    %esi,%ebx
  800d3e:	80 fb 19             	cmp    $0x19,%bl
  800d41:	77 14                	ja     800d57 <strtol+0xb1>
			dig = *s - 'A' + 10;
  800d43:	0f be d2             	movsbl %dl,%edx
  800d46:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800d49:	3b 55 10             	cmp    0x10(%ebp),%edx
  800d4c:	7d 09                	jge    800d57 <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800d4e:	41                   	inc    %ecx
  800d4f:	0f af 45 10          	imul   0x10(%ebp),%eax
  800d53:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800d55:	eb be                	jmp    800d15 <strtol+0x6f>

	if (endptr)
  800d57:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d5b:	74 05                	je     800d62 <strtol+0xbc>
		*endptr = (char *) s;
  800d5d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d60:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800d62:	85 ff                	test   %edi,%edi
  800d64:	74 21                	je     800d87 <strtol+0xe1>
  800d66:	f7 d8                	neg    %eax
  800d68:	eb 1d                	jmp    800d87 <strtol+0xe1>
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d6a:	80 39 30             	cmpb   $0x30,(%ecx)
  800d6d:	75 9a                	jne    800d09 <strtol+0x63>
  800d6f:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800d73:	0f 84 7a ff ff ff    	je     800cf3 <strtol+0x4d>
  800d79:	eb 84                	jmp    800cff <strtol+0x59>
  800d7b:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800d7f:	0f 84 6e ff ff ff    	je     800cf3 <strtol+0x4d>
  800d85:	eb 89                	jmp    800d10 <strtol+0x6a>
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
}
  800d87:	5b                   	pop    %ebx
  800d88:	5e                   	pop    %esi
  800d89:	5f                   	pop    %edi
  800d8a:	5d                   	pop    %ebp
  800d8b:	c3                   	ret    

00800d8c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800d8c:	55                   	push   %ebp
  800d8d:	89 e5                	mov    %esp,%ebp
  800d8f:	57                   	push   %edi
  800d90:	56                   	push   %esi
  800d91:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d92:	b8 00 00 00 00       	mov    $0x0,%eax
  800d97:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d9a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d9d:	89 c3                	mov    %eax,%ebx
  800d9f:	89 c7                	mov    %eax,%edi
  800da1:	89 c6                	mov    %eax,%esi
  800da3:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800da5:	5b                   	pop    %ebx
  800da6:	5e                   	pop    %esi
  800da7:	5f                   	pop    %edi
  800da8:	5d                   	pop    %ebp
  800da9:	c3                   	ret    

00800daa <sys_cgetc>:

int
sys_cgetc(void)
{
  800daa:	55                   	push   %ebp
  800dab:	89 e5                	mov    %esp,%ebp
  800dad:	57                   	push   %edi
  800dae:	56                   	push   %esi
  800daf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800db0:	ba 00 00 00 00       	mov    $0x0,%edx
  800db5:	b8 01 00 00 00       	mov    $0x1,%eax
  800dba:	89 d1                	mov    %edx,%ecx
  800dbc:	89 d3                	mov    %edx,%ebx
  800dbe:	89 d7                	mov    %edx,%edi
  800dc0:	89 d6                	mov    %edx,%esi
  800dc2:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800dc4:	5b                   	pop    %ebx
  800dc5:	5e                   	pop    %esi
  800dc6:	5f                   	pop    %edi
  800dc7:	5d                   	pop    %ebp
  800dc8:	c3                   	ret    

00800dc9 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800dc9:	55                   	push   %ebp
  800dca:	89 e5                	mov    %esp,%ebp
  800dcc:	57                   	push   %edi
  800dcd:	56                   	push   %esi
  800dce:	53                   	push   %ebx
  800dcf:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dd2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dd7:	b8 03 00 00 00       	mov    $0x3,%eax
  800ddc:	8b 55 08             	mov    0x8(%ebp),%edx
  800ddf:	89 cb                	mov    %ecx,%ebx
  800de1:	89 cf                	mov    %ecx,%edi
  800de3:	89 ce                	mov    %ecx,%esi
  800de5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800de7:	85 c0                	test   %eax,%eax
  800de9:	7e 17                	jle    800e02 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800deb:	83 ec 0c             	sub    $0xc,%esp
  800dee:	50                   	push   %eax
  800def:	6a 03                	push   $0x3
  800df1:	68 1f 29 80 00       	push   $0x80291f
  800df6:	6a 23                	push   $0x23
  800df8:	68 3c 29 80 00       	push   $0x80293c
  800dfd:	e8 19 f5 ff ff       	call   80031b <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800e02:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e05:	5b                   	pop    %ebx
  800e06:	5e                   	pop    %esi
  800e07:	5f                   	pop    %edi
  800e08:	5d                   	pop    %ebp
  800e09:	c3                   	ret    

00800e0a <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800e0a:	55                   	push   %ebp
  800e0b:	89 e5                	mov    %esp,%ebp
  800e0d:	57                   	push   %edi
  800e0e:	56                   	push   %esi
  800e0f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e10:	ba 00 00 00 00       	mov    $0x0,%edx
  800e15:	b8 02 00 00 00       	mov    $0x2,%eax
  800e1a:	89 d1                	mov    %edx,%ecx
  800e1c:	89 d3                	mov    %edx,%ebx
  800e1e:	89 d7                	mov    %edx,%edi
  800e20:	89 d6                	mov    %edx,%esi
  800e22:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800e24:	5b                   	pop    %ebx
  800e25:	5e                   	pop    %esi
  800e26:	5f                   	pop    %edi
  800e27:	5d                   	pop    %ebp
  800e28:	c3                   	ret    

00800e29 <sys_yield>:

void
sys_yield(void)
{
  800e29:	55                   	push   %ebp
  800e2a:	89 e5                	mov    %esp,%ebp
  800e2c:	57                   	push   %edi
  800e2d:	56                   	push   %esi
  800e2e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e2f:	ba 00 00 00 00       	mov    $0x0,%edx
  800e34:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e39:	89 d1                	mov    %edx,%ecx
  800e3b:	89 d3                	mov    %edx,%ebx
  800e3d:	89 d7                	mov    %edx,%edi
  800e3f:	89 d6                	mov    %edx,%esi
  800e41:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800e43:	5b                   	pop    %ebx
  800e44:	5e                   	pop    %esi
  800e45:	5f                   	pop    %edi
  800e46:	5d                   	pop    %ebp
  800e47:	c3                   	ret    

00800e48 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800e48:	55                   	push   %ebp
  800e49:	89 e5                	mov    %esp,%ebp
  800e4b:	57                   	push   %edi
  800e4c:	56                   	push   %esi
  800e4d:	53                   	push   %ebx
  800e4e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e51:	be 00 00 00 00       	mov    $0x0,%esi
  800e56:	b8 04 00 00 00       	mov    $0x4,%eax
  800e5b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e5e:	8b 55 08             	mov    0x8(%ebp),%edx
  800e61:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e64:	89 f7                	mov    %esi,%edi
  800e66:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e68:	85 c0                	test   %eax,%eax
  800e6a:	7e 17                	jle    800e83 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e6c:	83 ec 0c             	sub    $0xc,%esp
  800e6f:	50                   	push   %eax
  800e70:	6a 04                	push   $0x4
  800e72:	68 1f 29 80 00       	push   $0x80291f
  800e77:	6a 23                	push   $0x23
  800e79:	68 3c 29 80 00       	push   $0x80293c
  800e7e:	e8 98 f4 ff ff       	call   80031b <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800e83:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e86:	5b                   	pop    %ebx
  800e87:	5e                   	pop    %esi
  800e88:	5f                   	pop    %edi
  800e89:	5d                   	pop    %ebp
  800e8a:	c3                   	ret    

00800e8b <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800e8b:	55                   	push   %ebp
  800e8c:	89 e5                	mov    %esp,%ebp
  800e8e:	57                   	push   %edi
  800e8f:	56                   	push   %esi
  800e90:	53                   	push   %ebx
  800e91:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e94:	b8 05 00 00 00       	mov    $0x5,%eax
  800e99:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e9c:	8b 55 08             	mov    0x8(%ebp),%edx
  800e9f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ea2:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ea5:	8b 75 18             	mov    0x18(%ebp),%esi
  800ea8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800eaa:	85 c0                	test   %eax,%eax
  800eac:	7e 17                	jle    800ec5 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800eae:	83 ec 0c             	sub    $0xc,%esp
  800eb1:	50                   	push   %eax
  800eb2:	6a 05                	push   $0x5
  800eb4:	68 1f 29 80 00       	push   $0x80291f
  800eb9:	6a 23                	push   $0x23
  800ebb:	68 3c 29 80 00       	push   $0x80293c
  800ec0:	e8 56 f4 ff ff       	call   80031b <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800ec5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ec8:	5b                   	pop    %ebx
  800ec9:	5e                   	pop    %esi
  800eca:	5f                   	pop    %edi
  800ecb:	5d                   	pop    %ebp
  800ecc:	c3                   	ret    

00800ecd <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800ecd:	55                   	push   %ebp
  800ece:	89 e5                	mov    %esp,%ebp
  800ed0:	57                   	push   %edi
  800ed1:	56                   	push   %esi
  800ed2:	53                   	push   %ebx
  800ed3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ed6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800edb:	b8 06 00 00 00       	mov    $0x6,%eax
  800ee0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ee3:	8b 55 08             	mov    0x8(%ebp),%edx
  800ee6:	89 df                	mov    %ebx,%edi
  800ee8:	89 de                	mov    %ebx,%esi
  800eea:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800eec:	85 c0                	test   %eax,%eax
  800eee:	7e 17                	jle    800f07 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ef0:	83 ec 0c             	sub    $0xc,%esp
  800ef3:	50                   	push   %eax
  800ef4:	6a 06                	push   $0x6
  800ef6:	68 1f 29 80 00       	push   $0x80291f
  800efb:	6a 23                	push   $0x23
  800efd:	68 3c 29 80 00       	push   $0x80293c
  800f02:	e8 14 f4 ff ff       	call   80031b <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800f07:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f0a:	5b                   	pop    %ebx
  800f0b:	5e                   	pop    %esi
  800f0c:	5f                   	pop    %edi
  800f0d:	5d                   	pop    %ebp
  800f0e:	c3                   	ret    

00800f0f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800f0f:	55                   	push   %ebp
  800f10:	89 e5                	mov    %esp,%ebp
  800f12:	57                   	push   %edi
  800f13:	56                   	push   %esi
  800f14:	53                   	push   %ebx
  800f15:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f18:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f1d:	b8 08 00 00 00       	mov    $0x8,%eax
  800f22:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f25:	8b 55 08             	mov    0x8(%ebp),%edx
  800f28:	89 df                	mov    %ebx,%edi
  800f2a:	89 de                	mov    %ebx,%esi
  800f2c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f2e:	85 c0                	test   %eax,%eax
  800f30:	7e 17                	jle    800f49 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f32:	83 ec 0c             	sub    $0xc,%esp
  800f35:	50                   	push   %eax
  800f36:	6a 08                	push   $0x8
  800f38:	68 1f 29 80 00       	push   $0x80291f
  800f3d:	6a 23                	push   $0x23
  800f3f:	68 3c 29 80 00       	push   $0x80293c
  800f44:	e8 d2 f3 ff ff       	call   80031b <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800f49:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f4c:	5b                   	pop    %ebx
  800f4d:	5e                   	pop    %esi
  800f4e:	5f                   	pop    %edi
  800f4f:	5d                   	pop    %ebp
  800f50:	c3                   	ret    

00800f51 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800f51:	55                   	push   %ebp
  800f52:	89 e5                	mov    %esp,%ebp
  800f54:	57                   	push   %edi
  800f55:	56                   	push   %esi
  800f56:	53                   	push   %ebx
  800f57:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f5a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f5f:	b8 09 00 00 00       	mov    $0x9,%eax
  800f64:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f67:	8b 55 08             	mov    0x8(%ebp),%edx
  800f6a:	89 df                	mov    %ebx,%edi
  800f6c:	89 de                	mov    %ebx,%esi
  800f6e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f70:	85 c0                	test   %eax,%eax
  800f72:	7e 17                	jle    800f8b <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f74:	83 ec 0c             	sub    $0xc,%esp
  800f77:	50                   	push   %eax
  800f78:	6a 09                	push   $0x9
  800f7a:	68 1f 29 80 00       	push   $0x80291f
  800f7f:	6a 23                	push   $0x23
  800f81:	68 3c 29 80 00       	push   $0x80293c
  800f86:	e8 90 f3 ff ff       	call   80031b <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800f8b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f8e:	5b                   	pop    %ebx
  800f8f:	5e                   	pop    %esi
  800f90:	5f                   	pop    %edi
  800f91:	5d                   	pop    %ebp
  800f92:	c3                   	ret    

00800f93 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800f93:	55                   	push   %ebp
  800f94:	89 e5                	mov    %esp,%ebp
  800f96:	57                   	push   %edi
  800f97:	56                   	push   %esi
  800f98:	53                   	push   %ebx
  800f99:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f9c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fa1:	b8 0a 00 00 00       	mov    $0xa,%eax
  800fa6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fa9:	8b 55 08             	mov    0x8(%ebp),%edx
  800fac:	89 df                	mov    %ebx,%edi
  800fae:	89 de                	mov    %ebx,%esi
  800fb0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800fb2:	85 c0                	test   %eax,%eax
  800fb4:	7e 17                	jle    800fcd <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fb6:	83 ec 0c             	sub    $0xc,%esp
  800fb9:	50                   	push   %eax
  800fba:	6a 0a                	push   $0xa
  800fbc:	68 1f 29 80 00       	push   $0x80291f
  800fc1:	6a 23                	push   $0x23
  800fc3:	68 3c 29 80 00       	push   $0x80293c
  800fc8:	e8 4e f3 ff ff       	call   80031b <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800fcd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fd0:	5b                   	pop    %ebx
  800fd1:	5e                   	pop    %esi
  800fd2:	5f                   	pop    %edi
  800fd3:	5d                   	pop    %ebp
  800fd4:	c3                   	ret    

00800fd5 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800fd5:	55                   	push   %ebp
  800fd6:	89 e5                	mov    %esp,%ebp
  800fd8:	57                   	push   %edi
  800fd9:	56                   	push   %esi
  800fda:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fdb:	be 00 00 00 00       	mov    $0x0,%esi
  800fe0:	b8 0c 00 00 00       	mov    $0xc,%eax
  800fe5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fe8:	8b 55 08             	mov    0x8(%ebp),%edx
  800feb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800fee:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ff1:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ff3:	5b                   	pop    %ebx
  800ff4:	5e                   	pop    %esi
  800ff5:	5f                   	pop    %edi
  800ff6:	5d                   	pop    %ebp
  800ff7:	c3                   	ret    

00800ff8 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ff8:	55                   	push   %ebp
  800ff9:	89 e5                	mov    %esp,%ebp
  800ffb:	57                   	push   %edi
  800ffc:	56                   	push   %esi
  800ffd:	53                   	push   %ebx
  800ffe:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801001:	b9 00 00 00 00       	mov    $0x0,%ecx
  801006:	b8 0d 00 00 00       	mov    $0xd,%eax
  80100b:	8b 55 08             	mov    0x8(%ebp),%edx
  80100e:	89 cb                	mov    %ecx,%ebx
  801010:	89 cf                	mov    %ecx,%edi
  801012:	89 ce                	mov    %ecx,%esi
  801014:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801016:	85 c0                	test   %eax,%eax
  801018:	7e 17                	jle    801031 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80101a:	83 ec 0c             	sub    $0xc,%esp
  80101d:	50                   	push   %eax
  80101e:	6a 0d                	push   $0xd
  801020:	68 1f 29 80 00       	push   $0x80291f
  801025:	6a 23                	push   $0x23
  801027:	68 3c 29 80 00       	push   $0x80293c
  80102c:	e8 ea f2 ff ff       	call   80031b <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801031:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801034:	5b                   	pop    %ebx
  801035:	5e                   	pop    %esi
  801036:	5f                   	pop    %edi
  801037:	5d                   	pop    %ebp
  801038:	c3                   	ret    

00801039 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  801039:	55                   	push   %ebp
  80103a:	89 e5                	mov    %esp,%ebp
  80103c:	56                   	push   %esi
  80103d:	53                   	push   %ebx
  80103e:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  801041:	8b 18                	mov    (%eax),%ebx
	// copy-on-write page.  If not, panic.
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).
	
	if((err & FEC_WR) == 0){
  801043:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  801047:	75 14                	jne    80105d <pgfault+0x24>
		panic("pgfault not cause by write \n");
  801049:	83 ec 04             	sub    $0x4,%esp
  80104c:	68 4a 29 80 00       	push   $0x80294a
  801051:	6a 1c                	push   $0x1c
  801053:	68 67 29 80 00       	push   $0x802967
  801058:	e8 be f2 ff ff       	call   80031b <_panic>
	}
 
	if ((uvpt[PGNUM(addr)] & PTE_COW) == 0) 
  80105d:	89 d8                	mov    %ebx,%eax
  80105f:	c1 e8 0c             	shr    $0xc,%eax
  801062:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801069:	f6 c4 08             	test   $0x8,%ah
  80106c:	75 14                	jne    801082 <pgfault+0x49>
    {
        panic("pgfault not cause by COW \n");
  80106e:	83 ec 04             	sub    $0x4,%esp
  801071:	68 72 29 80 00       	push   $0x802972
  801076:	6a 21                	push   $0x21
  801078:	68 67 29 80 00       	push   $0x802967
  80107d:	e8 99 f2 ff ff       	call   80031b <_panic>
	// copy the data from the old page to the new page, then move the new
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.
	envid_t eid = sys_getenvid();
  801082:	e8 83 fd ff ff       	call   800e0a <sys_getenvid>
  801087:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(eid,(void*)PFTEMP,PTE_P|PTE_W|PTE_U)) < 0)
  801089:	83 ec 04             	sub    $0x4,%esp
  80108c:	6a 07                	push   $0x7
  80108e:	68 00 f0 7f 00       	push   $0x7ff000
  801093:	50                   	push   %eax
  801094:	e8 af fd ff ff       	call   800e48 <sys_page_alloc>
  801099:	83 c4 10             	add    $0x10,%esp
  80109c:	85 c0                	test   %eax,%eax
  80109e:	79 14                	jns    8010b4 <pgfault+0x7b>
		panic("page alloction failed.\n");
  8010a0:	83 ec 04             	sub    $0x4,%esp
  8010a3:	68 8d 29 80 00       	push   $0x80298d
  8010a8:	6a 2d                	push   $0x2d
  8010aa:	68 67 29 80 00       	push   $0x802967
  8010af:	e8 67 f2 ff ff       	call   80031b <_panic>
	addr = ROUNDDOWN(addr,PGSIZE);
  8010b4:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memmove(PFTEMP,addr,PGSIZE);
  8010ba:	83 ec 04             	sub    $0x4,%esp
  8010bd:	68 00 10 00 00       	push   $0x1000
  8010c2:	53                   	push   %ebx
  8010c3:	68 00 f0 7f 00       	push   $0x7ff000
  8010c8:	e8 d8 fa ff ff       	call   800ba5 <memmove>
	if ((r = sys_page_map(eid, PFTEMP, eid, addr, PTE_P | PTE_W |PTE_U)) < 0)
  8010cd:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  8010d4:	53                   	push   %ebx
  8010d5:	56                   	push   %esi
  8010d6:	68 00 f0 7f 00       	push   $0x7ff000
  8010db:	56                   	push   %esi
  8010dc:	e8 aa fd ff ff       	call   800e8b <sys_page_map>
  8010e1:	83 c4 20             	add    $0x20,%esp
  8010e4:	85 c0                	test   %eax,%eax
  8010e6:	79 12                	jns    8010fa <pgfault+0xc1>
        panic("pgfault: page map failed %e\n", r);
  8010e8:	50                   	push   %eax
  8010e9:	68 a5 29 80 00       	push   $0x8029a5
  8010ee:	6a 31                	push   $0x31
  8010f0:	68 67 29 80 00       	push   $0x802967
  8010f5:	e8 21 f2 ff ff       	call   80031b <_panic>
	if ((r = sys_page_unmap(eid, PFTEMP)) < 0)
  8010fa:	83 ec 08             	sub    $0x8,%esp
  8010fd:	68 00 f0 7f 00       	push   $0x7ff000
  801102:	56                   	push   %esi
  801103:	e8 c5 fd ff ff       	call   800ecd <sys_page_unmap>
  801108:	83 c4 10             	add    $0x10,%esp
  80110b:	85 c0                	test   %eax,%eax
  80110d:	79 12                	jns    801121 <pgfault+0xe8>
        panic("pgfault: page unmap failed %e\n", r);
  80110f:	50                   	push   %eax
  801110:	68 14 2a 80 00       	push   $0x802a14
  801115:	6a 33                	push   $0x33
  801117:	68 67 29 80 00       	push   $0x802967
  80111c:	e8 fa f1 ff ff       	call   80031b <_panic>
	// LAB 4: Your code here.

	// panic("pgfault not implemented");
}
  801121:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801124:	5b                   	pop    %ebx
  801125:	5e                   	pop    %esi
  801126:	5d                   	pop    %ebp
  801127:	c3                   	ret    

00801128 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801128:	55                   	push   %ebp
  801129:	89 e5                	mov    %esp,%ebp
  80112b:	57                   	push   %edi
  80112c:	56                   	push   %esi
  80112d:	53                   	push   %ebx
  80112e:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	struct PageInfo* pg = NULL;
	set_pgfault_handler(pgfault);
  801131:	68 39 10 80 00       	push   $0x801039
  801136:	e8 ed 0e 00 00       	call   802028 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  80113b:	b8 07 00 00 00       	mov    $0x7,%eax
  801140:	cd 30                	int    $0x30
  801142:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801145:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t eid = sys_exofork();
	if (eid < 0) panic("fork fault.\n");
  801148:	83 c4 10             	add    $0x10,%esp
  80114b:	85 c0                	test   %eax,%eax
  80114d:	79 14                	jns    801163 <fork+0x3b>
  80114f:	83 ec 04             	sub    $0x4,%esp
  801152:	68 c2 29 80 00       	push   $0x8029c2
  801157:	6a 71                	push   $0x71
  801159:	68 67 29 80 00       	push   $0x802967
  80115e:	e8 b8 f1 ff ff       	call   80031b <_panic>
	if (eid == 0){
  801163:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801167:	75 25                	jne    80118e <fork+0x66>
		thisenv = &envs[ENVX(sys_getenvid())];
  801169:	e8 9c fc ff ff       	call   800e0a <sys_getenvid>
  80116e:	25 ff 03 00 00       	and    $0x3ff,%eax
  801173:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80117a:	c1 e0 07             	shl    $0x7,%eax
  80117d:	29 d0                	sub    %edx,%eax
  80117f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801184:	a3 04 40 80 00       	mov    %eax,0x804004
		return eid;
  801189:	e9 61 01 00 00       	jmp    8012ef <fork+0x1c7>
  80118e:	bb 00 00 80 00       	mov    $0x800000,%ebx
	}
	// copy something to the child page.
	for (uintptr_t i = UTEXT;i <= USTACKTOP;i += PGSIZE){
		if (uvpd[PDX(i)] & PTE_P && (uvpt[PGNUM(i)] & PTE_P)){
  801193:	89 d8                	mov    %ebx,%eax
  801195:	c1 e8 16             	shr    $0x16,%eax
  801198:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80119f:	a8 01                	test   $0x1,%al
  8011a1:	74 52                	je     8011f5 <fork+0xcd>
  8011a3:	89 de                	mov    %ebx,%esi
  8011a5:	c1 ee 0c             	shr    $0xc,%esi
  8011a8:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8011af:	a8 01                	test   $0x1,%al
  8011b1:	74 42                	je     8011f5 <fork+0xcd>
duppage(envid_t envid, unsigned pn)
{
	int r;

	// LAB 4: Your code here.
	envid_t myenvid = sys_getenvid();
  8011b3:	e8 52 fc ff ff       	call   800e0a <sys_getenvid>
  8011b8:	89 c7                	mov    %eax,%edi
	pte_t pte = uvpt[pn];
  8011ba:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
	int perm = PTE_U | PTE_P;
	if(pte & PTE_W || pte & PTE_COW)
  8011c1:	a9 02 08 00 00       	test   $0x802,%eax
  8011c6:	0f 85 de 00 00 00    	jne    8012aa <fork+0x182>
  8011cc:	e9 fb 00 00 00       	jmp    8012cc <fork+0x1a4>
		perm |= PTE_COW;
	if((r = sys_page_map(myenvid,(void*)(pn*PGSIZE),envid,(void*)(pn*PGSIZE),perm))<0){
		panic("duppage fault :%e\n",r);
  8011d1:	50                   	push   %eax
  8011d2:	68 cf 29 80 00       	push   $0x8029cf
  8011d7:	6a 50                	push   $0x50
  8011d9:	68 67 29 80 00       	push   $0x802967
  8011de:	e8 38 f1 ff ff       	call   80031b <_panic>
	}
	if(perm & PTE_COW){
		if((r = sys_page_map(myenvid,(void*)(pn*PGSIZE),myenvid,(void*)(pn*PGSIZE),perm))<0)
			panic("duppage fault :%e\n",r);
  8011e3:	50                   	push   %eax
  8011e4:	68 cf 29 80 00       	push   $0x8029cf
  8011e9:	6a 54                	push   $0x54
  8011eb:	68 67 29 80 00       	push   $0x802967
  8011f0:	e8 26 f1 ff ff       	call   80031b <_panic>
	if (eid == 0){
		thisenv = &envs[ENVX(sys_getenvid())];
		return eid;
	}
	// copy something to the child page.
	for (uintptr_t i = UTEXT;i <= USTACKTOP;i += PGSIZE){
  8011f5:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8011fb:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  801201:	75 90                	jne    801193 <fork+0x6b>
		if (uvpd[PDX(i)] & PTE_P && (uvpt[PGNUM(i)] & PTE_P)){
			duppage(eid,PGNUM(i));
		}
	}
	int r = sys_page_alloc(eid,(void*)(UXSTACKTOP-PGSIZE),PTE_U|PTE_P|PTE_W);
  801203:	83 ec 04             	sub    $0x4,%esp
  801206:	6a 07                	push   $0x7
  801208:	68 00 f0 bf ee       	push   $0xeebff000
  80120d:	ff 75 e0             	pushl  -0x20(%ebp)
  801210:	e8 33 fc ff ff       	call   800e48 <sys_page_alloc>
	if (r < 0) panic("fork fault.\n");
  801215:	83 c4 10             	add    $0x10,%esp
  801218:	85 c0                	test   %eax,%eax
  80121a:	79 14                	jns    801230 <fork+0x108>
  80121c:	83 ec 04             	sub    $0x4,%esp
  80121f:	68 c2 29 80 00       	push   $0x8029c2
  801224:	6a 7d                	push   $0x7d
  801226:	68 67 29 80 00       	push   $0x802967
  80122b:	e8 eb f0 ff ff       	call   80031b <_panic>

	extern void _pgfault_upcall();
    r = sys_env_set_pgfault_upcall(eid, _pgfault_upcall);
  801230:	83 ec 08             	sub    $0x8,%esp
  801233:	68 a0 20 80 00       	push   $0x8020a0
  801238:	ff 75 e0             	pushl  -0x20(%ebp)
  80123b:	e8 53 fd ff ff       	call   800f93 <sys_env_set_pgfault_upcall>
    if (r < 0) panic("fork fault 3\n");
  801240:	83 c4 10             	add    $0x10,%esp
  801243:	85 c0                	test   %eax,%eax
  801245:	79 17                	jns    80125e <fork+0x136>
  801247:	83 ec 04             	sub    $0x4,%esp
  80124a:	68 e2 29 80 00       	push   $0x8029e2
  80124f:	68 81 00 00 00       	push   $0x81
  801254:	68 67 29 80 00       	push   $0x802967
  801259:	e8 bd f0 ff ff       	call   80031b <_panic>

	if ((r = sys_env_set_status(eid, ENV_RUNNABLE)) < 0)
  80125e:	83 ec 08             	sub    $0x8,%esp
  801261:	6a 02                	push   $0x2
  801263:	ff 75 e0             	pushl  -0x20(%ebp)
  801266:	e8 a4 fc ff ff       	call   800f0f <sys_env_set_status>
  80126b:	83 c4 10             	add    $0x10,%esp
  80126e:	85 c0                	test   %eax,%eax
  801270:	79 7d                	jns    8012ef <fork+0x1c7>
        panic("fork fault 4\n");
  801272:	83 ec 04             	sub    $0x4,%esp
  801275:	68 f0 29 80 00       	push   $0x8029f0
  80127a:	68 84 00 00 00       	push   $0x84
  80127f:	68 67 29 80 00       	push   $0x802967
  801284:	e8 92 f0 ff ff       	call   80031b <_panic>
		perm |= PTE_COW;
	if((r = sys_page_map(myenvid,(void*)(pn*PGSIZE),envid,(void*)(pn*PGSIZE),perm))<0){
		panic("duppage fault :%e\n",r);
	}
	if(perm & PTE_COW){
		if((r = sys_page_map(myenvid,(void*)(pn*PGSIZE),myenvid,(void*)(pn*PGSIZE),perm))<0)
  801289:	83 ec 0c             	sub    $0xc,%esp
  80128c:	68 05 08 00 00       	push   $0x805
  801291:	56                   	push   %esi
  801292:	57                   	push   %edi
  801293:	56                   	push   %esi
  801294:	57                   	push   %edi
  801295:	e8 f1 fb ff ff       	call   800e8b <sys_page_map>
  80129a:	83 c4 20             	add    $0x20,%esp
  80129d:	85 c0                	test   %eax,%eax
  80129f:	0f 89 50 ff ff ff    	jns    8011f5 <fork+0xcd>
  8012a5:	e9 39 ff ff ff       	jmp    8011e3 <fork+0xbb>
	envid_t myenvid = sys_getenvid();
	pte_t pte = uvpt[pn];
	int perm = PTE_U | PTE_P;
	if(pte & PTE_W || pte & PTE_COW)
		perm |= PTE_COW;
	if((r = sys_page_map(myenvid,(void*)(pn*PGSIZE),envid,(void*)(pn*PGSIZE),perm))<0){
  8012aa:	c1 e6 0c             	shl    $0xc,%esi
  8012ad:	83 ec 0c             	sub    $0xc,%esp
  8012b0:	68 05 08 00 00       	push   $0x805
  8012b5:	56                   	push   %esi
  8012b6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8012b9:	56                   	push   %esi
  8012ba:	57                   	push   %edi
  8012bb:	e8 cb fb ff ff       	call   800e8b <sys_page_map>
  8012c0:	83 c4 20             	add    $0x20,%esp
  8012c3:	85 c0                	test   %eax,%eax
  8012c5:	79 c2                	jns    801289 <fork+0x161>
  8012c7:	e9 05 ff ff ff       	jmp    8011d1 <fork+0xa9>
  8012cc:	c1 e6 0c             	shl    $0xc,%esi
  8012cf:	83 ec 0c             	sub    $0xc,%esp
  8012d2:	6a 05                	push   $0x5
  8012d4:	56                   	push   %esi
  8012d5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8012d8:	56                   	push   %esi
  8012d9:	57                   	push   %edi
  8012da:	e8 ac fb ff ff       	call   800e8b <sys_page_map>
  8012df:	83 c4 20             	add    $0x20,%esp
  8012e2:	85 c0                	test   %eax,%eax
  8012e4:	0f 89 0b ff ff ff    	jns    8011f5 <fork+0xcd>
  8012ea:	e9 e2 fe ff ff       	jmp    8011d1 <fork+0xa9>
    if (r < 0) panic("fork fault 3\n");

	if ((r = sys_env_set_status(eid, ENV_RUNNABLE)) < 0)
        panic("fork fault 4\n");
    return eid;
}
  8012ef:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8012f2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012f5:	5b                   	pop    %ebx
  8012f6:	5e                   	pop    %esi
  8012f7:	5f                   	pop    %edi
  8012f8:	5d                   	pop    %ebp
  8012f9:	c3                   	ret    

008012fa <sfork>:

// Challenge!
int
sfork(void)
{
  8012fa:	55                   	push   %ebp
  8012fb:	89 e5                	mov    %esp,%ebp
  8012fd:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801300:	68 fe 29 80 00       	push   $0x8029fe
  801305:	68 8c 00 00 00       	push   $0x8c
  80130a:	68 67 29 80 00       	push   $0x802967
  80130f:	e8 07 f0 ff ff       	call   80031b <_panic>

00801314 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801314:	55                   	push   %ebp
  801315:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801317:	8b 45 08             	mov    0x8(%ebp),%eax
  80131a:	05 00 00 00 30       	add    $0x30000000,%eax
  80131f:	c1 e8 0c             	shr    $0xc,%eax
}
  801322:	5d                   	pop    %ebp
  801323:	c3                   	ret    

00801324 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801324:	55                   	push   %ebp
  801325:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801327:	8b 45 08             	mov    0x8(%ebp),%eax
  80132a:	05 00 00 00 30       	add    $0x30000000,%eax
  80132f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801334:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801339:	5d                   	pop    %ebp
  80133a:	c3                   	ret    

0080133b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80133b:	55                   	push   %ebp
  80133c:	89 e5                	mov    %esp,%ebp
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80133e:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  801343:	a8 01                	test   $0x1,%al
  801345:	74 34                	je     80137b <fd_alloc+0x40>
  801347:	a1 00 00 74 ef       	mov    0xef740000,%eax
  80134c:	a8 01                	test   $0x1,%al
  80134e:	74 32                	je     801382 <fd_alloc+0x47>
  801350:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  801355:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801357:	89 c2                	mov    %eax,%edx
  801359:	c1 ea 16             	shr    $0x16,%edx
  80135c:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801363:	f6 c2 01             	test   $0x1,%dl
  801366:	74 1f                	je     801387 <fd_alloc+0x4c>
  801368:	89 c2                	mov    %eax,%edx
  80136a:	c1 ea 0c             	shr    $0xc,%edx
  80136d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801374:	f6 c2 01             	test   $0x1,%dl
  801377:	75 1a                	jne    801393 <fd_alloc+0x58>
  801379:	eb 0c                	jmp    801387 <fd_alloc+0x4c>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  80137b:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  801380:	eb 05                	jmp    801387 <fd_alloc+0x4c>
  801382:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  801387:	8b 45 08             	mov    0x8(%ebp),%eax
  80138a:	89 08                	mov    %ecx,(%eax)
			return 0;
  80138c:	b8 00 00 00 00       	mov    $0x0,%eax
  801391:	eb 1a                	jmp    8013ad <fd_alloc+0x72>
  801393:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801398:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80139d:	75 b6                	jne    801355 <fd_alloc+0x1a>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80139f:	8b 45 08             	mov    0x8(%ebp),%eax
  8013a2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  8013a8:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8013ad:	5d                   	pop    %ebp
  8013ae:	c3                   	ret    

008013af <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8013af:	55                   	push   %ebp
  8013b0:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8013b2:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
  8013b6:	77 39                	ja     8013f1 <fd_lookup+0x42>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8013b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8013bb:	c1 e0 0c             	shl    $0xc,%eax
  8013be:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8013c3:	89 c2                	mov    %eax,%edx
  8013c5:	c1 ea 16             	shr    $0x16,%edx
  8013c8:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8013cf:	f6 c2 01             	test   $0x1,%dl
  8013d2:	74 24                	je     8013f8 <fd_lookup+0x49>
  8013d4:	89 c2                	mov    %eax,%edx
  8013d6:	c1 ea 0c             	shr    $0xc,%edx
  8013d9:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8013e0:	f6 c2 01             	test   $0x1,%dl
  8013e3:	74 1a                	je     8013ff <fd_lookup+0x50>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8013e5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013e8:	89 02                	mov    %eax,(%edx)
	return 0;
  8013ea:	b8 00 00 00 00       	mov    $0x0,%eax
  8013ef:	eb 13                	jmp    801404 <fd_lookup+0x55>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8013f1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013f6:	eb 0c                	jmp    801404 <fd_lookup+0x55>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8013f8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013fd:	eb 05                	jmp    801404 <fd_lookup+0x55>
  8013ff:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801404:	5d                   	pop    %ebp
  801405:	c3                   	ret    

00801406 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801406:	55                   	push   %ebp
  801407:	89 e5                	mov    %esp,%ebp
  801409:	53                   	push   %ebx
  80140a:	83 ec 04             	sub    $0x4,%esp
  80140d:	8b 45 08             	mov    0x8(%ebp),%eax
  801410:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  801413:	3b 05 08 30 80 00    	cmp    0x803008,%eax
  801419:	75 1e                	jne    801439 <dev_lookup+0x33>
  80141b:	eb 0e                	jmp    80142b <dev_lookup+0x25>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80141d:	b8 24 30 80 00       	mov    $0x803024,%eax
  801422:	eb 0c                	jmp    801430 <dev_lookup+0x2a>
  801424:	b8 40 30 80 00       	mov    $0x803040,%eax
  801429:	eb 05                	jmp    801430 <dev_lookup+0x2a>
  80142b:	b8 08 30 80 00       	mov    $0x803008,%eax
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  801430:	89 03                	mov    %eax,(%ebx)
			return 0;
  801432:	b8 00 00 00 00       	mov    $0x0,%eax
  801437:	eb 36                	jmp    80146f <dev_lookup+0x69>
int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  801439:	3b 05 24 30 80 00    	cmp    0x803024,%eax
  80143f:	74 dc                	je     80141d <dev_lookup+0x17>
  801441:	3b 05 40 30 80 00    	cmp    0x803040,%eax
  801447:	74 db                	je     801424 <dev_lookup+0x1e>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801449:	8b 15 04 40 80 00    	mov    0x804004,%edx
  80144f:	8b 52 48             	mov    0x48(%edx),%edx
  801452:	83 ec 04             	sub    $0x4,%esp
  801455:	50                   	push   %eax
  801456:	52                   	push   %edx
  801457:	68 34 2a 80 00       	push   $0x802a34
  80145c:	e8 92 ef ff ff       	call   8003f3 <cprintf>
	*dev = 0;
  801461:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  801467:	83 c4 10             	add    $0x10,%esp
  80146a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80146f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801472:	c9                   	leave  
  801473:	c3                   	ret    

00801474 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801474:	55                   	push   %ebp
  801475:	89 e5                	mov    %esp,%ebp
  801477:	56                   	push   %esi
  801478:	53                   	push   %ebx
  801479:	83 ec 10             	sub    $0x10,%esp
  80147c:	8b 75 08             	mov    0x8(%ebp),%esi
  80147f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801482:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801485:	50                   	push   %eax
  801486:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80148c:	c1 e8 0c             	shr    $0xc,%eax
  80148f:	50                   	push   %eax
  801490:	e8 1a ff ff ff       	call   8013af <fd_lookup>
  801495:	83 c4 08             	add    $0x8,%esp
  801498:	85 c0                	test   %eax,%eax
  80149a:	78 05                	js     8014a1 <fd_close+0x2d>
	    || fd != fd2)
  80149c:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80149f:	74 06                	je     8014a7 <fd_close+0x33>
		return (must_exist ? r : 0);
  8014a1:	84 db                	test   %bl,%bl
  8014a3:	74 47                	je     8014ec <fd_close+0x78>
  8014a5:	eb 4a                	jmp    8014f1 <fd_close+0x7d>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8014a7:	83 ec 08             	sub    $0x8,%esp
  8014aa:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014ad:	50                   	push   %eax
  8014ae:	ff 36                	pushl  (%esi)
  8014b0:	e8 51 ff ff ff       	call   801406 <dev_lookup>
  8014b5:	89 c3                	mov    %eax,%ebx
  8014b7:	83 c4 10             	add    $0x10,%esp
  8014ba:	85 c0                	test   %eax,%eax
  8014bc:	78 1c                	js     8014da <fd_close+0x66>
		if (dev->dev_close)
  8014be:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014c1:	8b 40 10             	mov    0x10(%eax),%eax
  8014c4:	85 c0                	test   %eax,%eax
  8014c6:	74 0d                	je     8014d5 <fd_close+0x61>
			r = (*dev->dev_close)(fd);
  8014c8:	83 ec 0c             	sub    $0xc,%esp
  8014cb:	56                   	push   %esi
  8014cc:	ff d0                	call   *%eax
  8014ce:	89 c3                	mov    %eax,%ebx
  8014d0:	83 c4 10             	add    $0x10,%esp
  8014d3:	eb 05                	jmp    8014da <fd_close+0x66>
		else
			r = 0;
  8014d5:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8014da:	83 ec 08             	sub    $0x8,%esp
  8014dd:	56                   	push   %esi
  8014de:	6a 00                	push   $0x0
  8014e0:	e8 e8 f9 ff ff       	call   800ecd <sys_page_unmap>
	return r;
  8014e5:	83 c4 10             	add    $0x10,%esp
  8014e8:	89 d8                	mov    %ebx,%eax
  8014ea:	eb 05                	jmp    8014f1 <fd_close+0x7d>
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
  8014ec:	b8 00 00 00 00       	mov    $0x0,%eax
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
	return r;
}
  8014f1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014f4:	5b                   	pop    %ebx
  8014f5:	5e                   	pop    %esi
  8014f6:	5d                   	pop    %ebp
  8014f7:	c3                   	ret    

008014f8 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8014f8:	55                   	push   %ebp
  8014f9:	89 e5                	mov    %esp,%ebp
  8014fb:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014fe:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801501:	50                   	push   %eax
  801502:	ff 75 08             	pushl  0x8(%ebp)
  801505:	e8 a5 fe ff ff       	call   8013af <fd_lookup>
  80150a:	83 c4 08             	add    $0x8,%esp
  80150d:	85 c0                	test   %eax,%eax
  80150f:	78 10                	js     801521 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801511:	83 ec 08             	sub    $0x8,%esp
  801514:	6a 01                	push   $0x1
  801516:	ff 75 f4             	pushl  -0xc(%ebp)
  801519:	e8 56 ff ff ff       	call   801474 <fd_close>
  80151e:	83 c4 10             	add    $0x10,%esp
}
  801521:	c9                   	leave  
  801522:	c3                   	ret    

00801523 <close_all>:

void
close_all(void)
{
  801523:	55                   	push   %ebp
  801524:	89 e5                	mov    %esp,%ebp
  801526:	53                   	push   %ebx
  801527:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80152a:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80152f:	83 ec 0c             	sub    $0xc,%esp
  801532:	53                   	push   %ebx
  801533:	e8 c0 ff ff ff       	call   8014f8 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801538:	43                   	inc    %ebx
  801539:	83 c4 10             	add    $0x10,%esp
  80153c:	83 fb 20             	cmp    $0x20,%ebx
  80153f:	75 ee                	jne    80152f <close_all+0xc>
		close(i);
}
  801541:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801544:	c9                   	leave  
  801545:	c3                   	ret    

00801546 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801546:	55                   	push   %ebp
  801547:	89 e5                	mov    %esp,%ebp
  801549:	57                   	push   %edi
  80154a:	56                   	push   %esi
  80154b:	53                   	push   %ebx
  80154c:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80154f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801552:	50                   	push   %eax
  801553:	ff 75 08             	pushl  0x8(%ebp)
  801556:	e8 54 fe ff ff       	call   8013af <fd_lookup>
  80155b:	83 c4 08             	add    $0x8,%esp
  80155e:	85 c0                	test   %eax,%eax
  801560:	0f 88 c2 00 00 00    	js     801628 <dup+0xe2>
		return r;
	close(newfdnum);
  801566:	83 ec 0c             	sub    $0xc,%esp
  801569:	ff 75 0c             	pushl  0xc(%ebp)
  80156c:	e8 87 ff ff ff       	call   8014f8 <close>

	newfd = INDEX2FD(newfdnum);
  801571:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801574:	c1 e3 0c             	shl    $0xc,%ebx
  801577:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80157d:	83 c4 04             	add    $0x4,%esp
  801580:	ff 75 e4             	pushl  -0x1c(%ebp)
  801583:	e8 9c fd ff ff       	call   801324 <fd2data>
  801588:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  80158a:	89 1c 24             	mov    %ebx,(%esp)
  80158d:	e8 92 fd ff ff       	call   801324 <fd2data>
  801592:	83 c4 10             	add    $0x10,%esp
  801595:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801597:	89 f0                	mov    %esi,%eax
  801599:	c1 e8 16             	shr    $0x16,%eax
  80159c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8015a3:	a8 01                	test   $0x1,%al
  8015a5:	74 35                	je     8015dc <dup+0x96>
  8015a7:	89 f0                	mov    %esi,%eax
  8015a9:	c1 e8 0c             	shr    $0xc,%eax
  8015ac:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8015b3:	f6 c2 01             	test   $0x1,%dl
  8015b6:	74 24                	je     8015dc <dup+0x96>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8015b8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8015bf:	83 ec 0c             	sub    $0xc,%esp
  8015c2:	25 07 0e 00 00       	and    $0xe07,%eax
  8015c7:	50                   	push   %eax
  8015c8:	57                   	push   %edi
  8015c9:	6a 00                	push   $0x0
  8015cb:	56                   	push   %esi
  8015cc:	6a 00                	push   $0x0
  8015ce:	e8 b8 f8 ff ff       	call   800e8b <sys_page_map>
  8015d3:	89 c6                	mov    %eax,%esi
  8015d5:	83 c4 20             	add    $0x20,%esp
  8015d8:	85 c0                	test   %eax,%eax
  8015da:	78 2c                	js     801608 <dup+0xc2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8015dc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8015df:	89 d0                	mov    %edx,%eax
  8015e1:	c1 e8 0c             	shr    $0xc,%eax
  8015e4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8015eb:	83 ec 0c             	sub    $0xc,%esp
  8015ee:	25 07 0e 00 00       	and    $0xe07,%eax
  8015f3:	50                   	push   %eax
  8015f4:	53                   	push   %ebx
  8015f5:	6a 00                	push   $0x0
  8015f7:	52                   	push   %edx
  8015f8:	6a 00                	push   $0x0
  8015fa:	e8 8c f8 ff ff       	call   800e8b <sys_page_map>
  8015ff:	89 c6                	mov    %eax,%esi
  801601:	83 c4 20             	add    $0x20,%esp
  801604:	85 c0                	test   %eax,%eax
  801606:	79 1d                	jns    801625 <dup+0xdf>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801608:	83 ec 08             	sub    $0x8,%esp
  80160b:	53                   	push   %ebx
  80160c:	6a 00                	push   $0x0
  80160e:	e8 ba f8 ff ff       	call   800ecd <sys_page_unmap>
	sys_page_unmap(0, nva);
  801613:	83 c4 08             	add    $0x8,%esp
  801616:	57                   	push   %edi
  801617:	6a 00                	push   $0x0
  801619:	e8 af f8 ff ff       	call   800ecd <sys_page_unmap>
	return r;
  80161e:	83 c4 10             	add    $0x10,%esp
  801621:	89 f0                	mov    %esi,%eax
  801623:	eb 03                	jmp    801628 <dup+0xe2>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801625:	8b 45 0c             	mov    0xc(%ebp),%eax

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801628:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80162b:	5b                   	pop    %ebx
  80162c:	5e                   	pop    %esi
  80162d:	5f                   	pop    %edi
  80162e:	5d                   	pop    %ebp
  80162f:	c3                   	ret    

00801630 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801630:	55                   	push   %ebp
  801631:	89 e5                	mov    %esp,%ebp
  801633:	53                   	push   %ebx
  801634:	83 ec 14             	sub    $0x14,%esp
  801637:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80163a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80163d:	50                   	push   %eax
  80163e:	53                   	push   %ebx
  80163f:	e8 6b fd ff ff       	call   8013af <fd_lookup>
  801644:	83 c4 08             	add    $0x8,%esp
  801647:	85 c0                	test   %eax,%eax
  801649:	78 67                	js     8016b2 <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80164b:	83 ec 08             	sub    $0x8,%esp
  80164e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801651:	50                   	push   %eax
  801652:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801655:	ff 30                	pushl  (%eax)
  801657:	e8 aa fd ff ff       	call   801406 <dev_lookup>
  80165c:	83 c4 10             	add    $0x10,%esp
  80165f:	85 c0                	test   %eax,%eax
  801661:	78 4f                	js     8016b2 <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801663:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801666:	8b 42 08             	mov    0x8(%edx),%eax
  801669:	83 e0 03             	and    $0x3,%eax
  80166c:	83 f8 01             	cmp    $0x1,%eax
  80166f:	75 21                	jne    801692 <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801671:	a1 04 40 80 00       	mov    0x804004,%eax
  801676:	8b 40 48             	mov    0x48(%eax),%eax
  801679:	83 ec 04             	sub    $0x4,%esp
  80167c:	53                   	push   %ebx
  80167d:	50                   	push   %eax
  80167e:	68 78 2a 80 00       	push   $0x802a78
  801683:	e8 6b ed ff ff       	call   8003f3 <cprintf>
		return -E_INVAL;
  801688:	83 c4 10             	add    $0x10,%esp
  80168b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801690:	eb 20                	jmp    8016b2 <read+0x82>
	}
	if (!dev->dev_read)
  801692:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801695:	8b 40 08             	mov    0x8(%eax),%eax
  801698:	85 c0                	test   %eax,%eax
  80169a:	74 11                	je     8016ad <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80169c:	83 ec 04             	sub    $0x4,%esp
  80169f:	ff 75 10             	pushl  0x10(%ebp)
  8016a2:	ff 75 0c             	pushl  0xc(%ebp)
  8016a5:	52                   	push   %edx
  8016a6:	ff d0                	call   *%eax
  8016a8:	83 c4 10             	add    $0x10,%esp
  8016ab:	eb 05                	jmp    8016b2 <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8016ad:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8016b2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016b5:	c9                   	leave  
  8016b6:	c3                   	ret    

008016b7 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8016b7:	55                   	push   %ebp
  8016b8:	89 e5                	mov    %esp,%ebp
  8016ba:	57                   	push   %edi
  8016bb:	56                   	push   %esi
  8016bc:	53                   	push   %ebx
  8016bd:	83 ec 0c             	sub    $0xc,%esp
  8016c0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8016c3:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8016c6:	85 f6                	test   %esi,%esi
  8016c8:	74 31                	je     8016fb <readn+0x44>
  8016ca:	b8 00 00 00 00       	mov    $0x0,%eax
  8016cf:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  8016d4:	83 ec 04             	sub    $0x4,%esp
  8016d7:	89 f2                	mov    %esi,%edx
  8016d9:	29 c2                	sub    %eax,%edx
  8016db:	52                   	push   %edx
  8016dc:	03 45 0c             	add    0xc(%ebp),%eax
  8016df:	50                   	push   %eax
  8016e0:	57                   	push   %edi
  8016e1:	e8 4a ff ff ff       	call   801630 <read>
		if (m < 0)
  8016e6:	83 c4 10             	add    $0x10,%esp
  8016e9:	85 c0                	test   %eax,%eax
  8016eb:	78 17                	js     801704 <readn+0x4d>
			return m;
		if (m == 0)
  8016ed:	85 c0                	test   %eax,%eax
  8016ef:	74 11                	je     801702 <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8016f1:	01 c3                	add    %eax,%ebx
  8016f3:	89 d8                	mov    %ebx,%eax
  8016f5:	39 f3                	cmp    %esi,%ebx
  8016f7:	72 db                	jb     8016d4 <readn+0x1d>
  8016f9:	eb 09                	jmp    801704 <readn+0x4d>
  8016fb:	b8 00 00 00 00       	mov    $0x0,%eax
  801700:	eb 02                	jmp    801704 <readn+0x4d>
  801702:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801704:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801707:	5b                   	pop    %ebx
  801708:	5e                   	pop    %esi
  801709:	5f                   	pop    %edi
  80170a:	5d                   	pop    %ebp
  80170b:	c3                   	ret    

0080170c <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80170c:	55                   	push   %ebp
  80170d:	89 e5                	mov    %esp,%ebp
  80170f:	53                   	push   %ebx
  801710:	83 ec 14             	sub    $0x14,%esp
  801713:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801716:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801719:	50                   	push   %eax
  80171a:	53                   	push   %ebx
  80171b:	e8 8f fc ff ff       	call   8013af <fd_lookup>
  801720:	83 c4 08             	add    $0x8,%esp
  801723:	85 c0                	test   %eax,%eax
  801725:	78 62                	js     801789 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801727:	83 ec 08             	sub    $0x8,%esp
  80172a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80172d:	50                   	push   %eax
  80172e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801731:	ff 30                	pushl  (%eax)
  801733:	e8 ce fc ff ff       	call   801406 <dev_lookup>
  801738:	83 c4 10             	add    $0x10,%esp
  80173b:	85 c0                	test   %eax,%eax
  80173d:	78 4a                	js     801789 <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80173f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801742:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801746:	75 21                	jne    801769 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801748:	a1 04 40 80 00       	mov    0x804004,%eax
  80174d:	8b 40 48             	mov    0x48(%eax),%eax
  801750:	83 ec 04             	sub    $0x4,%esp
  801753:	53                   	push   %ebx
  801754:	50                   	push   %eax
  801755:	68 94 2a 80 00       	push   $0x802a94
  80175a:	e8 94 ec ff ff       	call   8003f3 <cprintf>
		return -E_INVAL;
  80175f:	83 c4 10             	add    $0x10,%esp
  801762:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801767:	eb 20                	jmp    801789 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801769:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80176c:	8b 52 0c             	mov    0xc(%edx),%edx
  80176f:	85 d2                	test   %edx,%edx
  801771:	74 11                	je     801784 <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801773:	83 ec 04             	sub    $0x4,%esp
  801776:	ff 75 10             	pushl  0x10(%ebp)
  801779:	ff 75 0c             	pushl  0xc(%ebp)
  80177c:	50                   	push   %eax
  80177d:	ff d2                	call   *%edx
  80177f:	83 c4 10             	add    $0x10,%esp
  801782:	eb 05                	jmp    801789 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801784:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801789:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80178c:	c9                   	leave  
  80178d:	c3                   	ret    

0080178e <seek>:

int
seek(int fdnum, off_t offset)
{
  80178e:	55                   	push   %ebp
  80178f:	89 e5                	mov    %esp,%ebp
  801791:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801794:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801797:	50                   	push   %eax
  801798:	ff 75 08             	pushl  0x8(%ebp)
  80179b:	e8 0f fc ff ff       	call   8013af <fd_lookup>
  8017a0:	83 c4 08             	add    $0x8,%esp
  8017a3:	85 c0                	test   %eax,%eax
  8017a5:	78 0e                	js     8017b5 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8017a7:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8017aa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017ad:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8017b0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017b5:	c9                   	leave  
  8017b6:	c3                   	ret    

008017b7 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8017b7:	55                   	push   %ebp
  8017b8:	89 e5                	mov    %esp,%ebp
  8017ba:	53                   	push   %ebx
  8017bb:	83 ec 14             	sub    $0x14,%esp
  8017be:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017c1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017c4:	50                   	push   %eax
  8017c5:	53                   	push   %ebx
  8017c6:	e8 e4 fb ff ff       	call   8013af <fd_lookup>
  8017cb:	83 c4 08             	add    $0x8,%esp
  8017ce:	85 c0                	test   %eax,%eax
  8017d0:	78 5f                	js     801831 <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017d2:	83 ec 08             	sub    $0x8,%esp
  8017d5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017d8:	50                   	push   %eax
  8017d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017dc:	ff 30                	pushl  (%eax)
  8017de:	e8 23 fc ff ff       	call   801406 <dev_lookup>
  8017e3:	83 c4 10             	add    $0x10,%esp
  8017e6:	85 c0                	test   %eax,%eax
  8017e8:	78 47                	js     801831 <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8017ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017ed:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8017f1:	75 21                	jne    801814 <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8017f3:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8017f8:	8b 40 48             	mov    0x48(%eax),%eax
  8017fb:	83 ec 04             	sub    $0x4,%esp
  8017fe:	53                   	push   %ebx
  8017ff:	50                   	push   %eax
  801800:	68 54 2a 80 00       	push   $0x802a54
  801805:	e8 e9 eb ff ff       	call   8003f3 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80180a:	83 c4 10             	add    $0x10,%esp
  80180d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801812:	eb 1d                	jmp    801831 <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  801814:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801817:	8b 52 18             	mov    0x18(%edx),%edx
  80181a:	85 d2                	test   %edx,%edx
  80181c:	74 0e                	je     80182c <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80181e:	83 ec 08             	sub    $0x8,%esp
  801821:	ff 75 0c             	pushl  0xc(%ebp)
  801824:	50                   	push   %eax
  801825:	ff d2                	call   *%edx
  801827:	83 c4 10             	add    $0x10,%esp
  80182a:	eb 05                	jmp    801831 <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80182c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801831:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801834:	c9                   	leave  
  801835:	c3                   	ret    

00801836 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801836:	55                   	push   %ebp
  801837:	89 e5                	mov    %esp,%ebp
  801839:	53                   	push   %ebx
  80183a:	83 ec 14             	sub    $0x14,%esp
  80183d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801840:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801843:	50                   	push   %eax
  801844:	ff 75 08             	pushl  0x8(%ebp)
  801847:	e8 63 fb ff ff       	call   8013af <fd_lookup>
  80184c:	83 c4 08             	add    $0x8,%esp
  80184f:	85 c0                	test   %eax,%eax
  801851:	78 52                	js     8018a5 <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801853:	83 ec 08             	sub    $0x8,%esp
  801856:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801859:	50                   	push   %eax
  80185a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80185d:	ff 30                	pushl  (%eax)
  80185f:	e8 a2 fb ff ff       	call   801406 <dev_lookup>
  801864:	83 c4 10             	add    $0x10,%esp
  801867:	85 c0                	test   %eax,%eax
  801869:	78 3a                	js     8018a5 <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  80186b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80186e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801872:	74 2c                	je     8018a0 <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801874:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801877:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80187e:	00 00 00 
	stat->st_isdir = 0;
  801881:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801888:	00 00 00 
	stat->st_dev = dev;
  80188b:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801891:	83 ec 08             	sub    $0x8,%esp
  801894:	53                   	push   %ebx
  801895:	ff 75 f0             	pushl  -0x10(%ebp)
  801898:	ff 50 14             	call   *0x14(%eax)
  80189b:	83 c4 10             	add    $0x10,%esp
  80189e:	eb 05                	jmp    8018a5 <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8018a0:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8018a5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018a8:	c9                   	leave  
  8018a9:	c3                   	ret    

008018aa <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8018aa:	55                   	push   %ebp
  8018ab:	89 e5                	mov    %esp,%ebp
  8018ad:	56                   	push   %esi
  8018ae:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8018af:	83 ec 08             	sub    $0x8,%esp
  8018b2:	6a 00                	push   $0x0
  8018b4:	ff 75 08             	pushl  0x8(%ebp)
  8018b7:	e8 75 01 00 00       	call   801a31 <open>
  8018bc:	89 c3                	mov    %eax,%ebx
  8018be:	83 c4 10             	add    $0x10,%esp
  8018c1:	85 c0                	test   %eax,%eax
  8018c3:	78 1d                	js     8018e2 <stat+0x38>
		return fd;
	r = fstat(fd, stat);
  8018c5:	83 ec 08             	sub    $0x8,%esp
  8018c8:	ff 75 0c             	pushl  0xc(%ebp)
  8018cb:	50                   	push   %eax
  8018cc:	e8 65 ff ff ff       	call   801836 <fstat>
  8018d1:	89 c6                	mov    %eax,%esi
	close(fd);
  8018d3:	89 1c 24             	mov    %ebx,(%esp)
  8018d6:	e8 1d fc ff ff       	call   8014f8 <close>
	return r;
  8018db:	83 c4 10             	add    $0x10,%esp
  8018de:	89 f0                	mov    %esi,%eax
  8018e0:	eb 00                	jmp    8018e2 <stat+0x38>
}
  8018e2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018e5:	5b                   	pop    %ebx
  8018e6:	5e                   	pop    %esi
  8018e7:	5d                   	pop    %ebp
  8018e8:	c3                   	ret    

008018e9 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8018e9:	55                   	push   %ebp
  8018ea:	89 e5                	mov    %esp,%ebp
  8018ec:	56                   	push   %esi
  8018ed:	53                   	push   %ebx
  8018ee:	89 c6                	mov    %eax,%esi
  8018f0:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8018f2:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8018f9:	75 12                	jne    80190d <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8018fb:	83 ec 0c             	sub    $0xc,%esp
  8018fe:	6a 01                	push   $0x1
  801900:	e8 95 08 00 00       	call   80219a <ipc_find_env>
  801905:	a3 00 40 80 00       	mov    %eax,0x804000
  80190a:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80190d:	6a 07                	push   $0x7
  80190f:	68 00 50 80 00       	push   $0x805000
  801914:	56                   	push   %esi
  801915:	ff 35 00 40 80 00    	pushl  0x804000
  80191b:	e8 1b 08 00 00       	call   80213b <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801920:	83 c4 0c             	add    $0xc,%esp
  801923:	6a 00                	push   $0x0
  801925:	53                   	push   %ebx
  801926:	6a 00                	push   $0x0
  801928:	e8 99 07 00 00       	call   8020c6 <ipc_recv>
}
  80192d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801930:	5b                   	pop    %ebx
  801931:	5e                   	pop    %esi
  801932:	5d                   	pop    %ebp
  801933:	c3                   	ret    

00801934 <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801934:	55                   	push   %ebp
  801935:	89 e5                	mov    %esp,%ebp
  801937:	53                   	push   %ebx
  801938:	83 ec 04             	sub    $0x4,%esp
  80193b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80193e:	8b 45 08             	mov    0x8(%ebp),%eax
  801941:	8b 40 0c             	mov    0xc(%eax),%eax
  801944:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801949:	ba 00 00 00 00       	mov    $0x0,%edx
  80194e:	b8 05 00 00 00       	mov    $0x5,%eax
  801953:	e8 91 ff ff ff       	call   8018e9 <fsipc>
  801958:	85 c0                	test   %eax,%eax
  80195a:	78 2c                	js     801988 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80195c:	83 ec 08             	sub    $0x8,%esp
  80195f:	68 00 50 80 00       	push   $0x805000
  801964:	53                   	push   %ebx
  801965:	e8 6e f0 ff ff       	call   8009d8 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80196a:	a1 80 50 80 00       	mov    0x805080,%eax
  80196f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801975:	a1 84 50 80 00       	mov    0x805084,%eax
  80197a:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801980:	83 c4 10             	add    $0x10,%esp
  801983:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801988:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80198b:	c9                   	leave  
  80198c:	c3                   	ret    

0080198d <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80198d:	55                   	push   %ebp
  80198e:	89 e5                	mov    %esp,%ebp
  801990:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801993:	8b 45 08             	mov    0x8(%ebp),%eax
  801996:	8b 40 0c             	mov    0xc(%eax),%eax
  801999:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80199e:	ba 00 00 00 00       	mov    $0x0,%edx
  8019a3:	b8 06 00 00 00       	mov    $0x6,%eax
  8019a8:	e8 3c ff ff ff       	call   8018e9 <fsipc>
}
  8019ad:	c9                   	leave  
  8019ae:	c3                   	ret    

008019af <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8019af:	55                   	push   %ebp
  8019b0:	89 e5                	mov    %esp,%ebp
  8019b2:	56                   	push   %esi
  8019b3:	53                   	push   %ebx
  8019b4:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8019b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8019ba:	8b 40 0c             	mov    0xc(%eax),%eax
  8019bd:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8019c2:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8019c8:	ba 00 00 00 00       	mov    $0x0,%edx
  8019cd:	b8 03 00 00 00       	mov    $0x3,%eax
  8019d2:	e8 12 ff ff ff       	call   8018e9 <fsipc>
  8019d7:	89 c3                	mov    %eax,%ebx
  8019d9:	85 c0                	test   %eax,%eax
  8019db:	78 4b                	js     801a28 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8019dd:	39 c6                	cmp    %eax,%esi
  8019df:	73 16                	jae    8019f7 <devfile_read+0x48>
  8019e1:	68 b1 2a 80 00       	push   $0x802ab1
  8019e6:	68 b8 2a 80 00       	push   $0x802ab8
  8019eb:	6a 7a                	push   $0x7a
  8019ed:	68 cd 2a 80 00       	push   $0x802acd
  8019f2:	e8 24 e9 ff ff       	call   80031b <_panic>
	assert(r <= PGSIZE);
  8019f7:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8019fc:	7e 16                	jle    801a14 <devfile_read+0x65>
  8019fe:	68 d8 2a 80 00       	push   $0x802ad8
  801a03:	68 b8 2a 80 00       	push   $0x802ab8
  801a08:	6a 7b                	push   $0x7b
  801a0a:	68 cd 2a 80 00       	push   $0x802acd
  801a0f:	e8 07 e9 ff ff       	call   80031b <_panic>
	memmove(buf, &fsipcbuf, r);
  801a14:	83 ec 04             	sub    $0x4,%esp
  801a17:	50                   	push   %eax
  801a18:	68 00 50 80 00       	push   $0x805000
  801a1d:	ff 75 0c             	pushl  0xc(%ebp)
  801a20:	e8 80 f1 ff ff       	call   800ba5 <memmove>
	return r;
  801a25:	83 c4 10             	add    $0x10,%esp
}
  801a28:	89 d8                	mov    %ebx,%eax
  801a2a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a2d:	5b                   	pop    %ebx
  801a2e:	5e                   	pop    %esi
  801a2f:	5d                   	pop    %ebp
  801a30:	c3                   	ret    

00801a31 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801a31:	55                   	push   %ebp
  801a32:	89 e5                	mov    %esp,%ebp
  801a34:	53                   	push   %ebx
  801a35:	83 ec 20             	sub    $0x20,%esp
  801a38:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801a3b:	53                   	push   %ebx
  801a3c:	e8 40 ef ff ff       	call   800981 <strlen>
  801a41:	83 c4 10             	add    $0x10,%esp
  801a44:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801a49:	7f 63                	jg     801aae <open+0x7d>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a4b:	83 ec 0c             	sub    $0xc,%esp
  801a4e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a51:	50                   	push   %eax
  801a52:	e8 e4 f8 ff ff       	call   80133b <fd_alloc>
  801a57:	83 c4 10             	add    $0x10,%esp
  801a5a:	85 c0                	test   %eax,%eax
  801a5c:	78 55                	js     801ab3 <open+0x82>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801a5e:	83 ec 08             	sub    $0x8,%esp
  801a61:	53                   	push   %ebx
  801a62:	68 00 50 80 00       	push   $0x805000
  801a67:	e8 6c ef ff ff       	call   8009d8 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801a6c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a6f:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801a74:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a77:	b8 01 00 00 00       	mov    $0x1,%eax
  801a7c:	e8 68 fe ff ff       	call   8018e9 <fsipc>
  801a81:	89 c3                	mov    %eax,%ebx
  801a83:	83 c4 10             	add    $0x10,%esp
  801a86:	85 c0                	test   %eax,%eax
  801a88:	79 14                	jns    801a9e <open+0x6d>
		fd_close(fd, 0);
  801a8a:	83 ec 08             	sub    $0x8,%esp
  801a8d:	6a 00                	push   $0x0
  801a8f:	ff 75 f4             	pushl  -0xc(%ebp)
  801a92:	e8 dd f9 ff ff       	call   801474 <fd_close>
		return r;
  801a97:	83 c4 10             	add    $0x10,%esp
  801a9a:	89 d8                	mov    %ebx,%eax
  801a9c:	eb 15                	jmp    801ab3 <open+0x82>
	}

	return fd2num(fd);
  801a9e:	83 ec 0c             	sub    $0xc,%esp
  801aa1:	ff 75 f4             	pushl  -0xc(%ebp)
  801aa4:	e8 6b f8 ff ff       	call   801314 <fd2num>
  801aa9:	83 c4 10             	add    $0x10,%esp
  801aac:	eb 05                	jmp    801ab3 <open+0x82>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801aae:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801ab3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ab6:	c9                   	leave  
  801ab7:	c3                   	ret    

00801ab8 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801ab8:	55                   	push   %ebp
  801ab9:	89 e5                	mov    %esp,%ebp
  801abb:	56                   	push   %esi
  801abc:	53                   	push   %ebx
  801abd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801ac0:	83 ec 0c             	sub    $0xc,%esp
  801ac3:	ff 75 08             	pushl  0x8(%ebp)
  801ac6:	e8 59 f8 ff ff       	call   801324 <fd2data>
  801acb:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801acd:	83 c4 08             	add    $0x8,%esp
  801ad0:	68 e4 2a 80 00       	push   $0x802ae4
  801ad5:	53                   	push   %ebx
  801ad6:	e8 fd ee ff ff       	call   8009d8 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801adb:	8b 46 04             	mov    0x4(%esi),%eax
  801ade:	2b 06                	sub    (%esi),%eax
  801ae0:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801ae6:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801aed:	00 00 00 
	stat->st_dev = &devpipe;
  801af0:	c7 83 88 00 00 00 24 	movl   $0x803024,0x88(%ebx)
  801af7:	30 80 00 
	return 0;
}
  801afa:	b8 00 00 00 00       	mov    $0x0,%eax
  801aff:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b02:	5b                   	pop    %ebx
  801b03:	5e                   	pop    %esi
  801b04:	5d                   	pop    %ebp
  801b05:	c3                   	ret    

00801b06 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801b06:	55                   	push   %ebp
  801b07:	89 e5                	mov    %esp,%ebp
  801b09:	53                   	push   %ebx
  801b0a:	83 ec 0c             	sub    $0xc,%esp
  801b0d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801b10:	53                   	push   %ebx
  801b11:	6a 00                	push   $0x0
  801b13:	e8 b5 f3 ff ff       	call   800ecd <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801b18:	89 1c 24             	mov    %ebx,(%esp)
  801b1b:	e8 04 f8 ff ff       	call   801324 <fd2data>
  801b20:	83 c4 08             	add    $0x8,%esp
  801b23:	50                   	push   %eax
  801b24:	6a 00                	push   $0x0
  801b26:	e8 a2 f3 ff ff       	call   800ecd <sys_page_unmap>
}
  801b2b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b2e:	c9                   	leave  
  801b2f:	c3                   	ret    

00801b30 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801b30:	55                   	push   %ebp
  801b31:	89 e5                	mov    %esp,%ebp
  801b33:	57                   	push   %edi
  801b34:	56                   	push   %esi
  801b35:	53                   	push   %ebx
  801b36:	83 ec 1c             	sub    $0x1c,%esp
  801b39:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801b3c:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801b3e:	a1 04 40 80 00       	mov    0x804004,%eax
  801b43:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801b46:	83 ec 0c             	sub    $0xc,%esp
  801b49:	ff 75 e0             	pushl  -0x20(%ebp)
  801b4c:	e8 a4 06 00 00       	call   8021f5 <pageref>
  801b51:	89 c3                	mov    %eax,%ebx
  801b53:	89 3c 24             	mov    %edi,(%esp)
  801b56:	e8 9a 06 00 00       	call   8021f5 <pageref>
  801b5b:	83 c4 10             	add    $0x10,%esp
  801b5e:	39 c3                	cmp    %eax,%ebx
  801b60:	0f 94 c1             	sete   %cl
  801b63:	0f b6 c9             	movzbl %cl,%ecx
  801b66:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801b69:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801b6f:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801b72:	39 ce                	cmp    %ecx,%esi
  801b74:	74 1b                	je     801b91 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801b76:	39 c3                	cmp    %eax,%ebx
  801b78:	75 c4                	jne    801b3e <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801b7a:	8b 42 58             	mov    0x58(%edx),%eax
  801b7d:	ff 75 e4             	pushl  -0x1c(%ebp)
  801b80:	50                   	push   %eax
  801b81:	56                   	push   %esi
  801b82:	68 eb 2a 80 00       	push   $0x802aeb
  801b87:	e8 67 e8 ff ff       	call   8003f3 <cprintf>
  801b8c:	83 c4 10             	add    $0x10,%esp
  801b8f:	eb ad                	jmp    801b3e <_pipeisclosed+0xe>
	}
}
  801b91:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b94:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b97:	5b                   	pop    %ebx
  801b98:	5e                   	pop    %esi
  801b99:	5f                   	pop    %edi
  801b9a:	5d                   	pop    %ebp
  801b9b:	c3                   	ret    

00801b9c <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801b9c:	55                   	push   %ebp
  801b9d:	89 e5                	mov    %esp,%ebp
  801b9f:	57                   	push   %edi
  801ba0:	56                   	push   %esi
  801ba1:	53                   	push   %ebx
  801ba2:	83 ec 18             	sub    $0x18,%esp
  801ba5:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801ba8:	56                   	push   %esi
  801ba9:	e8 76 f7 ff ff       	call   801324 <fd2data>
  801bae:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bb0:	83 c4 10             	add    $0x10,%esp
  801bb3:	bf 00 00 00 00       	mov    $0x0,%edi
  801bb8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801bbc:	75 42                	jne    801c00 <devpipe_write+0x64>
  801bbe:	eb 4e                	jmp    801c0e <devpipe_write+0x72>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801bc0:	89 da                	mov    %ebx,%edx
  801bc2:	89 f0                	mov    %esi,%eax
  801bc4:	e8 67 ff ff ff       	call   801b30 <_pipeisclosed>
  801bc9:	85 c0                	test   %eax,%eax
  801bcb:	75 46                	jne    801c13 <devpipe_write+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801bcd:	e8 57 f2 ff ff       	call   800e29 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801bd2:	8b 53 04             	mov    0x4(%ebx),%edx
  801bd5:	8b 03                	mov    (%ebx),%eax
  801bd7:	83 c0 20             	add    $0x20,%eax
  801bda:	39 c2                	cmp    %eax,%edx
  801bdc:	73 e2                	jae    801bc0 <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801bde:	8b 45 0c             	mov    0xc(%ebp),%eax
  801be1:	8a 0c 38             	mov    (%eax,%edi,1),%cl
  801be4:	89 d0                	mov    %edx,%eax
  801be6:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801beb:	79 05                	jns    801bf2 <devpipe_write+0x56>
  801bed:	48                   	dec    %eax
  801bee:	83 c8 e0             	or     $0xffffffe0,%eax
  801bf1:	40                   	inc    %eax
  801bf2:	88 4c 03 08          	mov    %cl,0x8(%ebx,%eax,1)
		p->p_wpos++;
  801bf6:	42                   	inc    %edx
  801bf7:	89 53 04             	mov    %edx,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bfa:	47                   	inc    %edi
  801bfb:	39 7d 10             	cmp    %edi,0x10(%ebp)
  801bfe:	74 0e                	je     801c0e <devpipe_write+0x72>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801c00:	8b 53 04             	mov    0x4(%ebx),%edx
  801c03:	8b 03                	mov    (%ebx),%eax
  801c05:	83 c0 20             	add    $0x20,%eax
  801c08:	39 c2                	cmp    %eax,%edx
  801c0a:	73 b4                	jae    801bc0 <devpipe_write+0x24>
  801c0c:	eb d0                	jmp    801bde <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801c0e:	8b 45 10             	mov    0x10(%ebp),%eax
  801c11:	eb 05                	jmp    801c18 <devpipe_write+0x7c>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c13:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801c18:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c1b:	5b                   	pop    %ebx
  801c1c:	5e                   	pop    %esi
  801c1d:	5f                   	pop    %edi
  801c1e:	5d                   	pop    %ebp
  801c1f:	c3                   	ret    

00801c20 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c20:	55                   	push   %ebp
  801c21:	89 e5                	mov    %esp,%ebp
  801c23:	57                   	push   %edi
  801c24:	56                   	push   %esi
  801c25:	53                   	push   %ebx
  801c26:	83 ec 18             	sub    $0x18,%esp
  801c29:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801c2c:	57                   	push   %edi
  801c2d:	e8 f2 f6 ff ff       	call   801324 <fd2data>
  801c32:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c34:	83 c4 10             	add    $0x10,%esp
  801c37:	be 00 00 00 00       	mov    $0x0,%esi
  801c3c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801c40:	75 3d                	jne    801c7f <devpipe_read+0x5f>
  801c42:	eb 48                	jmp    801c8c <devpipe_read+0x6c>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  801c44:	89 f0                	mov    %esi,%eax
  801c46:	eb 4e                	jmp    801c96 <devpipe_read+0x76>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801c48:	89 da                	mov    %ebx,%edx
  801c4a:	89 f8                	mov    %edi,%eax
  801c4c:	e8 df fe ff ff       	call   801b30 <_pipeisclosed>
  801c51:	85 c0                	test   %eax,%eax
  801c53:	75 3c                	jne    801c91 <devpipe_read+0x71>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801c55:	e8 cf f1 ff ff       	call   800e29 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801c5a:	8b 03                	mov    (%ebx),%eax
  801c5c:	3b 43 04             	cmp    0x4(%ebx),%eax
  801c5f:	74 e7                	je     801c48 <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801c61:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801c66:	79 05                	jns    801c6d <devpipe_read+0x4d>
  801c68:	48                   	dec    %eax
  801c69:	83 c8 e0             	or     $0xffffffe0,%eax
  801c6c:	40                   	inc    %eax
  801c6d:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801c71:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c74:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801c77:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c79:	46                   	inc    %esi
  801c7a:	39 75 10             	cmp    %esi,0x10(%ebp)
  801c7d:	74 0d                	je     801c8c <devpipe_read+0x6c>
		while (p->p_rpos == p->p_wpos) {
  801c7f:	8b 03                	mov    (%ebx),%eax
  801c81:	3b 43 04             	cmp    0x4(%ebx),%eax
  801c84:	75 db                	jne    801c61 <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801c86:	85 f6                	test   %esi,%esi
  801c88:	75 ba                	jne    801c44 <devpipe_read+0x24>
  801c8a:	eb bc                	jmp    801c48 <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801c8c:	8b 45 10             	mov    0x10(%ebp),%eax
  801c8f:	eb 05                	jmp    801c96 <devpipe_read+0x76>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c91:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801c96:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c99:	5b                   	pop    %ebx
  801c9a:	5e                   	pop    %esi
  801c9b:	5f                   	pop    %edi
  801c9c:	5d                   	pop    %ebp
  801c9d:	c3                   	ret    

00801c9e <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801c9e:	55                   	push   %ebp
  801c9f:	89 e5                	mov    %esp,%ebp
  801ca1:	56                   	push   %esi
  801ca2:	53                   	push   %ebx
  801ca3:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801ca6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ca9:	50                   	push   %eax
  801caa:	e8 8c f6 ff ff       	call   80133b <fd_alloc>
  801caf:	83 c4 10             	add    $0x10,%esp
  801cb2:	85 c0                	test   %eax,%eax
  801cb4:	0f 88 2a 01 00 00    	js     801de4 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cba:	83 ec 04             	sub    $0x4,%esp
  801cbd:	68 07 04 00 00       	push   $0x407
  801cc2:	ff 75 f4             	pushl  -0xc(%ebp)
  801cc5:	6a 00                	push   $0x0
  801cc7:	e8 7c f1 ff ff       	call   800e48 <sys_page_alloc>
  801ccc:	83 c4 10             	add    $0x10,%esp
  801ccf:	85 c0                	test   %eax,%eax
  801cd1:	0f 88 0d 01 00 00    	js     801de4 <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801cd7:	83 ec 0c             	sub    $0xc,%esp
  801cda:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801cdd:	50                   	push   %eax
  801cde:	e8 58 f6 ff ff       	call   80133b <fd_alloc>
  801ce3:	89 c3                	mov    %eax,%ebx
  801ce5:	83 c4 10             	add    $0x10,%esp
  801ce8:	85 c0                	test   %eax,%eax
  801cea:	0f 88 e2 00 00 00    	js     801dd2 <pipe+0x134>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cf0:	83 ec 04             	sub    $0x4,%esp
  801cf3:	68 07 04 00 00       	push   $0x407
  801cf8:	ff 75 f0             	pushl  -0x10(%ebp)
  801cfb:	6a 00                	push   $0x0
  801cfd:	e8 46 f1 ff ff       	call   800e48 <sys_page_alloc>
  801d02:	89 c3                	mov    %eax,%ebx
  801d04:	83 c4 10             	add    $0x10,%esp
  801d07:	85 c0                	test   %eax,%eax
  801d09:	0f 88 c3 00 00 00    	js     801dd2 <pipe+0x134>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801d0f:	83 ec 0c             	sub    $0xc,%esp
  801d12:	ff 75 f4             	pushl  -0xc(%ebp)
  801d15:	e8 0a f6 ff ff       	call   801324 <fd2data>
  801d1a:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d1c:	83 c4 0c             	add    $0xc,%esp
  801d1f:	68 07 04 00 00       	push   $0x407
  801d24:	50                   	push   %eax
  801d25:	6a 00                	push   $0x0
  801d27:	e8 1c f1 ff ff       	call   800e48 <sys_page_alloc>
  801d2c:	89 c3                	mov    %eax,%ebx
  801d2e:	83 c4 10             	add    $0x10,%esp
  801d31:	85 c0                	test   %eax,%eax
  801d33:	0f 88 89 00 00 00    	js     801dc2 <pipe+0x124>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d39:	83 ec 0c             	sub    $0xc,%esp
  801d3c:	ff 75 f0             	pushl  -0x10(%ebp)
  801d3f:	e8 e0 f5 ff ff       	call   801324 <fd2data>
  801d44:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801d4b:	50                   	push   %eax
  801d4c:	6a 00                	push   $0x0
  801d4e:	56                   	push   %esi
  801d4f:	6a 00                	push   $0x0
  801d51:	e8 35 f1 ff ff       	call   800e8b <sys_page_map>
  801d56:	89 c3                	mov    %eax,%ebx
  801d58:	83 c4 20             	add    $0x20,%esp
  801d5b:	85 c0                	test   %eax,%eax
  801d5d:	78 55                	js     801db4 <pipe+0x116>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801d5f:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801d65:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d68:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801d6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d6d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801d74:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801d7a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d7d:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801d7f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d82:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801d89:	83 ec 0c             	sub    $0xc,%esp
  801d8c:	ff 75 f4             	pushl  -0xc(%ebp)
  801d8f:	e8 80 f5 ff ff       	call   801314 <fd2num>
  801d94:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d97:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801d99:	83 c4 04             	add    $0x4,%esp
  801d9c:	ff 75 f0             	pushl  -0x10(%ebp)
  801d9f:	e8 70 f5 ff ff       	call   801314 <fd2num>
  801da4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801da7:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801daa:	83 c4 10             	add    $0x10,%esp
  801dad:	b8 00 00 00 00       	mov    $0x0,%eax
  801db2:	eb 30                	jmp    801de4 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  801db4:	83 ec 08             	sub    $0x8,%esp
  801db7:	56                   	push   %esi
  801db8:	6a 00                	push   $0x0
  801dba:	e8 0e f1 ff ff       	call   800ecd <sys_page_unmap>
  801dbf:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801dc2:	83 ec 08             	sub    $0x8,%esp
  801dc5:	ff 75 f0             	pushl  -0x10(%ebp)
  801dc8:	6a 00                	push   $0x0
  801dca:	e8 fe f0 ff ff       	call   800ecd <sys_page_unmap>
  801dcf:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801dd2:	83 ec 08             	sub    $0x8,%esp
  801dd5:	ff 75 f4             	pushl  -0xc(%ebp)
  801dd8:	6a 00                	push   $0x0
  801dda:	e8 ee f0 ff ff       	call   800ecd <sys_page_unmap>
  801ddf:	83 c4 10             	add    $0x10,%esp
  801de2:	89 d8                	mov    %ebx,%eax
    err:
	return r;
}
  801de4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801de7:	5b                   	pop    %ebx
  801de8:	5e                   	pop    %esi
  801de9:	5d                   	pop    %ebp
  801dea:	c3                   	ret    

00801deb <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801deb:	55                   	push   %ebp
  801dec:	89 e5                	mov    %esp,%ebp
  801dee:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801df1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801df4:	50                   	push   %eax
  801df5:	ff 75 08             	pushl  0x8(%ebp)
  801df8:	e8 b2 f5 ff ff       	call   8013af <fd_lookup>
  801dfd:	83 c4 10             	add    $0x10,%esp
  801e00:	85 c0                	test   %eax,%eax
  801e02:	78 18                	js     801e1c <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801e04:	83 ec 0c             	sub    $0xc,%esp
  801e07:	ff 75 f4             	pushl  -0xc(%ebp)
  801e0a:	e8 15 f5 ff ff       	call   801324 <fd2data>
	return _pipeisclosed(fd, p);
  801e0f:	89 c2                	mov    %eax,%edx
  801e11:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e14:	e8 17 fd ff ff       	call   801b30 <_pipeisclosed>
  801e19:	83 c4 10             	add    $0x10,%esp
}
  801e1c:	c9                   	leave  
  801e1d:	c3                   	ret    

00801e1e <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  801e1e:	55                   	push   %ebp
  801e1f:	89 e5                	mov    %esp,%ebp
  801e21:	56                   	push   %esi
  801e22:	53                   	push   %ebx
  801e23:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  801e26:	85 f6                	test   %esi,%esi
  801e28:	75 16                	jne    801e40 <wait+0x22>
  801e2a:	68 03 2b 80 00       	push   $0x802b03
  801e2f:	68 b8 2a 80 00       	push   $0x802ab8
  801e34:	6a 09                	push   $0x9
  801e36:	68 0e 2b 80 00       	push   $0x802b0e
  801e3b:	e8 db e4 ff ff       	call   80031b <_panic>
	e = &envs[ENVX(envid)];
  801e40:	89 f3                	mov    %esi,%ebx
  801e42:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  801e48:	8d 14 9d 00 00 00 00 	lea    0x0(,%ebx,4),%edx
  801e4f:	89 d8                	mov    %ebx,%eax
  801e51:	c1 e0 07             	shl    $0x7,%eax
  801e54:	29 d0                	sub    %edx,%eax
  801e56:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801e5b:	8b 40 48             	mov    0x48(%eax),%eax
  801e5e:	39 c6                	cmp    %eax,%esi
  801e60:	75 31                	jne    801e93 <wait+0x75>
  801e62:	89 d8                	mov    %ebx,%eax
  801e64:	c1 e0 07             	shl    $0x7,%eax
  801e67:	29 d0                	sub    %edx,%eax
  801e69:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801e6e:	8b 40 54             	mov    0x54(%eax),%eax
  801e71:	85 c0                	test   %eax,%eax
  801e73:	74 1e                	je     801e93 <wait+0x75>
  801e75:	c1 e3 07             	shl    $0x7,%ebx
  801e78:	29 d3                	sub    %edx,%ebx
  801e7a:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
		sys_yield();
  801e80:	e8 a4 ef ff ff       	call   800e29 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  801e85:	8b 43 48             	mov    0x48(%ebx),%eax
  801e88:	39 c6                	cmp    %eax,%esi
  801e8a:	75 07                	jne    801e93 <wait+0x75>
  801e8c:	8b 43 54             	mov    0x54(%ebx),%eax
  801e8f:	85 c0                	test   %eax,%eax
  801e91:	75 ed                	jne    801e80 <wait+0x62>
		sys_yield();
}
  801e93:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e96:	5b                   	pop    %ebx
  801e97:	5e                   	pop    %esi
  801e98:	5d                   	pop    %ebp
  801e99:	c3                   	ret    

00801e9a <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801e9a:	55                   	push   %ebp
  801e9b:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801e9d:	b8 00 00 00 00       	mov    $0x0,%eax
  801ea2:	5d                   	pop    %ebp
  801ea3:	c3                   	ret    

00801ea4 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801ea4:	55                   	push   %ebp
  801ea5:	89 e5                	mov    %esp,%ebp
  801ea7:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801eaa:	68 19 2b 80 00       	push   $0x802b19
  801eaf:	ff 75 0c             	pushl  0xc(%ebp)
  801eb2:	e8 21 eb ff ff       	call   8009d8 <strcpy>
	return 0;
}
  801eb7:	b8 00 00 00 00       	mov    $0x0,%eax
  801ebc:	c9                   	leave  
  801ebd:	c3                   	ret    

00801ebe <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ebe:	55                   	push   %ebp
  801ebf:	89 e5                	mov    %esp,%ebp
  801ec1:	57                   	push   %edi
  801ec2:	56                   	push   %esi
  801ec3:	53                   	push   %ebx
  801ec4:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801eca:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801ece:	74 45                	je     801f15 <devcons_write+0x57>
  801ed0:	b8 00 00 00 00       	mov    $0x0,%eax
  801ed5:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801eda:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801ee0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801ee3:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  801ee5:	83 fb 7f             	cmp    $0x7f,%ebx
  801ee8:	76 05                	jbe    801eef <devcons_write+0x31>
			m = sizeof(buf) - 1;
  801eea:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801eef:	83 ec 04             	sub    $0x4,%esp
  801ef2:	53                   	push   %ebx
  801ef3:	03 45 0c             	add    0xc(%ebp),%eax
  801ef6:	50                   	push   %eax
  801ef7:	57                   	push   %edi
  801ef8:	e8 a8 ec ff ff       	call   800ba5 <memmove>
		sys_cputs(buf, m);
  801efd:	83 c4 08             	add    $0x8,%esp
  801f00:	53                   	push   %ebx
  801f01:	57                   	push   %edi
  801f02:	e8 85 ee ff ff       	call   800d8c <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f07:	01 de                	add    %ebx,%esi
  801f09:	89 f0                	mov    %esi,%eax
  801f0b:	83 c4 10             	add    $0x10,%esp
  801f0e:	3b 75 10             	cmp    0x10(%ebp),%esi
  801f11:	72 cd                	jb     801ee0 <devcons_write+0x22>
  801f13:	eb 05                	jmp    801f1a <devcons_write+0x5c>
  801f15:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801f1a:	89 f0                	mov    %esi,%eax
  801f1c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f1f:	5b                   	pop    %ebx
  801f20:	5e                   	pop    %esi
  801f21:	5f                   	pop    %edi
  801f22:	5d                   	pop    %ebp
  801f23:	c3                   	ret    

00801f24 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801f24:	55                   	push   %ebp
  801f25:	89 e5                	mov    %esp,%ebp
  801f27:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801f2a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801f2e:	75 07                	jne    801f37 <devcons_read+0x13>
  801f30:	eb 23                	jmp    801f55 <devcons_read+0x31>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801f32:	e8 f2 ee ff ff       	call   800e29 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801f37:	e8 6e ee ff ff       	call   800daa <sys_cgetc>
  801f3c:	85 c0                	test   %eax,%eax
  801f3e:	74 f2                	je     801f32 <devcons_read+0xe>
		sys_yield();
	if (c < 0)
  801f40:	85 c0                	test   %eax,%eax
  801f42:	78 1d                	js     801f61 <devcons_read+0x3d>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801f44:	83 f8 04             	cmp    $0x4,%eax
  801f47:	74 13                	je     801f5c <devcons_read+0x38>
		return 0;
	*(char*)vbuf = c;
  801f49:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f4c:	88 02                	mov    %al,(%edx)
	return 1;
  801f4e:	b8 01 00 00 00       	mov    $0x1,%eax
  801f53:	eb 0c                	jmp    801f61 <devcons_read+0x3d>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801f55:	b8 00 00 00 00       	mov    $0x0,%eax
  801f5a:	eb 05                	jmp    801f61 <devcons_read+0x3d>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801f5c:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801f61:	c9                   	leave  
  801f62:	c3                   	ret    

00801f63 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801f63:	55                   	push   %ebp
  801f64:	89 e5                	mov    %esp,%ebp
  801f66:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801f69:	8b 45 08             	mov    0x8(%ebp),%eax
  801f6c:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801f6f:	6a 01                	push   $0x1
  801f71:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f74:	50                   	push   %eax
  801f75:	e8 12 ee ff ff       	call   800d8c <sys_cputs>
}
  801f7a:	83 c4 10             	add    $0x10,%esp
  801f7d:	c9                   	leave  
  801f7e:	c3                   	ret    

00801f7f <getchar>:

int
getchar(void)
{
  801f7f:	55                   	push   %ebp
  801f80:	89 e5                	mov    %esp,%ebp
  801f82:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801f85:	6a 01                	push   $0x1
  801f87:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f8a:	50                   	push   %eax
  801f8b:	6a 00                	push   $0x0
  801f8d:	e8 9e f6 ff ff       	call   801630 <read>
	if (r < 0)
  801f92:	83 c4 10             	add    $0x10,%esp
  801f95:	85 c0                	test   %eax,%eax
  801f97:	78 0f                	js     801fa8 <getchar+0x29>
		return r;
	if (r < 1)
  801f99:	85 c0                	test   %eax,%eax
  801f9b:	7e 06                	jle    801fa3 <getchar+0x24>
		return -E_EOF;
	return c;
  801f9d:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801fa1:	eb 05                	jmp    801fa8 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801fa3:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801fa8:	c9                   	leave  
  801fa9:	c3                   	ret    

00801faa <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801faa:	55                   	push   %ebp
  801fab:	89 e5                	mov    %esp,%ebp
  801fad:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801fb0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fb3:	50                   	push   %eax
  801fb4:	ff 75 08             	pushl  0x8(%ebp)
  801fb7:	e8 f3 f3 ff ff       	call   8013af <fd_lookup>
  801fbc:	83 c4 10             	add    $0x10,%esp
  801fbf:	85 c0                	test   %eax,%eax
  801fc1:	78 11                	js     801fd4 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801fc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fc6:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801fcc:	39 10                	cmp    %edx,(%eax)
  801fce:	0f 94 c0             	sete   %al
  801fd1:	0f b6 c0             	movzbl %al,%eax
}
  801fd4:	c9                   	leave  
  801fd5:	c3                   	ret    

00801fd6 <opencons>:

int
opencons(void)
{
  801fd6:	55                   	push   %ebp
  801fd7:	89 e5                	mov    %esp,%ebp
  801fd9:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801fdc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fdf:	50                   	push   %eax
  801fe0:	e8 56 f3 ff ff       	call   80133b <fd_alloc>
  801fe5:	83 c4 10             	add    $0x10,%esp
  801fe8:	85 c0                	test   %eax,%eax
  801fea:	78 3a                	js     802026 <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801fec:	83 ec 04             	sub    $0x4,%esp
  801fef:	68 07 04 00 00       	push   $0x407
  801ff4:	ff 75 f4             	pushl  -0xc(%ebp)
  801ff7:	6a 00                	push   $0x0
  801ff9:	e8 4a ee ff ff       	call   800e48 <sys_page_alloc>
  801ffe:	83 c4 10             	add    $0x10,%esp
  802001:	85 c0                	test   %eax,%eax
  802003:	78 21                	js     802026 <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802005:	8b 15 40 30 80 00    	mov    0x803040,%edx
  80200b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80200e:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802010:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802013:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80201a:	83 ec 0c             	sub    $0xc,%esp
  80201d:	50                   	push   %eax
  80201e:	e8 f1 f2 ff ff       	call   801314 <fd2num>
  802023:	83 c4 10             	add    $0x10,%esp
}
  802026:	c9                   	leave  
  802027:	c3                   	ret    

00802028 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802028:	55                   	push   %ebp
  802029:	89 e5                	mov    %esp,%ebp
  80202b:	53                   	push   %ebx
  80202c:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (_pgfault_handler == 0) {
  80202f:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  802036:	75 5b                	jne    802093 <set_pgfault_handler+0x6b>
		// First time through!
		// LAB 4: Your code here.
		void *va = (void *)(UXSTACKTOP - PGSIZE);
		envid_t eid = sys_getenvid();
  802038:	e8 cd ed ff ff       	call   800e0a <sys_getenvid>
  80203d:	89 c3                	mov    %eax,%ebx
		r = sys_page_alloc(eid,va,PTE_P | PTE_U | PTE_W);
  80203f:	83 ec 04             	sub    $0x4,%esp
  802042:	6a 07                	push   $0x7
  802044:	68 00 f0 bf ee       	push   $0xeebff000
  802049:	50                   	push   %eax
  80204a:	e8 f9 ed ff ff       	call   800e48 <sys_page_alloc>
		if(r<0) panic("set_pgfault_handler\n");
  80204f:	83 c4 10             	add    $0x10,%esp
  802052:	85 c0                	test   %eax,%eax
  802054:	79 14                	jns    80206a <set_pgfault_handler+0x42>
  802056:	83 ec 04             	sub    $0x4,%esp
  802059:	68 25 2b 80 00       	push   $0x802b25
  80205e:	6a 23                	push   $0x23
  802060:	68 3a 2b 80 00       	push   $0x802b3a
  802065:	e8 b1 e2 ff ff       	call   80031b <_panic>
		r = sys_env_set_pgfault_upcall(eid,_pgfault_upcall);
  80206a:	83 ec 08             	sub    $0x8,%esp
  80206d:	68 a0 20 80 00       	push   $0x8020a0
  802072:	53                   	push   %ebx
  802073:	e8 1b ef ff ff       	call   800f93 <sys_env_set_pgfault_upcall>
		if(r<0) panic("set_pgfault_handler\n");
  802078:	83 c4 10             	add    $0x10,%esp
  80207b:	85 c0                	test   %eax,%eax
  80207d:	79 14                	jns    802093 <set_pgfault_handler+0x6b>
  80207f:	83 ec 04             	sub    $0x4,%esp
  802082:	68 25 2b 80 00       	push   $0x802b25
  802087:	6a 25                	push   $0x25
  802089:	68 3a 2b 80 00       	push   $0x802b3a
  80208e:	e8 88 e2 ff ff       	call   80031b <_panic>
		// panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802093:	8b 45 08             	mov    0x8(%ebp),%eax
  802096:	a3 00 60 80 00       	mov    %eax,0x806000
}
  80209b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80209e:	c9                   	leave  
  80209f:	c3                   	ret    

008020a0 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8020a0:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8020a1:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  8020a6:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8020a8:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl %esp,%ebx
  8020ab:	89 e3                	mov    %esp,%ebx
	movl 40(%esp),%eax 	// esp from utf_fault_va to utf_regs(end)
  8020ad:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl 48(%esp),%esp 	// 
  8020b1:	8b 64 24 30          	mov    0x30(%esp),%esp
	pushl %eax
  8020b5:	50                   	push   %eax
 
 
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	movl %ebx,%esp
  8020b6:	89 dc                	mov    %ebx,%esp
	subl $4,48(%esp)
  8020b8:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	popl %eax
  8020bd:	58                   	pop    %eax
	popl %eax
  8020be:	58                   	pop    %eax
	popal
  8020bf:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	add $4,%esp
  8020c0:	83 c4 04             	add    $0x4,%esp
	popfl
  8020c3:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  8020c4:	5c                   	pop    %esp
 
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8020c5:	c3                   	ret    

008020c6 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8020c6:	55                   	push   %ebp
  8020c7:	89 e5                	mov    %esp,%ebp
  8020c9:	56                   	push   %esi
  8020ca:	53                   	push   %ebx
  8020cb:	8b 75 08             	mov    0x8(%ebp),%esi
  8020ce:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020d1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");
	int r;
    if (pg != NULL) {
  8020d4:	85 c0                	test   %eax,%eax
  8020d6:	74 0e                	je     8020e6 <ipc_recv+0x20>
        r = sys_ipc_recv(pg);
  8020d8:	83 ec 0c             	sub    $0xc,%esp
  8020db:	50                   	push   %eax
  8020dc:	e8 17 ef ff ff       	call   800ff8 <sys_ipc_recv>
  8020e1:	83 c4 10             	add    $0x10,%esp
  8020e4:	eb 10                	jmp    8020f6 <ipc_recv+0x30>
    } else {
        r = sys_ipc_recv((void *) UTOP);
  8020e6:	83 ec 0c             	sub    $0xc,%esp
  8020e9:	68 00 00 c0 ee       	push   $0xeec00000
  8020ee:	e8 05 ef ff ff       	call   800ff8 <sys_ipc_recv>
  8020f3:	83 c4 10             	add    $0x10,%esp
    }
    if (r < 0) {
  8020f6:	85 c0                	test   %eax,%eax
  8020f8:	79 16                	jns    802110 <ipc_recv+0x4a>
        // failed
        if (from_env_store != NULL) *from_env_store = 0;
  8020fa:	85 f6                	test   %esi,%esi
  8020fc:	74 06                	je     802104 <ipc_recv+0x3e>
  8020fe:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        if (perm_store != NULL) *perm_store = 0;
  802104:	85 db                	test   %ebx,%ebx
  802106:	74 2c                	je     802134 <ipc_recv+0x6e>
  802108:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80210e:	eb 24                	jmp    802134 <ipc_recv+0x6e>
        return r;
    } else {
        if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  802110:	85 f6                	test   %esi,%esi
  802112:	74 0a                	je     80211e <ipc_recv+0x58>
  802114:	a1 04 40 80 00       	mov    0x804004,%eax
  802119:	8b 40 74             	mov    0x74(%eax),%eax
  80211c:	89 06                	mov    %eax,(%esi)
        if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  80211e:	85 db                	test   %ebx,%ebx
  802120:	74 0a                	je     80212c <ipc_recv+0x66>
  802122:	a1 04 40 80 00       	mov    0x804004,%eax
  802127:	8b 40 78             	mov    0x78(%eax),%eax
  80212a:	89 03                	mov    %eax,(%ebx)
        return thisenv->env_ipc_value;
  80212c:	a1 04 40 80 00       	mov    0x804004,%eax
  802131:	8b 40 70             	mov    0x70(%eax),%eax
    }
 
	return 0;
}
  802134:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802137:	5b                   	pop    %ebx
  802138:	5e                   	pop    %esi
  802139:	5d                   	pop    %ebp
  80213a:	c3                   	ret    

0080213b <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80213b:	55                   	push   %ebp
  80213c:	89 e5                	mov    %esp,%ebp
  80213e:	57                   	push   %edi
  80213f:	56                   	push   %esi
  802140:	53                   	push   %ebx
  802141:	83 ec 0c             	sub    $0xc,%esp
  802144:	8b 75 10             	mov    0x10(%ebp),%esi
  802147:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");
	int r;
    if (pg == NULL) pg = (void *)UTOP;
  80214a:	85 f6                	test   %esi,%esi
  80214c:	75 05                	jne    802153 <ipc_send+0x18>
  80214e:	be 00 00 c0 ee       	mov    $0xeec00000,%esi
    do {
        r = sys_ipc_try_send(to_env, val, pg, perm);
  802153:	57                   	push   %edi
  802154:	56                   	push   %esi
  802155:	ff 75 0c             	pushl  0xc(%ebp)
  802158:	ff 75 08             	pushl  0x8(%ebp)
  80215b:	e8 75 ee ff ff       	call   800fd5 <sys_ipc_try_send>
  802160:	89 c3                	mov    %eax,%ebx
        if (r < 0 && r != -E_IPC_NOT_RECV) panic("ipc send failed: %e", r);
  802162:	83 c4 10             	add    $0x10,%esp
  802165:	85 c0                	test   %eax,%eax
  802167:	79 17                	jns    802180 <ipc_send+0x45>
  802169:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80216c:	74 1d                	je     80218b <ipc_send+0x50>
  80216e:	50                   	push   %eax
  80216f:	68 48 2b 80 00       	push   $0x802b48
  802174:	6a 40                	push   $0x40
  802176:	68 5c 2b 80 00       	push   $0x802b5c
  80217b:	e8 9b e1 ff ff       	call   80031b <_panic>
        sys_yield();
  802180:	e8 a4 ec ff ff       	call   800e29 <sys_yield>
    } while (r != 0);
  802185:	85 db                	test   %ebx,%ebx
  802187:	75 ca                	jne    802153 <ipc_send+0x18>
  802189:	eb 07                	jmp    802192 <ipc_send+0x57>
	int r;
    if (pg == NULL) pg = (void *)UTOP;
    do {
        r = sys_ipc_try_send(to_env, val, pg, perm);
        if (r < 0 && r != -E_IPC_NOT_RECV) panic("ipc send failed: %e", r);
        sys_yield();
  80218b:	e8 99 ec ff ff       	call   800e29 <sys_yield>
  802190:	eb c1                	jmp    802153 <ipc_send+0x18>
    } while (r != 0);
}
  802192:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802195:	5b                   	pop    %ebx
  802196:	5e                   	pop    %esi
  802197:	5f                   	pop    %edi
  802198:	5d                   	pop    %ebp
  802199:	c3                   	ret    

0080219a <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80219a:	55                   	push   %ebp
  80219b:	89 e5                	mov    %esp,%ebp
  80219d:	53                   	push   %ebx
  80219e:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  8021a1:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  8021a6:	39 c1                	cmp    %eax,%ecx
  8021a8:	74 21                	je     8021cb <ipc_find_env+0x31>
  8021aa:	ba 01 00 00 00       	mov    $0x1,%edx
  8021af:	8d 1c 95 00 00 00 00 	lea    0x0(,%edx,4),%ebx
  8021b6:	89 d0                	mov    %edx,%eax
  8021b8:	c1 e0 07             	shl    $0x7,%eax
  8021bb:	29 d8                	sub    %ebx,%eax
  8021bd:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8021c2:	8b 40 50             	mov    0x50(%eax),%eax
  8021c5:	39 c8                	cmp    %ecx,%eax
  8021c7:	75 1b                	jne    8021e4 <ipc_find_env+0x4a>
  8021c9:	eb 05                	jmp    8021d0 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8021cb:	ba 00 00 00 00       	mov    $0x0,%edx
		if (envs[i].env_type == type)
			return envs[i].env_id;
  8021d0:	8d 04 95 00 00 00 00 	lea    0x0(,%edx,4),%eax
  8021d7:	c1 e2 07             	shl    $0x7,%edx
  8021da:	29 c2                	sub    %eax,%edx
  8021dc:	8b 82 48 00 c0 ee    	mov    -0x113fffb8(%edx),%eax
  8021e2:	eb 0e                	jmp    8021f2 <ipc_find_env+0x58>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8021e4:	42                   	inc    %edx
  8021e5:	81 fa 00 04 00 00    	cmp    $0x400,%edx
  8021eb:	75 c2                	jne    8021af <ipc_find_env+0x15>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8021ed:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8021f2:	5b                   	pop    %ebx
  8021f3:	5d                   	pop    %ebp
  8021f4:	c3                   	ret    

008021f5 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8021f5:	55                   	push   %ebp
  8021f6:	89 e5                	mov    %esp,%ebp
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8021f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8021fb:	c1 e8 16             	shr    $0x16,%eax
  8021fe:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  802205:	a8 01                	test   $0x1,%al
  802207:	74 21                	je     80222a <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  802209:	8b 45 08             	mov    0x8(%ebp),%eax
  80220c:	c1 e8 0c             	shr    $0xc,%eax
  80220f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802216:	a8 01                	test   $0x1,%al
  802218:	74 17                	je     802231 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80221a:	c1 e8 0c             	shr    $0xc,%eax
  80221d:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  802224:	ef 
  802225:	0f b7 c0             	movzwl %ax,%eax
  802228:	eb 0c                	jmp    802236 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  80222a:	b8 00 00 00 00       	mov    $0x0,%eax
  80222f:	eb 05                	jmp    802236 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  802231:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  802236:	5d                   	pop    %ebp
  802237:	c3                   	ret    

00802238 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  802238:	55                   	push   %ebp
  802239:	57                   	push   %edi
  80223a:	56                   	push   %esi
  80223b:	53                   	push   %ebx
  80223c:	83 ec 1c             	sub    $0x1c,%esp
  80223f:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  802243:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802247:	8b 7c 24 38          	mov    0x38(%esp),%edi
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  80224b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80224f:	89 ca                	mov    %ecx,%edx
  const DWunion dd = {.ll = d};
  802251:	89 f8                	mov    %edi,%eax
  802253:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802257:	85 f6                	test   %esi,%esi
  802259:	75 2d                	jne    802288 <__udivdi3+0x50>
    {
      if (d0 > n1)
  80225b:	39 cf                	cmp    %ecx,%edi
  80225d:	77 65                	ja     8022c4 <__udivdi3+0x8c>
  80225f:	89 fd                	mov    %edi,%ebp
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802261:	85 ff                	test   %edi,%edi
  802263:	75 0b                	jne    802270 <__udivdi3+0x38>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802265:	b8 01 00 00 00       	mov    $0x1,%eax
  80226a:	31 d2                	xor    %edx,%edx
  80226c:	f7 f7                	div    %edi
  80226e:	89 c5                	mov    %eax,%ebp

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802270:	31 d2                	xor    %edx,%edx
  802272:	89 c8                	mov    %ecx,%eax
  802274:	f7 f5                	div    %ebp
  802276:	89 c1                	mov    %eax,%ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802278:	89 d8                	mov    %ebx,%eax
  80227a:	f7 f5                	div    %ebp
  80227c:	89 cf                	mov    %ecx,%edi
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80227e:	89 fa                	mov    %edi,%edx
  802280:	83 c4 1c             	add    $0x1c,%esp
  802283:	5b                   	pop    %ebx
  802284:	5e                   	pop    %esi
  802285:	5f                   	pop    %edi
  802286:	5d                   	pop    %ebp
  802287:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802288:	39 ce                	cmp    %ecx,%esi
  80228a:	77 28                	ja     8022b4 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  80228c:	0f bd fe             	bsr    %esi,%edi
	  if (bm == 0)
  80228f:	83 f7 1f             	xor    $0x1f,%edi
  802292:	75 40                	jne    8022d4 <__udivdi3+0x9c>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802294:	39 ce                	cmp    %ecx,%esi
  802296:	72 0a                	jb     8022a2 <__udivdi3+0x6a>
  802298:	3b 44 24 08          	cmp    0x8(%esp),%eax
  80229c:	0f 87 9e 00 00 00    	ja     802340 <__udivdi3+0x108>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8022a2:	b8 01 00 00 00       	mov    $0x1,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8022a7:	89 fa                	mov    %edi,%edx
  8022a9:	83 c4 1c             	add    $0x1c,%esp
  8022ac:	5b                   	pop    %ebx
  8022ad:	5e                   	pop    %esi
  8022ae:	5f                   	pop    %edi
  8022af:	5d                   	pop    %ebp
  8022b0:	c3                   	ret    
  8022b1:	8d 76 00             	lea    0x0(%esi),%esi
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8022b4:	31 ff                	xor    %edi,%edi
  8022b6:	31 c0                	xor    %eax,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8022b8:	89 fa                	mov    %edi,%edx
  8022ba:	83 c4 1c             	add    $0x1c,%esp
  8022bd:	5b                   	pop    %ebx
  8022be:	5e                   	pop    %esi
  8022bf:	5f                   	pop    %edi
  8022c0:	5d                   	pop    %ebp
  8022c1:	c3                   	ret    
  8022c2:	66 90                	xchg   %ax,%ax
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8022c4:	89 d8                	mov    %ebx,%eax
  8022c6:	f7 f7                	div    %edi
  8022c8:	31 ff                	xor    %edi,%edi
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8022ca:	89 fa                	mov    %edi,%edx
  8022cc:	83 c4 1c             	add    $0x1c,%esp
  8022cf:	5b                   	pop    %ebx
  8022d0:	5e                   	pop    %esi
  8022d1:	5f                   	pop    %edi
  8022d2:	5d                   	pop    %ebp
  8022d3:	c3                   	ret    
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8022d4:	bd 20 00 00 00       	mov    $0x20,%ebp
  8022d9:	89 eb                	mov    %ebp,%ebx
  8022db:	29 fb                	sub    %edi,%ebx

	      d1 = (d1 << bm) | (d0 >> b);
  8022dd:	89 f9                	mov    %edi,%ecx
  8022df:	d3 e6                	shl    %cl,%esi
  8022e1:	89 c5                	mov    %eax,%ebp
  8022e3:	88 d9                	mov    %bl,%cl
  8022e5:	d3 ed                	shr    %cl,%ebp
  8022e7:	89 e9                	mov    %ebp,%ecx
  8022e9:	09 f1                	or     %esi,%ecx
  8022eb:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
	      d0 = d0 << bm;
  8022ef:	89 f9                	mov    %edi,%ecx
  8022f1:	d3 e0                	shl    %cl,%eax
  8022f3:	89 c5                	mov    %eax,%ebp
	      n2 = n1 >> b;
  8022f5:	89 d6                	mov    %edx,%esi
  8022f7:	88 d9                	mov    %bl,%cl
  8022f9:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
  8022fb:	89 f9                	mov    %edi,%ecx
  8022fd:	d3 e2                	shl    %cl,%edx
  8022ff:	8b 44 24 08          	mov    0x8(%esp),%eax
  802303:	88 d9                	mov    %bl,%cl
  802305:	d3 e8                	shr    %cl,%eax
  802307:	09 c2                	or     %eax,%edx
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802309:	89 d0                	mov    %edx,%eax
  80230b:	89 f2                	mov    %esi,%edx
  80230d:	f7 74 24 0c          	divl   0xc(%esp)
  802311:	89 d6                	mov    %edx,%esi
  802313:	89 c3                	mov    %eax,%ebx
	      umul_ppmm (m1, m0, q0, d0);
  802315:	f7 e5                	mul    %ebp

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802317:	39 d6                	cmp    %edx,%esi
  802319:	72 19                	jb     802334 <__udivdi3+0xfc>
  80231b:	74 0b                	je     802328 <__udivdi3+0xf0>
  80231d:	89 d8                	mov    %ebx,%eax
  80231f:	31 ff                	xor    %edi,%edi
  802321:	e9 58 ff ff ff       	jmp    80227e <__udivdi3+0x46>
  802326:	66 90                	xchg   %ax,%ax
  802328:	8b 54 24 08          	mov    0x8(%esp),%edx
  80232c:	89 f9                	mov    %edi,%ecx
  80232e:	d3 e2                	shl    %cl,%edx
  802330:	39 c2                	cmp    %eax,%edx
  802332:	73 e9                	jae    80231d <__udivdi3+0xe5>
  802334:	8d 43 ff             	lea    -0x1(%ebx),%eax
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802337:	31 ff                	xor    %edi,%edi
  802339:	e9 40 ff ff ff       	jmp    80227e <__udivdi3+0x46>
  80233e:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802340:	31 c0                	xor    %eax,%eax
  802342:	e9 37 ff ff ff       	jmp    80227e <__udivdi3+0x46>
  802347:	90                   	nop

00802348 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  802348:	55                   	push   %ebp
  802349:	57                   	push   %edi
  80234a:	56                   	push   %esi
  80234b:	53                   	push   %ebx
  80234c:	83 ec 1c             	sub    $0x1c,%esp
  80234f:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  802353:	8b 74 24 34          	mov    0x34(%esp),%esi
  802357:	8b 7c 24 38          	mov    0x38(%esp),%edi
  80235b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80235f:	89 44 24 0c          	mov    %eax,0xc(%esp)
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  802363:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802367:	89 f3                	mov    %esi,%ebx
  const DWunion dd = {.ll = d};
  802369:	89 fa                	mov    %edi,%edx
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  80236b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  n1 = nn.s.high;
  80236f:	89 34 24             	mov    %esi,(%esp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802372:	85 c0                	test   %eax,%eax
  802374:	75 1a                	jne    802390 <__umoddi3+0x48>
    {
      if (d0 > n1)
  802376:	39 f7                	cmp    %esi,%edi
  802378:	0f 86 a2 00 00 00    	jbe    802420 <__umoddi3+0xd8>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80237e:	89 c8                	mov    %ecx,%eax
  802380:	89 f2                	mov    %esi,%edx
  802382:	f7 f7                	div    %edi
  802384:	89 d0                	mov    %edx,%eax

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  802386:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802388:	83 c4 1c             	add    $0x1c,%esp
  80238b:	5b                   	pop    %ebx
  80238c:	5e                   	pop    %esi
  80238d:	5f                   	pop    %edi
  80238e:	5d                   	pop    %ebp
  80238f:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802390:	39 f0                	cmp    %esi,%eax
  802392:	0f 87 ac 00 00 00    	ja     802444 <__umoddi3+0xfc>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802398:	0f bd e8             	bsr    %eax,%ebp
	  if (bm == 0)
  80239b:	83 f5 1f             	xor    $0x1f,%ebp
  80239e:	0f 84 ac 00 00 00    	je     802450 <__umoddi3+0x108>
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8023a4:	bf 20 00 00 00       	mov    $0x20,%edi
  8023a9:	29 ef                	sub    %ebp,%edi
  8023ab:	89 fe                	mov    %edi,%esi
  8023ad:	89 7c 24 0c          	mov    %edi,0xc(%esp)

	      d1 = (d1 << bm) | (d0 >> b);
  8023b1:	89 e9                	mov    %ebp,%ecx
  8023b3:	d3 e0                	shl    %cl,%eax
  8023b5:	89 d7                	mov    %edx,%edi
  8023b7:	89 f1                	mov    %esi,%ecx
  8023b9:	d3 ef                	shr    %cl,%edi
  8023bb:	09 c7                	or     %eax,%edi
	      d0 = d0 << bm;
  8023bd:	89 e9                	mov    %ebp,%ecx
  8023bf:	d3 e2                	shl    %cl,%edx
  8023c1:	89 14 24             	mov    %edx,(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8023c4:	89 d8                	mov    %ebx,%eax
  8023c6:	d3 e0                	shl    %cl,%eax
  8023c8:	89 c2                	mov    %eax,%edx
	      n0 = n0 << bm;
  8023ca:	8b 44 24 08          	mov    0x8(%esp),%eax
  8023ce:	d3 e0                	shl    %cl,%eax
  8023d0:	89 44 24 04          	mov    %eax,0x4(%esp)

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8023d4:	8b 44 24 08          	mov    0x8(%esp),%eax
  8023d8:	89 f1                	mov    %esi,%ecx
  8023da:	d3 e8                	shr    %cl,%eax
  8023dc:	09 d0                	or     %edx,%eax
  8023de:	d3 eb                	shr    %cl,%ebx
  8023e0:	89 da                	mov    %ebx,%edx
  8023e2:	f7 f7                	div    %edi
  8023e4:	89 d3                	mov    %edx,%ebx
	      umul_ppmm (m1, m0, q0, d0);
  8023e6:	f7 24 24             	mull   (%esp)
  8023e9:	89 c6                	mov    %eax,%esi
  8023eb:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8023ed:	39 d3                	cmp    %edx,%ebx
  8023ef:	0f 82 87 00 00 00    	jb     80247c <__umoddi3+0x134>
  8023f5:	0f 84 91 00 00 00    	je     80248c <__umoddi3+0x144>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  8023fb:	8b 54 24 04          	mov    0x4(%esp),%edx
  8023ff:	29 f2                	sub    %esi,%edx
  802401:	19 cb                	sbb    %ecx,%ebx
		  rr.s.low = (n1 << b) | (n0 >> bm);
  802403:	89 d8                	mov    %ebx,%eax
  802405:	8a 4c 24 0c          	mov    0xc(%esp),%cl
  802409:	d3 e0                	shl    %cl,%eax
  80240b:	89 e9                	mov    %ebp,%ecx
  80240d:	d3 ea                	shr    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  80240f:	09 d0                	or     %edx,%eax
  802411:	89 e9                	mov    %ebp,%ecx
  802413:	d3 eb                	shr    %cl,%ebx
  802415:	89 da                	mov    %ebx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802417:	83 c4 1c             	add    $0x1c,%esp
  80241a:	5b                   	pop    %ebx
  80241b:	5e                   	pop    %esi
  80241c:	5f                   	pop    %edi
  80241d:	5d                   	pop    %ebp
  80241e:	c3                   	ret    
  80241f:	90                   	nop
  802420:	89 fd                	mov    %edi,%ebp
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802422:	85 ff                	test   %edi,%edi
  802424:	75 0b                	jne    802431 <__umoddi3+0xe9>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802426:	b8 01 00 00 00       	mov    $0x1,%eax
  80242b:	31 d2                	xor    %edx,%edx
  80242d:	f7 f7                	div    %edi
  80242f:	89 c5                	mov    %eax,%ebp

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802431:	89 f0                	mov    %esi,%eax
  802433:	31 d2                	xor    %edx,%edx
  802435:	f7 f5                	div    %ebp
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802437:	89 c8                	mov    %ecx,%eax
  802439:	f7 f5                	div    %ebp
  80243b:	89 d0                	mov    %edx,%eax
  80243d:	e9 44 ff ff ff       	jmp    802386 <__umoddi3+0x3e>
  802442:	66 90                	xchg   %ax,%ax
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  802444:	89 c8                	mov    %ecx,%eax
  802446:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802448:	83 c4 1c             	add    $0x1c,%esp
  80244b:	5b                   	pop    %ebx
  80244c:	5e                   	pop    %esi
  80244d:	5f                   	pop    %edi
  80244e:	5d                   	pop    %ebp
  80244f:	c3                   	ret    

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802450:	3b 04 24             	cmp    (%esp),%eax
  802453:	72 06                	jb     80245b <__umoddi3+0x113>
  802455:	3b 7c 24 04          	cmp    0x4(%esp),%edi
  802459:	77 0f                	ja     80246a <__umoddi3+0x122>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  80245b:	89 f2                	mov    %esi,%edx
  80245d:	29 f9                	sub    %edi,%ecx
  80245f:	1b 54 24 0c          	sbb    0xc(%esp),%edx
  802463:	89 14 24             	mov    %edx,(%esp)
  802466:	89 4c 24 04          	mov    %ecx,0x4(%esp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  80246a:	8b 44 24 04          	mov    0x4(%esp),%eax
  80246e:	8b 14 24             	mov    (%esp),%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802471:	83 c4 1c             	add    $0x1c,%esp
  802474:	5b                   	pop    %ebx
  802475:	5e                   	pop    %esi
  802476:	5f                   	pop    %edi
  802477:	5d                   	pop    %ebp
  802478:	c3                   	ret    
  802479:	8d 76 00             	lea    0x0(%esi),%esi
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  80247c:	2b 04 24             	sub    (%esp),%eax
  80247f:	19 fa                	sbb    %edi,%edx
  802481:	89 d1                	mov    %edx,%ecx
  802483:	89 c6                	mov    %eax,%esi
  802485:	e9 71 ff ff ff       	jmp    8023fb <__umoddi3+0xb3>
  80248a:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80248c:	39 44 24 04          	cmp    %eax,0x4(%esp)
  802490:	72 ea                	jb     80247c <__umoddi3+0x134>
  802492:	89 d9                	mov    %ebx,%ecx
  802494:	e9 62 ff ff ff       	jmp    8023fb <__umoddi3+0xb3>
