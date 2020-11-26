
obj/user/dumbfork.debug:     file format elf32-i386


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
  80002c:	e8 c3 01 00 00       	call   8001f4 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <duppage>:
	}
}

void
duppage(envid_t dstenv, void *addr)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	8b 75 08             	mov    0x8(%ebp),%esi
  80003b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	// This is NOT what you should do in your fork.
	if ((r = sys_page_alloc(dstenv, addr, PTE_P|PTE_U|PTE_W)) < 0)
  80003e:	83 ec 04             	sub    $0x4,%esp
  800041:	6a 07                	push   $0x7
  800043:	53                   	push   %ebx
  800044:	56                   	push   %esi
  800045:	e8 40 0d 00 00       	call   800d8a <sys_page_alloc>
  80004a:	83 c4 10             	add    $0x10,%esp
  80004d:	85 c0                	test   %eax,%eax
  80004f:	79 12                	jns    800063 <duppage+0x30>
		panic("sys_page_alloc: %e", r);
  800051:	50                   	push   %eax
  800052:	68 00 20 80 00       	push   $0x802000
  800057:	6a 20                	push   $0x20
  800059:	68 13 20 80 00       	push   $0x802013
  80005e:	e8 fa 01 00 00       	call   80025d <_panic>
	if ((r = sys_page_map(dstenv, addr, 0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  800063:	83 ec 0c             	sub    $0xc,%esp
  800066:	6a 07                	push   $0x7
  800068:	68 00 00 40 00       	push   $0x400000
  80006d:	6a 00                	push   $0x0
  80006f:	53                   	push   %ebx
  800070:	56                   	push   %esi
  800071:	e8 57 0d 00 00       	call   800dcd <sys_page_map>
  800076:	83 c4 20             	add    $0x20,%esp
  800079:	85 c0                	test   %eax,%eax
  80007b:	79 12                	jns    80008f <duppage+0x5c>
		panic("sys_page_map: %e", r);
  80007d:	50                   	push   %eax
  80007e:	68 23 20 80 00       	push   $0x802023
  800083:	6a 22                	push   $0x22
  800085:	68 13 20 80 00       	push   $0x802013
  80008a:	e8 ce 01 00 00       	call   80025d <_panic>
	memmove(UTEMP, addr, PGSIZE);
  80008f:	83 ec 04             	sub    $0x4,%esp
  800092:	68 00 10 00 00       	push   $0x1000
  800097:	53                   	push   %ebx
  800098:	68 00 00 40 00       	push   $0x400000
  80009d:	e8 45 0a 00 00       	call   800ae7 <memmove>
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  8000a2:	83 c4 08             	add    $0x8,%esp
  8000a5:	68 00 00 40 00       	push   $0x400000
  8000aa:	6a 00                	push   $0x0
  8000ac:	e8 5e 0d 00 00       	call   800e0f <sys_page_unmap>
  8000b1:	83 c4 10             	add    $0x10,%esp
  8000b4:	85 c0                	test   %eax,%eax
  8000b6:	79 12                	jns    8000ca <duppage+0x97>
		panic("sys_page_unmap: %e", r);
  8000b8:	50                   	push   %eax
  8000b9:	68 34 20 80 00       	push   $0x802034
  8000be:	6a 25                	push   $0x25
  8000c0:	68 13 20 80 00       	push   $0x802013
  8000c5:	e8 93 01 00 00       	call   80025d <_panic>
}
  8000ca:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000cd:	5b                   	pop    %ebx
  8000ce:	5e                   	pop    %esi
  8000cf:	5d                   	pop    %ebp
  8000d0:	c3                   	ret    

008000d1 <dumbfork>:

envid_t
dumbfork(void)
{
  8000d1:	55                   	push   %ebp
  8000d2:	89 e5                	mov    %esp,%ebp
  8000d4:	56                   	push   %esi
  8000d5:	53                   	push   %ebx
  8000d6:	83 ec 10             	sub    $0x10,%esp
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  8000d9:	b8 07 00 00 00       	mov    $0x7,%eax
  8000de:	cd 30                	int    $0x30
  8000e0:	89 c3                	mov    %eax,%ebx
	// The kernel will initialize it with a copy of our register state,
	// so that the child will appear to have called sys_exofork() too -
	// except that in the child, this "fake" call to sys_exofork()
	// will return 0 instead of the envid of the child.
	envid = sys_exofork();
	if (envid < 0)
  8000e2:	85 c0                	test   %eax,%eax
  8000e4:	79 12                	jns    8000f8 <dumbfork+0x27>
		panic("sys_exofork: %e", envid);
  8000e6:	50                   	push   %eax
  8000e7:	68 47 20 80 00       	push   $0x802047
  8000ec:	6a 37                	push   $0x37
  8000ee:	68 13 20 80 00       	push   $0x802013
  8000f3:	e8 65 01 00 00       	call   80025d <_panic>
  8000f8:	89 c6                	mov    %eax,%esi
	if (envid == 0) {
  8000fa:	85 c0                	test   %eax,%eax
  8000fc:	75 27                	jne    800125 <dumbfork+0x54>
		// We're the child.
		// The copied value of the global variable 'thisenv'
		// is no longer valid (it refers to the parent!).
		// Fix it and return 0.
		thisenv = &envs[ENVX(sys_getenvid())];
  8000fe:	e8 49 0c 00 00       	call   800d4c <sys_getenvid>
  800103:	25 ff 03 00 00       	and    $0x3ff,%eax
  800108:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80010f:	c1 e0 07             	shl    $0x7,%eax
  800112:	29 d0                	sub    %edx,%eax
  800114:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800119:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  80011e:	b8 00 00 00 00       	mov    $0x0,%eax
  800123:	eb 71                	jmp    800196 <dumbfork+0xc5>
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  800125:	c7 45 f4 00 00 80 00 	movl   $0x800000,-0xc(%ebp)
  80012c:	b8 00 60 80 00       	mov    $0x806000,%eax
  800131:	3d 00 00 80 00       	cmp    $0x800000,%eax
  800136:	76 26                	jbe    80015e <dumbfork+0x8d>
  800138:	ba 00 00 80 00       	mov    $0x800000,%edx
		duppage(envid, addr);
  80013d:	83 ec 08             	sub    $0x8,%esp
  800140:	52                   	push   %edx
  800141:	56                   	push   %esi
  800142:	e8 ec fe ff ff       	call   800033 <duppage>
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  800147:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80014a:	8d 90 00 10 00 00    	lea    0x1000(%eax),%edx
  800150:	89 55 f4             	mov    %edx,-0xc(%ebp)
  800153:	83 c4 10             	add    $0x10,%esp
  800156:	81 fa 00 60 80 00    	cmp    $0x806000,%edx
  80015c:	72 df                	jb     80013d <dumbfork+0x6c>
		duppage(envid, addr);

	// Also copy the stack we are currently running on.
	duppage(envid, ROUNDDOWN(&addr, PGSIZE));
  80015e:	83 ec 08             	sub    $0x8,%esp
  800161:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800164:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800169:	50                   	push   %eax
  80016a:	53                   	push   %ebx
  80016b:	e8 c3 fe ff ff       	call   800033 <duppage>

	// Start the child environment running
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  800170:	83 c4 08             	add    $0x8,%esp
  800173:	6a 02                	push   $0x2
  800175:	53                   	push   %ebx
  800176:	e8 d6 0c 00 00       	call   800e51 <sys_env_set_status>
  80017b:	83 c4 10             	add    $0x10,%esp
  80017e:	85 c0                	test   %eax,%eax
  800180:	79 12                	jns    800194 <dumbfork+0xc3>
		panic("sys_env_set_status: %e", r);
  800182:	50                   	push   %eax
  800183:	68 57 20 80 00       	push   $0x802057
  800188:	6a 4c                	push   $0x4c
  80018a:	68 13 20 80 00       	push   $0x802013
  80018f:	e8 c9 00 00 00       	call   80025d <_panic>

	return envid;
  800194:	89 d8                	mov    %ebx,%eax
}
  800196:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800199:	5b                   	pop    %ebx
  80019a:	5e                   	pop    %esi
  80019b:	5d                   	pop    %ebp
  80019c:	c3                   	ret    

0080019d <umain>:

envid_t dumbfork(void);

void
umain(int argc, char **argv)
{
  80019d:	55                   	push   %ebp
  80019e:	89 e5                	mov    %esp,%ebp
  8001a0:	57                   	push   %edi
  8001a1:	56                   	push   %esi
  8001a2:	53                   	push   %ebx
  8001a3:	83 ec 0c             	sub    $0xc,%esp
	envid_t who;
	int i;

	// fork a child process
	who = dumbfork();
  8001a6:	e8 26 ff ff ff       	call   8000d1 <dumbfork>
  8001ab:	89 c7                	mov    %eax,%edi
  8001ad:	85 c0                	test   %eax,%eax
  8001af:	74 07                	je     8001b8 <umain+0x1b>
  8001b1:	be 6e 20 80 00       	mov    $0x80206e,%esi
  8001b6:	eb 05                	jmp    8001bd <umain+0x20>
  8001b8:	be 75 20 80 00       	mov    $0x802075,%esi

	// print a message and yield to the other a few times
	for (i = 0; i < (who ? 10 : 20); i++) {
  8001bd:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001c2:	eb 18                	jmp    8001dc <umain+0x3f>
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
  8001c4:	83 ec 04             	sub    $0x4,%esp
  8001c7:	56                   	push   %esi
  8001c8:	53                   	push   %ebx
  8001c9:	68 7b 20 80 00       	push   $0x80207b
  8001ce:	e8 62 01 00 00       	call   800335 <cprintf>
		sys_yield();
  8001d3:	e8 93 0b 00 00       	call   800d6b <sys_yield>

	// fork a child process
	who = dumbfork();

	// print a message and yield to the other a few times
	for (i = 0; i < (who ? 10 : 20); i++) {
  8001d8:	43                   	inc    %ebx
  8001d9:	83 c4 10             	add    $0x10,%esp
  8001dc:	85 ff                	test   %edi,%edi
  8001de:	74 07                	je     8001e7 <umain+0x4a>
  8001e0:	83 fb 09             	cmp    $0x9,%ebx
  8001e3:	7e df                	jle    8001c4 <umain+0x27>
  8001e5:	eb 05                	jmp    8001ec <umain+0x4f>
  8001e7:	83 fb 13             	cmp    $0x13,%ebx
  8001ea:	7e d8                	jle    8001c4 <umain+0x27>
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
		sys_yield();
	}
}
  8001ec:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001ef:	5b                   	pop    %ebx
  8001f0:	5e                   	pop    %esi
  8001f1:	5f                   	pop    %edi
  8001f2:	5d                   	pop    %ebp
  8001f3:	c3                   	ret    

008001f4 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001f4:	55                   	push   %ebp
  8001f5:	89 e5                	mov    %esp,%ebp
  8001f7:	56                   	push   %esi
  8001f8:	53                   	push   %ebx
  8001f9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001fc:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8001ff:	e8 48 0b 00 00       	call   800d4c <sys_getenvid>
  800204:	25 ff 03 00 00       	and    $0x3ff,%eax
  800209:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800210:	c1 e0 07             	shl    $0x7,%eax
  800213:	29 d0                	sub    %edx,%eax
  800215:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80021a:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80021f:	85 db                	test   %ebx,%ebx
  800221:	7e 07                	jle    80022a <libmain+0x36>
		binaryname = argv[0];
  800223:	8b 06                	mov    (%esi),%eax
  800225:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80022a:	83 ec 08             	sub    $0x8,%esp
  80022d:	56                   	push   %esi
  80022e:	53                   	push   %ebx
  80022f:	e8 69 ff ff ff       	call   80019d <umain>

	// exit gracefully
	exit();
  800234:	e8 0a 00 00 00       	call   800243 <exit>
}
  800239:	83 c4 10             	add    $0x10,%esp
  80023c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80023f:	5b                   	pop    %ebx
  800240:	5e                   	pop    %esi
  800241:	5d                   	pop    %ebp
  800242:	c3                   	ret    

00800243 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800243:	55                   	push   %ebp
  800244:	89 e5                	mov    %esp,%ebp
  800246:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800249:	e8 3c 0f 00 00       	call   80118a <close_all>
	sys_env_destroy(0);
  80024e:	83 ec 0c             	sub    $0xc,%esp
  800251:	6a 00                	push   $0x0
  800253:	e8 b3 0a 00 00       	call   800d0b <sys_env_destroy>
}
  800258:	83 c4 10             	add    $0x10,%esp
  80025b:	c9                   	leave  
  80025c:	c3                   	ret    

0080025d <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80025d:	55                   	push   %ebp
  80025e:	89 e5                	mov    %esp,%ebp
  800260:	56                   	push   %esi
  800261:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800262:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800265:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80026b:	e8 dc 0a 00 00       	call   800d4c <sys_getenvid>
  800270:	83 ec 0c             	sub    $0xc,%esp
  800273:	ff 75 0c             	pushl  0xc(%ebp)
  800276:	ff 75 08             	pushl  0x8(%ebp)
  800279:	56                   	push   %esi
  80027a:	50                   	push   %eax
  80027b:	68 98 20 80 00       	push   $0x802098
  800280:	e8 b0 00 00 00       	call   800335 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800285:	83 c4 18             	add    $0x18,%esp
  800288:	53                   	push   %ebx
  800289:	ff 75 10             	pushl  0x10(%ebp)
  80028c:	e8 53 00 00 00       	call   8002e4 <vcprintf>
	cprintf("\n");
  800291:	c7 04 24 8b 20 80 00 	movl   $0x80208b,(%esp)
  800298:	e8 98 00 00 00       	call   800335 <cprintf>
  80029d:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8002a0:	cc                   	int3   
  8002a1:	eb fd                	jmp    8002a0 <_panic+0x43>

008002a3 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8002a3:	55                   	push   %ebp
  8002a4:	89 e5                	mov    %esp,%ebp
  8002a6:	53                   	push   %ebx
  8002a7:	83 ec 04             	sub    $0x4,%esp
  8002aa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8002ad:	8b 13                	mov    (%ebx),%edx
  8002af:	8d 42 01             	lea    0x1(%edx),%eax
  8002b2:	89 03                	mov    %eax,(%ebx)
  8002b4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002b7:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8002bb:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002c0:	75 1a                	jne    8002dc <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8002c2:	83 ec 08             	sub    $0x8,%esp
  8002c5:	68 ff 00 00 00       	push   $0xff
  8002ca:	8d 43 08             	lea    0x8(%ebx),%eax
  8002cd:	50                   	push   %eax
  8002ce:	e8 fb 09 00 00       	call   800cce <sys_cputs>
		b->idx = 0;
  8002d3:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8002d9:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8002dc:	ff 43 04             	incl   0x4(%ebx)
}
  8002df:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8002e2:	c9                   	leave  
  8002e3:	c3                   	ret    

008002e4 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002e4:	55                   	push   %ebp
  8002e5:	89 e5                	mov    %esp,%ebp
  8002e7:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8002ed:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002f4:	00 00 00 
	b.cnt = 0;
  8002f7:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002fe:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800301:	ff 75 0c             	pushl  0xc(%ebp)
  800304:	ff 75 08             	pushl  0x8(%ebp)
  800307:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80030d:	50                   	push   %eax
  80030e:	68 a3 02 80 00       	push   $0x8002a3
  800313:	e8 54 01 00 00       	call   80046c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800318:	83 c4 08             	add    $0x8,%esp
  80031b:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800321:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800327:	50                   	push   %eax
  800328:	e8 a1 09 00 00       	call   800cce <sys_cputs>

	return b.cnt;
}
  80032d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800333:	c9                   	leave  
  800334:	c3                   	ret    

00800335 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800335:	55                   	push   %ebp
  800336:	89 e5                	mov    %esp,%ebp
  800338:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80033b:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80033e:	50                   	push   %eax
  80033f:	ff 75 08             	pushl  0x8(%ebp)
  800342:	e8 9d ff ff ff       	call   8002e4 <vcprintf>
	va_end(ap);

	return cnt;
}
  800347:	c9                   	leave  
  800348:	c3                   	ret    

00800349 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800349:	55                   	push   %ebp
  80034a:	89 e5                	mov    %esp,%ebp
  80034c:	57                   	push   %edi
  80034d:	56                   	push   %esi
  80034e:	53                   	push   %ebx
  80034f:	83 ec 1c             	sub    $0x1c,%esp
  800352:	89 c6                	mov    %eax,%esi
  800354:	89 d7                	mov    %edx,%edi
  800356:	8b 45 08             	mov    0x8(%ebp),%eax
  800359:	8b 55 0c             	mov    0xc(%ebp),%edx
  80035c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80035f:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800362:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800365:	bb 00 00 00 00       	mov    $0x0,%ebx
  80036a:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80036d:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800370:	39 d3                	cmp    %edx,%ebx
  800372:	72 11                	jb     800385 <printnum+0x3c>
  800374:	39 45 10             	cmp    %eax,0x10(%ebp)
  800377:	76 0c                	jbe    800385 <printnum+0x3c>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800379:	8b 45 14             	mov    0x14(%ebp),%eax
  80037c:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80037f:	85 db                	test   %ebx,%ebx
  800381:	7f 37                	jg     8003ba <printnum+0x71>
  800383:	eb 44                	jmp    8003c9 <printnum+0x80>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800385:	83 ec 0c             	sub    $0xc,%esp
  800388:	ff 75 18             	pushl  0x18(%ebp)
  80038b:	8b 45 14             	mov    0x14(%ebp),%eax
  80038e:	48                   	dec    %eax
  80038f:	50                   	push   %eax
  800390:	ff 75 10             	pushl  0x10(%ebp)
  800393:	83 ec 08             	sub    $0x8,%esp
  800396:	ff 75 e4             	pushl  -0x1c(%ebp)
  800399:	ff 75 e0             	pushl  -0x20(%ebp)
  80039c:	ff 75 dc             	pushl  -0x24(%ebp)
  80039f:	ff 75 d8             	pushl  -0x28(%ebp)
  8003a2:	e8 e1 19 00 00       	call   801d88 <__udivdi3>
  8003a7:	83 c4 18             	add    $0x18,%esp
  8003aa:	52                   	push   %edx
  8003ab:	50                   	push   %eax
  8003ac:	89 fa                	mov    %edi,%edx
  8003ae:	89 f0                	mov    %esi,%eax
  8003b0:	e8 94 ff ff ff       	call   800349 <printnum>
  8003b5:	83 c4 20             	add    $0x20,%esp
  8003b8:	eb 0f                	jmp    8003c9 <printnum+0x80>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8003ba:	83 ec 08             	sub    $0x8,%esp
  8003bd:	57                   	push   %edi
  8003be:	ff 75 18             	pushl  0x18(%ebp)
  8003c1:	ff d6                	call   *%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003c3:	83 c4 10             	add    $0x10,%esp
  8003c6:	4b                   	dec    %ebx
  8003c7:	75 f1                	jne    8003ba <printnum+0x71>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003c9:	83 ec 08             	sub    $0x8,%esp
  8003cc:	57                   	push   %edi
  8003cd:	83 ec 04             	sub    $0x4,%esp
  8003d0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003d3:	ff 75 e0             	pushl  -0x20(%ebp)
  8003d6:	ff 75 dc             	pushl  -0x24(%ebp)
  8003d9:	ff 75 d8             	pushl  -0x28(%ebp)
  8003dc:	e8 b7 1a 00 00       	call   801e98 <__umoddi3>
  8003e1:	83 c4 14             	add    $0x14,%esp
  8003e4:	0f be 80 bb 20 80 00 	movsbl 0x8020bb(%eax),%eax
  8003eb:	50                   	push   %eax
  8003ec:	ff d6                	call   *%esi
}
  8003ee:	83 c4 10             	add    $0x10,%esp
  8003f1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003f4:	5b                   	pop    %ebx
  8003f5:	5e                   	pop    %esi
  8003f6:	5f                   	pop    %edi
  8003f7:	5d                   	pop    %ebp
  8003f8:	c3                   	ret    

008003f9 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003f9:	55                   	push   %ebp
  8003fa:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003fc:	83 fa 01             	cmp    $0x1,%edx
  8003ff:	7e 0e                	jle    80040f <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800401:	8b 10                	mov    (%eax),%edx
  800403:	8d 4a 08             	lea    0x8(%edx),%ecx
  800406:	89 08                	mov    %ecx,(%eax)
  800408:	8b 02                	mov    (%edx),%eax
  80040a:	8b 52 04             	mov    0x4(%edx),%edx
  80040d:	eb 22                	jmp    800431 <getuint+0x38>
	else if (lflag)
  80040f:	85 d2                	test   %edx,%edx
  800411:	74 10                	je     800423 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800413:	8b 10                	mov    (%eax),%edx
  800415:	8d 4a 04             	lea    0x4(%edx),%ecx
  800418:	89 08                	mov    %ecx,(%eax)
  80041a:	8b 02                	mov    (%edx),%eax
  80041c:	ba 00 00 00 00       	mov    $0x0,%edx
  800421:	eb 0e                	jmp    800431 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800423:	8b 10                	mov    (%eax),%edx
  800425:	8d 4a 04             	lea    0x4(%edx),%ecx
  800428:	89 08                	mov    %ecx,(%eax)
  80042a:	8b 02                	mov    (%edx),%eax
  80042c:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800431:	5d                   	pop    %ebp
  800432:	c3                   	ret    

