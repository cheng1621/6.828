
obj/user/testpiperace.debug:     file format elf32-i386


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
  80002c:	e8 d7 01 00 00       	call   800208 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	83 ec 1c             	sub    $0x1c,%esp
	int p[2], r, pid, i, max;
	void *va;
	struct Fd *fd;
	const volatile struct Env *kid;

	cprintf("testing for dup race...\n");
  80003b:	68 80 23 80 00       	push   $0x802380
  800040:	e8 04 03 00 00       	call   800349 <cprintf>
	if ((r = pipe(p)) < 0)
  800045:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800048:	89 04 24             	mov    %eax,(%esp)
  80004b:	e8 16 1d 00 00       	call   801d66 <pipe>
  800050:	83 c4 10             	add    $0x10,%esp
  800053:	85 c0                	test   %eax,%eax
  800055:	79 12                	jns    800069 <umain+0x36>
		panic("pipe: %e", r);
  800057:	50                   	push   %eax
  800058:	68 99 23 80 00       	push   $0x802399
  80005d:	6a 0d                	push   $0xd
  80005f:	68 a2 23 80 00       	push   $0x8023a2
  800064:	e8 08 02 00 00       	call   800271 <_panic>
	max = 200;
	if ((r = fork()) < 0)
  800069:	e8 10 10 00 00       	call   80107e <fork>
  80006e:	89 c6                	mov    %eax,%esi
  800070:	85 c0                	test   %eax,%eax
  800072:	79 12                	jns    800086 <umain+0x53>
		panic("fork: %e", r);
  800074:	50                   	push   %eax
  800075:	68 b6 23 80 00       	push   $0x8023b6
  80007a:	6a 10                	push   $0x10
  80007c:	68 a2 23 80 00       	push   $0x8023a2
  800081:	e8 eb 01 00 00       	call   800271 <_panic>
	if (r == 0) {
  800086:	85 c0                	test   %eax,%eax
  800088:	75 53                	jne    8000dd <umain+0xaa>
		close(p[1]);
  80008a:	83 ec 0c             	sub    $0xc,%esp
  80008d:	ff 75 f4             	pushl  -0xc(%ebp)
  800090:	e8 e8 14 00 00       	call   80157d <close>
  800095:	83 c4 10             	add    $0x10,%esp
  800098:	bb c8 00 00 00       	mov    $0xc8,%ebx
		// If a clock interrupt catches dup between mapping the
		// fd and mapping the pipe structure, we'll have the same
		// ref counts, still a no-no.
		//
		for (i=0; i<max; i++) {
			if(pipeisclosed(p[0])){
  80009d:	83 ec 0c             	sub    $0xc,%esp
  8000a0:	ff 75 f0             	pushl  -0x10(%ebp)
  8000a3:	e8 0b 1e 00 00       	call   801eb3 <pipeisclosed>
  8000a8:	83 c4 10             	add    $0x10,%esp
  8000ab:	85 c0                	test   %eax,%eax
  8000ad:	74 15                	je     8000c4 <umain+0x91>
				cprintf("RACE: pipe appears closed\n");
  8000af:	83 ec 0c             	sub    $0xc,%esp
  8000b2:	68 bf 23 80 00       	push   $0x8023bf
  8000b7:	e8 8d 02 00 00       	call   800349 <cprintf>
				exit();
  8000bc:	e8 96 01 00 00       	call   800257 <exit>
  8000c1:	83 c4 10             	add    $0x10,%esp
			}
			sys_yield();
  8000c4:	e8 b6 0c 00 00       	call   800d7f <sys_yield>
		//
		// If a clock interrupt catches dup between mapping the
		// fd and mapping the pipe structure, we'll have the same
		// ref counts, still a no-no.
		//
		for (i=0; i<max; i++) {
  8000c9:	4b                   	dec    %ebx
  8000ca:	75 d1                	jne    80009d <umain+0x6a>
				exit();
			}
			sys_yield();
		}
		// do something to be not runnable besides exiting
		ipc_recv(0,0,0);
  8000cc:	83 ec 04             	sub    $0x4,%esp
  8000cf:	6a 00                	push   $0x0
  8000d1:	6a 00                	push   $0x0
  8000d3:	6a 00                	push   $0x0
  8000d5:	e8 90 11 00 00       	call   80126a <ipc_recv>
  8000da:	83 c4 10             	add    $0x10,%esp
	}
	pid = r;
	cprintf("pid is %d\n", pid);
  8000dd:	83 ec 08             	sub    $0x8,%esp
  8000e0:	56                   	push   %esi
  8000e1:	68 da 23 80 00       	push   $0x8023da
  8000e6:	e8 5e 02 00 00       	call   800349 <cprintf>
	va = 0;
	kid = &envs[ENVX(pid)];
  8000eb:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
	cprintf("kid is %d\n", kid-envs);
  8000f1:	83 c4 08             	add    $0x8,%esp
		ipc_recv(0,0,0);
	}
	pid = r;
	cprintf("pid is %d\n", pid);
	va = 0;
	kid = &envs[ENVX(pid)];
  8000f4:	8d 14 b5 00 00 00 00 	lea    0x0(,%esi,4),%edx
  8000fb:	89 f0                	mov    %esi,%eax
  8000fd:	c1 e0 07             	shl    $0x7,%eax
  800100:	29 d0                	sub    %edx,%eax
	cprintf("kid is %d\n", kid-envs);
  800102:	8d b0 00 00 c0 ee    	lea    -0x11400000(%eax),%esi
  800108:	c1 f8 02             	sar    $0x2,%eax
  80010b:	89 c1                	mov    %eax,%ecx
  80010d:	c1 e1 05             	shl    $0x5,%ecx
  800110:	89 c2                	mov    %eax,%edx
  800112:	c1 e2 0a             	shl    $0xa,%edx
  800115:	01 ca                	add    %ecx,%edx
  800117:	01 c2                	add    %eax,%edx
  800119:	89 d1                	mov    %edx,%ecx
  80011b:	c1 e1 0f             	shl    $0xf,%ecx
  80011e:	01 ca                	add    %ecx,%edx
  800120:	c1 e2 05             	shl    $0x5,%edx
  800123:	01 d0                	add    %edx,%eax
  800125:	f7 d8                	neg    %eax
  800127:	50                   	push   %eax
  800128:	68 e5 23 80 00       	push   $0x8023e5
  80012d:	e8 17 02 00 00       	call   800349 <cprintf>
	dup(p[0], 10);
  800132:	83 c4 08             	add    $0x8,%esp
  800135:	6a 0a                	push   $0xa
  800137:	ff 75 f0             	pushl  -0x10(%ebp)
  80013a:	e8 8c 14 00 00       	call   8015cb <dup>
	while (kid->env_status == ENV_RUNNABLE)
  80013f:	8b 46 54             	mov    0x54(%esi),%eax
  800142:	83 c4 10             	add    $0x10,%esp
  800145:	83 f8 02             	cmp    $0x2,%eax
  800148:	75 1a                	jne    800164 <umain+0x131>
  80014a:	89 f3                	mov    %esi,%ebx
		dup(p[0], 10);
  80014c:	83 ec 08             	sub    $0x8,%esp
  80014f:	6a 0a                	push   $0xa
  800151:	ff 75 f0             	pushl  -0x10(%ebp)
  800154:	e8 72 14 00 00       	call   8015cb <dup>
	cprintf("pid is %d\n", pid);
	va = 0;
	kid = &envs[ENVX(pid)];
	cprintf("kid is %d\n", kid-envs);
	dup(p[0], 10);
	while (kid->env_status == ENV_RUNNABLE)
  800159:	8b 53 54             	mov    0x54(%ebx),%edx
  80015c:	83 c4 10             	add    $0x10,%esp
  80015f:	83 fa 02             	cmp    $0x2,%edx
  800162:	74 e8                	je     80014c <umain+0x119>
		dup(p[0], 10);

	cprintf("child done with loop\n");
  800164:	83 ec 0c             	sub    $0xc,%esp
  800167:	68 f0 23 80 00       	push   $0x8023f0
  80016c:	e8 d8 01 00 00       	call   800349 <cprintf>
	if (pipeisclosed(p[0]))
  800171:	83 c4 04             	add    $0x4,%esp
  800174:	ff 75 f0             	pushl  -0x10(%ebp)
  800177:	e8 37 1d 00 00       	call   801eb3 <pipeisclosed>
  80017c:	83 c4 10             	add    $0x10,%esp
  80017f:	85 c0                	test   %eax,%eax
  800181:	74 14                	je     800197 <umain+0x164>
		panic("somehow the other end of p[0] got closed!");
  800183:	83 ec 04             	sub    $0x4,%esp
  800186:	68 4c 24 80 00       	push   $0x80244c
  80018b:	6a 3a                	push   $0x3a
  80018d:	68 a2 23 80 00       	push   $0x8023a2
  800192:	e8 da 00 00 00       	call   800271 <_panic>
	if ((r = fd_lookup(p[0], &fd)) < 0)
  800197:	83 ec 08             	sub    $0x8,%esp
  80019a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80019d:	50                   	push   %eax
  80019e:	ff 75 f0             	pushl  -0x10(%ebp)
  8001a1:	e8 8e 12 00 00       	call   801434 <fd_lookup>
  8001a6:	83 c4 10             	add    $0x10,%esp
  8001a9:	85 c0                	test   %eax,%eax
  8001ab:	79 12                	jns    8001bf <umain+0x18c>
		panic("cannot look up p[0]: %e", r);
  8001ad:	50                   	push   %eax
  8001ae:	68 06 24 80 00       	push   $0x802406
  8001b3:	6a 3c                	push   $0x3c
  8001b5:	68 a2 23 80 00       	push   $0x8023a2
  8001ba:	e8 b2 00 00 00       	call   800271 <_panic>
	va = fd2data(fd);
  8001bf:	83 ec 0c             	sub    $0xc,%esp
  8001c2:	ff 75 ec             	pushl  -0x14(%ebp)
  8001c5:	e8 df 11 00 00       	call   8013a9 <fd2data>
	if (pageref(va) != 3+1)
  8001ca:	89 04 24             	mov    %eax,(%esp)
  8001cd:	e8 6b 19 00 00       	call   801b3d <pageref>
  8001d2:	83 c4 10             	add    $0x10,%esp
  8001d5:	83 f8 04             	cmp    $0x4,%eax
  8001d8:	74 12                	je     8001ec <umain+0x1b9>
		cprintf("\nchild detected race\n");
  8001da:	83 ec 0c             	sub    $0xc,%esp
  8001dd:	68 1e 24 80 00       	push   $0x80241e
  8001e2:	e8 62 01 00 00       	call   800349 <cprintf>
  8001e7:	83 c4 10             	add    $0x10,%esp
  8001ea:	eb 15                	jmp    800201 <umain+0x1ce>
	else
		cprintf("\nrace didn't happen\n", max);
  8001ec:	83 ec 08             	sub    $0x8,%esp
  8001ef:	68 c8 00 00 00       	push   $0xc8
  8001f4:	68 34 24 80 00       	push   $0x802434
  8001f9:	e8 4b 01 00 00       	call   800349 <cprintf>
  8001fe:	83 c4 10             	add    $0x10,%esp
}
  800201:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800204:	5b                   	pop    %ebx
  800205:	5e                   	pop    %esi
  800206:	5d                   	pop    %ebp
  800207:	c3                   	ret    

00800208 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800208:	55                   	push   %ebp
  800209:	89 e5                	mov    %esp,%ebp
  80020b:	56                   	push   %esi
  80020c:	53                   	push   %ebx
  80020d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800210:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800213:	e8 48 0b 00 00       	call   800d60 <sys_getenvid>
  800218:	25 ff 03 00 00       	and    $0x3ff,%eax
  80021d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800224:	c1 e0 07             	shl    $0x7,%eax
  800227:	29 d0                	sub    %edx,%eax
  800229:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80022e:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800233:	85 db                	test   %ebx,%ebx
  800235:	7e 07                	jle    80023e <libmain+0x36>
		binaryname = argv[0];
  800237:	8b 06                	mov    (%esi),%eax
  800239:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80023e:	83 ec 08             	sub    $0x8,%esp
  800241:	56                   	push   %esi
  800242:	53                   	push   %ebx
  800243:	e8 eb fd ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800248:	e8 0a 00 00 00       	call   800257 <exit>
}
  80024d:	83 c4 10             	add    $0x10,%esp
  800250:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800253:	5b                   	pop    %ebx
  800254:	5e                   	pop    %esi
  800255:	5d                   	pop    %ebp
  800256:	c3                   	ret    

00800257 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800257:	55                   	push   %ebp
  800258:	89 e5                	mov    %esp,%ebp
  80025a:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80025d:	e8 46 13 00 00       	call   8015a8 <close_all>
	sys_env_destroy(0);
  800262:	83 ec 0c             	sub    $0xc,%esp
  800265:	6a 00                	push   $0x0
  800267:	e8 b3 0a 00 00       	call   800d1f <sys_env_destroy>
}
  80026c:	83 c4 10             	add    $0x10,%esp
  80026f:	c9                   	leave  
  800270:	c3                   	ret    

00800271 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800271:	55                   	push   %ebp
  800272:	89 e5                	mov    %esp,%ebp
  800274:	56                   	push   %esi
  800275:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800276:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800279:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80027f:	e8 dc 0a 00 00       	call   800d60 <sys_getenvid>
  800284:	83 ec 0c             	sub    $0xc,%esp
  800287:	ff 75 0c             	pushl  0xc(%ebp)
  80028a:	ff 75 08             	pushl  0x8(%ebp)
  80028d:	56                   	push   %esi
  80028e:	50                   	push   %eax
  80028f:	68 80 24 80 00       	push   $0x802480
  800294:	e8 b0 00 00 00       	call   800349 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800299:	83 c4 18             	add    $0x18,%esp
  80029c:	53                   	push   %ebx
  80029d:	ff 75 10             	pushl  0x10(%ebp)
  8002a0:	e8 53 00 00 00       	call   8002f8 <vcprintf>
	cprintf("\n");
  8002a5:	c7 04 24 0b 28 80 00 	movl   $0x80280b,(%esp)
  8002ac:	e8 98 00 00 00       	call   800349 <cprintf>
  8002b1:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8002b4:	cc                   	int3   
  8002b5:	eb fd                	jmp    8002b4 <_panic+0x43>

008002b7 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8002b7:	55                   	push   %ebp
  8002b8:	89 e5                	mov    %esp,%ebp
  8002ba:	53                   	push   %ebx
  8002bb:	83 ec 04             	sub    $0x4,%esp
  8002be:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8002c1:	8b 13                	mov    (%ebx),%edx
  8002c3:	8d 42 01             	lea    0x1(%edx),%eax
  8002c6:	89 03                	mov    %eax,(%ebx)
  8002c8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002cb:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8002cf:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002d4:	75 1a                	jne    8002f0 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8002d6:	83 ec 08             	sub    $0x8,%esp
  8002d9:	68 ff 00 00 00       	push   $0xff
  8002de:	8d 43 08             	lea    0x8(%ebx),%eax
  8002e1:	50                   	push   %eax
  8002e2:	e8 fb 09 00 00       	call   800ce2 <sys_cputs>
		b->idx = 0;
  8002e7:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8002ed:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8002f0:	ff 43 04             	incl   0x4(%ebx)
}
  8002f3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8002f6:	c9                   	leave  
  8002f7:	c3                   	ret    

008002f8 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002f8:	55                   	push   %ebp
  8002f9:	89 e5                	mov    %esp,%ebp
  8002fb:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800301:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800308:	00 00 00 
	b.cnt = 0;
  80030b:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800312:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800315:	ff 75 0c             	pushl  0xc(%ebp)
  800318:	ff 75 08             	pushl  0x8(%ebp)
  80031b:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800321:	50                   	push   %eax
  800322:	68 b7 02 80 00       	push   $0x8002b7
  800327:	e8 54 01 00 00       	call   800480 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80032c:	83 c4 08             	add    $0x8,%esp
  80032f:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800335:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80033b:	50                   	push   %eax
  80033c:	e8 a1 09 00 00       	call   800ce2 <sys_cputs>

	return b.cnt;
}
  800341:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800347:	c9                   	leave  
  800348:	c3                   	ret    

00800349 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800349:	55                   	push   %ebp
  80034a:	89 e5                	mov    %esp,%ebp
  80034c:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80034f:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800352:	50                   	push   %eax
  800353:	ff 75 08             	pushl  0x8(%ebp)
  800356:	e8 9d ff ff ff       	call   8002f8 <vcprintf>
	va_end(ap);

	return cnt;
}
  80035b:	c9                   	leave  
  80035c:	c3                   	ret    

0080035d <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80035d:	55                   	push   %ebp
  80035e:	89 e5                	mov    %esp,%ebp
  800360:	57                   	push   %edi
  800361:	56                   	push   %esi
  800362:	53                   	push   %ebx
  800363:	83 ec 1c             	sub    $0x1c,%esp
  800366:	89 c6                	mov    %eax,%esi
  800368:	89 d7                	mov    %edx,%edi
  80036a:	8b 45 08             	mov    0x8(%ebp),%eax
  80036d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800370:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800373:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800376:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800379:	bb 00 00 00 00       	mov    $0x0,%ebx
  80037e:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800381:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800384:	39 d3                	cmp    %edx,%ebx
  800386:	72 11                	jb     800399 <printnum+0x3c>
  800388:	39 45 10             	cmp    %eax,0x10(%ebp)
  80038b:	76 0c                	jbe    800399 <printnum+0x3c>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80038d:	8b 45 14             	mov    0x14(%ebp),%eax
  800390:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800393:	85 db                	test   %ebx,%ebx
  800395:	7f 37                	jg     8003ce <printnum+0x71>
  800397:	eb 44                	jmp    8003dd <printnum+0x80>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800399:	83 ec 0c             	sub    $0xc,%esp
  80039c:	ff 75 18             	pushl  0x18(%ebp)
  80039f:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a2:	48                   	dec    %eax
  8003a3:	50                   	push   %eax
  8003a4:	ff 75 10             	pushl  0x10(%ebp)
  8003a7:	83 ec 08             	sub    $0x8,%esp
  8003aa:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003ad:	ff 75 e0             	pushl  -0x20(%ebp)
  8003b0:	ff 75 dc             	pushl  -0x24(%ebp)
  8003b3:	ff 75 d8             	pushl  -0x28(%ebp)
  8003b6:	e8 59 1d 00 00       	call   802114 <__udivdi3>
  8003bb:	83 c4 18             	add    $0x18,%esp
  8003be:	52                   	push   %edx
  8003bf:	50                   	push   %eax
  8003c0:	89 fa                	mov    %edi,%edx
  8003c2:	89 f0                	mov    %esi,%eax
  8003c4:	e8 94 ff ff ff       	call   80035d <printnum>
  8003c9:	83 c4 20             	add    $0x20,%esp
  8003cc:	eb 0f                	jmp    8003dd <printnum+0x80>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8003ce:	83 ec 08             	sub    $0x8,%esp
  8003d1:	57                   	push   %edi
  8003d2:	ff 75 18             	pushl  0x18(%ebp)
  8003d5:	ff d6                	call   *%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003d7:	83 c4 10             	add    $0x10,%esp
  8003da:	4b                   	dec    %ebx
  8003db:	75 f1                	jne    8003ce <printnum+0x71>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003dd:	83 ec 08             	sub    $0x8,%esp
  8003e0:	57                   	push   %edi
  8003e1:	83 ec 04             	sub    $0x4,%esp
  8003e4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003e7:	ff 75 e0             	pushl  -0x20(%ebp)
  8003ea:	ff 75 dc             	pushl  -0x24(%ebp)
  8003ed:	ff 75 d8             	pushl  -0x28(%ebp)
  8003f0:	e8 2f 1e 00 00       	call   802224 <__umoddi3>
  8003f5:	83 c4 14             	add    $0x14,%esp
  8003f8:	0f be 80 a3 24 80 00 	movsbl 0x8024a3(%eax),%eax
  8003ff:	50                   	push   %eax
  800400:	ff d6                	call   *%esi
}
  800402:	83 c4 10             	add    $0x10,%esp
  800405:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800408:	5b                   	pop    %ebx
  800409:	5e                   	pop    %esi
  80040a:	5f                   	pop    %edi
  80040b:	5d                   	pop    %ebp
  80040c:	c3                   	ret    

0080040d <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80040d:	55                   	push   %ebp
  80040e:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800410:	83 fa 01             	cmp    $0x1,%edx
  800413:	7e 0e                	jle    800423 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800415:	8b 10                	mov    (%eax),%edx
  800417:	8d 4a 08             	lea    0x8(%edx),%ecx
  80041a:	89 08                	mov    %ecx,(%eax)
  80041c:	8b 02                	mov    (%edx),%eax
  80041e:	8b 52 04             	mov    0x4(%edx),%edx
  800421:	eb 22                	jmp    800445 <getuint+0x38>
	else if (lflag)
  800423:	85 d2                	test   %edx,%edx
  800425:	74 10                	je     800437 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800427:	8b 10                	mov    (%eax),%edx
  800429:	8d 4a 04             	lea    0x4(%edx),%ecx
  80042c:	89 08                	mov    %ecx,(%eax)
  80042e:	8b 02                	mov    (%edx),%eax
  800430:	ba 00 00 00 00       	mov    $0x0,%edx
  800435:	eb 0e                	jmp    800445 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800437:	8b 10                	mov    (%eax),%edx
  800439:	8d 4a 04             	lea    0x4(%edx),%ecx
  80043c:	89 08                	mov    %ecx,(%eax)
  80043e:	8b 02                	mov    (%edx),%eax
  800440:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800445:	5d                   	pop    %ebp
  800446:	c3                   	ret    

00800447 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800447:	55                   	push   %ebp
  800448:	89 e5                	mov    %esp,%ebp
  80044a:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80044d:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800450:	8b 10                	mov    (%eax),%edx
  800452:	3b 50 04             	cmp    0x4(%eax),%edx
  800455:	73 0a                	jae    800461 <sprintputch+0x1a>
		*b->buf++ = ch;
  800457:	8d 4a 01             	lea    0x1(%edx),%ecx
  80045a:	89 08                	mov    %ecx,(%eax)
  80045c:	8b 45 08             	mov    0x8(%ebp),%eax
  80045f:	88 02                	mov    %al,(%edx)
}
  800461:	5d                   	pop    %ebp
  800462:	c3                   	ret    

00800463 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800463:	55                   	push   %ebp
  800464:	89 e5                	mov    %esp,%ebp
  800466:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800469:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80046c:	50                   	push   %eax
  80046d:	ff 75 10             	pushl  0x10(%ebp)
  800470:	ff 75 0c             	pushl  0xc(%ebp)
  800473:	ff 75 08             	pushl  0x8(%ebp)
  800476:	e8 05 00 00 00       	call   800480 <vprintfmt>
	va_end(ap);
}
  80047b:	83 c4 10             	add    $0x10,%esp
  80047e:	c9                   	leave  
  80047f:	c3                   	ret    

00800480 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800480:	55                   	push   %ebp
  800481:	89 e5                	mov    %esp,%ebp
  800483:	57                   	push   %edi
  800484:	56                   	push   %esi
  800485:	53                   	push   %ebx
  800486:	83 ec 2c             	sub    $0x2c,%esp
  800489:	8b 7d 08             	mov    0x8(%ebp),%edi
  80048c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80048f:	eb 03                	jmp    800494 <vprintfmt+0x14>
			break;

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
			for (fmt--; fmt[-1] != '%'; fmt--)
  800491:	89 75 10             	mov    %esi,0x10(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {    //遍历输入的第一个参数，即输出信息的格式，先把格式字符串中'%'之前的字符一个个输出，因为它们前面没有'%'，所以它们就是要直接显示在屏幕上的
  800494:	8b 45 10             	mov    0x10(%ebp),%eax
  800497:	8d 70 01             	lea    0x1(%eax),%esi
  80049a:	0f b6 00             	movzbl (%eax),%eax
  80049d:	83 f8 25             	cmp    $0x25,%eax
  8004a0:	74 25                	je     8004c7 <vprintfmt+0x47>
			if (ch == '\0')									//当然中间如果遇到'\0'，代表这个字符串的访问结束
  8004a2:	85 c0                	test   %eax,%eax
  8004a4:	75 0d                	jne    8004b3 <vprintfmt+0x33>
  8004a6:	e9 b5 03 00 00       	jmp    800860 <vprintfmt+0x3e0>
  8004ab:	85 c0                	test   %eax,%eax
  8004ad:	0f 84 ad 03 00 00    	je     800860 <vprintfmt+0x3e0>
				return;
			putch(ch, putdat);								//调用putch函数，把一个字符ch输出到putdat指针所指向的地址中所存放的值对应的地址处
  8004b3:	83 ec 08             	sub    $0x8,%esp
  8004b6:	53                   	push   %ebx
  8004b7:	50                   	push   %eax
  8004b8:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {    //遍历输入的第一个参数，即输出信息的格式，先把格式字符串中'%'之前的字符一个个输出，因为它们前面没有'%'，所以它们就是要直接显示在屏幕上的
  8004ba:	46                   	inc    %esi
  8004bb:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  8004bf:	83 c4 10             	add    $0x10,%esp
  8004c2:	83 f8 25             	cmp    $0x25,%eax
  8004c5:	75 e4                	jne    8004ab <vprintfmt+0x2b>
			if (width < 0)									//代表有小数点，但是小数点前面并没有数字，比如'%.6f'这种情况，此时代表整数部分全部显示
				width = 0;			
			goto reswitch;

		case '#':
			altflag = 1;
  8004c7:	c6 45 e3 20          	movb   $0x20,-0x1d(%ebp)
  8004cb:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8004d2:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8004d9:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8004e0:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8004e7:	eb 07                	jmp    8004f0 <vprintfmt+0x70>
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  8004e9:	8b 75 10             	mov    0x10(%ebp),%esi

		// flag to pad on the right
		case '-':											//%后面的'-'代表要进行左对齐输出，右边填空格，如果省略代表右对齐
			padc = '-';										//如果有这个字符代表左对齐，则把对齐方式标志位变为'-'
  8004ec:	c6 45 e3 2d          	movb   $0x2d,-0x1d(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  8004f0:	8d 46 01             	lea    0x1(%esi),%eax
  8004f3:	89 45 10             	mov    %eax,0x10(%ebp)
  8004f6:	0f b6 16             	movzbl (%esi),%edx
  8004f9:	8a 06                	mov    (%esi),%al
  8004fb:	83 e8 23             	sub    $0x23,%eax
  8004fe:	3c 55                	cmp    $0x55,%al
  800500:	0f 87 03 03 00 00    	ja     800809 <vprintfmt+0x389>
  800506:	0f b6 c0             	movzbl %al,%eax
  800509:	ff 24 85 e0 25 80 00 	jmp    *0x8025e0(,%eax,4)
  800510:	8b 75 10             	mov    0x10(%ebp),%esi
			padc = '-';										//如果有这个字符代表左对齐，则把对齐方式标志位变为'-'
			goto reswitch;									//处理下一个字符

		// flag to pad with 0's instead of spaces
		case '0':											//0--有0表示进行对齐输出时填0,如省略表示填入空格，并且如果为0，则一定是右对齐
			padc = '0';										//对其方式标志位变为0
  800513:	c6 45 e3 30          	movb   $0x30,-0x1d(%ebp)
  800517:	eb d7                	jmp    8004f0 <vprintfmt+0x70>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {					//把遇到的位数字符串转换为真实的位数，比如输入的'%40'，代表有效位数为40位，下面的循环就是把precesion的值设置为40
				precision = precision * 10 + ch - '0';
  800519:	8d 42 d0             	lea    -0x30(%edx),%eax
  80051c:	89 c1                	mov    %eax,%ecx
  80051e:	89 45 d0             	mov    %eax,-0x30(%ebp)
				ch = *fmt;
  800521:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  800525:	8d 50 d0             	lea    -0x30(%eax),%edx
  800528:	83 fa 09             	cmp    $0x9,%edx
  80052b:	77 51                	ja     80057e <vprintfmt+0xfe>
  80052d:	8b 75 10             	mov    0x10(%ebp),%esi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {					//把遇到的位数字符串转换为真实的位数，比如输入的'%40'，代表有效位数为40位，下面的循环就是把precesion的值设置为40
  800530:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  800531:	8d 14 89             	lea    (%ecx,%ecx,4),%edx
  800534:	01 d2                	add    %edx,%edx
  800536:	8d 4c 10 d0          	lea    -0x30(%eax,%edx,1),%ecx
				ch = *fmt;
  80053a:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80053d:	8d 50 d0             	lea    -0x30(%eax),%edx
  800540:	83 fa 09             	cmp    $0x9,%edx
  800543:	76 eb                	jbe    800530 <vprintfmt+0xb0>
  800545:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800548:	eb 37                	jmp    800581 <vprintfmt+0x101>
					break;
			}
			goto process_precision;							//跳转到process_precistion子过程

		case '*':											//*--代表有效数字的位数也是由输入参数指定的，比如printf("%*.*f", 10, 2, n)，其中10,2就是用来指定显示的有效数字位数的
			precision = va_arg(ap, int);
  80054a:	8b 45 14             	mov    0x14(%ebp),%eax
  80054d:	8d 50 04             	lea    0x4(%eax),%edx
  800550:	89 55 14             	mov    %edx,0x14(%ebp)
  800553:	8b 00                	mov    (%eax),%eax
  800555:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  800558:	8b 75 10             	mov    0x10(%ebp),%esi
			}
			goto process_precision;							//跳转到process_precistion子过程

		case '*':											//*--代表有效数字的位数也是由输入参数指定的，比如printf("%*.*f", 10, 2, n)，其中10,2就是用来指定显示的有效数字位数的
			precision = va_arg(ap, int);
			goto process_precision;
  80055b:	eb 24                	jmp    800581 <vprintfmt+0x101>
  80055d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800561:	79 07                	jns    80056a <vprintfmt+0xea>
  800563:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  80056a:	8b 75 10             	mov    0x10(%ebp),%esi
  80056d:	eb 81                	jmp    8004f0 <vprintfmt+0x70>
  80056f:	8b 75 10             	mov    0x10(%ebp),%esi
			if (width < 0)									//代表有小数点，但是小数点前面并没有数字，比如'%.6f'这种情况，此时代表整数部分全部显示
				width = 0;			
			goto reswitch;

		case '#':
			altflag = 1;
  800572:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800579:	e9 72 ff ff ff       	jmp    8004f0 <vprintfmt+0x70>
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  80057e:	8b 75 10             	mov    0x10(%ebp),%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:									//处理输出精度，把width字段赋值为刚刚计算出来的precision值，所以width应该是整数部分的有效数字位数
			if (width < 0)
  800581:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800585:	0f 89 65 ff ff ff    	jns    8004f0 <vprintfmt+0x70>
				width = precision, precision = -1;
  80058b:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80058e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800591:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800598:	e9 53 ff ff ff       	jmp    8004f0 <vprintfmt+0x70>
			goto reswitch;

		// long flag (doubled for long long)				
		case 'l':											//如果遇到'l'，代表应该是输入long类型，如果有两个'l'代表long long
			lflag++;										//此时把lflag++
  80059d:	ff 45 d4             	incl   -0x2c(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  8005a0:	8b 75 10             	mov    0x10(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)				
		case 'l':											//如果遇到'l'，代表应该是输入long类型，如果有两个'l'代表long long
			lflag++;										//此时把lflag++
			goto reswitch;
  8005a3:	e9 48 ff ff ff       	jmp    8004f0 <vprintfmt+0x70>

		// character
		case 'c':											//如果是'c'代表显示一个字符
			putch(va_arg(ap, int), putdat);					//调用输出一个字符到内存的函数putch
  8005a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ab:	8d 50 04             	lea    0x4(%eax),%edx
  8005ae:	89 55 14             	mov    %edx,0x14(%ebp)
  8005b1:	83 ec 08             	sub    $0x8,%esp
  8005b4:	53                   	push   %ebx
  8005b5:	ff 30                	pushl  (%eax)
  8005b7:	ff d7                	call   *%edi
			break;
  8005b9:	83 c4 10             	add    $0x10,%esp
  8005bc:	e9 d3 fe ff ff       	jmp    800494 <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8005c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c4:	8d 50 04             	lea    0x4(%eax),%edx
  8005c7:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ca:	8b 00                	mov    (%eax),%eax
  8005cc:	85 c0                	test   %eax,%eax
  8005ce:	79 02                	jns    8005d2 <vprintfmt+0x152>
  8005d0:	f7 d8                	neg    %eax
  8005d2:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005d4:	83 f8 0f             	cmp    $0xf,%eax
  8005d7:	7f 0b                	jg     8005e4 <vprintfmt+0x164>
  8005d9:	8b 04 85 40 27 80 00 	mov    0x802740(,%eax,4),%eax
  8005e0:	85 c0                	test   %eax,%eax
  8005e2:	75 15                	jne    8005f9 <vprintfmt+0x179>
				printfmt(putch, putdat, "error %d", err);
  8005e4:	52                   	push   %edx
  8005e5:	68 bb 24 80 00       	push   $0x8024bb
  8005ea:	53                   	push   %ebx
  8005eb:	57                   	push   %edi
  8005ec:	e8 72 fe ff ff       	call   800463 <printfmt>
  8005f1:	83 c4 10             	add    $0x10,%esp
  8005f4:	e9 9b fe ff ff       	jmp    800494 <vprintfmt+0x14>
			else
				printfmt(putch, putdat, "%s", p);
  8005f9:	50                   	push   %eax
  8005fa:	68 6a 29 80 00       	push   $0x80296a
  8005ff:	53                   	push   %ebx
  800600:	57                   	push   %edi
  800601:	e8 5d fe ff ff       	call   800463 <printfmt>
  800606:	83 c4 10             	add    $0x10,%esp
  800609:	e9 86 fe ff ff       	jmp    800494 <vprintfmt+0x14>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80060e:	8b 45 14             	mov    0x14(%ebp),%eax
  800611:	8d 50 04             	lea    0x4(%eax),%edx
  800614:	89 55 14             	mov    %edx,0x14(%ebp)
  800617:	8b 00                	mov    (%eax),%eax
  800619:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80061c:	85 c0                	test   %eax,%eax
  80061e:	75 07                	jne    800627 <vprintfmt+0x1a7>
				p = "(null)";
  800620:	c7 45 d4 b4 24 80 00 	movl   $0x8024b4,-0x2c(%ebp)
			if (width > 0 && padc != '-')
  800627:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80062a:	85 f6                	test   %esi,%esi
  80062c:	0f 8e fb 01 00 00    	jle    80082d <vprintfmt+0x3ad>
  800632:	80 7d e3 2d          	cmpb   $0x2d,-0x1d(%ebp)
  800636:	0f 84 09 02 00 00    	je     800845 <vprintfmt+0x3c5>
				for (width -= strnlen(p, precision); width > 0; width--)
  80063c:	83 ec 08             	sub    $0x8,%esp
  80063f:	ff 75 d0             	pushl  -0x30(%ebp)
  800642:	ff 75 d4             	pushl  -0x2c(%ebp)
  800645:	e8 ad 02 00 00       	call   8008f7 <strnlen>
  80064a:	89 f1                	mov    %esi,%ecx
  80064c:	29 c1                	sub    %eax,%ecx
  80064e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  800651:	83 c4 10             	add    $0x10,%esp
  800654:	85 c9                	test   %ecx,%ecx
  800656:	0f 8e d1 01 00 00    	jle    80082d <vprintfmt+0x3ad>
					putch(padc, putdat);
  80065c:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  800660:	83 ec 08             	sub    $0x8,%esp
  800663:	53                   	push   %ebx
  800664:	56                   	push   %esi
  800665:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800667:	83 c4 10             	add    $0x10,%esp
  80066a:	ff 4d e4             	decl   -0x1c(%ebp)
  80066d:	75 f1                	jne    800660 <vprintfmt+0x1e0>
  80066f:	e9 b9 01 00 00       	jmp    80082d <vprintfmt+0x3ad>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800674:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800678:	74 19                	je     800693 <vprintfmt+0x213>
  80067a:	0f be c0             	movsbl %al,%eax
  80067d:	83 e8 20             	sub    $0x20,%eax
  800680:	83 f8 5e             	cmp    $0x5e,%eax
  800683:	76 0e                	jbe    800693 <vprintfmt+0x213>
					putch('?', putdat);
  800685:	83 ec 08             	sub    $0x8,%esp
  800688:	53                   	push   %ebx
  800689:	6a 3f                	push   $0x3f
  80068b:	ff 55 08             	call   *0x8(%ebp)
  80068e:	83 c4 10             	add    $0x10,%esp
  800691:	eb 0b                	jmp    80069e <vprintfmt+0x21e>
				else
					putch(ch, putdat);
  800693:	83 ec 08             	sub    $0x8,%esp
  800696:	53                   	push   %ebx
  800697:	52                   	push   %edx
  800698:	ff 55 08             	call   *0x8(%ebp)
  80069b:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80069e:	ff 4d e4             	decl   -0x1c(%ebp)
  8006a1:	46                   	inc    %esi
  8006a2:	8a 46 ff             	mov    -0x1(%esi),%al
  8006a5:	0f be d0             	movsbl %al,%edx
  8006a8:	85 d2                	test   %edx,%edx
  8006aa:	75 1c                	jne    8006c8 <vprintfmt+0x248>
  8006ac:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006af:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8006b3:	7f 1f                	jg     8006d4 <vprintfmt+0x254>
  8006b5:	e9 da fd ff ff       	jmp    800494 <vprintfmt+0x14>
  8006ba:	89 7d 08             	mov    %edi,0x8(%ebp)
  8006bd:	8b 7d d0             	mov    -0x30(%ebp),%edi
  8006c0:	eb 06                	jmp    8006c8 <vprintfmt+0x248>
  8006c2:	89 7d 08             	mov    %edi,0x8(%ebp)
  8006c5:	8b 7d d0             	mov    -0x30(%ebp),%edi
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006c8:	85 ff                	test   %edi,%edi
  8006ca:	78 a8                	js     800674 <vprintfmt+0x1f4>
  8006cc:	4f                   	dec    %edi
  8006cd:	79 a5                	jns    800674 <vprintfmt+0x1f4>
  8006cf:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006d2:	eb db                	jmp    8006af <vprintfmt+0x22f>
  8006d4:	8b 75 e4             	mov    -0x1c(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006d7:	83 ec 08             	sub    $0x8,%esp
  8006da:	53                   	push   %ebx
  8006db:	6a 20                	push   $0x20
  8006dd:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006df:	4e                   	dec    %esi
  8006e0:	83 c4 10             	add    $0x10,%esp
  8006e3:	85 f6                	test   %esi,%esi
  8006e5:	7f f0                	jg     8006d7 <vprintfmt+0x257>
  8006e7:	e9 a8 fd ff ff       	jmp    800494 <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006ec:	83 7d d4 01          	cmpl   $0x1,-0x2c(%ebp)
  8006f0:	7e 16                	jle    800708 <vprintfmt+0x288>
		return va_arg(*ap, long long);
  8006f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f5:	8d 50 08             	lea    0x8(%eax),%edx
  8006f8:	89 55 14             	mov    %edx,0x14(%ebp)
  8006fb:	8b 50 04             	mov    0x4(%eax),%edx
  8006fe:	8b 00                	mov    (%eax),%eax
  800700:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800703:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800706:	eb 34                	jmp    80073c <vprintfmt+0x2bc>
	else if (lflag)
  800708:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80070c:	74 18                	je     800726 <vprintfmt+0x2a6>
		return va_arg(*ap, long);
  80070e:	8b 45 14             	mov    0x14(%ebp),%eax
  800711:	8d 50 04             	lea    0x4(%eax),%edx
  800714:	89 55 14             	mov    %edx,0x14(%ebp)
  800717:	8b 30                	mov    (%eax),%esi
  800719:	89 75 d8             	mov    %esi,-0x28(%ebp)
  80071c:	89 f0                	mov    %esi,%eax
  80071e:	c1 f8 1f             	sar    $0x1f,%eax
  800721:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800724:	eb 16                	jmp    80073c <vprintfmt+0x2bc>
	else
		return va_arg(*ap, int);
  800726:	8b 45 14             	mov    0x14(%ebp),%eax
  800729:	8d 50 04             	lea    0x4(%eax),%edx
  80072c:	89 55 14             	mov    %edx,0x14(%ebp)
  80072f:	8b 30                	mov    (%eax),%esi
  800731:	89 75 d8             	mov    %esi,-0x28(%ebp)
  800734:	89 f0                	mov    %esi,%eax
  800736:	c1 f8 1f             	sar    $0x1f,%eax
  800739:	89 45 dc             	mov    %eax,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80073c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80073f:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
  800742:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800746:	0f 89 8a 00 00 00    	jns    8007d6 <vprintfmt+0x356>
				putch('-', putdat);
  80074c:	83 ec 08             	sub    $0x8,%esp
  80074f:	53                   	push   %ebx
  800750:	6a 2d                	push   $0x2d
  800752:	ff d7                	call   *%edi
				num = -(long long) num;
  800754:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800757:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80075a:	f7 d8                	neg    %eax
  80075c:	83 d2 00             	adc    $0x0,%edx
  80075f:	f7 da                	neg    %edx
  800761:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800764:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800769:	eb 70                	jmp    8007db <vprintfmt+0x35b>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80076b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80076e:	8d 45 14             	lea    0x14(%ebp),%eax
  800771:	e8 97 fc ff ff       	call   80040d <getuint>
			base = 10;
  800776:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80077b:	eb 5e                	jmp    8007db <vprintfmt+0x35b>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
  80077d:	83 ec 08             	sub    $0x8,%esp
  800780:	53                   	push   %ebx
  800781:	6a 30                	push   $0x30
  800783:	ff d7                	call   *%edi
			num = getuint(&ap, lflag);
  800785:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800788:	8d 45 14             	lea    0x14(%ebp),%eax
  80078b:	e8 7d fc ff ff       	call   80040d <getuint>
			base = 8;
			goto number;
  800790:	83 c4 10             	add    $0x10,%esp
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  800793:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800798:	eb 41                	jmp    8007db <vprintfmt+0x35b>
		// pointer
		case 'p':
			putch('0', putdat);
  80079a:	83 ec 08             	sub    $0x8,%esp
  80079d:	53                   	push   %ebx
  80079e:	6a 30                	push   $0x30
  8007a0:	ff d7                	call   *%edi
			putch('x', putdat);
  8007a2:	83 c4 08             	add    $0x8,%esp
  8007a5:	53                   	push   %ebx
  8007a6:	6a 78                	push   $0x78
  8007a8:	ff d7                	call   *%edi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8007aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ad:	8d 50 04             	lea    0x4(%eax),%edx
  8007b0:	89 55 14             	mov    %edx,0x14(%ebp)
			goto number;
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8007b3:	8b 00                	mov    (%eax),%eax
  8007b5:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8007ba:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8007bd:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8007c2:	eb 17                	jmp    8007db <vprintfmt+0x35b>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8007c4:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8007c7:	8d 45 14             	lea    0x14(%ebp),%eax
  8007ca:	e8 3e fc ff ff       	call   80040d <getuint>
			base = 16;
  8007cf:	b9 10 00 00 00       	mov    $0x10,%ecx
  8007d4:	eb 05                	jmp    8007db <vprintfmt+0x35b>
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8007d6:	b9 0a 00 00 00       	mov    $0xa,%ecx
		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007db:	83 ec 0c             	sub    $0xc,%esp
  8007de:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  8007e2:	56                   	push   %esi
  8007e3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8007e6:	51                   	push   %ecx
  8007e7:	52                   	push   %edx
  8007e8:	50                   	push   %eax
  8007e9:	89 da                	mov    %ebx,%edx
  8007eb:	89 f8                	mov    %edi,%eax
  8007ed:	e8 6b fb ff ff       	call   80035d <printnum>
			break;
  8007f2:	83 c4 20             	add    $0x20,%esp
  8007f5:	e9 9a fc ff ff       	jmp    800494 <vprintfmt+0x14>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007fa:	83 ec 08             	sub    $0x8,%esp
  8007fd:	53                   	push   %ebx
  8007fe:	52                   	push   %edx
  8007ff:	ff d7                	call   *%edi
			break;
  800801:	83 c4 10             	add    $0x10,%esp
  800804:	e9 8b fc ff ff       	jmp    800494 <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800809:	83 ec 08             	sub    $0x8,%esp
  80080c:	53                   	push   %ebx
  80080d:	6a 25                	push   $0x25
  80080f:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800811:	83 c4 10             	add    $0x10,%esp
  800814:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800818:	0f 84 73 fc ff ff    	je     800491 <vprintfmt+0x11>
  80081e:	4e                   	dec    %esi
  80081f:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800823:	75 f9                	jne    80081e <vprintfmt+0x39e>
  800825:	89 75 10             	mov    %esi,0x10(%ebp)
  800828:	e9 67 fc ff ff       	jmp    800494 <vprintfmt+0x14>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80082d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800830:	8d 70 01             	lea    0x1(%eax),%esi
  800833:	8a 00                	mov    (%eax),%al
  800835:	0f be d0             	movsbl %al,%edx
  800838:	85 d2                	test   %edx,%edx
  80083a:	0f 85 7a fe ff ff    	jne    8006ba <vprintfmt+0x23a>
  800840:	e9 4f fc ff ff       	jmp    800494 <vprintfmt+0x14>
  800845:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800848:	8d 70 01             	lea    0x1(%eax),%esi
  80084b:	8a 00                	mov    (%eax),%al
  80084d:	0f be d0             	movsbl %al,%edx
  800850:	85 d2                	test   %edx,%edx
  800852:	0f 85 6a fe ff ff    	jne    8006c2 <vprintfmt+0x242>
  800858:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80085b:	e9 77 fe ff ff       	jmp    8006d7 <vprintfmt+0x257>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800860:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800863:	5b                   	pop    %ebx
  800864:	5e                   	pop    %esi
  800865:	5f                   	pop    %edi
  800866:	5d                   	pop    %ebp
  800867:	c3                   	ret    

00800868 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800868:	55                   	push   %ebp
  800869:	89 e5                	mov    %esp,%ebp
  80086b:	83 ec 18             	sub    $0x18,%esp
  80086e:	8b 45 08             	mov    0x8(%ebp),%eax
  800871:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800874:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800877:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80087b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80087e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800885:	85 c0                	test   %eax,%eax
  800887:	74 26                	je     8008af <vsnprintf+0x47>
  800889:	85 d2                	test   %edx,%edx
  80088b:	7e 29                	jle    8008b6 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80088d:	ff 75 14             	pushl  0x14(%ebp)
  800890:	ff 75 10             	pushl  0x10(%ebp)
  800893:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800896:	50                   	push   %eax
  800897:	68 47 04 80 00       	push   $0x800447
  80089c:	e8 df fb ff ff       	call   800480 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008a1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008a4:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008aa:	83 c4 10             	add    $0x10,%esp
  8008ad:	eb 0c                	jmp    8008bb <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8008af:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008b4:	eb 05                	jmp    8008bb <vsnprintf+0x53>
  8008b6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8008bb:	c9                   	leave  
  8008bc:	c3                   	ret    

008008bd <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008bd:	55                   	push   %ebp
  8008be:	89 e5                	mov    %esp,%ebp
  8008c0:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008c3:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008c6:	50                   	push   %eax
  8008c7:	ff 75 10             	pushl  0x10(%ebp)
  8008ca:	ff 75 0c             	pushl  0xc(%ebp)
  8008cd:	ff 75 08             	pushl  0x8(%ebp)
  8008d0:	e8 93 ff ff ff       	call   800868 <vsnprintf>
	va_end(ap);

	return rc;
}
  8008d5:	c9                   	leave  
  8008d6:	c3                   	ret    

008008d7 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008d7:	55                   	push   %ebp
  8008d8:	89 e5                	mov    %esp,%ebp
  8008da:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008dd:	80 3a 00             	cmpb   $0x0,(%edx)
  8008e0:	74 0e                	je     8008f0 <strlen+0x19>
  8008e2:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8008e7:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8008e8:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008ec:	75 f9                	jne    8008e7 <strlen+0x10>
  8008ee:	eb 05                	jmp    8008f5 <strlen+0x1e>
  8008f0:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8008f5:	5d                   	pop    %ebp
  8008f6:	c3                   	ret    

008008f7 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008f7:	55                   	push   %ebp
  8008f8:	89 e5                	mov    %esp,%ebp
  8008fa:	53                   	push   %ebx
  8008fb:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8008fe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800901:	85 c9                	test   %ecx,%ecx
  800903:	74 1a                	je     80091f <strnlen+0x28>
  800905:	80 3b 00             	cmpb   $0x0,(%ebx)
  800908:	74 1c                	je     800926 <strnlen+0x2f>
  80090a:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  80090f:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800911:	39 ca                	cmp    %ecx,%edx
  800913:	74 16                	je     80092b <strnlen+0x34>
  800915:	42                   	inc    %edx
  800916:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  80091b:	75 f2                	jne    80090f <strnlen+0x18>
  80091d:	eb 0c                	jmp    80092b <strnlen+0x34>
  80091f:	b8 00 00 00 00       	mov    $0x0,%eax
  800924:	eb 05                	jmp    80092b <strnlen+0x34>
  800926:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  80092b:	5b                   	pop    %ebx
  80092c:	5d                   	pop    %ebp
  80092d:	c3                   	ret    

0080092e <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80092e:	55                   	push   %ebp
  80092f:	89 e5                	mov    %esp,%ebp
  800931:	53                   	push   %ebx
  800932:	8b 45 08             	mov    0x8(%ebp),%eax
  800935:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800938:	89 c2                	mov    %eax,%edx
  80093a:	42                   	inc    %edx
  80093b:	41                   	inc    %ecx
  80093c:	8a 59 ff             	mov    -0x1(%ecx),%bl
  80093f:	88 5a ff             	mov    %bl,-0x1(%edx)
  800942:	84 db                	test   %bl,%bl
  800944:	75 f4                	jne    80093a <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800946:	5b                   	pop    %ebx
  800947:	5d                   	pop    %ebp
  800948:	c3                   	ret    

00800949 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800949:	55                   	push   %ebp
  80094a:	89 e5                	mov    %esp,%ebp
  80094c:	53                   	push   %ebx
  80094d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800950:	53                   	push   %ebx
  800951:	e8 81 ff ff ff       	call   8008d7 <strlen>
  800956:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800959:	ff 75 0c             	pushl  0xc(%ebp)
  80095c:	01 d8                	add    %ebx,%eax
  80095e:	50                   	push   %eax
  80095f:	e8 ca ff ff ff       	call   80092e <strcpy>
	return dst;
}
  800964:	89 d8                	mov    %ebx,%eax
  800966:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800969:	c9                   	leave  
  80096a:	c3                   	ret    

0080096b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80096b:	55                   	push   %ebp
  80096c:	89 e5                	mov    %esp,%ebp
  80096e:	56                   	push   %esi
  80096f:	53                   	push   %ebx
  800970:	8b 75 08             	mov    0x8(%ebp),%esi
  800973:	8b 55 0c             	mov    0xc(%ebp),%edx
  800976:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800979:	85 db                	test   %ebx,%ebx
  80097b:	74 14                	je     800991 <strncpy+0x26>
  80097d:	01 f3                	add    %esi,%ebx
  80097f:	89 f1                	mov    %esi,%ecx
		*dst++ = *src;
  800981:	41                   	inc    %ecx
  800982:	8a 02                	mov    (%edx),%al
  800984:	88 41 ff             	mov    %al,-0x1(%ecx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800987:	80 3a 01             	cmpb   $0x1,(%edx)
  80098a:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80098d:	39 cb                	cmp    %ecx,%ebx
  80098f:	75 f0                	jne    800981 <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800991:	89 f0                	mov    %esi,%eax
  800993:	5b                   	pop    %ebx
  800994:	5e                   	pop    %esi
  800995:	5d                   	pop    %ebp
  800996:	c3                   	ret    

00800997 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800997:	55                   	push   %ebp
  800998:	89 e5                	mov    %esp,%ebp
  80099a:	53                   	push   %ebx
  80099b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80099e:	8b 45 10             	mov    0x10(%ebp),%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009a1:	85 c0                	test   %eax,%eax
  8009a3:	74 30                	je     8009d5 <strlcpy+0x3e>
		while (--size > 0 && *src != '\0')
  8009a5:	48                   	dec    %eax
  8009a6:	74 20                	je     8009c8 <strlcpy+0x31>
  8009a8:	8a 0b                	mov    (%ebx),%cl
  8009aa:	84 c9                	test   %cl,%cl
  8009ac:	74 1f                	je     8009cd <strlcpy+0x36>
  8009ae:	8d 53 01             	lea    0x1(%ebx),%edx
  8009b1:	01 c3                	add    %eax,%ebx
  8009b3:	8b 45 08             	mov    0x8(%ebp),%eax
			*dst++ = *src++;
  8009b6:	40                   	inc    %eax
  8009b7:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8009ba:	39 da                	cmp    %ebx,%edx
  8009bc:	74 12                	je     8009d0 <strlcpy+0x39>
  8009be:	42                   	inc    %edx
  8009bf:	8a 4a ff             	mov    -0x1(%edx),%cl
  8009c2:	84 c9                	test   %cl,%cl
  8009c4:	75 f0                	jne    8009b6 <strlcpy+0x1f>
  8009c6:	eb 08                	jmp    8009d0 <strlcpy+0x39>
  8009c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009cb:	eb 03                	jmp    8009d0 <strlcpy+0x39>
  8009cd:	8b 45 08             	mov    0x8(%ebp),%eax
			*dst++ = *src++;
		*dst = '\0';
  8009d0:	c6 00 00             	movb   $0x0,(%eax)
  8009d3:	eb 03                	jmp    8009d8 <strlcpy+0x41>
  8009d5:	8b 45 08             	mov    0x8(%ebp),%eax
	}
	return dst - dst_in;
  8009d8:	2b 45 08             	sub    0x8(%ebp),%eax
}
  8009db:	5b                   	pop    %ebx
  8009dc:	5d                   	pop    %ebp
  8009dd:	c3                   	ret    

008009de <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009de:	55                   	push   %ebp
  8009df:	89 e5                	mov    %esp,%ebp
  8009e1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009e4:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009e7:	8a 01                	mov    (%ecx),%al
  8009e9:	84 c0                	test   %al,%al
  8009eb:	74 10                	je     8009fd <strcmp+0x1f>
  8009ed:	3a 02                	cmp    (%edx),%al
  8009ef:	75 0c                	jne    8009fd <strcmp+0x1f>
		p++, q++;
  8009f1:	41                   	inc    %ecx
  8009f2:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8009f3:	8a 01                	mov    (%ecx),%al
  8009f5:	84 c0                	test   %al,%al
  8009f7:	74 04                	je     8009fd <strcmp+0x1f>
  8009f9:	3a 02                	cmp    (%edx),%al
  8009fb:	74 f4                	je     8009f1 <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009fd:	0f b6 c0             	movzbl %al,%eax
  800a00:	0f b6 12             	movzbl (%edx),%edx
  800a03:	29 d0                	sub    %edx,%eax
}
  800a05:	5d                   	pop    %ebp
  800a06:	c3                   	ret    

00800a07 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a07:	55                   	push   %ebp
  800a08:	89 e5                	mov    %esp,%ebp
  800a0a:	56                   	push   %esi
  800a0b:	53                   	push   %ebx
  800a0c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800a0f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a12:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  800a15:	85 f6                	test   %esi,%esi
  800a17:	74 23                	je     800a3c <strncmp+0x35>
  800a19:	8a 03                	mov    (%ebx),%al
  800a1b:	84 c0                	test   %al,%al
  800a1d:	74 2b                	je     800a4a <strncmp+0x43>
  800a1f:	3a 02                	cmp    (%edx),%al
  800a21:	75 27                	jne    800a4a <strncmp+0x43>
  800a23:	8d 43 01             	lea    0x1(%ebx),%eax
  800a26:	01 de                	add    %ebx,%esi
		n--, p++, q++;
  800a28:	89 c3                	mov    %eax,%ebx
  800a2a:	42                   	inc    %edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a2b:	39 c6                	cmp    %eax,%esi
  800a2d:	74 14                	je     800a43 <strncmp+0x3c>
  800a2f:	8a 08                	mov    (%eax),%cl
  800a31:	84 c9                	test   %cl,%cl
  800a33:	74 15                	je     800a4a <strncmp+0x43>
  800a35:	40                   	inc    %eax
  800a36:	3a 0a                	cmp    (%edx),%cl
  800a38:	74 ee                	je     800a28 <strncmp+0x21>
  800a3a:	eb 0e                	jmp    800a4a <strncmp+0x43>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a3c:	b8 00 00 00 00       	mov    $0x0,%eax
  800a41:	eb 0f                	jmp    800a52 <strncmp+0x4b>
  800a43:	b8 00 00 00 00       	mov    $0x0,%eax
  800a48:	eb 08                	jmp    800a52 <strncmp+0x4b>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a4a:	0f b6 03             	movzbl (%ebx),%eax
  800a4d:	0f b6 12             	movzbl (%edx),%edx
  800a50:	29 d0                	sub    %edx,%eax
}
  800a52:	5b                   	pop    %ebx
  800a53:	5e                   	pop    %esi
  800a54:	5d                   	pop    %ebp
  800a55:	c3                   	ret    

00800a56 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a56:	55                   	push   %ebp
  800a57:	89 e5                	mov    %esp,%ebp
  800a59:	53                   	push   %ebx
  800a5a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a5d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  800a60:	8a 10                	mov    (%eax),%dl
  800a62:	84 d2                	test   %dl,%dl
  800a64:	74 1a                	je     800a80 <strchr+0x2a>
  800a66:	88 d9                	mov    %bl,%cl
		if (*s == c)
  800a68:	38 d3                	cmp    %dl,%bl
  800a6a:	75 06                	jne    800a72 <strchr+0x1c>
  800a6c:	eb 17                	jmp    800a85 <strchr+0x2f>
  800a6e:	38 ca                	cmp    %cl,%dl
  800a70:	74 13                	je     800a85 <strchr+0x2f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a72:	40                   	inc    %eax
  800a73:	8a 10                	mov    (%eax),%dl
  800a75:	84 d2                	test   %dl,%dl
  800a77:	75 f5                	jne    800a6e <strchr+0x18>
		if (*s == c)
			return (char *) s;
	return 0;
  800a79:	b8 00 00 00 00       	mov    $0x0,%eax
  800a7e:	eb 05                	jmp    800a85 <strchr+0x2f>
  800a80:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a85:	5b                   	pop    %ebx
  800a86:	5d                   	pop    %ebp
  800a87:	c3                   	ret    

00800a88 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a88:	55                   	push   %ebp
  800a89:	89 e5                	mov    %esp,%ebp
  800a8b:	53                   	push   %ebx
  800a8c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a8f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  800a92:	8a 10                	mov    (%eax),%dl
  800a94:	84 d2                	test   %dl,%dl
  800a96:	74 13                	je     800aab <strfind+0x23>
  800a98:	88 d9                	mov    %bl,%cl
		if (*s == c)
  800a9a:	38 d3                	cmp    %dl,%bl
  800a9c:	75 06                	jne    800aa4 <strfind+0x1c>
  800a9e:	eb 0b                	jmp    800aab <strfind+0x23>
  800aa0:	38 ca                	cmp    %cl,%dl
  800aa2:	74 07                	je     800aab <strfind+0x23>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800aa4:	40                   	inc    %eax
  800aa5:	8a 10                	mov    (%eax),%dl
  800aa7:	84 d2                	test   %dl,%dl
  800aa9:	75 f5                	jne    800aa0 <strfind+0x18>
		if (*s == c)
			break;
	return (char *) s;
}
  800aab:	5b                   	pop    %ebx
  800aac:	5d                   	pop    %ebp
  800aad:	c3                   	ret    