00800433 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800433:	55                   	push   %ebp
  800434:	89 e5                	mov    %esp,%ebp
  800436:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800439:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  80043c:	8b 10                	mov    (%eax),%edx
  80043e:	3b 50 04             	cmp    0x4(%eax),%edx
  800441:	73 0a                	jae    80044d <sprintputch+0x1a>
		*b->buf++ = ch;
  800443:	8d 4a 01             	lea    0x1(%edx),%ecx
  800446:	89 08                	mov    %ecx,(%eax)
  800448:	8b 45 08             	mov    0x8(%ebp),%eax
  80044b:	88 02                	mov    %al,(%edx)
}
  80044d:	5d                   	pop    %ebp
  80044e:	c3                   	ret    

0080044f <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80044f:	55                   	push   %ebp
  800450:	89 e5                	mov    %esp,%ebp
  800452:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800455:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800458:	50                   	push   %eax
  800459:	ff 75 10             	pushl  0x10(%ebp)
  80045c:	ff 75 0c             	pushl  0xc(%ebp)
  80045f:	ff 75 08             	pushl  0x8(%ebp)
  800462:	e8 05 00 00 00       	call   80046c <vprintfmt>
	va_end(ap);
}
  800467:	83 c4 10             	add    $0x10,%esp
  80046a:	c9                   	leave  
  80046b:	c3                   	ret    

0080046c <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80046c:	55                   	push   %ebp
  80046d:	89 e5                	mov    %esp,%ebp
  80046f:	57                   	push   %edi
  800470:	56                   	push   %esi
  800471:	53                   	push   %ebx
  800472:	83 ec 2c             	sub    $0x2c,%esp
  800475:	8b 7d 08             	mov    0x8(%ebp),%edi
  800478:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80047b:	eb 03                	jmp    800480 <vprintfmt+0x14>
			break;

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
			for (fmt--; fmt[-1] != '%'; fmt--)
  80047d:	89 75 10             	mov    %esi,0x10(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {    //遍历输入的第一个参数，即输出信息的格式，先把格式字符串中'%'之前的字符一个个输出，因为它们前面没有'%'，所以它们就是要直接显示在屏幕上的
  800480:	8b 45 10             	mov    0x10(%ebp),%eax
  800483:	8d 70 01             	lea    0x1(%eax),%esi
  800486:	0f b6 00             	movzbl (%eax),%eax
  800489:	83 f8 25             	cmp    $0x25,%eax
  80048c:	74 25                	je     8004b3 <vprintfmt+0x47>
			if (ch == '\0')									//当然中间如果遇到'\0'，代表这个字符串的访问结束
  80048e:	85 c0                	test   %eax,%eax
  800490:	75 0d                	jne    80049f <vprintfmt+0x33>
  800492:	e9 b5 03 00 00       	jmp    80084c <vprintfmt+0x3e0>
  800497:	85 c0                	test   %eax,%eax
  800499:	0f 84 ad 03 00 00    	je     80084c <vprintfmt+0x3e0>
				return;
			putch(ch, putdat);								//调用putch函数，把一个字符ch输出到putdat指针所指向的地址中所存放的值对应的地址处
  80049f:	83 ec 08             	sub    $0x8,%esp
  8004a2:	53                   	push   %ebx
  8004a3:	50                   	push   %eax
  8004a4:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {    //遍历输入的第一个参数，即输出信息的格式，先把格式字符串中'%'之前的字符一个个输出，因为它们前面没有'%'，所以它们就是要直接显示在屏幕上的
  8004a6:	46                   	inc    %esi
  8004a7:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  8004ab:	83 c4 10             	add    $0x10,%esp
  8004ae:	83 f8 25             	cmp    $0x25,%eax
  8004b1:	75 e4                	jne    800497 <vprintfmt+0x2b>
			if (width < 0)									//代表有小数点，但是小数点前面并没有数字，比如'%.6f'这种情况，此时代表整数部分全部显示
				width = 0;			
			goto reswitch;

		case '#':
			altflag = 1;
  8004b3:	c6 45 e3 20          	movb   $0x20,-0x1d(%ebp)
  8004b7:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8004be:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8004c5:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8004cc:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8004d3:	eb 07                	jmp    8004dc <vprintfmt+0x70>
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  8004d5:	8b 75 10             	mov    0x10(%ebp),%esi

		// flag to pad on the right
		case '-':											//%后面的'-'代表要进行左对齐输出，右边填空格，如果省略代表右对齐
			padc = '-';										//如果有这个字符代表左对齐，则把对齐方式标志位变为'-'
  8004d8:	c6 45 e3 2d          	movb   $0x2d,-0x1d(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  8004dc:	8d 46 01             	lea    0x1(%esi),%eax
  8004df:	89 45 10             	mov    %eax,0x10(%ebp)
  8004e2:	0f b6 16             	movzbl (%esi),%edx
  8004e5:	8a 06                	mov    (%esi),%al
  8004e7:	83 e8 23             	sub    $0x23,%eax
  8004ea:	3c 55                	cmp    $0x55,%al
  8004ec:	0f 87 03 03 00 00    	ja     8007f5 <vprintfmt+0x389>
  8004f2:	0f b6 c0             	movzbl %al,%eax
  8004f5:	ff 24 85 00 22 80 00 	jmp    *0x802200(,%eax,4)
  8004fc:	8b 75 10             	mov    0x10(%ebp),%esi
			padc = '-';										//如果有这个字符代表左对齐，则把对齐方式标志位变为'-'
			goto reswitch;									//处理下一个字符

		// flag to pad with 0's instead of spaces
		case '0':											//0--有0表示进行对齐输出时填0,如省略表示填入空格，并且如果为0，则一定是右对齐
			padc = '0';										//对其方式标志位变为0
  8004ff:	c6 45 e3 30          	movb   $0x30,-0x1d(%ebp)
  800503:	eb d7                	jmp    8004dc <vprintfmt+0x70>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {					//把遇到的位数字符串转换为真实的位数，比如输入的'%40'，代表有效位数为40位，下面的循环就是把precesion的值设置为40
				precision = precision * 10 + ch - '0';
  800505:	8d 42 d0             	lea    -0x30(%edx),%eax
  800508:	89 c1                	mov    %eax,%ecx
  80050a:	89 45 d0             	mov    %eax,-0x30(%ebp)
				ch = *fmt;
  80050d:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  800511:	8d 50 d0             	lea    -0x30(%eax),%edx
  800514:	83 fa 09             	cmp    $0x9,%edx
  800517:	77 51                	ja     80056a <vprintfmt+0xfe>
  800519:	8b 75 10             	mov    0x10(%ebp),%esi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {					//把遇到的位数字符串转换为真实的位数，比如输入的'%40'，代表有效位数为40位，下面的循环就是把precesion的值设置为40
  80051c:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  80051d:	8d 14 89             	lea    (%ecx,%ecx,4),%edx
  800520:	01 d2                	add    %edx,%edx
  800522:	8d 4c 10 d0          	lea    -0x30(%eax,%edx,1),%ecx
				ch = *fmt;
  800526:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800529:	8d 50 d0             	lea    -0x30(%eax),%edx
  80052c:	83 fa 09             	cmp    $0x9,%edx
  80052f:	76 eb                	jbe    80051c <vprintfmt+0xb0>
  800531:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800534:	eb 37                	jmp    80056d <vprintfmt+0x101>
					break;
			}
			goto process_precision;							//跳转到process_precistion子过程

		case '*':											//*--代表有效数字的位数也是由输入参数指定的，比如printf("%*.*f", 10, 2, n)，其中10,2就是用来指定显示的有效数字位数的
			precision = va_arg(ap, int);
  800536:	8b 45 14             	mov    0x14(%ebp),%eax
  800539:	8d 50 04             	lea    0x4(%eax),%edx
  80053c:	89 55 14             	mov    %edx,0x14(%ebp)
  80053f:	8b 00                	mov    (%eax),%eax
  800541:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  800544:	8b 75 10             	mov    0x10(%ebp),%esi
			}
			goto process_precision;							//跳转到process_precistion子过程

		case '*':											//*--代表有效数字的位数也是由输入参数指定的，比如printf("%*.*f", 10, 2, n)，其中10,2就是用来指定显示的有效数字位数的
			precision = va_arg(ap, int);
			goto process_precision;
  800547:	eb 24                	jmp    80056d <vprintfmt+0x101>
  800549:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80054d:	79 07                	jns    800556 <vprintfmt+0xea>
  80054f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  800556:	8b 75 10             	mov    0x10(%ebp),%esi
  800559:	eb 81                	jmp    8004dc <vprintfmt+0x70>
  80055b:	8b 75 10             	mov    0x10(%ebp),%esi
			if (width < 0)									//代表有小数点，但是小数点前面并没有数字，比如'%.6f'这种情况，此时代表整数部分全部显示
				width = 0;			
			goto reswitch;

		case '#':
			altflag = 1;
  80055e:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800565:	e9 72 ff ff ff       	jmp    8004dc <vprintfmt+0x70>
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  80056a:	8b 75 10             	mov    0x10(%ebp),%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:									//处理输出精度，把width字段赋值为刚刚计算出来的precision值，所以width应该是整数部分的有效数字位数
			if (width < 0)
  80056d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800571:	0f 89 65 ff ff ff    	jns    8004dc <vprintfmt+0x70>
				width = precision, precision = -1;
  800577:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80057a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80057d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800584:	e9 53 ff ff ff       	jmp    8004dc <vprintfmt+0x70>
			goto reswitch;

		// long flag (doubled for long long)				
		case 'l':											//如果遇到'l'，代表应该是输入long类型，如果有两个'l'代表long long
			lflag++;										//此时把lflag++
  800589:	ff 45 d4             	incl   -0x2c(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  80058c:	8b 75 10             	mov    0x10(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)				
		case 'l':											//如果遇到'l'，代表应该是输入long类型，如果有两个'l'代表long long
			lflag++;										//此时把lflag++
			goto reswitch;
  80058f:	e9 48 ff ff ff       	jmp    8004dc <vprintfmt+0x70>

		// character
		case 'c':											//如果是'c'代表显示一个字符
			putch(va_arg(ap, int), putdat);					//调用输出一个字符到内存的函数putch
  800594:	8b 45 14             	mov    0x14(%ebp),%eax
  800597:	8d 50 04             	lea    0x4(%eax),%edx
  80059a:	89 55 14             	mov    %edx,0x14(%ebp)
  80059d:	83 ec 08             	sub    $0x8,%esp
  8005a0:	53                   	push   %ebx
  8005a1:	ff 30                	pushl  (%eax)
  8005a3:	ff d7                	call   *%edi
			break;
  8005a5:	83 c4 10             	add    $0x10,%esp
  8005a8:	e9 d3 fe ff ff       	jmp    800480 <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8005ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b0:	8d 50 04             	lea    0x4(%eax),%edx
  8005b3:	89 55 14             	mov    %edx,0x14(%ebp)
  8005b6:	8b 00                	mov    (%eax),%eax
  8005b8:	85 c0                	test   %eax,%eax
  8005ba:	79 02                	jns    8005be <vprintfmt+0x152>
  8005bc:	f7 d8                	neg    %eax
  8005be:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005c0:	83 f8 0f             	cmp    $0xf,%eax
  8005c3:	7f 0b                	jg     8005d0 <vprintfmt+0x164>
  8005c5:	8b 04 85 60 23 80 00 	mov    0x802360(,%eax,4),%eax
  8005cc:	85 c0                	test   %eax,%eax
  8005ce:	75 15                	jne    8005e5 <vprintfmt+0x179>
				printfmt(putch, putdat, "error %d", err);
  8005d0:	52                   	push   %edx
  8005d1:	68 d3 20 80 00       	push   $0x8020d3
  8005d6:	53                   	push   %ebx
  8005d7:	57                   	push   %edi
  8005d8:	e8 72 fe ff ff       	call   80044f <printfmt>
  8005dd:	83 c4 10             	add    $0x10,%esp
  8005e0:	e9 9b fe ff ff       	jmp    800480 <vprintfmt+0x14>
			else
				printfmt(putch, putdat, "%s", p);
  8005e5:	50                   	push   %eax
  8005e6:	68 82 24 80 00       	push   $0x802482
  8005eb:	53                   	push   %ebx
  8005ec:	57                   	push   %edi
  8005ed:	e8 5d fe ff ff       	call   80044f <printfmt>
  8005f2:	83 c4 10             	add    $0x10,%esp
  8005f5:	e9 86 fe ff ff       	jmp    800480 <vprintfmt+0x14>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fd:	8d 50 04             	lea    0x4(%eax),%edx
  800600:	89 55 14             	mov    %edx,0x14(%ebp)
  800603:	8b 00                	mov    (%eax),%eax
  800605:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800608:	85 c0                	test   %eax,%eax
  80060a:	75 07                	jne    800613 <vprintfmt+0x1a7>
				p = "(null)";
  80060c:	c7 45 d4 cc 20 80 00 	movl   $0x8020cc,-0x2c(%ebp)
			if (width > 0 && padc != '-')
  800613:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800616:	85 f6                	test   %esi,%esi
  800618:	0f 8e fb 01 00 00    	jle    800819 <vprintfmt+0x3ad>
  80061e:	80 7d e3 2d          	cmpb   $0x2d,-0x1d(%ebp)
  800622:	0f 84 09 02 00 00    	je     800831 <vprintfmt+0x3c5>
				for (width -= strnlen(p, precision); width > 0; width--)
  800628:	83 ec 08             	sub    $0x8,%esp
  80062b:	ff 75 d0             	pushl  -0x30(%ebp)
  80062e:	ff 75 d4             	pushl  -0x2c(%ebp)
  800631:	e8 ad 02 00 00       	call   8008e3 <strnlen>
  800636:	89 f1                	mov    %esi,%ecx
  800638:	29 c1                	sub    %eax,%ecx
  80063a:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  80063d:	83 c4 10             	add    $0x10,%esp
  800640:	85 c9                	test   %ecx,%ecx
  800642:	0f 8e d1 01 00 00    	jle    800819 <vprintfmt+0x3ad>
					putch(padc, putdat);
  800648:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  80064c:	83 ec 08             	sub    $0x8,%esp
  80064f:	53                   	push   %ebx
  800650:	56                   	push   %esi
  800651:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800653:	83 c4 10             	add    $0x10,%esp
  800656:	ff 4d e4             	decl   -0x1c(%ebp)
  800659:	75 f1                	jne    80064c <vprintfmt+0x1e0>
  80065b:	e9 b9 01 00 00       	jmp    800819 <vprintfmt+0x3ad>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800660:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800664:	74 19                	je     80067f <vprintfmt+0x213>
  800666:	0f be c0             	movsbl %al,%eax
  800669:	83 e8 20             	sub    $0x20,%eax
  80066c:	83 f8 5e             	cmp    $0x5e,%eax
  80066f:	76 0e                	jbe    80067f <vprintfmt+0x213>
					putch('?', putdat);
  800671:	83 ec 08             	sub    $0x8,%esp
  800674:	53                   	push   %ebx
  800675:	6a 3f                	push   $0x3f
  800677:	ff 55 08             	call   *0x8(%ebp)
  80067a:	83 c4 10             	add    $0x10,%esp
  80067d:	eb 0b                	jmp    80068a <vprintfmt+0x21e>
				else
					putch(ch, putdat);
  80067f:	83 ec 08             	sub    $0x8,%esp
  800682:	53                   	push   %ebx
  800683:	52                   	push   %edx
  800684:	ff 55 08             	call   *0x8(%ebp)
  800687:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80068a:	ff 4d e4             	decl   -0x1c(%ebp)
  80068d:	46                   	inc    %esi
  80068e:	8a 46 ff             	mov    -0x1(%esi),%al
  800691:	0f be d0             	movsbl %al,%edx
  800694:	85 d2                	test   %edx,%edx
  800696:	75 1c                	jne    8006b4 <vprintfmt+0x248>
  800698:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80069b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80069f:	7f 1f                	jg     8006c0 <vprintfmt+0x254>
  8006a1:	e9 da fd ff ff       	jmp    800480 <vprintfmt+0x14>
  8006a6:	89 7d 08             	mov    %edi,0x8(%ebp)
  8006a9:	8b 7d d0             	mov    -0x30(%ebp),%edi
  8006ac:	eb 06                	jmp    8006b4 <vprintfmt+0x248>
  8006ae:	89 7d 08             	mov    %edi,0x8(%ebp)
  8006b1:	8b 7d d0             	mov    -0x30(%ebp),%edi
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006b4:	85 ff                	test   %edi,%edi
  8006b6:	78 a8                	js     800660 <vprintfmt+0x1f4>
  8006b8:	4f                   	dec    %edi
  8006b9:	79 a5                	jns    800660 <vprintfmt+0x1f4>
  8006bb:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006be:	eb db                	jmp    80069b <vprintfmt+0x22f>
  8006c0:	8b 75 e4             	mov    -0x1c(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006c3:	83 ec 08             	sub    $0x8,%esp
  8006c6:	53                   	push   %ebx
  8006c7:	6a 20                	push   $0x20
  8006c9:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006cb:	4e                   	dec    %esi
  8006cc:	83 c4 10             	add    $0x10,%esp
  8006cf:	85 f6                	test   %esi,%esi
  8006d1:	7f f0                	jg     8006c3 <vprintfmt+0x257>
  8006d3:	e9 a8 fd ff ff       	jmp    800480 <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006d8:	83 7d d4 01          	cmpl   $0x1,-0x2c(%ebp)
  8006dc:	7e 16                	jle    8006f4 <vprintfmt+0x288>
		return va_arg(*ap, long long);
  8006de:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e1:	8d 50 08             	lea    0x8(%eax),%edx
  8006e4:	89 55 14             	mov    %edx,0x14(%ebp)
  8006e7:	8b 50 04             	mov    0x4(%eax),%edx
  8006ea:	8b 00                	mov    (%eax),%eax
  8006ec:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006ef:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006f2:	eb 34                	jmp    800728 <vprintfmt+0x2bc>
	else if (lflag)
  8006f4:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8006f8:	74 18                	je     800712 <vprintfmt+0x2a6>
		return va_arg(*ap, long);
  8006fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8006fd:	8d 50 04             	lea    0x4(%eax),%edx
  800700:	89 55 14             	mov    %edx,0x14(%ebp)
  800703:	8b 30                	mov    (%eax),%esi
  800705:	89 75 d8             	mov    %esi,-0x28(%ebp)
  800708:	89 f0                	mov    %esi,%eax
  80070a:	c1 f8 1f             	sar    $0x1f,%eax
  80070d:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800710:	eb 16                	jmp    800728 <vprintfmt+0x2bc>
	else
		return va_arg(*ap, int);
  800712:	8b 45 14             	mov    0x14(%ebp),%eax
  800715:	8d 50 04             	lea    0x4(%eax),%edx
  800718:	89 55 14             	mov    %edx,0x14(%ebp)
  80071b:	8b 30                	mov    (%eax),%esi
  80071d:	89 75 d8             	mov    %esi,-0x28(%ebp)
  800720:	89 f0                	mov    %esi,%eax
  800722:	c1 f8 1f             	sar    $0x1f,%eax
  800725:	89 45 dc             	mov    %eax,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800728:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80072b:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
  80072e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800732:	0f 89 8a 00 00 00    	jns    8007c2 <vprintfmt+0x356>
				putch('-', putdat);
  800738:	83 ec 08             	sub    $0x8,%esp
  80073b:	53                   	push   %ebx
  80073c:	6a 2d                	push   $0x2d
  80073e:	ff d7                	call   *%edi
				num = -(long long) num;
  800740:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800743:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800746:	f7 d8                	neg    %eax
  800748:	83 d2 00             	adc    $0x0,%edx
  80074b:	f7 da                	neg    %edx
  80074d:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800750:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800755:	eb 70                	jmp    8007c7 <vprintfmt+0x35b>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800757:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80075a:	8d 45 14             	lea    0x14(%ebp),%eax
  80075d:	e8 97 fc ff ff       	call   8003f9 <getuint>
			base = 10;
  800762:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800767:	eb 5e                	jmp    8007c7 <vprintfmt+0x35b>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
  800769:	83 ec 08             	sub    $0x8,%esp
  80076c:	53                   	push   %ebx
  80076d:	6a 30                	push   $0x30
  80076f:	ff d7                	call   *%edi
			num = getuint(&ap, lflag);
  800771:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800774:	8d 45 14             	lea    0x14(%ebp),%eax
  800777:	e8 7d fc ff ff       	call   8003f9 <getuint>
			base = 8;
			goto number;
  80077c:	83 c4 10             	add    $0x10,%esp
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  80077f:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800784:	eb 41                	jmp    8007c7 <vprintfmt+0x35b>
		// pointer
		case 'p':
			putch('0', putdat);
  800786:	83 ec 08             	sub    $0x8,%esp
  800789:	53                   	push   %ebx
  80078a:	6a 30                	push   $0x30
  80078c:	ff d7                	call   *%edi
			putch('x', putdat);
  80078e:	83 c4 08             	add    $0x8,%esp
  800791:	53                   	push   %ebx
  800792:	6a 78                	push   $0x78
  800794:	ff d7                	call   *%edi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800796:	8b 45 14             	mov    0x14(%ebp),%eax
  800799:	8d 50 04             	lea    0x4(%eax),%edx
  80079c:	89 55 14             	mov    %edx,0x14(%ebp)
			goto number;
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80079f:	8b 00                	mov    (%eax),%eax
  8007a1:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8007a6:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8007a9:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8007ae:	eb 17                	jmp    8007c7 <vprintfmt+0x35b>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8007b0:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8007b3:	8d 45 14             	lea    0x14(%ebp),%eax
  8007b6:	e8 3e fc ff ff       	call   8003f9 <getuint>
			base = 16;
  8007bb:	b9 10 00 00 00       	mov    $0x10,%ecx
  8007c0:	eb 05                	jmp    8007c7 <vprintfmt+0x35b>
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8007c2:	b9 0a 00 00 00       	mov    $0xa,%ecx
		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007c7:	83 ec 0c             	sub    $0xc,%esp
  8007ca:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  8007ce:	56                   	push   %esi
  8007cf:	ff 75 e4             	pushl  -0x1c(%ebp)
  8007d2:	51                   	push   %ecx
  8007d3:	52                   	push   %edx
  8007d4:	50                   	push   %eax
  8007d5:	89 da                	mov    %ebx,%edx
  8007d7:	89 f8                	mov    %edi,%eax
  8007d9:	e8 6b fb ff ff       	call   800349 <printnum>
			break;
  8007de:	83 c4 20             	add    $0x20,%esp
  8007e1:	e9 9a fc ff ff       	jmp    800480 <vprintfmt+0x14>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007e6:	83 ec 08             	sub    $0x8,%esp
  8007e9:	53                   	push   %ebx
  8007ea:	52                   	push   %edx
  8007eb:	ff d7                	call   *%edi
			break;
  8007ed:	83 c4 10             	add    $0x10,%esp
  8007f0:	e9 8b fc ff ff       	jmp    800480 <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007f5:	83 ec 08             	sub    $0x8,%esp
  8007f8:	53                   	push   %ebx
  8007f9:	6a 25                	push   $0x25
  8007fb:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007fd:	83 c4 10             	add    $0x10,%esp
  800800:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800804:	0f 84 73 fc ff ff    	je     80047d <vprintfmt+0x11>
  80080a:	4e                   	dec    %esi
  80080b:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80080f:	75 f9                	jne    80080a <vprintfmt+0x39e>
  800811:	89 75 10             	mov    %esi,0x10(%ebp)
  800814:	e9 67 fc ff ff       	jmp    800480 <vprintfmt+0x14>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800819:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80081c:	8d 70 01             	lea    0x1(%eax),%esi
  80081f:	8a 00                	mov    (%eax),%al
  800821:	0f be d0             	movsbl %al,%edx
  800824:	85 d2                	test   %edx,%edx
  800826:	0f 85 7a fe ff ff    	jne    8006a6 <vprintfmt+0x23a>
  80082c:	e9 4f fc ff ff       	jmp    800480 <vprintfmt+0x14>
  800831:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800834:	8d 70 01             	lea    0x1(%eax),%esi
  800837:	8a 00                	mov    (%eax),%al
  800839:	0f be d0             	movsbl %al,%edx
  80083c:	85 d2                	test   %edx,%edx
  80083e:	0f 85 6a fe ff ff    	jne    8006ae <vprintfmt+0x242>
  800844:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800847:	e9 77 fe ff ff       	jmp    8006c3 <vprintfmt+0x257>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  80084c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80084f:	5b                   	pop    %ebx
  800850:	5e                   	pop    %esi
  800851:	5f                   	pop    %edi
  800852:	5d                   	pop    %ebp
  800853:	c3                   	ret    

00800854 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800854:	55                   	push   %ebp
  800855:	89 e5                	mov    %esp,%ebp
  800857:	83 ec 18             	sub    $0x18,%esp
  80085a:	8b 45 08             	mov    0x8(%ebp),%eax
  80085d:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800860:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800863:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800867:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80086a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800871:	85 c0                	test   %eax,%eax
  800873:	74 26                	je     80089b <vsnprintf+0x47>
  800875:	85 d2                	test   %edx,%edx
  800877:	7e 29                	jle    8008a2 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800879:	ff 75 14             	pushl  0x14(%ebp)
  80087c:	ff 75 10             	pushl  0x10(%ebp)
  80087f:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800882:	50                   	push   %eax
  800883:	68 33 04 80 00       	push   $0x800433
  800888:	e8 df fb ff ff       	call   80046c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80088d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800890:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800893:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800896:	83 c4 10             	add    $0x10,%esp
  800899:	eb 0c                	jmp    8008a7 <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80089b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008a0:	eb 05                	jmp    8008a7 <vsnprintf+0x53>
  8008a2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8008a7:	c9                   	leave  
  8008a8:	c3                   	ret    

008008a9 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008a9:	55                   	push   %ebp
  8008aa:	89 e5                	mov    %esp,%ebp
  8008ac:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008af:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008b2:	50                   	push   %eax
  8008b3:	ff 75 10             	pushl  0x10(%ebp)
  8008b6:	ff 75 0c             	pushl  0xc(%ebp)
  8008b9:	ff 75 08             	pushl  0x8(%ebp)
  8008bc:	e8 93 ff ff ff       	call   800854 <vsnprintf>
	va_end(ap);

	return rc;
}
  8008c1:	c9                   	leave  
  8008c2:	c3                   	ret    

008008c3 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008c3:	55                   	push   %ebp
  8008c4:	89 e5                	mov    %esp,%ebp
  8008c6:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008c9:	80 3a 00             	cmpb   $0x0,(%edx)
  8008cc:	74 0e                	je     8008dc <strlen+0x19>
  8008ce:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8008d3:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8008d4:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008d8:	75 f9                	jne    8008d3 <strlen+0x10>
  8008da:	eb 05                	jmp    8008e1 <strlen+0x1e>
  8008dc:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8008e1:	5d                   	pop    %ebp
  8008e2:	c3                   	ret    

008008e3 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008e3:	55                   	push   %ebp
  8008e4:	89 e5                	mov    %esp,%ebp
  8008e6:	53                   	push   %ebx
  8008e7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8008ea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008ed:	85 c9                	test   %ecx,%ecx
  8008ef:	74 1a                	je     80090b <strnlen+0x28>
  8008f1:	80 3b 00             	cmpb   $0x0,(%ebx)
  8008f4:	74 1c                	je     800912 <strnlen+0x2f>
  8008f6:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  8008fb:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008fd:	39 ca                	cmp    %ecx,%edx
  8008ff:	74 16                	je     800917 <strnlen+0x34>
  800901:	42                   	inc    %edx
  800902:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800907:	75 f2                	jne    8008fb <strnlen+0x18>
  800909:	eb 0c                	jmp    800917 <strnlen+0x34>
  80090b:	b8 00 00 00 00       	mov    $0x0,%eax
  800910:	eb 05                	jmp    800917 <strnlen+0x34>
  800912:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800917:	5b                   	pop    %ebx
  800918:	5d                   	pop    %ebp
  800919:	c3                   	ret    

0080091a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80091a:	55                   	push   %ebp
  80091b:	89 e5                	mov    %esp,%ebp
  80091d:	53                   	push   %ebx
  80091e:	8b 45 08             	mov    0x8(%ebp),%eax
  800921:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800924:	89 c2                	mov    %eax,%edx
  800926:	42                   	inc    %edx
  800927:	41                   	inc    %ecx
  800928:	8a 59 ff             	mov    -0x1(%ecx),%bl
  80092b:	88 5a ff             	mov    %bl,-0x1(%edx)
  80092e:	84 db                	test   %bl,%bl
  800930:	75 f4                	jne    800926 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800932:	5b                   	pop    %ebx
  800933:	5d                   	pop    %ebp
  800934:	c3                   	ret    

00800935 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800935:	55                   	push   %ebp
  800936:	89 e5                	mov    %esp,%ebp
  800938:	53                   	push   %ebx
  800939:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80093c:	53                   	push   %ebx
  80093d:	e8 81 ff ff ff       	call   8008c3 <strlen>
  800942:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800945:	ff 75 0c             	pushl  0xc(%ebp)
  800948:	01 d8                	add    %ebx,%eax
  80094a:	50                   	push   %eax
  80094b:	e8 ca ff ff ff       	call   80091a <strcpy>
	return dst;
}
  800950:	89 d8                	mov    %ebx,%eax
  800952:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800955:	c9                   	leave  
  800956:	c3                   	ret    

00800957 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800957:	55                   	push   %ebp
  800958:	89 e5                	mov    %esp,%ebp
  80095a:	56                   	push   %esi
  80095b:	53                   	push   %ebx
  80095c:	8b 75 08             	mov    0x8(%ebp),%esi
  80095f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800962:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800965:	85 db                	test   %ebx,%ebx
  800967:	74 14                	je     80097d <strncpy+0x26>
  800969:	01 f3                	add    %esi,%ebx
  80096b:	89 f1                	mov    %esi,%ecx
		*dst++ = *src;
  80096d:	41                   	inc    %ecx
  80096e:	8a 02                	mov    (%edx),%al
  800970:	88 41 ff             	mov    %al,-0x1(%ecx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800973:	80 3a 01             	cmpb   $0x1,(%edx)
  800976:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800979:	39 cb                	cmp    %ecx,%ebx
  80097b:	75 f0                	jne    80096d <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80097d:	89 f0                	mov    %esi,%eax
  80097f:	5b                   	pop    %ebx
  800980:	5e                   	pop    %esi
  800981:	5d                   	pop    %ebp
  800982:	c3                   	ret    

00800983 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800983:	55                   	push   %ebp
  800984:	89 e5                	mov    %esp,%ebp
  800986:	53                   	push   %ebx
  800987:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80098a:	8b 45 10             	mov    0x10(%ebp),%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80098d:	85 c0                	test   %eax,%eax
  80098f:	74 30                	je     8009c1 <strlcpy+0x3e>
		while (--size > 0 && *src != '\0')
  800991:	48                   	dec    %eax
  800992:	74 20                	je     8009b4 <strlcpy+0x31>
  800994:	8a 0b                	mov    (%ebx),%cl
  800996:	84 c9                	test   %cl,%cl
  800998:	74 1f                	je     8009b9 <strlcpy+0x36>
  80099a:	8d 53 01             	lea    0x1(%ebx),%edx
  80099d:	01 c3                	add    %eax,%ebx
  80099f:	8b 45 08             	mov    0x8(%ebp),%eax
			*dst++ = *src++;
  8009a2:	40                   	inc    %eax
  8009a3:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8009a6:	39 da                	cmp    %ebx,%edx
  8009a8:	74 12                	je     8009bc <strlcpy+0x39>
  8009aa:	42                   	inc    %edx
  8009ab:	8a 4a ff             	mov    -0x1(%edx),%cl
  8009ae:	84 c9                	test   %cl,%cl
  8009b0:	75 f0                	jne    8009a2 <strlcpy+0x1f>
  8009b2:	eb 08                	jmp    8009bc <strlcpy+0x39>
  8009b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b7:	eb 03                	jmp    8009bc <strlcpy+0x39>
  8009b9:	8b 45 08             	mov    0x8(%ebp),%eax
			*dst++ = *src++;
		*dst = '\0';
  8009bc:	c6 00 00             	movb   $0x0,(%eax)
  8009bf:	eb 03                	jmp    8009c4 <strlcpy+0x41>
  8009c1:	8b 45 08             	mov    0x8(%ebp),%eax
	}
	return dst - dst_in;
  8009c4:	2b 45 08             	sub    0x8(%ebp),%eax
}
  8009c7:	5b                   	pop    %ebx
  8009c8:	5d                   	pop    %ebp
  8009c9:	c3                   	ret    

008009ca <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009ca:	55                   	push   %ebp
  8009cb:	89 e5                	mov    %esp,%ebp
  8009cd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009d0:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009d3:	8a 01                	mov    (%ecx),%al
  8009d5:	84 c0                	test   %al,%al
  8009d7:	74 10                	je     8009e9 <strcmp+0x1f>
  8009d9:	3a 02                	cmp    (%edx),%al
  8009db:	75 0c                	jne    8009e9 <strcmp+0x1f>
		p++, q++;
  8009dd:	41                   	inc    %ecx
  8009de:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8009df:	8a 01                	mov    (%ecx),%al
  8009e1:	84 c0                	test   %al,%al
  8009e3:	74 04                	je     8009e9 <strcmp+0x1f>
  8009e5:	3a 02                	cmp    (%edx),%al
  8009e7:	74 f4                	je     8009dd <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009e9:	0f b6 c0             	movzbl %al,%eax
  8009ec:	0f b6 12             	movzbl (%edx),%edx
  8009ef:	29 d0                	sub    %edx,%eax
}
  8009f1:	5d                   	pop    %ebp
  8009f2:	c3                   	ret    

008009f3 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009f3:	55                   	push   %ebp
  8009f4:	89 e5                	mov    %esp,%ebp
  8009f6:	56                   	push   %esi
  8009f7:	53                   	push   %ebx
  8009f8:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8009fb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009fe:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  800a01:	85 f6                	test   %esi,%esi
  800a03:	74 23                	je     800a28 <strncmp+0x35>
  800a05:	8a 03                	mov    (%ebx),%al
  800a07:	84 c0                	test   %al,%al
  800a09:	74 2b                	je     800a36 <strncmp+0x43>
  800a0b:	3a 02                	cmp    (%edx),%al
  800a0d:	75 27                	jne    800a36 <strncmp+0x43>
  800a0f:	8d 43 01             	lea    0x1(%ebx),%eax
  800a12:	01 de                	add    %ebx,%esi
		n--, p++, q++;
  800a14:	89 c3                	mov    %eax,%ebx
  800a16:	42                   	inc    %edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a17:	39 c6                	cmp    %eax,%esi
  800a19:	74 14                	je     800a2f <strncmp+0x3c>
  800a1b:	8a 08                	mov    (%eax),%cl
  800a1d:	84 c9                	test   %cl,%cl
  800a1f:	74 15                	je     800a36 <strncmp+0x43>
  800a21:	40                   	inc    %eax
  800a22:	3a 0a                	cmp    (%edx),%cl
  800a24:	74 ee                	je     800a14 <strncmp+0x21>
  800a26:	eb 0e                	jmp    800a36 <strncmp+0x43>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a28:	b8 00 00 00 00       	mov    $0x0,%eax
  800a2d:	eb 0f                	jmp    800a3e <strncmp+0x4b>
  800a2f:	b8 00 00 00 00       	mov    $0x0,%eax
  800a34:	eb 08                	jmp    800a3e <strncmp+0x4b>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a36:	0f b6 03             	movzbl (%ebx),%eax
  800a39:	0f b6 12             	movzbl (%edx),%edx
  800a3c:	29 d0                	sub    %edx,%eax
}
  800a3e:	5b                   	pop    %ebx
  800a3f:	5e                   	pop    %esi
  800a40:	5d                   	pop    %ebp
  800a41:	c3                   	ret    

00800a42 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a42:	55                   	push   %ebp
  800a43:	89 e5                	mov    %esp,%ebp
  800a45:	53                   	push   %ebx
  800a46:	8b 45 08             	mov    0x8(%ebp),%eax
  800a49:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  800a4c:	8a 10                	mov    (%eax),%dl
  800a4e:	84 d2                	test   %dl,%dl
  800a50:	74 1a                	je     800a6c <strchr+0x2a>
  800a52:	88 d9                	mov    %bl,%cl
		if (*s == c)
  800a54:	38 d3                	cmp    %dl,%bl
  800a56:	75 06                	jne    800a5e <strchr+0x1c>
  800a58:	eb 17                	jmp    800a71 <strchr+0x2f>
  800a5a:	38 ca                	cmp    %cl,%dl
  800a5c:	74 13                	je     800a71 <strchr+0x2f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a5e:	40                   	inc    %eax
  800a5f:	8a 10                	mov    (%eax),%dl
  800a61:	84 d2                	test   %dl,%dl
  800a63:	75 f5                	jne    800a5a <strchr+0x18>
		if (*s == c)
			return (char *) s;
	return 0;
  800a65:	b8 00 00 00 00       	mov    $0x0,%eax
  800a6a:	eb 05                	jmp    800a71 <strchr+0x2f>
  800a6c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a71:	5b                   	pop    %ebx
  800a72:	5d                   	pop    %ebp
  800a73:	c3                   	ret    

00800a74 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a74:	55                   	push   %ebp
  800a75:	89 e5                	mov    %esp,%ebp
  800a77:	53                   	push   %ebx
  800a78:	8b 45 08             	mov    0x8(%ebp),%eax
  800a7b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  800a7e:	8a 10                	mov    (%eax),%dl
  800a80:	84 d2                	test   %dl,%dl
  800a82:	74 13                	je     800a97 <strfind+0x23>
  800a84:	88 d9                	mov    %bl,%cl
		if (*s == c)
  800a86:	38 d3                	cmp    %dl,%bl
  800a88:	75 06                	jne    800a90 <strfind+0x1c>
  800a8a:	eb 0b                	jmp    800a97 <strfind+0x23>
  800a8c:	38 ca                	cmp    %cl,%dl
  800a8e:	74 07                	je     800a97 <strfind+0x23>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a90:	40                   	inc    %eax
  800a91:	8a 10                	mov    (%eax),%dl
  800a93:	84 d2                	test   %dl,%dl
  800a95:	75 f5                	jne    800a8c <strfind+0x18>
		if (*s == c)
			break;
	return (char *) s;
}
  800a97:	5b                   	pop    %ebx
  800a98:	5d                   	pop    %ebp
  800a99:	c3                   	ret    