00800aae <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800aae:	55                   	push   %ebp
  800aaf:	89 e5                	mov    %esp,%ebp
  800ab1:	57                   	push   %edi
  800ab2:	56                   	push   %esi
  800ab3:	53                   	push   %ebx
  800ab4:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ab7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800aba:	85 c9                	test   %ecx,%ecx
  800abc:	74 36                	je     800af4 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800abe:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800ac4:	75 28                	jne    800aee <memset+0x40>
  800ac6:	f6 c1 03             	test   $0x3,%cl
  800ac9:	75 23                	jne    800aee <memset+0x40>
		c &= 0xFF;
  800acb:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800acf:	89 d3                	mov    %edx,%ebx
  800ad1:	c1 e3 08             	shl    $0x8,%ebx
  800ad4:	89 d6                	mov    %edx,%esi
  800ad6:	c1 e6 18             	shl    $0x18,%esi
  800ad9:	89 d0                	mov    %edx,%eax
  800adb:	c1 e0 10             	shl    $0x10,%eax
  800ade:	09 f0                	or     %esi,%eax
  800ae0:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800ae2:	89 d8                	mov    %ebx,%eax
  800ae4:	09 d0                	or     %edx,%eax
  800ae6:	c1 e9 02             	shr    $0x2,%ecx
  800ae9:	fc                   	cld    
  800aea:	f3 ab                	rep stos %eax,%es:(%edi)
  800aec:	eb 06                	jmp    800af4 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800aee:	8b 45 0c             	mov    0xc(%ebp),%eax
  800af1:	fc                   	cld    
  800af2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800af4:	89 f8                	mov    %edi,%eax
  800af6:	5b                   	pop    %ebx
  800af7:	5e                   	pop    %esi
  800af8:	5f                   	pop    %edi
  800af9:	5d                   	pop    %ebp
  800afa:	c3                   	ret    

00800afb <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800afb:	55                   	push   %ebp
  800afc:	89 e5                	mov    %esp,%ebp
  800afe:	57                   	push   %edi
  800aff:	56                   	push   %esi
  800b00:	8b 45 08             	mov    0x8(%ebp),%eax
  800b03:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b06:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b09:	39 c6                	cmp    %eax,%esi
  800b0b:	73 33                	jae    800b40 <memmove+0x45>
  800b0d:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b10:	39 d0                	cmp    %edx,%eax
  800b12:	73 2c                	jae    800b40 <memmove+0x45>
		s += n;
		d += n;
  800b14:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b17:	89 d6                	mov    %edx,%esi
  800b19:	09 fe                	or     %edi,%esi
  800b1b:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b21:	75 13                	jne    800b36 <memmove+0x3b>
  800b23:	f6 c1 03             	test   $0x3,%cl
  800b26:	75 0e                	jne    800b36 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800b28:	83 ef 04             	sub    $0x4,%edi
  800b2b:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b2e:	c1 e9 02             	shr    $0x2,%ecx
  800b31:	fd                   	std    
  800b32:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b34:	eb 07                	jmp    800b3d <memmove+0x42>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b36:	4f                   	dec    %edi
  800b37:	8d 72 ff             	lea    -0x1(%edx),%esi
  800b3a:	fd                   	std    
  800b3b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b3d:	fc                   	cld    
  800b3e:	eb 1d                	jmp    800b5d <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b40:	89 f2                	mov    %esi,%edx
  800b42:	09 c2                	or     %eax,%edx
  800b44:	f6 c2 03             	test   $0x3,%dl
  800b47:	75 0f                	jne    800b58 <memmove+0x5d>
  800b49:	f6 c1 03             	test   $0x3,%cl
  800b4c:	75 0a                	jne    800b58 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
  800b4e:	c1 e9 02             	shr    $0x2,%ecx
  800b51:	89 c7                	mov    %eax,%edi
  800b53:	fc                   	cld    
  800b54:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b56:	eb 05                	jmp    800b5d <memmove+0x62>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b58:	89 c7                	mov    %eax,%edi
  800b5a:	fc                   	cld    
  800b5b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b5d:	5e                   	pop    %esi
  800b5e:	5f                   	pop    %edi
  800b5f:	5d                   	pop    %ebp
  800b60:	c3                   	ret    

00800b61 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b61:	55                   	push   %ebp
  800b62:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b64:	ff 75 10             	pushl  0x10(%ebp)
  800b67:	ff 75 0c             	pushl  0xc(%ebp)
  800b6a:	ff 75 08             	pushl  0x8(%ebp)
  800b6d:	e8 89 ff ff ff       	call   800afb <memmove>
}
  800b72:	c9                   	leave  
  800b73:	c3                   	ret    

00800b74 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b74:	55                   	push   %ebp
  800b75:	89 e5                	mov    %esp,%ebp
  800b77:	57                   	push   %edi
  800b78:	56                   	push   %esi
  800b79:	53                   	push   %ebx
  800b7a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800b7d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b80:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b83:	85 c0                	test   %eax,%eax
  800b85:	74 33                	je     800bba <memcmp+0x46>
  800b87:	8d 78 ff             	lea    -0x1(%eax),%edi
		if (*s1 != *s2)
  800b8a:	8a 13                	mov    (%ebx),%dl
  800b8c:	8a 0e                	mov    (%esi),%cl
  800b8e:	38 ca                	cmp    %cl,%dl
  800b90:	75 13                	jne    800ba5 <memcmp+0x31>
  800b92:	b8 00 00 00 00       	mov    $0x0,%eax
  800b97:	eb 16                	jmp    800baf <memcmp+0x3b>
  800b99:	8a 54 03 01          	mov    0x1(%ebx,%eax,1),%dl
  800b9d:	40                   	inc    %eax
  800b9e:	8a 0c 06             	mov    (%esi,%eax,1),%cl
  800ba1:	38 ca                	cmp    %cl,%dl
  800ba3:	74 0a                	je     800baf <memcmp+0x3b>
			return (int) *s1 - (int) *s2;
  800ba5:	0f b6 c2             	movzbl %dl,%eax
  800ba8:	0f b6 c9             	movzbl %cl,%ecx
  800bab:	29 c8                	sub    %ecx,%eax
  800bad:	eb 10                	jmp    800bbf <memcmp+0x4b>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800baf:	39 f8                	cmp    %edi,%eax
  800bb1:	75 e6                	jne    800b99 <memcmp+0x25>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800bb3:	b8 00 00 00 00       	mov    $0x0,%eax
  800bb8:	eb 05                	jmp    800bbf <memcmp+0x4b>
  800bba:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bbf:	5b                   	pop    %ebx
  800bc0:	5e                   	pop    %esi
  800bc1:	5f                   	pop    %edi
  800bc2:	5d                   	pop    %ebp
  800bc3:	c3                   	ret    

00800bc4 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800bc4:	55                   	push   %ebp
  800bc5:	89 e5                	mov    %esp,%ebp
  800bc7:	53                   	push   %ebx
  800bc8:	8b 55 08             	mov    0x8(%ebp),%edx
	const void *ends = (const char *) s + n;
  800bcb:	89 d0                	mov    %edx,%eax
  800bcd:	03 45 10             	add    0x10(%ebp),%eax
	for (; s < ends; s++)
  800bd0:	39 c2                	cmp    %eax,%edx
  800bd2:	73 1b                	jae    800bef <memfind+0x2b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800bd4:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
  800bd8:	0f b6 0a             	movzbl (%edx),%ecx
  800bdb:	39 d9                	cmp    %ebx,%ecx
  800bdd:	75 09                	jne    800be8 <memfind+0x24>
  800bdf:	eb 12                	jmp    800bf3 <memfind+0x2f>
  800be1:	0f b6 0a             	movzbl (%edx),%ecx
  800be4:	39 d9                	cmp    %ebx,%ecx
  800be6:	74 0f                	je     800bf7 <memfind+0x33>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800be8:	42                   	inc    %edx
  800be9:	39 d0                	cmp    %edx,%eax
  800beb:	75 f4                	jne    800be1 <memfind+0x1d>
  800bed:	eb 0a                	jmp    800bf9 <memfind+0x35>
  800bef:	89 d0                	mov    %edx,%eax
  800bf1:	eb 06                	jmp    800bf9 <memfind+0x35>
		if (*(const unsigned char *) s == (unsigned char) c)
  800bf3:	89 d0                	mov    %edx,%eax
  800bf5:	eb 02                	jmp    800bf9 <memfind+0x35>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bf7:	89 d0                	mov    %edx,%eax
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800bf9:	5b                   	pop    %ebx
  800bfa:	5d                   	pop    %ebp
  800bfb:	c3                   	ret    

00800bfc <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800bfc:	55                   	push   %ebp
  800bfd:	89 e5                	mov    %esp,%ebp
  800bff:	57                   	push   %edi
  800c00:	56                   	push   %esi
  800c01:	53                   	push   %ebx
  800c02:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c05:	eb 01                	jmp    800c08 <strtol+0xc>
		s++;
  800c07:	41                   	inc    %ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c08:	8a 01                	mov    (%ecx),%al
  800c0a:	3c 20                	cmp    $0x20,%al
  800c0c:	74 f9                	je     800c07 <strtol+0xb>
  800c0e:	3c 09                	cmp    $0x9,%al
  800c10:	74 f5                	je     800c07 <strtol+0xb>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c12:	3c 2b                	cmp    $0x2b,%al
  800c14:	75 08                	jne    800c1e <strtol+0x22>
		s++;
  800c16:	41                   	inc    %ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c17:	bf 00 00 00 00       	mov    $0x0,%edi
  800c1c:	eb 11                	jmp    800c2f <strtol+0x33>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c1e:	3c 2d                	cmp    $0x2d,%al
  800c20:	75 08                	jne    800c2a <strtol+0x2e>
		s++, neg = 1;
  800c22:	41                   	inc    %ecx
  800c23:	bf 01 00 00 00       	mov    $0x1,%edi
  800c28:	eb 05                	jmp    800c2f <strtol+0x33>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c2a:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c2f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800c33:	0f 84 87 00 00 00    	je     800cc0 <strtol+0xc4>
  800c39:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  800c3d:	75 27                	jne    800c66 <strtol+0x6a>
  800c3f:	80 39 30             	cmpb   $0x30,(%ecx)
  800c42:	75 22                	jne    800c66 <strtol+0x6a>
  800c44:	e9 88 00 00 00       	jmp    800cd1 <strtol+0xd5>
		s += 2, base = 16;
  800c49:	83 c1 02             	add    $0x2,%ecx
  800c4c:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  800c53:	eb 11                	jmp    800c66 <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
  800c55:	41                   	inc    %ecx
  800c56:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  800c5d:	eb 07                	jmp    800c66 <strtol+0x6a>
	else if (base == 0)
		base = 10;
  800c5f:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)
  800c66:	b8 00 00 00 00       	mov    $0x0,%eax

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c6b:	8a 11                	mov    (%ecx),%dl
  800c6d:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800c70:	80 fb 09             	cmp    $0x9,%bl
  800c73:	77 08                	ja     800c7d <strtol+0x81>
			dig = *s - '0';
  800c75:	0f be d2             	movsbl %dl,%edx
  800c78:	83 ea 30             	sub    $0x30,%edx
  800c7b:	eb 22                	jmp    800c9f <strtol+0xa3>
		else if (*s >= 'a' && *s <= 'z')
  800c7d:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c80:	89 f3                	mov    %esi,%ebx
  800c82:	80 fb 19             	cmp    $0x19,%bl
  800c85:	77 08                	ja     800c8f <strtol+0x93>
			dig = *s - 'a' + 10;
  800c87:	0f be d2             	movsbl %dl,%edx
  800c8a:	83 ea 57             	sub    $0x57,%edx
  800c8d:	eb 10                	jmp    800c9f <strtol+0xa3>
		else if (*s >= 'A' && *s <= 'Z')
  800c8f:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c92:	89 f3                	mov    %esi,%ebx
  800c94:	80 fb 19             	cmp    $0x19,%bl
  800c97:	77 14                	ja     800cad <strtol+0xb1>
			dig = *s - 'A' + 10;
  800c99:	0f be d2             	movsbl %dl,%edx
  800c9c:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800c9f:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ca2:	7d 09                	jge    800cad <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800ca4:	41                   	inc    %ecx
  800ca5:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ca9:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800cab:	eb be                	jmp    800c6b <strtol+0x6f>

	if (endptr)
  800cad:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800cb1:	74 05                	je     800cb8 <strtol+0xbc>
		*endptr = (char *) s;
  800cb3:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cb6:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800cb8:	85 ff                	test   %edi,%edi
  800cba:	74 21                	je     800cdd <strtol+0xe1>
  800cbc:	f7 d8                	neg    %eax
  800cbe:	eb 1d                	jmp    800cdd <strtol+0xe1>
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800cc0:	80 39 30             	cmpb   $0x30,(%ecx)
  800cc3:	75 9a                	jne    800c5f <strtol+0x63>
  800cc5:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800cc9:	0f 84 7a ff ff ff    	je     800c49 <strtol+0x4d>
  800ccf:	eb 84                	jmp    800c55 <strtol+0x59>
  800cd1:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800cd5:	0f 84 6e ff ff ff    	je     800c49 <strtol+0x4d>
  800cdb:	eb 89                	jmp    800c66 <strtol+0x6a>
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
}
  800cdd:	5b                   	pop    %ebx
  800cde:	5e                   	pop    %esi
  800cdf:	5f                   	pop    %edi
  800ce0:	5d                   	pop    %ebp
  800ce1:	c3                   	ret    

00800ce2 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ce2:	55                   	push   %ebp
  800ce3:	89 e5                	mov    %esp,%ebp
  800ce5:	57                   	push   %edi
  800ce6:	56                   	push   %esi
  800ce7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce8:	b8 00 00 00 00       	mov    $0x0,%eax
  800ced:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf0:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf3:	89 c3                	mov    %eax,%ebx
  800cf5:	89 c7                	mov    %eax,%edi
  800cf7:	89 c6                	mov    %eax,%esi
  800cf9:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800cfb:	5b                   	pop    %ebx
  800cfc:	5e                   	pop    %esi
  800cfd:	5f                   	pop    %edi
  800cfe:	5d                   	pop    %ebp
  800cff:	c3                   	ret    

00800d00 <sys_cgetc>:

int
sys_cgetc(void)
{
  800d00:	55                   	push   %ebp
  800d01:	89 e5                	mov    %esp,%ebp
  800d03:	57                   	push   %edi
  800d04:	56                   	push   %esi
  800d05:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d06:	ba 00 00 00 00       	mov    $0x0,%edx
  800d0b:	b8 01 00 00 00       	mov    $0x1,%eax
  800d10:	89 d1                	mov    %edx,%ecx
  800d12:	89 d3                	mov    %edx,%ebx
  800d14:	89 d7                	mov    %edx,%edi
  800d16:	89 d6                	mov    %edx,%esi
  800d18:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800d1a:	5b                   	pop    %ebx
  800d1b:	5e                   	pop    %esi
  800d1c:	5f                   	pop    %edi
  800d1d:	5d                   	pop    %ebp
  800d1e:	c3                   	ret    

00800d1f <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800d1f:	55                   	push   %ebp
  800d20:	89 e5                	mov    %esp,%ebp
  800d22:	57                   	push   %edi
  800d23:	56                   	push   %esi
  800d24:	53                   	push   %ebx
  800d25:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d28:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d2d:	b8 03 00 00 00       	mov    $0x3,%eax
  800d32:	8b 55 08             	mov    0x8(%ebp),%edx
  800d35:	89 cb                	mov    %ecx,%ebx
  800d37:	89 cf                	mov    %ecx,%edi
  800d39:	89 ce                	mov    %ecx,%esi
  800d3b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d3d:	85 c0                	test   %eax,%eax
  800d3f:	7e 17                	jle    800d58 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d41:	83 ec 0c             	sub    $0xc,%esp
  800d44:	50                   	push   %eax
  800d45:	6a 03                	push   $0x3
  800d47:	68 9f 27 80 00       	push   $0x80279f
  800d4c:	6a 23                	push   $0x23
  800d4e:	68 bc 27 80 00       	push   $0x8027bc
  800d53:	e8 19 f5 ff ff       	call   800271 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d58:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d5b:	5b                   	pop    %ebx
  800d5c:	5e                   	pop    %esi
  800d5d:	5f                   	pop    %edi
  800d5e:	5d                   	pop    %ebp
  800d5f:	c3                   	ret    

00800d60 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d60:	55                   	push   %ebp
  800d61:	89 e5                	mov    %esp,%ebp
  800d63:	57                   	push   %edi
  800d64:	56                   	push   %esi
  800d65:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d66:	ba 00 00 00 00       	mov    $0x0,%edx
  800d6b:	b8 02 00 00 00       	mov    $0x2,%eax
  800d70:	89 d1                	mov    %edx,%ecx
  800d72:	89 d3                	mov    %edx,%ebx
  800d74:	89 d7                	mov    %edx,%edi
  800d76:	89 d6                	mov    %edx,%esi
  800d78:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d7a:	5b                   	pop    %ebx
  800d7b:	5e                   	pop    %esi
  800d7c:	5f                   	pop    %edi
  800d7d:	5d                   	pop    %ebp
  800d7e:	c3                   	ret    

00800d7f <sys_yield>:

void
sys_yield(void)
{
  800d7f:	55                   	push   %ebp
  800d80:	89 e5                	mov    %esp,%ebp
  800d82:	57                   	push   %edi
  800d83:	56                   	push   %esi
  800d84:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d85:	ba 00 00 00 00       	mov    $0x0,%edx
  800d8a:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d8f:	89 d1                	mov    %edx,%ecx
  800d91:	89 d3                	mov    %edx,%ebx
  800d93:	89 d7                	mov    %edx,%edi
  800d95:	89 d6                	mov    %edx,%esi
  800d97:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d99:	5b                   	pop    %ebx
  800d9a:	5e                   	pop    %esi
  800d9b:	5f                   	pop    %edi
  800d9c:	5d                   	pop    %ebp
  800d9d:	c3                   	ret    

00800d9e <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
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
  800da7:	be 00 00 00 00       	mov    $0x0,%esi
  800dac:	b8 04 00 00 00       	mov    $0x4,%eax
  800db1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db4:	8b 55 08             	mov    0x8(%ebp),%edx
  800db7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dba:	89 f7                	mov    %esi,%edi
  800dbc:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dbe:	85 c0                	test   %eax,%eax
  800dc0:	7e 17                	jle    800dd9 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dc2:	83 ec 0c             	sub    $0xc,%esp
  800dc5:	50                   	push   %eax
  800dc6:	6a 04                	push   $0x4
  800dc8:	68 9f 27 80 00       	push   $0x80279f
  800dcd:	6a 23                	push   $0x23
  800dcf:	68 bc 27 80 00       	push   $0x8027bc
  800dd4:	e8 98 f4 ff ff       	call   800271 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800dd9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ddc:	5b                   	pop    %ebx
  800ddd:	5e                   	pop    %esi
  800dde:	5f                   	pop    %edi
  800ddf:	5d                   	pop    %ebp
  800de0:	c3                   	ret    

00800de1 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
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
  800dea:	b8 05 00 00 00       	mov    $0x5,%eax
  800def:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800df2:	8b 55 08             	mov    0x8(%ebp),%edx
  800df5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800df8:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dfb:	8b 75 18             	mov    0x18(%ebp),%esi
  800dfe:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e00:	85 c0                	test   %eax,%eax
  800e02:	7e 17                	jle    800e1b <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e04:	83 ec 0c             	sub    $0xc,%esp
  800e07:	50                   	push   %eax
  800e08:	6a 05                	push   $0x5
  800e0a:	68 9f 27 80 00       	push   $0x80279f
  800e0f:	6a 23                	push   $0x23
  800e11:	68 bc 27 80 00       	push   $0x8027bc
  800e16:	e8 56 f4 ff ff       	call   800271 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800e1b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e1e:	5b                   	pop    %ebx
  800e1f:	5e                   	pop    %esi
  800e20:	5f                   	pop    %edi
  800e21:	5d                   	pop    %ebp
  800e22:	c3                   	ret    

00800e23 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
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
  800e31:	b8 06 00 00 00       	mov    $0x6,%eax
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
  800e44:	7e 17                	jle    800e5d <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e46:	83 ec 0c             	sub    $0xc,%esp
  800e49:	50                   	push   %eax
  800e4a:	6a 06                	push   $0x6
  800e4c:	68 9f 27 80 00       	push   $0x80279f
  800e51:	6a 23                	push   $0x23
  800e53:	68 bc 27 80 00       	push   $0x8027bc
  800e58:	e8 14 f4 ff ff       	call   800271 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e5d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e60:	5b                   	pop    %ebx
  800e61:	5e                   	pop    %esi
  800e62:	5f                   	pop    %edi
  800e63:	5d                   	pop    %ebp
  800e64:	c3                   	ret    

00800e65 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
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
  800e73:	b8 08 00 00 00       	mov    $0x8,%eax
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
  800e86:	7e 17                	jle    800e9f <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e88:	83 ec 0c             	sub    $0xc,%esp
  800e8b:	50                   	push   %eax
  800e8c:	6a 08                	push   $0x8
  800e8e:	68 9f 27 80 00       	push   $0x80279f
  800e93:	6a 23                	push   $0x23
  800e95:	68 bc 27 80 00       	push   $0x8027bc
  800e9a:	e8 d2 f3 ff ff       	call   800271 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e9f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ea2:	5b                   	pop    %ebx
  800ea3:	5e                   	pop    %esi
  800ea4:	5f                   	pop    %edi
  800ea5:	5d                   	pop    %ebp
  800ea6:	c3                   	ret    

00800ea7 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
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
  800eb5:	b8 09 00 00 00       	mov    $0x9,%eax
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
  800ec8:	7e 17                	jle    800ee1 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800eca:	83 ec 0c             	sub    $0xc,%esp
  800ecd:	50                   	push   %eax
  800ece:	6a 09                	push   $0x9
  800ed0:	68 9f 27 80 00       	push   $0x80279f
  800ed5:	6a 23                	push   $0x23
  800ed7:	68 bc 27 80 00       	push   $0x8027bc
  800edc:	e8 90 f3 ff ff       	call   800271 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800ee1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ee4:	5b                   	pop    %ebx
  800ee5:	5e                   	pop    %esi
  800ee6:	5f                   	pop    %edi
  800ee7:	5d                   	pop    %ebp
  800ee8:	c3                   	ret    

00800ee9 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ee9:	55                   	push   %ebp
  800eea:	89 e5                	mov    %esp,%ebp
  800eec:	57                   	push   %edi
  800eed:	56                   	push   %esi
  800eee:	53                   	push   %ebx
  800eef:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ef2:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ef7:	b8 0a 00 00 00       	mov    $0xa,%eax
  800efc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eff:	8b 55 08             	mov    0x8(%ebp),%edx
  800f02:	89 df                	mov    %ebx,%edi
  800f04:	89 de                	mov    %ebx,%esi
  800f06:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f08:	85 c0                	test   %eax,%eax
  800f0a:	7e 17                	jle    800f23 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f0c:	83 ec 0c             	sub    $0xc,%esp
  800f0f:	50                   	push   %eax
  800f10:	6a 0a                	push   $0xa
  800f12:	68 9f 27 80 00       	push   $0x80279f
  800f17:	6a 23                	push   $0x23
  800f19:	68 bc 27 80 00       	push   $0x8027bc
  800f1e:	e8 4e f3 ff ff       	call   800271 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800f23:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f26:	5b                   	pop    %ebx
  800f27:	5e                   	pop    %esi
  800f28:	5f                   	pop    %edi
  800f29:	5d                   	pop    %ebp
  800f2a:	c3                   	ret    

00800f2b <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f2b:	55                   	push   %ebp
  800f2c:	89 e5                	mov    %esp,%ebp
  800f2e:	57                   	push   %edi
  800f2f:	56                   	push   %esi
  800f30:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f31:	be 00 00 00 00       	mov    $0x0,%esi
  800f36:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f3b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f3e:	8b 55 08             	mov    0x8(%ebp),%edx
  800f41:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f44:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f47:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f49:	5b                   	pop    %ebx
  800f4a:	5e                   	pop    %esi
  800f4b:	5f                   	pop    %edi
  800f4c:	5d                   	pop    %ebp
  800f4d:	c3                   	ret    

00800f4e <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800f4e:	55                   	push   %ebp
  800f4f:	89 e5                	mov    %esp,%ebp
  800f51:	57                   	push   %edi
  800f52:	56                   	push   %esi
  800f53:	53                   	push   %ebx
  800f54:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f57:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f5c:	b8 0d 00 00 00       	mov    $0xd,%eax
  800f61:	8b 55 08             	mov    0x8(%ebp),%edx
  800f64:	89 cb                	mov    %ecx,%ebx
  800f66:	89 cf                	mov    %ecx,%edi
  800f68:	89 ce                	mov    %ecx,%esi
  800f6a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f6c:	85 c0                	test   %eax,%eax
  800f6e:	7e 17                	jle    800f87 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f70:	83 ec 0c             	sub    $0xc,%esp
  800f73:	50                   	push   %eax
  800f74:	6a 0d                	push   $0xd
  800f76:	68 9f 27 80 00       	push   $0x80279f
  800f7b:	6a 23                	push   $0x23
  800f7d:	68 bc 27 80 00       	push   $0x8027bc
  800f82:	e8 ea f2 ff ff       	call   800271 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f87:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f8a:	5b                   	pop    %ebx
  800f8b:	5e                   	pop    %esi
  800f8c:	5f                   	pop    %edi
  800f8d:	5d                   	pop    %ebp
  800f8e:	c3                   	ret    

00800f8f <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800f8f:	55                   	push   %ebp
  800f90:	89 e5                	mov    %esp,%ebp
  800f92:	56                   	push   %esi
  800f93:	53                   	push   %ebx
  800f94:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800f97:	8b 18                	mov    (%eax),%ebx
	// copy-on-write page.  If not, panic.
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).
	
	if((err & FEC_WR) == 0){
  800f99:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800f9d:	75 14                	jne    800fb3 <pgfault+0x24>
		panic("pgfault not cause by write \n");
  800f9f:	83 ec 04             	sub    $0x4,%esp
  800fa2:	68 ca 27 80 00       	push   $0x8027ca
  800fa7:	6a 1c                	push   $0x1c
  800fa9:	68 e7 27 80 00       	push   $0x8027e7
  800fae:	e8 be f2 ff ff       	call   800271 <_panic>
	}
 
	if ((uvpt[PGNUM(addr)] & PTE_COW) == 0) 
  800fb3:	89 d8                	mov    %ebx,%eax
  800fb5:	c1 e8 0c             	shr    $0xc,%eax
  800fb8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fbf:	f6 c4 08             	test   $0x8,%ah
  800fc2:	75 14                	jne    800fd8 <pgfault+0x49>
    {
        panic("pgfault not cause by COW \n");
  800fc4:	83 ec 04             	sub    $0x4,%esp
  800fc7:	68 f2 27 80 00       	push   $0x8027f2
  800fcc:	6a 21                	push   $0x21
  800fce:	68 e7 27 80 00       	push   $0x8027e7
  800fd3:	e8 99 f2 ff ff       	call   800271 <_panic>
	// copy the data from the old page to the new page, then move the new
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.
	envid_t eid = sys_getenvid();
  800fd8:	e8 83 fd ff ff       	call   800d60 <sys_getenvid>
  800fdd:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(eid,(void*)PFTEMP,PTE_P|PTE_W|PTE_U)) < 0)
  800fdf:	83 ec 04             	sub    $0x4,%esp
  800fe2:	6a 07                	push   $0x7
  800fe4:	68 00 f0 7f 00       	push   $0x7ff000
  800fe9:	50                   	push   %eax
  800fea:	e8 af fd ff ff       	call   800d9e <sys_page_alloc>
  800fef:	83 c4 10             	add    $0x10,%esp
  800ff2:	85 c0                	test   %eax,%eax
  800ff4:	79 14                	jns    80100a <pgfault+0x7b>
		panic("page alloction failed.\n");
  800ff6:	83 ec 04             	sub    $0x4,%esp
  800ff9:	68 0d 28 80 00       	push   $0x80280d
  800ffe:	6a 2d                	push   $0x2d
  801000:	68 e7 27 80 00       	push   $0x8027e7
  801005:	e8 67 f2 ff ff       	call   800271 <_panic>
	addr = ROUNDDOWN(addr,PGSIZE);
  80100a:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memmove(PFTEMP,addr,PGSIZE);
  801010:	83 ec 04             	sub    $0x4,%esp
  801013:	68 00 10 00 00       	push   $0x1000
  801018:	53                   	push   %ebx
  801019:	68 00 f0 7f 00       	push   $0x7ff000
  80101e:	e8 d8 fa ff ff       	call   800afb <memmove>
	if ((r = sys_page_map(eid, PFTEMP, eid, addr, PTE_P | PTE_W |PTE_U)) < 0)
  801023:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  80102a:	53                   	push   %ebx
  80102b:	56                   	push   %esi
  80102c:	68 00 f0 7f 00       	push   $0x7ff000
  801031:	56                   	push   %esi
  801032:	e8 aa fd ff ff       	call   800de1 <sys_page_map>
  801037:	83 c4 20             	add    $0x20,%esp
  80103a:	85 c0                	test   %eax,%eax
  80103c:	79 12                	jns    801050 <pgfault+0xc1>
        panic("pgfault: page map failed %e\n", r);
  80103e:	50                   	push   %eax
  80103f:	68 25 28 80 00       	push   $0x802825
  801044:	6a 31                	push   $0x31
  801046:	68 e7 27 80 00       	push   $0x8027e7
  80104b:	e8 21 f2 ff ff       	call   800271 <_panic>
	if ((r = sys_page_unmap(eid, PFTEMP)) < 0)
  801050:	83 ec 08             	sub    $0x8,%esp
  801053:	68 00 f0 7f 00       	push   $0x7ff000
  801058:	56                   	push   %esi
  801059:	e8 c5 fd ff ff       	call   800e23 <sys_page_unmap>
  80105e:	83 c4 10             	add    $0x10,%esp
  801061:	85 c0                	test   %eax,%eax
  801063:	79 12                	jns    801077 <pgfault+0xe8>
        panic("pgfault: page unmap failed %e\n", r);
  801065:	50                   	push   %eax
  801066:	68 94 28 80 00       	push   $0x802894
  80106b:	6a 33                	push   $0x33
  80106d:	68 e7 27 80 00       	push   $0x8027e7
  801072:	e8 fa f1 ff ff       	call   800271 <_panic>
	// LAB 4: Your code here.

	// panic("pgfault not implemented");
}
  801077:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80107a:	5b                   	pop    %ebx
  80107b:	5e                   	pop    %esi
  80107c:	5d                   	pop    %ebp
  80107d:	c3                   	ret    