00800a9a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a9a:	55                   	push   %ebp
  800a9b:	89 e5                	mov    %esp,%ebp
  800a9d:	57                   	push   %edi
  800a9e:	56                   	push   %esi
  800a9f:	53                   	push   %ebx
  800aa0:	8b 7d 08             	mov    0x8(%ebp),%edi
  800aa3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800aa6:	85 c9                	test   %ecx,%ecx
  800aa8:	74 36                	je     800ae0 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800aaa:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800ab0:	75 28                	jne    800ada <memset+0x40>
  800ab2:	f6 c1 03             	test   $0x3,%cl
  800ab5:	75 23                	jne    800ada <memset+0x40>
		c &= 0xFF;
  800ab7:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800abb:	89 d3                	mov    %edx,%ebx
  800abd:	c1 e3 08             	shl    $0x8,%ebx
  800ac0:	89 d6                	mov    %edx,%esi
  800ac2:	c1 e6 18             	shl    $0x18,%esi
  800ac5:	89 d0                	mov    %edx,%eax
  800ac7:	c1 e0 10             	shl    $0x10,%eax
  800aca:	09 f0                	or     %esi,%eax
  800acc:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800ace:	89 d8                	mov    %ebx,%eax
  800ad0:	09 d0                	or     %edx,%eax
  800ad2:	c1 e9 02             	shr    $0x2,%ecx
  800ad5:	fc                   	cld    
  800ad6:	f3 ab                	rep stos %eax,%es:(%edi)
  800ad8:	eb 06                	jmp    800ae0 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ada:	8b 45 0c             	mov    0xc(%ebp),%eax
  800add:	fc                   	cld    
  800ade:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800ae0:	89 f8                	mov    %edi,%eax
  800ae2:	5b                   	pop    %ebx
  800ae3:	5e                   	pop    %esi
  800ae4:	5f                   	pop    %edi
  800ae5:	5d                   	pop    %ebp
  800ae6:	c3                   	ret    

00800ae7 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ae7:	55                   	push   %ebp
  800ae8:	89 e5                	mov    %esp,%ebp
  800aea:	57                   	push   %edi
  800aeb:	56                   	push   %esi
  800aec:	8b 45 08             	mov    0x8(%ebp),%eax
  800aef:	8b 75 0c             	mov    0xc(%ebp),%esi
  800af2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800af5:	39 c6                	cmp    %eax,%esi
  800af7:	73 33                	jae    800b2c <memmove+0x45>
  800af9:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800afc:	39 d0                	cmp    %edx,%eax
  800afe:	73 2c                	jae    800b2c <memmove+0x45>
		s += n;
		d += n;
  800b00:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b03:	89 d6                	mov    %edx,%esi
  800b05:	09 fe                	or     %edi,%esi
  800b07:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b0d:	75 13                	jne    800b22 <memmove+0x3b>
  800b0f:	f6 c1 03             	test   $0x3,%cl
  800b12:	75 0e                	jne    800b22 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800b14:	83 ef 04             	sub    $0x4,%edi
  800b17:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b1a:	c1 e9 02             	shr    $0x2,%ecx
  800b1d:	fd                   	std    
  800b1e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b20:	eb 07                	jmp    800b29 <memmove+0x42>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b22:	4f                   	dec    %edi
  800b23:	8d 72 ff             	lea    -0x1(%edx),%esi
  800b26:	fd                   	std    
  800b27:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b29:	fc                   	cld    
  800b2a:	eb 1d                	jmp    800b49 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b2c:	89 f2                	mov    %esi,%edx
  800b2e:	09 c2                	or     %eax,%edx
  800b30:	f6 c2 03             	test   $0x3,%dl
  800b33:	75 0f                	jne    800b44 <memmove+0x5d>
  800b35:	f6 c1 03             	test   $0x3,%cl
  800b38:	75 0a                	jne    800b44 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
  800b3a:	c1 e9 02             	shr    $0x2,%ecx
  800b3d:	89 c7                	mov    %eax,%edi
  800b3f:	fc                   	cld    
  800b40:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b42:	eb 05                	jmp    800b49 <memmove+0x62>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b44:	89 c7                	mov    %eax,%edi
  800b46:	fc                   	cld    
  800b47:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b49:	5e                   	pop    %esi
  800b4a:	5f                   	pop    %edi
  800b4b:	5d                   	pop    %ebp
  800b4c:	c3                   	ret    