0080107e <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  80107e:	55                   	push   %ebp
  80107f:	89 e5                	mov    %esp,%ebp
  801081:	57                   	push   %edi
  801082:	56                   	push   %esi
  801083:	53                   	push   %ebx
  801084:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	struct PageInfo* pg = NULL;
	set_pgfault_handler(pgfault);
  801087:	68 8f 0f 80 00       	push   $0x800f8f
  80108c:	e8 e3 0f 00 00       	call   802074 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801091:	b8 07 00 00 00       	mov    $0x7,%eax
  801096:	cd 30                	int    $0x30
  801098:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80109b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t eid = sys_exofork();
	if (eid < 0) panic("fork fault.\n");
  80109e:	83 c4 10             	add    $0x10,%esp
  8010a1:	85 c0                	test   %eax,%eax
  8010a3:	79 14                	jns    8010b9 <fork+0x3b>
  8010a5:	83 ec 04             	sub    $0x4,%esp
  8010a8:	68 42 28 80 00       	push   $0x802842
  8010ad:	6a 71                	push   $0x71
  8010af:	68 e7 27 80 00       	push   $0x8027e7
  8010b4:	e8 b8 f1 ff ff       	call   800271 <_panic>
	if (eid == 0){
  8010b9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8010bd:	75 25                	jne    8010e4 <fork+0x66>
		thisenv = &envs[ENVX(sys_getenvid())];
  8010bf:	e8 9c fc ff ff       	call   800d60 <sys_getenvid>
  8010c4:	25 ff 03 00 00       	and    $0x3ff,%eax
  8010c9:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8010d0:	c1 e0 07             	shl    $0x7,%eax
  8010d3:	29 d0                	sub    %edx,%eax
  8010d5:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8010da:	a3 04 40 80 00       	mov    %eax,0x804004
		return eid;
  8010df:	e9 61 01 00 00       	jmp    801245 <fork+0x1c7>
  8010e4:	bb 00 00 80 00       	mov    $0x800000,%ebx
	}
	// copy something to the child page.
	for (uintptr_t i = UTEXT;i <= USTACKTOP;i += PGSIZE){
		if (uvpd[PDX(i)] & PTE_P && (uvpt[PGNUM(i)] & PTE_P)){
  8010e9:	89 d8                	mov    %ebx,%eax
  8010eb:	c1 e8 16             	shr    $0x16,%eax
  8010ee:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010f5:	a8 01                	test   $0x1,%al
  8010f7:	74 52                	je     80114b <fork+0xcd>
  8010f9:	89 de                	mov    %ebx,%esi
  8010fb:	c1 ee 0c             	shr    $0xc,%esi
  8010fe:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801105:	a8 01                	test   $0x1,%al
  801107:	74 42                	je     80114b <fork+0xcd>
duppage(envid_t envid, unsigned pn)
{
	int r;

	// LAB 4: Your code here.
	envid_t myenvid = sys_getenvid();
  801109:	e8 52 fc ff ff       	call   800d60 <sys_getenvid>
  80110e:	89 c7                	mov    %eax,%edi
	pte_t pte = uvpt[pn];
  801110:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
	int perm = PTE_U | PTE_P;
	if(pte & PTE_W || pte & PTE_COW)
  801117:	a9 02 08 00 00       	test   $0x802,%eax
  80111c:	0f 85 de 00 00 00    	jne    801200 <fork+0x182>
  801122:	e9 fb 00 00 00       	jmp    801222 <fork+0x1a4>
		perm |= PTE_COW;
	if((r = sys_page_map(myenvid,(void*)(pn*PGSIZE),envid,(void*)(pn*PGSIZE),perm))<0){
		panic("duppage fault :%e\n",r);
  801127:	50                   	push   %eax
  801128:	68 4f 28 80 00       	push   $0x80284f
  80112d:	6a 50                	push   $0x50
  80112f:	68 e7 27 80 00       	push   $0x8027e7
  801134:	e8 38 f1 ff ff       	call   800271 <_panic>
	}
	if(perm & PTE_COW){
		if((r = sys_page_map(myenvid,(void*)(pn*PGSIZE),myenvid,(void*)(pn*PGSIZE),perm))<0)
			panic("duppage fault :%e\n",r);
  801139:	50                   	push   %eax
  80113a:	68 4f 28 80 00       	push   $0x80284f
  80113f:	6a 54                	push   $0x54
  801141:	68 e7 27 80 00       	push   $0x8027e7
  801146:	e8 26 f1 ff ff       	call   800271 <_panic>
	if (eid == 0){
		thisenv = &envs[ENVX(sys_getenvid())];
		return eid;
	}
	// copy something to the child page.
	for (uintptr_t i = UTEXT;i <= USTACKTOP;i += PGSIZE){
  80114b:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801151:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  801157:	75 90                	jne    8010e9 <fork+0x6b>
		if (uvpd[PDX(i)] & PTE_P && (uvpt[PGNUM(i)] & PTE_P)){
			duppage(eid,PGNUM(i));
		}
	}
	int r = sys_page_alloc(eid,(void*)(UXSTACKTOP-PGSIZE),PTE_U|PTE_P|PTE_W);
  801159:	83 ec 04             	sub    $0x4,%esp
  80115c:	6a 07                	push   $0x7
  80115e:	68 00 f0 bf ee       	push   $0xeebff000
  801163:	ff 75 e0             	pushl  -0x20(%ebp)
  801166:	e8 33 fc ff ff       	call   800d9e <sys_page_alloc>
	if (r < 0) panic("fork fault.\n");
  80116b:	83 c4 10             	add    $0x10,%esp
  80116e:	85 c0                	test   %eax,%eax
  801170:	79 14                	jns    801186 <fork+0x108>
  801172:	83 ec 04             	sub    $0x4,%esp
  801175:	68 42 28 80 00       	push   $0x802842
  80117a:	6a 7d                	push   $0x7d
  80117c:	68 e7 27 80 00       	push   $0x8027e7
  801181:	e8 eb f0 ff ff       	call   800271 <_panic>

	extern void _pgfault_upcall();
    r = sys_env_set_pgfault_upcall(eid, _pgfault_upcall);
  801186:	83 ec 08             	sub    $0x8,%esp
  801189:	68 ec 20 80 00       	push   $0x8020ec
  80118e:	ff 75 e0             	pushl  -0x20(%ebp)
  801191:	e8 53 fd ff ff       	call   800ee9 <sys_env_set_pgfault_upcall>
    if (r < 0) panic("fork fault 3\n");
  801196:	83 c4 10             	add    $0x10,%esp
  801199:	85 c0                	test   %eax,%eax
  80119b:	79 17                	jns    8011b4 <fork+0x136>
  80119d:	83 ec 04             	sub    $0x4,%esp
  8011a0:	68 62 28 80 00       	push   $0x802862
  8011a5:	68 81 00 00 00       	push   $0x81
  8011aa:	68 e7 27 80 00       	push   $0x8027e7
  8011af:	e8 bd f0 ff ff       	call   800271 <_panic>

	if ((r = sys_env_set_status(eid, ENV_RUNNABLE)) < 0)
  8011b4:	83 ec 08             	sub    $0x8,%esp
  8011b7:	6a 02                	push   $0x2
  8011b9:	ff 75 e0             	pushl  -0x20(%ebp)
  8011bc:	e8 a4 fc ff ff       	call   800e65 <sys_env_set_status>
  8011c1:	83 c4 10             	add    $0x10,%esp
  8011c4:	85 c0                	test   %eax,%eax
  8011c6:	79 7d                	jns    801245 <fork+0x1c7>
        panic("fork fault 4\n");
  8011c8:	83 ec 04             	sub    $0x4,%esp
  8011cb:	68 70 28 80 00       	push   $0x802870
  8011d0:	68 84 00 00 00       	push   $0x84
  8011d5:	68 e7 27 80 00       	push   $0x8027e7
  8011da:	e8 92 f0 ff ff       	call   800271 <_panic>
		perm |= PTE_COW;
	if((r = sys_page_map(myenvid,(void*)(pn*PGSIZE),envid,(void*)(pn*PGSIZE),perm))<0){
		panic("duppage fault :%e\n",r);
	}
	if(perm & PTE_COW){
		if((r = sys_page_map(myenvid,(void*)(pn*PGSIZE),myenvid,(void*)(pn*PGSIZE),perm))<0)
  8011df:	83 ec 0c             	sub    $0xc,%esp
  8011e2:	68 05 08 00 00       	push   $0x805
  8011e7:	56                   	push   %esi
  8011e8:	57                   	push   %edi
  8011e9:	56                   	push   %esi
  8011ea:	57                   	push   %edi
  8011eb:	e8 f1 fb ff ff       	call   800de1 <sys_page_map>
  8011f0:	83 c4 20             	add    $0x20,%esp
  8011f3:	85 c0                	test   %eax,%eax
  8011f5:	0f 89 50 ff ff ff    	jns    80114b <fork+0xcd>
  8011fb:	e9 39 ff ff ff       	jmp    801139 <fork+0xbb>
	envid_t myenvid = sys_getenvid();
	pte_t pte = uvpt[pn];
	int perm = PTE_U | PTE_P;
	if(pte & PTE_W || pte & PTE_COW)
		perm |= PTE_COW;
	if((r = sys_page_map(myenvid,(void*)(pn*PGSIZE),envid,(void*)(pn*PGSIZE),perm))<0){
  801200:	c1 e6 0c             	shl    $0xc,%esi
  801203:	83 ec 0c             	sub    $0xc,%esp
  801206:	68 05 08 00 00       	push   $0x805
  80120b:	56                   	push   %esi
  80120c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80120f:	56                   	push   %esi
  801210:	57                   	push   %edi
  801211:	e8 cb fb ff ff       	call   800de1 <sys_page_map>
  801216:	83 c4 20             	add    $0x20,%esp
  801219:	85 c0                	test   %eax,%eax
  80121b:	79 c2                	jns    8011df <fork+0x161>
  80121d:	e9 05 ff ff ff       	jmp    801127 <fork+0xa9>
  801222:	c1 e6 0c             	shl    $0xc,%esi
  801225:	83 ec 0c             	sub    $0xc,%esp
  801228:	6a 05                	push   $0x5
  80122a:	56                   	push   %esi
  80122b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80122e:	56                   	push   %esi
  80122f:	57                   	push   %edi
  801230:	e8 ac fb ff ff       	call   800de1 <sys_page_map>
  801235:	83 c4 20             	add    $0x20,%esp
  801238:	85 c0                	test   %eax,%eax
  80123a:	0f 89 0b ff ff ff    	jns    80114b <fork+0xcd>
  801240:	e9 e2 fe ff ff       	jmp    801127 <fork+0xa9>
    if (r < 0) panic("fork fault 3\n");

	if ((r = sys_env_set_status(eid, ENV_RUNNABLE)) < 0)
        panic("fork fault 4\n");
    return eid;
}
  801245:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801248:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80124b:	5b                   	pop    %ebx
  80124c:	5e                   	pop    %esi
  80124d:	5f                   	pop    %edi
  80124e:	5d                   	pop    %ebp
  80124f:	c3                   	ret    

00801250 <sfork>:

// Challenge!
int
sfork(void)
{
  801250:	55                   	push   %ebp
  801251:	89 e5                	mov    %esp,%ebp
  801253:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801256:	68 7e 28 80 00       	push   $0x80287e
  80125b:	68 8c 00 00 00       	push   $0x8c
  801260:	68 e7 27 80 00       	push   $0x8027e7
  801265:	e8 07 f0 ff ff       	call   800271 <_panic>

0080126a <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80126a:	55                   	push   %ebp
  80126b:	89 e5                	mov    %esp,%ebp
  80126d:	56                   	push   %esi
  80126e:	53                   	push   %ebx
  80126f:	8b 75 08             	mov    0x8(%ebp),%esi
  801272:	8b 45 0c             	mov    0xc(%ebp),%eax
  801275:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");
	int r;
    if (pg != NULL) {
  801278:	85 c0                	test   %eax,%eax
  80127a:	74 0e                	je     80128a <ipc_recv+0x20>
        r = sys_ipc_recv(pg);
  80127c:	83 ec 0c             	sub    $0xc,%esp
  80127f:	50                   	push   %eax
  801280:	e8 c9 fc ff ff       	call   800f4e <sys_ipc_recv>
  801285:	83 c4 10             	add    $0x10,%esp
  801288:	eb 10                	jmp    80129a <ipc_recv+0x30>
    } else {
        r = sys_ipc_recv((void *) UTOP);
  80128a:	83 ec 0c             	sub    $0xc,%esp
  80128d:	68 00 00 c0 ee       	push   $0xeec00000
  801292:	e8 b7 fc ff ff       	call   800f4e <sys_ipc_recv>
  801297:	83 c4 10             	add    $0x10,%esp
    }
    if (r < 0) {
  80129a:	85 c0                	test   %eax,%eax
  80129c:	79 16                	jns    8012b4 <ipc_recv+0x4a>
        // failed
        if (from_env_store != NULL) *from_env_store = 0;
  80129e:	85 f6                	test   %esi,%esi
  8012a0:	74 06                	je     8012a8 <ipc_recv+0x3e>
  8012a2:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        if (perm_store != NULL) *perm_store = 0;
  8012a8:	85 db                	test   %ebx,%ebx
  8012aa:	74 2c                	je     8012d8 <ipc_recv+0x6e>
  8012ac:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8012b2:	eb 24                	jmp    8012d8 <ipc_recv+0x6e>
        return r;
    } else {
        if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  8012b4:	85 f6                	test   %esi,%esi
  8012b6:	74 0a                	je     8012c2 <ipc_recv+0x58>
  8012b8:	a1 04 40 80 00       	mov    0x804004,%eax
  8012bd:	8b 40 74             	mov    0x74(%eax),%eax
  8012c0:	89 06                	mov    %eax,(%esi)
        if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  8012c2:	85 db                	test   %ebx,%ebx
  8012c4:	74 0a                	je     8012d0 <ipc_recv+0x66>
  8012c6:	a1 04 40 80 00       	mov    0x804004,%eax
  8012cb:	8b 40 78             	mov    0x78(%eax),%eax
  8012ce:	89 03                	mov    %eax,(%ebx)
        return thisenv->env_ipc_value;
  8012d0:	a1 04 40 80 00       	mov    0x804004,%eax
  8012d5:	8b 40 70             	mov    0x70(%eax),%eax
    }
 
	return 0;
}
  8012d8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012db:	5b                   	pop    %ebx
  8012dc:	5e                   	pop    %esi
  8012dd:	5d                   	pop    %ebp
  8012de:	c3                   	ret    

008012df <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8012df:	55                   	push   %ebp
  8012e0:	89 e5                	mov    %esp,%ebp
  8012e2:	57                   	push   %edi
  8012e3:	56                   	push   %esi
  8012e4:	53                   	push   %ebx
  8012e5:	83 ec 0c             	sub    $0xc,%esp
  8012e8:	8b 75 10             	mov    0x10(%ebp),%esi
  8012eb:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");
	int r;
    if (pg == NULL) pg = (void *)UTOP;
  8012ee:	85 f6                	test   %esi,%esi
  8012f0:	75 05                	jne    8012f7 <ipc_send+0x18>
  8012f2:	be 00 00 c0 ee       	mov    $0xeec00000,%esi
    do {
        r = sys_ipc_try_send(to_env, val, pg, perm);
  8012f7:	57                   	push   %edi
  8012f8:	56                   	push   %esi
  8012f9:	ff 75 0c             	pushl  0xc(%ebp)
  8012fc:	ff 75 08             	pushl  0x8(%ebp)
  8012ff:	e8 27 fc ff ff       	call   800f2b <sys_ipc_try_send>
  801304:	89 c3                	mov    %eax,%ebx
        if (r < 0 && r != -E_IPC_NOT_RECV) panic("ipc send failed: %e", r);
  801306:	83 c4 10             	add    $0x10,%esp
  801309:	85 c0                	test   %eax,%eax
  80130b:	79 17                	jns    801324 <ipc_send+0x45>
  80130d:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801310:	74 1d                	je     80132f <ipc_send+0x50>
  801312:	50                   	push   %eax
  801313:	68 b3 28 80 00       	push   $0x8028b3
  801318:	6a 40                	push   $0x40
  80131a:	68 c7 28 80 00       	push   $0x8028c7
  80131f:	e8 4d ef ff ff       	call   800271 <_panic>
        sys_yield();
  801324:	e8 56 fa ff ff       	call   800d7f <sys_yield>
    } while (r != 0);
  801329:	85 db                	test   %ebx,%ebx
  80132b:	75 ca                	jne    8012f7 <ipc_send+0x18>
  80132d:	eb 07                	jmp    801336 <ipc_send+0x57>
	int r;
    if (pg == NULL) pg = (void *)UTOP;
    do {
        r = sys_ipc_try_send(to_env, val, pg, perm);
        if (r < 0 && r != -E_IPC_NOT_RECV) panic("ipc send failed: %e", r);
        sys_yield();
  80132f:	e8 4b fa ff ff       	call   800d7f <sys_yield>
  801334:	eb c1                	jmp    8012f7 <ipc_send+0x18>
    } while (r != 0);
}
  801336:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801339:	5b                   	pop    %ebx
  80133a:	5e                   	pop    %esi
  80133b:	5f                   	pop    %edi
  80133c:	5d                   	pop    %ebp
  80133d:	c3                   	ret    

0080133e <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80133e:	55                   	push   %ebp
  80133f:	89 e5                	mov    %esp,%ebp
  801341:	53                   	push   %ebx
  801342:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801345:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  80134a:	39 c1                	cmp    %eax,%ecx
  80134c:	74 21                	je     80136f <ipc_find_env+0x31>
  80134e:	ba 01 00 00 00       	mov    $0x1,%edx
  801353:	8d 1c 95 00 00 00 00 	lea    0x0(,%edx,4),%ebx
  80135a:	89 d0                	mov    %edx,%eax
  80135c:	c1 e0 07             	shl    $0x7,%eax
  80135f:	29 d8                	sub    %ebx,%eax
  801361:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801366:	8b 40 50             	mov    0x50(%eax),%eax
  801369:	39 c8                	cmp    %ecx,%eax
  80136b:	75 1b                	jne    801388 <ipc_find_env+0x4a>
  80136d:	eb 05                	jmp    801374 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80136f:	ba 00 00 00 00       	mov    $0x0,%edx
		if (envs[i].env_type == type)
			return envs[i].env_id;
  801374:	8d 04 95 00 00 00 00 	lea    0x0(,%edx,4),%eax
  80137b:	c1 e2 07             	shl    $0x7,%edx
  80137e:	29 c2                	sub    %eax,%edx
  801380:	8b 82 48 00 c0 ee    	mov    -0x113fffb8(%edx),%eax
  801386:	eb 0e                	jmp    801396 <ipc_find_env+0x58>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801388:	42                   	inc    %edx
  801389:	81 fa 00 04 00 00    	cmp    $0x400,%edx
  80138f:	75 c2                	jne    801353 <ipc_find_env+0x15>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801391:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801396:	5b                   	pop    %ebx
  801397:	5d                   	pop    %ebp
  801398:	c3                   	ret    

00801399 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801399:	55                   	push   %ebp
  80139a:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80139c:	8b 45 08             	mov    0x8(%ebp),%eax
  80139f:	05 00 00 00 30       	add    $0x30000000,%eax
  8013a4:	c1 e8 0c             	shr    $0xc,%eax
}
  8013a7:	5d                   	pop    %ebp
  8013a8:	c3                   	ret    

008013a9 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8013a9:	55                   	push   %ebp
  8013aa:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8013ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8013af:	05 00 00 00 30       	add    $0x30000000,%eax
  8013b4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8013b9:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8013be:	5d                   	pop    %ebp
  8013bf:	c3                   	ret    

008013c0 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8013c0:	55                   	push   %ebp
  8013c1:	89 e5                	mov    %esp,%ebp
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8013c3:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  8013c8:	a8 01                	test   $0x1,%al
  8013ca:	74 34                	je     801400 <fd_alloc+0x40>
  8013cc:	a1 00 00 74 ef       	mov    0xef740000,%eax
  8013d1:	a8 01                	test   $0x1,%al
  8013d3:	74 32                	je     801407 <fd_alloc+0x47>
  8013d5:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8013da:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8013dc:	89 c2                	mov    %eax,%edx
  8013de:	c1 ea 16             	shr    $0x16,%edx
  8013e1:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8013e8:	f6 c2 01             	test   $0x1,%dl
  8013eb:	74 1f                	je     80140c <fd_alloc+0x4c>
  8013ed:	89 c2                	mov    %eax,%edx
  8013ef:	c1 ea 0c             	shr    $0xc,%edx
  8013f2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8013f9:	f6 c2 01             	test   $0x1,%dl
  8013fc:	75 1a                	jne    801418 <fd_alloc+0x58>
  8013fe:	eb 0c                	jmp    80140c <fd_alloc+0x4c>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  801400:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  801405:	eb 05                	jmp    80140c <fd_alloc+0x4c>
  801407:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  80140c:	8b 45 08             	mov    0x8(%ebp),%eax
  80140f:	89 08                	mov    %ecx,(%eax)
			return 0;
  801411:	b8 00 00 00 00       	mov    $0x0,%eax
  801416:	eb 1a                	jmp    801432 <fd_alloc+0x72>
  801418:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80141d:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801422:	75 b6                	jne    8013da <fd_alloc+0x1a>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801424:	8b 45 08             	mov    0x8(%ebp),%eax
  801427:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  80142d:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801432:	5d                   	pop    %ebp
  801433:	c3                   	ret    

00801434 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801434:	55                   	push   %ebp
  801435:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801437:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
  80143b:	77 39                	ja     801476 <fd_lookup+0x42>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80143d:	8b 45 08             	mov    0x8(%ebp),%eax
  801440:	c1 e0 0c             	shl    $0xc,%eax
  801443:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801448:	89 c2                	mov    %eax,%edx
  80144a:	c1 ea 16             	shr    $0x16,%edx
  80144d:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801454:	f6 c2 01             	test   $0x1,%dl
  801457:	74 24                	je     80147d <fd_lookup+0x49>
  801459:	89 c2                	mov    %eax,%edx
  80145b:	c1 ea 0c             	shr    $0xc,%edx
  80145e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801465:	f6 c2 01             	test   $0x1,%dl
  801468:	74 1a                	je     801484 <fd_lookup+0x50>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80146a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80146d:	89 02                	mov    %eax,(%edx)
	return 0;
  80146f:	b8 00 00 00 00       	mov    $0x0,%eax
  801474:	eb 13                	jmp    801489 <fd_lookup+0x55>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801476:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80147b:	eb 0c                	jmp    801489 <fd_lookup+0x55>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80147d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801482:	eb 05                	jmp    801489 <fd_lookup+0x55>
  801484:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801489:	5d                   	pop    %ebp
  80148a:	c3                   	ret    

0080148b <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80148b:	55                   	push   %ebp
  80148c:	89 e5                	mov    %esp,%ebp
  80148e:	53                   	push   %ebx
  80148f:	83 ec 04             	sub    $0x4,%esp
  801492:	8b 45 08             	mov    0x8(%ebp),%eax
  801495:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  801498:	3b 05 04 30 80 00    	cmp    0x803004,%eax
  80149e:	75 1e                	jne    8014be <dev_lookup+0x33>
  8014a0:	eb 0e                	jmp    8014b0 <dev_lookup+0x25>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8014a2:	b8 20 30 80 00       	mov    $0x803020,%eax
  8014a7:	eb 0c                	jmp    8014b5 <dev_lookup+0x2a>
  8014a9:	b8 3c 30 80 00       	mov    $0x80303c,%eax
  8014ae:	eb 05                	jmp    8014b5 <dev_lookup+0x2a>
  8014b0:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  8014b5:	89 03                	mov    %eax,(%ebx)
			return 0;
  8014b7:	b8 00 00 00 00       	mov    $0x0,%eax
  8014bc:	eb 36                	jmp    8014f4 <dev_lookup+0x69>
int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  8014be:	3b 05 20 30 80 00    	cmp    0x803020,%eax
  8014c4:	74 dc                	je     8014a2 <dev_lookup+0x17>
  8014c6:	3b 05 3c 30 80 00    	cmp    0x80303c,%eax
  8014cc:	74 db                	je     8014a9 <dev_lookup+0x1e>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8014ce:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8014d4:	8b 52 48             	mov    0x48(%edx),%edx
  8014d7:	83 ec 04             	sub    $0x4,%esp
  8014da:	50                   	push   %eax
  8014db:	52                   	push   %edx
  8014dc:	68 d4 28 80 00       	push   $0x8028d4
  8014e1:	e8 63 ee ff ff       	call   800349 <cprintf>
	*dev = 0;
  8014e6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  8014ec:	83 c4 10             	add    $0x10,%esp
  8014ef:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8014f4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014f7:	c9                   	leave  
  8014f8:	c3                   	ret    

008014f9 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8014f9:	55                   	push   %ebp
  8014fa:	89 e5                	mov    %esp,%ebp
  8014fc:	56                   	push   %esi
  8014fd:	53                   	push   %ebx
  8014fe:	83 ec 10             	sub    $0x10,%esp
  801501:	8b 75 08             	mov    0x8(%ebp),%esi
  801504:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801507:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80150a:	50                   	push   %eax
  80150b:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801511:	c1 e8 0c             	shr    $0xc,%eax
  801514:	50                   	push   %eax
  801515:	e8 1a ff ff ff       	call   801434 <fd_lookup>
  80151a:	83 c4 08             	add    $0x8,%esp
  80151d:	85 c0                	test   %eax,%eax
  80151f:	78 05                	js     801526 <fd_close+0x2d>
	    || fd != fd2)
  801521:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801524:	74 06                	je     80152c <fd_close+0x33>
		return (must_exist ? r : 0);
  801526:	84 db                	test   %bl,%bl
  801528:	74 47                	je     801571 <fd_close+0x78>
  80152a:	eb 4a                	jmp    801576 <fd_close+0x7d>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80152c:	83 ec 08             	sub    $0x8,%esp
  80152f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801532:	50                   	push   %eax
  801533:	ff 36                	pushl  (%esi)
  801535:	e8 51 ff ff ff       	call   80148b <dev_lookup>
  80153a:	89 c3                	mov    %eax,%ebx
  80153c:	83 c4 10             	add    $0x10,%esp
  80153f:	85 c0                	test   %eax,%eax
  801541:	78 1c                	js     80155f <fd_close+0x66>
		if (dev->dev_close)
  801543:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801546:	8b 40 10             	mov    0x10(%eax),%eax
  801549:	85 c0                	test   %eax,%eax
  80154b:	74 0d                	je     80155a <fd_close+0x61>
			r = (*dev->dev_close)(fd);
  80154d:	83 ec 0c             	sub    $0xc,%esp
  801550:	56                   	push   %esi
  801551:	ff d0                	call   *%eax
  801553:	89 c3                	mov    %eax,%ebx
  801555:	83 c4 10             	add    $0x10,%esp
  801558:	eb 05                	jmp    80155f <fd_close+0x66>
		else
			r = 0;
  80155a:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80155f:	83 ec 08             	sub    $0x8,%esp
  801562:	56                   	push   %esi
  801563:	6a 00                	push   $0x0
  801565:	e8 b9 f8 ff ff       	call   800e23 <sys_page_unmap>
	return r;
  80156a:	83 c4 10             	add    $0x10,%esp
  80156d:	89 d8                	mov    %ebx,%eax
  80156f:	eb 05                	jmp    801576 <fd_close+0x7d>
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
  801571:	b8 00 00 00 00       	mov    $0x0,%eax
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
	return r;
}
  801576:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801579:	5b                   	pop    %ebx
  80157a:	5e                   	pop    %esi
  80157b:	5d                   	pop    %ebp
  80157c:	c3                   	ret    

0080157d <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80157d:	55                   	push   %ebp
  80157e:	89 e5                	mov    %esp,%ebp
  801580:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801583:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801586:	50                   	push   %eax
  801587:	ff 75 08             	pushl  0x8(%ebp)
  80158a:	e8 a5 fe ff ff       	call   801434 <fd_lookup>
  80158f:	83 c4 08             	add    $0x8,%esp
  801592:	85 c0                	test   %eax,%eax
  801594:	78 10                	js     8015a6 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801596:	83 ec 08             	sub    $0x8,%esp
  801599:	6a 01                	push   $0x1
  80159b:	ff 75 f4             	pushl  -0xc(%ebp)
  80159e:	e8 56 ff ff ff       	call   8014f9 <fd_close>
  8015a3:	83 c4 10             	add    $0x10,%esp
}
  8015a6:	c9                   	leave  
  8015a7:	c3                   	ret    