00800b4d <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b4d:	55                   	push   %ebp
  800b4e:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b50:	ff 75 10             	pushl  0x10(%ebp)
  800b53:	ff 75 0c             	pushl  0xc(%ebp)
  800b56:	ff 75 08             	pushl  0x8(%ebp)
  800b59:	e8 89 ff ff ff       	call   800ae7 <memmove>
}
  800b5e:	c9                   	leave  
  800b5f:	c3                   	ret    

00800b60 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b60:	55                   	push   %ebp
  800b61:	89 e5                	mov    %esp,%ebp
  800b63:	57                   	push   %edi
  800b64:	56                   	push   %esi
  800b65:	53                   	push   %ebx
  800b66:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800b69:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b6c:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b6f:	85 c0                	test   %eax,%eax
  800b71:	74 33                	je     800ba6 <memcmp+0x46>
  800b73:	8d 78 ff             	lea    -0x1(%eax),%edi
		if (*s1 != *s2)
  800b76:	8a 13                	mov    (%ebx),%dl
  800b78:	8a 0e                	mov    (%esi),%cl
  800b7a:	38 ca                	cmp    %cl,%dl
  800b7c:	75 13                	jne    800b91 <memcmp+0x31>
  800b7e:	b8 00 00 00 00       	mov    $0x0,%eax
  800b83:	eb 16                	jmp    800b9b <memcmp+0x3b>
  800b85:	8a 54 03 01          	mov    0x1(%ebx,%eax,1),%dl
  800b89:	40                   	inc    %eax
  800b8a:	8a 0c 06             	mov    (%esi,%eax,1),%cl
  800b8d:	38 ca                	cmp    %cl,%dl
  800b8f:	74 0a                	je     800b9b <memcmp+0x3b>
			return (int) *s1 - (int) *s2;
  800b91:	0f b6 c2             	movzbl %dl,%eax
  800b94:	0f b6 c9             	movzbl %cl,%ecx
  800b97:	29 c8                	sub    %ecx,%eax
  800b99:	eb 10                	jmp    800bab <memcmp+0x4b>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b9b:	39 f8                	cmp    %edi,%eax
  800b9d:	75 e6                	jne    800b85 <memcmp+0x25>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b9f:	b8 00 00 00 00       	mov    $0x0,%eax
  800ba4:	eb 05                	jmp    800bab <memcmp+0x4b>
  800ba6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bab:	5b                   	pop    %ebx
  800bac:	5e                   	pop    %esi
  800bad:	5f                   	pop    %edi
  800bae:	5d                   	pop    %ebp
  800baf:	c3                   	ret    

00800bb0 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800bb0:	55                   	push   %ebp
  800bb1:	89 e5                	mov    %esp,%ebp
  800bb3:	53                   	push   %ebx
  800bb4:	8b 55 08             	mov    0x8(%ebp),%edx
	const void *ends = (const char *) s + n;
  800bb7:	89 d0                	mov    %edx,%eax
  800bb9:	03 45 10             	add    0x10(%ebp),%eax
	for (; s < ends; s++)
  800bbc:	39 c2                	cmp    %eax,%edx
  800bbe:	73 1b                	jae    800bdb <memfind+0x2b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800bc0:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
  800bc4:	0f b6 0a             	movzbl (%edx),%ecx
  800bc7:	39 d9                	cmp    %ebx,%ecx
  800bc9:	75 09                	jne    800bd4 <memfind+0x24>
  800bcb:	eb 12                	jmp    800bdf <memfind+0x2f>
  800bcd:	0f b6 0a             	movzbl (%edx),%ecx
  800bd0:	39 d9                	cmp    %ebx,%ecx
  800bd2:	74 0f                	je     800be3 <memfind+0x33>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bd4:	42                   	inc    %edx
  800bd5:	39 d0                	cmp    %edx,%eax
  800bd7:	75 f4                	jne    800bcd <memfind+0x1d>
  800bd9:	eb 0a                	jmp    800be5 <memfind+0x35>
  800bdb:	89 d0                	mov    %edx,%eax
  800bdd:	eb 06                	jmp    800be5 <memfind+0x35>
		if (*(const unsigned char *) s == (unsigned char) c)
  800bdf:	89 d0                	mov    %edx,%eax
  800be1:	eb 02                	jmp    800be5 <memfind+0x35>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800be3:	89 d0                	mov    %edx,%eax
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800be5:	5b                   	pop    %ebx
  800be6:	5d                   	pop    %ebp
  800be7:	c3                   	ret    

00800be8 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800be8:	55                   	push   %ebp
  800be9:	89 e5                	mov    %esp,%ebp
  800beb:	57                   	push   %edi
  800bec:	56                   	push   %esi
  800bed:	53                   	push   %ebx
  800bee:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bf1:	eb 01                	jmp    800bf4 <strtol+0xc>
		s++;
  800bf3:	41                   	inc    %ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bf4:	8a 01                	mov    (%ecx),%al
  800bf6:	3c 20                	cmp    $0x20,%al
  800bf8:	74 f9                	je     800bf3 <strtol+0xb>
  800bfa:	3c 09                	cmp    $0x9,%al
  800bfc:	74 f5                	je     800bf3 <strtol+0xb>
		s++;

	// plus/minus sign
	if (*s == '+')
  800bfe:	3c 2b                	cmp    $0x2b,%al
  800c00:	75 08                	jne    800c0a <strtol+0x22>
		s++;
  800c02:	41                   	inc    %ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c03:	bf 00 00 00 00       	mov    $0x0,%edi
  800c08:	eb 11                	jmp    800c1b <strtol+0x33>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c0a:	3c 2d                	cmp    $0x2d,%al
  800c0c:	75 08                	jne    800c16 <strtol+0x2e>
		s++, neg = 1;
  800c0e:	41                   	inc    %ecx
  800c0f:	bf 01 00 00 00       	mov    $0x1,%edi
  800c14:	eb 05                	jmp    800c1b <strtol+0x33>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c16:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c1b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800c1f:	0f 84 87 00 00 00    	je     800cac <strtol+0xc4>
  800c25:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  800c29:	75 27                	jne    800c52 <strtol+0x6a>
  800c2b:	80 39 30             	cmpb   $0x30,(%ecx)
  800c2e:	75 22                	jne    800c52 <strtol+0x6a>
  800c30:	e9 88 00 00 00       	jmp    800cbd <strtol+0xd5>
		s += 2, base = 16;
  800c35:	83 c1 02             	add    $0x2,%ecx
  800c38:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  800c3f:	eb 11                	jmp    800c52 <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
  800c41:	41                   	inc    %ecx
  800c42:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  800c49:	eb 07                	jmp    800c52 <strtol+0x6a>
	else if (base == 0)
		base = 10;
  800c4b:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)
  800c52:	b8 00 00 00 00       	mov    $0x0,%eax

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c57:	8a 11                	mov    (%ecx),%dl
  800c59:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800c5c:	80 fb 09             	cmp    $0x9,%bl
  800c5f:	77 08                	ja     800c69 <strtol+0x81>
			dig = *s - '0';
  800c61:	0f be d2             	movsbl %dl,%edx
  800c64:	83 ea 30             	sub    $0x30,%edx
  800c67:	eb 22                	jmp    800c8b <strtol+0xa3>
		else if (*s >= 'a' && *s <= 'z')
  800c69:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c6c:	89 f3                	mov    %esi,%ebx
  800c6e:	80 fb 19             	cmp    $0x19,%bl
  800c71:	77 08                	ja     800c7b <strtol+0x93>
			dig = *s - 'a' + 10;
  800c73:	0f be d2             	movsbl %dl,%edx
  800c76:	83 ea 57             	sub    $0x57,%edx
  800c79:	eb 10                	jmp    800c8b <strtol+0xa3>
		else if (*s >= 'A' && *s <= 'Z')
  800c7b:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c7e:	89 f3                	mov    %esi,%ebx
  800c80:	80 fb 19             	cmp    $0x19,%bl
  800c83:	77 14                	ja     800c99 <strtol+0xb1>
			dig = *s - 'A' + 10;
  800c85:	0f be d2             	movsbl %dl,%edx
  800c88:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800c8b:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c8e:	7d 09                	jge    800c99 <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800c90:	41                   	inc    %ecx
  800c91:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c95:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800c97:	eb be                	jmp    800c57 <strtol+0x6f>

	if (endptr)
  800c99:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c9d:	74 05                	je     800ca4 <strtol+0xbc>
		*endptr = (char *) s;
  800c9f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ca2:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800ca4:	85 ff                	test   %edi,%edi
  800ca6:	74 21                	je     800cc9 <strtol+0xe1>
  800ca8:	f7 d8                	neg    %eax
  800caa:	eb 1d                	jmp    800cc9 <strtol+0xe1>
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800cac:	80 39 30             	cmpb   $0x30,(%ecx)
  800caf:	75 9a                	jne    800c4b <strtol+0x63>
  800cb1:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800cb5:	0f 84 7a ff ff ff    	je     800c35 <strtol+0x4d>
  800cbb:	eb 84                	jmp    800c41 <strtol+0x59>
  800cbd:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800cc1:	0f 84 6e ff ff ff    	je     800c35 <strtol+0x4d>
  800cc7:	eb 89                	jmp    800c52 <strtol+0x6a>
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
}
  800cc9:	5b                   	pop    %ebx
  800cca:	5e                   	pop    %esi
  800ccb:	5f                   	pop    %edi
  800ccc:	5d                   	pop    %ebp
  800ccd:	c3                   	ret    

00800cce <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800cce:	55                   	push   %ebp
  800ccf:	89 e5                	mov    %esp,%ebp
  800cd1:	57                   	push   %edi
  800cd2:	56                   	push   %esi
  800cd3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cd4:	b8 00 00 00 00       	mov    $0x0,%eax
  800cd9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cdc:	8b 55 08             	mov    0x8(%ebp),%edx
  800cdf:	89 c3                	mov    %eax,%ebx
  800ce1:	89 c7                	mov    %eax,%edi
  800ce3:	89 c6                	mov    %eax,%esi
  800ce5:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ce7:	5b                   	pop    %ebx
  800ce8:	5e                   	pop    %esi
  800ce9:	5f                   	pop    %edi
  800cea:	5d                   	pop    %ebp
  800ceb:	c3                   	ret    

00800cec <sys_cgetc>:

int
sys_cgetc(void)
{
  800cec:	55                   	push   %ebp
  800ced:	89 e5                	mov    %esp,%ebp
  800cef:	57                   	push   %edi
  800cf0:	56                   	push   %esi
  800cf1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cf2:	ba 00 00 00 00       	mov    $0x0,%edx
  800cf7:	b8 01 00 00 00       	mov    $0x1,%eax
  800cfc:	89 d1                	mov    %edx,%ecx
  800cfe:	89 d3                	mov    %edx,%ebx
  800d00:	89 d7                	mov    %edx,%edi
  800d02:	89 d6                	mov    %edx,%esi
  800d04:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800d06:	5b                   	pop    %ebx
  800d07:	5e                   	pop    %esi
  800d08:	5f                   	pop    %edi
  800d09:	5d                   	pop    %ebp
  800d0a:	c3                   	ret    

00800d0b <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800d0b:	55                   	push   %ebp
  800d0c:	89 e5                	mov    %esp,%ebp
  800d0e:	57                   	push   %edi
  800d0f:	56                   	push   %esi
  800d10:	53                   	push   %ebx
  800d11:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d14:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d19:	b8 03 00 00 00       	mov    $0x3,%eax
  800d1e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d21:	89 cb                	mov    %ecx,%ebx
  800d23:	89 cf                	mov    %ecx,%edi
  800d25:	89 ce                	mov    %ecx,%esi
  800d27:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d29:	85 c0                	test   %eax,%eax
  800d2b:	7e 17                	jle    800d44 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d2d:	83 ec 0c             	sub    $0xc,%esp
  800d30:	50                   	push   %eax
  800d31:	6a 03                	push   $0x3
  800d33:	68 bf 23 80 00       	push   $0x8023bf
  800d38:	6a 23                	push   $0x23
  800d3a:	68 dc 23 80 00       	push   $0x8023dc
  800d3f:	e8 19 f5 ff ff       	call   80025d <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d44:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d47:	5b                   	pop    %ebx
  800d48:	5e                   	pop    %esi
  800d49:	5f                   	pop    %edi
  800d4a:	5d                   	pop    %ebp
  800d4b:	c3                   	ret    

00800d4c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d4c:	55                   	push   %ebp
  800d4d:	89 e5                	mov    %esp,%ebp
  800d4f:	57                   	push   %edi
  800d50:	56                   	push   %esi
  800d51:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d52:	ba 00 00 00 00       	mov    $0x0,%edx
  800d57:	b8 02 00 00 00       	mov    $0x2,%eax
  800d5c:	89 d1                	mov    %edx,%ecx
  800d5e:	89 d3                	mov    %edx,%ebx
  800d60:	89 d7                	mov    %edx,%edi
  800d62:	89 d6                	mov    %edx,%esi
  800d64:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d66:	5b                   	pop    %ebx
  800d67:	5e                   	pop    %esi
  800d68:	5f                   	pop    %edi
  800d69:	5d                   	pop    %ebp
  800d6a:	c3                   	ret    

00800d6b <sys_yield>:

void
sys_yield(void)
{
  800d6b:	55                   	push   %ebp
  800d6c:	89 e5                	mov    %esp,%ebp
  800d6e:	57                   	push   %edi
  800d6f:	56                   	push   %esi
  800d70:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d71:	ba 00 00 00 00       	mov    $0x0,%edx
  800d76:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d7b:	89 d1                	mov    %edx,%ecx
  800d7d:	89 d3                	mov    %edx,%ebx
  800d7f:	89 d7                	mov    %edx,%edi
  800d81:	89 d6                	mov    %edx,%esi
  800d83:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d85:	5b                   	pop    %ebx
  800d86:	5e                   	pop    %esi
  800d87:	5f                   	pop    %edi
  800d88:	5d                   	pop    %ebp
  800d89:	c3                   	ret    

00800d8a <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d8a:	55                   	push   %ebp
  800d8b:	89 e5                	mov    %esp,%ebp
  800d8d:	57                   	push   %edi
  800d8e:	56                   	push   %esi
  800d8f:	53                   	push   %ebx
  800d90:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d93:	be 00 00 00 00       	mov    $0x0,%esi
  800d98:	b8 04 00 00 00       	mov    $0x4,%eax
  800d9d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800da0:	8b 55 08             	mov    0x8(%ebp),%edx
  800da3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800da6:	89 f7                	mov    %esi,%edi
  800da8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800daa:	85 c0                	test   %eax,%eax
  800dac:	7e 17                	jle    800dc5 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dae:	83 ec 0c             	sub    $0xc,%esp
  800db1:	50                   	push   %eax
  800db2:	6a 04                	push   $0x4
  800db4:	68 bf 23 80 00       	push   $0x8023bf
  800db9:	6a 23                	push   $0x23
  800dbb:	68 dc 23 80 00       	push   $0x8023dc
  800dc0:	e8 98 f4 ff ff       	call   80025d <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800dc5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dc8:	5b                   	pop    %ebx
  800dc9:	5e                   	pop    %esi
  800dca:	5f                   	pop    %edi
  800dcb:	5d                   	pop    %ebp
  800dcc:	c3                   	ret    

00800dcd <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800dcd:	55                   	push   %ebp
  800dce:	89 e5                	mov    %esp,%ebp
  800dd0:	57                   	push   %edi
  800dd1:	56                   	push   %esi
  800dd2:	53                   	push   %ebx
  800dd3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dd6:	b8 05 00 00 00       	mov    $0x5,%eax
  800ddb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dde:	8b 55 08             	mov    0x8(%ebp),%edx
  800de1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800de4:	8b 7d 14             	mov    0x14(%ebp),%edi
  800de7:	8b 75 18             	mov    0x18(%ebp),%esi
  800dea:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dec:	85 c0                	test   %eax,%eax
  800dee:	7e 17                	jle    800e07 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800df0:	83 ec 0c             	sub    $0xc,%esp
  800df3:	50                   	push   %eax
  800df4:	6a 05                	push   $0x5
  800df6:	68 bf 23 80 00       	push   $0x8023bf
  800dfb:	6a 23                	push   $0x23
  800dfd:	68 dc 23 80 00       	push   $0x8023dc
  800e02:	e8 56 f4 ff ff       	call   80025d <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800e07:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e0a:	5b                   	pop    %ebx
  800e0b:	5e                   	pop    %esi
  800e0c:	5f                   	pop    %edi
  800e0d:	5d                   	pop    %ebp
  800e0e:	c3                   	ret    

00800e0f <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800e0f:	55                   	push   %ebp
  800e10:	89 e5                	mov    %esp,%ebp
  800e12:	57                   	push   %edi
  800e13:	56                   	push   %esi
  800e14:	53                   	push   %ebx
  800e15:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e18:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e1d:	b8 06 00 00 00       	mov    $0x6,%eax
  800e22:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e25:	8b 55 08             	mov    0x8(%ebp),%edx
  800e28:	89 df                	mov    %ebx,%edi
  800e2a:	89 de                	mov    %ebx,%esi
  800e2c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e2e:	85 c0                	test   %eax,%eax
  800e30:	7e 17                	jle    800e49 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e32:	83 ec 0c             	sub    $0xc,%esp
  800e35:	50                   	push   %eax
  800e36:	6a 06                	push   $0x6
  800e38:	68 bf 23 80 00       	push   $0x8023bf
  800e3d:	6a 23                	push   $0x23
  800e3f:	68 dc 23 80 00       	push   $0x8023dc
  800e44:	e8 14 f4 ff ff       	call   80025d <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e49:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e4c:	5b                   	pop    %ebx
  800e4d:	5e                   	pop    %esi
  800e4e:	5f                   	pop    %edi
  800e4f:	5d                   	pop    %ebp
  800e50:	c3                   	ret    

00800e51 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
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
  800e5a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e5f:	b8 08 00 00 00       	mov    $0x8,%eax
  800e64:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e67:	8b 55 08             	mov    0x8(%ebp),%edx
  800e6a:	89 df                	mov    %ebx,%edi
  800e6c:	89 de                	mov    %ebx,%esi
  800e6e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e70:	85 c0                	test   %eax,%eax
  800e72:	7e 17                	jle    800e8b <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e74:	83 ec 0c             	sub    $0xc,%esp
  800e77:	50                   	push   %eax
  800e78:	6a 08                	push   $0x8
  800e7a:	68 bf 23 80 00       	push   $0x8023bf
  800e7f:	6a 23                	push   $0x23
  800e81:	68 dc 23 80 00       	push   $0x8023dc
  800e86:	e8 d2 f3 ff ff       	call   80025d <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e8b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e8e:	5b                   	pop    %ebx
  800e8f:	5e                   	pop    %esi
  800e90:	5f                   	pop    %edi
  800e91:	5d                   	pop    %ebp
  800e92:	c3                   	ret    

00800e93 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e93:	55                   	push   %ebp
  800e94:	89 e5                	mov    %esp,%ebp
  800e96:	57                   	push   %edi
  800e97:	56                   	push   %esi
  800e98:	53                   	push   %ebx
  800e99:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e9c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ea1:	b8 09 00 00 00       	mov    $0x9,%eax
  800ea6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ea9:	8b 55 08             	mov    0x8(%ebp),%edx
  800eac:	89 df                	mov    %ebx,%edi
  800eae:	89 de                	mov    %ebx,%esi
  800eb0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800eb2:	85 c0                	test   %eax,%eax
  800eb4:	7e 17                	jle    800ecd <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800eb6:	83 ec 0c             	sub    $0xc,%esp
  800eb9:	50                   	push   %eax
  800eba:	6a 09                	push   $0x9
  800ebc:	68 bf 23 80 00       	push   $0x8023bf
  800ec1:	6a 23                	push   $0x23
  800ec3:	68 dc 23 80 00       	push   $0x8023dc
  800ec8:	e8 90 f3 ff ff       	call   80025d <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800ecd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ed0:	5b                   	pop    %ebx
  800ed1:	5e                   	pop    %esi
  800ed2:	5f                   	pop    %edi
  800ed3:	5d                   	pop    %ebp
  800ed4:	c3                   	ret    

00800ed5 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ed5:	55                   	push   %ebp
  800ed6:	89 e5                	mov    %esp,%ebp
  800ed8:	57                   	push   %edi
  800ed9:	56                   	push   %esi
  800eda:	53                   	push   %ebx
  800edb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ede:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ee3:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ee8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eeb:	8b 55 08             	mov    0x8(%ebp),%edx
  800eee:	89 df                	mov    %ebx,%edi
  800ef0:	89 de                	mov    %ebx,%esi
  800ef2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ef4:	85 c0                	test   %eax,%eax
  800ef6:	7e 17                	jle    800f0f <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ef8:	83 ec 0c             	sub    $0xc,%esp
  800efb:	50                   	push   %eax
  800efc:	6a 0a                	push   $0xa
  800efe:	68 bf 23 80 00       	push   $0x8023bf
  800f03:	6a 23                	push   $0x23
  800f05:	68 dc 23 80 00       	push   $0x8023dc
  800f0a:	e8 4e f3 ff ff       	call   80025d <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800f0f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f12:	5b                   	pop    %ebx
  800f13:	5e                   	pop    %esi
  800f14:	5f                   	pop    %edi
  800f15:	5d                   	pop    %ebp
  800f16:	c3                   	ret    

00800f17 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f17:	55                   	push   %ebp
  800f18:	89 e5                	mov    %esp,%ebp
  800f1a:	57                   	push   %edi
  800f1b:	56                   	push   %esi
  800f1c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f1d:	be 00 00 00 00       	mov    $0x0,%esi
  800f22:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f27:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f2a:	8b 55 08             	mov    0x8(%ebp),%edx
  800f2d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f30:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f33:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f35:	5b                   	pop    %ebx
  800f36:	5e                   	pop    %esi
  800f37:	5f                   	pop    %edi
  800f38:	5d                   	pop    %ebp
  800f39:	c3                   	ret    

00800f3a <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800f3a:	55                   	push   %ebp
  800f3b:	89 e5                	mov    %esp,%ebp
  800f3d:	57                   	push   %edi
  800f3e:	56                   	push   %esi
  800f3f:	53                   	push   %ebx
  800f40:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f43:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f48:	b8 0d 00 00 00       	mov    $0xd,%eax
  800f4d:	8b 55 08             	mov    0x8(%ebp),%edx
  800f50:	89 cb                	mov    %ecx,%ebx
  800f52:	89 cf                	mov    %ecx,%edi
  800f54:	89 ce                	mov    %ecx,%esi
  800f56:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f58:	85 c0                	test   %eax,%eax
  800f5a:	7e 17                	jle    800f73 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f5c:	83 ec 0c             	sub    $0xc,%esp
  800f5f:	50                   	push   %eax
  800f60:	6a 0d                	push   $0xd
  800f62:	68 bf 23 80 00       	push   $0x8023bf
  800f67:	6a 23                	push   $0x23
  800f69:	68 dc 23 80 00       	push   $0x8023dc
  800f6e:	e8 ea f2 ff ff       	call   80025d <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f73:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f76:	5b                   	pop    %ebx
  800f77:	5e                   	pop    %esi
  800f78:	5f                   	pop    %edi
  800f79:	5d                   	pop    %ebp
  800f7a:	c3                   	ret    

00800f7b <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800f7b:	55                   	push   %ebp
  800f7c:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800f7e:	8b 45 08             	mov    0x8(%ebp),%eax
  800f81:	05 00 00 00 30       	add    $0x30000000,%eax
  800f86:	c1 e8 0c             	shr    $0xc,%eax
}
  800f89:	5d                   	pop    %ebp
  800f8a:	c3                   	ret    

00800f8b <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800f8b:	55                   	push   %ebp
  800f8c:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800f8e:	8b 45 08             	mov    0x8(%ebp),%eax
  800f91:	05 00 00 00 30       	add    $0x30000000,%eax
  800f96:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800f9b:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800fa0:	5d                   	pop    %ebp
  800fa1:	c3                   	ret    

00800fa2 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800fa2:	55                   	push   %ebp
  800fa3:	89 e5                	mov    %esp,%ebp
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800fa5:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  800faa:	a8 01                	test   $0x1,%al
  800fac:	74 34                	je     800fe2 <fd_alloc+0x40>
  800fae:	a1 00 00 74 ef       	mov    0xef740000,%eax
  800fb3:	a8 01                	test   $0x1,%al
  800fb5:	74 32                	je     800fe9 <fd_alloc+0x47>
  800fb7:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800fbc:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800fbe:	89 c2                	mov    %eax,%edx
  800fc0:	c1 ea 16             	shr    $0x16,%edx
  800fc3:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800fca:	f6 c2 01             	test   $0x1,%dl
  800fcd:	74 1f                	je     800fee <fd_alloc+0x4c>
  800fcf:	89 c2                	mov    %eax,%edx
  800fd1:	c1 ea 0c             	shr    $0xc,%edx
  800fd4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800fdb:	f6 c2 01             	test   $0x1,%dl
  800fde:	75 1a                	jne    800ffa <fd_alloc+0x58>
  800fe0:	eb 0c                	jmp    800fee <fd_alloc+0x4c>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800fe2:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  800fe7:	eb 05                	jmp    800fee <fd_alloc+0x4c>
  800fe9:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  800fee:	8b 45 08             	mov    0x8(%ebp),%eax
  800ff1:	89 08                	mov    %ecx,(%eax)
			return 0;
  800ff3:	b8 00 00 00 00       	mov    $0x0,%eax
  800ff8:	eb 1a                	jmp    801014 <fd_alloc+0x72>
  800ffa:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800fff:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801004:	75 b6                	jne    800fbc <fd_alloc+0x1a>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801006:	8b 45 08             	mov    0x8(%ebp),%eax
  801009:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  80100f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801014:	5d                   	pop    %ebp
  801015:	c3                   	ret    

00801016 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801016:	55                   	push   %ebp
  801017:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801019:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
  80101d:	77 39                	ja     801058 <fd_lookup+0x42>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80101f:	8b 45 08             	mov    0x8(%ebp),%eax
  801022:	c1 e0 0c             	shl    $0xc,%eax
  801025:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80102a:	89 c2                	mov    %eax,%edx
  80102c:	c1 ea 16             	shr    $0x16,%edx
  80102f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801036:	f6 c2 01             	test   $0x1,%dl
  801039:	74 24                	je     80105f <fd_lookup+0x49>
  80103b:	89 c2                	mov    %eax,%edx
  80103d:	c1 ea 0c             	shr    $0xc,%edx
  801040:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801047:	f6 c2 01             	test   $0x1,%dl
  80104a:	74 1a                	je     801066 <fd_lookup+0x50>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80104c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80104f:	89 02                	mov    %eax,(%edx)
	return 0;
  801051:	b8 00 00 00 00       	mov    $0x0,%eax
  801056:	eb 13                	jmp    80106b <fd_lookup+0x55>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801058:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80105d:	eb 0c                	jmp    80106b <fd_lookup+0x55>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80105f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801064:	eb 05                	jmp    80106b <fd_lookup+0x55>
  801066:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80106b:	5d                   	pop    %ebp
  80106c:	c3                   	ret    

0080106d <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80106d:	55                   	push   %ebp
  80106e:	89 e5                	mov    %esp,%ebp
  801070:	53                   	push   %ebx
  801071:	83 ec 04             	sub    $0x4,%esp
  801074:	8b 45 08             	mov    0x8(%ebp),%eax
  801077:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  80107a:	3b 05 04 30 80 00    	cmp    0x803004,%eax
  801080:	75 1e                	jne    8010a0 <dev_lookup+0x33>
  801082:	eb 0e                	jmp    801092 <dev_lookup+0x25>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801084:	b8 20 30 80 00       	mov    $0x803020,%eax
  801089:	eb 0c                	jmp    801097 <dev_lookup+0x2a>
  80108b:	b8 3c 30 80 00       	mov    $0x80303c,%eax
  801090:	eb 05                	jmp    801097 <dev_lookup+0x2a>
  801092:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  801097:	89 03                	mov    %eax,(%ebx)
			return 0;
  801099:	b8 00 00 00 00       	mov    $0x0,%eax
  80109e:	eb 36                	jmp    8010d6 <dev_lookup+0x69>
int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  8010a0:	3b 05 20 30 80 00    	cmp    0x803020,%eax
  8010a6:	74 dc                	je     801084 <dev_lookup+0x17>
  8010a8:	3b 05 3c 30 80 00    	cmp    0x80303c,%eax
  8010ae:	74 db                	je     80108b <dev_lookup+0x1e>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8010b0:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8010b6:	8b 52 48             	mov    0x48(%edx),%edx
  8010b9:	83 ec 04             	sub    $0x4,%esp
  8010bc:	50                   	push   %eax
  8010bd:	52                   	push   %edx
  8010be:	68 ec 23 80 00       	push   $0x8023ec
  8010c3:	e8 6d f2 ff ff       	call   800335 <cprintf>
	*dev = 0;
  8010c8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  8010ce:	83 c4 10             	add    $0x10,%esp
  8010d1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8010d6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010d9:	c9                   	leave  
  8010da:	c3                   	ret    

008010db <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8010db:	55                   	push   %ebp
  8010dc:	89 e5                	mov    %esp,%ebp
  8010de:	56                   	push   %esi
  8010df:	53                   	push   %ebx
  8010e0:	83 ec 10             	sub    $0x10,%esp
  8010e3:	8b 75 08             	mov    0x8(%ebp),%esi
  8010e6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8010e9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010ec:	50                   	push   %eax
  8010ed:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8010f3:	c1 e8 0c             	shr    $0xc,%eax
  8010f6:	50                   	push   %eax
  8010f7:	e8 1a ff ff ff       	call   801016 <fd_lookup>
  8010fc:	83 c4 08             	add    $0x8,%esp
  8010ff:	85 c0                	test   %eax,%eax
  801101:	78 05                	js     801108 <fd_close+0x2d>
	    || fd != fd2)
  801103:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801106:	74 06                	je     80110e <fd_close+0x33>
		return (must_exist ? r : 0);
  801108:	84 db                	test   %bl,%bl
  80110a:	74 47                	je     801153 <fd_close+0x78>
  80110c:	eb 4a                	jmp    801158 <fd_close+0x7d>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80110e:	83 ec 08             	sub    $0x8,%esp
  801111:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801114:	50                   	push   %eax
  801115:	ff 36                	pushl  (%esi)
  801117:	e8 51 ff ff ff       	call   80106d <dev_lookup>
  80111c:	89 c3                	mov    %eax,%ebx
  80111e:	83 c4 10             	add    $0x10,%esp
  801121:	85 c0                	test   %eax,%eax
  801123:	78 1c                	js     801141 <fd_close+0x66>
		if (dev->dev_close)
  801125:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801128:	8b 40 10             	mov    0x10(%eax),%eax
  80112b:	85 c0                	test   %eax,%eax
  80112d:	74 0d                	je     80113c <fd_close+0x61>
			r = (*dev->dev_close)(fd);
  80112f:	83 ec 0c             	sub    $0xc,%esp
  801132:	56                   	push   %esi
  801133:	ff d0                	call   *%eax
  801135:	89 c3                	mov    %eax,%ebx
  801137:	83 c4 10             	add    $0x10,%esp
  80113a:	eb 05                	jmp    801141 <fd_close+0x66>
		else
			r = 0;
  80113c:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801141:	83 ec 08             	sub    $0x8,%esp
  801144:	56                   	push   %esi
  801145:	6a 00                	push   $0x0
  801147:	e8 c3 fc ff ff       	call   800e0f <sys_page_unmap>
	return r;
  80114c:	83 c4 10             	add    $0x10,%esp
  80114f:	89 d8                	mov    %ebx,%eax
  801151:	eb 05                	jmp    801158 <fd_close+0x7d>
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
  801153:	b8 00 00 00 00       	mov    $0x0,%eax
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
	return r;
}
  801158:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80115b:	5b                   	pop    %ebx
  80115c:	5e                   	pop    %esi
  80115d:	5d                   	pop    %ebp
  80115e:	c3                   	ret    

0080115f <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80115f:	55                   	push   %ebp
  801160:	89 e5                	mov    %esp,%ebp
  801162:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801165:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801168:	50                   	push   %eax
  801169:	ff 75 08             	pushl  0x8(%ebp)
  80116c:	e8 a5 fe ff ff       	call   801016 <fd_lookup>
  801171:	83 c4 08             	add    $0x8,%esp
  801174:	85 c0                	test   %eax,%eax
  801176:	78 10                	js     801188 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801178:	83 ec 08             	sub    $0x8,%esp
  80117b:	6a 01                	push   $0x1
  80117d:	ff 75 f4             	pushl  -0xc(%ebp)
  801180:	e8 56 ff ff ff       	call   8010db <fd_close>
  801185:	83 c4 10             	add    $0x10,%esp
}
  801188:	c9                   	leave  
  801189:	c3                   	ret    

0080118a <close_all>:

void
close_all(void)
{
  80118a:	55                   	push   %ebp
  80118b:	89 e5                	mov    %esp,%ebp
  80118d:	53                   	push   %ebx
  80118e:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801191:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801196:	83 ec 0c             	sub    $0xc,%esp
  801199:	53                   	push   %ebx
  80119a:	e8 c0 ff ff ff       	call   80115f <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80119f:	43                   	inc    %ebx
  8011a0:	83 c4 10             	add    $0x10,%esp
  8011a3:	83 fb 20             	cmp    $0x20,%ebx
  8011a6:	75 ee                	jne    801196 <close_all+0xc>
		close(i);
}
  8011a8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011ab:	c9                   	leave  
  8011ac:	c3                   	ret    

008011ad <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8011ad:	55                   	push   %ebp
  8011ae:	89 e5                	mov    %esp,%ebp
  8011b0:	57                   	push   %edi
  8011b1:	56                   	push   %esi
  8011b2:	53                   	push   %ebx
  8011b3:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8011b6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8011b9:	50                   	push   %eax
  8011ba:	ff 75 08             	pushl  0x8(%ebp)
  8011bd:	e8 54 fe ff ff       	call   801016 <fd_lookup>
  8011c2:	83 c4 08             	add    $0x8,%esp
  8011c5:	85 c0                	test   %eax,%eax
  8011c7:	0f 88 c2 00 00 00    	js     80128f <dup+0xe2>
		return r;
	close(newfdnum);
  8011cd:	83 ec 0c             	sub    $0xc,%esp
  8011d0:	ff 75 0c             	pushl  0xc(%ebp)
  8011d3:	e8 87 ff ff ff       	call   80115f <close>

	newfd = INDEX2FD(newfdnum);
  8011d8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8011db:	c1 e3 0c             	shl    $0xc,%ebx
  8011de:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8011e4:	83 c4 04             	add    $0x4,%esp
  8011e7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011ea:	e8 9c fd ff ff       	call   800f8b <fd2data>
  8011ef:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  8011f1:	89 1c 24             	mov    %ebx,(%esp)
  8011f4:	e8 92 fd ff ff       	call   800f8b <fd2data>
  8011f9:	83 c4 10             	add    $0x10,%esp
  8011fc:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8011fe:	89 f0                	mov    %esi,%eax
  801200:	c1 e8 16             	shr    $0x16,%eax
  801203:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80120a:	a8 01                	test   $0x1,%al
  80120c:	74 35                	je     801243 <dup+0x96>
  80120e:	89 f0                	mov    %esi,%eax
  801210:	c1 e8 0c             	shr    $0xc,%eax
  801213:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80121a:	f6 c2 01             	test   $0x1,%dl
  80121d:	74 24                	je     801243 <dup+0x96>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80121f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801226:	83 ec 0c             	sub    $0xc,%esp
  801229:	25 07 0e 00 00       	and    $0xe07,%eax
  80122e:	50                   	push   %eax
  80122f:	57                   	push   %edi
  801230:	6a 00                	push   $0x0
  801232:	56                   	push   %esi
  801233:	6a 00                	push   $0x0
  801235:	e8 93 fb ff ff       	call   800dcd <sys_page_map>
  80123a:	89 c6                	mov    %eax,%esi
  80123c:	83 c4 20             	add    $0x20,%esp
  80123f:	85 c0                	test   %eax,%eax
  801241:	78 2c                	js     80126f <dup+0xc2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801243:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801246:	89 d0                	mov    %edx,%eax
  801248:	c1 e8 0c             	shr    $0xc,%eax
  80124b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801252:	83 ec 0c             	sub    $0xc,%esp
  801255:	25 07 0e 00 00       	and    $0xe07,%eax
  80125a:	50                   	push   %eax
  80125b:	53                   	push   %ebx
  80125c:	6a 00                	push   $0x0
  80125e:	52                   	push   %edx
  80125f:	6a 00                	push   $0x0
  801261:	e8 67 fb ff ff       	call   800dcd <sys_page_map>
  801266:	89 c6                	mov    %eax,%esi
  801268:	83 c4 20             	add    $0x20,%esp
  80126b:	85 c0                	test   %eax,%eax
  80126d:	79 1d                	jns    80128c <dup+0xdf>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80126f:	83 ec 08             	sub    $0x8,%esp
  801272:	53                   	push   %ebx
  801273:	6a 00                	push   $0x0
  801275:	e8 95 fb ff ff       	call   800e0f <sys_page_unmap>
	sys_page_unmap(0, nva);
  80127a:	83 c4 08             	add    $0x8,%esp
  80127d:	57                   	push   %edi
  80127e:	6a 00                	push   $0x0
  801280:	e8 8a fb ff ff       	call   800e0f <sys_page_unmap>
	return r;
  801285:	83 c4 10             	add    $0x10,%esp
  801288:	89 f0                	mov    %esi,%eax
  80128a:	eb 03                	jmp    80128f <dup+0xe2>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  80128c:	8b 45 0c             	mov    0xc(%ebp),%eax

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80128f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801292:	5b                   	pop    %ebx
  801293:	5e                   	pop    %esi
  801294:	5f                   	pop    %edi
  801295:	5d                   	pop    %ebp
  801296:	c3                   	ret    

00801297 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801297:	55                   	push   %ebp
  801298:	89 e5                	mov    %esp,%ebp
  80129a:	53                   	push   %ebx
  80129b:	83 ec 14             	sub    $0x14,%esp
  80129e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012a1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012a4:	50                   	push   %eax
  8012a5:	53                   	push   %ebx
  8012a6:	e8 6b fd ff ff       	call   801016 <fd_lookup>
  8012ab:	83 c4 08             	add    $0x8,%esp
  8012ae:	85 c0                	test   %eax,%eax
  8012b0:	78 67                	js     801319 <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012b2:	83 ec 08             	sub    $0x8,%esp
  8012b5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012b8:	50                   	push   %eax
  8012b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012bc:	ff 30                	pushl  (%eax)
  8012be:	e8 aa fd ff ff       	call   80106d <dev_lookup>
  8012c3:	83 c4 10             	add    $0x10,%esp
  8012c6:	85 c0                	test   %eax,%eax
  8012c8:	78 4f                	js     801319 <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8012ca:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8012cd:	8b 42 08             	mov    0x8(%edx),%eax
  8012d0:	83 e0 03             	and    $0x3,%eax
  8012d3:	83 f8 01             	cmp    $0x1,%eax
  8012d6:	75 21                	jne    8012f9 <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8012d8:	a1 04 40 80 00       	mov    0x804004,%eax
  8012dd:	8b 40 48             	mov    0x48(%eax),%eax
  8012e0:	83 ec 04             	sub    $0x4,%esp
  8012e3:	53                   	push   %ebx
  8012e4:	50                   	push   %eax
  8012e5:	68 30 24 80 00       	push   $0x802430
  8012ea:	e8 46 f0 ff ff       	call   800335 <cprintf>
		return -E_INVAL;
  8012ef:	83 c4 10             	add    $0x10,%esp
  8012f2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012f7:	eb 20                	jmp    801319 <read+0x82>
	}
	if (!dev->dev_read)
  8012f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012fc:	8b 40 08             	mov    0x8(%eax),%eax
  8012ff:	85 c0                	test   %eax,%eax
  801301:	74 11                	je     801314 <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801303:	83 ec 04             	sub    $0x4,%esp
  801306:	ff 75 10             	pushl  0x10(%ebp)
  801309:	ff 75 0c             	pushl  0xc(%ebp)
  80130c:	52                   	push   %edx
  80130d:	ff d0                	call   *%eax
  80130f:	83 c4 10             	add    $0x10,%esp
  801312:	eb 05                	jmp    801319 <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801314:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801319:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80131c:	c9                   	leave  
  80131d:	c3                   	ret    

0080131e <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80131e:	55                   	push   %ebp
  80131f:	89 e5                	mov    %esp,%ebp
  801321:	57                   	push   %edi
  801322:	56                   	push   %esi
  801323:	53                   	push   %ebx
  801324:	83 ec 0c             	sub    $0xc,%esp
  801327:	8b 7d 08             	mov    0x8(%ebp),%edi
  80132a:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80132d:	85 f6                	test   %esi,%esi
  80132f:	74 31                	je     801362 <readn+0x44>
  801331:	b8 00 00 00 00       	mov    $0x0,%eax
  801336:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  80133b:	83 ec 04             	sub    $0x4,%esp
  80133e:	89 f2                	mov    %esi,%edx
  801340:	29 c2                	sub    %eax,%edx
  801342:	52                   	push   %edx
  801343:	03 45 0c             	add    0xc(%ebp),%eax
  801346:	50                   	push   %eax
  801347:	57                   	push   %edi
  801348:	e8 4a ff ff ff       	call   801297 <read>
		if (m < 0)
  80134d:	83 c4 10             	add    $0x10,%esp
  801350:	85 c0                	test   %eax,%eax
  801352:	78 17                	js     80136b <readn+0x4d>
			return m;
		if (m == 0)
  801354:	85 c0                	test   %eax,%eax
  801356:	74 11                	je     801369 <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801358:	01 c3                	add    %eax,%ebx
  80135a:	89 d8                	mov    %ebx,%eax
  80135c:	39 f3                	cmp    %esi,%ebx
  80135e:	72 db                	jb     80133b <readn+0x1d>
  801360:	eb 09                	jmp    80136b <readn+0x4d>
  801362:	b8 00 00 00 00       	mov    $0x0,%eax
  801367:	eb 02                	jmp    80136b <readn+0x4d>
  801369:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80136b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80136e:	5b                   	pop    %ebx
  80136f:	5e                   	pop    %esi
  801370:	5f                   	pop    %edi
  801371:	5d                   	pop    %ebp
  801372:	c3                   	ret    