008015a8 <close_all>:

void
close_all(void)
{
  8015a8:	55                   	push   %ebp
  8015a9:	89 e5                	mov    %esp,%ebp
  8015ab:	53                   	push   %ebx
  8015ac:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8015af:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8015b4:	83 ec 0c             	sub    $0xc,%esp
  8015b7:	53                   	push   %ebx
  8015b8:	e8 c0 ff ff ff       	call   80157d <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8015bd:	43                   	inc    %ebx
  8015be:	83 c4 10             	add    $0x10,%esp
  8015c1:	83 fb 20             	cmp    $0x20,%ebx
  8015c4:	75 ee                	jne    8015b4 <close_all+0xc>
		close(i);
}
  8015c6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015c9:	c9                   	leave  
  8015ca:	c3                   	ret    

008015cb <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8015cb:	55                   	push   %ebp
  8015cc:	89 e5                	mov    %esp,%ebp
  8015ce:	57                   	push   %edi
  8015cf:	56                   	push   %esi
  8015d0:	53                   	push   %ebx
  8015d1:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8015d4:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8015d7:	50                   	push   %eax
  8015d8:	ff 75 08             	pushl  0x8(%ebp)
  8015db:	e8 54 fe ff ff       	call   801434 <fd_lookup>
  8015e0:	83 c4 08             	add    $0x8,%esp
  8015e3:	85 c0                	test   %eax,%eax
  8015e5:	0f 88 c2 00 00 00    	js     8016ad <dup+0xe2>
		return r;
	close(newfdnum);
  8015eb:	83 ec 0c             	sub    $0xc,%esp
  8015ee:	ff 75 0c             	pushl  0xc(%ebp)
  8015f1:	e8 87 ff ff ff       	call   80157d <close>

	newfd = INDEX2FD(newfdnum);
  8015f6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8015f9:	c1 e3 0c             	shl    $0xc,%ebx
  8015fc:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801602:	83 c4 04             	add    $0x4,%esp
  801605:	ff 75 e4             	pushl  -0x1c(%ebp)
  801608:	e8 9c fd ff ff       	call   8013a9 <fd2data>
  80160d:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  80160f:	89 1c 24             	mov    %ebx,(%esp)
  801612:	e8 92 fd ff ff       	call   8013a9 <fd2data>
  801617:	83 c4 10             	add    $0x10,%esp
  80161a:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80161c:	89 f0                	mov    %esi,%eax
  80161e:	c1 e8 16             	shr    $0x16,%eax
  801621:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801628:	a8 01                	test   $0x1,%al
  80162a:	74 35                	je     801661 <dup+0x96>
  80162c:	89 f0                	mov    %esi,%eax
  80162e:	c1 e8 0c             	shr    $0xc,%eax
  801631:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801638:	f6 c2 01             	test   $0x1,%dl
  80163b:	74 24                	je     801661 <dup+0x96>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80163d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801644:	83 ec 0c             	sub    $0xc,%esp
  801647:	25 07 0e 00 00       	and    $0xe07,%eax
  80164c:	50                   	push   %eax
  80164d:	57                   	push   %edi
  80164e:	6a 00                	push   $0x0
  801650:	56                   	push   %esi
  801651:	6a 00                	push   $0x0
  801653:	e8 89 f7 ff ff       	call   800de1 <sys_page_map>
  801658:	89 c6                	mov    %eax,%esi
  80165a:	83 c4 20             	add    $0x20,%esp
  80165d:	85 c0                	test   %eax,%eax
  80165f:	78 2c                	js     80168d <dup+0xc2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801661:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801664:	89 d0                	mov    %edx,%eax
  801666:	c1 e8 0c             	shr    $0xc,%eax
  801669:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801670:	83 ec 0c             	sub    $0xc,%esp
  801673:	25 07 0e 00 00       	and    $0xe07,%eax
  801678:	50                   	push   %eax
  801679:	53                   	push   %ebx
  80167a:	6a 00                	push   $0x0
  80167c:	52                   	push   %edx
  80167d:	6a 00                	push   $0x0
  80167f:	e8 5d f7 ff ff       	call   800de1 <sys_page_map>
  801684:	89 c6                	mov    %eax,%esi
  801686:	83 c4 20             	add    $0x20,%esp
  801689:	85 c0                	test   %eax,%eax
  80168b:	79 1d                	jns    8016aa <dup+0xdf>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80168d:	83 ec 08             	sub    $0x8,%esp
  801690:	53                   	push   %ebx
  801691:	6a 00                	push   $0x0
  801693:	e8 8b f7 ff ff       	call   800e23 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801698:	83 c4 08             	add    $0x8,%esp
  80169b:	57                   	push   %edi
  80169c:	6a 00                	push   $0x0
  80169e:	e8 80 f7 ff ff       	call   800e23 <sys_page_unmap>
	return r;
  8016a3:	83 c4 10             	add    $0x10,%esp
  8016a6:	89 f0                	mov    %esi,%eax
  8016a8:	eb 03                	jmp    8016ad <dup+0xe2>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  8016aa:	8b 45 0c             	mov    0xc(%ebp),%eax

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8016ad:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016b0:	5b                   	pop    %ebx
  8016b1:	5e                   	pop    %esi
  8016b2:	5f                   	pop    %edi
  8016b3:	5d                   	pop    %ebp
  8016b4:	c3                   	ret    

008016b5 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8016b5:	55                   	push   %ebp
  8016b6:	89 e5                	mov    %esp,%ebp
  8016b8:	53                   	push   %ebx
  8016b9:	83 ec 14             	sub    $0x14,%esp
  8016bc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016bf:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016c2:	50                   	push   %eax
  8016c3:	53                   	push   %ebx
  8016c4:	e8 6b fd ff ff       	call   801434 <fd_lookup>
  8016c9:	83 c4 08             	add    $0x8,%esp
  8016cc:	85 c0                	test   %eax,%eax
  8016ce:	78 67                	js     801737 <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016d0:	83 ec 08             	sub    $0x8,%esp
  8016d3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016d6:	50                   	push   %eax
  8016d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016da:	ff 30                	pushl  (%eax)
  8016dc:	e8 aa fd ff ff       	call   80148b <dev_lookup>
  8016e1:	83 c4 10             	add    $0x10,%esp
  8016e4:	85 c0                	test   %eax,%eax
  8016e6:	78 4f                	js     801737 <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8016e8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8016eb:	8b 42 08             	mov    0x8(%edx),%eax
  8016ee:	83 e0 03             	and    $0x3,%eax
  8016f1:	83 f8 01             	cmp    $0x1,%eax
  8016f4:	75 21                	jne    801717 <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8016f6:	a1 04 40 80 00       	mov    0x804004,%eax
  8016fb:	8b 40 48             	mov    0x48(%eax),%eax
  8016fe:	83 ec 04             	sub    $0x4,%esp
  801701:	53                   	push   %ebx
  801702:	50                   	push   %eax
  801703:	68 18 29 80 00       	push   $0x802918
  801708:	e8 3c ec ff ff       	call   800349 <cprintf>
		return -E_INVAL;
  80170d:	83 c4 10             	add    $0x10,%esp
  801710:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801715:	eb 20                	jmp    801737 <read+0x82>
	}
	if (!dev->dev_read)
  801717:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80171a:	8b 40 08             	mov    0x8(%eax),%eax
  80171d:	85 c0                	test   %eax,%eax
  80171f:	74 11                	je     801732 <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801721:	83 ec 04             	sub    $0x4,%esp
  801724:	ff 75 10             	pushl  0x10(%ebp)
  801727:	ff 75 0c             	pushl  0xc(%ebp)
  80172a:	52                   	push   %edx
  80172b:	ff d0                	call   *%eax
  80172d:	83 c4 10             	add    $0x10,%esp
  801730:	eb 05                	jmp    801737 <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801732:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801737:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80173a:	c9                   	leave  
  80173b:	c3                   	ret    

0080173c <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80173c:	55                   	push   %ebp
  80173d:	89 e5                	mov    %esp,%ebp
  80173f:	57                   	push   %edi
  801740:	56                   	push   %esi
  801741:	53                   	push   %ebx
  801742:	83 ec 0c             	sub    $0xc,%esp
  801745:	8b 7d 08             	mov    0x8(%ebp),%edi
  801748:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80174b:	85 f6                	test   %esi,%esi
  80174d:	74 31                	je     801780 <readn+0x44>
  80174f:	b8 00 00 00 00       	mov    $0x0,%eax
  801754:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  801759:	83 ec 04             	sub    $0x4,%esp
  80175c:	89 f2                	mov    %esi,%edx
  80175e:	29 c2                	sub    %eax,%edx
  801760:	52                   	push   %edx
  801761:	03 45 0c             	add    0xc(%ebp),%eax
  801764:	50                   	push   %eax
  801765:	57                   	push   %edi
  801766:	e8 4a ff ff ff       	call   8016b5 <read>
		if (m < 0)
  80176b:	83 c4 10             	add    $0x10,%esp
  80176e:	85 c0                	test   %eax,%eax
  801770:	78 17                	js     801789 <readn+0x4d>
			return m;
		if (m == 0)
  801772:	85 c0                	test   %eax,%eax
  801774:	74 11                	je     801787 <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801776:	01 c3                	add    %eax,%ebx
  801778:	89 d8                	mov    %ebx,%eax
  80177a:	39 f3                	cmp    %esi,%ebx
  80177c:	72 db                	jb     801759 <readn+0x1d>
  80177e:	eb 09                	jmp    801789 <readn+0x4d>
  801780:	b8 00 00 00 00       	mov    $0x0,%eax
  801785:	eb 02                	jmp    801789 <readn+0x4d>
  801787:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801789:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80178c:	5b                   	pop    %ebx
  80178d:	5e                   	pop    %esi
  80178e:	5f                   	pop    %edi
  80178f:	5d                   	pop    %ebp
  801790:	c3                   	ret    

00801791 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801791:	55                   	push   %ebp
  801792:	89 e5                	mov    %esp,%ebp
  801794:	53                   	push   %ebx
  801795:	83 ec 14             	sub    $0x14,%esp
  801798:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80179b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80179e:	50                   	push   %eax
  80179f:	53                   	push   %ebx
  8017a0:	e8 8f fc ff ff       	call   801434 <fd_lookup>
  8017a5:	83 c4 08             	add    $0x8,%esp
  8017a8:	85 c0                	test   %eax,%eax
  8017aa:	78 62                	js     80180e <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017ac:	83 ec 08             	sub    $0x8,%esp
  8017af:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017b2:	50                   	push   %eax
  8017b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017b6:	ff 30                	pushl  (%eax)
  8017b8:	e8 ce fc ff ff       	call   80148b <dev_lookup>
  8017bd:	83 c4 10             	add    $0x10,%esp
  8017c0:	85 c0                	test   %eax,%eax
  8017c2:	78 4a                	js     80180e <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8017c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017c7:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8017cb:	75 21                	jne    8017ee <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8017cd:	a1 04 40 80 00       	mov    0x804004,%eax
  8017d2:	8b 40 48             	mov    0x48(%eax),%eax
  8017d5:	83 ec 04             	sub    $0x4,%esp
  8017d8:	53                   	push   %ebx
  8017d9:	50                   	push   %eax
  8017da:	68 34 29 80 00       	push   $0x802934
  8017df:	e8 65 eb ff ff       	call   800349 <cprintf>
		return -E_INVAL;
  8017e4:	83 c4 10             	add    $0x10,%esp
  8017e7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8017ec:	eb 20                	jmp    80180e <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8017ee:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017f1:	8b 52 0c             	mov    0xc(%edx),%edx
  8017f4:	85 d2                	test   %edx,%edx
  8017f6:	74 11                	je     801809 <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8017f8:	83 ec 04             	sub    $0x4,%esp
  8017fb:	ff 75 10             	pushl  0x10(%ebp)
  8017fe:	ff 75 0c             	pushl  0xc(%ebp)
  801801:	50                   	push   %eax
  801802:	ff d2                	call   *%edx
  801804:	83 c4 10             	add    $0x10,%esp
  801807:	eb 05                	jmp    80180e <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801809:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  80180e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801811:	c9                   	leave  
  801812:	c3                   	ret    

00801813 <seek>:

int
seek(int fdnum, off_t offset)
{
  801813:	55                   	push   %ebp
  801814:	89 e5                	mov    %esp,%ebp
  801816:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801819:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80181c:	50                   	push   %eax
  80181d:	ff 75 08             	pushl  0x8(%ebp)
  801820:	e8 0f fc ff ff       	call   801434 <fd_lookup>
  801825:	83 c4 08             	add    $0x8,%esp
  801828:	85 c0                	test   %eax,%eax
  80182a:	78 0e                	js     80183a <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80182c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80182f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801832:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801835:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80183a:	c9                   	leave  
  80183b:	c3                   	ret    

0080183c <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80183c:	55                   	push   %ebp
  80183d:	89 e5                	mov    %esp,%ebp
  80183f:	53                   	push   %ebx
  801840:	83 ec 14             	sub    $0x14,%esp
  801843:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801846:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801849:	50                   	push   %eax
  80184a:	53                   	push   %ebx
  80184b:	e8 e4 fb ff ff       	call   801434 <fd_lookup>
  801850:	83 c4 08             	add    $0x8,%esp
  801853:	85 c0                	test   %eax,%eax
  801855:	78 5f                	js     8018b6 <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801857:	83 ec 08             	sub    $0x8,%esp
  80185a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80185d:	50                   	push   %eax
  80185e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801861:	ff 30                	pushl  (%eax)
  801863:	e8 23 fc ff ff       	call   80148b <dev_lookup>
  801868:	83 c4 10             	add    $0x10,%esp
  80186b:	85 c0                	test   %eax,%eax
  80186d:	78 47                	js     8018b6 <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80186f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801872:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801876:	75 21                	jne    801899 <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801878:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80187d:	8b 40 48             	mov    0x48(%eax),%eax
  801880:	83 ec 04             	sub    $0x4,%esp
  801883:	53                   	push   %ebx
  801884:	50                   	push   %eax
  801885:	68 f4 28 80 00       	push   $0x8028f4
  80188a:	e8 ba ea ff ff       	call   800349 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80188f:	83 c4 10             	add    $0x10,%esp
  801892:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801897:	eb 1d                	jmp    8018b6 <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  801899:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80189c:	8b 52 18             	mov    0x18(%edx),%edx
  80189f:	85 d2                	test   %edx,%edx
  8018a1:	74 0e                	je     8018b1 <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8018a3:	83 ec 08             	sub    $0x8,%esp
  8018a6:	ff 75 0c             	pushl  0xc(%ebp)
  8018a9:	50                   	push   %eax
  8018aa:	ff d2                	call   *%edx
  8018ac:	83 c4 10             	add    $0x10,%esp
  8018af:	eb 05                	jmp    8018b6 <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8018b1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8018b6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018b9:	c9                   	leave  
  8018ba:	c3                   	ret    

008018bb <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8018bb:	55                   	push   %ebp
  8018bc:	89 e5                	mov    %esp,%ebp
  8018be:	53                   	push   %ebx
  8018bf:	83 ec 14             	sub    $0x14,%esp
  8018c2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018c5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018c8:	50                   	push   %eax
  8018c9:	ff 75 08             	pushl  0x8(%ebp)
  8018cc:	e8 63 fb ff ff       	call   801434 <fd_lookup>
  8018d1:	83 c4 08             	add    $0x8,%esp
  8018d4:	85 c0                	test   %eax,%eax
  8018d6:	78 52                	js     80192a <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018d8:	83 ec 08             	sub    $0x8,%esp
  8018db:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018de:	50                   	push   %eax
  8018df:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018e2:	ff 30                	pushl  (%eax)
  8018e4:	e8 a2 fb ff ff       	call   80148b <dev_lookup>
  8018e9:	83 c4 10             	add    $0x10,%esp
  8018ec:	85 c0                	test   %eax,%eax
  8018ee:	78 3a                	js     80192a <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  8018f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018f3:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8018f7:	74 2c                	je     801925 <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8018f9:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8018fc:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801903:	00 00 00 
	stat->st_isdir = 0;
  801906:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80190d:	00 00 00 
	stat->st_dev = dev;
  801910:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801916:	83 ec 08             	sub    $0x8,%esp
  801919:	53                   	push   %ebx
  80191a:	ff 75 f0             	pushl  -0x10(%ebp)
  80191d:	ff 50 14             	call   *0x14(%eax)
  801920:	83 c4 10             	add    $0x10,%esp
  801923:	eb 05                	jmp    80192a <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801925:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80192a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80192d:	c9                   	leave  
  80192e:	c3                   	ret    

0080192f <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80192f:	55                   	push   %ebp
  801930:	89 e5                	mov    %esp,%ebp
  801932:	56                   	push   %esi
  801933:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801934:	83 ec 08             	sub    $0x8,%esp
  801937:	6a 00                	push   $0x0
  801939:	ff 75 08             	pushl  0x8(%ebp)
  80193c:	e8 75 01 00 00       	call   801ab6 <open>
  801941:	89 c3                	mov    %eax,%ebx
  801943:	83 c4 10             	add    $0x10,%esp
  801946:	85 c0                	test   %eax,%eax
  801948:	78 1d                	js     801967 <stat+0x38>
		return fd;
	r = fstat(fd, stat);
  80194a:	83 ec 08             	sub    $0x8,%esp
  80194d:	ff 75 0c             	pushl  0xc(%ebp)
  801950:	50                   	push   %eax
  801951:	e8 65 ff ff ff       	call   8018bb <fstat>
  801956:	89 c6                	mov    %eax,%esi
	close(fd);
  801958:	89 1c 24             	mov    %ebx,(%esp)
  80195b:	e8 1d fc ff ff       	call   80157d <close>
	return r;
  801960:	83 c4 10             	add    $0x10,%esp
  801963:	89 f0                	mov    %esi,%eax
  801965:	eb 00                	jmp    801967 <stat+0x38>
}
  801967:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80196a:	5b                   	pop    %ebx
  80196b:	5e                   	pop    %esi
  80196c:	5d                   	pop    %ebp
  80196d:	c3                   	ret    

0080196e <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80196e:	55                   	push   %ebp
  80196f:	89 e5                	mov    %esp,%ebp
  801971:	56                   	push   %esi
  801972:	53                   	push   %ebx
  801973:	89 c6                	mov    %eax,%esi
  801975:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801977:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80197e:	75 12                	jne    801992 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801980:	83 ec 0c             	sub    $0xc,%esp
  801983:	6a 01                	push   $0x1
  801985:	e8 b4 f9 ff ff       	call   80133e <ipc_find_env>
  80198a:	a3 00 40 80 00       	mov    %eax,0x804000
  80198f:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801992:	6a 07                	push   $0x7
  801994:	68 00 50 80 00       	push   $0x805000
  801999:	56                   	push   %esi
  80199a:	ff 35 00 40 80 00    	pushl  0x804000
  8019a0:	e8 3a f9 ff ff       	call   8012df <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8019a5:	83 c4 0c             	add    $0xc,%esp
  8019a8:	6a 00                	push   $0x0
  8019aa:	53                   	push   %ebx
  8019ab:	6a 00                	push   $0x0
  8019ad:	e8 b8 f8 ff ff       	call   80126a <ipc_recv>
}
  8019b2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019b5:	5b                   	pop    %ebx
  8019b6:	5e                   	pop    %esi
  8019b7:	5d                   	pop    %ebp
  8019b8:	c3                   	ret    

008019b9 <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8019b9:	55                   	push   %ebp
  8019ba:	89 e5                	mov    %esp,%ebp
  8019bc:	53                   	push   %ebx
  8019bd:	83 ec 04             	sub    $0x4,%esp
  8019c0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8019c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8019c6:	8b 40 0c             	mov    0xc(%eax),%eax
  8019c9:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8019ce:	ba 00 00 00 00       	mov    $0x0,%edx
  8019d3:	b8 05 00 00 00       	mov    $0x5,%eax
  8019d8:	e8 91 ff ff ff       	call   80196e <fsipc>
  8019dd:	85 c0                	test   %eax,%eax
  8019df:	78 2c                	js     801a0d <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8019e1:	83 ec 08             	sub    $0x8,%esp
  8019e4:	68 00 50 80 00       	push   $0x805000
  8019e9:	53                   	push   %ebx
  8019ea:	e8 3f ef ff ff       	call   80092e <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8019ef:	a1 80 50 80 00       	mov    0x805080,%eax
  8019f4:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8019fa:	a1 84 50 80 00       	mov    0x805084,%eax
  8019ff:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801a05:	83 c4 10             	add    $0x10,%esp
  801a08:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a0d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a10:	c9                   	leave  
  801a11:	c3                   	ret    

00801a12 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801a12:	55                   	push   %ebp
  801a13:	89 e5                	mov    %esp,%ebp
  801a15:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801a18:	8b 45 08             	mov    0x8(%ebp),%eax
  801a1b:	8b 40 0c             	mov    0xc(%eax),%eax
  801a1e:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801a23:	ba 00 00 00 00       	mov    $0x0,%edx
  801a28:	b8 06 00 00 00       	mov    $0x6,%eax
  801a2d:	e8 3c ff ff ff       	call   80196e <fsipc>
}
  801a32:	c9                   	leave  
  801a33:	c3                   	ret    

00801a34 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801a34:	55                   	push   %ebp
  801a35:	89 e5                	mov    %esp,%ebp
  801a37:	56                   	push   %esi
  801a38:	53                   	push   %ebx
  801a39:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801a3c:	8b 45 08             	mov    0x8(%ebp),%eax
  801a3f:	8b 40 0c             	mov    0xc(%eax),%eax
  801a42:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801a47:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801a4d:	ba 00 00 00 00       	mov    $0x0,%edx
  801a52:	b8 03 00 00 00       	mov    $0x3,%eax
  801a57:	e8 12 ff ff ff       	call   80196e <fsipc>
  801a5c:	89 c3                	mov    %eax,%ebx
  801a5e:	85 c0                	test   %eax,%eax
  801a60:	78 4b                	js     801aad <devfile_read+0x79>
		return r;
	assert(r <= n);
  801a62:	39 c6                	cmp    %eax,%esi
  801a64:	73 16                	jae    801a7c <devfile_read+0x48>
  801a66:	68 51 29 80 00       	push   $0x802951
  801a6b:	68 58 29 80 00       	push   $0x802958
  801a70:	6a 7a                	push   $0x7a
  801a72:	68 6d 29 80 00       	push   $0x80296d
  801a77:	e8 f5 e7 ff ff       	call   800271 <_panic>
	assert(r <= PGSIZE);
  801a7c:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801a81:	7e 16                	jle    801a99 <devfile_read+0x65>
  801a83:	68 78 29 80 00       	push   $0x802978
  801a88:	68 58 29 80 00       	push   $0x802958
  801a8d:	6a 7b                	push   $0x7b
  801a8f:	68 6d 29 80 00       	push   $0x80296d
  801a94:	e8 d8 e7 ff ff       	call   800271 <_panic>
	memmove(buf, &fsipcbuf, r);
  801a99:	83 ec 04             	sub    $0x4,%esp
  801a9c:	50                   	push   %eax
  801a9d:	68 00 50 80 00       	push   $0x805000
  801aa2:	ff 75 0c             	pushl  0xc(%ebp)
  801aa5:	e8 51 f0 ff ff       	call   800afb <memmove>
	return r;
  801aaa:	83 c4 10             	add    $0x10,%esp
}
  801aad:	89 d8                	mov    %ebx,%eax
  801aaf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ab2:	5b                   	pop    %ebx
  801ab3:	5e                   	pop    %esi
  801ab4:	5d                   	pop    %ebp
  801ab5:	c3                   	ret    

00801ab6 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801ab6:	55                   	push   %ebp
  801ab7:	89 e5                	mov    %esp,%ebp
  801ab9:	53                   	push   %ebx
  801aba:	83 ec 20             	sub    $0x20,%esp
  801abd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801ac0:	53                   	push   %ebx
  801ac1:	e8 11 ee ff ff       	call   8008d7 <strlen>
  801ac6:	83 c4 10             	add    $0x10,%esp
  801ac9:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801ace:	7f 63                	jg     801b33 <open+0x7d>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801ad0:	83 ec 0c             	sub    $0xc,%esp
  801ad3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ad6:	50                   	push   %eax
  801ad7:	e8 e4 f8 ff ff       	call   8013c0 <fd_alloc>
  801adc:	83 c4 10             	add    $0x10,%esp
  801adf:	85 c0                	test   %eax,%eax
  801ae1:	78 55                	js     801b38 <open+0x82>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801ae3:	83 ec 08             	sub    $0x8,%esp
  801ae6:	53                   	push   %ebx
  801ae7:	68 00 50 80 00       	push   $0x805000
  801aec:	e8 3d ee ff ff       	call   80092e <strcpy>
	fsipcbuf.open.req_omode = mode;
  801af1:	8b 45 0c             	mov    0xc(%ebp),%eax
  801af4:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801af9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801afc:	b8 01 00 00 00       	mov    $0x1,%eax
  801b01:	e8 68 fe ff ff       	call   80196e <fsipc>
  801b06:	89 c3                	mov    %eax,%ebx
  801b08:	83 c4 10             	add    $0x10,%esp
  801b0b:	85 c0                	test   %eax,%eax
  801b0d:	79 14                	jns    801b23 <open+0x6d>
		fd_close(fd, 0);
  801b0f:	83 ec 08             	sub    $0x8,%esp
  801b12:	6a 00                	push   $0x0
  801b14:	ff 75 f4             	pushl  -0xc(%ebp)
  801b17:	e8 dd f9 ff ff       	call   8014f9 <fd_close>
		return r;
  801b1c:	83 c4 10             	add    $0x10,%esp
  801b1f:	89 d8                	mov    %ebx,%eax
  801b21:	eb 15                	jmp    801b38 <open+0x82>
	}

	return fd2num(fd);
  801b23:	83 ec 0c             	sub    $0xc,%esp
  801b26:	ff 75 f4             	pushl  -0xc(%ebp)
  801b29:	e8 6b f8 ff ff       	call   801399 <fd2num>
  801b2e:	83 c4 10             	add    $0x10,%esp
  801b31:	eb 05                	jmp    801b38 <open+0x82>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801b33:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801b38:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b3b:	c9                   	leave  
  801b3c:	c3                   	ret    

00801b3d <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b3d:	55                   	push   %ebp
  801b3e:	89 e5                	mov    %esp,%ebp
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b40:	8b 45 08             	mov    0x8(%ebp),%eax
  801b43:	c1 e8 16             	shr    $0x16,%eax
  801b46:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801b4d:	a8 01                	test   $0x1,%al
  801b4f:	74 21                	je     801b72 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b51:	8b 45 08             	mov    0x8(%ebp),%eax
  801b54:	c1 e8 0c             	shr    $0xc,%eax
  801b57:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801b5e:	a8 01                	test   $0x1,%al
  801b60:	74 17                	je     801b79 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b62:	c1 e8 0c             	shr    $0xc,%eax
  801b65:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801b6c:	ef 
  801b6d:	0f b7 c0             	movzwl %ax,%eax
  801b70:	eb 0c                	jmp    801b7e <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801b72:	b8 00 00 00 00       	mov    $0x0,%eax
  801b77:	eb 05                	jmp    801b7e <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801b79:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801b7e:	5d                   	pop    %ebp
  801b7f:	c3                   	ret    

00801b80 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801b80:	55                   	push   %ebp
  801b81:	89 e5                	mov    %esp,%ebp
  801b83:	56                   	push   %esi
  801b84:	53                   	push   %ebx
  801b85:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801b88:	83 ec 0c             	sub    $0xc,%esp
  801b8b:	ff 75 08             	pushl  0x8(%ebp)
  801b8e:	e8 16 f8 ff ff       	call   8013a9 <fd2data>
  801b93:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801b95:	83 c4 08             	add    $0x8,%esp
  801b98:	68 84 29 80 00       	push   $0x802984
  801b9d:	53                   	push   %ebx
  801b9e:	e8 8b ed ff ff       	call   80092e <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801ba3:	8b 46 04             	mov    0x4(%esi),%eax
  801ba6:	2b 06                	sub    (%esi),%eax
  801ba8:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801bae:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801bb5:	00 00 00 
	stat->st_dev = &devpipe;
  801bb8:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801bbf:	30 80 00 
	return 0;
}
  801bc2:	b8 00 00 00 00       	mov    $0x0,%eax
  801bc7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bca:	5b                   	pop    %ebx
  801bcb:	5e                   	pop    %esi
  801bcc:	5d                   	pop    %ebp
  801bcd:	c3                   	ret    

00801bce <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801bce:	55                   	push   %ebp
  801bcf:	89 e5                	mov    %esp,%ebp
  801bd1:	53                   	push   %ebx
  801bd2:	83 ec 0c             	sub    $0xc,%esp
  801bd5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801bd8:	53                   	push   %ebx
  801bd9:	6a 00                	push   $0x0
  801bdb:	e8 43 f2 ff ff       	call   800e23 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801be0:	89 1c 24             	mov    %ebx,(%esp)
  801be3:	e8 c1 f7 ff ff       	call   8013a9 <fd2data>
  801be8:	83 c4 08             	add    $0x8,%esp
  801beb:	50                   	push   %eax
  801bec:	6a 00                	push   $0x0
  801bee:	e8 30 f2 ff ff       	call   800e23 <sys_page_unmap>
}
  801bf3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bf6:	c9                   	leave  
  801bf7:	c3                   	ret    

00801bf8 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801bf8:	55                   	push   %ebp
  801bf9:	89 e5                	mov    %esp,%ebp
  801bfb:	57                   	push   %edi
  801bfc:	56                   	push   %esi
  801bfd:	53                   	push   %ebx
  801bfe:	83 ec 1c             	sub    $0x1c,%esp
  801c01:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801c04:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801c06:	a1 04 40 80 00       	mov    0x804004,%eax
  801c0b:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801c0e:	83 ec 0c             	sub    $0xc,%esp
  801c11:	ff 75 e0             	pushl  -0x20(%ebp)
  801c14:	e8 24 ff ff ff       	call   801b3d <pageref>
  801c19:	89 c3                	mov    %eax,%ebx
  801c1b:	89 3c 24             	mov    %edi,(%esp)
  801c1e:	e8 1a ff ff ff       	call   801b3d <pageref>
  801c23:	83 c4 10             	add    $0x10,%esp
  801c26:	39 c3                	cmp    %eax,%ebx
  801c28:	0f 94 c1             	sete   %cl
  801c2b:	0f b6 c9             	movzbl %cl,%ecx
  801c2e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801c31:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801c37:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801c3a:	39 ce                	cmp    %ecx,%esi
  801c3c:	74 1b                	je     801c59 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801c3e:	39 c3                	cmp    %eax,%ebx
  801c40:	75 c4                	jne    801c06 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801c42:	8b 42 58             	mov    0x58(%edx),%eax
  801c45:	ff 75 e4             	pushl  -0x1c(%ebp)
  801c48:	50                   	push   %eax
  801c49:	56                   	push   %esi
  801c4a:	68 8b 29 80 00       	push   $0x80298b
  801c4f:	e8 f5 e6 ff ff       	call   800349 <cprintf>
  801c54:	83 c4 10             	add    $0x10,%esp
  801c57:	eb ad                	jmp    801c06 <_pipeisclosed+0xe>
	}
}
  801c59:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c5c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c5f:	5b                   	pop    %ebx
  801c60:	5e                   	pop    %esi
  801c61:	5f                   	pop    %edi
  801c62:	5d                   	pop    %ebp
  801c63:	c3                   	ret    

00801c64 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801c64:	55                   	push   %ebp
  801c65:	89 e5                	mov    %esp,%ebp
  801c67:	57                   	push   %edi
  801c68:	56                   	push   %esi
  801c69:	53                   	push   %ebx
  801c6a:	83 ec 18             	sub    $0x18,%esp
  801c6d:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801c70:	56                   	push   %esi
  801c71:	e8 33 f7 ff ff       	call   8013a9 <fd2data>
  801c76:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c78:	83 c4 10             	add    $0x10,%esp
  801c7b:	bf 00 00 00 00       	mov    $0x0,%edi
  801c80:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801c84:	75 42                	jne    801cc8 <devpipe_write+0x64>
  801c86:	eb 4e                	jmp    801cd6 <devpipe_write+0x72>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801c88:	89 da                	mov    %ebx,%edx
  801c8a:	89 f0                	mov    %esi,%eax
  801c8c:	e8 67 ff ff ff       	call   801bf8 <_pipeisclosed>
  801c91:	85 c0                	test   %eax,%eax
  801c93:	75 46                	jne    801cdb <devpipe_write+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801c95:	e8 e5 f0 ff ff       	call   800d7f <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801c9a:	8b 53 04             	mov    0x4(%ebx),%edx
  801c9d:	8b 03                	mov    (%ebx),%eax
  801c9f:	83 c0 20             	add    $0x20,%eax
  801ca2:	39 c2                	cmp    %eax,%edx
  801ca4:	73 e2                	jae    801c88 <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801ca6:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ca9:	8a 0c 38             	mov    (%eax,%edi,1),%cl
  801cac:	89 d0                	mov    %edx,%eax
  801cae:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801cb3:	79 05                	jns    801cba <devpipe_write+0x56>
  801cb5:	48                   	dec    %eax
  801cb6:	83 c8 e0             	or     $0xffffffe0,%eax
  801cb9:	40                   	inc    %eax
  801cba:	88 4c 03 08          	mov    %cl,0x8(%ebx,%eax,1)
		p->p_wpos++;
  801cbe:	42                   	inc    %edx
  801cbf:	89 53 04             	mov    %edx,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801cc2:	47                   	inc    %edi
  801cc3:	39 7d 10             	cmp    %edi,0x10(%ebp)
  801cc6:	74 0e                	je     801cd6 <devpipe_write+0x72>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801cc8:	8b 53 04             	mov    0x4(%ebx),%edx
  801ccb:	8b 03                	mov    (%ebx),%eax
  801ccd:	83 c0 20             	add    $0x20,%eax
  801cd0:	39 c2                	cmp    %eax,%edx
  801cd2:	73 b4                	jae    801c88 <devpipe_write+0x24>
  801cd4:	eb d0                	jmp    801ca6 <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801cd6:	8b 45 10             	mov    0x10(%ebp),%eax
  801cd9:	eb 05                	jmp    801ce0 <devpipe_write+0x7c>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801cdb:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801ce0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ce3:	5b                   	pop    %ebx
  801ce4:	5e                   	pop    %esi
  801ce5:	5f                   	pop    %edi
  801ce6:	5d                   	pop    %ebp
  801ce7:	c3                   	ret    

00801ce8 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ce8:	55                   	push   %ebp
  801ce9:	89 e5                	mov    %esp,%ebp
  801ceb:	57                   	push   %edi
  801cec:	56                   	push   %esi
  801ced:	53                   	push   %ebx
  801cee:	83 ec 18             	sub    $0x18,%esp
  801cf1:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801cf4:	57                   	push   %edi
  801cf5:	e8 af f6 ff ff       	call   8013a9 <fd2data>
  801cfa:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801cfc:	83 c4 10             	add    $0x10,%esp
  801cff:	be 00 00 00 00       	mov    $0x0,%esi
  801d04:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d08:	75 3d                	jne    801d47 <devpipe_read+0x5f>
  801d0a:	eb 48                	jmp    801d54 <devpipe_read+0x6c>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  801d0c:	89 f0                	mov    %esi,%eax
  801d0e:	eb 4e                	jmp    801d5e <devpipe_read+0x76>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801d10:	89 da                	mov    %ebx,%edx
  801d12:	89 f8                	mov    %edi,%eax
  801d14:	e8 df fe ff ff       	call   801bf8 <_pipeisclosed>
  801d19:	85 c0                	test   %eax,%eax
  801d1b:	75 3c                	jne    801d59 <devpipe_read+0x71>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801d1d:	e8 5d f0 ff ff       	call   800d7f <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801d22:	8b 03                	mov    (%ebx),%eax
  801d24:	3b 43 04             	cmp    0x4(%ebx),%eax
  801d27:	74 e7                	je     801d10 <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801d29:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801d2e:	79 05                	jns    801d35 <devpipe_read+0x4d>
  801d30:	48                   	dec    %eax
  801d31:	83 c8 e0             	or     $0xffffffe0,%eax
  801d34:	40                   	inc    %eax
  801d35:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801d39:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d3c:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801d3f:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d41:	46                   	inc    %esi
  801d42:	39 75 10             	cmp    %esi,0x10(%ebp)
  801d45:	74 0d                	je     801d54 <devpipe_read+0x6c>
		while (p->p_rpos == p->p_wpos) {
  801d47:	8b 03                	mov    (%ebx),%eax
  801d49:	3b 43 04             	cmp    0x4(%ebx),%eax
  801d4c:	75 db                	jne    801d29 <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801d4e:	85 f6                	test   %esi,%esi
  801d50:	75 ba                	jne    801d0c <devpipe_read+0x24>
  801d52:	eb bc                	jmp    801d10 <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801d54:	8b 45 10             	mov    0x10(%ebp),%eax
  801d57:	eb 05                	jmp    801d5e <devpipe_read+0x76>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801d59:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801d5e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d61:	5b                   	pop    %ebx
  801d62:	5e                   	pop    %esi
  801d63:	5f                   	pop    %edi
  801d64:	5d                   	pop    %ebp
  801d65:	c3                   	ret    

00801d66 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801d66:	55                   	push   %ebp
  801d67:	89 e5                	mov    %esp,%ebp
  801d69:	56                   	push   %esi
  801d6a:	53                   	push   %ebx
  801d6b:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801d6e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d71:	50                   	push   %eax
  801d72:	e8 49 f6 ff ff       	call   8013c0 <fd_alloc>
  801d77:	83 c4 10             	add    $0x10,%esp
  801d7a:	85 c0                	test   %eax,%eax
  801d7c:	0f 88 2a 01 00 00    	js     801eac <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d82:	83 ec 04             	sub    $0x4,%esp
  801d85:	68 07 04 00 00       	push   $0x407
  801d8a:	ff 75 f4             	pushl  -0xc(%ebp)
  801d8d:	6a 00                	push   $0x0
  801d8f:	e8 0a f0 ff ff       	call   800d9e <sys_page_alloc>
  801d94:	83 c4 10             	add    $0x10,%esp
  801d97:	85 c0                	test   %eax,%eax
  801d99:	0f 88 0d 01 00 00    	js     801eac <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801d9f:	83 ec 0c             	sub    $0xc,%esp
  801da2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801da5:	50                   	push   %eax
  801da6:	e8 15 f6 ff ff       	call   8013c0 <fd_alloc>
  801dab:	89 c3                	mov    %eax,%ebx
  801dad:	83 c4 10             	add    $0x10,%esp
  801db0:	85 c0                	test   %eax,%eax
  801db2:	0f 88 e2 00 00 00    	js     801e9a <pipe+0x134>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801db8:	83 ec 04             	sub    $0x4,%esp
  801dbb:	68 07 04 00 00       	push   $0x407
  801dc0:	ff 75 f0             	pushl  -0x10(%ebp)
  801dc3:	6a 00                	push   $0x0
  801dc5:	e8 d4 ef ff ff       	call   800d9e <sys_page_alloc>
  801dca:	89 c3                	mov    %eax,%ebx
  801dcc:	83 c4 10             	add    $0x10,%esp
  801dcf:	85 c0                	test   %eax,%eax
  801dd1:	0f 88 c3 00 00 00    	js     801e9a <pipe+0x134>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801dd7:	83 ec 0c             	sub    $0xc,%esp
  801dda:	ff 75 f4             	pushl  -0xc(%ebp)
  801ddd:	e8 c7 f5 ff ff       	call   8013a9 <fd2data>
  801de2:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801de4:	83 c4 0c             	add    $0xc,%esp
  801de7:	68 07 04 00 00       	push   $0x407
  801dec:	50                   	push   %eax
  801ded:	6a 00                	push   $0x0
  801def:	e8 aa ef ff ff       	call   800d9e <sys_page_alloc>
  801df4:	89 c3                	mov    %eax,%ebx
  801df6:	83 c4 10             	add    $0x10,%esp
  801df9:	85 c0                	test   %eax,%eax
  801dfb:	0f 88 89 00 00 00    	js     801e8a <pipe+0x124>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e01:	83 ec 0c             	sub    $0xc,%esp
  801e04:	ff 75 f0             	pushl  -0x10(%ebp)
  801e07:	e8 9d f5 ff ff       	call   8013a9 <fd2data>
  801e0c:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801e13:	50                   	push   %eax
  801e14:	6a 00                	push   $0x0
  801e16:	56                   	push   %esi
  801e17:	6a 00                	push   $0x0
  801e19:	e8 c3 ef ff ff       	call   800de1 <sys_page_map>
  801e1e:	89 c3                	mov    %eax,%ebx
  801e20:	83 c4 20             	add    $0x20,%esp
  801e23:	85 c0                	test   %eax,%eax
  801e25:	78 55                	js     801e7c <pipe+0x116>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801e27:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801e2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e30:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801e32:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e35:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801e3c:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801e42:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e45:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801e47:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e4a:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801e51:	83 ec 0c             	sub    $0xc,%esp
  801e54:	ff 75 f4             	pushl  -0xc(%ebp)
  801e57:	e8 3d f5 ff ff       	call   801399 <fd2num>
  801e5c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e5f:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801e61:	83 c4 04             	add    $0x4,%esp
  801e64:	ff 75 f0             	pushl  -0x10(%ebp)
  801e67:	e8 2d f5 ff ff       	call   801399 <fd2num>
  801e6c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e6f:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801e72:	83 c4 10             	add    $0x10,%esp
  801e75:	b8 00 00 00 00       	mov    $0x0,%eax
  801e7a:	eb 30                	jmp    801eac <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  801e7c:	83 ec 08             	sub    $0x8,%esp
  801e7f:	56                   	push   %esi
  801e80:	6a 00                	push   $0x0
  801e82:	e8 9c ef ff ff       	call   800e23 <sys_page_unmap>
  801e87:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801e8a:	83 ec 08             	sub    $0x8,%esp
  801e8d:	ff 75 f0             	pushl  -0x10(%ebp)
  801e90:	6a 00                	push   $0x0
  801e92:	e8 8c ef ff ff       	call   800e23 <sys_page_unmap>
  801e97:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801e9a:	83 ec 08             	sub    $0x8,%esp
  801e9d:	ff 75 f4             	pushl  -0xc(%ebp)
  801ea0:	6a 00                	push   $0x0
  801ea2:	e8 7c ef ff ff       	call   800e23 <sys_page_unmap>
  801ea7:	83 c4 10             	add    $0x10,%esp
  801eaa:	89 d8                	mov    %ebx,%eax
    err:
	return r;
}
  801eac:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801eaf:	5b                   	pop    %ebx
  801eb0:	5e                   	pop    %esi
  801eb1:	5d                   	pop    %ebp
  801eb2:	c3                   	ret    

00801eb3 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801eb3:	55                   	push   %ebp
  801eb4:	89 e5                	mov    %esp,%ebp
  801eb6:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801eb9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ebc:	50                   	push   %eax
  801ebd:	ff 75 08             	pushl  0x8(%ebp)
  801ec0:	e8 6f f5 ff ff       	call   801434 <fd_lookup>
  801ec5:	83 c4 10             	add    $0x10,%esp
  801ec8:	85 c0                	test   %eax,%eax
  801eca:	78 18                	js     801ee4 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801ecc:	83 ec 0c             	sub    $0xc,%esp
  801ecf:	ff 75 f4             	pushl  -0xc(%ebp)
  801ed2:	e8 d2 f4 ff ff       	call   8013a9 <fd2data>
	return _pipeisclosed(fd, p);
  801ed7:	89 c2                	mov    %eax,%edx
  801ed9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801edc:	e8 17 fd ff ff       	call   801bf8 <_pipeisclosed>
  801ee1:	83 c4 10             	add    $0x10,%esp
}
  801ee4:	c9                   	leave  
  801ee5:	c3                   	ret    

00801ee6 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801ee6:	55                   	push   %ebp
  801ee7:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801ee9:	b8 00 00 00 00       	mov    $0x0,%eax
  801eee:	5d                   	pop    %ebp
  801eef:	c3                   	ret    

00801ef0 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801ef0:	55                   	push   %ebp
  801ef1:	89 e5                	mov    %esp,%ebp
  801ef3:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801ef6:	68 a3 29 80 00       	push   $0x8029a3
  801efb:	ff 75 0c             	pushl  0xc(%ebp)
  801efe:	e8 2b ea ff ff       	call   80092e <strcpy>
	return 0;
}
  801f03:	b8 00 00 00 00       	mov    $0x0,%eax
  801f08:	c9                   	leave  
  801f09:	c3                   	ret    

00801f0a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801f0a:	55                   	push   %ebp
  801f0b:	89 e5                	mov    %esp,%ebp
  801f0d:	57                   	push   %edi
  801f0e:	56                   	push   %esi
  801f0f:	53                   	push   %ebx
  801f10:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f16:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801f1a:	74 45                	je     801f61 <devcons_write+0x57>
  801f1c:	b8 00 00 00 00       	mov    $0x0,%eax
  801f21:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801f26:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801f2c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801f2f:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  801f31:	83 fb 7f             	cmp    $0x7f,%ebx
  801f34:	76 05                	jbe    801f3b <devcons_write+0x31>
			m = sizeof(buf) - 1;
  801f36:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801f3b:	83 ec 04             	sub    $0x4,%esp
  801f3e:	53                   	push   %ebx
  801f3f:	03 45 0c             	add    0xc(%ebp),%eax
  801f42:	50                   	push   %eax
  801f43:	57                   	push   %edi
  801f44:	e8 b2 eb ff ff       	call   800afb <memmove>
		sys_cputs(buf, m);
  801f49:	83 c4 08             	add    $0x8,%esp
  801f4c:	53                   	push   %ebx
  801f4d:	57                   	push   %edi
  801f4e:	e8 8f ed ff ff       	call   800ce2 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f53:	01 de                	add    %ebx,%esi
  801f55:	89 f0                	mov    %esi,%eax
  801f57:	83 c4 10             	add    $0x10,%esp
  801f5a:	3b 75 10             	cmp    0x10(%ebp),%esi
  801f5d:	72 cd                	jb     801f2c <devcons_write+0x22>
  801f5f:	eb 05                	jmp    801f66 <devcons_write+0x5c>
  801f61:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801f66:	89 f0                	mov    %esi,%eax
  801f68:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f6b:	5b                   	pop    %ebx
  801f6c:	5e                   	pop    %esi
  801f6d:	5f                   	pop    %edi
  801f6e:	5d                   	pop    %ebp
  801f6f:	c3                   	ret    