00801373 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801373:	55                   	push   %ebp
  801374:	89 e5                	mov    %esp,%ebp
  801376:	53                   	push   %ebx
  801377:	83 ec 14             	sub    $0x14,%esp
  80137a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80137d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801380:	50                   	push   %eax
  801381:	53                   	push   %ebx
  801382:	e8 8f fc ff ff       	call   801016 <fd_lookup>
  801387:	83 c4 08             	add    $0x8,%esp
  80138a:	85 c0                	test   %eax,%eax
  80138c:	78 62                	js     8013f0 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80138e:	83 ec 08             	sub    $0x8,%esp
  801391:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801394:	50                   	push   %eax
  801395:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801398:	ff 30                	pushl  (%eax)
  80139a:	e8 ce fc ff ff       	call   80106d <dev_lookup>
  80139f:	83 c4 10             	add    $0x10,%esp
  8013a2:	85 c0                	test   %eax,%eax
  8013a4:	78 4a                	js     8013f0 <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8013a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013a9:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8013ad:	75 21                	jne    8013d0 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8013af:	a1 04 40 80 00       	mov    0x804004,%eax
  8013b4:	8b 40 48             	mov    0x48(%eax),%eax
  8013b7:	83 ec 04             	sub    $0x4,%esp
  8013ba:	53                   	push   %ebx
  8013bb:	50                   	push   %eax
  8013bc:	68 4c 24 80 00       	push   $0x80244c
  8013c1:	e8 6f ef ff ff       	call   800335 <cprintf>
		return -E_INVAL;
  8013c6:	83 c4 10             	add    $0x10,%esp
  8013c9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013ce:	eb 20                	jmp    8013f0 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8013d0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8013d3:	8b 52 0c             	mov    0xc(%edx),%edx
  8013d6:	85 d2                	test   %edx,%edx
  8013d8:	74 11                	je     8013eb <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8013da:	83 ec 04             	sub    $0x4,%esp
  8013dd:	ff 75 10             	pushl  0x10(%ebp)
  8013e0:	ff 75 0c             	pushl  0xc(%ebp)
  8013e3:	50                   	push   %eax
  8013e4:	ff d2                	call   *%edx
  8013e6:	83 c4 10             	add    $0x10,%esp
  8013e9:	eb 05                	jmp    8013f0 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8013eb:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8013f0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013f3:	c9                   	leave  
  8013f4:	c3                   	ret    

008013f5 <seek>:

int
seek(int fdnum, off_t offset)
{
  8013f5:	55                   	push   %ebp
  8013f6:	89 e5                	mov    %esp,%ebp
  8013f8:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013fb:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8013fe:	50                   	push   %eax
  8013ff:	ff 75 08             	pushl  0x8(%ebp)
  801402:	e8 0f fc ff ff       	call   801016 <fd_lookup>
  801407:	83 c4 08             	add    $0x8,%esp
  80140a:	85 c0                	test   %eax,%eax
  80140c:	78 0e                	js     80141c <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80140e:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801411:	8b 55 0c             	mov    0xc(%ebp),%edx
  801414:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801417:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80141c:	c9                   	leave  
  80141d:	c3                   	ret    

0080141e <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80141e:	55                   	push   %ebp
  80141f:	89 e5                	mov    %esp,%ebp
  801421:	53                   	push   %ebx
  801422:	83 ec 14             	sub    $0x14,%esp
  801425:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801428:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80142b:	50                   	push   %eax
  80142c:	53                   	push   %ebx
  80142d:	e8 e4 fb ff ff       	call   801016 <fd_lookup>
  801432:	83 c4 08             	add    $0x8,%esp
  801435:	85 c0                	test   %eax,%eax
  801437:	78 5f                	js     801498 <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801439:	83 ec 08             	sub    $0x8,%esp
  80143c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80143f:	50                   	push   %eax
  801440:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801443:	ff 30                	pushl  (%eax)
  801445:	e8 23 fc ff ff       	call   80106d <dev_lookup>
  80144a:	83 c4 10             	add    $0x10,%esp
  80144d:	85 c0                	test   %eax,%eax
  80144f:	78 47                	js     801498 <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801451:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801454:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801458:	75 21                	jne    80147b <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80145a:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80145f:	8b 40 48             	mov    0x48(%eax),%eax
  801462:	83 ec 04             	sub    $0x4,%esp
  801465:	53                   	push   %ebx
  801466:	50                   	push   %eax
  801467:	68 0c 24 80 00       	push   $0x80240c
  80146c:	e8 c4 ee ff ff       	call   800335 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801471:	83 c4 10             	add    $0x10,%esp
  801474:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801479:	eb 1d                	jmp    801498 <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  80147b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80147e:	8b 52 18             	mov    0x18(%edx),%edx
  801481:	85 d2                	test   %edx,%edx
  801483:	74 0e                	je     801493 <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801485:	83 ec 08             	sub    $0x8,%esp
  801488:	ff 75 0c             	pushl  0xc(%ebp)
  80148b:	50                   	push   %eax
  80148c:	ff d2                	call   *%edx
  80148e:	83 c4 10             	add    $0x10,%esp
  801491:	eb 05                	jmp    801498 <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801493:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801498:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80149b:	c9                   	leave  
  80149c:	c3                   	ret    

0080149d <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80149d:	55                   	push   %ebp
  80149e:	89 e5                	mov    %esp,%ebp
  8014a0:	53                   	push   %ebx
  8014a1:	83 ec 14             	sub    $0x14,%esp
  8014a4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014a7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014aa:	50                   	push   %eax
  8014ab:	ff 75 08             	pushl  0x8(%ebp)
  8014ae:	e8 63 fb ff ff       	call   801016 <fd_lookup>
  8014b3:	83 c4 08             	add    $0x8,%esp
  8014b6:	85 c0                	test   %eax,%eax
  8014b8:	78 52                	js     80150c <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014ba:	83 ec 08             	sub    $0x8,%esp
  8014bd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014c0:	50                   	push   %eax
  8014c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014c4:	ff 30                	pushl  (%eax)
  8014c6:	e8 a2 fb ff ff       	call   80106d <dev_lookup>
  8014cb:	83 c4 10             	add    $0x10,%esp
  8014ce:	85 c0                	test   %eax,%eax
  8014d0:	78 3a                	js     80150c <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  8014d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014d5:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8014d9:	74 2c                	je     801507 <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8014db:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8014de:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8014e5:	00 00 00 
	stat->st_isdir = 0;
  8014e8:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8014ef:	00 00 00 
	stat->st_dev = dev;
  8014f2:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8014f8:	83 ec 08             	sub    $0x8,%esp
  8014fb:	53                   	push   %ebx
  8014fc:	ff 75 f0             	pushl  -0x10(%ebp)
  8014ff:	ff 50 14             	call   *0x14(%eax)
  801502:	83 c4 10             	add    $0x10,%esp
  801505:	eb 05                	jmp    80150c <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801507:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80150c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80150f:	c9                   	leave  
  801510:	c3                   	ret    

00801511 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801511:	55                   	push   %ebp
  801512:	89 e5                	mov    %esp,%ebp
  801514:	56                   	push   %esi
  801515:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801516:	83 ec 08             	sub    $0x8,%esp
  801519:	6a 00                	push   $0x0
  80151b:	ff 75 08             	pushl  0x8(%ebp)
  80151e:	e8 75 01 00 00       	call   801698 <open>
  801523:	89 c3                	mov    %eax,%ebx
  801525:	83 c4 10             	add    $0x10,%esp
  801528:	85 c0                	test   %eax,%eax
  80152a:	78 1d                	js     801549 <stat+0x38>
		return fd;
	r = fstat(fd, stat);
  80152c:	83 ec 08             	sub    $0x8,%esp
  80152f:	ff 75 0c             	pushl  0xc(%ebp)
  801532:	50                   	push   %eax
  801533:	e8 65 ff ff ff       	call   80149d <fstat>
  801538:	89 c6                	mov    %eax,%esi
	close(fd);
  80153a:	89 1c 24             	mov    %ebx,(%esp)
  80153d:	e8 1d fc ff ff       	call   80115f <close>
	return r;
  801542:	83 c4 10             	add    $0x10,%esp
  801545:	89 f0                	mov    %esi,%eax
  801547:	eb 00                	jmp    801549 <stat+0x38>
}
  801549:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80154c:	5b                   	pop    %ebx
  80154d:	5e                   	pop    %esi
  80154e:	5d                   	pop    %ebp
  80154f:	c3                   	ret    

00801550 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801550:	55                   	push   %ebp
  801551:	89 e5                	mov    %esp,%ebp
  801553:	56                   	push   %esi
  801554:	53                   	push   %ebx
  801555:	89 c6                	mov    %eax,%esi
  801557:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801559:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801560:	75 12                	jne    801574 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801562:	83 ec 0c             	sub    $0xc,%esp
  801565:	6a 01                	push   $0x1
  801567:	e8 7b 07 00 00       	call   801ce7 <ipc_find_env>
  80156c:	a3 00 40 80 00       	mov    %eax,0x804000
  801571:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801574:	6a 07                	push   $0x7
  801576:	68 00 50 80 00       	push   $0x805000
  80157b:	56                   	push   %esi
  80157c:	ff 35 00 40 80 00    	pushl  0x804000
  801582:	e8 01 07 00 00       	call   801c88 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801587:	83 c4 0c             	add    $0xc,%esp
  80158a:	6a 00                	push   $0x0
  80158c:	53                   	push   %ebx
  80158d:	6a 00                	push   $0x0
  80158f:	e8 7f 06 00 00       	call   801c13 <ipc_recv>
}
  801594:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801597:	5b                   	pop    %ebx
  801598:	5e                   	pop    %esi
  801599:	5d                   	pop    %ebp
  80159a:	c3                   	ret    

0080159b <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80159b:	55                   	push   %ebp
  80159c:	89 e5                	mov    %esp,%ebp
  80159e:	53                   	push   %ebx
  80159f:	83 ec 04             	sub    $0x4,%esp
  8015a2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8015a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8015a8:	8b 40 0c             	mov    0xc(%eax),%eax
  8015ab:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8015b0:	ba 00 00 00 00       	mov    $0x0,%edx
  8015b5:	b8 05 00 00 00       	mov    $0x5,%eax
  8015ba:	e8 91 ff ff ff       	call   801550 <fsipc>
  8015bf:	85 c0                	test   %eax,%eax
  8015c1:	78 2c                	js     8015ef <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8015c3:	83 ec 08             	sub    $0x8,%esp
  8015c6:	68 00 50 80 00       	push   $0x805000
  8015cb:	53                   	push   %ebx
  8015cc:	e8 49 f3 ff ff       	call   80091a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8015d1:	a1 80 50 80 00       	mov    0x805080,%eax
  8015d6:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8015dc:	a1 84 50 80 00       	mov    0x805084,%eax
  8015e1:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8015e7:	83 c4 10             	add    $0x10,%esp
  8015ea:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015ef:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015f2:	c9                   	leave  
  8015f3:	c3                   	ret    

008015f4 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8015f4:	55                   	push   %ebp
  8015f5:	89 e5                	mov    %esp,%ebp
  8015f7:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8015fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8015fd:	8b 40 0c             	mov    0xc(%eax),%eax
  801600:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801605:	ba 00 00 00 00       	mov    $0x0,%edx
  80160a:	b8 06 00 00 00       	mov    $0x6,%eax
  80160f:	e8 3c ff ff ff       	call   801550 <fsipc>
}
  801614:	c9                   	leave  
  801615:	c3                   	ret    

00801616 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801616:	55                   	push   %ebp
  801617:	89 e5                	mov    %esp,%ebp
  801619:	56                   	push   %esi
  80161a:	53                   	push   %ebx
  80161b:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80161e:	8b 45 08             	mov    0x8(%ebp),%eax
  801621:	8b 40 0c             	mov    0xc(%eax),%eax
  801624:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801629:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80162f:	ba 00 00 00 00       	mov    $0x0,%edx
  801634:	b8 03 00 00 00       	mov    $0x3,%eax
  801639:	e8 12 ff ff ff       	call   801550 <fsipc>
  80163e:	89 c3                	mov    %eax,%ebx
  801640:	85 c0                	test   %eax,%eax
  801642:	78 4b                	js     80168f <devfile_read+0x79>
		return r;
	assert(r <= n);
  801644:	39 c6                	cmp    %eax,%esi
  801646:	73 16                	jae    80165e <devfile_read+0x48>
  801648:	68 69 24 80 00       	push   $0x802469
  80164d:	68 70 24 80 00       	push   $0x802470
  801652:	6a 7a                	push   $0x7a
  801654:	68 85 24 80 00       	push   $0x802485
  801659:	e8 ff eb ff ff       	call   80025d <_panic>
	assert(r <= PGSIZE);
  80165e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801663:	7e 16                	jle    80167b <devfile_read+0x65>
  801665:	68 90 24 80 00       	push   $0x802490
  80166a:	68 70 24 80 00       	push   $0x802470
  80166f:	6a 7b                	push   $0x7b
  801671:	68 85 24 80 00       	push   $0x802485
  801676:	e8 e2 eb ff ff       	call   80025d <_panic>
	memmove(buf, &fsipcbuf, r);
  80167b:	83 ec 04             	sub    $0x4,%esp
  80167e:	50                   	push   %eax
  80167f:	68 00 50 80 00       	push   $0x805000
  801684:	ff 75 0c             	pushl  0xc(%ebp)
  801687:	e8 5b f4 ff ff       	call   800ae7 <memmove>
	return r;
  80168c:	83 c4 10             	add    $0x10,%esp
}
  80168f:	89 d8                	mov    %ebx,%eax
  801691:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801694:	5b                   	pop    %ebx
  801695:	5e                   	pop    %esi
  801696:	5d                   	pop    %ebp
  801697:	c3                   	ret    

00801698 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801698:	55                   	push   %ebp
  801699:	89 e5                	mov    %esp,%ebp
  80169b:	53                   	push   %ebx
  80169c:	83 ec 20             	sub    $0x20,%esp
  80169f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8016a2:	53                   	push   %ebx
  8016a3:	e8 1b f2 ff ff       	call   8008c3 <strlen>
  8016a8:	83 c4 10             	add    $0x10,%esp
  8016ab:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8016b0:	7f 63                	jg     801715 <open+0x7d>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8016b2:	83 ec 0c             	sub    $0xc,%esp
  8016b5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016b8:	50                   	push   %eax
  8016b9:	e8 e4 f8 ff ff       	call   800fa2 <fd_alloc>
  8016be:	83 c4 10             	add    $0x10,%esp
  8016c1:	85 c0                	test   %eax,%eax
  8016c3:	78 55                	js     80171a <open+0x82>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8016c5:	83 ec 08             	sub    $0x8,%esp
  8016c8:	53                   	push   %ebx
  8016c9:	68 00 50 80 00       	push   $0x805000
  8016ce:	e8 47 f2 ff ff       	call   80091a <strcpy>
	fsipcbuf.open.req_omode = mode;
  8016d3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016d6:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8016db:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016de:	b8 01 00 00 00       	mov    $0x1,%eax
  8016e3:	e8 68 fe ff ff       	call   801550 <fsipc>
  8016e8:	89 c3                	mov    %eax,%ebx
  8016ea:	83 c4 10             	add    $0x10,%esp
  8016ed:	85 c0                	test   %eax,%eax
  8016ef:	79 14                	jns    801705 <open+0x6d>
		fd_close(fd, 0);
  8016f1:	83 ec 08             	sub    $0x8,%esp
  8016f4:	6a 00                	push   $0x0
  8016f6:	ff 75 f4             	pushl  -0xc(%ebp)
  8016f9:	e8 dd f9 ff ff       	call   8010db <fd_close>
		return r;
  8016fe:	83 c4 10             	add    $0x10,%esp
  801701:	89 d8                	mov    %ebx,%eax
  801703:	eb 15                	jmp    80171a <open+0x82>
	}

	return fd2num(fd);
  801705:	83 ec 0c             	sub    $0xc,%esp
  801708:	ff 75 f4             	pushl  -0xc(%ebp)
  80170b:	e8 6b f8 ff ff       	call   800f7b <fd2num>
  801710:	83 c4 10             	add    $0x10,%esp
  801713:	eb 05                	jmp    80171a <open+0x82>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801715:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80171a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80171d:	c9                   	leave  
  80171e:	c3                   	ret    

0080171f <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80171f:	55                   	push   %ebp
  801720:	89 e5                	mov    %esp,%ebp
  801722:	56                   	push   %esi
  801723:	53                   	push   %ebx
  801724:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801727:	83 ec 0c             	sub    $0xc,%esp
  80172a:	ff 75 08             	pushl  0x8(%ebp)
  80172d:	e8 59 f8 ff ff       	call   800f8b <fd2data>
  801732:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801734:	83 c4 08             	add    $0x8,%esp
  801737:	68 9c 24 80 00       	push   $0x80249c
  80173c:	53                   	push   %ebx
  80173d:	e8 d8 f1 ff ff       	call   80091a <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801742:	8b 46 04             	mov    0x4(%esi),%eax
  801745:	2b 06                	sub    (%esi),%eax
  801747:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80174d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801754:	00 00 00 
	stat->st_dev = &devpipe;
  801757:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  80175e:	30 80 00 
	return 0;
}
  801761:	b8 00 00 00 00       	mov    $0x0,%eax
  801766:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801769:	5b                   	pop    %ebx
  80176a:	5e                   	pop    %esi
  80176b:	5d                   	pop    %ebp
  80176c:	c3                   	ret    

0080176d <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80176d:	55                   	push   %ebp
  80176e:	89 e5                	mov    %esp,%ebp
  801770:	53                   	push   %ebx
  801771:	83 ec 0c             	sub    $0xc,%esp
  801774:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801777:	53                   	push   %ebx
  801778:	6a 00                	push   $0x0
  80177a:	e8 90 f6 ff ff       	call   800e0f <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80177f:	89 1c 24             	mov    %ebx,(%esp)
  801782:	e8 04 f8 ff ff       	call   800f8b <fd2data>
  801787:	83 c4 08             	add    $0x8,%esp
  80178a:	50                   	push   %eax
  80178b:	6a 00                	push   $0x0
  80178d:	e8 7d f6 ff ff       	call   800e0f <sys_page_unmap>
}
  801792:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801795:	c9                   	leave  
  801796:	c3                   	ret    

00801797 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801797:	55                   	push   %ebp
  801798:	89 e5                	mov    %esp,%ebp
  80179a:	57                   	push   %edi
  80179b:	56                   	push   %esi
  80179c:	53                   	push   %ebx
  80179d:	83 ec 1c             	sub    $0x1c,%esp
  8017a0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8017a3:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8017a5:	a1 04 40 80 00       	mov    0x804004,%eax
  8017aa:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8017ad:	83 ec 0c             	sub    $0xc,%esp
  8017b0:	ff 75 e0             	pushl  -0x20(%ebp)
  8017b3:	e8 8a 05 00 00       	call   801d42 <pageref>
  8017b8:	89 c3                	mov    %eax,%ebx
  8017ba:	89 3c 24             	mov    %edi,(%esp)
  8017bd:	e8 80 05 00 00       	call   801d42 <pageref>
  8017c2:	83 c4 10             	add    $0x10,%esp
  8017c5:	39 c3                	cmp    %eax,%ebx
  8017c7:	0f 94 c1             	sete   %cl
  8017ca:	0f b6 c9             	movzbl %cl,%ecx
  8017cd:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8017d0:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8017d6:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8017d9:	39 ce                	cmp    %ecx,%esi
  8017db:	74 1b                	je     8017f8 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8017dd:	39 c3                	cmp    %eax,%ebx
  8017df:	75 c4                	jne    8017a5 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8017e1:	8b 42 58             	mov    0x58(%edx),%eax
  8017e4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8017e7:	50                   	push   %eax
  8017e8:	56                   	push   %esi
  8017e9:	68 a3 24 80 00       	push   $0x8024a3
  8017ee:	e8 42 eb ff ff       	call   800335 <cprintf>
  8017f3:	83 c4 10             	add    $0x10,%esp
  8017f6:	eb ad                	jmp    8017a5 <_pipeisclosed+0xe>
	}
}
  8017f8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8017fb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017fe:	5b                   	pop    %ebx
  8017ff:	5e                   	pop    %esi
  801800:	5f                   	pop    %edi
  801801:	5d                   	pop    %ebp
  801802:	c3                   	ret    

00801803 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801803:	55                   	push   %ebp
  801804:	89 e5                	mov    %esp,%ebp
  801806:	57                   	push   %edi
  801807:	56                   	push   %esi
  801808:	53                   	push   %ebx
  801809:	83 ec 18             	sub    $0x18,%esp
  80180c:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80180f:	56                   	push   %esi
  801810:	e8 76 f7 ff ff       	call   800f8b <fd2data>
  801815:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801817:	83 c4 10             	add    $0x10,%esp
  80181a:	bf 00 00 00 00       	mov    $0x0,%edi
  80181f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801823:	75 42                	jne    801867 <devpipe_write+0x64>
  801825:	eb 4e                	jmp    801875 <devpipe_write+0x72>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801827:	89 da                	mov    %ebx,%edx
  801829:	89 f0                	mov    %esi,%eax
  80182b:	e8 67 ff ff ff       	call   801797 <_pipeisclosed>
  801830:	85 c0                	test   %eax,%eax
  801832:	75 46                	jne    80187a <devpipe_write+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801834:	e8 32 f5 ff ff       	call   800d6b <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801839:	8b 53 04             	mov    0x4(%ebx),%edx
  80183c:	8b 03                	mov    (%ebx),%eax
  80183e:	83 c0 20             	add    $0x20,%eax
  801841:	39 c2                	cmp    %eax,%edx
  801843:	73 e2                	jae    801827 <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801845:	8b 45 0c             	mov    0xc(%ebp),%eax
  801848:	8a 0c 38             	mov    (%eax,%edi,1),%cl
  80184b:	89 d0                	mov    %edx,%eax
  80184d:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801852:	79 05                	jns    801859 <devpipe_write+0x56>
  801854:	48                   	dec    %eax
  801855:	83 c8 e0             	or     $0xffffffe0,%eax
  801858:	40                   	inc    %eax
  801859:	88 4c 03 08          	mov    %cl,0x8(%ebx,%eax,1)
		p->p_wpos++;
  80185d:	42                   	inc    %edx
  80185e:	89 53 04             	mov    %edx,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801861:	47                   	inc    %edi
  801862:	39 7d 10             	cmp    %edi,0x10(%ebp)
  801865:	74 0e                	je     801875 <devpipe_write+0x72>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801867:	8b 53 04             	mov    0x4(%ebx),%edx
  80186a:	8b 03                	mov    (%ebx),%eax
  80186c:	83 c0 20             	add    $0x20,%eax
  80186f:	39 c2                	cmp    %eax,%edx
  801871:	73 b4                	jae    801827 <devpipe_write+0x24>
  801873:	eb d0                	jmp    801845 <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801875:	8b 45 10             	mov    0x10(%ebp),%eax
  801878:	eb 05                	jmp    80187f <devpipe_write+0x7c>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80187a:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80187f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801882:	5b                   	pop    %ebx
  801883:	5e                   	pop    %esi
  801884:	5f                   	pop    %edi
  801885:	5d                   	pop    %ebp
  801886:	c3                   	ret    

00801887 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801887:	55                   	push   %ebp
  801888:	89 e5                	mov    %esp,%ebp
  80188a:	57                   	push   %edi
  80188b:	56                   	push   %esi
  80188c:	53                   	push   %ebx
  80188d:	83 ec 18             	sub    $0x18,%esp
  801890:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801893:	57                   	push   %edi
  801894:	e8 f2 f6 ff ff       	call   800f8b <fd2data>
  801899:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80189b:	83 c4 10             	add    $0x10,%esp
  80189e:	be 00 00 00 00       	mov    $0x0,%esi
  8018a3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8018a7:	75 3d                	jne    8018e6 <devpipe_read+0x5f>
  8018a9:	eb 48                	jmp    8018f3 <devpipe_read+0x6c>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  8018ab:	89 f0                	mov    %esi,%eax
  8018ad:	eb 4e                	jmp    8018fd <devpipe_read+0x76>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8018af:	89 da                	mov    %ebx,%edx
  8018b1:	89 f8                	mov    %edi,%eax
  8018b3:	e8 df fe ff ff       	call   801797 <_pipeisclosed>
  8018b8:	85 c0                	test   %eax,%eax
  8018ba:	75 3c                	jne    8018f8 <devpipe_read+0x71>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8018bc:	e8 aa f4 ff ff       	call   800d6b <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8018c1:	8b 03                	mov    (%ebx),%eax
  8018c3:	3b 43 04             	cmp    0x4(%ebx),%eax
  8018c6:	74 e7                	je     8018af <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8018c8:	25 1f 00 00 80       	and    $0x8000001f,%eax
  8018cd:	79 05                	jns    8018d4 <devpipe_read+0x4d>
  8018cf:	48                   	dec    %eax
  8018d0:	83 c8 e0             	or     $0xffffffe0,%eax
  8018d3:	40                   	inc    %eax
  8018d4:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  8018d8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8018db:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  8018de:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8018e0:	46                   	inc    %esi
  8018e1:	39 75 10             	cmp    %esi,0x10(%ebp)
  8018e4:	74 0d                	je     8018f3 <devpipe_read+0x6c>
		while (p->p_rpos == p->p_wpos) {
  8018e6:	8b 03                	mov    (%ebx),%eax
  8018e8:	3b 43 04             	cmp    0x4(%ebx),%eax
  8018eb:	75 db                	jne    8018c8 <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8018ed:	85 f6                	test   %esi,%esi
  8018ef:	75 ba                	jne    8018ab <devpipe_read+0x24>
  8018f1:	eb bc                	jmp    8018af <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8018f3:	8b 45 10             	mov    0x10(%ebp),%eax
  8018f6:	eb 05                	jmp    8018fd <devpipe_read+0x76>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8018f8:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8018fd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801900:	5b                   	pop    %ebx
  801901:	5e                   	pop    %esi
  801902:	5f                   	pop    %edi
  801903:	5d                   	pop    %ebp
  801904:	c3                   	ret    

00801905 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801905:	55                   	push   %ebp
  801906:	89 e5                	mov    %esp,%ebp
  801908:	56                   	push   %esi
  801909:	53                   	push   %ebx
  80190a:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80190d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801910:	50                   	push   %eax
  801911:	e8 8c f6 ff ff       	call   800fa2 <fd_alloc>
  801916:	83 c4 10             	add    $0x10,%esp
  801919:	85 c0                	test   %eax,%eax
  80191b:	0f 88 2a 01 00 00    	js     801a4b <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801921:	83 ec 04             	sub    $0x4,%esp
  801924:	68 07 04 00 00       	push   $0x407
  801929:	ff 75 f4             	pushl  -0xc(%ebp)
  80192c:	6a 00                	push   $0x0
  80192e:	e8 57 f4 ff ff       	call   800d8a <sys_page_alloc>
  801933:	83 c4 10             	add    $0x10,%esp
  801936:	85 c0                	test   %eax,%eax
  801938:	0f 88 0d 01 00 00    	js     801a4b <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80193e:	83 ec 0c             	sub    $0xc,%esp
  801941:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801944:	50                   	push   %eax
  801945:	e8 58 f6 ff ff       	call   800fa2 <fd_alloc>
  80194a:	89 c3                	mov    %eax,%ebx
  80194c:	83 c4 10             	add    $0x10,%esp
  80194f:	85 c0                	test   %eax,%eax
  801951:	0f 88 e2 00 00 00    	js     801a39 <pipe+0x134>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801957:	83 ec 04             	sub    $0x4,%esp
  80195a:	68 07 04 00 00       	push   $0x407
  80195f:	ff 75 f0             	pushl  -0x10(%ebp)
  801962:	6a 00                	push   $0x0
  801964:	e8 21 f4 ff ff       	call   800d8a <sys_page_alloc>
  801969:	89 c3                	mov    %eax,%ebx
  80196b:	83 c4 10             	add    $0x10,%esp
  80196e:	85 c0                	test   %eax,%eax
  801970:	0f 88 c3 00 00 00    	js     801a39 <pipe+0x134>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801976:	83 ec 0c             	sub    $0xc,%esp
  801979:	ff 75 f4             	pushl  -0xc(%ebp)
  80197c:	e8 0a f6 ff ff       	call   800f8b <fd2data>
  801981:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801983:	83 c4 0c             	add    $0xc,%esp
  801986:	68 07 04 00 00       	push   $0x407
  80198b:	50                   	push   %eax
  80198c:	6a 00                	push   $0x0
  80198e:	e8 f7 f3 ff ff       	call   800d8a <sys_page_alloc>
  801993:	89 c3                	mov    %eax,%ebx
  801995:	83 c4 10             	add    $0x10,%esp
  801998:	85 c0                	test   %eax,%eax
  80199a:	0f 88 89 00 00 00    	js     801a29 <pipe+0x124>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8019a0:	83 ec 0c             	sub    $0xc,%esp
  8019a3:	ff 75 f0             	pushl  -0x10(%ebp)
  8019a6:	e8 e0 f5 ff ff       	call   800f8b <fd2data>
  8019ab:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8019b2:	50                   	push   %eax
  8019b3:	6a 00                	push   $0x0
  8019b5:	56                   	push   %esi
  8019b6:	6a 00                	push   $0x0
  8019b8:	e8 10 f4 ff ff       	call   800dcd <sys_page_map>
  8019bd:	89 c3                	mov    %eax,%ebx
  8019bf:	83 c4 20             	add    $0x20,%esp
  8019c2:	85 c0                	test   %eax,%eax
  8019c4:	78 55                	js     801a1b <pipe+0x116>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8019c6:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8019cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019cf:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8019d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019d4:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8019db:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8019e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019e4:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8019e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019e9:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8019f0:	83 ec 0c             	sub    $0xc,%esp
  8019f3:	ff 75 f4             	pushl  -0xc(%ebp)
  8019f6:	e8 80 f5 ff ff       	call   800f7b <fd2num>
  8019fb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8019fe:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801a00:	83 c4 04             	add    $0x4,%esp
  801a03:	ff 75 f0             	pushl  -0x10(%ebp)
  801a06:	e8 70 f5 ff ff       	call   800f7b <fd2num>
  801a0b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801a0e:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801a11:	83 c4 10             	add    $0x10,%esp
  801a14:	b8 00 00 00 00       	mov    $0x0,%eax
  801a19:	eb 30                	jmp    801a4b <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  801a1b:	83 ec 08             	sub    $0x8,%esp
  801a1e:	56                   	push   %esi
  801a1f:	6a 00                	push   $0x0
  801a21:	e8 e9 f3 ff ff       	call   800e0f <sys_page_unmap>
  801a26:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801a29:	83 ec 08             	sub    $0x8,%esp
  801a2c:	ff 75 f0             	pushl  -0x10(%ebp)
  801a2f:	6a 00                	push   $0x0
  801a31:	e8 d9 f3 ff ff       	call   800e0f <sys_page_unmap>
  801a36:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801a39:	83 ec 08             	sub    $0x8,%esp
  801a3c:	ff 75 f4             	pushl  -0xc(%ebp)
  801a3f:	6a 00                	push   $0x0
  801a41:	e8 c9 f3 ff ff       	call   800e0f <sys_page_unmap>
  801a46:	83 c4 10             	add    $0x10,%esp
  801a49:	89 d8                	mov    %ebx,%eax
    err:
	return r;
}
  801a4b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a4e:	5b                   	pop    %ebx
  801a4f:	5e                   	pop    %esi
  801a50:	5d                   	pop    %ebp
  801a51:	c3                   	ret    

00801a52 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801a52:	55                   	push   %ebp
  801a53:	89 e5                	mov    %esp,%ebp
  801a55:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a58:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a5b:	50                   	push   %eax
  801a5c:	ff 75 08             	pushl  0x8(%ebp)
  801a5f:	e8 b2 f5 ff ff       	call   801016 <fd_lookup>
  801a64:	83 c4 10             	add    $0x10,%esp
  801a67:	85 c0                	test   %eax,%eax
  801a69:	78 18                	js     801a83 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801a6b:	83 ec 0c             	sub    $0xc,%esp
  801a6e:	ff 75 f4             	pushl  -0xc(%ebp)
  801a71:	e8 15 f5 ff ff       	call   800f8b <fd2data>
	return _pipeisclosed(fd, p);
  801a76:	89 c2                	mov    %eax,%edx
  801a78:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a7b:	e8 17 fd ff ff       	call   801797 <_pipeisclosed>
  801a80:	83 c4 10             	add    $0x10,%esp
}
  801a83:	c9                   	leave  
  801a84:	c3                   	ret    

00801a85 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801a85:	55                   	push   %ebp
  801a86:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801a88:	b8 00 00 00 00       	mov    $0x0,%eax
  801a8d:	5d                   	pop    %ebp
  801a8e:	c3                   	ret    

00801a8f <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801a8f:	55                   	push   %ebp
  801a90:	89 e5                	mov    %esp,%ebp
  801a92:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801a95:	68 bb 24 80 00       	push   $0x8024bb
  801a9a:	ff 75 0c             	pushl  0xc(%ebp)
  801a9d:	e8 78 ee ff ff       	call   80091a <strcpy>
	return 0;
}
  801aa2:	b8 00 00 00 00       	mov    $0x0,%eax
  801aa7:	c9                   	leave  
  801aa8:	c3                   	ret    

00801aa9 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801aa9:	55                   	push   %ebp
  801aaa:	89 e5                	mov    %esp,%ebp
  801aac:	57                   	push   %edi
  801aad:	56                   	push   %esi
  801aae:	53                   	push   %ebx
  801aaf:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ab5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801ab9:	74 45                	je     801b00 <devcons_write+0x57>
  801abb:	b8 00 00 00 00       	mov    $0x0,%eax
  801ac0:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801ac5:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801acb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801ace:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  801ad0:	83 fb 7f             	cmp    $0x7f,%ebx
  801ad3:	76 05                	jbe    801ada <devcons_write+0x31>
			m = sizeof(buf) - 1;
  801ad5:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801ada:	83 ec 04             	sub    $0x4,%esp
  801add:	53                   	push   %ebx
  801ade:	03 45 0c             	add    0xc(%ebp),%eax
  801ae1:	50                   	push   %eax
  801ae2:	57                   	push   %edi
  801ae3:	e8 ff ef ff ff       	call   800ae7 <memmove>
		sys_cputs(buf, m);
  801ae8:	83 c4 08             	add    $0x8,%esp
  801aeb:	53                   	push   %ebx
  801aec:	57                   	push   %edi
  801aed:	e8 dc f1 ff ff       	call   800cce <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801af2:	01 de                	add    %ebx,%esi
  801af4:	89 f0                	mov    %esi,%eax
  801af6:	83 c4 10             	add    $0x10,%esp
  801af9:	3b 75 10             	cmp    0x10(%ebp),%esi
  801afc:	72 cd                	jb     801acb <devcons_write+0x22>
  801afe:	eb 05                	jmp    801b05 <devcons_write+0x5c>
  801b00:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801b05:	89 f0                	mov    %esi,%eax
  801b07:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b0a:	5b                   	pop    %ebx
  801b0b:	5e                   	pop    %esi
  801b0c:	5f                   	pop    %edi
  801b0d:	5d                   	pop    %ebp
  801b0e:	c3                   	ret    

00801b0f <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b0f:	55                   	push   %ebp
  801b10:	89 e5                	mov    %esp,%ebp
  801b12:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801b15:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801b19:	75 07                	jne    801b22 <devcons_read+0x13>
  801b1b:	eb 23                	jmp    801b40 <devcons_read+0x31>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801b1d:	e8 49 f2 ff ff       	call   800d6b <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801b22:	e8 c5 f1 ff ff       	call   800cec <sys_cgetc>
  801b27:	85 c0                	test   %eax,%eax
  801b29:	74 f2                	je     801b1d <devcons_read+0xe>
		sys_yield();
	if (c < 0)
  801b2b:	85 c0                	test   %eax,%eax
  801b2d:	78 1d                	js     801b4c <devcons_read+0x3d>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801b2f:	83 f8 04             	cmp    $0x4,%eax
  801b32:	74 13                	je     801b47 <devcons_read+0x38>
		return 0;
	*(char*)vbuf = c;
  801b34:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b37:	88 02                	mov    %al,(%edx)
	return 1;
  801b39:	b8 01 00 00 00       	mov    $0x1,%eax
  801b3e:	eb 0c                	jmp    801b4c <devcons_read+0x3d>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801b40:	b8 00 00 00 00       	mov    $0x0,%eax
  801b45:	eb 05                	jmp    801b4c <devcons_read+0x3d>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801b47:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801b4c:	c9                   	leave  
  801b4d:	c3                   	ret    

00801b4e <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801b4e:	55                   	push   %ebp
  801b4f:	89 e5                	mov    %esp,%ebp
  801b51:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801b54:	8b 45 08             	mov    0x8(%ebp),%eax
  801b57:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801b5a:	6a 01                	push   $0x1
  801b5c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801b5f:	50                   	push   %eax
  801b60:	e8 69 f1 ff ff       	call   800cce <sys_cputs>
}
  801b65:	83 c4 10             	add    $0x10,%esp
  801b68:	c9                   	leave  
  801b69:	c3                   	ret    

00801b6a <getchar>:

int
getchar(void)
{
  801b6a:	55                   	push   %ebp
  801b6b:	89 e5                	mov    %esp,%ebp
  801b6d:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801b70:	6a 01                	push   $0x1
  801b72:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801b75:	50                   	push   %eax
  801b76:	6a 00                	push   $0x0
  801b78:	e8 1a f7 ff ff       	call   801297 <read>
	if (r < 0)
  801b7d:	83 c4 10             	add    $0x10,%esp
  801b80:	85 c0                	test   %eax,%eax
  801b82:	78 0f                	js     801b93 <getchar+0x29>
		return r;
	if (r < 1)
  801b84:	85 c0                	test   %eax,%eax
  801b86:	7e 06                	jle    801b8e <getchar+0x24>
		return -E_EOF;
	return c;
  801b88:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801b8c:	eb 05                	jmp    801b93 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801b8e:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801b93:	c9                   	leave  
  801b94:	c3                   	ret    

00801b95 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801b95:	55                   	push   %ebp
  801b96:	89 e5                	mov    %esp,%ebp
  801b98:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b9b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b9e:	50                   	push   %eax
  801b9f:	ff 75 08             	pushl  0x8(%ebp)
  801ba2:	e8 6f f4 ff ff       	call   801016 <fd_lookup>
  801ba7:	83 c4 10             	add    $0x10,%esp
  801baa:	85 c0                	test   %eax,%eax
  801bac:	78 11                	js     801bbf <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801bae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bb1:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801bb7:	39 10                	cmp    %edx,(%eax)
  801bb9:	0f 94 c0             	sete   %al
  801bbc:	0f b6 c0             	movzbl %al,%eax
}
  801bbf:	c9                   	leave  
  801bc0:	c3                   	ret    

00801bc1 <opencons>:

int
opencons(void)
{
  801bc1:	55                   	push   %ebp
  801bc2:	89 e5                	mov    %esp,%ebp
  801bc4:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801bc7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bca:	50                   	push   %eax
  801bcb:	e8 d2 f3 ff ff       	call   800fa2 <fd_alloc>
  801bd0:	83 c4 10             	add    $0x10,%esp
  801bd3:	85 c0                	test   %eax,%eax
  801bd5:	78 3a                	js     801c11 <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801bd7:	83 ec 04             	sub    $0x4,%esp
  801bda:	68 07 04 00 00       	push   $0x407
  801bdf:	ff 75 f4             	pushl  -0xc(%ebp)
  801be2:	6a 00                	push   $0x0
  801be4:	e8 a1 f1 ff ff       	call   800d8a <sys_page_alloc>
  801be9:	83 c4 10             	add    $0x10,%esp
  801bec:	85 c0                	test   %eax,%eax
  801bee:	78 21                	js     801c11 <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801bf0:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801bf6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bf9:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801bfb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bfe:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801c05:	83 ec 0c             	sub    $0xc,%esp
  801c08:	50                   	push   %eax
  801c09:	e8 6d f3 ff ff       	call   800f7b <fd2num>
  801c0e:	83 c4 10             	add    $0x10,%esp
}
  801c11:	c9                   	leave  
  801c12:	c3                   	ret    

00801c13 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801c13:	55                   	push   %ebp
  801c14:	89 e5                	mov    %esp,%ebp
  801c16:	56                   	push   %esi
  801c17:	53                   	push   %ebx
  801c18:	8b 75 08             	mov    0x8(%ebp),%esi
  801c1b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c1e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");
	int r;
    if (pg != NULL) {
  801c21:	85 c0                	test   %eax,%eax
  801c23:	74 0e                	je     801c33 <ipc_recv+0x20>
        r = sys_ipc_recv(pg);
  801c25:	83 ec 0c             	sub    $0xc,%esp
  801c28:	50                   	push   %eax
  801c29:	e8 0c f3 ff ff       	call   800f3a <sys_ipc_recv>
  801c2e:	83 c4 10             	add    $0x10,%esp
  801c31:	eb 10                	jmp    801c43 <ipc_recv+0x30>
    } else {
        r = sys_ipc_recv((void *) UTOP);
  801c33:	83 ec 0c             	sub    $0xc,%esp
  801c36:	68 00 00 c0 ee       	push   $0xeec00000
  801c3b:	e8 fa f2 ff ff       	call   800f3a <sys_ipc_recv>
  801c40:	83 c4 10             	add    $0x10,%esp
    }
    if (r < 0) {
  801c43:	85 c0                	test   %eax,%eax
  801c45:	79 16                	jns    801c5d <ipc_recv+0x4a>
        // failed
        if (from_env_store != NULL) *from_env_store = 0;
  801c47:	85 f6                	test   %esi,%esi
  801c49:	74 06                	je     801c51 <ipc_recv+0x3e>
  801c4b:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        if (perm_store != NULL) *perm_store = 0;
  801c51:	85 db                	test   %ebx,%ebx
  801c53:	74 2c                	je     801c81 <ipc_recv+0x6e>
  801c55:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801c5b:	eb 24                	jmp    801c81 <ipc_recv+0x6e>
        return r;
    } else {
        if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801c5d:	85 f6                	test   %esi,%esi
  801c5f:	74 0a                	je     801c6b <ipc_recv+0x58>
  801c61:	a1 04 40 80 00       	mov    0x804004,%eax
  801c66:	8b 40 74             	mov    0x74(%eax),%eax
  801c69:	89 06                	mov    %eax,(%esi)
        if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801c6b:	85 db                	test   %ebx,%ebx
  801c6d:	74 0a                	je     801c79 <ipc_recv+0x66>
  801c6f:	a1 04 40 80 00       	mov    0x804004,%eax
  801c74:	8b 40 78             	mov    0x78(%eax),%eax
  801c77:	89 03                	mov    %eax,(%ebx)
        return thisenv->env_ipc_value;
  801c79:	a1 04 40 80 00       	mov    0x804004,%eax
  801c7e:	8b 40 70             	mov    0x70(%eax),%eax
    }
 
	return 0;
}
  801c81:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c84:	5b                   	pop    %ebx
  801c85:	5e                   	pop    %esi
  801c86:	5d                   	pop    %ebp
  801c87:	c3                   	ret    