00801f70 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801f70:	55                   	push   %ebp
  801f71:	89 e5                	mov    %esp,%ebp
  801f73:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801f76:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801f7a:	75 07                	jne    801f83 <devcons_read+0x13>
  801f7c:	eb 23                	jmp    801fa1 <devcons_read+0x31>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801f7e:	e8 fc ed ff ff       	call   800d7f <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801f83:	e8 78 ed ff ff       	call   800d00 <sys_cgetc>
  801f88:	85 c0                	test   %eax,%eax
  801f8a:	74 f2                	je     801f7e <devcons_read+0xe>
		sys_yield();
	if (c < 0)
  801f8c:	85 c0                	test   %eax,%eax
  801f8e:	78 1d                	js     801fad <devcons_read+0x3d>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801f90:	83 f8 04             	cmp    $0x4,%eax
  801f93:	74 13                	je     801fa8 <devcons_read+0x38>
		return 0;
	*(char*)vbuf = c;
  801f95:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f98:	88 02                	mov    %al,(%edx)
	return 1;
  801f9a:	b8 01 00 00 00       	mov    $0x1,%eax
  801f9f:	eb 0c                	jmp    801fad <devcons_read+0x3d>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801fa1:	b8 00 00 00 00       	mov    $0x0,%eax
  801fa6:	eb 05                	jmp    801fad <devcons_read+0x3d>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801fa8:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801fad:	c9                   	leave  
  801fae:	c3                   	ret    

00801faf <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801faf:	55                   	push   %ebp
  801fb0:	89 e5                	mov    %esp,%ebp
  801fb2:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801fb5:	8b 45 08             	mov    0x8(%ebp),%eax
  801fb8:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801fbb:	6a 01                	push   $0x1
  801fbd:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801fc0:	50                   	push   %eax
  801fc1:	e8 1c ed ff ff       	call   800ce2 <sys_cputs>
}
  801fc6:	83 c4 10             	add    $0x10,%esp
  801fc9:	c9                   	leave  
  801fca:	c3                   	ret    

00801fcb <getchar>:

int
getchar(void)
{
  801fcb:	55                   	push   %ebp
  801fcc:	89 e5                	mov    %esp,%ebp
  801fce:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801fd1:	6a 01                	push   $0x1
  801fd3:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801fd6:	50                   	push   %eax
  801fd7:	6a 00                	push   $0x0
  801fd9:	e8 d7 f6 ff ff       	call   8016b5 <read>
	if (r < 0)
  801fde:	83 c4 10             	add    $0x10,%esp
  801fe1:	85 c0                	test   %eax,%eax
  801fe3:	78 0f                	js     801ff4 <getchar+0x29>
		return r;
	if (r < 1)
  801fe5:	85 c0                	test   %eax,%eax
  801fe7:	7e 06                	jle    801fef <getchar+0x24>
		return -E_EOF;
	return c;
  801fe9:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801fed:	eb 05                	jmp    801ff4 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801fef:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801ff4:	c9                   	leave  
  801ff5:	c3                   	ret    

00801ff6 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801ff6:	55                   	push   %ebp
  801ff7:	89 e5                	mov    %esp,%ebp
  801ff9:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ffc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fff:	50                   	push   %eax
  802000:	ff 75 08             	pushl  0x8(%ebp)
  802003:	e8 2c f4 ff ff       	call   801434 <fd_lookup>
  802008:	83 c4 10             	add    $0x10,%esp
  80200b:	85 c0                	test   %eax,%eax
  80200d:	78 11                	js     802020 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80200f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802012:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802018:	39 10                	cmp    %edx,(%eax)
  80201a:	0f 94 c0             	sete   %al
  80201d:	0f b6 c0             	movzbl %al,%eax
}
  802020:	c9                   	leave  
  802021:	c3                   	ret    

00802022 <opencons>:

int
opencons(void)
{
  802022:	55                   	push   %ebp
  802023:	89 e5                	mov    %esp,%ebp
  802025:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802028:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80202b:	50                   	push   %eax
  80202c:	e8 8f f3 ff ff       	call   8013c0 <fd_alloc>
  802031:	83 c4 10             	add    $0x10,%esp
  802034:	85 c0                	test   %eax,%eax
  802036:	78 3a                	js     802072 <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802038:	83 ec 04             	sub    $0x4,%esp
  80203b:	68 07 04 00 00       	push   $0x407
  802040:	ff 75 f4             	pushl  -0xc(%ebp)
  802043:	6a 00                	push   $0x0
  802045:	e8 54 ed ff ff       	call   800d9e <sys_page_alloc>
  80204a:	83 c4 10             	add    $0x10,%esp
  80204d:	85 c0                	test   %eax,%eax
  80204f:	78 21                	js     802072 <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802051:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802057:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80205a:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80205c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80205f:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802066:	83 ec 0c             	sub    $0xc,%esp
  802069:	50                   	push   %eax
  80206a:	e8 2a f3 ff ff       	call   801399 <fd2num>
  80206f:	83 c4 10             	add    $0x10,%esp
}
  802072:	c9                   	leave  
  802073:	c3                   	ret    

00802074 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802074:	55                   	push   %ebp
  802075:	89 e5                	mov    %esp,%ebp
  802077:	53                   	push   %ebx
  802078:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (_pgfault_handler == 0) {
  80207b:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  802082:	75 5b                	jne    8020df <set_pgfault_handler+0x6b>
		// First time through!
		// LAB 4: Your code here.
		void *va = (void *)(UXSTACKTOP - PGSIZE);
		envid_t eid = sys_getenvid();
  802084:	e8 d7 ec ff ff       	call   800d60 <sys_getenvid>
  802089:	89 c3                	mov    %eax,%ebx
		r = sys_page_alloc(eid,va,PTE_P | PTE_U | PTE_W);
  80208b:	83 ec 04             	sub    $0x4,%esp
  80208e:	6a 07                	push   $0x7
  802090:	68 00 f0 bf ee       	push   $0xeebff000
  802095:	50                   	push   %eax
  802096:	e8 03 ed ff ff       	call   800d9e <sys_page_alloc>
		if(r<0) panic("set_pgfault_handler\n");
  80209b:	83 c4 10             	add    $0x10,%esp
  80209e:	85 c0                	test   %eax,%eax
  8020a0:	79 14                	jns    8020b6 <set_pgfault_handler+0x42>
  8020a2:	83 ec 04             	sub    $0x4,%esp
  8020a5:	68 af 29 80 00       	push   $0x8029af
  8020aa:	6a 23                	push   $0x23
  8020ac:	68 c4 29 80 00       	push   $0x8029c4
  8020b1:	e8 bb e1 ff ff       	call   800271 <_panic>
		r = sys_env_set_pgfault_upcall(eid,_pgfault_upcall);
  8020b6:	83 ec 08             	sub    $0x8,%esp
  8020b9:	68 ec 20 80 00       	push   $0x8020ec
  8020be:	53                   	push   %ebx
  8020bf:	e8 25 ee ff ff       	call   800ee9 <sys_env_set_pgfault_upcall>
		if(r<0) panic("set_pgfault_handler\n");
  8020c4:	83 c4 10             	add    $0x10,%esp
  8020c7:	85 c0                	test   %eax,%eax
  8020c9:	79 14                	jns    8020df <set_pgfault_handler+0x6b>
  8020cb:	83 ec 04             	sub    $0x4,%esp
  8020ce:	68 af 29 80 00       	push   $0x8029af
  8020d3:	6a 25                	push   $0x25
  8020d5:	68 c4 29 80 00       	push   $0x8029c4
  8020da:	e8 92 e1 ff ff       	call   800271 <_panic>
		// panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8020df:	8b 45 08             	mov    0x8(%ebp),%eax
  8020e2:	a3 00 60 80 00       	mov    %eax,0x806000
}
  8020e7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8020ea:	c9                   	leave  
  8020eb:	c3                   	ret    

008020ec <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8020ec:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8020ed:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  8020f2:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8020f4:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl %esp,%ebx
  8020f7:	89 e3                	mov    %esp,%ebx
	movl 40(%esp),%eax 	// esp from utf_fault_va to utf_regs(end)
  8020f9:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl 48(%esp),%esp 	// 
  8020fd:	8b 64 24 30          	mov    0x30(%esp),%esp
	pushl %eax
  802101:	50                   	push   %eax
 
 
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	movl %ebx,%esp
  802102:	89 dc                	mov    %ebx,%esp
	subl $4,48(%esp)
  802104:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	popl %eax
  802109:	58                   	pop    %eax
	popl %eax
  80210a:	58                   	pop    %eax
	popal
  80210b:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	add $4,%esp
  80210c:	83 c4 04             	add    $0x4,%esp
	popfl
  80210f:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  802110:	5c                   	pop    %esp
 
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  802111:	c3                   	ret    
  802112:	66 90                	xchg   %ax,%ax

00802114 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  802114:	55                   	push   %ebp
  802115:	57                   	push   %edi
  802116:	56                   	push   %esi
  802117:	53                   	push   %ebx
  802118:	83 ec 1c             	sub    $0x1c,%esp
  80211b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80211f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802123:	8b 7c 24 38          	mov    0x38(%esp),%edi
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  802127:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80212b:	89 ca                	mov    %ecx,%edx
  const DWunion dd = {.ll = d};
  80212d:	89 f8                	mov    %edi,%eax
  80212f:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802133:	85 f6                	test   %esi,%esi
  802135:	75 2d                	jne    802164 <__udivdi3+0x50>
    {
      if (d0 > n1)
  802137:	39 cf                	cmp    %ecx,%edi
  802139:	77 65                	ja     8021a0 <__udivdi3+0x8c>
  80213b:	89 fd                	mov    %edi,%ebp
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  80213d:	85 ff                	test   %edi,%edi
  80213f:	75 0b                	jne    80214c <__udivdi3+0x38>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802141:	b8 01 00 00 00       	mov    $0x1,%eax
  802146:	31 d2                	xor    %edx,%edx
  802148:	f7 f7                	div    %edi
  80214a:	89 c5                	mov    %eax,%ebp

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80214c:	31 d2                	xor    %edx,%edx
  80214e:	89 c8                	mov    %ecx,%eax
  802150:	f7 f5                	div    %ebp
  802152:	89 c1                	mov    %eax,%ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802154:	89 d8                	mov    %ebx,%eax
  802156:	f7 f5                	div    %ebp
  802158:	89 cf                	mov    %ecx,%edi
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80215a:	89 fa                	mov    %edi,%edx
  80215c:	83 c4 1c             	add    $0x1c,%esp
  80215f:	5b                   	pop    %ebx
  802160:	5e                   	pop    %esi
  802161:	5f                   	pop    %edi
  802162:	5d                   	pop    %ebp
  802163:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802164:	39 ce                	cmp    %ecx,%esi
  802166:	77 28                	ja     802190 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802168:	0f bd fe             	bsr    %esi,%edi
	  if (bm == 0)
  80216b:	83 f7 1f             	xor    $0x1f,%edi
  80216e:	75 40                	jne    8021b0 <__udivdi3+0x9c>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802170:	39 ce                	cmp    %ecx,%esi
  802172:	72 0a                	jb     80217e <__udivdi3+0x6a>
  802174:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802178:	0f 87 9e 00 00 00    	ja     80221c <__udivdi3+0x108>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  80217e:	b8 01 00 00 00       	mov    $0x1,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802183:	89 fa                	mov    %edi,%edx
  802185:	83 c4 1c             	add    $0x1c,%esp
  802188:	5b                   	pop    %ebx
  802189:	5e                   	pop    %esi
  80218a:	5f                   	pop    %edi
  80218b:	5d                   	pop    %ebp
  80218c:	c3                   	ret    
  80218d:	8d 76 00             	lea    0x0(%esi),%esi
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802190:	31 ff                	xor    %edi,%edi
  802192:	31 c0                	xor    %eax,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802194:	89 fa                	mov    %edi,%edx
  802196:	83 c4 1c             	add    $0x1c,%esp
  802199:	5b                   	pop    %ebx
  80219a:	5e                   	pop    %esi
  80219b:	5f                   	pop    %edi
  80219c:	5d                   	pop    %ebp
  80219d:	c3                   	ret    
  80219e:	66 90                	xchg   %ax,%ax
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8021a0:	89 d8                	mov    %ebx,%eax
  8021a2:	f7 f7                	div    %edi
  8021a4:	31 ff                	xor    %edi,%edi
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8021a6:	89 fa                	mov    %edi,%edx
  8021a8:	83 c4 1c             	add    $0x1c,%esp
  8021ab:	5b                   	pop    %ebx
  8021ac:	5e                   	pop    %esi
  8021ad:	5f                   	pop    %edi
  8021ae:	5d                   	pop    %ebp
  8021af:	c3                   	ret    
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8021b0:	bd 20 00 00 00       	mov    $0x20,%ebp
  8021b5:	89 eb                	mov    %ebp,%ebx
  8021b7:	29 fb                	sub    %edi,%ebx

	      d1 = (d1 << bm) | (d0 >> b);
  8021b9:	89 f9                	mov    %edi,%ecx
  8021bb:	d3 e6                	shl    %cl,%esi
  8021bd:	89 c5                	mov    %eax,%ebp
  8021bf:	88 d9                	mov    %bl,%cl
  8021c1:	d3 ed                	shr    %cl,%ebp
  8021c3:	89 e9                	mov    %ebp,%ecx
  8021c5:	09 f1                	or     %esi,%ecx
  8021c7:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
	      d0 = d0 << bm;
  8021cb:	89 f9                	mov    %edi,%ecx
  8021cd:	d3 e0                	shl    %cl,%eax
  8021cf:	89 c5                	mov    %eax,%ebp
	      n2 = n1 >> b;
  8021d1:	89 d6                	mov    %edx,%esi
  8021d3:	88 d9                	mov    %bl,%cl
  8021d5:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
  8021d7:	89 f9                	mov    %edi,%ecx
  8021d9:	d3 e2                	shl    %cl,%edx
  8021db:	8b 44 24 08          	mov    0x8(%esp),%eax
  8021df:	88 d9                	mov    %bl,%cl
  8021e1:	d3 e8                	shr    %cl,%eax
  8021e3:	09 c2                	or     %eax,%edx
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8021e5:	89 d0                	mov    %edx,%eax
  8021e7:	89 f2                	mov    %esi,%edx
  8021e9:	f7 74 24 0c          	divl   0xc(%esp)
  8021ed:	89 d6                	mov    %edx,%esi
  8021ef:	89 c3                	mov    %eax,%ebx
	      umul_ppmm (m1, m0, q0, d0);
  8021f1:	f7 e5                	mul    %ebp

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8021f3:	39 d6                	cmp    %edx,%esi
  8021f5:	72 19                	jb     802210 <__udivdi3+0xfc>
  8021f7:	74 0b                	je     802204 <__udivdi3+0xf0>
  8021f9:	89 d8                	mov    %ebx,%eax
  8021fb:	31 ff                	xor    %edi,%edi
  8021fd:	e9 58 ff ff ff       	jmp    80215a <__udivdi3+0x46>
  802202:	66 90                	xchg   %ax,%ax
  802204:	8b 54 24 08          	mov    0x8(%esp),%edx
  802208:	89 f9                	mov    %edi,%ecx
  80220a:	d3 e2                	shl    %cl,%edx
  80220c:	39 c2                	cmp    %eax,%edx
  80220e:	73 e9                	jae    8021f9 <__udivdi3+0xe5>
  802210:	8d 43 ff             	lea    -0x1(%ebx),%eax
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802213:	31 ff                	xor    %edi,%edi
  802215:	e9 40 ff ff ff       	jmp    80215a <__udivdi3+0x46>
  80221a:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  80221c:	31 c0                	xor    %eax,%eax
  80221e:	e9 37 ff ff ff       	jmp    80215a <__udivdi3+0x46>
  802223:	90                   	nop

00802224 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  802224:	55                   	push   %ebp
  802225:	57                   	push   %edi
  802226:	56                   	push   %esi
  802227:	53                   	push   %ebx
  802228:	83 ec 1c             	sub    $0x1c,%esp
  80222b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80222f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802233:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802237:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80223b:	89 44 24 0c          	mov    %eax,0xc(%esp)
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  80223f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802243:	89 f3                	mov    %esi,%ebx
  const DWunion dd = {.ll = d};
  802245:	89 fa                	mov    %edi,%edx
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  802247:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  n1 = nn.s.high;
  80224b:	89 34 24             	mov    %esi,(%esp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  80224e:	85 c0                	test   %eax,%eax
  802250:	75 1a                	jne    80226c <__umoddi3+0x48>
    {
      if (d0 > n1)
  802252:	39 f7                	cmp    %esi,%edi
  802254:	0f 86 a2 00 00 00    	jbe    8022fc <__umoddi3+0xd8>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80225a:	89 c8                	mov    %ecx,%eax
  80225c:	89 f2                	mov    %esi,%edx
  80225e:	f7 f7                	div    %edi
  802260:	89 d0                	mov    %edx,%eax

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  802262:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802264:	83 c4 1c             	add    $0x1c,%esp
  802267:	5b                   	pop    %ebx
  802268:	5e                   	pop    %esi
  802269:	5f                   	pop    %edi
  80226a:	5d                   	pop    %ebp
  80226b:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  80226c:	39 f0                	cmp    %esi,%eax
  80226e:	0f 87 ac 00 00 00    	ja     802320 <__umoddi3+0xfc>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802274:	0f bd e8             	bsr    %eax,%ebp
	  if (bm == 0)
  802277:	83 f5 1f             	xor    $0x1f,%ebp
  80227a:	0f 84 ac 00 00 00    	je     80232c <__umoddi3+0x108>
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802280:	bf 20 00 00 00       	mov    $0x20,%edi
  802285:	29 ef                	sub    %ebp,%edi
  802287:	89 fe                	mov    %edi,%esi
  802289:	89 7c 24 0c          	mov    %edi,0xc(%esp)

	      d1 = (d1 << bm) | (d0 >> b);
  80228d:	89 e9                	mov    %ebp,%ecx
  80228f:	d3 e0                	shl    %cl,%eax
  802291:	89 d7                	mov    %edx,%edi
  802293:	89 f1                	mov    %esi,%ecx
  802295:	d3 ef                	shr    %cl,%edi
  802297:	09 c7                	or     %eax,%edi
	      d0 = d0 << bm;
  802299:	89 e9                	mov    %ebp,%ecx
  80229b:	d3 e2                	shl    %cl,%edx
  80229d:	89 14 24             	mov    %edx,(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8022a0:	89 d8                	mov    %ebx,%eax
  8022a2:	d3 e0                	shl    %cl,%eax
  8022a4:	89 c2                	mov    %eax,%edx
	      n0 = n0 << bm;
  8022a6:	8b 44 24 08          	mov    0x8(%esp),%eax
  8022aa:	d3 e0                	shl    %cl,%eax
  8022ac:	89 44 24 04          	mov    %eax,0x4(%esp)

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8022b0:	8b 44 24 08          	mov    0x8(%esp),%eax
  8022b4:	89 f1                	mov    %esi,%ecx
  8022b6:	d3 e8                	shr    %cl,%eax
  8022b8:	09 d0                	or     %edx,%eax
  8022ba:	d3 eb                	shr    %cl,%ebx
  8022bc:	89 da                	mov    %ebx,%edx
  8022be:	f7 f7                	div    %edi
  8022c0:	89 d3                	mov    %edx,%ebx
	      umul_ppmm (m1, m0, q0, d0);
  8022c2:	f7 24 24             	mull   (%esp)
  8022c5:	89 c6                	mov    %eax,%esi
  8022c7:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8022c9:	39 d3                	cmp    %edx,%ebx
  8022cb:	0f 82 87 00 00 00    	jb     802358 <__umoddi3+0x134>
  8022d1:	0f 84 91 00 00 00    	je     802368 <__umoddi3+0x144>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  8022d7:	8b 54 24 04          	mov    0x4(%esp),%edx
  8022db:	29 f2                	sub    %esi,%edx
  8022dd:	19 cb                	sbb    %ecx,%ebx
		  rr.s.low = (n1 << b) | (n0 >> bm);
  8022df:	89 d8                	mov    %ebx,%eax
  8022e1:	8a 4c 24 0c          	mov    0xc(%esp),%cl
  8022e5:	d3 e0                	shl    %cl,%eax
  8022e7:	89 e9                	mov    %ebp,%ecx
  8022e9:	d3 ea                	shr    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  8022eb:	09 d0                	or     %edx,%eax
  8022ed:	89 e9                	mov    %ebp,%ecx
  8022ef:	d3 eb                	shr    %cl,%ebx
  8022f1:	89 da                	mov    %ebx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8022f3:	83 c4 1c             	add    $0x1c,%esp
  8022f6:	5b                   	pop    %ebx
  8022f7:	5e                   	pop    %esi
  8022f8:	5f                   	pop    %edi
  8022f9:	5d                   	pop    %ebp
  8022fa:	c3                   	ret    
  8022fb:	90                   	nop
  8022fc:	89 fd                	mov    %edi,%ebp
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8022fe:	85 ff                	test   %edi,%edi
  802300:	75 0b                	jne    80230d <__umoddi3+0xe9>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802302:	b8 01 00 00 00       	mov    $0x1,%eax
  802307:	31 d2                	xor    %edx,%edx
  802309:	f7 f7                	div    %edi
  80230b:	89 c5                	mov    %eax,%ebp

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80230d:	89 f0                	mov    %esi,%eax
  80230f:	31 d2                	xor    %edx,%edx
  802311:	f7 f5                	div    %ebp
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802313:	89 c8                	mov    %ecx,%eax
  802315:	f7 f5                	div    %ebp
  802317:	89 d0                	mov    %edx,%eax
  802319:	e9 44 ff ff ff       	jmp    802262 <__umoddi3+0x3e>
  80231e:	66 90                	xchg   %ax,%ax
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  802320:	89 c8                	mov    %ecx,%eax
  802322:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802324:	83 c4 1c             	add    $0x1c,%esp
  802327:	5b                   	pop    %ebx
  802328:	5e                   	pop    %esi
  802329:	5f                   	pop    %edi
  80232a:	5d                   	pop    %ebp
  80232b:	c3                   	ret    

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  80232c:	3b 04 24             	cmp    (%esp),%eax
  80232f:	72 06                	jb     802337 <__umoddi3+0x113>
  802331:	3b 7c 24 04          	cmp    0x4(%esp),%edi
  802335:	77 0f                	ja     802346 <__umoddi3+0x122>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802337:	89 f2                	mov    %esi,%edx
  802339:	29 f9                	sub    %edi,%ecx
  80233b:	1b 54 24 0c          	sbb    0xc(%esp),%edx
  80233f:	89 14 24             	mov    %edx,(%esp)
  802342:	89 4c 24 04          	mov    %ecx,0x4(%esp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  802346:	8b 44 24 04          	mov    0x4(%esp),%eax
  80234a:	8b 14 24             	mov    (%esp),%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80234d:	83 c4 1c             	add    $0x1c,%esp
  802350:	5b                   	pop    %ebx
  802351:	5e                   	pop    %esi
  802352:	5f                   	pop    %edi
  802353:	5d                   	pop    %ebp
  802354:	c3                   	ret    
  802355:	8d 76 00             	lea    0x0(%esi),%esi
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802358:	2b 04 24             	sub    (%esp),%eax
  80235b:	19 fa                	sbb    %edi,%edx
  80235d:	89 d1                	mov    %edx,%ecx
  80235f:	89 c6                	mov    %eax,%esi
  802361:	e9 71 ff ff ff       	jmp    8022d7 <__umoddi3+0xb3>
  802366:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802368:	39 44 24 04          	cmp    %eax,0x4(%esp)
  80236c:	72 ea                	jb     802358 <__umoddi3+0x134>
  80236e:	89 d9                	mov    %ebx,%ecx
  802370:	e9 62 ff ff ff       	jmp    8022d7 <__umoddi3+0xb3>