00801c88 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801c88:	55                   	push   %ebp
  801c89:	89 e5                	mov    %esp,%ebp
  801c8b:	57                   	push   %edi
  801c8c:	56                   	push   %esi
  801c8d:	53                   	push   %ebx
  801c8e:	83 ec 0c             	sub    $0xc,%esp
  801c91:	8b 75 10             	mov    0x10(%ebp),%esi
  801c94:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");
	int r;
    if (pg == NULL) pg = (void *)UTOP;
  801c97:	85 f6                	test   %esi,%esi
  801c99:	75 05                	jne    801ca0 <ipc_send+0x18>
  801c9b:	be 00 00 c0 ee       	mov    $0xeec00000,%esi
    do {
        r = sys_ipc_try_send(to_env, val, pg, perm);
  801ca0:	57                   	push   %edi
  801ca1:	56                   	push   %esi
  801ca2:	ff 75 0c             	pushl  0xc(%ebp)
  801ca5:	ff 75 08             	pushl  0x8(%ebp)
  801ca8:	e8 6a f2 ff ff       	call   800f17 <sys_ipc_try_send>
  801cad:	89 c3                	mov    %eax,%ebx
        if (r < 0 && r != -E_IPC_NOT_RECV) panic("ipc send failed: %e", r);
  801caf:	83 c4 10             	add    $0x10,%esp
  801cb2:	85 c0                	test   %eax,%eax
  801cb4:	79 17                	jns    801ccd <ipc_send+0x45>
  801cb6:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801cb9:	74 1d                	je     801cd8 <ipc_send+0x50>
  801cbb:	50                   	push   %eax
  801cbc:	68 c7 24 80 00       	push   $0x8024c7
  801cc1:	6a 40                	push   $0x40
  801cc3:	68 db 24 80 00       	push   $0x8024db
  801cc8:	e8 90 e5 ff ff       	call   80025d <_panic>
        sys_yield();
  801ccd:	e8 99 f0 ff ff       	call   800d6b <sys_yield>
    } while (r != 0);
  801cd2:	85 db                	test   %ebx,%ebx
  801cd4:	75 ca                	jne    801ca0 <ipc_send+0x18>
  801cd6:	eb 07                	jmp    801cdf <ipc_send+0x57>
	int r;
    if (pg == NULL) pg = (void *)UTOP;
    do {
        r = sys_ipc_try_send(to_env, val, pg, perm);
        if (r < 0 && r != -E_IPC_NOT_RECV) panic("ipc send failed: %e", r);
        sys_yield();
  801cd8:	e8 8e f0 ff ff       	call   800d6b <sys_yield>
  801cdd:	eb c1                	jmp    801ca0 <ipc_send+0x18>
    } while (r != 0);
}
  801cdf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ce2:	5b                   	pop    %ebx
  801ce3:	5e                   	pop    %esi
  801ce4:	5f                   	pop    %edi
  801ce5:	5d                   	pop    %ebp
  801ce6:	c3                   	ret    

00801ce7 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801ce7:	55                   	push   %ebp
  801ce8:	89 e5                	mov    %esp,%ebp
  801cea:	53                   	push   %ebx
  801ceb:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801cee:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  801cf3:	39 c1                	cmp    %eax,%ecx
  801cf5:	74 21                	je     801d18 <ipc_find_env+0x31>
  801cf7:	ba 01 00 00 00       	mov    $0x1,%edx
  801cfc:	8d 1c 95 00 00 00 00 	lea    0x0(,%edx,4),%ebx
  801d03:	89 d0                	mov    %edx,%eax
  801d05:	c1 e0 07             	shl    $0x7,%eax
  801d08:	29 d8                	sub    %ebx,%eax
  801d0a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801d0f:	8b 40 50             	mov    0x50(%eax),%eax
  801d12:	39 c8                	cmp    %ecx,%eax
  801d14:	75 1b                	jne    801d31 <ipc_find_env+0x4a>
  801d16:	eb 05                	jmp    801d1d <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801d18:	ba 00 00 00 00       	mov    $0x0,%edx
		if (envs[i].env_type == type)
			return envs[i].env_id;
  801d1d:	8d 04 95 00 00 00 00 	lea    0x0(,%edx,4),%eax
  801d24:	c1 e2 07             	shl    $0x7,%edx
  801d27:	29 c2                	sub    %eax,%edx
  801d29:	8b 82 48 00 c0 ee    	mov    -0x113fffb8(%edx),%eax
  801d2f:	eb 0e                	jmp    801d3f <ipc_find_env+0x58>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801d31:	42                   	inc    %edx
  801d32:	81 fa 00 04 00 00    	cmp    $0x400,%edx
  801d38:	75 c2                	jne    801cfc <ipc_find_env+0x15>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801d3a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d3f:	5b                   	pop    %ebx
  801d40:	5d                   	pop    %ebp
  801d41:	c3                   	ret    

00801d42 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801d42:	55                   	push   %ebp
  801d43:	89 e5                	mov    %esp,%ebp
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801d45:	8b 45 08             	mov    0x8(%ebp),%eax
  801d48:	c1 e8 16             	shr    $0x16,%eax
  801d4b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801d52:	a8 01                	test   $0x1,%al
  801d54:	74 21                	je     801d77 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801d56:	8b 45 08             	mov    0x8(%ebp),%eax
  801d59:	c1 e8 0c             	shr    $0xc,%eax
  801d5c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801d63:	a8 01                	test   $0x1,%al
  801d65:	74 17                	je     801d7e <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801d67:	c1 e8 0c             	shr    $0xc,%eax
  801d6a:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801d71:	ef 
  801d72:	0f b7 c0             	movzwl %ax,%eax
  801d75:	eb 0c                	jmp    801d83 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801d77:	b8 00 00 00 00       	mov    $0x0,%eax
  801d7c:	eb 05                	jmp    801d83 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801d7e:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801d83:	5d                   	pop    %ebp
  801d84:	c3                   	ret    
  801d85:	66 90                	xchg   %ax,%ax
  801d87:	90                   	nop

00801d88 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801d88:	55                   	push   %ebp
  801d89:	57                   	push   %edi
  801d8a:	56                   	push   %esi
  801d8b:	53                   	push   %ebx
  801d8c:	83 ec 1c             	sub    $0x1c,%esp
  801d8f:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801d93:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801d97:	8b 7c 24 38          	mov    0x38(%esp),%edi
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801d9b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801d9f:	89 ca                	mov    %ecx,%edx
  const DWunion dd = {.ll = d};
  801da1:	89 f8                	mov    %edi,%eax
  801da3:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801da7:	85 f6                	test   %esi,%esi
  801da9:	75 2d                	jne    801dd8 <__udivdi3+0x50>
    {
      if (d0 > n1)
  801dab:	39 cf                	cmp    %ecx,%edi
  801dad:	77 65                	ja     801e14 <__udivdi3+0x8c>
  801daf:	89 fd                	mov    %edi,%ebp
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801db1:	85 ff                	test   %edi,%edi
  801db3:	75 0b                	jne    801dc0 <__udivdi3+0x38>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801db5:	b8 01 00 00 00       	mov    $0x1,%eax
  801dba:	31 d2                	xor    %edx,%edx
  801dbc:	f7 f7                	div    %edi
  801dbe:	89 c5                	mov    %eax,%ebp

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801dc0:	31 d2                	xor    %edx,%edx
  801dc2:	89 c8                	mov    %ecx,%eax
  801dc4:	f7 f5                	div    %ebp
  801dc6:	89 c1                	mov    %eax,%ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801dc8:	89 d8                	mov    %ebx,%eax
  801dca:	f7 f5                	div    %ebp
  801dcc:	89 cf                	mov    %ecx,%edi
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801dce:	89 fa                	mov    %edi,%edx
  801dd0:	83 c4 1c             	add    $0x1c,%esp
  801dd3:	5b                   	pop    %ebx
  801dd4:	5e                   	pop    %esi
  801dd5:	5f                   	pop    %edi
  801dd6:	5d                   	pop    %ebp
  801dd7:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801dd8:	39 ce                	cmp    %ecx,%esi
  801dda:	77 28                	ja     801e04 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801ddc:	0f bd fe             	bsr    %esi,%edi
	  if (bm == 0)
  801ddf:	83 f7 1f             	xor    $0x1f,%edi
  801de2:	75 40                	jne    801e24 <__udivdi3+0x9c>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801de4:	39 ce                	cmp    %ecx,%esi
  801de6:	72 0a                	jb     801df2 <__udivdi3+0x6a>
  801de8:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801dec:	0f 87 9e 00 00 00    	ja     801e90 <__udivdi3+0x108>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801df2:	b8 01 00 00 00       	mov    $0x1,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801df7:	89 fa                	mov    %edi,%edx
  801df9:	83 c4 1c             	add    $0x1c,%esp
  801dfc:	5b                   	pop    %ebx
  801dfd:	5e                   	pop    %esi
  801dfe:	5f                   	pop    %edi
  801dff:	5d                   	pop    %ebp
  801e00:	c3                   	ret    
  801e01:	8d 76 00             	lea    0x0(%esi),%esi
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801e04:	31 ff                	xor    %edi,%edi
  801e06:	31 c0                	xor    %eax,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801e08:	89 fa                	mov    %edi,%edx
  801e0a:	83 c4 1c             	add    $0x1c,%esp
  801e0d:	5b                   	pop    %ebx
  801e0e:	5e                   	pop    %esi
  801e0f:	5f                   	pop    %edi
  801e10:	5d                   	pop    %ebp
  801e11:	c3                   	ret    
  801e12:	66 90                	xchg   %ax,%ax
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801e14:	89 d8                	mov    %ebx,%eax
  801e16:	f7 f7                	div    %edi
  801e18:	31 ff                	xor    %edi,%edi
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801e1a:	89 fa                	mov    %edi,%edx
  801e1c:	83 c4 1c             	add    $0x1c,%esp
  801e1f:	5b                   	pop    %ebx
  801e20:	5e                   	pop    %esi
  801e21:	5f                   	pop    %edi
  801e22:	5d                   	pop    %ebp
  801e23:	c3                   	ret    
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801e24:	bd 20 00 00 00       	mov    $0x20,%ebp
  801e29:	89 eb                	mov    %ebp,%ebx
  801e2b:	29 fb                	sub    %edi,%ebx

	      d1 = (d1 << bm) | (d0 >> b);
  801e2d:	89 f9                	mov    %edi,%ecx
  801e2f:	d3 e6                	shl    %cl,%esi
  801e31:	89 c5                	mov    %eax,%ebp
  801e33:	88 d9                	mov    %bl,%cl
  801e35:	d3 ed                	shr    %cl,%ebp
  801e37:	89 e9                	mov    %ebp,%ecx
  801e39:	09 f1                	or     %esi,%ecx
  801e3b:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
	      d0 = d0 << bm;
  801e3f:	89 f9                	mov    %edi,%ecx
  801e41:	d3 e0                	shl    %cl,%eax
  801e43:	89 c5                	mov    %eax,%ebp
	      n2 = n1 >> b;
  801e45:	89 d6                	mov    %edx,%esi
  801e47:	88 d9                	mov    %bl,%cl
  801e49:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
  801e4b:	89 f9                	mov    %edi,%ecx
  801e4d:	d3 e2                	shl    %cl,%edx
  801e4f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801e53:	88 d9                	mov    %bl,%cl
  801e55:	d3 e8                	shr    %cl,%eax
  801e57:	09 c2                	or     %eax,%edx
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801e59:	89 d0                	mov    %edx,%eax
  801e5b:	89 f2                	mov    %esi,%edx
  801e5d:	f7 74 24 0c          	divl   0xc(%esp)
  801e61:	89 d6                	mov    %edx,%esi
  801e63:	89 c3                	mov    %eax,%ebx
	      umul_ppmm (m1, m0, q0, d0);
  801e65:	f7 e5                	mul    %ebp

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801e67:	39 d6                	cmp    %edx,%esi
  801e69:	72 19                	jb     801e84 <__udivdi3+0xfc>
  801e6b:	74 0b                	je     801e78 <__udivdi3+0xf0>
  801e6d:	89 d8                	mov    %ebx,%eax
  801e6f:	31 ff                	xor    %edi,%edi
  801e71:	e9 58 ff ff ff       	jmp    801dce <__udivdi3+0x46>
  801e76:	66 90                	xchg   %ax,%ax
  801e78:	8b 54 24 08          	mov    0x8(%esp),%edx
  801e7c:	89 f9                	mov    %edi,%ecx
  801e7e:	d3 e2                	shl    %cl,%edx
  801e80:	39 c2                	cmp    %eax,%edx
  801e82:	73 e9                	jae    801e6d <__udivdi3+0xe5>
  801e84:	8d 43 ff             	lea    -0x1(%ebx),%eax
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801e87:	31 ff                	xor    %edi,%edi
  801e89:	e9 40 ff ff ff       	jmp    801dce <__udivdi3+0x46>
  801e8e:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801e90:	31 c0                	xor    %eax,%eax
  801e92:	e9 37 ff ff ff       	jmp    801dce <__udivdi3+0x46>
  801e97:	90                   	nop

00801e98 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  801e98:	55                   	push   %ebp
  801e99:	57                   	push   %edi
  801e9a:	56                   	push   %esi
  801e9b:	53                   	push   %ebx
  801e9c:	83 ec 1c             	sub    $0x1c,%esp
  801e9f:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801ea3:	8b 74 24 34          	mov    0x34(%esp),%esi
  801ea7:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801eab:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801eaf:	89 44 24 0c          	mov    %eax,0xc(%esp)
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801eb3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801eb7:	89 f3                	mov    %esi,%ebx
  const DWunion dd = {.ll = d};
  801eb9:	89 fa                	mov    %edi,%edx
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  801ebb:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  n1 = nn.s.high;
  801ebf:	89 34 24             	mov    %esi,(%esp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801ec2:	85 c0                	test   %eax,%eax
  801ec4:	75 1a                	jne    801ee0 <__umoddi3+0x48>
    {
      if (d0 > n1)
  801ec6:	39 f7                	cmp    %esi,%edi
  801ec8:	0f 86 a2 00 00 00    	jbe    801f70 <__umoddi3+0xd8>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801ece:	89 c8                	mov    %ecx,%eax
  801ed0:	89 f2                	mov    %esi,%edx
  801ed2:	f7 f7                	div    %edi
  801ed4:	89 d0                	mov    %edx,%eax

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  801ed6:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801ed8:	83 c4 1c             	add    $0x1c,%esp
  801edb:	5b                   	pop    %ebx
  801edc:	5e                   	pop    %esi
  801edd:	5f                   	pop    %edi
  801ede:	5d                   	pop    %ebp
  801edf:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801ee0:	39 f0                	cmp    %esi,%eax
  801ee2:	0f 87 ac 00 00 00    	ja     801f94 <__umoddi3+0xfc>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801ee8:	0f bd e8             	bsr    %eax,%ebp
	  if (bm == 0)
  801eeb:	83 f5 1f             	xor    $0x1f,%ebp
  801eee:	0f 84 ac 00 00 00    	je     801fa0 <__umoddi3+0x108>
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801ef4:	bf 20 00 00 00       	mov    $0x20,%edi
  801ef9:	29 ef                	sub    %ebp,%edi
  801efb:	89 fe                	mov    %edi,%esi
  801efd:	89 7c 24 0c          	mov    %edi,0xc(%esp)

	      d1 = (d1 << bm) | (d0 >> b);
  801f01:	89 e9                	mov    %ebp,%ecx
  801f03:	d3 e0                	shl    %cl,%eax
  801f05:	89 d7                	mov    %edx,%edi
  801f07:	89 f1                	mov    %esi,%ecx
  801f09:	d3 ef                	shr    %cl,%edi
  801f0b:	09 c7                	or     %eax,%edi
	      d0 = d0 << bm;
  801f0d:	89 e9                	mov    %ebp,%ecx
  801f0f:	d3 e2                	shl    %cl,%edx
  801f11:	89 14 24             	mov    %edx,(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801f14:	89 d8                	mov    %ebx,%eax
  801f16:	d3 e0                	shl    %cl,%eax
  801f18:	89 c2                	mov    %eax,%edx
	      n0 = n0 << bm;
  801f1a:	8b 44 24 08          	mov    0x8(%esp),%eax
  801f1e:	d3 e0                	shl    %cl,%eax
  801f20:	89 44 24 04          	mov    %eax,0x4(%esp)

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801f24:	8b 44 24 08          	mov    0x8(%esp),%eax
  801f28:	89 f1                	mov    %esi,%ecx
  801f2a:	d3 e8                	shr    %cl,%eax
  801f2c:	09 d0                	or     %edx,%eax
  801f2e:	d3 eb                	shr    %cl,%ebx
  801f30:	89 da                	mov    %ebx,%edx
  801f32:	f7 f7                	div    %edi
  801f34:	89 d3                	mov    %edx,%ebx
	      umul_ppmm (m1, m0, q0, d0);
  801f36:	f7 24 24             	mull   (%esp)
  801f39:	89 c6                	mov    %eax,%esi
  801f3b:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801f3d:	39 d3                	cmp    %edx,%ebx
  801f3f:	0f 82 87 00 00 00    	jb     801fcc <__umoddi3+0x134>
  801f45:	0f 84 91 00 00 00    	je     801fdc <__umoddi3+0x144>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  801f4b:	8b 54 24 04          	mov    0x4(%esp),%edx
  801f4f:	29 f2                	sub    %esi,%edx
  801f51:	19 cb                	sbb    %ecx,%ebx
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801f53:	89 d8                	mov    %ebx,%eax
  801f55:	8a 4c 24 0c          	mov    0xc(%esp),%cl
  801f59:	d3 e0                	shl    %cl,%eax
  801f5b:	89 e9                	mov    %ebp,%ecx
  801f5d:	d3 ea                	shr    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  801f5f:	09 d0                	or     %edx,%eax
  801f61:	89 e9                	mov    %ebp,%ecx
  801f63:	d3 eb                	shr    %cl,%ebx
  801f65:	89 da                	mov    %ebx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801f67:	83 c4 1c             	add    $0x1c,%esp
  801f6a:	5b                   	pop    %ebx
  801f6b:	5e                   	pop    %esi
  801f6c:	5f                   	pop    %edi
  801f6d:	5d                   	pop    %ebp
  801f6e:	c3                   	ret    
  801f6f:	90                   	nop
  801f70:	89 fd                	mov    %edi,%ebp
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801f72:	85 ff                	test   %edi,%edi
  801f74:	75 0b                	jne    801f81 <__umoddi3+0xe9>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801f76:	b8 01 00 00 00       	mov    $0x1,%eax
  801f7b:	31 d2                	xor    %edx,%edx
  801f7d:	f7 f7                	div    %edi
  801f7f:	89 c5                	mov    %eax,%ebp

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801f81:	89 f0                	mov    %esi,%eax
  801f83:	31 d2                	xor    %edx,%edx
  801f85:	f7 f5                	div    %ebp
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801f87:	89 c8                	mov    %ecx,%eax
  801f89:	f7 f5                	div    %ebp
  801f8b:	89 d0                	mov    %edx,%eax
  801f8d:	e9 44 ff ff ff       	jmp    801ed6 <__umoddi3+0x3e>
  801f92:	66 90                	xchg   %ax,%ax
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  801f94:	89 c8                	mov    %ecx,%eax
  801f96:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801f98:	83 c4 1c             	add    $0x1c,%esp
  801f9b:	5b                   	pop    %ebx
  801f9c:	5e                   	pop    %esi
  801f9d:	5f                   	pop    %edi
  801f9e:	5d                   	pop    %ebp
  801f9f:	c3                   	ret    

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801fa0:	3b 04 24             	cmp    (%esp),%eax
  801fa3:	72 06                	jb     801fab <__umoddi3+0x113>
  801fa5:	3b 7c 24 04          	cmp    0x4(%esp),%edi
  801fa9:	77 0f                	ja     801fba <__umoddi3+0x122>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801fab:	89 f2                	mov    %esi,%edx
  801fad:	29 f9                	sub    %edi,%ecx
  801faf:	1b 54 24 0c          	sbb    0xc(%esp),%edx
  801fb3:	89 14 24             	mov    %edx,(%esp)
  801fb6:	89 4c 24 04          	mov    %ecx,0x4(%esp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  801fba:	8b 44 24 04          	mov    0x4(%esp),%eax
  801fbe:	8b 14 24             	mov    (%esp),%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801fc1:	83 c4 1c             	add    $0x1c,%esp
  801fc4:	5b                   	pop    %ebx
  801fc5:	5e                   	pop    %esi
  801fc6:	5f                   	pop    %edi
  801fc7:	5d                   	pop    %ebp
  801fc8:	c3                   	ret    
  801fc9:	8d 76 00             	lea    0x0(%esi),%esi
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801fcc:	2b 04 24             	sub    (%esp),%eax
  801fcf:	19 fa                	sbb    %edi,%edx
  801fd1:	89 d1                	mov    %edx,%ecx
  801fd3:	89 c6                	mov    %eax,%esi
  801fd5:	e9 71 ff ff ff       	jmp    801f4b <__umoddi3+0xb3>
  801fda:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801fdc:	39 44 24 04          	cmp    %eax,0x4(%esp)
  801fe0:	72 ea                	jb     801fcc <__umoddi3+0x134>
  801fe2:	89 d9                	mov    %ebx,%ecx
  801fe4:	e9 62 ff ff ff       	jmp    801f4b <__umoddi3+0xb3>
